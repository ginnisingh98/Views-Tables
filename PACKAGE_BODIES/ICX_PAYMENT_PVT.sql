--------------------------------------------------------
--  DDL for Package Body ICX_PAYMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_PAYMENT_PVT" as
/* $Header: ICXPSPVB.pls 115.5 99/07/17 03:20:34 porting ship $ */

procedure unpack_results(l_string in  varchar2,
                         l_names  out v240_table,
			 l_values out v240_table) is
l_length        number(15)	:= length(l_string) + 1;
l_count         number(15);
l_index         number(15)	:= 1;
l_char          varchar(1)	:= '';
l_word          varchar(240)	:= '';
l_name		boolean		:= TRUE;
debug		boolean		:= FALSE;
begin
l_count := instr(l_string,'</H2>');

if l_count > 0
then
    l_count := l_count +5;
end if;
if debug
then
    htp.p('DEBUG string = '||l_string);htp.nl;
    htp.p('DEBUG l_count = '||l_count||' l_length = '||l_length);htp.nl;
end if;
while l_count < l_length loop
	if l_name and substr(l_string,l_count,1) = ':'
	then
		l_names(l_index) := ltrim(rtrim(l_word));

		if debug
		then
		    htp.p('DEBUG name = '||l_word);
		end if;
		l_name := FALSE;
		l_word := '';
		l_count := l_count + 1;
	elsif l_name
	then
                l_char := substr(l_string,l_count,1);
		l_word := l_word||l_char;
                l_count := l_count + 1;
	elsif upper(substr(l_string,l_count,4)) = '<BR>'

	then
		l_values(l_index) := ltrim(rtrim(l_word));
		if debug
		then
		    htp.p(' value = '||l_word);htp.nl;
		end if;
		l_name := TRUE;
		l_word := '';
		l_index := l_index + 1;
		l_count := l_count + 4;
	else
		l_char := substr(l_string,l_count,1);
		l_word := l_word||l_char;

		l_count := l_count + 1;
	end if;
end loop;
exception
        when others then
                htp.p(SQLERRM);
end;

/*
 Gets the url for the Payment Server from the profile ICX_PAY_SERVER
*/
function GetServerUrl
	return varchar2 is

  l_url	varchar2(2000) := null;

begin
  fnd_profile.get('ICX_PAY_SERVER', l_url);

  return(l_url);

end GetServerUrl;


procedure orapmtlist(
                OapfStoreId     in      varchar2,
                OapfEmail       in      varchar2        default null,
                OapfNumber      out     varchar2,
                OapfPmtType     out     v240_table) is
l_url           varchar2(2000);

l_html          varchar2(2000);
l_names         v240_table;
l_values        v240_table;
debug           boolean  := FALSE;
begin
/* Open issue; does this come from FND_PROFILE or a input parameter*/
--l_url := 'http://ap571sun.us.oracle.com:9999/orapmt/OraPmt?';
l_url := icx_payment_pvt.GetServerUrl ||'?';
l_url := l_url||'OapfAction=orapmtlist'||'&';
l_url := l_url||'OapfStoreId='||OapfStoreId||'&';
l_url := l_url||'OapfEmail='||OapfEmail;
l_url := replace(l_url,' ','+');
if debug
then

    htp.p('DEBUG URL = '||l_url);htp.nl;
end if;
l_html := utl_http.request(l_url);
if debug
then
    htp.p('DEBUG HTML = '||l_html);
end if;
unpack_results(l_html,l_names,l_values);
OapfNumber := l_values(1);
for i in 2..l_names.COUNT loop
    OapfPmtType(i-1) := l_values(i);
end loop;
exception

        when others then
                OapfNumber := -1;
		OapfPmtType(-1) := SQLERRM;
end;

procedure orainv(
                OapfOrderId     in out  varchar2,
                OapfCurr        in      varchar2,
                OapfPrice       in out  varchar2,
                OapfAuthType    in      varchar2,
                OapfPmtType     in      varchar2,
                OapfStoreId     in      varchar2,
                OapfPayURL      in      varchar2,
                OapfReturnURL   in      varchar2,

                OapfFile        in      varchar2        default null,
                OapfCustName    in      varchar2        default null,
                OapfAddr1       in      varchar2        default null,
                OapfAddr2       in      varchar2        default null,
                OapfAddr3       in      varchar2        default null,
                OapfCity        in      varchar2        default null,
                OapfCnty        in      varchar2        default null,
                OapfState       in      varchar2        default null,
                OapfCntry       in      varchar2        default null,
                OapfPostalCode  in      varchar2        default null,
                OapfPhone       in      varchar2        default null,
                OapfEmail       in      varchar2        default null,
                OapfStatus      out     varchar2,

                OapfErrLocation out     varchar2,
                OapfVendErrCode out     varchar2,
                OapfVendErrmsg  out     varchar2) is
l_url           varchar2(2000);
l_html          varchar2(2000);
l_names         v240_table;
l_values        v240_table;
debug           boolean  := FALSE;
begin
/* Open issue; does this come from FND_PROFILE or a input parameter*/
--l_url := 'http://ap571sun.us.oracle.com:9999/orapmt/OraPmt?';
l_url := icx_payment_pvt.GetServerUrl ||'?';
l_url := l_url||'OapfAction=orainv'||'&';
l_url := l_url||'OapfOrderId='||OapfOrderId||'&';

l_url := l_url||'OapfCurr='||OapfCurr||'&';
l_url := l_url||'OapfPrice='||OapfPrice||'&';
l_url := l_url||'OapfAuthType='||OapfAuthType||'&';
l_url := l_url||'OapfPmtType='||OapfPmtType||'&';
l_url := l_url||'OapfStoreId='||OapfStoreId||'&';
l_url := l_url||'OapfPayURL='||OapfPayURL||'&';
l_url := l_url||'OapfPmtReturnURL='||OapfReturnURL||'&';
l_url := l_url||'OapfFile='||OapfFile||'&';
l_url := l_url||'OapfCustName='||OapfCustName||'&';
l_url := l_url||'OapfAddr1='||OapfAddr1||'&';
l_url := l_url||'OapfAddr2='||OapfAddr2||'&';
l_url := l_url||'OapfAddr3='||OapfAddr3||'&';
l_url := l_url||'OapfCity='||OapfCity||'&';

l_url := l_url||'OapfCnty='||OapfCnty||'&';
l_url := l_url||'OapfState='||OapfState||'&';
l_url := l_url||'OapfCntry='||OapfCntry||'&';
l_url := l_url||'OapfPostalCode='||OapfPostalCode||'&';
l_url := l_url||'OapfPhone='||OapfPhone||'&';
l_url := l_url||'OapfEmail='||OapfEmail;
l_url := replace(l_url,' ','+');
if debug
then
    htp.p('DEBUG URL = '||l_url);htp.nl;
end if;
l_html := utl_http.request(l_url);
if debug

then
    htp.p('DEBUG HTML = '||l_html);
end if;
unpack_results(l_html,l_names,l_values);
OapfOrderId := '';
OapfPrice   := '';
for i in 1..l_names.COUNT loop
    if l_names(i) = 'OapfStatus'
    then
        OapfStatus := l_values(i);
    elsif l_names(i) = 'OapfOrderId'
    then
        OapfOrderId := l_values(i);

    elsif l_names(i) = 'OapfPrice'
    then
        OapfPrice := l_values(i);
    elsif l_names(i) = 'OapfErrLocation'
    then
        OapfErrLocation := l_values(i);
    elsif l_names(i) = 'OapfVendErrCode'
    then
        OapfVendErrCode := l_values(i);
    elsif l_names(i) = 'OapfVendErrmsg'
    then
        OapfVendErrmsg := l_values(i);
    end if;

end loop;
exception
        when others then
                OapfStatus := SQLERRM;
end;

procedure orapay(
                OapfPmtSvc      in      varchar2,
                OapfStatus      out     varchar2,
                OapfOrderId     out     varchar2,
                OapfCurr        out     varchar2,
                OapfPrice       out     varchar2,
                OapfAuthType    out     varchar2,
                OapfStoreId     out     varchar2,

                OapfErrLocation out     varchar2,
                OapfVendErrCode out     varchar2,
                OapfVendErrmsg  out     varchar2) is
l_url           varchar2(2000);
l_html          varchar2(2000);
l_names         v240_table;
l_values        v240_table;
debug           boolean  := FALSE;
begin
/* Open issue; does this come from FND_PROFILE or a input parameter*/
--l_url := 'http://ap571sun.us.oracle.com:9999/orapmt/OraPmt?';
l_url := icx_payment_pvt.GetServerUrl ||'?';
l_url := l_url||'OapfAction=orapay'||'&';
l_url := l_url||'OapfPmtSvc='||OapfPmtSvc;

l_url := replace(l_url,' ','+');
if debug
then
    htp.p('DEBUG URL = '||l_url);htp.nl;
end if;
l_html := utl_http.request(l_url);
if debug
then
    htp.p('DEBUG HTML = '||l_html);
end if;
unpack_results(l_html,l_names,l_values);
for i in 1..l_names.COUNT loop
    if l_names(i) = 'OapfStatus'

    then
        OapfStatus := l_values(i);
    elsif l_names(i) = 'OapfOrderId'
    then
        OapfOrderId := l_values(i);
    elsif l_names(i) = 'OapfCurr'
    then
        OapfCurr := l_values(i);
    elsif l_names(i) = 'OapfPrice'
    then
        OapfPrice := l_values(i);
    elsif l_names(i) = 'OapfAuthType'
    then

        OapfAuthType := l_values(i);
    elsif l_names(i) = 'OapfStoreId'
    then
        OapfStoreId := l_values(i);
    elsif l_names(i) = 'OapfErrLocation'
    then
        OapfErrLocation := l_values(i);
    elsif l_names(i) = 'OapfVendErrCode'
    then
        OapfVendErrCode := l_values(i);
    elsif l_names(i) = 'OapfVendErrmsg'
    then
        OapfVendErrmsg := l_values(i);

    end if;
end loop;
exception
        when others then
                OapfStatus := SQLERRM;
end;

procedure oraauth(
		OapfOrderId	in out	varchar2,
		OapfCurr	in	varchar2,
		OapfPrice	in	varchar2,
		OapfAuthType	in	varchar2,
		OapfPmtType	in	varchar2,
		OapfPmtInstrID	in	varchar2,

		OapfPmtInstrExp	in	varchar2,
		OapfStoreId	in	varchar2,
		OapfCustName	in	varchar2	default null,
		OapfAddr1	in	varchar2	default null,
		OapfAddr2	in	varchar2	default null,
		OapfAddr3	in	varchar2	default null,
		OapfCity	in	varchar2	default null,
		OapfCnty	in	varchar2	default null,
		OapfState	in	varchar2	default null,
		OapfCntry	in	varchar2	default null,
		OapfPostalCode	in	varchar2	default null,
		OapfPhone	in	varchar2	default null,
		OapfEmail	in	varchar2	default null,

		OapfStatus	out	varchar2,
		OapfTrxnType	out	varchar2,
		OapfTrxnDate	out	varchar2,
		OapfAuthcode	out	varchar2,
		OapfRefcode	out	varchar2,
		OapfAVScode	out	varchar2,
		OapfPmtInstrType out	varchar2,
		OapfErrLocation	out	varchar2,
		OapfVendErrCode	out	varchar2,
		OapfVendErrmsg	out	varchar2,
		OapfAcquirer	out	varchar2,
		OapfAuxMsg	out	varchar2) is
l_url		varchar2(2000);

l_html		varchar2(2000);
l_names		v240_table;
l_values	v240_table;
debug		boolean  := FALSE;
begin
/* Open issue; does this come from FND_PROFILE or a input parameter*/
--l_url := 'http://ap571sun.us.oracle.com:9999/orapmt/OraPmt?';
l_url := icx_payment_pvt.GetServerUrl || '?';
l_url := l_url||'OapfAction=oraauth'||'&';
l_url := l_url||'OapfOrderId='||OapfOrderId||'&';
l_url := l_url||'OapfCurr='||OapfCurr||'&';
l_url := l_url||'OapfPrice='||OapfPrice||'&';
l_url := l_url||'OapfAuthType='||OapfAuthType||'&';
l_url := l_url||'OapfPmtType='||OapfPmtType||'&';

l_url := l_url||'OapfPmtInstrID='||OapfPmtInstrID||'&';
l_url := l_url||'OapfPmtInstrExp='||OapfPmtInstrExp||'&';
l_url := l_url||'OapfStoreId='||OapfStoreId||'&';
l_url := l_url||'OapfCustName='||OapfCustName||'&';
l_url := l_url||'OapfAddr1='||OapfAddr1||'&';
l_url := l_url||'OapfAddr2='||OapfAddr2||'&';
l_url := l_url||'OapfAddr3='||OapfAddr3||'&';
l_url := l_url||'OapfCity='||OapfCity||'&';
l_url := l_url||'OapfCnty='||OapfCnty||'&';
l_url := l_url||'OapfState='||OapfState||'&';
l_url := l_url||'OapfCntry='||OapfCntry||'&';
l_url := l_url||'OapfPostalCode='||OapfPostalCode||'&';
l_url := l_url||'OapfPhone='||OapfPhone||'&';

l_url := l_url||'OapfEmail='||OapfEmail;
l_url := replace(l_url,' ','+');
if debug
then
    htp.p('DEBUG URL = '||l_url);htp.nl;
end if;
l_html := utl_http.request(l_url);
if debug
then
    htp.p('DEBUG HTML = '||l_html);
end if;
unpack_results(l_html,l_names,l_values);
OapfOrderId := '';

for i in 1..l_names.COUNT loop
    if l_names(i) = 'OapfStatus'
    then
        OapfStatus := l_values(i);
    elsif l_names(i) = 'OapfOrderId'
    then
	OapfOrderId := l_values(i);
    elsif l_names(i) = 'OapfTrxnType'
    then
        OapfTrxnType := l_values(i);
    elsif l_names(i) = 'OapfTrxnDate'
    then
        OapfTrxnDate := l_values(i);

    elsif l_names(i) = 'OapfAuthcode'
    then
        OapfAuthcode := l_values(i);
    elsif l_names(i) = 'OapfRefcode'
    then
        OapfRefcode := l_values(i);
    elsif l_names(i) = 'OapfAuthcode'
    then
        OapfAuthcode := l_values(i);
    elsif l_names(i) = 'OapfAVScode'
    then
        OapfAVScode := l_values(i);
    elsif l_names(i) = 'OapfPmtInstrType'

    then
        OapfPmtInstrType := l_values(i);
    elsif l_names(i) = 'OapfErrLocation'
    then
        OapfErrLocation := l_values(i);
    elsif l_names(i) = 'OapfVendErrCode'
    then
        OapfVendErrCode := l_values(i);
    elsif l_names(i) = 'OapfVendErrmsg'
    then
        OapfVendErrmsg := l_values(i);
    elsif l_names(i) = 'OapfAcquirer'
    then

        OapfAcquirer := l_values(i);
    elsif l_names(i) = 'OapfAuxMsg'
    then
        OapfAuxMsg := l_values(i);
    end if;
end loop;
exception
        when others then
                OapfStatus := SQLERRM;
end;

procedure oracapture(
                OapfOrderId     in      varchar2,
                OapfCurr        in      varchar2,

                OapfPrice       in      varchar2,
                OapfAuthType    in      varchar2,
                OapfPmtType     in      varchar2,
                OapfStoreId     in      varchar2,
                OapfStatus      out     varchar2,
                OapfTrxnType    out     varchar2,
                OapfTrxnDate    out     varchar2,
                OapfPmtInstrType out    varchar2,
                OapfRefcode     out     varchar2,
                OapfErrLocation out     varchar2,
                OapfVendErrCode out     varchar2,
                OapfVendErrmsg  out     varchar2) is
l_url           varchar2(2000);

l_html          varchar2(2000);
l_names         v240_table;
l_values        v240_table;
debug           boolean  := FALSE;
begin
/* Open issue; does this come from FND_PROFILE or a input parameter*/
--l_url := 'http://ap571sun.us.oracle.com:9999/orapmt/OraPmt?';
l_url := icx_payment_pvt.GetServerUrl || '?';
l_url := l_url||'OapfAction=oracapture'||'&';
l_url := l_url||'OapfOrderId='||OapfOrderId||'&';
l_url := l_url||'OapfCurr='||OapfCurr||'&';
l_url := l_url||'OapfPrice='||OapfPrice||'&';
l_url := l_url||'OapfPmtType='||OapfPmtType||'&';
l_url := l_url||'OapfStoreId='||OapfStoreId;

l_url := replace(l_url,' ','+');
if debug
then
    htp.p('DEBUG URL = '||l_url);htp.nl;
end if;
l_html := utl_http.request(l_url);
if debug
then
    htp.p('DEBUG HTML = '||l_html);
end if;
unpack_results(l_html,l_names,l_values);
for i in 1..l_names.COUNT loop
    if l_names(i) = 'OapfStatus'

    then
        OapfStatus := l_values(i);
    elsif l_names(i) = 'OapfTrxnType'
    then
        OapfTrxnType := l_values(i);
    elsif l_names(i) = 'OapfTrxnDate'
    then
        OapfTrxnDate := l_values(i);
    elsif l_names(i) = 'OapfPmtInstrType'
    then
        OapfPmtInstrType := l_values(i);
    elsif l_names(i) = 'OapfRefcode'
    then

        OapfRefcode := l_values(i);
    elsif l_names(i) = 'OapfErrLocation'
    then
        OapfErrLocation := l_values(i);
    elsif l_names(i) = 'OapfVendErrCode'
    then
        OapfVendErrCode := l_values(i);
    elsif l_names(i) = 'OapfVendErrmsg'
    then
        OapfVendErrmsg := l_values(i);
    end if;
end loop;
exception

        when others then
                OapfStatus := SQLERRM;
end;

procedure oravoid(
                OapfOrderId     in      varchar2,
                OapfTrxnType    in out  varchar2,
                OapfPmtType     in      varchar2,
                OapfStoreId     in      varchar2,
                OapfStatus      out     varchar2,
                OapfTrxnDate    out     varchar2,
                OapfPmtInstrType out    varchar2,
                OapfRefcode     out     varchar2,
                OapfErrLocation out     varchar2,

                OapfVendErrCode out     varchar2,
                OapfVendErrmsg  out     varchar2) is
l_url           varchar2(2000);
l_html          varchar2(2000);
l_names         v240_table;
l_values        v240_table;
debug           boolean  := FALSE;
begin
/* Open issue; does this come from FND_PROFILE or a input parameter*/
--l_url := 'http://ap571sun.us.oracle.com:9999/orapmt/OraPmt?';
l_url := icx_payment_pvt.GetServerUrl || '?';
l_url := l_url||'OapfAction=oravoid'||'&';
l_url := l_url||'OapfOrderId='||OapfOrderId||'&';
l_url := l_url||'OapfTrxnType='||OapfTrxnType||'&';

l_url := l_url||'OapfPmtType='||OapfPmtType||'&';
l_url := l_url||'OapfStoreId='||OapfStoreId;
l_url := replace(l_url,' ','+');
if debug
then
    htp.p('DEBUG URL = '||l_url);htp.nl;
end if;
l_html := utl_http.request(l_url);
if debug
then
    htp.p('DEBUG HTML = '||l_html);
end if;
unpack_results(l_html,l_names,l_values);

for i in 1..l_names.COUNT loop
    if l_names(i) = 'OapfStatus'
    then
        OapfStatus := l_values(i);
    elsif l_names(i) = 'OapfTrxnType'
    then
        OapfTrxnType := l_values(i);
    elsif l_names(i) = 'OapfTrxnDate'
    then
        OapfTrxnDate := l_values(i);
    elsif l_names(i) = 'OapfPmtInstrType'
    then
        OapfPmtInstrType := l_values(i);

    elsif l_names(i) = 'OapfRefcode'
    then
        OapfRefcode := l_values(i);
    elsif l_names(i) = 'OapfErrLocation'
    then
        OapfErrLocation := l_values(i);
    elsif l_names(i) = 'OapfVendErrCode'
    then
        OapfVendErrCode := l_values(i);
    elsif l_names(i) = 'OapfVendErrmsg'
    then
        OapfVendErrmsg := l_values(i);
    end if;

end loop;
exception
        when others then
                OapfStatus := SQLERRM;
end;

procedure orareturn(
                OapfOrderId     in      varchar2,
                OapfCurr        in      varchar2,
                OapfPrice       in      varchar2,
                OapfPmtType     in      varchar2,
                OapfPmtInstrID  in      varchar2,
                OapfPmtInstrExp in      varchar2,
                OapfStoreId     in      varchar2,

                OapfStatus      out     varchar2,
                OapfTrxnType    out     varchar2,
                OapfTrxnDate    out     varchar2,
                OapfPmtInstrType out    varchar2,
                OapfRefcode     out     varchar2,
                OapfErrLocation out     varchar2,
                OapfVendErrCode out     varchar2,
                OapfVendErrmsg  out     varchar2) is
l_url           varchar2(2000);
l_html          varchar2(2000);
l_names         v240_table;
l_values        v240_table;
debug           boolean  := FALSE;

begin
/* Open issue; does this come from FND_PROFILE or a input parameter*/
--l_url := 'http://ap571sun.us.oracle.com:9999/orapmt/OraPmt?';
l_url := icx_payment_pvt.GetServerUrl || '?';
l_url := l_url||'OapfAction=orareturn'||'&';
l_url := l_url||'OapfOrderId='||OapfOrderId||'&';
l_url := l_url||'OapfCurr='||OapfCurr||'&';
l_url := l_url||'OapfPrice='||OapfPrice||'&';
l_url := l_url||'OapfPmtType='||OapfPmtType||'&';
l_url := l_url||'OapfPmtInstrID='||OapfPmtInstrID||'&';
l_url := l_url||'OapfPmtInstrExp='||OapfPmtInstrExp||'&';
l_url := l_url||'OapfStoreId='||OapfStoreId;
l_url := replace(l_url,' ','+');
if debug

then
    htp.p('DEBUG URL = '||l_url);htp.nl;
end if;
l_html := utl_http.request(l_url);
if debug
then
    htp.p('DEBUG HTML = '||l_html);
end if;
unpack_results(l_html,l_names,l_values);
for i in 1..l_names.COUNT loop
    if l_names(i) = 'OapfStatus'
    then
        OapfStatus := l_values(i);

    elsif l_names(i) = 'OapfTrxnType'
    then
        OapfTrxnType := l_values(i);
    elsif l_names(i) = 'OapfTrxnDate'
    then
        OapfTrxnDate := l_values(i);
    elsif l_names(i) = 'OapfPmtInstrType'
    then
        OapfPmtInstrType := l_values(i);
    elsif l_names(i) = 'OapfRefcode'
    then
        OapfRefcode := l_values(i);
    elsif l_names(i) = 'OapfErrLocation'

    then
        OapfErrLocation := l_values(i);
    elsif l_names(i) = 'OapfVendErrCode'
    then
        OapfVendErrCode := l_values(i);
    elsif l_names(i) = 'OapfVendErrmsg'
    then
        OapfVendErrmsg := l_values(i);
    end if;
end loop;
exception
        when others then
                OapfStatus := SQLERRM;

end;

procedure oraclosebatch(
                OapfPmtType     in      varchar2,
                OapfMerchBatchID in out varchar2,
                OapfStoreID     in out  varchar2,
                OapfStatus      out     varchar2,
                OapfBatchState  out     varchar2,
                OapfBatchDate   out     varchar2,
                OapfCreditAmount out    varchar2,
                OapfSalesAmount out     varchar2,
                OapfCurr        out     varchar2,
                OapfBatchTotal  out     varchar2,
                OapfNumTrxns    out     varchar2,

                OapfVpsbatchID  out     varchar2,
                OapfGWsbatchID  out     varchar2,
                OapfErrLocation out     varchar2,
                OapfVendErrCode out     varchar2,
                OapfVendErrmsg  out     varchar2) is
l_url           varchar2(2000);
l_html          varchar2(2000);
l_names         v240_table;
l_values        v240_table;
debug           boolean  := FALSE;
begin
/* Open issue; does this come from FND_PROFILE or a input parameter*/
--l_url := 'http://ap571sun.us.oracle.com:9999/orapmt/OraPmt?';
l_url := icx_payment_pvt.GetServerUrl || '?';

l_url := l_url||'OapfAction=oraclosebatch'||'&';
l_url := l_url||'OapfPmtType='||OapfPmtType||'&';
l_url := l_url||'OapfMerchBatchID='||OapfMerchBatchID||'&';
l_url := l_url||'OapfStoreId='||OapfStoreId;
l_url := replace(l_url,' ','+');
if debug
then
    htp.p('DEBUG URL = '||l_url);htp.nl;
end if;
l_html := utl_http.request(l_url);
if debug
then
    htp.p('DEBUG HTML = '||l_html);

end if;
unpack_results(l_html,l_names,l_values);
OapfMerchBatchID := '';
OapfStoreID := '';
for i in 1..l_names.COUNT loop
    if l_names(i) = 'OapfStatus'
    then
        OapfStatus := l_values(i);
    elsif l_names(i) = 'OapfMerchBatchID'
    then
        OapfMerchBatchID := l_values(i);
    elsif l_names(i) = 'OapfStoreID'
    then

        OapfStoreID := l_values(i);
    elsif l_names(i) = 'OapfBatchState'
    then
        OapfBatchState := l_values(i);
    elsif l_names(i) = 'OapfBatchDate'
    then
        OapfBatchDate := l_values(i);
    elsif l_names(i) = 'OapfCreditAmount'
    then
        OapfCreditAmount := l_values(i);
    elsif l_names(i) = 'OapfSalesAmount'
    then
        OapfSalesAmount := l_values(i);

    elsif l_names(i) = 'OapfCurr'
    then
        OapfCurr := l_values(i);
    elsif l_names(i) = 'OapfBatchTotal'
    then
        OapfBatchTotal := l_values(i);
    elsif l_names(i) = 'OapfNumTrxns'
    then
        OapfNumTrxns := l_values(i);
    elsif l_names(i) = 'OapfVpsbatchID'
    then
        OapfVpsbatchID := l_values(i);
    elsif l_names(i) = 'OapfGWsbatchID'

    then
        OapfGWsbatchID := l_values(i);
    elsif l_names(i) = 'OapfErrLocation'
    then
        OapfErrLocation := l_values(i);
    elsif l_names(i) = 'OapfVendErrCode'
    then
        OapfVendErrCode := l_values(i);
    elsif l_names(i) = 'OapfVendErrmsg'
    then
        OapfVendErrmsg := l_values(i);
    end if;
end loop;

exception
        when others then
                OapfStatus := SQLERRM;
end;

procedure oraqrytxstatus(
                OapfOrderId     in      varchar2,
                OapfPmtType     in      varchar2,
                OapfStoreID     in      varchar2) is
l_url           varchar2(2000);
l_html          varchar2(2000);
l_names         v240_table;
l_values        v240_table;
debug           boolean  := FALSE;

begin
/* Open issue; does this come from FND_PROFILE or a input parameter*/
--l_url := 'http://ap571sun.us.oracle.com:9999/orapmt/OraPmt?';
l_url := icx_payment_pvt.GetServerUrl || '?';
l_url := l_url||'OapfAction=oraqrytxstatus'||'&';
l_url := l_url||'OapfOrderId='||OapfOrderId||'&';
l_url := l_url||'OapfPmtType='||OapfPmtType||'&';
l_url := l_url||'OapfStoreId='||OapfStoreId;
l_url := replace(l_url,' ','+');
if debug
then
    htp.p('DEBUG URL = '||l_url);htp.nl;
end if;
l_html := utl_http.request(l_url);

htp.p('oraqrytxstatus');htp.nl;
htp.p(l_html);
end;

END ICX_PAYMENT_PVT;

/
