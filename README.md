# perl-project

## UPDATE
I realize I've forgot to provide a binary. My previous code couldn't be compiled so I've rewriten the controller to use a built-in web server and part of the model too.
New code is /MyWebServer.pl which acts as the controller now.

## Install dependencies << DEPRECATED
`$ bash ./install.sh`

Note: If starman is not installed with cpan, try with `apt install starman` (if running debian or derivates)

## Start webserver 
`$ ./MyWebServer`

Older version: `$ starman bin/app.psgi`

Point the browser to http://localhost:5000/index.html

### Notes
In order to have multiple concurrency support I've used starman web server which uses preforks.

It was difficult to find a good package to store data in-memory still shareable inter-process with no added dependencies like memcached, redis, etc.

I've used DBM::Deep which is file based but the OS will work most of the time in memory. This package has also locking mechanism out of the box.

I've added a sleep(1) in methods that write and locks the database in order to simulate an external slow requests and do a stress test and see how behaves with multiple concurrency.

### Concurency test
Send 50 request at the same time (It will take 50 seconds) \
`siege -v -c50 -r1 --content-type "application/json" 'http://localhost:5000/api/transaction POST {"type":"credit","amount":1}'`

siege result:
```Transactions:                     50 hits
Availability:                 100.00 %
Elapsed time:                  50.45 secs
Data transferred:               0.00 MB
Response time:                 25.74 secs
Transaction rate:               0.99 trans/sec
Throughput:                     0.00 MB/sec
Concurrency:                   25.51
Successful transactions:          50
Failed transactions:               0
Longest transaction:           50.42
Shortest transaction:           1.02
```
Check balance. It should return 50. If it shows less it means it failed.
`curl --request GET --url http://localhost:5000/api/balance`



