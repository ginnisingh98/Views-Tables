--------------------------------------------------------
--  DDL for Package Body RG_XBRL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RG_XBRL_PKG" AS
/* $Header: rgxbrlpb.pls 120.1 2004/08/19 00:16:58 vtreiger noship $ */
--
-- Wrappers
--
PROCEDURE Upload_taxonomy(errbuf	OUT NOCOPY VARCHAR2,
		          retcode	OUT NOCOPY VARCHAR2,
		          p_full_tax_name IN VARCHAR2,
		          p_tax_file_name IN VARCHAR2,
		          p_tax_descr     IN VARCHAR2) IS
BEGIN
  --
  RG_XBRL_PKG.load_taxonomy(p_full_tax_name	=> p_full_tax_name,
			    p_tax_file_name	=> p_tax_file_name,
			    p_tax_descr         => p_tax_descr);
  --
  EXCEPTION
    WHEN OTHERS THEN
      errbuf := SQLERRM;
      retcode := '2';
      --app_exception.raise_exception;
END Upload_taxonomy;
--
--
--
PROCEDURE Remove_taxonomy(errbuf	OUT NOCOPY VARCHAR2,
		          retcode	OUT NOCOPY VARCHAR2,
		          p_full_tax_name IN VARCHAR2) IS
BEGIN
  --
  RG_XBRL_PKG.delete_taxonomy(p_full_tax_name	=> p_full_tax_name);
  --
  EXCEPTION
    WHEN OTHERS THEN
      errbuf := SQLERRM;
      retcode := '2';
      --app_exception.raise_exception;
END Remove_taxonomy;
--
-- Regular procedures
--
PROCEDURE delete_taxonomy(p_full_tax_name IN VARCHAR2)
IS
p_taxonomy_id NUMBER(15) := 0;
l_axis_set_id NUMBER(15) := 0;
l_parent_flag NUMBER(15) := 0;
Remove_tax_err EXCEPTION;
BEGIN
  BEGIN
    SELECT taxonomy_id
    INTO p_taxonomy_id
    FROM RG_XBRL_TAXONOMIES
    WHERE taxonomy_name = p_full_tax_name AND
      ROWNUM = 1;
      EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
          p_taxonomy_id := 0;
  END;
  --
  IF p_taxonomy_id = 0
  THEN
    -- wrong taxonomy name
    -- deliver a message to a log file
    GL_MESSAGE.Write_Log(msg_name  =>'SHRD0180',
                      token_num => 2,
                      t1        =>'ROUTINE',
                      v1        =>
                      'RG_XBRL_PKG.delete_taxonomy',
                      t2        =>'ACTION',
                      v2        =>'Taxonomy name '
                                || p_full_tax_name
                                ||' does not exist');
    RAISE Remove_tax_err;
    RETURN;
  END IF;
  --
  --provide additional checks before delete
  --
  l_axis_set_id := 0;
  BEGIN
    SELECT axis_set_id
    INTO l_axis_set_id
    FROM RG_REPORT_AXIS_SETS
    WHERE taxonomy_id = p_taxonomy_id AND
      axis_set_type = 'R' AND
      ROWNUM = 1;
      EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
          l_axis_set_id := 0;
  END;
  --
  IF l_axis_set_id > 0
  THEN
    -- taxonomy is used in at least one row set
    -- deliver a message to a log file
    GL_MESSAGE.Write_Log(msg_name  =>'SHRD0180',
                      token_num => 2,
                      t1        =>'ROUTINE',
                      v1        =>
                      'RG_XBRL_PKG.delete_taxonomy',
                      t2        =>'ACTION',
                      v2        =>'Taxonomy '
                                || p_full_tax_name
                                ||' is still used in a row set');
    RAISE Remove_tax_err;
    RETURN;
  END IF;
  --
  l_parent_flag := 0;
  BEGIN
    SELECT 0
    INTO l_parent_flag
    FROM DUAL
    WHERE EXISTS
      (SELECT v1.taxonomy_id
       FROM rg_xbrl_taxonomies v1
       WHERE v1.taxonomy_id <> p_taxonomy_id AND
         p_taxonomy_id IN
         (SELECT DISTINCT v2.source_taxonomy_id
          FROM rg_xbrl_map_v v2
           WHERE v2.map_taxonomy_id = v1.taxonomy_id)
      );
      EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
          l_parent_flag := 1;
  END;
  --
  -- l_parent_flag value 1 means that p_taxonomy_id is
  -- top level parent node that has no parents above
  --
  -- l_parent_flag value 0 means that p_taxonomy_id is
  -- a child node and has some parents above
  --
  IF l_parent_flag = 0
  THEN
    -- taxonomy is not a top level parent
    -- deliver a message to a log file
    GL_MESSAGE.Write_Log(msg_name  =>'SHRD0180',
                      token_num => 2,
                      t1        =>'ROUTINE',
                      v1        =>
                      'RG_XBRL_PKG.delete_taxonomy',
                      t2        =>'ACTION',
                      v2        =>'Taxonomy '
                                || p_full_tax_name
                                ||' is not a parent');
    RAISE Remove_tax_err;
    RETURN;
  END IF;
  --
  DELETE FROM RG_XBRL_MAP_ELEMENTS
  WHERE taxonomy_id = p_taxonomy_id;
  COMMIT;
  --
  DELETE FROM RG_XBRL_ELEMENTS
  WHERE taxonomy_id = p_taxonomy_id;
  COMMIT;
  --
  DELETE FROM RG_XBRL_TAXONOMIES
  WHERE taxonomy_id = p_taxonomy_id;
  COMMIT;
  --
END delete_taxonomy;
--
--
--
PROCEDURE load_taxonomy(p_full_tax_name  IN VARCHAR2,
                        p_tax_file_name  IN VARCHAR2,
                        p_tax_descr      IN VARCHAR2)
IS
l_file_name_c VARCHAR2(240);
l_file_name_d VARCHAR2(240);
l_file_name_l VARCHAR2(240);
l_file_name_p VARCHAR2(240);
l_file_name_r VARCHAR2(240);
l_file_name   VARCHAR2(240);
l_element_cnt NUMBER(15);
l_user_id     NUMBER(15);
l_login_id    NUMBER(15);
l_date        DATE;
p_taxonomy_id NUMBER(15);
p_tax_dir     VARCHAR2(4000);
l_url         VARCHAR2(300);
l_valid_import_flag NUMBER(15);
l_valid_import_str VARCHAR2(4000);
l_taxonomy_id NUMBER(15);
l_xsd_pos     NUMBER(15);
l_tax_file_name VARCHAR2(240);
--
Load_tax_err EXCEPTION;
--
BEGIN
  l_url := '  ';
  l_file_name_c := ' ';
  l_file_name_d := ' ';
  l_file_name_l := ' ';
  l_file_name_p := ' ';
  l_file_name_r := ' ';
  -- Obtain user ID, login ID
  l_user_id := 1;
  l_login_id := 1;
  l_user_id  := FND_GLOBAL.User_Id;
  l_login_id := FND_GLOBAL.Login_Id;
  l_date     := SYSDATE;
  --
  SELECT directory_path
  INTO p_tax_dir
  FROM all_directories
  WHERE directory_name = 'XMLDIR'
  AND owner = 'SYS';
  --
  l_xsd_pos := 0;
  l_xsd_pos := INSTR(p_tax_file_name,'.xsd',1,1);
  IF l_xsd_pos > 0
  THEN
    l_file_name := p_tax_file_name;
    l_tax_file_name := SUBSTR(p_tax_file_name,1,l_xsd_pos-1);
  ELSE
    l_file_name   := p_tax_file_name || '.xsd';
    l_tax_file_name := p_tax_file_name;
  END IF;
  --
  l_valid_import_flag := 1;
  l_valid_import_str := '';
  --
  read_url(l_file_name,'targetNamespace="','"',l_url,'xlink:href="',
    l_file_name_c,l_file_name_d,l_file_name_l,l_file_name_p,l_file_name_r);
  --
  l_taxonomy_id := 0;
  --
  BEGIN
    SELECT taxonomy_id
    INTO l_taxonomy_id
    FROM RG_XBRL_TAXONOMIES
    WHERE taxonomy_url = l_url;
      EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
          l_taxonomy_id := 0;
  END;
  --
  IF l_taxonomy_id > 0
  THEN
    -- taxonomy has been loaded already
    -- deliver a message to a log file
    GL_MESSAGE.Write_Log(msg_name  =>'SHRD0180',
                      token_num => 2,
                      t1        =>'ROUTINE',
                      v1        =>
                      'RG_XBRL_PKG.load_taxonomy',
                      t2        =>'ACTION',
                      v2        =>'Taxonomy '
                                || l_url || ' - ' || l_file_name
                                ||' has been loaded already');
    RAISE Load_tax_err;
    RETURN;
  END IF;
  --
  verify_import(l_file_name, l_valid_import_flag, l_valid_import_str,
    '<import','namespace="','schemaLocation="','"');
  --
  IF l_valid_import_flag = 0
  THEN
    RAISE Load_tax_err;
    RETURN;
  END IF;
    --
    SELECT RG_XBRL_TAXONOMY_S.NEXTVAL
    INTO p_taxonomy_id
    FROM dual;
    --
    -- add one new row in Taxonomy Storage RG_XBRL_TAXONOMIES
    --
    INSERT INTO RG_XBRL_TAXONOMIES
      (TAXONOMY_ID,TAXONOMY_ALIAS,TAXONOMY_NAME,TAXONOMY_URL,TAXONOMY_DESCR,
       TAXONOMY_IMPORT_FLAG,
       CREATED_BY,LAST_UPDATED_BY,LAST_UPDATE_LOGIN,CREATION_DATE,LAST_UPDATE_DATE)
    VALUES (p_taxonomy_id, l_tax_file_name, p_full_tax_name,l_url,p_tax_descr,'N',
       l_user_id,l_user_id,l_login_id,l_date,l_date);
    -- COMMIT;
    --
    -- add multiple rows in Taxonomy Elements Storage RG_XBRL_ELEMENTS
    --
      insert_tax_clob(p_taxonomy_id, l_file_name, l_valid_import_str);
      COMMIT;
    --
    -- update multiple rows in Taxonomy Elements Storage RG_XBRL_ELEMENTS
    --
       update_lbl_clob(l_tax_file_name, p_taxonomy_id,l_file_name_l);
    --
    -- update multiple rows in Taxonomy Elements Storage RG_XBRL_ELEMENTS
    --
       update_dfn_clob(l_tax_file_name, p_taxonomy_id, l_file_name_d);
    --
    -- update multiple rows in Taxonomy Elements Storage RG_XBRL_ELEMENTS
    --
       update_flags(p_taxonomy_id);
    --
    --
END load_taxonomy;
--
--
--
PROCEDURE update_flags(p_taxonomy_id IN NUMBER)
IS
l_taxonomy_id NUMBER := 0;
BEGIN
  --
  UPDATE RG_XBRL_ELEMENTS t2
  SET t2.parent_id =
    (SELECT t1.element_id
     FROM RG_XBRL_ELEMENTS t1
     WHERE t1.element_identifier = t2.parent_identifier AND
       t1.taxonomy_id = p_taxonomy_id)
  WHERE t2.taxonomy_id = p_taxonomy_id;
  COMMIT;
  --
  UPDATE RG_XBRL_ELEMENTS
  SET has_parent_flag = 'Y'
  WHERE taxonomy_id = p_taxonomy_id AND
    parent_identifier IS NOT NULL;
  COMMIT;
  --
  UPDATE RG_XBRL_ELEMENTS t2
  SET t2.has_child_flag = 'Y'
  WHERE t2.taxonomy_id = p_taxonomy_id AND
    t2.element_identifier IN
    (SELECT t1.parent_identifier
     FROM RG_XBRL_ELEMENTS t1
     WHERE t1.taxonomy_id = p_taxonomy_id);
  COMMIT;
  --
  UPDATE RG_XBRL_ELEMENTS
  SET hierarchy_level = 3
  WHERE taxonomy_id = p_taxonomy_id AND
    (has_child_flag = 'Y' AND has_parent_flag = 'N');
  COMMIT;
  --
  UPDATE RG_XBRL_ELEMENTS
  SET hierarchy_level = 1
  WHERE taxonomy_id = p_taxonomy_id AND
    (has_child_flag = 'N' AND has_parent_flag = 'Y');
  COMMIT;
  --
  UPDATE RG_XBRL_ELEMENTS
  SET hierarchy_level = 2
  WHERE taxonomy_id = p_taxonomy_id AND
    (has_child_flag = 'Y' AND has_parent_flag = 'Y');
  COMMIT;
  --
END update_flags;
--
--
--
PROCEDURE verify_import(p_filename IN VARCHAR2,
                        p_valid_flag IN OUT NOCOPY NUMBER,
                        p_valid_str  IN OUT NOCOPY VARCHAR2,
                        p_srch_str1 IN VARCHAR2,
                        p_srch_str2 IN VARCHAR2,
                        p_srch_str3 IN VARCHAR2,
                        p_srch_str4 IN VARCHAR2)
IS
import_srch_pos NUMBER(15) := 0;
l_import_pos NUMBER(15) := 0;
l_namesp_pos NUMBER(15) := 0;
l_schema_pos NUMBER(15) := 0;
l_end_pos    NUMBER(15) := 0;
l_import_len NUMBER(15) := 0;
l_namesp_len NUMBER(15) := 0;
l_schema_len NUMBER(15) := 0;
l_tax_id     NUMBER(15) := 0;
l_p_filename NUMBER(15) := 0;
--
xbfile bfile;
iclob  clob;
--
l_namesp_str VARCHAR2(300);
l_schema_str VARCHAR2(300);
l_url_ret    VARCHAR2(300);
l_alias      VARCHAR2(240);
--
l_valid_str VARCHAR2(4000);
--
BEGIN
  l_p_filename := LENGTH(p_filename);
  l_alias := SUBSTR(p_filename,1,l_p_filename-4);
  l_url_ret := ' ';
  xbfile := bfilename('XMLDIR',p_filename);
  dbms_lob.open(xbfile);
  dbms_lob.createtemporary(iclob,TRUE,dbms_lob.session);
  dbms_lob.loadfromfile(iclob,xbfile,dbms_lob.getlength(xbfile));
  dbms_lob.close(xbfile);
  --
  l_valid_str := '';
  import_srch_pos := 1;
  l_import_len   := LENGTH(p_srch_str1);
  l_namesp_len   := LENGTH(p_srch_str2);
  l_schema_len   := LENGTH(p_srch_str3);

  LOOP
    l_import_pos := dbms_lob.INSTR(iclob,p_srch_str1,import_srch_pos,1);
    --
    IF l_import_pos = 0
    THEN
      EXIT;
    END IF;
    --
    l_namesp_str := '';
    l_namesp_pos  := dbms_lob.INSTR(iclob,p_srch_str2,l_import_pos+l_import_len+1,1);
    l_end_pos     := dbms_lob.INSTR(iclob,p_srch_str4,l_namesp_pos+l_namesp_len+2,1);
    l_namesp_str :=
      dbms_lob.SUBSTR(iclob,l_end_pos-l_namesp_pos-l_namesp_len,l_namesp_pos+l_namesp_len);
    --
    l_schema_str := '';
    l_schema_pos  := dbms_lob.INSTR(iclob,p_srch_str3,l_import_pos+l_import_len+1,1);
    l_end_pos     := dbms_lob.INSTR(iclob,p_srch_str4,l_schema_pos+l_schema_len+2,1);
    l_schema_str :=
      dbms_lob.SUBSTR(iclob,l_end_pos-l_schema_pos-l_schema_len,l_schema_pos+l_schema_len);
    --
    IF LENGTH(l_namesp_str) > 0
    THEN
      IF INSTR(l_namesp_str,'instance',1,1) > 0
      THEN
        -- skip this standard import taxonomy
        l_tax_id := 0;
      ELSE
      --
        l_valid_str := l_valid_str || l_namesp_str || '*****';
        l_tax_id := 0;
        --
        BEGIN
          SELECT taxonomy_id
          INTO l_tax_id
          FROM RG_XBRL_TAXONOMIES
          WHERE taxonomy_url = l_namesp_str;
          EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
              l_tax_id := 0;
        END;
        --
        IF l_tax_id = 0
        THEN
          -- taxonomy was not loaded, but is referenced
          -- deliver a message to a log file
          GL_MESSAGE.Write_Log(msg_name  =>'SHRD0180',
                            token_num => 2,
                            t1        =>'ROUTINE',
                            v1        =>
                           'RG_XBRL_PKG.verify_import',
                            t2        =>'ACTION',
                            v2        =>'Taxonomy '
                                      || l_namesp_str || ' - ' || l_schema_str
                                      ||' was never loaded');
          --
          p_valid_flag := 0;
        END IF;
      END IF;
    END IF;
    --
    import_srch_pos := l_end_pos + 1;
  END LOOP;
  p_valid_str := substr(l_valid_str,1);
  --
  dbms_lob.freetemporary(iclob);
  --
END verify_import;
--
--
--
PROCEDURE read_url(filename IN VARCHAR2,
                    p_first_srch    IN VARCHAR2,
                    p_last_replace  IN VARCHAR2,
                    p_url_ret IN OUT NOCOPY VARCHAR2,
                    p_link_srch     IN VARCHAR2,
                    p_link_c  IN OUT NOCOPY VARCHAR2,
                    p_link_d  IN OUT NOCOPY VARCHAR2,
                    p_link_l  IN OUT NOCOPY VARCHAR2,
                    p_link_p  IN OUT NOCOPY VARCHAR2,
                    p_link_r  IN OUT NOCOPY VARCHAR2)
IS
l_first_pos   NUMBER(15) := 0;
l_second_pos  NUMBER(15) := 0;
l_first_len   NUMBER(15) := 0;
link_srch_pos NUMBER(15) := 0;
l_alias_pos   NUMBER(15) := 0;
xbfile bfile;
xclob  clob;
l_url_ret   VARCHAR2(300);
l_link_ret  VARCHAR2(300);
l_alias     VARCHAR2(240);
l_file_name VARCHAR2(240);
BEGIN
  l_alias := SUBSTR(filename,1,LENGTH(filename)-4);
  l_url_ret := ' ';
  xbfile := bfilename('XMLDIR',filename);
  dbms_lob.open(xbfile);
  dbms_lob.createtemporary(xclob,TRUE,dbms_lob.session);
  dbms_lob.loadfromfile(xclob,xbfile,dbms_lob.getlength(xbfile));
  dbms_lob.close(xbfile);
  l_first_len   := LENGTH(p_first_srch);
  l_first_pos   := dbms_lob.INSTR(xclob,p_first_srch,1,1);
  l_second_pos  := dbms_lob.INSTR(xclob,p_last_replace,l_first_pos+l_first_len+1,1);
  p_url_ret :=
    dbms_lob.SUBSTR(xclob,l_second_pos-l_first_pos-l_first_len,l_first_pos+l_first_len);
  link_srch_pos := 1;
  l_first_pos := 0;
  l_second_pos := 0;
  l_first_len   := LENGTH(p_link_srch);
  LOOP
    l_first_pos := dbms_lob.INSTR(xclob,p_link_srch,link_srch_pos,1);
    IF l_first_pos = 0
    THEN
      EXIT;
    END IF;
    l_second_pos  := dbms_lob.INSTR(xclob,p_last_replace,l_first_pos+l_first_len+1,1);
    l_link_ret :=
      dbms_lob.SUBSTR(xclob,l_second_pos-l_first_pos-l_first_len,l_first_pos+l_first_len);
    l_alias_pos := INSTR(l_link_ret,l_alias,1);
    l_file_name := SUBSTR(l_link_ret,l_alias_pos);
    --
    IF INSTR(l_file_name,'calculation',1) > 0
    THEN
      p_link_c := l_file_name;
    END IF;
    --
    IF INSTR(l_file_name,'definition',1) > 0
    THEN
      p_link_d := l_file_name;
    END IF;
    --
    IF INSTR(l_file_name,'label',1) > 0
    THEN
      p_link_l := l_file_name;
    END IF;
    --
    IF INSTR(l_file_name,'presentation',1) > 0
    THEN
      p_link_p := l_file_name;
    END IF;
    --
    IF INSTR(l_file_name,'reference',1) > 0
    THEN
      p_link_r := l_file_name;
    END IF;
    --
    link_srch_pos := l_second_pos + 1;
  END LOOP;
  dbms_lob.freetemporary(xclob);
  EXCEPTION
    WHEN others
    THEN
    l_url_ret := ' ';
END read_url;
--
--
--
PROCEDURE insert_tax_clob(p_taxonomy_id IN NUMBER,
                          filename      IN VARCHAR2,
                          p_valid_str   IN VARCHAR2)
IS
xbfile bfile;
p_clob  clob;
--
l_user_id    NUMBER(15);
l_login_id   NUMBER(15);
l_date       DATE;
--
l_elem_id    NUMBER(15) := 0;
l_second_pos NUMBER(15) := 0;
--
l_elem_found_pos NUMBER(15) := 0;
--
l_elem_srch_pos  NUMBER(15) := 0;
l_id_srch_pos    NUMBER(15) := 0;
l_name_srch_pos  NUMBER(15) := 0;
l_type_srch_pos  NUMBER(15) := 0;
l_group_srch_pos NUMBER(15) := 0;
l_docm_srch_pos  NUMBER(15) := 0;
l_abstr_srch_pos NUMBER(15) := 0;
l_next_elem_pos  NUMBER(15) := 0;
l_exec           NUMBER(15) := 0;
--
l_elem_xbrl_id VARCHAR2(240);
l_elem_name    VARCHAR2(240);
l_elem_type    VARCHAR2(240);
l_elem_group   VARCHAR2(240);
l_elem_descr   VARCHAR2(3000);
--
l_delim_pos     NUMBER(15) := 0;
l_source_tax_id NUMBER(15) := 0;
l_cur_url       VARCHAR2(300);
l_valid_str     VARCHAR2(4000);
l_new_valid_str VARCHAR2(4000);
l_valid_len     NUMBER(15) := 0;
--
Insert_tax_err EXCEPTION;
--
BEGIN
  -- Obtain user ID, login ID
  l_user_id := 1;
  l_login_id := 1;
  l_user_id  := FND_GLOBAL.User_Id;
  l_login_id := FND_GLOBAL.Login_Id;
  l_date     := SYSDATE;
  --
  xbfile := bfilename('XMLDIR',filename);
  dbms_lob.open(xbfile);
  dbms_lob.createtemporary(p_clob,TRUE,dbms_lob.session);
  dbms_lob.loadfromfile(p_clob,xbfile,dbms_lob.getlength(xbfile));
  dbms_lob.close(xbfile);
  --
  l_elem_found_pos := 1;
  --
  LOOP
      l_elem_name    := '';
      l_elem_xbrl_id := '';
      l_elem_type    := '';
      l_elem_group   := '';
      l_elem_descr   := '';
      l_exec := 1;
      --
      l_elem_srch_pos := 0;
      l_elem_srch_pos := dbms_lob.INSTR(p_clob,'<element',l_elem_found_pos,1);
      IF l_elem_srch_pos = 0
      THEN
        EXIT;
      END IF;
      --
      l_next_elem_pos := dbms_lob.INSTR(p_clob,'<element',l_elem_srch_pos+1,1);
      --
      -- get name attribute for the element
      --
      l_name_srch_pos := 0;
      l_name_srch_pos := dbms_lob.INSTR(p_clob,'name="',l_elem_srch_pos,1);
      IF l_name_srch_pos = 0
      THEN
        EXIT;
      END IF;
      l_second_pos    := dbms_lob.INSTR(p_clob,'"',l_name_srch_pos+6,1);
      IF (l_next_elem_pos = 0)
      THEN
        l_elem_name :=
          dbms_lob.SUBSTR(p_clob,l_second_pos-l_name_srch_pos-6,l_name_srch_pos+6);
      ELSE
        IF (l_name_srch_pos < l_next_elem_pos)
        THEN
          l_elem_name :=
            dbms_lob.SUBSTR(p_clob,l_second_pos-l_name_srch_pos-6,l_name_srch_pos+6);
        ELSE
          l_exec := 0;
        END IF;
      END IF;
      --
      --
      -- get id attribute for the element
      --
      l_id_srch_pos := 0;
      l_id_srch_pos := dbms_lob.INSTR(p_clob,'id="',l_elem_srch_pos,1);
      IF l_id_srch_pos = 0
      THEN
        l_elem_xbrl_id := l_elem_name;
      ELSE
        l_second_pos  := dbms_lob.INSTR(p_clob,'"',l_id_srch_pos+4,1);
        IF (l_next_elem_pos = 0)
        THEN
          l_elem_xbrl_id :=
            dbms_lob.SUBSTR(p_clob,l_second_pos-l_id_srch_pos-4,l_id_srch_pos+4);
        ELSE
          IF (l_id_srch_pos < l_next_elem_pos)
          THEN
            l_elem_xbrl_id :=
              dbms_lob.SUBSTR(p_clob,l_second_pos-l_id_srch_pos-4,l_id_srch_pos+4);
          ELSE
            l_elem_xbrl_id := l_elem_name;
          END IF;
        END IF;
      END IF;
      --
      --
      -- get type attribute for the element
      --
      l_type_srch_pos := 0;
      l_type_srch_pos := dbms_lob.INSTR(p_clob,'type="',l_elem_srch_pos,1);
      IF l_type_srch_pos = 0
      THEN
        l_elem_type := '';
      ELSE
        l_second_pos  := dbms_lob.INSTR(p_clob,'"',l_type_srch_pos+6,1);
        IF (l_next_elem_pos = 0)
        THEN
          l_elem_type :=
            dbms_lob.SUBSTR(p_clob,l_second_pos-l_type_srch_pos-6,l_type_srch_pos+6);
        ELSE
          IF (l_type_srch_pos < l_next_elem_pos)
          THEN
            l_elem_type :=
              dbms_lob.SUBSTR(p_clob,l_second_pos-l_type_srch_pos-6,l_type_srch_pos+6);
          ELSE
            l_elem_type := '';
          END IF;
        END IF;
      END IF;
      --
      --
      -- get group attribute for the element
      --
      l_group_srch_pos := 0;
      l_group_srch_pos := dbms_lob.INSTR(p_clob,'substitutionGroup="',l_elem_srch_pos,1);
      IF l_group_srch_pos = 0
      THEN
        l_elem_group := '';
      ELSE
        l_second_pos     := dbms_lob.INSTR(p_clob,'"',l_group_srch_pos+19,1);
        IF (l_next_elem_pos = 0)
        THEN
          l_elem_group :=
            dbms_lob.SUBSTR(p_clob,l_second_pos-l_group_srch_pos-19,l_group_srch_pos+19);
        ELSE
          IF (l_group_srch_pos < l_next_elem_pos)
          THEN
            l_elem_group :=
              dbms_lob.SUBSTR(p_clob,l_second_pos-l_group_srch_pos-19,l_group_srch_pos+19);
          ELSE
            l_elem_group := '';
          END IF;
        END IF;
      END IF;
      --
      --
      -- get documentation attribute for the element
      --
      l_docm_srch_pos := 0;
      l_docm_srch_pos := dbms_lob.INSTR(p_clob,'<documentation>',l_elem_srch_pos,1);
      IF l_docm_srch_pos = 0
      THEN
        l_elem_descr := '';
      ELSE
        l_second_pos  := dbms_lob.INSTR(p_clob,'</documentation>',l_docm_srch_pos+15,1);
        IF (l_next_elem_pos = 0)
        THEN
          IF (l_second_pos-l_docm_srch_pos-15) > 1000
          THEN
            l_elem_descr :=
              dbms_lob.SUBSTR(p_clob,1000,l_docm_srch_pos+15);
          ELSE
            l_elem_descr :=
              dbms_lob.SUBSTR(p_clob,l_second_pos-l_docm_srch_pos-15,l_docm_srch_pos+15);
          END IF;
        ELSE
          IF (l_group_srch_pos < l_next_elem_pos)
          THEN
            IF (l_second_pos-l_docm_srch_pos-15) > 1000
            THEN
              l_elem_descr :=
                dbms_lob.SUBSTR(p_clob,1000,l_docm_srch_pos+15);
            ELSE
              l_elem_descr :=
                dbms_lob.SUBSTR(p_clob,l_second_pos-l_docm_srch_pos-15,l_docm_srch_pos+15);
            END IF;
          ELSE
            l_elem_group := '';
          END IF;
        END IF;
      END IF;
      --
      --
      -- get abstract attribute for the element
      --
      l_abstr_srch_pos := 0;
      l_abstr_srch_pos := dbms_lob.INSTR(p_clob,'abstract="true"',l_elem_srch_pos,1);
      IF l_abstr_srch_pos > 0
      THEN
        IF (l_next_elem_pos = 0)
        THEN
          EXIT;
        ELSE
          IF (l_abstr_srch_pos < l_next_elem_pos)
          THEN
            l_exec := 0;
          END IF;
        END IF;
      END IF;
      --
      IF l_exec = 1
      THEN
        IF INSTR(l_elem_group,'item',1,1) > 0
        THEN
          SELECT RG_XBRL_ELEMENTS_S.NEXTVAL
          INTO l_elem_id
          FROM dual;
          --
          INSERT INTO RG_XBRL_ELEMENTS
            (taxonomy_id,element_id,
             element_identifier,element_descr,
             element_name,element_type,
             element_group,
             has_child_flag,has_parent_flag,hierarchy_level,
             CREATED_BY,LAST_UPDATED_BY,LAST_UPDATE_LOGIN,
             CREATION_DATE,LAST_UPDATE_DATE)
          VALUES
            (p_taxonomy_id, l_elem_id,
             l_elem_xbrl_id, l_elem_descr,
             l_elem_name, l_elem_type,
             l_elem_group,
             'N', 'N', 0,
             l_user_id,l_user_id,l_login_id,
             l_date,l_date);
          --
          INSERT INTO RG_XBRL_MAP_ELEMENTS
            (taxonomy_id,element_id,
             enabled_flag,
             CREATED_BY,LAST_UPDATED_BY,LAST_UPDATE_LOGIN,
             CREATION_DATE,LAST_UPDATE_DATE)
          VALUES
            (p_taxonomy_id, l_elem_id,
             'Y',
             l_user_id,l_user_id,l_login_id,
             l_date,l_date);
        END IF;
      END IF;
      --
      l_elem_found_pos := l_elem_srch_pos + 5;
  END LOOP;
  dbms_lob.freetemporary(p_clob);
  -- COMMIT;
  --
  -- add elements from imported taxonomies for the taxonomy_id
  -- into RG_XBRL_MAP_ELEMENTS using p_valid_str
  --
  l_valid_str := SUBSTR(p_valid_str,1,LENGTH(p_valid_str));
  IF LENGTH(l_valid_str) > 0
  THEN
    LOOP
      IF LENGTH(l_valid_str) = 0
      THEN
        EXIT;
      END IF;
      l_delim_pos := INSTR(l_valid_str,'*****',1,1);
      IF l_delim_pos = 0
      THEN
        EXIT;
      END IF;
      l_cur_url := SUBSTR(l_valid_str,1,l_delim_pos-1);
      l_source_tax_id := 0;
      SELECT taxonomy_id
      INTO l_source_tax_id
      FROM RG_XBRL_TAXONOMIES
      WHERE taxonomy_url = l_cur_url;
      --
      IF l_source_tax_id = 0
      THEN
        -- imported taxonomy was not loaded
        GL_MESSAGE.Write_Log(msg_name  =>'SHRD0180',
                        token_num => 2,
                        t1        =>'ROUTINE',
                        v1        =>
                        'RG_XBRL_PKG.insert_tax_clob',
                        t2        =>'ACTION',
                        v2        =>'Import Taxonomy '
                                  || l_cur_url ||
                                  ' was not loaded');
        RAISE Insert_tax_err;
        EXIT;
      ELSE
        INSERT INTO RG_XBRL_MAP_ELEMENTS
          (taxonomy_id,element_id,
           enabled_flag,
           CREATED_BY,LAST_UPDATED_BY,LAST_UPDATE_LOGIN,
           CREATION_DATE,LAST_UPDATE_DATE)
          ( SELECT p_taxonomy_id,
            mel.element_id,mel.enabled_flag,
            mel.CREATED_BY,mel.LAST_UPDATED_BY,mel.LAST_UPDATE_LOGIN,
            mel.CREATION_DATE,mel.LAST_UPDATE_DATE
            FROM RG_XBRL_MAP_ELEMENTS mel
            WHERE mel.taxonomy_id = l_source_tax_id AND
              mel.element_id NOT IN
              (SELECT map.element_id
               FROM RG_XBRL_MAP_ELEMENTS map
               WHERE map.taxonomy_id = p_taxonomy_id)
          );
        --COMMIT;
        UPDATE RG_XBRL_TAXONOMIES
        SET TAXONOMY_IMPORT_FLAG = 'Y'
        WHERE taxonomy_id = p_taxonomy_id;
        --COMMIT;
      END IF;
      --
      --
      l_valid_len := LENGTH(l_valid_str);
      IF l_valid_len = (l_delim_pos + 4)
      THEN
        EXIT;
      END IF;
      l_new_valid_str := substr(l_valid_str,l_delim_pos+5,l_valid_len-l_delim_pos-4);
      l_valid_len := LENGTH(l_new_valid_str);
      l_valid_str := SUBSTR(l_new_valid_str,1,l_valid_len);
    END LOOP;
    --
  END IF;
  --
END insert_tax_clob;
--
--
--
PROCEDURE update_lbl_clob(p_tax_name    IN VARCHAR2,
                          p_taxonomy_id IN NUMBER,
                          filename      IN VARCHAR2)
IS
xbfile bfile;
l_clob  clob;
--
l_start_pos    NUMBER(15) := 0;
l_title_pos    NUMBER(15) := 0;
l_second_pos   NUMBER(15) := 0;
l_label_pos    NUMBER(15) := 0;
l_descr_pos    NUMBER(15) := 0;
l_left_br_pos  NUMBER(15) := 0;
l_right_br_pos NUMBER(15) := 0;
l_link_to_pos  NUMBER(15) := 0;
l_cur_lblarc_pos NUMBER(15) := 0;
l_fnd_lblarc_pos NUMBER(15) := 0;
l_near_lblarc_pos NUMBER(15) := 0;
l_prev_lblarc_pos NUMBER(15) := 0;
l_link_from_pos NUMBER(15) := 0;
--
l_element_id      NUMBER(15) := 0;
l_element_xbrl_id VARCHAR2(240);
l_element_label   VARCHAR2(240);
--
l_label         VARCHAR2(240);
l_label_descr   VARCHAR2(240);
l_label_from    VARCHAR2(240);
--
CURSOR tax_el_storage (tax_id number) IS
  SELECT element_id,
         element_identifier,
         element_label
  FROM RG_XBRL_ELEMENTS t1
  WHERE t1.taxonomy_id = tax_id
  FOR UPDATE;
--
BEGIN
  xbfile := bfilename('XMLDIR',filename);
  dbms_lob.open(xbfile);
  dbms_lob.createtemporary(l_clob,TRUE,dbms_lob.session);
  dbms_lob.loadfromfile(l_clob,xbfile,dbms_lob.getlength(xbfile));
  dbms_lob.close(xbfile);
  --
    OPEN tax_el_storage(p_taxonomy_id);
    LOOP
      l_element_id      := 0;
      l_element_xbrl_id := '';
      l_element_label   := '';
      l_label := '';
      --
      FETCH tax_el_storage INTO l_element_id,
                                l_element_xbrl_id,
                                l_element_label;
      IF tax_el_storage%NOTFOUND THEN
        EXIT;
      END IF;
      --
      l_start_pos  := dbms_lob.INSTR(l_clob,p_tax_name || '.xsd#' || l_element_xbrl_id,1,1);
      l_title_pos  := dbms_lob.INSTR(l_clob, 'label="', l_start_pos+6, 1);
      l_second_pos := dbms_lob.INSTR(l_clob, '"', l_title_pos+7, 1);
      l_label_descr :=
        dbms_lob.SUBSTR(l_clob,l_second_pos-l_title_pos-7,l_title_pos+7);
      --
      -- label description in loc is ready in l_label_descr
      --
      -- now find xlink:to="l_label_descr"
      --
      l_link_to_pos := dbms_lob.INSTR(l_clob,'xlink:to="' || l_label_descr || '"',1,1);
      --
      -- now find the nearest <labelArc for this l_link_to_pos
      --
      l_cur_lblarc_pos  := 1;
      l_near_lblarc_pos := 1;
      l_prev_lblarc_pos := 1;
      l_prev_lblarc_pos := dbms_lob.INSTR(l_clob, '<labelArc', 1, 1);
      LOOP
        l_fnd_lblarc_pos := dbms_lob.INSTR(l_clob, '<labelArc', l_cur_lblarc_pos, 1);
        IF (l_fnd_lblarc_pos = 0) OR (l_fnd_lblarc_pos > l_link_to_pos)
        THEN
          l_near_lblarc_pos := l_cur_lblarc_pos;
          EXIT;
        END IF;
        l_prev_lblarc_pos := l_fnd_lblarc_pos;
        l_cur_lblarc_pos  := l_fnd_lblarc_pos + 5;
      END LOOP;
      --
      -- l_near_lblarc_pos is ready
      --
      l_link_from_pos := dbms_lob.INSTR(l_clob,'xlink:from="',l_near_lblarc_pos,1);
      l_second_pos := dbms_lob.INSTR(l_clob, '"', l_link_from_pos+12, 1);
      l_label_from :=
        dbms_lob.SUBSTR(l_clob,l_second_pos-l_link_from_pos-12,l_link_from_pos+12);
      --
      -- l_label_from is ready for xlink:label="  " search
      --
      l_label_pos    := dbms_lob.INSTR(l_clob,
         'xlink:label="' || l_label_from, 1, 1);
      l_right_br_pos := dbms_lob.INSTR(l_clob, '>', l_label_pos, 1);
      l_left_br_pos  := dbms_lob.INSTR(l_clob, '<', l_right_br_pos+1, 1);
      --
      l_label :=
        dbms_lob.SUBSTR(l_clob,l_left_br_pos-l_right_br_pos-1, l_right_br_pos+1);
      --
      UPDATE RG_XBRL_ELEMENTS
        SET element_label = l_label
        WHERE CURRENT OF tax_el_storage;
    END LOOP;
    CLOSE tax_el_storage;
    dbms_lob.freetemporary(l_clob);
    COMMIT;
END update_lbl_clob;
--
--
--
PROCEDURE update_dfn_clob(p_tax_name    IN VARCHAR2,
                          p_taxonomy_id IN NUMBER,
                          filename      IN VARCHAR2)
IS
xbfile bfile;
d_clob  clob;
--
l_start_pos   NUMBER(15) := 0;
l_title_pos   NUMBER(15) := 0;
l_second_pos  NUMBER(15) := 0;
l_label_pos   NUMBER(15) := 0;
l_descr_pos   NUMBER(15) := 0;
l_def_arc_pos NUMBER(15) := 0;
l_from_pos    NUMBER(15) := 0;
l_to_pos      NUMBER(15) := 0;
l_ref_pos     NUMBER(15) := 0;
--
l_element_id          NUMBER(15) := 0;
l_element_xbrl_id     VARCHAR2(240);
l_element_defn_parent VARCHAR2(240);
--
l_label         VARCHAR2(240);
l_title_descr   VARCHAR2(240);
l_parent_descr  VARCHAR2(240);
--
CURSOR tax_el_storage (tax_id number) IS
  SELECT element_id,
         element_identifier,
         parent_identifier
  FROM RG_XBRL_ELEMENTS t1
  WHERE t1.taxonomy_id = tax_id
  FOR UPDATE;
--
BEGIN
  xbfile := bfilename('XMLDIR',filename);
  dbms_lob.open(xbfile);
  dbms_lob.createtemporary(d_clob,TRUE,dbms_lob.session);
  dbms_lob.loadfromfile(d_clob,xbfile,dbms_lob.getlength(xbfile));
  dbms_lob.close(xbfile);
  --
    OPEN tax_el_storage(p_taxonomy_id);
    LOOP
      l_element_id      := 0;
      l_element_xbrl_id := '';
      l_element_defn_parent   := '';
      --
      FETCH tax_el_storage INTO l_element_id,
                                l_element_xbrl_id,
                                l_element_defn_parent;
      IF tax_el_storage%NOTFOUND THEN
        EXIT;
      END IF;
      --
      l_start_pos  := dbms_lob.INSTR(d_clob,p_tax_name || '.xsd#' || l_element_xbrl_id,1,1);
      l_title_pos  := dbms_lob.INSTR(d_clob, 'label="', l_start_pos+6, 1);
      l_second_pos := dbms_lob.INSTR(d_clob, '"', l_title_pos+7, 1);
      l_title_descr :=
            dbms_lob.SUBSTR(d_clob,l_second_pos-l_title_pos-7,l_title_pos+7);
      --
      l_def_arc_pos  := dbms_lob.INSTR(d_clob, '<definitionArc', 1, 1);
      l_from_pos     := dbms_lob.INSTR(d_clob, 'from="' || l_title_descr, l_def_arc_pos, 1);
      l_to_pos       := dbms_lob.INSTR(d_clob, 'to="' || l_title_descr, l_from_pos+6, 1);
      l_second_pos   := dbms_lob.INSTR(d_clob, '"', l_to_pos+5, 1);
      l_parent_descr :=
            dbms_lob.SUBSTR(d_clob,l_second_pos-l_to_pos-4,l_to_pos+4);
      --
      l_ref_pos := dbms_lob.INSTR(d_clob, 'href="' || p_tax_name || '.xsd#' || l_parent_descr,
          1, 1);
      --
      l_element_defn_parent := '';
      IF (l_ref_pos > 0) AND (l_parent_descr <> l_element_xbrl_id)
      THEN
        l_element_defn_parent := SUBSTR(l_parent_descr,1,LENGTH(l_parent_descr));
      END IF;
      --
      UPDATE RG_XBRL_ELEMENTS
        SET parent_identifier = l_element_defn_parent
        WHERE CURRENT OF tax_el_storage;
    END LOOP;
    CLOSE tax_el_storage;
    dbms_lob.freetemporary(d_clob);
    COMMIT;
END update_dfn_clob;
--
END RG_XBRL_PKG;

/
