FROM perl

RUN mkdir /pacBuilder 
ADD . /pacBuilder/
WORKDIR /pacBuilder 
RUN cpan "Data::Validate::IP"
RUN cpan "Net::Netmask"
# RUN apk add upx
CMD ["./dopac.pl"]
