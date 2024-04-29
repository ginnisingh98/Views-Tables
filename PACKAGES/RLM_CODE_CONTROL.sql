--------------------------------------------------------
--  DDL for Package RLM_CODE_CONTROL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RLM_CODE_CONTROL" AUTHID CURRENT_USER as
/* $Header: RLMCDCRS.pls 120.1 2005/08/15 16:16:37 rlanka noship $ */

   CODE_RELEASE_LEVEL       varchar2(10) := '120000';

   Function Get_Code_Release_Level return varchar2;

End RLM_CODE_CONTROL;

 

/
