--------------------------------------------------------
--  DDL for Package Body OPI_DBI_MFG_JOB_DTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_MFG_JOB_DTL_PKG" AS
/*$Header: OPIDRMCVJDB.pls 120.1 2006/03/19 22:07:16 vganeshk noship $ */

  PROCEDURE get_dtl_sql (p_param in BIS_PMV_PAGE_PARAMETER_TBL,
       x_custom_sql out nocopy VARCHAR2,
       x_custom_output out nocopy BIS_QUERY_ATTRIBUTES_TBL)
IS

    l_org 		  VARCHAR2(255);
    l_item_org		  VARCHAR2(255);
    l_item_cat		  VARCHAR2(255);
    l_currency            VARCHAR2(30);
    l_item_org_where      VARCHAR2(2000);
    l_item_cat_where      VARCHAR2(2000);
    l_currency_code       VARCHAR2(2);
    l_flag                VARCHAR2(1);
    l_org_where           VARCHAR2(2000);
    l_respid 		  NUMBER;
    l_job_info_drill      VARCHAR2(255);

 BEGIN

   --Initialization
    l_org 		  := NULL;
    l_item_org		  := NULL;
    l_item_cat		  := NULL;
    l_currency            := '';
    l_item_org_where      := NULL;
    l_item_cat_where      := NULL;
    l_currency_code       := 'B';
    l_flag                := NULL;
    l_org_where           := NULL;
    l_respid 		  := -1;
    l_job_info_drill      := NULL;

   FOR i IN 1..p_param.COUNT
    LOOP
      IF(p_param(i).parameter_name = 'ORGANIZATION+ORGANIZATION')
        THEN l_org :=  p_param(i).parameter_id;
      END IF;

    IF(p_param(i).parameter_name = 'ITEM+ENI_ITEM_ORG') THEN
      IF (p_param(i).parameter_id IS NULL or upper(p_param(i).parameter_id) = 'ALL') THEN
          l_item_org :=  p_param(i).parameter_id;
      ELSE
          l_item_org := 'Selected';
      END IF;
    END IF;

    IF(p_param(i).parameter_name = 'ITEM+ENI_ITEM_INV_CAT') THEN
       IF (p_param(i).parameter_id IS NULL or upper(p_param(i).parameter_id) = 'ALL') THEN
           l_item_cat := p_param(i).parameter_id;
       ELSE
           l_item_cat := 'Selected';
       END IF;
    END IF;

    IF(p_param(i).parameter_name = 'CURRENCY+FII_CURRENCIES') then
       l_currency := p_param(i).parameter_id;
    END IF;

   END LOOP;

    IF(l_currency = '''FII_GLOBAL1''') then
        l_currency_code := 'G';
    ELSE
      IF
        (l_currency = '''FII_GLOBAL2''') then
         l_currency_code := 'SG';
      END IF;
    END IF;


    IF (UPPER(l_item_org) <> 'ALL') THEN
      l_item_org_where :='
        AND fact.assembly_item_id||''-''|| fact.organization_id in' ||'(&ITEM+ENI_ITEM_ORG)';
    END IF;

    IF(UPPER(l_item_cat) <> 'ALL') THEN
      l_item_cat_where := ' and itemorg.inv_category_id in (&ITEM+ENI_ITEM_INV_CAT)';
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

    l_org_where := ' and jobs.organization_id = '||l_org;

    IF (l_flag = 'Y') THEN

         l_job_info_drill := 'OPI_DBI_JOB_INFO_PROC_REP&addBreadCrumb=Y&cloInd=1';

    ELSE

         l_job_info_drill := 'OPI_DBI_JOB_INFO_DISC_REP&addBreadCrumb=Y&cloInd=1';

     END IF;

    x_custom_sql :=
    'SELECT
       f.job_name ||''(''||mtp.organization_code||'')''   OPI_ATTRIBUTE1
,      itemorg.value                                      OPI_ATTRIBUTE2
,      itemorg.description                                OPI_ATTRIBUTE3
,      v2.unit_of_measure                                 OPI_ATTRIBUTE4
,      ''pFunctionName='||l_job_info_drill ||'&jobId=''||f.job_id||
                                             ''&orgId=''||f.org_id ||
                                             ''&jobName=''|| mtp.organization_code ||
                                             ''&repId=''|| f.job_name ||
                                             ''&jobType=''|| f.job_type OPI_ATTRIBUTE5
,      f.opi_measure1                                     OPI_MEASURE1
,      f.opi_measure2                                     OPI_MEASURE2
,      f.opi_measure3                                     OPI_MEASURE3
,      f.opi_measure4                                     OPI_MEASURE4
,      f.opi_measure5                                     OPI_MEASURE5
,      f.opi_measure6                                     OPI_MEASURE6
,      f.opi_measure7                                     OPI_MEASURE7
,      f.opi_measure8			                  OPI_MEASURE8
,      f.opi_measure9		                          OPI_MEASURE9
,      f.opi_measure10                                    OPI_MEASURE10

    from
      (select
         (rank() over
          (&ORDER_BY_CLAUSE nulls last,org_id,job_id,closed_date)) - 1 rnk
		   ,org_id
           ,assembly_item_id
           ,uom_code
           ,job_id
           ,job_type
	   ,job_name
           ,closed_date
           ,opi_measure1
           ,opi_measure2
           ,opi_measure3
           ,opi_measure4
           ,opi_measure5
           ,opi_measure6
	   ,opi_measure7
	   ,opi_measure8
	   ,(opi_measure8-opi_measure7) opi_measure9
	   ,((opi_measure8-opi_measure7)/decode(opi_measure7,0,null,opi_measure7))*100 opi_measure10

       from

           (select
             org_id
            ,assembly_item_id
            ,uom_code
            ,job_id
            ,job_type
	    ,job_name
            ,closed_date
            ,opi_measure1
            ,opi_measure2
            ,opi_measure3_b*decode(''' || l_currency_code || ''', ''B'',1, ''G'', conversion_rate, ''SG'', sec_conversion_rate) opi_measure3
            ,opi_measure4_b*decode(''' || l_currency_code || ''', ''B'',1, ''G'', conversion_rate, ''SG'', sec_conversion_rate) opi_measure4
	    ,opi_measure5_b*decode(''' || l_currency_code || ''', ''B'',1, ''G'', conversion_rate, ''SG'', sec_conversion_rate) opi_measure5
	    ,opi_measure6
	    ,opi_measure7_b*decode(''' || l_currency_code || ''', ''B'',1, ''G'', conversion_rate, ''SG'', sec_conversion_rate) opi_measure7
	    ,opi_measure8_b*decode(''' || l_currency_code || ''', ''B'',1, ''G'', conversion_rate, ''SG'', sec_conversion_rate) opi_measure8
	    from
              (select
                 fact.organization_id org_id
                ,fact.job_id job_id
                ,fact.job_type job_type
		,jobs.job_name job_name
                ,fact.closed_date
                ,fact.conversion_rate
		,fact.sec_conversion_rate
                ,fact.uom_code
                ,fact.assembly_item_id
                ,fact.organization_id
                ,sum(jobs.start_quantity)       opi_measure1
                ,sum(fact.actual_qty_completed) opi_measure2
                ,sum(fact.standard_value_b)     opi_measure3_b
                ,sum(fact.actual_value_b)       opi_measure4_b
		,sum(fact.actual_value_b)- sum(fact.standard_value_b) opi_measure5_b
	        ,((sum(fact.actual_value_b)-sum(fact.standard_value_b))/decode(sum(fact.standard_value_b),0,null,sum(fact.standard_value_b)))*100 opi_measure6
	        ,sum(sum(fact.standard_value_b)) over() opi_measure7_b
		,sum(sum(fact.actual_value_b)) over()  opi_measure8_b

	        from
                  opi_dbi_mfg_cst_var_f   fact
                 ,opi_dbi_jobs_f         jobs
                where
                          fact.closed_date between &BIS_CURRENT_EFFECTIVE_START_DATE and &BIS_CURRENT_ASOF_DATE
                   and    fact.job_id = jobs.job_id
                   and    fact.assembly_item_id = jobs.assembly_item_id
                   and    fact.organization_id = jobs.organization_id
                   and    fact.job_type = jobs.job_type
		   and    fact.source = jobs.source
		   and    jobs.job_status_code = 12'
		   || l_item_org_where
		   || l_org_where ||'

                group by
                     fact.organization_id
                    ,fact.job_id
                    ,fact.job_type
		    ,jobs.job_name
                    ,fact.closed_date
		    ,fact.conversion_rate
		    ,fact.sec_conversion_rate
                    ,fact.uom_code
                    ,fact.assembly_item_id
                    ,fact.organization_id
                   )))f
                  ,eni_item_org_v itemorg
                  ,mtl_units_of_measure_vl v2
                  ,fii_time_day        time
                  ,mtl_parameters          mtp
                where
                         mtp.organization_id = f.org_id
		  and    itemorg.id = f.assembly_item_id||''-''|| f.org_id
		  and    itemorg.organization_id = f.org_id
		  and    itemorg.primary_uom_code = V2.uom_code
                  and    time.report_date = f.closed_date
                  and (rnk between &START_INDEX and &END_INDEX or &END_INDEX = -1) ' ||
                  l_item_cat_where || '

		   &ORDER_BY_CLAUSE nulls last';

  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

 END get_dtl_sql;
 END OPI_DBI_MFG_JOB_DTL_PKG;

/
