--------------------------------------------------------
--  DDL for Package PA_SCHEDULE_GLOB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_SCHEDULE_GLOB" AUTHID CURRENT_USER as
/* $Header: PARGGLBS.pls 120.1 2005/12/08 00:26:01 appldev ship $ */

TYPE ScheduleRecord  IS RECORD (   schrowid                rowid,
                                   schedule_id             number,
                                   calendar_id             number,
                                   assignment_id            number,
                                   project_id              number,
                                   schedule_type_code      varchar2(30),
                                   assignment_status_code  varchar2(30),
                                   system_status_code      varchar2(30),
                                   start_date              DATE,
                                   end_date                DATE,
                                   monday_hours            number,
                                   tuesday_hours           number,
                                   wednesday_hours         number,
                                   thursday_hours          number,
                                   friday_hours            number,
                                   saturday_hours          number,
                                   sunday_hours            number,
                                   change_type_code        VARCHAR2(30)  );

TYPE ScheduleTabTyp IS TABLE OF ScheduleRecord INDEX BY BINARY_INTEGER;


TYPE SchExceptRecord  IS RECORD (  exceptRowid                rowid,
                                   schedule_exception_id      number,
                                   calendar_id                number,
                                   assignment_id              number,
                                   project_id                 number,
                                   schedule_type_code         varchar2(30),
                                   assignment_status_code     varchar2(30),
                                   exception_type_code        varchar2(30),
                                   duration_shift_type_code   varchar2(30),
                                   duration_shift_unit_code   varchar2(30),
                                   number_of_shift            number,
                                   start_date                 DATE,
                                   end_date                   DATE,
                                   resource_calendar_percent  number,
                                   non_working_day_flag       varchar2(1),
                                   change_hours_type_code     varchar2(30),
                                   change_calendar_type_code  varchar2(30),
                                   change_calendar_id         number,
                                   monday_hours               number,
                                   tuesday_hours              number,
                                   wednesday_hours            number,
                                   thursday_hours             number,
                                   friday_hours               number,
                                   saturday_hours             number,
                                   sunday_hours               number );

TYPE SchExceptTabTyp IS TABLE OF SchExceptRecord INDEX BY BINARY_INTEGER;


TYPE calendar_record  IS RECORD (  seq_num                 number,
                                   duration                number,
                                   monday_hours            number,
                                   tuesday_hours           number,
                                   wednesday_hours         number,
                                   thursday_hours          number,
                                   friday_hours            number,
                                   saturday_hours          number,
                                   sunday_hours            number);

TYPE calendarTabTyp IS TABLE OF calendar_record INDEX BY BINARY_INTEGER;



TYPE cal_exception_record  IS RECORD (  exception_id          number,
                                        except_start_date     DATE,
																																								except_end_date       DATE,
                                        exception_category    varchar2(30));


TYPE CalExceptionTabTyp IS TABLE OF cal_exception_record INDEX BY BINARY_INTEGER;


END PA_SCHEDULE_GLOB;

 

/
