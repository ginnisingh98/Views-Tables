--------------------------------------------------------
--  DDL for Package PMT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PMT_UTIL" AUTHID CURRENT_USER as
/* $Header: ARPSUTLS.pls 120.5 2005/10/30 03:56:24 appldev ship $*/
/*
Types created from SET extended operations. Since SET supports group
operations, we need to input a list of OapfOrderId, etc.
Therefore, SETOapfOrderId is declared as a table of OapfOrderId and
starts from 0 for compatibility with 1.0
*/
TYPE SETOapfOrderId is table of varchar2(80) index by binary_integer;
TYPE SETOapfSplitId is table of varchar2(80) index by binary_integer;
TYPE SETOapfPrice is table of varchar2(80) index by binary_integer;
TYPE SETOapfCurr is table of varchar2(80) index by binary_integer;
TYPE SETOapfTerminalId is table of varchar2(80) index by binary_integer;
TYPE SETOapfMerchBatchId is table of varchar2(80) index by binary_integer;
TYPE SETOapfCapCode is table of varchar2(80) index by binary_integer;
TYPE SETOapfPmtInstrType is table of varchar2(80) index by binary_integer;
TYPE SETOapfRefcode is table of varchar2(80) index by binary_integer;
TYPE SETOapfCreditCounter is table of varchar2(80) index by binary_integer;
TYPE SETOapfBatchSequenceNum is table of varchar2(80) index by binary_integer;
TYPE in_oraauth IS RECORD (
	OapfAction char(7) NOT NULL := 'oraauth',
	OapfOrderId varchar2(80),
	OapfCurr varchar2(80),
	OapfPrice varchar2(80),
	OapfAuthType varchar2(80),
	OapfPmtType varchar2(80),
	OapfPmtInstrID varchar2(80),
	OapfPmtInstrExp varchar2(80),
	OapfStoreId varchar2(80),
	OapfcustName varchar2(80),
	OapfAddr1 varchar2(80),
	OapfAddr2 varchar2(80),
	OapfAddr3 varchar2(80),
	OapfCity varchar2(80),
	OapfCnty varchar2(80),
	OapfState varchar2(80),
	OapfCntry varchar2(80),
	OapfPostalCode varchar2(80),
	OapfPhone varchar2(80),
	OapfEmail varchar2(80),
        OapfRefNumber varchar2(80),
        OapfTrxnRef varchar2(80),
/*
SET name-value pairs.
*/
	OapfNlsLang varchar2(80),
	OapfAPIScheme varchar2(80),
	OapfTerminalId varchar2(80),
	OapfMerchBatchId varchar2(80),
	OapfBatchSequenceNum varchar2(80),
	OapfSplitShipment varchar2(80),
	OapfAuthCurr varchar2(80),
	OapfAuthPrice varchar2(80),
	OapfInstallTotalTrans varchar2(80),
	OapfRecurringFreq varchar2(80),
	oapfRecurringExpiryDate varchar2(80),
	OapfCustomerReferenceNumber varchar2(80),
	OapfDestinationPostalCode varchar2(80),
	OapfLocalTaxPrice varchar2(80),
	OapfLocalTaxCurr varchar2(80)
	  );
TYPE out_oraauth IS RECORD (
	OapfOrderId varchar2(80),
	OapfTrxnType varchar2(80),
	OapfStatus varchar2(20), /* Modified for PS 2.0 */
        OapfStatusMsg varchar2(200),     /* Added for PS 2.0 */
        OapfApprovalCode varchar2(80),  /* Added for PS 2.0 */
	OapfRefcode varchar2(80),
	OapfAVScode varchar2(80),
	OapfTrxnDate varchar2(80),
	OapfPmtInstrType varchar2(80),
	OapfErrLocation varchar2(80),
	OapfVendErrCode varchar2(80),
	OapfVendErrmsg varchar2(255),
	OapfAcquirer varchar2(80),
	OapfAuxMsg varchar2(80),
/*
SET name-value pairs.
*/
	OapfSplitId varchar2(80),
	OapfMerchBatchId varchar2(80),
	OapfCapCode varchar2(80),
	OapfCardCurr varchar2(80),
	OapfCurrConvRate varchar2(80),
	OapfTerminalId varchar2(80) );
procedure oraauth (baseurl in varchar2,
                   inparam in in_oraauth,
		   outparam out NOCOPY out_oraauth);

/*
--------------------------orasubsequentauth----------------------------
baseurl: URL address for payment server + /orapmt/OraPmt?
in_orasubsequentauth: input name-value pairs
out_orasubsequentauth:output name-value pairs
*/
TYPE in_orasubsequentauth IS RECORD (
	OapfAction char(17) NOT NULL:='orasubsequentauth',
	OapfAPIScheme char(11) NOT NULL:='ExtendedSET',
	OapfOrderId varchar2(80),
	OapfPrevSplitId varchar2(80),
	OapfSplitId varchar2(80),
	OapfCurr varchar2(80),
	OapfPrice varchar2(80),
	OapfAuthType varchar2(80),
	OapfPmtType varchar2(80),
	OapfStoreId varchar2(80),
	OapfSubsequentAuthInd varchar2(80),
	OapfNlsLang varchar2(80));
TYPE out_orasubsequentauth IS RECORD (
	OapfOrderId varchar2(80),
	OapfSplitId varchar2(80),
	OapfTrxnType varchar2(80),
	OapfStatus varchar2(80),
	OapfAuthcode varchar2(80),
	OapfNlsLang varchar2(80),
	OapfRefcode varchar2(80),
	OapfAVScode varchar2(80),
	OapfTrxnDate varchar2(80),
	OapfPmtInstrType varchar2(80),
	OapfErrLocation varchar2(80),
	OapfVendErrCode varchar2(80),
	OapfVendErrmsg varchar2(80),
	OapfAcquirer varchar2(80),
	OapfMerchBatchId varchar2(80),
	OapfVpsBatchId varchar2(80),
	OapfAuxMsg varchar2(80),
	OapfCapCode varchar2(80));
procedure orasubsequentauth (baseurl in varchar2,
			     inparam in in_orasubsequentauth,
			     outparam out NOCOPY out_orasubsequentauth);

/*
-----------------------------oracapture-------------------------------------
baseurl:url address for payment server + /orapmt/OraPmt?
in_oracapture: type record for input name-value pairs
out_oracapture: type record for output name-value pairs

*/
TYPE in_oracapture IS RECORD (
        OapfAction varchar2(20) NOT NULL:= 'oracapture',
        OapfOrderId varchar2(80),
        OapfPrice varchar2(80),
        OapfCurr varchar2(80),
        OapfPmtType varchar2(80),
        OapfStoreId varchar2(80),
        OapfTrxnRef varchar2(80),
        OapfCashRecId varchar2(80)
);
TYPE out_oracapture IS RECORD (
        OapfOrderId varchar2(80),    /* Added for PS 2.0 */
        OapfStatus varchar2(20),     /* Modified for PS 2.0 */
        OapfStatusMsg varchar2(200),  /* Added for PS 2.0 */
        OapfTrxnType varchar2(80),
        OapfTrxnDate varchar2(80),
        OapfPmtInstrType varchar2(80),
        OapfRefcode varchar2(80),
        OapfErrLocation varchar2(80),
        OapfVendErrCode varchar2(80),
        OapfVendErrmsg varchar2(255));
procedure oracapture(baseurl in varchar2,
                     inparam in in_oracapture,
                     outparam out NOCOPY out_oracapture);

/*
------------------------------oracapture for SET---------------------------
*/
TYPE SETIN_oracapture IS RECORD (
	OapfAction char(10) NOT NULL := 'oracapture',
	OapfPmtType varchar2(80),
	OapfNlsLang varchar2(80),
	OapfAPIScheme char(11) NOT NULL := 'ExtendedSET',
	OapfNumTrxns number,
	OapfStoreId varchar2(80),
	OapfOrderId SETOapfOrderId,
	OapfSplitId SETOapfSplitId,
	OapfPrice SETOapfPrice,
	OapfCurr SETOapfCurr,
	OapfTerminalId SETOapfTerminalId,
	OapfMerchBatchId SETOapfMerchBatchId,
	OapfBatchSequenceNum SETOapfBatchSequenceNum);
TYPE SETsummary_oracapture IS RECORD (
	OapfStatus varchar2(80),
	OapfNumTrxns number,
	OapfTrxnType varchar2(80),
	OapfTrxnDate varchar2(80),
	OapfPmtInstrType varchar2(80),
	OapfRefcode varchar2(80),
	OapfErrLocation varchar2(80),
	OapfVendErrCode varchar2(80),
	OapfVendErrmsg varchar2(80));
TYPE SETreport_oracapture IS RECORD (
	OapfStatus varchar2(80),
        OapfOrderId varchar2(80),
	OapfSplitId varchar2(80),
	OapfCurr varchar2(80),
	OapfPrice varchar2(80),
	OapfCapCode varchar2(80),
	OapfTerminalId varchar2(80),
	OapfPmtInstrType varchar2(80),
	OapfRefcode varchar2(80),
	OapfMerchBatchId varchar2(80),
	OapfBatchSequenceNum varchar2(80));
TYPE SETreportlst_oracapture is table of SETreport_oracapture index by binary_integer;
procedure oracapture(baseurl in varchar2,
		     inparam in SETIN_oracapture,
		     summary out NOCOPY SETsummary_oracapture,
                     reportlst out NOCOPY SETreportlst_oracapture);



/*
------------------------------oravoid-----------------------------------------
baseurl:url address for payment server + /orapmt/OraPmt?
in_oravoid:type record for input name-value pairs
           in_oravoid.OapfTrxnType should be number in according to the
	   corresponding actions such as Capture(8), MarkCapture(9),
	   Return(5). For details, see Appendix B in the developer's guide.
out_oravoid:type record for output name-value pairs
*/
TYPE in_oravoid IS RECORD (
        OapfAction varchar2(20) NOT NULL:= 'oravoid',
	OapfTrxnType varchar2(80) ,
	OapfPmtType varchar2(80),
	OapfOrderId varchar2(80),
        OapfStoreId varchar2(80));
TYPE out_oravoid IS RECORD (
        OapfStatus varchar2(80),
        OapfTrxnType varchar2(80),
        OapfTrxnDate varchar2(80),
	OapfPmtInstrType varchar2(80),
	OapfRefcode varchar2(80),
	OapfErrLocation varchar2(80),
	OapfVendErrCode varchar2(80),
	OapfVendErrmsg varchar2(80));
procedure oravoid (baseurl in varchar2,
		   inparam in in_oravoid,
	           outparam out NOCOPY out_oravoid);

/*
------------------------------oravoid for SET--------------------------------
*/
TYPE SETIN_oravoid IS RECORD (
	OapfAction char(7) NOT NULL := 'oravoid',
	OapfTrxnType varchar2(80),
	OapfPmtType varchar2(80),
	OapfNlsLang varchar2(80),
	OapfAPIScheme varchar2(80) := 'ExtendedSET',
	OapfNumTrxns number,
	OapfStoreId varchar2(80),
	OapfOrderId  SETOapfOrderId,
	OapfSplitId SETOapfSplitId,
	OapfPrice   SETOapfPrice,
	OapfCurr    SETOapfCurr,
	OapfTerminalId SETOapfTerminalId,
	OapfMerchBatchId SETOapfMerchBatchId,
	OapfBatchSequenceNum SETOapfBatchSequenceNum);
TYPE SETsummary_oravoid IS RECORD (
        OapfStatus varchar2(80),
        OapfTrxnType varchar2(80),
        OapfTrxnDate varchar2(80),
        OapfPmtInstrType varchar2(80),
        OapfRefcode varchar2(80),
        OapfErrLocation varchar2(80),
        OapfVendErrCode varchar2(80),
        OapfNumTrxns number,
        OapfVendErrmsg varchar2(80));
TYPE SETreport_oravoid IS RECORD (
        OapfStatus varchar2(80),
        OapfOrderId varchar2(80),
        OapfSplitId varchar2(80),
        OapfCapRevOrCreditCode varchar2(80),
        OapfTerminalId varchar2(80),
        OapfMerchBatchId varchar2(80),
        OapfBatchSequenceNum varchar2(80));
TYPE SETreportlst_oravoid is table of SETreport_oravoid index by binary_integer;
procedure oravoid(baseurl in varchar2, inparam in SETIN_oravoid,
		  summary out NOCOPY SETsummary_oravoid,
		  reportlst out NOCOPY SETreportlst_oravoid);


/*
-------------------------------orareturn--------------------------------------
baseurl:url address for payment server + /orapmt/OraPmt?
in_orareturn:type record for input name-value pairs
out_orareturn:type record for output name-value pairs
*/
TYPE in_orareturn IS RECORD (
        OapfAction varchar2(20) NOT NULL:= 'orareturn',
        OapfOrderId varchar2(80),
        OapfPrice varchar2(80),
        OapfCurr varchar2(80),
        OapfStoreId varchar2(80),
        OapfPmtType varchar2(80),
        OapfPmtInstrID varchar2(80),
        OapfPmtInstrExp varchar2(80),
	OapfMerchUsername varchar2(80),
	OapfMerchPasswd varchar2(80));
TYPE out_orareturn IS RECORD (
        OapfStatus varchar2(80),
        OapfTrxnType varchar2(80),
        OapfTrxnDate varchar2(80),
        OapfPmtInstrType varchar2(80),
        OapfRefcode varchar2(80),
        OapfErrLocation varchar2(80),
        OapfVendErrCode varchar2(80),
        OapfVendErrmsg varchar2(80));
procedure orareturn (baseurl in varchar2,
                   inparam in in_orareturn,
                   outparam out NOCOPY out_orareturn);
/*
------------------------------orareturn for SET---------------------------
*/
TYPE SETIN_orareturn IS RECORD (
        OapfAction char(9) NOT NULL := 'orareturn',
        OapfPrice SETOapfPrice,
        OapfCurr SETOapfCurr,
        OapfStoreId varchar2(80),
        OapfSplitId SETOapfSplitId,
        OapfPmtType varchar2(80),
        OapfOrderId SETOapfOrderId,
        OapfNlsLang varchar2(80),
        OapfAPIScheme char(11) NOT NULL := 'ExtendedSET',
        OapfNumTrxns number,
	OapfCreditCounter SETOapfCreditCounter,
        OapfTerminalId SETOapfTerminalId,
        OapfMerchBatchId SETOapfMerchBatchId,
        OapfBatchSequenceNum SETOapfBatchSequenceNum);
TYPE SETsummary_orareturn IS RECORD (
        OapfStatus varchar2(80),
        OapfTrxnType varchar2(80),
        OapfTrxnDate varchar2(80),
        OapfPmtInstrType varchar2(80),
        OapfNumTrxns number,
        OapfRefcode varchar2(80),
        OapfErrLocation varchar2(80),
        OapfVendErrCode varchar2(80),
        OapfVendErrmsg varchar2(80));
TYPE SETreport_orareturn IS RECORD (
        OapfStatus varchar2(80),
        OapfOrderId varchar2(80),
        OapfSplitId varchar2(80),
	OapfCreditCounter varchar2(80),
	OapfCapRevOrCreditCode varchar2(80),
        OapfTerminalId varchar2(80),
        OapfMerchBatchId varchar2(80),
        OapfBatchSequenceNum varchar2(80));
TYPE SETreportlst_orareturn is table of SETreport_orareturn index by binary_integer;
procedure orareturn(baseurl in varchar2,
                    inparam in SETIN_orareturn,
                    summary out NOCOPY SETsummary_orareturn,
                    reportlst out NOCOPY SETreportlst_orareturn);


/*
---------------------------------orapmtlist-------------------------------------
baseurl:url address for payment server + /orapmt/OraPmt?
in_orapmtlist:type record for input name-value pairs
summary_orapmtlist:type record for output summary name-value pairs
reportlst_orapmtlist:type table for an array of output name-value pairs
In this particular procedure, summary.OapfNumber gives the number of
the returning payment types. So the code to call orapmtlist would look
like:
PMT_UTIL.orapmtlist(baseurl, inparam, summary, reportlst);
for i in 0..summary.OapfNumber-1 loop
	dbms_output.put_line(reportlst(i).OapfPmtType);
end loop;
*/
TYPE in_orapmtlist IS RECORD(
	OapfAction char(10) NOT NULL := 'orapmtlist',
	OapfStoreId varchar2(80),
	OapfEmail varchar2(80));
TYPE summary_orapmtlist IS RECORD (
	OapfNumber number);
TYPE report_orapmtlist IS RECORD (
	OapfPmtType varchar2(200));
TYPE reportlst_orapmtlist IS TABLE OF report_orapmtlist INDEX BY BINARY_INTEGER;
procedure orapmtlist(baseurl in varchar2,
		     inparam in in_orapmtlist,
                     summary out NOCOPY summary_orapmtlist,
		     reportlst out NOCOPY reportlst_orapmtlist);


/*
--------------------------------oraclosebatch---------------------------------
baseurl:url address for payment server + /orapmt/OraPmt?
in_oraclosebatch:type record for input name-value pairs
summary_oraclosebatch:type record for output summary name-value pairs
reportlst_oraclosebatch:type table for an array of output name-value pairs
For each batch closed, a report of its OapfOrderId, OapfTrxnType and etc
information would soon follows. The total number of reports is stored in
summary_oraclosebatch.OapfNumTrxns. So the code to call oraclosebatch would
look like:
PMT_UTIL.oraclosebatch(baseurl, inparam, summary, reportlst);
--to print out NOCOPY the summary
dbms_output.put_line(summary.OapfMerchBatchID);
...
--to print out NOCOPY individual report
for i in 0..summary.OapfNumTrxns-1 loop
	dbms_output.put_line(reportlst(i).OapfOrderId);
	dbms_output.put_line(reportlst(i).OapfTrxnType);
end loop;
*/
TYPE in_oraclosebatch IS RECORD(
	OapfAction char(13) NOT NULL := 'oraclosebatch',
	OapfPmtType varchar2(80),
	OapfMerchBatchID varchar2(80),
	OapfStoreId varchar2(80),
/*
Added for 1.1
*/
	OapfTerminalId varchar2(80),
	OapfNlsLang varchar2(80),
	OapfAPIScheme varchar2(80));
TYPE summary_oraclosebatch IS RECORD (
	OapfMerchBatchID varchar2(80),
	OapfStatus varchar2(80),
	OapfBatchState varchar2(80),
	OapfBatchDate varchar2(80),
	OapfCreditAmount varchar2(80),
	OapfSalesAmount varchar2(80),
	OapfBatchTotal varchar2(80),
	OapfCurr varchar2(80),
	OapfNumTrxns number,
	OapfStoreID varchar2(80),
	OapfVpsBatchID varchar2(80),
	OapfGWBatchID varchar2(80),
	OapfErrLocation varchar2(80),
	OapfVendErrCode varchar2(80),
	OapfVendErrmsg varchar2(80));
TYPE report_oraclosebatch IS RECORD (
	OapfOrderId varchar2(80),
	OapfTrxnType varchar2(80),
	OapfTrxnDate varchar2(80),
	OapfStatus varchar2(80),
	OapfErrLocation varchar2(80),
	OapfVendErrCode varchar2(80),
	OapfVendErrmsg varchar2(255),
/* Added for SET */
	OapfTrxnAmtType varchar2(80),
	OapfSplitId varchar2(80));
TYPE reportlst_oraclosebatch IS TABLE OF report_oraclosebatch INDEX BY BINARY_INTEGER;
procedure oraclosebatch(baseurl in varchar2, inparam in in_oraclosebatch,
summary out NOCOPY summary_oraclosebatch, reportlst out NOCOPY reportlst_oraclosebatch);



/*
------------------------------------oraqrytxstatus-------------------------------
baseurl: url address for payment server + /orapmt/OraPmt?
in_oraqrytxstatus: record type for input name-value pairs
summary_oraqrytxstatus:record type for output summary name-value pairs
reportlst_oraqrytxstatus:type table for an array of output name-value pairs.
Again, summary_oraqrytxstatus.OapfNumTrxns denotes the number of transactions
that follow.
*/
TYPE in_oraqrytxstatus IS RECORD(
	OapfAction char(14) NOT NULL := 'oraqrytxstatus',
	OapfOrderId varchar2(80),
	OapfStoreId varchar2(80),
	OapfPmtType varchar2(80),
/* Added for 1.1 */
	OapfNlsLang varchar2(80),
	OapfAPIScheme varchar2(80));
TYPE summary_oraqrytxstatus IS RECORD (
	OapfNumTrxns number);
TYPE report_oraqrytxstatus IS RECORD (
	OapfOrderId varchar2(80),
	OapfTrxnType varchar2(80),
	OapfStatus varchar2(80),
	OapfPrice varchar2(80),
	OapfCurr varchar2(80),
	OapfAuthcode varchar2(80),
	OapfRefcode varchar2(80),
	OapfAVScode varchar2(80),
	OapfTrxnDate varchar2(80),
	OapfPmtInstrType varchar2(80),
	OapfErrLocation varchar2(80),
	OapfVendErrCode varchar2(80),
	OapfVendErrmsg varchar2(255),
	OapfAcquirer varchar2(80),
	OapfAuxMsg   varchar2(255),
	OapfVpsBatchID varchar2(80),
/* Added for Extended SET */
	OapfSplitId varchar2(80),
	OapfTerminalId varchar2(80),
	OapfMerchBatchId varchar2(80),
	OapfBatchSequenceNum varchar2(80));
TYPE reportlst_oraqrytxstatus IS TABLE OF report_oraqrytxstatus INDEX BY BINARY_INTEGER;
procedure oraqrytxstatus(baseurl in varchar2, inparam in in_oraqrytxstatus,
summary out NOCOPY summary_oraqrytxstatus, reportlst out NOCOPY reportlst_oraqrytxstatus);


/*
-----------------------------oraqrybatchstatus-------------------------------
baseurl : url for payment server + /orapmt/OraPmt?
in_oraqrybatchstatus: type record for input name-value pairs
summary_oraqrybatchstatus: type record for output summary name-value pairs
reportlst_oraqrybatchstatus:type table for output reports name-value pairs.
*/
TYPE in_oraqrybatchstatus IS RECORD(
	OapfAction char(17) NOT NULL := 'oraqrybatchstatus',
	OapfVpsBatchID varchar2(80),
	OapfStoreId varchar2(80),
/*
Added for SET
*/
	OapfTerminalId varchar2(80),
	OapfNlsLang varchar2(80),
	OapfAPIScheme varchar2(80));
TYPE summary_oraqrybatchstatus IS RECORD(
	OapfNumTrxns number);
TYPE report_oraqrybatchstatus IS RECORD(
	OapfOrderId varchar2(80),
	OapfTrxnType varchar2(80),
	OapfPrice varchar2(80),
	OapfCurr varchar2(80),
	OapfTrxnDate varchar2(80),
/* Added for SET */
	OapfTrxnAmtType varchar2(80),
	OapfSplitId varchar2(80));
TYPE reportlst_oraqrybatchstatus IS TABLE OF report_oraqrybatchstatus INDEX BY BINARY_INTEGER;
procedure oraqrybatchstatus(baseurl in varchar2, inparam in in_oraqrybatchstatus,
summary out NOCOPY summary_oraqrybatchstatus, reportlst out NOCOPY reportlst_oraqrybatchstatus);


/* Overloaded procedure for Web Group */
/*This is the new PS 2.0 version */
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
		p_OapfRefNumber         IN varchar2,
		p_OapfTrxnRef           IN varchar2,
                p_OapfStatus            OUT NOCOPY varchar2,
                p_OapfStatusMsg         OUT NOCOPY varchar2,
                p_OapfTrxnType          OUT NOCOPY varchar2,
                p_OapfTrxnDate          OUT NOCOPY varchar2,
                p_OapfApprovalCode      OUT NOCOPY varchar2,
                p_OapfRefcode           OUT NOCOPY varchar2,
                p_OapfAVScode           OUT NOCOPY varchar2,
                p_OapfPmtInstrType      OUT NOCOPY varchar2,
                p_OapfErrLocation       OUT NOCOPY varchar2,
                p_OapfVendErrCode       OUT NOCOPY varchar2,
                p_OapfVendErrmsg        OUT NOCOPY varchar2,
                p_OapfAcquirer          OUT NOCOPY varchar2,
                p_OapfAuxMsg            OUT NOCOPY varchar2 );

/* This is the new PS 2.0 version */
procedure oracapture ( p_baseurl        IN varchar2,
                p_OapfOrderId           IN OUT NOCOPY varchar2,
                p_OapfCurr              IN varchar2,
                p_OapfPrice             IN varchar2,
                p_OapfPmtType           IN varchar2,
                p_OapfStoreId           IN varchar2,
                p_OapfTrxnRef           IN varchar2,
                p_OapfStatus            OUT NOCOPY varchar2,
                p_OapfStatusMsg         OUT NOCOPY varchar2,
                p_OapfTrxnType          OUT NOCOPY varchar2,
                p_OapfTrxnDate          OUT NOCOPY varchar2,
                p_OapfPmtInstrType      OUT NOCOPY varchar2,
                p_OapfRefcode           OUT NOCOPY varchar2,
                p_OapfErrLocation       OUT NOCOPY varchar2,
                p_OapfVendErrCode       OUT NOCOPY varchar2,
                p_OapfVendErrmsg        OUT NOCOPY varchar2,
		p_OapfCashRecId         IN VARCHAR2 DEFAULT null);
end PMT_UTIL;

 

/
