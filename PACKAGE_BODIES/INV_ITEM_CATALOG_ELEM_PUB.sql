--------------------------------------------------------
--  DDL for Package Body INV_ITEM_CATALOG_ELEM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_ITEM_CATALOG_ELEM_PUB" AS
/* $Header: INVCEOIB.pls 120.2 2007/05/28 11:48:05 anmurali ship $ */
---------------------- Package variables and constants -----------------------

G_PKG_NAME       CONSTANT  VARCHAR2(30)  :=  'INV_ITEM_CATALOG_ELEM_PUB';

G_SUCCESS          CONSTANT  NUMBER  :=  0;
G_WARNING          CONSTANT  NUMBER  :=  1;
G_ERROR            CONSTANT  NUMBER  :=  2;

G_ROWS_TO_COMMIT   CONSTANT  NUMBER  :=  500;

------------------------------------------------------------------------------

------------------------ process_Item_Catalog_element_records ---------------------

PROCEDURE Process_item_descr_elements
     (
        p_api_version        IN   NUMBER
     ,  p_init_msg_list      IN   VARCHAR2
     ,  p_commit_flag        IN   VARCHAR2
     ,  p_validation_level   IN   NUMBER
     ,  p_inventory_item_id  IN   NUMBER
     ,  p_item_number        IN   VARCHAR2
     ,  p_item_desc_element_table IN ITEM_DESC_ELEMENT_TABLE
     ,  x_generated_descr    OUT NOCOPY VARCHAR2
     ,  x_return_status      OUT NOCOPY VARCHAR2
     ,  x_msg_count          OUT NOCOPY NUMBER
     ,  x_msg_data           OUT NOCOPY VARCHAR2
     )
IS
   l_api_name       CONSTANT  VARCHAR2(30)  := 'Process_item_descr_elements';
     -- On addition of any Required parameters the major version needs
     -- to change i.e. for eg. 1.X to 2.X.
     -- On addition of any Optional parameters the minor version needs
     -- to change i.e. for eg. X.6 to X.7.

   l_api_version    CONSTANT NUMBER     := 1.0;

   Mctx             INV_ITEM_MSG.Msg_Ctx_type;

   Processing_Error     EXCEPTION;

   ret_code             NUMBER           :=  0;
   l_err_text           VARCHAR2(2000);

   l_return_status      VARCHAR2(1);  -- :=  fnd_api.g_MISS_CHAR
   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2(2000);

   l_msg_name           VARCHAR2(2000);

   l_column_name        VARCHAR2(30);
   l_token              VARCHAR2(30);
   l_token_value        VARCHAR2(30);
   l_error_msg          VARCHAR2(2000);
   l_item_desc_element_table ITEM_DESC_ELEMENT_TABLE;
BEGIN

   -- Check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version,
					p_api_version 	,
					l_api_name	,
					G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

   -- Standard Start of API savepoint
   SAVEPOINT	Process_item_descr_elem_PUB;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   INV_ITEM_MSG.set_Message_Mode('PLSQL');

-- Set message level
   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
     INV_ITEM_MSG.set_Message_Level(INV_ITEM_MSG.g_Level_Warning);
   END IF;

   -- Define message context
   Mctx.Package_Name   := G_PKG_NAME;
   Mctx.Procedure_Name := l_api_name;

   -- Set global package variables for the current import session

   INV_ITEM_MSG.g_Table_Name := 'p_item_desc_element_table';

   INV_ITEM_MSG.g_User_id    := FND_GLOBAL.user_id        ;
   INV_ITEM_MSG.g_Login_id   := FND_GLOBAL.login_id       ;
   INV_ITEM_MSG.g_Prog_appid := FND_GLOBAL.prog_appl_id   ;
   INV_ITEM_MSG.g_Prog_id    := FND_GLOBAL.conc_program_id;
   INV_ITEM_MSG.g_Request_id := FND_GLOBAL.conc_request_id;

   x_return_status := fnd_api.g_RET_STS_SUCCESS;
   ------------------------------------------------------------------------------------------
   -- Process step 1: Loop through item catlog group elements interface records            --
   --  (a) Check for duplicate records in the interface table table  --
   ------------------------------------------------------------------------------------------
   INV_ITEM_MSG.Debug(Mctx, 'starting the main ICatalogOI loop step1');
   l_item_desc_element_table := p_item_desc_element_table;
   FOR icoi_rec IN l_item_desc_element_table.first .. l_item_desc_element_table.last-1 LOOP  --{
     FOR icoi_rec_dup IN icoi_rec+1 .. l_item_desc_element_table.last LOOP  --{
       IF ( l_item_desc_element_table.EXISTS(icoi_rec) ) THEN
       IF (l_item_desc_element_table(icoi_rec).ELEMENT_NAME = l_item_desc_element_table(icoi_rec_dup).ELEMENT_NAME)
         THEN
           INV_ITEM_MSG.Debug(Mctx, 'Duplicate record found' || to_char(icoi_rec_dup) );
           INV_ITEM_MSG.Add_Message
              (  p_Msg_Name        =>  'INV_CEOI_DUP_ELEM_REC'
              ,  p_token1          =>  'ELEMENT_NAME'
              ,  p_value1          =>  l_item_desc_element_table(icoi_rec).ELEMENT_NAME
              );
           l_item_desc_element_table.DELETE(icoi_rec_dup);
	   x_return_status := fnd_api.g_RET_STS_ERROR;
       END IF;
       END IF;
     END LOOP;--} icoi_csr_dup
   END LOOP;  --} icoi_csr

   INV_ITEM_MSG.Debug(Mctx, 'Write all accumulated messages' );
   -- Write all accumulated messages
   INV_ITEM_MSG.Write_List (p_delete => TRUE);

   ------------------------------------------------------------------------------------------
   -- Process step 2: Loop through item catlog group elements interface records            --
   --  (a) call the API to create item catalog group element values assignment record in the production table  --
   --  (b) update the current interface record process_flag and other converted values     --
   ------------------------------------------------------------------------------------------

   INV_ITEM_MSG.Debug(Mctx, 'starting the main ICatalogOI loop step2');

    FOR icoi_rec IN l_item_desc_element_table.first .. l_item_desc_element_table.last LOOP  --{

      l_return_status := fnd_api.g_RET_STS_SUCCESS;

      --  call the API to process item catalog element values

      IF ( l_item_desc_element_table.EXISTS(icoi_rec) ) THEN

            INV_ITEM_MSG.Debug(Mctx, 'calling INV_ITEM_CATALOG_ELE_PVT.Create_Catalog_group_ele_Assignment');
            INV_ITEM_MSG.Debug(Mctx, 'Element Name:'||l_item_desc_element_table(icoi_rec).ELEMENT_NAME);

            INV_ITEM_CATALOG_ELE_PVT.Catalog_Grp_Ele_Val_Assignment
            (
               p_api_version        =>  1.0
            ,  p_init_msg_list      =>  fnd_api.g_TRUE
            ,  p_commit             =>  fnd_api.g_FALSE
            ,  p_validation_level   =>  p_validation_level
            ,  p_inventory_item_id  =>  p_inventory_item_id
            ,  p_item_number        =>  p_item_number
            ,  p_element_name       =>  l_item_desc_element_table(icoi_rec).ELEMENT_NAME
            ,  p_element_value      =>  l_item_desc_element_table(icoi_rec).ELEMENT_VALUE
            ,  p_default_element_flag => l_item_desc_element_table(icoi_rec).DESCRIPTION_DEFAULT
            ,  x_return_status      =>  l_return_status
            ,  x_msg_count          =>  l_msg_count
            ,  x_msg_data           =>  l_msg_data
            );

            IF ( l_return_status = fnd_api.g_RET_STS_SUCCESS ) THEN
               NULL;
            ELSE
               INV_ITEM_MSG.Debug(Mctx, 'error in Catalog_Grp_Ele_Val_Assignment. Msg count=' || TO_CHAR(INV_ITEM_MSG.Count_Msg));
       	       x_return_status := l_return_status;
            END IF;  -- l_return_status

            -- If unexpected error in Catalog_Grp_Ele_Val_Assignment API, stop the processing
            IF ( l_return_status = fnd_api.g_RET_STS_UNEXP_ERROR ) THEN
       	       x_return_status := l_return_status;
               RAISE Processing_Error;
            END IF;

      END IF;  --  p_item_desc_element_table.EXISTS
      -- Write all accumulated messages
      INV_ITEM_MSG.Write_List (p_delete => TRUE);

   END LOOP;  --} icoi_csr

   INVICGDS.inv_get_icg_desc(
	inv_item_id=>p_inventory_item_id,
	first_elem_break=>30,
	use_name_as_first_elem=>fnd_profile.value('USE_NAME_ICG_DESC'),
	description_for_item=>x_generated_descr,
	delimiter=>null,
	show_all_delim=>'Y',
	error_text=>l_error_msg);

   -- Check of commit
   IF ( FND_API.To_Boolean(p_commit_flag) ) THEN
      COMMIT WORK;
   END IF;
   --
   -- Determine request return code
   --
   FND_MSG_PUB.Count_And_Get
    (  	p_count        =>      x_msg_count,
    	p_data         =>      x_msg_data
    );

EXCEPTION
   WHEN Processing_Error THEN
      ROLLBACK TO Process_item_descr_elem_PUB;
      -- Write all accumulated messages
      INV_ITEM_MSG.Write_List (p_delete => TRUE);

      FND_MSG_PUB.Count_And_Get
	(  	p_count        =>      x_msg_count,
   	        p_data         =>      x_msg_data
	);

   WHEN others THEN
      ROLLBACK TO Process_item_descr_elem_PUB;
      l_err_text := SUBSTRB(SQLERRM, 1,240);
      x_return_status := fnd_api.g_RET_STS_UNEXP_ERROR;
      INV_ITEM_MSG.Add_Message
      (  p_Msg_Name        =>  'INV_ITEM_UNEXPECTED_ERROR'
      ,  p_token1          =>  'PKG_NAME'
      ,  p_value1          =>  G_PKG_NAME
      ,  p_token2          =>  'PROCEDURE_NAME'
      ,  p_value2          =>  l_api_name
      ,  p_token3          =>  'ERROR_TEXT'
      ,  p_value3          =>  l_err_text
      );

      -- Write all accumulated messages
      INV_ITEM_MSG.Write_List (p_delete => TRUE);

      FND_MSG_PUB.Count_And_Get
	(  	p_count        =>      x_msg_count,
   	        p_data         =>      x_msg_data
	);

END Process_item_descr_elements;
------------------------------------------------------------------------------


------------------------ process_Item_Catlog_group_Interface_records -----------------------

PROCEDURE process_Item_Catalog_grp_recs
(
   ERRBUF              OUT  NOCOPY VARCHAR2
,  RETCODE             OUT  NOCOPY NUMBER
,  p_rec_set_id        IN   NUMBER
,  p_upload_rec_flag   IN   NUMBER
,  p_delete_rec_flag   IN   NUMBER
,  p_commit_flag       IN   NUMBER
,  p_prog_appid        IN   NUMBER
,  p_prog_id           IN   NUMBER
,  p_request_id        IN   NUMBER
,  p_user_id           IN   NUMBER
,  p_login_id          IN   NUMBER
)
IS
   l_api_name       CONSTANT  VARCHAR2(30)  := 'process_Item_Catalog_grp_recs';
   Mctx             INV_ITEM_MSG.Msg_Ctx_type;

   --
   -- Cursor for the duplicate check (Create_Catalog_group_Assignment)
   --
   CURSOR icoi_csr_dup
   IS
      SELECT
         mdei_dup.rowid
      ,  mdei_dup.transaction_id
      ,  mdei_dup.element_name
      FROM
         mtl_desc_elem_val_interface  mdei_dup
      WHERE
         mdei_dup.rowid > (select rowid
                           FROM mtl_desc_elem_val_interface  mdei
                           WHERE mdei.set_process_id = g_xset_id
                           AND mdei.process_flag IN (1, 2)
                           AND rownum < 2
                           AND (mdei.inventory_item_id = mdei_dup.inventory_item_id
                           OR mdei.item_number = mdei_dup.item_number )
                           AND mdei.element_name = mdei_dup.element_name
                          )
      FOR UPDATE OF mdei_dup.transaction_id;

   --
   -- Cursor for the main loop (Create_Catalog_group_Assignment)
   --
   CURSOR icoi_csr
   IS
      SELECT
         mdei.rowid, mdei.transaction_id
      ,  mdei.inventory_item_id
      ,  mdei.element_name, mdei.element_value
      ,  mdei.element_sequence, mdei.item_number
      ,  mdei.default_element_flag
      FROM
         mtl_desc_elem_val_interface  mdei
      WHERE
         mdei.set_process_id = g_xset_id
         AND mdei.process_flag IN (1, 2, 4) --R12C
      ORDER BY mdei.item_number,mdei.inventory_item_id
      FOR UPDATE OF mdei.transaction_id;

   l_process_flag       NUMBER;

   Processing_Error     EXCEPTION;

   ret_code             NUMBER           :=  0;
   l_err_text           VARCHAR2(2000);

   l_commit             VARCHAR2(1);
   l_return_status      VARCHAR2(1);  -- :=  fnd_api.g_MISS_CHAR
   l_msg_count          NUMBER;
   l_msg_data           VARCHAR2(2000);

   l_msg_name           VARCHAR2(2000);

   l_RETCODE            NUMBER;       -- G_SUCCESS, G_WARNING, G_ERROR
   l_column_name        VARCHAR2(30);
   l_token              VARCHAR2(30);
   l_token_value        VARCHAR2(30);
   l_element_name       VARCHAR2(200);
   l_element_value      VARCHAR2(200);
   l_default_element_flag  VARCHAR2(1);
   l_transaction_id     NUMBER;
   l_inventory_item_id  NUMBER;
   l_item_number      VARCHAR2(200);
   flex_id              NUMBER;
   item_id              NUMBER;

BEGIN

   INV_ITEM_MSG.Initialize;

   INV_ITEM_MSG.set_Message_Mode ('CP_LOG');

   -- Set message level

--   INV_ITEM_MSG.set_Message_Level (INV_ITEM_MSG.g_Level_Statement);
   INV_ITEM_MSG.set_Message_Level (INV_ITEM_MSG.g_Level_Error);

   -- Define message context
   Mctx.Package_Name   := G_PKG_NAME;
   Mctx.Procedure_Name := l_api_name;

   INV_ITEM_MSG.Debug(Mctx, 'start rec_set_id = '|| TO_CHAR(p_rec_set_id));

   -- Set global package variables for the current import session

   g_xset_id    := p_rec_set_id;

   g_User_id    := NVL(p_user_id,    FND_GLOBAL.user_id         );
   g_Login_id   := NVL(p_login_id,   FND_GLOBAL.login_id        );
   g_Prog_appid := NVL(p_prog_appid, FND_GLOBAL.prog_appl_id    );
   g_Prog_id    := NVL(p_prog_id,    FND_GLOBAL.conc_program_id );
   g_Request_id := NVL(p_request_id, FND_GLOBAL.conc_request_id );

   INV_ITEM_MSG.g_Table_Name := 'MTL_DESC_ELEM_VAL_INTERFACE';

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
   -- Process step 1: Set process flag to 2                                            --
   ---------------------------------------------------------------------------------------

   INV_ITEM_MSG.Debug(Mctx, ' Set process flag to 2');

   UPDATE mtl_desc_elem_val_interface  mdei
   SET    process_flag = 2
   WHERE
      mdei.set_process_id = g_xset_id
      AND  mdei.process_flag = 1;

   ------------------------------------------------------------------------------------------
   -- Process step 2: Loop through item catlog group elements interface records            --
   --  (a) convert the item_number to irem_id                                              --
   --  (b) update the  interface records accordingly                                       --
   ------------------------------------------------------------------------------------------
   INV_ITEM_MSG.Debug(Mctx, 'starting the ICatalogOI loop to convert the item_number');

   IF p_upload_rec_flag = 1 THEN

     SELECT mtl_system_items_interface_s.NEXTVAL
       INTO l_transaction_id
       FROM dual;

     FOR icoi_rec1 IN icoi_csr LOOP

      -- Process flag for the current record is initially set to 4 (validation success).
      -- May be changed to 3 or 5, if any errors occur during validation.
        l_process_flag := 4;
        l_inventory_item_id := NULL;
      --
      -- Assign missing inventory_item_id from item_number
      --

        l_return_status := fnd_api.g_RET_STS_SUCCESS;

        item_id := icoi_rec1.inventory_item_id;
        l_item_number := icoi_rec1.item_number;

        IF ( l_item_number IS NOT NULL ) THEN
            ret_code := INVPUOPI.mtl_pr_parse_item_name (
                           l_item_number,
                           flex_id,
                           l_err_text );
            IF ( ret_code = 0 ) THEN
               l_inventory_item_id := flex_id;
               IF ((item_id IS NOT NULL)AND
		             (l_inventory_item_id <> item_id)) THEN
                  l_return_status := fnd_api.g_RET_STS_ERROR;
                  l_msg_name := 'INV_CEOI_ITEM_NUM_ID_MISMATCH';
                  l_token := 'VALUE1';
                  l_token_value := l_item_number;
                  l_column_name := 'ITEM_NUMBER';
                  l_token := 'VALUE2';
                  l_token_value := item_id;
                  l_column_name := 'INVENTORY_ITEM_ID';
                END IF;
            ELSE
               l_return_status := fnd_api.g_RET_STS_ERROR;
               l_msg_name := 'INV_ICOI_INVALID_ITEM_NUMBER';
               l_token := 'VALUE';
               l_token_value := l_item_number;
               l_column_name := 'ITEM_NUMBER';
            END IF;

        ELSIF ( item_id IS NULL )THEN
            l_return_status := fnd_api.g_RET_STS_ERROR;
            l_msg_name := 'INV_CEOI_MISS_ITEM_NUMBER';
            l_token := fnd_api.g_MISS_CHAR;
            l_token_value := l_item_number||item_id;
            l_column_name := 'ITEM_NUMBER';
        END IF;
        IF (l_return_status = fnd_api.g_RET_STS_ERROR) THEN
           INV_ITEM_MSG.Add_Message
         (  p_Msg_Name        =>  l_msg_name
         ,  p_token1          =>  l_token
         ,  p_value1          =>  l_token_value
         ,  p_column_name     =>  l_column_name
	      ,  p_transaction_id  =>  l_transaction_id
         );
           UPDATE mtl_desc_elem_val_interface
           SET
           transaction_id = l_transaction_id,
           request_id     = g_request_id,
           process_flag       =  3
           WHERE
           CURRENT OF icoi_csr;
        ELSIF ( l_inventory_item_id IS NOT NULL )THEN
           UPDATE mtl_desc_elem_val_interface
           SET
           inventory_item_id = l_inventory_item_id
           WHERE
           CURRENT OF icoi_csr;
        END IF;

     END LOOP;  -- icoi_rec1

     -- Check of commit
     IF ( FND_API.To_Boolean(l_commit) ) THEN
        COMMIT WORK;
     END IF;
   -- Write all accumulated messages
     INV_ITEM_MSG.Write_List (p_delete => TRUE);

   ------------------------------------------------------------------------------------------
   -- Process step 3: Loop through item catlog group elements interface records            --
   --  (a) Check for duplicate records in the interface table table  --
   --  (b) update the duplicate interface records process_flag                             --
   ------------------------------------------------------------------------------------------
     INV_ITEM_MSG.Debug(Mctx, 'starting the main ICatalogOI loop step3');

     SELECT mtl_system_items_interface_s.NEXTVAL
       INTO l_transaction_id
       FROM dual;

     FOR icoi_rec_dup IN icoi_csr_dup LOOP  --{

       INV_ITEM_MSG.Add_Message
         (  p_Msg_Name        =>  'INV_CEOI_DUP_ELEM_REC'
         ,  p_token1          =>  'ELEMENT_NAME'
         ,  p_value1          =>  icoi_rec_dup.ELEMENT_NAME
         ,  p_transaction_id  =>  l_transaction_id
         );


       UPDATE mtl_desc_elem_val_interface
       SET
         transaction_id = l_transaction_id,
         request_id     = g_request_id,
         process_flag       =  3
       WHERE
         CURRENT OF icoi_csr_dup;

     END LOOP;  --} icoi_csr_dup
   END IF; -- Upload Rec Flag is 1
     -- Check of commit
   IF ( FND_API.To_Boolean(l_commit) ) THEN
      COMMIT WORK;
   END IF;
   -- Write all accumulated messages
   INV_ITEM_MSG.Write_List (p_delete => TRUE);

   ------------------------------------------------------------------------------------------
   -- Process step 4: Loop through item catlog group elements interface records            --
   --  (a) call the API to create item catalog group element values assignment record in the production table  --
   --  (b) update the current interface record process_flag and other converted values     --
   ------------------------------------------------------------------------------------------

   INV_ITEM_MSG.Debug(Mctx, 'starting the main ICatalogOI loop step4');

   SELECT mtl_system_items_interface_s.NEXTVAL
     INTO l_transaction_id
     FROM dual;

   FOR icoi_rec IN icoi_csr LOOP  --{

      -- Process flag for the current record is initially set to 4 (validation success).
      -- May be changed to 3 or 5, if any errors occur during validation.
      l_process_flag := 4;

      --
      -- Assign missing inventory_item_id from item_number
      --

      l_return_status := fnd_api.g_RET_STS_SUCCESS;
      l_inventory_item_id := icoi_rec.inventory_item_id;
      l_item_number       := icoi_rec.item_number;
      l_element_value     := icoi_rec.element_value;
      l_element_name      := icoi_rec.element_name;
      l_default_element_flag := icoi_rec.default_element_flag;
      --
      -- If value-to-id conversions are successful,
      --  call the API to process item catalog element values

      IF ( l_process_flag = 4 AND p_upload_rec_flag = 1 ) THEN

            INV_ITEM_MSG.Debug(Mctx, 'calling INV_ITEM_CATALOG_ELE_PVT.Create_Catalog_group_ele_Assignment:'||l_element_name);

            INV_ITEM_CATALOG_ELE_PVT.Catalog_Grp_Ele_Val_Assignment
            (
               p_api_version        =>  1.0
            ,  p_init_msg_list      =>  fnd_api.g_TRUE
            ,  p_commit             =>  fnd_api.g_FALSE
            ,  p_validation_level   =>  g_VALIDATE_IDS
            ,  p_inventory_item_id  =>  l_inventory_item_id
            ,  p_item_number        =>  l_item_number
            ,  p_element_name       =>  l_element_name
            ,  p_element_value      =>  l_element_value
            ,  p_default_element_flag =>  l_default_element_flag
            ,  x_return_status      =>  l_return_status
            ,  x_msg_count          =>  l_msg_count
            ,  x_msg_data           =>  l_msg_data
            );

            IF ( l_return_status = fnd_api.g_RET_STS_SUCCESS ) THEN
               l_process_flag := 7;
            ELSE
               l_process_flag := 3;
               INV_ITEM_MSG.Debug(Mctx, 'error in Catalog_Grp_Ele_Val_Assignment. Msg count=' || TO_CHAR(INV_ITEM_MSG.Count_Msg));
               l_RETCODE := G_WARNING;
            END IF;  -- l_return_status

            -- If unexpected error in Catalog_Grp_Ele_Val_Assignment API, stop the processing
            IF ( l_return_status = fnd_api.g_RET_STS_UNEXP_ERROR ) THEN
               l_RETCODE := G_ERROR;
               RAISE Processing_Error;
            END IF;

      END IF;  -- process_flag = 4 AND p_upload_rec_flag = 1

      -- Write all accumulated messages
      INV_ITEM_MSG.Write_List (p_delete => TRUE);

      --
      -- Update the current interface record
      --

      INV_ITEM_MSG.Debug(Mctx, 'update interface record');

      UPDATE mtl_desc_elem_val_interface
      SET
         transaction_id     =  l_transaction_id
      ,  inventory_item_id  =  l_inventory_item_id
      ,  item_number        =  l_item_number
      ,  process_flag       =  l_process_flag
      ,  program_application_id  =  g_prog_appid
      ,  program_id         =  g_prog_id
      ,  program_update_date=  SYSDATE
      ,  request_id         =  g_request_id
      ,  last_update_date   =  SYSDATE
      ,  last_updated_by    =  g_user_id
      ,  last_update_login  =  g_login_id
      WHERE
         CURRENT OF icoi_csr;

   END LOOP;  --} icoi_csr

   -- Check of commit
   IF ( FND_API.To_Boolean(l_commit) ) THEN
      COMMIT WORK;
   END IF;

   --
   -- Delete successfully processed records from the interface table
   --

   IF (p_delete_rec_flag = 1) THEN

      INV_ITEM_MSG.Debug(Mctx, 'calling delete_OI_records');

      INV_ITEM_CATALOG_ELEM_PUB.delete_OI_records
      (  p_commit         =>  l_commit
      ,  p_rec_set_id     =>  g_xset_id
      ,  x_return_status  =>  l_return_status
      );

      INV_ITEM_MSG.Debug(Mctx, 'done delete_OI_records: return_status=' || l_return_status);

      IF ( l_return_status <> fnd_api.g_RET_STS_SUCCESS ) THEN
         RAISE Processing_Error;
      END IF;

      -- Write all accumulated messages
      INV_ITEM_MSG.Write_List (p_delete => TRUE);

   END IF;  -- p_delete_rec_flag = 1

   --
   -- Determine request return code
   --

   RETCODE := l_RETCODE;
   IF ( l_RETCODE = G_SUCCESS ) THEN
      ERRBUF := FND_MESSAGE.Get_String('INV', 'INV_ICG_DESC_ELEM_SUCCESS');
   ELSIF ( l_RETCODE = G_WARNING ) THEN
      ERRBUF := FND_MESSAGE.Get_String('INV', 'INV_ICG_DESC_ELEM_WARNING');
   ELSE
      ERRBUF := FND_MESSAGE.Get_String('INV', 'INV_ICG_DESC_ELEM_FAILURE');
   END IF;

EXCEPTION

   WHEN Processing_Error THEN
      RETCODE := G_ERROR;
      ERRBUF := FND_MESSAGE.Get_String('INV', 'INV_ICG_DESC_ELEM_FAILURE');

      -- Write all accumulated messages
      INV_ITEM_MSG.Write_List (p_delete => TRUE);

      -- Check of commit
      IF ( FND_API.To_Boolean(l_commit) ) THEN
         COMMIT WORK;
      END IF;

   WHEN others THEN
      RETCODE := G_ERROR;
      ERRBUF := FND_MESSAGE.Get_String('INV', 'INV_ICG_DESC_ELEM_FAILURE');

      l_err_text := SUBSTRB(SQLERRM, 1,240);

      INV_ITEM_MSG.Add_Message
      (  p_Msg_Name        =>  'INV_ITEM_UNEXPECTED_ERROR'
      ,  p_token1          =>  'PACKAGE_NAME'
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

END process_Item_Catalog_grp_recs;
------------------------------------------------------------------------------

------------------------------ delete_OI_records -----------------------------

PROCEDURE delete_OI_records
(
   p_commit         IN   VARCHAR2
,  p_rec_set_id     IN   NUMBER
,  x_return_status  OUT  NOCOPY VARCHAR2
)
IS
   l_api_name       CONSTANT  VARCHAR2(30)  := 'delete_OI_records';
   Mctx             INV_ITEM_MSG.Msg_Ctx_type;

   l_del_process_flag    NUMBER  :=  7;  -- process_flag value for records to be deleted
BEGIN

   Mctx.Package_Name   := G_PKG_NAME;
   Mctx.Procedure_Name := l_api_name;

   INV_ITEM_MSG.Debug(Mctx, 'begin');

   -- Initialize API return status to success
   x_return_status := FND_API.g_RET_STS_SUCCESS;

   LOOP
     DELETE FROM mtl_desc_elem_val_interface
      WHERE  set_process_id = p_rec_set_id
        AND  process_flag = l_del_process_flag
        AND  rownum < G_ROWS_TO_COMMIT;

      EXIT WHEN SQL%NOTFOUND;

      INV_ITEM_MSG.Debug(Mctx, 'deleted ' || TO_CHAR(SQL%ROWCOUNT) || ' record(s)');

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

END INV_ITEM_CATALOG_ELEM_PUB;

/
