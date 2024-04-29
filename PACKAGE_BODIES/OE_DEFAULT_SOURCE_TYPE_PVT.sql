--------------------------------------------------------
--  DDL for Package Body OE_DEFAULT_SOURCE_TYPE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_DEFAULT_SOURCE_TYPE_PVT" as
/* $Header: OEXVDSTB.pls 115.2 99/07/16 08:16:54 porting shi $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'OE_DEFAULT_SOURCE_TYPE';

PROCEDURE GET_DEFAULT_SOURCE_TYPE(P_API_Version      In Number,
                                  P_Return_Status    Out Varchar2,
                                  P_Msg_Count        Out Number,
                                  P_MSG_Data         Out Varchar2,
                                  p_item in number,
                		   p_cycle_id in number,
			           p_linetype in varchar2,
                                   p_option_flag in varchar2,
                                   p_item_type in varchar2,
				   p_source_type_svrid out number,
                                   p_source_type out varchar2,
                                   p_warehouse in number default null) is
purchase_action  number;
pick_release_action number;
purchasable varchar2(1);
PURCHASERELEASE number := 17;
PICKRELEASE number := 2;
org_specified varchar2(1) := 'N';
item_in_org varchar2(1) := 'N';
c_source_type varchar2(80);
c_source_type_svrid number;
CP_API_Version Constant number := 1;
CP_Return_Status varchar2(30);
CP_Msg_Count number;
CP_MSG_Data varchar2(80);
L_API_Name Constant Varchar2(30) := 'GET_DEFAULT_SOURCE_TYPE';
L_API_Version Constant Number := 1.0;
L_Warehouse Number;
msgcount number := 0;

begin

/* notes:

    p_msg_data = 'itemcycle' and source_type is null implies something
                  fishy!!
    if p_msg_data = 'internal or 'external' , source_type_code_svrid = 1
                     which means source_type has to be INTERNAL or EXTERNAL

*/

	IF Not FND_API.Compatible_API_Call (L_API_Version,
				     P_API_Version,
				     L_API_Name,
				     G_PKG_Name) Then
 		Raise FND_API.G_EXC_UNEXPECTED_ERROR;
 	End If;


	if ((p_item is null) or (p_cycle_id is null) or (p_linetype is null) or (p_option_flag is null) or (p_item_type is null))

	then
     		P_Return_Status := FND_API.G_RET_STS_ERROR;
     		Return;
	end if;

	l_warehouse := p_warehouse;

	if l_warehouse = -99 then
   		l_warehouse := Null;
	end if;

	if l_warehouse is not null then
    		org_specified := 'Y';
	end if;

	if org_specified = 'Y' then
   		begin
       	  		select 'Y' into item_in_org
       	  		from mtl_system_items
         		where inventory_item_id = p_item
         		and organization_id = l_warehouse;
   		exception
         		when no_data_found then null;
   		end;
	end if;

 	begin
    		select msi.purchasing_enabled_flag
    		into purchasable
    		from mtl_system_items msi
    		where msi.inventory_item_id = p_item
    		and msi.organization_id = FND_PROFILE.VALUE_SPECIFIC('SO_ORGANIZATION_ID');
 	exception
    		when no_data_found then P_Return_Status :=  FND_API.G_RET_STS_ERROR;
                Return;
 	end;


/* check whether purchasing release is an action in the given cycle */
  	begin
    		select CA.action_id into
       		purchase_action
    		from
     		so_cycle_actions CA
     		where CA.action_id = PURCHASERELEASE
     		and CA.cycle_id = p_cycle_id
		and Nvl(CA.CHANGE_CODE,'ADDED') <> 'DELETED';
  	exception
     		when no_data_found then null;
  	end;

/* check whether pick release is an action in the given cycle */
   	begin
      		select CA.action_id into
          	pick_release_action
     		from
       		so_cycle_actions CA
       		where CA.action_id = PICKRELEASE
       		and CA.cycle_id = p_cycle_id
		and Nvl(CA.CHANGE_CODE,'ADDED') <> 'DELETED';
   	exception
       		when no_data_found then null;
  	end;


/* if item is standard and line is not an option and line is not a service line
   then only allow the line to be externally sourced */

	if    ( (p_item_type = 'STANDARD')
    		and ( (p_linetype = 'REGULAR') or (p_linetype = 'DETAIL')
                      or (p_linetype = 'PARENT') )
    		and (p_option_flag = 'N')) then

		if (purchase_action is null) then /* no purchase release in cycle */

        		p_source_type_svrid := 1;
        		p_source_type := 'INTERNAL';
        		p_msg_data := 'internal';
        		p_msg_count := msgcount + 1;

		elsif (pick_release_action is null) then

   /* purchase action is not null and pick release is null */

        		if (purchasable = 'Y') then
                		p_source_type := 'EXTERNAL';
                		p_source_type_svrid := 1;
                		p_msg_data := 'itemcycle';
                		p_msg_count := msgcount + 1;
         		else
                		p_source_type := ''; /* needs discussion */
                		p_msg_data := 'itemcycle';
                		p_msg_count := msgcount + 1;
                		P_Return_Status := FND_API.G_RET_STS_SUCCESS;
                		Return;

      			end if;

   		else  /* purchase action and pick release action both are not null */

   			oe_get_default_source_type_pub.get_custom_default_source_type(
                                               		CP_API_Version,
                                                       	CP_Return_Status,
							CP_Msg_Count,
                                                       	CP_MSG_Data,
                                                       	p_item,
                                                       	p_cycle_id,
                                                       	p_linetype,
                                                       	p_option_flag,
                                                       	p_item_type,
                                                       	c_source_type_svrid,
                                                  	c_source_type,
							l_warehouse);

        		p_source_type := c_source_type;
        		p_source_type_svrid := c_source_type_svrid;

   		end if;


	else /* not a standard item or regular line or an option */

       		p_source_type_svrid := 1;
       		p_source_type := 'INTERNAL';
       		p_msg_data := 'internal';
       		p_msg_count := msgcount + 1;

	end if; /* standard item ; not an option or service line */

	P_Return_Status := FND_API.G_RET_STS_SUCCESS;

end GET_DEFAULT_SOURCE_TYPE;

end OE_DEFAULT_SOURCE_TYPE_PVT;

/
