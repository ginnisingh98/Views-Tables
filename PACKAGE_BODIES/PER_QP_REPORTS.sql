--------------------------------------------------------
--  DDL for Package Body PER_QP_REPORTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_QP_REPORTS" as
/* $Header: ffqpr01t.pkb 115.0 99/07/16 02:03:19 porting ship $ */
/*===========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                       |
 |                  Redwood Shores, California, USA                          |
 |                       All rights reserved.                                |
 +===========================================================================+

Description
-----------
Package Header for procedures supporting FFXWSBQR - Define QP Report

History
-------
Date      Version  Description
----      -------  -----------
13-Apr-94 4.0      Created Initial Version
----------------------------------------------------------------------------*/
--
function get_formula_type return NUMBER is
l_formula_type_id number;
cursor c is
select formula_type_id
from   ff_formula_types
where   upper(formula_type_name) = 'QUICKPAINT';
--
begin
hr_utility.set_location('per_qp_reports.get_formula_type',1);
  open c;
  fetch c into l_formula_type_id;
  if c%notfound then
     close c;
     hr_utility.set_message(801,'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE','GET_FORMULA_TYPE');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
  end if;
  close c;
  return(l_formula_type_id);
end get_formula_type;
--
function get_sequence_id return NUMBER is
l_sequence number;
cursor c is
select ff_qp_reports_s.nextval
from   sys.dual;
--
begin
hr_utility.set_location('per_qp_reports.get_sequence_id',1);
  open c;
  fetch c into l_sequence;
  close c;
  return(l_sequence);
end get_sequence_id;
--
procedure check_unique_name(p_qp_report_name varchar2
                           ,p_formula_type_id number
                           ,p_business_group_id number
                           ,p_legislation_code varchar2) is
l_exists varchar2(1);
cursor c is
 select  'x'
 from    ff_qp_reports
 where   formula_type_id       = p_formula_type_id
 and     upper(qp_report_name) = upper(p_qp_report_name)
 and     nvl(business_group_id, nvl(p_business_group_id, 0)) =
                nvl(p_business_group_id, 0)
 and     nvl(legislation_code, nvl(p_legislation_code, ' ')) =
                nvl(p_legislation_code, ' ');
begin
hr_utility.set_location('per_qp_reports.check_unique_name',1);
  open c;
  fetch c into l_exists;
  if c%found then
     close c;
     hr_utility.set_message(801,'FF00151_QP_REP_NAME_EXISTS');
     hr_utility.raise_error;
  end if;
  close c;
end check_unique_name;
--
END PER_QP_REPORTS;

/
