--------------------------------------------------------
--  DDL for Package Body CSP_RELATED_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSP_RELATED_ITEMS_PKG" as
/* $Header: cspisdrb.pls 120.0.12010000.3 2011/05/31 08:32:08 htank ship $ */

PROCEDURE UPDATE_ITEM (p_item_id       IN NUMBER,
		       p_org_id        IN NUMBER,
		       p_disposition   IN VARCHAR2,
		       x_return_status OUT NOCOPY VARCHAR2,
		       x_error_tbl     OUT NOCOPY INV_ITEM_GRP.Error_tbl_type) Is

	l_item_rec   INV_ITEM_GRP.Item_rec_type;
	x_item_rec   INV_ITEM_GRP.Item_rec_type;

	cursor c_organizations is
		select decode(mia.control_level,1,mp.master_organization_id,mp.organization_id)
			organization_id
		from   mtl_parameters mp, mtl_item_attributes mia, mtl_system_items msi
		where  mp.master_organization_id = p_org_id
		and    mia.attribute_name = 'MTL_SYSTEM_ITEMS.MTL_TRANSACTIONS_ENABLED_FLAG'
		and    mp.organization_id = msi.organization_id
		and    msi.inventory_item_id = p_item_id
		minus
		select decode(mia.control_level,2,p_org_id)
		from   mtl_item_attributes mia
		where  mia.attribute_name = 'MTL_SYSTEM_ITEMS.MTL_TRANSACTIONS_ENABLED_FLAG';
BEGIN
	l_item_rec.inventory_item_id := p_item_id;
	l_item_rec.mtl_transactions_enabled_flag := p_disposition;

	for cr in c_organizations loop
		l_item_rec.organization_id := cr.organization_id;
		Inv_item_grp.Update_Item
		(
			p_commit              => fnd_api.g_FALSE
			,  p_lock_rows           => fnd_api.g_TRUE
			,  p_validation_level    => fnd_api.g_VALID_LEVEL_FULL
			,  p_Item_rec            => l_item_rec
			,  x_Item_rec            => x_item_rec
			,  x_return_status       => x_return_status
			,  x_Error_tbl           => x_error_tbl
			,  p_Template_Id         => NULL
			,  p_Template_Name       => NULL);
	end loop;
END;

PROCEDURE Insert_Row (X_Rowid		IN OUT  NOCOPY  VARCHAR2,
                       X_Inventory_Item_Id              NUMBER,
                       X_Organization_Id                NUMBER,
                       X_Related_Item_Id                NUMBER,
                       X_Relationship_Type_Id           NUMBER,
                       X_Reciprocal_Flag                VARCHAR2,
                       X_Start_Date                     DATE,
                       X_End_Date                       DATE,
                       X_Attr_Context                   VARCHAR2,
                       X_Attr_Char1                    VARCHAR2,
                       X_Attr_Char2                    VARCHAR2,
                       X_Attr_Char3                    VARCHAR2,
                       X_Attr_Char4                    VARCHAR2,
                       X_Attr_Char5                    VARCHAR2,
                       X_Attr_Char6                    VARCHAR2,
                       X_Attr_Char7                    VARCHAR2,
                       X_Attr_Char8                    VARCHAR2,
                       X_Attr_Char9                    VARCHAR2,
                       X_Attr_Char10                   VARCHAR2,
                       X_Attr_Num1                     NUMBER,
                       X_Attr_Num2                     NUMBER,
                       X_Attr_Num3                     NUMBER,
                       X_Attr_Num4                     NUMBER,
                       X_Attr_Num5                     NUMBER,
                       X_Attr_Num6                     NUMBER,
                       X_Attr_Num7                     NUMBER,
                       X_Attr_Num8                     NUMBER,
                       X_Attr_Num9                     NUMBER,
                       X_Attr_Num10                    NUMBER,
                       X_Attr_Date1                    DATE,
                       X_Attr_Date2                    DATE,
                       X_Attr_Date3                    DATE,
                       X_Attr_Date4                    DATE,
                       X_Attr_Date5                    DATE,
                       X_Attr_Date6                    DATE,
                       X_Attr_Date7                    DATE,
                       X_Attr_Date8                    DATE,
                       X_Attr_Date9                    DATE,
                       X_Attr_Date10                   DATE,
                       X_Last_Update_Date              DATE,
                       X_Last_Updated_By               NUMBER,
                       X_Creation_Date                 DATE,
                       X_Created_By                    NUMBER,
                       X_Last_Update_Login             NUMBER,
                       X_Object_Version_Number         NUMBER
  ) IS

   CURSOR C IS SELECT rowid FROM MTL_RELATED_ITEMS
                 WHERE inventory_item_id = X_Inventory_Item_Id
                 AND   organization_id = X_Organization_Id
                 AND   related_item_id = X_Related_Item_Id
                 AND   Relationship_Type_Id = X_Relationship_Type_Id
                 AND   Reciprocal_Flag = X_Reciprocal_Flag ;

   BEGIN

       INSERT INTO MTL_RELATED_ITEMS(
              inventory_item_id,
              organization_id,
              related_item_id,
              relationship_type_id,
              reciprocal_flag,
              Start_Date,
              End_Date,
              Attr_Context,
              Attr_Char1,
              Attr_Char2,
              Attr_Char3,
              Attr_Char4,
              Attr_Char5,
              Attr_Char6,
              Attr_Char7,
              Attr_Char8,
              Attr_Char9,
              Attr_Char10,
              Attr_Num1,
              Attr_Num2,
              Attr_Num3,
              Attr_Num4,
              Attr_Num5,
              Attr_Num6,
              Attr_Num7,
              Attr_Num8,
              Attr_Num9,
              Attr_Num10,
              Attr_Date1,
              Attr_Date2,
              Attr_Date3,
              Attr_Date4,
              Attr_Date5,
              Attr_Date6,
              Attr_Date7,
              Attr_Date8,
              Attr_Date9,
              Attr_Date10,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              object_version_number
             ) VALUES (
              X_Inventory_Item_Id,
              X_Organization_Id,
              X_Related_Item_Id,
              X_Relationship_Type_Id,
              X_Reciprocal_Flag,
              X_Start_Date,
              X_End_Date,
              X_Attr_Context,
              X_Attr_Char1,
              X_Attr_Char2,
              X_Attr_Char3,
              X_Attr_Char4,
              X_Attr_Char5,
              X_Attr_Char6,
              X_Attr_Char7,
              X_Attr_Char8,
              X_Attr_Char9,
              X_Attr_Char10,
              X_Attr_Num1,
              X_Attr_Num2,
              X_Attr_Num3,
              X_Attr_Num4,
              X_Attr_Num5,
              X_Attr_Num6,
              X_Attr_Num7,
              X_Attr_Num8,
              X_Attr_Num9,
              X_Attr_Num10,
              X_Attr_Date1,
              X_Attr_Date2,
              X_Attr_Date3,
              X_Attr_Date4,
              X_Attr_Date5,
              X_Attr_Date6,
              X_Attr_Date7,
              X_Attr_Date8,
              X_Attr_Date9,
              X_Attr_Date10,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Login,
              X_Object_Version_Number
             );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;

END Insert_Row;


PROCEDURE Lock_Row (X_Rowid                            VARCHAR2,
                     X_Inventory_Item_Id                NUMBER,
                     X_Organization_Id                  NUMBER,
                     X_Related_Item_Id                  NUMBER,
                     X_Relationship_Type_Id             NUMBER,
                     X_Reciprocal_Flag                  VARCHAR2,
                       X_Start_Date                      DATE,
                       X_End_Date                        DATE,
                       X_Attr_Context                  VARCHAR2,
                       X_Attr_Char1                    VARCHAR2,
                       X_Attr_Char2                    VARCHAR2,
                       X_Attr_Char3                    VARCHAR2,
                       X_Attr_Char4                    VARCHAR2,
                       X_Attr_Char5                    VARCHAR2,
                       X_Attr_Char6                    VARCHAR2,
                       X_Attr_Char7                    VARCHAR2,
                       X_Attr_Char8                    VARCHAR2,
                       X_Attr_Char9                    VARCHAR2,
                       X_Attr_Char10                   VARCHAR2,
                       X_Attr_Num1                     NUMBER,
                       X_Attr_Num2                     NUMBER,
                       X_Attr_Num3                     NUMBER,
                       X_Attr_Num4                     NUMBER,
                       X_Attr_Num5                     NUMBER,
                       X_Attr_Num6                     NUMBER,
                       X_Attr_Num7                     NUMBER,
                       X_Attr_Num8                     NUMBER,
                       X_Attr_Num9                     NUMBER,
                       X_Attr_Num10                    NUMBER,
                       X_Attr_Date1                    DATE,
                       X_Attr_Date2                    DATE,
                       X_Attr_Date3                    DATE,
                       X_Attr_Date4                    DATE,
                       X_Attr_Date5                    DATE,
                       X_Attr_Date6                    DATE,
                       X_Attr_Date7                    DATE,
                       X_Attr_Date8                    DATE,
                       X_Attr_Date9                    DATE,
                       X_Attr_Date10                   DATE
  ) IS

    CURSOR C IS
        SELECT *
        FROM   MTL_RELATED_ITEMS
        WHERE  rowid = X_Rowid
        FOR UPDATE of Inventory_Item_Id NOWAIT;

    Recinfo C%ROWTYPE;

  BEGIN

    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;

    if ( (Recinfo.inventory_item_id =  X_Inventory_Item_Id)
           AND (Recinfo.organization_id =  X_Organization_Id)
           AND (Recinfo.related_item_id =  X_Related_Item_Id)
           AND (Recinfo.relationship_type_id =  X_Relationship_Type_Id)
           AND (Recinfo.reciprocal_flag =  X_Reciprocal_Flag)
           AND (Recinfo.Start_Date =  X_Start_Date
               OR ((Recinfo.Start_Date IS NULL)
                    AND (X_Start_Date IS NULL)))
          AND (Recinfo.End_Date =  X_End_Date
               OR ((Recinfo.End_Date IS NULL)
                    AND (X_End_Date IS NULL)))
          AND (Recinfo.Attr_Context =  X_Attr_Context
               OR ((Recinfo.Attr_Context IS NULL)
                    AND (X_Attr_Context IS NULL)))
          AND (Recinfo.Attr_Char1 =  X_Attr_Char1
               OR ((Recinfo.Attr_Char1 IS NULL)
                    AND (X_Attr_Char1 IS NULL)))
         AND (Recinfo.Attr_Char2 =  X_Attr_Char2
              OR ((Recinfo.Attr_Char2 IS NULL)
                    AND (X_Attr_Char2 IS NULL)))
         AND (Recinfo.Attr_Char3 =  X_Attr_Char3
              OR ((Recinfo.Attr_Char3 IS NULL)
                    AND (X_Attr_Char3 IS NULL)))
         AND (Recinfo.Attr_Char4 =  X_Attr_Char4
              OR ((Recinfo.Attr_Char4 IS NULL)
                    AND (X_Attr_Char4 IS NULL)))
         AND (Recinfo.Attr_Char5 =  X_Attr_Char5
               OR ((Recinfo.Attr_Char5 IS NULL)
                    AND (X_Attr_Char5 IS NULL)))
         AND (Recinfo.Attr_Char6 =  X_Attr_Char6
               OR ((Recinfo.Attr_Char6 IS NULL)
                    AND (X_Attr_Char6 IS NULL)))
         AND (Recinfo.Attr_Char7 =  X_Attr_Char7
               OR ((Recinfo.Attr_Char7 IS NULL)
                    AND (X_Attr_Char7 IS NULL)))
         AND (Recinfo.Attr_Char8 =  X_Attr_Char8
               OR ((Recinfo.Attr_Char8 IS NULL)
                    AND (X_Attr_Char8 IS NULL)))
         AND (Recinfo.Attr_Char9 =  X_Attr_Char9
               OR ((Recinfo.Attr_Char9 IS NULL)
                    AND (X_Attr_Char9 IS NULL)))
         AND (Recinfo.Attr_Char10 =  X_Attr_Char10
              OR ((Recinfo.Attr_Char10 IS NULL)
                    AND (X_Attr_Char10 IS NULL)))
         AND (Recinfo.Attr_Num1 =  X_Attr_Num1
              OR ((Recinfo.Attr_Num1 IS NULL)
                    AND (X_Attr_Num1 IS NULL)))
         AND (Recinfo.Attr_Num2 =  X_Attr_Num2
              OR ((Recinfo.Attr_Num2 IS NULL)
                    AND (X_Attr_Num2 IS NULL)))
         AND (Recinfo.Attr_Num3 =  X_Attr_Num3
               OR ((Recinfo.Attr_Num3 IS NULL)
                    AND (X_Attr_Num3 IS NULL)))
          AND (Recinfo.Attr_Num4 =  X_Attr_Num4
               OR ((Recinfo.Attr_Num4 IS NULL)
                    AND (X_Attr_Num4 IS NULL)))
          AND (Recinfo.Attr_Num5 =  X_Attr_Num5
                OR ((Recinfo.Attr_Num5 IS NULL)
                    AND (X_Attr_Num5 IS NULL)))
           AND (Recinfo.Attr_Num6 =  X_Attr_Num6
                OR ((Recinfo.Attr_Num6 IS NULL)
                    AND (X_Attr_Num6 IS NULL)))
           AND (Recinfo.Attr_Num7 =  X_Attr_Num7
                OR ((Recinfo.Attr_Num7 IS NULL)
                    AND (X_Attr_Num7 IS NULL)))
           AND (Recinfo.Attr_Num8 =  X_Attr_Num8
                 OR ((Recinfo.Attr_Num8 IS NULL)
                    AND (X_Attr_Num8 IS NULL)))
           AND (Recinfo.Attr_Num9 =  X_Attr_Num9
                 OR ((Recinfo.Attr_Num9 IS NULL)
                    AND (X_Attr_Num9 IS NULL)))
           AND (Recinfo.Attr_Num10 =  X_Attr_Num10
                 OR ((Recinfo.Attr_Num10 IS NULL)
                    AND (X_Attr_Num10 IS NULL)))
           AND (Recinfo.Attr_Date1 =  X_Attr_Date1
                 OR ((Recinfo.Attr_Date1 IS NULL) AND (X_Attr_Date1 IS NULL)))
           AND (Recinfo.Attr_Date2 =  X_Attr_Date2
                 OR ((Recinfo.Attr_Date2 IS NULL) AND (X_Attr_Date2 IS NULL)))
           AND (Recinfo.Attr_Date3 =  X_Attr_Date3
                 OR ((Recinfo.Attr_Date3 IS NULL) AND (X_Attr_Date3 IS NULL)))
           AND (Recinfo.Attr_Date4 =  X_Attr_Date4
                 OR ((Recinfo.Attr_Date4 IS NULL) AND (X_Attr_Date4 IS NULL)))
           AND (Recinfo.Attr_Date5 =  X_Attr_Date5
                 OR ((Recinfo.Attr_Date5 IS NULL) AND (X_Attr_Date5 IS NULL)))
           AND (Recinfo.Attr_Date6 =  X_Attr_Date6
                 OR ((Recinfo.Attr_Date6 IS NULL) AND (X_Attr_Date6 IS NULL)))
           AND (Recinfo.Attr_Date7 =  X_Attr_Date7
                 OR ((Recinfo.Attr_Date7 IS NULL) AND (X_Attr_Date7 IS NULL)))
           AND (Recinfo.Attr_Date8 =  X_Attr_Date8
                 OR ((Recinfo.Attr_Date8 IS NULL) AND (X_Attr_Date8 IS NULL)))
           AND (Recinfo.Attr_Date9 =  X_Attr_Date9
                 OR ((Recinfo.Attr_Date9 IS NULL) AND (X_Attr_Date9 IS NULL)))
           AND (Recinfo.Attr_Date10 =  X_Attr_Date10
                 OR ((Recinfo.Attr_Date10 IS NULL) AND (X_Attr_Date10 IS NULL)))
      ) then
      return;
    else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;

END Lock_Row;


PROCEDURE Update_Row (X_Rowid                          VARCHAR2,
                       X_Inventory_Item_Id              NUMBER,
                       X_Organization_Id                NUMBER,
                       X_Related_Item_Id                NUMBER,
                       X_Relationship_Type_Id           NUMBER,
                       X_Reciprocal_Flag                VARCHAR2,
                       X_Start_Date                      DATE,
                       X_End_Date                        DATE,
                       X_Attr_Context                  VARCHAR2,
                       X_Attr_Char1                    VARCHAR2,
                       X_Attr_Char2                    VARCHAR2,
                       X_Attr_Char3                    VARCHAR2,
                       X_Attr_Char4                    VARCHAR2,
                       X_Attr_Char5                    VARCHAR2,
                       X_Attr_Char6                    VARCHAR2,
                       X_Attr_Char7                    VARCHAR2,
                       X_Attr_Char8                    VARCHAR2,
                       X_Attr_Char9                    VARCHAR2,
                       X_Attr_Char10                   VARCHAR2,
                       X_Attr_Num1                     NUMBER,
                       X_Attr_Num2                     NUMBER,
                       X_Attr_Num3                     NUMBER,
                       X_Attr_Num4                     NUMBER,
                       X_Attr_Num5                     NUMBER,
                       X_Attr_Num6                     NUMBER,
                       X_Attr_Num7                     NUMBER,
                       X_Attr_Num8                     NUMBER,
                       X_Attr_Num9                     NUMBER,
                       X_Attr_Num10                    NUMBER,
                       X_Attr_Date1                    DATE,
                       X_Attr_Date2                    DATE,
                       X_Attr_Date3                    DATE,
                       X_Attr_Date4                    DATE,
                       X_Attr_Date5                    DATE,
                       X_Attr_Date6                    DATE,
                       X_Attr_Date7                    DATE,
                       X_Attr_Date8                    DATE,
                       X_Attr_Date9                    DATE,
                       X_Attr_Date10                   DATE,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER

  ) IS
  BEGIN

    UPDATE MTL_RELATED_ITEMS
    SET
       inventory_item_id          =      X_Inventory_Item_Id,
       organization_id            =      X_Organization_Id,
       related_item_id            =      X_Related_Item_Id,
       relationship_type_id       =      X_Relationship_Type_Id,
       reciprocal_flag            =      X_Reciprocal_Flag,
       Start_Date 		  =      X_Start_Date,
       End_Date 		  =      X_End_Date,
       Attr_Context		  =      X_Attr_Context,
       Attr_Char1 		  =      X_Attr_Char1,
       Attr_Char2 		  =      X_Attr_Char2,
       Attr_Char3 		  =      X_Attr_Char3,
       Attr_Char4 		  =      X_Attr_Char4,
       Attr_Char5 		  =      X_Attr_Char5,
       Attr_Char6 		  =      X_Attr_Char6,
       Attr_Char7 		  =      X_Attr_Char7,
       Attr_Char8 		  =      X_Attr_Char8,
       Attr_Char9 		  =      X_Attr_Char9,
       Attr_Char10 		  =      X_Attr_Char10,
       Attr_Num1 		  =      X_Attr_Num1,
       Attr_Num2 		  =      X_Attr_Num2,
       Attr_Num3 		  =      X_Attr_Num3,
       Attr_Num4 		  =      X_Attr_Num4,
       Attr_Num5 		  =      X_Attr_Num5,
       Attr_Num6 		  =      X_Attr_Num6,
       Attr_Num7 		  =      X_Attr_Num7,
       Attr_Num8 		  =      X_Attr_Num8,
       Attr_Num9 		  =      X_Attr_Num9,
       Attr_Num10 		  =      X_Attr_Num10,
       Attr_Date1	 	  =      X_Attr_Date1,
       Attr_Date2	   	  =      X_Attr_Date2,
       Attr_Date3		  =      X_Attr_Date3,
       Attr_Date4		  =      X_Attr_Date4,
       Attr_Date5		  =      X_Attr_Date5,
       Attr_Date6	  	  =      X_Attr_Date6,
       Attr_Date7		  =      X_Attr_Date7,
       Attr_Date8		  =      X_Attr_Date8,
       Attr_Date9		  =      X_Attr_Date9,
       Attr_Date10		  =      X_Attr_Date10,
       last_update_date           =     X_Last_Update_Date,
       last_update_login          =     X_Last_Update_Login
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

  END Update_Row;

PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
    p_mst_org_id_pk1    number;
    p_replaced_item_id_pk2  number;
    p_replacing_item_pk3 number;
    p_relation_type_pk4 number;
    l_module_name varchar2(100);
  BEGIN
    l_module_name := 'csp.plsql.csp_related_items_pkg.delete_row';

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
            'begin... X_Rowid = ' || X_Rowid);
    end if;

    -- bug # 10396984
    -- delete any attachments for this
    p_relation_type_pk4 := 8;   -- supersession

    select organization_id, inventory_item_id, related_item_id
    into p_mst_org_id_pk1, p_replaced_item_id_pk2, p_replacing_item_pk3
    from MTL_RELATED_ITEMS
    WHERE rowid = X_Rowid;

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
            'p_mst_org_id_pk1 = ' || p_mst_org_id_pk1);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
            'p_replaced_item_id_pk2 = ' || p_replaced_item_id_pk2);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
            'p_replacing_item_pk3 = ' || p_replacing_item_pk3);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
            'p_relation_type_pk4 = ' || p_relation_type_pk4);
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
            'deleting related item record...');
    end if;

    DELETE FROM MTL_RELATED_ITEMS
    WHERE organization_id = p_mst_org_id_pk1
    and inventory_item_id = p_replaced_item_id_pk2
    and related_item_id = p_replacing_item_pk3
    and relationship_type_id = p_relation_type_pk4;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
            'record deleted...');
    end if;

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
            'deleting attachments for ...');
    end if;

    fnd_attached_documents2_pkg.delete_attachments(X_entity_name => 'RELATED_ITEMS',
            X_pk1_value => to_char(p_mst_org_id_pk1),
            X_pk2_value => to_char(p_replaced_item_id_pk2),
            X_pk3_value => to_char(p_replacing_item_pk3),
            X_pk4_value => to_char(p_relation_type_pk4),
            X_delete_document_flag => 'Y'
            );

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
            'attachements deleted...');
    end if;

    if(FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, l_module_name,
            'done...');
    end if;

END Delete_Row;


END CSP_RELATED_ITEMS_PKG;

/
