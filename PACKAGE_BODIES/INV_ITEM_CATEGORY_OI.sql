--------------------------------------------------------
--  DDL for Package Body INV_ITEM_CATEGORY_OI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_ITEM_CATEGORY_OI" AS
/* $Header: INVCICIB.pls 120.22.12010000.7 2010/05/26 11:02:50 kjonnala ship $ */

---------------------- Package variables and constants -----------------------

G_PKG_NAME       CONSTANT  VARCHAR2(30)  :=  'INV_ITEM_CATEGORY_OI';

G_SUCCESS          CONSTANT  NUMBER  :=  0;
G_WARNING          CONSTANT  NUMBER  :=  1;
G_ERROR            CONSTANT  NUMBER  :=  2;

G_ROWS_TO_COMMIT   CONSTANT  NUMBER  :=  500;

------------------------------------------------------------------------------

-------------------------Update_Sync_Records----------------------------------
PROCEDURE UPDATE_SYNC_RECORDS(p_inventory_item_id IN NUMBER,
                              p_organization_id IN NUMBER,
                              p_category_set_id IN NUMBER,
                              p_transaction_id  IN NUMBER,
                              p_row_id          IN ROWID,
                              x_old_category_id OUT NOCOPY NUMBER,
                              x_transaction_type OUT NOCOPY VARCHAR2,
                              x_return_status OUT NOCOPY NUMBER)
IS

  CURSOR c_cat_assign_exists (cp_item_id NUMBER,
                              cp_org_id  NUMBER,
                              cp_cat_set_id NUMBER)
  IS
    SELECT category_id FROM mtl_item_categories
     WHERE inventory_item_id = cp_item_id
       AND organization_id = cp_org_id
       AND category_set_id = cp_cat_set_id;

  CURSOR c_mult_item_flag (cp_cat_set_id NUMBER)
  IS
    SELECT mult_item_cat_assign_flag
      FROM mtl_category_sets_b
     WHERE category_set_id = cp_cat_set_id;

  l_category_id NUMBER := 0;
  l_old_category_id NUMBER;
  l_mult_item_assign_flag VARCHAR2(1);
  l_msg_name           VARCHAR2(2000);
  l_column_name        VARCHAR2(30);
  l_token              VARCHAR2(30);
  l_token_value        VARCHAR2(81);
  l_transaction_type   VARCHAR2(10);
  l_return_status      NUMBER;

BEGIN
 OPEN  c_cat_assign_exists( cp_item_id => p_inventory_item_id,
                            cp_org_id  => p_organization_id,
                            cp_cat_set_id => p_category_set_id);
 FETCH c_cat_assign_exists INTO l_category_id;

 IF c_cat_assign_exists%FOUND THEN
    OPEN  c_mult_item_flag (cp_cat_set_id => p_category_set_id);
    FETCH c_mult_item_flag INTO l_mult_item_assign_flag;
    CLOSE c_mult_item_flag;

    IF l_mult_item_assign_flag = 'Y' THEN
       l_msg_name := 'INV_MULT_SYNC_INVALID';
       l_token    := 'CATEGORY_SET_ID';
       l_token_value := TO_CHAR(p_category_set_id);
       l_column_name := 'CATEGORY_SET_ID';
       l_return_status := 3;

       INV_ITEM_MSG.Add_Message
       (  p_Msg_Name        =>  l_msg_name
       ,  p_token1          =>  l_token
       ,  p_value1          =>  l_token_value
       ,  p_transaction_id  =>  p_transaction_id
       ,  p_column_name     =>  l_column_name
       );

       UPDATE mtl_item_categories_interface
          SET process_flag = 3
        WHERE rowid = p_row_id;

    ELSE
       UPDATE mtl_item_categories_interface
          SET old_category_id = l_category_id,
              transaction_type = 'UPDATE'
        WHERE rowid = p_row_id;

        l_transaction_type := 'UPDATE';
        l_old_category_id := l_category_id;
    END IF;
 ELSE
    UPDATE mtl_item_categories_interface
       SET transaction_type = 'CREATE'
     WHERE rowid = p_row_id;

    l_transaction_type := 'CREATE';
 END IF;
 CLOSE c_cat_assign_exists;

 x_transaction_type := l_transaction_type;
 x_return_status := l_return_status;
 x_old_category_id:= l_old_category_id;

END UPDATE_SYNC_RECORDS;

------------------------ process_Item_Category_records -----------------------

PROCEDURE process_Item_Category_records
(
   ERRBUF              OUT  NOCOPY VARCHAR2
,  RETCODE             OUT  NOCOPY NUMBER
,  p_rec_set_id        IN   NUMBER
,  p_upload_rec_flag   IN   NUMBER    :=  1
,  p_delete_rec_flag   IN   NUMBER    :=  1
,  p_commit_flag       IN   NUMBER    :=  1
,  p_prog_appid        IN   NUMBER    :=  NULL
,  p_prog_id           IN   NUMBER    :=  NULL
,  p_request_id        IN   NUMBER    :=  NULL
,  p_user_id           IN   NUMBER    :=  NULL
,  p_login_id          IN   NUMBER    :=  NULL
,  p_gather_stats      IN   NUMBER    :=  1  /* Added for Bug 8532728 */
,  p_validate_rec_flag IN   NUMBER  DEFAULT 1 /*Fix for bug 9714783 - moved p_validate_rec_flag parameter to the end*/
)
IS
   l_api_name       CONSTANT  VARCHAR2(30)  := 'process_Item_Category_records';
   Mctx             INV_ITEM_MSG.Msg_Ctx_type;

   --
   -- Select records to flag missing or invalid organization_id
   --

   CURSOR miss_org_id_csr
   IS
      SELECT
         mici.rowid, mici.transaction_id
      ,  mici.transaction_type
      ,  mici.organization_id, mici.inventory_item_id
      ,  mici.category_set_id, mici.category_id
      ,  mici.organization_code, mici.item_number
      ,  mici.category_set_name, mici.category_name
      FROM
         mtl_item_categories_interface  mici
      WHERE
         set_process_id = g_xset_id
         AND  process_flag = 1
         AND  ( organization_id IS NULL
                OR ( organization_id IS NOT NULL
                     AND NOT EXISTS
                         ( SELECT  mp.organization_id
                           FROM  mtl_parameters  mp
                           WHERE  mp.organization_id = mici.organization_id
                         )
                   )
              )
      FOR UPDATE OF mici.transaction_id;

   --
   -- Cursor for the main loop (Create_Category_Assignment)
   --

   CURSOR icoi_csr
   IS
      SELECT
         mici.rowid, mici.transaction_id
      ,  mici.transaction_type, mici.process_flag
      ,  mici.organization_id, mici.inventory_item_id
      ,  mici.category_set_id, mici.category_id
      ,  mici.organization_code, mici.item_number
      ,  mici.category_set_name, mici.category_name
      ,  mici.old_category_id, mici.old_category_name  --* Added for Bug #3991044
      ,  mici.created_by
      ,  mici.set_process_id,mici.source_system_reference -- Added for Bug 9305193 Fix
      ,  mici.source_system_id
      FROM
         mtl_item_categories_interface  mici
      ,  mtl_parameters                 mp
      WHERE
         mici.set_process_id = g_xset_id
         AND mici.organization_id = mp.organization_id
         AND mici.process_flag IN (1, 2, 4) --R12C
      ORDER BY
         mp.master_organization_id  ASC
      ,  DECODE(mici.transaction_type, 'DELETE', 1, 'UPDATE', 2, 'CREATE', 3, 4)  ASC
      ,  DECODE(mp.organization_id, mp.master_organization_id, 1, 2)  ASC
      ,  mp.organization_id  ASC
      FOR UPDATE OF mici.transaction_id;

   --
   -- Select records to get category_set_id
   --

   CURSOR category_set_name_csr
   (  p_category_set_name  IN  VARCHAR2
   )
   IS
      SELECT  category_set_id, structure_id
      FROM  mtl_category_sets_vl
      WHERE  category_set_name = p_category_set_name;

   CURSOR msi_item_number_csr (cp_item_number IN VARCHAR2,
                               cp_organization_id IN NUMBER)
   IS
      SELECT inventory_item_id
        FROM mtl_system_items_b_kfv
       WHERE concatenated_segments = cp_item_number
         AND organization_id = cp_organization_id;

   CURSOR msii_item_number_csr (cp_item_number IN VARCHAR2,
                                cp_organization_id IN NUMBER,
                                cp_xset_id IN NUMBER)
   IS
      SELECT inventory_item_id
        FROM mtl_system_items_interface
       WHERE item_number = cp_item_number
         AND organization_id = cp_organization_id
         AND set_process_id = cp_xset_id
         AND process_flag IN (1,2,4);

/*
   -- To assign inventory_item_id from item_number

   CURSOR miss_item_id_csr
   IS
--      SELECT DISTINCT item_number, organization_id
      SELECT  rowid, transaction_id
           ,  item_number, organization_id
      FROM  mtl_item_categories_interface
      WHERE  set_process_id = g_xset_id
        AND  inventory_item_id IS NULL
        AND  item_number     IS NOT NULL
        AND  category_set_id IS NOT NULL
        AND  organization_id IS NOT NULL;

   -- To assign category_id from category_name

   CURSOR miss_category_id_csr
   IS
      SELECT  rowid, transaction_id
           ,  category_name, organization_id, category_set_id
      FROM  mtl_item_categories_interface
      WHERE  set_process_id = g_xset_id
        AND  category_id IS NULL
        AND  category_name   IS NOT NULL
        AND  category_set_id IS NOT NULL
        AND  organization_id IS NOT NULL
        AND  process_flag = l_process_flag_1;
*/


   -- pre-validate missing category_set_id, category_id, organization_id
   -- (not used)
/*
   CURSOR miss_id_csr IS
           SELECT i.transaction_id, i.organization_id
           FROM  mtl_item_categories_interface i
           WHERE  i.process_flag = l_process_flag_2
             AND  set_process_id = g_xset_id
             AND  ( i.organization_id = org_id OR all_org = l_All_Org )
             AND  (
              (NOT EXISTS (select  m.category_set_id
                           from  mtl_category_sets_b  m
                           where  m.category_set_id = i.category_set_id )
              )
              OR
              (NOT EXISTS (select m.category_id
                           from mtl_categories_b m,
                                mtl_category_sets_b ms
                           where m.category_id = i.category_id
                             and m.structure_id = ms.structure_id
                             and i.category_set_id = ms.category_set_id)
              )
              OR
              (NOT EXISTS (select organization_id
                           from ORG_ORGANIZATION_DEFINITIONS OOD
                           where OOD.organization_id = i.organization_id)
              )
                  );
*/
/* R12 Business Events Enh
   Populate mtl_item_bulkload_recs*/
   Cursor populate_catg_bulkloadrecs(
                          cp_request_id NUMBER
			 ,cp_set_id NUMBER) IS
   SELECT  mic.REQUEST_ID
          ,mic.INVENTORY_ITEM_ID
          ,mic.ORGANIZATION_ID
          ,mic.CATEGORY_SET_ID
	  ,mic.CATEGORY_ID
          ,mic.TRANSACTION_TYPE
          ,mic.CREATION_DATE
          ,mic.CREATED_BY
          ,mic.LAST_UPDATE_DATE
          ,mic.LAST_UPDATED_BY
          ,mic.LAST_UPDATE_LOGIN
   FROM MTL_ITEM_CATEGORIES_INTERFACE mic
   WHERE REQUEST_ID     = cp_request_id
   AND   set_process_id = cp_set_id
   AND   process_flag   = 7;

   l_process_flag       NUMBER;

   Processing_Error     EXCEPTION;

   ret_code             NUMBER           :=  0;
   l_err_text           VARCHAR2(2000);

   l_commit             VARCHAR2(1);
   l_return_status      VARCHAR2(1);  -- :=  fnd_api.g_MISS_CHAR
   l_return_status_flag NUMBER;
   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2(2000);

   l_msg_name           VARCHAR2(2000);

   l_RETCODE            NUMBER;       -- G_SUCCESS, G_WARNING, G_ERROR
   l_column_name        VARCHAR2(30);
   l_token              VARCHAR2(30);
   l_token_value        VARCHAR2(81); -- Bug # 3516745. Increased the
                                      -- size from 30 to 81.

   l_transaction_id     NUMBER;
   l_transaction_type   VARCHAR2(10);
   l_organization_id    NUMBER;
   l_inventory_item_id  NUMBER;
   l_category_set_id    NUMBER;
   l_structure_id       NUMBER;
   l_category_id        NUMBER;
   flex_id              NUMBER;
   l_has_privilege      VARCHAR2(1) := 'F';
   l_udex_catalog_id    NUMBER;
   l_gpc_catalog_id     NUMBER; --Bug 5517473

   l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

    --2698140 : Gather stats before running the IOI
    l_schema          VARCHAR2(30);
    l_status          VARCHAR2(1);
    l_industry        VARCHAR2(1);
    l_records         NUMBER(10);

    --* Variables added for Bug #3991044
    l_Reccount          NUMBER := 0;
    l_old_category_id   NUMBER;
    --* End of Bug #3991044
    l_records_updated   VARCHAR2(1); --bUG 4527222

    l_item_number	VARCHAR2(40); --5522789
    l_ret_old_category_id NUMBER;
    l_inv_debug_level     NUMBER := INVPUTLI.get_debug_level;

    l_ItemNum_GenMethod VARCHAR2(1); --Added for Bug 9305193 Fix

BEGIN

    --Start 2698140 : Gather stats before running
    --When called through pub pacs, prog_id will be null or -1.
--    IF NVL(fnd_global.conc_program_id,-1) <> -1 THEN Bug:3547401
    IF NVL(p_prog_id,-1) <> -1 AND p_gather_stats = 1 THEN  /* p_gather_stats Added for Bug 8532728 */

       SELECT count(*) INTO l_records
       FROM   mtl_item_categories_interface
       WHERE  set_process_id = p_rec_set_id
       AND    process_flag IN  (1,2,4); --R12C

	   -- Bug 6983407 Collect statistics only if the no. of records is bigger than the profile
	   -- option threshold
       IF l_records > nvl(fnd_profile.value('EGO_GATHER_STATS'),100)  AND FND_INSTALLATION.GET_APP_INFO('INV', l_status, l_industry, l_schema)   THEN
          IF l_schema IS NOT NULL    THEN
             FND_STATS.GATHER_TABLE_STATS(l_schema, 'MTL_ITEM_CATEGORIES_INTERFACE');
          END IF;
       END IF;
    END IF;
    --End 2698140 : Gather stats before running

    -- It is required to check if the category update is for GDSN item and that too GDSN Category set id ..
    -- For which case category_set_id of Udex Catalog is fetched for further use.
    BEGIN
      SELECT SUM(
             DECODE(FUNCTIONAL_AREA_ID,12,CATEGORY_SET_ID,0)) udex_catalog
            ,SUM(
             DECODE(FUNCTIONAL_AREA_ID,21,CATEGORY_SET_ID,0)) gpc_catalog
        INTO l_udex_catalog_id   , l_gpc_catalog_id
        FROM MTL_DEFAULT_CATEGORY_SETS
       WHERE FUNCTIONAL_AREA_ID IN (12,21); --Bug 5517473 added functional area 21
    EXCEPTION
      WHEN OTHERS THEN
        l_udex_catalog_id := NULL;
    END;


   INV_ITEM_MSG.Initialize;

   INV_ITEM_MSG.set_Message_Mode ('CP_LOG');

   -- Set message level

   INV_ITEM_MSG.set_Message_Level (INV_ITEM_MSG.g_Level_Statement);
  -- INV_ITEM_MSG.set_Message_Level (INV_ITEM_MSG.g_Level_Error);

   -- Define message context
   Mctx.Package_Name   := G_PKG_NAME;
   Mctx.Procedure_Name := l_api_name;

   IF (l_debug = 1) THEN
      INV_ITEM_MSG.Debug(Mctx, 'start rec_set_id = '|| TO_CHAR(p_rec_set_id));
   END IF;

   -- Set global package variables for the current import session

   g_xset_id    := p_rec_set_id;

   g_User_id    := NVL(p_user_id,    FND_GLOBAL.user_id         );
   g_Login_id   := NVL(p_login_id,   FND_GLOBAL.login_id        );
   g_Prog_appid := NVL(p_prog_appid, FND_GLOBAL.prog_appl_id    );
   g_Prog_id    := NVL(p_prog_id,    FND_GLOBAL.conc_program_id );
   g_Request_id := NVL(p_request_id, FND_GLOBAL.conc_request_id );

   INV_ITEM_MSG.g_Table_Name := 'MTL_ITEM_CATEGORIES_INTERFACE';

   INV_ITEM_MSG.g_User_id    := g_User_id;
   INV_ITEM_MSG.g_Login_id   := g_Login_id;
   INV_ITEM_MSG.g_Prog_appid := g_Prog_appid;
   INV_ITEM_MSG.g_Prog_id    := g_Prog_id;
   INV_ITEM_MSG.g_Request_id := g_Request_id;

   IF ( p_commit_flag = 1 ) THEN
      l_commit := fnd_api.g_TRUE;
   ELSE
      l_commit := fnd_api.g_FALSE;
   END IF;

   l_RETCODE := G_SUCCESS;

   ---------------------------------------------------------------------------------------
   -- Process step 1: Populate organization ids from codes                              --
   --  (a) convert organization_code to organization_id where organization_id IS NULL   --
   --  (b) use miss_org_id_csr to flag records with missing or invalid organization_id  --
   ---------------------------------------------------------------------------------------

   -- Assign all missing organization_id from organization_code

   IF (l_debug = 1) THEN
      INV_ITEM_MSG.Debug(Mctx, 'assign all missing organization_id');
   END IF;

   UPDATE mtl_item_categories_interface  mici
   SET
   (  mici.organization_id
   ,  process_flag
   ) =
   ( SELECT  mp.organization_id, DECODE(p_validate_rec_flag, 2, 1, 2)
     FROM  mtl_parameters  mp
     WHERE  mp.organization_code = mici.organization_code
   )
   WHERE
      mici.set_process_id = g_xset_id
      AND  mici.process_flag = 1
      AND  mici.organization_id IS NULL
      AND  mici.organization_code IS NOT NULL
      AND EXISTS
          ( SELECT  mp2.organization_id
            FROM  mtl_parameters  mp2
            WHERE  mp2.organization_code = mici.organization_code
          );

   -- For missing organization_id, update process_flag and log an error.
   -- Also, assign transaction_id, request_id

   FOR cr IN miss_org_id_csr LOOP

      SELECT mtl_system_items_interface_s.NEXTVAL
        INTO l_transaction_id
      FROM dual;

      UPDATE mtl_item_categories_interface
      SET
     --    transaction_id = mtl_system_items_interface_s.NEXTVAL
         transaction_id = l_transaction_id
      ,  request_id     = g_request_id
      ,  process_flag   = 3
      WHERE CURRENT OF miss_org_id_csr;
     -- RETURNING transaction_id INTO l_transaction_id;

      IF ( cr.organization_id IS NULL ) THEN
         IF ( cr.organization_code IS NULL ) THEN
            l_msg_name := 'INV_ICOI_MISS_ORG_CODE';
            l_token := fnd_api.g_MISS_CHAR;
            l_token_value := cr.organization_code;
         ELSE
            l_msg_name := 'INV_ICOI_INVALID_ORG_CODE';
            l_token := 'VALUE';
            l_token_value := cr.organization_code;
         END IF;
         l_column_name := 'ORGANIZATION_CODE';
      ELSE
         l_msg_name := 'INV_ICOI_INVALID_ORG_ID';
         l_token := 'VALUE';
         l_token_value := TO_CHAR(cr.organization_id);
         l_column_name := 'ORGANIZATION_ID';
      END IF;

      l_RETCODE := G_WARNING;

      INV_ITEM_MSG.Add_Message
      (  p_Msg_Name        =>  l_msg_name
      ,  p_token1          =>  l_token
      ,  p_value1          =>  l_token_value
      ,  p_transaction_id  =>  l_transaction_id
      ,  p_column_name     =>  l_column_name
      );

   END LOOP;  -- miss_org_id_csr

   -- Check of commit
   IF ( FND_API.To_Boolean(l_commit) ) THEN
      COMMIT WORK;
   END IF;

   -- Write all accumulated messages
   --
   INV_ITEM_MSG.Write_List (p_delete => TRUE);

   --------------------------------------------------------------------------
   -- Process step 2: Loop through item category interface records         --
   --  (a) convert category set, item, category values to ids, if missing  --
   --  (b) call the API to create item category assignment record in the   --
   --      production table                                                --
   --  (c) update the current interface record process_flag and other      --
   --      converted values                                                --
   --------------------------------------------------------------------------

   IF (l_debug = 1) THEN
      INV_ITEM_MSG.Debug(Mctx, 'starting the main ICOI loop');
   END IF;

   FOR icoi_rec IN icoi_csr LOOP  --{

      -- Process flag for the current record is initially set to 4
      -- (validation success);
      -- may be changed to 3 or 5, if any errors occur during validation.

      IF p_validate_rec_flag = 1 THEN
         l_process_flag := 4;
      ELSE
         l_process_flag := 1;
      END IF;

      SELECT mtl_system_items_interface_s.NEXTVAL
        INTO l_transaction_id
      FROM dual;

      l_organization_id := icoi_rec.organization_id;

      --
      -- Validate transaction_type
      --

      l_return_status := fnd_api.g_RET_STS_SUCCESS;

      l_transaction_type := UPPER(icoi_rec.transaction_type);

      --*Included UPDATE trans type for Bug #3991044
      IF ( l_transaction_type NOT IN ('CREATE', 'DELETE','UPDATE', 'SYNC') ) THEN
         l_return_status := fnd_api.g_RET_STS_ERROR;
         l_process_flag := 3;

         l_RETCODE := G_WARNING;

         l_msg_name := 'INV_ICOI_INVALID_TRANSACT_TYPE';
         l_token := fnd_api.g_MISS_CHAR;
         l_token_value := l_transaction_type;
         l_column_name := 'TRANSACTION_TYPE';

         INV_ITEM_MSG.Add_Message
         (  p_Msg_Name        =>  l_msg_name
         ,  p_token1          =>  l_token
         ,  p_value1          =>  l_token_value
         ,  p_transaction_id  =>  l_transaction_id
         ,  p_column_name     =>  l_column_name
         );

      END IF;  -- l_transaction_type

      --
      -- Assign missing category_set_id from category_set_name
      --

      l_return_status := fnd_api.g_RET_STS_SUCCESS;

      l_category_set_id := icoi_rec.category_set_id;

      IF ( l_category_set_id IS NULL ) THEN

        IF (l_debug = 1) THEN
            INV_ITEM_MSG.Debug(Mctx, 'assign missing category_set_id');
        END IF;

        IF ( icoi_rec.category_set_name IS NOT NULL ) THEN
           OPEN category_set_name_csr
              ( p_category_set_name  =>  icoi_rec.category_set_name );
           FETCH category_set_name_csr INTO l_category_set_id, l_structure_id;
           IF ( category_set_name_csr%NOTFOUND ) THEN
              l_return_status := fnd_api.g_RET_STS_ERROR;
              l_category_set_id := NULL;
              l_msg_name := 'INV_ICOI_INVALID_CAT_SET_NAME';
              l_token := 'VALUE';
              l_token_value := icoi_rec.category_set_name;
              l_column_name := 'CATEGORY_SET_NAME';
           END IF;
           CLOSE category_set_name_csr;
        ELSE
           l_return_status := fnd_api.g_RET_STS_ERROR;
           l_msg_name := 'INV_ICOI_MISS_CAT_SET_NAME';
           l_token := fnd_api.g_MISS_CHAR;
           l_token_value := icoi_rec.category_set_name;
           l_column_name := 'CATEGORY_SET_NAME';
        END IF;

        ELSE
           -- Pass the Id validation to Create_Category_Assignment API
           NULL;

           --l_msg_name := 'INV_ICOI_INVALID_CAT_SET_ID';
           --l_column_name := 'CATEGORY_SET_ID';

        END IF;  -- category_set_id

        IF ( l_return_status <> fnd_api.g_RET_STS_SUCCESS ) THEN
           l_process_flag := 3;

           l_RETCODE := G_WARNING;

           INV_ITEM_MSG.Add_Message
           (  p_Msg_Name        =>  l_msg_name
           ,  p_token1          =>  l_token
           ,  p_value1          =>  l_token_value
           ,  p_transaction_id  =>  l_transaction_id
           ,  p_column_name     =>  l_column_name
           );

        END IF;

        --* Code added for Bug #3991044
        --
        -- Assign missing old_category_id from old_category_name
        --

        l_return_status := fnd_api.g_RET_STS_SUCCESS;

        l_old_category_id := icoi_rec.old_category_id;


        IF ( l_transaction_type IN ('UPDATE', 'SYNC') AND (l_category_set_id IS NOT NULL)
              AND (l_old_category_id IS NULL) ) THEN

           IF (l_debug = 1) THEN
              INV_ITEM_MSG.Debug(Mctx, 'assign missing old category_id');
           END IF;

           IF ( icoi_rec.old_category_name IS NOT NULL ) THEN
              --* Fetching Category Id using Category Name
              IF (l_debug = 1) THEN
                 INV_ITEM_MSG.Debug(Mctx, 'Fetching Category Id using Category Name');
              END IF;
              BEGIN
                 SELECT  Category_id
                   INTO  l_old_category_id
                   FROM  Mtl_Categories_B_Kfv
                  WHERE  Structure_Id = ( SELECT  Structure_Id
                                            FROM  mtl_category_sets_vl
                                           WHERE  category_set_id = l_category_set_id )
                    AND  Concatenated_Segments = icoi_rec.old_category_name;
              EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                   l_return_status := fnd_api.g_RET_STS_ERROR;
                   l_msg_name := 'INV_ICOI_INVALID_CAT_NAME';
                   l_token := 'VALUE';
                   l_token_value := icoi_rec.old_category_name;
                   l_column_name := 'CATEGORY_NAME';
              END;
           ELSE
              IF l_transaction_type = 'UPDATE' THEN
                 l_return_status := fnd_api.g_ret_sts_error;
                 l_msg_name := 'INV_ICOI_MISS_CAT_NAME';
                 l_token := fnd_api.G_MISS_CHAR;
                 l_token_value := icoi_rec.old_category_name;
                 l_column_name := 'CATEGORY_NAME';
              END IF;
           END IF; --Old Category Name not null
        END IF;  -- category_id

        IF ( l_return_status <> fnd_api.g_RET_STS_SUCCESS ) THEN
           l_process_flag := 3;

           l_RETCODE := G_WARNING;

           INV_ITEM_MSG.Add_Message
           (  p_Msg_Name        =>  l_msg_name
           ,  p_token1          =>  l_token
           ,  p_value1          =>  l_token_value
           ,  p_transaction_id  =>  l_transaction_id
           ,  p_column_name     =>  l_column_name
           );
        END IF;
        --* End of Bug #3991044

        --
        -- Assign missing category_id from category_name
        --

        l_return_status := fnd_api.g_RET_STS_SUCCESS;

        l_category_id := icoi_rec.category_id;

        -- The category_set_id must be known at this point

        IF ( (l_category_set_id IS NOT NULL) AND (l_category_id IS NULL) ) THEN

           IF (l_debug = 1) THEN
              INV_ITEM_MSG.Debug(Mctx, 'assign missing category_id');
           END IF;

           IF ( icoi_rec.category_name IS NOT NULL ) THEN
  -- commented for fixing 2636268
  --            ret_code := INVPUOPI.mtl_pr_parse_flex_name
  --                        (  l_organization_id,
  --                           'MCAT',
  --                           icoi_rec.category_name,
  --                           flex_id,
  --                           l_category_set_id,
  --                           l_err_text );
  --
  --            IF ( ret_code = 0 ) THEN
  --               l_category_id := flex_id;
  --            ELSE
            BEGIN
            -- bug 3500492
              IF l_structure_id IS NULL THEN
                SELECT structure_id INTO l_structure_id
                  FROM mtl_category_sets_b
                 WHERE category_set_id = l_category_set_id;
              END IF;
                SELECT category_id INTO   l_category_id
                  FROM mtl_categories_b_kfv
                 WHERE concatenated_segments = icoi_rec.category_name
                 -- bug 3500492
                   AND  structure_id = l_structure_id
                   AND  NVL(disable_date,SYSDATE+1) > SYSDATE;
				INV_ITEM_MSG.Debug(Mctx, 'Comes out correctly after fetching from KFV');
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                 l_return_status := fnd_api.g_RET_STS_ERROR;
                 l_msg_name := 'INV_ICOI_INVALID_CAT_NAME';
                 l_token := 'VALUE';
                 l_token_value := icoi_rec.category_name;
                 l_column_name := 'CATEGORY_NAME';
            END;
--            END IF;
           ELSE
              l_return_status := fnd_api.g_RET_STS_ERROR;
              l_msg_name := 'INV_ICOI_MISS_CAT_NAME';
              l_token := fnd_api.g_MISS_CHAR;
              l_token_value := icoi_rec.category_name;
              l_column_name := 'CATEGORY_NAME';
           END IF;

        ELSE
           -- Pass the Id validation to Create_Category_Assignment
           NULL;

           --l_msg_name := 'INV_ICOI_INVALID_CAT_ID';
           --l_column_name := 'CATEGORY_ID';

        END IF;  -- category_id

        IF ( l_return_status <> fnd_api.g_RET_STS_SUCCESS ) THEN
           l_process_flag := 3;

           l_RETCODE := G_WARNING;

           INV_ITEM_MSG.Add_Message
           (  p_Msg_Name        =>  l_msg_name
           ,  p_token1          =>  l_token
           ,  p_value1          =>  l_token_value
           ,  p_transaction_id  =>  l_transaction_id
           ,  p_column_name     =>  l_column_name
           );

        END IF;
      --
      -- Assign missing inventory_item_id from item_number
      --

        l_return_status := fnd_api.g_RET_STS_SUCCESS;

        l_inventory_item_id := icoi_rec.inventory_item_id;

        INV_ITEM_MSG.Debug(Mctx, 'Before missing inventory_item_id');
        IF ( l_inventory_item_id IS NULL ) THEN

           IF (l_debug = 1) THEN
              INV_ITEM_MSG.Debug(Mctx, 'assign missing inventory_item_id');
           END IF;

           IF ( icoi_rec.item_number IS NOT NULL ) THEN
-- commented for fixing 2636268
--            ret_code := INVPUOPI.mtl_pr_parse_flex_name (
--                           l_organization_id,
--                           'MSTK',
--                           icoi_rec.item_number,
--                           flex_id,
--                           0,
--                           l_err_text );
--
--            IF ( ret_code = 0 ) THEN
--               l_inventory_item_id := flex_id;
--            ELSE
              OPEN msi_item_number_csr (cp_item_number => icoi_rec.item_number,
                                        cp_organization_id => icoi_rec.organization_id);
              FETCH msi_item_number_csr INTO l_inventory_item_id;
              CLOSE msi_item_number_csr;

              IF ( l_inventory_item_id IS NULL ) THEN
                OPEN msii_item_number_csr (cp_item_number => icoi_rec.item_number,
                                           cp_organization_id => icoi_rec.organization_id,
                                           cp_xset_id => g_xset_id);
                FETCH msii_item_number_csr INTO l_inventory_item_id;
                CLOSE msii_item_number_csr;
              END IF;

              IF ( l_inventory_item_id IS NULL ) THEN
                 l_return_status := fnd_api.g_RET_STS_ERROR;
                 l_msg_name := 'INV_ICOI_INVALID_ITEM_NUMBER';
                 l_token := 'VALUE';
                 l_token_value := icoi_rec.item_number;
                 l_column_name := 'ITEM_NUMBER';
              END IF;

           ELSE

	      /*Bug 9305193 Fix
                a) Find out the ItemNumber Generation Method of the ICC of Item
		b) If It is 'Function Generated',Don't mark the row with Error
		   Because in this case,User need not to enter the ItemNumber in Input
		   It will be calculated after preprocessing stage and populated back in table.
               */
	      SELECT item_num_gen_method  INTO l_ItemNum_GenMethod
                                          FROM   mtl_item_Catalog_groups_b
                                          WHERE  item_catalog_group_id=
                                                (SELECT DISTINCT(item_catalog_group_id)
                                                        FROM    mtl_system_items_interface
                                                        WHERE   set_process_id          = icoi_rec.set_process_id
                                                        AND     source_system_id        = icoi_rec.source_system_id
                                                        AND     source_system_reference = icoi_rec.source_system_reference
                                                        AND     organization_code       = icoi_rec.organization_code
                                                        AND     process_flag IN (1));

	      IF ( l_ItemNum_GenMethod <> 'F') THEN
	         l_return_status := fnd_api.g_RET_STS_ERROR;
                 l_msg_name := 'INV_ICOI_MISS_ITEM_NUMBER';
                 l_token := fnd_api.g_MISS_CHAR;
                 l_token_value := icoi_rec.item_number;
                 l_column_name := 'ITEM_NUMBER';
              END IF;

           END IF;

        ELSE
         -- Pass the Id validation to Create_Category_Assignment
           NULL;

         --l_msg_name := 'INV_ICOI_INVALID_ITEM_ID';
         --l_column_name := 'INVENTORY_ITEM_ID';

        END IF;  -- inventory_item_id

        IF ( l_return_status <> fnd_api.g_RET_STS_SUCCESS ) THEN
           l_process_flag := 3;

           l_RETCODE := G_WARNING;

           INV_ITEM_MSG.Add_Message
           (  p_Msg_Name        =>  l_msg_name
           ,  p_token1          =>  l_token
           ,  p_value1          =>  l_token_value
           ,  p_transaction_id  =>  l_transaction_id
           ,  p_column_name     =>  l_column_name
           );

        END IF;

        l_return_status := fnd_api.g_RET_STS_SUCCESS;

        INV_ITEM_MSG.Debug(Mctx, 'Before checking for created_by ');
        -- Security check to be skipped for defaulted records bug 6456493
	IF ( icoi_rec.created_by <> -99 ) THEN
           l_has_privilege := INV_EGO_REVISION_VALIDATE.check_data_security(
                                     p_function           => 'EGO_MANAGE_CATEGORY_SET'
                                    ,p_object_name        => 'EGO_CATEGORY_SET'
                                    ,p_instance_pk1_value => l_category_set_id
                                    ,P_User_Id            => g_User_id);
           IF l_has_privilege <> 'T' THEN
              l_return_status := fnd_api.g_RET_STS_ERROR;
              l_msg_name      := 'INV_IOI_NOT_CATEGORY_USER';
              l_token         := fnd_api.g_MISS_CHAR;
              l_token_value   := icoi_rec.category_set_name;
              l_column_name   := 'CATEGORY_SET_NAME';
           END IF;

           IF ( l_return_status <> fnd_api.g_RET_STS_SUCCESS ) THEN
              l_process_flag := 3;
              l_RETCODE      := G_WARNING;
              INV_ITEM_MSG.Add_Message
              (  p_Msg_Name        =>  l_msg_name
              ,  p_token1          =>  l_token
              ,  p_value1          =>  l_token_value
              ,  p_transaction_id  =>  l_transaction_id
              ,  p_column_name     =>  l_column_name);
           END IF;
        --End:Check for data security and user privileges
	ELSE
           IF l_inv_debug_level IN(101, 102) THEN
              INVPUTLI.info('INVCICIB. Security check skipped for Item Org CS' || l_inventory_item_id || '-' || l_organization_id || '-' || l_category_set_id);
           END IF;
	END IF;
         INV_ITEM_MSG.Debug(Mctx, 'After checking for created_by ');
        --Resolve SYNC records to CREATE/UPDATE
        IF l_transaction_type = 'SYNC' THEN
        INV_ITEM_MSG.Debug(Mctx, 'inside transaction type of SYNC ');
           UPDATE_SYNC_RECORDS(p_inventory_item_id => l_inventory_item_id,
                               p_organization_id => l_organization_id,
                               p_category_set_id => l_category_set_id,
                               p_transaction_id => l_transaction_id,
                               p_row_id         => icoi_rec.rowid,
                               x_old_category_id => l_ret_old_category_id,
                               x_transaction_type => l_transaction_type,
                               x_return_status => l_return_status_flag);
           IF l_return_status_flag = 3 THEN
              l_process_flag := 3;
           END IF;

           IF l_transaction_type = 'UPDATE' AND l_ret_old_category_id IS NOT NULL THEN
              l_old_category_id := l_ret_old_category_id;
           END IF;
        END IF;

        INV_ITEM_MSG.Debug(Mctx, 'Value for p_upload_rec_flag is '|| to_char(p_upload_rec_flag));
        IF p_upload_rec_flag = 1 THEN
          --Start: Check for data security and user privileges
          l_return_status := fnd_api.g_RET_STS_SUCCESS;

	  IF ( icoi_rec.created_by <> -99 ) THEN
             l_has_privilege := INV_EGO_REVISION_VALIDATE.check_data_security(
                                     p_function           => 'EGO_EDIT_ITEM_CAT_ASSIGNMENTS'
                                    ,p_object_name        => 'EGO_ITEM'
                                    ,p_instance_pk1_value => l_inventory_item_id
                                    ,p_instance_pk2_value => l_organization_id
                                    ,P_User_Id            => g_User_id);

             IF l_has_privilege <> 'T' THEN
                l_return_status := fnd_api.g_RET_STS_ERROR;
                l_msg_name      := 'INV_IOI_ITEM_UPDATE_PRIV';

        	 --Bug: 5522789 Tokenise the message to display item number.
                l_token         := 'VALUE';
                IF icoi_rec.item_number IS NULL THEN
                   Select concatenated_segments into l_item_number
                     From mtl_system_items_b_kfv
                    where INVENTORY_ITEM_ID = l_inventory_item_id
                      AND organization_id = l_organization_id;   -- org
                ELSE
                   l_item_number := icoi_rec.item_number;
                END IF;
                l_token_value   := l_item_number;
	         --End Bug: 5522789

                l_column_name   := 'ITEM_NUMBER';
             END IF; -- has privilege

             IF ( l_return_status <> fnd_api.g_RET_STS_SUCCESS ) THEN
                l_process_flag := 3;
                l_RETCODE      := G_WARNING;
                INV_ITEM_MSG.Add_Message
                (  p_Msg_Name        =>  l_msg_name
                ,  p_token1          =>  l_token
                ,  p_value1          =>  l_token_value
                ,  p_transaction_id  =>  l_transaction_id
                ,  p_column_name     =>  l_column_name);

             END IF;
          ELSE
             IF l_inv_debug_level IN(101, 102) THEN
                INVPUTLI.info('INVCICIB. Security check skipped for Item Org CS' || l_inventory_item_id || '-' || l_organization_id || '-' || l_category_set_id);
             END IF;
	  END IF; -- created_d by
        END IF;  -- UPLOAD REC

        -- Write all accumulated messages
        INV_ITEM_MSG.Write_List (p_delete => TRUE);

      --
      -- If value-to-id conversions are successful, call the API
      -- to process item category assignment.
      --

       INV_ITEM_MSG.Debug(Mctx, 'Value for l_process_flag is '|| to_char(l_process_flag));
       INV_ITEM_MSG.Debug(Mctx, 'Value for p_upload_rec_flag again '|| to_char(p_upload_rec_flag));
       INV_ITEM_MSG.Debug(Mctx, 'Value for l_transaction_type '|| l_transaction_type);

        IF ( l_process_flag = 4 AND p_upload_rec_flag = 1 ) THEN

         IF ( l_transaction_type = 'DELETE' ) THEN

            IF (l_debug = 1) THEN
               INV_ITEM_MSG.Debug(Mctx, 'calling INV_ITEM_CATEGORY_PVT.Delete_Category_Assignment');
            END IF;

            INV_ITEM_CATEGORY_PVT.Delete_Category_Assignment
            (
               p_api_version        =>  1.0
            ,  p_init_msg_list      =>  fnd_api.g_TRUE
            ,  p_commit             =>  fnd_api.g_FALSE
            ,  p_inventory_item_id  =>  l_inventory_item_id
            ,  p_organization_id    =>  l_organization_id
            ,  p_category_set_id    =>  l_category_set_id
            ,  p_category_id        =>  l_category_id
            ,  p_transaction_id     =>  l_transaction_id
            ,  x_return_status      =>  l_return_status
            ,  x_msg_count          =>  l_msg_count
            ,  x_msg_data           =>  l_msg_data
            );

            IF ( l_return_status = fnd_api.g_RET_STS_SUCCESS ) THEN
               l_process_flag := 7;
            ELSE
               l_process_flag := 3;

               IF (l_debug = 1) THEN
                  INV_ITEM_MSG.Debug(Mctx, 'error in Delete_Category_Assignment. Msg count=' || TO_CHAR(INV_ITEM_MSG.Count_Msg));
               END IF;

               l_RETCODE := G_WARNING;

            END IF;  -- l_return_status

            -- If unexpected error in Delete_Category_Assignment API, stop the processing
            IF ( l_return_status = fnd_api.g_RET_STS_UNEXP_ERROR ) THEN
               l_RETCODE := G_ERROR;
               RAISE Processing_Error;
            END IF;

         ELSIF ( l_transaction_type = 'CREATE' ) THEN

            IF (l_debug = 1) THEN
               INV_ITEM_MSG.Debug(Mctx, 'calling INV_ITEM_CATEGORY_PVT.Create_Category_Assignment');
            END IF;

            INV_ITEM_CATEGORY_PVT.Create_Category_Assignment
            (
               p_api_version        =>  1.0
            ,  p_init_msg_list      =>  fnd_api.g_TRUE
            ,  p_commit             =>  fnd_api.g_FALSE
            ,  p_validation_level   =>  INV_ITEM_CATEGORY_PVT.g_VALIDATE_IDS
            ,  p_inventory_item_id  =>  l_inventory_item_id
            ,  p_organization_id    =>  l_organization_id
            ,  p_category_set_id    =>  l_category_set_id
            ,  p_category_id        =>  l_category_id
            ,  p_transaction_id     =>  l_transaction_id
--Bug: 2879647 Added the parameter
            ,  p_request_id         =>  p_request_id
            ,  x_return_status      =>  l_return_status
            ,  x_msg_count          =>  l_msg_count
            ,  x_msg_data           =>  l_msg_data
            );

            IF ( l_return_status = fnd_api.g_RET_STS_SUCCESS ) THEN
               l_process_flag := 7;
               IF ( l_gpc_catalog_id  = l_category_set_id) THEN
	         -- Bug 5517473 removing the call to process_cat_assignment it is same as update_reg_pub_update_dates
		 BEGIN
		   EGO_GTIN_PVT.UPDATE_REG_PUB_UPDATE_DATES
                                     (p_inventory_item_id => l_inventory_item_id,
                                      p_organization_id   => l_organization_id,
                                      p_update_reg        => 'Y',
                                      p_commit            => FND_API.G_FALSE,
                                      x_return_status     => l_return_status,
                                      x_msg_count         => l_msg_count,
                                      x_msg_data          => l_msg_data);
   		   EXCEPTION
		      WHEN others THEN
		        l_msg_data := SQLERRM;
		 END;
		 IF ( l_return_status <> fnd_api.g_RET_STS_SUCCESS ) THEN
                    l_process_flag := 3;
                    IF (l_debug = 1) THEN
                      INV_ITEM_MSG.Debug(Mctx, 'error in Create_Category_Assignment ' || l_msg_data);
                    END IF;
                    l_RETCODE := G_WARNING;
                 END IF;
		/* End of bug 5517473 */
               END IF; --GPC Catalog
            ELSE
               l_process_flag := 3;

               IF (l_debug = 1) THEN
                  INV_ITEM_MSG.Debug(Mctx, 'error in Create_Category_Assignment. Msg count=' || TO_CHAR(INV_ITEM_MSG.Count_Msg));
               END IF;

               l_RETCODE := G_WARNING;

/*
            -- Reset current message index value back to 0
            FND_MSG_PUB.Reset (FND_MSG_PUB.g_FIRST);

            FOR idx IN 1 .. FND_MSG_PUB.Count_Msg LOOP

   IF (l_debug = 1) THEN
      INV_ITEM_MSG.Debug(Mctx, 'LOOP FND_MSG_PUB Msg: idx=' || TO_CHAR(idx));
   END IF;

DECLARE
   l_app_short_name   VARCHAR2(30);
   l_msg_text         VARCHAR2(2000);
BEGIN
               l_msg_data := FND_MSG_PUB.Get
                             (  p_msg_index  =>  idx
                             ,  p_encoded    =>  FND_API.g_TRUE
                             );

               FND_MESSAGE.Parse_Encoded
               (  encoded_message  =>  l_msg_data
               ,  app_short_name   =>  l_app_short_name
               ,  message_name     =>  l_msg_name
               );

               l_msg_text := FND_MSG_PUB.Get (  p_msg_index  =>  idx
                                             ,  p_encoded    =>  FND_API.g_FALSE
                                             );

--               INV_ITEM_MSG.Debug(Mctx, 'l_msg_name=' || SUBSTRB(l_msg_name, 1,30));
               IF (l_debug = 1) THEN
                  INV_ITEM_MSG.Debug(Mctx, 'l_msg_name=' || l_msg_name);
                  INV_ITEM_MSG.Debug(Mctx, 'l_msg_text=' || l_msg_text);
               END IF;
--               INV_ITEM_MSG.Debug(Mctx, 'l_msg_text_length=' || TO_CHAR( LENGTH(l_msg_text) ));
END;

            END LOOP;  -- loop through the messages
*/

            END IF;  -- l_return_status

            -- If unexpected error in Create_Category_Assignment API,
            -- stop the processing.

            IF ( l_return_status = fnd_api.g_RET_STS_UNEXP_ERROR ) THEN
               l_RETCODE := G_ERROR;
               RAISE Processing_Error;
            END IF;
         --* Code added for Bug #3991044

         INV_ITEM_MSG.Debug(Mctx, 'Value for l_transaction_type before update'|| l_transaction_type);

         ELSIF ( l_transaction_type = 'UPDATE' ) THEN
         INV_ITEM_MSG.Debug(Mctx, 'Value for l_transaction_type inside update'|| l_transaction_type);
            IF (l_debug = 1) THEN
               INV_ITEM_MSG.Debug(Mctx, 'calling INV_ITEM_CATEGORY_PVT.Update_Category_Assignment');
            END IF;

            l_return_status := fnd_api.g_RET_STS_SUCCESS;

             INV_ITEM_CATEGORY_PVT.Update_Category_Assignment
            (   p_api_version        =>  1.0
            ,  p_init_msg_list      =>  fnd_api.g_TRUE
            ,  p_commit             =>  fnd_api.g_FALSE
            ,  p_inventory_item_id  =>  l_inventory_item_id
            ,  p_organization_id    =>  l_organization_id
            ,  p_category_set_id    =>  l_category_set_id
            ,  p_category_id        =>  l_category_id
            ,  p_old_category_id    =>  l_old_category_id
            ,  p_transaction_id     =>  l_transaction_id
            ,  x_return_status      =>  l_return_status
            ,  x_msg_count          =>  l_msg_count
            ,  x_msg_data           =>  l_msg_data
            );

            IF ( l_return_status = fnd_api.g_RET_STS_SUCCESS ) THEN
               l_process_flag := 7;
               IF ( l_udex_catalog_id = l_category_set_id
	         OR l_gpc_catalog_id  = l_category_set_id) THEN
	         -- Bug 5517473 removing the call to process_cat_assignment it is same as update_reg_pub_update_dates
                 /*BEGIN
                   EXECUTE IMMEDIATE 'BEGIN EGO_GTIN_PVT.PROCESS_CAT_ASSIGNMENT( :1, :2); END;' USING l_inventory_item_id, l_organization_id;
                 EXCEPTION
                   WHEN OTHERS THEN
                     NULL;
                 END;*/
		 /* Bug 5517473 - Submit for Re-Registration of GDSN attrs when GDSN/GPC category set updated */
		 BEGIN
		   EGO_GTIN_PVT.UPDATE_REG_PUB_UPDATE_DATES
                                     (p_inventory_item_id => l_inventory_item_id,
                                      p_organization_id   => l_organization_id,
                                      p_update_reg        => 'Y',
                                      p_commit            => FND_API.G_FALSE,
                                      x_return_status     => l_return_status,
                                      x_msg_count         => l_msg_count,
                                      x_msg_data          => l_msg_data);
		EXCEPTION
		  WHEN others THEN
		    l_msg_data := SQLERRM;
		END;
		IF ( l_return_status <> fnd_api.g_RET_STS_SUCCESS ) THEN
                   l_process_flag := 3;
                   IF (l_debug = 1) THEN
                     INV_ITEM_MSG.Debug(Mctx, 'error in Update_Category_Assignment ' || l_msg_data);
                   END IF;
                   l_RETCODE := G_WARNING;
                END IF;
		/* End of bug 5517473 */
               END IF; --Udex Catalog
            ELSE
               l_process_flag := 3;
               IF (l_debug = 1) THEN
                  INV_ITEM_MSG.Debug(Mctx, 'error in Update_Category_Assignment. Msg count=' || TO_CHAR(INV_ITEM_MSG.Count_Msg));
               END IF;
               l_RETCODE := G_WARNING;
            END IF;  -- l_return_status
         --* End of Bug #3991044

         END IF;  -- l_transaction_type

         /* Bug 4527222
	    Replacing this call with a single call after the loop
         IF ( l_process_flag = 7 ) THEN
            -- Sync item category assignment with item record in STAR.

            IF (l_debug = 1) THEN
               INV_ITEM_MSG.Debug(Mctx, 'calling Sync_Category_Assignments');
            END IF;

            -- Bug: 2718703 checking for ENI product before calling their package
            -- Start Bug: 3185516
            IF ( l_transaction_type = 'CREATE' ) THEN
               INV_ENI_ITEMS_STAR_PKG.Sync_Category_Assignments(
                  p_api_version         => 1.0
                 ,p_init_msg_list       => FND_API.g_TRUE
                 ,p_inventory_item_id   => l_inventory_item_id
                 ,p_organization_id     => l_organization_id
                 ,p_category_set_id     => l_category_set_id
                 ,p_old_category_id     => NULL
                 ,p_new_category_id     => l_category_id
                 ,x_return_status       => l_return_Status
                 ,x_msg_count           => l_msg_count
                 ,x_msg_data            => l_msg_data);
            ELSIF( l_transaction_type = 'DELETE' ) THEN
               INV_ENI_ITEMS_STAR_PKG.Sync_Category_Assignments(
                  p_api_version         => 1.0
                 ,p_init_msg_list       => FND_API.g_TRUE
                 ,p_inventory_item_id   => l_inventory_item_id
                 ,p_organization_id     => l_organization_id
                 ,p_category_set_id     => l_category_set_id
                 ,p_old_category_id     => l_category_id
                 ,p_new_category_id     => NULL
                 ,x_return_status       => l_return_Status
                 ,x_msg_count           => l_msg_count
                 ,x_msg_data            => l_msg_data);
             END IF;

              -- End Bug: 3185516
              -- If unexpected error in Sync_Category_Assignments,
              -- stop the processing.

              IF ( l_return_status = fnd_api.g_RET_STS_UNEXP_ERROR ) THEN
                 l_RETCODE := G_ERROR;
                 RAISE Processing_Error;
              END IF;

         END IF; Bug 4527222*/

      END IF;  -- process_flag = 4 AND p_upload_rec_flag = 1

      -- Write all accumulated messages
      --
      INV_ITEM_MSG.Write_List (p_delete => TRUE);

      --
      -- Update the current interface record
      --

      IF (l_debug = 1) THEN
         INV_ITEM_MSG.Debug(Mctx, 'update interface record');
      END IF;

      UPDATE mtl_item_categories_interface
      SET
         transaction_id     =  l_transaction_id
      ,  transaction_type   =  l_transaction_type
      ,  process_flag       =  l_process_flag
      ,  inventory_item_id  =  NVL(l_inventory_item_id, inventory_item_id)
      ,  category_set_id    =  NVL(l_category_set_id, category_set_id)
      ,  category_id        =  NVL(l_category_id, category_id)
      ,  program_application_id  =  g_prog_appid
      ,  program_id              =  g_prog_id
      ,  program_update_date     =  SYSDATE
      ,  request_id              =  g_request_id
      ,  last_update_date    =  SYSDATE
      ,  last_updated_by     =  g_user_id
      ,  last_update_login   =  g_login_id
      WHERE
         CURRENT OF icoi_csr;

   END LOOP;  --} icoi_csr


  /* Bug 4527222*/
   BEGIN
     SELECT 'Y'
      INTO  l_records_updated
      FROM  mtl_item_categories_interface  mici
      WHERE mici.set_process_id = g_xset_id
        AND mici.process_flag = 7
	AND ROWNUM = 1;

     EXCEPTION
         WHEN NO_DATA_FOUND THEN
            l_records_updated := 'N';
         WHEN OTHERS THEN
            l_records_updated := 'Y';
   END;

   IF l_records_updated = 'Y' THEN
   BEGIN
      INV_ENI_ITEMS_STAR_PKG.Sync_Star_ItemCatg_From_COI(
                  p_api_version         => 1.0
                 ,p_init_msg_list       => FND_API.g_TRUE
		 ,p_set_process_id      => g_xset_id
	         ,x_return_status       => l_return_Status
	         ,x_msg_count           => l_msg_count
	         ,x_msg_data            => l_msg_data);
      -- End Bug: 3185516
      -- If unexpected error in Sync_Star_ItemCatg_From_COI,
      -- stop the processing.
      /*Bug 4569555
      IF ( l_return_status = fnd_api.g_RET_STS_UNEXP_ERROR ) THEN
            l_RETCODE := G_ERROR;
            RAISE Processing_Error;
       END IF;*/
   END;
   END IF;
  /* Bug 4527222*/

   --Populate Bulkload Recs
   IF g_request_id IS NOT NULL AND g_request_id <> -1 THEN
      FOR cr IN populate_catg_bulkloadrecs(g_request_id ,g_xset_id)
      LOOP
      INSERT INTO MTL_ITEM_BULKLOAD_RECS(
           REQUEST_ID
          ,ENTITY_TYPE
          ,INVENTORY_ITEM_ID
          ,ORGANIZATION_ID
          ,CATEGORY_SET_ID
	       ,CATEGORY_ID
          ,TRANSACTION_TYPE
          ,CREATION_DATE
          ,CREATED_BY
          ,LAST_UPDATE_DATE
          ,LAST_UPDATED_BY
          ,LAST_UPDATE_LOGIN)
      VALUES(
           cr.REQUEST_ID
          ,'ITEM_CATEGORY'
          ,cr.INVENTORY_ITEM_ID
          ,cr.ORGANIZATION_ID
          ,cr.CATEGORY_SET_ID
	       ,cr.CATEGORY_ID
          ,cr.TRANSACTION_TYPE
          ,NVL(cr.CREATION_DATE, SYSDATE)
          ,decode(cr.CREATED_BY, -99, g_user_id, NULL, g_user_id, cr.CREATED_BY)
          ,NVL(cr.LAST_UPDATE_DATE, SYSDATE)
          ,NVL(cr.LAST_UPDATED_BY, g_user_id)
          ,cr.LAST_UPDATE_LOGIN);
      END LOOP;

      BEGIN
         INV_ITEM_EVENTS_PVT.Invoke_ICX_APIs(
            p_entity_type       => 'ITEM_CATEGORY'
           ,p_xset_id           =>  g_xset_id
           ,p_dml_type          => 'BULK'
           ,p_request_id        =>  g_request_id );

         EXCEPTION
            WHEN OTHERS THEN
               NULL;
      END ;

   END IF;
   --Populate Bulkload Recs


   --R12: Business Event Enhancement
   IF (g_request_id <> -1) THEN
      BEGIN
         INV_ITEM_EVENTS_PVT.Raise_Events(
            p_request_id    =>  g_request_id
	   ,p_xset_id       =>  g_xset_id
           ,p_event_name    => 'EGO_WF_WRAPPER_PVT.G_ITEM_CAT_ASSIGN_EVENT'
           ,p_dml_type      => 'BULK');
         EXCEPTION
           WHEN OTHERS THEN
             NULL;
      END;
   END IF;
   --R12: Business Event Enhancement

   -- Check of commit
   IF ( FND_API.To_Boolean( l_commit ) ) THEN
      COMMIT WORK;
      -- Call IP Intermedia Sync
      INV_ITEM_EVENTS_PVT.Sync_IP_IM_Index;
   END IF;

   --
   -- Delete successfully processed records from the interface table
   --

   IF ( p_delete_rec_flag = 1 ) THEN

      IF (l_debug = 1) THEN
         INV_ITEM_MSG.Debug(Mctx, 'calling delete_OI_records');
      END IF;

      INV_ITEM_CATEGORY_OI.delete_OI_records
      (  p_commit         =>  l_commit
      ,  p_rec_set_id     =>  g_xset_id
      ,  x_return_status  =>  l_return_status
      );

      IF (l_debug = 1) THEN
         INV_ITEM_MSG.Debug(Mctx, 'done delete_OI_records: return_status=' || l_return_status);
      END IF;

      IF ( l_return_status <> fnd_api.g_RET_STS_SUCCESS ) THEN
         RAISE Processing_Error;
      END IF;

      -- Write all accumulated messages
      INV_ITEM_MSG.Write_List (p_delete => TRUE);

   END IF;  -- p_delete_rec_flag = 1

   --
   -- Assign conc request return code
   --

   RETCODE := l_RETCODE;
   IF ( l_RETCODE = G_SUCCESS ) THEN
      ERRBUF := FND_MESSAGE.Get_String('INV', 'INV_ICOI_SUCCESS');
   ELSIF ( l_RETCODE = G_WARNING ) THEN
      ERRBUF := FND_MESSAGE.Get_String('INV', 'INV_ICOI_WARNING');
   ELSE
      ERRBUF := FND_MESSAGE.Get_String('INV', 'INV_ICOI_FAILURE');
   END IF;

EXCEPTION

   WHEN Processing_Error THEN
      RETCODE := G_ERROR;
      ERRBUF := FND_MESSAGE.Get_String('INV', 'INV_ICOI_FAILURE');

      -- Write all accumulated messages
      INV_ITEM_MSG.Write_List (p_delete => TRUE);

      -- Check of commit
      IF ( FND_API.To_Boolean(l_commit) ) THEN
         COMMIT WORK;
      END IF;

   WHEN others THEN
      RETCODE := G_ERROR;
      ERRBUF := FND_MESSAGE.Get_String('INV', 'INV_ICOI_FAILURE');

      l_err_text := SUBSTRB(SQLERRM, 1,240);

      INV_ITEM_MSG.Add_Message
      (  p_Msg_Name        =>  'INV_ITEM_UNEXPECTED_ERROR'
      ,  p_token1          =>  'PKG_NAME'
      ,  p_value1          =>  G_PKG_NAME
      ,  p_token2          =>  'PROCEDURE_NAME'
      ,  p_value2          =>  l_api_name
      ,  p_token3          =>  'ERROR_TEXT'
      ,  p_value3          =>  l_err_text
      ,  p_transaction_id  =>  l_transaction_id
      );

      -- Write all accumulated messages
      INV_ITEM_MSG.Write_List (p_delete => TRUE);

      -- Check of commit
      IF ( FND_API.To_Boolean(l_commit) ) THEN
         COMMIT WORK;
      END IF;

END process_Item_Category_records;
------------------------------------------------------------------------------


---------------------------- convert_Values_to_Ids ---------------------------
/*
PROCEDURE convert_Values_to_Ids
(
)
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
END convert_Values_to_Ids;
*/

------------------------------ delete_OI_records -----------------------------

PROCEDURE delete_OI_records
(
   p_commit         IN   VARCHAR2  DEFAULT  fnd_api.g_FALSE
,  p_rec_set_id     IN   NUMBER
,  x_return_status  OUT  NOCOPY VARCHAR2
)
IS
   l_api_name       CONSTANT  VARCHAR2(30)  := 'delete_OI_records';
   Mctx             INV_ITEM_MSG.Msg_Ctx_type;

   l_del_process_flag    NUMBER  :=  7;  -- process_flag value for records to be deleted
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   Mctx.Package_Name   := G_PKG_NAME;
   Mctx.Procedure_Name := l_api_name;

   IF (l_debug = 1) THEN
      INV_ITEM_MSG.Debug(Mctx, 'begin');
   END IF;

   -- Initialize API return status to success
   x_return_status := FND_API.g_RET_STS_SUCCESS;

   LOOP
      DELETE FROM mtl_item_categories_interface
      WHERE  set_process_id = p_rec_set_id
        AND  process_flag = l_del_process_flag
        AND  rownum < G_ROWS_TO_COMMIT;

      EXIT WHEN SQL%NOTFOUND;

      --INV_ITEM_MSG.Debug(Mctx, 'deleted ' || TO_CHAR(SQL%ROWCOUNT) || ' record(s)');

      -- Check of commit
      IF ( FND_API.To_Boolean(p_commit) ) THEN
         COMMIT WORK;
      END IF;

   END LOOP;

EXCEPTION

   WHEN others THEN
      x_return_status := FND_API.g_RET_STS_UNEXP_ERROR;

      INV_ITEM_MSG.Add_Unexpected_Error (Mctx, SQLERRM);

      -- Check of commit
      IF ( FND_API.To_Boolean(p_commit) ) THEN
         COMMIT WORK;
      END IF;

END delete_OI_records;
------------------------------------------------------------------------------


END INV_ITEM_CATEGORY_OI;

/
