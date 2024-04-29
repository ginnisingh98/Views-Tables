--------------------------------------------------------
--  DDL for Package Body PER_ITS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ITS_PKG" as
/* $Header: peits01t.pkb 120.0 2005/05/31 10:31:14 appldev noship $ */
-- ----------------------------------------------------------------------------
-- return_legislation_code
--
--    Returns the legislation code for the business group of a responsibility
-- ----------------------------------------------------------------------------
--
FUNCTION return_legislation_code (p_responsibility_id IN NUMBER)
                                  RETURN VARCHAR2 IS
--
l_leg_code VARCHAR2(150);
--
BEGIN
--
--
select c.legislation_code into l_leg_code
from fnd_profile_options a, fnd_profile_option_values b, per_business_groups c
where a.profile_option_name = 'PER_BUSINESS_GROUP_ID'
and a.profile_option_id = b.profile_option_id
and b.level_value = p_responsibility_id
and b.level_id = 10003   /* responsibility level profile option */
and b.profile_option_value = to_char(c.business_group_id);
--
return l_leg_code;
--
END RETURN_LEGISLATION_CODE;
--
END PER_ITS_PKG;

/
