--------------------------------------------------------
--  DDL for Package Body PAY_US_TAXABILITY_RULES_PKG_F
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_TAXABILITY_RULES_PKG_F" as
/* $Header: pydia01t.pkb 120.0 2005/05/29 04:18:58 appldev noship $ */
--
PROCEDURE get_or_update(X_MODE                      VARCHAR2,
                        X_CONTEXT                   VARCHAR2,
                        X_JURISDICTION              VARCHAR2,
                        X_TAX_CAT                   VARCHAR2,
                        X_classification_id         NUMBER,
                        X_BOX1        IN OUT NOCOPY VARCHAR2,
                        X_BOX2        IN OUT NOCOPY VARCHAR2,
                        X_BOX3        IN OUT NOCOPY VARCHAR2) IS
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


FUNCTION check_row_exist(P_jurisdiction               VARCHAR2,
                         P_tax_type                   VARCHAR2,
                         P_category                   VARCHAR2,
                         P_classification_id          NUMBER,
                         P_taxability_rules_date_id   NUMBER)
RETURN VARCHAR2 is
--
ret VARCHAR2(1) := 'N';
--
CURSOR csr_check is
       select 'Y'
       from   PAY_TAXABILITY_RULES
       where  JURISDICTION_CODE        = P_jurisdiction
       and    TAX_TYPE                 = P_tax_type
       and    TAX_CATEGORY             = P_category
       and    CLASSIFICATION_ID        = p_classification_id
       and    TAXABILITY_RULES_DATE_ID = p_taxability_rules_date_id
       and    LEGISLATION_CODE         = 'US'
       and    nvl(STATUS,'VALID') <> 'D';
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
FUNCTION insert_rules(P_jurisdiction               VARCHAR2,
                      P_tax_type                   VARCHAR2,
                      P_category                   VARCHAR2,
                      P_classification_id          NUMBER,
                      P_taxability_rules_date_id   NUMBER)
RETURN NUMBER IS
--
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
            'US',
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
   end if;
--
  RETURN ret;
--
END insert_rules;
--
FUNCTION delete_rules(P_jurisdiction               VARCHAR2,
                      P_tax_type                   VARCHAR2,
                      P_category                   VARCHAR2,
                      p_classification_id          NUMBER,
                      p_taxability_rules_date_id   NUMBER)
RETURN NUMBER IS
--
ret number := 0;
begin
  update pay_taxability_rules
    set  status = 'D'
  where jurisdiction_code        = P_jurisdiction
  and   tax_type                 = P_tax_type
  and   tax_category             = P_category
  and   classification_id        = p_classification_id
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
FUNCTION chk_mutually_exclusive (p_jurisdiction_code  VARCHAR2,
                                 p_tax_category       VARCHAR2,
                                 p_tax_type           VARCHAR2,
                                 p_classification_id  NUMBER )
RETURN BOOLEAN IS
--
-- declare local cursor
--
CURSOR get_other_rule IS
SELECT   'Y'
FROM  pay_taxability_rules
WHERE jurisdiction_code = p_jurisdiction_code
AND   tax_type    = p_tax_type
AND   classification_id = p_classification_id
AND   tax_category      <> p_tax_category
AND   legislation_code = 'US';
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
      get_date_info(P_legislation_code ,
                      P_taxability_rules_date_id,
                      P_valid_date_from,
                      P_valid_date_to);

   IF X_MODE = 'QUERY' then


      X_BOX1 := check_row_exist(X_jurisdiction,
                                'CSDI',
                                X_tax_cat,
                                X_classification_id,
                                p_taxability_rules_date_id);
      X_BOX2 := check_row_exist(X_jurisdiction,
                                'GDI',
                                X_tax_cat,
                                X_classification_id,
                                p_taxability_rules_date_id);
      X_BOX3 := check_row_exist(X_jurisdiction,
                                'DCIA',
                                X_tax_cat,
                                X_classification_id,
                                p_taxability_rules_date_id);
      --
   elsif X_MODE = 'UPDATE' then
      P_User_Id  := FND_PROFILE.Value('USER_ID');
      P_Login_Id := FND_PROFILE.Value('LOGIN_ID');

      SELECT taxability_rules_date_id
        INTO p_taxability_rules_date_id
        FROM pay_taxability_rules_dates
       WHERE sysdate between valid_date_from and valid_date_to
         AND legislation_code = p_legislation_code;

      P_ret  := check_row_exist(X_jurisdiction,
                                'CSDI',
                                X_tax_cat,
                                X_classification_id,
                                p_taxability_rules_date_id);
      if P_ret = X_box1 then
         null;
      elsif  P_ret = 'Y' and X_box1 = 'N' then
         P_i := delete_rules(X_jurisdiction,'CSDI',X_tax_cat, X_classification_id, p_taxability_rules_date_id);
      elsif  P_ret = 'N' and X_box1 = 'Y' then
         P_i := insert_rules(X_jurisdiction,'CSDI',X_tax_cat, X_classification_id, p_taxability_rules_date_id);
      end if;
--
      P_ret := check_row_exist(X_jurisdiction,
                               'GDI',
                               X_tax_cat,
                               X_classification_id,
                               p_taxability_rules_date_id);
      if P_ret = X_box2 then
         null;
      elsif  P_ret = 'Y' and X_box2 = 'N' then
         P_i := delete_rules(X_jurisdiction,'GDI',X_tax_cat, X_classification_id, p_taxability_rules_date_id);
      elsif  P_ret = 'N' and X_box2 = 'Y' then
         P_i := insert_rules(X_jurisdiction,'GDI',X_tax_cat, X_classification_id, p_taxability_rules_date_id);
      end if;

      P_ret := check_row_exist(X_jurisdiction,
                               'DCIA',
                               X_tax_cat,
                               X_classification_id,
                               p_taxability_rules_date_id);
      if P_ret = X_box3 then
         null;
      elsif  P_ret = 'Y' and X_box3 = 'N' then
         P_i := delete_rules(X_jurisdiction,'DCIA',X_tax_cat, X_classification_id, p_taxability_rules_date_id);
      elsif  P_ret = 'N' and X_box3 = 'Y' then
         P_i := insert_rules(X_jurisdiction,'DCIA',X_tax_cat, X_classification_id, p_taxability_rules_date_id);
      end if;

--
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
FROM   pay_element_classifications pec
WHERE  pec.classification_name = p_classification_name
AND    pec.legislation_code = 'US';
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
END pay_us_taxability_rules_pkg_f;

/
