--------------------------------------------------------
--  DDL for Package INV_ENHANCED_TM_PERF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_ENHANCED_TM_PERF" AUTHID CURRENT_USER as
/*  $Header: INVENTMS.pls 120.0.12010000.2 2010/04/15 22:42:53 musinha noship $*/

  procedure print_debug(msg varchar2);

  procedure launch_worker( p_maxrows      in number
                          ,p_applid       in number
                          ,p_progid       in number
                          ,p_userid       in number
                          ,p_reqstid      in number
                          ,p_loginid      in number
                          ,x_ret_status   out nocopy number
                          ,x_ret_message  out nocopy varchar2);

  function get_seq_nextval
  RETURN number;

END INV_ENHANCED_TM_PERF ;

/
