--------------------------------------------------------
--  DDL for Package Body EGO_IMPORT_BATCH_PURGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_IMPORT_BATCH_PURGE_PKG" as
/* $Header: EGOIPURB.pls 120.0.12010000.10 2010/04/06 14:16:06 naaddepa noship $ */

-- ****************************************************************** --
--  API name    : Ego_import_batch_purge_pkg                          --
--  Type        : Private                                             --
--  Pre-reqs    : None.                                               --
--  Parameters  :                                                     --
--       IN     :                                                     --
--                p_batch_id                 NUMBER   Required        --
--                p_purge_criteria           varchar2                 --
--
--       OUT    : retcode                    VARCHAR2(1)              --
--                error_buf                  VARCHAR2(30)             --
--  Version     :                                                     --
--                Current version       1.0                           --
--                Initial version       1.0                           --
--                                                                    --
--  Notes       :                                                      --

-- ****************************************************************** --

CURSOR l_item_list_c(batch_id NUMBER) IS

SELECT Ego_item_list_inf (set_process_id, organization_id,
                   ORGANIZATION_CODE, REQUEST_ID,
                   INVENTORY_ITEM_ID, item_number,
    BUNDLE_ID,
    status ,
    isinbill,
    isincomp ,
    isinsubcomp
)
  FROM

(SELECT
    set_process_id,
    organization_id,
    ORGANIZATION_CODE,
    REQUEST_ID,
    INVENTORY_ITEM_ID,
    item_number,
    BUNDLE_ID,
    COALESCE -- search for failures
        (
          ( -- Looking for failure rows in MTL_SYSTEM_ITEMS_INTERFACE
            SELECT 'PARTIAL'
            FROM MTL_SYSTEM_ITEMS_INTERFACE MSII
            WHERE
                ( MSII.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
                OR  (   MSII.ITEM_NUMBER = I.ITEM_NUMBER
                    AND (
                        MSII.INVENTORY_ITEM_ID IS NULL
                        OR I.INVENTORY_ITEM_ID IS NULL
                        )
                    )
                )
              AND MSII.SET_PROCESS_ID = I.SET_PROCESS_ID
              AND ( MSII.ORGANIZATION_ID = I.ORGANIZATION_ID
                    OR ( MSII.ORGANIZATION_CODE = I.ORGANIZATION_CODE
                         AND (MSII.ORGANIZATION_CODE IS NULL OR I.ORGANIZATION_CODE IS NULL )
                       )
                  )
            AND ( (MSII.PROCESS_FLAG in (3,6) AND I.PROCESS_FLAG = 7) OR
                  (MSII.PROCESS_FLAG = 7 AND I.PROCESS_FLAG <> 7)
                )
              AND MSII.REQUEST_ID      = I.REQUEST_ID
              AND ROWNUM = 1
            )
         ,
          ( -- Looking for failure rows in MTL_ITEM_REVISIONS_INTERFACE
            SELECT 'PARTIAL'
            FROM MTL_ITEM_REVISIONS_INTERFACE MIRI
            WHERE
                ( MIRI.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
                OR  (   MIRI.ITEM_NUMBER = I.ITEM_NUMBER
                    AND (
                        MIRI.INVENTORY_ITEM_ID IS NULL
                        OR I.INVENTORY_ITEM_ID IS NULL
                        )
                    )
                )
              AND MIRI.SET_PROCESS_ID = I.SET_PROCESS_ID
              AND ( MIRI.ORGANIZATION_ID = I.ORGANIZATION_ID
                    OR ( MIRI.ORGANIZATION_CODE = I.ORGANIZATION_CODE
                         AND (MIRI.ORGANIZATION_CODE IS NULL OR I.ORGANIZATION_CODE IS NULL )
                       )
                  )
            AND ( (MIRI.PROCESS_FLAG in (3,6) AND I.PROCESS_FLAG = 7) OR
                  (MIRI.PROCESS_FLAG = 7 AND I.PROCESS_FLAG <> 7)
                )
              AND MIRI.REQUEST_ID      = I.REQUEST_ID
              AND ROWNUM = 1
            )
        ,
            ( -- Looking for failure rows in EGO_ITEM_PEOPLE_INTF
            SELECT 'PARTIAL'
            FROM EGO_ITEM_PEOPLE_INTF EIPI
            WHERE
                ( EIPI.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
                OR  (   EIPI.ITEM_NUMBER = I.ITEM_NUMBER
                    AND (
                        EIPI.INVENTORY_ITEM_ID IS NULL
                        OR I.INVENTORY_ITEM_ID IS NULL
                        )
                    )
                )
              AND EIPI.DATA_SET_ID = I.SET_PROCESS_ID
              AND ( EIPI.ORGANIZATION_ID = I.ORGANIZATION_ID
                    OR ( EIPI.ORGANIZATION_CODE = I.ORGANIZATION_CODE
                         AND (EIPI.ORGANIZATION_CODE IS NULL OR I.ORGANIZATION_CODE IS NULL )
                       )
                  )
              AND ( (EIPI.PROCESS_STATUS in (3,6) AND I.PROCESS_FLAG = 7) OR
                    (EIPI.PROCESS_STATUS = 4 AND I.PROCESS_FLAG <> 7)
                  )
              AND EIPI.REQUEST_ID      = I.REQUEST_ID
              AND ROWNUM = 1
            )
        ,
            ( -- Looking for failure rows in MTL_ITEM_CATEGORIES_INTERFACE
            SELECT 'PARTIAL'
            FROM MTL_ITEM_CATEGORIES_INTERFACE MICI
            WHERE
                ( MICI.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
                OR  (   MICI.ITEM_NUMBER = I.ITEM_NUMBER
                    AND (
                        MICI.INVENTORY_ITEM_ID IS NULL
                        OR I.INVENTORY_ITEM_ID IS NULL
                        )
                    )
                )
              AND MICI.SET_PROCESS_ID = I.SET_PROCESS_ID
              AND ( MICI.ORGANIZATION_ID = I.ORGANIZATION_ID
                    OR ( MICI.ORGANIZATION_CODE = I.ORGANIZATION_CODE
                         AND (MICI.ORGANIZATION_CODE IS NULL OR I.ORGANIZATION_CODE IS NULL )
                       )
                  )
              AND ( (MICI.PROCESS_FLAG in (3,6) AND I.PROCESS_FLAG = 7) OR
                    (MICI.PROCESS_FLAG = 7 AND I.PROCESS_FLAG <> 7)
                  )
              AND MICI.REQUEST_ID      = I.REQUEST_ID
              AND Nvl(MICI.BUNDLE_ID,0)       = Nvl(I.BUNDLE_ID,0)
              AND ROWNUM = 1
            )
        ,
            ( -- Looking for failure rows in EGO_AML_INTF
            SELECT 'PARTIAL'
            FROM EGO_AML_INTF EAI
            WHERE
                ( EAI.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
                OR  (   EAI.ITEM_NUMBER = I.ITEM_NUMBER
                    AND (
                        EAI.INVENTORY_ITEM_ID IS NULL
                        OR I.INVENTORY_ITEM_ID IS NULL
                        )
                    )
                )
              AND EAI.DATA_SET_ID = I.SET_PROCESS_ID
              AND ( EAI.ORGANIZATION_ID = I.ORGANIZATION_ID
                    OR ( EAI.ORGANIZATION_CODE = I.ORGANIZATION_CODE
                         AND (EAI.ORGANIZATION_CODE IS NULL OR I.ORGANIZATION_CODE IS NULL )
                       )
                  )
            AND ( (EAI.PROCESS_FLAG in (3,6) AND I.PROCESS_FLAG = 7) OR
                  (EAI.PROCESS_FLAG = 7 AND I.PROCESS_FLAG <> 7)
                )
              AND EAI.REQUEST_ID      = I.REQUEST_ID
              AND ROWNUM = 1
            )
        ,
            ( -- Looking for failure rows in EGO_ITM_USR_ATTR_INTRFC
            SELECT 'PARTIAL'
            FROM EGO_ITM_USR_ATTR_INTRFC EIUAI
            WHERE
                ( EIUAI.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
                OR  (   EIUAI.ITEM_NUMBER = I.ITEM_NUMBER
                    AND (
                        EIUAI.INVENTORY_ITEM_ID IS NULL
                        OR I.INVENTORY_ITEM_ID IS NULL
                        )
                    )
                )
              AND EIUAI.DATA_SET_ID = I.SET_PROCESS_ID
              AND ( EIUAI.ORGANIZATION_ID = I.ORGANIZATION_ID
                    OR ( EIUAI.ORGANIZATION_CODE = I.ORGANIZATION_CODE
                         AND (EIUAI.ORGANIZATION_CODE IS NULL OR I.ORGANIZATION_CODE IS NULL )
                       )
                  )
              AND ( (EIUAI.PROCESS_STATUS in (3,6) AND I.PROCESS_FLAG = 7) OR
                    (EIUAI.PROCESS_STATUS = 4 AND I.PROCESS_FLAG <> 7)
                  )
              AND EIUAI.REQUEST_ID      = I.REQUEST_ID
              AND Nvl(EIUAI.BUNDLE_ID,0)       = Nvl(I.BUNDLE_ID,0)
              AND ROWNUM = 1
            )
        ,
         /* ( -- Looking for failure rows in EGO_ITEM_ASSOCIATIONS_INTF
            SELECT 'PARTIAL'
            FROM EGO_ITEM_ASSOCIATIONS_INTF EIAI
            WHERE
                ( EIAI.INVENTORY_ITEM_ID = I.INVENTORY_ITEM_ID
                OR  (   EIAI.ITEM_NUMBER = I.ITEM_NUMBER
                    AND (
                        EIAI.INVENTORY_ITEM_ID IS NULL
                        OR I.INVENTORY_ITEM_ID IS NULL
                        )
                    )
                )
              AND EIAI.BATCH_ID = I.SET_PROCESS_ID
              AND ( EIAI.ORGANIZATION_ID = I.ORGANIZATION_ID
                    OR ( EIAI.ORGANIZATION_CODE = I.ORGANIZATION_CODE
                         AND (EIAI.ORGANIZATION_CODE IS NULL OR I.ORGANIZATION_CODE IS NULL )
                       )
                  )
              AND ( (EIAI.PROCESS_FLAG in (3,6) AND I.PROCESS_FLAG = 7) OR
                    (EIAI.PROCESS_FLAG = 7 AND I.PROCESS_FLAG <> 7)
                  )
              AND EIAI.REQUEST_ID      = I.REQUEST_ID
              AND Nvl(EIAI.BUNDLE_ID,0)       = Nvl(I.BUNDLE_ID,0)
              AND ROWNUM = 1
            )
        ,  */
           DECODE(I.PROCESS_FLAG,7,'SUCCESS','ERROR')
    ) AS status,
    0 isinbill,
    0 isincomp,
    0 isinsubcomp

FROM ( SELECT DISTINCT set_process_id, organization_id, ORGANIZATION_CODE, REQUEST_ID, INVENTORY_ITEM_ID, item_number, BUNDLE_ID ,PROCESS_FLAG
         FROM MTL_SYSTEM_ITEMS_INTERFACE
        WHERE PROCESS_FLAG IN (3,6,7)

       UNION

       SELECT DISTINCT set_process_id, organization_id, ORGANIZATION_CODE, REQUEST_ID, INVENTORY_ITEM_ID, item_number, null BUNDLE_ID ,PROCESS_FLAG
         FROM MTL_ITEM_REVISIONS_INTERFACE
        WHERE PROCESS_FLAG IN (3,6,7)

       UNION

        SELECT DISTINCT DATA_SET_ID set_process_id, organization_id, ORGANIZATION_CODE, REQUEST_ID, INVENTORY_ITEM_ID, item_number, null BUNDLE_ID , Decode ( PROCESS_STATUS,4,7,PROCESS_STATUS) PROCESS_FLAG
         FROM EGO_ITEM_PEOPLE_INTF
        WHERE PROCESS_STATUS IN (3,6,4)

       UNION

        SELECT DISTINCT set_process_id , organization_id, ORGANIZATION_CODE, REQUEST_ID, INVENTORY_ITEM_ID, item_number, BUNDLE_ID, PROCESS_FLAG
         FROM MTL_ITEM_CATEGORIES_INTERFACE
        WHERE PROCESS_FLAG IN (3,6,7)

       UNION

        SELECT DISTINCT DATA_SET_ID set_process_id, organization_id, ORGANIZATION_CODE, REQUEST_ID, INVENTORY_ITEM_ID, item_number, null BUNDLE_ID , PROCESS_FLAG
         FROM EGO_AML_INTF
        WHERE PROCESS_FLAG IN (3,6,7)

      /* UNION

        SELECT DISTINCT DATA_SET_ID set_process_id, organization_id, ORGANIZATION_CODE, REQUEST_ID, INVENTORY_ITEM_ID, item_number, BUNDLE_ID , Decode ( PROCESS_STATUS,4,7,PROCESS_STATUS) PROCESS_FLAG
         FROM EGO_ITM_USR_ATTR_INTRFC
        WHERE PROCESS_STATUS IN (3,6,4)*/

       UNION

        SELECT DISTINCT BATCH_ID set_process_id, organization_id, ORGANIZATION_CODE, REQUEST_ID, INVENTORY_ITEM_ID, item_number, BUNDLE_ID, PROCESS_FLAG
         FROM EGO_ITEM_ASSOCIATIONS_INTF
        WHERE PROCESS_FLAG IN (3,6,7)
     ) I
     WHERE set_process_id = batch_id );



TYPE cur_table IS TABLE OF Ego_item_list_inf;


PROCEDURE clear_items(p_purge_criteria IN VARCHAR2,
				            l_item_table IN cur_table) IS

l_item_entity_count NUMBER := 0;
l_item_rev_entity_count NUMBER := 0;
l_item_ppl_entity_count NUMBER := 0;
l_item_cat_entity_count NUMBER := 0;
l_item_asso_entity_count NUMBER := 0;

BEGIN

           fnd_file.put_line(fnd_file.Log,'Start deleting Item Entities.');


           FORALL item IN 1.. l_item_table.Count

                   DELETE FROM MTL_SYSTEM_ITEMS_INTERFACE
                   WHERE set_process_id = TREAT( l_item_table(item) AS Ego_item_list_inf).set_process_id
                    AND  ( organization_id = TREAT( l_item_table(item) AS Ego_item_list_inf).organization_id
                            OR ( organization_code = TREAT( l_item_table(item) AS Ego_item_list_inf).organization_code
                                 AND ( organization_code IS NULL OR TREAT( l_item_table(item) AS Ego_item_list_inf).organization_code IS NULL )
                               )
                         )
                    AND   REQUEST_ID = TREAT( l_item_table(item) AS Ego_item_list_inf).REQUEST_ID
                    AND ( INVENTORY_ITEM_ID = TREAT( l_item_table(item) AS Ego_item_list_inf).INVENTORY_ITEM_ID
                          OR  ( ITEM_NUMBER = TREAT( l_item_table(item) AS Ego_item_list_inf).ITEM_NUMBER
                                AND (   INVENTORY_ITEM_ID IS NULL OR TREAT( l_item_table(item) AS Ego_item_list_inf).INVENTORY_ITEM_ID IS NULL )
                              )
                        )
                    AND   Nvl(BUNDLE_ID,0)       = Nvl(TREAT( l_item_table(item) AS Ego_item_list_inf).BUNDLE_ID,0)
                    AND TREAT( l_item_table(item) AS Ego_item_list_inf).isinbill = 0 AND TREAT( l_item_table(item) AS Ego_item_list_inf).isincomp = 0 AND TREAT( l_item_table(item) AS Ego_item_list_inf).isinsubcomp = 0
                    AND TREAT( l_item_table(item) AS Ego_item_list_inf).status=p_purge_criteria;


           FOR i IN 1.. l_item_table.Count
           LOOP
             l_item_entity_count := l_item_entity_count + SQL%BULK_ROWCOUNT(i);

           END LOOP;

           fnd_file.put_line(fnd_file.Log,'No.of Item Entities deleted are '||l_item_entity_count);

           FORALL item IN l_item_table.first .. l_item_table.last

                  DELETE FROM MTL_ITEM_REVISIONS_INTERFACE
                  WHERE SET_PROCESS_ID = TREAT( l_item_table(item) AS Ego_item_list_inf).SET_PROCESS_ID
                  AND ( organization_id = TREAT( l_item_table(item) AS Ego_item_list_inf).organization_id
                         OR ( organization_code = TREAT( l_item_table(item) AS Ego_item_list_inf).organization_code
                              AND ( organization_code IS NULL OR TREAT( l_item_table(item) AS Ego_item_list_inf).organization_code IS NULL )
                            )
                      )
                  AND REQUEST_ID = TREAT( l_item_table(item) AS Ego_item_list_inf).REQUEST_ID
                  AND ( INVENTORY_ITEM_ID = TREAT( l_item_table(item) AS Ego_item_list_inf).INVENTORY_ITEM_ID
                        OR  ( ITEM_NUMBER = TREAT( l_item_table(item) AS Ego_item_list_inf).ITEM_NUMBER
                               AND ( INVENTORY_ITEM_ID IS NULL OR TREAT( l_item_table(item) AS Ego_item_list_inf).INVENTORY_ITEM_ID IS NULL )
                            )
                      )
                  AND TREAT( l_item_table(item) AS Ego_item_list_inf).isinbill = 0 AND TREAT( l_item_table(item) AS Ego_item_list_inf).isincomp = 0 AND TREAT( l_item_table(item) AS Ego_item_list_inf).isinsubcomp = 0
                  AND TREAT( l_item_table(item) AS Ego_item_list_inf).status=p_purge_criteria;



           FOR i IN l_item_table.first .. l_item_table.last
           LOOP
             l_item_rev_entity_count := l_item_rev_entity_count + SQL%BULK_ROWCOUNT(i);
           END LOOP;
           fnd_file.put_line(fnd_file.Log,'No.of Item Revision Entities deleted are '||l_item_rev_entity_count);





           FORALL item IN l_item_table.first .. l_item_table.last

                   DELETE FROM EGO_ITEM_PEOPLE_INTF
                   WHERE DATA_SET_ID = TREAT( l_item_table(item) AS Ego_item_list_inf).SET_PROCESS_ID
                   AND ( organization_id = TREAT( l_item_table(item) AS Ego_item_list_inf).organization_id
                         OR ( organization_code = TREAT( l_item_table(item) AS Ego_item_list_inf).organization_code
                               AND ( organization_code IS NULL OR TREAT( l_item_table(item) AS Ego_item_list_inf).organization_code IS NULL )
                            )
                       )
                   AND REQUEST_ID = TREAT( l_item_table(item) AS Ego_item_list_inf).REQUEST_ID
                   AND ( INVENTORY_ITEM_ID = TREAT( l_item_table(item) AS Ego_item_list_inf).INVENTORY_ITEM_ID
                         OR  ( ITEM_NUMBER = TREAT( l_item_table(item) AS Ego_item_list_inf).ITEM_NUMBER
                               AND (   INVENTORY_ITEM_ID IS NULL OR TREAT( l_item_table(item) AS Ego_item_list_inf).INVENTORY_ITEM_ID IS NULL )
                             )
                       )
                   AND TREAT( l_item_table(item) AS Ego_item_list_inf).isinbill = 0 AND TREAT( l_item_table(item) AS Ego_item_list_inf).isincomp = 0 AND TREAT( l_item_table(item) AS Ego_item_list_inf).isinsubcomp = 0
                   AND TREAT( l_item_table(item) AS Ego_item_list_inf).status=p_purge_criteria;


           FOR i IN l_item_table.first .. l_item_table.last
           LOOP
              l_item_ppl_entity_count := l_item_ppl_entity_count + SQL%BULK_ROWCOUNT(i);
           END LOOP;
           fnd_file.put_line(fnd_file.Log,'No.of Item People deleted are '||l_item_ppl_entity_count);


            FORALL item IN l_item_table.first .. l_item_table.last

                   DELETE FROM MTL_ITEM_CATEGORIES_INTERFACE
                   WHERE SET_PROCESS_ID = TREAT( l_item_table(item) AS Ego_item_list_inf).SET_PROCESS_ID
                   AND ( organization_id = TREAT( l_item_table(item) AS Ego_item_list_inf).organization_id
                         OR ( organization_code = TREAT( l_item_table(item) AS Ego_item_list_inf).organization_code
                              AND ( organization_code IS NULL OR TREAT( l_item_table(item) AS Ego_item_list_inf).organization_code IS NULL )
                            )
                       )
                   AND REQUEST_ID = TREAT( l_item_table(item) AS Ego_item_list_inf).REQUEST_ID
                   AND ( INVENTORY_ITEM_ID = TREAT( l_item_table(item) AS Ego_item_list_inf).INVENTORY_ITEM_ID
                         OR ( ITEM_NUMBER = TREAT( l_item_table(item) AS Ego_item_list_inf).ITEM_NUMBER
                              AND (   INVENTORY_ITEM_ID IS NULL OR TREAT( l_item_table(item) AS Ego_item_list_inf).INVENTORY_ITEM_ID IS NULL )
                            )
                       )
                   AND Nvl(BUNDLE_ID,0) = Nvl(TREAT( l_item_table(item) AS Ego_item_list_inf).BUNDLE_ID,0)
                   AND TREAT( l_item_table(item) AS Ego_item_list_inf).isinbill = 0 AND TREAT( l_item_table(item) AS Ego_item_list_inf).isincomp = 0 AND TREAT( l_item_table(item) AS Ego_item_list_inf).isinsubcomp = 0
                   AND TREAT( l_item_table(item) AS Ego_item_list_inf).status=p_purge_criteria;



           FOR i IN l_item_table.first .. l_item_table.last
           LOOP
             l_item_cat_entity_count := l_item_cat_entity_count + SQL%BULK_ROWCOUNT(i);
           END LOOP;
           fnd_file.put_line(fnd_file.Log,'No.of Item Categories deleted are '||l_item_cat_entity_count);



            FORALL item IN l_item_table.first .. l_item_table.last

                   DELETE FROM EGO_AML_INTF
                   WHERE DATA_SET_ID = TREAT( l_item_table(item) AS Ego_item_list_inf).SET_PROCESS_ID
                   AND ( organization_id = TREAT( l_item_table(item) AS Ego_item_list_inf).organization_id
                         OR ( organization_code = TREAT( l_item_table(item) AS Ego_item_list_inf).organization_code
                               AND ( organization_code IS NULL OR TREAT( l_item_table(item) AS Ego_item_list_inf).organization_code IS NULL )
                            )
                       )
                   AND REQUEST_ID = TREAT( l_item_table(item) AS Ego_item_list_inf).REQUEST_ID
                   AND ( INVENTORY_ITEM_ID = TREAT( l_item_table(item) AS Ego_item_list_inf).INVENTORY_ITEM_ID
                         OR  ( ITEM_NUMBER = TREAT( l_item_table(item) AS Ego_item_list_inf).ITEM_NUMBER
                               AND (   INVENTORY_ITEM_ID IS NULL OR TREAT( l_item_table(item) AS Ego_item_list_inf).INVENTORY_ITEM_ID IS NULL )
                             )
                       )
                   AND TREAT( l_item_table(item) AS Ego_item_list_inf).isinbill = 0 AND TREAT( l_item_table(item) AS Ego_item_list_inf).isincomp = 0 AND TREAT( l_item_table(item) AS Ego_item_list_inf).isinsubcomp = 0
                   AND TREAT( l_item_table(item) AS Ego_item_list_inf).status=p_purge_criteria;



           FORALL item IN l_item_table.first .. l_item_table.last

                   DELETE FROM EGO_ITM_USR_ATTR_INTRFC
                   WHERE DATA_SET_ID = TREAT( l_item_table(item) AS Ego_item_list_inf).SET_PROCESS_ID
                   AND ( organization_id = TREAT( l_item_table(item) AS Ego_item_list_inf).organization_id
                          OR ( organization_code = TREAT( l_item_table(item) AS Ego_item_list_inf).organization_code
                               AND ( organization_code IS NULL OR TREAT( l_item_table(item) AS Ego_item_list_inf).organization_code IS NULL )
                             )
                       )
                   AND REQUEST_ID = TREAT( l_item_table(item) AS Ego_item_list_inf).REQUEST_ID
                   AND ( INVENTORY_ITEM_ID = TREAT( l_item_table(item) AS Ego_item_list_inf).INVENTORY_ITEM_ID
                         OR ( ITEM_NUMBER = TREAT( l_item_table(item) AS Ego_item_list_inf).ITEM_NUMBER
                              AND ( INVENTORY_ITEM_ID IS NULL OR TREAT( l_item_table(item) AS Ego_item_list_inf).INVENTORY_ITEM_ID IS NULL )
                            )
                        )
                   AND Nvl(BUNDLE_ID,0) = Nvl(TREAT( l_item_table(item) AS Ego_item_list_inf).BUNDLE_ID,0)
                   AND TREAT( l_item_table(item) AS Ego_item_list_inf).isinbill = 0 AND TREAT( l_item_table(item) AS Ego_item_list_inf).isincomp = 0 AND TREAT( l_item_table(item) AS Ego_item_list_inf).isinsubcomp = 0
                   AND TREAT( l_item_table(item) AS Ego_item_list_inf).status=p_purge_criteria;


          FORALL item IN l_item_table.first .. l_item_table.last

                   DELETE FROM EGO_ITEM_ASSOCIATIONS_INTF EIAI
                   WHERE TREAT( l_item_table(item) AS Ego_item_list_inf).status=p_purge_criteria
                   AND BATCH_ID  =  TREAT( l_item_table(item) AS Ego_item_list_inf).SET_PROCESS_ID
                   AND ( organization_id = TREAT( l_item_table(item) AS Ego_item_list_inf).organization_id
                          OR ( ORGANIZATION_CODE = TREAT( l_item_table(item) AS Ego_item_list_inf).ORGANIZATION_CODE
                               AND (ORGANIZATION_CODE IS NULL OR TREAT( l_item_table(item) AS Ego_item_list_inf).ORGANIZATION_CODE IS NULL)
                             )
                       )
                   AND nvl(REQUEST_ID,0) = TREAT( l_item_table(item) AS Ego_item_list_inf).REQUEST_ID
                   AND ( INVENTORY_ITEM_ID = TREAT( l_item_table(item) AS Ego_item_list_inf).INVENTORY_ITEM_ID
                         OR  ( ITEM_NUMBER = TREAT( l_item_table(item) AS Ego_item_list_inf).ITEM_NUMBER
                               AND (   INVENTORY_ITEM_ID IS NULL OR TREAT( l_item_table(item) AS Ego_item_list_inf).INVENTORY_ITEM_ID IS NULL )
                             )
                       )
                   AND TREAT( l_item_table(item) AS Ego_item_list_inf).isinbill = 0 AND TREAT( l_item_table(item) AS Ego_item_list_inf).isincomp = 0 AND TREAT( l_item_table(item) AS Ego_item_list_inf).isinsubcomp = 0
                   AND Nvl(BUNDLE_ID,0) = Nvl(TREAT( l_item_table(item) AS Ego_item_list_inf).BUNDLE_ID,0);



           FOR i IN l_item_table.first .. l_item_table.last
           LOOP
             l_item_asso_entity_count := l_item_asso_entity_count + SQL%BULK_ROWCOUNT(i);
           END LOOP;
           fnd_file.put_line(fnd_file.Log,'No.of Item Associations deleted are '||l_item_asso_entity_count);



END;


PROCEDURE batch_purge(err_buff OUT   NOCOPY  VARCHAR2,
                ret_code OUT   NOCOPY  VARCHAR2,
                p_batch_id IN NUMBER,
                p_purge_criteria IN varchar2) IS

 l_batch_type VARCHAR2(50);
 stm_num NUMBER := 0;

BEGIN
    stm_num :=1;



    SELECT BATCH_TYPE INTO l_batch_type FROM EGO_IMPORT_BATCHES_B WHERE BATCH_ID=p_batch_id;

    fnd_file.put_line(fnd_file.Log,'Purge Program run for Batch ID:'||p_batch_id || '.');
    fnd_file.put_line(fnd_file.Log,'Batch type is '||l_batch_type||'.');
    fnd_file.put_line(fnd_file.Log,'Purge Criteria is '|| p_purge_criteria||'.');
    fnd_file.put_line(fnd_file.Log,' ');


   IF p_purge_criteria='ALL' THEN

        stm_num :=2;

        Purge_All(p_batch_id,ret_code,err_buff);

   ELSIF l_batch_type='EGO_ITEM' AND p_purge_criteria IS NOT NULL THEN

        stm_num :=3;

        Item_Purge(p_batch_id,p_purge_criteria,ret_code,err_buff);

   ELSIF l_batch_type='BOM_STRUCTURE' AND p_purge_criteria IS NOT NULL THEN

        stm_num :=4;

        Structure_Purge(p_batch_id,p_purge_criteria,ret_code,err_buff);

   END IF;

EXCEPTION

  WHEN OTHERS THEN
      err_buff := 'batch_purge: stm_num = '||stm_num||'. Error msg: '||SUBSTR(SQLERRM, 1, 200);
      ret_code := 2;--FND_API.G_RET_STS_ERROR;
      fnd_file.put_line(fnd_file.Log,err_buff);

END batch_purge;


--Item Purge Procedure

PROCEDURE Item_Purge(p_batch_id IN NUMBER,p_purge_criteria IN VARCHAR2,ret_code OUT NOCOPY VARCHAR2, err_buff OUT NOCOPY  VARCHAR2) IS

l_item_table cur_table;

item_num NUMBER:=0;

stm_num NUMBER := 0;

BEGIN

 stm_num := 1;

 OPEN l_item_list_c(p_batch_id);
 FETCH l_item_list_c BULK COLLECT INTO l_item_table;
 item_num:=l_item_list_c%ROWCOUNT;
 CLOSE l_item_list_c;

 stm_num := 2;
   IF item_num>0 THEN

      clear_items(p_purge_criteria,l_item_table);

      COMMIT;
   ELSE
      fnd_file.put_line(fnd_file.Log,'No.of Item Entities deleted are 0');
      fnd_file.put_line(fnd_file.Log,'No.of Item Revision Entities deleted are 0');
      fnd_file.put_line(fnd_file.Log,'No.of Item People deleted are 0');
      fnd_file.put_line(fnd_file.Log,'No.of Item Categories deleted are 0');
      fnd_file.put_line(fnd_file.Log,'No.of Item Associations deleted are 0');
   END IF;

EXCEPTION

   WHEN OTHERS THEN
      err_buff := 'Item_Purge: stm_num = '||stm_num||'. Error msg: '||SUBSTR(SQLERRM, 1, 200);
      ret_code := 2;--FND_API.G_RET_STS_ERROR;
      fnd_file.put_line(fnd_file.Log,err_buff);



END Item_Purge;


--structure purge procedure

PROCEDURE Structure_Purge(p_batch_id IN NUMBER, p_purge_criteria IN VARCHAR2,ret_code OUT NOCOPY VARCHAR2,err_buff OUT NOCOPY  VARCHAR2) IS

l_batch_id NUMBER:= p_batch_id;
l_purge_criteria VARCHAR2(20):=p_purge_criteria;


l_item_table cur_table;
item_num NUMBER;

l_bom_entity_count NUMBER :=0;
l_comp_entity_count NUMBER :=0;
l_sub_comp_entity_count NUMBER :=0;
l_ref_comp_entity_count NUMBER :=0;
l_op_comp_entity_count NUMBER :=0;

l_bom_op_route_entity_count NUMBER :=0;
l_bom_op_seq_entity_count NUMBER := 0;
l_bom_op_res_entity_count NUMBER := 0;
l_bom_sub_op_res_entity_count NUMBER := 0;


--cursor for list of structures in given batch

CURSOR l_struct_list_c(batch_id_struct NUMBER,purge_criteria VARCHAR2)
IS
SELECT Ego_Structure_list_inf(
BATCH_ID,
ORGANIZATION_ID,
REQUEST_ID,
ASSEMBLY_ITEM_ID,
BILL_SEQUENCE_ID,
BUNDLE_ID,
ALTERNATE_BOM_DESIGNATOR ,
process_flag )
FROM
(
SELECT BATCH_ID,ORGANIZATION_ID,REQUEST_ID,ASSEMBLY_ITEM_ID,BILL_SEQUENCE_ID,BUNDLE_ID,ALTERNATE_BOM_DESIGNATOR,process_flag
FROM BOM_BILL_OF_MTLS_INTERFACE I
WHERE I.BATCH_ID =batch_id_struct
AND I.PROCESS_FLAG IN ( Decode(purge_criteria,'SUCCESS',7,'ERROR',3,-123456),  Decode(purge_criteria,'ERROR',6,-123456) ));


TYPE structure_table IS TABLE OF Ego_Structure_list_inf;
l_structure_table structure_table:=null;
str_num NUMBER;

stm_num NUMBER := 0;

--cursor for list of routings in given batch

CURSOR l_routing_list_c(batch_id_route NUMBER,purge_criteria VARCHAR2)IS

SELECT Ego_route_list_inf(
BATCH_ID,
ORGANIZATION_ID,
REQUEST_ID,
ASSEMBLY_ITEM_ID,
ROUTING_SEQUENCE_ID,
process_flag,
ALTERNATE_ROUTING_DESIGNATOR)
FROM
( SELECT BATCH_ID,ORGANIZATION_ID,REQUEST_ID,ASSEMBLY_ITEM_ID,ROUTING_SEQUENCE_ID,process_flag,ALTERNATE_ROUTING_DESIGNATOR
  FROM  bom_op_routings_interface I
  WHERE I.BATCH_ID =batch_id_route
  AND I.PROCESS_FLAG IN ( Decode(purge_criteria,'SUCCESS',7,'ERROR',3,-123456) , Decode(purge_criteria,'SUCCESS',7,'ERROR',6,-123456) )
);


TYPE routing_table IS TABLE OF Ego_route_list_inf;
l_routing_table routing_table:=null;
routing_num NUMBER := 0;


BEGIN

--deletion of bom records in Sructure batch
  stm_num := 1;

     OPEN l_struct_list_c(l_batch_id,l_purge_criteria);
     FETCH l_struct_list_c BULK COLLECT INTO l_structure_table;
     str_num:=l_struct_list_c%ROWCOUNT;
     CLOSE l_struct_list_c;



--Start deleting records from bom tables

     IF str_num >0 THEN

                fnd_file.put_line(fnd_file.Log,'Start deleting Structure Entities');

                --delete records from bom_sub_comps_interface
                stm_num := 2;

                FORALL comp IN l_structure_table.first .. l_structure_table.last

                       DELETE FROM bom_sub_comps_interface bsci
                       WHERE bsci.batch_id  = TREAT(l_structure_table(comp) AS Ego_Structure_list_inf).batch_id
                        AND  bsci.organization_id = TREAT(l_structure_table(comp) AS Ego_Structure_list_inf).organization_id
                        AND  Nvl(bsci.request_id,0) = Nvl(TREAT(l_structure_table(comp) AS Ego_Structure_list_inf).request_id,0)
                        AND ( bsci.bill_sequence_id = bill_sequence_id
                              OR ( bsci.ORGANIZATION_ID = TREAT(l_structure_table(comp) AS Ego_Structure_list_inf).organization_id AND
                                   bsci.ASSEMBLY_ITEM_ID = TREAT(l_structure_table(comp) AS Ego_Structure_list_inf).assembly_item_id AND
                                   Nvl(bsci.ALTERNATE_BOM_DESIGNATOR,0) = Nvl(TREAT(l_structure_table(comp) AS Ego_Structure_list_inf).ALTERNATE_BOM_DESIGNATOR,0)
                                   AND (bsci.bill_sequence_id IS NULL OR bill_sequence_id IS NULL )
                                 )
                            );


                  FOR i IN l_structure_table.first .. l_structure_table.last LOOP
                     l_sub_comp_entity_count := l_sub_comp_entity_count + SQL%BULK_ROWCOUNT(i);
                  END LOOP;


                --delete records from bom_ref_desgs_interface
                  stm_num := 3;

                FORALL comp IN l_structure_table.first .. l_structure_table.last

                      DELETE FROM bom_ref_desgs_interface brdi
                      WHERE brdi.batch_id  = TREAT(l_structure_table(comp) AS Ego_Structure_list_inf).batch_id
                       AND  brdi.organization_id = TREAT(l_structure_table(comp) AS Ego_Structure_list_inf).organization_id
                       AND  Nvl(brdi.request_id,0) = Nvl(TREAT(l_structure_table(comp) AS Ego_Structure_list_inf).request_id,0)
                       AND ( brdi.bill_sequence_id = bill_sequence_id
                             OR ( brdi.ORGANIZATION_ID = TREAT(l_structure_table(comp) AS Ego_Structure_list_inf).organization_id AND
                                  brdi.ASSEMBLY_ITEM_ID = TREAT(l_structure_table(comp) AS Ego_Structure_list_inf).assembly_item_id AND
                                  Nvl(brdi.ALTERNATE_BOM_DESIGNATOR,0) = Nvl(TREAT(l_structure_table(comp) AS Ego_Structure_list_inf).ALTERNATE_BOM_DESIGNATOR,0)
                                  AND (brdi.bill_sequence_id IS NULL OR bill_sequence_id IS NULL )
                                )
                           );


                  FOR i IN l_structure_table.first .. l_structure_table.last LOOP
                      l_ref_comp_entity_count := l_ref_comp_entity_count + SQL%BULK_ROWCOUNT(i);
                  END LOOP;



               --delete records from bom_cmp_usr_attr_interface
                  stm_num := 4;

               FORALL comp IN l_structure_table.first .. l_structure_table.last

                     DELETE FROM bom_cmp_usr_attr_interface bcuai
                     WHERE ( bcuai.batch_id  = TREAT(l_structure_table(comp) AS Ego_Structure_list_inf).batch_id OR bcuai.data_set_id = TREAT(l_structure_table(comp) AS Ego_Structure_list_inf).batch_id)
                      AND  bcuai.organization_id = TREAT(l_structure_table(comp) AS Ego_Structure_list_inf).organization_id
                      AND  Nvl(bcuai.request_id,0) = Nvl(TREAT(l_structure_table(comp) AS Ego_Structure_list_inf).request_id,0)
                      AND  bcuai.bill_sequence_id = bill_sequence_id;



               --delete records from bom_component_ops_interface
                  stm_num := 5;

               FORALL comp IN l_structure_table.first .. l_structure_table.last

                    DELETE FROM bom_component_ops_interface bcoi
                    WHERE bcoi.batch_id = TREAT(l_structure_table(comp) AS Ego_Structure_list_inf).batch_id
                      AND bcoi.organization_id = TREAT(l_structure_table(comp) AS Ego_Structure_list_inf).organization_id
                      AND Nvl(bcoi.request_id,0) = Nvl(TREAT(l_structure_table(comp) AS Ego_Structure_list_inf).request_id,0)
                      AND ( bcoi.bill_sequence_id = bill_sequence_id
                            OR ( bcoi.ORGANIZATION_ID = TREAT(l_structure_table(comp) AS Ego_Structure_list_inf).organization_id AND
                                 bcoi.ASSEMBLY_ITEM_ID = TREAT(l_structure_table(comp) AS Ego_Structure_list_inf).assembly_item_id AND
                                 Nvl(bcoi.ALTERNATE_BOM_DESIGNATOR,0) = Nvl(TREAT(l_structure_table(comp) AS Ego_Structure_list_inf).ALTERNATE_BOM_DESIGNATOR,0)
                                 AND (bcoi.bill_sequence_id IS NULL OR bill_sequence_id IS NULL )
                               )
                          );


                 FOR i IN l_structure_table.first .. l_structure_table.last LOOP
                       l_op_comp_entity_count := l_op_comp_entity_count + SQL%BULK_ROWCOUNT(i);
                 END LOOP;


               --delete records from bom_inventory_comps_interface
                  stm_num := 6;

               FORALL comp IN l_structure_table.first .. l_structure_table.last

                   DELETE FROM bom_inventory_comps_interface bici
                   WHERE bici.BATCH_ID = TREAT(l_structure_table(comp) AS Ego_Structure_list_inf).batch_id
                     AND bici.ORGANIZATION_ID = TREAT(l_structure_table(comp) AS Ego_Structure_list_inf).organization_id
                     AND Nvl(bici.REQUEST_ID,0) = Nvl(TREAT(l_structure_table(comp) AS Ego_Structure_list_inf).request_id,0)
                     AND Nvl(bici.BUNDLE_ID,0) = Nvl(TREAT(l_structure_table(comp) AS Ego_Structure_list_inf).bundle_id,0)
                     AND ( bici.bill_sequence_id = bill_sequence_id
                           OR (  bici.ORGANIZATION_ID = TREAT(l_structure_table(comp) AS Ego_Structure_list_inf).organization_id AND
                                 bici.ASSEMBLY_ITEM_ID = TREAT(l_structure_table(comp) AS Ego_Structure_list_inf).assembly_item_id AND
                                 Nvl(bici.ALTERNATE_BOM_DESIGNATOR,0) = Nvl(TREAT(l_structure_table(comp) AS Ego_Structure_list_inf).ALTERNATE_BOM_DESIGNATOR,0) AND
                                 (bici.bill_sequence_id IS NULL OR bill_sequence_id IS NULL )
                              )
                         );


                  FOR i IN l_structure_table.first .. l_structure_table.last LOOP
                     l_comp_entity_count := l_comp_entity_count + SQL%BULK_ROWCOUNT(i);
                  END LOOP;


               --delete record from bom_bill_of_mtls_interface
                 stm_num := 7;

               FORALL comp IN l_structure_table.first .. l_structure_table.last

                    DELETE FROM bom_bill_of_mtls_interface bbmi
                     WHERE bbmi.BATCH_ID = TREAT(l_structure_table(comp) AS Ego_Structure_list_inf).batch_id
                       AND bbmi.ORGANIZATION_ID = TREAT(l_structure_table(comp) AS Ego_Structure_list_inf).organization_id
                       AND Nvl(bbmi.REQUEST_ID,0) = Nvl(TREAT(l_structure_table(comp) AS Ego_Structure_list_inf).request_id,0)
                       AND Nvl(bbmi.BUNDLE_ID,0) = Nvl(TREAT(l_structure_table(comp) AS Ego_Structure_list_inf).bundle_id,0)
                       AND ( bbmi.BILL_SEQUENCE_ID = TREAT(l_structure_table(comp) AS Ego_Structure_list_inf).bill_sequence_id
                             OR ( bbmi.ORGANIZATION_ID = TREAT(l_structure_table(comp) AS Ego_Structure_list_inf).organization_id AND
                                  bbmi.ASSEMBLY_ITEM_ID = TREAT(l_structure_table(comp) AS Ego_Structure_list_inf).assembly_item_id AND
                                  nvl(bbmi.ALTERNATE_BOM_DESIGNATOR,0) = Nvl(TREAT(l_structure_table(comp) AS Ego_Structure_list_inf).ALTERNATE_BOM_DESIGNATOR,0) AND
                                  (bbmi.BILL_SEQUENCE_ID IS NULL OR TREAT(l_structure_table(comp) AS Ego_Structure_list_inf).bill_sequence_id IS NULL )
                                )
                           );


                 FOR i IN l_structure_table.first .. l_structure_table.last LOOP
                      l_bom_entity_count := l_bom_entity_count + SQL%BULK_ROWCOUNT(i);
                 END LOOP;

           COMMIT;

      END IF;


 fnd_file.put_line(fnd_file.Log,'No.of Structures deleted are '||l_bom_entity_count);
 fnd_file.put_line(fnd_file.Log,'No.of Components deleted are '||l_comp_entity_count);
 fnd_file.put_line(fnd_file.Log,'No.of Sub-components deleted are '||l_sub_comp_entity_count);
 fnd_file.put_line(fnd_file.Log,'No.of Ref-designators deleted are '||l_ref_comp_entity_count);
 fnd_file.put_line(fnd_file.Log,'No.of Component operations deleted are '||l_op_comp_entity_count);



--end deleting records from bom tables


--Start deleting data from routing tables



 OPEN l_routing_list_c(l_batch_id,l_purge_criteria);
 FETCH l_routing_list_c BULK COLLECT INTO l_routing_table;
 routing_num:=l_routing_list_c%ROWCOUNT;
 CLOSE l_routing_list_c;



  IF routing_num >0 THEN

             --delete records from bom_op_resources_interface
             stm_num := 8;

               fnd_file.put_line(fnd_file.Log,'Start deleting Routing Entities');


               FORALL op IN l_routing_table.first .. l_routing_table.last

                                          DELETE FROM bom_op_resources_interface bori
                                          WHERE bori.batch_id = TREAT(l_routing_table(op) AS Ego_route_list_inf).batch_id
                                          AND bori.organization_id = TREAT(l_routing_table(op) AS Ego_route_list_inf).organization_id
                                          AND bori.request_id = TREAT(l_routing_table(op) AS Ego_route_list_inf).request_id
                                          AND bori.assembly_item_id = TREAT(l_routing_table(op) AS Ego_route_list_inf).assembly_item_id
                                          AND ( bori.ROUTING_SEQUENCE_ID = TREAT(l_routing_table(op) AS Ego_route_list_inf).ROUTING_SEQUENCE_ID
                                                 OR ( bori.organization_id = TREAT(l_routing_table(op) AS Ego_route_list_inf).organization_id
                                                     AND bori.assembly_item_id = TREAT(l_routing_table(op) AS Ego_route_list_inf).assembly_item_id
                                                     AND Nvl(bori.ALTERNATE_ROUTING_DESIGNATOR,0) = Nvl(TREAT(l_routing_table(op) AS Ego_route_list_inf).alternate_routing_designator,0)
                                                     AND (bori.ROUTING_SEQUENCE_ID IS NULL OR TREAT(l_routing_table(op) AS Ego_route_list_inf).ROUTING_SEQUENCE_ID IS NULL)
                                                   )
                                               );

                     FOR i IN l_routing_table.first .. l_routing_table.last LOOP
                            l_bom_op_res_entity_count := l_bom_op_res_entity_count + SQL%BULK_ROWCOUNT(i);
                     END LOOP;


             --delete records from bom_sub_op_resources_interface
             stm_num := 9;

                 FORALL op IN l_routing_table.first .. l_routing_table.last

                                          DELETE FROM bom_sub_op_resources_interface bsr
                                          WHERE bsr.batch_id = TREAT(l_routing_table(op) AS Ego_route_list_inf).batch_id
                                          AND bsr.organization_id = TREAT(l_routing_table(op) AS Ego_route_list_inf).organization_id
                                          AND bsr.request_id = TREAT(l_routing_table(op) AS Ego_route_list_inf).request_id
                                          AND bsr.assembly_item_id = TREAT(l_routing_table(op) AS Ego_route_list_inf).assembly_item_id
                                          AND ( bsr.ROUTING_SEQUENCE_ID = TREAT(l_routing_table(op) AS Ego_route_list_inf).ROUTING_SEQUENCE_ID
                                               OR ( bsr.organization_id = TREAT(l_routing_table(op) AS Ego_route_list_inf).organization_id
                                                     AND bsr.assembly_item_id = TREAT(l_routing_table(op) AS Ego_route_list_inf).assembly_item_id
                                                     AND Nvl(bsr.ALTERNATE_ROUTING_DESIGNATOR,0) = Nvl(TREAT(l_routing_table(op) AS Ego_route_list_inf).alternate_routing_designator,0)
                                                     AND (bsr.ROUTING_SEQUENCE_ID IS NULL OR TREAT(l_routing_table(op) AS Ego_route_list_inf).ROUTING_SEQUENCE_ID IS NULL)
                                                   )
                                              );

                      FOR i IN l_routing_table.first .. l_routing_table.last LOOP
                             l_bom_sub_op_res_entity_count := l_bom_sub_op_res_entity_count + SQL%BULK_ROWCOUNT(i);
                      END LOOP;


                --delete records from bom_op_networks_interface
                stm_num := 10;

                         /* DELETE FROM bom_op_networks_interface boni
                           WHERE boni.batch_id = l_op_table(op).batch_id
                             AND boni.organization_id = l_op_table(op).organization_id
                             AND boni.request_id = l_op_table(op).request_id
                             AND boni.assembly_item_id = l_op_table(op).assembly_item_id;
                         */


                 --delete records from bom_op_sequences_interface
                stm_num := 11;

                   FORALL op IN l_routing_table.first .. l_routing_table.last

                                          DELETE FROM bom_op_sequences_interface bseq
                                          WHERE bseq.batch_id = TREAT(l_routing_table(op) AS Ego_route_list_inf).batch_id
                                          AND bseq.organization_id = TREAT(l_routing_table(op) AS Ego_route_list_inf).organization_id
                                          AND bseq.request_id = TREAT(l_routing_table(op) AS Ego_route_list_inf).request_id
                                          AND bseq.assembly_item_id = TREAT(l_routing_table(op) AS Ego_route_list_inf).assembly_item_id
                                          AND ( bseq.ROUTING_SEQUENCE_ID = TREAT(l_routing_table(op) AS Ego_route_list_inf).ROUTING_SEQUENCE_ID
                                                OR ( bseq.organization_id = TREAT(l_routing_table(op) AS Ego_route_list_inf).organization_id
                                                     AND bseq.assembly_item_id = TREAT(l_routing_table(op) AS Ego_route_list_inf).assembly_item_id
                                                     AND Nvl(bseq.ALTERNATE_ROUTING_DESIGNATOR,0) = Nvl(TREAT(l_routing_table(op) AS Ego_route_list_inf).alternate_routing_designator,0)
                                                     AND (bseq.ROUTING_SEQUENCE_ID IS NULL OR TREAT(l_routing_table(op) AS Ego_route_list_inf).ROUTING_SEQUENCE_ID IS NULL)
                                                   )
                                              );

                     FOR i IN l_routing_table.first .. l_routing_table.last LOOP
                        l_bom_op_seq_entity_count := l_bom_op_seq_entity_count + SQL%BULK_ROWCOUNT(i);
                     END LOOP;


                --delete records from bom_op_routings_interface
                stm_num := 12;

                   FORALL op IN l_routing_table.first .. l_routing_table.last

                                         DELETE FROM bom_op_routings_interface brou
                                         WHERE brou.batch_id =TREAT(l_routing_table(op) AS Ego_route_list_inf).batch_id
                                         AND brou.organization_id = TREAT(l_routing_table(op) AS Ego_route_list_inf).organization_id
                                         AND brou.request_id = TREAT(l_routing_table(op) AS Ego_route_list_inf).request_id
                                         AND brou.assembly_item_id = TREAT(l_routing_table(op) AS Ego_route_list_inf).assembly_item_id
                                         AND ( brou.ROUTING_SEQUENCE_ID = TREAT(l_routing_table(op) AS Ego_route_list_inf).ROUTING_SEQUENCE_ID
                                               OR ( brou.organization_id = TREAT(l_routing_table(op) AS Ego_route_list_inf).organization_id AND
                                                    brou.assembly_item_id = TREAT(l_routing_table(op) AS Ego_route_list_inf).assembly_item_id AND
                                                    Nvl(brou.ALTERNATE_ROUTING_DESIGNATOR,0) = Nvl(TREAT(l_routing_table(op) AS Ego_route_list_inf).alternate_routing_designator,0) AND
                                                    (brou.ROUTING_SEQUENCE_ID IS NULL OR TREAT(l_routing_table(op) AS Ego_route_list_inf).ROUTING_SEQUENCE_ID IS NULL )
                                                  )
                                             );

                          FOR i IN l_routing_table.first .. l_routing_table.last LOOP
                              l_bom_op_route_entity_count := l_bom_op_route_entity_count + SQL%BULK_ROWCOUNT(i);
                          END LOOP;


                     COMMIT;

  END IF;


 fnd_file.put_line(fnd_file.Log,'No.of Routings deleted are '||l_bom_op_route_entity_count);
 fnd_file.put_line(fnd_file.Log,'No.of Operation Resources deleted are '||l_bom_op_res_entity_count);
 fnd_file.put_line(fnd_file.Log,'No.of Sub-operation Resources deleted are '||l_bom_sub_op_res_entity_count);
 fnd_file.put_line(fnd_file.Log,'No.of Operation sequences deleted are '||l_bom_op_seq_entity_count);

--end delete routing tables




--deletion of items in Sructure batch

     stm_num := 13;

     OPEN l_item_list_c(l_batch_id);
     FETCH l_item_list_c BULK COLLECT INTO l_item_table;
     item_num:=l_item_list_c%ROWCOUNT;
     CLOSE l_item_list_c;

   IF item_num >0 THEN

           FOR item IN l_item_table.first .. l_item_table.last LOOP

                   SELECT Count(1) INTO l_item_table(item).isinbill FROM bom_bill_of_mtls_interface bbmi
                    WHERE bbmi.BATCH_ID = l_item_table(item).set_process_id
                    AND ( bbmi.ORGANIZATION_ID = l_item_table(item).organization_id
                          OR ( bbmi.ORGANIZATION_CODE = l_item_table(item).organization_code
                               AND ( bbmi.ORGANIZATION_CODE IS NULL OR l_item_table(item).organization_code IS NULL)
                             )
                        )
                    AND bbmi.ITEM_NUMBER = l_item_table(item).item_number;



                   SELECT Count(1) INTO l_item_table(item).isincomp FROM bom_inventory_comps_interface bici
                    WHERE bici.BATCH_ID = l_item_table(item).set_process_id
                    AND ( bici.ORGANIZATION_ID = l_item_table(item).organization_id
                          OR ( bici.ORGANIZATION_CODE = l_item_table(item).organization_code
                               AND ( bici.ORGANIZATION_CODE IS NULL OR l_item_table(item).organization_code IS NULL)
                             )
                        )
                    AND bici.COMPONENT_ITEM_NUMBER = l_item_table(item).item_number;



                   SELECT Count(1) INTO l_item_table(item).isinsubcomp FROM bom_sub_comps_interface bsci
                    WHERE bsci.BATCH_ID = l_item_table(item).set_process_id
                    AND ( bsci.ORGANIZATION_ID = l_item_table(item).organization_id
                          OR ( bsci.ORGANIZATION_CODE = l_item_table(item).organization_code
                               AND ( bsci.ORGANIZATION_CODE IS NULL OR l_item_table(item).organization_code IS NULL)
                             )
                        )
                    AND bsci.SUBSTITUTE_COMP_NUMBER = l_item_table(item).item_number;

           END LOOP;

           clear_items(l_purge_criteria, l_item_table);

           COMMIT;

  ELSE

      fnd_file.put_line(fnd_file.Log,'No.of Item Entities deleted are 0');
      fnd_file.put_line(fnd_file.Log,'No.of Item Revision Entities deleted are 0');
      fnd_file.put_line(fnd_file.Log,'No.of Item People deleted are 0');
      fnd_file.put_line(fnd_file.Log,'No.of Item Categories deleted are 0');
      fnd_file.put_line(fnd_file.Log,'No.of Item Associations deleted are 0');

  END IF;


--end deleting item records in structure batch

EXCEPTION

WHEN OTHERS THEN

      err_buff := 'Structure_Purge: stm_num = '||stm_num||'. Error msg: '||SUBSTR(SQLERRM, 1, 200);
      ret_code := 2;--FND_API.G_RET_STS_ERROR;
      fnd_file.put_line(fnd_file.Log,err_buff);

END Structure_Purge;


--purge all procedure

PROCEDURE Purge_All(p_batch_id IN NUMBER,ret_code OUT NOCOPY VARCHAR2,err_buff OUT NOCOPY  VARCHAR2 ) IS


  l_batch_type VARCHAR2(50);
  stm_num NUMBER := 0;

BEGIN

    stm_num :=1;

    SELECT BATCH_TYPE INTO l_batch_type FROM EGO_IMPORT_BATCHES_B WHERE BATCH_ID=p_batch_id;

        stm_num :=2;

        DELETE FROM MTL_SYSTEM_ITEMS_INTERFACE WHERE set_process_id = p_batch_id AND PROCESS_FLAG IN (3,6,7);

        fnd_file.put_line(fnd_file.Log,'No.of Item Entities deleted are '||SQL%ROWCOUNT);

        stm_num :=3;

        DELETE FROM MTL_ITEM_REVISIONS_INTERFACE WHERE SET_PROCESS_ID = p_batch_id AND PROCESS_FLAG IN (3,6,7);

        fnd_file.put_line(fnd_file.Log,'No.of Item Revision Entities deleted are '||SQL%ROWCOUNT);


        stm_num :=4;

        DELETE FROM EGO_ITEM_PEOPLE_INTF WHERE DATA_SET_ID = p_batch_id AND PROCESS_STATUS IN (3,4,6,7);

        fnd_file.put_line(fnd_file.Log,'No.of Item People Entities deleted are '||SQL%ROWCOUNT);


        stm_num :=5;

        DELETE FROM MTL_ITEM_CATEGORIES_INTERFACE WHERE SET_PROCESS_ID = p_batch_id AND PROCESS_FLAG IN (3,6,7);

        fnd_file.put_line(fnd_file.Log,'No.of Item Categories Entities deleted are '||SQL%ROWCOUNT);


        stm_num :=6;


        DELETE FROM EGO_ITEM_ASSOCIATIONS_INTF WHERE BATCH_ID = p_batch_id AND PROCESS_FLAG IN (3,6,7);

        fnd_file.put_line(fnd_file.Log,'No.of Item Association Entities deleted are '||SQL%ROWCOUNT);


        stm_num :=7;


        DELETE FROM EGO_AML_INTF WHERE DATA_SET_ID = p_batch_id AND PROCESS_FLAG IN (3,6,7);



        DELETE FROM EGO_ITM_USR_ATTR_INTRFC WHERE DATA_SET_ID = p_batch_id AND PROCESS_STATUS IN (3,4,6,7);






  IF l_batch_type='BOM_STRUCTURE' THEN

          stm_num :=8;

          DELETE bom_bill_of_mtls_interface WHERE batch_id = p_batch_id AND PROCESS_FLAG IN (3,6,7);

          fnd_file.put_line(fnd_file.Log,'No.of Structures deleted are '||SQL%ROWCOUNT);


          stm_num :=9;

          DELETE bom_inventory_comps_interface WHERE batch_id = p_batch_id AND PROCESS_FLAG IN (3,6,7);

          fnd_file.put_line(fnd_file.Log,'No.of Components deleted are '||SQL%ROWCOUNT);


          stm_num :=10;

          DELETE bom_ref_desgs_interface WHERE batch_id = p_batch_id AND PROCESS_FLAG IN (3,6,7);

          fnd_file.put_line(fnd_file.Log,'No.of ref-designators deleted are '||SQL%ROWCOUNT);


          stm_num :=11;

          DELETE bom_sub_comps_interface WHERE batch_id = p_batch_id AND PROCESS_FLAG IN (3,6,7);

          fnd_file.put_line(fnd_file.Log,'No.of Sub-components deleted are '||SQL%ROWCOUNT);


          stm_num :=12;

          DELETE bom_cmp_usr_attr_interface WHERE (batch_id = p_batch_id or data_set_id = p_batch_id) AND PROCESS_STATUS IN (3,6,7);


          stm_num :=13;

          DELETE bom_component_ops_interface WHERE batch_id = p_batch_id AND PROCESS_FLAG IN (3,6,7);

          fnd_file.put_line(fnd_file.Log,'No.of Component Operations deleted are '||SQL%ROWCOUNT);


          stm_num :=14;

          DELETE bom_op_routings_interface WHERE batch_id = p_batch_id AND PROCESS_FLAG IN (3,6,7);

          fnd_file.put_line(fnd_file.Log,'No.of Routings deleted are '||SQL%ROWCOUNT);


          stm_num :=15;

          DELETE bom_op_resources_interface WHERE batch_id = p_batch_id AND PROCESS_FLAG IN (3,6,7);

          fnd_file.put_line(fnd_file.Log,'No.of Operation Resources deleted are '||SQL%ROWCOUNT);


          stm_num :=16;

          DELETE bom_sub_op_resources_interface WHERE batch_id = p_batch_id AND PROCESS_FLAG IN (3,6,7);

          fnd_file.put_line(fnd_file.Log,'No.of Sub-operation Resources deleted are '||SQL%ROWCOUNT);


          stm_num :=17;

          DELETE bom_op_sequences_interface WHERE batch_id = p_batch_id AND PROCESS_FLAG IN (3,6,7);

          fnd_file.put_line(fnd_file.Log,'No.of Operation sequences deleted are '||SQL%ROWCOUNT);


          stm_num :=18;

          DELETE bom_op_networks_interface WHERE batch_id = p_batch_id AND PROCESS_FLAG IN (3,6,7);

  END IF;

   COMMIT;

EXCEPTION

WHEN OTHERS THEN
      err_buff := 'Purge_All: stm_num = '||stm_num||'. Error msg: '||SUBSTR(SQLERRM, 1, 200);
      ret_code := 2; --FND_API.G_RET_STS_ERROR;
      fnd_file.put_line(fnd_file.Log,err_buff);

END Purge_All;


END Ego_import_batch_purge_pkg;

/
