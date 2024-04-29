--------------------------------------------------------
--  DDL for Package WSH_XC_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_XC_UTIL" AUTHID CURRENT_USER as
/* $Header: WSHXCUTS.pls 120.4.12010000.2 2009/02/09 12:04:22 skanduku ship $ */

-- --------------------------------------------------------------------------
-- Procedure:  Log_Exception
-- Description:  This procedure will create a new exception record or allow
--               update to an existing exception record. Update is allowed
--               only for the fields which are NULL in the Exception record.
--               The update function is mostly useful to add exception name to
--               an open exception or to add missing attributes.
-- BUG#: 1549665 hwahdani - added a new parameter p_request_id
-- BUG#: 1900149 HW added opm_parameters to log_excpetion
--               p_sublot_number, p_unit_of_measure2 and p_quantity2
-- BUG#: 1729516 Added BATCH_ID for P.Release Online Process in log_exception
-- --------------------------------------------------------------------------

PROCEDURE log_exception
          (p_api_version            IN     NUMBER,
           p_init_msg_list          IN     VARCHAR2  DEFAULT FND_API.G_FALSE,
           p_commit                 IN     VARCHAR2  DEFAULT FND_API.G_FALSE,
           p_validation_level       IN     NUMBER    DEFAULT FND_API.G_VALID_LEVEL_FULL,
           x_return_status         OUT NOCOPY      VARCHAR2,
           x_msg_count             OUT NOCOPY      NUMBER,
           x_msg_data              OUT NOCOPY      VARCHAR2,
           x_exception_id           IN OUT NOCOPY  NUMBER,

		 -- exception_location_id is a required field, assign it to
		 -- FND_API.G_MISS_NUM for insert, NULL for update
           p_exception_location_id  IN     NUMBER,

		 -- logged_at_location_id is a required field, assign it to
		 -- FND_API.G_MISS_NUM for insert, NULL for update
           p_logged_at_location_id  IN     NUMBER,

           p_logging_entity         IN     VARCHAR2 DEFAULT NULL,
           p_logging_entity_id      IN     NUMBER   DEFAULT NULL,
           p_exception_name         IN     VARCHAR2 DEFAULT NULL,
           p_message                IN     VARCHAR2 DEFAULT NULL,
           p_severity               IN     VARCHAR2 DEFAULT NULL,
           p_manually_logged        IN     VARCHAR2 DEFAULT NULL,
           p_exception_handling     IN     VARCHAR2 DEFAULT NULL,
           p_trip_id                IN     NUMBER   DEFAULT NULL,
           p_trip_name              IN     VARCHAR2 DEFAULT NULL,
           p_trip_stop_id           IN     NUMBER   DEFAULT NULL,
           p_delivery_id            IN     NUMBER   DEFAULT NULL,
           p_delivery_name          IN     VARCHAR2 DEFAULT NULL,
           p_delivery_detail_id     IN     NUMBER   DEFAULT NULL,
           p_delivery_assignment_id IN     NUMBER   DEFAULT NULL,
           p_container_name         IN     VARCHAR2 DEFAULT NULL,
           p_inventory_item_id      IN     NUMBER   DEFAULT NULL,
           p_lot_number             IN     VARCHAR2 DEFAULT NULL,
-- HW BUG#:1900149 OPM added p_sublot_number
-- HW OPMCONV. No need for sublot anymore
--         p_sublot_number          IN     VARCHAR2 DEFAULT NULL,
           p_revision               IN     VARCHAR2 DEFAULT NULL,
           p_serial_number          IN     VARCHAR2 DEFAULT NULL,
           p_unit_of_measure        IN     VARCHAR2 DEFAULT NULL,
           p_quantity               IN     NUMBER   DEFAULT NULL,
-- HW BUG#:1900149 OPM added unit_of_measure2 and quantity2
           p_unit_of_measure2       IN     VARCHAR2 DEFAULT NULL,
           p_quantity2              IN     NUMBER   DEFAULT NULL,
           p_subinventory           IN     VARCHAR2 DEFAULT NULL,
           p_locator_id             IN     NUMBER   DEFAULT NULL,
           p_arrival_date           IN     DATE     DEFAULT NULL,
           p_departure_date         IN     DATE     DEFAULT NULL,
           p_error_message          IN     VARCHAR2 DEFAULT NULL,
           p_attribute_category     IN     VARCHAR2 DEFAULT NULL,
           p_attribute1             IN     VARCHAR2 DEFAULT NULL,
           p_attribute2             IN     VARCHAR2 DEFAULT NULL,
           p_attribute3             IN     VARCHAR2 DEFAULT NULL,
           p_attribute4             IN     VARCHAR2 DEFAULT NULL,
           p_attribute5             IN     VARCHAR2 DEFAULT NULL,
           p_attribute6             IN     VARCHAR2 DEFAULT NULL,
           p_attribute7             IN     VARCHAR2 DEFAULT NULL,
           p_attribute8             IN     VARCHAR2 DEFAULT NULL,
           p_attribute9             IN     VARCHAR2 DEFAULT NULL,
           p_attribute10            IN     VARCHAR2 DEFAULT NULL,
           p_attribute11            IN     VARCHAR2 DEFAULT NULL,
           p_attribute12            IN     VARCHAR2 DEFAULT NULL,
           p_attribute13            IN     VARCHAR2 DEFAULT NULL,
           p_attribute14            IN     VARCHAR2 DEFAULT NULL,
           p_attribute15            IN     VARCHAR2 DEFAULT NULL,
           p_request_id             IN     NUMBER   DEFAULT NULL,
           p_batch_id               IN     NUMBER   DEFAULT NULL,
           p_creation_date          IN     DATE     DEFAULT NULL,
           p_created_by             IN     NUMBER   DEFAULT NULL,
           p_last_update_date       IN     DATE     DEFAULT NULL,
           p_last_updated_by        IN     NUMBER   DEFAULT NULL,
           p_last_update_login      IN     NUMBER   DEFAULT NULL,
           p_program_application_id IN     NUMBER   DEFAULT NULL,
           p_program_id             IN     NUMBER   DEFAULT NULL,
           p_program_update_date    IN     DATE     DEFAULT NULL,
           p_status                 IN     VARCHAR2 DEFAULT NULL,
           p_action                 IN     VARCHAR2 DEFAULT NULL
          );

-- --------------------------------------------------------------------------
--  Procedure: Change_ Status
--  Description:  If the p_old_status matches the current exception status,

-- --------------------------------------------------------------------------
--  Procedure: Change_ Status
--  Description:  If the p_old_status matches the current exception status,
--                this procedure will change the status in two ways:
--                1)if p_set_default_status = FND_API.G_TRUE (i.e. 'T'),
--                  then it sets the exception to default status
--                2)if p_set_default_status is missing, it sets the
--                  exception to x_new_status
--
-- --------------------------------------------------------------------------


PROCEDURE change_status
          (p_api_version            IN     NUMBER,
           p_init_msg_list          IN     VARCHAR2 DEFAULT FND_API.G_FALSE,
           p_commit                 IN     VARCHAR2 DEFAULT FND_API.G_FALSE,
           p_validation_level       IN     NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL,
           x_return_status         OUT NOCOPY      VARCHAR2,
           x_msg_count             OUT NOCOPY      NUMBER,
           x_msg_data              OUT NOCOPY      VARCHAR2,
           p_exception_id           IN     NUMBER,
           p_old_status             IN     VARCHAR2,
           p_set_default_status     IN     VARCHAR2 DEFAULT FND_API.G_FALSE,
           x_new_status             IN OUT NOCOPY  VARCHAR2
          );


-- ---------------------------------------------------------------------
-- procedure: insert_xc_def_form
-- description: called by the form to insert exception definition
--              This procedure should be called only by form WSHFXCDF.fmb,
--			 no one else should call this procedure.
-- ---------------------------------------------------------------------

procedure	insert_xc_def_form (
	x_exception_definition_id in out NOCOPY  NUMBER,
	p_exception_name		in VARCHAR2	DEFAULT null,
	p_description			in VARCHAR2   	DEFAULT NULL,
	p_exception_type		in VARCHAR2   	DEFAULT NULL,
	p_default_severity 		in VARCHAR2   	DEFAULT NULL,
	p_exception_handling	in VARCHAR2    DEFAULT NULL,
	p_workflow_item_type	in VARCHAR2    DEFAULT NULL,
  	p_workflow_process   	in VARCHAR2    DEFAULT NULL,
   	p_initiate_workflow 	in VARCHAR2    DEFAULT NULL,
	p_update_allowed 		in VARCHAR2    DEFAULT NULL,
	p_enabled 		in VARCHAR2    DEFAULT 'Y',
	p_attribute_category 	in VARCHAR2    DEFAULT NULL,
	p_attribute1			in VARCHAR2    DEFAULT NULL,
	p_attribute2			in VARCHAR2    DEFAULT NULL,
	p_attribute3	         	in VARCHAR2    DEFAULT NULL,
	p_attribute4	   		in VARCHAR2    DEFAULT NULL,
	p_attribute5	         	in VARCHAR2    DEFAULT NULL,
	p_attribute6	 		in VARCHAR2    DEFAULT NULL,
	p_attribute7			in VARCHAR2    DEFAULT NULL,
	p_attribute8			in VARCHAR2    DEFAULT NULL,
	p_attribute9			in VARCHAR2    DEFAULT NULL,
	p_attribute10			in VARCHAR2    DEFAULT NULL,
	p_attribute11 			in VARCHAR2    DEFAULT NULL,
	p_attribute12 			in VARCHAR2    DEFAULT NULL,
	p_attribute13			in VARCHAR2    DEFAULT NULL,
	p_attribute14			in VARCHAR2    DEFAULT NULL,
	p_attribute15	   		in VARCHAR2    DEFAULT NULL,
	p_creation_date 		in DATE		DEFAULT NULL,
 	p_created_by       		in NUMBER		DEFAULT NULL,
 	p_last_update_date 		in DATE		DEFAULT NULL,
 	p_last_updated_by  		in NUMBER		DEFAULT NULL,
 	p_last_update_login		in NUMBER		DEFAULT NULL
	);



-- ---------------------------------------------------------------------
-- procedure: update_xc_def_form
-- description: called by the form to update exception definition
--              This procedure should be called only by form WSHFXCDF.fmb,
--			 no one else should call this procedure.
-- ---------------------------------------------------------------------

procedure	update_xc_def_form (
	p_exception_definition_id		in NUMBER,
	p_exception_name		in VARCHAR2,
	p_description			in VARCHAR2   	DEFAULT NULL,
	p_exception_type		in VARCHAR2   	DEFAULT NULL,
	p_default_severity 		in VARCHAR2   	DEFAULT NULL,
	p_exception_handling	in VARCHAR2    DEFAULT NULL,
	p_workflow_item_type	in VARCHAR2    DEFAULT NULL,
 	p_workflow_process   	in VARCHAR2    DEFAULT NULL,
 	p_initiate_workflow 	in VARCHAR2    DEFAULT NULL,
	p_update_allowed 		in VARCHAR2    DEFAULT NULL,
	p_enabled 		in VARCHAR2    DEFAULT 'Y',
	p_attribute_category 	in VARCHAR2    DEFAULT NULL,
	p_attribute1			in VARCHAR2    DEFAULT NULL,
	p_attribute2			in VARCHAR2    DEFAULT NULL,
	p_attribute3	         	in VARCHAR2    DEFAULT NULL,
	p_attribute4	   		in VARCHAR2    DEFAULT NULL,
	p_attribute5	         	in VARCHAR2    DEFAULT NULL,
	p_attribute6	 		in VARCHAR2    DEFAULT NULL,
	p_attribute7			in VARCHAR2    DEFAULT NULL,
	p_attribute8			in VARCHAR2    DEFAULT NULL,
	p_attribute9			in VARCHAR2    DEFAULT NULL,
	p_attribute10			in VARCHAR2    DEFAULT NULL,
	p_attribute11 			in VARCHAR2    DEFAULT NULL,
	p_attribute12 			in VARCHAR2    DEFAULT NULL,
	p_attribute13			in VARCHAR2    DEFAULT NULL,
	p_attribute14			in VARCHAR2    DEFAULT NULL,
	p_attribute15	   		in VARCHAR2    DEFAULT NULL,
	p_creation_date 		in DATE		DEFAULT NULL,
 	p_created_by       		in NUMBER		DEFAULT NULL,
 	p_last_update_date 		in DATE		DEFAULT NULL,
 	p_last_updated_by  		in NUMBER		DEFAULT NULL,
 	p_last_update_login		in NUMBER		DEFAULT NULL,
        p_caller                        IN VARCHAR2     DEFAULT NULL      --- 5986504
	);


-- ---------------------------------------------------------------------
-- procedure: Load_Row
-- description: called by the generic loader to upload exception definition
--              This procedure should be called only by generic loader
--			 no one else should call this procedure.
-- ---------------------------------------------------------------------
procedure	Load_Row (
	p_language						in VARCHAR2,
	p_source_lang					in VARCHAR2,
	p_exception_definition_id	in NUMBER,
	p_exception_name			in VARCHAR2,
	p_description				in VARCHAR2,
	p_exception_type			in VARCHAR2,
	p_default_severity 		in VARCHAR2,
	p_exception_handling		in VARCHAR2,
	p_workflow_item_type		in VARCHAR2    DEFAULT NULL,
 	p_workflow_process   	in VARCHAR2    DEFAULT NULL,
 	p_initiate_workflow 		in VARCHAR2    DEFAULT NULL,
	p_update_allowed 			in VARCHAR2    DEFAULT NULL,
	p_enabled 			      in VARCHAR2    DEFAULT NULL,
	p_attribute_category 	in VARCHAR2    DEFAULT NULL,
	p_attribute1				in VARCHAR2    DEFAULT NULL,
	p_attribute2				in VARCHAR2    DEFAULT NULL,
	p_attribute3	         in VARCHAR2    DEFAULT NULL,
	p_attribute4	   		in VARCHAR2    DEFAULT NULL,
	p_attribute5	         in VARCHAR2    DEFAULT NULL,
	p_attribute6	 			in VARCHAR2    DEFAULT NULL,
	p_attribute7				in VARCHAR2    DEFAULT NULL,
	p_attribute8				in VARCHAR2    DEFAULT NULL,
	p_attribute9				in VARCHAR2    DEFAULT NULL,
	p_attribute10				in VARCHAR2    DEFAULT NULL,
	p_attribute11 				in VARCHAR2    DEFAULT NULL,
	p_attribute12 				in VARCHAR2    DEFAULT NULL,
	p_attribute13				in VARCHAR2    DEFAULT NULL,
	p_attribute14				in VARCHAR2    DEFAULT NULL,
	p_attribute15	   		in VARCHAR2    DEFAULT NULL,
	p_creation_date 			in DATE  DEFAULT NULL,
 	p_created_by       		in NUMBER   DEFAULT NULL,
 	p_last_update_date 		in DATE    DEFAULT NULL,
 	p_last_updated_by  		in NUMBER  DEFAULT NULL,
 	p_last_update_login		in NUMBER  DEFAULT NULL,
      --Bug 8205117 : Adding the parameters Custom_Mode and Upload Mode to the API Load_Row
        p_custom_mode                   in varchar2 default null,
        p_upload_mode                   in varchar2 default null

	);

-- ---------------------------------------------------------------------
-- procedure: Translate_Row
-- description: called by the generic loader to translate exception definition
--              This procedure should be called only by generic loader
--			 no one else should call this procedure.
-- --------------------------------------------------------------------

procedure Translate_Row (
		p_exception_definition_id		in number,
		p_exception_name				in VARCHAR2,
		p_description					in VARCHAR2,
		p_owner							in VARCHAR2
);



-- ---------------------------------------------------------------------
-- procedure: delete_xc_def_form
-- description: called by the form to delete exception definition
--              This procedure should be called only by form WSHFXCDF.fmb,
--			 no one else should call this procedure.
-- ---------------------------------------------------------------------
procedure delete_xc_def_form (
	p_exception_definition_id		in NUMBER
);



-- ---------------------------------------------------------------------
-- procedure: add_language
-- description: restore data intergrity to a corrupted
--			base/translation pair
--
-- ---------------------------------------------------------------------
procedure add_language;

-- ---------------------------------------------------------------------
-- function: Get_Lookup_Meaning
-- description: called by the view to populate Lookup Meaning for
--              EXCEPTION_BEHAVIOR and LOGGING_ENTITY
--
-- ---------------------------------------------------------------------
function Get_Lookup_Meaning (
	p_lookup_code		in VARCHAR2,
	p_lookup_type		in VARCHAR2
) return VARCHAR2 ;


-- --------------------------------------------------------------------------
-- Procedure:  Purge
-- Description:  This procedure will purge the exception data based on the
--               given input criteria
-- --------------------------------------------------------------------------

PROCEDURE Purge
          (p_api_version            IN     NUMBER,
           p_init_msg_list          IN     VARCHAR2  DEFAULT FND_API.G_FALSE,
           p_commit                 IN     VARCHAR2  DEFAULT FND_API.G_FALSE,
           p_validation_level       IN     NUMBER    DEFAULT FND_API.G_VALID_LEVEL_FULL,
           x_return_status          OUT NOCOPY     VARCHAR2,
           x_msg_count              OUT NOCOPY     NUMBER,
           x_msg_data               OUT NOCOPY     VARCHAR2,
           p_request_id             IN     NUMBER  DEFAULT NULL,
           p_exception_name         IN     VARCHAR2 DEFAULT NULL,
           p_logging_entity         IN     VARCHAR2 DEFAULT NULL,
           p_exception_location_id  IN     NUMBER  DEFAULT NULL,
           p_logged_at_location_id  IN     NUMBER DEFAULT NULL,
           p_inventory_org_id       IN     NUMBER  DEFAULT NULL ,
           p_exception_type         IN     VARCHAR2 DEFAULT NULL,
           p_severity               IN     VARCHAR2 DEFAULT NULL,
           p_status                 IN     VARCHAR2 DEFAULT NULL,
           p_arrival_date_from      IN     DATE      DEFAULT NULL,
           p_arrival_date_to        IN     DATE     DEFAULT NULL,
           p_departure_date_from    IN     DATE    DEFAULT NULL,
           p_departure_date_to      IN     DATE   DEFAULT NULL,
           p_creation_date_from     IN     DATE  DEFAULT NULL,
           p_creation_date_to       IN     DATE   DEFAULT NULL,
           p_data_older_no_of_days  IN     NUMBER  DEFAULT NULL,
           x_no_of_recs_purged      OUT NOCOPY     NUMBER,
           p_delivery_id            IN     NUMBER DEFAULT NULL,
           p_trip_id                IN     NUMBER DEFAULT NULL,
           p_trip_stop_id           IN     NUMBER DEFAULT NULL,
           p_delivery_detail_id     IN     NUMBER DEFAULT NULL,
           p_delivery_contents      IN     VARCHAR2 DEFAULT 'Y',
           p_action                 IN     VARCHAR2 DEFAULT NULL
          );


TYPE XC_REC_TYPE IS RECORD
     (entity_name             VARCHAR2(30),
      entity_id               NUMBER,
      exception_behavior      VARCHAR2(30)
     );

TYPE XC_TAB_TYPE IS TABLE OF XC_REC_TYPE INDEX BY BINARY_INTEGER;

-- -------------------------------------------------------------------------------
-- Start of comments
-- API name  : Check_Exceptions
-- Type      : Public
-- Function  : This procedure takes input as Entity Name and Entity Id
--             and finds the maximum severity exception logged against it.
--             Only Error and Warning Exceptions are considered, Information Only
--             are not considered.
--             If p_consider_content is set to 'Y', then the API also looks
--             at the contents of the Entity and checks for the maximum severity
--             against each child entity. This is drilled to lowest child entity.
--             The API returns a PL/SQL table of records with Entity Name, Entity ID
--             Exception Behavior. The table is populated with the Top Most entity
--             followed by its child entities (if exceptions exist against them) in
--             a hierarchial tree structure.
--             Valid Values for p_logging_entity_name : LINE, CONTAINER, DELIVERY,
--             TRIP, STOP
-- End of comments
-- --------------------------------------------------------------------------------

PROCEDURE Check_Exceptions (
                             -- Standard parameters
                             p_api_version           IN      NUMBER,
                             p_init_msg_list         IN      VARCHAR2  DEFAULT FND_API.G_FALSE,
                             x_return_status         OUT  NOCOPY    VARCHAR2,
                             x_msg_count             OUT  NOCOPY    NUMBER,
                             x_msg_data              OUT  NOCOPY    VARCHAR2,

                             -- program specific parameters
                             p_logging_entity_id	  IN 	NUMBER,
                             p_logging_entity_name	  IN	VARCHAR2,
                             p_consider_content      IN  VARCHAR2 DEFAULT 'Y',

                              -- program specific out parameters
                             x_exceptions_tab	IN OUT NOCOPY 	XC_TAB_TYPE,
                             p_caller                IN      VARCHAR2 DEFAULT NULL
                     	);


-- -------------------------------------------------------------------------------
-- Start of comments
-- API name  : Close_Exceptions
-- Type      : Public
-- Function  : This procedure takes input as Entity Name and Entity Id
--             and closes all exceptions logged against it.
--             If p_consider_content is set to 'Y', then the API also looks
--             at the contents of the Entity and closes all exceptions for the
--             child entities. This is drilled to lowest child entity.
--             This API should be called ONLY if Check_Exceptions is called before
--             it. This is because this API assumes all Error Exceptions are Resolved
--             prior to this API call and closes OPEN/NO_ACTION_REQUIRED exceptions
--             unless they are Information Only (FP bug 4370532)
--             Valid Values for p_logging_entity_name : LINE, CONTAINER, DELIVERY,
--             TRIP, STOP
-- End of comments
-- --------------------------------------------------------------------------------

PROCEDURE Close_Exceptions (
                               -- Standard parameters
                               p_api_version           IN   NUMBER,
                               p_init_msg_list         IN   VARCHAR2  DEFAULT FND_API.G_FALSE,
                               x_return_status         OUT  NOCOPY    VARCHAR2,
                               x_msg_count             OUT  NOCOPY    NUMBER,
                               x_msg_data              OUT  NOCOPY    VARCHAR2,

                               -- program specific parameters
                               p_logging_entity_id     IN  NUMBER,
                               p_logging_entity_name   IN  VARCHAR2,
                               p_consider_content      IN  VARCHAR2,
                               p_caller                IN  VARCHAR2 DEFAULT NULL
                          );

--OTM R12
PROCEDURE LOG_OTM_EXCEPTION(
  p_delivery_info_tab       IN         WSH_NEW_DELIVERIES_PVT.Delivery_Attr_Tbl_Type,
  p_new_interface_flag_tab  IN         WSH_UTIL_CORE.COLUMN_TAB_TYPE,
  x_return_status           OUT NOCOPY VARCHAR2);

PROCEDURE GET_OTM_DELIVERY_EXCEPTION (
  p_delivery_id         IN         WSH_NEW_DELIVERIES.DELIVERY_ID%TYPE,
  x_exception_name      OUT NOCOPY WSH_EXCEPTIONS.EXCEPTION_NAME%TYPE,
  x_severity            OUT NOCOPY WSH_EXCEPTIONS.SEVERITY%TYPE,
  x_return_status       OUT NOCOPY VARCHAR2);
--

END WSH_XC_UTIL;


/
