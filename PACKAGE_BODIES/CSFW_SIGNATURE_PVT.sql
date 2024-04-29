--------------------------------------------------------
--  DDL for Package Body CSFW_SIGNATURE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSFW_SIGNATURE_PVT" as
/* $Header: csfwsigb.pls 115.2 2003/10/29 23:51:46 pgiri noship $ */
/*
--Start of Comments
Package name     : CSFW_SIGNATURE_PVT
Purpose          : to upload signature associated with Debrief
History          :
NOTE             : Please see the function details for additional information

UPDATE NOTES
| Date          Developer           Change
|------         ---------------     --------------------------------------
08-06-2003	MMERCHAN	 Created


--End of Comments
*/


/*
Procedure to insert signature, name and date to Server
p_description is composed of --l_signed_date||' '||l_signed_by,
*/

PROCEDURE UPLOAD_SIGNATURE
		(p_debrief_header_id	NUMBER,
		 p_task_assignment_id NUMBER,
		 p_description VARCHAR2,
		 p_file_data BLOB,
		 p_error_msg     OUT NOCOPY    VARCHAR2,
           	 x_return_status IN OUT NOCOPY VARCHAR2
		) IS

 l_seq_num number;
 l_category_id number;
 l_msg_count NUMBER;
 l_msg_data  VARCHAR2(240);
 l_fnd_lobs_id number;
 l_language VARCHAR2(4);
 l_error_msg varchar(1024);

 l_signature_loc blob;
 l_signature_raw raw(32767);
 l_signature_size number;
 l_dummy NUMBER;

-- get max document sequence number for debrief header
CURSOR l_max_seq_no_cursor(x_debrief_header_id IN number)
  IS
  SELECT  nvl(max(fad.seq_num),0)+10
    FROM  fnd_attached_documents fad,
          fnd_documents fd
   WHERE  fad.pk1_value = to_char(x_debrief_header_id)
   AND    fd.document_id = fad.document_id
   AND EXISTS
         (SELECT 1
          FROM fnd_document_categories_tl cat_tl
          WHERE cat_tl.category_id = fd.category_id
          AND cat_tl.user_name = 'Signature'
          );

 -- get the category_id
  CURSOR l_category_id_cursor
  IS
  SELECT category_id
  FROM  fnd_document_categories_tl
  WHERE user_name = 'Signature';

 --  get next sequence value for FND_LOBS
  CURSOR l_fnd_lobs_s_cursor
  IS
  select fnd_lobs_s.nextval
  from dual;

 -- get language of user
  CURSOR l_language_cursor
  IS
  select userenv('LANG')
  from dual;

--to check if the record exists in the database
 cursor l_lobs_fileid_csr (p_file_id fnd_lobs.file_id%TYPE) is
 select 1
 from fnd_lobs
 where file_id = p_file_id;

RECORD_NOT_INSERTED EXCEPTION;
DEBRIEF_ATTACH_FAILED EXCEPTION;

BEGIN

 x_return_status := FND_API.G_RET_STS_SUCCESS;

 -- get the max seq no
  open l_max_seq_no_cursor(p_debrief_header_id);
  FETCH l_max_seq_no_cursor INTO l_seq_num;
  CLOSE l_max_seq_no_cursor;

  -- get the category id for Signature
  OPEN l_category_id_cursor;
  FETCH l_category_id_cursor INTO l_category_id;
  CLOSE l_category_id_cursor;

  -- get language of session
  OPEN l_language_cursor;
  FETCH l_language_cursor INTO l_language;
  CLOSE l_language_cursor;

  -- enter data into fnd_lobs
  BEGIN
      OPEN l_fnd_lobs_s_cursor;
      FETCH l_fnd_lobs_s_cursor INTO l_fnd_lobs_id;
      CLOSE l_fnd_lobs_s_cursor;

      INSERT INTO fnd_lobs(file_id, file_name, file_content_type,  file_data, upload_date, language, file_format)
      VALUES (l_fnd_lobs_id, 'INTERNAL', 'image/bmp', empty_blob(), SYSDATE, l_language, 'binary')
      RETURN file_data into l_signature_loc;

      l_signature_size := dbms_lob.getLength(p_file_data);
      dbms_lob.read(p_file_data, l_signature_size, 1, l_signature_raw);

      dbms_lob.write(l_signature_loc, l_signature_size, 1, l_signature_raw);

    EXCEPTION
      WHEN OTHERS THEN
      -- check if the record exists
        open l_lobs_fileid_csr(l_fnd_lobs_id) ;
	    fetch l_lobs_fileid_csr into l_dummy;
	    if l_lobs_fileid_csr%found then
	       --the record exists. Dont show any error.
              null;
            else
          --record could not be inserted, throw the exception
	          raise RECORD_NOT_INSERTED;
        end if;
	    close l_lobs_fileid_csr;

    END;


  -- Add attachement to Debrief
  BEGIN
  fnd_webattch.add_attachment(
    seq_num 			=> l_seq_num,
    category_id 		=> l_category_id,
    document_description=> p_description,  --l_signed_date||' '||l_signed_by,
    datatype_id 		=> 6,
    text			    => NULL,
    file_name 		    => 'INTERNAL',
    url                 => NULL,
    function_name 		=> 'CSFFEDBF',
    entity_name 		=> 'CSF_DEBRIEF_HEADERS',
    pk1_value 		    => p_debrief_header_id,
   	pk2_value		    => NULL,
   	pk3_value		    => NULL,
   	pk4_value		    => NULL,
   	pk5_value		    => NULL,
    media_id 			=> l_fnd_lobs_id,
    user_id 			=> fnd_global.login_id);
   EXCEPTION
	WHEN OTHERS THEN
		raise DEBRIEF_ATTACH_FAILED;
   END;

EXCEPTION

WHEN RECORD_NOT_INSERTED THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
	  p_error_msg := 'Record not inserted';

WHEN DEBRIEF_ATTACH_FAILED THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
	  p_error_msg := 'Attachment of BLOB:' || l_fnd_lobs_id || ' to Debrief Header Id:'|| p_debrief_header_id || ' failed';

WHEN OTHERS THEN

  p_error_msg :=  SQLERRM;
  x_return_status := FND_API.G_RET_STS_ERROR;

END UPLOAD_SIGNATURE;

END CSFW_SIGNATURE_PVT;

/
