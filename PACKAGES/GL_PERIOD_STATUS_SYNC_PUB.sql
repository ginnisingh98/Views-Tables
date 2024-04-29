--------------------------------------------------------
--  DDL for Package GL_PERIOD_STATUS_SYNC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_PERIOD_STATUS_SYNC_PUB" AUTHID CURRENT_USER AS
/* $Header: glpssyss.pls 120.2.12010000.1 2009/12/16 11:57:14 sommukhe noship $ */
/*================================================================================|
| FILENAME                                                                   	  |
|    glpssyss.pls                                                           	  |
|                                                                            	  |
| PACKAGE NAME                                                               	  |
|    GL_PERIOD_STATUS_SYNC_PUB                                                    |
|                                                                            	  |
| DESCRIPTION                                                                	  |
|     This is a GL Period Synchronization which is used to Open a GL period for   |
|     Primary and its Secondary and Reporting Ledgers with in a gieven date range.|
|     Also this Program used to close the period which is beyond the date range	  |
|     if the periods already opened.						  |
|     										  |
|     In case of any error in any stage of the program will stop the process. And |
|     error will be notified to AIA through business event.			  |
|     										  |
|     Existing concurrent Program used to change the Period statuses.		  |
|										  |
|     This is a package Body        						  |
|									     	  |
| 										  |
| SUB PROGRAMS									  |
| ------------									  |
| PROCEDURE period_status_sync							  |
| 										  |
| PARAMETER DESCRIPTION							     	  |
| ---------------------								  |
| p_ledger_short_name	IN 	short_name from gl_ledgers table. 		  |
| p_start_date          IN   	start_date of the period from gl_period_statuses  |
| p_end_date		IN 	end_date of the period from gl_period_statuses	  |
| errbuf	       OUT      Default out parameter to capture error message    |
| retcode   	       OUT      Default out parameter to capture error code       |
|										  |
| HISTORY                                                                    	  |
| -------   									  |
| 25-JUN-08  KARTHIK M P  Created 			             	          |
+=================================================================================*/



PROCEDURE period_status_sync
( errbuf 	     	OUT NOCOPY VARCHAR2,
  retcode		OUT NOCOPY VARCHAR2,
  x_return_status	OUT NOCOPY VARCHAR2,
  p_ledger_Short_name   IN VARCHAR2,
  p_start_date   	IN DATE,
  p_end_date	 	IN DATE
);

END gl_period_status_sync_pub;

/
