--------------------------------------------------------
--  DDL for Package Body OE_TEMP_ADD_ZERO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_TEMP_ADD_ZERO" as
/* $Header: OEXUPSTB.pls 120.0 2005/10/19 14:24:15 spagadal noship $ */
--
-- Package
--   OE_TEMP_ADD_ZERO
-- Purpose
--  New package for running script oeupstl.sql

-- History
--   04-FEB-99	WSWANG	Created

FUNCTION oe_add_zero ( in_string in VARCHAR2) return VARCHAR2
is
  l_out_string varchar2(240) := null;
  i number := 0;
  l_upper_boundary number := 0;
begin
  l_upper_boundary := length(in_string)/3;

  for i in 1..l_upper_boundary loop
    l_out_string := l_out_string || '0' || substr(in_string, 3*i-2, 3);
  end loop;

  return(l_out_string);
end oe_add_zero;
END OE_TEMP_ADD_ZERO;

/
