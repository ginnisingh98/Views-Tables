--------------------------------------------------------
--  DDL for Package Body OE_GET_DEFAULT_SOURCE_TYPE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_GET_DEFAULT_SOURCE_TYPE_PUB" as
/* $Header: OEXPDSTB.pls 115.0 99/07/16 08:14:21 porting ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'OE_CUSTOM_DEFAULT_SOURCE_TYPE';

procedure GET_CUSTOM_DEFAULT_SOURCE_TYPE( P_API_Version In Number,
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
			                p_warehouse in number default null) is
L_API_Name Constant Varchar2(30) := 'GET_CUSTOM_DEFAULT_SOURCE_TYPE';
L_API_Version Constant Number := 1.0;

begin

 IF Not FND_API.Compatible_API_Call (L_API_Version,
				     P_API_Version,
				     L_API_Name,
				     G_PKG_Name) Then
  Raise FND_API.G_EXC_UNEXPECTED_ERROR;
 End If;


     p_source_type := '';
     p_source_type_svrid := NULL;
     P_Return_Status := FND_API.G_RET_STS_SUCCESS;

 end GET_CUSTOM_DEFAULT_SOURCE_TYPE;

end OE_GET_DEFAULT_SOURCE_TYPE_PUB;

/
