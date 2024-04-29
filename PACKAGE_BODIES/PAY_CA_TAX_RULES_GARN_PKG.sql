--------------------------------------------------------
--  DDL for Package Body PAY_CA_TAX_RULES_GARN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_TAX_RULES_GARN_PKG" as
/* $Header: pycadiat.pkb 120.1 2005/10/05 22:01:39 saurgupt noship $ */
--
PROCEDURE get_or_update(X_MODE                VARCHAR2,
                        X_CONTEXT             VARCHAR2,
                        X_JURISDICTION        VARCHAR2,
                        X_TAX_CAT             VARCHAR2,
			X_classification_id   NUMBER,
                        X_legislation_code    VARCHAR2,
                        X_taxability_rules_date_id   out nocopy NUMBER,
                        X_valid_date_from       in out nocopy DATE,
                        X_valid_date_to       in out nocopy DATE,
                        X_session_date          DATE,
                        X_BOX1         IN OUT nocopy VARCHAR2,
                        X_BOX2         IN OUT nocopy VARCHAR2) IS
-- Local Variables
P_ret      VARCHAR2(1) := 'N';
P_User_Id  Number      := FND_PROFILE.Value('USER_ID');
P_login_id Number      := FND_PROFILE.Value('LOGIN_ID');
P_i        Number      := 0;
l_jurisdiction VARCHAR2(11);

procedure get_date_info(P_legislation_code   VARCHAR2,
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
       from   PAY_TAXABILITY_RULES
       where  JURISDICTION_CODE = P_jurisdiction
       and    TAX_TYPE          = P_tax_type
       and    TAX_CATEGORY      = P_category
       and    CLASSIFICATION_ID = p_classification_id
       and    TAXABILITY_RULES_DATE_ID = p_taxability_rules_date_id;

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
                       P_taxability_rules_date_id NUMBER,
		       P_legislation_code   VARCHAR2) IS
--
begin
  INSERT INTO pay_taxability_rules(
         JURISDICTION_CODE,
         TAX_TYPE,
         TAX_CATEGORY,
         CLASSIFICATION_ID,
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
         P_legislation_code,
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
		       P_classification_id  NUMBER,
                       P_taxability_rules_date_id NUMBER,
                       P_legislation_code   VARCHAR2) IS
--
begin
  delete from pay_taxability_rules
  where jurisdiction_code = P_jurisdiction
  and   tax_type          = P_tax_type
  and   tax_category      = P_category
  and   classification_id = p_classification_id
  and   taxability_rules_date_id = P_taxability_rules_date_id
  and   legislation_code = P_legislation_code;

  IF SQL%NOTFOUND then
     hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
     hr_utility.set_message_token('PROCEDURE','pay_us_taxability_rules_pkg.delete');
     hr_utility.set_message_token('STEP','1');
     hr_utility.raise_error;
  end if;
--
END delete_rules;
--
--
--
-- MAIN PROCEDURE
begin
l_jurisdiction := substr(X_jurisdiction,1,2)||'-000-0000';

  IF X_MODE = 'QUERY' then
     get_date_info(X_legislation_code, X_taxability_rules_date_id,
                   X_valid_date_from, X_valid_date_to, X_session_date);
        X_BOX1 := check_row_exist(l_jurisdiction,
                                  'CSDI',
                                  X_tax_cat,
				  X_classification_id,
				  X_taxability_rules_date_id);
        X_BOX2 := check_row_exist(l_jurisdiction,
                                  'GDI',
                                  X_tax_cat,
				  X_classification_id,
				  X_taxability_rules_date_id);
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

        P_ret  := check_row_exist(l_jurisdiction,
                                  'CSDI',
                                  X_tax_cat,
				  X_classification_id,
				  X_taxability_rules_date_id);
        if P_ret = X_box1 then
           null;
        elsif  P_ret = 'Y' and X_box1 = 'N' then
           delete_rules(l_jurisdiction,'CSDI',X_tax_cat, X_classification_id,
			X_taxability_rules_date_id, X_legislation_code);
        elsif  P_ret = 'N' and X_box1 = 'Y' then
           insert_rules(l_jurisdiction,'CSDI',X_tax_cat, X_classification_id,
			X_taxability_rules_date_id, X_legislation_code);
        end if;
--
        P_ret := check_row_exist(l_jurisdiction,
                                  'GDI',
                                  X_tax_cat,
				  X_classification_id,
				  X_taxability_rules_date_id);
        if P_ret = X_box2 then
           null;
        elsif  P_ret = 'Y' and X_box2 = 'N' then
           delete_rules(l_jurisdiction,'GDI',X_tax_cat, X_classification_id,
			X_taxability_rules_date_id, X_legislation_code);
        elsif  P_ret = 'N' and X_box2 = 'Y' then
           insert_rules(l_jurisdiction,'GDI',X_tax_cat, X_classification_id,
			X_taxability_rules_date_id, X_legislation_code);
        end if;
--
--
  end if;
--
END get_or_update;
--
--
-- Function to get the classification id.
--
FUNCTION get_classification_id (p_classification_name VARCHAR2,
				p_legislation_code VARCHAR2) RETURN NUMBER IS
--
-- declare cursor
--
CURSOR get_class_id IS
SELECT classification_id
FROM   pay_element_classifications
WHERE  classification_name = p_classification_name
AND    legislation_code = p_legislation_code;
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
END pay_ca_tax_rules_garn_pkg;

/
