--------------------------------------------------------
--  DDL for Package Body WSMPLCVA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSMPLCVA" AS
/* $Header: WSMLCVAB.pls 120.1 2006/03/27 20:42:37 mprathap noship $ */

--**********************************************************************************************
PROCEDURE load_org_table IS

-- BUG 3934661
-- when calling dbms_utility.get_hash_value use larger seed number
-- OLD: dbms_utility.get_hash_value(str, 1000, 5625);
-- NEW: dbms_utility.get_hash_value(str, 37, 1073741824);

--abb H optional scrap accounting added ESTIMATED_SCRAP_ACCOUNTING

cursor  c_wsm_param is
select  wsm.ORGANIZATION_ID,
        wsm.COPRODUCTS_SUPPLY_DEFAULT,
        wsm.DEFAULT_ACCT_CLASS_CODE,
        wsm.OP_SEQ_NUM_INCREMENT,
        wsm.LAST_OPERATION_SEQ_NUM,
        wsm.ESTIMATED_SCRAP_ACCOUNTING,
        NULL,
        NULL,
        wp.po_creation_time
--from  MTL_PARAMETERS MP , WSM_PARAMETERS WSM, ORG_ORGANIZATION_DEFINITIONS ORG
from    MTL_PARAMETERS MP , WSM_PARAMETERS WSM, HR_ALL_ORGANIZATION_UNITS ORG, WIP_PARAMETERS WP
where   MP.ORGANIZATION_ID =  WSM.ORGANIZATION_ID
and     ORG.ORGANIZATION_ID =  WSM.ORGANIZATION_ID
and     WP.ORGANIZATION_ID =  WSM.ORGANIZATION_ID
and     UPPER(MP.WSM_ENABLED_FLAG)='Y'
and     TRUNC(SYSDATE) <= NVL(ORG.DATE_TO, SYSDATE+1);

v_index         NUMBER;

l_error_code    number := 0;                -- BUG3126650
l_error_msg     varchar2(2000) := null;     -- BUG3126650

BEGIN

    open c_wsm_param;
    loop
        fetch c_wsm_param into v_rec_wsm_param;
        v_org(v_rec_wsm_param.ORGANIZATION_ID) := v_rec_wsm_param;
        exit when c_wsm_param%notfound;
    end loop;
    close c_wsm_param;

    v_index := v_org.first;
    while v_index <= v_org.last
    loop
        -- BEGIN: BUG3126650
        --SELECT max(acct_period_id)
        --INTO v_org(v_index).MAX_ORG_ACC_PERIODS
        --FROM ORG_ACCT_PERIODS
        --WHERE organization_id = v_index
        --AND period_start_date <= trunc(SYSDATE)
        --AND open_flag = 'Y';
        v_org(v_index).MAX_ORG_ACC_PERIODS := WSMPUTIL.GET_INV_ACCT_PERIOD(
                        x_err_code         => l_error_code,
                        x_err_msg          => l_error_msg,
                        p_organization_id  => v_index,
                        p_date             => sysdate);
        -- END: BUG3126650

        SELECT max(stock_locator_control_code)
        INTO  v_org(v_index).MAX_STK_LOC_CNTRL
        FROM  mtl_parameters
        WHERE organization_id = v_index;

        v_index := v_org.next(v_index);
    end loop;

END load_org_table;

--**********************************************************************************************

PROCEDURE load_class_code IS

type t_wlji_org2       is table of wip_accounting_classes.organization_id%type;
type t_wlji_cc         is table of wip_accounting_classes.class_code%type;

v_wlji_org2            t_wlji_org2 := t_wlji_org2();
v_wlji_cc              t_wlji_cc   := t_wlji_cc();

cursor  c_wsm_wac is
    select  organization_id,
            class_code
    from    wip_accounting_classes
    where   nvl(disable_date, sysdate+2) > sysdate
    and     class_type = 5 ;


str         VARCHAR2(100); -- assuming that to_char(org_id)||class_code has length < 100
hash_value  NUMBER;
v_index     NUMBER;

BEGIN

    open c_wsm_wac;
    loop
            fetch c_wsm_wac bulk collect into v_wlji_org2, v_wlji_cc;
            exit when c_wsm_wac%notfound;
    end loop;
    close c_wsm_wac;

    v_index := v_wlji_org2.first;
    while v_index <= v_wlji_org2.last
    loop
        str := to_char(v_wlji_org2(v_index))||v_wlji_cc(v_index);
        hash_value := dbms_utility.get_hash_value(str, 37, 1073741824);
        v_class_code(hash_value) := v_wlji_cc(v_index);

        v_index := v_wlji_org2.next(v_index);
    end loop;

END load_class_code;

--**********************************************************************************************

PROCEDURE load_subinventory IS

type t_wlji_org1                 is table of wsm_subinventory_extensions.organization_id%type;
type t_wlji_compl_subinv         is table of wsm_subinventory_extensions.secondary_inventory_name%type;

v_wlji_org1             t_wlji_org1         := t_wlji_org1();
v_wlji_compl_subinv     t_wlji_compl_subinv := t_wlji_compl_subinv();

cursor  c_wsm_subinv is
    select  organization_id,
            secondary_inventory_name
    from    wsm_subinventory_extensions;

str         VARCHAR2(100); -- assuming that to_char(org_id)||subinventory has length < 100
hash_value  NUMBER;
v_index     NUMBER;

BEGIN

    open c_wsm_subinv;
    loop
        fetch c_wsm_subinv bulk collect into v_wlji_org1, v_wlji_compl_subinv;
        exit when c_wsm_subinv%notfound;
    end loop;
    close c_wsm_subinv;

    v_index := v_wlji_org1.first;
    while v_index <= v_wlji_org1.last
    loop
        str := to_char(v_wlji_org1(v_index))||v_wlji_compl_subinv(v_index);
        hash_value := dbms_utility.get_hash_value(str, 37, 1073741824);
        v_subinv(hash_value) := v_wlji_compl_subinv(v_index);

        v_index := v_wlji_org1.next(v_index);
    end loop;

END load_subinventory;

--**********************************************************************************************

END WSMPLCVA;

/
