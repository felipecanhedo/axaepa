#import our modules
use FindBin;
use lib ("$FindBin::Bin", "$FindBin::Bin/../lib/perl");
use Wily::PrintMetric;
use JSON::PP; #requires perl 5.14 or download PP.pm from https://metacpan.org/source/MAKAMAKA/JSON-PP-2.27400/lib/JSON/PP.pm --no compile required
use strict;

my $url = 'http://s1axap09:9200/ao_axa_session_events_*_bnbldap/_search';

#query for all transaction events aggregated by app.id, event.value (holds transaction name) and event.sub_type (status: started/failed/ended ok)
my $query = '{"size":0,"query":{"bool":{"must":[{"term":{"event.type":"TRANSACTION"}},{"range":{"event.timestamp":{"gte":"now-15s","lte":"now"}}}]}},"_source":{"excludes":[]},"aggs":{"app":{"terms":{"field":"app.id","size":50,"order":{"_count":"desc"}},"aggs":{"transaction":{"terms":{"field":"event.value","size":50,"order":{"_count":"desc"}},"aggs":{"status":{"terms":{"field":"event.sub_type","size":50,"order":{"_count":"desc"}}}}}}}}}';

#run query and decode json
my $response = `curl -s $url -H 'content-type: application/json' -d '$query'`;

my $json = decode_json $response;

return unless $$json{'aggregations'};
return unless $$json{'aggregations'}{'app'};



#foreach app -> transactions -> status, print apm metrics
foreach my $app (@{$$json{'aggregations'}{'app'}{'buckets'}}) {

  my $appName = $$app{'key'};

  foreach my $transaction (@{$$app{'transaction'}{'buckets'}}) {

    my $transactionName = $$transaction{'key'};

    foreach my $status (@{$$transaction{'status'}{'buckets'}}) {

      my $statusName = $$status{'key'};
      $statusName = 'Started' if $statusName eq 'apptxn_start';
      $statusName = 'Finished' if $statusName eq 'apptxn_end';
      $statusName = 'Failed' if $statusName eq 'apptxn_fail';

      my $statusCount = $$status{'doc_count'};

      Wily::PrintMetric::printMetric('IntCounter', "AXA|$appName|$transactionName|$statusName:count", $statusCount);
    }
  }
}
