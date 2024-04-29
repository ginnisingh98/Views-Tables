--------------------------------------------------------
--  DDL for Package Body BOM_ROUTINGREVISION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_ROUTINGREVISION_PVT" AS
-- $Header: BOMVRRVB.pls 115.1 99/07/16 05:17:18 porting ship $

G_PKG_NAME 	CONSTANT VARCHAR2(30) := 'Bom_RoutingRevision_Pvt';

PROCEDURE AssignRtgRevision(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT     VARCHAR2,
  x_msg_count           OUT     NUMBER,
  x_msg_data            OUT     VARCHAR2,
  p_RtgRevision_rec     IN      RTG_REVISION_REC_TYPE :=
                                  G_MISS_RTG_REVISION_REC,
  x_RtgRevision_rec     OUT     RTG_REVISION_REC_TYPE
) IS
l_api_name		CONSTANT VARCHAR2(30)	:= 'AssignRtgRevision';
l_api_version   	CONSTANT NUMBER 	:= 1.0;
l_RtgRevision_rec     	RTG_REVISION_REC_TYPE;
l_ret_code		NUMBER;
l_err_text		VARCHAR2(2000);
cursor			l_parameter_csr(P_Code varchar2) is
                  	  Select organization_id
                  	  From mtl_parameters
                  	  Where organization_code = P_Code;
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
  l_RtgRevision_rec := p_RtgRevision_rec;

  -- set organization id

  If nvl(l_RtgRevision_rec.organization_code, FND_API.G_MISS_CHAR) <>
  FND_API.G_MISS_CHAR then
    For l_parameter_rec in l_parameter_csr(
    P_Code => l_RtgRevision_rec.organization_code) loop
      l_RtgRevision_rec.organization_id := l_parameter_rec.organization_id;
    End loop;
  End if; -- organization code
  If l_RtgRevision_rec.organization_id is null then
    Fnd_Message.Set_Name('BOM', 'BOM_ORG_ID_MISSING');
    FND_MSG_PUB.Add;
    raise FND_API.G_EXC_ERROR;
  End if; -- invalid org

  -- set item id
  If nvl(l_RtgRevision_rec.inventory_item_number, Fnd_Api.G_Miss_Char) <>
  Fnd_Api.G_Miss_Char then
    l_ret_code := INVPUOPI.mtl_pr_trans_prod_item(
      org_id => l_RtgRevision_rec.organization_id,
      item_number_in => l_RtgRevision_rec.inventory_item_number,
      item_id_out => l_RtgRevision_rec.inventory_item_id,
      err_text => l_err_text);
    If l_ret_code <> 0 then
      Fnd_Message.Set_Name('BOM', 'BOM_INV_ITEM_ID_MISSING');
      FND_MSG_PUB.Add;
      Raise FND_API.G_EXC_ERROR;
    End if;
  End if;

  x_RtgRevision_rec := l_RtgRevision_rec;
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
END AssignRtgRevision;
PROCEDURE ValidateRtgRevision(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT     VARCHAR2,
  x_msg_count           OUT     NUMBER,
  x_msg_data            OUT     VARCHAR2,
  p_RtgRevision_rec     IN      RTG_REVISION_REC_TYPE :=
                                  G_MISS_RTG_REVISION_REC,
  x_RtgRevision_rec     OUT     RTG_REVISION_REC_TYPE
) IS
l_api_name		CONSTANT VARCHAR2(30)	:= 'ValidateRtgRevision';
l_api_version   	CONSTANT NUMBER 	:= 1.0;
l_RtgRevision_rec     	RTG_REVISION_REC_TYPE;
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);
cursor			l_org_csr(P_OrgId number) is
			  Select 'x' dummy
			  From dual
			  Where not exists(
			    Select null
			    From mtl_parameters
           		    where organization_id = P_OrgId);
cursor			l_item_csr(P_ItemId number, P_OrgId number) is
			  Select 'x' dummy
			  From dual
			  Where not exists(
			    Select null
			    from mtl_system_items
        		    where organization_id = P_OrgId
        		    and   inventory_item_id = P_ItemId);
cursor			l_routing_csr(P_ItemId number, P_OrgId number) is
			  Select 'x' dummy
			  From dual
			  Where not exists(
			    Select null
			    from bom_operational_routings
     			    where organization_id = P_OrgId
       			    and assembly_item_id = P_ItemId);
cursor			l_OtherRevs_csr(P_ItemId number, P_OrgId number,
			P_Revision varchar2, P_EffDate date) is
			  Select 'x' dummy
			  from dual
			  Where exists(
			    Select null
			    from mtl_rtg_item_revisions
            		    where inventory_item_id = P_ItemId
            		    and   organization_id = P_OrgId
            		    and ((effectivity_date > P_EffDate and
				  process_revision < P_Revision)
                		 or
                  		 (effectivity_date < P_EffDate and
				  process_revision > P_Revision)
			        )
                	  );

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
  l_RtgRevision_rec := p_RtgRevision_rec;

  If p_validation_level = FND_API.G_VALID_LEVEL_FULL then
    AssignRtgRevision(
      p_api_version       => 1,
      p_init_msg_list     => p_init_msg_list,
      p_commit            => p_commit,
      p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
      x_return_status     => l_return_status,
      x_msg_count         => l_msg_count,
      x_msg_data          => l_msg_data,
      p_RtgRevision_rec   => l_RtgRevision_rec,
      x_RtgRevision_rec   => l_RtgRevision_rec);
    If l_return_status = FND_API.G_RET_STS_ERROR then
      Raise FND_API.G_EXC_ERROR;
    Elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
      Raise FND_API.G_EXC_UNEXPECTED_ERROR;
    End if; -- error
  End if; -- assign values

  -- Check if process revision is null
  If l_RtgRevision_rec.process_revision is null then
    Fnd_Message.Set_Name('BOM', 'BOM_NULL_RTG_REV');
    FND_MSG_PUB.Add;
    Raise FND_API.G_EXC_ERROR;
  End if;

  -- Check for valid org id
  For l_org_rec in l_org_csr(P_OrgId => l_RtgRevision_rec.organization_id) loop
    Fnd_Message.Set_Name('BOM', 'BOM_INVALID_ORG_ID');
    FND_MSG_PUB.Add;
    Raise FND_API.G_EXC_ERROR;
  End loop;

  -- Check if assembly item exists
  For l_item_rec in l_item_csr(
  P_ItemId => l_RtgRevision_rec.inventory_item_id,
  P_OrgId => l_RtgRevision_rec.organization_id) loop
    Fnd_Message.Set_Name('BOM', 'BOM_INV_ITEM_INVALID');
    FND_MSG_PUB.Add;
    Raise FND_API.G_EXC_ERROR;
  End loop;

  -- check if a valid routing exists for this revision
  For l_routing_rec in l_routing_csr(
  P_ItemId => l_RtgRevision_rec.inventory_item_id,
  P_OrgId => l_RtgRevision_rec.organization_id) loop
    Fnd_Message.Set_Name('BOM', 'BOM_RTG_DOES_NOT_EXIST');
    FND_MSG_PUB.Add;
    Raise FND_API.G_EXC_ERROR;
  End loop;

  -- check for ascending order
  For l_OtherRevs_rec in l_OtherRevs_csr(
  P_ItemId => l_RtgRevision_rec.inventory_item_id,
  P_OrgId => l_RtgRevision_rec.organization_id,
  P_Revision => l_RtgRevision_rec.process_revision,
  P_EffDate => l_RtgRevision_rec.effectivity_date) loop
    Fnd_Message.Set_Name('BOM', 'BOM_REV_INVALID');
    FND_MSG_PUB.Add;
    Raise FND_API.G_EXC_ERROR;
  End loop;

  x_RtgRevision_rec := l_RtgRevision_rec;
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

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
END ValidateRtgRevision;
PROCEDURE CreateRtgRevision(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT     VARCHAR2,
  x_msg_count           OUT     NUMBER,
  x_msg_data            OUT     VARCHAR2,
  p_RtgRevision_rec     IN      RTG_REVISION_REC_TYPE :=
                                  G_MISS_RTG_REVISION_REC,
  x_RtgRevision_rec     OUT     RTG_REVISION_REC_TYPE
) IS
l_api_name		CONSTANT VARCHAR2(30)	:= 'CreateRtgRevision';
l_api_version   	CONSTANT NUMBER 	:= 1.0;
l_RtgRevision_rec     	RTG_REVISION_REC_TYPE;
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
  SAVEPOINT CreateRtgRevision_Pvt;
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
  l_RtgRevision_rec := p_RtgRevision_rec;

  -- initialize record
  If l_RtgRevision_rec.inventory_item_id = Fnd_Api.G_Miss_Num then
    l_RtgRevision_rec.inventory_item_id := null;
  End if;

  If l_RtgRevision_rec.inventory_item_number = Fnd_Api.G_Miss_Char then
    l_RtgRevision_rec.inventory_item_number := null;
  End if;

  If l_RtgRevision_rec.organization_id = Fnd_Api.G_Miss_Num then
    l_RtgRevision_rec.organization_id := null;
  End if;

  If l_RtgRevision_rec.organization_code = Fnd_Api.G_Miss_Char then
    l_RtgRevision_rec.organization_code := null;
  End if;

  If l_RtgRevision_rec.process_revision = Fnd_Api.G_Miss_Char then
    l_RtgRevision_rec.process_revision := null;
  End if;

  If l_RtgRevision_rec.change_notice = Fnd_Api.G_Miss_Char then
    l_RtgRevision_rec.change_notice := null;
  End if;

  If l_RtgRevision_rec.ecn_initiation_date = Fnd_Api.G_Miss_Date then
    l_RtgRevision_rec.ecn_initiation_date := null;
  End if;

  If l_RtgRevision_rec.implemented_serial_number = Fnd_Api.G_Miss_Char then
    l_RtgRevision_rec.implemented_serial_number := null;
  End if;

  If nvl(l_RtgRevision_rec.effectivity_date, Fnd_Api.G_Miss_Date) =
  Fnd_Api.G_Miss_Date then
    l_RtgRevision_rec.effectivity_date := sysdate;
  End if;
  l_RtgRevision_rec.implementation_date := l_RtgRevision_rec.effectivity_date;

  If l_RtgRevision_rec.attribute_category = Fnd_Api.G_Miss_Char then
    l_RtgRevision_rec.attribute_category := null;
  End if;

  If l_RtgRevision_rec.attribute1 = Fnd_Api.G_Miss_Char then
    l_RtgRevision_rec.attribute1 := null;
  End if;

  If l_RtgRevision_rec.attribute2 = Fnd_Api.G_Miss_Char then
    l_RtgRevision_rec.attribute2 := null;
  End if;

  If l_RtgRevision_rec.attribute3 = Fnd_Api.G_Miss_Char then
    l_RtgRevision_rec.attribute3 := null;
  End if;

  If l_RtgRevision_rec.attribute4 = Fnd_Api.G_Miss_Char then
    l_RtgRevision_rec.attribute4 := null;
  End if;

  If l_RtgRevision_rec.attribute5 = Fnd_Api.G_Miss_Char then
    l_RtgRevision_rec.attribute5 := null;
  End if;

  If l_RtgRevision_rec.attribute6 = Fnd_Api.G_Miss_Char then
    l_RtgRevision_rec.attribute6 := null;
  End if;

  If l_RtgRevision_rec.attribute7 = Fnd_Api.G_Miss_Char then
    l_RtgRevision_rec.attribute7 := null;
  End if;

  If l_RtgRevision_rec.attribute8 = Fnd_Api.G_Miss_Char then
    l_RtgRevision_rec.attribute8 := null;
  End if;

  If l_RtgRevision_rec.attribute9 = Fnd_Api.G_Miss_Char then
    l_RtgRevision_rec.attribute9 := null;
  End if;

  If l_RtgRevision_rec.attribute10 = Fnd_Api.G_Miss_Char then
    l_RtgRevision_rec.attribute10 := null;
  End if;

  If l_RtgRevision_rec.attribute11 = Fnd_Api.G_Miss_Char then
    l_RtgRevision_rec.attribute11 := null;
  End if;

  If l_RtgRevision_rec.attribute12 = Fnd_Api.G_Miss_Char then
    l_RtgRevision_rec.attribute12 := null;
  End if;

  If l_RtgRevision_rec.attribute13 = Fnd_Api.G_Miss_Char then
    l_RtgRevision_rec.attribute13 := null;
  End if;

  If l_RtgRevision_rec.attribute14 = Fnd_Api.G_Miss_Char then
    l_RtgRevision_rec.attribute14 := null;
  End if;

  If l_RtgRevision_rec.attribute15 = Fnd_Api.G_Miss_Char then
    l_RtgRevision_rec.attribute15 := null;
  End if;

  If p_validation_level > FND_API.G_VALID_LEVEL_NONE then
    ValidateRtgRevision(
      p_api_version           =>      1,
      p_init_msg_list         =>      p_init_msg_list,
      p_commit                =>      p_commit,
      p_validation_level      =>      p_validation_level,
      x_return_status         =>      l_return_status,
      x_msg_count             =>      l_msg_count,
      x_msg_data              =>      l_msg_data,
      p_RtgRevision_rec       =>      l_RtgRevision_rec,
      x_RtgRevision_rec       =>      l_RtgRevision_rec);
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

  Insert into mtl_rtg_item_revisions(
    inventory_item_id,
    organization_id,
    process_revision,
    last_update_date,
    last_updated_by,
    creation_date,
    created_by,
    last_update_login,
    change_notice,
    ecn_initiation_date,
    implementation_date,
    implemented_serial_number,
    effectivity_date,
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
  values(
    l_RtgRevision_rec.inventory_item_id,
    l_RtgRevision_rec.organization_id,
    l_RtgRevision_rec.process_revision,
    sysdate,
    l_UserId,
    sysdate,
    l_UserId,
    l_LoginId,
    l_RtgRevision_rec.change_notice,
    l_RtgRevision_rec.ecn_initiation_date,
    l_RtgRevision_rec.implementation_date,
    l_RtgRevision_rec.implemented_serial_number,
    l_RtgRevision_rec.effectivity_date,
    l_RtgRevision_rec.attribute_category,
    l_RtgRevision_rec.attribute1,
    l_RtgRevision_rec.attribute2,
    l_RtgRevision_rec.attribute3,
    l_RtgRevision_rec.attribute4,
    l_RtgRevision_rec.attribute5,
    l_RtgRevision_rec.attribute6,
    l_RtgRevision_rec.attribute7,
    l_RtgRevision_rec.attribute8,
    l_RtgRevision_rec.attribute9,
    l_RtgRevision_rec.attribute10,
    l_RtgRevision_rec.attribute11,
    l_RtgRevision_rec.attribute12,
    l_RtgRevision_rec.attribute13,
    l_RtgRevision_rec.attribute14,
    l_RtgRevision_rec.attribute15,
    l_RequestId,
    l_ApplicationId,
    l_ProgramId,
    l_ProgramUpdate);

  x_RtgRevision_rec := l_RtgRevision_rec;
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
    ROLLBACK TO CreateRtgRevision_Pvt;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO CreateRtgRevision_Pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
  WHEN DUP_VAL_ON_INDEX then
    ROLLBACK TO CreateRtgRevision_Pvt;
    x_return_status := FND_API.G_RET_STS_ERROR;
    Fnd_Message.Set_Name('BOM', 'BOM_REV_INVALID');
    FND_MSG_PUB.Add;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
  WHEN OTHERS THEN
    ROLLBACK TO CreateRtgRevision_Pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
END CreateRtgRevision;
PROCEDURE UpdateRtgRevision(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT     VARCHAR2,
  x_msg_count           OUT     NUMBER,
  x_msg_data            OUT     VARCHAR2,
  p_RtgRevision_rec     IN      RTG_REVISION_REC_TYPE :=
                                  G_MISS_RTG_REVISION_REC,
  x_RtgRevision_rec     OUT     RTG_REVISION_REC_TYPE
) IS
l_api_name		CONSTANT VARCHAR2(30)	:= 'UpdateRtgRevision';
l_api_version   	CONSTANT NUMBER 	:= 1.0;
l_RtgRevision_rec       RTG_REVISION_REC_TYPE;
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);
l_UserId                NUMBER;
l_LoginId               NUMBER;
l_RequestId             NUMBER;
l_ProgramId             NUMBER;
l_ProgramUpdate         DATE;
l_ApplicationId         NUMBER;
cursor			l_ExistiongRevision_csr(P_ItemId number, P_OrgId number,
			P_Revision varchar2) is
			  Select *
			  From mtl_rtg_item_revisions
			  Where inventory_item_id = P_ItemId
			  And   organization_id = P_OrgId
			  And   process_revision = P_Revision;
l_RowsFound		boolean := false;
BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT UpdateRtgRevision_Pvt;
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
  l_RtgRevision_rec := p_RtgRevision_rec ;

  If p_validation_level = FND_API.G_VALID_LEVEL_FULL then
    AssignRtgRevision(
      p_api_version           =>     1,
      p_init_msg_list         =>     p_init_msg_list,
      p_commit                =>     p_commit,
      p_validation_level      =>     p_validation_level,
      x_return_status         =>     l_return_status,
      x_msg_count             =>     l_msg_count,
      x_msg_data              =>     l_msg_data,
      p_RtgRevision_rec       =>     l_RtgRevision_rec,
      x_RtgRevision_rec       =>     l_RtgRevision_rec
    );
    If l_return_status = FND_API.G_RET_STS_ERROR then
      Raise FND_API.G_EXC_ERROR;
    Elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
      Raise FND_API.G_EXC_UNEXPECTED_ERROR;
    End if; -- assign error
  End If; -- assign

  -- populate unspecified values
  l_RowsFound := false;
  For l_ExistingRev_rec in l_ExistiongRevision_csr(
  P_ItemId => l_RtgRevision_rec.inventory_item_id,
  P_OrgId => l_RtgRevision_rec.organization_id,
  P_Revision => l_RtgRevision_rec.process_revision) loop
    l_RowsFound := true;

    If l_RtgRevision_rec.change_notice = Fnd_Api.G_Miss_Char then
      l_RtgRevision_rec.change_notice := l_ExistingRev_rec.change_notice;
    End if;

    If l_RtgRevision_rec.ecn_initiation_date = Fnd_Api.G_Miss_Date then
      l_RtgRevision_rec.ecn_initiation_date :=
	l_ExistingRev_rec.ecn_initiation_date;
    End if;

    If l_RtgRevision_rec.implemented_serial_number = Fnd_Api.G_Miss_Char then
      l_RtgRevision_rec.implemented_serial_number :=
 	l_ExistingRev_rec.implemented_serial_number;
    End if;

    If nvl(l_RtgRevision_rec.effectivity_date, Fnd_Api.G_Miss_Date) =
    Fnd_Api.G_Miss_Date then
      l_RtgRevision_rec.effectivity_date := l_ExistingRev_rec.effectivity_date;
    End if;
    l_RtgRevision_rec.implementation_date := l_RtgRevision_rec.effectivity_date;

    If l_RtgRevision_rec.attribute_category = Fnd_Api.G_Miss_Char then
      l_RtgRevision_rec.attribute_category :=
	l_ExistingRev_rec.attribute_category;
    End if;

    If l_RtgRevision_rec.attribute1 = Fnd_Api.G_Miss_Char then
      l_RtgRevision_rec.attribute1 := l_ExistingRev_rec.attribute1;
    End if;

    If l_RtgRevision_rec.attribute2 = Fnd_Api.G_Miss_Char then
      l_RtgRevision_rec.attribute2 := l_ExistingRev_rec.attribute2;
    End if;

    If l_RtgRevision_rec.attribute3 = Fnd_Api.G_Miss_Char then
      l_RtgRevision_rec.attribute3 := l_ExistingRev_rec.attribute3;
    End if;

    If l_RtgRevision_rec.attribute4 = Fnd_Api.G_Miss_Char then
      l_RtgRevision_rec.attribute4 := l_ExistingRev_rec.attribute4;
    End if;

    If l_RtgRevision_rec.attribute5 = Fnd_Api.G_Miss_Char then
      l_RtgRevision_rec.attribute5 := l_ExistingRev_rec.attribute5;
    End if;

    If l_RtgRevision_rec.attribute6 = Fnd_Api.G_Miss_Char then
      l_RtgRevision_rec.attribute6 := l_ExistingRev_rec.attribute6;
    End if;

    If l_RtgRevision_rec.attribute7 = Fnd_Api.G_Miss_Char then
      l_RtgRevision_rec.attribute7 := l_ExistingRev_rec.attribute7;
    End if;

    If l_RtgRevision_rec.attribute8 = Fnd_Api.G_Miss_Char then
      l_RtgRevision_rec.attribute8 := l_ExistingRev_rec.attribute8;
    End if;

    If l_RtgRevision_rec.attribute9 = Fnd_Api.G_Miss_Char then
      l_RtgRevision_rec.attribute9 := l_ExistingRev_rec.attribute9;
    End if;

    If l_RtgRevision_rec.attribute10 = Fnd_Api.G_Miss_Char then
      l_RtgRevision_rec.attribute10 := l_ExistingRev_rec.attribute10;
    End if;

    If l_RtgRevision_rec.attribute11 = Fnd_Api.G_Miss_Char then
      l_RtgRevision_rec.attribute11 := l_ExistingRev_rec.attribute11;
    End if;

    If l_RtgRevision_rec.attribute12 = Fnd_Api.G_Miss_Char then
      l_RtgRevision_rec.attribute12 := l_ExistingRev_rec.attribute12;
    End if;

    If l_RtgRevision_rec.attribute13 = Fnd_Api.G_Miss_Char then
      l_RtgRevision_rec.attribute13 := l_ExistingRev_rec.attribute13;
    End if;

    If l_RtgRevision_rec.attribute14 = Fnd_Api.G_Miss_Char then
      l_RtgRevision_rec.attribute14 := l_ExistingRev_rec.attribute14;
    End if;

    If l_RtgRevision_rec.attribute15 = Fnd_Api.G_Miss_Char then
      l_RtgRevision_rec.attribute15 := l_ExistingRev_rec.attribute15;
    End if;
  End loop; -- get old values
  If not l_RowsFound then
    Fnd_Message.Set_Name('BOM', 'BOM_SQL_ERR');
    Fnd_Message.Set_Token('ENTITY', sqlerrm(100));
    FND_MSG_PUB.Add;
    Raise FND_API.G_EXC_ERROR;
  End if;

  If p_validation_level > FND_API.G_VALID_LEVEL_NONE then
    ValidateRtgRevision(
      p_api_version           =>     1,
      p_init_msg_list         =>     p_init_msg_list,
      p_commit                =>     p_commit,
      p_validation_level      =>     FND_API.G_VALID_LEVEL_NONE,
      x_return_status         =>     l_return_status,
      x_msg_count             =>     l_msg_count,
      x_msg_data              =>     l_msg_data,
      p_RtgRevision_rec       =>     l_RtgRevision_rec,
      x_RtgRevision_rec       =>     l_RtgRevision_rec
    );
    If l_return_status = FND_API.G_RET_STS_ERROR then
      Raise FND_API.G_EXC_ERROR;
    Elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
      Raise FND_API.G_EXC_UNEXPECTED_ERROR;
    End if; -- validation error
  End If; -- validation

  -- update routing revision

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

  update mtl_rtg_item_revisions set
    last_update_date = sysdate,
    last_updated_by = l_UserId,
    creation_date = sysdate,
    created_by = l_UserId,
    last_update_login = l_LoginId,
    change_notice = l_RtgRevision_rec.change_notice,
    ecn_initiation_date = l_RtgRevision_rec.ecn_initiation_date,
    implementation_date = l_RtgRevision_rec.implementation_date,
    implemented_serial_number = l_RtgRevision_rec.implemented_serial_number,
    effectivity_date = l_RtgRevision_rec.effectivity_date,
    attribute_category = l_RtgRevision_rec.attribute_category,
    attribute1 = l_RtgRevision_rec.attribute1,
    attribute2 = l_RtgRevision_rec.attribute2,
    attribute3 = l_RtgRevision_rec.attribute3,
    attribute4 = l_RtgRevision_rec.attribute4,
    attribute5 = l_RtgRevision_rec.attribute5,
    attribute6 = l_RtgRevision_rec.attribute6,
    attribute7 = l_RtgRevision_rec.attribute7,
    attribute8 = l_RtgRevision_rec.attribute8,
    attribute9 = l_RtgRevision_rec.attribute9,
    attribute10 = l_RtgRevision_rec.attribute10,
    attribute11 = l_RtgRevision_rec.attribute11,
    attribute12 = l_RtgRevision_rec.attribute12,
    attribute13 = l_RtgRevision_rec.attribute13,
    attribute14 = l_RtgRevision_rec.attribute14,
    attribute15 = l_RtgRevision_rec.attribute15,
    request_id = l_RequestId,
    program_application_id = l_ApplicationId,
    program_id = l_ProgramId,
    program_update_date = l_ProgramUpdate
  where inventory_item_id = l_RtgRevision_rec.inventory_item_id
  and   organization_id = l_RtgRevision_rec.organization_id
  and   process_revision = l_RtgRevision_rec.process_revision;


  x_RtgRevision_rec := l_RtgRevision_rec ;
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
    ROLLBACK TO UpdateRtgRevision_Pvt;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO UpdateRtgRevision_Pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
  WHEN OTHERS THEN
    ROLLBACK TO UpdateRtgRevision_Pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
END UpdateRtgRevision;
PROCEDURE DeleteRtgRevision(
  p_api_version         IN      NUMBER,
  p_init_msg_list       IN      VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN      VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN      NUMBER  := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT     VARCHAR2,
  x_msg_count           OUT     NUMBER,
  x_msg_data            OUT     VARCHAR2,
  p_RtgRevision_rec     IN      RTG_REVISION_REC_TYPE :=
                                  G_MISS_RTG_REVISION_REC,
  x_RtgRevision_rec     OUT     RTG_REVISION_REC_TYPE
) IS
l_api_name		CONSTANT VARCHAR2(30)	:= 'DeleteRtgRevision';
l_api_version   	CONSTANT NUMBER 	:= 1.0;
l_RtgRevision_rec       RTG_REVISION_REC_TYPE;
l_return_status         VARCHAR2(1);
l_msg_count             NUMBER;
l_msg_data              VARCHAR2(2000);
cursor			l_date_csr(P_ItemId number, P_OrgId number,
			P_Rev varchar2) is
			  Select 1 dummy
			  From mtl_rtg_item_revisions mrir
			  Where mrir.inventory_item_id = P_ItemId
			  And mrir.organization_id = P_OrgId
			  And mrir.process_revision = P_Rev
		          And mrir.effectivity_date < sysdate;
BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT DeleteRtgRevision_Pvt;
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
  l_RtgRevision_rec := p_RtgRevision_rec;

  If p_validation_level = FND_API.G_VALID_LEVEL_FULL then
    AssignRtgRevision(
      p_api_version           =>     1,
      p_init_msg_list         =>     p_init_msg_list,
      p_commit                =>     p_commit,
      p_validation_level      =>     p_validation_level,
      x_return_status         =>     l_return_status,
      x_msg_count             =>     l_msg_count,
      x_msg_data              =>     l_msg_data,
      p_RtgRevision_rec       =>     l_RtgRevision_rec,
      x_RtgRevision_rec       =>     l_RtgRevision_rec
    );
    If l_return_status = FND_API.G_RET_STS_ERROR then
      Raise FND_API.G_EXC_ERROR;
    Elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
      Raise FND_API.G_EXC_UNEXPECTED_ERROR;
    End if; -- assign error
  End If; -- assign

  For l_date_rec in l_date_csr(
  P_ItemId => l_RtgRevision_rec.inventory_item_id,
  P_OrgId => l_RtgRevision_rec.organization_id,
  P_Rev => l_RtgRevision_rec.process_revision) loop
    Fnd_Message.Set_Name('BOM', 'BOM_CANNOT_DELETE_REVISION');
    FND_MSG_PUB.Add;
    Raise FND_API.G_EXC_ERROR;
  End loop;

  delete from mtl_rtg_item_revisions
  where inventory_item_id = l_RtgRevision_rec.inventory_item_id
  and   organization_id = l_RtgRevision_rec.organization_id
  and   process_revision = l_RtgRevision_rec.process_revision;
  If sql%NotFound then
    Fnd_Message.Set_Name('BOM', 'BOM_SQL_ERR');
    Fnd_Message.Set_Token('ENTITY', sqlerrm(100));
    FND_MSG_PUB.Add;
    Raise FND_API.G_EXC_ERROR;
  End if;

  x_RtgRevision_rec := l_RtgRevision_rec;
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
    ROLLBACK TO DeleteRtgRevision_Pvt;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO DeleteRtgRevision_Pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
  WHEN OTHERS THEN
    ROLLBACK TO DeleteRtgRevision_Pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data
    );
END DeleteRtgRevision;
END Bom_RoutingRevision_Pvt;

/
