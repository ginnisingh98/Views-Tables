--------------------------------------------------------
--  DDL for Package INV_SHORTCHECKEXEC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_SHORTCHECKEXEC_PUB" AUTHID CURRENT_USER AS
/* $Header: INVSEPUS.pls 120.1 2005/06/21 05:33:27 appldev ship $*/
  -- Start OF comments
  -- API name  : ExecCheck
  -- TYPE      : Public
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
  --     OUT   :
  --  x_return_status    OUT NUMBER
  --  	Result of all the operations
  --
  --  x_msg_count        OUT NUMBER,
  --
  --  x_msg_data         OUT VARCHAR2,
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
  x_return_status 		IN OUT NOCOPY VARCHAR2,
  x_msg_count 			IN OUT NOCOPY NUMBER,
  x_msg_data 			IN OUT NOCOPY VARCHAR2,
  p_sum_detail_flag		IN NUMBER,
  p_organization_id		IN NUMBER,
  p_inventory_item_id		IN NUMBER,
  p_comp_att_qty_flag		IN NUMBER,
  p_primary_quantity		IN NUMBER DEFAULT 0,
  x_seq_num			OUT NOCOPY NUMBER,
  x_check_result		OUT NOCOPY VARCHAR2
  );
  -- Start OF comments
  -- API name  : CheckPrerequisites
  -- TYPE      : Public
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
  --     OUT   :
  --  x_return_status    OUT NUMBER
  --  	Result of all the operations
  --
  --  x_msg_count        OUT NUMBER,
  --
  --  x_msg_data         OUT VARCHAR2,
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
  x_return_status 		IN OUT NOCOPY VARCHAR2,
  x_msg_count 			IN OUT NOCOPY NUMBER,
  x_msg_data 			IN OUT NOCOPY VARCHAR2,
  p_sum_detail_flag		IN NUMBER,
  p_organization_id		IN NUMBER,
  p_inventory_item_id		IN NUMBER,
  p_transaction_type_id		IN NUMBER,
  x_check_result		OUT NOCOPY VARCHAR2
  );
  -- Start OF comments
  -- API name  : PurgeTempTable
  -- TYPE      : Public
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
  --     OUT   :
  --  x_return_status    OUT NUMBER
  --  	Result of all the operations
  --
  --  x_msg_count        OUT NUMBER,
  --
  --  x_msg_data         OUT VARCHAR2,
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
  x_return_status 		IN OUT NOCOPY VARCHAR2,
  x_msg_count 			IN OUT NOCOPY NUMBER,
  x_msg_data 			IN OUT NOCOPY VARCHAR2,
  p_seq_num			IN NUMBER
  );
END INV_ShortCheckExec_PUB;

 

/
