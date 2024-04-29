--------------------------------------------------------
--  DDL for Package PAY_NO_ABSENCE_USER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NO_ABSENCE_USER" AUTHID CURRENT_USER AS
/*$Header: pynoabsusr.pkh 120.0.12010000.1 2008/07/27 23:13:22 appldev ship $*/
-------------------------------------------------------------------------------------------------------------------------
/*  Element populate function to return Input values of absence element */
   -- NAME
   --  Element_populate
   -- PURPOSE
   --  To populate element input values for absence recording.
   -- ARGUMENTS
   --  P_ASSIGNMENT_ID         - Assignment id
   --  P_PERSON_ID 	       - Person id,
   --  P_ABSENCE_ATTENDANCE_ID - Absence attendance id,
   --  P_ELEMENT_TYPE_ID       - Element type id,
   --  P_ABSENCE_CATEGORY      - Absence category ( Sickness ),
   --  P_INPUT_VALUE_NAME 1-15 - Output variable holds element input value name.
   --  P_INPUT_VALUE 1-15      - Output variable holds element input value.
   -- USES
   -- NOTES
   --  The procedure fetches absence information from absence table with input absence_attendance_id and absence
   --  category 'Sickness', 'Part Time Sickness' and 'Child Minder Sickness'. Then it assigns the values to output variables.
-------------------------------------------------------------------------------------------------------------------------
Function Element_populate (p_assignment_id         in number,
                p_person_id in number,
		p_absence_attendance_id in number,
                p_element_type_id 	    in number,
	        p_absence_category 	    in varchar2,
	        p_original_entry_id     OUT nocopy NUMBER, --pgopal
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
		p_input_value15	    	OUT NOCOPY VARCHAR2) RETURN VARCHAR2;
END PAY_NO_ABSENCE_USER;

/
