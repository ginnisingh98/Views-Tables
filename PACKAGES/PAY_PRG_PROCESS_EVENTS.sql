--------------------------------------------------------
--  DDL for Package PAY_PRG_PROCESS_EVENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_PRG_PROCESS_EVENTS" AUTHID CURRENT_USER AS
/* $Header: pyprgevt.pkh 120.0.12010000.2 2009/08/03 11:27:07 pparate noship $ */
-------------------------------------------------------------------------------------
--  Name       : Purge_process_events _PAY_MGR
--  Function   : This is the Manager Process called by Conc Program
--               Purge Process Events
-------------------------------------------------------------------------------------
PROCEDURE Purge_process_events_PAY_MGR (
               X_errbuf         out NOCOPY varchar2,
               X_retcode        out NOCOPY varchar2,
               p_purge_date     in  varchar2,
               X_batch_size     in  number default 1000,
               X_Num_Workers    in  number default 5);
----------------------------------------------------------------------------------------
--  Name       :#Purge_process_events_PAY_WKR
--  Function   : Worker process to Purge Process Events.
--               This is called by #Purge_process_events_PAY_MGR
----------------------------------------------------------------------------------------
PROCEDURE Purge_process_events_PAY_WKR (
               X_errbuf     out NOCOPY varchar2,
               X_retcode    out NOCOPY varchar2,
               X_batch_size  in number,
               X_Worker_Id   in number,
               X_Num_Workers in number,
               X_Argument4   in varchar2 default null,
               X_Argument5   in varchar2 default null,
               X_Argument6   in varchar2 default null,
               X_Argument7   in varchar2 default null,
               X_Argument8   in varchar2 default null,
               X_Argument9   in varchar2 default null,
               X_Argument10  in varchar2 default  null);
-------------------------------------------------------------------------------------
--  Name       : Purge_process_events
--  Type       : Private
--  Function   : To purge data from pay_process_events table and archive it
--               deleted data into pay_process_events_shadow table.
--  Pre-reqs   :
--  Parameters :
--  IN         : p_purge_date
--               p_debug_flag
--               x_start_id
--               x_end_id
--
--  OUT        : X_errbuf  out NOCOPY varchar2,
--               X_retcode out NOCOPY varchar2
--
--  Notes      : The Procedure is called from Purge_process_events_PAY_WKR
--
-- End of comments
-------------------------------------------------------------------------------------
PROCEDURE Purge_process_events (
               x_errbuf     out nocopy varchar2,
               x_retcode    out nocopy varchar2,
               x_start_id   in number,
               x_end_id     in number,
               p_purge_date in varchar2,
               p_debug_flag in varchar2 );
END PAY_PRG_PROCESS_EVENTS ;

/
