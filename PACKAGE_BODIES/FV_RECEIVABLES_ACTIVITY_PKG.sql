--------------------------------------------------------
--  DDL for Package Body FV_RECEIVABLES_ACTIVITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_RECEIVABLES_ACTIVITY_PKG" AS
/* $Header: FVXDCDFB.pls 120.7 2006/07/31 13:16:56 kbhatt noship $  */
--  ======================================================================
--                  Variable Naming Conventions
--  ======================================================================
--  1. Input/Output Parameter ,global variables: "vp_<Variable Name>"
--  2. Other Global Variables		  	: "vg_<Variable_Name>"
--  3. Procedure Level local variables	   	: "amt / num _<Variable_Name>"
--  4. PL/SQL Table variables               : "vt_<Variable_Name>"
--  5. User Defined Excpetions              : "e_<Exception_Name>"
--  ======================================================================
--                          Parameter Global Variable Declarations
--  ======================================================================
vp_errbuf           VARCHAR2(5000)  ;
vp_retcode          NUMBER ;
vp_sob_id           Gl_Sets_Of_Books.set_of_books_id%TYPE   ;
vp_nonfed_customer_class  ar_lookups.lookup_code%TYPE;
vp_type_of_receivable FV_RECEIVABLE_TYPES_ALL.receivable_type%TYPE ;
vp_write_off_activity_1  AR_ADJUSTMENTS_ALL.Receivables_trx_id%type;
vp_write_off_activity_2  AR_ADJUSTMENTS_ALL.Receivables_trx_id%type;
vp_write_off_activity_3  AR_ADJUSTMENTS_ALL.Receivables_trx_id%type;

--Bug 5414783
--vp_org_id	NUMBER;		-- Bug 4655467

--  ======================================================================
--                           Other Global Variable Declarations
--  ======================================================================
vg_end_date DATE;
g_module_name VARCHAR2(100);
g_as_of_date  DATE;
vl_fy_begin_date DATE;
vl_fy_end_date DATE;

TYPE g_rec_desc IS RECORD (cash_receipt_id NUMBER
                           ,amount          NUMBER
			   ,desc_type  VARCHAR2(20)) ;

TYPE g_rec_desc_type IS TABLE OF g_rec_desc
                           INDEX BY BINARY_INTEGER;

-- ------------------------------------------------------------------
--                      Procedure Main
-- ------------------------------------------------------------------
--Main procedure is called from concurrent program.
--This procedure calls all the subsequent procedures
--in the receivables activity process
-- ------------------------------------------------------------------
PROCEDURE Main(
        errbuf          OUT NOCOPY     VARCHAR2,
        retcode         OUT NOCOPY     NUMBER,
        p_set_of_books_id  NUMBER,
        p_reporting_entity_code VARCHAR2,
        p_fiscal_year NUMBER,
        p_quarter NUMBER,
        p_reported_by 		VARCHAR2,
        p_type_of_receivable VARCHAR2,
        p_write_off_activity_1 VARCHAR2,
        p_write_off_activity_2 VARCHAR2,
        p_write_off_activity_3 VARCHAR2,
        p_nonfed_customer_class VARCHAR2,
        p_footnotes VARCHAR2,
        p_preparer_name VARCHAR2,
        p_preparer_phone VARCHAR2,
        p_preparer_fax_number VARCHAR2,
        p_preparer_email VARCHAR2,
        p_supervisor_name VARCHAR2,
        p_supervisor_phone VARCHAR2,
        p_supervisor_email VARCHAR2,
        p_address_line_1 VARCHAR2,
        p_address_line_2 VARCHAR2,
        p_address_line_3 VARCHAR2,
        p_city VARCHAR2,
        p_state VARCHAR2,
        p_postal_code VARCHAR2)
IS

  l_module_name VARCHAR2(200);
BEGIN
vp_retcode := 0;
g_module_name := 'fv.plsql.fv_receivables_activity_pkg.';

l_module_name := g_module_name || 'Main';

FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
'START OF RECEIVABLES ACTIVITY MAIN PROCESS ......');

 -- Load the parameter global variables
 vp_sob_id        := p_set_of_books_id   ;
 vp_nonfed_customer_class :=  p_nonfed_customer_class;
 vp_type_of_receivable := p_type_of_receivable ;
 vp_write_off_activity_1 := p_write_off_activity_1 ;
 vp_write_off_activity_2 := p_write_off_activity_2 ;
 vp_write_off_activity_3 := p_write_off_activity_3 ;

--Bug 5414783
/*
vp_org_id:=mo_global.get_current_org_id; 	-- Bug 4655467
fnd_request.set_org_id(vp_org_id);	-- Bug 4655467
*/

 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT,
 l_module_name,' SET OF BOOKS ID IS:'||TO_CHAR(vp_sob_id));

-- Deriving the End Date for the period for which Report is being run
BEGIN
  SELECT MIN(start_date) , MAX(end_date)
  INTO   vl_fy_begin_date , vl_fy_end_date
  FROM   gl_period_statuses
  WHERE  period_year = p_fiscal_year
  AND    set_of_books_id = P_SET_OF_BOOKS_ID
  AND    application_id = '101';
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    vp_retcode := SQLCODE ;
    vp_errbuf  := SQLERRM  ||'Parameter Fiscal Year is not defined'
                           || 'for the Set of Books' ;
	errbuf := vp_errbuf;
	retcode := vp_retcode;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,l_module_name
    ||'Undefined Fiscal Year',VP_ERRBUF) ;
    RETURN ;
END;

BEGIN
 IF P_QUARTER IS NOT NULL THEN
   SELECT MAX (end_date)
   INTO  vg_end_date
   FROM  gl_period_statuses
   WHERE period_year = P_FISCAL_YEAR
   AND   set_of_books_id = vp_sob_id
   AND   application_id = '101'
   AND   quarter_num = P_QUARTER;
 ELSE
   vg_end_date := vl_fy_end_date;
 END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    vp_retcode := SQLCODE ;
    vp_errbuf  := SQLERRM  ||'Parameter Quarter is not defined.' ;
	errbuf := vp_errbuf;
	retcode := vp_retcode;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,l_module_name
    ||'Undefined Quarter',VP_ERRBUF) ;
    RETURN ;
END;
 -- If the report_by is System Date then the SYSDATE is considered as As_of_date
 -- If the report_by is Querter End Date then Querter/Year End Date is considered
 -- as As_of_Date.
 -- This g_as_of_date is used to calculate the age of the purchase
 -- invoice.
 IF p_reported_by = 'SYSDATE' THEN
 	g_as_of_date := TRUNC(sysdate);
 ELSE
 	g_as_of_date := TRUNC(vg_end_date);
 END IF;
 -- purge the temp table
 FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
    'Purging Temporary Table...') ;
 DELETE FROM fv_receivables_activity_temp;

 -- populate temp table for Part I section B and PartII SectionA and SectionB
FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
'Populating Temp Table with' ||
'Part I Section B, Part II Section A, Section B Values...') ;
Populate_IB_IIAB ();

IF vp_retcode = 0 THEN
	FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
	'Populating Temp Table with'||
	'Part I Section A and Part II Section C Values.....') ;
	Populate_IA_IIC;
END IF;


IF vp_retcode = 0 THEN
      FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
     'SUBMITTING FUNDS AVAILABILITY REPORTS .....');
  Submit_Report (p_set_of_books_id,
		p_reporting_entity_code ,
         	p_fiscal_year ,
		p_quarter ,
		p_reported_by,
		p_type_of_receivable ,
	        p_footnotes ,
		p_preparer_name ,
		p_preparer_phone ,
		p_preparer_fax_number ,
		p_preparer_email ,
		p_supervisor_name ,
		p_supervisor_phone ,
		p_supervisor_email ,
	        p_address_line_1 ,
                p_address_line_2 ,
	        p_address_line_3 ,
	        p_city ,
                p_state ,
	        p_postal_code ) ;
 END IF;

  -- Checking for errors
   IF vp_retcode <> 0 THEN
     errbuf := vp_errbuf;
     retcode := vp_retcode;
     ROLLBACK;
   ELSE
     COMMIT;
   END IF;


   FV_UTILITY.DEBUG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,
  'END THE RECEIVABLES ACTIVITY MAIN PROCESS ......');


EXCEPTION
  WHEN OTHERS THEN
    vp_retcode := SQLCODE ;
    vp_errbuf  := SQLERRM  ||' -- Error in Main procedure' ;
	errbuf := vp_errbuf;
	retcode := vp_retcode;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED,
   l_module_name||'.final_exception',VP_ERRBUF) ;
    RETURN ;
END Main;

-- ------------------------------------------------------------------
--                      Procedure  Populate_IB_IIAB
-- Procedure populate_PartISecB_PartIISecASecB is called from the
-- Main procedure.
-- This procedure populated the temp table for Report Sections
--  PartI SecB , and PartII SecA and SecB
-- ------------------------------------------------------------------

PROCEDURE Populate_IB_IIAB IS

l_module_name VARCHAR2(200);

CURSOR 	CUR_IB_IIAB IS
SELECT 	rct.customer_trx_id,
       	rct.related_customer_trx_id,
		rct.trx_date,
		aps.amount_due_original,
        aps.amount_due_remaining,
       	aps.actual_date_closed,
	    aps.due_date,
      	aps.class,
	    aps.payment_schedule_id,
		interface_header_attribute3 created_from,
      	hzp1.category_code customer_category_code
		--fvis.status
FROM   	RA_CUSTOMER_TRX_ALL rct,
		RA_CUST_TRX_LINE_GL_DIST_ALL rctlgd,
		AR_PAYMENT_SCHEDULES_ALL aps,
		--RA_CUSTOMERS  rc, Bug#4476059 Quick Change
		hz_cust_accounts hzca1,
		hz_parties hzp1,
		FV_RECEIVABLE_TYPES_ALL frt,
 		FV_REC_CUST_TRX_TYPES_ALL fctt,
		GL_CODE_COMBINATIONS glc
		--FV_INVOICE_STATUSES_ALL fvis
WHERE  	rct.customer_trx_id = rctlgd.customer_trx_id
AND    	rct.trx_date <= vg_end_date
AND 	rctlgd.account_class = 'REC'
AND 	rctlgd.set_of_books_id = vp_sob_id
AND 	aps.customer_trx_id = rct.customer_trx_id
AND 	rct.bill_to_customer_id = hzca1.cust_account_id
AND	hzca1.party_id = hzp1.party_id
AND 	rctlgd.code_combination_id = glc.code_combination_id
AND 	hzca1.customer_class_code  = vp_nonfed_customer_class
AND 	aps.class = 'INV'
AND 	frt.receivable_type_id = fctt.receivable_type_id
AND 	frt.receivable_type = vp_type_of_receivable
AND 	fctt.cust_trx_type_id = rct.cust_trx_type_id
AND	frt.SET_OF_BOOKS_ID = vp_sob_id	-- Bug 4655467
--AND	frt.org_id = vp_org_id		-- Bug 4655467
AND	rct.SET_OF_BOOKS_ID = vp_sob_id	-- Bug 4655467
--AND	rct.org_id = vp_org_id		-- Bug 4655467
--added to main query for delinquent debt 180 days or less
--AND 	aps.customer_trx_id = fvis.customer_trx_id (+)
---AND 	vg_end_date BETWEEN NVL(fvis.start_date, vg_end_date)
--added to main query for delinquent debt 180 daysorless
--AND NVL(fvis.end_date, vg_end_date)
UNION
SELECT	rct2.customer_trx_id,
        rct2.related_customer_trx_id,
		rct2.trx_date,
		aps2.amount_due_original,
        aps2.amount_due_remaining,
        aps2.actual_date_closed,
        aps2.due_date,
        aps2.class,
        aps2.payment_schedule_id,
		rct2.interface_header_attribute3 created_from,
        hzp2.category_code customer_category_code
--		fvis.status
FROM   	RA_CUSTOMER_TRX_ALL rct2,
		AR_PAYMENT_SCHEDULES_ALL aps2,
        --RA_CUSTOMERS rc2           Bug#4476059 Quick Change
		hz_cust_accounts hzca2,
		hz_parties hzp2
--		FV_INVOICE_STATUSES_ALL fvis
where aps2.class in ('DM','CM')
and hzca2.cust_account_id = rct2.bill_to_customer_id
and hzca2.party_id = hzp2.party_id
and rct2.customer_trx_id = aps2.customer_trx_id
and rct2.SET_OF_BOOKS_ID = vp_sob_id	-- Bug 4655467
--and rct2.org_id = vp_org_id		-- Bug 4655467
--added to main query for delinquent debt 180 days or less
--and aps2.customer_trx_id = fvis.customer_trx_id (+)
and rct2.related_customer_trx_id in
	(Select rct3.customer_trx_id
     from   RA_CUSTOMER_TRX_ALL rct3,
            RA_CUST_TRX_LINE_GL_DIST_ALL rctlgd3,
 			--RA_CUSTOMERS  rc3,-- Bug#4476059 Quick Change
			hz_cust_accounts hzca3,
			hz_parties hzp3,
			AR_PAYMENT_SCHEDULES_ALL aps3,
			FV_RECEIVABLE_TYPES_ALL frt3,
			FV_REC_CUST_TRX_TYPES_ALL fctt3,
		--	FV_FUND_PARAMETERS fp3,		-- Bug 4655467
		--	FV_TREASURY_SYMBOLS  fts3,	-- Bug 4655467
			GL_CODE_COMBINATIONS glc3
  where  rct3.customer_trx_id = rctlgd3.customer_trx_id
  and      rct3.trx_date <= vg_end_date
  and rctlgd3.account_class ='REC'
  and rctlgd3.set_of_books_id = vp_sob_id
  and frt3.SET_OF_BOOKS_ID = vp_sob_id	-- Bug 4655467
--  and frt3.org_id = vp_org_id		-- Bug 4655467
  and rct3.SET_OF_BOOKS_ID = vp_sob_id	-- Bug 4655467
--  and rct3.org_id = vp_org_id		-- Bug 4655467
  and aps3.customer_trx_id = rct3.customer_trx_id
  and rct3.bill_to_customer_id = hzca3.cust_account_id
  and hzca3.party_id = hzp3.party_id
  and rctlgd3.code_combination_id = glc3.code_combination_id
  and hzca3.customer_class_code  =  vp_nonfed_customer_class
  and aps3.class = 'INV'
  and frt3.receivable_type = vp_type_of_receivable
  and frt3.receivable_type_id = fctt3.receivable_type_id
  and fctt3.cust_trx_type_id = rct3.cust_trx_type_id);
--  AND 	vg_end_date BETWEEN NVL(fvis.start_date, vg_end_date)
 --added to main query for delinquent debt 180 days or less;
 ---AND NVL(fvis.end_date, vg_end_date) ;

  CURSOR  CUR_INV_STATUS( p_customer_trx_id NUMBER ) IS
  SELECT status
  FROM   ra_customer_trx_all rct , fv_invoice_statuses_all fvis
  WHERE  rct.customer_trx_id = P_customer_trx_id
  AND    fvis.customer_trx_id = rct.customer_trx_id
  AND    vg_end_date  BETWEEN NVL(fvis.start_date,vg_end_date)
                AND NVL(fvis.end_date,vg_end_date);

amt_tot_delinq_bankruptcy  NUMBER ;
amt_tot_delinq_foreclosure NUMBER ;
amt_tot_delinq_forbearance NUMBER ;
amt_tot_delinq_collection  NUMBER ;
amt_tot_delinq_litigation  NUMBER ;
amt_tot_delinq_internal_offset NUMBER ;
amt_tot_delinq_garnishment 	 NUMBER ;
amt_tot_delinq_cross 		 NUMBER ;
amt_tot_delinq_treasury_offset NUMBER ;
amt_tot_delinq_agency 	       NUMBER ;
amt_tot_delinq_other 	       NUMBER ;

num_tot_delinq_bankruptcy  NUMBER ;
num_tot_delinq_foreclosure NUMBER ;
num_tot_delinq_forbearance NUMBER ;
num_tot_delinq_collection  NUMBER ;
num_tot_delinq_litigation  NUMBER ;
num_tot_delinq_internal_offset NUMBER ;
num_tot_delinq_garnishment 	 NUMBER ;
num_tot_delinq_cross 	       NUMBER ;
num_tot_delinq_treasury_offset NUMBER ;
num_tot_delinq_agency 		 NUMBER ;
num_tot_delinq_other 		 NUMBER ;

-- Part II Section A
amt_delinq_2A_tot NUMBER;
num_delinq_2A_tot NUMBER;
amt_delinq_1A NUMBER ;
amt_delinq_1B NUMBER ;
amt_delinq_1C NUMBER ;
amt_delinq_1D NUMBER ;
amt_delinq_1E NUMBER ;
amt_delinq_1F NUMBER ;
amt_delinq_1G NUMBER ;
amt_delinq_commercial NUMBER ;
amt_delinq_consumer   NUMBER ;
amt_delinq_forgn_sovrn NUMBER ;

num_delinq_1A NUMBER ;
num_delinq_1B NUMBER ;
num_delinq_1C NUMBER ;
num_delinq_1D NUMBER ;
num_delinq_1E NUMBER ;
num_delinq_1F NUMBER ;
num_delinq_1G NUMBER ;
num_delinq_commercial NUMBER ;
num_delinq_consumer   NUMBER ;
num_delinq_forgn_sovrn NUMBER ;

--Part II , Section B
amt_debt_eligible_180_10 NUMBER ;
amt_debt_eligible_bankruptcy  NUMBER ;
amt_debt_eligible_foreign  NUMBER ;
amt_debt_eligible_forbearance  NUMBER ;
amt_debt_eligible_foreclosure  NUMBER ;
amt_debt_eligible_other  NUMBER ;
amt_debt_eligible_collection  NUMBER ;
amt_debt_eligible_litigation  NUMBER ;
amt_debt_eligible_int_offset  NUMBER ;
amt_debt_eligible_offset  NUMBER ;
amt_debt_eligible_X_servicing NUMBER ;

num_debt_eligible_180_10 NUMBER ;
num_debt_eligible_bankruptcy  NUMBER ;
num_debt_eligible_foreign  NUMBER ;
num_debt_eligible_forbearance  NUMBER ;
num_debt_eligible_foreclosure  NUMBER ;
num_debt_eligible_other  NUMBER ;
num_debt_eligible_collection  NUMBER ;
num_debt_eligible_litigation  NUMBER ;
num_debt_eligible_int_offset  NUMBER ;
num_debt_eligible_offset  NUMBER ;
num_debt_eligible_X_servicing NUMBER ;

l_dm_status fv_invoice_statuses_all.status%TYPE ;
l_pay_schedule_id NUMBER;
l_dm_due_date  DATE;
l_count NUMBER ;
l_customer_trx_id NUMBER;

IA_increment NUMBER;
IIA_Increment NUMBER ;
IIB1_Increment NUMBER  ;
IIB2_Increment NUMBER;

BEGIN

--initialize
l_dm_status := '';
l_module_name := g_module_name || 'Populate_IB_IIAB' ;
amt_tot_delinq_bankruptcy   := 0 ;
amt_tot_delinq_foreclosure  := 0 ;
amt_tot_delinq_forbearance  := 0 ;
amt_tot_delinq_collection   := 0 ;
amt_tot_delinq_litigation   := 0 ;
amt_tot_delinq_internal_offset  := 0 ;
amt_tot_delinq_garnishment 	  := 0 ;
amt_tot_delinq_cross 		  := 0 ;
amt_tot_delinq_treasury_offset  := 0 ;
amt_tot_delinq_agency 	        := 0 ;
amt_tot_delinq_other 	        := 0 ;

num_tot_delinq_bankruptcy   := 0 ;
num_tot_delinq_foreclosure  := 0 ;
num_tot_delinq_forbearance  := 0 ;
num_tot_delinq_collection   := 0 ;
num_tot_delinq_litigation   := 0 ;
num_tot_delinq_internal_offset  := 0 ;
num_tot_delinq_garnishment 	  := 0 ;
num_tot_delinq_cross 	        := 0 ;
num_tot_delinq_treasury_offset  := 0 ;
num_tot_delinq_agency 		  := 0 ;
num_tot_delinq_other 		  := 0 ;

-- Part II Section A
amt_delinq_2A_tot := 0;
amt_delinq_1A  := 0 ;
amt_delinq_1B  := 0 ;
amt_delinq_1C  := 0 ;
amt_delinq_1D  := 0 ;
amt_delinq_1E  := 0 ;
amt_delinq_1F  := 0 ;
amt_delinq_1G  := 0 ;
amt_delinq_commercial  := 0 ;
amt_delinq_consumer    := 0 ;
amt_delinq_forgn_sovrn  := 0 ;

num_delinq_2A_tot := 0;
num_delinq_1A  := 0 ;
num_delinq_1B  := 0 ;
num_delinq_1C  := 0 ;
num_delinq_1D  := 0 ;
num_delinq_1E  := 0 ;
num_delinq_1F  := 0 ;
num_delinq_1G  := 0 ;
num_delinq_commercial  := 0 ;
num_delinq_consumer    := 0 ;
num_delinq_forgn_sovrn  := 0 ;

--Part II , Section B
amt_debt_eligible_180_10  := 0 ;
amt_debt_eligible_bankruptcy   := 0 ;
amt_debt_eligible_foreign   := 0 ;
amt_debt_eligible_forbearance   := 0 ;
amt_debt_eligible_foreclosure   := 0 ;
amt_debt_eligible_other   := 0 ;
amt_debt_eligible_collection   := 0 ;
amt_debt_eligible_litigation   := 0 ;
amt_debt_eligible_int_offset   := 0 ;
amt_debt_eligible_offset   := 0 ;
amt_debt_eligible_X_servicing  := 0 ;

num_debt_eligible_180_10  := 0 ;
num_debt_eligible_bankruptcy   := 0 ;
num_debt_eligible_foreign   := 0 ;
num_debt_eligible_forbearance   := 0 ;
num_debt_eligible_foreclosure   := 0 ;
num_debt_eligible_other   := 0 ;
num_debt_eligible_collection   := 0 ;
num_debt_eligible_litigation   := 0 ;
num_debt_eligible_int_offset   := 0 ;
num_debt_eligible_offset   := 0 ;
num_debt_eligible_X_servicing  := 0 ;

l_dm_status  := '' ;
l_pay_schedule_id := 0;
l_count  := 0 ;

IA_increment := 0;
IIA_Increment  := 0 ;
IIB1_Increment := 0  ;
IIB2_Increment := 0;



FOR recs IN CUR_IB_IIAB

LOOP


-- id will never be -99 so comparisions down
-- the line will definitely fail if class is not INV
l_pay_schedule_id := -99 ;

-- Part I Section B, 'Delinquent Debt by Age'
-- Initialize the Due Date for 'INV'
l_dm_due_date := recs.due_date;
IF recs.class = 'DM' and recs.related_customer_trx_id IS NOT NULL then
  SELECT nvl(min(due_date),recs.due_date)
  INTO   l_dm_due_date
  FROM   ar_payment_schedules_all a
  WHERE  a.customer_trx_id = recs.related_customer_trx_id
  AND    amount_due_remaining > 0;
ELSIF  recs.class = 'INV' AND recs.amount_due_remaining > 0 THEN
  SELECT MIN(payment_schedule_id)
  INTO   l_pay_schedule_id
  FROM   ar_payment_schedules_all a
  WHERE  a.customer_trx_id = recs.customer_trx_id;
END IF;

IF recs.payment_schedule_id = l_pay_schedule_id THEN
  IA_increment := 1 ;
ELSE
  IA_increment := 0 ;
END IF;

--amt* variables are the corresponding Dolalr amount
--num* variables are the corresponding Number/ Count

IF
trunc(g_as_of_date) between trunc(l_dm_due_date)+1 and trunc(l_dm_due_date)+90 then
  amt_delinq_1A := amt_delinq_1A + recs.amount_due_remaining;
  num_delinq_1A := num_delinq_1A + IA_increment ;
ELSIF
 trunc(g_as_of_date) between trunc(l_dm_due_date)+91 and trunc(l_dm_due_date)+180
then
	amt_delinq_1B := amt_delinq_1B + recs.amount_due_remaining;
	num_delinq_1B := num_delinq_1B + IA_increment ;
ELSIF
trunc(g_as_of_date) between trunc(l_dm_due_date)+181 and trunc(l_dm_due_date)+365
then
	amt_delinq_1C := amt_delinq_1C + recs.amount_due_remaining;
	num_delinq_1C := num_delinq_1C + IA_increment ;
ELSIF
trunc(g_as_of_date) between trunc(l_dm_due_date)+366 and trunc(l_dm_due_date)+730
then
	amt_delinq_1D := amt_delinq_1D + recs.amount_due_remaining;
	num_delinq_1D := num_delinq_1D + IA_increment ;
ELSIF
trunc(g_as_of_date) between trunc(l_dm_due_date)+731 and trunc(l_dm_due_date)+2190
then
	amt_delinq_1E := amt_delinq_1E + recs.amount_due_remaining;
	num_delinq_1E := num_delinq_1E + IA_increment ;
ELSIF
trunc(g_as_of_date) between trunc(l_dm_due_date)+2191 and trunc(l_dm_due_date)+3650
THEN
	amt_delinq_1F := amt_delinq_1F + recs.amount_due_remaining;
	num_delinq_1F := num_delinq_1F + IA_increment ;
ELSIF
	trunc(g_as_of_date) > trunc(l_dm_due_date)+3650 THEN
	amt_delinq_1G := amt_delinq_1G + recs.amount_due_remaining;
	num_delinq_1G := num_delinq_1G + IA_increment ;
END IF;

IF trunc(g_as_of_date) > trunc(l_dm_due_date) THEN
  IF upper(recs.customer_category_code) = 'COMMERCIAL' THEN
    amt_delinq_commercial := amt_delinq_commercial + recs.amount_due_remaining;
    num_delinq_commercial := num_delinq_commercial + IA_increment ;
  ELSIF upper(recs.customer_category_code) = 'CONSUMER'    THEN
    amt_delinq_consumer := amt_delinq_consumer + recs.amount_due_remaining;
    num_delinq_consumer := num_delinq_consumer + IA_increment ;
  ELSIF upper(recs.customer_category_code) = 'FORGN_SOVRN' THEN
    amt_delinq_forgn_sovrn := amt_delinq_forgn_sovrn +
                              recs.amount_due_remaining;
    num_delinq_forgn_sovrn := num_delinq_forgn_sovrn + IA_increment ;
  END IF;
END IF;

--Part II Section A, Delinquent Debt 180 Days or Less
--l_dm_status := recs.status ;
l_count := 0 ;
l_pay_schedule_id := 0;

IF (recs.class <> 'INV' ) then

-- Getting the STATUS of the Parent Invoice if the
--current record is not class 'INV'
BEGIN
   -- this is to pick on the status that falls within the
   -- period for which the report is running for.
   SELECT  related_customer_trx_id
    INTO   l_customer_trx_id
    FROM   ra_customer_trx_all rct
    WHERE  rct.customer_trx_id = recs.customer_trx_id
    AND    rct.SET_OF_BOOKS_ID = vp_sob_id;		-- Bug 4655467
--    AND    rct.org_id = vp_org_id   ;		-- Bug 4655467
EXCEPTION
   -- when no data found - no action needed because l_dm_status
   -- will be NULL and it will fall thru the logic below
	WHEN NO_DATA_FOUND THEN
          NULL;
END;
ELSE
   l_customer_trx_id := recs.customer_trx_id;
END IF;


 -- Checking if the current invoice has not been crossed
IF (recs.class = 'INV' ) then
BEGIN
     SELECT  count(*)
	 INTO l_count
	 FROM  fv_invoice_statuses_all fvis
     WHERE fvis.customer_trx_id = recs.customer_trx_id
     AND   fvis.status = 'CROSS';
--AND    l_end_date  BETWEEN fvis.start_date AND fvis.end_date;
-- may need to add above check in case a bug is logged .

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		null;
END;
End IF;



SELECT min(payment_schedule_id)
INTO   l_pay_schedule_id
FROM   ar_payment_schedules_all
WHERE  customer_trx_id = recs.customer_trx_id
AND    amount_due_remaining > 0;

IF recs.payment_schedule_id = l_pay_schedule_id THEN
	IIA_Increment := 1 ;
ELSE
	IIA_Increment := 0 ;
END IF;

IF trunc(g_as_of_date) between trunc(recs.due_date)+1 and
		trunc(recs.due_date)+180 THEN
  amt_delinq_2A_tot :=  amt_delinq_2A_tot +  recs.amount_due_remaining;
  num_delinq_2A_tot :=  num_delinq_2A_tot + IIA_Increment ;
END IF;



-- Begin Calculation Part II Section A
IF trunc(g_as_of_date) between trunc(recs.due_date)+1 and trunc(recs.due_date)+180
   and l_count = 0 THEN  ----  and l_dm_status IS NOT NULL then
   -- Part II Sec A 1A

FOR inv_stat_rec IN CUR_INV_STATUS( l_customer_trx_id )

LOOP
   l_dm_status := inv_stat_rec.status ;
   IF l_dm_status = 'BANKRUPTCY'   	  	THEN
     amt_tot_delinq_bankruptcy :=
     amt_tot_delinq_bankruptcy + recs.amount_due_remaining;
     num_tot_delinq_bankruptcy := num_tot_delinq_bankruptcy + IIA_Increment ;
   -- Part II Sec A 1B
   ELSIF l_dm_status = 'FORBEARANCE'   	THEN
    amt_tot_delinq_forbearance :=
	amt_tot_delinq_forbearance + recs.amount_due_remaining;
    num_tot_delinq_forbearance := num_tot_delinq_forbearance + IIA_Increment ;
   -- Part II Sec A 1C
   ELSIF l_dm_status = 'FORECLOSURE'  	THEN
    amt_tot_delinq_foreclosure :=
  	amt_tot_delinq_foreclosure + recs.amount_due_remaining;
    num_tot_delinq_foreclosure := num_tot_delinq_foreclosure + IIA_Increment ;
   -- Part II Sec A 1D
  ELSIF l_dm_status = 'COLLECTION'    	THEN
    amt_tot_delinq_collection :=
  	amt_tot_delinq_collection + recs.amount_due_remaining;
  	num_tot_delinq_collection := num_tot_delinq_collection + IIA_Increment ;
   -- Part II Sec A 1E
   ELSIF l_dm_status = 'LITIGATION'   	THEN
    amt_tot_delinq_litigation :=
  	amt_tot_delinq_litigation + recs.amount_due_remaining;
  	num_tot_delinq_litigation := num_tot_delinq_litigation + IIA_Increment ;
   -- Part II Sec A 1F
   ELSIF l_dm_status = 'INTERNAL_OFFSET'THEN
    amt_tot_delinq_internal_offset :=
    amt_tot_delinq_internal_offset + recs.amount_due_remaining;
 	num_tot_delinq_internal_offset := num_tot_delinq_internal_offset
 	                                  + IIA_Increment ;
   -- Part II Sec A 1G
   ELSIF l_dm_status = 'GARNISHMENT' 	 THEN
    amt_tot_delinq_garnishment :=
  	amt_tot_delinq_garnishment + recs.amount_due_remaining;
    num_tot_delinq_garnishment := num_tot_delinq_garnishment + IIA_Increment ;
   -- Part II Sec A 1H
   ELSIF l_dm_status = 'CROSS' 		   	 THEN
    amt_tot_delinq_cross :=
	amt_tot_delinq_cross + recs.amount_due_remaining;
  	num_tot_delinq_cross := num_tot_delinq_cross + IIA_Increment ;
   -- above condition is not generally possible because
   --we never enter the If End if Construct when
   -- the status is 'cross' (v_count = 0)

   -- Part II Sec A 1I
   ELSIF l_dm_status = 'TREASURY_OFFSET' THEN
    amt_tot_delinq_treasury_offset :=  amt_tot_delinq_treasury_offset +
                                       recs.amount_due_remaining;
	num_tot_delinq_treasury_offset :=  num_tot_delinq_treasury_offset +
	                                   IIA_Increment ;
   -- Part II Sec A 1J
   ELSIF l_dm_status = 'AGENCY'   		 THEN
    amt_tot_delinq_agency :=       	   amt_tot_delinq_agency +
                                       recs.amount_due_remaining;
  	num_tot_delinq_agency :=		   num_tot_delinq_agency +
  	                                   IIA_Increment ;
   -- Part II Sec A 1K
   ELSIF l_dm_status = 'OTHER' 	  		 THEN
    amt_tot_delinq_other :=    		   amt_tot_delinq_other +
      recs.amount_due_remaining;
    num_tot_delinq_other :=		       num_tot_delinq_other +
					   IIA_Increment ;
   END IF;
  END LOOP;
END IF; -- End Calculation Part II Section A

-- Begin Calculation Part II Section B
IF trunc(g_as_of_date) between trunc(recs.due_date)+181
   and trunc(recs.due_date)+3650  THEN
   --and l_dm_status IS NOT NULL then

IF recs.payment_schedule_id = l_pay_schedule_id and recs.class = 'INV' THEN
  IIB1_Increment := -1 ;
ELSE
  IIB1_Increment :=  0 ;
END IF ;

IF recs.payment_schedule_id = l_pay_schedule_id THEN
  IIB2_Increment := -1 ;
ELSE
  IIB2_Increment :=  0 ;
END IF ;

   -- Part II Sec B 1A
   amt_debt_eligible_180_10 :=   amt_debt_eligible_180_10 -
		recs.amount_due_remaining  ;
   num_debt_eligible_180_10 := num_debt_eligible_180_10 + IIB1_Increment  ;


FOR inv_stat_rec IN CUR_INV_STATUS(  l_customer_trx_id )

LOOP

   l_dm_status :=  inv_stat_rec.status;
   -- Part II Sec B 1B
   IF l_dm_status = 'BANKRUPTCY'    THEN
   	   amt_debt_eligible_bankruptcy :=  amt_debt_eligible_bankruptcy -
   						recs.amount_due_remaining ;
   	   num_debt_eligible_bankruptcy :=	num_debt_eligible_bankruptcy
   							+ IIB1_Increment  ;
   -- Part II Sec B 1C
   ELSIF l_dm_status = 'FOREIGN'  	THEN
   	  amt_debt_eligible_foreign := amt_debt_eligible_foreign -
   					recs.amount_due_remaining  ;
  	  num_debt_eligible_foreign := num_debt_eligible_foreign
  					+ IIB1_Increment ;
   -- Part II Sec B 1D
   ELSIF l_dm_status = 'FORBEARANCE' THEN
      amt_debt_eligible_forbearance := amt_debt_eligible_forbearance -
      					recs.amount_due_remaining ;
	num_debt_eligible_forbearance := num_debt_eligible_forbearance
          				+ IIB1_Increment  ;
   -- Part II Sec B 1E
   ELSIF l_dm_status = 'FORECLOSURE' THEN
      amt_debt_eligible_foreclosure := amt_debt_eligible_foreclosure -
      					recs.amount_due_remaining ;
      num_debt_eligible_foreclosure := num_debt_eligible_foreclosure
      					+ IIB1_Increment  ;
   -- Part II Sec B 1F AND Part II Sec B 2E
   -- Part II sec B 1F and 2E are the same values
   ELSIF l_dm_status = 'OTHER' 	  THEN
      amt_debt_eligible_other := amt_debt_eligible_other -
      				recs.amount_due_remaining ;
      num_debt_eligible_other := num_debt_eligible_other
      				+ IIB1_Increment  ;
   -- Part II Sec B 2B
   ELSIF l_dm_status = 'COLLECTION'	 THEN
      amt_debt_eligible_collection := amt_debt_eligible_collection -
      					recs.amount_due_remaining ;
	num_debt_eligible_collection :=	  num_debt_eligible_collection
				+ IIB2_Increment   ;
   -- Part II Sec B 2C
   ELSIF l_dm_status = 'LITIGATION'		 THEN
      amt_debt_eligible_litigation := amt_debt_eligible_litigation -
      					recs.amount_due_remaining ;
      num_debt_eligible_litigation := num_debt_eligible_litigation
      				 + IIB2_Increment   ;
   -- Part II Sec B 2D
   ELSIF l_dm_status = 'INTERNAL_OFFSET' THEN
      amt_debt_eligible_int_offset := amt_debt_eligible_int_offset -
      				   recs.amount_due_remaining ;
      num_debt_eligible_int_offset := num_debt_eligible_int_offset
      					+ IIB2_Increment   ;
   END IF;
END LOOP;
END IF; -- End Calculation Part II Section B
END LOOP; -- recs.traversal
--Part II Sec B 1G = Part II Sec B 2A in both Dollar Amt and Number
-- Part II Sec B 1G
-- Part II Sec B 2A
amt_debt_eligible_offset :=    		 amt_debt_eligible_180_10 +
   		  	  		 amt_debt_eligible_bankruptcy +
					 amt_debt_eligible_foreign +
					 amt_debt_eligible_forbearance +
					 amt_debt_eligible_foreclosure +
					 amt_debt_eligible_other ;

num_debt_eligible_offset :=    		 num_debt_eligible_180_10 +
   		  	  		 num_debt_eligible_bankruptcy +
					 num_debt_eligible_foreign +
					 num_debt_eligible_forbearance +
					 num_debt_eligible_foreclosure +
					 num_debt_eligible_other ;
-- Part II Sec B 2F
amt_debt_eligible_X_servicing := amt_debt_eligible_offset +
			  	 amt_debt_eligible_collection +
				 amt_debt_eligible_litigation +
				 amt_debt_eligible_int_offset +
				 amt_debt_eligible_other ;

num_debt_eligible_X_servicing := num_debt_eligible_offset +
			  	 num_debt_eligible_collection +
				 num_debt_eligible_litigation +
				 num_debt_eligible_int_offset +
				 num_debt_eligible_other ;


--==========================================================================
-- Populating Lines for Part I Section B
--==========================================================================
insert_row('1B01',  'Section B' ,NULL ,NULL) ;
insert_row('1B02',  'Delinquent Debt by Age' ,NULL ,NULL) ;
insert_row('1B03','LINE' ,NULL ,NULL) ;
insert_row('1B1',   '(1) Total Delinquencies',NULL ,NULL);
insert_row('1B1A',  '  (A) 1-90 Days',    num_delinq_1A , amt_delinq_1A);
insert_row('1B1B',  '  (B) 91-180 Days',  num_delinq_1B , amt_delinq_1B);
insert_row('1B1C',  '  (C) 181-365 Days', num_delinq_1C , amt_delinq_1C);
insert_row('1B1D',  '  (D) 1-2 Years',    num_delinq_1D , amt_delinq_1D);
insert_row('1B1E',  '  (E) 2-6 Years',    num_delinq_1E , amt_delinq_1E);
insert_row('1B1F',  '  (F) 6-10 Years',   num_delinq_1F , amt_delinq_1F);
insert_row('1B1G',  '  (G) Over 10 Years',num_delinq_1G , amt_delinq_1G);
insert_row('1B2',   '(2) Commercial',   num_delinq_commercial,
	           			amt_delinq_commercial);
insert_row('1B3',   '(3) Consumer',     num_delinq_consumer,
					amt_delinq_consumer);
insert_row('1B4',   '(4) Foreign/Sovereign Debt' ,   num_delinq_forgn_sovrn ,
  						     amt_delinq_forgn_sovrn);
-- Dummy Lines for Page Break on the Report.
insert_row('1B411',  '' ,NULL ,NULL);
insert_row('1B412',  '' ,NULL ,NULL);
insert_row('1B413',  '' ,NULL ,NULL);
insert_row('1B414',  '' ,NULL ,NULL);
insert_row('1B415',  '' ,NULL ,NULL);
insert_row('1B416',  '' ,NULL ,NULL);
insert_row('1B417',  '' ,NULL ,NULL);
insert_row('1B418',  '' ,NULL ,NULL);
insert_row('1B419',  '' ,NULL ,NULL);
insert_row('1B420',  '' ,NULL ,NULL);
insert_row('1B421',  '' ,NULL ,NULL);
--==========================================================================
-- Populating Lines for Part II Section A
--==========================================================================
insert_row('2011','LINE' ,NULL ,NULL) ;
insert_row('2012','Part II - Debt Management Tool and Technique',NULL,NULL);
insert_row('2013','          Performance Data ' ,NULL ,NULL) ;
insert_row('2014','LINE' ,NULL ,NULL) ;
insert_row('2A01','Section A' ,NULL ,NULL) ;
insert_row('2A02','Delinquent Debt 180 Days or Less',NULL ,NULL);

insert_row('2A03','LINE' ,NULL ,NULL) ;
insert_row('2A1', '(1) Total Delinquencies 1 - 180 Days',num_delinq_2A_tot ,
                        amt_delinq_2A_tot ) ;
insert_row('2A1A','  (A) In Bankruptcy',  num_tot_delinq_bankruptcy ,
                                          amt_tot_delinq_bankruptcy);
insert_row('2A1B','  (B) In Forbearance or In Formal Appeals Process',
num_tot_delinq_forbearance ,amt_tot_delinq_forbearance);
insert_row('2A1C','  (C) In Foreclosure',
num_tot_delinq_foreclosure ,amt_tot_delinq_foreclosure);
insert_row('2A1D','  (D) At Private Collection Agencies',
num_tot_delinq_collection ,amt_tot_delinq_collection);
insert_row('2A1E','  (E) In Litigation',
num_tot_delinq_litigation ,amt_tot_delinq_litigation);
insert_row('2A1F','  (F) Eligible for Internal Offset',
num_tot_delinq_internal_offset ,amt_tot_delinq_internal_offset);
insert_row('2A1G','  (G) In Wage Garnishment',
num_tot_delinq_garnishment ,amt_tot_delinq_garnishment);
insert_row('2A1H','  (H) At Treasury for Cross Servicing',
num_tot_delinq_cross ,amt_tot_delinq_cross);
insert_row('2A1I','  (I) At Treasury for Offset',
num_tot_delinq_treasury_offset ,amt_tot_delinq_treasury_offset);
insert_row('2A1J','  (J) At Agency',
num_tot_delinq_agency ,amt_tot_delinq_agency);
insert_row('2A1K','  (K) Other - must footnote',
num_tot_delinq_other ,amt_tot_delinq_other);

--==========================================================================
-- Populating Lines for Part II Section B
--==========================================================================
insert_row('2B01','LINE' ,NULL ,NULL) ;
insert_row('2B02','Section B' ,NULL ,NULL) ;
insert_row('2B03','Debt Eligible for Referral to Treasury for' ,NULL ,NULL) ;
insert_row('2B04','Offset and Cross-Servicing' ,NULL ,NULL) ;
insert_row('2B05','LINE' ,NULL ,NULL) ;
insert_row('2B11', '(1) Debt Eligible for Referral to Treasury' ,NULL ,NULL) ;
insert_row('2B12', '    for Offset' ,NULL ,NULL) ;
insert_row('2B1A', '  (A) Delinquent Debt Over 180 Days to 10 Years' ,
num_debt_eligible_180_10 ,amt_debt_eligible_180_10) ;
insert_row('2B1B', '  (B) In Bankruptcy (-)' ,
num_debt_eligible_bankruptcy ,amt_debt_eligible_bankruptcy) ;
insert_row('2B1C', '  (C) Foreign/Sovereign Debt (-)' ,
num_debt_eligible_foreign ,amt_debt_eligible_foreign) ;
insert_row('2B1D', '  (D) In Forbearance or Formal Appeals Process(-)' ,
num_debt_eligible_forbearance ,amt_debt_eligible_forbearance) ;
insert_row('2B1E', '  (E) In Foreclosure (-)' ,
num_debt_eligible_foreclosure ,amt_debt_eligible_foreclosure) ;
insert_row('2B1F', '  (F) Other - must footnote (+ or -)' ,
num_debt_eligible_other ,amt_debt_eligible_other) ;
insert_row('2B1G1','  (G) Debt Eligible for Referral to Treasury' ,
num_debt_eligible_offset ,amt_debt_eligible_offset) ;
insert_row('2B1G2','      for Offset' ,NULL, NULL) ;
insert_row('2B21', '(2) Debt Eligible for Referral to Treasury or a ' ,
NULL ,NULL) ;
insert_row('2B22', '    Designated Debt Collection Center for' ,NULL ,NULL) ;
insert_row('2B23', '    Cross-Servicing' ,NULL ,NULL) ;
insert_row('2B2A1','  (A) Debt Eligible for Referral to Treasury' ,
num_debt_eligible_offset ,amt_debt_eligible_offset) ;
insert_row('2B2A2','      for Offset' ,NULL,NULL) ;
insert_row('2B2B', '  (B) At PCAs (-)' ,num_debt_eligible_collection ,
                                        amt_debt_eligible_collection) ;
insert_row('2B2C', '  (C) In Litigation(-)' ,num_debt_eligible_litigation ,
                                             amt_debt_eligible_litigation) ;
insert_row('2B2D', '  (D) Eligible for Internal Offset (-)' ,
num_debt_eligible_int_offset ,amt_debt_eligible_int_offset) ;
insert_row('2B2E', '  (E) Other - must footnote (+ or -)' ,
num_debt_eligible_other ,amt_debt_eligible_other) ;
insert_row('2B2F1','  (F) Debt Eligible for Referral to Treasury or a ' ,
num_debt_eligible_X_servicing ,amt_debt_eligible_X_servicing) ;
insert_row('2B2F2','      Designated Debt Collection Center for' ,NULL ,NULL) ;
insert_row('2B2F3','      Cross-Servicing' ,NULL ,NULL) ;


EXCEPTION
  WHEN OTHERS THEN

    vp_retcode := SQLCODE;
    vp_errbuf  := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||
    '.final_exception',vp_errbuf) ;
    RAISE;

END  Populate_IB_IIAB ;


-- ------------------------------------------------------------------
--                      Procedure  Populate_IA_IIC
-- Procedure populate_IA_IIC is called from the
-- Main procedure. This procedure populates the temp table
-- for Report Sections  PartI SecA and PartII Sec B
-- ------------------------------------------------------------------

PROCEDURE Populate_IA_IIC IS

l_module_name VARCHAR2(200);

CURSOR 	CUR_IA IS
SELECT 	rct.customer_trx_id,
            rct.related_customer_trx_id,
		rct.trx_date,
		aps.amount_due_original,
        aps.amount_due_remaining,
        aps.actual_date_closed,
        aps.due_date,
        aps.class,
        aps.payment_schedule_id,
		rct.interface_header_attribute3 created_from,
        hzp1.category_code customer_category_code
FROM	RA_CUSTOMER_TRX_ALL rct,
		RA_CUST_TRX_LINE_GL_DIST_ALL rctlgd,
		AR_PAYMENT_SCHEDULES_ALL aps,
		--RA_CUSTOMERS  rc, --Bug#4476059 Quick Change
		hz_cust_accounts hzca1,
		hz_parties hzp1,
		FV_RECEIVABLE_TYPES_ALL frt,
        FV_REC_CUST_TRX_TYPES_ALL fctt,
	--	FV_FUND_PARAMETERS fp,		-- Bug 4655467
		GL_CODE_COMBINATIONS glc
	--	FV_TREASURY_SYMBOLS fts		-- Bug 4655467
WHERE 	rct.customer_trx_id = rctlgd.customer_trx_id
AND    	rct.trx_date <= vg_end_date
AND     rctlgd.account_class ='REC'
AND 	rctlgd.set_of_books_id = vp_sob_id
AND     aps.customer_trx_id = rct.customer_trx_id
AND     rct.bill_to_customer_id = hzca1.cust_account_id
AND	hzca1.party_id = hzp1.party_id
AND     rctlgd.code_combination_id = glc.code_combination_id
AND	 	hzca1.customer_class_code  = vp_nonfed_customer_class
AND   	aps.class = 'INV'
AND	    frt.receivable_type_id = fctt.receivable_type_id
AND 	frt.receivable_type = vp_type_of_receivable
AND		fctt.cust_trx_type_id = rct.cust_trx_type_id
AND	frt.SET_OF_BOOKS_ID = vp_sob_id	-- Bug 4655467
--AND	frt.org_id = vp_org_id		-- Bug 4655467
AND	rct.SET_OF_BOOKS_ID = vp_sob_id	-- Bug 4655467
--AND	rct.org_id = vp_org_id		-- Bug 4655467
UNION
SELECT 	rct2.customer_trx_id,
		rct2.related_customer_trx_id,
		rct2.trx_date,
		aps2.amount_due_original,
      	aps2.amount_due_remaining,
	      aps2.actual_date_closed,
      	aps2.due_date,
	      aps2.class,
      	aps2.payment_schedule_id,
		rct2.interface_header_attribute3 created_from,
	      hzp2.category_code customer_category_code
from   	RA_CUSTOMER_TRX_ALL rct2,
		ar_payment_schedules_all aps2,
      	--ra_customers rc2 --Bug#4476059 Quick Change
		hz_cust_accounts hzca2,
		hz_parties hzp2
where aps2.class in ('DM','CM')
	  	and hzca2.cust_account_id = rct2.bill_to_customer_id
		AND	hzca2.party_id = hzp2.party_id
		and rct2.customer_trx_id = aps2.customer_trx_id
		and rct2.SET_OF_BOOKS_ID = vp_sob_id	-- Bug 4655467
--		and rct2.org_id = vp_org_id		-- Bug 4655467
		and rct2.related_customer_trx_id

IN
	(Select rct3.customer_trx_id
from  RA_CUSTOMER_TRX_ALL rct3,
	RA_CUST_TRX_LINE_GL_DIST_ALL rctlgd3,
	--RA_CUSTOMERS  rc3, --Bug#4476059 Quick Change
		hz_cust_accounts hzca3,
		hz_parties hzp3,
      AR_PAYMENT_SCHEDULES_ALL aps3,
	FV_RECEIVABLE_TYPES_ALL frt3,
      FV_REC_CUST_TRX_TYPES_ALL fctt3,
--	FV_FUND_PARAMETERS fp3,		-- Bug 4655467
--	FV_TREASURY_SYMBOLS  fts3,	-- Bug 4655467
	GL_CODE_COMBINATIONS glc3
  where  rct3.customer_trx_id = rctlgd3.customer_trx_id
  and      rct3.trx_date <= vg_end_date
  and rctlgd3.account_class ='REC'
  and rctlgd3.set_of_books_id = vp_sob_id
  and frt3.SET_OF_BOOKS_ID = vp_sob_id	-- Bug 4655467
--  and frt3.org_id = vp_org_id		-- Bug 4655467
  and rct3.SET_OF_BOOKS_ID = vp_sob_id	-- Bug 4655467
--  and rct3.org_id = vp_org_id		-- Bug 4655467
  and aps3.customer_trx_id = rct3.customer_trx_id
  and rct3.bill_to_customer_id = hzca3.cust_account_id
  and hzca3.party_id = hzp3.party_id
  and rctlgd3.code_combination_id = glc3.code_combination_id
  and hzca3.customer_class_code  =  vp_nonfed_customer_class
  and aps3.class = 'INV'
  and frt3.receivable_type = vp_type_of_receivable
  and frt3.receivable_type_id = fctt3.receivable_type_id
  and fctt3.cust_trx_type_id = rct3.cust_trx_type_id);

CURSOR CUR_IA_ADJUSTMENTS(p_payment_schedule_id NUMBER ,
                          p_customer_trx_id NUMBER) IS
SELECT decode(fvs.factsi_customer_attribute, 'ATTRIBUTE1', ara.attribute1,
             'ATTRIBUTE2', ara.attribute2, 'ATTRIBUTE3', ara.attribute3,
             'ATTRIBUTE4', ara.attribute4, 'ATTRIBUTE5', ara.attribute5,
             'ATTRIBUTE6', ara.attribute6, 'ATTRIBUTE7', ara.attribute7,
             'ATTRIBUTE8', ara.attribute8, 'ATTRIBUTE8', ara.attribute8,
             'ATTRIBUTE9', ara.attribute9, 'ATTRIBUTE10', ara.attribute10,
             'ATTRIBUTE11', ara.attribute11, 'ATTRIBUTE12', ara.attribute12,
             'ATTRIBUTE13', ara.attribute13, 'ATTRIBUTE14', ara.attribute14,
             'ATTRIBUTE15', ara.attribute15) attribute15,
           ara.amount,
           ara.receivables_trx_id,
           ara.payment_schedule_id,
           rct.interface_header_attribute3 created_from,
           ara.customer_trx_id,
           hzp1.category_code customer_category_code,
           ara.type,
           rctt.type  trx_type
FROM       ar_adjustments_all ara,
           ra_customer_trx_all rct,
           --ra_customers rc, --Bug#4476059 Quick Change
	   hz_cust_accounts hzca1,
	   hz_parties hzp1,
           ra_cust_trx_types_all rctt,
           fv_system_parameters fvs
WHERE  rct.customer_trx_id = ara.customer_trx_id
AND    hzca1.cust_account_id   = rct.bill_to_customer_id
AND	hzca1.party_id = hzp1.party_id
AND    rct.cust_trx_type_id = rctt.cust_trx_type_id
AND    ara.apply_date >= vl_fy_begin_date
AND    ara.apply_date <  vg_end_date+1
AND    ara.gl_date    >= vl_fy_begin_date
AND    ara.gl_date    <  vg_end_date+1
AND    ara.payment_schedule_id = p_payment_schedule_id
AND    ara.customer_trx_id = p_customer_trx_id
AND    rct.SET_OF_BOOKS_ID = vp_sob_id;	-- Bug 4655467
--AND    rct.org_id = vp_org_id;		-- Bug 4655467


CURSOR CUR_1A_COLLECTIONS_1 (p_payment_schedule_id NUMBER ,
                             p_customer_trx_id NUMBER ) IS
SELECT  ara.amount_applied,
        ara.APPLIED_CUSTOMER_TRX_ID ,
        ara.receivables_trx_id,
        hzp1.category_code customer_category_code,
        ara.applied_payment_schedule_id,
        acr.receipt_number,
        acr.cash_receipt_id,
	acr.amount
from    ar_receivable_applications_all ara,
        ar_cash_receipts_all acr,
        --ra_customers rc, ----Bug#4476059 Quick Change
	   hz_cust_accounts hzca1,
	   hz_parties hzp1,
        ra_customer_trx_all rct
where   ara.cash_receipt_id = acr.cash_receipt_id
and     ara.status = 'APP'
and     ara.apply_date between vl_fy_begin_date and vg_end_date+1
and     rct.customer_trx_id = p_customer_trx_id
and     hzca1.cust_account_id = rct.bill_to_customer_id
AND	hzca1.party_id = hzp1.party_id
AND     ara.APPLIED_CUSTOMER_TRX_ID = p_customer_trx_id
AND 	ara.applied_payment_schedule_id = p_payment_schedule_id ;

CURSOR CUR_1A_COL_ON_REC (p_receipt_number VARCHAR2 ,
                          p_customer_trx_id NUMBER ,
                          p_cash_receipt_id NUMBER )IS
SELECT receipt_desc_type ,NVL(ficr.amount,0) amount
FROM   fv_interim_cash_receipts_all ficr,
	 ar_cash_receipts_all acr,
	 ar_cash_receipt_history_all acrh
WHERE ficr.receipt_number = p_receipt_number
AND   ficr.customer_trx_id = p_customer_trx_id
AND   ficr.set_of_books_id  = vp_sob_id
AND   ficr.batch_id = acrh.batch_id
AND   acrh.cash_receipt_id = acr.cash_receipt_id
AND   acrh.current_record_flag = 'Y'
AND   acr.cash_receipt_id = p_cash_receipt_id ;


CURSOR  CUR_IIC_Collections( p_payment_schedule_id NUMBER,
                             p_customer_trx_id NUMBER ) IS
select ara.amount_applied,
       ara.applied_customer_trx_id,
       ara.applied_payment_schedule_id,
       acr.receipt_number,
       ara.cash_receipt_id,
       aps.class
from   ar_receivable_applications_all ara,
       ar_cash_receipts_all acr,
       ar_payment_schedules_all aps
where  ara.cash_receipt_id = acr.cash_receipt_id
and    acr.set_of_books_id = vp_sob_id
and    nvl(ara.days_late,0) >=  0
and    trunc(ara.apply_date) > trunc(aps.due_date)
and    aps.customer_trx_id = ara.applied_customer_trx_id
and    aps.payment_schedule_id = ara.applied_payment_schedule_id
and    ara.applied_customer_trx_id = p_customer_trx_id
and    ara.applied_payment_schedule_id = p_payment_schedule_id ;

amt_accruals NUMBER ;
amt_fy_begin_bal NUMBER ;
amt_fy_new_rec   NUMBER ;
amt_fin_accruals_int NUMBER ;
amt_adj_reclassified NUMBER ;
amt_adj_sales_assets NUMBER ;
amt_adj_consolidation  NUMBER ;
amt_adj_accrual    NUMBER ;
amt_write_off_A    NUMBER ;
amt_write_off_B    NUMBER ;
amt_fin_adj_accruals_int  NUMBER ;
amt_col_third_party  NUMBER ;
amt_col_asset_sales  NUMBER ;
amt_col_others  NUMBER ;
amt_col_at_agency  NUMBER ;

amt_SECC_1A  NUMBER ;
amt_SECC_1B  NUMBER ;
amt_SECC_1C  NUMBER ;
amt_SECC_1D  NUMBER ;
amt_SECC_1E  NUMBER ;
amt_SECC_1F  NUMBER ;
amt_SECC_1G  NUMBER ;
amt_SECC_1H  NUMBER ;
amt_SECC_1I  NUMBER ;
amt_SECC_1J  NUMBER ;

num_fy_begin_bal NUMBER ;
num_fy_new_rec   NUMBER ;
num_adj NUMBER ;
num_write_off_A    NUMBER ;
num_write_off_B    NUMBER ;
num_SECC_1A  NUMBER ;
num_SECC_1B  NUMBER ;
num_SECC_1C  NUMBER ;
num_SECC_1D  NUMBER ;
num_SECC_1E  NUMBER ;
num_SECC_1F  NUMBER ;
num_SECC_1G  NUMBER ;
num_SECC_1H  NUMBER ;
num_SECC_1I  NUMBER ;
num_SECC_1J  NUMBER ;

--l_dm_status fv_invoice_statuses_all.status%TYPE := '' ;
--l_pay_schedule_id NUMBER;
--l_dm_due_date  DATE;
--l_count NUMBER ;

l_exists  NUMBER ;
l_adj_amount Number;
l_appld_amount	number ;
l_count   NUMBER;

--l_total_amt            NUMBER;
--l_amt_appl_on_fin      NUMBER;

l_act_amt              NUMBER;
l_cust_trx_id          NUMBER;
l_rec_desc_tbl g_rec_desc_type ;

l_pay_schedule_id ar_payment_schedules_all.payment_schedule_id%type;
schedule_id ar_receivable_applications_all.applied_payment_schedule_id%type;

dummy varchar2(2);
fc_flag varchar2(2);
l_status ra_customer_trx_all.status_trx%type ;
IIC_Col_recs_Increment NUMBER;

BEGIN

IIC_Col_recs_Increment := 0;
l_module_name := g_module_name || 'Populate_IB_IIAB';
amt_accruals  := 0;
amt_fy_begin_bal  := 0;
amt_fy_new_rec    := 0;
amt_fin_accruals_int  := 0;
amt_adj_reclassified  := 0;
amt_adj_sales_assets  := 0;
amt_adj_consolidation   := 0;
amt_adj_accrual     := 0;
amt_write_off_A     := 0;
amt_write_off_B     := 0;
amt_fin_adj_accruals_int     := 0;
amt_col_third_party     := 0;
amt_col_asset_sales     := 0;
amt_col_others     := 0;
amt_col_at_agency     := 0;

amt_SECC_1A     := 0;
amt_SECC_1B     := 0;
amt_SECC_1C     := 0;
amt_SECC_1D     := 0;
amt_SECC_1E     := 0;
amt_SECC_1F     := 0;
amt_SECC_1G     := 0;
amt_SECC_1H     := 0;
amt_SECC_1I     := 0;
amt_SECC_1J     := 0;

num_fy_begin_bal   := 0;
num_fy_new_rec     := 0;
num_adj   := 0;
num_write_off_A       := 0;
num_write_off_B       := 0;
num_SECC_1A     := 0;
num_SECC_1B     := 0;
num_SECC_1C     := 0;
num_SECC_1D     := 0;
num_SECC_1E     := 0;
num_SECC_1F     := 0;
num_SECC_1G     := 0;
num_SECC_1H     := 0;
num_SECC_1I     := 0;
num_SECC_1J     := 0;

l_adj_amount  := 0;
l_appld_amount:= 0;

--l_total_amt          := 0;
--l_amt_appl_on_fin    := 0;
l_act_amt            := 0;
l_count := 1;


FOR recs IN CUR_IA

LOOP
l_adj_amount:= 0;
l_appld_amount := 0;

l_pay_schedule_id := 0 ; -- id will never be 0 so comparisions down
-- the line will definitely fail if class is not INV

-- 1A1 Begining FY Balance Amount
IF (recs.trx_date < vl_fy_begin_date ) and
recs.actual_date_closed > vl_fy_begin_date THEN
	select nvl(sum(amount),0)
   	into l_adj_amount
   	from ar_adjustments_all
   	where customer_trx_id = recs.customer_trx_id
	and apply_date < vl_fy_begin_date + 1;

   	select nvl(sum(amount_applied),0) * -1
   	into l_appld_amount
   	from ar_receivable_applications_all
   	where applied_customer_trx_id = recs.customer_trx_id
	and apply_date < vl_fy_begin_date + 1;

    amt_fy_begin_bal := amt_fy_begin_bal +
                        recs.amount_due_original +
                        l_adj_amount + l_appld_amount ;
END IF;

-- 1A1 Begining FY Balance Number
SELECT MIN(payment_schedule_id)
INTO   l_pay_schedule_id
FROM   ar_payment_schedules_all a
WHERE  a.customer_trx_id = recs.customer_trx_id
AND    actual_date_closed > vl_fy_begin_date;

IF (recs.trx_date < vl_fy_begin_date ) AND
recs.payment_schedule_id = l_pay_schedule_id  THEN
	num_fy_begin_bal := num_fy_begin_bal + 1 ;
END IF;


-- 1A2 New Receivables Number
SELECT min(payment_schedule_id)
INTO   l_pay_schedule_id
FROM   ar_payment_schedules_all a
WHERE  a.customer_trx_id = recs.customer_trx_id;

--1A2 New Receivables Amount
IF (recs.trx_date >= vl_fy_begin_date and recs.class = 'INV') THEN
	amt_fy_new_rec := amt_fy_new_rec + recs.amount_due_original;
	--1A2 New Receivables Number
	IF recs.payment_schedule_id = l_pay_schedule_id  THEN
		num_fy_new_rec := num_fy_new_rec + 1;
	END IF;
END IF ;


--1A3 Accruals
BEGIN
   SELECT DISTINCT 'x' INTO dummy
   FROM   fv_finance_charge_controls_all
   WHERE  set_of_books_id = vp_sob_id
   AND    charge_type = recs.created_from  ;

   amt_accruals := amt_accruals + recs.amount_due_original;

   EXCEPTION
	WHEN NO_DATA_FOUND THEN
	 Null;
END ;


-- 1A9 Interest and Late Charges
BEGIN
   SELECT DISTINCT 'x' INTO dummy
   FROM   fv_finance_charge_controls_all
   WHERE  set_of_books_id = vp_sob_id
   AND    charge_type = recs.created_from
   AND category<> 'A';

   amt_fin_accruals_int := amt_fin_accruals_int + recs.amount_due_remaining;

   EXCEPTION
	WHEN NO_DATA_FOUND THEN
	 Null;
END ;


FOR adj_recs IN CUR_IA_ADJUSTMENTS (recs.payment_schedule_id ,
                                    recs.customer_trx_id)
LOOP

--1A5 Adjustments

BEGIN
    SELECT distinct 'Y' into fc_flag
    from   fv_finance_charge_controls_all
    where  charge_type = adj_recs.created_from;

EXCEPTION
     when no_data_found then
     fc_flag := 'N';
END;

  IF fc_flag = 'N' then
    IF (adj_recs.attribute15 = 'RECLASSIFIED') THEN
      amt_adj_reclassified :=   amt_adj_reclassified  + adj_recs.amount ;
      num_adj		   := num_adj + 1;
    ELSIF (adj_recs.attribute15 = 'ASSET') THEN
 	amt_adj_sales_assets :=   amt_adj_sales_assets  + adj_recs.amount ;
	num_adj		   := num_adj + 1;
    ELSIF (adj_recs.attribute15 = 'CONSOLIDATION') THEN
	amt_adj_consolidation :=   amt_adj_consolidation  + adj_recs.amount ;
	num_adj		   := num_adj + 1;
    END IF;
  ELSIF fc_flag = 'Y' THEN
    -- 1A3 Accruals
    IF (adj_recs.attribute15 IS NULL ) THEN
     amt_adj_accrual  :=   amt_adj_accrual  + adj_recs.amount ;
    END IF;
  END IF; -- fc_flag = N / Y

--END IF;

--1A6 Amounts Written-Off
IF adj_recs.receivables_trx_id IN
(vp_WRITE_OFF_ACTIVITY_1,vP_WRITE_OFF_ACTIVITY_2,vp_WRITE_OFF_ACTIVITY_3)
   THEN
	SELECT status_trx
	INTO l_status
	FROM ra_customer_trx_all
	WHERE customer_trx_id = adj_recs.customer_trx_id;

	IF l_status IN ('OP', 'PEN') THEN
	   amt_write_off_A := amt_write_off_A + adj_recs.amount;
	   num_write_off_A := num_write_off_A + 1;
	ELSIF l_status IN ('CL', 'VD')THEN
	   amt_write_off_B := amt_write_off_B + adj_recs.amount;
	   num_write_off_B := num_write_off_B + 1;
	END IF;
END IF;

--1A9 Interest and Late Charges

BEGIN
  select distinct 'Y' into fc_flag
  from   fv_finance_charge_controls_all
  where  set_of_books_id = vp_sob_id
  AND    charge_type = recs.created_from
  AND category <> 'A';
EXCEPTIOn
     when no_data_found then
     fc_flag := 'N';
End;
  if adj_recs.attribute15 is null and  nvl(adj_recs.receivables_trx_id, '-999')
  not in (nvl(vP_WRITE_OFF_ACTIVITY_1, '-99'),
    nvl(vP_WRITE_OFF_ACTIVITY_2, '-99'),
	nvl(vP_WRITE_OFF_ACTIVITY_3, '-99'))     and fc_flag = 'Y' then
    amt_fin_adj_accruals_int := amt_fin_adj_accruals_int + adj_recs.amount;
  end if;

END LOOP; -- CUR_1A_ADJUSTMENTS

-- 1A4 Collections
FOR col_recs IN CUR_1A_COLLECTIONS_1(recs.payment_schedule_id ,
                                     recs.customer_trx_id)
LOOP


-- get the parent trx id for the DM/CM

   IF recs.related_customer_trx_id IS NOT NULL and recs.class <> 'INV' THEN
	l_cust_trx_id :=  recs.related_customer_trx_id ;
   ELSE
	l_cust_trx_id :=  recs.customer_trx_id ;
   END IF;

  l_exists := 0;


  FOR receipt_desc_recs IN CUR_1A_COL_ON_REC (col_recs.receipt_number,
                                              l_cust_trx_id ,
                                              col_recs.cash_receipt_id)
  LOOP

 IF l_count > 1 THEN
   FOR i IN 1..l_rec_desc_tbl.count
   LOOP
	IF l_rec_desc_tbl(i).cash_receipt_id = col_recs.cash_receipt_id THEN
	      l_rec_desc_tbl(i).amount :=  l_rec_desc_tbl(i).amount -
						 col_recs.amount_applied;
	      l_exists := 1;
        END IF;
   END LOOP;
END IF;

   IF l_exists = 0 THEN
	 l_rec_desc_tbl(l_count).amount :=
			receipt_desc_recs.amount-col_recs.amount_applied;
	l_rec_desc_tbl(l_count).cash_receipt_id :=
			col_recs.cash_receipt_id;
	l_rec_desc_tbl(l_count).desc_type :=
			receipt_desc_recs.receipt_desc_type;
        l_count := l_count+1;
   END IF;

 l_act_amt := col_recs.amount_applied;


      IF nvl(col_recs.receivables_trx_id, '-999') not in
      (nvl(vp_WRITE_OFF_ACTIVITY_1, '-99'),
	     nvl(vp_WRITE_OFF_ACTIVITY_2, '-99'),
	      nvl(vp_WRITE_OFF_ACTIVITY_3, '-99')) THEN
        IF (receipt_desc_recs.receipt_desc_type = 'TP') THEN
	  amt_col_third_party := 	amt_col_third_party - l_act_amt;
	ELSIF (receipt_desc_recs.receipt_desc_type) = 'AS' THEN
	   amt_col_asset_sales := 	amt_col_asset_sales - l_act_amt;
	 ELSIF (receipt_desc_recs.receipt_desc_type) = 'OT' OR
	(receipt_desc_recs.receipt_desc_type) NOT IN ( 'AG','AS', 'TP')THEN
	     amt_col_others := 	amt_col_others - l_act_amt;
	 ELSE
	    amt_col_at_agency := 	amt_col_at_agency - l_act_amt;
	 END IF;
     END IF;
 END LOOP ; -- CUR_1A_COL_ON_REC
END LOOP; -- CUR_1A_COLLECTIONS_1

-- 2C Collections


FOR IIC_col_recs IN CUR_IIC_COLLECTIONS(recs.payment_schedule_id ,
                                        recs.customer_trx_id)
LOOP
select  min(applied_payment_schedule_id)
into schedule_id
FROM ar_receivable_applications_all
where applied_customer_trx_id =IIC_col_recs.applied_customer_trx_id
and   cash_receipt_id     =    IIC_col_recs.cash_receipt_id;

IF(IIC_Col_recs.applied_payment_schedule_id = schedule_id
  and recs.class = 'INV') THEN
  IIC_Col_recs_Increment := 1 ;
ELSE
  IIC_Col_recs_Increment := 0 ;
END IF;

 IF recs.related_customer_trx_id IS NOT NULL and recs.class <> 'INV' THEN
        l_cust_trx_id :=  recs.related_customer_trx_id ;
   ELSE
        l_cust_trx_id :=  recs.customer_trx_id ;
   END IF;

  FOR receipt_desc_recs IN CUR_1A_COL_ON_REC (IIC_col_recs.receipt_number,
				  --  IIC_Col_recs.applied_customer_trx_id ,
				l_cust_trx_id,
				    IIC_col_recs.cash_receipt_id)
  LOOP

    l_act_amt := IIC_Col_recs.amount_applied;

	IF (receipt_desc_recs.receipt_desc_type) = 'PC' THEN
		amt_SECC_1A := amt_SECC_1A  + l_act_amt;
		num_SECC_1A := num_SECC_1A + IIC_Col_recs_Increment ;
	ELSIF (receipt_desc_recs.receipt_desc_type) = 'LI' THEN
		amt_SECC_1B := amt_SECC_1B  + l_act_amt;
		num_SECC_1B := num_SECC_1B + IIC_Col_recs_Increment ;
	ELSIF (receipt_desc_recs.receipt_desc_type) = 'IO' THEN
		amt_SECC_1C := amt_SECC_1C  + l_act_amt;
		num_SECC_1C := num_SECC_1C + IIC_Col_recs_Increment ;
	ELSIF (receipt_desc_recs.receipt_desc_type) = 'TP' THEN
		amt_SECC_1D := amt_SECC_1D  + l_act_amt;
		num_SECC_1D := num_SECC_1D + IIC_Col_recs_Increment ;
	ELSIF (receipt_desc_recs.receipt_desc_type) = 'AS' THEN
		amt_SECC_1E := amt_SECC_1E  + l_act_amt;
                num_SECC_1E := num_SECC_1E + IIC_Col_recs_Increment ;
	ELSIF (receipt_desc_recs.receipt_desc_type) = 'WG' THEN
		amt_SECC_1F := amt_SECC_1F  + l_act_amt;
                num_SECC_1F := num_SECC_1F + IIC_Col_recs_Increment ;
	ELSIF (receipt_desc_recs.receipt_desc_type) = 'TD' THEN
		amt_SECC_1G := amt_SECC_1G  + l_act_amt;
                num_SECC_1G := num_SECC_1G + IIC_Col_recs_Increment ;
	ELSIF (receipt_desc_recs.receipt_desc_type) = 'TO' THEN
		amt_SECC_1H := amt_SECC_1H  + l_act_amt;
                num_SECC_1H := num_SECC_1H + IIC_Col_recs_Increment ;
	ELSIF (receipt_desc_recs.receipt_desc_type) = 'AG' THEN
		amt_SECC_1I := amt_SECC_1I  + l_act_amt;
                num_SECC_1I := num_SECC_1I + IIC_Col_recs_Increment ;
	ELSE
		amt_SECC_1J := amt_SECC_1J  + l_act_amt;
                num_SECC_1J := num_SECC_1J + IIC_Col_recs_Increment ;
	END IF;
  END LOOP ; -- CUR_1A_COL_ON_REC
END LOOP; -- CUR_IIC_COLLECTIONS


END LOOP;-- CUR_1A

-- On account
 FOR i IN 1..l_rec_desc_tbl.count
   LOOP

    IF (l_rec_desc_tbl(i).desc_type) = 'TP' THEN
      amt_col_third_party :=        amt_col_third_party + l_rec_desc_tbl(i).amount;
    ELSIF (l_rec_desc_tbl(i).desc_type) = 'AS' THEN
      amt_col_asset_sales :=       amt_col_asset_sales + l_rec_desc_tbl(i).amount;
    ELSIF (l_rec_desc_tbl(i).desc_type) = 'OT' OR
                 (l_rec_desc_tbl(i).desc_type) NOT IN ( 'AG','AS', 'TP')THEN
       amt_col_others :=  amt_col_others + l_rec_desc_tbl(i).amount;
    ELSE
       amt_col_at_agency :=        amt_col_at_agency + l_rec_desc_tbl(i).amount;
     END IF;
  END LOOP;

insert_row('101', 'LINE' ,NULL ,NULL) ;
insert_row('102', 'Part I - Status of Receivables' ,NULL ,NULL) ;
insert_row('103', 'LINE' ,NULL ,NULL) ;
insert_row('1A01','Section A' ,NULL ,NULL) ;
insert_row('1A02','Receivables and Collections' ,NULL ,NULL) ;
insert_row('1A03','LINE' ,NULL ,NULL) ;
insert_row('1A1', '(1) Beginning FY Balance',
num_fy_begin_bal ,amt_fy_begin_bal ) ;
insert_row('1A2', '(2) New Receivables (+)',
num_fy_new_rec   ,amt_fy_new_rec   ) ;
insert_row('1A3', '(3) Accruals (+)', '', amt_adj_accrual + amt_accruals) ;
insert_row('1A4', '(4) Collections on Receivables (-)', '' ,
						 amt_col_at_agency +
						 amt_col_third_party +
						 amt_col_asset_sales +
						 amt_col_others ) ;
insert_row('1A4A','  (A) At Agency', '' ,amt_col_at_agency ) ;
insert_row('1A4B','  (B) At Third Party', '' ,amt_col_third_party ) ;
insert_row('1A4C','  (C) Asset Sales', '' ,amt_col_asset_sales ) ;
insert_row('1A4D','  (D) Other - must footnote', '' ,amt_col_others ) ;
insert_row('1A5', '(5) Adjustments',
num_adj ,amt_adj_reclassified + amt_adj_sales_assets + amt_adj_consolidation) ;
insert_row('1A5A','  (A) Reclassified/Adjusted Amounts (+ or -)',
'', amt_adj_reclassified) ;
insert_row('1A5B','  (B) Adjustments Due to Sale of Assets (+ or -)',
'', amt_adj_sales_assets) ;
insert_row('1A5C','  (C) Consolidations (+ or -)',
'', amt_adj_consolidation) ;
insert_row('1A6', '(6) Amounts Written-Off (-)',
num_write_off_A + num_write_off_B , amt_write_off_A + amt_write_off_B ) ;
insert_row('1A6A','  (A) Currently Not Collectible',
num_write_off_A , amt_write_off_A ) ;
insert_row('1A6B','  (B) Written-Off and Closed Out',
num_write_off_B , amt_write_off_B ) ;
insert_row('1A70', '(7) Ending Balance',
num_fy_begin_bal + num_fy_new_rec - num_write_off_A - num_write_off_B,
amt_fy_begin_bal + amt_fy_new_rec + amt_accruals
+amt_col_at_agency + amt_col_third_party + amt_col_asset_sales + amt_col_others
+ amt_adj_reclassified + amt_adj_sales_assets + amt_adj_consolidation
+ amt_write_off_A + amt_write_off_A ) ;
insert_row('1A71','LINE' ,NULL ,NULL) ;
insert_row('1A7A','  (A) Foreign/Sovereign', '' , '' ) ;
insert_row('1A7B','  (B) State and Local Government', '' , '' ) ;
insert_row('1A7C','LINE' ,NULL ,NULL) ;
insert_row('1A8', '(8) Rescheduled Debt','' ,'' ) ;
insert_row('1A8A','  (A) Delinquent','' ,'') ;
insert_row('1A8B','  (B) Non-Delinquent','' ,'') ;
insert_row('1A91', '(9) Interest' || ' & ' || 'Late Charges',
'',    amt_fin_accruals_int + amt_fin_adj_accruals_int  ) ;
insert_row('1A92','LINE' ,NULL ,NULL) ;


-- Part 2 Section C
insert_row('2C01', 'LINE' ,NULL ,NULL) ;
insert_row('2C02', 'Section C' ,NULL ,NULL) ;
insert_row('2C03', 'Collections' ,NULL ,NULL) ;
insert_row('2C04', 'LINE' ,NULL ,NULL) ;
insert_row('2C1',  '(1) Collections on Delinquent Debt',
num_SECC_1A + num_SECC_1B + num_SECC_1C + num_SECC_1D +
num_SECC_1E + num_SECC_1F + num_SECC_1G + num_SECC_1H +
num_SECC_1I + num_SECC_1J  ,
amt_SECC_1A + amt_SECC_1B + amt_SECC_1C + amt_SECC_1D +
amt_SECC_1E + amt_SECC_1F + amt_SECC_1G + amt_SECC_1H +
amt_SECC_1I + amt_SECC_1J ) ;
insert_row('2C1A', '  (A) By Private Collection Agencies',
 num_SECC_1A   ,amt_SECC_1A  ) ;
insert_row('2C1B', '  (B) By Litigation',
 num_SECC_1B   ,amt_SECC_1B ) ;
insert_row('2C1C', '  (C) By Internal Offset',
 num_SECC_1C  , amt_SECC_1C) ;
insert_row('2C1D', '  (D) By Third Party',
 num_SECC_1D ,amt_SECC_1D ) ;
insert_row('2C1E', '  (E) By Asset Sales',
 num_SECC_1E ,amt_SECC_1E ) ;
insert_row('2C1F', '  (F) By Wage Garnishment',
 num_SECC_1F  ,amt_SECC_1F);
insert_row('2C1G1','  (G) By Treasury or a Designated Debt Collection',
 num_SECC_1G ,amt_SECC_1G  ) ;
insert_row('2C1G2','      Center Cross Servicing', NULL ,NULL  ) ;
insert_row('2C1H', '  (H) By Treasury Offset',
 num_SECC_1H , amt_SECC_1H);
insert_row('2C1I', '  (I) By Agency',
 num_SECC_1I , amt_SECC_1I);
insert_row('2C1J', '  (J) Other - must footnote',
num_SECC_1J  ,amt_SECC_1J);

-- Part 2 Section D - NO calculations for this section
--exist in the existing report.
insert_row('2D01','LINE' ,NULL ,NULL) ;
insert_row('2D02','Section D' ,NULL ,NULL) ;
insert_row('2D03','Debt Disposition' ,NULL ,NULL) ;
insert_row('2D04','LINE' ,NULL ,NULL) ;
insert_row('2D1',  '(1) Written Off and Not Closed Out' ,NULL ,NULL) ;
insert_row('2D1A', '  (A) At Private Collection Agencies' ,NULL ,NULL) ;
insert_row('2D1B1','  (B) At Treasury or a Designated Debt Collection' ,
NULL ,NULL) ;
insert_row('2D1B2','      Center for Cross Servicing' ,NULL ,NULL) ;
insert_row('2D1C', '  (C) At Treasury for Offset' ,NULL ,NULL) ;
insert_row('2D1D4','  (D) Other - must footnote' ,NULL ,NULL) ;
insert_row('2D2', '(2) Reported to IRS on Form 1099-C' ,NULL ,NULL) ;
insert_row('2D21','LINE' ,NULL ,NULL) ;

EXCEPTION
  WHEN OTHERS THEN
    vp_retcode := SQLCODE;
    vp_errbuf  := SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||
    '.final_exception',vp_errbuf) ;
    RAISE;

END  Populate_IA_IIC ;

-- ------------------------------------------------------------------
--                      Procedure Insert Row
-- ------------------------------------------------------------------
-- Insert_Row procedure is called from the <> <> procedure.
-- This procedure insert data in the fv_receivables_activity_temp
-- Table.
-- ------------------------------------------------------------------
PROCEDURE insert_row
            ( p_line_num VARCHAR2,
			  p_descpription VARCHAR2,
			  p_count NUMBER,
			  p_amount NUMBER
            ) IS
l_module_name VARCHAR2(200);

BEGIN
l_module_name := g_module_name || 'Insert_Row.';

     INSERT INTO fv_receivables_activity_temp  (
		LINE_NUM,
		DESCRIPTION,
		COUNT ,
		AMOUNT)
     VALUES  (
	 	p_line_num,
		p_descpription,
		p_count,
		p_amount );

EXCEPTION
   WHEN OTHERS THEN
      vp_retcode := SQLCODE ;
      vp_errbuf  := SQLERRM  ||
      'Error in Insert_Row procedure while inserting value for line:' ||
      p_line_num ;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||
      'Final Exception',vp_errbuf) ;
      RETURN ;
END insert_row;
-- ------------------------------------------------------------------
--                      Procedure Submit_Reports
-- ------------------------------------------------------------------
-- Submit_Reports procedure is called from the Main Procedure.
-- This procedure submits the Receivables Activity Worksheet Report
-- ------------------------------------------------------------------


PROCEDURE Submit_Report (p_set_of_books_id NUMBER,
p_reporting_entity_code VARCHAR2,
p_fiscal_year NUMBER,
p_quarter NUMBER,
p_reported_by VARCHAR2,
p_type_of_receivable VARCHAR2,
p_footnotes VARCHAR2,
p_preparer_name VARCHAR2,
p_preparer_phone VARCHAR2,
p_preparer_fax_number VARCHAR2,
p_preparer_email VARCHAR2,
p_supervisor_name VARCHAR2,
p_supervisor_phone VARCHAR2,
p_supervisor_email VARCHAR2,
p_address_line_1 VARCHAR2,
p_address_line_2 VARCHAR2,
p_address_line_3 VARCHAR2,
p_city VARCHAR2,
p_state VARCHAR2,
p_postal_code VARCHAR2  ) IS

l_module_name VARCHAR2(200);
vl_req_id   NUMBER;
vl_count NUMBER ;
vl_org_id NUMBER ;	-- MOAC Changes

BEGIN

l_module_name := g_module_name || 'Submit_Report.';
SELECT COUNT(*)
INTO vl_count
FROM fv_receivables_activity_temp ;

IF vl_count = 0  THEN
   vp_retcode := 1 ;
   vp_errbuf := 'No Data Found ' ;
   FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,vp_errbuf) ;
   RETURN ;
END IF;

-- MOAC Change
vl_org_id:=mo_global.get_current_org_id;
fnd_request.set_org_id(vl_org_id);

vl_req_id:= Fnd_Request.Submit_Request (
	'FV','FVXDCDFR','','',FALSE,
	p_set_of_books_id,
	p_reporting_entity_code,
	p_fiscal_year,
	p_quarter,
	p_reported_by,
	p_type_of_receivable,
	p_footnotes,
	p_preparer_name,
	p_preparer_phone,
	p_preparer_fax_number,
	p_preparer_email ,
	p_supervisor_name ,
	p_supervisor_phone ,
	p_supervisor_email ,
    p_address_line_1 ,
    p_address_line_2 ,
    p_address_line_3 ,
    p_city ,
    p_state ,
    p_postal_code
   ) ;

    IF (vl_req_id = 0) THEN
	  vp_retcode := 2 ;
      vp_errbuf  := 'Error in Submit_Report procedure,' ||
      ' while submitting Receivables Activity Report .' ;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_ERROR, l_module_name,vp_errbuf) ;
      RETURN ;
    END IF;

 EXCEPTION
   WHEN OTHERS THEN
      vp_retcode := SQLCODE ;
      vp_errbuf  := SQLERRM  ||' -- Error in Submit_Report procedure.' ;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_UNEXPECTED, l_module_name||
      '.final_exception',vp_errbuf) ;
      RETURN ;
END Submit_Report;
---------------------------------------------------------------------
--                              END OF PACKAGE BODY
---------------------------------------------------------------------
END fv_receivables_activity_pkg ;

/
