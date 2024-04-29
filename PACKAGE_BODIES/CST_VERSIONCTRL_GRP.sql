--------------------------------------------------------
--  DDL for Package Body CST_VERSIONCTRL_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_VERSIONCTRL_GRP" AS
/* $Header: CSTFVERB.pls 115.0 2003/08/15 23:25:51 anjgupta noship $*/


G_PKG_NAME     CONSTANT VARCHAR2(30) := 'CST_VersionCtrl_GRP';

Function Get_Current_Release_Level
   return number
   is
   Begin
      return CST_VersionCtrl_GRP.G_CURRENT_RELEASE_LEVEL;
   End Get_Current_Release_Level;

End CST_VersionCtrl_GRP;


/
