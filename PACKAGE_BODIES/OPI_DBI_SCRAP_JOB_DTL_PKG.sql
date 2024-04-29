--------------------------------------------------------
--  DDL for Package Body OPI_DBI_SCRAP_JOB_DTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_SCRAP_JOB_DTL_PKG" AS
/* $Header: OPIRSCRJDB.pls 120.5 2006/09/14 02:08:17 asparama noship $ */


PROCEDURE get_dtl_sql ( p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                        x_custom_sql out nocopy VARCHAR2,
                        x_custom_output out nocopy BIS_QUERY_ATTRIBUTES_TBL)
IS
    g_global_start_date     DATE;
    l_period_type           VARCHAR2(255);
    l_job_info_drill        VARCHAR2(255);
    l_org                   VARCHAR2(255);
    l_item_org              VARCHAR2(255);
    l_item_cat              VARCHAR2(255);
    l_org_id                NUMBER;
    l_currency              VARCHAR2(30);
    l_item_org_where        VARCHAR2(2000);
    l_item_cat_where        VARCHAR2(2000);
    l_jobstatus_where       VARCHAR2(1500);
    l_lang_code             VARCHAR2(20);
    l_currency_code         VARCHAR2(2);
    l_flag                  mtl_parameters.process_enabled_flag%type ;
    l_job_status            VARCHAR2(1000);
    l_respid                VARCHAR(100);

BEGIN

    l_period_type       := NULL;
    l_job_info_drill    := NULL;
    l_org               := NULL;
    l_item_org          := NULL;
    l_item_cat          := NULL;
    l_org_id            := NULL;
    l_currency          := '';
    l_item_org_where    := ' ';
    l_item_cat_where    := '';
    l_jobstatus_where   := '';
    l_lang_code         := NULL;
    l_currency_code     := 'B';
    l_flag              := 'Y';
    l_job_status        := NULL;
    l_respid            := NULL;
    g_global_start_date := bis_common_parameters.get_global_start_date;


    FOR i IN 1..p_param.COUNT
    LOOP
    --{
        IF(p_param(i).parameter_name = 'ORGANIZATION+ORGANIZATION') THEN
        --{
            l_org :=  p_param(i).parameter_id;
        --}
        END IF;

	IF(p_param(i).parameter_name = 'ITEM+ENI_ITEM_INV_CAT') THEN
        --{
            IF (p_param(i).parameter_id IS NULL or upper(p_param(i).parameter_id) = 'ALL') THEN
            --{
                l_item_cat := p_param(i).parameter_id;
            --}
            ELSE
            --{
                l_item_cat := 'Selcted';
            --}
            END IF;
        --}
        END IF;

        IF(p_param(i).parameter_name = 'ITEM+ENI_ITEM_ORG') THEN
        --{
            IF (p_param(i).parameter_id IS NULL or upper(p_param(i).parameter_id) = 'ALL') THEN
            --{
                l_item_org :=  p_param(i).parameter_id;
            --}
            ELSE
            --{
                l_item_org := 'Selected';
            --}
            END IF;
        --}
        END IF;

        IF(p_param(i).parameter_name = 'CURRENCY+FII_CURRENCIES') THEN
        --{
            l_currency := p_param(i).parameter_id;
        --}
        END IF;


        IF(p_param(i).parameter_name = 'PERIOD_TYPE') THEN
        --{
            l_period_type := p_param(i).parameter_value;
        --}
        END IF;

	IF(p_param(i).parameter_name = 'OPI_MFG_WO_ATTRIB+OPI_MFG_WO_STATUS_LVL') THEN
        --{
            IF (p_param(i).parameter_id IS NULL or upper(p_param(i).parameter_id) = 'ALL') THEN
            --{
                l_job_status :=  p_param(i).parameter_ID;
            --}
            ELSE
            --{
                l_job_status := 'Selected';
            --}
            END IF;
        --}
        END IF;

    END LOOP;

    IF(l_currency = '''FII_GLOBAL1''') THEN
    --{
        l_currency_code := 'G';
    --}
    ELSIF (l_currency = '''FII_GLOBAL2''') THEN
    --{
        l_currency_code := 'SG';
    --}
    ELSE
    --{
        l_currency_code := 'B';
    --}
    END IF;

    l_lang_code := USERENV('LANG');


    IF (upper(l_org)<>'ALL') THEN
    --{
        SELECT  trim(both '''' from l_org)
        INTO    l_org
        FROM    dual;
    --}
    END IF;

    IF (l_org is NULL) THEN
    --{
        SELECT  fnd_global.resp_id INTO l_respid from dual ;

        SELECT  id  INTO    l_org
        FROM    (SELECT id
                FROM    bis_organizations_v
                WHERE   responsibility_id = l_respid
                ORDER BY value asc)
        WHERE   rownum=1;
    --}
    END IF;


    IF (UPPER(l_item_org) <> 'ALL') THEN
    --{
        l_item_org_where :=' and scrap.inventory_item_id || ''-'' || scrap.organization_id in '
                            || ' (&ITEM+ENI_ITEM_ORG)' || ' and scrap.organization_id = ' || l_org;
    --{
    ELSE
    --{
        l_item_org_where :='  and scrap.organization_id = ' || l_org;
    --}
    END IF;

    IF (UPPER(l_job_status) <> 'ALL') THEN
    --{
        l_jobstatus_where := ' and job.job_status_code in (&OPI_MFG_WO_ATTRIB+OPI_MFG_WO_STATUS_LVL)';
    --}
    END IF;

    IF(UPPER(l_item_cat) <> 'ALL') THEN
    --{
        l_item_cat_where := '  and itemorg.inv_category_id in (&ITEM+ENI_ITEM_INV_CAT)';
    --}
    END IF;

    l_job_info_drill := 'OPI_DBI_JOB_INFO_DISC_REP&addBreadCrumb=Y&cloInd=1';

    SELECT  process_enabled_flag
    INTO    l_flag
    FROM    mtl_parameters mp
    WHERE   mp.organization_id = trim(both '''' from l_org);

    IF(l_flag<>'Y') THEN
    --{
        x_custom_sql := '
        SELECT  fact.job_name ||''(''|| mtp.organization_code || '')''
                                        OPI_ATTRIBUTE1,
                jobstatus.value         OPI_ATTRIBUTE2,
                itemorg.value           OPI_ATTRIBUTE3,
                itemorg.description     OPI_ATTRIBUTE4,
                uom.unit_of_measure     OPI_ATTRIBUTE5,
                ''pFunctionName='||l_job_info_drill ||'&jobId=''||fact.job_id||
                                           ''&orgId=''||fact.organization_id ||
                                           ''&jobName=''|| mtp.organization_code ||
                                           ''&repId=''|| fact.job_name ||
                                           ''&jobType=''|| fact.job_type OPI_ATTRIBUTE6,
                fact.opi_measure1       OPI_MEASURE1,
                fact.opi_measure2       OPI_MEASURE2,
                fact.opi_measure3       OPI_MEASURE3,
                fact.opi_measure4       OPI_MEASURE4,
                fact.opi_measure5       OPI_MEASURE5,
                fact.opi_measure6       OPI_MEASURE6,
                fact.opi_measure7       OPI_MEASURE7,
                fact.opi_measure8       OPI_MEASURE8,
                fact.opi_measure9       OPI_MEASURE9,
                fact.opi_measure10      OPI_MEASURE10
        FROM
            (SELECT
                (rank() over
                    (&ORDER_BY_CLAUSE nulls last, job_name, job_id, job_type, inventory_item_id, organization_id)) -1 rnk,
                    job_name,
                    job_id,
                    job_type,
                    job_status_code,
                    organization_id,
                    inventory_item_id,
                    uom_code,
                    opi_measure1,
                    opi_measure2,
                    opi_measure3,
                    opi_measure4,
                    opi_measure5,
                    opi_measure6,
                    opi_measure7,
                    opi_measure8,
                    opi_measure9,
                    opi_measure10
            FROM
                (SELECT
                    job_name,
                    job_id,
                    job_type,
                    job_status_code,
                    organization_id,
                    inventory_item_id,
                    uom_code,
                    prod_qty - scrap_qty        opi_measure1,
                    scrap_qty                   opi_measure2,
                    scrap_val                   opi_measure3,
                    prod_val - scrap_val        opi_measure4,
                    prod_val                    opi_measure5,
                    scrap_val/decode(prod_val,0,null,prod_val)*100  opi_measure6,
                    sum(scrap_val) over()                           opi_measure7,
                    sum(prod_val - scrap_val) over()                opi_measure8,
                    sum(prod_val) over()                            opi_measure9,
                    sum(scrap_val/decode(prod_val,0,null,prod_val)*100) over() opi_measure10
            FROM
                (SELECT job.job_name,
                        scrap.job_id,
                        scrap.job_type,
                        job.job_status_code,
                        scrap.organization_id,
                        scrap.inventory_item_id,
                        job.uom_code,
                        sum(scrap.production_qty)   prod_qty,
                        sum(decode(''' || l_currency_code || ''',
                                ''B'', scrap.production_val_b,
                                ''G'', scrap.production_val_g,
                                ''SG'', scrap.production_val_sg))
                                                    prod_val,
                        sum(scrap.scrap_qty)        scrap_qty,
                        sum(decode(''' || l_currency_code || ''',
                                ''B'', scrap.scrap_val_b,
                                ''G'', scrap.scrap_val_g,
                                ''SG'', scrap.scrap_val_sg))
                                                    scrap_val
                FROM    opi_prod_scr_mv scrap,
                        opi_dbi_jobs_f  job
                WHERE   scrap.transaction_date between &BIS_CURRENT_EFFECTIVE_START_DATE AND &BIS_CURRENT_ASOF_DATE
                AND     scrap.job_id = job.job_id
                AND     scrap.job_type = job.job_type
                AND     scrap.inventory_item_id = job.assembly_item_id
                AND     scrap.organization_id = job.organization_id
                AND     scrap.transaction_date >= ''' || g_global_start_date || ''''
                         || l_jobstatus_where || l_item_org_where || '
                GROUP BY
                        job.job_name,
                        scrap.job_id,
                        scrap.job_type,
                        job.job_status_code,
                        scrap.organization_id,
                        scrap.inventory_item_id,
                        job.uom_code)))             fact,
                mtl_parameters                  mtp,
                opi_mfg_wo_status_lvl_v         jobstatus,
                eni_item_org_v                  itemorg,
                mtl_units_of_measure_vl         uom
        WHERE   jobstatus.id = CASE WHEN fact.job_type=3 THEN DECODE (fact.job_status_code,2,12,1,3)
                                    ELSE fact.job_status_code
                                    END
        AND     mtp.organization_id = fact.organization_id
        AND     uom.uom_code = fact.uom_code
        AND     itemorg.inventory_item_id = fact.inventory_item_id
        AND     itemorg.organization_id = fact.organization_id'
                || l_item_cat_where || '
        AND (rnk between &START_INDEX and &END_INDEX or &END_INDEX = -1)
        &ORDER_BY_CLAUSE nulls last';
    --}
    ELSE
    --{
        x_custom_sql :='
        SELECT
         NULL OPI_ATTRIBUTE1
        ,NULL OPI_ATTRIBUTE2
        ,NULL OPI_ATTRIBUTE3
        ,NULL OPI_ATTRIBUTE4
        ,NULL OPI_ATTRIBUTE5
        ,NULL OPI_ATTRIBUTE6
        ,NULL OPI_MEASURE1
        ,NULL OPI_MEASURE2
        ,NULL OPI_MEASURE3
        ,NULL OPI_MEASURE4
        ,NULL OPI_MEASURE5
        ,NULL OPI_MEASURE6
        ,NULL OPI_MEASURE7
        ,NULL OPI_MEASURE8
        ,NULL OPI_MEASURE9
        ,NULL OPI_MEASURE10
        FROM dual WHERE 1=2';
    --}
    END IF;


  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();


 END get_dtl_sql;

 END OPI_DBI_SCRAP_JOB_DTL_PKG;

/
