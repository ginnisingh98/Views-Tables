--------------------------------------------------------
--  DDL for Package CS_KB_SEARCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_KB_SEARCH_PVT" AUTHID CURRENT_USER AS
/* $Header: cskbschs.pls 120.0 2005/06/01 09:36:17 appldev noship $ */

FUNCTION Get_Set_Usage_Count(
    p_set_id  IN NUMBER ) RETURN NUMBER;


END CS_KB_SEARCH_PVT;


 

/
