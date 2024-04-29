--------------------------------------------------------
--  DDL for Package XDP_CRON_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_CRON_UTIL" AUTHID CURRENT_USER AS
/* $Header: XDPCRONS.pls 120.1 2005/06/15 22:43:02 appldev  $ */


  pv_jobAdapterAdmin varchar2(4000) := 'XDP_CRON_UTIL.EXECUTE_ADAPTER_ADMIN';

  Procedure SubmitAdapterAdminJob(p_request in number,
                                  p_RunDate in date,
				  p_RunFreq in number default null,
                                  p_JobNumber OUT NOCOPY number);

  Procedure UpdateDBJob(p_jobID in number,
			p_request in number,
			p_ReqDate in date,
			p_Freq in number);

  Procedure Execute_Adapter_Admin(p_request in number);

/********* Commented out - START - sacsharm - Old code *************

  Procedure ExecuteCMUCronJobs;

  Procedure ExecuteCMUActivity(p_RequestID in number,
                               p_RequestCode in varchar2);

  Procedure SubmitCMUJob(p_interval in number,
                         p_JobNumber OUT NOCOPY number);

  Procedure StartupWatchdogProcess;

  Procedure SubmitWatchdogJob(p_interval in number,
                                     p_JobNumber OUT NOCOPY number);

  Procedure SubmitDQerWatchdogJob(p_interval in number,
                                  p_JobNumber OUT NOCOPY number);

  Procedure SubmitEventMgrJob (p_interval in number,
                                  p_JobNumber OUT NOCOPY number);
  Procedure ExecuteEventMgrJobs;

********** Commented out - END - sacsharm - Old code ************/

end XDP_CRON_UTIL;

 

/
