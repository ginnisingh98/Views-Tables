--------------------------------------------------------
--  DDL for Package Body AMS_ATCH_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_ATCH_UPGRADE" AS
/* $Header: amsvatub.pls 115.6 2002/12/05 01:04:08 rmajumda noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_ATCH_UPGRADE
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_ATCH_UPGRADE';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvatub.pls';


-- Hint: Primary key needs to be returned.
PROCEDURE Create_LOB_From_BFILE(
                                 p_file_name IN Varchar2,
				 p_dir_name  IN Varchar2,
				 x_file_id   OUT NOCOPY  Number
                              )

 IS
   l_src_opened boolean := false;
   l_dest_opened boolean := false;

   Dest_Loc BLOB;
   Src_Loc  BFILE ;
   amount   integer  := 50;

   l_lob_id  number;

   cursor c_get_next_lob_id is
      select fnd_lobs_s.nextval
      from dual;


BEGIN
         Src_Loc  := BFILENAME(p_dir_name,p_file_name);

	 --open the BFile
	 DBMS_LOB.OPEN(Src_Loc,DBMS_LOB.LOB_READONLY);
	 l_src_opened := true;

         OPEN c_get_next_lob_id;
         FETCH c_get_next_lob_id INTO l_LOB_ID;
         CLOSE c_get_next_lob_id;

	 x_file_id := l_lob_id;

	 --insert an empty lob into fnd_lobs
	 insert
	 into
	 fnd_lobs
	 (file_id,
	 file_name,
	 file_content_type,
	 file_data,
	 upload_date,
	 file_format,
	 program_name
	 )
	 values
	 (
	 l_LOB_ID,
	 p_file_name,
	 'image/html',
	 empty_blob(),
	 sysdate,
	 'image',
	 'AMS_CONTENT'
	 )
	 returning file_data into Dest_Loc;


	 --Now, open the lob
	 DBMS_LOB.OPEN(Dest_Loc,DBMS_LOB.LOB_READWRITE);

	 l_dest_opened := true;

	 --Now, load the lob from BFILE
	 DBMS_LOB.LOADFROMFILE(Dest_Loc,Src_Loc,Amount);

	 DBMS_LOB.CLOSE(DEST_LOC);
	 DBMS_LOB.CLOSE(Src_Loc);

EXCEPTION
    when others then
        if (l_dest_opened) then
	   DBMS_LOB.CLOSE(DEST_LOC);
        end if;
        if (l_src_opened) then
	   DBMS_LOB.CLOSE(Src_Loc);
        end if;
	raise;

END;

END;

/
