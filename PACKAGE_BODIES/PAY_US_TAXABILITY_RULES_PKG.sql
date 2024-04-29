--------------------------------------------------------
--  DDL for Package Body PAY_US_TAXABILITY_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_TAXABILITY_RULES_PKG" as
/* $Header: paysuetw.pkb 120.1 2005/09/27 00:36:53 sackumar noship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1993 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************


    Name        : pay_us_taxability_rules_pkg

    Description : This package holds building blocks used in maintenace
                  of US taxability rule using PAY_TAXABILITY_RULES
                  table.

    Uses        : hr_utility

    Change List
    -----------
    Date        Name          Vers    Bug No     Description
    ----        ----          ----    ------     -----------
    NOV-11-1993 RMAMGAIN      1.0                Created with following proc.
                                                 get_or_update
    05-OCT-1994 RFINE         40.1               Added 'PAY_' to package name.
    05-OCT-1994 RFINE         40.2               ... and suffix '_PKG'
    03-APR-1995 gpaytonm      40.3               Modified to handle populating
                                                 classification id.
    18-APR-1995 gpaytonm      40.4		 Changed occurences of
                                                 'W_SIT/FIT'
						 to 'NW_SIT/FIT'.
    19-APR-1995 gpaytonm      40.5		Modified to consider
                                                classification id
					        on query and delete.
    28-SEP-1995 gpaytonm      40.6		Added chk_mutually_exclusive
                                                to insure
						that only one overtime
                                                category at a
						time can be added
                                                included in WC
    25-JUN-1996 D JENG                          added handler for CITY, COUNTY
			                        and SCHOOL
    09-MAR-1999 A. Rundell   115.2              Removed unnecessary MLS change.
    03-JUN-1999 A Handa      115.4              Added legislation_code
                                                check in select
                                                from
                                                pay_element_classifications and
                                                pay_taxability_rules.
    09-JUL-1999	R. Murthy    115.5	        Modified selects and inserts
						from pay_taxability_rules
						to include the new not-null
						column taxability_rules_date_id
						and hard-coded legislation_code
						as US, since Canada has it's
						own package.

    02-JUN-2003	asasthan    115.6 2904628       New column has been added to
                                                pay_taxability_rules.
                                                The status column now carries
                                                a value of 'D' if the rule
                                                is DELETED(D) by either
                                                Oracle or by customer.
    22-sep-2003	asasthan    115.7 3152061       Check has been added
                                                to trash those balances
                                                that have been fed.
    23-sep-2003	asasthan    115.8 3152061       Changes to date joins
                                                in get_balance_type
    23-sep-2003	asasthan    115.9 3152061       added chk for legislation
                                                on pay_element_types_f
    23-sep-2003	asasthan    115.10 3152061      removed chk for legislation
                                                on pay_element_types_f
    03-nov-2003 tclewis     115.11 2845480      Added code to handle AEIC.
                                                state level box 6.
    10-DEC-2003 tclewis     115.14              Changed tax type for AEIC to
                                                STEIC from EIC.
    26-SEP-2005 tclewis     115.15 4537348      Modified conditions in get_or_update procedure
						to handle the t_box6 at state level.

  ************************************************************************/

PROCEDURE get_or_update(X_MODE                VARCHAR2,
                        X_CONTEXT             VARCHAR2,
                        X_JURISDICTION        VARCHAR2,
                        X_TAX_CAT             VARCHAR2,
			X_classification_id   NUMBER,
                        X_BOX1  IN OUT NOCOPY VARCHAR2,
                        X_BOX2  IN OUT NOCOPY VARCHAR2,
                        X_BOX3  IN OUT NOCOPY VARCHAR2,
                        X_BOX4  IN OUT NOCOPY VARCHAR2,
                        X_BOX5  IN OUT NOCOPY VARCHAR2,
                        X_BOX6  IN OUT NOCOPY VARCHAR2) IS
-- Local Variables
P_ret      VARCHAR2(1) := 'N';
P_User_Id  Number      := FND_PROFILE.Value('USER_ID');
P_login_id Number      := FND_PROFILE.Value('LOGIN_ID');
P_i        Number      := 0;
p_taxability_rules_date_id number;
p_valid_date_from      date;
p_valid_date_to         date;
p_legislation_code   VARCHAR2(2) := 'US';

procedure get_date_info(P_legislation_code   VARCHAR2 default 'US',
                      P_taxability_rules_date_id out nocopy number,
                      P_valid_date_from     out nocopy date,
                      P_valid_date_to       out nocopy date,
                      P_date               DATE default sysdate) is
CURSOR csr_get_info is
       select TRD.TAXABILITY_RULES_DATE_ID,
              TRD.VALID_DATE_FROM, TRD.VALID_DATE_TO
       from   PAY_TAXABILITY_RULES_DATES TRD
       where  p_date between TRD.VALID_DATE_FROM and
                             TRD.VALID_DATE_TO
       and    TRD.LEGISLATION_CODE = p_legislation_code;
begin
  OPEN  csr_get_info;
  FETCH csr_get_info INTO P_taxability_rules_date_id, P_valid_date_from,
                          P_valid_date_to;
  CLOSE csr_get_info;
--
END get_date_info;

FUNCTION check_row_exist(P_jurisdiction       VARCHAR2,
                         P_tax_type           VARCHAR2,
                         P_category           VARCHAR2,
                         P_classification_id  NUMBER,
                         P_taxability_rules_date_id NUMBER)
RETURN VARCHAR2 is
--
ret VARCHAR2(1) := 'N';
--
CURSOR csr_check is
       select 'Y'
       from   PAY_TAXABILITY_RULES
       where  JURISDICTION_CODE = P_jurisdiction
       and    TAX_TYPE          = P_tax_type
       and    TAX_CATEGORY      = P_category
       and    CLASSIFICATION_ID = p_classification_id
       and    TAXABILITY_RULES_DATE_ID = p_taxability_rules_date_id
       and    nvl(STATUS,'VALID') <> 'D'
       and    LEGISLATION_CODE  = 'US';
begin
  OPEN  csr_check;
  FETCH csr_check INTO ret;
  IF csr_check%NOTFOUND then
     ret := 'N';
  else
     ret := 'Y';
  end if;
  CLOSE csr_check;
--
  RETURN ret;
--
END check_row_exist;

/********************************************************************
** This function is called when a new taxability rule in inserted.
** The function checks if the row is there, if it exists the status
** needs to be changed from DELETED(D) to Valid(Null) row. If the
** row is not there, insert a new row.
********************************************************************/
FUNCTION insert_rules(P_jurisdiction       VARCHAR2,
                      P_tax_type           VARCHAR2,
                      P_category           VARCHAR2,
                      P_classification_id  NUMBER,
                      P_taxability_rules_date_id NUMBER)
RETURN NUMBER IS

ret number := 0;
begin

   update pay_taxability_rules
      set status = null
    where jurisdiction_code = P_jurisdiction
    and tax_type          = P_tax_type
    and tax_category      = P_category
    and classification_id = p_classification_id
    and taxability_rules_date_id = P_taxability_rules_date_id;

   if sql%notfound then
      INSERT INTO pay_taxability_rules(
         JURISDICTION_CODE, TAX_TYPE, TAX_CATEGORY,
         classification_id, TAXABILITY_RULES_DATE_ID,
         LEGISLATION_CODE,
         LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
         CREATED_BY, CREATION_DATE)
      VALUES (
         P_jurisdiction, P_tax_type, P_category,
         P_classification_id, P_taxability_rules_date_id,
         'US',
         SYSDATE, P_user_id, P_Login_Id,
         P_user_id, SYSDATE);

      IF SQL%NOTFOUND then
         hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
         hr_utility.set_message_token('PROCEDURE','pay_us_taxability_rules_pkg.insert');
         hr_utility.set_message_token('STEP','1');
         hr_utility.raise_error;
      end if;
   end if;

   RETURN ret;
END insert_rules;


/********************************************************************
** This function is called when a taxability rule has to deleted.
** Now instead of physically deleting the row from the database
** we will update the status of the row to DELETED(D).
********************************************************************/
FUNCTION delete_rules(P_jurisdiction       VARCHAR2,
                      P_tax_type           VARCHAR2,
                      P_category           VARCHAR2,
                      p_classification_id  NUMBER,
                      P_taxability_rules_date_id NUMBER)
RETURN NUMBER IS
--
ret number := 0;
begin

 update pay_taxability_rules
    set status = 'D'
  where jurisdiction_code = P_jurisdiction
  and   tax_type          = P_tax_type
  and   tax_category      = P_category
  and   classification_id = p_classification_id
  and   taxability_rules_date_id = P_taxability_rules_date_id;

  IF SQL%NOTFOUND then
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE','pay_us_taxability_rules_pkg.delete');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
  end if;
--
  RETURN ret;
--
END delete_rules;
--
--
-- This function checks whether another row for a given tax type,
-- jursidiction and classification id exist. This is primarily for tax type
-- of WC - as only one row can exist at any time for category of OT or S
-- however, if in the future for any reason this rules is extended to other
-- tax types this functin is stil applicable.
--
-- RETURN TRUE if rules are not mutually exclusive
--
FUNCTION chk_mutually_exclusive (	p_jurisdiction_code	VARCHAR2,
					p_tax_category		VARCHAR2,
					p_tax_type		VARCHAR2,
					p_classification_id	NUMBER )
RETURN BOOLEAN IS
--
-- declare local cursor
--
CURSOR get_other_rule IS
SELECT	'Y'
FROM	pay_taxability_rules
WHERE	jurisdiction_code	= p_jurisdiction_code
AND	tax_type		= p_tax_type
AND	classification_id	= p_classification_id
AND	tax_category		<> p_tax_category
AND     legislation_code        = 'US';
--
l_exists VARCHAR2(1) := 'N';
--
BEGIN
--
OPEN  get_other_rule;
FETCH get_other_rule INTO l_exists;
CLOSE get_other_rule;
--
IF l_exists = 'N'
THEN
	RETURN FALSE;
ELSE
	RETURN TRUE;
END IF;
--
END chk_mutually_exclusive;
--
--
-- MAIN PROCEDURE
begin
  IF X_MODE = 'QUERY' then
     get_date_info(p_legislation_code, p_taxability_rules_date_id,
                   p_valid_date_from, p_valid_date_to);
     if X_CONTEXT = 'FEDERAL' then
        X_BOX1 := check_row_exist(X_jurisdiction,
                                  'EIC',
                                  X_tax_cat,
				  X_classification_id,
                                  p_taxability_rules_date_id);
        X_BOX2 := check_row_exist(X_jurisdiction,
                                  'FIT',
                                  X_tax_cat,
				  X_classification_id,
                                  p_taxability_rules_date_id);
        X_BOX3 := check_row_exist(X_jurisdiction,
                                  'FUTA',
                                  X_tax_cat,
				  X_classification_id,
                                  p_taxability_rules_date_id);
        X_BOX4 := check_row_exist(X_jurisdiction,
                                  'MEDICARE',
                                  X_tax_cat,
				  X_classification_id,
                                  p_taxability_rules_date_id);
        X_BOX5 := check_row_exist(X_jurisdiction,
                                  'SS',
                                  X_tax_cat,
				  X_classification_id,
                                  p_taxability_rules_date_id);
        X_BOX6 := check_row_exist(X_jurisdiction,
                                  'NW_FIT',
                                  X_tax_cat,
				  X_classification_id,
                                  p_taxability_rules_date_id);
     elsif X_CONTEXT = 'STATE' then
        X_BOX1 := check_row_exist(X_jurisdiction,
                                  'WC',
                                  X_tax_cat,
				  X_classification_id,
                                  p_taxability_rules_date_id);
        X_BOX2 := check_row_exist(X_jurisdiction,
                                  'SIT',
                                  X_tax_cat,
				  X_classification_id,
                                  p_taxability_rules_date_id);
        X_BOX3 := check_row_exist(X_jurisdiction,
                                  'SUI',
                                  X_tax_cat,
				  X_classification_id,
                                  p_taxability_rules_date_id);
        X_BOX4 := check_row_exist(X_jurisdiction,
                                  'SDI',
                                  X_tax_cat,
				  X_classification_id,
                                  p_taxability_rules_date_id);
        X_BOX5 := check_row_exist(X_jurisdiction,
                                  'NW_SIT',
                                  X_tax_cat,
				  X_classification_id,
                                  p_taxability_rules_date_id);
        X_BOX6 := check_row_exist(X_jurisdiction,
                                  'STEIC',
                                  X_tax_cat,
				  X_classification_id,
                                  p_taxability_rules_date_id);
     elsif X_CONTEXT = 'WC' then
        X_BOX1 := check_row_exist(X_jurisdiction,
                                  'WC',
                                  X_tax_cat,
				  X_classification_id,
                                  p_taxability_rules_date_id);

--==========================
--
--   CITY, COUNTY and SCHOOL
--
--==========================
     elsif X_CONTEXT = 'COUNTY'
          then
        X_BOX6 := check_row_exist(X_jurisdiction,
                                  'COUNTY',
                                  X_tax_cat,
				  X_classification_id,
                                  p_taxability_rules_date_id);
        X_BOX5 := check_row_exist(X_jurisdiction,
                                  'NW_COUNTY',
                                  X_tax_cat,
				  X_classification_id,
                                  p_taxability_rules_date_id);
     elsif (X_CONTEXT = 'CITY')
          then
        X_BOX6 := check_row_exist(X_jurisdiction,
                                  'CITY',
                                  X_tax_cat,
				  X_classification_id,
                                  p_taxability_rules_date_id);
        X_BOX5 := check_row_exist(X_jurisdiction,
                                  'NW_CITY',
                                  X_tax_cat,
				  X_classification_id,
                                  p_taxability_rules_date_id);
     elsif (X_CONTEXT = 'SCHOOL')
          then
        X_BOX6 := check_row_exist(X_jurisdiction,
                                  'SCHOOL',
                                  X_tax_cat,
				  X_classification_id,
                                  p_taxability_rules_date_id);
        X_BOX5 := check_row_exist(X_jurisdiction,
                                  'NW_SCHOOL',
                                  X_tax_cat,
				  X_classification_id,
                                  p_taxability_rules_date_id);

     end if;
--
  elsif X_MODE = 'UPDATE' then
     P_User_Id  := FND_PROFILE.Value('USER_ID');
     P_Login_Id := FND_PROFILE.Value('LOGIN_ID');
     select taxability_rules_date_id
     into   p_taxability_rules_date_id
     from   pay_taxability_rules_dates
     where  sysdate between valid_date_from and valid_date_to
     and    legislation_code = p_legislation_code;

     if X_CONTEXT = 'FEDERAL' then
        P_ret  := check_row_exist(X_jurisdiction,
                                  'EIC',
                                  X_tax_cat,
				  X_classification_id,
                                  p_taxability_rules_date_id);
        if P_ret = X_box1 then
           null;
        elsif  P_ret = 'Y' and X_box1 = 'N' then
           P_i := delete_rules(X_jurisdiction,'EIC',X_tax_cat, X_classification_id, p_taxability_rules_date_id);
        elsif  P_ret = 'N' and X_box1 = 'Y' then
           P_i := insert_rules(X_jurisdiction,'EIC',X_tax_cat, X_classification_id, p_taxability_rules_date_id);
        end if;
--
        P_ret := check_row_exist(X_jurisdiction,
                                  'FIT',
                                  X_tax_cat,
				  X_classification_id, p_taxability_rules_date_id);
        if P_ret = X_box2 then
           null;
        elsif  P_ret = 'Y' and X_box2 = 'N' then
           P_i := delete_rules(X_jurisdiction,'FIT',X_tax_cat, X_classification_id, p_taxability_rules_date_id);
        elsif  P_ret = 'N' and X_box2 = 'Y' then
           P_i := insert_rules(X_jurisdiction,'FIT',X_tax_cat, X_classification_id, p_taxability_rules_date_id);
        end if;
--
        P_ret := check_row_exist(X_jurisdiction,
                                  'FUTA',
                                  X_tax_cat,
				  X_classification_id, p_taxability_rules_date_id);
        if P_ret = X_box3 then
           null;
        elsif  P_ret = 'Y' and X_box3 = 'N' then
           P_i := delete_rules(X_jurisdiction,'FUTA',X_tax_cat, X_classification_id, p_taxability_rules_date_id);
        elsif  P_ret = 'N' and X_box3 = 'Y' then
           P_i := insert_rules(X_jurisdiction,'FUTA',X_tax_cat, X_classification_id, p_taxability_rules_date_id);
        end if;
--
        P_ret := check_row_exist(X_jurisdiction,
                                  'MEDICARE',
                                  X_tax_cat,
				  X_classification_id, p_taxability_rules_date_id);
        if P_ret = X_box4 then
           null;
        elsif  P_ret = 'Y' and X_box4 = 'N' then
           P_i := delete_rules(X_jurisdiction,'MEDICARE',X_tax_cat, X_classification_id, p_taxability_rules_date_id);
        elsif  P_ret = 'N' and X_box4 = 'Y' then
           P_i := insert_rules(X_jurisdiction,'MEDICARE',X_tax_cat, X_classification_id, p_taxability_rules_date_id);
        end if;
--
        P_ret := check_row_exist(X_jurisdiction,
                                  'SS',
                                  X_tax_cat,
				  X_classification_id, p_taxability_rules_date_id);
        if P_ret = X_box5 then
           null;
        elsif  P_ret = 'Y' and X_box5 = 'N' then
           P_i := delete_rules(X_jurisdiction,'SS',X_tax_cat, X_classification_id, p_taxability_rules_date_id);
        elsif  P_ret = 'N' and X_box5 = 'Y' then
           P_i := insert_rules(X_jurisdiction,'SS',X_tax_cat, X_classification_id, p_taxability_rules_date_id);
        end if;
--
        P_ret := check_row_exist(X_jurisdiction,
                                  'NW_FIT',
                                  X_tax_cat,
				  X_classification_id, p_taxability_rules_date_id);
        if P_ret = X_box6 then
           null;
        elsif  P_ret = 'Y' and X_box6 = 'N' then
           P_i := delete_rules(X_jurisdiction,'NW_FIT',X_tax_cat, X_classification_id, p_taxability_rules_date_id);
        elsif  P_ret = 'N' and X_box6 = 'Y' then
           P_i := insert_rules(X_jurisdiction,'NW_FIT',X_tax_cat, X_classification_id, p_taxability_rules_date_id);
        end if;
--
     elsif X_CONTEXT = 'STATE' then
        P_ret := check_row_exist(X_jurisdiction,
                                  'WC',
                                  X_tax_cat,
				  X_classification_id, p_taxability_rules_date_id);
        if P_ret = X_box1 then
           null;
        elsif  P_ret = 'Y' and X_box1 = 'N' then
           P_i := delete_rules(X_jurisdiction,'WC',X_tax_cat, X_classification_id, p_taxability_rules_date_id);
        elsif  P_ret = 'N' and X_box1 = 'Y' then
           P_i := insert_rules(X_jurisdiction,'WC',X_tax_cat, X_classification_id, p_taxability_rules_date_id);
        end if;
--
        P_ret := check_row_exist(X_jurisdiction,
                                  'STEIC',
                                  X_tax_cat,
				  X_classification_id, p_taxability_rules_date_id);
        if P_ret = X_box6 then
           null;
        elsif  P_ret = 'Y' and X_box6 = 'N' then
           P_i := delete_rules(X_jurisdiction,'STEIC',X_tax_cat, X_classification_id, p_taxability_rules_date_id);
	elsif  P_ret = 'N' and X_box6 = 'Y' then
           P_i := insert_rules(X_jurisdiction,'STEIC',X_tax_cat, X_classification_id, p_taxability_rules_date_id);
        end if;
--
        P_ret := check_row_exist(X_jurisdiction,
                                  'SIT',
                                  X_tax_cat,
				  X_classification_id, p_taxability_rules_date_id);
        if P_ret = X_box2 then
           null;
        elsif  P_ret = 'Y' and X_box2 = 'N' then
           P_i := delete_rules(X_jurisdiction,'SIT',X_tax_cat, X_classification_id, p_taxability_rules_date_id);
        elsif  P_ret = 'N' and X_box2 = 'Y' then
           P_i := insert_rules(X_jurisdiction,'SIT',X_tax_cat, X_classification_id, p_taxability_rules_date_id);
        end if;
--
        P_ret := check_row_exist(X_jurisdiction,
                                  'SUI',
                                  X_tax_cat,
				  X_classification_id, p_taxability_rules_date_id);
        if P_ret = X_box3 then
           null;
        elsif  P_ret = 'Y' and X_box3 = 'N' then
           P_i := delete_rules(X_jurisdiction,'SUI',X_tax_cat, X_classification_id, p_taxability_rules_date_id);
        elsif  P_ret = 'N' and X_box3 = 'Y' then
           P_i := insert_rules(X_jurisdiction,'SUI',X_tax_cat, X_classification_id, p_taxability_rules_date_id);
        end if;
--
        P_ret := check_row_exist(X_jurisdiction,
                                  'SDI',
                                  X_tax_cat,
				  X_classification_id, p_taxability_rules_date_id);
        if P_ret = X_box4 then
           null;
        elsif  P_ret = 'Y' and X_box4 = 'N' then
           P_i := delete_rules(X_jurisdiction,'SDI',X_tax_cat, X_classification_id, p_taxability_rules_date_id);
        elsif  P_ret = 'N' and X_box4 = 'Y' then
           P_i := insert_rules(X_jurisdiction,'SDI',X_tax_cat, X_classification_id, p_taxability_rules_date_id);
        end if;
--
        P_ret := check_row_exist(X_jurisdiction,
                                  'NW_SIT',
                                  X_tax_cat,
				  X_classification_id, p_taxability_rules_date_id);
        if P_ret = X_box5 then
           null;
        elsif  P_ret = 'Y' and X_box5 = 'N' then
           P_i := delete_rules(X_jurisdiction,'NW_SIT',X_tax_cat, X_classification_id, p_taxability_rules_date_id);
        elsif  P_ret = 'N' and X_box5 = 'Y' then
           P_i := insert_rules(X_jurisdiction,'NW_SIT',X_tax_cat, X_classification_id, p_taxability_rules_date_id);
        end if;
--
     elsif X_CONTEXT = 'WC' then
        P_ret := check_row_exist(X_jurisdiction,
                                  'WC',
                                  X_tax_cat,
				  X_classification_id, p_taxability_rules_date_id);
        if P_ret = X_box1 then
           null;
        elsif  P_ret = 'Y' and X_box1 = 'N' then
           P_i := delete_rules(X_jurisdiction,'WC',X_tax_cat, X_classification_id, p_taxability_rules_date_id);
        elsif  P_ret = 'N' and X_box1 = 'Y' then
	--
	-- check whether OT Categor row is mutually exclusive
	--
	IF ( chk_mutually_exclusive (	p_jurisdiction_code	=> X_jurisdiction,
					p_tax_category		=> X_tax_cat,
					p_tax_type		=> 'WC',
					p_classification_id	=> X_classification_id ))
        THEN
		hr_utility.set_message(801, 'HR_50000_WC_ONLY_INC_ONE_OT');
		hr_utility.raise_error;
	END IF;
	--
           P_i := insert_rules(X_jurisdiction,'WC',X_tax_cat, X_classification_id, p_taxability_rules_date_id);
        end if;
--

--==========================
--
--   CITY, COUNTY and  SCHOOL
--
--==========================
--COUNTY

     elsif X_CONTEXT = 'COUNTY' then

        P_ret := check_row_exist(X_jurisdiction,
                                  'COUNTY',
                                  X_tax_cat,
				  X_classification_id, p_taxability_rules_date_id);
        if P_ret = X_box6 then
           null;
        elsif  P_ret = 'Y' and X_box6 = 'N' then
           P_i := delete_rules(X_jurisdiction,'COUNTY',X_tax_cat, X_classification_id, p_taxability_rules_date_id);
        elsif  P_ret = 'N' and X_box6 = 'Y' then

           P_i := insert_rules(X_jurisdiction,'COUNTY',X_tax_cat, X_classification_id, p_taxability_rules_date_id);
        end if;

        P_ret := check_row_exist(X_jurisdiction,
                                  'NW_COUNTY',
                                  X_tax_cat,
				  X_classification_id, p_taxability_rules_date_id);
        if P_ret = X_box5 then
           null;
        elsif  P_ret = 'Y' and X_box5 = 'N' then
           P_i := delete_rules(X_jurisdiction,'NW_COUNTY',X_tax_cat, X_classification_id, p_taxability_rules_date_id);
        elsif  P_ret = 'N' and X_box5 = 'Y' then

           P_i := insert_rules(X_jurisdiction,'NW_COUNTY',X_tax_cat, X_classification_id, p_taxability_rules_date_id);
        end if;

--CITY

     elsif X_CONTEXT = 'CITY' then

        P_ret := check_row_exist(X_jurisdiction,
                                  'CITY',
                                  X_tax_cat,
				  X_classification_id, p_taxability_rules_date_id);
        if P_ret = X_box6 then
           null;
        elsif  P_ret = 'Y' and X_box6 = 'N' then
           P_i := delete_rules(X_jurisdiction,'CITY',X_tax_cat, X_classification_id, p_taxability_rules_date_id);
        elsif  P_ret = 'N' and X_box6 = 'Y' then

           P_i := insert_rules(X_jurisdiction,'CITY',X_tax_cat, X_classification_id, p_taxability_rules_date_id);
        end if;

        P_ret := check_row_exist(X_jurisdiction,
                                  'NW_CITY',
                                  X_tax_cat,
				  X_classification_id, p_taxability_rules_date_id);
        if P_ret = X_box5 then
           null;
        elsif  P_ret = 'Y' and X_box5 = 'N' then
           P_i := delete_rules(X_jurisdiction,'NW_CITY',X_tax_cat, X_classification_id, p_taxability_rules_date_id);
        elsif  P_ret = 'N' and X_box5 = 'Y' then

           P_i := insert_rules(X_jurisdiction,'NW_CITY',X_tax_cat, X_classification_id, p_taxability_rules_date_id);
        end if;

--SCHOOL

    elsif X_CONTEXT = 'SCHOOL' then

        P_ret := check_row_exist(X_jurisdiction,
                                  'SCHOOL',
                                  X_tax_cat,
				  X_classification_id, p_taxability_rules_date_id);
        if P_ret = X_box6 then
           null;
        elsif  P_ret = 'Y' and X_box6 = 'N' then
           P_i := delete_rules(X_jurisdiction,'SCHOOL',X_tax_cat, X_classification_id, p_taxability_rules_date_id);
        elsif  P_ret = 'N' and X_box6 = 'Y' then

           P_i := insert_rules(X_jurisdiction,'SCHOOL',X_tax_cat, X_classification_id, p_taxability_rules_date_id);
        end if;

        P_ret := check_row_exist(X_jurisdiction,
                                  'NW_SCHOOL',
                                  X_tax_cat,
				  X_classification_id, p_taxability_rules_date_id);
        if P_ret = X_box5 then
           null;
        elsif  P_ret = 'Y' and X_box5 = 'N' then
           P_i := delete_rules(X_jurisdiction,'NW_SCHOOL',X_tax_cat, X_classification_id, p_taxability_rules_date_id);
        elsif  P_ret = 'N' and X_box5 = 'Y' then

           P_i := insert_rules(X_jurisdiction,'NW_SCHOOL',X_tax_cat, X_classification_id, p_taxability_rules_date_id);
        end if;



     end if;
--
  end if;
--
END get_or_update;
--
--
-- function to get the classification id fro 'Earnings'.
-- This is the default classification id for the WC OT category
-- tax rules from the WC form (DJC).
--
FUNCTION get_classification_id (p_classification_name VARCHAR2) RETURN NUMBER IS
--
-- declare cursor
--
CURSOR get_class_id IS
SELECT pec.classification_id
FROM  pay_element_classifications PEC
WHERE  PEC.classification_name = p_classification_name
AND    PEC.legislation_code    = 'US';
--
l_classification_id NUMBER(9);
--
BEGIN
--
OPEN  get_class_id;
FETCH get_class_id INTO l_classification_id;
CLOSE get_class_id;
--
RETURN l_classification_id;
--
END get_classification_id;

/*****************************************************************************
   Name      : get_balance_type
   Purpose   : This procedure gets balance_type_id for the tax_type
               and calls core functions to trash latest balances
               and associated run balances when taxability rules are changed.
   Arguments : p_tax_type          - Only federal level tax types
               p_tax_category      - ensures correct lookup_types are touched
               p_taxability_rules_date_id
               p_legislation_code

*****************************************************************************/

PROCEDURE get_balance_type(p_tax_type in varchar2,
                           p_tax_category in varchar2,
                           p_taxability_rules_date_id in number,
                           p_legislation_code in varchar2,
                           p_classification_id in number) is

cursor c_chk_element_taxcat(cp_classification_id  in number,
                            cp_tax_category in varchar2,
                            cp_trash_date in date) is
select 'Y' from dual
  where exists (
  select element_type_id
  from pay_element_types_f pet
where pet.classification_id = cp_classification_id
  and pet.element_information1 = cp_tax_category
  and effective_end_date >= cp_trash_date
 ) ;


cursor c_get_balance_type(cp_tax_type in varchar2,
                          cp_tax_category in varchar2,
                          cp_trash_date in date,
                          cp_classification_id in number ) is
  select balance_type_id,balance_name
   from pay_balance_types pbt
  where pbt.tax_type = cp_tax_type
    and pbt.legislation_code = 'US'
  and exists
      ( select 1
          from pay_balance_feeds_f pbf,
               pay_input_values_f piv,
               pay_element_types_f pet
         where pbf.balance_type_id = pbt.balance_type_id
             and pbf.effective_end_date >= cp_trash_date
             and piv.input_value_id = pbf.input_value_id
             and pbf.effective_start_date between piv.effective_start_date
                                              and piv.effective_end_date
             and pet.element_type_id = piv.element_type_id
             and pbf.effective_start_date between pet.effective_start_date
                                              and pet.effective_end_date
             and pet.classification_id = cp_classification_id
             and pet.element_information1 = cp_tax_category
             );


cursor c_session is
  select trunc(effective_date,'Y')
  from   fnd_sessions
  where  session_id = userenv('sessionid');


lv_exist_flag  varchar2(1) :='N';
ln_balance_type_id pay_balance_types.balance_type_id%TYPE := 0;
lv_balance_name pay_balance_types.balance_name%TYPE;
ln_business_group_id pay_balance_types.business_group_id%TYPE;
lv_legislation_code pay_balance_types.legislation_code%TYPE;
ld_effective_date date;


Begin
   hr_utility.trace('tax_type :'||p_tax_type);
   hr_utility.trace('tax_category :'||p_tax_category);
   hr_utility.trace('p_legislation_code :'||p_legislation_code);
   hr_utility.trace('p_taxability_rules_date_id :'||to_char(p_taxability_rules_date_id));
   hr_utility.trace('p_classification_id :'||to_char(p_classification_id));


   if p_legislation_code = 'US' then

        if p_tax_type in ('CSDI',
                          'EIC',
                          'FIT',
                          'FUTA',
                          'GDI',
                          'MEDICARE',
                          'NW_FIT',
                          'SS') then

          open c_session ;
          fetch c_session into ld_effective_date ;
          if c_session%notfound then ld_effective_date := trunc(sysdate,'Y') ;
          end if;
          close c_session ;
          hr_utility.trace('ld_effective_date :'||to_char(ld_effective_date));

          open c_chk_element_taxcat(p_classification_id,
                                    p_tax_category,
                                    ld_effective_date);

          fetch c_chk_element_taxcat into lv_exist_flag;
          close c_chk_element_taxcat;

          if lv_exist_flag = 'Y' then


           open c_get_balance_type(p_tax_type,
                                   p_tax_category,
                                   ld_effective_date,
                                   p_classification_id);
           loop
               fetch c_get_balance_type into ln_balance_type_id
                                            ,lv_balance_name;
               exit when c_get_balance_type%notfound;
           hr_utility.trace('balance_type_id :'||to_char(ln_balance_type_id));
           hr_utility.trace('balance_name :'||lv_balance_name);



               /* for each of balance fetched call the core
                  procedure to trash all person and assignment
                  latest balances */

                  hrassact.trash_latest_balances(ln_balance_type_id,
                                                 ld_effective_date);


                  pay_balance_pkg.invalidate_run_balances(ln_balance_type_id,
                                                          ld_effective_date);


            end loop;
           close c_get_balance_type;

           end if ; /*element exists */

        end if; /* p_tax_type */


   end if; /* p_legislation_code = 'US' */
END;
--begin
--hr_utility.trace_on (null, 'XTR');

END pay_us_taxability_rules_pkg;

/
