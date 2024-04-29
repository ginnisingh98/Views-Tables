--------------------------------------------------------
--  DDL for Package Body PA_GL_REV_XFER_AUDIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_GL_REV_XFER_AUDIT_PKG" AS
/* $Header: PAGLXARB.pls 120.6.12010000.6 2010/04/02 12:32:44 sbommaka ship $ */

PROCEDURE process(x_where_cc			IN	VARCHAR2,
		  x_gl_date_where_clause	IN	VARCHAR2,
		  x_from_date			IN	DATE,
		  x_to_date			IN	DATE,
		  x_request_id			IN	NUMBER)
IS
erdl_cur  NUMBER:= DBMS_SQL.OPEN_CURSOR;
rdl_cur	  NUMBER:= DBMS_SQL.OPEN_CURSOR;
uer_cur	  NUMBER:= DBMS_SQL.OPEN_CURSOR;
ubr_cur	  NUMBER:= DBMS_SQL.OPEN_CURSOR;
gain_cur  NUMBER:= DBMS_SQL.OPEN_CURSOR;
loss_cur  NUMBER:= DBMS_SQL.OPEN_CURSOR;
erdl_cur1  NUMBER:= DBMS_SQL.OPEN_CURSOR;
rdl_cur1   NUMBER:= DBMS_SQL.OPEN_CURSOR;
uer_cur1   NUMBER:= DBMS_SQL.OPEN_CURSOR;
ubr_cur1   NUMBER:= DBMS_SQL.OPEN_CURSOR;
gain_cur1  NUMBER:= DBMS_SQL.OPEN_CURSOR;
loss_cur1  NUMBER:= DBMS_SQL.OPEN_CURSOR;
fdbk NUMBER;
je_statement	varchar2(100);
erdl_stmt	varchar2(4000);
rdl_stmt	varchar2(4000);
uer_stmt	varchar2(4000);
ubr_stmt	varchar2(4000);
gain_stmt	VARCHAR2(4000);
loss_stmt	VARCHAR2(4000);
erdl_stmt1	varchar2(4000);
rdl_stmt1	varchar2(4000);
uer_stmt1	varchar2(4000);
ubr_stmt1	varchar2(4000);
gain_stmt1	VARCHAR2(4000);
loss_stmt1	VARCHAR2(4000);

begin

delete pa_gl_rev_xfer_audit_rep where request_id = x_request_id;
/* FOR SLA uptake : Removing batch name */


/*
Insertion of ERDL Lines
=======================
*/
ERDL_STMT := 'insert into pa_gl_rev_xfer_audit_rep
(
        REQUEST_ID,
        CODE_COMBINATION_ID,
        LINE_TYPE,
        PERIOD_NAME,
        PROJECT_ID,
        PROJECT_NUMBER,
        DRAFT_REV_NUMBER,
        TRANSFERRED_DATE,
        GL_DATE,
        TRANSACTION_TYPE,
        TRANSACTION_DATE,
        TASK_ID,
        TASK_NUMBER,
        EMP_OR_ORG_NAME,
        EXPENDITURE_ITEM_ID,
        RDL_LINE_NUM,
        RDL_EVENT_NUM,
        DEBIT_AMOUNT,
        CREDIT_AMOUNT)
SELECT  DISTINCT '||x_request_id||',
                ael.code_combination_id          ,
                ''ERDL''                         ,
                aeh.period_name                  ,
                pdr.project_id                   ,
                NULL                             ,
                pdr.draft_revenue_num            ,
                pdr.transferred_date             ,
                pdr.gl_date                      ,
                NULL                             ,
                to_date(NULL)                    ,
                rdl.task_id                      ,
                NULL                             ,
                NULL                             ,
                to_number(null)                  ,
                rdl.line_num                     ,
                rdl.event_num                    ,
                to_number(null)                  ,
                rdl.amount
FROM
        pa_cust_event_rdl_all   rdl,
	pa_events		pe,
        pa_draft_revenues       pdr,
	gl_code_combinations    cc,
        xla_ae_lines            ael,
	xla_ae_headers          aeh,
        xla_distribution_links  xdl
WHERE
        pdr.transfer_status_code 		= ''A''
AND     rdl.project_id          		=  pdr.project_id
AND     rdl.draft_revenue_num   		=  pdr.draft_revenue_num
AND     aeh.ae_header_id        		= ael.ae_header_id
AND     aeh.event_id				= pdr.event_id
AND     aeh.application_id      		= 275
AND     xdl.event_id				= pdr.event_id
AND   	xdl.ae_header_id   			= aeh.ae_header_id
AND   	xdl.ae_line_num    			= ael.ae_line_num
AND 	xdl.source_distribution_type  		= ''Revenue - Event Revenue''
AND     xdl.source_distribution_id_num_1	= pe.event_id
AND     xdl.source_distribution_id_num_2	= rdl.line_num
AND     pe.project_id				= pdr.project_id
AND     nvl(pe.task_id,-1)                      = nvl(rdl.task_id,-1)/* Modified for bug 9498273  */
AND	pe.event_num				= rdl.event_num
AND     '||x_gl_date_where_clause ||'
AND     TRUNC(pdr.transferred_date) BETWEEN
        nvl(TRUNC(TO_DATE('''||to_char(x_from_date,'DD-MM-RRRR')||''',''DD-MM-RRRR'')), TRUNC(pdr.transferred_date))
AND     nvl(TRUNC(TO_DATE('''||to_char(x_to_date,'DD-MM-RRRR')||''',''DD-MM-RRRR'')),TRUNC(pdr.transferred_date))
AND     '||x_where_cc||'
AND aeh.balance_type_code                  = ''A''
AND aeh.accounting_entry_status_code       = ''F''
AND     ael.code_combination_id = cc.code_combination_id
AND	pdr.event_id 	IS NOT NULL';

DBMS_SQL.PARSE (erdl_cur, erdl_stmt, DBMS_SQL.NATIVE);
fdbk := DBMS_SQL.EXECUTE (erdl_cur);
DBMS_SQL.CLOSE_CURSOR (erdl_cur);
COMMIT;

ERDL_STMT1 := 'insert into pa_gl_rev_xfer_audit_rep
(
        REQUEST_ID,
        CODE_COMBINATION_ID,
        LINE_TYPE,
        PERIOD_NAME,
        PROJECT_ID,
        PROJECT_NUMBER,
        DRAFT_REV_NUMBER,
        TRANSFERRED_DATE,
        GL_DATE,
        TRANSACTION_TYPE,
        TRANSACTION_DATE,
        TASK_ID,
        TASK_NUMBER,
        EMP_OR_ORG_NAME,
        EXPENDITURE_ITEM_ID,
        RDL_LINE_NUM,
        RDL_EVENT_NUM,
        DEBIT_AMOUNT,
        CREDIT_AMOUNT)
SELECT 	DISTINCT '||x_request_id||',
		jel.code_combination_id          ,
		''ERDL''			 ,
		jeh.period_name			 ,
		pdr.project_id			 ,
		NULL		                 ,
		pdr.draft_revenue_num            ,
		pdr.transferred_date             ,
		pdr.gl_date			 ,
		NULL		                 ,
		to_date(NULL)		         ,
		rdl.task_id			 ,
		NULL		                 ,
		NULL 			 	 ,
		to_number(null)			 ,
		rdl.line_num			 ,
                rdl.event_num                    ,
		to_number(null)			 ,
		rdl.amount
FROM
	pa_cust_event_rdl_all	rdl,
	pa_draft_revenues	pdr, /* Modified for bug 3261580 */
	gl_code_combinations    cc,
	gl_je_sources		jes,
	gl_je_lines   		jel,
	gl_je_headers		jeh,
	gl_je_batches		jeb
WHERE
	pdr.transfer_status_code = ''A''
AND	rdl.project_id 		= pdr.project_id
AND	rdl.draft_revenue_num	= pdr.draft_revenue_num
AND	cc.code_combination_id  = rdl.code_combination_id
AND   	jes.je_source_name = ''Project Accounting''
AND	jeh.je_header_id	= jel.je_header_id
AND	jeh.je_batch_id		= jeb.je_batch_id
AND     pdr.event_id IS NULL
AND	jel.code_combination_id	= rdl.code_combination_id
AND	jeh.reversed_je_header_id is null
AND     '||x_gl_date_where_clause ||'
AND	TRUNC(pdr.transferred_date) BETWEEN
	nvl(TRUNC(TO_DATE('''||to_char(x_from_date,'DD-MM-RRRR')||''',''DD-MM-RRRR'')), TRUNC(pdr.transferred_date))
AND	nvl(TRUNC(TO_DATE('''||to_char(x_to_date,'DD-MM-RRRR')||''',''DD-MM-RRRR'')),TRUNC(pdr.transferred_date))
AND	'||x_where_cc||'
AND	rdl.batch_name		= jel.reference_1' ;


DBMS_SQL.PARSE (erdl_cur1, erdl_stmt1, DBMS_SQL.NATIVE);
fdbk := DBMS_SQL.EXECUTE (erdl_cur1);
DBMS_SQL.CLOSE_CURSOR (erdl_cur1);
COMMIT;

/*
Insertion of RDL lines
======================
*/

rdl_stmt := 'insert into pa_gl_rev_xfer_audit_rep
(
        REQUEST_ID,
        CODE_COMBINATION_ID,
        LINE_TYPE,
        PERIOD_NAME,
        PROJECT_ID,
        PROJECT_NUMBER,
        DRAFT_REV_NUMBER,
        TRANSFERRED_DATE,
        GL_DATE,
        TRANSACTION_TYPE,
        TRANSACTION_DATE,
        TASK_ID,
        TASK_NUMBER,
        EMP_OR_ORG_NAME,
        EXPENDITURE_ITEM_ID,
        RDL_LINE_NUM,
        RDL_EVENT_NUM,
        DEBIT_AMOUNT,
        CREDIT_AMOUNT)
SELECT /*+ LEADING(cc) */ DISTINCT '||x_request_id||', /* Added LEADING Hint for Bug 5560164 */
                ael.code_combination_id ,
                ''RDL''                         ,
                aeh.period_name                 ,
                pdr.project_id                  ,
                NULL                            ,
                pdr.draft_revenue_num           ,
                pdr.transferred_date            ,
                pdr.gl_date                     ,
                NULL                            ,
                NULL                            ,
                NULL                            ,
                NULL                            ,
                NULL                            ,
                rdl.expenditure_item_id         ,
                rdl.line_num                    ,
                to_number(null)                 ,
                to_number(null)                 ,
                rdl.amount
FROM
                pa_cust_rev_dist_lines_all      rdl,
                pa_draft_revenues               pdr,
		gl_code_combinations    cc,
                xla_ae_lines            		ael,
	        xla_ae_headers          		aeh,
                xla_distribution_links  		xdl
WHERE   pdr.transfer_status_code 		= ''A''
AND     rdl.project_id          		= pdr.project_id
AND     rdl.draft_revenue_num  	 		= pdr.draft_revenue_num
AND     aeh.ae_header_id        		= ael.ae_header_id
AND     aeh.event_id				= pdr.event_id
AND     aeh.application_id      		= 275
AND   	xdl.ae_header_id   			= aeh.ae_header_id
AND   	xdl.ae_line_num    			= ael.ae_line_num
AND     xdl.event_id				= pdr.event_id
AND 	xdl.source_distribution_type  		= ''Revenue - Normal Revenue''
AND     xdl.source_distribution_id_num_1	= rdl.expenditure_item_id
AND     xdl.source_distribution_id_num_2	= rdl.line_num
AND     aeh.balance_type_code                  = ''A''
AND     aeh.accounting_entry_status_code       = ''F''
AND	pdr.event_id 	IS NOT NULL
AND     '||x_gl_date_where_clause ||'         /* Added for bug 7006975*/
AND             TRUNC(pdr.transferred_date) BETWEEN
                nvl(TRUNC(TO_DATE('''||to_char(x_from_date,'DD-MM-RRRR')||''',''DD-MM-RRRR'')), TRUNC(pdr.transferred_date))
AND             nvl(TRUNC(TO_DATE('''||to_char(x_to_date,'DD-MM-RRRR')||''',''DD-MM-RRRR'')),TRUNC(pdr.transferred_date))
AND     ael.code_combination_id = cc.code_combination_id
AND             '||x_where_cc;

DBMS_SQL.PARSE (rdl_cur, rdl_stmt, DBMS_SQL.NATIVE);
fdbk := DBMS_SQL.EXECUTE (rdl_cur);
DBMS_SQL.CLOSE_CURSOR (rdl_cur);


rdl_stmt1 := 'insert into pa_gl_rev_xfer_audit_rep
(
        REQUEST_ID,
        CODE_COMBINATION_ID,
        LINE_TYPE,
        PERIOD_NAME,
        PROJECT_ID,
        PROJECT_NUMBER,
        DRAFT_REV_NUMBER,
        TRANSFERRED_DATE,
        GL_DATE,
        TRANSACTION_TYPE,
        TRANSACTION_DATE,
        TASK_ID,
        TASK_NUMBER,
        EMP_OR_ORG_NAME,
        EXPENDITURE_ITEM_ID,
        RDL_LINE_NUM,
        RDL_EVENT_NUM,
        DEBIT_AMOUNT,
        CREDIT_AMOUNT)
SELECT /*+ LEADING(cc) */ DISTINCT '||x_request_id||', /* Added LEADING Hint for Bug 5560164 */
		jel.code_combination_id	,
		''RDL''				,
		jeh.period_name			,
		pdr.project_id			,
		NULL				,
		pdr.draft_revenue_num		,
		pdr.transferred_date		,
	        pdr.gl_date			,
		NULL				,
		NULL				,
		NULL				,
		NULL				,
		NULL				,
		rdl.expenditure_item_id		,
		rdl.line_num			,
                to_number(null)                 ,
		to_number(null)	  		,
		rdl.amount
FROM
		gl_je_sources			jes,
		pa_cust_rev_dist_lines_all	rdl,
		pa_draft_revenues		pdr,     /* Modified for bug 3261580 */
      		gl_je_lines   			jel,
		gl_je_headers			jeh,
		gl_je_batches			jeb,
		gl_code_combinations		cc
WHERE		pdr.transfer_status_code = ''A''
AND		rdl.project_id 		= pdr.project_id
AND		rdl.draft_revenue_num	= pdr.draft_revenue_num
AND		jeh.je_header_id	= jel.je_header_id
AND		jeh.je_batch_id		= jeb.je_batch_id
AND		rdl.batch_name		= jel.reference_1
AND		jel.code_combination_id	= rdl.code_combination_id
AND   		jes.je_source_name = ''Project Accounting''
AND             jes.je_source_name = jeh.je_source
AND		jel.code_combination_id = cc.code_combination_id
AND		jeh.reversed_je_header_id is null
AND		'||x_gl_date_where_clause||'
AND		TRUNC(pdr.transferred_date) BETWEEN
		nvl(TRUNC(TO_DATE('''||to_char(x_from_date,'DD-MM-RRRR')||''',''DD-MM-RRRR'')), TRUNC(pdr.transferred_date))
AND		nvl(TRUNC(TO_DATE('''||to_char(x_to_date,'DD-MM-RRRR')||''',''DD-MM-RRRR'')),TRUNC(pdr.transferred_date))
AND		'||x_where_cc||'
AND 		pdr.event_id IS NULL ';


DBMS_SQL.PARSE (rdl_cur1, rdl_stmt1, DBMS_SQL.NATIVE);
fdbk := DBMS_SQL.EXECUTE (rdl_cur1);
DBMS_SQL.CLOSE_CURSOR (rdl_cur1);

update pa_gl_rev_xfer_audit_rep rep set (TRANSACTION_TYPE,TRANSACTION_DATE,TASK_ID,EMP_OR_ORG_NAME) =
					(select	ei.expenditure_type,ei.expenditure_item_date,ei.task_id,DECODE(emp.full_name, null,org.name, emp.full_name )
					 from	hr_organization_units   	org,
						per_people_f			emp,
						pa_expenditure_items_all	ei,
						pa_expenditures_all		exp
					 where  ei.expenditure_item_id = rep.expenditure_item_id
					 AND	ei.expenditure_id	= exp.expenditure_id
					 AND	decode(ei.override_to_organization_id, null, exp.incurred_by_organization_id,ei.override_to_organization_id) =
						org.organization_id
					 AND	exp.incurred_by_person_id  = emp.person_id (+)
					 AND	(ei.expenditure_item_date  BETWEEN nvl(emp.effective_start_date, ei.expenditure_item_date)
					 AND	nvl(emp.effective_end_date,ei.expenditure_item_date ) ))
where	rep.line_type='RDL'
AND	request_id = x_request_id;

COMMIT;


/*
Insertion of UER Lines
======================
*/
uer_stmt := 'insert into pa_gl_rev_xfer_audit_rep
(
        REQUEST_ID,
        CODE_COMBINATION_ID,
        LINE_TYPE,
        PERIOD_NAME,
        PROJECT_ID,
        PROJECT_NUMBER,
        DRAFT_REV_NUMBER,
        TRANSFERRED_DATE,
        GL_DATE,
        TRANSACTION_TYPE,
        TRANSACTION_DATE,
        TASK_ID,
        TASK_NUMBER,
        EMP_OR_ORG_NAME,
        EXPENDITURE_ITEM_ID,
        RDL_LINE_NUM,
        RDL_EVENT_NUM,
        DEBIT_AMOUNT,
        CREDIT_AMOUNT)
SELECT /*+ LEADING(cc) */ DISTINCT '||x_request_id||', /* Added LEADING Hint for Bug 5560164 */
                ael.code_combination_id         ,
                ''UER''                         ,
                aeh.period_name                 ,
                pdr.project_id                  ,
                NULL                            ,
                pdr.draft_revenue_num           ,
                pdr.transferred_date            ,
                pdr.gl_date                     ,
                null                            ,
                to_date(null)                   ,
                to_number(null)                 ,
                null                            ,
                null                            ,
                to_number(null)                 ,
                to_number(null)                 ,
                to_number(null)                 ,
                -1*pdr.unearned_revenue_cr      ,
                to_number(null)
FROM
                pa_draft_Revenues       pdr,
		gl_code_combinations    cc,
                xla_ae_lines      	  ael,
		xla_ae_headers            aeh,
                xla_distribution_links    xdl
WHERE
        pdr.transfer_status_code 		= ''A''
AND     aeh.ae_header_id        		= ael.ae_header_id
AND     aeh.event_id				= pdr.event_id
AND     aeh.application_id      		= 275
AND   	xdl.ae_header_id   			= aeh.ae_header_id
AND   	xdl.ae_line_num    			= ael.ae_line_num
AND     xdl.event_id				= pdr.event_id
AND 	xdl.source_distribution_type  		= ''Revenue - UER''
AND     xdl.source_distribution_id_num_1	= pdr.project_id
AND     xdl.source_distribution_id_num_2	= pdr.draft_revenue_num
AND aeh.balance_type_code                  = ''A''
AND aeh.accounting_entry_status_code       = ''F''
AND	pdr.event_id 	IS NOT NULL
AND             '||x_gl_date_where_clause||'
AND             TRUNC(pdr.transferred_date) BETWEEN
                nvl(TRUNC(TO_DATE('''||to_char(x_from_date,'DD-MM-RRRR')||''',''DD-MM-RRRR'')), TRUNC(pdr.transferred_date))
AND             nvl(TRUNC(TO_DATE('''||to_char(x_to_date,'DD-MM-RRRR')||''',''DD-MM-RRRR'')),TRUNC(pdr.transferred_date))
AND     ael.code_combination_id = cc.code_combination_id
AND             '||x_where_cc;

DBMS_SQL.PARSE (uer_cur, uer_stmt, DBMS_SQL.NATIVE);
fdbk := DBMS_SQL.EXECUTE (uer_cur);
DBMS_SQL.CLOSE_CURSOR (uer_cur);
COMMIT;


uer_stmt1 := 'insert into pa_gl_rev_xfer_audit_rep
(
        REQUEST_ID,
        CODE_COMBINATION_ID,
        LINE_TYPE,
        PERIOD_NAME,
        PROJECT_ID,
        PROJECT_NUMBER,
        DRAFT_REV_NUMBER,
        TRANSFERRED_DATE,
        GL_DATE,
        TRANSACTION_TYPE,
        TRANSACTION_DATE,
        TASK_ID,
        TASK_NUMBER,
        EMP_OR_ORG_NAME,
        EXPENDITURE_ITEM_ID,
        RDL_LINE_NUM,
        RDL_EVENT_NUM,
        DEBIT_AMOUNT,
        CREDIT_AMOUNT)
SELECT /*+ LEADING(cc) */ DISTINCT '||x_request_id||', /* Added LEADING Hint for Bug 5560164 */
		jel.code_combination_id 	,
	        ''UER''				,
		jeh.period_name			,
		pdr.project_id			,
		NULL		                ,
		pdr.draft_revenue_num           ,
		pdr.transferred_date            ,
		pdr.gl_date			,
		null                     	,
		to_date(null)           	,
		to_number(null)		 	,
		null	                  	,
		null                    	,
		to_number(null)			,
		to_number(null)			,
		to_number(null)			,
		-1*pdr.unearned_revenue_cr	,
		to_number(null)
FROM
		gl_je_sources		jes,
		pa_draft_Revenues       pdr, /* Modified for bug 3261580 */
      		gl_je_lines   		jel,
		gl_je_headers		jeh,
		gl_je_batches		jeb,
		gl_code_combinations	cc
WHERE
		pdr.transfer_status_code = ''A''
AND		jeh.je_header_id		= jel.je_header_id
AND		jeh.je_batch_id		= jeb.je_batch_id
AND		pdr.unearned_batch_name  = jel.reference_1
AND		jel.code_combination_id	= pdr.unearned_code_combination_id
AND   		jes.je_source_name = ''Project Accounting''
AND		jel.code_combination_id = cc.code_combination_id
AND		jeh.reversed_je_header_id is null
AND		'||x_gl_date_where_clause||'
AND		TRUNC(pdr.transferred_date) BETWEEN
		nvl(TRUNC(TO_DATE('''||to_char(x_from_date,'DD-MM-RRRR')||''',''DD-MM-RRRR'')), TRUNC(pdr.transferred_date))
AND		nvl(TRUNC(TO_DATE('''||to_char(x_to_date,'DD-MM-RRRR')||''',''DD-MM-RRRR'')),TRUNC(pdr.transferred_date))
AND		'||x_where_cc||'
AND             pdr.event_id IS NULL ';

DBMS_SQL.PARSE (uer_cur1, uer_stmt1, DBMS_SQL.NATIVE);
fdbk := DBMS_SQL.EXECUTE (uer_cur1);
DBMS_SQL.CLOSE_CURSOR (uer_cur1);
COMMIT;

/*
Insertion of UBR Lines
======================
*/
ubr_stmt := 'insert into pa_gl_rev_xfer_audit_rep
(
        REQUEST_ID,
        CODE_COMBINATION_ID,
        LINE_TYPE,
        PERIOD_NAME,
        PROJECT_ID,
        PROJECT_NUMBER,
        DRAFT_REV_NUMBER,
        TRANSFERRED_DATE,
        GL_DATE,
        TRANSACTION_TYPE,
        TRANSACTION_DATE,
        TASK_ID,
        TASK_NUMBER,
        EMP_OR_ORG_NAME,
        EXPENDITURE_ITEM_ID,
        RDL_LINE_NUM,
        RDL_EVENT_NUM,
        DEBIT_AMOUNT,
        CREDIT_AMOUNT)
SELECT /*+ LEADING(cc) */ DISTINCT '||x_request_id||', /* Added LEADING Hint for Bug 5560164 */
               ael.code_combination_id          ,
               ''UBR''                          ,
               aeh.period_name                  ,
               pdr.project_id                   ,
               NULL                             ,
               pdr.draft_revenue_num            ,
               pdr.transferred_date             ,
               pdr.gl_date                      ,
               null                             ,
               to_date(null)                    ,
               to_number(null)                  ,
               null                             ,
               null                             ,
               to_number(null)                  ,
               to_number(null)                  ,
               to_number(null)                  ,
               pdr.unbilled_receivable_dr       ,
               to_number(null)
FROM
                pa_draft_Revenues       pdr,
		gl_code_combinations    cc,
                xla_ae_lines      	  ael,
		xla_ae_headers            aeh,
                xla_distribution_links    xdl
WHERE pdr.transfer_status_code 		= ''A''
AND     aeh.ae_header_id        		= ael.ae_header_id
AND     aeh.event_id				= pdr.event_id
AND     aeh.application_id      		= 275
AND   	xdl.ae_header_id   			= aeh.ae_header_id
AND   	xdl.ae_line_num    			= ael.ae_line_num
AND     xdl.event_id				= pdr.event_id
AND 	xdl.source_distribution_type  		= ''Revenue - UBR''
AND     xdl.source_distribution_id_num_1	= pdr.project_id
AND     xdl.source_distribution_id_num_2	= pdr.draft_revenue_num
     AND aeh.balance_type_code                  = ''A''
     AND aeh.accounting_entry_status_code       = ''F''
AND	pdr.event_id 	IS NOT NULL
AND             '||x_gl_date_where_clause||'
AND             TRUNC(pdr.transferred_date) BETWEEN
                nvl(TRUNC(TO_DATE('''||to_char(x_from_date,'DD-MM-RRRR')||''',''DD-MM-RRRR'')), TRUNC(pdr.transferred_date))
AND             nvl(TRUNC(TO_DATE('''||to_char(x_to_date,'DD-MM-RRRR')||''',''DD-MM-RRRR'')),TRUNC(pdr.transferred_date))
AND     ael.code_combination_id = cc.code_combination_id
AND             '||x_where_cc;

DBMS_SQL.PARSE (ubr_cur, ubr_stmt, DBMS_SQL.NATIVE);
fdbk := DBMS_SQL.EXECUTE (ubr_cur);
DBMS_SQL.CLOSE_CURSOR (ubr_cur);
COMMIT;


ubr_stmt1 := 'insert into pa_gl_rev_xfer_audit_rep
(
        REQUEST_ID,
        CODE_COMBINATION_ID,
        LINE_TYPE,
        PERIOD_NAME,
        PROJECT_ID,
        PROJECT_NUMBER,
        DRAFT_REV_NUMBER,
        TRANSFERRED_DATE,
        GL_DATE,
        TRANSACTION_TYPE,
        TRANSACTION_DATE,
        TASK_ID,
        TASK_NUMBER,
        EMP_OR_ORG_NAME,
        EXPENDITURE_ITEM_ID,
        RDL_LINE_NUM,
        RDL_EVENT_NUM,
        DEBIT_AMOUNT,
        CREDIT_AMOUNT)
SELECT /*+ LEADING(cc) */ DISTINCT '||x_request_id||', /* Added LEADING Hint for Bug 5560164 */
               jel.code_combination_id 		,
	       ''UBR''				,
	       jeh.period_name			,
	       pdr.project_id			,
               NULL				,
               pdr.draft_revenue_num		,
               pdr.transferred_date		,
	       pdr.gl_date			,
               null                     	,
               to_date(null)           		,
	       to_number(null)		 	,
               null	                  	,
               null                    		,
	       to_number(null)			,
	       to_number(null)			,
               to_number(null)                  ,
               pdr.unbilled_receivable_dr	,
	       to_number(null)
FROM
		gl_je_sources		jes,
		pa_draft_Revenues	pdr, /* Modified for bug 3261580 */
      		gl_je_lines   		jel,
		gl_je_headers		jeh,
		gl_je_batches		jeb,
		gl_code_combinations	cc
WHERE
		pdr.transfer_status_code = ''A''
AND		jeh.je_header_id	= jel.je_header_id
AND		jeh.je_batch_id		= jeb.je_batch_id
AND		pdr.unbilled_batch_name = jel.reference_1
AND		jel.code_combination_id	= pdr.unbilled_code_combination_id
AND		jes.je_source_name = ''Project Accounting''
AND		jel.code_combination_id = cc.code_combination_id
AND		jeh.reversed_je_header_id is null
AND		'||x_gl_date_where_clause||'
AND		TRUNC(pdr.transferred_date) BETWEEN
		nvl(TRUNC(TO_DATE('''||to_char(x_from_date,'DD-MM-RRRR')||''',''DD-MM-RRRR'')), TRUNC(pdr.transferred_date))
AND		nvl(TRUNC(TO_DATE('''||to_char(x_to_date,'DD-MM-RRRR')||''',''DD-MM-RRRR'')),TRUNC(pdr.transferred_date))
AND		'||x_where_cc||'
AND 		pdr.event_id IS NULL ';

DBMS_SQL.PARSE (ubr_cur1, ubr_stmt1, DBMS_SQL.NATIVE);
fdbk := DBMS_SQL.EXECUTE (ubr_cur1);
DBMS_SQL.CLOSE_CURSOR (ubr_cur1);
COMMIT;

/*
Insertion of RLZD-GAIN lines
============================
*/
gain_stmt :='insert into pa_gl_rev_xfer_audit_rep
(
        REQUEST_ID,
        CODE_COMBINATION_ID,
        LINE_TYPE,
        PERIOD_NAME,
        PROJECT_ID,
        PROJECT_NUMBER,
        DRAFT_REV_NUMBER,
        TRANSFERRED_DATE,
        GL_DATE,
        TRANSACTION_TYPE,
        TRANSACTION_DATE,
        TASK_ID,
        TASK_NUMBER,
        EMP_OR_ORG_NAME,
        EXPENDITURE_ITEM_ID,
        RDL_LINE_NUM,
        RDL_EVENT_NUM,
        DEBIT_AMOUNT,
        CREDIT_AMOUNT)
SELECT DISTINCT '||x_request_id||'              ,
               ael.code_combination_id         ,
                ''RLZD-GAIN''                   ,
               aeh.period_name                 ,
               pdr.project_id                   ,
               NULL                             ,
               pdr.draft_revenue_num            ,
               pdr.transferred_date             ,
               pdr.gl_date                      ,
               null                             ,
               to_date(null)                    ,
               to_number(null)                  ,
               null                             ,
               null                             ,
               to_number(null)                  ,
               to_number(null)                  ,
               to_number(null)                  ,
               -1*pdr.unearned_revenue_cr       ,
               to_number(null)
FROM
                pa_draft_Revenues       pdr,
		gl_code_combinations    cc,
	        xla_ae_lines      	  ael,
		xla_ae_headers            aeh,
                xla_distribution_links    xdl
WHERE           pdr.transfer_status_code 	= ''A''
AND     aeh.ae_header_id        		= ael.ae_header_id
AND     aeh.event_id				= pdr.event_id
AND     aeh.application_id      		= 275
AND   	xdl.ae_header_id   			= aeh.ae_header_id
AND   	xdl.ae_line_num    			= ael.ae_line_num
AND     xdl.event_id				= pdr.event_id
AND 	xdl.source_distribution_type  		= ''Revenue - Realized Gains''
AND     xdl.source_distribution_id_num_1	= pdr.project_id
AND     xdl.source_distribution_id_num_2	= pdr.draft_revenue_num
AND     aeh.balance_type_code                  = ''A''
AND     aeh.accounting_entry_status_code       = ''F''
AND	pdr.event_id 	IS NOT NULL
AND             '||x_gl_date_where_clause||'
AND             TRUNC(pdr.transferred_date) BETWEEN
                nvl(TRUNC(TO_DATE('''||to_char(x_from_date,'DD-MM-RRRR')||''',''DD-MM-RRRR'')), TRUNC(pdr.transferred_date))
AND             nvl(TRUNC(TO_DATE('''||to_char(x_to_date,'DD-MM-RRRR')||''',''DD-MM-RRRR'')),TRUNC(pdr.transferred_date))
AND     ael.code_combination_id = cc.code_combination_id
AND             '||x_where_cc;

DBMS_SQL.PARSE (gain_cur, gain_stmt, DBMS_SQL.NATIVE);
fdbk := DBMS_SQL.EXECUTE (gain_cur);
DBMS_SQL.CLOSE_CURSOR (gain_cur);
COMMIT;



gain_stmt1 :='insert into pa_gl_rev_xfer_audit_rep
(
        REQUEST_ID,
        CODE_COMBINATION_ID,
        LINE_TYPE,
        PERIOD_NAME,
        PROJECT_ID,
        PROJECT_NUMBER,
        DRAFT_REV_NUMBER,
        TRANSFERRED_DATE,
        GL_DATE,
        TRANSACTION_TYPE,
        TRANSACTION_DATE,
        TASK_ID,
        TASK_NUMBER,
        EMP_OR_ORG_NAME,
        EXPENDITURE_ITEM_ID,
        RDL_LINE_NUM,
        RDL_EVENT_NUM,
        DEBIT_AMOUNT,
        CREDIT_AMOUNT)
SELECT DISTINCT '||x_request_id||'		,
		jel.code_combination_id		,
	        ''RLZD-GAIN''			,
		jeh.period_name			,
	       pdr.project_id			,
               NULL				,
               pdr.draft_revenue_num		,
               pdr.transferred_date		,
	       pdr.gl_date			,
               null				,
               to_date(null)			,
	       to_number(null)			,
               null				,
               null				,
	       to_number(null)			,
	       to_number(null)			,
               to_number(null)			,
               -1*pdr.unearned_revenue_cr	,
	       to_number(null)
FROM
		gl_je_sources		jes,
		pa_draft_Revenues	pdr, /* Modified for bug 3261580 */
      		gl_je_lines   		jel,
		gl_je_headers		jeh,
		gl_je_batches		jeb,
		gl_code_combinations    cc
WHERE		pdr.transfer_status_code = ''A''
AND		jeh.je_header_id	= jel.je_header_id
AND		jeh.je_batch_id		= jeb.je_batch_id
AND		jeh.reversed_je_header_id is null
AND		pdr.realized_gains_batch_name  = jel.reference_1
AND		jel.code_combination_id	= pdr.realized_gains_ccid
AND		jel.code_combination_id = cc.code_combination_id
AND   		jes.je_source_name = ''Project Accounting''
AND		'||x_gl_date_where_clause||'
AND		TRUNC(pdr.transferred_date) BETWEEN
		nvl(TRUNC(TO_DATE('''||to_char(x_from_date,'DD-MM-RRRR')||''',''DD-MM-RRRR'')), TRUNC(pdr.transferred_date))
AND		nvl(TRUNC(TO_DATE('''||to_char(x_to_date,'DD-MM-RRRR')||''',''DD-MM-RRRR'')),TRUNC(pdr.transferred_date))
AND		'||x_where_cc||'
AND             pdr.event_id IS NULL ';

DBMS_SQL.PARSE (gain_cur1, gain_stmt1, DBMS_SQL.NATIVE);
fdbk := DBMS_SQL.EXECUTE (gain_cur1);
DBMS_SQL.CLOSE_CURSOR (gain_cur1);
COMMIT;

/*
Insertion of RLZD-LOSS lines
============================
*/
loss_stmt :='insert into pa_gl_rev_xfer_audit_rep
(
        REQUEST_ID,
        CODE_COMBINATION_ID,
        LINE_TYPE,
        PERIOD_NAME,
        PROJECT_ID,
        PROJECT_NUMBER,
        DRAFT_REV_NUMBER,
        TRANSFERRED_DATE,
        GL_DATE,
        TRANSACTION_TYPE,
        TRANSACTION_DATE,
        TASK_ID,
        TASK_NUMBER,
        EMP_OR_ORG_NAME,
        EXPENDITURE_ITEM_ID,
        RDL_LINE_NUM,
        RDL_EVENT_NUM,
        DEBIT_AMOUNT,
        CREDIT_AMOUNT)
SELECT DISTINCT '||x_request_id||'              ,
               ael.code_combination_id          ,
               ''RLZD-LOSS''                    ,
                aeh.period_name                 ,
               pdr.project_id                   ,
               NULL                             ,
               pdr.draft_revenue_num            ,
               pdr.transferred_date             ,
               pdr.gl_date                      ,
               null                             ,
               to_date(null)                    ,
               to_number(null)                  ,
               null                             ,
               null                             ,
               to_number(null)                  ,
               to_number(null)                  ,
               to_number(null)                  ,
               -1*pdr.unearned_revenue_cr       ,
               to_number(null)
FROM
                pa_draft_Revenues       pdr,
		gl_code_combinations    cc,
                xla_ae_lines      	  ael,
		xla_ae_headers            aeh,
                xla_distribution_links    xdl
WHERE           pdr.transfer_status_code 	= ''A''
AND     aeh.ae_header_id        		= ael.ae_header_id
AND     aeh.event_id				= pdr.event_id
AND     aeh.application_id      		= 275
AND   	xdl.ae_header_id   			= aeh.ae_header_id
AND   	xdl.ae_line_num    			= ael.ae_line_num
AND     xdl.event_id				= pdr.event_id
AND 	xdl.source_distribution_type  		= ''Revenue - Realized Losses''
AND     xdl.source_distribution_id_num_1	= pdr.project_id
AND     xdl.source_distribution_id_num_2	= pdr.draft_revenue_num
AND     aeh.balance_type_code                  = ''A''
AND     aeh.accounting_entry_status_code       = ''F''
AND	pdr.event_id 	IS NOT NULL
AND             '||x_gl_date_where_clause||'
AND             TRUNC(pdr.transferred_date) BETWEEN
                nvl(TRUNC(TO_DATE('''||to_char(x_from_date,'DD-MM-RRRR')||''',''DD-MM-RRRR'')), TRUNC(pdr.transferred_date))
AND             nvl(TRUNC(TO_DATE('''||to_char(x_to_date,'DD-MM-RRRR')||''',''DD-MM-RRRR'')),TRUNC(pdr.transferred_date))
AND     ael.code_combination_id = cc.code_combination_id
AND             '||x_where_cc;

DBMS_SQL.PARSE (loss_cur, loss_stmt, DBMS_SQL.NATIVE);
fdbk := DBMS_SQL.EXECUTE (loss_cur);
DBMS_SQL.CLOSE_CURSOR (loss_cur);
COMMIT;

loss_stmt1 :='insert into pa_gl_rev_xfer_audit_rep
(
        REQUEST_ID,
        CODE_COMBINATION_ID,
        LINE_TYPE,
        PERIOD_NAME,
        PROJECT_ID,
        PROJECT_NUMBER,
        DRAFT_REV_NUMBER,
        TRANSFERRED_DATE,
        GL_DATE,
        TRANSACTION_TYPE,
        TRANSACTION_DATE,
        TASK_ID,
        TASK_NUMBER,
        EMP_OR_ORG_NAME,
        EXPENDITURE_ITEM_ID,
        RDL_LINE_NUM,
        RDL_EVENT_NUM,
        DEBIT_AMOUNT,
        CREDIT_AMOUNT)
SELECT DISTINCT '||x_request_id||'		,
               jel.code_combination_id		,
	       ''RLZD-LOSS''			,
		jeh.period_name			,
	       pdr.project_id			,
               NULL				,
               pdr.draft_revenue_num		,
               pdr.transferred_date		,
	       pdr.gl_date			,
               null				,
               to_date(null)			,
	       to_number(null)			,
               null				,
               null				,
	       to_number(null)			,
	       to_number(null)			,
               to_number(null)			,
               -1*pdr.unearned_revenue_cr	,
	       to_number(null)
FROM
		gl_je_sources		jes,
		pa_draft_Revenues	pdr,  /* Modified for bug 3261580 */
      		gl_je_lines   		jel,
		gl_je_headers		jeh,
		gl_je_batches		jeb,
		gl_code_combinations    cc
WHERE		pdr.transfer_status_code = ''A''
AND		jeh.je_header_id		= jel.je_header_id
AND		jeh.je_batch_id		= jeb.je_batch_id
AND		jeh.reversed_je_header_id is null
AND		pdr.realized_losses_batch_name  = jel.reference_1
AND		jel.code_combination_id	= pdr.realized_losses_ccid
AND		jel.code_combination_id = cc.code_combination_id
AND   		jes.je_source_name = ''Project Accounting''
AND		'||x_gl_date_where_clause||'
AND		TRUNC(pdr.transferred_date) BETWEEN
		nvl(TRUNC(TO_DATE('''||to_char(x_from_date,'DD-MM-RRRR')||''',''DD-MM-RRRR'')), TRUNC(pdr.transferred_date))
AND		nvl(TRUNC(TO_DATE('''||to_char(x_to_date,'DD-MM-RRRR')||''',''DD-MM-RRRR'')),TRUNC(pdr.transferred_date))
AND		'||x_where_cc||'
AND            pdr.event_id IS NULL ';

DBMS_SQL.PARSE (loss_cur1, loss_stmt1, DBMS_SQL.NATIVE);
fdbk := DBMS_SQL.EXECUTE (loss_cur1);
DBMS_SQL.CLOSE_CURSOR (loss_cur1);
COMMIT;


/*
Summary updation
=================
*/

UPDATE  pa_gl_rev_xfer_audit_rep a
SET	project_number = (SELECT p.segment1 FROM pa_projects p WHERE p.project_id = a.project_id)
WHERE	request_id = x_request_id;

DELETE	pa_gl_rev_xfer_audit_rep
WHERE	request_id = x_request_id
AND	project_number IS NULL;

UPDATE  pa_gl_rev_xfer_audit_rep a
SET	task_number = (SELECT t.task_number FROM pa_tasks t WHERE t.task_id=a.task_id)
WHERE   task_id IS NOT NULL
AND	request_id = x_request_id;


UPDATE  pa_gl_rev_xfer_audit_rep a
SET	(transaction_type,transaction_date) = (	SELECT	event_type,completion_date
						FROM	pa_events pe
						WHERE	a.project_id = pe.project_id
						AND	NVL(a.task_id,-1)	= NVL(pe.task_id,-1)
						AND	a.rdl_event_num		= pe.event_num)
WHERE	line_type = 'ERDL'
AND	request_id = x_request_id;


COMMIT;
END process;

END pa_gl_rev_xfer_audit_pkg;

/
