--------------------------------------------------------
--  DDL for Package Body HZ_PHONE_NUMBER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_PHONE_NUMBER_PKG" AS
/*$Header: ARHPHNMB.pls 120.3 2005/09/01 19:30:56 achung noship $ */

FUNCTION transpose (
        p_phone_number  IN      VARCHAR2)
RETURN VARCHAR2 IS
  l_filtered_number     VARCHAR2(2000);
  l_ret_number  VARCHAR2(2000);
  l_changed_number  VARCHAR2(2000);

BEGIN

  l_filtered_number := translate(
    p_phone_number,
    '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz()- .+''~`\/@#$%^&*_,|}{[]?<>=";:',
    '01234567892223334445556667777888999922233344455566677778889999');

  IF l_filtered_number IS NULL OR l_filtered_number='' THEN
    RETURN NULL;
  END IF;
  IF length(l_filtered_number) > 0 THEN
    FOR I IN REVERSE 1..length(l_filtered_number) LOOP
      l_ret_number := l_ret_number || substr(l_filtered_number,I,1);
    END LOOP;
/*    FOR I IN 1..length(l_ret_number) LOOP
        l_filtered_number := substr(l_ret_number,I,1);
        select decode(upper(l_filtered_number),'A','2','B','2','C','2',
                                          'D','3','E','3','F','3',
                                          'G','4','H','4','I','4',
                                          'J','5','K','5','L','5',
                                          'M','6','N','6','O','6',
                                          'P','7','Q','7','R','7','S','7',
                                          'T','8','U','8','V','8',
                                          'W','9','X','9','Y','9','Z','9',l_filtered_number) into l_filtered_number from dual;
        l_changed_number := l_changed_number||l_filtered_number;

    END LOOP;
    l_ret_number := l_changed_number;
*/  END IF;

  RETURN l_ret_number;
END transpose;

END HZ_PHONE_NUMBER_PKG;

/
