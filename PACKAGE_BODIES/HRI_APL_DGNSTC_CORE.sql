--------------------------------------------------------
--  DDL for Package Body HRI_APL_DGNSTC_CORE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_APL_DGNSTC_CORE" AS
/* $Header: hriadgcr.pkb 120.2 2005/11/24 05:22:35 jtitmas noship $ */

FUNCTION get_ff_check_sql
     RETURN VARCHAR2 IS

  l_sql_stmt  VARCHAR2(32000);

BEGIN

  l_sql_stmt :=
'SELECT
 bg.name               bg_name
,bg.business_group_id  bg_id
,''FFP'' || ff.formula_id || ''_'' || TO_CHAR(ff.effective_start_date, ''DDMMYYYY'')
                       ff_name
FROM
 ff_formulas_f        ff
,per_business_groups  bg
WHERE ff.formula_name = :p_obj_nm
AND ff.business_group_id = bg.business_group_id
AND TRUNC(SYSDATE) BETWEEN ff.effective_start_date
                   AND ff.effective_end_date
ORDER BY bg.name';

  RETURN l_sql_stmt;

END get_ff_check_sql;

FUNCTION get_ff_check_all_sql
     RETURN VARCHAR2 IS

  l_sql_stmt  VARCHAR2(32000);

BEGIN

  l_sql_stmt :=
'SELECT
 bg.name               bg_name
,bg.business_group_id  bg_id
,''FFP''||ff.formula_id||''_''||TO_CHAR(ff.effective_start_date, ''DDMMYYYY'')
                       ff_name
FROM
 ff_formulas_f         ff
,per_business_groups  bg
WHERE ff.formula_name (+) = :p_obj_nm
AND ff.business_group_id (+) = bg.business_group_id
AND trunc(SYSDATE) BETWEEN ff.effective_start_date (+)
                   AND ff.effective_end_date (+)
AND EXISTS
 (SELECT NULL
  FROM per_all_assignments_f asg
  WHERE asg.assignment_type IN (''E'',''C'')
  AND trunc(SYSDATE) BETWEEN asg.effective_start_date AND asg.effective_end_date
  AND asg.business_group_id = bg.business_group_id)
ORDER BY bg.name';

  RETURN l_sql_stmt;

END get_ff_check_all_sql;

FUNCTION get_alert_sql
     RETURN VARCHAR2 IS

l_sql_stmt  VARCHAR2(32000);

BEGIN

  l_sql_stmt :=
'SELECT /*+ INDEX(mthd hri_adm_mthd_actions_u1) */
 log.note note,
 hr_bis.bis_decode_lookup(''HRI_PROCESS_STATUS'',log.msg_type) status,
 bg.name business_group_name,
 log.effective_date,
 log.person_id
FROM
 hri_adm_msg_log log,
 hri_adm_mthd_actions mthd,
 hr_all_organization_units_tl bg,
 per_all_people_f pn
WHERE log.mthd_action_id = mthd.mthd_action_id
AND log.person_id = pn.person_id
AND log.effective_date BETWEEN pn.effective_start_date
                       AND pn.effective_end_date
AND bg.organization_id = pn.business_group_id
AND bg.language = USERENV(''LANG'')
AND log.mthd_action_id =
 (SELECT max(mthd_action_id)
  FROM hri_adm_msg_log log1
  WHERE log1.msg_group = :p_obj_name
  AND log1.msg_type in (''ERROR'',''WARNING''))
AND log.msg_group = :p_obj_name
AND NOT EXISTS
 (SELECT null
  FROM hri_adm_mthd_actions mthd1
  WHERE mthd1.process_name = mthd.process_name
  AND mthd1.mthd_action_id > mthd.mthd_action_id)';

  RETURN l_sql_stmt;

END get_alert_sql;

END hri_apl_dgnstc_core;

/
