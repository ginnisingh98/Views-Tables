--------------------------------------------------------
--  DDL for Package Body GL_JOURNAL_IMPORT_TAX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_JOURNAL_IMPORT_TAX_PKG" AS
/* $Header: glujitxb.pls 120.3 2006/01/17 21:43:20 xiwu noship $ */
--
-- Wrappers
--
PROCEDURE Update_taxes(errbuf	    OUT NOCOPY VARCHAR2,
		       retcode	    OUT NOCOPY VARCHAR2,
		       p_batch_name IN VARCHAR2) IS
l_batch_id NUMBER;
BEGIN
  --
  BEGIN
    SELECT je_batch_id
    INTO l_batch_id
    FROM gl_je_batches
    WHERE name = p_batch_name AND
    ROWNUM = 1;
    --
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
          l_batch_id := -1;
  END;
  --
  IF l_batch_id = -1
  THEN
    -- wrong p_batch_name
    -- deliver a message to a log file
    GL_MESSAGE.Write_Log(msg_name  =>'SHRD0180',
                      token_num => 2,
                      t1        =>'ROUTINE',
                      v1        =>
                      'GL_JOURNAL_IMPORT_TAX_PKG.move_taxes',
                      t2        =>'ACTION',
                      v2        =>'Wrong batch name: '
                                || p_batch_name);
    --RAISE move_taxes_err;
    RETURN;
  END IF;
  --
  GL_JOURNAL_IMPORT_TAX_PKG.move_taxes_srs(l_batch_id);
  --
  EXCEPTION
    WHEN OTHERS THEN
      errbuf := SQLERRM;
      retcode := '2';
      --app_exception.raise_exception;
END Update_taxes;
--
-- Regular procedures
--
PROCEDURE move_taxes_srs(p_batch_id IN NUMBER)
IS
-- batch level
l_org_id NUMBER(15) := 0;
l_org_name VARCHAR2(240);
l_budgetary_control_status VARCHAR2(1);
l_actual_flag VARCHAR2(1);
l_approval_status_code VARCHAR2(1);
l_status VARCHAR2(1);
l_name VARCHAR2(100);
l_batch_tax_required NUMBER(15);
-- header level
l_ledger_id NUMBER(15) := 0;
l_je_header_id NUMBER(15);
l_je_header_name VARCHAR2(100);
l_je_header_je_source VARCHAR2(25);
l_je_header_tax_status_code VARCHAR2(1);
l_je_header_tax_required NUMBER(15);
-- line level
l_je_line_period_name VARCHAR2(15);
l_je_line_effective_date DATE;
l_je_line_status VARCHAR2(1);
l_je_line_tax_code VARCHAR2(15);
l_je_line_tax_flag VARCHAR2(1);
l_je_line_tax_code_id NUMBER(15);
l_je_line_attribute9 VARCHAR2(150);
l_je_line_attribute10 VARCHAR2(150);
l_je_line_tax_type_code VARCHAR2(1);
l_je_line_found NUMBER(15);
le_id               NUMBER; -- legal entity id
x_return_status     VARCHAR2(30);
x_msg_out           VARCHAR2(2000);
--
CURSOR je_headers (batch_id_in NUMBER)
IS
  SELECT je_header_id,name,je_source,tax_status_code,ledger_id
  FROM gl_je_headers
  WHERE je_batch_id = batch_id_in
  FOR UPDATE;
--
CURSOR je_lines (header_id_in NUMBER)
IS
  SELECT period_name,effective_date,status,
    tax_code,amount_includes_tax_flag,tax_code_id,
    attribute9,attribute10
  FROM gl_je_lines
  WHERE je_header_id = header_id_in
  FOR UPDATE;
--
BEGIN
  --
  BEGIN
    SELECT org_id,
      budgetary_control_status, actual_flag,
      approval_status_code, status, name
    INTO l_org_id,
      l_budgetary_control_status, l_actual_flag,
      l_approval_status_code, l_status, l_name
    FROM GL_JE_BATCHES
    WHERE je_batch_id = p_batch_id;

    --
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
          l_org_id := -1;
  END;
  --
  IF l_org_id = -1
  THEN
    -- deliver a message to a log file
    GL_MESSAGE.Write_Log(msg_name  =>'SHRD0180',
                      token_num => 2,
                      t1        =>'ROUTINE',
                      v1        =>
                      'GL_JOURNAL_IMPORT_TAX_PKG.move_taxes',
                      t2        =>'ACTION',
                      v2        =>'Batch name:'
                                || l_name
                                ||' :SOB does not exist');
    RETURN;
  END IF;
  --

  IF
    (l_status <> 'U')
  THEN
    -- deliver a message to a log file
    GL_MESSAGE.Write_Log(msg_name  =>'SHRD0180',
                      token_num => 2,
                      t1        =>'ROUTINE',
                      v1        =>
                      'GL_JOURNAL_IMPORT_TAX_PKG.move_taxes',
                      t2        =>'ACTION',
                      v2        =>'Batch name: '
                                || l_name
                                || ':cannot be taxed because '
                                || 'status is not U');
    RETURN;
  END IF;
  --
  IF
    (l_budgetary_control_status NOT IN ('R','N') )
  THEN
    -- deliver a message to a log file
    GL_MESSAGE.Write_Log(msg_name  =>'SHRD0180',
                      token_num => 2,
                      t1        =>'ROUTINE',
                      v1        =>
                      'GL_JOURNAL_IMPORT_TAX_PKG.move_taxes',
                      t2        =>'ACTION',
                      v2        =>'Batch name: '
                                || l_name
                                || ':cannot be taxed because '
                                || 'budgetary_control_status is not in R,N');
    RETURN;
  END IF;
  --
  IF
    (l_actual_flag <> 'A' )
  THEN
    -- deliver a message to a log file
    GL_MESSAGE.Write_Log(msg_name  =>'SHRD0180',
                      token_num => 2,
                      t1        =>'ROUTINE',
                      v1        =>
                      'GL_JOURNAL_IMPORT_TAX_PKG.move_taxes',
                      t2        =>'ACTION',
                      v2        =>'Batch name: '
                                || l_name
                                || ':cannot be taxed because '
                                || 'actual_flag is not A');
    RETURN;
  END IF;
  --
  --IF
  --  (l_approval_status_code <> 'I' )
  --THEN
    -- deliver a message to a log file
  --  GL_MESSAGE.Write_Log(msg_name  =>'SHRD0180',
  --                    token_num => 2,
  --                    t1        =>'ROUTINE',
  --                    v1        =>
  --                    'GL_JOURNAL_IMPORT_TAX_PKG.move_taxes',
  --                    t2        =>'ACTION',
  --                    v2        =>'Batch name: '
  --                              || l_name
  --                              || ':cannot be taxed because '
  --                              || 'approval_status_code is not I');
    --RETURN;
  --END IF;
  --
  l_batch_tax_required := 0;
  --
  -- we should figure out the value of org_id and put it into l_org_id
  -- from profile ORG_ID (MO: Operating Unit)
  --
  l_org_id := FND_PROFILE.VALUE_WNPS('ORG_ID');
  IF l_org_id IS NULL
  THEN
    l_org_id := -1;
  END IF;
  --
  BEGIN
    SELECT name
    INTO l_org_name
    FROM hr_operating_units
    WHERE organization_id = l_org_id;
    --
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
          l_org_name := '';
  END;
  --
  --GL_MESSAGE.Write_Log(msg_name  =>'SHRD0180',
  --                  token_num => 2,
  --                  t1        =>'ROUTINE',
  --                  v1        =>
  --                  'GL_JOURNAL_IMPORT_TAX_PKG.move_taxes',
  --                  t2        =>'ACTION',
  --                  v2        =>'Profile ORG_ID organization name:'
  --                            || l_org_name
  --                            || ':is used for further processing');
  --
  OPEN je_headers(p_batch_id);
  LOOP
    FETCH je_headers INTO
      l_je_header_id,
      l_je_header_name,
      l_je_header_je_source,
      l_je_header_tax_status_code,
      l_ledger_id;
    IF je_headers%NOTFOUND
    THEN
      EXIT;
    END IF;
    --
    IF SUBSTR(l_je_header_je_source,1,11) <> 'Spreadsheet'
    THEN
      -- deliver a message to a log file
      GL_MESSAGE.Write_Log(msg_name  =>'SHRD0180',
                      token_num => 2,
                      t1        =>'ROUTINE',
                      v1        =>
                      'GL_JOURNAL_IMPORT_TAX_PKG.move_taxes',
                      t2        =>'ACTION',
                      v2        =>'Batch :'
                                || l_name
                                ||':was not created by Spreadsheet');
      RETURN;
    END IF;
   --
    l_je_header_tax_required := 0;
    --
    OPEN je_lines(l_je_header_id);
    LOOP
      FETCH je_lines INTO
        l_je_line_period_name,
        l_je_line_effective_date,
        l_je_line_status,
        l_je_line_tax_code,
        l_je_line_tax_flag,
        l_je_line_tax_code_id,
        l_je_line_attribute9,
        l_je_line_attribute10;
      IF je_lines%NOTFOUND
      THEN
        EXIT;
      END IF;
      --
      -- process current je line
      --
      -- we suppose that l_je_line_attribute9 has a value of TAX_CODE
      -- and l_je_line_attribute10 has a value of AMOUNT_INCLUDES_TAX_FLAG(Y,N)
      --
      IF (l_je_line_attribute9 IS NOT NULL) AND
         (l_je_line_attribute10 IS NOT NULL)
      THEN
        --
        -- use GL_TAX_CODES_V to get tax_code_id
        --
        BEGIN
          --
          l_je_line_tax_flag := substr(l_je_line_attribute10,1,1);
          l_je_line_found := 1;
          l_je_line_tax_type_code := ' ';
          -- some questions about SELECT
          le_id := XLE_UTILITIES_GRP.Get_DefaultLegalContext_OU(
                   l_org_id);
          zx_gl_tax_options_pkg.get_tax_rate_id (
               1.0,
               l_org_id,
               le_id,
               l_je_line_attribute9,
               sysdate,
               l_je_line_tax_type_code,
               l_je_line_tax_code_id,
               x_return_status,
               x_msg_out);

--          SELECT tax_code_id, tax_type_code
--          INTO l_je_line_tax_code_id, l_je_line_tax_type_code
--          FROM GL_TAX_CODES_V
--          WHERE org_id = l_org_id AND
--            ledger_id = l_ledger_id AND
--            tax_code = l_je_line_attribute9 AND
--            valid_flag = 'Y' AND
--            displayed_flag = 'Y' AND
--            enabled_flag = 'Y' AND
--            sysdate BETWEEN nvl(start_date,sysdate) AND
--            nvl(end_date,sysdate);
          --
          EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
              l_je_line_found := -1;
        END;
        --
        IF l_je_line_found = 1
        THEN
          --
          --  if tax details are present in current line,
          --  then update gl_je_lines details
          --

          UPDATE gl_je_lines
          SET tax_code_id = l_je_line_tax_code_id,
              amount_includes_tax_flag = l_je_line_tax_flag,
              tax_type_code = l_je_line_tax_type_code,
              tax_rounding_rule_code = 'N',
              taxable_line_flag = 'Y'
          WHERE CURRENT OF je_lines;
          l_je_header_tax_required := 1;

        ELSE
          -- deliver a message to a log file
          GL_MESSAGE.Write_Log(msg_name  =>'SHRD0180',
                      token_num => 2,
                      t1        =>'ROUTINE',
                      v1        =>
                      'GL_JOURNAL_IMPORT_TAX_PKG.move_taxes',
                      t2        =>'ACTION',
                      v2        =>'Tax code:'
                                || l_je_line_attribute9
                                ||':cannot be found');
        END IF;
      END IF;
      --
    END LOOP;
    CLOSE je_lines;
    --
    --  if any line has been updated for taxes in current header,
    --  then update gl_je_headers details
    --
    IF l_je_header_tax_required = 1
    THEN
      UPDATE gl_je_headers
      SET tax_status_code = 'R'
      WHERE CURRENT OF je_headers;
      l_batch_tax_required := 1;
    END IF;
    --
  END LOOP;
  CLOSE je_headers;
  --
  -- do not forget to update org_id at batch level
  --
  IF l_batch_tax_required = 1
  THEN
    UPDATE gl_je_batches
    SET org_id = l_org_id
    WHERE je_batch_id = p_batch_id;
  END IF;
  --
  COMMIT;
  --
END move_taxes_srs;
--
--
PROCEDURE move_taxes_hook(p_batch_id IN NUMBER)
IS
-- batch level
l_org_id NUMBER(15) := 0;
l_org_name VARCHAR2(240);
l_budgetary_control_status VARCHAR2(1);
l_actual_flag VARCHAR2(1);
l_approval_status_code VARCHAR2(1);
l_status VARCHAR2(1);
l_name VARCHAR2(100);
l_batch_tax_required NUMBER(15);
-- header level
l_ledger_id NUMBER(15) := 0;
l_je_header_id NUMBER(15);
l_je_header_name VARCHAR2(100);
l_je_header_je_source VARCHAR2(25);
l_je_header_tax_status_code VARCHAR2(1);
l_je_header_tax_required NUMBER(15);
-- line level
l_je_line_period_name VARCHAR2(15);
l_je_line_effective_date DATE;
l_je_line_status VARCHAR2(1);
l_je_line_tax_code VARCHAR2(15);
l_je_line_tax_flag VARCHAR2(1);
l_je_line_tax_code_id NUMBER(15);
l_je_line_attribute9 VARCHAR2(150);
l_je_line_attribute10 VARCHAR2(150);
l_je_line_tax_type_code VARCHAR2(1);
l_je_line_found NUMBER(15);
l_je_line_num NUMBER(15);
le_id               NUMBER; -- legal entity id
x_return_status     VARCHAR2(30);
x_msg_out           VARCHAR2(2000);
--
-- move_taxes_err EXCEPTION;
--
CURSOR je_headers (batch_id_in NUMBER)
IS
  SELECT je_header_id,name,je_source,tax_status_code, ledger_id
  FROM gl_je_headers
  WHERE je_batch_id = batch_id_in
  FOR UPDATE;
--
CURSOR je_lines (header_id_in NUMBER)
IS
  SELECT je_line_num,period_name,effective_date,status,
    tax_code,amount_includes_tax_flag,tax_code_id,
    attribute9,attribute10
  FROM gl_je_lines
  WHERE je_header_id = header_id_in
  FOR UPDATE;
--
BEGIN
  --
  BEGIN
    SELECT org_id,
      budgetary_control_status, actual_flag,
      approval_status_code, status, name
    INTO l_org_id,
      l_budgetary_control_status, l_actual_flag,
      l_approval_status_code, l_status, l_name
    FROM GL_JE_BATCHES
    WHERE je_batch_id = p_batch_id;
    --
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
          l_org_id := -1;
  END;
  --
  IF l_org_id = -1
  THEN
    -- deliver a message to a log file
    GL_MESSAGE.Write_Log(msg_name  =>'SHRD0180',
                      token_num => 2,
                      t1        =>'ROUTINE',
                      v1        =>
                      'GL_JOURNAL_IMPORT_TAX_PKG.move_taxes',
                      t2        =>'ACTION',
                      v2        =>'Batch name:'
                                || l_name
                                ||' :SOB does not exist');
    RETURN;
  END IF;
  --
  IF
    (l_status <> 'U')
  THEN
    -- deliver a message to a log file
    GL_MESSAGE.Write_Log(msg_name  =>'SHRD0180',
                      token_num => 2,
                      t1        =>'ROUTINE',
                      v1        =>
                      'GL_JOURNAL_IMPORT_TAX_PKG.move_taxes',
                      t2        =>'ACTION',
                      v2        =>'Batch name: '
                                || l_name
                                || ':cannot be taxed because '
                                || 'status is not U');
    RETURN;
  END IF;
  --
  IF
    (l_budgetary_control_status NOT IN ('R','N') )
  THEN
    -- deliver a message to a log file
    GL_MESSAGE.Write_Log(msg_name  =>'SHRD0180',
                      token_num => 2,
                      t1        =>'ROUTINE',
                      v1        =>
                      'GL_JOURNAL_IMPORT_TAX_PKG.move_taxes',
                      t2        =>'ACTION',
                      v2        =>'Batch name: '
                                || l_name
                                || ':cannot be taxed because '
                                || 'budgetary_control_status is not in R,N');
    RETURN;
  END IF;
  --
  IF
    (l_actual_flag <> 'A' )
  THEN
    -- deliver a message to a log file
    GL_MESSAGE.Write_Log(msg_name  =>'SHRD0180',
                      token_num => 2,
                      t1        =>'ROUTINE',
                      v1        =>
                      'GL_JOURNAL_IMPORT_TAX_PKG.move_taxes',
                      t2        =>'ACTION',
                      v2        =>'Batch name: '
                                || l_name
                                || ':cannot be taxed because '
                                || 'actual_flag is not A');
    RETURN;
  END IF;
  --
  --IF
  --  (l_approval_status_code <> 'I' )
  --THEN
    -- deliver a message to a log file
  --  GL_MESSAGE.Write_Log(msg_name  =>'SHRD0180',
  --                    token_num => 2,
  --                    t1        =>'ROUTINE',
  --                    v1        =>
  --                    'GL_JOURNAL_IMPORT_TAX_PKG.move_taxes',
  --                    t2        =>'ACTION',
  --                    v2        =>'Batch name: '
  --                              || l_name
  --                              || ':cannot be taxed because '
  --                              || 'approval_status_code is not I');
    --RETURN;
  --END IF;
  --
  l_batch_tax_required := 0;
  --
  -- we should figure out the value of org_id and put it into l_org_id
  -- from profile ORG_ID (MO: Operating Unit)
  --
  l_org_id := FND_PROFILE.VALUE_WNPS('ORG_ID');
  IF l_org_id IS NULL
  THEN
    l_org_id := -1;
  END IF;
  --
  BEGIN
    SELECT name
    INTO l_org_name
    FROM hr_operating_units
    WHERE organization_id = l_org_id;
    --
    EXCEPTION
        WHEN NO_DATA_FOUND
        THEN
          l_org_name := '';
  END;
  --
  --GL_MESSAGE.Write_Log(msg_name  =>'SHRD0180',
  --                  token_num => 2,
  --                  t1        =>'ROUTINE',
  --                  v1        =>
  --                  'GL_JOURNAL_IMPORT_TAX_PKG.move_taxes',
  --                  t2        =>'ACTION',
  --                  v2        =>'Profile ORG_ID organization name:'
  --                            || l_org_name
  --                            || ':is used for further processing');
  --
  OPEN je_headers(p_batch_id);
  LOOP
    FETCH je_headers INTO
      l_je_header_id,
      l_je_header_name,
      l_je_header_je_source,
      l_je_header_tax_status_code,
      l_ledger_id;
    IF je_headers%NOTFOUND
    THEN
      EXIT;
    END IF;
    --
    IF SUBSTR(l_je_header_je_source,1,11) <> 'Spreadsheet'
    THEN
      -- deliver a message to a log file
      GL_MESSAGE.Write_Log(msg_name  =>'SHRD0180',
                      token_num => 2,
                      t1        =>'ROUTINE',
                      v1        =>
                      'GL_JOURNAL_IMPORT_TAX_PKG.move_taxes',
                      t2        =>'ACTION',
                      v2        =>'Batch name:'
                                || l_name
                                ||':was not created by Spreadsheet');
      RETURN;
    END IF;
    --
    l_je_header_tax_required := 0;
    --
    OPEN je_lines(l_je_header_id);
    LOOP
      FETCH je_lines INTO
        l_je_line_num,
        l_je_line_period_name,
        l_je_line_effective_date,
        l_je_line_status,
        l_je_line_tax_code,
        l_je_line_tax_flag,
        l_je_line_tax_code_id,
        l_je_line_attribute9,
        l_je_line_attribute10;
      IF je_lines%NOTFOUND
      THEN
        EXIT;
      END IF;
      --
      -- process current je line
      --
      -- we suppose that l_je_line_attribute9 has a value of TAX_CODE
      -- and l_je_line_attribute10 has a value of AMOUNT_INCLUDES_TAX_FLAG(Y,N)
      --
      IF (l_je_line_attribute9 IS NOT NULL) AND
         (l_je_line_attribute10 IS NOT NULL)
      THEN
        --
        -- use GL_TAX_CODES_V to get tax_code_id
        --
        BEGIN
          --
          l_je_line_tax_flag := substr(l_je_line_attribute10,1,1);
          l_je_line_found := 1;
          l_je_line_tax_type_code := ' ';
          -- some questions about SELECT
          le_id := XLE_UTILITIES_GRP.Get_DefaultLegalContext_OU(
                   l_org_id);
          zx_gl_tax_options_pkg.get_tax_rate_id (
               1.0,
               l_org_id,
               le_id,
               l_je_line_attribute9,
               sysdate,
               l_je_line_tax_type_code,
               l_je_line_tax_code_id,
               x_return_status,
               x_msg_out);


          SELECT tax_code_id, tax_type_code
          INTO l_je_line_tax_code_id, l_je_line_tax_type_code
          FROM GL_TAX_CODES_V
          WHERE org_id = l_org_id AND
            ledger_id = l_ledger_id AND
            tax_code = l_je_line_attribute9 AND
            valid_flag = 'Y' AND
            displayed_flag = 'Y' AND
            enabled_flag = 'Y' AND
            sysdate BETWEEN nvl(start_date,sysdate) AND
            nvl(end_date,sysdate);
          --
          EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
              l_je_line_found := -1;
        END;
        --
        IF l_je_line_found = 1
        THEN
          --
          --  if tax details are present in current line,
          --  then update gl_je_lines details
          --
          UPDATE gl_je_lines
          SET tax_code_id = l_je_line_tax_code_id,
              amount_includes_tax_flag = l_je_line_tax_flag,
              tax_type_code = l_je_line_tax_type_code,
              tax_rounding_rule_code = 'N',
              taxable_line_flag = 'Y'
          WHERE CURRENT OF je_lines;
          --WHERE je_header_id = l_je_header_id AND
          --  je_line_num = l_je_line_num;
          l_je_header_tax_required := 1;
        ELSE
          -- deliver a message to a log file
          GL_MESSAGE.Write_Log(msg_name  =>'SHRD0180',
                      token_num => 2,
                      t1        =>'ROUTINE',
                      v1        =>
                      'GL_JOURNAL_IMPORT_TAX_PKG.move_taxes',
                      t2        =>'ACTION',
                      v2        =>'Tax code:'
                                || l_je_line_attribute9
                                ||':cannot be found');
        END IF;
      END IF;
      --
    END LOOP;
    CLOSE je_lines;
    --
    --  if any line has been updated for taxes in current header,
    --  then update gl_je_headers details
    --
    IF l_je_header_tax_required = 1
    THEN
      UPDATE gl_je_headers
      SET tax_status_code = 'R'
      WHERE CURRENT OF je_headers;
      --WHERE je_header_id = l_je_header_id;
      l_batch_tax_required := 1;
    END IF;
    --
  END LOOP;
  CLOSE je_headers;
  --
  -- do not forget to update org_id at batch level
  --
  IF l_batch_tax_required = 1
  THEN
    UPDATE gl_je_batches
    SET org_id = l_org_id
    WHERE je_batch_id = p_batch_id;
  END IF;
  --
  --COMMIT;
  --
END move_taxes_hook;
--
--
--
PROCEDURE process_batch_list(p_batch_ids  IN     VARCHAR2,
                             p_separator  IN     VARCHAR2)
IS
l_last_sep_pos NUMBER(15);
l_new_sep_pos NUMBER(15);
l_cur_batch_id_str VARCHAR2(30);
l_cur_batch_id_num NUMBER(15);
--
BEGIN
  --
  l_last_sep_pos := 0;
  LOOP
    l_new_sep_pos := INSTR(p_batch_ids,p_separator,l_last_sep_pos+1,1);
    --
    IF l_new_sep_pos > 0
    THEN
      l_cur_batch_id_str :=
        SUBSTR(p_batch_ids,l_last_sep_pos+1,l_new_sep_pos-l_last_sep_pos-1);
      l_cur_batch_id_num := to_number(l_cur_batch_id_str,'9999999999');
      GL_JOURNAL_IMPORT_TAX_PKG.move_taxes_hook(l_cur_batch_id_num);
      --
      IF (l_new_sep_pos = LENGTH(p_batch_ids))
      THEN
        EXIT;
      END IF;
      --
      l_last_sep_pos := l_new_sep_pos;
      --
    END IF;
    --
  END LOOP;
  --
END process_batch_list;
--
END GL_JOURNAL_IMPORT_TAX_PKG;

/
