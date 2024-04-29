--------------------------------------------------------
--  DDL for Package Body FND_OAM_DSCRAM_RUNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_OAM_DSCRAM_RUNS_PKG" as
/* $Header: AFOAMDSRUNB.pls 120.6 2005/12/19 10:07 ilawler noship $ */

   ----------------------------------------
   -- Private Body Constants
   ----------------------------------------
   PKG_NAME                     CONSTANT VARCHAR2(20) := 'DSCRAM_RUNS_PKG.';

   -- Profile option names controlling whether the product is enabled and whether the instance is in a state where
   -- scrambling operations are allowed.
   B_DSCRAM_ENABLED_PROFILE_NAME        CONSTANT VARCHAR2(30) := 'OAM_DSCRAM_ENABLED';
   B_DSCRAM_ALLOWED_PROFILE_NAME        CONSTANT VARCHAR2(30) := 'OAM_DSCRAM_ALLOWED';

   B_PROFILE_ENABLED_VALUE              CONSTANT VARCHAR2(30) := 'YES';

   ----------------------------------------
   -- Private Body Variables
   ----------------------------------------
   TYPE b_run_cache_type IS RECORD
      (
       initialized              BOOLEAN         := FALSE,
       run_id                   NUMBER          := NULL,
       run_stat_id              NUMBER          := NULL,
       valid_check_interval     NUMBER          := NULL,
       run_mode                 VARCHAR2(30)    := NULL,
       arg_context              FND_OAM_DSCRAM_ARGS_PKG.arg_context,
       last_validated           DATE            := NULL,
       last_validation_ret_sts  VARCHAR2(6)     := NULL
       );
   b_run_info   b_run_cache_type;

   ----------------------------------------
   -- Public/Private Procedures/Functions
   ----------------------------------------

   -- Public
   FUNCTION GET_RUN_ID
      RETURN NUMBER
   IS
   BEGIN
      IF NOT b_run_info.initialized THEN
         RAISE NO_DATA_FOUND;
      END IF;

      RETURN b_run_info.run_id;
   END;

   -- Public
   FUNCTION GET_RUN_STAT_ID
      RETURN NUMBER
   IS
   BEGIN
      IF NOT b_run_info.initialized THEN
         RAISE NO_DATA_FOUND;
      END IF;

      RETURN b_run_info.run_stat_id;
   END;

   -- Public
   FUNCTION GET_VALID_CHECK_INTERVAL
      RETURN NUMBER
   IS
   BEGIN
      IF NOT b_run_info.initialized THEN
         RAISE NO_DATA_FOUND;
      END IF;

      RETURN b_run_info.valid_check_interval;
   END;

   -- Public
   FUNCTION GET_RUN_MODE
      RETURN VARCHAR2
   IS
   BEGIN
      IF NOT b_run_info.initialized THEN
         RAISE NO_DATA_FOUND;
      END IF;

      RETURN b_run_info.run_mode;
   END;

   -- Public
   PROCEDURE GET_RUN_ARG_CONTEXT(px_arg_context IN OUT NOCOPY FND_OAM_DSCRAM_ARGS_PKG.arg_context)
   IS
   BEGIN
      IF NOT b_run_info.initialized THEN
         RAISE NO_DATA_FOUND;
      END IF;

      --return a direct reference
      px_arg_context := b_run_info.arg_context;
   END;

   -- Public
   PROCEDURE SET_RUN_ARG_CONTEXT(p_arg_context IN FND_OAM_DSCRAM_ARGS_PKG.arg_context)
   IS
   BEGIN
      IF NOT b_run_info.initialized THEN
         RAISE NO_DATA_FOUND;
      END IF;

      --return a direct reference
      b_run_info.arg_context := p_arg_context;
   END;

   -- Public
   PROCEDURE INITIALIZE_RUN_ARG_CONTEXT(x_return_status         OUT NOCOPY VARCHAR2,
                                        x_return_msg            OUT NOCOPY VARCHAR2)
   IS
   BEGIN
      FND_OAM_DSCRAM_ARGS_PKG.FETCH_RUN_ARG_CONTEXT(b_run_info.run_id,
                                                    b_run_info.arg_context,
                                                    x_return_status,
                                                    x_return_msg);
   END;

   -- Public API
   FUNCTION VALIDATE_START_EXECUTION(p_run_id           IN NUMBER,
                                     x_return_status    OUT NOCOPY VARCHAR2,
                                     x_return_msg       OUT NOCOPY VARCHAR2)
      RETURN BOOLEAN
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'VALIDATE_START_EXECUTION';

      l_prof_value      VARCHAR2(20);
      l_run_dbname      VARCHAR2(30);
      l_status          VARCHAR2(30);
      l_current_dbname  VARCHAR2(30);
      l_run_stat_id     NUMBER;

      CURSOR C1
      IS
         SELECT run_status, target_dbname
         FROM fnd_oam_dscram_runs_b
         WHERE run_id = p_run_id;
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      -- check that data scrambling is enabled first
      FND_PROFILE.GET(B_DSCRAM_ENABLED_PROFILE_NAME,
                      l_prof_value);
      IF l_prof_value IS NULL OR UPPER(l_prof_value) <> B_PROFILE_ENABLED_VALUE THEN
         x_return_msg := 'The Data Scrambling feature is not Enabled.';
         RAISE PROGRAM_ERROR;
      END IF;

      -- now check that data scrambling operations are allowed
      l_prof_value := NULL;
      FND_PROFILE.GET(B_DSCRAM_ALLOWED_PROFILE_NAME,
                      l_prof_value);
      IF l_prof_value IS NULL OR UPPER(l_prof_value) <> B_PROFILE_ENABLED_VALUE THEN
         x_return_msg := 'Data Scrambling operations are not currently allowed.';
         RAISE PROGRAM_ERROR;
      END IF;

      --fetch necessary run attributes
      OPEN C1;
      FETCH C1 INTO l_status, l_run_dbname;
      IF C1%NOTFOUND THEN
         x_return_msg := 'Invalid run_id: ('||p_run_id||')';
         RAISE PROGRAM_ERROR;
      END IF;
      CLOSE C1;

      --make sure the run has been marked as processing by the master controller
      IF NOT FND_OAM_DSCRAM_UTILS_PKG.STATUS_IS_PROCESSING(l_status) THEN
         x_return_status := FND_OAM_DSCRAM_UTILS_PKG.CONV_VALIDATE_START_STS_TO_RET(l_status);
         IF FND_OAM_DSCRAM_UTILS_PKG.RET_STS_IS_ERROR(x_return_status) THEN
            x_return_msg := 'Invalid run status('||l_status||')';
            fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         END IF;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
      END IF;

      --validate that the run's dbname matches this DB
      SELECT UPPER(name)
         INTO l_current_dbname
         FROM V$DATABASE;

      IF l_current_dbname IS NULL OR l_current_dbname <> l_run_dbname THEN
         x_return_msg := 'Invalid target dbname, current('||l_current_dbname||'), target('||l_run_dbname||')';
         RAISE PROGRAM_ERROR;
      END IF;

      --success
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      RETURN TRUE;
   EXCEPTION
      WHEN PROGRAM_ERROR THEN
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
      WHEN OTHERS THEN
         x_return_msg := 'Unhandled Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN FALSE;
   END;

   -- Public
   -- Return Statuses:
   --  SUCCESS, ERROR, ERROR_UNEXP,
   --  Converted: PROCESSED, STOPPED, ERROR_FATAL, STOP
   FUNCTION VALIDATE_CONTINUED_EXECUTION(p_force_query          IN BOOLEAN,
                                         p_recurse              IN BOOLEAN,
                                         x_return_status        OUT NOCOPY VARCHAR2,
                                         x_return_msg           OUT NOCOPY VARCHAR2)
      RETURN BOOLEAN
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'VALIDATE_CONTINUED_EXECUTION';

      l_status          VARCHAR2(30) := NULL;

      CURSOR C1
      IS
         SELECT run_status
         FROM fnd_oam_dscram_runs_b
         WHERE run_id = b_run_info.run_id;
   BEGIN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      -- make sure the state's initialized
      IF NOT b_run_info.initialized THEN
         RAISE NO_DATA_FOUND;
      END IF;

      -- check if we should do work or if we can return the cached status
      IF NOT (p_force_query OR
              FND_OAM_DSCRAM_UTILS_PKG.VALIDATION_DUE(b_run_info.last_validated)) THEN
         x_return_status := b_run_info.last_validation_ret_sts;
         RETURN (x_return_status = FND_API.G_RET_STS_SUCCESS);
      END IF;

      fnd_oam_debug.log(1, l_ctxt, '>RE-QUERYING<');

      -- re-init the cached fields to allow easy exit
      b_run_info.last_validation_ret_sts := x_return_status;
      b_run_info.last_validated := SYSDATE;

      --otherwise, fetch necessary run attributes and evaluate
      OPEN C1;
      FETCH C1 INTO l_status;
      IF C1%NOTFOUND THEN
         --shouldn't happen since we're using the cached run_id
         x_return_msg := 'Invalid cached run_id: '||b_run_info.run_id;
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         RETURN FALSE;
      END IF;
      CLOSE C1;

      --make sure the run has been marked as processing by the master controller
      IF l_status <> FND_OAM_DSCRAM_UTILS_PKG.G_STATUS_PROCESSING THEN
         x_return_status := FND_OAM_DSCRAM_UTILS_PKG.CONV_VALIDATE_CONT_STS_TO_RET(l_status);
         b_run_info.last_validation_ret_sts := x_return_status;
         IF x_return_status <> FND_OAM_DSCRAM_UTILS_PKG.G_RET_STS_PROCESSED THEN
            x_return_msg := 'Invalid run status('||l_status||')';
            fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         END IF;
         RETURN FALSE;
      END IF;

      --ignore p_recurse because we're the topmost entity

      --success
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      b_run_info.last_validation_ret_sts := x_return_status;
      b_run_info.last_validated := SYSDATE;
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS THEN
         x_return_msg := 'Unhandled Exception: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         b_run_info.last_validation_ret_sts := x_return_status;
         b_run_info.last_validated := SYSDATE;
         RETURN FALSE;
   END;

   -- Public
   -- Return Statuses:
   --  SUCCESS, ERROR, ERROR_UNEXP
   PROCEDURE ASSIGN_WORKER_TO_RUN(p_run_id              IN NUMBER,
                                  x_return_status       OUT NOCOPY VARCHAR2,
                                  x_return_msg          OUT NOCOPY VARCHAR2)
   IS
      l_ctxt            VARCHAR2(60) := PKG_NAME||'ASSIGN_WORKER_TO_RUN';

      l_run_stat_id             NUMBER;
      l_valid_check_interval    NUMBER;
      l_run_mode                VARCHAR2(30);
      l_null                    NUMBER;
      l_return_status           VARCHAR2(6);
      l_return_msg              VARCHAR2(2048);

      CURSOR C1
      IS
         SELECT last_run_stat_id, valid_check_interval, run_mode
         FROM fnd_oam_dscram_runs_b
         WHERE run_id = p_run_id;
      CURSOR C2(c_stat_id       NUMBER)
      IS
         SELECT 1
         FROM sys.dual
         WHERE EXISTS (SELECT 1
                       FROM fnd_oam_dscram_stats
                       WHERE stat_id = c_stat_id);
   BEGIN
      fnd_oam_debug.log(2, l_ctxt, 'ENTER');
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_return_msg := '';

      --fetch necessary run attributes
      OPEN C1;
      FETCH C1 INTO l_run_stat_id, l_valid_check_interval, l_run_mode;
      IF C1%NOTFOUND THEN
         x_return_msg := 'Invalid run_id: ('||p_run_id||')';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN;
      END IF;
      CLOSE C1;

      --make sure it's a valid stat id
      OPEN C2(l_run_stat_id);
      FETCH C2 into l_null;
      IF C2%NOTFOUND THEN
         x_return_msg := 'Invalid run_stat_id: ('||l_run_stat_id||')';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
         RETURN;
      END IF;
      CLOSE C2;

      fnd_oam_debug.log(1, l_ctxt, 'Run Stat ID: '||l_run_stat_id);

      b_run_info.run_id := p_run_id;
      b_run_info.run_stat_id := l_run_stat_id;
      IF l_valid_check_interval IS NULL OR l_valid_check_interval < 0 THEN
         l_valid_check_interval := 0;
         fnd_oam_debug.log(1, l_ctxt, 'Entity Validation Polling DISABLED');
      ELSE
         fnd_oam_debug.log(1, l_ctxt, 'Entity Validation Polling Interval: '||l_valid_check_interval||' seconds');
      END IF;
      b_run_info.valid_check_interval := l_valid_check_interval;
      b_run_info.run_mode := l_run_mode;
      b_run_info.last_validated := NULL;
      b_run_info.initialized := TRUE;

      x_return_status := FND_API.G_RET_STS_SUCCESS;
      fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   EXCEPTION
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_return_msg := 'Unhandled Error: (Code('||SQLCODE||'), Message("'||SQLERRM||'"))';
         fnd_oam_debug.log(6, l_ctxt, x_return_msg);
         fnd_oam_debug.log(2, l_ctxt, 'EXIT');
   END;

   -- Public
   -- Copied from FND_OAM_DS_PSETS_PKG, seems to mimic standard syntax of calls
   -- made from FND_TOP/sql/FNDNLINS.sql.
   PROCEDURE ADD_LANGUAGE
   IS
   BEGIN

      delete from FND_OAM_DSCRAM_RUNS_TL T
         where not exists
            (select NULL
             from FND_OAM_DSCRAM_RUNS_B B
             where B.RUN_ID = T.RUN_ID
             );

  update FND_OAM_DSCRAM_RUNS_TL T set (
      DISPLAY_NAME,
      DESCRIPTION
    ) = (select
      B.DISPLAY_NAME,
      B.DESCRIPTION
    from FND_OAM_DSCRAM_RUNS_TL B
    where B.RUN_ID = T.RUN_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.RUN_ID,
      T.LANGUAGE
  ) in (select
      SUBT.RUN_ID,
      SUBT.LANGUAGE
    from FND_OAM_DSCRAM_RUNS_TL SUBB, FND_OAM_DSCRAM_RUNS_TL SUBT
    where SUBB.RUN_ID = SUBT.RUN_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DISPLAY_NAME <> SUBT.DISPLAY_NAME
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into FND_OAM_DSCRAM_RUNS_TL (
    RUN_ID,
    DISPLAY_NAME,
    DESCRIPTION,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select /*+ ORDERED */
    B.RUN_ID,
    B.DISPLAY_NAME,
    B.DESCRIPTION,
    B.CREATED_BY,
    B.CREATION_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from FND_OAM_DSCRAM_RUNS_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from FND_OAM_DSCRAM_RUNS_TL T
    where T.RUN_ID = B.RUN_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

   END ADD_LANGUAGE;

END FND_OAM_DSCRAM_RUNS_PKG;

/
