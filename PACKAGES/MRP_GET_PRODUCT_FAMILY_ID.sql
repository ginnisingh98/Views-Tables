--------------------------------------------------------
--  DDL for Package MRP_GET_PRODUCT_FAMILY_ID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_GET_PRODUCT_FAMILY_ID" AUTHID CURRENT_USER AS
/* $Header: MRPGPFIS.pls 115.0 2002/03/26 03:58:46 pkm ship        $  */

FUNCTION p_family(ITEM_ID IN NUMBER,
		  ORG_ID IN NUMBER) RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES (p_family, WNDS,WNPS);
END;

 

/
