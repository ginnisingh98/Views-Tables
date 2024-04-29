--------------------------------------------------------
--  DDL for Package FND_OAM_COLLECTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_OAM_COLLECTION" AUTHID CURRENT_USER AS
  /* $Header: AFOAMCLS.pls 120.2.12000000.1 2007/01/18 13:22:04 appldev ship $ */

  --
  -- Name
  --   update_metric_internal
  -- Purpose
  --   This procedure is for internal use only!
  --   This procedure will update a row in fnd_oam_metval for the given
  --   metric name.
  --
  -- Input Arguments
  --    p_metric_name varchar2
  --    p_value varchar2
  --    p_status_code number : if < 0 then status_code is not updated.
  --
  -- Output Arguments
  --
  -- Input/Output Arguments
  --
  -- Notes:
  --    This is an internal convenience method only for OAM collection
  --
  PROCEDURE update_metric_internal (
      p_metric_name in varchar2,
      p_value in varchar2,
      p_status_code in number);

  --
  -- Name
  --   refresh_activity
  --
  -- Purpose
  --   Computes the values for the following indicators and updates the
  --   FND_OAM_METVAL table using an autonomous transaction.
  --      1) Number of Active Users
  --      2) Number of Database sessions
  --      3) Number of Running requests
  --      4) Number of Service Processes
  --      5) Number of Serivces Up
  --      6) Number of Serivces Down
  --      7) Number of invalid objects
  --      8) % of Workflow mailer messages waiting to be sent
  --
  -- Input Arguments
  --
  -- Output Arguments
  --
  -- Notes:
  --
  --
  PROCEDURE refresh_activity;

  --
  -- Name
  --   refresh_config_changes
  --
  -- Purpose
  --   Computes the values for the following indicators and updates the
  --   FND_OAM_METVAL table using an autonomous transaction.
  --      1) Number of patches applied in the last 24 hours
  --      2) Number of changes in profile options in last 24 hours
  --
  -- Input Arguments
  --
  -- Output Arguments
  --
  -- Notes:
  --
  --
  PROCEDURE refresh_config_changes;

  --
  -- Name
  --   refresh_throughput
  --
  -- Purpose
  --   Computes the values for the following indicators and updates the
  --   FND_OAM_METVAL table using an autonomous transaction.
  --      1) % of Completed requests
  --      2) % of Workflow mailer messages that have been processed
  --
  -- Input Arguments
  --
  -- Output Arguments
  --
  -- Notes:
  --
  --
  PROCEDURE refresh_throughput;

  --
  -- Name
  --   refresh_exceptions_summary
  --
  -- Purpose
  --   Computes the values for the following indicators and updates the
  --   FND_OAM_METVAL table using an autonomous transaction.
  --      1) Number of critical unprocessed exceptions in last 24 hours
  --      2) Number of critical processed exceptions in last 24 hours
  --      3) Number of total critical unprocessed exceptions
  --
  -- Input Arguments
  --
  -- Output Arguments
  --
  -- Notes:
  --
  --
  PROCEDURE refresh_exceptions_summary;

  --
  -- Name
  --   refresh_user_alerts_summary
  --
  -- Purpose
  --   Computes the values for the following indicators and updates the
  --   fnd_oam_mets table using an autonomous transaction.
  --
  --      1) Number of New User Alerts
  --      2) Number of New User Alert Occurrances
  --      3) Number of Open User Alerts
  --      4) Number of Open User Alert Occurrances
  --
  -- Input Arguments
  --
  -- Output Arguments
  --
  -- Notes:
  --
  --
  PROCEDURE refresh_user_alerts_summary;

  --
  -- Name
  --   refresh_miscellaneous
  --
  -- Purpose
  --   Computes the values for the following indicators and
  --   updates the FND_OAM_METVAL using an autonomous transaction.
  --   Metrics: PL/SQL Agent, Servlet Agent, JSP Agent, JTF, Discoverer,
  --            Personal Home Page, TCF
  --
  -- Input Arguments
  --
  -- Output Arguments
  --
  -- Notes:
  --
  --
  PROCEDURE refresh_miscellaneous;

  --
  -- Name
  --   refresh_app_sys_status
  --
  -- Purpose
  --   Derives the status of the following applications servers using URL
  --   pings of the corresponding processes that belong to the server. The status
  --   and host information for each of the processes as well as servers are
  --   updated in the FND_OAM_APP_SYS_STATUS table
  --      1)  Admin - Currently no processes are defined for this server
  --      2)  Web   - Consists of Apache Server and Apache Listener
  --      3)  Forms - Consists of the forms launcher
  --      4)  CP    - Consists of the Internal Concurrent Manager, Reports
  --      5)  Data  - Consists of the database instances as defined in gv$instance.
  --
  -- Input Arguments
  --
  -- Output Arguments
  --
  -- Notes:
  --
  --
  PROCEDURE refresh_app_sys_status;

  --
  -- Name
  --   raise_alerts
  --
  -- Purpose
  --   Checks values for all metrics and service instances that are currently
  --   being monitored and raises alert if the values or status codes match
  --   the thresholds specified by the user.
  --
  -- Input Arguments
  --
  -- Output Arguments
  --
  -- Notes:
  --
  --
  PROCEDURE raise_alerts;



  --
  -- Name
  --   refresh_all
  --
  -- Purpose
  --   Computes the values for all the indicators and updates the
  --   fnd_sys_metrics table.
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
  --   submit_col_req_conditional
  --
  -- Purpose
  --   Submits a request for program 'FNDOAMCOL' if and only if there are no
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
  PROCEDURE submit_col_req_conditional;

  --
  -- Name
  --   resubmit
  --
  -- Purpose
  --   Submits a request for program 'FNDOAMCOL' with the new repeat
  --   interval if the current interval is different from the new repeat
  --   interval.
  --
  --   It will cancel any pending or running requests before submitting
  --   a new request.
  --
  --   If more than one repeating requests are found, it will cancel them
  --   all and submit a new request with the given repeat interval.
  --
  --
  -- Input Arguments
  --
  --   p_repeat_interval - The new repeat interval
  --   p_repeat_interval_unit_code - The new repeat interval unit code
  --
  -- Output Arguments
  --   p_ret_code
  --	  -1 - Was unable to cancel one or more in progress requests.
  --           Check p_ret_msg for any error message.
  --      -2 - There was no need to resubmit - since the currently
  --            repeating request has the same repeat interval.
  --      >0 - Successfully resubmitted. Request id of the new request.
  --
  --   p_ret_msg
  --	  Any return error message.
  -- Notes:
  --
  --
  PROCEDURE resubmit(
	p_repeat_interval fnd_concurrent_requests.resubmit_interval%TYPE,
	p_repeat_interval_unit_code fnd_concurrent_requests.resubmit_interval_unit_code%TYPE,
	p_ret_code OUT NOCOPY number,
	p_ret_msg OUT NOCOPY varchar2);


  --
  -- Name
  --   Alert_Long_Running_Requests
  --
  -- Purpose
  --	The procedure will raise a consolidated alert if more than a user specified threshold
  --	number of concurrent requests are running for more than a user specified threshold offset
  --	period of time and for more than a user specified threshold tolerance percentage of their
  --	respective average runtimes. It also raise an alert for specified concurrent programs if it
  --	runs for more than the user specified threshold tolerance percentage of its user specific
  --	threshold offset period of time.

  -- Input Arguments
  --
  -- 	   None
  --
  -- Output Arguments
  --
  --   		None
  -- Notes:
  --
  --
	  PROCEDURE alert_long_running_requests;

  --
  -- Name
  --   Alert_Long_Pending_Requests
  --
  -- Purpose
  -- 		The procedure raises a consolidated alert if more than a user specified
  --		threshold number of concurrent requests are pending for more than a user
  --		specified threshold period of time after their requested start time.
  --		It also raise an alert for specified concurrent programs if it is
  --		pending for more than a user specified threshold period of time.
  --
  -- Input Arguments
  --
  -- 	   None
  --
  -- Output Arguments
  --
  --   		None
  -- Notes:
  --
  --
	  PROCEDURE alert_long_pending_requests;



END fnd_oam_collection;

 

/

  GRANT EXECUTE ON "APPS"."FND_OAM_COLLECTION" TO "EM_OAM_MONITOR_ROLE";
