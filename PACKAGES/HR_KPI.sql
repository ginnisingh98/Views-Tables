--------------------------------------------------------
--  DDL for Package HR_KPI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_KPI" AUTHID CURRENT_USER as
/* $Header: hrkpi02.pkh 120.0.12010000.1 2008/07/28 03:28:01 appldev ship $ */


  --
  -- Although the implementation of request is java we still call
  -- through a PL/SQL wrapper rather than via call spec directly
  -- to allow more flexibility (eg. autonmous tx), better error
  -- handling. The trade off is performance which is less critical
  -- for this prototype code
  --
  function  request (context in varchar2, cookie in out nocopy varchar2,sid in varchar2)
  return varchar2 ;

  procedure parseResponse (response  in     varchar2,
			               l_type      in out nocopy varchar2,
                           l_sub       in out nocopy varchar2,
                           l_value     in out nocopy varchar2,
                           l_error     in out nocopy varchar2
                           ) ;

  procedure save_user_preference ( p_name  in varchar2,
                                   p_value in varchar2 ) ;
  --procedure dbg(p_msg in varchar2);

  procedure debug_end(package_name in varchar2,method_name in varchar2);
  procedure debug_event(package_name in varchar2,method_name in varchar2,message_text in varchar2);
  procedure debug_exception(routine in varchar2,
                        errcode in number,
                        errmsg in varchar2);
  procedure debug_start(package_name in varchar2,method_name in varchar2);
  procedure debug_text(package_name in varchar2,method_name in varchar2,message_text in varchar2);
end hr_kpi;

/
