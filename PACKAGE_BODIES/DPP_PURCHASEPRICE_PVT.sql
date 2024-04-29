--------------------------------------------------------
--  DDL for Package Body DPP_PURCHASEPRICE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DPP_PURCHASEPRICE_PVT" AS
/* $Header: dppvpopb.pls 120.21.12010000.2 2010/04/21 11:35:15 anbbalas ship $ */

-- Package name     : DPP_PURCHASEPRICE_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'DPP_PURCHASEPRICE_PVT';
G_DEBUG BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
G_FILE_NAME     CONSTANT VARCHAR2(14) := 'dppvpopb.pls';

---------------------------------------------------------------------
-- PROCEDURE
--    Update_PurchasePrice
--
-- PURPOSE
--    Update purchase price.
--
-- PARAMETERS
--
-- NOTES
--    1.
--    2.
----------------------------------------------------------------------

PROCEDURE Update_PurchasePrice(
    p_api_version   	 	IN 	  NUMBER
   ,p_init_msg_list	    IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_commit	         	IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_validation_level	IN 	  NUMBER       := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status	    OUT 	NOCOPY	  VARCHAR2
   ,x_msg_count	        OUT 	NOCOPY	  NUMBER
   ,x_msg_data	        OUT 	NOCOPY	  VARCHAR2
   ,p_item_price_rec	 	IN    dpp_txn_hdr_rec_type
   ,p_item_cost_tbl 	 	IN    dpp_item_cost_tbl_type
)
IS
l_api_name              CONSTANT VARCHAR2(30) := 'Update_PurchasePrice';
l_api_version           CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;

l_result                NUMBER;
l_api_errors            PO_API_ERRORS_REC_TYPE;
l_return_status 	VARCHAR2(1);
l_cur_return_status    	VARCHAR2(1);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(4000);

l_item_price_rec        DPP_PURCHASEPRICE_PVT.dpp_txn_hdr_rec_type := p_item_price_rec;
l_item_cost_tbl         DPP_PURCHASEPRICE_PVT.dpp_item_cost_tbl_type := p_item_cost_tbl;
l_po_details_tbl	DPP_PURCHASEPRICE_PVT.dpp_po_line_tbl_type;
l_exe_update_rec 	DPP_ExecutionDetails_PVT.DPP_EXE_UPDATE_REC_TYPE;
l_status_Update_tbl 	DPP_ExecutionDetails_PVT.dpp_status_Update_tbl_type;

l_new_price             NUMBER;
l_Transaction_Number    VARCHAR2(40);

l_dpp_application_id    NUMBER := 9000; -- seeded for DPP
l_responsibility_id     NUMBER;
l_exchange_rate		NUMBER;
l_user_name             VARCHAR2(100);

--OutputXML
l_output_xml		CLOB;
l_queryCtx              dbms_xmlquery.ctxType;
l_module               CONSTANT VARCHAR2(100) := 'dpp.plsql.DPP_PURCHASEPRICE_PVT.UPDATE_PURCHASEPRICE';

/* pll.price_override,
        nvl(pll.price_override,pol.unit_price) unit_price*/
CURSOR po_cur(p_inventory_item_id IN NUMBER, p_org_id IN NUMBER, p_vendor_id IN NUMBER) IS
 SELECT poh.segment1    po_num,
        poh.currency_code currency_code,
        pol.line_num    line_num,
        pol.quantity    quantity,
        poh.vendor_id   vendor_id,
        poh.vendor_site_id  vendor_site_id,
        poh.agent_id    agent_id,
        poh.ship_to_location_id ship_loc,
        poh.bill_to_location_id bill_loc,
        poh.type_lookup_code type_lookup_code,
        nvl(por.revision_num ,poh.revision_num )   revision_num,
        por.release_num,
        pll.shipment_num,
        nvl(pll.price_override,pol.unit_price) unit_price
 FROM po_headers_all poh
 JOIN po_lines_all pol
  ON poh.po_header_id = pol.po_header_id
 AND nvl(pol.closed_code,'OPEN') not in ('FINALLY CLOSED', 'CLOSED')
 AND nvl(poh.closed_code,'OPEN') not in ('FINALLY CLOSED', 'CLOSED')
 AND nvl(pol.cancel_flag,'N') = 'N'
 AND nvl(poh.cancel_flag,'N') = 'N'
 AND nvl(poh.frozen_flag,'N') = 'N'
 AND poh.org_id = pol.org_id
 AND poh.enabled_flag = 'Y'
 AND poh.org_id = p_org_id
 AND poh.vendor_id = p_vendor_id
 AND poh.authorization_status IN ('APPROVED','REQUIRES REAPPROVAL')
 and pol.item_id = p_inventory_item_id
 AND ((nvl(pol.ALLOW_PRICE_OVERRIDE_FLAG,'N') = 'Y' AND poh.type_lookup_code = 'BLANKET')
     OR (poh.type_lookup_code = 'STANDARD'))
LEFT OUTER JOIN po_line_locations_all pll
 ON  pol.po_line_id = pll.po_line_id
 AND nvl(pll.closed_code,'OPEN') not in ('FINALLY CLOSED', 'CLOSED')
 AND pll.quantity_received = 0
 AND nvl(pll.cancel_flag,'N') = 'N'
 AND pol.org_id = pll.org_id
LEFT OUTER JOIN po_releases_all por
  ON pll.po_release_id = por.po_release_id
 AND nvl(por.closed_code,'OPEN') not in ('FINALLY CLOSED', 'CLOSED')
 AND nvl(por.frozen_flag,'N') = 'N'
 AND por.authorization_status IN ('APPROVED','REQUIRES REAPPROVAL')
 AND nvl(por.cancel_flag,'N') = 'N'
 AND pll.org_id = por.org_id;

CURSOR get_item_number_csr (p_inventory_item_id IN NUMBER)
IS
SELECT concatenated_segments item_number
FROM mtl_system_items_kfv msi
WHERE inventory_item_id = p_inventory_item_id
  AND ROWNUM = 1;

BEGIN
------------------------------------------
-- Initialization
------------------------------------------

po_moac_utils_pvt.set_org_context(l_item_price_rec.org_id);

-- Standard begin of API savepoint
    SAVEPOINT  Update_PurchasePrice_PVT;
-- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
      p_api_version,
      l_api_name,
      G_PKG_NAME)   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
-- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   -- Debug Message
   DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Private API: ' || l_api_name || 'start');

-- Initialize API return status to sucess
    l_return_status := FND_API.G_RET_STS_SUCCESS;
    l_cur_return_status := FND_API.G_RET_STS_SUCCESS;
		x_return_status := l_return_status;
--
-- API body
--
  --Get the user name for the last updated by user
    BEGIN
      SELECT user_name
        INTO l_user_name
        FROM fnd_user
       WHERE user_id = l_item_price_rec.last_updated_by;
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
           DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_EXCEPTION, l_module,'Invalid User');
           RAISE FND_API.G_EXC_ERROR;
       WHEN OTHERS THEN
          fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
          fnd_message.set_token('ROUTINE', 'DPP_PURCHASEPRICE_PVT');
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
           AND fpov.profile_option_value = TO_CHAR (l_item_price_rec.org_id)
           AND fpov.level_id = 10004
           AND furgd.user_id = fpov.level_value
           AND frv.application_id = 9000
           AND TRUNC (SYSDATE) BETWEEN NVL (frv.start_date, TRUNC (SYSDATE))
           AND NVL (frv.end_date, TRUNC (SYSDATE))
           AND TRUNC (SYSDATE) BETWEEN NVL (furgd.start_date, TRUNC (SYSDATE))
           AND NVL (furgd.end_date, TRUNC (SYSDATE))
           AND furgd.responsibility_id = frv.responsibility_id
           AND furgd.responsibility_application_id = frv.application_id
           AND furgd.user_id = l_item_price_rec.last_updated_by
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
                                     l_item_price_rec.org_id))
                    OR (psp.view_all_organizations_flag = 'Y'
                        AND psp.business_group_id IS NULL)
                    OR (NVL (psp.view_all_organizations_flag, 'N') <> 'Y'
                        AND EXISTS (SELECT 1
                                      FROM per_organization_list per,
                                           hr_operating_units hr
                                     WHERE per.security_profile_id = psp.security_profile_id
                                       AND hr.organization_id = per.organization_id
                                       AND hr.usable_flag IS NULL
                                       AND per.organization_id = l_item_price_rec.org_id)))
                AND fpov.level_id = 10004
                AND furgd.user_id = fpov.level_value
                AND frv.application_id = 9000
                AND TRUNC (SYSDATE) BETWEEN NVL (frv.start_date, TRUNC (SYSDATE))
                AND NVL (frv.end_date, TRUNC (SYSDATE))
                AND TRUNC (SYSDATE) BETWEEN NVL (furgd.start_date,TRUNC (SYSDATE))
                AND NVL (furgd.end_date, TRUNC (SYSDATE))
                AND furgd.responsibility_id = frv.responsibility_id
                AND furgd.responsibility_application_id = frv.application_id
                AND furgd.user_id = l_item_price_rec.last_updated_by
                AND ROWNUM = 1;
          EXCEPTION
             WHEN NO_DATA_FOUND THEN
                 l_responsibility_id := -1;
             WHEN OTHERS THEN
                 fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
                 fnd_message.set_token('ROUTINE', 'DPP_PURCHASEPRICE_PVT');
                 fnd_message.set_token('ERRNO', sqlcode);
                 fnd_message.set_token('REASON', sqlerrm);
                 FND_MSG_PUB.add;
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END;
       WHEN OTHERS THEN
          fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
          fnd_message.set_token('ROUTINE', 'DPP_PURCHASEPRICE_PVT');
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
             AND fpov.profile_option_value = TO_CHAR (l_item_price_rec.org_id)
             AND fpov.level_id = 10003
             AND frv.responsibility_id = fpov.level_value
             AND frv.application_id = 9000
             AND TRUNC (SYSDATE) BETWEEN NVL (frv.start_date, TRUNC (SYSDATE))
                 AND NVL (frv.end_date, TRUNC (SYSDATE))
             AND TRUNC (SYSDATE) BETWEEN NVL (furgd.start_date, TRUNC (SYSDATE))
                 AND NVL (furgd.end_date, TRUNC (SYSDATE))
             AND furgd.responsibility_id = frv.responsibility_id
             AND furgd.responsibility_application_id = frv.application_id
             AND furgd.user_id = l_item_price_rec.last_updated_by
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
                                        AND hr.organization_id = l_item_price_rec.org_id))
                        OR (psp.view_all_organizations_flag = 'Y'
                            AND psp.business_group_id IS NULL)
                        OR (NVL (psp.view_all_organizations_flag, 'N') <> 'Y'
                            AND EXISTS (SELECT 1
                                          FROM per_organization_list per,
                                               hr_operating_units hr
                                         WHERE per.security_profile_id = psp.security_profile_id
                                           AND hr.organization_id = per.organization_id
                                           AND hr.usable_flag IS NULL
                                           AND per.organization_id = l_item_price_rec.org_id)))
                   AND fpov.level_id = 10003
                   AND frv.responsibility_id = fpov.level_value
                   AND frv.application_id = 9000
                   AND TRUNC (SYSDATE) BETWEEN NVL (frv.start_date, TRUNC (SYSDATE))
                       AND NVL (frv.end_date, TRUNC (SYSDATE))
                   AND TRUNC (SYSDATE) BETWEEN NVL (furgd.start_date,TRUNC (SYSDATE))
                       AND NVL (furgd.end_date, TRUNC (SYSDATE))
                   AND furgd.responsibility_id = frv.responsibility_id
                   AND furgd.responsibility_application_id = frv.application_id
                   AND furgd.user_id = l_item_price_rec.last_updated_by
                   AND ROWNUM = 1;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                   l_responsibility_id := -1;
                WHEN OTHERS THEN
                   fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
                   fnd_message.set_token('ROUTINE', 'DPP_PURCHASEPRICE_PVT');
                   fnd_message.set_token('ERRNO', sqlcode);
                   fnd_message.set_token('REASON', sqlerrm);
                   FND_MSG_PUB.add;
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END;
          WHEN OTHERS THEN
             fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
             fnd_message.set_token('ROUTINE', 'DPP_PURCHASEPRICE_PVT');
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
             AND fpov.profile_option_value = TO_CHAR (l_item_price_rec.org_id)
             AND fpov.level_id = 10002
             AND frv.application_id = fpov.level_value
             AND frv.application_id = 9000
             AND TRUNC (SYSDATE) BETWEEN NVL (frv.start_date, TRUNC (SYSDATE))
                 AND NVL (frv.end_date, TRUNC (SYSDATE))
             AND TRUNC (SYSDATE) BETWEEN NVL (furgd.start_date, TRUNC (SYSDATE))
                 AND NVL (furgd.end_date, TRUNC (SYSDATE))
             AND furgd.responsibility_id = frv.responsibility_id
             AND furgd.responsibility_application_id = frv.application_id
             AND furgd.user_id = l_item_price_rec.last_updated_by
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
                                         AND hr.organization_id = l_item_price_rec.org_id))
                      OR (psp.view_all_organizations_flag = 'Y'
                          AND psp.business_group_id IS NULL)
                      OR (NVL (psp.view_all_organizations_flag, 'N') <> 'Y'
                          AND EXISTS (SELECT 1
                                        FROM per_organization_list per,
                                             hr_operating_units hr
                                       WHERE per.security_profile_id = psp.security_profile_id
                                         AND hr.organization_id = per.organization_id
                                         AND hr.usable_flag IS NULL
                                         AND per.organization_id = l_item_price_rec.org_id)))
                   AND fpov.level_id = 10002
                   AND frv.application_id = fpov.level_value
                   AND frv.application_id = 9000
                   AND TRUNC (SYSDATE) BETWEEN NVL (frv.start_date, TRUNC (SYSDATE))
                       AND NVL (frv.end_date, TRUNC (SYSDATE))
                   AND TRUNC (SYSDATE) BETWEEN NVL (furgd.start_date,TRUNC (SYSDATE))
                       AND NVL (furgd.end_date, TRUNC (SYSDATE))
                   AND furgd.responsibility_id = frv.responsibility_id
                   AND furgd.responsibility_application_id = frv.application_id
                   AND furgd.user_id = l_item_price_rec.last_updated_by
                   AND ROWNUM = 1;
             EXCEPTION
                WHEN NO_DATA_FOUND THEN
                   l_responsibility_id := -1;
                WHEN OTHERS THEN
                   fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
                   fnd_message.set_token('ROUTINE', 'DPP_PURCHASEPRICE_PVT');
                   fnd_message.set_token('ERRNO', sqlcode);
                   fnd_message.set_token('REASON', sqlerrm);
                   FND_MSG_PUB.add;
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END;
          WHEN OTHERS THEN
             fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
             fnd_message.set_token('ROUTINE', 'DPP_PURCHASEPRICE_PVT');
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
             AND fpov.profile_option_value = TO_CHAR (l_item_price_rec.org_id)
             AND fpov.level_id = 10001
             AND fpov.level_value = 0
             AND frv.application_id = 9000
             AND TRUNC (SYSDATE) BETWEEN NVL (frv.start_date, TRUNC (SYSDATE))
                 AND NVL (frv.end_date, TRUNC (SYSDATE))
             AND TRUNC (SYSDATE) BETWEEN NVL (furgd.start_date, TRUNC (SYSDATE))
                 AND NVL (furgd.end_date, TRUNC (SYSDATE))
             AND furgd.responsibility_id = frv.responsibility_id
             AND furgd.responsibility_application_id = frv.application_id
             AND furgd.user_id = l_item_price_rec.last_updated_by
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
                                            AND hr.organization_id = l_item_price_rec.org_id))
                            OR (psp.view_all_organizations_flag = 'Y'
                                AND psp.business_group_id IS NULL)
                            OR (NVL (psp.view_all_organizations_flag, 'N') <> 'Y'
                                AND EXISTS (SELECT 1
                                              FROM per_organization_list per,
                                                   hr_operating_units hr
                                             WHERE per.security_profile_id = psp.security_profile_id
                                               AND hr.organization_id = per.organization_id
                                               AND hr.usable_flag IS NULL
                                               AND per.organization_id = l_item_price_rec.org_id)))
                       AND fpov.level_id = 10001
                       AND fpov.level_value = 0
                       AND frv.application_id = 9000
                       AND TRUNC (SYSDATE) BETWEEN NVL (frv.start_date, TRUNC (SYSDATE))
                           AND NVL (frv.end_date, TRUNC (SYSDATE))
                       AND TRUNC (SYSDATE) BETWEEN NVL (furgd.start_date,TRUNC (SYSDATE))
                           AND NVL (furgd.end_date, TRUNC (SYSDATE))
                       AND furgd.responsibility_id = frv.responsibility_id
                       AND furgd.responsibility_application_id = frv.application_id
                       AND furgd.user_id = l_item_price_rec.last_updated_by
                       AND ROWNUM = 1;
                 EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                       l_responsibility_id := -1;
                    WHEN OTHERS THEN
                       fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
                       fnd_message.set_token('ROUTINE', 'DPP_PURCHASEPRICE_PVT');
                       fnd_message.set_token('ERRNO', sqlcode);
                       fnd_message.set_token('REASON', sqlerrm);
                       FND_MSG_PUB.add;
                       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                 END;
           WHEN OTHERS THEN
             fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
             fnd_message.set_token('ROUTINE', 'DPP_PURCHASEPRICE_PVT');
             fnd_message.set_token('ERRNO', sqlcode);
             fnd_message.set_token('REASON', sqlerrm);
             FND_MSG_PUB.add;
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END;
    END IF;
    --Check if the responsibility id s -1
    IF l_responsibility_id = -1 THEN
       FND_MESSAGE.set_name('DPP', 'DPP_INVALID_RESP');
       FND_MESSAGE.set_token('USER', l_user_name);
       FND_MSG_PUB.add;

       DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Price Protection responsibility not available for Last updated user'||l_user_name);

       RAISE FND_API.G_EXC_ERROR;
    END IF;

  FND_GLOBAL.APPS_INITIALIZE(l_item_price_rec.last_updated_by,l_responsibility_id,l_dpp_application_id);

  FOR i IN l_item_cost_tbl.FIRST .. l_item_cost_tbl.LAST LOOP
      l_status_Update_tbl(i).transaction_line_id := l_item_cost_tbl(i).transaction_line_id;
      l_status_Update_tbl(i).update_status := 'Y'; -- defaulting to Y so that lines without POs can be updated to Y
      FOR get_item_number_rec IN get_item_number_csr(l_item_cost_tbl(i).inventory_item_id) LOOP
          l_item_cost_tbl(i).item_number := get_item_number_rec.item_number;
      END LOOP;
      FOR po_rec IN po_cur(l_item_cost_tbl(i).inventory_item_id, l_item_price_rec.org_id, l_item_price_rec.vendor_id) LOOP

        --Check for Blanket Purchase Agreements
        IF (po_rec.type_lookup_code = 'BLANKET' AND po_rec.release_num IS NULL) OR po_rec.shipment_num IS NULL THEN
          null;
        ELSE
          l_po_details_tbl(i).Document_Number := po_rec.po_num ||' '||po_rec.release_num;
    	  l_po_details_tbl(i).Document_Type   := po_rec.type_lookup_code;
    	  l_po_details_tbl(i).Line_Number     := po_rec.line_num;
          -- Debug Message

          DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'PO Line Price Update for item: ' || l_item_cost_tbl(i).item_number
                                            || ' for PO Number ' ||po_rec.po_num|| 'start');

          IF po_rec.currency_code IS NOT NULL THEN
             IF po_rec.currency_code = l_item_cost_tbl(i).currency THEN  --currency conversion req or not
                l_new_price := l_item_cost_tbl(i).new_price;
             ELSE    --currency conversion req or not
                DPP_UTILITY_PVT.convert_currency(p_from_currency   => l_item_cost_tbl(i).currency
                                                ,p_to_currency     => po_rec.currency_code
                                                ,p_conv_type       => FND_API.G_MISS_CHAR
                                                ,p_conv_rate       => FND_API.G_MISS_NUM
                                                ,p_conv_date       => SYSDATE
                                                ,p_from_amount     => l_item_cost_tbl(i).new_price
                                                ,x_return_status   => l_cur_return_status
                                                ,x_to_amount       => l_new_price
                                                ,x_rate            => l_exchange_rate
                                                );
             END IF;   --currency conversion req or not
             -- Handle currency conversion error
             IF l_cur_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                   DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Error in Currency Conversion to PO Currency: ' || po_rec.currency_code);

                   l_po_details_tbl(i).Reason_For_Failure := NVL(l_po_details_tbl(i).Reason_For_Failure,' ')
                                                             ||'Error in Currency Conversion to PO Currency: '
                                                             || po_rec.currency_code;
                   l_return_status := l_cur_return_status;
                   l_status_Update_tbl(i).update_status := 'N';
                   INSERT INTO DPP_OUTPUT_XML_GT(Item_Number,
                                            Document_Type,
                                            Document_Number,
                                            Line_Number,
                                            Reason_For_Failure)
                                     VALUES(l_item_cost_tbl(i).item_number,
                                            l_po_details_tbl(i).Document_Type,
                                            l_po_details_tbl(i).Document_Number,
                                            l_po_details_tbl(i).Line_Number,
                                            l_po_details_tbl(i).Reason_for_failure);
             ELSE  --l_cur_return_status is success
                --Check if the Price is Same
                IF po_rec.unit_price = l_new_price THEN
                   DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'No update required since PO line price is same for '||po_rec.po_num);
                ELSE   ---po_rec.unit_price = l_new_price THEN
                   -- Debug Message
                   DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Price to be updated for item: ' || l_item_cost_tbl(i).item_number || ' is ' ||l_new_price);

                   l_result := PO_CHANGE_API1_S.update_po(x_po_number         =>    po_rec.po_num,
                                                     x_release_number	 =>    po_rec.release_num,
                                                     x_revision_number	 =>    po_rec.revision_num,
                                                     x_line_number	 =>    po_rec.line_num,
                                                     x_shipment_number	 =>    po_rec.shipment_num,
                                                     new_quantity	 =>    NULL,
                                                     new_price		 =>    l_new_price,
                                                     new_promised_date   =>    NULL,
                                                     new_need_by_date    =>    NULL,
                                                     launch_approvals_flag   =>	  'Y', -- launch approval through workflow
                                                     update_source	 =>    'Oracle Price Protection',
                                                     version		 =>    1.0,
                                                     x_override_date	 =>    NULL,
                                                     x_api_errors        =>    l_api_errors,
                                                     p_buyer_name           =>    NULL,
                                                     p_secondary_quantity   =>    NULL,
                                                     p_preferred_grade      =>    NULL,
                                                     p_org_id               =>    l_item_price_rec.org_id
                                                     );
                   -- Debug Message
                   DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'PO API Result for item: ' || l_item_cost_tbl(i).item_number ||' and PO Number: '||po_rec.po_num ||' is ' ||l_result);

                   IF (l_result <> 1) THEN
                       l_status_Update_tbl(i).update_status := 'N';
                       l_return_status := FND_API.G_RET_STS_ERROR;
                       -- Display the errors
                       FOR j IN 1..l_api_errors.message_text.COUNT LOOP
                           l_po_details_tbl(i).Reason_for_failure	:= l_api_errors.message_text(j);
                           -- Debug Message
                           DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Error Message: ' || l_api_errors.message_text(j));

                           INSERT INTO DPP_OUTPUT_XML_GT(Item_Number,
                                                   Document_Type,
                                                   Document_Number,
                                                   Line_Number,
                                                   Reason_For_Failure)
                                            VALUES(l_item_cost_tbl(i).item_number,													l_po_details_tbl(i).Document_Type,
                                                   l_po_details_tbl(i).Document_Number,
                                                   l_po_details_tbl(i).Line_Number,
                                                   l_po_details_tbl(i).Reason_for_failure);
                       END LOOP;
                   ELSE  --(l_result <> 1) THEN
                      l_status_Update_tbl(i).update_status := 'Y';
                   END IF;
                   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
                      x_return_status := l_return_status;
                   END IF;
                   -- Debug Message
                   DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'PO Line Price Update for item: ' || l_item_cost_tbl(i).item_number
                                            || ' for PO Number ' ||po_rec.po_num|| 'end');

                 END IF;  ---po_rec.unit_price = l_new_price THEN
             END IF;  --Currency status success
          END IF;   --po_rec.currency_code IS NOT NULL THEN
        END IF ;  -- For blanket purchase agreements
      END LOOP;  -- po cursor loop
  END LOOP; -- all records
  IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     l_exe_update_rec.execution_status := 'SUCCESS';
  ELSE
     l_exe_update_rec.execution_status := 'WARNING';
  END IF;
  --OutputXML Generation
  BEGIN
     DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Status before generating output xml: ' || x_return_status);

     --Get the output XML from DPP_OUTPUT_XML_GT table
     l_Transaction_Number := ''''||l_item_price_rec.Transaction_Number||'''';
     IF x_return_status IN (FND_API.G_RET_STS_ERROR, FND_API.G_RET_STS_UNEXP_ERROR) THEN
        l_queryCtx := dbms_xmlquery.newContext('SELECT '||l_Transaction_Number||' TXNNUMBER,
						 CURSOR (Select Item_Number ITEMNUMBER,
	                   					Document_Type POTYPE,
                                                                Document_Number PONUMBER,
                                                                Line_Number LINENUMBER,
                                                                Reason_For_Failure REASON
                                                                from DPP_OUTPUT_XML_GT
                                                                where Reason_For_Failure IS NOT NULL) TRANSACTION from dual'
                                                                );
     ELSE
        l_queryCtx := dbms_xmlquery.newContext('SELECT '||l_Transaction_Number||' TXNNUMBER from dual');
     END IF;
     dbms_xmlquery.setRowTag(l_queryCtx,'ROOT');
     l_output_xml := dbms_xmlquery.getXml(l_queryCtx);
     dbms_xmlquery.closeContext(l_queryCtx);
  EXCEPTION
     WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	    fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
	    fnd_message.set_token('ROUTINE', 'DPP_PURCHASEPRICE_PVT.Update_PurchasePrice-XML Generation');
       fnd_message.set_token('ERRNO', sqlcode);
       fnd_message.set_token('REASON', sqlerrm);
   	   FND_MSG_PUB.add;
  END;

  l_exe_update_rec.Transaction_Header_ID 	:= l_item_price_rec.Transaction_Header_ID;
  l_exe_update_rec.Org_ID 			:= l_item_price_rec.Org_ID;
  l_exe_update_rec.Execution_Detail_ID 		:= l_item_price_rec.Execution_Detail_ID;
  l_exe_update_rec.Output_XML   		:= l_output_xml;
  l_exe_update_rec.Execution_End_Date 		:= SYSDATE;
  l_exe_update_rec.Provider_Process_Id 		:= l_item_price_rec.Provider_Process_Id;
  l_exe_update_rec.Provider_Process_Instance_id := l_item_price_rec.Provider_Process_Instance_id;
  l_exe_update_rec.Last_Updated_By 		:= l_item_price_rec.Last_Updated_By;

  DPP_ExecutionDetails_PVT.Update_ExecutionDetails(p_api_version   	 	=> l_api_version
                                                  ,p_init_msg_list	 	=> FND_API.G_FALSE
                                                  ,p_commit	         	=> FND_API.G_FALSE
                                                  ,p_validation_level	=> FND_API.G_VALID_LEVEL_FULL
                                                  ,x_return_status	 	=> l_return_status
                                                  ,x_msg_count	     	=> l_msg_count
                                                  ,x_msg_data	         => l_msg_data
                                                  ,p_EXE_UPDATE_rec	   => l_exe_update_rec
                                                  ,p_status_Update_tbl => l_status_Update_tbl
                                                  );

  DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Status after update execution details: ' || l_return_status);

  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

-- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;
   -- Debug Message
   DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Private API: ' || l_api_name || 'end');

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
   (p_count          =>   x_msg_count,
    p_data           =>   x_msg_data
   );
--Exception Handling
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
	 ROLLBACK TO UPDATE_PURCHASEPRICE_PVT;
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
	 ROLLBACK TO UPDATE_PURCHASEPRICE_PVT;
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
        ROLLBACK TO UPDATE_PURCHASEPRICE_PVT;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 	      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
	      fnd_message.set_token('ROUTINE', l_full_name);
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

END Update_PurchasePrice;

---------------------------------------------------------------------
-- PROCEDURE
--    Notify_PO
--
-- PURPOSE
--    Notify_Partial Receipts
--
-- PARAMETERS
--
-- NOTES
--    1.
--    2.
----------------------------------------------------------------------

PROCEDURE Notify_PO(
    p_api_version   	 IN 	  NUMBER
   ,p_init_msg_list	     IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_commit	         IN 	  VARCHAR2     := FND_API.G_FALSE
   ,p_validation_level	 IN 	  NUMBER       := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status	     OUT NOCOPY	  VARCHAR2
   ,x_msg_count	         OUT NOCOPY	  NUMBER
   ,x_msg_data	         OUT NOCOPY	  VARCHAR2
   ,p_po_notify_hdr_rec	 IN OUT NOCOPY  dpp_po_notify_rec_type
   ,p_po_notify_item_tbl	IN OUT NOCOPY  dpp_po_notify_item_tbl_type
)
IS
l_api_name              CONSTANT VARCHAR2(30) := 'Notify_PO';
l_api_version           CONSTANT NUMBER := 1.0;
l_full_name             CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
l_module                CONSTANT VARCHAR2(100) := 'dpp.plsql.DPP_PURCHASEPRICE_PVT.NOTIFY_PO';

l_rec_count             NUMBER;
l_return_status         VARCHAR2(1);
l_operating_unit_name   VARCHAR2(40);

l_po_notify_hdr_rec     DPP_PURCHASEPRICE_PVT.dpp_po_notify_rec_type := p_po_notify_hdr_rec;
l_po_notify_item_tbl    DPP_PURCHASEPRICE_PVT.dpp_po_notify_item_tbl_type := p_po_notify_item_tbl;
l_po_details_tbl	DPP_PURCHASEPRICE_PVT.dpp_po_details_tbl_type;
l_vendor_rec            DPP_UTILITY_PVT.vendor_rec_type;
l_vendor_site_rec       DPP_UTILITY_PVT.vendor_site_rec_type;

CURSOR get_po_details_csr(p_vendor_id IN NUMBER, p_inventory_item_id IN NUMBER, p_org_id IN NUMBER)
IS
/* Select PO Lines with Partial Receipts */
SELECT
  poh.segment1||DECODE(por.release_num,NULL,NULL,'-'||por.release_num)    doc_num,
  poh.type_lookup_code,
  pol.line_num    line_num,
  flv.meaning authorization_status
FROM
  po_headers_all poh
  JOIN
  po_lines_all pol
  ON
  poh.po_header_id = pol.po_header_id AND
  nvl(pol.closed_code,'OPEN') not in ('FINALLY CLOSED', 'CLOSED')   AND
  nvl(poh.closed_code,'OPEN') not in ('FINALLY CLOSED', 'CLOSED') AND
  nvl(pol.cancel_flag,'N') = 'N' AND
  nvl(poh.cancel_flag,'N') = 'N' AND
  poh.org_id = pol.org_id AND
  poh.org_id = p_org_id   AND
  pol.item_id = p_inventory_item_id    AND
  poh.vendor_id = p_vendor_id   AND
  poh.enabled_flag = 'Y'
  INNER JOIN
  po_line_locations_all pll
  ON
  pol.po_line_id = pll.po_line_id AND
  (pll.quantity_received > 0 OR (nvl(pol.ALLOW_PRICE_OVERRIDE_FLAG,'N') = 'N' AND poh.type_lookup_code = 'BLANKET')) AND
  nvl(pll.closed_code,'OPEN') not in ('FINALLY CLOSED', 'CLOSED') AND
  nvl(pll.cancel_flag,'N') = 'N'
  LEFT OUTER JOIN
  po_releases_all por
ON
  pll.po_release_id = por.po_release_id   AND
  nvl(por.closed_code,'OPEN') not in ('FINALLY CLOSED', 'CLOSED')   AND
  nvl(por.cancel_flag,'N') = 'N'    AND
  pol.org_id = pll.org_id   AND
  pll.org_id = por.org_id
  INNER JOIN
	fnd_lookup_values flv
	ON
	flv.lookup_type = 'AUTHORIZATION STATUS' AND
	flv.language = USERENV('LANG') AND
  nvl(por.authorization_status ,poh.authorization_status) = flv.lookup_code
UNION
/* Select POs Pending Approval, Incomplete and Pre-Approved POs  */
SELECT
  poh.segment1    doc_num,
  poh.type_lookup_code,
  pol.line_num    line_num,
  flv.meaning authorization_status
FROM
  po_headers_all poh
JOIN
  po_lines_all pol
ON
  poh.po_header_id = pol.po_header_id   AND
  nvl(pol.closed_code,'OPEN') not in ('FINALLY CLOSED', 'CLOSED')   AND
  nvl(poh.closed_code,'OPEN') not in ('FINALLY CLOSED', 'CLOSED')   AND
  NVL(poh.authorization_status,'NONE') NOT IN ('APPROVED','REQUIRES REAPPROVAL') AND
  nvl(pol.cancel_flag,'N') = 'N'   AND
  nvl(poh.cancel_flag,'N') = 'N'   AND
  poh.org_id = pol.org_id   AND
  poh.org_id = p_org_id   AND
  pol.item_id = p_inventory_item_id    AND
  poh.vendor_id = p_vendor_id AND
  poh.enabled_flag = 'Y'
  INNER JOIN
	fnd_lookup_values flv
	ON
	flv.lookup_type = 'AUTHORIZATION STATUS' AND
	flv.language = USERENV('LANG') AND
  nvl(poh.authorization_status,'INCOMPLETE') = flv.lookup_code

  UNION
  /* Select Frozen, Incomplete, In Process etc. releases */
SELECT
  poh.segment1||DECODE(por.release_num,NULL,NULL,'-'||por.release_num)    doc_num,
  poh.type_lookup_code,
  pol.line_num    line_num,
  flv.meaning authorization_status
FROM
  po_headers_all poh,
  po_lines_all pol,
  po_line_locations_all pll,
  po_releases_all por,
  fnd_lookup_values flv
WHERE
  poh.po_header_id = pol.po_header_id   AND
  nvl(pol.closed_code,'OPEN') not in ('FINALLY CLOSED', 'CLOSED')   AND
  nvl(poh.closed_code,'OPEN') not in ('FINALLY CLOSED', 'CLOSED')   AND
  nvl(pol.cancel_flag,'N') = 'N'   AND
  nvl(poh.cancel_flag,'N') = 'N'   AND
  poh.org_id = pol.org_id   AND
  poh.org_id = p_org_id   AND
  pol.item_id = p_inventory_item_id    AND
  poh.vendor_id = p_vendor_id AND
  poh.enabled_flag = 'Y'  AND
  pol.po_line_id = pll.po_line_id AND
  pll.po_release_id = por.po_release_id   AND
  nvl(por.closed_code,'OPEN') not in ('FINALLY CLOSED', 'CLOSED')   AND
  nvl(por.cancel_flag,'N') = 'N'    AND
  (nvl(por.frozen_flag, 'N') = 'Y' OR NVL(por.authorization_status,'NONE') NOT IN ('APPROVED','REQUIRES REAPPROVAL')) AND
  pol.org_id = pll.org_id   AND
  pll.org_id = por.org_id AND
  flv.lookup_type = 'AUTHORIZATION STATUS' AND
  flv.language = USERENV('LANG') AND
  NVL(por.authorization_status,'INCOMPLETE') = flv.lookup_code
/*Select the Frozen Pos*/
UNION
SELECT
  poh.segment1    doc_num,
  poh.type_lookup_code,
  pol.line_num    line_num,
  flv.meaning authorization_status
FROM
  po_headers_all poh
JOIN
  po_lines_all pol
ON
  poh.po_header_id = pol.po_header_id   AND
  nvl(pol.closed_code,'OPEN') not in ('FINALLY CLOSED', 'CLOSED')   AND
  nvl(poh.closed_code,'OPEN') not in ('FINALLY CLOSED', 'CLOSED')   AND
  nvl(pol.cancel_flag,'N') = 'N'   AND
  nvl(poh.cancel_flag,'N') = 'N'   AND
  nvl(poh.frozen_flag,'N') = 'Y'   AND
  poh.org_id = pol.org_id   AND
  poh.org_id = p_org_id   AND
  pol.item_id = p_inventory_item_id    AND
  poh.vendor_id = p_vendor_id AND
  poh.enabled_flag = 'Y'
  INNER JOIN
	fnd_lookup_values flv
	ON
	flv.lookup_type = 'AUTHORIZATION STATUS' AND
	flv.language = USERENV('LANG') AND
  nvl(poh.authorization_status,'INCOMPLETE') = flv.lookup_code
 /*Select the Blanket purchase agreements */
UNION
SELECT
  poh.segment1    doc_num,
  poh.type_lookup_code,
  pol.line_num    line_num,
  flv.meaning authorization_status
FROM
  po_headers_all poh
JOIN
  po_lines_all pol
ON
  poh.po_header_id = pol.po_header_id   AND
  nvl(pol.closed_code,'OPEN') not in ('FINALLY CLOSED', 'CLOSED')   AND
  nvl(poh.closed_code,'OPEN') not in ('FINALLY CLOSED', 'CLOSED')   AND
  nvl(pol.cancel_flag,'N') = 'N'   AND
  nvl(poh.cancel_flag,'N') = 'N'   AND
  poh.type_lookup_code = 'BLANKET' AND
  poh.org_id = pol.org_id   AND
  poh.org_id = p_org_id   AND
  pol.item_id = p_inventory_item_id    AND
  poh.vendor_id = p_vendor_id AND
  poh.enabled_flag = 'Y'
  INNER JOIN
	fnd_lookup_values flv
	ON
	flv.lookup_type = 'AUTHORIZATION STATUS' AND
	flv.language = USERENV('LANG') AND
  nvl(poh.authorization_status,'INCOMPLETE') = flv.lookup_code
/* Select POs if there are pending receiving transactions for the shipment */
UNION
SELECT
  poh.segment1||DECODE(por.release_num,NULL,NULL,'-'||por.release_num)    doc_num,
  poh.type_lookup_code,
  pol.line_num    line_num,
  flv.meaning authorization_status
FROM
  po_headers_all poh
JOIN
  po_lines_all pol
ON
  poh.po_header_id = pol.po_header_id   AND
  nvl(pol.closed_code,'OPEN') not in ('FINALLY CLOSED', 'CLOSED')   AND
  nvl(poh.closed_code,'OPEN') not in ('FINALLY CLOSED', 'CLOSED')   AND
  nvl(pol.cancel_flag,'N') = 'N'   AND
  nvl(poh.cancel_flag,'N') = 'N'   AND
  poh.org_id = pol.org_id   AND
  poh.org_id = p_org_id   AND
  pol.item_id = p_inventory_item_id    AND
  poh.vendor_id = p_vendor_id   AND
  poh.enabled_flag = 'Y'
INNER JOIN
  po_line_locations_all pll
ON
  pol.po_line_id = pll.po_line_id  AND
  pol.org_id = pll.org_id  AND
  nvl(pll.closed_code,'OPEN') not in ('FINALLY CLOSED', 'CLOSED')   AND
  --pll.quantity_received > 0   AND
  nvl(pll.cancel_flag,'N') = 'N'
INNER JOIN
  rcv_transactions_interface rti
ON
  rti.po_line_location_id = pll.line_location_id AND
  rti.transaction_status_code = 'PENDING'
LEFT OUTER JOIN
  po_releases_all por
ON
  pll.po_release_id = por.po_release_id AND
  nvl(por.closed_code,'OPEN') not in ('FINALLY CLOSED', 'CLOSED')   AND
  nvl(por.cancel_flag,'N') = 'N'  AND
  pll.org_id = por.org_id
  INNER JOIN
	fnd_lookup_values flv
	ON
	flv.lookup_type = 'AUTHORIZATION STATUS' AND
	flv.language = USERENV('LANG') AND
  nvl(por.authorization_status ,poh.authorization_status) = flv.lookup_code;


CURSOR get_item_number_csr(p_inventory_item_id IN NUMBER)
IS
SELECT msi.concatenated_segments
  FROM mtl_system_items_kfv msi
 WHERE inventory_item_id = p_inventory_item_id
   AND ROWNUM = 1;

-- report card id: 872003
BEGIN
-- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME)   THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
--Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
     FND_MSG_PUB.initialize;
  END IF;

-- Debug Message
   DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Private API: ' || l_api_name || 'start');

-- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;
--
-- API body
--
   l_vendor_rec.vendor_id := l_po_notify_hdr_rec.vendor_id;
   DPP_UTILITY_PVT.Get_Vendor(p_vendor_rec => l_vendor_rec
                             ,x_rec_count	=> l_rec_count
                             ,x_return_status	=> l_return_status
                             );
   l_po_notify_hdr_rec.Vendor_Number	:= l_vendor_rec.Vendor_Number;
   l_po_notify_hdr_rec.Vendor_Name	:= l_vendor_rec.Vendor_Name;
   l_vendor_site_rec.Vendor_id		:= l_po_notify_hdr_rec.Vendor_id;
   l_vendor_site_rec.Vendor_Site_id	:= l_po_notify_hdr_rec.Vendor_Site_id;

   DPP_UTILITY_PVT.Get_Vendor_Site(p_vendor_site_rec => l_vendor_site_rec
                                  ,x_rec_count	=> l_rec_count
                                  ,x_return_status	=> l_return_status
                                  );

   l_po_notify_hdr_rec.Vendor_Site_Code	:= l_vendor_site_rec.Vendor_Site_Code;

   SELECT name
     INTO l_operating_unit_name
     FROM hr_operating_units
    WHERE organization_id = l_po_notify_hdr_rec.org_id;

    l_po_notify_hdr_rec.Operating_Unit	:= l_operating_unit_name;
    p_po_notify_hdr_rec := l_po_notify_hdr_rec;

    IF l_po_notify_item_tbl.EXISTS(1) THEN
       FOR i IN l_po_notify_item_tbl.FIRST..l_po_notify_item_tbl.LAST LOOP
           IF l_po_notify_item_tbl(i).inventory_item_id IS NULL THEN
              IF g_debug THEN
                 DPP_Utility_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Inventory Item ID cannot be NULL');
              END IF;
              FND_MESSAGE.set_name('DPP', 'DPP_API_INPUT_ID_MISSING');
              FND_MESSAGE.set_token('ID', 'Inventory Item ID');
              FND_MSG_PUB.add;
              -- Initializing Nested Table
	      IF NOT l_po_details_tbl.EXISTS(1) THEN
	         l_po_details_tbl(1).Document_Number := NULL;
		 l_po_details_tbl(1).Document_Type	 := NULL;
		 l_po_details_tbl(1).PO_Line_NUmber	:= NULL;
		 l_po_details_tbl(1).Authorization_Status := NULL;
              END IF;
              p_po_notify_item_tbl(i).po_details_tbl := l_po_details_tbl;
              RAISE FND_API.G_EXC_ERROR;
           ELSE
	      FOR get_item_number_rec IN get_item_number_csr(l_po_notify_item_tbl(i).inventory_item_id)	LOOP
                  p_po_notify_item_tbl(i).item_number := get_item_number_rec.concatenated_segments;
              END LOOP;
              OPEN get_po_details_csr(l_po_notify_hdr_rec.vendor_id,
                                   l_po_notify_item_tbl(i).inventory_item_id,
                                   l_po_notify_hdr_rec.org_id);
                LOOP
                  FETCH get_po_details_csr BULK COLLECT INTO l_po_details_tbl;
                  EXIT WHEN get_po_details_csr%NOTFOUND;
                END LOOP;
              CLOSE get_po_details_csr;

              -- Initializing Nested Table
              IF NOT l_po_details_tbl.EXISTS(1) THEN
                 l_po_details_tbl(1).Document_Number := NULL;
                 l_po_details_tbl(1).Document_Type	 := NULL;
                 l_po_details_tbl(1).PO_Line_NUmber := NULL;
                 l_po_details_tbl(1).Authorization_Status := NULL;
              END IF;
              p_po_notify_item_tbl(i).po_details_tbl := l_po_details_tbl;
           END IF;
       END LOOP;
    END IF;

   -- Debug Message
   IF g_debug THEN
      DPP_UTILITY_PVT.debug_message(FND_LOG.LEVEL_STATEMENT, l_module, 'Private API: ' || l_api_name || 'end');
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
   (p_count          =>   x_msg_count,
    p_data           =>   x_msg_data
   );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Standard call to get message count and if count=1, get the message
        FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
		 p_count   => x_msg_count,
		 p_data    => x_msg_data
		 );
	 IF x_msg_count > 1 THEN
            FOR I IN 1..x_msg_count LOOP
                x_msg_data := SUBSTR((x_msg_data||' '|| FND_MSG_PUB.GET(P_MSG_INDEX => I, P_ENCODED => 'F')), 1, 4000);
	    END LOOP;
	 END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
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
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 	      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
	      fnd_message.set_token('ROUTINE', l_full_name);
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

END Notify_PO;

END DPP_PURCHASEPRICE_PVT;


/
