--------------------------------------------------------
--  DDL for Package Body FND_ATTACHMENT_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_ATTACHMENT_UTIL_PKG" as
/* $Header: AFAKUTLB.pls 120.2.12010000.8 2021/02/26 21:31:05 ctilley ship $ */

inconsistent_datatypes EXCEPTION;
PRAGMA EXCEPTION_INIT(inconsistent_datatypes, -932);

 FUNCTION get_atchmt_exists(l_entity_name VARCHAR2,
                   l_pkey1         VARCHAR2,
                   l_pkey2         VARCHAR2 DEFAULT NULL,
                   l_pkey3         VARCHAR2 DEFAULT NULL,
                   l_pkey4         VARCHAR2 DEFAULT NULL,
                   l_pkey5         VARCHAR2 DEFAULT NULL,
		   l_function_name VARCHAR2 DEFAULT NULL,
		   l_function_type VARCHAR2 DEFAULT NULL)
 RETURN VARCHAR2 IS
   l_exists VARCHAR2(1);
   l2_function_name VARCHAR2(30);
   l2_function_type VARCHAR2(1);
 BEGIN
 --  if the function name is not passed in, try using the server-side
 --  package global
 IF (l_function_name IS NULL) THEN
	l2_function_name := FND_ATTACHMENT_UTIL_PKG.function_name;
 ELSE
	l2_function_name := l_function_name;
 END IF;

 IF (l_function_type IS NULL) THEN
	l2_function_type := FND_ATTACHMENT_UTIL_PKG.function_type;
  ELSE
	l2_function_type := l_function_type;
  END IF;

IF (l_pkey2 is not null) and (l_pkey3 is not null) then

  SELECT 'Y'
       INTO l_exists
       FROM  fnd_doc_category_usages fdcu,
                fnd_documents fd,
           	fnd_attachment_functions af,
           	fnd_attached_documents fad
          WHERE fad.entity_name = l_entity_name
	    AND fad.pk1_value = l_pkey1
	    AND fad.pk2_value = l_pkey2
     	    AND fad.pk3_value = l_pkey3
	    AND (l_pkey4 IS NULL
		   OR fad.pk4_value = l_pkey4)
	    AND (l_pkey5 IS NULL
		   OR fad.pk5_value = l_pkey5)
            AND fad.document_id = fd.document_id
            AND fd.category_id = fdcu.category_id
            AND fdcu.attachment_function_id = af.attachment_function_id
	    AND fdcu.enabled_flag = 'Y'
 	    and exists (select 'x' from fnd_attachment_functions af
                  where af.function_type = l2_function_type
                  AND af.function_name = l2_function_name
                  AND fdcu.attachment_function_id = af.attachment_function_id)
            AND ROWNUM = 1;

   ELSE IF (l_pkey2 is not null) then

     SELECT  'Y'
       INTO l_exists
       FROM  fnd_doc_category_usages fdcu,
                fnd_documents fd,
                fnd_attached_documents fad,
           	fnd_attachment_functions af
          WHERE fad.entity_name = l_entity_name
	    AND fad.pk1_value = l_pkey1
	    AND fad.pk2_value = l_pkey2
     	    AND (l_pkey3 IS NULL
     	           OR fad.pk3_value = l_pkey3)
	    AND (l_pkey4 IS NULL
		   OR fad.pk4_value = l_pkey4)
	    AND (l_pkey5 IS NULL
		   OR fad.pk5_value = l_pkey5)
            AND fad.document_id = fd.document_id
            AND fd.category_id = fdcu.category_id
            AND fdcu.attachment_function_id = af.attachment_function_id
	    AND fdcu.enabled_flag = 'Y'
            and exists (select 'x' from fnd_attachment_functions af
                  where af.function_type = l2_function_type
                  AND af.function_name = l2_function_name
                  AND fdcu.attachment_function_id = af.attachment_function_id)
            AND ROWNUM = 1;

   ELSE

      SELECT 'Y'
       INTO l_exists
       FROM  fnd_doc_category_usages fdcu,
                fnd_documents fd,
                fnd_attached_documents fad,
                fnd_attachment_functions af
          WHERE fad.entity_name = l_entity_name
	    AND fad.pk1_value = l_pkey1
	    AND (l_pkey2 IS NULL
	           OR fad.pk2_value = l_pkey2)
     	    AND (l_pkey3 IS NULL
     	           OR fad.pk3_value = l_pkey3)
	    AND (l_pkey4 IS NULL
		   OR fad.pk4_value = l_pkey4)
	    AND (l_pkey5 IS NULL
		   OR fad.pk5_value = l_pkey5)
            AND fad.document_id = fd.document_id
            AND fd.category_id = fdcu.category_id
            AND fdcu.attachment_function_id = af.attachment_function_id
	    AND fdcu.enabled_flag = 'Y'
            and exists (select 'x' from fnd_attachment_functions af
                  where af.function_type = l2_function_type
                  AND af.function_name = l2_function_name
                  AND fdcu.attachment_function_id = af.attachment_function_id)
            AND ROWNUM = 1;
    END IF;
END IF;

 IF (l_exists<>'Y') THEN
   return('N');
 ELSE
   return('Y');
 END IF;

  EXCEPTION
    WHEN OTHERS THEN
     return('N');

 END get_atchmt_exists;


 FUNCTION get_atchmt_exists_sql(l_entity_name VARCHAR2,
                   l_pkey1         VARCHAR2,
                   l_pkey2         VARCHAR2 DEFAULT NULL,
                   l_pkey3         VARCHAR2 DEFAULT NULL,
                   l_pkey4         VARCHAR2 DEFAULT NULL,
                   l_pkey5         VARCHAR2 DEFAULT NULL,
		   l_sqlstmt       VARCHAR2 DEFAULT NULL,
		   l_function_name VARCHAR2 DEFAULT NULL,
		   l_function_type VARCHAR2 DEFAULT NULL)
 RETURN VARCHAR2 IS
   l_exists VARCHAR2(1);
   l2_function_name VARCHAR2(30);
   l2_function_type VARCHAR2(1);
   l_cursor INTEGER;
   l_rows_processed INTEGER;
   l_exists_flag VARCHAR2(1);
   l_sql_stmt VARCHAR2(2000);
 BEGIN
 --  if the function name is not passed in, try using the server-side
 --  package global
 IF (l_function_name IS NULL) THEN
	l2_function_name := FND_ATTACHMENT_UTIL_PKG.function_name;
 ELSE
	l2_function_name := l_function_name;
 END IF;

 IF (l_function_type IS NULL) THEN
	l2_function_type := FND_ATTACHMENT_UTIL_PKG.function_type;
 ELSE
	l2_function_type := l_function_type;
 END IF;


  l_sql_stmt := 'SELECT ''Y'' FROM dual WHERE EXISTS ('||
      'SELECT 1 FROM fnd_attached_documents fad,'||
                  'fnd_doc_category_usages fdcu,'||
                  'fnd_attachment_functions af,'||
                  'fnd_documents fd '||
            'WHERE fad.entity_name = :ename '||
              'AND fad.document_id = fd.document_id '||
              'AND fd.category_id = fdcu.category_id '||
              'AND fdcu.attachment_function_id = af.attachment_function_id '||
              'AND fdcu.enabled_flag = ''Y'' '||
              'AND af.function_type = :function_type '||
              'AND af.function_name = :function_name ';

  --  include primary keys only if not null
  IF (l_pkey1 IS NOT NULL) THEN
    l_sql_stmt := l_sql_stmt|| 'AND fad.pk1_value = :pkey1 ';
  END IF;

  IF (l_pkey2 IS NOT NULL) THEN
    l_sql_stmt := l_sql_stmt|| 'AND fad.pk2_value = :pkey2 ';
  END IF;

  IF (l_pkey3 IS NOT NULL) THEN
    l_sql_stmt := l_sql_stmt|| 'AND fad.pk3_value = :pkey3 ';
  END IF;

  IF (l_pkey4 IS NOT NULL) THEN
    l_sql_stmt := l_sql_stmt|| 'AND fad.pk4_value = :pkey4 ';
  END IF;

  IF (l_pkey5 IS NOT NULL) THEN
    l_sql_stmt := l_sql_stmt|| 'AND fad.pk5_value = :pkey5 ';
  END IF;

 --  open the cursor
 l_cursor := dbms_sql.open_cursor;
 --  parse the sql
 dbms_sql.parse(l_cursor, l_sql_stmt||' '||l_sqlstmt||')',
		dbms_sql.v7);

  --  define the column
  dbms_sql.define_column(l_cursor, 1, l_exists_flag, 1);

  -- bind variables
  dbms_sql.bind_variable(l_cursor, ':ename', l_entity_name);
  dbms_sql.bind_variable(l_cursor, ':function_type', l2_function_type);
  dbms_sql.bind_variable(l_cursor, ':function_name', l2_function_name);

    IF (l_pkey1 IS NOT NULL) THEN
      dbms_sql.bind_variable(l_cursor, ':pkey1', l_pkey1);
   END IF;

   IF (l_pkey2 IS NOT NULL) THEN
      dbms_sql.bind_variable(l_cursor, ':pkey2', l_pkey2);
   END IF;

   IF (l_pkey3 IS NOT NULL) THEN
      dbms_sql.bind_variable(l_cursor, ':pkey3', l_pkey3);
   END IF;

   IF (l_pkey4 IS NOT NULL) THEN
      dbms_sql.bind_variable(l_cursor, ':pkey4', l_pkey4);
   END IF;

   IF (l_pkey5 IS NOT NULL) THEN
      dbms_sql.bind_variable(l_cursor, ':pkey5', l_pkey5);
   END IF;


   l_rows_processed := dbms_sql.execute_and_fetch(l_cursor);
   dbms_sql.column_value(l_cursor,1,l_exists_flag);
   dbms_sql.close_cursor(l_cursor);

   IF (l_exists_Flag = 'Y') THEN
     return('Y');
   ELSE
     return('N');
   END IF;


  EXCEPTION
    WHEN OTHERS THEN
       dbms_sql.close_cursor(l_cursor);
       return('N');

 END get_atchmt_exists_sql;


PROCEDURE init_atchmt(l_function_name IN OUT NOCOPY VARCHAR2,
	       attachments_defined_flag OUT NOCOPY BOOLEAN,
		l_function_type IN OUT NOCOPY VARCHAR2) IS
  m_function_name VARCHAR2(40);
  m_rowcount NUMBER;
BEGIN


  --  get attachment definition tied to function
  SELECT count(*)
    INTO m_rowcount
    FROM fnd_attachment_functions
   WHERE function_name = l_function_name
     AND function_type = 'F';

  IF (m_rowcount > 0) THEN
	l_function_name := l_function_name;
	attachments_defined_Flag := TRUE;
	l_function_type := 'F';
	--  set package global
	FND_ATTACHMENT_UTIL_PKG.function_name := l_function_name;
	FND_ATTACHMENT_UTIL_PKG.function_type := l_function_type;
	return;
  ELSE
	--  get attachment definition tied to form
	SELECT function_name,
	       count(*)
          INTO m_function_name,
               m_rowcount
          FROM fnd_attachment_functions
         WHERE function_type = 'O'
           AND (function_name, application_id) =
		(SELECT distinct ff.form_name, ff.application_id
		   FROM fnd_form ff,
                        fnd_form_functions fff
                  WHERE ff.application_id = fff.application_id
		    AND ff.form_id = fff.form_id
		   AND fff.function_name = l_function_name)
         GROUP BY function_name;

	IF (m_rowcount > 0) THEN
		l_function_name := m_function_name;
		attachments_defined_Flag := TRUE;
		l_function_type := 'O';
		--  set package global
		FND_ATTACHMENT_UTIL_PKG.function_name := l_function_name;
                FND_ATTACHMENT_UTIL_PKG.function_type := l_function_type;
		return;
	END IF;
  END IF;

  --  neither check got any attachment definition, so
  --  return FALSE
  	attachments_defined_flag := FALSE;
	FND_ATTACHMENT_UTIL_PKG.function_name := null;
	FND_ATTACHMENT_UTIL_PKG.function_type := null;


 EXCEPTION
   WHEN OTHERS THEN
      attachments_defined_flag := FALSE;
	FND_ATTACHMENT_UTIL_PKG.function_name := null;
	FND_ATTACHMENT_UTIL_PKG.function_type := null;

END init_atchmt;

PROCEDURE init_atchmt(l_function_name IN OUT NOCOPY VARCHAR2,
	       attachments_defined_flag OUT NOCOPY BOOLEAN,
		l_enabled_flag OUT NOCOPY VARCHAR2,
		l_session_context_field OUT NOCOPY VARCHAR2,
		l_function_type OUT NOCOPY VARCHAR2) IS
  m_function_name VARCHAR2(40);
  m_enabled_flag VARCHAR2(1);
  m_session_context_field VARCHAR2(61);
BEGIN

 BEGIN
    --  get attachment definition tied to function
    SELECT enabled_flag,session_context_field
      INTO m_enabled_flag,m_session_context_field
      FROM fnd_attachment_functions
     WHERE function_name = l_function_name
       AND function_type = 'F';

    IF (m_enabled_flag = 'Y') THEN
	l_function_name := l_function_name;
	attachments_defined_Flag := TRUE;
	l_enabled_flag := m_enabled_flag;
	l_session_context_field := m_session_context_field;
	l_function_type := 'F';
	--  set package global
	FND_ATTACHMENT_UTIL_PKG.function_name := l_function_name;
	FND_ATTACHMENT_UTIL_PKG.function_type := 'F';
	return;
    ELSIF (m_enabled_flag = 'N') THEN
	l_function_name := l_function_name;
 	attachments_defined_flag := FALSE;
	l_enabled_flag := m_enabled_flag;
	l_session_context_field := m_session_context_field;
	l_function_type := 'F';
	return;
    END IF;
 EXCEPTION
	WHEN NO_DATA_FOUND THEN null;
	WHEN OTHERS THEN RAISE;
 END;


	--  get attachment definition tied to form
  SELECT function_name,
         enabled_flag,
         session_context_field
    INTO m_function_name,
         m_enabled_flag,
         m_session_context_field
    FROM fnd_attachment_functions
   WHERE function_type = 'O'
     AND (function_name, application_id) =
	 (SELECT distinct ff.form_name, ff.application_id
	    FROM fnd_form ff,
                 fnd_form_functions fff
           WHERE ff.application_id = fff.application_id
	     AND ff.form_id = fff.form_id
	     AND fff.function_name = l_function_name);

  IF ( m_enabled_flag = 'Y') THEN
	l_function_name := m_function_name;
	attachments_defined_Flag := TRUE;
	l_enabled_flag := m_enabled_flag;
	l_session_context_field := m_session_context_field;
	l_function_type := 'O';
	--  set package global
	FND_ATTACHMENT_UTIL_PKG.function_name := l_function_name;
	FND_ATTACHMENT_UTIL_PKG.function_type := 'O';
	return;
  ELSIF (m_enabled_flag = 'N' ) THEN
	l_function_name := l_function_name;
 	attachments_defined_flag := FALSE;
	l_enabled_flag := m_enabled_flag;
	l_session_context_field := m_session_context_field;
	l_function_type := 'F';
	FND_ATTACHMENT_UTIL_PKG.function_name := l_function_name;
	FND_ATTACHMENT_UTIL_PKG.function_type := 'O';
	return;
  END IF;

  --  neither check got any attachment definition, so
  --  return FALSE
  attachments_defined_flag := FALSE;
  FND_ATTACHMENT_UTIL_PKG.function_name := null;
  FND_ATTACHMENT_UTIL_PKG.function_type := null;

  EXCEPTION
   WHEN NO_DATA_FOUND THEN
  	attachments_defined_flag := FALSE;
 	FND_ATTACHMENT_UTIL_PKG.function_name := null;
  	FND_ATTACHMENT_UTIL_PKG.function_type := null;

   WHEN OTHERS THEN
	attachments_defined_flag := FALSE;
	FND_ATTACHMENT_UTIL_PKG.function_name := null;
	FND_ATTACHMENT_UTIL_PKG.function_type := null;

END init_atchmt;

PROCEDURE init_form(X_entity_name IN VARCHAR2,
                    X_user_entity_name OUT NOCOPY VARCHAR2,
	           X_doc_type_meaning OUT NOCOPY VARCHAR2) IS
 CURSOR c1 IS
	SELECT meaning
   	  FROM fnd_lookup_values
	 WHERE lookup_type = 'ATCHMT_DOCUMENT_TYPE'
	   AND lookup_code = 'O';

 CURSOR c2 IS
	SELECT user_entity_name
	  FROM fnd_document_entities_vl
	 WHERE data_object_code = X_entity_name;
BEGIN

 OPEN c1;
 FETCH c1 INTO X_doc_type_meaning;
 CLOSE c1;


 IF (X_entity_name IS NOT NULL) THEN
	 OPEN c2;
	 FETCH c2 INTO X_user_entity_name;
	 CLOSE c2;
 END IF;

 EXCEPTION
	WHEN NO_DATA_FOUND THEN return;


END init_form;



PROCEDURE init_doc_form(X_category_name IN VARCHAR2 DEFAULT NULL,
			X_category_id  OUT NOCOPY NUMBER,
			X_category_desc  OUT NOCOPY VARCHAR2,
			X_security_type IN NUMBER DEFAULT NULL,
			X_security_id IN NUMBER DEFAULT NULL,
			X_security_desc OUT NOCOPY VARCHAR2) IS
 CURSOR c1 IS
	SELECT category_id, user_name
	 FROM fnd_document_categories_vl
	WHERE name = X_category_name;

 l_cursor INTEGER;
 rows_processed INTEGER;
 l_security_desc VARCHAR2(255);

BEGIN
	--  Get category info
	IF (X_category_name IS NOT NULL) THEN
		OPEN c1;
		FETCH c1 INTO X_category_id, X_category_desc;
		CLOSE c1;
	END IF;

	--  get set of books description if security type = 2
	IF (X_security_type = 2) THEN
		--  user dynamic sql as AOL may not have reference to
		--  sets of books
		l_cursor := dbms_sql.open_cursor;
		--  parse the statement
		dbms_sql.parse(l_cursor,
			'SELECT short_name FROM gl_sets_of_books '||
			'WHERE set_of_books_id = :sob_id', dbms_sql.v7);
		--  define the column
		dbms_sql.define_column(l_cursor, 1, l_security_desc, 20);
		--  bind variable
		dbms_sql.bind_variable(l_cursor, ':sob_id', X_security_id);

		rows_processed := dbms_sql.execute_and_fetch(l_cursor);
		dbms_sql.column_value(l_cursor,1,l_security_desc);
		dbms_sql.close_cursor(l_cursor);
		X_security_desc := l_security_desc;

	END IF;

END init_doc_form;


FUNCTION get_atchmt_function_name RETURN VARCHAR2 IS
BEGIN
--  return the value in the package global
  RETURN(FND_ATTACHMENT_UTIL_PKG.function_name);
END get_atchmt_function_name;


FUNCTION get_user_function_name(x_function_type IN VARCHAR2,
			   x_application_id IN NUMBER,
		           x_function_name IN VARCHAR2) RETURN VARCHAR2 IS
  CURSOR get_form IS
	SELECT user_form_name
          FROM fnd_form_vl
	WHERE form_name = x_function_name
          AND application_id = x_application_id;

  CURSOR get_function IS
	SELECT user_function_name
	  FROM fnd_form_functions_vl
	 WHERE function_name = x_function_name;

  CURSOR get_report IS
	SELECT user_concurrent_program_name
          FROM fnd_concurrent_programs_vl
	WHERE application_id = x_application_id
          AND concurrent_program_name = x_function_name;

  l_function_name VARCHAR2(255);
BEGIN
  IF (x_function_type = 'F') THEN
	--  get function name
	OPEN get_function;
	FETCH get_function INTO l_function_name;
	CLOSE get_function;
	RETURN(l_function_name);


  ELSIF (x_function_type = 'O') THEN
	-- get form name
	OPEN get_form;
	FETCH get_form INTO l_function_name;
	CLOSE get_form;
	RETURN(l_function_name);

  ELSIF (x_function_type = 'R') THEN
	--  get concurrent program name
	OPEN get_report;
	FETCH get_report INTO l_function_name;
	CLOSE get_report;
	RETURN(l_function_name);
  ELSE
	RETURN('INVALID_FUNCTION');
  END IF;


END get_user_function_name;

PROCEDURE update_file_metadata(X_file_id IN NUMBER DEFAULT NULL) IS

  l_file_name		varchar2(255);
  l_file_name_lob	varchar2(255);
  l_file_name_tl	varchar2(255);
  l_content_type        varchar2(255);
  l_document_id         number := 0;
  l_language		varchar2(16);
  beg_file_loc          number := 1;
--  ctx_format          varchar2(20);

BEGIN

  -- get file name and language.
  select file_name,language
    into l_file_name_lob, l_language
    from fnd_lobs
  where file_id = update_file_metadata.X_file_id ;

  -- Parse the file name to get rid of the directory
--  l_file_name := substr(l_file_name_lob,instr(l_file_name_lob,'A',-1)); Original code
LOOP
  if (upper(substr(l_file_name_lob,instr(l_file_name_lob,'.',-1)-beg_file_loc,1)) between 'A' and 'Z'
     or
     substr(l_file_name_lob,instr(l_file_name_lob,'.',-1)-beg_file_loc,1) between '0' and '9')
     then
     beg_file_loc := beg_file_loc+1;
  else
     l_file_name := substr(l_file_name_lob,instr(l_file_name_lob,'.',-1)-beg_file_loc+1);
     exit;
  end if;
END LOOP;

  -- Get file name from fnd_documents_tl
  -- BUG#1560000 Added language = l_language to select statement
  select document_id,file_name
    into l_document_id,l_file_name_tl
    from fnd_documents
   where file_name like '%'||l_file_name ||'%';

  -- Extract content type from file name.
  l_content_type := substr (l_file_name_tl,instr(l_file_name_tl, ':') + 1 );

  -- Update fnd_document_tl
  update fnd_documents
     set  file_name = l_file_name,
	  media_id  = update_file_metadata.X_file_id
   where  document_id = l_document_id;

  -- Update fnd_lobs
  update fnd_lobs
     set file_content_type = l_content_type,
         program_name = 'FNDATTCH',
         file_format = fnd_gfm.set_file_format(l_content_type)
   where file_id = X_file_id;

EXCEPTION
    when NO_DATA_FOUND then
      fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
      fnd_message.set_token('ROUTINE','File ID: '||
				update_file_metadata.X_file_id);
      fnd_message.set_token('ERRNO', SQLCODE);
      fnd_message.set_token('REASON', SQLERRM);
      RAISE;

END update_file_metadata;

----------------------------------------------------------------------------
-- MergeAttachments (PUBLIC)
--   This is the procedure being called during the Party Merge.
--   FND_ATTACHMENT_UTIL_PKG.MergeAttachments() has been registered
--   in Party Merge Data Dict.
--   The input/output arguments format matches the document PartyMergeDD.doc.
--
-- Usage example in pl/sql
--   This procedure should only be called from the PartyMerge utility.
--
procedure MergeAttachments(p_entity_name in varchar2,
                        p_from_id in number,
                        p_to_id in out nocopy number,
                        p_from_fk_id in varchar2,
                        p_to_fk_id in varchar2,
                        p_parent_entity_name in varchar2,
                        p_batch_id in number,
                        p_batch_party_id in number,
                        p_return_status in out nocopy varchar2) is
  pen      varchar2(100);
begin
  p_return_status := FND_API.G_RET_STS_SUCCESS;

  if p_parent_entity_name is NULL then
    pen := 'HZ_PARTIES';
  else
    pen := p_parent_entity_name;
  end if;

  if (p_from_fk_id <> p_to_fk_id) then

    update fnd_attached_documents
    set pk1_value = p_to_fk_id
    where pk1_value = p_from_fk_id
    and entity_name = pen;
-- For Bulk processing this condition has been removed.  Updated ldt to include
-- bulk flag = 'Y'
--    and attached_document_id = p_from_id;

    p_to_id := p_from_id;

  end if;

end MergeAttachments;

PROCEDURE MergeCustAttach (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2) IS

  TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
       RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
       INDEX BY BINARY_INTEGER;
  MERGE_HEADER_ID_LIST MERGE_HEADER_ID_LIST_TYPE;

  TYPE PK1_VALUE_LIST_TYPE IS TABLE OF
         FND_ATTACHED_DOCUMENTS.PK1_VALUE%TYPE
        INDEX BY BINARY_INTEGER;
  NUM_COL1_ORIG_LIST PK1_VALUE_LIST_TYPE;
  NUM_COL1_NEW_LIST PK1_VALUE_LIST_TYPE;

  l_profile_val VARCHAR2(30);
  CURSOR merged_records IS
        SELECT distinct CUSTOMER_MERGE_HEADER_ID
              ,PK1_VALUE
         FROM FND_ATTACHED_DOCUMENTS yt, ra_customer_merges m
         WHERE (
            yt.PK1_VALUE = m.DUPLICATE_ID
           AND yt.entity_name = 'AR_CUSTOMERS'
         ) AND    m.process_flag = 'N'
         AND    m.request_id = req_id
         AND    m.set_number = set_num;
  l_last_fetch BOOLEAN := FALSE;
  l_count NUMBER;
BEGIN
  IF process_mode='LOCK' THEN
    NULL;
  ELSE
    ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
    ARP_MESSAGE.SET_TOKEN('TABLE_NAME','FND_ATTACHED_DOCUMENTS',FALSE);
    HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
    l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

    open merged_records;

   LOOP
      FETCH merged_records BULK COLLECT INTO
         MERGE_HEADER_ID_LIST
          , NUM_COL1_ORIG_LIST
          ;
      IF merged_records%NOTFOUND THEN
         l_last_fetch := TRUE;
      END IF;
      IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
        exit;
      END IF;
      FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
         NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));
      END LOOP;
      IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
        FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
         INSERT INTO HZ_CUSTOMER_MERGE_LOG (
           MERGE_LOG_ID,
           TABLE_NAME,
           MERGE_HEADER_ID,
           NUM_COL1_ORIG,
           NUM_COL1_NEW,
           ACTION_FLAG,
           REQUEST_ID,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATE_LOGIN,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY
      ) VALUES (         HZ_CUSTOMER_MERGE_LOG_s.nextval,
         'FND_ATTACHED_DOCUMENTS',
         MERGE_HEADER_ID_LIST(I),
         NUM_COL1_ORIG_LIST(I),
         NUM_COL1_NEW_LIST(I),
         'U',
         req_id,
         hz_utility_pub.CREATED_BY,
         hz_utility_pub.CREATION_DATE,
         hz_utility_pub.LAST_UPDATE_LOGIN,
         hz_utility_pub.LAST_UPDATE_DATE,
         hz_utility_pub.LAST_UPDATED_BY
      );
   END IF;

      FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
      UPDATE FND_ATTACHED_DOCUMENTS yt SET
           PK1_VALUE=NUM_COL1_NEW_LIST(I)
          , SEQ_NUM = seq_num+1
          , LAST_UPDATE_DATE=SYSDATE
          , last_updated_by=arp_standard.profile.user_id
          , last_update_login=arp_standard.profile.last_update_login
          , REQUEST_ID=req_id
          , PROGRAM_APPLICATION_ID=arp_standard.profile.program_application_id
          , PROGRAM_ID=arp_standard.profile.program_id
          , PROGRAM_UPDATE_DATE=SYSDATE
       WHERE yt.entity_name = 'AR_CUSTOMERS'
       AND   yt.pk1_value = NUM_COL1_ORIG_LIST(I)
         ;
      l_count := l_count + SQL%ROWCOUNT;
      IF l_last_fetch THEN
         EXIT;
      END IF;
    END LOOP;

    arp_message.set_name('AR','AR_ROWS_UPDATED');
    arp_message.set_token('NUM_ROWS',to_char(l_count));
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    arp_message.set_line( 'MergeCustAttach');
    RAISE;
END MergeCustAttach;

FUNCTION get_attachment_doc_length(x_document_id number)
RETURN NUMBER IS

l_length number;
l_long_txt LONG;
l_datatype_id number;
l_media_id number;
l_stmt varchar2(200);
c pls_integer;
res pls_integer;

BEGIN
 -- Retrieve the datatype and media id to determine the type of document and doc source
 select datatype_id, media_id
 into l_datatype_id, l_media_id
 from fnd_documents
 where document_id = x_document_id;

 if (l_datatype_id = 1) then
    -- Short text length
    select nvl(length(short_text),0) into l_length from fnd_documents_short_text where media_id = l_media_id;
 elsif (l_datatype_id = 2) then
   -- Using dbms_sql for successful compilation when the datatype is still LONG (changed to CLOB in 12.2)
   begin
       l_stmt := 'select nvl(length(long_text),0) from fnd_documents_long_text where media_id = :x_media_id';
       c := dbms_sql.open_cursor;
       dbms_sql.parse(c,l_stmt,dbms_sql.NATIVE);
       dbms_sql.bind_variable(c,':x_media_id',l_media_id);
       dbms_sql.define_column(c,1,l_length);
       res := dbms_sql.execute_and_fetch(c);
       dbms_sql.column_value(c,1,l_length);
       dbms_sql.close_cursor(c);

   exception when inconsistent_datatypes then
       -- For when ORA-932 occurs
       select long_text into l_long_txt
       from fnd_documents_long_text i
       where media_id = l_media_id;

       l_length := nvl(length(l_long_txt),0);
   end;

 elsif (l_datatype_id = 5) then
    -- Web type document
    select nvl(length(url),0) into l_length from fnd_documents where document_id = x_document_id;
 elsif (l_datatype_id = 6) then
    -- File type
    select nvl(length(file_data),0) into l_length from fnd_lobs where file_id = l_media_id;
 else
   -- Default
    l_length := 0;
 end if;

    return l_length;

EXCEPTION when others then
    fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
    fnd_message.set_token('ERRNO', SQLCODE);
    fnd_message.set_token('REASON', SQLERRM);
    RAISE;
END get_attachment_doc_length;


-- Determine if URL is secure (ref SecureHttpRequest.isSecureUrl)
-- Returns:
-- Y - secure url
-- N - potentially unsecure
--
FUNCTION isSecureUrl(x_url varchar2)
    RETURN varchar2 IS

l_module_source varchar2(80) := 'FND_ATTACHMENT_UTIL_PKG.isSecureUrl';
l_url varchar2(300);
l_url_base varchar2(300);
l_web_agent varchar2(300);
l_web_agent_base varchar2(300);
l_servlet_agent varchar2(300);
l_servlet_agent_base varchar2(300);
l_framework_agent varchar2(300);
l_framework_agent_base varchar2(300);
l_apps_portal varchar2(300);
l_apps_portal_base varchar(300);
BEGIN
  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,'Begin - url is: '||x_url);
  end if;

   l_url := lower(x_url);

   -- Check for Invalid chars
   if (instr(l_url,'%0a') > 0 or instr(l_url,'/n') > 0 or instr(l_url,'%0d') > 0  or instr(l_url,'/r') > 0 ) then
       if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
           fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,'invalid char found - return N' );
       end if;
       return 'N';
   end if;

   -- Check relative/local url
   if (substr(l_url,1,1) = '/' and length(l_url)>1) then
       if (substr(l_url,2,1) >= 'a' AND substr(l_url,2,1) <= 'z') then
           return 'Y';
       else
          if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
              fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,'invalid relative url' );
          end if;
          return 'N';
       end if;
   end if;

   l_url_base := substr(REGEXP_REPLACE(l_url, '^http[s]?://(www\.)?|^www\.', '', 1),1,instr(REGEXP_REPLACE(l_url, '^http[s]?://(www\.)?|^www\.', '', 1), '/',1)-1);

   if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
       fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,'url base: '||l_url_base||' from url: '||l_url);
   end if;

   -- Get web agent
   l_web_agent := fnd_profile.value('APPS_WEB_AGENT');
   if (l_web_agent is not null) then
       l_web_agent_base := lower(substr(REGEXP_REPLACE(l_web_agent, '^http[s]?://(www\.)?|^www\.', '', 1),1,instr(REGEXP_REPLACE(l_web_agent, '^http[s]?://(www\.)?|^www\.', '', 1), '/',1)-1));

       if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
           fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,'Web Agent is:'||l_web_agent||' base: '||l_web_agent_base);
       end if;
   end if;

   -- Get Servlet agent
   l_servlet_agent := fnd_profile.value('APPS_SERVLET_AGENT');
   if (l_servlet_agent is not null) then
       l_servlet_agent_base := lower(substr(REGEXP_REPLACE(l_servlet_agent, '^http[s]?://(www\.)?|^www\.', '', 1),1,instr(REGEXP_REPLACE(l_servlet_agent, '^http[s]?://(www\.)?|^www\.', '', 1), '/',1)-1));

       if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
           fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,'Servlet Agent base: '||l_servlet_agent_base);
       end if;
   end if;

   -- Get Framework agent
   l_framework_agent := fnd_profile.value('APPS_FRAMEWORK_AGENT');
   if (l_framework_agent is not null) then
       l_framework_agent_base := lower(REGEXP_REPLACE(l_framework_agent, '^http[s]?://(www\.)?|^www\.', '', 1));

       if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
           fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,'Framework Agent base: '||l_framework_agent_base||' from framwork agent: '||l_framework_agent);
       end if;
   end if;

   -- Check APPS_PORTAL
   l_apps_portal := fnd_profile.value('APPS_PORTAL');
   if (l_apps_portal is not null) then
       l_apps_portal_base := lower(REGEXP_REPLACE(l_apps_portal, '^http[s]?://(www\.)?|^www\.', '', 1));

       if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
           fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,'APPS_PORTAL base: '||l_apps_portal_base||' from APPS_PORTAL: '||l_apps_portal);
       end if;
   end if;


   if (l_url_base=l_web_agent_base  OR l_url_base=l_servlet_agent_base OR l_url_base=l_framework_agent_base OR l_url_base=l_apps_portal_base) then
       if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
           fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,'Internal URL is secure' );
       end if;

       -- local now check if banned
       if (instr(l_url,'fndssologinredirect') > 0 or instr(l_url,'fndssologoutredirect') > 0 or instr(l_url,'weboam/redirecturl') >0) then
           if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
               fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,'banned' );
           end if;
           return 'N';
       end if;
       -- Internal and not banned
           return 'Y';
   else
       -- Not internal
       if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
           fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,'Not internal' );
       end if;

       return 'N';
   end if;

   -- Done with internal url check

   if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
       fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,' End: Default - return N - should not get here');
   end if;

   return 'N';

EXCEPTION WHEN OTHERS THEN
   fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
   fnd_message.set_token('ERRNO', SQLCODE);
   fnd_message.set_token('REASON', SQLERRM);
   RAISE;
END;

-- Determine if the Web Attachment is allowed
-- Returns:
-- ALLOWED
-- NOT_ALLOWED_INVALID_PROTOCOL
-- NOT_ALLOWED_WARN
-- NOT_ALLOWED_BLOCK
--
FUNCTION allow_url_redirect(x_url varchar2)
    RETURN varchar2 IS

l_module_source varchar2(80) := 'FND_ATTACHMENT_UTIL_PKG.allow_url_redirect';
l_validation_profile varchar2(10);
l_isSecure varchar2(1);
second_colon_position number;
trailing_slash_position number;

BEGIN
  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,'Begin - url is: '||x_url);
  end if;

  if (verify_url_protocol(x_url) = 'N') then
     return 'NOT_ALLOWED_INVALID_PROTOCOL';
  end if;

  l_validation_profile := FND_PROFILE.VALUE('FND_ATTACHMENT_URL_VALIDATION');

  if (l_validation_profile is null or l_validation_profile = 'NONE') then
     if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,'Attachment URL Validation is null or set to None');
     end if;
     return 'ALLOWED';
  end if;

  l_isSecure := isSecureUrl(x_url);

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,'Security check of url: '||x_url||' results: '||l_isSecure);
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,'Attachment URL Validation Profile value: '||l_validation_profile);
  end if;

  if (l_isSecure = 'Y') then
     if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,'isSecure');
     end if;
     return 'ALLOWED';
  elsif (l_isSecure = 'N' and l_validation_profile = 'WARN') then
       if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
           fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,'Warn potential unsecure URL');
       end if;
       return 'NOT_ALLOWED_WARN';
  elsif (l_isSecure = 'N' and l_validation_profile = 'BLOCK') then
       if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
           fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,'Block potential unsecure URL');
       end if;
     return 'NOT_ALLOWED_BLOCK';
  end if;


   if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
       fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,' End: Default - return warn - should not get here');
   end if;

   return 'NOT_ALLOWED_WARN';

EXCEPTION WHEN OTHERS THEN
   fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
    fnd_message.set_token('ERRNO', SQLCODE);
    fnd_message.set_token('REASON', SQLERRM);
    RAISE;
END;


-- Determine if the Web Attachment protocol is allowed
-- Returns:
-- Y - Allowed
-- N - Not allowed
--
FUNCTION verify_url_protocol(x_url varchar2)
    RETURN varchar2 IS

l_module_source varchar2(80) := 'FND_ATTACHMENT_UTIL_PKG.verify_url_protocol';
l_validation_profile varchar2(10);
second_colon_position number;
trailing_slash_position number;
l_allowed_protocol varchar2(200);
l_url_protocol varchar2(10);
l_allow varchar2(1);
BEGIN
  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source,'Begin - url is: '||x_url);
  end if;


 l_allowed_protocol := lower(FND_PROFILE.VALUE('FND_ATTACHMENT_ALLOWED_PROTOCOLS'));

 if (l_allowed_protocol is null) then
     if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
        fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,'Attachment ALLOWED Protocol profile is null - default');
     end if;

     l_allowed_protocol := 'http,https';  -- Default to allow http and https only
 end if;


 if (instr(l_allowed_protocol,' ') > 0) then
   -- Loop through and remove all spaces
  while (instr(l_allowed_protocol,' ') > 0) loop
        l_allowed_protocol := replace(l_allowed_protocol,' ','');
  end loop;
 end if;

 if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,'Protocols allowed (should contain no spaces): '||l_allowed_protocol);
 end if;

 -- Append with semicolon to ensure that exact protocols are found.
 -- Example: http does not match to https
 l_allowed_protocol := ','||l_allowed_protocol||',';


 l_url_protocol :=lower(substr(x_url,1,instr(x_url,'://',1)-1));

 if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,'Attachment Protocols allowed: '||l_allowed_protocol||' and the url is: '||l_url_protocol);
 end if;

 if (l_url_protocol is null or instr(l_allowed_protocol,','||l_url_protocol||',')>0) then
    l_allow := 'Y';
 else
   l_allow := 'N';
 end if;

 if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
     fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source,'Protocol allowed: '||l_allow);
 end if;

  return l_allow;

end;



END fnd_attachment_util_pkg;

/
