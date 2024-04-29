--------------------------------------------------------
--  DDL for Package Body BOM_ROUTINGHEADER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_ROUTINGHEADER_PVT" AS
-- $Header: BOMVRTGB.pls 120.5 2005/12/05 05:53:25 earumuga noship $

G_PKG_NAME CONSTANT VARCHAR2(30) := 'BOM_RoutingHeader_PVT';
g_yes	   constant number := 1;
g_no	   constant number := 2;
g_mfg	   constant number := 1; -- routing type
g_eng	   constant number := 2; -- routing type
g_event    constant number := 1; -- operation type
g_process  constant number := 2; -- operation type
g_LineOp   constant number := 3; -- operation type
PROCEDURE AssignRouting
( 	p_api_version           IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level	IN  	NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
	x_return_status		IN OUT NOCOPY	VARCHAR2,
	x_msg_count		    IN OUT NOCOPY	NUMBER,
	x_msg_data		    IN OUT NOCOPY	VARCHAR2,
	p_routing_rec		IN	ROUTING_REC_TYPE := G_MISS_ROUTING_REC,
	x_routing_rec		IN OUT NOCOPY     ROUTING_REC_TYPE
) is
l_api_name	CONSTANT VARCHAR2(30)	:= 'AssignRouting';
l_api_version   CONSTANT NUMBER 	:= 1;
l_routing_rec	ROUTING_REC_TYPE;
l_ret_code      number := 0;
l_err_text   	varchar2(100) := null;

cursor		l_OldAssy_csr(P_RtgSeqId number) is
		  Select assembly_item_id,
		         organization_id,
			 alternate_routing_designator
		  From bom_operational_routings
		  Where routing_sequence_id = P_RtgSeqId;

cursor		l_OldRtg_csr(P_AssyId number, P_OrgId number,
	        P_Alternate varchar2) is
		  Select bor.routing_sequence_id
		  From bom_operational_routings bor
		  Where bor.assembly_item_id = P_AssyId
		  And   bor.organization_id = P_OrgId
		  And   nvl(bor.alternate_routing_designator, 'PRIMARY ALT') =
		        nvl(P_Alternate , 'PRIMARY ALT');

cursor		l_parameter_csr(P_Code varchar2) is
		  Select organization_id
		  From mtl_parameters
		  Where organization_code = P_Code;
cursor		l_line_csr(P_Organization_Id number, P_Code varchar2) is
		  Select line_id
		  From wip_lines
		  Where organization_id = P_Organization_Id
		  And   line_code = P_Code;
cursor 		l_CommonRtg_csr(P_AssyId number, P_OrgId number,
		P_Alt varchar2) is
      		  Select routing_sequence_id,
             	         completion_subinventory,
             	         completion_locator_id
      		  From bom_operational_routings
      		  Where assembly_item_id = P_AssyId
      		  And organization_id = P_OrgId
      		  And nvl(alternate_routing_designator, 'primary alternate') =
          	      nvl(P_Alt, 'primary alternate');
cursor 		l_CommonAssy_csr (P_SeqId number, P_OrgId number,
		P_Alternate varchar2) is
      		  Select assembly_item_id,
             	         completion_subinventory,
             	         completion_locator_id
      		  From bom_operational_routings
      		  Where routing_sequence_id = P_SeqId
      		  And organization_id = P_OrgId
      		  And nvl(alternate_routing_designator, 'Primary Alternate') =
                      nvl(P_Alternate, 'Primary Alternate');
BEGIN
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- API body
    l_routing_rec := p_routing_rec;

    -- set organization id

    If nvl(l_routing_rec.routing_sequence_id, FND_API.G_MISS_NUM) <>
    FND_API.G_MISS_NUM then
      For l_assy_rec in	l_OldAssy_csr(
      P_RtgSeqId => l_routing_rec.routing_sequence_id) loop
        l_routing_rec.assembly_item_id := l_assy_rec.assembly_item_id;
        l_routing_rec.organization_id := l_assy_rec.organization_id;
        l_routing_rec.alternate_routing_designator :=
          l_assy_rec.alternate_routing_designator;
      End loop;
    End if; -- check existing routing

    if nvl(l_routing_rec.organization_code, FND_API.G_MISS_CHAR) <>
    FND_API.G_MISS_CHAR then
      l_routing_rec.organization_id := FND_API.G_MISS_NUM;
      For l_parameter_rec in l_parameter_csr(
      P_Code => l_routing_rec.organization_code) loop
        l_routing_rec.organization_id := l_parameter_rec.organization_id;
      End loop;
    End if; -- organization code

    if nvl(l_routing_rec.organization_id, FND_API.G_MISS_NUM) =
    FND_API.G_MISS_NUM then
      Fnd_Message.Set_Name('BOM', 'BOM_ORG_ID_MISSING');
      FND_MSG_PUB.Add;
      raise FND_API.G_EXC_ERROR;
    end if; -- organization_id

    -- set assembly item id

    if nvl(l_routing_rec.Assembly_Item_Number, FND_API.G_MISS_CHAR) <>
    FND_API.G_MISS_CHAR then
      l_ret_code := INVPUOPI.mtl_pr_trans_prod_item(
		org_id => l_routing_rec.organization_id,
		item_number_in => l_routing_rec.assembly_item_number,
		item_id_out => l_routing_rec.assembly_item_id,
		err_text => l_err_text);
      if l_ret_code <> 0 then
	    Fnd_Message.Set_Name('BOM', 'BOM_ASSY_ITEM_MISSING');
    	    FND_MSG_PUB.Add;
            raise FND_API.G_EXC_ERROR;
      end if;  -- parse failed
    end if; -- assembly item number

    -- get routing sequence id
    If nvl(l_routing_rec.routing_sequence_id, FND_API.G_MISS_NUM) =
    FND_API.G_MISS_NUM then
      If l_routing_rec.alternate_routing_designator = FND_API.G_MISS_CHAR then
        l_routing_rec.alternate_routing_designator := null;
      End if;
      For l_OldRtg_rec in l_OldRtg_csr(
      P_AssyId => l_routing_rec.assembly_item_id,
      P_OrgId => l_routing_rec.organization_id,
      P_Alternate => l_routing_rec.alternate_routing_designator) loop
        l_routing_rec.routing_sequence_id := l_OldRtg_rec.routing_sequence_id;
      End loop; -- existing routing
    End if; -- get routing sequence id

    -- set locator id

    if nvl(l_routing_rec.location_name, FND_API.G_MISS_CHAR) <>
    FND_API.G_MISS_CHAR then
      l_ret_code := INVPUOPI.mtl_pr_parse_flex_name(
		org_id => l_routing_rec.organization_id,
		flex_code => 'MTLL',
		flex_name => l_routing_rec.location_name,
		flex_id => l_routing_rec.completion_locator_id,
		set_id => -1,
		err_text => l_err_text);
      if l_ret_code <> 0 then
	Fnd_Message.Set_Name('BOM', 'BOM_LOCATION_NAME_INVALID');
        FND_MSG_PUB.Add;
        raise FND_API.G_EXC_ERROR;
      end if; -- invalid locator
    end if; -- parse completion locator

    -- set common assembly item id

    if nvl(l_routing_rec.common_item_number, FND_API.G_MISS_CHAR) <>
    FND_API.G_MISS_CHAR then
      l_ret_code := INVPUOPI.mtl_pr_trans_prod_item(
		org_id => l_routing_rec.organization_id,
		item_number_in => l_routing_rec.common_item_number,
		item_id_out => l_routing_rec.common_assembly_item_id,
		err_text => l_err_text);
      if l_ret_code <> 0 then
	Fnd_Message.Set_Name('BOM', 'BOM_CMN_ASSY_ITEM_INVALID');
        FND_MSG_PUB.Add;
        raise FND_API.G_EXC_ERROR;
      end if; -- invalid item id
    end if; -- common assembly

    -- set common routing info

    If nvl(l_routing_rec.common_assembly_item_id, FND_API.G_MISS_NUM) <>
    FND_API.G_MISS_NUM then
      l_routing_rec.common_routing_sequence_id := null;
      For l_CommonRtg_rec in l_CommonRtg_csr(
      P_AssyId => l_routing_rec.common_assembly_item_id,
      P_OrgId => l_routing_rec.organization_id,
      P_Alt => l_routing_rec.alternate_routing_designator) loop
	l_routing_rec.common_routing_sequence_id :=
          l_CommonRtg_rec.routing_sequence_id;
        -- Bug 4081948
        -- Take values of completion_subinventory and completion_locator_id
        --   from input if specified, else from common routing
        l_routing_rec.completion_subinventory :=
          nvl(l_routing_rec.completion_subinventory,l_CommonRtg_rec.completion_subinventory);
        l_routing_rec.completion_locator_id :=
          nvl(l_routing_rec.completion_locator_id,l_CommonRtg_rec.completion_locator_id);
      End loop; -- common routing
      If l_routing_rec.common_routing_sequence_id is null then
        Fnd_Message.Set_Name('BOM', 'BOM_CMN_RTG_SEQ_INVALID');
        FND_MSG_PUB.Add;
        raise FND_API.G_EXC_ERROR;
      End if; -- could not find routing
    Elsif l_routing_rec.routing_sequence_id <>
    l_routing_rec.common_routing_sequence_id and
    l_routing_rec.common_routing_sequence_id <> FND_API.G_MISS_NUM and
    l_routing_rec.routing_sequence_id <> FND_API.G_MISS_NUM then
      l_routing_rec.common_assembly_item_id := null;
      For l_CommonAssy_rec in l_CommonAssy_csr (
      P_SeqId => l_routing_rec.common_routing_sequence_id,
      P_OrgId => l_routing_rec.organization_id,
      P_Alternate => l_routing_rec.alternate_routing_designator) loop
        l_routing_rec.common_assembly_item_id :=
          l_CommonAssy_rec.assembly_item_id;
        -- Bug 4081948
        -- Take values of completion_subinventory and completion_locator_id
        --   from input if specified, else from common routing
        l_routing_rec.completion_subinventory :=
          nvl(l_routing_rec.completion_subinventory,l_CommonAssy_rec.completion_subinventory);
        l_routing_rec.completion_locator_id :=
          nvl(l_routing_rec.completion_locator_id,l_CommonAssy_rec.completion_locator_id);
      end loop; -- common assembly
      If l_routing_rec.common_assembly_item_id is null then
        Fnd_Message.Set_Name('BOM', 'BOM_CMN_RTG_SEQ_INVALID');
        FND_MSG_PUB.Add;
        raise FND_API.G_EXC_ERROR;
      End if; -- could not find common assembly
    Elsif l_routing_rec.routing_sequence_id <> FND_API.G_MISS_NUM then
      -- noncommon
      l_routing_rec.common_routing_sequence_id :=
        l_routing_rec.routing_sequence_id;
      l_routing_rec.common_assembly_item_id := Null;
    End if; -- set common routing info

    -- set line id

    if nvl(l_routing_rec.line_code, FND_API.G_MISS_CHAR) <>
    FND_API.G_MISS_CHAR then
      l_routing_rec.line_id := FND_API.G_MISS_NUM;
      For l_line_rec in l_line_csr(
      P_Organization_Id => l_routing_rec.organization_id,
      P_Code => l_routing_rec.line_code) loop
          l_routing_rec.line_id := l_line_rec.line_id;
      End loop;
      If l_routing_rec.line_id = FND_API.G_MISS_NUM then
        Fnd_Message.Set_Name('BOM', 'BOM_INVALID_LINE');
        FND_MSG_PUB.Add;
        raise FND_API.G_EXC_ERROR;
      End if; -- line is missing
    End if; -- line code

    -- set cfm_flag

    If nvl(l_routing_rec.cfm_routing_flag, FND_API.G_MISS_NUM) =
    FND_API.G_MISS_NUM then
      l_routing_rec.cfm_routing_flag := g_no; -- default
    End if;

    x_routing_rec := l_routing_rec;

    -- End of API body.

    -- Standard call to get message count and if count is 1,
    -- get message info.
    FND_MSG_PUB.Count_And_Get
    	(p_count         =>      x_msg_count,
         p_data          =>      x_msg_data
    	);
EXCEPTION
  	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get
    		(p_count         	=>      x_msg_count,
        	 p_data          	=>      x_msg_data
    		);
  	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
    		(p_count         	=>      x_msg_count,
        	 p_data          	=>      x_msg_data
    		);
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(p_count         	=>      x_msg_count,
        	 p_data          	=>      x_msg_data
    		);
END AssignRouting;

PROCEDURE ValidateRouting
( 	p_api_version           IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level	IN  	NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
	x_return_status		IN OUT NOCOPY	VARCHAR2,
	x_msg_count		    IN OUT NOCOPY	NUMBER,
	x_msg_data		    IN OUT NOCOPY	VARCHAR2,
	p_routing_rec		IN	ROUTING_REC_TYPE := G_MISS_ROUTING_REC,
	x_routing_rec		IN OUT NOCOPY     ROUTING_REC_TYPE
) is
l_api_name	CONSTANT VARCHAR2(30)	:= 'ValidateRouting';
l_api_version   CONSTANT NUMBER 	:= 1;
l_routing_rec   ROUTING_REC_TYPE;
l_return_status	VARCHAR2(1);
l_msg_count	NUMBER;
l_msg_data	VARCHAR2(2000);
Cursor          l_org_csr (P_OrgId number) is
      		  Select 1 dummy
      		  From dual
      		  Where not exists (
        	    Select null
        	    From mtl_parameters
        	    Where organization_id = P_OrgId);
Cursor 		l_alternate_csr (P_OrgId number, P_Alt varchar2) is
      		  Select 1 dummy
      		  From dual
      		  Where not exists (
        	    Select null
        	    From bom_alternate_designators
                    Where organization_id = P_OrgId
        	    And alternate_designator_code = P_Alt);
Cursor 		l_item_csr (P_Org number, P_Item number) is
      		  Select 1 dummy
      		  From dual
      		    Where not exists (
        	      select null
        	      from mtl_system_items
        	      where organization_id = P_Org
        	      and   inventory_item_id = P_Item);
Cursor 		l_DupRtgs_csr (P_RtgSeqId number, P_AssyId number,
	        P_OrgId number, P_Alternate varchar2) is
      		  Select 1 dummy
      		  From dual
      		  Where exists (
        	    select null
        	    from bom_operational_routings
        	    where routing_sequence_id <> P_RtgSeqId
        	    and assembly_item_id = P_AssyId
		    and organization_id = P_OrgId
		    and nvl(alternate_routing_designator, 'Primary Alternate')
		      = nvl(P_Alternate, 'Primary Alternate'));
Cursor 		l_CheckPrimary_csr (P_OrgId number, P_AssyId number,
		P_RtgType number) is
      		  Select 1 dummy
      		  From dual
      		  Where not exists (
		    select null
		    from bom_operational_routings
		    where organization_id = P_OrgId
	            and   assembly_item_id = P_AssyId
	            and   alternate_routing_designator is null
                and   ( routing_type = P_RtgType OR routing_type = 1));
			  -- Commented this check..Will fail when mfg rtg exists and we create eng alt
			  -- decode(P_RtgType, 2, routing_type, 1));
Cursor 		l_CheckAttributes_csr (
    		P_OrgId number, P_AssyId number, P_RtgType number) is
      		  Select 1
      		  From dual
      		  Where not exists (
		    Select null
		    From mtl_system_items
		    Where organization_id = P_OrgId
		    and   inventory_item_id = P_AssyId
		    and   bom_item_type <> 3
		    and   bom_enabled_flag = 'Y'
		    and   pick_components_flag = 'N'
		    and   eng_item_flag =
			  decode(P_RtgType, 2, eng_item_flag, 'N'));
Cursor 		l_CommonRtg_csr(P_RtgSeqId number) is
      		  Select 1 dummy
      		  From dual
      		  Where not exists (
    		    select null
		    from bom_operational_routings
		    where routing_sequence_id = P_RtgSeqId);

    -- Common routing's alt must be same as current routing's alt
    -- Common routing cannot have same assembly_item_id as current routing
    -- Common routing must have the same org id as current routing
    -- Common routing must be mfg routing if current routing is a mfg routing
    -- Common routing cannot reference a common routing
Cursor 		l_VerifyCommonRtg_csr(
		P_cmn_rtg_id	NUMBER,
		P_rtg_type	NUMBER,
        	P_item_id       NUMBER,
        	P_org_id        NUMBER,
		P_alt_desg	VARCHAR2) is
      		  Select 1 dummy
      		  From dual
  		  Where not exists (
        	    select null
		    from bom_operational_routings bor
		    where bor.routing_sequence_id = P_cmn_rtg_id
        	    and nvl(bor.alternate_routing_designator,
		    'Primary Alternate') = nvl(P_alt_desg, 'Primary Alternate')
        	    and bor.common_routing_sequence_id =
                        bor.routing_sequence_id
        	    and   bor.assembly_item_id <> P_item_id
        	    and   bor.organization_id = P_org_id
		    and   bor.routing_type =
                          decode(P_rtg_type, 1, 1, bor.routing_type));
Cursor 		l_SubInvFlags_csr (P_ItemId number, P_OrgId number) is
      		  Select msi.inventory_asset_flag,
             		 msi.restrict_subinventories_code,
             		 msi.restrict_locators_code,
             		 msi.location_control_code,
             		 mp.stock_locator_control_code
      		  from mtl_system_items msi,
           	       mtl_parameters mp
      		  where msi.inventory_item_id = P_ItemId
      		  and msi.organization_id = P_OrgId
      		  and mp.organization_id = msi.organization_id;
Cursor 		l_NonRestrictedSubinv_csr (P_SubInv varchar2, P_OrgId number,
    		P_Asset number, P_Inv_Asst varchar2) is
      		  Select locator_type
      		  From mtl_secondary_inventories
      		  Where secondary_inventory_name = P_SubInv
      		  And organization_id = P_OrgId
      		  And nvl(disable_date,TRUNC(SYSDATE)+1) > TRUNC(SYSDATE)
      		  And ((P_Asset = 1 and quantity_tracked = 1) or
           		(nvl(P_Asset, 0) <> 1 and
            		((P_Inv_Asst = 'Y' and asset_inventory = 1
              		  and quantity_tracked = 1)
                          or (P_Inv_Asst = 'N')))
                      );
Cursor 		l_RestrictedSubinv_csr (P_SubInv varchar2, P_OrgId number,
    		P_ItemId number, P_Asset number, P_Inv_Asst varchar2) is
      		  Select locator_type
      		  From mtl_secondary_inventories sub,
           	       mtl_item_sub_inventories item
      		  Where item.organization_id = sub.organization_id
      		  And item.secondary_inventory = sub.secondary_inventory_name
      		  And item.inventory_item_id = P_ItemId
      		  And sub.secondary_inventory_name = P_SubInv
      		  And sub.organization_id = P_OrgId
      		  And nvl(sub.disable_date,TRUNC(SYSDATE)+1) > TRUNC(SYSDATE)
      		  And ((P_Asset = 1 and sub.quantity_tracked = 1) or
           	       (nvl(P_Asset, 0) <> 1 and
                        ((P_Inv_Asst = 'Y' and sub.asset_inventory = 1 and
                          sub.quantity_tracked = 1) or (P_Inv_Asst = 'N'))
                       )
                      );
Cursor 		l_NonRestrictedLocators_csr (P_Location number, P_OrgId number,
    		P_SubInventory varchar2) is
      		  select 1 dummy
      		  from sys.dual
      		  where not exists(
        	    select null
        	    from mtl_item_locations
        	    where inventory_location_id = P_Location
        	    and organization_id = P_OrgId
        	    and subinventory_code = P_SubInventory
        	    and nvl(disable_date, trunc(SYSDATE)+1) > trunc(SYSDATE));
Cursor 		l_RestrictedLocators_csr (P_Location number, P_OrgId number,
    		P_SubInventory varchar2, P_ItemId number) is
      		  Select 1 dummy
      		  from dual
      		  where not exists(
        	    select null
        	    from mtl_item_locations loc,
             	         mtl_secondary_locators item
        	where loc.inventory_location_id = P_Location
        	and loc.organization_id = P_OrgId
        	and loc.subinventory_code = P_SubInventory
        	and nvl(loc.disable_date,trunc(SYSDATE)+1) > trunc(SYSDATE)
        	and loc.inventory_location_id = item.secondary_locator
        	and loc.organization_id = item.organization_id
        	and item.inventory_item_id = P_ItemId);
l_sub_loc_code number;
l_expense_to_asset_transfer number;
cursor		l_line_csr(p_line_id number) is
	  	  Select 'x' dummy
            	  From dual
	  	  Where not exists (
	    	    Select null
	    	    From wip_lines
	    	    Where line_id = p_line_id);
cursor		l_MixedModelFlag_csr(p_item_id number, p_org_id number,
		p_alternate varchar2, p_line_id number) is
	 	  Select 'x' dummy
		  From dual
		  Where exists (
		    Select null
		    From bom_operational_routings bor
		    Where bor.assembly_item_id = p_item_id
		    And   bor.organization_id = p_org_id
		    And   nvl(bor.alternate_routing_designator,
			      'Primary Alternate') <>
			  nvl(p_alternate, 'Primary Alternate')
		    And   line_id = p_line_id
		    And   bor.mixed_model_map_flag = g_yes);
cursor		l_DupPriority_csr(p_item_id number, p_org_id number,
		p_alternate varchar2, p_priority number) is
	 	  Select 'x' dummy
		  From dual
		  Where exists (
		    Select null
		    From bom_operational_routings bor
		    Where bor.assembly_item_id = p_item_id
		    And   bor.organization_id = p_org_id
		    And   nvl(bor.alternate_routing_designator,
			      'Primary Alternate') <>
			  nvl(p_alternate, 'Primary Alternate')
		    And   bor.priority = p_priority);
cursor		l_ctp_csr(p_item_id number, p_org_id number,
		p_alternate varchar2) is
	 	  Select 'x' dummy
		  From dual
		  Where exists (
		    Select null
		    From bom_operational_routings bor
		    Where bor.assembly_item_id = p_item_id
		    And   bor.organization_id = p_org_id
		    And   nvl(bor.alternate_routing_designator,
			      'Primary Alternate') <>
			  nvl(p_alternate, 'Primary Alternate')
		    And   bor.ctp_flag = g_yes);
cursor		l_OldLine_csr (P_RtgSeqId number) is
		  Select bor.line_id
		  From bom_operational_routings bor
		  Where bor.routing_sequence_id = P_RtgSeqId
		  And exists (
                    Select null
		    From bom_operation_sequences bos
		    Where bos.routing_sequence_id = bor.routing_sequence_id
		    And bos.standard_operation_id is not null
                  );
BEGIN
    	-- Standard call to check for call compatibility.
    	IF NOT FND_API.Compatible_API_Call ( 	l_api_version,
        	    	    	    	 	p_api_version,
   	       	    	 			l_api_name,
		    	    	    	    	G_PKG_NAME ) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;
	--  Initialize API return status to success
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- API body
	l_routing_rec :=  p_routing_rec;
	If p_validation_level = FND_API.G_VALID_LEVEL_FULL then
	  AssignRouting (p_api_version => 1,
  	    p_init_msg_list	=> p_init_msg_list,
	    p_commit	    	=> p_commit,
	    p_validation_level	=> FND_API.G_VALID_LEVEL_FULL,
	    x_return_status	=> l_return_status,
	    x_msg_count		=> l_msg_count,
	    x_msg_data		=> l_msg_data,
	    p_routing_rec	=> l_routing_rec,
	    x_routing_rec	=> l_routing_rec);
          If l_return_status = FND_API.G_RET_STS_ERROR then
            Raise FND_API.G_EXC_ERROR;
          Elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
            Raise FND_API.G_EXC_UNEXPECTED_ERROR;
          End if; -- error
        End if; -- assign values

        -- Check for valid org id

        For l_org_rec in l_org_csr (
        P_OrgId => l_routing_rec.organization_id) loop
          Fnd_Message.Set_Name('BOM', 'BOM_INVALID_ORG_ID');
	  FND_MSG_PUB.Add;
          Raise FND_API.G_EXC_ERROR;
        End loop; -- Invalid Organization

	-- Check for valid alternate

        if l_routing_rec.alternate_routing_designator is not null then
          For l_alternate_rec in l_alternate_csr (
          P_OrgId => l_routing_rec.organization_id,
          P_Alt => l_routing_rec.alternate_routing_designator) loop
            Fnd_Message.Set_Name('BOM', 'BOM_INVALID_RTG_ALTERNATE');
	    FND_MSG_PUB.Add;
            Raise FND_API.G_EXC_ERROR;
          End loop; -- invalid alternate
        End if; -- Check for valid alternate

        -- Check if assembly item exists

        For l_item_rec in l_item_csr (
        P_Org => l_routing_rec.organization_id,
        P_Item => l_routing_rec.assembly_item_id) loop
          Fnd_Message.Set_Name ('BOM', 'BOM_ASSEMBLY_ITEM_INVALID');
	  FND_MSG_PUB.Add;
          Raise FND_API.G_EXC_ERROR;
        End loop; -- Invalid item id

        -- routing_type must be 1 or 2

        If l_routing_rec.routing_type not in (g_mfg, g_eng) then
          Fnd_Message.Set_Name('BOM', 'BOM_ROUTING_TYPE_INVALID');
	  FND_MSG_PUB.Add;
          Raise FND_API.G_EXC_ERROR;
        End if; -- invalid routing type

        -- Check for unique routing

        For l_duplicate_rec in l_DupRtgs_csr (
        P_RtgSeqId => l_routing_rec.routing_sequence_id,
        P_AssyId => l_routing_rec.assembly_item_id,
	  P_OrgId => l_routing_rec.organization_id,
        P_Alternate => l_routing_rec.alternate_routing_designator) loop
	  Fnd_Message.Set_Name('BOM', 'BOM_DUPLICATE_RTG');
	  FND_MSG_PUB.Add;
          Raise FND_API.G_EXC_ERROR;
        End loop; -- duplicate routing

        -- Check alternate routing has a primary
        -- Check alternate mfg routing does not have an eng primary routing

        if l_routing_rec.alternate_routing_designator is not null then
          For l_primary_rec in l_CheckPrimary_csr (
	  P_OrgId => l_routing_rec.organization_id,
          P_AssyId => l_routing_rec.assembly_item_id,
          P_RtgType => l_routing_rec.routing_type) loop
	    Fnd_Message.Set_Name('BOM', 'BOM_INVALID_PRIMARY');
	    FND_MSG_PUB.Add;
            Raise FND_API.G_EXC_ERROR;
          End loop; -- invalid primary
        End if; --  alternate is not null

        -- Check routing type and item attributes

        For l_item_rec in l_CheckAttributes_csr (
	P_OrgId => l_routing_rec.organization_id,
        P_AssyId => l_routing_rec.assembly_item_id,
        P_RtgType => l_routing_rec.routing_type) loop
	  Fnd_Message.Set_Name('BOM', 'BOM_ROUTING_TYPE_ERR');
	  FND_MSG_PUB.Add;
          Raise FND_API.G_EXC_ERROR;
        End loop; -- invalid item

        If l_routing_rec.routing_sequence_id <>
	l_routing_rec.common_routing_sequence_id then

          -- Check cmn rtg seq id existence

          For l_Common_rec in l_CommonRtg_csr(P_RtgSeqId =>
	  l_routing_rec.common_routing_sequence_id) loop
            Fnd_Message.Set_Name('BOM', 'BOM_COMMON_RTG_NOT_EXIST');
	    FND_MSG_PUB.Add;
            Raise FND_API.G_EXC_ERROR;
          End loop; -- nonexistent common

          -- Verify common routing attributes

          For l_Common_rec in l_VerifyCommonRtg_csr(
	  P_cmn_rtg_id => l_routing_rec.common_routing_sequence_id,
	  P_rtg_type   => l_routing_rec.routing_type,
          P_item_id    => l_routing_rec.assembly_item_id,
          P_org_id     => l_routing_rec.organization_id,
	  P_alt_desg   => l_routing_rec.alternate_routing_designator) loop
	    Fnd_Message.Set_Name('BOM', 'BOM_COMMON_RTG_ERROR');
	    FND_MSG_PUB.Add;
            Raise FND_API.G_EXC_ERROR;
          End loop; -- validate common
        End if; -- common specified

	-- Validate subinventory

	If l_routing_rec.completion_locator_id is not null
        and l_routing_rec.completion_subinventory is null then
          Fnd_Message.Set_Name('BOM', 'BOM_LOCATOR_INVALID');
	  FND_MSG_PUB.Add;
          Raise FND_API.G_EXC_ERROR;
        End if; -- locator without subinventory

	If l_routing_rec.completion_subinventory is not null then
          For l_Flags_rec in l_SubInvFlags_csr (
          P_ItemId => l_routing_rec.assembly_item_id,
          P_OrgId => l_routing_rec.organization_id) loop
            -- if item locator control is null, set to 1 (no loc control)
            If l_Flags_rec.location_control_code is null then
              l_Flags_rec.location_control_code := 1;
            End if;
            -- if subinv is not restricted and locator is, then make
            -- locator unrestricted
            If l_Flags_rec.restrict_subinventories_code = 2
	    and l_Flags_rec.restrict_locators_code = 1 then
              l_Flags_rec.restrict_locators_code := 2;
            End if;

            -- Check if subinventory is valid

            l_expense_to_asset_transfer :=
              to_number(Fnd_Profile.Value(
		'INV'||':'||'EXPENSE_TO_ASSET_TRANSFER'));
            l_sub_loc_code := null;
            If l_Flags_rec.restrict_subinventories_code = 2 then
              -- non-restricted subinventory
              For l_SubInv_rec in l_NonRestrictedSubinv_csr (
              P_SubInv => l_routing_rec.completion_subinventory,
              P_OrgId => l_routing_rec.organization_id,
              P_Asset => l_expense_to_asset_transfer,
              P_Inv_Asst => l_Flags_rec.inventory_asset_flag) loop
                l_sub_loc_code := l_SubInv_rec.locator_type;
              End loop; -- get sublocator code
            Else -- restricted subinventory
              For l_SubInv_rec in l_RestrictedSubinv_csr (
              P_SubInv => l_routing_rec.completion_subinventory,
              P_OrgId => l_routing_rec.organization_id,
              P_ItemId => l_routing_rec.assembly_item_id,
              P_Asset => l_expense_to_asset_transfer,
              P_Inv_Asst => l_Flags_rec.inventory_asset_flag) loop
                l_sub_loc_code := l_SubInv_rec.locator_type;
              End loop; -- get sublocator code
            End if; -- restricted or nonrestricted subinventory
            If l_sub_loc_code is null then
              Fnd_Message.Set_Name('BOM', 'BOM_SUBINV_INVALID');
	      FND_MSG_PUB.Add;
              Raise FND_API.G_EXC_ERROR;
            End if;

            -- Validate locator
            -- Org level
            If l_Flags_rec.stock_locator_control_code = 1
            and l_routing_rec.completion_locator_id is not null then
              Fnd_Message.Set_Name('BOM', 'BOM_LOCATOR_INVALID');
	      FND_MSG_PUB.Add;
              Raise FND_API.G_EXC_ERROR;
            end if;

            If l_Flags_rec.stock_locator_control_code in (2, 3) and
            l_routing_rec.completion_locator_id is null then
              Fnd_Message.Set_Name('BOM', 'BOM_LOCATOR_INVALID');
	      FND_MSG_PUB.Add;
              Raise FND_API.G_EXC_ERROR;
            end if;

            If l_Flags_rec.stock_locator_control_code in (2, 3)
	    and l_routing_rec.completion_locator_id is not null then
              If l_Flags_rec.restrict_locators_code = 2 then
                -- non-restricted locator
                For l_Locator_rec in l_NonRestrictedLocators_csr (
                P_Location => l_routing_rec.completion_locator_id,
                P_OrgId => l_routing_rec.organization_id,
                P_SubInventory => l_routing_rec.completion_subinventory) loop
                  Fnd_Message.Set_Name('BOM', 'BOM_LOCATOR_INVALID');
	          FND_MSG_PUB.Add;
                  Raise FND_API.G_EXC_ERROR;
                End loop;
              Else -- restricted locator
                For l_Locator_rec in l_RestrictedLocators_csr (
                P_Location => l_routing_rec.completion_locator_id,
                P_OrgId => l_routing_rec.organization_id,
		P_SubInventory => l_routing_rec.completion_subinventory,
                P_ItemId => l_routing_rec.assembly_item_id) loop
                  Fnd_Message.Set_Name('BOM', 'BOM_LOCATOR_INVALID');
	          FND_MSG_PUB.Add;
                  Raise FND_API.G_EXC_ERROR;
                End loop;
              End If; --  restricted or non-restricted locator
            End If; -- check if item location exists

            If l_Flags_rec.stock_locator_control_code not in (1,2,3,4)
            and l_routing_rec.completion_locator_id is not null then
              Fnd_Message.Set_Name('BOM', 'BOM_LOCATOR_INVALID');
	      FND_MSG_PUB.Add;
              Raise FND_API.G_EXC_ERROR;
            End if;

            -- Subinventory level
            If l_Flags_rec.stock_locator_control_code = 4
	    and l_sub_loc_code = 1
	    and l_routing_rec.completion_locator_id is not null then
              Fnd_Message.Set_Name('BOM', 'BOM_LOCATOR_INVALID');
	      FND_MSG_PUB.Add;
              Raise FND_API.G_EXC_ERROR;
            End if;

            If l_Flags_rec.stock_locator_control_code = 4 then
              If l_sub_loc_code in (2, 3) and
              l_routing_rec.completion_locator_id is null then
                Fnd_Message.Set_Name('BOM', 'BOM_LOCATOR_INVALID');
	        FND_MSG_PUB.Add;
                Raise FND_API.G_EXC_ERROR;
              End if;
              If l_sub_loc_code in (2, 3)
              and l_routing_rec.completion_locator_id is not null then
                If l_Flags_rec.restrict_locators_code = 2 then
                  -- non-restricted locator
                  For X_Location in l_NonRestrictedLocators_csr (
                  P_Location => l_routing_rec.completion_locator_id,
		  P_OrgId => l_routing_rec.organization_id,
                  P_SubInventory => l_routing_rec.completion_subinventory) loop
                    Fnd_Message.Set_Name('BOM', 'BOM_LOCATOR_INVALID');
	            FND_MSG_PUB.Add;
                    Raise FND_API.G_EXC_ERROR;
                  End loop;
                Else -- restricted locator
                  For l_Location_rec in l_RestrictedLocators_csr (
                  P_Location => l_routing_rec.completion_locator_id,
		  P_OrgId => l_routing_rec.organization_id,
                  P_SubInventory => l_routing_rec.completion_subinventory,
		  P_ItemId => l_routing_rec.assembly_item_id) loop
                    Fnd_Message.Set_Name('BOM', 'BOM_LOCATOR_INVALID');
	            FND_MSG_PUB.Add;
                    Raise FND_API.G_EXC_ERROR;
                  End loop;
                End If; -- locator exists?
              End if; -- subinventory required locator

              If l_sub_loc_code not in (1,2,3,5)
	      and l_routing_rec.completion_locator_id is not null then
                Fnd_Message.Set_Name('BOM', 'BOM_LOCATOR_INVALID');
	        FND_MSG_PUB.Add;
                Raise FND_API.G_EXC_ERROR;
              End if;
            End If; -- org locator = 4

            -- Item level
            If l_Flags_rec.stock_locator_control_code = 4
	    and l_sub_loc_code = 5 and l_Flags_rec.location_control_code = 1
            and l_routing_rec.completion_locator_id is not null then
              Fnd_Message.Set_Name('BOM', 'BOM_LOCATOR_INVALID');
	      FND_MSG_PUB.Add;
              Raise FND_API.G_EXC_ERROR;
            end if;

            If l_Flags_rec.location_control_code in (2, 3)
	    and l_routing_rec.completion_locator_id is not null then
              If l_Flags_rec.restrict_locators_code = 2 then
                -- non-restricted locator
                For l_Location_rec in l_NonRestrictedLocators_csr (
                P_Location => l_routing_rec.completion_locator_id,
		     P_OrgId => l_routing_rec.organization_id,
                P_SubInventory => l_routing_rec.completion_subinventory) loop
                  Fnd_Message.Set_Name('BOM', 'BOM_LOCATOR_INVALID');
	          FND_MSG_PUB.Add;
              	  Raise FND_API.G_EXC_ERROR;
                End loop;
              Else  -- restricted locator
                For l_Location_rec in l_RestrictedLocators_csr (
		    P_Location => l_routing_rec.completion_locator_id,
                P_OrgId => l_routing_rec.organization_id,
		    P_SubInventory => l_routing_rec.completion_subinventory,
                P_ItemId => l_routing_rec.assembly_item_id) loop
                  Fnd_Message.Set_Name('BOM', 'BOM_LOCATOR_INVALID');
	          FND_MSG_PUB.Add;
              	  Raise FND_API.G_EXC_ERROR;
                End loop;
              End If; -- locator exists?
            End If; -- locator control in (2, 3)

            If l_Flags_rec.location_control_code not in (1,2,3)
	    and l_routing_rec.completion_locator_id is not null then
              Fnd_Message.Set_Name('BOM', 'BOM_LOCATOR_INVALID');
	      FND_MSG_PUB.Add;
              Raise FND_API.G_EXC_ERROR;
            End if;
          End loop; -- SubInvFlags
        End If; -- Completion SubInventory specified

	-- CFM logic

	If nvl(l_routing_rec.cfm_routing_flag, g_no) = g_no then
          l_routing_rec.line_id := null;
          l_routing_rec.line_code := null;
          l_routing_rec.mixed_model_map_flag := null;
          l_routing_rec.total_product_cycle_time := null;
        End if; -- non-cfm

	If l_routing_rec.cfm_routing_flag = g_yes
	and l_routing_rec.line_id is null then
	  Fnd_Message.Set_Name('BOM', 'BOM_LINE_REQUIRED');
	  FND_MSG_PUB.Add;
	  Raise FND_API.G_EXC_ERROR;
     	End if;

	If l_routing_rec.line_id is not null then
   	  For l_line_rec in l_line_csr(
	  p_line_id => l_routing_rec.line_id) loop
	    Fnd_Message.Set_Name('BOM', 'BOM_INVALID_LINE');
	    FND_MSG_PUB.Add;
	    Raise FND_API.G_EXC_ERROR;
	  End loop;
     	End if;

 	If l_routing_rec.mixed_model_map_flag = g_yes then
	  For l_MixedModel_rec in l_MixedModelFlag_csr(
	  p_item_id => l_routing_rec.assembly_item_id,
	  p_org_id => l_routing_rec.organization_id,
	  p_alternate => l_routing_rec.alternate_routing_designator,
	  p_line_id => l_routing_rec.line_id) loop
	    Fnd_Message.Set_Name('BOM', 'BOM_MIXED_MODEL_UNIQUE');
	    FND_MSG_PUB.Add;
	    Raise FND_API.G_EXC_ERROR;
	  End loop;
 	End if; -- use in mixed model map

	For l_priority_rec in l_DupPriority_csr(
        p_item_id => l_routing_rec.assembly_item_id,
	p_org_id => l_routing_rec.organization_id,
	p_alternate => l_routing_rec.alternate_routing_designator,
        p_priority => l_routing_rec.priority) loop
          Fnd_Message.Set_Name('BOM', 'BOM_UNIQUE_PRIORITY');
          Fnd_Message.Set_Token('ENTITY2', null);
          Fnd_Message.Set_Token('ENTITY', to_char(l_routing_rec.priority));
	  FND_MSG_PUB.Add;
	  Raise FND_API.G_EXC_ERROR;
        End loop;

 	If l_routing_rec.ctp_flag = g_yes then
	  For l_ctp_rec in l_ctp_csr(
          p_item_id => l_routing_rec.assembly_item_id,
          p_org_id => l_routing_rec.organization_id,
	  p_alternate => l_routing_rec.alternate_routing_designator) loop
	    Fnd_Message.Set_Name('BOM', 'BOM_CTP_UNIQUE');
	    FND_MSG_PUB.Add;
	    Raise FND_API.G_EXC_ERROR;
          End loop;
 	End If; --  ctp_flag = yes

	If l_routing_rec.cfm_routing_flag = g_yes then
	  For l_OldLine_rec in l_OldLine_csr(
	  P_RtgSeqId => l_routing_rec.routing_sequence_id) loop
	    If l_OldLine_rec.line_id <> l_routing_rec.line_id then
	      Fnd_Message.Set_Name('BOM', 'BOM_CANNOT_UPDATE_OI');
	      FND_MSG_PUB.Add;
	      Raise FND_API.G_EXC_ERROR;
            End if; -- line changed
          End loop; -- old routing
        End if; -- cfm routing

        x_routing_rec := l_routing_rec;

	-- End of API body.
	-- Standard call to get message count and if count is 1,
	-- get message info.
	FND_MSG_PUB.Count_And_Get
    	(p_count         	=>      x_msg_count,
         p_data          	=>      x_msg_data
    	);
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
	FND_MSG_PUB.Count_And_Get
    		(p_count         	=>      x_msg_count,
        	 p_data          	=>      x_msg_data
    		);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get
    		(p_count         	=>      x_msg_count,
        	 p_data          	=>      x_msg_data
    		);
    WHEN OTHERS THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  	IF 	FND_MSG_PUB.Check_Msg_Level
		(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
        	FND_MSG_PUB.Add_Exc_Msg
    	  	(G_PKG_NAME,
    	    	 l_api_name
	    	);
	END IF;
	FND_MSG_PUB.Count_And_Get
    		(p_count         	=>      x_msg_count,
        	 p_data          	=>      x_msg_data
    		);
END ValidateRouting;
PROCEDURE CreateRouting
(	p_api_version           IN	NUMBER,
 	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level	IN  	NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
	x_return_status		IN OUT NOCOPY	VARCHAR2,
	x_msg_count		    IN OUT NOCOPY	NUMBER,
	x_msg_data		    IN OUT NOCOPY	VARCHAR2,
	p_routing_rec		IN	ROUTING_REC_TYPE := G_MISS_ROUTING_REC,
	x_routing_rec		IN OUT NOCOPY     ROUTING_REC_TYPE
) is
l_api_name	CONSTANT VARCHAR2(30)	:= 'CreateRouting';
l_api_version   CONSTANT NUMBER 	:= 1;
l_routing_rec   ROUTING_REC_TYPE;
cursor 		l_NewRtg_csr is
      		  Select
		    bom_operational_routings_s.nextval routing_sequence_id
      		  From dual;
l_UserId	number;
l_LoginId	number;
l_RequestId	number;
l_ProgramId	number;
l_ApplicationId	number;
l_ProgramUpdate date;
l_return_status VARCHAR2(1);
l_msg_count     NUMBER;
l_msg_data      VARCHAR2(2000);
BEGIN
	-- Standard Start of API savepoint
    	SAVEPOINT	CreateRouting_Pvt;
    	-- Standard call to check for call compatibility.
    	IF NOT FND_API.Compatible_API_Call ( 	l_api_version,
        	    	    	    	 	p_api_version,
   	       	    	 			l_api_name,
		    	    	    	    	G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;
	--  Initialize API return status to success
    	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- API body

	l_routing_rec := p_routing_rec;

 	For l_NewRtg_rec in l_NewRtg_csr loop
          l_routing_rec.routing_sequence_id := l_NewRtg_rec.routing_sequence_id;
        End loop; -- new primary key

	-- initialize record

	If l_routing_rec.assembly_item_id = FND_API.G_MISS_NUM then
	  l_routing_rec.assembly_item_id := null;
	End if;
	If l_routing_rec.assembly_item_number = FND_API.G_MISS_CHAR then
	  l_routing_rec.assembly_item_number := null;
	End if;
	If l_routing_rec.organization_id = FND_API.G_MISS_NUM then
	  l_routing_rec.organization_id := null;
	End if;
	If l_routing_rec.organization_code = FND_API.G_MISS_CHAR then
	  l_routing_rec.organization_code := null;
	End if;
	If l_routing_rec.alternate_routing_designator =
	FND_API.G_MISS_CHAR then
	  l_routing_rec.alternate_routing_designator := null;
	End if;
	If nvl(l_routing_rec.routing_type, FND_API.G_MISS_NUM) =
        FND_API.G_MISS_NUM then
	   l_routing_rec.routing_type := g_mfg;
	End if;
	If l_routing_rec.common_assembly_item_id = FND_API.G_MISS_NUM then
	  l_routing_rec.common_assembly_item_id := null;
	End if;
	If l_routing_rec.common_item_number = FND_API.G_MISS_CHAR then
	  l_routing_rec.common_item_number := null;
	End if;
	If nvl(l_routing_rec.common_routing_sequence_id, FND_API.G_MISS_NUM)
        = FND_API.G_MISS_NUM then
	  l_routing_rec.common_routing_sequence_id :=
	    l_routing_rec.routing_sequence_id;
	End if;
	If l_routing_rec.routing_comment = FND_API.G_MISS_CHAR then
	  l_routing_rec.routing_comment := null;
	End if;
	If l_routing_rec.completion_subinventory = FND_API.G_MISS_CHAR then
	  l_routing_rec.completion_subinventory := null;
	End if;
	If l_routing_rec.completion_locator_id = FND_API.G_MISS_NUM then
	  l_routing_rec.completion_locator_id := null;
	End if;
	If l_routing_rec.location_name = FND_API.G_MISS_CHAR then
	  l_routing_rec.location_name := null;
	End if;
	If l_routing_rec.attribute_category = FND_API.G_MISS_CHAR then
	  l_routing_rec.attribute_category := null;
	End if;
	If l_routing_rec.attribute1 = FND_API.G_MISS_CHAR then
	  l_routing_rec.attribute1 := null;
	End if;
	If l_routing_rec.attribute2 = FND_API.G_MISS_CHAR then
	  l_routing_rec.attribute2 := null;
	End if;
	If l_routing_rec.attribute3 = FND_API.G_MISS_CHAR then
	  l_routing_rec.attribute3 := null;
	End if;
	If l_routing_rec.attribute4 = FND_API.G_MISS_CHAR then
	  l_routing_rec.attribute4 := null;
	End if;
	If l_routing_rec.attribute5 = FND_API.G_MISS_CHAR then
	  l_routing_rec.attribute5 := null;
	End if;
	If l_routing_rec.attribute6 = FND_API.G_MISS_CHAR then
	  l_routing_rec.attribute6 := null;
	End if;
	If l_routing_rec.attribute7 = FND_API.G_MISS_CHAR then
	  l_routing_rec.attribute7 := null;
	End if;
	If l_routing_rec.attribute8 = FND_API.G_MISS_CHAR then
	  l_routing_rec.attribute8 := null;
	End if;
	If l_routing_rec.attribute9 = FND_API.G_MISS_CHAR then
	  l_routing_rec.attribute9 := null;
	End if;
	If l_routing_rec.attribute10 = FND_API.G_MISS_CHAR then
	  l_routing_rec.attribute10 := null;
	End if;
	If l_routing_rec.attribute11 = FND_API.G_MISS_CHAR then
	  l_routing_rec.attribute11 := null;
	End if;
	If l_routing_rec.attribute12 = FND_API.G_MISS_CHAR then
	  l_routing_rec.attribute12 := null;
	End if;
	If l_routing_rec.attribute13 = FND_API.G_MISS_CHAR then
	  l_routing_rec.attribute13 := null;
	End if;
	If l_routing_rec.attribute14 = FND_API.G_MISS_CHAR then
	  l_routing_rec.attribute14 := null;
	End if;
	If l_routing_rec.attribute15 = FND_API.G_MISS_CHAR then
	  l_routing_rec.attribute15 := null;
	End if;
	If l_routing_rec.line_id = FND_API.G_MISS_NUM then
	  l_routing_rec.line_id := null;
	End if;
	If l_routing_rec.line_code = FND_API.G_MISS_CHAR then
	  l_routing_rec.line_code := null;
	End if;
	If l_routing_rec.mixed_model_map_flag = FND_API.G_MISS_NUM then
	  l_routing_rec.mixed_model_map_flag := g_no;
	End if;
	If l_routing_rec.priority = FND_API.G_MISS_NUM then
	  l_routing_rec.priority := null;
	End if;
	If l_routing_rec.cfm_routing_flag = FND_API.G_MISS_NUM then
	  l_routing_rec.cfm_routing_flag := g_no;
	End if;
	If l_routing_rec.total_product_cycle_time = FND_API.G_MISS_NUM then
	  l_routing_rec.total_product_cycle_time := null;
	End if;
	If l_routing_rec.ctp_flag = FND_API.G_MISS_NUM then
	  l_routing_rec.ctp_flag := g_no;
	End if;
	IF l_routing_rec.pending_from_ecn = FND_API.G_MISS_CHAR THEN
	  l_routing_rec.pending_from_ecn := NULL;
	END IF;

	If p_validation_level > FND_API.G_VALID_LEVEL_NONE then
	  ValidateRouting(
            p_api_version           =>      1,
            p_init_msg_list         =>      p_init_msg_list,
            p_commit                =>      p_commit,
            p_validation_level      =>      p_validation_level,
            x_return_status         =>      l_return_status,
            x_msg_count             =>      l_msg_count,
            x_msg_data              =>      l_msg_data,
            p_routing_rec           =>      l_routing_rec,
            x_routing_rec           =>      l_routing_rec);
          If l_return_status = FND_API.G_RET_STS_ERROR then
	    Raise FND_API.G_EXC_ERROR;
  	  Elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
	    Raise FND_API.G_EXC_UNEXPECTED_ERROR;
          End if; -- validation error
        End if; -- validate before inserting

	l_UserId := nvl(Fnd_Global.USER_ID, -1);
	l_LoginId := Fnd_Global.LOGIN_ID;
	l_RequestId := Fnd_Global.CONC_REQUEST_ID;
	l_ProgramId := Fnd_Global.CONC_PROGRAM_ID;
	l_ApplicationId	:= Fnd_Global.PROG_APPL_ID;
        -- do not use decode because of implicit data type conversions
        If l_RequestId is null then
          l_ProgramUpdate := null;
        Else
          l_ProgramUpdate := sysdate;
        End if;

	Insert into bom_operational_routings(
  	  routing_sequence_id,
	  assembly_item_id,
	  organization_id,
	  alternate_routing_designator,
	  last_update_date,
	  last_updated_by,
	  creation_date,
	  created_by,
	  last_update_login,
	  routing_type,
	  common_assembly_item_id,
	  common_routing_sequence_id,
	  routing_comment,
	  completion_subinventory,
	  completion_locator_id,
	  attribute_category,
	  attribute1,
	  attribute2,
	  attribute3,
	  attribute4,
	  attribute5,
	  attribute6,
	  attribute7,
	  attribute8,
	  attribute9,
	  attribute10,
	  attribute11,
	  attribute12,
	  attribute13,
	  attribute14,
	  attribute15,
	  request_id,
	  program_application_id,
	  program_id,
	  program_update_date,
	  line_id,
	  cfm_routing_flag,
	  mixed_model_map_flag,
	  priority,
	  ctp_flag,
	  total_product_cycle_time,
	  pending_from_ecn)
	values(
  	  l_routing_rec.routing_sequence_id,
	  l_routing_rec.assembly_item_id,
	  l_routing_rec.organization_id,
	  l_routing_rec.alternate_routing_designator,
	  sysdate,
	  l_UserId,
	  sysdate,
	  l_UserId,
	  l_LoginId,
	  l_routing_rec.routing_type,
	  l_routing_rec.common_assembly_item_id,
	  l_routing_rec.common_routing_sequence_id,
	  l_routing_rec.routing_comment,
	  l_routing_rec.completion_subinventory,
	  l_routing_rec.completion_locator_id,
	  l_routing_rec.attribute_category,
	  l_routing_rec.attribute1,
	  l_routing_rec.attribute2,
	  l_routing_rec.attribute3,
	  l_routing_rec.attribute4,
	  l_routing_rec.attribute5,
	  l_routing_rec.attribute6,
	  l_routing_rec.attribute7,
	  l_routing_rec.attribute8,
	  l_routing_rec.attribute9,
	  l_routing_rec.attribute10,
	  l_routing_rec.attribute11,
	  l_routing_rec.attribute12,
	  l_routing_rec.attribute13,
	  l_routing_rec.attribute14,
	  l_routing_rec.attribute15,
	  l_RequestId,
	  l_ApplicationId,
	  l_ProgramId,
	  l_ProgramUpdate,
	  l_routing_rec.line_id,
	  l_routing_rec.cfm_routing_flag,
	  l_routing_rec.mixed_model_map_flag,
	  l_routing_rec.priority,
	  l_routing_rec.ctp_flag,
	  l_routing_rec.total_product_cycle_time,
	  l_routing_rec.pending_from_ecn);

  	If l_routing_rec.alternate_routing_designator is null then
          insert into mtl_rtg_item_revisions(
	    inventory_item_id,
            organization_id,
            process_revision,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login,
            implementation_date,
            effectivity_date)
      	  select
 	    l_routing_rec.assembly_item_id,
            mp.organization_id,
            mp.starting_revision,
            sysdate,
            l_UserId,
            sysdate,
            l_UserId,
	    l_LoginId,
            sysdate,
            sysdate
       	  from mtl_parameters mp
       	  where mp.organization_id = l_routing_rec.organization_id
          and not exists (
            select null
            from mtl_rtg_item_revisions
            where organization_id = l_routing_rec.organization_id
            and inventory_item_id = l_routing_rec.assembly_item_id);
	End if; -- starting routing revision

	x_routing_rec := l_routing_rec;

	-- End of API body.
	-- Standard check of p_commit.
	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT WORK;
	END IF;
	-- Standard call to get message count and if count is 1,
	-- get message info.
	FND_MSG_PUB.Count_And_Get
    	(p_count        =>      x_msg_count,
       	 p_data         =>      x_msg_data
    	);
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO CreateRouting_Pvt;
		x_return_status := FND_API.G_RET_STS_ERROR;
		FND_MSG_PUB.Count_And_Get
    		(p_count        =>      x_msg_count,
         	 p_data         =>      x_msg_data
    		);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO CreateRouting_Pvt;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Count_And_Get
    		(p_count         =>      x_msg_count,
        	 p_data          =>      x_msg_data
    		);
    WHEN OTHERS THEN
		ROLLBACK TO CreateRouting_Pvt;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(G_PKG_NAME,
    	    		 l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(p_count         =>      x_msg_count,
        	 p_data          =>      x_msg_data
    		);
END CreateRouting;

PROCEDURE UpdateRouting
( 	p_api_version           IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level	IN  	NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
	x_return_status		IN OUT NOCOPY	VARCHAR2,
	x_msg_count		    IN OUT NOCOPY	NUMBER,
	x_msg_data		    IN OUT NOCOPY	VARCHAR2,
	p_routing_rec		IN	ROUTING_REC_TYPE := G_MISS_ROUTING_REC,
	x_routing_rec		IN OUT NOCOPY     ROUTING_REC_TYPE
) is
l_api_name		CONSTANT VARCHAR2(30)	:= 'UpdateRouting';
l_api_version        	CONSTANT NUMBER 	:= 1.0;
l_routing_rec		ROUTING_REC_TYPE;
l_return_status        	VARCHAR2(1);
l_msg_count            	NUMBER;
l_msg_data              VARCHAR2(2000);
l_UserId	number;
l_LoginId	number;
l_RequestId	number;
l_ProgramId	number;
l_ProgramUpdate date;
l_ApplicationId	number;
cursor			l_ExistingRouting(p_routing_seq_id number,
		 	p_assy_item_id number, p_org_id number,
			p_alternate varchar2)is
			  Select *
			  From bom_operational_routings bor
			  Where bor.routing_sequence_id = p_routing_seq_id
			  Or (bor.assembly_item_id = p_assy_item_id and
			      bor.organization_id = p_org_id and
			      nvl(bor.alternate_routing_designator,
			          'primary alternate') =
			      nvl(p_alternate, 'primary alternate')
                             );
l_RowFound 	boolean := false; -- old routing found
BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT	UpdateRouting_Pvt;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(
      l_api_version,
      p_api_version,
      l_api_name,
      G_PKG_NAME)
    THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- API body
    l_routing_rec := p_routing_rec;
    If p_validation_level = FND_API.G_VALID_LEVEL_FULL then
      AssignRouting(
        p_api_version           =>     1,
        p_init_msg_list         =>     p_init_msg_list,
        p_commit                =>     p_commit,
        p_validation_level      =>     p_validation_level,
        x_return_status         =>     l_return_status,
        x_msg_count             =>     l_msg_count,
        x_msg_data              =>     l_msg_data,
        p_routing_rec           =>     l_routing_rec,
        x_routing_rec           =>     l_routing_rec
      );
      If l_return_status = FND_API.G_RET_STS_ERROR then
        Raise FND_API.G_EXC_ERROR;
      Elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
        Raise FND_API.G_EXC_UNEXPECTED_ERROR;
      End if; -- assign error
    End If; -- assign

    -- populate unspecified values

    l_RowFound := false;
    For l_OldRtg_rec in l_ExistingRouting(
    p_routing_seq_id => l_routing_rec.routing_sequence_id,
    p_assy_item_id => l_routing_rec.assembly_item_id,
    p_org_id => l_routing_rec.organization_id,
    p_alternate => l_routing_rec.alternate_routing_designator) loop
      l_RowFound := true; -- old routing found
      If l_routing_rec.routing_sequence_id = Fnd_Api.G_Miss_Num then
        l_routing_rec.routing_sequence_id := l_OldRtg_rec.routing_sequence_id;
      End if;
      If l_routing_rec.assembly_item_id = Fnd_Api.G_Miss_Num then
        l_routing_rec.assembly_item_id := l_OldRtg_rec.assembly_item_id;
      End if;
      If l_routing_rec.organization_id = Fnd_Api.G_Miss_Num then
        l_routing_rec.organization_id := l_OldRtg_rec.organization_id;
      End if;
      If l_routing_rec.alternate_routing_designator = Fnd_Api.G_Miss_Char then
        l_routing_rec.alternate_routing_designator :=
          l_OldRtg_rec.alternate_routing_designator;
      End if;

      -- can not update routing type
        l_routing_rec.routing_type := l_OldRtg_rec.routing_type;

      If l_routing_rec.common_assembly_item_id = Fnd_Api.G_Miss_Num then
        l_routing_rec.common_assembly_item_id :=
	  l_OldRtg_rec.common_assembly_item_id;
      End if;
      If l_routing_rec.common_routing_sequence_id = Fnd_Api.G_Miss_Num then
        l_routing_rec.common_routing_sequence_id :=
	  l_OldRtg_rec.common_routing_sequence_id;
      End if;
      If l_routing_rec.routing_comment = Fnd_Api.G_Miss_Char then
        l_routing_rec.routing_comment := l_OldRtg_rec.routing_comment;
      End if;
      If l_routing_rec.completion_subinventory = Fnd_Api.G_Miss_Char then
        l_routing_rec.completion_subinventory :=
	  l_OldRtg_rec.completion_subinventory;
      End if;
      If l_routing_rec.completion_locator_id = Fnd_Api.G_Miss_Num then
        l_routing_rec.completion_locator_id :=
	  l_OldRtg_rec.completion_locator_id;
      End if;
      If l_routing_rec.attribute_category = Fnd_Api.G_Miss_Char then
        l_routing_rec.attribute_category := l_OldRtg_rec.attribute_category;
      End if;
      If l_routing_rec.attribute1 = Fnd_Api.G_Miss_Char then
        l_routing_rec.attribute1 := l_OldRtg_rec.attribute1;
      End if;
      If l_routing_rec.attribute2 = Fnd_Api.G_Miss_Char then
        l_routing_rec.attribute2 := l_OldRtg_rec.attribute2;
      End if;
      If l_routing_rec.attribute3 = Fnd_Api.G_Miss_Char then
        l_routing_rec.attribute3 := l_OldRtg_rec.attribute3;
      End if;
      If l_routing_rec.attribute4 = Fnd_Api.G_Miss_Char then
        l_routing_rec.attribute4 := l_OldRtg_rec.attribute4;
      End if;
      If l_routing_rec.attribute5 = Fnd_Api.G_Miss_Char then
        l_routing_rec.attribute5 := l_OldRtg_rec.attribute5;
      End if;
      If l_routing_rec.attribute6 = Fnd_Api.G_Miss_Char then
        l_routing_rec.attribute6 := l_OldRtg_rec.attribute6;
      End if;
      If l_routing_rec.attribute7 = Fnd_Api.G_Miss_Char then
        l_routing_rec.attribute7 := l_OldRtg_rec.attribute7;
      End if;
      If l_routing_rec.attribute8 = Fnd_Api.G_Miss_Char then
        l_routing_rec.attribute8 := l_OldRtg_rec.attribute8;
      End if;
      If l_routing_rec.attribute9 = Fnd_Api.G_Miss_Char then
        l_routing_rec.attribute9 := l_OldRtg_rec.attribute9;
      End if;
      If l_routing_rec.attribute10 = Fnd_Api.G_Miss_Char then
        l_routing_rec.attribute10 := l_OldRtg_rec.attribute10;
      End if;
      If l_routing_rec.attribute11 = Fnd_Api.G_Miss_Char then
        l_routing_rec.attribute11 := l_OldRtg_rec.attribute11;
      End if;
      If l_routing_rec.attribute12 = Fnd_Api.G_Miss_Char then
        l_routing_rec.attribute12 := l_OldRtg_rec.attribute12;
      End if;
      If l_routing_rec.attribute13 = Fnd_Api.G_Miss_Char then
        l_routing_rec.attribute13 := l_OldRtg_rec.attribute13;
      End if;
      If l_routing_rec.attribute14 = Fnd_Api.G_Miss_Char then
        l_routing_rec.attribute14 := l_OldRtg_rec.attribute14;
      End if;
      If l_routing_rec.attribute15 = Fnd_Api.G_Miss_Char then
        l_routing_rec.attribute15 := l_OldRtg_rec.attribute15;
      End if;
      If l_routing_rec.line_id = Fnd_Api.G_Miss_Num then
        l_routing_rec.line_id := l_OldRtg_rec.line_id;
      End if;

      -- CFM flag is not updatable
        l_routing_rec.cfm_routing_flag := l_OldRtg_rec.cfm_routing_flag;

      If l_routing_rec.mixed_model_map_flag = Fnd_Api.G_Miss_Num then
        l_routing_rec.mixed_model_map_flag :=
	  l_OldRtg_rec.mixed_model_map_flag;
      End if;
      If l_routing_rec.priority = Fnd_Api.G_Miss_Num then
        l_routing_rec.priority := l_OldRtg_rec.priority;
      End if;
      If l_routing_rec.ctp_flag = Fnd_Api.G_Miss_Num then
        l_routing_rec.ctp_flag := l_OldRtg_rec.ctp_flag;
      End if;
      If l_routing_rec.total_product_cycle_time = Fnd_Api.G_Miss_Num then
        l_routing_rec.total_product_cycle_time :=
	  l_OldRtg_rec.total_product_cycle_time;
      End if;
    End loop; -- get old values

    If not l_RowFound then -- old routing not found
      Fnd_Message.Set_Name('BOM', 'BOM_ROUTING_MISSING');
      FND_MSG_PUB.Add;
      Raise FND_API.G_EXC_ERROR;
    End if; -- missing routing

    If p_validation_level > FND_API.G_VALID_LEVEL_NONE then
      ValidateRouting(
        p_api_version           =>     1,
        p_init_msg_list         =>     p_init_msg_list,
        p_commit                =>     p_commit,
        p_validation_level      =>     FND_API.G_VALID_LEVEL_NONE,
        x_return_status         =>     l_return_status,
        x_msg_count             =>     l_msg_count,
        x_msg_data              =>     l_msg_data,
        p_routing_rec           =>     l_routing_rec,
        x_routing_rec           =>     l_routing_rec
      );
      If l_return_status = FND_API.G_RET_STS_ERROR then
        Raise FND_API.G_EXC_ERROR;
      Elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
        Raise FND_API.G_EXC_UNEXPECTED_ERROR;
      End if; -- validation error
    End If; -- validation

    -- update routing

    l_UserId := nvl(Fnd_Global.USER_ID, -1);
    l_LoginId := Fnd_Global.LOGIN_ID;
    l_RequestId := Fnd_Global.CONC_REQUEST_ID;
    l_ProgramId := Fnd_Global.CONC_PROGRAM_ID;
    l_ApplicationId := Fnd_Global.PROG_APPL_ID;
    -- do not use decode because of implicit data type conversions
    If l_RequestId is null then
      l_ProgramUpdate := null;
    Else
      l_ProgramUpdate := sysdate;
    End if;
    update bom_operational_routings set
      last_update_date = sysdate,
      last_updated_by = l_UserId,
    --  creation_date = nvl(creation_date,sysdate),  /* Commented for Bug 3271195 */
    --  created_by = l_UserId,                       /* Commented for Bug 3271195 */
      last_update_login = l_LoginId,
      common_assembly_item_id = l_routing_rec.common_assembly_item_id,
      common_routing_sequence_id = l_routing_rec.common_routing_sequence_id,
      routing_comment = l_routing_rec.routing_comment,
      completion_subinventory = l_routing_rec.completion_subinventory,
      completion_locator_id = l_routing_rec.completion_locator_id,
      attribute_category = l_routing_rec.attribute_category,
      attribute1 = l_routing_rec.attribute1,
      attribute2 = l_routing_rec.attribute2,
      attribute3 = l_routing_rec.attribute3,
      attribute4 = l_routing_rec.attribute4,
      attribute5 = l_routing_rec.attribute5,
      attribute6 = l_routing_rec.attribute6,
      attribute7 = l_routing_rec.attribute7,
      attribute8 = l_routing_rec.attribute8,
      attribute9 = l_routing_rec.attribute9,
      attribute10 = l_routing_rec.attribute10,
      attribute11 = l_routing_rec.attribute11,
      attribute12 = l_routing_rec.attribute12,
      attribute13 = l_routing_rec.attribute13,
      attribute14 = l_routing_rec.attribute14,
      attribute15 = l_routing_rec.attribute15,
      request_id = l_RequestId,
      program_application_id = l_ApplicationId,
      program_id = l_ProgramId,
      program_update_date = l_ProgramUpdate,
      line_id = l_routing_rec.line_id,
      cfm_routing_flag = l_routing_rec.cfm_routing_flag,
      mixed_model_map_flag = l_routing_rec.mixed_model_map_flag,
      priority = l_routing_rec.priority,
      ctp_flag = l_routing_rec.ctp_flag,
      total_product_cycle_time = l_routing_rec.total_product_cycle_time
    Where routing_sequence_id = l_routing_rec.routing_sequence_id
    Or   (assembly_item_id = l_routing_rec.assembly_item_id and
	  organization_id = l_routing_rec.organization_id and
	  nvl(alternate_routing_designator, 'Primary Alternate') =
	  nvl(l_routing_rec.alternate_routing_designator, 'Primary Alternate')
          );

    x_routing_rec := l_routing_rec;
    -- End of API body.

    -- Standard check of p_commit.
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data => x_msg_data);
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO UpdateRouting_Pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_count => x_msg_count,
        p_data => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO UpdateRouting_Pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(
        p_count => x_msg_count,
        p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO UpdateRouting_Pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(
  	p_count => x_msg_count,
      	p_data => x_msg_data);
End UpdateRouting;
PROCEDURE DeleteRouting
( 	p_api_version           IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level	IN  	NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
	x_return_status		IN OUT NOCOPY	VARCHAR2,
	x_msg_count		    IN OUT NOCOPY	NUMBER,
	x_msg_data		    IN OUT NOCOPY	VARCHAR2,
	p_delete_group		IN	VARCHAR2,
        p_description		IN	VARCHAR2 := null,
	p_routing_rec		IN	ROUTING_REC_TYPE := G_MISS_ROUTING_REC,
	x_routing_rec		IN OUT NOCOPY     ROUTING_REC_TYPE
) is
l_api_name		CONSTANT VARCHAR2(30)	:= 'DeleteRouting';
l_api_version   	CONSTANT NUMBER 	:= 1.0;
l_routing_rec		ROUTING_REC_TYPE;
l_DeleteGrpSeqId 	number := null;
l_return_status        	VARCHAR2(1);
l_msg_count            	NUMBER;
l_msg_data              VARCHAR2(2000);
l_UserId		number;
cursor			l_ExistingRouting(p_routing_seq_id number,
		 	p_assy_item_id number, p_org_id number,
			p_alternate varchar2)is
			  Select bor.routing_sequence_id,
			         bor.assembly_item_id,
			         bor.organization_id,
			         bor.alternate_routing_designator,
			 	 bor.routing_type
			  From bom_operational_routings bor
			  Where bor.routing_sequence_id = p_routing_seq_id
			  Or (bor.assembly_item_id = p_assy_item_id and
			      bor.organization_id = p_org_id and
			      nvl(bor.alternate_routing_designator,
			          'primary alternate') =
			      nvl(p_alternate, 'primary alternate')
                             );
l_RowFound 		boolean := false; -- old routing found
cursor			l_group_csr(P_OrgId number) is
		  	  Select delete_group_sequence_id
		    	  From bom_delete_groups
		  	  Where delete_group_name = p_delete_group
 			  And organization_id = P_OrgId;
l_routing		constant number := 3; -- delete type
l_ReturnCode		number;
BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT DeleteRouting_Pvt;
  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
  G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;
  --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- API body
  l_routing_rec := p_routing_rec;
  If p_validation_level = FND_API.G_VALID_LEVEL_FULL then
    AssignRouting(
      p_api_version           =>     1,
      p_init_msg_list         =>     p_init_msg_list,
      p_commit                =>     p_commit,
      p_validation_level      =>     p_validation_level,
      x_return_status         =>     l_return_status,
      x_msg_count             =>     l_msg_count,
      x_msg_data              =>     l_msg_data,
      p_routing_rec           =>     l_routing_rec,
      x_routing_rec           =>     l_routing_rec
    );
    If l_return_status = FND_API.G_RET_STS_ERROR then
      Raise FND_API.G_EXC_ERROR;
    Elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
      Raise FND_API.G_EXC_UNEXPECTED_ERROR;
    End if; -- assign error
  End If; -- assign

  l_DeleteGrpSeqId := null;
  For l_DelGrp_rec in l_group_csr(
  P_OrgId => l_routing_rec.organization_id) loop
    l_DeleteGrpSeqId :=  l_DelGrp_rec.delete_group_sequence_id;
  End loop; -- get existing delete group

  l_UserId := nvl(Fnd_Global.USER_ID, -1);

  For l_OldRtg_rec in l_ExistingRouting(
  p_routing_seq_id => l_routing_rec.routing_sequence_id,
  p_assy_item_id => l_routing_rec.assembly_item_id,
  p_org_id => l_routing_rec.organization_id,
  p_alternate => l_routing_rec.alternate_routing_designator) loop
    l_RowFound := true; -- old routing found
    l_ReturnCode := MODAL_DELETE.DELETE_MANAGER_OI(
      new_group_seq_id        => l_DeleteGrpSeqId,
      name                    => p_delete_group,
      group_desc              => p_description,
      org_id                  => l_OldRtg_rec.organization_id,
      bom_or_eng              => l_OldRtg_rec.routing_type,
      del_type                => l_routing,
      ent_bill_seq_id         => null,
      ent_rtg_seq_id          => l_OldRtg_rec.routing_sequence_id,
      ent_inv_item_id         => l_OldRtg_rec.assembly_item_id,
      ent_alt_designator      => l_OldRtg_rec.alternate_routing_designator,
      ent_comp_seq_id         => null,
      ent_op_seq_id           => null,
      user_id                 => l_UserId,
      err_text                => l_msg_data
    );
    If l_ReturnCode <> 0 then
      Fnd_Msg_Pub.Add_Exc_Msg (
	p_pkg_name => 'MODAL_DELETE',
  	p_procedure_name => 'DELETE_MANAGER_OI',
  	p_error_text => l_msg_data
      );
      Raise FND_API.G_EXC_UNEXPECTED_ERROR;
    End if; -- SQL error in modal delete
  End loop; -- Add to delete group

  If not l_RowFound then -- old routing not found
    Fnd_Message.Set_Name('BOM', 'BOM_ROUTING_MISSING');
    FND_MSG_PUB.Add;
    Raise FND_API.G_EXC_ERROR;
  End if; -- missing routing

  x_routing_rec := l_routing_rec;
  -- End of API body.

  -- Standard check of p_commit.
  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;
  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(
    p_count => x_msg_count,
    p_data => x_msg_data
  );
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO DeleteRouting_Pvt;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO DeleteRouting_Pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
  WHEN OTHERS THEN
    ROLLBACK TO DeleteRouting_Pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
END DeleteRouting;

PROCEDURE createrouting
(
	p_api_version		IN NUMBER,
	x_return_status		IN OUT NOCOPY VARCHAR2,
	x_msg_count			IN OUT NOCOPY NUMBER,
	x_msg_data			IN OUT	NOCOPY VARCHAR2,
	p_description		IN VARCHAR2,
	p_assembly_item_id	IN NUMBER,
	p_organization_id	IN NUMBER,
	p_alt_rtg_desig		IN VARCHAR2,
	p_routing_type		IN NUMBER,
	p_common_assembly_item_id IN NUMBER,
	p_common_rtg_seq_id IN NUMBER,
	p_routing_comment	IN VARCHAR2,
	p_copy_request_id   IN NUMBER,
	p_user_id           IN NUMBER,
	p_change_notice     IN VARCHAR2,
	x_rtg_seq_id		IN OUT NOCOPY NUMBER
) IS
l_api_name	CONSTANT VARCHAR2(30)	:= 'CreateRouting';
l_api_version   CONSTANT NUMBER 	:= 1;
l_routing_rec bom_routingheader_pvt.routing_rec_type;
x_routing_rec bom_routingheader_pvt.routing_rec_type;
BEGIN
   	SAVEPOINT	createrouting_pvt;
   	-- Standard call to check for call compatibility.
   	IF NOT fnd_api.compatible_api_call(l_api_version,
        	    	    	    	   p_api_version,
       	       	    	 			   l_api_name,
		    	    	    	       G_PKG_NAME)
	THEN
		RAISE fnd_api.g_exc_unexpected_error;
	END IF;
	--  Initialize API return status to success
   	x_return_status := fnd_api.g_ret_sts_success;
	l_routing_rec.assembly_item_id := p_assembly_item_id;
	l_routing_rec.routing_sequence_id := NULL; -- Create will not have the sequence id
	l_routing_rec.organization_id := p_organization_id;
	l_routing_rec.alternate_routing_designator := p_alt_rtg_desig;
	l_routing_rec.routing_type := p_routing_type;
	l_routing_rec.common_assembly_item_id := p_common_assembly_item_id;
	l_routing_rec.common_routing_sequence_id := p_common_rtg_seq_id;
	l_routing_rec.routing_comment := p_routing_comment;
	l_routing_rec.pending_from_ecn := p_change_notice;

	CreateRouting (
	    p_api_version           =>      p_api_version,
            p_init_msg_list         =>      fnd_api.G_TRUE,
            p_commit                =>      fnd_api.G_FALSE,
            p_validation_level      =>      fnd_api.G_VALID_LEVEL_FULL,
            x_return_status         =>      x_return_status,
            x_msg_count             =>      x_msg_count,
            x_msg_data              =>      x_msg_data,
            p_routing_rec           =>      l_routing_rec,
            x_routing_rec           =>      x_routing_rec
          );

	 IF ( x_return_status = fnd_api.g_ret_sts_success ) THEN
		 x_rtg_seq_id := x_routing_rec.routing_sequence_id;
	 ELSE
            INSERT INTO mtl_interface_errors
                        (unique_id,
                         organization_id,
                         transaction_id,
                         table_name,
                         column_name,
                         error_message,
                         bo_identifier,
                         last_update_date,
                         last_updated_by,
                         creation_date,
                         created_by,
						 message_type
                        )
                 VALUES (p_assembly_item_id,
                         p_organization_id,
                         p_copy_request_id,
                         NULL,
                         bom_copy_bill.get_current_item_rev
                                             (p_assembly_item_id,
                                              p_organization_id,
                                              SYSDATE
                                             ),
                         x_msg_data,
                         'BOM_COPY',
                         SYSDATE,
                         p_user_id,
                         SYSDATE,
                         p_user_id,
						 'E'
                        );
	 END IF;
END;


END BOM_RoutingHeader_PVT;

/
