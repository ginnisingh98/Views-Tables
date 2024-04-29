--------------------------------------------------------
--  DDL for Package Body PAY_PST_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PST_UTILS" AS
/* $Header: pypstutl.pkb 120.0 2006/06/07 02:14:56 exjones noship $ */
--
  g_last_batch_id          NUMBER          := -1;
  g_last_api_id            NUMBER          := -1;
  g_last_time              NUMBER          := dbms_utility.get_time;
  g_cache_age              NUMBER          := 1000; -- In hundredths of a second
  --
  g_batch_status           VARCHAR2(30)    := 'BATCH_STATUS_UNKNOWN';
  g_percent_complete       NUMBER          := -1;
  g_process_status         VARCHAR2(30)    := 'PROCESS_STATUS_UNKNOWN';
  g_total_lines            NUMBER          := -1;
  g_can_update             VARCHAR2(30)    := 'CAN_UPDATE_UNKNOWN';
  g_date_started           DATE            := hr_general.start_of_time;
  g_parameter_group        VARCHAR2(240)   := 'PARAMETER_GROUP_UNKNOWN';
  g_validate_only          VARCHAR2(30)    := 'VALIDATE_ONLY_UNKNOWN';
  g_date_completed         DATE            := hr_general.end_of_time;
  g_completion_text        VARCHAR2(2000)  := 'COMPLETION_TEXT_UNKNOWN';
  g_process_phase          VARCHAR2(240)   := 'PROCESS_PHASE_UNKNOWN';
  g_last_batch_exception   VARCHAR2(2000)  := 'LAST_BATCH_EXCEPTION_UNKNOWN';
  g_display_view_errors    NUMBER          := 0;
  g_last_process_date      DATE            := hr_general.start_of_time;
  --
  g_module_name            VARCHAR2(240)   := 'MODULE_NAME_UNKNOWN';
  g_module_status          VARCHAR2(30)    := 'MODULE_STATUS_UNKNOWN';
  g_api_unprocessed        NUMBER          := -1;
  g_api_validated          NUMBER          := -1;
  g_api_error              NUMBER          := -1;
  g_api_complete           NUMBER          := -1;
--
  PROCEDURE cache_batch_data(p_batch_id IN NUMBER) IS
  --
    CURSOR csr_count(cp_batch_id IN NUMBER) IS
      SELECT SUM(DECODE(bl.line_status,'U',1,0)),
             SUM(DECODE(bl.line_status,'V',1,0)),
             SUM(DECODE(bl.line_status,'E',1,0)),
             SUM(DECODE(bl.line_status,'C',1,0))
      FROM   hr_pump_batch_lines bl
      WHERE  bl.batch_id = cp_batch_id;
    --
    CURSOR csr_except(cp_batch_id IN NUMBER) IS
      SELECT be.exception_text
      FROM   hr_pump_batch_exceptions be
      WHERE  be.source_type = 'BATCH_HEADER'
      AND    be.source_id = cp_batch_id
      AND    be.exception_sequence = (
               SELECT MAX(bx.exception_sequence)
               FROM   hr_pump_batch_exceptions bx
               WHERE  bx.source_type = 'BATCH_HEADER'
               AND    bx.source_id = cp_batch_id
             );
    --
    CURSOR csr_process(cp_batch_id IN NUMBER) IS
      SELECT cr.actual_start_date,
             nvl(pg.action_parameter_group_name,hr_general.decode_lookup('NAME_TRANSLATIONS','DEFAULT')),
             yn.meaning,
             cr.actual_completion_date,
             cr.completion_text,
             fl.meaning,
             cr.phase_code,
             cr.request_date
      FROM   fnd_concurrent_requests cr,
             fnd_concurrent_programs cp,
             fnd_application fa,
             (select action_parameter_group_name,to_char(action_parameter_group_id) action_parameter_group_id from pay_action_parameter_groups) pg,
             fnd_lookups fl,
             fnd_lookups yn
      WHERE  fa.application_short_name = 'PER'
      AND    cp.application_id = fa.application_id
      AND    cp.concurrent_program_name = 'DATAPUMP'
      AND    cr.program_application_id = cp.application_id
      AND    cr.concurrent_program_id = cp.concurrent_program_id
      AND    cr.argument1 = to_char(cp_batch_id)
      AND    pg.action_parameter_group_id (+)= cr.argument3
      AND    fl.lookup_type = 'CP_PHASE_CODE'
      AND    fl.enabled_flag = 'Y'
      AND    fl.lookup_code = cr.phase_code
      AND    yn.lookup_type = 'YES_NO'
      AND    yn.enabled_flag = 'Y'
      AND    yn.lookup_code = cr.argument2
      AND    cr.request_id = (
               SELECT MAX(crx.request_id)
               FROM   fnd_concurrent_requests crx,
                      fnd_concurrent_programs cpx,
                      fnd_application fax
               WHERE  fax.application_short_name = 'PER'
               AND    cpx.application_id = fax.application_id
               AND    cpx.concurrent_program_name = 'DATAPUMP'
               AND    crx.program_application_id = cpx.application_id
               AND    crx.concurrent_program_id = cpx.concurrent_program_id
               AND    crx.argument1 = to_char(cp_batch_id)
             );
    --
    l_unprocessed    NUMBER;
    l_validated      NUMBER;
    l_error          NUMBER;
    l_complete       NUMBER;
    --
    l_phase          VARCHAR2(30);
  --
  BEGIN
    IF p_batch_id <> g_last_batch_id OR
       g_last_time + g_cache_age < dbms_utility.get_time
    THEN
      g_last_time := dbms_utility.get_time;
      g_last_batch_id := p_batch_id;
      --
      OPEN csr_count(p_batch_id);
      FETCH csr_count
      INTO  l_unprocessed,
            l_validated,
            l_error,
            l_complete;
      CLOSE csr_count;
      --
      OPEN csr_except(p_batch_id);
      FETCH csr_except
      INTO  g_last_batch_exception;
      --
      IF csr_except%NOTFOUND THEN
        g_last_batch_exception := NULL;
      END IF;
      CLOSE csr_except;
      --
      OPEN csr_process(p_batch_id);
      FETCH csr_process
      INTO  g_date_started,
            g_parameter_group,
            g_validate_only,
            g_date_completed,
            g_completion_text,
            g_process_phase,
            l_phase,
            g_last_process_date;
      --
      IF csr_process%NOTFOUND THEN
        g_date_started := NULL;
        g_parameter_group := NULL;
        g_validate_only := NULL;
        g_date_completed := NULL;
        g_completion_text := NULL;
        g_process_phase := NULL;
        l_phase := NULL;
        g_last_process_date := NULL;
      END IF;
      CLOSE csr_process;
      --
      g_total_lines := l_unprocessed + l_validated + l_error + l_complete;
      g_percent_complete := TRUNC(((l_complete + l_validated + l_error) * 100) / g_total_lines,2);
      --
      IF l_phase = 'R' THEN
        g_batch_status := 'BATCH_STATUS_INPROGRESS';
      ELSIF l_error > 0 THEN
        g_batch_status := 'BATCH_STATUS_ERROR';
      ELSIF l_unprocessed > 0 AND l_validated + l_error + l_complete = 0 THEN
        g_batch_status := 'BATCH_STATUS_NOTSTARTED';
      ELSIF l_validated > 0 AND l_unprocessed + l_error + l_complete = 0 THEN
        g_batch_status := 'BATCH_STATUS_VALIDATED';
      ELSIF l_complete > 0 AND l_unprocessed + l_error + l_validated = 0 THEN
        g_batch_status := 'BATCH_STATUS_COMPLETE';
      ELSIF l_unprocessed + l_validated + l_error + l_complete = 0 THEN
        g_batch_status := 'BATCH_STATUS_EMPTY';
      ELSE
        g_batch_status := 'BATCH_STATUS_PARTIAL';
      END IF;
      --
      IF l_validated + l_error + l_complete + l_unprocessed = 0 THEN
        g_process_status := 'PROCESS_STATUS_EMPTY';
      ELSIF l_unprocessed > 0 AND l_validated + l_error + l_complete = 0 THEN
        g_process_status := 'PROCESS_STATUS_NOTSTARTED';
      ELSE
        g_process_status := 'PROCESS_STATUS_PROCESSED';
      END IF;
      --
      IF g_batch_status = 'BATCH_STATUS_ERROR' THEN
        g_display_view_errors := 1;
      ELSE
        g_display_view_errors := 0;
      END IF;
      --
    END IF;
  END cache_batch_data;
  --
  PROCEDURE cache_api_data(p_batch_id IN NUMBER,p_api_id IN NUMBER) IS
  --
    l_last_batch_id NUMBER := g_last_batch_id;
  --
    CURSOR csr_count(cp_batch_id IN NUMBER,cp_api_id IN NUMBER) IS
      SELECT am.module_package||'.'||am.module_name,
             SUM(DECODE(bl.line_status,'U',1,0)),
             SUM(DECODE(bl.line_status,'V',1,0)),
             SUM(DECODE(bl.line_status,'E',1,0)),
             SUM(DECODE(bl.line_status,'C',1,0))
      FROM   hr_pump_batch_lines bl,hr_api_modules am
      WHERE  bl.batch_id = cp_batch_id
      AND    bl.api_module_id = cp_api_id
      AND    am.api_module_id = bl.api_module_id
      GROUP BY
             am.module_package||'.'||am.module_name;
  --
  BEGIN
    cache_batch_data(p_batch_id);
    --
    IF p_batch_id <> l_last_batch_id OR
       p_api_id <> g_last_api_id OR
       g_last_time + g_cache_age < dbms_utility.get_time
    THEN
      g_last_time := dbms_utility.get_time;
      g_last_batch_id := p_batch_id;
      g_last_api_id := p_api_id;
      --
      OPEN csr_count(p_batch_id,p_api_id);
      FETCH csr_count
      INTO  g_module_name,
            g_api_unprocessed,
            g_api_validated,
            g_api_error,
            g_api_complete;
      CLOSE csr_count;
      --
      IF g_api_error > 0 THEN
        g_module_status := 'MODULE_STATUS_ERROR';
      ELSIF g_api_unprocessed > 0 AND g_api_validated + g_api_error + g_api_complete = 0 THEN
        g_module_status := 'MODULE_STATUS_NOTSTARTED';
      ELSIF g_api_validated > 0 AND g_api_unprocessed + g_api_error + g_api_complete = 0 THEN
        g_module_status := 'MODULE_STATUS_VALIDATED';
      ELSIF g_api_complete > 0 AND g_api_unprocessed + g_api_error + g_api_validated = 0 THEN
        g_module_status := 'MODULE_STATUS_COMPLETE';
      ELSIF g_api_unprocessed + g_api_validated + g_api_error + g_api_complete = 0 THEN
        g_module_status := 'MODULE_STATUS_EMPTY';
      ELSE
        g_module_status := 'MODULE_STATUS_PARTIAL';
      END IF;
      --
    END IF;
  END cache_api_data;
--
  FUNCTION batch_status(p_batch_id IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    cache_batch_data(p_batch_id);
    RETURN g_batch_status;
  END batch_status;
  --
  FUNCTION process_status(p_batch_id IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    cache_batch_data(p_batch_id);
    RETURN g_process_status;
  END process_status;
  --
  FUNCTION percent_complete(p_batch_id IN NUMBER) RETURN NUMBER IS
  BEGIN
    cache_batch_data(p_batch_id);
    RETURN g_percent_complete;
  END percent_complete;
  --
  FUNCTION total_lines(p_batch_id IN NUMBER) RETURN NUMBER IS
  BEGIN
    cache_batch_data(p_batch_id);
    RETURN g_total_lines;
  END total_lines;
  --
  FUNCTION can_update(p_batch_id IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    cache_batch_data(p_batch_id);
    RETURN g_can_update;
  END can_update;
  --
  FUNCTION date_started(p_batch_id IN NUMBER) RETURN DATE IS
  BEGIN
    cache_batch_data(p_batch_id);
    RETURN g_date_started;
  END date_started;
  --
  FUNCTION parameter_group(p_batch_id IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    cache_batch_data(p_batch_id);
    RETURN g_parameter_group;
  END parameter_group;
  --
  FUNCTION validate_only(p_batch_id IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    cache_batch_data(p_batch_id);
    RETURN g_validate_only;
  END validate_only;
  --
  FUNCTION date_completed(p_batch_id IN NUMBER) RETURN DATE IS
  BEGIN
    cache_batch_data(p_batch_id);
    RETURN g_date_completed;
  END date_completed;
  --
  FUNCTION completion_text(p_batch_id IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    cache_batch_data(p_batch_id);
    RETURN g_completion_text;
  END completion_text;
  --
  FUNCTION process_phase(p_batch_id IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    cache_batch_data(p_batch_id);
    RETURN g_process_phase;
  END process_phase;
  --
  FUNCTION last_batch_exception(p_batch_id IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    cache_batch_data(p_batch_id);
    RETURN g_last_batch_exception;
  END last_batch_exception;
  --
  FUNCTION display_view_errors(p_batch_id IN NUMBER) RETURN NUMBER IS
  BEGIN
    cache_batch_data(p_batch_id);
    RETURN g_display_view_errors;
  END display_view_errors;
  --
  FUNCTION last_process_date(p_batch_id IN NUMBER) RETURN DATE IS
  BEGIN
    cache_batch_data(p_batch_id);
    RETURN g_last_process_date;
  END last_process_date;
--
  FUNCTION module_name(p_batch_id IN NUMBER,p_api_id IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    cache_api_data(p_batch_id,p_api_id);
    RETURN g_module_name;
  END module_name;
  --
  FUNCTION module_status(p_batch_id IN NUMBER,p_api_id IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
    cache_api_data(p_batch_id,p_api_id);
    RETURN g_module_status;
  END module_status;
  --
  FUNCTION api_unprocessed(p_batch_id IN NUMBER,p_api_id IN NUMBER) RETURN NUMBER IS
  BEGIN
    cache_api_data(p_batch_id,p_api_id);
    RETURN g_api_unprocessed;
  END api_unprocessed;
  --
  FUNCTION api_validated(p_batch_id IN NUMBER,p_api_id IN NUMBER) RETURN NUMBER IS
  BEGIN
    cache_api_data(p_batch_id,p_api_id);
    RETURN g_api_validated;
  END api_validated;
  --
  FUNCTION api_error(p_batch_id IN NUMBER,p_api_id IN NUMBER) RETURN NUMBER IS
  BEGIN
    cache_api_data(p_batch_id,p_api_id);
    RETURN g_api_error;
  END api_error;
  --
  FUNCTION api_complete(p_batch_id IN NUMBER,p_api_id IN NUMBER) RETURN NUMBER IS
  BEGIN
    cache_api_data(p_batch_id,p_api_id);
    RETURN g_api_complete;
  END api_complete;
--
END pay_pst_utils;

/
