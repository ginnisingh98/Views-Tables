--------------------------------------------------------
--  DDL for Package Body GMF_GL_GET_PERIOD_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_GL_GET_PERIOD_INFO" AS
/* $Header: gmfprinb.pls 115.3 2002/11/11 00:40:29 rseshadr Exp $ */
       CURSOR cur_get_period_info (calendarname  varchar2,
           periodtype    varchar2,
                 dateinperiod  date,
                 setofbooksid  number,
           appid         number,
           periodyear    number,
           periodnumber number) is
         SELECT gp.period_name,
                gps.closing_status,
                gp.period_year,
                gp.period_num,
                gp.quarter_num,
                gpt.description,
    gp.start_date,
    gp.end_date
         FROM   gl_period_statuses gps,
                gl_periods gp,
                gl_period_sets gpt
         WHERE  lower(gpt.period_set_name) like  lower(calendarname)
           AND  gp.period_set_name like  gpt.period_set_name
     AND  gp.period_type like periodtype
           AND  nvl(trunc(dateinperiod),gp.start_date) between gp.start_date
                                 and gp.end_date
           AND  gps.period_name = gp.period_name
           AND  gps.set_of_books_id = setofbooksid
           AND  gps.application_id = appid
     AND  gp.period_year = nvl(periodyear, gp.period_year)
     AND gp.period_num  = nvl(periodnumber, gp.period_num)
  ORDER BY gp.period_year, gp.period_num;

       PROCEDURE GL_GET_PERIOD_INFO (calendarname in  varchar2,
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
             period_end_date   out NOCOPY date ) IS

       appid    number;
       st_date    date;
       en_date    date;
       err_sts    number;
       row_to_fetch  number;
       setofbooksid  number;
       BEGIN

   SELECT application_id
   INTO   appid
   FROM   fnd_application
   WHERE  application_short_name = 'SQLGL';

   st_date := NULL;
   en_date := NULL;
   row_to_fetch := 1;

   gmf_gl_get_sob_id.proc_gl_get_sob_id( st_date,
          en_date,
          sobname,
          setofbooksid,
          row_to_fetch,
          err_sts);



   IF NOT cur_get_period_info%ISOPEN THEN
    OPEN cur_get_period_info( calendarname,
               periodtype,
                     dateinperiod,
            setofbooksid,
            appid,
            periodyear,
            periodnumber);
  END IF;

  FETCH cur_get_period_info
        INTO     periodname,
                 periodstatus,
                 periodyear,
                 periodnumber,
                 quarternum,
                 description ,
    period_start_date,
    period_end_date;

  if (cur_get_period_info%NOTFOUND) or rowtofetch = 1
  then
    if ( cur_get_period_info%NOTFOUND )
    then
                  statuscode := 100;
    end if;
    CLOSE cur_get_period_info;
  end if;

         EXCEPTION
           when NO_DATA_FOUND then
                statuscode := 100;
           when OTHERS then
                statuscode := SQLCODE;

         END gl_get_period_info;
END GMF_GL_GET_PERIOD_INFO;

/
