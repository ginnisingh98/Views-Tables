--------------------------------------------------------
--  DDL for Package QP_NUMBER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_NUMBER" AUTHID CURRENT_USER as
/* $Header: QPNUMBRS.pls 120.0 2005/06/02 00:46:32 appldev noship $ */


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

end QP_NUMBER;

 

/
