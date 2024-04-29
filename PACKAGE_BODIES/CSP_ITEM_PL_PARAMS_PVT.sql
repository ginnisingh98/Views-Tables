--------------------------------------------------------
--  DDL for Package Body CSP_ITEM_PL_PARAMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_ITEM_PL_PARAMS_PVT" AS
/* $Header: cspvpipb.pls 120.1 2006/01/20 13:55:29 phegde noship $ */

--
-- Purpose: Insert or update table mtl_item_pl_params based on some conditions
--
-- MODIFICATION HISTORY
-- Person      Date      Comments
-- ---------   ------    ------------------------------------------
--  phegde      01/05/06  created package


  PROCEDURE merge_item_params
     (  p_organization_id       NUMBER
       ,p_inventory_item_id     NUMBER
       ,p_excess_service_level  NUMBER
       ,p_repair_service_level  NUMBER
       ,p_newbuy_service_level  NUMBER
       ,p_excess_edq_factor     NUMBER
       ,p_repair_edq_factor     NUMBER
       ,p_newbuy_edq_factor     NUMBER
       ,p_excess_edq_multiple   NUMBER
       ,p_repair_edq_multiple   NUMBER
       ,p_newbuy_edq_multiple   NUMBER
     ) IS
     l_excess_service_level     NUMBER;
     l_repair_service_level     NUMBER;
     l_newbuy_service_level     NUMBER;
     l_excess_edq_factor        NUMBER;
     l_repair_edq_Factor        NUMBER;
     l_newbuy_edq_Factor        NUMBER;
     l_edq_multiple             NUMBER;
     l_item_pl_params_s         NUMBER;
     l_count                    NUMBER;
     l_item_excess_Service_level   NUMBER;
     l_item_repair_Service_level    NUMBER;
     l_item_newbuy_service_level    NUMBER;
     l_item_excess_edq_factor       NUMBER;
     l_item_repair_edq_factor       NUMBER;
     l_item_newbuy_edq_factor       NUMBER;
     l_item_excess_Edq_multiple     NUMBER;
     l_item_repair_edq_multiple     NUMBER;
     l_item_newbuy_edq_multiple     NUMBER;
  BEGIN
    SELECT excess_service_level,
           repair_service_level,
           newbuy_service_level,
           excess_edq_Factor,
           repair_edq_Factor,
           newbuy_edq_Factor,
           edq_multiple
    INTO   l_excess_Service_level,
           l_repair_Service_level,
           l_newbuy_Service_level,
           l_excess_edq_factor,
           l_repair_edq_Factor,
           l_newbuy_edq_Factor,
           l_edq_multiple
    FROM csp_planning_parameters cpp
    WHERE organization_id = p_organization_id
    and cpp.organization_type = 'W';


      BEGIN
        SELECT excess_service_level,
               repair_service_level,
               newbuy_service_level,
               excess_edq_factor,
               repair_edq_factor,
               newbuy_edq_factor,
               excess_edq_multiple,
               repair_edq_multiple,
               newbuy_edq_multiple
        INTO l_item_excess_Service_level,
             l_item_repair_Service_level,
             l_item_newbuy_service_level,
             l_item_excess_edq_factor,
             l_item_repair_edq_factor,
             l_item_newbuy_edq_factor,
             l_item_excess_Edq_multiple,
             l_item_repair_edq_multiple,
             l_item_newbuy_edq_multiple
        FROM csp_item_pl_params
        WHERE organization_id = p_organization_id
        AND inventory_item_id = p_inventory_item_id;

        IF ((nvl(l_item_excess_Service_level, nvl(l_excess_service_level, 0)) <> nvl(p_excess_service_level, 0)) OR
           (nvl(l_item_repair_Service_level, nvl(l_repair_service_level, 0)) <> nvl(p_repair_service_level, 0)) OR
           (nvl(l_item_newbuy_service_level, nvl(l_newbuy_service_level, 0)) <> nvl(p_newbuy_service_level, 0)) OR
           (nvl(l_item_excess_edq_factor, nvl(l_excess_edq_factor, 0)) <> nvl(p_excess_edq_factor, 0)) OR
           (nvl(l_item_repair_edq_factor, nvl(l_repair_edq_Factor, 0)) <> nvl(p_repair_edq_factor, 0)) OR
           (nvl(l_item_newbuy_edq_Factor, nvl(l_newbuy_edq_Factor,0)) <> nvl(p_newbuy_edq_factor,0)) OR
           (nvl(l_item_excess_Edq_multiple, nvl(l_edq_multiple, 0)) <> nvl(p_excess_edq_multiple, 0)) OR
           (nvl(l_item_repair_edq_multiple, nvl(l_edq_multiple, 0)) <> nvl(p_repair_edq_multiple, 0)) OR
           (nvl(l_item_newbuy_edq_multiple, nvl(l_edq_multiple, 0)) <> nvl(p_newbuy_edq_multiple, 0))) THEN
          UPDATE csp_item_pl_params
          SET excess_service_level = decode(p_excess_service_level, nvl(l_item_excess_Service_level, l_excess_service_level), excess_service_level, p_excess_service_level),
              repair_service_level = decode(p_repair_service_level, nvl(l_item_repair_Service_level, l_repair_service_level), repair_service_level, p_repair_service_level),
              newbuy_service_level = decode(p_newbuy_service_level, nvl(l_item_newbuy_service_level, l_newbuy_service_level), newbuy_service_level, p_newbuy_service_level),
              excess_edq_factor = decode(p_excess_edq_factor, nvl(l_item_excess_edq_factor, l_excess_edq_factor), excess_edq_factor, p_excess_edq_factor),
              repair_edq_factor = decode(p_repair_edq_factor, nvl(l_item_repair_edq_factor, l_repair_edq_factor), repair_edq_factor, p_repair_edq_factor),
              newbuy_edq_factor = decode(p_newbuy_edq_factor, nvl(l_item_newbuy_edq_factor, l_newbuy_edq_factor), newbuy_edq_factor, p_newbuy_edq_factor),
              excess_edq_multiple = decode(p_excess_edq_multiple, nvl(l_item_excess_Edq_multiple, l_edq_multiple), excess_edq_multiple, p_excess_edq_multiple),
              repair_edq_multiple = decode(p_repair_edq_multiple, nvl(l_item_repair_edq_multiple, l_edq_multiple), repair_edq_multiple, p_repair_edq_multiple),
              newbuy_edq_multiple = decode(p_newbuy_edq_multiple, nvl(l_item_newbuy_edq_multiple, l_edq_multiple), newbuy_edq_multiple, p_newbuy_edq_multiple),
              last_updated_by = fnd_global.user_id,
              last_update_date = sysdate,
              last_update_login = fnd_global.login_id
          WHERE organization_id = p_organization_id
          AND inventory_item_id = p_inventory_item_id;

          csp_plan_details_pkg.reorders(p_organization_id,p_inventory_item_id);

        END IF;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          IF ((nvl(l_excess_service_level, 0) <> nvl(p_excess_service_level, 0)) OR
             (nvl(l_repair_service_level, 0) <> nvl(p_repair_service_level, 0)) OR
             (nvl(l_newbuy_service_level, 0) <> nvl(p_newbuy_service_level, 0)) OR
             (nvl(l_excess_edq_factor, 0) <> nvl(p_excess_edq_factor, 0)) OR
             (nvl(l_repair_edq_Factor, 0) <> nvl(p_repair_edq_factor, 0)) OR
             (nvl(l_newbuy_edq_Factor,0) <> nvl(p_newbuy_edq_factor,0)) OR
             (nvl(l_edq_multiple, 0) <> nvl(p_excess_edq_multiple, 0)) OR
             (nvl(l_edq_multiple, 0) <> nvl(p_repair_edq_multiple, 0)) OR
             (nvl(l_edq_multiple, 0) <> nvl(p_newbuy_edq_multiple, 0))) THEN
            SELECT csp_item_pl_params_s1.nextval
            INTO l_item_pl_params_s
            FROM dual;

            INSERT INTO csp_item_pl_params(ITEM_PL_PARAMS_ID,
              ORGANIZATION_ID,
              INVENTORY_ITEM_ID,
              CREATED_BY,
              CREATION_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATE_LOGIN,
              EXCESS_SERVICE_LEVEL,
              REPAIR_SERVICE_LEVEL,
              NEWBUY_SERVICE_LEVEL,
              EXCESS_EDQ_FACTOR,
              REPAIR_EDQ_FACTOR,
              NEWBUY_EDQ_FACTOR,
              EXCESS_EDQ_MULTIPLE,
              REPAIR_EDQ_MULTIPLE,
              NEWBUY_EDQ_MULTIPLE)
             SELECT
               l_item_pl_params_s,
               p_organization_id,
               p_inventory_item_id,
               fnd_global.user_id created_by,
               sysdate creation_date,
               fnd_global.user_id last_updated_by,
               sysdate last_update_Date,
               fnd_global.login_id last_update_login,
               decode(nvl(p_excess_service_level, 0), nvl(cpp.excess_service_level, 0), null, p_excess_service_level) excess_Service_level,
               decode(p_repair_service_level, cpp.repair_service_level, null, p_repair_service_level) repair_Service_level,
               decode(p_newbuy_service_level, cpp.newbuy_service_level, null, p_newbuy_service_level) newbuy_service_level,
               decode(p_excess_edq_factor, cpp.excess_edq_factor, null, p_excess_edq_Factor) excess_edq_Factor,
               decode(p_repair_edq_factor, cpp.repair_edq_factor, null, p_repair_edq_Factor) repair_edq_Factor,
               decode(p_newbuy_edq_factor, cpp.newbuy_edq_factor, null, p_newbuy_edq_Factor) newbuy_edq_Factor,
               decode(p_excess_edq_multiple, cpp.edq_multiple, null, p_excess_edq_multiple) excess_Edq_multiple,
               decode(p_repair_edq_multiple, cpp.edq_multiple, null, p_repair_edq_multiple) repair_edq_multiple,
               decode(p_newbuy_edq_multiple, cpp.edq_multiple, null, p_newbuy_edq_multiple) newbuy_edq_multiple
             FROM csp_planning_parameters cpp
             WHERE cpp.organization_id = p_organization_id
             AND cpp.organization_type = 'W';

             csp_plan_details_pkg.reorders(p_organization_id,p_inventory_item_id);

          END IF;

      END;


 /*     MERGE INTO CSP_ITEM_PL_PARAMS cipp
      USING CSP_PLANNING_PARAMETERS cpp
      ON (cipp.organization_id = p_organization_id
          AND cipp.inventory_item_id = p_inventory_item_id)
      WHEN MATCHED THEN
      UPDATE SET cipp.excess_service_level = decode(p_excess_service_level, cpp.excess_service_level, FND_API.G_MISS_NUM, p_excess_service_level),
                 cipp.repair_service_level = decode(p_repair_service_level, cpp.repair_service_level, FND_API.G_MISS_NUM, p_repair_service_level)
      WHEN NOT MATCHED THEN

    */
--    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      null;
  END;

END;

/
