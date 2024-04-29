--------------------------------------------------------
--  DDL for Package Body PER_ABSENCE_ATTENDANCES_PKG2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ABSENCE_ATTENDANCES_PKG2" as
/* $Header: peaba02t.pkb 115.3 2002/12/11 12:17:33 raranjan ship $ */

--this procedure was written as a workaround. For some reason the
--hr_entry_api procedure cannot be directly called from the form
--therefore requiring that this server side procedure be written as
--an interface between the two. The problem seems to be the interfacing
--between forms and the server side code. It could be the differing
--versions of PLSQL in use between forms and the server, the large number of
--variables in use or the overloading of the package headers.

procedure insert_element(p_effective_start_date IN OUT NOCOPY DATE,
		         p_effective_end_date IN OUT NOCOPY DATE,
		         p_element_entry_id IN OUT NOCOPY NUMBER,
		         p_assignment_id In NUMBER,
		         p_element_link_id IN NUMBER,
		         p_creator_id IN NUMBER,
			 p_creator_type IN VARCHAR2,
			 p_entry_type IN VARCHAR2,
		         p_input_value_id1 IN NUMBER,
		         p_entry_value1 IN VARCHAR2) is
--
-- local vars being used so values not passed back to the client
-- they are incorrect. KLS 13/7/95 WWbug 269609
--
l_eff_start_date  date;
l_eff_end_date    date;
l_element_type_id number;
l_element_link_id number;

cursor c_get_element_type is
select distinct pel.element_type_id
from   pay_element_links_f pel
where  pel.element_link_id = p_element_link_id
and    p_effective_start_date between pel.effective_start_date
                              and     pel.effective_end_date;


begin

l_eff_start_date := p_effective_start_date;
l_eff_end_date := p_effective_end_date;

--
-- Bug 1806161. Re-obtain the element_link_id because the form can
-- get the incorrect link under certain circumstances. First get the
-- element type.
--
open  c_get_element_type;
fetch c_get_element_type into l_element_type_id;
close c_get_element_type;

l_element_link_id := hr_entry_api.get_link
 (p_assignment_id     => p_assignment_id
 ,p_element_type_id   => l_element_type_id
 ,p_session_date      => l_eff_start_date);

hr_entry_api.insert_element_entry(p_effective_start_date => l_eff_start_date,
				  p_effective_end_date => l_eff_end_date,
				  p_element_entry_id => p_element_entry_id,
				  p_assignment_id => p_assignment_id,
				  p_element_link_id => l_element_link_id,
				  p_creator_id => p_creator_id,
				  p_creator_type => p_creator_type,
				  p_entry_type => p_entry_type,
				  p_input_value_id1 => p_input_value_id1,
				  p_entry_value1 => p_entry_value1);
end insert_element;



--this procedure was written as a workaround. For some reason the
--hr_entry_api procedure cannot be directly called from the form
--therefore requiring that this server side procedure be written as
--an interface between the two. The problem seems to be the interfacing
--between forms and the server side code. It could be the differing
--versions of PLSQL in use between forms and the server, the large number of
--variables in use or the overloading of the package headers.

procedure update_element(p_dt_update_mode IN VARCHAR2,
			 p_session_date IN DATE,
			 p_element_entry_id IN NUMBER,
			 p_creator_id IN NUMBER,
			 p_creator_type IN VARCHAR2,
			 p_input_value_id1 IN NUMBER,
			 p_entry_value1 IN VARCHAR2) is

begin
hr_entry_api.update_element_entry(p_dt_update_mode => p_dt_update_mode,
                                  p_session_date => p_session_date,
				  p_element_entry_id =>
				  p_element_entry_id,
				  p_creator_id => p_creator_id,
				  p_creator_type => p_creator_type,
				  p_input_value_id1 =>
				  p_input_value_id1,
				  p_entry_value1 => p_entry_value1);
end update_element;


end PER_ABSENCE_ATTENDANCES_PKG2;

/
