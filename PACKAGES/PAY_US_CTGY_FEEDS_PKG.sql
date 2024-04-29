--------------------------------------------------------
--  DDL for Package PAY_US_CTGY_FEEDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_CTGY_FEEDS_PKG" AUTHID CURRENT_USER as
/* $Header: pyusctgf.pkh 115.0 99/07/17 06:42:24 porting ship $ */
--
--
/*
--
-- Copyright (c) Oracle Corporation 1991, 1992, 1993. All rights reserved.
--
/*
   NAME
      pyusctgf.pkh
--
   DESCRIPTION
      See description in pyusctgf.pkb
--
  MODIFIED (DD-MON-YYYY)
  S Panwar   6-FEB-1995      Created
  S Panwar   4-MAY-1995      Removed default on p_date
*/
--
-- Typedefs
--
TYPE text_table IS TABLE OF VARCHAR2(50) INDEX BY BINARY_INTEGER;
--
-- Procedures
--
PROCEDURE create_category_feeds (p_element_type_id    NUMBER,
                                 p_date   DATE);
--
end pay_us_ctgy_feeds_pkg;

 

/
