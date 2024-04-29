--------------------------------------------------------
--  DDL for Package Body JE_ES_MOD_LE_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JE_ES_MOD_LE_UPDATE" AS
/* $Header: jeesmodb.pls 120.2 2006/11/03 08:23:34 anvijaya noship $ */

PROCEDURE update_main IS
l_org_id  NUMBER(15);
l_return_status  VARCHAR2(50);
l_msg_count  NUMBER(15);
l_msg_data  VARCHAR2(50);
l_le_info  NUMBER(15);

CURSOR upgrade_cur IS
   SELECT DISTINCT org_id
   FROM je_es_modelo_190_all
   WHERE legal_entity_id IS NULL
   AND org_id IS NOT NULL;

BEGIN

  OPEN upgrade_cur;

  LOOP
          FETCH upgrade_cur INTO l_org_id;
          EXIT WHEN upgrade_cur%NOTFOUND;

l_le_info :=XLE_UTILITIES_GRP.Get_DefaultLegalContext_OU(l_org_id);

/*XLE_UPGRADE_UTILS.Get_default_legal_context ( l_return_status,
                                                        l_msg_count,
                                        l_msg_data,
                                                l_org_id,
                                                l_le_info );
*/
         IF NVL(l_return_status, 'ZZZZ') <> 'E' THEN
           IF l_le_info IS NOT NULL THEN
                UPDATE je_es_modelo_190_all
                SET legal_entity_id = l_le_info
                WHERE org_id = l_org_id
                AND legal_entity_id IS NULL;

           END IF;

         END IF;

  END LOOP;

  CLOSE upgrade_cur;

  EXCEPTION
           WHEN OTHERS THEN null;


END;
END je_es_mod_le_update;

/
