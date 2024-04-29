--------------------------------------------------------
--  DDL for Package Body PA_BIS_SUMMARY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_BIS_SUMMARY" AS
/* $Header: PABISUMB.pls 120.1 2005/08/19 16:16:09 mwasowic noship $ */

--------------------------------------
-- FUNCTION/PROCEDURE IMPLEMENTATIONS
--

Procedure SUMMARIZE_BIS(errbuf OUT NOCOPY varchar2,ret_code OUT NOCOPY varchar2) IS --File.Sql.39 bug 4440895

x_org_id    NUMBER(15);
v_pa_org_start_date_high  date;
v_pa_org_start_date_low   date;
v_gl_org_start_date_high  date;
v_gl_org_start_date_low   date;
--=================================================== IGOR
-- insert 1:
cursor c_prd_drills1 is
select
ORGANIZATION_ID ORGANIZATION_ID,
PROJECT_ID PROJECT_ID,
PERIOD PERIOD,
ACC_PTYPE ACC_PTYPE,
S_DATE S_DATE,
E_DATE E_DATE,
SUM(NVL(ACT_COST,0)) ACT_COST,
SUM(NVL(ACT_REVENUE,0)) ACT_REVENUE,
SUM(NVL(BUD_COST,0)) BUD_COST,
SUM(NVL(BUD_REVENUE,0)) BUD_REVENUE
from
(
SELECT
         P.CARRYING_OUT_ORGANIZATION_ID ORGANIZATION_ID
        , P.PROJECT_ID                  PROJECT_ID
        , TA.GL_PERIOD                  PERIOD
        , I.ACCUMULATION_PERIOD_TYPE    ACC_PTYPE
        , PER.START_DATE                S_DATE
        , PER.END_DATE                  E_DATE
        , TA.TOT_BURDENED_COST      ACT_COST
        , TA.TOT_REVENUE            ACT_REVENUE
        , 0                         BUD_COST
        , 0                         BUD_REVENUE
 FROM pa_projects p
        , pa_project_types pt
        , pa_txn_accum ta
        , pa_implementations i
        , gl_period_statuses per
WHERE           i.accumulation_period_type = 'GL'
AND     p.project_type = pt.project_type
AND     pt.project_type_class_code = 'CONTRACT'
AND     ta.project_id = p.project_id
AND     ta.gl_period = per.period_name
AND     per.application_id = PA_Period_Process_Pkg.Application_ID
--                           Changed from 101 for PA/GL Period Enhancements
AND     per.set_of_books_id = i.set_of_books_id
AND      per.adjustment_period_flag = 'N'
AND     per.start_date <= v_gl_org_start_date_high
AND     per.start_date > v_gl_org_start_date_low
UNION ALL
SELECT
         P.CARRYING_OUT_ORGANIZATION_ID         ORGANIZATION_ID
        , P.PROJECT_ID                          PROJECT_ID
        , TA.PA_PERIOD                          PERIOD
        , I.ACCUMULATION_PERIOD_TYPE            ACC_PTYPE
        , PER.START_DATE                        S_DATE
        , PER.END_DATE                          E_DATE
        , TA.TOT_BURDENED_COST      ACT_COST
        , TA.TOT_REVENUE            ACT_REVENUE
        , 0                                             BUD_COST
        , 0                                             BUD_REVENUE
 FROM pa_projects p
        , pa_project_types pt
        , pa_txn_accum ta
        , pa_implementations i
        , pa_periods per
WHERE           i.accumulation_period_type = 'PA'
AND     p.project_type = pt.project_type
AND     pt.project_type_class_code = 'CONTRACT'
AND     ta.project_id = p.project_id
AND     ta.pa_period = per.period_name
AND     per.start_date <= v_pa_org_start_date_high
AND     per.start_date > v_pa_org_start_date_low
UNION ALL
SELECT
        P.CARRYING_OUT_ORGANIZATION_ID  ORGANIZATION_ID
        , P.PROJECT_ID                  PROJECT_ID
        , BPA.GL_PERIOD_NAME            PERIOD
        , I.ACCUMULATION_PERIOD_TYPE    ACC_PTYPE
        , PER.START_DATE                S_DATE
        , PER.END_DATE                  E_DATE
        , 0                                             ACT_COST
        , 0                                             ACT_REVENUE
        , BPA.BASE_BURDENED_COST        BUD_COST
        , BPA.BASE_REVENUE              BUD_REVENUE
 FROM pa_projects p
        , pa_project_types pt
        , pa_budget_by_pa_period_v  bpa
        , pa_implementations I
        , gl_period_statuses per
WHERE           i.accumulation_period_type = 'GL'
AND     p.project_type = pt.project_type
AND     pt.project_type_class_code = 'CONTRACT'
AND     p.project_id = bpa.project_id
AND     bpa.budget_type_code in ('AR','AC')
AND     bpa.gl_period_name = per.period_name
AND     per.application_id = PA_Period_Process_Pkg.Application_ID
--                           Changed from 101 for PA/GL Period Enhancements
AND     per.set_of_books_id = i.set_of_books_id
AND     per.adjustment_period_flag = 'N'
AND     per.start_date <= v_gl_org_start_date_high
AND     per.start_date > v_gl_org_start_date_low
UNION ALL
SELECT
        P.CARRYING_OUT_ORGANIZATION_ID ORGANIZATION_ID
        , P.PROJECT_ID                   PROJECT_ID
        , BPA.PA_PERIOD                  PERIOD
        , I.ACCUMULATION_PERIOD_TYPE     ACC_PTYPE
        , BPA.PERIOD_START_DATE          S_DATE
        , BPA.PERIOD_END_DATE            E_DATE
        , 0                                             ACT_COST
        , 0                                             ACT_REVENUE
        , BPA.BASE_BURDENED_COST    BUD_COST
        , BPA.BASE_REVENUE          BUD_REVENUE
FROM pa_projects p
        , pa_project_types pt
              , pa_budget_by_pa_period_v  bpa
        , pa_implementations i
WHERE           i.accumulation_period_type = 'PA'
AND     p.project_type = pt.project_type
AND     pt.project_type_class_code = 'CONTRACT'
AND     p.project_id = bpa.project_id
AND     bpa.budget_type_code in ('AR','AC')
AND     bpa.period_start_date <= v_pa_org_start_date_high
AND     bpa.period_start_date >  v_pa_org_start_date_low
UNION ALL
SELECT
         P.CARRYING_OUT_ORGANIZATION_ID ORGANIZATION_ID
        , P.PROJECT_ID                  PROJECT_ID
        , PER.PERIOD_NAME                  PERIOD
        , I.ACCUMULATION_PERIOD_TYPE    ACC_PTYPE
        , PER.START_DATE                S_DATE
        , PER.END_DATE                  E_DATE
        , 0                         ACT_COST
        , 0                         ACT_REVENUE
        , 0                         BUD_COST
        , 0                         BUD_REVENUE
 FROM pa_projects p
        , pa_project_types pt
        , pa_implementations i
        , gl_period_statuses per
WHERE           i.accumulation_period_type = 'GL'
AND     p.project_type = pt.project_type
AND     pt.project_type_class_code = 'CONTRACT'
AND     per.application_id = PA_Period_Process_Pkg.Application_ID
--                           Changed from 101 for PA/GL Period Enhancements
AND     per.set_of_books_id = i.set_of_books_id
AND      per.adjustment_period_flag = 'N'
AND     per.start_date <= v_gl_org_start_date_high
AND     per.start_date > v_gl_org_start_date_low
UNION ALL
SELECT
         P.CARRYING_OUT_ORGANIZATION_ID         ORGANIZATION_ID
        , P.PROJECT_ID                          PROJECT_ID
        , PER.PERIOD_NAME                          PERIOD
        , I.ACCUMULATION_PERIOD_TYPE            ACC_PTYPE
        , PER.START_DATE                        S_DATE
        , PER.END_DATE                          E_DATE
        , 0      				ACT_COST
        , 0            				ACT_REVENUE
        , 0                                     BUD_COST
        , 0                                     BUD_REVENUE
 FROM pa_projects p
        , pa_project_types pt
        , pa_implementations i
        , pa_periods per
WHERE           i.accumulation_period_type = 'PA'
AND     p.project_type = pt.project_type
AND     pt.project_type_class_code = 'CONTRACT'
AND     per.start_date <= v_pa_org_start_date_high
AND     per.start_date > v_pa_org_start_date_low
)
group by
ORGANIZATION_ID,
PROJECT_ID,
PERIOD,
ACC_PTYPE,
S_DATE,
E_DATE
;
--================================================IGOR
-- loop 1
cursor c_prd_drills2 is
select
CCATEGORY CCATEGORY,
CCODE CCODE,
PROJECT_ID PROJECT_ID,
PERIOD PERIOD,
ACC_PTYPE ACC_PTYPE,
S_DATE S_DATE,
E_DATE E_DATE,
SUM(NVL(ACT_COST,0)) ACT_COST,
SUM(NVL(ACT_REVENUE,0)) ACT_REVENUE,
SUM(NVL(BUD_COST,0)) BUD_COST,
SUM(NVL(BUD_REVENUE,0)) BUD_REVENUE
from
(
SELECT
 PC.CLASS_CATEGORY CCATEGORY,
 PC.CLASS_CODE CCODE,
 P.PROJECT_ID PROJECT_ID,
 PER.PERIOD_NAME PERIOD,
 I.ACCUMULATION_PERIOD_TYPE ACC_PTYPE,
 PER.START_DATE S_DATE,
 PER.END_DATE E_DATE,
 0 ACT_COST,
 0 ACT_REVENUE,
 0 BUD_COST,
 0 BUD_REVENUE
 FROM pa_projects p ,
 pa_project_types pt ,
 pa_implementations i ,
 pa_periods per ,
 pa_class_categories cc ,
 pa_project_classes pc
 WHERE
 i.accumulation_period_type = 'PA' AND
 p.project_type = pt.project_type AND pt.project_type_class_code =
 'CONTRACT' AND p.project_id = pc.project_id AND pc.class_category =
 cc.class_category AND cc.pick_one_code_only_flag = 'Y' AND
 per.start_date <= v_pa_org_start_date_high
 AND per.start_date > v_pa_org_start_date_low
 UNION ALL
 SELECT
 PC.CLASS_CATEGORY CCATEGORY,
 PC.CLASS_CODE CCODE,
 P.PROJECT_ID PROJECT_ID,
 TA.PA_PERIOD PERIOD,
 I.ACCUMULATION_PERIOD_TYPE ACC_PTYPE,
 PER.START_DATE S_DATE,
 PER.END_DATE E_DATE,
 TA.TOT_BURDENED_COST ACT_COST,
 TA.TOT_REVENUE ACT_REVENUE,
 0 BUD_COST,
 0 BUD_REVENUE
 FROM
 pa_projects p
 , pa_project_types pt
 , pa_txn_accum ta
 , pa_implementations i ,
 pa_periods per ,
 pa_class_categories cc ,
 pa_project_classes pc
WHERE
 i.accumulation_period_type = 'PA'
 AND p.project_type = pt.project_type
 AND
 pt.project_type_class_code = 'CONTRACT'
 AND ta.project_id = p.project_id
 AND ta.pa_period = per.period_name
 AND p.project_id = pc.project_id AND
 pc.class_category = cc.class_category
 AND cc.pick_one_code_only_flag = 'Y'
 AND per.start_date <= v_pa_org_start_date_high
 AND per.start_date > v_pa_org_start_date_low
UNION ALL
SELECT
 PC.CLASS_CATEGORY CCATEGORY,
 PC.CLASS_CODE CCODE,
 P.PROJECT_ID  PROJECT_ID,
 BPA.PA_PERIOD PERIOD,
 I.ACCUMULATION_PERIOD_TYPE ACC_PTYPE,
 BPA.PERIOD_START_DATE S_DATE,
 BPA.PERIOD_END_DATE E_DATE,
 0 ACT_COST,
 0 ACT_REVENUE,
 BPA.BASE_BURDENED_COST BUD_COST,
 BPA.BASE_REVENUE BUD_REVENUE
 FROM pa_projects p ,
 pa_project_types pt ,
 pa_budget_by_pa_period_v bpa ,
 pa_implementations i ,
 pa_class_categories cc ,
 pa_project_classes pc
 WHERE i.accumulation_period_type = 'PA'
 AND p.project_type =
 pt.project_type
 AND pt.project_type_class_code = 'CONTRACT'
 AND  p.project_id = bpa.project_id
 AND bpa.budget_type_code in ('AR','AC')
 AND
 p.project_id = pc.project_id
 AND pc.class_category = cc.class_category AND
 cc.pick_one_code_only_flag = 'Y'
 AND bpa.period_start_date <= v_pa_org_start_date_high
 AND bpa.period_start_date > v_pa_org_start_date_low
)
GROUP BY
CCATEGORY,
CCODE,
PROJECT_ID,
PERIOD,
ACC_PTYPE,
S_DATE,
E_DATE;
--=================================================== IGOR
-- loop2:
cursor c_prd_drills3 is
select
CCATEGORY CCATEGORY,
CCODE CCODE,
PROJECT_ID PROJECT_ID,
PERIOD PERIOD,
ACC_PTYPE ACC_PTYPE,
S_DATE S_DATE,
E_DATE E_DATE,
SUM(NVL(ACT_COST,0)) ACT_COST,
SUM(NVL(ACT_REVENUE,0)) ACT_REVENUE,
SUM(NVL(BUD_COST,0)) BUD_COST,
SUM(NVL(BUD_REVENUE,0)) BUD_REVENUE
from
(
SELECT
        PC.CLASS_CATEGORY CCATEGORY
        , PC.CLASS_CODE CCODE
        , P.PROJECT_ID  PROJECT_ID
        , PER.PERIOD_NAME PERIOD
        , I.ACCUMULATION_PERIOD_TYPE ACC_PTYPE
        , PER.START_DATE S_DATE
        , PER.END_DATE E_DATE
        , 0     ACT_COST
        , 0     ACT_REVENUE
        , 0     BUD_COST
        , 0     BUD_REVENUE
FROM pa_projects p
        , pa_project_types pt
        , pa_implementations i
        , gl_period_statuses per
        , pa_class_categories cc
        , pa_project_classes pc
WHERE           i.accumulation_period_type = 'GL'
AND     p.project_type = pt.project_type
AND     pt.project_type_class_code = 'CONTRACT'
AND     per.application_id = PA_Period_Process_Pkg.Application_ID
--                           Changed from 101 for PA/GL Period Enhancements
AND     per.set_of_books_id = i.set_of_books_id
AND     p.project_id = pc.project_id
AND     pc.class_category = cc.class_category
AND     cc.pick_one_code_only_flag = 'Y'
AND     per.adjustment_period_flag = 'N'
AND     per.start_date <= v_gl_org_start_date_high
AND     per.start_date > v_gl_org_start_date_low
UNION ALL
SELECT
        PC.CLASS_CATEGORY CCATEGORY
        , PC.CLASS_CODE   CCODE
        , P.PROJECT_ID    PROJECT_ID
        , TA.GL_PERIOD    PERIOD
        , I.ACCUMULATION_PERIOD_TYPE ACC_PTYPE
        , PER.START_DATE S_DATE
        , PER.END_DATE E_DATE
        , TA.TOT_BURDENED_COST ACT_COST
        , TA.TOT_REVENUE ACT_REVENUE
        , 0 BUD_COST
        , 0 BUD_REVENUE
 FROM pa_projects p
        , pa_project_types pt
        , pa_txn_accum ta
        , pa_implementations i
        , gl_period_statuses per
              , pa_class_categories cc
        , pa_project_classes pc
WHERE           i.accumulation_period_type = 'GL'
AND     p.project_type = pt.project_type
AND     pt.project_type_class_code = 'CONTRACT'
AND     ta.project_id = p.project_id
AND     ta.gl_period = per.period_name
AND     per.application_id = PA_Period_Process_Pkg.Application_ID
--                           Changed from 101 for PA/GL Period Enhancements
AND     per.set_of_books_id = i.set_of_books_id
AND     p.project_id = pc.project_id
AND     pc.class_category = cc.class_category
AND     cc.pick_one_code_only_flag = 'Y'
AND     per.adjustment_period_flag = 'N'
AND     per.start_date <=  v_gl_org_start_date_high
AND     per.start_date > v_gl_org_start_date_low
UNION ALL
SELECT
        PC.CLASS_CATEGORY CCATEGORY
        , PC.CLASS_CODE CCODE
        , P.PROJECT_ID  PROJECT_ID
        , BPA.GL_PERIOD_NAME PERIOD
        , I.ACCUMULATION_PERIOD_TYPE ACC_PTYPE
        , PER.START_DATE S_DATE
        , PER.END_DATE E_DATE
        , 0     ACT_COST
        , 0     ACT_REVENUE
        , BPA.BASE_BURDENED_COST BUD_COST
        , BPA.BASE_REVENUE BUD_REVENUE
 FROM pa_projects p
        , pa_project_types pt
              , pa_budget_by_pa_period_v  bpa
        , pa_implementations I
              , gl_period_statuses per
              , pa_class_categories cc
        , pa_project_classes pc
WHERE           i.accumulation_period_type = 'GL'
AND     p.project_type = pt.project_type
AND     pt.project_type_class_code = 'CONTRACT'
AND     p.project_id = bpa.project_id
AND     bpa.budget_type_code in ('AR','AC')
AND     bpa.gl_period_name = per.period_name
AND     per.application_id = PA_Period_Process_Pkg.Application_ID
--                           Changed from 101 for PA/GL Period Enhancements
AND     per.set_of_books_id = i.set_of_books_id
AND      p.project_id = pc.project_id
AND     pc.class_category = cc.class_category
AND     cc.pick_one_code_only_flag = 'Y'
AND      per.adjustment_period_flag = 'N'
AND     per.start_date <= v_gl_org_start_date_high
AND     per.start_date > v_gl_org_start_date_low
)
GROUP BY
CCATEGORY,
CCODE,
PROJECT_ID,
PERIOD,
ACC_PTYPE,
S_DATE,
E_DATE;

--=================================================== IGOR
-- insert 6:
cursor c_prd_drills4 is
SELECT
PNAME,
ACC_PTYPE,
S_DATE,
E_DATE,
SUM(NVL(ACT_COST,0)) ACT_COST,
SUM(NVL(ACT_REVENUE,0)) ACT_REVENUE,
SUM(NVL(BUD_COST,0)) BUD_COST,
SUM(NVL(BUD_REVENUE,0)) BUD_REVENUE
from
(
SELECT
	PER.PERIOD_NAME PNAME
	, I.ACCUMULATION_PERIOD_TYPE ACC_PTYPE
	, PER.START_DATE S_DATE
	, PER.END_DATE E_DATE
	, 0 ACT_COST
	, 0 ACT_REVENUE
	, 0 BUD_COST
	, 0 BUD_REVENUE
 FROM 	pa_periods per
	, pa_implementations i
WHERE 	i.accumulation_period_type = 'PA'
AND	per.start_date <= v_pa_org_start_date_high
AND   	per.start_date >  v_pa_org_start_date_low
UNION ALL
SELECT
	TA.PA_PERIOD PNAME
	, I.ACCUMULATION_PERIOD_TYPE ACC_PTYPE
	, PER.START_DATE S_DATE
	, PER.END_DATE E_DATE
	, TA.TOT_BURDENED_COST ACT_COST
	, TA.TOT_REVENUE ACT_REVENUE
	, 0 BUD_COST
	, 0 BUD_REVENUE
 FROM pa_projects p
	, pa_project_types pt
	, pa_txn_accum ta
	, pa_implementations i
	, pa_periods per
WHERE		i.accumulation_period_type = 'PA'
AND	p.project_type = pt.project_type
AND	pt.project_type_class_code = 'CONTRACT'
AND	ta.project_id = p.project_id
AND	ta.pa_period = per.period_name
AND	per.start_date <= v_pa_org_start_date_high
AND   	per.start_date >  v_pa_org_start_date_low
UNION ALL
SELECT
	BPA.PA_PERIOD PNAME
	, I.ACCUMULATION_PERIOD_TYPE ACC_PTYPE
	, BPA.PERIOD_START_DATE S_DATE
	, BPA.PERIOD_END_DATE E_DATE
	, 0 ACT_COST
	, 0 ACT_REVENUE
	, BPA.BASE_BURDENED_COST BUD_COST
	, BPA.BASE_REVENUE BUD_REVENUE
 FROM pa_projects p
	, pa_project_types pt
              , pa_budget_by_pa_period_v  bpa
	, pa_implementations i
WHERE		i.accumulation_period_type = 'PA'
AND	p.project_type = pt.project_type
AND	pt.project_type_class_code = 'CONTRACT'
AND	p.project_id = bpa.project_id
AND	bpa.budget_type_code in ('AR','AC')
AND	bpa.period_start_date <= v_pa_org_start_date_high
AND   	bpa.period_start_date >  v_pa_org_start_date_low
UNION ALL
SELECT
	PER.PERIOD_NAME PNAME
	, I.ACCUMULATION_PERIOD_TYPE ACC_PTYPE
	, PER.START_DATE S_DATE
	, PER.END_DATE E_DATE
	, 0 ACT_COST
	, 0 ACT_REVENUE
	, 0 BUD_COST
	, 0 BUD_REVENUE
 FROM  pa_implementations i
	, gl_period_statuses per
WHERE		i.accumulation_period_type = 'GL'
AND 	per.application_id = PA_Period_Process_Pkg.Application_ID
--                           Changed from 101 for PA/GL Period Enhancements
AND	per.set_of_books_id = i.set_of_books_id
AND      per.adjustment_period_flag = 'N'
AND 	per.start_date <= v_gl_org_start_date_high
AND	per.start_date > v_gl_org_start_date_low
UNION ALL
SELECT
	TA.GL_PERIOD PNAME
	, I.ACCUMULATION_PERIOD_TYPE ACC_PTYPE
	, PER.START_DATE S_DATE
	, PER.END_DATE E_DATE
	, TA.TOT_BURDENED_COST ACT_COST
	, TA.TOT_REVENUE ACT_REVENUE
	, 0 BUD_COST
	, 0 BUD_REVENUE
 FROM pa_projects p
	, pa_project_types pt
	, pa_txn_accum ta
	, pa_implementations i
	, gl_period_statuses per
WHERE		i.accumulation_period_type = 'GL'
AND	p.project_type = pt.project_type
AND	pt.project_type_class_code = 'CONTRACT'
AND	ta.project_id = p.project_id
AND	ta.gl_period = per.period_name
AND 	per.application_id = PA_Period_Process_Pkg.Application_ID
--                           Changed from 101 for PA/GL Period Enhancements
AND	per.set_of_books_id = i.set_of_books_id
AND      per.adjustment_period_flag = 'N'
AND 	per.start_date <= v_gl_org_start_date_high
AND	per.start_date > v_gl_org_start_date_low
UNION ALL
SELECT
	BPA.GL_PERIOD_NAME PNAME
	, I.ACCUMULATION_PERIOD_TYPE ACC_PTYPE
	, PER.START_DATE S_DATE
	, PER.END_DATE E_DATE
	, 0 ACT_COST
        , 0 ACT_REVENUE
	, BPA.BASE_BURDENED_COST BUD_COST
	, BPA.BASE_REVENUE BUD_REVENUE
 FROM pa_projects p
	, pa_project_types pt
              , pa_budget_by_pa_period_v  bpa
	, pa_implementations i
              , gl_period_statuses per
WHERE		i.accumulation_period_type = 'GL'
AND	p.project_type = pt.project_type
AND	pt.project_type_class_code = 'CONTRACT'
AND	p.project_id = bpa.project_id
AND	bpa.budget_type_code in ('AR','AC')
AND	bpa.gl_period_name = per.period_name
AND 	per.application_id = PA_Period_Process_Pkg.Application_ID
--                           Changed from 101 for PA/GL Period Enhancements
AND	per.set_of_books_id = i.set_of_books_id
AND      per.adjustment_period_flag = 'N'
AND 	per.start_date <= v_gl_org_start_date_high
AND	per.start_date > v_gl_org_start_date_low
)
GROUP BY
PNAME,
ACC_PTYPE,
S_DATE,
E_DATE;
--=================================================== IGOR

prd_drills_rec1		c_prd_drills1%rowtype;
prd_drills_rec2		c_prd_drills2%rowtype;
prd_drills_rec3		c_prd_drills3%rowtype;
prd_drills_rec4		c_prd_drills4%rowtype;

BEGIN

Select org_id into x_org_id from pa_implementations;

-- high date for pa_org:
select per2.start_date
into v_pa_org_start_date_high
from pa_periods per2
where per2.current_pa_period_flag = 'Y';

-- low date for pa_org:
/* Removed the pa_implementations join from the main query and added as subquery Bug # 2634995*/
select DECODE(gl_pt2.number_per_fiscal_year, 52,
(ADD_MONTHS(per2.start_date, -3)), 26,
(ADD_MONTHS(per2.start_date, -6)),12,
(ADD_MONTHS(per2.start_date, -12)),
(ADD_MONTHS(per2.start_date, -3)))
into v_pa_org_start_date_low
from
pa_periods per2,
--pa_implementations i2,
gl_period_types gl_pt2
where
per2.current_pa_period_flag = 'Y'
--and i2.pa_period_type = gl_pt2.period_type
and gl_pt2.period_type = (select i2.pa_period_type
                          from pa_implementations i2);

-- low date for gl_org:
select ADD_MONTHS(gl_per.start_date, -12)
into v_gl_org_start_date_low
from gl_period_statuses gl_per
, pa_implementations pa_i
, pa_periods pa_per
where gl_per.application_id = PA_Period_Process_Pkg.Application_ID
--                            Changed from 101 for PA/GL Period Enhancements
and gl_per.set_of_books_id = pa_i.set_of_books_id
and pa_per.gl_period_name = gl_per.period_name
and pa_per.current_pa_period_flag = 'Y';

-- high date for gl_org:
select gl_per.start_date
into v_gl_org_start_date_high
from gl_period_statuses gl_per
, pa_implementations pa_i
, pa_periods pa_per
where gl_per.application_id = PA_Period_Process_Pkg.Application_ID
--                            Changed from 101 for PA/GL Period Enhancements
and gl_per.set_of_books_id = pa_i.set_of_books_id
and pa_per.gl_period_name = gl_per.period_name
and pa_per.current_pa_period_flag = 'Y';



DELETE FROM PA_BIS_PRJ_BY_PRD_DRILLS;
DELETE FROM PA_BIS_PRJ_TO_DATE_DRILLS;
DELETE FROM PA_BIS_TO_DATE_DRILLS;
DELETE FROM PA_BIS_TOTALS_BY_PRD;
DELETE FROM PA_BIS_TOTALS_TO_DATE;

COMMIT;

FOR prd_drills_rec1 IN c_prd_drills1 LOOP

INSERT INTO PA_BIS_PRJ_BY_PRD_DRILLS (
drilldown_type
, amount_type_code
, drilldown_key1
, project_id
, period_name
, accumulation_period_type
, start_date
, end_date
, sort_order
, org_id
, actual
, budget)
VALUES
	     ( 'ORGANIZATION'
	      ,'REVENUE'
	      ,prd_drills_rec1.ORGANIZATION_ID
              ,prd_drills_rec1.PROJECT_ID
              ,prd_drills_rec1.PERIOD
              ,prd_drills_rec1.ACC_PTYPE
              ,prd_drills_rec1.S_DATE
              ,prd_drills_rec1.E_DATE
              ,TO_CHAR(NULL)
              ,x_org_id
              ,prd_drills_rec1.ACT_REVENUE
              ,prd_drills_rec1.BUD_REVENUE);

INSERT INTO PA_BIS_PRJ_BY_PRD_DRILLS (
drilldown_type
, amount_type_code
, drilldown_key1
, project_id
, period_name
, accumulation_period_type
, start_date
, end_date
, sort_order
, org_id
, actual
, budget)
VALUES
	     ( 'ORGANIZATION'
	      ,'COST'
	      ,prd_drills_rec1.ORGANIZATION_ID
              ,prd_drills_rec1.PROJECT_ID
              ,prd_drills_rec1.PERIOD
              ,prd_drills_rec1.ACC_PTYPE
              ,prd_drills_rec1.S_DATE
              ,prd_drills_rec1.E_DATE
              ,TO_CHAR(NULL)
              ,x_org_id
              ,prd_drills_rec1.ACT_COST
              ,prd_drills_rec1.BUD_COST);

COMMIT;
END LOOP;

COMMIT;






FOR prd_drills_rec2 IN c_prd_drills2 LOOP
INSERT INTO PA_BIS_PRJ_BY_PRD_DRILLS
(
drilldown_type
, amount_type_code
, drilldown_key1
, drilldown_key2
, project_id
, period_name
, accumulation_period_type
, start_date
, end_date
, sort_order
, org_id
, actual
, budget)
VALUES
	     ( 'CLASS_CATEGORY'
	      ,'COST'
	      ,prd_drills_rec2.CCATEGORY
              ,prd_drills_rec2.CCODE
              ,prd_drills_rec2.PROJECT_ID
              ,prd_drills_rec2.PERIOD
              ,prd_drills_rec2.ACC_PTYPE
              ,prd_drills_rec2.S_DATE
              ,prd_drills_rec2.E_DATE
              ,TO_CHAR(NULL)
              ,x_org_id
              ,prd_drills_rec2.ACT_COST
              ,prd_drills_rec2.BUD_COST);

INSERT INTO PA_BIS_PRJ_BY_PRD_DRILLS
(
drilldown_type
, amount_type_code
, drilldown_key1
, drilldown_key2
, project_id
, period_name
, accumulation_period_type
, start_date
, end_date
, sort_order
, org_id
, actual
, budget)
VALUES
             ( 'CLASS_CATEGORY'
              ,'REVENUE'
              ,prd_drills_rec2.CCATEGORY
              ,prd_drills_rec2.CCODE
              ,prd_drills_rec2.PROJECT_ID
              ,prd_drills_rec2.PERIOD
              ,prd_drills_rec2.ACC_PTYPE
              ,prd_drills_rec2.S_DATE
              ,prd_drills_rec2.E_DATE
              ,TO_CHAR(NULL)
              ,x_org_id
              ,prd_drills_rec2.ACT_REVENUE
              ,prd_drills_rec2.BUD_REVENUE);

COMMIT;

END LOOP;
COMMIT;


FOR prd_drills_rec3 IN c_prd_drills3 LOOP
INSERT INTO PA_BIS_PRJ_BY_PRD_DRILLS
(
drilldown_type
, amount_type_code
, drilldown_key1
, drilldown_key2
, project_id
, period_name
, accumulation_period_type
, start_date
, end_date
, sort_order
, org_id
, actual
, budget)
VALUES
	     ( 'CLASS_CATEGORY'
	      ,'COST'
	      ,prd_drills_rec3.CCATEGORY
              ,prd_drills_rec3.CCODE
              ,prd_drills_rec3.PROJECT_ID
              ,prd_drills_rec3.PERIOD
              ,prd_drills_rec3.ACC_PTYPE
              ,prd_drills_rec3.S_DATE
              ,prd_drills_rec3.E_DATE
              ,TO_CHAR(NULL)
              ,x_org_id
              ,prd_drills_rec3.ACT_COST
              ,prd_drills_rec3.BUD_COST);

INSERT INTO PA_BIS_PRJ_BY_PRD_DRILLS
(
drilldown_type
, amount_type_code
, drilldown_key1
, drilldown_key2
, project_id
, period_name
, accumulation_period_type
, start_date
, end_date
, sort_order
, org_id
, actual
, budget)
VALUES
             ( 'CLASS_CATEGORY'
              ,'REVENUE'
              ,prd_drills_rec3.CCATEGORY
              ,prd_drills_rec3.CCODE
              ,prd_drills_rec3.PROJECT_ID
              ,prd_drills_rec3.PERIOD
              ,prd_drills_rec3.ACC_PTYPE
              ,prd_drills_rec3.S_DATE
              ,prd_drills_rec3.E_DATE
              ,TO_CHAR(NULL)
              ,x_org_id
              ,prd_drills_rec3.ACT_REVENUE
              ,prd_drills_rec3.BUD_REVENUE);


COMMIT;

END LOOP;


INSERT INTO PA_BIS_PRJ_TO_DATE_DRILLS
(
drilldown_type
, amount_type_code
, drilldown_key1
, drilldown_key2
, project_id
, project_number
, project_name
, sort_order
, org_id
, actual_ptd
, budget_ptd
, actual_ytd
, budget_ytd
)
SELECT
    	'CLASS_CATEGORY'
    	, 'REVENUE'
	, PC.CLASS_CATEGORY
	, PC.CLASS_CODE
	, P.PROJECT_ID
	, P.SEGMENT1
	, P.NAME
	, P.NAME ||'01'
        , P.org_id
	, SUM(NVL(PAA.REVENUE_PTD, 0))
	, SUM(NVL(PAB.BASE_REVENUE_PTD, 0))
	, SUM(NVL(PAA.REVENUE_YTD, 0))
	, SUM(NVL(PAB.BASE_REVENUE_YTD, 0))
FROM pa_projects p
	, pa_project_types pt
	, pa_project_accum_headers pah
	, pa_project_accum_actuals paa
	, pa_project_accum_budgets pab
	, pa_class_categories cc
	, pa_project_classes pc
WHERE  p.project_id = pah.project_id
AND	p.project_type = pt.project_type
AND	pt.project_type_class_code = 'CONTRACT'
AND     pah.task_id = 0
AND     pah.resource_list_member_id = 0
AND	pah.project_accum_id = paa.project_accum_id(+)
AND 	pah.project_accum_id = pab.project_accum_id(+)
AND 	pab.budget_type_code(+) = 'AR'
AND      p.project_id = pc.project_id
AND 	pc.class_category = cc.class_category
AND	cc.pick_one_code_only_flag = 'Y'
GROUP BY PC.CLASS_CATEGORY, PC.CLASS_CODE, P.PROJECT_ID, P.SEGMENT1, P.NAME, P.org_id
UNION
SELECT
    	'CLASS_CATEGORY'
    	, 'COST'
	, PC.CLASS_CATEGORY
	, PC.CLASS_CODE
        , P.PROJECT_ID
	, P.SEGMENT1
	, P.NAME
	, P.NAME ||'02'
        , P.org_id
	, SUM(NVL(PAA.BURDENED_COST_PTD, 0))
	, SUM(NVL(PAB.BASE_BURDENED_COST_PTD, 0))
	, SUM(NVL(PAA.BURDENED_COST_YTD, 0))
	, SUM(NVL(PAB.BASE_BURDENED_COST_YTD, 0))
FROM pa_projects p
	, pa_project_types pt
	, pa_project_accum_headers pah
	, pa_project_accum_actuals paa
	, pa_project_accum_budgets pab
	, pa_class_categories cc
	, pa_project_classes pc
WHERE  p.project_id = pah.project_id
AND	p.project_type = pt.project_type
AND	pt.project_type_class_code = 'CONTRACT'
AND     pah.task_id = 0
AND     pah.resource_list_member_id = 0
AND	pah.project_accum_id = paa.project_accum_id(+)
AND 	pah.project_accum_id = pab.project_accum_id(+)
AND 	pab.budget_type_code(+) = 'AC'
AND      p.project_id = pc.project_id
AND 	pc.class_category = cc.class_category
AND	cc.pick_one_code_only_flag = 'Y'
GROUP BY PC.CLASS_CATEGORY, PC.CLASS_CODE, P.PROJECT_ID, P.SEGMENT1, P.NAME, P.org_id
UNION
SELECT
	'CLASS_CATEGORY'
	, 'REVENUE'
	, CC.CLASS_CATEGORY
	, SUBSTRB(pa_bis_messages.get_message('PA','PA_BIS_PAPFPJCL_UNASSIGNED'),1,30)
        , P.PROJECT_ID
	, P.SEGMENT1
	, P.NAME
	, P.NAME ||'01'
        , P.org_id
	, SUM(NVL(PAA.REVENUE_PTD, 0))
	, SUM(NVL(PAB.BASE_REVENUE_PTD, 0))
	, SUM(NVL(PAA.REVENUE_YTD, 0))
	, SUM(NVL(PAB.BASE_REVENUE_YTD, 0))
FROM pa_projects p
	, pa_project_types pt
	, pa_project_accum_headers pah
	, pa_project_accum_actuals paa
	, pa_project_accum_budgets pab
	, pa_class_categories cc
WHERE  p.project_id = pah.project_id
AND	p.project_type = pt.project_type
AND	pt.project_type_class_code = 'CONTRACT'
AND     pah.task_id = 0
AND     pah.resource_list_member_id = 0
AND	pah.project_accum_id = paa.project_accum_id(+)
AND 	pah.project_accum_id = pab.project_accum_id(+)
AND 	pab.budget_type_code(+) = 'AR'
AND	cc.pick_one_code_only_flag = 'Y'
AND	NOT EXISTS (select 'x'
		  from pa_project_classes pc2
		  where pc2.project_id = p.project_id
		  and   pc2.class_category = cc.class_category)
GROUP BY CC.CLASS_CATEGORY, P.PROJECT_ID, P.SEGMENT1, P.NAME, P.org_id
UNION
SELECT
	'CLASS_CATEGORY'
	, 'COST'
	, CC.CLASS_CATEGORY
	, SUBSTRB(pa_bis_messages.get_message('PA','PA_BIS_PAPFPJCL_UNASSIGNED'),1,30)
        , P.PROJECT_ID
	, P.SEGMENT1
	, P.NAME
	, P.NAME ||'02'
        , P.org_id
	, SUM(NVL(PAA.BURDENED_COST_PTD, 0))
	, SUM(NVL(PAB.BASE_BURDENED_COST_PTD, 0))
	, SUM(NVL(PAA.BURDENED_COST_YTD, 0))
	, SUM(NVL(PAB.BASE_BURDENED_COST_YTD, 0))
FROM pa_projects p
	, pa_project_types pt
	, pa_project_accum_headers pah
	, pa_project_accum_actuals paa
	, pa_project_accum_budgets pab
	, pa_class_categories cc
WHERE  p.project_id = pah.project_id
AND	p.project_type = pt.project_type
AND	pt.project_type_class_code = 'CONTRACT'
AND     pah.task_id = 0
AND     pah.resource_list_member_id = 0
AND	pah.project_accum_id = paa.project_accum_id(+)
AND 	pah.project_accum_id = pab.project_accum_id(+)
AND 	pab.budget_type_code(+) = 'AC'
AND	cc.pick_one_code_only_flag = 'Y'
AND	NOT EXISTS (select 'x'
		  from pa_project_classes pc2
		  where pc2.project_id = p.project_id
		  and   pc2.class_category = cc.class_category)
GROUP BY CC.CLASS_CATEGORY, P.PROJECT_ID, P.SEGMENT1, P.NAME, P.org_id
;

COMMIT;



INSERT INTO PA_BIS_PRJ_TO_DATE_DRILLS
(
drilldown_type
, amount_type_code
, drilldown_key1
, project_id
, project_number
, project_name
, sort_order
, org_id
, actual_ptd
, budget_ptd
, actual_ytd
, budget_ytd )
SELECT
    	'ORGANIZATION'
    	, 'REVENUE'
	, P.CARRYING_OUT_ORGANIZATION_ID
	, P.PROJECT_ID
	, P.SEGMENT1
	, P.NAME
	, P.NAME ||'01'
        , P.org_id
	, SUM(NVL(PAA.REVENUE_PTD, 0))
	, SUM(NVL(PAB.BASE_REVENUE_PTD, 0))
	, SUM(NVL(PAA.REVENUE_YTD, 0))
	, SUM(NVL(PAB.BASE_REVENUE_YTD, 0))
FROM pa_projects p
	, pa_project_types pt
	, pa_project_accum_headers pah
	, pa_project_accum_actuals paa
	, pa_project_accum_budgets pab
WHERE  p.project_id = pah.project_id
AND	p.project_type = pt.project_type
AND	pt.project_type_class_code = 'CONTRACT'
AND     pah.task_id = 0
AND     pah.resource_list_member_id = 0
AND	pah.project_accum_id = paa.project_accum_id(+)
AND 	pah.project_accum_id = pab.project_accum_id(+)
AND 	pab.budget_type_code(+) = 'AR'
GROUP BY P.CARRYING_OUT_ORGANIZATION_ID,P.PROJECT_ID, P.SEGMENT1, P.NAME, P.org_id
UNION
SELECT
    	'ORGANIZATION'
    	, 'COST'
	, P.CARRYING_OUT_ORGANIZATION_ID
              , P.PROJECT_ID
	, P.SEGMENT1
	, P.NAME
	, P.NAME ||'02'
        , P.org_id
	, SUM(NVL(PAA.BURDENED_COST_PTD, 0))
	, SUM(NVL(PAB.BASE_BURDENED_COST_PTD, 0))
	, SUM(NVL(PAA.BURDENED_COST_YTD, 0))
	, SUM(NVL(PAB.BASE_BURDENED_COST_YTD, 0))
FROM pa_projects p
	, pa_project_types pt
	, pa_project_accum_headers pah
	, pa_project_accum_actuals paa
	, pa_project_accum_budgets pab
WHERE  p.project_id = pah.project_id
AND	p.project_type = pt.project_type
AND	pt.project_type_class_code = 'CONTRACT'
AND     pah.task_id = 0
AND     pah.resource_list_member_id = 0
AND	pah.project_accum_id = paa.project_accum_id(+)
AND 	pah.project_accum_id = pab.project_accum_id(+)
AND 	pab.budget_type_code(+) = 'AC'
GROUP BY P.CARRYING_OUT_ORGANIZATION_ID, P.PROJECT_ID, P.SEGMENT1, P.NAME, P.org_id
;

COMMIT;



INSERT INTO PA_BIS_TO_DATE_DRILLS
(
drilldown_type
, amount_type_code
, drilldown_key1
, sort_order
, org_id
, actual_ptd
, budget_ptd
, actual_ytd
, budget_ytd
)
SELECT
    	'ORGANIZATION'
    	, 'REVENUE'
	, P.CARRYING_OUT_ORGANIZATION_ID
	, OP.NAME
        , P.org_id
	, SUM(NVL(PAA.REVENUE_PTD, 0))
	, SUM(NVL(PAB.BASE_REVENUE_PTD, 0))
	, SUM(NVL(PAA.REVENUE_YTD, 0))
	, SUM(NVL(PAB.BASE_REVENUE_YTD, 0))
FROM pa_projects p
	, pa_project_types pt
	, pa_project_accum_headers pah
	, pa_project_accum_actuals paa
	, pa_project_accum_budgets pab
	, pa_organizations_proj_all_bg_v op
WHERE  p.project_id = pah.project_id
AND	p.project_type = pt.project_type
AND	pt.project_type_class_code = 'CONTRACT'
AND     pah.task_id = 0
AND     pah.resource_list_member_id = 0
AND	pah.project_accum_id = paa.project_accum_id(+)
AND 	pah.project_accum_id = pab.project_accum_id(+)
AND 	pab.budget_type_code(+) = 'AR'
AND     p.carrying_out_organization_id = op.organization_id
GROUP BY P.CARRYING_OUT_ORGANIZATION_ID, OP.NAME, P.org_id
UNION
SELECT
    	'ORGANIZATION'
    	, 'COST'
	, P.CARRYING_OUT_ORGANIZATION_ID
	, OP.NAME
        , P.org_id
	, SUM(NVL(PAA.BURDENED_COST_PTD, 0))
	, SUM(NVL(PAB.BASE_BURDENED_COST_PTD, 0))
	, SUM(NVL(PAA.BURDENED_COST_YTD, 0))
	, SUM(NVL(PAB.BASE_BURDENED_COST_YTD, 0))
FROM pa_projects p
	, pa_project_types pt
	, pa_project_accum_headers pah
	, pa_project_accum_actuals paa
	, pa_project_accum_budgets pab
	, pa_organizations_proj_all_bg_v op
WHERE  p.project_id = pah.project_id
AND	p.project_type = pt.project_type
AND	pt.project_type_class_code = 'CONTRACT'
AND     pah.task_id = 0
AND     pah.resource_list_member_id = 0
AND	pah.project_accum_id = paa.project_accum_id(+)
AND 	pah.project_accum_id = pab.project_accum_id(+)
AND 	pab.budget_type_code(+) = 'AC'
AND     p.carrying_out_organization_id = op.organization_id
GROUP BY P.CARRYING_OUT_ORGANIZATION_ID, OP.NAME, P.org_id
;

COMMIT;



INSERT INTO PA_BIS_TO_DATE_DRILLS
(
drilldown_type
, amount_type_code
, drilldown_key1
, drilldown_key2
, sort_order
, org_id
, actual_ptd
, budget_ptd
, actual_ytd
, budget_ytd
)
SELECT
    	'CLASS_CATEGORY'
    	, 'REVENUE'
	, PC.CLASS_CATEGORY
	, PC.CLASS_CODE
	, PC.CLASS_CODE
        , P.org_id
	, SUM(NVL(PAA.REVENUE_PTD, 0))
	, SUM(NVL(PAB.BASE_REVENUE_PTD, 0))
	, SUM(NVL(PAA.REVENUE_YTD, 0))
	, SUM(NVL(PAB.BASE_REVENUE_YTD, 0))
FROM pa_projects p
	, pa_project_types pt
	, pa_project_accum_headers pah
	, pa_project_accum_actuals paa
	, pa_project_accum_budgets pab
	, pa_class_categories cc
	, pa_project_classes pc
WHERE  p.project_id = pah.project_id
AND	p.project_type = pt.project_type
AND	pt.project_type_class_code = 'CONTRACT'
AND     pah.task_id = 0
AND     pah.resource_list_member_id = 0
AND	pah.project_accum_id = paa.project_accum_id(+)
AND 	pah.project_accum_id = pab.project_accum_id(+)
AND 	pab.budget_type_code(+) = 'AR'
AND      p.project_id = pc.project_id
AND 	pc.class_category = cc.class_category
AND	cc.pick_one_code_only_flag = 'Y'
GROUP BY PC.CLASS_CATEGORY, PC.CLASS_CODE, P.org_id
UNION
SELECT
    	'CLASS_CATEGORY'
    	, 'COST'
	, PC.CLASS_CATEGORY
	, PC.CLASS_CODE
	, PC.CLASS_CODE
        , P.org_id
	, SUM(NVL(PAA.BURDENED_COST_PTD, 0))
	, SUM(NVL(PAB.BASE_BURDENED_COST_PTD, 0))
	, SUM(NVL(PAA.BURDENED_COST_YTD, 0))
	, SUM(NVL(PAB.BASE_BURDENED_COST_YTD, 0))
FROM pa_projects p
	, pa_project_types pt
	, pa_project_accum_headers pah
	, pa_project_accum_actuals paa
	, pa_project_accum_budgets pab
	, pa_class_categories cc
	, pa_project_classes pc
WHERE  p.project_id = pah.project_id
AND	p.project_type = pt.project_type
AND	pt.project_type_class_code = 'CONTRACT'
AND     pah.task_id = 0
AND     pah.resource_list_member_id = 0
AND	pah.project_accum_id = paa.project_accum_id(+)
AND 	pah.project_accum_id = pab.project_accum_id(+)
AND 	pab.budget_type_code(+) = 'AC'
AND      p.project_id = pc.project_id
AND 	pc.class_category = cc.class_category
AND	cc.pick_one_code_only_flag = 'Y'
GROUP BY PC.CLASS_CATEGORY, PC.CLASS_CODE, P.org_id
UNION
SELECT
	'CLASS_CATEGORY'
	, 'REVENUE'
	, CC.CLASS_CATEGORY
	, SUBSTRB(pa_bis_messages.get_message('PA','PA_BIS_PAPFPJCL_UNASSIGNED'),1,30)
	, 'ZZZZZZZZZZ'
        , P.org_id
	, SUM(NVL(PAA.REVENUE_PTD, 0))
	, SUM(NVL(PAB.BASE_REVENUE_PTD, 0))
	, SUM(NVL(PAA.REVENUE_YTD, 0))
	, SUM(NVL(PAB.BASE_REVENUE_YTD, 0))
FROM pa_projects p
	, pa_project_types pt
	, pa_project_accum_headers pah
	, pa_project_accum_actuals paa
	, pa_project_accum_budgets pab
	, pa_class_categories cc
WHERE  p.project_id = pah.project_id
AND	p.project_type = pt.project_type
AND	pt.project_type_class_code = 'CONTRACT'
AND     pah.task_id = 0
AND     pah.resource_list_member_id = 0
AND	pah.project_accum_id = paa.project_accum_id(+)
AND 	pah.project_accum_id = pab.project_accum_id(+)
AND 	pab.budget_type_code(+) = 'AR'
AND	cc.pick_one_code_only_flag = 'Y'
AND	NOT EXISTS (select 'x'
		  from pa_project_classes pc2
		  where pc2.project_id = p.project_id
		  and   pc2.class_category = cc.class_category)
GROUP BY CC.CLASS_CATEGORY, P.org_id
UNION
SELECT
	'CLASS_CATEGORY'
	, 'COST'
	, CC.CLASS_CATEGORY
	, SUBSTRB(pa_bis_messages.get_message('PA','PA_BIS_PAPFPJCL_UNASSIGNED'),1,30)
	, 'ZZZZZZZZZZ'
        , P.org_id
	, SUM(NVL(PAA.BURDENED_COST_PTD, 0))
	, SUM(NVL(PAB.BASE_BURDENED_COST_PTD, 0))
	, SUM(NVL(PAA.BURDENED_COST_YTD, 0))
	, SUM(NVL(PAB.BASE_BURDENED_COST_YTD, 0))
FROM pa_projects p
	, pa_project_types pt
	, pa_project_accum_headers pah
	, pa_project_accum_actuals paa
	, pa_project_accum_budgets pab
	, pa_class_categories cc
WHERE  p.project_id = pah.project_id
AND	p.project_type = pt.project_type
AND	pt.project_type_class_code = 'CONTRACT'
AND     pah.task_id = 0
AND     pah.resource_list_member_id = 0
AND	pah.project_accum_id = paa.project_accum_id(+)
AND 	pah.project_accum_id = pab.project_accum_id(+)
AND 	pab.budget_type_code(+) = 'AC'
AND	cc.pick_one_code_only_flag = 'Y'
AND	NOT EXISTS (select 'x'
		  from pa_project_classes pc2
		  where pc2.project_id = p.project_id
		  and   pc2.class_category = cc.class_category)
GROUP BY CC.CLASS_CATEGORY, P.org_id
;

COMMIT;

FOR prd_drills_rec4 IN c_prd_drills4 LOOP

INSERT INTO PA_BIS_TOTALS_BY_PRD
(
amount_type_code
, period_name
, accumulation_period_type
, start_date
, end_date
, sort_order
, org_id
, actual
, budget
)
VALUES
	      ('REVENUE'
              , prd_drills_rec4.pname
              , prd_drills_rec4.acc_ptype
              , prd_drills_rec4.s_date
              , prd_drills_rec4.e_date
              , TO_CHAR(NULL)
              , x_org_id
              ,prd_drills_rec4.ACT_REVENUE
              ,prd_drills_rec4.BUD_REVENUE);

INSERT INTO PA_BIS_TOTALS_BY_PRD
(
amount_type_code
, period_name
, accumulation_period_type
, start_date
, end_date
, sort_order
, org_id
, actual
, budget
)
VALUES
              ('COST'
              , prd_drills_rec4.pname
              , prd_drills_rec4.acc_ptype
              , prd_drills_rec4.s_date
              , prd_drills_rec4.e_date
              , TO_CHAR(NULL)
              , x_org_id
              ,prd_drills_rec4.ACT_COST
              ,prd_drills_rec4.BUD_COST);


COMMIT;

END LOOP;

INSERT INTO PA_BIS_TOTALS_TO_DATE
(
amount_type_code
, sort_order
, drilldown_indicator
, org_id
, actual_ptd
, budget_ptd
, actual_ytd
, budget_ytd
)
SELECT
        'REVENUE'
	, '01'
	, 'Y'
        , P.org_id
	, SUM(NVL(PAA.REVENUE_PTD, 0))
	, SUM(NVL(PAB.BASE_REVENUE_PTD, 0))
	, SUM(NVL(PAA.REVENUE_YTD, 0))
	, SUM(NVL(PAB.BASE_REVENUE_YTD, 0))
 FROM pa_projects p
	, pa_project_types pt
	, pa_project_accum_headers pah
	, pa_project_accum_actuals paa
	, pa_project_accum_budgets pab
WHERE  p.project_id = pah.project_id
AND	p.project_type = pt.project_type
AND	pt.project_type_class_code = 'CONTRACT'
AND     pah.task_id = 0
AND     pah.resource_list_member_id = 0
AND	pah.project_accum_id = paa.project_accum_id(+)
AND 	pah.project_accum_id = pab.project_accum_id(+)
AND 	pab.budget_type_code(+) = 'AR'
group by P.org_id
UNION
SELECT
        'COST'
	, '02'
	, 'Y'
        , P.org_id
	, SUM(NVL(PAA.BURDENED_COST_PTD, 0))
	, SUM(NVL(PAB.BASE_BURDENED_COST_PTD, 0))
	, SUM(NVL(PAA.BURDENED_COST_YTD, 0))
	, SUM(NVL(PAB.BASE_BURDENED_COST_YTD, 0))
 FROM pa_projects p
	, pa_project_types pt
	, pa_project_accum_headers pah
	, pa_project_accum_actuals paa
	, pa_project_accum_budgets pab
WHERE  p.project_id = pah.project_id
AND	p.project_type = pt.project_type
AND	pt.project_type_class_code = 'CONTRACT'
AND     pah.task_id = 0
AND     pah.resource_list_member_id = 0
AND	pah.project_accum_id = paa.project_accum_id(+)
AND 	pah.project_accum_id = pab.project_accum_id(+)
AND 	pab.budget_type_code(+) = 'AC'
group by P.org_id;

commit;


exception
when others then
     ret_code := SQLCODE;
     errbuf   := SQLERRM;
END SUMMARIZE_BIS;

END PA_BIS_SUMMARY;

/
