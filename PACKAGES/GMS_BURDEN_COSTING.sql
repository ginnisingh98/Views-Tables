--------------------------------------------------------
--  DDL for Package GMS_BURDEN_COSTING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_BURDEN_COSTING" AUTHID CURRENT_USER as
-- /* $Header: gmscbcas.pls 120.1 2005/07/26 14:21:36 appldev ship $ */

-- Package holds all the burden cost accounting functions and procedures

   -- Procedure to update the current project_id in package variable
   PROCEDURE set_current_project_id(x_project_id in number);
   PRAGMA RESTRICT_REFERENCES(set_current_project_id, WNDS);

   -- function to retrive the current project id
   FUNCTION get_current_project_id RETURN NUMBER;
   PRAGMA RESTRICT_REFERENCES(get_current_project_id, WNDS, WNPS);

end GMS_BURDEN_COSTING;

 

/
