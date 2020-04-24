# AXA EPA
APM EPA plugin to collect transaction counts from AXA


### Config Files edited:

* IntroscopeEPAgent.properties:

```
introscope.epagent.plugins.stateless.names=AXA
introscope.epagent.stateless.AXA.command=perl /opt/ca/epagent/epaplugins/axa/transactions.pl
introscope.epagent.stateless.AXA.delayInSeconds=15
introscope.epagent.stateless.AXA.metricNotReportedAction=zero
```

* conf/EPAService.conf:

```
wrapper.java.command=/opt/ca/axa/java/jre1.8.0_151/bin/java
```

* /usr/share/perl5/JSON/PP.pm

```
Downloaded from: https://metacpan.org/source/MAKAMAKA/JSON-PP-2.27400/lib/JSON/PP.pm
```
