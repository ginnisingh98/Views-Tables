--------------------------------------------------------
--  DDL for Package Body DPP_ITEMCOST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DPP_ITEMCOST_PVT" AS
/* $Header: dppvcstb.pls 120.25.12010000.6 2010/04/21 13:34:30 kansari ship $ */
-- Package name     : DPP_ITEMCOST_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'DPP_ITEMCOST_PVT';
G_DEBUG BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
G_FILE_NAME     CONSTANT VARCHAR2(14) := 'dppvcstb.pls';
---------------------------------------------------------------------
-- PROCEDURE
--    Update_ItemCost
--
-- PURPOSE
--    Update item cost.
--
-- PARAMETERS
--
-- NOTES
--    1.
--    2.
----------------------------------------------------------------------
function wait_for_rec_processing(in_execution_detail_id IN number default NULL,
                                 in_transaction_header_id IN number default NULL,
                                 interval   IN number default 60,
                                 max_wait   IN number default 0,
                                 message    OUT NOCOPY varchar2)
return  boolean is

Call_Status     boolean;
Time_Out        boolean := FALSE;
pipename        varchar2(60);
req_phase       varchar2(15);
STime                          number(30);
ETime                          number(30);
i                                              number;
l_interface_pending_count number;
begin
    if ( max_wait > 0 ) then
        Time_Out := TRUE;
        Select To_Number(((To_Char(Sysdate, 'J') - 1 ) * 86400) + To_Char(Sysdate, 'SSSss'))
          Into STime From Sys.Dual;
    end if;

    LOOP

        SELECT
                                 count(*)
                          INTO
                                 l_interface_pending_count
                          FROM
                                 mtl_transactions_interface
                          WHERE
                                 source_code = 'Price Protection'      AND
                                 source_header_id = in_execution_detail_id       AND
                                 transaction_header_id = in_transaction_header_id  AND
                                 process_flag = 1;

         IF l_interface_pending_count = 0 THEN
               call_status := TRUE;
               return (call_status);
                        end if;

        if ( Time_Out ) then
           Select To_Number(((To_Char(Sysdate, 'J') - 1 ) * 86400) + To_Char(Sysdate, 'SSSss'))
             Into ETime From Sys.Dual;

           if ( (ETime - STime) >= max_wait ) then
              call_status := FALSE;
              return (call_status);
           end if;
        end if;
        dbms_lock.sleep(interval);
    END LOOP;

    exception
       when others then
          Fnd_Message.Set_Name('FND', 'CP-Generic oracle error');
          Fnd_Message.Set_Token('ERROR', substr(SQLERRM, 1, 80), FALSE);
          Fnd_Message.Set_Token('ROUTINE','DPP_ITEMCOST_PVT.wait_for_rec_processing', FALSE);
          FND_MSG_PUB.add;
          return FALSE;
  end wait_for_rec_processing;

PROCEDURE Update_ItemCost
     (p_api_Version       IN NUMBER,
      p_Init_msg_List     IN VARCHAR2 := fnd_api.g_False,
      p_Commit            IN VARCHAR2 := fnd_api.g_False,
      p_Validation_Level  IN NUMBER := fnd_api.g_Valid_Level_Full,
      x_Return_Status     OUT NOCOPY VARCHAR2,
      x_msg_Count         OUT NOCOPY NUMBER,
      x_msg_Data          OUT NOCOPY VARCHAR2,
      p_txn_hdr_rec       IN DPP_CST_HDR_REC_TYPE,
      p_Item_Cost_Tbl     IN DPP_TXN_LINE_TBL_TYPE)
IS
l_api_name                      CONSTANT VARCHAR2(30) := 'Update_ItemCost';
l_api_version                   CONSTANT NUMBER := 1.0;
l_full_name                     CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;

l_return_status                 VARCHAR2(30);
l_msg_count                     NUMBER;
l_msg_data                      VARCHAR2(4000);

l_cost_type_id                  NUMBER := 8; -- seeded cost type for Price Protection
l_transaction_type_id           NUMBER := 80; -- seeded type for average cost update
l_transaction_action_id         NUMBER := 24; -- seeded for cost update
l_dpp_application_id            NUMBER := 9000; -- seeded for dpp

l_cost_type                     VARCHAR2(30);
l_src_hdr_id                          NUMBER;
l_cost_import_req_id            NUMBER;
l_cost_upd_req_id                  NUMBER;
l_wait_req                         BOOLEAN;
l_phase                            VARCHAR2(30);
l_status                           VARCHAR2(30);
l_dev_phase                        VARCHAR2(30);
l_dev_status                       VARCHAR2(30);
l_message                          VARCHAR2(30);
l_to_amount                     NUMBER := 0;
l_exchange_rate                 NUMBER;
l_interface_pending_count       NUMBER := 0;
l_txn_subtype                         VARCHAR2(240);
l_wait_status                         BOOLEAN;
l_import_cost_group_id          NUMBER;
l_prior_cost                          NUMBER;
l_processed_flag                      VARCHAR2(1) := 'N';
l_transaction_line_id           NUMBER;
l_transaction_subtype           VARCHAR2(20);
l_bom_installed                       NUMBER;
l_incorrect_price_exists        NUMBER := 0;
l_responsibility_id                NUMBER;
l_execution_status                 VARCHAR2(20);
l_transaction_number            VARCHAR2(50);
l_sysdate                                DATE := sysdate;
l_trunc_sysdate                    DATE := trunc(sysdate);
l_output_xml                          CLOB;
l_queryCtx                      dbms_xmlquery.ctxType;

--- Begin Added for A/c Generator W/f ---
l_itemtype                      VARCHAR2(30) := 'OZFACCTG';
l_itemkey                       VARCHAR2(38);
x_return_ccid                   NUMBER;
x_concat_segs                   VARCHAR2(500);
x_concat_ids                    VARCHAR2(500);
x_concat_descrs                 VARCHAR2(500);
l_bg_process_mode               VARCHAR2(1);
l_cost_adj_ccid               NUMBER;
l_chart_of_accounts_id          NUMBER;
l_role_name                     VARCHAR2(240) := null;
l_debug_flag                    VARCHAR2(30);
l_result                        BOOLEAN;
l_errmsg                        VARCHAR2(2000);
l_new_comb                      BOOLEAN := TRUE;
l_user_name                VARCHAR2(100);
l_correct_item             VARCHAR2(1)  := 'Y';
l_insert_xla_header        VARCHAR2(1)  := 'N';
--- End Added for A/c Generator W/f ---

l_txn_hdr_rec           DPP_ITEMCOST_PVT.dpp_cst_hdr_rec_type   := p_txn_hdr_rec;
l_item_cost_tbl         DPP_ITEMCOST_PVT.dpp_txn_line_tbl_type := p_item_cost_tbl;
l_inv_org_details_tbl   DPP_ITEMCOST_PVT.inv_org_details_tbl_type;

l_exe_update_rec                   DPP_ExecutionDetails_PVT.dpp_exe_update_rec_type;
l_status_Update_tbl             DPP_ExecutionDetails_PVT.dpp_status_Update_tbl_type;
l_module 				CONSTANT VARCHAR2(100) := 'dpp.plsql.DPP_ITEMCOST_PVT.UPDATE_ITEMCOST';

TYPE  inventory_item_id_tbl IS TABLE OF mtl_system_items_b.inventory_item_id%TYPE
      INDEX BY PLS_INTEGER;
TYPE  error_explanation_tbl IS TABLE OF mtl_transactions_interface.error_explanation%TYPE
      INDEX BY PLS_INTEGER;
TYPE  source_line_id_tbl IS TABLE OF mtl_transactions_interface.source_line_id%TYPE
      INDEX BY PLS_INTEGER;
TYPE  transaction_id_tbl IS TABLE OF mtl_material_transactions.transaction_id%TYPE
      INDEX BY PLS_INTEGER;
TYPE  transaction_line_id_tbl IS TABLE OF dpp_transaction_lines_all.transaction_line_id%TYPE
      INDEX BY PLS_INTEGER;
TYPE  transaction_subtype_tbl IS TABLE OF dpp_xla_lines.transaction_sub_type%TYPE
      INDEX BY PLS_INTEGER;

inventory_item_ids      inventory_item_id_tbl;
error_explanations      error_explanation_tbl;
source_line_ids         source_line_id_tbl;
transaction_ids         transaction_id_tbl;
transaction_line_ids    transaction_line_id_tbl;
transaction_subtypes    transaction_subtype_tbl;

CURSOR Item_cur(p_inventory_item_id IN NUMBER,p_org_id IN NUMBER, p_trunc_sysdate IN DATE)
IS
    SELECT mp.organization_id,msi.primary_uom_code transaction_uom,
           msi.concatenated_segments item_number, mp.primary_cost_method, cod.organization_name,
           mp.default_cost_group_id cost_group_id,
           cod.currency_code
    FROM mtl_parameters mp,
         mtl_system_items_kfv msi,
         cst_organization_definitions cod
    WHERE mp.organization_id = msi.organization_id
       AND mp.primary_cost_method IN (1,2)
       AND msi.inventory_item_id = p_inventory_item_id
       AND msi.inventory_asset_flag = 'Y'
       AND cod.organization_id = mp.organization_id
       AND cod.operating_unit = p_org_id
--     AND NVL(mp.consigned_flag,'N') = 'N'
       AND mp.process_enabled_flag = 'N'
       AND NVL(cod.disable_date,p_trunc_sysdate + 1) > p_trunc_sysdate;

CURSOR Organization_cur(p_cost_type_id IN NUMBER,p_request_id IN NUMBER)
IS
 SELECT DISTINCT organization_id from cst_item_costs
  WHERE cost_type_id = p_cost_type_id
   AND request_id = p_request_id;

BEGIN
------------------------------------------
-- Initialization
------------------------------------------

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      g_pkg_name)  THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )  THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message

   dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Private API: ' || l_api_name || 'start at: '||to_char(sysdate,'dd-mon-yyyy hh24:mi:ss'));

   -- Initialize API return status to sucess
   l_return_status := FND_API.G_RET_STS_SUCCESS;

--
-- API body
--
   -- check for mandatory input parameters --
   IF l_txn_hdr_rec.org_id IS NULL THEN
      FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
      FND_MESSAGE.set_token('ID', 'Org ID');
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_txn_hdr_rec.last_updated_by IS NULL THEN
      FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
      FND_MESSAGE.set_token('ID', 'User ID - Last_Updated_By');
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_txn_hdr_rec.cost_adjustment_account IS NULL THEN
      FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
      FND_MESSAGE.set_token('ID', 'Cost Adjustment Account');
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_txn_hdr_rec.transaction_header_id IS NULL THEN
      FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
      FND_MESSAGE.set_token('ID', 'Transaction Header ID');
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_txn_hdr_rec.execution_detail_id IS NULL THEN
      FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
      FND_MESSAGE.set_token('ID', 'Execution Detail ID');
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
   ELSIF l_txn_hdr_rec.transaction_number IS NULL THEN
      FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
      FND_MESSAGE.set_token('ID', 'Transaction Number');
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'After mandatory checks:'||to_char(sysdate,'dd-mon-yyyy hh24:mi:ss'));

    l_bg_process_mode := nvl(fnd_profile.value('DPP_ACCT_GEN_USE_WORKFLOW'),'N');

    --Get the user name for the last updated by user
    BEGIN
       SELECT user_name
        INTO l_user_name
       FROM fnd_user
       WHERE user_id = l_txn_hdr_rec.last_updated_by;
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
           dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Invalid User');
           RAISE FND_API.G_EXC_ERROR;
       WHEN OTHERS THEN
          fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
          fnd_message.set_token('ROUTINE', 'DPP_ITEMCOST_PVT');
          fnd_message.set_token('ERRNO', sqlcode);
          fnd_message.set_token('REASON', sqlerrm);
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

    --Getting a valid Price Protection Responsibility at the User Level Profile Options
    BEGIN
        SELECT frv.responsibility_id
          INTO l_responsibility_id
          FROM fnd_profile_options fpo,
               fnd_profile_option_values fpov,
               fnd_responsibility_vl frv,
               fnd_user_resp_groups_direct furgd
         WHERE fpo.profile_option_name IN ('ORG_ID', 'DEFAULT_ORG_ID')
           AND fpo.profile_option_id = fpov.profile_option_id
           AND fpov.profile_option_value = TO_CHAR (l_txn_hdr_rec.org_id)
           AND fpov.level_id = 10004
           AND furgd.user_id = fpov.level_value
           AND frv.application_id = 9000
           AND TRUNC (SYSDATE) BETWEEN NVL (frv.start_date, TRUNC (SYSDATE))
           AND NVL (frv.end_date, TRUNC (SYSDATE))
           AND TRUNC (SYSDATE) BETWEEN NVL (furgd.start_date, TRUNC (SYSDATE))
           AND NVL (furgd.end_date, TRUNC (SYSDATE))
           AND furgd.responsibility_id = frv.responsibility_id
           AND furgd.responsibility_application_id = frv.application_id
           AND furgd.user_id = l_txn_hdr_rec.last_updated_by
           AND ROWNUM = 1;
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
          l_responsibility_id := -1;
          BEGIN
             SELECT frv.responsibility_id
               INTO l_responsibility_id
               FROM fnd_profile_options fpo,
                    fnd_profile_option_values fpov,
                    fnd_responsibility_vl frv,
                    fnd_user_resp_groups_direct furgd,
                    per_security_profiles psp
              WHERE fpo.profile_option_name = 'XLA_MO_SECURITY_PROFILE_LEVEL'
                AND fpo.profile_option_id = fpov.profile_option_id
                AND fpov.profile_option_value = TO_CHAR (psp.security_profile_id)
                AND ((psp.view_all_organizations_flag = 'Y'
                      AND psp.business_group_id IS NOT NULL
                      AND EXISTS (SELECT 1
                                    FROM hr_operating_units hr
                                   WHERE hr.business_group_id = psp.business_group_id
                                     AND hr.usable_flag IS NULL
                                     AND hr.organization_id =
                                     l_txn_hdr_rec.org_id))
                    OR (psp.view_all_organizations_flag = 'Y'
                        AND psp.business_group_id IS NULL)
                    OR (NVL (psp.view_all_organizations_flag, 'N') <> 'Y'
                        AND EXISTS (SELECT 1
                                      FROM per_organization_list per,
                                           hr_operating_units hr
                                     WHERE per.security_profile_id = psp.security_profile_id
                                       AND hr.organization_id = per.organization_id
                                       AND hr.usable_flag IS NULL
                                       AND per.organization_id = l_txn_hdr_rec.org_id)))
                AND fpov.level_id = 10004
                AND furgd.user_id = fpov.level_value
                AND frv.application_id = 9000
                AND TRUNC (SYSDATE) BETWEEN NVL (frv.start_date, TRUNC (SYSDATE))
                AND NVL (frv.end_date, TRUNC (SYSDATE))
                AND TRUNC (SYSDATE) BETWEEN NVL (furgd.start_date,TRUNC (SYSDATE))
                AND NVL (furgd.end_date, TRUNC (SYSDATE))
                AND furgd.responsibility_id = frv.responsibility_id
                AND furgd.responsibility_application_id = frv.application_id
                AND furgd.user_id = l_txn_hdr_rec.last_updated_by
                AND ROWNUM = 1;
          EXCEPTION
             WHEN NO_DATA_FOUND THEN
                 l_responsibility_id := -1;
             WHEN OTHERS THEN
                 fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
                 fnd_message.set_token('ROUTINE', 'DPP_ITEMCOST_PVT');
                 fnd_message.set_token('ERRNO', sqlcode);
                 fnd_message.set_token('REASON', sqlerrm);
                 FND_MSG_PUB.add;
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END;
       WHEN OTHERS THEN
          fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
          fnd_message.set_token('ROUTINE', 'DPP_ITEMCOST_PVT');
          fnd_message.set_token('ERRNO', sqlcode);
          fnd_message.set_token('REASON', sqlerrm);
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

    --Getting a valid Price Protection Responsibility at the Responsibility Level Profile Options
    IF l_responsibility_id = -1 THEN
       BEGIN
          SELECT frv.responsibility_id
            INTO l_responsibility_id
            FROM fnd_profile_options fpo,
                 fnd_profile_option_values fpov,
                 fnd_responsibility_vl frv,
                 fnd_user_resp_groups_direct furgd
           WHERE fpo.profile_option_name IN ('ORG_ID', 'DEFAULT_ORG_ID')
             AND fpo.profile_option_id = fpov.profile_option_id
             AND fpov.profile_option_value = TO_CHAR (l_txn_hdr_rec.org_id)
             AND fpov.level_id = 10003
             AND frv.responsibility_id = fpov.level_value
             AND frv.application_id = 9000
             AND TRUNC (SYSDATE) BETWEEN NVL (frv.start_date, TRUNC (SYSDATE))
                 AND NVL (frv.end_date, TRUNC (SYSDATE))
             AND TRUNC (SYSDATE) BETWEEN NVL (furgd.start_date, TRUNC (SYSDATE))
                 AND NVL (furgd.end_date, TRUNC (SYSDATE))
             AND furgd.responsibility_id = frv.responsibility_id
             AND furgd.responsibility_application_id = frv.application_id
             AND furgd.user_id = l_txn_hdr_rec.last_updated_by
             AND ROWNUM = 1;
       EXCEPTION
          WHEN NO_DATA_FOUND THEN
              l_responsibility_id := -1;
              BEGIN
                SELECT frv.responsibility_id
                  INTO l_responsibility_id
                  FROM fnd_profile_options fpo,
                       fnd_profile_option_values fpov,
                       fnd_responsibility_vl frv,
                       fnd_user_resp_groups_direct furgd,
                       per_security_profiles psp
                 WHERE fpo.profile_option_name = 'XLA_MO_SECURITY_PROFILE_LEVEL'
                   AND fpo.profile_option_id = fpov.profile_option_id
                   AND fpov.profile_option_value = TO_CHAR (psp.security_profile_id)
                   AND ((psp.view_all_organizations_flag = 'Y'
                         AND psp.business_group_id IS NOT NULL
                         AND EXISTS (SELECT 1
                                       FROM hr_operating_units hr
                                      WHERE hr.business_group_id = psp.business_group_id
                                        AND hr.usable_flag IS NULL
                                        AND hr.organization_id = l_txn_hdr_rec.org_id))
                        OR (psp.view_all_organizations_flag = 'Y'
                            AND psp.business_group_id IS NULL)
                        OR (NVL (psp.view_all_organizations_flag, 'N') <> 'Y'
                            AND EXISTS (SELECT 1
                                          FROM per_organization_list per,
                                               hr_operating_units hr
                                         WHERE per.security_profile_id = psp.security_profile_id
                                           AND hr.organization_id = per.organization_id
                                           AND hr.usable_flag IS NULL
                                           AND per.organization_id = l_txn_hdr_rec.org_id)))
                   AND fpov.level_id = 10003
                   AND frv.responsibility_id = fpov.level_value
                   AND frv.application_id = 9000
                   AND TRUNC (SYSDATE) BETWEEN NVL (frv.start_date, TRUNC (SYSDATE))
                       AND NVL (frv.end_date, TRUNC (SYSDATE))
                   AND TRUNC (SYSDATE) BETWEEN NVL (furgd.start_date,TRUNC (SYSDATE))
                       AND NVL (furgd.end_date, TRUNC (SYSDATE))
                   AND furgd.responsibility_id = frv.responsibility_id
                   AND furgd.responsibility_application_id = frv.application_id
                   AND furgd.user_id = l_txn_hdr_rec.last_updated_by
                   AND ROWNUM = 1;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                   l_responsibility_id := -1;
                WHEN OTHERS THEN
                   fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
                   fnd_message.set_token('ROUTINE', 'DPP_ITEMCOST_PVT');
                   fnd_message.set_token('ERRNO', sqlcode);
                   fnd_message.set_token('REASON', sqlerrm);
                   FND_MSG_PUB.add;
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END;
          WHEN OTHERS THEN
             fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
             fnd_message.set_token('ROUTINE', 'DPP_ITEMCOST_PVT');
             fnd_message.set_token('ERRNO', sqlcode);
             fnd_message.set_token('REASON', sqlerrm);
             FND_MSG_PUB.add;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END;
    END IF;

    --Getting a valid Price Protection Responsibility at the Application Level Profile Options
    IF l_responsibility_id = -1 THEN
       BEGIN
          SELECT frv.responsibility_id
            INTO l_responsibility_id
            FROM fnd_profile_options fpo,
                 fnd_profile_option_values fpov,
                 fnd_responsibility_vl frv,
                 fnd_user_resp_groups_direct furgd
           WHERE fpo.profile_option_name IN ('ORG_ID', 'DEFAULT_ORG_ID')
             AND fpo.profile_option_id = fpov.profile_option_id
             AND fpov.profile_option_value = TO_CHAR (l_txn_hdr_rec.org_id)
             AND fpov.level_id = 10002
             AND frv.application_id = fpov.level_value
             AND frv.application_id = 9000
             AND TRUNC (SYSDATE) BETWEEN NVL (frv.start_date, TRUNC (SYSDATE))
                 AND NVL (frv.end_date, TRUNC (SYSDATE))
             AND TRUNC (SYSDATE) BETWEEN NVL (furgd.start_date, TRUNC (SYSDATE))
                 AND NVL (furgd.end_date, TRUNC (SYSDATE))
             AND furgd.responsibility_id = frv.responsibility_id
             AND furgd.responsibility_application_id = frv.application_id
             AND furgd.user_id = l_txn_hdr_rec.last_updated_by
             AND ROWNUM = 1;
       EXCEPTION
          WHEN NO_DATA_FOUND THEN
             l_responsibility_id := -1;
             BEGIN
                SELECT frv.responsibility_id
                  INTO l_responsibility_id
                  FROM fnd_profile_options fpo,
                       fnd_profile_option_values fpov,
                       fnd_responsibility_vl frv,
                       fnd_user_resp_groups_direct furgd,
                       per_security_profiles psp
                 WHERE fpo.profile_option_name = 'XLA_MO_SECURITY_PROFILE_LEVEL'
                   AND fpo.profile_option_id = fpov.profile_option_id
                   AND fpov.profile_option_value = TO_CHAR (psp.security_profile_id)
                   AND ((psp.view_all_organizations_flag = 'Y'
                         AND psp.business_group_id IS NOT NULL
                         AND EXISTS (SELECT 1
                                       FROM hr_operating_units hr
                                       WHERE hr.business_group_id = psp.business_group_id
                                         AND hr.usable_flag IS NULL
                                         AND hr.organization_id = l_txn_hdr_rec.org_id))
                      OR (psp.view_all_organizations_flag = 'Y'
                          AND psp.business_group_id IS NULL)
                      OR (NVL (psp.view_all_organizations_flag, 'N') <> 'Y'
                          AND EXISTS (SELECT 1
                                        FROM per_organization_list per,
                                             hr_operating_units hr
                                       WHERE per.security_profile_id = psp.security_profile_id
                                         AND hr.organization_id = per.organization_id
                                         AND hr.usable_flag IS NULL
                                         AND per.organization_id = l_txn_hdr_rec.org_id)))
                   AND fpov.level_id = 10002
                   AND frv.application_id = fpov.level_value
                   AND frv.application_id = 9000
                   AND TRUNC (SYSDATE) BETWEEN NVL (frv.start_date, TRUNC (SYSDATE))
                       AND NVL (frv.end_date, TRUNC (SYSDATE))
                   AND TRUNC (SYSDATE) BETWEEN NVL (furgd.start_date,TRUNC (SYSDATE))
                       AND NVL (furgd.end_date, TRUNC (SYSDATE))
                   AND furgd.responsibility_id = frv.responsibility_id
                   AND furgd.responsibility_application_id = frv.application_id
                   AND furgd.user_id = l_txn_hdr_rec.last_updated_by
                   AND ROWNUM = 1;
             EXCEPTION
                WHEN NO_DATA_FOUND THEN
                   l_responsibility_id := -1;
                WHEN OTHERS THEN
                   fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
                   fnd_message.set_token('ROUTINE', 'DPP_ITEMCOST_PVT');
                   fnd_message.set_token('ERRNO', sqlcode);
                   fnd_message.set_token('REASON', sqlerrm);
                   FND_MSG_PUB.add;
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END;
          WHEN OTHERS THEN
             fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
             fnd_message.set_token('ROUTINE', 'DPP_ITEMCOST_PVT');
             fnd_message.set_token('ERRNO', sqlcode);
             fnd_message.set_token('REASON', sqlerrm);
             FND_MSG_PUB.add;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END;
    END IF;

    --Getting a valid Price Protection Responsibility at the Site Level Profile Options
    IF l_responsibility_id = -1 THEN
       BEGIN
          SELECT frv.responsibility_id
            INTO l_responsibility_id
            FROM fnd_profile_options fpo,
                 fnd_profile_option_values fpov,
                 fnd_responsibility_vl frv,
                 fnd_user_resp_groups_direct furgd
           WHERE fpo.profile_option_name IN ('ORG_ID', 'DEFAULT_ORG_ID')
             AND fpo.profile_option_id = fpov.profile_option_id
             AND fpov.profile_option_value = TO_CHAR (l_txn_hdr_rec.org_id)
             AND fpov.level_id = 10001
             AND fpov.level_value = 0
             AND frv.application_id = 9000
             AND TRUNC (SYSDATE) BETWEEN NVL (frv.start_date, TRUNC (SYSDATE))
                 AND NVL (frv.end_date, TRUNC (SYSDATE))
             AND TRUNC (SYSDATE) BETWEEN NVL (furgd.start_date, TRUNC (SYSDATE))
                 AND NVL (furgd.end_date, TRUNC (SYSDATE))
             AND furgd.responsibility_id = frv.responsibility_id
             AND furgd.responsibility_application_id = frv.application_id
             AND furgd.user_id = l_txn_hdr_rec.last_updated_by
             AND ROWNUM = 1;
       EXCEPTION
             WHEN NO_DATA_FOUND THEN
                 l_responsibility_id := -1;
                 BEGIN

                    SELECT frv.responsibility_id
                      INTO l_responsibility_id
                      FROM fnd_profile_options fpo,
                           fnd_profile_option_values fpov,
                           fnd_responsibility_vl frv,
                           fnd_user_resp_groups_direct furgd,
                           per_security_profiles psp
                     WHERE fpo.profile_option_name = 'XLA_MO_SECURITY_PROFILE_LEVEL'
                       AND fpo.profile_option_id = fpov.profile_option_id
                       AND fpov.profile_option_value = TO_CHAR (psp.security_profile_id)
                       AND ((psp.view_all_organizations_flag = 'Y'
                             AND psp.business_group_id IS NOT NULL
                             AND EXISTS (SELECT 1
                                           FROM hr_operating_units hr
                                          WHERE hr.business_group_id = psp.business_group_id
                                            AND hr.usable_flag IS NULL
                                            AND hr.organization_id = l_txn_hdr_rec.org_id))
                            OR (psp.view_all_organizations_flag = 'Y'
                                AND psp.business_group_id IS NULL)
                            OR (NVL (psp.view_all_organizations_flag, 'N') <> 'Y'
                                AND EXISTS (SELECT 1
                                              FROM per_organization_list per,
                                                   hr_operating_units hr
                                             WHERE per.security_profile_id = psp.security_profile_id
                                               AND hr.organization_id = per.organization_id
                                               AND hr.usable_flag IS NULL
                                               AND per.organization_id = l_txn_hdr_rec.org_id)))
                       AND fpov.level_id = 10001
                       AND fpov.level_value = 0
                       AND frv.application_id = 9000
                       AND TRUNC (SYSDATE) BETWEEN NVL (frv.start_date, TRUNC (SYSDATE))
                           AND NVL (frv.end_date, TRUNC (SYSDATE))
                       AND TRUNC (SYSDATE) BETWEEN NVL (furgd.start_date,TRUNC (SYSDATE))
                           AND NVL (furgd.end_date, TRUNC (SYSDATE))
                       AND furgd.responsibility_id = frv.responsibility_id
                       AND furgd.responsibility_application_id = frv.application_id
                       AND furgd.user_id = l_txn_hdr_rec.last_updated_by
                       AND ROWNUM = 1;
                 EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                       l_responsibility_id := -1;
                    WHEN OTHERS THEN
                       fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
                       fnd_message.set_token('ROUTINE', 'DPP_ITEMCOST_PVT');
                       fnd_message.set_token('ERRNO', sqlcode);
                       fnd_message.set_token('REASON', sqlerrm);
                       FND_MSG_PUB.add;
                       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 END;
           WHEN OTHERS THEN
             fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
             fnd_message.set_token('ROUTINE', 'DPP_ITEMCOST_PVT');
             fnd_message.set_token('ERRNO', sqlcode);
             fnd_message.set_token('REASON', sqlerrm);
             FND_MSG_PUB.add;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END;
    END IF;

    --Check if the responsibility id is -1
    IF l_responsibility_id = -1 THEN
       FND_MESSAGE.set_name('DPP', 'DPP_INVALID_RESP');
       FND_MESSAGE.set_token('USER', l_user_name);
       FND_MSG_PUB.add;

       dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Price Protection responsibility not available for Last updated user'||l_user_name);

       RAISE FND_API.G_EXC_ERROR;
    END IF;

    FND_GLOBAL.APPS_INITIALIZE(l_txn_hdr_rec.last_updated_by,l_responsibility_id,l_dpp_application_id);
    MO_GLOBAL.set_policy_context('S',l_txn_hdr_rec.org_id);

    BEGIN
      SELECT cost_type
       INTO l_cost_type
       FROM cst_cost_types
       WHERE cost_type_id = 8;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
         dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'The cost type DPPCost is not setup.');
         RAISE FND_API.G_EXC_ERROR;
    END;

    SELECT dpp_cst_group_id_seq.nextval
    INTO l_import_cost_group_id
    FROM dual;

    SELECT count(*)
    INTO l_bom_installed
    FROM bom_parameters
    WHERE organization_id = l_txn_hdr_rec.org_id;

    -- Begin A/c Generator Code ---

    IF l_bg_process_mode = 'Y' THEN
       --Changed from ozf_sys_parameters_all to hr_operating_units
       SELECT chart_of_accounts_id
        INTO l_chart_of_accounts_id
        FROM gl_sets_of_books sob,
             hr_operating_units hr
       WHERE hr.set_of_books_id = sob.set_of_books_id
         AND hr.organization_id = l_txn_hdr_rec.org_id;

       l_debug_flag := fnd_profile.value('ACCOUNT_GENERATOR:DEBUG_MODE');

       dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Debug Flag: ' || l_debug_flag );

    END IF;

   -- Standard begin of API savepoint
   SAVEPOINT  Update_ItemCost_PVT;

   IF l_item_cost_tbl.COUNT > 0 THEN

      dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Before For Loop:'||to_char(sysdate,'dd-mon-yyyy hh24:mi:ss'));

      FOR i IN l_item_cost_tbl.FIRST..l_item_cost_tbl.LAST  LOOP
          l_status_Update_tbl(i).transaction_line_id := l_item_cost_tbl(i).transaction_line_id;
          l_status_Update_tbl(i).update_status := 'Y';

          FOR Item_rec IN Item_cur(l_item_cost_tbl(i).inventory_item_id,l_txn_hdr_rec.org_id, l_trunc_sysdate)  LOOP
             l_item_cost_tbl(i).item_number             := item_rec.item_number;
             l_inv_org_details_tbl(i).inventory_org_name := Item_rec.organization_name;

             IF l_item_cost_tbl(i).currency = Item_rec.currency_code THEN
                l_to_amount := l_item_cost_tbl(i).new_price;
             ELSE
                l_to_amount := 0;
                DPP_UTILITY_PVT.convert_currency(p_from_currency   => l_item_cost_tbl(i).currency
                                                 ,p_to_currency     => Item_rec.currency_code
                                                 ,p_conv_type       => FND_API.G_MISS_CHAR
                                                 ,p_conv_rate       => FND_API.G_MISS_NUM
                                                 ,p_conv_date       => l_trunc_sysdate
                                                 ,p_from_amount     => l_item_cost_tbl(i).new_price
                                                 ,x_return_status   => l_return_status
                                                 ,x_to_amount       => l_to_amount
                                                 ,x_rate            => l_exchange_rate);
             END IF;

             IF Item_rec.primary_cost_method = 1 THEN
                BEGIN
                  SELECT NVL(ctc.item_cost,0) prior_cost
                    INTO l_prior_cost
                    FROM cst_item_costs ctc
                  WHERE ctc.organization_id = Item_rec.organization_id
                    AND ctc.inventory_item_id = l_item_cost_tbl(i).inventory_item_id
                    AND ctc.cost_type_id = 1;
                EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                      l_prior_cost := 0;
                            END;
             ELSE
                BEGIN
                  SELECT NVL(item_cost,0)
                    INTO l_prior_cost
                    FROM cst_quantity_layers
                  WHERE organization_id = Item_rec.organization_id
                    AND inventory_item_id       = l_item_cost_tbl(i).inventory_item_id
                    AND cost_group_id = item_rec.cost_group_id;
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     l_prior_cost := 0;
                END;
                  END IF;

             --Insert the available details into the GT table.
             IF l_prior_cost = 0 THEN
                l_txn_subtype := null;
             ELSIF l_to_amount < l_prior_cost THEN
                l_txn_subtype := 'PRICE_DECREASE';
             ELSE
                l_txn_subtype := 'PRICE_INCREASE';
             END IF;

             INSERT INTO DPP_OUTPUT_XML_GT(Item_Number,
                                              NewPrice,
                                              Currency,
                                              Inventory_Org_Name,
                                              inventory_item_id,
                                              transaction_subtype,
                                              transaction_line_id,
                                              organization_id)
                                      VALUES (l_item_cost_tbl(i).item_number,
                                              l_item_cost_tbl(i).new_price,
                                              l_item_cost_tbl(i).currency,
                                              Item_rec.organization_name,
                                              l_item_cost_tbl(i).inventory_item_id,
                                              l_txn_subtype,
                                              l_item_cost_tbl(i).transaction_line_id,
                                              Item_rec.organization_id);

             --If Prior cost is Zero or not defined then raise an Exception
             IF l_prior_cost  = 0 THEN
                --ADD Messages
                l_item_cost_tbl(i).Reason_for_failure := 'Costing setup is not done or the cost is Zero for the item:'||l_item_cost_tbl(i).item_number ;
                dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Costing setup is not done or the cost is Zero for the item:'||l_item_cost_tbl(i).item_number);
                l_return_status := FND_API.G_RET_STS_ERROR;

                UPDATE DPP_OUTPUT_XML_GT
                SET reason_for_failure  = l_item_cost_tbl(i).Reason_for_failure
                WHERE organization_id           = Item_rec.organization_id
                AND inventory_item_id   = l_item_cost_tbl(i).inventory_item_id;

                l_status_Update_tbl(i).update_status := 'N';
                l_correct_item := 'N';
                --CONTINUE; Fix for the bug 7621428
                GOTO END_LOOP;  --Fix for the bug 7621428
             END IF;

             IF l_to_amount <> l_prior_cost THEN
                --Check if any organization has incorrect price existing for that item
                l_incorrect_price_exists := 0;

                BEGIN
                  SELECT 1
                  INTO l_incorrect_price_exists
                  FROM dual
                  WHERE EXISTS (SELECT cis.organization_id
                                  FROM cst_item_costs cis,
                                       org_organization_definitions ood
                                 WHERE cis.organization_id = ood.organization_id
                                   AND cis.organization_id = Item_rec.organization_id
                                   AND ood.operating_unit = l_txn_hdr_rec.org_id
                                   AND cis.cost_type_id = 1
                                   AND cis.inventory_item_id = l_item_cost_tbl(i).inventory_item_id
                                   AND cis.item_cost > 0
                                   AND (((cis.item_cost-l_to_amount) >0
                                   AND l_item_cost_tbl(i).price_change <0)
                                    OR ((cis.item_cost-l_to_amount) <0 AND  l_item_cost_tbl(i).price_change >0)));
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     l_incorrect_price_exists := 0;
                END;

                IF NVL(l_incorrect_price_exists,0) = 0 THEN
                   BEGIN
                     SELECT 1
                     INTO l_incorrect_price_exists
                     FROM dual
                     WHERE EXISTS (SELECT cql.organization_id
                                      FROM cst_quantity_layers cql,
                                           org_organization_definitions ood
                                     WHERE cql.organization_id = ood.organization_id

                                       AND cql.organization_id = Item_rec.organization_id
                                       AND ood.operating_unit = l_txn_hdr_rec.org_id
                                       AND cql.inventory_item_id = l_item_cost_tbl(i).inventory_item_id
                                       AND cql.cost_group_id = item_rec.cost_group_id
                                       AND cql.item_cost > 0
                                       AND(((cql.item_cost -l_to_amount) > 0
                                       AND l_item_cost_tbl(i).price_change < 0)
                                       OR((item_cost -l_to_amount) < 0  AND l_item_cost_tbl(i).price_change > 0)));

                   EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        l_incorrect_price_exists := 0;
                   END;
                END IF;      --NVL(l_incorrect_price_exists,0) = 0

                IF NVL(l_incorrect_price_exists,0) = 1 THEN
                   l_item_cost_tbl(i).Reason_for_failure := 'This inventory organizations has an incorrect cost for item:'||l_item_cost_tbl(i).item_number;
                   dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'This inventory organizations has an incorrect cost for item:'||l_item_cost_tbl(i).item_number);
                   l_return_status := FND_API.G_RET_STS_ERROR;

                   UPDATE DPP_OUTPUT_XML_GT
                   SET reason_for_failure  = l_item_cost_tbl(i).Reason_for_failure
                   WHERE organization_id                = Item_rec.organization_id
                   AND inventory_item_id        = l_item_cost_tbl(i).inventory_item_id;

                   l_status_Update_tbl(i).update_status := 'N';
                   l_correct_item := 'N';

                   GOTO INCORRECT_PRICE;
                END IF;
             END IF; -- end if for l_to_amount <> l_prior_cost if
             << END_LOOP >>     --Fix for the bug 7621428
				 null;	--Fix for the bug 7621428
          END LOOP;  --ITEM REC Cursor end.

          IF l_correct_item = 'N' THEN
            null;
          ELSE
            l_insert_xla_header := 'Y';
            FOR Item_rec IN Item_cur(l_item_cost_tbl(i).inventory_item_id,l_txn_hdr_rec.org_id, l_trunc_sysdate)  LOOP
              -- Begin A/c Generator Code ---
              IF l_bg_process_mode = 'Y' THEN
                l_itemkey := Fnd_Flex_Workflow.INITIALIZE('SQLGL',
                                                          'GL#',
                                                          l_chart_of_accounts_id,
                                                          'OZFACCTG');

                wf_engine.SetItemAttrNumber(itemtype => l_itemtype,
                                            itemkey  => l_itemkey,
                                            aname    => 'ORG_ID',
                                            avalue   => l_txn_hdr_rec.org_id);

                wf_engine.SetItemAttrNumber(itemtype => l_itemtype,
                                            itemkey  => l_itemkey,
                                            aname    => 'CHART_OF_ACCOUNTS_ID',
                                            avalue   => l_chart_of_accounts_id);

                wf_engine.SetItemAttrNumber(itemtype => l_itemtype,
                                            itemkey  => l_itemkey,
                                            aname    => 'INVENTORY_ITEM_ID',
                                            avalue   => l_item_cost_tbl(i).inventory_item_id);

                wf_engine.SetItemAttrText(itemtype => l_itemtype,
                                          itemkey  => l_itemkey,
                                          aname    => 'ACCOUNT_ID',
                                          avalue   => l_txn_hdr_rec.cost_adjustment_account);

                wf_engine.SetItemAttrNumber(itemtype => l_itemtype,
                                            itemkey  => l_itemkey,
                                            aname    => 'ORGANIZATION_ID',
                                            avalue   =>  Item_rec.organization_id);

                dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'submitting the fnd_flex_workflow_generate process');

                l_result := Fnd_Flex_Workflow.GENERATE('OZFACCTG',
                                                        l_itemkey,
                                                        TRUE,
                                                        x_return_ccid,
                                                        x_concat_segs,
                                                        x_concat_ids,
                                                        x_concat_descrs,
                                                        l_errmsg,
                                                        l_new_comb);

                IF l_result THEN
                  IF Item_rec.primary_cost_method = 1 THEN
                    INSERT INTO cst_Item_cst_dtls_InterFace(Inventory_Item_Id,
                                                              Organization_Id,
                                                              Item_Cost,
                                                              Basis_Type,
                                                              Usage_Rate_Or_Amount,
                                                              Cost_Type_Id,
                                                              Cost_Type,
                                                              Last_Update_Date,
                                                              Last_Updated_By,
                                                              Creation_Date,
                                                              Created_By,
                                                              Group_Id,
                                                              Process_Flag,
                                                              Cost_Element,
                                                              Cost_Element_Id,
                                                              Net_Yield_Or_Shrinkage_Factor,
                                                              Level_Type)
                                                       VALUES(L_item_cost_tbl(i).inventory_item_id,
                                                              Item_rec.Organization_Id,
                                                              NULL,
                                                              1,
                                                              l_To_Amount,
                                                              l_Cost_Type_Id,
                                                              l_Cost_Type,
                                                              l_sysDate,
                                                              l_txn_hdr_rec.Last_Updated_By,
                                                              l_sysDate,
                                                              l_txn_hdr_rec.Last_Updated_By,
                                                              l_Import_Cost_Group_Id,
                                                              1,
                                                              NULL,
                                                              1,
                                                              1,
                                                              1);

                    l_status_Update_tbl(i).update_status        := 'Y';
                  ELSIF Item_rec.primary_cost_method = 2 THEN
                    INSERT INTO mtl_Transactions_InterFace(Transaction_InterFace_Id,
                                                              Transaction_Header_Id,
                                                              Source_Code,
                                                              Source_Line_Id,
                                                              Source_Header_Id,
                                                              Process_Flag,
                                                              Transaction_Mode,
                                                              Last_Update_Date,
                                                              Last_Updated_By,
                                                              Creation_Date,
                                                              Created_By,
                                                              Organization_Id,
                                                              Transaction_Quantity,
                                                              Transaction_uom,
                                                              Transaction_Date,
                                                              Transaction_Type_Id,
                                                              Inventory_Item_Id,
                                                              New_Average_Cost,
                                                              Currency_Code,
                                                              Cost_Group_Id,
                                                              Material_Account,
                                                              Transaction_Reference)
                                              VALUES (dpp_mtl_txn_IfAce_Id_seq.Nextval,
                                                          l_txn_hdr_rec.Transaction_Header_Id,
                                                          'Price Protection',
                                                          l_txn_hdr_rec.Execution_Detail_Id,
                                                          l_txn_hdr_rec.Execution_Detail_Id,
                                                          1,                                     -- Process is 1
                                                          3,                                     -- Background is 3
                                                          l_sysDate,
                                                          l_txn_hdr_rec.Last_Updated_By,
                                                          SYSDATE,
                                                          l_txn_hdr_rec.Last_Updated_By,
                                                          Item_rec.Organization_Id,
                                                          1,
                                                          Item_rec.Transaction_uom,
                                                          l_sysDate,
                                                          l_Transaction_Type_Id,
                                                          L_item_cost_tbl(i).inventory_item_id,
                                                          l_To_Amount,
                                                          L_item_cost_tbl(i).currency,
                                                          Item_rec.Cost_Group_Id,
                                                          Nvl(x_Return_ccId,l_txn_hdr_rec.Cost_Adjustment_Account),
                                                          l_txn_SubType);

                                   INSERT INTO mtl_txn_Cost_det_InterFace(Transaction_InterFace_Id,
                                                               Last_Update_Date,
                                                               Last_Updated_By,
                                                               Creation_Date,
                                                               Created_By,
                                                               Organization_Id,
                                                               Cost_Element_Id,
                                                               Level_Type,
                                                               New_Average_Cost)
                                                   VALUES (dpp_mtl_txn_IfAce_Id_seq.Currval,
                                                               l_sysDate,
                                                               l_txn_hdr_rec.Last_Updated_By,
                                                               l_sysDate,
                                                               l_txn_hdr_rec.Last_Updated_By,
                                                               Item_rec.Organization_Id,
                                                               1,
                                                               1,
                                                               l_To_Amount);

                                   l_status_Update_tbl(i).update_status         := 'Y';

                    dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Success OZFACCTG WF'||'-'||x_return_ccid);

                  END IF; -- end if for primary_cost_method
                ELSE

                  dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'OZFACCTG WF - Failure');

                  l_return_status := FND_API.G_RET_STS_ERROR;
                  l_status_Update_tbl(i).update_status                          := 'N';
                  l_item_cost_tbl(i).Reason_for_failure := 'OZFACCTG Workflow - Failure for item:'||l_item_cost_tbl(i).item_number||' Error Message: '||SUBSTR(l_errmsg,1,254);

                  UPDATE DPP_OUTPUT_XML_GT
                  SET reason_for_failure  = l_item_cost_tbl(i).Reason_for_failure
                  WHERE organization_id                 = Item_rec.organization_id
                  AND inventory_item_id         = l_item_cost_tbl(i).inventory_item_id;

                  GOTO WORKFLOW_ERROR;

                END IF; -- end if for l_result

              ELSE
                -- End A/c Generator Code---
                IF Item_rec.primary_cost_method = 1 THEN
                  INSERT INTO cst_Item_cst_dtls_InterFace(Inventory_Item_Id,
                                                              Organization_Id,
                                                              Item_Cost,
                                                              Basis_Type,
                                                              Usage_Rate_Or_Amount,
                                                              Cost_Type_Id,
                                                              Cost_Type,
                                                              Last_Update_Date,
                                                              Last_Updated_By,
                                                              Creation_Date,
                                                              Created_By,
                                                              Group_Id,
                                                              Process_Flag,
                                                              Cost_Element,
                                                              Cost_Element_Id,
                                                              Net_Yield_Or_Shrinkage_Factor,
                                                              Level_Type)
                                                       VALUES(L_item_cost_tbl(i).inventory_item_id,
                                                              Item_rec.Organization_Id,
                                                              NULL,
                                                              1,
                                                              l_To_Amount,
                                                              l_Cost_Type_Id,
                                                              l_Cost_Type,
                                                              l_sysDate,
                                                              l_txn_hdr_rec.Last_Updated_By,
                                                              l_sysDate,
                                                              l_txn_hdr_rec.Last_Updated_By,
                                                              l_Import_Cost_Group_Id,
                                                              1,
                                                              NULL,
                                                              1,
                                                              1,
                                                              1);

                  l_status_Update_tbl(i).update_status  := 'Y';
                ELSIF Item_rec.primary_cost_method = 2 THEN
                  INSERT INTO mtl_Transactions_InterFace(Transaction_InterFace_Id,
                                                             Transaction_Header_Id,
                                                             Source_Code,
                                                             Source_Line_Id,
                                                             Source_Header_Id,
                                                             Process_Flag,
                                                             Transaction_Mode,
                                                             Last_Update_Date,
                                                             Last_Updated_By,
                                                             Creation_Date,
                                                             Created_By,
                                                             Organization_Id,
                                                             Transaction_Quantity,
                                                             Transaction_uom,
                                                             Transaction_Date,
                                                             Transaction_Type_Id,
                                                             Inventory_Item_Id,
                                                             New_Average_Cost,
                                                             Currency_Code,
                                                             Cost_Group_Id,
                                                             Material_Account,
                                                             Transaction_Reference)
                                                  VALUES     (dpp_mtl_txn_IfAce_Id_seq.Nextval,
                                                             l_txn_hdr_rec.Transaction_Header_Id,
                                                             'Price Protection',
                                                             l_txn_hdr_rec.Execution_Detail_Id,
                                                             l_txn_hdr_rec.Execution_Detail_Id,
                                                             1,                                     -- Process is 1
                                                             3,                                     -- Background is 3
                                                             l_sysDate,
                                                             l_txn_hdr_rec.Last_Updated_By,
                                                             l_sysDate,
                                                             l_txn_hdr_rec.Last_Updated_By,
                                                             Item_rec.Organization_Id,
                                                             1,
                                                             Item_rec.Transaction_uom,
                                                             l_sysDate,
                                                             l_Transaction_Type_Id,
                                                             L_item_cost_tbl(i).inventory_item_id,
                                                             l_To_Amount,
                                                             L_item_cost_tbl(i).currency,
                                                             Item_rec.Cost_Group_Id,
                                                             Nvl(x_Return_ccId,l_txn_hdr_rec.Cost_Adjustment_Account),
                                                             l_txn_SubType);

                  INSERT INTO mtl_txn_Cost_det_InterFace(Transaction_InterFace_Id,
                                                             Last_Update_Date,
                                                             Last_Updated_By,
                                                             Creation_Date,
                                                             Created_By,
                                                             Organization_Id,
                                                             Cost_Element_Id,
                                                             Level_Type,
                                                             New_Average_Cost)
                                                  VALUES     (dpp_mtl_txn_IfAce_Id_seq.Currval,
                                                             l_sysDate,
                                                             l_txn_hdr_rec.Last_Updated_By,
                                                             l_sysDate,
                                                             l_txn_hdr_rec.Last_Updated_By,
                                                             Item_rec.Organization_Id,
                                                             1,
                                                             1,
                                                             l_To_Amount);
                  l_status_Update_tbl(i).update_status          := 'Y';
                END IF;
              END IF;  -- a/c generator end if
            END LOOP;  --ITEM REC Cursor end.
          END IF; --Correct Item
          l_item_cost_tbl(i).inv_org_details_tbl        := l_inv_org_details_tbl;
      END LOOP;
   END IF;

   dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'After For Loop:'||to_char(sysdate,'dd-mon-yyyy hh24:mi:ss'));

   --Calling the "Cost Import Process" Concurrent Program
   BEGIN
     l_cost_import_req_id := FND_REQUEST.submit_request(
                                    application => 'BOM',
                                    program     => 'CSTPCIMP',
                                    description => NULL,
                                    start_time  => NULL,
                                    sub_request => FALSE,
                                    argument1  => 4,                --Import cost option
                                    argument2  => 2 ,               --Mode to run this request
                                    argument3  => 1,                --Group ID option
                                    argument4  => 1,                --Group ID Dummy
                                    argument5  => l_import_cost_group_id,             --Group ID
                                    argument6  => l_cost_type,     --Cost type to import to
                                    argument7  => 1);               --Delete successful rows

          COMMIT;

          dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Cost Import Request ID: '||l_cost_import_req_id);

     l_wait_req := fnd_concurrent.wait_for_request(
               request_id => l_cost_import_req_id,
                           interval    => 60,
                           max_wait    => 0,
                           phase       => l_phase,
                           status      => l_status,
                           dev_phase   => l_dev_phase,
                           dev_status  => l_dev_status,
                           message     => l_message);
   END;

   dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'After Import Request:' || to_char(sysdate,'dd-mon-yyyy hh24:mi:ss'));
   dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'l_phase: ' || l_dev_phase || '; l_status: ' || l_dev_status);

   IF l_dev_status NOT IN ('WARNING','ERROR') THEN

     FOR Organization_Rec IN Organization_Cur(l_cost_type_id,l_cost_import_req_id)
     LOOP
       --Calling the "Update Standard Costs" Concurrent Program
       BEGIN
         l_cost_upd_req_id := FND_REQUEST.submit_request(
                                                                                 application => 'BOM',
                                                                                 program     => 'CMCICU',
                                                                                 description => NULL,
                                                                                 start_time  => NULL,
                                                                                 sub_request => FALSE,
                               argument1  => Organization_Rec.organization_id,
                               argument2  => l_bom_installed ,
                               argument3  => l_cost_type_id,
                               argument4  => 1,
                               argument5  => Nvl(x_Return_ccId,l_txn_hdr_rec.Cost_Adjustment_Account),
                               argument6  => 'DPP Std Cost Update - Execution Detail ID: '||l_txn_hdr_rec.execution_detail_id,
                               argument7  => 1,
                               argument8  => 1,
                               argument9  => 3,
                               argument10 => null,
                               argument11 => null,
                               argument12 => null,
                               argument13 => null,
                               argument14 => null,
                               argument15 => null,
                               argument16 => null,
                               argument17 => null,
                               argument18 => null,
                               argument19 => null,
                               argument20 => null,
                               argument21 => null,
                               argument22 => null,
                               argument23 => 1,
                               argument24 => 2);
                        COMMIT;

                        dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Std Cost Update Request ID: '||l_cost_upd_req_id);

         l_wait_req := fnd_concurrent.wait_for_request(
                     request_id  => l_cost_upd_req_id,
                               interval    => 60,
                               max_wait    => 0,
                               phase       => l_phase,
                               status      => l_status,
                               dev_phase   => l_dev_phase,
                               dev_status  => l_dev_status,
                               message     => l_message);

                        dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'l_phase: '||l_dev_phase|| '; l_status: '||l_dev_status);

       END;

       IF l_dev_status IN ('WARNING','ERROR') THEN
         l_return_status := FND_API.g_ret_sts_error;
                        UPDATE DPP_OUTPUT_XML_GT
                          SET reason_for_failure  = 'Std Cost Update Request ID: '||l_cost_upd_req_id||' '|| l_dev_phase||' with '||l_dev_status
                          WHERE organization_id = Organization_Rec.organization_id;

                          -- Flip the success flag to N for all items to enable resubmission
                          FOR i IN l_status_Update_tbl.FIRST..l_status_Update_tbl.LAST
                          LOOP
                   l_status_Update_tbl(i).update_status                                 := 'N';
           END LOOP;
       END IF;

     END LOOP;

          dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'After Std Cost Update request:'||to_char(sysdate,'dd-mon-yyyy hh24:mi:ss'));

   ELSE
     l_return_status := FND_API.g_ret_sts_error;
          dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Item Cost Import Request ID: '||l_cost_import_req_id||' '|| l_dev_phase||' with '||l_dev_status);

          UPDATE DPP_OUTPUT_XML_GT
                 SET reason_for_failure  = 'Item Cost Import Request ID: '||l_cost_import_req_id||' '|| l_dev_phase||' with '||l_dev_status;

          -- Flip the success flag to N for all items to enable resubmission
          FOR i IN l_status_Update_tbl.FIRST..l_status_Update_tbl.LAST
          LOOP
        l_status_Update_tbl(i).update_status := 'N';
     END LOOP;

   END IF;

        dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Starting Error Processing: ' || l_return_status);

   -- Standard begin of API savepoint
   SAVEPOINT  Update_ItemCost_PVT;

        dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Before Std Cost Error Processing:'||to_char(sysdate,'dd-mon-yyyy hh24:mi:ss'));

   -- Begin Error Processing for Std Cost Update
   SELECT Inventory_Item_Id,
          Error_Explanation
   BULK COLLECT INTO Inventory_Item_Ids,
          Error_Explanations
   FROM   cst_Item_cst_dtls_InterFace
   WHERE  Cost_Type_Id = l_Cost_Type_Id
          AND Group_Id = l_Import_Cost_Group_Id
          AND Process_Flag = 3;

   FORALL indx IN inventory_item_ids.FIRST .. inventory_item_ids.LAST
          UPDATE DPP_OUTPUT_XML_GT
                SET reason_for_failure = error_explanations(indx)
                WHERE inventory_item_id = inventory_item_ids(indx);


   IF inventory_item_ids.COUNT > 0 THEN
           l_return_status := FND_API.g_ret_sts_error;
   END IF;

   dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'After Std Cost Error Processing:'||to_char(sysdate,'dd-mon-yyyy hh24:mi:ss'));

   -- End Error Processing for Std Cost Update

   -- Begin Error Processing for Avg Cost Update
   SELECT COUNT(* )
   INTO   l_InterFace_Pending_Count
   FROM   mtl_Transactions_InterFace
   WHERE  Source_Code = 'Price Protection'
          AND Source_Header_Id = l_txn_hdr_rec.Execution_Detail_Id
          AND Transaction_Header_Id = l_txn_hdr_rec.Transaction_Header_Id
          AND Process_Flag = 1;

        IF l_interface_pending_count > 0 THEN

           l_wait_status := wait_for_rec_processing(in_execution_detail_id   => l_txn_hdr_rec.Execution_detail_ID,
                                                    in_transaction_header_id => l_txn_hdr_rec.Transaction_Header_ID,
                                               interval                 => 60,
                                                         max_wait                 => 0,
                                                         message                  => l_msg_data);

        ELSE
         dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Before Avg Cost Error Processing:'||to_char(sysdate,'dd-mon-yyyy hh24:mi:ss'));

      SELECT Source_Line_Id,
             Nvl(Error_Explanation,Error_Code) Error_Explanation
      BULK COLLECT INTO Source_Line_Ids,
             Error_Explanations
      FROM   mtl_Transactions_InterFace
      WHERE  Source_Code = 'Price Protection'
             AND Source_Header_Id = l_txn_hdr_rec.Execution_Detail_Id
             AND Transaction_Header_Id = l_txn_hdr_rec.Transaction_Header_Id
             AND Process_Flag = 3;

      FORALL indx IN source_line_ids.FIRST .. source_line_ids.LAST
                  UPDATE DPP_OUTPUT_XML_GT
                        SET reason_for_failure  = error_explanations(indx)
                        WHERE transaction_line_id   = source_line_ids(indx);

         IF source_line_ids.COUNT > 0 THEN
                           l_return_status := fnd_api.g_ret_sts_error;
                        END IF;

        END IF;
-- End Error Processing for Avg Cost Update

      dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'After Avg Cost Error Processing:'||to_char(sysdate,'dd-mon-yyyy hh24:mi:ss'));
      dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Inserting into SLA tables: ' || l_return_status);

   l_sysdate := sysdate;


   IF l_insert_xla_header = 'Y' THEN
     BEGIN
                 INSERT INTO DPP_XLA_HEADERS(
                        transaction_header_id
                        ,pp_transaction_type
                        ,base_transaction_header_id
                        ,processed_flag
                        ,creation_date
                        ,created_by
                        ,last_update_date
                        ,last_updated_by
                        ,last_update_login)
                 VALUES(
                        l_txn_hdr_rec.Transaction_Header_ID
                        ,'COST_UPDATE'
                        ,l_txn_hdr_rec.Execution_Detail_ID
                        ,l_processed_flag
                        ,l_sysdate
                        ,l_txn_hdr_rec.last_updated_by
                        ,l_sysdate
                        ,l_txn_hdr_rec.last_updated_by
                        ,FND_GLOBAL.login_id);

          dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'After SLA Hdr Insert:'||to_char(sysdate,'dd-mon-yyyy hh24:mi:ss'));
          dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Inserting into SLA Lines table for Avg Cost Update ');

            -- Begin SLA Line Processing for Avg Cost Update
       BEGIN
         SELECT
           mmt.transaction_id,
           dpp_gt.transaction_line_id,
           dpp_gt.transaction_subtype
         BULK COLLECT INTO
           transaction_ids,
           transaction_line_ids,
           transaction_subtypes
         FROM
           mtl_material_transactions mmt,
           DPP_OUTPUT_XML_GT dpp_gt
         WHERE
           mmt.transaction_source_type_id = 13 -- Inventory
           AND mmt.source_line_id = l_txn_hdr_rec.Execution_Detail_ID
           AND mmt.transaction_type_id = l_transaction_type_id
           AND mmt.transaction_action_id = l_transaction_action_id
           AND dpp_gt.organization_id = mmt.organization_id
           AND dpp_gt.inventory_item_id = mmt.inventory_item_id;

         FORALL indx IN transaction_ids.FIRST .. transaction_ids.LAST
            INSERT INTO DPP_XLA_LINES(
                  transaction_header_id
                  ,transaction_line_id
                  ,base_transaction_header_id
                  ,base_transaction_line_id
                  ,transaction_sub_type
                  ,creation_date
                  ,created_by
                  ,last_update_date
                  ,last_updated_by)
            VALUES(
                  l_txn_hdr_rec.Transaction_Header_ID
                  ,transaction_line_ids(indx)
                  ,l_txn_hdr_rec.Execution_Detail_ID
                  ,transaction_ids(indx)
                  ,transaction_subtypes(indx)
                  ,l_sysdate
                  ,l_txn_hdr_rec.last_updated_by
                  ,l_sysdate
                  ,l_txn_hdr_rec.last_updated_by);
       EXCEPTION
         WHEN NO_DATA_FOUND THEN
                dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'No Data Found for SLA lines table insertion - Avg Costing...');
       END;
            -- End SLA Line Processing for Avg Cost Update

			dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Inserting into SLA Lines table for Std Cost Update: ');
			dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Before SLA Line Insert - Std:'||to_char(sysdate,'dd-mon-yyyy hh24:mi:ss'));

            -- Begin SLA Line Processing for Std Cost Update
       BEGIN
         SELECT
           mmt.transaction_id,
           dpp_gt.transaction_line_id,
           dpp_gt.transaction_subtype
         BULK COLLECT INTO
           transaction_ids,
           transaction_line_ids,
           transaction_subtypes
         FROM
           mtl_material_transactions mmt,
           cst_cost_updates ccu,
           DPP_OUTPUT_XML_GT dpp_gt
         WHERE
           mmt.transaction_source_id = ccu.cost_update_id
           AND mmt.transaction_source_type_id = 11
           AND mmt.transaction_action_id = l_transaction_action_id
           AND ccu.description = 'DPP Std Cost Update - Execution Detail ID: '||l_txn_hdr_rec.execution_detail_id
           AND ccu.cost_type_id = l_cost_type_id
           AND dpp_gt.organization_id = mmt.organization_id
           AND dpp_gt.inventory_item_id = mmt.inventory_item_id;

         FORALL indx IN transaction_ids.FIRST .. transaction_ids.LAST
                     INSERT INTO DPP_XLA_LINES(
                                 transaction_header_id
                                ,transaction_line_id
                                ,base_transaction_header_id
                                ,base_transaction_line_id
                                ,transaction_sub_type
                                ,creation_date
                                ,created_by
                                ,last_update_date
                                ,last_updated_by)
                     VALUES(
                                 l_txn_hdr_rec.Transaction_Header_ID
                                ,transaction_line_ids(indx)
                                ,l_txn_hdr_rec.Execution_Detail_ID
                                ,transaction_ids(indx)
                                ,transaction_subtypes(indx)
                                ,l_sysdate
                                ,l_txn_hdr_rec.last_updated_by
                                ,l_sysdate
                                ,l_txn_hdr_rec.last_updated_by);

       EXCEPTION
         WHEN NO_DATA_FOUND THEN
            dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'No Data Found for SLA table insertion...');
       END;
       -- End SLA Line Processing for Std Cost Update

     EXCEPTION
       WHEN OTHERS THEN
                        l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                --        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                        fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
                        fnd_message.set_token('ROUTINE', 'DPP_ITEMCOST_PVT.Update_ItemCost-SLA Tables Insertion');
                        fnd_message.set_token('ERRNO', sqlcode);
                        fnd_message.set_token('REASON', sqlerrm);
                        FND_MSG_PUB.add;
                --        END IF;
                        dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Error in SLA Tables Insertion:' || sqlerrm);
     END;
   END IF;

   dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Before Exe Dtls Update:'||to_char(sysdate,'dd-mon-yyyy hh24:mi:ss'));

   << INCORRECT_PRICE >>

   << WORKFLOW_ERROR >>

   x_return_status := l_return_status;

        SELECT DECODE(l_return_status,FND_API.G_RET_STS_SUCCESS,'SUCCESS','WARNING')
          INTO l_execution_status
          FROM DUAL;

   BEGIN
        dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Status before generating output xml: ' || l_return_status);

          --Get the output XML from DPP_OUTPUT_XML_GT table
     l_Transaction_Number := '''' || l_txn_hdr_rec.Transaction_Number || '''';

          IF x_return_status IN (FND_API.G_RET_STS_ERROR, FND_API.G_RET_STS_UNEXP_ERROR) THEN
            l_queryCtx := dbms_xmlquery.newContext('SELECT '||l_Transaction_Number||' TXNNUMBER,
                 CURSOR (Select Item_Number ITEMNUMBER,
                                inventory_org_name ORGNAME,
                                                         NewPrice NEWPRICE,
                                                         Currency CURRENCY,
                                                         Reason_For_Failure REASON
                                        from DPP_OUTPUT_XML_GT
                                        where Reason_For_Failure IS NOT NULL) TRANSACTION from dual');
          ELSE
                 l_queryCtx := dbms_xmlquery.newContext('SELECT '||l_Transaction_Number||' TXNNUMBER from dual');
     END IF;

     dbms_xmlquery.setRowTag(l_queryCtx, 'ROOT');
          l_output_xml := dbms_xmlquery.getXml(l_queryCtx);
          dbms_xmlquery.closeContext(l_queryCtx);

        EXCEPTION
          WHEN OTHERS THEN
            l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                 fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
                 fnd_message.set_token('ROUTINE', 'DPP_ITEMCOST_PVT.Update_ItemCost-XML Generation');
                 fnd_message.set_token('ERRNO', sqlcode);
                 fnd_message.set_token('REASON', sqlerrm);
                 FND_MSG_PUB.add;
        END;

        dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Status before calling update API: ' || l_return_status);

   l_exe_update_rec.Transaction_Header_ID       := l_txn_hdr_rec.Transaction_Header_ID;
   l_exe_update_rec.Org_ID                                              := l_txn_hdr_rec.Org_ID;
   l_exe_update_rec.Execution_Detail_ID                 := l_txn_hdr_rec.Execution_Detail_ID;
   l_exe_update_rec.Output_XML                                  :=        l_output_xml;
   l_exe_update_rec.execution_status                    := l_execution_status;
   l_exe_update_rec.Execution_End_Date          := SYSDATE;
   l_exe_update_rec.Provider_Process_Id                 := l_txn_hdr_rec.Provider_Process_Id;
   l_exe_update_rec.Provider_Process_Instance_id := l_txn_hdr_rec.Provider_Process_Instance_id;
   l_exe_update_rec.Last_Updated_By                     := l_txn_hdr_rec.Last_Updated_By;

   DPP_ExecutionDetails_PVT.Update_ExecutionDetails(
                         p_api_version            => l_api_version
                        ,p_init_msg_list         => FND_API.G_FALSE
                        ,p_commit                  => FND_API.G_FALSE
                        ,p_validation_level => FND_API.G_VALID_LEVEL_FULL
                        ,x_return_status         => l_return_status
                        ,x_msg_count               => l_msg_count
                        ,x_msg_data               => l_msg_data
                        ,p_EXE_UPDATE_rec         => l_exe_update_rec
                        ,p_status_Update_tbl=> l_status_Update_tbl
        );

        dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'After Exe Dtls Update:'||to_char(sysdate,'dd-mon-yyyy hh24:mi:ss'));

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                x_return_status := l_return_status;
        END IF;

   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;

   -- Debug Message

   dpp_utility_pvt.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Private API: ' || l_api_name || 'end');

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
      (p_count          =>   x_msg_count,
       p_data           =>   x_msg_data
      );
   IF x_msg_count > 1 THEN
           FOR I IN 1..x_msg_count LOOP
               x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
           END LOOP;
   END IF;
--Exception Handling
EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
        p_encoded => FND_API.G_FALSE,
        p_count   => x_msg_count,
        p_data    => x_msg_data
     );
     IF x_msg_count > 1 THEN
            FOR I IN 1..x_msg_count LOOP
               x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
            END LOOP;
     END IF;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_ITEMCOST_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data
     );
     IF x_msg_count > 1 THEN
            FOR I IN 1..x_msg_count LOOP
               x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
            END LOOP;
     END IF;

  WHEN OTHERS THEN
     ROLLBACK TO UPDATE_ITEMCOST_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
          fnd_message.set_token('ROUTINE', 'DPP_ITEMCOST_PVT.Update_ItemCost');
          fnd_message.set_token('ERRNO', sqlcode);
          fnd_message.set_token('REASON', sqlerrm);
          FND_MSG_PUB.add;

     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data
     );
     IF x_msg_count > 1 THEN
            FOR I IN 1..x_msg_count LOOP
               x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
            END LOOP;
     END IF;
END Update_ItemCost;

END DPP_ITEMCOST_PVT;

/
