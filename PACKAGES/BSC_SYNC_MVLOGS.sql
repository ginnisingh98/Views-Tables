--------------------------------------------------------
--  DDL for Package BSC_SYNC_MVLOGS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_SYNC_MVLOGS" AUTHID CURRENT_USER AS
/*$Header: BSCMVLGS.pls 120.1 2005/11/18 16:17 arsantha noship $*/

function sync_dim_table_mv_log(
  p_dim_table_name in varchar2,
  p_error_message out nocopy varchar2
) return boolean;

function drop_dim_table_mv_log(
  p_dim_table_name in varchar2,
  p_error_message out nocopy varchar2
) return boolean;

END BSC_SYNC_MVLOGS;

 

/
