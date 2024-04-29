--------------------------------------------------------
--  DDL for Package Body PER_KR_VALIDATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_KR_VALIDATIONS_PKG" as
/* $Header: pekrvald.pkb 120.0 2005/05/31 11:10:07 appldev noship $ */
FUNCTION check_kr_ni
(
  p_national_identifier  IN VARCHAR2
 ,p_gender               IN VARCHAR2
 ,p_date_format          IN VARCHAR2
) RETURN VARCHAR2
IS
  l_return_value  VARCHAR2(255);
  l_gender_digit  VARCHAR2(1);
  l_dummy         DATE;
BEGIN
  --
  l_dummy        := to_date(substr(p_national_identifier, 1, 6), p_date_format);
  l_gender_digit := mod(substr(p_national_identifier, 8, 1), 2);
  --
  if not
  ( ( p_gender = 'M' and l_gender_digit = 1 )
      or
    ( p_gender = 'F' and l_gender_digit = 0 )
  )
    then l_return_value := 'INVALID_ID';
  else
    l_return_value := p_national_identifier;
  end if;
  return l_return_value;
EXCEPTION
  WHEN OTHERS THEN
    l_return_value := 'INVALID_ID';
    return l_return_value;
--
END check_kr_ni;
--
END per_kr_validations_pkg;

/
