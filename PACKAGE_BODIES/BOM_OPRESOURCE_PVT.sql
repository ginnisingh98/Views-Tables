--------------------------------------------------------
--  DDL for Package Body BOM_OPRESOURCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_OPRESOURCE_PVT" AS
-- $Header: BOMVRESB.pls 120.2.12010000.2 2008/11/14 16:45:18 snandana ship $

G_PKG_NAME 	CONSTANT VARCHAR2(30):='Bom_OpResource_Pvt';
g_event		constant number := 1;
g_yes		constant number := 1;
g_no		constant number := 2;

PROCEDURE AssignResource(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       IN OUT NOCOPY     VARCHAR2,
  x_msg_count           IN OUT NOCOPY     NUMBER,
  x_msg_data            IN OUT NOCOPY     VARCHAR2,
  p_resource_rec        IN      RESOURCE_REC_TYPE := G_MISS_RESOURCE_REC,
  x_resource_rec        IN OUT NOCOPY     RESOURCE_REC_TYPE
) is
l_api_name		CONSTANT VARCHAR2(30)	:= 'AssignResource';
l_api_version   	CONSTANT NUMBER 	:= 1.0;
l_resource_rec        	RESOURCE_REC_TYPE;
l_ret_code              NUMBER;
l_err_text              varchar2(2000);
cursor          l_assy_csr(P_RtgSeqId number) is
                  Select assembly_item_id,
                         organization_id,
                         alternate_routing_designator
                  From bom_operational_routings
                  Where routing_sequence_id = P_RtgSeqId;
cursor          l_parameter_csr(P_Code varchar2) is
                  Select organization_id
                  From mtl_parameters
                  Where organization_code = P_Code;
cursor          l_routing_csr(P_AssyItemId number, P_OrgId number,
                P_Alternate varchar2) is
                  select routing_sequence_id
                  from bom_operational_routings
                  where organization_id = P_OrgId
                  and   assembly_item_id = P_AssyItemId
                  and   nvl(alternate_routing_designator, 'Primary Alternate') =
                        nvl(P_Alternate, 'Primary Alternate');
cursor		l_event_csr(P_OpSeqId number) is
		  Select operation_type,
		         reference_flag
		  From bom_operation_sequences
		  Where operation_sequence_id = P_OpSeqId;
l_EventFound	BOOLEAN := FALSE;
cursor		l_oper_csr(P_RtgSeqId number, P_SeqNum number, P_EffDate Date)
		is
		  select operation_sequence_id
        	  from bom_operation_sequences
        	  where routing_sequence_id = P_RtgSeqId
        	  and   operation_seq_num = P_SeqNum
                  /* Bug # 1376700  */
                  and   trunc(effectivity_date) = trunc(P_EffDate)
		  and   nvl(operation_type, g_event) = g_event
		  and   nvl(reference_flag, g_no) = g_no;
cursor		l_NonOpResource_csr(P_Code varchar2, P_OrgId number) is
		  select resource_id
                  from bom_resources
                  where resource_code = P_Code
                  and organization_id = P_OrgId;
cursor		l_Activity_csr(P_Code varchar2, P_OrgId number) is
		  select activity_id
                  from cst_activities
                  where activity = P_Code
                  and nvl(organization_id, P_OrgId) = P_OrgId;
cursor 	 	l_defaults_csr(P_OpSeqId number, P_ResourceId number) is
		  select br.default_basis_type,
               		 br.default_activity_id,
                         decode(bd.location_id,
				NULL, decode(br.AUTOCHARGE_TYPE,
					     NULL, 2,
					     3, 2,
					     4, 2,
					     br.AUTOCHARGE_TYPE),
 				nvl(br.AUTOCHARGE_TYPE, 2)) default_autocharge,
               		 br.standard_rate_flag
          	  from bom_resources br,
		       bom_departments bd,
		       bom_operation_sequences bos
         	  where br.resource_id = P_ResourceId
		  and   bos.operation_sequence_id = P_OpSeqId
		  and   bd.department_id = bos.department_id;

BEGIN
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
  l_resource_rec := p_resource_rec;

  -- get routing info
  If nvl(l_resource_rec.routing_sequence_id, FND_API.G_MISS_NUM) <>
  FND_API.G_MISS_NUM then
    For l_assy_rec in l_assy_csr(
    P_RtgSeqId => l_resource_rec.routing_sequence_id) loop
      l_resource_rec.assembly_item_id := l_assy_rec.assembly_item_id;
      l_resource_rec.organization_id := l_assy_rec.organization_id;
      l_resource_rec.alternate_routing_designator :=
        l_assy_rec.alternate_routing_designator;
    End loop;
  End if; -- check routing

 -- set organization id

  If nvl(l_resource_rec.organization_code, FND_API.G_MISS_CHAR) <>
  FND_API.G_MISS_CHAR then
    l_resource_rec.organization_id := null;
    For l_parameter_rec in l_parameter_csr(
    P_Code => l_resource_rec.organization_code) loop
      l_resource_rec.organization_id := l_parameter_rec.organization_id;
    End loop;
    If l_resource_rec.organization_id is null then
      Fnd_Message.Set_Name('BOM', 'BOM_ORG_ID_MISSING');
      FND_MSG_PUB.Add;
      raise FND_API.G_EXC_ERROR;
    End if; -- invalid org
  End if; -- organization code

  -- get assembly item number
  If nvl(l_resource_rec.Assembly_Item_Number, FND_API.G_MISS_CHAR) <>
  FND_API.G_MISS_CHAR then
    l_ret_code := INVPUOPI.mtl_pr_trans_prod_item(
                org_id => l_resource_rec.organization_id,
                item_number_in => l_resource_rec.assembly_item_number,
                item_id_out => l_resource_rec.assembly_item_id,
                err_text => l_err_text);
    if l_ret_code <> 0 then
      Fnd_Message.Set_Name('BOM', 'BOM_ASSY_ITEM_MISSING');
      FND_MSG_PUB.Add;
      raise FND_API.G_EXC_ERROR;
    end if;  -- parse failed
  end if; -- assembly item number

  -- null routing sequence id
  If nvl(l_resource_rec.routing_sequence_id, FND_API.G_MISS_NUM) =
  FND_API.G_MISS_NUM then
    If l_resource_rec.alternate_routing_designator = FND_API.G_MISS_CHAR then
      l_resource_rec.alternate_routing_designator := null;
    End if;
    For l_routing_rec in l_routing_csr(
    P_AssyItemId => l_resource_rec.assembly_item_id,
    P_OrgId => l_resource_rec.organization_id,
    P_Alternate => l_resource_rec.alternate_routing_designator) loop
      l_resource_rec.routing_sequence_id :=
        l_routing_rec.routing_sequence_id;
    End loop;
  End if; -- get routing sequence id

  -- Can only be associated with non-referenced operations of type Event
  If nvl(l_resource_rec.operation_sequence_id, Fnd_Api.G_Miss_Num) <>
  Fnd_Api.G_Miss_Num then
    l_EventFound := FALSE;
    For l_event_rec in l_event_csr(
    P_OpSeqId => l_resource_rec.operation_sequence_id) loop
      l_EventFound := TRUE;
      If l_event_rec.reference_flag = g_yes or
      l_event_rec.operation_type <> g_event then
        Fnd_Message.Set_Name('BOM', 'BOM_EVENT_RESOURCE');
        FND_MSG_PUB.Add;
        Raise FND_API.G_EXC_ERROR;
      End if;
    End loop;
    If not l_EventFound then
      Fnd_Message.Set_Name('BOM', 'BOM_OP_SEQ_INVALID');
      FND_MSG_PUB.Add;
      Raise FND_API.G_EXC_ERROR;
    End if; -- invalid op seq id
  End if; -- non-referenced event?

  --  Get operation sequence id
  If nvl(l_resource_rec.operation_sequence_id, Fnd_Api.G_Miss_Num) =
  Fnd_Api.G_Miss_Num then
    For l_operation_rec in l_oper_csr(
    P_RtgSeqId => l_resource_rec.routing_sequence_id,
    P_SeqNum => l_resource_rec.operation_seq_num,
    P_EffDate => l_resource_rec.effectivity_date) loop
      l_resource_rec.operation_sequence_id :=
	l_operation_rec.operation_sequence_id;
    End loop;
  End if; -- get operation
  If nvl(l_resource_rec.operation_sequence_id, Fnd_Api.G_Miss_Num) =
  Fnd_Api.G_Miss_Num then
    -- operation not found (must also be non-referenced event)
    Fnd_Message.Set_Name('BOM', 'BOM_OP_SEQ_INVALID');
    FND_MSG_PUB.Add;
    Raise FND_API.G_EXC_ERROR;
  End if;

  -- Get resource_id
  If nvl(l_resource_rec.resource_code, Fnd_Api.G_Miss_Char) <>
  Fnd_Api.G_Miss_Char then
    l_resource_rec.resource_id := null;
    For l_SetUpResource_rec in 	l_NonOpResource_csr(
    P_Code => l_resource_rec.resource_code,
    P_OrgId =>l_resource_rec.organization_id) loop
      l_resource_rec.resource_id := l_SetUpResource_rec.resource_id;
    End loop;
    If l_resource_rec.resource_id is null then
      Fnd_Message.Set_Name('BOM', 'BOM_RESOURCE_ID_MISSING');
      FND_MSG_PUB.Add;
      Raise FND_API.G_EXC_ERROR;
    End if; -- invalid resource
  End if; -- get resource id

  -- Get activity_id
  If nvl(l_resource_rec.activity, Fnd_Api.G_Miss_Char) <>
  Fnd_Api.G_Miss_Char then
    l_resource_rec.activity_id := null;
    For l_activity_rec in l_Activity_csr(
    P_Code => l_resource_rec.activity,
    P_OrgId => l_resource_rec.organization_id) loop
      l_resource_rec.activity_id := l_activity_rec.activity_id;
    End loop;
    If l_resource_rec.activity_id is null then
      Fnd_Message.Set_Name('BOM', 'BOM_ACTIVITY_INVALID');
      FND_MSG_PUB.Add;
      Raise FND_API.G_EXC_ERROR;
    End if; -- invalid activity
  End if; -- get activity id

  -- usage rates
/* Bug 1349028 */
  If (l_resource_rec.usage_rate_or_amount_inverse is null) or
     ((l_resource_rec.usage_rate_or_amount_inverse = Fnd_Api.G_Miss_Num) and
      (l_resource_rec.usage_rate_or_amount <> Fnd_Api.G_Miss_Num)) then
    If l_resource_rec.usage_rate_or_amount = 0 then
      l_resource_rec.usage_rate_or_amount_inverse := 0;
    Else
-- Bug 1533214
      l_resource_rec.usage_rate_or_amount := round (l_resource_rec.usage_rate_or_amount,G_round_off_val); /* Bug 7322996 */
      l_resource_rec.usage_rate_or_amount_inverse :=
        1 / l_resource_rec.usage_rate_or_amount;
    End if;
  End if; -- null inverse

  If (l_resource_rec.usage_rate_or_amount is null) or
     ((l_resource_rec.usage_rate_or_amount = Fnd_Api.G_Miss_Num) and
      (l_resource_rec.usage_rate_or_amount_inverse <> Fnd_Api.G_Miss_Num)) then
    If l_resource_rec.usage_rate_or_amount_inverse = 0 then
      l_resource_rec.usage_rate_or_amount := 0;
    Else
-- Bug 1533214
      l_resource_rec.usage_rate_or_amount_inverse := round (l_resource_rec.usage_rate_or_amount_inverse ,G_round_off_val); /* Bug 7322996 */
      l_resource_rec.usage_rate_or_amount :=
        1 / l_resource_rec.usage_rate_or_amount_inverse;
    End if;
  End if; -- null usage rate

  -- Get Basis and Autocharge defaults
  For l_defaults_rec in l_defaults_csr(
  P_OpSeqId => l_resource_rec.operation_sequence_id,
  P_ResourceId => l_resource_rec.resource_id) loop
    If l_resource_rec.basis_type is null then
      l_resource_rec.basis_type := nvl(l_defaults_rec.default_basis_type,1);
    End if;
    If l_resource_rec.activity_id is null then
      l_resource_rec.activity_id := l_defaults_rec.default_activity_id;
    End if;
    If l_resource_rec.autocharge_type is null then
      l_resource_rec.autocharge_type := l_defaults_rec.default_autocharge;
    End if;
    If l_resource_rec.standard_rate_flag is null then
      l_resource_rec.standard_rate_flag := l_defaults_rec.standard_rate_flag;
    End if;
  End loop; -- defaults

  x_resource_rec := l_resource_rec;
  -- End of API body.

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(
    p_count => x_msg_count,
    p_data => x_msg_data
  );
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
END AssignResource;

PROCEDURE ValidateResource(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       IN OUT NOCOPY     VARCHAR2,
  x_msg_count           IN OUT NOCOPY     NUMBER,
  x_msg_data            IN OUT NOCOPY     VARCHAR2,
  p_resource_rec        IN      RESOURCE_REC_TYPE := G_MISS_RESOURCE_REC,
  x_resource_rec        IN OUT NOCOPY     RESOURCE_REC_TYPE
) is
l_api_name		CONSTANT VARCHAR2(30)	:= 'ValidateResource';
l_api_version   	CONSTANT NUMBER 	:= 1.0;
l_resource_rec         	RESOURCE_REC_TYPE;
l_return_status         VARCHAR(1);
l_msg_count             NUMBER;
l_msg_data              VARCHAR(2000);
--<BUGFIX :1746461 Begin>
rate_invalid            NUMBER;
--<BUGFIX :1746461 End>
cursor			l_operation_csr(P_OpSeqId number) is
			  Select 'x' dummy
			  From dual
			  Where not exists(
			    select null
        		    from bom_operation_sequences
        		    where operation_sequence_id = P_OpSeqId
			    and   nvl(operation_type, g_event) = g_event
			    and   nvl(reference_flag, g_no) = g_no);
cursor			l_resource_csr(P_OpSeqId number, P_ResourceId number) is
			  select 'x' dummy
			  from dual
			  where not exists (
        		    select null
                	    from bom_resources br,
			    bom_department_resources bdr,
			    bom_operation_sequences bos
                	    where br.resource_id = P_ResourceId
			    and bos.operation_sequence_id = P_OpSeqId
               		    and nvl(br.disable_date, bos.effectivity_date + 1)
			        > bos.effectivity_date
                	    and bdr.department_id = bos.department_id
                	    and bdr.resource_id = br.resource_id);
cursor			l_DeptRes_csr(P_ResourceId number, P_OpSeqId number) is
			  select bdr.AVAILABLE_24_HOURS_FLAG,
				 bd.location_id
             		  from bom_department_resources bdr,
                  	       bom_departments bd,
			       bom_operation_sequences bos
            		  where bdr.resource_id = P_ResourceId
			  and   bos.operation_sequence_id = P_OpSeqId
              		  and bdr.department_id = bos.department_id
              		  and bdr.department_id = bd.department_id;
cursor			l_activity_csr(P_ActivityId number, P_OpSeqId number) is
		   	Select 'x' dummy
			From dual
			Where not exists(
			  select null
                	  from cst_activities ca,
			       bom_operation_sequences bos,
			       bom_operational_routings bor
                	  where ca.activity_id = P_ActivityId
			  and   bos.operation_sequence_id = P_OpSeqId
			  and   bos.routing_sequence_id =
			 	bor.routing_sequence_id
                	  and   nvl(ca.organization_id, bor.organization_id)
                        	= bor.organization_id
                	  and   nvl(ca.disable_date, bos.effectivity_date + 1)
			        > bos.effectivity_date);
cursor			l_DupResource_csr(P_OpSeqId number, P_OldSeqNum number,
			P_NewSeqNum number) is
			  Select 'x' dummy
			  From dual
			  Where exists(
			    Select null
        		    from bom_operation_resources bor
        		    where bor.operation_sequence_id = P_OpSeqId
        		    and   bor.resource_seq_num = P_NewSeqNum
        		    and   (bor.resource_seq_num <> P_OldSeqNum
				   or P_OldSeqNum is null));
l_HourUomCode		VARCHAR2(3);
l_HourUomClass		VARCHAR2(10);
l_ResUomCode		VARCHAR2(3);
l_ResUomClass		VARCHAR2(10);
cursor			l_uom_csr(P_ResourceId number) is
			  Select unit_of_measure
			  From bom_resources
			  Where resource_id = P_ResourceId;
cursor			l_class_csr(P_Code varchar2) is
			  Select uom_class
			  From mtl_units_of_measure
			  Where uom_code = P_Code;
cursor			l_conversion_csr is
			  Select 'x' dummy
			  From dual
			  where not exists(
			    select null
                            from mtl_uom_conversions a,
                                 mtl_uom_conversions b
                       	    where a.uom_code = l_ResUomCode
                       	    and   a.uom_class = l_ResUomClass
                       	    and   a.inventory_item_id = 0
                       	    and   nvl(a.disable_date, sysdate + 1) > sysdate
                       	    and   b.uom_code = l_HourUomCode
                       	    and   b.inventory_item_id = 0
                       	    and   b.uom_class = a.uom_class);
cursor			l_schedule_csr(P_OpSeqId number, P_SeqNum number,
			P_SchedType number) is
			  Select 'x' dummy
			  From dual
        		  Where exists(
			    select null
        		    from bom_operation_resources bor
        		    where operation_sequence_id = P_OpSeqId
			    and (resource_seq_num <> P_SeqNum or
			         P_SeqNum is null)
        		    and schedule_flag = P_SchedType);
l_Prior			constant number := 3;
l_Next			constant number := 4;
l_POReceipt		constant number := 3;
l_POMove		constant number := 4;
cursor			l_pomove_csr(P_OpSeqId number, P_SeqNum number) is
			  select 'x' dummy
			  from dual
			  where exists(
       			    select null
        		    from bom_operation_resources
        		    where operation_sequence_id = P_OpSeqId
			    and (P_SeqNum is null or
				 resource_seq_num <> P_SeqNum)
        		    and   autocharge_type = l_POMove);
cursor 			l_CheckLocation_csr(P_OpSeqId number) is
        		  select 1 dummy
        		  from dual
        		  where not exists(
			    select 'no dept loc'
                    	    from bom_departments bd,
			         bom_operation_sequences bos
                      	    where bos.operation_sequence_id = P_OpSeqId
			    and   bd.department_id = bos.department_id
                    	    and   bd.location_id is not null);
BEGIN
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
  l_resource_rec := p_resource_rec;

  If p_validation_level = FND_API.G_VALID_LEVEL_FULL then
    AssignResource(
      p_api_version       => 1,
      p_init_msg_list     => p_init_msg_list,
      p_commit            => p_commit,
      p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
      x_return_status     => l_return_status,
      x_msg_count         => l_msg_count,
      x_msg_data          => l_msg_data,
      p_resource_rec      => l_resource_rec,
      x_resource_rec      => l_resource_rec);
    If l_return_status = FND_API.G_RET_STS_ERROR then
      Raise FND_API.G_EXC_ERROR;
    Elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
      Raise FND_API.G_EXC_UNEXPECTED_ERROR;
    End if; -- error
  End if; -- assign values

  -- verify for existence of operation seq id
  For l_operation_rec in l_operation_csr(
  P_OpSeqId => l_resource_rec.operation_sequence_id) loop
    Fnd_Message.Set_Name('BOM', 'BOM_OP_SEQ_INVALID');
    FND_MSG_PUB.Add;
    Raise FND_API.G_EXC_ERROR;
  End loop;

  -- check for null resource seq num
  If l_resource_rec.new_resource_seq_num is null then
    Fnd_Message.Set_Name('BOM', 'BOM_NULL_RESOURCE_SEQ_NUM');
    FND_MSG_PUB.Add;
    Raise FND_API.G_EXC_ERROR;
  End if;

  -- check for duplicate resource seq num/operation sequence id
  For l_DupResource_rec in l_DupResource_csr(
  P_OpSeqId => l_resource_rec.operation_sequence_id,
  P_OldSeqNum => l_resource_rec.resource_seq_num,
  P_NewSeqNum => l_resource_rec.new_resource_seq_num) loop
    Fnd_Message.Set_Name('BOM', 'BOM_DUPLICATE_RES_NUM');
    FND_MSG_PUB.Add;
    Raise FND_API.G_EXC_ERROR;
  End loop;

  -- validate resource exists and is enabled and belongs to dept
  For l_InvalidResource_rec in l_resource_csr(
  P_OpSeqId => l_resource_rec.operation_sequence_id,
  P_ResourceId => l_resource_rec.resource_id) loop
    Fnd_Message.Set_Name('BOM', 'BOM_DEPT_RES_INVALID');
    FND_MSG_PUB.Add;
    Raise FND_API.G_EXC_ERROR;
  End loop;

  -- Check if resource is available 24 hours

  If l_resource_rec.assigned_units is null then
    l_resource_rec.assigned_units := 1;
  End if;
  For l_DeptRes_rec in l_DeptRes_csr(
  P_ResourceId => l_resource_rec.resource_id,
  P_OpSeqId => l_resource_rec.operation_sequence_id) loop
    If l_DeptRes_rec.available_24_hours_flag = g_yes then
      l_resource_rec.assigned_units := 1;
    End if;
  End loop;

  -- verify activity is enabled
  if l_resource_rec.activity_id is not null then
    For l_activity_rec in l_activity_csr(
    P_ActivityId => l_resource_rec.activity_id,
    P_OpSeqId => l_resource_rec.operation_sequence_id) loop
      Fnd_Message.Set_Name('BOM', 'BOM_ACTIVITY_ID_INVALID');
      FND_MSG_PUB.Add;
      Raise FND_API.G_EXC_ERROR;
    End loop;
  End if;

  -- get units of measure and uom classes
  l_HourUomCode := Fnd_Profile.Value('BOM:HOUR_UOM_CODE');
  For l_class_rec in l_class_csr(P_Code => l_HourUomCode) loop
    l_HourUomClass := l_class_rec.uom_class;
  End loop;

  For l_uom_rec in l_uom_csr(P_ResourceId => l_resource_rec.resource_id) loop
    l_ResUomCode := l_uom_rec.unit_of_measure;
  End loop;
  For l_class_rec in l_class_csr(P_Code => l_ResUomCode) loop
    l_ResUomClass := l_class_rec.uom_class;
  End loop;

  -- Schedule must be No if:
  -- 1) resource uom <> hour uom code (if they're the same, class would be
  --    same.
  -- 2) res uom class <> hour uom class and
  -- 3) no conversion between resource uom and hour uom
  If l_resource_rec.schedule_flag <> g_no then
    If l_HourUomClass <> l_ResUomClass then
      Fnd_Message.Set_Name('BOM', 'BOM_OP_RES_SCHED_NO');
      FND_MSG_PUB.Add;
      Raise FND_API.G_EXC_ERROR;
    End if; -- not time based class
    For l_conversion_rec in l_conversion_csr loop
      Fnd_Message.Set_Name('BOM', 'BOM_OP_RES_SCHED_NO');
      FND_MSG_PUB.Add;
      Raise FND_API.G_EXC_ERROR;
    End loop;
  end if; -- schedule flag

  -- cannot have more than one Next or Prior scheduled resource
  -- for an operation

  If l_resource_rec.schedule_flag = l_Prior then
    For l_Schedule_rec in l_schedule_csr(
    P_OpSeqId => l_resource_rec.operation_sequence_id,
    P_SeqNum => l_resource_rec.resource_seq_num,
    P_SchedType => l_resource_rec.schedule_flag) loop
      Fnd_Message.Set_Name('BOM', 'BOM_OP_RES_PRIOR_ERROR');
      FND_MSG_PUB.Add;
      Raise FND_API.G_EXC_ERROR;
    End loop;
  End if; -- prior

  If l_resource_rec.schedule_flag = l_Next then
    For l_Schedule_rec in l_schedule_csr(
    P_OpSeqId => l_resource_rec.operation_sequence_id,
    P_SeqNum => l_resource_rec.resource_seq_num,
    P_SchedType => l_resource_rec.schedule_flag) loop
      Fnd_Message.Set_Name('BOM', 'BOM_OP_RES_NEXT_ERROR');
      FND_MSG_PUB.Add;
      Raise FND_API.G_EXC_ERROR;
    End loop;
  End if; -- next

  -- cannot have negative usage rate if one of the following is true:
  -- 1) autocharge_type = 3 or 4
  -- 2) res uom class = hour_uom_class

  If l_resource_rec.usage_rate_or_amount < 0 then
    If l_resource_rec.autocharge_type in (3, 4) then
      Fnd_Message.Set_Name('BOM', 'BOM_NEGATIVE_USAGE_RATE');
      FND_MSG_PUB.Add;
      Raise FND_API.G_EXC_ERROR;
    End if;
    If  l_HourUomClass = l_ResUomClass then
      Fnd_Message.Set_Name('BOM', 'BOM_NEGATIVE_USAGE_RATE');
      FND_MSG_PUB.Add;
      Raise FND_API.G_EXC_ERROR;
    End if;
  End if; -- negative usage

  -- assigned units cannot be less than or equal to .00001
  If l_resource_rec.assigned_units <= .00001 then
    Fnd_Message.Set_Name('BOM', 'BOM_ASSIGNED_UNIT_ERROR');
    FND_MSG_PUB.Add;
    Raise FND_API.G_EXC_ERROR;
  End if;

  -- check if basis type,standard rate flag, schedule flag
  -- and autocharge type are valid
  If (l_resource_rec.basis_type not in (1,2)) or
  (l_resource_rec.standard_rate_flag not in (1, 2)) or
  (l_resource_rec.schedule_flag not in (1,2,3,4)) or
  (l_resource_rec.autocharge_type not in (1,2,3,4)) then
    Fnd_Message.Set_Name('BOM', 'BOM_OP_RES_LOOKUP_ERROR');
    FND_MSG_PUB.Add;
    Raise FND_API.G_EXC_ERROR;
  End if;

  -- Only one PO move per operation
  If l_resource_rec.autocharge_type = l_POMove then
    For l_autocharge_rec in l_pomove_csr(
    P_OpSeqId => l_resource_rec.operation_sequence_id,
    P_SeqNum => l_resource_rec.resource_seq_num) loop
      Fnd_Message.Set_Name('BOM', 'BOM_AUTOCHARGE_INVALID');
      FND_MSG_PUB.Add;
      Raise FND_API.G_EXC_ERROR;
    End loop;
  End if; -- PO Move

  -- Autocharge cannot be PO Move or PO Receipt if
  -- the department has no location
  If l_resource_rec.autocharge_type in (l_POReceipt, l_POMove) then
    For l_location_rec in l_CheckLocation_csr(
    P_OpSeqId => l_resource_rec.operation_sequence_id) loop
      Fnd_Message.Set_Name('BOM','BOM_AUTOCHARGE_INVALID');
      FND_MSG_PUB.Add;
      Raise FND_API.G_EXC_ERROR;
    End loop;
  End if;

  -- Check offset percent
  If l_resource_rec.resource_offset_percent not between 0 and 100 then
    Fnd_Message.Set_Name('BOM', 'BOM_OFFSET_PERCENT_INVALID');
    FND_MSG_PUB.Add;
    Raise FND_API.G_EXC_ERROR;
  End if;

-- Bug 2514018 Check Principle Flag
  If l_resource_rec.principle_flag IS NOT NULL and
     l_resource_rec.principle_flag NOT IN (1,2)
     and  l_resource_rec.principle_flag <> FND_API.G_MISS_NUM then
    Fnd_Message.Set_Name('BOM', 'BOM_RES_PCLFLAG_INVALID');
    FND_MSG_PUB.Add;
    Raise FND_API.G_EXC_ERROR;
  END IF;
--Bug 2514018

  -- Check usage rate and usage rate inverse
--<BUG FIX 1746461 Begin>
/*
  If l_resource_rec.usage_rate_or_amount <> 0 then
 If round(l_resource_rec.usage_rate_or_amount, 6) <>
    round((1 / l_resource_rec.usage_rate_or_amount_inverse), 6) then
      Fnd_Message.Set_Name('BOM', 'BOM_USAGE_RATE_INVALID');
      FND_MSG_PUB.Add;
      Raise FND_API.G_EXC_ERROR;
    End if;
  Elsif l_resource_rec.usage_rate_or_amount = 0 then
   If l_resource_rec.usage_rate_or_amount_inverse <> 0 then
      Fnd_Message.Set_Name('BOM', 'BOM_USAGE_RATE_INVALID');
      FND_MSG_PUB.Add;
      Raise FND_API.G_EXC_ERROR;
    End if;
  End if;
*/
-- rate_invalid is 0 when usage_rate is invalid
 rate_invalid:=0;
  if (l_resource_rec.usage_rate_or_amount <> 0) and
   (l_resource_rec.usage_rate_or_amount_inverse <> 0)
  then /* Bug 7322996 */
      if (round(l_resource_rec.usage_rate_or_amount,G_round_off_val) <>
          round((1/l_resource_rec.usage_rate_or_amount_inverse),G_round_off_val))
          and
         (round((1/l_resource_rec.usage_rate_or_amount),G_round_off_val) <>
         round(l_resource_rec.usage_rate_or_amount_inverse,G_round_off_val))
      then
            rate_invalid:=0;
      else
            rate_invalid:=1;
      end if;
  elsif (l_resource_rec.usage_rate_or_amount = 0) and
        (l_resource_rec.usage_rate_or_amount_inverse = 0)
  then
        rate_invalid:=1;
  else
     rate_invalid:=0;
  end if;

  if (rate_invalid = 0)
  then
     Fnd_Message.Set_Name('BOM','BOM_USAGE_RATE_INVALID');
     FND_MSG_PUB.Add;
     Raise FND_API.G_EXC_ERROR;
  end if;
--<BUG FIX : 1746461 End>

  x_resource_rec := l_resource_rec;
  -- End of API body.

  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(
    p_count => x_msg_count,
    p_data => x_msg_data
  );
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
END ValidateResource;
PROCEDURE CreateResource(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       IN OUT NOCOPY     VARCHAR2,
  x_msg_count           IN OUT NOCOPY     NUMBER,
  x_msg_data            IN OUT NOCOPY     VARCHAR2,
  p_resource_rec        IN      RESOURCE_REC_TYPE := G_MISS_RESOURCE_REC,
  x_resource_rec        IN OUT NOCOPY     RESOURCE_REC_TYPE
) IS
l_api_name		CONSTANT VARCHAR2(30)	:= 'CreateResource';
l_api_version   	CONSTANT NUMBER 	:= 1.0;
l_resource_rec          RESOURCE_REC_TYPE;
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);
l_UserId                number;
l_LoginId               number;
l_RequestId             number;
l_ProgramId             number;
l_ApplicationId         number;
l_ProgramUpdate         date;
BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT CreateResource_Pvt;
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
  l_resource_rec := p_resource_rec;

  -- initialize record
  If l_resource_rec.operation_sequence_id = Fnd_Api.G_Miss_Num then
    l_resource_rec.operation_sequence_id := null;
  End if;

  If nvl(l_resource_rec.new_resource_seq_num, Fnd_Api.G_Miss_Num) =
  Fnd_Api.G_Miss_Num then
    l_resource_rec.new_resource_seq_num := l_resource_rec.resource_seq_num;
  End if;
  l_resource_rec.resource_seq_num := null;

  If l_resource_rec.resource_id = Fnd_Api.G_Miss_Num then
    l_resource_rec.resource_id := null;
  End if;

  If l_resource_rec.activity_id = Fnd_Api.G_Miss_Num then
    l_resource_rec.activity_id := null;
  End if;

  If nvl(l_resource_rec.standard_rate_flag, Fnd_Api.G_Miss_Num) =
  Fnd_Api.G_Miss_Num then
--bug 2117759 standard_rate_flag will be defaulted from res definition
    l_resource_rec.standard_rate_flag := null;
  End if;

  If nvl(l_resource_rec.assigned_units, Fnd_Api.G_Miss_Num) =
  Fnd_Api.G_Miss_Num then
    l_resource_rec.assigned_units := 1;
  End if;

  If (nvl(l_resource_rec.usage_rate_or_amount, Fnd_Api.G_Miss_Num) =
   Fnd_Api.G_Miss_Num and
   nvl(l_resource_rec.usage_rate_or_amount_inverse, Fnd_Api.G_Miss_Num) =
   Fnd_Api.G_Miss_Num) then
    l_resource_rec.usage_rate_or_amount := 1;
    l_resource_rec.usage_rate_or_amount_inverse := 1;
  End if;

  If nvl(l_resource_rec.basis_type, Fnd_Api.G_Miss_Num) =
  Fnd_Api.G_Miss_Num then
    l_resource_rec.basis_type := null;
  End if;

  If nvl(l_resource_rec.schedule_flag, Fnd_Api.G_Miss_Num) =
  Fnd_Api.G_Miss_Num then
    l_resource_rec.schedule_flag := 2;
  End if;

  If l_resource_rec.resource_offset_percent = Fnd_Api.G_Miss_Num then
    l_resource_rec.resource_offset_percent := null;
  End if;

  If l_resource_rec.autocharge_type = Fnd_Api.G_Miss_Num then
    l_resource_rec.autocharge_type := null;
  End if;

  If l_resource_rec.attribute_category = Fnd_Api.G_Miss_Char then
    l_resource_rec.attribute_category := null;
  End if;

  If l_resource_rec.attribute1 = Fnd_Api.G_Miss_Char then
    l_resource_rec.attribute1 := null;
  End if;

  If l_resource_rec.attribute2 = Fnd_Api.G_Miss_Char then
    l_resource_rec.attribute2 := null;
  End if;

  If l_resource_rec.attribute3 = Fnd_Api.G_Miss_Char then
    l_resource_rec.attribute3 := null;
  End if;

  If l_resource_rec.attribute4 = Fnd_Api.G_Miss_Char then
    l_resource_rec.attribute4 := null;
  End if;

  If l_resource_rec.attribute5 = Fnd_Api.G_Miss_Char then
    l_resource_rec.attribute5 := null;
  End if;

  If l_resource_rec.attribute6 = Fnd_Api.G_Miss_Char then
    l_resource_rec.attribute6 := null;
  End if;

  If l_resource_rec.attribute7 = Fnd_Api.G_Miss_Char then
    l_resource_rec.attribute7 := null;
  End if;


  If l_resource_rec.attribute8 = Fnd_Api.G_Miss_Char then
    l_resource_rec.attribute8 := null;
  End if;

  If l_resource_rec.attribute9 = Fnd_Api.G_Miss_Char then
    l_resource_rec.attribute9 := null;
  End if;

  If l_resource_rec.attribute10 = Fnd_Api.G_Miss_Char then
    l_resource_rec.attribute10 := null;
  End if;

  If l_resource_rec.attribute11 = Fnd_Api.G_Miss_Char then
    l_resource_rec.attribute11 := null;
  End if;

  If l_resource_rec.attribute12 = Fnd_Api.G_Miss_Char then
    l_resource_rec.attribute12 := null;
  End if;

  If l_resource_rec.attribute13 = Fnd_Api.G_Miss_Char then
    l_resource_rec.attribute13 := null;
  End if;

  If l_resource_rec.attribute14 = Fnd_Api.G_Miss_Char then
    l_resource_rec.attribute14 := null;
  End if;

  If l_resource_rec.attribute15 = Fnd_Api.G_Miss_Char then
    l_resource_rec.attribute15 := null;
  End if;

  If l_resource_rec.assembly_item_id = Fnd_Api.G_Miss_Num then
    l_resource_rec.assembly_item_id := null;
  End if;

  If l_resource_rec.alternate_routing_designator = Fnd_Api.G_Miss_Char then
    l_resource_rec.alternate_routing_designator := null;
  End if;

  If l_resource_rec.organization_id = Fnd_Api.G_Miss_Num then
    l_resource_rec.organization_id := null;
  End if;

  If l_resource_rec.operation_seq_num = Fnd_Api.G_Miss_Num then
    l_resource_rec.operation_seq_num := null;
  End if;

  If l_resource_rec.effectivity_date = Fnd_Api.G_Miss_Date then
    l_resource_rec.effectivity_date := null;
  End if;

  If l_resource_rec.routing_sequence_id = Fnd_Api.G_Miss_Num then
    l_resource_rec.routing_sequence_id := null;
  End if;

  If l_resource_rec.organization_code = Fnd_Api.G_Miss_Char then
    l_resource_rec.organization_code := null;
  End if;

  If l_resource_rec.assembly_item_number = Fnd_Api.G_Miss_Char then
    l_resource_rec.assembly_item_number := null;
  End if;

  If l_resource_rec.resource_code = Fnd_Api.G_Miss_Char then
    l_resource_rec.resource_code := null;
  End if;

  If l_resource_rec.activity = Fnd_Api.G_Miss_Char then
    l_resource_rec.activity := null;
  End if;

--Bug 2514018
  if nvl(l_resource_rec.principle_flag,Fnd_Api.G_Miss_Num) =
		Fnd_Api.G_Miss_Num then
     l_resource_rec.principle_flag := 2;
  End if;
--Bug 2514018

  If p_validation_level > FND_API.G_VALID_LEVEL_NONE then
    ValidateResource(
      p_api_version           =>      1,
      p_init_msg_list         =>      p_init_msg_list,
      p_commit                =>      p_commit,
      p_validation_level      =>      p_validation_level,
      x_return_status         =>      l_return_status,
      x_msg_count             =>      l_msg_count,
      x_msg_data              =>      l_msg_data,
      p_resource_rec          =>      l_resource_rec,
      x_resource_rec          =>      l_resource_rec);
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
  l_ApplicationId := Fnd_Global.PROG_APPL_ID;
  -- do not use decode because of implicit data type conversions
  If l_RequestId is null then
    l_ProgramUpdate := null;
  Else
    l_ProgramUpdate := sysdate;
  End if;

  Insert into bom_operation_resources(
    operation_sequence_id,
    resource_seq_num,
    resource_id,
    activity_id,
    standard_rate_flag,
    assigned_units,
    usage_rate_or_amount,
    usage_rate_or_amount_inverse,
    basis_type,
    schedule_flag,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login,
    resource_offset_percent,
    autocharge_type,
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
    principle_flag,
    schedule_seq_num,
    substitute_group_num,
    request_id,
    program_application_id,
    program_id,
    program_update_date)
  values(
    l_resource_rec.operation_sequence_id,
    l_resource_rec.new_resource_seq_num,
    l_resource_rec.resource_id,
    l_resource_rec.activity_id,
    l_resource_rec.standard_rate_flag,
    l_resource_rec.assigned_units,
    round(l_resource_rec.usage_rate_or_amount,G_round_off_val), /* Bug 7322996 */
    round(l_resource_rec.usage_rate_or_amount_inverse,G_round_off_val), /* Bug 7322996 */
    l_resource_rec.basis_type,
    l_resource_rec.schedule_flag,
    sysdate,
    l_UserId,
    sysdate,
    l_UserId,
    l_LoginId,
    l_resource_rec.resource_offset_percent,
    l_resource_rec.autocharge_type,
    l_resource_rec.attribute_category,
    l_resource_rec.attribute1,
    l_resource_rec.attribute2,
    l_resource_rec.attribute3,
    l_resource_rec.attribute4,
    l_resource_rec.attribute5,
    l_resource_rec.attribute6,
    l_resource_rec.attribute7,
    l_resource_rec.attribute8,
    l_resource_rec.attribute9,
    l_resource_rec.attribute10,
    l_resource_rec.attribute11,
    l_resource_rec.attribute12,
    l_resource_rec.attribute13,
    l_resource_rec.attribute14,
    l_resource_rec.attribute15,
    l_resource_rec.principle_flag,
    l_resource_rec.schedule_seq_num,
    l_resource_rec.schedule_seq_num,
    l_RequestId,
    l_ApplicationId,
    l_ProgramId,
    l_ProgramUpdate);

  x_resource_rec := l_resource_rec;
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
    ROLLBACK TO CreateResource_Pvt;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO CreateResource_Pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
  WHEN OTHERS THEN
    ROLLBACK TO CreateResource_Pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
END CreateResource;
PROCEDURE UpdateResource(
  p_api_version         IN	NUMBER,
  p_init_msg_list	IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
  p_validation_level	IN  	NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
  x_return_status	IN OUT NOCOPY VARCHAR2,
  x_msg_count		IN OUT NOCOPY NUMBER,
  x_msg_data		IN OUT NOCOPY VARCHAR2,
  p_resource_rec	IN	RESOURCE_REC_TYPE := G_MISS_RESOURCE_REC,
  x_resource_rec	IN OUT NOCOPY  RESOURCE_REC_TYPE
) IS
l_api_name		CONSTANT VARCHAR2(30)	:= 'UpdateResource';
l_api_version   	CONSTANT NUMBER 	:= 1.0;
l_resource_rec		RESOURCE_REC_TYPE;
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);
l_UserId                NUMBER;
l_LoginId               NUMBER;
l_RequestId             NUMBER;
l_ProgramId             NUMBER;
l_ProgramUpdate         DATE;
l_ApplicationId         NUMBER;
cursor			l_ExistingOpResource_csr(P_OpSeqId number,
			P_SeqNum number) is
			  Select *
			  From bom_operation_resources bor
			  Where bor.operation_sequence_id = P_OpSeqId
			  And   bor.resource_seq_num = P_SeqNum;
l_ResourceFound		BOOLEAN := false;
BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT UpdateResource_Pvt;
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
  l_resource_rec := p_resource_rec;

  If p_validation_level = FND_API.G_VALID_LEVEL_FULL then
    AssignResource(
      p_api_version           =>     1,
      p_init_msg_list         =>     p_init_msg_list,
      p_commit                =>     p_commit,
      p_validation_level      =>     p_validation_level,
      x_return_status         =>     l_return_status,
      x_msg_count             =>     l_msg_count,
      x_msg_data              =>     l_msg_data,
      p_resource_rec          =>     l_resource_rec,
      x_resource_rec          =>     l_resource_rec
    );
    If l_return_status = FND_API.G_RET_STS_ERROR then
      Raise FND_API.G_EXC_ERROR;
    Elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
      Raise FND_API.G_EXC_UNEXPECTED_ERROR;
    End if; -- assign error
  End If; -- assign


  -- populate unspecified values

  l_ResourceFound := false;
  For l_OldResource_rec in l_ExistingOpResource_csr(
  P_OpSeqId => l_resource_rec.operation_sequence_id,
  P_SeqNum => l_resource_rec.resource_seq_num) loop
    l_ResourceFound := true;

    If l_resource_rec.resource_id = Fnd_Api.G_Miss_Num then
      l_resource_rec.resource_id := l_OldResource_rec.resource_id;
    End if;

    If l_resource_rec.activity_id = Fnd_Api.G_Miss_Num then
      l_resource_rec.activity_id := l_OldResource_rec.activity_id;
    End if;

    If l_resource_rec.standard_rate_flag = Fnd_Api.G_Miss_Num then
      l_resource_rec.standard_rate_flag :=
	l_OldResource_rec.standard_rate_flag;
    End if;

    If l_resource_rec.assigned_units = Fnd_Api.G_Miss_Num then
      l_resource_rec.assigned_units := l_OldResource_rec.assigned_units;
    End if;

    If l_resource_rec.usage_rate_or_amount = Fnd_Api.G_Miss_Num then
      l_resource_rec.usage_rate_or_amount :=
	l_OldResource_rec.usage_rate_or_amount;
    End if;

    If l_resource_rec.usage_rate_or_amount_inverse = Fnd_Api.G_Miss_Num then
      l_resource_rec.usage_rate_or_amount_inverse :=
	l_OldResource_rec.usage_rate_or_amount_inverse;
    End if;

    If l_resource_rec.basis_type = Fnd_Api.G_Miss_Num then
      l_resource_rec.basis_type := l_OldResource_rec.basis_type;
    End if;

    If l_resource_rec.schedule_flag = Fnd_Api.G_Miss_Num then
      l_resource_rec.schedule_flag := l_OldResource_rec.schedule_flag;
    End if;

    If l_resource_rec.resource_offset_percent = Fnd_Api.G_Miss_Num then
      l_resource_rec.resource_offset_percent :=
 	l_OldResource_rec.resource_offset_percent;
    End if;

    If l_resource_rec.autocharge_type = Fnd_Api.G_Miss_Num then
      l_resource_rec.autocharge_type := l_OldResource_rec.autocharge_type;
    End if;

    If l_resource_rec.attribute_category = Fnd_Api.G_Miss_Char then
      l_resource_rec.attribute_category :=
	l_OldResource_rec.attribute_category;
    End if;

    If l_resource_rec.attribute1 = Fnd_Api.G_Miss_Char then
      l_resource_rec.attribute1 := l_OldResource_rec.attribute1;
    End if;

    If l_resource_rec.attribute2 = Fnd_Api.G_Miss_Char then
      l_resource_rec.attribute2 := l_OldResource_rec.attribute2;
    End if;

    If l_resource_rec.attribute3 = Fnd_Api.G_Miss_Char then
      l_resource_rec.attribute3 := l_OldResource_rec.attribute3;
    End if;

    If l_resource_rec.attribute4 = Fnd_Api.G_Miss_Char then
      l_resource_rec.attribute4 := l_OldResource_rec.attribute4;
    End if;

    If l_resource_rec.attribute5 = Fnd_Api.G_Miss_Char then
      l_resource_rec.attribute5 := l_OldResource_rec.attribute5;
    End if;

    If l_resource_rec.attribute6 = Fnd_Api.G_Miss_Char then
      l_resource_rec.attribute6 := l_OldResource_rec.attribute6;
    End if;

    If l_resource_rec.attribute7 = Fnd_Api.G_Miss_Char then
      l_resource_rec.attribute7 := l_OldResource_rec.attribute7;
    End if;

    If l_resource_rec.attribute8 = Fnd_Api.G_Miss_Char then
      l_resource_rec.attribute8 := l_OldResource_rec.attribute8;
    End if;

    If l_resource_rec.attribute9 = Fnd_Api.G_Miss_Char then
      l_resource_rec.attribute9 := l_OldResource_rec.attribute9;
    End if;

    If l_resource_rec.attribute10 = Fnd_Api.G_Miss_Char then
      l_resource_rec.attribute10 := l_OldResource_rec.attribute10;
    End if;

    If l_resource_rec.attribute11 = Fnd_Api.G_Miss_Char then
      l_resource_rec.attribute11 := l_OldResource_rec.attribute11;
    End if;

    If l_resource_rec.attribute12 = Fnd_Api.G_Miss_Char then
      l_resource_rec.attribute12 := l_OldResource_rec.attribute12;
    End if;

    If l_resource_rec.attribute13 = Fnd_Api.G_Miss_Char then
      l_resource_rec.attribute13 := l_OldResource_rec.attribute13;
    End if;

    If l_resource_rec.attribute14 = Fnd_Api.G_Miss_Char then
      l_resource_rec.attribute14 := l_OldResource_rec.attribute14;
    End if;

    If l_resource_rec.attribute15 = Fnd_Api.G_Miss_Char then
      l_resource_rec.attribute15 := l_OldResource_rec.attribute15;
    End if;

    If l_resource_rec.principle_flag =  Fnd_Api.G_Miss_Num then
      l_resource_rec.principle_flag := l_OldResource_rec.principle_flag;
    End if;

    If l_resource_rec.new_resource_seq_num = Fnd_Api.G_Miss_Num then
      l_resource_rec.new_resource_seq_num := l_resource_rec.resource_seq_num;
    End if;
  End loop; -- get old values

  If not l_ResourceFound then
    Fnd_Message.Set_Name('BOM', 'BOM_INVALID_OP_RESOURCE');
    FND_MSG_PUB.Add;
    Raise FND_API.G_EXC_ERROR;
  End if; -- missing op resource

  If p_validation_level > FND_API.G_VALID_LEVEL_NONE then
    ValidateResource(
      p_api_version           =>     1,
      p_init_msg_list         =>     p_init_msg_list,
      p_commit                =>     p_commit,
      p_validation_level      =>     FND_API.G_VALID_LEVEL_NONE,
      x_return_status         =>     l_return_status,
      x_msg_count             =>     l_msg_count,
      x_msg_data              =>     l_msg_data,
      p_resource_rec          =>     l_resource_rec,
      x_resource_rec          =>     l_resource_rec
    );
    If l_return_status = FND_API.G_RET_STS_ERROR then
      Raise FND_API.G_EXC_ERROR;
    Elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
      Raise FND_API.G_EXC_UNEXPECTED_ERROR;
    End if; -- validation error
  End If; -- validation

  -- update operation resource

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

  update bom_operation_resources set
    resource_seq_num = l_resource_rec.new_resource_seq_num,
    resource_id = l_resource_rec.resource_id,
    activity_id = l_resource_rec.activity_id,
    standard_rate_flag = l_resource_rec.standard_rate_flag,
    assigned_units = l_resource_rec.assigned_units,
    usage_rate_or_amount = round(l_resource_rec.usage_rate_or_amount,G_round_off_val), /* Bug 7322996 */
    usage_rate_or_amount_inverse = round(l_resource_rec.usage_rate_or_amount_inverse,G_round_off_val), /* Bug 7322996 */
    basis_type = l_resource_rec.basis_type,
    schedule_flag = l_resource_rec.schedule_flag,
    last_update_date = sysdate,
    last_updated_by = l_UserId,
    creation_date = nvl(creation_date,sysdate),
    created_by = l_UserId,
    last_update_login = l_LoginId,
    resource_offset_percent = l_resource_rec.resource_offset_percent,
    autocharge_type = l_resource_rec.autocharge_type,
    attribute_category = l_resource_rec.attribute_category,
    attribute1 = l_resource_rec.attribute1,
    attribute2 = l_resource_rec.attribute2,
    attribute3 = l_resource_rec.attribute3,
    attribute4 = l_resource_rec.attribute4,
    attribute5 = l_resource_rec.attribute5,
    attribute6 = l_resource_rec.attribute6,
    attribute7 = l_resource_rec.attribute7,
    attribute8 = l_resource_rec.attribute8,
    attribute9 = l_resource_rec.attribute9,
    attribute10 = l_resource_rec.attribute10,
    attribute11 = l_resource_rec.attribute11,
    attribute12 = l_resource_rec.attribute12,
    attribute13 = l_resource_rec.attribute13,
    attribute14 = l_resource_rec.attribute14,
    attribute15 = l_resource_rec.attribute15,
    principle_flag = l_resource_rec.principle_flag,
    request_id = l_RequestId,
    program_application_id = l_ApplicationId,
    program_id = l_ProgramId,
    program_update_date = l_ProgramUpdate
  where operation_sequence_id = l_resource_rec.operation_sequence_id
  and   resource_seq_num = l_resource_rec.resource_seq_num;

  x_resource_rec := l_resource_rec;
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
    ROLLBACK TO UpdateResource_Pvt;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO UpdateResource_Pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
  WHEN OTHERS THEN
    ROLLBACK TO UpdateResource_Pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
END UpdateResource;
PROCEDURE DeleteResource(
  p_api_version         IN	NUMBER,
  p_init_msg_list	IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
  p_validation_level	IN  	NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
  x_return_status	IN OUT NOCOPY VARCHAR2,
  x_msg_count		IN OUT NOCOPY NUMBER,
  x_msg_data		IN OUT NOCOPY VARCHAR2,
  p_resource_rec	IN	RESOURCE_REC_TYPE := G_MISS_RESOURCE_REC,
  x_resource_rec	IN OUT NOCOPY RESOURCE_REC_TYPE
) IS
l_api_name		CONSTANT VARCHAR2(30)	:= 'DeleteResource';
l_api_version   	CONSTANT NUMBER 	:= 1.0;
l_resource_rec		RESOURCE_REC_TYPE;
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);
BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT DeleteResource_Pvt;
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
  l_resource_rec := p_resource_rec;

  If p_validation_level = FND_API.G_VALID_LEVEL_FULL then
    AssignResource(
      p_api_version           =>     1,
      p_init_msg_list         =>     p_init_msg_list,
      p_commit                =>     p_commit,
      p_validation_level      =>     p_validation_level,
      x_return_status         =>     l_return_status,
      x_msg_count             =>     l_msg_count,
      x_msg_data              =>     l_msg_data,
      p_resource_rec          =>     l_resource_rec,
      x_resource_rec          =>     l_resource_rec
    );
    If l_return_status = FND_API.G_RET_STS_ERROR then
      Raise FND_API.G_EXC_ERROR;
    Elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
      Raise FND_API.G_EXC_UNEXPECTED_ERROR;
    End if; -- assign error
  End If; -- assign

  x_resource_rec := l_resource_rec;

  delete bom_operation_resources
  where operation_sequence_id = l_resource_rec.operation_sequence_id
  and   resource_seq_num = l_resource_rec.resource_seq_num;

  If sql%notfound then
    Fnd_Message.Set_Name('BOM', 'BOM_INVALID_OP_RESOURCE');
    FND_MSG_PUB.Add;
    Raise FND_API.G_EXC_ERROR;
  End if; -- missing op resource

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
    ROLLBACK TO DeleteResource_Pvt;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO DeleteResource_Pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
  WHEN OTHERS THEN
    ROLLBACK TO DeleteResource_Pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
END DeleteResource;
END Bom_OpResource_Pvt;

/
