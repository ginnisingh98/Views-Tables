--------------------------------------------------------
--  DDL for Package Body POS_PASSWORD_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_PASSWORD_UTIL_PKG" AS
/*$Header: POSPWUTB.pls 120.1.12010000.2 2009/02/26 07:45:11 dashah ship $ */

--
-- private function that removes adjacent repeating characters in a string
--
FUNCTION remove_repeating_char(
  p_string IN VARCHAR2
) RETURN VARCHAR2
IS
lv_string VARCHAR2(3000);
ln_counter NUMBER;
BEGIN
  IF p_string IS NOT NULL THEN
    ln_counter := 1;
    lv_string := p_string;
    WHILE ln_counter < length(lv_string) LOOP
      IF substr(lv_string, ln_counter+1, 1) = substr(lv_string, ln_counter, 1) THEN
        lv_string := substr(lv_string, 1, ln_counter) || substr(lv_string, ln_counter+2);
      ELSE
	ln_counter := ln_counter + 1;
      END IF;
    END LOOP;
    RETURN lv_string;
  END IF;
  RETURN NULL;
END remove_repeating_char;

FUNCTION generate_user_pwd
RETURN VARCHAR2
IS

lv_pwd VARCHAR2(200);
lv_status VARCHAR2(30);

lv_signon_pwd_length fnd_profile_option_values.profile_option_value%TYPE;
lv_signon_pwd_hardguess fnd_profile_option_values.profile_option_value%TYPE;
ln_pwd_length NUMBER := 5;
ln_tmp_str varchar2(255);

BEGIN

  lv_signon_pwd_length := fnd_profile.value('SIGNON_PASSWORD_LENGTH');

  IF lv_signon_pwd_length IS NOT NULL THEN
    BEGIN
      ln_pwd_length := to_number(lv_signon_pwd_length);
    EXCEPTION
      WHEN OTHERS THEN
	ln_pwd_length := 5;
    END;
  END IF;
 /*As part of fix 8288119 : changes foward ported from 11i Bugs 5599028,7257014*/
  ln_tmp_str := nchr(mod(fnd_crypto.smallrandomnumber(),26)+65) ||
                       nchr(mod(fnd_crypto.smallrandomnumber(),26)+97) ||
                       mod(fnd_crypto.smallrandomnumber(),10) ||
                       substr('%,^!#$*()-_+;:,|?', mod(fnd_crypto.smallrandomnumber(), 17), 1) ;
  lv_pwd := substr(remove_repeating_char(ln_tmp_str || substr(icx_call.encrypt(fnd_crypto.smallrandomnumber), 4)), 1, ln_pwd_length+1);

   /*As part of fix 8288119 : changes foward ported from 11i Bugs 5599028,7257014*/


  -- just in case the previous encryption has too many repetitive charaters
  WHILE length(lv_pwd) < ln_pwd_length LOOP
    lv_pwd := lv_pwd || lv_pwd;
  END LOOP;

  RETURN lv_pwd;

END generate_user_pwd;


END POS_PASSWORD_UTIL_PKG;

/
