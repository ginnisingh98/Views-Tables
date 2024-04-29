--------------------------------------------------------
--  DDL for Package INV_SHORTCHECKEXEC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_SHORTCHECKEXEC_PVT" AUTHID CURRENT_USER AS
/* $Header: INVSEPVS.pls 120.3 2006/06/23 00:01:13 stdavid ship $*/
  -- Start OF comments
  -- API name  : ExecCheck
  -- TYPE      : Private
  -- Pre-reqs  : None
  -- FUNCTION  :
  -- Parameters:
  --     IN    :
  --  p_api_version      IN  NUMBER (required)
  --  	API Version of this procedure
  --
  --  p_init_msg_list   IN  VARCHAR2 (optional)
  --    DEFAULT = FND_API.G_FALSE,
  --
  --  p_commit           IN  VARCHAR2 (optional)
  --    DEFAULT = FND_API.G_FALSE
  --
  --
  --     OUT NOCOPY /* file.sql.39 change */   :
  --  x_return_status    OUT NOCOPY /* file.sql.39 change */ NUMBER
  --  	Result of all the operations
  --
  --  x_msg_count        OUT NOCOPY /* file.sql.39 change */ NUMBER,
  --
  --  x_msg_data         OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  --
  --  x_ErrorCode        OUT NOCOPY /* file.sql.39 change */ NUMBER,
  --
  -- Version: Current Version 1.0
  --              Changed : Nothing
  --          No Previous Version 0.0
  --          Initial version 1.0
  -- Notes  :
  -- END OF comments
PROCEDURE ExecCheck (
  p_api_version 		IN NUMBER ,
  p_init_msg_list 		IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit 			IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  x_return_status 	 IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  x_msg_count 		 IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
  x_msg_data 		 IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  p_sum_detail_flag		IN NUMBER,
  p_organization_id		IN NUMBER,
  p_inventory_item_id		IN NUMBER,
  p_comp_att_qty_flag		IN NUMBER,
  p_primary_quantity		IN NUMBER DEFAULT 0,
  x_seq_num		 IN OUT NOCOPY /* file.sql.39 change */ NUMBER,  --  Made the Parameter as IN for Bug 4399653
  x_check_result	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
  );
  -- Start OF comments
  -- API name  : CheckPrerequisites
  -- TYPE      : Private
  -- Pre-reqs  : None
  -- FUNCTION  :
  -- Parameters:
  --     IN    :
  --  p_api_version      IN  NUMBER (required)
  --  	API Version of this procedure
  --
  --  p_init_msg_list   IN  VARCHAR2 (optional)
  --    DEFAULT = FND_API.G_FALSE,
  --
  --  p_commit           IN  VARCHAR2 (optional)
  --    DEFAULT = FND_API.G_FALSE
  --
  --
  --     OUT NOCOPY /* file.sql.39 change */   :
  --  x_return_status    OUT NOCOPY /* file.sql.39 change */ NUMBER
  --  	Result of all the operations
  --
  --  x_msg_count        OUT NOCOPY /* file.sql.39 change */ NUMBER,
  --
  --  x_msg_data         OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  --
  -- Version: Current Version 1.0
  --              Changed : Nothing
  --          No Previous Version 0.0
  --          Initial version 1.0
  -- Notes  :
  -- END OF comments
PROCEDURE CheckPrerequisites (
  p_api_version 		IN NUMBER ,
  p_init_msg_list 		IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  x_return_status 	 IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  x_msg_count 		 IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
  x_msg_data 		 IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  p_sum_detail_flag		IN NUMBER,
  p_organization_id		IN NUMBER,
  p_inventory_item_id		IN NUMBER,
  p_transaction_type_id		IN NUMBER,
  x_check_result	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
  );
  -- Start OF comments
  -- API name  : SendNotifications
  -- TYPE      : Private
  -- Pre-reqs  : None
  -- FUNCTION  :
  -- Parameters:
  --     IN    :
  --  p_api_version      IN  NUMBER (required)
  --  	API Version of this procedure
  --
  --  p_init_msg_list   IN  VARCHAR2 (optional)
  --    DEFAULT = FND_API.G_FALSE,
  --
  --  p_commit           IN  VARCHAR2 (optional)
  --    DEFAULT = FND_API.G_FALSE
  --
  --
  --     OUT NOCOPY /* file.sql.39 change */   :
  --  x_return_status    OUT NOCOPY /* file.sql.39 change */ NUMBER
  --  	Result of all the operations
  --
  --  x_msg_count        OUT NOCOPY /* file.sql.39 change */ NUMBER,
  --
  --  x_msg_data         OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  --
  -- Version: Current Version 1.0
  --              Changed : Nothing
  --          No Previous Version 0.0
  --          Initial version 1.0
  -- Notes  :
  -- END OF comments
PROCEDURE SendNotifications (
  p_api_version 		IN NUMBER ,
  p_init_msg_list 		IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit 			IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  x_return_status 	 IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  x_msg_count 		 IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
  x_msg_data 		 IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  p_organization_id		IN NUMBER,
  p_inventory_item_id		IN NUMBER,
  p_seq_num			IN NUMBER,
  p_notification_type		IN VARCHAR2
  );
  -- Start OF comments
  -- API name  : PurgeTempTable
  -- TYPE      : Private
  -- Pre-reqs  : None
  -- FUNCTION  :
  -- Parameters:
  --     IN    :
  --  p_api_version      IN  NUMBER (required)
  --  	API Version of this procedure
  --
  --  p_init_msg_list   IN  VARCHAR2 (optional)
  --    DEFAULT = FND_API.G_FALSE,
  --
  --  p_commit          IN  VARCHAR2 (optional)
  --    DEFAULT = FND_API.G_FALSE
  --
  --  p_seq_num		IN NUMBER
  --	Sequence number of rows which have to be deleted
  --
  --
  --     OUT NOCOPY /* file.sql.39 change */   :
  --  x_return_status    OUT NOCOPY /* file.sql.39 change */ NUMBER
  --  	Result of all the operations
  --
  --  x_msg_count        OUT NOCOPY /* file.sql.39 change */ NUMBER,
  --
  --  x_msg_data         OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  --
  --  x_ErrorCode        OUT NOCOPY /* file.sql.39 change */ NUMBER,
  --
  --
  -- Version: Current Version 1.0
  --              Changed : Nothing
  --          No Previous Version 0.0
  --          Initial version 1.0
  -- Notes  :
  -- END OF comments
PROCEDURE PurgeTempTable (
  p_api_version 		IN NUMBER ,
  p_init_msg_list 		IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit 			IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  x_return_status 	 IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  x_msg_count 		 IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
  x_msg_data 		 IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  p_seq_num			IN NUMBER
  );
PROCEDURE PrepareMessage (
  p_inventory_item_id		IN NUMBER,
  p_organization_id		IN NUMBER
  );
-- Added for bug 5081655: calculate open qty for repetitive schedules
FUNCTION get_rep_curr_open_qty
  ( p_organization_id         IN  NUMBER
  , p_wip_entity_id           IN  NUMBER
  , p_repetitive_schedule_id  IN  NUMBER
  , p_first_unit_start_date   IN  DATE
  , p_processing_work_days    IN  NUMBER
  , p_operation_seq_num       IN  NUMBER
  , p_inventory_item_id       IN  NUMBER
  , p_quantity_issued         IN  NUMBER
  ) RETURN NUMBER;
END INV_ShortCheckExec_PVT;

 

/
