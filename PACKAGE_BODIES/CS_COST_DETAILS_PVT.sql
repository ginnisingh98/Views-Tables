--------------------------------------------------------
--  DDL for Package Body CS_COST_DETAILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_COST_DETAILS_PVT" AS
/* $Header: csxvcstb.pls 120.22.12010000.1 2008/07/24 18:46:41 appldev ship $ */

   L_RECALC_COST                VARCHAR2(1):='N';
   l_item_changed               VARCHAR2(1):='N';
   L_TRANSACTION_TYPE_CHANGED   VARCHAR(1):='N';

   RECORD_LOCK_EXCEPTION        EXCEPTION ;
   G_WARNING                    EXCEPTION ;
   PRAGMA EXCEPTION_INIT(RECORD_LOCK_EXCEPTION,-0054);

--local Procedures and Functions
PROCEDURE Validate_Who_Info(P_API_NAME       IN            VARCHAR2,
                            P_USER_ID        IN            NUMBER,
                            P_LOGIN_ID       IN            NUMBER,
                            X_RETURN_STATUS  OUT NOCOPY    VARCHAR2
	                    );

FUNCTION  Do_Cost_Line_Exist(p_api_name      IN          VARCHAR2,
                             p_cost_id       IN          NUMBER ,
                             x_return_status OUT NOCOPY  VARCHAR2
	                    )RETURN VARCHAR2;

FUNCTION Do_charge_line_Exist(p_api_name       IN          VARCHAR2,
                              p_cost_id        IN          NUMBER ,
                              x_return_status  OUT NOCOPY  VARCHAR2
	                      )RETURN VARCHAR2;

PROCEDURE RECORD_IS_LOCKED_MSG(P_TOKEN_AN     IN  VARCHAR2);

PROCEDURE TO_NULL(p_cost_rec_in  IN         cs_cost_details_pub.Cost_Rec_Type,
                  p_cost_rec_out OUT NOCOPY cs_cost_details_pub.Cost_Rec_Type
		  );

PROCEDURE VALIDATE_COST_DETAILS
          (
		 p_api_name             IN            VARCHAR2,
		 pv_cost_rec            IN            CS_COST_DETAILS_PUB.COST_REC_TYPE,
		 p_validation_mode      IN            VARCHAR2,
		 p_user_id              IN            NUMBER,
		 p_login_id             IN            NUMBER,
		 x_cost_rec             OUT NOCOPY    CS_COST_DETAILS_PUB.COST_REC_TYPE,
		 x_msg_data             OUT NOCOPY    VARCHAR2,
		 x_msg_count            OUT NOCOPY    NUMBER,
		 x_return_status        OUT NOCOPY    VARCHAR2
	 );

/*Defaulting occurs for each MISSING attribute.
Attributes that are not explicitly passed by the user and therefore, retain the values
on the initialized record are defined as MISSING attributes. For e.g. all the number
fields on the entity records are initialized to the value FND_API.G_MISS_NUM and
thus, all number fields with this value are MISSING attributes.
*/

FUNCTION  Check_For_Miss ( p_param  IN  NUMBER ) RETURN NUMBER ;
FUNCTION  Check_For_Miss ( p_param  IN  VARCHAR2 ) RETURN VARCHAR2 ;
FUNCTION  Check_For_Miss ( p_param  IN  DATE ) RETURN DATE ;

--===============================
-- Add_Invalid_Argument_Msg
--===============================

PROCEDURE Add_Invalid_Argument_Msg( p_token_an	VARCHAR2,
                                    p_token_v	VARCHAR2,
	                            p_token_p	VARCHAR2
				  ) IS
BEGIN

   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.Set_Name('CS', 'CS_API_ALL_INVALID_ARGUMENT');
      FND_MESSAGE.Set_Token('API_NAME', p_token_an);
      FND_MESSAGE.Set_Token('VALUE', p_token_v);
      FND_MESSAGE.Set_Token('PARAMETER', p_token_p);
      FND_MSG_PUB.Add;
   END IF;

END Add_Invalid_Argument_Msg;

--===============================
-- Add_Null_Parameter_Msg
--===============================

PROCEDURE Add_Null_Parameter_Msg(p_token_an	VARCHAR2,
                                 p_token_np	VARCHAR2
				 ) IS

BEGIN

   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.Set_Name('CS', 'CS_API_ALL_NULL_PARAMETER');
      FND_MESSAGE.Set_Token('API_NAME', p_token_an);
      FND_MESSAGE.Set_Token('NULL_PARAM', p_token_np);
      FND_MSG_PUB.Add;
   END IF;

END Add_Null_Parameter_Msg;


--===============================
-- IS_COST_FLAG_CHECKED
--===============================
----This Function will check if the Create_Cost flag in the SAC setup Screen is checked

FUNCTION IS_COST_FLAG_CHECKED ( p_transaction_type_id	IN         NUMBER,
				x_msg_data		OUT NOCOPY VARCHAR2,
				x_msg_count		OUT NOCOPY NUMBER,
				x_return_status		OUT NOCOPY VARCHAR2
			       ) RETURN VARCHAR2 IS

   CURSOR c_transaction_type_id IS
   SELECT 1
   FROM   CS_transaction_types_b
   WHERE  transaction_type_id = p_transaction_type_id
          AND create_cost_flag = 'Y';

   lv_exists_flag VARCHAR2(1) := 'N';
   l_prog_name CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'is_cost_flag_checked';

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   FOR v_transaction_type_id IN c_transaction_type_id LOOP
      lv_exists_flag := 'Y';
   END LOOP;

RETURN lv_exists_flag;

EXCEPTION

WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   RETURN lv_exists_flag;

END IS_COST_FLAG_CHECKED;

--===============================
-- IS_CHARGE_LINE_TYPE_VALID
--===============================
--This Function will check if the Charge Line type is 'ACTUAL'.Cost Lines can be created only for 'ACTUALS'

FUNCTION IS_CHARGE_LINE_TYPE_VALID(p_charge_line_type IN VARCHAR2,
				   x_msg_data         OUT NOCOPY VARCHAR2,
				   x_msg_count        OUT NOCOPY NUMBER,
				   x_return_status    OUT NOCOPY VARCHAR2
				   )RETURN VARCHAR2 IS

  CURSOR c_charge_line_type (p_charge_line_type IN VARCHAR2) IS
  SELECT lookup_code
  FROM   fnd_lookup_values
  WHERE  lookup_type = 'CS_CHG_LINE_TYPE'
       AND lookup_code = p_charge_line_type;

  lv_exists_flag VARCHAR2(1) := 'N';
  l_prog_name CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'is_charge_line_type_valid';

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   FOR v_charge_line_type IN c_charge_line_type(p_charge_line_type)
   LOOP
      IF v_charge_line_type.lookup_code ='ACTUAL' then
       lv_exists_flag := 'Y';
      END IF;
   END LOOP ;
   RETURN lv_exists_flag;

EXCEPTION

WHEN OTHERS THEN
   FND_MESSAGE.SET_NAME(G_APP_NAME, G_DB_ERROR);
   FND_MESSAGE.SET_TOKEN(token => G_PROG_NAME_TOKEN, value => l_prog_name);
   FND_MESSAGE.SET_TOKEN(token => G_SQLCODE_TOKEN, value => SQLCODE);
   FND_MESSAGE.SET_TOKEN(token => G_SQLERRM_TOKEN, value => SQLERRM);
   FND_MSG_PUB.add;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   RETURN lv_exists_flag;

END IS_CHARGE_LINE_TYPE_VALID;

--===============================
-- IS_INCIDENT_ID_VALID
--===============================
--This Funtion checks of the incident id is a valid one

FUNCTION IS_INCIDENT_ID_VALID (p_incident_id   IN         NUMBER,
			       x_msg_data      OUT NOCOPY VARCHAR2,
			       x_msg_count     OUT NOCOPY NUMBER,
			       x_return_status OUT NOCOPY VARCHAR2
			      )	RETURN VARCHAR2	IS

   CURSOR c_incident IS
   SELECT 'Y'
   FROM cs_incidents_all_b
   WHERE incident_id = p_incident_id;

   lv_exists_flag VARCHAR2(1) := 'N';
   l_prog_name CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'is_incident_id_valid';

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN c_incident;
   FETCH c_incident INTO lv_exists_flag;
   CLOSE c_incident;

   RETURN lv_exists_flag;

EXCEPTION

WHEN OTHERS THEN
   FND_MESSAGE.SET_NAME(G_APP_NAME, G_DB_ERROR);
   FND_MESSAGE.SET_TOKEN(token => G_PROG_NAME_TOKEN, value => l_prog_name);
   FND_MESSAGE.SET_TOKEN(token => G_SQLCODE_TOKEN, value => SQLCODE);
   FND_MESSAGE.SET_TOKEN(token => G_SQLERRM_TOKEN, value => SQLERRM);
   FND_MSG_PUB.add;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   RETURN lv_exists_flag;

END IS_INCIDENT_ID_VALID;

--===============================
-- IS_ESTIMATE_DETAIL_ID_VALID
--===============================
--This function checks if the Charge lineid is a valid one
FUNCTION IS_ESTIMATE_DETAIL_ID_VALID (p_estimate_detail_id IN         NUMBER,
				      x_msg_data           OUT NOCOPY VARCHAR2,
				      x_msg_count          OUT NOCOPY NUMBER,
				      x_return_status      OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

   CURSOR c_estimate_detail_id IS
   SELECT 1
   FROM   CS_ESTIMATE_DETAILS
   WHERE  estimate_detail_id = p_estimate_detail_id;

   lv_exists_flag VARCHAR2(1) := 'N';
   l_prog_name CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'is_estimate_detail_id_valid';

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

  FOR v_estimate_detail_id IN c_estimate_detail_id
  LOOP
    lv_exists_flag := 'Y';
  END LOOP;

  RETURN lv_exists_flag;

EXCEPTION

WHEN OTHERS THEN

   FND_MESSAGE.SET_NAME(G_APP_NAME, G_DB_ERROR);
   FND_MESSAGE.SET_TOKEN(token => G_PROG_NAME_TOKEN, value => l_prog_name);
   FND_MESSAGE.SET_TOKEN(token => G_SQLCODE_TOKEN, value => SQLCODE);
   FND_MESSAGE.SET_TOKEN(token => G_SQLERRM_TOKEN, value => SQLERRM);
   FND_MSG_PUB.add;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   RETURN lv_exists_flag;

END IS_ESTIMATE_DETAIL_ID_VALID;


--===============================
-- VALIDATE_SOURCE
--===============================
--This procedure checks if the Source is valid

PROCEDURE VALIDATE_SOURCE(p_api_name          IN   VARCHAR2,
			  p_source_code       IN   VARCHAR2,
			  p_source_id         IN   NUMBER,
			  x_source_id         OUT NOCOPY   NUMBER,
			  x_msg_data          OUT NOCOPY VARCHAR2,
			  x_msg_count         OUT NOCOPY NUMBER,
			  x_return_status     OUT NOCOPY   VARCHAR2) IS

   CURSOR c_val_ch_source(p_source_id IN NUMBER) IS
   SELECT incident_id
   FROM   CS_INCIDENTS_ALL_B
   WHERE  incident_id =p_source_id;

   CURSOR c_val_dr_source(p_source_id IN NUMBER) IS
   SELECT repair_line_id
   FROM   CSD_REPAIRS
   WHERE repair_line_id = p_source_id;

   CURSOR c_val_sd_source(p_source_id IN NUMBER) IS
   SELECT debrief_line_id
   FROM csf_debrief_lines
   WHERE debrief_line_id = p_source_id;

   lv_exists_flag  VARCHAR2(1) := 'N';
   l_ERRM VARCHAR2(100);

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;


-- THe 3 valid source codes are 'SR'(Estimate_Detail_id)
--                              'SD'(Debrief_Line_Id)
--				'DR'(Repair_Line_Id)
  IF p_source_code = 'SR' THEN

    IF  p_source_id IS NOT NULL THEN
      FOR v_val_ch_source IN c_val_ch_source(p_source_id) LOOP
	lv_exists_flag := 'Y';
	x_source_id := p_source_id;
      END LOOP;

      IF lv_exists_flag <> 'Y' THEN

	FND_MESSAGE.Set_Name('CS', 'CS_CHG_INVALID_SOURCE');
	FND_MESSAGE.SET_TOKEN('SOURCE_CODE', p_source_code);
	FND_MESSAGE.SET_TOKEN('SOURCE_ID', p_source_id);
	FND_MSG_PUB.Add;
	RAISE FND_API.G_EXC_ERROR;

      END IF;

    ELSE
      -- source_id cannot be cannot be null
      Add_Null_Parameter_Msg(p_api_name, 'p_source_id');
      RAISE FND_API.G_EXC_ERROR;
    END IF ;

  ELSIF p_source_code = 'DR' THEN
    IF  p_source_id  IS NOT NULL  THEN
      FOR v_val_dr_source IN c_val_dr_source(p_source_id) LOOP
	lv_exists_flag := 'Y';
	x_source_id := p_source_id;
      END LOOP;

      IF lv_exists_flag <> 'Y' THEN
	--RAISE FND_API.G_EXC_ERROR;
	--null;
	FND_MESSAGE.Set_Name('CS', 'CS_CHG_INVALID_SOURCE');
	FND_MESSAGE.SET_TOKEN('SOURCE_CODE', p_source_code);
	FND_MESSAGE.SET_TOKEN('SOURCE_ID', p_source_id);
	FND_MSG_PUB.Add;
	RAISE FND_API.G_EXC_ERROR;
      END IF;

    ELSE
      -- source_id cannot be cannot be null
      Add_Null_Parameter_Msg(p_api_name, 'p_source_id');
      RAISE FND_API.G_EXC_ERROR;
    END IF ;

  ELSIF p_source_code = 'SD' THEN
    IF  p_source_id  IS NOT NULL  THEN
      FOR v_val_dr_source IN c_val_sd_source(p_source_id) LOOP
	lv_exists_flag := 'Y';
	x_source_id := p_source_id;
      END LOOP;

      IF lv_exists_flag <> 'Y' THEN
	--RAISE FND_API.G_EXC_ERROR;
	--null;
	FND_MESSAGE.Set_Name('CS', 'CS_CHG_INVALID_SOURCE');
	FND_MESSAGE.SET_TOKEN('SOURCE_CODE', p_source_code);
	FND_MESSAGE.SET_TOKEN('SOURCE_ID', p_source_id);
	FND_MSG_PUB.Add;
	RAISE FND_API.G_EXC_ERROR;
      END IF;

    ELSE
      -- raise error as source_id cannot be cannot be null
      Add_Null_Parameter_Msg(p_api_name, 'p_source_id');
      RAISE FND_API.G_EXC_ERROR;
    END IF ;


  ELSE
    --Invalid source code passed. Raise an exception
    Add_Invalid_Argument_Msg(
      p_token_an => p_api_name,
      p_token_v  => p_source_code,
      p_token_p  => 'p_source_code');

	    RAISE FND_API.G_EXC_ERROR;
	  END IF ;

EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   fnd_msg_pub.count_and_get(p_count => x_msg_count
	     ,p_data  => x_msg_data);

WHEN NO_DATA_FOUND THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   IF  p_source_id IS NOT NULL THEN
      Add_Invalid_Argument_Msg
          (p_token_an => p_api_name,
	   p_token_v  => p_source_id,
	   p_token_p  => 'p_source_id');
   END IF ;

WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MESSAGE.Set_Name('CS', 'CS_CHG_INVALID_SOURCE');
   FND_MESSAGE.SET_TOKEN('SOURCE_CODE', p_source_code);
   FND_MESSAGE.SET_TOKEN('SOURCE_ID', p_source_id);
   FND_MSG_PUB.Add;
   fnd_msg_pub.count_and_get(p_count => x_msg_count
                            ,p_data  => x_msg_data);

END  Validate_Source;

--===============================
-- VALIDATE_ORG_ID
--===============================
--This procedure checks if the Operating Unit is Valid

PROCEDURE VALIDATE_ORG_ID(p_api_name       IN VARCHAR2,
			  p_org_id         IN NUMBER,
			  x_return_status  OUT NOCOPY VARCHAR2,
			  x_msg_count      OUT NOCOPY NUMBER,
			  x_msg_data       OUT NOCOPY VARCHAR2) IS

   CURSOR c_org_id IS
   SELECT organization_id
   FROM   hr_operating_units
   WHERE  organization_id = p_org_id;

   lv_exists_flag VARCHAR2(1) := 'N';

BEGIN

   FOR v_org_id IN c_org_id
   LOOP
      lv_exists_flag := 'Y';
   END LOOP;

   IF lv_exists_flag = 'Y' THEN
      x_return_status :=  FND_API.G_RET_STS_SUCCESS ;
   ELSE
      raise NO_DATA_FOUND;
   END IF;

EXCEPTION

   WHEN NO_DATA_FOUND THEN
	Add_Invalid_Argument_Msg(
			 p_token_an  =>  p_api_name,
			 p_token_v   =>  to_char(p_org_id) ,
			 p_token_p   =>  'p_org_id') ;

	 fnd_msg_pub.count_and_get(
	   p_count => x_msg_count
	  ,p_data  => x_msg_data);

	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
	 x_return_status :=  FND_API.G_RET_STS_ERROR ;

END VALIDATE_ORG_ID;

--===============================
-- IS_ITEM_VALID
--===============================
--This Function checks if the item exists in the organization passed
FUNCTION IS_ITEM_VALID(p_org_id             IN  NUMBER,
                       p_inventory_item_id  IN  NUMBER,
                       x_msg_data           OUT NOCOPY VARCHAR2,
                       x_msg_count          OUT NOCOPY NUMBER,
                       x_return_status      OUT NOCOPY VARCHAR2
		      ) RETURN VARCHAR2 IS

   CURSOR c_inventory_item_id IS
   SELECT 1
   FROM mtl_system_items_b
   WHERE organization_id =cs_std.get_item_valdn_orgzn_id -- modified by bkanimoz on 21-jan-2007
   AND inventory_item_id =p_inventory_item_id;

   lv_exists_flag VARCHAR2(1) := 'N';
   l_prog_name CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'is_item_valid';

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   FOR v_inventory_item_id IN c_inventory_item_id LOOP
      lv_exists_flag := 'Y';
   END LOOP;
   RETURN lv_exists_flag;

EXCEPTION

WHEN OTHERS THEN

   FND_MESSAGE.SET_NAME(G_APP_NAME, G_DB_ERROR);
   FND_MESSAGE.SET_TOKEN(token => G_PROG_NAME_TOKEN, value => l_prog_name);
   FND_MESSAGE.SET_TOKEN(token => G_SQLCODE_TOKEN, value => SQLCODE);
   FND_MESSAGE.SET_TOKEN(token => G_SQLERRM_TOKEN, value => SQLERRM);
   FND_MSG_PUB.add;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   RETURN lv_exists_flag;

END IS_ITEM_VALID;

--===============================
--IS_TXN_INV_ORG_VALID
--===============================
--This Function checks if the Inventory Org is valid

FUNCTION IS_TXN_INV_ORG_VALID(p_txn_inv_org    IN         NUMBER,
                              p_org_id         IN         NUMBER,
                              x_msg_data       OUT NOCOPY VARCHAR2,
                              x_msg_count      OUT NOCOPY NUMBER,
                              x_return_status  OUT NOCOPY VARCHAR2)RETURN VARCHAR2 IS

   CURSOR c_oper_unit_for_inv_org (p_txn_inv_org number) IS
   SELECT To_number(hoi2.org_information3)  OPERATING_UNIT
   FROM   hr_organization_units hou,
          hr_organization_information hoi1,
          hr_organization_information hoi2,
          mtl_parameters mp
   WHERE  mp.organization_id = p_txn_inv_org
       AND mp.organization_id = hou.organization_id
       AND hou.organization_id = hoi1.organization_id
       AND hoi1.org_information1 = 'INV'
       AND hoi1.org_information2 = 'Y'
       AND hoi1.org_information_context = 'CLASS'
       AND hou.organization_id = hoi2.organization_id
       AND hoi1.organization_id = hoi2.organization_id
       AND hoi2.org_information_context = 'Accounting Information';

   lv_exists_flag VARCHAR2(1) := 'N';
   l_prog_name CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'is_txn_inv_org_valid';

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   FOR v_oper_unit_for_inv_org IN c_oper_unit_for_inv_org (p_txn_inv_org)
   LOOP
     IF v_oper_unit_for_inv_org.OPERATING_UNIT = p_org_id THEN
        lv_exists_flag := 'Y';
        EXIT;
     END IF;
   END LOOP;

   RETURN lv_exists_flag;

EXCEPTION

WHEN OTHERS THEN

   FND_MESSAGE.SET_NAME(G_APP_NAME, G_DB_ERROR);
   FND_MESSAGE.SET_TOKEN(token => G_PROG_NAME_TOKEN, value => l_prog_name);
   FND_MESSAGE.SET_TOKEN(token => G_SQLCODE_TOKEN, value => SQLCODE);
   FND_MESSAGE.SET_TOKEN(token => G_SQLERRM_TOKEN, value => SQLERRM);
   FND_MSG_PUB.add;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   RETURN lv_exists_flag;
END;

--===============================
--- Get Primary Unit of Measure
--===============================
--This Procedure gets the Primary UOM for the Item defined in the Item Master window.

PROCEDURE GET_PRIMARY_UOM(p_inventory_item_id IN NUMBER,
			  p_org_id            IN NUMBER,
			  x_primary_uom       OUT NOCOPY VARCHAR2,
			  x_msg_data          OUT NOCOPY VARCHAR2,
			  x_msg_count         OUT NOCOPY NUMBER,
			  x_return_status     OUT NOCOPY VARCHAR2
                          ) IS

   CURSOR c_primary_uom(p_inv_id IN NUMBER) IS
   SELECT mum.uom_code
   FROM   mtl_system_items_b msi,
          mtl_units_of_measure_tl mum
   WHERE  msi.primary_unit_of_measure = mum.unit_of_measure
       AND msi.inventory_item_id = p_inventory_item_id
       AND msi.organization_id = p_org_id;

   lv_exists_flag VARCHAR2(1) := 'N';
   l_prog_name CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'get_primary_uom';

BEGIN

-- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   FOR v_primary_uom IN c_primary_uom(P_INVentory_item_ID)
   LOOP
      lv_exists_flag := 'Y';
       x_primary_uom := v_primary_uom.uom_code;
   END LOOP;

EXCEPTION

WHEN OTHERS THEN

  FND_MESSAGE.Set_Name('CS', 'CS_CHG_GET_UOM_FAILED');
  FND_MESSAGE.SET_TOKEN('INVENTORY_ITEM_ID', p_inventory_item_id);
  FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID', cs_std.get_item_valdn_orgzn_id);
  FND_MSG_PUB.add;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END GET_PRIMARY_UOM;

--===============================
--- IS_UOM_VALID
--===============================
--This function checks if the UOM is valid

FUNCTION IS_UOM_VALID(p_uom_code       IN         VARCHAR2,
                      p_org_id         IN         NUMBER,
                      p_inv_id         IN         NUMBER,
                      x_msg_data       OUT NOCOPY VARCHAR2,
                      x_msg_count      OUT NOCOPY NUMBER,
                      x_return_status  OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS
   CURSOR   c_uom_code(p_uom_code IN VARCHAR2,
		  p_inv_id IN NUMBER) IS
   SELECT   uom_code
   FROM     mtl_item_uoms_view
   WHERE    uom_code = p_uom_code
        AND inventory_item_id = P_INV_ID
	AND organization_id = p_org_id ;

   lv_exists_flag VARCHAR2(1) := 'N';
   l_prog_name CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'is_uom_valid';

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FOR v_uom_code IN c_uom_code(p_uom_code,p_inv_id)
  LOOP
    lv_exists_flag := 'Y';
  END LOOP;
  RETURN lv_exists_flag;

EXCEPTION

WHEN OTHERS THEN
   FND_MESSAGE.SET_NAME(G_APP_NAME, G_DB_ERROR);
   FND_MESSAGE.SET_TOKEN(token => G_PROG_NAME_TOKEN, value => l_prog_name);
   FND_MESSAGE.SET_TOKEN(token => G_SQLCODE_TOKEN, value => SQLCODE);
   FND_MESSAGE.SET_TOKEN(token => G_SQLERRM_TOKEN, value => SQLERRM);
   FND_MSG_PUB.add;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   RETURN lv_exists_flag;
END;

--===============================
---Get Currency Code
--===============================
--This procedure gets the Functional Currency of the Operating Unit defined in General Ledger

PROCEDURE GET_CURRENCY_CODE(p_org_id            IN  NUMBER,
                            x_currency_code     OUT NOCOPY VARCHAR2,
                            x_msg_data          OUT NOCOPY VARCHAR2,
                            x_msg_count         OUT NOCOPY NUMBER,
                            x_return_status     OUT NOCOPY VARCHAR2 ) IS

   CURSOR c_currency_code IS
   SELECT currency_code
   FROM   gl_sets_of_books a,
          hr_operating_units b
   WHERE  a.NAME = b.NAME
          AND b.organization_id = p_org_id;

   lv_exists_flag VARCHAR2(1) := 'N';
   l_prog_name CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'get_currency_code';

BEGIN
  -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   FOR v_currency_code IN c_currency_code
   LOOP
      lv_exists_flag := 'Y';
      x_currency_code  := v_currency_code.currency_code ;
  END LOOP;

EXCEPTION

WHEN OTHERS THEN

   FND_MESSAGE.Set_Name('CS', 'CS_COST_GET_CURRENCY_FAILED');
   FND_MSG_PUB.add;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END GET_CURRENCY_CODE;

--===============================
---IS_CURRENCY_CODE_VALID
--===============================
--This Function checks if the passed currency code is valid

FUNCTION IS_CURRENCY_CODE_VALID (p_currency_code   IN         VARCHAR2,
                                 x_msg_data        OUT NOCOPY VARCHAR2,
                                 x_msg_count       OUT NOCOPY NUMBER,
                                 x_return_status   OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

   CURSOR c_currency_code IS
   SELECT currency_code
   FROM   FND_CURRENCIES_TL
   WHERE  currency_code = p_currency_code
       AND language = Userenv('lang');

  lv_exists_flag VARCHAR2(1) := 'N';
  l_prog_name CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'is_currency_code_valid';

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   FOR v_currency_code IN c_currency_code
   LOOP
      lv_exists_flag := 'Y';
   END LOOP;
   RETURN lv_exists_flag;

EXCEPTION

WHEN OTHERS THEN

   FND_MESSAGE.SET_NAME(G_APP_NAME, G_DB_ERROR);
   FND_MESSAGE.SET_TOKEN(token => G_PROG_NAME_TOKEN, value => l_prog_name);
   FND_MESSAGE.SET_TOKEN(token => G_SQLCODE_TOKEN, value => SQLCODE);
   FND_MESSAGE.SET_TOKEN(token => G_SQLERRM_TOKEN, value => SQLERRM);
   FND_MSG_PUB.add;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   RETURN lv_exists_flag;

END IS_CURRENCY_CODE_VALID;

--===============================
---IS_COST_ID_VALID
--===============================

FUNCTION IS_COST_ID_VALID (p_cost_id IN         NUMBER,
                           x_msg_data           OUT NOCOPY VARCHAR2,
                           x_msg_count          OUT NOCOPY NUMBER,
                           x_return_status      OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2 IS

   CURSOR c_cost_id IS
   SELECT 1
   FROM   cs_cost_details
   WHERE  cost_id = p_cost_id;

   lv_exists_flag VARCHAR2(1) := 'N';
   l_prog_name CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'is_cost_id_valid';

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

    FOR v_cost_id IN c_cost_id
    LOOP
       lv_exists_flag := 'Y';
    END LOOP;

    RETURN lv_exists_flag;

EXCEPTION

   WHEN OTHERS THEN
      FND_MESSAGE.SET_NAME(G_APP_NAME, G_DB_ERROR);
      FND_MESSAGE.SET_TOKEN(token => G_PROG_NAME_TOKEN, value => l_prog_name);
      FND_MESSAGE.SET_TOKEN(token => G_SQLCODE_TOKEN, value => SQLCODE);
      FND_MESSAGE.SET_TOKEN(token => G_SQLERRM_TOKEN, value => SQLERRM);
      FND_MSG_PUB.add;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RETURN lv_exists_flag;

END IS_COST_ID_VALID;

--===============================
---VALIDATE_BUSINESS_PROCESS
--===============================
--This procedure just checks if the Business process id is present in cs_bus_process_txns

PROCEDURE VALIDATE_BUSINESS_PROCESS(p_api_name             IN VARCHAR2,
                                    p_transaction_type_id  IN NUMBER,
                                    x_return_status        OUT NOCOPY VARCHAR2,
                                    x_msg_count            OUT NOCOPY NUMBER,
                                    x_msg_data             OUT NOCOPY VARCHAR2  ) IS

  CURSOR c_business_process IS
  SELECT '1'
  FROM  cs_bus_process_txns
  WHERE transaction_type_id = p_transaction_type_id;

  lv_exists_flag VARCHAR2(1) := 'N';

BEGIN
   FOR v_business_process IN c_business_process
      LOOP
        lv_exists_flag := 'Y';
      END LOOP;

   IF lv_exists_flag = 'Y' THEN
      x_return_status :=  FND_API.G_RET_STS_SUCCESS ;
   ELSE
       x_return_status :=  FND_API.G_RET_STS_ERROR;
       RAISE NO_DATA_FOUND;
  END IF;

EXCEPTION

WHEN NO_DATA_FOUND THEN
   x_return_status := FND_API.G_RET_STS_ERROR;

WHEN OTHERS THEN
   x_return_status :=  FND_API.G_RET_STS_ERROR ;

END VALIDATE_BUSINESS_PROCESS;

--===============================
---VALIDATE_OPERATING_UNIT
--===============================
--This procedure checks if the Operating Unit has been set up in the service activity billing types for service activity ID

PROCEDURE VALIDATE_OPERATING_UNIT(p_api_name             IN VARCHAR2,
                                  p_txn_billing_type_id  IN NUMBER,
                                  x_return_status        OUT NOCOPY VARCHAR2,
                                  x_msg_count            OUT NOCOPY NUMBER,
                                  x_msg_data             OUT NOCOPY VARCHAR2 ) IS

   CURSOR c_operating_unit IS
   SELECT '1'
   FROM   cs_txn_billing_oetxn_all
   WHERE  txn_billing_type_id = p_txn_billing_type_id;

   lv_exists_flag VARCHAR2(1) := 'N';

BEGIN

   FOR v_operating_unit IN c_operating_unit
   LOOP
      lv_exists_flag := 'Y';
   END LOOP;

   IF lv_exists_flag = 'Y' THEN
      x_return_status :=  FND_API.G_RET_STS_SUCCESS ;
   ELSE
      x_return_status :=  FND_API.G_RET_STS_ERROR;
      RAISE NO_DATA_FOUND;
   END IF;

EXCEPTION

WHEN NO_DATA_FOUND THEN
   x_return_status := FND_API.G_RET_STS_ERROR;

WHEN OTHERS THEN
   x_return_status :=  FND_API.G_RET_STS_ERROR ;

END VALIDATE_OPERATING_UNIT;

--===============================
---VALIDATE_TRANSACTION_TYPE_ID
--===============================
--This procedure checks if the SAC is valid

PROCEDURE VALIDATE_TRANSACTION_TYPE_ID(p_api_name                 IN VARCHAR2,
                                       p_transaction_type_id      IN NUMBER,
				       x_line_order_category_code OUT NOCOPY VARCHAR2,
                                       x_return_status            OUT NOCOPY VARCHAR2,
                                       x_msg_count                OUT NOCOPY NUMBER,
                                       x_msg_data                 OUT NOCOPY VARCHAR2 ) IS

  CURSOR c_transaction_type_id IS
  SELECT transaction_type_id,line_order_category_code
  FROM   cs_transaction_types_b
  WHERE transaction_type_id = p_transaction_type_id;

  lv_exists_flag VARCHAR2(1) := 'N';

BEGIN

  FOR v_transaction_type_id IN c_transaction_type_id
  LOOP
     lv_exists_flag := 'Y';
     x_line_order_category_code:=v_transaction_type_id.line_order_category_code;
  END LOOP;

  IF lv_exists_flag = 'Y' THEN
     x_return_status :=  FND_API.G_RET_STS_SUCCESS ;
  ELSE
     RAISE NO_DATA_FOUND;
  END IF;

EXCEPTION

WHEN NO_DATA_FOUND THEN
   Add_Invalid_Argument_Msg(
			 p_token_an  =>  p_api_name,
			 p_token_v   =>  to_char(p_transaction_type_id) ,
			 p_token_p   =>  'p_transaction_type_id') ;

   fnd_msg_pub.count_and_get(
	   p_count => x_msg_count
	  ,p_data  => x_msg_data);

   x_return_status :=  FND_API.G_RET_STS_ERROR ;

WHEN OTHERS THEN
   x_return_status :=  FND_API.G_RET_STS_ERROR ;

END VALIDATE_transaction_type_id;

--===============================
---VALIDATE_TRANSACTION_TYPE_ID
--===============================
-- Added For the Debrief flow
PROCEDURE Get_Item_from_Profile(p_transaction_type_id     IN NUMBER,
                                p_inv_item_id             IN NUMBER,
                                p_no_charge               OUT NOCOPY VARCHAR2,
                                x_inv_item_id             OUT NOCOPY NUMBER,
                                x_return_status           OUT NOCOPY VARCHAR2,
                                x_msg_count               OUT NOCOPY NUMBER,
                                x_msg_data                OUT NOCOPY VARCHAR2 ) IS

   CURSOR c_check_flag IS
   SELECT create_charge_flag,create_cost_flag
   FROM   cs_transaction_types_b
   WHERE  transaction_type_id = p_transaction_type_id;

   CURSOR c_get_item_from_profile is
   select fnd_profile.value('CS_DEFAULT_LABOR_ITEM') from dual;

   lv_exists_flag VARCHAR2(1) := 'N';
   l_create_charge_flag VARCHAR2(1);
   l_create_cost_flag VARCHAR2(1);

BEGIN
--For the Debrief Flow
/*If the SAC Set up has Create Charge = 'No' and Create Cost ='Yes'
   and no item is passed from Debrief, then retrieve the inv. item from the profile mentioned below and proceed with the rest of the logic
  If the profile value is null, and no item is passed by the calling program, then raise an error message and abort the process.
*/
   OPEN c_check_flag;
   FETCH c_check_flag into l_create_charge_flag,l_create_cost_flag;
   CLOSE c_check_flag;

	IF l_create_charge_flag = 'N' and l_create_cost_flag='Y' and P_INV_ITEM_ID is null
	THEN
	 p_no_charge :='Y';
	   OPEN c_get_item_from_profile;
	   FETCH c_get_item_from_profile
	   INTO x_inv_item_id;

	   IF c_get_item_from_profile%NOTFOUND THEN
	      CLOSE c_get_item_from_profile;

              x_inv_item_id := null;
	   END IF;
	   CLOSE c_get_item_from_profile;
	   else
             p_no_charge :='N';
	END IF;

EXCEPTION

  WHEN OTHERS THEN
     x_return_status :=  FND_API.G_RET_STS_ERROR ;

END Get_Item_from_Profile;

--===============================
---GET_COST_DETAIL_REC
--===============================

PROCEDURE GET_COST_DETAIL_REC(p_api_name               IN         VARCHAR2,
                              p_cost_id                IN         NUMBER,
                              x_cost_detail_rec        OUT NOCOPY CS_COST_DETAILS%ROWTYPE ,
                              x_msg_data               OUT NOCOPY VARCHAR2,
                              x_msg_count              OUT NOCOPY NUMBER,
                              x_return_status          OUT NOCOPY VARCHAR2) IS
BEGIN

   x_return_status :=  FND_API.G_RET_STS_SUCCESS ;

   SELECT *
   INTO x_cost_detail_rec
   FROM CS_COST_DETAILS
   WHERE COST_ID = p_cost_id
   FOR UPDATE OF  COST_ID NOWAIT ;

EXCEPTION

WHEN NO_DATA_FOUND THEN
   x_return_status :=  FND_API.G_RET_STS_ERROR;
   CS_COST_DETAILS_PVT.Add_Invalid_Argument_Msg(
                         p_token_an  =>  p_api_name,
                         p_token_v   =>  to_char(p_cost_id) ,
                         p_token_p   =>  'p_cost_id') ;
   fnd_msg_pub.count_and_get(
          p_count => x_msg_count
         ,p_data  => x_msg_data);

WHEN RECORD_LOCK_EXCEPTION THEN
   x_return_status := FND_API.G_RET_STS_ERROR ;
   CS_cost_Details_PVT.Record_Is_Locked_Msg(
                             p_token_an => p_api_name);

WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MESSAGE.SET_NAME('CS', 'CS_COST_GET_COST_FAILED');
   FND_MESSAGE.SET_TOKEN('API_NAME', p_api_name);
   FND_MSG_PUB.add;
   fnd_msg_pub.count_and_get(
        p_count => x_msg_count
       ,p_data  => x_msg_data);

END;

--===============================
---GET_CHARGE_FLAGS_FROM_SR
--===============================
--This procedure gets the value for the flags
/*1.Disallow Request Update2.Disallow Charge 3.Disallow Charge Update defined in the SR Type Screen
  1.Create Charge 2.Create Cost defined in the SAC setup screen
*/

PROCEDURE get_charge_flags_from_sr(p_api_name                IN          VARCHAR2,
                                   p_incident_id             IN          NUMBER,
				   p_transaction_type_id     IN          NUMBER,
				   x_create_charge_flag      OUT NOCOPY  VARCHAR2,
				   x_create_cost_flag	     OUT NOCOPY  VARCHAR2,
				   x_disallow_request_update OUT NOCOPY  VARCHAR2,
                                   x_disallow_new_charge     OUT NOCOPY  VARCHAR2,
                                   x_disallow_charge_update  OUT NOCOPY  VARCHAR2,
				   x_msg_data                OUT NOCOPY  VARCHAR2,
                                   x_msg_count               OUT NOCOPY  NUMBER,
                                   x_return_status           OUT NOCOPY  NUMBER
                                   )IS

   CURSOR SAC_FLAGS IS
   SELECT NVL(create_charge_flag,'Y') ,
          NVL(create_cost_flag,'N')
   FROM   cs_transaction_types_b
   WHERE  transaction_type_id = p_transaction_type_id;

   cursor c_charge_flags(p_incident_id IN NUMBER) IS
   SELECT nvl(csinst.disallow_new_charge, 'N'),
          nvl(csinst.disallow_charge_update, 'N'),
          nvl(csinst.disallow_request_update,'N') --new check for costing
   FROM  cs_incident_statuses csinst,
         cs_incidents_all csinall
   WHERE csinst.incident_status_id = csinall.incident_status_id
   AND   csinall.incident_id = p_incident_id;

BEGIN

   IF p_transaction_type_id is not null and  p_transaction_type_id <> fnd_api.g_miss_num
   THEN
      OPEN sac_flags ;
      FETCH sac_flags
      INTO x_create_charge_flag ,x_create_cost_flag;
         IF sac_flags%NOTFOUND THEN
            CLOSE sac_flags;
             --Add null argument error
             Add_Invalid_Argument_Msg(p_token_an => p_api_name,
                                  p_token_v  => TO_CHAR(p_incident_id),
                                  p_token_p  => 'p_transaction_type_id');
              RAISE FND_API.G_EXC_ERROR;
         END IF;
     CLOSE sac_flags;
   ELSE
      x_create_charge_flag :='Y';
      x_create_cost_flag	:='Y';
   END IF;


  OPEN c_charge_flags(p_incident_id);
  FETCH c_charge_flags
  INTO x_disallow_new_charge, x_disallow_charge_update,x_disallow_request_update;
  IF c_charge_flags%NOTFOUND THEN
      CLOSE c_charge_flags;
      Add_Invalid_Argument_Msg(p_token_an => p_api_name,
                                  p_token_v  => TO_CHAR(p_incident_id),
                                  p_token_p  => 'p_incident_id');
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   CLOSE c_charge_flags;
END;

--===============================
---GET_CHARGE_DETAILS
--===============================

PROCEDURE GET_CHARGE_DETAILS(p_api_name              IN		   VARCHAR2,
                             p_estimate_detail_id    IN		   NUMBER,
		             x_incident_id           OUT NOCOPY    NUMBER,
		             x_transaction_type_id   OUT NOCOPY    NUMBER,
		             x_txn_billing_type_id   OUT NOCOPY    NUMBER,
		             x_charge_line_type	     OUT NOCOPY    VARCHAR2,
		             x_inventory_item_id     OUT NOCOPY    NUMBER,
		             x_quantity		     OUT NOCOPY    VARCHAR2,
		             x_unit_of_measure_code  OUT NOCOPY    VARCHAR2,
		             x_currency_code	     OUT  NOCOPY   VARCHAR2,
		             x_source_id	     OUT  NOCOPY   NUMBER,
		             x_source_code	     OUT  NOCOPY   VARCHAR2,
		             x_org_id		     OUT  NOCOPY   NUMBER,
		             x_txn_inv_org           OUT NOCOPY    NUMBER,
		             x_msg_data              OUT NOCOPY	   VARCHAR2,
		             x_msg_count             OUT NOCOPY	   NUMBER,
		             x_return_status         OUT NOCOPY	   VARCHAR2) IS

BEGIN

   x_return_status :=  FND_API.G_RET_STS_SUCCESS ;

       SELECT incident_id  ,
		transaction_type_id ,
		txn_billing_type_id ,
		charge_line_type,
		inventory_item_id,
		quantity_required	,
		unit_of_measure_code ,
		currency_code	,
		source_id	,
		source_code	,
		org_id		,
		fnd_profile.value('CS_INV_VALIDATION_ORG') --Bug 7193528
       INTO	x_incident_id     ,
		x_transaction_type_id ,
		x_txn_billing_type_id  ,
		x_charge_line_type	,
		x_inventory_item_id	,
		x_quantity		,
		x_unit_of_measure_code  ,
		x_currency_code		,
		x_source_id		,
		x_source_code		,
		x_org_id		,
		x_txn_inv_org
        FROM CS_ESTIMATE_DETAILS
        WHERE ESTIMATE_DETAIL_ID = p_estimate_detail_id
        FOR UPDATE OF  ESTIMATE_DETAIL_ID NOWAIT ;

EXCEPTION
WHEN NO_DATA_FOUND  THEN
   Add_Invalid_Argument_Msg(p_token_an => p_api_name,
                  p_token_v => to_char(p_estimate_detail_id) ,
                  p_token_p => 'estimate_detail_id' ) ;
   RAISE FND_API.G_EXC_ERROR;

WHEN RECORD_LOCK_EXCEPTION THEN
   x_return_status := FND_API.G_RET_STS_ERROR ;
   CS_cost_Details_PVT.Record_Is_Locked_Msg(
                             p_token_an => p_api_name);
   RAISE FND_API.G_EXC_ERROR;

WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MESSAGE.SET_NAME('CS', 'CS_CHG_GET_CHARGE_FAILED');
   FND_MESSAGE.SET_TOKEN('API_NAME', p_api_name);
   FND_MSG_PUB.add;
   fnd_msg_pub.count_and_get(p_count => x_msg_count,p_data  => x_msg_data);

END Get_charge_details;

--===============================
--- GET_SR_ORG_INFO
--===============================
--This Procedure gets the INV_ORGANIZATION_ID for the SR
--Bug 7193528
PROCEDURE GET_SR_ORG_INFO(p_incident_id         IN  NUMBER,
                          x_org_id              OUT NOCOPY NUMBER,
			  x_inv_organization_id OUT NOCOPY NUMBER,
			  x_msg_data            OUT NOCOPY VARCHAR2,
			  x_msg_count           OUT NOCOPY NUMBER,
			  x_return_status       OUT NOCOPY VARCHAR2
                          ) IS

   CURSOR c_get_sr_org(p_incident_id IN NUMBER) IS
   SELECT inv_organization_id, org_id
   FROM   cs_incidents_all_b cia
   WHERE  cia.incident_id = p_incident_id;

   lv_exists_flag VARCHAR2(1) := 'N';
   l_prog_name CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'GET_SR_ORG_INFO';

BEGIN

-- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   FOR v_get_sr_org IN c_get_sr_org(p_incident_id)
   LOOP
      x_org_id:=v_get_sr_org.org_id;
      x_inv_organization_id:= v_get_sr_org.inv_organization_id;
   END LOOP;

EXCEPTION

WHEN NO_DATA_FOUND THEN
x_inv_organization_id:= null;
END GET_SR_ORG_INFO;


--===============================
---Do_Cost_Line_Exist
--===============================
--This Function checks if a record exist in cs_cost_details for the passed cost_id

FUNCTION Do_cost_line_Exist(p_api_name      IN          VARCHAR2,
                            p_cost_id       IN          NUMBER ,
                            x_return_status OUT NOCOPY  VARCHAR2)  RETURN VARCHAR2 IS

   lv_exists_flag         VARCHAR2(1) := 'N';
   l_prog_name CONSTANT   VARCHAR2(61) := G_PKG_NAME||'.'||'do_cost_line_exist';
   l_exist_cost_id        NUMBER;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   SELECT cost_id
   INTO   l_exist_cost_id
   FROM   CS_cost_details
   WHERE cost_id =p_cost_id
   FOR UPDATE OF COST_ID NOWAIT ;

   if l_exist_cost_id is not null then
      lv_exists_flag := 'N';
   end if;
   RETURN lv_exists_flag;

EXCEPTION

WHEN RECORD_LOCK_EXCEPTION THEN

   x_return_status := FND_API.G_RET_STS_ERROR ;
   CS_cost_Details_PVT.Record_Is_Locked_Msg(
                             p_token_an => p_api_name);
   RAISE FND_API.G_EXC_ERROR;

WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   RETURN lv_exists_flag;

END Do_Cost_Line_Exist ;

--===============================
---Do_charge_line_Exist
--===============================
--This Function checks if a record exist in cs_cost_details for the passed cost_id

FUNCTION Do_charge_line_Exist(p_api_name      IN          VARCHAR2,
                              p_cost_id       IN          NUMBER ,
                              x_return_status OUT NOCOPY  VARCHAR2)  RETURN VARCHAR2 IS

   lv_exists_flag VARCHAR2(1) := 'N';
   l_charge_exist number;
   l_prog_name CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'do_charge_line_exist';

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   SELECT ced.estimate_detail_id
   INTO   l_charge_exist
   FROM   CS_cost_details csd,cs_estimate_details ced
   WHERE  csd.cost_id =p_cost_id
   AND    ced.estimate_Detail_id = csd.estimate_Detail_id
   FOR UPDATE OF COST_ID NOWAIT ;

   if l_charge_exist is not null then
      lv_exists_flag := 'Y';
   end if;

   RETURN lv_exists_flag;

EXCEPTION

WHEN OTHERS THEN
   RETURN lv_exists_flag;

END Do_charge_line_Exist;

--===============================
--GET_TXN_BILLING_TYPE
--===============================
--This procedure gets the Billing Type for the Item

PROCEDURE GET_TXN_BILLING_TYPE( p_api_name            IN         VARCHAR2,
                                p_inv_id              IN         NUMBER,
                                p_txn_type_id         IN         NUMBER,
                                x_txn_billing_type_id OUT NOCOPY NUMBER,
                                x_msg_data            OUT NOCOPY VARCHAR2,
                                x_msg_count           OUT NOCOPY NUMBER,
                                x_return_status       OUT NOCOPY VARCHAR2) IS

   CURSOR c_txn_billing_type(p_inventory_item_id   IN NUMBER,
                             p_txn_type_id         IN NUMBER) IS
   SELECT ctbt.txn_billing_type_id
   FROM   mtl_system_items_kfv kfv,
          cs_txn_billing_types ctbt
   WHERE  kfv.inventory_item_id = p_inventory_item_id
     AND organization_id = cs_std.get_item_valdn_orgzn_id
     AND ctbt.transaction_type_id = p_txn_type_id
     AND ctbt.billing_type = kfv.material_billable_flag;

    lv_exists_flag VARCHAR2(1) := 'N';

BEGIN
  -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   FOR v_txn_billing_type IN c_txn_billing_type(p_inv_id,p_txn_type_id)
   LOOP
      x_txn_billing_type_id := v_txn_billing_type.txn_billing_type_id;
      lv_exists_flag := 'Y';
   END LOOP;

   IF lv_exists_flag <> 'Y' THEN
      FND_MESSAGE.Set_Name('CS', 'CS_CHG_ITM_BILL_TYP_NOT_IN_TXN');
      FND_MESSAGE.SET_TOKEN('INVENTORY_ITEM_ID', p_inv_id);
      FND_MESSAGE.SET_TOKEN('TXN_TYPE_ID', p_txn_type_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
  END IF;

EXCEPTION

WHEN FND_API.G_EXC_ERROR  THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   fnd_msg_pub.count_and_get(
      p_count => x_msg_count
     ,p_data  => x_msg_data);

WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.Set_Name('CS', 'CS_CHG_ITM_BILL_TYP_NOT_IN_TXN');
    FND_MESSAGE.SET_TOKEN('INVENTORY_ITEM_ID', p_inv_id);
    FND_MESSAGE.SET_TOKEN('TXN_TYPE_ID', p_txn_type_id);
    FND_MSG_PUB.Add;
    fnd_msg_pub.count_and_get(
      p_count => x_msg_count
     ,p_data  => x_msg_data);

END GET_TXN_BILLING_TYPE;

 /*======================================================================+
  ==
  ==  Procedure name      : Create_cost_details
  ==  Comments            : API to create cost details in cs_cost_details
  ==  Modification History:
  ==
  ==  Date        Name       Desc
  ==  ----------  ---------  ---------------------------------------------
  ==  15-DEC-2007 | BKANIMOZ   | Created the procedure
  ========================================================================*/

PROCEDURE Create_cost_details
	(
		p_api_version              IN         NUMBER,
		p_init_msg_list            IN         VARCHAR2         := FND_API.G_FALSE,
		p_commit                   IN         VARCHAR2         := FND_API.G_FALSE,
		p_validation_level         IN         NUMBER           := FND_API.G_VALID_LEVEL_FULL,
		x_return_status            OUT NOCOPY VARCHAR2,
		x_msg_count                OUT NOCOPY NUMBER,
		x_object_version_number    OUT NOCOPY NUMBER,
		x_msg_data                 OUT NOCOPY VARCHAR2,
		x_cost_id                  OUT NOCOPY NUMBER,
		p_resp_appl_id             IN         NUMBER		:= FND_GLOBAL.RESP_APPL_ID,
		p_resp_id                  IN         NUMBER		:= FND_GLOBAL.RESP_ID,
		p_user_id                  IN         NUMBER		:= FND_GLOBAL.USER_ID,
		p_login_id                 IN         NUMBER		:= FND_GLOBAL.LOGIN_ID,
		p_transaction_control      IN         VARCHAR2		:= FND_API.G_TRUE,
		p_cost_rec                 IN         CS_Cost_Details_PUB.Cost_Rec_Type,
		p_cost_creation_override   IN         VARCHAR2:='N'
	) IS


   l_api_version	NUMBER          :=  1.0 ;
   l_api_name           CONSTANT	VARCHAR2(75)    := 'Create_Cost_Details Private API' ;
   l_api_name_full      CONSTANT	VARCHAR2(100)    :=  G_PKG_NAME || '.' || l_api_name ;
   l_prog_name	        CONSTANT	VARCHAR2(100)	:=  G_PKG_NAME||'.'||'create_cost_details';
   l_log_module         CONSTANT	VARCHAR2(255)   := 'csxvcsts.pls.' || l_api_name_full || '.';

   l_cost_rec		CS_Cost_Details_PUB.Cost_Rec_Type;
   lx_cost_rec		CS_Cost_Details_PUB.Cost_Rec_Type;

   l_valid_check	VARCHAR2(1);
   l_return_status	VARCHAR2(1) ;
   l_msg_data           VARCHAR2(2000);
   l_msg_count          NUMBER;
   l_errm	        VARCHAR2(100);
   l_cost_id		NUMBER;
   l_object_version_number  NUMBER;

   p_cost_group_id	NUMBER;
   p_cost_type_id	NUMBER;

   l_unit_cost		NUMBER;

   l_transaction_type_id          NUMBER;
   l_charge_line_type	          VARCHAR2(30);
   l_override_ext_cost_flag       VARCHAR2(1);
   p_estimate_detail_id           NUMBER;
   lv_cost_id		          NUMBER;
   l_disallow_new_charge          VARCHAR2(1);
   l_disallow_charge_update       VARCHAR2(1);
   l_disallow_request_update      VARCHAR2(1);
   l_create_charge_flag	          VARCHAR2(1);
   l_create_cost_flag	          VARCHAR2(1);
   l_cost_org_id                  NUMBER;
   l_cost_inv_org_id              NUMBER;
   l_line_order_category_code     VARCHAR2(10);

   CURSOR c_check_cost_exst is
   SELECT cost_id
   FROM cs_cost_details
   WHERE estimate_Detail_id = p_estimate_detail_id;


BEGIN
   -- Standard start of API savepoint
   IF FND_API.To_Boolean(p_transaction_control) THEN
      SAVEPOINT Create_Cost_Details_PVT;
   END IF ;
  -- Standard call to check for call compatibility
   IF NOT FND_API.Compatible_API_Call(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
     FND_MSG_PUB.Initialize;
  END IF;
  -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
   THEN
	 FND_LOG.String
	    ( FND_LOG.level_procedure ,
	      L_LOG_MODULE || '',
	     'Inside Create_cost_details PVT API:'
	    );
   END IF;


----------------------- FND Logging -----------------------------------
  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN


    FND_LOG.String
    ( FND_LOG.level_procedure ,
       L_LOG_MODULE || 'start'
    , 'Inside ' || L_API_NAME_FULL || ', called with parameters below:'
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_api_version:' || p_api_version
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_init_msg_list:' || p_init_msg_list
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_commit:' || p_commit
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_validation_level:' || p_validation_level
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_resp_appl_id:' || p_resp_appl_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_resp_id:' || p_resp_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_user_id:' || p_user_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_login_id:' || p_login_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_transaction_control:' || p_transaction_control
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_cost_creation_override:  ' || p_cost_creation_override
    );
 -- --------------------------------------------------------------------------
 -- This procedure Logs the charges record paramters.
 -- --------------------------------------------------------------------------
    CS_COST_DETAILS_PUB.Log_Cost_Rec_Parameters
    ( p_cost_Rec_in           => p_cost_rec
    );

  END IF;

 --Convert the IN Parameters from FND_API.G_MISS_XXXX to NULL
  --if no value is passed then return NULL otherwise return the value passed

       TO_NULL (p_cost_Rec, l_cost_Rec) ;

 IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
 THEN
    FND_LOG.String
       ( FND_LOG.level_procedure ,
         L_LOG_MODULE || '',
        'l_cost_Rec.estimate_Detail_id : '||l_cost_Rec.estimate_Detail_id
        );
  END IF;

-- If estimate_Detail_Id is passed to the Create Cost Details API, then get all the data necessry from the charges table .
--      In this case , if any other parameters are passed then they will not be validated

-- If estimate_detail_id is not passed then validate all the parameters passed

   if  l_cost_Rec.estimate_Detail_id is not null then

          p_estimate_detail_id :=l_cost_Rec.estimate_Detail_id;

	  OPEN	c_check_cost_exst;
	  FETCH c_check_cost_exst into lv_cost_id;
	  CLOSE c_check_cost_exst;

	  if lv_cost_id is not null then
	     FND_MESSAGE.SET_NAME('CS', 'CS_COST_CHARGE_EXIST');
	     FND_MSG_PUB.ADD;
	     RAISE FND_API.G_EXC_ERROR;
	  end if;

          --call get_charge_details to get the data from cs_estimate_details table
		  get_charge_details
		  (
		               p_api_name               =>  l_api_name_full,
                               p_estimate_detail_id     =>  l_cost_Rec.estimate_detail_id,
			       x_incident_id            =>  l_cost_rec.incident_id,
			       x_transaction_type_id    =>  l_cost_rec.transaction_type_id  ,
			       x_txn_billing_type_id    =>  l_cost_rec.txn_billing_type_id,
			       x_charge_line_type	=>  l_cost_rec.charge_line_type ,
			       x_inventory_item_id	=>  l_cost_rec.inventory_item_id  ,
			       x_quantity		=>  l_cost_rec.quantity      ,
			       x_unit_of_measure_code	=>  l_cost_rec.unit_of_measure_code ,
			       x_currency_code		=>  l_cost_rec.currency_code   ,
			       x_source_id		=>  l_cost_rec.source_id    ,
			       x_source_code		=>  l_cost_rec.source_code  ,
			       x_org_id			=>  l_cost_rec.org_id      ,
			       x_txn_inv_org		=>  l_cost_rec.inventory_org_id,
			       x_msg_data               =>  x_msg_data,
			       x_msg_count              =>  x_msg_count,
			       x_return_status          =>  x_return_status
		    );

		lx_cost_rec:=l_cost_rec;
--Bug 6972425
--start
                 get_charge_flags_from_sr
	            (
	                      p_api_name		=> l_api_name,
	                      p_incident_id		=> l_cost_rec.incident_id,
	                      p_transaction_type_id	=> l_cost_rec.transaction_type_id,
	                      x_create_charge_flag	=> l_create_charge_flag,
	                      x_create_cost_flag	=> l_create_cost_flag,
	                      x_disallow_request_update	=> l_disallow_request_update,
	                      x_disallow_new_charge	=> l_disallow_new_charge,
	                      x_disallow_charge_update	=> l_disallow_charge_update,
	                      x_msg_data		=> l_msg_data,
	                      x_msg_count		=> l_msg_count,
	                      x_return_status		=> l_return_status
	              );

	IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
	THEN
	   FND_LOG.String
	    ( FND_LOG.level_procedure ,
	      L_LOG_MODULE || '',
	     'l_create_cost_flag: '||l_create_cost_flag||'l_create_charge_flag: '||l_create_charge_flag
	    );

	   FND_LOG.String
	    ( FND_LOG.level_procedure ,
	      L_LOG_MODULE || '',
	     'l_disallow_request_update: '||l_disallow_request_update||'l_disallow_new_charge: '||l_disallow_new_charge||
	     'l_disallow_charge_update: '||l_disallow_charge_update
	    );
	END IF;

	If l_create_charge_flag ='N' and l_create_cost_flag =  'Y'  then
		    if   l_disallow_request_update='Y' THEN
		       FND_MESSAGE.SET_NAME('CS', 'CS_COST_CANNOT_INSERT');
		       FND_MSG_PUB.ADD;
		       RAISE FND_API.G_EXC_ERROR;
		    end if;

	Else
	          if l_disallow_new_charge  = 'Y' OR l_disallow_request_update='Y' THEN
		      FND_MESSAGE.SET_NAME('CS', 'CS_COST_CANNOT_INSERT');
		      FND_MSG_PUB.ADD;
		      RAISE FND_API.G_EXC_ERROR;
		  end if;
	end if;
--end Bug 6972425

end if;--estimate_detail_id not null

	l_transaction_type_id := l_cost_rec.transaction_type_id;
	l_charge_line_type    := l_cost_rec.charge_line_type;

	IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
	THEN
	   FND_LOG.String
	    ( FND_LOG.level_procedure ,
	      L_LOG_MODULE || '',
	     'l_transaction_type_id : '||l_transaction_type_id ||'l_charge_line_type :'||l_charge_line_type
	    );
	END IF;

/* 1. Transaction_Type_Id
	Check if 'Create_Cost_Flag' is set for this transaction_Type
*/
--if parameter p_cost_creation_override ='Y' then do not check for the Create_Cost flag in SAC setup

IF p_cost_creation_override = 'N' THEN
    if l_transaction_type_id is not null then

    -- If transaction type id is passed , first check if it is valid.
    -- Then Check if the 'Create_Cost_Flag' for this transaction_type_id is checked
    -- Then Check if this transaction_type_id is tied to atleast one business process -- check this with rohit

	  VALIDATE_TRANSACTION_TYPE_ID (
					p_api_name		=> l_api_name_full,
					p_transaction_type_id   => l_transaction_type_id,
					x_line_order_category_code=>l_line_order_category_code,
					x_msg_data		=> l_msg_data,
					x_msg_count		=> l_msg_count,
					x_return_status		=> l_return_status
					) ;

	    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
	       RAISE FND_API.G_EXC_ERROR ;
	    Else
	        l_valid_check := IS_COST_FLAG_CHECKED
					   (p_transaction_type_id => l_transaction_type_id,
					    x_msg_data            => l_msg_data,
					    x_msg_count           => l_msg_count,
					    x_return_status       => l_return_status
                                           );

		      if l_valid_check ='Y' then
			 l_cost_rec.transaction_type_id  := l_transaction_type_id;

			 VALIDATE_BUSINESS_PROCESS (
						p_api_name		=> l_api_name_full,
						p_transaction_type_id   => l_transaction_type_id,
						x_msg_data		=> l_msg_data,
						x_msg_count		=> l_msg_count,
						x_return_status		=> l_return_status
						) ;

				IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
				   FND_MESSAGE.SET_NAME('CS', 'CS_COST_INVALID_BUS_PROCESS');
				   FND_MSG_PUB.ADD;
				   RAISE FND_API.G_EXC_ERROR;
				END IF;
		      Else
		           FND_MESSAGE.SET_NAME('CS', 'CS_COST_INVALID_COST_FLAG');
			   FND_MSG_PUB.ADD;
                           RAISE G_WARNING;
		      end if;
	    end if;
	else -- transaction_type_id is null
	        Add_Null_Parameter_Msg(l_api_name,
				     'p_transaction_type_id') ;
		RAISE FND_API.G_EXC_ERROR;
	end if;
END IF;--p_cost_creation_overrid



   IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
   THEN
      FND_LOG.String
       ( FND_LOG.level_procedure ,
         L_LOG_MODULE || '',
         'After Mandatory Check 1'
        );
END IF;

/*2.Cost Records  will be created only for ACTUAL charge lines.
    if charge_line_type is passed the value should be 'ACTUAL'
    if not passed then default it to 'ACTUAL'*/

   if l_charge_line_type is not null then
         l_valid_check := IS_CHARGE_LINE_TYPE_VALID
				 (p_charge_line_type => l_charge_line_type,
				  x_msg_data         => l_msg_data,
				  x_msg_count        => l_msg_count,
				  x_return_status    => l_return_status
				  );

		IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
		   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		ELSIF l_return_status = G_RET_STS_ERROR THEN
		   RAISE FND_API.G_EXC_ERROR;
		END IF;

		if l_valid_check ='Y' then
		   l_cost_rec.charge_line_type := l_charge_line_type;
		else  --throw the error message and stop processing
		   Add_Invalid_Argument_Msg(l_api_name,
					l_charge_line_type,
					 'charge_line_type');

		   RAISE G_WARNING;
		end if;
	else
		l_cost_rec.charge_line_type := 'ACTUAL';
	end if;

   IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
   THEN
      FND_LOG.String
         ( FND_LOG.level_procedure ,
           L_LOG_MODULE || '',
           'After Mandatory Check 2'
         );
    END IF;
--------------------------------------------------------------------------------------------------------------------------
-- All the Other Validations would be performed only when the Validation_level is FULL .


IF (p_validation_level = FND_API.G_VALID_LEVEL_NONE) THEN


	  Validate_Who_Info (   p_api_name             => l_api_name_full,
				p_user_id              => NVL(p_user_id, -1),
				p_login_id             => p_login_id,
				x_return_status        => l_return_status
			    );

	    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	      RAISE FND_API.G_EXC_ERROR;
	    END IF;
	    L_RECALC_COST := 'Y';


ELSIF (p_validation_level = FND_API.G_VALID_LEVEL_FULL) then


-- Perform  all the validations by calling  the procedure VALIDATE_COST_DETAILS which inturn does all the validations

	if  l_cost_Rec.estimate_Detail_id is null then

		  VALIDATE_COST_DETAILS(
				 p_api_name          => l_api_name,
				 pv_cost_rec         => l_cost_rec,
				 p_validation_mode   => 'I'     ,
				 p_user_id           => p_user_id,
				 p_login_id          => p_login_id,
				 x_cost_rec          => lx_cost_rec,
				 x_msg_data          => x_msg_data,
				 x_msg_count         => x_msg_count,
				 x_return_status     => l_return_status
				 );

                   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			  FND_MESSAGE.Set_Name('CS', 'CS_COST_VALIDATE_COST_DTL_ER');
                          FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
                          FND_MSG_PUB.Add;
                          RAISE FND_API.G_EXC_ERROR;
                    END IF;
                    IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
                    THEN
			FND_LOG.String
	                   ( FND_LOG.level_procedure ,
	                      L_LOG_MODULE || '',
	                      'After Validating the Cost Details'
	                    );
	            END IF;

	end if;--validation_level
END IF;--p_cost_rec.estimate_Detail_id is not null

--If the Costing API is called from the backend with a SAC of RETURN type then the user can
-- pass a negative Extened Cost.
/*
	if sign(lx_cost_rec.extended_cost)=-1
	then

	    Add_Invalid_Argument_Msg(l_api_name_full,
				     to_char(lx_cost_rec.extended_cost),
				     'Extended Cost ');
	  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	end if;
*/
--===============================
---Quantity validations
--===============================
	if sign(lx_cost_rec.quantity) = (0)
	then

	    Add_Invalid_Argument_Msg(l_api_name_full,
				     to_char(lx_cost_rec.quantity),
				     'Quantity ');
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

	end if;

--IF Quantity is not passed then Default it to 1
	IF lx_cost_rec.quantity IS NULL THEN
	     lx_cost_rec.quantity:=1;
	END IF;

-- For a Return Transaction the Quantity should be Negative
	IF (l_line_order_category_code = 'RETURN')  then
           if  lx_cost_rec.quantity is not null
           then
              if sign(lx_cost_rec.quantity) = -1 then
                 lx_cost_rec.quantity := lx_cost_rec.quantity;
              else
               --assign -ve qty to out record
                 lx_cost_rec.quantity := (lx_cost_rec.quantity * -1);
              end if;
           end if;
       Else
-- For a Order Transaction
          if  lx_cost_rec.quantity is not null then
             if sign(lx_cost_rec.quantity ) = -1 then
             -- need to make this positive as no -ve quantity for orders
               lx_cost_rec.quantity  := (lx_cost_rec.quantity  * -1);
             else
                lx_cost_rec.quantity := lx_cost_rec.quantity ;
             end if;
          end if;
      End if;

--Bug 7193528

/*1. If Cost Creation is attempted for an SAC with Create_Charge Flag checked
   then Use the Value set in the profile "Service :Inventory Validation
   Org" to retrieve the Item's Unit Cost
  2. If Cost Creation is attempted for an SAC with Create_Charge Flag UnChecked
   then Use the Service Request Inventory Org to fetch the Item's Unit Cost.
The Inventory_org_id in CS_COST_DETAILS should be the org from which the Item
Cost is fetched.
The same logic holds good for getting the ORG_ID(operating Unit) in
CS_COST_DETAILS
1.IF Cost Creation is attempted for an exising Charge Line then store the
Charge Line's Operating unit in CS_COST_DETAILS.org_id column
2.If Cost Creation is attempted for the SR, then store the SR's Operating
Unit in the Org Id column of the Cost table
*/

      if l_create_charge_flag ='N' then
         --l_cost_org_id  := p_cost_rec.inventory_org_id;

         get_sr_org_info        ( p_incident_id         => lx_cost_rec.incident_id,
	                          x_org_id              => l_cost_org_id,
			          x_inv_organization_id => l_cost_inv_org_id  ,
			          x_msg_data            => x_msg_data,
				  x_msg_count           => x_msg_count,
				  x_return_status       => l_return_status
				  );

      else

         l_cost_inv_org_id  :=lx_cost_rec.inventory_org_id;
	 l_cost_org_id      :=lx_cost_rec.org_id;

	    if  l_cost_Rec.estimate_Detail_id is null then

	       get_sr_org_info  ( p_incident_id         => lx_cost_rec.incident_id,
	                          x_org_id              => l_cost_org_id,
			          x_inv_organization_id => l_cost_inv_org_id  ,
			          x_msg_data            => x_msg_data,
				  x_msg_count           => x_msg_count,
				  x_return_status       => l_return_status
				);
	    end if;

      end if;

--===============================
---Item Cost
--===============================

l_unit_cost := CST_COST_API.Get_Item_Cost
				(
				p_api_version		=> 1.0,
				p_inventory_item_id	=> lx_cost_rec.inventory_item_id,
				p_organization_id	=> l_cost_org_id,
				p_cost_group_id		=> p_cost_group_id,
				p_cost_type_id		=> p_cost_type_id
				);

--Calculate the Item's Extended Cost
-- If extended cost is passed then make the unit cost and quantity column to NULL and set the flag to 'Y'
-- IF extended cost is not passed then calculate it as below and set the flag to 'N'

	If lx_cost_rec.extended_cost IS  NULL THEN
	     lx_cost_rec.extended_cost :=l_unit_cost*lx_cost_rec.quantity;
	     l_override_ext_cost_flag :='N';
	Else
	     --l_unit_cost	 := null;
	     --lx_cost_rec.quantity := null;
	     l_override_ext_cost_flag :='Y';
	     IF (l_line_order_category_code = 'RETURN')  then
	       if sign(lx_cost_rec.extended_cost) = -1 then
                 lx_cost_rec.extended_cost := lx_cost_rec.extended_cost;
               else
               --assign -ve qty to out record
                 lx_cost_rec.extended_cost := (lx_cost_rec.extended_cost * -1);
               end if;
	     END IF;

	END IF;

		IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
		  THEN
		FND_LOG.String
		    ( FND_LOG.level_procedure ,
		      L_LOG_MODULE || '',
		     'Before calling the Insert_Row procedure'
		    );
		END IF;

--This prcoedure will insert data into cs_cost_details table

	CS_COST_DETAILS_PKG.Insert_Row
	(
		x_cost_id		=>l_cost_id				,
		p_incident_id		=>lx_cost_rec.incident_id		,
		p_estimate_detail_id	=>lx_cost_rec.estimate_detail_id	,
		p_transaction_type_id	=>lx_cost_rec.transaction_type_id	,
		p_txn_billing_type_id	=>lx_cost_rec.txn_billing_type_id	,
		p_inventory_item_id	=>lx_cost_rec.inventory_item_id		,
		p_quantity		=>lx_cost_rec.quantity			,
		p_unit_cost		=>l_unit_cost				,
		p_extended_cost		=>lx_cost_rec.extended_cost		,
		p_override_ext_cost_flag =>l_override_ext_cost_flag		,
		p_transaction_date	=> sysdate				,
		p_source_id		=>lx_cost_rec.source_id			,
		p_source_code		=>lx_cost_rec.source_code		,
		p_unit_of_measure_code	=>lx_cost_rec.unit_of_measure_code	,
		p_currency_code		=>lx_cost_rec.currency_code		,
		p_org_id		=>l_cost_org_id			        ,
		p_inventory_org_id	=>l_cost_inv_org_id		        ,
		p_attribute1		=>lx_cost_rec.attribute1		,
		p_attribute2		=>lx_cost_rec.attribute2		,
		p_attribute3		=>lx_cost_rec.attribute3		,
		p_attribute4		=>lx_cost_rec.attribute4		,
		p_attribute5		=>lx_cost_rec.attribute5		,
		p_attribute6		=>lx_cost_rec.attribute6		,
		p_attribute7		=>lx_cost_rec.attribute7		,
		p_attribute8		=>lx_cost_rec.attribute8		,
		p_attribute9		=>lx_cost_rec.attribute9		,
		p_attribute10		=>lx_cost_rec.attribute10		,
		p_attribute11		=>lx_cost_rec.attribute11		,
		p_attribute12		=>lx_cost_rec.attribute12		,
		p_attribute13		=>lx_cost_rec.attribute13		,
		p_attribute14		=>lx_cost_rec.attribute14		,
		p_attribute15		=>lx_cost_rec.attribute15		,
		p_last_update_date	=> sysdate				,
		p_last_updated_by	=> FND_GLOBAL.USER_ID			,
		p_last_update_login	=> FND_GLOBAL.LOGIN_ID			,
		p_created_by		=> FND_GLOBAL.USER_ID			,
		p_creation_date	        =>  sysdate				,
		x_object_version_number => l_object_version_number
	);

   x_cost_id :=l_cost_id;

	 IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
         THEN
		FND_LOG.String
                   ( FND_LOG.level_procedure ,
                      L_LOG_MODULE || '',
                     'After calling the Insert Row '
                     );
          END IF;

  FND_MSG_PUB.Count_And_Get
	    ( p_count => x_msg_count,
	      p_data  => x_msg_data,
	      p_encoded => FND_API.G_FALSE) ;

EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN
   x_return_status := FND_API.G_RET_STS_ERROR;
   IF FND_API.To_Boolean(p_transaction_control)
   THEN
        ROLLBACK TO Create_Cost_Details_PVT;
   END IF ;
   FND_MSG_PUB.Count_And_Get(p_count    => x_msg_count,
                                p_data     => x_msg_data,
                                p_encoded  => FND_API.G_FALSE) ;

WHEN G_WARNING THEN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF FND_API.To_Boolean(p_transaction_control)
   THEN
        ROLLBACK TO Create_Cost_Details_PVT;
   END IF ;
   FND_MSG_PUB.Count_And_Get(p_count    => x_msg_count,
                                p_data     => x_msg_data,
                                p_encoded  => FND_API.G_FALSE) ;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   IF FND_API.To_Boolean(p_transaction_control) THEN
      ROLLBACK TO Create_Cost_Details_PVT;
   END IF ;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                             p_data    => x_msg_data,
                             p_encoded => FND_API.G_FALSE) ;

WHEN OTHERS THEN
   IF FND_API.To_Boolean(p_transaction_control) THEN
      ROLLBACK TO Create_Cost_Details_PVT;
   END IF ;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
   THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
   END IF;
   FND_MSG_PUB.Count_And_Get(p_count   => x_msg_count,
                                p_data    => x_msg_data,
                                p_encoded => FND_API.G_FALSE) ;

END create_cost_details;

/*======================================================================+
  ==
  ==  Procedure name      : Create_cost_details
  ==  Comments            : API to Update cost details in cs_cost_details
  ==  Modification History:
  ==
  ==  Date        Name       Desc
  ==  ----------  ---------  ---------------------------------------------
  ==  15-DEC-2007 | BKANIMOZ   | Created the procedure
  ========================================================================*/

PROCEDURE Update_Cost_Details
(
	 p_api_version              IN         NUMBER,
	 p_init_msg_list            IN         VARCHAR2         := FND_API.G_FALSE,
	 p_commit                   IN         VARCHAR2         := FND_API.G_FALSE,
	 p_validation_level         IN         NUMBER           := FND_API.G_VALID_LEVEL_FULL,
	 x_return_status            OUT NOCOPY VARCHAR2,
	 x_msg_count                OUT NOCOPY NUMBER,
	 x_object_version_number    OUT NOCOPY NUMBER,
	 x_msg_data                 OUT NOCOPY VARCHAR2,
	 p_resp_appl_id             IN         NUMBER		:= FND_GLOBAL.RESP_APPL_ID,
	 p_resp_id                  IN         NUMBER		:= FND_GLOBAL.RESP_ID,
	 p_user_id                  IN         NUMBER		:= FND_GLOBAL.USER_ID,
	 p_login_id                 IN         NUMBER           :=FND_GLOBAL.LOGIN_ID,
	 p_transaction_control      IN         VARCHAR2         := FND_API.G_TRUE,
	 p_Cost_Rec                 IN         CS_Cost_Details_PUB.Cost_Rec_Type

) IS

   l_api_version          NUMBER                 :=  1.0 ;
   l_api_name             VARCHAR2(100)           := 'Update_Cost_Details' ;
   l_api_name_full        VARCHAR2(100)           :=  G_PKG_NAME || '.' || l_api_name ;
   l_log_module CONSTANT  VARCHAR2(255)          := 'csxvcstb.pls.' || l_api_name_full || '.';
   l_return_status        VARCHAR2(1) ;
   l_org_id               NUMBER ;
   l_prog_name CONSTANT   VARCHAR2(61) := G_PKG_NAME||'.'||'update_cost_details';
   l_cost_rec		  CS_Cost_Details_PUB.Cost_Rec_Type;
   lx_cost_rec		  CS_Cost_Details_PUB.Cost_Rec_Type;
   l_valid_check          VARCHAR2(1);

    l_msg_data            VARCHAR2(2000);
    l_msg_count           NUMBER;
    l_object_version_number NUMBER;
    l_errm                VARCHAR2(100);
    l_cost_id             NUMBER;
    l_transaction_type_id NUMBER;
    l_charge_line_type	  VARCHAR2(30);

    l_unit_cost		 NUMBER;
    p_cost_group_id	 NUMBER;
    p_cost_type_id	 NUMBER;

    l_override_ext_cost_flag VARCHAR2(1);
    l_quantity		 NUMBER;
    lt_estimate_detail_id NUMBER;
    v_estimate_detail_id NUMBER;

    p_cost_id          NUMBER;
    v_unit_cost        NUMBER;
    v_extended_cost    NUMBER;
    v_override_ext_cost_flag VARCHAR2(1);

    p_estimate_detail_id        NUMBER;
    lv_cost_id		        NUMBER;
    l_disallow_new_charge       VARCHAR2(1);
    l_disallow_charge_update    VARCHAR2(1);
    l_disallow_request_update   VARCHAR2(1);
    l_create_charge_flag	VARCHAR2(1);
    l_create_cost_flag		VARCHAR2(1);
    l_cost_org_id               NUMBER;
    l_cost_inv_org_id           NUMBER;

  CURSOR get_flag IS
  SELECT unit_cost,
         extended_cost,
         override_ext_cost_flag
  FROM   cs_cost_details
  WHERE  cost_id = p_cost_id;

  CURSOR c_check_cost_exst IS
  SELECT cost_id
  FROM   cs_cost_details
  WHERE estimate_Detail_id = p_estimate_detail_id;

BEGIN
-- Standard start of API savepoint
   IF FND_API.To_Boolean(p_transaction_control) THEN
      SAVEPOINT Update_Cost_Details_PVT;
   END IF ;
 -- Standard call to check for call compatibility
  IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME)
  THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;
 -- Initialize message list if p_init_msg_list is set to TRUE
  IF FND_API.To_Boolean(p_init_msg_list) THEN
     FND_MSG_PUB.Initialize;
  END IF;
-- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

----------------------- FND Logging -----------------------------------
  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || 'start'
    , 'Inside ' || L_API_NAME_FULL || ', called with parameters below:'
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_api_version:' || p_api_version
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_init_msg_list:' || p_init_msg_list
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_commit:' || p_commit
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_validation_level:' || p_validation_level
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_resp_appl_id:' || p_resp_appl_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_resp_id:' || p_resp_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_user_id:' || p_user_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_login_id:' || p_login_id
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_transaction_control:' || p_transaction_control
    );
 -- --------------------------------------------------------------------------
 -- This procedure Logs the charges record paramters.
 -- --------------------------------------------------------------------------
    CS_COST_DETAILS_PUB.Log_Cost_Rec_Parameters
    ( p_cost_Rec_in         => p_cost_rec
    );

END IF;

l_cost_rec:=p_cost_rec;

	IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
	THEN
	  FND_LOG.String
	    ( FND_LOG.level_procedure ,
	      L_LOG_MODULE || '',
	     'p_cost_rec.estimate_Detail_id : '||p_cost_rec.estimate_Detail_id
	    );
	END IF;

 lt_estimate_detail_id :=p_cost_rec.estimate_Detail_id ;


/*
If  there is a  estimate_Detail_id for the cost_id passed , then get all the details from the estimate_Detail_id
and pass it to the cost update package. This is to make sure that the cost level details are in sync with  charge line details.

	For example say a Charge line  has been Created for 10 Quantities of an Item.
	Cost Line is also generated for this 10 quantity.
        If while calling the Update Cost  API , say the Quantity is passed as 20 for this cost line,
        the cost API will not update the cost line with 20 quantities .
	But if the Update Cost API is called with Extended Cost ,  then the Cost API will update the Quantity and Unit Cost
	to NULL and extended cost to the value passed.
*/


IF p_cost_rec.cost_id is not null and p_cost_rec.cost_id <> fnd_api.g_miss_num
THEN

	   begin

	   select estimate_detail_id
	   into   v_estimate_detail_id
	   from   cs_cost_details csd
	   where cost_id =p_cost_rec.cost_id;

	      if v_estimate_detail_id is not null then
		 lt_estimate_detail_id:=v_estimate_detail_id;
	      end if;

	   exception
	      when no_data_found then
		null;--dbms_output.put_line('Costing1');
	       when others then
	       null;
	   end;

END IF;


IF  lt_estimate_detail_id IS NOT NULL
AND  lt_estimate_detail_id<> fnd_api.g_miss_num
THEN

p_estimate_Detail_id := lt_estimate_detail_id;

 OPEN	c_check_cost_exst;

	  FETCH c_check_cost_exst into lv_cost_id;

	  CLOSE c_check_cost_exst;

	  if lv_cost_id is  null then
		FND_MESSAGE.SET_NAME('CS', 'CS_COST_NO_CHARGE_EXIST');
		FND_MSG_PUB.ADD;
		RAISE G_WARNING;
	  end if;

	GET_CHARGE_DETAILS
	(
		       p_api_name               =>  l_api_name_full,
		       p_estimate_detail_id     =>  lt_estimate_detail_id,
		       x_incident_id            =>  l_cost_rec.incident_id,
		       x_transaction_type_id    =>  l_cost_rec.transaction_type_id  ,
		       x_txn_billing_type_id    =>  l_cost_rec.txn_billing_type_id,
		       x_charge_line_type	=>  l_cost_rec.charge_line_type ,
		       x_inventory_item_id	=>  l_cost_rec.inventory_item_id  ,
		       x_quantity		=>  l_cost_rec.quantity      ,
		       x_unit_of_measure_code	=>  l_cost_rec.unit_of_measure_code ,
		       x_currency_code		=>  l_cost_rec.currency_code   ,
		       x_source_id		=>  l_cost_rec.source_id    ,
		       x_source_code		=>  l_cost_rec.source_code  ,
		       x_org_id			=>  l_cost_rec.org_id      ,
		       x_txn_inv_org		=>  l_cost_rec.inventory_org_id,
		       x_msg_data               =>  x_msg_data,
		       x_msg_count              =>  x_msg_count,
		       x_return_status          =>  x_return_status
	 );

--Bug fix for 6972425
--start
get_charge_flags_from_sr
	(
	   p_api_name			=> l_api_name_full,
	   p_incident_id		=> l_cost_rec.incident_id,
	   p_transaction_type_id	=> l_cost_rec.transaction_type_id,
	   x_create_charge_flag		=> l_create_charge_flag,
	   x_create_cost_flag		=> l_create_cost_flag,
	   x_disallow_request_update	=> l_disallow_request_update,
	   x_disallow_new_charge	=> l_disallow_new_charge,
	   x_disallow_charge_update	=> l_disallow_charge_update,
	   x_msg_data			=> l_msg_data,
	   x_msg_count			=> l_msg_count,
	   x_return_status		=> l_return_status
	);

	IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
	  THEN
	FND_LOG.String
	    ( FND_LOG.level_procedure ,
	      L_LOG_MODULE || '',
	     'l_create_cost_flag: '||l_create_cost_flag||'l_create_charge_flag: '||l_create_charge_flag
	    );

	FND_LOG.String
	    ( FND_LOG.level_procedure ,
	      L_LOG_MODULE || '',
	     'l_disallow_request_update: '||l_disallow_request_update||'l_disallow_new_charge: '||l_disallow_new_charge||
	     'l_disallow_charge_update: '||l_disallow_charge_update
	    );
	END IF;

       If l_create_charge_flag ='N' and l_create_cost_flag =  'Y'  then

		    if   l_disallow_request_update='Y' THEN
		     FND_MESSAGE.SET_NAME('CS', 'CS_COST_CANNOT_UPDATE');
		     FND_MSG_PUB.ADD;
		     RAISE FND_API.G_EXC_ERROR;
		    end if;

	Else

	          if l_disallow_charge_update  = 'Y' OR l_disallow_request_update='Y' THEN
		     FND_MESSAGE.SET_NAME('CS', 'CS_COST_CANNOT_UPDATE');
		     FND_MSG_PUB.ADD;
		     RAISE FND_API.G_EXC_ERROR;
		  end if;

	end if;

--end Bug fix for 6972425

END IF;

lx_cost_rec:=l_cost_rec;

--Cost Line can only be created for 'ACTUAL' charge Line types

if lx_cost_rec.charge_line_type is not null and lx_cost_rec.charge_line_type <> fnd_api.g_miss_char
then
if lx_cost_rec.charge_line_type<>'ACTUAL' then

    Add_Invalid_Argument_Msg(l_api_name_full,
                             to_char(lx_cost_rec.charge_line_type),
                             'Charge_line_Type');
RAISE G_WARNING;
end if;
end if;



IF (p_validation_level = FND_API.G_VALID_LEVEL_NONE) THEN


      Validate_Who_Info ( p_api_name             => l_api_name_full,
                        p_user_id              => NVL(p_user_id, -1),
                        p_login_id             => p_login_id,
                        x_return_status        => l_return_status);

		    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
		      RAISE FND_API.G_EXC_ERROR;
		    END IF;

		    IF  lt_estimate_detail_id is  null then

			lx_cost_rec:= l_cost_rec;

		    END IF;

		 L_RECALC_COST :='Y';


ELSIF (p_validation_level = FND_API.G_VALID_LEVEL_FULL) then


-- Perform  all the validations by calling  the procedure VALIDATE_COST_DETAILS which inturn does all the validations
     --This is done only when there is no estimate_Detail_id
	if   lt_estimate_detail_id is null or  lt_estimate_detail_id = fnd_api.g_miss_num
	then

		  VALIDATE_COST_DETAILS
		            (
				 p_api_name          => l_api_name,
				 pv_cost_rec          => l_cost_rec,
				 p_validation_mode   => 'U'     ,
				 p_user_id           => p_user_id,
				 p_login_id          => p_login_id,
				 x_cost_rec          => lx_cost_rec,
				 x_msg_data          => x_msg_data,
				 x_msg_count         => x_msg_count,
				 x_return_status     => l_return_status
			    );


			   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
			      FND_MESSAGE.Set_Name('CS', 'CS_COST_VALIDATE_COST_DTL_ER');
			      FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
			      FND_MSG_PUB.Add;
			      RAISE FND_API.G_EXC_ERROR;
			    END IF;

		IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
		THEN
				FND_LOG.String
		    ( FND_LOG.level_procedure ,
		      L_LOG_MODULE || '',
		     'After Validating the Cost Details '
		    );

		END IF;

		lv_cost_id := lx_cost_rec.cost_id;

	end if;
END IF;

	IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
	THEN
		FND_LOG.String
		( FND_LOG.level_procedure ,
		  L_LOG_MODULE || '',
		 'Before Cost Calculations'
		);
	    END IF;


/*
if sign(lx_cost_rec.extended_cost)= -1
then

    Add_Invalid_Argument_Msg(l_api_name_full,
                             to_char(lx_cost_rec.extended_cost),
                             'Extended Cost ');
    RAISE FND_API.G_EXC_ERROR;

end if;
*/

if sign(lx_cost_rec.quantity) = 0
then


    Add_Invalid_Argument_Msg(l_api_name_full,
                             to_char(lx_cost_rec.quantity),
                             'Quantity ');
    RAISE FND_API.G_EXC_ERROR;

end if;


p_cost_id := lv_cost_id;

open get_flag;
fetch get_flag into v_unit_cost,
	   v_extended_cost,
	   v_override_ext_cost_flag  ;
close get_flag;


l_override_ext_cost_flag:=v_override_ext_cost_flag;
l_unit_cost :=v_unit_cost;
if lx_cost_rec.extended_cost is not null
and lx_cost_rec.extended_cost <> fnd_api.g_miss_num then

	--l_unit_cost := NULL;
	--lx_cost_rec.quantity	  := NULL;
	l_unit_cost := v_unit_cost;
	l_override_ext_cost_flag :='Y';
	L_RECALC_COST := 'N';  --If extended cost is passed then need not recalculate the unit cost/extended cost

end if;



if L_RECALC_COST = 'Y' then
	IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
	THEN
	FND_LOG.String
	    ( FND_LOG.level_procedure ,
	      L_LOG_MODULE || '',
	     'Recalcualting the Cost'
	    );
         END IF;
--Bug 7193528
    if l_create_charge_flag ='N' then
         --l_cost_org_id  := p_cost_rec.inventory_org_id;

         get_sr_org_info        ( p_incident_id         => lx_cost_rec.incident_id,
	                          x_org_id              => l_cost_org_id,
			          x_inv_organization_id => l_cost_inv_org_id  ,
			          x_msg_data            => x_msg_data,
				  x_msg_count           => x_msg_count,
				  x_return_status       => l_return_status
				  );

      else

         l_cost_inv_org_id  :=lx_cost_rec.inventory_org_id;
	 l_cost_org_id      :=lx_cost_rec.org_id;

	    if  l_cost_Rec.estimate_Detail_id is null then

	       get_sr_org_info  ( p_incident_id         => lx_cost_rec.incident_id,
	                          x_org_id              => l_cost_org_id,
			          x_inv_organization_id => l_cost_inv_org_id  ,
			          x_msg_data            => x_msg_data,
				  x_msg_count           => x_msg_count,
				  x_return_status       => l_return_status
				);
	    end if;

      end if;

--Calculate the Item's Unit Cost
	l_unit_cost := CST_COST_API.Get_Item_Cost
					(
					p_api_version		=> 1.0,
					p_inventory_item_id	=> lx_cost_rec.inventory_item_id,
					p_organization_id	=> lx_cost_rec.org_id,
					p_cost_group_id		=> p_cost_group_id,
					p_cost_type_id		=> p_cost_type_id
					);

	--Calculate the Item's Extended Cost
		If lx_cost_rec.extended_cost IS  NULL or lx_cost_rec.extended_cost = fnd_api.g_miss_num
		THEN
		     lx_cost_rec.extended_cost :=l_unit_cost*lx_cost_rec.quantity;
		     l_override_ext_cost_flag :='N';
		Else

		     --l_unit_cost := NULL;
		     --l_quantity  := NULL;
		     l_override_ext_cost_flag :='Y';

		END IF;

end if ;

	IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
		THEN
	   FND_LOG.String
	    ( FND_LOG.level_procedure ,
	      L_LOG_MODULE || '',
	     'Before calling the Update_Row Procedure'
	    );
	    END IF;


CS_COST_DETAILS_PKG.Update_Row
	(
		p_cost_id		=>lx_cost_rec.cost_id			,
		p_incident_id		=>lx_cost_rec.incident_id		,
		p_estimate_detail_id	=>lx_cost_rec.estimate_detail_id	,
		p_transaction_type_id	=>lx_cost_rec.transaction_type_id	,
		p_txn_billing_type_id	=>lx_cost_rec.txn_billing_type_id	,
		--p_charge_line_type	=>lx_cost_rec.charge_line_type		,
		p_inventory_item_id	=>lx_cost_rec.inventory_item_id		,
		p_quantity		=>lx_cost_rec.quantity			,
		p_unit_cost		=>l_unit_cost				,
		p_extended_cost		=>lx_cost_rec.extended_cost		,
		p_override_ext_cost_flag =>l_override_ext_cost_flag		,
		p_transaction_date	=>sysdate				,
		p_source_id		=>lx_cost_rec.source_id			,
		p_source_code		=>lx_cost_rec.source_code		,
		p_unit_of_measure_code	=>lx_cost_rec.unit_of_measure_code	,
		p_currency_code		=>lx_cost_rec.currency_code		,
		p_org_id		=>l_cost_org_id 			,
		p_inventory_org_id	=>l_cost_inv_org_id      		,
		p_attribute1		=>lx_cost_rec.attribute1		,
		p_attribute2		=>lx_cost_rec.attribute2		,
		p_attribute3		=>lx_cost_rec.attribute3		,
		p_attribute4		=>lx_cost_rec.attribute4		,
		p_attribute5		=>lx_cost_rec.attribute5		,
		p_attribute6		=>lx_cost_rec.attribute6		,
		p_attribute7		=>lx_cost_rec.attribute7		,
		p_attribute8		=>lx_cost_rec.attribute8		,
		p_attribute9		=>lx_cost_rec.attribute9		,
		p_attribute10		=>lx_cost_rec.attribute10		,
		p_attribute11		=>lx_cost_rec.attribute11		,
		p_attribute12		=>lx_cost_rec.attribute12		,
		p_attribute13		=>lx_cost_rec.attribute13		,
		p_attribute14		=>lx_cost_rec.attribute14		,
		p_attribute15		=>lx_cost_rec.attribute15		,
		p_last_update_date	=> sysdate				,
		p_last_updated_by	=> FND_GLOBAL.USER_ID			,
		p_last_update_login	=> FND_GLOBAL.LOGIN_ID			,
		p_created_by		=> FND_GLOBAL.USER_ID			,
		p_creation_date	        =>  sysdate				,
		x_object_version_number => l_object_version_number
	);



 -- Standard check of p_commit
	  IF FND_API.To_Boolean(p_commit) THEN
	   COMMIT ;

	  END IF;

-- Standard call to get message count and if count is 1, get message info
  FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data
    );


EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN
   IF FND_API.To_Boolean(p_transaction_control) THEN
      ROLLBACK TO Update_Cost_Details_PVT;
   END IF ;
   x_return_status := FND_API.G_RET_STS_ERROR;
   FND_MSG_PUB.Count_And_Get(
        p_count    => x_msg_count,
        p_data     => x_msg_data,
        p_encoded  => FND_API.G_FALSE) ;

WHEN G_WARNING THEN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF FND_API.To_Boolean(p_transaction_control) THEN
      ROLLBACK TO Update_Cost_Details_PVT;
   END IF ;
   FND_MSG_PUB.Count_And_Get(p_count    => x_msg_count,
                                p_data     => x_msg_data,
                                p_encoded  => FND_API.G_FALSE) ;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   IF FND_API.To_Boolean(p_transaction_control) THEN
      ROLLBACK TO Update_Cost_Details_PVT;
   END IF ;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data,
                                p_encoded => FND_API.G_FALSE) ;
WHEN OTHERS THEN
   IF FND_API.To_Boolean(p_transaction_control) THEN
      ROLLBACK TO Update_Cost_Details_PVT;
   END IF ;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
     FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
   END IF;
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                 p_data  => x_msg_data,
                                p_encoded => FND_API.G_FALSE) ;


END Update_Cost_Details;

/*======================================================================+
  ==
  ==  Procedure name      : delete_cost_details
  ==  Comments            : API to Update cost details in cs_cost_details
  ==  Modification History:
  ==
  ==  Date        Name       Desc
  ==  ----------  ---------  ---------------------------------------------
  ==  15-DEC-2007 | BKANIMOZ   | Created the procedure
  ========================================================================*/


 PROCEDURE Delete_Cost_Details
 (
             p_api_version          IN         NUMBER,
             p_init_msg_list        IN         VARCHAR2,
             p_commit               IN         VARCHAR2 ,
             p_validation_level     IN         NUMBER   ,
             x_return_status        OUT NOCOPY VARCHAR2,
             x_msg_count            OUT NOCOPY NUMBER,
             x_msg_data             OUT NOCOPY VARCHAR2,
             p_transaction_control  IN         VARCHAR2 ,
             p_cost_id		    IN         NUMBER   := NULL
)IS


   l_api_name       CONSTANT  VARCHAR2(100) := 'Delete_Cost_Details' ;
   l_api_name_full  CONSTANT  VARCHAR2(61) := G_PKG_NAME || '.' || l_api_name ;
   l_log_module     CONSTANT VARCHAR2(255) := 'csxvcstb.plsl.' || l_api_name_full || '.';
   l_api_version    CONSTANT  NUMBER       := 1.0 ;

   l_resp_appl_id          NUMBER  ;
   l_resp_id               NUMBER  ;
   l_user_id               NUMBER  ;
   l_login_id              NUMBER  ;
   l_org_id                NUMBER          := NULL ;
   l_charge_line_type      VARCHAR2(30);
   l_return_status         VARCHAR2(1) ;
   l_valid_check	   VARCHAR2(1);

BEGIN

--Standard Start of API Savepoint
   IF FND_API.To_Boolean( p_transaction_control ) THEN
      SAVEPOINT   Delete_Cost_Details_PVT ;
    END IF ;
--Standard Call to check API compatibility
   IF NOT FND_API.Compatible_API_Call(l_api_version,     p_api_version,     l_api_name,     G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
   END IF ;
--Initialize the message list  if p_msg_list is set to TRUE
   IF FND_API.To_Boolean(p_init_msg_list)   THEN
      FND_MSG_PUB.initialize ;
    END IF ;

  --Initialize the API Return Success to True
  x_return_status := FND_API.G_RET_STS_SUCCESS ;

----------------------- FND Logging -----------------------------------
  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || 'start'
    , 'Inside ' || L_API_NAME_FULL || ', called with parameters below:'
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_api_version:' || p_api_version
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_init_msg_list:' || p_init_msg_list
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_commit:' || p_commit
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_validation_level:' || p_validation_level
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_transaction_control:' || p_transaction_control
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_cost_id' || p_cost_id
    );

  END IF;

 IF (p_cost_id  IS NULL) THEN
    Add_Null_Parameter_Msg(l_api_name_full,
                           'p_cost_id') ;
    RAISE FND_API.G_EXC_ERROR ;
  END IF ;

IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
	  FND_LOG.String
	    ( FND_LOG.level_procedure ,
	      L_LOG_MODULE || '',
	     'Before  Do_Cost_Line_Exist'
	    );
END IF;

 l_valid_check:=  Do_cost_line_Exist
		 (
		  l_api_name_full,
		  p_cost_id,
		  l_return_status
		  ) ;
   IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      Add_Invalid_Argument_Msg(l_api_name,
                              TO_CHAR(p_cost_id),
                               'cost_id');
      RAISE G_WARNING;
   ELSIF l_return_status = G_RET_STS_ERROR THEN
     Add_Invalid_Argument_Msg(l_api_name,
                               TO_CHAR(p_cost_id),
                               'cost_id');
     RAISE G_WARNING;
   END IF;

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     RAISE G_WARNING ;
  END IF ;

  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
      FND_LOG.String
      ( FND_LOG.level_procedure ,
      L_LOG_MODULE || '',
     'Before Do_charge_line_Exist'
    );
END IF;

--if there is a charge line existing for this cost then do not delete this cost line

l_valid_check:=  Do_charge_line_Exist
			  (
			   l_api_name_full,
			   p_cost_id,
			   l_return_status
			   ) ;

   if l_valid_check ='Y' then
	FND_MESSAGE.SET_NAME('CS', 'CS_COST_CANNOT_DELETE');
	FND_MSG_PUB.ADD;
	RAISE G_WARNING;
   end if;


delete from cs_cost_details where
cost_id = p_cost_id;

  --End of API Body
  --Standard Check of p_commit
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK ;
  END IF ;

  --Standard call to get  message count and if count is 1 , get message info
  FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
                            p_data => x_msg_data) ;

  --Begin Exception Handling

EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN
   IF FND_API.To_Boolean( p_transaction_control ) THEN
      ROLLBACK TO Delete_Cost_Details_PVT;
   END IF ;
   x_return_status :=  FND_API.G_RET_STS_ERROR ;
   FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                            p_data  => x_msg_data,
                            p_encoded => FND_API.G_FALSE) ;

WHEN G_WARNING THEN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF FND_API.To_Boolean(p_transaction_control) THEN
      ROLLBACK TO Delete_Cost_Details_PVT;
   END IF ;
      FND_MSG_PUB.Count_And_Get(p_count    => x_msg_count,
                                p_data     => x_msg_data,
                                p_encoded  => FND_API.G_FALSE) ;

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   IF FND_API.To_Boolean( p_transaction_control ) THEN
      ROLLBACK TO  Delete_Cost_Details_PVT;
   END IF ;
     x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                             p_data  => x_msg_data,
                            p_encoded => FND_API.G_FALSE) ;

WHEN OTHERS THEN
   IF FND_API.To_Boolean( p_transaction_control ) THEN
      ROLLBACK TO  Delete_Cost_Details_PVT;
   END IF ;
   x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR ;
  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
  THEN
     FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME,l_api_name);
  END IF ;
  FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                            p_data  => x_msg_data,
                            p_encoded => FND_API.G_FALSE) ;

End Delete_Cost_Details;

/*======================================================================+
  ==
  ==  Procedure name      : Validate_cost_details
  ==  Comments            : API to Update cost details in cs_cost_details
  ==  Modification History:
  ==
  ==  Date        Name       Desc
  ==  ----------  ---------  ---------------------------------------------
  ==  15-DEC-2007 | BKANIMOZ   | Created the procedure
  ========================================================================*/

PROCEDURE VALIDATE_COST_DETAILS
(
	 p_api_name                  IN            VARCHAR2,
	 pv_cost_rec                 IN            CS_COST_DETAILS_PUB.COST_REC_TYPE,
	 p_validation_mode           IN            VARCHAR2,
	 p_user_id                   IN            NUMBER,
	 p_login_id                  IN            NUMBER,
	 x_cost_rec                  OUT NOCOPY    CS_COST_DETAILS_PUB.COST_REC_TYPE,
	 x_msg_data                  OUT NOCOPY    VARCHAR2,
	 x_msg_count                 OUT NOCOPY    NUMBER,
	 x_return_status             OUT NOCOPY    VARCHAR2
 ) IS

   l_valid_check   VARCHAR2(1);
   l_return_status VARCHAR2(1) ;
   l_msg_data      VARCHAR2(2000);
   l_msg_count     NUMBER;
   l_api_version   NUMBER                   :=  1.0 ;
   l_api_name      CONSTANT VARCHAR2(100)    := 'Validate_Cost_Details Private API' ;
   l_api_name_full CONSTANT VARCHAR2(61)    :=  G_PKG_NAME || '.' || l_api_name ;
   l_log_module    CONSTANT VARCHAR2(255)   := 'csxvcstb.pls' || l_api_name_full || '.';
   l_db_det_rec                           CS_COST_DETAILS%ROWTYPE;
   l_source_id     NUMBER;
   l_org_id        NUMBER;
   l_profile       VARCHAR2(200);
   l_primary_uom   VARCHAR2(10);
   l_currency_code VARCHAR2(10);

   l_disallow_new_charge        VARCHAR2(1);
   l_disallow_charge_update     VARCHAR2(1);
   l_disallow_request_update	VARCHAR2(1);
   l_create_charge_flag		VARCHAR2(1);
   l_create_cost_flag		VARCHAR2(1);

   l_txn_billing_type_id   NUMBER;
   l_inv_item_id           NUMBER;
   l_line_order_category_code VARCHAR2(10);
   l_no_charge             VARCHAR2(1);
   lx_quantity             NUMBER;

BEGIN

   IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
   THEN
         FND_LOG.String
	( FND_LOG.level_procedure ,
	L_LOG_MODULE || '',
	'Inside Validate_Cost_Details'
	);
   END IF;

   IF p_validation_mode = 'U' THEN

      IF pv_cost_rec.cost_id IS NULL OR
      pv_cost_rec.cost_id = FND_API.G_MISS_NUM THEN
         Add_Null_Parameter_Msg(l_api_name,'cost_id') ;
         Add_Invalid_Argument_Msg(l_api_name,TO_CHAR(pv_cost_rec.estimate_detail_id),'cost_id');
         RAISE FND_API.G_EXC_ERROR;
      ELSE -- validate the cost id passed
         IF IS_COST_ID_VALID(p_cost_id => pv_cost_rec.cost_id,
                             x_msg_data           => l_msg_data,
                             x_msg_count          => l_msg_count,
                             x_return_status      => l_return_status) = 'U' THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

         ELSIF IS_COST_ID_VALID( p_cost_id => pv_cost_rec.cost_id,
                                 x_msg_data           => l_msg_data,
                                 x_msg_count          => l_msg_count,
                                 x_return_status      => l_return_status) = 'N' THEN
            Add_Invalid_Argument_Msg(l_api_name,TO_CHAR(pv_cost_rec.cost_id),'cost_id');
            RAISE FND_API.G_EXC_ERROR;
          ELSE
        --cost id is valid
        --assign to out record
        x_cost_Rec.cost_id := pv_cost_rec.cost_id;
        -- Get existing cost  record for this estimate detail_id
        Get_Cost_Detail_Rec   (P_API_NAME            => l_api_name_full,
                              P_COST_ID              => pv_cost_rec.cost_id,
                              x_COST_DETAIL_REC      => l_db_det_rec,
                              x_MSG_DATA             => l_msg_data,
                              x_MSG_COUNT            => l_msg_count,
                              x_RETURN_STATUS        => l_return_status);


		if (l_return_status = fnd_api.g_ret_sts_error) then
		  RAISE FND_API.G_EXC_ERROR;
		elsif (l_return_status = fnd_api.g_ret_sts_unexp_error) then
		  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		end if;
           END IF;
      END IF;
  END IF;

     IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
     THEN
	FND_LOG.String
	( FND_LOG.level_procedure ,
	 L_LOG_MODULE || '',
	 'After Cost_Id Validation'
	 );
     END IF;

   IF pv_cost_rec.quantity  <> l_db_det_rec.quantity and pv_cost_rec.quantity <> fnd_api.g_miss_num  THEN
	-- cost will be recalculated if  quantity changes during updation
	l_recalc_cost := 'Y';
   END IF;
	x_cost_rec:=pv_cost_rec;

------------------------------------------------------------------------
	/* 1. Incident ID - Mandatory, If null or invalid throw Error message and stop processing
	*/

if p_validation_mode ='I' then
	if pv_cost_rec.incident_id is not null then

		     l_valid_check := IS_INCIDENT_ID_VALID
					   (
					    p_incident_id         => pv_cost_rec.incident_id,
					    x_msg_data            => l_msg_data,
					    x_msg_count           => l_msg_count,
					    x_return_status       => l_return_status
					    );
			     if l_return_status = g_ret_sts_unexp_error then
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			      ELSIF l_return_status = G_RET_STS_ERROR THEN
				RAISE FND_API.G_EXC_ERROR;
			      END IF;

		if l_valid_check ='Y' then
		   x_cost_rec.incident_id := pv_cost_rec.incident_id;
		else  --throw the error message and stop processing
		   Add_Invalid_Argument_Msg(l_api_name,
					 pv_cost_rec.incident_id,
					 'incident_id');

		    RAISE FND_API.G_EXC_ERROR;
		end if;

	else
		Add_Null_Parameter_Msg(l_api_name,'p_incident_id') ;
		RAISE FND_API.G_EXC_ERROR;
	end if;

elsif p_validation_mode ='U' then
 -- Incident Id will not change, hence assign from the database
 x_cost_rec.incident_id :=l_db_det_rec.incident_id;

end if;

	IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
	  THEN
		FND_LOG.String
		( FND_LOG.level_procedure ,
		 L_LOG_MODULE || '',
		'After Incident_ID Validation'
		);
	    END IF;


----------------------------------------------------------------------------------------------------------
	/* 2.Transaction_type_ID - Mandatory, If null or invalid throw Error message and stop processing
	*/

IF p_validation_mode = 'U' THEN


	if     pv_cost_rec.transaction_type_id  = FND_API.G_MISS_NUM OR
	        pv_cost_rec.transaction_type_id IS NULL THEN

	       --Default attributes using db record
	       x_cost_rec.transaction_type_id := l_db_det_rec.transaction_type_id;

	else
	       --validate teh transaction type id passed

			VALIDATE_TRANSACTION_TYPE_ID
					       (
						p_api_name                 => p_api_name,
						p_transaction_type_id      => pv_cost_rec.transaction_type_id,
						x_line_order_category_code => l_line_order_category_code,
						x_msg_data                 => l_msg_data,
						x_msg_count                => l_msg_count,
						x_return_status            => l_return_status
						) ;

		if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		  RAISE FND_API.G_EXC_ERROR ;
		end if;

		--assign the values source_code, source_id to out record
		  x_cost_rec.transaction_type_id := pv_cost_rec.transaction_type_id;
		  l_transaction_type_changed := 'Y';
       	          lx_quantity :=pv_cost_rec.quantity ;

	  if pv_cost_rec.quantity = FND_API.G_MISS_NUM OR
             pv_cost_rec.quantity = null
	  then
             lx_quantity :=l_db_det_rec.quantity;
	  end if ;

	  IF (l_line_order_category_code = 'RETURN')  then
	     if  lx_quantity is not null
	     then
	         if sign(pv_cost_rec.quantity) = -1 then
	            x_cost_rec.quantity :=  lx_quantity;
		 else
		   --assign -ve qty to out record
		     x_cost_rec.quantity := ( lx_quantity * -1);
		  end if;
              end if;
           Else
	      if   lx_quantity is not null then
	         if sign( lx_quantity ) = -1 then
		-- need to make this positive as no -ve quantity for orders
                    x_cost_rec.quantity  := ( lx_quantity  * -1);
                 else
		    x_cost_rec.quantity :=  lx_quantity ;
		 end if;
	      end if;
	   End if;
	end if;
END IF;--validation mode

----------------------------------------------------------------------------------------------------------
	/* 3. Check for the Status Flags - Mandatory,
	      If null or invalid throw Error message and stop processing
         */


/*
When the costs are created from charges lines and the "Disallow Charge" flag is Yes (checked)
the behavior should be the same as the current behavior so no records should be created.
If the "Disallow Charge Update" flag is Yes (checked) then we should not allow updates for charges or costs.

However, for the scenario when Create Charge="N" and Create Cost="Y"
we should not validate the flags since the costs are not dependent on the charge creation.
In this case we should create the costs.

The costs should not be created only if the Disallow Request Update is Yes (checked).
*/


	get_charge_flags_from_sr
	(
	   p_api_name			=> p_api_name,
	   p_incident_id		=> x_cost_rec.incident_id,
	   p_transaction_type_id	=> pv_cost_rec.transaction_type_id,
	   x_create_charge_flag		=> l_create_charge_flag,
	   x_create_cost_flag		=> l_create_cost_flag,
	   x_disallow_request_update	=> l_disallow_request_update,
	   x_disallow_new_charge	=> l_disallow_new_charge,
	   x_disallow_charge_update	=> l_disallow_charge_update,
	   x_msg_data			=> l_msg_data,
	   x_msg_count			=> l_msg_count,
	   x_return_status		=> l_return_status
	);

	IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
	  THEN
	FND_LOG.String
	    ( FND_LOG.level_procedure ,
	      L_LOG_MODULE || '',
	     'l_create_cost_flag: '||l_create_cost_flag||'l_create_charge_flag: '||l_create_charge_flag
	    );

	FND_LOG.String
	    ( FND_LOG.level_procedure ,
	      L_LOG_MODULE || '',
	     'l_disallow_request_update: '||l_disallow_request_update||'l_disallow_new_charge: '||l_disallow_new_charge||
	     'l_disallow_charge_update: '||l_disallow_charge_update
	    );
	END IF;


IF p_validation_mode = 'I' THEN
	If l_create_charge_flag ='N' and l_create_cost_flag =  'Y'  then
		    if   l_disallow_request_update='Y' THEN


		     FND_MESSAGE.SET_NAME('CS', 'CS_COST_CANNOT_INSERT');
		     FND_MSG_PUB.ADD;
		     RAISE FND_API.G_EXC_ERROR;
		    end if;

	Else
	          if l_disallow_new_charge  = 'Y' OR l_disallow_request_update='Y' THEN


		     FND_MESSAGE.SET_NAME('CS', 'CS_COST_CANNOT_INSERT');
		     FND_MSG_PUB.ADD;
		     RAISE FND_API.G_EXC_ERROR;
		  end if;

	end if;

ELSIF p_validation_mode = 'U' THEN


  If l_create_charge_flag ='N' and l_create_cost_flag =  'Y'  then
		    if   l_disallow_request_update='Y' THEN
		     FND_MESSAGE.SET_NAME('CS', 'CS_COST_CANNOT_UPDATE');
		     FND_MSG_PUB.ADD;
		     RAISE FND_API.G_EXC_ERROR;
		    end if;

	Else
	          if l_disallow_charge_update  = 'Y' OR l_disallow_request_update='Y' THEN

		     FND_MESSAGE.SET_NAME('CS', 'CS_COST_CANNOT_UPDATE');
		     FND_MSG_PUB.ADD;
		     RAISE FND_API.G_EXC_ERROR;
		  end if;

	end if;

 END IF;

----------------------------------------------------------------------------------------------------------
	/* 4. Check for the  Estimate Detail ID
	      If null or invalid throw Error message and stop processing
         */

if p_validation_mode ='I' then

	if pv_cost_rec.estimate_Detail_id  is not null then

		     l_valid_check := IS_ESTIMATE_DETAIL_ID_VALID
					   (
					    p_estimate_detail_id  => pv_cost_rec.estimate_detail_id,
					    x_msg_data            => l_msg_data,
					    x_msg_count           => l_msg_count,
					    x_return_status       => l_return_status
					    );
			     IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			      ELSIF l_return_status = G_RET_STS_ERROR THEN
				RAISE FND_API.G_EXC_ERROR;
			      END IF;

		if l_valid_check ='Y' then
		   x_cost_rec.estimate_detail_id := pv_cost_rec.estimate_detail_id ;
		else  --throw the error message and stop processing
		   Add_Invalid_Argument_Msg(l_api_name,
					    pv_cost_rec.estimate_Detail_id,
					 'estimate_detail_id');
		    RAISE FND_API.G_EXC_ERROR;
		end if;

	else -- if null ,  then just assign
	    x_cost_rec.estimate_Detail_id := pv_cost_rec.estimate_detail_id;

	end if;
elsif p_validation_mode ='U' then
 -- Estimate Detail Id will not change for the cost_id, hence assign from the database

 x_cost_rec.estimate_detail_id :=l_db_det_rec.estimate_Detail_id;

end if;


 IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
FND_LOG.String
    ( FND_LOG.level_procedure ,
      L_LOG_MODULE || '',
     'After Estimate_Detail_ID Validation'
    );
END IF;

----------------------------------------------

	/* 5. Source Id and Source Code Mandatory
	      validate the source id and source code against the respective tables
	*/



  IF p_validation_mode = 'I' THEN
	if pv_cost_rec.source_id  is not null and pv_cost_rec.source_code is not null  then

		 VALIDATE_SOURCE
				       (
						p_api_name         => p_api_name,
						p_source_code      => pv_cost_rec.source_code,
						p_source_id        => pv_cost_rec.source_id,
						--x_source_code      => l_source_code,
						x_source_id        => l_source_id,
						x_msg_data         => l_msg_data,
						x_msg_count        => l_msg_count,
						x_return_status    => l_return_status
					) ;
			 If l_return_status = G_RET_STS_UNEXP_ERROR then
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
			elsif l_return_status = G_RET_STS_ERROR then
					RAISE FND_API.G_EXC_ERROR;
			end if;

			  x_cost_Rec.source_id   := l_source_id;
			  x_cost_rec.source_code := pv_cost_rec.source_code;


	else

		Add_Null_Parameter_Msg(l_api_name,
				     'p_source_id') ;
/*
		Add_Invalid_Argument_Msg(l_api_name,
				       to_char(pv_cost_rec.incident_id),
				       'source_id');*/
		RAISE FND_API.G_EXC_ERROR;
	end if;

 ELSIF p_validation_mode = 'U' THEN

	if     pv_cost_rec.source_code  = FND_API.G_MISS_CHAR OR
	       pv_cost_rec.source_code IS NULL AND
	       pv_cost_rec.source_id = FND_API.G_MISS_NUM OR
	       pv_cost_rec.source_id IS NULL THEN

	       --Default attributes using db record
	       x_cost_rec.source_code := l_db_det_rec.source_code;
	       x_cost_rec.source_id   := l_db_det_rec.source_id;
	else

			VALIDATE_SOURCE
					       (
						p_api_name         => p_api_name,
						p_source_code      => pv_cost_rec.source_code,
						p_source_id        => pv_cost_rec.source_id,
						--x_source_code      => l_source_code,
						x_source_id        => l_source_id,
						x_msg_data         => l_msg_data,
						x_msg_count        => l_msg_count,
						x_return_status    => l_return_status
						) ;

		if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		  RAISE FND_API.G_EXC_ERROR ;
		end if;

		--assign the values source_code, source_id to out record
		x_cost_rec.source_code := x_cost_rec.source_code;
		x_cost_rec.source_id   := x_cost_rec.source_id;


	end if;

END IF;--validation_mode
	IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
	THEN
	FND_LOG.String
	( FND_LOG.level_procedure ,
	L_LOG_MODULE || '',
	'After Source Id and Source Code Validation'
	);
	 END IF;
---------------------------------------------------
	/* 5. Operating Unit
		Check if the passed value for the org_id is mandatory .
		If not passed then default it from the Multi Org Setup  --get this clarified

	*/

/*Validation Logic

1 If create_charge_flag =N then
      1 if org id is passed validate it and assign it to the out record
      2 if not passed then assign the  multi org id to the out record

2.If create_charge_flag ='Y', then there will be an additional check for the profile
        'Service:Allow Charge Operating Unit Update'
   IF the profile is set to 'Y' then
	1.If Org _id is passed then validate that org id and assign it to  the out rec
	2.If org id is not passed then assign the  Multi Org Id
   If Profile is set to 'N'
      1.If Org Id is passed
                 1. Check this with the Multi Org id.If not equal Throw an error message
                 2.If equal assign it to the OUT record
      2 If Org Id is not passed assign  Multi Org id to the out record
*/

--Get the Multi Org ID

	 CS_Multiorg_PUB.Get_OrgId
	 (
			P_API_VERSION       => 1.0,
			P_INIT_MSG_LIST     => FND_API.G_FALSE,
			-- Fix bug 3236597 P_COMMIT            => 'T',
			P_COMMIT            => 'F',  -- Fix bug 3236597
			P_VALIDATION_LEVEL  => FND_API.G_VALID_LEVEL_FULL,
			X_RETURN_STATUS     => l_return_status,
			X_MSG_COUNT         => l_msg_count,
			X_MSG_DATA          => l_msg_data,
			P_INCIDENT_ID       => pv_cost_rec.incident_id,
			X_ORG_ID            => l_org_id,
			X_PROFILE           => l_profile
         );





	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	    RAISE FND_API.G_EXC_ERROR ;
	  END IF;

	 IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
		THEN
		FND_LOG.String
		    ( FND_LOG.level_procedure ,
		      L_LOG_MODULE || '',
		     'Mutli Org ID l_org_id : '||l_org_id||'l_profile :'||l_profile
		    );
	END IF;


IF p_validation_mode = 'I' THEN
   IF l_create_charge_flag ='Y'  then
	   IF l_profile = 'Y' THEN

		   if pv_cost_rec.org_id is not null then

			VALIDATE_ORG_ID
			               (
					  P_API_NAME       => l_api_name,
					  P_ORG_ID         => pv_cost_rec.org_id,
					  X_RETURN_STATUS  => l_return_status,
					  X_MSG_COUNT      => l_msg_count,
					  X_MSG_DATA       => l_msg_data
				      );


				if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
				  RAISE FND_API.G_EXC_ERROR ;
				end if;
			  x_cost_rec.org_id := pv_cost_rec.org_id;
		    else

			--use the default
			x_cost_rec.org_id := l_org_id;
		    end if;
	    else
	      -- l_profile = 'N'--Service:Allow Charge Operating Unit Update
	      if pv_cost_rec.org_id is not null then

--	      dbms_output.put_line('                    OU 1 l_profile : '||l_profile||pv_cost_rec.org_id||'-'||l_org_id);
			if pv_cost_rec.org_id <> l_org_id then
			  --raise error
			  --Need to define error here
			  FND_MESSAGE.SET_NAME('CS', 'CS_CHG_CANNOT_CHANGE_OU');
			  FND_MESSAGE.SET_TOKEN('API_NAME', p_api_name);
			  FND_MSG_PUB.ADD;
			  RAISE FND_API.G_EXC_ERROR;
			else
			  x_cost_rec.org_id := pv_cost_rec.org_id;
			end if;
	      else
		--pv_cost_rec.org_id is null
		--assign default
		x_cost_rec.org_id := l_org_id;
	      end if;
	  end if;--l_profile
ELSE --flags create_charge_flag='N'


		if pv_cost_rec.org_id is not null then

			VALIDATE_ORG_ID(
				  P_API_NAME       => l_api_name,
				  P_ORG_ID         => pv_cost_rec.org_id,
				  X_RETURN_STATUS  => l_return_status,
				  X_MSG_COUNT      => l_msg_count,
				  X_MSG_DATA       => l_msg_data
				  );

				if l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
				  RAISE FND_API.G_EXC_ERROR ;
				end if;
			  x_cost_rec.org_id := pv_cost_rec.org_id;
		    else
			--use the default
			x_cost_rec.org_id := l_org_id;
		    end if;

END IF;--flags

 ELSIF p_validation_mode = 'U' THEN


IF l_create_charge_flag ='Y'  then
    IF l_profile = 'Y' THEN

      -- If l_profile = 'Y' THEN if org_id is not passed
      -- or org_id is null then assign the value from the database
      -- else if passed then validate the org_id and if valid then
      -- assign the value to the out parameter

      if pv_cost_rec.org_id = FND_API.G_MISS_NUM or
         pv_cost_rec.org_id IS NULL THEN
         --use the value from the database
         x_cost_rec.org_id := l_db_det_rec.org_id;

      else

        VALIDATE_ORG_ID(
				  P_API_NAME       => l_api_name,
				  P_ORG_ID         => pv_cost_rec.org_id,
				  X_RETURN_STATUS  => l_return_status,
				  X_MSG_COUNT      => l_msg_count,
				  X_MSG_DATA       => l_msg_data);

        if l_return_status <> fnd_api.g_ret_sts_success then
          raise fnd_api.g_exc_error ;
        end if;
        x_cost_rec.org_id := pv_cost_rec.org_id;

      end if;

    ELSE
      -- l_profile = 'N'
      -- If l_profile = 'N' THEN if org_id is not passed
      -- or org_id is null then assign the value from the database
      -- else if passed then validate the org_id and if valid then
      -- assign the value to the out parameter

      IF pv_cost_rec.org_id = FND_API.G_MISS_NUM OR
         pv_cost_rec.org_id IS NULL THEN
        --use the value from the database
        x_cost_rec.org_id := l_db_det_rec.org_id;

      ELSE
        IF pv_cost_rec.org_id <> l_db_det_rec.org_id THEN
          --raise error
          FND_MESSAGE.SET_NAME('CS', 'CS_CHG_CANNOT_CHANGE_OU');
          FND_MESSAGE.SET_TOKEN('API_NAME', p_api_name);
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          x_cost_rec.org_id := pv_cost_rec.org_id;
        END IF;
      END IF;
    END IF;-- profile
    END IF;
else--if create_charge_flag='N'

if pv_cost_rec.org_id = FND_API.G_MISS_NUM or
         pv_cost_rec.org_id IS NULL THEN
         --use the value from the database
         x_cost_rec.org_id := l_db_det_rec.org_id;

      else
        VALIDATE_ORG_ID(
				  P_API_NAME       => l_api_name,
				  P_ORG_ID         => pv_cost_rec.org_id,
				  X_RETURN_STATUS  => l_return_status,
				  X_MSG_COUNT      => l_msg_count,
				  X_MSG_DATA       => l_msg_data);

        if l_return_status <> fnd_api.g_ret_sts_success then
          raise fnd_api.g_exc_error ;
        end if;
        x_cost_rec.org_id := pv_cost_rec.org_id;

      end if;

  END IF;--validation mode

   IF x_cost_rec.org_id  <> l_db_det_rec.org_id  THEN
          -- Item is changed so recalculate the cost.
           --cost will be recalculated if item,ou or quantity changes during updation
           l_recalc_cost := 'Y' ;
	   --dbms_output.put_line('l_recalc_cost ORG changes');
   END IF;
IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
	THEN
FND_LOG.String
    ( FND_LOG.level_procedure ,
      L_LOG_MODULE || '',
     'After Org_ID Validation'
    );
END IF;
--------------------------------------------------------
	/* 5.Item Validation
	*/



 IF p_validation_mode = 'I' THEN
 --Added for the Debrief flow
/* If the SAC setup is Create Charge = 'No' and Create Cost ='Yes' and no item is passed,
 then retrieve the inv. item from the profile Service: Default Inventory Item for Labor Transactions
 and proceed with the rest of the logic
 If the profile value is null, and no item is passed by the calling program,
 then raise an error message and abort the process.*/
 l_no_charge :='N';
            Get_Item_from_Profile(
			  P_TRANSACTION_TYPE_ID   =>pv_cost_rec.transaction_type_id,
			  p_inv_item_id	          =>pv_cost_rec.inventory_item_id  ,
			  p_no_charge             =>l_no_charge,
			  x_inv_item_id           =>l_inv_item_id,
			  x_msg_data            => l_msg_data,
			  x_msg_count           => l_msg_count,
			  x_return_status       => l_return_status
			  );
	    if l_no_charge = 'Y' then
	        if l_inv_item_id is null  then
	             Add_Null_Parameter_Msg(l_api_name,
						     'p_inventory_item_id') ;
	             RAISE FND_API.G_EXC_ERROR;
                     else
                       x_cost_rec.inventory_item_id:=l_inv_item_id;
                end if;
	      end if;

 if l_no_charge <> 'Y' then
	if pv_cost_rec.inventory_item_id is not null then

		    l_valid_check :=      IS_ITEM_VALID
					   (
					    p_org_id             =>  x_cost_rec.org_id,
					    p_inventory_item_id  =>  pv_cost_rec.inventory_item_id,
					    x_msg_data            => l_msg_data,
					    x_msg_count           => l_msg_count,
					    x_return_status       => l_return_status
					    );



		if l_valid_check ='Y' then

		   x_cost_rec.inventory_item_id  := pv_cost_rec.inventory_item_id ;
		else  --throw the error message and stop processing
		   Add_Invalid_Argument_Msg(l_api_name,
					to_char(pv_cost_rec.inventory_item_id),
					 'inventory_item_id');

		    RAISE FND_API.G_EXC_ERROR;
		end if;

	else

	       Add_Null_Parameter_Msg(l_api_name,
				     'p_inventory_item_id') ;
/*		Add_Invalid_Argument_Msg(l_api_name,
				       to_char(pv_cost_rec.inventory_item_id),
				       'inventory_item_id');*/
		RAISE FND_API.G_EXC_ERROR;

	end if;
  end if;
ELSIF p_validation_mode = 'U' THEN

	if     pv_cost_rec.inventory_item_id  = FND_API.G_MISS_NUM OR
	       pv_cost_rec.inventory_item_id IS NULL
       then

        --Default attributes using db record
	       x_cost_rec.inventory_item_id := l_db_det_rec.inventory_item_id;

	 else

              l_valid_check :=      IS_ITEM_VALID
					   (
					    p_org_id             =>  x_cost_rec.org_id,
					    p_inventory_item_id  =>  x_cost_rec.inventory_item_id,
					    x_msg_data            => l_msg_data,
					    x_msg_count           => l_msg_count,
					    x_return_status       => l_return_status
					    );

		if l_valid_check ='Y' then
		--assign the values inventory_item_id to out record
		   x_cost_rec.inventory_item_id  := pv_cost_rec.inventory_item_id ;
		else  --throw the error message and stop processing
		   Add_Invalid_Argument_Msg(l_api_name,
					to_char(pv_cost_rec.inventory_item_id),
					 'inventory_item_id');

		    RAISE FND_API.G_EXC_ERROR;
		end if;
        end if;


        IF x_cost_rec.inventory_item_id <> l_db_det_rec.inventory_item_id THEN
          -- Item is changed so recalculate the cost.
           --cost will be recalculated if item,ou or quantity changes during updation
           l_recalc_cost := 'Y' ;
           l_item_changed := 'Y';
        END IF;


END IF; --validation_mode

IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
	THEN

FND_LOG.String
    ( FND_LOG.level_procedure ,
      L_LOG_MODULE || '',
     'After Item Id Validation'
    );
END If;





 IF p_validation_mode = 'I' THEN
	if pv_cost_rec.inventory_org_id is not null then

		    l_valid_check := IS_TXN_INV_ORG_VALID
		            (p_txn_inv_org   =>   pv_cost_rec.inventory_org_id,
                            --p_org_id         => l_org_id,
                            p_org_id           => x_cost_rec.org_id,
                            x_msg_data         => l_msg_data,
                            x_msg_count        => l_msg_count,
                            x_return_status    => l_return_status  ) ;



		if l_valid_check ='Y' then

		   x_cost_rec.inventory_org_id  := pv_cost_rec.inventory_org_id ;
		else  --throw the error message and stop processing
		   Add_Invalid_Argument_Msg(l_api_name,
					to_char(pv_cost_rec.inventory_org_id),
					 'inventory_org_id');

		    RAISE FND_API.G_EXC_ERROR;
		end if;




	end if;

ELSIF p_validation_mode = 'U' THEN

	if     pv_cost_rec.inventory_org_id  = FND_API.G_MISS_NUM OR
	       pv_cost_rec.inventory_org_id IS NULL
       then

        --Default attributes using db record
	       x_cost_rec.inventory_org_id := l_db_det_rec.inventory_org_id;

	 else

             l_valid_check := IS_TXN_INV_ORG_VALID
			  (p_txn_inv_org   =>  pv_cost_rec.inventory_org_id,
                            --p_org_id         => l_org_id,
                            p_org_id           => x_cost_rec.org_id,
                            x_msg_data         => l_msg_data,
                            x_msg_count        => l_msg_count,
                            x_return_status    => l_return_status  ) ;

		if l_valid_check ='Y' then
		--assign the values inventory_org_id to out record
		   x_cost_rec.inventory_org_id  := pv_cost_rec.inventory_org_id ;
		else  --throw the error message and stop processing
		   Add_Invalid_Argument_Msg(l_api_name,
					to_char(pv_cost_rec.inventory_org_id),
					 'inventory_org_id');

		    RAISE FND_API.G_EXC_ERROR;
		end if;
        end if;



END IF; --validation_mode

IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
	THEN

FND_LOG.String
    ( FND_LOG.level_procedure ,
      L_LOG_MODULE || '',
     'After Inventory Org Id Validation'
    );
END If;



	 --------------------------------------------------------
	/* 5.transaction Billing Type  Validation
		*/

IF p_validation_mode = 'I' THEN

    get_txn_billing_type(p_api_name            => p_api_name,
                         p_inv_id              => x_cost_rec.inventory_item_id,
                         p_txn_type_id         => x_cost_rec.transaction_type_id,
                         x_txn_billing_type_id => l_txn_billing_type_id,
                         x_msg_data            => l_msg_data,
                         x_msg_count           => l_msg_count,
                         x_return_status       => l_return_status);


      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR ;
      ELSE
        IF pv_cost_rec.txn_billing_type_id IS NOT NULL THEN
		IF pv_cost_rec.txn_billing_type_id <> l_txn_billing_type_id THEN
		  --RAISE ERROR
		  FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INVALID_TXN_BILLING_TYP');
		  FND_MESSAGE.SET_TOKEN('TXN_BILLING_TYPE_ID', pv_cost_rec.txn_billing_type_id);
		  FND_MSG_PUB.ADD;
		  RAISE FND_API.G_EXC_ERROR;
		ELSE --
		  --the ids match
		  --assign to the out record
		  x_cost_rec.txn_billing_type_id := pv_cost_rec.txn_billing_type_id ;


		END IF;

        ELSE
          -- pv_cost_rec.txn_billing_type_id is null
          -- assign l_txn_billing_type_id to out record
          x_cost_rec.txn_billing_type_id := l_txn_billing_type_id;
        END IF;
        VALIDATE_OPERATING_UNIT(p_api_name            => l_api_name_full,
			  p_txn_billing_type_id => l_txn_billing_type_id,
			  x_return_status       => l_return_status,
			  x_msg_count           => l_msg_count,
			  x_msg_data            => l_msg_data);

	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          FND_MESSAGE.SET_NAME('CS', 'CS_COST_INVALID_OU_BILLING_TYP');
	  FND_MESSAGE.SET_TOKEN('TXN_BILLING_TYPE_ID', pv_cost_rec.txn_billing_type_id);
	  FND_MSG_PUB.ADD;
	  RAISE FND_API.G_EXC_ERROR;
	End if;

      END IF;
  ELSIF p_validation_mode = 'U' THEN

    IF l_item_changed = 'Y' OR
       l_transaction_type_changed = 'Y' THEN

      --need to get the txn billing type for changed parameters

      GET_TXN_BILLING_TYPE(P_API_NAME            => p_api_name,
                           P_INV_ID              => x_cost_rec.inventory_item_id,
                           P_TXN_TYPE_ID         => x_cost_rec.transaction_type_id,
                           X_TXN_BILLING_TYPE_ID => l_txn_billing_type_id,
                           X_MSG_DATA            => l_msg_data,
                           X_MSG_COUNT           => l_msg_count,
                           X_RETURN_STATUS       => l_return_status);

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR ;
      ELSE
        VALIDATE_OPERATING_UNIT(p_api_name            => p_api_name,
			  p_txn_billing_type_id => l_txn_billing_type_id,
			  x_return_status       => l_return_status,
			  x_msg_count           => l_msg_count,
			  x_msg_data            => l_msg_data);

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR ;
        ELSE
	  IF pv_cost_rec.txn_billing_type_id  <> FND_API.G_MISS_NUM AND
		 pv_cost_rec.txn_billing_type_id IS NOT NULL THEN
	    IF pv_cost_rec.txn_billing_type_id <> l_txn_billing_type_id THEN

		  --RAISE ERROR
		  FND_MESSAGE.SET_NAME('CS', 'CS_CHG_INVALID_TXN_BILLING_TYP');
		  FND_MESSAGE.SET_TOKEN('TXN_BILLING_TYPE_ID', pv_cost_rec.txn_billing_type_id);
		  FND_MSG_PUB.ADD;
		  RAISE FND_API.G_EXC_ERROR;
	    ELSE --
		  --the ids match
		  --assign to the out record
		  x_cost_rec.txn_billing_type_id := pv_cost_rec.txn_billing_type_id ;
	    END IF;
	  ELSE
		-- pv_cost_rec.txn_billing_type_id is not passed
		-- assign l_txn_billing_type_id to out record
		x_cost_rec.txn_billing_type_id := l_txn_billing_type_id;
	  END IF;
        END IF;
      END IF;
    ELSE

      -- niether the item nor the transaction type is changed
      -- assign the billing type from db
      x_cost_rec.txn_billing_type_id := l_db_det_rec.txn_billing_type_id;

    END IF;

    --DBMS_OUTPUT.PUT_LINE('Completed the txn billing type id');

  END IF;

IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
	THEN
	FND_LOG.String
    ( FND_LOG.level_procedure ,
      L_LOG_MODULE || '',
     'After Billing Type Validation'
    );
    END IF;



	 --------------------------------------------------------


	 /* 6.Unit of Measure
		Check if the passed value for the UOM  is valid
		If not passed then default the  Item' primary UOM
	*/



   IF p_validation_mode = 'I' THEN

	 IF pv_cost_rec.unit_of_measure_code IS NOT NULL THEN

	       l_valid_check := IS_UOM_VALID
	                     (
				p_inv_id        => x_cost_rec.inventory_item_id,
				p_org_id        => x_cost_rec.org_id,
				p_uom_code      => pv_cost_rec.unit_of_measure_code,
				x_msg_data      => l_msg_data,
				x_msg_count     => l_msg_count,
				x_return_status => l_return_status
			);

				IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
				  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				ELSIF l_return_status = G_RET_STS_ERROR THEN
				  RAISE FND_API.G_EXC_ERROR;
				END IF;

	      IF l_valid_check <> 'Y' THEN
		Add_Invalid_Argument_Msg(l_api_name,
					 pv_cost_rec.unit_of_measure_code,
					 'Unit_of_Measure_Code');
		RAISE FND_API.G_EXC_ERROR;

	      ELSE
		--assign to out record
		x_cost_rec.unit_of_measure_code := pv_cost_rec.unit_of_measure_code;
	      END IF;

	    ELSE --If UOM is not passed then default the Item's Primary UOM


	      GET_PRIMARY_UOM(P_INVentory_item_ID        =>    x_cost_rec.inventory_item_id,
			      p_org_id        =>    x_cost_rec.org_id,
			      X_PRIMARY_UOM   =>    l_primary_uom,
			      X_MSG_DATA      =>    l_msg_data ,
			      X_MSG_COUNT     =>    l_msg_count,
			      X_RETURN_STATUS =>    l_return_status);

	      --DBMS_OUTPUT.PUT_LINE('Back from GET_PRIMARY_UOM status='||l_return_status || '   l_primary_uom '||l_primary_uom);

	      --IF l_return_status <> 'S' THEN
	      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		--raise error
		FND_MESSAGE.SET_NAME('CS', 'CS_COST_GET_PRIMARY_UOM_ERROR');
		FND_MESSAGE.SET_TOKEN('INV_ID', x_cost_rec.inventory_item_id);
                FND_MSG_PUB.ADD;
		RAISE FND_API.G_EXC_ERROR;
	      END IF;

	      --assign to out record
	      x_cost_rec.unit_of_measure_code := l_primary_uom;

	    END IF;
ELSIF  p_validation_mode = 'U' THEN

	 IF pv_cost_rec.unit_of_measure_code <> FND_API.G_MISS_CHAR AND
	      pv_cost_rec.unit_of_measure_code IS NOT NULL

	 then


	l_valid_check := IS_UOM_VALID(
					p_inv_id        => x_cost_rec.inventory_item_id,
					p_org_id        => x_cost_rec.org_id,
					p_uom_code      => pv_cost_rec.unit_of_measure_code,
					x_msg_data      => l_msg_data,
					x_msg_count     => l_msg_count,
					x_return_status => l_return_status
					);

					IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
					  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
					ELSIF l_return_status = G_RET_STS_ERROR THEN
					  RAISE FND_API.G_EXC_ERROR;
					END IF;

		      IF l_valid_check <> 'Y' THEN
			Add_Invalid_Argument_Msg(l_api_name,
						 pv_cost_rec.unit_of_measure_code,
						 'Unit_of_Measure_Code');
			RAISE FND_API.G_EXC_ERROR;

		      ELSE
			--assign to out record
			x_cost_rec.unit_of_measure_code := pv_cost_rec.unit_of_measure_code;
		      END IF;

	Else --If UOM is not passed then default the Item's Primary UOM


		      GET_PRIMARY_UOM(P_INVentory_item_ID        =>    x_cost_rec.inventory_item_id,
				      p_org_id        =>    x_cost_rec.org_id,
				      X_PRIMARY_UOM   =>    l_primary_uom,
				      X_MSG_DATA      =>    l_msg_data ,
				      X_MSG_COUNT     =>    l_msg_count,
				      X_RETURN_STATUS =>    l_return_status);



		      --IF l_return_status <> 'S' THEN
		      if l_return_status <> FND_API.G_RET_STS_SUCCESS then
			--raise error
			FND_MESSAGE.SET_NAME('CS', 'CS_COST_GET_PRIMARY_UOM_ERROR');
			FND_MESSAGE.SET_TOKEN('INV_ID', x_cost_rec.inventory_item_id);
			FND_MSG_PUB.ADD;
			RAISE FND_API.G_EXC_ERROR;
		      end if;

		      --assign to out record
		      x_cost_rec.unit_of_measure_code := l_primary_uom;

      End if;
END IF;

IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
	THEN
FND_LOG.String
    ( FND_LOG.level_procedure ,
      L_LOG_MODULE || '',
     'After UOM Validation'
    );
END IF;



-----------------------------------------------
/* 7.Currency Code
		Check if the passed value for the Currenc  is valid
		If not passed then default the  Currency from the Service Request Operating Unit
*/

 IF p_validation_mode = 'I' THEN

	 IF pv_cost_rec.currency_code IS NOT NULL THEN

	       l_valid_check := IS_CURRENCY_CODE_VALID
	                     (
				p_currency_Code => pv_cost_rec.currency_code,
				x_msg_data      => l_msg_data,
				x_msg_count     => l_msg_count,
				x_return_status => l_return_status
			);

				IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
				  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				ELSIF l_return_status = G_RET_STS_ERROR THEN
				  RAISE FND_API.G_EXC_ERROR;
				END IF;

	      IF l_valid_check <> 'Y' THEN
		Add_Invalid_Argument_Msg(l_api_name,
					 pv_cost_rec.currency_code,
					 'Currency Code');
		RAISE FND_API.G_EXC_ERROR;

	      ELSE
		--assign to out record
		x_cost_rec.currency_code := pv_cost_rec.currency_code;
	      END IF;

	    ELSE --If UOM is not passed then default the Item's Primary UOM


	      get_currency_code
	                     (
			      p_org_id           =>    x_cost_rec.org_id,
			      X_CURRENCY_CODE    =>    l_currency_code,
			      X_MSG_DATA         =>    l_msg_data ,
			      X_MSG_COUNT        =>    l_msg_count,
			      X_RETURN_STATUS    =>    l_return_status);

	      --DBMS_OUTPUT.PUT_LINE('Back from GET_PRIMARY_UOM status='||l_return_status || '   l_primary_uom '||l_primary_uom);

	      --IF l_return_status <> 'S' THEN
	      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		--raise error
		FND_MESSAGE.SET_NAME('CS', 'CS_COST_GET_PRIMARY_UOM_ERROR');
		FND_MESSAGE.SET_TOKEN('INV_ID', pv_cost_rec.unit_of_measure_code);
		FND_MSG_PUB.ADD;
		RAISE FND_API.G_EXC_ERROR;
	      END IF;

	      --assign to out record
	      x_cost_rec.currency_code := l_currency_code;

	    END IF;
ELSIF  p_validation_mode = 'U' THEN

	 IF pv_cost_rec.currency_code<> FND_API.G_MISS_CHAR AND
	      pv_cost_rec.currency_code IS NOT NULL

	 then


	 l_valid_check := IS_CURRENCY_CODE_VALID
	                     (
				p_currency_Code => pv_cost_rec.currency_code,
				x_msg_data      => l_msg_data,
				x_msg_count     => l_msg_count,
				x_return_status => l_return_status
			);

				IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
				  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				ELSIF l_return_status = G_RET_STS_ERROR THEN
				  RAISE FND_API.G_EXC_ERROR;
				END IF;

	      IF l_valid_check <> 'Y' THEN
		Add_Invalid_Argument_Msg(l_api_name,
					 pv_cost_rec.currency_code,
					 'Currency Code');
		RAISE FND_API.G_EXC_ERROR;

	      ELSE
		--assign to out record
		x_cost_rec.currency_code := pv_cost_rec.currency_code;
	      END IF;

	Else --If UOM is not passed then default the Item's Primary UOM


		      get_currency_code
	                     (
			      p_org_id           =>    x_cost_rec.org_id,
			      X_CURRENCY_CODE    =>    l_currency_code,
			      X_MSG_DATA         =>    l_msg_data ,
			      X_MSG_COUNT        =>    l_msg_count,
			      X_RETURN_STATUS    =>    l_return_status);




	      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		--raise error
		FND_MESSAGE.SET_NAME('CS', 'CS_COST_GET_PRIMARY_UOM_ERROR');
		FND_MESSAGE.SET_TOKEN('INV_ID', pv_cost_rec.unit_of_measure_code);
		FND_MSG_PUB.ADD;
		RAISE FND_API.G_EXC_ERROR;
	      END IF;

	      --assign to out record
	      x_cost_rec.currency_code := l_currency_code;


      End if;
END IF;

IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
	THEN
FND_LOG.String
    ( FND_LOG.level_procedure ,
      L_LOG_MODULE || '',
     'After Currency Code Validation'
    );
END IF;


EXCEPTION


 WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

         FND_MSG_PUB.Count_And_Get(p_count    => x_msg_count,
                                p_data     => x_msg_data,
                                p_encoded  => FND_API.G_FALSE) ;
WHEN OTHERS  THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MSG_PUB.Count_And_Get(p_count    => x_msg_count,
                                p_data     => x_msg_data,
                                p_encoded  => FND_API.G_FALSE) ;




END VALIDATE_COST_DETAILS;


--=============================
-- Record_Is_Locked_msg
--=============================

PROCEDURE Record_Is_Locked_Msg
( p_token_an	VARCHAR2
)
IS

BEGIN

    FND_MESSAGE.Set_Name('CS', 'CS_API_ALL_CANT_LOCK_RECORD');
    FND_MESSAGE.Set_Token('API_NAME', p_token_an);
    FND_MSG_PUB.Add;
END Record_IS_Locked_Msg;


PROCEDURE Validate_Who_Info(
                 P_API_NAME                  IN            VARCHAR2,
                 P_USER_ID                   IN            NUMBER,
                 P_LOGIN_ID                  IN            NUMBER,
                 X_RETURN_STATUS             OUT NOCOPY    VARCHAR2) IS

  CURSOR c_user IS
  SELECT 1
  FROM   fnd_user
  WHERE  user_id = p_user_id
  AND    TRUNC(SYSDATE) <= start_date
  AND    NVL(end_date, SYSDATE) >= SYSDATE;

  CURSOR c_login IS
  SELECT 1
  FROM   fnd_logins
  WHERE  login_id = p_login_id
  AND    user_id = p_user_id;

  l_dummy  VARCHAR2(1);

BEGIN

   x_return_status :=  FND_API.G_RET_STS_SUCCESS;

   BEGIN
      IF p_user_id = -1 then
         SELECT 'x' into l_dummy
         FROM    fnd_user
         WHERE   user_id = p_user_id;
      ELSE
         SELECT 'x' into l_dummy
         FROM    fnd_user
         WHERE   user_id = p_user_id
         AND trunc(sysdate) BETWEEN trunc(nvl(start_date, sysdate))
         AND trunc(nvl(end_date, sysdate));
      END IF;

      EXCEPTION
      WHEN NO_DATA_FOUND THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         Add_Invalid_Argument_Msg(p_token_an => p_api_name,
                                  p_token_v  => TO_CHAR(p_user_id),
                                  p_token_p  => 'p_user_id');
      return;
   END;

   IF p_login_id is not null then
   BEGIN
      SELECT 'x' into l_dummy
      FROM       fnd_logins
      WHERE   login_id = p_login_id
      AND        user_id  = p_user_id;

      EXCEPTION
      WHEN NO_DATA_FOUND THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         Add_Invalid_Argument_Msg(p_token_an => p_api_name,
                                  p_token_v  => TO_CHAR(p_login_id),
                                  p_token_p  => 'p_user_login');
   END;
   END IF;

END Validate_Who_Info;
/**************************************************
Private Procedure Body TO_NULL
**************************************************/

 PROCEDURE TO_NULL(p_cost_rec_in             IN		cs_cost_details_pub.Cost_Rec_Type,
                   p_cost_rec_out	     OUT NOCOPY cs_cost_details_pub.Cost_Rec_Type) IS
 BEGIN
	p_cost_rec_out.cost_id                := Check_For_Miss(p_cost_rec_in.cost_id) ;
	p_cost_rec_out.incident_id            := Check_For_Miss(p_cost_rec_in.incident_id) ;
	p_cost_rec_out.estimate_Detail_id     := Check_For_Miss(p_cost_rec_in.estimate_Detail_id) ;
	p_cost_rec_out.charge_line_type       := Check_For_Miss(p_cost_rec_in.charge_line_type) ;
	p_cost_rec_out.transaction_type_id    := Check_For_Miss(p_cost_rec_in.transaction_type_id) ;
	p_cost_rec_out.txn_billing_type_id    := Check_For_Miss(p_cost_rec_in.txn_billing_type_id) ;
	p_cost_rec_out.inventory_item_id      := Check_For_Miss(p_cost_rec_in.inventory_item_id) ;
	p_cost_rec_out. quantity              := Check_For_Miss(p_cost_rec_in. quantity) ;
	p_cost_rec_out.unit_of_measure_code   := Check_For_Miss(p_cost_rec_in.unit_of_measure_code) ;
	p_cost_rec_out.currency_code          := Check_For_Miss(p_cost_rec_in.currency_code) ;
	p_cost_rec_out.source_id              := Check_For_Miss(p_cost_rec_in.source_id) ;
	p_cost_rec_out.source_code            := Check_For_Miss(p_cost_rec_in.source_code) ;
	p_cost_rec_out.org_id                 := Check_For_Miss(p_cost_rec_in.org_id) ;
	p_cost_rec_out.inventory_org_id	      := Check_For_Miss(p_cost_rec_in.inventory_org_id) ;
	--p_cost_rec_out.unit_cost	      := Check_For_Miss(p_cost_rec_in.unit_cost) ;
	p_cost_rec_out.extended_cost          := Check_For_Miss(p_cost_rec_in.extended_cost) ;
	--p_cost_rec_out.override_ext_cost_flag := Check_For_Miss(p_cost_rec_in.override_ext_cost_flag) ;
--	p_cost_rec_out.transaction_date       := Check_For_Miss(p_cost_rec_in.transaction_date) ;
	p_cost_rec_out.attribute1             := Check_For_Miss(p_cost_rec_in.attribute1) ;
	p_cost_rec_out.attribute2             := Check_For_Miss(p_cost_rec_in.attribute2) ;
	p_cost_rec_out.attribute3             := Check_For_Miss(p_cost_rec_in.attribute3) ;
	p_cost_rec_out.attribute4             := Check_For_Miss(p_cost_rec_in.attribute4) ;
	p_cost_rec_out.attribute5             := Check_For_Miss(p_cost_rec_in.attribute5) ;
	p_cost_rec_out.attribute6             := Check_For_Miss(p_cost_rec_in.attribute6) ;
	p_cost_rec_out.attribute7             := Check_For_Miss(p_cost_rec_in.attribute7) ;
	p_cost_rec_out.attribute8             := Check_For_Miss(p_cost_rec_in.attribute8) ;
	p_cost_rec_out.attribute9             := Check_For_Miss(p_cost_rec_in.attribute9) ;
	p_cost_rec_out.attribute10            := Check_For_Miss(p_cost_rec_in.attribute10) ;
	p_cost_rec_out.attribute11            := Check_For_Miss(p_cost_rec_in.attribute11) ;
	p_cost_rec_out.attribute12            := Check_For_Miss(p_cost_rec_in.attribute12) ;
	p_cost_rec_out.attribute13            := Check_For_Miss(p_cost_rec_in.attribute13) ;
	p_cost_rec_out.attribute14            := Check_For_Miss(p_cost_rec_in.attribute14) ;
	p_cost_rec_out.attribute15            := Check_For_Miss(p_cost_rec_in.attribute15) ;
END TO_NULL;

/*************************************************
Function Implementations
**************************************************/
FUNCTION  Check_For_Miss ( p_param  IN  NUMBER ) RETURN NUMBER IS
BEGIN

  IF p_param = FND_API.G_MISS_NUM THEN
       RETURN NULL ;
  ELSE
    RETURN p_param ;
  END IF ;
END Check_For_Miss ;


FUNCTION  Check_For_Miss ( p_param  IN  VARCHAR2 ) RETURN VARCHAR2 IS
BEGIN
  IF p_param = FND_API.G_MISS_CHAR THEN
     RETURN NULL ;
  ELSE
    RETURN p_param ;
  END IF ;
END Check_For_Miss ;


FUNCTION  Check_For_Miss ( p_param  IN  DATE ) RETURN DATE IS
BEGIN
  IF p_param = FND_API.G_MISS_DATE THEN
     RETURN NULL ;
  ELSE
    RETURN p_param ;
  END IF ;
END Check_For_Miss ;

--------------------------------------------------------------------------------
--  Procedure Name            :   PURGE_COST
--
--  Parameters (other than standard ones)
--  IN
--      p_object_type         :   Type of object for which this procedure is
--                                being called. (Here it will be 'SR')
--      p_processing_set_id   :   Id that helps the API in identifying the
--                                set of SRs for which the child objects have
--                                to be deleted.
--
--  Description
--      This procedure physically deletes all the cost lines attached to
--      a service request. It reads the list of SRs for which the cost lines
--      have to be deleted from the global temp table, looking only for rows
--      having the purge_status as NULL. Using Set processing, the procedure
--      deletes all the cost lines attached to such SRs.
--
--  HISTORY
--
----------------+------------+--------------------------------------------------
--  DATE        | UPDATED BY | Change Description
----------------+------------+--------------------------------------------------
--  26-dec-2007 | bkanimoz   | Created
--              |            |
----------------+------------+--------------------------------------------------
PROCEDURE Purge_Cost
(
  p_api_version_number IN  NUMBER := 1.0
, p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE
, p_commit             IN  VARCHAR2 := FND_API.G_FALSE
, p_object_type        IN  VARCHAR2
, p_processing_set_id  IN  NUMBER
, x_return_status      OUT NOCOPY  VARCHAR2
, x_msg_count          OUT NOCOPY  NUMBER
, x_msg_data           OUT NOCOPY  VARCHAR2
)
IS
--------------------------------------------------------------------------------

L_API_VERSION   CONSTANT NUMBER       := 1.0;
L_API_NAME      CONSTANT VARCHAR2(30) := 'PURGE_COST';
L_API_NAME_FULL CONSTANT VARCHAR2(61) := G_PKG_NAME || '.' || L_API_NAME;
L_LOG_MODULE    CONSTANT VARCHAR2(255) := 'csxvcstb.plsql.' || L_API_NAME_FULL || '.';

l_row_count     NUMBER := 0;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'start'
    , 'Inside ' || L_API_NAME_FULL || ', called with parameters below:'
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 1'
    , 'p_api_version_number:' || p_api_version_number
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 2'
    , 'p_init_msg_list:' || p_init_msg_list
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 3'
    , 'p_commit:' || p_commit
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 4'
    , 'p_object_type:' || p_object_type
    );
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'param 5'
    , 'p_processing_set_id:' || p_processing_set_id
    );
  END IF ;

  IF NOT FND_API.Compatible_API_Call
  (
    L_API_VERSION
  , p_api_version_number
  , L_API_NAME
  , G_PKG_NAME
  )
  THEN
    FND_MSG_PUB.Count_And_Get
    (
      p_count => x_msg_count
    , p_data  => x_msg_data
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF ;

  IF FND_API.to_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF ;

  ------------------------------------------------------------------------------
  -- Parameter Validations:
  ------------------------------------------------------------------------------

  IF NVL(p_object_type, 'X') <> 'SR'
  THEN
    IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_unexpected
      , L_LOG_MODULE || 'object_type_invalid'
      , 'p_object_type has to be SR.'
      );
    END IF ;

    FND_MESSAGE.Set_Name('CS', 'CS_SR_PARAM_VALUE_ERROR');
    FND_MESSAGE.Set_Token('API_NAME', L_API_NAME_FULL);
    FND_MESSAGE.Set_Token('PARAM', 'p_object_type');
    FND_MESSAGE.Set_Token('CURRVAL', p_object_type);
    FND_MSG_PUB.ADD;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  ---

  IF p_processing_set_id IS NULL
  THEN
    IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_unexpected
      , L_LOG_MODULE || 'proc_set_id_invalid'
      , 'p_processing_set_id should not be NULL.'
      );
    END IF ;

    FND_MESSAGE.Set_Name('CS', 'CS_SR_PARAM_VALUE_ERROR');
    FND_MESSAGE.Set_Token('API_NAME', L_API_NAME_FULL);
    FND_MESSAGE.Set_Token('PARAM', 'p_processing_set_id');
    FND_MESSAGE.Set_Token('CURRVAL', NVL(to_char(p_processing_set_id),'NULL'));
    FND_MSG_PUB.ADD;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  ------------------------------------------------------------------------------
  -- Actual Logic starts below:
  ------------------------------------------------------------------------------

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'del_cost_line_start'
    , 'deleting cost lines against SRs in the global temp table'
    );
  END IF ;

  -- Delete all the estimate lines that correspond to the
  -- SRs that are available for purge after validations.

  DELETE /*+ index(e) */ cs_cost_details e
  WHERE
    incident_id IN
    (
    SELECT /*+ no_unnest no_semijoin cardinality(10) */
        object_id
    FROM
        jtf_object_purge_param_tmp
    WHERE
        processing_set_id = p_processing_set_id
    AND object_type = 'SR'
    AND NVL(purge_status, 'S') = 'S'
    );

  l_row_count := SQL%ROWCOUNT;

  IF FND_LOG.level_statement >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_statement
    , L_LOG_MODULE || 'del_chg_line_end'
    , 'after deleting cost lines against SRs in the global temp table'
      || l_row_count || ' rows deleted.'
    );
  END IF ;

  ---

  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    (
      FND_LOG.level_procedure
    , L_LOG_MODULE || 'end'
    , 'Completed work in ' || L_API_NAME_FULL || ' successfully'
    );
  END IF ;

EXCEPTION
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_unexpected
      , L_LOG_MODULE || 'unexpected_error'
      , 'Inside WHEN FND_API.G_EXC_UNEXPECTED_ERROR of ' || L_API_NAME_FULL
      );
    END IF ;

	WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.Set_Name('CS', 'CS_COST_LINE_DEL_FAIL');
    FND_MESSAGE.Set_Token('API_NAME', L_API_NAME_FULL);
    FND_MESSAGE.Set_Token('ERROR', SQLERRM);
    FND_MSG_PUB.ADD;

    IF FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level
    THEN
      FND_LOG.String
      (
        FND_LOG.level_unexpected
      , L_LOG_MODULE || 'when_others'
      , 'Inside WHEN OTHERS of ' || L_API_NAME_FULL || '. Oracle Error was:'
      );
      FND_LOG.String
      (
        FND_LOG.level_unexpected
      , L_LOG_MODULE || 'when_others'
      , SQLERRM
      );
    END IF ;
END Purge_Cost;

PROCEDURE  get_currency_converted_value(
                                        p_from_currency IN  VARCHAR2,
                                        p_to_currency   IN  VARCHAR2,
                                        p_value         IN  NUMBER,
                                        p_ou            IN  VARCHAR2,
                                        x_value         OUT NOCOPY NUMBER
                                      ) IS

p_api_name        VARCHAR(100);
l_rate            NUMBER;
l_numerator       NUMBER;
l_denominator     NUMBER;
l_return_status   VARCHAR2(1);
l_call_api        VARCHAR2(1):='Y';
l_conversion_type VARCHAR2(30) :=   FND_PROFILE.VALUE('CS_CHG_DEFAULT_CONVERSION_TYPE');
l_max_roll_days   NUMBER       :=   to_number(FND_PROFILE.VALUE('CS_CHG_MAX_ROLL_DAYS'));
l_from_currency   VARCHAR2(15);

BEGIN

l_from_currency :=p_from_currency;


if l_from_currency is null and p_ou is not null then

   begin
       select currency_code
       into   l_from_currency
       from   gl_sets_of_books
       where   name = p_ou;
   exception
       when no_data_found then
       x_value := p_value;
       l_call_api := 'N';
   end ;

end if;


if l_call_api ='Y' then

   gl_currency_api.get_closest_triangulation_rate
        (
               x_from_currency      =>p_from_currency,
               x_to_currency        => p_to_currency,
               x_conversion_date    => SYSDATE,
               x_conversion_type    => l_conversion_type,--l_conversion_type,
               x_max_roll_days      =>  l_max_roll_days,-- l_max_roll_days,
               x_denominator        => l_denominator,
               x_numerator          => l_numerator,
               x_rate               => l_rate );

x_value := l_rate * p_value;

end if;

EXCEPTION
WHEN OTHERS THEN
x_value:=p_value;
END get_currency_converted_value;


END CS_Cost_Details_PVT;

/
