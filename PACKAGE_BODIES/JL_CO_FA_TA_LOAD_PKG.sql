--------------------------------------------------------
--  DDL for Package Body JL_CO_FA_TA_LOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_CO_FA_TA_LOAD_PKG" AS
/* $Header: jlcoftlb.pls 120.4 2006/09/20 17:53:50 abuissa ship $ */

/* ======================================================================*
 | FND Logging infrastructure                                           |
 * ======================================================================*/
G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'JL_CO_FA_TA_LOAD_PKG';
G_CURRENT_RUNTIME_LEVEL     CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_UNEXPECTED          CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
G_LEVEL_ERROR               CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
G_LEVEL_EXCEPTION           CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_EVENT               CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
G_LEVEL_PROCEDURE           CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_STATEMENT           CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
G_MODULE_NAME               CONSTANT VARCHAR2(80) := 'JL.PLSQL.JL_CO_FA_TA_LOAD_PKG.';


PROCEDURE rollback_process(p_appraisal_id  NUMBER);


----------------------------------------------------------------------------
-- PROCEDURE                                                              --
--   load                                                                 --
--                                                                        --
-- DESCRIPTION                                                            --
--   Use this procedure to load  technical appraisals information into    --
--   system, validates loaded informatiom and generate a report on loaded --
--   information.                                                         --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11.5                                         --
--                                                                        --
-- PARAMETERS:                                                            --
--       p_file_name    - Full path name of file that contains appraisal  --                                                              --
--       information.                                                     --
-- HISTORY:                                                               --
--    05/18/99     Sujit Dalai    Created                                 --
----------------------------------------------------------------------------
PROCEDURE load  ( ERRBUF    OUT NOCOPY VARCHAR2,
                  RETCODE   OUT NOCOPY VARCHAR2,
                  p_file_name   VARCHAR2)  IS
   x_request_id               NUMBER;
   x_count                    NUMBER;
   x_appraisal_id             NUMBER;

   call_status                BOOLEAN;
   rphase                     VARCHAR2(80);
   rstatus                    VARCHAR2(80);
   dphase                     VARCHAR2(80);
   dstatus                    VARCHAR2(80);
   message                    VARCHAR2(240);
   dbg_msg                    VARCHAR2(4000);

   err_num                    NUMBER;
   err_msg                    VARCHAR2(2000);
   LOAD_ERROR                 EXCEPTION;
   REPORT_ERROR               EXCEPTION;
   l_api_name           CONSTANT VARCHAR2(30) := 'LOAD';


BEGIN

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'(+)');
   END IF;

   x_appraisal_id := -1;

              ---------------------------------------------------------
              --    Submit request to load technical appraisal       --
              ---------------------------------------------------------

   x_request_id := fnd_request.submit_request('JL',
                                               'JLCOFAMP',
                                               '',
                                               '',
                                               FALSE,
                                               p_file_name);

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_file.put_line( 1, 'Request id for loader pgm : '||to_char(x_request_id));
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Request id for loader pgm : '||to_char(x_request_id));
   END IF;

              ---------------------------------------------------------
              -- Rollback everything and complete the process with   --
              -- if concurrent request completes with error.         --
              ---------------------------------------------------------

   IF x_request_id = 0 THEN

     ROLLBACK_PROCESS(x_appraisal_id);
     RAISE LOAD_ERROR;
   ELSE
     COMMIT;
   END IF;

   call_status := fnd_concurrent.wait_for_request(x_request_id,
                                                  120,
                                                  0,
                                                  rphase,
                                                  rstatus,
                                                  dphase,
                                                  dstatus,
                                                  message);

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      dbg_msg := fnd_message.get;
      fnd_file.put_line(1, 'dbg_msg : '||dbg_msg);
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'dbg_msg : '||dbg_msg);
   END IF;

   IF dphase = 'COMPLETE' THEN
      IF dstatus = 'NORMAL' THEN
         fnd_file.put_line( 1, 'Loader pgm completed successfully. '||dphase||'-'||dstatus);
         COMMIT;
      ELSE
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_file.put_line( 1, 'Loader pgm completed. ');
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Loader pgm completed. ');
           fnd_file.put_line( 1, 'Phase and Status '||dphase||'-'||dstatus);
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Phase and Status '||dphase||'-'||dstatus);
           IF (call_status) THEN
              fnd_file.put_line( 1, 'Call Status '||'TRUE');
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Call Status '||'TRUE');
           ELSE
              fnd_file.put_line( 1, 'Call Status '||'FALSE');
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Call Status '||'FALSE');
           END IF;
        END IF;
        ROLLBACK_PROCESS(x_appraisal_id);
        RAISE LOAD_ERROR;
      END IF;
   ELSE
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         fnd_file.put_line( 1, 'Loader pgm is not completed. ');
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Loader pgm is not completed. ');
         fnd_file.put_line( 1, 'Phase and Status '||dphase||'-'||dstatus);
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Phase and Status '||dphase||'-'||dstatus);
         IF (call_status) THEN
            fnd_file.put_line( 1, 'Call Status '||'TRUE');
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Call Status '||'TRUE');
         ELSE
            fnd_file.put_line( 1, 'Call Status '||'FALSE');
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Call Status '||'FALSE');
         END IF;
      END IF;
      ROLLBACK_PROCESS(x_appraisal_id);
      RAISE LOAD_ERROR;
   END IF;

              ---------------------------------------------------------
              --        Find value for appraisal_id                  --
              ---------------------------------------------------------


   SELECT jl_co_fa_appraisals_s.nextval
     INTO x_appraisal_id
     FROM DUAL;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_file.put_line( 1, 'x_appraisal_id : '||to_char(x_appraisal_id));
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'x_appraisal_id : '||to_char(x_appraisal_id));
   END IF;

   INSERT INTO JL_CO_FA_APPRAISALS(
               APPRAISAL_ID,
               APPRAISAL_DATE,
               CURRENCY_CODE,
               FISCAL_YEAR,
               APPRAISER_NAME,
               APPRAISER_ADDRESS1,
               APPRAISER_ADDRESS2,
               APPRAISER_PHONE,
               APPRAISER_CITY,
               APPRAISAL_STATUS,
               CREATED_BY,
               CREATION_DATE,
               LAST_UPDATED_BY,
               LAST_UPDATE_DATE,
               LAST_UPDATE_LOGIN,
               REQUEST_ID,
               PROGRAM_APPLICATION_ID,
               PROGRAM_ID,
               PROGRAM_UPDATE_DATE)
   SELECT      x_appraisal_id,
               APPRAISAL_DATE,
               CURRENCY_CODE,
               FISCAL_YEAR,
               APPRAISER_NAME,
               APPRAISER_ADDRESS1,
               APPRAISER_ADDRESS2,
               APPRAISER_PHONE,
               APPRAISER_CITY,
               APPRAISAL_STATUS,
               fnd_global.user_id,
               sysdate,
               fnd_global.user_id,
               sysdate,
               fnd_global.login_id,
               fnd_global.conc_request_id,
               fnd_global.prog_appl_id,
               fnd_global.conc_program_id,
               PROGRAM_UPDATE_DATE
   FROM JL_CO_FA_APPRAISALS
   WHERE appraisal_id = -1;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_file.put_line( 1, 'Insert JL_CO_FA_APPRAISALS is complete.');
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Insert JL_CO_FA_APPRAISALS is complete.');
   END IF;

   INSERT INTO JL_CO_FA_ASSET_APPRS(
               APPRAISAL_ID,
               ASSET_NUMBER,
               APPRAISAL_VALUE,
               STATUS,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               CREATION_DATE,
               CREATED_BY,
               LAST_UPDATE_LOGIN,
               REQUEST_ID,
               PROGRAM_APPLICATION_ID,
               PROGRAM_ID,
               PROGRAM_UPDATE_DATE)
   SELECT      x_appraisal_id,
               ASSET_NUMBER,
               APPRAISAL_VALUE,
               STATUS,
               sysdate,
               fnd_global.user_id,
               sysdate,
               fnd_global.user_id,
               fnd_global.login_id,
               fnd_global.conc_request_id,
               fnd_global.prog_appl_id,
               fnd_global.conc_program_id,
               PROGRAM_UPDATE_DATE
   FROM JL_CO_FA_ASSET_APPRS
   WHERE appraisal_id = -1;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_file.put_line( 1, 'Insert JL_CO_FA_ASSET_APPRS is complete.');
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Insert JL_CO_FA_ASSET_APPRS is complete.');
   END IF;

   DELETE FROM JL_CO_FA_APPRAISALS
   WHERE appraisal_id = -1;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_file.put_line( 1, 'Delete JL_CO_FA_APPRAISALS is complete.');
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Delete JL_CO_FA_APPRAISALS is complete.');
   END IF;

   DELETE FROM JL_CO_FA_ASSET_APPRS
   WHERE appraisal_id = -1;

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      fnd_file.put_line( 1, 'Delete JL_CO_FA_ASSET_APPRS is complete.');
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Delete JL_CO_FA_ASSET_APPRS is complete.');
   END IF;

----------------------------------------------------------------------------
--   Submit validation request only when there is atleast one asset       --
--   loaded in the JL_CO_FA_ASSSET_APPRS table.                           --
----------------------------------------------------------------------------
   BEGIN
   x_count := 0;

   SELECT 1
     INTO x_count
     FROM DUAL
   WHERE EXISTS (SELECT * FROM JL_CO_FA_ASSET_APPRS
                  WHERE  appraisal_id = x_appraisal_id);

   EXCEPTION
     WHEN OTHERS THEN
     IF x_count = 0 THEN
        ROLLBACK_PROCESS(x_appraisal_id);
        ROLLBACK_PROCESS(-1);
        RAISE LOAD_ERROR;
     END IF;
   END;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       fnd_file.put_line( 1, 'x_count : '||to_char(x_count));
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'x_count : '||to_char(x_count));
    END IF;

    IF x_count <> 0 THEN

         x_request_id := fnd_request.submit_request('JL',
                                               'JLCOFAVP',
                                               '',
                                               '',
                                               FALSE,
                                               x_appraisal_id);

         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            fnd_file.put_line( 1, 'Request id for Validation pgm : '||to_char(x_request_id));
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Request id for Validation pgm : '||to_char(x_request_id));
         END IF;

              ---------------------------------------------------------
              -- Rollback everything and complte the process with    --
              -- if concurrent request completes with error.         --
              ---------------------------------------------------------

       IF x_request_id = 0 THEN
         ROLLBACK_PROCESS(x_appraisal_id);
         ROLLBACK_PROCESS(-1);
         RAISE LOAD_ERROR;
       END IF;

   COMMIT;

        call_status := fnd_concurrent.wait_for_request(x_request_id,
                                                  120,
                                                  0,
                                                  rphase,
                                                  rstatus,
                                                  dphase,
                                                  dstatus,
                                                  message);

        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           dbg_msg := fnd_message.get;
           fnd_file.put_line(1, 'dbg_msg : '||dbg_msg);
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'dbg_msg : '||dbg_msg);
        END IF;

        IF dphase = 'COMPLETE' THEN
           IF dstatus = 'NORMAL' THEN
              fnd_file.put_line( 1, 'Validation pgm completed successfully. '||dphase||'-'||dstatus);
              COMMIT;
           ELSE
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               fnd_file.put_line( 1, 'Validation pgm completed. ');
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Validation pgm completed. ');
               fnd_file.put_line( 1, 'Phase and Status '||dphase||'-'||dstatus);
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Phase and Status '||dphase||'-'||dstatus);
               IF (call_status) THEN
                  fnd_file.put_line( 1, 'Call Status '||'TRUE');
                  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Call Status '||'TRUE');
               ELSE
                  fnd_file.put_line( 1, 'Call Status '||'FALSE');
                  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Call Status '||'FALSE');
               END IF;
             END IF;
             ROLLBACK_PROCESS(x_appraisal_id);
             ROLLBACK_PROCESS(-1);
             RAISE LOAD_ERROR;
           END IF;
        ELSE
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              fnd_file.put_line( 1, 'Validation pgm is not completed. ');
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Validation pgm is not completed. ');
              fnd_file.put_line( 1, 'Phase and Status '||dphase||'-'||dstatus);
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Phase and Status '||dphase||'-'||dstatus);
              IF (call_status) THEN
                  fnd_file.put_line( 1, 'Call Status '||'TRUE');
                  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Call Status '||'TRUE');
              ELSE
                  fnd_file.put_line( 1, 'Call Status '||'FALSE');
                  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Call Status '||'FALSE');
              END IF;
           END IF;
           ROLLBACK_PROCESS(x_appraisal_id);
           ROLLBACK_PROCESS(-1);
           RAISE LOAD_ERROR;
        END IF;

        x_request_id := fnd_request.submit_request('JL',
                                               'JLCOFAAR',
                                               '',
                                               '',
                                               FALSE,
                                               x_appraisal_id,
                                               'Y');

        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           fnd_file.put_line( 1, 'Request id for Report pgm : '||to_char(x_request_id));
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Request id for Report pgm : '||to_char(x_request_id));
        END IF;

        IF x_request_id = 0 THEN
          RAISE REPORT_ERROR;
        END IF;

   COMMIT;

        call_status := fnd_concurrent.wait_for_request(x_request_id,
                                                  120,
                                                  0,
                                                  rphase,
                                                  rstatus,
                                                  dphase,
                                                  dstatus,
                                                  message);

        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           dbg_msg := fnd_message.get;
           fnd_file.put_line(1, 'dbg_msg : '||dbg_msg);
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'dbg_msg : '||dbg_msg);
        END IF;

        IF dphase = 'COMPLETE' THEN
           IF dstatus = 'NORMAL' THEN
              null;
           ELSE
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               fnd_file.put_line( 1, 'Addition report completed. ');
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Addition report completed. ');
               fnd_file.put_line( 1, 'Phase and Status '||dphase||'-'||dstatus);
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Phase and Status '||dphase||'-'||dstatus);
               IF (call_status) THEN
                  fnd_file.put_line( 1, 'Call Status '||'TRUE');
                   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Call Status '||'TRUE');
               ELSE
                  fnd_file.put_line( 1, 'Call Status '||'FALSE');
                   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Call Status '||'FALSE');
               END IF;
             END IF;
             RAISE REPORT_ERROR;
           END IF;
        ELSE
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              fnd_file.put_line( 1, 'addition report is not completed. ');
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'addition report is not completed. ');
              fnd_file.put_line( 1, 'Phase and Status '||dphase||'-'||dstatus);
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Phase and Status '||dphase||'-'||dstatus);
              IF (call_status) THEN
                  fnd_file.put_line( 1, 'Call Status '||'TRUE');
                  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Call Status '||'TRUE');
              ELSE
                  fnd_file.put_line( 1, 'Call Status '||'FALSE');
                  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_api_name, 'Call Status '||'FALSE');
              END IF;
           END IF;
           RAISE REPORT_ERROR;
        END IF;

   END IF;

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'(-)');
   END IF;

EXCEPTION

      WHEN LOAD_ERROR THEN

        fnd_message.set_name('JL', 'JL_CO_FA_LOAD_ERROR');
        err_msg := fnd_message.get;
        fnd_file.put_line(fnd_file.log, err_msg);
        call_status := fnd_concurrent.set_completion_status('ERROR','');
/*        fnd_message.raise_error;
*/

      WHEN REPORT_ERROR THEN

        fnd_message.set_name('JL', 'JL_CO_FA_TA_ADD_REPORT_ERROR');
        err_msg := fnd_message.get;
        fnd_file.put_line(fnd_file.log, err_msg);
        call_status := fnd_concurrent.set_completion_status('ERROR','');
/*        fnd_message.raise_error;
*/

      WHEN OTHERS THEN
        ROLLBACK;
        ROLLBACK_PROCESS(-1);
        fnd_message.set_name('JL', 'JL_CO_FA_GENERAL_ERROR');
        fnd_file.put_line( 1, fnd_message.get);
        err_num := SQLCODE;
        err_msg := substr(SQLERRM, 1, 200);
        RAISE_APPLICATION_ERROR( err_num, err_msg);
END;

----------------------------------------------------------------------------
-- FUNCTION                                                               --
--   rollback_process                                                     --
--                                                                        --
-- DESCRIPTION                                                            --
--   Use this procedure to rollback all loaded information.               --
--                                                                        --
--                                                                        --
-- PURPOSE:                                                               --
--   Oracle Applications Rel 11.5                                         --
--                                                                        --
-- PARAMETERS:                                                            --
--                                                                        --
--                                                                        --
-- HISTORY:                                                               --
--    05-19-99     Sujit Dalai    Created                                 --
----------------------------------------------------------------------------
PROCEDURE rollback_process(p_appraisal_id  NUMBER) IS
BEGIN

   DELETE FROM JL_CO_FA_ASSET_APPRS
   WHERE appraisal_id = p_appraisal_id;

   DELETE FROM JL_CO_FA_APPRAISALS
   WHERE appraisal_id = p_appraisal_id;

   COMMIT;
END;

END jl_co_fa_ta_load_pkg;

/
