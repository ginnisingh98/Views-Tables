--------------------------------------------------------
--  DDL for Package HR_COMPETENCE_ELEMENT_BE6
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_COMPETENCE_ELEMENT_BE6" AUTHID CURRENT_USER as 
--Code generated on 04/01/2007 09:31:55
/* $Header: hrapiwfe.pkb 120.3 2006/06/20 10:26:28 sayyampe noship $*/
procedure copy_competencies_a (
p_activity_version_from        number,
p_activity_version_id          number,
p_activity_version_to          number,
p_competence_type              varchar2);
end hr_competence_element_be6;

 

/
