--------------------------------------------------------
--  DDL for Package Body CSM_LOBS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_LOBS_PKG" AS
/* $Header: csmulobb.pls 120.15.12010000.3 2010/05/13 10:05:18 trajasek ship $ */

-- MODIFICATION HISTORY
-- Person      Date    Comments
-- Ravi        06/11/2002
-- ---------   ------  ------------------------------------------
   -- Enter procedure, function bodies as shown below

error EXCEPTION;

/*** Globals ***/
g_object_name  CONSTANT VARCHAR2(30) := 'CSM_LOBS_PKG';  -- package name
g_pub_name     CONSTANT VARCHAR2(30) := 'CSF_M_LOBS';  -- publication item name
g_debug_level           NUMBER; -- debug level

--to check if the record exists in the database
 CURSOR l_lobs_fileid_csr (p_file_id fnd_lobs.file_id%TYPE)
 IS
 SELECT 1
 FROM 	fnd_lobs
 WHERE 	FILE_ID = P_FILE_ID;

CURSOR c_FND_LOBS( b_user_name VARCHAR2, b_tranid NUMBER) is
  SELECT
     CLID$$CS,
 	 FILE_ID,
  	 TASK_ASSIGNMENT_ID,
  	 DESCRIPTION,
  	 LANGUAGE,
  	 DMLTYPE$$,
	 SEQNO$$,
	 TRANID$$,
	 VERSION$$,
	 ENTITY_NAME,
	 PK1_VALUE,
	 PK2_VALUE,
	 SEQ_NUM,
	 FILE_NAME,
	 FILE_CONTENT_TYPE,
	 USER_NAME,
	 LAST_UPDATE_DATE,
	 LAST_UPDATED_BY,
	 UPDATE_USER,
	 CATEGORY,
	 USAGE_TYPE,
	 DATA_TYPE,
	 URL,
	 SHORT_TEXT,
	 DATA_TYPE_ID,
	 DOCUMENT_ID,
	 TITLE
  FROM
	 csf_m_lobs_inq
  WHERE   tranid$$ = b_tranid
  AND     clid$$cs = b_user_name;

/***
  This procedure is called by APPLY_RECORD when an inserted record is to be processed.
***/

PROCEDURE APPLY_INSERT
         (
           p_record        IN c_FND_LOBS%ROWTYPE,
           p_error_msg     OUT NOCOPY    VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2
         ) IS

  -- Variables needed for public API
  l_seq_num			NUMBER;
  l_category_id		NUMBER;
  l_file_id			NUMBER;
  l_task_assignment_id	NUMBER;--This column in the table has the SR or TASK id
  l_msg_count 		NUMBER;
  l_msg_data  		VARCHAR2(240);
  l_file_access_id 	NUMBER;
  l_error_msg 		VARCHAR(1024);
  l_signature_loc 	BLOB;
  l_signature_raw 	LONG RAW(32000);
  l_signature_size 	NUMBER;
  l_language 		asg_user.LANGUAGE%TYPE;
  l_dummy 			NUMBER;
  l_category_name   VARCHAR2(240);--need to add value
  l_file_name		p_record.FILE_NAME%TYPE;
  l_file_content_type p_record.FILE_CONTENT_TYPE%TYPE;
  l_entity_name		p_record.ENTITY_NAME%TYPE;
  l_function_name 	VARCHAR2(240);
  l_user_id			ASG_USER.USER_ID%TYPE;
  l_dodirty			BOOLEAN;
  l_title           VARCHAR2(80);
  l_schema_name		FND_ORACLE_USERID.ORACLE_USERNAME%TYPE;
  l_data_type       all_tab_columns.data_type%TYPE;
  l_data_type_id NUMBER;
  l_dsql 			VARCHAR2(4000);
  l_cursorid 		NUMBER;
  l_result 			NUMBER;

  -- get the debrief header id for the task_assignment
  -- use the first debrief header id
  CURSOR l_debrief_header_id_csr(p_task_assignment_id IN number)
  IS
  SELECT debrief_header_id
  FROM   csf_debrief_headers
  WHERE  task_assignment_id = p_task_assignment_id
  ORDER BY debrief_header_id;

  -- get max seq no for the debrief_header_id
  CURSOR l_max_seq_no_csr(p_task_assignment_id IN NUMBER, p_language IN VARCHAR2,p_category_name IN VARCHAR2,c_entity_name IN VARCHAR2)
  IS
  SELECT nvl(max(fad.seq_num),0)+10
  FROM   fnd_attached_documents fad,
         fnd_documents fd
  WHERE  fad.pk1_value   = to_char(p_task_assignment_id)
  AND    fd.document_id  = fad.document_id
  AND    fad.entity_name = c_entity_name
  AND EXISTS
         (SELECT 1
          FROM 	fnd_document_categories_tl cat_tl
          WHERE cat_tl.category_id 	= fd.category_id
          AND 	cat_tl.name 		= p_category_name
          AND 	cat_tl.LANGUAGE 	= p_language
          );


  -- get the category_id
  CURSOR l_category_id_csr(p_language IN VARCHAR2, p_category_name IN VARCHAR2)
  IS
  SELECT category_id
  FROM 	 fnd_document_categories_tl
  WHERE  name 	  = p_category_name
  AND 	 LANGUAGE = p_language;


 CURSOR l_get_language(p_user_name IN VARCHAR2)
 IS
 SELECT au.LANGUAGE,au.USER_ID
 FROM 	asg_user au
 WHERE 	au.user_name = p_user_name;

 CURSOR l_get_schema
 IS
 SELECT ORACLE_USERNAME from  FND_ORACLE_USERID
 WHERE ORACLE_ID =883;

 CURSOR l_get_datatype (c_schema IN FND_ORACLE_USERID.ORACLE_USERNAME%TYPE)
 IS
 select data_type from all_tab_columns
 where table_name 	= 'CSF_M_LOBS_INQ'
 and   column_name  = 'FILE_DATA'
 and   OWNER        = c_schema;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_dodirty		  := FALSE;--mark dirty for datatypeid =6 is not necessary

  l_error_msg := 'Entering ' || g_object_name || '.APPLY_INSERT'|| ' for PK ' || to_char( p_record.file_id);
  CSM_UTIL_PKG.LOG   ( l_error_msg ,
                           'CSM_LOBS_PKG.APPLY_INSERT',
                           FND_LOG.LEVEL_PROCEDURE );

  --if attachments are not part of what we support then we leave
  IF p_record.entity_name NOT IN('JTF_TASKS_B','CS_INCIDENTS','CSF_DEBRIEF_HEADERS') THEN

  	l_error_msg := 'Leaving ' || g_object_name || '.APPLY_INSERT'||
	  			   ' as we are not supporting  Attachment for the entity' || TO_CHAR(p_record.entity_name);
  	CSM_UTIL_PKG.LOG   ( l_error_msg ,'CSM_LOBS_PKG.APPLY_INSERT',FND_LOG.LEVEL_PROCEDURE );
  	RETURN;

  END IF;

  l_title:=p_record.title;
  l_data_type_id :=p_record.data_type_id;
  -- get the language of the user
  OPEN  l_get_language(p_record.clid$$cs);
  FETCH l_get_language INTO l_language,l_user_id;
  CLOSE l_get_language;

  IF p_record.entity_name = 'JTF_TASKS_B' OR p_record.entity_name = 'CS_INCIDENTS'	THEN
  	l_category_name   	 := 'MISC';
  	l_file_name		  	 := p_record.file_name;
  	l_file_content_type  := p_record.file_content_type;
  	l_entity_name		 := p_record.entity_name;
   	l_task_assignment_id := TO_NUMBER (p_record.pk1_value);

  	IF p_record.entity_name = 'JTF_TASKS_B' THEN --function name is the Name of the Form in which the attachment is displayed
  		l_function_name		:= 'JTFTKMAN';
  	ELSIF p_record.entity_name = 'CS_INCIDENTS' THEN
  		l_function_name		:= 'CSXSRISR';
  	END IF;

  ELSIF p_record.entity_name = 'CSF_DEBRIEF_HEADERS'	THEN
  	--Else is for signature upload for debrief
  	l_category_name   	:= 'SIGNATURE';
  	l_file_name		  	:= 'INTERNAL';
  	l_file_content_type := 'image/bmp';
  	l_entity_name		:= 'CSF_DEBRIEF_HEADERS';
  	l_function_name		:= 'CSFFEDBF';
-- Bug 5726888
    l_data_type_id :=6;
  --required only for signature...
  -- if debrief_header_id is not passed get the debrief header id using task assignment id
    l_task_assignment_id:=p_record.pk1_value;

  	IF ( (p_record.pk1_value IS NULL) AND
        (p_record.task_assignment_id IS NOT NULL) )
  	THEN
     	OPEN l_debrief_header_id_csr(p_record.task_assignment_id);
     	FETCH l_debrief_header_id_csr INTO l_task_assignment_id;
     	CLOSE l_debrief_header_id_csr;
  	END IF;
  END IF;


  --setting file id
  --For lobs we require file id to insert data into fnd_lobs.So we get the file_id from the client
  --For LOBS we give fileid to the server so that we can avoid the lobs getting downloaded in the client
  --twice when its uploaded
  IF l_data_type_id = 6 THEN
  	   l_file_id := p_record.file_id;

-- Bug 5726888
           IF l_file_id IS NULL AND l_category_name = 'SIGNATURE' THEN
            l_file_id := p_record.document_id;
           END IF;
	     --verify that the record does not already exist.If already present then pass null so that the api will create the own id
  		 OPEN 	l_lobs_fileid_csr(l_file_id) ;
  		 FETCH l_lobs_fileid_csr into l_dummy;

		 IF  l_lobs_fileid_csr%FOUND THEN
			p_error_msg 	:= 'Duplicate Record: File id ' || to_char(l_file_id)|| ' already exists in fnd_lobs table.So generating a new from fnd sequence';
       		CSM_UTIL_PKG.LOG( p_error_msg ,'CSM_LOBS_PKG.UPLOAD_SR_TASK_LOB', FND_LOG.LEVEL_ERROR );
		    l_file_id := NULL;
			--get the file id from the sequence diretly.As the client sent file id is not proper.
		    SELECT fnd_lobs_s.nextval
			INTO l_file_id
   			FROM dual;
			l_dodirty := TRUE;
	     END IF;

		 CLOSE l_lobs_fileid_csr;
  ELSE
	   l_file_id := NULL;
  END IF;

  -- get the max seq no
  open  l_max_seq_no_csr(l_task_assignment_id, l_language,l_category_name,l_entity_name);
  FETCH l_max_seq_no_csr INTO l_seq_num;
  CLOSE l_max_seq_no_csr;

  -- get the category id for Signature
  OPEN  l_category_id_csr(l_language,l_category_name);
  FETCH l_category_id_csr INTO l_category_id;
  CLOSE l_category_id_csr;

  IF l_data_type_id = 6 THEN

    BEGIN
  	-- get shema
  	OPEN  l_get_schema;
  	FETCH l_get_schema INTO l_schema_name;
  	CLOSE l_get_schema;

  	-- get datatype
  	OPEN  l_get_datatype(l_schema_name);
  	FETCH l_get_datatype INTO l_data_type;
  	CLOSE l_get_datatype;

   /* INSERT INTO fnd_lobs(file_id,
						file_name,
						file_content_type,
						file_data,
        				upload_date,
						language,
						file_format)
     			SELECT	l_file_id AS FILE_ID,
						l_file_name AS FILE_NAME,
						l_file_content_type AS FILE_CONTENT_TYPE,
						file_data AS FILE_DATA,
        				SYSDATE as UPLOAD_DATE,
						l_language as LANGUAGE,
						'binary' AS FILE_FORMAT
				FROM	csf_m_lobs_inq
				WHERE 	file_id = l_file_id
				AND 	tranid$$ = p_record.tranid$$
    			AND     clid$$cs = p_record.clid$$cs;*/
		IF l_data_type ='BLOB' THEN
			l_dsql :=  'INSERT INTO fnd_lobs(file_id,'
				||		'file_name,'
				||		'file_content_type,'
				||		'file_data,'
        		||		'upload_date,'
				||		'language, '
				||		'file_format)'
     			|| 'SELECT ' ||	l_file_id   || ' AS FILE_ID,'
						   	 || '''' || l_file_name || ''' AS FILE_NAME,'
							 || '''' || l_file_content_type || ''' AS FILE_CONTENT_TYPE, '
							 || 'file_data    AS FILE_DATA, '
        					 ||' SYSDATE 	  AS UPLOAD_DATE,'
							 ||'''' || l_language 	|| ''' AS LANGUAGE,'
							 ||'''binary'''     || ' AS FILE_FORMAT '
							 ||' FROM	csf_m_lobs_inq'
				|| ' WHERE 	file_id  = ' || l_file_id
				|| ' AND 	tranid$$ = ' || p_record.tranid$$
    			|| ' AND     clid$$cs = ''' || p_record.clid$$cs || '''';

		ELSE
			l_dsql :=  'INSERT INTO fnd_lobs(file_id,'
				||		'file_name,'
				||		'file_content_type,'
				||		'file_data,'
        		||		'upload_date,'
				||		'language, '
				||		'file_format)'
     			|| 'SELECT ' ||	l_file_id   || ' AS FILE_ID,'
						   	 || '''' || l_file_name || ''' AS FILE_NAME,'
							 || '''' || l_file_content_type || ''' AS FILE_CONTENT_TYPE, '
							 || 'TO_LOB(file_data)    AS FILE_DATA, '
        					 ||' SYSDATE   AS UPLOAD_DATE,'
							 ||'''' || l_language 	|| ''' AS LANGUAGE,'
							 ||'''binary'''     || ' AS FILE_FORMAT '
							 ||' FROM	csf_m_lobs_inq'
				|| ' WHERE 	file_id  = ' || l_file_id
				|| ' AND 	tranid$$ = ' || p_record.tranid$$
    			|| ' AND     clid$$cs = ''' || p_record.clid$$cs || '''';

		END IF;

  		l_cursorid := DBMS_SQL.open_cursor;
   		--parse and execute the sql
   		DBMS_SQL.parse(l_cursorid, l_dsql, DBMS_SQL.v7);
   		l_result := DBMS_SQL.execute(l_cursorid);
   		DBMS_SQL.close_cursor (l_cursorid);



    EXCEPTION
      WHEN OTHERS THEN
      -- check if the record exists
          OPEN  l_lobs_fileid_csr(l_file_id) ;
	      FETCH l_lobs_fileid_csr into l_dummy;
	      IF l_lobs_fileid_csr%found THEN
	         --the record exists. Dont show any error.
             null;
          ELSE
             --record could not be inserted, throw the exception
             x_return_status := FND_API.G_RET_STS_ERROR;
             raise;
          END IF;
	      CLOSE l_lobs_fileid_csr;
    END;

  END IF;--this is execulted only for lobs

  --After inserting the lobs into fnd_lobs table the attachment is added to the corresponding
  --Entity ie to task or Debrief or SR we need to call the following API
  fnd_webattch.add_attachment(
    seq_num 			=> l_seq_num,
    category_id 		=> l_category_id,
    document_description=> p_record.description,  --l_signed_date||' '||l_signed_by,
    datatype_id 		=> l_data_type_id,
    text			    => p_record.short_text,
    file_name 		    => l_file_name,
    url                 => p_record.url,
    function_name 		=> l_function_name,
    entity_name 		=> l_entity_name,
    pk1_value 		    => l_task_assignment_id,
   	pk2_value		    => NULL,
   	pk3_value		    => NULL,
   	pk4_value		    => NULL,
   	pk5_value		    => NULL,
    media_id 			=> l_file_id,
    user_id 			=> l_user_id, --fnd_global.login_id
	title               => l_title);

	--Inserting data into the Access table to have the record in the client immd.Without running JTM progmram

	CSM_LOBS_EVENT_PKG.INSERT_ACC_ON_UPLOAD(l_task_assignment_id,l_user_id,l_entity_name,l_data_type_id,l_dodirty);

	l_error_msg			:= 'The record is going to get rejected as its successfully inserted into the Base Table.';

    CSM_UTIL_PKG.LOG   ( l_error_msg , 'CSM_LOBS_PKG.APPLY_INSERT',
                     FND_LOG.LEVEL_PROCEDURE );

	--The attachment is added successfully to the apps.so deferring the original record
    IF l_data_type_id =5 OR l_data_type_id =1 OR (l_data_type_id = 6 AND l_dodirty = TRUE) THEN
	   --Reject the record for url,short text and for lobs which has new file id
	   --from server instead of one from the client
	   CSM_UTIL_PKG.REJECT_RECORD        (
           p_user_name     => p_record.CLID$$CS,
           p_tranid        => p_record.TRANID$$,
           p_seqno         => p_record.SEQNO$$,
           p_pk            => p_record.document_id,
           p_object_name   => g_object_name,
           p_pub_name      => g_pub_name,
           p_error_msg     => l_error_msg,
           x_return_status => x_return_status
         );

	END IF;

    l_error_msg :=  'Leaving ' || g_object_name || '.APPLY_INSERT' || ' for PK ' || to_char (p_record.file_id);
    CSM_UTIL_PKG.LOG   ( l_error_msg , 'CSM_LOBS_PKG.APPLY_INSERT',
                     FND_LOG.LEVEL_PROCEDURE );


EXCEPTION WHEN OTHERS THEN

  l_error_msg :=  'Exception occurred in ' || g_object_name || '.APPLY_INSERT and hence leaving it:' || ' ' || sqlerrm
               || ' for PK ' || to_char (p_record.file_id );
  CSM_UTIL_PKG.LOG   ( l_error_msg ,'CSM_LOBS_PKG.APPLY_INSERT',FND_LOG.LEVEL_ERROR );
  fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_INSERT', sqlerrm);

  p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT(p_api_error => TRUE );
  x_return_status := FND_API.G_RET_STS_ERROR;

END APPLY_INSERT;

/***
  This procedure is called by APPLY_CLIENT_CHANGES for every record in in-queue that needs to be processed.
***/
PROCEDURE APPLY_RECORD
         (
           p_record        IN     c_FND_LOBS%ROWTYPE,
           p_error_msg     OUT NOCOPY    VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2
         ) IS
l_error_msg varchar(1024);
BEGIN
  /*** initialize return status and message list ***/
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.INITIALIZE;


  l_error_msg :=  'Entering ' || g_object_name || '.APPLY_RECORD'
               || ' for PK ' || to_char (p_record.FILE_ID );
  CSM_UTIL_PKG.LOG   ( l_error_msg ,
                     'CSM_LOBS_PKG.APPLY_RECORD',
                    FND_LOG.LEVEL_PROCEDURE );

  l_error_msg := 'Processing ' || g_object_name || ' for PK ' || to_char (p_record.FILE_ID) || ' ' ||
       'DMLTYPE = ' || p_record.dmltype$$ ;

   CSM_UTIL_PKG.LOG ( l_error_msg ,
            'CSM_LOBS_PKG.APPLY_RECORD',
             FND_LOG.LEVEL_EVENT  );

  IF p_record.dmltype$$='I' THEN
    -- Process insert
    APPLY_INSERT
      (
        p_record,
        p_error_msg,
        x_return_status
      );
  ELSIF p_record.dmltype$$='U' THEN

    -- Process update; not supported for this entity

      l_error_msg := 'Update is not supported for this entity ' || g_object_name;
      CSM_UTIL_PKG.LOG  (l_error_msg,
        'CSM_LOBS_PKG.APPLY_RECORD',
         FND_LOG.LEVEL_EVENT );

        p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_message        => 'CSM_DML_OPERATION'
      , p_token_name1    => 'DML'
      , p_token_value1   => p_record.dmltype$$
      );

    x_return_status := FND_API.G_RET_STS_ERROR;

  ELSIF p_record.dmltype$$='D' THEN
    -- Process delete; not supported for this entity

      l_error_msg := 'Delete is not supported for this entity ' || g_object_name ;
      CSM_UTIL_PKG.LOG( l_error_msg,
                'CSM_LOBS_PKG.APPLY_RECORD',
                FND_LOG.LEVEL_EVENT );


    p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_message        => 'CSM_DML_OPERATION'
      , p_token_name1    => 'DML'
      , p_token_value1   => p_record.dmltype$$
      );

    x_return_status := FND_API.G_RET_STS_ERROR;
  ELSE
    -- invalid dml type

       CSM_UTIL_PKG.LOG
      ( 'Invalid DML type: ' || p_record.dmltype$$ || ' for this entity '
                            || g_object_name,  'CSM_LOBS_PKG.APPLY_RECORD', FND_LOG.LEVEL_ERROR);

    p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_message        => 'CSM_DML_OPERATION'
      , p_token_name1    => 'DML'
      , p_token_value1   => p_record.dmltype$$
      );

    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

    CSM_UTIL_PKG.LOG ( 'Leaving ' || g_object_name || '.APPLY_RECORD'   || ' for PK ' || p_record.FILE_ID,
                        'CSM_LOBS_LOBS.APPLY_RECORD',
                        FND_LOG.LEVEL_PROCEDURE  );


EXCEPTION WHEN OTHERS THEN
  /*** defer record when any process exception occurs ***/

   CSM_UTIL_PKG.LOG
    ( 'Exception occurred in ' || g_object_name || '.APPLY_RECORD:' || ' ' || sqlerrm
               || ' for PK ' || p_record.FILE_ID,'CSM_LOBS_LOBS.APPLY_RECORD',FND_LOG.LEVEL_ERROR );


  fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_RECORD', sqlerrm);
  p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
    (
      p_api_error      => TRUE
    );


    CSM_UTIL_PKG.LOG
    ( 'Leaving ' || g_object_name || '.APPLY_RECORD'|| ' for PK ' || p_record.FILE_ID,
            'CSM_LOBS_LOBS.APPLY_RECORD',
            FND_LOG.LEVEL_ERROR );


  x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_RECORD;

/***
  This procedure is called by CSM_SERVICEP_WRAPPER_PKG when publication item CSF_M_LOBS
  is dirty. This happens when a mobile field service device executed DML on an updatable table and did
  a fast sync. This procedure will insert the data that came from mobile into the backend tables using
  public APIs.
***/
PROCEDURE APPLY_CLIENT_CHANGES
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_debug_level   IN NUMBER,
           x_return_status IN OUT NOCOPY VARCHAR2
         ) IS

  l_process_status VARCHAR2(1);
  l_error_msg      VARCHAR2(4000);
BEGIN
  g_debug_level := p_debug_level;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  CSM_UTIL_PKG.LOG   ( 'Entering ' || g_object_name || '.Apply_Client_Changes',
            'CSM_LOBS_LOBS.APPLY_CLIENT_CHANGES',
             FND_LOG.LEVEL_PROCEDURE);


  /*** loop through CSF_M_LOBS records in inqueue ***/
  FOR r_FND_LOBS IN c_FND_LOBS( p_user_name, p_tranid) LOOP

    SAVEPOINT save_rec;

    /*** apply record ***/
    APPLY_RECORD
      (
        r_FND_LOBS
      , l_error_msg
      , l_process_status
      );


    /*** was record processed successfully? ***/
    IF l_process_status = FND_API.G_RET_STS_SUCCESS THEN
      /*** Yes -> delete record from inqueue ***/
        CSM_UTIL_PKG.LOG
        ( 'Record successfully processed, deleting from inqueue ' || g_object_name
               || ' for PK ' || r_FND_LOBS.FILE_ID,
               'CSM_LOBS_LOBS.APPLY_CLIENT_CHANGES',
               FND_LOG.LEVEL_EVENT );


      CSM_UTIL_PKG.DELETE_RECORD
        (
          p_user_name,
          p_tranid,
          r_FND_LOBS.seqno$$,
          r_FND_LOBS.FILE_ID, -- put PK column here
          g_object_name,
          g_pub_name,
          l_error_msg,
          l_process_status
        );

      /*** was delete successful? ***/
      IF l_process_status <> FND_API.G_RET_STS_SUCCESS THEN
        /*** no -> rollback ***/
          CSM_UTIL_PKG.LOG
          ( 'Deleting from inqueue failed, rolling back to savepoint for entity ' || g_object_name
               || ' and  PK ' || r_FND_LOBS.FILE_ID,
               'CSM_LOBS_LOBS.APPLY_CLIENT_CHANGES' ,
               FND_LOG.LEVEL_EVENT);

        ROLLBACK TO save_rec;
      END IF;
    END IF;

    IF l_process_Status <> FND_API.G_RET_STS_SUCCESS THEN
      /*** Record was not processed successfully or delete failed -> defer and reject record ***/

        CSM_UTIL_PKG.LOG
        ( 'Record not processed successfully, deferring and rejecting record for entity ' || g_object_name
               || ' and PK ' || r_FND_LOBS.FILE_ID,
               'CSM_LOBS_LOBS.APPLY_CLIENT_CHANGES',
               FND_LOG.LEVEL_EVENT );


      CSM_UTIL_PKG.DEFER_RECORD
       (
         p_user_name
       , p_tranid
       , r_FND_LOBS.seqno$$
       , r_FND_LOBS.FILE_ID -- put PK column here
       , g_object_name
       , g_pub_name
       , l_error_msg
       , l_process_status
       , r_FND_LOBS.dmltype$$
       );

      /*** Was defer successful? ***/
      IF l_process_status <> FND_API.G_RET_STS_SUCCESS THEN
        /*** no -> rollback ***/
          CSM_UTIL_PKG.LOG
          ( 'Defer record failed, rolling back to savepoint for entity ' || g_object_name
               || ' and PK ' || r_FND_LOBS.FILE_ID,
               'CSM_LOBS_LOBS.APPLY_CLIENT_CHANGES',
               FND_LOG.LEVEL_EVENT );

        ROLLBACK TO save_rec;
      END IF;
    END IF;

  END LOOP;


    CSM_UTIL_PKG.LOG( 'Leaving ' || g_object_name || '.Apply_Client_Changes',
    'CSM_LOBS_LOBS.APPLY_CLIENT_CHANGES',
    FND_LOG.LEVEL_PROCEDURE);


EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
    CSM_UTIL_PKG.LOG  ( 'Exception occurred in ' || g_object_name || '.APPLY_CLIENT_CHANGES:' || ' ' || sqlerrm ,
        'CSM_LOBS_LOBS.APPLY_CLIENT_CHANGES', FND_LOG.LEVEL_ERROR);

  x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_CLIENT_CHANGES;

--code for HA
PROCEDURE APPLY_HA_INSERT
          (p_HA_PAYLOAD_ID  IN  NUMBER,
           p_COL_NAME_LIST  IN  CSM_VARCHAR_LIST,
           p_COL_VALUE_LIST IN  CSM_VARCHAR_LIST,
           x_RETURN_STATUS  OUT NOCOPY VARCHAR2,
           x_ERROR_MESSAGE  OUT NOCOPY VARCHAR2
         )
IS
L_HA_PAYLOAD_ID       NUMBER;
L_COL_NAME_LIST       CSM_VARCHAR_LIST;
L_COL_VALUE_LIST      CSM_VARCHAR_LIST;
L_CON_NAME_LIST  CSM_VARCHAR_LIST;
l_CON_VALUE_LIST CSM_VARCHAR_LIST;
L_RETURN_STATUS       VARCHAR2(200);
L_ERROR_MESSAGE       VARCHAR2(2000);
L_AUD_RETURN_STATUS   VARCHAR2(200);
L_AUD_ERROR_MESSAGE   VARCHAR2(2000);
L_USER_ID             NUMBER;
L_FUNCTION_NAME 	    VARCHAR2(240);
L_DUMMY               NUMBER;

L_DOCUMENT_ID           FND_DOCUMENTS.DOCUMENT_ID%TYPE;
L_DATA_TYPE_ID          FND_DOCUMENTS.DATATYPE_ID%TYPE;
L_CATEGORY_ID           FND_DOCUMENTS.CATEGORY_ID%TYPE;
L_URL                   FND_DOCUMENTS.URL%TYPE;
L_MEDIA_ID              FND_DOCUMENTS.MEDIA_ID%TYPE;
L_FILE_NAME             FND_DOCUMENTS.FILE_NAME%TYPE;
L_ACTION_ID             FND_DOCUMENTS.MEDIA_ID%TYPE;

L_DESCRIPTION           FND_DOCUMENTS_TL.DESCRIPTION%TYPE;
L_LANGUAGE              FND_DOCUMENTS_TL.LANGUAGE%TYPE;
L_TEXT                  FND_DOCUMENTS_LONG_TEXT.LONG_TEXT%TYPE;
L_TITLE                 FND_DOCUMENTS_TL.TITLE%TYPE;

L_ENTITY_NAME           FND_ATTACHED_DOCUMENTS.ENTITY_NAME%TYPE;
L_PK1_VALUE             FND_ATTACHED_DOCUMENTS.PK1_VALUE%TYPE;
L_PK2_VALUE             FND_ATTACHED_DOCUMENTS.PK2_VALUE%TYPE;
L_PK3_VALUE             FND_ATTACHED_DOCUMENTS.PK3_VALUE%TYPE;
L_PK4_VALUE             FND_ATTACHED_DOCUMENTS.PK4_VALUE%TYPE;
L_PK5_VALUE             FND_ATTACHED_DOCUMENTS.PK5_VALUE%TYPE;
L_SEQ_NUM               FND_ATTACHED_DOCUMENTS.SEQ_NUM%TYPE;
L_ATTACHED_DOCUMENT_ID  FND_ATTACHED_DOCUMENTS.ATTACHED_DOCUMENT_ID%TYPE;
L_ACTION                FND_ATTACHED_DOCUMENTS.ATTACHED_DOCUMENT_ID%TYPE;

L_LOB_FILE_ID                 FND_LOBS.FILE_ID%TYPE;
L_LOB_FILE_NAME               FND_LOBS.FILE_NAME%TYPE;
L_LOB_FILE_CONTENT_TYPE       FND_LOBS.FILE_CONTENT_TYPE%TYPE;
L_LOB_FILE_DATA               FND_LOBS.FILE_DATA%TYPE;
L_LOB_UPLOAD_DATE             FND_LOBS.UPLOAD_DATE%TYPE;
L_LOB_EXPIRATION_DATE         FND_LOBS.EXPIRATION_DATE%TYPE;
L_LOB_PROGRAM_NAME            FND_LOBS.PROGRAM_NAME%TYPE;
L_LOB_PROGRAM_TAG             FND_LOBS.PROGRAM_TAG%TYPE;
L_LOB_LANGUAGE                FND_LOBS.LANGUAGE%TYPE;
L_LOB_ORACLE_CHARSET          FND_LOBS.ORACLE_CHARSET%TYPE;
L_LOB_FILE_FORMAT             FND_LOBS.FILE_FORMAT%TYPE;

Cursor C_Get_Aux_Objects(C_Payload_Id Number)
Is
SELECT HA_PAYLOAD_ID,
       OBJECT_NAME,
       DML_TYPE
From   Csm_Ha_Payload_Data
Where  Parent_Payload_Id = C_Payload_Id
AND    HA_PAYLOAD_ID <> PARENT_PAYLOAD_ID
ORDER BY HA_PAYLOAD_ID ASC;

CURSOR C_GET_ATTACHMENT(C_ATTACHED_DOCUMENT_ID NUMBER)
IS
SELECT ATTACHED_DOCUMENT_ID
FROM   FND_ATTACHED_DOCUMENTS
Where  ATTACHED_DOCUMENT_ID= C_ATTACHED_DOCUMENT_ID;

l_Aux_Name_List   Csm_Varchar_List;
l_aux_Value_List  Csm_Varchar_List;

BEGIN

  CSM_UTIL_PKG.LOG('Entering CSM_LOBS_PKG.APPLY_HA_INSERT for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_LOBS_PKG.APPLY_HA_INSERT',FND_LOG.LEVEL_PROCEDURE);

   -- Initialization
l_HA_PAYLOAD_ID   := p_HA_PAYLOAD_ID;
L_COL_NAME_LIST   := P_COL_NAME_LIST;
L_COL_VALUE_LIST  := P_COL_VALUE_LIST;
L_RETURN_STATUS   := FND_API.G_RET_STS_SUCCESS;

--Process Aux Objects
  For R_Get_Aux_Objects In C_Get_Aux_Objects(P_Ha_Payload_Id)  Loop

    CSM_HA_PROCESS_PKG.Parse_Xml(P_Ha_Payload_Id =>R_Get_Aux_Objects.Ha_Payload_Id,
                        X_Col_Name_List  => l_Aux_Name_List,
                        x_COL_VALUE_LIST => l_Aux_Value_List,
                        X_Con_Name_List  => L_CON_NAME_LIST,
                        x_COn_VALUE_LIST => L_CON_VALUE_LIST,
                        X_Return_Status  => L_Return_Status,
                        X_ERROR_MESSAGE  => L_ERROR_MESSAGE);
    IF L_RETURN_STATUS = FND_API.G_RET_STS_SUCCESS THEN

      IF R_GET_AUX_OBJECTS.OBJECT_NAME = 'FND_DOCUMENTS_TL' THEN
           If  L_Return_Status = Fnd_Api.G_Ret_Sts_Success And  L_Aux_Name_List.Count > 0 Then
            FOR I IN 1..L_AUX_NAME_LIST.COUNT-1 LOOP
              IF  L_AUX_NAME_LIST(I) = 'DESCRIPTION' THEN
                L_DESCRIPTION := L_AUX_VALUE_LIST(I);
              ELSIF  L_AUX_NAME_LIST(I) = 'TITLE' THEN
                L_TITLE := L_AUX_VALUE_LIST(I);
              END IF;
            END LOOP;
           END IF;
      ELSIF R_GET_AUX_OBJECTS.OBJECT_NAME = 'FND_ATTACHED_DOCUMENTS' THEN
           If  L_Return_Status = Fnd_Api.G_Ret_Sts_Success And  L_Aux_Name_List.Count > 0 Then
            FOR I IN 1..L_AUX_NAME_LIST.COUNT-1 LOOP
              IF L_AUX_NAME_LIST(I) = 'ENTITY_NAME' THEN
                L_ENTITY_NAME := L_AUX_VALUE_LIST(I);
              ELSIF  L_AUX_NAME_LIST(I) = 'PK1_VALUE' THEN
                L_PK1_VALUE := L_AUX_VALUE_LIST(I);
              ELSIF  L_AUX_NAME_LIST(I) = 'PK2_VALUE' THEN
                L_PK2_VALUE := L_AUX_VALUE_LIST(I);
              ELSIF  L_AUX_NAME_LIST(I) = 'PK3_VALUE' THEN
                L_PK3_VALUE := L_AUX_VALUE_LIST(I);
              ELSIF  L_AUX_NAME_LIST(I) = 'PK4_VALUE' THEN
                L_PK4_VALUE := L_AUX_VALUE_LIST(I);
              ELSIF  L_AUX_NAME_LIST(I) = 'PK5_VALUE' THEN
                L_PK5_VALUE := L_AUX_VALUE_LIST(I);
              ELSIF  L_AUX_NAME_LIST(I) = 'SEQ_NUM' THEN
                L_SEQ_NUM := L_AUX_VALUE_LIST(I);
              ELSIF  L_AUX_NAME_LIST(I) = 'ATTACHED_DOCUMENT_ID' THEN
                L_ATTACHED_DOCUMENT_ID := L_AUX_VALUE_LIST(I);
              END IF;
            END LOOP;
           END IF;
      ELSIF R_GET_AUX_OBJECTS.OBJECT_NAME = 'FND_DOCUMENTS_SHORT_TEXT' THEN
           If  L_Return_Status = Fnd_Api.G_Ret_Sts_Success And  L_Aux_Name_List.Count > 0 Then
            FOR I IN 1..L_AUX_NAME_LIST.COUNT-1 LOOP
              IF L_AUX_NAME_LIST(I) = 'SHORT_TEXT' THEN
                L_TEXT := L_AUX_VALUE_LIST(I);
              END IF;
            END LOOP;
           END IF;
      ELSIF R_GET_AUX_OBJECTS.OBJECT_NAME = 'FND_DOCUMENTS_LONG_TEXT' THEN
           If  L_Return_Status = Fnd_Api.G_Ret_Sts_Success And  L_Aux_Name_List.Count > 0 Then
            FOR I IN 1..L_AUX_NAME_LIST.COUNT-1 LOOP
              IF L_AUX_NAME_LIST(I) = 'LONG_TEXT' THEN
                L_TEXT := L_AUX_VALUE_LIST(I);
              END IF;
            END LOOP;
           END IF;
      ELSIF R_GET_AUX_OBJECTS.OBJECT_NAME = 'FND_LOBS' THEN
           If  L_Return_Status = Fnd_Api.G_Ret_Sts_Success And  L_Aux_Name_List.Count > 0 Then
            FOR I IN 1..L_AUX_NAME_LIST.COUNT-1 LOOP
              IF L_AUX_NAME_LIST(I) = 'FILE_ID' THEN
                L_LOB_FILE_ID := L_AUX_VALUE_LIST(I);
              ELSIF  L_AUX_NAME_LIST(I) = 'FILE_NAME' THEN
                L_LOB_FILE_NAME := L_AUX_VALUE_LIST(I);
              ELSIF  L_AUX_NAME_LIST(I) = 'FILE_CONTENT_TYPE' THEN
                L_LOB_FILE_CONTENT_TYPE := L_AUX_VALUE_LIST(I);
              ELSIF  L_AUX_NAME_LIST(I) = 'UPLOAD_DATE' THEN
                L_LOB_UPLOAD_DATE := L_AUX_VALUE_LIST(I);
              ELSIF  L_AUX_NAME_LIST(I) = 'EXPIRATION_DATE' THEN
                L_LOB_EXPIRATION_DATE := L_AUX_VALUE_LIST(I);
              ELSIF  L_AUX_NAME_LIST(I) = 'PROGRAM_NAME' THEN
                L_LOB_PROGRAM_NAME := L_AUX_VALUE_LIST(I);
              ELSIF  L_AUX_NAME_LIST(I) = 'PROGRAM_TAG' THEN
                L_LOB_PROGRAM_TAG := L_AUX_VALUE_LIST(I);
              ELSIF  L_AUX_NAME_LIST(I) = 'LANGUAGE' THEN
                L_LOB_LANGUAGE := L_AUX_VALUE_LIST(I);
              ELSIF  L_AUX_NAME_LIST(I) = 'ORACLE_CHARSET' THEN
                L_LOB_ORACLE_CHARSET := L_AUX_VALUE_LIST(I);
              ELSIF  L_AUX_NAME_LIST(I) = 'FILE_FORMAT' THEN
                L_LOB_FILE_FORMAT := L_AUX_VALUE_LIST(I);
              END IF;
            END LOOP;
           END IF;
      END IF;

    END IF;--PARSE SUCCESS
    If L_Aux_Name_List.Count > 0 Then
      L_Aux_Name_List.DELETE;
    End If;
    If L_Aux_Value_List.Count > 0 Then
      L_AUX_VALUE_LIST.DELETE;
    END IF;

  END LOOP;

---GET FND DOCUMENTS DATA
  FOR I IN 1..L_COL_NAME_LIST.COUNT-1 LOOP

    IF  L_COL_VALUE_LIST(I) IS NOT NULL THEN
      IF L_COL_NAME_LIST(I) = 'DOCUMENT_ID' THEN
        L_DOCUMENT_ID := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'DATATYPE_ID' THEN
        L_DATA_TYPE_ID := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'CATEGORY_ID' THEN
        L_CATEGORY_ID  := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'URL' THEN
        L_URL := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'MEDIA_ID' THEN
        L_MEDIA_ID := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'FILE_NAME' THEN
        L_FILE_NAME := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CREATED_BY' THEN
        L_USER_ID := L_COL_VALUE_LIST(I);
      END IF;

     END IF;
  END LOOP;

  --check whether the given change is update or insert
OPEN  C_GET_ATTACHMENT (L_ATTACHED_DOCUMENT_ID);
FETCH C_GET_ATTACHMENT INTO L_ACTION;
CLOSE C_GET_ATTACHMENT;

  	IF L_ENTITY_NAME = 'JTF_TASKS_B' THEN --function name is the Name of the Form in which the attachment is displayed
  		L_FUNCTION_NAME		:= 'JTFTKMAN';
  	ELSIF L_ENTITY_NAME = 'CS_INCIDENTS' THEN
  		L_FUNCTION_NAME		:= 'CSXSRISR';
  	ELSIF L_ENTITY_NAME = 'CSF_DEBRIEF_HEADERS' THEN
  		L_FUNCTION_NAME		:= 'CSFFEDBF';
  	END IF;
    --if this is a lobs attachment insert directly into fnd_lobs
    IF L_DATA_TYPE_ID = 6 THEN
      BEGIN
        INSERT INTO FND_LOBS(FILE_ID, FILE_NAME, FILE_CONTENT_TYPE,
                      FILE_DATA, UPLOAD_DATE, EXPIRATION_DATE,
                      PROGRAM_NAME, PROGRAM_TAG, LANGUAGE,
                      ORACLE_CHARSET,FILE_FORMAT)
        VALUES        (L_LOB_FILE_ID, L_LOB_FILE_NAME, L_LOB_FILE_CONTENT_TYPE,
                      G_FILE_ATTACHMENT, L_LOB_UPLOAD_DATE, L_LOB_EXPIRATION_DATE,
                      L_LOB_PROGRAM_NAME, L_LOB_PROGRAM_TAG, L_LOB_LANGUAGE,
                      L_LOB_ORACLE_CHARSET,L_LOB_FILE_FORMAT);
      EXCEPTION
        WHEN OTHERS THEN
          OPEN  L_LOBS_FILEID_CSR(L_LOB_FILE_ID) ;
          FETCH L_LOBS_FILEID_CSR INTO L_DUMMY;
          IF L_LOBS_FILEID_CSR%FOUND THEN
	         --the record exists. Dont show any error.
             null;
          ELSE
             --record could not be inserted, throw the exception
             X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
           END IF;
           CLOSE L_LOBS_FILEID_CSR;
      END; --begin end
    END IF; --data type id

  IF L_RETURN_STATUS = FND_API.G_RET_STS_SUCCESS THEN
    --After inserting the lobs into fnd_lobs table the attachment is added to the corresponding
    --Entity ie to task or Debrief or SR we need to call the following API
    IF L_ACTION IS NULL THEN
      FND_WEBATTCH.ADD_ATTACHMENT(
        SEQ_NUM 			      => L_SEQ_NUM,
        CATEGORY_ID 		    => L_CATEGORY_ID,
        DOCUMENT_DESCRIPTION=> L_DESCRIPTION,  --l_signed_date||' '||l_signed_by,
        DATATYPE_ID 		    => L_DATA_TYPE_ID,
        TEXT			          => L_TEXT,
        FILE_NAME 		      => L_FILE_NAME,
        URL                 => L_URL,
        FUNCTION_NAME 		  => L_FUNCTION_NAME,
        ENTITY_NAME 		    => L_ENTITY_NAME,
        PK1_VALUE 		      => L_PK1_VALUE,
        PK2_VALUE		        => L_PK2_VALUE,
        PK3_VALUE		        => L_PK3_VALUE,
        PK4_VALUE		        => L_PK4_VALUE,
        PK5_VALUE		        => L_PK5_VALUE,
        MEDIA_ID 			      => L_MEDIA_ID,
        USER_ID 			      => L_USER_ID, --fnd_global.login_id
        TITLE               => L_TITLE);

        X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
    ELSE
        X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
        X_ERROR_MESSAGE := 'Update of Attachments are not supported.Please ignore the record.';
    END IF;

  ELSE
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    X_ERROR_MESSAGE := 'File Attachment Failed.';
  END IF;
    CSM_UTIL_PKG.LOG('Leaving CSM_LOBS_PKG.APPLY_HA_INSERT for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_LOBS_PKG.APPLY_HA_INSERT',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION WHEN OTHERS THEN
     CSM_UTIL_PKG.log( 'Exception in CSM_LOBS_PKG.APPLY_HA_INSERT: ' || sqlerrm
               || ' for HA ID ' || p_HA_PAYLOAD_ID ,'CSM_LOBS_PKG.APPLY_HA_INSERT',FND_LOG.LEVEL_EXCEPTION);
  X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
  X_ERROR_MESSAGE := SUBSTR(1,2000,SQLERRM);

END APPLY_HA_INSERT;

PROCEDURE APPLY_HA_CHANGES
          (p_HA_PAYLOAD_ID  IN  NUMBER,
           P_COL_NAME_LIST  IN  CSM_VARCHAR_LIST,
           p_COL_VALUE_LIST IN  CSM_VARCHAR_LIST,
           p_dml_type       IN  VARCHAR2,
           x_RETURN_STATUS  OUT NOCOPY VARCHAR2,
           x_ERROR_MESSAGE  OUT NOCOPY VARCHAR2
         )IS
L_RETURN_STATUS  VARCHAR2(100);
l_ERROR_MESSAGE  VARCHAR2(4000);
BEGIN
  /*** initialize return status and message list ***/
  L_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.INITIALIZE;

  CSM_UTIL_PKG.LOG('Entering CSM_LOBS_PKG.APPLY_HA_CHANGES for Payload ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_LOBS_PKG.APPLY_HA_CHANGES',FND_LOG.LEVEL_PROCEDURE);

  IF p_dml_type ='I' THEN
    -- Process insert
            APPLY_HA_INSERT
                (p_HA_PAYLOAD_ID  =>p_HA_PAYLOAD_ID,
                p_COL_NAME_LIST  => P_COL_NAME_LIST,
                p_COL_VALUE_LIST => p_COL_VALUE_LIST,
                x_RETURN_STATUS  => l_RETURN_STATUS,
                x_ERROR_MESSAGE  => l_ERROR_MESSAGE
              );
  ELSIF P_DML_TYPE ='U' THEN
    --Update Not Supported
    -- Process update
/*            APPLY_HA_UPDATE
                (p_HA_PAYLOAD_ID  =>p_HA_PAYLOAD_ID,
                p_COL_NAME_LIST  => P_COL_NAME_LIST,
                p_COL_VALUE_LIST => p_COL_VALUE_LIST,
                x_RETURN_STATUS  => l_RETURN_STATUS,
                X_ERROR_MESSAGE  => L_ERROR_MESSAGE
              );
 */
  NULL;
  END IF;

  X_RETURN_STATUS := l_RETURN_STATUS;
  x_ERROR_MESSAGE := l_ERROR_MESSAGE;
  CSM_UTIL_PKG.LOG('Leaving CSM_LOBS_PKG.APPLY_HA_CHANGES for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_LOBS_PKG.APPLY_HA_CHANGES',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION WHEN OTHERS THEN
  CSM_UTIL_PKG.log( 'Exception in CSM_LOBS_PKG.APPLY_HA_CHANGES: ' || sqlerrm
               || ' for HA ID ' || p_HA_PAYLOAD_ID ,'CSM_LOBS_PKG.APPLY_HA_CHANGES',FND_LOG.LEVEL_EXCEPTION);
  X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
  X_ERROR_MESSAGE := TO_CHAR(SQLERRM,2000);

END APPLY_HA_CHANGES;

END CSM_LOBS_PKG;

/
