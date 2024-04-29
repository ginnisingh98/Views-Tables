--------------------------------------------------------
--  DDL for Package AHL_PRD_WORKORDER_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_PRD_WORKORDER_CUHK" AUTHID CURRENT_USER AS
/*$Header: AHLCPRJS.pls 120.0.12010000.1 2009/01/12 23:32:49 sikumar noship $*/

        ------------------------
        -- Declare Procedures --
        ------------------------
        --  Start of Comments  --
        --
        --  Procedure name      : CREATE_JOB_PRE
        --  Type                : Public
        --  Function            : Provide User Hooks for the customer to add validations before CREATE_JOB function call
        --  Pre-reqs            :
        --
        --  Standard IN  Parameters :
        --
        --  Standard OUT Parameters :
        --      x_return_status                 OUT     VARCHAR2              Required
        --      x_msg_count                     OUT     NUMBER                Required
        --      x_msg_data                      OUT     VARCHAR2              Required
        --
        --  CREATE_JOB_PRE Parameters :
        --      		p_prd_workorder_rec					 IN AHL_PRD_WORKORDER_PVT.prd_workorder_rec  Required
        --
        --  Version :
        --      Initial Version   1.0
        --
        --  End of Comments  --

 PROCEDURE CREATE_JOB_PRE
 (
		p_prd_workorder_rec					 IN AHL_PRD_WORKORDER_PVT.prd_workorder_rec,
	  x_return_status                OUT NOCOPY VARCHAR2 ,
	  x_msg_count                    OUT NOCOPY NUMBER  ,
	  x_msg_data                     OUT NOCOPY VARCHAR2
	);

				--  Start of Comments  --
        --
        --  Procedure name      : CREATE_JOB_POST
        --  Type                : Public
        --  Function            : Provide User Hooks for the customer to add validations after CREATE_JOB function call
        --  Pre-reqs            :
        --
        --  Standard IN  Parameters :
        --
        --  Standard OUT Parameters :
        --      x_return_status                 OUT     VARCHAR2              Required
        --      x_msg_count                     OUT     NUMBER                Required
        --      x_msg_data                      OUT     VARCHAR2              Required
        --
        --  CREATE_JOB_POST Parameters :
        --      	 p_prd_workorder_rec					IN  AHL_PRD_WORKORDER_PVT.prd_workorder_rec						 Required
				--				 p_operation_tbl							IN  AHL_PRD_OPERATIONS_PVT.prd_operation_tbl								Required
				--			   p_resource_tbl								IN  AHL_PP_RESRC_REQUIRE_PVT.resrc_require_tbl_type					Required
				--			    p_material_tbl							IN  AHL_PP_MATERIALS_PVT.req_material_tbl_type  Required		Required
        --
        --  Version :
        --      Initial Version   1.0
        --
        --  End of Comments  --

 PROCEDURE CREATE_JOB_POST
 (
	 p_prd_workorder_rec					IN  AHL_PRD_WORKORDER_PVT.prd_workorder_rec,
	 p_operation_tbl								IN  AHL_PRD_OPERATIONS_PVT.prd_operation_tbl,
	 p_resource_tbl								  IN  AHL_PP_RESRC_REQUIRE_PVT.resrc_require_tbl_type,
	 p_material_tbl							  	IN  AHL_PP_MATERIALS_PVT.req_material_tbl_type,
	 x_return_status                OUT NOCOPY VARCHAR2 ,
	 x_msg_count                    OUT NOCOPY NUMBER  ,
	 x_msg_data                     OUT NOCOPY VARCHAR2
	 );

				--  Start of Comments  --
        --
        --  Procedure name      : UPDATE_JOB_PRE
        --  Type                : Public
        --  Function            : Provide User Hooks for the customer to add validations before UPDATE_JOB_PRE function call
        --  Pre-reqs            :
        --
        --  Standard IN  Parameters :
        --
        --  Standard OUT Parameters :
        --      x_return_status                 OUT     VARCHAR2              Required
        --      x_msg_count                     OUT     NUMBER                Required
        --      x_msg_data                      OUT     VARCHAR2              Required
        --
        --  UPDATE_JOB_PRE Parameters :
        --       p_prd_workorder_rec				  	IN  AHL_PRD_WORKORDER_PVT.prd_workorder_rec	Required
				--			 p_prd_workoper_tbl					  	IN  AHL_PRD_WORKORDER_PVT.prd_workoper_tbl  Required
        --
        --  Version :
        --      Initial Version   1.0
        --
        --  End of Comments  --

 PROCEDURE  UPDATE_JOB_PRE
 (
 p_prd_workorder_rec				  	IN  AHL_PRD_WORKORDER_PVT.prd_workorder_rec,
 p_prd_workoper_tbl					  	IN  AHL_PRD_WORKORDER_PVT.prd_workoper_tbl,
 x_return_status                OUT NOCOPY VARCHAR2,
 x_msg_count                    OUT NOCOPY NUMBER,
 x_msg_data                     OUT NOCOPY VARCHAR2
 );

				--  Start of Comments  --
        --
        --  Procedure name      : UPDATE_JOB_PRE
        --  Type                : Public
        --  Function            : Provide User Hooks for the customer to add validations after UPDATE_JOB_PRE function call
        --  Pre-reqs            :
        --
        --  Standard IN  Parameters :
        --
        --  Standard OUT Parameters :
        --      x_return_status                 OUT     VARCHAR2              Required
        --      x_msg_count                     OUT     NUMBER                Required
        --      x_msg_data                      OUT     VARCHAR2              Required
        --
        --  UPDATE_JOB_PRE Parameters :
        --       p_prd_workorder_rec				  	IN  AHL_PRD_WORKORDER_PVT.prd_workorder_rec	Required
				--			 p_prd_workoper_tbl					  	IN  AHL_PRD_WORKORDER_PVT.prd_workoper_tbl  Required
        --
        --  Version :
        --      Initial Version   1.0
        --
        --  End of Comments  --

 PROCEDURE UPDATE_JOB_POST
 (
 p_prd_workorder_rec				  	IN  AHL_PRD_WORKORDER_PVT.prd_workorder_rec,
 p_prd_workoper_tbl					  	IN  AHL_PRD_WORKORDER_PVT.prd_workoper_tbl,
 x_return_status                OUT NOCOPY VARCHAR2,
 x_msg_count                    OUT NOCOPY NUMBER,
 x_msg_data                     OUT NOCOPY VARCHAR2
 );


END AHL_PRD_WORKORDER_CUHK;

/
