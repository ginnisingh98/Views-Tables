--------------------------------------------------------
--  DDL for Package Body PON_LANGUAGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_LANGUAGE_PKG" as
/*$Header: PONLANGB.pls 120.0 2005/06/01 18:29:25 appldev noship $ */

PROCEDURE retrieve_enabled_languages (
x_languages     OUT NOCOPY refCurTyp
, x_status        OUT NOCOPY VARCHAR2
, x_exception_msg OUT NOCOPY VARCHAR2
)
IS
BEGIN
  OPEN x_languages FOR
    select language_code
    from fnd_languages
    where installed_flag in ('I','B')
    order by language_code;
  x_status := 'S';
EXCEPTION
  WHEN OTHERS THEN
    x_status := 'E';
END retrieve_enabled_languages;

END PON_LANGUAGE_PKG;

/
