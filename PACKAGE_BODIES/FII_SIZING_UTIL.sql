--------------------------------------------------------
--  DDL for Package Body FII_SIZING_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_SIZING_UTIL" AS
/* $Header: FIISZ01B.pls 120.1 2005/06/07 11:57:04 sgautam noship $ */
PROCEDURE fii_pa_revenue_f_cnt (p_from_date DATE,
                   	p_to_date DATE,
                   	p_num_rows OUT NOCOPY /* file.sql.39 change */ NUMBER) IS
cursor c_cnt_rows is
  select SUM(cnt) from
   (select count(*) cnt
     FROM pa_cust_rev_dist_lines_all
     WHERE program_update_date BETWEEN p_from_date and p_to_date
     and function_code NOT IN ('LRL','LRB','URL','URB')
   UNION ALL
     select count(*) cnt
     FROM pa_cust_event_rdl_all
     WHERE program_update_date BETWEEN p_from_date and p_to_date);
BEGIN
 open c_cnt_rows;
 fetch c_cnt_rows into p_num_rows;
 close c_cnt_rows;
EXCEPTION
 When OTHERS
 then p_num_rows := Null;
END;


PROCEDURE fii_pa_revenue_f_len (p_from_date DATE,p_to_date DATE,p_avg_row_len OUT NOCOPY /* file.sql.39 change */ NUMBER) IS
BEGIN
  p_avg_row_len := 173;
END;


PROCEDURE fii_pa_cost_f_cnt (p_from_date DATE,
                   	p_to_date DATE,
                   	p_num_rows OUT NOCOPY /* file.sql.39 change */ NUMBER) IS
cursor c_cnt_rows is
  select count(*)
  from pa_cost_distribution_lines_all
   WHERE line_type = 'R'
   AND program_update_date BETWEEN p_from_date AND p_to_date;
BEGIN
 open c_cnt_rows;
 fetch c_cnt_rows into p_num_rows;
 close c_cnt_rows;
EXCEPTION
 When OTHERS
 then p_num_rows := Null;
END;

PROCEDURE fii_pa_cost_f_len (p_from_date DATE,p_to_date DATE,p_avg_row_len OUT NOCOPY /* file.sql.39 change */ NUMBER) IS
BEGIN
  p_avg_row_len := 212;
END;


PROCEDURE fii_pa_budget_f_cnt (p_from_date DATE,
                   	p_to_date DATE,
                   	p_num_rows OUT NOCOPY /* file.sql.39 change */ NUMBER) IS
cursor c_cnt_rows is
  SELECT count(*)
   FROM  pa_budget_lines
   WHERE last_update_date BETWEEN p_from_date AND p_to_date;
BEGIN
 open c_cnt_rows;
 fetch c_cnt_rows into p_num_rows;
 close c_cnt_rows;
EXCEPTION
 When OTHERS
 then p_num_rows := Null;
END;


PROCEDURE fii_pa_budget_f_len (p_from_date DATE,p_to_date DATE,p_avg_row_len OUT NOCOPY /* file.sql.39 change */ NUMBER) IS
BEGIN
  p_avg_row_len := 190;
END;

PROCEDURE fii_pa_budget_m_cnt (p_from_date DATE,
                   	p_to_date DATE,
                   	p_num_rows OUT NOCOPY /* file.sql.39 change */ NUMBER) IS
 cursor c_cnt_rows is
  select count(*)
  FROM
   PA_BUDGET_TYPES     BT,
   PA_BUDGET_VERSIONS  BV
  WHERE
      BV.BUDGET_TYPE_CODE = BT.BUDGET_TYPE_CODE
  AND BV.BUDGET_STATUS_CODE = 'B'
  AND BV.LAST_UPDATE_DATE BETWEEN p_from_date AND p_to_date;
BEGIN
 open c_cnt_rows;
 fetch c_cnt_rows into p_num_rows;
 close c_cnt_rows;
EXCEPTION
 When OTHERS
 then p_num_rows := Null;
END;

PROCEDURE fii_pa_budget_m_len (p_from_date DATE,p_to_date DATE,p_avg_row_len OUT NOCOPY /* file.sql.39 change */ NUMBER) IS
BEGIN
  p_avg_row_len := 209;
END;

PROCEDURE fii_pa_exp_type_m_cnt (p_from_date DATE,
	                   p_to_date DATE,
        	           p_num_rows OUT NOCOPY /* file.sql.39 change */ NUMBER) IS
 cursor c_cnt_rows is
  select sum(cnt)
  from (
    select count(*) cnt
    FROM PA_EXPENDITURE_TYPES
    WHERE last_update_date BETWEEN p_from_date AND p_to_date
    UNION ALL
    select count(*) cnt
    FROM PA_LOOKUPS PL,
     PA_LOOKUPS PLU
     WHERE PL.LOOKUP_TYPE = 'ADW DIM LEVEL NAME'
     AND PL.LOOKUP_CODE = 'ALL_EXP_TYPES'
     AND PLU.LOOKUP_TYPE = 'ADW RESOURCE NAME'
     AND PLU.LOOKUP_CODE = 'UNKNOWN');
BEGIN
 open c_cnt_rows;
 fetch c_cnt_rows into p_num_rows;
 close c_cnt_rows;
EXCEPTION
 When OTHERS
 then p_num_rows := Null;
END fii_pa_exp_type_m_cnt;


PROCEDURE fii_pa_exp_type_m_len (p_from_date DATE,p_to_date DATE,p_avg_row_len OUT NOCOPY /* file.sql.39 change */ NUMBER) IS
BEGIN
  p_avg_row_len := 119;
END;

PROCEDURE edw_project_m_cnt (p_from_date DATE,
                   	p_to_date DATE,
                   	p_num_rows OUT NOCOPY /* file.sql.39 change */ NUMBER) IS
 cursor c_cnt_rows IS
   select sum(cnt) from (
    SELECT count(*) cnt
    from pa_tasks  pt
    WHERE (NOT EXISTS
  	(select '*' from pa_tasks
      	where parent_task_id = pt.task_id)
      	OR pt.parent_task_id IS NULL )
    AND	pt.last_update_date BETWEEN p_from_date AND p_to_date
    UNION
    SELECT count(*) cnt
    FROM pa_projects_all pa
    WHERE pa.last_update_date BETWEEN p_from_date AND p_to_date
    UNION
    SELECT count(*) cnt
    FROM pjm_seiban_numbers sb
    WHERE sb.last_update_date BETWEEN p_from_date AND p_to_date);
BEGIN
 open c_cnt_rows;
 fetch c_cnt_rows into p_num_rows;
 close c_cnt_rows;
EXCEPTION
 When OTHERS
 then p_num_rows := Null;
END edw_project_m_cnt;

PROCEDURE edw_project_m_len (p_from_date DATE,p_to_date DATE,p_avg_row_len OUT NOCOPY /* file.sql.39 change */ NUMBER) IS
BEGIN
   p_avg_row_len := 1613;
END;

PROCEDURE FII_AP_INV_ON_HOLD_F_CNT(p_from_date DATE,
                                   p_to_date DATE,
                                   p_num_rows OUT NOCOPY /* file.sql.39 change */ NUMBER) IS

CURSOR c_cnt_rows IS
   SELECT count(*)
   FROM ap_invoices_all ai
   WHERE ai.last_update_date between p_from_date and p_to_date
   AND   ai.invoice_type_lookup_code <> 'EXPENSE REPORT'
   AND   ai.cancelled_date IS NULL
   AND   ((EXISTS (SELECT 'this invoice is on hold' FROM ap_holds_all ah
                   WHERE ai.invoice_id = ah.invoice_id
                   AND   ai.org_id = ah.org_id
                   AND   ah.hold_lookup_code IS NOT NULL
                   AND   ah.release_lookup_code IS NULL))
         OR (EXISTS (SELECT 'this invoice has payment schedule hold' FROM ap_payment_schedules_all aps
                     WHERE ai.invoice_id = aps.invoice_id
                     AND   ai.org_id = aps.org_id
                     AND   NVL(aps.hold_flag, 'N') = 'Y')));
BEGIN
 OPEN c_cnt_rows;
 FETCH c_cnt_rows INTO p_num_rows;
 CLOSE c_cnt_rows;
EXCEPTION
 When OTHERS
 then p_num_rows := Null;
END;

PROCEDURE FII_AP_INV_ON_HOLD_F_LEN (p_from_date DATE,p_to_date DATE,p_avg_row_len OUT NOCOPY /* file.sql.39 change */ NUMBER) IS
BEGIN
   p_avg_row_len := 203;
END;

PROCEDURE FII_AR_TRX_DIST_F_CNT(p_from_date DATE,
                                p_to_date DATE,
                                p_num_rows OUT NOCOPY /* file.sql.39 change */ NUMBER) IS

CURSOR c_cnt_rows IS
select sum(cnt) from
(SELECT count(*) cnt
 FROM
  ra_cust_trx_line_gl_dist_all    ctlgd,
  ra_customer_trx_lines_all       ctl,
  ra_customer_trx_all             ct
 WHERE   ctlgd.account_set_flag = 'N'
 AND     ctlgd.last_update_date between p_from_date and p_to_date
 AND     ctlgd.customer_trx_line_id = ctl.customer_trx_line_id
 AND     (nvl(ctl.interface_line_context, 'xxx') NOT IN ('ORDER ENTRY', 'GEMMS OP')
         OR (ctl.interface_line_context = 'ORDER ENTRY'
              AND translate(ctl.interface_line_attribute6, 'z0123456789', 'z') IS NOT NULL)
         OR (ctl.interface_line_context = 'GEMMS OP'
             AND (ctl.interface_line_attribute1 <> '0')))
 AND     ctl.customer_trx_id = ct.customer_trx_id
 AND     ct.complete_flag = 'Y'
 UNION ALL
 SELECT count(*)
 FROM
  ra_customer_trx_lines_all     ctl,
  ra_customer_trx_all           ct
 WHERE ctl.last_update_date between p_from_date and p_to_date
 AND (nvl(ctl.interface_line_context, 'xxx') <> 'ORDER ENTRY'
        OR (ctl.interface_line_context = 'ORDER ENTRY'
            AND translate(ctl.interface_line_attribute6, 'z0123456789', 'z') IS NOT NULL))
 AND   ctl.customer_trx_id = ct.customer_trx_id
 AND   ct.complete_flag = 'Y'
 UNION ALL
 SELECT count(*)
 FROM
  ar_adjustments_all            adj,
  ra_customer_trx_all           ct
 WHERE  adj.last_update_date between p_from_date and p_to_date
 AND    nvl(adj.status, 'A') = 'A'
 AND    nvl(adj.postable,'Y') = 'Y'
 AND    ct.customer_trx_id  = adj.customer_trx_id
 AND    nvl(ct.org_id, -999) = nvl(adj.org_id, -999)
 AND    ct.complete_flag = 'Y'
 UNION ALL
 SELECT count(*)
 from
  ra_cust_trx_line_gl_dist_all    ctlgd,
  ra_customer_trx_lines_all       ctl,
  ra_customer_trx_all             ct
 WHERE   ctlgd.last_update_date between p_from_date and p_to_date
 AND     ctlgd.account_set_flag = 'N'
 AND     ctlgd.customer_trx_line_id = ctl.customer_trx_line_id
 AND     ctl.customer_trx_id = ct.customer_trx_id
 AND     ctl.interface_line_context = 'ORDER ENTRY'
 AND     DECODE(ctl.interface_line_attribute6, NULL, NULL,
                translate(ctl.interface_line_attribute6, 'z0123456789', 'z')) IS NULL
 AND     ct.complete_flag = 'Y'
 UNION ALL
 SELECT count(*)
 FROM
  ra_customer_trx_lines_all     ctl,
  ra_customer_trx_all           ct
 WHERE  ctl.last_update_date between p_from_date and p_to_date
 AND    ctl.interface_line_context = 'ORDER ENTRY'
 AND    DECODE(ctl.interface_line_attribute6, NULL, NULL,
                translate(ctl.interface_line_attribute6, 'z0123456789', 'z')) IS NULL
 AND    ctl.customer_trx_id = ct.customer_trx_id
 AND    ct.complete_flag = 'Y'
 UNION ALL
 SELECT count(*)
 FROM
  ra_cust_trx_line_gl_dist_all    ctlgd,
  ra_customer_trx_lines_all       ctl,
  ra_customer_trx_all             ct
 WHERE   ctlgd.last_update_date between p_from_date and p_to_date
 AND     ctlgd.account_set_flag = 'N'
 AND     ctlgd.customer_trx_line_id = ctl.customer_trx_line_id
 AND     nvl(ctl.interface_line_context, 'xxx') IN ('GEMMS OP')
 AND     ctl.customer_trx_id = ct.customer_trx_id
 AND     ct.complete_flag = 'Y'
);
BEGIN
 OPEN c_cnt_rows;
 FETCH c_cnt_rows INTO p_num_rows;
 CLOSE c_cnt_rows;
EXCEPTION
 When OTHERS
 then p_num_rows := Null;
END;

PROCEDURE FII_AR_TRX_DIST_F_LEN (p_from_date DATE,p_to_date DATE,p_avg_row_len OUT NOCOPY /* file.sql.39 change */ NUMBER) IS
BEGIN
   p_avg_row_len := 415;
END;

PROCEDURE FII_E_REVENUE_F_CNT(p_from_date DATE,
                              p_to_date DATE,
                              p_num_rows OUT NOCOPY /* file.sql.39 change */ NUMBER) IS

CURSOR c_cnt_rows IS
select sum(cnt) from
(SELECT count(*) cnt
 FROM
  ra_cust_trx_line_gl_dist_all    ctlgd,
  ra_customer_trx_lines_all       ctl,
  ra_customer_trx_all             ct
 WHERE   ctlgd.last_update_date between p_from_date and p_to_date
 AND     ctlgd.account_class not in ('REC','UNBILL')
 AND     ctlgd.account_set_flag = 'N'
 AND     nvl(ctlgd.amount,0) <> 0
 AND     ctlgd.customer_trx_line_id = ctl.customer_trx_line_id
 AND     (nvl(ctl.interface_line_context, 'xxx') NOT IN ('PA INVOICES','ORDER ENTRY')
         OR (ctl.interface_line_context = 'ORDER ENTRY'
              AND translate(ctl.interface_line_attribute6, 'z0123456789', 'z') IS NOT NULL))
 AND     ctl.customer_trx_id = ct.customer_trx_id
 AND     ct.complete_flag = 'Y'
 UNION ALL
 SELECT count(*)
 FROM
  ra_customer_trx_lines_all     ctl,
  ra_customer_trx_all           ct
 WHERE ctl.last_update_date between p_from_date and p_to_date
 AND  (nvl(ctl.interface_line_context, 'xxx') NOT IN ('PA INVOICES', 'ORDER ENTRY')
         OR (ctl.interface_line_context = 'ORDER ENTRY'
              AND translate(ctl.interface_line_attribute6, 'z0123456789', 'z') IS NOT NULL))
 AND    (nvl(ctl.quantity_ordered,0) <> 0  OR
         nvl(ctl.quantity_invoiced,0) <> 0  OR
         nvl(ctl.quantity_credited,0) <> 0)
 AND  ctl.customer_trx_id = ct.customer_trx_id
 AND	ct.complete_flag = 'Y'
 UNION ALL
 SELECT count(*)
 FROM
  ar_adjustments_all            adj,
  ra_customer_trx_all           ct
 WHERE adj.last_update_date between p_from_date and p_to_date
 AND   nvl(adj.status, 'A') = 'A'
 AND   nvl(adj.postable,'Y') = 'Y'
 AND   ct.customer_trx_id  = adj.customer_trx_id
 AND   nvl(ct.org_id, -999) = nvl(adj.org_id, -999)
 AND   ct.complete_flag = 'Y'
 UNION ALL
 SELECT count(*)
 FROM
   gl_je_lines                  jel,
   gl_je_headers                jeh
 WHERE   jel.last_update_date between p_from_date and p_to_date
 AND     jel.status = 'P'
 AND     jel.je_header_id = jeh.je_header_id
 AND     jeh.je_source = 'Manual'
 AND     jeh.actual_flag = 'A'
 UNION ALL
 SELECT count(*)
 FROM
  pa_cust_rev_dist_lines_all    rdl
 WHERE rdl.creation_date between p_from_date and p_to_date
 AND   rdl.function_code NOT IN ('LRL', 'LRB', 'URL', 'URB')
 UNION ALL
 SELECT count(*)
 FROM
  PA_CUST_EVENT_RDL_ALL         RDL
 WHERE  rdl.creation_date between p_from_date and p_to_date
 UNION ALL
 select count(*)
 FROM
  pa_draft_revenues_all         pdr
 WHERE pdr.last_update_date between p_from_date and p_to_date
 AND   pdr.unearned_revenue_cr <> 0
 AND   pdr.released_date IS NOT NULL
 UNION ALL
 SELECT count(*)
 from
  ra_cust_trx_line_gl_dist_all    ctlgd,
  ra_customer_trx_lines_all       ctl,
  ra_customer_trx_all             ct
 WHERE   ctlgd.last_update_date between p_from_date and p_to_date
 AND     ctlgd.account_class not in ('REC','UNBILL')
 AND     ctlgd.account_set_flag = 'N'
 AND     nvl(ctlgd.amount,0) <> 0
 AND     ctlgd.customer_trx_line_id = ctl.customer_trx_line_id
 AND     ctl.customer_trx_id = ct.customer_trx_id
 AND     ctl.interface_line_context = 'ORDER ENTRY'
 AND     DECODE(ctl.interface_line_attribute6, NULL, NULL,
                translate(ctl.interface_line_attribute6, 'z0123456789', 'z')) IS NULL
 AND     ct.complete_flag = 'Y'
 UNION ALL
 SELECT count(*)
 FROM
  ra_customer_trx_lines_all     ctl,
  ra_customer_trx_all           ct
 WHERE   ctl.last_update_date between p_from_date and p_to_date
 AND     ctl.interface_line_context = 'ORDER ENTRY'
 AND     DECODE(ctl.interface_line_attribute6, NULL, NULL,
                translate(ctl.interface_line_attribute6, 'z0123456789', 'z')) IS NULL
 AND    (nvl(ctl.quantity_ordered,0) <> 0  OR
         nvl(ctl.quantity_invoiced,0) <> 0  OR
         nvl(ctl.quantity_credited,0) <> 0)
 AND    ctl.customer_trx_id = ct.customer_trx_id
 AND    ct.complete_flag = 'Y'
);
BEGIN
 OPEN c_cnt_rows;
 FETCH c_cnt_rows INTO p_num_rows;
 CLOSE c_cnt_rows;
EXCEPTION
 When OTHERS
 then p_num_rows := Null;
END;

PROCEDURE FII_E_REVENUE_F_LEN (p_from_date DATE,p_to_date DATE,p_avg_row_len OUT NOCOPY /* file.sql.39 change */ NUMBER) IS
BEGIN
   p_avg_row_len := 410;
END;

PROCEDURE EDW_AR_DOC_NUM_M_CNT(p_from_date DATE,
                               p_to_date DATE,
                               p_num_rows OUT NOCOPY /* file.sql.39 change */ NUMBER) IS

CURSOR c_cnt_rows IS
   SELECT count(*)
   FROM ra_customer_trx_all
   where last_update_date between p_from_date and p_to_date;
BEGIN
 OPEN c_cnt_rows;
 FETCH c_cnt_rows INTO p_num_rows;
 CLOSE c_cnt_rows;
EXCEPTION
 When OTHERS
 then p_num_rows := Null;
END;

PROCEDURE EDW_AR_DOC_NUM_M_LEN (p_from_date DATE,p_to_date DATE,p_avg_row_len OUT NOCOPY /* file.sql.39 change */ NUMBER) IS
BEGIN
   p_avg_row_len := 93;
END;

PROCEDURE EDW_TIME_M_CNT(p_from_date DATE,
                         p_to_date DATE,
                         p_num_rows OUT NOCOPY /* file.sql.39 change */ NUMBER) IS

CURSOR c_cnt_rows IS
  select sum(cnt) from
  (SELECT max(end_date)-min(per.start_date)+1 cnt
   From  gl_periods per,
         gl_sets_of_books book
   where per.start_date <= p_to_date
   and per.end_date >= p_from_date
   and per.ADJUSTMENT_PERIOD_FLAG = 'N'
   and per.period_set_name = book.period_set_name
   and per.period_type = book.accounted_period_type
   Group By per.period_set_name, per.period_type
   union all
   select count(*)
   from gl_date_period_map map,
        pa_implementations_all pa,
        gl_sets_of_books gl,
        pa_periods_all period
   where pa.set_of_books_id=gl.set_of_books_id
   and period.org_id=pa.org_id
   and map.period_type=pa.pa_period_type
   and map.period_name=period.period_name
   and map.period_set_name=gl.period_set_name
   and map.accounting_date >= p_from_date
   and map.accounting_date <= p_to_date
   and map.period_name <> 'NOT ASSIGNED'
   union all
   select count(*)
   from pa_implementations_all pa,
        gl_sets_of_books gl,
        pa_periods_all period
   where pa.set_of_books_id=gl.set_of_books_id
   and period.org_id=pa.org_id
   and period.end_date >= p_from_date
   and period.start_date <= p_to_date
   and period.period_name <> 'NOT ASSIGNED'
   union all
   select count(*) from
   (select distinct per.period_set_name,
                    per.period_type,
                    per.period_name,
                    per.period_year,
                    per.quarter_num,
                    per.start_date,
                    per.end_date
    from gl_periods per, gl_sets_of_books book
    where per.adjustment_period_flag = 'N'
    and per.period_set_name = book.period_set_name
    and per.period_type = book.accounted_period_type)
   union all
   select to_date('31-12-2000','dd-mm-yyyy')-to_date('01-01-1995','dd-mm-yyyy')+1 cnt
   from dual
   union all
   select months_between(last_day(to_date('31-12-2000','dd-mm-yyyy')),last_day(to_date('01-01-1995','dd-mm-yyyy')))+1 cnt
   from dual);
BEGIN
 OPEN c_cnt_rows;
 FETCH c_cnt_rows INTO p_num_rows;
 CLOSE c_cnt_rows;
EXCEPTION
 When OTHERS
 then p_num_rows := Null;
END;

PROCEDURE EDW_TIME_M_LEN (p_from_date DATE,p_to_date DATE,p_avg_row_len OUT NOCOPY /* file.sql.39 change */ NUMBER) IS
BEGIN
   p_avg_row_len := 1523;
END;

/* Estimate average row length and number of rows for FII_AP_INV_LINES_F */
PROCEDURE FII_AP_INV_LINES_F_CNT (p_from_date DATE,
                  	 p_to_date DATE,
                  	 p_num_rows OUT NOCOPY /* file.sql.39 change */ NUMBER) IS

CURSOR c_cnt_rows IS
  Select count(*)
  from
	ap_invoice_distributions_all aid,
	ap_invoices_all ai
  WHERE aid.last_update_date between p_from_date and p_to_date
   AND NVL(aid.reversal_flag,'N') <> 'Y'
	AND aid.invoice_id = ai.invoice_id
	AND aid.org_id = ai.org_id
	AND ai.invoice_type_lookup_code <> 'EXPENSE REPORT'
	AND ai.cancelled_date IS NULL;

BEGIN
  OPEN c_cnt_rows;
    FETCH c_cnt_rows INTO p_num_rows;
  CLOSE c_cnt_rows;
END;

PROCEDURE FII_AP_INV_LINES_F_LEN (p_from_date DATE,p_to_date DATE,p_avg_row_len OUT NOCOPY /* file.sql.39 change */ NUMBER) IS
BEGIN
  p_avg_row_len := 385;
END;

/* Estimate average row length and number of rows for FII_AP_SCH_PAYMTS_F */
PROCEDURE FII_AP_SCH_PAYMTS_F_CNT (p_from_date DATE,
                  	 p_to_date DATE,
                  	 p_num_rows OUT NOCOPY /* file.sql.39 change */ NUMBER) IS
CURSOR c_cnt_rows IS
  SELECT count(*) cnt
FROM ap_payment_schedules_all aps
WHERE aps.last_update_date BETWEEN p_from_date and p_to_date;

BEGIN
  OPEN c_cnt_rows;
    FETCH c_cnt_rows INTO p_num_rows;
  CLOSE c_cnt_rows;
END;

PROCEDURE FII_AP_SCH_PAYMTS_F_LEN (p_from_date DATE,p_to_date DATE,p_avg_row_len OUT NOCOPY /* file.sql.39 change */ NUMBER) IS
BEGIN
  p_avg_row_len := 352;
END;

/* Estimate average row length and number of rows for FII_AP_INV_PAYMTS_F */
PROCEDURE FII_AP_INV_PAYMTS_F_CNT (p_from_date DATE,
                  	 p_to_date DATE,
                  	 p_num_rows OUT NOCOPY /* file.sql.39 change */ NUMBER) IS
CURSOR c_cnt_rows IS
  SELECT count(*) cnt
  FROM
     ap_invoice_payments_all aip,
     ap_invoices_all ai
   WHERE aip.last_update_date between p_from_date and p_to_date
   AND   aip.invoice_id = ai.invoice_id
	AND   ai.invoice_type_lookup_code <> 'EXPENSE REPORT';

BEGIN
  OPEN c_cnt_rows;
    FETCH c_cnt_rows INTO p_num_rows;
  CLOSE c_cnt_rows;
END;

PROCEDURE FII_AP_INV_PAYMTS_F_LEN (p_from_date DATE,p_to_date DATE,p_avg_row_len OUT NOCOPY /* file.sql.39 change */ NUMBER) IS
BEGIN
  p_avg_row_len := 415;
END;

/* Estimate average row length and number of rows for FII_AP_HOLD_DATA_F */
PROCEDURE FII_AP_HOLD_DATA_F_CNT (p_from_date DATE,
                  	 p_to_date DATE,
                  	 p_num_rows OUT NOCOPY /* file.sql.39 change */ NUMBER) IS
CURSOR c_cnt_rows IS
	SELECT count(*)
   FROM ap_holds_all ah
   WHERE ah.last_update_date BETWEEN p_from_date and p_to_date;

BEGIN
  OPEN c_cnt_rows;
    FETCH c_cnt_rows INTO p_num_rows;
  CLOSE c_cnt_rows;
END;

PROCEDURE FII_AP_HOLD_DATA_F_LEN (p_from_date DATE,p_to_date DATE,p_avg_row_len OUT NOCOPY /* file.sql.39 change */ NUMBER) IS
BEGIN
  p_avg_row_len := 415;
END;

/* Estimate average row length and number of rows for EDW_AP_PAYMENT_M */
PROCEDURE EDW_AP_PAYMENT_M_CNT (p_from_date DATE,
                  	 p_to_date DATE,
                  	 p_num_rows OUT NOCOPY /* file.sql.39 change */ NUMBER) IS
CURSOR c_cnt_rows IS
       select count(*) cnt
from ap_invoice_payments_all aip
WHERE aip.last_update_date between p_from_date and p_to_date;


BEGIN
  OPEN c_cnt_rows;
    FETCH c_cnt_rows INTO p_num_rows;
  CLOSE c_cnt_rows;
END;


PROCEDURE EDW_AP_PAYMENT_M_LEN (p_from_date DATE,p_to_date DATE,p_avg_row_len OUT NOCOPY /* file.sql.39 change */ NUMBER)  IS
BEGIN
  p_avg_row_len := 188;
END;

/* Estimate average row length and number of rows for EDW_INV_TYPE_M */
PROCEDURE EDW_INV_TYPE_M_CNT (p_from_date DATE,
                  	 p_to_date DATE,
                  	 p_num_rows OUT NOCOPY /* file.sql.39 change */ NUMBER) IS
CURSOR c_cnt_rows IS
Select count(*) cnt
from ap_invoices_all ai
where invoice_type_lookup_code <> 'EXPENSE REPORT'
AND   ai.last_update_date between p_from_date and p_to_date;

BEGIN
  OPEN c_cnt_rows;
    FETCH c_cnt_rows INTO p_num_rows;
  CLOSE c_cnt_rows;
END;

PROCEDURE EDW_INV_TYPE_M_LEN (p_from_date DATE,p_to_date DATE,p_avg_row_len OUT NOCOPY /* file.sql.39 change */ NUMBER) IS
BEGIN
  p_avg_row_len := 149;
END;

END;

/
