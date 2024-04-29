--------------------------------------------------------
--  DDL for Package Body GMF_ORGANIZATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_ORGANIZATIONS_PKG" AS
/* $Header: GMFPORGB.pls 120.5.12010000.2 2009/08/17 13:38:47 rpatangy ship $ */
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMFPORGB.pls                                        |
--| Package Name       : GMF_ORGANIZATIONS_PKG                               |
--| API name           : Get_Process_Organizations                           |
--| Type               : Public                                              |
--| Pre-reqs             : N/A                                               |
--| Function             : Populate process organizations for a legal entity |
--|                      and range of organizations                          |
--| Parameters         : p_Legal_Entity_id                                   |
--|                      p_From_Orgn_Code                                    |
--|                      p_To_Orgn_Code                                      |
--|                      x_Row_Count                                         |
--|                      x_Return_Status                                     |
--|                                                                          |
--|AUTHOR              : Sukarna Reddy Dt 05-Jul-2005                        |
--| Notes                                                                    |
--|     This package contains a procedure to populate global temporary table |
--|     GMF_PROCESS_ORGANIZATIONS_GT with process organization for a         |
--|     specified legal entity.                                              |
--|                                                                          |
--| HISTORY                                                                  |
--|   umoogala   05-Aug-2005   Added Legal_entity_Id to the table.           |
--| rpatangy 13-Aug-2009 B8757676 Added period_id to check for disabled org  |
--+==========================================================================+


  PROCEDURE get_process_organizations(p_Legal_Entity_id  IN  NUMBER,
                                      p_From_Orgn_Code   IN  VARCHAR2,
                                      p_To_Orgn_Code     IN  VARCHAR2,
                                      p_period_id        IN  NUMBER,  /* B8757676 */
                                      x_Row_Count        OUT NOCOPY NUMBER,
                                      x_Return_Status    OUT NOCOPY NUMBER
                                     ) IS
    l_index          PLS_INTEGER;
    l_org_count      PLS_INTEGER;
    l_return_status  VARCHAR2(5);
    l_msg_data       VARCHAR2(2000);

    l_from_orgn_code MTL_ORGANIZATIONS.ORGANIZATION_CODE%TYPE;
    l_to_orgn_code   MTL_ORGANIZATIONS.ORGANIZATION_CODE%TYPE;
    l_le_info        XLE_BUSINESSINFO_GRP.INV_ORG_REC_TYPE;
    l_period_id      gmf_period_statuses.period_id%TYPE;   /* B8757676 */
    l_period_start_date gmf_period_statuses.start_date%TYPE; /* B8757676 */
    l_period_end_date gmf_period_statuses.end_date%TYPE; /* B8757676 */

    TYPE inv_orgs IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    l_inv_orgs  inv_orgs;

  BEGIN

    x_Return_Status := 0;
    l_from_orgn_code := p_from_orgn_code;
    l_to_orgn_code   := p_to_orgn_code;
    l_period_id      := p_period_id;   /* B8757676 */

    BEGIN  /* B8757676 */
      IF l_period_id IS NOT NULL THEN
       SELECT  start_date, end_date INTO
        l_period_start_date, l_period_end_date
        FROM gmf_period_statuses WHERE period_id = l_period_id ;
      ELSE
        NULL;
      END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      NULL ;
      WHEN OTHERS THEN
      NULL ;
    END ;  /* B8757676 */

    XLE_BUSINESSINFO_GRP.Get_InvOrg_Info(
                        x_return_status  => l_return_status,
                        x_msg_data       => l_msg_data,
                        P_InvOrg_ID      => NULL,
                        P_Le_ID          => p_legal_entity_id,
                        P_Party_ID       => NULL,
                        x_Inv_Le_info    => l_le_info);
    l_org_count := l_le_info.count;

    IF l_org_count = 0
    THEN
      x_Row_Count := 0;
      x_return_status := -1; --No Rows returned by the API
      RETURN;
    END IF;


    FOR l_index IN 1..l_org_count
    LOOP
        l_inv_orgs(l_index) := l_le_info(l_index).inv_org_id;
    END LOOP;

    FORALL j IN 1..l_le_info.COUNT
      INSERT
        INTO GMF_PROCESS_ORGANIZATIONS_GT
        (
           organization_id,
           organization_code,
           base_currency_code,
           std_uom,
           legal_entity_id,
           operating_unit_id
        )
        SELECT  mp.organization_id,
                mp.organization_code,
                gfp.base_currency_code,
                NULL,
                p_legal_entity_id,
                ood.operating_unit
          FROM  mtl_parameters mp,
                gmf_fiscal_policies gfp,
                org_organization_definitions ood
        WHERE mp.organization_id = l_inv_orgs(j)
           AND mp.process_enabled_flag = 'Y'
           AND mp.organization_code >= NVL(l_from_orgn_code,mp.organization_code)
           AND mp.organization_code <= NVL(l_to_orgn_code,mp.organization_code)
           AND gfp.legal_entity_id = p_legal_entity_id
           AND ood.organization_id = l_inv_orgs(j)
	   AND ( ( ood.disable_date IS NOT NULL AND l_period_end_date IS NOT NULL
                   AND ood.disable_date > l_period_end_date )
		 OR
                ( ood.disable_date IS NULL  )
                 OR
                ( l_period_end_date IS NULL )   -- B8757676
               )
    ;

    x_Row_Count := sql%rowcount;

    IF x_Row_Count = 0
    THEN
      x_return_status := -1; --No Rows returned by the API
      RETURN;
    END IF;


    UPDATE gmf_process_organizations_gt gpo
     SET std_uom = (SELECT u.uom_code
                      FROM mtl_units_of_measure u,
                           gmd_parameters_hdr h,
                           gmd_parameters_dtl d
                    WHERE u.base_uom_flag = 'Y'
                    AND gpo.organization_id = h.organization_id
                    AND h.parameter_id = d.parameter_id
                    AND d.parameter_name = 'FM_YIELD_TYPE'
                    AND d.parameter_value = u.uom_class)
    WHERE gpo.std_uom IS NULL;

    UPDATE gmf_process_organizations_gt gpo
     SET std_uom = (SELECT u.uom_code
                      FROM mtl_units_of_measure u,
                           gmd_parameters_hdr h,
                           gmd_parameters_dtl d
                    WHERE u.base_uom_flag = 'Y'
                    AND  h.organization_id IS NULL
                    AND h.parameter_id = d.parameter_id
                    AND d.parameter_name = 'FM_YIELD_TYPE'
                    AND d.parameter_value = u.uom_class)
    WHERE gpo.std_uom IS NULL;

   EXCEPTION
     WHEN OTHERS
     THEN
     x_return_status := -1;

   END get_process_organizations;

END GMF_ORGANIZATIONS_PKG;

/
