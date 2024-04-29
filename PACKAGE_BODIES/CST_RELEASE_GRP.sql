--------------------------------------------------------
--  DDL for Package Body CST_RELEASE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_RELEASE_GRP" AS
/* $Header: CSTFPRVB.pls 115.0 2003/08/18 05:00:55 anjgupta noship $ */

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'CST_Release_GRP';

--  Function to return patchset I release level

   Function Get_I_Release_Level
   return number
   is
   Begin
      return CST_Release_GRP.G_I_RELEASE_LEVEL;
   End Get_I_Release_Level;


--  Function to return patchset J release level

   Function Get_J_Release_Level
   return number
   is
   Begin
      return CST_Release_GRP.G_J_RELEASE_LEVEL;
   End Get_J_Release_Level;

End CST_Release_GRP;

/
