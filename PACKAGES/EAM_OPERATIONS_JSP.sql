--------------------------------------------------------
--  DDL for Package EAM_OPERATIONS_JSP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_OPERATIONS_JSP" AUTHID CURRENT_USER AS
/* $Header: EAMOPSJS.pls 120.1.12010000.2 2011/06/29 10:39:35 vpasupur ship $
   $Author: vpasupur $ */

  -- Author  : YULIN
  -- Created : 7/23/01 2:58:14 PM
  -- Purpose : API for handover in JSP pages

   -- Standard who
   g_last_updated_by         NUMBER(15) := FND_GLOBAL.USER_ID;
   g_created_by              NUMBER(15) := FND_GLOBAL.USER_ID;
   g_last_update_login       NUMBER(15) := FND_GLOBAL.LOGIN_ID;
   g_request_id              NUMBER(15) := FND_GLOBAL.CONC_REQUEST_ID;
   g_program_application_id  NUMBER(15) := FND_GLOBAL.PROG_APPL_ID;
   g_program_id              NUMBER(15) := FND_GLOBAL.CONC_PROGRAM_ID;

-------------------------------------------------------------------------
-- Procedure to check whether the handover operation is being
-- conducted properly or not , i.e. all previous ops are completed
-- Bug fix # 2113203 - baroy
-------------------------------------------------------------------------
  procedure handover_validate
  ( p_wip_entity_id               IN NUMBER,
    p_operation_sequence_number   IN NUMBER,
    p_organization_id             IN NUMBER,
    x_return_stat                 OUT NOCOPY NUMBER
  );


-- removed procedure charge_resource_validate

-------------------------------------------------------------------------
-- Procedure to check whether the assign employee operation is being
-- conducted on a completed or uncompleted operation
-- Bug fix # 2130980 - baroy
-------------------------------------------------------------------------
  procedure assign_employee_validate
  ( p_wip_entity_id               IN NUMBER,
    p_operation_sequence_number   IN NUMBER,
    p_organization_id             IN NUMBER,
    x_return_stat                 OUT NOCOPY NUMBER
  );



-------------------------------------------------------------------------
-- Procedure to check whether the complete/uncomplete operation is being
-- conducted after taking into account the operation dependancies or not
-- Bug fix # 2130980 - baroy
-------------------------------------------------------------------------
  procedure complete_uncomplete_validate
  ( p_wip_entity_id               IN NUMBER,
    p_operation_sequence_number   IN NUMBER,
    p_organization_id             IN NUMBER,
    x_return_stat                 OUT NOCOPY NUMBER
  );


--------------------------------------------------------------------------
-- A wrapper to the operation completion logic, cache the return status
-- and convert it the the message that can be accepted by JSP pages
--------------------------------------------------------------------------
  procedure complete_operation
  (  p_api_version                 IN    NUMBER        := 1.0
    ,p_init_msg_list               IN    VARCHAR2      := FND_API.G_FALSE
    ,p_commit                      IN    VARCHAR2      := FND_API.G_FALSE
    ,p_validate_only               IN    VARCHAR2      := FND_API.G_TRUE
    ,p_record_version_number       IN    NUMBER        := NULL
    ,x_return_status               OUT NOCOPY   VARCHAR2
    ,x_msg_count                   OUT NOCOPY   NUMBER
    ,x_msg_data                    OUT NOCOPY   VARCHAR2
    ,p_wip_entity_id               IN    NUMBER        -- data
    ,p_operation_seq_num           IN    NUMBER
    ,p_actual_start_date           IN    DATE
    ,p_actual_end_date             IN    DATE
    ,p_actual_duration             IN    NUMBER
    ,p_transaction_date            IN    DATE
    ,p_transaction_type            IN    NUMBER
    ,p_shutdown_start_date         IN    DATE
    ,p_shutdown_end_date           IN    DATE
    ,p_reconciliation_code         IN    VARCHAR2
    ,p_stored_last_update_date     IN    DATE  -- old update date, for locking only
    ,p_qa_collection_id            IN    NUMBER DEFAULT NULL
    ,p_vendor_id             IN  NUMBER      := NULL
    ,p_vendor_site_id        IN  NUMBER      := NULL
	,p_vendor_contact_id     IN  NUMBER      := NULL
	,p_reason_id             IN  NUMBER      := NULL
	,p_reference             IN  VARCHAR2    := NULL
	,p_attribute_category	IN	VARCHAR2    := NULL
	,p_attribute1			IN	VARCHAR2	:= NULL
	,p_attribute2			IN	VARCHAR2	:= NULL
	,p_attribute3			IN	VARCHAR2	:= NULL
	,p_attribute4			IN	VARCHAR2	:= NULL
	,p_attribute5			IN	VARCHAR2	:= NULL
	,p_attribute6			IN	VARCHAR2	:= NULL
	,p_attribute7			IN	VARCHAR2	:= NULL
	,p_attribute8			IN	VARCHAR2	:= NULL
	,p_attribute9			IN	VARCHAR2	:= NULL
	,p_attribute10			IN	VARCHAR2	:= NULL
	,p_attribute11			IN	VARCHAR2	:= NULL
	,p_attribute12			IN	VARCHAR2	:= NULL
	,p_attribute13			IN	VARCHAR2	:= NULL
	,p_attribute14			IN	VARCHAR2	:= NULL
	,p_attribute15			IN	VARCHAR2	:= NULL
  );

------------------------------------------------------------------------------------
-- performing operation handover for jsp pages
-- use the column last_update_date for optimistic locking
-- Fix for Bug 2205400- Populate Actual End Date and Duration during handover
-- Changed the call to the API .
------------------------------------------------------------------------------------
  procedure operation_handover
  (  p_api_version                 IN    NUMBER        := 1.0
    ,p_init_msg_list               IN    VARCHAR2      := FND_API.G_FALSE
    ,p_commit                      IN    VARCHAR2      := FND_API.G_FALSE
    ,p_validate_only               IN    VARCHAR2      := FND_API.G_TRUE
    ,p_record_version_number       IN    NUMBER        := NULL
    ,x_return_status               OUT NOCOPY   VARCHAR2
    ,x_msg_count                   OUT NOCOPY   NUMBER
    ,x_msg_data                    OUT NOCOPY   VARCHAR2
    ,p_wip_entity_id               IN    NUMBER        -- data
    ,p_old_op_seq_num              IN    NUMBER
    ,p_new_op_seq_num              IN    NUMBER
    ,p_description                 IN    VARCHAR2
    ,p_assigned_department         IN    VARCHAR2
    ,p_start_date                  IN    DATE
    ,p_completion_date             IN    DATE
    ,p_shutdown_type               IN    NUMBER  -- old update date, for locking only
    ,p_stored_last_update_date     IN    DATE
    ,p_duration                    IN    NUMBER
    ,p_reconciliation_value        IN    VARCHAR2
  );

-----------------------------------------------------------------------------------------
-- copy the operation network data for the new operation
-----------------------------------------------------------------------------------------
 procedure copy_operation_network
   (
      p_wip_entity_id               IN    NUMBER        -- data
     ,p_old_op_seq_num              IN    NUMBER
     ,p_new_op_seq_num              IN    NUMBER
     ,p_operation_start_date        IN    DATE
     ,p_operation_completion_date   IN    DATE
     ,x_return_status               OUT NOCOPY   VARCHAR2
  ) ;

---------------------------------------------------------------------------------------
-- handover the selected resources of one operation
---------------------------------------------------------------------------------------
  procedure operation_handover_resource
  (  p_api_version                 IN    NUMBER        := 1.0
    ,p_init_msg_list               IN    VARCHAR2      := FND_API.G_FALSE
    ,p_commit                      IN    VARCHAR2      := FND_API.G_FALSE
    ,p_validate_only               IN    VARCHAR2      := FND_API.G_TRUE
    ,p_record_version_number       IN    NUMBER        := NULL
    ,x_return_status               OUT NOCOPY   VARCHAR2
    ,x_msg_count                   OUT NOCOPY   NUMBER
    ,x_msg_data                    OUT NOCOPY   VARCHAR2
    ,p_wip_entity_id               IN    NUMBER        -- data
    ,p_old_op_seq_num              IN    NUMBER
    ,p_resource_seq_num            IN    NUMBER
    ,p_new_op_seq_num              IN    NUMBER
    ,p_department                  IN    VARCHAR2
    ,p_start_date                  IN    DATE
    ,p_duration                    IN    NUMBER
    ,p_new_op_start_date           IN    DATE
    ,p_new_op_end_date             IN    DATE
    ,p_employee_id		   IN    NUMBER
    ,p_complete_rollback	   IN	 VARCHAR2      := FND_API.G_FALSE -- Added parameter to handle rollback for Mobile Handover Page.
  );

  -------------------------------------------------------------------------
   -- Procedure to validate insertion of Resource to an Operation in JSP
   -- Used in Resources Page
   -- Author : amondal
   -------------------------------------------------------------------------
   procedure validate_insert (p_wip_entity_id      IN       NUMBER
                              ,p_operation_seq_num  IN       NUMBER
                              ,p_department_code    IN       VARCHAR2
                              ,p_organization_id    IN       NUMBER
                              ,p_resource_code      IN       VARCHAR2
                              ,p_uom_code           IN       VARCHAR2
                              ,p_usage_rate         IN       NUMBER
                              ,p_assigned_units     IN       NUMBER
                              ,p_start_date         IN       DATE
                              ,p_end_date           IN       DATE
                              ,p_activity           IN       VARCHAR2
                              ,x_uom_status         OUT NOCOPY      NUMBER
                              ,x_operation_status   OUT NOCOPY      NUMBER
                              ,x_department_status  OUT NOCOPY      NUMBER
                              ,x_res_status         OUT NOCOPY      NUMBER
                              ,x_usage_status       OUT NOCOPY      NUMBER
                              ,x_assigned_units     OUT NOCOPY      NUMBER
                              ,x_assigned           OUT NOCOPY      NUMBER
                              ,x_dates              OUT NOCOPY      NUMBER
                           ,x_activity           OUT NOCOPY      NUMBER) ;

    --------------------------------------------------------------------------
    -- Procedure to add a Resource to an Operation
    -- Used in Resources Page
    -- Author : amondal
    --------------------------------------------------------------------------
    procedure insert_into_wor(  p_api_version        IN       NUMBER
                    ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
                    ,p_commit             IN       VARCHAR2 := fnd_api.g_false
                    ,p_validation_level   IN       NUMBER   := fnd_api.g_valid_level_full
                    ,p_wip_entity_id      IN       NUMBER
                    ,p_operation_seq_num  IN       NUMBER
                    ,p_organization_id    IN       NUMBER
                    ,p_usage_rate   IN       NUMBER
                    ,p_resource_code      IN       VARCHAR2
                    ,p_uom_code           IN       VARCHAR2
    		,p_resource_seq_num   IN NUMBER
                    ,p_dept_code          IN VARCHAR2
    		,p_assigned_units     IN NUMBER
    		,p_basis              IN NUMBER
                    ,p_scheduled_flag     IN NUMBER
    		,p_charge_type        IN NUMBER
    		,p_schedule_sequence  IN NUMBER
    		,p_std_rate           IN VARCHAR2
    		,p_start_date         IN DATE
    		,p_end_date           IN DATE
    		,p_activity           IN VARCHAR2
		,p_mod		      IN VARCHAR2 DEFAULT NULL
    		,x_update_status      OUT NOCOPY      NUMBER
                    ,x_return_status      OUT NOCOPY      VARCHAR2
                    ,x_msg_count          OUT NOCOPY      NUMBER
                ,x_msg_data           OUT NOCOPY      VARCHAR2);

   ----------------------------------------------------------------------------
   -- Procedure to validate materials added to an operation
   -- Used in Add Materials Page
   -- Author : amondal
   ----------------------------------------------------------------------------
   PROCEDURE material_validate (
               p_organization_id      IN       NUMBER
              ,p_wip_entity_id        IN       NUMBER
              ,p_description          IN       VARCHAR2
              ,p_uom                  IN       VARCHAR2
              ,p_concatenated_segments IN      VARCHAR2
     	     ,p_operation_seq_num     IN      VARCHAR2
     	     ,p_department_code       IN      VARCHAR2
     	     ,p_supply                IN      VARCHAR2
              ,p_subinventory_code     IN      VARCHAR2
              ,p_locator               IN      VARCHAR2
     	     ,x_invalid_asset		  OUT NOCOPY     NUMBER
     	     ,x_invalid_description     OUT NOCOPY     NUMBER
     	     ,x_invalid_uom             OUT NOCOPY     NUMBER
     	     ,x_invalid_subinventory    OUT NOCOPY     NUMBER
       	     ,x_invalid_locator         OUT NOCOPY     NUMBER
     	     ,x_invalid_department      OUT NOCOPY     NUMBER
     	     ,x_invalid_operation       OUT NOCOPY     NUMBER
     	     ,x_invalid_supply          OUT NOCOPY     NUMBER
           );

    ---------------------------------------------------------------------------
    -- Procedure to add materials to an operation
    -- Used in Add Materials Page
    -- Author : amondal
    ---------------------------------------------------------------------------
    PROCEDURE insert_into_wro(
                       p_api_version        IN       NUMBER
                      ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
                      ,p_commit             IN       VARCHAR2 := fnd_api.g_false
                      ,p_validation_level   IN       NUMBER   := fnd_api.g_valid_level_full
                      ,p_wip_entity_id      IN       NUMBER
                      ,p_organization_id    IN       NUMBER
      		,p_concatenated_segments  IN   VARCHAR2
      	 	,p_description            IN   VARCHAR2
                      ,p_operation_seq_num    IN     NUMBER
       		,p_supply             	IN     VARCHAR2
      		,p_required_date        IN     DATE
      		,p_quantity            IN      NUMBER
      		,p_comments            IN      VARCHAR2
      		,p_supply_subinventory  IN     VARCHAR2
      		,p_locator 		IN     VARCHAR2
      		,p_mrp_net_flag         IN     VARCHAR2
      		,p_material_release     IN     VARCHAR2
      		,x_invalid_update_operation  OUT NOCOPY  NUMBER
      		,x_invalid_update_department OUT NOCOPY  NUMBER
      		,x_invalid_update_description OUT NOCOPY NUMBER
                              ,x_return_status      OUT NOCOPY      VARCHAR2
                      ,x_msg_count          OUT NOCOPY      NUMBER
                      ,x_msg_data           OUT NOCOPY      VARCHAR2
                  ,x_update_status        OUT NOCOPY   NUMBER
				  ,p_supply_code          IN     NUMBER :=NULL
				  ,p_one_step_issue       IN   varchar2:=fnd_api.g_false /*To identify the call from one step issue page */
				  ,p_released_quantity    IN  NUMBER := NULL --added for bug 3572280
				  );

     --Start of bug 12631479
	 --This procedure is not called in R12.This was added to maintain the dual check between R12->R12.1
          PROCEDURE insert_into_wro(
                       p_api_version        IN       NUMBER
                      ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
                      ,p_commit             IN       VARCHAR2 := fnd_api.g_false
                      ,p_validation_level   IN       NUMBER   := fnd_api.g_valid_level_full
                      ,p_wip_entity_id      IN       NUMBER
                      ,p_organization_id    IN       NUMBER
      		,p_concatenated_segments  IN   VARCHAR2
      	 	,p_description            IN   VARCHAR2
                      ,p_operation_seq_num    IN     NUMBER
       		,p_supply             	IN     VARCHAR2
      		,p_required_date        IN     DATE
      		,p_quantity            IN      NUMBER
      		,p_comments            IN      VARCHAR2
      		,p_supply_subinventory  IN     VARCHAR2
      		,p_locator 		IN     VARCHAR2
      		,p_mrp_net_flag         IN     VARCHAR2
      		,p_material_release     IN     VARCHAR2
      		,x_invalid_update_operation  OUT NOCOPY  NUMBER
      		,x_invalid_update_department OUT NOCOPY  NUMBER
      		,x_invalid_update_description OUT NOCOPY NUMBER
                              ,x_return_status      OUT NOCOPY      VARCHAR2
                      ,x_msg_count          OUT NOCOPY      NUMBER
                      ,x_msg_data           OUT NOCOPY      VARCHAR2
                  ,x_update_status        OUT NOCOPY   NUMBER
				  ,p_supply_code          IN     NUMBER :=NULL
				  ,p_one_step_issue       IN   varchar2:=fnd_api.g_false /*To identify the call from one step issue page */
				  ,p_released_quantity    IN  NUMBER := NULL --added for bug 3572280
          ,p_attribute_category   IN  VARCHAR2
          ,p_attribute1 IN VARCHAR2
          ,p_attribute2 IN VARCHAR2
          ,p_attribute3 IN VARCHAR2
          ,p_attribute4 IN VARCHAR2
          ,p_attribute5 IN VARCHAR2
          ,p_attribute6 IN VARCHAR2
          ,p_attribute7 IN VARCHAR2
          ,p_attribute8 IN VARCHAR2
          ,p_attribute9 IN VARCHAR2
          ,p_attribute10 IN VARCHAR2
          ,p_attribute11 IN VARCHAR2
          ,p_attribute12 IN VARCHAR2
          ,p_attribute13 IN VARCHAR2
          ,p_attribute14 IN VARCHAR2
          ,p_attribute15 IN VARCHAR2

				  );
       --End of bug 12631479
     ----------------------------------------------------------------------
     -- Procedure tp delete materials from an operation
     -- Used in Add Materials Page
     -- Author : amondal
     ----------------------------------------------------------------------
     PROCEDURE delete_resources (
                 p_api_version        IN       NUMBER
       	 ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
       	 ,p_commit             IN       VARCHAR2 := fnd_api.g_false
                ,p_validation_level   IN       NUMBER   := fnd_api.g_valid_level_full
                ,p_wip_entity_id      IN       NUMBER
                ,p_operation_seq_num  IN       NUMBER
                ,p_resource_seq_num   IN       NUMBER
                ,x_return_status      OUT NOCOPY      VARCHAR2
                ,x_msg_count          OUT NOCOPY      NUMBER
           ,x_msg_data           OUT NOCOPY      VARCHAR2);

    --------------------------------------------------------------------------
    -- Procedure to add an operation to a work order
    -- Used in Operations Page
    -- Author : rethakur
    --------------------------------------------------------------------------
    procedure insert_into_wo (  p_wip_entity_id		 IN       NUMBER
                           ,p_operation_seq_num		 IN       NUMBER
                           ,p_standard_operation_id	 IN	  NUMBER
			   ,p_organization_id		 IN       NUMBER
                           ,p_description		 IN       VARCHAR2
                           ,p_department_id	         IN       NUMBER
                           ,p_shutdown_type		 IN       VARCHAR2
			   ,p_first_unit_start_date	 IN	  VARCHAR2
			   ,p_last_unit_completion_date  IN       VARCHAR2
			   ,p_duration			 IN       NUMBER
			   ,p_long_description           IN       VARCHAR2 := null
                           ,x_return_status	         OUT NOCOPY      NUMBER
			   ,x_msg_count                    OUT NOCOPY      NUMBER    );

    --------------------------------------------------------------------------
    -- Procedure to validate standard operation
    -- Used in Operations Page
    -- Author : rethakur
    --------------------------------------------------------------------------
   procedure validate_std_operation ( p_organization_id		 IN       NUMBER
				    ,p_operation_code		 IN       VARCHAR2
				    ,x_standard_operation_id	 OUT NOCOPY      NUMBER
				    ,x_department_id		 OUT NOCOPY      NUMBER
				    ,x_shutdown_type             OUT NOCOPY      VARCHAR2
				    ,x_return_status	         OUT NOCOPY      NUMBER);

    --------------------------------------------------------------------------
    -- Procedure to validate shutdown type
    -- Used in Operations Page
    -- Author : rethakur
    --------------------------------------------------------------------------
   procedure validate_shutdown_type (p_meaning                   IN       VARCHAR2
				    ,x_lookup_code		 OUT NOCOPY      NUMBER
				    ,x_return_status	         OUT NOCOPY      NUMBER);

    --------------------------------------------------------------------------
    -- Procedure to validate department
    -- Used in Operations Page
    -- Author : rethakur
    --------------------------------------------------------------------------
   procedure validate_dept (p_wip_entity_id		 IN       NUMBER
                           ,p_operation_seq_num		 IN       NUMBER
			   ,p_organization_id		 IN       NUMBER
                           ,p_department_code	         IN       VARCHAR2
			   ,x_department_id		 OUT NOCOPY      NUMBER
                           ,x_return_status	         OUT NOCOPY      NUMBER);

    --------------------------------------------------------------------------
    -- Procedure to update operations in wip_operations
    -- Used in Operations Page
    -- Author : rethakur
    --------------------------------------------------------------------------
 procedure update_wo ( p_wip_entity_id		   IN       NUMBER
                     ,p_operation_seq_num	   IN       NUMBER
		     ,p_organization_id		   IN       NUMBER
                     ,p_description		   IN       VARCHAR2
                     ,p_shutdown_type		   IN       VARCHAR2
		     ,p_first_unit_start_date	   IN	    VARCHAR2
	             ,p_last_unit_completion_date  IN       VARCHAR2
		     ,p_duration		   IN       NUMBER
		     ,p_long_description           IN       VARCHAR2 := null
		     ,x_return_status              OUT NOCOPY      NUMBER
		     ,x_msg_count                  OUT NOCOPY NUMBER  ) ;

/*--------------------------------------------------------------------------
-- Validation API for new link between operaions in
-- Dependency definitions
--------------------------------------------------------------------------*/
    PROCEDURE validate_new_link(
                                          p_from_operation IN NUMBER,
                                          p_to_operation     IN NUMBER,
                                          p_dep_direction    IN NUMBER,
                                          p_wip_entity_id    IN NUMBER,
                                          p_sche_start_date   IN DATE,
										  p_sche_end_date     IN DATE,
                                          x_error_flag      OUT NOCOPY VARCHAR2,
                                          x_error_mssg      OUT NOCOPY VARCHAR2 ) ;

/*--------------------------------------------------------------------------
-- API for creating new link between operaions in
-- Dependency definitions
--------------------------------------------------------------------------*/
    PROCEDURE create_new_link(p_from_operation IN NUMBER,
                                          p_to_operation     IN NUMBER,
                                          p_dep_direction    IN NUMBER,
                                          p_wip_entity_id    IN NUMBER,
                                          p_organization_id  IN NUMBER,
                                          p_user_id            IN NUMBER,
										  p_sche_start_date   IN DATE,
										  p_sche_end_date     IN DATE,
                                          x_error_flag  OUT NOCOPY VARCHAR2,
                                          x_error_mssg  OUT NOCOPY VARCHAR2 );



/*--------------------------------------------------------------------------
-- API for creating new link between operaions in
-- Dependency definitions
--------------------------------------------------------------------------*/
    PROCEDURE delete_link(p_from_operation IN NUMBER,
                                          p_to_operation     IN NUMBER,
                                          p_dep_direction    IN NUMBER,
                                          p_wip_entity_id    IN NUMBER,
                                          p_organization_id  IN NUMBER,
                                          p_user_id            IN NUMBER,
                                          x_error_flag  OUT NOCOPY VARCHAR2,
                                          x_error_mssg  OUT NOCOPY VARCHAR2 );

/*-------------------------------------------------------------------------
-- API for calling the scheduler (finite or infinite) when the relevant
-- fields in operations or resources are changed.
-------------------------------------------------------------------------*/
    PROCEDURE schedule_workorders(p_organization_id  IN NUMBER,
                                  p_wip_entity_id    IN NUMBER);

/*-------------------------------------------------------------------------
-- API for geting the operation_seq_num and the department_code
-- for the wip_entity_id.
-------------------------------------------------------------------------*/
    PROCEDURE count_op_seq_num(p_organization_id  IN NUMBER,
                               p_wip_entity_id    IN NUMBER,
                               op_seq_num        OUT NOCOPY   NUMBER,
                               op_dept_code      OUT NOCOPY   VARCHAR2,
			       op_count          OUT NOCOPY   NUMBER,
                               l_return_status   OUT NOCOPY   VARCHAR2,
                               l_msg_data        OUT NOCOPY   VARCHAR2,
                               l_msg_count       OUT NOCOPY   NUMBER);
/*-------------------------------------------------------------------------
-- API for geting the operation_seq_num,the department_code and start/end dates
-- of operation for a given wip entity id. Added for bug#3544893
-------------------------------------------------------------------------*/
PROCEDURE default_operation (p_organization_id    IN NUMBER,
                             p_wip_entity_id      IN NUMBER,
                             x_op_seq_num         OUT NOCOPY   NUMBER,
			     x_op_dept_code	  OUT NOCOPY   VARCHAR2,
		             x_op_count           OUT NOCOPY   NUMBER,
			     x_op_start_date      OUT NOCOPY DATE,
			     x_op_end_date        OUT NOCOPY DATE,
                             x_return_status      OUT NOCOPY   VARCHAR2,
                             x_msg_data           OUT NOCOPY   VARCHAR2,
                             x_msg_count          OUT NOCOPY   NUMBER);


/* ------------------------------------------------------------------------
   API for checking whether the resources associated with a work order and
   an operation are available in the department chosen.
 --------------------------------------------------------------------------*/

  PROCEDURE handover_department_validate(p_wip_entity_id               IN NUMBER,
				         p_operation_seq_num	       IN NUMBER,
				         p_department                  IN VARCHAR2,
					 p_organization_id	       IN NUMBER,
					 p_resource_code               IN VARCHAR2,
				         x_return_status        OUT NOCOPY NUMBER);


/* ------------------------------------------------------------------------
   API for checking whether the operation for a particular work order can be deleted
 --------------------------------------------------------------------------*/


   PROCEDURE check_op_deletion(p_wip_entity_id               IN NUMBER,
                               p_operation_seq_num	        IN NUMBER,
                               x_return_status               OUT NOCOPY NUMBER) ;


/* ------------------------------------------------------------------------
   API for deeting operation from self service side
 --------------------------------------------------------------------------*/

   PROCEDURE delete_operation (
      p_api_version                  IN    NUMBER         := 1.0
      ,p_init_msg_list               IN    VARCHAR2    := FND_API.G_TRUE
      ,p_commit                      IN    VARCHAR2  := FND_API.G_FALSE
      ,p_organization_id             IN    NUMBER
      ,p_wip_entity_id   	     IN	   NUMBER
      ,p_operation_seq_num	     IN	   NUMBER
      ,p_department_id  	     IN	   NUMBER
      ,x_return_status               OUT NOCOPY   VARCHAR2
      ,x_msg_count                   OUT NOCOPY   NUMBER
      ,x_msg_data                    OUT NOCOPY   VARCHAR2
     );

/*---------------------------------------------------------------------------
   API for updating/deleting material used in one step issue page
  -----------------------------------------------------------------------------*/
  PROCEDURE update_wro
            (
	       p_commit            IN  VARCHAR2 := FND_API.G_FALSE
	      ,p_organization_id             IN    NUMBER
	      ,p_wip_entity_id   	     IN	   NUMBER
	      ,p_operation_seq_num	     IN	   NUMBER
	      ,p_inventory_item_id          IN    NUMBER
	      ,p_update                     IN  NUMBER
	      ,p_required_qty               IN  NUMBER
	      ,x_return_status               OUT NOCOPY   VARCHAR2
	      ,x_msg_count                   OUT NOCOPY   NUMBER
	      ,x_msg_data                    OUT NOCOPY   VARCHAR2
	     );


/*---------------------------------------------------------------------------
   API for deleting instances . Call to WO API incorporated.
  -----------------------------------------------------------------------------*/

   PROCEDURE delete_instance (
            p_api_version        IN       NUMBER
  	   ,p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false
  	   ,p_commit             IN       VARCHAR2 := fnd_api.g_false
           ,p_validation_level   IN       NUMBER   := fnd_api.g_valid_level_full
           ,p_wip_entity_id      IN       NUMBER
           ,p_organization_id      IN       NUMBER
           ,p_operation_seq_num  IN       NUMBER
           ,p_resource_seq_num   IN       NUMBER
           ,p_instance_id	   IN       NUMBER
           ,x_return_status      OUT NOCOPY      VARCHAR2
           ,x_msg_count          OUT NOCOPY      NUMBER
           ,x_msg_data           OUT NOCOPY      VARCHAR2)  ;

end EAM_OPERATIONS_JSP;

/
