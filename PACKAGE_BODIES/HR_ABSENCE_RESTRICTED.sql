--------------------------------------------------------
--  DDL for Package Body HR_ABSENCE_RESTRICTED
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ABSENCE_RESTRICTED" as
/* $Header: peabrest.pkb 120.0.12010000.4 2010/03/18 10:25:49 ghshanka noship $ */
-- ----------------------------------------------------------------------------
-- |----------------------< absences_restricted >--------------------------|
-- ----------------------------------------------------------------------------
--

function absences_restricted(selected_person_id in varchar2,
		 login_person_id in varchar2
		 )return varchar2 is

begin

	NULL;

/* Example code logic


	if to_number(selected_person_id) = 36003 then
		 return '31044,31045';
	 end if;

*/

return '-1'; -- do not return null..
end absences_restricted;

--
end hr_absence_restricted;

/
