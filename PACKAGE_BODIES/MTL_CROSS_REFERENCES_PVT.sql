--------------------------------------------------------
--  DDL for Package Body MTL_CROSS_REFERENCES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_CROSS_REFERENCES_PVT" AS
/* $Header: INVVXRFB.pls 120.0.12010000.2 2010/01/13 00:27:08 akbharga noship $ */

PROCEDURE Process_XRef(
  p_init_msg_list       IN               VARCHAR2       DEFAULT  FND_API.G_FALSE
  ,p_commit             IN               VARCHAR2       DEFAULT  FND_API.G_FALSE
  ,p_XRef_Tbl           IN OUT NOCOPY    MTL_CROSS_REFERENCES_PUB.XRef_Tbl_Type
  ,x_return_status      OUT NOCOPY       VARCHAR2
  ,x_msg_count          OUT NOCOPY       NUMBER
  ,x_message_list       OUT NOCOPY             Error_Handler.Error_Tbl_Type) IS

  -- Local variable Declarations
  l_api_name            VARCHAR2(30) :='Process_XRef';
  l_exists              VARCHAR(1);
  l_XRef_exists         VARCHAR(1);

  l_XRef_Rec            MTL_CROSS_REFERENCES_PUB.XRef_Rec_Type;  -- Declaring the record type object
  l_XRef_Tbl            MTL_CROSS_REFERENCES_PUB.XRef_Tbl_Type;  -- Declaring local table object
  l_Token_Tbl			Error_Handler.Token_Tbl_Type;            -- For passing token in error msgs
  l_msg_count           NUMBER;
  returned_cross_ref_id NUMBER;
  returned_object_version_number NUMBER;
  -- Cursor for fetching the current values from the table.
  CURSOR mtl_xref_cur  IS
    SELECT *
    FROM mtl_cross_references
    WHERE CROSS_REFERENCE_ID=l_XRef_Rec.CROSS_REFERENCE_ID;

  l_mtl_XRef_rec       MTL_CROSS_REFERENCES%ROWTYPE;  -- For fetching the data of above cursor

  VALIDATION_ERROR     EXCEPTION;
  l_has_privilege      VARCHAR2(1);

  -- cursor for locking the record while updating and deleting
  CURSOR mtl_xref_lock_b IS
          SELECT
          SOURCE_SYSTEM_ID
         ,START_DATE_ACTIVE
         ,END_DATE_ACTIVE
         ,OBJECT_VERSION_NUMBER
         ,UOM_CODE
         ,REVISION_ID
         ,EPC_GTIN_SERIAL
         ,INVENTORY_ITEM_ID
         ,ORGANIZATION_ID
         ,CROSS_REFERENCE_TYPE
         ,CROSS_REFERENCE
         ,ORG_INDEPENDENT_FLAG
         ,REQUEST_ID
         ,ATTRIBUTE1
         ,ATTRIBUTE2
         ,ATTRIBUTE3
         ,ATTRIBUTE4
         ,ATTRIBUTE5
         ,ATTRIBUTE6
         ,ATTRIBUTE7
         ,ATTRIBUTE8
         ,ATTRIBUTE9
         ,ATTRIBUTE10
         ,ATTRIBUTE11
         ,ATTRIBUTE12
         ,ATTRIBUTE13
         ,ATTRIBUTE14
         ,ATTRIBUTE15
         ,ATTRIBUTE_CATEGORY
  FROM MTL_CROSS_REFERENCES_B
      WHERE CROSS_REFERENCE_ID=l_XRef_Rec.CROSS_REFERENCE_ID
  FOR UPDATE OF INVENTORY_ITEM_ID NOWAIT;


     CURSOR mtl_xref_lock_tl IS
      SELECT
          DESCRIPTION
         ,DECODE(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
      FROM MTL_CROSS_REFERENCES_TL
      WHERE CROSS_REFERENCE_ID = l_XRef_Rec.CROSS_REFERENCE_ID
      AND   USERENV('LANG') IN (LANGUAGE, SOURCE_LANG)
      FOR UPDATE OF CROSS_REFERENCE_ID NOWAIT;



  l_lock_b_recinfo mtl_xref_lock_b%ROWTYPE;
  l_lock_tl_recinfo  mtl_xref_lock_tl%ROWTYPE;

  resource_busy    EXCEPTION;
  PRAGMA EXCEPTION_INIT (resource_busy, -54);

BEGIN

  SAVEPOINT MTL_CROSS_REFERENCES_PVT;
  X_return_status:= FND_API.G_RET_STS_SUCCESS ;
  l_XRef_Tbl := p_XRef_Tbl;

  -- Initialize message list
  IF FND_API.To_Boolean (p_init_msg_list) THEN
	Error_Handler.Initialize;
  END IF;

  -- Looping all the records
  FOR l_Xref_Indx IN  p_XRef_Tbl.FIRST..p_XRef_Tbl.Last LOOP
    l_XRef_Rec := l_XRef_Tbl(l_Xref_Indx);

    BEGIN -- Internal Begin
    -- common validation section for INSERT/UPDATE/DELETE

  -- Check for valid Transaction_Type

  IF l_XRef_Rec.Transaction_Type <> 'CREATE' AND l_XRef_Rec.Transaction_Type <> 'UPDATE' AND
  l_XRef_Rec.Transaction_Type <> 'DELETE' THEN

             l_XRef_Rec.x_return_status:=FND_API.g_RET_STS_ERROR;
             Error_Handler.Add_Error_Message
             (
             p_message_name		  =>  'INV_XREF_INVALID_TRANS_TYPE'
             ,p_application_id    =>  'INV'
             ,p_message_type	  =>  'E'
             ,p_entity_code		  =>  G_Entity_Code
             ,p_entity_index      =>  l_Xref_Indx
             ,p_table_name        =>  G_Table_Name
             );
             RAISE VALIDATION_ERROR;

      END IF;




      -- checking for privileges
      IF INV_EGO_REVISION_VALIDATE.check_data_security (
	      p_function              => 'EGO_EDIT_ITEM_XREFS'
          ,p_object_name          => 'EGO_ITEM'
	      ,p_instance_pk1_value   => l_XRef_Rec.Inventory_item_id
	      ,p_instance_pk2_value   => FND_GLOBAL.org_id
	      ,P_User_Id              => FND_GLOBAL.user_id)  <> 'T' THEN

        Error_Handler.Add_Error_Message
        (
        p_message_name		      =>  'INV_IOI_ITEM_UPDATE_PRIV'
        ,p_application_id		  =>  'INV'
        ,p_message_type		      =>  'E'
        ,p_entity_code		      =>  G_Entity_Code
        ,p_entity_index		      => l_Xref_Indx
        ,p_table_name		      => 'MTL_CROSS_REFERENCES'
        );
        RAISE VALIDATION_ERROR;
      END IF;

      -- checking for item existance in MSIB
      IF l_XRef_Rec.Inventory_Item_Id IS NOT NULL
	     AND l_XRef_Rec.Inventory_Item_Id<>FND_API.G_MISS_NUM then

        BEGIN
          SELECT 'x' INTO l_exists
		  FROM mtl_system_items_b
		  WHERE inventory_item_id =l_XRef_Rec.Inventory_Item_Id;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_XRef_Rec.x_return_status:=FND_API.g_RET_STS_ERROR;
          Error_Handler.Add_Error_Message
          (
          p_message_name		  =>  'INV-NO ITEM RECORD'
          ,p_application_id		  =>  'INV'
          ,p_message_type		  =>  'E'
          ,p_entity_code		  =>  G_Entity_Code
          ,p_entity_index		  =>  l_Xref_Indx
          ,p_table_name		      =>  'MTL_SYSTEM_ITEMS_B'
          );
          RAISE VALIDATION_ERROR;
        WHEN Too_Many_Rows  THEN
          NULL;
        END;
      END IF;

      -- organization validation -- both org_indp_flag and org_id should not be NOT NULL
      IF l_XRef_Rec.Organization_Id IS NOT NULL
	     AND l_XRef_Rec.Organization_Id <>FND_API.G_MISS_NUM THEN

		   IF l_XRef_Rec.Org_Independent_Flag='Y' THEN
             l_XRef_Rec.x_return_status:=FND_API.g_RET_STS_ERROR;
             Error_Handler.Add_Error_Message
             (
             p_message_name		  =>  'INV_XREF_ORG_FLAG'
             ,p_application_id    =>  'INV'
             ,p_message_type	  =>  'E'
             ,p_entity_code		  =>  G_Entity_Code
             ,p_entity_index      =>  l_Xref_Indx
             ,p_table_name        =>  G_Table_Name
             );
             RAISE VALIDATION_ERROR;
           END IF ;
      END IF;

      -- Invalid value for org_indep_flag
      IF l_XRef_rec.org_independent_flag NOT IN ('Y','N',FND_API.G_MISS_CHAR) THEN

	    l_XRef_Rec.x_return_status:=FND_API.g_RET_STS_ERROR;
        Error_Handler.Add_Error_Message
        (
        p_message_name            =>  'INV_XREF_INVALID_ORG_FLAG'
        ,p_application_id         =>  'INV'
        ,p_message_type           =>  'E'
        ,p_entity_code            =>  G_Entity_Code
        ,p_entity_index           =>  l_Xref_Indx
        ,p_table_name             =>  'MTL_CROSS_REFERENCE'
        );
        RAISE VALIDATION_ERROR;
      END IF;

      -- SS_ITEM_XREF and GTIN not supported.
      IF l_XRef_rec.Cross_Reference_Type IN ('SS_ITEM_XREF','GTIN') THEN

	    l_XRef_Rec.x_return_status:=FND_API.g_RET_STS_ERROR;
        Error_Handler.Add_Error_Message
        (
        p_message_name            =>  'INV_XREF_INVALID_TYPES'
        ,p_application_id         =>  'INV'
        ,p_message_type           =>  'E'
        ,p_entity_code            =>  G_Entity_Code
        ,p_entity_index           =>  l_Xref_Indx
        ,p_table_name             =>  'MTL_CROSS_REFERENCE_TYPES'
        );
        RAISE VALIDATION_ERROR;
      END IF;

      -- cross reference type validations
      IF l_XRef_Rec.Cross_Reference_Type IS NOT NULL
	     AND l_XRef_Rec.Cross_Reference_Type<> FND_API.G_MISS_CHAR THEN

        BEGIN -- cross reference type existance
          SELECT 'x' INTO l_exists
		  FROM MTL_CROSS_REFERENCE_TYPES
		  WHERE cross_reference_type           =l_XRef_Rec.Cross_Reference_Type
		  AND trunc(nvl(disable_date,sysdate)) >= trunc(sysdate);
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_XRef_Rec.x_return_status  :=FND_API.g_RET_STS_ERROR;
          l_Token_Tbl(1).Token_Name   :=  'CROSS_REFERENCE_TYPE';
          l_Token_Tbl(1).Token_Value  :=  l_XRef_Rec.Cross_Reference_Type;
          l_Token_Tbl(1).Translate    :=  FALSE;
		  Error_Handler.Add_Error_Message
          (
          p_message_name          =>  'INV_XREF_TYPE_INACTIVE'
          ,p_application_id       =>  'INV'
          ,p_token_tbl            =>  l_Token_Tbl
          ,p_message_type         =>  'E'
          ,p_entity_code          =>  G_Entity_Code
          ,p_entity_index         => l_Xref_Indx
          ,p_table_name           => 'MTL_CROSS_REFERENCE_TYPES'
          );
          RAISE VALIDATION_ERROR;
        END;
      END IF ;



      IF l_XRef_Rec.Transaction_Type = 'CREATE' THEN

	    -- Should not leave PK columns blank and cannot pass NULL to these Columns.
	    IF l_XRef_Rec.Inventory_Item_Id IS NULL OR l_XRef_Rec.Inventory_Item_Id =FND_API.G_MISS_NUM
           OR l_XRef_Rec.Cross_Reference_Type IS NULL  OR l_XRef_Rec.Cross_Reference_Type =FND_API.G_MISS_CHAR
              OR l_XRef_Rec.Cross_Reference IS NULL OR l_XRef_Rec.Cross_Reference=FND_API.G_MISS_CHAR THEN

          l_XRef_Rec.x_return_status:=FND_API.g_RET_STS_ERROR;
          Error_Handler.Add_Error_Message
          (
          p_message_name          =>  'INV_XREF_NULL_COLS'
          ,p_application_id       =>  'INV'
          ,p_message_type         =>  'E'
          ,p_entity_code          =>  G_Entity_Code
          ,p_entity_index         =>  l_Xref_Indx
          ,p_table_name           =>  G_Table_Name
          );
          RAISE VALIDATION_ERROR;
        END IF;

        -- Org_Id and Org_Indp_Flag both NULL.
        IF l_XRef_Rec.Organization_Id IS NULL
           OR l_XRef_Rec.Organization_Id = FND_API.G_MISS_NUM THEN

           IF l_XRef_Rec.Org_Independent_Flag IS NULL
		      OR l_XRef_Rec.Org_Independent_Flag=FND_API.G_MISS_CHAR
			     OR l_XRef_Rec.Org_Independent_Flag <>'Y'  THEN

              l_XRef_Rec.x_return_status:=FND_API.g_RET_STS_ERROR;
              Error_Handler.Add_Error_Message
              (
              p_message_name      =>  'INV_XREF_NULL_ORG'
              ,p_application_id	  =>  'INV'
              ,p_message_type     =>  'E'
              ,p_entity_code      =>  G_Entity_Code
              ,p_entity_index     =>  l_Xref_Indx
              ,p_table_name	      =>  G_Table_Name
              );
              RAISE VALIDATION_ERROR;
           END IF ;
        END IF;



        -- Checking for Revision_Id  and UOM_Code Values

        IF (l_XRef_Rec.Uom_Code IS NOT NULL
		   AND l_XRef_Rec.Uom_Code <> FND_API.G_MISS_CHAR)
              OR  (l_XRef_Rec.Revision_Id IS NOT NULL
          AND l_XRef_Rec.Revision_Id <> FND_API.G_MISS_NUM)

         THEN

          l_XRef_Rec.x_return_status:=FND_API.g_RET_STS_ERROR;
          Error_Handler.Add_Error_Message
          (
          p_message_name      => 'INV_XREF_INVALID_COLUMN_VALUE'
          ,p_application_id	  =>  'INV'
          ,p_message_type     =>  'E'
          ,p_entity_code      =>  G_Entity_Code
          ,p_entity_index     =>  l_Xref_Indx
          ,p_table_name	  =>  G_Table_Name
          );
          RAISE VALIDATION_ERROR;

        END IF ;

        -- checking for Item existance for given org.
        IF l_XRef_Rec.Organization_Id IS NOT NULL
           AND l_XRef_Rec.Organization_Id <>FND_API.G_MISS_NUM THEN

          BEGIN
            SELECT 'x' INTO l_exists
            FROM mtl_system_items_b
            WHERE Inventory_item_id    = l_XRef_Rec.Inventory_Item_Id
            AND Organization_id        = l_XRef_Rec.Organization_Id;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_XRef_Rec.x_return_status:=FND_API.g_RET_STS_ERROR;
            Error_Handler.Add_Error_Message
            (
            p_message_name        =>  'INV_INVALID_ITEM_ORG'
            ,p_application_id     =>  'INV'
            ,p_message_type       =>  'E'
            ,p_entity_code        =>  G_Entity_Code
            ,p_entity_index       =>  l_Xref_Indx
            ,p_table_name         =>  'MTL_SYSTEM_ITEMS_B'
            );
            RAISE VALIDATION_ERROR;
          END;
        END IF ;

       -- checking for duplicate record
        BEGIN

          SELECT  'x' INTO l_XRef_exists
          FROM mtl_cross_references
          WHERE Cross_Reference_Type        = l_XRef_Rec.Cross_Reference_Type
          AND Inventory_Item_Id             = l_XRef_Rec.Inventory_Item_Id
          AND Cross_Reference               =l_XRef_Rec.Cross_Reference
          AND Decode(Organization_Id,NULL,Org_Independent_Flag,Organization_Id) =
              Decode(l_XRef_Rec.Organization_Id,FND_API.G_MISS_NUM,l_XRef_Rec.Org_Independent_Flag,l_XRef_Rec.Organization_Id);

           --record already Exists
          IF l_XRef_exists='x' THEN

            l_Token_Tbl(1).Token_Name   :=  'INVENTORY_ITEM_ID';
            l_Token_Tbl(1).Token_Value  :=  l_XRef_Rec.Inventory_Item_Id;
            l_Token_Tbl(1).Translate    :=  FALSE;
            l_Token_Tbl(2).Token_Name   :=  'CROSS_REFERENCE_TYPE';
            l_Token_Tbl(2).Token_Value  :=  l_XRef_Rec.CROSS_REFERENCE_TYPE;
            l_Token_Tbl(2).Translate    :=  FALSE;
            l_Token_Tbl(3).Token_Name   :=  'CROSS_REFERENCE';
            l_Token_Tbl(3).Token_Value  :=  l_XRef_Rec.CROSS_REFERENCE;
            l_Token_Tbl(3).Translate    :=  FALSE;

            l_XRef_Rec.x_return_status:=FND_API.g_RET_STS_ERROR;
            Error_Handler.Add_Error_Message
            (
            p_message_name        =>  'INV_XREF_PRIMARY_KEY_VIOLATED'
            ,p_application_id     =>  'INV'
            ,p_token_tbl          =>  l_Token_Tbl
            ,p_message_type       =>  'E'
            ,p_entity_code        =>  G_Entity_Code
            ,p_entity_index       =>  l_Xref_Indx
            ,p_table_name         =>  G_Table_Name
            );
            RAISE VALIDATION_ERROR;
          END IF;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
        END;

        --Changing Gloabal variable back to NULL before inserting.
        SELECT Decode(l_XRef_Rec.Inventory_Item_Id,FND_API.G_MISS_NUM,NULL,l_XRef_Rec.Inventory_Item_Id),
               Decode(l_XRef_Rec.Organization_Id,FND_API.G_MISS_NUM,NULL,l_XRef_Rec.Organization_Id),
               Decode(l_XRef_Rec.Cross_Reference_Type,FND_API.G_MISS_CHAR,NULL,l_XRef_Rec.Cross_Reference_Type),
               Decode(l_XRef_Rec.Cross_Reference,FND_API.G_MISS_CHAR,NULL,l_XRef_Rec.Cross_Reference),
               Decode(l_XRef_Rec.Description,FND_API.G_MISS_CHAR,NULL,l_XRef_Rec.Description),
               Decode(l_XRef_Rec.Org_Independent_Flag,FND_API.G_MISS_CHAR,NULL,l_XRef_Rec.Org_Independent_Flag),
               Decode(l_XRef_Rec.Last_Update_Date,FND_API.G_MISS_DATE,NULL,l_XRef_Rec.Last_Update_Date),
               Decode(l_XRef_Rec.Last_Updated_By,FND_API.G_MISS_NUM,NULL,l_XRef_Rec.Last_Updated_By),
               Decode(l_XRef_Rec.Creation_Date,FND_API.G_MISS_DATE,NULL,l_XRef_Rec.Creation_Date),
               Decode(l_XRef_Rec.Created_By,FND_API.G_MISS_NUM,NULL,l_XRef_Rec.Created_By),
               Decode(l_XRef_Rec.Last_Update_Login,FND_API.G_MISS_NUM,NULL,l_XRef_Rec.Last_Update_Login),
               Decode(l_XRef_Rec.Request_id,FND_API.G_MISS_NUM,NULL,l_XRef_Rec.Request_id),
               Decode(l_XRef_Rec.Program_Application_Id,FND_API.G_MISS_NUM,NULL,l_XRef_Rec.Program_Application_Id),
               Decode(l_XRef_Rec.Program_Id,FND_API.G_MISS_NUM,NULL,l_XRef_Rec.Program_Id),
               Decode(l_XRef_Rec.Program_Update_Date,FND_API.G_MISS_DATE,NULL,l_XRef_Rec.Program_Update_Date),
               Decode(l_XRef_Rec.Attribute1,FND_API.G_MISS_CHAR,NULL,l_XRef_Rec.Attribute1),
               Decode(l_XRef_Rec.Attribute2,FND_API.G_MISS_CHAR,NULL,l_XRef_Rec.Attribute2),
               Decode(l_XRef_Rec.Attribute3,FND_API.G_MISS_CHAR,NULL,l_XRef_Rec.Attribute3),
               Decode(l_XRef_Rec.Attribute4,FND_API.G_MISS_CHAR,NULL,l_XRef_Rec.Attribute4),
               Decode(l_XRef_Rec.Attribute5,FND_API.G_MISS_CHAR,NULL,l_XRef_Rec.Attribute5),
               Decode(l_XRef_Rec.Attribute6,FND_API.G_MISS_CHAR,NULL,l_XRef_Rec.Attribute6),
               Decode(l_XRef_Rec.Attribute7,FND_API.G_MISS_CHAR,NULL,l_XRef_Rec.Attribute7),
               Decode(l_XRef_Rec.Attribute8,FND_API.G_MISS_CHAR,NULL,l_XRef_Rec.Attribute8),
               Decode(l_XRef_Rec.Attribute9,FND_API.G_MISS_CHAR,NULL,l_XRef_Rec.Attribute9),
               Decode(l_XRef_Rec.Attribute10,FND_API.G_MISS_CHAR,NULL,l_XRef_Rec.Attribute10),
               Decode(l_XRef_Rec.Attribute11,FND_API.G_MISS_CHAR,NULL,l_XRef_Rec.Attribute11),
               Decode(l_XRef_Rec.Attribute12,FND_API.G_MISS_CHAR,NULL,l_XRef_Rec.Attribute12),
               Decode(l_XRef_Rec.Attribute13,FND_API.G_MISS_CHAR,NULL,l_XRef_Rec.Attribute13),
               Decode(l_XRef_Rec.Attribute14,FND_API.G_MISS_CHAR,NULL,l_XRef_Rec.Attribute14),
               Decode(l_XRef_Rec.Attribute15,FND_API.G_MISS_CHAR,NULL,l_XRef_Rec.Attribute15),
               Decode(l_XRef_Rec.Attribute_category,FND_API.G_MISS_CHAR,NULL,l_XRef_Rec.Attribute_category),
               Decode(l_XRef_Rec.Uom_Code,FND_API.G_MISS_CHAR,NULL,l_XRef_Rec.Uom_Code),
               Decode(l_XRef_Rec.Revision_Id,FND_API.G_MISS_NUM,NULL,l_XRef_Rec.Revision_Id)

        INTO   l_XRef_Rec.Inventory_Item_Id,l_XRef_Rec.Organization_Id, l_XRef_Rec.Cross_Reference_Type,l_XRef_Rec.Cross_Reference,
               l_XRef_Rec.Description,l_XRef_Rec.Org_Independent_Flag,l_XRef_Rec.Last_Update_Date,l_XRef_Rec.Last_Updated_By,l_XRef_Rec.Creation_Date,
               l_XRef_Rec.Created_By,l_XRef_Rec.Last_Update_Login,l_XRef_Rec.Request_id,l_XRef_Rec.Program_Application_Id,l_XRef_Rec.Program_Id,
               l_XRef_Rec.Program_Update_Date,l_XRef_Rec.Attribute1,l_XRef_Rec.Attribute2,l_XRef_Rec.Attribute3,l_XRef_Rec.Attribute4,
               l_XRef_Rec.Attribute5,l_XRef_Rec.Attribute6,l_XRef_Rec.Attribute7,l_XRef_Rec.Attribute8,l_XRef_Rec.Attribute9,l_XRef_Rec.Attribute10,
               l_XRef_Rec.Attribute11,l_XRef_Rec.Attribute12,l_XRef_Rec.Attribute13,l_XRef_Rec.Attribute14,l_XRef_Rec.Attribute15,
               l_XRef_Rec.Attribute_category,l_XRef_Rec.Uom_Code,l_XRef_Rec.Revision_Id
        FROM dual;

        MTL_CROSS_REFERENCES_PKG.INSERT_ROW(
	      P_UOM_CODE               => NULL
	      ,P_REVISION_ID           => NULL
	      ,P_INVENTORY_ITEM_ID     => l_XRef_Rec.Inventory_Item_Id
	      ,P_ORGANIZATION_ID       => l_XRef_Rec.Organization_Id
	      ,P_CROSS_REFERENCE_TYPE  => l_XRef_Rec.Cross_Reference_Type
	      ,P_CROSS_REFERENCE       => l_XRef_Rec.Cross_Reference
	      ,P_ORG_INDEPENDENT_FLAG  => Nvl(l_XRef_Rec.Org_Independent_Flag,'N')
	      ,P_REQUEST_ID            => NULL
	      ,P_ATTRIBUTE1            => l_XRef_Rec.Attribute1
	      ,P_ATTRIBUTE2            => l_XRef_Rec.Attribute2
	      ,P_ATTRIBUTE3            => l_XRef_Rec.Attribute3
	      ,P_ATTRIBUTE4            => l_XRef_Rec.Attribute4
	      ,P_ATTRIBUTE5            => l_XRef_Rec.Attribute5
	      ,P_ATTRIBUTE6            => l_XRef_Rec.Attribute6
	      ,P_ATTRIBUTE7            => l_XRef_Rec.Attribute7
	      ,P_ATTRIBUTE8            => l_XRef_Rec.Attribute8
	      ,P_ATTRIBUTE9            => l_XRef_Rec.Attribute9
	      ,P_ATTRIBUTE10           => l_XRef_Rec.Attribute10
	      ,P_ATTRIBUTE11           => l_XRef_Rec.Attribute11
	      ,P_ATTRIBUTE12           => l_XRef_Rec.Attribute12
	      ,P_ATTRIBUTE13           => l_XRef_Rec.Attribute13
	      ,P_ATTRIBUTE14           => l_XRef_Rec.Attribute14
	      ,P_ATTRIBUTE15           => l_XRef_Rec.Attribute15
	      ,P_ATTRIBUTE_CATEGORY    => l_XRef_Rec.Attribute_category
	      ,P_DESCRIPTION           => l_XRef_Rec.Description
	      ,P_CREATION_DATE         => Nvl(l_XRef_Rec.Creation_Date,SYSDATE)
	      ,P_CREATED_BY            => Nvl(l_XRef_Rec.Created_By,FND_GLOBAL.USER_ID)
	      ,P_LAST_UPDATE_DATE      => Nvl(l_XRef_Rec.Last_Update_Date,SYSDATE)
	      ,P_LAST_UPDATED_BY       => Nvl(l_XRef_Rec.Last_Updated_By,FND_GLOBAL.USER_ID)
	      ,P_LAST_UPDATE_LOGIN     => Nvl(l_XRef_Rec.Last_Update_Login,FND_GLOBAL.LOGIN_ID)
	      ,P_PROGRAM_APPLICATION_ID=> NULL
	      ,P_PROGRAM_ID            => NULL
	      ,P_PROGRAM_UPDATE_DATE   => NULL
	      ,P_EPC_GTIN_SERIAL =>NULL
	      ,P_SOURCE_SYSTEM_ID       => NULL
        ,P_START_DATE_ACTIVE      => NULL
        ,P_END_DATE_ACTIVE        => NULL
        ,P_OBJECT_VERSION_NUMBER  =>NULL
         ,X_CROSS_REFERENCE_ID  =>returned_cross_ref_id
                            );

      ELSIF  l_XRef_Rec.Transaction_Type = 'UPDATE' THEN

        -- Current cols should not be NULL.
        IF l_XRef_Rec.CROSS_REFERENCE_ID =FND_API.G_MISS_NUM THEN

          l_XRef_Rec.x_return_status:=FND_API.g_RET_STS_ERROR;  -- assigning the record status as error
          Error_Handler.Add_Error_Message
          (
          p_message_name           =>  'INV_XREF_ID_NULL'
          ,p_application_id        =>  'INV'
          ,p_message_type          =>  'E'
          ,p_entity_code           =>  G_Entity_Code
          ,p_entity_index          =>  l_Xref_Indx
          ,p_table_name            =>  G_Table_Name
          );
          RAISE VALIDATION_ERROR;
        END IF;

        -- cannot pass NULL to these Columns
        IF l_XRef_Rec.Inventory_Item_Id IS NULL
           OR l_XRef_Rec.Cross_Reference_Type IS NULL
		      OR l_XRef_Rec.Cross_Reference IS NULL THEN

	      l_XRef_Rec.x_return_status:=FND_API.g_RET_STS_ERROR;  -- assigning the record status as error
          Error_Handler.Add_Error_Message
          (
          p_message_name           =>  'INV_XREF_NULL_COLS'
          ,p_application_id        =>  'INV'
          ,p_message_type          =>  'E'
          ,p_entity_code           =>  G_Entity_Code
          ,p_entity_index          =>  l_Xref_Indx
          ,p_table_name            =>  G_Table_Name
          );
          RAISE VALIDATION_ERROR;
        END IF;

        -- Checking for Revision_Id and UOM_Cde  Values

        IF (l_XRef_Rec.Uom_Code IS NOT NULL
		   AND l_XRef_Rec.Uom_Code <> FND_API.G_MISS_CHAR)
              OR  (l_XRef_Rec.Revision_Id IS NOT NULL
          AND l_XRef_Rec.Revision_Id <> FND_API.G_MISS_NUM)


              THEN

		  l_XRef_Rec.x_return_status:=FND_API.g_RET_STS_ERROR;
          Error_Handler.Add_Error_Message
          (
          p_message_name      => 'INV_XREF_INVALID_COLUMN_VALUE'
          ,p_application_id	  =>  'INV'
          ,p_message_type     =>  'E'
          ,p_entity_code      =>  G_Entity_Code
          ,p_entity_index     =>  l_Xref_Indx
          ,p_table_name	  =>  G_Table_Name
          );
          RAISE VALIDATION_ERROR;

        END IF ;

        -- getting original values and checking for existance of record
        OPEN  mtl_xref_cur;
        FETCH  mtl_xref_cur INTO l_mtl_XRef_rec;
          IF mtl_xref_cur%NOTFOUND THEN
            l_XRef_Rec.x_return_status:=FND_API.g_RET_STS_ERROR;
            Error_Handler.Add_Error_Message
            (
            p_message_name         =>  'INV_XREF_ID_NOTEXISTS'
            ,p_application_id      =>  'INV'
            ,p_message_type        =>  'E'
            ,p_entity_code         =>  G_Entity_Code
            ,p_entity_index        => l_Xref_Indx
            ,p_table_name          => G_Table_Name
            );
			CLOSE mtl_xref_cur;
            RAISE VALIDATION_ERROR;
          END IF;
        CLOSE mtl_xref_cur;

        -- Converting global values(values left blank) back to original values.
        SELECT Decode(l_XRef_Rec.Inventory_Item_Id,FND_API.G_MISS_NUM,l_mtl_XRef_Rec.Inventory_Item_Id,l_XRef_Rec.Inventory_Item_Id),
               Decode(l_XRef_Rec.Organization_Id,FND_API.G_MISS_NUM,l_mtl_XRef_Rec.Organization_Id,l_XRef_Rec.Organization_Id),
               Decode(l_XRef_Rec.Cross_Reference_Type,FND_API.G_MISS_CHAR,l_mtl_XRef_Rec.Cross_Reference_Type,l_XRef_Rec.Cross_Reference_Type),
               Decode(l_XRef_Rec.Cross_Reference,FND_API.G_MISS_CHAR,l_mtl_XRef_Rec.Cross_Reference,l_XRef_Rec.Cross_Reference),
               Decode(l_XRef_Rec.Description,FND_API.G_MISS_CHAR,l_mtl_XRef_Rec.Description,l_XRef_Rec.Description),
               Decode(l_XRef_Rec.Org_Independent_Flag,FND_API.G_MISS_CHAR,l_mtl_XRef_Rec.Org_Independent_Flag,l_XRef_Rec.Org_Independent_Flag),
               Decode(l_XRef_Rec.Last_Update_Date,FND_API.G_MISS_DATE,NULL,l_XRef_Rec.Last_Update_Date),
               Decode(l_XRef_Rec.Last_Updated_By,FND_API.G_MISS_NUM,NULL,l_XRef_Rec.Last_Updated_By),
               Decode(l_XRef_Rec.Creation_Date,FND_API.G_MISS_DATE,l_mtl_XRef_Rec.Creation_Date,l_XRef_Rec.Creation_Date),
               Decode(l_XRef_Rec.Created_By,FND_API.G_MISS_NUM,l_mtl_XRef_Rec.Created_By,l_XRef_Rec.Created_By),
               Decode(l_XRef_Rec.Last_Update_Login,FND_API.G_MISS_NUM,NULL,l_XRef_Rec.Last_Update_Login),
               Decode(l_XRef_Rec.Request_id,FND_API.G_MISS_NUM,l_mtl_XRef_Rec.Request_id,l_XRef_Rec.Request_id),
               Decode(l_XRef_Rec.Program_Application_Id,FND_API.G_MISS_NUM,l_mtl_XRef_Rec.Program_Application_Id,l_XRef_Rec.Program_Application_Id),
               Decode(l_XRef_Rec.Program_Id,FND_API.G_MISS_NUM,l_XRef_Rec.Program_Id,l_mtl_XRef_Rec.Program_Id),
               Decode(l_XRef_Rec.Program_Update_Date,FND_API.G_MISS_DATE,l_mtl_XRef_Rec.Program_Update_Date,l_XRef_Rec.Program_Update_Date),
               Decode(l_XRef_Rec.Attribute1,FND_API.G_MISS_CHAR,l_mtl_XRef_Rec.Attribute1,l_XRef_Rec.Attribute1),
               Decode(l_XRef_Rec.Attribute2,FND_API.G_MISS_CHAR,l_mtl_XRef_Rec.Attribute2,l_XRef_Rec.Attribute2),
               Decode(l_XRef_Rec.Attribute3,FND_API.G_MISS_CHAR,l_mtl_XRef_Rec.Attribute3,l_XRef_Rec.Attribute3),
               Decode(l_XRef_Rec.Attribute4,FND_API.G_MISS_CHAR,l_mtl_XRef_Rec.Attribute4,l_XRef_Rec.Attribute4),
               Decode(l_XRef_Rec.Attribute5,FND_API.G_MISS_CHAR,l_mtl_XRef_Rec.Attribute5,l_XRef_Rec.Attribute5),
               Decode(l_XRef_Rec.Attribute6,FND_API.G_MISS_CHAR,l_mtl_XRef_Rec.Attribute6,l_XRef_Rec.Attribute6),
               Decode(l_XRef_Rec.Attribute7,FND_API.G_MISS_CHAR,l_mtl_XRef_Rec.Attribute7,l_XRef_Rec.Attribute7),
               Decode(l_XRef_Rec.Attribute8,FND_API.G_MISS_CHAR,l_mtl_XRef_Rec.Attribute8,l_XRef_Rec.Attribute8),
               Decode(l_XRef_Rec.Attribute9,FND_API.G_MISS_CHAR,l_mtl_XRef_Rec.Attribute9,l_XRef_Rec.Attribute9),
               Decode(l_XRef_Rec.Attribute10,FND_API.G_MISS_CHAR,l_mtl_XRef_Rec.Attribute10,l_XRef_Rec.Attribute10),
               Decode(l_XRef_Rec.Attribute11,FND_API.G_MISS_CHAR,l_mtl_XRef_Rec.Attribute11,l_XRef_Rec.Attribute11),
               Decode(l_XRef_Rec.Attribute12,FND_API.G_MISS_CHAR,l_mtl_XRef_Rec.Attribute12,l_XRef_Rec.Attribute12),
               Decode(l_XRef_Rec.Attribute13,FND_API.G_MISS_CHAR,l_mtl_XRef_Rec.Attribute13,l_XRef_Rec.Attribute13),
               Decode(l_XRef_Rec.Attribute14,FND_API.G_MISS_CHAR,l_mtl_XRef_Rec.Attribute14,l_XRef_Rec.Attribute14),
               Decode(l_XRef_Rec.Attribute15,FND_API.G_MISS_CHAR,l_mtl_XRef_Rec.Attribute15,l_XRef_Rec.Attribute15),
               Decode(l_XRef_Rec.Attribute_category,FND_API.G_MISS_CHAR,l_mtl_XRef_Rec.Attribute_category,l_XRef_Rec.Attribute_category),
               Decode(l_XRef_Rec.Uom_Code,FND_API.G_MISS_CHAR,l_mtl_XRef_Rec.Uom_Code,l_XRef_Rec.Uom_Code),
               Decode(l_XRef_Rec.Revision_Id,FND_API.G_MISS_NUM,l_mtl_XRef_Rec.Revision_Id,l_XRef_Rec.Revision_Id)
        INTO   l_XRef_Rec.Inventory_Item_Id,l_XRef_Rec.Organization_Id, l_XRef_Rec.Cross_Reference_Type,l_XRef_Rec.Cross_Reference,
               l_XRef_Rec.Description,l_XRef_Rec.Org_Independent_Flag,l_XRef_Rec.Last_Update_Date,l_XRef_Rec.Last_Updated_By,l_XRef_Rec.Creation_Date,
               l_XRef_Rec.Created_By,l_XRef_Rec.Last_Update_Login,l_XRef_Rec.Request_id,l_XRef_Rec.Program_Application_Id,l_XRef_Rec.Program_Id,
			   l_XRef_Rec.Program_Update_Date,l_XRef_Rec.Attribute1,l_XRef_Rec.Attribute2,l_XRef_Rec.Attribute3,l_XRef_Rec.Attribute4,
			   l_XRef_Rec.Attribute5,l_XRef_Rec.Attribute6,l_XRef_Rec.Attribute7,l_XRef_Rec.Attribute8,l_XRef_Rec.Attribute9,l_XRef_Rec.Attribute10,
			   l_XRef_Rec.Attribute11,l_XRef_Rec.Attribute12,l_XRef_Rec.Attribute13,l_XRef_Rec.Attribute14,l_XRef_Rec.Attribute15,
			   l_XRef_Rec.Attribute_category,l_XRef_Rec.Uom_Code,l_XRef_Rec.Revision_Id
        FROM dual;

        -- organization validation -- both org_indp_flag and org_id NOT NULL
        IF l_XRef_Rec.Organization_Id IS NOT NULL  THEN

          IF l_XRef_Rec.Org_Independent_Flag='Y' THEN
            l_XRef_Rec.x_return_status:=FND_API.g_RET_STS_ERROR;
            Error_Handler.Add_Error_Message
            (
            p_message_name         =>  'INV_XREF_ORG_FLAG'
            ,p_application_id      =>  'INV'
            ,p_message_type        =>  'E'
            ,p_entity_code         =>  G_Entity_Code
            ,p_entity_index        =>  l_Xref_Indx
            ,p_table_name          =>  G_Table_Name
            );
            RAISE VALIDATION_ERROR;
          END IF ;
        END IF;

		-- if org_id and org_indp_flag both NULL
        IF l_XRef_Rec.Organization_Id IS NULL THEN

          IF l_XRef_Rec.Org_Independent_Flag IS NULL
	         OR l_XRef_Rec.Org_Independent_Flag = FND_API.G_MISS_CHAR
			    OR l_XRef_Rec.Org_Independent_Flag <> 'Y'  THEN

			  l_XRef_Rec.x_return_status:=FND_API.g_RET_STS_ERROR;
              Error_Handler.Add_Error_Message
              (
              p_message_name       =>  'INV_XREF_NULL_ORG'
              ,p_application_id    =>  'INV'
              ,p_message_type      =>  'E'
              ,p_entity_code       =>  G_Entity_Code
              ,p_entity_index      =>  l_Xref_Indx
              ,p_table_name        =>  G_Table_Name
              );
              RAISE VALIDATION_ERROR;
          END IF;
        END IF ;

        -- checking for Item existance for given org.
        IF l_XRef_Rec.Organization_Id IS NOT NULL
		   AND l_XRef_Rec.Organization_Id <>FND_API.G_MISS_NUM
		       AND l_XRef_Rec.Inventory_Item_Id <>FND_API.G_MISS_NUM THEN

		  BEGIN
            SELECT 'x' INTO l_exists
            FROM mtl_system_items_b
            WHERE Inventory_item_id       = l_XRef_Rec.Inventory_Item_Id
			AND Organization_id           = l_XRef_Rec.Organization_Id;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
            l_XRef_Rec.x_return_status:=FND_API.g_RET_STS_ERROR;
            Error_Handler.Add_Error_Message
            (
            p_message_name         =>  'INV_INVALID_ITEM_ORG'
            ,p_application_id      =>  'INV'
            ,p_message_type        =>  'E'
            ,p_entity_code         =>  G_Entity_Code
            ,p_entity_index        => l_Xref_Indx
            ,p_table_name          => G_Table_Name
            );
            RAISE VALIDATION_ERROR;
          END;
        END IF;

        -- checking for duplicate record
        IF l_mtl_XRef_Rec.Inventory_Item_Id <> l_XRef_Rec.Inventory_Item_Id
           OR l_mtl_XRef_Rec.Cross_Reference_Type <> l_XRef_Rec.Cross_Reference_Type
		      OR l_mtl_XRef_Rec.Cross_Reference <> l_XRef_Rec.Cross_Reference
                 OR Nvl(l_mtl_XRef_Rec.Organization_Id,0) <> l_XRef_Rec.Organization_Id
				    OR l_mtl_XRef_Rec.Org_Independent_Flag <> l_XRef_Rec.Org_Independent_Flag THEN

		  BEGIN
            SELECT  'x' INTO l_XRef_exists
			FROM mtl_cross_references
            WHERE Cross_Reference_Type        = l_XRef_Rec.Cross_Reference_Type
            AND Inventory_Item_Id             = l_XRef_Rec.Inventory_Item_Id
            AND Cross_Reference               = l_XRef_Rec.Cross_Reference
            AND Decode(Organization_Id,NULL,Org_Independent_Flag,Organization_Id) =
                Decode(l_XRef_Rec.Organization_Id,NULL,l_XRef_Rec.Org_Independent_Flag,l_XRef_Rec.Organization_Id);

            --record already Exists
            IF l_XRef_exists='x' THEN
              l_XRef_Rec.x_return_status  :=  FND_API.g_RET_STS_ERROR;
              l_Token_Tbl(1).Token_Name   :=  'INVENTORY_ITEM_ID';
              l_Token_Tbl(1).Token_Value  :=  l_XRef_Rec.Inventory_Item_Id;
              l_Token_Tbl(1).Translate    :=  FALSE;
              l_Token_Tbl(2).Token_Name   :=  'CROSS_REFERENCE_TYPE';
              l_Token_Tbl(2).Token_Value  :=  l_XRef_Rec.Cross_Reference_Type;
              l_Token_Tbl(2).Translate    :=  FALSE;
              l_Token_Tbl(3).Token_Name   :=  'CROSS_REFERENCE';
              l_Token_Tbl(3).Token_Value  :=  l_XRef_Rec.Cross_Reference;
              l_Token_Tbl(3).Translate    :=  FALSE;

              Error_Handler.Add_Error_Message
              (
              p_message_name       =>  'INV_XREF_PRIMARY_KEY_VIOLATED'
              ,p_application_id    =>  'INV'
              ,p_token_tbl         =>  l_Token_Tbl
              ,p_message_type      =>  'E'
              ,p_entity_code       =>  G_Entity_Code
              ,p_entity_index      =>  l_Xref_Indx
              ,p_table_name        =>  G_Table_Name
              );
              RAISE VALIDATION_ERROR;
            END IF;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
          END;
        END IF ;

	    -- locking the row
        OPEN mtl_xref_lock_b;
        FETCH mtl_xref_lock_b INTO l_lock_b_recinfo ;
        CLOSE mtl_xref_lock_b;

          OPEN mtl_xref_lock_tl;
        FETCH mtl_xref_lock_tl INTO l_lock_tl_recinfo ;
        CLOSE mtl_xref_lock_tl;

		-- calling update
        MTL_CROSS_REFERENCES_PKG.UPDATE_ROW(
          P_INVENTORY_ITEM_ID             => l_XRef_Rec.Inventory_Item_Id
          ,P_ORGANIZATION_ID              => l_XRef_Rec.Organization_Id
          ,P_CROSS_REFERENCE_TYPE         => l_XRef_Rec.Cross_Reference_Type
          ,P_CROSS_REFERENCE              => l_XRef_Rec.Cross_Reference
          ,P_CROSS_REFERENCE_ID    => l_XRef_Rec.Cross_Reference_Id
          ,P_ORG_INDEPENDENT_FLAG         => l_XRef_Rec.Org_Independent_Flag
          ,P_REQUEST_ID                   => NULL
          ,P_ATTRIBUTE1                   => l_XRef_Rec.Attribute1
          ,P_ATTRIBUTE2                   => l_XRef_Rec.Attribute2
          ,P_ATTRIBUTE3                   => l_XRef_Rec.Attribute3
          ,P_ATTRIBUTE4                   => l_XRef_Rec.Attribute4
          ,P_ATTRIBUTE5                   => l_XRef_Rec.Attribute5
          ,P_ATTRIBUTE6                   => l_XRef_Rec.Attribute6
          ,P_ATTRIBUTE7                   => l_XRef_Rec.Attribute7
          ,P_ATTRIBUTE8                   => l_XRef_Rec.Attribute8
          ,P_ATTRIBUTE9                   => l_XRef_Rec.Attribute9
          ,P_ATTRIBUTE10                  => l_XRef_Rec.Attribute10
          ,P_ATTRIBUTE11                  => l_XRef_Rec.Attribute11
          ,P_ATTRIBUTE12                  => l_XRef_Rec.Attribute12
          ,P_ATTRIBUTE13                  => l_XRef_Rec.Attribute13
          ,P_ATTRIBUTE14                  => l_XRef_Rec.Attribute14
          ,P_ATTRIBUTE15                  => l_XRef_Rec.Attribute15
          ,P_ATTRIBUTE_CATEGORY           => l_XRef_Rec.Attribute_category
          ,P_DESCRIPTION                  => l_XRef_Rec.Description
          ,P_LAST_UPDATE_DATE             => Nvl(l_XRef_Rec.Last_Update_Date,SYSDATE)
          ,P_LAST_UPDATED_BY              => Nvl(l_XRef_Rec.Last_Updated_By,FND_GLOBAL.USER_ID)
          ,P_LAST_UPDATE_LOGIN            => Nvl(l_XRef_Rec.Last_Update_Login,FND_GLOBAL.LOGIN_ID)
          ,P_UOM_CODE                     => NULL
          ,P_REVISION_ID                  => NULL
          ,P_EPC_GTIN_SERIAL => l_mtl_XRef_rec.EPC_GTIN_SERIAL
	  ,P_SOURCE_SYSTEM_ID       => l_mtl_XRef_rec.SOURCE_SYSTEM_ID
          ,P_START_DATE_ACTIVE      => l_mtl_XRef_rec.START_DATE_ACTIVE
          ,P_END_DATE_ACTIVE        => l_mtl_XRef_rec.END_DATE_ACTIVE
          ,X_OBJECT_VERSION_NUMBER =>returned_object_version_number
          );

	  ELSIF  l_XRef_Rec.Transaction_Type = 'DELETE' THEN
        -- current cols should not be NULL.
     IF l_XRef_Rec.CROSS_REFERENCE_ID =FND_API.G_MISS_NUM THEN

          l_XRef_Rec.x_return_status:=FND_API.g_RET_STS_ERROR;  -- assigning the record status as error
          Error_Handler.Add_Error_Message
          (
          p_message_name		   =>  'INV_XREF_ID_NULL'
          ,p_application_id		   =>  'INV'
          ,p_message_type		   =>  'E'
          ,p_entity_code	  	   =>  G_Entity_Code
          ,p_entity_index		   =>  l_Xref_Indx
          ,p_table_name		       =>  G_Table_Name
          );
          RAISE VALIDATION_ERROR;
        END IF;

        -- checking for the record existance.
        OPEN  mtl_xref_cur;
        FETCH  mtl_xref_cur INTO l_mtl_XRef_rec;
          IF mtl_xref_cur%NOTFOUND THEN

            l_XRef_Rec.x_return_status:=FND_API.g_RET_STS_ERROR;
            Error_Handler.Add_Error_Message
            (
            p_message_name          =>  'INV_XREF_ID_NOTEXISTS'
            ,p_application_id       =>  'INV'
            ,p_message_type         =>  'E'
            ,p_entity_code          =>  G_Entity_Code
            ,p_entity_index         =>  l_Xref_Indx
            ,p_table_name           =>  G_Table_Name
            );
			CLOSE mtl_xref_cur;
            RAISE VALIDATION_ERROR;
          END IF;
        CLOSE mtl_xref_cur;

        -- locking the row
        OPEN mtl_xref_lock_b;
        FETCH mtl_xref_lock_b INTO l_lock_b_recinfo ;
        CLOSE mtl_xref_lock_b;

          OPEN mtl_xref_lock_tl;
        FETCH mtl_xref_lock_tl INTO l_lock_tl_recinfo ;
        CLOSE mtl_xref_lock_tl;

        -- calling delete
        MTL_CROSS_REFERENCES_PKG.DELETE_ROW(
          P_CROSS_REFERENCE_ID     => l_XRef_Rec.CROSS_REFERENCE_ID );

	  END IF;  -- Transaction type

	EXCEPTION
    WHEN VALIDATION_ERROR THEN
      X_return_status:= FND_API.g_RET_STS_ERROR;
	  l_msg_count := l_msg_count +1;

    WHEN resource_busy THEN
      Error_Handler.Add_Error_Message
      (
      p_message_name          =>  'INV_XREF_RECORD_LOCKED'
      ,p_application_id       =>  'INV'
      ,p_message_type         =>  'E'
      ,p_entity_code          =>  G_Entity_Code
      ,p_entity_index         =>  l_Xref_Indx
      ,p_table_name           =>  G_Table_Name
      );

      l_XRef_Rec.x_return_status:=FND_API.g_RET_STS_ERROR;
      X_return_status:= FND_API.g_RET_STS_ERROR;
      l_msg_count := l_msg_count +1;

    WHEN others THEN
      x_return_status  :=  FND_API.G_RET_STS_UNEXP_ERROR;
      l_Token_Tbl(1).Token_Name   :=  'PACKAGE_NAME';
      l_Token_Tbl(1).Token_Value  :=  G_PKG_NAME;
      l_Token_Tbl(1).Translate    :=  FALSE;
      l_Token_Tbl(2).Token_Name   :=  'PROCEDURE_NAME';
      l_Token_Tbl(2).Token_Value  :=  l_api_name;
      l_Token_Tbl(2).Translate    :=  FALSE;
      l_Token_Tbl(3).Token_Name   :=  'ERROR_TEXT';
      l_Token_Tbl(3).Token_Value  :=  SQLERRM;
      l_Token_Tbl(3).Translate    :=  FALSE;

	  Error_Handler.Add_Error_Message
      (
      p_message_name                =>  'INV_ITEM_UNEXPECTED_ERROR'
      ,p_application_id             =>  'INV'
      ,p_token_tbl                  =>  l_Token_Tbl
      ,p_message_type               =>  'E'
      ,p_entity_code                =>  G_Entity_Code
      ,p_entity_index               =>  l_Xref_Indx
      ,p_table_name                 =>  G_Table_Name
      );
	  l_msg_count := l_msg_count +1;

	  ROLLBACK TO MTL_CROSS_REFERENCES_PVT; -- rolling back to savepoint

    END; -- internal begin
  END LOOP;  -- p_XRef_Tbl

  p_XRef_Tbl:=l_XRef_Tbl;
  x_msg_count:=l_msg_count;

  IF (p_commit = FND_API.g_TRUE) THEN
  COMMIT;
  END IF;

END Process_XRef;
END MTL_CROSS_REFERENCES_PVT;

/
