FROM alpine

RUN mkdir /pacBuilder 
ADD . /pacBuilder/
WORKDIR /pacBuilder 

RUN apk update
RUN apk add perl
RUN apk add perl-utils
RUN apk add make
RUN cpan "Data::Validate::IP"
RUN cpan "Net::Netmask"
#CMD ["./sleeper.sh"]
CMD ["./dopac.pl"]

