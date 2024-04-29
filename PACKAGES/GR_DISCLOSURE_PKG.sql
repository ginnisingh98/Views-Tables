--------------------------------------------------------
--  DDL for Package GR_DISCLOSURE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GR_DISCLOSURE_PKG" AUTHID CURRENT_USER AS
/*$Header: GRHIDISS.pls 115.4 2002/10/25 18:10:37 mgrosser ship $*/
/*	This record definition maintains the list of columns returned the form. */


   PROCEDURE Check_Primary_Key
	   			 (p_disclosure_code IN VARCHAR2,
				  p_called_by_form IN VARCHAR2,
				  x_rowid OUT NOCOPY VARCHAR2,
				  x_key_exists OUT NOCOPY VARCHAR2);
   PROCEDURE Check_References
				(delete_disclosure gr_disclosures.disclosure_code%TYPE);


END GR_DISCLOSURE_PKG;

 

/
