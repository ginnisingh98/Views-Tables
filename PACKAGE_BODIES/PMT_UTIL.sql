--------------------------------------------------------
--  DDL for Package Body PMT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PMT_UTIL" as
/* $Header: ARPSUTLB.pls 120.8 2005/10/30 03:56:23 appldev ship $*/

type v240_table is table of varchar2(240)
	index by binary_integer;

outnames 	 v240_table;
outvalues	 v240_table;


/*
-------------------------------unpack_results--------------------------------
Given l_string which is a html file format, parse l_string and store the name
value pairs in l_names and l_values. For example, if OapfPrice name-value pairs
exist in l_string, it would be stored as l_names(i) := 'OapfPrice' and
l_values(i) := '17.00'.
*/
procedure unpack_results(l_string in  varchar2,
                         l_names  out NOCOPY v240_table,
			 l_values out NOCOPY v240_table) is

l_length        number(15)	:= length(l_string) + 1;
l_count         number(15);
l_index         number(15)	:= 1;
l_char          varchar(1)	:= '';
l_word          varchar(240)	:= '';
l_name		boolean		:= TRUE;
debug		boolean		:= FALSE;

begin

-- just to see what is returned by the server
l_count := instr(l_string,'</H2>');
if l_count > 0
then
    l_count := l_count +5;
end if;


while l_count < l_length loop
	if l_name and substr(l_string,l_count,1) = ':'
	then
		l_names(l_index) := ltrim(rtrim(l_word));
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
                HTP.print(SQLERRM);
end;


/*
-----------------------------------oraauth----------------------------------
*/
procedure oraauth(
		baseurl in varchar2,
		inparam in in_oraauth,
		outparam out NOCOPY out_oraauth) is

l_url		varchar2(2000);
l_html		varchar2(7000);
l_names		v240_table;
l_values	v240_table;
debug		boolean  := FALSE;

begin

/*
Construct a basic URL.
*/
l_url := baseurl;
l_url := l_url||'OapfAction=oraauth'||'&';

/*
If SET extended feature is used, add those extended name-value pairs to URL.
*/
if inparam.OapfAPIScheme = 'ExtendedSET' then
	l_url := l_url||'OapfAPIScheme='||inparam.OapfAPIScheme||'&';
	l_url := l_url||'OapfTerminalId='||inparam.OapfTerminalId||'&';
	l_url := l_url||'OapfMerchBatchId='||inparam.OapfMerchBatchId||'&';
	l_url := l_url||'OapfBatchSequenceNum='||inparam.OapfBatchSequenceNum||'&';
	l_url := l_url||'OapfSplitShipment='||inparam.OapfSplitShipment||'&';
	l_url := l_url||'OapfAuthCurr='||inparam.OapfAuthCurr||'&';
	l_url := l_url||'OapfAuthPrice='||inparam.OapfAuthPrice||'&';
	l_url := l_url||'OapfInstallTotalTrans='||inparam.OapfInstallTotalTrans||'&';
	l_url := l_url||'OapfRecurringFreq='||inparam.OapfRecurringFreq||'&';
	l_url := l_url||'OapfRecurringExpiryDate='||inparam.OapfRecurringExpiryDate||'&';
	l_url := l_url||'OapfCustomerReferenceNumber='||inparam.OapfCustomerReferenceNumber||'&';
	l_url := l_url||'OapfDestinationPostalCode='||inparam.OapfDestinationPostalCode||'&';
	l_url := l_url||'OapfLocalTaxPrice='||inparam.OapfLocalTaxPrice||'&';
	l_url := l_url||'OapfLocalTaxCurr='||inparam.OapfLocalTaxCurr||'&';
end if;
l_url := l_url||'OapfOrderId='||inparam.OapfOrderId||'&';
l_url := l_url||'OapfCurr='||inparam.OapfCurr||'&';
l_url := l_url||'OapfPrice='||inparam.OapfPrice||'&';
l_url := l_url||'OapfAuthType='||inparam.OapfAuthType||'&';
l_url := l_url||'OapfPmtType='||inparam.OapfPmtType||'&';
l_url := l_url||'OapfPmtInstrID='||inparam.OapfPmtInstrID||'&';
l_url := l_url||'OapfPmtInstrExp='||inparam.OapfPmtInstrExp||'&';
l_url := l_url||'OapfStoreId='||inparam.OapfStoreId || '&';
l_url := l_url||'OapfCustName='||inparam.OapfCustName||'&';
l_url := l_url||'OapfAddr1='||inparam.OapfAddr1||'&';
l_url := l_url||'OapfAddr2='||inparam.OapfAddr2||'&';
l_url := l_url||'OapfAddr3='||inparam.OapfAddr3||'&';
l_url := l_url||'OapfCity='||inparam.OapfCity||'&';
l_url := l_url||'OapfCnty='||inparam.OapfCnty||'&';
l_url := l_url||'OapfState='||inparam.OapfState||'&';
l_url := l_url||'OapfCntry='||inparam.OapfCntry||'&';
l_url := l_url||'OapfPostalCode='||inparam.OapfPostalCode||'&';
l_url := l_url||'OapfPhone='||inparam.OapfPhone||'&';
l_url := l_url||'OapfNlsLang='||inparam.OapfnlsLang||'&';
l_url := l_url||'OapfEmail='||inparam.OapfEmail||'&';
l_url := l_url||'OapfRefNumber='||inparam.OapfRefNumber||'&';
l_url := l_url||'OapfTrxnRef='||inparam.OapfTrxnRef;

/*
Repliace blank characters with + sign.
*/
l_url := replace(l_url,' ','+');

if debug then
	htp.print(l_url);
end if;

/*
Send http request to the payment server.
*/
l_html := utl_http.request(l_url);
if debug then
	htp.print(l_html);
end if;


/*
Unpack the results
*/
unpack_results(l_html,l_names,l_values);


/*
Retrieve name-value pairs stored in l_names and l_values, and assign
them to the output variable called outparam.
*/
for i in 1..l_names.COUNT loop

    if l_names(i) = 'OapfStatus'
    then
        outparam.OapfStatus := l_values(i);
    elsif l_names(i) = 'OapfStatusMsg'
    then
        outparam.OapfStatusMsg := l_values(i);
    elsif l_names(i) = 'OapfOrderId'
    then
	outparam.OapfOrderId := l_values(i);
    elsif l_names(i) = 'OapfTrxnType'
    then
        outparam.OapfTrxnType := l_values(i);
    elsif l_names(i) = 'OapfTrxnDate'
    then
        outparam.OapfTrxnDate := l_values(i);
    elsif l_names(i) = 'OapfApprovalCode'
    then
        outparam.OapfApprovalCode := l_values(i);
    elsif l_names(i) = 'OapfRefcode'
    then
        outparam.OapfRefcode := l_values(i);
    elsif l_names(i) = 'OapfAVScode'
    then
        outparam.OapfAVScode := l_values(i);
    elsif l_names(i) = 'OapfPmtInstrType'
    then
        outparam.OapfPmtInstrType := l_values(i);
    elsif l_names(i) = 'OapfErrLocation'
    then
        outparam.OapfErrLocation := l_values(i);
    elsif l_names(i) = 'OapfVendErrCode'
    then
        outparam.OapfVendErrCode := l_values(i);
    elsif l_names(i) = 'OapfVendErrmsg'
    then
        outparam.OapfVendErrmsg := l_values(i);
    elsif l_names(i) = 'OapfAcquirer'
    then
        outparam.OapfAcquirer := l_values(i);
    elsif l_names(i) = 'OapfAuxMsg'
    then
        outparam.OapfAuxMsg := l_values(i);
/*
SET extended oraauth output .
*/
    elsif l_names(i) = 'OapfSplitId'
    then
        outparam.OapfSplitId := l_values(i);
    elsif l_names(i) = 'OapfMerchBatchId'
    then
        outparam.OapfMerchBatchId := l_values(i);
    elsif l_names(i) = 'OapfCapCode'
    then
        outparam.OapfCapCode := l_values(i);
    elsif l_names(i) = 'OapfCardCurr'
    then
        outparam.OapfCardCurr := l_values(i);
    elsif l_names(i) = 'OapfCurrConvRate'
    then
        outparam.OapfCurrConvRate := l_values(i);
    elsif l_names(i) = 'OapfTerminalId'
    then
        outparam.OapfTerminalId := l_values(i);
    end if;

end loop;


/*
If any exception takes place, print out NOCOPY SQLERRM in html page.
*/
exception
        when others then
                htp.print(SQLERRM);
end;

/*************************orasubsequentauth******************************/
procedure orasubsequentauth(
		baseurl in varchar2,
		inparam in in_orasubsequentauth,
		outparam out NOCOPY out_orasubsequentauth) is
l_url	varchar2(2000);
l_html	varchar2(2000);
l_names	v240_table;
l_values  v240_table;
debug	 boolean:= FALSE;
begin
/*
Construct a request URL string.
*/
l_url := baseurl;
l_url := l_url||'OapfAction='||inparam.OapfAction||'&';
l_url := l_url||'OapfAPIScheme='||inparam.OapfAPIScheme||'&';
l_url := l_url||'OapfOrderId='||inparam.OapfOrderId||'&';
l_url := l_url||'OapfStoreId='||inparam.OapfStoreId||'&';
l_url := l_url||'OapfPrevSplitId='||inparam.OapfPrevSplitId||'&';
l_url := l_url||'OapfSplitId='||inparam.OapfSplitId||'&';
l_url := l_url||'OapfCurr='||inparam.OapfCurr||'&';
l_url := l_url||'OapfPrice='||inparam.OapfPrice||'&';
l_url := l_url||'OapfAuthType='||inparam.OapfAuthType||'&';
l_url := l_url||'OapfPmtType='||inparam.OapfPmtType||'&';
l_url := l_url||'OapfSubsequentAuthInd='||inparam.OapfSubsequentAuthInd||'&';
l_url := l_url||'OapfNlsLang='||inparam.OapfNlsLang;
l_url := replace(l_url, ' ', '+');
if (debug) then
	htp.print(l_url);
end if;

/*
Send HTTP request.
*/
l_html := utl_http.request(l_url);
if (debug) then
	htp.print(l_html);
end if;

/*
Parse the returning HTML file.
*/
unpack_results(l_html, l_names, l_values);
for i in 1..l_names.COUNT LOOP
	if l_names(i) = 'OapfOrderId' then
		outparam.OapfOrderId := l_values(i);
	elsif l_names(i) = 'OapfSplitId' then
		outparam.OapfSplitId := l_values(i);
	elsif l_names(i) = 'OapfNlsLang' then
		outparam.OapfNlsLang := l_values(i);
	elsif l_names(i) = 'OapfTrxnType' then
		outparam.OapfTrxnType := l_values(i);
	elsif l_names(i) = 'OapfStatus' then
		outparam.OapfStatus := l_values(i);
	elsif l_names(i) = 'OapfAuthcode' then
		outparam.OapfAuthcode := l_values(i);
	elsif l_names(i) = 'OapfRefcode' then
		outparam.OapfRefcode := l_values(i);
	elsif l_names(i) = 'OapfAVScode' then
		outparam.OapfAVScode := l_values(i);
	elsif l_names(i) = 'OapfTrxnDate' then
		outparam.OapfTrxnDate := l_values(i);
	elsif l_names(i) = 'OapfPmtInstrType' then
		outparam.OapfPmtInstrType := l_values(i);
	elsif l_names(i) = 'OapfErrLocation' then
		outparam.OapfErrLocation := l_values(i);
	elsif l_names(i) = 'OapfVendErrCode' then
		outparam.OapfVendErrCode := l_values(i);
	elsif l_names(i) = 'OapfVendErrmsg' then
		outparam.OapfVendErrmsg := l_values(i);
	elsif l_names(i) = 'OapfAcquirer' then
		outparam.OapfAcquirer := l_values(i);
	elsif l_names(i) = 'OapfMerchBatchId' then
		outparam.OapfMerchBatchId := l_values(i);
	elsif l_names(i) = 'OapfVpsBatchId' then
		outparam.OapfVpsBatchId := l_values(i);
	elsif l_names(i) = 'OapfAuxMsg' then
		outparam.OapfAuxMsg := l_values(i);
	elsif l_names(i) = 'OapfCapCode' then
		outparam.OapfCapCode := l_values(i);
	end if;
end LOOP;
exception
	when others then
		htp.print(SQLERRM);

end;

/*************************oracapture************************************/
procedure oracapture(
                baseurl in varchar2,
                inparam in in_oracapture,
                outparam out NOCOPY out_oracapture) is

l_url           varchar2(2000);
l_html          varchar2(7000);
l_names         v240_table;
l_values        v240_table;
debug           boolean  := FALSE;

begin

/*
Construct a request URL string.
*/
l_url := baseurl;
l_url := l_url||'OapfAction='|| inparam.OapfAction ||'&';
l_url := l_url||'OapfOrderId='||inparam.OapfOrderId||'&';
l_url := l_url||'OapfPrice='||inparam.OapfPrice||'&';
l_url := l_url||'OapfCurr='||inparam.OapfCurr||'&';
l_url := l_url||'OapfPmtType='||inparam.OapfPmtType||'&';
l_url := l_url||'OapfStoreId='||inparam.OapfStoreId||'&';
l_url := l_url||'OapfTrxnRef='||inparam.OapfTrxnRef;
l_url := replace(l_url,' ','+');


/*
Send HTTP request to payment server
*/
l_html := utl_http.request(l_url);


/*
Parse the resulting HTML page.
*/
unpack_results(l_html,l_names,l_values);

/*
Assign output name-value pairs to outparam.
*/
for i in 1..l_names.COUNT loop

    if l_names(i) = 'OapfStatus'
    then
        outparam.OapfStatus := l_values(i);
    elsif l_names(i) = 'OapfTrxnType'
    then
        outparam.OapfTrxnType := l_values(i);
    elsif l_names(i) = 'OapfTrxnDate'
    then
        outparam.OapfTrxnDate := l_values(i);
    elsif l_names(i) = 'OapfPmtInstrType'
    then
        outparam.OapfPmtInstrType := l_values(i);
    elsif l_names(i) = 'OapfRefcode'
    then
	outparam.OapfRefcode := l_values(i);
    elsif l_names(i) = 'OapfErrLocation'
    then
        outparam.OapfErrLocation := l_values(i);
    elsif l_names(i) = 'OapfVendErrCode'
    then
        outparam.OapfVendErrCode := l_values(i);
    elsif l_names(i) = 'OapfVendErrmsg'
    then
        outparam.OapfVendErrmsg := l_values(i);
    end if;

end loop;


exception
        when others then
                htp.print(SQLERRM);
end;

/***************oracapture for SET***********************************/
procedure oracapture(
                baseurl in varchar2,
                inparam in SETIN_oracapture,
                summary out NOCOPY SETsummary_oracapture,
                reportlst out NOCOPY SETreportlst_oracapture) is
l_url           varchar2(2000);
l_html          varchar2(7000);
l_names         v240_table;
l_values        v240_table;
l_index         number;
debug           boolean := FALSE;

begin
/*
Construct a request URL string.
*/
l_url := baseurl;
l_url := l_url || 'OapfAction='||inparam.OapfAction||'&';
l_url := l_url || 'OapfPmtType='||inparam.OapfPmtType||'&';
l_url := l_url || 'OapfStoreId='||inparam.OapfStoreId||'&';
l_url := l_url || 'OapfNlsLang='||inparam.OapfNlsLang||'&';
l_url := l_url || 'OapfAPIScheme='||inparam.OapfAPIScheme||'&';
l_url := l_url || 'OapfNumTrxns='||inparam.OapfNumTrxns||'&';
for i in 1..inparam.OapfOrderId.COUNT loop
        l_url :=
l_url||'OapfOrderId-'||TO_CHAR(i-1)||'='||inparam.OapfOrderId(i)||'&';
end loop;
for i in 1..inparam.OapfSplitId.COUNT loop
        l_url :=
l_url||'OapfSplitId-'||TO_CHAR(i-1)||'='||inparam.OapfSplitId(i)||'&';
end loop;
for i in 1..inparam.OapfPrice.COUNT loop
        l_url :=
l_url||'OapfPrice-'||TO_CHAR(i-1)||'='||inparam.OapfPrice(i)||'&';
end loop;
for i in 1..inparam.OapfCurr.COUNT loop
        l_url :=
l_url||'OapfCurr-'||TO_CHAR(i-1)||'='||inparam.OapfCurr(i)||'&';
end loop;
for i in 1..inparam.OapfTerminalId.COUNT loop
        l_url :=
l_url||'OapfTerminalId-'||TO_CHAR(i-1)||'='||inparam.OapfTerminalId(i)||'&';
end loop;
for i in 1..inparam.OapfMerchBatchId.COUNT loop
        l_url :=
l_url||'OapfMerchBatchId-'||TO_CHAR(i-1)||'='||inparam.OapfMerchBatchId(i)||'&';
end loop;
for i in 1..inparam.OapfBatchSequenceNum.COUNT loop
        l_url :=
l_url||'OapfBatchSequenceNum-'||TO_CHAR(i-1)||'='||inparam.OapfBatchSequenceNum(i)||'&';
end loop;
l_url := replace(l_url, ' ', '+');
if debug then
        htp.print(l_url);
end if;
l_html := utl_http.request(l_url);
if debug then
        htp.print(l_html);
end if;
unpack_results(l_html, l_names, l_values);
for i in 1..l_names.COUNT loop
        if l_names(i)='OapfStatus' then
                summary.OapfStatus := l_values(i);
/* elsif l_names(i) = 'OapfStatusMsg' then
                summary.OapfStatusMsg := l_values(i); */
        elsif l_names(i)='OapfTrxnType' then
                summary.OapfTrxnType := l_values(i);
        elsif l_names(i)='OapfTrxnDate' then
                summary.OapfTrxnDate := l_values(i);
        elsif l_names(i)='OapfPmtInstrType' then
                summary.OapfPmtInstrType := l_values(i);
        elsif l_names(i)='OapfRefcode' then
                summary.OapfRefcode := l_values(i);
        elsif l_names(i)='OapfErrLocation' then
                summary.OapfErrLocation := l_values(i);
        elsif l_names(i)='OapfVendErrCode' then
                summary.OapfVendErrCode := l_values(i);
        elsif l_names(i)='OapfVendErrmsg' then
                summary.OapfVendErrmsg := l_values(i);
        elsif l_names(i)='OapfNumTrxns' then
                summary.OapfNumTrxns := TO_NUMBER(l_values(i));
        elsif INSTR(l_names(i), 'OapfStatus-') <>0 then
                l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfStatus-'));
                reportlst(l_index).OapfStatus := l_values(i);
/*      elsif INSTR(l_names(i), 'OapfStatusMsg-') <>0 then
                l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfStatusMsg-'));
                reportlst(l_index).OapfStatusMsg := l_values(i); */
        elsif INSTR(l_names(i), 'OapfOrderId-') <>0 then
                l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfOrderId-'));
                reportlst(l_index).OapfOrderId := l_values(i);
        elsif INSTR(l_names(i), 'OapfSplitId-') <>0 then
                l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfSplitId-'));
                reportlst(l_index).OapfSplitId := l_values(i);
        elsif INSTR(l_names(i), 'OapfCurr-') <>0 then
                l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfCurr-'));
                reportlst(l_index).OapfCurr := l_values(i);
        elsif INSTR(l_names(i), 'OapfPrice-') <>0 then
                l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfPrice-'));
                reportlst(l_index).OapfPrice := l_values(i);
        elsif INSTR(l_names(i), 'OapfTerminalId-') <>0 then
                l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfTerminalId-'));
                reportlst(l_index).OapfTerminalId := l_values(i);
        elsif INSTR(l_names(i), 'OapfPmtInstrType-') <>0 then
                l_index := TO_NUMBER(LTRIM(l_names(i),
'OapfPmtInstrType-'));
                reportlst(l_index).OapfPmtInstrType := l_values(i);
        elsif INSTR(l_names(i), 'OapfRefcode-') <>0 then
                l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfRefcode-'));
                reportlst(l_index).OapfRefcode := l_values(i);
        elsif INSTR(l_names(i), 'OapfMerchBatchId-') <>0 then
                l_index := TO_NUMBER(LTRIM(l_names(i),
'OapfMerchBatchId-'));
                reportlst(l_index).OapfMerchBatchId := l_values(i);
        elsif INSTR(l_names(i), 'OapfBatchSequenceNum-') <>0 then
                l_index := TO_NUMBER(LTRIM(l_names(i),
'OapfBatchSequenceNum-'));
                reportlst(l_index).OapfBatchSequenceNum := l_values(i);
        end if;
end loop;
exception
        when others then
                htp.print(SQLERRM);
end;

/********************oravoid*************************************************/
procedure oravoid(
                baseurl in varchar2,
                inparam in in_oravoid,
                outparam out NOCOPY out_oravoid) is

l_url           varchar2(2000);
l_html          varchar2(7000);
l_names         v240_table;
l_values        v240_table;
debug           boolean  := FALSE;

begin

/*
Construct HTTP request URL string.
*/
l_url := baseurl;
l_url := l_url||'OapfAction='|| inparam.OapfAction ||'&';
l_url := l_url||'OapfTrxnType='||inparam.OapfTrxnType||'&';
l_url := l_url||'OapfPmtType='||inparam.OapfPmtType||'&';
l_url := l_url||'OapfOrderId='||inparam.OapfOrderId||'&';
l_url := l_url||'OapfStoreId='||inparam.OapfStoreId ;
l_url := replace(l_url,' ','+');


/*
Send HTTP request to payment server.
*/
l_html := utl_http.request(l_url);

if (debug) then
	htp.print(l_html);
end if;

/*
Parse the resulting HTML file to name-value pairs tables.
*/
unpack_results(l_html,l_names,l_values);

/*
Loop through table and assign the name-value pairs to outparam.
*/
for i in 1..l_names.COUNT loop

    if l_names(i) = 'OapfStatus'
    then
        outparam.OapfStatus := l_values(i);
    elsif l_names(i) = 'OapfTrxnType'
    then
        outparam.OapfTrxnType := l_values(i);
    elsif l_names(i) = 'OapfTrxnDate'
    then
        outparam.OapfTrxnDate := l_values(i);
    elsif l_names(i) = 'OapfPmtInstrType'
    then
        outparam.OapfPmtInstrType := l_values(i);
    elsif l_names(i) = 'OapfRefcode'
    then
        outparam.OapfRefcode := l_values(i);
    elsif l_names(i) = 'OapfErrLocation'
    then
        outparam.OapfErrLocation := l_values(i);
    elsif l_names(i) = 'OapfVendErrCode'
    then
        outparam.OapfVendErrCode := l_values(i);
    elsif l_names(i) = 'OapfVendErrmsg'
    then
        outparam.OapfVendErrmsg := l_values(i);
    end if;

end loop;


exception
        when others then
                htp.print(SQLERRM);
end;

/************************oravoid for SET*************************************/
procedure oravoid(
                baseurl in varchar2,
                inparam in SETIN_oravoid,
                summary out NOCOPY SETsummary_oravoid,
                reportlst out NOCOPY SETreportlst_oravoid) is
l_url           varchar2(2000);
l_html          varchar2(7000);
l_names         v240_table;
l_values        v240_table;
l_index         number;
debug           boolean := FALSE;

begin
/*
Construct a request URL string.
*/
l_url := baseurl;
l_url := l_url || 'OapfAction='||inparam.OapfAction||'&';
l_url := l_url || 'OapfTrxnType='||inparam.OapfTrxnType||'&';
l_url := l_url || 'OapfPmtType='||inparam.OapfPmtType||'&';
l_url := l_url || 'OapfNlsLang='||inparam.OapfNlsLang||'&';
l_url := l_url || 'OapfAPIScheme='||inparam.OapfAPIScheme||'&';
l_url := l_url || 'OapfNumTrxns='||inparam.OapfNumTrxns||'&';
l_url := l_url || 'OapfStoreId='||inparam.OapfStoreId||'&';
for i in 1..inparam.OapfOrderId.COUNT loop
        l_url := l_url||'OapfOrderId-'||TO_CHAR(i)||'='||inparam.OapfOrderId(i)||'&';
end loop;
for i in 1..inparam.OapfSplitId.COUNT loop
        l_url := l_url||'OapfSplitId-'||TO_CHAR(i)||'='||inparam.OapfSplitId(i)||'&';
end loop;
for i in 1..inparam.OapfPrice.COUNT loop
        l_url := l_url||'OapfPrice-'||TO_CHAR(i)||'='||inparam.OapfPrice(i)||'&';
end loop;
for i in 1..inparam.OapfCurr.COUNT loop
        l_url := l_url||'OapfCurr-'||TO_CHAR(i)||'='||inparam.OapfCurr(i)||'&';
end loop;
for i in 1..inparam.OapfTerminalId.COUNT loop
        l_url := l_url||'OapfTerminalId-'||TO_CHAR(i)||'='||inparam.OapfTerminalId(i)||'&';
end loop;
for i in 1..inparam.OapfMerchBatchId.COUNT loop
        l_url := l_url||'OapfMerchBatchId-'||TO_CHAR(i)||'='||inparam.OapfMerchBatchId(i)||'&';
end loop;
for i in 1..inparam.OapfBatchSequenceNum.COUNT loop
        l_url := l_url||'OapfBatchSequenceNum-'||TO_CHAR(i)||'='||inparam.OapfBatchSequenceNum(i)||'&';
end loop;
l_url := replace(l_url, ' ', '+');
if debug then
	htp.print(l_url);
end if;
l_html:=utl_http.request(l_url);
if debug then
	htp.print(l_html);
end if;
unpack_results(l_html, l_names, l_values);
for i in 1..l_names.COUNT loop
        if l_names(i)='OapfStatus' then
                summary.OapfStatus := l_values(i);
        elsif l_names(i)='OapfTrxnType' then
                summary.OapfTrxnType := l_values(i);
        elsif l_names(i)='OapfTrxnDate' then
                summary.OapfTrxnDate := l_values(i);
        elsif l_names(i)='OapfPmtInstrType' then
                summary.OapfPmtInstrType := l_values(i);
        elsif l_names(i)='OapfRefcode' then
                summary.OapfRefcode := l_values(i);
        elsif l_names(i)='OapfErrLocation' then
                summary.OapfErrLocation := l_values(i);
        elsif l_names(i)='OapfVendErrCode' then
                summary.OapfVendErrCode := l_values(i);
        elsif l_names(i)='OapfVendErrmsg' then
                summary.OapfVendErrmsg := l_values(i);
        elsif l_names(i)='OapfNumTrxns' then
                summary.OapfNumTrxns := TO_NUMBER(l_values(i));
       elsif INSTR(l_names(i), 'OapfStatus-') <>0 then
                l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfStatus-'));
                reportlst(l_index).OapfStatus := l_values(i);
       elsif INSTR(l_names(i), 'OapfOrderId-') <>0 then
                l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfOrderId-'));
                reportlst(l_index).OapfOrderId := l_values(i);
       elsif INSTR(l_names(i), 'OapfSplitId-') <>0 then
                l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfSplitId-'));
                reportlst(l_index).OapfSplitId := l_values(i);
        elsif INSTR(l_names(i), 'OapfCapRevOrCreditCode-') <>0 then
                l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfCapRevOrCreditCode-'));
                reportlst(l_index).OapfCapRevOrCreditCode := l_values(i);
        elsif INSTR(l_names(i), 'OapfTerminalId-') <>0 then
                l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfTerminalId-'));
                reportlst(l_index).OapfTerminalId := l_values(i);
        elsif INSTR(l_names(i), 'OapfMerchBatchId-') <>0 then
                l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfMerchBatchId-'));
                reportlst(l_index).OapfMerchBatchId := l_values(i);
        elsif INSTR(l_names(i), 'OapfBatchSequenceNum-') <>0 then
                l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfBatchSequenceNum-'));
                reportlst(l_index).OapfBatchSequenceNum := l_values(i);
        end if;
end loop;
exception
        when others then
                htp.print(SQLERRM);
end;




/*********************orareturn**********************************************/
procedure orareturn(
                baseurl in varchar2,
                inparam in in_orareturn,
                outparam out NOCOPY out_orareturn) is

l_url           varchar2(2000);
l_html          varchar2(7000);
l_names         v240_table;
l_values        v240_table;
debug           boolean  := FALSE;

begin

/*
Construct URL string.
*/
l_url := baseurl;
l_url := l_url||'OapfAction='|| inparam.OapfAction ||'&';
l_url := l_url||'OapfOrderId='||inparam.OapfOrderId||'&';
l_url := l_url||'OapfPrice='||inparam.OapfPrice||'&';
l_url := l_url||'OapfCurr='||inparam.OapfCurr||'&';
l_url := l_url||'OapfStoreId='||inparam.OapfStoreId || '&';
l_url := l_url||'OapfPmtType='||inparam.OapfPmtType || '&';
l_url := l_url||'OapfPmtInstrID='||inparam.OapfPmtInstrID || '&';
l_url := l_url||'OapfMerchUsername='||inparam.OapfMerchUsername || '&';
l_url := l_url||'OapfMerchPasswd='||inparam.OapfMerchPasswd || '&';
l_url := l_url||'OapfPmtInstrExp='||inparam.OapfPmtInstrExp ;
l_url := replace(l_url,' ','+');


/*
Send HTTP request URL to payment server.
*/
l_html := utl_http.request(l_url);


/*
Parse resulting HTML page to name-value pair table.
*/
unpack_results(l_html,l_names,l_values);

/*
Assign name-value pair to output variable outparam.
*/
for i in 1..l_names.COUNT loop

    if l_names(i) = 'OapfStatus'
    then
        outparam.OapfStatus := l_values(i);
    elsif l_names(i) = 'OapfTrxnType'
    then
        outparam.OapfTrxnType := l_values(i);
    elsif l_names(i) = 'OapfTrxnDate'
    then
        outparam.OapfTrxnDate := l_values(i);
    elsif l_names(i) = 'OapfPmtInstrType'
    then
        outparam.OapfPmtInstrType := l_values(i);
    elsif l_names(i) = 'OapfRefcode'
    then
        outparam.OapfRefcode := l_values(i);
    elsif l_names(i) = 'OapfErrLocation'
    then
        outparam.OapfErrLocation := l_values(i);
    elsif l_names(i) = 'OapfVendErrCode'
    then
        outparam.OapfVendErrCode := l_values(i);
    elsif l_names(i) = 'OapfVendErrmsg'
    then
        outparam.OapfVendErrmsg := l_values(i);
    end if;

end loop;


exception
        when others then
                htp.print(SQLERRM);
end;

/****************************orareturn for SET******************************/
procedure orareturn(
                baseurl in varchar2,
                inparam in SETIN_orareturn,
                summary out NOCOPY SETsummary_orareturn,
                reportlst out NOCOPY SETreportlst_orareturn) is
l_url           varchar2(2000);
l_html          varchar2(7000);
l_names         v240_table;
l_values        v240_table;
l_index         number;
debug           boolean := FALSE;

begin
/*
Construct a request URL string.
*/
l_url := baseurl;
l_url := l_url || 'OapfAction='||inparam.OapfAction||'&';
l_url := l_url || 'OapfStoreId='||inparam.OapfStoreId||'&';
l_url := l_url || 'OapfPmtType='||inparam.OapfPmtType||'&';
l_url := l_url || 'OapfNlsLang='||inparam.OapfNlsLang||'&';
l_url := l_url || 'OapfAPIScheme='||inparam.OapfAPIScheme||'&';
l_url := l_url || 'OapfNumTrxns='||inparam.OapfNumTrxns||'&';
for i in 1..inparam.OapfOrderId.COUNT loop
        l_url := l_url||'OapfOrderId-'||TO_CHAR(i)||'='||inparam.OapfOrderId(i)||'&';
end loop;
for i in 1..inparam.OapfSplitId.COUNT loop
        l_url := l_url||'OapfSplitId-'||TO_CHAR(i)||'='||inparam.OapfSplitId(i)||'&';
end loop;
for i in 1..inparam.OapfCreditCounter.COUNT loop
        l_url := l_url||'OapfCreditCounter-'||TO_CHAR(i)||'='||inparam.OapfCreditCounter(i)||'&';
end loop;
for i in 1..inparam.OapfPrice.COUNT loop
        l_url := l_url||'OapfPrice-'||TO_CHAR(i)||'='||inparam.OapfPrice(i)||'&';
end loop;
for i in 1..inparam.OapfCurr.COUNT loop
        l_url := l_url||'OapfCurr-'||TO_CHAR(i)||'='||inparam.OapfCurr(i)||'&';
end loop;
for i in 1..inparam.OapfTerminalId.COUNT loop
        l_url := l_url||'OapfTerminalId-'||TO_CHAR(i)||'='||inparam.OapfTerminalId(i)||'&';
end loop;
for i in 1..inparam.OapfMerchBatchId.COUNT loop
        l_url := l_url||'OapfMerchBatchId-'||TO_CHAR(i)||'='||inparam.OapfMerchBatchId(i)||'&';
end loop;
for i in 1..inparam.OapfBatchSequenceNum.COUNT loop
        l_url := l_url||'OapfBatchSequenceNum-'||TO_CHAR(i)||'='||inparam.OapfBatchSequenceNum(i)||'&';
end loop;
l_url := replace(l_url, ' ', '+');
l_html:=utl_http.request(l_url);
unpack_results(l_html, l_names, l_values);
for i in 1..l_names.COUNT loop
	if l_names(i)='OapfStatus' then
		summary.OapfStatus := l_values(i);
	elsif l_names(i)='OapfTrxnType' then
		summary.OapfTrxnType := l_values(i);
	elsif l_names(i)='OapfTrxnDate' then
		summary.OapfTrxnDate := l_values(i);
	elsif l_names(i)='OapfPmtInstrType' then
		summary.OapfPmtInstrType := l_values(i);
	elsif l_names(i)='OapfRefcode' then
		summary.OapfRefcode := l_values(i);
	elsif l_names(i)='OapfErrLocation' then
		summary.OapfErrLocation := l_values(i);
	elsif l_names(i)='OapfVendErrCode' then
		summary.OapfVendErrCode := l_values(i);
	elsif l_names(i)='OapfVendErrmsg' then
		summary.OapfVendErrmsg := l_values(i);
	elsif l_names(i)='OapfNumTrxns' then
		summary.OapfNumTrxns := TO_NUMBER(l_values(i));
       elsif INSTR(l_names(i), 'OapfOrderId-') <>0 then
                l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfOrderId-'));
                reportlst(l_index).OapfOrderId := l_values(i);
       elsif INSTR(l_names(i), 'OapfSplitId-') <>0 then
                l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfSplitId-'));
                reportlst(l_index).OapfSplitId := l_values(i);
       elsif INSTR(l_names(i), 'OapfCreditCounter-') <>0 then
                l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfCreditCounter-'));
                reportlst(l_index).OapfCreditCounter := l_values(i);
        elsif INSTR(l_names(i), 'OapfStatus-') <>0 then
                l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfStatus-'));
                reportlst(l_index).OapfStatus := l_values(i);
        elsif INSTR(l_names(i), 'OapfCapRevOrCreditCode-') <>0 then
                l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfCapRevOrCreditCode-'));
                reportlst(l_index).OapfCapRevOrCreditCode := l_values(i);
        elsif INSTR(l_names(i), 'OapfTerminalId-') <>0 then
                l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfTerminalId-'));
                reportlst(l_index).OapfTerminalId := l_values(i);
        elsif INSTR(l_names(i), 'OapfMerchBatchId-') <>0 then
                l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfMerchBatchId-'));
                reportlst(l_index).OapfMerchBatchId := l_values(i);
        elsif INSTR(l_names(i), 'OapfBatchSequenceNum-') <>0 then
                l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfBatchSequenceNum-'));
                reportlst(l_index).OapfBatchSequenceNum := l_values(i);
        end if;
end loop;
exception
        when others then
                htp.print(SQLERRM);
end;




/***********************orapmtlist*****************************************/
procedure orapmtlist(
		baseurl in varchar2,
		inparam in in_orapmtlist,
		summary out NOCOPY summary_orapmtlist,
		reportlst out NOCOPY reportlst_orapmtlist) IS
l_url           varchar2(2000);
l_html          varchar2(7000);
l_names         v240_table;
l_values        v240_table;
debug           boolean  := FALSE;
l_index         number;
begin

/* Construct request URL */
l_url := baseurl;
l_url := l_url||'OapfAction='|| inparam.OapfAction ||'&';
l_url := l_url || 'OapfStoreId=' || inparam.OapfStoreId || '&';
l_url := l_url || 'OapfEmail=' || inparam.OapfEmail;
l_url := replace(l_url,' ','+');


/* Send HTTP URL request to payment server */
l_html := utl_http.request(l_url);

/*
Parse resulting HTML page.
*/
unpack_results(l_html,l_names,l_values);
if (debug) then
	htp.print(l_html);
end if;

/*
Assign name-value pair table values to summary and reportlst.
reportlst is a table of individual records.
*/
for i in 1..l_names.COUNT LOOP
	if INSTR(l_names(i), 'OapfNumber') <> 0 then
		summary.OapfNumber := TO_NUMBER(l_values(i));
	elsif INSTR(l_names(i), 'OapfPmtType-') <> 0 then
        	l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfPmtType-'));
        	reportlst(l_index).OapfPmtType := l_values(i);
	end if;
end loop;
exception
	when others then
		htp.print(SQLERRM);
end;

/**************************oraclosebatch***********************************/
procedure oraclosebatch(
                baseurl in varchar2,
                inparam in in_oraclosebatch,
		summary out NOCOPY summary_oraclosebatch,
		reportlst out NOCOPY reportlst_oraclosebatch) is

l_url           varchar2(2000);
l_html          varchar2(7000);
l_names         v240_table;
l_values        v240_table;
debug           boolean  := FALSE;
l_index         number;
begin

/*
Construct URL request.
*/
l_url := baseurl;
l_url := l_url||'OapfAction='|| inparam.OapfAction ||'&';
l_url := l_url||'OapfPmtType='||inparam.OapfPmtType||'&';
l_url := l_url||'OapfStoreId='||inparam.OapfStoreId || '&';
l_url := l_url||'OapfMerchBatchID='||inparam.OapfMerchBatchID || '&';
l_url := l_url||'OapfTerminalId='||inparam.OapfTerminalId ||'&';
l_url := l_url||'OapfNlsLang='||inparam.OapfNlsLang ||'&';
l_url := l_url||'OapfAPIScheme='||inparam.OapfAPIScheme;

/* Added for SET */
l_url := replace(l_url,' ','+');

/*
Send HTTP URL request to the payment server.
*/
l_html := utl_http.request(l_url);


/*
Parse resulting HTML page.
*/
unpack_results(l_html,l_names,l_values);

/*
Read though l_names and l_values table, and assign them to summary or
reportlst output parameters. reportlst is a table of output reports for
oraclosebatch operation.
*/
for i in 1..l_names.COUNT loop

    if l_names(i) = 'OapfStatus'
    then
	summary.OapfStatus := l_values(i);
    elsif l_names(i) = 'OapfMerchBatchID'
    then
        summary.OapfMerchBatchID := l_values(i);
    elsif l_names(i) = 'OapfBatchState'
    then
        summary.OapfBatchDate := l_values(i);
    elsif l_names(i) = 'OapfBatchDate'
    then
        summary.OapfBatchDate := l_values(i);
    elsif l_names(i) = 'OapfCreditAmount'
    then
        summary.OapfCreditAmount := l_values(i);
    elsif l_names(i) = 'OapfSalesAmount'
    then
        summary.OapfSalesAmount := l_values(i);
    elsif l_names(i) = 'OapfBatchTotal'
    then
        summary.OapfBatchTotal := l_values(i);
    elsif l_names(i) = 'OapfCurr'
    then
        summary.OapfCurr := l_values(i);
    elsif l_names(i) = 'OapfNumTrxns'
    then
        summary.OapfNumTrxns := TO_NUMBER(l_values(i));
    elsif l_names(i) = 'OapfStoreID'
    then
        summary.OapfStoreID := l_values(i);
    elsif l_names(i) = 'OapfVpsBatchID'
    then
        summary.OapfVpsBatchID := l_values(i);
    elsif l_names(i) = 'OapfErrLocation'
    then
        summary.OapfErrLocation := l_values(i);
    elsif l_names(i) = 'OapfGWBatchID'
    then
        summary.OapfGWBatchID := l_values(i);
    elsif l_names(i) = 'OapfVendErrCode'
    then
        summary.OapfVendErrCode := l_values(i);
    elsif l_names(i) = 'OapfVendErrmsg'
    then
        summary.OapfVendErrmsg := l_values(i);
    elsif INSTR(l_names(i), 'OapfOrderId-') <> 0 then
	l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfOrderId-'));
	reportlst(l_index).OapfOrderId := l_values(i);
    elsif INSTR(l_names(i), 'OapfTrxnType-') <> 0 then
	l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfTrxnType-'));
	reportlst(l_index).OapfTrxnType := l_values(i);
    elsif INSTR(l_names(i), 'OapfTrxnDate-') <> 0 then
	l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfTrxnDate-'));
	reportlst(l_index).OapfTrxnDate := l_values(i);
    elsif INSTR(l_names(i), 'OapfStatus-') <> 0 then
	l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfStatus-'));
	reportlst(l_index).OapfStatus := l_values(i);
    elsif INSTR(l_names(i), 'OapfErrLocation-') <> 0 then
	l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfErrLocation-'));
	reportlst(l_index).OapfErrLocation := l_values(i);
    elsif INSTR(l_names(i), 'OapfVendErrCode-') <> 0 then
	l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfVendErrCode-'));
	reportlst(l_index).OapfVendErrCode := l_values(i);
    elsif INSTR(l_names(i), 'OapfVendErrmsg-') <> 0 then
	l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfVendErrmsg-'));
	reportlst(l_index).OapfVendErrmsg := l_values(i);
    elsif INSTR(l_names(i), 'OapfTrxnAmtType-') <> 0 then
	l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfTrxnAmtType-'));
	reportlst(l_index).OapfTrxnAmtType := l_values(i);
    elsif INSTR(l_names(i), 'OapfSplitId-') <> 0 then
	l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfSplitId-'));
	reportlst(l_index).OapfSplitId := l_values(i);
    end if;

end loop;


exception
        when others then
		htp.print(SQLERRM);
end;

/*************************oraqrytxstatus*****************************************/
procedure oraqrytxstatus(
                baseurl in varchar2,
                inparam in in_oraqrytxstatus,
                summary out NOCOPY summary_oraqrytxstatus,
                reportlst out NOCOPY reportlst_oraqrytxstatus) is

l_url           varchar2(2000);
l_html          varchar2(7000);
l_names         v240_table;
l_values        v240_table;
debug           boolean  := FALSE;
l_index         number;
begin

/* Construct HTTP request URL */
l_url := baseurl;
l_url := l_url||'OapfAction='|| inparam.OapfAction ||'&';
l_url := l_url||'OapfOrderId='||inparam.OapfOrderId||'&';
l_url := l_url||'OapfStoreId='||inparam.OapfStoreId || '&';
l_url := l_url||'OapfPmtType='||inparam.OapfPmtType || '&';
/* Added for SET */
l_url := l_url||'OapfNlsLang='||inparam.OapfNlsLang ||'&';
l_url := l_url||'OapfAPIScheme='||inparam.OapfAPIScheme;
l_url := replace(l_url,' ','+');

if debug then
	htp.print(l_url);
end if;
/* Send HTTP request */
l_html := utl_http.request(l_url);

if debug then
	htp.print(l_html);
end if;


/* Parse the resulting HTML Page. */
unpack_results(l_html,l_names,l_values);

/* Go through l_names and l_values table, assign them to output variable
summary and reportlst.
*/
for i in 1..l_names.COUNT loop

    if l_names(i) = 'OapfNumTrxns'
    then
        summary.OapfNumTrxns := TO_NUMBER(l_values(i));
    elsif INSTR(l_names(i), 'OapfOrderId-') <> 0 then
        l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfOrderId-'));
        reportlst(l_index).OapfOrderId := l_values(i);
    elsif INSTR(l_names(i), 'OapfTrxnType-') <> 0 then
        l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfTrxnType-'));
        reportlst(l_index).OapfTrxnType := l_values(i);
    elsif INSTR(l_names(i), 'OapfStatus-') <> 0 then
        l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfStatus-'));
        reportlst(l_index).OapfStatus := l_values(i);
    elsif INSTR(l_names(i), 'OapfPrice-') <> 0 then
        l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfPrice-'));
        reportlst(l_index).OapfPrice := l_values(i);
    elsif INSTR(l_names(i), 'OapfCurr-') <> 0 then
        l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfCurr-'));
        reportlst(l_index).OapfCurr := l_values(i);
    elsif INSTR(l_names(i), 'OapfAuthcode-') <> 0 then
        l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfAuthcode-'));
        reportlst(l_index).OapfAuthcode := l_values(i);
    elsif INSTR(l_names(i), 'OapfRefcode-') <> 0 then
        l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfRefcode-'));
        reportlst(l_index).OapfRefcode := l_values(i);
    elsif INSTR(l_names(i), 'OapfAVScode-') <> 0 then
        l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfAVScode-'));
        reportlst(l_index).OapfAVScode := l_values(i);
    elsif INSTR(l_names(i), 'OapfTrxnDate-') <> 0 then
        l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfTrxnDate-'));
        reportlst(l_index).OapfTrxnDate := l_values(i);
    elsif INSTR(l_names(i), 'OapfPmtInstrType-') <> 0 then
        l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfPmtInstrType-'));
        reportlst(l_index).OapfPmtInstrType := l_values(i);
    elsif INSTR(l_names(i), 'OapfErrLocation-') <> 0 then
        l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfErrLocation-'));
        reportlst(l_index).OapfErrLocation := l_values(i);
    elsif INSTR(l_names(i), 'OapfVendErrCode-') <> 0 then
        l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfVendErrCode-'));
        reportlst(l_index).OapfVendErrCode := l_values(i);
    elsif INSTR(l_names(i), 'OapfVendErrmsg-') <> 0 then
        l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfVendErrmsg-'));
        reportlst(l_index).OapfVendErrmsg := l_values(i);
    elsif INSTR(l_names(i), 'OapfAcquirer-') <> 0 then
        l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfAcquirer-'));
        reportlst(l_index).OapfAcquirer := l_values(i);
    elsif INSTR(l_names(i), 'OapfAuxMsg-') <> 0 then
        l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfAuxMsg-'));
        reportlst(l_index).OapfAuxMsg := l_values(i);
    elsif INSTR(l_names(i), 'OapfVpsBatchID-') <> 0 then
        l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfVpsBatchID-'));
        reportlst(l_index).OapfVpsBatchID := l_values(i);
/*
	Added for SET
*/
    elsif INSTR(l_names(i), 'OapfSplitId-') <> 0 then
        l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfSplitId-'));
        reportlst(l_index).OapfSplitId := l_values(i);
    elsif INSTR(l_names(i), 'OapfTerminalId-') <> 0 then
        l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfTerminalId-'));
        reportlst(l_index).OapfTerminalId := l_values(i);
    elsif INSTR(l_names(i), 'OapfMerchBatchId-') <> 0 then
        l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfMerchBatchId-'));
        reportlst(l_index).OapfMerchBatchId := l_values(i);
    elsif INSTR(l_names(i), 'OapfBatchSequenceNum-') <> 0 then
        l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfBatchSequenceNum-'));
        reportlst(l_index).OapfBatchSequenceNum := l_values(i);
    end if;

end loop;


exception
        when others then
                htp.print(SQLERRM);
end;


/*************************oraqrybatchstatus**************************************/
procedure oraqrybatchstatus(
                baseurl in varchar2,
                inparam in in_oraqrybatchstatus,
                summary out NOCOPY summary_oraqrybatchstatus,
                reportlst out NOCOPY reportlst_oraqrybatchstatus) is

l_url           varchar2(2000);
l_html          varchar2(7000);
l_names         v240_table;
l_values        v240_table;
debug           boolean  := FALSE;
l_index         number;
begin

/* Construct request URL */
l_url := baseurl;
l_url := l_url||'OapfAction='|| inparam.OapfAction ||'&';
l_url := l_url||'OapfVpsBatchID='||inparam.OapfVpsBatchID||'&';
l_url := l_url||'OapfStoreId='||inparam.OapfStoreId||'&';
l_url := l_url||'OapfTerminalId='||inparam.OapfTerminalId||'&';
l_url := l_url||'OapfNlsLang='||inparam.OapfNlsLang||'&';
l_url := l_url||'OapfAPIScheme='||inparam.OapfAPIScheme;
l_url := replace(l_url,' ','+');


/* Send HTTP request */
l_html := utl_http.request(l_url);

/* Parse resulting HTML page */
unpack_results(l_html,l_names,l_values);

/* Go through l_names and l_values name-value pair table and assign
values to output variables summary and reportlst
*/
for i in 1..l_names.COUNT loop

    if l_names(i) = 'OapfNumTrxns'
    then
        summary.OapfNumTrxns := TO_NUMBER(l_values(i));
    elsif INSTR(l_names(i), 'OapfOrderId-') <> 0 then
        l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfOrderId-'));
        reportlst(l_index).OapfOrderId := l_values(i);
    elsif INSTR(l_names(i), 'OapfTrxnType-') <> 0 then
        l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfTrxnType-'));
        reportlst(l_index).OapfTrxnType := l_values(i);
    elsif INSTR(l_names(i), 'OapfPrice-') <> 0 then
        l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfPrice-'));
        reportlst(l_index).OapfPrice := l_values(i);
    elsif INSTR(l_names(i), 'OapfCurr-') <> 0 then
        l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfCurr-'));
        reportlst(l_index).OapfCurr := l_values(i);
    elsif INSTR(l_names(i), 'OapfTrxnDate-') <> 0 then
        l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfTrxnDate-'));
        reportlst(l_index).OapfTrxnDate := l_values(i);
    elsif INSTR(l_names(i), 'OapfTrxnAmtType-') <> 0 then
        l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfTrxnAmtType-'));
        reportlst(l_index).OapfTrxnAmtType := l_values(i);
    elsif INSTR(l_names(i), 'OapfSplitId-') <> 0 then
        l_index := TO_NUMBER(LTRIM(l_names(i), 'OapfSplitId-'));
        reportlst(l_index).OapfSplitId := l_values(i);
    end if;

end loop;


exception
        when others then
                htp.print(SQLERRM);
end;


/*
Overloaded procedure from Web Group
*/
procedure oraauth ( p_baseurl           IN varchar2,
                p_OapfOrderId           IN OUT NOCOPY varchar2,
                p_OapfCurr              IN varchar2,
                p_OapfPrice             IN varchar2,
                p_OapfAuthType          IN varchar2,
                p_OapfPmtType           IN varchar2,
                p_OapfPmtInstrID        IN varchar2,
                p_OapfPmtInstrExp       IN varchar2,
                p_OapfStoreId           IN varchar2,
                p_OapfcustName          IN varchar2,
                p_OapfAddr1             IN varchar2,
                p_OapfAddr2             IN varchar2,
                p_OapfAddr3             IN varchar2,
                p_OapfCity              IN varchar2,
                p_OapfCnty              IN varchar2,
                p_OapfState             IN varchar2,
                p_OapfCntry             IN varchar2,
                p_OapfPostalCode        IN varchar2,
                p_OapfPhone             IN varchar2,
                p_OapfEmail             IN varchar2,
		p_OapfRefNumber		IN varchar2,
		p_OapfTrxnRef		IN varchar2,
                p_OapfStatus            OUT NOCOPY varchar2,
                p_OapfStatusMsg         OUT NOCOPY varchar2, /* NEW for PS 2.0 */
                p_OapfTrxnType          OUT NOCOPY varchar2,
                p_OapfTrxnDate          OUT NOCOPY varchar2,
                p_OapfApprovalCode      OUT NOCOPY varchar2, /* Change for PS 2.0 */
                p_OapfRefcode           OUT NOCOPY varchar2,
                p_OapfAVScode           OUT NOCOPY varchar2,
                p_OapfPmtInstrType      OUT NOCOPY varchar2,
                p_OapfErrLocation       OUT NOCOPY varchar2,
                p_OapfVendErrCode       OUT NOCOPY varchar2,
                p_OapfVendErrmsg        OUT NOCOPY varchar2,
                p_OapfAcquirer          OUT NOCOPY varchar2,
                p_OapfAuxMsg            OUT NOCOPY varchar2 ) IS

inparam PMT_UTIL.in_oraauth;
outparam PMT_UTIL.out_oraauth;

BEGIN

        fnd_file.put_line(FND_FILE.LOG, 'oraauth ()+');
        inparam.OapfOrderId     := p_OapfOrderId;
        inparam.OapfCurr        := p_OapfCurr ;
        inparam.OapfPrice       := p_OapfPrice;
        inparam.OapfAuthType    := p_OapfAuthType;
        inparam.OapfPmtType     := p_OapfPmtType;
        inparam.OapfPmtInstrID  := p_OapfPmtInstrID;
        inparam.OapfPmtInstrExp := p_OapfPmtInstrExp;
        inparam.OapfStoreId     := p_OapfStoreId;
        inparam.OapfcustName    := p_OapfcustName;
        inparam.OapfAddr1       := p_OapfAddr1 ;
        inparam.OapfAddr2       := p_OapfAddr2 ;
        inparam.OapfAddr3       := p_OapfAddr3 ;
        inparam.OapfCity        := p_OapfCity ;
        inparam.OapfCnty        := p_OapfCnty ;
        inparam.OapfState       := p_OapfState;
        inparam.OapfCntry       := p_OapfCntry;
        inparam.OapfPostalCode  := p_OapfPostalCode;
        inparam.OapfPhone       := p_OapfPhone ;
        inparam.OapfEmail       := p_OapfEmail ;
	inparam.OapfRefNumber   := p_OapfRefNumber;
	inparam.OapfTrxnRef     := p_OapfTrxnRef;

        PMT_UTIL.oraauth(p_baseurl, inparam, outparam);

        /* start workaround :
           setting p_OapfOrderId to inparam.OapfOrderId is a workaround so that
           indicator variables in c-code are initialized properly, when these
           variables are returned to calling c program arzarm.lpc */
        p_OapfOrderId           := inparam.OapfOrderId ;
        /* end worakround */

        p_OapfTrxnType          := outparam.OapfTrxnType ;
        p_OapfStatus            := outparam.OapfStatus ;
        p_OapfStatusMsg         := outparam.OapfStatusMsg ;
        p_OapfApprovalCode      := outparam.OapfApprovalCode ;
        p_OapfRefcode           := outparam.OapfRefcode ;
        p_OapfAVScode           := outparam.OapfAVScode ;
        p_OapfTrxnDate          := outparam.OapfTrxnDate ;
        p_OapfPmtInstrType      := outparam.OapfPmtInstrType ;
        p_OapfErrLocation       := outparam.OapfErrLocation ;
        p_OapfVendErrCode       := outparam.OapfVendErrCode ;
        p_OapfVendErrmsg        := outparam.OapfVendErrmsg ;
        p_OapfAcquirer          := outparam.OapfAcquirer ;
        p_OapfAuxMsg            := outparam.OapfAuxMsg ;
        fnd_file.put_line(FND_FILE.LOG, 'oraauth ()-');


END;

/*
   vcrisost :
   this is the procedure version used by arzarm.lpc - where
   we pass the parameters individually rather than via inparam/outparam
*/
procedure oracapture ( p_baseurl        IN varchar2,
                p_OapfOrderId           IN OUT NOCOPY varchar2,
                p_OapfCurr              IN varchar2,
                p_OapfPrice             IN varchar2,
                p_OapfPmtType           IN varchar2,
                p_OapfStoreId           IN varchar2,
                p_OapfTrxnRef           IN varchar2,
                p_OapfStatus            OUT NOCOPY varchar2,
                p_OapfStatusMsg         OUT NOCOPY varchar2, /* NEW for PS 2.0 */
                p_OapfTrxnType          OUT NOCOPY varchar2,
                p_OapfTrxnDate          OUT NOCOPY varchar2,
                p_OapfPmtInstrType      OUT NOCOPY varchar2,
                p_OapfRefcode           OUT NOCOPY varchar2,
                p_OapfErrLocation       OUT NOCOPY varchar2,
                p_OapfVendErrCode       OUT NOCOPY varchar2,
                p_OapfVendErrmsg        OUT NOCOPY varchar2,
		p_OapfCashRecId         IN  VARCHAR2 DEFAULT null) IS

inparam PMT_UTIL.in_oracapture;
outparam PMT_UTIL.out_oracapture;

BEGIN

        fnd_file.put_line(FND_FILE.LOG, 'oracapture ()+');
        /* vcrisost : put messages to debug 1471726 */
        fnd_file.put_line(FND_FILE.LOG, 'PRINTING INPARAM VARIABLES');
        arp_standard.debug('PRINTING INPARAM VARIABLES');
        arp_standard.debug('inparam.OapfOrderId = ' || p_OapfOrderId);
        arp_standard.debug('inparam.OapfCurr    = ' || p_OapfCurr);
        arp_standard.debug('inparam.OapfPrice   = ' || p_OapfPrice);
        arp_standard.debug('inparam.OapfPmtType = ' || p_OapfPmtType);
        arp_standard.debug('inparam.OapfStoreId = ' || p_OapfStoreId);
        arp_standard.debug('inparam.OapfTrxnRef = ' || p_OapfTrxnRef);
        arp_standard.debug('inparam.OapfCashRecId ' || p_OapfCashRecId);

        inparam.OapfOrderId     := p_OapfOrderId;
        inparam.OapfCurr        := p_OapfCurr ;
        inparam.OapfPrice       := p_OapfPrice;
        inparam.OapfPmtType     := p_OapfPmtType;
        inparam.OapfStoreId     := p_OapfStoreId;
        inparam.OapfTrxnRef      := p_OapfTrxnRef;
        inparam.OapfCashRecId    := p_OapfCashRecId;

        PMT_UTIL.oracapture(p_baseurl, inparam, outparam);

        /* vcrisost : put messages to debug 1471726 */
        arp_standard.debug('PRINTING OUTPARAM VARIABLES');
        arp_standard.debug('p_OapfOrderId           = ' || outparam.OapfOrderId) ;
        arp_standard.debug('p_OapfStatus            = ' || outparam.OapfStatus) ;
        arp_standard.debug('p_OapfStatusMsg         = ' || outparam.OapfStatusMsg) ;
        arp_standard.debug('p_OapfTrxnType          = ' || outparam.OapfTrxnType) ;
        arp_standard.debug('p_OapfTrxnDate          = ' || outparam.OapfTrxnDate) ;
        arp_standard.debug('p_OapfPmtInstrType      = ' || outparam.OapfPmtInstrType) ;
        arp_standard.debug('p_OapfRefcode           = ' || outparam.OapfRefcode) ;
        arp_standard.debug('p_OapfErrLocation       = ' || outparam.OapfErrLocation) ;
        arp_standard.debug('p_OapfVendErrCode       = ' || outparam.OapfVendErrCode) ;
        arp_standard.debug('p_OapfVendErrmsg        = ' || outparam.OapfVendErrmsg) ;

        /* start workaround :
           setting p_OapfOrderId to inparam.OapfOrderId is a workaround so that
           indicator variables in c-code are initialized properly, when these
           variables are returned to calling c program arzarm.lpc */

        p_OapfOrderId           := inparam.OapfOrderId ;

        /* end worakround */

        p_OapfStatus            := outparam.OapfStatus ;
        p_OapfStatusMsg         := outparam.OapfStatusMsg ;
        p_OapfTrxnType          := outparam.OapfTrxnType ;
        p_OapfTrxnDate          := outparam.OapfTrxnDate ;
        p_OapfPmtInstrType      := outparam.OapfPmtInstrType ;
        p_OapfRefcode           := outparam.OapfRefcode ;
        p_OapfErrLocation       := outparam.OapfErrLocation ;
        p_OapfVendErrCode       := outparam.OapfVendErrCode ;
        p_OapfVendErrmsg        := outparam.OapfVendErrmsg ;

        fnd_file.put_line(FND_FILE.LOG, 'oracapture ()-');
END;
end PMT_UTIL;

/
