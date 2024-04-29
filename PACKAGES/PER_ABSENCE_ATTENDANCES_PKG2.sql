--------------------------------------------------------
--  DDL for Package PER_ABSENCE_ATTENDANCES_PKG2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ABSENCE_ATTENDANCES_PKG2" AUTHID CURRENT_USER as
/* $Header: peaba02t.pkh 115.1 2002/12/11 12:18:00 raranjan ship $ */

procedure insert_element(p_effective_start_date IN OUT NOCOPY DATE,
		         p_effective_end_date IN OUT NOCOPY DATE,
		         p_element_entry_id IN OUT NOCOPY NUMBER,
		         p_assignment_id In NUMBER,
		         p_element_link_id IN NUMBER,
		         p_creator_id IN NUMBER,
			 p_creator_type IN VARCHAR2,
			 p_entry_type IN VARCHAR2,
		         p_input_value_id1 IN NUMBER,
		         p_entry_value1 IN VARCHAR2);

procedure update_element(p_dt_update_mode IN VARCHAR2,
			 p_session_date IN DATE,
			 p_element_entry_id IN NUMBER,
			 p_creator_id IN NUMBER,
			 p_creator_type IN VARCHAR2,
			 p_input_value_id1 IN NUMBER,
			 p_entry_value1 IN VARCHAR2);


end PER_ABSENCE_ATTENDANCES_PKG2;

 

/
