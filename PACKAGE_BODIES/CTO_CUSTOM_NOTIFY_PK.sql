--------------------------------------------------------
--  DDL for Package Body CTO_CUSTOM_NOTIFY_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CTO_CUSTOM_NOTIFY_PK" as
/* $Header: CTOCNOTB.pls 115.0 2003/11/26 23:42:03 ssawant noship $ */




/*---------------------------------------------------------------------------+
    This function tries to get the recipient intended for the defined notification.
    This function will return null by default.
    ERROR TYPES can be one of the following and are defined in CTOUTILS.pls(CTO_UTILITY_PK)
    OPT_DROP_AND_ITEM_CREATED
    OPT_DROP_AND_ITEM_NOT_CREATED
    EXP_ERROR_AND_ITEM_CREATED
    EXP_ERROR_AND_ITEM_NOT_CREATED
+----------------------------------------------------------------------------*/

function Get_Recipient(
        p_error_type         in      Number,
        p_inventory_item_id  in      Number,
        p_organization_id    in      Number,
        p_line_id            in      Number)
Return Varchar2 IS
begin
	/*----------------------------------------------------------------+
	   This function can be replaced by custom code that will
           provide the intendend recipient for this notification.
        +-----------------------------------------------------------------*/

	return NULL;
end Get_Recipient;

end CTO_CUSTOM_NOTIFY_PK;

/
