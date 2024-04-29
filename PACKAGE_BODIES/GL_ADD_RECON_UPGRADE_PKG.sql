--------------------------------------------------------
--  DDL for Package Body GL_ADD_RECON_UPGRADE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_ADD_RECON_UPGRADE_PKG" AS
/* $Header: glurcnub.pls 120.2 2006/02/08 23:32:40 vtreiger noship $ */
  --
  -- PRIVATE GLOBAL VARIABLES
  --
  g_api  CONSTANT VARCHAR2(40) := 'gl.plsql.GL_ADD_RECON_UPGRADE_PKG';
  g_gl_je_lines_table CONSTANT VARCHAR2(30) := 'GL_JE_LINES';
  g_table_name    CONSTANT VARCHAR2(30) := 'GL_CODE_COMBINATIONS';
  g_id_column     CONSTANT VARCHAR2(30) := 'CODE_COMBINATION_ID';
  g_script_name   CONSTANT VARCHAR2(30) := 'glurcnub.pls';
  --
  g_std_ins CONSTANT VARCHAR2(1500) :=
    'INSERT INTO gl_je_lines_recon ' ||
    '(je_header_id,je_line_num,ledger_id,' ||
    'jgzz_recon_status,jgzz_recon_date,' ||
    'jgzz_recon_id,jgzz_recon_ref,' ||
    'last_update_date,last_updated_by,' ||
    'creation_date,created_by,last_update_login) ' ||
    'SELECT /*+ ORDERED INDEX(c gl_code_combinations_u1) */ ' ||
    'l.je_header_id,l.je_line_num,l.ledger_id, ' ||
    'nvl(l.jgzz_recon_status_11i,' || '''' || 'U' || '''' || ')' ||
    ',l.jgzz_recon_date_11i, ' ||
    'l.jgzz_recon_id_11i,l.jgzz_recon_ref_11i, ' ||
    'sysdate, -2, sysdate, -2, 1 ' ||
    'FROM gl_code_combinations c, gl_je_lines l ' ||
    ' WHERE c.code_combination_id between :start_id and :end_id ' ||
    'AND c.code_combination_id = l.code_combination_id ' ||
    'AND c.jgzz_recon_flag = ' || '''' || 'Y' || '''' ||
    ' AND NOT EXISTS ' ||
    '(SELECT /*+ ORDERED INDEX(r gl_je_lines_recon_u1) */  1 ' ||
    'FROM gl_je_lines_recon r ' ||
    'WHERE r.je_header_id = l.je_header_id ' ||
    'AND r.je_line_num = l.je_line_num) ';
  --
  -- PRIVATE FUNCTIONS
  --
  --
  -- Function
  --   prepare_recon_update
  -- Purpose
  --   Insert data into gl_je_lines_recon.
  -- History
  --   08/26/2005   V Treiger      Created
  -- Arguments
  --   x_start_id     Start id for AD parallel range, gl_je_lines_recon upgrade only
  --   x_end_id       End   id for AD parallel range, gl_je_lines_recon upgrade only
  --
  FUNCTION prepare_recon_update(x_start_id  NUMBER DEFAULT NULL,
                                x_end_id    NUMBER DEFAULT NULL)
  RETURN NUMBER
  IS
  --
    l_rows NUMBER := 0;
    fn_name       CONSTANT VARCHAR2(30) := 'PREPARE_RECON_UPDATE';
  --
  BEGIN
    GL_MESSAGE.FUNC_ENT(fn_name, FND_LOG.LEVEL_PROCEDURE,
                        g_api || '.' || fn_name);
    -- parameters
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL >= FND_LOG.LEVEL_PROCEDURE) THEN
      GL_MESSAGE.WRITE_FNDLOG_STRING(FND_LOG.LEVEL_PROCEDURE,
                                   g_api || '.' || fn_name,
                                   'x_src_table = ' || 'gl_je_lines');
      GL_MESSAGE.WRITE_FNDLOG_STRING(FND_LOG.LEVEL_PROCEDURE,
                                   g_api || '.' || fn_name,
                                   'x_start_id = ' || x_start_id);
      GL_MESSAGE.WRITE_FNDLOG_STRING(FND_LOG.LEVEL_PROCEDURE,
                                   g_api || '.' || fn_name,
                                   'x_end_id = ' || x_end_id);
    END IF;
    --
    EXECUTE IMMEDIATE g_std_ins USING x_start_id, x_end_id;
    l_rows := SQL%ROWCOUNT;
    --
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL >= FND_LOG.LEVEL_PROCEDURE) THEN
      GL_MESSAGE.FUNC_SUCC(fn_name, FND_LOG.LEVEL_PROCEDURE,
                         g_api || '.' || fn_name);
    END IF;
    RETURN l_rows;
  EXCEPTION
    WHEN OTHERS THEN
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL >= FND_LOG.LEVEL_PROCEDURE) THEN
        GL_MESSAGE.WRITE_FNDLOG_STRING(FND_LOG.LEVEL_UNEXPECTED,
                                     g_api || '.' || fn_name,
                                     SUBSTR(SQLERRM, 1, 4000));
        GL_MESSAGE.FUNC_FAIL(fn_name, FND_LOG.LEVEL_UNEXPECTED,
                           g_api || '.' || fn_name);
      END IF;
      RAISE;
      RETURN l_rows;
  END prepare_recon_update;
  --
  --
  -- PUBLIC FUNCTIONS
  --
  PROCEDURE upgrade_recon(
                  x_errbuf       OUT NOCOPY VARCHAR2,
                  x_retcode      OUT NOCOPY VARCHAR2,
                  x_batch_size              NUMBER,
                  x_num_workers             NUMBER) IS
    fn_name       CONSTANT VARCHAR2(30) := 'UPGRADE_RECON';
    SUBMIT_REQ_ERROR       EXCEPTION;
    --
    l_req_data          VARCHAR2(10);
    l_req_id            NUMBER;
    --
    l_retstatus         BOOLEAN;
    l_status            VARCHAR2(30);
    l_industry          VARCHAR2(30);
    l_table_owner       VARCHAR2(30);
    l_gl_schema         VARCHAR2(30);
    l_applsys_schema    VARCHAR2(30);
  BEGIN
    GL_MESSAGE.FUNC_ENT(fn_name, FND_LOG.LEVEL_PROCEDURE,
                        g_api || '.' || fn_name);
    -- parameters
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL >= FND_LOG.LEVEL_PROCEDURE) THEN
      GL_MESSAGE.WRITE_FNDLOG_STRING(FND_LOG.LEVEL_PROCEDURE,
                                   g_api || '.' || fn_name,
                                   'x_batch_size = ' || x_batch_size);
      GL_MESSAGE.WRITE_FNDLOG_STRING(FND_LOG.LEVEL_PROCEDURE,
                                   g_api || '.' || fn_name,
                                   'x_num_workers = ' || x_num_workers);
    END IF;
    -- AD_CONC_UTILS_PKG.submit_subrequests sets request data
    l_req_data := FND_CONC_GLOBAL.request_data;
    --
    IF (l_req_data IS NULL) THEN  -- First time
        -- get schema name for GL and FND
        l_retstatus := fnd_installation.get_app_info(
                            'SQLGL', l_status, l_industry, l_gl_schema);
        IF (   (NOT l_retstatus)
            OR (l_gl_schema is null)) THEN
          raise_application_error(-20001,
               'Cannot get schema name for product : SQLGL');
        END IF;
        --
        l_retstatus := fnd_installation.get_app_info(
                            'FND', l_status, l_industry, l_applsys_schema);
        IF (   (NOT l_retstatus)
            OR (l_applsys_schema is null)) THEN
          raise_application_error(-20001,
               'Cannot get schema name for product : FND');
        END IF;
        --
        -- Clean up AD update information in case number of workers changed
        -- Note: this procedure implicitly commits
        AD_PARALLEL_UPDATES_PKG.delete_update_information(
                    ad_parallel_updates_pkg.ID_RANGE,
                    l_gl_schema,
                    g_table_name,
                    g_script_name);
        --
        -- Submit child requests to update gl_je_lines_recon
        AD_CONC_UTILS_PKG.submit_subrequests(
               X_errbuf                    => x_errbuf,
               X_retcode                   => x_retcode,
               X_workerconc_app_shortname  => 'SQLGL',
               X_workerconc_progname       => 'GLRCNINS',
               X_batch_size                => x_batch_size,
               X_num_workers               => x_num_workers,
               X_argument4                 => l_gl_schema);
        --
        -- If the request data hasn't been set, then the AD API did not
        -- successfully submit all child requests.
        l_req_data := FND_CONC_GLOBAL.request_data;
        IF (l_req_data IS NULL) THEN
          RAISE SUBMIT_REQ_ERROR;
        END IF;
        --
    ELSE  -- Restart case
      -- check status of all subrequests ( since
      -- the program is not really used for a restart)
      -- * If we want to produce an execution report, it may be more effecient
      --   not to use the API since that would mean we are getting
      --   sub-requests and loop through them twice.
      --
      AD_CONC_UTILS_PKG.submit_subrequests(
               X_errbuf                    => x_errbuf,
               X_retcode                   => x_retcode,
               -- for restart, the rest of the parameters are not really used
               X_workerconc_app_shortname  => 'SQLGL',
               X_workerconc_progname       => 'GLRCNINS',
               X_batch_size                => x_batch_size,
               X_num_workers               => x_num_workers,
               X_argument4                 => l_gl_schema);
      --
      IF (x_retcode = AD_CONC_UTILS_PKG.CONC_SUCCESS) THEN
        UPDATE GL_SYSTEM_USAGES
        SET    reconciliation_upg_flag = 'Y',
             last_update_date = sysdate,
             last_updated_by = 1,
             last_update_login = 0;
      END IF;
      --
    END IF;
    --
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL >= FND_LOG.LEVEL_PROCEDURE) THEN
      GL_MESSAGE.FUNC_SUCC(fn_name, FND_LOG.LEVEL_PROCEDURE,
                         g_api || '.' || fn_name);
    END IF;
    --
  EXCEPTION
    WHEN SUBMIT_REQ_ERROR THEN
      x_retcode := AD_CONC_UTILS_PKG.CONC_FAIL;
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL >= FND_LOG.LEVEL_PROCEDURE) THEN
        GL_MESSAGE.WRITE_LOG(msg_name  => 'SHRD0055',
                           token_num => 1,
                           t1        => 'ROUTINE',
                           v1        => fn_name,
                           log_level => FND_LOG.LEVEL_PROCEDURE,
                           module    => g_api || '.' || fn_name);
        GL_MESSAGE.FUNC_FAIL(fn_name, FND_LOG.LEVEL_UNEXPECTED,
                           g_api || '.' || fn_name);
      END IF;
      RAISE;
    WHEN OTHERS THEN
      x_retcode := AD_CONC_UTILS_PKG.CONC_FAIL;
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL >= FND_LOG.LEVEL_PROCEDURE) THEN
        GL_MESSAGE.WRITE_FNDLOG_STRING(FND_LOG.LEVEL_UNEXPECTED,
                                     g_api || '.' || fn_name,
                                     SUBSTR(SQLERRM, 1, 4000));
        GL_MESSAGE.FUNC_FAIL(fn_name, FND_LOG.LEVEL_UNEXPECTED,
                           g_api || '.' || fn_name);
      END IF;
      RAISE;
  END upgrade_recon;
  --
  PROCEDURE update_gl_je_lines_recon_table(
                  x_errbuf       OUT NOCOPY VARCHAR2,
                  x_retcode      OUT NOCOPY VARCHAR2,
                  x_batch_size              NUMBER,
                  x_worker_Id               NUMBER,
                  x_num_workers             NUMBER,
                  x_argument4               VARCHAR2) IS
    fn_name       CONSTANT VARCHAR2(30) := 'UPDATE_GL_JE_LINES_RECON_TABLE';
    --
    l_any_rows_to_process  BOOLEAN;
    l_start_id             NUMBER;
    l_end_id               NUMBER;
    l_rows_processed       NUMBER;
    --
  BEGIN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'X_Worker_Id   : ' || X_Worker_Id);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'X_Num_Workers : ' || X_Num_Workers);
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Session Id    : ' ||
                                    FND_GLOBAL.session_id);
    --
    GL_MESSAGE.FUNC_ENT(fn_name, FND_LOG.LEVEL_PROCEDURE,
                        g_api || '.' || fn_name);
    -- parameters
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL >= FND_LOG.LEVEL_PROCEDURE) THEN
      GL_MESSAGE.WRITE_FNDLOG_STRING(FND_LOG.LEVEL_PROCEDURE,
                                   g_api || '.' || fn_name,
                                   'x_batch_size = ' || x_batch_size);
      GL_MESSAGE.WRITE_FNDLOG_STRING(FND_LOG.LEVEL_PROCEDURE,
                                   g_api || '.' || fn_name,
                                   'x_argument4 = ' || x_argument4);
    END IF;
    --
    ad_parallel_updates_pkg.initialize_id_range(
                    ad_parallel_updates_pkg.ID_RANGE,
                    x_argument4,
                    g_table_name,
                    g_script_name,
                    g_id_column,
                    x_worker_id,
                    x_num_workers,
                    x_batch_size, 0);
    --
    ad_parallel_updates_pkg.get_id_range(
                    l_start_id,
                    l_end_id,
                    l_any_rows_to_process,
                    x_batch_size,
                    TRUE);
    --
    while (l_any_rows_to_process)
    loop
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_start_id : ' || l_start_id);
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_end_id   : ' || l_end_id);
      --
      l_rows_processed := prepare_recon_update(l_start_id,l_end_id);
      --
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_rows_processed : ' || l_rows_processed);
      --
      ad_parallel_updates_pkg.processed_id_range(
                  l_rows_processed,
                  l_end_id);
      --
      fnd_concurrent.af_commit;
      --
      ad_parallel_updates_pkg.get_id_range(
                 l_start_id,
                 l_end_id,
                 l_any_rows_to_process,
                 x_batch_size,
                 FALSE);
      --
    end loop;
    --
    x_retcode := AD_CONC_UTILS_PKG.CONC_SUCCESS;
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL >= FND_LOG.LEVEL_PROCEDURE) THEN
      GL_MESSAGE.FUNC_SUCC(fn_name, FND_LOG.LEVEL_PROCEDURE,
                         g_api || '.' || fn_name);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_errbuf := SUBSTR(SQLERRM, 1, 240);
      x_retcode := AD_CONC_UTILS_PKG.CONC_FAIL;
      IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL >= FND_LOG.LEVEL_PROCEDURE) THEN
        GL_MESSAGE.WRITE_FNDLOG_STRING(FND_LOG.LEVEL_UNEXPECTED,
                                     g_api || '.' || fn_name,
                                     SUBSTR(SQLERRM, 1, 4000));
        GL_MESSAGE.FUNC_FAIL(fn_name, FND_LOG.LEVEL_UNEXPECTED,
                           g_api || '.' || fn_name);
      END IF;
      RAISE;
  END update_gl_je_lines_recon_table;

END GL_ADD_RECON_UPGRADE_PKG;

/
