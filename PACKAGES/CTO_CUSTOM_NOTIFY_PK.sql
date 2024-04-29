--------------------------------------------------------
--  DDL for Package CTO_CUSTOM_NOTIFY_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CTO_CUSTOM_NOTIFY_PK" AUTHID CURRENT_USER as
/* $Header: CTOCNOTS.pls 115.0 2003/11/26 23:41:34 ssawant noship $ */


/*---------------------------------------------------------------------------+
    This function tries to get the recipient intended for the defined notification.
    This function will return null by default.
+----------------------------------------------------------------------------*/

function Get_Recipient(
        p_error_type         in      Number,
        p_inventory_item_id  in      Number,
        p_organization_id    in      Number,
        p_line_id            in      Number)
Return Varchar2;

end CTO_CUSTOM_NOTIFY_PK;

 

/
