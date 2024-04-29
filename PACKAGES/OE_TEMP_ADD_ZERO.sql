--------------------------------------------------------
--  DDL for Package OE_TEMP_ADD_ZERO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_TEMP_ADD_ZERO" AUTHID CURRENT_USER as
/* $Header: OEXUPSTS.pls 120.0 2005/10/19 14:23:44 spagadal noship $ */
--
-- Package
--   OE_TEMP_ADD_ZERO
-- Purpose
--  New package for running script oeupstl.sql

-- History
--   04-FEB-99	WSWANG	Created

    FUNCTION oe_add_zero ( in_string in VARCHAR2) return VARCHAR2;


END OE_TEMP_ADD_ZERO;

 

/
