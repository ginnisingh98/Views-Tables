--------------------------------------------------------
--  DDL for Package Body PAY_PROGRESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PROGRESS_PKG" AS
-- $Header: pyprogpk.pkb 120.0.12010000.2 2010/02/23 10:16:39 priupadh ship $
/*
*** ------------------------------------------------------------------------+
*** Program:     pay_progress_pkg (Package Body)
***
*** Change History
***
*** Date       Changed By  Version               Description of Change
*** ---------  ----------  -------              -----------------------------------------------------------+
*** 23 FEB 2010 priupadh   120.0.12010000.2      Bug 9274304 Modified cursor csr_action added dbms_lob.substr
***                                              to comments column .
*** -------------------------------------------------------------------------------------------------------+
*/
  -- Buffer previous progress update requests.
  -- We may use this in future to create a progress summary graph
  -- e.g. showing the processing rate over time using the timestamp field
  -- which holds the time that the progress update was requested in
  -- 100ths of a second.
  --
  TYPE progress_info_t IS TABLE OF progress_info_r INDEX BY BINARY_INTEGER;
--
  -- Global information about the progress info buffer table and the last
  -- progress update we requested.
  --
  g_num_samples   NUMBER;
  g_action_id     NUMBER;
  g_sample_list   progress_info_t;
  g_first_stamp   NUMBER;
--
  -- Get the progress of the specified payroll action, or get an update
  -- on the last action we explicitly requested info for.
  -- Buffer the progress information in a global table before sending it back.
  --
  FUNCTION current_progress(p_payroll_action_id IN NUMBER DEFAULT NULL) RETURN progress_info_r IS
    --
    -- Calculate counts of records for the action based on their status
    CURSOR csr_summary(cp_id IN NUMBER) IS
      SELECT    NVL(SUM(DECODE(action_status,'C',1,'S',1,0)),0)   completed,
                NVL(SUM(DECODE(action_status,'E',1,0)),0)   in_error,
                NVL(SUM(DECODE(action_status,'M',1,0)),0)   marked_for_retry,
                NVL(SUM(DECODE(action_status,'U',1,0)),0)   unprocessed
      FROM      pay_assignment_actions
      WHERE     payroll_action_id = cp_id
      AND       source_action_id IS NULL;
    --
    -- Determine various statistics used for calculating timing information
    CURSOR csr_time(cp_id IN NUMBER,cp_done IN VARCHAR2) IS
      SELECT    ppa.creation_date start_time,
                NVL(fcr.actual_completion_date,
                  DECODE(cp_done,'Y',ppa.last_update_date,SYSDATE)
                ) end_time,
                SYSDATE                                             current_time
      FROM      fnd_concurrent_requests fcr,pay_payroll_actions ppa
      WHERE     fcr.request_id(+) = ppa.request_id
      AND       ppa.payroll_action_id = cp_id;
    --
    -- Get the information we need to pass to the existing function
    -- in the pay_payroll_actions_pkg package, which works out the
    -- name of the run.
    CURSOR csr_action(cp_id IN NUMBER) IS
      SELECT    payroll_action_id,
                action_type,
                action_status,
                consolidation_set_id,
                display_run_number,
                element_set_id,
                assignment_set_id,
                effective_date,
                dbms_lob.substr(comments,4000,1) comments_1
      FROM      pay_payroll_actions
      WHERE     payroll_action_id = cp_id;
    --
    l_progress      progress_info_r;
    l_action        csr_action%ROWTYPE;
    l_end_time      DATE;
    l_current_time  DATE;
    l_done          VARCHAR2(1);
    --
  BEGIN
    --
    -- Timestamp this progress update in 100ths of a second
    IF g_first_stamp IS NULL THEN
      g_first_stamp := dbms_utility.get_time;
      l_progress.timestamp := 0;
    ELSE
      l_progress.timestamp := dbms_utility.get_time - g_first_stamp;
    END IF;
    --
    -- If we didn't pass an action ID and we haven't previously
    -- passed one then we can't do anything more
    IF p_payroll_action_id IS NULL AND g_action_id = -1 THEN
      RETURN l_progress;
    END IF;
    --
    -- If we passed an action ID and it's different to the
    -- last one we passed then reset the result buffer table
    IF  p_payroll_action_id IS NOT NULL
    AND p_payroll_action_id <> g_action_id
    THEN
      g_action_id := p_payroll_action_id;
      g_num_samples := 0;
      g_sample_list.Delete;
    ELSE
      g_num_samples := g_num_samples + 1;
    END IF;
    --
    -- Fetch the count of records processed into the progress record
    OPEN csr_summary(g_action_id);
    FETCH csr_summary
    INTO  l_progress.completed,
          l_progress.in_error,
          l_progress.marked_for_retry,
          l_progress.unprocessed;
    CLOSE csr_summary;
    --
    IF l_progress.unprocessed + l_progress.marked_for_retry > 0 THEN
      l_done := 'N';
    ELSE
      l_done := 'Y';
    END IF;
    --
    -- Get the start time and other intermediate timing info
    OPEN csr_time(g_action_id,l_done);
    FETCH csr_time
    INTO  l_progress.start_time,
          l_end_time,
          l_current_time;
    CLOSE csr_time;
    --
    IF l_end_time IS NOT NULL THEN
      l_current_time := l_end_time;
    END IF;
    l_progress.elapsed_time := (l_current_time - l_progress.start_time) * (24*60*60);
    IF l_progress.completed + l_progress.in_error > 0 THEN
      l_progress.process_rate := l_progress.elapsed_time / (l_progress.completed + l_progress.in_error);
      l_progress.time_remaining := (((l_progress.unprocessed + l_progress.marked_for_retry) * l_progress.process_rate) / (60*60));
      l_progress.completion_time := l_current_time + (l_progress.time_remaining / 24);
      l_progress.time_remaining := ROUND(l_progress.time_remaining);
    END IF;
    l_progress.time_per_assignment := ROUND(l_progress.process_rate);
    IF l_progress.process_rate > 0 THEN
      l_progress.assignments_per_hour := ROUND((60*60)/l_progress.process_rate);
    END IF;
    --
    OPEN csr_action(g_action_id);
    FETCH csr_action INTO l_action;
    CLOSE csr_action;
    --
    l_progress.run_description := pay_payroll_actions_pkg.v_name(
      l_action.payroll_action_id,
      l_action.action_type,
      l_action.consolidation_set_id,
      l_action.display_run_number,
      l_action.element_set_id,
      l_action.assignment_set_id,
      l_action.effective_date
    );
    l_progress.message := l_action.comments_1;
    --
    -- Work out the total percent complete and in error
    if (l_progress.in_error + l_progress.completed +
        l_progress.marked_for_retry + l_progress.unprocessed) > 0 then
      l_progress.percent_complete := ((l_progress.in_error +
          l_progress.completed) / (l_progress.in_error + l_progress.completed +
                  l_progress.marked_for_retry + l_progress.unprocessed)) * 100;
      l_progress.percent_in_error := (l_progress.in_error /
         (l_progress.in_error + l_progress.completed +
                  l_progress.marked_for_retry + l_progress.unprocessed)) * 100;
    else
      l_progress.percent_complete := 0;
      l_progress.percent_in_error := 0;
    end if;
    --
    g_sample_list(g_num_samples) := l_progress;
    RETURN l_progress;
  END current_progress;
--
BEGIN
  g_num_samples := 0;
  g_action_id   := -1;
  g_sample_list.Delete;
END pay_progress_pkg;

/
