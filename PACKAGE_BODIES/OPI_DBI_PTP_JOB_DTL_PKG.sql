--------------------------------------------------------
--  DDL for Package Body OPI_DBI_PTP_JOB_DTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_PTP_JOB_DTL_PKG" AS
/* $Header: OPIDRPTPJDB.pls 120.4 2007/06/22 05:22:43 sdiwakar ship $ */


PROCEDURE get_dtl_sql ( p_param         IN  BIS_PMV_PAGE_PARAMETER_TBL,
                        x_custom_sql    OUT NOCOPY VARCHAR2,
                        x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
    l_period_type           VARCHAR2(255);
    l_org                   VARCHAR2(255);
    l_item_org              VARCHAR2(255);
    l_item_cat              VARCHAR2(255);
    l_currency              VARCHAR2(255);
    l_currency_code         VARCHAR2(2);
    l_flag                  mtl_parameters.process_enabled_flag%type;
    l_flag_where            VARCHAR2(255);
    l_lang_code             VARCHAR2(20);
    l_item_org_where        VARCHAR2(2000);
    l_jobstatus_where       VARCHAR2(1500);
    l_job_info_drill        VARCHAR2(255);
    l_jobstatus             VARCHAR2(1000);
    l_item_cat_where        VARCHAR2(2000);
    g_gsd                   DATE;

BEGIN
    l_period_type           := NULL;
    l_org                   := NULL;
    l_item_org              := NULL;
    l_item_cat              := NULL;
    l_currency              := NULL;
    l_currency_code         := NULL;
    l_flag                  := NULL;
    l_flag_where            := NULL;
    l_lang_code             := NULL;
    l_item_org_where        := NULL;
    l_jobstatus_where       := NULL;
    l_item_cat_where        := NULL;
    l_job_info_drill        := NULL;
    l_jobstatus             := NULL;
    g_gsd                   := bis_common_parameters.get_global_start_date;


    FOR i IN 1..p_param.COUNT
    LOOP
    --{
        IF (p_param(i).parameter_name = 'ORGANIZATION+ORGANIZATION') THEN
        --{
            l_org :=  p_param(i).parameter_id;
        --}
        END IF;

        IF (p_param(i).parameter_name = 'ITEM+ENI_ITEM_ORG') THEN
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

        IF (p_param(i).parameter_name = 'PERIOD_TYPE') THEN
        --{
            l_period_type := p_param(i).parameter_value;
        --}
        END IF;

        IF (p_param(i).parameter_name = 'ITEM+ENI_ITEM_INV_CAT') THEN
        --{
            IF (p_param(i).parameter_id IS NULL or upper(p_param(i).parameter_id) = 'ALL') THEN
            --{
                l_item_cat := p_param(i).parameter_id;
            --}
            ELSE
            --{
                l_item_cat := 'Selected';
            --}
            END IF;
        --}
        END IF;


        IF (p_param(i).parameter_name = 'OPI_MFG_WO_ATTRIB+OPI_MFG_WO_STATUS_LVL') THEN
        --{
            IF (p_param(i).parameter_id IS NULL or upper(p_param(i).parameter_id) = 'ALL') THEN
            --{
                l_jobstatus := p_param(i).parameter_id;
            --}
            ELSE
            --{
                l_jobstatus := 'Selected';
            --}
            END IF;
        --}
        END IF;

        IF (p_param(i).parameter_name = 'CURRENCY+FII_CURRENCIES') THEN
        --{
            l_currency := p_param(i).parameter_id;
        --}
        END IF;
    --}
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


    SELECT  process_enabled_flag
    INTO    l_flag
    FROM    mtl_parameters mp
    WHERE   mp.organization_id = trim(both '''' from l_org);


    IF (UPPER(l_item_org) <> 'ALL') THEN
    --{
        l_item_org_where := ' and wip_f.inventory_item_id || ''-'' || wip_f.organization_id in '
                            || ' (&ITEM+ENI_ITEM_ORG)' || ' and wip_f.organization_id = ' || l_org;
    --}
    ELSE
    --{
        l_item_org_where :=' AND wip_f.organization_id = '|| l_org;
    --}
    END IF;


    IF (UPPER(l_jobstatus) <> 'ALL' and l_jobstatus IS NOT NULL) THEN
    --{
        l_jobstatus_where := ' AND job.job_status_code in (&OPI_MFG_WO_ATTRIB+OPI_MFG_WO_STATUS_LVL) ';
    --}
    END IF;


    IF UPPER(l_item_cat) <> 'ALL' THEN
    --{
        l_item_cat_where := ' AND itemorg.inv_category_id in (&ITEM+ENI_ITEM_INV_CAT)';
    --}
    END IF;


    /* Job Information Page URL */
    IF  (l_flag = 'Y') THEN     --Process
    --{
        l_job_info_drill := 'OPI_DBI_JOB_INFO_PROC_REP&addBreadCrumb=Y';
    --}
    ELSE
    --{
        l_job_info_drill := 'OPI_DBI_JOB_INFO_DISC_REP&addBreadCrumb=Y';
    --}
    END IF;


   /* Query */
    x_custom_sql := '
    SELECT  f.job_name ||''(''||mtp.organization_code||'')''
                                        OPI_ATTRIBUTE1,
            jobstatus.value             OPI_ATTRIBUTE2,
            itemorg.value               OPI_ATTRIBUTE3,
            itemorg.description         OPI_ATTRIBUTE4,
            uom.unit_of_measure         OPI_ATTRIBUTE5,
             ''pFunctionName='||l_job_info_drill ||'&jobId=''||f.job_id||
                                           ''&orgId=''||f.organization_id ||
                                           ''&jobName=''|| mtp.organization_code ||
                                           ''&repId=''|| replace(f.job_name,'' '','''') ||
                                           ''&jobType=''|| f.job_type ||
                                           ''&cloInd=''|| decode(''' || l_flag || ''', ''Y'',
                                                decode(f.job_status_code, 12, 1, 2), 1) OPI_ATTRIBUTE6,
            f.opi_measure1              OPI_MEASURE1,
            f.opi_measure2              OPI_MEASURE2,
            f.opi_measure3              OPI_MEASURE3
    FROM
        (SELECT
            (rank() over
                (&ORDER_BY_CLAUSE nulls last, job_name, job_id, job_type, inventory_item_id, organization_id)) -1 rnk,
                job_name,
                job_id,
                job_type,
                inventory_item_id,
                organization_id,
                job_status_code,
                uom_code,
                opi_measure1                opi_measure1,
                opi_measure2                opi_measure2,
                sum(opi_measure2)over()     opi_measure3
        FROM
            (SELECT job.job_name,
                    job.job_id,
                    job.job_type,
                    job.assembly_item_id            inventory_item_id,
                    job.organization_id,
                    job.job_status_code,
                    job.uom_code,
                    sum(wip_f.completion_quantity)    opi_measure1,
                    sum(decode(''' || l_currency_code || ''',
                                ''B'', wip_f.completion_value_b,
                                ''G'', wip_f.completion_value_g,
                                ''SG'', wip_f.completion_value_sg))
                                                    opi_measure2
            FROM    opi_dbi_jobs_f      job,
                    opi_dbi_wip_comp_f  wip_f
            WHERE   job.line_type = 1
            AND     trunc(wip_f.transaction_date) >= &BIS_CURRENT_EFFECTIVE_START_DATE
            AND     trunc(wip_f.transaction_date) <= &BIS_CURRENT_ASOF_DATE
            AND     job.job_id = wip_f.job_id
            AND     wip_f.transaction_date >= '''||g_gsd||'''
                    '|| l_item_org_where || l_jobstatus_where||'
            GROUP BY
                    job.job_name,
                    job.job_id,
                    job.job_type,
                    job.organization_id,
                    job.job_status_code,
                    job.uom_code,
                    job.assembly_item_id))              f,
        mtl_parameters                  mtp,
        opi_mfg_wo_status_lvl_v         jobstatus,
        eni_item_org_v                  itemorg,
        mtl_units_of_measure_vl         uom
    WHERE
        jobstatus.id = f.job_status_code
    AND mtp.organization_id = f.organization_id
    AND uom.uom_code = f.uom_code
    AND itemorg.inventory_item_id = f.inventory_item_id
    AND itemorg.organization_id = f.organization_id'
    || l_item_cat_where || '
    AND (rnk between &START_INDEX and &END_INDEX or &END_INDEX = -1)
    &ORDER_BY_CLAUSE nulls last';

    x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

END get_dtl_sql;
END OPI_DBI_PTP_JOB_DTL_PKG;

/
