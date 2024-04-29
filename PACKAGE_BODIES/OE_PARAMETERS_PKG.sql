--------------------------------------------------------
--  DDL for Package Body OE_PARAMETERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_PARAMETERS_PKG" as
/* $Header: OEXPARAB.pls 115.21 2004/05/05 12:22:17 rmoharan ship $ */
--Pack J
-- Start of comments
-- API name         :  Insert_Row
-- Type             :  Public
-- Description      :  Inserts record in Oe_Sys_Parameters_All table.
-- Parameters       :
-- IN               :  p_sys_param_all_rec     IN
--			       oe_parameters_pkg.sys_param_all_rec_type     Required
--
-- OUT              :  x_row_id                   OUT  VARCHAR2
--
-- End of Comments
  PROCEDURE Insert_Row(p_sys_param_all_rec IN
			       oe_parameters_pkg.sys_param_all_rec_type,
    		       x_row_id  OUT NOCOPY VARCHAR2)
  IS
     CURSOR get_rowid IS
      SELECT rowid FROM oe_sys_parameters_all
      WHERE nvl(org_id, -99) = nvl(p_sys_param_all_rec.org_Id, -99)
      AND parameter_code = p_sys_param_all_rec.parameter_code;
   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   --
   BEGIN
      INSERT INTO oe_sys_parameters_all(
              org_id,
              creation_date,
              created_by,
              last_update_date,
              last_updated_by,
              last_update_login,
              parameter_code,
	      parameter_value,
              context,
              attribute1,
              attribute2,
              attribute3,
              attribute4,
              attribute5,
              attribute6,
              attribute7,
              attribute8,
              attribute9,
              attribute10,
              attribute11,
              attribute12,
              attribute13,
              attribute14,
              attribute15
             )
	VALUES (
              p_sys_param_all_rec.org_id,
              p_sys_param_all_rec.creation_date,
              p_sys_param_all_rec.created_by,
              p_sys_param_all_rec.last_update_date,
              p_sys_param_all_rec.last_updated_by,
              p_sys_param_all_rec.last_update_login,
              p_sys_param_all_rec.parameter_code,
	      p_sys_param_all_rec.parameter_value,
              p_sys_param_all_rec.Context,
              p_sys_param_all_rec.Attribute1,
              p_sys_param_all_rec.Attribute2,
              p_sys_param_all_rec.Attribute3,
              p_sys_param_all_rec.Attribute4,
              p_sys_param_all_rec.Attribute5,
              p_sys_param_all_rec.Attribute6,
              p_sys_param_all_rec.Attribute7,
              p_sys_param_all_rec.Attribute8,
              p_sys_param_all_rec.Attribute9,
              p_sys_param_all_rec.Attribute10,
              p_sys_param_all_rec.Attribute11,
              p_sys_param_all_rec.Attribute12,
              p_sys_param_all_rec.Attribute13,
              p_sys_param_all_rec.Attribute14,
              p_sys_param_all_rec.Attribute15
             );

    OPEN get_rowid;
    FETCH get_rowid INTO X_Row_id;
    IF (get_rowid%NOTFOUND) THEN
      CLOSE get_rowid;
      Raise NO_DATA_FOUND;
    END IF;
    CLOSE get_rowid;
  END Insert_Row;

-- Start of comments
-- API name         :  Lock_Row
-- Type             :  Public
-- Description      :  Locks the record in Oe_Sys_Parameters_All table for the rowid.
-- Parameters       :
-- IN               :  p_row_id         IN  VARCHAR2     Required
--
-- OUT              :
--
-- End of Comments

  PROCEDURE Lock_Row(p_row_id  IN  VARCHAR2)
  IS
    CURSOR lock_param_all IS
      SELECT org_id,parameter_value,
             context,attribute1,
	     attribute2,attribute3,
	     attribute4,attribute5,
	     attribute6,attribute7,
	     attribute8,attribute9,
	     attribute10,attribute11,
	     attribute12,attribute13,
	     attribute14,attribute15
      FROM oe_sys_parameters_all
      WHERE rowid = p_row_id
      FOR UPDATE OF parameter_value NOWAIT;

    l_recinfo lock_param_all%ROWTYPE;
    RECORD_CHANGED EXCEPTION;
   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   --
  BEGIN
     IF p_row_id IS NOT NULL THEN
        OPEN lock_param_all ;
        FETCH lock_param_all INTO  l_recinfo;
        IF lock_param_all%NOTFOUND THEN
           CLOSE lock_param_all;
           fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
           app_exception.raise_exception;
        END IF;
        CLOSE lock_param_all;
     END IF;
  EXCEPTION
    WHEN OTHERS THEN
       raise;
  END Lock_Row;

-- Start of comments
-- API name         :  Update_Row
-- Type             :  Public
-- Description      :  update the record in Oe_Sys_Parameters_All table for the rowid if not found
--                     insert the record.
-- Parameters       :
-- IN               :  p_sys_param_all_rec     IN
--			       oe_parameters_pkg.sys_param_all_rec_type     Required
--
-- IN OUT           :  x_row_id                IN  VARCHAR2
--
-- End of Comments

  PROCEDURE Update_Row(x_row_id  IN OUT NOCOPY  VARCHAR2,
                       p_sys_param_all_rec IN
			       oe_parameters_pkg.sys_param_all_rec_type)

  IS
   --
   l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
   --
  BEGIN
     IF x_row_id IS NOT NULL THEN

        UPDATE oe_sys_parameters_all
        SET
          org_id                	  =     p_sys_param_all_rec.org_id,
          last_update_date                =     p_sys_param_all_rec.Last_Update_Date,
          last_updated_by                 =     p_sys_param_all_rec.Last_Updated_By,
          last_update_login               =     p_sys_param_all_rec.Last_Update_Login,
          parameter_value                 =     p_sys_param_all_rec.parameter_value,
          context               	  =     p_sys_param_all_rec.Context,
          attribute1                      =     p_sys_param_all_rec.Attribute1,
          attribute2                      =     p_sys_param_all_rec.Attribute2,
          attribute3                      =     p_sys_param_all_rec.Attribute3,
          attribute4                      =     p_sys_param_all_rec.Attribute4,
          attribute5                      =     p_sys_param_all_rec.Attribute5,
          attribute6                      =     p_sys_param_all_rec.Attribute6,
          attribute7                      =     p_sys_param_all_rec.Attribute7,
          attribute8                      =     p_sys_param_all_rec.Attribute8,
          attribute9                      =     p_sys_param_all_rec.Attribute9,
          attribute10                     =     p_sys_param_all_rec.Attribute10,
          attribute11                     =     p_sys_param_all_rec.Attribute11,
          attribute12                     =     p_sys_param_all_rec.Attribute12,
          attribute13                     =     p_sys_param_all_rec.Attribute13,
          attribute14                     =     p_sys_param_all_rec.Attribute14,
          attribute15                     =     p_sys_param_all_rec.Attribute15
       WHERE rowid = X_Row_id;

       IF (SQL%NOTFOUND) THEN
        -- Record does not exists. Inserting the record.
          Insert_Row(p_sys_param_all_rec,
     	             x_row_id );
       END IF;
     ELSE -- New Record Insert it.
        Insert_Row(p_sys_param_all_rec,
 	           x_row_id);
     END IF;
  END Update_Row;
  -- End Pack J
  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY 	 VARCHAR2,
                       X_Organization_Id                NUMBER,
                       X_Last_Update_Date               DATE ,
                       X_Last_Updated_By                NUMBER ,
                       X_Creation_Date                  DATE ,
                       X_Created_By                     NUMBER ,
                       X_Last_Update_Login              NUMBER,
                       X_Master_Organization_Id         NUMBER,
		       x_customer_relationships_flag    varchar2,
                       X_Audit_trail_Enable_Flag        VARCHAR2,
                     --MRG BGN
                       X_Compute_Margin_Flag            VARCHAR2,
                     --MRG  END
                       --freight rating begin
                       X_Freight_Rating_Enabled_Flag    VARCHAR2,
                       --freight rating end
                       X_Fte_Ship_Method_Enabled_Flag       VARCHAR2,
                       X_Context                        VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2
  ) IS
   -- CURSOR C IS SELECT rowid FROM oe_system_parameters_all
                 /** WHERE nvl(org_id, -99) = nvl(X_Organization_Id, -99); **/
                -- NVL of -99 is removed as per SSA
                -- WHERE org_id = X_Organization_Id;
    --             WHERE nvl(org_id, -99) = nvl(X_Organization_Id, -99);
   BEGIN
     /*
       INSERT INTO oe_system_parameters_all(
              org_id,
              last_update_date,
              last_updated_by,
              creation_date,
              created_by,
              last_update_login,
              master_organization_id,
	      customer_relationships_flag,
              audit_trail_enable_flag,
             --MRG BGN
              Compute_Margin_Flag,
             --MRG END
              --freight rating begin
              freight_rating_enabled_flag,
              --freight rating end
              Fte_Ship_Method_enabled_flag,
              context,
              attribute1,
              attribute2,
              attribute3,
              attribute4,
              attribute5,
              attribute6,
              attribute7,
              attribute8,
              attribute9,
              attribute10,
              attribute11,
              attribute12,
              attribute13,
              attribute14,
              attribute15
             )
	VALUES (
              X_Organization_Id,
              X_Last_Update_Date,
              X_Last_Updated_By,
              X_Creation_Date,
              X_Created_By,
              X_Last_Update_Login,
              X_Master_Organization_Id,
              x_customer_relationships_flag,
              X_Audit_trail_Enable_Flag,
            --MRG BGN
              X_Compute_Margin_Flag,
            --MRG END
              --freight rating begin
              X_Freight_Rating_Enabled_flag,
              --freight rating end
              X_Fte_Ship_Method_Enabled_Flag,
              X_Context,
              X_Attribute1,
              X_Attribute2,
              X_Attribute3,
              X_Attribute4,
              X_Attribute5,
              X_Attribute6,
              X_Attribute7,
              X_Attribute8,
              X_Attribute9,
              X_Attribute10,
              X_Attribute11,
              X_Attribute12,
              X_Attribute13,
              X_Attribute14,
              X_Attribute15
             );

    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
   */
    NULL;
  END Insert_Row;

  PROCEDURE Lock_Row(X_Rowid                            VARCHAR2,
                     X_Organization_Id                  NUMBER,
                     X_Master_Organization_Id           NUMBER,
		     x_customer_relationships_flag    varchar2,
		     X_Audit_trail_Enable_Flag        varchar2,
                   --MRG BGN
                     X_Compute_Margin_Flag              VARCHAR2,
                   --MRG END
                     --freight rating begin
                     X_Freight_Rating_Enabled_Flag    VARCHAR2,
                     --freight rating end
                     X_Fte_Ship_Method_Enabled_Flag       VARCHAR2,
                     X_Context               VARCHAR2,
                     X_Attribute1                       VARCHAR2,
                     X_Attribute2                       VARCHAR2,
                     X_Attribute3                       VARCHAR2,
                     X_Attribute4                       VARCHAR2,
                     X_Attribute5                       VARCHAR2,
                     X_Attribute6                       VARCHAR2,
                     X_Attribute7                       VARCHAR2,
                     X_Attribute8                       VARCHAR2,
                     X_Attribute9                       VARCHAR2,
                     X_Attribute10                      VARCHAR2,
                     X_Attribute11                      VARCHAR2,
                     X_Attribute12                      VARCHAR2,
                     X_Attribute13                      VARCHAR2,
                     X_Attribute14                      VARCHAR2,
                     X_Attribute15                      VARCHAR2
  ) IS
/*
    CURSOR C IS
        SELECT *
        FROM   oe_system_parameters_all
        WHERE  rowid = X_Rowid
        FOR UPDATE of Org_Id NOWAIT;
    Recinfo C%ROWTYPE;
    RECORD_CHANGED EXCEPTION;
*/
  BEGIN
/*
    OPEN C;
    FETCH C INTO Recinfo;
    if (C%NOTFOUND) then
      CLOSE C;
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;
    if not ( ((Recinfo.org_id =  X_Organization_Id)
                OR (    (Recinfo.org_id IS NULL)
                    AND (X_Organization_Id IS NULL)))
           AND (Recinfo.master_organization_id =  X_Master_Organization_Id)
		 AND (Recinfo.customer_relationships_flag =
					x_customer_relationships_flag)
                 AND (Recinfo.audit_trail_enable_flag = x_audit_trail_enable_flag)
        --MRG BGN
           AND (   (Recinfo.Compute_Margin_Flag = X_Compute_Margin_Flag)
                OR (    (Recinfo.Compute_Margin_Flag IS NULL)
                   AND  (X_Compute_Margin_Flag IS NULL)))
        --MRG END
           --freight rating begin
           AND (   (Recinfo.Freight_Rating_Enabled_flag = X_Freight_Rating_Enabled_flag)
                OR (    (Recinfo.Freight_Rating_Enabled_flag IS NULL)
                   AND  (X_Freight_Rating_Enabled_flag IS NULL)))
           --freight rating end
           AND (   (Recinfo.Fte_Ship_Method_Enabled_flag = X_Fte_Ship_Method_Enabled_flag)
                OR (    (Recinfo.Fte_Ship_Method_Enabled_flag IS NULL)
                   AND  (X_Fte_Ship_Method_Enabled_flag IS NULL)))
           ) then
	    RAISE RECORD_CHANGED;
	  end if;

          if not ( (   (Recinfo.Context =  X_Context)
                OR (    (Recinfo.Context IS NULL)
                    AND (X_Context IS NULL)))
           AND (   (Recinfo.attribute1 =  X_Attribute1)
                OR (    (Recinfo.attribute1 IS NULL)
                    AND (X_Attribute1 IS NULL)))
           AND (   (Recinfo.attribute2 =  X_Attribute2)
                OR (    (Recinfo.attribute2 IS NULL)
                    AND (X_Attribute2 IS NULL)))
           AND (   (Recinfo.attribute3 =  X_Attribute3)
                OR (    (Recinfo.attribute3 IS NULL)
                    AND (X_Attribute3 IS NULL)))
           AND (   (Recinfo.attribute4 =  X_Attribute4)
                OR (    (Recinfo.attribute4 IS NULL)
                    AND (X_Attribute4 IS NULL)))
           AND (   (Recinfo.attribute5 =  X_Attribute5)
                OR (    (Recinfo.attribute5 IS NULL)
                    AND (X_Attribute5 IS NULL)))
           AND (   (Recinfo.attribute6 =  X_Attribute6)
                OR (    (Recinfo.attribute6 IS NULL)
                    AND (X_Attribute6 IS NULL)))
           AND (   (Recinfo.attribute7 =  X_Attribute7)
                OR (    (Recinfo.attribute7 IS NULL)
                    AND (X_Attribute7 IS NULL)))
           AND (   (Recinfo.attribute8 =  X_Attribute8)
                OR (    (Recinfo.attribute8 IS NULL)
                    AND (X_Attribute8 IS NULL)))
           AND (   (Recinfo.attribute9 =  X_Attribute9)
                OR (    (Recinfo.attribute9 IS NULL)
                    AND (X_Attribute9 IS NULL)))
           AND (   (Recinfo.attribute10 =  X_Attribute10)
                OR (    (Recinfo.attribute10 IS NULL)
                    AND (X_Attribute10 IS NULL)))
           AND (   (Recinfo.attribute11 =  X_Attribute11)
                OR (    (Recinfo.attribute11 IS NULL)
                    AND (X_Attribute11 IS NULL)))
           AND (   (Recinfo.attribute12 =  X_Attribute12)
                OR (    (Recinfo.attribute12 IS NULL)
                    AND (X_Attribute12 IS NULL)))
           AND (   (Recinfo.attribute13 =  X_Attribute13)
                OR (    (Recinfo.attribute13 IS NULL)
                    AND (X_Attribute13 IS NULL)))
           AND (   (Recinfo.attribute14 =  X_Attribute14)
                OR (    (Recinfo.attribute14 IS NULL)
                    AND (X_Attribute14 IS NULL)))
           AND (   (Recinfo.attribute15 =  X_Attribute15)
                OR (    (Recinfo.attribute15 IS NULL)
                    AND (X_Attribute15 IS NULL)))
	 )then
	    Raise RECORD_CHANGED;
         end if;
    EXCEPTION
    WHEN RECORD_CHANGED THEN
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    WHEN OTHERS THEN
	raise;
*/
NULL;
  END Lock_Row;

  PROCEDURE Update_Row(X_Rowid                          VARCHAR2,
                       X_Organization_Id                NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Master_Organization_Id         NUMBER,
		       x_customer_relationships_flag    varchar2,
                       X_Audit_trail_Enable_Flag        VARCHAR2,
                     --MRG BGN
                       X_Compute_Margin_Flag            VARCHAR2,
                     --MRG  END
                       --freight rating begin
                       X_Freight_Rating_Enabled_Flag    VARCHAR2,
                       --freight rating end
                       X_Fte_Ship_Method_Enabled_Flag       VARCHAR2,
                       X_Context                        VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2
  ) IS
  BEGIN
/*
    UPDATE oe_system_parameters_all
    SET
       org_id                 	=     X_Organization_Id,
       last_update_date                =     X_Last_Update_Date,
       last_updated_by                 =     X_Last_Updated_By,
       last_update_login               =     X_Last_Update_Login,
       master_organization_id          =     X_Master_Organization_Id,
       customer_relationships_flag     =     x_customer_relationships_flag,
       audit_trail_enable_flag         =     X_Audit_trail_Enable_Flag,
     --MRG BGN
       Compute_Margin_Flag             =     X_Compute_Margin_Flag,
     --MRG END
       --freight rating begin
       freight_rating_enabled_flag     =     X_Freight_Rating_Enabled_flag,
       --freight rating end
       Fte_Ship_Method_enabled_flag    =     X_Fte_Ship_Method_Enabled_flag,
       context              	       =     X_Context,
       attribute1                      =     X_Attribute1,
       attribute2                      =     X_Attribute2,
       attribute3                      =     X_Attribute3,
       attribute4                      =     X_Attribute4,
       attribute5                      =     X_Attribute5,
       attribute6                      =     X_Attribute6,
       attribute7                      =     X_Attribute7,
       attribute8                      =     X_Attribute8,
       attribute9                      =     X_Attribute9,
       attribute10                     =     X_Attribute10,
       attribute11                     =     X_Attribute11,
       attribute12                     =     X_Attribute12,
       attribute13                     =     X_Attribute13,
       attribute14                     =     X_Attribute14,
       attribute15                     =     X_Attribute15
    WHERE rowid = X_Rowid;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
*/
NULL;
  END Update_Row;
  PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
  BEGIN
    IF OE_CODE_CONTROL.CODE_RELEASE_LEVEL >= '110510' THEN
       DELETE FROM oe_sys_parameters_all
       WHERE rowid = X_Rowid;
/*
    ELSE

       DELETE FROM oe_system_parameters_all
       WHERE rowid = X_Rowid;
*/
    END IF;
    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  END Delete_Row;


END OE_PARAMETERS_PKG;

/
