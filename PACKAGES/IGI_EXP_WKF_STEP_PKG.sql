--------------------------------------------------------
--  DDL for Package IGI_EXP_WKF_STEP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_EXP_WKF_STEP_PKG" AUTHID CURRENT_USER AS
-- $Header: igiexpbs.pls 115.9 2003/08/09 13:10:08 rgopalan ship $
 /* This package is for the table IGI_EXP_WKF_STEP for insert,update,delete and locking of records .*/
  procedure insert_row
  (x_rowid       in out NOCOPY varchar2,
   x_wkf_id      number,
   x_flow_id     number,
   x_step_no     number,
   x_position_structure_id number,
   x_last_update_date date,
   x_last_updated_by number,
   x_last_update_login number,
   x_created_by    number,
   x_creation_date date
   );
  procedure lock_row
   (x_rowid      varchar2,
   x_wkf_id      number,
   x_flow_id     number,
   x_step_no     number,
   x_position_structure_id number,
   x_last_update_date date,
   x_last_updated_by number,
   x_last_update_login number,
   x_created_by    number,
   x_creation_date date
   );
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
   );
  procedure delete_row(x_rowid varchar2);

end IGI_EXP_WKF_STEP_PKG;

 

/
