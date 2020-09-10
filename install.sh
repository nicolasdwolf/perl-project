
#!/bin/bash
cpan install Plack && \
cpan install Dancer2 && \
cpan install Dancer2::Plugin::REST && \
cpan install Try::Tiny && \
cpan install Error::Return && \
cpan install Data::Dumper && \
cpan install DBM::Deep && \
cpan install Starman
