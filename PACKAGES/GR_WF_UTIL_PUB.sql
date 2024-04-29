--------------------------------------------------------
--  DDL for Package GR_WF_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GR_WF_UTIL_PUB" AUTHID CURRENT_USER AS
/*  $Header: GRWFUPBS.pls 120.2 2007/12/13 20:55:11 plowe ship $    */

/*  Global variables */
G_PKG_NAME    CONSTANT varchar2(30) := 'GR_WF_UTIL_PUB';
G_debug_level CONSTANT NUMBER       := FND_MSG_PUB.G_Msg_Level_Threshold; -- Use this variable everywhere
/*===========================================================================
--  PROCEDURE:
--    INITIATE_PROCESS_ITEM_CHNG
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to initiate the Document Rebuild Required Workflow
--    for a Item Properties change for a regulatory item. And it will be called from the
--    trigger on Item properties table.
--
--  PARAMETERS:
--    p_api_version   IN  NUMBER            - API Version
--    p_init_msg_list IN  VARCHAR2          - Initiate the message list
--    p_commit        IN  VARCHAR2          - Commit Flag
--    p_orgn_id       IN  NUMBER            - Organization Id for an Item
--    p_item_id       IN  NUMBER          - Item Id of an Item
--    x_return_status OUT NOCOPY VARCHAR2   - 'S'uccess, 'E'rror, 'U'nexpected Error
--    x_error_code    OUT NOCOPY VARCHAR2   - If there is an error, send back the approriate error code
--    x_msg_data      OUT NOCOPY VARCHAR2   - If there is an error, send back the approriate message
--
--  SYNOPSIS:
--    INITIATE_PROCESS_ITEM_CHNG(l_api_version,l_init_msg_list,l_commit,l_orgn_id
--                               l_item_id,x_return_status,x_error_code,x_msg_data);
--
--  HISTORY
--    Mercy Thomas   31-Mar-2005  BUG 4276612 - Created.
--
--=========================================================================== */

	PROCEDURE INITIATE_PROCESS_ITEM_CHNG
	(p_api_version              IN         	   NUMBER,
	 p_init_msg_list            IN             VARCHAR2,
	 p_commit                   IN             VARCHAR2,
	 p_orgn_id                  IN	           NUMBER,
	 p_item_id                  IN	           NUMBER,
	 p_user_id                  IN             NUMBER,
	 x_return_status           OUT 	NOCOPY     VARCHAR2,
	 x_error_code              OUT 	NOCOPY     NUMBER,
	 x_msg_data            	   OUT 	NOCOPY     VARCHAR2
	);

/*===========================================================================
--  PROCEDURE:
--    INITIATE_PROCESS_FORMULA_CHNG
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to initiate the Document Rebuild Required Workflow
--    for a Formula change for a regulatory item. And it will be called from the
--    trigger from a Formula API.
--
--  PARAMETERS:
--    p_api_version   IN  NUMBER            - API Version
--    p_init_msg_list IN  VARCHAR2          - Initiate the message list
--    p_commit        IN  VARCHAR2          - Commit Flag
--    p_orgn_id       IN  NUMBER            - Organization Id for an Item
--    p_item_id       IN  NUMBER            - Item Id of an Item
--    p_formula_id    IN  NUMBER            - Formula Id of product
--    x_return_status OUT NOCOPY VARCHAR2   - 'S'uccess, 'E'rror, 'U'nexpected Error
--    x_error_code    OUT NOCOPY VARCHAR2   - If there is an error, send back the approriate error code
--    x_msg_data      OUT NOCOPY VARCHAR2   - If there is an error, send back the approriate message
--
--  SYNOPSIS:
--    INITIATE_PROCESS_FORMULA_CHNG(l_api_version,l_init_msg_list,l_commit,l_orgn_id
--                               l_item_id,l_formula_id,x_return_status,x_error_code,x_msg_data);
--
--  HISTORY
--    Mercy Thomas   31-Mar-2005  BUG 4276612 - Created.
--
--=========================================================================== */
	PROCEDURE INITIATE_PROCESS_FORMULA_CHNG
	(p_api_version              IN         	   NUMBER,
	 p_init_msg_list            IN             VARCHAR2,
	 p_commit                   IN             VARCHAR2,
	 p_orgn_id                  IN	           NUMBER,
	 p_item_id                  IN	           NUMBER,
	 p_formula_no               IN	           VARCHAR2,
	 p_formula_vers             IN	           NUMBER,
	 p_user_id                  IN             NUMBER,
	 x_return_status           OUT 	NOCOPY VARCHAR2,
	 x_error_code              OUT 	NOCOPY NUMBER,
	 x_msg_data                OUT 	NOCOPY VARCHAR2
	);

/*===========================================================================
--  PROCEDURE:
--    INITIATE_PROCESS_SALES_ORDER
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to initiate the Document Rebuild Required Workflow
--    or a Sales Order change for a hazardous regulatory item. And it will be called from the
--    trigger from INV_Move_Order_PUB.Create_Move_Order_Lines
--
--  PARAMETERS:
--    p_api_version   IN  NUMBER            - API Version
--    p_init_msg_list IN  VARCHAR2          - Initiate the message list
--    p_commit        IN  VARCHAR2          - Commit Flag
--    p_sales_order_org_id  IN NUMBER       - Organization Id (OU) for the Sales Order
--    p_orgn_id       IN  NUMBER            - Organization Id for an Item
--    p_item_id       IN  NUMBER            - Item Id of an Item
--    p_sales_order_noIN  VARCHAR2          - Sales Order Number of an Item
--    x_return_status OUT NOCOPY VARCHAR2   - 'S'uccess, 'E'rror, 'U'nexpected Error
--    x_error_code    OUT NOCOPY VARCHAR2   - If there is an error, send back the approriate error code
--    x_msg_data      OUT NOCOPY VARCHAR2   - If there is an error, send back the approriate message
--
--  SYNOPSIS:
--    INITIATE_PROCESS_SALES_ORDER(l_api_version,l_init_msg_list,l_commit,l_orgn_id
--                               l_item_id,l_sales_order_no,x_return_status,x_error_code,x_msg_data);
--
--  HISTORY
--    Mercy Thomas   31-Mar-2005  BUG 4276612 - Created.
--    Peter Lowe     13-Dec-2007  Bug 6689912 Added sales order org id to
--                       signature of INITIATE_PROCESS_SALES_ORDER
--			     for 3rd Party Integration
--========================================================================= */

	PROCEDURE INITIATE_PROCESS_SALES_ORDER
	(p_api_version              IN         	   NUMBER,
	 p_init_msg_list            IN             VARCHAR2,
	 p_commit                   IN             VARCHAR2,
	 p_sales_order_org_id       IN             NUMBER,
	 p_orgn_id                  IN	           NUMBER,
	 p_item_id                  IN	           NUMBER,
	 p_sales_order_no           IN	           VARCHAR2,
	 x_return_status           OUT 	NOCOPY     VARCHAR2,
	 x_error_code              OUT 	NOCOPY     NUMBER,
	 x_msg_data                OUT 	NOCOPY     VARCHAR2
	);
/*===========================================================================
--  PROCEDURE:
--    INITIATE_PROCESS_TECH_CHNG
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to initiate the Document Rebuild Required Workflow
--    for a Technical Parameters change for a regulatory item. And it will be called from the
--    trigger on Item Technical Data Header table.
--
--  PARAMETERS:
--    p_api_version   IN  NUMBER            - API Version
--    p_init_msg_list IN  VARCHAR2          - Initiate the message list
--    p_commit        IN  VARCHAR2          - Commit Flag
--    p_orgn_id       IN  NUMBER            - Organization Id for an Item
--    p_item_id       IN  NUMBER          - Item Id of an Item
--    p_tech_data_id  IN  NUMBER          - Technical Data_Id of product
--    x_return_status OUT NOCOPY VARCHAR2   - 'S'uccess, 'E'rror, 'U'nexpected Error
--    x_error_code    OUT NOCOPY VARCHAR2   - If there is an error, send back the approriate error code
--    x_msg_data      OUT NOCOPY VARCHAR2   - If there is an error, send back the approriate message
--
--  SYNOPSIS:
--    INITIATE_PROCESS_TECH_CHNG(l_api_version,l_init_msg_list,l_commit,l_orgn_id
--                               l_item_id,l_tech_data_id,x_return_status,x_error_code,x_msg_data);
--
--  HISTORY
--    Mercy Thomas   31-Mar-2005  BUG 4276612 - Created.
--
--=========================================================================== */

	PROCEDURE INITIATE_PROCESS_TECH_CHNG
	(p_api_version              IN         	   NUMBER,
	 p_init_msg_list            IN             VARCHAR2,
	 p_commit                   IN             VARCHAR2,
	 p_orgn_id                  IN	           NUMBER,
	 p_tech_data_id             IN	           NUMBER,
	 p_tech_parm_id             IN             NUMBER,
	 p_user_id                  IN             NUMBER,
	 x_return_status           OUT 	NOCOPY VARCHAR2,
	 x_error_code              OUT 	NOCOPY NUMBER,
	 x_msg_data                OUT 	NOCOPY VARCHAR2
	);

END GR_WF_UTIL_PUB;

/
