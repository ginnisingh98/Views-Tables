--------------------------------------------------------
--  DDL for Package ICX_PAYMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_PAYMENT_PVT" AUTHID CURRENT_USER AS
/* $Header: ICXPSPVS.pls 115.5 99/07/17 03:20:39 porting ship $ */

type v240_table is table of varchar2(240)
        index by binary_integer;

function GetServerUrl
	return varchar2;

procedure orapmtlist(
                OapfStoreId     in      varchar2,
                OapfEmail       in      varchar2        default null,
		OapfNumber	out	varchar2,
		OapfPmtType	out	v240_table);
procedure orainv(
                OapfOrderId     in out  varchar2,
                OapfCurr        in      varchar2,
                OapfPrice       in out  varchar2,

                OapfAuthType    in      varchar2,
                OapfPmtType     in      varchar2,
                OapfStoreId     in      varchar2,
                OapfPayURL	in      varchar2,
                OapfReturnURL	in      varchar2,
                OapfFile	in      varchar2        default null,
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
                OapfVendErrmsg  out     varchar2);

procedure orapay(
                OapfPmtSvc	in	varchar2,
                OapfStatus      out     varchar2,
                OapfOrderId     out	varchar2,
                OapfCurr        out     varchar2,

                OapfPrice       out	varchar2,
                OapfAuthType    out     varchar2,
                OapfStoreId     out     varchar2,
                OapfErrLocation out     varchar2,
                OapfVendErrCode out     varchar2,
                OapfVendErrmsg  out     varchar2);

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
		OapfAuxMsg	out	varchar2);
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

                OapfVendErrmsg  out     varchar2);
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
                OapfVendErrmsg  out     varchar2);

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
                OapfVendErrmsg  out     varchar2);

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
                OapfVendErrmsg  out     varchar2);

procedure oraqrytxstatus(
		OapfOrderId	in	varchar2,
                OapfPmtType     in      varchar2,
                OapfStoreID     in	varchar2);
end ICX_PAYMENT_PVT;

 

/
