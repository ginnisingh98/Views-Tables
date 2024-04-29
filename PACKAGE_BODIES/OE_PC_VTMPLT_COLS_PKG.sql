--------------------------------------------------------
--  DDL for Package Body OE_PC_VTMPLT_COLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_PC_VTMPLT_COLS_PKG" AS
/* $Header: OEXPCVCB.pls 120.0 2005/06/01 01:34:50 appldev noship $ */


   PROCEDURE Insert_Row(
      x_rowid    				in out NOCOPY /* file.sql.39 change */  varchar2
	 ,x_validation_tmplt_col_id	in out NOCOPY /* file.sql.39 change */ number
      ,x_validation_tmplt_id 		in      number
      ,x_column_name                in      varchar2
      ,x_validation_op              in      varchar2
      ,x_value_string          	in      varchar2
      ,x_created_by       	 	in      number
      ,x_creation_date       		in      date
      ,x_last_updated_by 	    	in      number
      ,x_last_update_date        	in      date
      ,x_last_update_login       	in      number
   )
   Is
	 CURSOR C IS SELECT oe_pc_vtmplt_cols_s.nextval FROM dual;
      CURSOR CROWID IS SELECT rowid FROM oe_pc_vtmplt_cols
                       WHERE validation_tmplt_id = x_validation_tmplt_id
                       AND   column_name         = x_column_name;

   Begin

	OPEN C;
	FETCH C INTO x_validation_tmplt_col_id;
	if (C%NOTFOUND) then
	  CLOSE C;
	  RAISE NO_DATA_FOUND;
	end if;
	CLOSE C;

      INSERT INTO oe_pc_vtmplt_cols (
	    validation_tmplt_col_id
         ,validation_tmplt_id
         ,column_name
         ,validation_op
         ,value_string
         ,created_by
         ,creation_date
         ,last_updated_by
         ,last_update_date
         ,last_update_login
      )
      Values
      (
	    x_validation_tmplt_col_id
         ,x_validation_tmplt_id
         ,x_column_name
         ,x_validation_op
         ,x_value_string
         ,x_created_by
         ,x_creation_date
         ,x_last_updated_by
         ,x_last_update_date
         ,x_last_update_login
      );

      Open CROWID;
      Fetch CROWID into x_rowid;
      if (CROWID%NOTFOUND) then
         CLOSE CROWID;
         RAISE NO_DATA_FOUND;
      end if;
      CLOSE CROWID;

      UPDATE oe_pc_vtmplts
      SET
         last_updated_by    	 = x_last_updated_by
         ,last_update_date     = x_last_update_date
         ,last_update_login     = x_last_update_login
      WHERE validation_tmplt_id = x_validation_tmplt_id;

   End Insert_Row;


   ------------------------------------------
   PROCEDURE Lock_Row(
      x_rowid    				in      varchar2
	 ,x_validation_tmplt_col_id	in	   number
      ,x_validation_tmplt_id 		in      number
      ,x_column_name                in      varchar2
      ,x_validation_op              in      varchar2
      ,x_value_string          	in      varchar2
      ,x_created_by       	 	in      number
      ,x_creation_date       		in      date
      ,x_last_updated_by 	    	in      number
      ,x_last_update_date        	in      date
      ,x_last_update_login       	in      number
   )
   Is
      CURSOR C IS
         SELECT *
         FROM oe_pc_vtmplt_cols
         WHERE rowid = x_rowid
         FOR UPDATE OF value_string NOWAIT;

      Recinfo C%ROWTYPE;
   Begin
      Open C;
      Fetch C into Recinfo;
      if (C%NOTFOUND) then
         Close C;
         FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
         APP_EXCEPTION.Raise_Exception;
      end if;
      Close C;
      if (
           (Recinfo.validation_tmplt_col_id = x_validation_tmplt_col_id)
           AND (Recinfo.validation_tmplt_id = x_validation_tmplt_id)
           AND (rtrim(Recinfo.column_name)  = x_column_name)
           AND (rtrim(Recinfo.validation_op)   = x_validation_op)
           AND (Recinfo.created_by   	 = x_created_by)
           AND (Recinfo.creation_date	 = x_creation_date)
           AND (Recinfo.last_updated_by    = x_last_updated_by)
           AND (Recinfo.last_update_date   = x_last_update_date)
           AND (    (Recinfo.last_update_login = x_last_update_login)
                 OR (    (recinfo.last_update_login IS NULL)
                      AND(x_last_update_login IS NULL)))
           AND (    (Recinfo.value_string = x_value_string)
                 OR (    (recinfo.value_string IS NULL)
                      AND(x_value_string IS NULL)))
         ) then
         return;
      else
         FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
         APP_EXCEPTION.Raise_Exception;
      end if;
   End Lock_Row;

   --------------------------------------------------------------------
   PROCEDURE Update_Row(
      x_rowid    				in      varchar2
	 ,x_validation_tmplt_col_id   in	   number
      ,x_validation_tmplt_id 		in      number
      ,x_column_name                in      varchar2
      ,x_validation_op              in      varchar2
      ,x_value_string          	in      varchar2
      ,x_created_by       	 	in      number
      ,x_creation_date       		in      date
      ,x_last_updated_by 	    	in      number
      ,x_last_update_date        	in      date
      ,x_last_update_login       	in      number
   )
   Is
   Begin

      UPDATE oe_pc_vtmplt_cols
      SET
	 column_name 		= x_column_name
         ,validation_op        = x_validation_op
         ,value_string         = x_value_string
         ,last_updated_by    	 = x_last_updated_by
         ,last_update_date     = x_last_update_date
         ,last_update_login     = x_last_update_login
      WHERE rowid = x_rowid;

      UPDATE oe_pc_vtmplts
      SET
         last_updated_by    	 = x_last_updated_by
         ,last_update_date     = x_last_update_date
         ,last_update_login     = x_last_update_login
      WHERE validation_tmplt_id = x_validation_tmplt_id;

   End Update_Row;


   -------------------------------------------------
   PROCEDURE Delete_Row(
      x_rowid    			in      varchar2
   )
   Is
   Begin

      DELETE FROM OE_PC_VTMPLT_COLS
      WHERE  rowid = x_rowid;
      if (SQL%NOTFOUND) then
         RAISE NO_DATA_FOUND;
      end if;

   End Delete_Row;


   -------------------------------------------------------------------
   --  Added 2 parameters to fix #2050546 to include column_name,validation_op and
   --  value_string to check for the unique columns

   PROCEDURE Check_Unique(
       x_rowid					in     varchar2
      ,x_validation_tmplt_id			in     number
      ,x_column_name				in     varchar2
      ,x_validation_op                          in     varchar2
      ,x_value_string                           in     varchar2
   )
   Is
       dummy   number;
   Begin

      -- onely one column for a validation tmplt
      SELECT count(1)
      INTO   dummy
      FROM   oe_pc_vtmplt_cols
      WHERE  validation_tmplt_id = x_validation_tmplt_id
      AND    column_name = x_column_name
      AND    validation_op = x_validation_op
      AND    value_string  = x_value_string
      AND    ((x_rowid IS null) OR (rowid <> x_rowid));

      if (dummy >= 1) then
         fnd_message.set_name('ONT', 'OE_PC_VT_DUP_COLUMN_NAME');
        app_exception.raise_exception;
      end if;
   End Check_Unique;
   ------------------------------------------------------------------------

END OE_PC_VTMPLT_COLS_PKG;

/
