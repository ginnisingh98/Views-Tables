--------------------------------------------------------
--  DDL for Package Body INV_SHORTCHECKEXEC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_SHORTCHECKEXEC_PVT" AS
/* $Header: INVSEPVB.pls 120.12 2007/12/03 09:25:32 aambulka ship $*/
G_PKG_NAME              CONSTANT VARCHAR2(30) := 'INV_ShortCheckExec_PVT';
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
  x_seq_num		 IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
  x_check_result	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
  )
IS
     L_api_version 		CONSTANT NUMBER := 1.0;
     L_api_name 		CONSTANT VARCHAR2(30) := 'ExecCheck';
     L_WIP_short_quantity	NUMBER;
     L_OE_short_quantity	NUMBER;
     L_Statement_not_found	EXCEPTION;
     L_count			NUMBER;             -- Added for Bug #4474266


     -- Bug #4474266 Added the following cursor
     CURSOR L_Quantity_crs (p_organization_id  IN NUMBER,
                            p_seq_num          IN NUMBER) IS
	SELECT sum(quantity_open) short_quantity,
	       inventory_item_id
	FROM mtl_short_chk_temp
	WHERE organization_id = p_organization_id
        AND seq_num = p_seq_num     -- Bug 5081665: filter on seq_num
	group by inventory_item_id;

  --
     PROCEDURE ExecStatement ( p_organization_id 	IN NUMBER,
			       p_inventory_item_id	IN NUMBER,
			       p_sum_detail_flag	IN NUMBER,
			       x_seq_num	 OUT NOCOPY /* file.sql.39 change */ NUMBER,
			       x_wip_short_quantity OUT NOCOPY /* file.sql.39 change */ NUMBER,
			       x_oe_short_quantity OUT NOCOPY /* file.sql.39 change */ NUMBER )
     IS
     L_Statement		LONG;
     L_ExecStatement_crs	NUMBER;
     L_RowsProcessed		NUMBER;
  --
     -- Cursor for shortage statements
     CURSOR L_Statement_crs ( p_organization_id  IN NUMBER,
			      p_sum_detail_flag	 IN NUMBER ) IS
	SELECT short_statement
	FROM   mtl_short_chk_statements
	WHERE  organization_id = p_organization_id
	AND    detail_sum_flag = p_sum_detail_flag;
  --
     BEGIN
	   -- Get statement
     	   OPEN L_Statement_crs ( p_organization_id,
	  		          p_sum_detail_flag );
     	   FETCH L_Statement_crs INTO L_Statement;
           IF L_Statement_crs%NOTFOUND THEN
		RAISE L_Statement_not_found;
	   END IF;
	   CLOSE L_Statement_crs;
  --
	   -- Execute statement
	   L_ExecStatement_crs := dbms_sql.open_cursor;
	   dbms_sql.parse(L_ExecStatement_crs,L_Statement,dbms_sql.v7);
	   dbms_sql.bind_variable(L_ExecStatement_crs,':organization_id',
						      p_organization_id);
	   dbms_sql.bind_variable(L_ExecStatement_crs,':inventory_item_id',
						      p_inventory_item_id);
	   -- If statement type is summary then bind wip and oe short quantity
	   IF p_sum_detail_flag = 2 THEN
	      dbms_sql.bind_variable(L_ExecStatement_crs,':wip_short_quantity',
							 0);
	      dbms_sql.bind_variable(L_ExecStatement_crs,':oe_short_quantity',
							 0);
	   END IF;
	   -- If statement type is detail then pull sequence number and bind it
	   IF p_sum_detail_flag = 1 THEN
		SELECT mtl_short_chk_temp_s.NEXTVAL
		INTO   x_seq_num
		FROM   dual;
		--
	        dbms_sql.bind_variable(L_ExecStatement_crs,':seq_num',
							   x_seq_num);
	   ELSE
		x_seq_num := NULL;
	   END IF;
	   L_RowsProcessed := dbms_sql.execute(L_ExecStatement_crs);
	   -- If statement type is summary then pick up the wip and oe
 	   -- short quantity
	   IF p_sum_detail_flag = 2 THEN
	      dbms_sql.variable_value(L_ExecStatement_crs,':wip_short_quantity',
						          x_wip_short_quantity);
	      dbms_sql.variable_value(L_ExecStatement_crs,':oe_short_quantity',
 						          x_oe_short_quantity);
	   END IF;
	   dbms_sql.close_cursor(L_ExecStatement_crs);
     END ExecStatement;
  --
     FUNCTION Compare (
	p_organization_id	IN NUMBER,
	p_inventory_item_id	IN NUMBER,
	p_short_quantity	IN NUMBER )
     RETURN VARCHAR2
     IS
	L_ATT_qty                NUMBER;
	L_primary_quantity	 NUMBER;
	L_adj_qty		 NUMBER;
	L_qty_on_hand		 NUMBER;
	L_qty_res_on_hand	 NUMBER;
	L_qty_res		 NUMBER;
	L_qty_sug		 NUMBER;
	L_qty_atr		 NUMBER;
	L_api_return_status	 VARCHAR2(1);
     BEGIN

     -- Clearing the quantity cache
     --inv_quantity_tree_pub.clear_quantity_cache;

     -- Call quantity tree to obtain the quantity available to transact
     INV_Quantity_Tree_PUB.Query_Quantities
     (
	p_api_version_number	=>	1.0
   	, p_init_msg_lst        =>	fnd_api.g_false
   	, x_return_status       =>	L_api_return_status
   	, x_msg_count           =>	x_msg_count
   	, x_msg_data            =>	x_msg_data
   	, p_organization_id     =>	p_organization_id
   	, p_inventory_item_id   =>	p_inventory_item_id
   	, p_tree_mode           =>	INV_Quantity_Tree_PUB.g_transaction_mode
	, p_is_revision_control =>	FALSE
   	, p_is_lot_control      =>	FALSE
	, p_is_serial_control   =>	FALSE
	, p_revision            =>	NULL
	, p_lot_number          =>	NULL
   	, p_subinventory_code	=>	NULL
	, p_locator_id          =>	NULL
	, x_qoh                 =>	L_qty_on_hand
   	, x_rqoh		=>	L_qty_res_on_hand
   	, x_qr			=>	L_qty_res
   	, x_qs			=>	L_qty_sug
   	, x_att			=>	L_ATT_qty
   	, x_atr			=>	L_qty_atr
     );
     IF L_api_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     /* Old code which did not use the quantity tree
     	SELECT NVL(SUM(transaction_quantity),0)
     	INTO   L_ATT_qty
     	FROM   mtl_att_qty_v
     	WHERE  organization_id 		= p_organization_id
     	AND    inventory_item_id	= p_inventory_item_id;
     */

	-- Now compare the ATT qty (but if it is a background transaction:
	-- minus the receipt quantity which is already included)
	-- against the summarized short quantity
	IF p_sum_detail_flag = 1 THEN
	   L_primary_quantity := p_primary_quantity;
	ELSE
	   L_primary_quantity := 0;
	END IF;

	-- Compute the adjusted ATT qty; the ATT qty without the primary
	-- quantity, or 0 if negative
	L_adj_qty := L_ATT_qty - L_primary_quantity;
	IF (L_adj_qty < 0) THEN
	  L_adj_qty := 0;
	END IF;

	-- Compare the adjusted ATT quantity (supply) to the shortage quantity (demand)
        IF L_adj_qty >= p_short_quantity THEN
	   return (FND_API.G_FALSE);
	ELSE
	   return (FND_API.G_TRUE);
	END IF;
     END Compare;
  --
  BEGIN
     -- Standard Call to check for call compatibility
     IF NOT FND_API.Compatible_API_Call(l_api_version
           , p_api_version
           , l_api_name
           , G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
     --
     -- Initialize message list if p_init_msg_list is set to true
     IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
     END IF;
     --
     -- Initialize API return status to access
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     --
     -- Initialize x_check_result
     x_check_result := FND_API.G_FALSE;
     -- See what statement we have to execute

     -- Bug #4474266 Added the IF condition for p_sum_detail_flag = 0

     IF p_sum_detail_flag = 0 THEN
	 select count(*) into L_count from mtl_short_chk_temp;

	 IF L_count > 0 then
	   Begin
	    FOR L_Quantity_rec in L_Quantity_crs (p_organization_id, x_seq_num)
	      LOOP
                  x_check_result := Compare (
                                              p_organization_id   => p_organization_id,
                                              p_inventory_item_id => L_Quantity_rec.inventory_item_id,
                                              p_short_quantity    => L_Quantity_rec.short_quantity);

                  IF  x_check_result = FND_API.G_FALSE THEN
                     delete from mtl_short_chk_temp
                     where inventory_item_id = L_Quantity_rec.inventory_item_id
                     and seq_num = x_seq_num  -- Bug 5081665: filter on seq_num
                     and organization_id = p_organization_id;
                  END IF;
              END LOOP;
	   end;
         END IF;

    ELSIF p_sum_detail_flag = 1 THEN
	-- detail statement
	-- If we have to compare the short quantity with the orgs ATT quantity,
	-- we execute first the summary statement to see if there are any
	-- shortages
	IF p_comp_att_qty_flag = 1 THEN
	   -- Get statement and execute it
	   ExecStatement (
		p_organization_id	=> p_organization_id,
		p_inventory_item_id	=> p_inventory_item_id,
		p_sum_detail_flag	=> 2,
		x_seq_num               => x_seq_num,
		x_wip_short_quantity	=> L_WIP_short_quantity,
		x_oe_short_quantity	=> L_OE_short_quantity
	   );
	   -- Compare short and att quantity (both are in primary uom)
	   x_check_result := Compare (
				p_organization_id	=> p_organization_id,
				p_inventory_item_id	=> p_inventory_item_id,
				p_short_quantity	=>
				    L_WIP_short_quantity + L_OE_short_quantity);
	END IF;
	-- Now execute the detail statement if shortage exists or
	-- parameter p_comp_att_qty_flag has been set to No
	IF p_sum_detail_flag = 1 AND (p_comp_att_qty_flag = 2 OR
				      x_check_result = FND_API.G_TRUE) THEN
	   -- Get statement and execute it
	   ExecStatement (
		p_organization_id	=> p_organization_id,
		p_inventory_item_id	=> p_inventory_item_id,
		p_sum_detail_flag	=> 1,
		x_seq_num		=> x_seq_num,
		x_wip_short_quantity	=> L_WIP_short_quantity,
		x_oe_short_quantity	=> L_OE_short_quantity
	   );
	   -- Set x_check_result according to mtl_short_chk_temp table contents
	   BEGIN
		SELECT FND_API.G_TRUE
	   	INTO   x_check_result
	   	FROM   mtl_short_chk_temp
	   	WHERE  seq_num = x_seq_num
		AND    rownum < 2;
	   EXCEPTION
		WHEN NO_DATA_FOUND THEN
		x_check_result := FND_API.G_FALSE;
	   END;
	END IF;
     ELSIF p_sum_detail_flag = 2 THEN
	-- summary statement
	-- Get statement and execute it
	ExecStatement (
		p_organization_id	=> p_organization_id,
		p_inventory_item_id	=> p_inventory_item_id,
		p_sum_detail_flag	=> 2,
		x_seq_num		=> x_seq_num,
		x_wip_short_quantity	=> L_WIP_short_quantity,
		x_oe_short_quantity	=> L_OE_short_quantity
	);
	-- Compare short and att quantity (both are in primary uom)
	x_check_result := Compare (
				p_organization_id	=> p_organization_id,
				p_inventory_item_id	=> p_inventory_item_id,
				p_short_quantity	=>
				    L_WIP_short_quantity + L_OE_short_quantity);
     END IF;
     --
     -- Standard check of p_commit
     IF FND_API.to_Boolean(p_commit) THEN
        COMMIT;
     END IF;
     -- Standard call to get message count and if count is 1, get message info
     FND_MSG_PUB.Count_And_Get
     (p_count => x_msg_count
        , p_data => x_msg_data);
  EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
     --
     x_return_status := FND_API.G_RET_STS_ERROR;
     --
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
        , p_data => x_msg_data);
     --
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
        , p_data => x_msg_data);
     --
     WHEN L_Statement_not_found THEN
     --
     x_return_status := FND_API.G_RET_STS_ERROR;
     --
     FND_MESSAGE.SET_NAME('INV','INV_SHORT_STATEMENT_NOT_FOUND');
     FND_MSG_PUB.Add;
     --
     WHEN OTHERS THEN
     --
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;
     --
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
        , p_data => x_msg_data);
  END;
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
  )
IS
     L_api_version 	CONSTANT NUMBER := 1.0;
     L_api_name 	CONSTANT VARCHAR2(30) := 'CheckPrerequisites';
     L_TransTypeFlag	NUMBER;
     L_ItemFlag 	NUMBER;
     --
     CURSOR L_TransType_crs ( p_transaction_type_id  IN NUMBER,
			      p_sum_detail_flag	     IN NUMBER ) IS
     	SELECT DECODE(p_sum_detail_flag,1,shortage_msg_background_flag,
				     	2,shortage_msg_online_flag)
     	FROM   mtl_transaction_types
     	WHERE  transaction_type_id = p_transaction_type_id;
     --
     CURSOR L_Item_crs ( p_organization_id    IN NUMBER,
		         p_inventory_item_id  IN NUMBER ) IS
	SELECT DECODE(check_shortages_flag,'Y',1,'N',2,NULL)
	FROM   mtl_system_items
	WHERE  inventory_item_id = p_inventory_item_id
	AND    organization_id   = p_organization_id;
     --
  BEGIN
     -- Standard Call to check for call compatibility
     IF NOT FND_API.Compatible_API_Call(l_api_version
           , p_api_version
           , l_api_name
           , G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
     --
     -- Initialize message list if p_init_msg_list is set to true
     IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
     END IF;
     --
     -- Initialize API return status to access
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     --
     -- Initialize x_check_result to FND_API.G_FALSE
     x_check_result := FND_API.G_FALSE;
     --
     -- Check if transaction type allows shortage message for given
     -- message type (but only if p_transaction_type_id is not null)
     IF p_transaction_type_id IS NOT NULL THEN
        OPEN L_TransType_crs ( p_transaction_type_id,
			       p_sum_detail_flag );
        FETCH L_TransType_crs INTO L_TransTypeFlag;
        CLOSE L_TransType_crs;
     ELSE
	L_TransTypeFlag := 1;
     END IF;
     IF L_TransTypeFlag = 1 THEN
	-- Check if item allows shortage message for given message type
	-- If so, set x_check_result to FND_API.G_TRUE
	OPEN L_Item_crs ( p_organization_id,
		          p_inventory_item_id );
	FETCH L_Item_crs INTO L_ItemFlag;
	CLOSE L_Item_crs;
	IF L_ItemFlag = 1 THEN
	   x_check_result := FND_API.G_TRUE;
	END IF;
     END IF;
     --
     -- Standard call to get message count and if count is 1, get message info
     FND_MSG_PUB.Count_And_Get
     (p_count => x_msg_count
        , p_data => x_msg_data);
  EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
     --
     x_return_status := FND_API.G_RET_STS_ERROR;
     --
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
        , p_data => x_msg_data);
     --
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
        , p_data => x_msg_data);
     --
     WHEN OTHERS THEN
     --
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;
     --
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
        , p_data => x_msg_data);
  END;
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
  )
IS
     L_api_version 		CONSTANT NUMBER := 1.0;
     L_api_name 		CONSTANT VARCHAR2(30) := 'SendNotifications';
     L_user_name		VARCHAR2(100);
     L_notification_id		NUMBER;
     L_item_conc_segments	mtl_system_items_kfv.concatenated_segments%TYPE;
     L_organization_code	VARCHAR2(3);
     L_msg_name			VARCHAR2(30);
     l_org_id                   NUMBER;  -- MOAC parameter
     l_ou_org_id                NUMBER;  --Bug#6509349

     --
     CURSOR L_Item_crs IS
	SELECT concatenated_segments
	FROM   mtl_system_items_kfv
	WHERE  inventory_item_id = p_inventory_item_id
	AND    organization_id	 = p_organization_id;
     --
     CURSOR L_Org_crs IS
	SELECT organization_code
	FROM   mtl_parameters
	WHERE  organization_id = p_organization_id;
     --
     CURSOR L_ShortParam_csr ( p_organization_id  IN NUMBER ) IS
	SELECT DECODE(check_wip_flag,1,wip_notif_comp_planner_flag,2)
		wip_notif_comp_planner_flag,
	       DECODE(check_wip_flag,1,wip_notif_ass_planner_flag,2)
		wip_notif_ass_planner_flag,
	       DECODE(check_wip_flag,1,wip_notif_comp_buyer_flag,2)
		wip_notif_comp_buyer_flag,
	       DECODE(check_wip_flag,1,wip_notif_job_creator_flag,2)
		wip_notif_job_creator_flag,
	       DECODE(check_oe_flag,1,oe_notif_item_planner_flag,2)
		oe_notif_item_planner_flag,
	       DECODE(check_oe_flag,1,oe_notif_so_creator_flag,2)
		oe_notif_so_creator_flag
	FROM   mtl_short_chk_param
	WHERE  organization_id = p_organization_id;
     --
     L_ShortParam_rec	L_ShortParam_csr%ROWTYPE;
     --
     CURSOR L_ShortTemp_csr IS
	-- WIP component planner
	SELECT DISTINCT FU.user_name	user_name
	FROM   mtl_planners MP,
	       mtl_system_items MSI,
	       fnd_user FU,
	       mtl_short_chk_temp MSCT
	WHERE  L_ShortParam_rec.wip_notif_comp_planner_flag = 1
	AND    MSCT.object_type 	IN (1,2)
	AND    MSCT.seq_num     	= p_seq_num
        AND    MSCT.inventory_item_id 	= MSI.inventory_item_id
	AND    MSCT.organization_id	= MSI.organization_id
	AND    MSI.planner_code		= MP.planner_code
	AND    MSI.organization_id	= MP.organization_id
	AND    FU.employee_id		= MP.employee_id
	-- WIP assembly planner (discrete jobs)
	UNION
	SELECT DISTINCT FU.user_name
	FROM   mtl_planners MP,
	       mtl_system_items MSI,
	       wip_entities WE,
	       fnd_user FU,
	       mtl_short_chk_temp MSCT
	WHERE  L_ShortParam_rec.wip_notif_ass_planner_flag = 1
	AND    MSCT.seq_num     	= p_seq_num
	AND    MSCT.object_type 	= 1
	AND    MSCT.object_id		= WE.wip_entity_id
	AND    WE.primary_item_id   	= MSI.inventory_item_id
	AND    MSCT.organization_id	= MSI.organization_id
	AND    MSI.planner_code		= MP.planner_code
	AND    MSI.organization_id	= MP.organization_id
	AND    FU.employee_id		= MP.employee_id
	-- WIP assembly planner (repetitive schedules)
	UNION
	SELECT DISTINCT FU.user_name
	FROM   mtl_planners MP,
	       mtl_system_items MSI,
	       wip_repetitive_schedules WRS,
	       wip_repetitive_items WRI,
	       fnd_user FU,
	       mtl_short_chk_temp MSCT
	WHERE  L_ShortParam_rec.wip_notif_ass_planner_flag = 1
	AND    MSCT.seq_num     	= p_seq_num
	AND    MSCT.object_type 	= 2
	AND    MSCT.object_id		= WRS.repetitive_schedule_id
	AND    WRI.wip_entity_id        = WRS.wip_entity_id
        AND    WRI.line_id              = WRS.line_id
        AND    WRI.organization_id      = MSCT.organization_id
	AND    WRI.primary_item_id   	= MSI.inventory_item_id
	AND    MSCT.organization_id	= MSI.organization_id
	AND    MSI.planner_code		= MP.planner_code
	AND    MSI.organization_id	= MP.organization_id
	AND    FU.employee_id		= MP.employee_id
	-- WIP component buyer
	UNION
	SELECT DISTINCT FU.user_name
	FROM   mtl_system_items MSI,
	       fnd_user FU,
	       mtl_short_chk_temp MSCT
	WHERE  L_ShortParam_rec.wip_notif_comp_buyer_flag = 1
	AND    MSCT.seq_num     	= p_seq_num
	AND    MSCT.object_type 	IN (1,2)
        AND    MSCT.inventory_item_id 	= MSI.inventory_item_id
	AND    MSCT.organization_id	= MSI.organization_id
	AND    FU.employee_id		= MSI.buyer_id
	-- WIP discrete job creator
	UNION
	SELECT DISTINCT FU.user_name
	FROM   fnd_user FU,
	       wip_discrete_jobs WDJ,
	       mtl_short_chk_temp MSCT
	WHERE  L_ShortParam_rec.wip_notif_job_creator_flag = 1
	AND    MSCT.seq_num		= p_seq_num
	AND    MSCT.object_type 	= 1
	AND    MSCT.object_id   	= WDJ.wip_entity_id
	AND    MSCT.organization_id     = WDJ.organization_id
	AND    WDJ.created_by		= FU.user_id
	-- WIP repetitive schedule creator
	UNION
        SELECT DISTINCT FU.user_name
        FROM   fnd_user FU,
	       wip_repetitive_schedules WRS,
               mtl_short_chk_temp MSCT
        WHERE  L_ShortParam_rec.wip_notif_job_creator_flag = 1
        AND    MSCT.seq_num     	= p_seq_num
        AND    MSCT.object_type 	= 2
        AND    MSCT.object_id   	= WRS.repetitive_schedule_id
	AND    MSCT.organization_id	= WRS.organization_id
	AND    WRS.created_by   	= FU.user_id
	-- OE item planner
 	UNION
	SELECT DISTINCT FU.user_name	user_name
	FROM   mtl_planners MP,
	       mtl_system_items MSI,
	       fnd_user FU,
	       mtl_short_chk_temp MSCT
	WHERE  L_ShortParam_rec.oe_notif_item_planner_flag = 1
	AND    MSCT.object_type = 4
	AND    MSCT.seq_num     	= p_seq_num
        AND    MSCT.inventory_item_id 	= MSI.inventory_item_id
	AND    MSCT.organization_id	= MSI.organization_id
	AND    MSI.planner_code		= MP.planner_code
	AND    MSI.organization_id	= MP.organization_id
	AND    FU.employee_id		= MP.employee_id
	-- OE sales order creator
	UNION
	SELECT DISTINCT FU.user_name
	FROM   fnd_user FU,
	       oe_order_headers SH,
	       mtl_short_chk_temp MSCT
	WHERE  L_ShortParam_rec.oe_notif_so_creator_flag = 1
	AND    MSCT.seq_num     	= p_seq_num
        AND    MSCT.object_type 	= 4
	AND    MSCT.object_id		= SH.header_id
	AND    SH.created_by		= FU.user_id;
     --
  BEGIN

     -- MOAC : Added multi org init procedure as secured synonym
     -- oe_order_headers requires OU context.

     MO_GLOBAL.init('INV');

     -- MOAC : Check if the specified operating unit exists in
     -- the session's access control list.
     /*Bug#6509349 :We should pass operating unit org id and
        not the organization id picked from MMT.Getting
	Operating unit organizaiton id from below query.*/
     Begin
        SELECT hoi.org_information3 into l_ou_org_id
	FROM hr_organization_information hoi
        WHERE hoi.org_information_context ='Accounting Information'
        AND hoi.organization_id = p_organization_id ;

     EXCEPTION
        WHEN OTHERS THEN
        inv_log_util.trace(sqlerrm,'INV_ShortStatement_PVT.sendnotifications',9);
        x_return_status := FND_API.G_RET_STS_ERROR;
        RAISE FND_API.G_EXC_ERROR;
     END ;

    -- l_org_id := MO_GLOBAL.get_valid_org(p_organization_id);
       l_org_id := MO_GLOBAL.get_valid_org(l_ou_org_id); --Bug#6509349

     IF l_org_id is NULL THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- MOAC : Sets the application context for the current org
     -- if the specified operating unit exists in
     -- the session's access control list.

     MO_GLOBAL.set_policy_context('S',l_org_id);

     -- Standard Call to check for call compatibility
     IF NOT FND_API.Compatible_API_Call(l_api_version
           , p_api_version
           , l_api_name
           , G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
     --
     -- Initialize message list if p_init_msg_list is set to true
     IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
     END IF;
     --
     -- Initialize API return status to access
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     --
     -- Get item concatenated segments
     OPEN L_Item_crs;
     FETCH L_Item_crs INTO L_item_conc_segments;
     CLOSE L_Item_crs;
     --
     -- Get organization code
     OPEN L_Org_crs;
     FETCH L_Org_crs INTO L_organization_code;
     CLOSE L_Org_crs;
     --
     -- Get the notification recipients from the shortage parameter
     OPEN L_ShortParam_csr ( p_organization_id );
     FETCH L_ShortParam_csr INTO L_ShortParam_rec;
     IF L_ShortParam_csr%NOTFOUND THEN
	FND_MESSAGE.SET_NAME('INV','INV_SHORT_PARAMETER_NOT_FOUND');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
     END IF;
     CLOSE L_ShortParam_csr;
     --
     -- Set message name according to input parameter
     IF p_notification_type = 'R' THEN
	L_msg_name := 'INV_SHORTAGE_EXISTS';
     ELSE
	L_msg_name := 'INV_SHORTAGE_EXISTS_REPORT';
     END IF;
     --
     -- Go through the shortage temp table and call the wf message api to
     -- send the shortage message
     --
     OPEN L_ShortTemp_csr;
     LOOP
     	FETCH L_ShortTemp_csr INTO L_user_name;
	EXIT WHEN L_ShortTemp_csr%NOTFOUND;
     	-- Call the send message wf procedure
     	L_notification_id := WF_NOTIFICATION.Send (
				role		=> L_user_name,
				msg_type	=> 'INVSHMSG',
				msg_name	=> L_msg_name,
				due_date	=> NULL,
				callback	=> NULL,
				context		=> NULL,
				send_comment	=> NULL );
     	-- Set message attributes
     	-- Open Form Command for View shortage form
-- Added call to wf_notification.denormalize_notification for bug 3101169
     	WF_NOTIFICATION.SetAttrText (
		nid	=> L_notification_id,
		aname	=> 'OPEN_FORM_COMMAND',
		avalue	=> 'INV_INVSHINQ:ORG_ID="'||'&'||
		    'ORGANIZATION_ID" ITEM_ID="'||'&'||'INVENTORY_ITEM_ID"' );
     	-- Item id
     	WF_NOTIFICATION.SetAttrNumber (
  		nid	=> L_notification_id,
		aname	=> 'INVENTORY_ITEM_ID',
		avalue	=> p_inventory_item_id );
        WF_NOTIFICATION.Denormalize_Notification(L_notification_id);
     	-- Item concatenated segments
     	WF_NOTIFICATION.SetAttrText (
		nid     => L_notification_id,
        	aname   => 'INVENTORY_ITEM_CONC_SEGMENTS',
		avalue  => L_item_conc_segments );
        WF_NOTIFICATION.Denormalize_Notification(L_notification_id);
     	-- Organization id
     	WF_NOTIFICATION.SetAttrNumber (
        	nid     => L_notification_id,
        	aname   => 'ORGANIZATION_ID',
        	avalue  => p_organization_id );
         WF_NOTIFICATION.Denormalize_Notification(L_notification_id);
     	-- Organization code
     	WF_NOTIFICATION.SetAttrText (
		nid     => L_notification_id,
        	aname   => 'ORGANIZATION_CODE',
		avalue  => L_organization_code );
        WF_NOTIFICATION.Denormalize_Notification(L_notification_id);
     	--
     END LOOP;
     CLOSE L_ShortTemp_csr;
     -- Standard check of p_commit
     IF FND_API.to_Boolean(p_commit) THEN
        COMMIT;
     END IF;
     -- Standard call to get message count and if count is 1, get message info
     FND_MSG_PUB.Count_And_Get
     (p_count => x_msg_count
        , p_data => x_msg_data);
  EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
     --
     x_return_status := FND_API.G_RET_STS_ERROR;
     --
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
        , p_data => x_msg_data);
     --
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
        , p_data => x_msg_data);
     --
     WHEN OTHERS THEN
     --
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;
     --
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
        , p_data => x_msg_data);
  END;
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
  )
IS
     L_api_version 	CONSTANT NUMBER := 1.0;
     L_api_name 	CONSTANT VARCHAR2(30) := 'PurgeTempTable';
  BEGIN
     -- Standard Call to check for call compatibility
     IF NOT FND_API.Compatible_API_Call(l_api_version
           , p_api_version
           , l_api_name
           , G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;
     --
     -- Initialize message list if p_init_msg_list is set to true
     IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
     END IF;
     --
     -- Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     --
     -- Purge all rows with the given sequence number
     DELETE FROM mtl_short_chk_temp
     WHERE  seq_num = p_seq_num;
     --
     -- Standard check of p_commit
     IF FND_API.to_Boolean(p_commit) THEN
        COMMIT;
     END IF;
     -- Standard call to get message count and if count is 1, get message info
     FND_MSG_PUB.Count_And_Get
     (p_count => x_msg_count
        , p_data => x_msg_data);
  EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
     --
     x_return_status := FND_API.G_RET_STS_ERROR;
     --
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
        , p_data => x_msg_data);
     --
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
        , p_data => x_msg_data);
     --
     WHEN OTHERS THEN
     --
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --
     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
     END IF;
     --
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
        , p_data => x_msg_data);
  END;
  -- Start OF comments
  -- API name  : PrepareMessage
  -- TYPE      : Private
  -- Pre-reqs  : None
  -- FUNCTION  : This API prepares a shortage message for the given item/org
  -- 		   and pushes it onto the message stack.  After calling this
  --		   API, caller should call fnd_message.retrieve and
  --		   fnd_message.show in order to display the message.
  -- Parameters:
  --     IN    :
  --  p_inventory_item_id      IN  NUMBER (required)
  --    The inventory item ID which a shortage message should be created for
  --
  --  p_organization_id   IN  NUMBER (required)
  --    The inventory organization ID in which the shortage occurred
  -- END OF comments
PROCEDURE PrepareMessage (
  p_inventory_item_id	IN NUMBER,
  p_organization_id	IN NUMBER
)
IS
  L_item_conc_segments	mtl_system_items_kfv.concatenated_segments%TYPE;
  BEGIN
    BEGIN
      SELECT concatenated_segments
      INTO L_item_conc_segments
      FROM mtl_system_items_kfv
      WHERE organization_id = p_organization_id
      AND inventory_item_id = p_inventory_item_id;
    EXCEPTION
      WHEN OTHERS THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;
    fnd_message.set_name('INV','INV_SHORTAGE_EXISTS');
    fnd_message.set_token('ITEM',L_item_conc_segments);
  EXCEPTION
    WHEN OTHERS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END PrepareMessage;
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
) RETURN NUMBER IS
  l_open_qty       NUMBER;
  l_qty_allocated  NUMBER;
  l_num_days       NUMBER;
BEGIN
  IF TRUNC(p_first_unit_start_date) > TRUNC(sysdate) THEN
     RETURN 0;
  END IF;

  BEGIN
     SELECT ( NVL(bcd2.seq_num, (bcd2.next_seq_num - 1))
              - NVL(bcd1.seq_num, bcd1.next_seq_num)
              + 1
            )
       INTO l_num_days
       FROM mtl_parameters  mp
          , bom_calendar_dates  bcd1
          , bom_calendar_dates  bcd2
      WHERE mp.organization_id = p_organization_id
        AND bcd1.calendar_code = mp.calendar_code
        AND bcd1.exception_set_id = mp.calendar_exception_set_id
        AND bcd1.calendar_date = TRUNC(p_first_unit_start_date)
        AND bcd2.calendar_code = mp.calendar_code
        AND bcd2.exception_set_id = mp.calendar_exception_set_id
        AND bcd2.calendar_date = TRUNC(sysdate);
  EXCEPTION
     WHEN OTHERS THEN
        inv_log_util.trace(sqlerrm,'INV_ShortStatement_PVT.get_rep_curr_open_qty',9);
        l_num_days := 0;
  END;

  IF NVL(l_num_days,0) <= 0 THEN
     RETURN 0;
  END IF;

  l_num_days := LEAST(l_num_days, NVL(p_processing_work_days,0));

  l_qty_allocated :=
    wip_picking_pub.quantity_allocated( p_wip_entity_id          => p_wip_entity_id
                                      , p_operation_seq_num      => p_operation_seq_num
                                      , p_organization_id        => p_organization_id
                                      , p_inventory_item_id      => p_inventory_item_id
                                      , p_repetitive_schedule_id => p_repetitive_schedule_id
                                      , p_quantity_issued        => p_quantity_issued
                                      );

  SELECT LEAST( ( wro.required_quantity *
                  DECODE( NVL(wp.include_component_yield,1)
                        , 2, NVL(wro.component_yield_factor,1)
                        , 1
                        )
                  - p_quantity_issued
                  - NVL(l_qty_allocated,0)
                  - NVL( wo.CUMULATIVE_SCRAP_QUANTITY * wro.QUANTITY_PER_ASSEMBLY
                         / DECODE( NVL(wp.include_component_yield,1)
                                 , 2, 1
                                 , NVL(wro.component_yield_factor,1)
                                 )
                       , 0
                       )
                )
              , ( wrs.daily_production_rate * wro.quantity_per_assembly * l_num_days)
                + NVL(wro.quantity_backordered, 0)
              )
    INTO l_open_qty
    FROM wip_parameters              wp
       , wip_requirement_operations  wro
       , wip_operations              wo
       , wip_repetitive_schedules    wrs
   WHERE wp.organization_id         = p_organization_id
     AND wro.organization_id        = wp.organization_id
     AND wro.wip_entity_id          = p_wip_entity_id
     AND wro.repetitive_schedule_id = p_repetitive_schedule_id
     AND wro.operation_seq_num      = p_operation_seq_num
     AND wro.inventory_item_id      = p_inventory_item_id
     AND wro.required_quantity      > (wro.quantity_issued + NVL(l_qty_allocated,0))
     AND wro.repetitive_schedule_id = wo.repetitive_schedule_id (+)
     AND wro.operation_seq_num      = wo.operation_seq_num (+)
     AND wrs.organization_id        = wro.organization_id
     AND wrs.wip_entity_id          = wro.wip_entity_id
     AND wrs.repetitive_schedule_id = wro.repetitive_schedule_id;

  RETURN NVL(l_open_qty,0);

EXCEPTION
  WHEN OTHERS THEN
    inv_log_util.trace(sqlerrm,'INV_ShortStatement_PVT.get_rep_curr_open_qty',9);
    RETURN 0;
END get_rep_curr_open_qty;

END INV_ShortCheckExec_PVT;

/
