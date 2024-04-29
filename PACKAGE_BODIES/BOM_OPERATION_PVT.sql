--------------------------------------------------------
--  DDL for Package Body BOM_OPERATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_OPERATION_PVT" AS
-- $Header: BOMVOPRB.pls 120.2 2005/06/21 03:47:38 appldev ship $

G_PKG_NAME 	CONSTANT VARCHAR2(30):='BOM_Operation_Pvt';
g_event	 	constant number := 1;
g_process 	constant number := 2;
g_LineOp	constant number := 3;
g_yes	 	constant number := 1;
g_no	 	constant number := 2;

PROCEDURE AssignOperation(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       IN OUT NOCOPY     VARCHAR2,
  x_msg_count           IN OUT NOCOPY     NUMBER,
  x_msg_data            IN OUT NOCOPY     VARCHAR2,
  p_operation_rec       IN      OPERATION_REC_TYPE := G_MISS_OPERATION_REC,
  x_operation_rec       IN OUT NOCOPY     OPERATION_REC_TYPE
) IS
l_api_name		CONSTANT VARCHAR2(30)	:= 'AssignOperation';
l_api_version   	CONSTANT NUMBER 	:= 1.0;
l_operation_rec		OPERATION_REC_TYPE;
l_ret_code		NUMBER;
l_err_text		varchar2(2000);
g_assy_item_type	number;
cursor 		l_operation_csr (P_OpSeqId number) is
		  Select bos.routing_sequence_id,
                         bos.operation_type,
		         bos.operation_seq_num
		  From bom_operation_sequences bos
		  Where operation_sequence_id = P_OpSeqId;
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
cursor		l_department_csr(P_code varchar2, P_OrgId number) is
    		  select department_id
        	  from bom_departments
        	  where organization_id = P_OrgId
        	  and   department_code = P_Code;
cursor		l_routing_csr(P_AssyItemId number, P_OrgId number,
		P_Alternate varchar2) is
       		  select routing_sequence_id
        	  from bom_operational_routings
        	  where organization_id = P_OrgId
        	  and   assembly_item_id = P_AssyItemId
        	  and   nvl(alternate_routing_designator, 'Primary Alternate') =
                	nvl(P_Alternate, 'Primary Alternate');

cursor		l_StdOp_csr(P_Code varchar2, P_OpType number,
	    	P_RtgSeqId number) is
    		  select bso.standard_operation_id
        	  from bom_standard_operations bso,
    		       bom_operational_routings bor
        	  where bso.organization_id = bor.organization_id
		  and   nvl(bso.line_id, -1) = nvl(bor.line_id, -1)
		  and   nvl(bso.operation_type, g_event) =
		  	nvl(P_OpType, g_event)
		  and   bso.operation_code = P_Code
		  and   bor.routing_sequence_id = P_RtgSeqId;
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
  l_operation_rec := p_operation_rec;

  If nvl(l_operation_rec.operation_sequence_id, FND_API.G_MISS_NUM) <>
  FND_API.G_MISS_NUM then
     For l_ExistingOp_rec in l_operation_csr(
     P_OpSeqId => l_operation_rec.operation_sequence_id) loop
       l_operation_rec.routing_sequence_id := l_ExistingOp_rec.routing_sequence_id;
       l_operation_rec.operation_type := l_ExistingOp_rec.operation_type;
       l_operation_rec.operation_seq_num := l_ExistingOp_rec.operation_seq_num;
     End loop;
  End if;

  If nvl(l_operation_rec.routing_sequence_id, FND_API.G_MISS_NUM) <>
  FND_API.G_MISS_NUM then
    For l_assy_rec in l_assy_csr(
    P_RtgSeqId => l_operation_rec.routing_sequence_id) loop
      l_operation_rec.assembly_item_id := l_assy_rec.assembly_item_id;
      l_operation_rec.organization_id := l_assy_rec.organization_id;
      l_operation_rec.alternate_routing_designator :=
        l_assy_rec.alternate_routing_designator;
    End loop;
  End if; -- check existing routing

  -- set organization id

  If nvl(l_operation_rec.organization_code, FND_API.G_MISS_CHAR) <>
  FND_API.G_MISS_CHAR then
    For l_parameter_rec in l_parameter_csr(
    P_Code => l_operation_rec.organization_code) loop
      l_operation_rec.organization_id := l_parameter_rec.organization_id;
    End loop;
  End if; -- organization code

  if nvl(l_operation_rec.organization_id, FND_API.G_MISS_NUM) =
  FND_API.G_MISS_NUM then
    Fnd_Message.Set_Name('BOM', 'BOM_ORG_ID_MISSING');
    FND_MSG_PUB.Add;
    raise FND_API.G_EXC_ERROR;
  end if; -- organization_id

  If nvl(l_operation_rec.Assembly_Item_Number, FND_API.G_MISS_CHAR) <>
  FND_API.G_MISS_CHAR then
    l_ret_code := INVPUOPI.mtl_pr_trans_prod_item(
                org_id => l_operation_rec.organization_id,
                item_number_in => l_operation_rec.assembly_item_number,
                item_id_out => l_operation_rec.assembly_item_id,
                err_text => l_err_text);
    if l_ret_code <> 0 then
      Fnd_Message.Set_Name('BOM', 'BOM_ASSY_ITEM_MISSING');
      FND_MSG_PUB.Add;
      raise FND_API.G_EXC_ERROR;
    end if;  -- parse failed
  end if; -- assembly item number

  -- set department id

  If nvl(l_operation_rec.department_code, Fnd_Api.G_Miss_Char) <>
  Fnd_Api.G_Miss_Char then
    l_operation_rec.department_id := null;
    For l_department_rec in l_department_csr(
    P_code => l_operation_rec.department_code,
    P_OrgId => l_operation_rec.organization_id) loop
      l_operation_rec.department_id := l_department_rec.department_id;
    End loop;
    If l_operation_rec.department_id is null then
      Fnd_Message.Set_Name('BOM', 'BOM_DEPT_CODE_INVALID');
      FND_MSG_PUB.Add;
      raise FND_API.G_EXC_ERROR;
    End if; -- invalid dept code
  End if; -- dept code

  -- Get the Assembly type from Item Id/Org ID and set option dependent flag.
  SELECT  bom_item_type
  INTO    g_assy_item_type
  FROM    MTL_SYSTEM_ITEMS
  WHERE   organization_id   = l_operation_rec.organization_id
  AND     inventory_item_id = l_operation_rec.Assembly_Item_Id ;

  If (nvl(l_operation_rec.option_dependent_flag,Fnd_Api.G_Miss_Num) <> Fnd_Api.G_Miss_Num) then
	If (g_assy_item_type not in (1,2) and l_operation_rec.option_dependent_flag = 1 ) then
      		Fnd_Message.Set_Name('BOM','BOM_OP_DPTFLAG_MUST_BE_NO');
      		FND_MSG_PUB.Add;
      		Raise FND_API.G_EXC_ERROR;
	End If;
  Else
	If g_assy_item_type in ( 1,2 ) then
    		l_operation_rec.option_dependent_flag := 1;
       	Else
		l_operation_rec.option_dependent_flag := 2;
       	End If;
  End If;

  -- null routing sequence id
  If nvl(l_operation_rec.routing_sequence_id, FND_API.G_MISS_NUM) =
  FND_API.G_MISS_NUM then
    If l_operation_rec.alternate_routing_designator = Fnd_Api.G_Miss_Char then
      l_operation_rec.alternate_routing_designator := null;
    End if;
    For l_routing_rec in l_routing_csr(
    P_AssyItemId => l_operation_rec.assembly_item_id,
    P_OrgId => l_operation_rec.organization_id,
    P_Alternate => l_operation_rec.alternate_routing_designator) loop
      l_operation_rec.routing_sequence_id :=
        l_routing_rec.routing_sequence_id;
    End loop;
    If nvl(l_operation_rec.routing_sequence_id, FND_API.G_MISS_NUM) =
    FND_API.G_MISS_NUM then
      Fnd_Message.Set_Name('BOM', 'BOM_RTG_SEQ_INVALID');
      FND_MSG_PUB.Add;
      Raise FND_API.G_EXC_ERROR;
    End if;
  End if; -- get routing sequence id

  If l_operation_rec.operation_type = Fnd_Api.G_MISS_NUM then
    l_operation_rec.operation_type := g_event;
  End if;

  If nvl(l_operation_rec.operation_code, Fnd_Api.G_Miss_Char) <>
  Fnd_Api.G_Miss_Char then
    l_operation_rec.standard_operation_id := null;
    For l_StdOp_rec in l_StdOp_csr(
    P_Code => l_operation_rec.operation_code,
    P_OpType => l_operation_rec.operation_type,
    P_RtgSeqId => l_operation_rec.routing_sequence_id) loop
      l_operation_rec.standard_operation_id :=
	l_StdOp_rec.standard_operation_id;
    End loop; -- get standard operation id
    If l_operation_rec.standard_operation_id is null then
      Fnd_Message.Set_Name('BOM', 'BOM_STD_OP_CODE_INVALID');
      FND_MSG_PUB.Add;
      Raise FND_API.G_EXC_ERROR;
    End if; -- invalid op code
  End if; -- std op code

  x_operation_rec := l_operation_rec;
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
END AssignOperation;

PROCEDURE ValidateOperation(
  p_api_version         IN	NUMBER,
  p_init_msg_list	IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
  p_validation_level	IN  	NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
  x_return_status	IN OUT NOCOPY VARCHAR2,
  x_msg_count		IN OUT NOCOPY NUMBER,
  x_msg_data		IN OUT NOCOPY VARCHAR2,
  p_operation_rec	IN	OPERATION_REC_TYPE := G_MISS_OPERATION_REC,
  x_operation_rec	IN OUT NOCOPY OPERATION_REC_TYPE
) is
l_api_name		CONSTANT VARCHAR2(30)	:= 'ValidateOperation';
l_api_version   	CONSTANT NUMBER 	:= 1.0;
l_operation_rec		OPERATION_REC_TYPE;
l_return_status		VARCHAR(1);
l_msg_count        	NUMBER;
l_msg_data		VARCHAR(2000);
cursor			l_Duplicate_csr (P_OpSeqId number, P_RtgSeqId number,
			P_OpSeqNum number, P_OpType number, P_EffDate date) is
			  Select 'x' dummy
			  From dual
			  Where exists(
			    Select null
			    From bom_operation_sequences bos
        		    where bos.routing_sequence_id = P_RtgSeqId
        		    and bos.effectivity_date = P_EffDate
        		    and bos.operation_seq_num = P_OpSeqNum
			    and nvl(bos.operation_type, g_event) =
				nvl(P_OpType, g_event)
			    and bos.operation_sequence_id <> P_OpSeqId);
cursor			l_routing_csr (P_RtgSeqId number) is
			Select 'x' dummy
			From dual
			Where not exists(
			  select null
        		  from bom_operational_routings bor
        		  where bor.routing_sequence_id = P_RtgSeqId);
cursor			l_noncfm_csr (P_RtgSeqId number) is
			Select 'x' dummy
        		From bom_operational_routings bor
        		Where bor.routing_sequence_id = P_RtgSeqId
			And nvl(bor.cfm_routing_flag, 2) = 2;
cursor			l_lbr_csr (P_RtgSeqId number) is
			Select 'x' dummy
        		From bom_operational_routings bor
        		Where bor.routing_sequence_id = P_RtgSeqId
			And nvl(bor.cfm_routing_flag,2) = 3;
cursor			l_OtherOps_csr(P_RtgSeqId number, P_OpSeqId number,
    		        P_OpSeqNum number, P_OpType number, P_EffDate date,
			P_DisDate date) is
			  select 'x' dummy
			  From dual
			  Where exists (
			    select null
        		    from bom_operation_sequences
        		    where operation_sequence_id <> P_OpSeqId
			    and   routing_sequence_id = P_RtgSeqId
        		    and   operation_seq_num = P_OpSeqNum
			    and   nvl(operation_type, g_event) =
			          nvl(P_OpType, g_event)
        		    and   (effectivity_date < nvl(P_DisDate,
				     effectivity_date + 1) and
				   nvl(disable_date, P_EffDate + 1) >= P_EffDate
				  )
			  );
cursor			l_common_csr(P_RtgSeqId number) is
			  select 'Is pointing to a common' dummy
            		  from bom_operational_routings
            		  where routing_sequence_id = P_RtgSeqId
            		  and   common_routing_sequence_id <>
                                routing_sequence_id;
l_PrevStdOp		number := null;
l_PrevStdCode		varchar2(4) := null;
l_PrevRefFlag		number := null;
cursor			l_OldOpCode_csr(P_OpSeqId number) is
			  Select bos.standard_operation_id,
				 bso.operation_code,
       			         nvl(bos.reference_flag, 2) reference_flag
			  From bom_operation_sequences bos,
 			       bom_standard_operations bso
			  Where operation_sequence_id = P_OpSeqId
			  And bos.standard_operation_id =
			      bso.standard_operation_id;
cursor			l_OpResources_csr(P_OpSeqId number) is
			  Select 'x' dummy
			  From dual
			  Where exists(
			    Select null
			    From bom_operation_resources
			    Where operation_sequence_id = P_OpSeqId);
cursor			l_attachments_csr(P_OpSeqId number) is
			  Select 'x' dummy
			  From dual
			  Where exists(
			    Select null
			    From fnd_attached_documents
			    Where pk1_value = to_char(P_OpSeqId)
			    and entity_name = 'BOM_OPERATION_SEQUENCES');
cursor			l_StdOp_csr(P_OpType number, P_RtgSeqId number,
			P_StdOpId number) is
	           	  select bso.DEPARTMENT_ID,
		 	         bso.MINIMUM_TRANSFER_QUANTITY,
                  	         bso.COUNT_POINT_TYPE,
				 bso.OPERATION_DESCRIPTION,
		  		 bso.BACKFLUSH_FLAG,
				 bso.OPTION_DEPENDENT_FLAG,
		  		 bso.ATTRIBUTE_CATEGORY,
				 bso.ATTRIBUTE1,
				 bso.ATTRIBUTE2,
				 bso.ATTRIBUTE3,
		  		 bso.ATTRIBUTE4,
				 bso.ATTRIBUTE5,
				 bso.ATTRIBUTE6,
				 bso.ATTRIBUTE7,
		  		 bso.ATTRIBUTE8,
				 bso.ATTRIBUTE9,
				 bso.ATTRIBUTE10,
				 bso.ATTRIBUTE11,
		  	 	 bso.ATTRIBUTE12,
			  	 bso.ATTRIBUTE13,
				 bso.ATTRIBUTE14,
				 bso.ATTRIBUTE15,
		  		 bso.OPERATION_YIELD_ENABLED
             		  from bom_standard_operations bso,
    		               bom_operational_routings bor
            		  where bso.standard_operation_id = P_StdOpId
		  	  and   bor.routing_sequence_id = P_RtgSeqId
        	  	  and   bso.organization_id = bor.organization_id
		  	  and   nvl(bso.line_id, -1) = nvl(bor.line_id, -1)
		  	  and   nvl(bso.operation_type, g_event) =
		  		nvl(P_OpType, g_event);
l_StdOpFound		boolean := false;
l_UserId        	number;
l_LoginId       	number;
l_RequestId     	number;
l_ProgramId     	number;
l_ApplicationId 	number;
l_ProgramUpdate 	date;
cursor			l_dept_csr(P_RtgSeqId number, P_DeptId number,
			P_EffDate date) is
			  select 'x' dummy
			  from dual
			  where not exists(
			    Select null
     			    from bom_departments bd,
			         bom_operational_routings bor
   			    where bd.organization_id = bor.organization_id
			    and   bor.routing_sequence_id = P_RtgSeqId
    			    and   bd.department_id = P_DeptId
    			    and   nvl(bd.disable_date, P_EffDate+1) > P_EffDate
                          );
cursor			l_parents_csr(P_ParentSeqId number) is
			Select 'x' dummy
			from bom_operation_resources
		 	where operation_sequence_id = P_ParentSeqId;
BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT ValidateOperation_Pvt;
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
  l_operation_rec := p_operation_rec;
  If p_validation_level = FND_API.G_VALID_LEVEL_FULL then
    AssignOperation(
      p_api_version 	  => 1,
      p_init_msg_list     => p_init_msg_list,
      p_commit            => p_commit,
      p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
      x_return_status     => l_return_status,
      x_msg_count         => l_msg_count,
      x_msg_data          => l_msg_data,
      p_operation_rec       => l_operation_rec,
      x_operation_rec       => l_operation_rec);
    If l_return_status = FND_API.G_RET_STS_ERROR then
      Raise FND_API.G_EXC_ERROR;
    Elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
      Raise FND_API.G_EXC_UNEXPECTED_ERROR;
    End if; -- error
  End if; -- assign values

  -- verify operation seq num is not null
  If l_operation_rec .operation_seq_num is null then
    Fnd_Message.Set_Name('BOM', 'BOM_OP_SEQ_NUM_MISSING');
    FND_MSG_PUB.Add;
    Raise FND_API.G_EXC_ERROR;
  End if;

  -- check effective date entered
  If  l_operation_rec.new_effectivity_date is null then
    Fnd_Message.Set_Name('BOM', 'BOM_EFF_DATE_MISSING');
    FND_MSG_PUB.Add;
    Raise FND_API.G_EXC_ERROR;
  End if;

  -- verify uniqueness of operation
  For l_duplicate_rec in l_Duplicate_csr(
  P_OpSeqId => l_operation_rec.operation_sequence_id,
  P_RtgSeqId => l_operation_rec.routing_sequence_id,
  P_OpSeqNum => l_operation_rec.new_operation_seq_num,
  P_OpType => l_operation_rec.operation_type,
  P_EffDate => l_operation_rec.new_effectivity_date) loop
    Fnd_Message.Set_Name('BOM', 'BOM_OPERATION_DUPLICATE');
    FND_MSG_PUB.Add;
    Raise FND_API.G_EXC_ERROR;
  End loop;

  -- check for existence of routing

  For l_routing_rec in l_routing_csr(
  P_RtgSeqId => l_operation_rec.routing_sequence_id) loop
    Fnd_Message.Set_Name('BOM', 'BOM_RTG_SEQ_INVALID');
    FND_MSG_PUB.Add;
    Raise FND_API.G_EXC_ERROR;
  End loop; -- routing existence

  -- make sure there is no overlapping operations

  For l_OtherOps_rec in	l_OtherOps_csr(
  P_RtgSeqId => l_operation_rec.routing_sequence_id,
  P_OpSeqId => l_operation_rec.operation_sequence_id,
  P_OpSeqNum => l_operation_rec.new_operation_seq_num,
  P_OpType => l_operation_rec.operation_type,
  P_EffDate => l_operation_rec.new_effectivity_date,
  P_DisDate => l_operation_rec.disable_date) loop
    Fnd_Message.Set_Name('BOM', 'BOM_IMPL_OP_OVERLAP');
    FND_MSG_PUB.Add;
    Raise FND_API.G_EXC_ERROR;
  End loop;

  -- verify that the routing does not have a common.  If so, it cannot have
  -- operations
  For l_common_rec in l_common_csr(
  P_RtgSeqId => l_operation_rec.routing_sequence_id) loop
    Fnd_Message.Set_Name('BOM', 'BOM_COMMON_OP');
    FND_MSG_PUB.Add;
    Raise FND_API.G_EXC_ERROR;
  End loop;

  -- Op Code is mandatory for Processes and Line Operations
  If l_operation_rec.operation_type in (g_process, g_LineOp) and
  l_operation_rec.standard_operation_id is null then
    Fnd_Message.Set_Name('BOM', 'BOM_STD_OP_REQUIRED');
    FND_MSG_PUB.Add;
    Raise FND_API.G_EXC_ERROR;
  End if; -- mandatory op code

  -- can not reference null op code
  If l_operation_rec.standard_operation_id is null then
    l_operation_rec.reference_flag := g_no;
  End if; -- null op code

  -- Copy and reference logic

  -- get previous standard operation
  For l_OldOp_rec in l_OldOpCode_csr(
  P_OpSeqId => l_operation_rec.operation_sequence_id) loop
    l_PrevStdOp	:= l_OldOp_rec.standard_operation_id;
    l_PrevRefFlag := l_OldOp_rec.reference_flag;
    l_PrevStdCode := l_OldOp_rec.operation_code;
  End loop;

  -- Cannot set copied operation to referenced
  If l_PrevRefFlag = g_no and l_operation_rec.reference_flag = g_yes then
    Fnd_Message.Set_Name('BOM', 'BOM_COPY_REF_OPERATION');
    Fnd_Message.Set_Token('OPERATION', l_PrevStdCode);
    FND_MSG_PUB.Add;
    Raise FND_API.G_EXC_ERROR;
  End if;

  -- Standard Operation has changed to not null value
  If nvl(l_PrevStdOp, -1) <> l_operation_rec.standard_operation_id then
    -- check resources
    For l_resource_rec in l_OpResources_csr(
    P_OpSeqId => l_operation_rec.operation_sequence_id) loop
      Fnd_Message.Set_Name('BOM', 'BOM_CANNOT_COPY_STD_OP');
      FND_MSG_PUB.Add;
      Raise FND_API.G_EXC_ERROR;
    End loop; -- resources exist, cannot copy
    l_StdOpFound := false;
    For l_StdOp_rec in l_StdOp_csr(
    P_OpType => l_operation_rec.operation_type,
    P_RtgSeqId => l_operation_rec.routing_sequence_id,
    P_StdOpId => l_operation_rec.standard_operation_id) loop
      l_StdOpFound := true;
      l_operation_rec.department_id :=  nvl(l_operation_rec.department_id,l_StdOp_rec.department_id);
      l_operation_rec.minimum_transfer_quantity :=nvl(l_operation_rec.minimum_transfer_quantity,l_StdOp_rec.minimum_transfer_quantity);
      l_operation_rec.count_point_type := nvl(l_operation_rec.count_point_type,l_StdOp_rec.count_point_type);
      l_operation_rec.operation_description := nvl(l_operation_rec.operation_description,l_StdOp_rec.operation_description);
      l_operation_rec.option_dependent_flag := nvl(l_operation_rec.option_dependent_flag,l_StdOp_rec.option_dependent_flag);
      l_operation_rec.attribute_category := nvl(l_operation_rec.attribute_category,l_StdOp_rec.attribute_category);
      l_operation_rec.attribute1 := nvl(l_operation_rec.attribute1,l_StdOp_rec.attribute1);
      l_operation_rec.attribute2 := nvl(l_operation_rec.attribute2,l_StdOp_rec.attribute2);
      l_operation_rec.attribute3 := nvl(l_operation_rec.attribute3,l_StdOp_rec.attribute3);
      l_operation_rec.attribute4 := nvl(l_operation_rec.attribute4,l_StdOp_rec.attribute4);
      l_operation_rec.attribute5 := nvl(l_operation_rec.attribute5,l_StdOp_rec.attribute5);
      l_operation_rec.attribute6 := nvl(l_operation_rec.attribute6,l_StdOp_rec.attribute6);
      l_operation_rec.attribute7 := nvl(l_operation_rec.attribute7,l_StdOp_rec.attribute7);
      l_operation_rec.attribute8 := nvl(l_operation_rec.attribute8,l_StdOp_rec.attribute8);
      l_operation_rec.attribute9 := nvl(l_operation_rec.attribute9,l_StdOp_rec.attribute9);
      l_operation_rec.attribute10 := nvl(l_operation_rec.attribute10,l_StdOp_rec.attribute10);
      l_operation_rec.attribute11 := nvl(l_operation_rec.attribute11,l_StdOp_rec.attribute11);
      l_operation_rec.attribute12 := nvl(l_operation_rec.attribute12,l_StdOp_rec.attribute12);
      l_operation_rec.attribute13 := nvl(l_operation_rec.attribute13,l_StdOp_rec.attribute13);
      l_operation_rec.attribute14 := nvl(l_operation_rec.attribute14,l_StdOp_rec.attribute14);
      l_operation_rec.attribute15 := nvl(l_operation_rec.attribute15,l_StdOp_rec.attribute15);
      l_operation_rec.backflush_flag := nvl(l_operation_rec.backflush_flag,l_StdOp_rec.backflush_flag);
      l_operation_rec.operation_yield_enabled := nvl(l_operation_rec.operation_yield_enabled,l_StdOp_rec.operation_yield_enabled);
    End loop; -- copy standard operation
    If not l_StdOpFound then
      Fnd_Message.Set_Name('BOM', 'BOM_STD_OP_ID_INVALID');
      FND_MSG_PUB.Add;
      Raise FND_API.G_EXC_ERROR;
    End if; -- invalid op code
    -- copy op resources
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
      request_id,
      program_application_id,
      program_id,
      program_update_date)
    Select
      l_operation_rec.operation_sequence_id,
      resource_seq_num,
      resource_id,
      activity_id,
      standard_rate_flag,
      assigned_units,
      usage_rate_or_amount,
      usage_rate_or_amount_inverse,
      basis_type,
      schedule_flag,
      sysdate,
      l_UserId,
      sysdate,
      l_UserId,
      l_LoginId,
      null,
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
      l_RequestId,
      l_ApplicationId,
      l_ProgramId,
      l_ProgramUpdate
    From bom_std_op_resources
    Where standard_operation_id = l_operation_rec.standard_operation_id;
    -- copy attachment
    FND_ATTACHED_DOCUMENTS2_PKG.copy_attachments(
      X_from_entity_name              => 'BOM_STANDARD_OPERATIONS',
      X_from_pk1_value                => to_char(
        l_operation_rec.standard_operation_id),
      X_from_pk2_value                => null,
      X_from_pk3_value                => null,
      X_from_pk4_value                => null,
      X_from_pk5_value                => null,
      X_to_entity_name                => 'BOM_OPERATION_SEQUENCES',
      X_to_pk1_value                  => to_char(
        l_operation_rec.operation_sequence_id),
      X_to_pk2_value                  => null,
      X_to_pk3_value                  => null,
      X_to_pk4_value                  => null,
      X_to_pk5_value                  => null,
      X_created_by                    => l_UserId,
      X_last_update_login             => l_LoginId,
      X_program_application_id        => l_ApplicationId,
      X_program_id                    => l_ProgramId,
      X_request_id                    => l_RequestId
    );
  End if; -- copy

  -- columns corresponding to columns in Standard Operations should not be
  -- changed when referenced.
  If l_operation_rec.reference_flag = g_yes then
    For l_StdOp_rec in l_StdOp_csr(
    P_OpType => l_operation_rec.operation_type,
    P_RtgSeqId => l_operation_rec.routing_sequence_id,
    P_StdOpId => l_operation_rec.standard_operation_id) loop
      l_StdOpFound := true;
      l_operation_rec.department_id := l_StdOp_rec.department_id;
      l_operation_rec.minimum_transfer_quantity :=
 	l_StdOp_rec.minimum_transfer_quantity;
      l_operation_rec.count_point_type := l_StdOp_rec.count_point_type;
      l_operation_rec.operation_description :=
	l_StdOp_rec.operation_description;
      l_operation_rec.option_dependent_flag :=
 	nvl(l_operation_rec.option_dependent_flag,l_StdOp_rec.option_dependent_flag);
      l_operation_rec.attribute_category := l_StdOp_rec.attribute_category;
      l_operation_rec.attribute1 := l_StdOp_rec.attribute1;
      l_operation_rec.attribute2 := l_StdOp_rec.attribute2;
      l_operation_rec.attribute3 := l_StdOp_rec.attribute3;
      l_operation_rec.attribute4 := l_StdOp_rec.attribute4;
      l_operation_rec.attribute5 := l_StdOp_rec.attribute5;
      l_operation_rec.attribute6 := l_StdOp_rec.attribute6;
      l_operation_rec.attribute7 := l_StdOp_rec.attribute7;
      l_operation_rec.attribute8 := l_StdOp_rec.attribute8;
      l_operation_rec.attribute9 := l_StdOp_rec.attribute9;
      l_operation_rec.attribute10 := l_StdOp_rec.attribute10;
      l_operation_rec.attribute11 := l_StdOp_rec.attribute11;
      l_operation_rec.attribute12 := l_StdOp_rec.attribute12;
      l_operation_rec.attribute13 := l_StdOp_rec.attribute13;
      l_operation_rec.attribute14 := l_StdOp_rec.attribute14;
      l_operation_rec.attribute15 := l_StdOp_rec.attribute15;
      l_operation_rec.backflush_flag := l_StdOp_rec.backflush_flag;
      l_operation_rec.operation_yield_enabled := l_StdOp_rec.operation_yield_enabled;
    End loop; -- copy standard operation
    If not l_StdOpFound then
      Fnd_Message.Set_Name('BOM', 'BOM_STD_OP_ID_INVALID');
      FND_MSG_PUB.Add;
      Raise FND_API.G_EXC_ERROR;
    End if; -- invalid op code
  End if; -- referenced

  -- Validate Department
  For l_dept_rec in l_dept_csr(
  P_RtgSeqId => l_operation_rec.routing_sequence_id,
  P_DeptId => l_operation_rec.department_id,
  P_EffDate => l_operation_rec.new_effectivity_date) loop
    Fnd_Message.Set_Name('BOM', 'BOM_DEPT_ID_INVALID');
    FND_MSG_PUB.Add;
    Raise FND_API.G_EXC_ERROR;
  End loop; -- invalid department

  --  validate operation details

  if (l_operation_rec.minimum_transfer_quantity < 0)
  or (l_operation_rec.new_effectivity_date > l_operation_rec.disable_date)
  or (l_operation_rec.count_point_type not in (1,2,3))
  or (l_operation_rec.backflush_flag not in (1,2))
  or (l_operation_rec.option_dependent_flag not in (1,2))
     -- BACKFLUSH_FLAG must be Yes if COUNT_POINT_TYPE is No-direct charge
  or (l_operation_rec.count_point_type = 3 and
      l_operation_rec.backflush_flag <> 1)
  or (l_operation_rec.operation_lead_time_percent not between 0 and 100)
  -- CFM attributes
  or (l_operation_rec.net_planning_percent not between 0 and 100)
  or (l_operation_rec.yield not between 0 and 1)
  or (l_operation_rec.cumulative_yield not between 0 and 1)
  or (l_operation_rec.reverse_cumulative_yield not between 0 and 1)
  or (l_operation_rec.include_in_rollup not in (1,2))
  or (l_operation_rec.operation_yield_enabled not in (1,2))
  then
    Fnd_Message.Set_Name('BOM', 'BOM_OPERATION_ERROR');
    FND_MSG_PUB.Add;
    Raise FND_API.G_EXC_ERROR;
  End if; -- etc, etc, etc

  -- CFM validation

  For l_noncfm_rec in l_noncfm_csr (
  P_RtgSeqId => l_operation_rec.routing_sequence_id) loop
    l_operation_rec.process_op_seq_id := null;
    l_operation_rec.line_op_seq_id := null;
    l_operation_rec.yield := null;
    l_operation_rec.cumulative_yield := null;
    l_operation_rec.reverse_cumulative_yield := null;
    l_operation_rec.labor_time_calc := null;
    l_operation_rec.machine_time_calc := null;
    l_operation_rec.total_time_calc := null;
    l_operation_rec.labor_time_user := null;
    l_operation_rec.machine_time_user := null;
    l_operation_rec.total_time_user := null;
    l_operation_rec.net_planning_percent := null;
    /** Bug 2097667 Default value for these 2 fields should be
	1 regardless of the routing type
    l_operation_rec.include_in_rollup := null;
    l_operation_rec.operation_yield_enabled := null;
     **/
  End loop;

  For l_lbr_rec in l_lbr_csr (
  P_RtgSeqId => l_operation_rec.routing_sequence_id) loop
    l_operation_rec.process_op_seq_id := null;
    l_operation_rec.line_op_seq_id := null;
    l_operation_rec.labor_time_calc := null;
    l_operation_rec.machine_time_calc := null;
    l_operation_rec.total_time_calc := null;
    l_operation_rec.labor_time_user := null;
    l_operation_rec.machine_time_user := null;
    l_operation_rec.total_time_user := null;
    l_operation_rec.net_planning_percent := null;
  End loop;

  If nvl(l_operation_rec.operation_type, g_event) <> g_event and
  (l_operation_rec.process_op_seq_id is not null or
   l_operation_rec.line_op_seq_id is not null) then
    Fnd_Message.Set_Name('BOM', 'BOM_PARENT_OP_NULL');
    FND_MSG_PUB.Add;
    Raise FND_API.G_EXC_ERROR;
  End if; -- only events can have parents

  For l_process_rec in l_parents_csr(
  P_ParentSeqId => l_operation_rec.process_op_seq_id) loop
    Fnd_Message.Set_Name('BOM', 'BOM_PARENT_OP_INVALID');
    FND_MSG_PUB.Add;
    Raise FND_API.G_EXC_ERROR;
  End loop; -- invalid process

  For l_LineOp_rec in l_parents_csr(
  P_ParentSeqId => l_operation_rec.line_op_seq_id) loop
    Fnd_Message.Set_Name('BOM', 'BOM_PARENT_OP_INVALID');
    FND_MSG_PUB.Add;
    Raise FND_API.G_EXC_ERROR;
  End loop; -- invalid line operation

  x_operation_rec := l_operation_rec;

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
    ROLLBACK TO ValidateOperation_Pvt;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO ValidateOperation_Pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
  WHEN OTHERS THEN
    ROLLBACK TO ValidateOperation_Pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
End ValidateOperation;

PROCEDURE CreateOperation(
  p_api_version         IN	NUMBER,
  p_init_msg_list	IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
  p_validation_level	IN  	NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
  x_return_status	IN OUT NOCOPY VARCHAR2,
  x_msg_count		IN OUT NOCOPY NUMBER,
  x_msg_data		IN OUT NOCOPY VARCHAR2,
  p_operation_rec	IN	OPERATION_REC_TYPE := G_MISS_OPERATION_REC,
  x_operation_rec	IN OUT NOCOPY OPERATION_REC_TYPE
) is
l_api_name		CONSTANT VARCHAR2(30)	:= 'CreateOperation';
l_api_version   	CONSTANT NUMBER 	:= 1.0;
l_operation_rec		OPERATION_REC_TYPE;
l_return_status 	VARCHAR2(1);
l_msg_count     	NUMBER;
l_msg_data      	VARCHAR2(2000);
l_UserId        	number;
l_LoginId       	number;
l_RequestId     	number;
l_ProgramId     	number;
l_ApplicationId 	number;
l_ProgramUpdate 	date;
cursor			l_NewOper_csr is
			Select bom_operation_sequences_s.nextval new_op_seq_id
			from dual;
BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT CreateOperation_Pvt;
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
  l_operation_rec := p_operation_rec;

  -- initialize record

  For l_NewOper_rec in l_NewOper_csr loop
    l_operation_rec.operation_sequence_id := l_NewOper_rec.new_op_seq_id;
  End loop; -- new primary key

  If l_operation_rec.routing_sequence_id = Fnd_Api.G_Miss_Num then
    l_operation_rec.routing_sequence_id := null;
  End if;

  If l_operation_rec.operation_seq_num = Fnd_Api.G_Miss_Num then
    l_operation_rec.operation_seq_num := null;
  End if;

  If nvl(l_operation_rec.new_operation_seq_num, Fnd_Api.G_Miss_Num) =
  Fnd_Api.G_Miss_Num then
    l_operation_rec.new_operation_seq_num := l_operation_rec.operation_seq_num;
  End if;

  If l_operation_rec.standard_operation_id = Fnd_Api.G_Miss_Num then
    l_operation_rec.standard_operation_id := null;
  End if;

  If l_operation_rec.department_id = Fnd_Api.G_Miss_Num then
    l_operation_rec.department_id := null;
  End if;

  If l_operation_rec.operation_lead_time_percent = Fnd_Api.G_Miss_Num then
    l_operation_rec.operation_lead_time_percent := null;
  End if;

  If l_operation_rec.minimum_transfer_quantity = Fnd_Api.G_Miss_Num then
    l_operation_rec.minimum_transfer_quantity := null;
  End if;

  If nvl(l_operation_rec.count_point_type, Fnd_Api.G_Miss_Num) =
  Fnd_Api.G_Miss_Num then
    l_operation_rec.count_point_type := 1;
  End if;

  If l_operation_rec.operation_description = Fnd_Api.G_Miss_Char then
    l_operation_rec.operation_description := null;
  End if;

  If nvl(l_operation_rec.effectivity_date, Fnd_Api.G_Miss_Date) =
  Fnd_Api.G_Miss_Date then
    l_operation_rec.effectivity_date := trunc(sysdate);
  End if;

  If nvl(l_operation_rec.new_effectivity_date, Fnd_Api.G_Miss_Date) =
  Fnd_Api.G_Miss_Date then
    l_operation_rec.new_effectivity_date := l_operation_rec.effectivity_date;
  End if;

  If l_operation_rec.disable_date = Fnd_Api.G_Miss_Date then
    l_operation_rec.disable_date := null;
  End if;

  If nvl(l_operation_rec.backflush_flag, Fnd_Api.G_Miss_Num) =
  Fnd_Api.G_Miss_Num then
    l_operation_rec.backflush_flag := g_yes;
  End if;

  If nvl(l_operation_rec.option_dependent_flag, Fnd_Api.G_Miss_Num) =
  Fnd_Api.G_Miss_Num then
    l_operation_rec.option_dependent_flag := g_no;
  End if;

  If l_operation_rec.attribute_category = Fnd_Api.G_Miss_Char then
    l_operation_rec.attribute_category := null;
  End if;

  If l_operation_rec.attribute1 = Fnd_Api.G_Miss_Char then
    l_operation_rec.attribute1 := null;
  End if;

  If l_operation_rec.attribute2 = Fnd_Api.G_Miss_Char then
    l_operation_rec.attribute2 := null;
  End if;

  If l_operation_rec.attribute3 = Fnd_Api.G_Miss_Char then
    l_operation_rec.attribute3 := null;
  End if;

  If l_operation_rec.attribute4 = Fnd_Api.G_Miss_Char then
    l_operation_rec.attribute4 := null;
  End if;

  If l_operation_rec.attribute5 = Fnd_Api.G_Miss_Char then
    l_operation_rec.attribute5 := null;
  End if;

  If l_operation_rec.attribute6 = Fnd_Api.G_Miss_Char then
    l_operation_rec.attribute6 := null;
  End if;

  If l_operation_rec.attribute7 = Fnd_Api.G_Miss_Char then
    l_operation_rec.attribute7 := null;
  End if;

  If l_operation_rec.attribute8 = Fnd_Api.G_Miss_Char then
    l_operation_rec.attribute8 := null;
  End if;

  If l_operation_rec.attribute9 = Fnd_Api.G_Miss_Char then
    l_operation_rec.attribute9 := null;
  End if;

  If l_operation_rec.attribute10 = Fnd_Api.G_Miss_Char then
    l_operation_rec.attribute10 := null;
  End if;

  If l_operation_rec.attribute11 = Fnd_Api.G_Miss_Char then
    l_operation_rec.attribute11 := null;
  End if;

  If l_operation_rec.attribute12 = Fnd_Api.G_Miss_Char then
    l_operation_rec.attribute12 := null;
  End if;

  If l_operation_rec.attribute13 = Fnd_Api.G_Miss_Char then
    l_operation_rec.attribute13 := null;
  End if;

  If l_operation_rec.attribute14 = Fnd_Api.G_Miss_Char then
    l_operation_rec.attribute14 := null;
  End if;

  If l_operation_rec.attribute15 = Fnd_Api.G_Miss_Char then
    l_operation_rec.attribute15 := null;
  End if;

  If l_operation_rec.assembly_item_id = Fnd_Api.G_Miss_Num then
    l_operation_rec.assembly_item_id := null;
  End if;

  If l_operation_rec.organization_id = Fnd_Api.G_Miss_Num then
    l_operation_rec.organization_id := null;
  End if;

  If l_operation_rec.alternate_routing_designator = Fnd_Api.G_Miss_Char then
    l_operation_rec.alternate_routing_designator := null;
  End if;

  If l_operation_rec.organization_code = Fnd_Api.G_Miss_Char then
    l_operation_rec.organization_code := null;
  End if;

  If l_operation_rec.assembly_item_number = Fnd_Api.G_Miss_Char then
    l_operation_rec.assembly_item_number := null;
  End if;

  If l_operation_rec.department_code = Fnd_Api.G_Miss_Char then
    l_operation_rec.department_code := null;
  End if;

  If l_operation_rec.operation_code = Fnd_Api.G_Miss_Char then
    l_operation_rec.operation_code := null;
  End if;

  If l_operation_rec.operation_type = Fnd_Api.G_Miss_Num then
    l_operation_rec.operation_type := null;
  End if;

  If nvl(l_operation_rec.reference_flag, Fnd_Api.G_Miss_Num) =
  Fnd_Api.G_Miss_Num then
    l_operation_rec.reference_flag := g_no;
  End if;

  If l_operation_rec.process_op_seq_id = Fnd_Api.G_Miss_Num then
    l_operation_rec.process_op_seq_id := null;
  End if;

  If l_operation_rec.line_op_seq_id = Fnd_Api.G_Miss_Num then
    l_operation_rec.line_op_seq_id := null;
  End if;

  If l_operation_rec.yield = Fnd_Api.G_Miss_Num then
    l_operation_rec.yield := null;
  End if;

  If l_operation_rec.cumulative_yield = Fnd_Api.G_Miss_Num then
    l_operation_rec.cumulative_yield := null;
  End if;

  If l_operation_rec.reverse_cumulative_yield = Fnd_Api.G_Miss_Num then
    l_operation_rec.reverse_cumulative_yield := null;
  End if;

  If l_operation_rec.labor_time_calc = Fnd_Api.G_Miss_Num then
    l_operation_rec.labor_time_calc := null;
  End if;

  If l_operation_rec.machine_time_calc = Fnd_Api.G_Miss_Num then
    l_operation_rec.machine_time_calc := null;
  End if;

  If l_operation_rec.total_time_calc = Fnd_Api.G_Miss_Num then
    l_operation_rec.total_time_calc := null;
  End if;

  If l_operation_rec.labor_time_user = Fnd_Api.G_Miss_Num then
    l_operation_rec.labor_time_user := null;
  End if;

  If l_operation_rec.machine_time_user = Fnd_Api.G_Miss_Num then
    l_operation_rec.machine_time_user := null;
  End if;

  If l_operation_rec.total_time_user = Fnd_Api.G_Miss_Num then
    l_operation_rec.total_time_user := null;
  End if;

  If l_operation_rec.net_planning_percent = Fnd_Api.G_Miss_Num then
    l_operation_rec.net_planning_percent := null;
  End if;

  If nvl(l_operation_rec.include_in_rollup, Fnd_Api.G_Miss_Num) =
  Fnd_Api.G_Miss_Num then
    l_operation_rec.include_in_rollup := g_yes;
  End if;

  If nvl(l_operation_rec.operation_yield_enabled, Fnd_Api.G_Miss_Num) =
  Fnd_Api.G_Miss_Num then
    l_operation_rec.operation_yield_enabled := g_yes;
  End if;

  If p_validation_level > FND_API.G_VALID_LEVEL_NONE then
    ValidateOperation(
      p_api_version           =>      1,
      p_init_msg_list         =>      p_init_msg_list,
      p_commit                =>      p_commit,
      p_validation_level      =>      p_validation_level,
      x_return_status         =>      l_return_status,
      x_msg_count             =>      l_msg_count,
      x_msg_data              =>      l_msg_data,
      p_operation_rec         =>      l_operation_rec,
      x_operation_rec         =>      l_operation_rec);
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

  Insert into bom_operation_sequences(
    operation_sequence_id,
    routing_sequence_id,
    operation_seq_num,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login,
    standard_operation_id,
    department_id,
    operation_lead_time_percent,
    minimum_transfer_quantity,
    count_point_type,
    operation_description,
    effectivity_date,
    disable_date,
    backflush_flag,
    option_dependent_flag,
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
    operation_type,
    reference_flag,
    process_op_seq_id,
    line_op_seq_id,
    yield,
    cumulative_yield,
    reverse_cumulative_yield,
    labor_time_calc,
    machine_time_calc,
    total_time_calc,
    labor_time_user,
    machine_time_user,
    total_time_user,
    net_planning_percent,
    include_in_rollup,
    operation_yield_enabled,
    implementation_date)
  Values(
    l_operation_rec.operation_sequence_id,
    l_operation_rec.routing_sequence_id,
    l_operation_rec.operation_seq_num,
    sysdate,
    l_UserId,
    sysdate,
    l_UserId,
    l_LoginId,
    l_operation_rec.standard_operation_id,
    l_operation_rec.department_id,
    l_operation_rec.operation_lead_time_percent,
    l_operation_rec.minimum_transfer_quantity,
    l_operation_rec.count_point_type,
    l_operation_rec.operation_description,
    l_operation_rec.effectivity_date,
    l_operation_rec.disable_date,
    l_operation_rec.backflush_flag,
    l_operation_rec.option_dependent_flag,
    l_operation_rec.attribute_category,
    l_operation_rec.attribute1,
    l_operation_rec.attribute2,
    l_operation_rec.attribute3,
    l_operation_rec.attribute4,
    l_operation_rec.attribute5,
    l_operation_rec.attribute6,
    l_operation_rec.attribute7,
    l_operation_rec.attribute8,
    l_operation_rec.attribute9,
    l_operation_rec.attribute10,
    l_operation_rec.attribute11,
    l_operation_rec.attribute12,
    l_operation_rec.attribute13,
    l_operation_rec.attribute14,
    l_operation_rec.attribute15,
    l_RequestId,
    l_ApplicationId,
    l_ProgramId,
    l_ProgramUpdate,
    l_operation_rec.operation_type,
    l_operation_rec.reference_flag,
    l_operation_rec.process_op_seq_id,
    l_operation_rec.line_op_seq_id,
    l_operation_rec.yield,
    l_operation_rec.cumulative_yield,
    l_operation_rec.reverse_cumulative_yield,
    l_operation_rec.labor_time_calc,
    l_operation_rec.machine_time_calc,
    l_operation_rec.total_time_calc,
    l_operation_rec.labor_time_user,
    l_operation_rec.machine_time_user,
    l_operation_rec.total_time_user,
    l_operation_rec.net_planning_percent,
    l_operation_rec.include_in_rollup,
    l_operation_rec.operation_yield_enabled,
    l_operation_rec.effectivity_date) ;

  x_operation_rec := l_operation_rec;
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
    ROLLBACK TO CreateOperation_Pvt;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO CreateOperation_Pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
  WHEN OTHERS THEN
    ROLLBACK TO CreateOperation_Pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
End CreateOperation;

PROCEDURE UpdateOperation(
  p_api_version         IN	NUMBER,
  p_init_msg_list	IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
  p_validation_level	IN  	NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
  x_return_status	IN OUT NOCOPY VARCHAR2,
  x_msg_count		IN OUT NOCOPY NUMBER,
  x_msg_data		IN OUT NOCOPY VARCHAR2,
  p_operation_rec	IN	OPERATION_REC_TYPE := G_MISS_OPERATION_REC,
  x_operation_rec	IN OUT NOCOPY OPERATION_REC_TYPE
) is
l_api_name		CONSTANT VARCHAR2(30)	:= 'UpdateOperation';
l_api_version   	CONSTANT NUMBER 	:= 1.0;
l_operation_rec		OPERATION_REC_TYPE;
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);
l_UserId        	NUMBER;
l_LoginId       	NUMBER;
l_RequestId     	NUMBER;
l_ProgramId     	NUMBER;
l_ProgramUpdate 	DATE;
l_ApplicationId 	NUMBER;
cursor			l_ExistingOperation_csr(P_OpSeqId number,
			P_RtgSeqId number, P_OpType number, P_SeqNum number,
			P_EffDate date) is
			Select *
			From bom_operation_sequences bos
			Where bos.operation_sequence_id = P_OpSeqId
			Or (bos.routing_sequence_id = P_RtgSeqId and
			    nvl(bos.operation_type, g_event) =
			    nvl(P_OpType, g_event) and
			    bos.operation_seq_num = P_SeqNum and
			    bos.effectivity_date = decode(P_OpType,
			      g_process, bos.effectivity_date,
			      g_LineOp, bos.effectivity_date,
			      P_EffDate));
l_OperFound		BOOLEAN := false;
BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT UpdateOperation_Pvt;
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
  l_operation_rec := p_operation_rec;

  If p_validation_level = FND_API.G_VALID_LEVEL_FULL then
    AssignOperation(
      p_api_version           =>     1,
      p_init_msg_list         =>     p_init_msg_list,
      p_commit                =>     p_commit,
      p_validation_level      =>     p_validation_level,
      x_return_status         =>     l_return_status,
      x_msg_count             =>     l_msg_count,
      x_msg_data              =>     l_msg_data,
      p_operation_rec         =>     l_operation_rec,
      x_operation_rec         =>     l_operation_rec
    );
    If l_return_status = FND_API.G_RET_STS_ERROR then
      Raise FND_API.G_EXC_ERROR;
    Elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
      Raise FND_API.G_EXC_UNEXPECTED_ERROR;
    End if; -- assign error
  End If; -- assign

  -- populate unspecified values

  l_OperFound := false;
  For l_OldOper_rec in l_ExistingOperation_csr(
  P_OpSeqId => l_operation_rec.operation_sequence_id,
  P_RtgSeqId => l_operation_rec.routing_sequence_id,
  P_OpType => l_operation_rec.operation_type,
  P_SeqNum => l_operation_rec.operation_seq_num,
  P_EffDate => l_operation_rec.effectivity_date) loop
    l_OperFound := true;

    -- non updatable
    l_operation_rec.operation_sequence_id :=
      l_OldOper_rec.operation_sequence_id;
    l_operation_rec.routing_sequence_id := l_OldOper_rec.routing_sequence_id;
    l_operation_rec.operation_type := l_OldOper_rec.operation_type;

    l_operation_rec.operation_seq_num := l_OldOper_rec.operation_seq_num;
    If l_operation_rec.new_operation_seq_num = Fnd_Api.G_Miss_Num then
      l_operation_rec.new_operation_seq_num :=
	l_OldOper_rec.operation_seq_num;
    End if;

    If l_operation_rec.standard_operation_id = Fnd_Api.G_Miss_Num then
      l_operation_rec.standard_operation_id :=
	l_OldOper_rec.standard_operation_id;
    End if;

    If l_operation_rec.department_id = Fnd_Api.G_Miss_Num then
      l_operation_rec.department_id := l_OldOper_rec.department_id;
    End if;

    If l_operation_rec.operation_lead_time_percent = Fnd_Api.G_Miss_Num then
      l_operation_rec.operation_lead_time_percent :=
	l_OldOper_rec.operation_lead_time_percent;
    End if;

    If l_operation_rec.minimum_transfer_quantity = Fnd_Api.G_Miss_Num then
      l_operation_rec.minimum_transfer_quantity :=
	l_OldOper_rec.minimum_transfer_quantity;
    End if;

    If l_operation_rec.count_point_type = Fnd_Api.G_Miss_Num then
      l_operation_rec.count_point_type := l_OldOper_rec.count_point_type;
    End if;

    If l_operation_rec.operation_description = Fnd_Api.G_Miss_Char then
      l_operation_rec.operation_description :=
	l_OldOper_rec.operation_description;
    End if;

    l_operation_rec.effectivity_date := l_OldOper_rec.effectivity_date;
    If l_operation_rec.new_effectivity_date = Fnd_Api.G_Miss_Date then
      l_operation_rec.new_effectivity_date :=
	l_OldOper_rec.effectivity_date;
    End if;

    If l_operation_rec.disable_date = Fnd_Api.G_Miss_Date then
      l_operation_rec.disable_date := l_OldOper_rec.disable_date;
    End if;

    If l_operation_rec.backflush_flag = Fnd_Api.G_Miss_Num then
      l_operation_rec.backflush_flag := l_OldOper_rec.backflush_flag;
    End if;

    If l_operation_rec.option_dependent_flag = Fnd_Api.G_Miss_Num then
      l_operation_rec.option_dependent_flag :=
	l_OldOper_rec.option_dependent_flag;
    End if;

    If l_operation_rec.attribute_category = Fnd_Api.G_Miss_Char then
      l_operation_rec.attribute_category := l_OldOper_rec.attribute_category;
    End if;

    If l_operation_rec.attribute1 = Fnd_Api.G_Miss_Char then
      l_operation_rec.attribute1 := l_OldOper_rec.attribute1;
    End if;

    If l_operation_rec.attribute2 = Fnd_Api.G_Miss_Char then
      l_operation_rec.attribute2 := l_OldOper_rec.attribute2;
    End if;

    If l_operation_rec.attribute3 = Fnd_Api.G_Miss_Char then
      l_operation_rec.attribute3 := l_OldOper_rec.attribute3;
    End if;

    If l_operation_rec.attribute4 = Fnd_Api.G_Miss_Char then
      l_operation_rec.attribute4 := l_OldOper_rec.attribute4;
    End if;

    If l_operation_rec.attribute5 = Fnd_Api.G_Miss_Char then
      l_operation_rec.attribute5 := l_OldOper_rec.attribute5;
    End if;

    If l_operation_rec.attribute6 = Fnd_Api.G_Miss_Char then
      l_operation_rec.attribute6 := l_OldOper_rec.attribute6;
    End if;

    If l_operation_rec.attribute7 = Fnd_Api.G_Miss_Char then
      l_operation_rec.attribute7 := l_OldOper_rec.attribute7;
    End if;

    If l_operation_rec.attribute8 = Fnd_Api.G_Miss_Char then
      l_operation_rec.attribute8 := l_OldOper_rec.attribute8;
    End if;

    If l_operation_rec.attribute9 = Fnd_Api.G_Miss_Char then
      l_operation_rec.attribute9 := l_OldOper_rec.attribute9;
    End if;

    If l_operation_rec.attribute10 = Fnd_Api.G_Miss_Char then
      l_operation_rec.attribute10 := l_OldOper_rec.attribute10;
    End if;

    If l_operation_rec.attribute11 = Fnd_Api.G_Miss_Char then
      l_operation_rec.attribute11 := l_OldOper_rec.attribute11;
    End if;

    If l_operation_rec.attribute12 = Fnd_Api.G_Miss_Char then
      l_operation_rec.attribute12 := l_OldOper_rec.attribute12;
    End if;

    If l_operation_rec.attribute13 = Fnd_Api.G_Miss_Char then
      l_operation_rec.attribute13 := l_OldOper_rec.attribute13;
    End if;

    If l_operation_rec.attribute14 = Fnd_Api.G_Miss_Char then
      l_operation_rec.attribute14 := l_OldOper_rec.attribute14;
    End if;

    If l_operation_rec.attribute15 = Fnd_Api.G_Miss_Char then
      l_operation_rec.attribute15 := l_OldOper_rec.attribute15;
    End if;

    If l_operation_rec.reference_flag = Fnd_Api.G_Miss_Num then
      l_operation_rec.reference_flag := l_OldOper_rec.reference_flag;
    End if;

    If l_operation_rec.process_op_seq_id = Fnd_Api.G_Miss_Num then
      l_operation_rec.process_op_seq_id := l_OldOper_rec.process_op_seq_id;
    End if;

    If l_operation_rec.line_op_seq_id = Fnd_Api.G_Miss_Num then
      l_operation_rec.line_op_seq_id := l_OldOper_rec.line_op_seq_id;
    End if;

    If l_operation_rec.yield = Fnd_Api.G_Miss_Num then
      l_operation_rec.yield := l_OldOper_rec.yield;
    End if;

    If l_operation_rec.cumulative_yield = Fnd_Api.G_Miss_Num then
      l_operation_rec.cumulative_yield := l_OldOper_rec.cumulative_yield;
    End if;

    If l_operation_rec.reverse_cumulative_yield = Fnd_Api.G_Miss_Num then
      l_operation_rec.reverse_cumulative_yield :=
	l_OldOper_rec.reverse_cumulative_yield;
    End if;

    If l_operation_rec.labor_time_calc = Fnd_Api.G_Miss_Num then
      l_operation_rec.labor_time_calc := l_OldOper_rec.labor_time_calc;
    End if;

    If l_operation_rec.machine_time_calc = Fnd_Api.G_Miss_Num then
      l_operation_rec.machine_time_calc := l_OldOper_rec.machine_time_calc;
    End if;

    If l_operation_rec.total_time_calc = Fnd_Api.G_Miss_Num then
      l_operation_rec.total_time_calc := l_OldOper_rec.total_time_calc;
    End if;

    If l_operation_rec.labor_time_user = Fnd_Api.G_Miss_Num then
      l_operation_rec.labor_time_user := l_OldOper_rec.labor_time_user;
    End if;

    If l_operation_rec.machine_time_user = Fnd_Api.G_Miss_Num then
      l_operation_rec.machine_time_user := l_OldOper_rec.machine_time_user;
    End if;

    If l_operation_rec.total_time_user = Fnd_Api.G_Miss_Num then
      l_operation_rec.total_time_user := l_OldOper_rec.total_time_user;
    End if;

    If l_operation_rec.net_planning_percent = Fnd_Api.G_Miss_Num then
      l_operation_rec.net_planning_percent :=
	l_OldOper_rec.net_planning_percent;
    End if;

    If l_operation_rec.include_in_rollup = Fnd_Api.G_Miss_Num then
      l_operation_rec.include_in_rollup := l_OldOper_rec.include_in_rollup;
    End if;

    If l_operation_rec.operation_yield_enabled = Fnd_Api.G_Miss_Num then
      l_operation_rec.operation_yield_enabled := l_OldOper_rec.operation_yield_enabled;
    End if;

  End loop; -- get old values

  If not l_OperFound then
    Fnd_Message.Set_Name('BOM', 'BOM_INVALID_OPERATION');
    FND_MSG_PUB.Add;
    Raise FND_API.G_EXC_ERROR;
  End if; -- missing operation

  If p_validation_level > FND_API.G_VALID_LEVEL_NONE then
    ValidateOperation(
      p_api_version           =>     1,
      p_init_msg_list         =>     p_init_msg_list,
      p_commit                =>     p_commit,
      p_validation_level      =>     FND_API.G_VALID_LEVEL_NONE,
      x_return_status         =>     l_return_status,
      x_msg_count             =>     l_msg_count,
      x_msg_data              =>     l_msg_data,
      p_operation_rec         =>     l_operation_rec,
      x_operation_rec         =>     l_operation_rec
    );
    If l_return_status = FND_API.G_RET_STS_ERROR then
      Raise FND_API.G_EXC_ERROR;
    Elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
      Raise FND_API.G_EXC_UNEXPECTED_ERROR;
    End if; -- validation error
  End If; -- validation

  -- update operation

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

  update bom_operation_sequences set
    operation_seq_num = l_operation_rec.new_operation_seq_num,
    last_update_date = sysdate,
    last_updated_by = l_UserId,
    creation_date = sysdate,
    created_by = l_UserId,
    last_update_login = l_LoginId,
    standard_operation_id = l_operation_rec.standard_operation_id,
    department_id = l_operation_rec.department_id,
    operation_lead_time_percent =
      l_operation_rec.operation_lead_time_percent,
    minimum_transfer_quantity = l_operation_rec.minimum_transfer_quantity,
    count_point_type = l_operation_rec.count_point_type,
    operation_description = l_operation_rec.operation_description,
    effectivity_date = l_operation_rec.new_effectivity_date,
    disable_date = l_operation_rec.disable_date,
    backflush_flag = l_operation_rec.backflush_flag,
    option_dependent_flag = l_operation_rec.option_dependent_flag,
    attribute_category = l_operation_rec.attribute_category,
    attribute1 = l_operation_rec.attribute1,
    attribute2 = l_operation_rec.attribute2,
    attribute3 = l_operation_rec.attribute3,
    attribute4 = l_operation_rec.attribute4,
    attribute5 = l_operation_rec.attribute5,
    attribute6 = l_operation_rec.attribute6,
    attribute7 = l_operation_rec.attribute7,
    attribute8 = l_operation_rec.attribute8,
    attribute9 = l_operation_rec.attribute9,
    attribute10 = l_operation_rec.attribute10,
    attribute11 = l_operation_rec.attribute11,
    attribute12 = l_operation_rec.attribute12,
    attribute13 = l_operation_rec.attribute13,
    attribute14 = l_operation_rec.attribute14,
    attribute15 = l_operation_rec.attribute15,
    request_id = l_RequestId,
    program_application_id = l_ApplicationId,
    program_id = l_ProgramId,
    program_update_date = l_ProgramUpdate,
    reference_flag = l_operation_rec.reference_flag,
    process_op_seq_id = l_operation_rec.process_op_seq_id,
    line_op_seq_id = l_operation_rec.line_op_seq_id,
    yield = l_operation_rec.yield,
    cumulative_yield = l_operation_rec.cumulative_yield,
    reverse_cumulative_yield = l_operation_rec.reverse_cumulative_yield,
    labor_time_calc = l_operation_rec.labor_time_calc,
    machine_time_calc = l_operation_rec.machine_time_calc,
    total_time_calc = l_operation_rec.total_time_calc,
    labor_time_user = l_operation_rec.labor_time_user,
    machine_time_user = l_operation_rec.machine_time_user,
    total_time_user = l_operation_rec.total_time_user,
    net_planning_percent = l_operation_rec.net_planning_percent,
    include_in_rollup = l_operation_rec.include_in_rollup,
    operation_yield_enabled = l_operation_rec.operation_yield_enabled
  Where operation_sequence_id = l_operation_rec.operation_sequence_id
  Or (routing_sequence_id = l_operation_rec.routing_sequence_id
      and nvl(operation_type, g_event) =
          nvl(l_operation_rec.operation_type, g_event)
      and operation_seq_num = l_operation_rec.operation_seq_num
      and effectivity_date = decode(l_operation_rec.operation_type,
	  g_process, effectivity_date,
	  g_LineOp, effectivity_date,
	  l_operation_rec.effectivity_date));

--bugFix 1690706 Begin
UPDATE BOM_INVENTORY_COMPONENTS bic SET
   bic.OPERATION_LEAD_TIME_PERCENT = l_operation_rec.operation_lead_time_percent
  WHERE bic.OPERATION_SEQ_NUM = l_operation_rec.new_operation_seq_num
       and bic.BILL_SEQUENCE_ID =
             (select bom.BILL_SEQUENCE_ID
              from BOM_BILL_OF_MATERIALS bom,
                   BOM_OPERATIONAL_ROUTINGS bor
             where bor.routing_sequence_id = l_operation_rec.routing_sequence_id
                and nvl(bor.alternate_routing_designator,'NONE') =
                    nvl(bom.ALTERNATE_BOM_DESIGNATOR,'NONE')
                and bom.ASSEMBLY_ITEM_ID = bor.assembly_item_id
                and bom.ORGANIZATION_ID  = bor.organization_id
             );
--bugFix 1690706 End
  x_operation_rec := l_operation_rec;
  -- End of API body.

  -- Standard check of p_commit.
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;
  -- Standard call to get message count and if count is 1, get message info.
  FND_MSG_PUB.Count_And_Get(
    p_count => x_msg_count,
    p_data => x_msg_data
  );
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO UpdateOperation_Pvt;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO UpdateOperation_Pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
  WHEN OTHERS THEN
    ROLLBACK TO UpdateOperation_Pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
End UpdateOperation;

PROCEDURE DeleteOperation(
  p_api_version         IN	NUMBER,
  p_init_msg_list	IN	VARCHAR2 := FND_API.G_FALSE,
  p_commit	    	IN  	VARCHAR2 := FND_API.G_FALSE,
  p_validation_level	IN  	NUMBER	:= FND_API.G_VALID_LEVEL_FULL,
  x_return_status	IN OUT NOCOPY VARCHAR2,
  x_msg_count		IN OUT NOCOPY  NUMBER,
  x_msg_data		IN OUT NOCOPY VARCHAR2,
  p_delete_group        IN	VARCHAR2,
  p_description         IN	VARCHAR2 := Null,
  p_operation_rec	IN	OPERATION_REC_TYPE := G_MISS_OPERATION_REC,
  x_operation_rec	IN OUT NOCOPY OPERATION_REC_TYPE
) is
l_api_name		CONSTANT VARCHAR2(30)	:= 'DeleteOperation';
l_api_version   	CONSTANT NUMBER 	:= 1.0;
l_operation_rec		OPERATION_REC_TYPE;
l_DeleteGrpSeqId        number := null;
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);
l_UserId                number;
cursor			l_ExistingOperation_csr(P_OpSeqId number,
			P_RtgSeqId number, P_OpType number, P_SeqNum number,
			P_EffDate date) is
			Select bos.operation_sequence_id,
                               bor.routing_sequence_id,
                               bor.assembly_item_id,
                               bor.organization_id,
                               bor.alternate_routing_designator,
                               bor.routing_type
                          From bom_operational_routings bor,
			       bom_operation_sequences bos
			Where bor.routing_sequence_id = bos.routing_sequence_id
			and (bos.operation_sequence_id = P_OpSeqId
			     Or
			     (bos.routing_sequence_id = P_RtgSeqId and
			      nvl(bos.operation_type, g_event) =
				nvl(P_OpType, g_event) and
			      bos.operation_seq_num = P_SeqNum and
			      bos.effectivity_date = decode(P_OpType,
                                g_process, bos.effectivity_date,
                                g_LineOp, bos.effectivity_date,
			        P_EffDate))
			    );
l_OperFound		BOOLEAN := false;
cursor                  l_group_csr(P_OrgId number) is
                          Select delete_group_sequence_id
                          From bom_delete_groups
                          Where delete_group_name = p_delete_group
			  And organization_id = P_OrgId;
l_operation             constant number := 5; -- delete type
l_ReturnCode            number;
BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT DeleteOperation_Pvt;
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
  l_operation_rec := p_operation_rec;
  If p_validation_level = FND_API.G_VALID_LEVEL_FULL then
    AssignOperation(
      p_api_version           =>     1,
      p_init_msg_list         =>     p_init_msg_list,
      p_commit                =>     p_commit,
      p_validation_level      =>     p_validation_level,
      x_return_status         =>     l_return_status,
      x_msg_count             =>     l_msg_count,
      x_msg_data              =>     l_msg_data,
      p_operation_rec         =>     l_operation_rec,
      x_operation_rec         =>     l_operation_rec
    );
    If l_return_status = FND_API.G_RET_STS_ERROR then
      Raise FND_API.G_EXC_ERROR;
    Elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
      Raise FND_API.G_EXC_UNEXPECTED_ERROR;
    End if; -- assign error
  End If; -- assign

  l_DeleteGrpSeqId := null;
  For l_DelGrp_rec in l_group_csr(
  P_OrgId => l_operation_rec.organization_id) loop
    l_DeleteGrpSeqId :=  l_DelGrp_rec.delete_group_sequence_id;
  End loop; -- get existing delete group

  l_UserId := nvl(Fnd_Global.USER_ID, -1);

  l_OperFound := false;
  For l_OldOper_rec in l_ExistingOperation_csr(
  P_OpSeqId => l_operation_rec.operation_sequence_id,
  P_RtgSeqId => l_operation_rec.routing_sequence_id,
  P_OpType => l_operation_rec.operation_type,
  P_SeqNum => l_operation_rec.operation_seq_num,
  P_EffDate => l_operation_rec.effectivity_date) loop
    l_OperFound := true; -- old operation found
    l_ReturnCode := MODAL_DELETE.DELETE_MANAGER_OI(
      new_group_seq_id        => l_DeleteGrpSeqId,
      name                    => p_delete_group,
      group_desc              => p_description,
      org_id                  => l_OldOper_rec.organization_id,
      bom_or_eng              => l_OldOper_rec.routing_type,
      del_type                => l_operation,
      ent_bill_seq_id         => null,
      ent_rtg_seq_id          => l_OldOper_rec.routing_sequence_id,
      ent_inv_item_id         => l_OldOper_rec.assembly_item_id,
      ent_alt_designator      => l_OldOper_rec.alternate_routing_designator,
      ent_comp_seq_id         => null,
      ent_op_seq_id           => l_OldOper_rec.operation_sequence_id,
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

  If not l_OperFound then
    Fnd_Message.Set_Name('BOM', 'BOM_INVALID_OPERATION');
    FND_MSG_PUB.Add;
    Raise FND_API.G_EXC_ERROR;
  End if; -- missing operation

  x_operation_rec := l_operation_rec;
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
    ROLLBACK TO DeleteOperation_Pvt;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO DeleteOperation_Pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
  WHEN OTHERS THEN
    ROLLBACK TO DeleteOperation_Pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
End DeleteOperation;

END BOM_Operation_Pvt;

/
