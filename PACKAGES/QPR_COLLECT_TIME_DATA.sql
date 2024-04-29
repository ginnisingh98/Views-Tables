--------------------------------------------------------
--  DDL for Package QPR_COLLECT_TIME_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QPR_COLLECT_TIME_DATA" AUTHID CURRENT_USER AS
/* $Header: QPRUCTMS.pls 120.0 2007/10/11 13:08:38 agbennet noship $ */
--  Calendar type constants --
  GREGORIAN_CALENDAR number := 1 ;
  FISCAL_CALENDAR number :=  2;

  procedure collect_time_data(errbuf out nocopy varchar2,
                              retcode out nocopy number,
                              p_instance_id in number,
                              p_calendar_type in number,
                              p_calendar_code in varchar2,
                              p_date_from in varchar2,
                              p_date_to in varchar2);
END;




/
