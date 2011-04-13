module Umpire
  module Redis
    def count_exists?(fqdn)
      $redis.hexists 'counts', fqdn
    end

    def all_counts
      $redis.hgetall 'counts'
    end

    def fetch_count(fqdn)
      $redis.hget 'counts', fqdn
    end

    def inc_count(fqdn)
      $redis.hincrby('counts', fqdn, 1)
    end

    def new_count(fqdn)
      $redis.hset 'counts', fqdn, 1
    end
    
    def del_count(fqdn)
      $redis.hdel 'counts', fqdn
    end
  end
end
