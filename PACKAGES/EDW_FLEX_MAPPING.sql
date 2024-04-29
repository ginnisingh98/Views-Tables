--------------------------------------------------------
--  DDL for Package EDW_FLEX_MAPPING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_FLEX_MAPPING" AUTHID CURRENT_USER AS
/* $Header: EDWSRFLS.pls 115.4 2002/12/05 22:26:03 jwen ship $ */

/*===========================================================================*/

FUNCTION GET_VALUE( P_fact_name                IN  VARCHAR2,
                          P_dim_name              IN  VARCHAR2,
                          P_ccid                 IN  NUMBER,
                          P_set_of_books_id      IN  VARCHAR2,
                          P_structure_id              IN  NUMBER)
			RETURN VARCHAR2;

          PRAGMA RESTRICT_REFERENCES (get_value,WNDS, WNPS, RNPS);
END EDW_FLEX_MAPPING;

 

/
