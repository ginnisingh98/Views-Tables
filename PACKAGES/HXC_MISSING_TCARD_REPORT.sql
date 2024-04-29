--------------------------------------------------------
--  DDL for Package HXC_MISSING_TCARD_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_MISSING_TCARD_REPORT" AUTHID CURRENT_USER as
/* $Header: hxcmistc.pkh 115.2 2003/11/02 22:25:28 namrute ship $ */

Function check_assignment_set
  (p_assignment_set_id          in number,
   p_assignment_id              in number)
 Return varchar2;

Function get_vendor_name
  (p_start_date                in date,
   p_end_date                  in date,
   p_resource_id                in number
   )
 Return varchar2;

Function check_vendor_exists
  (p_start_date                in date,
   p_end_date                  in date,
   p_assignment_id             in NUMBER,
   p_resource_id               in number,
   p_vendor_id		       in number
   )
 Return varchar2;

end hxc_missing_tcard_report;

 

/
