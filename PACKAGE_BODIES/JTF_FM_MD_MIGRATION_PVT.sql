--------------------------------------------------------
--  DDL for Package Body JTF_FM_MD_MIGRATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_FM_MD_MIGRATION_PVT" AS
/* $Header: JTFFMVMB.pls 120.0 2005/05/11 09:06:47 appldev noship $ */


g_idx_created NUMBER := 0;
g_item_created NUMBER := 0;
g_text_file_id NUMBER := NULL;

migrated_content MASTERDOC_QRY_TBL_TYPE;

l_query_tbl MASTERDOC_QRY_TBL_TYPE;
l_masterdoc_qry_tbl MASTERDOC_QRY_TBL_TYPE;

FUNCTION check_log(p_code IN VARCHAR2,
                   p_status IN VARCHAR2) RETURN NUMBER
IS
  CURSOR c_check_log_csr(c_code VARCHAR2,
					c_status VARCHAR2) IS
    SELECT 1
	 FROM JTF_FM_MIGRATION_HISTORY
     WHERE migration_code = c_code
	  AND status = c_status;
  l_temp NUMBER;
BEGIN
  OPEN c_check_log_csr(p_code, p_status);
  FETCH c_check_log_csr INTO l_temp;
  IF (c_check_log_csr%NOTFOUND) THEN
    l_temp := 0;
  END IF;
  CLOSE c_check_log_csr;
  RETURN l_temp;
END check_log;

PROCEDURE create_log(p_code IN VARCHAR2,
				 p_status IN VARCHAR2,
				 x_status OUT NOCOPY VARCHAR2)
IS
BEGIN
  DELETE FROM JTF_FM_MIGRATION_HISTORY
	   WHERE MIGRATION_CODE = p_code;
  INSERT INTO JTF_FM_MIGRATION_HISTORY(MIGRATION_CODE,
    OBJECT_VERSION_NUMBER, CREATED_BY, CREATION_DATE,
    LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,STATUS)
  VALUES(p_code,0, FND_GLOBAL.user_id, SYSDATE,
    FND_GLOBAL.user_id, SYSDATE, FND_GLOBAL.user_id, p_status);
  x_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
  WHEN OTHERS THEN
    x_status := FND_API.G_RET_STS_ERROR;
END create_log;

PROCEDURE update_log(p_code IN VARCHAR2,
				 p_old_status IN VARCHAR2,
				 p_new_status IN VARCHAR2,
				 p_number  IN NUMBER,
				 x_status OUT NOCOPY VARCHAR2)
IS
  l_i NUMBER;
BEGIN
  UPDATE JTF_FM_MIGRATION_HISTORY
     SET STATUS = p_new_status,
   	    LAST_UPDATE_DATE = SYSDATE
   WHERE MIGRATION_CODE = p_code
	AND STATUS = p_old_status;

	 FOR l_i IN p_number..MIGRATED_CONTENT.count LOOP
	    INSERT INTO JTF_FM_MIG_HISTORY_DETAILS
       (MIGRATION_CODE,
        ITEM_ID,
        CONTENT_TYPE_CODE,
        CONTENT_ITEM_ID,
        CITEM_VERSION_ID,
        FILE_ID,
        FILE_NAME,
        DESCRIPTION,
        QUERY_CITEM_ID,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
       VALUES(MIGRATED_CONTENT(l_i).MIGRATION_CODE,
       MIGRATED_CONTENT(l_i).ITEM_ID,
       MIGRATED_CONTENT(l_i).CONTENT_TYPE_CODE,
       MIGRATED_CONTENT(l_i).CONTENT_ITEM_ID,
       MIGRATED_CONTENT(l_i).CITEM_VERSION_ID,
       MIGRATED_CONTENT(l_i).FILE_ID,
       MIGRATED_CONTENT(l_i).FILE_NAME,
       MIGRATED_CONTENT(l_i).DESCRIPTION,
       MIGRATED_CONTENT(l_i).QUERY_CITEM_ID,
       FND_GLOBAL.user_id,
       SYSDATE,
       FND_GLOBAL.user_id,
       SYSDATE,
       FND_GLOBAL.user_id);
     END LOOP;



  x_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
  WHEN OTHERS THEN
    x_status := FND_API.G_RET_STS_ERROR;
END update_log;



-------------------------------------------------
-- Debug Information Pring Procedure
-- Y : Display Debug
-- N:  No Debug Statement Printout
PROCEDURE printDebuglog(p_debug_str IN VARCHAR2)
IS
BEGIN
--  printDebugLog(p_debug_str);
  IF JTF_FM_MD_MIGRATION_PVT.g_debug = 'Y' THEN
    --FND_FILE.PUT_LINE(FND_FILE.LOG,p_debug_str);
	--DBMS_OUTPUT.PUT_LINE(p_debug_str);
	NULL;
  END IF;

END printDebugLog;

PROCEDURE printOutput(p_message IN VARCHAR2)
IS
BEGIN
  --FND_FILE.PUT_LINE(FND_FILE.OUTPUT,p_message);
  --DBMS_OUTPUT.PUT_LINE(p_message);
  NULL;
END printOutput;



PROCEDURE printReport
IS
  l_i NUMBER;
  l_name VARCHAR2(50) := NULL;
  l_desc VARCHAR2(255) := NULL;
  l_item_id NUMBER := NULL;
  l_file_id NUMBER := NULL;
  l_query_id NUMBER := NULL;
  l_content_item_id NUMBER;
  l_citem_ver_id NUMBER;
  l_content_type_code VARCHAR2(100) := NULL;

  l_temp_msg VARCHAR2(2000);
  l_title1 VARCHAR2(2000);


BEGIN
  -- printOutput('Running Time:'||to_char(g_start_time,'MM/DD/RRRR HH24:MI:SS')
  --  ||'-'||to_char(g_end_time,'MM/DD/RRRR HH24:MI:SS'));
  printOutput('');
  printOutput('=================================');
  -- Migration summary
  fnd_message.set_name('JTF', 'JTF_FM_MSG_MGRT_SUMMRY');
  l_temp_msg := fnd_message.get;
  printOutput('1. '||l_temp_msg);
  printOutput('=================================');
  -- Number of content items created
  fnd_message.set_name('JTF', 'JTF_FM_M_NUM_CONT_ITEM_DESC');
  l_temp_msg := fnd_message.get;
  printOutput(l_temp_msg||': '||to_char(g_item_created));
  printOutput('');
  FOR l_i IN 1..MIGRATED_CONTENT.count LOOP
    IF MOD(l_i-1,25) = 0 THEN
	 printOutput('');
      printOutput(l_title1);
      printOutput('-----------------                        -----------------  '||
    '                      ----------                               -------- ' ||
    '                      ----------------');
    END IF;
    IF (MIGRATED_CONTENT(l_i).ITEM_ID IS NULL) THEN
	 l_item_id := RPAD(' ',40,' ');
    ELSE
	 l_item_id := RPAD(MIGRATED_CONTENT(l_i).ITEM_ID,40,' ');
    END IF;
    IF (MIGRATED_CONTENT(l_i).CONTENT_TYPE_CODE IS NULL) THEN
	 l_content_type_code := RPAD(' ',40,' ');
    ELSE
      l_content_type_code := RPAD(SUBSTR(MIGRATED_CONTENT(l_i).CONTENT_TYPE_CODE,1,40),40,' ');
	 END IF;

    IF (MIGRATED_CONTENT(l_i).content_item_id IS NULL) THEN
	 l_content_item_id := RPAD(' ',40,' ');
    ELSE
	 l_content_item_id
	   := RPAD(SUBSTR(MIGRATED_CONTENT(l_i).content_item_id,1,40),40,' ');
    END IF;
	IF (MIGRATED_CONTENT(l_i).CITEM_VERSION_ID IS NULL) THEN
	 l_CITEM_VER_ID:= RPAD(' ',40,' ');
    ELSE
	 l_CITEM_VER_ID
	   := RPAD(SUBSTR(MIGRATED_CONTENT(l_i).CITEM_VERSION_ID,1,40),40,' ');
    END IF;
	IF (MIGRATED_CONTENT(l_i).FILE_ID IS NULL) THEN
	 l_FILE_ID:= RPAD(' ',40,' ');
    ELSE
	 l_FILE_ID
	   := RPAD(SUBSTR(MIGRATED_CONTENT(l_i).FILE_ID,1,40),40,' ');
    END IF;
	IF (MIGRATED_CONTENT(l_i).FILE_NAME IS NULL) THEN
	 l_name:= RPAD(' ',40,' ');
    ELSE
	 l_name
	   := RPAD(SUBSTR(MIGRATED_CONTENT(l_i).FILE_NAME,1,40),40,' ');
    END IF;
	IF (MIGRATED_CONTENT(l_i).DESCRIPTION IS NULL) THEN
	 l_desc:= RPAD(' ',40,' ');
    ELSE
	 l_desc
	   := RPAD(SUBSTR(MIGRATED_CONTENT(l_i).DESCRIPTION,1,40),40,' ');
    END IF;
	IF (MIGRATED_CONTENT(l_i).QUERY_CITEM_ID IS NULL) THEN
	 l_query_id:= RPAD(' ',40,' ');
    ELSE
	 l_query_id
	   := RPAD(SUBSTR(MIGRATED_CONTENT(l_i).QUERY_CITEM_ID,1,40),40,' ');
    END IF;
    printOutput(l_item_id||' '||l_content_type_code||' '||l_content_item_id||' '
	 ||l_citem_ver_id||' '
      ||l_file_id||' ' || l_name ||' ' || l_desc ||' ' || l_query_id);

  END LOOP;
END printReport;



-- This procedure is to handle new content item
-- and put it into IBC tables
PROCEDURE process_content_item(
  px_masterdoc_qry_rec IN OUT NOCOPY MASTERDOC_QRY_REC_TYPE,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data OUT NOCOPY VARCHAR2)
IS
  l_i NUMBER;
  l_j NUMBER;
  l_return_status VARCHAR2(1);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(2000);

  l_status VARCHAR2(30) ;
  l_cv_label_rec Ibc_Cv_Label_Grp.CV_Label_Rec_Type;
  x_cv_label_rec Ibc_Cv_Label_Grp.CV_Label_Rec_Type;
  l_attribute_type_codes JTF_VARCHAR2_TABLE_100;
  l_attributes JTF_VARCHAR2_TABLE_4000;
  l_attidx NUMBER;
  l_directory NUMBER;


  l_compound_content_items JTF_NUMBER_TABLE ;
  l_compound_attribute_types JTF_VARCHAR2_TABLE_100;


  l_object_version_number NUMBER := 0;

  l_content_item_id NUMBER;
  l_citem_version_id NUMBER;
  l_lgl_phys_map_id NUMBER;
  l_version_number NUMBER;
  l_move_label NUMBER;
  l_old_version NUMBER;
  l_old_ver_num NUMBER;
  l_old_item NUMBER;
  l_query NUMBER := NULL;

  CURSOR c_get_content_item_csr(c_item_id VARCHAR2,c_content_type_code VARCHAR2) IS
    SELECT content_item_id, citem_version_id
	 FROM jtf_fm_mig_history_details
     WHERE item_id  = c_item_id
	 and content_type_code = c_content_type_code;


BEGIN
  SAVEPOINT process_content_item;
  printDebugLog('Start processing item');
  l_move_label := 0;
    OPEN c_get_content_item_csr(px_masterdoc_qry_rec.item_id,px_masterdoc_qry_rec.content_type_code);
    FETCH c_get_content_item_csr INTO l_content_item_id, l_citem_version_id;
    IF (c_get_content_item_csr%NOTFOUND) THEN
	 l_citem_version_id := NULL;
	ELSE
	printDebugLog('Item is already present in OCM ' ||px_masterdoc_qry_rec.item_id);
	 l_old_version := l_citem_version_id;
	 --l_citem_version_id := NULL;
      --l_move_label := 1;
    END IF;
    CLOSE c_get_content_item_csr;

  printDebugLog('  After finding content item id and citem version id');
  printDebugLog('    content item id:'||l_content_item_id
    ||' Citem version id:'||l_citem_version_id);
  l_attribute_type_codes := JTF_VARCHAR2_TABLE_100();
  l_attributes := JTF_VARCHAR2_TABLE_4000();

  IF px_masterdoc_qry_rec.content_type_code = 'AMF_TEMPLATE'
  THEN
     l_query := NULL;
	 l_directory := 4;
	  printDebugLog('Assinged l_query NULL value');
      l_attribute_type_codes.extend(6);
	  l_attributes.extend(6);
	  l_attribute_type_codes(1) := 'APPLICATION_ID';
	  l_attributes(1) := '690';
	  l_attribute_type_codes(2) := 'DEFAULT_MODE';
	  l_attributes(2) := 'HTML';
	  l_attribute_type_codes(3) := 'HTML_DATA_FND_ID';
	  l_attributes(3) := px_masterdoc_qry_rec.FILE_ID;
	  l_attribute_type_codes(4) := 'TEXT_DATA_FND_ID';
	  l_attributes(4) := g_text_file_id;
	  l_attribute_type_codes(5) := 'OWNER';
	  l_attributes(5) := FND_GLOBAL.USER_ID;
	  printDebugLog('Query Id is ' || px_masterdoc_qry_rec.QUERY_CITEM_ID);
      l_attribute_type_codes(6) := 'QUERY_ID';
	  l_attributes(6) := px_masterdoc_qry_rec.QUERY_CITEM_ID;
	   l_status := IBC_UTILITIES_PUB.G_STV_WORK_IN_PROGRESS;
	  IF  (px_masterdoc_qry_rec.QUERY_CITEM_ID is NOT NULL) THEN
	     printDebugLog('Query Id is not NULL, so component created');
	     l_compound_content_items := JTF_NUMBER_TABLE(px_masterdoc_qry_rec.QUERY_CITEM_ID) ;
         l_compound_attribute_types := JTF_VARCHAR2_TABLE_100('AMF_QUERY');

	  END IF;

  ELSIF px_masterdoc_qry_rec.content_type_code = 'AMF_QUERY'
  THEN
      l_query := px_masterdoc_qry_rec.FILE_ID;
	  l_directory := 11;
	  printDebugLog('Assinged l_query ' || l_query);
      l_attribute_type_codes.extend(1);
	  l_attributes.extend(1);
	  l_attribute_type_codes(1) := 'IS_DATA_QUERY';
	  l_attributes(1) := 'F';
	  l_status := IBC_UTILITIES_PUB.G_STV_APPROVED;
  ELSE
     null;
  END IF;

  IF (l_content_item_id IS NULL) THEN

    printDebugLog('    Start upserting content item');
    IBC_CITEM_ADMIN_GRP.upsert_item(
      p_ctype_code => px_masterdoc_qry_rec.content_type_code,
      p_citem_name => px_masterdoc_qry_rec.FILE_NAME,
      p_citem_description => px_masterdoc_qry_rec.DESCRIPTION,
	  p_dir_node_id => l_directory, -- TEMPLATE -4 , Query -11 directory node
      p_reference_code => NULL,
      p_trans_required => FND_API.G_FALSE,
	  p_wd_restricted => FND_API.G_FALSE,
      p_start_date => NULL,
      p_end_date => NULL,
      p_attribute_type_codes => l_attribute_type_codes,
      p_attributes => l_attributes,
      p_attach_file_id => l_query,
	  p_component_citems => l_compound_content_items,
      p_component_atypes  => l_compound_attribute_types,
      p_status => l_status,
      p_language => USERENV('LANG'),
      p_commit => FND_API.G_FALSE,
      px_content_item_id => px_masterdoc_qry_rec.content_item_id,
      px_citem_ver_id => px_masterdoc_qry_rec.citem_version_id,
      px_object_version_number => l_object_version_number,
      x_return_status => l_return_status,
      x_msg_count => l_msg_count,
      x_msg_data => l_msg_data);
    IF l_return_status <> FND_API.g_ret_sts_success THEN
      printDebugLog('    Error in base content item creation:'||l_msg_data);
	 RAISE FND_API.g_exc_error;
    END IF;

       printDebugLog(' After Upsert content Item ID and CITEM_VERID is: ' ||px_masterdoc_qry_rec.content_item_id || ':' ||px_masterdoc_qry_rec.citem_version_id);

  END IF;
  x_return_status := FND_API.g_ret_sts_success;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO process_content_item;
    x_return_status := FND_API.g_ret_sts_error;
END process_content_item;

PROCEDURE process_content_items(
  px_masterdoc_qry_tbl IN OUT NOCOPY MASTERDOC_QRY_TBL_TYPE,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data OUT NOCOPY VARCHAR2)
IS
  l_i NUMBER;
  l_j NUMBER;
  l_duplicate VARCHAR2(1);
  l_return_status VARCHAR2(1);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(2000);

BEGIN
  SAVEPOINT process_content_items;
  x_return_status := FND_API.g_ret_sts_success;
  printDebugLog('  process_content_items begin');
  IF px_masterdoc_qry_tbl.count > 0 THEN
    printDebugLog('    content item number='||px_masterdoc_qry_tbl.count);
    FOR l_i IN 1..px_masterdoc_qry_tbl.count LOOP
      printDebugLog('    Content item '||l_i
	   ||' item code:'||px_masterdoc_qry_tbl(l_i).content_type_code
	   ||' file id:'||px_masterdoc_qry_tbl(l_i).file_id
	   ||' file name:'||px_masterdoc_qry_tbl(l_i).file_name);


        l_return_status := FND_API.g_ret_sts_success;

          process_content_item(
            px_masterdoc_qry_rec => px_masterdoc_qry_tbl(l_i),
            x_return_status => l_return_status,
            x_msg_count => l_msg_count,
            x_msg_data => l_msg_data);
          printDebugLog('    process_content_item return:'||l_return_status);

       IF (l_return_status = FND_API.g_ret_sts_success)
	   THEN

		     g_idx_created := g_idx_created + 1;

		     MIGRATED_CONTENT(g_idx_created).content_type_code
		     := px_masterdoc_qry_tbl(l_i).CONTENT_TYPE_CODE;
		     MIGRATED_CONTENT(g_idx_created).FILE_ID
			 := px_masterdoc_qry_tbl(l_i).FILE_ID;
		     MIGRATED_CONTENT(g_idx_created).file_name
		     := px_masterdoc_qry_tbl(l_i).FILE_NAME;
			 MIGRATED_CONTENT(g_idx_created).ITEM_ID
			 := px_masterdoc_qry_tbl(l_i).ITEM_ID;
			 MIGRATED_CONTENT(g_idx_created).CONTENT_ITEM_ID
			 := px_masterdoc_qry_tbl(l_i).CONTENT_ITEM_ID ;
			  printDebugLog(' Content ID in process content items is :' || px_masterdoc_qry_tbl(l_i).CONTENT_ITEM_ID );
			 MIGRATED_CONTENT(g_idx_created).CITEM_VERSION_ID
			 := px_masterdoc_qry_tbl(l_i).CITEM_VERSION_ID;
			  printDebugLog(' Content VERSION ID in process content items is :' || px_masterdoc_qry_tbl(l_i).CITEM_VERSION_ID );
			 MIGRATED_CONTENT(g_idx_created).DESCRIPTION
			 := px_masterdoc_qry_tbl(l_i).DESCRIPTION;
			 MIGRATED_CONTENT(g_idx_created).QUERY_CITEM_ID
			 := px_masterdoc_qry_tbl(l_i).QUERY_CITEM_ID;
			 MIGRATED_CONTENT(g_idx_created).MIGRATION_CODE
			 := px_masterdoc_qry_tbl(l_i).MIGRATION_CODE;

	   END IF; -- end of statistics

    END LOOP;
    COMMIT;
  END IF;
  printDebuglog('    process_content_items end');
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO process_content_items;
    x_return_status := FND_API.g_ret_sts_error;
END process_content_items;







PROCEDURE query_mig(x_status OUT NOCOPY VARCHAR2)
IS

  CURSOR c_get_query_details_csr  IS
	 SELECT QUERY_ID,QUERY_NAME, QUERY_DESC, FILE_ID from JTF_FM_QUERIES_ALL ;

  l_query_id NUMBER;
  l_query_name VARCHAR2(50);
  l_query_desc VARCHAR2(255);
  l_query_file_id NUMBER;
  l_query_content_item_id NUMBER;

  l_index  NUMBER := 0;
  l_return_status VARCHAR2(1);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(2000);




BEGIN

	-- Check to see if any Query was attached to this doc
	-- If query is present, first Migrate the query into OCM
	-- Get the content_item_id in OCM for that Query
	-- Add that as an attribute of the template
	 OPEN c_get_query_details_csr();
	   LOOP

			     FETCH c_get_query_details_csr INTO l_query_id,l_query_name,l_query_desc,l_query_file_id;
		         EXIT  WHEN c_get_query_details_csr%NOTFOUND ;

				   l_index := l_index + 1;
				     l_query_tbl(l_index).MIGRATION_CODE := 'JTF_FM_QUERY_MIG';
				      l_query_tbl(l_index).item_id := l_query_id;
                      l_query_tbl(l_index).CONTENT_TYPE_CODE := 'AMF_QUERY';
	                  l_query_tbl(l_index).file_id := l_query_file_id;
	                  l_query_tbl(l_index).file_name := l_query_name;
	                  l_query_tbl(l_index).DESCRIPTION := l_query_desc;
					  l_query_tbl(l_index).CONTENT_ITEM_ID := null;
					  l_query_tbl(l_index).CITEM_VERSION_ID := null;

     END LOOP;
			  CLOSE c_get_query_details_csr;


			   process_content_items(
	                  px_masterdoc_qry_tbl => l_query_tbl,
                      x_return_status => l_return_status,
                      x_msg_count => l_msg_count,
                      x_msg_data => l_msg_data);
               printDebuglog('  process_content_items return:'||l_return_status);
               IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                    raise Fnd_Api.G_EXC_UNEXPECTED_ERROR;
               END IF;
	EXCEPTION

	WHEN OTHERS THEN
	       FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.g_false,
          p_count => l_msg_count,
          p_data  => l_msg_data
          );
		  printDebugLog('x_message: '||l_msg_data);

END query_mig;

PROCEDURE CREATE_EMPTY_TEXT_BLOB(l_file_id OUT NOCOPY NUMBER)
IS
 l_set_prof BOOLEAN;
BEGIN
   select fnd_lobs_s.nextval into l_file_id from dual;
   INSERT INTO fnd_lobs(file_id,file_name,file_content_type,file_data,upload_date, file_format)
   VALUES (l_file_id,'Dummy FM TEXT file','text/plain',empty_blob(),sysdate, 'text');
   g_text_file_id := l_file_id;
   printDebugLog('DUmmy TEXTFILE ID IS :' || l_file_id);
   l_set_prof := FND_PROFILE.save('JTF_FM_TEXT_FND_ID', l_file_id, 'APPL', '690');

END CREATE_EMPTY_TEXT_BLOB;


PROCEDURE master_document_mig(
  x_status OUT NOCOPY VARCHAR2)
IS

  -- This cursor is to get all documents uploaded by fulfillment & marketing
  CURSOR c_get_item_csr IS
    select b.item_id
	 from jtf_amv_items_b b
     where b.content_type_id = 20
	  and b.application_id IN(690,530)
     ORDER BY b.item_id;

  -- This cursor is to find all attachments defined
  -- in content repository  for the items in c_get_item_cur
  CURSOR c_get_content_repository_csr(c_item_id NUMBER)  IS
    SELECT distinct file_id, file_name,description
	FROM jtf_amv_attachments a
    WHERE attachment_used_by_id = c_item_id
    AND file_id IS NOT NULL;

  -- Check if this document has an associated query
  CURSOR c_get_query_csr(c_item_id NUMBER)  IS
     SELECT QUERY_ID from JTF_FM_QUERY_MES where MES_DOC_ID = c_item_id;

  -- Get the CITEM_ID for the associated QUERY, assuming it has already been migrated to OCM
  CURSOR c_get_query_details_csr(c_query_id NUMBER)  IS
	 SELECT CONTENT_ITEM_ID from JTF_FM_MIG_HISTORY_DETAILS where item_id = c_query_id;


  l_lang VARCHAR2(4);
  l_langdesc VARCHAR2(255);
  l_default_langdesc VARCHAR2(255);
  l_description VARCHAR2(2000);
  l_i NUMBER;
  l_j NUMBER;
  l_k NUMBER;
  l_index NUMBER;
  l_file_id NUMBER;
  l_file_name VARCHAR2(240);

  l_return_status VARCHAR2(1);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(2000);

  l_item_id NUMBER;
  l_default_language VARCHAR2(4);

  l_query_id NUMBER;
  l_query_name VARCHAR2(50);
  l_query_desc VARCHAR2(255);
  l_query_file_id NUMBER;
  l_query_content_item_id NUMBER;
  l_seperator NUMBER;
  l_ext VARCHAR2(240);


BEGIN
  l_i := 0;
  l_k := 0;
  l_index := 0;

  OPEN c_get_item_csr;
  LOOP
    FETCH c_get_item_csr INTO l_item_id;
    EXIT WHEN c_get_item_csr%NOTFOUND;

    printDebuglog('Item id:'||l_item_id);

	-- Check to see if any Query was attached to this doc
	-- If query is present, first Migrate the query into OCM
	-- Get the content_item_id in OCM for that Query
	-- Add that as an attribute of the template
	  OPEN c_get_query_csr(l_item_id);
	    FETCH c_get_query_csr INTO l_query_id;
		  printDebugLog('Query Id is:' || l_query_id);
		  IF (c_get_query_csr%NOTFOUND)
	      THEN
		     l_query_id := NULL;
		  ELSE
		      OPEN c_get_query_details_csr(l_query_id);
			     FETCH c_get_query_details_csr INTO l_query_content_item_id;
		         EXIT WHEN c_get_query_details_csr%NOTFOUND;
				 printDebugLog('citemid of Query is :' ||l_query_content_item_id);
			  CLOSE c_get_query_details_csr;
		  END IF;
	  CLOSE c_get_query_csr;


    -- Find all minisites this media object linked to
    OPEN c_get_content_repository_csr(l_item_id);
      FETCH c_get_content_repository_csr INTO l_file_id, l_file_name,l_description;
      EXIT WHEN c_get_content_repository_csr%NOTFOUND;


	  printDebuglog('  l file  id:'||l_file_id||' File Name:'||l_file_name);
	  l_seperator := INSTR(l_file_name, '.', -1);

      IF (l_seperator <> 0) THEN
	     l_ext := UPPER(substr(l_file_name,l_seperator+1));
	     IF (l_ext IN ('HTML', 'HTM')) THEN

		  l_i := l_i + 1;
           l_masterdoc_qry_tbl(l_i).item_id := l_item_id;
           l_masterdoc_qry_tbl(l_i).CONTENT_TYPE_CODE := 'AMF_TEMPLATE';
	       l_masterdoc_qry_tbl(l_i).file_id := l_file_id;
	       l_masterdoc_qry_tbl(l_i).file_name := l_file_name;
	       l_masterdoc_qry_tbl(l_i).DESCRIPTION := l_description;
	       l_masterdoc_qry_tbl(l_i).MIGRATION_CODE:= 'JTF_FM_OCM_MIG';
	       IF l_query_id IS NOT NULL
	       THEN
	           l_masterdoc_qry_tbl(l_i).QUERY_CITEM_ID :=  l_query_content_item_id ;
		       printDebuglog('Query attached, citem id is :' ||l_query_content_item_id );

	       END IF;
		 ELSE
	       printDebuglog('File is not of type htm or html, so not migrating' || l_file_name);

		 END IF; -- End IF (l_ext IN ('HTML', 'HTM')) THEN
	   END IF; -- End IF (l_seperator <> 0) THEN


     CLOSE c_get_content_repository_csr;

  END LOOP;
  CLOSE c_get_item_csr;
      process_content_items(
	  px_masterdoc_qry_tbl => l_masterdoc_qry_tbl,
      x_return_status => l_return_status,
      x_msg_count => l_msg_count,
      x_msg_data => l_msg_data);
    printDebuglog('  process_content_items return:'||l_return_status);
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      raise Fnd_Api.G_EXC_UNEXPECTED_ERROR;
    END IF;
  printDebuglog('Content repository migration End');
  x_status := FND_API.g_ret_sts_success;
EXCEPTION
  WHEN OTHERS THEN
    x_status := FND_API.g_ret_sts_error;
END master_document_mig;

PROCEDURE ocmMigration(errbuf OUT NOCOPY VARCHAR2,
  retcode OUT NOCOPY VARCHAR2,
  p_debug_flag IN VARCHAR2)
IS
  l_status VARCHAR2(1);
  l_set_prof BOOLEAN;
  l_num NUMBER :=1;
BEGIN

  IF (check_log(p_code => 'JTF_FM_OCM_MIG',
		      p_status => 'SUCCESS') = 0) THEN

      create_log(p_code => 'JTF_FM_OCM_MIG',
		       p_status => 'START',
		       x_status => l_status);

    IF p_debug_flag = 'Y' THEN
      JTF_FM_MD_MIGRATION_PVT.g_debug := p_debug_flag;
    END IF;

    --g_start_time := SYSDATE;


  IF (check_log(p_code => 'JTF_FM_QUERY_MIG',p_status => 'SUCCESS') = 0)
  THEN

      create_log(p_code => 'JTF_FM_QUERY_MIG',
		       p_status => 'START',
		       x_status => l_status);


	query_mig(
	      x_status => l_status);
    IF (l_status <> FND_API.G_RET_STS_SUCCESS) THEN
      raise Fnd_Api.G_EXC_UNEXPECTED_ERROR;
    END IF;

           update_log(p_code => 'JTF_FM_QUERY_MIG',
			  p_old_status => 'START',
			  p_new_status => 'SUCCESS',
			  p_number => 1,
			  x_status => l_status);

	   l_num := g_idx_created + 1;
   ELSE
       printDEBUGLOG('Queries have already been Migrated, so proceeding with content');
   END IF;

   g_text_file_id := FND_PROFILE.VALUE('JTF_FM_TEXT_FND_ID');

   IF g_text_file_id IS NULL THEN
	   CREATE_EMPTY_TEXT_BLOB(g_text_file_id);
   END IF;

    -- Migrate the attachments to OCM content item
    -- based on the logical items
    master_document_mig(
      x_status => l_status);
    IF (l_status <> FND_API.G_RET_STS_SUCCESS) THEN
      raise Fnd_Api.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --g_end_time := SYSDATE;
    --printReport;

      update_log(p_code => 'JTF_FM_OCM_MIG',
			  p_old_status => 'START',
			  p_new_status => 'SUCCESS',
			  p_number  =>l_num,
			  x_status => l_status);

  END IF;

  retcode := 0;
  errbuf := 'SUCCESS';
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    printOutput(SQLCODE||'-'||SQLERRM);
    printDebuglog(SQLCODE||'-'||SQLERRM);
    retcode := -1;
    errbuf := SQLCODE||'-'||SQLERRM;
END ocmMigration;

END JTF_FM_MD_MIGRATION_PVT;

/
