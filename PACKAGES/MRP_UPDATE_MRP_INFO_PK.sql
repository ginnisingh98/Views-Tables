--------------------------------------------------------
--  DDL for Package MRP_UPDATE_MRP_INFO_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MRP_UPDATE_MRP_INFO_PK" AUTHID CURRENT_USER AS
/* $Header: MRPPUPDS.pls 115.1 2002/06/07 12:58:12 pkm ship    $ */

PROCEDURE mrp_update_mrp_cols (
                arg_org_id          IN      NUMBER,
                arg_item_id         IN      NUMBER,
                arg_user_id         IN      NUMBER,
                arg_request_id      IN      NUMBER );

END MRP_UPDATE_MRP_INFO_PK;

 

/
