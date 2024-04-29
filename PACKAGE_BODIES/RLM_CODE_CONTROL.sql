--------------------------------------------------------
--  DDL for Package Body RLM_CODE_CONTROL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RLM_CODE_CONTROL" as
/* $Header: RLMCDCRB.pls 115.0 2002/12/31 21:24:37 rlanka noship $ */

   Function Get_Code_Release_Level
   return varchar2
   is
   Begin
      return RLM_CODE_CONTROL.CODE_RELEASE_LEVEL;
   End Get_Code_Release_Level;

End RLM_CODE_CONTROL;

/
