--------------------------------------------------------
--  DDL for Package Body OE_CONFIG_TSO_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_CONFIG_TSO_GRP" AS
/* $Header: OEXGTSOB.pls 120.3 2005/10/27 17:25:16 akurella noship $ */

-------------------------------------------------------
-- Local Variables and Procedures
-------------------------------------------------------
G_PKG_NAME CONSTANT VARCHAR2(30) := 'OE_CONFIG_TSO_GRP';

PROCEDURE Print_Time (p_msg IN VARCHAR2);

PROCEDURE Print_Time (p_msg IN VARCHAR2)
IS
  l_time VARCHAR2(100);
  l_debug_level CONSTANT NUMBER := OE_DEBUG_PUB.G_DEBUG_LEVEL;
BEGIN
  l_time := to_char(new_time(sysdate,'PST','EST'),'DD-MON-YY HH24:MI:SS');
  IF l_debug_level > 0 THEN
     OE_DEBUG_PUB.Add (p_msg||':'||l_time,1);
  END IF;
END Print_Time;


-----------------------------------------------------
-- Group APIs section
-----------------------------------------------------

/* API: Get_MACD_Action_Mode
 *
 * Type: Group API, only for Oracle products internal use
 *
 * Input parameters: p_top_model_line_id and p_line_id both are NUMBER and
 * indicate the line_id of the line for which we need the MACD_Action_Mode
 *
 * Output Parameters: x_config_mode NUMBER indicates the MACD action mode
 * and x_return_status VARCHAR2 which indicates success/error
 *
 * Validation: Performs a check whether the line passed belongs to a
 * container model by calling OE_CONFIG_TSO_PVT.Is_Part_Of_Container_Model
 * Only if it is part of a container model will it call the MACD_Action_Mode
 * API. If it is not a part of container model, then it returns with the
 * following values: x_config_mode = NULL and x_return_status = ERROR
 *
 * There are no error messages that we populate so it is upto the caller to
 * examine the output parameters and take action if there is an error. (The
 * reason we do not populate error messages is because the passed in line may
 * not be part of a container model or the top model line may be passed in
 * as child line etc. So the number of error messages required would be too
 * many.)
 *
 * Assumption: line being passed is already in the in oe_order_lines_all table.
 *
 * Description of API internals:
 * The Private API called by this procedure uses different SQLs depending
 * on what is the input parameter
 * It goes in order of p_top_model_line_id and p_line_id
 *
 * As mentioned above, the config mode would depend upon what is the input
 * parameter.
 *
 * I. p_top_model_line_id (The API looks for this first)
 *
 * The API checks for a baseline revision in the CZ/OM tables and if it
 * is not found, the config_mode is returned as 1 (new configuration).
 * If a baseline revision is found in the CZ/OM tables, the config_mode is
 * updated to 3. It then checks for a change made to line in configurator and
 * if a delta is found, the config_mode is updated to 4 and returned. If no
 * delta is found, the config_mode is retained at 3 and returned.
 *
 * II. p_line_id (If no top_model_line_id is passed, then API checks for this)
 *
 * The API checks for a baseline revision in the CZ/OM tables and if no
 * baseline exists, config_mode is returned as 1 (new configuration).
 * If a baseline revision for the line is found in CZ/OM tables, config_mode
 * is set to 3. It then proceeds to check for a change made to line in
 * configurator. If such a delta exists, the config_mode is set to 2 and
 * returned. Else value of 3 is retained and returned.
 *
 * If the config_mode is returned as NULL, it is to be interpreted that there
 * is some error (either the line is not part of container model or OTHERS
 * exception in OE_CONFIG_TSO_PVT.Get_MACD_Action_Mode)
 *
 * IMPORTANT: If the correct mode is to be obtained, then a top model line
 * must be passed ONLY into p_top_model_line_id (and not into p_line_id)
 * Similarly, for a child line of a container model, the line_id should
 * be passed ONLY into p_line_id (and not into p_top_model_line_id). Since SQL
 * goes in order of top_model_line_id and then line_id, when a child line
 * is being passed, the child line's line_id should be passed to p_line_id
 * and the p_top_model_line_id should necessarily be NULL
 *
 */

PROCEDURE Get_MACD_Action_Mode
(
   p_line_id           IN  NUMBER := NULL
  ,p_top_model_line_id IN  NUMBER := NULL
  ,x_config_mode       OUT NOCOPY NUMBER
  ,x_return_status     OUT NOCOPY VARCHAR2
)
IS
  l_debug_level CONSTANT NUMBER := OE_DEBUG_PUB.G_DEBUG_LEVEL;
  l_top_container_model  VARCHAR2(1);
  l_part_of_container    VARCHAR2(1);
   -- MOAC
  l_org_id               NUMBER;
  l_current_access_mode  VARCHAR2(1);
  l_current_org_id       NUMBER;
  l_reset_policy         BOOLEAN := FALSE;
BEGIN
  Print_Time ('Entering OE_CONFIG_TSO_GRP.Get_MACD_Action_Mode..');
  IF l_debug_level > 0 THEN
     OE_DEBUG_PUB.Add('LineID:'||p_line_id,3);
     OE_DEBUG_PUB.Add('TopModelLineID:'||p_top_model_line_id,3);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS; --Nocopy changes

  -- MOAC change
  -- Check if org context has been set before doing any process
  -- Set the context if not already or if the org on the line_id is different
  -- than the org previously set.

  l_current_access_mode := mo_global.Get_access_mode(); -- MOAC
  l_current_org_id := mo_global.get_current_org_id();

  BEGIN


   SELECT org_id
   INTO l_org_id
   FROM oe_order_lines_all
   WHERE line_id = p_line_id;


  EXCEPTION

   WHEN OTHERS THEN
     IF l_debug_level > 0 THEN
       OE_DEBUG_PUB.Add('Null org id' || sqlerrm,3);
     END IF;
     RAISE FND_API.G_EXC_ERROR;
  END;

  IF l_debug_level  > 0 THEN
         oe_debug_pub.add('SO Org Id: ' ||l_org_id , 1 ) ;
  END IF;


  IF nvl(l_current_org_id,-99) <> l_org_id THEN
       Mo_Global.Set_Policy_Context (p_access_mode => 'S', p_org_id => l_org_id);
       l_reset_policy := TRUE;
  END IF;


  OE_CONFIG_TSO_PVT.Is_Part_Of_Container_Model
  (  p_line_id             => p_line_id
    ,p_top_model_line_id   => p_top_model_line_id
    ,x_top_container_model => l_top_container_model
    ,x_part_of_container   => l_part_of_container
  );

  IF l_part_of_container = 'N' THEN
     x_config_mode := NULL;
     x_return_status := FND_API.G_RET_STS_ERROR;
     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('ERR: Only part of container models can use API',1);
   	    OE_DEBUG_PUB.Add('Setting Return Status:'||x_return_status,1);
	    OE_DEBUG_PUB.Add('Config Mode:'||x_config_mode,2);
     END IF;
     Print_Time ('Exiting OE_CONFIG_TSO_GRP.Get_MACD_Action_Mode..');
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  --following code is executed only if line is part of container model
  IF l_debug_level > 0 THEN
     OE_DEBUG_PUB.Add('L_PartOfContainer:'||l_part_of_container,3);
     OE_DEBUG_PUB.Add('Eligible to call TSO_PVT.Get_MACD_Action_Mode',2);
  END IF;
  OE_CONFIG_TSO_PVT.Get_MACD_Action_Mode
  (  p_line_id           => p_line_id
    ,p_top_model_line_id => p_top_model_line_id
    ,x_config_mode       => x_config_mode
    ,x_return_status     => x_return_status
  );
  IF l_debug_level > 0 THEN
     OE_DEBUG_PUB.Add('Return Status:'||x_return_status,1);
     OE_DEBUG_PUB.Add('Config Mode:'||x_config_mode,2);
  END IF;

  IF l_reset_policy THEN -- MOAC
      Mo_Global.Set_Policy_Context (p_access_mode => l_current_access_mode,  p_org_id => l_current_org_id);
  END IF;
  Print_Time ('Exiting OE_CONFIG_TSO_GRP.Get_MACD_Action_Mode..');

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN

    IF l_reset_policy THEN -- MOAC
      Mo_Global.Set_Policy_Context (p_access_mode => l_current_access_mode,  p_org_id => l_current_org_id);
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_config_mode := NULL;
    IF l_debug_level > 0 THEN
       OE_DEBUG_PUB.Add('Expected Exception in TSO_GRP.Get_MACD_Action_Mode'
                          ||sqlerrm,1);
    END IF;


  WHEN OTHERS THEN
    IF l_reset_policy THEN -- MOAC
      Mo_Global.Set_Policy_Context (p_access_mode => l_current_access_mode,  p_org_id => l_current_org_id);
    END IF;
    x_config_mode := NULL;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF l_debug_level > 0 THEN
       OE_DEBUG_PUB.Add('Other Exception in TSO_GRP.Get_MACD_Action_Mode'
                          ||sqlerrm,1);
    END IF;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       OE_MSG_PUB.Add_Exc_Msg
       (  G_PKG_NAME
         ,'Get_MACD_Action_Mode' );
    END IF;

END Get_MACD_Action_Mode;

Procedure Process_MACD_Order
(P_api_version_number     IN  NUMBER,
 P_sold_to_org_id         IN  NUMBER,
 P_x_header_id            IN  OUT  NOCOPY NUMBER,
 P_MACD_Action            IN  VARCHAR2,
 P_Instance_Tbl           IN  csi_datastructures_pub.instance_cz_tbl,
 P_Extended_Attrib_Tbl    IN  csi_datastructures_pub.ext_attrib_values_tbl,
 X_container_line_id      OUT NOCOPY NUMBER,
 X_number_of_containers   OUT NOCOPY NUMBER,
 x_return_status          OUT NOCOPY VARCHAR2,
 x_msg_count              OUT NOCOPY VARCHAR2,
 x_msg_data               OUT NOCOPY VARCHAR2)
IS
  l_debug_level CONSTANT NUMBER := OE_DEBUG_PUB.G_DEBUG_LEVEL;
  l_line_tbl             OE_ORDER_PUB.line_tbl_type;
  l_number_of_containers NUMBER;
  l_org_id               NUMBER;
BEGIN
  Print_Time ('Entering OE_CONFIG_TSO_GRP.Process_MACD_Order..');


  -- Main Logic
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- MOAC change
  -- Check if org context has been set before doing any process
  -- If there is no org context set, we stop calling group process order API
  -- and raise an error though we don't do any validation for the org_id.

  l_org_id := MO_GLOBAL.get_current_org_id;
  IF (l_org_id IS NULL OR l_org_id = FND_API.G_MISS_NUM) THEN

       IF l_debug_level > 0 THEN
         OE_DEBUG_PUB.Add('Null org id',3);
       END IF;

       FND_MESSAGE.set_name('FND','MO_ORG_REQUIRED');
       OE_MSG_PUB.Add;
       RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF l_debug_level > 0 THEN
     OE_DEBUG_PUB.Add('Return Status:'||x_return_status,1);
     OE_DEBUG_PUB.Add('Org Id:' || l_org_id,1);
  END IF;

  Oe_config_tso_pvt.Process_MACD_Order
   (P_API_VERSION_NUMBER     => P_API_VERSION_NUMBER,
    P_caller                 => 'G', -- Group
    P_sold_to_org_id         => p_sold_to_org_id,
    P_x_header_id            => p_x_header_id,
    P_MACD_Action            => p_macd_action,
    P_Instance_Tbl           => p_instance_tbl,
    P_x_Line_Tbl             => l_line_tbl,
    P_Extended_Attrib_Tbl    => P_Extended_Attrib_Tbl,
    X_container_line_id      => x_container_line_id,
    X_number_of_containers   => X_number_of_containers,
    X_return_status          => x_return_status,
    X_msg_count              => x_msg_count,
    X_msg_data               => x_msg_data);

  Print_Time ('Exiting OE_CONFIG_TSO_GRP.Process_MACD_Order..');

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        --  Get message count and data

        OE_MSG_PUB.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF l_debug_level > 0 THEN
       OE_DEBUG_PUB.Add('Other Exception in TSO_GRP.Process_MACD_Order'
                          ||sqlerrm,1);
    END IF;
    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       OE_MSG_PUB.Add_Exc_Msg
       (  G_PKG_NAME
         ,'Process_MACD_Order' );
    END IF;

END Process_MACD_Order;

END OE_CONFIG_TSO_GRP;

/
