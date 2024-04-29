--------------------------------------------------------
--  DDL for Package INV_RELEASE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_RELEASE" AUTHID CURRENT_USER AS
  /* $Header: INVRELSES.pls 120.0 2005/05/25 04:48:54 appldev noship $ */

  --  Release Levels

  G_I_Release_Level            CONSTANT NUMBER            := 110509;
  G_J_Release_Level            CONSTANT NUMBER            := 110510;
  G_K_Release_Level            CONSTANT NUMBER            := 110511;

  Function Get_I_Release_Level return number;

  Function Get_J_Release_Level return number;

  Function Get_K_Release_Level return number;

END INV_RELEASE;

 

/
