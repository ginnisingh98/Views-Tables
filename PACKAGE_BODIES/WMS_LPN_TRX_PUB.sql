--------------------------------------------------------
--  DDL for Package Body WMS_LPN_TRX_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_LPN_TRX_PUB" AS
/* $Header: WMSTRXWB.pls 115.1 2000/06/25 20:04:45 pkm ship        $ */


--      Name: PROCESS_LPN_TRX
--
--      Input parameters:
--
--      Output parameters:
--       x_proc_msg         Message from the Process-Manager
--       return_status      0 on Success, 1 on Error
--
--
--
FUNCTION PROCESS_LPN_TRX(p_org_id         IN  NUMBER,
                         p_lpn_id         IN  NUMBER,
                         p_item_id        IN  NUMBER,
                         p_txn_qty        IN  NUMBER,
                         p_pri_qty        IN  NUMBER,
                         p_uom            IN  VARCHAR2,
                         p_trx_type_id    IN  NUMBER,
                         p_trx_src_type_id IN  NUMBER,
                         p_trx_action_id  IN  NUMBER,
                         p_trx_acc_id     IN  NUMBER,
                         p_date           IN  DATE,
                         p_lot_num        IN  VARCHAR2,
                         p_lot_exp_date   IN  DATE,
                         p_revision       IN  VARCHAR2,
                         p_subinv_code    IN  VARCHAR2,
                         p_locator_id     IN  NUMBER,
                         p_tosubinv_code  IN  VARCHAR2,
                         p_tolocator_id   IN  NUMBER,
                         p_xfr_org_id     IN  NUMBER,
                         p_reason_id      IN  NUMBER,
                         p_user_id        IN  NUMBER,
                         p_login_id       IN  NUMBER,
                         p_serial_num     IN  VARCHAR2,
                         p_dist_acc_id    IN  NUMBER,
                         p_cc_entry_id    IN  NUMBER,
                         p_cost_grp_id    IN  NUMBER,
                         x_proc_msg      OUT  VARCHAR2 )  RETURN NUMBER IS
BEGIN
null;
END;

END WMS_LPN_TRX_PUB;

/
