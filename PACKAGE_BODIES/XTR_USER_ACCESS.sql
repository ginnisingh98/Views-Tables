--------------------------------------------------------
--  DDL for Package Body XTR_USER_ACCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_USER_ACCESS" AS
/* $Header: xtruaccb.pls 120.1 2005/09/28 11:52:25 eaggarwa noship $ */

FUNCTION dealer_code RETURN xtr_dealer_codes.dealer_code%TYPE IS
  FUNCTION get_dealer_code RETURN xtr_dealer_codes.dealer_code%TYPE IS
    CURSOR c_get_dealer_code IS
    SELECT dealer_code
    FROM xtr_dealer_codes
    WHERE user_id = fnd_global.user_id;
  BEGIN
    if g_dealer_code is null then --4491268

    OPEN c_get_dealer_code;
    FETCH c_get_dealer_code INTO g_dealer_code;
    CLOSE c_get_dealer_code;

    end if;

    RETURN g_dealer_code;
  END get_dealer_code;
BEGIN

  /* This is cauing problem in OA FWk related pages
     Please see bug 3630670 for more info

     if (g_dealer_code is not null) then
       return g_dealer_code;
     else
       RETURN get_dealer_code;
     end if;
  */

  RETURN get_dealer_code;

END dealer_code;

END XTR_USER_ACCESS;

/
