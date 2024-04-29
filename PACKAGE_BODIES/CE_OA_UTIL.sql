--------------------------------------------------------
--  DDL for Package Body CE_OA_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_OA_UTIL" AS
/* $Header: ceoautlb.pls 120.0 2004/06/21 21:51:55 bhchung ship $ */

FUNCTION XTR_USER(X_user_id number) RETURN VARCHAR2 IS
  l_cnt 	number;
BEGIN
  select count(1)
  into   l_cnt
  from   xtr_dealer_codes
  where  user_id = X_user_id;

  if l_cnt = 0 then
    return 'N';
  else
    return 'Y';
  end if;
END XTR_USER;

FUNCTION IS_INSTALLED(X_prod_id number) RETURN VARCHAR2 IS
  l_temp	BOOLEAN;
  l_status	VARCHAR2(1);
  l_dummy	VARCHAR2(100);
BEGIN
  l_temp := FND_INSTALLATION.get(X_prod_id, X_prod_id, l_status, l_dummy);
  if (l_status = 'I' or l_status = 'S') then
    return 'Y';
  else
    return 'N';
  end if;
END IS_INSTALLED;

END CE_OA_UTIL;

/
