--------------------------------------------------------
--  DDL for Package Body OE_PC_VTMPLTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_PC_VTMPLTS_PKG" AS
/* $Header: OEXPCVTB.pls 120.1 2005/07/15 03:05:54 ppnair noship $ */

   -------------------------------------------------
   PROCEDURE Insert_Row(
      x_rowid    				in out nocopy varchar2
      ,x_validation_tmplt_id 		in out nocopy number
      ,x_entity_id                  in      number
      ,x_display_name			in      varchar2
      ,x_description  			in      varchar2
      ,x_validation_tmplt_short_name in     varchar2
      ,x_validation_type       	in      varchar2
      ,x_system_flag	        	in      varchar2
      ,x_created_by       	 	in      number
      ,x_creation_date       		in      date
      ,x_last_updated_by 	    	in      number
      ,x_last_update_date        	in      date
      ,x_last_update_login       	in      number
      ,x_wf_item_type                   in      varchar2
      ,x_activity_name			in      varchar2
      ,x_activity_status_code		in      varchar2
      ,x_activity_result_code		in      varchar2
      ,x_api_pkg				in      varchar2
      ,x_api_proc				in      varchar2
      ,x_attribute_category       	in      varchar2
      ,x_attribute1	       	in      varchar2
      ,x_attribute2	       	in      varchar2
      ,x_attribute3	       	in      varchar2
      ,x_attribute4	       	in      varchar2
      ,x_attribute5	       	in      varchar2
      ,x_attribute6	       	in      varchar2
      ,x_attribute7	       	in      varchar2
      ,x_attribute8	       	in      varchar2
      ,x_attribute9	       	in      varchar2
      ,x_attribute10	       	in      varchar2
      ,x_attribute11	       	in      varchar2
      ,x_attribute12	       	in      varchar2
      ,x_attribute13	       	in      varchar2
      ,x_attribute14	       	in      varchar2
      ,x_attribute15	       	in      varchar2
   )
   Is
      CURSOR CROWID IS SELECT rowid FROM oe_pc_vtmplts
                       WHERE validation_tmplt_id = x_validation_tmplt_id;

      CURSOR CID IS SELECT oe_pc_vtmplts_s.nextval
                    FROM sys.dual;
   Begin

   IF x_validation_tmplt_id IS NULL THEN
      Open CID;
      Fetch CID into x_validation_tmplt_id;
      if (CID%NOTFOUND) then
         CLOSE CID;
         RAISE NO_DATA_FOUND;
      end if;
      Close CID;
   END IF;

      INSERT INTO oe_pc_vtmplts (
         validation_tmplt_id
         ,entity_id
         ,validation_tmplt_short_name
         ,validation_type
         ,system_flag
         ,created_by
         ,creation_date
         ,last_updated_by
         ,last_update_date
         ,last_update_login
         ,wf_item_type
         ,activity_name
         ,activity_status_code
         ,activity_result_code
         ,api_pkg
         ,api_proc
         ,attribute_category
         ,attribute1
         ,attribute2
         ,attribute3
         ,attribute4
         ,attribute5
         ,attribute6
         ,attribute7
         ,attribute8
         ,attribute9
         ,attribute10
         ,attribute11
         ,attribute12
         ,attribute13
         ,attribute14
         ,attribute15
      )
      Values
      (
         x_validation_tmplt_id
         ,x_entity_id
         ,x_validation_tmplt_short_name
         ,x_validation_type
         ,x_system_flag
         ,x_created_by
         ,x_creation_date
         ,x_last_updated_by
         ,x_last_update_date
         ,x_last_update_login
         ,x_wf_item_type
         ,x_activity_name
         ,x_activity_status_code
         ,x_activity_result_code
         ,x_api_pkg
         ,x_api_proc
         ,x_attribute_category
         ,x_attribute1
         ,x_attribute2
         ,x_attribute3
         ,x_attribute4
         ,x_attribute5
         ,x_attribute6
         ,x_attribute7
         ,x_attribute8
         ,x_attribute9
         ,x_attribute10
         ,x_attribute11
         ,x_attribute12
         ,x_attribute13
         ,x_attribute14
         ,x_attribute15
      );


      INSERT INTO oe_pc_vtmplts_tl (
         validation_tmplt_id
         ,language
         ,source_lang
         ,created_by
         ,creation_date
         ,last_updated_by
         ,last_update_date
         ,display_name
         ,description
         ,last_update_login
      )
      SELECT
         x_validation_tmplt_id
         ,l.language_code
         ,USERENV('LANG')
         ,x_created_by
         ,x_creation_date
         ,x_last_updated_by
         ,x_last_update_date
         ,x_display_name
         ,x_description
         ,x_last_update_login
      FROM fnd_languages l
      WHERE l.installed_flag in ('I', 'B')
      AND   not exists (
                        SELECT  null
                        FROM oe_pc_vtmplts_tl t
                        WHERE t.validation_tmplt_id = x_validation_tmplt_id
                        AND   t.language            = l.language_code);


      Open CROWID;
      Fetch CROWID into x_rowid;
      if (CROWID%NOTFOUND) then
         CLOSE CROWID;
         RAISE NO_DATA_FOUND;
      end if;
      CLOSE CROWID;

   End Insert_Row;
   ------------------------------------------
   PROCEDURE Lock_Row(
      x_rowid    				in      varchar2
      ,x_validation_tmplt_id 		in      number
      ,x_entity_id                  in      number
      ,x_display_name 			in      varchar2
      ,x_description  			in      varchar2
      ,x_validation_tmplt_short_name in     varchar2
      ,x_validation_type       	in      varchar2
      ,x_system_flag	        	in      varchar2
      ,x_created_by       	 	in      number
      ,x_creation_date       		in      date
      ,x_last_updated_by 	    	in      number
      ,x_last_update_date        	in      date
      ,x_last_update_login       	in      number
      ,x_wf_item_type                   in      varchar2
      ,x_activity_name			in      varchar2
      ,x_activity_status_code		in      varchar2
      ,x_activity_result_code		in      varchar2
      ,x_api_pkg				in      varchar2
      ,x_api_proc				in      varchar2
      ,x_attribute_category       	in      varchar2
      ,x_attribute1	       	in      varchar2
      ,x_attribute2	       	in      varchar2
      ,x_attribute3	       	in      varchar2
      ,x_attribute4	       	in      varchar2
      ,x_attribute5	       	in      varchar2
      ,x_attribute6	       	in      varchar2
      ,x_attribute7	       	in      varchar2
      ,x_attribute8	       	in      varchar2
      ,x_attribute9	       	in      varchar2
      ,x_attribute10	       	in      varchar2
      ,x_attribute11	       	in      varchar2
      ,x_attribute12	       	in      varchar2
      ,x_attribute13	       	in      varchar2
      ,x_attribute14	       	in      varchar2
      ,x_attribute15	       	in      varchar2
   )
   Is
      CURSOR C IS
         SELECT *
         FROM oe_pc_vtmplts
         WHERE rowid = x_rowid
         FOR UPDATE OF validation_tmplt_id NOWAIT;

      Recinfo C%ROWTYPE;

      CURSOR C1 IS
         SELECT *
         FROM oe_pc_vtmplts_tl t
         WHERE validation_tmplt_id = x_validation_tmplt_id
         AND   language = userenv('LANG')
         FOR UPDATE OF validation_tmplt_id NOWAIT;

      tlinfo C1%ROWTYPE;

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
               (Recinfo.validation_tmplt_id = x_validation_tmplt_id)
           AND (Recinfo.entity_id    	  = x_entity_id)
           AND (rtrim(Recinfo.validation_tmplt_short_name) = x_validation_tmplt_short_name)
           AND (rtrim(Recinfo.validation_type) = x_validation_type)
           AND (Recinfo.system_flag         = x_system_flag)
           AND (Recinfo.created_by   	 = x_created_by)
           AND (Recinfo.creation_date	 = x_creation_date)
           AND (Recinfo.last_updated_by    = x_last_updated_by)
           AND (Recinfo.last_update_date   = x_last_update_date)
           AND (    (Recinfo.last_update_login = x_last_update_login)
                 OR (    (recinfo.last_update_login IS NULL)
                      AND(x_last_update_login IS NULL)))
           AND (    (Recinfo.wf_item_type = x_wf_item_type)
                 OR (    (recinfo.wf_item_type IS NULL)
                      AND(x_wf_item_type IS NULL)))
           AND (    (Recinfo.activity_name = x_activity_name)
                 OR (    (recinfo.activity_name IS NULL)
                      AND(x_activity_name IS NULL)))
           AND (    (Recinfo.activity_status_code = x_activity_status_code)
                 OR (    (recinfo.activity_status_code IS NULL)
                      AND(x_activity_status_code IS NULL)))
           AND (    (Recinfo.activity_result_code = x_activity_result_code)
                 OR (    (recinfo.activity_result_code IS NULL)
                      AND(x_activity_result_code IS NULL)))
           AND (    (Recinfo.api_pkg = x_api_pkg)
                 OR (    (recinfo.api_pkg IS NULL)
                      AND(x_api_pkg IS NULL)))
           AND (    (Recinfo.api_proc = x_api_proc)
                 OR (    (recinfo.api_proc IS NULL)
                      AND(x_api_proc IS NULL)))
         ) then
         return;
      else
         FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
         APP_EXCEPTION.Raise_Exception;
      end if;

      Open C1;
      Fetch C1 into tlinfo;
      if (C1%NOTFOUND) then
         Close C1;
         FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
         APP_EXCEPTION.Raise_Exception;
      end if;
      Close C1;

      if (
               (rtrim(tlinfo.display_name)     = x_display_name)
           AND (tlinfo.last_updated_by    = x_last_updated_by)
           AND (tlinfo.last_update_date   = x_last_update_date)
           AND (    (rtrim(tlinfo.description) = x_description)
                 OR (    (tlinfo.description IS NULL)
                      AND(x_description IS NULL)))
           AND (    (tlinfo.last_update_login = x_last_update_login)
                 OR (    (tlinfo.last_update_login IS NULL)
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
      ,x_validation_tmplt_id 		in      number
      ,x_entity_id                  in      number
      ,x_display_name 			in   	  varchar2
      ,x_description  			in      varchar2
      ,x_validation_tmplt_short_name in     varchar2
      ,x_validation_type       	in      varchar2
      ,x_system_flag	        	in      varchar2
      ,x_created_by       	 	in      number
      ,x_creation_date       		in      date
      ,x_last_updated_by 	    	in      number
      ,x_last_update_date        	in      date
      ,x_last_update_login       	in      number
      ,x_wf_item_type                   in      varchar2
      ,x_activity_name			in      varchar2
      ,x_activity_status_code		in      varchar2
      ,x_activity_result_code		in      varchar2
      ,x_api_pkg				in      varchar2
      ,x_api_proc				in      varchar2
      ,x_attribute_category       	in      varchar2
      ,x_attribute1	       	in      varchar2
      ,x_attribute2	       	in      varchar2
      ,x_attribute3	       	in      varchar2
      ,x_attribute4	       	in      varchar2
      ,x_attribute5	       	in      varchar2
      ,x_attribute6	       	in      varchar2
      ,x_attribute7	       	in      varchar2
      ,x_attribute8	       	in      varchar2
      ,x_attribute9	       	in      varchar2
      ,x_attribute10	       	in      varchar2
      ,x_attribute11	       	in      varchar2
      ,x_attribute12	       	in      varchar2
      ,x_attribute13	       	in      varchar2
      ,x_attribute14	       	in      varchar2
      ,x_attribute15	       	in      varchar2
   )
   Is
   Begin

      UPDATE oe_pc_vtmplts
      SET
         entity_id 		 = x_entity_id
         ,validation_tmplt_short_name = x_validation_tmplt_short_name
         ,validation_type      = x_validation_type
         ,system_flag          = x_system_flag
         ,created_by   		 = x_created_by
         ,creation_date		 = x_creation_date
         ,last_updated_by    	 = x_last_updated_by
         ,last_update_date     = x_last_update_date
         ,last_update_login     = x_last_update_login
         ,wf_item_type         = x_wf_item_type
         ,activity_name        = x_activity_name
         ,activity_status_code = x_activity_status_code
         ,activity_result_code = x_activity_result_code
         ,api_pkg			 = x_api_pkg
         ,api_proc		 = x_api_proc
         ,attribute_category   = x_attribute_category
         ,attribute1           = x_attribute1
         ,attribute2           = x_attribute2
         ,attribute3           = x_attribute3
         ,attribute4           = x_attribute4
         ,attribute5           = x_attribute5
         ,attribute6           = x_attribute6
         ,attribute7           = x_attribute7
         ,attribute8           = x_attribute8
         ,attribute9           = x_attribute9
         ,attribute10           = x_attribute10
         ,attribute11           = x_attribute11
         ,attribute12           = x_attribute12
         ,attribute13           = x_attribute13
         ,attribute14           = x_attribute14
         ,attribute15           = x_attribute15
      WHERE validation_tmplt_id = x_validation_tmplt_id;

      if (SQL%NOTFOUND) then
         RAISE NO_DATA_FOUND;
      end if;


      UPDATE oe_pc_vtmplts_tl
      SET
         source_lang		 = USERENV('LANG')
         ,last_updated_by    	 = x_last_updated_by
         ,last_update_date     = x_last_update_date
         ,last_update_login    = x_last_update_login
         ,display_name         = x_display_name
         ,description          = x_description
      WHERE validation_tmplt_id = x_validation_tmplt_id
      AND   USERENV('LANG') in (language, source_lang);

      if (SQL%NOTFOUND) then
         RAISE NO_DATA_FOUND;
      end if;

   End Update_Row;
   -------------------------------------------------

   PROCEDURE Delete_Row(
      x_validation_tmplt_id			in      number
   )
   Is
   Begin

      -- delete constraint rules if any
      DELETE FROM OE_PC_VTMPLT_COLS
      WHERE  validation_tmplt_id = x_validation_tmplt_id;

      -- delete all the validation pkgs from oe_pc_validation_pkgs table
      DELETE FROM OE_PC_VALIDATION_PKGS
      WHERE  validation_tmplt_id = x_validation_tmplt_id;

      -- delete the tl table
      DELETE FROM OE_PC_VTMPLTS_TL
      WHERE  validation_tmplt_id = x_validation_tmplt_id;

      DELETE FROM OE_PC_VTMPLTS
      WHERE  validation_tmplt_id = x_validation_tmplt_id;



      if (SQL%NOTFOUND) then
         RAISE NO_DATA_FOUND;
      end if;

   End Delete_Row;
   -------------------------------------------------------------------
   PROCEDURE Add_Language
   IS
   Begin
     DELETE FROM oe_pc_vtmplts t
     WHERE NOT EXISTS
              (SELECT null
               FROM oe_pc_vtmplts b
               where validation_tmplt_id = t.validation_tmplt_id);

     UPDATE oe_pc_vtmplts_tl t
     SET
     (
       display_name,
       description
     ) = (
          SELECT
            b.display_name,
            b.description
          FROM oe_pc_vtmplts_tl b
          WHERE b.validation_tmplt_id = t.validation_tmplt_id
          AND   b.language      = t.source_lang
         )
     where
     (
       t.validation_tmplt_id,
       t.language
     ) IN (
           SELECT
              subt.validation_tmplt_id,
              subt.language
           FROM oe_pc_vtmplts_tl subb, oe_pc_vtmplts_tl subt
           WHERE subb.validation_tmplt_id = subt.validation_tmplt_id
           AND   subb.language      = subt.source_lang
           AND(subb.display_name <> subt.display_name
               OR subb.DESCRIPTION <> subt.description
               OR (subb.description IS null AND subt.description IS NOT null)
               OR (subb.description IS NOT null AND subt.description IS null)
              )
          );

     INSERT INTO oe_pc_vtmplts_tl
     (
         validation_tmplt_id
         ,language
         ,source_lang
         ,created_by
         ,creation_date
         ,last_updated_by
         ,last_update_date
         ,display_name
         ,description
         ,last_update_login
     )
     SELECT
         b.validation_tmplt_id
         ,l.language_code
         ,b.source_lang    -- bug 2329327
         ,b.created_by
         ,b.creation_date
         ,b.last_updated_by
         ,b.last_update_date
         ,b.display_name
         ,b.description
         ,b.last_update_login
     FROM oe_pc_vtmplts_tl b, fnd_languages l
     WHERE l.installed_flag IN ('I', 'B')
     AND   b.language = USERENV('LANG')
     AND   NOT EXISTS
              ( SELECT null
                FROM oe_pc_vtmplts_tl t
                WHERE t.validation_tmplt_id = b.validation_tmplt_id
                AND   t.language      = l.language_code);
   End Add_Language;
   -------------------------------------------------------------------
   PROCEDURE Check_References(
      x_validation_tmplt_id 		in      number
   )
   Is
     dummy number;
   Begin
      SELECT 1
      into dummy
      FROM  dual
      WHERE NOT EXISTS
            (SELECT 1
             FROM oe_pc_conditions
             WHERE validation_tmplt_id = x_validation_tmplt_id);
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
        fnd_message.set_name('ONT', 'OE_PC_VT_REF_EXISTS');
        app_exception.raise_exception;
   End Check_References;
   -----------------------------------------------------------------------
   PROCEDURE Check_Unique(
      x_rowid					in 	  varchar2
      ,x_entity_id				in      number
      ,x_display_name				in      varchar2
      ,x_validation_tmplt_short_name	in      varchar2
      ,x_validation_unit			in      varchar2
   )
   Is
       dummy   		 number;
       chk_display_name  boolean := FALSE;
       chk_short_name    boolean := FALSE;
   Begin
      if (x_validation_unit = 'ALL') then
         chk_short_name     := TRUE;
         chk_display_name   := TRUE;
      elsif (x_validation_unit = 'VALIDATION_TMPLT_DISPLAY_NAME') then
         chk_display_name  := TRUE;
      elsif (x_validation_unit = 'VALIDATION_TMPLT_SHORT_NAME') then
         chk_short_name  := TRUE;
      end if;

      if (chk_display_name = TRUE) then
          -- record set short name should be unique within an entity
          SELECT count(1)
          INTO   dummy
          FROM   oe_pc_vtmplts_vl
          WHERE  entity_id = x_entity_id
          AND    validation_tmplt_display_name = x_display_name
          AND    ((x_rowid IS null) OR (row_id <> x_rowid));

          if (dummy >= 1) then
             fnd_message.set_name('ONT', 'OE_PC_VT_DUP_DISPLAY_NAME');
             app_exception.raise_exception;
          end if;
      end if;

      if (chk_short_name = TRUE) then
          -- record set short name should be unique within an entity
          SELECT count(1)
          INTO   dummy
          FROM   oe_pc_vtmplts
          WHERE  entity_id = x_entity_id
          AND    validation_tmplt_short_name = x_validation_tmplt_short_name
          AND    ((x_rowid IS null) OR (rowid <> x_rowid));

          if (dummy >= 1) then
             fnd_message.set_name('ONT', 'OE_PC_VT_DUP_SHORT_NAME');
             app_exception.raise_exception;
          end if;
      end if;
   End Check_Unique;
   ------------------------------------------------------------------------

   PROCEDURE Translate_Row(
      x_validation_tmplt_id 			in	   varchar2
	 ,x_owner					in 	   varchar2
      ,x_display_name	in      varchar2
      ,x_description	in      varchar2
	 )
   IS
    l_user_id number :=0;
   BEGIN
      l_user_id :=fnd_load_util.owner_id(x_owner);
      UPDATE oe_pc_vtmplts_tl
      SET
         source_lang		 = USERENV('LANG')
         --,last_updated_by    	 = decode(x_OWNER, 'SEED', 1, 0)
         ,last_updated_by    	 = l_user_id
         ,last_update_date     = sysdate
         ,last_update_login    = 0
         ,display_name         = x_display_name
         ,description          = x_description
      WHERE validation_tmplt_id = x_validation_tmplt_id
      AND   USERENV('LANG') in (language, source_lang);

   END Translate_Row;

   PROCEDURE Load_Row(
       x_validation_tmplt_id 			in      varchar2
      ,x_owner					in	   varchar2
      ,x_display_name	in      varchar2
      ,x_description	in      varchar2
      ,x_entity_id                  in     varchar2
      ,x_validation_tmplt_short_name 	in      varchar2
	 ,x_validation_type			in	   varchar2
	 ,x_activity_name		     in		varchar2
	 ,x_activity_status_code		in		varchar2
	 ,x_activity_result_code		in		varchar2
	 ,x_api_pkg				in		varchar2
	 ,x_api_proc				in		varchar2
      ,x_system_flag	        	in      varchar2
      ,x_attribute_category       	in      varchar2
      ,x_attribute1	       	in      varchar2
      ,x_attribute2	       	in      varchar2
      ,x_attribute3	       	in      varchar2
      ,x_attribute4	       	in      varchar2
      ,x_attribute5	       	in      varchar2
      ,x_attribute6	       	in      varchar2
      ,x_attribute7	       	in      varchar2
      ,x_attribute8	       	in      varchar2
      ,x_attribute9	       	in      varchar2
      ,x_attribute10	       	in      varchar2
      ,x_attribute11	       	in      varchar2
      ,x_attribute12	       	in      varchar2
      ,x_attribute13	       	in      varchar2
      ,x_attribute14	       	in      varchar2
      ,x_attribute15	       	in      varchar2
         ,x_wf_item_type                     in         varchar2
   )
   IS
   BEGIN

    declare
	user_id	number := 0;
	row_id	varchar2(64);
	l_validation_tmplt_id		number;
        l_db_user_id	number := 0;
	l_valid_release boolean:=false;
    begin

     if (X_OWNER = 'SEED') then
		  user_id := 1;
     end if;
     --Seed data versioning changes start
     user_id :=fnd_load_util.owner_id(x_owner);
     begin
        select last_updated_by
	  into l_db_user_id
	  from oe_pc_vtmplts
	  where  validation_tmplt_id = x_validation_tmplt_id;
      exception
        when no_data_found then
	  null;
     end ;
       if (l_db_user_id <= user_id)
           or (l_db_user_id in (0,1,2)
              and user_id in (0,1,2))       then
	  l_valid_release :=true ;
    end if;
    if l_valid_release then
     --Seed data versioning changes end
    OE_PC_vtmplts_pkg.UPDATE_ROW(
	 x_rowid				 => row_id
      ,x_validation_tmplt_id 		 => x_validation_tmplt_id
      ,x_display_name		 => x_display_name
      ,x_description		 => x_description
	 ,x_entity_id				      => x_entity_id
      ,x_validation_tmplt_short_name		 => x_validation_tmplt_short_name
      ,x_validation_type		=> x_validation_type
         ,x_wf_item_type                => x_wf_item_type
	 ,x_activity_name		=> x_activity_name
	 ,x_activity_status_code	=> x_activity_status_code
	 ,x_activity_result_code	=> x_activity_result_code
	 ,x_api_pkg			=> x_api_pkg
	 ,x_api_proc			=> x_api_proc
      ,x_system_flag	      => x_system_flag
      ,x_created_by            => user_id
      ,x_creation_date         => sysdate
      ,x_last_updated_by 	 => user_id
      ,x_last_update_date      => sysdate
      ,x_last_update_login     => 0
      ,x_attribute_category    => x_attribute_category
      ,x_attribute1	           => x_attribute1
      ,x_attribute2	           => x_attribute2
      ,x_attribute3	           => x_attribute3
      ,x_attribute4	           => x_attribute4
      ,x_attribute5	           => x_attribute5
      ,x_attribute6	           => x_attribute6
      ,x_attribute7	           => x_attribute7
      ,x_attribute8	           => x_attribute8
      ,x_attribute9	           => x_attribute9
      ,x_attribute10	           => x_attribute10
      ,x_attribute11	           => x_attribute11
      ,x_attribute12	           => x_attribute12
      ,x_attribute13	           => x_attribute13
      ,x_attribute14	           => x_attribute14
      ,x_attribute15	           => x_attribute15
	 );
     end if;
    exception
	when NO_DATA_FOUND then

	l_validation_tmplt_id := x_validation_tmplt_id;

	 oe_pc_vtmplts_pkg.INSERT_ROW(
	 x_rowid				 => row_id
      ,x_validation_tmplt_id 		 => l_validation_tmplt_id
      ,x_display_name		 => x_display_name
      ,x_description		 => x_description
	 ,x_entity_id				      => x_entity_id
      ,x_validation_tmplt_short_name		 => x_validation_tmplt_short_name
	 ,x_validation_type	      => x_validation_type
         ,x_wf_item_type                => x_wf_item_type
	 ,x_activity_name		=> x_activity_name
	 ,x_activity_status_code	=> x_activity_status_code
	 ,x_activity_result_code	=> x_activity_result_code
	 ,x_api_pkg			=> x_api_pkg
	 ,x_api_proc			=> x_api_proc
      ,x_system_flag	      => x_system_flag
      ,x_created_by            => user_id
      ,x_creation_date         => sysdate
      ,x_last_updated_by 	 => user_id
      ,x_last_update_date      => sysdate
      ,x_last_update_login     => 0
      ,x_attribute_category    => x_attribute_category
      ,x_attribute1	           => x_attribute1
      ,x_attribute2	           => x_attribute2
      ,x_attribute3	           => x_attribute3
      ,x_attribute4	           => x_attribute4
      ,x_attribute5	           => x_attribute5
      ,x_attribute6	           => x_attribute6
      ,x_attribute7	           => x_attribute7
      ,x_attribute8	           => x_attribute8
      ,x_attribute9	           => x_attribute9
      ,x_attribute10	           => x_attribute10
      ,x_attribute11	           => x_attribute11
      ,x_attribute12	           => x_attribute12
      ,x_attribute13	           => x_attribute13
      ,x_attribute14	           => x_attribute14
      ,x_attribute15	           => x_attribute15
	 );
  end;

END LOAD_ROW;

END OE_PC_VTMPLTS_PKG;

/
