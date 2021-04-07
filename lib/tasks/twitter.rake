namespace :usasearch do
  namespace :twitter do

    desc 'prune tweets older than X days (default 3)'
    task :expire, [:days_back] => [:environment] do |_t, args|
      args.with_defaults(days_back: 3)
      Tweet.expire(args.days_back.to_i)
    end

    desc 'optimize the elastic_tweets index'
    task :optimize_index => :environment do
      ElasticTweet.optimize
    end

    desc 'refresh twitter lists members'
    task :refresh_lists, [:host] => :environment do |_t, args|
      args.with_defaults host: 'default'
      ContinuousWorker.start { TwitterData.refresh_lists }
    end

    desc 'refresh tweets from lists'
    task :refresh_lists_statuses, [:host] => :environment do |_t, args|
      args.with_defaults host: 'default'
      ContinuousWorker.start { TwitterData.refresh_lists_statuses }
    end

    desc "Connect to Twitter Streaming API and capture tweets from all customer twitter accounts"
    task :stream => [:environment] do

      logger = ActiveSupport::Logger.new(Rails.root.to_s + "/log/twitter.log")
      twitter_ids_holder = SynchronizedObjectHolder.new { TwitterProfile.active_twitter_ids }
      twitter_client = Twitter::Streaming::Client.new do |client|
        client.consumer_key = Rails.application.secrets.twitter['consumer_key']
        client.consumer_secret = Rails.application.secrets.twitter['consumer_secret']
        client.access_token = Rails.application.secrets.twitter['access_token']
        client.access_token_secret = Rails.application.secrets.twitter['access_token_secret']
      end

      do_follow = lambda do |twitter_client|
        twitter_ids = twitter_ids_holder.get_object_and_reset_changed
        if twitter_ids.present?
          logger.info "[#{Time.now}] [TWITTER] [CONNECT] Connecting to Twitter to follow #{twitter_ids.size} Twitter profiles."
          twitter_ids_string= twitter_ids.map(&:to_s).join(',')

          # DEBUG
          puts "do_follow: about to call filter: twitter_ids_string: #{twitter_ids_string.inspect}"

          twitter_client.filter(follow: twitter_ids_string) do |status|
            # DEBUG
            puts "do_follow: filter_block: status: #{status.inspect}"

            case status
            when Twitter::Tweet
              logger.info "[#{Time.now}] [TWITTER] [FOLLOW] New tweet received: @#{status.user.screen_name}: #{status.text}"
              begin
                TwitterData.import_tweet(status) if twitter_ids.include?(status.user.id)
              rescue Exception => e
                logger.error "[#{Time.now}] [TWITTER] [FOLLOW] [ERROR] Encountered error while handling tweet with status_id=#{status.id}: #{e.message}"
              end
            when Twitter::Streaming::DeletedTweet
              logger.info "[#{Time.now}] [TWITTER] [ONDELETE] Received delete request for status##{status.id}"
              Tweet.where(tweet_id: status_id).destroy_all
            end
          end
        end
      end

      do_follow.call(twitter_client)

      #   EventMachine.add_periodic_timer(60) do
      #     if twitter_ids_holder.object_changed?
      #       logger.info "[#{Time.now}] [TWITTER] [RESET_STREAM]"
      #       twitter_client.stop_stream
      #       do_follow.call(twitter_client)
      #     end
      #   end
      # end
    end
  end
end
