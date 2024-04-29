--------------------------------------------------------
--  DDL for Package PER_NL_ABSENCE_TRACK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_NL_ABSENCE_TRACK_PKG" AUTHID CURRENT_USER AS
/* $Header: penlabst.pkh 120.0.12000000.1 2007/01/22 00:21:34 appldev ship $ */
--
-- Creates Default Absence Actions for a Employee if no actions
-- are entered for a employee
PROCEDURE create_Default_Absence_Actions
	(p_absence_attendance_id number,
	 p_effective_date date,
	 p_return_status  in out nocopy varchar2 );
PROCEDURE chk_Abs_Action_Setup_Exists
         (p_absence_attendance_id IN number ,
          p_business_group_id     OUT nocopy NUMBER,
          p_user_table_name       OUT nocopy VARCHAR2,
          p_start_date            OUT nocopy DATE,
          p_setup_exists          OUT nocopy varchar2);
END PER_NL_ABSENCE_TRACK_PKG;

 

/
