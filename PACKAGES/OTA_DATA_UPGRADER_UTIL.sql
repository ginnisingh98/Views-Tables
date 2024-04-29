--------------------------------------------------------
--  DDL for Package OTA_DATA_UPGRADER_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_DATA_UPGRADER_UTIL" AUTHID CURRENT_USER AS
/* $Header: otdatupg.pkh 120.1 2005/08/01 00:56:56 jbharath noship $ */

-- ----------------------------------------------------------------------------
-- |----------------------------< upgrade_chunk >-----------------------------|
-- ----------------------------------------------------------------------------
--
--
-- Description:
--   This procedure migrates data using the AD large table update utilities
--   it process data for a single thread in a multi-threaded upgrade job.
--
--   It is a generic routine which accepts a named procedure to call. This
--   procedure accepts a standard set of parameters and actually performs the
--   data upgrade. It passes out the number of rows processed.
--
-- Prerequisites
--
-- Parameters:
--   Name                           Reqd Type     Description
--   p_this_worker_num                Y  Number   The number of this worker
--                                                thread.
--   p_total_num_workers              Y  Number   The total number of workers
--                                                performing this upgrade.
--   p_process_ctrl                   Y  Varchar2 String encoding special control
--                                                actions on a per process basis.
--   p_table_owner                    Y  Varchar2 The name of the schema owning
--                                                the table to be upgraded.
--   p_table_name                     Y  Varchar2 The name of the table to be
--                                                upgraded.
--   p_pkid_column                    Y  Varchar2 The name of the PK id column
--   p_update_name                    Y  Varchar2 The name of the update process.
--   p_batch_size                     Y  Number   The batch commit size.
--   p_upg_proc                       Y  Varchar2 The procedure to call which
--                                                actually performs the data
--                                                upgrade.
procedure upgradeChunk
   (p_this_worker_num   number
   ,p_total_num_workers number
   ,p_process_ctrl      varchar2
   ,p_table_owner       varchar2
   ,p_table_name        varchar2
   ,p_pkid_column       varchar2
   ,p_update_name       varchar2
   ,p_batch_size        number
   ,p_upg_proc          varchar2
   ,p_upgrade_id    varchar2
   ,p_use_rowid     varchar2);

procedure submitUpgradeProcessControl(
                      errbuf    out nocopy varchar2,
                      retcode   out nocopy number,
		      p_process_to_call in varchar2,
		      p_upgrade_type    in varchar2,
		      p_action_parameter_group_id in varchar2,
		      p_process_ctrl    in varchar2,
		      p_param1          in varchar2,
		      p_param2          in varchar2,
		      p_param3          in varchar2,
		      p_param4          in varchar2,
		      p_param5          in varchar2,
		      p_param6          in varchar2,
		      p_param7          in varchar2,
		      p_param8          in varchar2,
		      p_param9          in varchar2,
		      p_param10         in varchar2
		      );

procedure submitUpgradeProcessSingle(
                      errbuf    out nocopy varchar2,
                      retcode   out nocopy number,
		      p_process_number  in varchar2,
		      p_max_number_proc in varchar2,
		      p_process_to_call in varchar2,
		      p_upgrade_type    in varchar2,
		      p_process_ctrl    in varchar2,
		      p_param1          in varchar2,
		      p_param2          in varchar2,
		      p_param3          in varchar2,
		      p_param4          in varchar2,
		      p_param5          in varchar2,
		      p_param6          in varchar2,
		      p_param7          in varchar2,
		      p_param8          in varchar2,
		      p_param9          in varchar2,
		      p_param10         in varchar2
		      );

Function getLoggingState return varchar2;

Procedure writeLog(p_text         in VARCHAR2
                  ,p_logging_type in VARCHAR2 default null
		  ,p_error        in BOOLEAN  default FALSE
		  ,p_location     in NUMBER   default 0) ;

end ota_data_upgrader_util;

 

/
