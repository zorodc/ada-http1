with HTTP;         use HTTP;
with HTTP.Request; use HTTP.Request;

procedure Test is
   CRLF        : constant String := ASCII.CR & ASCII.LF;
   Test_String : constant String :=
	 "GET /index.html HTTP/1.1"                                   & CRLF &
	 "User-Agent: Mozilla/4.0 (compatible; MSIE5.01; Windows NT)" & CRLF &
	 "Host: www.adaisquitecool.com"                               & CRLF &
	 "Accept-Language: en-us"                                     & CRLF &
	 "Accept-Encoding: gzip, deflate"                             & CRLF &
	 "Connection: Keep-Alive"                                     & CRLF & CRLF;
   HTTP_Parser : Parse.Context;
   Read_Length :       Natural;
begin
   Parse.Str_Read (HTTP_Parser, Test_String, Read_Length);
   Parse.Debug    (HTTP_Parser, Test_String);
end Test;
