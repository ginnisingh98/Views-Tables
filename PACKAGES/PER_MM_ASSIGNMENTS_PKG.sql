--------------------------------------------------------
--  DDL for Package PER_MM_ASSIGNMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_MM_ASSIGNMENTS_PKG" AUTHID CURRENT_USER as
/* $Header: pemmv03t.pkh 115.2 2003/05/12 16:29:52 mgettins ship $ */
--
--
procedure update_row
           (p_default_from in varchar2,
            p_select_assignment in varchar2,
            p_grade_id in number,
            p_tax_unit_id in number,
            p_row_id in varchar2);
--
--
procedure load_rows
                  (p_mass_move_id in number,
                   p_session_date in date);
--
--
procedure lock_row
           (p_mass_move_id in number,
            p_assignment_id in number,
            p_position_id in number,
            p_default_from in varchar2,
            p_select_assignment in varchar2,
            p_grade_id in number,
            p_tax_unit_id in number,
            p_row_id in varchar2);
--
--
procedure restore_defaults
          (p_mass_move_id in number,
           p_assignment_id in number,
           p_grade_id out nocopy number,
           p_grade_name out nocopy varchar2,
           p_tax_unit_id out nocopy number,
           p_tax_unit_name out nocopy varchar2);
--
--
end per_mm_assignments_pkg;

 

/
