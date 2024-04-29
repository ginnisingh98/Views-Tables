--------------------------------------------------------
--  DDL for Package Body CST_UPD_GIR_MTA_WTA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_UPD_GIR_MTA_WTA" AS
/* $Header: CSTGIRMWB.pls 120.1.12010000.1 2008/10/28 18:53:03 hyu noship $ */

-- Local procedures and variables

PG_DEBUG VARCHAR2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE debug
( line       IN VARCHAR2,
  msg_prefix IN VARCHAR2  DEFAULT 'CST',
  msg_module IN VARCHAR2  DEFAULT 'cst_upd_gir_mta_wta',
  msg_level  IN NUMBER    DEFAULT FND_LOG.LEVEL_STATEMENT);

--

PROCEDURE cst_sl_link_upg_mta (p_je_batch_id   IN NUMBER) AS

CURSOR cu_gir(p_je_batch_id IN NUMBER) IS
SELECT jle.code_combination_id,
       gir.rowid,
       gir.reference_1,
       xla_gl_sl_link_id_s.nextval
  FROM gl_je_headers        gh,
       gl_import_references gir,
       gl_je_lines          jle
 WHERE gh.je_batch_id       = p_je_batch_id
   AND gh.je_header_id      = jle.je_header_id
   AND gir.je_header_id     = jle.je_header_id
   AND gir.je_line_num      = jle.je_line_num
   AND gir.gl_sl_link_table = 'MTA'
   AND gir.gl_sl_link_id    IS NULL;

ccid_tab           DBMS_SQL.NUMBER_TABLE;
gir_rowid_tab      DBMS_SQL.VARCHAR2_TABLE;
gl_batch_id_tab    DBMS_SQL.NUMBER_TABLE;
gl_sl_link_id_tab  DBMS_SQL.NUMBER_TABLE;
l_inv_sl_id_tab    DBMS_SQL.NUMBER_TABLE;


CURSOR cu_xla_line IS
SELECT l.rowid,
       m.gl_sl_link_id
  FROM mtl_transaction_accounts m,
       cst_lists_temp           c,
       xla_distribution_links   lk,
       xla_ae_lines             l
 WHERE lk.application_id               = 707
   AND lk.source_distribution_type     = 'MTL_TRANSACTION_ACCOUNTS'
   AND lk.source_distribution_id_num_1 = c.number_1
   AND lk.application_id               = 707
   AND lk.ae_header_id                 = l.ae_header_id
   AND lk.ae_line_num                  = l.ae_line_num
   AND l.application_id                = 707
   AND m.transaction_id                = c.number_2
   AND m.inv_sub_ledger_id             = c.number_1
   AND m.reference_account             = c.number_3;

xline_rowid_tab    DBMS_SQL.VARCHAR2_TABLE;
xl_link_id_tab     DBMS_SQL.NUMBER_TABLE;

l_last_fetch  BOOLEAN := FALSE;
bulk_size     NUMBER  := 10000;
l_sql         NUMBER  := 0;

CURSOR cv IS
SELECT NULL
  FROM cst_lists_temp
 WHERE number_1 IS NULL
   AND list_id   = 999;

l_check       VARCHAR2(1);
BEGIN

  debug('cst_sl_link_upg_mta +');
  debug('  p_je_batch_id  :'||p_je_batch_id);


  OPEN cu_gir(p_je_batch_id);
  LOOP
     FETCH cu_gir BULK COLLECT INTO
     ccid_tab         ,
     gir_rowid_tab    ,
     gl_batch_id_tab  ,
     gl_sl_link_id_tab  LIMIT bulk_size;

     IF cu_gir%NOTFOUND THEN
        l_last_fetch := TRUE;
     END IF;

     IF (gir_rowid_tab.COUNT = 0) AND (l_last_fetch) THEN
       EXIT;
     END IF;

     debug('  Update GIR.GL_SL_LINK_ID for MTA');

     FORALL i IN gir_rowid_tab.FIRST .. gir_rowid_tab.LAST
      UPDATE gl_import_references
         SET gl_sl_link_id = gl_sl_link_id_tab(i)
       WHERE rowid   = gir_rowid_tab(i);

     l_sql := SQL%ROWCOUNT;

     IF l_sql <> 0 THEN

       debug('  Update MTA.GL_SL_LINK_ID for MTA');

       FORALL i IN gir_rowid_tab.FIRST .. gir_rowid_tab.LAST
        UPDATE mtl_transaction_accounts
           SET gl_sl_link_id     = gl_sl_link_id_tab(i)
         WHERE gl_batch_id       = gl_batch_id_tab(i)
           AND reference_account = ccid_tab(i);

       debug('  Insert Cst_Lists_Temp for MTA');

       FORALL i IN gir_rowid_tab.FIRST .. gir_rowid_tab.LAST
         INSERT INTO cst_lists_temp
         (list_id ,
          number_1,
          number_2,
          number_3,
          varchar_1)
         SELECT 999,
                inv_sub_ledger_id,
                transaction_id,
                reference_account,
                NULL
           FROM mtl_transaction_accounts
          WHERE gl_batch_id       = gl_batch_id_tab(i)
            AND reference_account = ccid_tab(i);
     END IF;

     OPEN cv;
     FETCH cv INTO l_check;
     IF cv%NOTFOUND THEN

          debug('  Update XAL.GL_SL_LINK_ID for MTA');

          OPEN cu_xla_line;
          FETCH cu_xla_line BULK COLLECT INTO
           xline_rowid_tab,
           xl_link_id_tab ;
           FORALL i IN xline_rowid_tab.FIRST .. xline_rowid_tab.LAST
           UPDATE xla_ae_lines
              SET gl_sl_link_id   = xl_link_id_tab(i)
            WHERE rowid   = xline_rowid_tab(i);
          CLOSE cu_xla_line;
     END IF;
     CLOSE cv;
     DELETE FROM cst_lists_temp;


  END LOOP;
  CLOSE cu_gir;

  debug('cst_sl_link_upg_mta -');

EXCEPTION
  WHEN OTHERS THEN
    IF cu_gir%ISOPEN      THEN CLOSE cu_gir;       END IF;
    IF cu_xla_line%ISOPEN THEN CLOSE cu_xla_line;  END IF;
    IF cv%ISOPEN          THEN CLOSE cv;           END IF;
    debug('EXCEPTION OTHERS cst_sl_link_upg_mta :'||SQLERRM);
    RAISE;
END cst_sl_link_upg_mta;





PROCEDURE cst_sl_link_upg_wta (p_je_batch_id   IN NUMBER) AS

CURSOR cu_gir(p_je_batch_id IN NUMBER) IS
SELECT jle.code_combination_id,
       gir.rowid,
       gir.reference_1,
       xla_gl_sl_link_id_s.nextval
  FROM gl_je_headers        gh,
       gl_import_references gir,
       gl_je_lines          jle
 WHERE gh.je_batch_id       = p_je_batch_id
   AND gh.je_header_id      = jle.je_header_id
   AND gir.je_header_id     = jle.je_header_id
   AND gir.je_line_num      = jle.je_line_num
   AND gir.gl_sl_link_table = 'WTA'
   AND gir.gl_sl_link_id    IS NULL;

CURSOR cu_xla_line IS
SELECT l.rowid,
       m.gl_sl_link_id
  FROM wip_transaction_accounts m,
       cst_lists_temp           c,
       xla_distribution_links   lk,
       xla_ae_lines             l
 WHERE lk.application_id               = 707
   AND lk.source_distribution_type     = 'WIP_TRANSACTION_ACCOUNTS'
   AND lk.source_distribution_id_num_1 = c.number_1
   AND lk.application_id               = 707
   AND lk.ae_header_id                 = l.ae_header_id
   AND lk.ae_line_num                  = l.ae_line_num
   AND l.application_id                = 707
   AND m.transaction_id                = c.number_2
   AND m.wip_sub_ledger_id             = c.number_1
   AND m.reference_account             = c.number_3;

CURSOR cv IS
SELECT NULL
  FROM cst_lists_temp
 WHERE number_1 IS NULL
   AND list_id   = 999;

xline_rowid_tab    DBMS_SQL.VARCHAR2_TABLE;
xl_link_id_tab     DBMS_SQL.NUMBER_TABLE;
ccid_tab           DBMS_SQL.NUMBER_TABLE;
gir_rowid_tab      DBMS_SQL.VARCHAR2_TABLE;
gl_batch_id_tab    DBMS_SQL.NUMBER_TABLE;
gl_sl_link_id_tab  DBMS_SQL.NUMBER_TABLE;
l_inv_sl_id_tab    DBMS_SQL.NUMBER_TABLE;
l_last_fetch       BOOLEAN := FALSE;
bulk_size          NUMBER  := 10000;
l_sql              NUMBER  := 0;
l_check            VARCHAR2(1);

BEGIN
  debug('cst_sl_link_upg_wta +');

  debug('  p_je_batch_id  :'||p_je_batch_id);

  OPEN cu_gir(p_je_batch_id);
  LOOP
     FETCH cu_gir BULK COLLECT INTO
     ccid_tab         ,
     gir_rowid_tab    ,
     gl_batch_id_tab  ,
     gl_sl_link_id_tab  LIMIT bulk_size;

     IF cu_gir%NOTFOUND THEN
        l_last_fetch := TRUE;
     END IF;

     IF (gir_rowid_tab.COUNT = 0) AND (l_last_fetch) THEN
       EXIT;
     END IF;

     debug('  Update GIR.GL_SL_LINK_ID for WTA');

     FORALL i IN gir_rowid_tab.FIRST .. gir_rowid_tab.LAST
      UPDATE gl_import_references
         SET gl_sl_link_id = gl_sl_link_id_tab(i)
       WHERE rowid   = gir_rowid_tab(i);

     l_sql := SQL%ROWCOUNT;

     IF l_sql <> 0 THEN

       debug('  Update WTA.GL_SL_LINK_ID for WTA');

       FORALL i IN gir_rowid_tab.FIRST .. gir_rowid_tab.LAST
        UPDATE wip_transaction_accounts
           SET gl_sl_link_id     = gl_sl_link_id_tab(i)
         WHERE gl_batch_id       = gl_batch_id_tab(i)
           AND reference_account = ccid_tab(i);

       debug('  Insert Cst_Lists_Temp for WTA');

       FORALL i IN gir_rowid_tab.FIRST .. gir_rowid_tab.LAST
         INSERT INTO cst_lists_temp
         (list_id ,
          number_1,
          number_2,
          number_3,
          varchar_1)
         SELECT 999,
                wip_sub_ledger_id,
                transaction_id,
                reference_account,
                NULL
           FROM wip_transaction_accounts
          WHERE gl_batch_id       = gl_batch_id_tab(i)
            AND reference_account = ccid_tab(i);
     END IF;

     OPEN cv;
     FETCH cv INTO l_check;
     IF cv%NOTFOUND THEN

          debug('  Insert XAL.GL_SL_LINK_ID for WTA');

          OPEN cu_xla_line;
          FETCH cu_xla_line BULK COLLECT INTO
           xline_rowid_tab,
           xl_link_id_tab ;
           FORALL i IN xline_rowid_tab.FIRST .. xline_rowid_tab.LAST
           UPDATE xla_ae_lines
              SET gl_sl_link_id   = xl_link_id_tab(i)
            WHERE rowid   = xline_rowid_tab(i);
          CLOSE cu_xla_line;
     END IF;
     CLOSE cv;
     DELETE FROM cst_lists_temp;


  END LOOP;
  CLOSE cu_gir;

  debug('cst_sl_link_upg_wta -');
EXCEPTION
  WHEN OTHERS THEN
    IF cu_gir%ISOPEN      THEN CLOSE cu_gir;       END IF;
    IF cu_xla_line%ISOPEN THEN CLOSE cu_xla_line;  END IF;
    IF cv%ISOPEN          THEN CLOSE cv;           END IF;
    debug('EXCEPTION OTHERS cst_sl_link_upg_wta :'||SQLERRM);
    RAISE;
END cst_sl_link_upg_wta;




PROCEDURE update_mta_wta
(errbuf           OUT  NOCOPY VARCHAR2,
 retcode          OUT  NOCOPY NUMBER,
 p_from_date      IN VARCHAR2,
 p_to_date        IN VARCHAR2,
 p_ledger_id      IN NUMBER)
IS
CURSOR c_glb(l_from_date IN DATE, l_to_date   IN DATE)
IS
select a.je_batch_id
  from gl_je_batches a,
       gl_period_statuses b
 where a.set_of_books_id_11i    = b.set_of_books_id
   and b.set_of_books_id        = p_ledger_id
   and a.default_effective_date >= l_from_date
   and a.default_effective_date <= l_to_date
   and b.migration_status_code  = 'U'
   and b.application_id         = 401
   and a.name                 like '%Inventory%';
l_je_batch_id   NUMBER;
l_from_date     DATE;
l_to_date       DATE;
BEGIN
  debug('update_mta_wta +');
  debug('  p_from_date   :'||p_from_date);
  debug('  p_to_date     :'||p_to_date);
  debug('  p_ledger_id   :'||p_ledger_id);


 -- l_from_date := to_date(p_from_date,'YYYY/MM/DD HH24:MI:SS');
 -- l_to_date   := to_date(p_to_date,'YYYY/MM/DD HH24:MI:SS');

  l_from_date := to_date(p_from_date,'YYYY/MM/DD');
  l_to_date   := to_date(p_to_date,'YYYY/MM/DD');


  OPEN c_glb(l_from_date, l_to_date);
  LOOP
    FETCH c_glb INTO l_je_batch_id;
    debug('  l_je_batch_id :'||l_je_batch_id);
    EXIT WHEN c_glb%NOTFOUND;
    cst_sl_link_upg_mta (p_je_batch_id => l_je_batch_id);
    cst_sl_link_upg_wta (p_je_batch_id => l_je_batch_id);
    COMMIT;
  END LOOP;
  CLOSE c_glb;

  debug('update_mta_wta -');

EXCEPTION
  WHEN OTHERS THEN
    IF c_glb%ISOPEN      THEN CLOSE c_glb;       END IF;
    debug('EXCEPTION OTHERS update_mta_wta :'||SQLERRM);
    RAISE;
END update_mta_wta;


PROCEDURE debug
( line       IN VARCHAR2,
  msg_prefix IN VARCHAR2  DEFAULT 'CST',
  msg_module IN VARCHAR2  DEFAULT 'cst_upd_gir_mta_wta',
  msg_level  IN NUMBER    DEFAULT FND_LOG.LEVEL_STATEMENT)
IS
  l_msg_prefix     VARCHAR2(64);
  l_msg_level      NUMBER;
  l_msg_module     VARCHAR2(256);
  l_beg_end_suffix VARCHAR2(15);
  l_org_cnt        NUMBER;
  l_line           VARCHAR2(32767);
BEGIN

  l_line       := line;
  l_msg_prefix := msg_prefix;
  l_msg_level  := msg_level;
  l_msg_module := msg_module;

  IF (INSTRB(upper(l_line), 'EXCEPTION') <> 0) THEN
    l_msg_level  := FND_LOG.LEVEL_EXCEPTION;
  END IF;

  IF l_msg_level <> FND_LOG.LEVEL_EXCEPTION AND PG_DEBUG = 'N' THEN
    RETURN;
  END IF;

  IF ( l_msg_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
     FND_LOG.STRING(l_msg_level, l_msg_module, SUBSTRB(l_line,1,4000));
  END IF;

EXCEPTION
  WHEN OTHERS THEN RAISE;
END debug;


END;

/
