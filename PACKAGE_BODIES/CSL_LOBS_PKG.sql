--------------------------------------------------------
--  DDL for Package Body CSL_LOBS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSL_LOBS_PKG" AS
/* $Header: cslvlobb.pls 120.0 2005/05/24 17:51:22 appldev noship $ */

  error EXCEPTION;

  /*** Globals ***/
  g_object_name  CONSTANT VARCHAR2(30) := 'CSL_LOBS_PKG';  -- package name
  g_pub_name     CONSTANT VARCHAR2(30) := 'CSL_LOBS';  -- publication item name
  g_debug_level           NUMBER; -- debug level

  CURSOR C_FND_LOBS( b_user_name VARCHAR2, b_tranid NUMBER) is
    SELECT *
    FROM  CSL_LOBS_INQ
    WHERE tranid$$ = b_tranid
    AND   clid$$cs = b_user_name;

  /***
  This procedure is called by APPLY_RECORD when an inserted record is to be
  processed.
  ***/

  PROCEDURE APPLY_INSERT
  (
           p_record        IN C_FND_LOBS%ROWTYPE,
           p_error_msg     OUT NOCOPY    VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2
  ) IS

    -- Variables needed for public API
    l_seq_num			number;
    l_category_id		number;
    l_file_id			number;
    l_debrief_header_id	number;
    l_msg_count NUMBER;
    l_msg_data  VARCHAR2(240);
    l_file_access_id number;
    l_error_msg varchar(1024);

    -- get the debrief header id for the task_assignment
    -- use the first debrief header id
    CURSOR l_debrief_header_id_csr(p_task_assignment_id IN number) IS
      SELECT debrief_header_id FROM  csf_debrief_headers
      WHERE task_assignment_id = p_task_assignment_id
      ORDER BY debrief_header_id;

    -- get max seq no for the debrief_header_id
    CURSOR l_max_seq_no_csr(p_debrief_header_id IN number)
    IS
    SELECT  nvl(max(fad.seq_num),0)+10
      FROM  fnd_attached_documents fad, fnd_documents fd
      WHERE  fad.pk1_value=to_char(p_debrief_header_id)
      AND    fd.document_id = fad.document_id
      AND EXISTS
         (SELECT 1
          FROM fnd_document_categories_tl cat_tl
          WHERE cat_tl.category_id = fd.category_id
          AND cat_tl.user_name = 'Signature'
          );

    -- get the category_id
    CURSOR l_category_id_csr IS
    SELECT category_id FROM  fnd_document_categories_tl
       WHERE user_name = 'Signature';

    l_dummy number;
    -- to check if the record exists in the database
    CURSOR l_lobs_fileid_csr (p_file_id fnd_lobs.file_id%TYPE) IS
    SELECT 1 FROM fnd_lobs WHERE file_id = p_file_id;

    l_signature_loc blob;
    l_signature_raw raw(32767);
    l_signature_size number;

  BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_error_msg := 'Entering ' || g_object_name || '.APPLY_INSERT'
                   || ' for PK ' || to_char( p_record.FILE_ID);

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => p_record.file_id
      , v_object_name => g_object_name
      , v_message     => l_error_msg
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

    -- if debrief_header_id is not passed get the debrief header id
    IF ( (p_record.pk1_value IS NULL) AND
         (p_record.task_assignment_id IS NOT NULL) )
    THEN
      OPEN l_debrief_header_id_csr(p_record.task_assignment_id);
      FETCH l_debrief_header_id_csr INTO l_debrief_header_id;
      CLOSE l_debrief_header_id_csr;
    ELSE
      l_debrief_header_id := TO_NUMBER (p_record.pk1_value);
    END IF;

    -- get the max seq no
    OPEN l_max_seq_no_csr(l_debrief_header_id);
    FETCH l_max_seq_no_csr INTO l_seq_num;
    CLOSE l_max_seq_no_csr;

    -- get the category id for Signature
    OPEN l_category_id_csr;
    FETCH l_category_id_csr INTO l_category_id;
    CLOSE l_category_id_csr;

  -- API to  create an attachment

  --verify that the record does not already exist
  OPEN l_lobs_fileid_csr(p_record.file_id) ;
  FETCH l_lobs_fileid_csr into l_dummy;
  IF l_lobs_fileid_csr%found THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    p_error_msg := 'Duplicate Record: File id ' || to_char(p_record.file_id)
                  || ' already exists in fnd_lobs table';

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => p_record.file_id
      , v_object_name => g_object_name
      , v_message     => p_error_msg
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;

    CLOSE l_lobs_fileid_csr;
    RETURN;
  END IF;
  CLOSE l_lobs_fileid_csr;

  BEGIN
    INSERT INTO fnd_lobs(
        file_id, file_name, file_content_type,  file_data,
        upload_date, language, file_format)
    VALUES (p_record.file_id, 'INTERNAL', 'image/bmp', empty_blob(),
        SYSDATE, p_record.language, 'binary')
    RETURN file_data into l_signature_loc;

    l_signature_size := dbms_lob.getLength(p_record.file_data);
    dbms_lob.read(p_record.file_data, l_signature_size, 1, l_signature_raw);

    dbms_lob.write(l_signature_loc, l_signature_size, 1, l_signature_raw);
  EXCEPTION
     WHEN OTHERS THEN
      -- check if the record exists
        open l_lobs_fileid_csr(p_record.file_id) ;
	    fetch l_lobs_fileid_csr into l_dummy;
	    if l_lobs_fileid_csr%found then
	       --the record exists. Dont show any error.
           null;
        else
          --record could not be inserted, throw the exception
          x_return_status := FND_API.G_RET_STS_ERROR;
          raise;
        end if;
	    close l_lobs_fileid_csr;

  END;
  fnd_webattch.add_attachment(
    seq_num 			=> l_seq_num,
    category_id 		=> l_category_id,
    document_description        => p_record.description,
    datatype_id 		=> 6,
    text			=> NULL,
    file_name 		        => 'INTERNAL',
    url                         => NULL,
    function_name 		=> 'CSFFEDBF',
    entity_name 		=> 'CSF_DEBRIEF_HEADERS',
    pk1_value 		        => l_debrief_header_id,
    pk2_value		        => NULL,
    pk3_value		        => NULL,
    pk4_value		        => NULL,
    pk5_value		        => NULL,
    media_id 			=> p_record.file_id,
    user_id 			=> fnd_global.login_id);


    l_error_msg :=  'Leaving ' || g_object_name || '.APPLY_INSERT'
            || ' for PK ' || to_char (p_record.FILE_ID );

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => p_record.file_id
      , v_object_name => g_object_name
      , v_message     => l_error_msg
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;


  EXCEPTION
    WHEN OTHERS THEN

       l_error_msg :=  'Exception occurred in ' || g_object_name
                       || '.APPLY_INSERT:' || ' ' || sqlerrm
                       || ' for PK ' || to_char (p_record.FILE_ID );

       IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
         jtm_message_log_pkg.Log_Msg
         ( v_object_id   => p_record.file_id
         , v_object_name => g_object_name
         , v_message     => l_error_msg
         , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
       END IF;

       fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_INSERT', sqlerrm);

       p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
         (
           p_api_error      => TRUE
         );

       l_error_msg := 'Leaving ' || g_object_name || '.APPLY_INSERT'
                      || ' for PK ' || to_char (p_record.FILE_ID );

       IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
         jtm_message_log_pkg.Log_Msg
         ( v_object_id   => p_record.file_id
         , v_object_name => g_object_name
         , v_message     => l_error_msg
         , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
       END IF;

    x_return_status := FND_API.G_RET_STS_ERROR;
  END APPLY_INSERT;


  /***
  This procedure is called by APPLY_CLIENT_CHANGES for every record in
  in-queue that needs to be processed.
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


  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.file_id
    , v_object_name => g_object_name
    , v_message     => 'Entering ' || g_object_name || '.APPLY_RECORD'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  l_error_msg := 'Processing ' || g_object_name || ' for PK '
                 || to_char (p_record.FILE_ID) || ' ' || 'DMLTYPE = '
                 || p_record.dmltype$$ ;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.file_id
    , v_object_name => g_object_name
    , v_message     => l_error_msg
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

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

    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.file_id
    , v_object_name => g_object_name
    , v_message     => l_error_msg
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);

    p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_message        => 'CSL_DML_OPERATION'
      , p_token_name1    => 'DML'
      , p_token_value1   => p_record.dmltype$$
      );

    x_return_status := FND_API.G_RET_STS_ERROR;

  ELSIF p_record.dmltype$$='D' THEN
    -- Process delete; not supported for this entity

    l_error_msg := 'Delete is not supported for this entity ' || g_object_name ;

    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.file_id
    , v_object_name => g_object_name
    , v_message     => l_error_msg
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);

    p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_message        => 'CSL_DML_OPERATION'
      , p_token_name1    => 'DML'
      , p_token_value1   => p_record.dmltype$$
      );

    x_return_status := FND_API.G_RET_STS_ERROR;
  ELSE
    -- invalid dml type

    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
       jtm_message_log_pkg.Log_Msg
      ( v_object_id   => p_record.task_assignment_id
      , v_object_name => g_object_name
      , v_message     => 'Invalid DML type: ' || p_record.dmltype$$
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
    END IF;

    p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_message        => 'CSL_DML_OPERATION'
      , p_token_name1    => 'DML'
      , p_token_value1   => p_record.dmltype$$
      );

    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.file_id
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.APPLY_RECORD'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;


EXCEPTION WHEN OTHERS THEN
  /*** defer record when any process exception occurs ***/

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.file_id
    , v_object_name => g_object_name
    , v_message     => 'Exception occurred in APPLY_RECORD:' || fnd_global.local_chr(10) || sqlerrm
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;

  fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_RECORD', sqlerrm);
  p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
    (
      p_api_error      => TRUE
    );

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.file_id
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.APPLY_RECORD'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_RECORD;


/***
  This procedure is called by CSL_SERVICEL_WRAPPER_PKG when publication
  item CSL_LOBS is dirty. This happens when a mobile field service device
  executed DML on an updatable table and did a fast sync. This procedure
  will insert the data that came from mobile into the backend tables using
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

  jtm_message_log_pkg.Log_Msg
  ( v_object_id   => null
    , v_object_name => g_object_name
    , v_message     => 'Entering ' || g_object_name || '.APPLY_INSERT'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
  );

  /*** loop through CSL_LOBS records in inqueue ***/
  FOR r_FND_LOBS IN C_FND_LOBS( p_user_name, p_tranid) LOOP

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
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( v_object_id   => r_fnd_lobs.task_assignment_id
        , v_object_name => g_object_name
        , v_message     => 'Record successfully processed, deleting from inqueue'
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;


      CSL_SERVICEL_WRAPPER_PKG.DELETE_RECORD
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
        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
          jtm_message_log_pkg.Log_Msg
          ( v_object_id   => r_FND_LOBS.task_assignment_id
          , v_object_name => g_object_name
          , v_message     => 'Deleting from inqueue failed, rolling back to savepoint'
          , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
        END IF;

        ROLLBACK TO save_rec;
      END IF;
    END IF;

    IF l_process_Status <> FND_API.G_RET_STS_SUCCESS THEN
      /*** Record was not processed successfully or delete failed
           -> defer and reject record ***/

        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
          jtm_message_log_pkg.Log_Msg
          ( v_object_id   => r_FND_LOBS.task_assignment_id
          , v_object_name => g_object_name
          , v_message     => 'Deleting from inqueue failed, rolling back to savepoint'
          , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
        END IF;

      CSL_SERVICEL_WRAPPER_PKG.DEFER_RECORD
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
        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
          jtm_message_log_pkg.Log_Msg
          ( v_object_id   => r_FND_LOBS.task_assignment_id
          , v_object_name => g_object_name
          , v_message     => 'Defer record failed, rolling back to savepoint'
          , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
        END IF;

        ROLLBACK TO save_rec;
      END IF;
    END IF;

  END LOOP;


  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.Apply_Client_Changes'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;


EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => g_object_name
    , v_message     => 'Exception occurred in APPLY_CLIENT_CHANGES:' || fnd_global.local_chr(10) || sqlerrm
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;

  x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_CLIENT_CHANGES;

END CSL_LOBS_PKG;

/
