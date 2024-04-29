--------------------------------------------------------
--  DDL for Package INVUPCTF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INVUPCTF" AUTHID CURRENT_USER as
/* $Header: INVUPCTS.pls 115.0 99/07/16 11:11:36 porting ship $*/

PROCEDURE  UPDATE_CATALOG_STATUS_FLAG(
current_catalog_id          IN    NUMBER,
current_element_name        IN    VARCHAR2
);

PROCEDURE  UPDATE_CATSTAT_FLAG_NEW_DE(
current_catalog_id     IN    NUMBER);

FUNCTION CHECK_REQD_DESC_ELEMS(
current_catalog_id          IN    NUMBER,
current_inv_item_id         IN    NUMBER) RETURN BOOLEAN;

END INVUPCTF;

 

/
