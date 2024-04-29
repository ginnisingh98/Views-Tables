--------------------------------------------------------
--  DDL for Package Body CSFW_ATTACHMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSFW_ATTACHMENT_PVT" AS
/* $Header: csfwattachb.pls 120.0.12010000.2 2010/05/25 10:03:55 shadas noship $ */

/*
Procedure to upload attachment to Server
*/
PROCEDURE UPLOAD_ATTACHMENT
		(p_incident_id	NUMBER,
		 p_incident_number NUMBER,
		 p_datatype_id NUMBER,
		 p_title VARCHAR2,
		 p_description VARCHAR2,
		 p_category_user_name VARCHAR2,
		 p_file_name VARCHAR2,
		 p_file_content_type VARCHAR2,
		 p_text VARCHAR2,
		 p_url VARCHAR2,
		 p_file_data BLOB,
		 p_error_msg     OUT NOCOPY    VARCHAR2,
         x_return_status IN OUT NOCOPY VARCHAR2
		) IS

 l_seq_num number;
 l_category_id number;
 l_msg_count NUMBER;
 l_msg_data  VARCHAR2(240);
 l_fnd_lobs_id number;
 l_fnd_text_id number;
 l_language VARCHAR2(4);
 l_error_msg varchar(1024);

 l_attachment_text VARCHAR2(32767);
 l_attachment_loc blob;
 l_attachment_raw raw(32767);
 l_attachment_size number;
 l_dummy NUMBER;

-- get max document sequence number for the incident id
CURSOR l_max_seq_no_cursor(x_incident_id IN number)
  IS
  SELECT  nvl(max(fad.seq_num),0)+10
    FROM  fnd_attached_documents fad,
          fnd_documents fd
   WHERE  fad.pk1_value = to_char(x_incident_id)
   AND    fd.document_id = fad.document_id
   AND EXISTS
         (SELECT 1
          FROM fnd_document_categories_tl cat_tl
          WHERE cat_tl.category_id = fd.category_id
          --AND cat_tl.user_name = p_category_user_name
          );

 -- get the category_id
  CURSOR l_category_id_cursor
  IS
  SELECT category_id
  FROM  fnd_document_categories_tl
  WHERE user_name = p_category_user_name;

 --  get next sequence value for FND_LOBS
  CURSOR l_fnd_lobs_s_cursor
  IS
  select fnd_lobs_s.nextval
  from dual;

  -- get next sequence value for fnd_documents_short_text
  CURSOR fnd_short_text_s_cursor
  is
  select fnd_documents_short_text_s.nextval
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
ATTACH_FAILED EXCEPTION;

BEGIN

 x_return_status := FND_API.G_RET_STS_SUCCESS;

 -- get the max seq no
  open l_max_seq_no_cursor(p_incident_id);
  FETCH l_max_seq_no_cursor INTO l_seq_num;
  CLOSE l_max_seq_no_cursor;

  -- get the category id for given Category name
  OPEN l_category_id_cursor;
  FETCH l_category_id_cursor INTO l_category_id;
  CLOSE l_category_id_cursor;

  -- get language of session
  OPEN l_language_cursor;
  FETCH l_language_cursor INTO l_language;
  CLOSE l_language_cursor;


  IF (p_datatype_id = 6) THEN
    BEGIN
      -- enter data into fnd_lobs
      OPEN l_fnd_lobs_s_cursor;
      FETCH l_fnd_lobs_s_cursor INTO l_fnd_lobs_id;
      CLOSE l_fnd_lobs_s_cursor;

      INSERT INTO fnd_lobs(file_id, file_name, file_content_type,  file_data, upload_date, language, file_format)
      VALUES (l_fnd_lobs_id, p_file_name, p_file_content_type, empty_blob(), SYSDATE, l_language, 'binary')
      RETURN file_data into l_attachment_loc;

        l_attachment_size := dbms_lob.getLength(p_file_data);
      dbms_lob.read(p_file_data, l_attachment_size, 1, l_attachment_raw);

      dbms_lob.write(l_attachment_loc, l_attachment_size, 1, l_attachment_raw);

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
  ELSIF (p_datatype_id = 1) THEN
    -- Enter data into fnd_documents_short_text
    BEGIN
      OPEN fnd_short_text_s_cursor;
      FETCH fnd_short_text_s_cursor INTO l_fnd_text_id;
      CLOSE fnd_short_text_s_cursor;

      INSERT INTO fnd_documents_short_text(media_id, short_text)
      VALUES (l_fnd_text_id, p_text)
      RETURN short_text into l_attachment_text;

    END;
--  ELSIF (p_datatype_id = 5) THEN
--    BEGIN
--    END;
  END IF;

  -- Add attachement to Service Request
  BEGIN
  fnd_webattch.add_attachment(
    seq_num 			    => l_seq_num,
    category_id 		    => l_category_id,
    document_description    => p_description,
    datatype_id             => p_datatype_id,
    text                    => p_text,
    file_name               => p_file_name,
    url                     => p_url,
    function_name           => 'CSXSRISR',         -- CSXSRISR - Create Service Request Form Name, i.e., form function name
    entity_name             => 'CS_INCIDENTS',
    pk1_value               => p_incident_id,
   	pk2_value               => NULL,
   	pk3_value               => NULL,
   	pk4_value               => NULL,
   	pk5_value               => NULL,
    media_id                => l_fnd_lobs_id,
    user_id                 => fnd_global.login_id,
	title                   => p_title);
   EXCEPTION
	WHEN OTHERS THEN
		raise ATTACH_FAILED;
   END;

EXCEPTION

WHEN RECORD_NOT_INSERTED THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
	  p_error_msg := 'Record not inserted';

WHEN ATTACH_FAILED THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
	  p_error_msg := 'Attachment of BLOB:' || l_fnd_lobs_id || ' to Service Request Number:'|| p_incident_number || ' failed';

WHEN OTHERS THEN

  p_error_msg :=  SQLERRM;
  x_return_status := FND_API.G_RET_STS_ERROR;

END UPLOAD_ATTACHMENT;

END CSFW_ATTACHMENT_PVT;


/
