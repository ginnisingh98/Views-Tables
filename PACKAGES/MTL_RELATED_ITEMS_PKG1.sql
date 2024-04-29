--------------------------------------------------------
--  DDL for Package MTL_RELATED_ITEMS_PKG1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_RELATED_ITEMS_PKG1" AUTHID CURRENT_USER as
/* $Header: INVISRIS.pls 115.0 2002/04/08 10:46:30 pkm ship        $ */


  FUNCTION site_to_address(X_site_id IN NUMBER) return VARCHAR2;
  PRAGMA RESTRICT_REFERENCES(SITE_TO_ADDRESS, WNDS, WNPS);


END MTL_RELATED_ITEMS_PKG1;

 

/
