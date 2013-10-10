module Holginator
  module SinatraHelper

    MONTHS = %w(Januar Februar März April Mai Juni Juli August September Oktober November Dezember)

    def etag_for_feed
      etag_key   = "holginator:etag:#{params[:feed]}"
      $redis.get(etag_key)
    end

    def log_request
      time = Time.now
      key  = "#{params[:feed]}:stats:#{time.month}"
      if $redis.get(key)
        $redis.incr(key)
      else
        $redis.set(key, 1)
      end
    end

    def aggregate_stats
      current_month = Time.now.month
      months = (1..current_month)
      stats = $redis.multi do
        months.each do |month|
          $redis.get "#{params[:feed]}:stats:#{month}"      
        end
      end

      stats_for_each_month = []
      stats.each_with_index do |monthly_requests, index| 
        month = index + 1
        stats_for_each_month << monthly_requests
      end
      stats_for_each_month
    end  

    def stats_for_api
      { stats: aggregate_stats }
    end

    def month_for_index(index)
      MONTHS[index]
    end
  end
end