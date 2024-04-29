--------------------------------------------------------
--  DDL for Package HR_SPEC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SPEC_PKG" AUTHID CURRENT_USER as
/* $Header: hrspec.pkh 115.1 99/07/17 05:37:08 porting ship $ */
------------------------------------------------------------------------------
/*
+==============================================================================+
|                       Copyright (c) 1994 Oracle Corporation                  |
|                          Redwood Shores, California, USA                     |
|                               All rights reserved.                           |
+==============================================================================+
Name
	HR Libraries server-side agent
Purpose
	Agent handles all server-side traffic to and from forms libraries. This
	is particularly necessary because we wish to avoid the situation where
	a form and its libraries both refer to the same server-side package.
	Forms/libraries appears to be unable to cope with this situation in
	circumstances which we cannot yet define.
History
	21 Apr 95	N Simpson	Created
	17 May 95	N Simpson	Added delete_ownerships,
					insert_ownerships and
					startup_insert_allowed to
					remove all sql from client side and
					thus allow library to be made global
        06 Sep 95       S Desai         Added test_path_to_perbecvd
					      test_path_to_perbeben
        08 Sep 95	D Kerr		Changed datatype of parameter
					chk_asg_on_payroll from %TYPE to
					number. Workaround for forms bug.
        11 Mar 96	D Kerr          Added checkformat and changeformat.
	19 Aug 97	Sxshah	Banner now on eack line.
	21 Aug 97       V Treiger       Added procedures per_date_range and
	                                asg_date_range
        21 May 98       D Kerr          Added overload version of
                                        chk_asg_on_payroll
*/
procedure test_path_to_perwsspp (p_ass_id    NUMBER);
--
procedure chk_asg_on_payroll
  (p_assignment_id  in NUMBER);

-- This routine is required for bug 620733.
procedure chk_asg_on_payroll
  (p_assignment_id  in NUMBER,
   p_effective_date in DATE);
--
procedure test_path_to_perbecvd ( p_element_entry_id NUMBER );
--
procedure test_path_to_perbeben ( p_element_entry_id NUMBER );
--
procedure delete_ownerships (p_key_name	varchar2, p_key_value number);
procedure insert_ownerships (p_session_id number, p_key_name varchar2, p_key_value number);
function startup_insert_allowed (p_session_id number) return boolean;
--
-- From hr_chkfmt
--
   procedure checkformat
   ( value   in out varchar2,
     format  in     varchar2,
     output  in out varchar2,
     minimum in     varchar2,
     maximum in     varchar2,
     nullok  in     varchar2,
     rgeflg  in out varchar2,
     curcode in     varchar2
    ) ;
--
   procedure changeformat
   ( input   in     varchar2,
     output  out    varchar2,
     format  in     varchar2,
     curcode in     varchar2
   ) ;
--
   procedure per_date_range
   ( p_person_id  in      number,
     p_date_from  in out  date,
     p_date_to    in out  date
   ) ;
--
   procedure asg_date_range
   ( p_assignment_id  in      number,
     p_date_from      in out  date,
     p_date_to        in out  date
   ) ;
--
end	hr_spec_pkg;

 

/
