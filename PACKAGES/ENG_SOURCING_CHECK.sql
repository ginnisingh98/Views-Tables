--------------------------------------------------------
--  DDL for Package ENG_SOURCING_CHECK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_SOURCING_CHECK" AUTHID CURRENT_USER AS
/* $Header: ENGSRCKS.pls 115.1 2003/11/16 00:13:57 mxgovind noship $ */

   FUNCTION IS_ITEM_SOURCED(
	p_revised_item		NUMBER,
	p_source_organization	NUMBER,
	p_dest_organization	NUMBER
    ) RETURN NUMBER;


END ENG_SOURCING_CHECK;

 

/
