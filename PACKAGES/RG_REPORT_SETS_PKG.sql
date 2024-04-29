--------------------------------------------------------
--  DDL for Package RG_REPORT_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RG_REPORT_SETS_PKG" AUTHID CURRENT_USER AS
/* $Header: rgirsets.pls 120.1 2003/04/29 01:29:33 djogg ship $ */

  -- NAME
  --   new_report_set_id
  --
  -- DESCRIPTION
  --   Get a new report set id from rg_report_sets_s
  --
  -- PARAMETERS
  --   *None*
  --

  FUNCTION new_report_set_id
                  RETURN        NUMBER;
  --
  -- NAME
  --   check_dup_report_set_name
  --
  -- DESCRIPTION
  --   Check whether new_name already used by another report sets
  --   in the currenct application.
  --
  -- PARAMETERS
  -- 1. Current Application ID
  -- 2. Current Report Set ID
  -- 3. New report set name
  --

  FUNCTION check_dup_report_set_name(cur_application_id IN   NUMBER,
				     cur_report_set_id  IN   NUMBER,
				     new_name           IN   VARCHAR2)
                                     RETURN             BOOLEAN;

END rg_report_sets_pkg;

 

/
