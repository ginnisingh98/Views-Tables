--------------------------------------------------------
--  DDL for Package Body ECX_ATTACHMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECX_ATTACHMENT" AS
-- $Header: ECXATCHB.pls 120.2 2006/05/24 16:05:25 susaha ship $

l_procedure          PLS_INTEGER := ecx_debug.g_procedure;
l_statement          PLS_INTEGER := ecx_debug.g_statement;
l_unexpected         PLS_INTEGER := ecx_debug.g_unexpected;
l_procedureEnabled   boolean     := ecx_debug.g_procedureEnabled;
l_statementEnabled   boolean     := ecx_debug.g_statementEnabled;
l_unexpectedEnabled  boolean     := ecx_debug.g_unexpectedEnabled;

-- private variables, types and functions
EMBEDDED_PROGRAM_NAME          CONSTANT VARCHAR2(32)   := 'ECX_ATTACHMENT';
EMBEDDED_PROGRAM_TAG           CONSTANT VARCHAR2(32)   := 'ECX_ATTACHMENT';
EMBEDDED_FND_KEY1              CONSTANT VARCHAR2(100)  := 'ECX_ATTACHMENT_KEY1';
EMBEDDED_ECX_ENTITY_NAME       CONSTANT VARCHAR2(40)   := 'ECX_ATTACHMENT_ENTITY';
EMBEDDED_FND_SEQ_INIT          CONSTANT NUMBER         := 88;
EMBEDDED_FND_SEQ_INTERVAL      CONSTANT NUMBER         := 10;

ATTACHMENT_RECORD_DELIMITOR    CONSTANT VARCHAR2(1)    := '!';
ATTACHMENT_FIELD_DELIMITOR     CONSTANT VARCHAR2(1)    := ':';
ATTACHMENT_CID_DELIMITOR       CONSTANT VARCHAR2(1)    := '@';

-- Temporary place to hold attachment reference maps for offline (BES) cases
i_attachment_maps              VARCHAR2(2000) := NULL;

TYPE attachment_record_type IS RECORD (cid         VARCHAR2(256),
                                       fid         NUMBER,
                                       dataType    NUMBER);

TYPE attachment_records_type IS TABLE OF attachment_record_type INDEX BY BINARY_INTEGER;


PROCEDURE get_attachment_records(
                     i_attachments   IN         VARCHAR2,
                     x_records       OUT NOCOPY attachment_records_type);

-- public procedures
PROCEDURE deposit_blob_attachment(
             i_main_doc_id           IN OUT NOCOPY NUMBER,
             i_file_name             IN       VARCHAR2,
             i_file_content_type     IN       VARCHAR2   DEFAULT NULL,
             i_file_data             IN       BLOB,
             i_expire_date           IN       DATE,
             i_lang                  IN       VARCHAR2,
             i_ora_charset           IN       VARCHAR2,
             i_file_format           IN       VARCHAR2   DEFAULT NULL,
             x_file_id               OUT NOCOPY NUMBER
)  AS

  i_method_name   varchar2(2000) := 'ecx_attachment.deposit_blob_attachment';
  l_org_id                     VARCHAR2(60);
  l_cur_doc_id                 NUMBER := NULL;
  l_security_id                NUMBER := NULL;
  l_attached_id                NUMBER := NULL;
  l_program_app_id             NUMBER := 0;   -- ??????????
  l_program_id                 NUMBER := 0;   -- ??????????
  l_request_id                 NUMBER := 0;   -- ?????????
  l_seq_num                    NUMBER := 0;
  l_row_id_tmp                 VARCHAR2(30) := NULL;
  l_main_row_id                VARCHAR2(30) := NULL;
  l_main_media_id              NUMBER := NULL;
  l_install_mode               VARCHAR2(200) := NULL;
  l_progress                   VARCHAR2(4) := NULL;
  l_program_name               VARCHAR2(32) := EMBEDDED_PROGRAM_NAME;
  l_program_tag                VARCHAR2(32) := EMBEDDED_PROGRAM_TAG;
  l_category_id_tmp            NUMBER;
  l_language_tmp               VARCHAR2(30);
  l_dynamic_sql_str0           VARCHAR2(2000) := NULL;
  l_dynamic_sql_str1           VARCHAR2(2000) := NULL;
  l_dynamic_sql_str2           VARCHAR2(2000) := NULL;
  l_dynamic_sql_str3           VARCHAR2(2000) := NULL;
  l_dynamic_sql_str4           VARCHAR2(2000) := NULL;
  l_dynamic_sql_str5           VARCHAR2(2000) := NULL;
  l_dynamic_sql_str6           VARCHAR2(2000) := NULL;
  l_dynamic_sql_str7           VARCHAR2(2000) := NULL;
  l_description_tmp            VARCHAR2(255) := 'main doc for ECX to deposit attachment files';
  mode_not_support             EXCEPTION;

BEGIN

  if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
  end if;
  if(l_statementEnabled) then
     ecx_debug.log(l_statement,'i_main_doc_id', i_main_doc_id,i_method_name);
     ecx_debug.log(l_statement,'i_file_content_type', i_file_content_type,i_method_name);
     ecx_debug.log(l_statement,'i_file_format', i_file_format,i_method_name);
  end if;

  -- Check mode
  -- ecx_utils.g_install_mode := wf_core.translate('WF_INSTALL');
  -- IF (ecx_utils.g_install_mode = 'EMBEDDED') THEN

  l_install_mode := wf_core.translate('WF_INSTALL');
  IF (l_install_mode  = 'EMBEDDED') THEN

    -- Insert a record in fnd_documents representing the current
    -- attachment
    l_progress := '0000';
    l_category_id_tmp := 33;
    l_language_tmp := i_lang;

    l_dynamic_sql_str1 := 'BEGIN fnd_profile.get('||'''ORG_ID'''||', :orgId); END;';
    EXECUTE IMMEDIATE l_dynamic_sql_str1 USING OUT l_org_id;

    l_security_id := TO_NUMBER(l_org_id);

    l_dynamic_sql_str2 := 'BEGIN
                            fnd_documents_pkg.insert_row(:1,:2,:3,:4,:5,:6,
                                                         :7,:8,:9,:10,:11,:12,
                                                         NULL,
                                                         NULL,
                                                         :13,
                                                         NULL,
                                                         NULL,
                                                         NULL,
                                                         NULL,
                                                         NULL,
                                                         :14,
                                                         :15,
                                                         :16,
                                                         NULL,
                                                         :17,
                                                         NULL, NULL, NULL, NULL,
                                                         NULL, NULL, NULL, NULL,
                                                         NULL, NULL, NULL, NULL,
                                                         NULL, NULL, NULL, NULL);
                          END;';

            EXECUTE IMMEDIATE l_dynamic_sql_str2
                    USING IN OUT l_row_id_tmp,
                          IN OUT l_cur_doc_id,
                          SYSDATE,
                          0,
                          SYSDATE,
                          0,
                          0,
                          ecx_attachment.EMBEDDED_LOB_DATA_TYPE,
                          l_category_id_tmp,
                          1,
                          l_security_id,
                          'Y',
                          '0',
                          SYSDATE,
                          l_language_tmp,
                          l_description_tmp,
                          IN OUT x_file_id;

      -- Insert the actual blob into the fnd_lobs table
      l_progress := '0001';
      IF (x_file_id is NULL) THEN

         l_dynamic_sql_str0 := 'SELECT fnd_lobs_s.nextval FROM dual';
         EXECUTE IMMEDIATE l_dynamic_sql_str0 INTO x_file_id;

      END IF;

      l_dynamic_sql_str3 := 'INSERT INTO fnd_lobs
                                    (file_id, file_name, file_content_type, upload_date,
                                     expiration_date, program_name, program_tag,
                                     file_data, language, oracle_charset, file_format)
                                  VALUES (:1, :2, :3, NULL, :4, :5, :6,
                                          :7, :8, :9, :10)';

      EXECUTE IMMEDIATE l_dynamic_sql_str3
              USING x_file_id, i_file_name, i_file_content_type,
                    i_expire_date, l_program_name, l_program_tag,
                    i_file_data, l_language_tmp, i_ora_charset, i_file_format;


     -- Make association between the current attachment file with its
     -- main business document in fnd_attached_documents table. Note
     -- l_cur_doc_id is the document id denoting the current attachment,
     -- while the x_file_id is the file_id of the very same attachment.
     IF (i_main_doc_id IS NULL) THEN

        -- the main doc does not exist. The mulitple attachments of
        -- a the same main doc is assoicated with the PK2_VALUE
        -- column in the fnd_attached_documents table. the value
        -- of the PK2_VALUE is obtained from the fnd_documents_s
        -- sequencer.
        l_progress := '0002';

        l_dynamic_sql_str4 := 'SELECT fnd_documents_s.nextval FROM dual';
        EXECUTE IMMEDIATE l_dynamic_sql_str4 INTO i_main_doc_id;

     END IF;

     -- Create attachment record in fnd_attached_documents now
     l_progress := '0003';
     l_dynamic_sql_str5 := 'SELECT MAX(seq_num)
                              FROM fnd_attached_documents
                             WHERE pk1_value =''' || EMBEDDED_FND_KEY1 || ''' AND
                                   entity_name =''' || EMBEDDED_ECX_ENTITY_NAME || '''';
     EXECUTE IMMEDIATE l_dynamic_sql_str5 INTO l_seq_num;

     IF l_seq_num is NULL THEN
       l_seq_num := EMBEDDED_FND_SEQ_INIT;
     ELSE
       l_seq_num := l_seq_num + EMBEDDED_FND_SEQ_INTERVAL;
     END IF;

     l_dynamic_sql_str6 := 'SELECT fnd_attached_documents_s.nextval FROM dual';
     EXECUTE IMMEDIATE  l_dynamic_sql_str6 INTO l_attached_id;

     if(l_statementEnabled) then
        ecx_debug.log(l_statement,'attached_document_id in FND_ATTACHED_DOCUMENTS', l_attached_id,i_method_name);
        ecx_debug.log(l_statement,'current_attachment_id in FND_ATTACHED_DOCUMENTS',l_cur_doc_id,i_method_name);
        ecx_debug.log(l_statement,'seq_num in FND_ATTACHED_DOCUMENTS', l_seq_num,i_method_name);
        ecx_debug.log(l_statement,'pk2_value in FND_ATTACHED_DOCUMENTS', i_main_doc_id,i_method_name);
     end if;

     l_dynamic_sql_str7 := 'INSERT INTO fnd_attached_documents
                                   (attached_document_id,
                                    document_id,
                                    creation_date,
                                    created_by,
                                    last_update_date,
                                    last_updated_by,
                                    last_update_login,
                                    seq_num,
                                    entity_name,
                                    pk1_value, pk2_value, pk3_value,
                                    pk4_value, pk5_value,
                                    automatically_added_flag,
                                    program_application_id, program_id,
                                    program_update_date, request_id,
                                    attribute_category, attribute1,
                                    attribute2, attribute3, attribute4,
                                    attribute5, attribute6, attribute7,
                                    attribute8, attribute9, attribute10,
                                    attribute11, attribute12, attribute13,
                                    attribute14, attribute15, column1)
                              VALUES
                                   (:1, :2, :3, :4, :5, :6, :7, :8, :9, :10,
                                    :11, NULL, NULL, NULL,
                                    :12, :13, :14, :15, :16,
                                    NULL, NULL, NULL, NULL,
                                    NULL, NULL, NULL, NULL,
                                    NULL, NULL, NULL, NULL,
                                    NULL, NULL, NULL, NULL,
                                    NULL)';
     EXECUTE IMMEDIATE l_dynamic_sql_str7
                 USING l_attached_id, l_cur_doc_id,
                       SYSDATE, 0, SYSDATE, 0, 0, l_seq_num,
                       EMBEDDED_ECX_ENTITY_NAME, EMBEDDED_FND_KEY1, i_main_doc_id,
                       'N', l_program_app_id, l_program_id, SYSDATE, l_request_id;

  ELSE

    -- Standalone mode is not yet supported
    RAISE mode_not_support;

  END IF; -- EMBEDDED MODE

  l_progress := '0004';

  if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
  end if;

EXCEPTION

  WHEN mode_not_support THEN

      ecx_utils.i_errbuf :=  'ECX_ATTACHMENT.DEPOSIT_BLOB_ATTACHMENT MODE NOT SUPPORT' || SQLERRM;
      ecx_utils.i_ret_code := 0;
      if(l_unexpectedEnabled) then
        ecx_debug.log(l_unexpected, ecx_utils.i_errbuf,i_method_name);
      end if;
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      RAISE ecx_utils.PROGRAM_EXIT;

  WHEN OTHERS THEN


      if(l_unexpectedEnabled) then
        ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,'PROGRESS_LEVEL',
                          'ECX_ATTACHMENT.DEPOSIT_BLOB_ATTACHMENT');
        ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
      end if;
      ecx_utils.error_type := 30;
      ecx_utils.i_ret_code := 2;
      ecx_utils.i_errbuf := SQLERRM || ' at ECX_ATTACHMENT.DEPOSIT_BLOB_ATTACHMENT';
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      RAISE ecx_utils.PROGRAM_EXIT;

END deposit_blob_attachment;


PROCEDURE formulate_content_id(
              i_file_id             IN        NUMBER,
              i_entity_name         IN        VARCHAR2,
              i_pk1_value           IN        VARCHAR2,
              i_pk2_value           IN        VARCHAR2,
              i_pk3_value           IN        VARCHAR2,
              i_pk4_value           IN        VARCHAR2,
              i_pk5_value           IN        VARCHAR2,
              x_cid                 OUT NOCOPY VARCHAR2
) AS
  i_method_name   varchar2(2000) := 'ecx_attachment.formulate_content_id';
  l_progress                   VARCHAR2(4) := NULL;
  l_file_name                  VARCHAR2(256) := NULL;
  l_dynamic_sql_str0           VARCHAR2(2000) := NULL;
  invalid_input                EXCEPTION;

BEGIN

  if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
  end if;
  if(l_statementEnabled) then
   ecx_debug.log(l_statement,'i_file_id', i_file_id,i_method_name);
   ecx_debug.log(l_statement,'i_entity_name', i_entity_name,i_method_name);
   ecx_debug.log(l_statement,'i_pk1_value', i_pk1_value,i_method_name);
   ecx_debug.log(l_statement,'i_pk2_value', i_pk2_value,i_method_name);
   ecx_debug.log(l_statement,'i_pk3_value', i_pk3_value,i_method_name);
   ecx_debug.log(l_statement,'i_pk4_value', i_pk4_value,i_method_name);
   ecx_debug.log(l_statement,'i_pk5_value', i_pk5_value,i_method_name);
 end if;

  IF (i_entity_name  IS NOT NULL) THEN

     x_cid := i_entity_name;

  ELSE

     RAISE invalid_input;

  END IF;


  x_cid := x_cid || ATTACHMENT_CID_DELIMITOR;

  IF (i_pk1_value IS NOT NULL) THEN

     x_cid := x_cid || i_pk1_value;

  END IF;

  x_cid := x_cid || ATTACHMENT_CID_DELIMITOR;

  IF (i_pk2_value IS NOT NULL) THEN

     x_cid := x_cid || i_pk2_value;

  END IF;

  x_cid := x_cid || ATTACHMENT_CID_DELIMITOR;

  IF (i_pk3_value IS NOT NULL) THEN

     x_cid := x_cid || i_pk3_value;

  END IF;

  x_cid := x_cid || ATTACHMENT_CID_DELIMITOR;


  IF (i_pk4_value IS NOT NULL) THEN

     x_cid := x_cid || i_pk4_value;

  END IF;

  x_cid := x_cid || ATTACHMENT_CID_DELIMITOR;


  IF (i_pk5_value IS NOT NULL) THEN

     x_cid := x_cid || i_pk5_value;

  END IF;

  x_cid := x_cid || ATTACHMENT_CID_DELIMITOR;

  IF (i_file_id IS NOT NULL) THEN

    x_cid := x_cid || i_file_id;
    x_cid := x_cid || ATTACHMENT_CID_DELIMITOR;

    -- append filename
    l_dynamic_sql_str0 := 'SELECT file_name
                             FROM fnd_lobs
                            WHERE file_id = ' || i_file_id;
    EXECUTE IMMEDIATE l_dynamic_sql_str0 INTO l_file_name;
    IF (l_file_name IS NOT NULL) THEN

      x_cid := x_cid || l_file_name;

    END IF;

  ELSE

    RAISE invalid_input;

  END IF;

   if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
   end if;

EXCEPTION

   WHEN invalid_input THEN

    ecx_utils.i_errbuf :=  'ECX_ATTACHMENT.FORMULATE_CONTENT_ID INVALID INPUTS' || SQLERRM;
    ecx_utils.i_ret_code := 0;
    if(l_unexpectedEnabled) then
     ecx_debug.log(l_unexpected, ecx_utils.i_errbuf,i_method_name);
    end if;
    if (l_procedureEnabled) then
     ecx_debug.pop(i_method_name);
    end if;
    RAISE ecx_utils.PROGRAM_EXIT;

  WHEN OTHERS THEN

      if(l_unexpectedEnabled) then
        ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,'PROGRESS_LEVEL',
                          'ECX_ATTACHMENT.FORMULATE_CONTENT_ID');
        ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
      end if;
      ecx_utils.error_type := 30;
      ecx_utils.i_ret_code := 2;
      ecx_utils.i_errbuf := SQLERRM || ' at ECX_ATTACHMENT.FORMULATE_CONTENT_ID';
      if (l_procedureEnabled) then
       ecx_debug.pop(i_method_name);
      end if;
      RAISE ecx_utils.PROGRAM_EXIT;

END formulate_content_id;

PROCEDURE register_attachment_offline(
             i_cid                   IN       VARCHAR2,
             i_file_id               IN       NUMBER,
             i_data_type             IN       NUMBER
) AS
  i_method_name   varchar2(2000) := 'ecx_attachment.register_attachment_offline';
  l_is_append                  BOOLEAN := TRUE;
  l_parameterlist              wf_parameter_list_t;
  l_attachments                VARCHAR2(2000) := NULL;
  l_install_mode               VARCHAR2(200) := NULL;
  l_progress                   VARCHAR2(4) := NULL;
  l_records                    ecx_attachment.attachment_records_type;
  mode_not_support             EXCEPTION;
  invalid_input                EXCEPTION;

BEGIN

  if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
  end if;
  if(l_statementEnabled) then
    ecx_debug.log(l_statement,'i_cid', i_cid,i_method_name);
    ecx_debug.log(l_statement,'i_file_id', i_file_id,i_method_name);
    ecx_debug.log(l_statement,'i_data_type', i_data_type,i_method_name);
  end if;


  -- Prelimnary check of inputs validity
  IF ((i_cid is NULL) OR (i_file_id is NULL)) THEN

     RAISE invalid_input;

  END IF;

  -- Check mode
  l_install_mode := wf_core.translate('WF_INSTALL');
  IF (l_install_mode  = 'EMBEDDED') THEN

    -- Retrieve ECX_ATTACHMENT name/value pairs, which may have registered earlier
    l_progress := '0000';
    l_attachments := i_attachment_maps;

    l_attachments := RTRIM(l_attachments);
    l_attachments := LTRIM(l_attachments);
    IF ((l_attachments is NULL) OR (l_attachments = ' ')) THEN

       -- No attachments yet, just append the current i_cid and i_file_id
       -- into the ecx_utils.g_event's ecx_attachment.ECX_UTIL_EVENT_ATTACHMENT name/value pair
       l_progress := '0001';
       l_attachments := i_cid || ATTACHMENT_FIELD_DELIMITOR ||
                        i_file_id || ATTACHMENT_FIELD_DELIMITOR ||
                        i_data_type || ATTACHMENT_RECORD_DELIMITOR;

    ELSE

       -- There are attachments registered already, validate the current
       -- i_cid and i_file_id against the previous ones
       l_progress := '0002';
       get_attachment_records(l_attachments, l_records);
       IF (l_records.COUNT > 0) THEN

          -- validate the current i_cid and i_file_id against the previous records
          FOR i IN l_records.FIRST .. l_records.LAST LOOP

             IF (l_records(i).cid = i_cid) THEN

                -- Same cid should have the same file_id, in this case,
                -- nothing would be appended in the l_attachments
                l_progress := '0003';
                IF (l_records(i).fid = i_file_id) THEN

                  l_is_append := FALSE;
                  EXIT;

                ELSE

                  -- Same cid but different file_id, something must be wrong
                  RAISE invalid_input;

                END IF;

             ELSE

               l_is_append := (l_is_append AND TRUE);

             END IF;

          END LOOP;

          IF (l_is_append) THEN

              -- Append this new i_cid
              l_progress := '0004';
              l_attachments := l_attachments || i_cid || ATTACHMENT_FIELD_DELIMITOR ||
                               i_file_id || ATTACHMENT_FIELD_DELIMITOR ||
                               i_data_type || ATTACHMENT_RECORD_DELIMITOR;

          END IF;

       ELSE

          -- Should not come here, but for double-safety
          l_progress := '0005';
          l_attachments := i_cid || ATTACHMENT_FIELD_DELIMITOR ||
                           i_file_id || ATTACHMENT_FIELD_DELIMITOR ||
                           i_data_type || ATTACHMENT_RECORD_DELIMITOR;

       END IF;

    END IF;

    -- Push the newly modified
    i_attachment_maps := l_attachments;

  ELSE

    -- Standalone mode is not yet supported
    RAISE mode_not_support;

  END IF; -- EMBEDDED MODE

 if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
 end if;

EXCEPTION

  WHEN invalid_input THEN

      ecx_utils.i_errbuf :=  'ECX_ATTACHMENT.REGISTER_ATTACHMENT_OFFLINE INVALID INPUT: CID or FID '|| SQLERRM;
      ecx_utils.i_ret_code := 0;
      if(l_unexpectedEnabled) then
        ecx_debug.log(l_unexpected, ecx_utils.i_errbuf,i_method_name);
      end if;
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      RAISE ecx_utils.PROGRAM_EXIT;

  WHEN mode_not_support THEN

      ecx_utils.i_errbuf :=  'ECX_ATTACHMENT.REGISTER_ATTACHMENT_OFFLINE MODE NOT SUPPORT' || SQLERRM;
      ecx_utils.i_ret_code := 0;
      if(l_unexpectedEnabled) then
        ecx_debug.log(l_unexpected, ecx_utils.i_errbuf,i_method_name);
      end if;
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      RAISE ecx_utils.PROGRAM_EXIT;

  WHEN OTHERS THEN

      if(l_unexpectedEnabled) then
        ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,'PROGRESS_LEVEL',
                          'ECX_ATTACHMENT.REGISTER_ATTACHMENT_OFFLINE');
        ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
      end if;
      ecx_utils.error_type := 30;
      ecx_utils.i_ret_code := 2;
      ecx_utils.i_errbuf := SQLERRM || ' at ECX_ATTACHMENT.REGISTER_ATTACHMENT_OFFLINE';
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      RAISE ecx_utils.PROGRAM_EXIT;

END register_attachment_offline;


PROCEDURE register_attachment(
             i_cid                   IN       VARCHAR2,
             i_file_id               IN       NUMBER,
             i_data_type             IN       NUMBER
) AS
  i_method_name   varchar2(2000) := 'ecx_attachment.register_attachment';
  l_is_append                  BOOLEAN := TRUE;
  l_parameterlist              wf_parameter_list_t;
  l_attachments                VARCHAR2(2000) := NULL;
  l_install_mode               VARCHAR2(200) := NULL;
  l_progress                   VARCHAR2(4) := NULL;
  l_records                    ecx_attachment.attachment_records_type;
  mode_not_support             EXCEPTION;
  invalid_input                EXCEPTION;

BEGIN

  if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
  end if;
  if(l_statementEnabled) then
   ecx_debug.log(l_statement,'i_cid', i_cid,i_method_name);
   ecx_debug.log(l_statement,'i_file_id', i_file_id,i_method_name);
   ecx_debug.log(l_statement,'i_data_type', i_data_type,i_method_name);
  end if;


  -- Prelimnary check of inputs validity
  IF ((i_cid is NULL) OR (i_file_id is NULL)) THEN

     RAISE invalid_input;

  END IF;

  -- Check mode
  -- ecx_utils.g_install_mode := wf_core.translate('WF_INSTALL');
  -- IF (ecx_utils.g_install_mode = 'EMBEDDED') THEN

  l_install_mode := wf_core.translate('WF_INSTALL');
  IF (l_install_mode  = 'EMBEDDED') THEN

    -- Retrieve ECX_ATTACHMENT name/value pairs from the
    -- ecx_utils.g_event workflow event
    l_progress := '0000';
    IF (ecx_utils.g_event is NULL)
    THEN
        wf_event_t.initialize(ecx_utils.g_event);
    END IF;
    l_parameterlist := wf_event_t.getParameterList(ecx_utils.g_event);
    l_attachments := wf_event.getValueForParameter(ecx_attachment.ECX_UTIL_EVENT_ATTACHMENT,
                                             l_parameterlist);

    l_attachments := RTRIM(l_attachments);
    l_attachments := LTRIM(l_attachments);
    IF ((l_attachments is NULL) OR (l_attachments = ' ')) THEN

       -- No attachments yet, just append the current i_cid and i_file_id
       -- into the ecx_utils.g_event's ecx_attachment.ECX_UTIL_EVENT_ATTACHMENT name/value pair
       l_progress := '0001';
       l_attachments := i_cid || ATTACHMENT_FIELD_DELIMITOR ||
                        i_file_id || ATTACHMENT_FIELD_DELIMITOR ||
                        i_data_type || ATTACHMENT_RECORD_DELIMITOR;

    ELSE

       -- There are attachments registered already, validate the current
       -- i_cid and i_file_id against the previous ones
       l_progress := '0002';
       get_attachment_records(l_attachments, l_records);
       IF (l_records.COUNT > 0) THEN

          -- validate the current i_cid and i_file_id against the previous records
          FOR i IN l_records.FIRST .. l_records.LAST LOOP

             IF (l_records(i).cid = i_cid) THEN

                -- Same cid should have the same file_id, in this case,
                -- nothing would be appended in the l_attachments
                l_progress := '0003';
                IF (l_records(i).fid = i_file_id) THEN

                  l_is_append := FALSE;
                  EXIT;

                ELSE

                  -- Same cid but different file_id, something must be wrong
                  RAISE invalid_input;

                END IF;

             ELSE

               l_is_append := (l_is_append AND TRUE);

             END IF;

          END LOOP;

          IF (l_is_append) THEN

              -- Append this new i_cid
              l_progress := '0004';
              l_attachments := l_attachments || i_cid || ATTACHMENT_FIELD_DELIMITOR ||
                               i_file_id || ATTACHMENT_FIELD_DELIMITOR ||
                               i_data_type || ATTACHMENT_RECORD_DELIMITOR;

          END IF;

       ELSE

          -- Should not come here, but for double-safety
          l_progress := '0005';
          l_attachments := i_cid || ATTACHMENT_FIELD_DELIMITOR ||
                           i_file_id || ATTACHMENT_FIELD_DELIMITOR ||
                           i_data_type || ATTACHMENT_RECORD_DELIMITOR;

       END IF;

    END IF;

    -- Push the newly modified
    ecx_utils.g_event.addParameterToList(ecx_attachment.ECX_UTIL_EVENT_ATTACHMENT, l_attachments);

  ELSE

    -- Standalone mode is not yet supported
    RAISE mode_not_support;

  END IF; -- EMBEDDED MODE

  if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
  end if;

EXCEPTION

  WHEN invalid_input THEN

      ecx_utils.i_errbuf :=  'ECX_ATTACHMENT.REGISTER_ATTACHMENT INVALID INPUT: CID or FID '|| SQLERRM;
      ecx_utils.i_ret_code := 0;
      if(l_unexpectedEnabled) then
        ecx_debug.log(l_unexpected,ecx_utils.i_errbuf,i_method_name);
      end if;
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      RAISE ecx_utils.PROGRAM_EXIT;

  WHEN mode_not_support THEN

      ecx_utils.i_errbuf :=  'ECX_ATTACHMENT.REGISTER_ATTACHMENT MODE NOT SUPPORT' || SQLERRM;
      ecx_utils.i_ret_code := 0;
      if(l_unexpectedEnabled) then
        ecx_debug.log(l_unexpected,ecx_utils.i_errbuf,i_method_name);
      end if;
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      RAISE ecx_utils.PROGRAM_EXIT;

  WHEN OTHERS THEN

      if(l_unexpectedEnabled) then
        ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,'PROGRESS_LEVEL',
                          'ECX_ATTACHMENT.REGISTER_ATTACHMENT');
        ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
      end if;
      ecx_utils.error_type := 30;
      ecx_utils.i_ret_code := 2;
      ecx_utils.i_errbuf := SQLERRM || ' at ECX_ATTACHMENT.REGISTER_ATTACHMENT';
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      RAISE ecx_utils.PROGRAM_EXIT;


END register_attachment;


PROCEDURE register_attachment_offline(
             i_entity_name           IN        VARCHAR2,
             i_pk1_value             IN        VARCHAR2,
             i_pk2_value             IN        VARCHAR2,
             i_pk3_value             IN        VARCHAR2,
             i_pk4_value             IN        VARCHAR2,
             i_pk5_value             IN        VARCHAR2,
             i_file_id               IN        NUMBER,
             i_data_type             IN        NUMBER,
             x_cid                   OUT NOCOPY VARCHAR2
) AS

i_method_name   varchar2(2000) := 'ecx_attachment.register_attachment_offline';
BEGIN

  if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
  end if;


  formulate_content_id(i_file_id,
                       i_entity_name,
                       i_pk1_value,
                       i_pk2_value,
                       i_pk3_value,
                       i_pk4_value,
                       i_pk5_value,
                       x_cid);

  register_attachment_offline(x_cid, i_file_id, i_data_type);

  if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
  end if;

EXCEPTION

  WHEN OTHERS THEN

      if(l_unexpectedEnabled) then
        ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,'PROGRESS_LEVEL',
                          'ECX_ATTACHMENT.REGISTER_ATTACHMENT_OFFLINE');
        ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
      end if;
      ecx_utils.error_type := 30;
      ecx_utils.i_ret_code := 2;
      ecx_utils.i_errbuf := SQLERRM || ' at ECX_ATTACHMENT.REGISTER_ATTACHMENT_OFFLINE';
      if (l_procedureEnabled) then
       ecx_debug.pop(i_method_name);
      end if;
      RAISE ecx_utils.PROGRAM_EXIT;

END register_attachment_offline;


PROCEDURE register_attachment(
             i_entity_name           IN        VARCHAR2,
             i_pk1_value             IN        VARCHAR2,
             i_pk2_value             IN        VARCHAR2,
             i_pk3_value             IN        VARCHAR2,
             i_pk4_value             IN        VARCHAR2,
             i_pk5_value             IN        VARCHAR2,
             i_file_id               IN        NUMBER,
             i_data_type             IN        NUMBER,
             x_cid                   OUT NOCOPY VARCHAR2
) AS

i_method_name   varchar2(2000) := 'ecx_attachment.register_attachment	';
BEGIN

  if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
  end if;

  formulate_content_id(i_file_id,
                       i_entity_name,
                       i_pk1_value,
                       i_pk2_value,
                       i_pk3_value,
                       i_pk4_value,
                       i_pk5_value,
                       x_cid);

  register_attachment(x_cid, i_file_id, i_data_type);

  if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
  end if;

EXCEPTION

  WHEN OTHERS THEN

      if(l_unexpectedEnabled) then
        ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,'PROGRESS_LEVEL',
                          'ECX_ATTACHMENT.REGISTER_ATTACHMENT');
        ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
      end if;
      ecx_utils.error_type := 30;
      ecx_utils.i_ret_code := 2;
      ecx_utils.i_errbuf := SQLERRM || ' at ECX_ATTACHMENT.REGISTER_ATTACHMENT';
      if (l_procedureEnabled) then
       ecx_debug.pop(i_method_name);
      end if;
      RAISE ecx_utils.PROGRAM_EXIT;

END register_attachment;


PROCEDURE remove_attachmentMaps_offline(
              x_attachment_maps     OUT NOCOPY VARCHAR2
) AS

BEGIN

   ecx_debug.push('ECX_ATTACHMENT.REMOVE_ATTACHMENTMAPS_OFFLINE');

   x_attachment_maps := i_attachment_maps;
   i_attachment_maps := NULL;

   ecx_debug.pop('ECX_ATTACHMENT.REMOVE_ATTACHMENTMAPS_OFFLINE');

END remove_attachmentMaps_offline;



PROCEDURE get_attachment_records(
                     i_attachments   IN        VARCHAR2,
                     x_records       OUT NOCOPY attachment_records_type
) AS

  i_method_name   varchar2(2000) := 'ecx_attachment.get_attachment_records';
  l_record_counter             NUMBER := 0;
  l_inner_position             NUMBER := 0;
  l_inner_begin                NUMBER := 1;
  l_occurrence                 NUMBER := 1;
  l_begin                      NUMBER := 1;
  l_position                   NUMBER := 0;
  l_datatype                   NUMBER := NULL;
  l_sdatatype                  VARCHAR2(256) := NULL;
  l_fid                        NUMBER := NULL;
  l_sfid                       VARCHAR2(256) := NULL;
  l_cid                        VARCHAR2(256) := NULL;
  l_progress                   VARCHAR2(4) := NULL;
  l_current_record             VARCHAR2(300) := NULL;
  l_invalid_records            EXCEPTION;

BEGIN

  if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
  end if;
  if(l_statementEnabled) then
     ecx_debug.log(l_statement,'ei_attachments', i_attachments,i_method_name);
  end if;


  IF (i_attachments IS NOT NULL) THEN

    l_progress := '0000';
    LOOP

      l_position := INSTR(i_attachments, ATTACHMENT_RECORD_DELIMITOR, 1, l_occurrence);

      IF (l_position = 0) THEN

         EXIT;

      ELSE

         l_current_record := SUBSTR(i_attachments, l_begin, l_position - l_begin  + 1);

         l_progress := '0001';
         IF (l_current_record IS NOT NULL) THEN

           -- Get CID
           l_inner_position := INSTR(l_current_record, ATTACHMENT_FIELD_DELIMITOR, 1, 1);
           IF (l_inner_position = 0) THEN

              RAISE l_invalid_records;

           ELSE

              l_cid := SUBSTR(l_current_record,l_inner_begin, l_inner_position - l_inner_begin);
              l_inner_begin := l_inner_position + 1;

           END IF;
           l_inner_position := 0;

           -- GET FID
           l_inner_position := INSTR(l_current_record, ATTACHMENT_FIELD_DELIMITOR, 1, 2);
           IF (l_inner_position = 0) THEN

              RAISE l_invalid_records;

           ELSE

              l_sfid := SUBSTR(l_current_record,l_inner_begin, l_inner_position - l_inner_begin);
              l_fid := TO_NUMBER(l_sfid);
              l_inner_begin := l_inner_position + 1;

           END IF;
           l_inner_position := 0;

           -- GET datatype
           l_inner_position := INSTR(l_current_record, ATTACHMENT_RECORD_DELIMITOR, 1, 1);
           IF (l_inner_position = 0) THEN

              RAISE l_invalid_records;

           ELSE

              l_sdatatype := SUBSTR(l_current_record,l_inner_begin, l_inner_position - l_inner_begin);
              l_datatype := TO_NUMBER(l_sdatatype);

           END IF;

           l_record_counter := l_record_counter + 1;
           x_records(l_record_counter).cid := l_cid;
           x_records(l_record_counter).fid := l_fid;
           x_records(l_record_counter).dataType := l_datatype;

         END IF; -- l_current_record is NOT NULL
         l_inner_begin := 1;

      END IF;


      l_begin := l_position + 1;
      l_current_record := NULL;
      l_occurrence := l_occurrence + 1;

    END LOOP;

  END IF;

  if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
  end if;

EXCEPTION

  WHEN l_invalid_records THEN

      ecx_utils.i_errbuf :=  'ECX_ATTACHMENT.GET_ATTACHMENT_RECORDS RECORDED ATTACHMENTS ARE WRONG '|| SQLERRM;
      ecx_utils.i_ret_code := 0;
      if(l_unexpectedEnabled) then
        ecx_debug.log(l_unexpected, ecx_utils.i_errbuf,i_method_name);
      end if;
      if (l_procedureEnabled) then
       ecx_debug.pop(i_method_name);
      end if;
      RAISE ecx_utils.PROGRAM_EXIT;


END get_attachment_records;

PROCEDURE map_attachments(
              i_msgid              IN       RAW
)AS

  i_method_name   varchar2(2000) := 'ecx_attachment.map_attachments';
  l_progress                   VARCHAR2(4) := NULL;
  l_attachments_info           VARCHAR2(2000) := NULL;
  l_install_mode               VARCHAR2(200) := NULL;
  l_parameterList              wf_parameter_list_t;
  l_records                    ecx_attachment.attachment_records_type;

BEGIN

  if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
  end if;
  if(l_statementEnabled) then
     ecx_debug.log(l_statement,'i_msgid', i_msgid,i_method_name);
  end if;

  l_install_mode := wf_core.translate('WF_INSTALL');
  IF (ecx_utils.g_event is NULL) THEN

     wf_event_t.initialize(ecx_utils.g_event);

  END IF;
  l_parameterList := wf_event_t.getParameterList(ecx_utils.g_event);
  l_attachments_info := wf_event.getValueForParameter(ecx_attachment.ECX_UTIL_EVENT_ATTACHMENT,
                                                      l_parameterList);

  l_attachments_info := RTRIM(l_attachments_info);
  l_attachments_info := LTRIM(l_attachments_info);
  if(l_statementEnabled) then
    ecx_debug.log(l_statement,'l_attachments_info', l_attachments_info,i_method_name);
  end if;

  -- Book keep the attachments info if it exists
  IF (l_attachments_info is NOT NULL) THEN

    l_progress := '0000';
    get_attachment_records(l_attachments_info, l_records);
    IF (l_records.COUNT > 0) THEN

      l_progress := '0001';
      FOR i IN l_records.FIRST .. l_records.LAST LOOP

         INSERT INTO ecx_attachment_maps
                (msgid,
                 cid,
                 fid,
                 dataType,
                 orderIndex,
                 nestParentIndex)
         VALUES
            (i_msgid,
             l_records(i).cid,
             l_records(i).fid,
             l_records(i).dataType,
             i,
             0   -- 0 refers to the main doc
            );

      END LOOP;


    END IF;

  END IF;

if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
end if;

EXCEPTION

  WHEN OTHERS THEN

      if(l_unexpectedEnabled) then
        ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,'PROGRESS_LEVEL',
                          'ECX_ATTACHMENT.MAP_ATTACHMENTS');
        ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
      end if;
      ecx_utils.error_type := 30;
      ecx_utils.i_ret_code := 2;
      ecx_utils.i_errbuf := SQLERRM || ' at ECX_ATTACHMENT.MAP_ATTACHMENTS';
      if (l_procedureEnabled) then
       ecx_debug.pop(i_method_name);
      end if;
      RAISE ecx_utils.PROGRAM_EXIT;

END map_attachments;

PROCEDURE map_attachments(
              i_event              IN       WF_EVENT_T,
              i_msgid              IN       RAW
)AS
  i_method_name   varchar2(2000) := 'ecx_attachment.map_attachments';
  l_progress                   VARCHAR2(4) := NULL;
  l_attachments_info           VARCHAR2(2000) := NULL;
  l_install_mode               VARCHAR2(200) := NULL;
  l_parameterList              wf_parameter_list_t;
  l_records                    ecx_attachment.attachment_records_type;

BEGIN

  if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;

  if(l_statementEnabled) then
    ecx_debug.log(l_statement,'i_msgid', i_msgid,i_method_name);
  end if;

  l_install_mode := wf_core.translate('WF_INSTALL');
  IF (i_event is not NULL) THEN

    l_parameterList := wf_event_t.getParameterList(i_event);
    l_attachments_info := wf_event.getValueForParameter(ecx_attachment.ECX_UTIL_EVENT_ATTACHMENT,
                                                      l_parameterList);

    l_attachments_info := RTRIM(l_attachments_info);
    l_attachments_info := LTRIM(l_attachments_info);
    if(l_statementEnabled) then
      ecx_debug.log(l_statement,'l_attachments_info', l_attachments_info,i_method_name);
    end if;

    -- Book keep the attachments info if it exists
    IF (l_attachments_info is NOT NULL) THEN

      l_progress := '0000';
      get_attachment_records(l_attachments_info, l_records);
      IF (l_records.COUNT > 0) THEN

        l_progress := '0001';
        FOR i IN l_records.FIRST .. l_records.LAST LOOP

         INSERT INTO ecx_attachment_maps
                (msgid,
                 cid,
                 fid,
                 dataType,
                 orderIndex,
                 nestParentIndex)
         VALUES
            (i_msgid,
             l_records(i).cid,
             l_records(i).fid,
             l_records(i).dataType,
             i,
             0   -- 0 refers to the main doc
            );

        END LOOP;


      END IF;

    END IF;

  END IF;

  if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
  end if;

EXCEPTION

  WHEN OTHERS THEN

      if(l_unexpectedEnabled) then
        ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,'PROGRESS_LEVEL',
                          'ECX_ATTACHMENT.MAP_ATTACHMENTS');
        ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
      end if;
      ecx_utils.error_type := 30;
      ecx_utils.i_ret_code := 2;
      ecx_utils.i_errbuf := SQLERRM || ' at ECX_ATTACHMENT.MAP_ATTACHMENTS';
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      RAISE ecx_utils.PROGRAM_EXIT;

END map_attachments;



PROCEDURE remap_attachments(
              i_msgid              IN       RAW
)AS
  i_method_name   varchar2(2000) := 'ecx_attachment.remap_attachments';
  l_progress                   VARCHAR2(4) := NULL;
  l_in_aqMsgid                 RAW(16) := NULL;
  l_map_row                    ECX_ATTACHMENT_MAPS%ROWTYPE;
  CURSOR l_map_cursor (msgid RAW) IS
   SELECT *
     FROM ecx_attachment_maps
    WHERE MSGID = msgid;

BEGIN

  if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
  end if;
  if(l_statementEnabled) then
     ecx_debug.log(l_statement,'i_msgid of the passthrough document', i_msgid,i_method_name);
  end if;

  l_progress := '0000';

  -- retrieve the original AQ message ID on the ecx_inqueue
  SELECT msgId
    INTO l_in_aqMsgid
    FROM ecx_doclogs
   WHERE OUT_MSGID = i_msgid;

  l_progress := '0001';
  IF (l_in_aqMsgid IS NOT NULL) THEN

     FOR l_map_row IN l_map_cursor(l_in_aqMsgid)
     LOOP

        IF (l_map_row.msgid = l_in_aqMsgid)
        THEN

           INSERT INTO ecx_attachment_maps (msgId,
                                            cId,
                                            fId,
                                            dataType,
                                            orderIndex,
                                            nestParentIndex
                    )
                    VALUES
                    (
                       i_msgid,
                       l_map_row.cId,
                       l_map_row.fId,
                       l_map_row.dataType,
                       l_map_row.orderIndex,
                       l_map_row.nestParentIndex
                    );

        END IF;

     END LOOP;

  END IF;
  l_progress := '0002';

  if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
  end if;



EXCEPTION

  WHEN OTHERS THEN

     if(l_unexpectedEnabled) then
        ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,'PROGRESS_LEVEL',
                          'ECX_ATTACHMENT.REMAP_ATTACHMENTS');
        ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
      end if;
      ecx_utils.error_type := 30;
      ecx_utils.i_ret_code := 2;
      ecx_utils.i_errbuf := SQLERRM || ' at ECX_ATTACHMENT.MAP_ATTACHMENTS';
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;

      RAISE ecx_utils.PROGRAM_EXIT;

END remap_attachments;



PROCEDURE retrieve_attachment(
              i_msgid              IN       RAW,
              i_cid                IN       VARCHAR2,
              x_file_name          OUT NOCOPY VARCHAR2,
              x_file_content_type  OUT NOCOPY VARCHAR2,
              x_file_data          OUT NOCOPY BLOB,
              x_ora_charset        OUT NOCOPY VARCHAR2,
              x_file_format        OUT NOCOPY VARCHAR2
) AS
  i_method_name   varchar2(2000) := 'ecx_attachment.retrieve_attachment';
  l_file_id                    NUMBER := NULL;
  l_datatype                   NUMBER := NULL;
  l_mode                       VARCHAR2(200) := NULL;
  l_progress                   VARCHAR2(4) := NULL;
  l_install_mode               VARCHAR2(200) := NULL;
  l_dynamic_sql_str0           VARCHAR2(2000) := NULL;
  mode_not_support             EXCEPTION;
  mode_mismatch                EXCEPTION;

BEGIN

  if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
  end if;
  if(l_statementEnabled) then
   ecx_debug.log(l_statement,'i_msgid', i_msgid,i_method_name);
   ecx_debug.log(l_statement,'i_cid', i_cid,i_method_name);
  end if;

  -- Check mode
  -- ecx_utils.g_install_mode := wf_core.translate('WF_INSTALL');
  -- IF (ecx_utils.g_install_mode = 'EMBEDDED') THEN

  l_install_mode := wf_core.translate('WF_INSTALL');
  IF (l_install_mode  = 'EMBEDDED') THEN

     l_progress := '0000';
     SELECT fid, datatype
       INTO l_file_id, l_datatype
       FROM ecx_attachment_maps
      WHERE msgid = i_msgid AND cid = i_cid;

     IF ((l_file_id is NOT NULL) AND (l_datatype is NOT NULL)) THEN

        l_progress := '0001';

        IF (l_datatype = ecx_attachment.EMBEDDED_LOB_DATA_TYPE) THEN

             l_progress := '0002';
             l_dynamic_sql_str0 := 'SELECT file_name, file_content_type,
                                           file_data, oracle_charset, file_format
                                      FROM fnd_lobs
                                     WHERE file_id = ' || l_file_id;
             EXECUTE IMMEDIATE l_dynamic_sql_str0
                          INTO x_file_name, x_file_content_type,
                               x_file_data, x_ora_charset, x_file_format;

        ELSIF (l_datatype = ecx_attachment.EMBEDDED_SHORTTEXT_DATA_TYPE) THEN

             x_file_content_type := 'text';

        -- XXX
        -- ELSIF other types one by one
        -- XXX

        END IF;

     END IF; -- ((l_file_id is NOT NULL) AND (l_datatype is NOT NULL))

  ELSE

     -- Standalone mode is not yet supported
     RAISE mode_not_support;

  END IF;  -- EMBEDDED MODE

  if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
  end if;

EXCEPTION

  WHEN no_data_found THEN

    ecx_utils.i_errbuf :=  'ECX_ATTACHMENT.RETRIEVE_ATTACHMENT NO DATA FOUND IN ECX_ATTACHMENT_MAP TABLE' || SQLERRM;
    ecx_utils.i_ret_code := 0;
    if(l_unexpectedEnabled) then
      ecx_debug.log(l_unexpected,ecx_utils.i_errbuf,i_method_name);
    end if;
    if (l_procedureEnabled) then
     ecx_debug.pop(i_method_name);
    end if;
    RAISE ecx_utils.PROGRAM_EXIT;


  WHEN mode_not_support THEN

    ecx_utils.i_errbuf :=  'ECX_ATTACHMENT.RETRIEVE_ATTACHMENT MODE NOT SUPPORT' || SQLERRM;
    ecx_utils.i_ret_code := 0;
    if(l_unexpectedEnabled) then
      ecx_debug.log(l_unexpected,ecx_utils.i_errbuf,i_method_name);
    end if;
    if (l_procedureEnabled) then
     ecx_debug.pop(i_method_name);
    end if;
    RAISE ecx_utils.PROGRAM_EXIT;


  WHEN mode_mismatch THEN

    ecx_utils.i_errbuf :=  'ECX_ATTACHMENT.RETRIEVE_ATTACHMENT MODE MISMATCHES' || SQLERRM;
    ecx_utils.i_ret_code := 0;
    if(l_unexpectedEnabled) then
      ecx_debug.log(l_unexpected,ecx_utils.i_errbuf,i_method_name);
    end if;
    if (l_procedureEnabled) then
     ecx_debug.pop(i_method_name);
    end if;
    RAISE ecx_utils.PROGRAM_EXIT;

  WHEN OTHERS THEN

      if(l_unexpectedEnabled) then
        ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,'PROGRESS_LEVEL',
                          'ECX_ATTACHMENT.RETRIEVE_ATTACHMENT');
        ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
      end if;
      ecx_utils.error_type := 30;
      ecx_utils.i_ret_code := 2;
      ecx_utils.i_errbuf := SQLERRM || ' at ECX_ATTACHMENT.RETRIEVE_ATTACHMENT';
      if (l_procedureEnabled) then
     ecx_debug.pop(i_method_name);
    end if;
      RAISE ecx_utils.PROGRAM_EXIT;

END retrieve_attachment;


PROCEDURE retrieve_attachment(
              i_msgid              IN       RAW,
              i_cid                IN       VARCHAR2,
              x_file_name          OUT NOCOPY VARCHAR2,
              x_file_content_type  OUT NOCOPY VARCHAR2,
              x_file_data          OUT NOCOPY BLOB,
              x_language           OUT NOCOPY VARCHAR2,
              x_ora_charset        OUT NOCOPY VARCHAR2,
              x_file_format        OUT NOCOPY VARCHAR2
) AS
  i_method_name   varchar2(2000) := 'ecx_attachment.retrieve_attachment';
  l_file_id                    NUMBER := NULL;
  l_datatype                   NUMBER := NULL;
  l_mode                       VARCHAR2(200) := NULL;
  l_progress                   VARCHAR2(4) := NULL;
  l_install_mode               VARCHAR2(200) := NULL;
  l_dynamic_sql_str0           VARCHAR2(2000) := NULL;
  mode_not_support             EXCEPTION;
  mode_mismatch                EXCEPTION;

BEGIN

  if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
  end if;
 if(l_statementEnabled) then
     ecx_debug.log(l_statement,'i_msgid', i_msgid,i_method_name);
     ecx_debug.log(l_statement,'i_cid', i_cid,i_method_name);
 end if;

  -- Check mode
  -- ecx_utils.g_install_mode := wf_core.translate('WF_INSTALL');
  -- IF (ecx_utils.g_install_mode = 'EMBEDDED') THEN

  l_install_mode := wf_core.translate('WF_INSTALL');
  IF (l_install_mode  = 'EMBEDDED') THEN

     l_progress := '0000';
     SELECT fid, datatype
       INTO l_file_id, l_datatype
       FROM ecx_attachment_maps
      WHERE msgid = i_msgid AND cid = i_cid;

     IF ((l_file_id is NOT NULL) AND (l_datatype is NOT NULL)) THEN

        l_progress := '0001';

        IF (l_datatype = ecx_attachment.EMBEDDED_LOB_DATA_TYPE) THEN

             l_progress := '0002';
             l_dynamic_sql_str0 := 'SELECT file_name, file_content_type,
                                           file_data, oracle_charset, file_format,
                                           language
                                      FROM fnd_lobs
                                     WHERE file_id = ' || l_file_id;
             EXECUTE IMMEDIATE l_dynamic_sql_str0
                          INTO x_file_name, x_file_content_type,
                               x_file_data, x_ora_charset, x_file_format,
                               x_language;

        ELSIF (l_datatype = ecx_attachment.EMBEDDED_SHORTTEXT_DATA_TYPE) THEN

             x_file_content_type := 'text';

        -- XXX
        -- ELSIF other types one by one
        -- XXX

        END IF;

     END IF; -- ((l_file_id is NOT NULL) AND (l_datatype is NOT NULL))

  ELSE

     -- Standalone mode is not yet supported
     RAISE mode_not_support;

  END IF;  -- EMBEDDED MODE

  if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
  end if;


EXCEPTION

  WHEN no_data_found THEN

    ecx_utils.i_errbuf :=  'ECX_ATTACHMENT.RETRIEVE_ATTACHMENT NO DATA FOUND IN ECX_ATTACHMENT_MAP TABLE' || SQLERRM;
    ecx_utils.i_ret_code := 0;
    if(l_unexpectedEnabled) then
      ecx_debug.log(l_unexpected,ecx_utils.i_errbuf,i_method_name);
    end if;
    if (l_procedureEnabled) then
      ecx_debug.pop(i_method_name);
    end if;

    RAISE ecx_utils.PROGRAM_EXIT;


  WHEN mode_not_support THEN

    ecx_utils.i_errbuf :=  'ECX_ATTACHMENT.RETRIEVE_ATTACHMENT MODE NOT SUPPORT' || SQLERRM;
    ecx_utils.i_ret_code := 0;
    if(l_unexpectedEnabled) then
      ecx_debug.log(l_unexpected,ecx_utils.i_errbuf,i_method_name);
    end if;
    if (l_procedureEnabled) then
      ecx_debug.pop(i_method_name);
    end if;
    RAISE ecx_utils.PROGRAM_EXIT;


  WHEN mode_mismatch THEN

    ecx_utils.i_errbuf :=  'ECX_ATTACHMENT.RETRIEVE_ATTACHMENT MODE MISMATCHES' || SQLERRM;
    ecx_utils.i_ret_code := 0;
    if(l_unexpectedEnabled) then
      ecx_debug.log(l_unexpected,ecx_utils.i_errbuf,i_method_name);
    end if;
    if (l_procedureEnabled) then
      ecx_debug.pop(i_method_name);
    end if;
    RAISE ecx_utils.PROGRAM_EXIT;

  WHEN OTHERS THEN

      if(l_unexpectedEnabled) then
        ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,'PROGRESS_LEVEL',
                          'ECX_ATTACHMENT.RETRIEVE_ATTACHMENT');
        ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
      end if;
      ecx_utils.error_type := 30;
      ecx_utils.i_ret_code := 2;
      ecx_utils.i_errbuf := SQLERRM || ' at ECX_ATTACHMENT.RETRIEVE_ATTACHMENT';
      if (l_procedureEnabled) then
         ecx_debug.pop(i_method_name);
      end if;
      RAISE ecx_utils.PROGRAM_EXIT;

END retrieve_attachment;


PROCEDURE retrieve_attachment(
              i_file_id            IN       NUMBER,
              i_data_type          IN       NUMBER,
              x_file_name          OUT NOCOPY VARCHAR2,
              x_file_content_type  OUT NOCOPY VARCHAR2,
              x_file_data          OUT NOCOPY BLOB,
              x_language           OUT NOCOPY VARCHAR2,
              x_ora_charset        OUT NOCOPY VARCHAR2,
              x_file_format        OUT NOCOPY VARCHAR2
) AS
  i_method_name   varchar2(2000) := 'ecx_attachment.retrieve_attachment';
  l_file_id                    NUMBER := NULL;
  l_datatype                   NUMBER := NULL;
  l_mode                       VARCHAR2(200) := NULL;
  l_progress                   VARCHAR2(4) := NULL;
  l_install_mode               VARCHAR2(200) := NULL;
  l_dynamic_sql_str0           VARCHAR2(2000) := NULL;
  mode_not_support             EXCEPTION;
  mode_mismatch                EXCEPTION;

BEGIN

  if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
  end if;
  if(l_statementEnabled) then
    ecx_debug.log(l_statement,'i_file_id', i_file_id,i_method_name);
    ecx_debug.log(l_statement,'i_data_type', i_data_type,i_method_name);
  end if;

  -- Check mode
  l_install_mode := wf_core.translate('WF_INSTALL');
  IF (l_install_mode  = 'EMBEDDED') THEN

     l_progress := '0000';
     IF ((i_file_id is NOT NULL) AND (i_data_type is NOT NULL)) THEN

        l_progress := '0001';
        IF (i_data_type = ecx_attachment.EMBEDDED_LOB_DATA_TYPE) THEN

             l_progress := '0002';
             l_dynamic_sql_str0 := 'SELECT file_name, file_content_type,
                                           file_data, oracle_charset, file_format,
                                           language
                                      FROM fnd_lobs
                                     WHERE file_id = ' || i_file_id;
             EXECUTE IMMEDIATE l_dynamic_sql_str0
                          INTO x_file_name, x_file_content_type,
                               x_file_data, x_ora_charset, x_file_format,
                               x_language;

        ELSIF (i_data_type = ecx_attachment.EMBEDDED_SHORTTEXT_DATA_TYPE) THEN

             x_file_content_type := 'text';

        -- XXX
        -- ELSIF other types one by one
        -- XXX

        END IF;

     END IF; -- ((i_file_id is NOT NULL) AND (i_data_type is NOT NULL))

  ELSE

     -- Standalone mode is not yet supported
     RAISE mode_not_support;

  END IF;  -- EMBEDDED MODE

  if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
  end if;

EXCEPTION

  WHEN no_data_found THEN

    ecx_utils.i_errbuf :=  'ECX_ATTACHMENT.RETRIEVE_ATTACHMENT NO DATA FOUND IN ECX_ATTACHMENT_MAP TABLE' || SQLERRM;
    ecx_utils.i_ret_code := 0;
    if(l_unexpectedEnabled) then
      ecx_debug.log(l_unexpected,ecx_utils.i_errbuf,i_method_name);
    end if;
    if (l_procedureEnabled) then
      ecx_debug.pop(i_method_name);
    end if;
    RAISE ecx_utils.PROGRAM_EXIT;


  WHEN mode_not_support THEN

    ecx_utils.i_errbuf :=  'ECX_ATTACHMENT.RETRIEVE_ATTACHMENT MODE NOT SUPPORT' || SQLERRM;
    ecx_utils.i_ret_code := 0;
    if(l_unexpectedEnabled) then
      ecx_debug.log(l_unexpected,ecx_utils.i_errbuf,i_method_name);
    end if;
    if (l_procedureEnabled) then
      ecx_debug.pop(i_method_name);
    end if;
    RAISE ecx_utils.PROGRAM_EXIT;


  WHEN mode_mismatch THEN

    ecx_utils.i_errbuf :=  'ECX_ATTACHMENT.RETRIEVE_ATTACHMENT MODE MISMATCHES' || SQLERRM;
    ecx_utils.i_ret_code := 0;
    if(l_unexpectedEnabled) then
      ecx_debug.log(l_unexpected,ecx_utils.i_errbuf,i_method_name);
    end if;
    if (l_procedureEnabled) then
      ecx_debug.pop(i_method_name);
    end if;
    RAISE ecx_utils.PROGRAM_EXIT;

  WHEN OTHERS THEN

      if(l_unexpectedEnabled) then
        ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,'PROGRESS_LEVEL',
                          'ECX_ATTACHMENT.RETRIEVE_ATTACHMENT');
        ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
      end if;
      ecx_utils.error_type := 30;
      ecx_utils.i_ret_code := 2;
      ecx_utils.i_errbuf := SQLERRM || ' at ECX_ATTACHMENT.RETRIEVE_ATTACHMENT';
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      RAISE ecx_utils.PROGRAM_EXIT;

END retrieve_attachment;


PROCEDURE reconfig_attachment(
              i_msgid              IN       RAW,
              i_cid                IN       VARCHAR2,
              i_entity_name        IN       VARCHAR2,
              i_pk1_value          IN       VARCHAR2,
              i_pk2_value          IN       VARCHAR2,
              i_pk3_value          IN       VARCHAR2,
              i_pk4_value          IN       VARCHAR2,
              i_pk5_value          IN       VARCHAR2,
              i_program_app_id     IN       NUMBER,
              i_program_id         IN       NUMBER,
              i_request_id         IN       NUMBER,
              x_document_id        OUT NOCOPY NUMBER
) AS
  i_method_name   varchar2(2000) := 'ecx_attachment.deposit_blob_attachment';
  l_file_id                    NUMBER := NULL;
  l_datatype                   NUMBER := NULL;
  l_install_mode               VARCHAR2(200) := NULL;
  l_mode                       VARCHAR2(200) := NULL;
  l_progress                   VARCHAR2(4) := NULL;
  l_dynamic_sql_str0           VARCHAR2(2000) := NULL;
  l_dynamic_sql_str1           VARCHAR2(2000) := NULL;
  mode_not_support             EXCEPTION;
  invalid_input                EXCEPTION;

BEGIN

  if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
  end if;
  if(l_statementEnabled) then
     ecx_debug.log(l_statement,'i_msgid', i_msgid,i_method_name);
     ecx_debug.log(l_statement,'i_cid', i_cid,i_method_name);
     ecx_debug.log(l_statement,'i_entity_name', i_entity_name,i_method_name);
     ecx_debug.log(l_statement,'i_pk1_value', i_pk1_value,i_method_name);
     ecx_debug.log(l_statement,'i_pk2_value', i_pk2_value,i_method_name);
     ecx_debug.log(l_statement,'i_pk3_value', i_pk3_value,i_method_name);
     ecx_debug.log(l_statement,'i_pk4_value', i_pk4_value,i_method_name);
     ecx_debug.log(l_statement,'i_pk5_value', i_pk5_value,i_method_name);
     ecx_debug.log(l_statement,'i_program_app_id', i_program_app_id,i_method_name);
     ecx_debug.log(l_statement,'i_program_id', i_program_id,i_method_name);
     ecx_debug.log(l_statement,'i_request_id', i_request_id,i_method_name);
  end if;
  IF (i_entity_name IS NULL) THEN

    RAISE invalid_input;

  END IF;


  -- Check mode
  l_install_mode := wf_core.translate('WF_INSTALL');
  IF (l_install_mode  = 'EMBEDDED') THEN

     l_progress := '0000';
     SELECT fid, datatype
       INTO l_file_id, l_datatype
       FROM ecx_attachment_maps
      WHERE msgid = i_msgid AND cid = i_cid;

     IF ((l_file_id is NOT NULL) AND (l_datatype is NOT NULL)) THEN

        -- Figure out document_id based on file_id
        l_progress := '0001';
        l_dynamic_sql_str1 := 'SELECT DISTINCT document_id
                               FROM fnd_Documents_tl
                               WHERE media_id = ' || l_file_id;

        EXECUTE IMMEDIATE l_dynamic_sql_str1 INTO x_document_id;


        IF (l_datatype = ecx_attachment.EMBEDDED_LOB_DATA_TYPE) THEN

           l_progress := '0002';
           l_dynamic_sql_str0 := 'UPDATE fnd_attached_documents SET
                                          entity_name = :1,
                                          pk1_value = :2,
                                          pk2_value = :3,
                                          pk3_value = :4,
                                          pk4_value = :5,
                                          pk5_value = :6,
                                          program_application_id = :7,
                                          program_id = :8,
                                          request_id = :9
                                   WHERE  document_id = :10';

            EXECUTE IMMEDIATE l_dynamic_sql_str0
                    USING i_entity_name, i_pk1_value, i_pk2_value, i_pk3_value,
                          i_pk4_value, i_pk5_value, i_program_app_id,
                          i_program_id, i_request_id, x_document_id;


        END IF;

     END IF;

  ELSE

    -- Standalone mode is not yet supported
     RAISE mode_not_support;

  END IF;

 if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
 end if;
EXCEPTION

  WHEN invalid_input THEN

    ecx_utils.i_errbuf :=  'ECX_ATTACHMENT.RECONFIG_ATTACHMENT INVALID INPUTS' || SQLERRM;
    ecx_utils.i_ret_code := 0;
    if(l_unexpectedEnabled) then
      ecx_debug.log(l_unexpected,ecx_utils.i_errbuf,i_method_name);
    end if;
    if (l_procedureEnabled) then
      ecx_debug.pop(i_method_name);
    end if;
    RAISE ecx_utils.PROGRAM_EXIT;

  WHEN mode_not_support THEN

    ecx_utils.i_errbuf :=  'ECX_ATTACHMENT.RECONFIG_ATTACHMENT MODE NOT SUPPORT' || SQLERRM;
    ecx_utils.i_ret_code := 0;
    if(l_unexpectedEnabled) then
      ecx_debug.log(l_unexpected,ecx_utils.i_errbuf,i_method_name);
    end if;
    if (l_procedureEnabled) then
      ecx_debug.pop(i_method_name);
    end if;
    RAISE ecx_utils.PROGRAM_EXIT;

  WHEN OTHERS THEN

      if(l_unexpectedEnabled) then
        ecx_debug.log(l_unexpected,'ECX','ECX_PROGRAM_ERROR',i_method_name,'PROGRESS_LEVEL',
                          'ECX_ATTACHMENT.RECONFIG_ATTACHMENT');
        ecx_debug.log(l_unexpected,'ECX','ECX_ERROR_MESSAGE',i_method_name,'ERROR_MESSAGE',SQLERRM);
      end if;
      ecx_utils.error_type := 30;
      ecx_utils.i_ret_code := 2;
      ecx_utils.i_errbuf := SQLERRM || ' at ECX_ATTACHMENT.RECONFIG_ATTACHMENT';
      if (l_procedureEnabled) then
        ecx_debug.pop(i_method_name);
      end if;
      RAISE ecx_utils.PROGRAM_EXIT;

END reconfig_attachment;


END ecx_attachment;

/
