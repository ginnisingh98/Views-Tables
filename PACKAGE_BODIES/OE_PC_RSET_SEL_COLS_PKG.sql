--------------------------------------------------------
--  DDL for Package Body OE_PC_RSET_SEL_COLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_PC_RSET_SEL_COLS_PKG" AS
/* $Header: OEXPCRSB.pls 120.0 2005/06/01 02:24:54 appldev noship $ */

   ---------------------------------------------------
   PROCEDURE Insert_Row(
      x_rowid    				in out NOCOPY /* file.sql.39 change */  varchar2
      ,x_record_set_id 			in      number
      ,x_column_name                in      varchar2
      ,x_created_by       	 	in      number
      ,x_creation_date       		in      date
      ,x_last_updated_by 	    	in      number
      ,x_last_update_date        	in      date
      ,x_last_update_login       	in      number
   )
   Is
      CURSOR CROWID IS SELECT rowid FROM oe_pc_rset_sel_cols
                       WHERE record_set_id = x_record_set_id
                       AND   column_name   = x_column_name;

   Begin

      INSERT INTO oe_pc_rset_sel_cols (
         record_set_id
         ,column_name
         ,created_by
         ,creation_date
         ,last_updated_by
         ,last_update_date
         ,last_update_login
      )
      Values
      (
         x_record_set_id
         ,x_column_name
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

      UPDATE oe_pc_rsets
      SET
         last_updated_by    	 = x_last_updated_by
         ,last_update_date     = x_last_update_date
         ,last_update_login     = x_last_update_login
      WHERE record_set_id = x_record_set_id ;


   End Insert_Row;
   ------------------------------------------
   PROCEDURE Lock_Row(
      x_rowid    				in      varchar2
      ,x_record_set_id 			in      number
      ,x_column_name                in      varchar2
      ,x_created_by       	 	in      number
      ,x_creation_date       		in      date
      ,x_last_updated_by 	    	in      number
      ,x_last_update_date        	in      date
      ,x_last_update_login       	in      number
   )
   Is
      CURSOR C IS
         SELECT *
         FROM oe_pc_rset_sel_cols
         WHERE rowid = x_rowid
         FOR UPDATE OF column_name NOWAIT;

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
               (Recinfo.record_set_id = x_record_set_id)
           AND (rtrim(Recinfo.column_name)  = x_column_name)
           AND (Recinfo.created_by   	 = x_created_by)
           AND (Recinfo.creation_date	 = x_creation_date)
           AND (Recinfo.last_updated_by    = x_last_updated_by)
           AND (Recinfo.last_update_date   = x_last_update_date)
           AND (    (Recinfo.last_update_login = x_last_update_login)
                 OR (    (recinfo.last_update_login IS NULL)
                      AND(x_last_update_login IS NULL)))
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
      ,x_record_set_id 			in      number
      ,x_column_name                in      varchar2
      ,x_created_by       	 	in      number
      ,x_creation_date       		in      date
      ,x_last_updated_by 	    	in      number
      ,x_last_update_date        	in      date
      ,x_last_update_login       	in      number
   )
   Is
   Begin
      UPDATE oe_pc_rset_sel_cols
      SET
         column_name 		 = x_column_name
         ,last_updated_by    	 = x_last_updated_by
         ,last_update_date     = x_last_update_date
         ,last_update_login     = x_last_update_login
      WHERE rowid = x_rowid;

     --update the timestamp on the record sets table
     UPDATE oe_pc_rsets
     SET
         last_updated_by    	 = x_last_updated_by
         ,last_update_date     = x_last_update_date
         ,last_update_login     = x_last_update_login
     WHERE record_set_id = x_record_set_id ;

   End Update_Row;
   -------------------------------------------------

   PROCEDURE Delete_Row(
      x_rowid    			in      varchar2
   )
   Is
   Begin

      DELETE FROM oe_pc_rset_sel_cols
      WHERE  rowid = x_rowid;
      if (SQL%NOTFOUND) then
         RAISE NO_DATA_FOUND;
      end if;

   End Delete_Row;
   -------------------------------------------------------------------
   PROCEDURE Check_Unique(
      x_rowid    			in      varchar2
      ,x_record_Set_id		in	  number
      ,x_column_name		in 	  varchar2
   )
   Is
      dummy  number;
   Begin
       -- column names name should be unique within a record set
       SELECT count(1)
       INTO   dummy
       FROM   oe_pc_rset_sel_cols
       WHERE  record_set_id = x_record_set_id
       AND    column_name   = x_column_name
       AND    ((x_rowid IS null) OR (rowid <> x_rowid));

       if (dummy >= 1) then
          fnd_message.set_name('ONT', 'OE_PC_RS_DUP_COLUMN_NAME');
          app_exception.raise_exception;
       end if;
   End Check_Unique;
   -----------------------------------------------------------------------
END OE_PC_RSET_SEL_COLS_PKG;

/
