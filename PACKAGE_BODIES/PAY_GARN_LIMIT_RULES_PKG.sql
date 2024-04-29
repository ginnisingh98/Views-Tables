--------------------------------------------------------
--  DDL for Package Body PAY_GARN_LIMIT_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_GARN_LIMIT_RULES_PKG" as
/* $Header: pyglr01t.pkb 115.0 99/07/17 06:08:42 porting ship $ */

  PROCEDURE pre_insert (x_limit_rule_id     IN OUT NUMBER)
   IS
      CURSOR C2 IS SELECT pay_us_garn_limit_rules_s.nextval FROM sys.dual;
  BEGIN
      if (X_Limit_Rule_Id is NULL) then
        OPEN C2;
        FETCH C2 INTO X_Limit_Rule_Id;
        CLOSE C2;
      end if;
  END pre_insert;

  PROCEDURE post_query( x_state_code                     VARCHAR2,
                        x_garn_category                  VARCHAR2,
                        x_state_name              IN OUT VARCHAR2,
                        x_garn_category_name      IN OUT VARCHAR2
) IS
    l_state_name               pay_state_rules.name%TYPE;
    l_lookup_type              hr_lookups.lookup_type%TYPE;
    l_lookup_code              hr_lookups.lookup_code%TYPE;
    l_meaning                  hr_lookups.meaning%TYPE;

    CURSOR state_c IS
     SELECT name
     FROM   pay_state_rules
     WHERE  substr(jurisdiction_code, 1, 2) = x_state_code;

    CURSOR lookup_c IS
     SELECT meaning
     FROM   hr_lookups
     WHERE  lookup_type = l_lookup_type
     AND    lookup_code = l_lookup_code;

  BEGIN
    IF x_state_code IS NOT NULL THEN
      OPEN state_c;
      FETCH state_c INTO l_state_name;
      IF state_c%NOTFOUND THEN
        CLOSE state_c;
        RAISE no_data_found;
      ELSE
        x_state_name := l_state_name;
        CLOSE state_c;
      END IF;
    END IF;
    IF x_garn_category IS NOT NULL THEN
      l_lookup_type := 'US_GARN_EXMPT_CAT';
      l_lookup_code := x_garn_category;
      OPEN lookup_c;
      FETCH lookup_c INTO l_meaning;
      IF lookup_c%NOTFOUND THEN
        CLOSE lookup_c;
        RAISE no_data_found;
      ELSE
        x_garn_category_name := l_meaning;
        CLOSE lookup_c;
      END IF;
    END IF;
  EXCEPTION WHEN no_data_found THEN
    APP_EXCEPTION.RAISE_EXCEPTION;
  END post_query;

  PROCEDURE Check_Unique( X_State_Code                     VARCHAR2,
                          X_Garn_Category                  VARCHAR2
  ) IS
    esd DATE;
  BEGIN
     SELECT  MIN(effective_start_date)
     INTO    esd
     FROM    pay_us_garn_limit_rules_f
     WHERE   state_code = X_State_Code
     AND     GARN_CATEGORY = X_Garn_Category;
     IF (esd IS NOT NULL) then
         hr_utility.set_message(801, 'PAY_51780_GER_CHK_UNI_W_DATE');
         fnd_message.set_token('1',esd);
         hr_utility.raise_error;
     END IF;
  END check_unique;

END;

/
