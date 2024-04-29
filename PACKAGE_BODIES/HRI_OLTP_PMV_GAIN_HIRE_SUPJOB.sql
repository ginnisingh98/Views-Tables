--------------------------------------------------------
--  DDL for Package Body HRI_OLTP_PMV_GAIN_HIRE_SUPJOB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_OLTP_PMV_GAIN_HIRE_SUPJOB" AS
/* $Header: hriopgh.pkb 120.2 2005/07/20 02:08:16 cbridge noship $ */
--
PROCEDURE get_sql2(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                   x_custom_sql         OUT NOCOPY VARCHAR2,
                   x_custom_output      OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_sql_text         VARCHAR2(32000);
  l_security_clause  VARCHAR2(4000);
  l_custom_rec       BIS_QUERY_ATTRIBUTES;

/* Parameter values */
  l_parameter_rec         hri_oltp_pmv_util_param.HRI_PMV_PARAM_REC_TYPE;
  l_bind_tab              hri_oltp_pmv_util_param.HRI_PMV_BIND_TAB_TYPE;

BEGIN

/* Initialize out parameters */
    l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
    x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

/* Get common parameter values */
  hri_oltp_pmv_util_param.get_parameters_from_table
        (p_page_parameter_tbl  => p_page_parameter_tbl,
         p_parameter_rec       => l_parameter_rec,
         p_bind_tab            => l_bind_tab);

/* Get security clause for Manager based security */
  l_security_clause := hri_oltp_pmv_util_pkg.get_security_clause('MGR');

/* Formulate query SQL */
  l_sql_text :=
'SELECT -- Hires Salary Variance Top 10
 rnk.diff_rnk                HRI_P_ORDER_BY_1
,hri_bpl_job.get_job_display_name
     (job.id
     ,job.business_group_id
     ,job.value) || '' ('' || bgr.org_information9 || '')''
                             HRI_P_JOB_CN
,rnk.new_hire_hdc            HRI_P_MEASURE1
,rnk.new_hire_avg_sal        HRI_P_MEASURE2
,rnk.curr_emp_avg_sal        HRI_P_MEASURE3
,rnk.diff_pct                HRI_P_MEASURE4
FROM
 hri_dbi_cl_job_n_v job
,hr_organization_information bgr
,(SELECT
   diff.job_id
  ,diff.new_hire_hdc
  ,diff.new_hire_sal
  ,diff.new_hire_avg_sal
  ,diff.curr_emp_hdc
  ,diff.curr_emp_sal
  ,diff.curr_emp_avg_sal
  ,diff.diff_pct
  ,RANK() OVER (ORDER BY ABS(diff.diff_pct) DESC, diff.curr_emp_sal, diff.job_id)  diff_rnk
  FROM

   (SELECT
     averages.job_id                      job_id
    ,averages.new_hire_hdc                new_hire_hdc
    ,averages.new_hire_sal                new_hire_sal
    ,averages.new_hire_avg_sal            new_hire_avg_sal
    ,averages.curr_emp_hdc                curr_emp_hdc
    ,averages.curr_emp_sal                curr_emp_sal
    ,averages.curr_emp_avg_sal            curr_emp_avg_sal
    ,DECODE(averages.curr_emp_avg_sal,
              0, 0,
            (averages.new_hire_avg_sal - averages.curr_emp_avg_sal) * 100 /
             averages.curr_emp_avg_sal)   diff_pct
    FROM
     (SELECT
       hire_sal.job_id                       job_id
      ,hire_sal.new_hire_hdc                 new_hire_hdc
      ,hire_sal.new_hire_sal                 new_hire_sal
      ,DECODE(hire_sal.new_hire_hdc, 0, 0, hire_sal.new_hire_sal / hire_sal.new_hire_hdc)
                                             new_hire_avg_sal
      ,curr_emp.total_headcount - hire_sal.new_hire_hdc
                                             curr_emp_hdc
      ,curr_emp.total_salary - hire_sal.new_hire_sal
                                             curr_emp_sal
      ,DECODE(curr_emp.total_headcount - hire_sal.new_hire_hdc,
                0,TO_NUMBER(NULL),
              (curr_emp.total_salary - hire_sal.new_hire_sal) /
              (curr_emp.total_headcount - hire_sal.new_hire_hdc))
                                             curr_emp_avg_sal
      FROM
       (SELECT /*+ NO_MERGE */
         sub_job.job_id
        ,SUM(sub_job.total_headcount)     total_headcount
        ,SUM(DECODE(sub_job.anl_slry_currency,
                      :GLOBAL_CURRENCY, sub_job.total_anl_slry,
                    hri_bpl_currency.convert_currency_amount
                        (sub_job.anl_slry_currency
                        ,:GLOBAL_CURRENCY
                        ,&BIS_CURRENT_EFFECTIVE_END_DATE
                        ,sub_job.total_anl_slry
                        ,:GLOBAL_RATE)))  total_salary
        FROM
         hri_mdp_sup_wrkfc_job_mv  sub_job
        WHERE sub_job.supervisor_person_id = &HRI_PERSON+HRI_PER_USRDR_H
        AND sub_job.anl_slry_currency <> ''NA_EDW''
        AND &BIS_CURRENT_EFFECTIVE_END_DATE BETWEEN effective_start_date
                                            AND     effective_end_date
        AND job_id <> -1
		GROUP BY
         sub_job.job_id) curr_emp
      ,(SELECT /*+ NO_MERGE */
         hire.job_id                       job_id
        ,SUM(hire.headcount_value)         new_hire_hdc
        ,SUM(DECODE(hire.currency,
                      :GLOBAL_CURRENCY, hire.salary,
                    hri_bpl_currency.convert_currency_amount
                        (hire.currency
                        ,:GLOBAL_CURRENCY
                        ,&BIS_CURRENT_EFFECTIVE_END_DATE
                        ,hire.salary
                        ,:GLOBAL_RATE)))   new_hire_sal
        FROM
         hri_mdp_sup_gain_hire_mv         hire
        WHERE hire.supervisor_id = &HRI_PERSON+HRI_PER_USRDR_H
        AND hire.effective_date BETWEEN &BIS_CURRENT_EFFECTIVE_START_DATE
                                AND     &BIS_CURRENT_EFFECTIVE_END_DATE
        GROUP BY
         hire.job_id)   hire_sal
      WHERE curr_emp.job_id = hire_sal.job_id
      AND hire_sal.new_hire_hdc > 0
     ) averages
   ) diff
 ) rnk
WHERE rnk.job_id = job.id
AND rnk.diff_rnk <= 10
AND bgr.organization_id = job.business_group_id
AND bgr.org_information_context = ''Business Group Information''
' || l_security_clause || '
&ORDER_BY_CLAUSE ';
--
  x_custom_sql := l_SQL_Text;

  l_custom_rec.attribute_name := ':GLOBAL_CURRENCY';
  l_custom_rec.attribute_value := l_parameter_rec.currency_code;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':GLOBAL_RATE';
  l_custom_rec.attribute_value := l_parameter_rec.rate_type;
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(2) := l_custom_rec;
--
END get_sql2;
--
END hri_oltp_pmv_gain_hire_supjob;

/
