--------------------------------------------------------
--  DDL for Package PY_GB_ASG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PY_GB_ASG" AUTHID CURRENT_USER as
/* $Header: pygbasg.pkh 120.1 2005/06/30 06:42:36 tukumar noship $ */

PROCEDURE payroll_transfer (	p_assignment_id  IN NUMBER);
--
PROCEDURE delete_per_latest_balances
                    (p_person_id      number,
                     p_assignment_id  number,
                     p_effective_date date);
end py_gb_asg;

 

/
