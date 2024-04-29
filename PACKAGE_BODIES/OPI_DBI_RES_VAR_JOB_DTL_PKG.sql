--------------------------------------------------------
--  DDL for Package Body OPI_DBI_RES_VAR_JOB_DTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_RES_VAR_JOB_DTL_PKG" AS
/*$Header: OPIDRRSVJDB.pls 120.3 2006/03/27 21:17:18 vganeshk noship $ */

  PROCEDURE get_dtl_sql (p_param in BIS_PMV_PAGE_PARAMETER_TBL,
       x_custom_sql out nocopy VARCHAR2,
       x_custom_output out nocopy BIS_QUERY_ATTRIBUTES_TBL)
  IS

    l_org 		  VARCHAR2(255);
    l_resource_group	  VARCHAR2(255);
    l_resource_dept       VARCHAR2(255);
    l_resource		  VARCHAR2(255);
    l_currency            VARCHAR2(30);
    l_currency_code       VARCHAR2(2);
    l_flag                VARCHAR2(1);
    l_jobstatus		  VARCHAR2(255);
    l_resource_where	  VARCHAR2(2000);
    l_resource_grp_where  VARCHAR2(2000);
    l_resource_dept_where VARCHAR2(2000);
    l_org_where		  VARCHAR2(255);
    l_jobstatus_where 	  VARCHAR2(1500);
    l_job_info_drill      VARCHAR2(255);
    l_respid 		  NUMBER;

  BEGIN

    --Initialization
    l_org 		   := NULL;
    l_resource_group	   := NULL;
    l_resource_dept        := NULL;
    l_resource		   := NULL;
    l_currency             := '';
    l_currency_code        := 'B';
    l_flag                 := NULL;
    l_jobstatus		   := NULL;
    l_resource_where	   := NULL;
    l_resource_grp_where   := NULL;
    l_resource_dept_where  := NULL;
    l_org_where		   := NULL;
    l_jobstatus_where 	   := NULL;
    l_job_info_drill       := NULL;
    l_respid 		   := -1;

    FOR i IN 1..p_param.COUNT
    LOOP
    	IF(p_param(i).parameter_name = 'ORGANIZATION+ORGANIZATION') THEN
    		l_org :=  p_param(i).parameter_id;
    	END IF;

    	IF(p_param(i).parameter_name = 'RESOURCE+ENI_RESOURCE_GROUP') THEN
    	  IF (p_param(i).parameter_id IS NULL or upper(p_param(i).parameter_id) = 'ALL'
    	      or p_param(i).parameter_id = '-1') THEN
    		l_resource_group :=  p_param(i).parameter_id;
          ELSE
                l_resource_group :=  'Selected';
          END IF;
    	END IF;

    	IF(p_param(i).parameter_name = 'RESOURCE+ENI_RESOURCE_DEPARTMENT') THEN
    	  IF (p_param(i).parameter_id IS NULL or upper(p_param(i).parameter_id) = 'ALL'
    	      or p_param(i).parameter_id = '-1') THEN
    		l_resource_dept :=  p_param(i).parameter_id;
          ELSE
                l_resource_dept :=  'Selected';
          END IF;
    	END IF;

    	IF(p_param(i).parameter_name = 'RESOURCE+ENI_RESOURCE') THEN
    	   IF (p_param(i).parameter_id IS NULL or upper(p_param(i).parameter_id) = 'ALL') THEN
    	       l_resource :=  p_param(i).parameter_id;
    	   ELSE
    	       l_resource :=  'Selected';
    	   END IF;
    	END IF;

    	IF(p_param(i).parameter_name = 'OPI_MFG_WO_ATTRIB+OPI_MFG_WO_STATUS_LVL') THEN
    	   IF (p_param(i).parameter_id IS NULL or upper(p_param(i).parameter_id) = 'ALL') THEN
    	       l_jobstatus := p_param(i).parameter_id;
    	   ELSE
    	       l_jobstatus := 'Selected';
    	   END IF;
    	END IF;

    	IF(p_param(i).parameter_name = 'CURRENCY+FII_CURRENCIES') THEN
    	   l_currency := p_param(i).parameter_id;
    	END IF;


     END LOOP;


     IF(l_currency = '''FII_GLOBAL1''') THEN
    	 l_currency_code := 'G';
     ELSE
       IF(l_currency = '''FII_GLOBAL2''') THEN
           l_currency_code := 'SG';
       END IF;
     END IF;

     IF (UPPER(l_resource) <> 'ALL') THEN
     	l_resource_where := ' and resview.id in (&RESOURCE+ENI_RESOURCE)';
     END IF;

     IF (UPPER(l_resource_group) <> 'ALL') THEN
     	IF(UPPER(l_resource_group) <> '-1') THEN
     		l_resource_grp_where := ' and resview.resource_group_fk in (&RESOURCE+ENI_RESOURCE_GROUP) ';
     	ELSE
     		l_resource_grp_where := ' and resview.resource_group_fk in (''-1'')';
     	END IF;
     END IF;

     IF (UPPER(l_resource_dept) <> 'ALL') THEN
        IF(UPPER(l_resource_dept) <> '-1') THEN
     		l_resource_dept_where := ' and resview.department_fk in (&RESOURCE+ENI_RESOURCE_DEPARTMENT) ';
     	ELSE
     		l_resource_dept_where := ' and resview.department_fk in (''-1'')';
     	END IF;
     END IF;

     IF (UPPER(l_jobstatus) <> 'ALL') THEN
     	l_jobstatus_where := ' and
     	decode (job.status,''Closed'',''12'',''Cancelled'',''7'',''Complete - No Charges'',''5'',
     		           ''Complete'',''4'',''Pending Close'',''14'',''Failed Close'',''15'',''Released'',''3'',
     		           ''On Hold'',''6'',''-1'') in (&OPI_MFG_WO_ATTRIB+OPI_MFG_WO_STATUS_LVL) ';
     END IF;

     IF (l_org is NULL) THEN

     select fnd_global.resp_id into l_respid from dual ;
     select id into l_org from (select id from bis_organizations_v where responsibility_id = l_respid order by value asc) where rownum=1;

     ELSE

     select process_enabled_flag
     into l_flag
     from mtl_parameters mp
     where mp.organization_id = trim(both '''' from l_org);

     END IF;

     l_org_where := 'and job.organization_id = '||l_org;

     IF (l_flag = 'Y') THEN

        l_job_info_drill := 'OPI_DBI_JOB_INFO_PROC_REP&addBreadCrumb=Y&cloInd=1';
     	-- Construct the URL for OPM Job info OA page
     ELSE

        l_job_info_drill := 'OPI_DBI_JOB_INFO_DISC_REP&addBreadCrumb=Y&cloInd=1';
        -- Construct the URL for Discrete Job info OA Page
     END IF;


     x_custom_sql :=
     'SELECT
         fact.job_name ||''(''||mtp.organization_code||'')'' OPI_ATTRIBUTE1,
 	 jobstatus.value 					    OPI_ATTRIBUTE2,
 	 fact.opi_date1 				    OPI_DATE1,
 	 ''pFunctionName='||l_job_info_drill ||'&jobId=''||fact.job_id||
 	                                       ''&orgId=''||fact.organization_id ||
 	                                       ''&jobName=''|| mtp.organization_code ||
 	                                       ''&repId=''|| fact.job_name ||
 	                                       ''&jobType=''|| fact.job_type OPI_ATTRIBUTE4,
 	 fact.opi_measure1                                  OPI_MEASURE1,
         fact.opi_measure2                                  OPI_MEASURE2,
 	 fact.opi_measure3                                  OPI_MEASURE3,
 	 fact.opi_measure4                                  OPI_MEASURE4,
 	 fact.opi_measure5                                  OPI_MEASURE5,
 	 fact.opi_measure6				    OPI_MEASURE6,
 	 fact.opi_measure7				    OPI_MEASURE7,
 	 fact.opi_measure8                                  OPI_MEASURE8,
	 fact.opi_measure9                                  OPI_MEASURE9,
	 fact.opi_measure10                                 OPI_MEASURE10,
	 fact.opi_measure11                                 OPI_MEASURE11,
	 fact.opi_measure12				    OPI_MEASURE12,
 	 fact.opi_measure13				    OPI_MEASURE13
 	 FROM
        (SELECT
           (rank() over
           (&ORDER_BY_CLAUSE nulls last,organization_id,job_name)) - 1 rnk,
  	   organization_id,
  	   job_status_code,
  	   job_name,
  	   job_type,
  	   job_id,
           opi_date1,
           opi_measure1,
           opi_measure2,
           opi_measure3,
           opi_measure4,
           opi_measure5,
           opi_measure6,
           opi_measure7,
           opi_measure8,
           opi_measure9,
           opi_measure10,
           opi_measure11,
           (opi_measure8-opi_measure10) opi_measure12,
           (opi_measure8-opi_measure10)/decode(opi_measure10,0,null,opi_measure10)*100 opi_measure13
         FROM
           (select
            	organization_id,
            	job_status_code,
            	job_name,
            	job_type,
            	job_id,
            	opi_date1,
                opi_measure1,
                decode('''|| l_currency_code || ''', ''B'',opi_measure2_b,''G'',opi_measure2_g,''SG'',opi_measure2_sg) opi_measure2,
        	opi_measure3,
        	decode('''|| l_currency_code || ''', ''B'',opi_measure4_b,''G'',opi_measure4_g,''SG'',opi_measure4_sg) opi_measure4,
        	opi_measure5,
        	decode('''|| l_currency_code || ''', ''B'',opi_measure6_b,''G'',opi_measure6_g,''SG'',opi_measure6_sg) opi_measure6,
        	decode('''|| l_currency_code || ''', ''B'',opi_measure7_b,''G'',opi_measure7_g,''SG'',opi_measure7_sg) opi_measure7,
        	decode('''|| l_currency_code || ''', ''B'',opi_measure8_b,''G'',opi_measure8_g,''SG'',opi_measure8_sg) opi_measure8,
        	opi_measure9,
        	decode('''|| l_currency_code || ''', ''B'',opi_measure10_b,''G'',opi_measure10_g,''SG'',opi_measure10_sg) opi_measure10,
        	opi_measure11
            from
  		(select
		   job.organization_id organization_id,
		   job.job_status_code job_status_code,
		   job.job_name job_name,
		   job.job_type job_type,
		   job.job_id job_id,
		   job.completion_date opi_date1,
		   job.actual_qty_completed opi_measure1,
		   sum(act.actual_val_g) opi_measure2_g,
		   sum(act.actual_val_b) opi_measure2_b,
		   sum(act.actual_val_sg) opi_measure2_sg,
		   sum(act.actual_qty) opi_measure3,
		   sum(std.std_usage_val_g) opi_measure4_g,
		   sum(std.std_usage_val_b) opi_measure4_b,
		   sum(std.std_usage_val_sg) opi_measure4_sg,
		   sum(std.std_usage_qty) opi_measure5,
		   sum(act.actual_val_g) - sum(std.std_usage_val_g) opi_measure6_g,
		   sum(act.actual_val_b) - sum(std.std_usage_val_b) opi_measure6_b,
		   sum(act.actual_val_sg) - sum(std.std_usage_val_sg) opi_measure6_sg,
		   (sum(act.actual_val_g) - sum(std.std_usage_val_g))/(decode(sum(std.std_usage_val_g),0,
		   null,sum(std.std_usage_val_g)))*100 opi_measure7_g,
		   (sum(act.actual_val_b) - sum(std.std_usage_val_b))/(decode(sum(std.std_usage_val_b),0,
		   null,sum(std.std_usage_val_b)))*100 opi_measure7_b,
		   (sum(act.actual_val_sg) - sum(std.std_usage_val_sg))/(decode(sum(std.std_usage_val_sg),0,
		   null,sum(std.std_usage_val_sg)))*100 opi_measure7_sg,
		   sum(sum(act.actual_val_sg)) over() opi_measure8_sg,
		   sum(sum(act.actual_val_b)) over() opi_measure8_b,
		   sum(sum(act.actual_val_g)) over() opi_measure8_g,
		   sum(sum(act.actual_qty)) over() opi_measure9,
		   sum(sum(std.std_usage_val_g)) over() opi_measure10_g,
		   sum(sum(std.std_usage_val_b)) over() opi_measure10_b,
		   sum(sum(std.std_usage_val_sg)) over() opi_measure10_sg,
		   sum(sum(std.std_usage_qty)) over() opi_measure11
		 from
		   opi_dbi_res_std_f std,
		   opi_dbi_res_actual_f act,
		   opi_dbi_jobs_f job,
		   eni_resource_v resview
		 where
		   job.completion_date between &BIS_CURRENT_EFFECTIVE_START_DATE and
		   &BIS_CURRENT_ASOF_DATE and
		   job.job_id = act.job_id	and
		   job.source = act.source and
		   job.organization_id = act.organization_id and
		   job.assembly_item_id = act.assembly_item_id and
		   job.job_type = act.job_type and
		   job.job_id = std.job_id	and
		   job.source = std.source and
		   job.organization_id = std.organization_id and
		   job.assembly_item_id = std.assembly_item_id and
		   job.job_type = std.job_type and
		   std.resource_id = act.resource_id and
		   job.organization_id = resview.organization_id and
		   job.status IN (''Cancelled'', ''Complete - No Charges'',
                                  ''Closed'') and
		   resview.resource_id = act.resource_id and
		   job.job_type <> 5'
		   		|| l_resource_where
		    		|| l_resource_grp_where
		    		|| l_resource_dept_where
		    		|| l_jobstatus_where
		    		|| l_org_where
		    		|| '
		group by
		   job.organization_id,
		   job.job_status_code,
		   job.completion_date,
		   job.actual_qty_completed,
		   job.job_name,
		   job.job_type,
		   job.job_id,
		   job.assembly_item_id
     		)))fact,
        	   fii_time_day        time,
        	   mtl_parameters          mtp,
               opi_mfg_wo_status_lvl_v jobstatus
        	 where
                jobstatus.id = fact.job_status_code and
        	     mtp.organization_id = fact.organization_id and
  		     time.report_date = fact.opi_date1 and
		     (rnk between &START_INDEX and &END_INDEX or &END_INDEX = -1)
		      &ORDER_BY_CLAUSE nulls last';
  	x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

   END get_dtl_sql;
   END OPI_DBI_RES_VAR_JOB_DTL_PKG;

/
