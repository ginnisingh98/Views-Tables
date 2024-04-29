--------------------------------------------------------
--  DDL for Package HR_LOC_ABSENCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_LOC_ABSENCE" AUTHID CURRENT_USER AS
/* $Header: hrabsloc.pkh 120.7 2007/04/11 11:28:32 saurai noship $ */

/* pgopal- Added p_original_entry_id parameter*/
procedure get_element_details
  (p_absence_attendance_id      in  number
  ,p_assignment_id              in number
  ,p_element_type_id           out nocopy number
  ,p_create_entry              out nocopy  varchar2
  ,p_original_entry_id          OUT NOCOPY NUMBER  --gpopal
  ,p_input_value_id1            out nocopy number
  ,p_entry_value1               out nocopy VARCHAR2
  ,p_input_value_id2            out nocopy number
  ,p_entry_value2               out nocopy VARCHAR2
  ,p_input_value_id3            out nocopy number
  ,p_entry_value3               out nocopy VARCHAR2
  ,p_input_value_id4            out nocopy number
  ,p_entry_value4               out nocopy VARCHAR2
  ,p_input_value_id5            out nocopy number
  ,p_entry_value5               out nocopy VARCHAR2
  ,p_input_value_id6            out nocopy number
  ,p_entry_value6               out nocopy VARCHAR2
  ,p_input_value_id7            out nocopy number
  ,p_entry_value7               out nocopy VARCHAR2
  ,p_input_value_id8            out nocopy number
  ,p_entry_value8               out nocopy VARCHAR2
  ,p_input_value_id9            out nocopy number
  ,p_entry_value9               out nocopy VARCHAR2
  ,p_input_value_id10           out nocopy number
  ,p_entry_value10              out nocopy VARCHAR2
  ,p_input_value_id11           out nocopy number
  ,p_entry_value11              out nocopy VARCHAR2
  ,p_input_value_id12           out nocopy number
  ,p_entry_value12              out nocopy VARCHAR2
  ,p_input_value_id13           out nocopy number
  ,p_entry_value13              out nocopy VARCHAR2
  ,p_input_value_id14           out nocopy number
  ,p_entry_value14              out nocopy VARCHAR2
  ,p_input_value_id15           out nocopy number
  ,p_entry_value15              out nocopy VARCHAR2
  );

PROCEDURE create_absence (p_absence_attendance_id NUMBER
			     ,p_effective_date DATE
			     ,p_date_start DATE
			     ,p_date_end   DATE);

function get_element_for_category (p_absence_attendance_id NUMBER) return NUMBER;

function get_package_for_category (p_absence_attendance_id NUMBER) return VARCHAR2;

procedure get_absence_element
  (p_absence_attendance_id in  number
  ,p_assignment_id         in number
  ,p_effective_date        in date
  ,p_processing_type       out nocopy varchar2
  ,p_element_entry_id      out nocopy number
  ,p_effective_start_date  out nocopy date
  ,p_effective_end_date    out nocopy date);

procedure delete_absence_element
  (p_dt_delete_mode            in  varchar2
  ,p_session_date              in  date
  ,p_element_entry_id          in  number
  );

procedure update_absence_element
  (p_dt_update_mode            in  varchar2
  ,p_assignment_id             in  number
  ,p_session_date              in  date
  ,p_element_entry_id          in  number
  ,p_absence_attendance_id     in  number
  ) ;

procedure insert_absence_element
  (p_date_start                in  date
  ,p_assignment_id             in  number
  ,p_absence_attendance_id     in  number
  ,p_element_entry_id          out nocopy number
  );

PROCEDURE update_absence(p_absence_attendance_id NUMBER,
			     p_date_start DATE,
			     p_date_end	DATE,
			     P_EFFECTIVE_DATE DATE);


procedure delete_absence
  (p_absence_attendance_id in  number
  );

end hr_loc_absence;

/
