--------------------------------------------------------
--  DDL for Package AMW_AUDIT_PROCEDURES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_AUDIT_PROCEDURES_PVT" AUTHID CURRENT_USER AS
/* $Header: amwvrcds.pls 120.0 2005/05/31 20:31:01 appldev noship $ */
-- ===============================================================
-- Package name
--          AMW_AUDIT_PROCEDURES_PVT
-- Purpose
-- 		  	for Import Audit Procedure : Load_AP (without knowing any audit_procedure_id in advance)
--			for direct call : Operate_AP (knowing audit_procedure_id or audit_procedure_rev_id)
-- History
-- 		  	12/08/2003    tsho     Creates
-- ===============================================================

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  	 	   	NUMBER := 30;


G_USER_ID         	 	   CONSTANT NUMBER 		:= FND_GLOBAL.USER_ID;
G_LOGIN_ID        	 	   CONSTANT NUMBER 		:= FND_GLOBAL.CONC_LOGIN_ID;
G_OBJ_TYPE				   CONSTANT	VARCHAR2(80)	:= AMW_UTILITY_PVT.GET_LOOKUP_MEANING('AMW_OBJECT_TYPE','AP');

-- FND_API global constant
G_FALSE    		  		   CONSTANT VARCHAR2(1) := FND_API.G_FALSE;
G_TRUE 					   CONSTANT VARCHAR2(1) := FND_API.G_TRUE;
G_VALID_LEVEL_FULL 		   CONSTANT NUMBER 		:= FND_API.G_VALID_LEVEL_FULL;
G_RET_STS_SUCCESS 		   CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
G_RET_STS_ERROR			   CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_ERROR;
G_RET_STS_UNEXP_ERROR 	   CONSTANT VARCHAR2(1) := FND_API.G_RET_STS_UNEXP_ERROR;


-- Operate_AP with global p_operate_mode
G_OP_CREATE			 	   CONSTANT NUMBER := 10;
G_OP_UPDATE        		   CONSTANT NUMBER := 20;
G_OP_REVISE        		   CONSTANT NUMBER := 30;
G_OP_DELETE        		   CONSTANT NUMBER := 40;


-- ===================================================================
--    Record name
--             audit_procedure_rec_type
--   Parameters:
--       audit_procedure_id
--       audit_procedure_rev_id
--       audit_procedure_rev_num
--       end_date
--       approval_date
--       curr_approved_flag
--       latest_revision_flag
--       last_update_date
--       last_updated_by
--       creation_date
--       created_by
--       last_update_login
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
--       object_version_number
--       approval_status
--       orig_system_reference
--       requestor_id
--       audit_procedure_name
--       audit_procedure_description
-- ===================================================================
TYPE audit_procedure_rec_type IS RECORD
(
    audit_procedure_id              NUMBER			:= NULL,
    audit_procedure_rev_id          NUMBER 			:= NULL,
    audit_procedure_rev_num         NUMBER 			:= NULL,
    end_date                        DATE 			:= NULL,
    approval_date                   DATE 			:= NULL,
    curr_approved_flag              VARCHAR2(1) 	:= NULL,
    latest_revision_flag            VARCHAR2(1) 	:= NULL,
    last_update_date                DATE 			:= NULL,
    last_updated_by                 NUMBER 			:= NULL,
    creation_date                   DATE 			:= NULL,
    created_by                      NUMBER 			:= NULL,
    last_update_login               NUMBER 			:= NULL,
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
    object_version_number           NUMBER 			:= NULL,
    approval_status                 VARCHAR2(30) 	:= NULL,
    orig_system_reference           VARCHAR2(240) 	:= NULL,
    requestor_id                    NUMBER 			:= G_USER_ID,
    audit_procedure_name            VARCHAR2(240) 	:= NULL,
    audit_procedure_description     VARCHAR2(4000)	:= NULL,
    project_id                      NUMBER          := NULL,
    classification                  NUMBER          := NULL
);

g_miss_audit_procedure_rec          audit_procedure_rec_type;
TYPE  audit_procedure_tbl_type      IS TABLE OF audit_procedure_rec_type INDEX BY BINARY_INTEGER;
g_miss_audit_procedure_tbl          audit_procedure_tbl_type;



-- ===============================================================
-- Procedure name
--          Load_AP
-- Purpose
-- 		  	for Import Audit Procedure with approval_status 'A' or 'D'
-- ===============================================================
PROCEDURE Load_AP(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := G_FALSE,
    p_commit                     IN   VARCHAR2     := G_FALSE,
    p_validation_level           IN   NUMBER       := G_VALID_LEVEL_FULL,
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,
    p_audit_procedure_rec        IN   audit_procedure_rec_type,
    x_audit_procedure_rev_id     OUT  NOCOPY NUMBER,
    x_audit_procedure_id         OUT  NOCOPY NUMBER,
    p_approval_date              IN   DATE
    );



-- ===============================================================
-- Procedure name
--          Operate_AP
-- Purpose
-- 		  	operate audit procedure depends on the pass-in p_operate_mode:
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
PROCEDURE Operate_AP(
    p_operate_mode	   			 IN	  VARCHAR2,
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := G_FALSE,
    p_commit                     IN   VARCHAR2     := G_FALSE,
    p_validation_level           IN   NUMBER       := G_VALID_LEVEL_FULL,
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,
    p_audit_procedure_rec        IN   audit_procedure_rec_type,
    x_audit_procedure_rev_id     OUT  NOCOPY NUMBER,
    x_audit_procedure_id         OUT  NOCOPY NUMBER,
    p_approval_date              IN   DATE
    );



-- ===============================================================
-- Procedure name
--          Create_AP
-- Purpose
-- 		  	create audit procedure with specified approval_status,
--			if no specified approval_status in pass-in p_audit_procedure_rec,
--			the default approval_status is set to 'D'.
-- ===============================================================
PROCEDURE Create_AP(
    p_operate_mode	   			 IN	  VARCHAR2,
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := G_FALSE,
    p_commit                     IN   VARCHAR2     := G_FALSE,
    p_validation_level           IN   NUMBER       := G_VALID_LEVEL_FULL,

    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,

    p_audit_procedure_rec        IN   audit_procedure_rec_type,
    x_audit_procedure_rev_id     OUT  NOCOPY NUMBER,
    x_audit_procedure_id         OUT  NOCOPY NUMBER
     );



-- ===============================================================
-- Procedure name
--          Update_AP
-- Purpose
-- 		  	update audit procedure with specified audit_procedure_rev_id,
--			if no specified audit_procedure_rev_id in pass-in p_audit_procedure_rec,
--			this will update the one with specified audit_procedure_id having
--			latest_revision_flag='Y' AND approval_status='D'.
-- Notes
-- 			if audit_procedure_rev_id is not specified, then
-- 			audit_procedure_id is a must when calling Update_AP
-- ===============================================================
PROCEDURE Update_AP(
    p_operate_mode	   			 IN	  VARCHAR2,
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := G_FALSE,
    p_commit                     IN   VARCHAR2     := G_FALSE,
    p_validation_level           IN   NUMBER       := G_VALID_LEVEL_FULL,

    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,

    p_audit_procedure_rec        IN   audit_procedure_rec_type,
    x_audit_procedure_rev_id     OUT  NOCOPY NUMBER,
    x_audit_procedure_id         OUT  NOCOPY NUMBER
    );



-- ===============================================================
-- Procedure name
--          Delete_AP
-- Purpose
-- 		  	delete audit procedure with specified audit_procedure_rev_id.
-- ===============================================================
PROCEDURE Delete_AP(
    p_operate_mode	   			 IN	  VARCHAR2,
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := G_FALSE,
    p_commit                     IN   VARCHAR2     := G_FALSE,
    p_validation_level           IN   NUMBER       := G_VALID_LEVEL_FULL,
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,
    p_audit_procedure_rev_id     IN   NUMBER,
    x_audit_procedure_id         OUT  NOCOPY NUMBER
    );




-- ===============================================================
-- Procedure name
--          Revise_Without_Revision_Exists
-- Purpose
-- 		  	revise audit procedure with specified audit_procedure_id,
--			it'll revise the one having latest_revision_flag='Y'
--			AND approval_status='A' OR 'R' of specified audit_procedure_id.
--			the new revision created by this call will have
--			latest_revision_flag='Y', and the approval_status
--			will be set to 'D' if not specified in the p_audit_procedure_rec
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

    p_audit_procedure_rec      	 IN   audit_procedure_rec_type,
    x_audit_procedure_rev_id	 OUT  NOCOPY NUMBER,
    x_audit_procedure_id         OUT  NOCOPY NUMBER
    );



-- ===============================================================
-- Procedure name
--          Validate_AP
-- Purpose
-- 		  	Validate_AP is the container for calling all the other
--			validation procedures on one record(Validate_xxx_Rec) and
--			the container of validation on items(Check_AP_Items)
-- Note
-- 	   		basically, this should be called before calling table handler
-- ===============================================================
PROCEDURE Validate_AP(
    p_operate_mode	   			 IN	  VARCHAR2,
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := G_FALSE,
    p_validation_level           IN   NUMBER 	   := G_VALID_LEVEL_FULL,
    p_audit_procedure_rec      	 IN   audit_procedure_rec_type,
    x_audit_procedure_rec      	 OUT  NOCOPY audit_procedure_rec_type,
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2
    );



-- ===============================================================
-- Procedure name
--          Check_AP_Items
-- Purpose
-- 		  	check all the necessaries for items
-- Note
-- 	   		Check_AP_Items is the container for calling all the
--			other validation procedures on items(check_xxx_Items)
--			the validation on items should be only table column constraints
--			not the business logic validation.
-- ===============================================================
PROCEDURE Check_AP_Items (
    p_operate_mode 		         IN  VARCHAR2,
    P_audit_procedure_rec		 IN  audit_procedure_rec_type,
    x_return_status 			 OUT NOCOPY VARCHAR2
    );



-- ===============================================================
-- Procedure name
--          check_AP_uk_items
-- Purpose
-- 		  	check the uniqueness of the items which have been marked
--			as unique in table
-- ===============================================================
PROCEDURE check_AP_uk_items(
    p_operate_mode 			 IN  VARCHAR2,
    p_audit_procedure_rec	 IN  audit_procedure_rec_type,
    x_return_status 		 OUT NOCOPY VARCHAR2
	);



-- ===============================================================
-- Procedure name
--          check_AP_req_items
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
PROCEDURE check_AP_req_items(
    p_operate_mode 			 IN  VARCHAR2,
    p_audit_procedure_rec	 IN  audit_procedure_rec_type,
    x_return_status 		 OUT NOCOPY VARCHAR2
	);



-- ===============================================================
-- Procedure name
--          check_AP_FK_items
-- Purpose
-- 		  	check forien key of the items
-- ===============================================================
PROCEDURE check_AP_FK_items(
    p_operate_mode 			 IN  VARCHAR2,
    p_audit_procedure_rec 	 IN  audit_procedure_rec_type,
    x_return_status 		 OUT NOCOPY VARCHAR2
	);



-- ===============================================================
-- Procedure name
--          check_AP_Lookup_items
-- Purpose
-- 		  	check lookup of the items
-- ===============================================================
PROCEDURE check_AP_Lookup_items(
    p_operate_mode 			 IN  VARCHAR2,
    p_audit_procedure_rec	 IN  audit_procedure_rec_type,
    x_return_status 		 OUT NOCOPY VARCHAR2
	);




-- ===============================================================
-- Procedure name
--          Complete_AP_Rec
-- Purpose
-- 		  	complete(fill out) the items which are not specified.
-- Note
-- 	   		basically, this is called when G_OP_UPDATE, G_OP_REVISE
-- ===============================================================
PROCEDURE Complete_AP_Rec (
   p_audit_procedure_rec    IN  audit_procedure_rec_type,
   x_complete_rec           OUT NOCOPY audit_procedure_rec_type
   );




-- ===============================================================
-- Procedure name
--          Validate_AP_rec
-- Purpose
-- 		  	check all the necessaries for one record,
--			this includes the cross-items validation
-- Note
-- 	   		Validate_AP_rec is the dispatcher of
--			other validation procedures on one record.
--			business logic validation should go here.
-- ===============================================================
PROCEDURE Validate_AP_rec(
    p_operate_mode	   			 IN	  VARCHAR2,
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := G_FALSE,
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,
    p_audit_procedure_rec      	 IN   audit_procedure_rec_type
    );




-- ===============================================================
-- Procedure name
--          Validate_create_AP_rec
-- Purpose
-- 		  	this is the validation for mode G_OP_CREATE.
-- Note
--			risk name cannot be duplicated in table
-- ===============================================================
PROCEDURE Validate_create_AP_rec(
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,
    p_audit_procedure_rec      	 IN   audit_procedure_rec_type
    );




-- ===============================================================
-- Procedure name
--          Validate_update_AP_rec
-- Purpose
-- 		  	this is the validation for mode G_OP_UPDATE.
-- Note
--			risk name cannot be duplicated in table.
--			only the risk with approval_status='D' can be use G_OP_UPDATE
-- ===============================================================
PROCEDURE Validate_update_AP_rec(
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,
    p_audit_procedure_rec      	 IN   audit_procedure_rec_type
    );




-- ===============================================================
-- Procedure name
--          Validate_revise_AP_rec
-- Purpose
-- 		  	this is the validation for mode G_OP_REVISE.
-- Note
-- 	   		changing audit procedure name when revising an audit procedure is not allowed.
-- ===============================================================
PROCEDURE Validate_revise_AP_rec(
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,
    p_audit_procedure_rec      	 IN   audit_procedure_rec_type
    );



-- ===============================================================
-- Procedure name
--          Validate_delete_AP_rec
-- Purpose
-- 		  	this is the validation for mode G_OP_DELETE.
-- Note
-- 	   		not implemented yet.
--			need to find out when(approval_status='?') can G_OP_DELETE.
-- ===============================================================
PROCEDURE Validate_delete_AP_rec(
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,
    p_audit_procedure_rec      	 IN   audit_procedure_rec_type
    );


-- ===============================================================
-- Procedure name
--          copy_audit_step
-- Purpose
-- 		  	this procedure copies audit steps from from_ap_rev_id to
--          to_ap_rev_id
-- Note
--
-- ===============================================================
PROCEDURE copy_audit_steps(
		  p_api_version        	IN	NUMBER,
  		  p_init_msg_list		IN	VARCHAR2, -- default FND_API.G_FALSE,
		  p_commit	    		IN  VARCHAR2, -- default FND_API.G_FALSE,
		  p_validation_level	IN  NUMBER,	-- default	FND_API.G_VALID_LEVEL_FULL,
     	  x_return_status		OUT	NOCOPY VARCHAR2,
		  x_msg_count			OUT	NOCOPY NUMBER,
		  x_msg_data			OUT	NOCOPY VARCHAR2,
		  x_from_ap_rev_id IN NUMBER,
		  x_to_ap_id IN NUMBER
		  );

-- ===============================================================
-- Procedure name
--          copy_tasks
-- Purpose
-- 		  	this procedure copies tasks from from_ap_id to
--          to_ap_id
-- Note
--
-- ===============================================================
PROCEDURE copy_tasks(
		  p_api_version        	IN	NUMBER,
  		  p_init_msg_list		IN	VARCHAR2, -- default FND_API.G_FALSE,
		  p_commit	    		IN  VARCHAR2, -- default FND_API.G_FALSE,
		  p_validation_level	IN  NUMBER,	-- default	FND_API.G_VALID_LEVEL_FULL,
     	  x_return_status		OUT	NOCOPY VARCHAR2,
		  x_msg_count			OUT	NOCOPY NUMBER,
		  x_msg_data			OUT	NOCOPY VARCHAR2,
		  x_from_ap_id IN NUMBER,
		  x_to_ap_id IN NUMBER
		  );

-- ===============================================================
-- Procedure name
--          copy_controls
-- Purpose
-- 		  	this procedure copies controls from from_ap_id to
--          to_ap_id
-- Note
--
-- ===============================================================
PROCEDURE copy_controls(
		  p_api_version        	IN	NUMBER,
  		  p_init_msg_list		IN	VARCHAR2, -- default FND_API.G_FALSE,
		  p_commit	    		IN  VARCHAR2, -- default FND_API.G_FALSE,
		  p_validation_level	IN  NUMBER,	-- default	FND_API.G_VALID_LEVEL_FULL,
     	  x_return_status		OUT	NOCOPY VARCHAR2,
		  x_msg_count			OUT	NOCOPY NUMBER,
		  x_msg_data			OUT	NOCOPY VARCHAR2,
		  x_from_ap_id IN NUMBER,
		  x_to_ap_id IN NUMBER
		  );

procedure insert_ap_step(
                            p_api_version_number         IN   NUMBER,
                            p_init_msg_list              IN   VARCHAR2     := G_FALSE,
                            p_commit                     IN   VARCHAR2     := G_FALSE,
                            p_validation_level           IN   NUMBER       := G_VALID_LEVEL_FULL,
                            p_samplesize  		    	in number,
   			 				 p_audit_procedure_id   	in number,
							 p_seqnum			    	in varchar2,
							 p_requestor_id		    	in number,
							 p_name				    	in varchar2,
							 p_description		    	in varchar2,
							 p_audit_procedure_rev_id	in number,
                             p_user_id                  in number,
                             x_return_status              OUT  NOCOPY VARCHAR2,
                             x_msg_count                  OUT  NOCOPY NUMBER,
                             x_msg_data                   OUT  NOCOPY VARCHAR2);

procedure insert_ap_control_assoc(
                            p_api_version_number         IN   NUMBER,
                            p_init_msg_list              IN   VARCHAR2     := G_FALSE,
                            p_commit                     IN   VARCHAR2     := G_FALSE,
                            p_validation_level           IN   NUMBER       := G_VALID_LEVEL_FULL,
                            p_control_id  		    	in number,
   			 				 p_audit_procedure_id   	in number,
                             p_des_eff                  in varchar2,
                             p_op_eff                   in varchar2,
                             p_approval_date            in date,
                             p_user_id                  in number,
                             x_return_status              OUT  NOCOPY VARCHAR2,
                             x_msg_count                  OUT  NOCOPY NUMBER,
                             x_msg_data                   OUT  NOCOPY VARCHAR2);

procedure copy_ext_attr(
                            p_api_version_number         IN   NUMBER,
                            p_init_msg_list              IN   VARCHAR2     := G_FALSE,
                            p_commit                     IN   VARCHAR2     := G_FALSE,
                            p_validation_level           IN   NUMBER       := G_VALID_LEVEL_FULL,
   			 				p_from_audit_procedure_id   	in number,
   			 				p_to_audit_procedure_id   	in number,
                            x_return_status              OUT  NOCOPY VARCHAR2,
                            x_msg_count                  OUT  NOCOPY NUMBER,
                            x_msg_data                   OUT  NOCOPY VARCHAR2);
procedure revise_ap_if_necessary(
                            p_api_version_number         IN   NUMBER,
                            p_init_msg_list              IN   VARCHAR2     := G_FALSE,
                            p_commit                     IN   VARCHAR2     := G_FALSE,
                            p_validation_level           IN   NUMBER       := G_VALID_LEVEL_FULL,
                            p_audit_procedure_id        IN  NUMBER,
                            x_return_status              OUT  NOCOPY VARCHAR2,
                            x_msg_count                  OUT  NOCOPY NUMBER,
                            x_msg_data                   OUT  NOCOPY VARCHAR2);
-- ----------------------------------------------------------------------
END AMW_AUDIT_PROCEDURES_PVT;


 

/
