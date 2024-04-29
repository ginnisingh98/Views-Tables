--------------------------------------------------------
--  DDL for Package Body OPI_DBI_PRE_R12_COGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_PRE_R12_COGS_PKG" AS
/* $Header: OPIDECOGSPB.pls 120.2 2007/03/15 07:38:58 kvelucha ship $ */


/*=========================================
    Package Level Constants
==========================================*/

-- Source constants
PRE_R12_OPM_SOURCE CONSTANT NUMBER := 3;

-- Flag for Inventory Turns
INCLUDE_FOR_TURNS               CONSTANT NUMBER := 1;
DO_NOT_INCLUDE_FOR_TURNS        CONSTANT NUMBER := 2;


/*=================================================================
    This procedure extracts process data from the Pre R12 data model
    into the staging table. It is only called from the R12 COGS
    package when the global start date is before the R12 migration date.

    Parameters:
    - p_global_start_date: global start date
    - errbuf: error buffer
    - retcode: return code
===================================================================*/

PROCEDURE pre_r12_opm_cogs( p_global_start_date IN DATE,
                            errbuf      IN OUT NOCOPY  VARCHAR2,
                            retcode     IN OUT NOCOPY  NUMBER) IS
    -- Declaration block
    l_stmt number;

BEGIN

    -- Initialization block
    l_stmt := 0;

    bis_collection_utilities.put_line('Enter pre_r12_opm_cogs() ' ||
                                      To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));
        INSERT /*+ append parallel(opi_dbi_cogs_fstg) */ into opi_dbi_cogs_fstg (
            inventory_item_id,
            organization_id,
            order_line_id,
            top_model_line_id,
            top_model_item_id,
            top_model_item_uom,
            top_model_org_id,
            customer_id,
            cogs_val_b_draft,
            cogs_val_b,
            cogs_date,
            source,
            turns_cogs_flag,
            internal_flag
            )
    (SELECT
            inventory_item_id,
            organization_id,
            order_line_id,
            order_line_id,
            inventory_item_id,
            top_model_item_uom,
            organization_id,
            sold_to_org_id,
            0,
            sum(COGS_VAL_B),
            max(COGS_DATE),
            source,
            turns_cogs_flag,
            internal_flag
    FROM
            (SELECT /*+ full(led) use_hash(led, lines,cust_acct,msi,whse) parallel(led) parallel(lines) parallel(cust_acct) parallel(msi) parallel(whse)  */
                    lines.inventory_item_id         inventory_item_id,
                    whse.mtl_organization_id        organization_id,
                    tran.oe_order_line_id           order_line_id,
                    msi.primary_uom_code            top_model_item_uom,
                    0                               cogs_val_b_draft,
                    led.debit_credit_sign*led.amount_base cogs_val_b,
                    trunc(gl_trans_date)            cogs_date,
                    nvl(cust_acct.party_id, -1)     sold_to_org_id,
                    Decode(lines.source_type_code,
                            'EXTERNAL', DO_NOT_INCLUDE_FOR_TURNS,
                            INCLUDE_FOR_TURNS)      turns_cogs_flag,
                    Decode(lines.order_source_id, 10, 1, 0) INTERNAL_FLAG,
                    PRE_R12_OPM_SOURCE                  source
            FROM    gl_subr_led led,
                    (SELECT /*+ full(tran) full(rcv) use_hash(tran) parallel(tran) parallel(rcv) */
                            tran.doc_type,
                            rcv.oe_order_line_id    oe_order_line_id,
                            tran.line_id,
                            tran.orgn_code,
                            tran.whse_code
                    FROM    ic_tran_pnd      tran,
                             rcv_transactions rcv
                    WHERE   doc_type = 'PORC'
                    AND     completed_ind = 1
                    AND     gl_posted_ind = 1
                    AND     tran.line_id = rcv.transaction_id
                    AND     rcv.oe_order_line_id is NOT NULL
                    GROUP BY doc_type, rcv.oe_order_line_id, line_id, orgn_code, whse_code
                UNION ALL
                    SELECT /*+ full(tran) parallel(tran) */
                            tran.doc_type,
                            tran.line_id    oe_order_line_id,
                            tran.line_id,
                            tran.orgn_code,
                            tran.whse_code
                    FROM    ic_tran_pnd      tran
                    WHERE   doc_type = 'OMSO'
                    AND     completed_ind = 1
                    AND     gl_posted_ind = 1
                    GROUP BY    doc_type, line_id, line_id, orgn_code, whse_code)  tran,
                    oe_order_lines_all     lines,
                    hz_cust_accounts       cust_acct,
                    mtl_system_items_b     msi,
                    ic_whse_mst            whse
            WHERE   led.doc_type in ( 'OMSO', 'PORC' )
            AND     led.acct_ttl_type = 5200
            AND     lines.line_id = tran.oe_order_line_id
            AND     lines.sold_to_org_id = cust_acct.cust_account_id(+)
            AND     tran.doc_type = led.doc_type
            AND     tran.line_id  = led.line_id
            AND     whse.whse_code = tran.whse_code
            AND     msi.inventory_item_id=lines.inventory_item_id
            AND     msi.organization_id=lines.ship_from_org_id
            AND     led.GL_TRANS_DATE  >= p_global_start_date )
    GROUP BY    inventory_item_id,
                organization_id,
                top_model_item_uom,
                sold_to_org_id,
                order_line_id,
                turns_cogs_flag,
                internal_flag,
                source );

    l_stmt := 1;

    COMMIT;

    bis_collection_utilities.put_line('Exit pre_r12_opm_cogs() ' ||
                                      To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

EXCEPTION WHEN OTHERS THEN
--{
    ROLLBACK;

    bis_collection_utilities.put_line(' Error in pre_r12_opm_cogs() at statement');
    bis_collection_utilities.put_line( Sqlerrm );
--}
END pre_r12_opm_cogs;

END opi_dbi_pre_r12_cogs_pkg;

/
