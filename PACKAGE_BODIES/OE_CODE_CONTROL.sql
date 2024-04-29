--------------------------------------------------------
--  DDL for Package Body OE_CODE_CONTROL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_CODE_CONTROL" as
/* $Header: OEXCRCNB.pls 120.0.12000000.1 2007/01/16 21:48:05 appldev ship $ */

   Function Get_Code_Release_Level
   return varchar2
   is
   Begin
      return OE_CODE_CONTROL.CODE_RELEASE_LEVEL;
   End Get_Code_Release_Level;

End OE_CODE_CONTROL;

/
