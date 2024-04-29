--------------------------------------------------------
--  DDL for Package Body PAY_CA_TAXABILITY_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_TAXABILITY_RULES_PKG" as
/* $Header: paycaetw.pkb 120.1 2006/02/21 11:42:26 ssouresr noship $ */
--
--
 /*
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


    Name        : pay_ca_taxability_rules_pkg

    Description : This package holds building blocks used in maintenace
                  of Canadian taxability rules using PAY_TAXABILITY_RULES
                  table.

    Uses        : hr_utility

    Change List
    -----------
    Date        Name          Vers    Bug No     Description
    ----        ----          ----    ------     -----------
    8/15/98	RAMURTHY      110.0		 Created.

    05-NOV-05   SSOURESR      115.2              Added tax type PPIP
  */
--

PROCEDURE get_or_update(X_MODE                VARCHAR2,
                        X_CONTEXT             VARCHAR2,
                        X_JURISDICTION        VARCHAR2,
                        X_TAX_CAT             VARCHAR2,
			X_classification_id   NUMBER,
			X_legislation_code    VARCHAR2,
			X_taxability_rules_date_id out nocopy NUMBER,
			X_valid_date_from  in out nocopy DATE,
                        X_valid_date_to    in out nocopy DATE,
			X_session_date		DATE,
                        X_BOX1         IN OUT nocopy VARCHAR2,
                        X_BOX2         IN OUT nocopy VARCHAR2,
                        X_BOX3         IN OUT nocopy VARCHAR2,
                        X_BOX4         IN OUT nocopy VARCHAR2,
                        X_BOX5         IN OUT nocopy VARCHAR2,
                        X_BOX6         IN OUT nocopy VARCHAR2,
			X_BOX7         IN OUT nocopy VARCHAR2,
			X_BOX8         IN OUT nocopy VARCHAR2,
			X_BOX9         IN OUT nocopy VARCHAR2,
			X_BOX10        IN OUT nocopy VARCHAR2) IS

TYPE character_data_table IS TABLE OF VARCHAR2(10) INDEX BY BINARY_INTEGER;

-- Local Variables
P_ret      VARCHAR2(1) := 'N';
P_User_Id  Number      := FND_PROFILE.Value('USER_ID');
P_login_id Number      := FND_PROFILE.Value('LOGIN_ID');
p_comp     VARCHAR2(1) := 'N';
l_fed_tax_type  character_data_table;
l_qbc_tax_type  character_data_table;
l_prv_tax_type  character_data_table;

procedure get_date_info(P_legislation_code   VARCHAR2 default 'CA',
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
			 P_taxability_rules_date_id number)
RETURN VARCHAR2 is
--
ret VARCHAR2(1) := 'N';
--
CURSOR csr_check is
       select 'Y'
       from   PAY_TAXABILITY_RULES PTR
       where  PTR.JURISDICTION_CODE = P_jurisdiction
       and    PTR.TAX_TYPE          = P_tax_type
       and    PTR.TAX_CATEGORY      = P_category
       and    PTR.CLASSIFICATION_ID = p_classification_id
       and    PTR.TAXABILITY_RULES_DATE_ID = p_taxability_rules_date_id;
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

PROCEDURE insert_rules(P_jurisdiction       VARCHAR2,
                      P_tax_type           VARCHAR2,
                      P_category           VARCHAR2,
		      P_classification_id  NUMBER,
		      P_taxability_rules_date_id NUMBER) IS
--
begin

  INSERT INTO pay_taxability_rules(
         JURISDICTION_CODE,
         TAX_TYPE,
         TAX_CATEGORY,
         classification_id,
	 TAXABILITY_RULES_DATE_ID,
         LEGISLATION_CODE,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN,
         CREATED_BY,
         CREATION_DATE)
  VALUES (
         P_jurisdiction,
         P_tax_type,
         P_category,
         P_classification_id,
	 P_taxability_rules_date_id,
	 'CA',
         SYSDATE,
         P_user_id,
         P_Login_Id,
         P_user_id,
         SYSDATE);
  IF SQL%NOTFOUND then
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE','pay_us_taxability_rules_pkg.insert');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
  end if;
--
END insert_rules;
--

PROCEDURE delete_rules(P_jurisdiction       VARCHAR2,
                      P_tax_type           VARCHAR2,
                      P_category           VARCHAR2,
		      p_classification_id  NUMBER,
		      P_taxability_rules_date_id NUMBER) IS
--
begin
  delete from pay_taxability_rules
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
--
END delete_rules;
--
--
-- MAIN PROCEDURE
begin
-- Set up the arrays with the tax types.

l_fed_tax_type(1) := 'FED';
l_fed_tax_type(2) := 'CPP';
l_fed_tax_type(3) := 'EIM';

l_prv_tax_type(1) := 'PRV';
l_prv_tax_type(2) := 'PPT';
l_prv_tax_type(3) := 'RSTI';
l_prv_tax_type(4) := 'PST';
l_prv_tax_type(5) := 'GST';
l_prv_tax_type(6) := 'HST';
l_prv_tax_type(7) := 'PMED';
l_prv_tax_type(8) := 'VAC';
l_prv_tax_type(9) := 'WCB';

l_qbc_tax_type(1) := 'PRV';
l_qbc_tax_type(2) := 'PPT';
l_qbc_tax_type(3) := 'RSTI';
l_qbc_tax_type(4) := 'GST';
l_qbc_tax_type(5) := 'QST';
l_qbc_tax_type(6) := 'QPP';
l_qbc_tax_type(7) := 'PMED';
l_qbc_tax_type(8) := 'VAC';
l_qbc_tax_type(9) := 'WCB';
l_qbc_tax_type(10):= 'PPIP';

  IF X_MODE = 'QUERY' then
     get_date_info(X_legislation_code, X_taxability_rules_date_id,
		   X_valid_date_from, X_valid_date_to, X_session_date);
     if X_CONTEXT = 'FEDERAL' then
        X_BOX1 := check_row_exist(X_jurisdiction,
                                  'FED',
                                  X_tax_cat,
				  X_classification_id,
				  X_taxability_rules_date_id);
        X_BOX2 := check_row_exist(X_jurisdiction,
                                  'CPP',
                                  X_tax_cat,
				  X_classification_id,
				  X_taxability_rules_date_id);
        X_BOX3 := check_row_exist(X_jurisdiction,
                                  'EIM',
                                  X_tax_cat,
				  X_classification_id,
				  X_taxability_rules_date_id);
     elsif X_CONTEXT = 'PROVINCE' then
        X_BOX1 := check_row_exist(substr(X_jurisdiction,1,2)||'-000-0000',
                                  'PRV',
                                  X_tax_cat,
				  X_classification_id,
				  X_taxability_rules_date_id);
        X_BOX2 := check_row_exist(substr(X_jurisdiction,1,2)||'-000-0000',
                                  'PPT',
                                  X_tax_cat,
				  X_classification_id,
				  X_taxability_rules_date_id);
        X_BOX3 := check_row_exist(substr(X_jurisdiction,1,2)||'-000-0000',
                                  'RSTI',
                                  X_tax_cat,
				  X_classification_id,
				  X_taxability_rules_date_id);
        X_BOX4 := check_row_exist(substr(X_jurisdiction,1,2)||'-000-0000',
                                  'PST',
                                  X_tax_cat,
				  X_classification_id,
				  X_taxability_rules_date_id);
        X_BOX5 := check_row_exist(substr(X_jurisdiction,1,2)||'-000-0000',
                                  'GST',
                                  X_tax_cat,
				  X_classification_id,
				  X_taxability_rules_date_id);
        X_BOX6 := check_row_exist(substr(X_jurisdiction,1,2)||'-000-0000',
                                  'HST',
                                  X_tax_cat,
                                  X_classification_id,
                                  X_taxability_rules_date_id);
	X_BOX7 := check_row_exist(substr(X_jurisdiction,1,2)||'-000-0000',
                                  'PMED',
                                  X_tax_cat,
                                  X_classification_id,
                                  X_taxability_rules_date_id);
	X_BOX8 := check_row_exist(substr(X_jurisdiction,1,2)||'-000-0000',
                                  'VAC',
                                  X_tax_cat,
                                  X_classification_id,
                                  X_taxability_rules_date_id);
        X_BOX9 := check_row_exist(substr(X_jurisdiction,1,2)||'-000-0000',
                                  'WCB',
                                  X_tax_cat,
                                  X_classification_id,
                                  X_taxability_rules_date_id);
     elsif X_CONTEXT = 'QUEBEC' then
        X_BOX1 := check_row_exist(substr(X_jurisdiction,1,2)||'-000-0000',
                                  'PRV',
                                  X_tax_cat,
                                  X_classification_id,
                                  X_taxability_rules_date_id);
        X_BOX2 := check_row_exist(substr(X_jurisdiction,1,2)||'-000-0000',
                                  'PPT',
                                  X_tax_cat,
                                  X_classification_id,
                                  X_taxability_rules_date_id);
        X_BOX3 := check_row_exist(substr(X_jurisdiction,1,2)||'-000-0000',
                                  'RSTI',
                                  X_tax_cat,
                                  X_classification_id,
                                  X_taxability_rules_date_id);
        X_BOX4 := check_row_exist(substr(X_jurisdiction,1,2)||'-000-0000',
                                  'GST',
                                  X_tax_cat,
                                  X_classification_id,
                                  X_taxability_rules_date_id);
        X_BOX5 := check_row_exist(substr(X_jurisdiction,1,2)||'-000-0000',
                                  'QST',
                                  X_tax_cat,
                                  X_classification_id,
                                  X_taxability_rules_date_id);
        X_BOX6 := check_row_exist(substr(X_jurisdiction,1,2)||'-000-0000',
                                  'QPP',
                                  X_tax_cat,
                                  X_classification_id,
                                  X_taxability_rules_date_id);
        X_BOX7 := check_row_exist(substr(X_jurisdiction,1,2)||'-000-0000',
                                  'PMED',
                                  X_tax_cat,
                                  X_classification_id,
                                  X_taxability_rules_date_id);
        X_BOX8 := check_row_exist(substr(X_jurisdiction,1,2)||'-000-0000',
                                  'VAC',
                                  X_tax_cat,
                                  X_classification_id,
                                  X_taxability_rules_date_id);
        X_BOX9 := check_row_exist(substr(X_jurisdiction,1,2)||'-000-0000',
                                  'WCB',
                                  X_tax_cat,
                                  X_classification_id,
                                  X_taxability_rules_date_id);
        X_BOX10 := check_row_exist(substr(X_jurisdiction,1,2)||'-000-0000',
                                  'PPIP',
                                  X_tax_cat,
                                  X_classification_id,
                                  X_taxability_rules_date_id);
     end if;
--
  elsif X_MODE = 'UPDATE' then
     P_User_Id  := FND_PROFILE.Value('USER_ID');
     P_Login_Id := FND_PROFILE.Value('LOGIN_ID');
     if X_taxability_rules_date_id IS NULL then
        select taxability_rules_date_id
	into   X_taxability_rules_date_id
        from   pay_taxability_rules_dates
        where  X_session_date between valid_date_from and valid_date_to
	and    legislation_code = X_legislation_code;
     end if;

     if X_CONTEXT = 'FEDERAL' then
      for i in 1..3 loop
        P_ret  := check_row_exist(X_jurisdiction,
                                  l_fed_tax_type(i),
                                  X_tax_cat,
				  X_classification_id,
				  X_taxability_rules_date_id);
	if i = 1 then
           p_comp := X_box1;
        elsif i = 2 then
	   p_comp := X_box2;
	else
	   p_comp := X_box3;
	end if;

        if P_ret = p_comp then
           null;
        elsif  P_ret = 'Y' and p_comp = 'N' then
           delete_rules(X_jurisdiction, l_fed_tax_type(i), X_tax_cat,
		        X_classification_id, X_taxability_rules_date_id);
        elsif  P_ret = 'N' and p_comp = 'Y' then
           insert_rules(X_jurisdiction,l_fed_tax_type(i), X_tax_cat,
			X_classification_id, X_taxability_rules_date_id);
        end if;
       end loop;
--
     elsif X_CONTEXT = 'PROVINCE' then
      for i in 1..9 loop
        P_ret  := check_row_exist(substr(X_jurisdiction,1,2)||'-000-0000',
                                  l_prv_tax_type(i),
                                  X_tax_cat,
                                  X_classification_id,
                                  X_taxability_rules_date_id);
        if i = 1 then
           p_comp := X_box1;
        elsif i = 2 then
           p_comp := X_box2;
	elsif i = 3 then
           p_comp := X_box3;
	elsif i = 4 then
           p_comp := X_box4;
	elsif i = 5 then
           p_comp := X_box5;
	elsif i = 6 then
           p_comp := X_box6;
	elsif i = 7 then
           p_comp := X_box7;
	elsif i = 8 then
           p_comp := X_box8;
        else
	   p_comp := X_box9;
        end if;

        if P_ret = p_comp then
           null;
        elsif  P_ret = 'Y' and p_comp = 'N' then
           delete_rules(substr(X_jurisdiction,1,2)||'-000-0000', l_prv_tax_type(i), X_tax_cat,
                        X_classification_id, X_taxability_rules_date_id);
        elsif  P_ret = 'N' and p_comp = 'Y' then
           insert_rules(substr(X_jurisdiction,1,2)||'-000-0000',l_prv_tax_type(i), X_tax_cat,
                        X_classification_id, X_taxability_rules_date_id);
        end if;
       end loop;
     elsif X_CONTEXT = 'QUEBEC' then
      for i in 1..10 loop
        P_ret  := check_row_exist(substr(X_jurisdiction,1,2)||'-000-0000',
                                  l_qbc_tax_type(i),
                                  X_tax_cat,
                                  X_classification_id,
                                  X_taxability_rules_date_id);
        if i = 1 then
           p_comp := X_box1;
        elsif i = 2 then
           p_comp := X_box2;
        elsif i = 3 then
           p_comp := X_box3;
        elsif i = 4 then
           p_comp := X_box4;
        elsif i = 5 then
           p_comp := X_box5;
        elsif i = 6 then
           p_comp := X_box6;
        elsif i = 7 then
           p_comp := X_box7;
        elsif i = 8 then
           p_comp := X_box8;
	elsif i = 9 then
	   p_comp := X_box9;
	else
	   p_comp := X_box10;
        end if;

        if P_ret = p_comp then
           null;
        elsif  P_ret = 'Y' and p_comp = 'N' then
           delete_rules(substr(X_jurisdiction,1,2)||'-000-0000', l_qbc_tax_type(i), X_tax_cat,
                        X_classification_id, X_taxability_rules_date_id);
        elsif  P_ret = 'N' and p_comp = 'Y' then
           insert_rules(substr(X_jurisdiction,1,2)||'-000-0000',l_qbc_tax_type(i), X_tax_cat,
                        X_classification_id, X_taxability_rules_date_id);
        end if;
       end loop;
--
     end if;
--
  end if;
--
END get_or_update;
--
--
--
FUNCTION get_classification_id (p_classification_name VARCHAR2) RETURN NUMBER IS
--
-- declare cursor
--
CURSOR get_class_id IS
SELECT classification_id
FROM   pay_element_classifications
WHERE  classification_name = p_classification_name
AND    legislation_code = 'CA';
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
--
END pay_ca_taxability_rules_pkg;

/
