--------------------------------------------------------
--  DDL for Package Body IGF_SL_UPLOAD_XML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SL_UPLOAD_XML" AS
/* $Header: IGFSL26B.pls 120.13 2006/04/20 00:57:44 ugummall noship $ */

/*----------PROCESS FLOW--------------------------------------

main()
The main() process is called from the concurrent request (Upload XML File).
It will take the file path as parameter and it will raise the business event
which will then upload this file. It also passes the file path as ECX_PARAMETER1

upload_xml()
This process is called from the workflow to convert the file passed to a CLOB
parameter and will set the ECX_EVENT_MESSAGE attribute of the workflow.
It will also find the <DocumentID> and set it as the parameter  ECX_PARAMETER2.
It will also insert the document in the igf_sl_cod_doc_dtls table.

set_nls_fmt()
This process is called from the IGF_SL_INBOUND.xgm for setting the NLS Format

get_datetime()
This process is called from the IGF_SL_INBOUND.xgm for converting the datetime
fields into Gateway compatible.

get_date()
This process is called from the IGF_SL_INBOUND.xgm for converting the date field
into XML Gateway compatible.

launch_request()
This process is called from the workflow and is teh last step of the workflow. It will
launch the sub-process which will upload launch a concurrent request which will process
the response records uploaded by XML Gateway in the previous step.

main_response()
This process is the sub-process (also a concurrent program) which will take the records in the
response tables and updates teh system tables accordingly. It takes the document ID as a
parameter. It will internally call process_pell_records and process_dl_records which process
the Pell and DL Records respectively.

-----------------------------------------------------------*/

CURSOR  chk_doc ( cp_doc_id VARCHAR2) IS
  SELECT  ROWID row_id, a.*
    FROM  IGF_SL_COD_DOC_DTLS a
   WHERE  document_id_txt = cp_doc_id;

g_doc_id  VARCHAR2(30);
g_process_date DATE;

PROCEDURE update_xml_document(l_chk_doc chk_doc%ROWTYPE, p_doc_status VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  igf_sl_cod_doc_dtls_pkg.update_row (
      x_rowid                             => l_chk_doc.row_id,
      x_document_id_txt                   => l_chk_doc.document_id_txt,
      x_outbound_doc                      => l_chk_doc.outbound_doc   ,
      x_inbound_doc                       => l_chk_doc.inbound_doc    ,
      x_send_date                         => l_chk_doc.send_date      ,
      x_ack_date                          => l_chk_doc.ack_date       ,
      x_doc_status                        => p_doc_status             ,
      x_doc_type                          => l_chk_doc.doc_type       ,
      x_full_resp_code                    => l_chk_doc.full_resp_code ,
      x_mode                              => 'R'
  );
  COMMIT;
END update_xml_document;

PROCEDURE delete_temp_table_data
IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  DELETE IGF_SL_COD_TEMP;
  COMMIT;
  null;
END delete_temp_table_data;

PROCEDURE rollback_resp_tables
IS
PRAGMA AUTONOMOUS_TRANSACTION;

  CURSOR  get_cod_temp  IS
    SELECT  *
      FROM  IGF_SL_COD_TEMP;
  l_temp  get_cod_temp%ROWTYPE;
BEGIN
  -- Remove data from resp tables because of any of the following reasons
  -- 1. Destination entity id is not correct.
  -- 2. It is a receipt document
  -- 3. Invalid Full_Resp_code value
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_upload_xml.rollback_resp_tables.debug','Removing data from resp tables');
  END IF;

  FOR l_temp IN get_cod_temp
  LOOP
    IF l_temp.LEVEL_CODE = 'CR' THEN
      DELETE IGF_SL_CR_RESP_DTLS WHERE DOCUMENT_ID_TXT = l_temp.REC_ID;
    ELSIF l_temp.LEVEL_CODE = 'RS' THEN
      DELETE IGF_SL_RS_RESP_DTLS WHERE REP_SCHL_RESP_ID = l_temp.REC_ID;
    ELSIF l_temp.LEVEL_CODE = 'AS' THEN
      DELETE IGF_SL_AS_RESP_DTLS WHERE  ATD_SCHL_RESP_ID = l_temp.REC_ID;
    ELSIF l_temp.LEVEL_CODE = 'ST' THEN
      DELETE IGF_SL_ST_RESP_DTLS WHERE STDNT_RESP_ID = l_temp.REC_ID;
    ELSIF l_temp.LEVEL_CODE = 'AWD' THEN
      DELETE IGF_SL_DL_RESP_DTLS WHERE DL_LOAN_RESP_ID = l_temp.REC_ID;
    ELSIF l_temp.LEVEL_CODE = 'DL_DB' THEN
      DELETE IGF_SL_DLDB_RSP_DTL WHERE DISB_RESP_ID = l_temp.REC_ID;
    ELSIF l_temp.LEVEL_CODE = 'PELL' THEN
      DELETE IGF_GR_RESP_DTLS WHERE PELL_RESP_ID = l_temp.REC_ID;
    ELSIF l_temp.LEVEL_CODE = 'PELL_DB' THEN
      DELETE IGF_GR_DB_RESP_DTLS WHERE DISB_RESP_ID = l_temp.REC_ID;
    ELSIF l_temp.LEVEL_CODE = 'DL_INFO' THEN
      DELETE IGF_SL_DI_RESP_DTLS WHERE DL_INFO_ID = l_temp.REC_ID;
    END IF;
  END LOOP;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_upload_xml.rollback_resp_tables.debug','Removing data from IGF_SL_COD_TEMP');
  END IF;
  DELETE IGF_SL_COD_TEMP;

  COMMIT;
END rollback_resp_tables;

FUNCTION check_entityid(
                        p_entity_id  VARCHAR2
                       ) RETURN BOOLEAN
AS
-----------------------------------------------------------------------------------
--
--   Created By : ugummall
--   Date Created On : 2004/09/21
--   Purpose : Check if a particular entity ID is configured as a SWS Entity ID
--             into the OSS System
--   Know limitations, enhancements or remarks
--   Change History:
-----------------------------------------------------------------------------------
--   Who        When             What
-----------------------------------------------------------------------------------
  CURSOR  chk_id (cp_entity_id VARCHAR2)  IS
    SELECT  REP.ORG_ALTERNATE_ID ENTITY_ID
      FROM  IGS_OR_ORG_ALT_IDS REP,
            IGS_OR_ORG_ALT_IDTYP_V REPID
     WHERE  REP.ORG_ALTERNATE_ID_TYPE = REPID.ORG_ALTERNATE_ID_TYPE
      AND   REPID.SYSTEM_ID_TYPE = 'ENTITY_ID'
      AND   SYSDATE BETWEEN REP.START_DATE AND NVL(REP.END_DATE, SYSDATE)
      AND   REP.ORG_ALTERNATE_ID = cp_entity_id;
  l_entity_id IGF_GR_REPORT_PELL.REP_ENTITY_ID_TXT%TYPE;

BEGIN
  l_entity_id := NULL;
  OPEN chk_id(p_entity_id);
  FETCH chk_id INTO l_entity_id;
  CLOSE chk_id;

  IF l_entity_id IS NULL THEN
    RETURN FALSE;
  ELSE
    RETURN TRUE;
  END IF;

EXCEPTION
  WHEN others THEN
    fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','igf_sl_upload_xml.check_entityid');
    igs_ge_msg_stack.add;
    app_exception.raise_exception;
END check_entityid;
/* -----------------------------------------------------------------------------------
   Know limitations, enhancements or remarks
   Change History:
-----------------------------------------------------------------------------------
  Who        When             What
tsailaja                  15/Jan/2006     Bug 4947880 Added invocation of igf_aw_gen.set_org_id(NULL);
-----------------------------------------------------------------------------------
*/
PROCEDURE main  ( errbuf        OUT     NOCOPY    VARCHAR2,
                  retcode       OUT     NOCOPY    NUMBER,
                  p_file_path   IN                VARCHAR2
                )
AS
  CURSOR  get_doc ( cp_doc_id VARCHAR2) IS
    SELECT  ROWID ROW_ID, docdtls.*
      FROM  IGF_SL_COD_DOC_DTLS docdtls
     WHERE  DOCUMENT_ID_TXT = cp_doc_id;
  l_get_doc get_doc%ROWTYPE;

  CURSOR  get_event_key IS
    SELECT  IGF_SL_LOAD_XML_S.NEXTVAL
      FROM  DUAL;

  l_parameter_list  wf_parameter_list_t := wf_parameter_list_t();

  l_event_name      VARCHAR2(255);
  l_event_key       VARCHAR2(240);
  l_map_code        VARCHAR2(255);

  l_temp            VARCHAR2(30);
  l_sql_stmt        VARCHAR2(200);
  l_start_pos       NUMBER;
  l_file_path       VARCHAR2(1000);
  srcFile           BFILE ;
  intLen            INT;
  tmpClob1          CLOB;
  tmpClob           CLOB;
  MYCLOB_TEXT       VARCHAR2(11000);
  l_doc_id          VARCHAR2(30);
  lv_file           UTL_FILE.FILE_TYPE;
  ln_start_pos      INTEGER;
  ln_end_pos        INTEGER;
  l_endofdir        NUMBER;
  l_temp_endofdir   NUMBER;
  lv_directory      VARCHAR2(300);
  lv_filename       VARCHAR2(300);
  ln_file_line_num  NUMBER;
BEGIN
  igf_aw_gen.set_org_id(NULL);
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_upload_xml.main.debug','main started');
  END IF;

  -- Step 1. Print the log parameters
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_upload_xml.main.debug','file path is: ' || p_file_path);
  END IF;
  fnd_file.put_line(fnd_file.log,'File Path : '||p_file_path);

  -- Step 2. Get the XML file from the file path and store it in COD_DOC_DTLS table.
  -- Seperate directory and filename
  l_file_path := p_file_path;
  l_endofdir := 0;
  l_temp_endofdir := 0;
  LOOP
    l_temp_endofdir := INSTR(l_file_path, '/', l_temp_endofdir+1, 1);
    IF l_temp_endofdir = 0 THEN
      EXIT;
    END IF;
    l_endofdir := l_temp_endofdir;
  END LOOP;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_upload_xml.main.debug','Final value of l_endofdire is: ' || l_endofdir);
  END IF;

  lv_directory := SUBSTR(l_file_path, 1, l_endofdir-1);
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_upload_xml.main.debug','lv_directory: ' || lv_directory);
  END IF;
  lv_filename := SUBSTR(l_file_path, l_endofdir+1);
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_upload_xml.main.debug','lv_filename: ' || lv_filename);
  END IF;

  -- Open the file
  BEGIN
    lv_file := utl_file.fopen(lv_directory, lv_filename, 'r', 32767);
  EXCEPTION
  WHEN UTL_FILE.INVALID_PATH THEN
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_upload_xml.main.debug','UTL_FILE.INVALID_PATH Exception occurred');
    END IF;
    RAISE;
    RETURN;
  WHEN UTL_FILE.INVALID_MODE THEN
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_upload_xml.main.debug','UTL_FILE.INVALID_MODE Exception occurred');
    END IF;
    RAISE;
    RETURN;
  WHEN UTL_FILE.INVALID_OPERATION THEN
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_upload_xml.main.debug','UTL_FILE.INVALID_OPERATION Exception occurred');
    END IF;
    RAISE;
    RETURN;
  END;

  -- Here tmpClob is the final CLOB output, not tmpClob1
  -- Open tmpClob1.
  tmpClob1  :=  EMPTY_CLOB;
  DBMS_LOB.CREATETEMPORARY(tmpClob1,TRUE,DBMS_LOB.SESSION);
  DBMS_LOB.OPEN(tmpClob1,DBMS_LOB.LOB_READWRITE);
  IF DBMS_LOB.ISOPEN(tmpClob1) = 1 THEN
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_upload_xml.main.debug','tmpClob1 IS opened successfully');
    END IF;
  ELSE
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_upload_xml.main.debug','tmpClob1 is NOT opened successfully');
    END IF;
    RETURN;
  END IF;

  -- Create tmpClob1 from the file.
  ln_file_line_num := 0;
  BEGIN
    LOOP
      -- When EOF reaches, GET_LINE raises NO DATA FOUND Exception.
      ln_file_line_num := ln_file_line_num + 1;
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_upload_xml.main.debug', 'Before reading line number: ' || ln_file_line_num);
      END IF;

      UTL_FILE.GET_LINE(lv_file, myclob_text);

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_upload_xml.main.debug', 'After reading line number: ' || ln_file_line_num || 'Length of the text is: ' || LENGTH(myclob_text) || 'Start of the text is: ' || SUBSTR(myclob_text, 1, 32));
      END IF;

      IF myclob_text IS NOT NULL AND LENGTH(myclob_text) <> 0 THEN
        DBMS_LOB.WRITEAPPEND(tmpClob1, LENGTH(myclob_text), myclob_text);
      END IF;

    END LOOP;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- This will Auto-Close the file when EOF Reaches
      UTL_FILE.FCLOSE(lv_file);
    WHEN OTHERS THEN
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_upload_xml.main.debug','Exception occurred while creating tmpClob1');
      END IF;
      RAISE;
      RETURN;
  END;

  -- Open tmpClob
  tmpClob :=  EMPTY_CLOB;
  DBMS_LOB.CREATETEMPORARY(tmpClob,TRUE,DBMS_LOB.SESSION);
  DBMS_LOB.OPEN(tmpClob,DBMS_LOB.LOB_READWRITE);
  IF DBMS_LOB.ISOPEN(tmpClob1) = 1 THEN
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_upload_xml.main.debug','tmpClob IS opened successfully');
    END IF;
  ELSE
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_upload_xml.main.debug','tmpClob is NOT opened successfully');
    END IF;
    RETURN;
  END IF;

  -- Copy from tmpClob1 to tmpClob
  ln_start_pos :=  DBMS_LOB.INSTR(tmpClob1,'<CommonRecord',1,1);
  ln_end_pos   :=  DBMS_LOB.INSTR(tmpClob1,'</CommonRecord>',1,1);
  ln_end_pos   :=  ln_end_pos + LENGTH('</CommonRecord>');
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_upload_xml.main.debug', 'Start of <CommonRecord ie ln_start_pos is: ' || ln_start_pos || 'End of </CommonRecord> ie ln_end_pos is: ' || ln_end_pos);
  END IF;
  DBMS_LOB.COPY(tmpClob, tmpClob1, ln_end_pos-ln_start_pos, 1, ln_start_pos);

  -- Try to find out the document id from the file
  MYCLOB_TEXT := TRIM(DBMS_LOB.SUBSTR(tmpClob,10000,1));
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_upload_xml.main.debug','MYCLOB_TEXT is read successfully: '||SUBSTR(MYCLOB_TEXT, 1, 1000));
  END IF;

  l_start_pos :=  INSTR(MYCLOB_TEXT,'<DocumentID>',1,1);
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_upload_xml.main.debug','l_start_pos is: ' || l_start_pos);
  END IF;

  IF l_start_pos = 0 THEN
    fnd_message.set_name('IGF','IGF_SL_COD_IB_NO_XML_DOC_ID');
    fnd_file.put_line(fnd_file.log, fnd_message.get);
          RETURN;
  ELSE
    l_doc_id := SUBSTR(MYCLOB_TEXT,(l_start_pos+12),30);
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_upload_xml.main.debug','Document ID read from XML is: ' || l_doc_id);
    END IF;
  END IF;

  -- Insert/Update the IGF_SL_COD_DOC_DTLS TABLE
  l_get_doc := NULL;
  OPEN  get_doc(l_doc_id);
  FETCH get_doc INTO l_get_doc;
  CLOSE get_doc;

  IF l_get_doc.ROW_ID IS NULL THEN
    l_get_doc.doc_type := 'COD';
  END IF;
  igf_sl_cod_doc_dtls_pkg.add_row (
      x_mode                     => 'R',
      x_rowid                    => l_get_doc.ROW_ID,
      x_document_id_txt          => l_doc_id,
      x_outbound_doc             => l_get_doc.outbound_doc,
      x_inbound_doc              => tmpClob,
      x_send_date                => l_get_doc.send_date,
      x_ack_date                 => SYSDATE,
      x_doc_status               => 'R',
      x_doc_type                 => l_get_doc.doc_type,
      x_full_resp_code           => l_get_doc.full_resp_code
  );
  COMMIT;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_upload_xml.main.debug','Document successfully loaded in table');
  END IF;

  -- Step 3. Raise the business event.
  l_event_name  := 'oracle.apps.igf.sl.loadxml';
  l_map_code  := 'IGF_SL_INBOUND';
  l_event_key := NULL;
  OPEN get_event_key;
  FETCH get_event_key INTO l_event_key;
  CLOSE get_event_key;

  -- Now add the parameters to the list to be passed to the workflow
  wf_event.addparametertolist(
     p_name  => 'EVENT_NAME',
     p_value => l_event_name,
     p_parameterlist => l_parameter_list
     );
  wf_event.addparametertolist(
    p_name => 'EVENT_KEY',
    p_value => l_event_key,
    p_parameterlist => l_parameter_list
    );
  wf_event.addparametertolist(
    p_name => 'ECX_MAP_CODE',
    p_value => l_map_code,
    p_parameterlist => l_parameter_list
    );
  wf_event.addparametertolist(
    p_name => 'ECX_PARAMETER1',
    p_value => l_doc_id,
    p_parameterlist => l_parameter_list
    );

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_upload_xml.main.debug','Raising business event with key: ' || l_event_key);
  END IF;
  -- raise the business event
  wf_event.RAISE (
           p_event_name      => l_event_name,
           p_event_key       => l_event_key,
           p_parameters      => l_parameter_list
        );

  fnd_message.set_name('IGF','IGF_SL_COD_INBOUND_EVENT');
  fnd_message.set_token('EVENT_KEY_VALUE',l_event_key);
  fnd_file.put_line(fnd_file.log,fnd_message.get);

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    retcode := 2;
    errbuf  := fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION');
    fnd_file.put_line(fnd_file.log, SQLERRM);
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_upload_xml.main.debug','sqlerrm ' || SQLERRM);
    END IF;
    igs_ge_msg_stack.conc_exception_hndl;
END main;

PROCEDURE upload_xml  ( itemtype      IN              VARCHAR2,
                        itemkey       IN              VARCHAR2,
                        actid         IN              NUMBER,
                        funcmode      IN              VARCHAR2,
                        resultout     OUT NOCOPY      VARCHAR2
                      )
AS
  l_doc_id        VARCHAR2(30);
  l_wf_event      wf_event_t;
  newxmldoc       CLOB;
  buffer          VARCHAR2(32767);

BEGIN
  -- This is called by workflow. Read XML File from the table, then add <CR> Tag
  -- and initialize the workflow event data with two this new xml as parameter.

  DECLARE
    xmldoc          CLOB;
    buffer          VARCHAR2(32767);
    amount          BINARY_INTEGER;
    l_start_pos     INTEGER;
    new_l_start_pos INTEGER;
    new_end_pos     INTEGER;
    new_xml_len     INTEGER;
    flag            INTEGER;
    nth_occur       INTEGER;
    new_l_start_pos_buffer INTEGER;
    end_tag         INTEGER;

  BEGIN
    l_doc_id := wf_engine.getitemattrtext ( itemtype, itemkey, 'ECX_PARAMETER1');
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_upload_xml.upload_xml.debug','Document Id from the ECX_PARAMETER1' || l_doc_id);
    END IF;

    SELECT INBOUND_DOC INTO xmldoc FROM igf_sl_cod_doc_dtls WHERE DOCUMENT_ID_TXT = l_doc_id;
    SELECT INBOUND_DOC INTO newxmldoc FROM igf_sl_cod_doc_dtls WHERE DOCUMENT_ID_TXT = l_doc_id FOR UPDATE;

    new_xml_len := DBMS_LOB.GETLENGTH(newxmldoc);
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_upload_xml.upload_xml.debug','Before erasing the newxmldoc. Its length new_xml_len is '||new_xml_len);
    END IF;
    DBMS_LOB.ERASE(newxmldoc, new_xml_len, 1);

    buffer := '<CR>
        <CommonRecord>';
    amount := LENGTH(buffer);
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_upload_xml.upload_xml.debug','Writing root tags into newxmldoc');
    END IF;
    DBMS_LOB.WRITE(newxmldoc, amount, 1, buffer);
    --akomurav one off 4873868
    -- Remove the xsi:nil tags from the inbound file
    new_l_start_pos := DBMS_LOB.INSTR(xmldoc,'<DocumentID>',1,1);
    new_l_start_pos_buffer :=new_xml_len;
    flag := 1;
    nth_occur := 1;
    while (flag =1) loop
          new_end_pos := DBMS_LOB.INSTR(xmldoc,'xsi:nil',1,nth_occur);
          if new_end_pos > 0 then
              DBMS_LOB.COPY(newxmldoc,xmldoc,new_end_pos-new_l_start_pos,amount+1,new_l_start_pos);
              nth_occur := nth_occur + 1;
              amount := amount+(new_end_pos-new_l_start_pos);
              end_tag := DBMS_LOB.INSTR(xmldoc,'>',new_end_pos+1,1);
              new_l_start_pos := end_tag;
          end if;
          if new_end_pos = 0 then
              flag:=0;
          end if;
    end loop;

    DBMS_LOB.COPY(newxmldoc,xmldoc,new_l_start_pos_buffer-new_l_start_pos+1,amount+1,new_l_start_pos);
    buffer := '</CR>';
    amount := LENGTH(buffer);
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_upload_xml.upload_xml.debug','Appending </CR> tag');
    END IF;
    DBMS_LOB.WRITEAPPEND(newxmldoc, amount, buffer);
  END;

  -- set the workflow attributes
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_upload_xml.upload_xml.debug','Before setting workflow attributes');
  END IF;
  wf_event_t.Initialize(l_wf_event);
  l_wf_event.setEventData(newxmldoc);
  wf_engine.SetItemAttrEvent(itemtype,itemkey,'ECX_EVENT_MESSAGE',l_wf_event);
  resultout := 'P';

EXCEPTION
  WHEN OTHERS THEN
    resultout := 'F';
    wf_core.context ('IGF_SL_UPLOAD_XML',
                      'UPLOAD_XML', itemtype,
                       itemkey,to_char(actid), funcmode);
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_upload_xml.upload_xml.debug','sqlerrm ' || SQLERRM);
    END IF;
END upload_xml;

PROCEDURE print_edits ( p_id      IN  VARCHAR2,
                        p_level   IN  VARCHAR2
                      )
AS

  CURSOR  get_records ( cp_id VARCHAR2,
                        cp_level VARCHAR2)  IS
    SELECT  *
      FROM  IGF_SL_REJ_EDIT_V
     WHERE  EDIT_ID = cp_id
      AND   LEVEL_CODE = cp_level;
  rec_get_records get_records%ROWTYPE;
  lv_lookup_code  VARCHAR2(30);
BEGIN
  -- Print the level for which the edit results are pritned.
  OPEN get_records(p_id, p_level);
  FETCH get_records INTO rec_get_records;
  IF get_records%FOUND THEN
    lv_lookup_code := p_level || '_EDIT_RSLTS';
    fnd_file.put_line(fnd_file.log, igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS',lv_lookup_code));
  END IF;
  CLOSE get_records;

  FOR l_record IN get_records(p_id, p_level)
  LOOP
    fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','EDIT_CD')|| ':'||l_record.EDIT_CODE);
    fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','EDIT_CD_TYP')|| ':'||l_record.EDIT_CODE_TYPE);
    fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','ERR_FLD')|| ':'||l_record.RESP_ERR_FIELD);
    fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','ERR_VAL')|| ':'||l_record.RESP_ERR_VALUE);
    fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','REPT_VAL')|| ':'||l_record.REPORTED_VALUE);
    fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','EDIT_MSG')|| ':'||l_record.EDIT_MESSAGE_TXT);
    fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','EDIT_COND')|| ':'||l_record.EDIT_CONDITION_TXT);
    fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','EDIT_FIX')|| ':'||l_record.EDIT_FIX_TXT);
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','igf_sl_upload_xml.print_edits');
    igs_ge_msg_stack.add;
    app_exception.raise_exception;
END print_edits;

PROCEDURE process_dl_records  ( p_st_id         IN    NUMBER,
                                p_rej_flg       IN    BOOLEAN,
                                p_type          IN    VARCHAR2
                              )
AS

  CURSOR  get_dl_resp ( cp_st_id  NUMBER) IS
    SELECT  *
      FROM  IGF_SL_DL_RESP_DTLS
     WHERE  STDNT_RESP_ID = cp_st_id
      AND   NVL(STATUS_CODE, '*') <> 'P';

  CURSOR  get_dl_db_resp  ( cp_dl_id  NUMBER) IS
    SELECT  *
      FROM  IGF_SL_DLDB_RSP_DTL
     WHERE  DL_LOAN_RESP_ID = cp_dl_id
      AND   NVL(STATUS_CODE, '*') <> 'P';

  CURSOR  get_dl_rec  ( cp_dl_num       VARCHAR2,
                        cp_fin_awd_yr   VARCHAR2
                      ) IS
    SELECT  *
      FROM  IGF_SL_LOR_LOC_ALL
     WHERE  LOAN_NUMBER = cp_dl_num
      AND   FIN_AWARD_YEAR = cp_fin_awd_yr;
  l_dl_rec  get_dl_rec%ROWTYPE;

  CURSOR  get_dl_db_rec ( cp_awd_id         NUMBER,
                          cp_disb_seq_num   NUMBER,
                          cp_disb_num       NUMBER
                       )  IS
    SELECT  *
      FROM  IGF_AW_DB_CHG_DTLS
     WHERE  AWARD_ID = cp_awd_id
      AND   DISB_NUM = cp_disb_num
      AND   DISB_SEQ_NUM = cp_disb_seq_num;
  l_dl_db_rec get_dl_db_rec%ROWTYPE;

  -- Curosrs for the loan records updation
  CURSOR  c_tbh_cur ( cp_loan_id    NUMBER) IS
    SELECT  igf_sl_lor.*
      FROM  IGF_SL_LOR
     WHERE  loan_id = cp_loan_id
     FOR UPDATE NOWAIT;
  l_tbh_cur c_tbh_cur%ROWTYPE;

  CURSOR  c_tbh_cur1  ( cp_loan_id  NUMBER) IS
    SELECT  igf_sl_lor_loc.*
      FROM  IGF_SL_LOR_LOC
     WHERE  loan_id = cp_loan_id
     FOR UPDATE NOWAIT;
  l_tbh_cur1  c_tbh_cur1%ROWTYPE;

  CURSOR  c_tbh_cur2  ( cp_loan_id  NUMBER) IS
    SELECT  igf_sl_loans.*
      FROM  IGF_SL_LOANS
     WHERE  loan_id = cp_loan_id
     FOR UPDATE NOWAIT;
  l_tbh_cur2  c_tbh_cur2%ROWTYPE;

  -- Cursors from the disbursements updation
  CURSOR  c_tbh_disb  ( cp_awd_id         NUMBER,
                        cp_disb_seq_num   NUMBER,
                        cp_disb_num       NUMBER
                       )  IS
    SELECT  *
      FROM  IGF_AW_DB_CHG_DTLS_V
     WHERE  AWARD_ID = cp_awd_id
      AND   DISB_NUM = cp_disb_num
      AND   DISB_SEQ_NUM = cp_disb_seq_num;
  l_tbh_disb  c_tbh_disb%ROWTYPE;

  CURSOR  c_tbh_disb1 ( cp_awd_id         NUMBER,
                        cp_disb_seq_num   NUMBER,
                       cp_disb_num        NUMBER
                       )  IS
    SELECT  *
      FROM  IGF_AW_DB_COD_DTLS_V
     WHERE  AWARD_ID = cp_awd_id
      AND   DISB_NUM = cp_disb_num
      AND   DISB_SEQ_NUM = cp_disb_seq_num;
  l_tbh_disb1 c_tbh_disb1%ROWTYPE;
  update_flag   BOOLEAN;



BEGIN

  FOR l_dl_resp IN get_dl_resp(p_st_id)
  LOOP
    fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','PROC_DL_NUM')||':' ||l_dl_resp.LOAN_NUMBER_TXT);
    fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','RESP_ST')||':' ||l_dl_resp.RESP_CODE );

    l_dl_rec := NULL;
    OPEN get_dl_rec(l_dl_resp.LOAN_NUMBER_TXT,l_dl_resp.FIN_AWD_YR);
    FETCH get_dl_rec INTO l_dl_rec;
    CLOSE get_dl_rec;

    IF l_dl_rec.loan_id IS NULL THEN
      fnd_message.set_name('IGF','IGF_SL_COD_SKIP');
      fnd_file.put_line(fnd_file.log,fnd_message.get);

      -- update the status to 'N' - Processed, Not found in the System
      UPDATE IGF_SL_DL_RESP_DTLS
      SET STATUS_CODE = 'N'
      WHERE DL_LOAN_RESP_ID = l_dl_resp.DL_LOAN_RESP_ID;
    ELSE


      l_tbh_cur := NULL;
      l_tbh_cur1 := NULL;
      l_tbh_cur2 := NULL;

      -- igf_sl_lor_all
      OPEN c_tbh_cur(l_dl_rec.loan_id);
      FETCH c_tbh_cur INTO l_tbh_cur;
      CLOSE c_tbh_cur;

      -- igf_sl_lor_loc_all
      OPEN c_tbh_cur1(l_dl_rec.loan_id);
      FETCH c_tbh_cur1 INTO l_tbh_cur1;
      CLOSE c_tbh_cur1;

      -- igf_sl_loans
      OPEN c_tbh_cur2(l_dl_rec.loan_id);
      FETCH c_tbh_cur2 INTO l_tbh_cur2;
      CLOSE c_tbh_cur2;

      print_edits(l_dl_resp.DL_LOAN_RESP_ID,'DL');

      IF p_rej_flg = TRUE OR l_dl_resp.RESP_CODE = 'R' THEN
        -- update the IGF_SL_LOR_ALL with ORIG_STATUS_FLAG = 'R'
        l_tbh_cur.ORIG_STATUS_FLAG := 'R';

        -- update the IGF_SL_LOR_LOC_ALL with ORIG_STATUS_FLAG = 'R'
        l_tbh_cur1.ORIG_STATUS_FLAG := 'R';
        l_tbh_cur1.document_id_txt := g_doc_id;

        -- update IGF_SL_LOANS_ALL with LOAN_STATUS or LOAN_CHG_STATUS = 'R'
        IF l_tbh_cur2.LOAN_STATUS = 'S' THEN
          l_tbh_cur2.LOAN_STATUS := 'R';
          l_tbh_cur2.LOAN_STATUS_DATE := SYSDATE;
        ELSIF  l_tbh_cur2.LOAN_CHG_STATUS = 'S' THEN -- change down
          l_tbh_cur2.LOAN_CHG_STATUS := 'R';
          l_tbh_cur2.LOAN_CHG_STATUS_DATE := SYSDATE;
        END IF;
      ELSIF l_dl_resp.RESP_CODE ='A' THEN
        l_tbh_cur.ORIG_STATUS_FLAG := l_dl_resp.RESP_CODE;
        l_tbh_cur1.ORIG_STATUS_FLAG := l_dl_resp.RESP_CODE;
        l_tbh_cur1.document_id_txt := g_doc_id;

        IF l_tbh_cur2.LOAN_STATUS = 'S' THEN
          l_tbh_cur2.LOAN_STATUS := l_dl_resp.RESP_CODE;
        ELSIF  l_tbh_cur2.LOAN_CHG_STATUS = 'S' THEN
          l_tbh_cur2.LOAN_CHG_STATUS := l_dl_resp.RESP_CODE;
        END IF;

        -- compare the values in the resp record with the system record
        IF l_dl_resp.AWARD_AMT <> l_dl_rec.LOAN_AMT_ACCEPTED THEN
          fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','SYS_VAL_DL_AMT')||':' ||l_dl_rec.LOAN_AMT_ACCEPTED );
          fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','RESP_VAL_DL_AMT')||':' ||l_dl_resp.AWARD_AMT );
        END IF;

        -- 4582675. If the response document is of type RS, then update all the fields
        -- that would get updated if it had been CO, PN, PS or BN.

        IF p_type = 'CO' OR p_type = 'RS' THEN

          fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','END_AMT')||':' ||l_dl_resp.ENDORSER_AMT);
          fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','CRDT_DEC_ST')||':' ||l_dl_resp.CRDT_DECISION_STATUS);
          fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','CRDT_DEC_DT')||':' ||l_dl_resp.CRDT_DECISION_DATE);
          fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','CRDT_DEC_OVD')||':' ||l_dl_resp.CRDT_DECISION_OVRD_CODE);

          -- update these 4 cols in the tables IGF_SL_LOR_ALL, IGF_SL_LOR_LOC_ALL
          l_tbh_cur.CREDIT_OVERRIDE := NVL(l_dl_resp.CRDT_DECISION_OVRD_CODE, l_tbh_cur.CREDIT_OVERRIDE);
          l_tbh_cur.CREDIT_DECISION_DATE  := NVL(l_dl_resp.CRDT_DECISION_DATE, l_tbh_cur.CREDIT_DECISION_DATE);
          l_tbh_cur.crdt_decision_status := NVL(l_dl_resp.CRDT_DECISION_STATUS, l_tbh_cur.crdt_decision_status);
          l_tbh_cur.PNOTE_ACCEPT_AMT := NVL(l_dl_resp.ENDORSER_AMT, l_tbh_cur.PNOTE_ACCEPT_AMT);
          l_tbh_cur.PNOTE_BATCH_ID  := g_doc_id;

          l_tbh_cur1.CREDIT_OVERRIDE := NVL(l_dl_resp.CRDT_DECISION_OVRD_CODE, l_tbh_cur1.CREDIT_OVERRIDE);
          l_tbh_cur1.CREDIT_DECISION_DATE :=  NVL(l_dl_resp.CRDT_DECISION_DATE, l_tbh_cur1.CREDIT_DECISION_DATE);
          l_tbh_cur1.crdt_decision_status := NVL(l_dl_resp.CRDT_DECISION_STATUS, l_tbh_cur1.crdt_decision_status);
          l_tbh_cur1.PNOTE_ACCEPT_AMT := NVL(l_dl_resp.ENDORSER_AMT, l_tbh_cur1.PNOTE_ACCEPT_AMT);
          l_tbh_cur1.DOCUMENT_ID_TXT  := g_doc_id;

        END IF;

        IF p_type = 'PN' OR p_type = 'RS' OR p_type = 'CO' THEN

          fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','ELEC_MPN_FLAG')||':' ||l_dl_resp.ELEC_MPN_FLAG);
          fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','PNOTE_MPN_ID')||':' ||l_dl_resp.PNOTE_MPN_ID);
          fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','MPN_STATUS_CODE')||':' ||l_dl_resp.MPN_STATUS_CODE);
          fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','MPN_LINK_FLAG')||':' ||l_dl_resp.MPN_LINK_FLAG);

          -- update these 4 cols in the tables IGF_SL_LOR_ALL, IGF_SL_LOR_LOC_ALL
          l_tbh_cur.PNOTE_ID := NVL(l_dl_resp.PNOTE_MPN_ID, l_tbh_cur.PNOTE_ID);
          l_tbh_cur.PNOTE_STATUS := NVL(l_dl_resp.MPN_STATUS_CODE, l_tbh_cur.PNOTE_STATUS);
          l_tbh_cur.PNOTE_ACK_DATE  := NVL(g_process_date, l_tbh_cur.PNOTE_ACK_DATE);
          l_tbh_cur.PNOTE_STATUS_DATE := SYSDATE;

          IF (l_dl_resp.ELEC_MPN_FLAG IS NOT NULL) THEN
            IF (l_dl_resp.ELEC_MPN_FLAG = 'true') THEN
              l_tbh_cur.ELEC_MPN_IND  := 'E';
            ELSIF (l_dl_resp.ELEC_MPN_FLAG = 'false') THEN
              l_tbh_cur.ELEC_MPN_IND  := 'P';
            END IF;
          END IF;

          IF (l_dl_resp.MPN_LINK_FLAG IS NOT NULL) THEN
            IF (l_dl_resp.MPN_LINK_FLAG = 'true') THEN
              l_tbh_cur.PNOTE_MPN_IND  := 'Y';
            ELSIF (l_dl_resp.MPN_LINK_FLAG = 'false') THEN
              l_tbh_cur.PNOTE_MPN_IND  := 'N';
            END IF;
          END IF;
          l_tbh_cur.PNOTE_BATCH_ID  := g_doc_id;

          l_tbh_cur1.PNOTE_ID := NVL(l_dl_resp.PNOTE_MPN_ID, l_tbh_cur1.PNOTE_ID);
          l_tbh_cur1.PNOTE_STATUS :=  NVL(l_dl_resp.MPN_STATUS_CODE, l_tbh_cur1.PNOTE_STATUS);
          l_tbh_cur1.PNOTE_PRINT_IND   := NVL(l_tbh_cur.ELEC_MPN_IND, l_tbh_cur1.PNOTE_PRINT_IND);
          l_tbh_cur1.PNOTE_MPN_IND := NVL(l_tbh_cur.PNOTE_MPN_IND, l_tbh_cur1.PNOTE_MPN_IND);
          l_tbh_cur1.DOCUMENT_ID_TXT  := g_doc_id;

        END IF;

        IF p_type = 'PS' OR p_type = 'RS' THEN

          fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','PYMT_SERVICER_AMT')||':' ||l_dl_resp.PYMT_SERVICER_AMT);
          fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','PYMT_SERVICER_DATE')||':' ||l_dl_resp.PYMT_SERVICER_DATE);

          -- update these 2 cols in the tables IGF_SL_LOR_ALL, IGF_SL_LOR_LOC_ALL
          -- IN LOR_ALL OLD+NEW PYMT AMOUNT
          l_tbh_cur1.pymt_servicer_amt :=  NVL(l_tbh_cur1.pymt_servicer_amt,0) + NVL(l_dl_resp.PYMT_SERVICER_AMT,0);
          l_tbh_cur1.pymt_servicer_date  := NVL(l_dl_resp.PYMT_SERVICER_DATE, l_tbh_cur1.pymt_servicer_date);
          l_tbh_cur1.DOCUMENT_ID_TXT  := g_doc_id;

        END IF;

        IF p_type = 'BN' OR p_type = 'RS' THEN

          fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','BOOK_LOAN_AMT')||':' ||l_dl_resp.BOOK_LOAN_AMT);
          fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','BOOK_LOAN_AMT_DATE')||':' ||l_dl_resp.BOOK_LOAN_AMT_DATE);

          -- update these 2 cols in the tables IGF_SL_LOR_ALL, IGF_SL_LOR_LOC_ALL  and the document_id also
          l_tbh_cur.BOOK_LOAN_AMT :=  NVL(l_dl_resp.BOOK_LOAN_AMT, l_tbh_cur.BOOK_LOAN_AMT);
          l_tbh_cur.BOOK_LOAN_AMT_DATE  := NVL(l_dl_resp.BOOK_LOAN_AMT_DATE, l_tbh_cur.BOOK_LOAN_AMT_DATE);
          l_tbh_cur.PNOTE_BATCH_ID  := g_doc_id;

          l_tbh_cur1.BOOK_LOAN_AMT :=  NVL(l_dl_resp.BOOK_LOAN_AMT, l_tbh_cur1.BOOK_LOAN_AMT);
          l_tbh_cur1.BOOK_LOAN_AMT_DATE  := NVL(l_dl_resp.BOOK_LOAN_AMT_DATE, l_tbh_cur1.BOOK_LOAN_AMT_DATE);
          l_tbh_cur1.DOCUMENT_ID_TXT  := g_doc_id;

        END IF;
      END IF;

      igf_sl_lor_pkg.update_row (
                    X_Mode                              => 'R',
                    x_rowid                             => l_tbh_cur.row_id,
                    x_origination_id                    => l_tbh_cur.origination_id,
                    x_loan_id                           => l_tbh_cur.loan_id,
                    x_sch_cert_date                     => l_tbh_cur.sch_cert_date,
                    x_orig_status_flag                  => l_tbh_cur.orig_status_flag,
                    x_orig_batch_id                     => l_tbh_cur.orig_batch_id,
                    x_orig_batch_date                   => l_tbh_cur.orig_batch_date,
                    x_chg_batch_id                      => l_tbh_cur.chg_batch_id,
                    x_orig_ack_date                     => l_tbh_cur.orig_ack_date,
                    x_credit_override                   => l_tbh_cur.credit_override,
                    x_credit_decision_date              => l_tbh_cur.credit_decision_date,
                    x_req_serial_loan_code              => l_tbh_cur.req_serial_loan_code,
                    x_act_serial_loan_code              => l_tbh_cur.act_serial_loan_code,
                    x_pnote_delivery_code               => l_tbh_cur.pnote_delivery_code,
                    x_pnote_status                      => l_tbh_cur.pnote_status,
                    x_pnote_status_date                 => l_tbh_cur.pnote_status_date,
                    x_pnote_id                          => l_tbh_cur.pnote_id,
                    x_pnote_print_ind                   => l_tbh_cur.pnote_print_ind,
                    x_pnote_accept_amt                  => l_tbh_cur.pnote_accept_amt,
                    x_pnote_accept_date                 => l_tbh_cur.pnote_accept_date,
                    x_unsub_elig_for_heal               => l_tbh_cur.unsub_elig_for_heal,
                    x_disclosure_print_ind              => l_tbh_cur.disclosure_print_ind,
                    x_orig_fee_perct                    => l_tbh_cur.orig_fee_perct,
                    x_borw_confirm_ind                  => l_tbh_cur.borw_confirm_ind,
                    x_borw_interest_ind                 => l_tbh_cur.borw_interest_ind,
                    x_borw_outstd_loan_code             => l_tbh_cur.borw_outstd_loan_code,
                    x_unsub_elig_for_depnt              => l_tbh_cur.unsub_elig_for_depnt,
                    x_guarantee_amt                     => l_tbh_cur.guarantee_amt,
                    x_guarantee_date                    => l_tbh_cur.guarantee_date,
                    x_guarnt_amt_redn_code              => l_tbh_cur.guarnt_amt_redn_code,
                    x_guarnt_status_code                => l_tbh_cur.guarnt_status_code,
                    x_guarnt_status_date                => l_tbh_cur.guarnt_status_date,
                    x_lend_apprv_denied_code            => NULL,
                    x_lend_apprv_denied_date            => NULL,
                    x_lend_status_code                  => l_tbh_cur.lend_status_code,
                    x_lend_status_date                  => l_tbh_cur.lend_status_date,
                    x_guarnt_adj_ind                    => l_tbh_cur.guarnt_adj_ind,
                    x_grade_level_code                  => l_tbh_cur.grade_level_code,
                    x_enrollment_code                   => l_tbh_cur.enrollment_code,
                    x_anticip_compl_date                => l_tbh_cur.anticip_compl_date,
                    x_borw_lender_id                    => NULL,
                    x_duns_borw_lender_id               => NULL,
                    x_guarantor_id                      => NULL,
                    x_duns_guarnt_id                    => NULL,
                    x_prc_type_code                     => l_tbh_cur.prc_type_code,
                    x_cl_seq_number                     => l_tbh_cur.cl_seq_number,
                    x_last_resort_lender                => l_tbh_cur.last_resort_lender,
                    x_lender_id                         => NULL,
                    x_duns_lender_id                    => NULL,
                    x_lend_non_ed_brc_id                => NULL,
                    x_recipient_id                      => NULL,
                    x_recipient_type                    => NULL,
                    x_duns_recip_id                     => NULL,
                    x_recip_non_ed_brc_id               => NULL,
                    x_rec_type_ind                      => l_tbh_cur.rec_type_ind,
                    x_cl_loan_type                      => l_tbh_cur.cl_loan_type,
                    x_cl_rec_status                     => NULL,
                    x_cl_rec_status_last_update         => NULL,
                    x_alt_prog_type_code                => l_tbh_cur.alt_prog_type_code,
                    x_alt_appl_ver_code                 => l_tbh_cur.alt_appl_ver_code,
                    x_mpn_confirm_code                  => NULL,
                    x_resp_to_orig_code                 => l_tbh_cur.resp_to_orig_code,
                    x_appl_loan_phase_code              => NULL,
                    x_appl_loan_phase_code_chg          => NULL,
                    x_appl_send_error_codes             => NULL,
                    x_tot_outstd_stafford               => l_tbh_cur.tot_outstd_stafford,
                    x_tot_outstd_plus                   => l_tbh_cur.tot_outstd_plus,
                    x_alt_borw_tot_debt                 => l_tbh_cur.alt_borw_tot_debt,
                    x_act_interest_rate                 => l_tbh_cur.act_interest_rate,
                    x_service_type_code                 => l_tbh_cur.service_type_code,
                    x_rev_notice_of_guarnt              => l_tbh_cur.rev_notice_of_guarnt,
                    x_sch_refund_amt                    => l_tbh_cur.sch_refund_amt,
                    x_sch_refund_date                   => l_tbh_cur.sch_refund_date,
                    x_uniq_layout_vend_code             => l_tbh_cur.uniq_layout_vend_code,
                    x_uniq_layout_ident_code            => l_tbh_cur.uniq_layout_ident_code,
                    x_p_person_id                       => l_tbh_cur.p_person_id,
                    x_p_ssn_chg_date                    => NULL,
                    x_p_dob_chg_date                    => NULL,
                    x_p_permt_addr_chg_date             => NULL,
                    x_p_default_status                  => l_tbh_cur.p_default_status,
                    x_p_signature_code                  => l_tbh_cur.p_signature_code,
                    x_p_signature_date                  => l_tbh_cur.p_signature_date,
                    x_s_ssn_chg_date                    => NULL,
                    x_s_dob_chg_date                    => NULL,
                    x_s_permt_addr_chg_date             => NULL,
                    x_s_local_addr_chg_date             => NULL,
                    x_s_default_status                  => l_tbh_cur.s_default_status,
                    x_s_signature_code                  => l_tbh_cur.s_signature_code,
                    x_pnote_batch_id                    => l_tbh_cur.pnote_batch_id,
                    x_pnote_ack_date                    => l_tbh_cur.pnote_ack_date,
                    x_pnote_mpn_ind                     => l_tbh_cur.pnote_mpn_ind ,
                    x_elec_mpn_ind                      => l_tbh_cur.elec_mpn_ind         ,
                    x_borr_sign_ind                     => l_tbh_cur.borr_sign_ind        ,
                    x_stud_sign_ind                     => l_tbh_cur.stud_sign_ind        ,
                    x_borr_credit_auth_code             => l_tbh_cur.borr_credit_auth_code ,
                    x_relationship_cd                   => l_tbh_cur.relationship_cd,
                    x_interest_rebate_percent_num       => l_tbh_cur.interest_rebate_percent_num,
                    x_cps_trans_num                     => l_tbh_cur.cps_trans_num   ,
                    x_atd_entity_id_txt                 => l_tbh_cur.atd_entity_id_txt,
                    x_rep_entity_id_txt                 => l_tbh_cur.rep_entity_id_txt,
                    x_crdt_decision_status              => l_tbh_cur.crdt_decision_status,
                    x_note_message                      => l_tbh_cur.note_message        ,
                    x_book_loan_amt                     => l_tbh_cur.book_loan_amt       ,
                    x_book_loan_amt_date                => l_tbh_cur.book_loan_amt_date,
                    x_actual_record_type_code        =>  l_tbh_cur.actual_record_type_code,
                    x_alt_approved_amt               =>  l_tbh_cur.alt_approved_amt,
                    x_deferment_request_code         =>  l_tbh_cur.deferment_request_code,
                    x_eft_authorization_code         =>  l_tbh_cur.eft_authorization_code,
                    x_external_loan_id_txt           =>  l_tbh_cur.external_loan_id_txt,
                    x_flp_approved_amt               =>  l_tbh_cur.flp_approved_amt,
                    x_fls_approved_amt               =>  l_tbh_cur.fls_approved_amt,
                    x_flu_approved_amt               =>  l_tbh_cur.flu_approved_amt,
                    x_guarantor_use_txt              =>  l_tbh_cur.guarantor_use_txt,
                    x_lender_use_txt                 =>  l_tbh_cur.lender_use_txt,
                    x_loan_app_form_code             =>  l_tbh_cur.loan_app_form_code,
                    x_override_grade_level_code      =>  l_tbh_cur.override_grade_level_code,
                    x_pymt_servicer_amt              =>  l_tbh_cur.pymt_servicer_amt,
                    x_pymt_servicer_date             =>  l_tbh_cur.pymt_servicer_date,
                    x_reinstatement_amt              =>  l_tbh_cur.reinstatement_amt,
                    x_requested_loan_amt             =>  l_tbh_cur.requested_loan_amt,
                    x_school_use_txt                 =>  l_tbh_cur.school_use_txt,
                    x_b_alien_reg_num_txt               =>  l_tbh_cur.b_alien_reg_num_txt,
                    x_esign_src_typ_cd                  =>  l_tbh_cur.esign_src_typ_cd,
                    x_acad_begin_date                   =>  l_tbh_cur.acad_begin_date,
                    x_acad_end_date                     =>  l_tbh_cur.acad_end_date);

      igf_sl_lor_loc_pkg.update_row (
             x_mode                              => 'R',
             x_rowid                             => l_tbh_cur1.row_id,
             x_loan_id                           => l_tbh_cur1.loan_id,
             x_origination_id                    => l_tbh_cur1.origination_id,
             x_loan_number                       => l_tbh_cur1.loan_number,
             x_loan_type                         => l_tbh_cur1.loan_type,
             x_loan_amt_offered                  => l_tbh_cur1.loan_amt_offered,
             x_loan_amt_accepted                 => l_tbh_cur1.loan_amt_accepted,
             x_loan_per_begin_date               => l_tbh_cur1.loan_per_begin_date,
             x_loan_per_end_date                 => l_tbh_cur1.loan_per_end_date,
             x_acad_yr_begin_date                => l_tbh_cur1.acad_yr_begin_date,
             x_acad_yr_end_date                  => l_tbh_cur1.acad_yr_end_date,
             x_loan_status                       => l_tbh_cur1.loan_status,
             x_loan_status_date                  => l_tbh_cur1.loan_status_date,
             x_loan_chg_status                   => l_tbh_cur1.loan_chg_status,
             x_loan_chg_status_date              => l_tbh_cur1.loan_chg_status_date,
             x_req_serial_loan_code              => l_tbh_cur1.req_serial_loan_code,
             x_act_serial_loan_code              => l_tbh_cur1.act_serial_loan_code,
             x_active                            => l_tbh_cur1.active,
             x_active_date                       => l_tbh_cur1.active_date,
             x_sch_cert_date                     => l_tbh_cur1.sch_cert_date,
             x_orig_status_flag                  => l_tbh_cur1.orig_status_flag,
             x_orig_batch_id                     => l_tbh_cur1.orig_batch_id,
             x_orig_batch_date                   => l_tbh_cur1.orig_batch_date,
             x_chg_batch_id                      => NULL,
             x_orig_ack_date                     => l_tbh_cur1.orig_ack_date,
             x_credit_override                   => l_tbh_cur1.credit_override,
             x_credit_decision_date              => l_tbh_cur1.credit_decision_date,
             x_pnote_delivery_code               => l_tbh_cur1.pnote_delivery_code,
             x_pnote_status                      => l_tbh_cur1.pnote_status,
             x_pnote_status_date                 => l_tbh_cur1.pnote_status_date,
             x_pnote_id                          => l_tbh_cur1.pnote_id,
             x_pnote_print_ind                   => l_tbh_cur1.pnote_print_ind,
             x_pnote_accept_amt                  => l_tbh_cur1.pnote_accept_amt,
             x_pnote_accept_date                 => l_tbh_cur1.pnote_accept_date,
             x_p_signature_code                  => l_tbh_cur1.p_signature_code,
             x_p_signature_date                  => l_tbh_cur1.p_signature_date,
             x_s_signature_code                  => l_tbh_cur1.s_signature_code,
             x_unsub_elig_for_heal               => l_tbh_cur1.unsub_elig_for_heal,
             x_disclosure_print_ind              => l_tbh_cur1.disclosure_print_ind,
             x_orig_fee_perct                    => l_tbh_cur1.orig_fee_perct,
             x_borw_confirm_ind                  => l_tbh_cur1.borw_confirm_ind,
             x_borw_interest_ind                 => l_tbh_cur1.borw_interest_ind,
             x_unsub_elig_for_depnt              => l_tbh_cur1.unsub_elig_for_depnt,
             x_guarantee_amt                     => l_tbh_cur1.guarantee_amt,
             x_guarantee_date                    => l_tbh_cur1.guarantee_date,
             x_guarnt_adj_ind                    => l_tbh_cur1.guarnt_adj_ind,
             x_guarnt_amt_redn_code              => l_tbh_cur1.guarnt_amt_redn_code,
             x_guarnt_status_code                => l_tbh_cur1.guarnt_status_code,
             x_guarnt_status_date                => l_tbh_cur1.guarnt_status_date,
             x_lend_apprv_denied_code            => NULL,
             x_lend_apprv_denied_date            => NULL,
             x_lend_status_code                  => l_tbh_cur1.lend_status_code,
             x_lend_status_date                  => l_tbh_cur1.lend_status_date,
             x_grade_level_code                  => l_tbh_cur1.grade_level_code,
             x_enrollment_code                   => l_tbh_cur1.enrollment_code,
             x_anticip_compl_date                => l_tbh_cur1.anticip_compl_date,
             x_borw_lender_id                    => l_tbh_cur1.borw_lender_id,
             x_duns_borw_lender_id               => NULL,
             x_guarantor_id                      => l_tbh_cur1.guarantor_id,
             x_duns_guarnt_id                    => NULL,
             x_prc_type_code                     => l_tbh_cur1.prc_type_code,
             x_rec_type_ind                      => l_tbh_cur1.rec_type_ind,
             x_cl_loan_type                      => l_tbh_cur1.cl_loan_type,
             x_cl_seq_number                     => l_tbh_cur1.cl_seq_number,
             x_last_resort_lender                => l_tbh_cur1.last_resort_lender,
             x_lender_id                         => l_tbh_cur1.lender_id,
             x_duns_lender_id                    => NULL,
             x_lend_non_ed_brc_id                => l_tbh_cur1.lend_non_ed_brc_id,
             x_recipient_id                      => l_tbh_cur1.recipient_id,
             x_recipient_type                    => l_tbh_cur1.recipient_type,
             x_duns_recip_id                     => NULL,
             x_recip_non_ed_brc_id               => l_tbh_cur1.recip_non_ed_brc_id,
             x_cl_rec_status                     => NULL,
             x_cl_rec_status_last_update         => NULL,
             x_alt_prog_type_code                => l_tbh_cur1.alt_prog_type_code,
             x_alt_appl_ver_code                 => l_tbh_cur1.alt_appl_ver_code,
             x_borw_outstd_loan_code             => l_tbh_cur1.borw_outstd_loan_code,
             x_mpn_confirm_code                  => NULL,
             x_resp_to_orig_code                 => l_tbh_cur1.resp_to_orig_code,
             x_appl_loan_phase_code              => NULL,
             x_appl_loan_phase_code_chg          => NULL,
             x_tot_outstd_stafford               => l_tbh_cur1.tot_outstd_stafford,
             x_tot_outstd_plus                   => l_tbh_cur1.tot_outstd_plus,
             x_alt_borw_tot_debt                 => l_tbh_cur1.alt_borw_tot_debt,
             x_act_interest_rate                 => l_tbh_cur1.act_interest_rate,
             x_service_type_code                 => l_tbh_cur1.service_type_code,
             x_rev_notice_of_guarnt              => l_tbh_cur1.rev_notice_of_guarnt,
             x_sch_refund_amt                    => l_tbh_cur1.sch_refund_amt,
             x_sch_refund_date                   => l_tbh_cur1.sch_refund_date,
             x_uniq_layout_vend_code             => l_tbh_cur1.uniq_layout_vend_code,
             x_uniq_layout_ident_code            => l_tbh_cur1.uniq_layout_ident_code,
             x_p_person_id                       => l_tbh_cur1.p_person_id,
             x_p_ssn                             => l_tbh_cur1.p_ssn,
             x_p_ssn_chg_date                    => NULL,
             x_p_last_name                       => l_tbh_cur1.p_last_name,
             x_p_first_name                      => l_tbh_cur1.p_first_name,
             x_p_middle_name                     => l_tbh_cur1.p_middle_name,
             x_p_permt_addr1                     => l_tbh_cur1.p_permt_addr1,
             x_p_permt_addr2                     => l_tbh_cur1.p_permt_addr2,
             x_p_permt_city                      => l_tbh_cur1.p_permt_city,
             x_p_permt_state                     => l_tbh_cur1.p_permt_state,
             x_p_permt_zip                       => l_tbh_cur1.p_permt_zip,
             x_p_permt_addr_chg_date             => l_tbh_cur1.p_permt_addr_chg_date,
             x_p_permt_phone                     => l_tbh_cur1.p_permt_phone,
             x_p_email_addr                      => l_tbh_cur1.p_email_addr,
             x_p_date_of_birth                   => l_tbh_cur1.p_date_of_birth,
             x_p_dob_chg_date                    => NULL,
             x_p_license_num                     => l_tbh_cur1.p_license_num,
             x_p_license_state                   => l_tbh_cur1.p_license_state,
             x_p_citizenship_status              => l_tbh_cur1.p_citizenship_status,
             x_p_alien_reg_num                   => l_tbh_cur1.p_alien_reg_num,
             x_p_default_status                  => l_tbh_cur1.p_default_status,
             x_p_foreign_postal_code             => l_tbh_cur1.p_foreign_postal_code,
             x_p_state_of_legal_res              => l_tbh_cur1.p_state_of_legal_res,
             x_p_legal_res_date                  => l_tbh_cur1.p_legal_res_date,
             x_s_ssn                             => l_tbh_cur1.s_ssn,
             x_s_ssn_chg_date                    => NULL,
             x_s_last_name                       => l_tbh_cur1.s_last_name,
             x_s_first_name                      => l_tbh_cur1.s_first_name,
             x_s_middle_name                     => l_tbh_cur1.s_middle_name,
             x_s_permt_addr1                     => l_tbh_cur1.s_permt_addr1,
             x_s_permt_addr2                     => l_tbh_cur1.s_permt_addr2,
             x_s_permt_city                      => l_tbh_cur1.s_permt_city,
             x_s_permt_state                     => l_tbh_cur1.s_permt_state,
             x_s_permt_zip                       => l_tbh_cur1.s_permt_zip,
             x_s_permt_addr_chg_date             => l_tbh_cur1.s_permt_addr_chg_date,
             x_s_permt_phone                     => l_tbh_cur1.s_permt_phone,
             x_s_local_addr1                     => l_tbh_cur1.s_local_addr1,
             x_s_local_addr2                     => l_tbh_cur1.s_local_addr2,
             x_s_local_city                      => l_tbh_cur1.s_local_city,
             x_s_local_state                     => l_tbh_cur1.s_local_state,
             x_s_local_zip                       => l_tbh_cur1.s_local_zip,
             x_s_local_addr_chg_date             => NULL,
             x_s_email_addr                      => l_tbh_cur1.s_email_addr,
             x_s_date_of_birth                   => l_tbh_cur1.s_date_of_birth,
             x_s_dob_chg_date                    => NULL,
             x_s_license_num                     => l_tbh_cur1.s_license_num,
             x_s_license_state                   => l_tbh_cur1.s_license_state,
             x_s_depncy_status                   => l_tbh_cur1.s_depncy_status,
             x_s_default_status                  => l_tbh_cur1.s_default_status,
             x_s_citizenship_status              => l_tbh_cur1.s_citizenship_status,
             x_s_alien_reg_num                   => l_tbh_cur1.s_alien_reg_num,
             x_s_foreign_postal_code             => l_tbh_cur1.s_foreign_postal_code,
             x_pnote_batch_id                    => l_tbh_cur1.pnote_batch_id,
             x_pnote_ack_date                    => l_tbh_cur1.pnote_ack_date,
             x_pnote_mpn_ind                     => l_tbh_cur1.pnote_mpn_ind,
             x_award_id                          => l_tbh_cur1.award_id     ,
             x_base_id                           => l_tbh_cur1.base_id       ,
             x_document_id_txt                   => l_tbh_cur1.document_id_txt    ,
             x_loan_key_num                      => l_tbh_cur1.loan_key_num   ,
             x_INTEREST_REBATE_PERCENT_NUM       => l_tbh_cur1.INTEREST_REBATE_PERCENT_NUM,
             x_fin_award_year                    => l_tbh_cur1.fin_award_year  ,
             x_cps_trans_num                     => l_tbh_cur1.cps_trans_num    ,
             x_ATD_ENTITY_ID_TXT                 => l_tbh_cur1.ATD_ENTITY_ID_TXT,
             x_REP_ENTITY_ID_TXT                 => l_tbh_cur1.REP_ENTITY_ID_TXT,
             x_SOURCE_ENTITY_ID_TXT              => l_tbh_cur1.SOURCE_ENTITY_ID_TXT,
             x_pymt_servicer_amt                 => l_tbh_cur1.pymt_servicer_amt  ,
             x_pymt_servicer_date                => l_tbh_cur1.pymt_servicer_date ,
             x_book_loan_amt                     => l_tbh_cur1.book_loan_amt      ,
             x_book_loan_amt_date                => l_tbh_cur1.book_loan_amt_date ,
             x_s_chg_birth_date                  => l_tbh_cur1.s_chg_birth_date   ,
             x_s_chg_ssn                         => l_tbh_cur1.s_chg_ssn          ,
             x_s_chg_last_name                   => l_tbh_cur1.s_chg_last_name    ,
             x_b_chg_birth_date                  => l_tbh_cur1.b_chg_birth_date   ,
             x_b_chg_ssn                         => l_tbh_cur1.b_chg_ssn          ,
             x_b_chg_last_name                   => l_tbh_cur1.b_chg_last_name    ,
             x_note_message                      => l_tbh_cur1.note_message       ,
             x_full_resp_code                    => l_tbh_cur1.full_resp_code     ,
             x_s_permt_county                    => l_tbh_cur1.s_permt_county     ,
             x_b_permt_county                    => l_tbh_cur1.b_permt_county     ,
             x_s_permt_country                   => l_tbh_cur1.s_permt_country    ,
             x_b_permt_country                   => l_tbh_cur1.b_permt_country    ,
             x_crdt_decision_status              => l_tbh_cur1.crdt_decision_status,
             x_actual_record_type_code        => l_tbh_cur1.actual_record_type_code,
             x_alt_approved_amt               => l_tbh_cur1.alt_approved_amt,
             x_alt_borrower_ind_flag          => l_tbh_cur1.alt_borrower_ind_flag,
             x_borower_credit_authoriz_flag   => l_tbh_cur1.borower_credit_authoriz_flag,
             x_borower_electronic_sign_flag   => l_tbh_cur1.borower_electronic_sign_flag,
             x_cost_of_attendance_amt         => l_tbh_cur1.cost_of_attendance_amt,
             x_deferment_request_code         => l_tbh_cur1.deferment_request_code,
             x_eft_authorization_code         => l_tbh_cur1.eft_authorization_code,
             x_established_fin_aid_amount     => l_tbh_cur1.established_fin_aid_amount,
             x_expect_family_contribute_amt   => l_tbh_cur1.expect_family_contribute_amt,
             x_external_loan_id_txt           => l_tbh_cur1.external_loan_id_txt,
             x_flp_approved_amt               => l_tbh_cur1.flp_approved_amt,
             x_fls_approved_amt               => l_tbh_cur1.fls_approved_amt,
             x_flu_approved_amt               => l_tbh_cur1.flu_approved_amt,
             x_guarantor_use_txt              => l_tbh_cur1.guarantor_use_txt,
             x_lender_use_txt                 => l_tbh_cur1.lender_use_txt,
             x_loan_app_form_code             => l_tbh_cur1.loan_app_form_code,
             x_mpn_type_flag                  => l_tbh_cur1.mpn_type_flag,
             x_reinstatement_amt              => l_tbh_cur1.reinstatement_amt,
             x_requested_loan_amt             => l_tbh_cur1.requested_loan_amt,
             x_school_id_txt                  => l_tbh_cur1.school_id_txt,
             x_school_use_txt                 => l_tbh_cur1.school_use_txt,
             x_student_electronic_sign_flag   => l_tbh_cur1.student_electronic_sign_flag,
            x_esign_src_typ_cd               =>  l_tbh_cur1.esign_src_typ_cd
);

      igf_sl_loans_pkg.update_row (
                 x_mode                              => 'R',
                 x_rowid                             => l_tbh_cur2.row_id,
                 x_loan_id                           => l_tbh_cur2.loan_id,
                 x_award_id                          => l_tbh_cur2.award_id,
                 x_seq_num                           => l_tbh_cur2.seq_num,
                 x_loan_number                       => l_tbh_cur2.loan_number,
                 x_loan_per_begin_date               => l_tbh_cur2.loan_per_begin_date,
                 x_loan_per_end_date                 => l_tbh_cur2.loan_per_end_date,
                 x_loan_status                       => l_tbh_cur2.loan_status,
                 x_loan_status_date                  => l_tbh_cur2.loan_status_date,
                 x_loan_chg_status                   => l_tbh_cur2.loan_chg_status,
                 x_loan_chg_status_date              => l_tbh_cur2.loan_chg_status_date,
                 x_active                            => l_tbh_cur2.active,
                 x_active_date                       => l_tbh_cur2.active_date,
                 x_borw_detrm_code                   => l_tbh_cur2.borw_detrm_code,
                 x_legacy_record_flag                => NULL,
                 x_external_loan_id_txt              => l_tbh_cur2.external_loan_id_txt);

      UPDATE IGF_SL_DL_RESP_DTLS
      SET STATUS_CODE = 'P'
      WHERE DL_LOAN_RESP_ID = l_dl_resp.DL_LOAN_RESP_ID;

      -- start the processing of Direct Loan Disbursements
      FOR l_dl_db_resp IN get_dl_db_resp(l_dl_resp.DL_LOAN_RESP_ID)
      LOOP
        fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','DISB_NUM')||':'||l_dl_db_resp.disb_num);
        fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','DISB_SEQ_NUM')||':' ||l_dl_db_resp.disb_seq_num);
        fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','RESP_ST')||':' ||l_dl_db_resp.RESP_CODE);

        l_dl_db_rec := NULL;
        OPEN get_dl_db_rec(l_dl_rec.AWARD_ID,l_dl_db_resp.disb_seq_num,l_dl_db_resp.disb_num);
        FETCH get_dl_db_rec INTO l_dl_db_rec;
        CLOSE get_dl_db_rec;

        l_tbh_disb := NULL;
        OPEN c_tbh_disb(l_dl_rec.AWARD_ID,l_dl_db_resp.disb_seq_num,l_dl_db_resp.disb_num);
        FETCH c_tbh_disb INTO l_tbh_disb;
        CLOSE c_tbh_disb;

        l_tbh_disb1 := NULL;
        OPEN c_tbh_disb1(l_dl_rec.AWARD_ID,l_dl_db_resp.disb_seq_num,l_dl_db_resp.disb_num);
        FETCH c_tbh_disb1 INTO l_tbh_disb1;
        CLOSE c_tbh_disb1;

        update_flag := FALSE;
        IF p_rej_flg = TRUE OR l_dl_db_resp.RESP_CODE = 'R' THEN
          -- update the table IGF_AW_DB_COD_DTLS with DISB_STATUS = 'R' , IGF_AW_DB_CHG_DTLS  DISB_STATUS = 'R'
          IF  l_dl_db_resp.disb_seq_num < 66 THEN
            IF l_tbh_disb.disb_seq_num IS NULL THEN
              -- disbursement record not found in the system. Log a mesg.
              fnd_message.set_name('IGF','IGF_SL_COD_SKIP');
              fnd_file.put_line(fnd_file.log,fnd_message.get);

              UPDATE IGF_SL_DLDB_RSP_DTL
              SET status_code = 'N'
              WHERE DISB_RESP_ID = l_dl_db_resp.DISB_RESP_ID;
              update_flag := FALSE;
            ELSE
              l_tbh_disb.DISB_STATUS := 'R';
              --l_tbh_disb1.DISB_STATUS := 'R';

              UPDATE IGF_SL_DLDB_RSP_DTL
              SET status_code = 'P'
              WHERE DISB_RESP_ID = l_dl_db_resp.DISB_RESP_ID;
              update_flag := TRUE;
            END IF;
          END IF;
        ELSE
          print_edits(l_dl_db_resp.DISB_RESP_ID,'DL_DB');
          IF  l_dl_db_resp.disb_seq_num < 66 THEN
            IF l_tbh_disb.disb_seq_num IS NULL THEN
              -- disbursement record not found in the system. Log a mesg.
              fnd_message.set_name('IGF','IGF_SL_COD_SKIP');
              fnd_file.put_line(fnd_file.log,fnd_message.get);

              -- update the status to 'N' - Processed, Not found in the System
              UPDATE IGF_SL_DLDB_RSP_DTL
              SET STATUS_CODE = 'N'
              WHERE DISB_RESP_ID = l_dl_db_resp.DISB_RESP_ID;
              update_flag := FALSE;
            ELSE
              IF l_dl_db_rec.DISB_ACCEPTED_AMT <> l_dl_db_resp.disb_amt THEN
                fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','SYS_VAL_DB_AMT')||':' ||l_dl_db_rec.DISB_ACCEPTED_AMT);
                fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','RESP_VAL_DB_AMT')||':' ||l_dl_db_resp.disb_amt);
                igf_gr_gen.insert_sys_holds(l_dl_rec.award_id,l_dl_db_rec.disb_num,'DL');
              END IF;
              IF l_dl_db_rec.disb_date <> l_dl_db_resp.disb_date THEN
                fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','SYS_VAL_DB_DT')||':' ||l_dl_db_rec.disb_date);
                fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','RESP_VAL_DB_DT')||':' ||l_dl_db_resp.disb_date);
              END IF;

              -- update in the table IGF_AW_DB_COD_DTLS , IGF_AW_DB_CHG_DTLS RESP_CODE,PREV_SEQ_NUM,STATUS
              l_tbh_disb.DISB_STATUS := l_dl_db_resp.RESP_CODE;
              --l_tbh_disb1.DISB_STATUS := l_dl_db_resp.RESP_CODE;
              --l_tbh_disb.PREV_SEQ_NUM := l_dl_db_resp.PREV_SEQ_NUM;
              --l_tbh_disb1.PREV_SEQ_NUM := l_dl_db_resp.PREV_SEQ_NUM;

              UPDATE IGF_SL_DLDB_RSP_DTL
              SET STATUS_CODE = 'P'
              WHERE DISB_RESP_ID = l_dl_db_resp.DISB_RESP_ID;
              update_flag := TRUE;
            END IF;
          ELSE  -- implies disb_seq_num > 65
            IF l_dl_db_resp.DISB_SEQ_NUM < 91 THEN
              fnd_message.set_name('IGF','IGF_SL_COD_SCHL_ADJ');
              fnd_file.put_line(fnd_file.log,fnd_message.get);
            ELSIF l_dl_db_resp.DISB_SEQ_NUM < 100 THEN
              fnd_message.set_name('IGF','IGF_SL_COD_GEN_DISB');
              fnd_file.put_line(fnd_file.log,fnd_message.get);
            END IF;

            fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','RESP_VAL_DB_AMT')||':' ||l_dl_db_resp.DISB_AMT);
            fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','RESP_VAL_DB_DT')||':' ||l_dl_db_resp.DISB_DATE);
            fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','RESP_VAL_PRV_SEQ_NUM')||':' ||l_dl_db_resp.PREV_SEQ_NUM);

            UPDATE IGF_SL_DLDB_RSP_DTL
            SET STATUS_CODE = 'P'
            WHERE DISB_RESP_ID = l_dl_db_resp.DISB_RESP_ID;
            update_flag := FALSE;
          END IF;
        END IF; -- for the rejected flag check

        IF (update_flag) THEN
          igf_aw_db_chg_dtls_pkg.update_row(
                    x_rowid                          => l_tbh_disb.row_id ,
                    x_award_id                       => l_tbh_disb.award_id,
                    x_disb_num                       => l_tbh_disb.disb_num ,
                    x_disb_seq_num                   => l_tbh_disb.disb_seq_num,
                    x_DISB_ACCEPTED_AMT              => l_tbh_disb.DISB_ACCEPTED_AMT,
                    x_orig_fee_amt                   => l_tbh_disb.orig_fee_amt  ,
                    x_disb_net_amt                   => l_tbh_disb.disb_net_amt  ,
                    x_disb_date                      => l_tbh_disb.disb_date     ,
                    x_disb_activity                  => l_tbh_disb.disb_activity ,
                    x_disb_status                    => l_tbh_disb.disb_status   ,
                    x_disb_status_date               => l_tbh_disb.disb_status_date,
                    x_disb_rel_flag                  => l_tbh_disb.disb_rel_flag    ,
                    x_first_disb_flag                => l_tbh_disb.first_disb_flag   ,
                    x_INTEREST_REBATE_AMT            => l_tbh_disb.INTEREST_REBATE_AMT,
                    x_disb_conf_flag                 => l_tbh_disb.disb_conf_flag      ,
                    x_pymnt_prd_start_date           => l_tbh_disb.pymnt_prd_start_date ,
                    x_note_message                   => l_tbh_disb.note_message          ,
                    x_batch_id_txt                   => l_tbh_disb.batch_id_txt              ,
                    x_ack_date                       => l_tbh_disb.ack_date              ,
                    x_booking_id_txt                     => l_tbh_disb.booking_id_txt           ,
                    x_booking_date                   => l_tbh_disb.booking_date           ,
                    x_mode                           => 'R'
          );
          igf_aw_db_cod_dtls_pkg.update_row(
                    x_rowid                          => l_tbh_disb1.row_id      ,
                    x_award_id                       => l_tbh_disb1.award_id    ,
                    x_document_id_txt                => l_tbh_disb1.document_id_txt  ,
                    x_disb_num                       => l_tbh_disb1.disb_num      ,
                    x_disb_seq_num                   => l_tbh_disb1.disb_seq_num  ,
                    x_DISB_ACCEPTED_AMT              => l_tbh_disb1.DISB_ACCEPTED_AMT,
                    x_orig_fee_amt                   => l_tbh_disb1.orig_fee_amt   ,
                    x_disb_net_amt                   => l_tbh_disb1.disb_net_amt   ,
                    x_disb_date                      => l_tbh_disb1.disb_date      ,
                    x_disb_rel_flag                  => l_tbh_disb1.disb_rel_flag    ,
                    x_first_disb_flag                => l_tbh_disb1.first_disb_flag  ,
                    x_INTEREST_REBATE_AMT            => l_tbh_disb1.INTEREST_REBATE_AMT,
                    x_disb_conf_flag                 => l_tbh_disb1.disb_conf_flag    ,
                    x_pymnt_per_start_date           => l_tbh_disb1.pymnt_per_start_date,
                    x_note_message                   => l_tbh_disb1.note_message       ,
                    x_rep_entity_id_txt              => l_tbh_disb1.rep_entity_id_txt,
                    x_atd_entity_id_txt              => l_tbh_disb1.atd_entity_id_txt,
                    x_mode                                     => 'R'
          );
        END IF;
      END LOOP; -- DL DISBURSEMENT LOOP
    END IF; -- FOR THE RECORD EXISTS CHECK
  END LOOP; -- DL AWARDS LOOP

EXCEPTION
  WHEN OTHERS THEN
    fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','igf_sl_upload_xml.process_dl_records');
    igs_ge_msg_stack.add;
    app_exception.raise_exception;
END process_dl_records;

PROCEDURE process_pell_records  ( p_st_id         IN        NUMBER,
                                  p_ssn           IN        VARCHAR2,
                                  p_lname         IN        VARCHAR2,
                                  p_dob           IN        DATE,
                                  p_rej_flg       IN        BOOLEAN
                                )
AS

  CURSOR  get_pell_resp ( cp_st_id  NUMBER) IS
    SELECT  *
      FROM  IGF_GR_RESP_DTLS
     WHERE  STDNT_RESP_ID = cp_st_id
      AND   NVL(STATUS_CODE, '*') <> 'P';

  CURSOR  get_pell_db_resp  (cp_pell_id   NUMBER) IS
    SELECT  *
      FROM  IGF_GR_DB_RESP_DTLS
     WHERE  PELL_RESP_ID = cp_pell_id
      AND   NVL(STATUS_CODE, '*') <> 'P';

  CURSOR  get_pell_rec  ( cp_ssn            VARCHAR2,
                          cp_lname          VARCHAR2,
                          cp_dob            DATE,
                          cp_fin_awd_yr     VARCHAR2
                        ) IS
    SELECT  *
      FROM  IGF_GR_COD_DTLS
     WHERE  S_SSN = cp_ssn
      AND   S_DATE_OF_BIRTH = cp_dob
      AND   S_LAST_NAME = cp_lname
      AND   FIN_AWARD_YEAR = cp_fin_awd_yr;
  l_pell_rec  get_pell_rec%ROWTYPE;

  CURSOR  get_pell_db_rec ( cp_awd_id         NUMBER,
                            cp_disb_seq_num   NUMBER,
                            cp_disb_num       NUMBER
                          ) IS
    SELECT  *
      FROM  IGF_AW_DB_CHG_DTLS
     WHERE  AWARD_ID = cp_awd_id
      AND   DISB_NUM = cp_disb_num
      AND   DISB_SEQ_NUM = cp_disb_seq_num;
  l_pell_db_rec get_pell_db_rec%ROWTYPE;

  CURSOR  c_tbh_pell  ( orig_id IGF_GR_RFMS.ORIGINATION_ID%TYPE) IS
    SELECT  *
      FROM  IGF_GR_RFMS
      WHERE ORIGINATION_ID = orig_id
      FOR UPDATE;
  l_tbh_pell  c_tbh_pell%ROWTYPE;

  -- Cursors from the disbursements updation
  CURSOR  c_tbh_disb  ( cp_awd_id         NUMBER,
                        cp_disb_seq_num   NUMBER,
                        cp_disb_num       NUMBER
                      ) IS
    SELECT  *
      FROM  IGF_AW_DB_CHG_DTLS_V
     WHERE  AWARD_ID = cp_awd_id
      AND   DISB_NUM = cp_disb_num
      AND   DISB_SEQ_NUM = cp_disb_seq_num;
  l_tbh_disb  c_tbh_disb%ROWTYPE;

  CURSOR  c_tbh_disb1 ( cp_awd_id         NUMBER,
                        cp_disb_seq_num   NUMBER,
                        cp_disb_num       NUMBER
                      ) IS
    SELECT  *
      FROM  IGF_AW_DB_COD_DTLS_V
     WHERE  AWARD_ID = cp_awd_id
      AND   DISB_NUM = cp_disb_num
      AND   DISB_SEQ_NUM = cp_disb_seq_num;
  l_tbh_disb1 c_tbh_disb1%ROWTYPE;

  update_flag   BOOLEAN;


BEGIN


  FOR l_pell_resp IN get_pell_resp(p_st_id)
  LOOP
    fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','PROC_PELL'));
    fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','RESP_ST')||':' ||l_pell_resp.RESP_CODE );

    l_pell_rec := NULL;
    OPEN get_pell_rec(p_ssn,p_lname,p_dob,l_pell_resp.FIN_AWD_YR);
    FETCH get_pell_rec INTO l_pell_rec;
    CLOSE get_pell_rec;




    IF l_pell_rec.origination_id IS NULL THEN
      fnd_message.set_name('IGF','IGF_SL_COD_SKIP');
      fnd_file.put_line(fnd_file.log,fnd_message.get);

      -- Update the status to 'N' - Processed, Not found in the System
      UPDATE IGF_GR_RESP_DTLS
      SET STATUS_CODE = 'N'
      WHERE PELL_RESP_ID = l_pell_resp.PELL_RESP_ID;
    ELSE


      l_tbh_pell := NULL;
      OPEN c_tbh_pell(l_pell_rec.ORIGINATION_ID);
      FETCH c_tbh_pell INTO l_tbh_pell;
      CLOSE c_tbh_pell;

      print_edits(l_pell_resp.PELL_RESP_ID,'PELL');

      IF p_rej_flg = TRUE OR l_pell_resp.RESP_CODE = 'R' THEN
        -- In response file 'R' means Rejected.
        -- In the system, Pell Orig Status 'E' means Rejected and 'R' means 'Ready to Send'
        l_tbh_pell.ORIG_ACTION_CODE := 'E';
      ELSIF l_pell_resp.RESP_CODE IN ('A','C') THEN
        -- compare the values in the resp record with the system record
        IF l_pell_resp.AWARD_AMT <> l_pell_rec.AWARD_AMT THEN
          fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','SYS_VAL_PELL')||':' ||l_pell_rec.AWARD_AMT );
          fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','RESP_VAL_PELL')||':' ||l_pell_resp.AWARD_AMT );
        END IF;
        IF l_pell_resp.COA_AMT <> l_pell_rec.COA_AMT THEN
          fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','SYS_VAL_COA')||':' ||l_pell_rec.COA_AMT);
          fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','RESP_VAL_COA')||':' ||l_pell_resp.COA_AMT);
        END IF;
        IF l_pell_resp.SCHD_PELL_AMT <> l_pell_rec.SCHD_PELL_AMT THEN
          fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','SYS_VAL_FT')||':' ||l_pell_rec.SCHD_PELL_AMT);
          fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','RESP_VAL_FT')||':' ||l_pell_resp.SCHD_PELL_AMT);
        END IF;
        IF l_pell_resp.VER_STATUS_CODE <> l_pell_rec.VER_STATUS_CODE THEN
          fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','SYS_VAL_VER')||':' ||l_pell_rec.VER_STATUS_CODE);
          fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','RESP_VAL_VER')||':' ||l_pell_resp.VER_STATUS_CODE);
        END IF;

        fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','YTD_DISB_AMT')||':' ||l_pell_resp.YTD_DISB_AMT);
        fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','TOT_ELIG_USED')||':' ||l_pell_resp.TOT_ELIG_USED);
        fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','NEG_PEND_AMT')||':' ||l_pell_resp.NEG_PEND_AMT);

       /*SELECT THE COLUMNS YTD_DISB_AMT, TOT_ELIG_USED, SCHD_PELL_AMT, NEG_PEND_AMT, FSA_CODE_1,FSA_CODE_2,FSA_CODE_3,PELL_STATUS
          CPS_VERIF_FLAG, HIGH_CPS_TRANS_NUM FROM IGF_GR_RESP_DTLS
          Also update the fields YTD_DISB_AMT, TOT_ELIG_USED, PENDING_AMOUNT,ORIG_aCTION_CODE in the table IGF_GR_RFMS_ALL
        */--dont
        l_tbh_pell.ORIG_ACTION_CODE := l_pell_resp.RESP_CODE;
      END IF;

      igf_gr_rfms_pkg.update_row(
                  x_rowid                             => l_tbh_pell.row_id,
                  x_origination_id                    => l_tbh_pell.origination_id,
                  x_ci_cal_type                       => l_tbh_pell.ci_cal_type           ,
                  x_ci_sequence_number                => l_tbh_pell.ci_sequence_number    ,
                  x_base_id                           => l_tbh_pell.base_id               ,
                  x_award_id                          => l_tbh_pell.award_id              ,
                  x_rfmb_id                           => l_tbh_pell.rfmb_id               ,
                  x_sys_orig_ssn                      => l_tbh_pell.sys_orig_ssn          ,
                  x_sys_orig_name_cd                  => l_tbh_pell.sys_orig_name_cd      ,
                  x_transaction_num                   => l_tbh_pell.transaction_num       ,
                  x_efc                               => l_tbh_pell.efc                   ,
                  x_ver_status_code                   => l_tbh_pell.ver_status_code       ,
                  x_secondary_efc                     => l_tbh_pell.secondary_efc         ,
                  x_secondary_efc_cd                  => l_tbh_pell.secondary_efc_cd      ,
                  x_pell_amount                       => l_tbh_pell.pell_amount           ,
                  x_pell_profile                      => l_tbh_pell.pell_profile          ,
                  x_enrollment_status                 => l_tbh_pell.enrollment_status     ,
                  x_enrollment_dt                     => l_tbh_pell.enrollment_dt         ,
                  x_coa_amount                        => l_tbh_pell.coa_amount            ,
                  x_academic_calendar                 => l_tbh_pell.academic_calendar     ,
                  x_payment_method                    => l_tbh_pell.payment_method        ,
                  x_total_pymt_prds                   => l_tbh_pell.total_pymt_prds       ,
                  x_incrcd_fed_pell_rcp_cd            => l_tbh_pell.incrcd_fed_pell_rcp_cd,
                  x_attending_campus_id               => l_tbh_pell.attending_campus_id   ,
                  x_est_disb_dt1                      => l_tbh_pell.est_disb_dt1          ,
                  x_orig_action_code                  => l_tbh_pell.orig_action_code      ,
                  x_orig_status_dt                    => l_tbh_pell.orig_status_dt        ,
                  x_orig_ed_use_flags                 => l_tbh_pell.orig_ed_use_flags     ,
                  x_ft_pell_amount                    => l_tbh_pell.ft_pell_amount        ,
                  x_prev_accpt_efc                    => l_tbh_pell.prev_accpt_efc        ,
                  x_prev_accpt_tran_no                => l_tbh_pell.prev_accpt_tran_no    ,
                  x_prev_accpt_sec_efc_cd             => l_tbh_pell.prev_accpt_sec_efc_cd ,
                  x_prev_accpt_coa                    => l_tbh_pell.prev_accpt_coa        ,
                  x_orig_reject_code                  => l_tbh_pell.orig_reject_code      ,
                  x_wk_inst_time_calc_pymt            => l_tbh_pell.wk_inst_time_calc_pymt,
                  x_wk_int_time_prg_def_yr            => l_tbh_pell.wk_int_time_prg_def_yr,
                  x_cr_clk_hrs_prds_sch_yr            => l_tbh_pell.cr_clk_hrs_prds_sch_yr,
                  x_cr_clk_hrs_acad_yr                => l_tbh_pell.cr_clk_hrs_acad_yr    ,
                  x_inst_cross_ref_cd                 => l_tbh_pell.inst_cross_ref_cd     ,
                  x_low_tution_fee                    => l_tbh_pell.low_tution_fee        ,
                  x_rec_source                        => l_tbh_pell.rec_source            ,
                  x_pending_amount                    => l_tbh_pell.pending_amount        ,
                  x_mode                              => 'R',
                  x_birth_dt                          => l_tbh_pell.birth_dt              ,
                  x_last_name                         => l_tbh_pell.last_name             ,
                  x_first_name                        => l_tbh_pell.first_name            ,
                  x_middle_name                       => l_tbh_pell.middle_name           ,
                  x_current_ssn                       => l_tbh_pell.current_ssn           ,
                  x_legacy_record_flag                => NULL,
                  x_reporting_pell_cd                 => NULL,
                  x_rep_entity_id_txt                 => l_tbh_pell.rep_entity_id_txt     ,
                  x_atd_entity_id_txt                 => l_tbh_pell.atd_entity_id_txt     ,
                  x_note_message                      => l_tbh_pell.note_message          ,
                  x_full_resp_code                    => l_tbh_pell.full_resp_code        ,
                  x_document_id_txt                   => l_tbh_pell.document_id_txt
      );

      UPDATE IGF_GR_RESP_DTLS
      SET STATUS_CODE = 'P'
      WHERE PELL_RESP_ID = l_pell_resp.PELL_RESP_ID;

      -- start the processing of pell disbursements
      FOR l_pell_db_resp IN get_pell_db_resp(l_pell_resp.PELL_RESP_ID)
      LOOP
        fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','DISB_NUM')||':'||l_pell_db_resp.disb_num);
        fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','DISB_SEQ_NUM')||':' ||l_pell_db_resp.disb_seq_num);
        fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','RESP_ST')||':' ||l_pell_db_resp.RESP_CODE);

        l_pell_db_rec := NULL;
        OPEN get_pell_db_rec(l_pell_rec.AWARD_ID,l_pell_db_resp.disb_seq_num,l_pell_db_resp.disb_num);
        FETCH get_pell_db_rec INTO l_pell_db_rec;
        CLOSE get_pell_db_rec;

        l_tbh_disb := NULL;
        OPEN c_tbh_disb(l_pell_rec.AWARD_ID,l_pell_db_resp.disb_seq_num,l_pell_db_resp.disb_num);
        FETCH c_tbh_disb INTO l_tbh_disb;
        CLOSE c_tbh_disb;

        l_tbh_disb1 := NULL;
        OPEN c_tbh_disb1(l_pell_rec.AWARD_ID,l_pell_db_resp.disb_seq_num,l_pell_db_resp.disb_num);
        FETCH c_tbh_disb1 INTO l_tbh_disb1;
        CLOSE c_tbh_disb1;

        update_flag := FALSE;
        IF p_rej_flg = TRUE OR l_pell_db_resp.RESP_CODE = 'R' THEN
          -- update the table IGF_AW_DB_COD_DTLS with DISB_STATUS = 'R' , IGF_AW_DB_CHG_DTLS  DISB_STATUS = 'R'
          -- update the status_code = 'P' in IGF_GR_DB_RESP_DTLS
          IF  l_pell_db_resp.disb_seq_num < 66 THEN
            IF l_tbh_disb.disb_seq_num IS NULL THEN
              -- disbursement record not found in the system. Log a mesg.
              fnd_message.set_name('IGF','IGF_SL_COD_SKIP');
              fnd_file.put_line(fnd_file.log,fnd_message.get);

              UPDATE IGF_GR_DB_RESP_DTLS
              SET status_code = 'N'
              WHERE DISB_RESP_ID = l_pell_db_resp.DISB_RESP_ID;
              update_flag := FALSE;
            ELSE
              l_tbh_disb.DISB_STATUS := 'R';
              --l_tbh_disb1.DISB_STATUS := 'R';
              UPDATE IGF_GR_DB_RESP_DTLS
              SET status_code = 'P'
              WHERE DISB_RESP_ID = l_pell_db_resp.DISB_RESP_ID;
              update_flag := TRUE;
            END IF;
          END IF;
        ELSE
          print_edits(l_pell_db_resp.DISB_RESP_ID,'PELL_DB');
          IF  l_pell_db_resp.disb_seq_num < 66 THEN
            IF l_tbh_disb.disb_seq_num IS NULL THEN
              -- disbursement record not found in the system. Log a mesg.
              fnd_message.set_name('IGF','IGF_SL_COD_SKIP');
              fnd_file.put_line(fnd_file.log,fnd_message.get);

              -- update the status to 'N' - Processed, Not found in the System
              UPDATE IGF_GR_DB_RESP_DTLS
              SET STATUS_CODE = 'N'
              WHERE DISB_RESP_ID = l_pell_db_resp.DISB_RESP_ID;
              update_flag := FALSE;
            ELSE
              /*  Compare the system disbursement amount and the response disbursement amount, and disbursement date,
                  if these are different then print into the log file and insert system hold on the disbursement as per
                  existing logic. Call the wrapper igf_gr_gen.insert_sys_holds(rec_award.award_id,rec_disb_orig.disb_ref_num,'PELL');
                  Update the disb_status = resp_code in table IGF_AW_DB_CHG_DTLS
                  Also print in the log file, Payment Period Start Date if present and update it in the table
                  IGF_AW_DISB_COD_DTLS and IGF_AW_DB_CHG_DTLS.
                  Update the status_code = 'P' in IGF_GR_DB_RESP_DTLS*/ --dont

              IF l_pell_db_rec.DISB_ACCEPTED_AMT <> l_pell_db_resp.disb_amt THEN
                fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','SYS_VAL_DB_AMT')||':' ||l_pell_db_rec.DISB_ACCEPTED_AMT);
                fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','RESP_VAL_DB_AMT')||':' ||l_pell_db_resp.disb_amt);
                igf_gr_gen.insert_sys_holds(l_pell_rec.award_id,l_pell_db_rec.disb_num,'PELL');
              END IF;
              IF l_pell_db_rec.disb_date <> l_pell_db_resp.disb_date THEN
                fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','SYS_VAL_DB_DT')||':' ||l_pell_db_rec.disb_date);
                fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','RESP_VAL_DB_DT')||':' ||l_pell_db_resp.disb_date);
              END IF;
              fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','RESP_VAL_PYMT_PER_DT')||':' ||l_pell_db_resp.PYMNT_PER_START_DATE);

              -- UPDATE IN THE TABLE IGF_AW_DB_COD_DTLS , IGF_AW_DB_CHG_DTLS RESP_CODE,PYMNT_PER_START_DATE, PREV_SEQ_NUM
              l_tbh_disb.DISB_STATUS :=  l_pell_db_resp.RESP_CODE;
              l_tbh_disb.PYMNT_PRD_START_DATE := l_pell_db_resp.PYMNT_PER_START_DATE;
              --l_tbh_disb.PREV_SEQ_NUM := l_pell_db_resp.PREV_SEQ_NUM;
              --l_tbh_disb1.DISB_STATUS := l_pell_db_resp.RESP_CODE;
              l_tbh_disb1.PYMNT_PER_START_DATE := l_pell_db_resp.PYMNT_PER_START_DATE;
              --l_tbh_disb1.PREV_SEQ_NUM := l_pell_db_resp.PREV_SEQ_NUM;

              UPDATE IGF_GR_DB_RESP_DTLS
              SET STATUS_CODE = 'P'
              WHERE DISB_RESP_ID = l_pell_db_resp.DISB_RESP_ID;
              update_flag := TRUE;
            END IF;
          ELSE  -- implies disb_seq_num > 65
            /*  Print Disbursement Amount, Disbursement Date, Previous Disbursement Sequence Number
                and print a message -(School would have to adjust the disbursement amount as per the COD generated adjustment)
                Update the status_code = 'P' in IGF_GR_DB_RESP_DTLS. */ --dont
            fnd_message.set_name('IGF','IGF_SL_COD_SCHL_ADJ');
            fnd_file.put_line(fnd_file.log,fnd_message.get);
            fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','RESP_VAL_DB_AMT')||':' ||l_pell_db_resp.DISB_AMT);
            fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','RESP_VAL_DB_DT')||':' ||l_pell_db_resp.DISB_DATE);
            fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','RESP_VAL_PRV_SEQ_NUM')||':' ||l_pell_db_resp.PREV_SEQ_NUM);

            UPDATE IGF_GR_DB_RESP_DTLS
            SET STATUS_CODE = 'P'
            WHERE DISB_RESP_ID = l_pell_db_resp.DISB_RESP_ID;
            update_flag := FALSE;
          END IF;
        END IF; -- for the rejected flag check

        IF (update_flag) THEN
          igf_aw_db_chg_dtls_pkg.update_row(
                          x_rowid                             => l_tbh_disb.row_id,
                          x_award_id                          => l_tbh_disb.award_id,
                          x_disb_num                          => l_tbh_disb.disb_num,
                          x_disb_seq_num                      => l_tbh_disb.disb_seq_num,
                          x_disb_accepted_amt                 => l_tbh_disb.disb_accepted_amt,
                          x_orig_fee_amt                      => l_tbh_disb.orig_fee_amt,
                          x_disb_net_amt                      => l_tbh_disb.disb_net_amt,
                          x_disb_date                         => l_tbh_disb.disb_date,
                          x_disb_activity                     => l_tbh_disb.disb_activity,
                          x_disb_status                       => l_tbh_disb.disb_status,
                          x_disb_status_date                  => l_tbh_disb.disb_status_date,
                          x_disb_rel_flag                     => l_tbh_disb.disb_rel_flag,
                          x_first_disb_flag                   => l_tbh_disb.first_disb_flag,
                          x_interest_rebate_amt               => l_tbh_disb.interest_rebate_amt,
                          x_disb_conf_flag                    => l_tbh_disb.disb_conf_flag,
                          x_pymnt_prd_start_date              => l_tbh_disb.pymnt_prd_start_date,
                          x_note_message                      => l_tbh_disb.note_message,
                          x_batch_id_txt                      => l_tbh_disb.batch_id_txt,
                          x_ack_date                          => l_tbh_disb.ack_date,
                          x_booking_id_txt                    => l_tbh_disb.booking_id_txt,
                          x_booking_date                      => l_tbh_disb.booking_date,
                          x_mode                              => 'R'
                       );
          igf_aw_db_cod_dtls_pkg.update_row(
                          x_rowid                          => l_tbh_disb1.row_id      ,
                          x_award_id                       => l_tbh_disb1.award_id    ,
                          x_document_id_txt                => l_tbh_disb1.document_id_txt  ,
                          x_disb_num                       => l_tbh_disb1.disb_num      ,
                          x_disb_seq_num                   => l_tbh_disb1.disb_seq_num  ,
                          x_disb_accepted_amt              => l_tbh_disb1.disb_accepted_amt ,
                          x_orig_fee_amt                   => l_tbh_disb1.orig_fee_amt   ,
                          x_disb_net_amt                   => l_tbh_disb1.disb_net_amt   ,
                          x_disb_date                      => l_tbh_disb1.disb_date      ,
                          x_disb_rel_flag                  => l_tbh_disb1.disb_rel_flag    ,
                          x_first_disb_flag                => l_tbh_disb1.first_disb_flag  ,
                          x_interest_rebate_amt            => l_tbh_disb1.interest_rebate_amt      ,
                          x_disb_conf_flag                 => l_tbh_disb1.disb_conf_flag    ,
                          x_pymnt_per_start_date           => l_tbh_disb1.pymnt_per_start_date,
                          x_note_message                   => l_tbh_disb1.note_message       ,
                          x_rep_entity_id_txt              =>  l_tbh_disb1.rep_entity_id_txt       ,
                          x_atd_entity_id_txt              =>  l_tbh_disb1.atd_entity_id_txt       ,
                          x_mode                                       => 'R'
          );
        END IF;
      END LOOP; -- PELL DISBURSEMENT LOOP
    END IF; -- FOR THE RECORD EXISTS CHECK
  END LOOP; -- PELL AWARDS LOOP

EXCEPTION
  WHEN OTHERS THEN
    fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','igf_sl_upload_xml.process_pell_records');
    igs_ge_msg_stack.add;
    app_exception.raise_exception;
END process_pell_records;

PROCEDURE main_response ( errbuf          OUT   NOCOPY  VARCHAR2,
                          retcode         OUT   NOCOPY  NUMBER,
                          p_document_id   IN            VARCHAR2
                        )
AS
-----------------------------------------------------------------------------------
--
--   Created By : ugummall
--   Date Created On : 2004/09/21
--   Purpose : It uploads the data from the response tables and updates the system
--             tables with the latest informtion on the COD
--   Know limitations, enhancements or remarks
--   Change History:
-----------------------------------------------------------------------------------
--   Who                                When             What
--  tsailaja              15/Jan/2006     Bug 4947880 Added invocation of igf_aw_gen.set_org_id(NULL);
-----------------------------------------------------------------------------------
  l_chk_doc chk_doc%ROWTYPE;

  CURSOR  get_cr_resp ( cp_doc_id VARCHAR2) IS
    SELECT  DOC_CREATED_DATE,
            SOURCE_ENTITY_ID_TXT,
            SOFT_PROVIDER,
                              SOFT_VERSION,
            FULL_RESP_CODE,
            RECEIPT_DATE,
                              DEST_ENTITY_ID_TXT,
            DOC_TYPE_CODE,
            DOC_STATUS_CODE,
                              PROCESS_DATE
      FROM  IGF_SL_CR_RESP_DTLS
     WHERE  DOCUMENT_ID_TXT = cp_doc_id;
  l_get_cr_resp get_cr_resp%ROWTYPE;

  CURSOR  get_rs_resp ( cp_doc_id VARCHAR2) IS
    SELECT  *
      FROM  IGF_SL_RS_RESP_DTLS
     WHERE  document_id_txt = cp_doc_id;

  CURSOR  get_fin_smry  ( cp_rep_id NUMBER) IS
    SELECT  *
      FROM  IGF_SL_RESP_F_SMRY
     WHERE  REP_SCHL_RESP_ID = cp_rep_id
     ORDER BY FIN_AWARD_YEAR,
              FIN_AWARD_TYPE;

  CURSOR  get_as_resp ( cp_rep_id NUMBER) IS
    SELECT  *
      FROM  IGF_SL_AS_RESP_DTLS
     WHERE  REP_SCHL_RESP_ID = cp_rep_id;

  CURSOR  get_st_resp ( cp_atd_id NUMBER) IS
    SELECT  *
      FROM  IGF_SL_ST_RESP_DTLS
     WHERE  ATD_SCHL_RESP_ID = cp_atd_id;

  CURSOR  get_cod_temp  IS
    SELECT  *
      FROM  IGF_SL_COD_TEMP;

  CURSOR  get_cods_for_student  ( cp_ssn  VARCHAR2, cp_lname  VARCHAR2, cp_dob  DATE) IS
    SELECT  codpell.ROWID row_id, codpell.*
      FROM  IGF_GR_COD_DTLS codpell
     WHERE  codpell.s_ssn = cp_ssn
      AND   codpell.s_last_name = cp_lname
      AND   codpell.s_date_of_birth = cp_dob;

  CURSOR  get_loans_for_student ( cp_ssn  VARCHAR2, cp_lname  VARCHAR2, cp_dob  DATE) IS
    SELECT  coddl.*
      FROM  IGF_SL_LOR_LOC coddl
     WHERE  coddl.s_ssn = cp_ssn
      AND   coddl.s_last_name = cp_lname
      AND   coddl.s_date_of_birth = cp_dob;

  l_doc_id        VARCHAR2(30);
  l_doc_rej_flg   BOOLEAN;
  l_rs_rej_flg    BOOLEAN;
  l_as_rej_flg    BOOLEAN;
  l_st_rej_flg    BOOLEAN;
  p_doc_id        VARCHAR2(30);

  changed_p_ssn   VARCHAR2(30);
  changed_p_lname VARCHAR2(30);
  changed_p_dob   DATE;

BEGIN
  igf_aw_gen.set_org_id(NULL);
  p_doc_id := p_document_id;
  l_doc_rej_flg  := FALSE;
  l_rs_rej_flg   := FALSE;
  l_as_rej_flg   := FALSE;
  l_st_rej_flg   := FALSE;

  -- Print the parameters passed to the procedure
  fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','DOC_ID')|| ':'||p_doc_id);
  fnd_file.put_line(fnd_file.log,'');

  -- Check if the document is present or not.
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_upload_xml.main_response.debug','Checking document(' || p_doc_id || ') is present or not');
  END IF;
  l_doc_id := NULL;
  OPEN chk_doc(p_doc_id);
  FETCH chk_doc INTO l_chk_doc;
  CLOSE chk_doc;
  IF l_chk_doc.document_id_txt IS NULL THEN
    fnd_message.set_name('IGF','IGF_SL_COD_INV_DOCID');
    fnd_file.put_line(fnd_file.log,fnd_message.get);
    RETURN;
  END IF;

  -- set the global doc id
  g_doc_id := p_doc_id;

  -- take the data from the temp tables into the response tables
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_upload_xml.main_response.debug','Updating Response details from COD_TEMP table to RESP Tables');
  END IF;
  FOR l_temp IN get_cod_temp
  LOOP
    IF l_temp.LEVEL_CODE = 'CR' THEN
      UPDATE IGF_SL_CR_RESP_DTLS
      SET DOC_TYPE_CODE = l_temp.DOC_TYPE_CODE,
          DOC_STATUS_CODE = l_temp.DOC_STATUS_CODE,
          PROCESS_DATE = l_temp.PROCESS_DATE
      WHERE DOCUMENT_ID_TXT = l_temp.REC_ID;
    ELSIF l_temp.LEVEL_CODE = 'RS' THEN
      UPDATE IGF_SL_RS_RESP_DTLS
      SET RESP_CODE = l_temp.RESP_CODE
      WHERE REP_SCHL_RESP_ID = l_temp.REC_ID;
    ELSIF l_temp.LEVEL_CODE = 'AS' THEN
      UPDATE IGF_SL_AS_RESP_DTLS
      SET RESP_CODE = l_temp.RESP_CODE
      WHERE  ATD_SCHL_RESP_ID = l_temp.REC_ID;
    ELSIF l_temp.LEVEL_CODE = 'ST' THEN
      UPDATE IGF_SL_ST_RESP_DTLS
      SET RESP_CODE = l_temp.RESP_CODE
      WHERE STDNT_RESP_ID = l_temp.REC_ID;
    ELSIF l_temp.LEVEL_CODE = 'AWD' THEN
      UPDATE IGF_SL_DL_RESP_DTLS
      SET RESP_CODE = l_temp.RESP_CODE,
          ELEC_MPN_FLAG = l_temp.ELEC_MPN_FLAG,
          PNOTE_MPN_ID = l_temp.PNOTE_MPN_ID,
          MPN_STATUS_CODE = l_temp.MPN_STATUS_CODE,
          MPN_LINK_FLAG = l_temp.MPN_LINK_FLAG,
          PYMT_SERVICER_AMT = l_temp.PYMT_SERVICER_AMT,
          PYMT_SERVICER_DATE = l_temp.PYMT_SERVICER_DATE,
          BOOK_LOAN_AMT = l_temp.BOOK_LOAN_AMT,
          BOOK_LOAN_AMT_DATE = l_temp.BOOK_LOAN_AMT_DATE,
          ENDORSER_AMT = l_temp.ENDORSER_AMT,
          CRDT_DECISION_STATUS = l_temp.CRDT_DECISION_STATUS,
          CRDT_DECISION_DATE = l_temp.CRDT_DECISION_DATE,
          CRDT_DECISION_OVRD_CODE = l_temp.CRDT_DECISION_OVRD_CODE
      WHERE DL_LOAN_RESP_ID = l_temp.REC_ID;
    ELSIF l_temp.LEVEL_CODE = 'BORR' THEN
      UPDATE IGF_SL_DL_RESP_DTLS
      SET B_RESP_CODE = l_temp.RESP_CODE
      WHERE DL_LOAN_RESP_ID = l_temp.REC_ID;
    ELSIF l_temp.LEVEL_CODE = 'DL_DB' THEN
      UPDATE IGF_SL_DLDB_RSP_DTL
      SET RESP_CODE = l_temp.RESP_CODE,
          PREV_SEQ_NUM = l_temp.PREV_SEQ_NUM
      WHERE DISB_RESP_ID = l_temp.REC_ID;
    ELSIF l_temp.LEVEL_CODE = 'PELL' THEN
      UPDATE IGF_GR_RESP_DTLS
      SET RESP_CODE = l_temp.RESP_CODE,
          YTD_DISB_AMT = l_temp.YTD_DISB_AMT,
          TOT_ELIG_USED = l_temp.TOT_ELIG_USED,
          SCHD_PELL_AMT = l_temp.SCHD_PELL_AMT,
          NEG_PEND_AMT = l_temp.NEG_PEND_AMT,
          FSA_CODE_1 = l_temp.FSA_CODE_1,
          FSA_CODE_2 = l_temp.FSA_CODE_2,
          FSA_CODE_3 = l_temp.FSA_CODE_3,
          CPS_VERIF_FLAG = l_temp.CPS_VERIF_FLAG,
          HIGH_CPS_TRANS_NUM = l_temp.HIGH_CPS_TRANS_NUM
      WHERE PELL_RESP_ID = l_temp.REC_ID;
    ELSIF l_temp.LEVEL_CODE = 'PELL_DB' THEN
      UPDATE IGF_GR_DB_RESP_DTLS
      SET RESP_CODE = l_temp.RESP_CODE,
          PREV_SEQ_NUM = l_temp.PREV_SEQ_NUM
      WHERE DISB_RESP_ID = l_temp.REC_ID;
    ELSIF l_temp.LEVEL_CODE = 'DL_INFO' THEN
      UPDATE IGF_SL_DI_RESP_DTLS
      SET RESP_CODE = l_temp.RESP_CODE
      WHERE DL_INFO_ID = l_temp.REC_ID;
    END IF;
  END LOOP;

  -- Commit above changes.
  -- Here commit is needed as we may need to remove data from resp tables in seperate transaction
  -- at which locks on above updated rows should be available.
  COMMIT;

  -- Open the cursor for the main CommonRecord Details
  l_get_cr_resp := NULL;
  OPEN  get_cr_resp(p_doc_id);
  FETCH get_cr_resp INTO l_get_cr_resp;
  CLOSE get_cr_resp;

  -- print CommonRecord values in log file
  g_process_date := l_get_cr_resp.PROCESS_DATE;
  fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','CR_RESP_DTLS'));
  fnd_file.put_line(fnd_file.log,'');
  fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','DOC_CR_DT')|| ':'||l_get_cr_resp.DOC_CREATED_DATE);
  fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','SRC_ENT_ID')|| ':'||l_get_cr_resp.SOURCE_ENTITY_ID_TXT);
  fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','DST_ENT_ID')|| ':'||l_get_cr_resp.DEST_ENTITY_ID_TXT);
  fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','SFT_PRVD')|| ':'||l_get_cr_resp.SOFT_PROVIDER);
  fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','SFT_VER')|| ':'||l_get_cr_resp.SOFT_VERSION);
  fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','FULL_RESP_CD')|| ':'||l_get_cr_resp.FULL_RESP_CODE);
  fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','RECP_DATE')|| ':'||l_get_cr_resp.RECEIPT_DATE);
  fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','DOC_TYPE')|| ':'||l_get_cr_resp.DOC_TYPE_CODE);
  fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','DOC_STATUS')|| ':'||l_get_cr_resp.DOC_STATUS_CODE);
  fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','PROC_DATE')|| ':'||l_get_cr_resp.PROCESS_DATE);

  -- Check if the document is receipt document or not. If it is, then
  -- log message and return. Do not process if it is receipt document.
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_upload_xml.main_response.debug','RECEIPT_DATE is ' || l_get_cr_resp.RECEIPT_DATE);
  END IF;
  IF l_get_cr_resp.RECEIPT_DATE IS NOT NULL THEN
    fnd_file.put_line(fnd_file.log,'receipt date is not null');
    fnd_message.set_name('IGF','IGF_SL_NOT_PRC_RECEIPT_DOC');
    fnd_file.put_line(fnd_file.log,fnd_message.get);
    -- delete data from resp tables as well as from temp table(IGF_SL_COD_TEMP)
    rollback_resp_tables();
    RETURN;
  END IF;

  -- Check if destination school in XML file is present in our system or not.
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_upload_xml.main_response.debug','Checking destination entity id(' || l_get_cr_resp.dest_entity_id_txt || ')');
  END IF;
  IF NOT check_entityid(l_get_cr_resp.DEST_ENTITY_ID_TXT) THEN
    fnd_message.set_name('IGF','IGF_SL_COD_INV_DEST_ID');
    fnd_message.set_token('DEST_ENTITY_ID',l_get_cr_resp.DEST_ENTITY_ID_TXT);
    fnd_file.put_line(fnd_file.log,fnd_message.get);

    -- update the IGF_SL_COD_DOC_DTLS table with the status = 'E'
    update_xml_document(l_chk_doc, 'E');
    -- delete data from resp tables as well as from temp table(IGF_SL_COD_TEMP)
    rollback_resp_tables();
    RETURN;
  END IF;

  -- Rest of the processing is to be done if this is not a receipt document.
  IF l_get_cr_resp.RECEIPT_DATE IS NULL THEN
    IF l_get_cr_resp.FULL_RESP_CODE NOT IN ('F','S','M','N') THEN
      fnd_message.set_name('IGF','IGF_SL_COD_INV_RES_CODE');
      fnd_file.put_line(fnd_file.log,fnd_message.get);

      -- update the IGF_SL_COD_DOC_DTLS table with the status = 'F';
      update_xml_document(l_chk_doc, 'F');
      -- delete data from resp tables as well as from temp table(IGF_SL_COD_TEMP)
      rollback_resp_tables();
      RETURN;
    END IF;

    -- Here onwards, Data from response tables should not be deleted.
    -- Hence removing data from temp table(IGF_SL_COD_TEMP) as temp table data
    -- is not needed to remove data from resp tables
    delete_temp_table_data();

    -- print the edit results at the CommonRecord Level
    print_edits(p_doc_id,'CR');

    l_doc_rej_flg := FALSE;
    IF l_get_cr_resp.DOC_STATUS_CODE = 'R' THEN
      l_doc_rej_flg := TRUE;

      -- update the IGF_SL_COD_DOC_DTLS table with the status = 'J';
      -- do not return from here as there would be child level rejects
      igf_sl_cod_doc_dtls_pkg.update_row (
          x_rowid                             => l_chk_doc.row_id,
          x_document_id_txt                   => l_chk_doc.document_id_txt,
          x_outbound_doc                      => l_chk_doc.outbound_doc   ,
          x_inbound_doc                       => l_chk_doc.inbound_doc    ,
          x_send_date                         => l_chk_doc.send_date      ,
          x_ack_date                          => l_chk_doc.ack_date       ,
          x_doc_status                        => 'J'                      ,
          x_doc_type                          => l_chk_doc.doc_type       ,
          x_full_resp_code                    => l_chk_doc.full_resp_code ,
          x_mode                              => 'R'
      );
    END IF;

    -- start the processing of the Reporting School Tags
    FOR l_rs_resp IN get_rs_resp(p_doc_id)
    LOOP
      l_rs_rej_flg := FALSE;
      fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','RS_RESP_DTLS'));
      fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','RS_ENT_ID')|| ':'|| l_rs_resp.REP_ENTITY_ID_TXT);
      fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','RESP_ST')|| ':'|| l_rs_resp.RESP_CODE);
      fnd_file.put_line(fnd_file.OUTPUT,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','RS_RESP_DTLS'));
      fnd_file.put_line(fnd_file.OUTPUT,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','RS_ENT_ID')|| ':'|| l_rs_resp.REP_ENTITY_ID_TXT);
      fnd_file.put_line(fnd_file.OUTPUT,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','RESP_ST')|| ':'|| l_rs_resp.RESP_CODE);

      IF NOT check_entityid(l_rs_resp.REP_ENTITY_ID_TXT) THEN
        fnd_message.set_name('IGF','IGF_SL_COD_INV_REPENTITY_ID');
        fnd_message.set_token('REPT_ENTITY_ID',l_rs_resp.REP_ENTITY_ID_TXT);
        fnd_file.put_line(fnd_file.log,fnd_message.get);
        -- skip the processing for this reporting school
      ELSE
        print_edits(l_rs_resp.REP_SCHL_RESP_ID,'RS');

        IF l_doc_rej_flg = TRUE OR l_rs_resp.RESP_CODE = 'R' THEN
          l_rs_rej_flg := TRUE;
        END IF;

        -- print the fin summary data from the response file
        FOR l_fin_smry IN get_fin_smry(l_rs_resp.REP_SCHL_RESP_ID)
        LOOP
          fnd_file.put_line(fnd_file.OUTPUT,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','FIN_AWD_YR')|| ':'|| l_fin_smry.FIN_AWARD_YEAR);
          fnd_file.put_line(fnd_file.OUTPUT,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','FIN_AWD_TYP')|| ':'|| l_fin_smry.FIN_AWARD_TYPE);
          fnd_file.put_line(fnd_file.OUTPUT,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','TOT_ST_TAG')|| ':'|| l_fin_smry.TOT_CNT_NUM);
          fnd_file.put_line(fnd_file.OUTPUT,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','TOT_ACPT_AWD')|| ':'|| l_fin_smry.TOT_CNT_ACPT_NUM);
          fnd_file.put_line(fnd_file.OUTPUT,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','TOT_REJ_AWD')|| ':'|| l_fin_smry.TOT_CNT_REJ_NUM);
          fnd_file.put_line(fnd_file.OUTPUT,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','TOT_DUP_AWD')|| ':'|| l_fin_smry.TOT_CNT_DUP_NUM);
          fnd_file.put_line(fnd_file.OUTPUT,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','TOT_COR_AWD')|| ':'|| l_fin_smry.TOT_CNT_CORR_NUM);
          fnd_file.put_line(fnd_file.OUTPUT,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','TOT_SEL_VERIF')|| ':'|| l_fin_smry.TOT_CNT_VER_SLCTD_NUM);
          fnd_file.put_line(fnd_file.OUTPUT,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','TOT_SSADMIN')|| ':'|| l_fin_smry.TOT_CNT_SSADMIN_NUM);
          fnd_file.put_line(fnd_file.OUTPUT,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','TOT_REP_AWD')|| ':'|| l_fin_smry.TOT_REP_AWD_AMT);
          fnd_file.put_line(fnd_file.OUTPUT,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','TOT_REP_DB_AMT')|| ':'|| l_fin_smry.TOT_REP_DISB_AMT);
          fnd_file.put_line(fnd_file.OUTPUT,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','TOT_ACPT_AMT')|| ':'|| l_fin_smry.TOT_FIN_AWD_ACPT_AMT);
          fnd_file.put_line(fnd_file.OUTPUT,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','TOT_DB_ACPT_AMT')|| ':'|| l_fin_smry.TOT_FIN_DISB_ACPT_AMT);
          fnd_file.put_line(fnd_file.OUTPUT,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','TOT_FUND_DB_AMT')|| ':'|| l_fin_smry.TOT_FUND_DISB_ACPT_AMT);
          fnd_file.put_line(fnd_file.OUTPUT,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','TOT_NONFUND_DB_AMT')|| ':'|| l_fin_smry.TOT_NONFUND_DISB_ACPT_AMT);
          fnd_file.put_line(fnd_file.OUTPUT,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','TOT_AWD_CORR_AMT')|| ':'|| l_fin_smry.TOT_FIN_AWD_CORR_AMT);

          fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','FIN_AWD_YR')|| ':'|| l_fin_smry.FIN_AWARD_YEAR);
          fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','FIN_AWD_TYP')|| ':'|| l_fin_smry.FIN_AWARD_TYPE);
          fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','TOT_ST_TAG')|| ':'|| l_fin_smry.TOT_CNT_NUM);
          fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','TOT_ACPT_AWD')|| ':'|| l_fin_smry.TOT_CNT_ACPT_NUM);
          fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','TOT_REJ_AWD')|| ':'|| l_fin_smry.TOT_CNT_REJ_NUM);
          fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','TOT_DUP_AWD')|| ':'|| l_fin_smry.TOT_CNT_DUP_NUM);
          fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','TOT_COR_AWD')|| ':'|| l_fin_smry.TOT_CNT_CORR_NUM);
          fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','TOT_SEL_VERIF')|| ':'|| l_fin_smry.TOT_CNT_VER_SLCTD_NUM);
          fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','TOT_SSADMIN')|| ':'|| l_fin_smry.TOT_CNT_SSADMIN_NUM);
          fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','TOT_REP_AWD')|| ':'|| l_fin_smry.TOT_REP_AWD_AMT);
          fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','TOT_REP_DB_AMT')|| ':'|| l_fin_smry.TOT_REP_DISB_AMT);
          fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','TOT_ACPT_AMT')|| ':'|| l_fin_smry.TOT_FIN_AWD_ACPT_AMT);
          fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','TOT_DB_ACPT_AMT')|| ':'|| l_fin_smry.TOT_FIN_DISB_ACPT_AMT);
          fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','TOT_FUND_DB_AMT')|| ':'|| l_fin_smry.TOT_FUND_DISB_ACPT_AMT);
          fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','TOT_NONFUND_DB_AMT')|| ':'|| l_fin_smry.TOT_NONFUND_DISB_ACPT_AMT);
          fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','TOT_AWD_CORR_AMT')|| ':'|| l_fin_smry.TOT_FIN_AWD_CORR_AMT);
        END LOOP;

        -- start the processing of the Attending School Tags
        FOR l_as_resp IN get_as_resp(l_rs_resp.REP_SCHL_RESP_ID)
        LOOP
          l_as_rej_flg := FALSE;
          fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','AS_RESP_DTLS'));
          fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','AS_ENT_ID')|| ':'|| l_as_resp.ATD_ENTITY_ID_TXT);
          fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','RESP_ST')|| ':'|| l_as_resp.RESP_CODE);
          fnd_file.put_line(fnd_file.OUTPUT,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','AS_RESP_DTLS'));
          fnd_file.put_line(fnd_file.OUTPUT,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','AS_ENT_ID')|| ':'|| l_as_resp.ATD_ENTITY_ID_TXT);
          fnd_file.put_line(fnd_file.OUTPUT,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','RESP_ST')|| ':'|| l_as_resp.RESP_CODE);

          IF NOT check_entityid(l_as_resp.ATD_ENTITY_ID_TXT) THEN
            fnd_message.set_name('IGF','IGF_SL_COD_INV_ATDENTITY_ID');
            fnd_message.set_token('ATTD_ENTITY_ID',l_as_resp.ATD_ENTITY_ID_TXT);
            fnd_file.put_line(fnd_file.log,fnd_message.get);
            -- skip the processing for this attending school
          ELSE
            print_edits(l_as_resp.ATD_SCHL_RESP_ID,'AS');

            IF l_rs_rej_flg = TRUE OR l_as_resp.RESP_CODE = 'R' THEN
              l_as_rej_flg := TRUE;
            END IF;

            -- start the processing of the Student Tags
            FOR l_st_resp IN get_st_resp(l_as_resp.ATD_SCHL_RESP_ID)
            LOOP
              l_st_rej_flg := FALSE;
              fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','ST_RESP_DTLS'));
              fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','ST_SSN')|| ':'|| l_st_resp.S_SSN);
              fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','ST_LNAME')|| ':'|| l_st_resp.S_LAST_NAME);
              fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','ST_DOB')|| ':'|| l_st_resp.S_DATE_OF_BIRTH);
              fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_SL_COD_XML_TAGS','RESP_ST')|| ':'|| l_st_resp.RESP_CODE);

              print_edits(l_st_resp.STDNT_RESP_ID,'ST');

              IF l_as_rej_flg = TRUE OR l_st_resp.RESP_CODE = 'R' THEN
                l_st_rej_flg := TRUE;
              END IF;

              changed_p_dob := l_st_resp.S_DATE_OF_BIRTH;
              changed_p_ssn := l_st_resp.S_SSN;
              changed_p_lname := l_st_resp.S_LAST_NAME;

              IF l_st_resp.RESP_CODE = 'A' THEN
                -- Get changed(new) student identifier information, if present.
                changed_p_dob := NVL(l_st_resp.S_CHG_DATE_OF_BIRTH, l_st_resp.S_DATE_OF_BIRTH);
                changed_p_ssn := NVL(l_st_resp.S_CHG_SSN, l_st_resp.S_SSN);
                changed_p_lname := NVL(l_st_resp.S_CHG_LAST_NAME, l_st_resp.S_LAST_NAME);

                -- If new student identifier info is different from old student identifier info then
                -- local COD tables should be reflected with COD info.
                -- That is for all records in local COD tables for that student, update with new student identifier info.
                IF changed_p_dob <> l_st_resp.S_DATE_OF_BIRTH OR changed_p_ssn <> l_st_resp.S_SSN OR changed_p_lname <> l_st_resp.S_LAST_NAME THEN
                  -- Update student pell records with new student identifier info.
                  -- Student will have only one Pell award, but still used For loop for consistency purpose.
                  FOR rec IN get_cods_for_student(l_st_resp.s_ssn,l_st_resp.s_last_name,l_st_resp.s_date_of_birth)
                  LOOP
                    igf_gr_cod_dtls_pkg.update_row(
                      x_rowid                             =>  rec.row_id,
                      x_origination_id                    =>  rec.origination_id,
                      x_award_id                          =>  rec.award_id,
                      x_document_id_txt                   =>  rec.document_id_txt,
                      x_base_id                           =>  rec.base_id,
                      x_fin_award_year                    =>  rec.fin_award_year,
                      x_cps_trans_num                     =>  rec.cps_trans_num,
                      x_award_amt                         =>  rec.award_amt,
                      x_coa_amt                           =>  rec.coa_amt,
                      x_low_tution_fee                    =>  rec.low_tution_fee,
                      x_incarc_flag                       =>  rec.incarc_flag,
                      x_ver_status_code                   =>  rec.ver_status_code,
                      x_enrollment_date                   =>  rec.enrollment_date,
                      x_sec_efc_code                      =>  rec.sec_efc_code,
                      x_ytd_disb_amt                      =>  rec.ytd_disb_amt,
                      x_tot_elig_used                     =>  rec.tot_elig_used,
                      x_schd_pell_amt                     =>  rec.schd_pell_amt,
                      x_neg_pend_amt                      =>  rec.neg_pend_amt,
                      x_cps_verif_flag                    =>  rec.cps_verif_flag,
                      x_high_cps_trans_num                =>  rec.high_cps_trans_num,
                      x_note_message                      =>  rec.note_message,
                      x_full_resp_code                    =>  rec.full_resp_code,
                      x_atd_entity_id_txt                 =>  rec.atd_entity_id_txt,
                      x_rep_entity_id_txt                 =>  rec.rep_entity_id_txt,
                      x_source_entity_id_txt              =>  rec.source_entity_id_txt,
                      x_pell_status                       =>  rec.pell_status,
                      x_pell_status_date                  =>  rec.pell_status_date,
                      x_s_ssn                             =>  changed_p_ssn,
                      x_driver_lic_state                  =>  rec.driver_lic_state,
                      x_driver_lic_number                 =>  rec.driver_lic_number,
                      x_s_date_of_birth                   =>  changed_p_dob,
                      x_first_name                        =>  UPPER(rec.first_name),
                      x_middle_name                       =>  UPPER(rec.middle_name),
                      x_s_last_name                       =>  changed_p_lname,
                      x_s_chg_date_of_birth               =>  NULL,
                      x_s_chg_ssn                         =>  NULL,
                      x_s_chg_last_name                   =>  NULL,
                      x_permt_addr_foreign_flag           =>  NULL,
                      x_addr_type_code                    =>  NULL,
                      x_permt_addr_line_1                 =>  UPPER(rec.permt_addr_line_1),
                      x_permt_addr_line_2                 =>  UPPER(rec.permt_addr_line_2),
                      x_permt_addr_line_3                 =>  UPPER(rec.permt_addr_line_3),
                      x_permt_addr_city                   =>  UPPER(rec.permt_addr_city),
                      x_permt_addr_state_code             =>  UPPER(rec.permt_addr_state_code),
                      x_permt_addr_post_code              =>  UPPER(rec.permt_addr_post_code),
                      x_permt_addr_county                 =>  UPPER(rec.permt_addr_county),
                      x_permt_addr_country                =>  UPPER(rec.permt_addr_country),
                      x_phone_number_1                    =>  rec.phone_number_1,
                      x_phone_number_2                    =>  NULL,
                      x_phone_number_3                    =>  NULL,
                      x_email_address                     =>  UPPER(rec.email_address),
                      x_citzn_status_code                 =>  rec.citzn_status_code,
                      x_mode                              =>  'R'
                    );
                  END LOOP;

                  -- Update student loan records with new student identifier info.
                  FOR rec IN get_loans_for_student(l_st_resp.s_ssn,l_st_resp.s_last_name,l_st_resp.s_date_of_birth)
                                    LOOP
                    igf_sl_lor_loc_pkg.update_row (
                      x_mode                              => 'R',
                      x_rowid                             => rec.row_id,
                      x_loan_id                           => rec.loan_id,
                      x_origination_id                    => rec.origination_id,
                      x_loan_number                       => rec.loan_number,
                      x_loan_type                         => rec.loan_type,
                      x_loan_amt_offered                  => rec.loan_amt_offered,
                      x_loan_amt_accepted                 => rec.loan_amt_accepted,
                      x_loan_per_begin_date               => rec.loan_per_begin_date,
                      x_loan_per_end_date                 => rec.loan_per_end_date,
                      x_acad_yr_begin_date                => rec.acad_yr_begin_date,
                      x_acad_yr_end_date                  => rec.acad_yr_end_date,
                      x_loan_status                       => rec.loan_status,
                      x_loan_status_date                  => rec.loan_status_date,
                      x_loan_chg_status                   => rec.loan_chg_status,
                      x_loan_chg_status_date              => rec.loan_chg_status_date,
                      x_req_serial_loan_code              => rec.req_serial_loan_code,
                      x_act_serial_loan_code              => rec.act_serial_loan_code,
                      x_active                            => rec.active,
                      x_active_date                       => rec.active_date,
                      x_sch_cert_date                     => rec.sch_cert_date,
                      x_orig_status_flag                  => rec.orig_status_flag,
                      x_orig_batch_id                     => rec.orig_batch_id,
                      x_orig_batch_date                   => rec.orig_batch_date,
                      x_chg_batch_id                      => NULL,
                      x_orig_ack_date                     => rec.orig_ack_date,
                      x_credit_override                   => rec.credit_override,
                      x_credit_decision_date              => rec.credit_decision_date,
                      x_pnote_delivery_code               => rec.pnote_delivery_code,
                      x_pnote_status                      => rec.pnote_status,
                      x_pnote_status_date                 => rec.pnote_status_date,
                      x_pnote_id                          => rec.pnote_id,
                      x_pnote_print_ind                   => rec.pnote_print_ind,
                      x_pnote_accept_amt                  => rec.pnote_accept_amt,
                      x_pnote_accept_date                 => rec.pnote_accept_date,
                      x_p_signature_code                  => rec.p_signature_code,
                      x_p_signature_date                  => rec.p_signature_date,
                      x_s_signature_code                  => rec.s_signature_code,
                      x_unsub_elig_for_heal               => rec.unsub_elig_for_heal,
                      x_disclosure_print_ind              => rec.disclosure_print_ind,
                      x_orig_fee_perct                    => rec.orig_fee_perct,
                      x_borw_confirm_ind                  => rec.borw_confirm_ind,
                      x_borw_interest_ind                 => rec.borw_interest_ind,
                      x_unsub_elig_for_depnt              => rec.unsub_elig_for_depnt,
                      x_guarantee_amt                     => rec.guarantee_amt,
                      x_guarantee_date                    => rec.guarantee_date,
                      x_guarnt_adj_ind                    => rec.guarnt_adj_ind,
                      x_guarnt_amt_redn_code              => rec.guarnt_amt_redn_code,
                      x_guarnt_status_code                => rec.guarnt_status_code,
                      x_guarnt_status_date                => rec.guarnt_status_date,
                      x_lend_apprv_denied_code            => NULL,
                      x_lend_apprv_denied_date            => NULL,
                      x_lend_status_code                  => rec.lend_status_code,
                      x_lend_status_date                  => rec.lend_status_date,
                      x_grade_level_code                  => rec.grade_level_code,
                      x_enrollment_code                   => rec.enrollment_code,
                      x_anticip_compl_date                => rec.anticip_compl_date,
                      x_borw_lender_id                    => rec.borw_lender_id,
                      x_duns_borw_lender_id               => NULL,
                      x_guarantor_id                      => rec.guarantor_id,
                      x_duns_guarnt_id                    => NULL,
                      x_prc_type_code                     => rec.prc_type_code,
                      x_rec_type_ind                      => rec.rec_type_ind,
                      x_cl_loan_type                      => rec.cl_loan_type,
                      x_cl_seq_number                     => rec.cl_seq_number,
                      x_last_resort_lender                => rec.last_resort_lender,
                      x_lender_id                         => rec.lender_id,
                      x_duns_lender_id                    => NULL,
                      x_lend_non_ed_brc_id                => rec.lend_non_ed_brc_id,
                      x_recipient_id                      => rec.recipient_id,
                      x_recipient_type                    => rec.recipient_type,
                      x_duns_recip_id                     => NULL,
                      x_recip_non_ed_brc_id               => rec.recip_non_ed_brc_id,
                      x_cl_rec_status                     => NULL,
                      x_cl_rec_status_last_update         => NULL,
                      x_alt_prog_type_code                => rec.alt_prog_type_code,
                      x_alt_appl_ver_code                 => rec.alt_appl_ver_code,
                      x_borw_outstd_loan_code             => rec.borw_outstd_loan_code,
                      x_mpn_confirm_code                  => NULL,
                      x_resp_to_orig_code                 => rec.resp_to_orig_code,
                      x_appl_loan_phase_code              => NULL,
                      x_appl_loan_phase_code_chg          => NULL,
                      x_tot_outstd_stafford               => rec.tot_outstd_stafford,
                      x_tot_outstd_plus                   => rec.tot_outstd_plus,
                      x_alt_borw_tot_debt                 => rec.alt_borw_tot_debt,
                      x_act_interest_rate                 => rec.act_interest_rate,
                      x_service_type_code                 => rec.service_type_code,
                      x_rev_notice_of_guarnt              => rec.rev_notice_of_guarnt,
                      x_sch_refund_amt                    => rec.sch_refund_amt,
                      x_sch_refund_date                   => rec.sch_refund_date,
                      x_uniq_layout_vend_code             => rec.uniq_layout_vend_code,
                      x_uniq_layout_ident_code            => rec.uniq_layout_ident_code,
                      x_p_person_id                       => rec.p_person_id,
                      x_p_ssn                             => rec.p_ssn,
                      x_p_ssn_chg_date                    => NULL,
                      x_p_last_name                       => rec.p_last_name,
                      x_p_first_name                      => rec.p_first_name,
                      x_p_middle_name                     => rec.p_middle_name,
                      x_p_permt_addr1                     => rec.p_permt_addr1,
                      x_p_permt_addr2                     => rec.p_permt_addr2,
                      x_p_permt_city                      => rec.p_permt_city,
                      x_p_permt_state                     => rec.p_permt_state,
                      x_p_permt_zip                       => rec.p_permt_zip,
                      x_p_permt_addr_chg_date             => rec.p_permt_addr_chg_date,
                      x_p_permt_phone                     => rec.p_permt_phone,
                      x_p_email_addr                      => rec.p_email_addr,
                      x_p_date_of_birth                   => rec.p_date_of_birth,
                      x_p_dob_chg_date                    => NULL,
                      x_p_license_num                     => rec.p_license_num,
                      x_p_license_state                   => rec.p_license_state,
                      x_p_citizenship_status              => rec.p_citizenship_status,
                      x_p_alien_reg_num                   => rec.p_alien_reg_num,
                      x_p_default_status                  => rec.p_default_status,
                      x_p_foreign_postal_code             => rec.p_foreign_postal_code,
                      x_p_state_of_legal_res              => rec.p_state_of_legal_res,
                      x_p_legal_res_date                  => rec.p_legal_res_date,
                      x_s_ssn                             => changed_p_ssn,
                      x_s_ssn_chg_date                    => NULL,
                      x_s_last_name                       => changed_p_lname,
                      x_s_first_name                      => rec.s_first_name,
                      x_s_middle_name                     => rec.s_middle_name,
                      x_s_permt_addr1                     => rec.s_permt_addr1,
                      x_s_permt_addr2                     => rec.s_permt_addr2,
                      x_s_permt_city                      => rec.s_permt_city,
                      x_s_permt_state                     => rec.s_permt_state,
                      x_s_permt_zip                       => rec.s_permt_zip,
                      x_s_permt_addr_chg_date             => rec.s_permt_addr_chg_date,
                      x_s_permt_phone                     => rec.s_permt_phone,
                      x_s_local_addr1                     => rec.s_local_addr1,
                      x_s_local_addr2                     => rec.s_local_addr2,
                      x_s_local_city                      => rec.s_local_city,
                      x_s_local_state                     => rec.s_local_state,
                      x_s_local_zip                       => rec.s_local_zip,
                      x_s_local_addr_chg_date             => NULL,
                      x_s_email_addr                      => rec.s_email_addr,
                      x_s_date_of_birth                   => changed_p_dob,
                      x_s_dob_chg_date                    => NULL,
                      x_s_license_num                     => rec.s_license_num,
                      x_s_license_state                   => rec.s_license_state,
                      x_s_depncy_status                   => rec.s_depncy_status,
                      x_s_default_status                  => rec.s_default_status,
                      x_s_citizenship_status              => rec.s_citizenship_status,
                      x_s_alien_reg_num                   => rec.s_alien_reg_num,
                      x_s_foreign_postal_code             => rec.s_foreign_postal_code,
                      x_pnote_batch_id                    => rec.pnote_batch_id,
                      x_pnote_ack_date                    => rec.pnote_ack_date,
                      x_pnote_mpn_ind                     => rec.pnote_mpn_ind,
                      x_award_id                          => rec.award_id     ,
                      x_base_id                           => rec.base_id       ,
                      x_document_id_txt                   => rec.document_id_txt    ,
                      x_loan_key_num                      => rec.loan_key_num   ,
                      x_INTEREST_REBATE_PERCENT_NUM       => rec.INTEREST_REBATE_PERCENT_NUM,
                      x_fin_award_year                    => rec.fin_award_year  ,
                      x_cps_trans_num                     => rec.cps_trans_num    ,
                      x_ATD_ENTITY_ID_TXT                 => rec.ATD_ENTITY_ID_TXT,
                      x_REP_ENTITY_ID_TXT                 => rec.REP_ENTITY_ID_TXT,
                      x_SOURCE_ENTITY_ID_TXT              => rec.SOURCE_ENTITY_ID_TXT,
                      x_pymt_servicer_amt                 => rec.pymt_servicer_amt  ,
                      x_pymt_servicer_date                => rec.pymt_servicer_date ,
                      x_book_loan_amt                     => rec.book_loan_amt      ,
                      x_book_loan_amt_date                => rec.book_loan_amt_date ,
                      x_s_chg_birth_date                  => NULL,
                      x_s_chg_ssn                         => NULL,
                      x_s_chg_last_name                   => NULL,
                      x_b_chg_birth_date                  => rec.b_chg_birth_date   ,
                      x_b_chg_ssn                         => rec.b_chg_ssn          ,
                      x_b_chg_last_name                   => rec.b_chg_last_name    ,
                      x_note_message                      => rec.note_message       ,
                      x_full_resp_code                    => rec.full_resp_code     ,
                      x_s_permt_county                    => rec.s_permt_county     ,
                      x_b_permt_county                    => rec.b_permt_county     ,
                      x_s_permt_country                   => rec.s_permt_country    ,
                      x_b_permt_country                   => rec.b_permt_country    ,
                      x_crdt_decision_status              => rec.crdt_decision_status,
                      x_actual_record_type_code           => rec.actual_record_type_code,
                      x_alt_approved_amt                  => rec.alt_approved_amt,
                      x_alt_borrower_ind_flag             => rec.alt_borrower_ind_flag,
                      x_borower_credit_authoriz_flag      => rec.borower_credit_authoriz_flag,
                      x_borower_electronic_sign_flag      => rec.borower_electronic_sign_flag,
                      x_cost_of_attendance_amt            => rec.cost_of_attendance_amt,
                      x_deferment_request_code            => rec.deferment_request_code,
                      x_eft_authorization_code            => rec.eft_authorization_code,
                      x_established_fin_aid_amount        => rec.established_fin_aid_amount,
                      x_expect_family_contribute_amt      => rec.expect_family_contribute_amt,
                      x_external_loan_id_txt              => rec.external_loan_id_txt,
                      x_flp_approved_amt                  => rec.flp_approved_amt,
                      x_fls_approved_amt                  => rec.fls_approved_amt,
                      x_flu_approved_amt                  => rec.flu_approved_amt,
                      x_guarantor_use_txt                 => rec.guarantor_use_txt,
                      x_lender_use_txt                    => rec.lender_use_txt,
                      x_loan_app_form_code                => rec.loan_app_form_code,
                      x_mpn_type_flag                     => rec.mpn_type_flag,
                      x_reinstatement_amt                 => rec.reinstatement_amt,
                      x_requested_loan_amt                => rec.requested_loan_amt,
                      x_school_id_txt                     => rec.school_id_txt,
                      x_school_use_txt                    => rec.school_use_txt,
                      x_student_electronic_sign_flag      => rec.student_electronic_sign_flag,
                      x_esign_src_typ_cd                  => rec.esign_src_typ_cd
                    );
                  END LOOP;
                END IF; -- student identifier differ
              END IF; -- student is accepted.

              -- start the processing based on the document type
              IF l_chk_doc.doc_type IN ('COD','DL') THEN
                IF l_get_cr_resp.DOC_TYPE_CODE = 'ND' THEN
                  process_pell_records(l_st_resp.STDNT_RESP_ID, changed_p_ssn, changed_p_lname, changed_p_dob, FALSE);
                ELSE
                  process_dl_records(l_st_resp.STDNT_RESP_ID,l_st_rej_flg,l_get_cr_resp.DOC_TYPE_CODE);
                END IF;
              END IF;
              IF l_chk_doc.doc_type = 'PELL' THEN
                  process_pell_records(l_st_resp.STDNT_RESP_ID, changed_p_ssn, changed_p_lname, changed_p_dob, l_st_rej_flg);
              END IF;
            END LOOP; -- FOR THE STUDENT CURSOR
          END IF; -- FOR THE ATTENDING SCHOOL ENTITY ID
        END LOOP; -- FOR THE ATTENDING SCHOOL CURSOR
      END IF; -- REPORTING SCHOOL ENTITY ID
    END LOOP; -- FOR THE REPORTING SCHOOL CURSOR
  END IF;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    retcode := 2;
    errbuf  := fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION');
    fnd_file.put_line(fnd_file.log, SQLERRM);
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_upload_xml.main_response.debug','sqlerrm ' || SQLERRM);
    END IF;
    igs_ge_msg_stack.conc_exception_hndl;
END main_response;

PROCEDURE set_nls_fmt ( PARAM   IN  VARCHAR2)
AS
  l_temp varchar2(10);
  l_sql_stmt varchar2(100);
BEGIN
  l_temp := '.,';
  l_sql_stmt := 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ''' || l_temp || '''';
  EXECute IMMEDIATE l_sql_stmt;
END set_nls_fmt;

FUNCTION  get_created_by
RETURN NUMBER AS
BEGIN
  RETURN -1;
END get_created_by;

FUNCTION  get_creation_date
RETURN DATE AS
BEGIN
  RETURN TO_DATE('01062004', 'DDMMYYYY');
END get_creation_date ;

FUNCTION  get_last_updated_by
RETURN NUMBER AS
BEGIN
  RETURN -1;
END get_last_updated_by ;

FUNCTION  get_last_update_date
RETURN DATE AS
BEGIN
  RETURN TO_DATE('01062004', 'DDMMYYYY');
END get_last_update_date ;

FUNCTION  get_last_update_login
RETURN NUMBER AS
BEGIN
  RETURN -1;
END get_last_update_login ;


PROCEDURE get_datetime  ( PARAM     IN    VARCHAR2,
                          OUTPARAM  OUT   NOCOPY VARCHAR2
                        )
AS
BEGIN
  OUTPARAM := SUBSTR(REPLACE(REPLACE(REPLACE(PARAM,'-'),':'),'T'),1,14);
END get_datetime;

PROCEDURE get_date  ( PARAM     IN    VARCHAR2,
                      OUTPARAM  OUT   NOCOPY VARCHAR2
                    )
AS
BEGIN
  OUTPARAM := REPLACE(PARAM,'-');
END get_date;

PROCEDURE launch_request  ( itemtype    IN              VARCHAR2,
                            itemkey     IN              VARCHAR2,
                            actid       IN              NUMBER,
                            funcmode    IN              VARCHAR2,
                            resultout   OUT NOCOPY      VARCHAR2
                          )
IS
  ln_request_id NUMBER;
  l_doc_id VARCHAR2(30);
BEGIN
  l_doc_id := wf_engine.GetItemAttrText(itemtype, itemkey, 'ECX_PARAMETER1');
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_upload_xml.launch_request.debug','Document ID from ECX_PARAMETER1 is: ' || l_doc_id);
  END IF;

  ln_request_id := fnd_request.submit_request(
                                               'IGF','IGFSLJ18','','', FALSE,
                                               l_doc_id,CHR(0),
                                               '','','','','','','','',
                                               '','','','','','','','','','',
                                               '','','','','','','','','','',
                                               '','','','','','','','','','',
                                               '','','','','','','','','','',
                                               '','','','','','','','','','',
                                               '','','','','','','','','','',
                                               '','','','','','','','','','',
                                               '','','','','','','','','','',
                                               '','','','','','','','','','');
  resultout := 'SUCCESS';
  COMMIT;
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_upload_xml.launch_request.debug','sub process launched with id ' || ln_request_id);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    resultout := 'F';
    wf_core.context ('IGF_SL_UPLOAD_XML',
                      'LAUNCH_REQUEST', itemtype,
                       itemkey,to_char(actid), funcmode);
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_upload_xml.launch_request.debug','sqlerrm ' || SQLERRM);
    END IF;
    RETURN;
END launch_request;

PROCEDURE update_rs_respcode(p_rec_id IN VARCHAR2, p_resp_code IN VARCHAR2)
AS
  CURSOR  cur_cod_temp(cp_rec_id IN VARCHAR2) IS
    SELECT  rec_id, level_code, resp_code
      FROM  IGF_SL_COD_TEMP
     WHERE  REC_ID = cp_rec_id
      AND   LEVEL_CODE = 'RS';
  rec_cod_temp cur_cod_temp%ROWTYPE;
  IGFSL26_XMLGW_RS_REC_NOT_FOUND EXCEPTION;
BEGIN
  -- write parameters in debug messages
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_upload_xml.update_rs_respcode.debug', 'p_rec_id = ' || p_rec_id);
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_upload_xml.update_rs_respcode.debug', 'p_resp_code = ' || p_resp_code);
  END IF;

  -- check wether record with p_rec_id and LEVEL_CODE as RS exists or not.
  OPEN cur_cod_temp(p_rec_id);
  FETCH cur_cod_temp INTO rec_cod_temp;
  IF cur_cod_temp%NOTFOUND THEN
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_upload_xml.update_rs_respcode.debug', 'Record NOT found with p_rec_id ' || p_rec_id || ' and with level_code RS');
    END IF;
    RAISE IGFSL26_XMLGW_RS_REC_NOT_FOUND;
  ELSE
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_upload_xml.update_rs_respcode.debug', 'Record has been found with p_rec_id ' || p_rec_id);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_upload_xml.update_rs_respcode.debug', 'REC_ID = ' || rec_cod_temp.REC_ID);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_upload_xml.update_rs_respcode.debug', 'LEVEL_CODE = ' || rec_cod_temp.LEVEL_CODE);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_upload_xml.update_rs_respcode.debug', 'RESP_CODE = ' || rec_cod_temp.RESP_CODE);
    END IF;
  END IF;
  CLOSE cur_cod_temp;

  -- update the record with RESP_CODE as p_resp_code
  -- we are not commiting after the update as the transaction in which this update executes
  -- and the transaction in which XML Gateway engine executes its insertions is same.
  UPDATE  IGF_SL_COD_TEMP
    SET   RESP_CODE = p_resp_code
   WHERE  REC_ID = p_rec_id
    AND   LEVEL_CODE = 'RS';

  -- print the record in debug messages.
  OPEN cur_cod_temp(p_rec_id);
  FETCH cur_cod_temp INTO rec_cod_temp;
  IF cur_cod_temp%NOTFOUND THEN
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_upload_xml.update_rs_respcode.debug', 'After update, Record NOT found with p_rec_id ' || p_rec_id || ' and with level_code RS');
    END IF;
    RAISE IGFSL26_XMLGW_RS_REC_NOT_FOUND;
  ELSE
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_upload_xml.update_rs_respcode.debug', 'After update, Record has been found with p_rec_id ' || p_rec_id);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_upload_xml.update_rs_respcode.debug', 'After update, REC_ID = ' || rec_cod_temp.REC_ID);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_upload_xml.update_rs_respcode.debug', 'After update, LEVEL_CODE = ' || rec_cod_temp.LEVEL_CODE);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_upload_xml.update_rs_respcode.debug', 'After update, RESP_CODE = ' || rec_cod_temp.RESP_CODE);
    END IF;
  END IF;
  CLOSE cur_cod_temp;
EXCEPTION
  WHEN IGFSL26_XMLGW_RS_REC_NOT_FOUND THEN
    fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','igf_sl_upload_xml.update_rs_respcode');
    igs_ge_msg_stack.add;
    app_exception.raise_exception;
  WHEN OTHERS THEN
    fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','igf_sl_upload_xml.update_rs_respcode');
    igs_ge_msg_stack.add;
    app_exception.raise_exception;
END update_rs_respcode;

PROCEDURE update_rcptdate_respcode(p_doc_id IN VARCHAR2, p_receipt_date IN VARCHAR2)
AS
ld_receipt_date DATE;
lv_receipt_date VARCHAR2(100);
BEGIN
      get_datetime(p_receipt_date, lv_receipt_date);
      ld_receipt_date := TO_DATE(SUBSTR(lv_receipt_date, 1, 8), 'YYYY/MM/DD');

      UPDATE  IGF_SL_CR_RESP_DTLS
        SET   RECEIPT_DATE = ld_receipt_date
        WHERE  DOCUMENT_ID_TXT = p_doc_id;

END;

END igf_sl_upload_xml;

/
