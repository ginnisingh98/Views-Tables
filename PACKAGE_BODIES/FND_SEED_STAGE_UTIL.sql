--------------------------------------------------------
--  DDL for Package Body FND_SEED_STAGE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_SEED_STAGE_UTIL" as
/* $Header: fndpstub.pls 120.4.12010000.3 2011/01/19 14:39:41 smadhapp ship $ */


G_MSG_TAB       CHAR4K_TAB;
G_DISPLAY_MSG   BOOLEAN := FALSE;
l_max_err       PLS_INTEGER :=100;

PROCEDURE insert_msg( p_msg_str IN VARCHAR2)
IS
BEGIN
  G_MSG_TAB(G_MSG_TAB.COUNT + 1) := p_msg_str;
END insert_msg;

PROCEDURE update_status( p_debug IN NUMBER,
                         p_seq IN NUMBER,
                         p_status IN NUMBER)
IS
  type csr_type IS REF CURSOR;
  upd_csr     csr_type;
  l_str       VARCHAR2(4000);
BEGIN
  if p_debug = 0 then
    l_str := 'UPDATE fnd_seed_stage_entity
                 SET exec_status = :1
               WHERE seq = :2';
  else
    l_str := 'UPDATE fnd_seed_stage_entity_debug
                 SET exec_status = :1
               WHERE seq = :2';
  end if;

  EXECUTE IMMEDIATE l_str USING p_status, p_seq;

END update_status;

PROCEDURE get_messages(p_msg_to IN NUMBER,
                       x_msg_tab OUT NOCOPY CHAR4K_TAB)
IS
BEGIN
  if G_MSG_TAB.COUNT > 0 then
    FOR i IN l_max_err+1 .. p_msg_to
    LOOP
      x_msg_tab(i-l_max_err) := G_MSG_TAB(i);
    END LOOP;
  end if;
  G_MSG_TAB.DELETE(l_max_err+1, p_msg_to);
END get_messages;

PROCEDURE get_messages(p_msg_from IN NUMBER,
                       p_msg_to IN NUMBER,
                       x_msg_tab OUT NOCOPY CHAR4K_TAB)
IS
BEGIN
  if G_MSG_TAB.COUNT > 0 then
    FOR i IN p_msg_from .. p_msg_to
    LOOP
      x_msg_tab(i) := G_MSG_TAB(i);
    END LOOP;
  end if;
  G_MSG_TAB.DELETE(p_msg_from, p_msg_to);
END get_messages;

PROCEDURE get_messages(x_msg_tab OUT NOCOPY CHAR4K_TAB)
IS
counter number := 0;
BEGIN
  if G_MSG_TAB.COUNT > 0 then
    FOR i IN G_MSG_TAB.FIRST .. G_MSG_TAB.LAST
    LOOP
      x_msg_tab(i) := G_MSG_TAB(i);
      counter := counter + 1;
      exit when counter > 100;
    END LOOP;
  end if;
  G_MSG_TAB.DELETE;
END get_messages;

PROCEDURE UPLOAD (p_lct_file IN VARCHAR2,
                  p_proc_id IN NUMBER,
                  p_debug IN NUMBER,
                  x_abort OUT NOCOPY NUMBER,
                  x_warning OUT NOCOPY NUMBER,
                  x_err_count OUT NOCOPY NUMBER,
                  x_err_tab OUT NOCOPY CHAR4K_TAB)
IS
  TYPE csr_type IS REF CURSOR;

  config_csr          csr_type;
  l_upload_lob        FND_SEED_STAGE_CONFIG.UPLOAD_STMT%TYPE;
  l_stmt_len          FND_SEED_STAGE_CONFIG.STMT_LEN%TYPE;

  status_csr          csr_type;
  l_str               VARCHAR2(4000);

  l_upload_arr        DBMS_SQL.VARCHAR2S;
  l_upload_stmt       VARCHAR2(32767);
  l_amt               BINARY_INTEGER;
  l_offset            INTEGER;
  l_read_cnt          PLS_INTEGER;
  l_csr               INTEGER;
  l_msg               VARCHAR2(4000);
  l_ret               INTEGER;
  --l_max_err           PLS_INTEGER;
  l_err_count         INTEGER;
  l_status            VARCHAR2(10);
  l_buffer            VARCHAR2(32767);

--ret  INTEGER;
BEGIN

--ret := DBMS_PROFILER.START_PROFILER('FNDLOAD_ReuseLct'||to_char(sysdate, 'HH24:MI:SS'));

  x_err_count := 0;
  x_abort := 0;
  x_warning := 0;
--  l_status := 0;
  --l_max_err := 100;

--DBMS_OUTPUT.PUT_LINE('1111111');
G_MSG_TAB.delete;

  if p_debug = 0 then
    l_str := 'SELECT upload_stmt, stmt_len
              FROM fnd_seed_stage_config
              WHERE lct_file = :1
              AND proc_id = :2
              AND entity_name = ''PLSQL_WRAPPER_CODE''';
  else
    l_str := 'SELECT upload_stmt, stmt_len
              FROM fnd_seed_stage_config_debug
              WHERE lct_file = :1
              AND proc_id = :2
              AND entity_name = ''PLSQL_WRAPPER_CODE''';
  end if;

  OPEN config_csr FOR l_str USING p_lct_file, p_proc_id;
  FETCH config_csr INTO l_upload_lob, l_stmt_len;
  if config_csr%NOTFOUND then
    l_msg := 'No record found in FND_SEED_STAGE_CONFIG with the plsql wrapper code';
    x_abort := 1;
    x_err_count := 1;
    x_err_tab(1) := l_msg;
    CLOSE config_csr;
    RETURN;
  end if;
  CLOSE config_csr;

  BEGIN
    if l_stmt_len <= 32767 then
      l_offset := 1;
      BEGIN
      LOOP
        l_amt := 32767;
        DBMS_LOB.READ(l_upload_lob, l_amt, l_offset, l_buffer);
        l_upload_stmt := l_upload_stmt||l_buffer;
        l_offset := l_offset + l_amt;
      END LOOP;
      EXCEPTION WHEN NO_DATA_FOUND THEN
        NULL;
      END;
      EXECUTE IMMEDIATE l_upload_stmt;
    else
      l_offset := 1;
      l_read_cnt := 1;
      BEGIN
      LOOP
        l_amt := 256;
        DBMS_LOB.READ(l_upload_lob, l_amt, l_offset, l_upload_arr(l_read_cnt));
        l_offset := l_offset + l_amt;
        l_read_cnt := l_read_cnt + 1;
      END LOOP;
      EXCEPTION WHEN NO_DATA_FOUND THEN
        NULL;
      END;

      l_csr := DBMS_SQL.OPEN_CURSOR;

      BEGIN
        DBMS_SQL.PARSE(l_csr, l_upload_arr, 1, l_read_cnt-1, FALSE, DBMS_SQL.NATIVE);
      EXCEPTION WHEN OTHERS THEN
          DBMS_SQL.CLOSE_CURSOR(l_csr);
          l_msg := SUBSTR('Error parsing the generated plsql wrapper statement '||sqlerrm(sqlcode), 1, 4000);
          x_abort := 1;
          x_err_count := 1;
          x_err_tab(1) := l_msg;
          RETURN;
      END;

      l_ret := DBMS_SQL.EXECUTE(l_csr);

      DBMS_SQL.CLOSE_CURSOR(l_csr);

    end if;
  END;

  l_err_count := G_MSG_TAB.COUNT;
  x_err_count := l_err_count;
  if l_err_count > l_max_err then
    --x_err_count := l_max_err;
    get_messages(1, l_max_err, x_err_tab);
  else
    --x_err_count := l_err_count;
    x_err_tab := G_MSG_TAB;
  end if;

  if p_debug = 0 then
    l_str := 'SELECT exec_status
                FROM fnd_seed_stage_entity
               WHERE seq = -1
                 AND config_id = -1';
  else
    l_str := 'SELECT exec_status
                FROM fnd_seed_stage_entity_debug
               WHERE seq = -1
                 AND config_id = -1';
  end if;

  OPEN status_csr FOR l_str;
  FETCH status_csr INTO l_status;
  CLOSE status_csr;
--DBMS_OUTPUT.PUT_LINE('status = '||l_status);
  if l_status = '1' then
    x_abort := 1;
  elsif l_status = '2' then
    x_warning := 1;
  end if;

--ret := DBMS_PROFILER.STOP_PROFILER;

EXCEPTION WHEN OTHERS THEN
  if config_csr%ISOPEN then
    CLOSE config_csr;
  end if;
  if DBMS_SQL.IS_OPEN(l_csr) then
    DBMS_SQL.CLOSE_CURSOR(l_csr);
  end if;
  if status_csr%ISOPEN then
    CLOSE status_csr;
  end if;
  l_msg := SUBSTR('Error during uploading. '||sqlerrm, 1, 4000);
  x_abort := 1;
  x_err_count := 1;
  x_err_tab(1) := l_msg;
END UPLOAD;

PROCEDURE create_temp_clob(p_temp_clob IN OUT NOCOPY CLOB)
is
begin
  dbms_lob.createtemporary(p_temp_clob,true,dbms_lob.session);
end;

end FND_SEED_STAGE_UTIL;

/
