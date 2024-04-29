--------------------------------------------------------
--  DDL for Package GMS_STREAMLINE_PROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_STREAMLINE_PROC" AUTHID CURRENT_USER as
/* $Header: gmsstrms.pls 120.1 2006/04/20 06:19:02 tsomani noship $ */

-- Procedure to kick off all the Interface streamline processes.


 -- The data type of the variable through_date has been changed to varchar2 from date for bug 2644176.
   procedure  GMSISLPR(errbuf                   out NOCOPY varchar2,
                       retcode          	out NOCOPY varchar2,
                       process_stream   	in varchar2,
                       project_id       	in number     DEFAULT NULL,
                       through_date     	in  varchar2  DEFAULT NULL,
                       reschedule_interval 	in number     DEFAULT NULL,
                       reschedule_time  	in date       DEFAULT NULL,
                       stop_date        	in date       DEFAULT NULL,
                       adjust_dates     	in varchar2   DEFAULT 'N',
                       debug_mode       	in varchar2   DEFAULT 'N'
                       );

end GMS_STREAMLINE_PROC;

 

/
