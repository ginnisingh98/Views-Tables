--------------------------------------------------------
--  DDL for Package PAY_BALANCE_FEED_DEL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BALANCE_FEED_DEL_PKG" AUTHID CURRENT_USER as
/* $Header: pyscd.pkh 120.0.12010000.2 2009/08/21 17:00:53 priupadh noship $ */
/*
 Copyright (c) Oracle Corporation 1991,1992,1993. All rights reserved
--
/*
--
 Name         : PAY_BALANCE_FEED_DEL_PKG
 Author       : $Author: priupadh $
 Synopsis     : Purging Process - Balance Feeds.
 Contents     : sub_class_del_proc
                bal_feed_main_proc

 Change List
 -----------
 Date        Name          Vers    Bug No     Description
 ==================================================================================
 05-Aug-08  salogana      115.1   6595092     Corrected the dbdrv hint.
 26-Nov-08  salogana      115.2   7556805     Added balance feed deletion
                                              functionality with the sub
                                              classification deletion.
 18-Mar-09  priupadh      115.3   7611838     Added procedures for multi threading
 07-May-09  priupadh      115.4   8493517     Added parameters to Bal_feed_main_proc
 -----------+-------------+-------+----------+-------------------------------------+
 */
PROCEDURE Bal_feed_main_proc(
        errbuf            out nocopy varchar2,
        retcode           out nocopy varchar2,
        c_element_type_id in number,
        c_pur_mode        in varchar2,
        c_dummy_param     in varchar2 default null,
        c_dummy_param_1   in varchar2 default null,
        c_bal_feed_id     in number default null,
        c_sub_class_id    in number default null,
        c_batch_size      in number default null);

PROCEDURE Trash_latest_balances_threaded(X_errbuf          out nocopy varchar2,
                                         X_retcode         out nocopy varchar2,
                                         l_balance_type_id number,
                                         l_input_value_id  number,
                                         l_trash_date      date,
                                         l_batch_size      number);

PROCEDURE Delete_Proc_PAY_MGR (
               X_errbuf         out nocopy varchar2,
               X_retcode        out nocopy varchar2,
               p_cursor          in varchar2,
               p_balance_type_id in varchar2,
               p_input_value_id  in  varchar2 default null,
               X_batch_size      in  number default 1000,
               X_Num_Workers     in  number default 5);

PROCEDURE Delete_Proc_PAY_WKR (
               X_errbuf      out nocopy varchar2,
               X_retcode     out nocopy varchar2,
               X_batch_size  in number,
               X_Worker_Id   in number,
               X_Num_Workers in number,
               X_Argument4   in varchar2 default null,
               X_Argument5   in varchar2 default null,
               X_Argument6   in varchar2 default null,
               X_Argument7   in varchar2 default null,
               X_Argument8   in varchar2 default null,
               X_Argument9   in varchar2 default null,
               X_Argument10  in varchar2 default null);

PROCEDURE Delete_assnmnt_lat_bal(
               x_errbuf             out nocopy varchar2,
               x_retcode            out nocopy varchar2,
               x_assnmnt_start_id   in number,
               x_assnmnt_end_id     in number,
               p_cursor             in varchar2,
               p_balance_type_id    in varchar2,
               p_input_value_id     in varchar2);


end PAY_BALANCE_FEED_DEL_PKG;



/
