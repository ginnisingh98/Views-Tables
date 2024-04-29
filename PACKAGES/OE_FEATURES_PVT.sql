--------------------------------------------------------
--  DDL for Package OE_FEATURES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_FEATURES_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVNEWS.pls 120.0 2005/06/01 00:08:09 appldev noship $ */
--------------------------------------------------------------------
--Margin should only avail for pack I
--This is wrapper to a call to OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL
--------------------------------------------------------------------
Function Is_Margin_Avail return Boolean;

End OE_FEATURES_PVT;

 

/
