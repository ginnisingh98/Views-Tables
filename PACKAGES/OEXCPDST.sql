--------------------------------------------------------
--  DDL for Package OEXCPDST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OEXCPDST" AUTHID CURRENT_USER AS
/* $Header: OECPDILS.pls 115.1 99/07/16 08:10:46 porting shi $ */

PROCEDURE OE_CP_DISCOUNT
(       source_id                       IN      NUMBER
,       destination_id                  IN      NUMBER
,	destination_price_list_id	IN	NUMBER
,       msg_text                        OUT     VARCHAR2
,       return_status                   OUT     NUMBER
,	line_item_not_copied		OUT	NUMBER
,	line_exist			OUT	NUMBER
);

END OEXCPDST;

 

/
