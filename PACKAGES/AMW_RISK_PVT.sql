--------------------------------------------------------
--  DDL for Package AMW_RISK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_RISK_PVT" AUTHID CURRENT_USER AS
/* $Header: amwvrsks.pls 120.0 2005/05/31 19:22:38 appldev noship $ */

-- ===============================================================
-- Package name
--          AMW_Risk_PVT
-- Purpose
-- 		  	for Import Risk : Load_Risk (without knowing any risk_id in advance)
--			for direct call : Operate_Risk (knowing risk_id or risk_rev_id)
-- History
-- 		  	7/23/2003    tsho     Creates
-- 		  	12/09/2004   tsho     modify for new column in base table: Classification
--          		01/05/2005   tsho     add Approve_Risk procedure to approve risk without workflow
-- ===============================================================

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  	 	   	NUMBER := 30;


G_USER_ID         	 				NUMBER 		:= FND_GLOBAL.USER_ID;
G_LOGIN_ID        	 				NUMBER 		:= FND_GLOBAL.CONC_LOGIN_ID;
G_OBJ_TYPE				   CONSTANT	VARCHAR2(80)	:= AMW_UTILITY_PVT.GET_LOOKUP_MEANING('AMW_OBJECT_TYPE','RISK');

-- FND_API global constant
G_FALSE    		  		   CONSTANT VARCHAR2(1) := FND_API.G_FALSE;
G_TRUE 					   CONSTANT VARCHAR2(1) := FND_API.G_TRUE;
G_VALID_LEVEL_FULL 		   CONSTANT NUMBER 		:= FND_API.G_VALID_LEVEL_FULL;
G_RET_STS_SUCCESS 		   CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
G_RET_STS_ERROR			   CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
G_RET_STS_UNEXP_ERROR 	   CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;


-- Operate_Risk with global p_operate_mode
G_OP_CREATE			 	   CONSTANT NUMBER := 10;
G_OP_UPDATE        		   CONSTANT NUMBER := 20;
G_OP_REVISE        		   CONSTANT NUMBER := 30;
G_OP_DELETE        		   CONSTANT NUMBER := 40;


-- ===================================================================
--    Record name
--             risk_rec_type
--   Parameters:
--       risk_id
--       last_update_date
--       last_update_login
--       created_by
--       last_updated_by
--       risk_impact
--       likelihood
--       attribute_category
--       attribute1
--       attribute2
--       attribute3
--       attribute4
--       attribute5
--       attribute6
--       attribute7
--       attribute8
--       attribute9
--       attribute10
--       attribute11
--       attribute12
--       attribute13
--       attribute14
--       attribute15
--       security_group_id
--       risk_type
--       approval_status
--       object_version_number
--       approval_date
--       creation_date
--       risk_rev_num
--       risk_rev_id
--       requestor_id
--       orig_system_reference
--       latest_revision_flag
--       end_date
--       curr_approved_flag
--       risk_name
--       risk_description
--       material
--       classification (12.09.2004 added by tsho)
-- ===================================================================
TYPE risk_rec_type IS RECORD
(
       risk_id                         NUMBER			:= NULL,
       last_update_date                DATE 			:= NULL,
       last_update_login               NUMBER 			:= NULL,
       created_by                      NUMBER 			:= NULL,
       last_updated_by                 NUMBER 			:= NULL,
       risk_impact                     VARCHAR2(30) 	:= NULL,
       likelihood                      VARCHAR2(30) 	:= NULL,
       attribute_category              VARCHAR2(30) 	:= NULL,
       attribute1                      VARCHAR2(150) 	:= NULL,
       attribute2                      VARCHAR2(150) 	:= NULL,
       attribute3                      VARCHAR2(150) 	:= NULL,
       attribute4                      VARCHAR2(150) 	:= NULL,
       attribute5                      VARCHAR2(150) 	:= NULL,
       attribute6                      VARCHAR2(150) 	:= NULL,
       attribute7                      VARCHAR2(150) 	:= NULL,
       attribute8                      VARCHAR2(150) 	:= NULL,
       attribute9                      VARCHAR2(150) 	:= NULL,
       attribute10                     VARCHAR2(150) 	:= NULL,
       attribute11                     VARCHAR2(150) 	:= NULL,
       attribute12                     VARCHAR2(150) 	:= NULL,
       attribute13                     VARCHAR2(150) 	:= NULL,
       attribute14                     VARCHAR2(150) 	:= NULL,
       attribute15                     VARCHAR2(150) 	:= NULL,
       security_group_id               NUMBER 			:= NULL,
       risk_type                       VARCHAR2(30) 	:= NULL,
       approval_status                 VARCHAR2(30) 	:= NULL,
       object_version_number           NUMBER 			:= NULL,
       approval_date                   DATE 			:= NULL,
       creation_date                   DATE 			:= NULL,
       risk_rev_num                    NUMBER 			:= NULL,
       risk_rev_id                     NUMBER 			:= NULL,
       requestor_id                    NUMBER 			:= G_USER_ID,
       orig_system_reference           VARCHAR2(240) 	:= NULL,
       latest_revision_flag            VARCHAR2(1) 		:= NULL,
       end_date                        DATE 			:= NULL,
       curr_approved_flag              VARCHAR2(1) 		:= NULL,
       risk_name                       VARCHAR2(240) 	:= NULL,
       risk_description                VARCHAR2(4000)	:= NULL,
	   material						   varchar2(1)		:= NULL,
       classification                  NUMBER           := NULL
);

g_miss_risk_rec          risk_rec_type;
TYPE  risk_tbl_type      IS TABLE OF risk_rec_type INDEX BY BINARY_INTEGER;
g_miss_risk_tbl          risk_tbl_type;



-- ===============================================================
-- Procedure name
--          Load_Risk
-- Purpose
-- 		  	for Import Risk with approval_status 'A' or 'D'
-- ===============================================================
PROCEDURE Load_Risk(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := G_FALSE,
    p_commit                     IN   VARCHAR2     := G_FALSE,
    p_validation_level           IN   NUMBER       := G_VALID_LEVEL_FULL,
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,
    p_risk_rec               	 IN   risk_rec_type,
    x_risk_rev_id      		 OUT  NOCOPY NUMBER,
    x_risk_id      		 OUT  NOCOPY NUMBER
    );



-- ===============================================================
-- Procedure name
--          Operate_Risk
-- Purpose
-- 		  	operate risk depends on the pass-in p_operate_mode:
--			G_OP_CREATE
--			G_OP_UPDATE
--			G_OP_REVISE
--			G_OP_DELETE
-- Notes
-- 			the G_OP_UPDATE mode here is in business logic meaning,
--			not as the same as update in table handler meaning.
--			same goes to other p_operate_mode  if it happens to
--			have similar name.
-- ===============================================================
PROCEDURE Operate_Risk(
    p_operate_mode	   			 IN	  VARCHAR2,
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := G_FALSE,
    p_commit                     IN   VARCHAR2     := G_FALSE,
    p_validation_level           IN   NUMBER       := G_VALID_LEVEL_FULL,
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,
    p_risk_rec               	 IN   risk_rec_type,
    x_risk_rev_id      		 OUT  NOCOPY NUMBER,
    x_risk_id      		 OUT  NOCOPY NUMBER
    );



-- ===============================================================
-- Procedure name
--          Create_Risk
-- Purpose
-- 		  	create risk with specified approval_status,
--			if no specified approval_status in pass-in p_risk_rec,
--			the default approval_status is set to 'D'.
-- ===============================================================
PROCEDURE Create_Risk(
    p_operate_mode	   			 IN	  VARCHAR2,
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := G_FALSE,
    p_commit                     IN   VARCHAR2     := G_FALSE,
    p_validation_level           IN   NUMBER       := G_VALID_LEVEL_FULL,

    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,

    p_risk_rec               	 IN   risk_rec_type,
    x_risk_rev_id                OUT  NOCOPY NUMBER,
    x_risk_id      		 OUT  NOCOPY NUMBER
     );



-- ===============================================================
-- Procedure name
--          Update_Risk
-- Purpose
-- 		  	update risk with specified risk_rev_id,
--			if no specified risk_rev_id in pass-in p_risk_rec,
--			this will update the one with specified risk_id having
--			latest_revision_flag='Y' AND approval_status='D'.
-- Notes
-- 			if risk_rev_id is not specified, then
-- 			risk_id is a must when calling Update_Risk
-- ===============================================================
PROCEDURE Update_Risk(
    p_operate_mode	   			 IN	  VARCHAR2,
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := G_FALSE,
    p_commit                     IN   VARCHAR2     := G_FALSE,
    p_validation_level           IN   NUMBER       := G_VALID_LEVEL_FULL,

    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,

    p_risk_rec               	 IN   risk_rec_type,
    x_risk_rev_id      		 OUT  NOCOPY NUMBER,
    x_risk_id      		 OUT  NOCOPY NUMBER
    );



-- ===============================================================
-- Procedure name
--          Delete_Risk
-- Purpose
-- 		  	delete risk with specified risk_rev_id.
-- ===============================================================
PROCEDURE Delete_Risk(
    p_operate_mode	   			 IN	  VARCHAR2,
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := G_FALSE,
    p_commit                     IN   VARCHAR2     := G_FALSE,
    p_validation_level           IN   NUMBER       := G_VALID_LEVEL_FULL,
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,
    p_risk_rev_id                IN   NUMBER,
    x_risk_id      		 OUT  NOCOPY NUMBER
    );




-- ===============================================================
-- Procedure name
--          Revise_Without_Revision_Exists
-- Purpose
-- 		  	revise risk with specified risk_id,
--			it'll revise the one having latest_revision_flag='Y'
--			AND approval_status='A' OR 'R' of specified risk_id.
--			the new revision created by this call will have
--			latest_revision_flag='Y', and the approval_status
--			will be set to 'D' if not specified in the p_risk_rec
--			the revisee(the old one) will have latest_revision_flag='N'
-- Note
-- 	   		actually the name for Revise_Without_Revision_Exists
--			should be Revise_Without_Draft_Revision_Exists if there's
--			no limitation for the procedure name.
-- ===============================================================
PROCEDURE Revise_Without_Revision_Exists(
    p_operate_mode	   			 IN	  VARCHAR2,
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := G_FALSE,
    p_commit                     IN   VARCHAR2     := G_FALSE,
    p_validation_level           IN   NUMBER       := G_VALID_LEVEL_FULL,

    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,

    p_risk_rec               	 IN   risk_rec_type,
    x_risk_rev_id      		 OUT  NOCOPY NUMBER,
    x_risk_id      		 OUT  NOCOPY NUMBER
    );



-- ===============================================================
-- Procedure name
--          Validate_risk
-- Purpose
-- 		  	Validate_risk is the container for calling all the other
--			validation procedures on one record(Validate_xxx_Rec) and
--			the container of validation on items(Check_Risk_Items)
-- Note
-- 	   		basically, this should be called before calling table handler
-- ===============================================================
PROCEDURE Validate_risk(
    p_operate_mode	   			 IN	  VARCHAR2,
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := G_FALSE,
    p_validation_level           IN   NUMBER 	   := G_VALID_LEVEL_FULL,
    p_risk_rec               	 IN   risk_rec_type,
    x_risk_rec               	 OUT  NOCOPY risk_rec_type,
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2
    );



-- ===============================================================
-- Procedure name
--          Check_risk_Items
-- Purpose
-- 		  	check all the necessaries for items
-- Note
-- 	   		Check_risk_Items is the container for calling all the
--			other validation procedures on items(check_xxx_Items)
--			the validation on items should be only table column constraints
--			not the business logic validation.
-- ===============================================================
PROCEDURE Check_risk_Items (
    p_operate_mode 		         IN  VARCHAR2,
    P_risk_rec 				 IN  risk_rec_type,
    x_return_status 			 OUT NOCOPY VARCHAR2
    );



-- ===============================================================
-- Procedure name
--          check_risk_uk_items
-- Purpose
-- 		  	check the uniqueness of the items which have been marked
--			as unique in table
-- ===============================================================
PROCEDURE check_risk_uk_items(
    p_operate_mode 			 IN  VARCHAR2,
    p_risk_rec 				 IN  risk_rec_type,
    x_return_status 			 OUT NOCOPY VARCHAR2
	);



-- ===============================================================
-- Procedure name
--          check_risk_req_items
-- Purpose
-- 		  	check the requireness of the items which have been marked
--			as NOT NULL in table
-- Note
-- 	   		since the standard default with
--			FND_API.G_MISS_XXX v.s. NULL has been changed to:
--			if user want to update to Null, pass in G_MISS_XXX
--			else if user want to update to some value, pass in value
--			else if user doesn't want to update, pass in NULL.
-- Reference
-- 			http://www-apps.us.oracle.com/atg/performance/
--			Standards and Templates>Business Object API Coding Standards
-- 			2.3.1 Differentiating between Missing parameters and Null parameters
-- ===============================================================
PROCEDURE check_risk_req_items(
    p_operate_mode 			 IN  VARCHAR2,
    p_risk_rec 				 IN  risk_rec_type,
    x_return_status 			 OUT NOCOPY VARCHAR2
	);



-- ===============================================================
-- Procedure name
--          check_risk_FK_items
-- Purpose
-- 		  	check forien key of the items
-- ===============================================================
PROCEDURE check_risk_FK_items(
    p_operate_mode 			 IN  VARCHAR2,
    p_risk_rec 				 IN  risk_rec_type,
    x_return_status 			 OUT NOCOPY VARCHAR2
	);



-- ===============================================================
-- Procedure name
--          check_risk_Lookup_items
-- Purpose
-- 		  	check lookup of the items
-- ===============================================================
PROCEDURE check_risk_Lookup_items(
    p_operate_mode 			 IN  VARCHAR2,
    p_risk_rec 				 IN  risk_rec_type,
    x_return_status 			 OUT NOCOPY VARCHAR2
	);




-- ===============================================================
-- Procedure name
--          Complete_risk_Rec
-- Purpose
-- 		  	complete(fill out) the items which are not specified.
-- Note
-- 	   		basically, this is called when G_OP_UPDATE, G_OP_REVISE
-- ===============================================================
PROCEDURE Complete_risk_Rec (
   p_risk_rec 				IN  risk_rec_type,
   x_complete_rec 			 OUT NOCOPY risk_rec_type
   );




-- ===============================================================
-- Procedure name
--          Validate_risk_rec
-- Purpose
-- 		  	check all the necessaries for one record,
--			this includes the cross-items validation
-- Note
-- 	   		Validate_risk_rec is the dispatcher of
--			other validation procedures on one record.
--			business logic validation should go here.
-- ===============================================================
PROCEDURE Validate_risk_rec(
    p_operate_mode	   			 IN	  VARCHAR2,
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := G_FALSE,
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,
    p_risk_rec               	 IN   risk_rec_type
    );




-- ===============================================================
-- Procedure name
--          Validate_create_risk_rec
-- Purpose
-- 		  	this is the validation for mode G_OP_CREATE.
-- Note
--			risk name cannot be duplicated in table
-- ===============================================================
PROCEDURE Validate_create_risk_rec(
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,
    p_risk_rec               	 IN   risk_rec_type
    );




-- ===============================================================
-- Procedure name
--          Validate_update_risk_rec
-- Purpose
-- 		  	this is the validation for mode G_OP_UPDATE.
-- Note
--			risk name cannot be duplicated in table.
--			only the risk with approval_status='D' can be use G_OP_UPDATE
-- ===============================================================
PROCEDURE Validate_update_risk_rec(
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,
    p_risk_rec               	 IN   risk_rec_type
    );




-- ===============================================================
-- Procedure name
--          Validate_revise_risk_rec
-- Purpose
-- 		  	this is the validation for mode G_OP_REVISE.
-- Note
-- 	   		changing risk name when revising a risk is not allowed.
-- ===============================================================
PROCEDURE Validate_revise_risk_rec(
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,
    p_risk_rec               	 IN   risk_rec_type
    );



-- ===============================================================
-- Procedure name
--          Validate_delete_risk_rec
-- Purpose
-- 		  	this is the validation for mode G_OP_DELETE.
-- Note
-- 	   		not implemented yet.
--			need to find out when(approval_status='?') can G_OP_DELETE.
-- ===============================================================
PROCEDURE Validate_delete_risk_rec(
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,
    p_risk_rec               	 IN   risk_rec_type
    );


-- ===============================================================
-- Procedure name
--          Approve_Risk
-- Purpose
-- 		  	to approve the risk without going through workflow
-- Note
--
-- ===============================================================
PROCEDURE Approve_Risk(
    p_risk_rev_id                IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2          := G_FALSE,
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2
    );

-- ----------------------------------------------------------------------
END AMW_Risk_PVT;

 

/
