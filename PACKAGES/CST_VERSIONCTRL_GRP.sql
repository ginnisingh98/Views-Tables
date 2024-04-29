--------------------------------------------------------
--  DDL for Package CST_VERSIONCTRL_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_VERSIONCTRL_GRP" AUTHID CURRENT_USER AS
/* $Header: CSTFVERS.pls 115.1 2003/09/04 20:59:09 anjgupta noship $*/

   G_CURRENT_RELEASE_LEVEL       number := 110510;

   Function Get_Current_Release_Level return number;

End CST_VersionCtrl_GRP;

 

/
