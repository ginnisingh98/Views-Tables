--------------------------------------------------------
--  DDL for Package CST_RELEASE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_RELEASE_GRP" AUTHID CURRENT_USER AS
/* $Header: CSTFPRVS.pls 115.1 2003/08/18 19:09:04 anjgupta noship $ */


  G_I_Release_Level            CONSTANT NUMBER            := 110509;
  G_J_Release_Level            CONSTANT NUMBER            := 110510;

  Function Get_I_Release_Level return number;

  Function Get_J_Release_Level return number;


End CST_Release_GRP;

 

/
