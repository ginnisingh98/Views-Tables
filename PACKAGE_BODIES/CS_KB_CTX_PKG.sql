--------------------------------------------------------
--  DDL for Package Body CS_KB_CTX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_KB_CTX_PKG" AS
/* $Header: cskbdstb.pls 120.0.12010000.4 2009/10/01 08:25:29 vpremach ship $ */

  -- *********************************
  -- Private Procedure Declarations
  -- *********************************


  PROCEDURE Single_Synthesize_Set_Content
  (p_solution_id IN     NUMBER,
    p_lang        IN     VARCHAR2,
    p_soln_number IN     VARCHAR2,
    p_set_type_id IN     NUMBER,
    p_clob        IN OUT NOCOPY CLOB

  );

  --Start 12.1.3
    PROCEDURE Single_Sync_Set_Attach_Content
  (p_solution_id IN     NUMBER,
    p_lang        IN     VARCHAR2,
    p_soln_number IN     VARCHAR2,
    p_set_type_id IN     NUMBER,
    p_clob        IN OUT NOCOPY CLOB

  );
  --End 12.1.3
  PROCEDURE Write_Soln_Header_Cont_Hlp
  ( p_solution_id IN     NUMBER,
    p_lang        IN     VARCHAR2,
    p_clob        IN OUT NOCOPY CLOB,
    p_temp_clob   IN OUT NOCOPY CLOB);


  PROCEDURE Write_Soln_Header_Sect_Hlp
  ( p_solution_id IN     NUMBER,
    p_lang        IN     VARCHAR2,
    p_clob        IN OUT NOCOPY CLOB);


  PROCEDURE Write_Soln_Category_Sect_Hlp
  ( p_solution_id IN     NUMBER,
    p_clob        IN OUT NOCOPY CLOB);


  PROCEDURE Write_Soln_Product_Cont_Hlp
  ( p_solution_id IN     NUMBER,
    p_lang        IN     VARCHAR2,
    p_clob        IN OUT NOCOPY CLOB,
    p_temp_clob   IN OUT NOCOPY CLOB);


  PROCEDURE Write_Soln_Product_Sect_Hlp
  ( p_solution_id IN     NUMBER,
    p_clob        IN OUT NOCOPY CLOB);


  PROCEDURE Write_Soln_Platform_Cont_Hlp
  ( p_solution_id IN     NUMBER,
    p_lang        IN     VARCHAR2,
    p_clob        IN OUT NOCOPY CLOB,
    p_temp_clob   IN OUT NOCOPY CLOB);

  PROCEDURE Write_Soln_Platform_Sect_Hlp
  ( p_solution_id IN     NUMBER,
    p_clob        IN OUT NOCOPY CLOB);

  PROCEDURE Write_Soln_CatGrp_Sect_Hlp
  ( p_solution_id IN     NUMBER,
    p_clob        IN OUT NOCOPY CLOB);


  PROCEDURE Write_Soln_Statement_Cont_Hlp
  ( p_solution_id IN     NUMBER,
    p_lang        IN     VARCHAR2,
    p_clob        IN OUT NOCOPY CLOB,
    p_temp_clob   IN OUT NOCOPY CLOB);

  PROCEDURE Write_Soln_Statement_Sect_Hlp
  ( p_solution_id IN     NUMBER,
    p_clob        IN OUT NOCOPY CLOB);

  PROCEDURE Write_Stmt_Header_Cont_Hlp
  ( p_statement_id IN     NUMBER,
    p_lang         IN     VARCHAR2,
    p_clob         IN OUT NOCOPY CLOB,
    p_temp_clob   IN OUT NOCOPY CLOB,
    p_statement_number IN VARCHAR2,
    p_name             IN VARCHAR2,
    p_description      IN CLOB);

  PROCEDURE Write_Stmt_Header_Sect_Hlp
  ( p_statement_id IN     NUMBER,
    p_lang         IN     VARCHAR2,
    p_clob         IN OUT NOCOPY CLOB,
    p_statement_number IN VARCHAR2,
    p_type_id          IN NUMBER,
    p_access_level     IN NUMBER);

  PROCEDURE Write_Stmt_CatGrp_Sect_Hlp
  ( p_statement_id IN     NUMBER,
    p_clob         IN OUT NOCOPY CLOB);

  -- 3341248
  PROCEDURE Write_Related_Stmt_Sect_Hlp
  ( p_statement_id IN     NUMBER,
    p_clob         IN OUT NOCOPY CLOB);

  --Start 12.1.3
   PROCEDURE Write_Soln_Attach_Cont_Hlp
  ( p_solution_id IN     NUMBER,
    p_lang        IN     VARCHAR2,
    p_clob        IN OUT NOCOPY CLOB,
    p_temp_clob   IN OUT NOCOPY CLOB);

   PROCEDURE Write_Soln_Attach_Sect_Hlp
  ( p_solution_id IN     NUMBER,
    p_clob        IN OUT NOCOPY CLOB);
  --End 12.1.3



  -- ********************************
  -- Public Procedure Implementations
  -- ********************************

  PROCEDURE Get_Composite_Elements
  ( p_rowid IN ROWID, p_clob IN OUT NOCOPY CLOB )
  IS
    l_solnid NUMBER;
    l_lang VARCHAR2(4);
    l_status VARCHAR2(30);
    l_clob CLOB := NULL;
    l_clob_len NUMBER;

    --(perf11510)
    CURSOR set_content_csr(p_rowid IN ROWID) IS
    SELECT tl.set_id,
	   tl.LANGUAGE,
	   b.status,
	   tl.content_cache,
	   b.set_number,
	   b.set_type_id
    FROM CS_KB_SETS_TL tl, CS_KB_SETS_B b
    WHERE tl.ROWID = p_rowid
    AND b.set_id = tl.set_id;

    l_set_number VARCHAR2(30);
    l_set_type_id NUMBER;
  BEGIN

    --(perf11510)
    /*
    -- Get the solution id and language, based on the rowid
    select tl.set_id, tl.language, b.status, tl.content_cache
    into l_solnid, l_lang, l_status, l_clob
    from CS_KB_SETS_TL tl, CS_KB_SETS_B b
    where tl.rowid = p_rowid
      and b.set_id = tl.set_id;
     */
    OPEN set_content_csr(p_rowid);
    FETCH set_content_csr
		    INTO  l_solnid
                         ,l_lang
			 ,l_status
			 ,l_clob
			 ,l_set_number
			 ,l_set_type_id;

    CLOSE set_content_csr;
    -- end (perf11510)


    -- Index only Published Solutions.
    IF ( l_status = 'PUB' )
    THEN
      -- If the solution content cache is populated, then use it
      -- for the indexed content.
      IF (l_clob IS NOT NULL AND dbms_lob.getlength(l_clob) > 0)
      THEN
        -- Clear out the output CLOB buffer
        dbms_lob.trim(p_clob, 0);

        -- Copy content cache into output CLOB buffer for indexing
        l_clob_len := dbms_lob.getlength(l_clob);
        dbms_lob.copy(p_clob, l_clob, l_clob_len, 1, 1);
      ELSE
        -- Call procedure to return synthesized solution content
        -- for indexing. CLOB is passed by reference and sub
        -- procedures will change the CLOB directly.
       -- Synthesize_Solution_Content( l_solnid, l_lang, p_clob );
       Single_Synthesize_Set_Content( l_solnid
                                     ,l_lang
                                     ,l_set_number
                                     ,l_set_type_id
                                     ,p_clob);

      END IF;

      -- Append the solution security information to the indexable
      -- content at index time.
      -- Note: neither the content cache, nor the call to Synthesize_
      -- Solution_Content() includes the security section.
      Write_Soln_CatGrp_Sect_Hlp( l_solnid, p_clob );

    END IF;
  END Get_Composite_Elements;

  --(perf11510)
  PROCEDURE Single_Synthesize_Set_Content
  ( p_solution_id IN     NUMBER,
    p_lang        IN     VARCHAR2,
    p_soln_number IN     VARCHAR2,
    p_set_type_id IN     NUMBER,
    p_clob        IN OUT NOCOPY CLOB)
  IS
    l_temp_clob CLOB;
    l_amt BINARY_INTEGER;
    l_newline VARCHAR2(4) := fnd_global.newline;
    l_data VARCHAR2(32000);

    CURSOR set_title_csr(p_set_id NUMBER, p_lang VARCHAR2) IS
    SELECT name
    FROM Cs_Kb_Sets_tl
    WHERE set_id = p_set_id
    AND LANGUAGE = p_lang;
    l_soln_title VARCHAR2(2000);

    l_sections VARCHAR2(32000);
    l_content  VARCHAR2(32000);

    CURSOR c1(c_setid IN NUMBER, c_lang IN VARCHAR2) IS
      SELECT et.name, et.description, eb.element_id, eb.element_number
      FROM CS_KB_ELEMENTS_B eb,
           CS_KB_ELEMENTS_TL et,
           CS_KB_SET_ELES se
      WHERE se.set_id = c_setid
      AND eb.element_id = se.element_id
      AND eb.element_id = et.element_id
      AND eb.status = 'PUBLISHED' --- added 03/16/2004
      AND et.LANGUAGE = c_lang;

    rec1 c1%ROWTYPE;

    CURSOR c6(c_set_id IN NUMBER, c_lang IN VARCHAR2) IS
      SELECT b.segment1 name,t.description, s.product_id
      FROM mtl_system_items_b b, mtl_system_items_tl t, cs_kb_set_products s
      WHERE t.inventory_item_id = s.product_id
      AND t.organization_id   = s.product_org_id
      AND b.inventory_item_id = s.product_id
      AND b.organization_id   = s.product_org_id
      AND t.LANGUAGE = c_lang
      AND s.set_id = c_set_id;

    CURSOR c7(c_set_id IN NUMBER, c_lang IN VARCHAR2) IS
      SELECT b.segment1 name,t.description, s.platform_id
      FROM mtl_system_items_b b, mtl_system_items_tl t, cs_kb_set_platforms s
      WHERE t.inventory_item_id = s.platform_id
      AND t.organization_id   = s.platform_org_id
      AND b.inventory_item_id = s.platform_id
      AND b.organization_id   = s.platform_org_id
      AND t.LANGUAGE = c_lang
      AND s.set_id = c_set_id;

    CURSOR c5(c_set_id IN NUMBER) IS
      SELECT DISTINCT category_id
      FROM CS_KB_SOLN_CATEGORIES_B
      START WITH category_id IN
      (
        SELECT category_id
        FROM cs_kb_set_categories
        WHERE set_id = c_set_id
      )
      CONNECT BY PRIOR parent_category_id = category_id;

    l_clob CLOB := NULL;
    l_clob_len NUMBER;
    p_clob_len NUMBER;

    l_stmt_name      VARCHAR2(32000) := '';
    empty_flag       BOOLEAN := TRUE;
  BEGIN
    -- temp clob lives for at most the duration of call.
    dbms_lob.createtemporary(l_temp_clob, TRUE, dbms_lob.call);

    DBMS_LOB.OPEN(l_temp_clob,DBMS_LOB.LOB_READWRITE);

    -- Clear out the output CLOB buffer
    dbms_lob.trim(p_clob, 0);

    -- write the solution number to clob
    l_data := l_newline||p_soln_number;

    -- write solution title to clob
    OPEN set_title_csr(p_solution_id, p_lang);
    FETCH set_title_csr INTO l_soln_title;
    CLOSE set_title_csr;

    l_data := l_data||' '||l_soln_title||l_newline;
    l_data := Remove_Tags(l_data);
    l_amt := LENGTH(l_data);

    dbms_lob.writeappend(p_clob, l_amt, l_data);

    -- Construct the header sections
    -- write solution type id
    l_sections := l_newline||'<TYPE>a' || TO_CHAR(p_set_type_id) || 'a</TYPE> ';

    -- write language code
    l_sections := l_sections||l_newline||'<LANG>a'|| p_lang ||'a</LANG>';

    -- write solution number
    l_sections := l_sections|| l_newline||'<NUMBER>a' || p_soln_number
		    || 'a</NUMBER>';

    -- For each Statement linked to the solution header,
    -- write all of the Statement content (summary, description)
    -- into the clob.
    l_sections := l_sections || l_newline||'<STATEMENTS>';

    l_stmt_name := '';

    FOR rec1 IN c1(p_solution_id, p_lang) LOOP

      -- Write the statement summary to clob
      l_stmt_name := l_stmt_name||rec1.name||l_newline;
      l_amt := LENGTH(l_stmt_name);
      IF l_amt >= 31000 THEN
      	-- flush l_stmt_name to the p_clob
	  l_stmt_name := Remove_Tags(l_stmt_name);
	  dbms_lob.writeappend(p_clob, l_amt, l_stmt_name);
	  l_stmt_name := l_newline;
      END IF;

      -- Write the statement description to clob
      l_clob := rec1.description;
      IF (l_clob IS NOT NULL AND dbms_lob.getlength(l_clob) > 0)
      THEN
        l_clob := Remove_Tags_Clob(l_clob, l_temp_clob);
        l_clob_len := dbms_lob.getlength(l_clob);
        p_clob_len := dbms_lob.getlength(p_clob);
        dbms_lob.copy(p_clob, l_clob, l_clob_len, p_clob_len+1, 1);
      END IF;

      -- Repeat each statement id for 10 times.
      -- Need revisit in 115.x. See issue #1309
      FOR i IN 1..10 LOOP
       l_sections := l_sections||' a'||rec1.element_id||'a ';
      END LOOP;
    END LOOP;

    l_amt := LENGTH(l_stmt_name);
    IF l_amt > 0 THEN
       l_stmt_name := Remove_Tags(l_stmt_name);
       dbms_lob.writeappend(p_clob, l_amt, l_stmt_name);
    END IF;

    l_sections := l_sections || '</STATEMENTS>';

    -- write category section
    l_sections := l_sections|| l_newline||'<CATEGORIES>';
    FOR rec5 IN c5(p_solution_id) LOOP
      l_sections := l_sections  || ' a' || TO_CHAR(rec5.category_id) || 'a ';
    END LOOP;

    l_sections := l_sections||'</CATEGORIES>' ;

    --write product name and description to clob
    l_sections := l_sections || l_newline||'<PRODUCTS>';

    l_data := '';
    l_amt := 0;

    -- reset empty_flag
    empty_flag := TRUE;
    FOR rec6 IN c6(p_solution_id, p_lang) LOOP
      l_data := l_data||l_newline||rec6.name||' '||rec6.description;
      l_sections := l_sections||l_newline||' a'||TO_CHAR(rec6.product_id)||'a ';
      empty_flag := FALSE;
    END LOOP;

    IF empty_flag THEN
      -- write generice platforms
      l_sections := l_sections || 'a000a';
    END IF;
    l_sections := l_sections || '</PRODUCTS>';

    l_sections := l_sections || l_newline||'<PLATFORMS>';

    -- reset empty_flag
    empty_flag := TRUE;
    FOR rec7 IN c7(p_solution_id, p_lang) LOOP
      l_data := l_data||l_newline||rec7.name||' '||rec7.description;
      l_sections := l_sections||' a'||TO_CHAR(rec7.platform_id) ||'a ';
      empty_flag := FALSE;
    END LOOP;

    IF empty_flag THEN
      -- write generice platforms
      l_sections := l_sections || 'a000a';
    END IF;

    l_sections := l_sections || '</PLATFORMS>';

    l_data := Remove_Tags(l_data);

    l_amt := LENGTH(l_data);
    IF ( l_amt > 0 )
    THEN
      dbms_lob.writeappend(p_clob, l_amt, l_data);
    END IF;

    l_amt := LENGTH(l_sections);
    IF ( l_amt > 0 )
    THEN
      dbms_lob.writeappend(p_clob, l_amt, l_sections);
    END IF;

   DBMS_LOB.CLOSE(l_temp_clob);
   dbms_lob.freetemporary(l_temp_clob);

  END Single_Synthesize_Set_Content;
  -- end (perf11510)
    --Start 12.1.3
 PROCEDURE Get_Composite_Attach_Elements
  ( p_rowid IN ROWID, p_clob IN OUT NOCOPY CLOB )
  IS
    l_solnid NUMBER;
    l_lang VARCHAR2(4);
    l_status VARCHAR2(30);
    l_clob CLOB := NULL;
    l_clob_len NUMBER;

    --(perf11510)
    CURSOR set_content_csr(p_rowid IN ROWID) IS
    SELECT tl.set_id,
	   tl.LANGUAGE,
	   b.status,
	   tl.attachment_content_cache,
	   b.set_number,
	   b.set_type_id
    FROM CS_KB_SETS_TL tl, CS_KB_SETS_B b
    WHERE tl.ROWID = p_rowid
    AND b.set_id = tl.set_id;

    l_set_number VARCHAR2(30);
    l_set_type_id NUMBER;
  BEGIN

    --(perf11510)
    /*
    -- Get the solution id and language, based on the rowid
    select tl.set_id, tl.language, b.status, tl.content_cache
    into l_solnid, l_lang, l_status, l_clob
    from CS_KB_SETS_TL tl, CS_KB_SETS_B b
    where tl.rowid = p_rowid
      and b.set_id = tl.set_id;
     */
    OPEN set_content_csr(p_rowid);
    FETCH set_content_csr
		    INTO  l_solnid
                         ,l_lang
			 ,l_status
			 ,l_clob
			 ,l_set_number
			 ,l_set_type_id;

    CLOSE set_content_csr;
    -- end (perf11510)


    -- Index only Published Solutions.
    IF ( l_status = 'PUB' )
    THEN
      -- If the solution content cache is populated, then use it
      -- for the indexed content.
      IF (l_clob IS NOT NULL AND dbms_lob.getlength(l_clob) > 0)
      THEN
        -- Clear out the output CLOB buffer
        dbms_lob.trim(p_clob, 0);

        -- Copy content cache into output CLOB buffer for indexing
        l_clob_len := dbms_lob.getlength(l_clob);
        dbms_lob.copy(p_clob, l_clob, l_clob_len, 1, 1);
      ELSE
        -- Call procedure to return synthesized solution content
        -- for indexing. CLOB is passed by reference and sub
        -- procedures will change the CLOB directly.
       -- Synthesize_Solution_Content( l_solnid, l_lang, p_clob );
       Single_Sync_Set_Attach_Content( l_solnid
                                     ,l_lang
                                     ,l_set_number
                                     ,l_set_type_id
                                     ,p_clob);

      END IF;

      -- Append the solution security information to the indexable
      -- content at index time.
      -- Note: neither the content cache, nor the call to Synthesize_
      -- Solution_Content() includes the security section.
      Write_Soln_CatGrp_Sect_Hlp( l_solnid, p_clob );

    END IF;
  END Get_Composite_Attach_Elements;

    PROCEDURE Single_Sync_Set_Attach_Content
  ( p_solution_id IN     NUMBER,
    p_lang        IN     VARCHAR2,
    p_soln_number IN     VARCHAR2,
    p_set_type_id IN     NUMBER,
    p_clob        IN OUT NOCOPY CLOB)
  IS
    l_temp_clob CLOB;
    l_amt BINARY_INTEGER;
    l_newline VARCHAR2(4) := fnd_global.newline;
    l_data VARCHAR2(32000);

    CURSOR set_title_csr(p_set_id NUMBER, p_lang VARCHAR2) IS
    SELECT name
    FROM Cs_Kb_Sets_tl
    WHERE set_id = p_set_id
    AND LANGUAGE = p_lang;
    l_soln_title VARCHAR2(2000);

    l_sections VARCHAR2(32000);
    l_content  VARCHAR2(32000);

    CURSOR c1(c_setid IN NUMBER, c_lang IN VARCHAR2) IS
      SELECT et.name, et.description, eb.element_id, eb.element_number
      FROM CS_KB_ELEMENTS_B eb,
           CS_KB_ELEMENTS_TL et,
           CS_KB_SET_ELES se
      WHERE se.set_id = c_setid
      AND eb.element_id = se.element_id
      AND eb.element_id = et.element_id
      AND eb.status = 'PUBLISHED' --- added 03/16/2004
      AND et.LANGUAGE = c_lang;

    rec1 c1%ROWTYPE;

    CURSOR c6(c_set_id IN NUMBER, c_lang IN VARCHAR2) IS
      SELECT b.segment1 name,t.description, s.product_id
      FROM mtl_system_items_b b, mtl_system_items_tl t, cs_kb_set_products s
      WHERE t.inventory_item_id = s.product_id
      AND t.organization_id   = s.product_org_id
      AND b.inventory_item_id = s.product_id
      AND b.organization_id   = s.product_org_id
      AND t.LANGUAGE = c_lang
      AND s.set_id = c_set_id;

    CURSOR c7(c_set_id IN NUMBER, c_lang IN VARCHAR2) IS
      SELECT b.segment1 name,t.description, s.platform_id
      FROM mtl_system_items_b b, mtl_system_items_tl t, cs_kb_set_platforms s
      WHERE t.inventory_item_id = s.platform_id
      AND t.organization_id   = s.platform_org_id
      AND b.inventory_item_id = s.platform_id
      AND b.organization_id   = s.platform_org_id
      AND t.LANGUAGE = c_lang
      AND s.set_id = c_set_id;

    CURSOR c5(c_set_id IN NUMBER) IS
      SELECT DISTINCT category_id
      FROM CS_KB_SOLN_CATEGORIES_B
      START WITH category_id IN
      (
        SELECT category_id
        FROM cs_kb_set_categories
        WHERE set_id = c_set_id
      )
      CONNECT BY PRIOR parent_category_id = category_id;

     CURSOR c8(c_setid IN NUMBER, c_lang IN VARCHAR2) IS
      SELECT	fdtl.title, fdtl.description, fl.file_name, fl.file_data, fad.document_id
	  FROM 	fnd_attached_documents fad,
		fnd_documents fd,
		fnd_documents_tl fdtl,
                fnd_lobs fl
	  WHERE	fad.document_id = fd.document_id
            AND fd.document_id = fdtl.document_id
            AND fl.file_id = fd.media_id
	    AND fdtl.language  = c_lang
	    AND fad.entity_name = 'CS_KB_SETS_B'
	    AND fad.pk1_value = c_setid;

    l_clob CLOB := NULL;
    l_clob_len NUMBER;
    p_clob_len NUMBER;
    --12.1.3
    src_blob BLOB := null;
    amount INTEGER := dbms_lob.lobmaxsize;
    dest_offset INTEGER :=1;
    src_offset  INTEGER :=1;
    blob_csid  NUMBER := dbms_lob.default_csid;
    lang_context  INTEGER := dbms_lob.default_lang_ctx;
    warning  INTEGER;
    --12.1.3

    l_stmt_name      VARCHAR2(32000) := '';
    empty_flag       BOOLEAN := TRUE;
  BEGIN
    -- temp clob lives for at most the duration of call.
    dbms_lob.createtemporary(l_temp_clob, TRUE, dbms_lob.call);

    DBMS_LOB.OPEN(l_temp_clob,DBMS_LOB.LOB_READWRITE);

    -- Clear out the output CLOB buffer
    dbms_lob.trim(p_clob, 0);

    -- write the solution number to clob
    l_data := l_newline||p_soln_number;

    -- write solution title to clob
    OPEN set_title_csr(p_solution_id, p_lang);
    FETCH set_title_csr INTO l_soln_title;
    CLOSE set_title_csr;

    l_data := l_data||' '||l_soln_title||l_newline;
    l_data := Remove_Tags(l_data);
    l_amt := LENGTH(l_data);

    dbms_lob.writeappend(p_clob, l_amt, l_data);

    -- Construct the header sections
    -- write solution type id
    l_sections := l_newline||'<TYPE>a' || TO_CHAR(p_set_type_id) || 'a</TYPE> ';

    -- write language code
    l_sections := l_sections||l_newline||'<LANG>a'|| p_lang ||'a</LANG>';

    -- write solution number
    l_sections := l_sections|| l_newline||'<NUMBER>a' || p_soln_number
		    || 'a</NUMBER>';

    -- For each Statement linked to the solution header,
    -- write all of the Statement content (summary, description)
    -- into the clob.
    l_sections := l_sections || l_newline||'<STATEMENTS>';

    l_stmt_name := '';

    FOR rec1 IN c1(p_solution_id, p_lang) LOOP

      -- Write the statement summary to clob
      l_stmt_name := l_stmt_name||rec1.name||l_newline;
      l_amt := LENGTH(l_stmt_name);
      IF l_amt >= 31000 THEN
      	-- flush l_stmt_name to the p_clob
	  l_stmt_name := Remove_Tags(l_stmt_name);
	  dbms_lob.writeappend(p_clob, l_amt, l_stmt_name);
	  l_stmt_name := l_newline;
      END IF;

      -- Write the statement description to clob
      l_clob := rec1.description;
      IF (l_clob IS NOT NULL AND dbms_lob.getlength(l_clob) > 0)
      THEN
        l_clob := Remove_Tags_Clob(l_clob, l_temp_clob);
        l_clob_len := dbms_lob.getlength(l_clob);
        p_clob_len := dbms_lob.getlength(p_clob);
        dbms_lob.copy(p_clob, l_clob, l_clob_len, p_clob_len+1, 1);
      END IF;

      -- Repeat each statement id for 10 times.
      -- Need revisit in 115.x. See issue #1309
      FOR i IN 1..10 LOOP
       l_sections := l_sections||' a'||rec1.element_id||'a ';
      END LOOP;
    END LOOP;

    l_amt := LENGTH(l_stmt_name);
    IF l_amt > 0 THEN
       l_stmt_name := Remove_Tags(l_stmt_name);
       dbms_lob.writeappend(p_clob, l_amt, l_stmt_name);
    END IF;

    l_sections := l_sections || '</STATEMENTS>';

    -- write category section
    l_sections := l_sections|| l_newline||'<CATEGORIES>';
    FOR rec5 IN c5(p_solution_id) LOOP
      l_sections := l_sections  || ' a' || TO_CHAR(rec5.category_id) || 'a ';
    END LOOP;

    l_sections := l_sections||'</CATEGORIES>' ;

    --write product name and description to clob
    l_sections := l_sections || l_newline||'<PRODUCTS>';

    l_data := '';
    l_amt := 0;

    -- reset empty_flag
    empty_flag := TRUE;
    FOR rec6 IN c6(p_solution_id, p_lang) LOOP
      l_data := l_data||l_newline||rec6.name||' '||rec6.description;
      l_sections := l_sections||l_newline||' a'||TO_CHAR(rec6.product_id)||'a ';
      empty_flag := FALSE;
    END LOOP;

    IF empty_flag THEN
      -- write generice platforms
      l_sections := l_sections || 'a000a';
    END IF;
    l_sections := l_sections || '</PRODUCTS>';

    l_sections := l_sections || l_newline||'<PLATFORMS>';

    -- reset empty_flag
    empty_flag := TRUE;
    FOR rec7 IN c7(p_solution_id, p_lang) LOOP
      l_data := l_data||l_newline||rec7.name||' '||rec7.description;
      l_sections := l_sections||' a'||TO_CHAR(rec7.platform_id) ||'a ';
      empty_flag := FALSE;
    END LOOP;

    IF empty_flag THEN
      -- write generice platforms
      l_sections := l_sections || 'a000a';
    END IF;

    l_sections := l_sections || '</PLATFORMS>';

    -- Start 12.1.3
          l_sections := l_sections || l_newline||'<ATTACHMENTS>';

    -- reset empty_flag
    empty_flag := TRUE;
    FOR rec8 IN c8(p_solution_id, p_lang) LOOP
        l_data := l_newline||rec8.title||l_newline||rec8.description||l_newline||rec8.file_name||l_newline;
        l_data := Remove_Tags(l_data); --, p_temp_clob);
	l_sections := l_sections||' a'||TO_CHAR(rec8.document_id) ||'a ';
      l_amt := LENGTH(l_data);

      IF(l_amt>0) THEN
        dbms_lob.writeappend(p_clob, l_amt, l_data);
      END IF;

      -- Write the statement description to clob
      src_blob := rec8.file_data;
      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'cs.plsql.cskbdstb.pls',
                         'Before dbms_lob.converttoclob- src_blob :  || src_blob');
        END IF;
      dbms_lob.converttoclob(l_clob ,src_blob, amount, dest_offset, src_offset, blob_csid,lang_context, warning);
      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'cs.plsql.cskbdstb.pls',
                         'After dbms_lob.converttoclob- l_clob : || l_clob' );
        END IF;

      IF (l_clob IS NOT NULL AND dbms_lob.getlength(l_clob) > 0)
      THEN
        l_clob := Remove_Tags_Clob(l_clob, l_temp_clob);
        l_clob_len := dbms_lob.getlength(l_clob);
        p_clob_len := dbms_lob.getlength(p_clob);
        dbms_lob.copy(p_clob, l_clob, l_clob_len, p_clob_len+1, 1);
      END IF;

      empty_flag := FALSE;
    IF empty_flag THEN
      -- write generice platforms
      l_sections := l_sections || 'a000a';
    END IF;
 END LOOP;
    l_sections := l_sections || '</ATTACHMENTS>';

    --End 12.1.3

    l_data := Remove_Tags(l_data);

    l_amt := LENGTH(l_data);
    IF ( l_amt > 0 )
    THEN
      dbms_lob.writeappend(p_clob, l_amt, l_data);
    END IF;

    l_amt := LENGTH(l_sections);
    IF ( l_amt > 0 )
    THEN
      dbms_lob.writeappend(p_clob, l_amt, l_sections);
    END IF;

   DBMS_LOB.CLOSE(l_temp_clob);
   dbms_lob.freetemporary(l_temp_clob);

  END Single_Sync_Set_Attach_Content;
  -- end (perf11510)

--End 12.1.3

  PROCEDURE Build_Elements
  (p_rowid IN ROWID, p_clob IN OUT NOCOPY CLOB)
  IS
    l_statement_id NUMBER;
    l_lang VARCHAR2(5);
    l_status VARCHAR2(30);

    l_statement_number VARCHAR2(30);
    l_name VARCHAR2(2000);
    l_description CLOB := NULL;
    l_access_level NUMBER;
    l_type_id NUMBER;

    l_temp_clob CLOB;

    CURSOR GET_STMT_CONTENT IS
     SELECT tl.element_id, tl.LANGUAGE, b.status,
            b.element_number, tl.name, tl.description,
            b.access_level, b.element_type_id
     FROM CS_KB_ELEMENTS_TL tl, CS_KB_ELEMENTS_B b
     WHERE tl.ROWID = p_rowid
     AND tl.element_id = b.element_id;
  BEGIN
    -- Fetch statement id, language, and status based on rowid
    -- Bug 3455203 - Perf Changes: Select all info in one cursor
    -- and pass down to other apis

    OPEN  GET_STMT_CONTENT;
    FETCH GET_STMT_CONTENT INTO l_statement_id, l_lang, l_status,
                                l_statement_number, l_name, l_description,
                                l_access_level, l_type_id;
    CLOSE GET_STMT_CONTENT;


    -- Index only Published statements
    IF ( l_status = 'PUBLISHED' )
    THEN
      -- Call procedure to return synthesized statement content
      -- for indexing. CLOB is passed by reference and sub
      -- procedures will change the CLOB directly.
      --Synthesize_Statement_Content( l_statement_id, l_lang, p_clob );
      -- Bug 3455203 - Perf Changes:
      -- Consolidated code from Synthesize_Statement_Content to here:

      -- temp clob lives for at most the duration of call.
      dbms_lob.createtemporary(l_temp_clob, TRUE, dbms_lob.call);
      -- Clear out the output CLOB buffer
      dbms_lob.trim(p_clob, 0);

      -- Write out the statement text content
      Write_Stmt_Header_Cont_Hlp(l_statement_id, l_lang, p_clob, l_temp_clob,
                                 l_statement_number, l_name, l_description);
      -- Write out metadata sections
      Write_Stmt_Header_Sect_Hlp(l_statement_id, l_lang, p_clob,
                                 l_statement_number, l_type_id, l_access_level);
      -- explicitly free the clob
      dbms_lob.freetemporary(l_temp_clob);
      --

      -- Append the statement security information into the index
      -- at index time.
      Write_Stmt_CatGrp_Sect_Hlp(l_statement_id, p_clob);

      -- 3341248: Append the related statements information
      Write_Related_Stmt_Sect_Hlp(l_statement_id, p_clob);

    END IF;
  END Build_Elements;


  PROCEDURE Synthesize_Solution_Content
  ( p_solution_id IN            NUMBER,
    p_lang        IN            VARCHAR2,
    p_clob        IN OUT NOCOPY CLOB)
  IS
    l_temp_clob CLOB;

  BEGIN

    -- temp clob lives for at most the duration of call.
    dbms_lob.createtemporary(l_temp_clob, TRUE, dbms_lob.call);

    -- Clear out the output CLOB buffer
    dbms_lob.trim(p_clob, 0);

    -- Write out the solution text content
    Write_Soln_Header_Cont_Hlp( p_solution_id, p_lang, p_clob, l_temp_clob );
    Write_Soln_Statement_Cont_Hlp( p_solution_id, p_lang, p_clob, l_temp_clob );
    Write_Soln_Product_Cont_Hlp( p_solution_id, p_lang, p_clob, l_temp_clob );
    Write_Soln_Platform_Cont_Hlp( p_solution_id, p_lang, p_clob, l_temp_clob );

    -- Write out metadata sections
    Write_Soln_Header_Sect_Hlp( p_solution_id, p_lang, p_clob );
    Write_Soln_Statement_Sect_Hlp( p_solution_id, p_clob );
    Write_Soln_Category_Sect_Hlp( p_solution_id, p_clob );
    Write_Soln_Product_Sect_Hlp( p_solution_id, p_clob );
    Write_Soln_Platform_Sect_Hlp( p_solution_id, p_clob );

    -- explicitly free the clob
    dbms_lob.freetemporary(l_temp_clob);
  END Synthesize_Solution_Content;


  --Start 12.1.3
     PROCEDURE Synthesize_Sol_Attach_Content
  ( p_solution_id IN            NUMBER,
    p_lang        IN            VARCHAR2,
    p_clob        IN OUT NOCOPY CLOB)
  IS
    l_temp_clob CLOB;

  BEGIN

    -- temp clob lives for at most the duration of call.
    dbms_lob.createtemporary(l_temp_clob, TRUE, dbms_lob.call);

    -- Clear out the output CLOB buffer
    dbms_lob.trim(p_clob, 0);

    -- Write out the solution text content
    Write_Soln_Header_Cont_Hlp( p_solution_id, p_lang, p_clob, l_temp_clob );
    Write_Soln_Statement_Cont_Hlp( p_solution_id, p_lang, p_clob, l_temp_clob );
    Write_Soln_Product_Cont_Hlp( p_solution_id, p_lang, p_clob, l_temp_clob );
    Write_Soln_Platform_Cont_Hlp( p_solution_id, p_lang, p_clob, l_temp_clob );
    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'cs.plsql.cskbdstb.pls',
                         'Before Write_Soln_Attach_Cont_Hlp- ');
        END IF;
    Write_Soln_Attach_Cont_Hlp( p_solution_id, p_lang, p_clob, l_temp_clob );
    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'cs.plsql.cskbdstb.pls',
                         'After Write_Soln_Attach_Cont_Hlp- ');
        END IF;
    -- Write out metadata sections
    Write_Soln_Header_Sect_Hlp( p_solution_id, p_lang, p_clob );
    Write_Soln_Statement_Sect_Hlp( p_solution_id, p_clob );
    Write_Soln_Category_Sect_Hlp( p_solution_id, p_clob );
    Write_Soln_Product_Sect_Hlp( p_solution_id, p_clob );
    Write_Soln_Platform_Sect_Hlp( p_solution_id, p_clob );
    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'cs.plsql.cskbdstb.pls',
                         'Before Write_Soln_Attach_Sect_Hlp- ');
        END IF;
    Write_Soln_Attach_Sect_Hlp( p_solution_id, p_clob );
     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'cs.plsql.cskbdstb.pls',
                         'After Write_Soln_Attach_Sect_Hlp- ');
        END IF;
    -- explicitly free the clob
    dbms_lob.freetemporary(l_temp_clob);
  END Synthesize_Sol_Attach_Content;
  --End 12.1.3

--  procedure Synthesize_Statement_Content
--  ( p_statement_id IN NUMBER,
--    p_lang IN VARCHAR2,
--    p_clob IN OUT NOCOPY CLOB)
--  is
--    l_temp_clob CLOB;
--  begin
--
--    -- temp clob lives for at most the duration of call.
--    dbms_lob.createtemporary(l_temp_clob, TRUE, dbms_lob.call);
--
--    -- Clear out the output CLOB buffer
--    dbms_lob.trim(p_clob, 0);
--
--    -- Write out the statement text content
--    Write_Stmt_Header_Cont_Hlp(p_statement_id, p_lang, p_clob, l_temp_clob);
--
--    -- Write out metadata sections
--    Write_Stmt_Header_Sect_Hlp(p_statement_id, p_lang, p_clob);
--
--    -- explicitly free the clob
--    dbms_lob.freetemporary(l_temp_clob);
--
--  end Synthesize_Statement_Content;



  -- *********************************
  -- Private Procedure Implementations
  -- *********************************

  PROCEDURE Write_Soln_Header_Cont_Hlp
  ( p_solution_id IN     NUMBER,
    p_lang        IN     VARCHAR2,
    p_clob        IN OUT NOCOPY CLOB,
    p_temp_clob   IN OUT NOCOPY CLOB)
  IS
    CURSOR c2(c_set_id IN NUMBER, c_lang IN VARCHAR2) IS
      SELECT b.set_number, tl.name
      FROM CS_KB_SETS_B b, CS_KB_SETS_TL tl
      WHERE b.set_id = c_set_id
      AND tl.set_id = b.set_id
      AND tl.LANGUAGE = c_lang;

    l_soln_title VARCHAR2(2000);
    l_soln_number VARCHAR2(30);
    l_data VARCHAR2(2000);
    l_amt BINARY_INTEGER;
    l_newline VARCHAR2(4) := fnd_global.newline;
  BEGIN
    -- Fetch the solution header
    OPEN c2(p_solution_id, p_lang);
    FETCH c2 INTO l_soln_number, l_soln_title;
    CLOSE c2;

    -- write the solution number to clob
    l_data := l_newline||l_soln_number;
    l_amt := LENGTH(l_data);
    dbms_lob.writeappend(p_clob, l_amt, l_data);

    -- write solution title to clob
    l_data := ' '||l_soln_title;
    l_data := Remove_Tags(l_data); --, p_temp_clob);
    l_amt := LENGTH(l_data);
    dbms_lob.writeappend(p_clob, l_amt, l_data);

  END Write_Soln_Header_Cont_Hlp;


  PROCEDURE Write_Soln_Header_Sect_Hlp
  ( p_solution_id IN     NUMBER,
    p_lang        IN     VARCHAR2,
    p_clob        IN OUT NOCOPY CLOB)
  IS
    CURSOR c2(c_set_id IN NUMBER) IS
      SELECT set_type_id, set_number
      FROM CS_KB_SETS_B
      WHERE set_id = c_set_id;

    l_soln_number VARCHAR2(30);
    l_type_id NUMBER;
    l_data VARCHAR2(2000);
    l_amt BINARY_INTEGER;
    l_newline VARCHAR2(4) := fnd_global.newline;
  BEGIN

    OPEN c2(p_solution_id);
    FETCH c2 INTO l_type_id, l_soln_number;
    CLOSE c2;

    -- write solution type id
    l_data := l_newline||'<TYPE>a' || TO_CHAR(l_type_id) || 'a</TYPE> ';
    l_amt := LENGTH(l_data);
    dbms_lob.writeappend(p_clob, l_amt, l_data);

    -- write language code
    l_data := l_newline||'<LANG>a'|| p_lang ||'a</LANG>';
    l_amt := LENGTH(l_data);
    dbms_lob.writeappend(p_clob, l_amt, l_data);

    -- write solution number
    l_data := l_newline||'<NUMBER>a' || l_soln_number || 'a</NUMBER>';
    l_amt := LENGTH(l_data);
    dbms_lob.writeappend(p_clob, l_amt, l_data);

  END Write_Soln_Header_Sect_Hlp;

--Start 12.1.3
      PROCEDURE Write_Soln_Attach_Cont_Hlp
  ( p_solution_id IN     NUMBER,
    p_lang        IN     VARCHAR2,
    p_clob        IN OUT NOCOPY CLOB,
    p_temp_clob   IN OUT NOCOPY CLOB)
  IS
/*    CURSOR c1(c_setid IN NUMBER, c_lang IN VARCHAR2) IS
      SELECT	fdtl.title, fdtl.description, fl.file_name, fl.file_data
	  FROM 	fnd_attached_documents fad,
		fnd_documents fd,
		fnd_documents_tl fdtl,
                fnd_lobs fl
	  WHERE	fad.document_id = fd.document_id
            AND fd.document_id = fdtl.document_id
            AND fl.file_id = fd.media_id
	    AND fdtl.language  = c_lang
	    AND fad.entity_name = 'CS_KB_SETS_B'
	    AND fad.pk1_value = c_setid; */
-- Changed the cursor for bug 8815880
    CURSOR c1(c_setid IN NUMBER, c_lang IN VARCHAR2) IS
      SELECT fdtl.title, fdtl.description, fl.file_name,  fl.file_data, fd.url, fst.short_text
      FROM fnd_attached_documents fad,
           fnd_documents fd,
           fnd_documents_tl fdtl,
           fnd_lobs fl,
           fnd_documents_short_text fst
      WHERE fad.document_id = fd.document_id
      AND fd.document_id = fdtl.document_id
      AND fl.file_id(+) = fd.media_id
      AND fst.media_id(+) = fd.media_id
      AND fdtl.LANGUAGE = c_lang
      AND fad.entity_name = 'CS_KB_SETS_B'
      AND fad.pk1_value = c_setid;

    rec1 c1%ROWTYPE;
    l_data VARCHAR2(32000);
    l_amt BINARY_INTEGER;
    l_clob CLOB := NULL;
    l_clob_len NUMBER;
    p_clob_len NUMBER;
    src_blob BLOB := null;
    amount INTEGER := dbms_lob.lobmaxsize;
    dest_offset INTEGER :=1;
    src_offset  INTEGER :=1;
    blob_csid  NUMBER := dbms_lob.default_csid;
    lang_context  INTEGER := dbms_lob.default_lang_ctx;
    warning  INTEGER;
    blob_length INTEGER;
    l_newline VARCHAR2(4) := fnd_global.newline;

  BEGIN
    -- For each Statement linked to the solution header,
    -- write all of the Statement content (summary, description)
    -- into the clob.
    dbms_lob.createtemporary(l_clob, TRUE, dbms_lob.call);

    -- Clear out the output CLOB buffer
    dbms_lob.trim(l_clob, 0);


     IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'cs.plsql.cskbdstb.pls',
                         'Inside Write_Soln_Attach_Cont_Hlp- ');
        END IF;
    FOR rec1 IN c1(p_solution_id, p_lang) LOOP

      -- Write the statement summary to clob
      l_data := l_newline||rec1.title||l_newline||rec1.description||l_newline||rec1.file_name||l_newline||rec1.url||l_newline||rec1.short_text||l_newline;
      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'cs.plsql.cskbdstb.pls',
                         'Before  Remove_Tags-l_data:  || l_data');
        END IF;
      l_data := Remove_Tags(l_data); --, p_temp_clob);
      l_amt := LENGTH(l_data);

      IF(l_amt>0) THEN
        dbms_lob.writeappend(p_clob, l_amt, l_data);
      END IF;

      -- Write the statement description to clob
      blob_length := DBMS_LOB.GETLENGTH(rec1.file_data); --Bug 8815880
      If blob_length is not null then
	      src_blob := rec1.file_data;
	      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'cs.plsql.cskbdstb.pls',
				 'Before dbms_lob.converttoclob- src_blob :  || src_blob');
		END IF;
	      dbms_lob.converttoclob(l_clob ,src_blob, amount, dest_offset, src_offset, blob_csid,lang_context, warning);
	      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
		   FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'cs.plsql.cskbdstb.pls',
				 'After dbms_lob.converttoclob- l_clob : || l_clob' );
		END IF;

	      IF (l_clob IS NOT NULL AND dbms_lob.getlength(l_clob) > 0)
	      THEN
		l_clob := Remove_Tags_Clob(l_clob, p_temp_clob);
		l_clob_len := dbms_lob.getlength(l_clob);
		p_clob_len := dbms_lob.getlength(p_clob);
		dbms_lob.copy(p_clob, l_clob, l_clob_len, p_clob_len+1, 1);
	      END IF;
	      dbms_lob.trim(l_clob, 0);
	      src_offset := 1;
      End If;
    END LOOP;
  END Write_Soln_Attach_Cont_Hlp;

  PROCEDURE Write_Soln_Attach_Sect_Hlp
  ( p_solution_id IN     NUMBER,
    p_clob        IN OUT NOCOPY CLOB)
  IS
    CURSOR c1(c_setid IN NUMBER) IS
    /*  (perf11510): functional fix
      select se.element_id
      from CS_KB_SET_ELES se
      where se.set_id = c_setid;
    */
      SELECT fad.document_id
	FROM fnd_attached_documents fad,
	fnd_documents fd
	WHERE fad.document_id = fd.document_id
	AND fad.entity_name = 'CS_KB_SETS_B'
	AND fad.pk1_value = c_setid;
    l_data VARCHAR2(32000);
    l_amt BINARY_INTEGER;
    l_setid NUMBER;
    l_lang VARCHAR2(4);
    rec1 c1%ROWTYPE;
    l_newline VARCHAR2(4) := fnd_global.newline;
  BEGIN
    -- Write out statement Section to statements section
    l_data := l_newline||'<ATTACHMENTS>';
    l_amt := LENGTH(l_data);
    dbms_lob.writeappend(p_clob, l_amt, l_data);

    l_data := '';
    l_amt := 0;
    FOR rec1 IN c1(p_solution_id) LOOP
        l_data := l_data || ' a' || rec1.document_id || 'a ';
    END LOOP;

    l_amt := LENGTH(l_data);
    IF ( l_amt > 0 )
    THEN
      dbms_lob.writeappend(p_clob, l_amt, l_data);
    END IF;

    l_data := '</ATTACHMENTS>';
    l_amt := LENGTH(l_data);
    dbms_lob.writeappend(p_clob, l_amt, l_data);
  END Write_Soln_Attach_Sect_Hlp;

  --End 12.1.3

  PROCEDURE Write_Soln_Category_Sect_Hlp
  ( p_solution_id IN     NUMBER,
    p_clob        IN OUT NOCOPY CLOB)
  IS
    CURSOR c5(c_set_id IN NUMBER) IS
      SELECT DISTINCT category_id
      FROM CS_KB_SOLN_CATEGORIES_B
      START WITH category_id IN
      (
        SELECT category_id
        FROM cs_kb_set_categories
        WHERE set_id = c_set_id
      )
      CONNECT BY PRIOR parent_category_id = category_id;

    l_data VARCHAR2(32000);
    l_amt BINARY_INTEGER;
    l_category_id NUMBER;
    l_newline VARCHAR2(4) := fnd_global.newline;
  BEGIN
    -- write category section

    l_data := l_newline||'<CATEGORIES>';
    l_amt := LENGTH(l_data);
    dbms_lob.writeappend(p_clob, l_amt, l_data);

    l_data := '';
    l_amt := 0;

    FOR rec5 IN c5(p_solution_id) LOOP
      l_category_id := rec5.category_id;
      l_data := l_data || l_newline || ' a' || TO_CHAR(l_category_id) || 'a ';
    END LOOP;

    l_amt := LENGTH(l_data);
    IF ( l_amt > 0 )
    THEN
      dbms_lob.writeappend(p_clob, l_amt, l_data);
    END IF;

    l_data := '</CATEGORIES>';
    l_amt := LENGTH(l_data);
    dbms_lob.writeappend(p_clob, l_amt, l_data);
  END Write_Soln_Category_Sect_Hlp;



  PROCEDURE Write_Soln_Product_Cont_Hlp
  ( p_solution_id IN     NUMBER,
    p_lang        IN     VARCHAR2,
    p_clob        IN OUT NOCOPY CLOB,
    p_temp_clob   IN OUT NOCOPY CLOB)
  IS
    CURSOR c6(c_set_id IN NUMBER, c_lang IN VARCHAR2) IS
      SELECT b.segment1 name,t.description
      FROM mtl_system_items_b b, mtl_system_items_tl t, cs_kb_set_products s
      WHERE t.inventory_item_id = s.product_id
      AND t.organization_id   = s.product_org_id
      AND b.inventory_item_id = s.product_id
      AND b.organization_id   = s.product_org_id
      AND t.LANGUAGE = c_lang
      AND s.set_id = c_set_id;
    l_data VARCHAR2(32000);
    l_amt BINARY_INTEGER;
    l_newline VARCHAR2(4) := fnd_global.newline;
  BEGIN
    --write product name and description to clob
    l_data := '';
    l_amt := 0;

    FOR rec6 IN c6(p_solution_id, p_lang) LOOP
      l_data := l_data||l_newline||rec6.name||' '||rec6.description;
    END LOOP;

    l_data := Remove_Tags(l_data); --, p_temp_clob);

    l_amt := LENGTH(l_data);
    IF ( l_amt > 0 )
    THEN
      dbms_lob.writeappend(p_clob, l_amt, l_data);
    END IF;

  END Write_Soln_Product_Cont_Hlp;


  PROCEDURE Write_Soln_Product_Sect_Hlp
  ( p_solution_id IN     NUMBER,
    p_clob        IN OUT NOCOPY CLOB)
  IS
    CURSOR c3(c_set_id IN NUMBER) IS
      SELECT product_id, product_org_id
      FROM CS_KB_SET_PRODUCTS
      WHERE set_id = c_set_id;
    l_data VARCHAR2(32000);
    l_amt BINARY_INTEGER;
    l_setid NUMBER;
    l_product_id NUMBER;
    l_product_org_id NUMBER;
    rec3 c3%ROWTYPE;
    l_newline VARCHAR2(4) := fnd_global.newline;
  BEGIN
    -- write the start product section info

    l_data := l_newline||'<PRODUCTS>';
    l_amt := LENGTH(l_data);
    dbms_lob.writeappend(p_clob, l_amt, l_data);

    l_data := '';
    l_amt := 0;
    FOR rec3 IN c3(p_solution_id) LOOP
      l_product_id := rec3.product_id;
      l_product_org_id := rec3.product_org_id;

      l_data := l_data||l_newline||' a'||TO_CHAR(l_product_id)||'a ';
    END LOOP;

    l_amt := LENGTH(l_data);
    IF ( l_amt > 0 )
    THEN
      dbms_lob.writeappend(p_clob, l_amt, l_data);
    ELSE
      l_data := 'a000a';
      dbms_lob.writeappend(p_clob, 5, l_data);
    END IF;

    l_data := '</PRODUCTS>';
    l_amt := LENGTH(l_data);
    dbms_lob.writeappend(p_clob, l_amt, l_data);
  END Write_Soln_Product_Sect_Hlp;



  PROCEDURE Write_Soln_Platform_Cont_Hlp
  ( p_solution_id IN     NUMBER,
    p_lang        IN     VARCHAR2,
    p_clob        IN OUT NOCOPY CLOB,
    p_temp_clob   IN OUT NOCOPY CLOB)
  IS
    CURSOR c7(c_set_id IN NUMBER, c_lang IN VARCHAR2) IS
      SELECT b.segment1 name,t.description
      FROM mtl_system_items_b b, mtl_system_items_tl t, cs_kb_set_platforms s
      WHERE t.inventory_item_id = s.platform_id
      AND t.organization_id   = s.platform_org_id
      AND b.inventory_item_id = s.platform_id
      AND b.organization_id   = s.platform_org_id
      AND t.LANGUAGE = c_lang
      AND s.set_id = c_set_id;
    l_data VARCHAR2(32000);
    l_amt BINARY_INTEGER;
    l_newline VARCHAR2(4) := fnd_global.newline;
  BEGIN
    --write platform name and description to clob
    l_data := '';
    l_amt := 0;
    FOR rec7 IN c7(p_solution_id, p_lang) LOOP
      l_data := l_data||l_newline||rec7.name||' '||rec7.description;
    END LOOP;

    l_data := Remove_Tags(l_data); --, p_temp_clob);

    l_amt := LENGTH(l_data);
    IF ( l_amt > 0 )
    THEN
      dbms_lob.writeappend(p_clob, l_amt, l_data);
    END IF;
  END Write_Soln_Platform_Cont_Hlp;


  PROCEDURE Write_Soln_Platform_Sect_Hlp
  ( p_solution_id IN     NUMBER,
    p_clob        IN OUT NOCOPY CLOB)
  IS
    CURSOR c4(c_set_id IN NUMBER) IS
      SELECT platform_id, platform_org_id
      FROM CS_KB_SET_PLATFORMS
      WHERE set_id = c_set_id;
    l_data VARCHAR2(32000);
    l_amt BINARY_INTEGER;
    l_platform_id NUMBER;
    l_platform_org_id NUMBER;
    rec4 c4%ROWTYPE;
    l_newline VARCHAR2(4) := fnd_global.newline;
  BEGIN
    -- write the start platform section info

    l_data := l_newline||'<PLATFORMS>';
    l_amt := LENGTH(l_data);
    dbms_lob.writeappend(p_clob, l_amt, l_data);

    l_data := '';
    l_amt := 0;

    FOR rec4 IN c4(p_solution_id) LOOP
      l_platform_id := rec4.platform_id;
      l_platform_org_id := rec4.platform_org_id;

      l_data := l_data||' a'||TO_CHAR(l_platform_id) ||'a ';
    END LOOP;

    l_amt := LENGTH(l_data);
    IF ( l_amt > 0 )
    THEN
      dbms_lob.writeappend(p_clob, l_amt, l_data);
    ELSE
      l_data := 'a000a';
      dbms_lob.writeappend(p_clob, 5, l_data);
    END IF;

    l_data := '</PLATFORMS>';
    l_amt := LENGTH(l_data);
    dbms_lob.writeappend(p_clob, l_amt, l_data);
  END Write_Soln_Platform_Sect_Hlp;


  PROCEDURE Write_Soln_CatGrp_Sect_Hlp
  ( p_solution_id IN     NUMBER,
    p_clob        IN OUT NOCOPY CLOB)
  IS
    CURSOR c4(c_set_id IN NUMBER) IS
      SELECT UNIQUE b.category_group_id
      FROM cs_kb_set_categories a, CS_KB_CAT_GROUP_DENORM b
      WHERE a.category_id = b.child_category_id
      AND a.set_id = c_set_id;

    CURSOR c5(c_position IN NUMBER) IS
      SELECT visibility_id FROM cs_kb_visibilities_b
			-- (secure) klou
      WHERE position <= c_position
			ORDER BY visibility_id;

    l_data VARCHAR2(32000);
    l_amt BINARY_INTEGER;
    l_max_cat_vis NUMBER;
    l_soln_vis NUMBER;
    l_vis NUMBER;
    rec4 c4%ROWTYPE;
    rec5 c5%ROWTYPE;
    l_newline VARCHAR2(4) := fnd_global.newline;
  BEGIN
    -- write the start category group section info

    l_data := l_newline||'<CATEGORYGROUPS>';
    l_amt := LENGTH(l_data);
    dbms_lob.writeappend(p_clob, l_amt, l_data);

    l_data := '';
    l_amt := 0;

    FOR rec4 IN c4(p_solution_id) LOOP
      SELECT MAX(b.visibility_position)
      INTO l_max_cat_vis
      FROM cs_kb_set_categories a, CS_KB_CAT_GROUP_DENORM b
      WHERE a.category_id = b.child_category_id
      AND b.category_group_id = rec4.category_group_id
      AND a.set_id = p_solution_id;

      SELECT b.position
      INTO l_soln_vis
      FROM cs_kb_sets_b a, cs_kb_visibilities_b b
      WHERE a.visibility_id = b.visibility_id
      AND a.set_id = p_solution_id;

      IF l_soln_vis < l_max_cat_vis THEN
        l_vis := l_soln_vis;
      ELSE
        l_vis := l_max_cat_vis;
      END IF;

      FOR rec5 IN c5(l_vis) LOOP
        l_data := l_data||' '||TO_CHAR(rec4.category_group_id)||'a' ||TO_CHAR(rec5.visibility_id)||' ';
      END LOOP;
    END LOOP;

    l_amt := LENGTH(l_data);
    IF ( l_amt > 0 )
    THEN
      dbms_lob.writeappend(p_clob, l_amt, l_data);
    END IF;

    l_data := '</CATEGORYGROUPS>';
    l_amt := LENGTH(l_data);
    dbms_lob.writeappend(p_clob, l_amt, l_data);
  END Write_Soln_CatGrp_Sect_Hlp;


  PROCEDURE Write_Soln_Statement_Cont_Hlp
  ( p_solution_id IN     NUMBER,
    p_lang        IN     VARCHAR2,
    p_clob        IN OUT NOCOPY CLOB,
    p_temp_clob   IN OUT NOCOPY CLOB)
  IS
    CURSOR c1(c_setid IN NUMBER, c_lang IN VARCHAR2) IS
      SELECT et.name, et.description, eb.element_id, eb.element_number
      FROM CS_KB_ELEMENTS_B eb,
           CS_KB_ELEMENTS_TL et,
           CS_KB_SET_ELES se
      WHERE se.set_id = c_setid
      AND eb.element_id = se.element_id
      AND eb.element_id = et.element_id
      AND eb.status = 'PUBLISHED' --- added 03/16/2004
      AND et.LANGUAGE = c_lang;
    rec1 c1%ROWTYPE;
    l_data VARCHAR2(32000);
    l_amt BINARY_INTEGER;
    l_clob CLOB := NULL;
    l_clob_len NUMBER;
    p_clob_len NUMBER;
    l_newline VARCHAR2(4) := fnd_global.newline;
  BEGIN
    -- For each Statement linked to the solution header,
    -- write all of the Statement content (summary, description)
    -- into the clob.
    FOR rec1 IN c1(p_solution_id, p_lang) LOOP

      -- Write the statement summary to clob
      l_data := l_newline||rec1.name||l_newline;
      l_data := Remove_Tags(l_data); --, p_temp_clob);
      l_amt := LENGTH(l_data);

      IF(l_amt>0) THEN
        dbms_lob.writeappend(p_clob, l_amt, l_data);
      END IF;

      -- Write the statement description to clob
      l_clob := rec1.description;

      IF (l_clob IS NOT NULL AND dbms_lob.getlength(l_clob) > 0)
      THEN
        l_clob := Remove_Tags_Clob(l_clob, p_temp_clob);
        l_clob_len := dbms_lob.getlength(l_clob);
        p_clob_len := dbms_lob.getlength(p_clob);
        dbms_lob.copy(p_clob, l_clob, l_clob_len, p_clob_len+1, 1);
      END IF;
    END LOOP;
  END Write_Soln_Statement_Cont_Hlp;

  PROCEDURE Write_Soln_Statement_Sect_Hlp
  ( p_solution_id IN     NUMBER,
    p_clob        IN OUT NOCOPY CLOB)
  IS
    CURSOR c1(c_setid IN NUMBER) IS
    /*  (perf11510): functional fix
      select se.element_id
      from CS_KB_SET_ELES se
      where se.set_id = c_setid;
    */
      SELECT se.element_id
      FROM CS_KB_SET_ELES se,
           cs_kb_elements_b sb
      WHERE se.set_id = c_setid
      AND sb.element_id = se.element_id
      AND sb.status = 'PUBLISHED';
    l_data VARCHAR2(32000);
    l_amt BINARY_INTEGER;
    l_setid NUMBER;
    l_lang VARCHAR2(4);
    rec1 c1%ROWTYPE;
    l_newline VARCHAR2(4) := fnd_global.newline;
  BEGIN
    -- Write out statement Section to statements section
    l_data := l_newline||'<STATEMENTS>';
    l_amt := LENGTH(l_data);
    dbms_lob.writeappend(p_clob, l_amt, l_data);

    l_data := '';
    l_amt := 0;
    FOR rec1 IN c1(p_solution_id) LOOP
      FOR i IN 1..10 LOOP
        l_data := l_data || ' a' || rec1.element_id || 'a ';
      END LOOP;
    END LOOP;

    l_amt := LENGTH(l_data);
    IF ( l_amt > 0 )
    THEN
      dbms_lob.writeappend(p_clob, l_amt, l_data);
    END IF;

    l_data := '</STATEMENTS>';
    l_amt := LENGTH(l_data);
    dbms_lob.writeappend(p_clob, l_amt, l_data);
  END Write_Soln_Statement_Sect_Hlp;

  PROCEDURE Write_Stmt_Header_Cont_Hlp
  ( p_statement_id IN     NUMBER,
    p_lang         IN     VARCHAR2,
    p_clob         IN OUT NOCOPY CLOB,
    p_temp_clob   IN OUT NOCOPY CLOB,
    p_statement_number IN VARCHAR2,
    p_name IN VARCHAR2,
    p_description IN CLOB)

  IS
-- Bug 3455203 - Perf Changes:
-- Name and Desc now passed as params to api
--    cursor c1(c_element_id in number, c_lang in varchar2) is
--      select b.element_number, tl.name, tl.description
--      from cs_kb_elements_tl tl, cs_kb_elements_b b
--      where tl.element_id = c_element_id
--        and tl.language = c_lang
--        and tl.element_id = b.element_id;
 --   rec1 c1%ROWTYPE;
    l_data VARCHAR2(2000);
    l_amt BINARY_INTEGER;
    l_newline VARCHAR2(4) := fnd_global.newline;
--    l_statement_number varchar2(30);
--    l_name varchar2(2000);
    l_description CLOB := NULL;
    l_clob_len NUMBER;
    p_clob_len NUMBER;
  BEGIN
    -- Fetch Statement summary and description
--    open c1( p_statement_id, p_lang);
--    fetch c1 into  l_statement_number, l_name, l_description;
--    close c1;

    -- Write the statement number and summary to clob
    l_data := l_newline||p_statement_number||' '||p_name||l_newline;
    l_data := Remove_Tags(l_data); --, p_temp_clob);
    l_amt := LENGTH(l_data);
    dbms_lob.writeappend(p_clob, l_amt, l_data);

    -- write statement description into clob
    l_description := p_description;
    IF (l_description IS NOT NULL AND dbms_lob.getlength(l_description) > 0)
    THEN
      l_description := Remove_Tags_Clob(l_description, p_temp_clob);
      l_clob_len := dbms_lob.getlength(l_description);
      p_clob_len := dbms_lob.getlength(p_clob);
      dbms_lob.copy(p_clob, l_description, l_clob_len, p_clob_len+1, 1);
    END IF;
  END Write_Stmt_Header_Cont_Hlp;


  PROCEDURE Write_Stmt_Header_Sect_Hlp
  ( p_statement_id IN     NUMBER,
    p_lang         IN     VARCHAR2,
    p_clob         IN OUT NOCOPY CLOB,
    p_statement_number IN VARCHAR2,
    p_type_id          IN NUMBER,
    p_access_level     IN NUMBER)
  IS
-- Bug 3455203 - Perf Changes:
-- Type and Number now passed as params to api
--    cursor c1(c_element_id in number) is
--      select element_type_id, element_number
--      from cs_kb_elements_b
--      where element_id = c_element_id;
    --rec1 c1%ROWTYPE;
    l_data VARCHAR2(2000);
    l_amt BINARY_INTEGER;
    --l_type_id number;
    l_newline VARCHAR2(4) := fnd_global.newline;
    --l_statement_number varchar(30);

    -- Add access level section
    CURSOR access_levels_csr IS --(p_element_id in NUMBER) is
    SELECT lookup_code
    FROM cs_lookups
    WHERE lookup_type = 'CS_KB_ACCESS_LEVEL'
    AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date_active, SYSDATE))
    AND TRUNC(NVL(end_date_active, SYSDATE))
    AND TO_NUMBER(lookup_code) <= p_access_level;

    l_access_level access_levels_csr%ROWTYPE;

  BEGIN
    -- Fetch Statement type info
--    open c1( p_statement_id );
--    fetch c1 into l_type_id, l_statement_number;
--    close c1;

    --write statement type and language section data into clob.
    l_data := l_newline||'<NUMBER>a' || p_statement_number || 'a</NUMBER>'||
              l_newline||'<TYPE>a'||TO_CHAR(p_type_id)||'a</TYPE>'||
              l_newline||'<LANG>a'||p_lang||'a</LANG>'
           --3341248
            ||l_newline||'<STATEMENTID>a'||p_statement_id||'a</STATEMENTID>'
             ;
           --end 3341248

    -- Add access level
    l_data := l_data || l_newline||'<ACCESS> ';
    FOR l_access_level IN access_levels_csr --(p_statement_id)
    LOOP
       l_data := l_data||'a'||l_access_level.lookup_code||'a'||' ';
    END LOOP;
    l_data := l_data ||'</ACCESS>';


    l_amt := LENGTH(l_data);
    IF(l_amt>0) THEN
      dbms_lob.writeappend(p_clob, l_amt, l_data);
    END IF;
  END Write_Stmt_Header_Sect_Hlp;

  PROCEDURE Write_Stmt_CatGrp_Sect_Hlp
  ( p_statement_id IN     NUMBER,
    p_clob         IN OUT NOCOPY CLOB)
  IS

    -- Bug 3455203 - Perf Changes:
    -- Restrict on PUB

    CURSOR c4(c_element_id IN NUMBER) IS
      SELECT UNIQUE b.category_group_id
      FROM cs_kb_set_categories a,
           CS_KB_CAT_GROUP_DENORM b,
           cs_kb_set_eles c ,
           cs_kb_sets_b d
      WHERE a.category_id = b.child_category_id
      AND a.set_id = c.set_id
      AND d.status = 'PUB'
      AND c.set_id = d.set_id
      AND c.element_id = c_element_id;

    CURSOR c5(c_position IN NUMBER) IS
      SELECT visibility_id FROM cs_kb_visibilities_b
			-- (secure) klou
      WHERE position <= c_position
      ORDER BY visibility_id;

    -- Bug 3455203 - Perf Changes:
    -- Restrict on PUB
    CURSOR c6(c_element_id IN NUMBER) IS
      SELECT s.set_id, v.position
      FROM cs_kb_set_eles se,
           cs_kb_Sets_B s,
           cs_kb_visibilities_b v
      WHERE se.element_id = c_element_id
      AND   se.set_id = s.set_id
      AND   s.status = 'PUB'
      AND   s.visibility_id = v.visibility_id;


    l_data VARCHAR2(32000);
    l_amt BINARY_INTEGER;
    l_max_cat_vis NUMBER;
    l_soln_vis NUMBER;
    l_vis NUMBER;
    l_max_vis NUMBER;
    rec4 c4%ROWTYPE;
    rec5 c5%ROWTYPE;
    rec6 c6%ROWTYPE;
    l_newline VARCHAR2(4) := fnd_global.newline;

    -- perf11510
    CURSOR max_vis_pos_csr (p_statement_id NUMBER,
                            p_set_id       NUMBER,
                            p_cat_group_id NUMBER)
     IS
    SELECT NVL(MAX(b.visibility_position), -1)
      FROM cs_kb_set_categories a,
             CS_KB_CAT_GROUP_DENORM b,
             cs_kb_set_eles c
	    WHERE a.category_id = b.child_category_id
        AND a.set_id = c.set_id
	    AND a.set_id = p_set_id --rec6.set_id
	    AND b.category_group_id = p_cat_group_id --rec4.category_group_id
	    AND c.element_id = p_statement_id;

   /* 336469: For 8.1.7 compatibility
    Type t_set_pos_tbl Is Table Of c6%ROWTYPE
      Index By Binary_Integer;

    l_set_pos  t_set_pos_tbl;
   */
    TYPE list_num IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    l_set_pos  list_num;
    l_set_ids  list_num;

  BEGIN
    -- write the start category group section info

    l_data := l_newline||'<CATEGORYGROUPS>';
    l_amt := LENGTH(l_data);
    dbms_lob.writeappend(p_clob, l_amt, l_data);

    l_data := '';
    l_amt := 0;

    l_vis := -1;
    l_max_vis := -1;

    -- perf11510
    OPEN c6(p_statement_id);
    --336469: For 8.1.7 compatibility
    --Fetch c6 BULK COLLECT Into l_set_pos;
    FETCH c6 BULK COLLECT INTO l_set_ids, l_set_pos;
    CLOSE c6;
    -- end perf11510

    FOR rec4 IN c4(p_statement_id) LOOP

      -- perf11510
      -- for rec6 in c6(p_statement_id) loop
     FOR i IN l_set_pos.FIRST..l_set_pos.LAST LOOP


      OPEN max_vis_pos_csr(p_statement_id,
                           --336469 l_set_pos(i).set_id,
                           l_set_ids(i),
                           rec4.category_group_id);
      FETCH max_vis_pos_csr INTO l_max_cat_vis;
      CLOSE max_vis_pos_csr;

        -- Bug 3455203 - Perf Changes:
        -- Posn now retrieved via c6 cursor
        --        select b.position
        --        into l_soln_vis
        --        from cs_kb_sets_b a, cs_kb_visibilities_b b
        --        where a.visibility_id = b.visibility_id
        --        and a.set_id = rec6.set_id;

        -- perf11510
       IF l_max_cat_vis > 0 THEN
          l_soln_vis :=  l_set_pos(i); --336469 l_set_pos(i).position;

          IF l_soln_vis < l_max_cat_vis THEN
            l_vis := l_soln_vis;
          ELSE
            l_vis := l_max_cat_vis;
          END IF;

          IF l_max_vis < l_vis THEN
            l_max_vis := l_vis;
          END IF;
       END IF; -- end l_max_cat_vis check
      END LOOP; -- end l_set_pos loop

      FOR rec5 IN c5(l_max_vis) LOOP
        l_data := l_data||' '||TO_CHAR(rec4.category_group_id)||'a' ||TO_CHAR(rec5.visibility_id)||' ';
      END LOOP;

      -- reset for each cg in loop
      l_max_vis := -1;

    END LOOP;

    l_amt := LENGTH(l_data);
    IF ( l_amt > 0 )
    THEN
      dbms_lob.writeappend(p_clob, l_amt, l_data);
    END IF;

    l_data := '</CATEGORYGROUPS>';
    l_amt := LENGTH(l_data);
    dbms_lob.writeappend(p_clob, l_amt, l_data);
  END Write_Stmt_CatGrp_Sect_Hlp;

   /*
     Remove_Tags:
       - replaces all occurrences of '<' with '!'
       p_text: the original varchar
       returns: the modified varchar
   */
  FUNCTION Remove_Tags
  ( p_text IN VARCHAR2)
  RETURN VARCHAR2
  IS
  BEGIN
    RETURN REPLACE(p_text, '<', '!');
  END Remove_Tags;

  /*
     Remove_Tags_Clob:
       - replaces all occurrences of '<' with '!'
       p_clob: the original data
       p_temp_clob: if necessary, modified data is stored here
       returns: pointer to either p_clob or p_temp_clob
   */
  FUNCTION Remove_Tags_Clob
  ( p_clob        IN CLOB,
    p_temp_clob   IN OUT NOCOPY CLOB
  )
  RETURN CLOB
  IS
  l_len NUMBER;
  l_idx NUMBER;
  BEGIN
    --can't use, 8.1.7 does not support CLOB replace
    --p_clob := replace(p_clob, '<', '!');

    l_idx := dbms_lob.INSTR(p_clob, '<', 1);
    IF(l_idx IS NOT NULL AND l_idx > 0) THEN
        -- '<' found, so need to copy original into temp clob
        -- Clear out the temp clob buffer
        dbms_lob.trim(p_temp_clob, 0);
        -- Copy original data into temporary clob
        l_len := dbms_lob.getlength(p_clob);
        dbms_lob.copy(p_temp_clob, p_clob, l_len, 1, 1);
    ELSE
        -- no '<' found, so just return the original
        RETURN p_clob;
    END IF;

    --assert: there is at least one '<' in p_clob,
    --assert: l_idx contains the position of the first '<'
    --assert: p_temp_clob is a copy of p_clob.

    --Now replace all '<' with '!' in p_temp_clob
    --and return p_temp_clob

    WHILE(l_idx IS NOT NULL AND l_idx > 0) LOOP
      dbms_lob.WRITE(p_temp_clob, 1, l_idx, '!');
      l_idx := dbms_lob.INSTR(p_temp_clob, '<', l_idx);
    END LOOP;

    RETURN p_temp_clob;

 END Remove_Tags_Clob;

   -- 3341248
  PROCEDURE Write_Related_Stmt_Sect_Hlp
  ( p_statement_id IN     NUMBER,
    p_clob         IN OUT NOCOPY CLOB)
  IS
    CURSOR get_all_stmts(p_element_id IN NUMBER) IS
	SELECT a.element_id
	FROM cs_kb_set_eles a
	WHERE a.element_id <> p_element_id --:b1
	AND   a.set_id IN (
	SELECT s.set_id
	FROM cs_kb_set_eles se,
	     cs_kb_sets_b s
	WHERE se.element_id = p_element_id
	AND se.set_id = s.set_id
	AND s.status = 'PUB');
	--     select a.element_id
	--     from cs_kb_set_eles a, cs_kb_set_eles b, cs_kb_sets_b c
	--     where b.set_id = a.set_id
	--     and  a.set_id = c.set_id
	--     and c.status = 'PUB'
	--     and b.element_id = p_element_id
	--     and a.element_id <> p_element_id;


    l_data VARCHAR2(32000);
    l_amt BINARY_INTEGER;

    l_newline VARCHAR2(4) := fnd_global.newline;

    ROWS NATURAL := 30000;
    TYPE list_ids IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    l_ele_ids list_ids;

    l_cnt NUMBER := 0;
  BEGIN

    l_data := l_newline||'<RELATEDSTMTS>';
    l_amt := LENGTH(l_data);
    dbms_lob.writeappend(p_clob, l_amt, l_data);
    l_data := '';

    OPEN get_all_stmts(p_statement_id);
    LOOP
      FETCH get_all_stmts BULK COLLECT INTO l_ele_ids LIMIT ROWS;
      EXIT WHEN get_all_stmts%NOTFOUND;

      FOR i IN l_ele_ids.FIRST..l_ele_ids.LAST
      LOOP
        l_data := l_data||' '||TO_CHAR(l_ele_ids(i));

        l_cnt := l_cnt + 1;

        -- Assume that each element_id is 15 digits, we need
        -- to flush the l_data every 2000 elements.
        -- The 15 digits assumption is very conservative, most
        -- of the time it uses only up to 7 digits.
        IF l_cnt >= 2000 THEN
          l_cnt := 0;
          l_amt := LENGTH(l_data);
          dbms_lob.writeappend(p_clob, l_amt, l_data);
          l_data := '';
        END IF;
      END LOOP;

    END LOOP;
   CLOSE get_all_stmts;

    -- Process the last batch.
    -- Why is this needed? This is because when the number of
    -- rows in the cursor is less than the LIMIT rows. Oracle
    -- does a bulk collect and then set the cursor%notfound
    -- to true. That's why the last batch will not be processed
    -- inside the loop.
   l_cnt := 0;
   IF l_ele_ids.COUNT > 0 THEN
    FOR i IN l_ele_ids.FIRST..l_ele_ids.LAST
      LOOP
        l_data := l_data||' '||TO_CHAR(l_ele_ids(i));
        l_cnt := l_cnt + 1;
        -- Assume that each element_id is 15 digits, we need
        -- to flush the l_data every 2000 elements.
        -- The 15 digits assumption is very conservative, most
        -- of the time it uses only up to 7 digits.
        IF l_cnt >= 2000 THEN
          l_cnt := 0;
          l_amt := LENGTH(l_data);
          dbms_lob.writeappend(p_clob, l_amt, l_data);
          l_data := '';
        END IF;
      END LOOP;
   END IF;

    l_data := l_data||'</RELATEDSTMTS>';
    l_amt := LENGTH(l_data);
    dbms_lob.writeappend(p_clob, l_amt, l_data);
  END Write_Related_Stmt_Sect_Hlp;


END cs_kb_ctx_pkg;

/

  GRANT EXECUTE ON "APPS"."CS_KB_CTX_PKG" TO "CTXSYS";
  GRANT EXECUTE ON "APPS"."CS_KB_CTX_PKG" TO "CS";
