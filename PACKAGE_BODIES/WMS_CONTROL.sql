--------------------------------------------------------
--  DDL for Package Body WMS_CONTROL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_CONTROL" as
/* $Header: WMSCNTRLB.pls 115.2 2003/07/21 17:30:48 mjuneja noship $ */

   Function Get_Current_Release_Level
   return number
   is
   Begin
      return WMS_CONTROL.G_CURRENT_RELEASE_LEVEL;
   End Get_Current_Release_Level;

End WMS_CONTROL;

/
