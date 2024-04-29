--------------------------------------------------------
--  DDL for Package PER_MM_VALID_GRADES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_MM_VALID_GRADES_PKG" AUTHID CURRENT_USER as
/* $Header: pemmv04t.pkh 120.0.12010000.1 2008/07/28 05:00:47 appldev ship $ */
--
--
procedure insert_row
         (p_mass_move_id in number,
          p_position_id in number,
          p_target_grade_id in number,
          p_attribute_category in varchar2,
          p_attribute1 in varchar2,
          p_attribute2 in varchar2,
          p_attribute3 in varchar2,
          p_attribute4 in varchar2,
          p_attribute5 in varchar2,
          p_attribute6 in varchar2,
          p_attribute7 in varchar2,
          p_attribute8 in varchar2,
          p_attribute9 in varchar2,
          p_attribute10 in varchar2,
          p_attribute11 in varchar2,
          p_attribute12 in varchar2,
          p_attribute13 in varchar2,
          p_attribute14 in varchar2,
          p_attribute15 in varchar2,
          p_attribute16 in varchar2,
          p_attribute17 in varchar2,
          p_attribute18 in varchar2,
          p_attribute19 in varchar2,
          p_attribute20 in varchar2);
--
--
procedure update_row
          (p_target_grade_id in number,
          p_attribute1 in varchar2,
          p_attribute2 in varchar2,
          p_attribute3 in varchar2,
          p_attribute4 in varchar2,
          p_attribute5 in varchar2,
          p_attribute6 in varchar2,
          p_attribute7 in varchar2,
          p_attribute8 in varchar2,
          p_attribute9 in varchar2,
          p_attribute10 in varchar2,
          p_attribute11 in varchar2,
          p_attribute12 in varchar2,
          p_attribute13 in varchar2,
          p_attribute14 in varchar2,
          p_attribute15 in varchar2,
          p_attribute16 in varchar2,
          p_attribute17 in varchar2,
          p_attribute18 in varchar2,
          p_attribute19 in varchar2,
          p_attribute20 in varchar2,
          p_row_id in varchar2);
--
--
procedure delete_row
            (p_row_id in varchar2);
--
--
procedure lock_row
         (p_mass_move_id in number,
          p_position_id in number,
          p_target_grade_id in number,
          p_attribute_category in varchar2,
          p_attribute1 in varchar2,
          p_attribute2 in varchar2,
          p_attribute3 in varchar2,
          p_attribute4 in varchar2,
          p_attribute5 in varchar2,
          p_attribute6 in varchar2,
          p_attribute7 in varchar2,
          p_attribute8 in varchar2,
          p_attribute9 in varchar2,
          p_attribute10 in varchar2,
          p_attribute11 in varchar2,
          p_attribute12 in varchar2,
          p_attribute13 in varchar2,
          p_attribute14 in varchar2,
          p_attribute15 in varchar2,
          p_attribute16 in varchar2,
          p_attribute17 in varchar2,
          p_attribute18 in varchar2,
          p_attribute19 in varchar2,
          p_attribute20 in varchar2,
          p_row_id in varchar2);
--
--
procedure load_rows
                 (p_mass_move_id in number);
--
--
end per_mm_valid_grades_pkg;



/
