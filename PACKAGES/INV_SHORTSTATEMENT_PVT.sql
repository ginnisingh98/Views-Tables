--------------------------------------------------------
--  DDL for Package INV_SHORTSTATEMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_SHORTSTATEMENT_PVT" AUTHID CURRENT_USER AS
/* $Header: INVSSTMS.pls 115.4 2003/01/20 09:54:01 shchandr ship $*/
  -- Start OF comments
  -- API name  : BuildDetail
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
  --     OUT   :
  --  x_return_status    OUT NUMBER
  --  	Result of all the operations
  --
  --  x_msg_count        OUT NUMBER,
  --
  --  x_msg_data         OUT VARCHAR2,
  --
  --  x_short_stat_detail OUT LONG
  --	Detail shortage statement
  --
  -- Version: Current Version 1.0
  --              Changed : Nothing
  --          No Previous Version 0.0
  --          Initial version 1.0
  -- Notes  :
  -- END OF comments
PROCEDURE BuildDetail (
  p_api_version 		IN NUMBER ,
  p_init_msg_list 		IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  x_return_status 		IN OUT NOCOPY VARCHAR2,
  x_msg_count 			IN OUT NOCOPY NUMBER,
  x_msg_data 			IN OUT NOCOPY VARCHAR2,
  p_organization_id		IN NUMBER,
  p_check_wip_flag		IN NUMBER,
  p_check_oe_flag		IN NUMBER,
  p_wip_rel_jobs_flag		IN NUMBER,
  p_wip_days_overdue_rel_jobs 	IN NUMBER,
  p_wip_unrel_jobs_flag		IN NUMBER,
  p_wip_days_overdue_unrel_jobs IN NUMBER,
  p_wip_hold_jobs_flag		IN NUMBER,
  p_wip_rel_rep_flag		IN NUMBER,
  p_wip_days_overdue_rel_rep    IN NUMBER,
  p_wip_unrel_rep_flag		IN NUMBER,
  p_wip_days_overdue_unrel_rep  IN NUMBER,
  p_wip_hold_rep_flag		IN NUMBER,
  p_wip_req_date_jobs_flag      IN NUMBER,
  p_wip_curr_op_jobs_flag	IN NUMBER,
  p_wip_prev_op_jobs_flag	IN NUMBER,
  p_wip_req_date_rep_flag       IN NUMBER,
  p_wip_curr_op_rep_flag        IN NUMBER,
  p_wip_prev_op_rep_flag        IN NUMBER,
  p_wip_excl_bulk_comp_flag    	IN NUMBER,
  p_wip_excl_supplier_comp_flag	IN NUMBER,
  p_wip_excl_pull_comp_flag     IN NUMBER,
  x_short_stat_detail		OUT NOCOPY LONG
  );
  -- Start OF comments
  -- API name  : BuildSummary
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
  --     OUT   :
  --  x_return_status    OUT NUMBER
  --  	Result of all the operations
  --
  --  x_msg_count        OUT NUMBER,
  --
  --  x_msg_data         OUT VARCHAR2,
  --
  --  x_short_stat_sum OUT LONG
  --	Summary shortage statement
  --
  -- Version: Current Version 1.0
  --              Changed : Nothing
  --          No Previous Version 0.0
  --          Initial version 1.0
  -- Notes  :
  -- END OF comments
PROCEDURE BuildSummary (
  p_api_version 		IN NUMBER ,
  p_init_msg_list 		IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  x_return_status 		IN OUT NOCOPY VARCHAR2,
  x_msg_count 			IN OUT NOCOPY NUMBER,
  x_msg_data 			IN OUT NOCOPY VARCHAR2,
  p_organization_id		IN NUMBER,
  p_check_wip_flag		IN NUMBER,
  p_check_oe_flag		IN NUMBER,
  p_wip_rel_jobs_flag		IN NUMBER,
  p_wip_days_overdue_rel_jobs 	IN NUMBER,
  p_wip_unrel_jobs_flag		IN NUMBER,
  p_wip_days_overdue_unrel_jobs IN NUMBER,
  p_wip_hold_jobs_flag		IN NUMBER,
  p_wip_rel_rep_flag		IN NUMBER,
  p_wip_days_overdue_rel_rep    IN NUMBER,
  p_wip_unrel_rep_flag		IN NUMBER,
  p_wip_days_overdue_unrel_rep  IN NUMBER,
  p_wip_hold_rep_flag		IN NUMBER,
  p_wip_req_date_jobs_flag      IN NUMBER,
  p_wip_curr_op_jobs_flag	IN NUMBER,
  p_wip_prev_op_jobs_flag	IN NUMBER,
  p_wip_req_date_rep_flag       IN NUMBER,
  p_wip_curr_op_rep_flag        IN NUMBER,
  p_wip_prev_op_rep_flag        IN NUMBER,
  p_wip_excl_bulk_comp_flag    	IN NUMBER,
  p_wip_excl_supplier_comp_flag	IN NUMBER,
  p_wip_excl_pull_comp_flag     IN NUMBER,
  x_short_stat_sum		OUT NOCOPY LONG
  );
  -- Start OF comments
  -- API name  : InsertUpdate
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
PROCEDURE InsertUpdate (
  p_api_version 		IN NUMBER ,
  p_init_msg_list 		IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  x_return_status 		IN OUT NOCOPY VARCHAR2,
  x_msg_count 			IN OUT NOCOPY NUMBER,
  x_msg_data 			IN OUT NOCOPY VARCHAR2,
  p_organization_id		IN NUMBER,
  p_short_stat_sum		IN LONG,
  p_short_stat_detail		IN LONG
  );
  -- Start OF comments
  -- API name  : StartBuild
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
PROCEDURE StartBuild (
  p_api_version 		IN NUMBER ,
  p_init_msg_list 		IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_commit 			IN VARCHAR2 DEFAULT FND_API.G_FALSE,
  x_return_status 		IN OUT NOCOPY VARCHAR2,
  x_msg_count 			IN OUT NOCOPY NUMBER,
  x_msg_data 			IN OUT NOCOPY VARCHAR2,
  p_organization_id		IN NUMBER,
  p_check_wip_flag		IN NUMBER,
  p_check_oe_flag		IN NUMBER,
  p_wip_rel_jobs_flag		IN NUMBER,
  p_wip_days_overdue_rel_jobs 	IN NUMBER,
  p_wip_unrel_jobs_flag		IN NUMBER,
  p_wip_days_overdue_unrel_jobs IN NUMBER,
  p_wip_hold_jobs_flag		IN NUMBER,
  p_wip_rel_rep_flag		IN NUMBER,
  p_wip_days_overdue_rel_rep    IN NUMBER,
  p_wip_unrel_rep_flag		IN NUMBER,
  p_wip_days_overdue_unrel_rep  IN NUMBER,
  p_wip_hold_rep_flag		IN NUMBER,
  p_wip_req_date_jobs_flag      IN NUMBER,
  p_wip_curr_op_jobs_flag	IN NUMBER,
  p_wip_prev_op_jobs_flag	IN NUMBER,
  p_wip_req_date_rep_flag       IN NUMBER,
  p_wip_curr_op_rep_flag        IN NUMBER,
  p_wip_prev_op_rep_flag        IN NUMBER,
  p_wip_excl_bulk_comp_flag    	IN NUMBER,
  p_wip_excl_supplier_comp_flag	IN NUMBER,
  p_wip_excl_pull_comp_flag     IN NUMBER
  );
END INV_ShortStatement_PVT;

 

/
