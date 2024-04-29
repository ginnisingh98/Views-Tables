--------------------------------------------------------
--  DDL for Package Body IBE_M_MIGRATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_M_MIGRATION_PVT" AS
/* $Header: IBEVMMGB.pls 120.0 2005/05/30 02:37:07 appldev noship $ */
g_image_type CONSTANT VARCHAR2(30) := 'IBC_IMAGE';
g_html_type CONSTANT VARCHAR2(30) := 'IBE_HTML';
g_media_type CONSTANT VARCHAR2(30) := 'IBE_MEDIA';

g_label_code CONSTANT VARCHAR2(100) := 'IBE';
g_association_type CONSTANT VARCHAR2(100) := 'IBE_MEDIA_OBJECT';

g_mode VARCHAR2(30);
g_language VARCHAR2(255);
g_idx_conflict NUMBER := 0;
g_idx_created NUMBER := 0;
g_item_conflict NUMBER := 0;
g_item_created NUMBER := 0;
g_html_items NUMBER := 0;
g_image_items NUMBER := 0;
g_media_items NUMBER := 0;
g_start_time DATE;
g_end_time DATE;

unreg_attachments STRING_240_TBL_TYPE;
conflict_content CONTENT_TBL_TYPE;
migrated_content CONTENT_TBL_TYPE;

installed_languages STRING_TBL_TYPE;
installed_langdesc STRING_255_TBL_TYPE;

l_attachment_tbl ATTACHMENT_TBL_TYPE;
l_trans_attachment_tbl TRANS_ATTACHMENT_TBL_TYPE;

FUNCTION check_log(p_code IN VARCHAR2,
                   p_status IN VARCHAR2) RETURN NUMBER
IS
  CURSOR c_check_log_csr(c_code VARCHAR2,
					c_status VARCHAR2) IS
    SELECT 1
	 FROM IBE_MIGRATION_HISTORY
     WHERE migration_code = c_code
	  AND status = c_status;

  CURSOR c_check_item_migrated IS
    SELECT lgl_phys_map_id
	 FROM ibe_dsp_lgl_phys_map
     WHERE content_item_key IS NOT NULL;

  l_temp NUMBER;
BEGIN
  OPEN c_check_log_csr(p_code, p_status);
  FETCH c_check_log_csr INTO l_temp;
  IF (c_check_log_csr%NOTFOUND) THEN
    l_temp := 0;
  ELSE
    OPEN c_check_item_migrated;
    FETCH c_check_item_migrated INTO l_temp;
    IF (c_check_item_migrated%NOTFOUND) THEN
	 l_temp := 0;
    ELSE
	 l_temp := 1;
    END IF;
    CLOSE c_check_item_migrated;
  END IF;
  CLOSE c_check_log_csr;
  RETURN l_temp;
END check_log;

PROCEDURE create_log(p_code IN VARCHAR2,
				 p_status IN VARCHAR2,
				 x_status OUT NOCOPY VARCHAR2)
IS
BEGIN
  DELETE FROM IBE_MIGRATION_HISTORY
	   WHERE MIGRATION_CODE = p_code;
  INSERT INTO IBE_MIGRATION_HISTORY(MIGRATION_CODE,
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
				 x_status OUT NOCOPY VARCHAR2)
IS
BEGIN
  UPDATE IBE_MIGRATION_HISTORY
     SET STATUS = p_new_status,
   	    LAST_UPDATE_DATE = SYSDATE
   WHERE MIGRATION_CODE = p_code
	AND STATUS = p_old_status;
  x_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
  WHEN OTHERS THEN
    x_status := FND_API.G_RET_STS_ERROR;
END update_log;

-- Migration for context
-- p_mode: 'EVALUATION', 'EXECUTION', 'ROLLBACK'
-- update ibe_migration_history
PROCEDURE context_mig(p_mode IN VARCHAR2,
  x_status OUT NOCOPY VARCHAR2,
  x_content_component_tbl OUT NOCOPY CONTENT_COMPONENT_TBL_TYPE)
IS
  -- Migrate the seed data too
  CURSOR c_get_context_csr IS
    SELECT CONTEXT_ID, ACCESS_NAME, COMPONENT_TYPE_CODE
	 FROM IBE_DSP_CONTEXT_B
     WHERE CONTEXT_TYPE_CODE = 'MEDIA'
	  AND (COMPONENT_TYPE_CODE IS NULL
	  OR CONTEXT_ID < 10000);
  --   AND CONTEXT_ID >= 10000

  CURSOR c_get_component_type_csr(c_context_id NUMBER) IS
    SELECT DISTINCT OBJECT_TYPE
	 FROM IBE_DSP_OBJ_LGL_CTNT
	WHERE CONTEXT_ID = c_context_id;

  CURSOR c_get_rollback_csr IS
    SELECT creation_date, last_update_date
	 FROM IBE_MIGRATION_HISTORY
     WHERE MIGRATION_CODE = 'IBE_CONTENT_COMPONENT'
	  AND STATUS = 'SUCCESS';

  l_content_component_tbl CONTENT_COMPONENT_TBL_TYPE;

  l_context_id NUMBER;
  l_access_name VARCHAR2(40);
  l_object_temp VARCHAR2(2);
  l_component_type VARCHAR2(30) := NULL;
  l_i NUMBER;
  l_j NUMBER;

  l_start_date DATE;
  l_end_date DATE;
  l_migcode VARCHAR2(30);
  l_module VARCHAR2(30);

  CURSOR c_get_code(c_migcode VARCHAR2) IS
    SELECT 1
	 FROM IBE_MIGRATION_HISTORY
     WHERE MIGRATION_CODE = c_migcode;
BEGIN
  SAVEPOINT context_mig;
  l_migcode  := 'IBE_CONTENT_COMPONENT';
  l_module  := 'ibe.plsql.migration.context';

  IF p_mode = 'EXECUTION' THEN
    l_migcode := l_migcode || to_char(SYSDATE,'DDMMRRRR');
    OPEN c_get_code(l_migcode);
    FETCH c_get_code INTO l_i;
    IF (c_get_code%NOTFOUND) THEN
	 CLOSE c_get_code;
      INSERT INTO IBE_MIGRATION_HISTORY(MIGRATION_CODE,
	   OBJECT_VERSION_NUMBER, CREATED_BY, CREATION_DATE,
	   LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,STATUS)
      VALUES(l_migcode, 0, FND_GLOBAL.user_id, SYSDATE,
        FND_GLOBAL.user_id, SYSDATE, FND_GLOBAL.user_id, 'START');
    ELSE
	 CLOSE c_get_code;
    END IF;
  END IF;
  l_i := 0;
  OPEN c_get_context_csr;
  LOOP
    FETCH c_get_context_csr INTO l_context_id, l_access_name,
      l_component_type;
    EXIT WHEN c_get_context_csr%NOTFOUND;
    l_i := l_i + 1;
    IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.string(FND_LOG.LEVEL_EVENT, l_module,
                      'Key:'||to_char(l_context_id)||
                      ' Old component_type_code:'||l_component_type);
    END IF;
    OPEN c_get_component_type_csr(l_context_id);
    -- possible value from this cursor is 'C':category, 'I':item
    -- 'S':section
    -- l_component_type := NULL;
    LOOP
	 FETCH c_get_component_type_csr INTO l_object_temp;
	 EXIT WHEN c_get_component_type_csr%NOTFOUND;
	 IF l_object_temp = 'S' THEN
	   IF l_component_type IS NULL THEN
		l_component_type := 'SECTION';
        ELSIF l_component_type = 'PRODUCT' THEN
		l_component_type := 'GENERIC';
	   END IF;
	 ELSIF l_object_temp = 'C' OR l_object_temp = 'I' THEN
	   IF l_component_type IS NULL THEN
		l_component_type := 'PRODUCT';
        ELSIF l_component_type = 'SECTION' THEN
	     l_component_type := 'GENERIC';
	   END IF;
	 END IF;
    END LOOP;
    CLOSE c_get_component_type_csr;
    l_content_component_tbl(l_i).context_id := l_context_id;
    l_content_component_tbl(l_i).access_name := l_access_name;
    IF (l_context_id < 10000) THEN
      l_content_component_tbl(l_i).component_type_code := l_component_type;
    ELSE
	 IF (l_component_type = NULL) THEN
	   l_component_type := 'GENERIC';
	 END IF;
      l_content_component_tbl(l_i).component_type_code := l_component_type;
    END IF;
  END LOOP;
  CLOSE c_get_context_csr;
  IF p_mode = 'EXECUTION' THEN
    IF (l_i > 0) THEN
	 FOR l_j IN 1..l_i LOOP
	   -- No update on last_updated_by based on the review feedback
	   UPDATE IBE_DSP_CONTEXT_B
		 SET COMPONENT_TYPE_CODE
		   = NVL(l_content_component_tbl(l_j).component_type_code,
			COMPONENT_TYPE_CODE),
                     LAST_UPDATE_DATE = SYSDATE
           WHERE context_id = l_content_component_tbl(l_j).context_id;
           IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
             FND_LOG.string(FND_LOG.LEVEL_EVENT, l_module,
                            'Key:'||to_char(l_content_component_tbl(l_j).context_id)
                            ||' New component_type_code:'
                            ||l_content_component_tbl(l_j).component_type_code);
           END IF;
	 END LOOP;
    END IF;
    UPDATE IBE_MIGRATION_HISTORY
      SET STATUS = 'SUCCESS',
  	     LAST_UPDATE_DATE = SYSDATE
     WHERE MIGRATION_CODE = l_migcode
	  AND STATUS = 'START';
  END IF;
  IF p_mode = 'EXECUTION' OR p_mode = 'EVALUATION' THEN
    x_content_component_tbl := l_content_component_tbl;
  ELSE
    x_content_component_tbl := NULL_CONTENT_COMPONENT_TBL;
  END IF;
  x_status := FND_API.g_ret_sts_success;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO context_mig;
    x_status := FND_API.g_ret_sts_error;
END context_mig;

PROCEDURE media_template_mig(p_mode IN VARCHAR2,
  x_status OUT NOCOPY VARCHAR2,
  x_media_tbl OUT NOCOPY MEDIA_TEMPLATE_TBL_TYPE,
  x_template_tbl OUT NOCOPY MEDIA_TEMPLATE_TBL_TYPE)
IS
BEGIN
  x_status := FND_API.g_ret_sts_success;
END media_template_mig;

-------------------------------------------------
-- Debug Information Pring Procedure
-- Y : Display Debug in the Conc. Program Log.
-- N:  No Debug Statement Printout
PROCEDURE printDebuglog(p_debug_str IN VARCHAR2)
IS
BEGIN
--  dbms_output.put_line(p_debug_str);
  IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,p_debug_str);
  END IF;
  IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
  	IBE_UTIL.debug(p_debug_str);
  END IF;
END printDebugLog;

PROCEDURE printOutput(p_message IN VARCHAR2)
IS
BEGIN
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,p_message);
--  dbms_output.put_line(p_message);
END printOutput;

PROCEDURE printReport
IS
  l_i NUMBER;
  l_access_name VARCHAR2(40) := NULL;
  l_store VARCHAR2(40) := NULL;
  l_item_ref_code VARCHAR2(40) := NULL;
  l_seed_flag VARCHAR2(6) := NULL;
  l_all_store VARCHAR2(40) := NULL;
  l_mode VARCHAR2(80);
  l_def_lang VARCHAR2(255);

  l_temp_msg VARCHAR2(2000);
  l_title1 VARCHAR2(2000);

  CURSOR c_get_content_type(c_type_code VARCHAR2) IS
    SELECT content_type_name
	 FROM ibc_content_types_vl
     WHERE content_type_code = c_type_code;

  CURSOR c_get_mode(c_mode VARCHAR2) IS
    SELECT meaning
	 FROM fnd_lookups
     WHERE lookup_type='IBE_M_AUTOPLACEMENT_MODE'
	  and Lookup_code=c_mode;

  CURSOR c_get_lang(c_lang_code VARCHAR2) IS
    SELECT description
	 FROM fnd_languages_vl
     WHERE language_code=c_lang_code;

BEGIN
  -- For all store
  fnd_message.set_name('IBE','IBE_PRMT_ALL_G');
  l_temp_msg := fnd_message.get;
  l_all_store := substr(l_temp_msg,1,40);

  OPEN c_get_mode(g_mode);
  FETCH c_get_mode INTO l_mode;
  IF c_get_mode%FOUND THEN
    g_mode := l_mode;
  END IF;
  CLOSE c_get_mode;
  OPEN c_get_lang(g_language);
  FETCH c_get_lang INTO l_def_lang;
  IF c_get_lang%FOUND THEN
    g_language := l_def_lang;
  END IF;
  CLOSE c_get_lang;
  fnd_message.set_name('IBE','IBE_M_ATTACHMENT_MIG_DESC');
  l_temp_msg := fnd_message.get;
  printOutput(RPAD('=',LENGTH(l_temp_msg)+4,'='));
  printOutput('| '||l_temp_msg||' |');
  printOutput(RPAD('=',LENGTH(l_temp_msg)+4,'='));
  printOutput('');
  -- Concurrent program parameters
  fnd_message.set_name('IBE','IBE_M_CONCURRENT_PARAM_DESC');
  l_temp_msg := fnd_message.get;
  printOutput(l_temp_msg);
  printOutput(RPAD('',LENGTHB(l_temp_msg),'='));
  -- Running Mode
  fnd_message.set_name('IBE', 'IBE_M_RUNNING_MODE_DESC');
  l_temp_msg := fnd_message.get;
  printOutput(l_temp_msg||': '||g_mode);
  -- Default Language
  fnd_message.set_name('IBE', 'IBE_MSITE_PRMT_SP_ST_DEF_LANG');
  l_temp_msg := fnd_message.get;
  printOutput(l_temp_msg||': '||g_language);
  -- printOutput('Running Time:'||to_char(g_start_time,'MM/DD/RRRR HH24:MI:SS')
  --  ||'-'||to_char(g_end_time,'MM/DD/RRRR HH24:MI:SS'));
  printOutput('');
  printOutput('=================================');
  -- Migration summary
  fnd_message.set_name('IBE', 'IBE_MSG_MGRT_SUMMRY');
  l_temp_msg := fnd_message.get;
  printOutput('1. '||l_temp_msg);
  printOutput('=================================');
  -- Number of content items created
  fnd_message.set_name('IBE', 'IBE_M_NUM_CONTENT_ITEM_DESC');
  l_temp_msg := fnd_message.get;
  printOutput(l_temp_msg||': '||to_char(g_item_created));
  printOutput('');
  -- Content Items created by content type
  fnd_message.set_name('IBE', 'IBE_M_ITEM_BY_TYPE_DESC');
  l_temp_msg := fnd_message.get;
  printOutput(l_temp_msg||':');
  OPEN c_get_content_type('IBE_HTML');
  FETCH c_get_content_type INTO l_temp_msg;
  IF c_get_content_type%NOTFOUND THEN
    l_temp_msg := 'HTML';
  END IF;
  CLOSE c_get_content_type;
  printOutput(l_temp_msg||' :'||to_char(g_html_items));
  OPEN c_get_content_type('IBC_IMAGE');
  FETCH c_get_content_type INTO l_temp_msg;
  IF c_get_content_type%NOTFOUND THEN
    l_temp_msg := 'Image';
  END IF;
  CLOSE c_get_content_type;
  printOutput(l_temp_msg||' :'||to_char(g_image_items));
  OPEN c_get_content_type('IBE_MEDIA');
  FETCH c_get_content_type INTO l_temp_msg;
  IF c_get_content_type%NOTFOUND THEN
    l_temp_msg := 'Media';
  END IF;
  CLOSE c_get_content_type;
  printOutput(l_temp_msg||' :'||to_char(g_media_items));
  printOutput('');
  printOutput('===============================');
  fnd_message.set_name('IBE', 'IBE_M_EXCEPTION_REPORT_LBL');
  l_temp_msg := fnd_message.get;
  printOutput('2. '||l_temp_msg);
  printOutput('===============================');
  fnd_message.set_name('IBE', 'IBE_M_EXCEPTION_REPORT_DESC');
  l_temp_msg := fnd_message.get;
  printOutput(l_temp_msg);
  printOutput('');
  fnd_message.set_name('IBE', 'IBE_M_UNIDENTIFIED_ATTCH_LBL');
  l_temp_msg := fnd_message.get;
  printOutput('2.1 '||l_temp_msg);
  printOutput('===========================================');
  fnd_message.set_name('IBE', 'IBE_M_UNIDENTIFIED_ATTCH_DESC');
  l_temp_msg := fnd_message.get;
  printOutput(l_temp_msg);
  fnd_message.set_name('IBE', 'IBE_PRMT_SRC_FILE_NAME');
  l_temp_msg := fnd_message.get;
  printOutput(l_temp_msg);
  printOutput('--------------------');
  IF (unreg_attachments.COUNT > 0) THEN
    FOR l_i IN 1..unreg_attachments.COUNT LOOP
	 printOutput(unreg_attachments(l_i));
    END LOOP;
  END IF;
  printOutput('');
  fnd_message.set_name('IBE', 'IBE_M_DIFF_ATTACHMENT_LBL');
  l_temp_msg := fnd_message.get;
  printOutput('2.2 '||l_temp_msg);
  printOutput('=====================================================');
  fnd_message.set_name('IBE', 'IBE_M_DIFF_ATTACHMENT_DESC');
  l_temp_msg := fnd_message.get;
  printOutput(l_temp_msg);
  printOutput('');
  fnd_message.set_name('IBE', 'IBE_M_MEDIA_ACCESS_NAME_PRMT');
  l_temp_msg := fnd_message.get;
  IF (length(l_temp_msg) >= 40) THEN
    l_title1 := substr(l_temp_msg,1,40)||' ';
  ELSE
    l_title1 := RPAD(l_temp_msg,40,' ')||' ';
  END IF;
  fnd_message.set_name('IBE', 'IBE_M_SEEDED_PRMT');
  l_temp_msg := fnd_message.get;
  IF (length(l_temp_msg) >= 6) THEN
    l_title1 := l_title1 || substr(l_temp_msg,1,6) || ' ';
  ELSE
    l_title1 := l_title1 || RPAD(l_temp_msg,6,' ')||' ';
  END IF;
  fnd_message.set_name('IBE', 'IBE_M_STORE_NAME_PRMT');
  l_temp_msg := fnd_message.get;
  IF (length(l_temp_msg) >= 40) THEN
    l_title1 := l_title1 || substr(l_temp_msg,1,40);
  ELSE
    l_title1 := l_title1 || RPAD(l_temp_msg,40,' ')||' ';
  END IF;
  fnd_message.set_name('IBE', 'IBE_PRMT_LANG_G');
  l_temp_msg := fnd_message.get;
  IF (length(l_temp_msg) >= 30) THEN
    l_title1 := l_title1 || substr(l_temp_msg,1,30);
  ELSE
    l_title1 := l_title1 || RPAD(l_temp_msg,30,' ')||' ';
  END IF;
  fnd_message.set_name('IBE', 'IBE_PRMT_SRC_FILE_NAME');
  l_temp_msg := fnd_message.get;
  l_title1 := l_title1 || l_temp_msg;
  FOR l_i IN 1..CONFLICT_CONTENT.count LOOP
    IF MOD(l_i-1,25) = 0 THEN
	 printOutput('');
      printOutput(l_title1);
      printOutput('-----------------                        ------ ----------' ||
   '                               --------                       ----------------');
    END IF;
    IF (CONFLICT_CONTENT(l_i).access_name IS NULL) THEN
	 l_access_name := RPAD(' ',40,' ');
    ELSE
	 l_access_name := RPAD(CONFLICT_CONTENT(l_i).access_name,40,' ');
    END IF;
    IF (CONFLICT_CONTENT(l_i).store_code IS NULL) THEN
	 l_store := RPAD(' ',40,' ');
    ELSE
	 IF (CONFLICT_CONTENT(l_i).store_code = 'ALL') THEN
        l_store := RPAD(SUBSTR(l_all_store,1,40),40,' ');
	 ELSE
	   l_store := RPAD(SUBSTR(CONFLICT_CONTENT(l_i).store_code,1,40),40,' ');
	 END IF;
    END IF;
    IF (CONFLICT_CONTENT(l_i).seed_flag IS NULL) THEN
	 l_seed_flag := RPAD(' ',6,' ');
    ELSE
	 l_seed_flag := RPAD(CONFLICT_CONTENT(l_i).seed_flag,6,' ');
    END IF;
    printOutput(l_access_name||' '
	 ||l_seed_flag||' '
	 ||l_store||' '
	 ||RPAD(CONFLICT_CONTENT(l_i).language,30,' ')||' '
	 ||CONFLICT_CONTENT(l_i).file_name);
  END LOOP;
  printOutput('');
  printOutput('===============================');
  fnd_message.set_name('IBE', 'IBE_M_MIG_DETAIL_REPORT_PRMT');
  l_temp_msg := fnd_message.get;
  printOutput('3. '||l_temp_msg);
  printOutput('===============================');
  -- Fix bug 2710858
  fnd_message.set_name('IBE', 'IBE_M_MIG_DETAIL_REPORT_DESC');
  l_temp_msg := fnd_message.get;
  printOutput(l_temp_msg);
  printOutput('');
  fnd_message.set_name('IBE', 'IBE_M_MEDIA_ACCESS_NAME_PRMT');
  l_temp_msg := fnd_message.get;
  IF (length(l_temp_msg) >= 40) THEN
    l_title1 := substr(l_temp_msg,1,40)||' ';
  ELSE
    l_title1 := RPAD(l_temp_msg,40,' ')||' ';
  END IF;
  fnd_message.set_name('IBE', 'IBE_M_CONTENT_ITEM_CODE_PRMT');
  l_temp_msg := fnd_message.get;
  IF (length(l_temp_msg) >= 40) THEN
    l_title1 := l_title1 || substr(l_temp_msg,1,40);
  ELSE
    l_title1 := l_title1 || RPAD(l_temp_msg,40,' ')||' ';
  END IF;
  fnd_message.set_name('IBE', 'IBE_M_STORE_NAME_PRMT');
  l_temp_msg := fnd_message.get;
  IF (length(l_temp_msg) >= 40) THEN
    l_title1 := l_title1 || substr(l_temp_msg,1,40);
  ELSE
    l_title1 := l_title1 || RPAD(l_temp_msg,40,' ')||' ';
  END IF;
  fnd_message.set_name('IBE', 'IBE_PRMT_LANG_G');
  l_temp_msg := fnd_message.get;
  IF (length(l_temp_msg) >= 30) THEN
    l_title1 := l_title1 || substr(l_temp_msg,1,30);
  ELSE
    l_title1 := l_title1 || RPAD(l_temp_msg,30,' ')||' ';
  END IF;
  fnd_message.set_name('IBE', 'IBE_PRMT_SRC_FILE_NAME');
  l_temp_msg := fnd_message.get;
  l_title1 := l_title1 || l_temp_msg;
  FOR l_i IN 1..MIGRATED_CONTENT.count LOOP
    IF MOD(l_i-1,25) = 0 THEN
	 printOutput('');
      printOutput(l_title1);
      printOutput('-----------------                        -----------------  '||
    '                      ----------                               -------- ' ||
    '                      ----------------');
    END IF;
    IF (MIGRATED_CONTENT(l_i).access_name IS NULL) THEN
	 l_access_name := RPAD(' ',40,' ');
    ELSE
	 l_access_name := RPAD(MIGRATED_CONTENT(l_i).access_name,40,' ');
    END IF;
    IF (MIGRATED_CONTENT(l_i).store_code IS NULL) THEN
	 l_store := RPAD(' ',40,' ');
    ELSE
	 IF l_store = 'ALL' THEN
        l_store := RPAD(SUBSTR(l_all_store,1,40),40,' ');
	 ELSE
	   l_store := RPAD(SUBSTR(MIGRATED_CONTENT(l_i).store_code,1,40),40,' ');
	 END IF;
    END IF;
    IF (MIGRATED_CONTENT(l_i).content_item_code IS NULL) THEN
	 l_item_ref_code := RPAD(' ',40,' ');
    ELSE
	 l_item_ref_code
	   := RPAD(SUBSTR(MIGRATED_CONTENT(l_i).content_item_code,1,40),40,' ');
    END IF;
    printOutput(l_access_name||' '||l_item_ref_code||' '||l_store||' '
	 ||RPAD(MIGRATED_CONTENT(l_i).language,30,' ')||' '
      ||MIGRATED_CONTENT(l_i).file_name);
  END LOOP;
END printReport;

-- This procedure checks the migrated attachment
-- can be recognized by the program
-- Fix for perf bug 2854588, sql id 5044302
PROCEDURE attachType IS
  CURSOR c_get_attachment_csr IS
    SELECT DISTINCT file_name
	 FROM jtf_amv_attachments a
     WHERE application_id = 671
	  AND file_id IS NOT NULL
	  AND attachment_used_by = 'ITEM'
	  AND NOT EXISTS (
		  SELECT NULL
		    FROM ibe_dsp_lgl_phys_map b, jtf_amv_items_b c
             WHERE a.attachment_id = b.attachment_id
               AND c.item_id = b.item_id
			AND c.deliverable_type_code = 'TEMPLATE');

  l_file_name VARCHAR2(240);
  l_i NUMBER;
  l_seperator NUMBER;
  l_ext VARCHAR2(240);
  l_unreg_flag VARCHAR2(1);
BEGIN
  l_i := 0;
  OPEN c_get_attachment_csr;
  LOOP
    FETCH c_get_attachment_csr INTO l_file_name;
    EXIT WHEN c_get_attachment_csr%NOTFOUND;
    l_seperator := INSTR(l_file_name, '.', -1);
    l_unreg_flag := 'N';
    IF (l_seperator <> 0) THEN
	 l_ext := UPPER(substr(l_file_name,l_seperator+1));
	 IF (l_ext IN ('JPG', 'JPEG', 'JFIF', 'JPE', 'PNG', 'GIF', 'GFA',
		 'HTML', 'HTM')) THEN
	   l_unreg_flag := 'Y';
      END IF;
    END IF;
    IF (l_unreg_flag = 'N') THEN
      l_i := l_i + 1;
      unreg_attachments(l_i) := l_file_name;
    END IF;
  END LOOP;
  CLOSE c_get_attachment_csr;
END attachType;

-- This procedure is to get the attachment for content item
-- base language
PROCEDURE get_base_content(
  p_item_id IN NUMBER,
  p_msite_id IN NUMBER,
  p_default_msite IN VARCHAR2,
  p_language_code IN VARCHAR2,
  x_file_id OUT NOCOPY NUMBER,
  x_file_name OUT NOCOPY VARCHAR2,
  x_height OUT NOCOPY NUMBER,
  x_width OUT NOCOPY NUMBER,
  x_translate_flag OUT NOCOPY VARCHAR2)
IS
  -- Fix the height and width issue
  CURSOR c_get_mapping_csr(c_item_id NUMBER,
    c_msite_id NUMBER, c_default_msite VARCHAR2,
    c_language_code VARCHAR2, c_default_lang VARCHAR2) IS
--    SELECT b.file_id, b.display_width, b.display_height, b.file_name
    SELECT b.file_id, b.display_height, b.display_width, b.file_name
	 FROM jtf_amv_attachments b, ibe_dsp_lgl_phys_map a
     WHERE a.attachment_id = b.attachment_id
	  AND a.default_language = c_default_lang
	  AND a.language_code = c_language_code
	  AND a.default_site = c_default_msite
	  AND a.msite_id = c_msite_id
	  AND a.item_id = c_item_id;

  CURSOR c_get_any_mapping(c_item_id NUMBER,
    c_msite_id NUMBER, c_default_msite VARCHAR2) IS
--    SELECT b.file_id, b.display_width, b.display_height, b.file_name
    SELECT b.file_id, b.display_height, b.display_width, b.file_name
	 FROM jtf_amv_attachments b, ibe_dsp_lgl_phys_map a
     WHERE a.attachment_id = b.attachment_id
	  AND a.default_site = c_default_msite
	  AND a.msite_id = c_msite_id
	  AND a.item_id = c_item_id;

  l_height NUMBER;
  l_width NUMBER;
  l_file_id NUMBER;
  l_file_name VARCHAR2(240);
  l_translate_flag VARCHAR2(1);
  l_continue_flag VARCHAR2(1);
BEGIN
  IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
    printDebuglog('    get_base_content begin');
    printDebuglog('    p_item_id='||p_item_id||' p_msite_id='||p_msite_id||
                  ' p_default_msite='||p_default_msite||' p_language_code='||
                  p_language_code);
  END IF;
  -- Check if the base language has the mapping
  l_continue_flag  := 'Y';
  OPEN c_get_mapping_csr(p_item_id, p_msite_id,
    p_default_msite, p_language_code, 'N');
  FETCH c_get_mapping_csr INTO l_file_id, l_height, l_width, l_file_name;
  IF (c_get_mapping_csr%FOUND) THEN
    -- If the base language has mapping, then need to
    -- translate the other languages during merging
    l_continue_flag := 'N';
    l_translate_flag := 'Y';
  END IF;
  CLOSE c_get_mapping_csr;
  IF (l_continue_flag = 'Y') THEN
    -- Check if there is mapping for all language of the minisite
    OPEN c_get_mapping_csr(p_item_id, p_msite_id,
      p_default_msite, 'US', 'Y');
    FETCH c_get_mapping_csr INTO l_file_id, l_height, l_width, l_file_name;
    IF (c_get_mapping_csr%FOUND) THEN
	 -- If the all language is defined, use all language
	 -- mapping as the base language content, and no need
	 -- to translate the other languages
	 l_continue_flag := 'N';
	 l_translate_flag := 'N';
    END IF;
    CLOSE c_get_mapping_csr;
  END IF;
  IF (l_continue_flag = 'Y') AND (p_default_msite = 'N') THEN
    -- If this is for a specific minisite, then check if there
    -- is all minisite mapping for the base language
    OPEN c_get_mapping_csr(p_item_id, 1, 'Y', p_language_code, 'N');
    FETCH c_get_mapping_csr INTO l_file_id, l_height, l_width, l_file_name;
    IF (c_get_mapping_csr%FOUND) THEN
	 -- use all minisite and specific language mapping as
	 -- base language content, but need translate the other
	 -- languages
	 l_continue_flag := 'N';
	 l_translate_flag := 'Y';
    END IF;
    CLOSE c_get_mapping_csr;
    IF (l_continue_flag = 'Y') THEN
      OPEN c_get_mapping_csr(p_item_id, 1, 'Y', 'US', 'Y');
      FETCH c_get_mapping_csr INTO l_file_id, l_height, l_width, l_file_name;
      IF (c_get_mapping_csr%FOUND) THEN
	   -- use all minisite and all language mapping as the
	   -- base language content, indicate the all language
	   -- mapping is used for base language
	   l_continue_flag := 'N';
	   l_translate_flag := 'A';
      END IF;
    END IF;
  END IF;
  -- If cannot find mapping for the base language
  -- pick up first one of the mapping as the base
  -- language attachment
  IF (l_continue_flag = 'Y') THEN
   OPEN c_get_any_mapping(p_item_id, p_msite_id, p_default_msite);
   FETCH c_get_any_mapping INTO l_file_id, l_height, l_width, l_file_name;
   IF (c_get_any_mapping%FOUND) THEN
	l_continue_flag := 'N';
	l_translate_flag := 'N';
   END IF;
  END IF;
  IF (l_continue_flag = 'Y') THEN
    x_file_id := -1;
    x_height := -1;
    x_width := -1;
    x_translate_flag := null;
    x_file_name := null;
  ELSE
    x_file_id := l_file_id;
    x_height := l_height;
    x_width := l_width;
    x_translate_flag := l_translate_flag;
    x_file_name := l_file_name;
  END IF;
  IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
    printDebuglog('    x_file_id='||x_file_id||' x_height='||x_height||
      ' x_width='||x_width||' x_translate_flag='||x_translate_flag||
      ' x_file_name='||x_file_name);
    printDebuglog('    get_base_content end');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
      printDebuglog('get exception in get_base_content');
      printDebuglog('sqlcode:'||SQLCODE||' sqlerr;'||SQLERRM);
    END IF;
END get_base_content;

-- This procedure is to get the attachment for content item
-- translated languages
PROCEDURE get_trans_content(
  p_item_id IN NUMBER,
  p_msite_id IN NUMBER,
  p_default_msite IN VARCHAR2,
  p_language_code IN VARCHAR2,
  p_translate_flag IN VARCHAR2,
  x_file_id OUT NOCOPY NUMBER,
  x_file_name OUT NOCOPY VARCHAR2,
  x_height OUT NOCOPY NUMBER,
  x_width OUT NOCOPY NUMBER)
IS
  -- Fix the height and width issue
  CURSOR c_get_mapping_csr(c_item_id NUMBER,
    c_msite_id NUMBER, c_default_msite VARCHAR2,
    c_language_code VARCHAR2, c_default_lang VARCHAR2) IS
--    SELECT b.file_id, b.display_width, b.display_height, b.file_name
    SELECT b.file_id, b.display_height, b.display_width, b.file_name
	 FROM jtf_amv_attachments b, ibe_dsp_lgl_phys_map a
     WHERE a.attachment_id = b.attachment_id
	  AND a.default_language = c_default_lang
	  AND a.language_code = c_language_code
	  AND a.default_site = c_default_msite
	  AND a.msite_id = c_msite_id
	  AND a.item_id = c_item_id;

  l_continue_flag VARCHAR2(1);
  l_height NUMBER;
  l_width NUMBER;
  l_file_id NUMBER;
  l_file_name VARCHAR2(240);
BEGIN
  IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
    printDebuglog('    get_trans_content begin');
    printDebuglog('    p_item_id='||p_item_id||' p_msite_id='||p_msite_id||
      ' p_default_msite='||p_default_msite||' p_language_code='||p_language_code||
      ' p_translate_flag='||p_translate_flag);
  END IF;
  -- Check if the specific language has the mapping
    l_continue_flag := 'Y';
  OPEN c_get_mapping_csr(p_item_id, p_msite_id,
    p_default_msite, p_language_code, 'N');
  FETCH c_get_mapping_csr INTO l_file_id, l_height, l_width, l_file_name;
  IF (c_get_mapping_csr%FOUND) THEN
    l_continue_flag := 'N';
  END IF;
  CLOSE c_get_mapping_csr;
  IF (l_continue_flag = 'Y') AND
    (p_translate_flag = 'Y' OR p_translate_flag = 'A') THEN
    OPEN c_get_mapping_csr(p_item_id, p_msite_id,
	 p_default_msite, 'US', 'Y');
    FETCH c_get_mapping_csr INTO l_file_id, l_height, l_width, l_file_name;
    IF (c_get_mapping_csr%FOUND) THEN
      l_continue_flag := 'N';
    END IF;
    CLOSE c_get_mapping_csr;
    IF (l_continue_flag = 'Y') AND (p_translate_flag = 'Y') THEN
	 OPEN c_get_mapping_csr(p_item_id, 1, 'Y', 'US', 'Y');
	 FETCH c_get_mapping_csr INTO l_file_id, l_height, l_width, l_file_name;
	 IF (c_get_mapping_csr%FOUND) THEN
	   l_continue_flag := 'N';
	 END IF;
      CLOSE c_get_mapping_csr;
    END IF;
  END IF;
  IF (l_continue_flag = 'Y') THEN
    x_file_id := -1;
    x_height := -1;
    x_width := -1;
    x_file_name := null;
  ELSE
    x_file_id := l_file_id;
    x_height := l_height;
    x_width := l_width;
    x_file_name := l_file_name;
  END IF;
  IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
    printDebuglog('    x_file_id='||x_file_id||' x_height='||x_height||
      ' x_width='||x_width||' x_file_name='||x_file_name);
    printDebuglog('    get_trans_content end');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
      printDebuglog('get exception in get_trans_content');
      printDebuglog('sqlcode:'||SQLCODE||' sqlerr;'||SQLERRM);
    END IF;
END get_trans_content;

-- This procedure is used to decide content type of the
-- content item
PROCEDURE contentItemType(
  p_attachment_rec IN OUT NOCOPY ATTACHMENT_REC_TYPE)
IS
  l_i NUMBER;
  l_j NUMBER := 0;
  l_seperator NUMBER;
  l_ext VARCHAR2(240);
  l_unreg_flag VARCHAR2(1);
  l_file_name VARCHAR2(240);
BEGIN
  p_attachment_rec.conflict_flag := 'N';
  IF (p_attachment_rec.start_trans <> -1) THEN
    l_j := p_attachment_rec.end_trans-p_attachment_rec.start_trans+1;
  END IF;
  p_attachment_rec.content_type_code := NULL;
  FOR l_i IN 1..(l_j+1) LOOP
    IF (l_i=1) THEN
      l_file_name := p_attachment_rec.file_name;
    ELSE
	 l_file_name
	   := l_trans_attachment_tbl(l_i-2+p_attachment_rec.start_trans).file_names;
    END IF;
    l_seperator := INSTR(l_file_name, '.', -1);
    IF (l_seperator <> 0) THEN
	 l_ext := UPPER(substr(l_file_name,l_seperator+1));
	 IF (l_ext IN ('JPG','JPEG','JFIF','JPE','PNG','GIF','GFA')) THEN
	   IF p_attachment_rec.content_type_code IS NULL THEN
		p_attachment_rec.content_type_code := g_image_type;
	   ELSIF p_attachment_rec.content_type_code = g_html_type THEN
		p_attachment_rec.content_type_code := g_media_type;
		p_attachment_rec.conflict_flag := 'Y';
	   ELSIF p_attachment_rec.content_type_code = g_media_type THEN
		p_attachment_rec.conflict_flag := 'Y';
	   END IF;
	 ELSIF (l_ext IN ('HTML', 'HTM')) THEN
	   IF p_attachment_rec.content_type_code IS NULL THEN
		p_attachment_rec.content_type_code := g_html_type;
        ELSIF p_attachment_rec.content_type_code = g_image_type THEN
		p_attachment_rec.content_type_code := g_media_type;
	   ELSIF p_attachment_rec.content_type_code = g_media_type THEN
		p_attachment_rec.conflict_flag := 'Y';
	   END IF;
	 ELSE
	   p_attachment_rec.content_type_code := g_media_type;
      END IF;
    END IF;
  END LOOP;
  IF (p_attachment_rec.content_type_code IS NULL) THEN
    p_attachment_rec.content_type_code := g_media_type;
  END IF;
END contentItemType;

-- This function is used to compare two content items to
-- see if the migration can reuse content item for one
-- logical item
FUNCTION compareContentItem(
  l_src_att IN ATTACHMENT_REC_TYPE,
  l_tar_att IN ATTACHMENT_REC_TYPE) RETURN VARCHAR2
IS
  l_i NUMBER;
BEGIN
  IF (l_src_att.language<>l_tar_att.language) THEN
    RETURN 'N';
  END IF;
  IF (l_src_att.file_id<>l_tar_att.file_id) THEN
    RETURN 'N';
  END IF;
  IF (l_src_att.file_name<>l_tar_att.file_name) THEN
    RETURN 'N';
  END IF;
  IF (l_src_att.END_TRANS-l_src_att.START_TRANS)<>
	(l_tar_att.END_TRANS-l_tar_att.START_TRANS) THEN
    RETURN 'N';
  END IF;
  IF ((l_src_att.START_TRANS=-1) AND (l_tar_att.START_TRANS<>-1))
    OR ((l_src_att.START_TRANS<>-1) AND (l_tar_att.START_TRANS=-1)) THEN
    RETURN 'N';
  END IF;
  IF (l_src_att.START_TRANS <> -1) THEN
    FOR l_i IN 1..(l_tar_att.END_TRANS-l_src_att.START_TRANS+1) LOOP
	 IF l_trans_attachment_tbl(l_src_att.START_TRANS+l_i-1).TRANS_LANGUAGES
	   <> l_trans_attachment_tbl(l_tar_att.START_TRANS+l_i-1).TRANS_LANGUAGES THEN
	   RETURN 'N';
      END IF;
	 IF l_trans_attachment_tbl(l_src_att.START_TRANS+l_i-1).FILE_IDS
	   <> l_trans_attachment_tbl(l_tar_att.START_TRANS+l_i-1).FILE_IDS THEN
	   RETURN 'N';
      END IF;
    END LOOP;
  END IF;
  RETURN 'Y';
EXCEPTION
  WHEN OTHERS THEN
    RETURN 'N';
END compareContentItem;

-- This procedure is to handle new content item
-- and put it into IBC tables
PROCEDURE process_content_item(
  p_label_flag IN VARCHAR2,
  px_attachment_rec IN OUT NOCOPY ATTACHMENT_REC_TYPE,
  x_return_status OUT NOCOPY VARCHAR2,
  x_msg_count OUT NOCOPY NUMBER,
  x_msg_data OUT NOCOPY VARCHAR2)
IS
  l_i NUMBER;
  l_j NUMBER;
  l_return_status VARCHAR2(1);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(2000);

  l_type_code VARCHAR2(100) := g_media_type;
  l_label_code VARCHAR2(100) := g_label_code;
  l_association_type VARCHAR2(100) := g_association_type;
  l_status VARCHAR2(30) := IBC_UTILITIES_PUB.G_STV_APPROVED;
  l_cv_label_rec Ibc_Cv_Label_Grp.CV_Label_Rec_Type;
  x_cv_label_rec Ibc_Cv_Label_Grp.CV_Label_Rec_Type;
  l_attribute_type_codes JTF_VARCHAR2_TABLE_100;
  l_attributes JTF_VARCHAR2_TABLE_4000;
  l_attidx NUMBER;

  -- l_assoc_type_codes JTF_VARCHAR2_TABLE_100;
  -- l_assoc_objects JTF_VARCHAR2_TABLE_300;

  l_object_version_number NUMBER := 0;

  l_content_item_id NUMBER;
  l_citem_version_id NUMBER;
  l_lgl_phys_map_id NUMBER;
  l_version_number NUMBER;
  l_move_label NUMBER;
  l_old_version NUMBER;
  l_old_ver_num NUMBER;
  l_old_item NUMBER;

  CURSOR c_get_content_item_csr(c_item_ref_code VARCHAR2,
					   c_label_code VARCHAR2) IS
    SELECT a.content_item_id, b.citem_version_id
	 FROM ibc_content_items a, ibc_citem_version_labels b
     WHERE a.item_reference_code = c_item_ref_code
	  AND a.content_item_id = b.content_item_id
	  AND b.label_code = c_label_code;

  CURSOR c_get_item_version_csr(c_item_ref_code VARCHAR2) IS
    SELECT a.content_item_id, b.citem_version_id
	 FROM ibc_content_items a, ibc_citem_versions_b b
     WHERE a.item_reference_code = c_item_ref_code
	  AND a.content_item_id = b.citem_version_id
	  AND b.citem_version_status = IBC_UTILITIES_PUB.G_STV_APPROVED;

  CURSOR c_get_content_item(c_item_ref_code VARCHAR2) IS
    SELECT content_item_id
	 FROM ibc_content_items
     WHERE item_reference_code = c_item_ref_code;

  CURSOR c_get_lgl_phys_map_id_csr IS
    SELECT IBE_DSP_LGL_PHYS_MAP_S1.nextval
	 FROM dual;

  CURSOR c_check_map(c_item_id NUMBER, c_msite_id NUMBER,
    c_lang_code VARCHAR2, c_def_msite VARCHAR2, c_def_lang VARCHAR2) IS
    SELECT 1
	 FROM IBE_DSP_LGL_PHYS_MAP
     WHERE item_id = c_item_id
	  AND msite_id = c_msite_id
       AND language_code = c_lang_code
	  AND default_site = c_def_msite
	  AND default_language = c_def_lang
	  AND attachment_id = -1;

  CURSOR c_get_version_number(c_citem_version_id NUMBER) IS
    SELECT version_number
	 FROM ibc_citem_versions_b
     WHERE citem_version_id = c_citem_version_id;

  l_upsert_item VARCHAR2(1);
  l_label_associate_item VARCHAR2(1);

BEGIN
  SAVEPOINT process_content_item;
  IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
    printDebugLog('Start processing item');
  END IF;
  l_upsert_item  := 'Y';
  l_label_associate_item  := 'Y';

  l_move_label := 0;
/*
  IF px_attachment_rec.seed_data_flag = 'Y' THEN
    -- OPEN c_get_content_item_csr(px_attachment_rec.access_name, l_label_code);
    OPEN c_get_content_item_csr(px_attachment_rec.content_item_code,
	 l_label_code);
    FETCH c_get_content_item_csr INTO l_content_item_id, l_citem_version_id;
    IF (c_get_content_item_csr%NOTFOUND) THEN
	 l_citem_version_id := NULL;
	 -- OPEN c_get_content_item(px_attachment_rec.access_name);
	 OPEN c_get_content_item(px_attachment_rec.content_item_code);
	 FETCH c_get_content_item INTO l_content_item_id;
	 IF (c_get_content_item%NOTFOUND) THEN
	   l_content_item_id := NULL;
	 END IF;
	 CLOSE c_get_content_item;
    ELSE
	 l_old_version := l_citem_version_id;
	 l_citem_version_id := NULL;
      l_move_label := 1;
    END IF;
    CLOSE c_get_content_item_csr;
  ELSIF px_attachment_rec.duplicate_flag = 'Y' THEN
*/
  IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
    printDebuglog('  duplicate flag='||px_attachment_rec.duplicate_flag);
  END IF;
  IF px_attachment_rec.duplicate_flag = 'Y' THEN
    l_upsert_item := 'N';
    l_label_associate_item := 'N';
    l_content_item_id := px_attachment_rec.content_item_id;
    l_citem_version_id := px_attachment_rec.citem_version_id;
    l_move_label := -1;
  ELSE
    OPEN c_get_content_item_csr(px_attachment_rec.content_item_code,
	 l_label_code);
    FETCH c_get_content_item_csr INTO l_content_item_id, l_citem_version_id;
    IF (c_get_content_item_csr%NOTFOUND) THEN
      IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
	     printDebuglog('  labeled version is not found for '
	                   ||px_attachment_rec.content_item_code||' label '||l_label_code);
      END IF;
	OPEN c_get_item_version_csr(px_attachment_rec.content_item_code);
	FETCH c_get_item_version_csr INTO l_content_item_id, l_citem_version_id;
	IF (c_get_item_version_csr%NOTFOUND) THEN
    IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
	   printDebuglog('  approved version is not found for '
	                 ||px_attachment_rec.content_item_code);
    END IF;
	 l_upsert_item := 'Y';
	 l_label_associate_item := 'Y';
	 l_citem_version_id := NULL;
	 OPEN c_get_content_item(px_attachment_rec.content_item_code);
	 FETCH c_get_content_item INTO l_content_item_id;
	 IF (c_get_content_item%NOTFOUND) THEN
      IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
	     printDebuglog('  content item not found for '
	                   ||px_attachment_rec.content_item_code);
      END IF;
	   l_content_item_id := NULL;
      END IF;
	 CLOSE c_get_content_item;
     ELSE
       IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
	      printDebuglog('  approved version is found for '
	                    ||px_attachment_rec.content_item_code);
       END IF;
   	 l_upsert_item := 'N';
	    l_label_associate_item := 'Y';
	END IF;
	CLOSE c_get_item_version_csr;
    ELSE
    IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
	   printDebuglog(' labeled version is found for '
	                 ||px_attachment_rec.content_item_code||' label '||l_label_code);
    END IF;
	 l_upsert_item := 'N';
	 l_label_associate_item := 'N';
    END IF;
    CLOSE c_get_content_item_csr;
  END IF;
  IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
    printDebugLog('  l_upsert_item='||l_upsert_item);
    printDebugLog('  l_label_associate_item='||l_label_associate_item);
    printDebugLog('  After finding content item id and citem version id');
    printDebugLog('    content item id:'||l_content_item_id
                  ||' Citem version id:'||l_citem_version_id);
  END IF;

  -- IF (l_content_item_id IS NULL) THEN
  IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
    printDebugLog('    upsert content item flag:'||l_upsert_item);
  END IF;
  IF (px_attachment_rec.duplicate_flag <> 'Y')
    AND (l_upsert_item = 'Y') THEN
    l_attribute_type_codes := JTF_VARCHAR2_TABLE_100();
    l_attributes := JTF_VARCHAR2_TABLE_4000();
    l_attidx := 0;
    IF (px_attachment_rec.width IS NOT NULL) AND (px_attachment_rec.width<>0) THEN
	 l_attidx := l_attidx + 1;
      l_attribute_type_codes.extend(1);
      l_attributes.extend(1);
	 l_attribute_type_codes(l_attidx) := 'WIDTH';
	 l_attributes(l_attidx) := px_attachment_rec.width;
    IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
  	   printDebugLog('    attribute index:'||l_attidx);
  	   printDebugLog('    attribute_type_code:'||l_attribute_type_codes(l_attidx));
	   printDebugLog('    attribute_value:'||l_attributes(l_attidx));
    END IF;
    END IF;
    IF (px_attachment_rec.height IS NOT NULL) AND (px_attachment_rec.height<>0) THEN
	 l_attidx := l_attidx + 1;
	 l_attribute_type_codes.extend(1);
	 l_attributes.extend(1);
	 l_attribute_type_codes(l_attidx) := 'HEIGHT';
	 l_attributes(l_attidx) := px_attachment_rec.height;
    IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
	   printDebugLog('    attribute index:'||l_attidx);
	   printDebugLog('    attribute_type_code:'||l_attribute_type_codes(l_attidx));
	   printDebugLog('    attribute_value:'||l_attributes(l_attidx));
    END IF;
    END IF;
    IF l_attidx = 0 THEN
    IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
	   printDebugLog('    attribute type is null');
  	   printDebugLog('    attribute value is null');
    END IF;
	 l_attribute_type_codes := NULL;
	 l_attributes := NULL;
    END IF;

    IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
      printDebugLog('    Start upserting content item');
      printDebugLog('    type code:'||px_attachment_rec.content_type_code);
      printDebugLog('    name:'||px_attachment_rec.FILE_NAME);
      printDebugLog('    description:'||px_attachment_rec.FILE_NAME);
      printDebugLog('    file id:'||px_attachment_rec.file_id);
      printDebugLog('    status:'||l_status);
      printDebugLog('    language:'||px_attachment_rec.language);
      printDebugLog('    content_item_id:'||l_content_item_id);
      printDebugLog('    citem_version_id:'||l_citem_version_id);
      printDebugLog('    object_version_num:'||l_object_version_number);
    END IF;
    IBC_CITEM_ADMIN_GRP.upsert_item(
      p_ctype_code => px_attachment_rec.content_type_code,
      p_citem_name => px_attachment_rec.FILE_NAME,
      p_citem_description => px_attachment_rec.FILE_NAME,
	 p_dir_node_id => 9, -- IBE directory node
      p_reference_code => px_attachment_rec.content_item_code,
      p_trans_required => FND_API.G_FALSE,
	 p_wd_restricted => FND_API.G_FALSE,
      p_start_date => NULL,
      p_end_date => NULL,
      p_attribute_type_codes => l_attribute_type_codes,
      p_attributes => l_attributes,
      p_attach_file_id => px_attachment_rec.file_id,
      p_status => l_status,
      p_language => px_attachment_rec.language,
      p_commit => FND_API.G_FALSE,
      px_content_item_id => l_content_item_id,
      px_citem_ver_id => l_citem_version_id,
      px_object_version_number => l_object_version_number,
      x_return_status => l_return_status,
      x_msg_count => l_msg_count,
      x_msg_data => l_msg_data);
    IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
      printDebugLog('    OCM base content item creation status:'||l_return_status);
    END IF;
    IF l_return_status <> FND_API.g_ret_sts_success THEN
      IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
        printDebugLog('    Error in base content item creation:');
      END IF;
      for i in 1..l_msg_count loop
	   l_msg_data := FND_MSG_PUB.get(i,FND_API.G_FALSE);
      IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
	     printDebugLog('      '||l_msg_data);
      END IF;
      end loop;
	 x_msg_data := l_msg_data;
	 RAISE FND_API.g_exc_error;
    END IF;
    px_attachment_rec.content_item_id := l_content_item_id;
    px_attachment_rec.citem_version_id := l_citem_version_id;
    IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
      printDebugLog('    End upserting content item');
      printDebugLog('    content_item_id:'||l_content_item_id);
      printDebugLog('    citem_version_id:'||l_citem_version_id);
      printDebugLog('    object_version_num:'||l_object_version_number);
    END IF;
    IF (px_attachment_rec.start_trans <> -1) THEN
      FOR l_j IN
        px_attachment_rec.start_trans..px_attachment_rec.end_trans LOOP
        IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
          printDebugLog('    Start upserting translation of content item');
	       printDebugLog('    language:'||px_attachment_rec.language);
        END IF;
	   IBC_CITEM_ADMIN_GRP.upsert_item(
	     p_ctype_code => px_attachment_rec.content_type_code,
	     p_citem_name => l_trans_attachment_tbl(l_j).file_names,
	     p_citem_description => l_trans_attachment_tbl(l_j).FILE_NAMES,
	     p_dir_node_id => 9, -- IBE directory node
	     p_reference_code => px_attachment_rec.content_item_code,
	     p_trans_required => FND_API.G_FALSE,
	     p_wd_restricted => FND_API.G_FALSE,
	     p_start_date => NULL,
	     p_end_date => NULL,
	     p_attribute_type_codes => l_attribute_type_codes,
	     p_attributes => l_attributes,
	     p_attach_file_id => l_trans_attachment_tbl(l_j).file_ids,
	     p_status => l_status,
	     p_language => l_trans_attachment_tbl(l_j).trans_languages,
	     p_commit => FND_API.G_FALSE,
	     px_content_item_id => l_content_item_id,
	     px_citem_ver_id => l_citem_version_id,
	     px_object_version_number => l_object_version_number,
	     x_return_status => l_return_status,
	     x_msg_count => l_msg_count,
	     x_msg_data => l_msg_data);
      IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
  	     printDebugLog('    OCM translating content item status:'||l_return_status);
      END IF;
        IF l_return_status <> FND_API.g_ret_sts_success THEN
          IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
            printDebugLog('    Error in translating content item!');
          END IF;
	     for i in 1..l_msg_count loop
	       l_msg_data := FND_MSG_PUB.get(i,FND_API.G_FALSE);
          IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
	         printDebugLog('      '||l_msg_data);
          END IF;
          end loop;
	     x_msg_data := l_msg_data;
	     RAISE FND_API.g_exc_error;
        END IF;
      END LOOP;
    END IF;
  END IF;

  IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
    printDebugLog('Label association flag:'|| l_label_associate_item);
    printDebugLog('Label flag:'|| p_label_flag);
  END IF;
  IF (p_label_flag = 'Y') AND (l_label_associate_item = 'Y') THEN
    -- l_assoc_type_codes := JTF_VARCHAR2_TABLE_100();
    -- l_assoc_objects := JTF_VARCHAR2_TABLE_300();
    -- l_assoc_type_codes.extend(1);
    -- l_assoc_objects.extend(1);
    IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
      printDebugLog('Labeling starts');
      printDebugLog('p_new_content_item_id:'||l_content_item_id);
      printDebugLog('p_new_version_number:'||l_citem_version_id);
      printDebugLog('p_media_object_id:'||px_attachment_rec.item_id);
      printDebugLog('p_association_type_code:'||l_association_type);
    END IF;
    IF (l_content_item_id IS NOT NULL) AND (l_citem_version_id IS NOT NULL) THEN
      OPEN c_get_version_number(l_citem_version_id);
      FETCH c_get_version_number INTO l_version_number;
      CLOSE c_get_version_number;
      IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
        printDebugLog('p_new_version_number:'||l_version_number);
      END IF;
      IF (l_move_label = 1) THEN
	   l_old_item := l_content_item_id;
        OPEN c_get_version_number(l_old_version);
        FETCH c_get_version_number INTO l_old_ver_num;
        CLOSE c_get_version_number;
        IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
          printDebugLog('p_old_version_number:'||l_old_ver_num);
        END IF;
      ELSE
	   l_old_item := NULL;
	   l_old_ver_num := NULL;
      END IF;
      IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
        printDebugLog('Update_Label_Association Starts');
        printDebugLog('p_old_content_item_id:'||l_old_item);
        printDebugLog('p_old_version_number:'||l_old_ver_num);
        printDebugLog('p_new_content_item_id:'||l_content_item_id);
        printDebugLog('p_new_version_number:'||l_version_number);
        printDebugLog('p_media_object_id:'||px_attachment_rec.item_id);
        printDebugLog('p_association_type_code:'||l_association_type);
      END IF;
      IF (l_version_number IS NOT NULL) THEN
        IBE_M_IBC_INT_PVT.Update_Label_Association(
          p_api_version => 1.0,
	     p_init_msg_list => FND_API.G_FALSE,
  	     p_commit => FND_API.G_FALSE,
	     p_old_content_item_id => l_old_item,
	     p_old_version_number => l_old_ver_num,
	     p_new_content_item_id => l_content_item_id,
	     p_new_version_number => l_version_number,
	     p_media_object_id => px_attachment_rec.item_id,
	     p_association_type_code => l_association_type,
	     x_return_status => l_return_status,
	     x_msg_count => l_msg_count,
	     x_msg_data => l_msg_data);
        IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
          printDebugLog('    Labeling ends:'||l_return_status);
        END IF;
        IF l_return_status <> FND_API.g_ret_sts_success THEN
          IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
            printDebugLog('    Error in labeling and associating content item!');
          END IF;
	     for i in 1..l_msg_count loop
	       l_msg_data := FND_MSG_PUB.get(i,FND_API.G_FALSE);
          IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
	         printDebugLog('      '||l_msg_data);
          END IF;
          end loop;
	     x_msg_data := l_msg_data;
	     RAISE FND_API.g_exc_error;
        END IF;
	 END IF;
    END IF;
  END IF;

  IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
    printDebugLog('id:'||l_lgl_phys_map_id);
    printDebugLog('msite:'||px_attachment_rec.msite_id);
    printDebugLog('item_id:'||px_attachment_rec.item_id);
    printDebugLog('def site:'||px_attachment_rec.default_site);
    printDebugLog('content key:'||TO_CHAR(l_content_item_id));
  END IF;
  IF (l_content_item_id IS NOT NULL) AND (px_attachment_rec.item_id IS NOT NULL)
    AND (px_attachment_rec.msite_id IS NOT NULL)
    AND (px_attachment_rec.default_site IS NOT NULL) THEN
    OPEN c_check_map(px_attachment_rec.item_id,px_attachment_rec.msite_id,
        'OCM', px_attachment_rec.default_site, 'Y');
    FETCH c_check_map INTO l_j;
    IF (c_check_map%NOTFOUND) THEN
      l_j := 0;
    END IF;
    CLOSE c_check_map;
    IF (l_j = 0) THEN
      OPEN c_get_lgl_phys_map_id_csr;
      FETCH c_get_lgl_phys_map_id_csr INTO l_lgl_phys_map_id;
      CLOSE c_get_lgl_phys_map_id_csr;
      IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
        printDebugLog('id:'||l_lgl_phys_map_id);
        printDebugLog('msite:'||px_attachment_rec.msite_id);
        printDebugLog('item_id:'||px_attachment_rec.item_id);
        printDebugLog('def site:'||px_attachment_rec.default_site);
        printDebugLog('content key:'||TO_CHAR(l_content_item_id));
      END IF;
	 x_msg_data := 'Error when creating mapping';
      INSERT INTO ibe_dsp_lgl_phys_map
        (LGL_PHYS_MAP_ID,OBJECT_VERSION_NUMBER,CREATED_BY,CREATION_DATE,
         LAST_UPDATED_BY, LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,MSITE_ID,
         LANGUAGE_CODE, ATTACHMENT_ID, ITEM_ID, DEFAULT_LANGUAGE,
         DEFAULT_SITE, CONTENT_ITEM_KEY)
      VALUES
        (l_lgl_phys_map_id, 1, FND_GLOBAL.user_id, SYSDATE, FND_GLOBAL.user_id,
         SYSDATE, FND_GLOBAL.user_id, px_attachment_rec.msite_id,
         'OCM', -1, px_attachment_rec.item_id,
         'Y', px_attachment_rec.default_site, TO_CHAR(l_content_item_id));
    END IF;
  END IF;
  x_msg_data := '';
  x_return_status := FND_API.g_ret_sts_success;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO process_content_item;
    IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
      printDebugLog('    Exception in process_content_item:');
      printDebugLog('      '||SQLCODE||'-'||SQLERRM);
    END IF;
    x_return_status := FND_API.g_ret_sts_error;
END process_content_item;

PROCEDURE process_content_items(
  p_label_flag IN VARCHAR2,
  px_attachment_tbl IN OUT NOCOPY ATTACHMENT_TBL_TYPE,
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

  l_date DATE;
  l_list_flag VARCHAR2(1);
  l_item_id NUMBER;
  CURSOR c_get_content_item(c_item_ref_code VARCHAR2) IS
    SELECT content_item_id, creation_date
	 FROM ibc_content_items
     WHERE item_reference_code = c_item_ref_code;

BEGIN
  SAVEPOINT process_content_items;
  l_list_flag  := 'Y';
  x_return_status := FND_API.g_ret_sts_success;
  IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
    printDebugLog('  process_content_items begin');
  END IF;
  IF px_attachment_tbl.count > 0 THEN
    IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
      printDebugLog('    content item number='||px_attachment_tbl.count);
    END IF;
    FOR l_i IN 1..px_attachment_tbl.count LOOP
      IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
        printDebugLog('    Content item '||l_i
	                   ||' item code:'||px_attachment_tbl(l_i).content_item_code
                 	    ||' file id:'||px_attachment_tbl(l_i).file_id
	                   ||' file name:'||px_attachment_tbl(l_i).file_name);
      END IF;
	 IF (px_attachment_tbl(l_i).file_id <> -1) AND
	   (px_attachment_tbl(l_i).file_id IS NOT NULL) THEN
	   px_attachment_tbl(l_i).duplicate_flag := 'N';
      IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
  	     printDebugLog('Check duplicate');
      END IF;
	   FOR l_j IN 1..(l_i-1) LOOP
          l_duplicate := compareContentItem(l_src_att => px_attachment_tbl(l_i),
            l_tar_att => px_attachment_tbl(l_j));
		IF l_duplicate = 'Y' THEN
		  px_attachment_tbl(l_i).duplicate_flag := l_duplicate;
		  px_attachment_tbl(l_i).CONTENT_ITEM_ID
		    := px_attachment_tbl(l_j).content_item_id;
		  px_attachment_tbl(l_i).CITEM_VERSION_ID
		    := px_attachment_tbl(l_j).citem_version_id;
		  px_attachment_tbl(l_i).CONTENT_ITEM_CODE
		    := px_attachment_tbl(l_j).content_item_code;
		END IF;
	   END LOOP;
      IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
  	     printDebugLog('    Duplicate flag='
   		             || px_attachment_tbl(l_i).duplicate_flag);
      END IF;
        contentItemType(p_attachment_rec => px_attachment_tbl(l_i));
      IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
	     printDebugLog('    Content type='
               		 || px_attachment_tbl(l_i).content_type_code);
      END IF;
	   -- Check list flag
      IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
	     printDebugLog('  Check list flag');
      END IF;
	   OPEN c_get_content_item(px_attachment_tbl(l_i).CONTENT_ITEM_CODE);
	   FETCH c_get_content_item INTO l_item_id, l_date;
	   IF c_get_content_item%FOUND THEN
		IF (l_date < g_start_time) THEN
		  l_list_flag := 'N';
          END IF;
        END IF;
	   CLOSE c_get_content_item;
      IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
	     printDebugLog('    List flag='||l_list_flag);
      END IF;
        l_return_status := FND_API.g_ret_sts_success;
	   IF g_mode = 'EXECUTION' THEN
      IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
		  printDebugLog('    process_content_item start');
		  printDebugLog('    p_label_flag='||p_label_flag);
      END IF;
          process_content_item(
		  p_label_flag => p_label_flag,
            px_attachment_rec => px_attachment_tbl(l_i),
            x_return_status => l_return_status,
            x_msg_count => l_msg_count,
            x_msg_data => l_msg_data);
          IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
            printDebugLog('    process_content_item return:'||l_return_status);
          END IF;
		IF (l_return_status <> FND_API.g_ret_sts_success) THEN
        IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
          printDebugLog('    Error in processing content item');
		    printDebugLog('      '||l_msg_data);
        END IF;
		  x_msg_data := l_msg_data;
	       RAISE FND_API.g_exc_error;
		END IF;
	   END IF;
        IF (l_return_status = FND_API.g_ret_sts_success) THEN
         IF (l_list_flag = 'Y') THEN
		IF (px_attachment_tbl(l_i).duplicate_flag = 'N') THEN
		  g_item_created := g_item_created + 1;
		END IF;
		g_idx_created := g_idx_created + 1;
		MIGRATED_CONTENT(g_idx_created).access_name
		  := px_attachment_tbl(l_i).ACCESS_NAME;
		MIGRATED_CONTENT(g_idx_created).seed_flag
		  := px_attachment_tbl(l_i).SEED_DATA_FLAG;
		MIGRATED_CONTENT(g_idx_created).store_code
		  := px_attachment_tbl(l_i).STORE_CODE;
		MIGRATED_CONTENT(g_idx_created).content_item_code
		  := px_attachment_tbl(l_i).CONTENT_ITEM_CODE;
		MIGRATED_CONTENT(g_idx_created).language
		  := SUBSTR(px_attachment_tbl(l_i).LANGDESC,1,30);
		MIGRATED_CONTENT(g_idx_created).file_name
		  := px_attachment_tbl(l_i).FILE_NAME;
		IF (px_attachment_tbl(l_i).start_trans <> -1) THEN
		  FOR l_j IN px_attachment_tbl(l_i).start_trans..px_attachment_tbl(l_i).end_trans LOOP
		    g_idx_created := g_idx_created + 1;
		    MIGRATED_CONTENT(g_idx_created).access_name
			 -- := NULL;
			 := px_attachment_tbl(l_i).ACCESS_NAME;
		    MIGRATED_CONTENT(g_idx_created).seed_flag
			 -- := NULL;
			 := px_attachment_tbl(l_i).SEED_DATA_FLAG;
		    MIGRATED_CONTENT(g_idx_created).store_code
			 -- := NULL;
			 := px_attachment_tbl(l_i).STORE_CODE;
		    MIGRATED_CONTENT(g_idx_created).content_item_code
			 -- := NULL;
			 := px_attachment_tbl(l_i).CONTENT_ITEM_CODE;
		    MIGRATED_CONTENT(g_idx_created).language
			 := SUBSTR(l_trans_attachment_tbl(l_j).TRANS_LANGDESC,1,30);
              MIGRATED_CONTENT(g_idx_created).file_name
			 := l_trans_attachment_tbl(l_j).FILE_NAMES;
		  END LOOP;
		END IF;
		IF (px_attachment_tbl(l_i).duplicate_flag = 'N') THEN
		  IF px_attachment_tbl(l_i).content_type_code = g_image_type THEN
		    g_image_items := g_image_items + 1;
		  ELSIF px_attachment_tbl(l_i).content_type_code = g_media_type THEN
		    g_media_items := g_media_items + 1;
		  ELSIF px_attachment_tbl(l_i).content_type_code = g_html_type THEN
		    g_html_items := g_html_items + 1;
		  END IF;
		END IF;
          IF (px_attachment_tbl(l_i).conflict_flag = 'Y')
		  AND (px_attachment_tbl(l_i).duplicate_flag = 'N') THEN
		  g_item_conflict := g_item_conflict + 1;
		  g_idx_conflict := g_idx_conflict + 1;
		  CONFLICT_CONTENT(g_idx_conflict).access_name
		    := px_attachment_tbl(l_i).ACCESS_NAME;
		  CONFLICT_CONTENT(g_idx_conflict).seed_flag
		    := px_attachment_tbl(l_i).SEED_DATA_FLAG;
		  CONFLICT_CONTENT(g_idx_conflict).store_code
		    := px_attachment_tbl(l_i).STORE_CODE;
		  CONFLICT_CONTENT(g_idx_conflict).content_item_code
		    := px_attachment_tbl(l_i).CONTENT_ITEM_CODE;
		  CONFLICT_CONTENT(g_idx_conflict).language
		    := SUBSTR(px_attachment_tbl(l_i).LANGDESC,1,30);
		  CONFLICT_CONTENT(g_idx_conflict).file_name
		    := px_attachment_tbl(l_i).FILE_NAME;
		  IF (px_attachment_tbl(l_i).start_trans <> -1) THEN
		    FOR l_j IN px_attachment_tbl(l_i).start_trans..px_attachment_tbl(l_i).end_trans LOOP
		      g_idx_conflict := g_idx_conflict + 1;
		      CONFLICT_CONTENT(g_idx_conflict).access_name
			   -- := NULL;
		        := px_attachment_tbl(l_i).ACCESS_NAME;
		      CONFLICT_CONTENT(g_idx_conflict).seed_flag
			   -- := NULL;
		        := px_attachment_tbl(l_i).SEED_DATA_FLAG;
		      CONFLICT_CONTENT(g_idx_conflict).store_code
			   -- := NULL;
		        := px_attachment_tbl(l_i).STORE_CODE;
		      CONFLICT_CONTENT(g_idx_conflict).content_item_code
			   -- := NULL;
		        := px_attachment_tbl(l_i).CONTENT_ITEM_CODE;
		      CONFLICT_CONTENT(g_idx_conflict).language
			   := SUBSTR(l_trans_attachment_tbl(l_j).TRANS_LANGDESC,1,30);
                CONFLICT_CONTENT(g_idx_conflict).file_name
			   := l_trans_attachment_tbl(l_j).FILE_NAMES;
		    END LOOP;
		  END IF; -- translation end if
		END IF; -- conflict end if
         END IF; -- Check if the item should be list or not
	   END IF; -- end of statistics
      END IF;
    END LOOP;
    COMMIT;
  END IF;
  IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
    printDebuglog('    process_content_items end');
  END IF;
  x_msg_data := '';
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO process_content_items;
    IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
      printDebuglog('    exception in process_content_items end');
      printDebuglog('      '||SQLCODE||'-'||SQLERRM);
    END IF;
    x_return_status := FND_API.g_ret_sts_error;
END process_content_items;

PROCEDURE clean_data(x_return_status OUT NOCOPY VARCHAR2)
IS
  CURSOR c_get_date_csr(c_code VARCHAR2,
				    c_status VARCHAR2) IS
    SELECT last_update_date
	 FROM IBE_MIGRATION_HISTORY
     WHERE migration_code = c_code
	  AND status = c_status;
    CURSOR c1(l_date IN DATE) IS
        SELECT  attachment_id,object_version_number FROM jtf_amv_attachments a
        WHERE file_id IS NOT NULL
          AND application_id = 671
	    AND last_update_date < l_date
    	 AND attachment_used_by = 'ITEM'
          AND NOT EXISTS (
	       	 SELECT NULL
    		   FROM ibe_dsp_lgl_phys_map b, jtf_amv_items_b c
                WHERE a.attachment_id = b.attachment_id
		      AND b.item_id = c.item_id
		        AND c.deliverable_type_code = 'TEMPLATE');



  l_date DATE;
  l_api_version NUMBER := 1.0;
  x_msg_count NUMBER;
  x_msg_data VARCHAR2(2000);

BEGIN
  SAVEPOINT clean_data;
  OPEN c_get_date_csr('IBE_OCM_MIG','SUCCESS');
  FETCH c_get_date_csr INTO l_date;
  IF c_get_date_csr%FOUND THEN
    CLOSE c_get_date_csr;
    -- Add type checking for media mapping only
    -- Fix perf bug 2854588, sql id 5044423
    DELETE FROM ibe_dsp_lgl_phys_map a
    WHERE lgl_phys_map_id >= 10000
      AND content_item_key IS NULL
	 AND last_update_date <= l_date
	 AND attachment_id <> -1
	 AND EXISTS (
	   SELECT NULL
		FROM jtf_amv_items_b c
         WHERE a.item_id = c.item_id
		 AND c.deliverable_type_code = 'MEDIA'
		 AND c.application_id = 671);


    -- Fix bug 2854588, sql id 5044426
  FOR r1 IN c1(l_date) LOOP
       JTF_AMV_ATTACHMENT_PUB.delete_act_attachment(
            p_api_version		=> l_api_version,
            x_return_status	=> x_return_status,
            x_msg_count		=> x_msg_count,
            x_msg_data		=> x_msg_data,
            p_act_attachment_id	=>r1.attachment_id,
            p_object_version	=>r1.object_version_number);
  END LOOP;

--    DELETE FROM jtf_amv_attachments a
--    WHERE file_id IS NOT NULL
--      AND application_id = 671
--	 AND last_update_date < l_date
--	 AND attachment_used_by = 'ITEM'
--      AND NOT EXISTS (
--		 SELECT NULL
--		   FROM ibe_dsp_lgl_phys_map b, jtf_amv_items_b c
--            WHERE a.attachment_id = b.attachment_id
--		    AND b.item_id = c.item_id
--		    AND c.deliverable_type_code = 'TEMPLATE');
    COMMIT;
  ELSE
    CLOSE c_get_date_csr;
  END IF;
  x_return_status := FND_API.g_ret_sts_success;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO clean_data;
    x_return_status := FND_API.g_ret_sts_error;
END clean_data;

PROCEDURE attachment_mig(p_mode IN VARCHAR2,
  p_default_mig_lang IN VARCHAR2,
  x_status OUT NOCOPY VARCHAR2)
IS
  -- This cursor is to get installed languages
  -- in current database instance
  CURSOR c_get_installed_lang_csr IS
    SELECT language_code, description
	 FROM fnd_languages_vl
     WHERE installed_flag in ('I','B');

  -- This cursor is to get all customer media objects
  -- It is using last_updated_by instead of lgl_phys_map_id
  -- to make sure the data owner is 'SEED'.
  CURSOR c_get_item_csr IS
    select b.item_id, b.access_name
	 from jtf_amv_items_b b
     where b.deliverable_type_code <> 'TEMPLATE'
	  and b.application_id = 671
     ORDER BY b.item_id;
--  CURSOR c_get_item_csr IS
--    select b.item_id, b.access_name
--	 from jtf_amv_items_b b
--     where b.deliverable_type_code <> 'TEMPLATE'
--	  and b.application_id = 671
--       and exists (select null
--	     from ibe_dsp_lgl_phys_map a
--	    where a.item_id = b.item_id
--	      and a.last_updated_by <> 1)
--     ORDER BY b.item_id;

  -- This cursor is to get all defined msite mapping
  -- for a media object
  CURSOR c_get_item_sites_csr(c_item_id NUMBER) IS
   SELECT b.msite_id, b.msite_name, decode(b.msite_id,1,'Y','N'),
	b.default_language_code
    from ibe_msites_vl b
   where EXISTS (select NULL
                   FROM ibe_dsp_lgl_phys_map a
	             WHERE a.msite_id = b.msite_id
	               AND a.item_id = c_item_id
				   AND b.site_type = 'I'
		          AND a.content_item_key IS NULL)
  ORDER BY b.msite_id ASC;

  -- This cursor is to check if a seeded media object
  -- has default seeded mapping
  CURSOR c_get_seed_flag_csr(c_item_id NUMBER) IS
    SELECT 'Y'
	 FROM ibe_dsp_lgl_phys_map
     WHERE content_item_key IS NULL
	  AND default_site = 'Y'
	  AND item_id = c_item_id
	  AND lgl_phys_map_id < 10000;

  -- This cursor is to find all attachments defined
  -- in content repository and are not mapped to media objects
  -- yet
  -- Fix bug 2854588, sql id 5044448
  CURSOR c_get_content_repository_csr IS
    SELECT distinct file_id, file_name, display_height, display_width
	 FROM jtf_amv_attachments a
     WHERE application_id = 671
       AND file_id IS NOT NULL
	  AND attachment_used_by = 'ITEM'
	  AND NOT EXISTS (
		 SELECT NULL
		   FROM ibe_dsp_lgl_phys_map b
		  WHERE b.attachment_id = a.attachment_id);

  l_lang VARCHAR2(4);
  l_langdesc VARCHAR2(255);
  l_default_langdesc VARCHAR2(255);
  l_i NUMBER;
  l_j NUMBER;
  l_k NUMBER;
  l_index NUMBER;
  l_file_id NUMBER;
  l_file_name VARCHAR2(240);
  l_height NUMBER;
  l_width NUMBER;

  l_return_status VARCHAR2(1);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(2000);

  l_store_code VARCHAR2(240) := NULL;
  l_store_lang VARCHAR2(4);
  l_item_id NUMBER;
  l_access_name VARCHAR2(40);
  l_msite_id NUMBER;
  l_default_site VARCHAR2(3);
  l_language_code VARCHAR2(4);
  l_default_language VARCHAR2(4);
  l_translate_flag VARCHAR2(1);
BEGIN
  l_i := 0;
  OPEN c_get_installed_lang_csr;
  LOOP
    FETCH c_get_installed_lang_csr INTO l_lang, l_langdesc;
    EXIT WHEN c_get_installed_lang_csr%NOTFOUND;
    l_i := l_i + 1;
    INSTALLED_LANGUAGES(l_i) := l_lang;
    INSTALLED_LANGDESC(l_i) := l_langdesc;
    IF (l_lang = p_default_mig_lang) THEN
      l_default_langdesc := l_langdesc;
    END IF;
    IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
      printDebuglog('Installed language '||l_i||':'||l_lang);
    END IF;
  END LOOP;
  CLOSE c_get_installed_lang_csr;
  l_i := 0;
  l_k := 0;

  -- Migration will based on media objects
  OPEN c_get_item_csr;
  LOOP
    FETCH c_get_item_csr INTO l_item_id, l_access_name;
    EXIT WHEN c_get_item_csr%NOTFOUND;
    l_i := 0;
    l_k := 0;
    l_index := 0;
    l_attachment_tbl.delete;
    l_trans_attachment_tbl.delete;

    IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
      printDebuglog('Item id:'||l_item_id||' Access name:'||l_access_name);
    END IF;
    -- Find all minisites this media object linked to
    OPEN c_get_item_sites_csr(l_item_id);
    LOOP
      FETCH c_get_item_sites_csr INTO l_msite_id, l_store_code, l_default_site,
	 l_store_lang;
      EXIT WHEN c_get_item_sites_csr%NOTFOUND;
      l_i := l_i + 1;
	 l_index := l_index + 1;
    IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
  	   printDebuglog('  Msite id:'||l_msite_id||' Store code:'||l_store_code||
	     ' default site:'||l_default_site||' Store lang:'||l_store_lang);
    END IF;
      l_attachment_tbl(l_i).item_id := l_item_id;
      l_attachment_tbl(l_i).access_name := l_access_name;
      l_attachment_tbl(l_i).msite_id := l_msite_id;
      l_attachment_tbl(l_i).store_code := l_store_code;
      l_attachment_tbl(l_i).default_site := l_default_site;
	 l_attachment_tbl(l_i).seed_data_flag := 'N';
	 -- For item code validation
	 l_attachment_tbl(l_i).CONTENT_ITEM_CODE
	   := NLS_UPPER('IBEMGR_'||l_access_name||'_'||l_index);
	 IF (l_default_site = 'Y') THEN
	   l_attachment_tbl(l_i).store_code := 'ALL';
	   l_attachment_tbl(l_i).language := p_default_mig_lang;
	   -- Seeded logical item
	   IF (l_item_id < 10000) THEN
          OPEN c_get_seed_flag_csr(l_item_id);
          FETCH c_get_seed_flag_csr INTO l_attachment_tbl(l_i).seed_data_flag;
		IF (c_get_seed_flag_csr%NOTFOUND) THEN
		  l_attachment_tbl(l_i).seed_data_flag := 'N';
		END IF;
          CLOSE c_get_seed_flag_csr;
	   END IF;
	 ELSE
	   l_attachment_tbl(l_i).language := l_store_lang;
	 END IF;
    IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
  	   printDebuglog('  Seed data:'||l_attachment_tbl(l_i).seed_data_flag);
	   printDebuglog('  Before get_base_content:');
      printDebuglog('    p_item_id='||l_attachment_tbl(l_i).item_id);
      printDebuglog('    p_msite_id='||l_attachment_tbl(l_i).msite_id);
      printDebuglog('    p_default_msite='||l_attachment_tbl(l_i).default_site);
	   printDebuglog('    p_language_code='||l_attachment_tbl(l_i).language);
    END IF;
      get_base_content(p_item_id => l_attachment_tbl(l_i).item_id,
        p_msite_id => l_attachment_tbl(l_i).msite_id,
        p_default_msite => l_attachment_tbl(l_i).default_site,
        p_language_code => l_attachment_tbl(l_i).language,
        x_file_id => l_attachment_tbl(l_i).file_id,
        x_file_name => l_attachment_tbl(l_i).file_name,
        x_height => l_attachment_tbl(l_i).height,
        x_width => l_attachment_tbl(l_i).width,
        x_translate_flag => l_translate_flag);
      IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
	     printDebuglog('  After get_base_content:');
        printDebuglog('    x_file_id='||l_attachment_tbl(l_i).file_id);
        printDebuglog('    x_file_name='||l_attachment_tbl(l_i).file_name);
        printDebuglog('    x_height='||l_attachment_tbl(l_i).height);
        printDebuglog('    x_width='||l_attachment_tbl(l_i).width);
        printDebuglog('    x_translate_flag='||l_translate_flag);
      END IF;
      -- Get all mapping for this media object and the specific minisite
	 l_attachment_tbl(l_i).start_trans := -1;
	 l_attachment_tbl(l_i).end_trans := -1;
	 FOR l_j IN 1..installed_languages.COUNT LOOP
	   IF installed_languages(l_j)=l_attachment_tbl(l_i).language THEN
		l_attachment_tbl(l_i).langdesc := installed_langdesc(l_j);
	   ELSE
        IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
  	       printDebuglog('  Before get_trans_content:');
          printDebuglog('    p_item_id='||l_attachment_tbl(l_i).item_id);
          printDebuglog('    p_msite_id='||l_attachment_tbl(l_i).msite_id);
          printDebuglog('    p_default_msite='||l_attachment_tbl(l_i).default_site);
	       printDebuglog('    p_language_code='||l_attachment_tbl(l_i).language);
          printDebuglog('    p_translate_flag='||l_translate_flag);
        END IF;
          get_trans_content(p_item_id => l_attachment_tbl(l_i).item_id,
            p_msite_id => l_attachment_tbl(l_i).msite_id,
            p_default_msite => l_attachment_tbl(l_i).default_site,
            p_language_code => installed_languages(l_j),
            p_translate_flag => l_translate_flag,
            x_file_id => l_file_id,
            x_file_name => l_file_name,
            x_height => l_height,
            x_width => l_width);
          IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
            printDebuglog('  After get_trans_content:');
            printDebuglog('    x_file_id='||l_file_id);
 		      printDebuglog('    x_file_name='||l_file_name);
		      printDebuglog('    x_height='||l_height);
 		      printDebuglog('    x_width='||l_width);
          END IF;
		IF (l_file_id IS NOT NULL AND l_file_id <> -1) THEN
		  l_k := l_k + 1;
		  IF (l_attachment_tbl(l_i).start_trans = -1) THEN
		    l_attachment_tbl(l_i).start_trans := l_k;
		  END IF;
		  l_trans_attachment_tbl(l_k).TRANS_LANGUAGES
		    := installed_languages(l_j);
            l_trans_attachment_tbl(l_k).TRANS_LANGDESC
		    := installed_langdesc(l_j);
            l_trans_attachment_tbl(l_k).FILE_IDS := l_file_id;
            l_trans_attachment_tbl(l_k).FILE_NAMES := l_file_name;
            l_trans_attachment_tbl(l_k).HIGHTS := l_height;
		  l_trans_attachment_tbl(l_k).WIDTHS := l_width;
		  l_attachment_tbl(l_i).end_trans := l_k;
		END IF;
        IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
	       printDebuglog('    tran start='||l_attachment_tbl(l_i).start_trans);
	       printDebuglog('    tran end='||l_attachment_tbl(l_i).end_trans);
        END IF;
	   END IF;
      END LOOP;
    END LOOP;
    CLOSE c_get_item_sites_csr;
    IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
      printDebuglog(' Before process_content_items');
    END IF;
    process_content_items(
	 p_label_flag => 'Y',
      px_attachment_tbl => l_attachment_tbl,
      x_return_status => l_return_status,
      x_msg_count => l_msg_count,
      x_msg_data => l_msg_data);
    IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
      printDebuglog('  process_content_items return:'||l_return_status);
    END IF;
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
        printDebuglog('  exception in process_content_items');
      END IF;
      raise Fnd_Api.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END LOOP;
  CLOSE c_get_item_csr;
  -- Migrate all unused attachments in content repository
  l_i := 0;
  l_k := 0;
  l_index := 0;
  l_attachment_tbl.delete;
  l_trans_attachment_tbl.delete;
  IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
    printDebuglog('Content repository migration');
  END IF;
  OPEN c_get_content_repository_csr;
  LOOP
    FETCH c_get_content_repository_csr INTO l_file_id,l_file_name,l_height,l_width;
    EXIT WHEN c_get_content_repository_csr%NOTFOUND;
    l_i := l_i + 1;
    l_index := l_index + 1;
    l_attachment_tbl(l_i).item_id := NULL;
    l_attachment_tbl(l_i).access_name := '';
    l_attachment_tbl(l_i).msite_id := NULL;
    l_attachment_tbl(l_i).store_code := '';
    l_attachment_tbl(l_i).default_site := NULL;
    l_attachment_tbl(l_i).seed_data_flag := 'N';
    l_attachment_tbl(l_i).CONTENT_ITEM_CODE
	 := 'IBEMGR_CONTENT_REPOSITORY'||'_'||l_index;
    l_attachment_tbl(l_i).language := p_default_mig_lang;
    l_attachment_tbl(l_i).langdesc := l_default_langdesc;
    l_attachment_tbl(l_i).start_trans := -1;
    l_attachment_tbl(l_i).end_trans := -1;
    l_attachment_tbl(l_i).file_id := l_file_id;
    l_attachment_tbl(l_i).file_name := l_file_name;
    l_attachment_tbl(l_i).height := l_height;
    l_attachment_tbl(l_i).width := l_width;
  END LOOP;
  IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
    printDebuglog(' Before process_content_items for content repository');
  END IF;
  process_content_items(
    p_label_flag => 'N',
    px_attachment_tbl => l_attachment_tbl,
    x_return_status => l_return_status,
    x_msg_count => l_msg_count,
    x_msg_data => l_msg_data);
  IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
    printDebuglog(' After process_content_items for content repository:'||l_return_status);
  END IF;
  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
      printDebuglog('  exception in process_content_items for content repository:');
      printDebuglog('    '||l_msg_data);
    END IF;
    raise Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  END IF;
  IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
    printDebuglog('Content repository migration End');
  END IF;
  x_status := FND_API.g_ret_sts_success;
EXCEPTION
  WHEN OTHERS THEN
    x_status := FND_API.g_ret_sts_error||l_msg_data;
END attachment_mig;

PROCEDURE ocmMigration(errbuf OUT NOCOPY VARCHAR2,
  retcode OUT NOCOPY VARCHAR2,
  p_mode IN VARCHAR2,
  p_default_lang IN VARCHAR2,
  p_debug_flag IN VARCHAR2,
  p_clean_flag IN VARCHAR2)
IS
  l_status VARCHAR2(1);
  l_set_prof BOOLEAN;
  l_msg_data VARCHAR2(2000);
BEGIN
  IF (check_log(p_code => 'IBE_OCM_MIG',
		      p_status => 'SUCCESS') = 0) THEN
    IF (p_mode = 'EXECUTION') THEN
      create_log(p_code => 'IBE_OCM_MIG',
		       p_status => 'START',
		       x_status => l_status);
	 IF (l_status <> FND_API.G_RET_STS_SUCCESS) THEN
	   l_msg_data := 'Error when creating log file';
	   raise Fnd_Api.G_EXC_UNEXPECTED_ERROR;
	 END IF;
    END IF;
    IF p_debug_flag = 'Y' THEN
      IBE_M_MIGRATION_PVT.g_debug := p_debug_flag;
    END IF;
    g_mode := p_mode;
    g_language := p_default_lang;
    g_start_time := SYSDATE;
    IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
      printDebuglog('Parameter list:');
      printDebuglog('  p_mode = '||p_mode);
      printDebuglog('  p_default_lang = '||p_default_lang);
      printDebuglog('  p_debug_flag = '||p_debug_flag);
      printDebuglog('  p_clean_flag = '||p_clean_flag);
      printDebuglog('  g_start_time = '
	                 ||to_char(g_start_time,'DD-MON-RRRR HH24:MI:SS'));
    END IF;

    IF (p_mode = 'EXECUTION') THEN
      IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
        printDebuglog('Set IBE directory node to be hidden');
      END IF;
	 -- Ibc_Directory_Nodes_Pkg.UPDATE_ROW (
	 --  p_DIRECTORY_NODE_ID => 9 ,
	 --  p_DIRECTORY_NODE_CODE => NULL,
	 --  p_HIDDEN_FLAG  => 'Y');
	 BEGIN
	 EXECUTE IMMEDIATE 'begin Ibc_Directory_Nodes_Pkg.UPDATE_ROW '||
	   '(p_DIRECTORY_NODE_ID => 9 ,p_DIRECTORY_NODE_CODE => NULL, '||
	   'p_HIDDEN_FLAG  => ''Y''); END;';
	 END;
      IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
        printDebuglog('After setring IBE directory node to be hidden');
      END IF;
    END IF;

    -- Check all attachment files to be migrated
    -- can be recognized by the program
    IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
      printDebuglog('Check the attachment file type');
    END IF;
    attachType;
    IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
      printDebuglog('After checking the attachment file type');
    END IF;
    -- Migrate the attachments to OCM content item
    -- based on the logical items
    IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
      printDebuglog('Migrate attachment based on the mapping');
      printDebuglog('  p_mode = '||p_mode);
      printDebuglog('  p_default_mig_lang = '||p_default_lang);
    END IF;
    attachment_mig(p_mode => p_mode,
      p_default_mig_lang => p_default_lang,
      x_status => l_msg_data);
    IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
      printDebuglog('After migrating attachment:');
      printDebuglog('  status_message='||l_msg_data);
    END IF;
    l_status := substr(l_msg_data,1,length(FND_API.G_RET_STS_SUCCESS));
    IF (l_status <> FND_API.G_RET_STS_SUCCESS) THEN
      raise Fnd_Api.G_EXC_UNEXPECTED_ERROR;
    END IF;
    IF (p_mode = 'EXECUTION') THEN
    IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
  	   printDebuglog('Set the profile for iStore-OCM integration');
    END IF;
	 l_msg_data := 'Error when setting up the profile';
      -- Set the integration profile to 'Y'
	 -- l_set_prof := FND_PROFILE.save('IBE_M_USE_CONTENT_INTEGRATION','Y', 'APPL', '671');

     --bug# 3407125-setting the profile value at site level
    l_set_prof := FND_PROFILE.save('IBE_M_USE_CONTENT_INTEGRATION','Y','SITE');

     -- FND_PROFILE.put('IBE_M_USE_CONTENT_INTEGRATION', 'Y');
	 l_msg_data := '';
    IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
	   printDebuglog('After setting the profile for iStore-OCM integration');
    END IF;
    END IF;
    g_end_time := SYSDATE;
    IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
      printDebuglog('Print migration report');
    END IF;
    printReport;
    IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
      printDebuglog('After printing migration report');
    END IF;
    IF (p_mode = 'EXECUTION') THEN
      IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
        printDebuglog('Set IBE directory node to be visible');
      END IF;
	 --Ibc_Directory_Nodes_Pkg.UPDATE_ROW (
	 --  p_DIRECTORY_NODE_ID => 9 , -- This is the Folder id of iStore
	 --  p_DIRECTORY_NODE_CODE => NULL,
	 --  p_HIDDEN_FLAG  => 'N');
	 BEGIN
	 EXECUTE IMMEDIATE 'begin Ibc_Directory_Nodes_Pkg.UPDATE_ROW '||
	   '(p_DIRECTORY_NODE_ID => 9 ,p_DIRECTORY_NODE_CODE => NULL, '||
	   'p_HIDDEN_FLAG  => ''N''); END;';
	 END;
      IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
        printDebuglog('After setting IBE directory node to be visible');
      END IF;

    IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
  	   printDebuglog('Update log for migration');
    END IF;
      update_log(p_code => 'IBE_OCM_MIG',
			  p_old_status => 'START',
			  p_new_status => 'SUCCESS',
			  x_status => l_status);
      IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
        printDebuglog('After updating log for migration:'||l_status);
      END IF;
	 IF (l_status <> FND_API.G_RET_STS_SUCCESS) THEN
	   l_msg_data := 'Error when updating log file';
	   raise Fnd_Api.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;
  END IF;
  -- Insert the log into IBE_MIGRATION_HISTORY
  IF (p_clean_flag = 'Y') THEN
    IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
      printDebuglog('Clean old data');
    END IF;
    clean_data(x_return_status => l_status);
    IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
      printDebuglog('After cleaning old data:'||l_status);
    END IF;
    IF (l_status <> FND_API.g_ret_sts_success) THEN
	 l_msg_data := 'Error when cleaning old data';
      raise Fnd_Api.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;
  retcode := 0;
  errbuf := 'SUCCESS';
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    IF (p_mode = 'EXECUTION') THEN
      IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
        printDebuglog('Exception occurs, need to set the folder visible!');
        printDebuglog('Set IBE directory node to be visible');
      END IF;
	 --Ibc_Directory_Nodes_Pkg.UPDATE_ROW (
	 --  p_DIRECTORY_NODE_ID => 9 , -- This is the Folder id of iStore
	 --  p_DIRECTORY_NODE_CODE => NULL,
	 --  p_HIDDEN_FLAG  => 'N');
	 BEGIN
	 EXECUTE IMMEDIATE 'begin Ibc_Directory_Nodes_Pkg.UPDATE_ROW '||
	   '(p_DIRECTORY_NODE_ID => 9 ,p_DIRECTORY_NODE_CODE => NULL, '||
	   'p_HIDDEN_FLAG  => ''N''); END;';
	 COMMIT;
	 END;
      IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
        printDebuglog('After setting IBE directory node to be visible');
      END IF;
    END IF;
    printOutput(l_msg_data||' '||SQLCODE||'-'||SQLERRM);
    IF IBE_M_MIGRATION_PVT.g_debug = 'Y' THEN
      printDebuglog(l_msg_data||' '||SQLCODE||'-'||SQLERRM);
    END IF;
    retcode := -1;
    errbuf := l_msg_data||' '||SQLCODE||'-'||SQLERRM;
END ocmMigration;

END IBE_M_MIGRATION_PVT;

/
