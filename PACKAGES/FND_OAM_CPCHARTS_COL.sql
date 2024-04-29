--------------------------------------------------------
--  DDL for Package FND_OAM_CPCHARTS_COL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_OAM_CPCHARTS_COL" AUTHID CURRENT_USER AS
  /* $Header: AFOAMCCS.pls 120.0 2005/11/18 15:37:02 appldev noship $ */

  --
  -- Name
  --   insert_metric_internal
  -- Purpose
  --   This procedure is for internal use only!
  --   This procedure will insert a row in fnd_oam_chart_metrics for the given
  --   metric name.
  --
  -- Input Arguments
  --    p_metric_name varchar2
  --    p_context varchar2
  --    p_value number
  --
  -- Output Arguments
  --
  -- Input/Output Arguments
  --
  -- Notes:
  --    This is an internal convenience method only for OAM chart data collection
  --
  PROCEDURE insert_metric_internal (
      p_metric_name in varchar2,
      p_context in varchar2,
      p_value in number);


  -- Name
  --   delete_metric_internal
  -- Purpose
  --   This procedure is for internal use only!
  --   This procedure will delete the metric entry if it exists in fnd_oam_chart_metrics for the given
  --   metric name.
  --
  -- Input Arguments
  --    p_metric_name varchar2
  --
  -- Output Arguments
  --
  -- Input/Output Arguments
  --
  -- Notes:
  --    This is an internal convenience method only for OAM chart data collection
  --
  PROCEDURE delete_metric_internal(
      p_metric_name in varchar2);

   -- Name
  --   update_metric_internal
  -- Purpose
  --   This procedure is for internal use only!
  --   This procedure will update a row in fnd_oam_chart_metrics for the given
  --   metric name. If it does not exist, then insert.
  --
  -- Input Arguments
  --    p_metric_name varchar2
  --    p_context varchar2
  --    p_value number
  --
  -- Output Arguments
  --
  -- Input/Output Arguments
  --
  -- Notes:
  --    This is an internal convenience method only for OAM chart data collection
  --

  PROCEDURE update_metric_internal (
      p_metric_name in varchar2,
      p_context in varchar2,
      p_value in number);

  --
  --
  -- Name
  --   refresh_req_status
  --
  -- Purpose
  --   Computes the metric values for the all request status
  --
  PROCEDURE refresh_req_status;

  -- Name
  --   update_req_status_metric
  --
  -- Purpose
  --   compute the metric value for one request status
  --
  PROCEDURE update_req_status_metric(p_metric_name in varchar2);

  --
  -- Name
  --   refresh_completed_req_status
  --
  -- Purpose
  --   Computes the metric values for the completed request status for the last hour
  --
  -- Input Arguments
  --
  -- Output Arguments
  --
  -- Notes:
  --
  --
  PROCEDURE refresh_completed_req_status;

  -- Name
  --   refresh_pending_req_status
  --
  -- Purpose
  --   Computes the metric values for the pending request status
  --
  -- Input Arguments
  --
  -- Output Arguments
  --
  -- Notes:
  --
  --
  PROCEDURE refresh_pending_req_status;
   -- Name
  --   refresh_running_req_duration
  --
  -- Purpose
  --   Computes the metric values for the running request duration
  --
  -- Input Arguments
  --
  -- Output Arguments
  --
  -- Notes:
  --
  --
  PROCEDURE refresh_running_req_duration;
  --
  -- Name
  --   refresh_running_req_user
  --
  -- Purpose
  --   Computes the metric values for the running request grouped by user
  --
  -- Input Arguments
  --
  -- Output Arguments
  --
  -- Notes:
  --
  --
  PROCEDURE refresh_running_req_user;
   --
  -- Name
  --   refresh_pending_req_user
  --
  -- Purpose
  --   Computes the metric values for the pending request grouped by user
  --
  --

  PROCEDURE refresh_pending_req_user;
  --
  -- Name
  --   refresh_running_req_app
  --
  -- Purpose
  --   Computes the metric values for the running request grouped by application
  --
  -- Input Arguments
  --
  -- Output Arguments
  --
  -- Notes:
  --
  --
  PROCEDURE refresh_running_req_app;
  -- Name
  --   refresh_pending_req_app
  --
  -- Purpose
  --   Computes the metric values for the pending request grouped by application
  --
  --

  PROCEDURE refresh_pending_req_app;

  --
  -- Name
  --   refresh_running_req_resp
  --
  -- Purpose
  --   Computes the metric values for the running request grouped by responsibility
  --
  -- Input Arguments
  --
  -- Output Arguments
  --
  -- Notes:
  --
  PROCEDURE refresh_running_req_resp;
   -- Name
  --   refresh_pending_req_resp
  --
  -- Purpose
  --   Computes the metric values for the pending request grouped by responsibility
  --
  --

  PROCEDURE refresh_pending_req_resp;

  -- Name
  --   update_run_req_mgr_metric
  --
  -- Purpose
  --   compute the count of running requests for a specified manager
  --
  PROCEDURE update_run_req_mgr_metric(p_queue_application_id in number,
                                          p_concurrent_queue_name in varchar2,
                                          p_user_concurrent_queue_name in varchar2);
  -- Name
  --   update_pend_req_mgr_metric
  --
  -- Purpose
  --   compute the count of pending requests for a specified manager
  --
  PROCEDURE update_pend_req_mgr_metric(p_queue_application_id in number,
                                          p_concurrent_queue_name in varchar2,
                                          p_user_concurrent_queue_name in varchar2);
  -- Name
  --   update_process_mgr_metric
  --
  -- Purpose
  --   compute the count of process for a specified manager
  --
  PROCEDURE update_process_mgr_metric(p_queue_application_id in number,
                                          p_concurrent_queue_name in varchar2,
                                          p_user_concurrent_queue_name in varchar2);
  -- Name
  --   refresh_run_req_process_mgr
  --
  -- Purpose
  --   refresh the count of running requests and processes for all managers
  --
  PROCEDURE refresh_run_req_process_mgr;
  -- Name
  --   refresh_pend_req_mgr
  --
  -- Purpose
  --   refresh the count of pending requests for all managers
  --
  PROCEDURE refresh_pend_req_mgr;
  -- Name
  --   refresh_req_stats_user
  --
  -- Purpose
  --   refresh the concurrent request statistics by user
  --
  PROCEDURE refresh_req_stats_user;

  -- Name
  --   refresh_req_stats_program
  --
  -- Purpose
  --   refresh the concurrent request statistics by program
  --
  PROCEDURE refresh_req_stats_program;
   -- Name
  --   insert_stats_user
  -- Purpose
  --   This procedure is for internal use only!
  --   This procedure will insert a row in fnd_oam_stats_user
  --
  -- Input Arguments
  --
  --
  PROCEDURE insert_stats_user (
      p_user_id in number,
      p_stats_interval in varchar2,
      p_comp_req_count in number,
      p_total_runtime in number);
  -- Name
  --   insert_stats_program
  -- Purpose
  --   This procedure is for internal use only!
  --   This procedure will insert a row in fnd_oam_stats_user
  --
  -- Input Arguments
  --
  --
  PROCEDURE insert_stats_program (
      p_app_id in number,
      p_program_id in number,
      p_stats_interval in varchar2,
      p_total_runtime in number,
      p_ave_tuntime in number,
      p_min_tuntime in number,
      p_max_tuntime in number,
      p_times_run in number);

  --
  -- Name
  --   refresh_all
  --
  -- Purpose
  --   Computes the values for all chart metrics
  --
  -- Input Arguments
  --
  -- Output Arguments
  --    errbuf - for any error message
  --    retcode - 0 for success, 1 for success with warnings, 2 for error
  --
  -- Notes:
  --
  --
  PROCEDURE refresh_all (errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY VARCHAR2);

  --
  -- Name
  --   submit_req_conditional
  --
  -- Purpose
  --   Submits a request for program 'OAMCHARTCOL' if and only if there are no
  --   other requests for this program in the pending or running phase.
  --
  -- Input Arguments
  --
  -- Output Arguments
  --
  --
  -- Notes:
  --
  --
  PROCEDURE submit_req_conditional;


END fnd_oam_cpcharts_col;

 

/
