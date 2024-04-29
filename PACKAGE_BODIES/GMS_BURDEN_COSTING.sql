--------------------------------------------------------
--  DDL for Package Body GMS_BURDEN_COSTING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_BURDEN_COSTING" AS
/* $Header: gmscbcab.pls 120.1 2005/07/26 14:21:33 appldev ship $ */

-- Global variables/cursors used within the package   --

current_project_id  pa_projects_all.project_id%type;
------------------------------------------------------------------

-- Procedure to set the current project_id in package variable
PROCEDURE set_current_project_id(x_project_id in number) IS
current_project_id number(15);
BEGIN
  current_project_id := x_project_id;
END set_current_project_id;

------------------------------------------------------------------

-- Procedure to get the current project_id in package variable
FUNCTION get_current_project_id RETURN NUMBER IS
BEGIN
  return current_project_id;
END get_current_project_id;

------------------------------------------------------------------
END  GMS_BURDEN_COSTING;

/
