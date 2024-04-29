--------------------------------------------------------
--  DDL for Package Body INV_SHORTCHECKEXEC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_SHORTCHECKEXEC_PUB" AS
/* $Header: INVSEPUB.pls 120.1 2005/06/21 05:36:13 appldev ship $*/
G_PKG_NAME              CONSTANT VARCHAR2(30) := 'INV_ShortCheckExec_PUB';
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
  --  x_check_result	 OUT VARCHAR2
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
  )
IS
     L_api_version 	CONSTANT NUMBER := 1.0;
     L_api_name 	CONSTANT VARCHAR2(30) := 'ExecCheck';
     L_Object_Exists	VARCHAR2(1);
     --
     CURSOR L_Item_crs ( p_organization_id    IN NUMBER,
		         p_inventory_item_id  IN NUMBER ) IS
	SELECT 'X'
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
     -- Validate p_inventory_item_id if not null or statement type is summary
     IF p_inventory_item_id IS NOT NULL OR p_sum_detail_flag = 2 THEN
        OPEN L_Item_crs ( p_organization_id,
	                  p_inventory_item_id );
        FETCH L_Item_crs INTO L_Object_Exists;
        IF L_Item_crs%NOTFOUND THEN
	   FND_MESSAGE.SET_NAME('INV','INV_SHORT_ITEM_NOT_FOUND');
	   FND_MESSAGE.SET_TOKEN('INVENTORY_ITEM_ID',TO_CHAR(p_inventory_item_id));
	   FND_MSG_PUB.Add;
	   RAISE FND_API.G_EXC_ERROR;
        END IF;
        CLOSE L_Item_crs;
     END IF;
     --
     INV_ShortCheckExec_PVT.ExecCheck (
  	p_api_version		=> 1.0,
  	p_init_msg_list 	=> p_init_msg_list,
  	p_commit 		=> p_commit,
  	x_return_status		=> x_return_status,
  	x_msg_count		=> x_msg_count,
  	x_msg_data		=> x_msg_data,
  	p_sum_detail_flag	=> p_sum_detail_flag,
  	p_organization_id	=> p_organization_id,
  	p_inventory_item_id	=> p_inventory_item_id,
  	p_comp_att_qty_flag	=> p_comp_att_qty_flag,
	p_primary_quantity	=> p_primary_quantity,
  	x_seq_num		=> x_seq_num,
  	x_check_result		=> x_check_result
  	);
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
  )
IS
     L_api_version 	CONSTANT NUMBER := 1.0;
     L_api_name 	CONSTANT VARCHAR2(30) := 'CheckPrerequisites';
     L_Object_Exists	VARCHAR2(1);
     --
     CURSOR L_Item_crs ( p_organization_id    IN NUMBER,
		         p_inventory_item_id  IN NUMBER ) IS
	SELECT 'X'
	FROM   mtl_system_items
	WHERE  inventory_item_id = p_inventory_item_id
	AND    organization_id   = p_organization_id;
     --
     CURSOR L_TransType_crs ( p_transaction_type_id  IN NUMBER ) IS
	SELECT 'X'
        FROM   mtl_transaction_types
	WHERE  transaction_type_id = p_transaction_type_id;
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
     -- Validate p_inventory_item_id
     OPEN L_Item_crs ( p_organization_id,
         	       p_inventory_item_id );
     FETCH L_Item_crs INTO L_Object_Exists;
     IF L_Item_crs%NOTFOUND THEN
        FND_MESSAGE.SET_NAME('INV','INV_ITEM_NOT_FOUND');
	FND_MESSAGE.SET_TOKEN('INVENTORY_ITEM_ID',TO_CHAR(p_inventory_item_id));
	FND_MSG_PUB.Add;
	RAISE FND_API.G_EXC_ERROR;
     END IF;
     CLOSE L_Item_crs;
     --
     -- Validate p_transaction_type_id
     IF p_transaction_type_id IS NOT NULL THEN
        OPEN L_TransType_crs ( p_transaction_type_id );
        FETCH L_TransType_crs INTO L_Object_Exists;
        IF L_TransType_crs%NOTFOUND THEN
           FND_MESSAGE.SET_NAME('INV','INV_TRANSACTION_TYPE_NOT_FOUND');
	   FND_MESSAGE.SET_TOKEN('TRANSACTION_TYPE_ID',
			         TO_CHAR(p_transaction_type_id));
           FND_MSG_PUB.Add;
           RAISE FND_API.G_EXC_ERROR;
        END IF;
        CLOSE L_TransType_crs;
     END IF;
     --
     INV_ShortCheckExec_PVT.CheckPrerequisites (
  	p_api_version		=> 1.0,
  	p_init_msg_list 	=> p_init_msg_list,
  	x_return_status		=> x_return_status,
  	x_msg_count		=> x_msg_count,
  	x_msg_data		=> x_msg_data,
  	p_sum_detail_flag	=> p_sum_detail_flag,
  	p_organization_id	=> p_organization_id,
  	p_inventory_item_id	=> p_inventory_item_id,
	p_transaction_type_id	=> p_transaction_type_id,
  	x_check_result		=> x_check_result
  	);
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
     -- Initialize API return status to access
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     --
     INV_ShortCheckExec_PVT.PurgeTempTable (
  	p_api_version 		=> 1.0,
  	p_init_msg_list 	=> p_init_msg_list,
  	p_commit 		=> p_commit,
  	x_return_status		=> x_return_status,
  	x_msg_count		=> x_msg_count,
  	x_msg_data		=> x_msg_data,
  	p_seq_num		=> p_seq_num
     );
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
END INV_ShortCheckExec_PUB;

/
