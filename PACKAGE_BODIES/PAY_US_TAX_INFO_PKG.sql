--------------------------------------------------------
--  DDL for Package Body PAY_US_TAX_INFO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_TAX_INFO_PKG" AS
/* $Header: pyusgjit.pkb 115.8 2003/12/16 09:53:19 tclewis ship $ */
/*
 ******************************************************************
 *                                                                *
 *  Copyright (C) 1997 Oracle Corporation US Ltd.                 *
 *                                                                *
 *  All rights reserved.                                          *
 *                                                                *
 *  This material has been provided pursuant to an agreement      *
 *  containing restrictions on its use.  The material is also     *
 *  protected by copyright law.  No part of this material may     *
 *  be copied or distributed, transmitted or transcribed, in      *
 *  any form or by any means, electronic, mechanical, magnetic,   *
 *  manual, or otherwise, or disclosed to third parties without   *
 *  the express written permission of Oracle Corporation US Ltd.  *
 *                                                                *
 ******************************************************************
 Name        : pay_us_jit (BODY)
 File        : pyusgjit.pkb
 Description : This package declares functions which are used
               to return values for US Payroll W2 report.

 Change List
 -----------

 Version Date      Author     ER/CR No. Description of Change
 -------+---------+----------+---------+-------------------------------------------------
 40.0    07-DEC-97 lwthomps	         Date Created
 40.1/
 110.1   08-DEC-98 rthirlby   735626    Added get_tax_exist.Used in state
                                        balance views.
 110.3   18-FEB-99 rthakur    793794    Added a check for WC2
 110.5   04-AUG-99 rmonge               Made package body adchkdrv compliant.
 115.6   05-NOV_03 tclewis              Added check for State EIC STEIC.
 ========================================================================================
*/

FUNCTION get_sit_exist (p_state_abbrev		VARCHAR2,
                        p_date                  DATE
		        ) return boolean
--
IS
--
l_state_exist	VARCHAR2(10);
--
begin
--
   hr_utility.trace('p_state_abbrev	->'||p_state_abbrev);
--
begin
--
SELECT
	sit_exists
INTO
	l_state_exist
FROM
	pay_us_state_tax_info_f	pustif,
	pay_us_states		pus
WHERE
	pus.state_code	 = pustif.state_code
AND	pus.state_abbrev = p_state_abbrev
AND     SIT_EXISTS = 'Y'
AND	p_date between effective_start_date
		and effective_end_date;
--
RETURN TRUE;
   hr_utility.trace('l_state_exist	->'||l_state_exist);
--
exception when NO_DATA_FOUND then
      RETURN FALSE;
--
end;
--
--
end get_sit_exist;
--
--
FUNCTION get_lit_exist (p_tax_type             varchar2,
                        p_jurisdiction_code    varchar2,
                        p_date                 date)
                        return boolean
--
IS
--
l_lit_exist	VARCHAR2(10);
--
begin
--
   hr_utility.trace('p_tax_type		->'||p_tax_type);
   hr_utility.trace('p_jurisdiction_code->'||p_jurisdiction_code);
   hr_utility.trace('p_date		->'||to_char(p_date));
--
begin
--
if p_tax_type like 'COUNTY' then
--
	SELECT
		COUNTY_TAX
	INTO
		l_lit_exist
	FROM
		pay_us_county_tax_info_f
	WHERE
		jurisdiction_code	 = p_jurisdiction_code
        AND     county_tax = 'Y'
	AND	p_date between effective_start_date
		and effective_end_date;
--
elsif p_tax_type like 'CITY' then
--
	SELECT
		CITY_TAX
	INTO
		l_lit_exist
	FROM
		pay_us_city_tax_info_f
	WHERE
		jurisdiction_code	 = p_jurisdiction_code
        AND     city_tax = 'Y'
	AND	p_date between effective_start_date
		and effective_end_date;
--
end if;
--
RETURN TRUE;
   hr_utility.trace('l_lit_exist	->'||l_lit_exist);
--
exception when NO_DATA_FOUND then
  RETURN FALSE;
--
end;
--
--
end get_lit_exist;
--
--------------------------------------------------------------------
-- Function get_tax_exist. This returns 'Y' if the following state
-- state taxes exist, SDI, SUI, SIT, WC for a particular state on a
-- particular date.
--------------------------------------------------------------------
FUNCTION get_tax_exist(p_tax_type             varchar2,
                       p_jurisdiction_code    varchar2,
                       p_ee_or_er             varchar2,
                       p_date                 date)
                       return varchar2
IS
--
l_exists  varchar2(2);
l_false   varchar2(1) := 'N';
BEGIN
--
  IF (p_tax_type <> 'WC' OR p_tax_type <> 'WC2') THEN
  --
      SELECT 'Y'
      INTO l_exists
      FROM pay_us_state_tax_info_f pust
      WHERE state_code = substr(p_jurisdiction_code,1,2)
      AND   p_date between effective_start_date and effective_end_date
      AND   decode(decode(p_tax_type||'_'||p_ee_or_er
               , 'SDI_EE', to_char(SDI_EE_WAGE_LIMIT)
               , 'SDI_ER', to_char(SDI_ER_WAGE_LIMIT)
               , 'SIT_', SIT_EXISTS
               , 'SUI_EE', to_char(SUI_EE_WAGE_LIMIT)
               , 'SUI_ER', to_char(SUI_ER_WAGE_LIMIT)
               , 'STEIC_EE',STA_INFORMATION17
                        , 'UNKNOWN'), '', 'N', 'Y')
                    = 'Y';
      --
      RETURN l_exists;
  ELSE
  --
      SELECT 'Y'
      INTO l_exists
      FROM pay_wc_funds pwf,
           pay_us_states pus
      WHERE pus.state_code = substr(p_jurisdiction_code,1,2)
      AND   pus.state_abbrev = pwf.state_code;
      /* How about business_group_id too ? */
      RETURN l_exists;
      --
  END IF;
  --
RETURN l_false;
--
EXCEPTION
--
  WHEN NO_DATA_FOUND THEN
     RETURN l_false;
  --
  WHEN TOO_MANY_ROWS THEN
     RETURN l_exists;
END get_tax_exist;
--
end pay_us_tax_info_pkg;

/
