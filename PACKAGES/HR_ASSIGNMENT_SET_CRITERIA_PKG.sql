--------------------------------------------------------
--  DDL for Package HR_ASSIGNMENT_SET_CRITERIA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ASSIGNMENT_SET_CRITERIA_PKG" AUTHID CURRENT_USER as
/* $Header: pyasc01t.pkh 115.0 99/07/17 05:42:50 porting ship $ */
--
  procedure insert_row(p_rowid             in out varchar2,
                       p_line_no               in number,
                       p_assignment_set_id     in number,
                       p_left_operand          in varchar2,
                       p_operator              in varchar2,
                       p_right_operand         in varchar2,
                       p_logical               in varchar2);
  --
  procedure update_row(p_rowid                 in varchar2,
                       p_line_no               in number,
                       p_assignment_set_id     in number,
                       p_left_operand          in varchar2,
                       p_operator              in varchar2,
                       p_right_operand         in varchar2,
                       p_logical               in varchar2);
  --
  procedure delete_row(p_rowid   in varchar2);
  --
  procedure lock_row(p_rowid                   in varchar2,
                       p_line_no               in number,
                       p_assignment_set_id     in number,
                       p_left_operand          in varchar2,
                       p_operator              in varchar2,
                       p_right_operand         in varchar2,
                       p_logical               in varchar2);

  --
end HR_ASSIGNMENT_SET_CRITERIA_PKG;

 

/
