--------------------------------------------------------
--  DDL for Package GMF_OPM_ITEM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_OPM_ITEM" AUTHID CURRENT_USER AS
/* $Header: gmfopmis.pls 120.0 2005/05/26 00:41:31 appldev noship $ */
	FUNCTION CHECK_OPM_ITEM    (p_item_no	in 	mtl_system_items.segment1%TYPE)
		RETURN NUMBER;
	PRAGMA RESTRICT_REFERENCES (CHECK_OPM_ITEM, WNDS);
END GMF_OPM_ITEM;

 

/
