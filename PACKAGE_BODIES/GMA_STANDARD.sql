--------------------------------------------------------
--  DDL for Package Body GMA_STANDARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMA_STANDARD" AS
/* $Header: GMASTNDB.pls 120.2 2005/12/15 11:10:25 txdaniel noship $ */

counter pls_integer;
v_eventQuery EDR_STANDARD.eventQuery;
v_ameRuleinputvalues EDR_STANDARD.ameRuleinputvalues;

G_PKG_NAME CONSTANT VARCHAR2(30) := 'EDR_FILES_PUB';

PROCEDURE PSIG_STATUS
	(
	p_event 	in	varchar2,
	p_event_key	in    varchar2,
        P_status        out NOCOPY   varchar2
	) IS
BEGIN
      edr_standard.psig_status(p_event, p_event_key, p_status);
END PSIG_STATUS;

/* signature Requirement. This Procedure returns signature requireemnt for a given event.
   The status is 'Yes' */
PROCEDURE PSIG_REQUIRED
	(
	 p_event 	 in	varchar2,
	 p_event_key in   varchar2,
       P_status    out  NOCOPY boolean
	) is
BEGIN
      edr_standard.psig_required(p_event, p_event_key, p_status);
END PSIG_REQUIRED;

/* eRecord Requirement. This Procedure returns signature requirement for a given event.
   The status is 'true' or 'false' */
PROCEDURE EREC_REQUIRED
	(
	p_event 	 in	varchar2,
	p_event_key	 in   varchar2,
      P_status     out NOCOPY  boolean
	) is
BEGIN
      edr_standard.erec_required(p_event, p_event_key, p_status);
END EREC_REQUIRED;

FUNCTION PSIG_QUERY(p_eventQuery GMA_STANDARD.eventQuery) return number IS PRAGMA AUTONOMOUS_TRANSACTION;
i number;
begin
      v_eventQuery.DELETE; -- Added for bug 4874228
      for counter IN 1..p_eventQuery.COUNT loop
         v_eventQuery(counter).event_name := p_eventQuery(counter).event_name;
         v_eventQuery(counter).event_key := p_eventQuery(counter).event_key;
         v_eventQuery(counter).key_type := p_eventQuery(counter).key_type;
      end loop;
      i := edr_standard.psig_query(v_eventQuery);
      return i;
END PSIG_QUERY;

PROCEDURE GET_AMERULE_INPUT_VALUES( ameapplication IN varchar2,
                          		ameruleid IN NUMBER,
                          		amerulename IN VARCHAR2,
                          		ameruleinputvalues OUT NOCOPY GMA_STANDARD.ameruleinputvalues) is
BEGIN
      for counter IN 1..ameruleinputvalues.COUNT loop
         v_ameRuleinputvalues(counter).input_name := ameruleinputvalues(counter).input_name;
         v_ameRuleinputvalues(counter).input_value := ameruleinputvalues(counter).input_value;
      end loop;

      edr_standard.get_amerule_input_values(ameapplication, ameruleid, amerulename, v_ameRuleinputvalues);

      for counter IN 1..ameruleinputvalues.COUNT loop
         v_ameRuleinputvalues(counter).input_name := ameruleinputvalues(counter).input_name;
         v_ameRuleinputvalues(counter).input_value := ameruleinputvalues(counter).input_value;
      end loop;
END GET_AMERULE_INPUT_VALUES;

PROCEDURE DISPLAY_DATE(P_DATE_IN in DATE , P_DATE_OUT OUT NOCOPY Varchar2) IS
BEGIN
  edr_standard.display_date(p_date_in, p_date_out);
END DISPLAY_DATE;

PROCEDURE UPLOAD_FILE(	p_api_version		IN NUMBER,
			p_commit		IN VARCHAR2,
			p_called_from_forms	IN VARCHAR2,
			p_file_name 		IN VARCHAR2,
			p_category 		IN VARCHAR2,
			p_content_type 		IN VARCHAR2,
			p_version_label		IN VARCHAR2,
			p_file_data	 	IN BLOB,
			p_file_format 		IN VARCHAR2,
			p_source_lang		IN VARCHAR2,
			p_description		IN VARCHAR2,
			p_file_exists_action	IN VARCHAR2,
			p_submit_for_approval	IN VARCHAR2,
			p_attribute1 		IN VARCHAR2,
			p_attribute2 		IN VARCHAR2,
			p_attribute3 		IN VARCHAR2,
			p_attribute4 		IN VARCHAR2,
			p_attribute5 		IN VARCHAR2,
			p_attribute6 		IN VARCHAR2,
			p_attribute7 		IN VARCHAR2,
			p_attribute8 		IN VARCHAR2,
			p_attribute9 		IN VARCHAR2,
			p_attribute10 		IN VARCHAR2,
			p_created_by 		IN NUMBER,
			p_creation_date 	IN DATE,
			p_last_updated_by 	IN NUMBER,
			p_last_update_login 	IN NUMBER,
			p_last_update_date 	IN DATE,
			x_return_status 	OUT NOCOPY VARCHAR2,
			x_msg_data		OUT NOCOPY VARCHAR2)
AS

/*	Alpha Variables */
L_API_NAME 		CONSTANT VARCHAR2(30) := 'UPLOAD_FILE';
L_FILE_NAME		VARCHAR2(2000);
L_EXTENSION		VARCHAR2(2000);
L_RETURN_STATUS 	VARCHAR2(1);
L_CONCAT_SEGS		VARCHAR2(200);
L_STATUS		VARCHAR2(30);
L_EVENT_USER_KEY 	VARCHAR2(2000);
L_USER			VARCHAR2(240);
L_MSG_DATA		VARCHAR2(200);
L_FILE_DATA		BLOB;

L_SEG_ARRAY		FND_FLEX_EXT.SEGMENTARRAY;

/* 	Numeric Variables */
L_COUNT			NUMBER;
L_ORACLE_ERROR		NUMBER;
L_API_VERSION		CONSTANT NUMBER := 1.0;
L_VERSION		NUMBER;
L_POS			NUMBER;
L_RESP_ID		NUMBER;
L_RESP_APPL_ID		NUMBER;
L_ROW_ID	        VARCHAR2(240);
L_FILE_ID		NUMBER;
L_CATEGORY_ID		NUMBER;
L_FND_DOCUMENT_ID	NUMBER;
L_ATTACHED_DOCUMENT_ID 	NUMBER;
X_DOCUMENT_ID   	NUMBER;
L_MEDIA_ID      	NUMBER;

I 			INTEGER;

/*	Exceptions */
EDR_FILES_FILE_NAME_NULL EXCEPTION;
EDR_FILES_CATEGORY_NULL	 EXCEPTION;
EDR_FILES_FILE_NULL	 EXCEPTION;
EDR_FILES_FORMAT_NULL	 EXCEPTION;
EDR_FILES_SRC_LANG_NULL  EXCEPTION;
EDR_FILES_EXIST_ACT_NULL EXCEPTION;
EDR_FILES_ERES_ERROR	 EXCEPTION;
EDR_FILES_INSERT_ERROR	 EXCEPTION;
EDR_FILES_INV_FLEX_VALUE EXCEPTION;
EDR_FILES_ALREADY_EXISTS EXCEPTION;
EDR_FILES_OVERWRITE_ERROR EXCEPTION;
EDR_FILES_APPL_ID_NULL   EXCEPTION;
EDR_FILES_RESP_ID_NULL   EXCEPTION;
EDR_FILES_USER_NULL      EXCEPTION;

/* 	Cursors */
CURSOR c_get_category IS
   SELECT category_id
   FROM  fnd_document_categories
   WHERE name = p_category;
LocalCatRecord c_get_category%ROWTYPE;

CURSOR c_get_exists IS
   SELECT  version_number, status
   FROM    edr_files_b
   WHERE   original_file_name = p_file_name
   AND	   category_id = LocalCatRecord.category_id;
LocalExistsRecord c_get_exists%ROWTYPE;

CURSOR c_get_seq_num IS
   SELECT  edr_files_b_s.nextval
   FROM    dual;
LocalSeqRecord c_get_seq_num%ROWTYPE;

CURSOR c_get_event IS
   SELECT a.file_name, b.name
   FROM   edr_files_b a, fnd_document_categories b
   WHERE  a.category_id = b.category_id
   AND	  a.file_id = l_file_id;
LocalEventRecord c_get_event%ROWTYPE;

 /* Used to get the next attached_document_id  for a new attachment SKARIMIS*/
CURSOR  c_get_id IS
   SELECT fnd_attached_documents_s.nextval
   FROM dual;

/* Used to check if the attribute is required in the flexfield */
CURSOR c_get_flex1 IS
   SELECT count(*)
   FROM  fnd_descr_flex_column_usages
   WHERE application_id = '709'
   AND descriptive_flexfield_name = 'EDR_FILE_ATTRIBUTES'
   AND descriptive_flex_context_code = p_category;
LocalFlex1Record	c_get_flex1%ROWTYPE;

BEGIN
/* Get ids */
   l_resp_appl_id 	:= FND_GLOBAL.RESP_APPL_ID;
   l_resp_id		:= FND_GLOBAL.RESP_ID;
   l_user	 	:= FND_GLOBAL.USER_NAME;

   IF l_resp_appl_id IS NULL THEN
      RAISE EDR_FILES_APPL_ID_NULL;
   END IF;

   IF l_resp_id IS NULL THEN
      RAISE EDR_FILES_RESP_ID_NULL;
   END IF;

   IF l_user IS NULL THEN
      RAISE EDR_FILES_USER_NULL;
   END IF;

/*  Check the API version passed in matches the
**  internal API version.
*/

   IF NOT FND_API.Compatible_API_Call
                                        (g_api_version,
					 p_api_version,
					 l_api_name,
					 g_pkg_name) THEN

      RAISE FND_API.G_Exc_Unexpected_Error;
   END IF;

/* Check for required parameters */
   IF p_file_name IS NULL THEN
      RAISE EDR_FILES_FILE_NAME_NULL;
   END IF;

   IF p_category IS NULL THEN
      RAISE EDR_FILES_CATEGORY_NULL;
   END IF;

   IF p_file_data IS NULL THEN
      RAISE EDR_FILES_FILE_NULL;
   END IF;

   IF p_file_format IS NULL THEN
      RAISE EDR_FILES_FORMAT_NULL;
   END IF;

   IF p_source_lang IS NULL THEN
      RAISE EDR_FILES_SRC_LANG_NULL;
   END IF;

   IF p_file_exists_action IS NULL THEN
      RAISE EDR_FILES_EXIST_ACT_NULL;
   END IF;

/* Default the internal version in case the document does not already exist */
   l_version := 0;

/* The status is always 'N'(Not Approved)*/
   l_status := 'N';

/* Select the category id */
   OPEN c_get_category;
   FETCH c_get_category INTO LocalCatRecord;

   l_category_id := LocalCatRecord.category_id;
   CLOSE c_get_category;

/* Check to see if file already exists */
   OPEN c_get_exists;
   FETCH c_get_exists INTO LocalExistsRecord;

/* File already exists and not be overwritten, return error */
    IF c_get_exists%FOUND THEN
        l_version := LocalExistsRecord.version_number;
   	IF p_file_exists_action = 'D' THEN
   	   RAISE EDR_FILES_ALREADY_EXISTS;
   	END IF;
    END IF;

/* File exists as approved, pending or approval not required, and not to be versioned, return error */
    IF c_get_exists%FOUND THEN
        l_version := LocalExistsRecord.version_number;
   	IF p_file_exists_action = 'O' AND LocalExistsRecord.status in ('A', 'P', 'S') THEN
   	   RAISE EDR_FILES_OVERWRITE_ERROR;
   	END IF;
    END IF;
   CLOSE c_get_exists;

/* Validate flexfield values */
   FND_FLEX_DESCVAL.set_context_value(p_category);

  i := 0;
  IF p_category IS NOT NULL THEN
   i := i +1;
   l_seg_array(i) := p_category;
  END IF;

  OPEN c_get_flex1;
  FETCH c_get_flex1 INTO l_count;
   IF c_get_flex1%FOUND THEN
  	IF l_count >= i THEN
           i := i + 1;
           /* 25 Aug 2003 Bug 3103346   Mercy Thomas Added the following code to validate the descriptive flexfield columns   */
           fnd_flex_descval.set_column_value('ATTRIBUTE1', p_attribute1);
           /* 25 Aug 2003 Bug 3103346   Mercy Thomas End of the code changes */
  	END IF;
  	IF l_count >= i THEN
           i := i + 1;
           /* 25 Aug 2003 Bug 3103346   Mercy Thomas Added the following code to validate the descriptive flexfield columns   */
           fnd_flex_descval.set_column_value('ATTRIBUTE2', p_attribute2);
           /* 25 Aug 2003 Bug 3103346   Mercy Thomas End of the code changes */
        END IF;
  	IF l_count >= i THEN
           i := i + 1;
           /* 25 Aug 2003 Bug 3103346   Mercy Thomas Added the following code to validate the descriptive flexfield columns   */
           fnd_flex_descval.set_column_value('ATTRIBUTE3', p_attribute3);
           /* 25 Aug 2003 Bug 3103346   Mercy Thomas End of the code changes */
  	END IF;
  	IF l_count >= i THEN
           i := i + 1;
           /* 25 Aug 2003 Bug 3103346   Mercy Thomas Added the following code to validate the descriptive flexfield columns   */
           fnd_flex_descval.set_column_value('ATTRIBUTE4', p_attribute4);
           /* 25 Aug 2003 Bug 3103346   Mercy Thomas End of the code changes */
  	END IF;
  	IF l_count >= i THEN
           i := i + 1;
           /* 25 Aug 2003 Bug 3103346   Mercy Thomas Added the following code to validate the descriptive flexfield columns   */
           fnd_flex_descval.set_column_value('ATTRIBUTE5', p_attribute5);
           /* 25 Aug 2003 Bug 3103346   Mercy Thomas End of the code changes */
  	END IF;
  	IF l_count >= i THEN
           i := i + 1;
           /* 25 Aug 2003 Bug 3103346   Mercy Thomas Added the following code to validate the descriptive flexfield columns   */
           fnd_flex_descval.set_column_value('ATTRIBUTE6', p_attribute6);
           /* 25 Aug 2003 Bug 3103346   Mercy Thomas End of the code changes */
  	END IF;
  	IF l_count >= i THEN
           i := i + 1;
           /* 25 Aug 2003 Bug 3103346   Mercy Thomas Added the following code to validate the descriptive flexfield columns   */
           fnd_flex_descval.set_column_value('ATTRIBUTE7', p_attribute7);
           /* 25 Aug 2003 Bug 3103346   Mercy Thomas End of the code changes */
  	END IF;
  	IF l_count >= i THEN
           i := i + 1;
           /* 25 Aug 2003 Bug 3103346   Mercy Thomas Added the following code to validate the descriptive flexfield columns   */
           fnd_flex_descval.set_column_value('ATTRIBUTE8', p_attribute8);
           /* 25 Aug 2003 Bug 3103346   Mercy Thomas End of the code changes */
  	END IF;
  	IF l_count >= i THEN
           i := i + 1;
           /* 25 Aug 2003 Bug 3103346   Mercy Thomas Added the following code to validate the descriptive flexfield columns   */
           fnd_flex_descval.set_column_value('ATTRIBUTE9', p_attribute9);
           /* 25 Aug 2003 Bug 3103346   Mercy Thomas End of the code changes */
  	END IF;
  	IF l_count >= i THEN
           i := i + 1;
           /* 25 Aug 2003 Bug 3103346   Mercy Thomas Added the following code to validate the descriptive flexfield columns   */
           fnd_flex_descval.set_column_value('ATTRIBUTE10', p_attribute10);
           /* 25 Aug 2003 Bug 3103346   Mercy Thomas End of the code changes */
  	END IF;
     END IF;
   CLOSE c_get_flex1;

   /* 25 Aug 2003 Bug 3103346   Mercy Thomas Added the following code to validate the descriptive flexfield  */

   IF NOT (FND_FLEX_DESCVAL.validate_desccols('EDR', 'EDR_FILE_ATTRIBUTES',
                                              'V', SYSDATE)) THEN
      RAISE EDR_FILES_INV_FLEX_VALUE;
   END IF;
   /* 25 Aug 2003 Bug 3103346   Mercy Thomas End of the code changes */


/* Increment internal version number */
   l_version := l_version + 1;

/* Locate beginning of the extension in the file name string to use position to
   split up the file name
*/
   l_extension := NULL;
   l_file_name := p_file_name;
   l_pos := INSTR(p_file_name, '.',-1,1);

   IF l_pos <> 0 THEN
      l_extension := SUBSTR(l_file_name,l_pos,LENGTH(l_file_name));
      l_file_name := SUBSTR(p_file_name,1,l_pos-1);
   END IF;

/* Set up the display name for the attachment */
   l_file_name := l_file_name ||'_v_'||p_version_label||l_extension;

/* Get the next sequence number for file_id */
/* Fixed SKARIMIS */
   SELECT  edr_files_b_s.nextval INTO l_file_id FROM dual;

/* Call private package to insert data into the tables */
--cj the whole idea is that instead of inserting one row in edr_files_b/tl tables
-- we would have to insert a row in:
-- edr_files_b/tl
-- fnd_documents
--fnd_lobs
--fnd_attached_documents (attach the file to a default enity named EDR_FILES_B

--CJ look at the new definition of this package
--it would not have the BLOB col FILE_DATA
--change this call accordingly

   EDR_FILES_PKG.Insert_Row (
 	X_ROWID =>l_row_id,
  	X_FILE_ID =>l_file_id,
  	X_FILE_NAME =>l_file_name,
  	X_ORIGINAL_FILE_NAME =>p_file_name,
  	X_VERSION_LABEL =>p_version_label,
  	X_CATEGORY_ID =>l_category_id,
  	X_CONTENT_TYPE =>p_content_type,
  	X_FILE_FORMAT =>p_file_format,
  	X_STATUS =>l_status,
  	X_VERSION_NUMBER =>l_version,
  	X_FND_DOCUMENT_ID => NULL,
  	X_ATTRIBUTE_CATEGORY =>p_category,
  	X_ATTRIBUTE1=>p_attribute1,
  	X_ATTRIBUTE2=>p_attribute2,
  	X_ATTRIBUTE3=>p_attribute3,
  	X_ATTRIBUTE4=>p_attribute4,
  	X_ATTRIBUTE5 =>p_attribute5,
  	X_ATTRIBUTE6=>p_attribute6,
  	X_ATTRIBUTE7=>p_attribute7,
  	X_ATTRIBUTE8=>p_attribute8,
  	X_ATTRIBUTE9=>p_attribute9,
  	X_ATTRIBUTE10=>p_attribute10,
  	X_ATTRIBUTE11=>NULL,
  	X_ATTRIBUTE12=>NULL,
  	X_ATTRIBUTE13=>NULL,
  	X_ATTRIBUTE14=>NULL,
  	X_ATTRIBUTE15=>NULL,
  	X_DESCRIPTION =>p_description,
  	X_CREATION_DATE=>p_creation_date,
  	X_CREATED_BY =>p_created_by,
  	X_LAST_UPDATE_DATE=>p_last_update_date,
  	X_LAST_UPDATED_BY=>p_last_updated_by,
  	X_LAST_UPDATE_LOGIN =>p_last_update_login);

--CJ now that the row is inserted in edr_files table
-- we have insert into fn_documents, fnd_attached_documents
-- and fnd_lobs

--CJ to insert in fnd_documents and fnd_attached_dcouments
--use FND_ATTACHED_DOCUMENTS_PKG.Insert_Row
-- i am attaching the java code to help u understand
-- the parameters to be passed

  OPEN c_get_id;
  FETCH c_get_id INTO l_attached_document_id;
  CLOSE c_get_id;

  FND_ATTACHED_DOCUMENTS_PKG.Insert_Row(X_Rowid=>l_row_id,
               X_attached_document_id=>l_attached_document_id,
               X_document_id=>x_document_id,
               X_creation_date=>p_creation_date,
               X_created_by=>p_created_by,
               X_last_update_date=>p_last_update_date,
               X_last_updated_by=>p_last_updated_by,
               X_last_update_login=>p_last_update_login,
               X_seq_num=>1,
               X_entity_name=>'EDR_FILES_B',
               X_column1=>NULL,
               X_pk1_value=>NULL,
               X_pk2_value=>NULL,
               X_pk3_value=>NULL,
               X_pk4_value=>NULL,
               X_pk5_value=>NULL,
               X_automatically_added_flag=>'N',
               X_datatype_id=>6,
               X_category_id=>l_category_id,
               X_security_type=>1,
               X_security_id=>-1,
               X_publish_flag=>'N',
               X_storage_type=>1,
               X_usage_type=>'S',
               X_language=>p_source_lang,
               X_description=>p_description,
               X_file_name=>l_file_name,
               X_media_id=>l_media_id,
               X_doc_attribute_category=>p_category,
               X_doc_attribute1=>p_attribute1,
               X_doc_attribute2=>p_attribute2,
               X_doc_attribute3=>p_attribute3,
               X_doc_attribute4=>p_attribute4,
               X_doc_attribute5=>p_attribute5,
               X_doc_attribute6=>p_attribute6,
               X_doc_attribute7=>p_attribute7,
               X_doc_attribute8=>p_attribute8,
               X_doc_attribute9=>p_attribute9,
               X_doc_attribute10=>p_attribute10,
               X_create_doc=>'N');

-- use a direct INSERT statement to insert
-- into FND_LOBS
-- i am attaching the java code for inserting into this table
--just to show u what the values of the parameters should be
   INSERT into FND_LOBS
   	(file_id,
    	 file_name,
    	 file_data,
    	 file_content_type,
    	 file_format)
    VALUES
    	(l_media_id,
    	 l_file_name,
    	 l_file_data,
    	 p_content_type,
    	 p_file_format);

--CJ now update the row in the edr_files_b table with the fnd_document_id that you get
-- from inserting a row in FND_DOCUMENTS table

	UPDATE 	EDR_FILES_B
	SET	fnd_document_id = x_document_id
	WHERE  	file_id = l_file_id;

/* If sending for approval, raise ERES event */

  IF p_submit_for_approval = 'Y' THEN
        OPEN c_get_event;
        FETCH c_get_event INTO LocalEventRecord;
        l_event_user_key := LocalEventRecord.file_name ||'-'||LocalEventRecord.name;
        CLOSE c_get_event;

	-- cj change this api to edr_raise_event when its available

        wf_event.raise2(p_event_name => 'oracle.apps.edr.file.approve',
        		p_event_key => l_file_id,
                	p_event_data => null,
                	p_parameter_name1 => 'DEFERRED',
                	p_parameter_value1 => 'Y',
                	p_parameter_name2 => 'POST_OPERATION_API',
                	p_parameter_value2 => 'EDR_ATTACHMENTS_GRP.EVENT_POST_OP('||l_file_id||')',
                	p_parameter_name3 => 'PSIG_USER_KEY_LABEL',
                	p_parameter_value3 => 'File Approval:',
                	p_parameter_name4 => 'PSIG_USER_KEY_VALUE',
                	p_parameter_value4 => l_event_user_key,
                	p_parameter_name5 => 'PSIG_TRANSACTION_AUDIT_ID',
                	p_parameter_value5 => '-1',
                	p_parameter_name6 => '#WF_SOURCE_APPLICATION_TYPE',
                	p_parameter_value6 => 'DB',
                	p_parameter_name7 => '#WF_SIGN_REQUESTER',
                	p_parameter_value7 => l_user);


         EDR_STANDARD.PSIG_STATUS
         ( p_event 	=> 'oracle.apps.edr.file.approve'	,
           p_event_key 	=> l_file_id				,
           p_status 	=> l_status
         );

         -- If the status of the erecord in the evidence store is COMPLETE
         -- it means that signature was not required.
         -- if its PENDING means that the offine notification is sent out
         -- to the approver and its waiting approval
         -- in any other case raise an error

	if l_status = 'PENDING' then
         	UPDATE  edr_files_b
         	SET	status = 'P'
         	WHERE	file_id = l_file_id
         	AND 	file_name = LocalEventRecord.file_name;
	elsif l_status = 'COMPLETE' then
         	UPDATE  edr_files_b
         	SET	status = 'S'
         	WHERE	file_id = l_file_id
         	AND 	file_name = LocalEventRecord.file_name;
	else
         	RAISE EDR_FILES_ERES_ERROR;
        	ROLLBACK;
        END IF;

    END IF;

/*IF everything is successful and commit is yes, issue a commit*/
    IF p_commit = 'T' THEN
    	COMMIT;
    END IF;

EXCEPTION
/*
**
*/
   WHEN EDR_FILES_FILE_NAME_NULL THEN
	FND_MESSAGE.SET_NAME('EDR','EDR_FILES_FILE_NAME_NULL');
        FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
	FND_MSG_PUB.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
        x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN EDR_FILES_APPL_ID_NULL THEN
	FND_MESSAGE.SET_NAME('EDR','EDR_FILES_APPL_ID_NULL');
        FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
	FND_MSG_PUB.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
        x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN EDR_FILES_RESP_ID_NULL THEN
	FND_MESSAGE.SET_NAME('EDR','EDR_FILES_RESP_ID_NULL');
        FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
	FND_MSG_PUB.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
        x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN EDR_FILES_USER_NULL THEN
	FND_MESSAGE.SET_NAME('EDR','EDR_FILES_USER_NULL');
        FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
	FND_MSG_PUB.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
        x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN EDR_FILES_CATEGORY_NULL	THEN
  	FND_MESSAGE.SET_NAME('EDR','EDR_FILES_CATEGORY_NULL');
        FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
	FND_MSG_PUB.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
        x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN EDR_FILES_FILE_NULL THEN
   	FND_MESSAGE.SET_NAME('EDR','EDR_FILES_FILE_NULL');
        FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
	FND_MSG_PUB.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN EDR_FILES_FORMAT_NULL THEN
    	FND_MESSAGE.SET_NAME('EDR','EDR_FILES_FORMAT_NULL');
        FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
	FND_MSG_PUB.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN EDR_FILES_SRC_LANG_NULL THEN
        FND_MESSAGE.SET_NAME('EDR','EDR_FILES_SRC_LANG_NULL');
        FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
	FND_MSG_PUB.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN EDR_FILES_EXIST_ACT_NULL THEN
        FND_MESSAGE.SET_NAME('EDR','EDR_FILES_EXISTS_ACT_NULL');
        FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
	FND_MSG_PUB.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
	x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN EDR_FILES_ERES_ERROR THEN
    	FND_MESSAGE.SET_NAME('EDR','EDR_FILES_ERES_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
	FND_MSG_PUB.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN EDR_FILES_INSERT_ERROR THEN
    	FND_MESSAGE.SET_NAME('EDR','EDR_FILES_INSERT_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
	FND_MSG_PUB.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN EDR_FILES_INV_FLEX_VALUE THEN
    	FND_MESSAGE.SET_NAME('EDR','EDR_FILES_INV_FLEX_VALUE');
        FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
	FND_MSG_PUB.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN EDR_FILES_ALREADY_EXISTS THEN
    	FND_MESSAGE.SET_NAME('EDR','EDR_FILES_ALREADY_EXISTS');
        FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
	FND_MSG_PUB.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN EDR_FILES_OVERWRITE_ERROR THEN
    	FND_MESSAGE.SET_NAME('EDR','EDR_FILES_OVERWRITE_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
	FND_MSG_PUB.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
        x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
        l_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        l_msg_data :=  'Error = '||SQLERRM;

END UPLOAD_FILE;

/* Added for Melanie Grosser as a fix for bug# 3280763 */
/*===========================================================================
--  FUNCTION:
--    build_eres_query
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to build an ERES query based upon document
--    attachments for a given entity.  It will return the ID of the query that
--    was built so that the calling program may execute it.
--
--  PARAMETERS:
--    p_entity_name IN  VARCHAR2     - Entity that attachments are associated with
--    p_pk1_value IN  VARCHAR2       - Primary key value 1 ifor entity
--    p_pk2_value IN  VARCHAR2       - Primary key value 2 ifor entity (may be null)
--    p_pk3_value IN  VARCHAR2       - Primary key value 3 ifor entity (may be null)
--    p_pk4_value IN  VARCHAR2       - Primary key value 4 ifor entity (may ne null)
--    p_pk5_value IN  VARCHAR2       - Primary key value 5 ifor entity (may be null)
--    x_error_message OUT VARCHAR2   - If there is an error, send back the approriate message
--    x_return_status OUT VARCHAR2   - 'S'uccess, 'E'rror, 'U'nexpected Error
--
--  SYNOPSIS:
--    l_query_id := GMA_STANDARD.build_eres_query('GR_ITEM_GENERAL',l_item_code,NULL,NULL,NULL,
--                            NULL,NULL,l_err_message,l_return_status);
--    IF (l_query_id > 0 ) THEN
--       GMA_WF_SIGNi.show_trans_query(p_query_id => l_query_id);
--    END IF;
--
--  HISTORY
--    M. Grosser 18-Nov-2003    Created
--    R. Tardio  25-Nov-2003    Added to GMA_STANDARD.
--=========================================================================== */
FUNCTION build_eres_query (p_entity_name IN  VARCHAR2,
                           p_pk1_value IN  VARCHAR2,
                           p_pk2_value IN  VARCHAR2,
                           p_pk3_value IN  VARCHAR2,
                           p_pk4_value IN  VARCHAR2,
                           p_pk5_value IN  VARCHAR2,
                           x_error_message OUT NOCOPY VARCHAR2,
                           x_return_status OUT NOCOPY VARCHAR2
                           )  RETURN NUMBER IS


/*  ------------- LOCAL VARIABLES ------------------- */
l_return_status       VARCHAR2(2) := 'S';
l_oracle_error        NUMBER;
l_query_id            NUMBER;
l_event_key           VARCHAR2(240);
i 	              NUMBER :=1;
x_event_group         GMA_STANDARD.eventQuery;

/*  ------------------ CURSORS ---------------------- */
   CURSOR c_get_event_key IS
	SELECT file_id
	FROM   fnd_attached_documents f, edr_files_b e
	WHERE  entity_name = p_entity_name
	AND    pk1_value = p_pk1_value
	AND    NVL(pk2_value,' ') = NVL(p_pk2_value,' ')
	AND    NVL(pk3_value,' ') = NVL(p_pk3_value,' ')
	AND    NVL(pk4_value,' ') = NVL(p_pk4_value,' ')
	AND    NVL(pk5_value,' ') = NVL(p_pk5_value,' ')
	AND    e.fnd_document_id = f.document_id;

  BEGIN
     -- Use cursor to retrieve file_id based upon document attachments
     OPEN c_get_event_key;
     FETCH c_get_event_key INTO l_event_key;

     -- No attachments or not in file upload system
     IF c_get_event_key%NOTFOUND THEN
        RETURN (0);
     ELSE
        -- Build query group
        WHILE c_get_event_key%FOUND LOOP
           x_event_group(i).event_name := 'oracle.apps.edr.file.approve';
           x_event_group(i).event_key :=  l_event_key;
           i := i + 1;
           FETCH c_get_event_key INTO l_event_key;
        END LOOP;

        -- Retrieve query id
        l_query_id := GMA_STANDARD.PSIG_QUERY(x_event_group);
     END IF;
     CLOSE c_get_event_key;

     RETURN(l_query_id);

  EXCEPTION
    WHEN OTHERS THEN
       x_error_message:= SQLERRM;
       x_return_status := 'U';
       RETURN(-1);

  END build_eres_query;

/*===========================================================================
--  FUNCTION:
--    get_erecord_id
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to get erecord_id for a event/key
--    combination.
--
--  PARAMETERS:
--    p_event_name IN  VARCHAR2       - Name of the event
--    p_event_key  IN  VARCHAR2       - event key
--
--
--  HISTORY
--    Thomas Daniel 19-Jul-2005    Added for the erecord enhancement for GME.
--                                 Details in bug 4328588
--=========================================================================== */
FUNCTION GET_ERECORD_ID
  ( p_event_name IN VARCHAR2
   ,p_event_key  IN VARCHAR2
  ) RETURN NUMBER IS
BEGIN
  RETURN EDR_STANDARD_PUB.GET_ERECORD_ID
           ( p_event_name => p_event_name
            ,p_event_key  => p_event_key
           );

END  GET_ERECORD_ID;

end GMA_STANDARD;

/
