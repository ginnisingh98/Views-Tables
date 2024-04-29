--------------------------------------------------------
--  DDL for Package OE_DEFAULT_SOURCE_TYPE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_DEFAULT_SOURCE_TYPE_PVT" AUTHID CURRENT_USER as
/* $Header: OEXVDSTS.pls 115.0 99/07/16 08:16:59 porting ship $ */
PROCEDURE GET_DEFAULT_SOURCE_TYPE( P_API_Version In Number,
                                   P_Return_Status Out Varchar2,
                                   P_Msg_Count Out Number,
                                   P_MSG_Data Out Varchar2,
                                   p_item in number,
	         		   p_cycle_id in number,
			           p_linetype in varchar2,
                                   p_option_flag in varchar2,
                                   p_item_type in varchar2,
				   p_source_type_svrid out number,
                                   p_source_type out varchar2,
                                   p_warehouse in number default null);
end OE_DEFAULT_SOURCE_TYPE_PVT;

 

/
