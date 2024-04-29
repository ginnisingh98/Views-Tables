--------------------------------------------------------
--  DDL for Package GMF_GL_GET_PERIOD_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_GL_GET_PERIOD_INFO" AUTHID CURRENT_USER as
/* $Header: gmfprins.pls 115.2 2002/11/11 00:40:39 rseshadr ship $ */
       procedure GL_GET_PERIOD_INFO (calendarname in  varchar2,
                                     periodtype   in  varchar2,
                                     dateinperiod in  date,
                                     sobname      in out NOCOPY varchar2,
                                     appabbr      in  varchar2,
                                     periodname   out NOCOPY varchar2,
                                     periodstatus out NOCOPY varchar2,
                                     periodyear   in out NOCOPY number,
                                     periodnumber in out NOCOPY number,
                                     quarternum   out NOCOPY number,
                                     description  out NOCOPY varchar2,
                                     statuscode   out NOCOPY number,
             rowtofetch in out NOCOPY number,
             period_start_date out NOCOPY date,
             period_end_date   out NOCOPY date);
END GMF_GL_GET_PERIOD_INFO;

 

/
