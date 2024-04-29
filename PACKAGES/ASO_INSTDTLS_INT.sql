--------------------------------------------------------
--  DDL for Package ASO_INSTDTLS_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_INSTDTLS_INT" AUTHID CURRENT_USER as
/* $Header: asoisers.pls 120.3 2006/03/29 10:21:58 hagrawal ship $ */
-- Start of Comments
-- Package name     : ASO_Installdetails_INT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments



--
--
-- Record types
--
-- Inst_detail_rec_type
-- Contact_Rec_Type
-- System_Rec_Type
-- Cascade_Line_Rec_Type
--
--
-- API
--
-- Create_Installation_Details
-- Update_Installation_Details
-- Delete_Installation_Details
-- Autocreate_systems
-- Update_Inst_Details_Order
--




-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;

TYPE Inst_detail_rec_type IS RECORD
(
line_inst_detail_id	      NUMBER		DEFAULT FND_API.G_MISS_NUM,
order_line_id		      NUMBER		DEFAULT FND_API.G_MISS_NUM,
quote_line_shipment_id        NUMBER		DEFAULT FND_API.G_MISS_NUM,
source_line_inst_detail_id    NUMBER		DEFAULT FND_API.G_MISS_NUM,
transaction_type_id           NUMBER		DEFAULT FND_API.G_MISS_NUM,
system_id                     NUMBER		DEFAULT FND_API.G_MISS_NUM,
customer_product_id           NUMBER		DEFAULT FND_API.G_MISS_NUM,
type_code                     VARCHAR2(30)      DEFAULT FND_API.G_MISS_CHAR,
quantity                      NUMBER	        DEFAULT FND_API.G_MISS_NUM,
installed_at_party_site_id    NUMBER	        DEFAULT FND_API.G_MISS_NUM,
installed_cp_return_by_date   DATE              DEFAULT FND_API.G_MISS_DATE,
installed_cp_rma_line_id      NUMBER	        DEFAULT FND_API.G_MISS_NUM,
new_cp_rma_line_id            NUMBER    	DEFAULT FND_API.G_MISS_NUM,
new_cp_return_by_date         DATE              DEFAULT FND_API.G_MISS_DATE,
expected_installation_date    DATE	        DEFAULT FND_API.G_MISS_DATE,
start_date_active             DATE	        DEFAULT FND_API.G_MISS_DATE,
end_date_active               DATE	        DEFAULT FND_API.G_MISS_DATE,
object_version_number         NUMBER            DEFAULT FND_API.G_MISS_NUM
        --desc_flex                     DFF_Rec_Type
);
G_MISS_Inst_detail_Rec       Inst_detail_Rec_Type;
TYPE Inst_detail_Tbl_type    IS TABLE OF Inst_detail_Rec_type
                                    INDEX BY BINARY_INTEGER;
G_MISS_Inst_detail_Tbl       Inst_detail_Tbl_Type;



TYPE Contact_Rec_Type IS RECORD
(
       CONTACT_ID         NUMBER 	:= FND_API.G_MISS_NUM,
       CONTACT_TYPE       VARCHAR2(150) := FND_API.G_MISS_CHAR,
       CS_CONTACT_ID      NUMBER := FND_API.G_MISS_NUM, -- key to cs_contacts
       OPERATION_CODE     VARCHAR2(50)  := FND_API.G_MISS_CHAR,
       OBJECT_VERSION_NUMBER NUMBER     := FND_API.G_MISS_NUM,
       OLD_CONTACT_ID     NUMBER := FND_API.G_MISS_NUM, --needed internally by api
       CONTACT_CATEGORY   VARCHAR2(30)  := FND_API.G_MISS_CHAR  -- Added for Bug 1554869 shegde

);


G_MISS_Contact_Rec          Contact_Rec_Type;
TYPE Contact_Tbl_type    IS TABLE OF Contact_Rec_type
                                    INDEX BY BINARY_INTEGER;
G_MISS_Contact_Tbl       Contact_Tbl_Type;


TYPE System_Rec_Type IS RECORD
(
	customer_id			NUMBER,
        NAME 			        VARCHAR2(240),
 	DESCRIPTION		        VARCHAR2(240),
	system_type_code		VARCHAR2(50),
	number_to_create 		NUMBER,
	install_site_use_id	 	NUMBER DEFAULT NULL,
	technical_contact_id	 	NUMBER DEFAULT NULL,
	service_admin_contact_id	NUMBER DEFAULT NULL,
	ship_to_site_use_id		NUMBER DEFAULT NULL,
	ship_to_contact_id		NUMBER DEFAULT NULL,
	bill_to_site_use_id		NUMBER DEFAULT NULL,
	bill_to_contact_id		NUMBER DEFAULT NULL,
	config_system_type		VARCHAR2(150) DEFAULT NULL,
     start_date_active        DATE	DEFAULT NULL,
     end_date_active          DATE	DEFAULT NULL,
	attribute1			VARCHAR2(150) DEFAULT NULL,
	attribute2			VARCHAR2(150) DEFAULT NULL,
	attribute3			VARCHAR2(150) DEFAULT NULL,
	attribute4			VARCHAR2(150) DEFAULT NULL,
	attribute5			VARCHAR2(150) DEFAULT NULL,
	attribute6			VARCHAR2(150) DEFAULT NULL,
	attribute7			VARCHAR2(150) DEFAULT NULL,
	attribute8			VARCHAR2(150) DEFAULT NULL,
	attribute9			VARCHAR2(150) DEFAULT NULL,
	attribute10			VARCHAR2(150) DEFAULT NULL,
	attribute11			VARCHAR2(150) DEFAULT NULL,
	attribute12			VARCHAR2(150) DEFAULT NULL,
	attribute13			VARCHAR2(150) DEFAULT NULL,
	attribute14			VARCHAR2(150) DEFAULT NULL,
	attribute15			VARCHAR2(150) DEFAULT NULL,
	attribute_category		VARCHAR2(150) DEFAULT NULL
);

G_MISS_System_Rec        System_Rec_Type;
TYPE System_Tbl_type    IS TABLE OF System_Rec_type
                                    INDEX BY BINARY_INTEGER;
G_MISS_System_Tbl       System_Tbl_Type;


TYPE Cascade_Line_Rec_Type IS RECORD
(
       LINE_ID             NUMBER := FND_API.G_MISS_NUM,
       PARENT_LINE_ID      NUMBER := FND_API.G_MISS_NUM,
       QTY_FACTOR          NUMBER := 1,
       INST_DETAIL_CREATED VARCHAR2(1) := FND_API.G_FALSE
 );


G_MISS_Cascade_Line_Rec          Cascade_Line_Rec_Type;
TYPE Cascade_Line_Tbl_type    IS TABLE OF Cascade_Line_Rec_type
                                    INDEX BY BINARY_INTEGER;
G_MISS_Cascade_line_Tbl       Cascade_Line_Tbl_Type;

--G_MISS_DFF_rec	              CS_Installedbase_PUB.DFF_rec_type;



TYPE Line_Inst_Rec_Type IS RECORD
(
       LINE_ID             NUMBER := FND_API.G_MISS_NUM,
       INST_DETAIL_ID      NUMBER := FND_API.G_MISS_NUM,
       QUANTITY            NUMBER := FND_API.G_MISS_NUM
 );


G_MISS_Line_Inst_Rec          Line_Inst_Rec_Type;
TYPE Line_Inst_Tbl_type    IS TABLE OF Line_Inst_Rec_type
                                    INDEX BY BINARY_INTEGER;
G_MISS_line_Inst_Tbl       Line_Inst_Tbl_Type;

TYPE Name_Rec_Type  IS RECORD(
	system_id		NUMBER,
	name			VARCHAR2(50));

TYPE name_tbl_type IS TABLE OF Name_Rec_Type
index by BINARY_INTEGER;

G_System_name_tbl  Name_Tbl_Type;

Function Get_System_Rec Return System_rec_type  ;

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
--                                      Default = FND_API.G_FALSE
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
	p_api_version_number           IN      NUMBER,
	p_init_msg_list         IN      VARCHAR2   DEFAULT FND_API.G_FALSE,
	p_commit                IN      VARCHAR2   DEFAULT FND_API.G_FALSE,
	x_return_status         OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
	x_msg_count             OUT NOCOPY /* file.sql.39 change */     NUMBER,
	x_msg_data              OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
    --    p_object_version_number IN      NUMBER,
	p_line_inst_dtl_tbl     IN      Inst_Detail_tbl_type,
        p_cascade_line_tbl      IN      cascade_line_tbl_type DEFAULT G_MISS_Cascade_Line_Tbl,
        p_contact_tbl           IN      contact_tbl_type DEFAULT G_MISS_Contact_Tbl,
	x_line_inst_dtl_id      OUT NOCOPY /* file.sql.39 change */     NUMBER

);

--  API name   : Update_Installation_Details
--  Type       : Public
--  Function   : This API is used to update Installation details records.
--  Pre-reqs   : None.
--
--  Standard IN Parameters:
--   p_api_version_number       IN   NUMBER    Required
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
--  p_line_inst_dtl_tbl       Line_Inst_Dtl_Tbl_Type   Required

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
	p_api_version_number           IN      NUMBER,
	p_init_msg_list         IN      VARCHAR2    DEFAULT FND_API.G_FALSE,
	p_commit                IN      VARCHAR2    DEFAULT FND_API.G_FALSE,
	x_return_status         OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
	x_msg_count             OUT NOCOPY /* file.sql.39 change */     NUMBER,
	x_msg_data              OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
        p_object_version_number IN      NUMBER,
	p_line_inst_dtl_tbl     IN      Inst_Detail_Tbl_Type,
	p_contact_tbl           IN      contact_tbl_type DEFAULT G_MISS_Contact_Tbl,
        p_cascade_flag          IN      VARCHAR2   DEFAULT FND_API.G_TRUE  );


--------------------------------------------------------------------------

-- Start of comments
--  API name   : Delete_Installation_Details
--  Type       : Public
--  Function   : This API is used to delete Installation details records.
--  Pre-reqs   : None.
--
--  Standard IN Parameters:
--   p_api_version_number       IN   NUMBER    Required
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
	p_api_version_number           IN      NUMBER,
	p_init_msg_list         IN      VARCHAR2    DEFAULT FND_API.G_FALSE,
	p_commit                IN      VARCHAR2    DEFAULT FND_API.G_FALSE,
	x_return_status         OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
	x_msg_count             OUT NOCOPY /* file.sql.39 change */     NUMBER,
	x_msg_data              OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
	p_line_inst_dtl_id      IN      NUMBER
);


PROCEDURE Autocreate_systems
(
	p_api_version_number           IN      NUMBER,
	p_init_msg_list         IN      VARCHAR2    DEFAULT FND_API.G_FALSE,
	p_commit                IN      VARCHAR2    DEFAULT FND_API.G_FALSE,
	x_return_status         OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
	x_msg_count             OUT NOCOPY /* file.sql.39 change */     NUMBER,
        x_msg_data              OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
       -- p_system_tbl            IN OUT NOCOPY /* file.sql.39 change */     System_Tbl_Type
        p_system_rec            IN      System_Rec_Type ,
        x_system_name_tbl       OUT NOCOPY /* file.sql.39 change */     Name_tbl_type
);

PROCEDURE Update_Inst_Details_ORDER
 (
        p_api_version_number			IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2  DEFAULT FND_API.G_FALSE,
	p_commit	  IN	VARCHAR2  DEFAULT FND_API.G_FALSE,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	x_msg_count		 OUT NOCOPY /* file.sql.39 change */ NUMBER,
	x_msg_data		 OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
	p_quote_line_shipment_id		IN	NUMBER,
	p_order_line_id		IN	NUMBER
);


 PROCEDURE CASCADE_DETAILS_YN(
        p_api_version           IN      NUMBER,
	p_init_msg_list         IN      VARCHAR2    DEFAULT FND_API.G_FALSE,
	p_commit                IN      VARCHAR2    DEFAULT FND_API.G_FALSE,
	x_return_status         OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
	x_msg_count             OUT NOCOPY /* file.sql.39 change */     NUMBER,
        x_msg_data              OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
        p_object_version_number IN      NUMBER,
        p_cascade_line_rec      IN      cascade_line_rec_type,
        x_line_inst_dtl_id      OUT NOCOPY /* file.sql.39 change */     NUMBER);


END ASO_instdtls_INT;

 

/
