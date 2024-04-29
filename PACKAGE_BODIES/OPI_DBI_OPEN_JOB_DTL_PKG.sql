--------------------------------------------------------
--  DDL for Package Body OPI_DBI_OPEN_JOB_DTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_OPEN_JOB_DTL_PKG" AS
/*$Header: OPIDROPNJB.pls 120.3 2005/09/23 02:03 vganeshk noship $*/
PROCEDURE get_dtl_sql (p_param in BIS_PMV_PAGE_PARAMETER_TBL,
       x_custom_sql out nocopy VARCHAR2,
       x_custom_output out nocopy BIS_QUERY_ATTRIBUTES_TBL)

IS

       l_period_type            VARCHAR2(255);
       l_org 		        bis_organizations_v.id%type;
       l_item_org               VARCHAR2(255);
       l_item_cat		VARCHAR2(255);
       l_currency               VARCHAR2(30);
       l_jobstatus              VARCHAR2(255);
       l_item_org_where         VARCHAR2(2000);
       l_item_cat_where         VARCHAR2(2000);
       l_jobstatus_where        VARCHAR2(2000);
       l_lang_code              VARCHAR2(20);
       l_currency_code          VARCHAR2(2);
       l_respid              	NUMBER;
       l_job_info_drill      	VARCHAR2(255);
       l_flag                	mtl_parameters.process_enabled_flag%type;
       l_org_where		VARCHAR2(2000);


BEGIN

       --Initialization
       l_period_type            := NULL;
       l_org 		        := NULL;
       l_item_org               := NULL;
       l_item_cat		:= NULL;
       l_currency               := '';
       l_jobstatus              := NULL;
       l_item_org_where         := ' ';
       l_item_cat_where         := ' ';
       l_jobstatus_where        := ' ';
       l_lang_code              := NULL;
       l_currency_code          := 'B';
       l_respid              	:=-1;
       l_job_info_drill      	:= NULL;
       l_flag                	:= NULL;
       l_org_where		:= NULL;

 FOR i IN 1..p_param.COUNT
  LOOP
    IF(p_param(i).parameter_name = 'ORGANIZATION+ORGANIZATION')
    --{
      THEN l_org :=  p_param(i).parameter_id;
    --}
    END IF;

    IF(p_param(i).parameter_name = 'ITEM+ENI_ITEM_ORG') THEN
    --{
	IF (p_param(i).parameter_id IS NULL or upper(p_param(i).parameter_id) = 'ALL') THEN
       	   l_item_org :=  p_param(i).parameter_id;
	else
	   l_item_org := 'Selected';
 	END IF;
    --}
    END IF;

    IF(p_param(i).parameter_name = 'ITEM+ENI_ITEM_INV_CAT') THEN
    --{
       IF (p_param(i).parameter_id IS NULL or upper(p_param(i).parameter_id) = 'ALL') THEN
           l_item_cat := p_param(i).parameter_id;
       ELSE
           l_item_cat := 'Selected';
       END IF;
    --}
    END IF;

    IF(p_param(i).parameter_name = 'CURRENCY+FII_CURRENCIES') then
    --{
       l_currency := p_param(i).parameter_id;
    --}
    END IF;

    IF(p_param(i).parameter_name = 'OPI_MFG_WO_ATTRIB+OPI_MFG_WO_STATUS_LVL')
    --{
      THEN  l_jobstatus := p_param(i).parameter_id;
    --}
    END IF;

  END LOOP;

    IF(l_currency = '''FII_GLOBAL1''') then
    --{
        l_currency_code := 'G';
    --}
    ELSE
    --{
      IF
        (l_currency = '''FII_GLOBAL2''') then
         l_currency_code := 'SG';
      END IF;
    --}
    END IF;


    IF (UPPER(l_item_org) <> 'ALL') THEN
    --{
      l_item_org_where :='
       AND fact.inventory_item_id||''-''|| fact.organization_id in' ||'(&ITEM+ENI_ITEM_ORG)';
       --||'AND fact.organization_id = '||l_org;
    --}
    END IF;

    IF(UPPER(l_item_cat) <> 'ALL') THEN
    --{
      l_item_cat_where := ' and itemorg.inv_category_id in (&ITEM+ENI_ITEM_INV_CAT)';
    --}
    END IF;

    IF (UPPER(l_jobstatus) <> 'ALL') THEN
    --{
     l_jobstatus_where := ' and
     decode (jobs.status,''Closed'',12,''Cancelled'',7,''Complete - No Charges'',5,
                ''Complete'',4,''Pending Close'',14,''Failed Close'',15,''Released'',3,
                ''On Hold'',6,-1) in ( ' || l_jobstatus || ') ';
    --}
    END IF;

    IF (l_org is NULL) THEN
    --{

         select fnd_global.resp_id into l_respid from dual ;
         select id into l_org from (select id from bis_organizations_v where responsibility_id = l_respid order by value asc) where rownum=1;
    --}
    ELSE
    --{
         select process_enabled_flag
         into l_flag
         from mtl_parameters mp
         where mp.organization_id = trim(both '''' from l_org);
    --}
    END IF;

    l_org_where := ' and fact.organization_id = '||l_org;

    IF (l_flag = 'Y') THEN
    --{
         l_job_info_drill := 'OPI_DBI_JOB_INFO_PROC_REP&cloInd=1';
    --}
    ELSE
    --{
         l_job_info_drill := 'OPI_DBI_JOB_INFO_DISC_REP&cloInd=1';
    --}
    END IF;


    x_custom_sql :=
    'SELECT
         f.job_name ||''('' || mtp.organization_code || '')''  OPI_ATTRIBUTE1
        ,job_status.value                                      OPI_ATTRIBUTE2
        ,itemorg.value                                      OPI_ATTRIBUTE3
        ,itemorg.description                                OPI_ATTRIBUTE4
        ,v2.unit_of_measure                                 OPI_ATTRIBUTE5
        ,''pFunctionName='||l_job_info_drill ||'&jobId=''||f.job_id||
                                             ''&orgId=''||f.org_id ||
                             ''&jobName=''|| mtp.organization_code ||
                                          ''&repId=''|| f.job_name ||
                                                      ''&jobType=''|| f.job_type
                                                                  OPI_ATTRIBUTE6
        ,f.opi_measure1                                     OPI_MEASURE1
        ,f.opi_measure2                                     OPI_MEASURE2
        ,f.opi_measure3                                     OPI_MEASURE3
        ,f.opi_measure4                                     OPI_MEASURE4
        ,f.opi_measure5                                     OPI_MEASURE5
        ,f.opi_measure6                                     OPI_MEASURE6
        ,f.opi_measure7                                     OPI_MEASURE7
        ,f.opi_measure8                                     OPI_MEASURE8
        ,f.opi_measure9                                     OPI_MEASURE9
        ,f.opi_measure10                                    OPI_MEASURE10
from
  (select
  	(rank() over (&ORDER_BY_CLAUSE nulls last,job_id,job_name,org_id,assembly_item_id)) - 1 rnk
        ,job_id
        ,job_type
        ,job_name
        ,org_id
        ,assembly_item_id
        ,job_status_code
        ,opi_attribute1
  	,opi_attribute2
  	,opi_measure1
  	,opi_measure2
  	,opi_measure3
  	,opi_measure4
  	,opi_measure5
  	,opi_measure6
  	,opi_measure7
  	,opi_measure8
  	,opi_measure9
  	,opi_measure10
   from
         (select
             org_id
            ,assembly_item_id
            ,job_id
            ,job_type
            ,job_name
	    ,job_name opi_attribute1
	    ,status opi_attribute2
	    ,job_status_code
            ,start_qty opi_measure1
            ,actual_qty opi_measure2
	    ,standard_value opi_measure3
            ,actual_value opi_measure4
            ,(actual_value - standard_value) opi_measure5
            ,(actual_value - standard_value)*100/(decode(standard_value,0,null,standard_value)) opi_measure6
            ,standard_value_tot opi_measure7
	    ,actual_value_tot opi_measure8
	    ,(actual_value_tot - standard_value_tot) opi_measure9
	    ,(actual_value_tot - standard_value_tot)*100/(decode(standard_value_tot,0,null,standard_value_tot)) opi_measure10
	  from
               (select
                 jobs.job_name job_name,
                 jobs.job_id job_id,
                 jobs.job_type,
                 jobs.organization_id org_id,
                 jobs.assembly_item_id assembly_item_id,
                 jobs.job_status_code job_status_code,
                 jobs.status status,
                 jobs.start_quantity start_qty,
                 fact.actual_prd_qty actual_qty,
                 decode(''' || l_currency_code || ''', ''B'',fact.standard_value_b,
                 				       ''G'',fact.standard_value_g,
                 				       ''SG'',fact.standard_value_sg) standard_value,
                 decode(''' || l_currency_code || ''', ''B'',fact.actual_value_b,
		                  		       ''G'',fact.actual_value_g,
                 				       ''SG'',fact.actual_value_sg) actual_value,
                 sum(decode(''' || l_currency_code || ''', ''B'',fact.standard_value_b,
                 	 			           ''G'',fact.standard_value_g,
                 				           ''SG'',fact.standard_value_sg)) over()
                 				           standard_value_tot,
		 sum(decode(''' || l_currency_code || ''', ''B'',fact.actual_value_b,
		                    		           ''G'',fact.actual_value_g,
                 				           ''SG'',fact.actual_value_sg)) over()
                 				           actual_value_tot
             from
                  OPI_DBI_CURR_UNREC_VAR_F   fact,
                  OPI_DBI_JOBS_F          jobs
             where
                   	  fact.job_id = jobs.job_id
                   and    fact.job_type = jobs.job_type
                   and    fact.inventory_item_id = jobs.assembly_item_id
                   and    fact.organization_id = jobs.organization_id '
                   || l_item_org_where
		   || l_jobstatus_where
                   || l_org_where
                   || '
             group by
                     jobs.job_name,
		     jobs.job_id,
		     jobs.job_type,
		     jobs.organization_id,
		     jobs.assembly_item_id,
		     jobs.job_status_code,
		     jobs.status,
		     jobs.start_quantity,
                     fact.actual_prd_qty,
                     fact.standard_value_b,
		     fact.standard_value_g,
		     fact.standard_value_sg,
		     fact.actual_value_b,
		     fact.actual_value_g,
		     fact.actual_value_sg
		     )))f
		  ,eni_item_org_v          itemorg
                  ,mtl_units_of_measure_vl v2
                  ,mtl_parameters          mtp
                  ,OPI_MFG_WO_STATUS_LVL_V job_status
		  where
		         mtp.organization_id = f.org_id
		  and    itemorg.id = f.assembly_item_id||''-''|| f.org_id
		  and    itemorg.organization_id = f.org_id
		  and    itemorg.primary_uom_code = V2.uom_code
		  and    f.job_status_code = job_status.id
                  and (rnk between &START_INDEX and &END_INDEX or &END_INDEX = -1) ' ||
		  l_item_cat_where || '
		  &ORDER_BY_CLAUSE nulls last';



 x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

 END get_dtl_sql;
 END OPI_DBI_OPEN_JOB_DTL_PKG;

/
