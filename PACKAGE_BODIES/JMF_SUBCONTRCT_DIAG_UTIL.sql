--------------------------------------------------------
--  DDL for Package Body JMF_SUBCONTRCT_DIAG_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JMF_SUBCONTRCT_DIAG_UTIL" AS
/* $Header: JMFDUSBB.pls 120.0.12010000.2 2010/06/28 06:29:43 abhissri ship $ */

--+===========================================================================+
--|                    Copyright (c) 2005 Oracle Corporation                  |
--|                       Redwood Shores, California, USA                     |
--|                            All rights reserved.                           |
--+===========================================================================+
--|                                                                           |
--|  FILENAME :            JMFDUSBB.pls                                       |
--|                                                                           |
--|  DESCRIPTION:          Package body file for Subcontracting Diagnostics   |
--|                        Utility Package                                    |
--|                                                                           |
--|  HISTORY:                                                                 |
--|   20-DEC-2007          kdevadas  Created.                                 |
--+===========================================================================+

--=============================================
-- GLOBALS
--=============================================
--=============================================
-- PROCEDURES AND FUNCTIONS
--=============================================
--========================================================================
-- FUNCTION : Check_Profiles    PUBLIC
-- PARAMETERS: NONE
-- COMMENT   : This function checks for the profile options applicable to
--             Subcontracting and displays the profile options values, if set.
--             Returns SUCCESS only if all the profiles are set correctly
--========================================================================

FUNCTION Check_Profiles  RETURN VARCHAR2 IS
l_statusStr         VARCHAR2(10);
BEGIN
  l_statusStr :=  JMF_SUBCONTRCT_DIAG_UTIL.G_STATUS_SUCCESS;
  JTF_DIAGNOSTIC_COREAPI.SectionPrint('<u>1. CHECKING PROFILES</u>');
  IF JTF_DIAGNOSTIC_COREAPI.CheckProfile('JMF_SHK_CHARGE_BASED_ENABLED', NULL, NULL, NULL, null) = NULL   THEN
    l_statusStr :=  JMF_SUBCONTRCT_DIAG_UTIL.G_STATUS_FAILURE;
  END IF;
  IF JTF_DIAGNOSTIC_COREAPI.CheckProfile('XLA_MO_SECURITY_PROFILE_LEVEL', NULL, NULL, NULL, null) = NULL THEN
    l_statusStr :=  JMF_SUBCONTRCT_DIAG_UTIL.G_STATUS_FAILURE;
  END IF ;
  IF JTF_DIAGNOSTIC_COREAPI.CheckProfile('DEFAULT_ORG_ID', NULL, NULL, NULL, null) = NULL THEN
    l_statusStr :=  JMF_SUBCONTRCT_DIAG_UTIL.G_STATUS_FAILURE;
  END IF;
  JTF_DIAGNOSTIC_COREAPI.BRPrint;
  RETURN l_statusStr;
END Check_Profiles;

--========================================================================
-- FUNCTION : Check_WIP_Parameters    PUBLIC
-- PARAMETERS: NONE
-- COMMENT   : This function displays all the Manufacturing Partner
--             organizations for which WIP Parameters have not been defined.
--             Returns SUCCESS only if all the MP orgs have WIP parameters
--             defined.
--========================================================================
FUNCTION Check_WIP_Parameters RETURN VARCHAR2 IS
l_count             NUMBER := 0;
l_sqltxt            VARCHAR2(2000);
l_statusStr         VARCHAR2(10);
BEGIN
  l_statusStr :=  JMF_SUBCONTRCT_DIAG_UTIL.G_STATUS_SUCCESS;
  JTF_DIAGNOSTIC_COREAPI.SectionPrint('<u>2. CHECKING WIP PARAMETERS</u>');
  JTF_DIAGNOSTIC_COREAPI.line_out('WIP Parameters have not been defined for the following MP Organizations:');
  JTF_DIAGNOSTIC_COREAPI.BRPrint;
  l_sqltxt := ' SELECT
                organization_id "MP Organization Id",
                organization_code "MP Organization Code"
              FROM MTL_PARAMETERS mp
              WHERE trading_partner_org_flag = ''Y''
              AND NOT EXISTS
                (SELECT 1 FROM WIP_PARAMETERS wp
                WHERE mp.organization_id = wp.organization_id)';

  l_count := JTF_DIAGNOSTIC_COREAPI.display_SQL(l_sqltxt,'');
  JTF_DIAGNOSTIC_COREAPI.BRPrint;
  IF l_count >0 THEN
    JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Please enter WIP Parameters for these MP Organizations');
    JTF_DIAGNOSTIC_COREAPI.BRPrint;
    l_statusStr := JMF_SUBCONTRCT_DIAG_UTIL.G_STATUS_FAILURE;
  END IF;
  RETURN l_statusStr;

END Check_WIP_Parameters;

--========================================================================
-- FUNCTION : Check_Accounting_Periods    PUBLIC
-- PARAMETERS: NONE
-- COMMENT   : This function displays all the Manufacturing Partner
--             organizations for which Inventory Accounting Periods are
--             not open. Returns SUCCESS only if all the MP orgs have open
--             accounting periods for the current date.
--========================================================================
FUNCTION Check_Accounting_Periods RETURN VARCHAR2 IS
l_count             NUMBER := 0;
l_sqltxt            VARCHAR2(2000);
l_statusStr         VARCHAR2(10);
BEGIN
  l_statusStr :=  JMF_SUBCONTRCT_DIAG_UTIL.G_STATUS_SUCCESS;
  JTF_DIAGNOSTIC_COREAPI.SectionPrint('<u>3. CHECKING ACCOUNTING PERIODS</u>');
  JTF_DIAGNOSTIC_COREAPI.line_out('Inventory accounting periods are not open in the following MP organizations:');
  JTF_DIAGNOSTIC_COREAPI.BRPrint;
  l_sqltxt := ' SELECT
                organization_id "MP Organization Id",
                organization_code "MP Organization Code"
              FROM mtl_parameters mp
              WHERE trading_partner_org_flag = ''Y''
              AND NOT EXISTS
                (SELECT   1
                    FROM org_acct_periods oap
                    WHERE oap.organization_id = mp.organization_id
                    AND (Trunc(period_start_date) < Trunc(SYSDATE)
                    AND Trunc(schedule_close_date) > Trunc(SYSDATE))
                    AND open_flag = ''Y'' )';

  l_count := JTF_DIAGNOSTIC_COREAPI.display_SQL(l_sqltxt,'');
  JTF_DIAGNOSTIC_COREAPI.BRPrint;
  IF l_count >0 THEN
    JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Please open accounting periods in these MP organizations');
    JTF_DIAGNOSTIC_COREAPI.BRPrint;
    l_statusStr := JMF_SUBCONTRCT_DIAG_UTIL.G_STATUS_FAILURE;
  END IF;
  RETURN l_statusStr;

END Check_Accounting_Periods;


--========================================================================
-- FUNCTION : Check_Routings    PUBLIC
-- PARAMETERS: NONE
-- COMMENT   : This function displays all the Manufacturing Partner
--             organizations in which Routings are defined for Outsourced
--             Assembly items. For the Subcontracting feature, Routings must
--             NOT be defined in the MP org for Outsourced Assemblies.
--             Returns SUCCESS only if none of the Outsourced Assemblies have
--             routings defined for them
--========================================================================

FUNCTION Check_Routings RETURN VARCHAR2 IS
l_count             NUMBER := 0;
l_sqltxt            VARCHAR2(2000);
l_statusStr         VARCHAR2(10);
BEGIN
  l_statusStr :=  JMF_SUBCONTRCT_DIAG_UTIL.G_STATUS_SUCCESS;
  JTF_DIAGNOSTIC_COREAPI.SectionPrint('<u>4. CHECKING ROUTINGS</u>');
  JTF_DIAGNOSTIC_COREAPI.line_out('Routings are defined for the following Outsourced Assembly items in MP organizations:');
  JTF_DIAGNOSTIC_COREAPI.BRPrint;
  l_sqltxt := ' SELECT
                  msi.segment1 "Outsourced Assembly",
                  mp.organization_code "Organization Code"
                FROM
                  mtl_system_items_b msi,
                  mtl_parameters mp
                WHERE
                  msi.OUTSOURCED_ASSEMBLY = 1
                  AND msi.organization_id = mp.organization_id
                  AND mp.trading_partner_org_flag = ''Y''
                  AND EXISTS
                    (SELECT 1 FROM  bom_operational_routings bor
                      WHERE bor.organization_id = msi.organization_id
                      AND bor.assembly_item_id = msi.inventory_item_id)';


  l_count := JTF_DIAGNOSTIC_COREAPI.display_SQL(l_sqltxt,'');
  JTF_DIAGNOSTIC_COREAPI.BRPrint;
  IF l_count >0 THEN
    JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Please remove any defined routings for these Outsourced assemblies in MP Organizations');
    JTF_DIAGNOSTIC_COREAPI.BRPrint;
    l_statusStr := JMF_SUBCONTRCT_DIAG_UTIL.G_STATUS_FAILURE;
  END IF;
  RETURN l_statusStr;

END Check_Routings;

--========================================================================
-- FUNCTION : Check_Shipping_Networks    PUBLIC
-- PARAMETERS: NONE
-- COMMENT   : This function displays all the OEM and MP organizations
--             between which no shipping network has been defined and
--             which have valid subcontracting orders to be processed
--========================================================================
FUNCTION Check_Shipping_Network RETURN VARCHAR2 IS
l_count             NUMBER := 0;
l_sqltxt            VARCHAR2(2000);
l_statusStr         VARCHAR2(10);
BEGIN
  l_statusStr :=  JMF_SUBCONTRCT_DIAG_UTIL.G_STATUS_SUCCESS;
  JTF_DIAGNOSTIC_COREAPI.SectionPrint('<u>5. CHECKING SHIPPING NETWORKS</u>');
  JTF_DIAGNOSTIC_COREAPI.line_out('Shipping network is not defined between the following OEM and MP organizations:');
  JTF_DIAGNOSTIC_COREAPI.BRPrint;
  l_sqltxt := ' SELECT  DISTINCT
                (SELECT organization_code FROM mtl_parameters WHERE organization_id = oem_organization_id) "OEM Organization Code",
                (SELECT organization_code FROM mtl_parameters WHERE organization_id = tp_organization_id) "MP Organization Code"
              FROM jmf_subcontract_orders jso
              WHERE  NOT EXISTS
                (SELECT 1 FROM mtl_interorg_parameters mip
                WHERE mip.from_organization_id = jso.oem_organization_id
                AND   mip.to_organization_id   = jso.tp_organization_id
                AND SUBCONTRACTING_TYPE IS NOT NULL)';


  l_count := JTF_DIAGNOSTIC_COREAPI.display_SQL(l_sqltxt,'');
  JTF_DIAGNOSTIC_COREAPI.BRPrint;
  IF l_count >0 THEN
    JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Please define shipping networks between the following OEM and MP organizations');
    JTF_DIAGNOSTIC_COREAPI.BRPrint;
    l_statusStr := JMF_SUBCONTRCT_DIAG_UTIL.G_STATUS_FAILURE;
  END IF;
  RETURN l_statusStr;

END Check_Shipping_Network;

--========================================================================
-- FUNCTION : Check_Shipping_Methods    PUBLIC
-- PARAMETERS: NONE
-- COMMENT   : This function displays all the OEM and MP organizations
--             between which no default shipping methods has been defined and
--             which have valid subcontracting orders to be processed
--========================================================================
FUNCTION Check_Shipping_Methods RETURN VARCHAR2 IS
l_count             NUMBER := 0;
l_sqltxt            VARCHAR2(2000);
l_statusStr         VARCHAR2(10);
BEGIN
  l_statusStr :=  JMF_SUBCONTRCT_DIAG_UTIL.G_STATUS_SUCCESS;
  JTF_DIAGNOSTIC_COREAPI.SectionPrint('<u>6. CHECKING SHIPPING METHODS</u>');
  JTF_DIAGNOSTIC_COREAPI.line_out('Default shipping method is not defined between the following OEM and MP organizations:');
  JTF_DIAGNOSTIC_COREAPI.BRPrint;
  l_sqltxt := '  SELECT  DISTINCT
                (SELECT organization_code FROM mtl_parameters WHERE organization_id = oem_organization_id) "OEM Organization Code",
                (SELECT organization_code FROM mtl_parameters WHERE organization_id = tp_organization_id) "TP Organization Code"
              FROM jmf_subcontract_orders jso
              WHERE  NOT EXISTS
                (SELECT 1 FROM mtl_interorg_ship_methods mism
                WHERE mism.from_organization_id = jso.oem_organization_id
                AND   mism.to_organization_id   = jso.tp_organization_id
                AND mism.default_flag = 1)
              UNION
              SELECT  DISTINCT
                (SELECT organization_code FROM mtl_parameters WHERE organization_id = oem_organization_id) "OEM Organization Code",
                (SELECT organization_code FROM mtl_parameters WHERE organization_id = tp_organization_id) "TP Organization Code"
              FROM jmf_subcontract_orders jso
              WHERE  NOT EXISTS
                (SELECT 1 FROM mtl_interorg_ship_methods mism
                WHERE mism.from_organization_id = jso.tp_organization_id
                AND   mism.to_organization_id   = jso.oem_organization_id
                AND mism.default_flag = 1)';

  l_count := JTF_DIAGNOSTIC_COREAPI.display_SQL(l_sqltxt,'');
  JTF_DIAGNOSTIC_COREAPI.BRPrint;
  IF l_count >0 THEN
    JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Please define default shipping methods between the following OEM and MP organizations');
    JTF_DIAGNOSTIC_COREAPI.BRPrint;
    l_statusStr := JMF_SUBCONTRCT_DIAG_UTIL.G_STATUS_FAILURE;
  END IF;
  RETURN l_statusStr;

END Check_Shipping_Methods;


--========================================================================
-- FUNCTION : Check_Cust_Supp_Association    PUBLIC
-- PARAMETERS: NONE
-- COMMENT   : This function displays all the OEM and MP organizations
--             between which have no Customer/Supplier associations defined
--             in the organization's inventory information
--========================================================================
FUNCTION Check_Cust_Supp_Association RETURN VARCHAR2 IS
l_count             NUMBER := 0;
l_sqltxt            VARCHAR2(2000);
l_statusStr         VARCHAR2(10);
BEGIN
  l_statusStr :=  JMF_SUBCONTRCT_DIAG_UTIL.G_STATUS_SUCCESS;
  JTF_DIAGNOSTIC_COREAPI.SectionPrint('<u>7. CHECKING CUSTOMER SUPPLIER ASSOCIATION</u>');

  -- For OEM organizations
  JTF_DIAGNOSTIC_COREAPI.line_out('Customer/Supplier Associations have not been defined in the following OEM organizations:');
  JTF_DIAGNOSTIC_COREAPI.BRPrint;
  l_sqltxt := '  SELECT
                  ORGANIZATION_CODE "OEM Organization" FROM mtl_parameters   mp
                  WHERE Nvl(trading_partner_org_flag, ''N'') = ''N''
                  AND EXISTS(
                  SELECT  1 FROM
                  hr_organization_information hoi
                  WHERE mp.organization_id = hoi.organization_id
                  AND org_information_context = ''Customer/Supplier Association''
                  AND (org_information3 IS NULL
                      OR org_information4 IS NULL) )
                  AND EXISTS
                  ( SELECT 1 FROM mtl_system_items_b msi
                    WHERE msi.organization_id = mp.organization_id
                    AND msi.outsourced_assembly = 1)';

  l_count := JTF_DIAGNOSTIC_COREAPI.display_SQL(l_sqltxt,'');
  JTF_DIAGNOSTIC_COREAPI.BRPrint;
  IF l_count >0 THEN
    JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Please define Customer/Supplier Associations in these OEM organizations');
    JTF_DIAGNOSTIC_COREAPI.BRPrint;
    l_statusStr := JMF_SUBCONTRCT_DIAG_UTIL.G_STATUS_FAILURE;
  END IF;

   l_count :=0;
  -- For MP organizations
  JTF_DIAGNOSTIC_COREAPI.line_out('Customer/Supplier Associations have not been defined in the following MP organizations:');
  JTF_DIAGNOSTIC_COREAPI.BRPrint;
  l_sqltxt := '  SELECT
                  ORGANIZATION_CODE "MP Organization" FROM mtl_parameters   mp
                  WHERE Nvl(trading_partner_org_flag, ''N'') = ''Y''
                  AND EXISTS(
                  SELECT  1 FROM
                  hr_organization_information hoi
                  WHERE mp.organization_id = hoi.organization_id
                  AND org_information_context = ''Customer/Supplier Association''
                  AND (org_information1 IS NULL
                      OR org_information2 IS NULL
                      OR org_information4 IS NULL
                      OR org_information4 IS NULL) ) ';

  l_count := JTF_DIAGNOSTIC_COREAPI.display_SQL(l_sqltxt,'');
  JTF_DIAGNOSTIC_COREAPI.BRPrint;
  IF l_count >0 THEN
    JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Please define Customer/Supplier Associations in these MP organizations');
    JTF_DIAGNOSTIC_COREAPI.BRPrint;
    l_statusStr := JMF_SUBCONTRCT_DIAG_UTIL.G_STATUS_FAILURE;
  END IF;
  RETURN l_statusStr;

END Check_Cust_Supp_Association;

--------------------------------------------------------------------------------------
-- procedure to check if price list has been defined for the subcontracting components
--------------------------------------------------------------------------------------
--========================================================================
-- FUNCTION : Check_Price_List    PUBLIC
-- PARAMETERS: NONE
-- COMMENT   : This function displays all the subcontracting components
--             which have no price defined in the price list
--========================================================================
FUNCTION Check_Price_List RETURN VARCHAR2 IS
l_count             NUMBER := 0;
l_sqltxt            VARCHAR2(2000);
l_statusStr         VARCHAR2(10);
BEGIN
  l_statusStr :=  JMF_SUBCONTRCT_DIAG_UTIL.G_STATUS_SUCCESS;
  JTF_DIAGNOSTIC_COREAPI.SectionPrint('<u>8. CHECKING PRICE LISTS</u>');
  JTF_DIAGNOSTIC_COREAPI.line_out('The following subcontracting components are not associated with any price list:');
  JTF_DIAGNOSTIC_COREAPI.BRPrint;
  l_sqltxt := '  SELECT DISTINCT
                  SEGMENT1 "Item"
                  FROM mtl_system_items_b msi
                  WHERE subcontracting_component IN (1,2)
                  AND EXISTS
                  ( SELECT 1 FROM  mtl_parameters mp
                    WHERE mp.organization_id = msi.organization_id
                    AND Nvl(trading_partner_org_flag, ''N'') = ''Y'')
                  AND NOT EXISTS
                  ( SELECT 1 FROM  qp_list_lines
                    WHERE   qp_price_list_pvt.get_inventory_item_id(list_line_id) = msi.inventory_item_id)';

  l_count := JTF_DIAGNOSTIC_COREAPI.display_SQL(l_sqltxt,'');
  JTF_DIAGNOSTIC_COREAPI.BRPrint;
  IF l_count >0 THEN
    JTF_DIAGNOSTIC_COREAPI.ActionErrorPrint('Please define a valid price for these subcontracting components');
    JTF_DIAGNOSTIC_COREAPI.BRPrint;
    l_statusStr := JMF_SUBCONTRCT_DIAG_UTIL.G_STATUS_FAILURE;
  END IF;
  RETURN l_statusStr;

END Check_Price_List;


END JMF_SUBCONTRCT_DIAG_UTIL;

/
