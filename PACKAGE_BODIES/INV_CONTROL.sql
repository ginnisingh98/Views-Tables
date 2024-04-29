--------------------------------------------------------
--  DDL for Package Body INV_CONTROL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_CONTROL" as
/* $Header: INVCNTRLB.pls 115.2 2003/07/19 01:12:02 ssia noship $ */
   Function Get_Current_Release_Level
   return number
   is
   Begin
      return INV_CONTROL.G_CURRENT_RELEASE_LEVEL;
   End Get_Current_Release_Level;

End INV_CONTROL;

/
