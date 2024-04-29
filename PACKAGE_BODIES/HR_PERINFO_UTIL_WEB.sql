--------------------------------------------------------
--  DDL for Package Body HR_PERINFO_UTIL_WEB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_PERINFO_UTIL_WEB" as
/* $Header: hrpiutlw.pkb 120.3 2005/12/13 13:50:50 svittal noship $ */
  c_prompts           hr_util_misc_web.g_prompts%TYPE;
  c_title             hr_util_misc_web.g_title%TYPE;
  g_package           varchar2(31)   := 'HR_PERINFO_UTIL_WEB';
  g_person_id per_all_people_f.person_id%TYPE;
  g_region_code  constant varchar2(30) := 'HR_PERINFO_FRAMES';
  g_application_id   constant integer      := 601;


-- private function
--
function isR11i(p_application_id in number default 800)
  RETURN BOOLEAN is
--
cursor csr_get_prod_verison is
select PRODUCT_VERSION
from FND_PRODUCT_INSTALLATIONS
where APPLICATION_ID = p_application_id;
--
l_version    FND_PRODUCT_INSTALLATIONS.PRODUCT_VERSION%TYPE;
--
begin
  open csr_get_prod_verison;
  fetch csr_get_prod_verison into l_version;
  close csr_get_prod_verison;
  l_version := substr(l_version,1,4);
  l_version := replace(l_version,'.');
  if to_number(l_version) >= 115 then
    return true;
  else
    return false;
  end if;

end isR11i;



/*------------------------------------------------------------------------------
|
|       Name           : isDateLessThanCreationDate
|
|       Purpose        :
|
|       This  function will check if the passed in date is less than the date
|       on which the person was created. The creation date of the person is
|       MIN(EFFECTIVE_START_DATE) from per_all_people_f for a person.
|
|       In Parameters  :
|
|       p_date         : The date to be checked.
|       p_person_id    : The ID of person for whom this check is done.
|
|       Returns        :
|
|       Boolean        :
|
|       TRUE           : If the date is less than the creation date.
|       FALSE          : If the date is equal to or greater than the creation
|                        date.
+-----------------------------------------------------------------------------*/

	FUNCTION isDateLessThanCreationDate
		(p_date IN DATE,p_person_id IN NUMBER) RETURN BOOLEAN IS

	CURSOR csr_min_start_date IS
	SELECT min(pp.effective_start_date)
	FROM   per_all_people_f pp
	WHERE  pp.person_id = p_person_id;

	l_start_date DATE;
	BEGIN
		OPEN csr_min_start_date;
		FETCH csr_min_start_date INTO l_start_date;
		CLOSE csr_min_start_date;

		IF trunc(p_date) >= trunc(l_start_date) THEN
			RETURN FALSE;
		ELSE
			RETURN TRUE;
		END IF;
	EXCEPTION
	WHEN OTHERS THEN
		raise;
	END isDateLessThanCreationDate;

/*------------------------------------------------------------------------------
|
|       Name           : isLessThanCurrentStartDate
|
|       Purpose        :
|
|       This  function will check if the passed in date is less than the
|       Effective Start Date of the person reocrd which is current for a
|       given Object Version Number and Person ID.
|
|       In Parameters  :
|
|       p_date         : The date to be checked.
|       p_person_id    : The ID of person for whom this check is done.
|       p_ovn          : The Object Version of the Person row in question.
|
|       Returns        :
|
|       Boolean        :
|
|       TRUE           : If the date is less than the Effective Start Date.
|       FALSE          : If the date is equal to or greater than the Effective
|                        Start date.
+-----------------------------------------------------------------------------*/

	FUNCTION isLessThanCurrentStartDate
		(p_effective_date IN DATE
		,p_person_id IN NUMBER
		,p_ovn IN NUMBER) RETURN BOOLEAN IS

	CURSOR csr_chk_effective_date IS
	SELECT 'Y'
	FROM   per_all_people_f pp
	WHERE  pp.person_id = p_person_id
	AND    pp.object_version_number = p_ovn
	AND    trunc(p_effective_date) < trunc(pp.effective_start_date);

	l_result VARCHAR2(10);
	BEGIN
		OPEN csr_chk_effective_date;
		FETCH csr_chk_effective_date INTO l_result;
		CLOSE csr_chk_effective_date;

		IF l_result = 'Y'  THEN
			RETURN TRUE;
		ELSE
			RETURN FALSE;
		END IF;
	EXCEPTION
	WHEN OTHERS THEN
		raise;
	END isLessThanCurrentStartDate;



END hr_perinfo_util_web;

/
