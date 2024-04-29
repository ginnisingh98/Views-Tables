--------------------------------------------------------
--  DDL for Package Body INV_RELEASE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_RELEASE" AS
/* $Header: INVRELSEB.pls 120.0 2005/05/25 06:48:38 appldev noship $ */

--  Global constant holding the package name

G_PKG_NAME                    CONSTANT VARCHAR2(30) := 'INV_Release';

--  Function to return patchset I release level

   Function Get_I_Release_Level
   return number
   is
   Begin
      return INV_Release.G_I_RELEASE_LEVEL;
   End Get_I_Release_Level;


--  Function to return patchset J release level

   Function Get_J_Release_Level
   return number
   is
   Begin
      return INV_Release.G_J_RELEASE_LEVEL;
   End Get_J_Release_Level;


--  Function to return patchset K release level

   Function Get_K_Release_Level
   return number
   is
   Begin
      return INV_Release.G_K_RELEASE_LEVEL;
   End Get_K_Release_Level;


END INV_Release;

/
