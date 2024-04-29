--------------------------------------------------------
--  DDL for Package Body OPI_DBI_PRE_R12_RES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_PRE_R12_RES_PKG" AS
/* $Header: OPIDREOB.pls 120.3 2006/04/28 13:52:49 julzhang noship $ */


/*=============================================
    Package level Constants
=============================================*/
g_ok                    CONSTANT NUMBER(1)  := 0;
g_warning               CONSTANT NUMBER(1)  := 1;
g_error                 CONSTANT NUMBER(1)  := -1;

PRE_R12_OPM_SOURCE      CONSTANT NUMBER := 3;


/*======================================================
    This procedure extracts actual resource usage data
    from the Pre-R12 data model into the staging table for
    initial load.  It is only called when the global start
    date is before the R12 migration date.

    Parameters:
    - errbuf: error buffer
    - retcode: return code
=======================================================*/
PROCEDURE pre_r12_opm_res_actual (errbuf    IN OUT NOCOPY VARCHAR2,
                                  retcode   IN OUT NOCOPY VARCHAR2) IS

    l_rowcount      NUMBER;
    g_hr_uom        sy_uoms_mst.um_code%TYPE;

BEGIN

    retcode := 0;
    g_hr_uom := fnd_profile.value( 'BOM:HOUR_UOM_CODE');

     bis_collection_utilities.put_line('Enter pre_r12_opm_res_actual() ' ||
                                      To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

    INSERT /*+ append */ INTO opi_dbi_res_actual_stg (
            resource_id,
            organization_id,
            transaction_date,
            uom,
            actual_qty_draft,
            actual_qty,
            actual_qty_g_draft,
            actual_qty_g,
            actual_val_b_draft,
            actual_val_b,
            source,
            job_id,
            job_type,
            assembly_item_id,
            department_id)
        SELECT /*+ ORDERED */
                rdtl.resource_id            resource_id,
                rdtl.organization_id          organization_id,
                TRUNC(rtran.trans_date)     transaction_date,
                rtran.trans_um              uom,
                0                           actual_qty_draft,
                sum(rtran.resource_usage * prod.cost_alloc) actual_qty,
                0                           actual_qty_g_draft,
                sum(rtran.resource_usage * prod.cost_alloc * hruom.std_factor / ruom.std_factor) actual_qtg_g,
                 0                           actual_val_b_draft,
                sum(led.amount_base * led.debit_credit_sign)   actual_val_b,
                PRE_R12_opm_source           source,
                rtran.doc_id                job_id,
                4                           job_type,
                prod.inventory_item_id       assembly_item_id,
                rmst.resource_class         department_id
        FROM    sy_uoms_mst                 hruom,
                sy_uoms_mst                 ruom,
                gme_resource_txns           rtran,
                cr_rsrc_dtl                 rdtl,
                cr_rsrc_mst_b               rmst,
                gme_material_details        prod,
                gl_subr_led                 led
        WHERE   hruom.um_code = g_hr_uom
        AND     ruom.um_code = rtran.trans_um
        AND     rtran.completed_ind = 1
        AND     rdtl.orgn_code = rtran.orgn_code
        AND     rdtl.resources = rtran.resources
        AND     rmst.resources = rdtl.resources
        AND     prod.batch_id = rtran.doc_id
        AND     prod.line_type = 1
        AND     rtran.doc_id = led.doc_id -- new
        AND     rtran.line_id = led.line_id -- new
        AND     rtran.doc_type = led.doc_type -- new
        AND     rtran.trans_date = led.gl_trans_date --new
        AND     led.acct_ttl_type = 1530 --new (WIP)
        AND     led.sub_event_type = 50050 -- new (resource step ceritification)
        GROUP BY
                prod.inventory_item_id,
                rtran.doc_id,
                rdtl.resource_id,
                rmst.resource_class,
                rdtl.organization_id,
                TRUNC(rtran.trans_date),
                rtran.trans_um;

    COMMIT;


    l_rowcount := sql%rowcount;

    bis_collection_utilities.put_line('From Pre R12 Data Model - OPM Resource Actual: ' ||
             to_char(l_rowcount) || ' rows initially collected into staging table at '||
             to_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

     bis_collection_utilities.put_line('Exit pre_r12_opm_res_actual() ' ||
                                      To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));
EXCEPTION WHEN OTHERS THEN
--{
    errbuf:= Sqlerrm;
    retcode:= SQLCODE;

    ROLLBACK;

    bis_collection_utilities.put_line('Exception in pre_r12_opm_res_actual ' || errbuf );
--}
END pre_r12_opm_res_actual;


END opi_dbi_pre_r12_res_pkg;

/
