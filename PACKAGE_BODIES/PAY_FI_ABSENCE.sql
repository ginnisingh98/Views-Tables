--------------------------------------------------------
--  DDL for Package Body PAY_FI_ABSENCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FI_ABSENCE" AS
/* $Header: pyfiabsc.pkb 120.0.12000000.2 2007/03/01 09:16:43 dbehera noship $ */
	FUNCTION MAINTAIN_PAID_HOLIDAY
		( p_assignment_id         in number,
                p_person_id 		in number,
               	p_absence_attendance_id in number,
		p_element_type_id 	in number,
		p_absence_category 	in varchar2,
		p_original_entry_id     OUT nocopy NUMBER,
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
		p_input_value15	    	OUT NOCOPY VARCHAR2)
		RETURN VARCHAR2 IS


		BEGIN

			IF p_absence_category = 'V' THEN

				p_input_value_name1	:=  'CREATOR_ID';
				p_input_value1			:=  p_absence_attendance_id;

				RETURN 'Y';

			ELSE

				RETURN 'N';

			END IF;

		END MAINTAIN_PAID_HOLIDAY;

END PAY_FI_ABSENCE;

/
