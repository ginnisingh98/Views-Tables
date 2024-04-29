--------------------------------------------------------
--  DDL for Package Body ASO_INSTDTLS_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_INSTDTLS_INT" as
/* $Header: asoiserb.pls 120.4 2006/03/29 10:22:26 hagrawal ship $ */
-- Start of Comments
-- Package name     : ASO_Instdtls_INT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

G_PKG_NAME CONSTANT VARCHAR2(30):= 'ASO_Instdtls_INT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asoiserb.pls';

G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;


-- global variables

  l_line_inst_tbl           Line_Inst_Tbl_type;
  l_inst_count              NUMBER := 1;

Function Get_System_Rec Return System_rec_type IS
 l_system_rec  System_rec_type ;
Begin
 Return l_system_rec ;
End Get_System_Rec ;




  PROCEDURE Autocreate_systems(
	p_api_version_number           IN      NUMBER,
	p_init_msg_list         IN      VARCHAR2    := FND_API.G_FALSE,
	p_commit                IN      VARCHAR2    := FND_API.G_FALSE,
	x_return_status         OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
	x_msg_count             OUT NOCOPY /* file.sql.39 change */     NUMBER,
        x_msg_data              OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
--        p_system_tbl            IN OUT NOCOPY /* file.sql.39 change */     System_Tbl_Type
        p_system_rec            IN      System_Rec_Type ,
        x_system_name_tbl       OUT NOCOPY /* file.sql.39 change */     Name_tbl_type
  )
IS
/*   l_api_version_number NUMBER := 1;
   l_api_name VARCHAR2(50) := 'Autocreate_systems';
   l_name VARCHAR2(240);
   l_name_tbl  CS_AUTOCREATE_SYSTEMS_PKG.name_tbl_type ;*/

  BEGIN

  /*
-- dbms_output.put_line('beginning of the interface API');

 -- Standard Start of API savepoint
      SAVEPOINT Autocreate_systems_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      ASO_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

-- dbms_output.put_line('before service API');

--   FOR i in 1..p_system_tbl.count LOOP
   */
--   l_name := p_system_tbl(i).name;
/*
   CS_AUTOCREATE_SYSTEMS_PKG.autocreate
   (
        P_CUSTOMER_ID	        => p_system_tbl(i).customer_id,
 	P_NAME 			=> p_system_tbl(i).name,
 	P_DESCRIPTION		=> p_system_tbl(i).description,
 	P_SYSTEM_TYPE_CODE	=> p_system_tbl(i).system_type_code,
 	P_NUMBER_TO_CREATE	=> p_system_tbl(i).number_to_create,
 	P_INSTALL_SITE_USE_ID	=> p_system_tbl(i).install_site_use_id,
 	P_TECHNICAL_CONTACT_ID  => p_system_tbl(i).technical_contact_id,
 	P_SERVICE_ADMIN_CONTACT_ID  =>p_system_tbl(i).service_admin_contact_id,
 	P_SHIP_TO_SITE_USE_ID	=> p_system_tbl(i).ship_to_site_use_id,
 	P_SHIP_TO_CONTACT_ID	=> p_system_tbl(i).ship_to_contact_id,
 	P_BILL_TO_SITE_USE_ID	=> p_system_tbl(i).bill_to_site_use_id,
 	P_BILL_TO_CONTACT_ID	=> p_system_tbl(i).bill_to_contact_id,
     P_CONFIG_SYSTEM_TYPE	=> p_system_tbl(i).config_system_type,
	P_START_DATE_ACTIVE      => p_system_tbl(i).start_date_active,
	P_END_DATE_ACTIVE      => p_system_tbl(i).end_date_active,
	p_attribute1		=> p_system_tbl(i).attribute1,
	p_attribute2		=> p_system_tbl(i).attribute2,
	p_attribute3		=> p_system_tbl(i).attribute3,
	p_attribute4		=> p_system_tbl(i).attribute4,
	p_attribute5		=> p_system_tbl(i).attribute5,
	p_attribute6		=> p_system_tbl(i).attribute6,
	p_attribute7		=> p_system_tbl(i).attribute7,
	p_attribute8		=> p_system_tbl(i).attribute8,
	p_attribute9		=> p_system_tbl(i).attribute9,
	p_attribute10		=> p_system_tbl(i).attribute10,
	p_attribute11		=> p_system_tbl(i).attribute11,
	p_attribute12		=> p_system_tbl(i).attribute12,
	p_attribute13		=> p_system_tbl(i).attribute13,
	p_attribute14		=> p_system_tbl(i).attribute14,
	p_attribute15		=> p_system_tbl(i).attribute15,
	p_context               => p_system_tbl(i).attribute_category
   );
*/
 /*  CS_AUTOCREATE_SYSTEMS_PKG.autocreate
   (
        P_CUSTOMER_ID	        => p_system_rec.customer_id,
 	P_NAME 			=> p_system_rec.name,
 	P_DESCRIPTION		=> p_system_rec.description,
 	P_SYSTEM_TYPE_CODE	=> p_system_rec.system_type_code,
 	P_NUMBER_TO_CREATE	=> p_system_rec.number_to_create,
 	P_INSTALL_SITE_USE_ID	=> p_system_rec.install_site_use_id,
 	P_TECHNICAL_CONTACT_ID  => p_system_rec.technical_contact_id,
 	P_SERVICE_ADMIN_CONTACT_ID  =>p_system_rec.service_admin_contact_id,
 	P_SHIP_TO_SITE_USE_ID	=> p_system_rec.ship_to_site_use_id,
 	P_SHIP_TO_CONTACT_ID	=> p_system_rec.ship_to_contact_id,
 	P_BILL_TO_SITE_USE_ID	=> p_system_rec.bill_to_site_use_id,
 	P_BILL_TO_CONTACT_ID	=> p_system_rec.bill_to_contact_id,
     P_CONFIG_SYSTEM_TYPE	=> p_system_rec.config_system_type,
	P_START_DATE_ACTIVE      => p_system_rec.start_date_active,
	P_END_DATE_ACTIVE      => p_system_rec.end_date_active,
	p_attribute1		=> p_system_rec.attribute1,
	p_attribute2		=> p_system_rec.attribute2,
	p_attribute3		=> p_system_rec.attribute3,
	p_attribute4		=> p_system_rec.attribute4,
	p_attribute5		=> p_system_rec.attribute5,
	p_attribute6		=> p_system_rec.attribute6,
	p_attribute7		=> p_system_rec.attribute7,
	p_attribute8		=> p_system_rec.attribute8,
	p_attribute9		=> p_system_rec.attribute9,
	p_attribute10		=> p_system_rec.attribute10,
	p_attribute11		=> p_system_rec.attribute11,
	p_attribute12		=> p_system_rec.attribute12,
	p_attribute13		=> p_system_rec.attribute13,
	p_attribute14		=> p_system_rec.attribute14,
	p_attribute15		=> p_system_rec.attribute15,
	p_context               => p_system_rec.attribute_category,
        x_name_tbl              => l_name_tbl
   );

null;
           IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;

--p_system_tbl(i).name := l_name;

--END LOOP;

      For i IN l_name_tbl.FIRST .. l_name_tbl.LAST Loop
       x_system_name_tbl(i).system_id  := l_name_tbl(i).system_id ;
       x_system_name_tbl(i).name       := l_name_tbl(i).name  ;
      End Loop ;
      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      ASO_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Public API: ' || l_api_name || 'end');


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_SQLERRM  => sqlerrm
                  ,P_SQLCODE  => sqlcode
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

			   */
			   null;

END Autocreate_systems;



/*
-- PROCEDURE Map_to_Service_record
-- USAGE     this procedure is used to convert a ASO_instdtls_INT.inst_detail_TBL into CS_Instdtls_PUB.line_inst_dtl_REC_TYPE.
-- NEED
-- 1. forms cannot directly use CS_Instdtls_PUB.line_inst_dtl_REC_TYPE
-- 2. forms 6.0 has a bug in accepting record types

-- should be modified in future to accept rec type

PROCEDURE Map_to_Service_record(
    p_line_inst_dtl_tbl IN  inst_detail_TBL_TYPE,
    x_line_inst_dtl_rec OUT NOCOPY  file.sql.39 change  CS_Inst_detail_PUB.line_inst_dtl_REC_TYPE
  )
  IS
  i NUMBER := 1;

  BEGIN

  x_line_inst_dtl_rec.line_inst_detail_id
		:= p_line_inst_dtl_tbl(i).line_inst_detail_id;
  x_line_inst_dtl_rec.order_line_id
		:= p_line_inst_dtl_tbl(i).order_line_id;
  x_line_inst_dtl_rec.quote_line_shipment_id
		:= p_line_inst_dtl_tbl(i).quote_line_shipment_id;
  x_line_inst_dtl_rec.source_line_inst_detail_id
		:= p_line_inst_dtl_tbl(i).source_line_inst_detail_id;
  x_line_inst_dtl_rec.transaction_type_id
		:= p_line_inst_dtl_tbl(i).transaction_type_id;
  x_line_inst_dtl_rec.system_id
		:= p_line_inst_dtl_tbl(i).system_id;
  x_line_inst_dtl_rec.customer_product_id
		:= p_line_inst_dtl_tbl(i).customer_product_id;
  x_line_inst_dtl_rec.type_code
		:= p_line_inst_dtl_tbl(i).type_code;
  x_line_inst_dtl_rec.quantity
		:= p_line_inst_dtl_tbl(i).quantity;
  x_line_inst_dtl_rec.installed_at_party_site_id
		:= p_line_inst_dtl_tbl(i).installed_at_party_site_id;
  x_line_inst_dtl_rec.installed_cp_return_by_date
		:= p_line_inst_dtl_tbl(i).installed_cp_return_by_date;
  x_line_inst_dtl_rec.installed_cp_rma_line_id
		:= p_line_inst_dtl_tbl(i).installed_cp_rma_line_id;
  x_line_inst_dtl_rec.new_cp_rma_line_id
		:= p_line_inst_dtl_tbl(i).new_cp_rma_line_id;
  x_line_inst_dtl_rec.new_cp_return_by_date
		:= p_line_inst_dtl_tbl(i).new_cp_return_by_date;
  x_line_inst_dtl_rec.expected_installation_date
		:= p_line_inst_dtl_tbl(i).expected_installation_date;
  x_line_inst_dtl_rec.start_date_active
		:= p_line_inst_dtl_tbl(i).start_date_active;
  x_line_inst_dtl_rec.end_date_active
		:= p_line_inst_dtl_tbl(i).end_date_active;

		null;

END;


*/

-- PROCEDURE Modify contacts
-- USAGE     used to create, update, delete contacts.
-- NEED      single point of call to all contact related information.
--           calls service core's specify contact, update contact and delete contact.
-- REQUIRED FIELD operation code


PROCEDURE Modify_Contacts(
	p_api_version           IN NUMBER,
	p_init_msg_list         IN      VARCHAR2    := FND_API.G_FALSE,
	p_commit                IN      VARCHAR2    := FND_API.G_FALSE,
	x_return_status         OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
	x_msg_count             OUT NOCOPY /* file.sql.39 change */     NUMBER,
	x_msg_data              OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
	p_line_dtl_id    IN NUMBER := FND_API.G_MISS_NUM,
                                                --default for delete
	p_contact_tbl    IN  contact_tbl_type := G_MISS_Contact_Tbl
       )
     IS
	/*
   	l_cs_contact_id NUMBER;
   	l_cp_contact_rec CS_Installedbase_PUB.CP_Contact_Rec_Type;
   	l_obj_version_number NUMBER := -1;
   	my_message VARCHAR2(2000);
	x_obj_version_number number; --nocopy changes */

     BEGIN
	/*
--dbms_output.put_line('before modify contacts - calling cs in create 1');
 	l_cp_contact_rec.source_object_code  :=  'INST_DETAIL'	;
 	l_cp_contact_rec.source_object_id    :=  p_line_dtl_id ;
 	l_cp_contact_rec.desc_flex           :=  G_MISS_DFF_rec ;


    	FOR i in 1..p_contact_tbl.count LOOP
    	  IF p_contact_tbl(i).OPERATION_CODE is NULL THEN

             IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
              FND_MESSAGE.Set_Name('ASO', 'API_MISSING_ID');
              FND_MESSAGE.Set_Token('COLUMN', 'Contact operation code', FALSE);
              FND_MSG_PUB.ADD;
             END IF;

          ELSIF p_contact_tbl(i).OPERATION_CODE = 'CREATE' THEN

            l_cp_contact_rec.contact_id	      := p_contact_tbl(i).contact_id;
            l_cp_contact_rec.contact_type     := p_contact_tbl(i).contact_type;
            l_cp_contact_rec.contact_category := p_contact_tbl(i).contact_category; -- Added for Bug 1554869 shegde


    		 CS_Installedbase_PUB.specify_contact(
      			  p_api_version	       => 2.0,
     			  p_init_msg_list      => FND_API.G_FALSE	,
      			  p_commit             => FND_API.G_FALSE	,
			  x_return_status      => x_return_status,
			  x_msg_count	       => x_msg_count,
			  x_msg_data	       => x_msg_data,
	           	  p_contact_rec        => l_cp_contact_rec ,
			  x_cs_contact_id      => l_cs_contact_id ,
      			  x_object_version_number => l_obj_version_number
                       );

           ELSIF p_contact_tbl(i).OPERATION_CODE = 'UPDATE' THEN
   --  dbms_output.put_line('before modify contacts - calling cs update');
        	 l_cp_contact_rec.contact_id := p_contact_tbl(i).contact_id;
         	l_cp_contact_rec.contact_type := p_contact_tbl(i).contact_type;
	 	l_cs_contact_id      := p_contact_tbl(i).cs_contact_id;
          l_obj_version_number := p_contact_tbl(i).object_version_number;
          l_cp_contact_rec.contact_category := p_contact_tbl(i).contact_category; -- Added for Bug 1554869 shegde

    		   CS_Installedbase_PUB.update_contact(
       			p_api_version	        => 1.0,	-- Bug# 1531396 puzzled why 2.0 was being passed earlier ????????? reverting it to 1.0 -shegde
			x_return_status	        => x_return_status,
			x_msg_count	        =>  x_msg_count,
			x_msg_data	        => x_msg_data,
			p_cs_contact_id         => l_cs_contact_id	,
    		        p_object_version_number => l_obj_version_number,
			p_contact_rec           => l_cp_contact_rec,
      		        x_object_version_number => x_obj_version_number
                     );
               l_obj_version_number := x_obj_version_number; ---Nocopy changes

  	 ELSIF p_contact_tbl(i).OPERATION_CODE = 'DELETE' THEN
     -- dbms_output.put_line('before modify contacts - calling cs delete');
   		 CS_Installedbase_PUB.delete_contact(
   		     p_api_version	=> 1.0,		-- Bug# 1531396 puzzled why 2.0 was being passed earlier ????????? reverting it to 1.0 -shegde
		     x_return_status	=> x_return_status,
		     x_msg_count	=> x_msg_count,
		     x_msg_data	    	=> x_msg_data,
		     p_cs_contact_id	=> p_contact_tbl(i).cs_contact_id);
  	  END IF;

   END LOOP;
   */
   null;

END Modify_Contacts;



-- PROCEDURE Create_Inst_Details
-- USAGE    creates installation details and contacts
-- NEED
-- calls service core's create_installation_details and specify_contacts

PROCEDURE Create_Inst_Details(
	p_api_version           IN      NUMBER,
	p_init_msg_list         IN      VARCHAR2   := FND_API.G_FALSE,
	p_commit                IN      VARCHAR2   := FND_API.G_FALSE,
	x_return_status         OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
	x_msg_count             OUT NOCOPY /* file.sql.39 change */     NUMBER,
	x_msg_data              OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
	p_line_inst_dtl_tbl     IN      Inst_Detail_tbl_Type,
        p_cascade_line_tbl      IN      cascade_line_tbl_type
                                        := G_MISS_Cascade_Line_Tbl,
        p_contact_tbl           IN      contact_tbl_type
                                        := G_MISS_Contact_Tbl,
	x_line_inst_dtl_id      OUT NOCOPY /* file.sql.39 change */     NUMBER
)

IS /*
	l_dtl_id NUMBER;
	l_line_inst_dtl_rec CS_INST_DETAIL_PUB.Line_Inst_Dtl_Rec_Type;
	l_object_version_number NUMBER; */

BEGIN
/*
     Map_to_Service_record(
     p_line_inst_dtl_tbl =>  p_line_inst_dtl_tbl ,
     x_line_inst_dtl_rec =>  l_line_inst_dtl_rec
    );


     CS_Inst_detail_PUB.Create_Installation_details(
         p_api_version              => 1.0
	,x_return_status            => x_return_status
	,x_msg_count                => x_msg_count
	,x_msg_data                 => x_msg_data
	,p_line_inst_dtl_rec        => l_line_inst_dtl_rec
        ,p_line_inst_dtl_desc_flex  => G_MISS_DFF_rec
        ,x_object_version_number    => l_object_version_number
	,x_line_inst_detail_id      => l_dtl_id
     );

      x_line_inst_dtl_id := l_dtl_id ;


	IF (p_contact_tbl.count > 0
              and x_return_status =  FND_API.G_RET_STS_SUCCESS ) THEN
--       dbms_output.put_line('after modify contacts');
	Modify_contacts
	 ( 1.0     ,
  	   p_init_msg_list         ,
  	   p_commit                ,
  	   x_return_status         ,
   	   x_msg_count             ,
   	   x_msg_data              ,
    	   l_dtl_id                ,
   	   p_contact_tbl             );
--  dbms_output.put_line('after modify contacts');
	end if;


-- make an entry in the temp table. this is needed to prevent going to the
-- database each time.

     IF p_line_inst_dtl_tbl(1).order_line_id is not NULL
       AND p_line_inst_dtl_tbl(1).order_line_id <> FND_API.G_MISS_NUM THEN
       l_line_inst_tbl(l_inst_count).line_id
                     := p_line_inst_dtl_tbl(1).order_line_id;
     ELSE
       l_line_inst_tbl(l_inst_count).line_id
                     := p_line_inst_dtl_tbl(1).quote_line_shipment_id;
     END IF;
     l_line_inst_tbl(l_inst_count).inst_detail_id
                     := l_dtl_id;
     l_line_inst_tbl(l_inst_count).quantity := p_line_inst_dtl_tbl(1).quantity;
     l_inst_count := l_inst_count + 1;

	*/
	null;

END Create_Inst_Details;



-- PROCEDURE CASCADE_DETAILS_YN
-- USAGE This procedure is used to determine whether or not installation detail
-- should be cascaded to a new line. We check to see if the parent already has
-- installation details. If it has then the parent's details are cascaded.

   PROCEDURE CASCADE_DETAILS_YN(
        p_api_version           IN      NUMBER,
	p_init_msg_list         IN      VARCHAR2    := FND_API.G_FALSE,
	p_commit                IN      VARCHAR2    := FND_API.G_FALSE,
	x_return_status         OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
	x_msg_count             OUT NOCOPY /* file.sql.39 change */     NUMBER,
        x_msg_data              OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
        p_object_version_number IN      NUMBER,
        p_cascade_line_rec      IN      cascade_line_rec_type,
        x_line_inst_dtl_id      OUT NOCOPY /* file.sql.39 change */     NUMBER)

    IS
      /*  CURSOR C_detail_exists(parent_quote_line_id NUMBER) IS
        SELECT
	   line_inst_detail_id	         ,
	   transaction_type_id           ,
	   system_id                     ,
	   customer_product_id           ,
	   customer_product_type_code                  ,
	   customer_product_quantity                  ,
	   installed_at_party_site_id    ,
	   installed_cp_return_by_date   ,
  	   installed_cp_rma_line_id      ,
	   new_cp_rma_line_id           ,
	   new_cp_return_by_date           ,
	   expected_installation_date,
	   start_date_active,
	   end_date_active
        FROM CS_LINE_INST_DETAILS
        WHERE quote_line_shipment_id = parent_quote_line_id;


         CURSOR C_contacts_info(inst_detail_id NUMBER) IS
            SELECT contact_id, contact_type, contact_category
            FROM   cs_inst_contact_dtls_v -- Bug 1554869 shegde
            WHERE  line_inst_detail_id = inst_detail_id;


        l_api_version          NUMBER        := 1.0;
        l_api_name             VARCHAR2(100) := 'CASCADE_DETAILS_YN';
        l_line_inst_dtl_rec    Inst_Detail_rec_Type;
        l_contact_tbl          contact_tbl_type;
        l_cascade_req          VARCHAR2(2)   := 'T';
        l_line_inst_dtl_tbl    Inst_Detail_tbl_Type;
        i                      NUMBER;
        p_cascade_line_tbl     Cascade_Line_Tbl_Type;  */
     BEGIN
	/*
  -- Standard Start of API savepoint
      SAVEPOINT CASCADE_DETAILS_YN_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version,
                         	           p_api_version,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      ASO_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name(' + appShortName +', 'UT_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;


         l_line_inst_dtl_rec.quote_line_shipment_id
			:= p_cascade_line_rec.line_id;

        OPEN C_detail_exists(p_cascade_line_rec.parent_line_id);
        FETCH C_detail_exists into
	l_line_inst_dtl_rec.source_line_inst_detail_id,
	l_line_inst_dtl_rec.transaction_type_id    ,
	l_line_inst_dtl_rec.system_id               ,
	l_line_inst_dtl_rec.customer_product_id      ,
	l_line_inst_dtl_rec.type_code                 ,
	l_line_inst_dtl_rec.quantity                   ,
	l_line_inst_dtl_rec.installed_at_party_site_id  ,
	l_line_inst_dtl_rec.installed_cp_return_by_date  ,
	l_line_inst_dtl_rec.installed_cp_rma_line_id      ,
	l_line_inst_dtl_rec.new_cp_rma_line_id          ,
	l_line_inst_dtl_rec.new_cp_return_by_date        ,
	l_line_inst_dtl_rec.expected_installation_date,
	l_line_inst_dtl_rec.start_date_active,
	l_line_inst_dtl_rec.start_date_active  ;
        IF (C_detail_exists%NOTFOUND) THEN
            l_cascade_req := 'F';
        END IF;
        CLOSE C_detail_exists;

       i := 1;
       IF l_cascade_req = 'T' THEN

        l_line_inst_dtl_rec.quantity
            := l_line_inst_dtl_rec.quantity * p_cascade_line_rec.qty_factor;

        FOR j in  C_contacts_info(l_line_inst_dtl_rec.source_line_inst_detail_id) LOOP
           l_contact_tbl(i).contact_id     := j.contact_id;
           l_contact_tbl(i).contact_type   := j.contact_type;
           l_contact_tbl(i).operation_code := 'CREATE';
           l_contact_tbl(i).contact_category   := j.contact_category; -- added contact category for Bug 1554869 shegde

             i := i + 1;
        END LOOP;


         l_line_inst_dtl_tbl(1) := l_line_inst_dtl_rec;
         Create_Inst_Details(
	      p_api_version          =>  1.0 ,
              p_init_msg_list        =>  FND_API.G_FALSE ,
	      p_commit               =>  FND_API.G_FALSE ,
	      x_return_status        =>  x_return_status ,
	      x_msg_count            =>  x_msg_count ,
	      x_msg_data             =>  x_msg_data ,
	      p_line_inst_dtl_tbl    =>  l_line_inst_dtl_tbl ,
              p_cascade_line_tbl     =>  p_cascade_line_tbl  ,
              p_contact_tbl          =>  l_contact_tbl ,
	      x_line_inst_dtl_id     =>  x_line_inst_dtl_id
          );

      END IF;

      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      ASO_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Public API: ' || l_api_name || 'end');


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
                ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_SQLERRM  => sqlerrm
                  ,P_SQLCODE  => sqlcode
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
*/
null;
end Cascade_Details_YN;


-- PROCEDURE Cascade_Delete_Inst_Details
-- USAGE     used to delete installation details for all options if the model level installation detail is deleted.
-- NEED     existing functionality


   PROCEDURE Cascade_Delete_Inst_Details(
	p_api_version           IN      NUMBER,
	p_init_msg_list         IN      VARCHAR2    := FND_API.G_FALSE,
	p_commit                IN      VARCHAR2    := FND_API.G_FALSE,
	x_return_status         OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
	x_msg_count             OUT NOCOPY /* file.sql.39 change */     NUMBER,
        x_msg_data              OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
	p_line_inst_dtl_id      IN      NUMBER
   )
  IS
/*
  CURSOR cascaded_lines(p_inst_dtl_id NUMBER) IS
    select line_inst_detail_id
    from cs_line_inst_details
    where source_line_inst_detail_id = p_inst_dtl_id;
*/
BEGIN
/*
  	 FOR i in cascaded_lines(p_line_inst_dtl_id) LOOP
     	      ASO_Instdtls_INT.Delete_Installation_Detail(
       	        p_api_version_number   => 1.0,
		x_return_status        => x_return_status,
		x_msg_count            => x_msg_count,
		x_msg_data             => x_msg_data,
		p_line_inst_dtl_id     => i.line_inst_detail_id
      		 );
	 END LOOP;
	 */

null;
END Cascade_Delete_Inst_Details;


-- PROCEDURE Cascade_Update_Inst_Details
-- USAGE     used to update installation details for all options if the model level installation detail is updated.
-- NEED     existing functionality


  PROCEDURE Cascade_Update_Inst_Details(
	p_api_version           IN      NUMBER,
	p_init_msg_list         IN      VARCHAR2    := FND_API.G_FALSE,
	p_commit                IN      VARCHAR2    := FND_API.G_FALSE,
	x_return_status         OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
	x_msg_count             OUT NOCOPY /* file.sql.39 change */     NUMBER,
        x_msg_data              OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
        p_object_version_number IN      NUMBER,
        p_line_inst_dtl_tbl     IN      Inst_Detail_tbl_Type,
	p_contact_tbl           IN      contact_tbl_type := G_MISS_Contact_Tbl ,
        p_old_quantity          IN      NUMBER
  )
IS
/*
CURSOR cascaded_lines(p_inst_dtl_id NUMBER) IS
  select line_inst_detail_id, customer_product_quantity quantity, object_version_number
  from cs_line_inst_details
  where source_line_inst_detail_id = p_inst_dtl_id;

CURSOR C_cascade_cont(p_inst_dtl_id NUMBER) IS
  select cs_contact_id, object_version_number, contact_id
  from cs_inst_contact_dtls_v -- Bug 1554869 shegde
  where line_inst_detail_id = p_inst_dtl_id;

l_line_inst_dtl_tbl Inst_Detail_tbl_Type;
l_contact_tbl   contact_tbl_type;
l_object_version_number NUMBER;
*/

BEGIN
/*         l_line_inst_dtl_tbl := p_line_inst_dtl_tbl;
         l_contact_tbl       := p_contact_tbl;

  	 FOR i in cascaded_lines(p_line_inst_dtl_tbl(1).line_inst_detail_id) LOOP
           -- dbms_output.put_line('in cascade update inst details');
              l_line_inst_dtl_tbl(1).source_line_inst_detail_id
				:= p_line_inst_dtl_tbl(1).line_inst_detail_id;
              l_line_inst_dtl_tbl(1).line_inst_detail_id
                                := i.line_inst_detail_id;
              l_object_version_number
				:= i.object_version_number;


-- If quantity of the parent changes then the quantity at the child must also
-- change in the same ratio. We take the factor as an input because it could
-- lead to decimal quanitities. Instead we pass the old quantity and compute
-- the values here.

              -- Bug 2965402 : changed "<> NULL" to "IS NOT NULL"
              IF  l_line_inst_dtl_tbl(1).quantity IS NOT NULL AND
                  l_line_inst_dtl_tbl(1).quantity <> FND_API.G_MISS_NUM THEN

 -- quantity = quantity * new_quantity/old_quantity
                 l_line_inst_dtl_tbl(1).quantity :=
                  l_line_inst_dtl_tbl(1).quantity * i.quantity/p_old_quantity;

              END IF;

-- for every line in the contact table
               FOR j in 1..l_contact_tbl.count LOOP
                  IF l_contact_tbl(j).operation_code <> 'CREATE' THEN
                     FOR k in C_cascade_cont(l_line_inst_dtl_tbl(1).line_inst_detail_id) LOOP
                       IF k.contact_id = l_contact_tbl(j).old_contact_id THEN
                          l_contact_tbl(j).object_version_number
                                          := k.object_version_number;
                          l_contact_tbl(j).cs_contact_id := k.cs_contact_id;
                    --      l_contact_tbl(j).line_inst_detail_id
                 --             := l_line_inst_dtl_tbl(1).line_inst_detail_id;
                       END IF;
                     END LOOP;
                   END IF;
                 END LOOP;

        	ASO_Instdtls_INT.Update_Installation_Detail(
       	        1.0           ,
 		p_init_msg_list         ,
		p_commit                ,
		x_return_status         ,
		x_msg_count             ,
		x_msg_data              ,
                p_object_version_number => l_object_version_number,
                p_line_inst_dtl_tbl     => l_line_inst_dtl_tbl,
                p_contact_tbl           =>  l_contact_tbl ,
                p_cascade_flag          => FND_API.G_FALSE
      		 );
-- i think we need the following so that the loop can start with the initial values again.
          l_contact_tbl       := p_contact_tbl;
         END LOOP;
	    */

null;
END Cascade_Update_Inst_Details;




--   *******************************************************
--    Start of Comments
--   *******************************************************
--   API Name:  Create_Installation_Details
--   Type    :  Public
--   Pre-Req :
--   Parameters:
--
--  Standard IN Parameters:
--   p_api_version       IN   NUMBER    Required
--   p_init_msg_list     IN   VARCHAR2  Optional
--                                      := FND_API.G_FALSE
--
--  Standard OUT NOCOPY /* file.sql.39 change */ Parameters:
--   x_return_status     OUT NOCOPY /* file.sql.39 change */  VARCHAR2(1)
--   x_msg_count         OUT NOCOPY /* file.sql.39 change */  NUMBER
--   x_msg_data          OUT NOCOPY /* file.sql.39 change */  VARCHAR2(2000)
--
--  Create_Installation_Details IN Parameters:
--  p_line_inst_dtl_rec       Line_Inst_Dtl_Rec_Type   Required
--  p_cascade_line_tbl   IN   Cascade_line_tbl_type  DEFAULT = G_MISS_Cascade_Line_Tbl

--  Create_Installation_Details OUT NOCOPY /* file.sql.39 change */ Parameters:
--  x_line_inst_dtl_id        NUMBER
--
--   End of Comments
--
-- Hint: Add corresponding delete detail table procedures if it's master-detail relationship.
--       The Master delete procedure may not be needed depends on different business requirements.


PROCEDURE Create_Installation_Detail
(
	p_api_version_number    IN      NUMBER,
	p_init_msg_list         IN      VARCHAR2   := FND_API.G_FALSE,
	p_commit                IN      VARCHAR2   := FND_API.G_FALSE,
	x_return_status         OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
	x_msg_count             OUT NOCOPY /* file.sql.39 change */     NUMBER,
	x_msg_data              OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
--        p_object_version_number IN      NUMBER,
	p_line_inst_dtl_tbl     IN      Inst_Detail_TBL_Type,
        p_cascade_line_tbl      IN      cascade_line_tbl_type := G_MISS_Cascade_Line_Tbl,
        p_contact_tbl           IN      contact_tbl_type := G_MISS_Contact_Tbl,
	x_line_inst_dtl_id      OUT NOCOPY /* file.sql.39 change */     NUMBER
)
IS
/*
--BEGIN
  l_api_version_number      NUMBER := 1.0;
  l_api_name VARCHAR2(50)          := 'Create_Installation_Detail';
  l_line_inst_dtl_tbl       CS_Inst_detail_PUB.Line_Inst_Dtl_tbl_Type;
  l_cascade_line_tbl        Inst_Detail_TBL_Type := p_line_inst_dtl_tbl;
  l_return_status           NUMBER;
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(1000);
  l_dtl_id                  NUMBER;
  l_cascade_count           NUMBER := 0;
  l_p_cascade_line_tbl      cascade_line_tbl_type;


my_message VARCHAR2(2000);
*/
BEGIN
/*
   -- Standard Start of API savepoint
      SAVEPOINT CREATE_installation_detail_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      ASO_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name(' + appShortName +', 'UT_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;


-- dbms_output.put_line('before create inst details');

-- create installation details for the header or model item.
       Create_Inst_Details
       (
	p_api_version           => 1.0  ,
	p_init_msg_list         => FND_API.G_FALSE ,
	p_commit                => FND_API.G_FALSE ,
	x_return_status         => x_return_status ,
	x_msg_count             => x_msg_count ,
	x_msg_data              => x_msg_data  ,
	p_line_inst_dtl_tbl     => p_line_inst_dtl_tbl ,
        p_cascade_line_tbl      => p_cascade_line_tbl  ,
        p_contact_tbl           => p_contact_tbl ,
	x_line_inst_dtl_id      => x_line_inst_dtl_id
       );

       IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
       END IF;


-- check to see how many installation details need to be created.

     l_cascade_count := p_cascade_line_tbl.count;
     l_p_cascade_line_tbl := p_cascade_line_tbl;
    WHILE l_cascade_count > 0 LOOP

       l_cascade_line_tbl := p_line_inst_dtl_tbl ;

      FOR j in 1..l_inst_count LOOP
       FOR i in 1..l_p_cascade_line_tbl.count LOOP

-- check if parent installation detail has already been created
          IF l_line_inst_tbl(j).line_id
                = l_p_cascade_line_tbl(i).parent_line_id
          AND l_p_cascade_line_tbl(i).INST_DETAIL_CREATED
                = FND_API.G_FALSE THEN

             l_cascade_line_tbl(1).source_line_inst_detail_id
                                     := l_line_inst_tbl(j).inst_detail_id ;

-- determine whether it is an order line or a quote line
             IF l_cascade_line_tbl(1).order_line_id <> FND_API.G_MISS_NUM
               AND l_cascade_line_tbl(1).order_line_id is not NULL THEN
                    l_cascade_line_tbl(1).order_line_id
			:= l_p_cascade_line_tbl(i).line_id ;
             ELSE
                    l_cascade_line_tbl(1).quote_line_shipment_id
                        := l_p_cascade_line_tbl(i).line_id ;
             END IF;

-- cascade quantity
             l_cascade_line_tbl(1).quantity
	:= l_line_inst_tbl(j).quantity * l_p_cascade_line_tbl(i).qty_factor;
          --   dbms_output.put_line('quantity '||l_cascade_line_tbl(1).quantity);

          Create_Inst_Details(
        	p_api_version           => 1.0  ,
	        p_init_msg_list         => FND_API.G_FALSE ,
	        p_commit                => FND_API.G_FALSE ,
	        x_return_status         => x_return_status ,
	        x_msg_count             => x_msg_count ,
	        x_msg_data              => x_msg_data  ,
	        p_line_inst_dtl_tbl     => l_cascade_line_tbl  ,
                p_cascade_line_tbl      => l_p_cascade_line_tbl  ,
                p_contact_tbl           => p_contact_tbl ,
	        x_line_inst_dtl_id      => x_line_inst_dtl_id
            );

        l_p_cascade_line_tbl(i).INST_DETAIL_CREATED := FND_API.G_TRUE;
        l_cascade_count  := l_cascade_count - 1;
        END IF;

       END LOOP;  -- cascade line tbl

      END LOOP;   -- cascade count

    END LOOP;  -- count > 0


      --
      -- End of API body
      --
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      ASO_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Public API: ' || l_api_name || 'end');


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
                ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_SQLERRM  => sqlerrm
                  ,P_SQLCODE  => sqlcode
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

			   */
			   null;

end Create_Installation_Detail;



--  API name   : Update_Installation_Details
--  Type       : Public
--  Function   : This API is used to update Installation details records.
--  Pre-reqs   : None.
--
--  Standard IN Parameters:
--   p_api_version       IN   NUMBER    Required
--   p_init_msg_list     IN   VARCHAR2  Optional
--                                      Default = FND_API.G_FALSE
--
--  Standard OUT NOCOPY /* file.sql.39 change */ Parameters:
--   x_return_status     OUT NOCOPY /* file.sql.39 change */  VARCHAR2(1)
--   x_msg_count         OUT NOCOPY /* file.sql.39 change */  NUMBER
--   x_msg_data          OUT NOCOPY /* file.sql.39 change */  VARCHAR2(2000)
--
--  Update_Installation_Details IN Parameters:
--  p_line_inst_dtl_id        NUMBER                   Required
--  p_line_inst_dtl_rec       Line_Inst_Dtl_Rec_Type   Required

--  Update_Installation_Details OUT NOCOPY /* file.sql.39 change */ Parameters:
--  None
--
--  Version	:	Current version	1.0
--  				Initial version	1.0
--
-- End of comments
--------------------------------------------------------------------------

PROCEDURE Update_Installation_Detail
(
	p_api_version_number    IN      NUMBER,
	p_init_msg_list         IN      VARCHAR2    := FND_API.G_FALSE,
	p_commit                IN      VARCHAR2    := FND_API.G_FALSE,
	x_return_status         OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
	x_msg_count             OUT NOCOPY /* file.sql.39 change */     NUMBER,
	x_msg_data              OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
        p_object_version_number IN      NUMBER,
	p_line_inst_dtl_tbl     IN      Inst_Detail_tbl_Type,
	p_contact_tbl           IN      contact_tbl_type := G_MISS_Contact_Tbl,
        p_cascade_flag          IN      VARCHAR2   := FND_API.G_TRUE)
IS
   /*  CURSOR C_old_contact(l_cs_contact_id NUMBER) IS
     SELECT contact_id
     FROM cs_inst_contact_dtls_v -- Bug 1554869 shegde
     WHERE cs_contact_id = l_cs_contact_id;

     l_api_version_number NUMBER := 1.0;
     l_api_name           VARCHAR2(50) := 'UPDATE_INSTALLATION_DETAIL';
     l_cs_contact_id      NUMBER;
     l_line_inst_dtl_rec  CS_Inst_detail_PUB.Line_Inst_Dtl_Rec_Type;
     l_object_version_number NUMBER;
     l_old_quantity       NUMBER := 1;
     l_p_contact_tbl      contact_tbl_type; */
BEGIN
/*
 -- Standard Start of API savepoint
      SAVEPOINT Update_Installation_detail_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      ASO_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- API body
      --

      -- ******************************************************************
      -- Validate Environment
      -- ******************************************************************
      IF FND_GLOBAL.User_Id IS NULL
      THEN
          IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
              FND_MESSAGE.Set_Name(' + appShortName +', 'UT_CANNOT_GET_PROFILE_VALUE');
              FND_MESSAGE.Set_Token('PROFILE', 'USER_ID', FALSE);
              FND_MSG_PUB.ADD;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      END IF;



     Map_to_Service_record(
     p_line_inst_dtl_tbl =>  p_line_inst_dtl_tbl ,
     x_line_inst_dtl_rec =>  l_line_inst_dtl_rec
    );


-- this assignment is done so that if the line had previously been cascaded
-- then the source line will not change because of the update. by explicity
-- setting it to null we make sure that this line has no relationship with the
-- parent.

    IF l_line_inst_dtl_rec.source_line_inst_detail_id = FND_API.G_MISS_NUM THEN
      l_line_inst_dtl_rec.source_line_inst_detail_id := null;
   END IF;

-- old quantity is needed if updates have to be cascaded
     IF l_line_inst_dtl_rec.quantity is not NULL
        OR l_line_inst_dtl_rec.quantity <> FND_API.G_MISS_NUM THEN

        SELECT customer_product_quantity  INTO l_old_quantity
        FROM cs_line_inst_details
        where line_inst_detail_id = l_line_inst_dtl_rec.line_inst_detail_id;
        IF SQL%NOTFOUND THEN
           null;
        END IF;

     END IF;  -- inst quantity not null

    CS_Inst_detail_PUB.Update_installation_details
    (
	p_api_version       => 1.0          ,
	p_init_msg_list     => FND_API.G_FALSE        ,
	p_commit            => FND_API.G_FALSE        ,
	x_return_status     => x_return_status         ,
	x_msg_count         => x_msg_count             ,
	x_msg_data          => x_msg_data              ,
        p_line_inst_dtl_rec =>  l_line_inst_dtl_rec     ,
        p_line_inst_dtl_desc_flex => G_MISS_DFF_rec,
        P_OBJECT_VERSION_NUMBER	  => p_object_version_number,
        X_OBJECT_VERSION_NUMBER   => l_object_version_number
    );

          IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;

-- dbms_output.put_line('before modify contacts in update');

 IF p_contact_tbl.count > 0 THEN
-- first create a link between the old and new contact ids. This is needed
-- for cascading.

   l_p_contact_tbl := p_contact_tbl;
   FOR i in 1..p_contact_tbl.count LOOP
      IF p_contact_tbl(i).old_contact_id = FND_API.G_MISS_NUM
        AND p_contact_tbl(i).operation_code <> 'CREATE' THEN

        OPEN C_old_contact( p_contact_tbl(i).cs_contact_id);
        FETCH C_old_contact INTO l_p_contact_tbl(i).old_contact_id;
        IF(C_old_contact%NOTFOUND) THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;
        CLOSE  C_old_contact;

      END IF;
    END LOOP;

   Modify_contacts
     ( p_api_version        => 1.0          ,
       p_init_msg_list      => FND_API.G_FALSE        ,
       p_commit             => FND_API.G_FALSE        ,
       x_return_status      => x_return_status         ,
       x_msg_count          => x_msg_count             ,
       x_msg_data           => x_msg_data              ,
       p_line_dtl_id        => l_line_inst_dtl_rec.line_inst_detail_id ,
       p_contact_tbl        => p_contact_tbl);


         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;
   END IF;


  Cascade_update_inst_details(
     1.0,
	p_init_msg_list         ,
	p_commit                ,
	x_return_status         ,
	x_msg_count             ,
	x_msg_data              ,
        p_object_version_number ,
	p_line_inst_dtl_tbl     ,
	p_contact_tbl           ,
        l_old_quantity          );


   IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;



      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      ASO_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Public API: ' || l_api_name || 'end');


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
 null;

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
             null;

          WHEN OTHERS THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_SQLERRM  => sqlerrm
                  ,P_SQLCODE  => sqlcode
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
			   */
              null;

END Update_Installation_Detail;



--------------------------------------------------------------------------

-- Start of comments
--  API name   : Delete_Installation_Details
--  Type       : Public
--  Function   : This API is used to delete Installation details records.
--  Pre-reqs   : None.
--
--  Standard IN Parameters:
--   p_api_version       IN   NUMBER    Required
--   p_init_msg_list     IN   VARCHAR2  Optional
--                                      Default = FND_API.G_FALSE
--
--  Standard OUT NOCOPY /* file.sql.39 change */ Parameters:
--   x_return_status     OUT NOCOPY /* file.sql.39 change */  VARCHAR2(1)
--   x_msg_count         OUT NOCOPY /* file.sql.39 change */  NUMBER
--   x_msg_data          OUT NOCOPY /* file.sql.39 change */  VARCHAR2(2000)
--
--  Delete_Installation_Details IN Parameters:
--  p_line_inst_dtl_id        NUMBER                   Required

--  Delete_Installation_Details OUT NOCOPY /* file.sql.39 change */ Parameters:
--  None
--
--  Version	:	Current version	1.0
--  				Initial version	1.0
--
-- End of comments
--------------------------------------------------------------------------

PROCEDURE Delete_Installation_Detail
(
	p_api_version_number    IN      NUMBER,
	p_init_msg_list         IN      VARCHAR2    := FND_API.G_FALSE,
	p_commit                IN      VARCHAR2    := FND_API.G_FALSE,
	x_return_status         OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
	x_msg_count             OUT NOCOPY /* file.sql.39 change */     NUMBER,
	x_msg_data              OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
	p_line_inst_dtl_id      IN      NUMBER
)
IS
/*
CURSOR C_contact_info(p_inst_dtl_id NUMBER) IS
  select cs_contact_id
  from cs_inst_contact_dtls_v -- Bug 1554869 shegde
  where line_inst_detail_id = p_inst_dtl_id;

l_api_version_number NUMBER := 1.0;
l_api_name VARCHAR2(50)     := 'Delete_Installation_Detail';
l_object_version_number NUMBER;
l_contact_tbl contact_tbl_type;
j NUMBER := 1;
*/
BEGIN
/*
 -- Standard Start of API savepoint
      SAVEPOINT Delete_Installation_detail_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      ASO_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


   Cascade_delete_inst_details(
     1.0    ,
	p_init_msg_list         ,
	p_commit                ,
	x_return_status         ,
	x_msg_count             ,
	x_msg_data              ,
	p_line_inst_dtl_id
       );

           IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;


   FOR i in C_Contact_Info(p_line_inst_dtl_id) LOOP
      l_contact_tbl(j).cs_contact_id := i.cs_contact_id;
      l_contact_tbl(j).operation_code := 'DELETE';
      j := j + 1;
   END LOOP;

  IF l_contact_tbl.count > 0 THEN
   Modify_contacts
 ( 1.0    ,
   p_init_msg_list         ,
   p_commit                ,
   x_return_status         ,
   x_msg_count             ,
   x_msg_data              ,
   p_line_dtl_id => p_line_inst_dtl_id ,
   p_contact_tbl => l_contact_tbl);
  END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;


    CS_Inst_detail_PUB.Delete_installation_details(
	1.0    ,
	p_init_msg_list         ,
	p_commit                ,
	x_return_status         ,
	x_msg_count             ,
	x_msg_data              ,
	p_line_inst_dtl_id
    );

        IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;


      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      ASO_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Public API: ' || l_api_name || 'end');


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_SQLERRM  => sqlerrm
                  ,P_SQLCODE  => sqlcode
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

			   */
			   null;
END Delete_Installation_Detail;



-- PROCEDURE Update_Inst_Details_ORDER
-- USAGE     updates the installation detail to include the order line id.
-- NEED
-- 1. installation details need to be linked to an order. when creating installation details from OC the order line id does not exist. this procedure is called after the quote is converted to an order.


PROCEDURE Update_Inst_Details_ORDER
 (
        p_api_version_number			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2  := FND_API.G_FALSE,
	p_commit	  IN	VARCHAR2  := FND_API.G_FALSE,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count		 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data		 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	p_quote_line_shipment_id		IN	NUMBER,
	p_order_line_id		IN	NUMBER
)
IS
/*
      CURSOR C_inst_details IS
      SELECT count(*)
      FROM cs_line_inst_details
      WHERE quote_line_shipment_id = p_quote_line_shipment_id;

      l_api_version_number        number := 1.0;
      l_api_name           VARCHAR2(240) := 'UPDATE_INST_DETAILS_ORDER';
      l_count              NUMBER;
	 */

BEGIN
/*
     -- Standard Start of API savepoint
      SAVEPOINT Update_Inst_details_ORder_PUB;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                         	           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      ASO_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

       OPEN C_inst_details;
       FETCH C_inst_details INTO l_count;
       CLOSE C_inst_details;

     IF l_count > 0 THEN

	CS_Installedbase_GRP.Update_Inst_Details_Order_Line(
	p_api_version		=> 1.0,
	x_return_status		=> x_return_status,
	x_msg_count		=> x_msg_count,
	x_msg_data		=> x_msg_data,
	p_quote_line_shipment_id => p_quote_line_shipment_id,
	p_order_line_id		=> p_order_line_id
	);

     END IF;

 	IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
          END IF;

       -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
          COMMIT WORK;
      END IF;


      -- Debug Message
      ASO_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Public API: ' || l_api_name || 'end');


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_SQLERRM  => sqlerrm
                  ,P_SQLCODE  => sqlcode
                  ,P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
*/
null;
END;


END ASO_instdtls_INT;

/
