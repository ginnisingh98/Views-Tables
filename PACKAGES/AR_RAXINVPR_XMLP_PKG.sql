--------------------------------------------------------
--  DDL for Package AR_RAXINVPR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_RAXINVPR_XMLP_PKG" AUTHID CURRENT_USER AS
/* $Header: RAXINVPRS.pls 120.0 2007/12/27 14:27:31 abraghun noship $ */
	P_TRX_NUMBER_LOW	varchar2(40);
	P_TRX_NUMBER_HIGH	varchar2(40);
	P_CHOICE	varchar2(40);
	P_OPEN_INVOICE	varchar2(40);
	P_CUST_TRX_TYPE_ID	number;
	P_INSTALLMENT_NUMBER	number;
	P_DATES_LOW	date;
	P_DATES_HIGH	date;
	P_CUSTOMER_ID	varchar2(40);
	p_customer_class_code	varchar2(40);
	p_batch_id	varchar2(40);
	P_customer_trx_id	number;
	p_where1	varchar2(8096):= 'U_BILL.CUST_ACCT_SITE_ID = A_BILL.CUST_ACCT_SITE_ID
AND      U_BILL.SITE_USE_ID = A.BILL_TO_SITE_USE_ID
AND      A.COMPLETE_FLAG = ''Y''
AND      A.BILL_TO_CUSTOMER_ID = B.CUST_ACCOUNT_ID
AND      DECODE(P.PAYMENT_SCHEDULE_ID, '''', 0, NVL(T.PRINTING_LEAD_DAYS,0) ) = 0
AND      NVL(P.TERMS_SEQUENCE_NUMBER,TL.SEQUENCE_NUM)=TL.SEQUENCE_NUM
AND      A.CUSTOMER_TRX_ID = P.CUSTOMER_TRX_ID (+)
AND      A.PRINTING_OPTION IN (''PRI'', ''REP'')
AND      A.TERM_ID = TL.TERM_ID
AND      A.TERM_ID = T.TERM_ID
AND      L_TYPES.LOOKUP_TYPE = ''INV/CM''
AND      TYPES.CUST_TRX_TYPE_ID = A.CUST_TRX_TYPE_ID
AND      L_TYPES.LOOKUP_CODE    = DECODE( TYPES.TYPE, ''DEP'', ''INV'', TYPES.TYPE ) AND A_BILL.party_site_id = party_site.party_site_id
AND B.PARTY_ID = PARTY.PARTY_ID
AND loc.location_id = party_site.location_id';
	p_where2	varchar2(8096):= 'U_BILL.CUST_ACCT_SITE_ID = A_BILL.CUST_ACCT_SITE_ID
AND      U_BILL.SITE_USE_ID = A.BILL_TO_SITE_USE_ID
AND      A.COMPLETE_FLAG = ''Y''
AND      NVL(A.PRINTING_OPTION, ''REP'') IN (''PRI'', ''REP'')
AND      A.BILL_TO_CUSTOMER_ID = B.CUST_ACCOUNT_ID
AND      T.PRINTING_LEAD_DAYS   > 0
AND      T.TERM_ID              = A.TERM_ID
AND      A.CUSTOMER_TRX_ID      = P.CUSTOMER_TRX_ID
AND      L_TYPES.LOOKUP_TYPE    = ''INV/CM''
AND      TYPES.CUST_TRX_TYPE_ID = A.CUST_TRX_TYPE_ID
AND      L_TYPES.LOOKUP_CODE    = DECODE( TYPES.TYPE, ''DEP'', ''INV'', TYPES.TYPE ) AND A_BILL.party_site_id = party_site.party_site_id
AND B.PARTY_ID = PARTY.PARTY_ID
AND loc.location_id = party_site.location_id';
	P_table1	varchar2(8096):='AR_ADJUSTMENTS   COM_ADJ,  AR_PAYMENT_SCHEDULES    P,
	RA_CUST_TRX_LINE_GL_DIST     REC, RA_CUSTOMER_TRX     A,  HZ_CUST_ACCOUNTS    B,
	RA_TERMS    T, RA_TERMS_LINES    TL, RA_CUST_TRX_TYPES    TYPES, AR_LOOKUPS    L_TYPES,
	HZ_PARTIES     PARTY,   HZ_CUST_ACCT_SITES   A_BILL,  HZ_PARTY_SITES    PARTY_SITE,
	HZ_LOCATIONS  LOC, HZ_CUST_SITE_USES   U_BILL';
	P_table2	varchar2(8096):='RA_TERMS_LINES    TL,
	RA_CUST_TRX_TYPES    TYPES, AR_LOOKUPS    L_TYPES,
	HZ_CUST_ACCOUNTS    B, HZ_PARTIES   PARTY, HZ_CUST_SITE_USES   U_BILL,
	HZ_CUST_ACCT_SITES    A_BILL, HZ_PARTY_SITES   PARTY_SITE, HZ_LOCATIONS   LOC,
	AR_ADJUSTMENTS   COM_ADJ, RA_CUSTOMER_TRX   A, AR_PAYMENT_SCHEDULES  P, RA_TERMS   T';
	P_adj_number_low	varchar2(32767);
	P_adj_number_high	varchar2(32767);
	P_adj_dates_low	date;
	P_adj_dates_high	date;
	P_cust_trx_class	varchar2(40);
	P_CONC_REQUEST_ID	number;
	P_MIN_PRECISION	number;
	INSTALLMENT_PRINTING_PENDING	varchar2(32767);
	RP_DATA_FOUND	varchar2(100);
	RP_COMPANY_NAME	varchar2(50);
	RP_REPORT_NAME	varchar2(240);
	Print_option	varchar2(80);
	Type_id	varchar2(30);
	Customer_id	varchar2(50);
	Batch_id	varchar2(50);
	Open_Invoices	varchar2(80);
	Invoice_Dates	varchar2(50);
	Invoice_Numbers	varchar2(50);
	Functional_Currency	varchar2(15);
	function AfterPForm return boolean  ;
	function BeforeReport return boolean  ;
	function AfterReport return boolean  ;
	function installment_last_print_datefor(sequence_num in number, last_printed_sequence_num in number, printing_pending in varchar2, last_print_date in date) return date  ;
	Function INSTALLMENT_PRINTING_PENDING_p return varchar2;
	Function RP_DATA_FOUND_p return varchar2;
	Function RP_COMPANY_NAME_p return varchar2;
	Function RP_REPORT_NAME_p return varchar2;
	Function Print_option_p return varchar2;
	Function Type_id_p return varchar2;
	Function Customer_id_p return varchar2;
	Function Batch_id_p return varchar2;
	Function Open_Invoices_p return varchar2;
	Function Invoice_Dates_p return varchar2;
	Function Invoice_Numbers_p return varchar2;
	Function Functional_Currency_p return varchar2;
function D_AmountFormula return VARCHAR2;
END AR_RAXINVPR_XMLP_PKG;



/
