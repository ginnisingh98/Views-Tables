--------------------------------------------------------
--  DDL for Package HR_COMPETENCE_ELEMENT_BK6
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_COMPETENCE_ELEMENT_BK6" AUTHID CURRENT_USER as
/* $Header: pecelapi.pkh 120.2 2006/02/13 14:05:47 vbala noship $ */
--
--
-- copy_competencies_b
--
-- A new parameter p_activity_version_id is introduced so that the generator
-- can make a call to ota_tav_bus to get the legislation code by passing the
-- activity_version_id. Hence when these procedures are called the parameter
-- activity_version_id should have the same value as p_activity_version_from.
--
Procedure copy_competencies_b	(
       p_activity_version_from   in number
      ,p_activity_version_id     in number
      ,p_activity_version_to     in number
      ,p_competence_type         in varchar2
     );
--
-- copy_competencies_a
--
Procedure copy_competencies_a	(
       p_activity_version_from   in number
      ,p_activity_version_id     in number
      ,p_activity_version_to     in number
      ,p_competence_type         in varchar2
	);

end hr_competence_element_bk6;

 

/
