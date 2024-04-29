--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_PMV_PER_ORGMGR_LOV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_PMV_PER_ORGMGR_LOV" AS
/* $Header: hriopomlov.pkb 120.2 2005/12/06 02:27:24 rlpatil noship $ */

PROCEDURE GET_SQL(p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL,
                  x_custom_sql       OUT NOCOPY VARCHAR2,
                  x_custom_output    OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS

/* Parameter values */
  l_parameter_rec        hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  l_bind_tab             hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;
  l_custom_rec           BIS_QUERY_ATTRIBUTES ;
  l_search               VARCHAR2(100);
  l_value                VARCHAR2(100);

BEGIN

/* Get common parameter values */
  hri_oltp_pmv_util_param.get_parameters_from_table
        (p_page_parameter_tbl  => p_page_parameter_tbl,
         p_parameter_rec       => l_parameter_rec,
         p_bind_tab            => l_bind_tab);

/* Collect Search Value More Window only */
  FOR i IN 1..p_page_parameter_tbl.COUNT
    LOOP
      IF (p_page_parameter_tbl(i).parameter_name = 'HRI_P_CHAR8_GA') THEN
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
      'SELECT ID,
              VALUE,
	      PARENT_ID
         FROM
      (SELECT distinct mgr.sup_person_id id,
              per.value value,
	      mgr.sup_person_id parent_id,
	      TO_CHAR(mgr.sup_level) || per.order_by order_by,
	      mgr.effective_start_date,
	      mgr.effective_end_date,
	      mgr.sub_person_id selected_mgr_person_id,
	      mgr.sub_level selected_mgr_level,
	      mgr.sup_person_id mgr_person_id,
	      mgr.sup_level mgr_level
         FROM hri_cs_suph_orgmgr_ct mgr ,
	      hri_dbi_cl_per_n_v per
        WHERE per.id = mgr.sup_person_id
	  AND trunc(&AS_OF_DATE) BETWEEN per.effective_start_date AND per.effective_end_date
	  AND EXISTS (SELECT NULL
	                FROM hri_cs_suph sec
	               WHERE sec.sup_person_id = &BIS_SELECTED_TOP_MANAGER
		         AND sec.sub_person_id = mgr.sup_person_id
			 AND mgr.effective_start_date BETWEEN sec.effective_start_date AND sec.effective_end_date )
        UNION ALL
	SELECT distinct mgr.sub_person_id id,
	       per.value value,
	       mgr.sup_person_id parent_id,
	       TO_CHAR(mgr.sub_level) || per.order_by order_by,
	       mgr.effective_start_date,
	       mgr.effective_end_date,
	       mgr.sup_person_id selected_mgr_person_id,
	       mgr.sup_level selected_mgr_level,
	       mgr.sub_person_id mgr_person_id,
	       mgr.sub_level mgr_level
	  FROM hri_cs_suph_orgmgr_ct mgr ,
	       hri_dbi_cl_per_n_v per
	 WHERE per.id = mgr.sub_person_id
	   AND mgr.sub_relative_level = 1
	   AND trunc(&AS_OF_DATE) BETWEEN per.effective_start_date AND per.effective_end_date
	   AND EXISTS (SELECT NULL
	                 FROM hri_cs_suph sec
		        WHERE sec.sup_person_id = &BIS_SELECTED_TOP_MANAGER
			  AND sec.sub_person_id = mgr.sub_person_id
			  AND mgr.effective_start_date BETWEEN sec.effective_start_date AND sec.effective_end_date ))
         WHERE SELECTED_MGR_PERSON_ID = &HRI_PERSON+HRI_PER_USRDR_H
	   AND &AS_OF_DATE BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE
	   '
           || l_search  ;

EXCEPTION
   WHEN OTHERS THEN
          null ;
   END;


END HRI_OLTP_PMV_PER_ORGMGR_LOV;


/
