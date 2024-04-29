--------------------------------------------------------
--  DDL for Package HR_COMPETENCES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_COMPETENCES_BK3" AUTHID CURRENT_USER as
/* $Header: pecpnapi.pkh 120.1 2005/11/28 03:21:27 dsaxby noship $ */
--
--
--  delete_competence_b
--
Procedure delete_competence_b
	(
         p_competence_id             in   number,
         p_object_version_number     in   number
	);
--
-- delete_competence_a
--
Procedure delete_competence_a
	(
         p_competence_id             in   number,
         p_object_version_number     in   number
	);

end hr_competences_bk3;

 

/
