--------------------------------------------------------
--  DDL for Package HR_ASSIGNMENT_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ASSIGNMENT_SETS_PKG" AUTHID CURRENT_USER as
/* $Header: pyass01t.pkh 115.0 99/07/17 05:43:24 porting ship $ */
--
  procedure insert_row(p_rowid             in out varchar2,
                       p_assignment_set_id     in number,
                       p_business_group_id     in number,
                       p_payroll_id            in number,
                       p_assignment_set_name   in varchar2,
                       p_formula_id            in number);

  --
  procedure update_row(p_rowid                 in varchar2,
                       p_assignment_set_id     in number,
                       p_business_group_id     in number,
                       p_payroll_id            in number,
                       p_assignment_set_name   in varchar2,
                       p_formula_id            in number);
  --
  procedure delete_row(p_rowid   in varchar2);
  --
  procedure lock_row(p_rowid                   in varchar2,
                       p_assignment_set_id     in number,
                       p_business_group_id     in number,
                       p_payroll_id            in number,
                       p_assignment_set_name   in varchar2,
                       p_formula_id            in number);

  --
end HR_ASSIGNMENT_SETS_PKG;

 

/
