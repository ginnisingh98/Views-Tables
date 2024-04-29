--------------------------------------------------------
--  DDL for Package PAY_SE_ABSENCE_USER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SE_ABSENCE_USER" AUTHID CURRENT_USER AS
/*$Header: pyseabsence.pkh 120.1 2007/06/28 13:19:02 rravi noship $*/
Function Element_populate (p_assignment_id         in number,
                p_person_id in number,
		p_absence_attendance_id in number,
                p_element_type_id 	in number,
		p_absence_category 	in varchar2,
		p_original_entry_id     OUT NOCOPY NUMBER,
                p_input_value_name1 	OUT NOCOPY VARCHAR2,
		p_input_value1	    	OUT NOCOPY VARCHAR2,
                p_input_value_name2 	OUT NOCOPY VARCHAR2,
		p_input_value2	    	OUT NOCOPY VARCHAR2,
                p_input_value_name3 	OUT NOCOPY VARCHAR2,
		p_input_value3	    	OUT NOCOPY VARCHAR2,
                p_input_value_name4 	OUT NOCOPY VARCHAR2,
		p_input_value4	    	OUT NOCOPY VARCHAR2,
                p_input_value_name5 	OUT NOCOPY VARCHAR2,
		p_input_value5	    	OUT NOCOPY VARCHAR2,
                p_input_value_name6 	OUT NOCOPY VARCHAR2,
		p_input_value6	    	OUT NOCOPY VARCHAR2,
                p_input_value_name7 	OUT NOCOPY VARCHAR2,
		p_input_value7	    	OUT NOCOPY VARCHAR2,
                p_input_value_name8 	OUT NOCOPY VARCHAR2,
		p_input_value8	    	OUT NOCOPY VARCHAR2,
                p_input_value_name9 	OUT NOCOPY VARCHAR2,
		p_input_value9	    	OUT NOCOPY VARCHAR2,
                p_input_value_name10 	OUT NOCOPY VARCHAR2,
		p_input_value10	    	OUT NOCOPY VARCHAR2,
                p_input_value_name11 	OUT NOCOPY VARCHAR2,
		p_input_value11	    	OUT NOCOPY VARCHAR2,
                p_input_value_name12 	OUT NOCOPY VARCHAR2,
		p_input_value12	    	OUT NOCOPY VARCHAR2,
                p_input_value_name13 	OUT NOCOPY VARCHAR2,
		p_input_value13	    	OUT NOCOPY VARCHAR2,
                p_input_value_name14 	OUT NOCOPY VARCHAR2,
		p_input_value14	    	OUT NOCOPY VARCHAR2,
                p_input_value_name15 	OUT NOCOPY VARCHAR2,
		p_input_value15	    	OUT NOCOPY VARCHAR2  ) RETURN VARCHAR2;

  PROCEDURE GET_WEEKEND_PUBLIC_HOLIDAYS(p_assignment_id in number,
                P_START_DATE		in varchar2,
		P_END_DATE		in varchar2,
		p_start_time		in varchar2,
		p_end_time		in varchar2,
		p_weekends		OUT NOCOPY NUMBER,
		p_public_holidays	OUT NOCOPY NUMBER,
		p_Total_holidays	OUT NOCOPY NUMBER
		);

Function holiday_Element_populate (p_assignment_id         in number,
                p_person_id in number,
		p_absence_attendance_id in number,
                p_element_type_id 	in number,
		p_absence_category 	in varchar2,
		p_original_entry_id     OUT NOCOPY NUMBER,
                p_input_value_name1 	OUT NOCOPY VARCHAR2,
		p_input_value1	    	OUT NOCOPY VARCHAR2,
                p_input_value_name2 	OUT NOCOPY VARCHAR2,
		p_input_value2	    	OUT NOCOPY VARCHAR2,
                p_input_value_name3 	OUT NOCOPY VARCHAR2,
		p_input_value3	    	OUT NOCOPY VARCHAR2,
                p_input_value_name4 	OUT NOCOPY VARCHAR2,
		p_input_value4	    	OUT NOCOPY VARCHAR2,
                p_input_value_name5 	OUT NOCOPY VARCHAR2,
		p_input_value5	    	OUT NOCOPY VARCHAR2,
                p_input_value_name6 	OUT NOCOPY VARCHAR2,
		p_input_value6	    	OUT NOCOPY VARCHAR2,
                p_input_value_name7 	OUT NOCOPY VARCHAR2,
		p_input_value7	    	OUT NOCOPY VARCHAR2,
                p_input_value_name8 	OUT NOCOPY VARCHAR2,
		p_input_value8	    	OUT NOCOPY VARCHAR2,
                p_input_value_name9 	OUT NOCOPY VARCHAR2,
		p_input_value9	    	OUT NOCOPY VARCHAR2,
                p_input_value_name10 	OUT NOCOPY VARCHAR2,
		p_input_value10	    	OUT NOCOPY VARCHAR2,
                p_input_value_name11 	OUT NOCOPY VARCHAR2,
		p_input_value11	    	OUT NOCOPY VARCHAR2,
                p_input_value_name12 	OUT NOCOPY VARCHAR2,
		p_input_value12	    	OUT NOCOPY VARCHAR2,
                p_input_value_name13 	OUT NOCOPY VARCHAR2,
		p_input_value13	    	OUT NOCOPY VARCHAR2,
                p_input_value_name14 	OUT NOCOPY VARCHAR2,
		p_input_value14	    	OUT NOCOPY VARCHAR2,
                p_input_value_name15 	OUT NOCOPY VARCHAR2,
		p_input_value15	    	OUT NOCOPY VARCHAR2  ) RETURN VARCHAR2;

FUNCTION GET_DAYS_WITH_ABS_PERCENTAGE(
		p_date_earned in date,
		p_tax_unit_id in Number,
		p_assignment_action_id IN NUMBER,
		p_assignment_id IN NUMBER,
		p_business_group_id in NUMBER,
		p_days IN NUMBER,
		p_Absence_percentage IN Number,
		p_category_code IN VARCHAR2
		)

RETURN NUMBER;

FUNCTION CHECK_SICK_INTERUPTED(p_date_earned IN date,
		p_assignment_id IN NUMBER,
		p_tax_unit_id IN NUMBER,
		p_business_group_id in NUMBER,
		p_category_code IN VARCHAR2
		)
RETURN VARCHAR2;
END PAY_SE_ABSENCE_USER;


/
