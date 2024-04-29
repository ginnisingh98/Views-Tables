--------------------------------------------------------
--  DDL for Package Body FEM_PL_INCR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_PL_INCR_PKG" AS
/* $Header: fem_pl_incr.plb 120.1 2006/02/27 17:35:33 gcheng noship $ */

-- Private package variables
   G_RUNNING          CONSTANT VARCHAR2(10) := 'RUNNING';
   G_SNAPSHOT         CONSTANT VARCHAR2(1) := 'S';
   G_REPLACEMENT      CONSTANT VARCHAR2(1) := 'R';
   G_ERROR_REPROCESS  CONSTANT VARCHAR2(1) := 'E';

/**************************************************************************
-- Private Procedure Declarations
**************************************************************************/

   PROCEDURE XGL_Obj_Exec_Lock_Exists
                (p_calling_context         IN  VARCHAR2 DEFAULT 'ENGINE',
                 p_object_id               IN  NUMBER,
                 p_obj_def_id              IN  NUMBER,
                 p_cal_period_id           IN  NUMBER,
                 p_ledger_id               IN  NUMBER,
                 p_dataset_code            IN  NUMBER,
                 x_obj_exec_lock_exists    OUT NOCOPY VARCHAR2,
                 x_exec_state              OUT NOCOPY VARCHAR2,
                 x_prev_request_id         OUT NOCOPY NUMBER,
                 x_num_msg                 OUT NOCOPY NUMBER);

   PROCEDURE XGL_Exec_Mode_Lock_Exists
                (p_cal_period_id           IN  NUMBER,
                 p_ledger_id               IN  NUMBER,
                 p_dataset_code            IN  NUMBER,
                 p_object_id               IN  NUMBER,
                 p_exec_mode               IN  VARCHAR2,
                 x_exec_mode_lock_exists   OUT NOCOPY VARCHAR2,
                 x_num_msg                 OUT NOCOPY NUMBER);

   PROCEDURE Fact_Obj_Exec_Lock_Exists
                (p_calling_context         IN  VARCHAR2 DEFAULT 'ENGINE',
                 p_object_id               IN  NUMBER,
                 p_obj_def_id              IN  NUMBER,
                 p_cal_period_id           IN  NUMBER,
                 p_ledger_id               IN  NUMBER,
                 p_dataset_code            IN  NUMBER,
                 p_source_system_code      IN  NUMBER,
                 p_table_name              IN  VARCHAR2,
                 x_obj_exec_lock_exists    OUT NOCOPY VARCHAR2,
                 x_exec_state              OUT NOCOPY VARCHAR2,
                 x_prev_request_id         OUT NOCOPY NUMBER,
                 x_num_msg                 OUT NOCOPY NUMBER);

   PROCEDURE Fact_Exec_Mode_Lock_Exists
                (p_cal_period_id           IN  NUMBER,
                 p_ledger_id               IN  NUMBER,
                 p_dataset_code            IN  NUMBER,
                 p_source_system_code      IN  NUMBER,
                 p_table_name              IN  VARCHAR2,
                 p_object_id               IN  NUMBER,
                 p_exec_mode               IN  VARCHAR2,
                 x_exec_mode_lock_exists   OUT NOCOPY VARCHAR2,
                 x_num_msg                 OUT NOCOPY NUMBER);


   PROCEDURE Snapshot_Period_Lock_Exists
                (p_cal_period_id           IN  NUMBER,
                 p_ledger_id               IN  NUMBER,
                 p_dataset_code            IN  NUMBER,
                 x_ss_per_lock_exists      OUT NOCOPY VARCHAR2,
                 x_num_msg                 OUT NOCOPY NUMBER);


/**************************************************************************
-- Public Procedures
**************************************************************************/

-- =======================================================================
   PROCEDURE Exec_Lock_Exists
                (p_calling_context         IN  VARCHAR2 DEFAULT 'ENGINE',
                 p_object_id               IN  NUMBER,
                 p_obj_def_id              IN  NUMBER,
                 p_cal_period_id           IN  NUMBER,
                 p_ledger_id               IN  NUMBER,
                 p_dataset_code            IN  NUMBER,
                 p_source_system_code      IN  VARCHAR2 DEFAULT NULL,
                 p_table_name              IN  VARCHAR2 DEFAULT NULL,
                 p_exec_mode               IN  VARCHAR2,
                 x_exec_lock_exists        OUT NOCOPY VARCHAR2,
                 x_exec_state              OUT NOCOPY VARCHAR2,
                 x_prev_request_id         OUT NOCOPY NUMBER,
                 x_num_msg                 OUT NOCOPY NUMBER) IS
-- =========================================================================
-- Purpose
--    High-level process lock API procedure specific to GL integration and
--    other engines that support incremental loads.  Calls other API
--    procedures to perform process validations to ensure that there are
--    no process execution locks or process overlaps and to validate the
--    Execution Mode parameter.
-- History
--    12-22-03  G Hall     Created
--    03-10-04  G Hall     Added x_prev_request_id parameter
--    11-22-04  G Hall     Bug# 3922507
--                         Removed call to Snapshot_Period_Lock_Exists;
--                         this check isn't needed for XGL since roll up
--                         and roll forward will not be implemented.
-- Arguments
--    p_calling_context    'ENGINE' (default) or 'UI'.
--    p_object_id          The Object ID that identifies the rule being
--                         executed.
--    p_obj_def_id         The Object Definition ID that identifies the
--                         rule version being executed.
--    p_cal_period_id      The Cal Period ID value passed to the engine.
--    p_ledger_id          The Ledger ID value passed to the engine.
--    p_dataset_code       The Dataset Code value passed to the engine.
--    p_exec_mode          The Execution Mode value passed to the engine.
--                         S (Snapshot), I (Incremental),
--                         E (Error Reprocessing).
--    x_exec_lock_exists   'T' or 'F'
--    x_exec_state         'NORMAL', 'RERUN', 'RESTART'
--    x_prev_request_id    Passes back the Request ID of the previous
--                         execution for the given ledger, dataset, period,
--                         and object when x_exec_state = 'RERUN'.
--    x_num_msg            The number of end-user messages put onto the
--                         FND message stack by this procedure and any of
--                         its subordinate procedures.
-- Notes
--    Called by FEM_PL_PKG.Obj_Execution_Lock_Exists
-- =========================================================================

      v_num_msg                     NUMBER(2) := 0;
      v_object_type                 FEM_OBJECT_TYPES.object_type_code%TYPE;

   BEGIN

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => fnd_log.level_procedure,
         p_module   => 'fem.plsql.fem_pl_incr_pkg.' ||
                       'exec_lock_exists.begin',
         p_msg_text => 'BEGIN');

   -- ----------------------------------------------------------------------
   -- Call the Obj_Exec_Lock_Exists API procedure to make sure that no
   -- other integration rule, and no other version of the current
   -- integration rule, has been run, or is running for the given ledger,
   -- dataset, and period, and that no other instance of the current rule
   -- version is currently running for the given ledger, dataset, and
   -- period, and to retrieve the execution state (NORMAL, RERUN, RESTART).
   -- ----------------------------------------------------------------------

      SELECT object_type_code
      INTO v_object_type
      FROM fem_object_catalog_b
      WHERE object_id = p_object_id;

      IF v_object_type = 'XGL_INTEGRATION' THEN
        XGL_Obj_Exec_Lock_Exists
          (p_calling_context      => p_calling_context,
           p_object_id            => p_object_id,
           p_obj_def_id           => p_obj_def_id,
           p_cal_period_id        => p_cal_period_id,
           p_ledger_id            => p_ledger_id,
           p_dataset_code         => p_dataset_code,
           x_obj_exec_lock_exists => x_exec_lock_exists,
           x_exec_state           => x_exec_state,
           x_prev_request_id      => x_prev_request_id,
           x_num_msg              => v_num_msg);
      ELSIF v_object_type = 'SOURCE_DATA_LOADER' THEN
        Fact_Obj_Exec_Lock_Exists
          (p_calling_context      => p_calling_context,
           p_object_id            => p_object_id,
           p_obj_def_id           => p_obj_def_id,
           p_cal_period_id        => p_cal_period_id,
           p_ledger_id            => p_ledger_id,
           p_dataset_code         => p_dataset_code,
           p_source_system_code   => p_source_system_code,
           p_table_name           => p_table_name,
           x_obj_exec_lock_exists => x_exec_lock_exists,
           x_exec_state           => x_exec_state,
           x_prev_request_id      => x_prev_request_id,
           x_num_msg              => v_num_msg);
      END IF;


      x_num_msg := NVL(v_num_msg, 0);

      IF x_exec_lock_exists = 'T' THEN

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => fnd_log.level_procedure,
            p_module   => 'fem.plsql.fem_pl_incr_pkg.' ||
                          'exec_lock_exists.oele',
            p_msg_text => 'RETURNING: Object Execution Lock Exists');

         RETURN;

      END IF;

   -- ----------------------------------------------------------------------
   -- Call the Exec_Mode_Lock_Exists API procedure to verify that for
   -- Execution Mode = 'S', there are no previous successful executions for
   -- the given ledger, dataset, and period, and for Execution Mode = 'I'
   -- or 'E', a successful snapshot run has been executed.
   -- ----------------------------------------------------------------------

      IF v_object_type = 'XGL_INTEGRATION' THEN
        XGL_Exec_Mode_Lock_Exists
          (p_cal_period_id         => p_cal_period_id,
           p_ledger_id             => p_ledger_id,
           p_dataset_code          => p_dataset_code,
           p_object_id             => p_object_id,
           p_exec_mode             => p_exec_mode,
           x_exec_mode_lock_exists => x_exec_lock_exists,
           x_num_msg               => v_num_msg);
      ELSIF v_object_type = 'SOURCE_DATA_LOADER' THEN
        Fact_Exec_Mode_Lock_Exists
          (p_cal_period_id         => p_cal_period_id,
           p_ledger_id             => p_ledger_id,
           p_dataset_code          => p_dataset_code,
           p_source_system_code    => p_source_system_code,
           p_table_name            => p_table_name,
           p_object_id             => p_object_id,
           p_exec_mode             => p_exec_mode,
           x_exec_mode_lock_exists => x_exec_lock_exists,
           x_num_msg               => v_num_msg);
      END IF;
      x_num_msg := x_num_msg + NVL(v_num_msg, 0);

      IF x_exec_lock_exists = 'T' THEN

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => fnd_log.level_procedure,
            p_module   => 'fem.plsql.fem_pl_incr_pkg.' ||
                          'exec_lock_exists.emle',
            p_msg_text => 'RETURNING: Execution Mode Lock Exists; ' ||
                          'x_exec_state = NULL');

         x_exec_state := NULL;
         RETURN;

      END IF;

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => fnd_log.level_procedure,
         p_module   => 'fem.plsql.fem_pl_incr_pkg.' ||
                       'exec_lock_exists.end',
         p_msg_text => 'END');

   END Exec_Lock_Exists;
-- =======================================================================


/**************************************************************************
-- Private Procedures
**************************************************************************/

-- =========================================================================
   PROCEDURE XGL_Obj_Exec_Lock_Exists
                (p_calling_context         IN  VARCHAR2 DEFAULT 'ENGINE',
                 p_object_id               IN  NUMBER,
                 p_obj_def_id              IN  NUMBER,
                 p_cal_period_id           IN  NUMBER,
                 p_ledger_id               IN  NUMBER,
                 p_dataset_code            IN  NUMBER,
                 x_obj_exec_lock_exists    OUT NOCOPY VARCHAR2,
                 x_exec_state              OUT NOCOPY VARCHAR2,
                 x_prev_request_id         OUT NOCOPY NUMBER,
                 x_num_msg                 OUT NOCOPY NUMBER) IS
-- =========================================================================
-- Purpose
--    Performs process validations specific to GL integration and other
--    engines that support incremental loads, to ensure that there are no
--    process execution locks or process overlaps.
-- History
--    01-12-04  G Hall     Created
--    03-10-04  G Hall     Added x_prev_request_id parameter
--    05-21-04  G Hall     Bug# 3643866: Fixed first query
--                         (SELECT DISTINCT e.object_id...) to only look up
--                          objects with the object type of the current object.
--    05-25-04  G Hall     Added call to FEM_PL_PKG.Set_Exec_State.
-- Arguments
--    p_calling_context    'ENGINE' (default) or 'UI'.
--    p_object_id          The Object ID identifying the rule being
--                         executed.
--    p_obj_def_id         The Object_Definition_ID identifying the version
--                         of the rule being executed.
--    p_cal_period_id      The Cal Period ID value passed to the engine.
--    p_ledger_id          The Ledger ID value passed to the engine.
--    p_dataset_code       The Dataset Code value passed to the engine.
--    x_obj_lock_exists    Returns 'T' or 'F'.
--    x_exec_state         Returns '
--    x_prev_request_id    Passes back the Request ID of the previous
--                         execution for the given ledger, dataset, period,
--                         and object when x_exec_state = 'RERUN'.
--    x_num_msg            Returns the number of end-user messages put onto
--                         the FND message stack by this procedure.
-- Notes
--    Called by FEM_PL_INCR.Exec_Lock_Exists.
-- =========================================================================

      v_precedent_obj_id       fem_pl_object_executions.object_id%TYPE;
      v_precedent_obj_def_id   fem_pl_object_executions.exec_object_definition_id%TYPE;

      v_prev_event_order       fem_pl_object_executions.event_order%TYPE;
      v_prev_exec_status_cd    fem_pl_object_executions.exec_status_code%TYPE;
      v_prev_request_id        fem_pl_object_executions.request_id%TYPE;

      v_current_request_id     NUMBER;

      v_msg_count              NUMBER;
      v_msg_data               VARCHAR2(512);
      v_return_status          VARCHAR2(1);

      CURSOR c1 IS
         SELECT r.request_id
         FROM fem_pl_requests r,
              fem_pl_object_executions o
         WHERE r.cal_period_id       = p_cal_period_id
           AND r.ledger_id           = p_ledger_id
           AND r.output_dataset_code = p_dataset_code
           AND o.request_id          = r.request_id
           AND o.object_id           = p_object_id
           AND o.exec_status_code    = 'RUNNING';

   BEGIN

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => fnd_log.level_procedure,
         p_module   => 'fem.plsql.fem_pl_incr_pkg.' ||
                       'xgl_obj_exec_lock_exists.begin',
         p_msg_text => 'BEGIN');

   -- ----------------------------------------------------------------------
   -- Reset failed executions that are left in 'RUNNING' status to their
   -- correct error status.
   -- ----------------------------------------------------------------------

      FOR reset IN c1 LOOP

         FEM_ENGINES_PKG.Tech_Message
            (p_severity => fnd_log.level_statement,
             p_module   => 'fem.plsql.fem_pl_incr_pkg.' ||
                           'xgl_obj_exec_lock_exists.reset_request_id.',
             p_app_name => 'FEM',
             p_msg_name => 'FEM_GL_POST_204',
             p_token1   => 'VAR_NAME',
             p_value1   => 'reset.request_id',
             p_token2   => 'VAR_VAL',
             p_value2   => reset.request_id);

         FEM_PL_PKG.set_exec_state
           (p_api_version   => 1.0,
            p_commit        => fnd_api.g_false,
            p_request_id    => reset.request_id,
            p_object_id     => p_object_id,
            x_msg_count     => v_msg_count,
            x_msg_data      => v_msg_data,
            x_return_status => v_return_status);

      END LOOP;

   -- ----------------------------------------------------------------------
   -- Only one object and object version is allowed to run for any ledger,
   -- dataset, period combination.  Get the object and version that have
   -- been run for the current ledger, dataset, and period, if any.  Only
   -- currently running or successfully completed executions count for
   -- establishing the object and object version precedent for the current
   -- ledger, period, and dataset.
   -- ----------------------------------------------------------------------

      BEGIN

         SELECT DISTINCT e.object_id, e.exec_object_definition_id
         INTO v_precedent_obj_id, v_precedent_obj_def_id
         FROM fem_pl_requests r,
              fem_pl_object_executions e,
              fem_object_catalog_b c1
         WHERE r.ledger_id           = p_ledger_id
           AND r.cal_period_id       = p_cal_period_id
           AND r.output_dataset_code = p_dataset_code
           AND e.request_id          = r.request_id
           AND c1.object_id          = e.object_id
           AND c1.object_type_code   =
              (SELECT object_type_code
               FROM fem_object_catalog_b c2
               WHERE c2.object_id = p_object_id);

      EXCEPTION
         WHEN NO_DATA_FOUND THEN

      -- ----------------------------------------------------------------
      -- There is no lock, and execution state is NORMAL.  This will be
      -- the case for the first run of each period for the given ledger
      -- and dataset, i.e. the snapshot load.
      -- ----------------------------------------------------------------

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => fnd_log.level_procedure,
            p_module   => 'fem.plsql.fem_pl_incr_pkg.' ||
                          'xgl_obj_exec_lock_exists.end.normal1.',
            p_msg_text => 'END: x_exec_state = NORMAL');

         x_obj_exec_lock_exists := 'F';
         x_exec_state := 'NORMAL';
         x_num_msg := 0;

         RETURN;

      END;

   -- ----------------------------------------------------------------------
   -- Make sure that the current integration rule matches the rule precedent
   -- set by previous executions for the given ledger, dataset, and period.
   -- ----------------------------------------------------------------------

      IF p_object_id <> v_precedent_obj_id THEN

      -- -------------------------------------------------------------------
      -- Wrong Rule:
      -- The current rule does not match the rule precedent set for the
      -- given ledger, dataset, and period.
      -- -------------------------------------------------------------------

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => fnd_log.level_exception,
            p_module   => 'fem.plsql.fem_pl_incr_pkg.' ||
                          'xgl_obj_exec_lock_exists.end.wr',
            p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_016');

         FEM_ENGINES_PKG.Put_Message
           (p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_016');

         x_obj_exec_lock_exists := 'T';
         x_exec_state := NULL;
         x_num_msg := 1;

         RETURN;

      END IF;

   -- ----------------------------------------------------------------------
   -- Make sure that the current integration rule version matches the
   -- rule version precedent set by previous executions for the given
   -- ledger, dataset, and period.
   -- ----------------------------------------------------------------------

      IF p_obj_def_id <> v_precedent_obj_def_id THEN

      -- -------------------------------------------------------------------
      -- Wrong Rule Version:
      -- The current rule version does not match the rule version precedent
      -- set for the given ledger, dataset, and period.
      -- -------------------------------------------------------------------

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => fnd_log.level_exception,
            p_module   => 'fem.plsql.fem_pl_incr_pkg.' ||
                          'xgl_obj_exec_lock_exists.end.wrv',
            p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_017');

         FEM_ENGINES_PKG.Put_Message
           (p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_017');

         x_obj_exec_lock_exists := 'T';
         x_exec_state := NULL;
         x_num_msg := 1;

         RETURN;

      END IF;

   -- ----------------------------------------------------------------------
   -- Check for execution locks and determine execution state based on the
   -- EXEC_STATUS_CODE of the most recent execution for the given ledger,
   -- dataset, period, and object/object version.
   -- ----------------------------------------------------------------------

      SELECT MAX(e.event_order)
      INTO v_prev_event_order
      FROM fem_pl_requests r,
           fem_pl_object_executions e
      WHERE r.ledger_id           = p_ledger_id
        AND r.cal_period_id       = p_cal_period_id
        AND r.output_dataset_code = p_dataset_code
        AND e.request_id          = r.request_id
        AND e.object_id           = p_object_id
        AND e.exec_object_definition_id = p_obj_def_id;

      SELECT exec_status_code, request_id
      INTO v_prev_exec_status_cd, v_prev_request_id
      FROM fem_pl_object_executions
      WHERE event_order = v_prev_event_order;

      IF v_prev_exec_status_cd = 'SUCCESS' THEN

      -- -------------------------------------------------------------------
      -- No lock exists and execution state is NORMAL
      -- -------------------------------------------------------------------

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => fnd_log.level_procedure,
            p_module   => 'fem.plsql.fem_pl_incr_pkg.' ||
                          'xgl_obj_exec_lock_exists.end.normal2.',
            p_msg_text => 'END: x_exec_state = NORMAL');

         x_obj_exec_lock_exists := 'F';
         x_exec_state := 'NORMAL';
         x_num_msg := 0;

         RETURN;

      ELSIF v_prev_exec_status_cd IN ('CANCELLED_RERUN', 'ERROR_RERUN') THEN

      -- -------------------------------------------------------------------
      -- No lock exists and execution state is RERUN
      -- -------------------------------------------------------------------

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => fnd_log.level_procedure,
            p_module   => 'fem.plsql.fem_pl_incr_pkg.' ||
                          'xgl_obj_exec_lock_exists.end.rerun',
            p_msg_text => 'END: x_exec_state = RERUN');

         x_obj_exec_lock_exists := 'F';
         x_exec_state := 'RERUN';
         x_prev_request_id := v_prev_request_id;
         x_num_msg := 0;

         RETURN;

      ELSIF v_prev_exec_status_cd IN ('CANCELLED_UNDO', 'ERROR_UNDO') THEN

      -- -------------------------------------------------------------------
      -- Exec Undo Lock:
      -- A lock exists until the previous execution is undone
      -- -------------------------------------------------------------------

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => fnd_log.level_exception,
            p_module   => 'fem.plsql.fem_pl_incr_pkg.' ||
                          'xgl_obj_exec_lock_exists.end.eule1.',
            p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_018');

         FEM_ENGINES_PKG.Put_Message
           (p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_018');

         x_obj_exec_lock_exists := 'T';
         x_exec_state := NULL;
         x_num_msg := 1;

         RETURN;

      ELSIF v_prev_exec_status_cd = 'RUNNING' THEN

      -- -------------------------------------------------------------------
      -- Determine whether this is a restart or whether another instance is
      -- still running.  This comparison differs depending on the calling
      -- context.  The "restart" execution mode is impossible from the UI
      -- because there is no concurrent manager context -- The UI is only
      -- checking if there is a lock prior to starting a concurrent request.
      -- So a RUNNING status for the previous execution can only mean that
      -- the previous execution is still running.
      -- -------------------------------------------------------------------

         IF p_calling_context = 'UI' THEN

         -- ----------------------------------------------------------------
         -- Object Already Running:
         -- A lock exists because another instance of the current object
         -- version is still running for the given ledger, dataset, and
         -- period.
         -- ----------------------------------------------------------------

            FEM_ENGINES_PKG.Tech_Message
              (p_severity => fnd_log.level_exception,
               p_module   => 'fem.plsql.fem_pl_incr_pkg.' ||
                             'xgl_obj_exec_lock_exists.end.oar1.',
               p_app_name => 'FEM',
               p_msg_name => 'FEM_GL_POST_019');

            FEM_ENGINES_PKG.Put_Message
              (p_app_name => 'FEM',
               p_msg_name => 'FEM_GL_POST_019');

            x_obj_exec_lock_exists := 'T';
            x_exec_state := NULL;
            x_num_msg := 1;

            RETURN;

         ELSE

         -- ----------------------------------------------------------------
         -- p_calling_context must be 'ENGINE'
         -- ----------------------------------------------------------------

            v_current_request_id := FND_GLOBAL.CONC_REQUEST_ID;

            IF v_current_request_id = v_prev_request_id THEN

            -- -------------------------------------------------------------
            -- No lock exists, execution state is RESTART
            -- -------------------------------------------------------------

               FEM_ENGINES_PKG.Tech_Message
                 (p_severity => fnd_log.level_procedure,
                  p_module   => 'fem.plsql.fem_pl_incr_pkg.' ||
                                'xgl_obj_exec_lock_exists.end.restart',
                  p_msg_text => 'END: x_exec_state = RESTART');

               x_obj_exec_lock_exists := 'F';
               x_exec_state := 'RESTART';
               x_num_msg := 0;

               RETURN;

            ELSE

            -- -------------------------------------------------------------
            -- Object Already Running:
            -- A lock exists because another instance of the current object
            -- version is still running for the given ledger, dataset, and
            -- period.
            -- -------------------------------------------------------------

               FEM_ENGINES_PKG.Tech_Message
                 (p_severity => fnd_log.level_exception,
                  p_module   => 'fem.plsql.fem_pl_incr_pkg.' ||
                                'xgl_obj_exec_lock_exists.end.oar2.',
                  p_app_name => 'FEM',
                  p_msg_name => 'FEM_GL_POST_019');

               FEM_ENGINES_PKG.Put_Message
                 (p_app_name => 'FEM',
                  p_msg_name => 'FEM_GL_POST_019');

               x_obj_exec_lock_exists := 'T';
               x_exec_state := NULL;
               x_num_msg := 1;

               RETURN;

            END IF;

         END IF;

      END IF;

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => fnd_log.level_exception,
         p_module   => 'fem.plsql.fem_pl_incr_pkg.' ||
                       'xgl_obj_exec_lock_exists.end',
         p_msg_text => 'Invalid Exec Status for previous execution: ' ||
                       v_prev_exec_status_cd ||
                       '.  Previous Request ID: ' || TO_CHAR(v_prev_request_id));

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => fnd_log.level_exception,
         p_module   => 'fem.plsql.fem_pl_incr_pkg.' ||
                       'xgl_obj_exec_lock_exists.end.eule2.',
         p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_018');

      FEM_ENGINES_PKG.Put_Message
        (p_app_name => 'FEM',
         p_msg_name => 'FEM_GL_POST_018');

      x_obj_exec_lock_exists := 'T';
      x_exec_state := NULL;
      x_num_msg := 1;

   END XGL_Obj_Exec_Lock_Exists;
-- =========================================================================


-- =========================================================================
   PROCEDURE XGL_Exec_Mode_Lock_Exists
                (p_cal_period_id           IN  NUMBER,
                 p_ledger_id               IN  NUMBER,
                 p_dataset_code            IN  NUMBER,
                 p_object_id               IN  NUMBER,
                 p_exec_mode               IN  VARCHAR2,
                 x_exec_mode_lock_exists   OUT NOCOPY VARCHAR2,
                 x_num_msg                 OUT NOCOPY NUMBER) IS
-- =========================================================================
-- Purpose
--    Ensure that exactly one snapshot load is run first, before any
--    incremental loads, for each ledger, dataset, and period.
-- History
--    01-12-04  G Hall          Created
-- Arguments
--    p_cal_period_id      The Cal Period ID value passed to the engine.
--    p_ledger_id          The Ledger ID value passed to the engine.
--    p_dataset_code       The Dataset Code value passed to the engine.
--    p_object_id          The Object ID identifying the rule being
--                         executed.
--    p_exec_mode          'S' (snapshot), 'I', (incremental),
--                         'E' (error reprocessing).
--    x_exec_mode_lock_exists Returns 'T' or 'F'.
--    x_num_msg            Returns the number of end-user messages put onto
--                         the FND message stack by this procedure.
-- Logic
-- 1. Check that there is no entry in the FEM_PL_REQUESTS table for the
--    given ledger, dataset, period, and object with EXEC_MODE_CODE = 'S'
--    (SNAPSHOT) and EXEC_STATUS = 'SUCCESS' ('CANCELLED_UNDO' and
--    'ERROR_UNDO' have already been checked for by XGL_Obj_Exec_Lock_Exists,
--    and 'CANCELLED_RERUN' or 'ERROR_RERUN' are OK since they indicate an
--    incomplete run).  If there is, the snapshot has already been run.
-- 2. Check that there is an entry in the FEM_PL_REQUESTS table
--    for the given ledger, dataset, and period, and object with
--    EXEC_MODE_CODE = 'S' (SNAPSHOT) and EXEC_STATUS = 'SUCCESS'.  If not,
--    raise the Snapshot Not Run Yet exception.
-- Notes
--    Called by FEM_PL_INCR.Exec_Lock_Exists.
-- =========================================================================

      v_row_count   NUMBER;

   BEGIN

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => fnd_log.level_procedure,
         p_module   => 'fem.plsql.fem_pl_incr_pkg.' ||
                       'xgl_exec_mode_lock_exists.begin',
         p_msg_text => 'BEGIN');

      IF p_exec_mode NOT IN ('S', 'I', 'E') THEN

      -- Execution mode is invalid

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => fnd_log.level_exception,
            p_module   => 'fem.plsql.fem_pl_incr_pkg.' ||
                          'xgl_exec_mode_lock_exists.iem',
            p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_014');

         FEM_ENGINES_PKG.Put_Message
           (p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_014');

         x_num_msg := 1;
         x_exec_mode_lock_exists := 'T';

         RETURN;

      END IF;

   -- ---------------------------------------------------------------------
   -- Find out if there are any previous snapshot loads successfully
   -- completed for the given ledger, dataset, period, and rule.
   -- ---------------------------------------------------------------------

      SELECT COUNT(*)
      INTO v_row_count
      FROM fem_pl_requests r,
           fem_pl_object_executions o
      WHERE r.cal_period_id       = p_cal_period_id
        AND r.ledger_id           = p_ledger_id
        AND r.output_dataset_code = p_dataset_code
        AND r.exec_mode_code      = 'S'
        AND r.exec_status_code    = 'SUCCESS'
        AND o.request_id          = r.request_id
        AND o.object_id           = p_object_id;

      IF (p_exec_mode = 'S') AND (v_row_count > 0) THEN

      -- ------------------------------------------------------------------
      -- The snapshot load has already been run for this Ledger, Dataset,
      -- and period.
      -- ------------------------------------------------------------------

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => fnd_log.level_exception,
            p_module   => 'fem.plsql.fem_pl_incr_pkg.' ||
                          'xgl_exec_mode_lock_exists.ssar',
            p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_012');

         FEM_ENGINES_PKG.Put_Message
           (p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_012');

         x_num_msg := 1;
         x_exec_mode_lock_exists := 'T';

         RETURN;

      ELSIF (p_exec_mode in ('I', 'E')) AND (v_row_count = 0) THEN

      -- ------------------------------------------------------------------
      -- The snapshot load has not been run yet for this Ledger, Dataset,
      -- and period.
      -- ------------------------------------------------------------------

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => fnd_log.level_exception,
            p_module   => 'fem.plsql.fem_pl_incr_pkg.' ||
                          'xgl_exec_mode_lock_exists.ssnry',
            p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_013');

         FEM_ENGINES_PKG.Put_Message
           (p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_013');

         x_num_msg := 1;
         x_exec_mode_lock_exists := 'T';

         RETURN;

      END IF;

      x_num_msg := 0;
      x_exec_mode_lock_exists := 'F';

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => fnd_log.level_procedure,
         p_module   => 'fem.plsql.fem_pl_incr_pkg.' ||
                       'xgl_exec_mode_lock_exists.end',
         p_msg_text => 'END');

   END XGL_Exec_Mode_Lock_Exists;
-- =========================================================================


-- =========================================================================
   PROCEDURE Snapshot_Period_Lock_Exists
                (p_cal_period_id           IN  NUMBER,
                 p_ledger_id               IN  NUMBER,
                 p_dataset_code            IN  NUMBER,
                 x_ss_per_lock_exists      OUT NOCOPY VARCHAR2,
                 x_num_msg                 OUT NOCOPY NUMBER) IS
-- =========================================================================
-- Purpose
--    For snapshot loads, make sure that the targeted period will be the
--    latest loaded period.  This is done by checking FEM_PL_REQUESTS for
--    any successful executions for periods after the current period, for
--    the given ledger and dataset (it isn't necessary to check the current
--    period; that was already done in XGL_Exec_Mode_Lock_Exists).
-- History
--    12-22-03  G Hall     Created
--    11-22-04  G Hall     This procedure is now obsolete, per bu# 3922507.
--                         The check performed by this procedure was only
--                         needed if roll up and/or roll forward were
--                         implemented for XGL; they have not been and
--                         probably won't be.  However, this procedure can
--                         be saved for a while in case that plan changes.
-- Arguments
--    p_cal_period_id      The Cal Period ID value passed to the engine.
--    p_ledger_id          The Ledger ID value passed to the engine.
--    p_dataset_code       The Dataset Code value passed to the engine.
--    x_ss_per_lock_exists Returns 'T' or 'F'.
--    x_num_msg            Returns the number of end-user messages put onto
--                         the FND message stack by this procedure.
-- Notes
--    Called by FEM_PL_INCR.Exec_Lock_Exists.
--    This procedure can also be used for Incremental loads to identify
--    if the period is a back-post.
-- =========================================================================

      v_cal_per_dim_id     fem_dimensions_b.dimension_id%TYPE;
      v_API_return_code    NUMBER;
      v_dim_attr_id        fem_dim_attributes_b.attribute_id%TYPE;
      v_dim_attr_ver_id    fem_dim_attr_versions_b.version_id%TYPE;
      v_cal_per_end_date   fem_cal_periods_attr.date_assign_value%TYPE;
      v_row_count          NUMBER;
      v_dim_name1          fem_dimensions_tl.dimension_name%TYPE;
      v_attr_name          fem_dim_attributes_tl.attribute_name%TYPE;

   BEGIN

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => fnd_log.level_procedure,
         p_module   => 'fem.plsql.fem_pl_incr_pkg.' ||
                       'snapshot_period_lock_exists.begin',
         p_msg_text => 'BEGIN');

   -- -----------------------------------------------------------------------
   -- Look up the Attribute ID and the Version ID for the CAL_PERIOD_END_DATE
   -- attribute, and look up its value for the current Cal Period ID.
   -- -----------------------------------------------------------------------

      SELECT dimension_id
      INTO v_cal_per_dim_id
      FROM fem_dimensions_b
      WHERE dimension_varchar_label = 'CAL_PERIOD';

      fem_dimension_util_pkg.get_dim_attr_id_ver_id
        (x_err_code    => v_API_return_code,
         x_attr_id     => v_dim_attr_id,
         x_ver_id      => v_dim_attr_ver_id,
         p_dim_id      => v_cal_per_dim_id,
         p_attr_label  => 'CAL_PERIOD_END_DATE');

      IF v_API_return_code > 0 THEN
         RAISE NO_DATA_FOUND;
      END IF;

      SELECT date_assign_value
      INTO v_cal_per_end_date
      FROM fem_cal_periods_attr
      WHERE attribute_id  = v_dim_attr_id
        AND version_id    = v_dim_attr_ver_id
        AND cal_period_id = p_cal_period_id;

      FEM_ENGINES_PKG.Tech_Message
      (p_severity    => fnd_log.level_statement,
       p_module   => 'fem.plsql.fem_pl_incr_pkg.' ||
                     'snapshot_period_lock_exists.v_cal_per_end_date',
       p_app_name => 'FEM',
       p_msg_name => 'FEM_GL_POST_204',
       p_token1   => 'VAR_NAME',
       p_value1   => 'v_cal_per_end_date',
       p_token2   => 'VAR_VAL',
       p_value2   => TO_CHAR(v_cal_per_end_date, 'DD-MON-YYYY'));

   -- ----------------------------------------------------------------------
   -- See if there are has been any processing for any later period.
   -- ----------------------------------------------------------------------

   -- Note:  This SQL is incorrect; it needs to check only XGL requests.
   --
   -- SELECT count(*)
   -- INTO v_row_count
   -- FROM fem_pl_requests r,
   --      fem_cal_periods_attr a
   -- WHERE r.ledger_id           = p_ledger_id
   --   AND r.output_dataset_code = p_dataset_code
   --   AND r.exec_status_code    = 'SUCCESS'
   --   AND a.attribute_id        = v_dim_attr_id
   --   AND a.version_id          = v_dim_attr_ver_id
   --   AND a.cal_period_id       = r.cal_period_id
   --   AND a.date_assign_value   > v_cal_per_end_date;
   --
   -- Note: The following SQL should be correct, however it has only been
   --       superficially tested, since this procedure is currently obsolete.
   --       If this procedure is reinstated, this section needs to be fully
   --       tested.
   --
      SELECT count(*)
      INTO v_row_count
      FROM fem_pl_requests r,
           fem_pl_object_executions e,
           fem_object_catalog_b o,
           fem_cal_periods_attr a
      WHERE r.ledger_id           = p_ledger_id
        AND r.output_dataset_code = p_dataset_code
        AND r.exec_status_code    = 'SUCCESS'
        AND e.request_id          = r.request_id
        AND o.object_id           = e.object_id
        AND o.object_type_code    = 'XGL_INTEGRATION'
        AND a.attribute_id        = v_dim_attr_id
        AND a.version_id          = v_dim_attr_ver_id
        AND a.cal_period_id       = r.cal_period_id
        AND a.date_assign_value   > v_cal_per_end_date;

      IF v_row_count > 0 THEN

      -- This snapshot load is being run out of order.

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => fnd_log.level_exception,
            p_module   => 'fem.plsql.fem_pl_incr_pkg.' ||
                          'snapshot_period_lock_exists.ssple',
            p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_015');

         FEM_ENGINES_PKG.Put_Message
           (p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_015');

         x_num_msg := 1;
         x_ss_per_lock_exists := 'T';

         RETURN;

      END IF;

      x_num_msg := 0;
      x_ss_per_lock_exists := 'F';

      FEM_ENGINES_PKG.Tech_Message
        (p_severity => fnd_log.level_procedure,
         p_module   => 'fem.plsql.fem_pl_incr_pkg.' ||
                       'snapshot_period_lock_exists.end',
         p_msg_text => 'END');

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
      -- -------------------------------------------------------------------
      -- This exception can occur in retrieving the Cal Period End Date
      -- attribute.  Log a message indicating Invalid Calendar Period
      -- because the Cal Period End Date Attribute is not set.
      -- -------------------------------------------------------------------

         v_dim_name1 := FEM_DIMENSION_UTIL_PKG.Get_Dimension_Name
                           (p_dim_id => v_cal_per_dim_id);

         IF v_dim_name1 IS NULL THEN
            v_dim_name1 := 'Calendar Period';
         END IF;

         v_attr_name := FEM_DIMENSION_UTIL_PKG.Get_Dim_Attr_Name
                           (p_dim_id     => v_cal_per_dim_id,
                            p_attr_label => 'CAL_PERIOD_END_DATE');

         IF v_attr_name IS NULL THEN
            v_attr_name := 'Calendar Period End Date';
         END IF;

         FEM_ENGINES_PKG.Tech_Message
           (p_severity => fnd_log.level_exception,
            p_module   => 'fem.plsql.fem_pl_incr_pkg.' ||
                          'snapshot_period_lock_exists.invalid_cal_period_id',
            p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_003',
            p_token1   => 'DIMENSION_NAME1',
            p_value1   => v_dim_name1,
            p_token2   => 'DIMENSION_NAME2',
            p_value2   => v_dim_name1,
            p_token3   => 'ATTRIBUTE_NAME',
            p_value3   => v_attr_name);

         FEM_ENGINES_PKG.Put_Message
           (p_app_name => 'FEM',
            p_msg_name => 'FEM_GL_POST_003',
            p_token1   => 'DIMENSION_NAME1',
            p_value1   => v_dim_name1,
            p_token2   => 'DIMENSION_NAME2',
            p_value2   => v_dim_name1,
            p_token3   => 'ATTRIBUTE_NAME',
            p_value3   => v_attr_name);

         x_num_msg := 1;
         x_ss_per_lock_exists := 'T';

         RAISE;

   END Snapshot_Period_Lock_Exists;
-- =======================================================================


-- =========================================================================
   PROCEDURE Fact_Obj_Exec_Lock_Exists
                (p_calling_context         IN  VARCHAR2 DEFAULT 'ENGINE',
                 p_object_id               IN  NUMBER,
                 p_obj_def_id              IN  NUMBER,
                 p_cal_period_id           IN  NUMBER,
                 p_ledger_id               IN  NUMBER,
                 p_dataset_code            IN  NUMBER,
                 p_source_system_code      IN  NUMBER,
                 p_table_name              IN  VARCHAR2,
                 x_obj_exec_lock_exists    OUT NOCOPY VARCHAR2,
                 x_exec_state              OUT NOCOPY VARCHAR2,
                 x_prev_request_id         OUT NOCOPY NUMBER,
                 x_num_msg                 OUT NOCOPY NUMBER) IS
-- =========================================================================
-- Purpose
--    Performs process validations specific to Fact Data Loader
--    to ensure that there are no process execution locks.
-- History
--    02-21-06  gcheng     Created
-- Arguments
--    p_calling_context    'ENGINE' (default) or 'UI'.
--    p_object_id          The Object ID identifying the rule being executed.
--    p_obj_def_id         The Object_Definition_ID identifying the version
--                         of the rule being executed.
--    p_cal_period_id      The Cal Period ID value passed to the engine.
--    p_ledger_id          The Ledger ID value passed to the engine.
--    p_dataset_code       The Dataset Code value passed to the engine.
--    p_source_system_code The Source System Code value passed to the engine.
--    p_table_name         The Table that the rule is writing to.
--    x_obj_lock_exists    Returns 'T' or 'F'.
--    x_exec_state         Return values are 'NORMAL', 'RERUN', 'RESTART'
--    x_prev_request_id    Passes back the Request ID of the previous
--                         execution for the given ledger, dataset, period,
--                         system, table and object when x_exec_state = 'RERUN'.
--    x_num_msg            Returns the number of end-user messages put onto
--                         the FND message stack by this procedure.
-- Notes
--    Called by FEM_PL_INCR_PKG.Exec_Lock_Exists.
-- =========================================================================

      C_MODULE                 CONSTANT FND_LOG_MESSAGES.module%TYPE :=
          'fem.plsql.fem_pl_incr_pkg.fact_obj_exec_lock_exists';

      v_prev_event_order       fem_pl_object_executions.event_order%TYPE;
      v_prev_exec_status_cd    fem_pl_object_executions.exec_status_code%TYPE;
      v_prev_request_id        fem_pl_object_executions.request_id%TYPE;

      v_current_request_id     NUMBER;

      v_msg_count              NUMBER;
      v_msg_data               VARCHAR2(512);
      v_return_status          VARCHAR2(1);

      CURSOR c1 IS
         SELECT r.request_id
         FROM fem_pl_requests r,
              fem_pl_object_executions o
         WHERE r.cal_period_id       = p_cal_period_id
           AND r.ledger_id           = p_ledger_id
           AND r.output_dataset_code = p_dataset_code
           AND r.source_system_code  = p_source_system_code
           AND r.table_name          = p_table_name
           AND o.request_id          = r.request_id
           AND o.object_id           = p_object_id
           AND o.exec_status_code    = G_RUNNING;

   BEGIN

      IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FEM_ENGINES_PKG.Tech_Message
           (p_severity => fnd_log.level_procedure,
            p_module   => C_MODULE || '.begin',
            p_msg_text => 'BEGIN');
      END IF;

      -- Initialize vars:
      x_obj_exec_lock_exists := NULL;
      x_num_msg := 0;

   -- ----------------------------------------------------------------------
   -- Reset failed executions that are left in 'RUNNING' status to their
   -- correct error status.
   -- ----------------------------------------------------------------------

      FOR reset IN c1 LOOP

         IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FEM_ENGINES_PKG.Tech_Message
               (p_severity => fnd_log.level_statement,
                p_module   => C_MODULE || '.reset_request_id',
                p_app_name => 'FEM',
                p_msg_name => 'FEM_GL_POST_204',
                p_token1   => 'VAR_NAME',
                p_value1   => 'reset.request_id',
                p_token2   => 'VAR_VAL',
                p_value2   => reset.request_id);
         END IF;

         FEM_PL_PKG.set_exec_state
           (p_api_version   => 1.0,
            p_commit        => fnd_api.g_false,
            p_request_id    => reset.request_id,
            p_object_id     => p_object_id,
            x_msg_count     => v_msg_count,
            x_msg_data      => v_msg_data,
            x_return_status => v_return_status);

      END LOOP;

   -- ----------------------------------------------------------------------
   -- Check for execution locks and determine execution state based on the
   -- EXEC_STATUS_CODE of the most recent execution for the given ledger,
   -- dataset, period, and object/object version.
   -- ----------------------------------------------------------------------

      SELECT MAX(e.event_order)
      INTO v_prev_event_order
      FROM fem_pl_requests r,
           fem_pl_object_executions e
      WHERE r.ledger_id           = p_ledger_id
        AND r.cal_period_id       = p_cal_period_id
        AND r.output_dataset_code = p_dataset_code
        AND r.source_system_code  = p_source_system_code
        AND r.table_name          = p_table_name
        AND e.request_id          = r.request_id
        AND e.object_id           = p_object_id
        AND e.exec_object_definition_id = p_obj_def_id;

   BEGIN
      SELECT exec_status_code, request_id
      INTO v_prev_exec_status_cd, v_prev_request_id
      FROM fem_pl_object_executions
      WHERE event_order = v_prev_event_order;
   EXCEPTION
      WHEN no_data_found THEN
         v_prev_exec_status_cd := NULL;
   END;

      IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FEM_ENGINES_PKG.Tech_Message
           (p_severity => fnd_log.level_procedure,
            p_module   => C_MODULE || '.prev_exec_status',
            p_msg_text => 'v_prev_exec_status_cd: ' || v_prev_exec_status_cd);
      END IF;

      IF v_prev_exec_status_cd IS NULL THEN

      -- ----------------------------------------------------------------
      -- There is no lock, and execution state is NORMAL.  This will be
      -- the case for the first run of each period for the given ledger
      -- and dataset, i.e. the snapshot load.
      -- ----------------------------------------------------------------

         x_obj_exec_lock_exists := 'F';
         x_exec_state := 'NORMAL';

      ELSIF v_prev_exec_status_cd = 'SUCCESS' THEN

      -- -------------------------------------------------------------------
      -- No lock exists and execution state is NORMAL
      -- -------------------------------------------------------------------

         x_obj_exec_lock_exists := 'F';
         x_exec_state := 'NORMAL';

      ELSIF v_prev_exec_status_cd IN ('CANCELLED_RERUN', 'ERROR_RERUN') THEN

      -- -------------------------------------------------------------------
      -- No lock exists and execution state is RERUN
      -- -------------------------------------------------------------------

         x_obj_exec_lock_exists := 'F';
         x_exec_state := 'RERUN';
         x_prev_request_id := v_prev_request_id;

      ELSIF v_prev_exec_status_cd IN ('CANCELLED_UNDO', 'ERROR_UNDO') THEN

      -- -------------------------------------------------------------------
      -- Exec Undo Lock:
      -- A lock exists until the previous execution is undone
      -- -------------------------------------------------------------------

         x_obj_exec_lock_exists := 'T';

      ELSIF v_prev_exec_status_cd = 'RUNNING' THEN

      -- -------------------------------------------------------------------
      -- Determine whether this is a restart or whether another instance is
      -- still running.  This comparison differs depending on the calling
      -- context.  The "restart" execution mode is impossible from the UI
      -- because there is no concurrent manager context -- The UI is only
      -- checking if there is a lock prior to starting a concurrent request.
      -- So a RUNNING status for the previous execution can only mean that
      -- the previous execution is still running.
      -- -------------------------------------------------------------------

         IF p_calling_context = 'UI' THEN

         -- ----------------------------------------------------------------
         -- Object Already Running:
         -- A lock exists because another instance of the current object
         -- version is still running for the given ledger, dataset, and
         -- period.
         -- ----------------------------------------------------------------

            x_obj_exec_lock_exists := 'T';

         ELSE

         -- ----------------------------------------------------------------
         -- p_calling_context must be 'ENGINE'
         -- ----------------------------------------------------------------

            v_current_request_id := FND_GLOBAL.CONC_REQUEST_ID;

            IF v_current_request_id = v_prev_request_id THEN

            -- -------------------------------------------------------------
            -- No lock exists, execution state is RESTART
            -- -------------------------------------------------------------

               x_obj_exec_lock_exists := 'F';
               x_exec_state := 'RESTART';

            ELSE

            -- -------------------------------------------------------------
            -- Object Already Running:
            -- A lock exists because another instance of the current object
            -- version is still running for the given ledger, dataset, and
            -- period.
            -- -------------------------------------------------------------

               x_obj_exec_lock_exists := 'T';

            END IF; -- v_current_request_id = v_prev_request_id

         END IF; -- p_calling_context = 'UI'

      END IF; -- v_prev_exec_status_cd = 'SUCCESS'

      IF nvl(x_obj_exec_lock_exists,'T') = 'T' THEN
         IF x_obj_exec_lock_exists IS NULL THEN
            IF FND_LOG.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
               FEM_ENGINES_PKG.Tech_Message
                (p_severity => fnd_log.level_exception,
                 p_module   => C_MODULE || '.invalid_prev_exec_status',
                 p_msg_text => 'Invalid Exec Status for previous execution: ' ||
                               v_prev_exec_status_cd ||
                               '.  Previous Request ID: ' || TO_CHAR(v_prev_request_id));
            END IF;

            x_obj_exec_lock_exists := 'T';
         END IF;

         IF FND_LOG.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FEM_ENGINES_PKG.Tech_Message
              (p_severity => fnd_log.level_exception,
               p_module   => C_MODULE || '.lock_exists',
               p_app_name => 'FEM',
               p_msg_name => 'FEM_PL_RESULTS_EXIST_ERR');
         END IF;

         FEM_ENGINES_PKG.Put_Message
           (p_app_name => 'FEM',
            p_msg_name => 'FEM_PL_RESULTS_EXIST_ERR');

         x_num_msg := 1;
         x_exec_state := NULL;

      ELSE
         IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FEM_ENGINES_PKG.Tech_Message
              (p_severity => fnd_log.level_procedure,
               p_module   => C_MODULE || '.exec_state',
               p_msg_text => 'x_exec_state = ' || x_exec_state);
         END IF;
      END IF;

      IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FEM_ENGINES_PKG.Tech_Message
           (p_severity => fnd_log.level_procedure,
            p_module   => C_MODULE || '.end',
            p_msg_text => 'END');
      END IF;

   END Fact_Obj_Exec_Lock_Exists;
-- =========================================================================


-- =========================================================================
   PROCEDURE Fact_Exec_Mode_Lock_Exists
                (p_cal_period_id           IN  NUMBER,
                 p_ledger_id               IN  NUMBER,
                 p_dataset_code            IN  NUMBER,
                 p_source_system_code      IN  NUMBER,
                 p_table_name              IN  VARCHAR2,
                 p_object_id               IN  NUMBER,
                 p_exec_mode               IN  VARCHAR2,
                 x_exec_mode_lock_exists   OUT NOCOPY VARCHAR2,
                 x_num_msg                 OUT NOCOPY NUMBER) IS
-- =========================================================================
-- Purpose
--    Ensure that exactly one snapshot load is run first, before any
--    replacement or error reprocessing loads, for each ledger, dataset,
--    period, source system and table.
-- History
--    02-21-06  gcheng          Created
-- Arguments
--    p_cal_period_id      The Cal Period ID value passed to the engine.
--    p_ledger_id          The Ledger ID value passed to the engine.
--    p_dataset_code       The Dataset Code value passed to the engine.
--    p_source_system_code The Source System Code value passed to the engine.
--    p_table_name         The Table that the rule is writing to.
--    p_object_id          The Object ID identifying the rule being
--                         executed.
--    p_exec_mode          'S' (snapshot), 'I', (incremental),
--                         'E' (error reprocessing).
--    x_exec_mode_lock_exists Returns 'T' or 'F'.
--    x_num_msg            Returns the number of end-user messages put onto
--                         the FND message stack by this procedure.
-- Logic
--    For a given ledger, dataset, period, system, and table,
--    the Fact Data Loader rule can only run in Snapshot (S) mode
--    if no data has been written out to the given parameter set.
--    Also, the Fact Data Loader can only run in Error Reprocessing (E)
--    or Replacement (R) mode once Snapshot mode was run once,
--    regardless if that Snapshot run wrote any data to the table.
-- Notes
--    Called by FEM_PL_INCR_PKG.Exec_Lock_Exists.
-- =========================================================================

      C_MODULE                 CONSTANT FND_LOG_MESSAGES.module%TYPE :=
          'fem.plsql.fem_pl_incr_pkg.fact_exec_mode_lock_exists';

      v_row_count   NUMBER;

   BEGIN

      IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FEM_ENGINES_PKG.Tech_Message
           (p_severity => fnd_log.level_procedure,
            p_module   => C_MODULE || '.begin',
            p_msg_text => 'BEGIN');
      END IF;

      IF p_exec_mode NOT IN ('S', 'R', 'E') THEN

      -- Execution mode is invalid

         IF FND_LOG.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FEM_ENGINES_PKG.Tech_Message
              (p_severity => fnd_log.level_exception,
               p_module   => C_MODULE || '.inv_exec_mode',
               p_app_name => 'FEM',
               p_msg_name => 'FEM_SD_LDR_INV_EXEC_MODE');
         END IF;

         FEM_ENGINES_PKG.Put_Message
           (p_app_name => 'FEM',
            p_msg_name => 'FEM_SD_LDR_INV_EXEC_MODE');

         x_num_msg := 1;
         x_exec_mode_lock_exists := 'T';

         RETURN;

      END IF;


   -- ---------------------------------------------------------------------
   -- A Snapshot load can only be run if no previous loads have already
   -- posted data for the given ledger, dataset, period, system and table.
   -- ---------------------------------------------------------------------

      IF p_exec_mode = G_SNAPSHOT THEN

         SELECT COUNT(*)
         INTO v_row_count
         FROM fem_pl_requests r,
              fem_pl_object_executions o,
              fem_pl_tables t
         WHERE r.cal_period_id       = p_cal_period_id
           AND r.ledger_id           = p_ledger_id
           AND r.output_dataset_code = p_dataset_code
           AND r.source_system_code  = p_source_system_code
           AND r.table_name          = p_table_name
           AND t.request_id          = o.request_id
           AND t.object_id           = o.object_id
           AND t.num_of_output_rows  > 0
           AND o.request_id          = r.request_id
           AND o.object_id           = p_object_id;

         IF v_row_count > 0 THEN

         -- ------------------------------------------------------------------
         -- A load has already populated data for this Ledger, Dataset,
         -- Period, System and Table.
         -- ------------------------------------------------------------------

            IF FND_LOG.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
               FEM_ENGINES_PKG.Tech_Message
                 (p_severity => fnd_log.level_exception,
                  p_module   => C_MODULE || '.data_loaded',
                  p_app_name => 'FEM',
                  p_msg_name => 'FEM_PL_CANNOT_SNAPSHOT');
            END IF;

            FEM_ENGINES_PKG.Put_Message
              (p_app_name => 'FEM',
               p_msg_name => 'FEM_PL_CANNOT_SNAPSHOT');

            x_num_msg := 1;
            x_exec_mode_lock_exists := 'T';

            RETURN;

         END IF;

      END IF;

   -- ---------------------------------------------------------------------
   -- The loader cannot run in Replacement or Error Reprocessing mode until
   -- it has run in Snapshot mode for a ledger, dataset, period, system
   -- and table.
   -- ---------------------------------------------------------------------

      IF p_exec_mode IN (G_REPLACEMENT, G_ERROR_REPROCESS) THEN

         SELECT COUNT(*)
         INTO v_row_count
         FROM fem_pl_requests r,
              fem_pl_object_executions o
         WHERE r.cal_period_id       = p_cal_period_id
           AND r.ledger_id           = p_ledger_id
           AND r.output_dataset_code = p_dataset_code
           AND r.source_system_code  = p_source_system_code
           AND r.table_name          = p_table_name
           AND r.exec_mode_code      = G_SNAPSHOT
           AND o.request_id          = r.request_id
           AND o.object_id           = p_object_id;

         IF v_row_count = 0 THEN

         -- ------------------------------------------------------------------
         -- A load has already been populated data for this Ledger, Dataset,
         -- Period, System and Table.
         -- ------------------------------------------------------------------

            IF FND_LOG.level_exception >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
               FEM_ENGINES_PKG.Tech_Message
                 (p_severity => fnd_log.level_exception,
                  p_module   => C_MODULE || '.data_loaded',
                  p_app_name => 'FEM',
                  p_msg_name => 'FEM_PL_RUN_SNAPSHOT_FIRST');
            END IF;

            FEM_ENGINES_PKG.Put_Message
              (p_app_name => 'FEM',
               p_msg_name => 'FEM_PL_RUN_SNAPSHOT_FIRST');

            x_num_msg := 1;
            x_exec_mode_lock_exists := 'T';

            RETURN;

         END IF;

      END IF;

      x_num_msg := 0;
      x_exec_mode_lock_exists := 'F';


      IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FEM_ENGINES_PKG.Tech_Message
           (p_severity => fnd_log.level_procedure,
            p_module   => C_MODULE || '.end',
            p_msg_text => 'END');
      END IF;

   END Fact_Exec_Mode_Lock_Exists;
-- =========================================================================


END FEM_PL_INCR_PKG;

/
