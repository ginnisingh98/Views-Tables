--------------------------------------------------------
--  DDL for Package EGO_CHANGE_USER_ATTRS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_CHANGE_USER_ATTRS_PUB" AUTHID CURRENT_USER AS
/* $Header: EGOCHUAS.pls 115.3 2003/07/29 05:07:56 akumar noship $ */



                       ----------------------
                       -- Global Variables --
                       ----------------------

/*
 * PROCESS_STATUS constants
 * ------------------------
 * The following constants are used in the
 * EGO_ITEM_USER_ATTRS_INTERFACE.PROCESS_STATUS column to describe the processing
 * status of each row.
 * G_PS_TO_BE_PROCESSED: *used by the caller* indicates that a row should be
 * processed
 * G_PS_IN_PROCESS: *used by the bulkloader* indicates that a row is being
 * processed
 * G_PS_ERROR: *used by the bulkloader* indicates that a row encountered an error
 * (NOTE: the error may have occurred in another interface table row with the same
 * ROW_IDENTIFIER column value, because all interface table rows with the
 * same ROW_IDENTIFIER column value are processed as one logical unit)
 * G_PS_SUCCESS: *used by the bulkloader* indicates that a row was succcessfully
 * loaded
 */

    G_PS_TO_BE_PROCESSED                     CONSTANT NUMBER := 1;
    G_PS_IN_PROCESS                          CONSTANT NUMBER := 2;
    G_PS_ERROR                               CONSTANT NUMBER := 3;
    G_PS_SUCCESS                             CONSTANT NUMBER := 4;



                          ----------------
                          -- Procedures --
                          ----------------

/*
 * Process_Item_User_Attrs_Data : Used by Import Process
 * ----------------------------
 * This procedure processes all interface table rows
 * corresponding to the passed-in data set ID.  ERRBUF and RETCODE are standard
 * parameters for concurrent programs, and we ignore them.
 * p_debug_level: number from 0-3, with 0 for no debug
 * information and 3 for exhaustive debugs
 * p_purge_successful_lines: 'T' or 'F', indicating
 * whether or not to delete all rows in this data set
 * that are successfully processed
 */
PROCEDURE Process_Change_User_Attrs_Data
(
        ERRBUF                          OUT NOCOPY VARCHAR2
       ,RETCODE                         OUT NOCOPY VARCHAR2
       ,p_data_set_id                   IN   NUMBER
       ,p_debug_level                   IN   NUMBER   DEFAULT 0
       ,p_purge_successful_lines        IN   VARCHAR2 DEFAULT FND_API.G_FALSE
);




/*
 * Get_Current_Data_Set_Id
 * -----------------------
 * (For use by SQL*Loader control file only)
 */
FUNCTION Get_Current_Data_Set_Id
RETURN NUMBER;

/*
 * Process_Change_User_Attrs : Public API to be called for immediate
 * processing Change header user attributes
*/
PROCEDURE Process_Change_User_Attrs
      (
        p_api_version                   IN NUMBER := 1.0
	,   p_init_msg_list             IN BOOLEAN := FALSE
	,   x_return_status             OUT NOCOPY VARCHAR2
	,   x_msg_count                 OUT NOCOPY NUMBER
	,   p_bo_identifier             IN  VARCHAR2 := 'ECO'
        ,p_change_number                IN VARCHAR2
        ,p_change_mgmt_type_code        IN VARCHAR2
        ,p_Organization_Code            IN VARCHAR2
        ,p_attributes_row_table         IN EGO_USER_ATTR_ROW_TABLE
        ,p_attributes_data_table        IN EGO_USER_ATTR_DATA_TABLE
	,   p_debug                     IN  VARCHAR2 := 'N'
	,   p_output_dir                IN  VARCHAR2 := NULL
	,   p_debug_filename            IN  VARCHAR2 := 'ECO_BO_Debug.log'
      );

/*
 * Process_Change_Line_User_Attrs : Public API to be called for immediate
 * processing Change line user attributes
*/
PROCEDURE Process_Change_Line_User_Attrs
      (
        p_api_version                   IN NUMBER := 1.0
        ,   p_init_msg_list             IN  BOOLEAN := FALSE
        ,   x_return_status             OUT NOCOPY VARCHAR2
        ,   x_msg_count                 OUT NOCOPY NUMBER
        ,   p_bo_identifier             IN  VARCHAR2 := 'ECO'
        ,p_change_number                IN VARCHAR2
        ,p_change_mgmt_type_code        IN VARCHAR2
        ,p_Organization_Code            IN VARCHAR2
        ,p_change_line_sequence_number  IN NUMBER
        ,p_attributes_row_table         IN EGO_USER_ATTR_ROW_TABLE
        ,p_attributes_data_table        IN EGO_USER_ATTR_DATA_TABLE
        ,   p_debug                     IN  VARCHAR2 := 'N'
        ,   p_output_dir                IN  VARCHAR2 := NULL
        ,   p_debug_filename            IN  VARCHAR2 := 'ECO_BO_Debug.log'
      );
--Begin of Bug:3070807

 PROCEDURE Check_Delete_Associations
(
          p_api_version                   IN      NUMBER
         ,p_association_id                IN      NUMBER
	 ,p_classification_code           IN      VARCHAR2
	 ,p_data_level                    IN      VARCHAR2
	 ,p_attr_group_id                 IN      NUMBER
	 ,p_application_id                IN      NUMBER
	 ,p_attr_group_type               IN      VARCHAR2
	 ,p_attr_group_name               IN      VARCHAR2
	 ,p_enabled_code                  IN      VARCHAR2
	 ,p_init_msg_list				          IN      VARCHAR2   := fnd_api.g_FALSE
	 ,x_ok_to_delete                  OUT     NOCOPY VARCHAR2
	 ,x_return_status           			OUT     NOCOPY VARCHAR2
	 ,x_errorcode               			OUT     NOCOPY NUMBER
	 ,x_msg_count               			OUT     NOCOPY NUMBER
        ,x_msg_data 			                OUT     NOCOPY VARCHAR2
);
--End  of Bug:3070807
END EGO_CHANGE_USER_ATTRS_PUB;


 

/
