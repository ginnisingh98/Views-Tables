--------------------------------------------------------
--  DDL for Package GML_ITEM_AUTOLOT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GML_ITEM_AUTOLOT" AUTHID CURRENT_USER AS
/* $Header: GMLATLTS.pls 115.0 2003/05/06 15:38:26 pbamb noship $ */

FUNCTION item_autolot_enabled(P_item_id IN NUMBER) RETURN BOOLEAN;

END GML_ITEM_AUTOLOT;

 

/
