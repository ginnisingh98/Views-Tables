--------------------------------------------------------
--  DDL for Package Body IGI_EXP_WKF_STEP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_EXP_WKF_STEP_PKG" as
--$Header: igiexpbb.pls 115.7 2003/08/09 11:36:00 rgopalan ship $
 procedure insert_row
 ( x_rowid       in out NOCOPY varchar2,
   x_wkf_id      number,
   x_flow_id     number,
   x_step_no     number,
   x_position_structure_id number,
   x_last_update_date date,
   x_last_updated_by number,
   x_last_update_login number,
   x_created_by    number,
   x_creation_date date
   ) is
BEGIN
 NULL;
END insert_row;

 procedure lock_row
  (x_rowid       varchar2,
   x_wkf_id      number ,
   x_flow_id     number,
   x_step_no     number,
   x_position_structure_id number,
   x_last_update_date date,
   x_last_updated_by number,
   x_last_update_login number,
   x_created_by    number,
   x_creation_date date
   )
 is
BEGIN
 NULL;
END lock_row;

 procedure update_row
  (x_rowid       varchar2,
   x_wkf_id      number,
   x_flow_id     number,
   x_step_no     number,
   x_position_structure_id number,
   x_last_update_date date,
   x_last_updated_by number,
   x_last_update_login number,
   x_created_by    number,
   x_creation_date date
   ) is
BEGIN
 NULL;
END update_row;

 procedure delete_row(x_rowid varchar2) is
BEGIN
 NULL;
END delete_row;



 end IGI_EXP_WKF_STEP_PKG;

/
