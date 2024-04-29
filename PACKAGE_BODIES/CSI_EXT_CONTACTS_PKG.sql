--------------------------------------------------------
--  DDL for Package Body CSI_EXT_CONTACTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_EXT_CONTACTS_PKG" AS
/*$Header: CSIEXCTB.pls 120.1 2005/06/28 15:42:13 rmamidip noship $*/
-- Defining Global Parameters.
G_PKG_NAME CONSTANT VARCHAR2(30) := 'CSI_EXT_CONTACTS_PKG';
 FUNCTION Get_Txn_Type
 RETURN NUMBER IS
 l_Txn_Type_Id NUMBER;
 CURSOR Txn_Cur IS
 SELECT Transaction_Type_Id
 FROM   CSI_Txn_Types
 WHERE  Source_Transaction_Type = 'IB_UI';
 BEGIN
 OPEN Txn_Cur;
 FETCH Txn_Cur INTO l_Txn_Type_Id;
 IF NOT Txn_Cur%FOUND THEN
 l_Txn_Type_Id := NULL;
 END IF;
 CLOSE Txn_Cur;
 RETURN l_Txn_Type_Id;
 END Get_Txn_Type;
-- Procedure to convert Contacts parameters to RecordType
PROCEDURE Convert_Contact_Param_To_Rec(
	P_customer_product_id		IN NUMBER	:= FND_API.G_MISS_NUM,
        P_CS_CONTACT_ID                 IN NUMBER	:= FND_API.G_MISS_NUM,
	P_contact_category		IN VARCHAR2	:= FND_API.G_MISS_CHAR,
	P_contact_type			IN VARCHAR2	:= FND_API.G_MISS_CHAR,
	P_contact_id			IN NUMBER	:= FND_API.G_MISS_NUM,
	P_primary_flag			IN VARCHAR2 := FND_API.G_MISS_CHAR,
	P_preferred_flag		IN VARCHAR2 := FND_API.G_MISS_CHAR,
	P_svc_provider_flag		IN VARCHAR2 := FND_API.G_MISS_CHAR,
	P_start_date_active		IN DATE	:= FND_API.G_MISS_DATE,
	P_end_date_active		IN DATE	:= FND_API.G_MISS_DATE,
	P_context			IN VARCHAR2 := FND_API.G_MISS_CHAR,
	P_attribute1			IN VARCHAR2 := FND_API.G_MISS_CHAR,
	P_attribute2			IN VARCHAR2 := FND_API.G_MISS_CHAR,
	P_attribute3			IN VARCHAR2 := FND_API.G_MISS_CHAR,
	P_attribute4			IN VARCHAR2 := FND_API.G_MISS_CHAR,
	P_attribute5			IN VARCHAR2 := FND_API.G_MISS_CHAR,
	P_attribute6			IN VARCHAR2 := FND_API.G_MISS_CHAR,
	P_attribute7			IN VARCHAR2 := FND_API.G_MISS_CHAR,
	P_attribute8			IN VARCHAR2 := FND_API.G_MISS_CHAR,
	P_attribute9			IN VARCHAR2 := FND_API.G_MISS_CHAR,
	P_attribute10			IN VARCHAR2 := FND_API.G_MISS_CHAR,
	P_attribute11			IN VARCHAR2 := FND_API.G_MISS_CHAR,
	P_attribute12			IN VARCHAR2 := FND_API.G_MISS_CHAR,
	P_attribute13			IN VARCHAR2 := FND_API.G_MISS_CHAR,
	P_attribute14			IN VARCHAR2 := FND_API.G_MISS_CHAR,
	P_attribute15			IN VARCHAR2 := FND_API.G_MISS_CHAR,
    X_party_tbl             OUT NOCOPY csi_datastructures_pub.party_tbl) IS
    CURSOR CONTACT_IP(P_INSTANCE_ID NUMBER ) IS
     select instance_party_id
     from csi_i_parties
     where instance_id=P_INSTANCE_ID
     and relationship_type_code='OWNER' ;

BEGIN
     FOR contact_ip_rec IN contact_ip(p_customer_product_id)
     LOOP
     x_party_tbl(1).contact_ip_id:=contact_ip_rec.instance_party_id;
     END LOOP;

     X_party_tbl(1).instance_id      := NVL(P_customer_product_Id,FND_API.G_MISS_NUM);
     X_party_tbl(1).party_source_table := NVL(P_Contact_Category,FND_API.G_MISS_CHAR);
     X_party_tbl(1).party_id         := NVL(P_Contact_Id,FND_API.G_MISS_NUM);
     X_party_tbl(1).relationship_type_code := NVL(P_Contact_Type,FND_API.G_MISS_CHAR);
     X_party_tbl(1).contact_flag    := 'Y';
     X_party_tbl(1).Instance_Party_Id := NVL(P_cs_Contact_Id,FND_API.G_MISS_NUM);
     X_party_tbl(1).active_start_date  :=NVL(P_Start_Date_Active,FND_API.G_MISS_DATE);
     X_Party_tbl(1).primary_flag := NVL(P_primary_flag,FND_API.G_MISS_CHAR);
     X_Party_tbl(1).preferred_flag := NVL(P_preferred_flag,FND_API.G_MISS_CHAR);
     X_Party_tbl(1).context  := NVL(P_context,FND_API.G_MISS_CHAR);
     X_Party_tbl(1).Attribute1  := NVL(P_Attribute1,FND_API.G_MISS_CHAR);
     X_Party_tbl(1).Attribute2  := NVL(P_Attribute2,FND_API.G_MISS_CHAR);
     X_Party_tbl(1).Attribute3  := NVL(P_Attribute3,FND_API.G_MISS_CHAR);
     X_Party_tbl(1).Attribute4  := NVL(P_Attribute4,FND_API.G_MISS_CHAR);
     X_Party_tbl(1).Attribute5  := NVL(P_Attribute5,FND_API.G_MISS_CHAR);
     X_Party_tbl(1).Attribute6  := NVL(P_Attribute6,FND_API.G_MISS_CHAR);
     X_Party_tbl(1).Attribute7  := NVL(P_Attribute7,FND_API.G_MISS_CHAR);
     X_Party_tbl(1).Attribute8  := NVL(P_Attribute8,FND_API.G_MISS_CHAR);
     X_Party_tbl(1).Attribute9  := NVL(P_Attribute9,FND_API.G_MISS_CHAR);
     X_Party_tbl(1).Attribute10  := NVL(P_Attribute10,FND_API.G_MISS_CHAR);
     X_Party_tbl(1).Attribute11  := NVL(P_Attribute11,FND_API.G_MISS_CHAR);
     X_Party_tbl(1).Attribute12  := NVL(P_Attribute12,FND_API.G_MISS_CHAR);
     X_Party_tbl(1).Attribute13  := NVL(P_Attribute13,FND_API.G_MISS_CHAR);
     X_Party_tbl(1).Attribute14  := NVL(P_Attribute14,FND_API.G_MISS_CHAR);
     X_Party_tbl(1).Attribute15  := NVL(P_Attribute15,FND_API.G_MISS_CHAR);
END Convert_Contact_Param_To_Rec;

PROCEDURE Insert_Row(
	p_customer_product_id		IN NUMBER,
	p_contact_category              IN VARCHAR2,
	p_contact_type			IN VARCHAR2,
	p_contact_id			IN NUMBER,
	p_primary_flag			IN VARCHAR2,
	p_preferred_flag		IN VARCHAR2,
	p_svc_provider_flag		IN VARCHAR2,
	p_start_date_active		IN DATE,
	p_end_date_active		IN DATE,
	p_context			IN VARCHAR2,
	p_attribute1			IN VARCHAR2,
	p_attribute2			IN VARCHAR2,
	p_attribute3			IN VARCHAR2,
	p_attribute4			IN VARCHAR2,
	p_attribute5			IN VARCHAR2,
	p_attribute6			IN VARCHAR2,
	p_attribute7			IN VARCHAR2,
	p_attribute8			IN VARCHAR2,
	p_attribute9			IN VARCHAR2,
	p_attribute10			IN VARCHAR2,
	p_attribute11			IN VARCHAR2,
	p_attribute12			IN VARCHAR2,
	p_attribute13			IN VARCHAR2,
	p_attribute14			IN VARCHAR2,
	p_attribute15			IN VARCHAR2,
	x_cs_contact_id		        OUT NOCOPY NUMBER,
	x_return_status		        OUT NOCOPY VARCHAR,
	x_msg_count		 OUT NOCOPY NUMBER,
	x_msg_data		 OUT NOCOPY VARCHAR,
	x_object_version_number	        OUT NOCOPY NUMBER
	)
IS
      l_Party_Tbl  CSI_DATASTRUCTURES_PUB.Party_Tbl;
      l_Party_Account_Tbl CSI_DATASTRUCTURES_PUB.Party_Account_Tbl;
      l_Txn_Rec CSI_DATASTRUCTURES_PUB.Transaction_Rec;
      l_Api_Version NUMBER DEFAULT 1;
      l_api_name	CONSTANT	VARCHAR2(30)	:= 'Insert_Row';
      l_Commit VARCHAR2(1) := FND_API.G_FALSE;
      l_Init_Msg_List VARCHAR2(1) := FND_API.G_FALSE;
      l_Validation_Level NUMBER := FND_API.G_VALID_LEVEL_FULL;
      l_Return_Status VARCHAR2(1);
      l_Msg_Index  NUMBER;

      -- added as part of fix for Bug 2733128
      l_chg_instance_rec          csi_datastructures_pub.instance_rec;
      l_chg_pricing_attribs_tbl   csi_datastructures_pub.pricing_attribs_tbl;
      l_chg_ext_attrib_val_tbl    csi_datastructures_pub.extend_attrib_values_tbl;
      l_chg_org_units_tbl         csi_datastructures_pub.organization_units_tbl;
      l_chg_inst_asset_tbl        csi_datastructures_pub.instance_asset_tbl;
      l_chg_inst_id_lst           csi_datastructures_pub.id_tbl;

BEGIN
    Convert_Contact_Param_To_Rec(
	P_customer_product_id		,
	NULL                            ,
	P_contact_category		,
	P_contact_type			,
	P_contact_id			,
	P_primary_flag			,
	P_preferred_flag		,
	P_svc_provider_flag		,
	P_start_date_active		,
	P_end_date_active		,
	P_context				,
	P_attribute1			,
	P_attribute2			,
	P_attribute3			,
	P_attribute4			,
	P_attribute5			,
	P_attribute6			,
	P_attribute7			,
	P_attribute8			,
	P_attribute9			,
	P_attribute10			,
	P_attribute11			,
	P_attribute12			,
	P_attribute13			,
	P_attribute14			,
	P_attribute15			,
    l_party_tbl            );
    l_Party_Tbl(1).object_version_number:= 1;
     l_Txn_Rec.TRANSACTION_DATE := SYSDATE;
     l_Txn_Rec.SOURCE_TRANSACTION_DATE:= SYSDATE;
     l_Txn_Rec.TRANSACTION_TYPE_ID  := Get_Txn_Type;
     l_Txn_Rec.Object_Version_Number := 1;

/*
     CSI_PARTY_RELATIONSHIPS_PUB.Create_Inst_Party_Relationship
     (P_API_Version => l_Api_Version,
      P_Commit             => l_Commit,
      P_Init_Msg_List      => l_Init_Msg_List,
      P_Validation_Level   => l_Validation_Level,
      P_Party_Tbl          => l_Party_Tbl,
      P_Party_Account_Tbl  => l_Party_Account_Tbl,
      P_Txn_Rec            => l_Txn_Rec,
      X_Return_Status      => x_Return_Status,
      X_Msg_Count          => x_Msg_Count,
      X_Msg_Data           => x_Msg_Data);
*/

   csi_item_instance_pub.update_item_instance(
      p_api_version           => 1.0,
      p_commit                => fnd_api.g_false,
      p_init_msg_list         => fnd_api.g_true,
      p_validation_level      => fnd_api.g_valid_level_full,
      p_instance_rec          => l_chg_instance_rec,
      p_ext_attrib_values_tbl => l_chg_ext_attrib_val_tbl,
      p_party_tbl             => l_Party_Tbl,
      p_account_tbl           => l_Party_Account_Tbl,
      p_pricing_attrib_tbl    => l_chg_pricing_attribs_tbl,
      p_org_assignments_tbl   => l_chg_org_units_tbl,
      p_txn_rec               => l_Txn_Rec,
      p_asset_assignment_tbl  => l_chg_inst_asset_tbl,
      x_instance_id_lst       => l_chg_inst_id_lst,
      x_return_status         => x_Return_Status,
      x_msg_count             => x_Msg_Count,
      x_msg_data              => x_Msg_Data);

IF NOT x_Return_Status = FND_API.G_Ret_Sts_Success
   THEN
 	l_msg_index := 1;
	 WHILE x_msg_count > 0
         LOOP
		x_Msg_Data:= x_Msg_Data||FND_MSG_PUB.GET(l_msg_index,
			     		                   FND_API.G_FALSE);
		l_msg_index := l_msg_index + 1;
         x_Msg_Count := x_Msg_Count - 1;
  	 END LOOP;
   RAISE fnd_api.g_Exc_Error;
  END IF;
  x_Cs_Contact_Id := l_Party_Tbl(1).Instance_Party_Id;
EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
			(p_count => x_msg_count ,
			 p_data => x_msg_data
			);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
		(p_count => x_msg_count ,
		 p_data => x_msg_data
		);
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get
			(p_count => x_msg_count ,
			 p_data => x_msg_data
			);

END Insert_Row;

PROCEDURE Delete_Row(
	x_return_status OUT NOCOPY 	VARCHAR,
	x_msg_count	 OUT NOCOPY NUMBER,
	x_msg_data	 OUT NOCOPY VARCHAR,
	p_cs_contact_id 	IN	NUMBER,
        P_Object_Version_Number IN      NUMBER)
IS
      l_Party_Tbl  CSI_DATASTRUCTURES_PUB.Party_Tbl;
      l_Party_Account_Tbl CSI_DATASTRUCTURES_PUB.Party_Account_Tbl;
      l_Txn_Rec CSI_DATASTRUCTURES_PUB.Transaction_Rec;
      l_Api_Version NUMBER DEFAULT 1;
      l_Api_Name VARCHAR2(30) := 'Delete_Row';
      l_Commit VARCHAR2(1) := FND_API.G_FALSE;
      l_Init_Msg_List VARCHAR2(1) := FND_API.G_FALSE;
      l_Validation_Level NUMBER := FND_API.G_VALID_LEVEL_FULL;
      l_Msg_Index  NUMBER;
begin
     l_Party_Tbl(1).Instance_Party_Id  := p_CS_Contact_ID;
     l_Party_Tbl(1).Object_Version_Number  := p_Object_Version_Number;
     l_Txn_Rec.TRANSACTION_DATE := SYSDATE;
     l_Txn_Rec.SOURCE_TRANSACTION_DATE:= SYSDATE;
     l_Txn_Rec.TRANSACTION_TYPE_ID  := Get_Txn_Type;

CSI_PARTY_RELATIONSHIPS_PUB.expire_inst_party_relationship
 (    p_api_version                 =>     l_Api_Version,
      p_commit                      =>     l_Commit,
      p_init_msg_list               =>     l_Init_Msg_List,
      p_validation_level            =>     l_Validation_Level,
      p_instance_party_tbl          =>     l_party_tbl,
      p_txn_rec                     =>     l_txn_rec,
      x_return_status               =>     x_Return_Status,
      x_msg_count                   =>     x_Msg_Count,
      x_msg_data                    =>     x_Msg_Data );

   IF NOT x_Return_Status = FND_API.G_Ret_Sts_Success
   THEN
 	l_msg_index := 1;
	 WHILE x_msg_count > 0
         LOOP
		x_Msg_Data := x_Msg_Data||FND_MSG_PUB.GET(l_msg_index,
			     		                   FND_API.G_FALSE);
		l_msg_index := l_msg_index + 1;
         x_Msg_Count := x_Msg_Count - 1;
  	 END LOOP;
   RAISE fnd_api.g_Exc_Error;
  END IF;

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
			(p_count => x_msg_count ,
			 p_data => x_msg_data
			);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
		(p_count => x_msg_count ,
		 p_data => x_msg_data
		);
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get
			(p_count => x_msg_count ,
			 p_data => x_msg_data
			);
 END DELETE_ROW;
PROCEDURE Lock_Row(
	p_cs_contact_id		IN NUMBER,
	p_customer_product_id	IN NUMBER,
	p_customer_id	         IN NUMBER,
	p_contact_category       IN VARCHAR2,
	p_contact_type			IN VARCHAR2,
	p_contact_id			IN NUMBER,
	p_primary_flag			IN VARCHAR2,
	p_preferred_flag		IN VARCHAR2,
	p_svc_provider_flag		IN VARCHAR2,
	p_start_date_active		IN DATE,
	p_end_date_active		IN DATE,
	p_context			IN VARCHAR2,
	p_attribute1			IN VARCHAR2,
	p_attribute2			IN VARCHAR2,
	p_attribute3			IN VARCHAR2,
	p_attribute4			IN VARCHAR2,
	p_attribute5			IN VARCHAR2,
	p_attribute6			IN VARCHAR2,
	p_attribute7			IN VARCHAR2,
	p_attribute8			IN VARCHAR2,
	p_attribute9			IN VARCHAR2,
	p_attribute10			IN VARCHAR2,
	p_attribute11			IN VARCHAR2,
	p_attribute12			IN VARCHAR2,
	p_attribute13			IN VARCHAR2,
	p_attribute14			IN VARCHAR2,
	p_attribute15			IN VARCHAR2,
	p_object_version_number	IN NUMBER
	)
IS
	CURSOR C IS
		SELECT *
		FROM csi_i_parties
		WHERE instance_party_id  = p_cs_contact_id
		FOR UPDATE of instance_party_id NOWAIT;

	FetchC	C%ROWTYPE;
BEGIN
	open C;
	FETCH C into FetchC;
	If (C%NOTFOUND) then
		CLOSE C;
		FND_MESSAGE.SET_NAME('CSI','FORM_RECORD_DELETED');
	End If;
	close C;

	If (
			(FetchC.Instance_party_id = p_cs_contact_id	)
		AND	(
				(FetchC.Instance_id = p_customer_product_id)
			OR	((FetchC.Instance_id is NULL) AND
				(p_customer_product_id is NULL)))
		AND	(
				(FetchC.Relationship_type_code = p_contact_type)
			OR	((FetchC.Relationship_type_code is NULL) AND
				(p_contact_type is NULL)))
		AND	(
				(FetchC.Party_id = p_contact_id)
			OR	((FetchC.Party_id is NULL) AND
				(p_contact_id is NULL)))
		AND	(
				(FetchC.primary_flag = p_primary_flag)
			OR	((FetchC.primary_flag is NULL) AND
				(p_primary_flag is NULL)))
		AND	(
				(FetchC.preferred_flag = p_preferred_flag)
			OR	((FetchC.preferred_flag is NULL) AND
				(p_preferred_flag is NULL)))
		AND	(
				(FetchC.Party_Source_Table = p_Contact_category)
			OR	((FetchC.Party_Source_Table is NULL) AND
				(p_Contact_category is NULL)))
		AND	(
				(FetchC.Active_start_date = p_start_date_active)
			OR	((FetchC.Active_start_date is NULL) AND
				(p_start_date_active is NULL)))
		AND	(
				(FetchC.Active_end_date = p_end_date_active)
			OR	((FetchC.Active_end_date is NULL) AND
				(p_end_date_active is NULL)))
		AND	(
				(FetchC.attribute1 = p_attribute1)
			OR	((FetchC.attribute1 is NULL) AND
				(p_attribute1 is NULL)))
		AND	(
				(FetchC.attribute2 = p_attribute2)
			OR	((FetchC.attribute2 is NULL) AND
				(p_attribute2 is NULL)))
		AND	(
				(FetchC.attribute3 = p_attribute3)
			OR	((FetchC.attribute3 is NULL) AND
				(p_attribute3 is NULL)))
		AND	(
				(FetchC.attribute4 = p_attribute4)
			OR	((FetchC.attribute4 is NULL) AND
				(p_attribute4 is NULL)))
		AND	(
				(FetchC.attribute5 = p_attribute5)
			OR	((FetchC.attribute5 is NULL) AND
				(p_attribute5 is NULL)))
		AND	(
				(FetchC.attribute6 = p_attribute6)
			OR	((FetchC.attribute6 is NULL) AND
				(p_attribute6 is NULL)))
		AND	(
				(FetchC.attribute7 = p_attribute7)
			OR	((FetchC.attribute7 is NULL) AND
				(p_attribute7 is NULL)))
		AND	(
				(FetchC.attribute8 = p_attribute8)
			OR	((FetchC.attribute8 is NULL) AND
				(p_attribute8 is NULL)))
		AND	(
				(FetchC.attribute9 = p_attribute9)
			OR	((FetchC.attribute9 is NULL) AND
				(p_attribute9 is NULL)))
		AND	(
				(FetchC.attribute10 = p_attribute10)
			OR	((FetchC.attribute10 is NULL) AND
				(p_attribute10 is NULL)))
		AND	(
				(FetchC.attribute11 = p_attribute11)
			OR	((FetchC.attribute11 is NULL) AND
				(p_attribute11 is NULL)))
		AND	(
				(FetchC.attribute12 = p_attribute12)
			OR	((FetchC.attribute12 is NULL) AND
				(p_attribute12 is NULL)))
		AND	(
				(FetchC.attribute13 = p_attribute13)
			OR	((FetchC.attribute13 is NULL) AND
				(p_attribute13 is NULL)))
		AND	(
				(FetchC.attribute14 = p_attribute14)
			OR	((FetchC.attribute14 is NULL) AND
				(p_attribute14 is NULL)))
		AND	(
				(FetchC.attribute15 = p_attribute15)
			OR	((FetchC.attribute15 is NULL) AND
				(p_attribute15 is NULL)))
		AND	(
				(FetchC.context = p_context)
			OR	((FetchC.context is NULL) AND
				(p_context is NULL)))
		AND	(
				(FetchC.object_version_number = p_object_version_number)
			OR	((FetchC.object_version_number is NULL) AND
				(p_object_version_number is NULL)))
	  ) then
             RETURN;
	else
		FND_MESSAGE.SET_NAME('FND','Form_Record_Changed');
	end if;
END Lock_Row;

PROCEDURE Update_Row(
	p_cs_contact_id		IN NUMBER,
	p_customer_product_id		IN NUMBER,
	p_contact_category  	IN VARCHAR2,
	p_contact_type			IN VARCHAR2,
	p_contact_id			IN NUMBER,
	p_primary_flag			IN VARCHAR2,
	p_preferred_flag		IN VARCHAR2,
	p_svc_provider_flag		IN VARCHAR2,
	p_start_date_active		IN DATE,
	p_end_date_active		IN DATE,
	p_context			IN VARCHAR2,
	p_attribute1			IN VARCHAR2,
	p_attribute2			IN VARCHAR2,
	p_attribute3			IN VARCHAR2,
	p_attribute4			IN VARCHAR2,
	p_attribute5			IN VARCHAR2,
	p_attribute6			IN VARCHAR2,
	p_attribute7			IN VARCHAR2,
	p_attribute8			IN VARCHAR2,
	p_attribute9			IN VARCHAR2,
	p_attribute10			IN VARCHAR2,
	p_attribute11			IN VARCHAR2,
	p_attribute12			IN VARCHAR2,
	p_attribute13			IN VARCHAR2,
	p_attribute14			IN VARCHAR2,
	p_attribute15			IN VARCHAR2,
	p_object_version_number	IN NUMBER,
	x_return_status	 OUT NOCOPY VARCHAR,
	x_msg_count		 OUT NOCOPY NUMBER,
	x_msg_data		 OUT NOCOPY VARCHAR,
	x_object_version_number OUT NOCOPY NUMBER
	)
IS
	l_api_name	CONSTANT		VARCHAR2(30)	:= 'Update_Contact';
	l_api_version	CONSTANT		NUMBER		:= 1.0;
    l_Commit VARCHAR2(1) := FND_API.G_FALSE;
    l_Init_Msg_List VARCHAR2(1) := FND_API.G_FALSE;
    l_Validation_Level NUMBER := FND_API.G_VALID_LEVEL_FULL;
    l_Msg_Index     NUMBER;
    l_Party_Tbl     csi_datastructures_pub.party_tbl;
    l_Account_Tbl   csi_datastructures_pub.party_account_tbl;
    l_Txn_Rec       csi_datastructures_pub.Transaction_Rec;

    -- added as part of fix for Bug 2733128
    l_chg_instance_rec          csi_datastructures_pub.instance_rec;
    l_chg_pricing_attribs_tbl   csi_datastructures_pub.pricing_attribs_tbl;
    l_chg_ext_attrib_val_tbl    csi_datastructures_pub.extend_attrib_values_tbl;
    l_chg_org_units_tbl         csi_datastructures_pub.organization_units_tbl;
    l_chg_inst_asset_tbl        csi_datastructures_pub.instance_asset_tbl;
    l_chg_inst_id_lst           csi_datastructures_pub.id_tbl;
BEGIN
-- Converting Single Column Attributes to Record Type.
	Convert_Contact_Param_To_Rec(
	P_cs_Contact_id	                => p_cs_contact_id,
	P_contact_category		=> p_contact_category,
	P_customer_product_id		=> p_customer_product_id,
	P_contact_id			=> p_contact_id,
	P_contact_type			=> p_contact_type,
	P_primary_flag			=> p_primary_flag,
	P_preferred_flag		=> p_preferred_flag,
	P_svc_provider_flag		=> p_svc_provider_flag,
	P_start_date_active		=> p_start_date_active,
	P_end_date_active		=> p_end_date_active,
	P_context			=> p_context,
	P_attribute1			=> p_attribute1,
	P_attribute2			=> p_attribute2,
	P_attribute3			=> p_attribute3,
	P_attribute4			=> p_attribute4,
	P_attribute5			=> p_attribute5,
	P_attribute6			=> p_attribute6,
	P_attribute7			=> p_attribute7,
	P_attribute8			=> p_attribute8,
	P_attribute9			=> p_attribute9,
	P_attribute10			=> p_attribute10,
	P_attribute11			=> p_attribute11,
	P_attribute12			=> p_attribute12,
	P_attribute13			=> p_attribute13,
	P_attribute14			=> p_attribute14,
	P_attribute15			=> p_attribute15,
    X_party_tbl             => l_party_tbl
    );
 l_Party_Tbl(1).Instance_Party_Id := P_CS_CONTACT_ID;
 l_Party_Tbl(1).Active_Start_Date := NULL;
 l_Party_Tbl(1).Object_Version_Number := P_Object_Version_Number;
 l_Txn_Rec.Transaction_Type_Id := Get_Txn_Type;
 l_Txn_Rec.Transaction_Date := SYSDATE;
 l_Txn_Rec.Source_Transaction_Date := SYSDATE;
 l_Txn_Rec.Object_Version_Number := 1;

/*
CSI_PARTY_RELATIONSHIPS_PUB.update_inst_party_relationship
 (    p_api_version                 =>     l_Api_Version,
      p_commit                      =>     l_Commit,
      p_init_msg_list               =>     l_Init_Msg_List,
      p_validation_level            =>     l_Validation_Level,
      p_Party_Tbl                   =>     l_party_tbl,
      p_party_account_tbl           =>     l_account_tbl,
      p_txn_rec                     =>     l_txn_rec,
      x_return_status               =>     x_Return_Status,
      x_msg_count                   =>     x_Msg_Count,
      x_msg_data                    =>     x_Msg_Data );
*/

    csi_item_instance_pub.update_item_instance(
      p_api_version           => 1.0,
      p_commit                => fnd_api.g_false,
      p_init_msg_list         => fnd_api.g_true,
      p_validation_level      => fnd_api.g_valid_level_full,
      p_instance_rec          => l_chg_instance_rec,
      p_ext_attrib_values_tbl => l_chg_ext_attrib_val_tbl,
      p_party_tbl             => l_party_tbl,
      p_account_tbl           => l_account_tbl,
      p_pricing_attrib_tbl    => l_chg_pricing_attribs_tbl,
      p_org_assignments_tbl   => l_chg_org_units_tbl,
      p_txn_rec               => l_txn_rec,
      p_asset_assignment_tbl  => l_chg_inst_asset_tbl,
      x_instance_id_lst       => l_chg_inst_id_lst,
      x_return_status         => x_return_status,
      x_msg_count             => x_msg_count,
      x_msg_data              => x_msg_data);

   IF NOT x_Return_Status = FND_API.G_Ret_Sts_Success
   THEN
 	l_msg_index := 1;
	 WHILE x_msg_count > 0
         LOOP
		x_Msg_Data := x_Msg_Data||FND_MSG_PUB.GET(l_msg_index,
			     		                   FND_API.G_FALSE);
		l_msg_index := l_msg_index + 1;
         x_Msg_Count := x_Msg_Count - 1;
  	 END LOOP;
   RAISE fnd_api.g_Exc_Error;
  END IF;

EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
			(p_count => x_msg_count ,
			 p_data => x_msg_data
			);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
		(p_count => x_msg_count ,
		 p_data => x_msg_data
		);
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
			FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,l_api_name);
		END IF;
		FND_MSG_PUB.Count_And_Get
			(p_count => x_msg_count ,
			 p_data => x_msg_data
			);
END Update_Row;
end csi_ext_contacts_pkg;

/
