--------------------------------------------------------
--  DDL for Package HXC_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_DRT_PKG" AUTHID CURRENT_USER AS
/* $Header: hxcdrt.pkh 120.0.12010000.7 2018/05/09 11:14:36 rpakalap noship $ */
  TYPE numtab IS TABLE OF number;

  TYPE varchartab IS TABLE OF varchar2(25);

  TYPE datetab IS TABLE OF date;

  table_not_found EXCEPTION;

  PRAGMA EXCEPTION_INIT(table_not_found, -942);

  PROCEDURE timecards_drc
    (p_person_id IN number
    ,p_result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type);
  PROCEDURE remove_timecards
    (p_person_id IN number);

  PROCEDURE delete_act_tc
    (p_resource_id IN number
    ,p_start_time  IN date
    ,p_stop_time   IN date
    ,p_timecard_id IN number);

  PROCEDURE delete_arc_tc
    (p_resource_id IN number
    ,p_start_time  IN date
    ,p_stop_time   IN date
    ,p_timecard_id IN number);


  PROCEDURE delete_otlr_tc
    (p_resource_id IN number);

  PROCEDURE hxc_hr_drc
    (p_person_id  IN         number
    ,p_result_tbl OUT NOCOPY per_drt_pkg.result_tbl_type);

  PROCEDURE hxc_hr_post
    (p_person_id  IN         number);
END hxc_drt_pkg;

/
