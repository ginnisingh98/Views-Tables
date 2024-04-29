--------------------------------------------------------
--  DDL for Package FTP_FILTER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FTP_FILTER_PKG" AUTHID CURRENT_USER as
/* $Header: ftpfilts.pls 120.3.12000000.2 2007/08/08 07:40:58 shishank ship $ */

   function get_eng_where_clause_new(
      err_code out nocopy number,      -- 0 == no error
      err_msg out nocopy varchar2,         -- err_msg if err_code <> 0
      data_set_id in number,             -- data set id
      period_id in number,               -- cal_period_id
      table_alias in varchar2,           -- alias to use with table
      table_name in varchar2,            -- actual table name
      ledger_id in number default NULL,  -- ledger_id
      filter_id in number default NULL,  -- filter_object_id
      eff_date in date default NULL,     -- effective_date
      working_copy_flg in char default 'N' -- working copy flag
   ) return long;

end FTP_FILTER_PKG;

 

/
