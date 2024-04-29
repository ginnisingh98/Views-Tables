--------------------------------------------------------
--  DDL for Package POS_GLOBAL_VARS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_GLOBAL_VARS_SV" AUTHID CURRENT_USER AS
/* $Header: POSMESGS.pls 115.0 99/08/20 11:09:51 porting sh $*/

  /* InitializeMessageArray
   * ----------------------
   */
  PROCEDURE InitializeMessageArray;

  /* InitializeOtherVars
   * -------------------
   */
  PROCEDURE InitializeOtherVars(p_scriptName VARCHAR2);


END POS_GLOBAL_VARS_SV;

 

/
