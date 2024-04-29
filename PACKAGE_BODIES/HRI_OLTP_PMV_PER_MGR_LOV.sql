--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_PMV_PER_MGR_LOV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_PMV_PER_MGR_LOV" AS
/* $Header: hriopmgrlov.pkb 120.8 2006/02/08 02:53 smohapat noship $ */

  PROCEDURE GET_SQL(p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL,
                     x_custom_sql       OUT NOCOPY VARCHAR2,
                     x_custom_output    OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
  IS

/* Parameter values */
  l_parameter_rec        hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  l_bind_tab             hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;
  l_custom_rec           BIS_QUERY_ATTRIBUTES ;
  l_search               VARCHAR2(500);
  l_value                VARCHAR2(250);

   BEGIN

/* Get common parameter values */
  hri_oltp_pmv_util_param.get_parameters_from_table
        (p_page_parameter_tbl  => p_page_parameter_tbl,
         p_parameter_rec       => l_parameter_rec,
         p_bind_tab            => l_bind_tab);

/* Collect Search Value More Window only */
  FOR i IN 1..p_page_parameter_tbl.COUNT
    LOOP
      IF (p_page_parameter_tbl(i).parameter_name = 'HRI_P_CHAR1_GA') THEN
        l_value := p_page_parameter_tbl(i).parameter_value;
      END IF;
    END LOOP;
  /* Append search filter if Value entered */
  IF (l_value is not null) THEN
    l_search:= ' AND upper(value) like upper('''||l_value||''')';
  ELSE
    l_search:= ' ';
  END IF;

     x_custom_sql :=

       '
select ID, VALUE, PARENT_ID
 FROM
(
SELECT suph.sup_person_id id
,substr(per.value,1,20) value
,asg.supervisor_id parent_id
,suph.effective_start_date effective_date
,TO_CHAR(suph.sup_level) || per.order_by order_by
,suph.sub_person_id selected_mgr_person_id
,suph.sub_level selected_mgr_level
,suph.sup_person_id mgr_person_id
,suph.sup_level mgr_level
FROM hri_cs_suph suph
,hri_cl_wkr_sup_status_ct stt
,hri_dbi_cl_per_n_v per
,per_all_assignments_f asg
 WHERE
     stt.person_id = suph.sub_person_id
AND suph.sub_invalid_flag_code = ''N''
AND asg.person_id = suph.sup_person_id
AND per.id = suph.sup_person_id
AND asg.primary_flag = ''Y''
AND asg.assignment_type IN (''E'', ''C'')
AND stt.supervisor_flag = ''Y''
AND &AS_OF_DATE BETWEEN stt.effective_start_date AND stt.effective_end_date
AND &AS_OF_DATE BETWEEN suph.effective_start_date AND suph.effective_end_date
AND &AS_OF_DATE BETWEEN per.effective_start_date AND per.effective_end_date
AND &AS_OF_DATE BETWEEN asg.effective_start_date AND asg.effective_end_date
AND EXISTS (SELECT NULL
             FROM hri_cs_suph sec
             WHERE sec.sub_invalid_flag_code = ''N''
             AND sec.sup_person_id IN (hri_bpl_security.get_apps_signin_person_id,&BIS_SELECTED_TOP_MANAGER)
             AND sec.sub_person_id = suph.sup_person_id
             AND &AS_OF_DATE BETWEEN sec.effective_start_date AND sec.effective_end_date )
UNION ALL
SELECT suph.sub_person_id id
,substr(per.value,1,20) value
,suph.sup_person_id parent_id
,suph.effective_start_date effective_date
,TO_CHAR(suph.sub_level) || per.order_by order_by
,suph.sup_person_id selected_mgr_person_id
,suph.sup_level selected_mgr_level
,suph.sub_person_id mgr_person_id
,suph.sub_level mgr_level
FROM hri_cs_suph suph
,hri_cl_wkr_sup_status_ct stt
,hri_dbi_cl_per_n_v per
WHERE stt.person_id = suph.sub_person_id
AND suph.sub_invalid_flag_code = ''N''
AND per.id = suph.sub_person_id
AND suph.sub_relative_level = 1
AND stt.supervisor_flag = ''Y''
AND &AS_OF_DATE BETWEEN stt.effective_start_date AND stt.effective_end_date
AND &AS_OF_DATE BETWEEN suph.effective_start_date AND suph.effective_end_date
AND &AS_OF_DATE BETWEEN per.effective_start_date AND per.effective_end_date
AND EXISTS (SELECT NULL FROM hri_cs_suph sec
            WHERE sec.sub_invalid_flag_code = ''N''
            AND sec.sup_person_id IN (hri_bpl_security.get_apps_signin_person_id,&BIS_SELECTED_TOP_MANAGER)
            AND sec.sub_person_id = suph.sub_person_id
            AND  &AS_OF_DATE BETWEEN sec.effective_start_date AND sec.effective_end_date )
)
WHERE SELECTED_MGR_PERSON_ID = &HRI_PERSON+HRI_PER_USRDR_H
'
|| l_search ||
'
ORDER BY order_by';

   EXCEPTION
      WHEN OTHERS THEN
          null ;
   END;

PROCEDURE GET_SQL_LEAF(p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL,
                     x_custom_sql       OUT NOCOPY VARCHAR2,
                     x_custom_output    OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
  IS

/* Parameter values */
  l_parameter_rec        hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  l_bind_tab             hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;
  l_custom_rec           BIS_QUERY_ATTRIBUTES ;

  l_search               VARCHAR2(500);
  l_value                VARCHAR2(250);


   BEGIN

/* Initialize out parameters */
    l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
    x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

/* Get common parameter values */
  hri_oltp_pmv_util_param.get_parameters_from_table
        (p_page_parameter_tbl  => p_page_parameter_tbl,
         p_parameter_rec       => l_parameter_rec,
         p_bind_tab            => l_bind_tab);

/* Collect Search Value More Window only */
  FOR i IN 1..p_page_parameter_tbl.COUNT
    LOOP
      IF (p_page_parameter_tbl(i).parameter_name = 'HRI_P_CHAR1_GA') THEN
        l_value := p_page_parameter_tbl(i).parameter_value;
      END IF;
    END LOOP;
  /* Append search filter if Value entered */
  IF (l_value is not null) THEN
    l_search:= ' AND upper(value) like upper('''||l_value||''')';
  ELSE
    l_search:= ' ';
  END IF;

     x_custom_sql :=

       '
select ID, VALUE, PARENT_ID
 FROM
(
SELECT suph.sup_person_id id
,substr(per.value,1,20) value
,asg.supervisor_id parent_id
,suph.effective_start_date effective_date
,TO_CHAR(suph.sup_level) || per.order_by order_by
,suph.sub_person_id selected_mgr_person_id
,suph.sub_level selected_mgr_level
,suph.sup_person_id mgr_person_id
,suph.sup_level mgr_level
FROM hri_cs_suph suph
,hri_dbi_cl_per_n_v per
,per_all_assignments_f asg
 WHERE
     suph.sub_invalid_flag_code = ''N''
 AND asg.person_id = suph.sup_person_id
 AND per.id = suph.sup_person_id
 AND asg.primary_flag = ''Y''
 AND asg.assignment_type in (''E'',''C'')
 AND &AS_OF_DATE BETWEEN suph.effective_start_date AND suph.effective_end_date
 AND &AS_OF_DATE BETWEEN per.effective_start_date AND per.effective_end_date
 AND &AS_OF_DATE BETWEEN asg.effective_start_date AND asg.effective_end_date
 AND EXISTS (SELECT NULL FROM hri_cs_suph sec
             WHERE sec.sub_invalid_flag_code = ''N''
             AND sec.sup_person_id IN (hri_bpl_security.get_apps_signin_person_id,&BIS_SELECTED_TOP_MANAGER)
             AND sec.sub_person_id = suph.sup_person_id
             AND &AS_OF_DATE BETWEEN sec.effective_start_date
             AND sec.effective_end_date )
 AND EXISTS (SELECT NULL FROM hri_cl_wkr_sup_status_ct mstt
             WHERE mstt.person_id = suph.sup_person_id
             AND mstt.supervisor_flag = ''Y''
             AND (mstt.effective_start_date BETWEEN &AS_OF_DATE -365
                                                AND &AS_OF_DATE
                  OR &AS_OF_DATE -365 BETWEEN mstt.effective_start_date
                                                       AND mstt.effective_end_date) )
UNION ALL
SELECT suph.sub_person_id id
,substr(per.value,1,20) value
,suph.sup_person_id parent_id
,suph.effective_start_date effective_date
,TO_CHAR(suph.sub_level) || per.order_by order_by
,suph.sup_person_id selected_mgr_person_id
,suph.sup_level selected_mgr_level
,suph.sub_person_id mgr_person_id
,suph.sub_level mgr_level
FROM hri_cs_suph suph
,hri_cl_wkr_sup_status_ct stt
,hri_dbi_cl_per_n_v per
WHERE stt.person_id = suph.sub_person_id
AND suph.sub_invalid_flag_code = ''N''
AND per.id = suph.sub_person_id
AND suph.sub_relative_level = 1
AND stt.supervisor_flag = ''Y''
AND &AS_OF_DATE BETWEEN stt.effective_start_date AND stt.effective_end_date
AND &AS_OF_DATE BETWEEN suph.effective_start_date AND suph.effective_end_date
AND &AS_OF_DATE BETWEEN per.effective_start_date AND per.effective_end_date
AND EXISTS (SELECT NULL FROM hri_cs_suph sec
            WHERE sec.sub_invalid_flag_code = ''N''
            AND sec.sup_person_id IN (hri_bpl_security.get_apps_signin_person_id,&BIS_SELECTED_TOP_MANAGER)
            AND sec.sub_person_id = suph.sub_person_id
            AND  &AS_OF_DATE BETWEEN sec.effective_start_date AND sec.effective_end_date )
)
WHERE SELECTED_MGR_PERSON_ID = &HRI_PERSON+HRI_PER_USRDR_H
'
|| l_search ||
'
ORDER BY order_by';


   EXCEPTION
      WHEN OTHERS THEN
          null ;
   END;

END;

/
