--------------------------------------------------------
--  DDL for Package PAY_PROGRESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PROGRESS_PKG" AUTHID CURRENT_USER AS
-- $Header: pyprogpk.pkh 120.0.12010000.1 2008/07/27 23:27:24 appldev ship $
--
  -- Record to return progress info to the 'client' be it a Form
  -- or another PL/SQL block which we use to create a portlet or
  -- whatever.
  -- Sending back a whole record means that changing the information
  -- here won't break existing clients. As long as we only add
  -- fields and don't delete what was originally here.
  --
  TYPE progress_info_r IS RECORD(
    timestamp             NUMBER,
    run_description       VARCHAR2(240),
    completed             NUMBER,
    in_error              NUMBER,
    marked_for_retry      NUMBER,
    unprocessed           NUMBER,
    start_time            DATE,
    elapsed_time          NUMBER,
    completion_time       DATE,
    process_rate          NUMBER,
    time_remaining        NUMBER,
    time_per_assignment   NUMBER,
    assignments_per_hour  NUMBER,
    percent_complete      NUMBER,
    percent_in_error      NUMBER,
    message               VARCHAR2(240)
  );
--
  -- Calculate the progress of the supplied payroll action, or update the progress
  -- of the last payroll action we asked for (if the parameter is NULL or not passed).
  -- Return a record containing all the progress information.
  --
  FUNCTION current_progress(p_payroll_action_id IN NUMBER DEFAULT NULL) RETURN progress_info_r;
--
END pay_progress_pkg;

/
