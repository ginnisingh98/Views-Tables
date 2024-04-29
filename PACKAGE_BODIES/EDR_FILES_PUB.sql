--------------------------------------------------------
--  DDL for Package Body EDR_FILES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDR_FILES_PUB" AS
/* $Header: EDRPFILB.pls 120.1.12000000.1 2007/01/18 05:54:35 appldev ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'EDR_FILES_PUB';
G_PUBLISH_FLAG_N constant varchar2(1) := 'N';
G_PUBLISH_FLAG_Y constant varchar2(1) := 'Y';
G_SECURITY_OFF constant NUMBER := 4;
G_SECURITY_ON constant NUMBER := 1;

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

-- Alpha Variables
L_API_NAME 		        CONSTANT VARCHAR2(30) := 'UPLOAD_FILE';
L_FILE_NAME		        VARCHAR2(2000);
L_EXTENSION		        VARCHAR2(2000);
L_RETURN_STATUS 	    VARCHAR2(1);
L_CONCAT_SEGS		    VARCHAR2(200);
L_STATUS		        VARCHAR2(30);
L_EVENT_USER_KEY 	    VARCHAR2(2000);
L_USER			        VARCHAR2(240);
L_MSG_DATA		        VARCHAR2(2000);
L_FILE_DATA		        BLOB;

L_SEG_ARRAY		        FND_FLEX_EXT.SEGMENTARRAY;

-- Numeric Variables
L_COUNT			        NUMBER;
L_ORACLE_ERROR		    NUMBER;
L_API_VERSION		    CONSTANT NUMBER := 1.0;
L_VERSION		        NUMBER;
L_POS			        NUMBER;
L_RESP_ID		        NUMBER;
L_RESP_APPL_ID		    NUMBER;
L_ROW_ID	            VARCHAR2(240);
L_FILE_ID		        NUMBER;
L_CATEGORY_ID		    NUMBER;
L_FND_DOCUMENT_ID	    NUMBER;
L_ATTACHED_DOCUMENT_ID 	NUMBER;
X_DOCUMENT_ID   	    NUMBER;
L_MEDIA_ID      	    NUMBER;

I 			            INTEGER;

-- Exceptions
EDR_FILES_FILE_NAME_NULL  EXCEPTION;
EDR_FILES_CATEGORY_NULL	  EXCEPTION;
EDR_FILES_FILE_NULL	      EXCEPTION;
EDR_FILES_FORMAT_NULL	  EXCEPTION;
EDR_FILES_SRC_LANG_NULL   EXCEPTION;
EDR_FILES_EXIST_ACT_NULL  EXCEPTION;
EDR_FILES_ERES_ERROR	  EXCEPTION;
EDR_FILES_INSERT_ERROR	  EXCEPTION;
EDR_FILES_INV_FLEX_VALUE  EXCEPTION;
EDR_FILES_ALREADY_EXISTS  EXCEPTION;
EDR_FILES_OVERWRITE_ERROR EXCEPTION;
EDR_FILES_APPL_ID_NULL    EXCEPTION;
EDR_FILES_RESP_ID_NULL    EXCEPTION;
EDR_FILES_USER_NULL       EXCEPTION;
edr_commit_flag_error     EXCEPTION;
--Bug 3581517:Start
EDR_FILES_INVALID_CATEGORY EXCEPTION;
--Bug 3581517:End

L_EVENT EDR_ERES_EVENT_PUB.ERES_EVENT_REC_TYPE;
L_CHILDREN EDR_ERES_EVENT_PUB.ERECORD_ID_TBL_TYPE;

L_MSG_COUNT               NUMBER;
L_MSG_index               NUMBER;

L_ERECORD_ID              NUMBER;
L_EVENT_STATUS            VARCHAR2(20);

l_send_ackn               boolean := FALSE;
l_trans_status            varchar2(30);

-- Cursors
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

-- Used to get the next attached_document_id  for a new attachment
CURSOR  c_get_id IS
   SELECT fnd_attached_documents_s.nextval
   FROM dual;

-- Used to check if the attribute is required in the flexfield
CURSOR c_get_flex1 IS
   SELECT count(*)
   FROM  fnd_descr_flex_column_usages
   WHERE application_id = '709'
   AND descriptive_flexfield_name = 'EDR_FILE_ATTRIBUTES'
   AND descriptive_flex_context_code = p_category;
LocalFlex1Record	c_get_flex1%ROWTYPE;

BEGIN
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Get ids
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

   --Check the API version passed in matches the
   --internal API version.

   IF NOT FND_API.Compatible_API_Call
                                        (g_api_version,
					 p_api_version,
					 l_api_name,
					 g_pkg_name) THEN

      RAISE FND_API.G_Exc_Unexpected_Error;
   END IF;

   -- Check for required parameters
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

   --Bug 3265035: Start
   --Add additional check to make sure that the commit takes place
   --when the file is being sent for approval
   --this is required because it doesnt make sense to send a file
   --for approval without it having been commited to the database
   --and technically it wouldn't work because the ERES rule function
   --is doing its commits autonomously
   if (p_commit <> 'T' AND p_submit_for_approval = 'Y') then
       raise edr_commit_flag_error;
   end if;
   --Bug 3265035: End

   -- Default the internal version in case the document does not already exist
   l_version := 0;

   -- The status is always 'N'(New)
   l_status := 'N';

   -- Select the category id
   OPEN c_get_category;
   FETCH c_get_category INTO LocalCatRecord;

   --Bug 3581517:Start
   --comment 1 line
   --l_category_id := LocalCatRecord.category_id;

   --Check if the category exists or not
   IF c_get_category%NOTFOUND THEN
     RAISE EDR_FILES_INVALID_CATEGORY;
   ELSE
     l_category_id := LocalCatRecord.category_id;
   END IF;
   --Bug 3581517:End
   CLOSE c_get_category;

   -- Check to see if file already exists
   OPEN c_get_exists;
   FETCH c_get_exists INTO LocalExistsRecord;

   -- File already exists and not be overwritten, return error
    IF c_get_exists%FOUND THEN
        l_version := LocalExistsRecord.version_number;
   	IF p_file_exists_action = 'D' THEN
   	   RAISE EDR_FILES_ALREADY_EXISTS;
   	END IF;
    END IF;

    -- File exists as approved, pending or approval not required,
    -- and not to be versioned, return error
    IF c_get_exists%FOUND THEN
        l_version := LocalExistsRecord.version_number;
   	IF p_file_exists_action = 'O' AND LocalExistsRecord.status in ('A', 'P', 'S') THEN
   	   RAISE EDR_FILES_OVERWRITE_ERROR;
   	END IF;
    END IF;
   CLOSE c_get_exists;

   -- Validate flexfield values
   FND_FLEX_DESCVAL.set_context_value(p_category);

  i := 0;
  IF p_category IS NOT NULL THEN
   i := i +1;
   l_seg_array(i) := p_category;
  END IF;

  OPEN c_get_flex1;
  FETCH c_get_flex1 INTO l_count;

   --validate the flexfields
   --Bug 3581517:Start
   --comment 1 line
   --IF c_get_flex1%FOUND THEN
   IF l_count > 0 THEN
        --comment the code that conditionally sets the flexfield segment value
        --and instead unconditionally set all the values
        --one sample of older code that is removed is given below...the rest of
        --the block is deleted and replaced by new code
        /*
  	IF l_count >= i THEN
           i := i + 1;
           fnd_flex_descval.set_column_value('ATTRIBUTE1', p_attribute1);
  	END IF;
  	*/
  	fnd_flex_descval.set_column_value('ATTRIBUTE1', p_attribute1);
        fnd_flex_descval.set_column_value('ATTRIBUTE2', p_attribute2);
        fnd_flex_descval.set_column_value('ATTRIBUTE3', p_attribute3);
        fnd_flex_descval.set_column_value('ATTRIBUTE4', p_attribute4);
        fnd_flex_descval.set_column_value('ATTRIBUTE5', p_attribute5);
        fnd_flex_descval.set_column_value('ATTRIBUTE6', p_attribute6);
        fnd_flex_descval.set_column_value('ATTRIBUTE7', p_attribute7);
        fnd_flex_descval.set_column_value('ATTRIBUTE8', p_attribute8);
        fnd_flex_descval.set_column_value('ATTRIBUTE9', p_attribute9);
        fnd_flex_descval.set_column_value('ATTRIBUTE10', p_attribute10);

        --Check for validity of the flexfield data
        --For bug 3581517 this check is now moved inside the top if
        --block (l_count>0) instead of doing an unguarded check
        IF NOT (FND_FLEX_DESCVAL.validate_desccols('EDR',
                                                   'EDR_FILE_ATTRIBUTES',
                                                   'V',
                                                    SYSDATE))
        THEN
          RAISE EDR_FILES_INV_FLEX_VALUE;
        END IF;
   --Bug 3581517:End

   END IF;
   CLOSE c_get_flex1;

   --Increment internal version number
   l_version := l_version + 1;

   -- Locate beginning of the extension in the file name string to use position to
   --split up the file name
   l_extension := NULL;
   l_file_name := p_file_name;
   l_pos := INSTR(p_file_name, '.',-1,1);

   IF l_pos <> 0 THEN
      l_extension := SUBSTR(l_file_name,l_pos,LENGTH(l_file_name));
      l_file_name := SUBSTR(p_file_name,1,l_pos-1);
   END IF;

   --Set up the display name for the attachment
   l_file_name := l_file_name ||'_v_'||p_version_label||l_extension;

   --Get the next sequence number for file_id
   SELECT  edr_files_b_s.nextval INTO l_file_id FROM dual;

  --Call private package to insert data into the tables
  --the whole idea is that instead of inserting one row in edr_files_b/tl tables
  -- we would have to insert a row in:
  -- edr_files_b/tl
  -- fnd_documents
  --fnd_lobs
  --fnd_attached_documents (attach the file to a default enity named EDR_FILES_B

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

   --now that the row is inserted in edr_files table
   -- we have insert into fn_documents, fnd_attached_documents
   -- and fnd_lobs

   --to insert in fnd_documents and fnd_attached_dcouments
   --use FND_ATTACHED_DOCUMENTS_PKG.Insert_Row

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
               --Bug 4381237: Start
               --We dont want any attachment security in the file
               --X_security_type=>1,
               --X_security_id=>-1,
               X_security_type=>4,
               X_security_id=> null,
               --Bug Bug 4381237: End
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
   INSERT into FND_LOBS
   	(file_id,
    	 file_name,
    	 file_data,
    	 file_content_type,
    	 file_format)
    VALUES
    	(l_media_id,
    	 l_file_name,
    	 --Bug 3265035: Start
    	 p_file_data,
    	 --l_file_data,
    	 --Bug 3265035: End
    	 p_content_type,
    	 p_file_format);

        --now update the row in the edr_files_b table with the fnd_document_id
        --that you get from inserting a row in FND_DOCUMENTS table

	UPDATE 	EDR_FILES_B
	SET	fnd_document_id = x_document_id
	WHERE  	file_id = l_file_id;

  --If sending for approval, raise ERES event
  IF p_submit_for_approval = 'Y' THEN

        --Bug 3265035: Start
        --if the file is being sent for approval go ahead and commit
        --u dont need to check commit flag as the commit flag would have
        --to be Y in order for the control to come here
        commit;
        --Bug 3265035: End

        OPEN c_get_event;
        FETCH c_get_event INTO LocalEventRecord;
        l_event_user_key := LocalEventRecord.file_name ||'-'||LocalEventRecord.name;
        CLOSE c_get_event;

	--Bug 3265035: Start
	-- raise the event

	--create the payload first
	l_event.param_name_1 := 'DEFERRED';
	l_event.param_value_1 := 'Y';
	l_event.param_name_2 := 'POST_OPERATION_API';
	l_event.param_value_2 := 'EDR_ATTACHMENTS_GRP.EVENT_POST_OP('||l_file_id||')';
	l_event.param_name_3 := 'PSIG_USER_KEY_LABEL';
	l_event.param_value_3 := 'File Approval:';
	l_event.param_name_4 := 'PSIG_USER_KEY_VALUE';
	l_event.param_value_4 := l_event_user_key;
	l_event.param_name_5 := 'PSIG_TRANSACTION_AUDIT_ID';
	l_event.param_value_5 := '-1';
	l_event.param_name_6 := '#WF_SOURCE_APPLICATION_TYPE';
	l_event.param_value_6 := 'DB';
	l_event.param_name_7 := '#WF_SIGN_REQUESTER';
	l_event.param_value_7 := l_user;

	--now create the eres event
	l_event.event_name := 'oracle.apps.edr.file.approve';
	l_event.event_key := l_file_id;
	l_event.erecord_id := l_erecord_id;
	l_event.event_status := l_event_status;

	--now raise the eres event
	EDR_ERES_EVENT_PUB.RAISE_ERES_EVENT
	( p_api_version         => 1.0			         ,
	  p_init_msg_list       => FND_API.G_TRUE	         ,
	  p_validation_level    => FND_API.G_VALID_LEVEL_FULL    ,
	  x_return_status       => l_return_status	         ,
	  x_msg_count           => l_msg_count		         ,
	  x_msg_data            => l_msg_data		         ,
	  p_child_erecords      => l_children	                 ,
	  x_event               => l_event
	);

	-- If any errors happen abort API.
	IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	/*
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
         */

         l_erecord_id := l_event.erecord_id;
         l_event_status := l_event.event_status;

         --if the erecord id has been generated it means that the file required some
         --erecord and/or esignature. in that case update the status of the file and
         --also send out an acknowldgement to the evidence store

         if (l_erecord_id is not null) then
         	-- If the status of the erecord in the evidence store is NOACTION
         	-- it means that signature was not required.
         	-- if its PENDING means that the offine notification is sent out
         	-- to the approver and its waiting approval
         	-- in any other case raise an error

                if (l_event_status = 'PENDING') then
                        l_send_ackn := TRUE;
                        l_trans_status := 'SUCCESS';

			--update the file status and put the erecord
			--id in attribute 14

	         	UPDATE  edr_files_b
	         	SET	status = 'P',
	         		attribute14 = l_erecord_id
	         	WHERE	file_id = l_file_id
	         	AND 	file_name = LocalEventRecord.file_name;
		elsif (l_event_status = 'NOACTION') then
                        l_send_ackn := TRUE;
                        l_trans_status := 'SUCCESS';

	         	UPDATE  edr_files_b
	         	SET	status = 'S',
	         		attribute14 = l_erecord_id
	         	WHERE	file_id = l_file_id
	         	AND 	file_name = LocalEventRecord.file_name;

                --Bug 3265035: Start
                 --this would allow the file to be attached to other business objects
                --through the Document Catalog button in the attachment Forms UI
                update fnd_documents set
                security_type = G_SECURITY_OFF,
                publish_flag = G_PUBLISH_FLAG_Y
                where document_id = x_document_id;
                --For the Status 'NO APPROVAL' Raise the Approval completion Event
                wf_event.raise2(p_event_name       => 'oracle.apps.edr.file.approvalcompletion',
                                p_event_key        => l_file_id,
                                p_event_data       => null,
                                p_parameter_name1  => 'FILE_STATUS',
                                p_parameter_value1 => 'NO APPROVAL'
                                );
                --Bug 3265035: End
		end if;


	        --send transaction acknowledgement
	        if l_send_ackn = TRUE then
		        EDR_TRANS_ACKN_PUB.SEND_ACKN
		        ( p_api_version          => 1.0,
		          p_init_msg_list	 => FND_API.G_TRUE   ,
		          x_return_status	 => l_return_status,
		          x_msg_count		 => l_msg_count,
		          x_msg_data		 => l_msg_data,
		          p_event_name           => l_event.event_name,
		          p_event_key            => l_event.event_key,
		          p_erecord_id	         => l_erecord_id,
		          p_trans_status	 => l_trans_status,
		          p_ackn_by              => 'FILE_UPLOAD_API',
		          p_ackn_note	         => '',
		          p_autonomous_commit    => 'T'
		        );

			-- If any errors happen abort API.
			IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
				RAISE FND_API.G_EXC_ERROR;
			END IF;
	        end if;
	end if;
	--Bug 3265035: End
    END IF;

    --if everything is successful and commit is yes, issue a commit
    IF p_commit = 'T' THEN
    	COMMIT;
    END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR ;
       FND_MSG_PUB.Count_And_Get
       (p_count        =>      l_msg_count  ,
        p_data         =>      x_msg_data
       );
       APP_EXCEPTION.RAISE_EXCEPTION;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       FND_MSG_PUB.Count_And_Get
       (p_count         	=>      l_msg_count     ,
        p_data          	=>      x_msg_data
       );
       APP_EXCEPTION.RAISE_EXCEPTION;

   WHEN EDR_FILES_FILE_NAME_NULL THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MESSAGE.SET_NAME('EDR','EDR_FILES_FILE_NAME_NULL');
        FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
	FND_MSG_PUB.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;

   WHEN EDR_FILES_APPL_ID_NULL THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MESSAGE.SET_NAME('EDR','EDR_FILES_APPL_ID_NULL');
        FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
	FND_MSG_PUB.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;

   WHEN EDR_FILES_RESP_ID_NULL THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MESSAGE.SET_NAME('EDR','EDR_FILES_RESP_ID_NULL');
        FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
	FND_MSG_PUB.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;

   WHEN EDR_FILES_USER_NULL THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MESSAGE.SET_NAME('EDR','EDR_FILES_USER_NULL');
        FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
	FND_MSG_PUB.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;

   WHEN EDR_FILES_CATEGORY_NULL	THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
  	FND_MESSAGE.SET_NAME('EDR','EDR_FILES_CATEGORY_NULL');
        FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
	FND_MSG_PUB.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;

   WHEN EDR_FILES_FILE_NULL THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
   	FND_MESSAGE.SET_NAME('EDR','EDR_FILES_FILE_NULL');
        FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
	FND_MSG_PUB.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;

    WHEN EDR_FILES_FORMAT_NULL THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    	FND_MESSAGE.SET_NAME('EDR','EDR_FILES_FORMAT_NULL');
        FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
	FND_MSG_PUB.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;

    WHEN EDR_FILES_SRC_LANG_NULL THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('EDR','EDR_FILES_SRC_LANG_NULL');
        FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
	FND_MSG_PUB.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;

    WHEN EDR_FILES_EXIST_ACT_NULL THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('EDR','EDR_FILES_EXISTS_ACT_NULL');
        FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
	FND_MSG_PUB.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;

    WHEN EDR_FILES_ERES_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    	FND_MESSAGE.SET_NAME('EDR','EDR_FILES_ERES_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
	FND_MSG_PUB.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;

    WHEN EDR_FILES_INSERT_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    	FND_MESSAGE.SET_NAME('EDR','EDR_FILES_INSERT_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
	FND_MSG_PUB.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;

    WHEN EDR_FILES_INV_FLEX_VALUE THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    	FND_MESSAGE.SET_NAME('EDR','EDR_FILES_INV_FLEX_VALUE');
        FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
	FND_MSG_PUB.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;

    WHEN EDR_FILES_ALREADY_EXISTS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    	FND_MESSAGE.SET_NAME('EDR','EDR_FILES_ALREADY_EXISTS');
        FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
	FND_MSG_PUB.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;

    WHEN EDR_FILES_OVERWRITE_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    	FND_MESSAGE.SET_NAME('EDR','EDR_FILES_OVERWRITE_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
	FND_MSG_PUB.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;

    WHEN edr_commit_flag_error THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    	FND_MESSAGE.SET_NAME('EDR','EDR_FILES_COMMIT_FLAG_ERROR');
        FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
	FND_MSG_PUB.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;

    WHEN EDR_FILES_INVALID_CATEGORY THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
    	FND_MESSAGE.SET_NAME('EDR','EDR_FILES_INVALID_CATEGORY');
        FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
	FND_MSG_PUB.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_data :=  'Error = '||SQLERRM;
        FND_MSG_PUB.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;

END UPLOAD_FILE;

END EDR_FILES_PUB;

/
