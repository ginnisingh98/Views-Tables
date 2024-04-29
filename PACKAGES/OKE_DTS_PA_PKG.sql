--------------------------------------------------------
--  DDL for Package OKE_DTS_PA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_DTS_PA_PKG" AUTHID CURRENT_USER AS
/* $Header: OKEPDPAS.pls 115.3 2002/05/13 11:21:22 pkm ship      $ */

FUNCTION Event_Type_Exist ( P_Event_Type VARCHAR2 ) RETURN BOOLEAN;

FUNCTION Project_Exist ( P_Project_ID NUMBER ) RETURN BOOLEAN;


END;



 

/
