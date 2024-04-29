--------------------------------------------------------
--  DDL for Package XDP_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_PURGE" AUTHID CURRENT_USER AS
/* $Header: XDPPRGS.pls 120.1 2005/06/16 02:26:11 appldev  $ */

-- minimum number of days that SFM data will be retains.
-- this number will be used if users specifiy any illegal values
-- for number of days of data retaining in the database.

g_min_number_of_days NUMBER := 1;


-- Procedure PURGE
--	Purge obsolete data from SFM
--
-- IN:
--   p_number_of_days
--                 	- number of days of data will be retained in SFM.
--   		   	- if not specified, g_min_number_of_days will be
--                 	- used if specified as null, or negative or less
--                 	- than g_min_number_of_days.
--   p_run_mode	   	- specify run mode when this API is called.--
--		   	- 	'PURGE', to purge data
--		   	-	'VERIFY', to verify setting and print out data will be purged
--   p_purge_data_set
--            	 	- indicate what data to be purged,
--                 	- eg. '[ORDER, SOA, MSGS, MISC]' will purge order, soa
--                 	- , messages and debug/error data
--                 	-    '[ORDER]' will only purge order data
--                 	- Default is null, means will not purge at all
--
--   p_purge_msg_flag
--                 	- indicate if messages whose orders still exist
--                 	- in the database should be purged or not
--
--   p_purge_order_flag
--            	 	- indicate if the external messages related to orders
--                 	- will be purged
--
--   p_max_exceptions	- number of continuous exceptions allowed before terminating a purge
--
--   p_log_mode		- indicate if how you would like to log messages for
--			- purging operation. Available option TERSE and VERBOSE
--			-- any other words will result no message logged
--
--   p_rollback_segment	- indicate what rollback segment should be used. If null, default
--			- rollback segment will be used
-- OUT:
--   ERRBUF	     - as required by concurrent manager
--   RETCODE	     - as required by concurrent manager
--
--
-- Note: when run by a concurrent manager, exceptions will be silenced
-- with proper messages returned in ERRBUF. RETCODE is 2 for
-- exception errors
--

PROCEDURE PURGE
(
     ERRBUF	            	OUT NOCOPY	VARCHAR2,
     RETCODE	        		OUT NOCOPY	VARCHAR2,
     p_number_of_days		IN	NUMBER   DEFAULT g_min_number_of_days,
     p_run_mode			IN	VARCHAR2 DEFAULT 'VERIFY',
     p_purge_data_set		IN 	VARCHAR2 DEFAULT '[ORDER,SOA,MSGS,MISC]',
     p_purge_msg_flag		IN 	VARCHAR2 DEFAULT 'TRUE',
     p_purge_order_flag		IN 	VARCHAR2 DEFAULT 'TRUE',
     p_max_exceptions		IN 	NUMBER   DEFAULT 10,
     p_log_mode			IN 	VARCHAR2 DEFAULT 'TERSE',
     p_rollback_segment		IN 	VARCHAR2 DEFAULT NULL
);

END XDP_PURGE;

 

/
