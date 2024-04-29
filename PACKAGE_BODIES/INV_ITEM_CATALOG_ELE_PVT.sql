--------------------------------------------------------
--  DDL for Package Body INV_ITEM_CATALOG_ELE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_ITEM_CATALOG_ELE_PVT" AS
/* $Header: INVCEAPB.pls 120.2 2006/09/15 10:09:09 supsrini ship $ */
---------------------- Package variables and constants -----------------------

G_PKG_NAME            CONSTANT  VARCHAR2(30)  :=  'INV_ITEM_CATALOG_ELE_PVT';

G_INV_APP_ID          CONSTANT  NUMBER        :=  401;
G_ELEM_VAL_LENGTH     CONSTANT  NUMBER        :=  30;
G_INV_APP_SHORT_NAME  CONSTANT  VARCHAR2(3)   :=  'INV';

------------------------- Create_Category_Assignment -------------------------

PROCEDURE Catalog_Grp_Ele_Val_Assignment
(
   p_api_version        IN   NUMBER
,  p_init_msg_list      IN   VARCHAR2
,  p_commit             IN   VARCHAR2
,  p_validation_level   IN   NUMBER
,  p_inventory_item_id  IN   NUMBER
,  p_item_number        IN   VARCHAR2
,  p_element_name       IN   VARCHAR2
,  p_element_value      IN   VARCHAR2
,  p_default_element_flag IN VARCHAR2
,  x_return_status      OUT NOCOPY VARCHAR2
,  x_msg_count          OUT NOCOPY NUMBER
,  x_msg_data           OUT NOCOPY VARCHAR2
)
IS
   l_api_name        CONSTANT  VARCHAR2(30)  := 'Catalog_Grp_Ele_Val_Assignment';
   l_api_version     CONSTANT  NUMBER        := 1.0;
   Mctx              INV_ITEM_MSG.Msg_Ctx_type;

   l_element_name                VARCHAR2(200);
   l_exists                      VARCHAR2(1);
   l_inventory_item_id           NUMBER;
   flex_id            NUMBER;
   l_grp_id           NUMBER;

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
   l_org_id             NUMBER;

   l_item_number        VARCHAR2(40); --5522789

   CURSOR org_item_exists_csr
   (  p_inventory_item_id  NUMBER
   ) IS
      SELECT organization_id
      FROM  mtl_system_items_b
      WHERE  inventory_item_id = p_inventory_item_id;


   CURSOR catalog_group_element_csr (p_element_name VARCHAR2,p_inventory_item_id NUMBER)
   IS
      SELECT  element_name
      FROM  mtl_descr_element_values
      WHERE  inventory_item_id = p_inventory_item_id
      AND    element_name = p_element_name;

   CURSOR catalog_group_csr (p_inventory_item_id NUMBER)
   IS
      SELECT  item_Catalog_group_id
      FROM  mtl_system_items_b
      WHERE  inventory_item_id = p_inventory_item_id
      AND    item_Catalog_group_id IS NOT NULL;


BEGIN

   -- Set savepoint
   SAVEPOINT Catalog_Grp_Ele_Val_Assign_PVT;

--   INVPUTLI.info('Add_Message: p_Msg_Name=' || p_Msg_Name);

--dbms_output.put_line('Enter INV_ITEM_CATALOG_ELE_PVT.Catalog_Grp_Ele_Val_Assignment');

   -- Check for call compatibility
   IF NOT FND_API.Compatible_API_Call (l_api_version, p_api_version,
                                       l_api_name, G_PKG_NAME)
   THEN
      RAISE FND_API.g_EXC_UNEXPECTED_ERROR;
   END IF;

--dbms_output.put_line('Before Initialize message list.');

   -- Initialize message list
   IF (FND_API.To_Boolean (p_init_msg_list)) THEN
      INV_ITEM_MSG.Initialize;
   END IF;

   -- Define message context
   Mctx.Package_Name   := G_PKG_NAME;
   Mctx.Procedure_Name := l_api_name;

   -- Initialize API return status to success
   x_return_status := FND_API.g_RET_STS_SUCCESS;

   -- Check for NULL parameter values

--dbms_output.put_line('Before IS NULL ; x_return_status = ' || x_return_status);

   IF (( p_inventory_item_id IS NULL ) AND ( p_item_number IS NULL )) OR
      ( p_element_name IS NULL )
   THEN
      INV_ITEM_MSG.Add_Error('INV_INVALID_ARG_NULL_VALUE');
      RAISE FND_API.g_EXC_ERROR;
   END IF;

   INV_ITEM_MSG.Debug(Mctx, 'Validate item');

   -- Validate item
   INV_ITEM_MSG.Debug(Mctx, 'assign missing inventory_item_id');
   l_inventory_item_id := p_inventory_item_id;

/** checking the validation level, to convert the item_number to item_id ***/
   IF (p_validation_level IN (INV_ITEM_CATALOG_ELEM_PUB.g_VALIDATE_ALL,INV_ITEM_CATALOG_ELEM_PUB.g_VALIDATE_LEVEL_FULL)) THEN
      IF ( p_item_number IS NOT NULL ) THEN
          ret_code := INVPUOPI.mtl_pr_parse_item_name (
                           p_item_number,
                           flex_id,
                           l_err_text );

            IF ( ret_code = 0 ) THEN
               l_inventory_item_id := flex_id;
               IF ( p_inventory_item_id <> -999 AND p_inventory_item_id <> l_inventory_item_id) THEN
                  l_return_status := fnd_api.g_RET_STS_ERROR;
                  l_msg_name := 'INV_CEOI_ITEM_NUM_ID_MISMATCH';
                  l_token := 'VALUE1';
                  l_token_value := p_item_number;
                  l_column_name := 'ITEM_NUMBER';
                  l_token := 'VALUE2';
                  l_token_value := p_inventory_item_id;
                  l_column_name := 'INVENTORY_ITEM_ID';
                END IF;
            ELSE
               l_return_status := fnd_api.g_RET_STS_ERROR;
               l_msg_name := 'INV_ICOI_INVALID_ITEM_NUMBER';
               l_token := 'VALUE';
               l_token_value := p_item_number;
               l_column_name := 'ITEM_NUMBER';
            END IF;

      END IF;
       IF (l_return_status = fnd_api.g_RET_STS_ERROR) THEN
         INV_ITEM_MSG.Add_Message
         (  p_Msg_Name        =>  l_msg_name
         ,  p_token1          =>  l_token
         ,  p_value1          =>  l_token_value
         ,  p_column_name     =>  l_column_name
         );
         RAISE FND_API.g_EXC_ERROR;
       END IF;

     END IF;/*validation_level check***/

--dbms_output.put_line('Before OPEN org_item_exists_csr ; x_return_status = ' || x_return_status);

   OPEN org_item_exists_csr (l_inventory_item_id);
   FETCH org_item_exists_csr INTO l_org_id;
   IF (org_item_exists_csr%NOTFOUND) THEN
      CLOSE org_item_exists_csr;
      INV_ITEM_MSG.Add_Error('INV_ORGITEM_ID_NOT_FOUND');
      RAISE FND_API.g_EXC_ERROR;
   END IF;
   CLOSE org_item_exists_csr;

--dbms_output.put_line('After OPEN org_item_exists_csr ; x_return_status = ' || x_return_status);

   INV_ITEM_MSG.Debug(Mctx, 'Validate catalog Group name');

-- Validate catalog group name

   OPEN catalog_group_csr (l_inventory_item_id);
   FETCH catalog_group_csr INTO l_grp_id;

   IF (catalog_group_csr%NOTFOUND) THEN
      CLOSE catalog_group_csr;
      INV_ITEM_MSG.Add_Error('INV_CEOI_CAT_GRP_NOT_FOUND');
      RAISE FND_API.g_EXC_ERROR;
   END IF;
   CLOSE catalog_group_csr;

   INV_ITEM_MSG.Debug(Mctx, 'Validate catalog Element name');
-- Validate catalog element name

   OPEN catalog_group_element_csr (p_element_name,l_inventory_item_id);
   FETCH catalog_group_element_csr INTO l_element_name;

   IF (catalog_group_element_csr%NOTFOUND) THEN
      CLOSE catalog_group_element_csr;
      INV_ITEM_MSG.Add_Error
      (  p_Msg_Name  =>'INV_CEOI_CAT_GRP_ELE_NOT_FOUND'
      ,  p_token     => 'ELEMENT_NAME'
      ,  p_value     => p_element_name );
      RAISE FND_API.g_EXC_ERROR;
   END IF;
   CLOSE catalog_group_element_csr;

   INV_ITEM_MSG.Debug(Mctx, 'Validate catalog Element value');
-- Validate catalog element value length

   IF (length(p_element_value) > G_ELEM_VAL_LENGTH) THEN
      INV_ITEM_MSG.Add_Error
      (  p_Msg_Name  =>'INV_CEOI_CAT_GRP_ELE_VAL_LEN_M'
      ,  p_token     => 'ELEMENT_NAME'
      ,  p_value     => p_element_name );
      RAISE FND_API.g_EXC_ERROR;
   END IF;

-- Bug: 4062893 Check whether user has EDIT privilege on item for EGO.
   IF INV_EGO_REVISION_VALIDATE.Get_Process_Control ='EGO_ITEM_BULKLOAD'
   AND INV_EGO_REVISION_VALIDATE.check_data_security(
				     p_function           => 'EGO_EDIT_ITEM'
				    ,p_object_name        => 'EGO_ITEM'
				    ,p_instance_pk1_value => l_inventory_item_id
				    ,p_instance_pk2_value => l_org_id
				    ,P_User_Id            => FND_GLOBAL.user_id) <> 'T'
   THEN
   --Bug: 5522789 Tokenise the message to display item number.
	IF p_item_number IS NULL THEN
		Select concatenated_segments
		into l_item_number
		From mtl_system_items_b_kfv
		where INVENTORY_ITEM_ID = l_inventory_item_id
		AND organization_id = l_org_id;
	ELSE
		l_item_number := p_item_number;
	END IF;

     INV_ITEM_MSG.Add_Error
      (  p_Msg_Name  =>'INV_IOI_ITEM_UPDATE_PRIV'
       ,  p_token     => 'VALUE'
       ,  p_value     =>  l_item_number );
      RAISE FND_API.g_EXC_ERROR;
   END IF;

-- Update the production table

      INV_ITEM_MSG.Debug(Mctx, 'begin UPDATE  mtl_descr_element_values');

      UPDATE  mtl_descr_element_values
      SET
        element_value     = p_element_value
      ,  default_element_flag = decode(p_default_element_flag,'Y','Y','N')
      ,  last_update_date  = SYSDATE
      ,  last_updated_by   = FND_GLOBAL.user_id
      ,  last_update_login = FND_GLOBAL.login_id
      ,  request_id        = FND_GLOBAL.conc_request_id
      ,  program_application_id	= FND_GLOBAL.prog_appl_id
      ,  program_id 	   = FND_GLOBAL.conc_program_id
      ,  program_update_date = SYSDATE
      WHERE
          inventory_item_id = l_inventory_item_id
      AND element_name      = p_element_name;


    INV_ITEM_MSG.Debug(Mctx, 'end UPDATE mtl_descr_element_values');

   -- Standard check of p_commit
   IF (FND_API.To_Boolean (p_commit)) THEN

      INV_ITEM_MSG.Debug(Mctx, 'before COMMIT WORK');
      COMMIT WORK;
   END IF;

   INV_ITEM_MSG.Count_And_Get
   (  p_count  =>  x_msg_count
   ,  p_data   =>  x_msg_data
   );
  -- Write all accumulated messages
      INV_ITEM_MSG.Write_List (p_delete => TRUE);

EXCEPTION

   WHEN FND_API.g_EXC_ERROR THEN
      ROLLBACK TO Catalog_Grp_Ele_Val_Assign_PVT;

      x_return_status := FND_API.g_RET_STS_ERROR;
      INV_ITEM_MSG.Count_And_Get
      (  p_count  =>  x_msg_count
      ,  p_data   =>  x_msg_data
      );

   WHEN FND_API.g_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Catalog_Grp_Ele_Val_Assign_PVT;

      x_return_status := FND_API.g_RET_STS_UNEXP_ERROR;
      INV_ITEM_MSG.Count_And_Get
      (  p_count  =>  x_msg_count
      ,  p_data   =>  x_msg_data
      );

   WHEN others THEN
      ROLLBACK TO Catalog_Grp_Ele_Val_Assign_PVT;

      x_return_status := FND_API.g_RET_STS_UNEXP_ERROR;
      INV_ITEM_MSG.Add_Unexpected_Error (Mctx, SQLERRM);

      INV_ITEM_MSG.Count_And_Get
      (  p_count  =>  x_msg_count
      ,  p_data   =>  x_msg_data
      );

END Catalog_Grp_Ele_Val_Assignment;

END INV_ITEM_CATALOG_ELE_PVT;

/
