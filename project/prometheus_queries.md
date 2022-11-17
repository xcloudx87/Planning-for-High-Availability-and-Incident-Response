## Availability SLI

### The percentage of successful requests over the last 5m
<br>
sum(rate(flask\_http\_request\_total{instance="18.221.65.230:80", status="200"}[5m])) / sum(rate(flask\_http\_request\_total{instance="18.221.65.230:80"}[5m]))

## Latency SLI

### 90% of requests finish in these times
<br>
histogram\_quantile(0.9, sum by(le, verb) (rate(flask\_http\_request\_duration\_seconds\_bucket{instance="18.221.65.230:80"}[5m])))

## Throughput

### Successful requests per second
<br>
rate(flask\_http\_request\_duration\_seconds\_count{instance="18.221.65.230:80"}[1m])

## Error Budget - Remaining Error Budget

### The error budget is 20%
<br>
1 - ((1 - (sum(increase(flask\_http\_request\_total{instance="18.221.65.230:80", status="200"}[7d])) by (verb)) / sum(increase(flask\_http\_request\_total{instance="18.221.65.230:80"}[7d])) by (verb)) / (1 - .80))