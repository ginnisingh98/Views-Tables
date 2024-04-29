--------------------------------------------------------
--  DDL for Package HR_COMPETENCE_ELEMENT_BK4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_COMPETENCE_ELEMENT_BK4" AUTHID CURRENT_USER as
/* $Header: pecelapi.pkh 120.2 2006/02/13 14:05:47 vbala noship $ */
--
--
--  delete_competence_element_b
--
Procedure delete_competence_element_b
	(
		p_competence_element_id  in   number	,
		p_object_version_number  in   number
	);
--
-- delete_competence_element_a
--
Procedure delete_competence_element_a
	(
		p_competence_element_id  in  number	,
		p_object_version_number  in  number
	);

end hr_competence_element_bk4;

 

/
