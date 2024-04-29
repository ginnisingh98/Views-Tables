--------------------------------------------------------
--  DDL for Package Body OE_PC_RSETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_PC_RSETS_PKG" AS
/* $Header: OEXPCRDB.pls 120.1 2005/07/14 06:12:29 appldev ship $ */


   PROCEDURE Insert_Row(
      x_rowid    				in out NOCOPY /* file.sql.39 change */  varchar2
      ,x_record_set_id 			in out NOCOPY /* file.sql.39 change */  number
      ,x_entity_id                  in      number
      ,x_record_set_short_name 	in      varchar2
      ,x_pk_record_set_flag       	in      varchar2
      ,x_record_set_display_name	in      varchar2
      ,x_record_set_description	in      varchar2
      ,x_system_flag	        	in      varchar2
      ,x_created_by       	 	in      number
      ,x_creation_date       		in      date
      ,x_last_updated_by 	    	in      number
      ,x_last_update_date        	in      date
      ,x_last_update_login       	in      number
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
      CURSOR CROWID IS SELECT rowid FROM oe_pc_rsets
                       WHERE record_set_id = x_record_set_id;

      CURSOR CID IS SELECT oe_pc_rsets_s.nextval
                    FROM sys.dual;
   Begin

   IF x_record_set_id IS NULL THEN
      Open CID;
      Fetch CID into x_record_set_id;
      if (CID%NOTFOUND) then
         CLOSE CID;
         RAISE NO_DATA_FOUND;
      end if;
      Close CID;
  END IF;

      INSERT INTO oe_pc_rsets (
         record_set_id
         ,entity_id
         ,record_set_short_name
         ,pk_record_set_flag
         ,system_flag
         ,created_by
         ,creation_date
         ,last_updated_by
         ,last_update_date
         ,last_update_login
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
         x_record_set_id
         ,x_entity_id
         ,x_record_set_short_name
         ,x_pk_record_set_flag
         ,x_system_flag
         ,x_created_by
         ,x_creation_date
         ,x_last_updated_by
         ,x_last_update_date
         ,x_last_update_login
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


      INSERT INTO oe_pc_rsets_tl (
         record_set_id
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
         x_record_set_id
         ,l.language_code
         ,USERENV('LANG')
         ,x_created_by
         ,x_creation_date
         ,x_last_updated_by
         ,x_last_update_date
         ,x_record_set_display_name
         ,x_record_set_description
         ,x_last_update_login
      FROM fnd_languages l
      WHERE l.installed_flag in ('I', 'B')
      AND   not exists (
                        SELECT  null
                        FROM oe_pc_rsets_tl t
                        WHERE t.record_set_id = x_record_set_id
                        AND   t.language      = l.language_code);

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
      ,x_record_set_id 			in      number
      ,x_entity_id                  in      number
      ,x_record_set_short_name 	in      varchar2
      ,x_pk_record_set_flag       	in      varchar2
      ,x_record_set_display_name	in      varchar2
      ,x_record_set_description	in      varchar2
      ,x_system_flag	        	in      varchar2
      ,x_created_by       	 	in      number
      ,x_creation_date       		in      date
      ,x_last_updated_by 	    	in      number
      ,x_last_update_date        	in      date
      ,x_last_update_login       	in      number
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
         FROM oe_pc_rsets
         WHERE rowid = x_rowid
         FOR UPDATE OF record_set_id NOWAIT;

      Recinfo C%ROWTYPE;

      CURSOR C1 IS
         SELECT *
         FROM oe_pc_rsets_tl t
         WHERE record_set_id = x_record_set_id
         AND   language = userenv('LANG')
         FOR UPDATE OF record_set_id NOWAIT;

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
               (Recinfo.record_set_id       = x_record_set_id)
           AND (Recinfo.entity_id    	  = x_entity_id)
           AND (rtrim(Recinfo.record_set_short_name) = x_record_set_short_name)
           AND (Recinfo.pk_record_set_flag = x_pk_record_set_flag)
           AND (Recinfo.system_flag        = x_system_flag)
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

      Open C1;
      Fetch C1 into tlinfo;
      if (C1%NOTFOUND) then
         Close C1;
         FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
         APP_EXCEPTION.Raise_Exception;
      end if;
      Close C1;

      if (
           (rtrim(tlinfo.display_name)     = x_record_set_display_name)
           AND (tlinfo.last_updated_by    = x_last_updated_by)
           AND (tlinfo.last_update_date   = x_last_update_date)
           AND (    (rtrim(tlinfo.description) = x_record_set_description)
                 OR (    (tlinfo.description IS NULL)
                      AND(x_record_set_description IS NULL)))
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
      ,x_record_set_id 			in      number
      ,x_entity_id                  in      number
      ,x_record_set_short_name 	in      varchar2
      ,x_pk_record_set_flag       	in      varchar2
      ,x_record_set_display_name	in      varchar2
      ,x_record_set_description	in      varchar2
      ,x_system_flag	        	in      varchar2
      ,x_created_by       	 	in      number
      ,x_creation_date       		in      date
      ,x_last_updated_by 	    	in      number
      ,x_last_update_date        	in      date
      ,x_last_update_login       	in      number
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

      UPDATE oe_pc_rsets
      SET
         record_set_id 		 = x_record_set_id
         ,entity_id 		 = x_entity_id
         ,record_set_short_name = x_record_set_short_name
         ,pk_record_set_flag    = x_pk_record_set_flag
         ,system_flag          = x_system_flag
         ,created_by   		 = x_created_by
         ,creation_date		 = x_creation_date
         ,last_updated_by    	 = x_last_updated_by
         ,last_update_date     = x_last_update_date
         ,last_update_login     = x_last_update_login
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
      WHERE record_set_id = x_record_set_id;
      if (SQL%NOTFOUND) then
         RAISE NO_DATA_FOUND;
      end if;


      UPDATE oe_pc_rsets_tl
      SET
         source_lang		 = USERENV('LANG')
         ,last_updated_by    	 = x_last_updated_by
         ,last_update_date     = x_last_update_date
         ,last_update_login    = x_last_update_login
         ,display_name         = x_record_set_display_name
         ,description          = x_record_set_description
      WHERE record_set_id = x_record_set_id
      AND   USERENV('LANG') in (language, source_lang);

      if (SQL%NOTFOUND) then
         RAISE NO_DATA_FOUND;
      end if;
   End Update_Row;
   -------------------------------------------------

   PROCEDURE Delete_Row(
      x_record_set_id	in      number
   )
   Is
   Begin


      -- delete constraint rules if any
      DELETE FROM OE_PC_RSET_SEL_COLS
      WHERE  record_set_id = x_record_set_id;

      -- delete all the validation pkgs from oe_pc_validation_pkgs table
      DELETE FROM OE_PC_VALIDATION_PKGS
      WHERE  record_set_id = x_record_set_id;

      -- delete the tl table
      DELETE FROM OE_PC_RSETS_TL
      WHERE  record_set_id = x_record_set_id;

      DELETE FROM OE_PC_RSETS
      WHERE  record_set_id = x_record_set_id;

      if (SQL%NOTFOUND) then
         RAISE NO_DATA_FOUND;
      end if;

   End Delete_Row;
   -------------------------------------------------------------------
   PROCEDURE Add_Language
   IS
   Begin
     DELETE FROM oe_pc_rsets_tl t
     WHERE NOT EXISTS
              (SELECT null
               FROM oe_pc_rsets b
               where record_set_id = t.record_set_id);

     UPDATE oe_pc_rsets_tl t
     SET
     (
       display_name,
       description
     ) = (
          SELECT
            b.display_name,
            b.description
          FROM oe_pc_rsets_tl b
          WHERE b.record_set_id = t.record_set_id
          AND   b.language      = t.source_lang
         )
     where
     (
       t.record_set_id,
       t.language
     ) IN (
           SELECT
              subt.record_set_id,
              subt.language
           FROM oe_pc_rsets_tl subb, oe_pc_rsets_tl subt
           WHERE subb.record_set_id = subt.record_set_id
           AND   subb.language      = subt.source_lang
           AND(subb.display_name <> subt.display_name
               OR subb.DESCRIPTION <> subt.description
               OR (subb.description IS null AND subt.description IS NOT null)
               OR (subb.description IS NOT null AND subt.description IS null)
              )
          );

     INSERT INTO oe_pc_rsets_tl
     (
         record_set_id
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
         b.record_set_id
         ,l.language_code
         ,b.source_lang    -- bug 2329327
         ,b.created_by
         ,b.creation_date
         ,b.last_updated_by
         ,b.last_update_date
         ,b.display_name
         ,b.description
         ,b.last_update_login
     FROM oe_pc_rsets_tl b, fnd_languages l
     WHERE l.installed_flag IN ('I', 'B')
     AND   b.language = USERENV('LANG')
     AND   NOT EXISTS
              ( SELECT null
                FROM oe_pc_rsets_tl t
                WHERE t.record_set_id = b.record_set_id
                AND   t.language      = l.language_code);
   End Add_Language;
   -------------------------------------------------------------------
   PROCEDURE Check_References(
      x_record_set_id 			in      number
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
             WHERE record_set_id = x_record_set_id);
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
        fnd_message.set_name('ONT', 'OE_PC_RS_REF_EXISTS');
        app_exception.raise_exception;
   End Check_References;

   -----------------------------------------------------------------------
   PROCEDURE Check_Unique(
      x_rowid				in 	  varchar2
      ,x_entity_id			in      number
      ,x_record_set_display_name	in      varchar2
      ,x_record_set_short_name	in      varchar2
      ,x_pk_record_set_flag		in      varchar2
      ,x_validation_unit		in      varchar2
   )
   Is
       dummy   number;
       chk_display_name  boolean := FALSE;
       chk_short_name    boolean := FALSE;
       chk_pk_flag	 boolean := FALSE;
   Begin
      if (x_validation_unit = 'ALL') then
         chk_display_name  := TRUE;
         chk_short_name    := TRUE;
         chk_pk_flag	   := TRUE;
      elsif (x_validation_unit = 'RECORD_SET_DISPLAY_NAME') then
         chk_display_name  := TRUE;
      elsif (x_validation_unit = 'RECORD_SET_SHORT_NAME') then
         chk_short_name  := TRUE;
      elsif (x_validation_unit = 'PK_RECORD_SET_FLAG') then
         chk_pk_flag	  := TRUE;
      end if;

      if (chk_display_name = TRUE) then
          -- record set short name should be unique within an entity
          SELECT count(1)
          INTO   dummy
          FROM   oe_pc_rsets_vl
          WHERE  entity_id = x_entity_id
          AND    record_set_display_name = x_record_set_display_name
          AND    ((x_rowid IS null) OR (row_id <> x_rowid));

          if (dummy >= 1) then
             fnd_message.set_name('ONT', 'OE_PC_RS_DUP_DISPLAY_NAME');
             app_exception.raise_exception;
          end if;
      end if;

      if (chk_short_name = TRUE) then
          -- record set short name should be unique within an entity
          SELECT count(1)
          INTO   dummy
          FROM   oe_pc_rsets
          WHERE  entity_id = x_entity_id
          AND    record_set_short_name = x_record_set_short_name
          AND    ((x_rowid IS null) OR (rowid <> x_rowid));

          if (dummy >= 1) then
             fnd_message.set_name('ONT', 'OE_PC_RS_DUP_SHORT_NAME');
             app_exception.raise_exception;
          end if;
      end if;
      if (chk_pk_flag = TRUE) then
          -- there can be only one record set with  pk_record_set_flag = Y
          SELECT count(1)
          INTO   dummy
          FROM   oe_pc_rsets
          WHERE  entity_id = x_entity_id
          AND    pk_record_set_flag = 'Y'
          AND    x_pk_record_set_flag = 'Y'
          AND    ((x_rowid IS null) OR (rowid <> x_rowid));

          if (dummy >= 1) then
             fnd_message.set_name('ONT', 'OE_PC_PK_RS_EXISTS');
             app_exception.raise_exception;
          end if;
      end if;

   End Check_Unique;
   ------------------------------------------------------------------------

   PROCEDURE Translate_Row(
      x_record_set_id 			in	   varchar2
	 ,x_owner					in 	   varchar2
      ,x_record_set_display_name	in      varchar2
      ,x_record_set_description	in      varchar2
	 )
   IS
      l_user_id number :=0;
   BEGIN
      l_user_id := fnd_load_util.owner_id(x_owner); --Seed data changes
      UPDATE oe_pc_rsets_tl
      SET
         source_lang		 = USERENV('LANG')
         --,last_updated_by    	 = decode(x_OWNER, 'SEED', 1, 0)
	 ,last_updated_by    	 = l_user_id
         ,last_update_date     = sysdate
         ,last_update_login    = 0
         ,display_name         = x_record_set_display_name
         ,description          = x_record_set_description
      WHERE record_set_id = x_record_set_id
      AND   USERENV('LANG') in (language, source_lang);

   END Translate_Row;

   PROCEDURE Load_Row(
       x_record_set_id 			in      varchar2
      ,x_owner					in      varchar2
      ,x_record_set_display_name	in      varchar2
      ,x_record_set_description	in      varchar2
      ,x_entity_id                  in     varchar2
      ,x_record_set_short_name 	in      varchar2
      ,x_pk_record_set_flag       	in      varchar2
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
   )
   IS
   BEGIN

    declare
	user_id	number := 0;
	row_id	varchar2(64);
	l_record_set_id		number;
        l_db_user_id	number := 0;
	l_valid_release boolean :=false;
    begin

     if (X_OWNER = 'SEED') then
		  user_id := 1;
     end if;
    --seed data changes start
      user_id :=fnd_load_util.owner_id(x_owner);
      begin
         select last_updated_by
	   into l_db_user_id
   	   from oe_pc_rsets
   	   WHERE record_set_id = x_record_set_id;
      exception
        when no_data_found then
	   null;
      end;
       if (l_db_user_id <= user_id)
           or (l_db_user_id in (0,1,2)
              and user_id in (0,1,2))      then
	      l_valid_release:=true;
       end if;
       if l_valid_release then
    --seed data changes end
       OE_PC_Rsets_pkg.UPDATE_ROW(
	 x_rowid				 => row_id
      ,x_record_set_id 		 => x_record_set_id
      ,x_record_set_display_name		 => x_record_set_display_name
      ,x_record_set_description		 => x_record_set_description
	 ,x_entity_id				      => x_entity_id
      ,x_record_set_short_name		 => x_record_set_short_name
	 ,x_pk_record_set_flag	 => x_pk_record_set_flag
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

	l_record_set_id := x_record_set_id;

	 oe_pc_rsets_pkg.INSERT_ROW(
	 x_rowid				 => row_id
      ,x_record_set_id 		 => l_record_set_id
      ,x_record_set_display_name		 => x_record_set_display_name
      ,x_record_set_description		 => x_record_set_description
	 ,x_entity_id				      => x_entity_id
      ,x_record_set_short_name		 => x_record_set_short_name
	 ,x_pk_record_set_flag	 => x_pk_record_set_flag
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

END OE_PC_RSETS_PKG;

/
