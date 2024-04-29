--------------------------------------------------------
--  DDL for Package FND_NUMBER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_NUMBER" AUTHID CURRENT_USER as
/* $Header: AFNUMBRS.pls 115.8 2002/03/01 13:49:48 pkm ship     $ */


  canonical_mask    varchar2(100);
  decimal_char      VARCHAR2(1);
  group_separator   VARCHAR2(1);

--
-- Canonical functions
--
  function canonical_to_number(
    canonical varchar2)
  return number;
  PRAGMA restrict_references(canonical_to_number, WNDS, WNPS, RNDS);

  function number_to_canonical(
    numberval number)
  return varchar2;
  PRAGMA restrict_references(number_to_canonical, WNDS, WNPS, RNDS);

-- Test procedure - used to verify functionality
  procedure test;

  procedure initialize;

end FND_NUMBER;

 

/
