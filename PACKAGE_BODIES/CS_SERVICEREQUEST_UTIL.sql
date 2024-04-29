--------------------------------------------------------
--  DDL for Package Body CS_SERVICEREQUEST_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SERVICEREQUEST_UTIL" AS
/* $Header: csusrb.pls 120.30.12010000.6 2010/04/03 18:06:51 rgandhi ship $ */

G_ACTION_SUBTYPE CONSTANT VARCHAR2(5) := 'ACT';
G_PKG_NAME          CONSTANT VARCHAR2(30) := 'CS_ServiceRequest_UTIL';
G_TABLE_NAME        CONSTANT VARCHAR2(40) := 'CS_INCIDENTS_ALL_B';
G_TL_TABLE_NAME     CONSTANT VARCHAR2(40) := 'CS_INCIDENTS_ALL_TL';

-- -----------------------------------------------------------------------------
-- Procedure Name : get_org_details
-- Parameter      :
-- IN             : p_org_id             This is a foreign key to table
--                                       mtl_paramters
-- OUT            : x_maint_org          Maintenance organization associated
--                                       with p_org_id
--                : x_eam_enabled_flag   Eam Enabled flag for paramter p_org_id
--                : x_return_status      Indicates success or error condition
--                                       encountered by the procedure
-- Description    : This procedure checks whether party role code exist in
--                  party role table and is active on system date or not.
-- Modification History
-- Date     Name     Description
---------- -------- ------------------------------------------------------------
-- 04/21/05 smisra   Created
-- 08/29/05 smisra   Used NVL in select statement
-- -----------------------------------------------------------------------------
PROCEDURE get_org_details
( p_org_id           IN         NUMBER
, x_eam_enabled_flag OUT NOCOPY VARCHAR2
, x_maint_org_id     OUT NOCOPY NUMBER
, x_master_org_id    OUT NOCOPY NUMBER
, x_return_Status    OUT NOCOPY VARCHAR2
) IS
CURSOR c_org_info IS
  SELECT
    NVL(maint_organization_id,-1)
  , NVL(master_organization_id,-1)
  , NVL(eam_enabled_flag,'X')
  FROM mtl_parameters
  WHERE organization_id = p_org_id;
BEGIN
  OPEN  c_org_info;
  FETCH c_org_info INTO x_maint_org_id, x_master_org_id, x_eam_enabled_flag;
  IF c_org_info % NOTFOUND
  THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  ELSE
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  END IF;
  CLOSE c_org_info;
--
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
    FND_MESSAGE.set_token('P_TEXT','CS_SERVICEREQUEST_UTIL.get_org_details'||'-'||SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END get_org_details;
-- -----------------------------------------------------------------------------
-- Procedure Name : get_status_details
-- Parameter      :
-- IN             : p_status_id             This foreign key to
--                                          cs_incident_statuses_b
-- OUT            : x_close_flag
--                : x_disallow_request_update    Any SR attribute except statrus
--                                               can not be updated.
--                : x_disallow_agent_dispatch    owner update not allowed
--                : x_disallow_product_update    product update not allowed
--                : x_pending_approval_flag      Indicates if a status id is
--                                               used as intermediate status
--                                               in ERES process
--                : x_intermediated_status_id    Intermediate status to be
--                                               used before ERES action
--                : x_approval_action_status_id  Status to be used for
--                                               ERES approval
--                : x_rejection_action_status_id Status to be used for
--                                               ERES rejection
--                : x_return_stauts         indicates if validation failed or
--                                          succeeded
-- Description    : This procedure accesses incident status table and get all
--                  attributes associated with incident status.
-- Modification History
-- Date     Name     Description
-- -------- -------- -----------------------------------------------------------
-- 06/20/05 smisra   Created
-- -----------------------------------------------------------------------------
PROCEDURE get_status_details
( p_status_id                  IN         NUMBER
, x_close_flag                 OUT NOCOPY VARCHAR2
, x_disallow_request_update    OUT NOCOPY VARCHAR2
, x_disallow_agent_dispatch    OUT NOCOPY VARCHAR2
, x_disallow_product_update    OUT NOCOPY VARCHAR2
, x_pending_approval_flag      OUT NOCOPY VARCHAR2
, x_intermediate_status_id     OUT NOCOPY VARCHAR2
, x_approval_action_status_id  OUT NOCOPY VARCHAR2
, x_rejection_action_status_id OUT NOCOPY VARCHAR2
, x_return_status              OUT NOCOPY VARCHAR2
) IS
l_dt DATE;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_dt := trunc(sysdate);
  SELECT
    NVL(close_flag             ,'N')
  , NVL(disallow_request_update,'N')
  , NVL(disallow_agent_dispatch,'N')
  , NVL(disallow_product_update,'N')
  , NVL(pending_approval_flag  ,'N')
  , intermediate_status_id
  , approval_action_status_id
  , rejection_action_status_id
  INTO
    x_close_flag
  , x_disallow_request_update
  , x_disallow_agent_dispatch
  , x_disallow_product_update
  , x_pending_approval_flag
  , x_intermediate_status_id
  , x_approval_action_status_id
  , x_rejection_action_status_id
  FROM
    cs_incident_statuses_b
  WHERE incident_status_id = p_status_id
  --  AND trunc(sysdate) BETWEEN NVL(start_date_active,l_dt)
  --                         AND NVL(end_date_active  ,l_dt)
  ;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    FND_MESSAGE.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
    FND_MESSAGE.set_token ('P_TEXT','CS_SERVICEREQUEST_UTIL.get_status_details'||'-'||SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END get_status_details;
-- -----------------------------------------------------------------------------
-- Procedure Name : get_customer_product_details
-- Parameter      :
-- IN             : p_customer_product_id   This foreign key to
--                                          csi_item_instances table.
-- OUT            :
--                : x_party_source_table    Party source table.
--                : x_party_id              customer product customer Id
--                : x_inv_master_org_id     inventory master org
--                : x_inv_item_id           Inventory item associated with
--                                          customer product
--                : x_maint_org_id          last validation org
--                : x_external_reference    external reference for CP
--                : x_serial_number         CP serail number
--                : x_start_dt_active       Customer product Active from
--                : x_end_dt_active         Customer product Active up to
--                : x_loc_type              Customer product location type.
--                : x_return_stauts         indicates if validation failed or
--                                          succeeded
-- Description    : This procedure accesses customer product table and get
--                  customer product details that a used by customer product
--                  validation procedure
--                  This procedure can be used by current serial number and
--                  external reference validations too.
-- Modification History
-- Date     Name     Description
-- -------- -------- -----------------------------------------------------------
-- 05/10/05 smisra   Created
-- -----------------------------------------------------------------------------
PROCEDURE get_customer_product_details
( p_customer_product_id   IN         NUMBER
, x_party_source_table    OUT NOCOPY VARCHAR2
, x_party_id              OUT NOCOPY NUMBER
, x_inv_master_org_id     OUT NOCOPY NUMBER
, x_inv_item_id           OUT NOCOPY NUMBER
, x_maint_org_id          OUT NOCOPY NUMBER
, x_external_reference    OUT NOCOPY VARCHAR2
, x_serial_number         OUT NOCOPY VARCHAR2
, x_start_dt_active       OUT NOCOPY DATE
, x_end_dt_active         OUT NOCOPY DATE
, x_loc_type              OUT NOCOPY VARCHAR2
, x_return_status         OUT NOCOPY VARCHAR2
) IS

CURSOR  c_cp IS
SELECT
  owner_party_source_table
, owner_party_id
, inv_master_organization_id
, inventory_item_id
, last_vld_organization_id
, active_start_date
, active_end_date
, location_type_code
, external_reference
, serial_number
FROM
  csi_item_instances
WHERE instance_id = p_customer_product_id;
--
BEGIN
  OPEN c_cp;
  FETCH c_cp
  INTO
    x_party_source_table
  , x_party_id
  , x_inv_master_org_id
  , x_inv_item_id
  , x_maint_org_id
  , x_start_dt_active
  , x_end_dt_active
  , x_loc_type
  , x_external_reference
  , x_serial_number
  ;
  IF c_cp%NOTFOUND
  THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  ELSE
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  END IF;
  CLOSE c_cp;
END;
-- -----------------------------------------------------------------------------
-- Procedure Name : get_item_details
-- Parameter      :
-- IN             : p_inv_item_id           inventory item. This paramter and
--                                          p_inventory_org id is a key to
--                                          mtl_system_items_b table.
--                : p_inventory__org_id     inventory organization
-- OUT            : x_enable_flag           indicates if item is enabled
--                : x_serv_req_enabled      indicates if inv item can be used
--                                          in a service request.
--                : x_eam_item_type         indicatea if inv item is an asset
--                : x_start_date_active     Inventory item Active from
--                : x_end_date_active       Inventory item Active up to
--                : x_return_stauts         indicates if validation failed or
--                                          succeeded
-- Description    : This procedure accesses item master table and gets inventory
--                  item details that are used for further validations.
-- Modification History
-- Date     Name     Description
-- -------- -------- -----------------------------------------------------------
-- 05/05/05 smisra   Created
-- 08/29/05 smisra   Used NVL in select statement
-- -----------------------------------------------------------------------------
PROCEDURE get_item_details
( p_inventory_org_id             NUMBER
, p_inv_item_id                  NUMBER
, x_enabled_flag      OUT NOCOPY VARCHAR2
, x_serv_req_enabled  OUT NOCOPY VARCHAR2
, x_eam_item_type     OUT NOCOPY NUMBER
, x_start_date_active OUT NOCOPY DATE
, x_end_date_active   OUT NOCOPY DATE
, x_return_status     OUT NOCOPY VARCHAR2
) IS
BEGIN
  SELECT
    NVL(enabled_flag,'N')
  , NVL(serv_req_enabled_code,'N')
  , NVL(eam_item_type,-1)
  , start_date_active
  , end_date_active
  INTO
    x_enabled_flag
  , x_serv_req_enabled
  , x_eam_item_type
  , x_start_date_active
  , x_end_date_active
  FROM
    mtl_system_items
  WHERE organization_id = p_inventory_org_id
    AND inventory_item_id = p_inv_item_id;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
END;
-- -----------------------------------------------------------------------------
-- Function  Name : get_unassigned_indicator
-- Parameter      :
-- IN             : p_incident_owner_id  NUMBER
--                : p_owner_group_id     NUMBER
-- Description    : This function return unassinged indicator based on owner and
--                  group values
-- Modification History
-- Date     Name     Description
-- -------- -------- -----------------------------------------------------------
-- 03/25/05 smisra   Created
-- -----------------------------------------------------------------------------
FUNCTION get_unassigned_indicator
(p_incident_owner_id IN NUMBER
,p_owner_group_id    IN NUMBER) RETURN NUMBER
IS
BEGIN
  if (p_incident_owner_id IS NOT NULL AND
      p_owner_group_id    IS NOT NULL )
  THEN
    RETURN 3;
  ELSIF (p_incident_owner_id IS     NULL AND
         p_owner_group_id    IS NOT NULL )
  THEN
    RETURN 2;
  ELSIF (p_incident_owner_id IS NOT NULL AND
         p_owner_group_id    IS     NULL )
  THEN
    RETURN 1;
  ELSE
    RETURN 0;
  END IF;
END get_unassigned_indicator;
--
-- The following function are local function. Introduced in 11.5.10
-- Function to derive the correct values to be passed to the cross validation
-- APIs. ie. if the new values is passed, then use the new value, else use
-- the old value. (since decode cannot be used out of a select stmnt. this
-- approach was considered.
--
-- The function is overloaded to handle the 3 data types, number, varchar2
-- and date
FUNCTION GET_RIGHT_NUM (
   p_new_num_value       IN   NUMBER,
   p_old_num_value       IN   NUMBER )
RETURN NUMBER
IS
BEGIN
   if ( p_new_num_value = FND_API.G_MISS_NUM ) then
      return p_old_num_value;
   else
      return p_new_num_value;
   end if;

END  GET_RIGHT_NUM;

FUNCTION GET_RIGHT_CHAR (
   p_new_char_value       IN   VARCHAR2,
   p_old_char_value       IN   VARCHAR2 )
RETURN VARCHAR2
IS
BEGIN
   if ( p_new_char_value = FND_API.G_MISS_CHAR ) then
      return p_old_char_value;
   else
      return p_new_char_value;
   end if;

END  GET_RIGHT_CHAR;

FUNCTION GET_RIGHT_DATE (
   p_new_date_value       IN   DATE,
   p_old_date_value       IN   DATE )
RETURN DATE
IS
BEGIN
   if ( p_new_date_value = FND_API.G_MISS_DATE ) then
      return p_old_date_value;
   else
      return p_new_date_value;
   end if;

END  GET_RIGHT_DATE;

-- --------------------------------------------------------------------------------
-- Convert_Request_Number_To_ID
--	convert a service request number to the corresponding internal ID.
-- --------------------------------------------------------------------------------
PROCEDURE Convert_Request_Number_To_ID  (
	p_api_name		 IN  VARCHAR2,
	p_parameter_name	 IN  VARCHAR2,
	p_request_number	 IN  VARCHAR2,
	p_org_id		 IN  NUMBER := NULL,
 	p_request_id	  	 OUT NOCOPY NUMBER ,
	x_return_status		 OUT NOCOPY VARCHAR2
  ) IS
    l_api_name        CONSTANT VARCHAR2(30)    := 'Convert_Request_Number_To_ID';
    l_api_name_full   CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;
  BEGIN
    -- Initialize Return Status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    BEGIN
	  SELECT incident_id INTO p_request_id
	  FROM cs_incidents_all_b
	  WHERE incident_number = p_request_number ;
    EXCEPTION
	WHEN NO_DATA_FOUND THEN
	   x_return_status := FND_API.G_RET_STS_ERROR;
	   Add_Invalid_Argument_Msg( p_token_an    => l_api_name_full,
				     p_token_v     => p_request_number,
				     p_token_p     => p_parameter_name,
                                     p_table_name  => G_TABLE_NAME,
                                     p_column_name => 'INCIDENT_NUMBER' );
	WHEN OTHERS THEN
	      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
	      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
	      fnd_msg_pub.ADD;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    END;
  END Convert_Request_Number_To_ID;
-- --------------------------------------------------------------------------------
--  Convert_Type_To_ID
--	convert a service request or action type to the corresponding internal ID.
-- --------------------------------------------------------------------------------
  PROCEDURE Convert_Type_To_ID (
	p_api_name		IN  VARCHAR2,
	p_parameter_name	IN  VARCHAR2,
	p_type_name		IN  VARCHAR2,
	p_subtype		IN  VARCHAR2,
	p_parent_type_id	IN  NUMBER := FND_API.G_MISS_NUM,
 	p_type_id		OUT NOCOPY NUMBER,
	x_return_status		OUT NOCOPY VARCHAR2
  ) IS
  l_api_name         CONSTANT VARCHAR2(30)    := 'Convert_Type_To_ID';
  l_api_name_full    CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

  BEGIN
    -- Initialize Return Status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_subtype = G_ACTION_SUBTYPE  THEN
	IF p_parent_type_id = FND_API.g_MISS_NUM THEN
	-- the subtype is 'ACT' and the user did not pass in parent_type_id
	-- it is possible that multiple rows will be returned and hence TOO_MANY_ROWS
	-- exception must be handled
	    BEGIN
	          SELECT incident_type_id INTO p_type_id
		  FROM cs_incident_types_vl
		  WHERE incident_subtype = p_subtype
		  AND   UPPER(name)  = UPPER(p_type_name);

	    EXCEPTION
		WHEN NO_DATA_FOUND THEN
		   x_return_status := FND_API.G_RET_STS_ERROR;
	           Add_Invalid_Argument_Msg( p_token_an    => l_api_name_full,
				     	     p_token_v     => p_type_name,
				     	     p_token_p     => p_parameter_name,
                                             p_table_name  => 'CS_INCIDENT_TYPES_VL',
                                             p_column_name => 'NAME' );
		WHEN TOO_MANY_ROWS THEN
		   x_return_status := FND_API.G_RET_STS_ERROR;
	           Add_Duplicate_Value_Msg( p_token_an    => l_api_name_full,
				     	    p_token_p     => p_parameter_name,
                                            p_table_name  => 'CS_INCIDENT_TYPES_VL',
                                            p_column_name => 'NAME' );
		WHEN OTHERS THEN
	      	   fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
	           fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
	           fnd_msg_pub.ADD;
	           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	    END;
	ELSE
	      -- the subtype is 'ACT' and the user did pass in parent_type_id
	      -- it is not possible that multiple rows will be returned and hence TOO_MANY_ROWS
	      -- exception need not be handled
	      BEGIN
	          SELECT incident_type_id INTO p_type_id
		  FROM cs_incident_types_vl
		  WHERE incident_subtype = p_subtype
		  AND   UPPER(name)  = UPPER(p_type_name)
		  AND   ((parent_incident_type_id = p_parent_type_id)
			 OR (parent_incident_type_id IS NULL
			     AND p_parent_type_id IS NULL));

	      EXCEPTION
		WHEN NO_DATA_FOUND THEN
		   x_return_status := FND_API.G_RET_STS_ERROR;
	           Add_Invalid_Argument_Msg( p_token_an    => l_api_name_full,
				     	     p_token_v     => p_type_name,
				     	     p_token_p     => p_parameter_name,
                                             p_table_name  => 'CS_INCIDENT_TYPES_VL',
                                             p_column_name => 'NAME' );
		WHEN OTHERS THEN
	           fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
	           fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
	           fnd_msg_pub.ADD;
	           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	      END;
	   END IF;
   ELSE
        -- if this is a SR type
	BEGIN
		SELECT incident_type_id INTO p_type_id
		  FROM cs_incident_types_vl
		  WHERE incident_subtype = p_subtype
		  AND   UPPER(name)  = UPPER(p_type_name)
                  AND   TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date_active, SYSDATE))
                  AND   TRUNC(NVL(end_date_active, SYSDATE))
                  AND   rownum<2;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
	   	   x_return_status := FND_API.G_RET_STS_ERROR;
	           Add_Invalid_Argument_Msg( p_token_an    => l_api_name_full,
				     	     p_token_v     => p_type_name,
				     	     p_token_p     => p_parameter_name,
                                             p_table_name  => 'CS_INCIDENT_TYPES_VL',
                                             p_column_name => 'NAME' );
		WHEN OTHERS THEN
	           fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
	           fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
	           fnd_msg_pub.ADD;
	           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	END;
   END IF;
  END Convert_Type_To_ID;

-- --------------------------------------------------------------------------------
-- Convert_Status_To_ID
--	convert a service request or action status to the corresponding internal ID.
-- --------------------------------------------------------------------------------

  PROCEDURE Convert_Status_To_ID (
	p_api_name			 IN   VARCHAR2,
	p_parameter_name		 IN   VARCHAR2,
	p_status_name			 IN   VARCHAR2,
	p_subtype			 IN   VARCHAR2,
 	p_status_id		    	 OUT  NOCOPY NUMBER,
	x_return_status			 OUT  NOCOPY VARCHAR2
  ) IS

  l_api_name        CONSTANT VARCHAR2(30)    := 'Convert_Status_To_ID';
  l_api_name_full   CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

  BEGIN
    -- Initialize Return Status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    BEGIN
	  SELECT incident_status_id INTO p_status_id
	  FROM cs_incident_statuses_vl
	  WHERE incident_subtype = p_subtype
	  AND   UPPER(name)  = UPPER(p_status_name)
          AND   TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date_active, SYSDATE))
                AND TRUNC(NVL(end_date_active, SYSDATE))
          AND   rownum<2;
    EXCEPTION
	WHEN NO_DATA_FOUND THEN
	   x_return_status := FND_API.G_RET_STS_ERROR;
	   Add_Invalid_Argument_Msg( p_token_an    => l_api_name_full,
				     p_token_v     => p_status_name,
				     p_token_p     => p_parameter_name,
                                     p_table_name  => 'CS_INCIDENT_STATUSES_VL',
                                     p_column_name => 'NAME');
	WHEN OTHERS THEN
	      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
	      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
	      fnd_msg_pub.ADD;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    END;
  END Convert_Status_to_ID;
-- --------------------------------------------------------------------------------
-- Convert_Severity_To_ID
--	convert a service request or action severity to the corresponding internal ID.
-- --------------------------------------------------------------------------------
  PROCEDURE Convert_Severity_To_ID (
	p_api_name			 IN  VARCHAR2,
	p_parameter_name		 IN  VARCHAR2,
	p_severity_name		  	 IN  VARCHAR2,
	p_subtype			 IN  VARCHAR2,
	p_severity_id			OUT  NOCOPY NUMBER,
	x_return_status			OUT  NOCOPY VARCHAR2
  ) IS

  l_api_name       CONSTANT VARCHAR2(30)    := 'Convert_Severity_To_ID';
  l_api_name_full  CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;


  BEGIN
    -- Initialize Return Status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    BEGIN
	  SELECT incident_severity_id INTO p_severity_id
	  FROM cs_incident_severities_vl
	  WHERE incident_subtype = p_subtype
	  AND   UPPER(name)  = UPPER(p_severity_name)
          AND   TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date_active, SYSDATE))
                AND TRUNC(NVL(end_date_active, SYSDATE))
          AND   rownum<2;
    EXCEPTION
	WHEN NO_DATA_FOUND THEN
	   x_return_status := FND_API.G_RET_STS_ERROR;
	   Add_Invalid_Argument_Msg( p_token_an    => l_api_name_full,
				     p_token_v     => p_severity_name,
				     p_token_p     => p_parameter_name,
                                     p_table_name  => 'CS_INCIDENT_SEVERITIES_VL',
                                     p_column_name => 'NAME');
	WHEN OTHERS THEN
	      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
	      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
	      fnd_msg_pub.ADD;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    END;
  END Convert_Severity_To_ID;

/*
** Convert_Urgency_To_ID
** 1. Convert a service request urgency to the corresponding internal ID.
*/
PROCEDURE Convert_Urgency_To_ID
( p_api_name             IN   VARCHAR2,
  p_parameter_name       IN   VARCHAR2,
  p_urgency_name         IN   VARCHAR2,
  p_urgency_id           OUT  NOCOPY NUMBER,
  x_return_status        OUT  NOCOPY VARCHAR2
)
IS
  l_api_name          CONSTANT VARCHAR2(30)    := 'Convert_Urgency_To_ID';
  l_api_name_full     CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;


BEGIN
  -- Initialize the return status.
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Fetch ID from database.
  SELECT incident_urgency_id INTO p_urgency_id
  FROM   cs_incident_urgencies_vl
  WHERE  UPPER(name) = UPPER(p_urgency_name)
  AND    TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date_active, SYSDATE))
                AND TRUNC(NVL(end_date_active, SYSDATE))
  AND    rownum<2;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        Add_Invalid_Argument_Msg( p_token_an    => l_api_name_full,
			          p_token_v     => p_urgency_name,
			          p_token_p     => p_parameter_name,
                                  p_table_name  => 'CS_INCIDENT_URGENCIES_VL',
                                  p_column_name => 'NAME');
  WHEN OTHERS THEN
	fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
	fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
	fnd_msg_pub.ADD;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Convert_Urgency_To_ID;

/*
** Convert_Customer_To_ID
** 1. Convert a customer name or a customer number to the corresponding
**    internal ID.
*/
-- -----------------------------------------------------------------------------
-- Modification History
-- Date     Name     Desc
-- -------- -------- -----------------------------------------------------------
-- 12/16/05 smisra   Bug 4890701
--                   This procedure is never called with some value of param
--                   p_customer_name. so program logic related to this param
--                   is never executed. The code related to p_customer_name
--                   has performance issues. hence removing all the logic
--                   related to parameter p_customer_name
-- -----------------------------------------------------------------------------
PROCEDURE Convert_Customer_To_ID
( p_api_name             IN   VARCHAR2,
  p_parameter_name_nb    IN   VARCHAR2,
  p_parameter_name_n     IN   VARCHAR2,
  p_customer_number      IN   VARCHAR2  := FND_API.G_MISS_CHAR,
  p_customer_name        IN   VARCHAR2  := FND_API.G_MISS_CHAR,
  p_customer_id          OUT  NOCOPY NUMBER,
  x_return_status        OUT  NOCOPY VARCHAR2
)
IS
  l_api_name         CONSTANT VARCHAR2(30) := 'Convert_Customer_To_ID';
  l_api_name_full    CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_api_name;
BEGIN
  -- Initialize the return status.
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Fetch ID from database.

  IF p_customer_number <> FND_API.G_MISS_CHAR THEN
    BEGIN
        SELECT a.party_id INTO p_customer_id
        FROM hz_parties a
        WHERE a.party_number = p_customer_number;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
              Add_Invalid_Argument_Msg( p_token_an   => l_api_name_full,
			                p_token_v    => p_customer_number,
			                p_token_p    => p_parameter_name_nb,
                                        p_table_name => G_TABLE_NAME,
                                        p_column_name => 'CUSTOMER_NUMBER');
      WHEN OTHERS THEN
	      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
	      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
	      fnd_msg_pub.ADD;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    END;
    -- If the customer name parameter is also passed, generate an
    -- informational message.

    IF p_customer_name <> FND_API.G_MISS_CHAR THEN
      Add_Param_Ignored_Msg( p_token_an   => l_api_name_full,
			     p_token_ip   => p_parameter_name_n,
                             p_table_name => G_TABLE_NAME,
                             p_column_name => 'CUSTOMER_NAME' );
    END IF;
  /* Bug 4890701 smisra 12/16/05
  This is procedure is used only in csvsrb.pls
  and it is not used with parameter p_customer_name. so this condition
  will never execute. hence removing this piece.
  ELSE
    BEGIN
      SELECT a.party_id INTO p_customer_id
      FROM hz_parties a
      WHERE UPPER(a.party_name) = UPPER(p_customer_name);

    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        Add_Invalid_Argument_Msg( p_token_an    => l_api_name_full,
			          p_token_v     => p_customer_name,
			          p_token_p     => p_parameter_name_n,
                                  p_table_name  => G_TABLE_NAME,
                                  p_column_name => 'CUSTOMER_NAME' );
      WHEN TOO_MANY_ROWS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
	Add_Duplicate_Value_Msg( p_token_an    => l_api_name_full,
				 p_token_p     => p_parameter_name_n,
                                 p_table_name  => G_TABLE_NAME,
                                 p_column_name => 'CUSTOMER_NAME' );
      WHEN OTHERS THEN
	fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
	fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
	fnd_msg_pub.ADD;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    END;
  **************************************************************************/
  END IF;
END Convert_Customer_To_ID;


-----------------------------------------------------------------------------
-- Convert_Employee_To_ID
--   Convert an employee name or an employee number to the corresponding
--   internal ID.
-----------------------------------------------------------------------------
PROCEDURE Convert_Employee_To_ID
( p_api_name             IN   VARCHAR2,
  p_parameter_name_nb    IN   VARCHAR2,
  p_employee_number      IN   VARCHAR2  := FND_API.G_MISS_CHAR,
  p_employee_id          OUT  NOCOPY NUMBER,
  x_return_status        OUT  NOCOPY VARCHAR2
)
IS
 l_api_name        CONSTANT VARCHAR2(30)    := 'Convert_Employee_To_ID';
 l_api_name_full   CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;
BEGIN
  -- Initialize the return status.
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Fetch ID from database.
  IF (p_employee_number <> FND_API.G_MISS_CHAR) THEN
    BEGIN
      SELECT person_id INTO p_employee_id
      FROM   per_people_x
      WHERE  employee_number = p_employee_number;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        Add_Invalid_Argument_Msg( p_token_an    => l_api_name_full,
			          p_token_v     => p_employee_number,
			          p_token_p     => p_parameter_name_nb,
                                  p_table_name  => null,
                                  p_column_name => 'EMPLOYEE_NUMBER' );
      WHEN TOO_MANY_ROWS THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
		Add_Duplicate_Value_Msg( p_token_an    => l_api_name_full,
				 	 p_token_p     => p_parameter_name_nb,
                                         p_table_name  => null,
                                         p_column_name => 'EMPLOYEE_NUMBER' );
      WHEN OTHERS THEN
	      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
	      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
	      fnd_msg_pub.ADD;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    END;
  END IF;

END Convert_Employee_To_ID;


/*
** Convert_CP_Ref_Number_To_ID
** 1. Convert a customer product reference number to the corresponding
**    customer product ID.
*/
PROCEDURE Convert_CP_Ref_Number_To_ID
( p_api_name             IN   VARCHAR2,
  p_parameter_name       IN   VARCHAR2,
  p_cp_ref_number        IN   NUMBER,
  p_org_id               IN   NUMBER    := NULL,
  p_customer_product_id  OUT  NOCOPY NUMBER,
  x_return_status        OUT  NOCOPY VARCHAR2
)
IS
  l_api_name         CONSTANT VARCHAR2(30)    := 'Convert_CP_Ref_Number_To_ID';
  l_api_name_full    CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;
  l_cp_ref_number    csi_item_instances.instance_number % type;

BEGIN
  -- Initialize the return status.
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_cp_ref_number := to_char(p_cp_ref_number);

  -- Fetch ID from database.
    SELECT instance_id
    INTO p_customer_product_id
    FROM csi_item_instances
    WHERE instance_number = l_cp_ref_number;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
	  x_return_status := FND_API.G_RET_STS_ERROR;
	  Add_Invalid_Argument_Msg( p_token_an    => l_api_name_full,
				    p_token_v     => TO_CHAR(p_cp_ref_number),
				    p_token_p     => p_parameter_name,
                                    p_table_name  => null,
                                    p_column_name => 'CP_REF_NUMBER' );
    WHEN OTHERS THEN
	 fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
	 fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
	 fnd_msg_pub.ADD;
	 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Convert_CP_Ref_Number_To_ID;

/*
** Convert_RMA_Number_To_ID
** 1. Convert an RMA number into the corresponding sales order header ID.
*/
PROCEDURE Convert_RMA_Number_To_ID
( p_api_name             IN   VARCHAR2,
  p_parameter_name       IN   VARCHAR2,
  p_rma_number           IN   NUMBER,
  p_order_type_id        IN   NUMBER    := NULL,
  p_org_id               IN   NUMBER    := NULL,
  p_rma_header_id        OUT  NOCOPY NUMBER,
  x_return_status        OUT  NOCOPY VARCHAR2
)
IS
  l_api_name          CONSTANT VARCHAR2(30)    := 'Convert_RMA_Number_To_ID';
  l_api_name_full     CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;


BEGIN
  -- Initialize the return status.
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Fetch ID from database.
  SELECT header_id INTO p_rma_header_id
  FROM   so_headers_all
  WHERE  order_number = p_rma_number
  AND    order_type_id = NVL(p_order_type_id,order_type_id) ;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

    Add_Invalid_Argument_Msg( p_token_an    => l_api_name_full,
  		              p_token_v     => TO_CHAR(p_rma_number),
			      p_token_p     => p_parameter_name,
                              p_table_name  => G_TABLE_NAME ,
                              p_column_name => 'RMA_NUMBER' );

  WHEN TOO_MANY_ROWS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

    Add_Duplicate_Value_Msg( p_token_an    => l_api_name_full,
			     p_token_p     => p_parameter_name,
                             p_table_name  => G_TABLE_NAME ,
                             p_column_name => 'RMA_NUMBER' );
  WHEN OTHERS THEN
      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
      fnd_msg_pub.ADD;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Convert_RMA_Number_To_ID;

-- --------------------------------------------------------------------------------
-- Validate_Who_info
-- --------------------------------------------------------------------------------
  PROCEDURE Validate_Who_Info (
	p_api_name			 IN  VARCHAR2,
	p_parameter_name_usr		 IN  VARCHAR2,
	p_parameter_name_login		 IN  VARCHAR2,
	p_user_id			 IN  NUMBER,
	p_login_id			 IN  NUMBER,
	x_return_status			OUT  NOCOPY VARCHAR2
  ) IS
  l_dummy 		VARCHAR2(1);
  l_api_name            CONSTANT VARCHAR2(30)    := 'Validate_Who_Info';
  l_api_name_full       CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

  BEGIN
    -- Initialize Return Status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    BEGIN

      -- Special check to not check the dates when the user ID is (-1).
      IF p_user_id = -1 THEN
        SELECT 'x' INTO l_dummy
        FROM   fnd_user
        WHERE  user_id = p_user_id;
      ELSE
          SELECT 'x' INTO l_dummy
	  FROM	fnd_user
	  WHERE	user_id  = p_user_id
	  AND   TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date, SYSDATE))
			AND TRUNC(NVL(end_date, SYSDATE));
      END IF;

    EXCEPTION
	WHEN NO_DATA_FOUND THEN
	   x_return_status := FND_API.G_RET_STS_ERROR;
           Add_Invalid_Argument_Msg( p_token_an    => l_api_name_full,
  		              	     p_token_v     => TO_CHAR(p_user_id),
			       	     p_token_p     => p_parameter_name_usr,
                                     p_table_name  => G_TABLE_NAME,
                                     p_column_name => 'CREATED_BY');
	WHEN OTHERS THEN
	      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
	      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
	      fnd_msg_pub.ADD;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

           RETURN;
    END;

    IF p_login_id IS NOT NULL THEN

      BEGIN
   	  SELECT 'x' INTO l_dummy
	  FROM	fnd_logins
	  WHERE	login_id  = p_login_id
	  AND	user_id	  = p_user_id;
      EXCEPTION
	WHEN NO_DATA_FOUND THEN
	   	x_return_status := FND_API.G_RET_STS_ERROR;
           	Add_Invalid_Argument_Msg( p_token_an => l_api_name_full,
  		p_token_v      => TO_CHAR(p_login_id),
		p_token_p      => p_parameter_name_login,
                p_table_name   => G_TABLE_NAME,
                p_column_name    => 'LAST_UPDATE_LOGIN' );

	WHEN OTHERS THEN
	      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
	      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
	      fnd_msg_pub.ADD;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      END;
    END IF;
  END Validate_Who_Info;


/*
** Validate_Type
** 1. Verify that the service request type is a valid and active type.
** 2. Verify that if the type of the request has any related statuses defined,
**    the status given is one of the active related statuses.
*/

/*******************************
--commented out to test new type validation proc below.
PROCEDURE Validate_Type
( p_api_name             IN   VARCHAR2,
  p_parameter_name       IN   VARCHAR2,
  p_type_id   		 IN   NUMBER,
  p_subtype  		 IN   VARCHAR2,
  p_status_id  		 IN   NUMBER,
  p_resp_id              IN   NUMBER,
  p_operation            IN   VARCHAR2,
  x_return_status        OUT  NOCOPY VARCHAR2,
  -- for cmro_eam
  x_CMRO_flag            OUT  NOCOPY VARCHAR2,
  x_maintenance_flag     OUT  NOCOPY VARCHAR2
)
IS
  l_dummy  		VARCHAR2(1);
  l_status 		NUMBER;
  l_api_name            CONSTANT VARCHAR2(30)    := 'Validate_Type';
  l_api_name_full       CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;
  l_profile             VARCHAR2(9);

  CURSOR val_type_map IS
  SELECT 'x'
  FROM   cs_sr_type_mapping
  WHERE  incident_type_id  = p_type_id
  AND    responsibility_id = p_resp_id
  AND    TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date, SYSDATE))
                        AND     TRUNC(NVL(end_date, SYSDATE));

  CURSOR val_type IS
  SELECT  CMRO_flag,Maintenance_flag
  FROM   cs_incident_types_b
  WHERE  incident_type_id = p_type_id
  AND    incident_subtype = p_subtype
  AND    TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date_active, SYSDATE))
                       AND     TRUNC(NVL(end_date_active, SYSDATE));

BEGIN
  -- Initialize the return status.
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_CMRO_flag := NULL;
  x_maintenance_flag := NULL;

  l_profile       := FND_PROFILE.VALUE('CS_SR_USE_TYPE_RESPON_SETUP');

  -- Verify the type ID against the database.

  IF l_profile='YES' Then
        OPEN val_type_map;
        FETCH val_type_map INTO l_dummy;
        IF (val_type_map%NOTFOUND) THEN
                  CLOSE val_type_map;
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  fnd_message.set_name ('CS', 'CS_SR_TYPE_BY_RESP');
                  fnd_message.set_token ('OPERATION',p_operation);
                  fnd_msg_pub.ADD;
        ELSE
                  x_return_status  := FND_API.G_RET_STS_SUCCESS;
                  --Fixed bug 2809312, moved this close cursor here from
                  --after the if.
                  CLOSE val_type_map;
        END IF;
  ELSE
        OPEN val_type;
	-- for cmro_eam
        FETCH val_type INTO x_CMRO_flag,x_maintenance_flag;
        IF (val_type%NOTFOUND) THEN
                  CLOSE val_type;
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  RAISE NO_DATA_FOUND ;
        ELSE
                  x_return_status  := FND_API.G_RET_STS_SUCCESS;
                  --Fixed bug 2809312, moved this close cursor here from
                  --after the if.
                  CLOSE val_type;
        END IF;
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    Add_Invalid_Argument_Msg( p_token_an    => l_api_name_full,
	              	      p_token_v     => TO_CHAR(p_type_id),
			      p_token_p     => p_parameter_name,
                              p_table_name  => G_TABLE_NAME,
                              p_column_name => 'INCIDENT_TYPE_ID' );

  WHEN OTHERS THEN
	      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
	      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
	      fnd_msg_pub.ADD;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Validate_Type;

*******************************/

-- DJ API Cleanup
-- New proc. to validate type for security
PROCEDURE Validate_Type (
   p_parameter_name       IN   VARCHAR2,
   p_type_id   		  IN   NUMBER,
   p_subtype  		  IN   VARCHAR2,
   p_status_id            IN   NUMBER,   -- not used in proc.
   p_resp_id              IN   NUMBER,
   p_resp_appl_id         IN   NUMBER,   -- new for 11.5.10 default NULL
   p_business_usage       IN   VARCHAR2, -- new for 11.5.10 default NULL
   p_ss_srtype_restrict   IN   VARCHAR2, -- new for 11.5.10 default 'N'
   p_operation            IN   VARCHAR2, -- new for 11.5.10 used for self_service resp.
   x_return_status        OUT  NOCOPY VARCHAR2,
   x_cmro_flag            OUT  NOCOPY VARCHAR2,  -- new for 11.5.10
   x_maintenance_flag     OUT  NOCOPY VARCHAR2 ) -- new for 11.5.10
IS
   l_dummy  		 VARCHAR2(1);
   l_status 		 NUMBER;
   l_api_name            CONSTANT VARCHAR2(30) := 'Validate_Type';
   l_api_name_full       CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_api_name;

   -- this is used to indicate if the out flag params. are populated or not.
   l_flags_set           VARCHAR2(1) := 'N';
   l_start_date          DATE;
   l_end_date            DATE;

   cursor val_type_map is
   select 'x'
   from   cs_sr_type_mapping
   where  incident_type_id  = p_type_id
   and    responsibility_id = p_resp_id
   and    application_id    = p_resp_appl_id  -- new for 11.5.10
   and    trunc(sysdate) between trunc(nvl(start_date, sysdate))
                         and     trunc(nvl(end_date, sysdate));

   -- For bug 3474365
   cursor val_type_unsecure is
   select UPPER(cmro_flag), UPPER(maintenance_flag),start_date_active,end_date_active
   from   cs_incident_types_b
   where  incident_type_id = p_type_id
   and    incident_subtype = p_subtype;
--   and    trunc(sysdate) between trunc(nvl(start_date_active, sysdate))
--			 and     trunc(nvl(end_date_active,   sysdate));

   cursor val_type_secure is
   select cmro_flag, maintenance_flag ,start_date_active,end_date_active
   from   cs_incident_types_vl_sec
   where  incident_type_id  = p_type_id
   and    incident_subtype  = p_subtype;
 --  and    trunc(sysdate) between trunc(nvl(start_date_active, sysdate))
 --                        and     trunc(nvl(end_date_active, sysdate));

BEGIN
  -- Initialize the return status.
  x_return_status     := FND_API.G_RET_STS_SUCCESS;
  x_cmro_flag         := NULL;
  x_maintenance_flag  := NULL;

  -- Verify the type ID against the database.
  if ( p_business_usage = 'SELF_SERVICE' ) then
     if ( p_ss_srtype_restrict = 'Y' AND p_operation = 'CREATE') then
	open  val_type_map;
	fetch val_type_map into l_dummy;
	close val_type_map;

	if ( l_dummy = 'x' ) then
	   x_return_status := FND_API.G_RET_STS_SUCCESS;
        else
	   -- new message for 11.5.10
	   -- You do not have access to the service request type that is
	   -- being created. Please contact your system administrator.
           fnd_message.set_name ('CS', 'CS_SR_WEB_NO_PRIV');
           fnd_msg_pub.ADD;
	   x_return_status := FND_API.G_RET_STS_ERROR;
	end if;
     else
       -- For bug 3474365 - included an if condition while called for validating old sr type
       -- for self_Service applications.


       if ( p_operation = 'UPDATE') then
	open  val_type_unsecure;
	fetch val_type_unsecure into x_cmro_flag, x_maintenance_flag,l_start_date,l_end_date;

	if ( val_type_unsecure%notfound ) then
	   -- new message for 11.5.10
	   -- Invalid type. Given type is either end dated or does not exist
	   -- as a valid type.
           fnd_message.set_name ('CS', 'CS_SR_INVALID_TYPE');
	   fnd_message.set_token('API_NAME', l_api_name_full);
           fnd_msg_pub.ADD;
	   x_return_status := FND_API.G_RET_STS_ERROR;

        elsif (not( trunc(sysdate) >= trunc(nvl(l_start_date, sysdate))
                      and     trunc(sysdate) <= trunc(nvl(l_end_date, sysdate)) )) then
           fnd_message.set_name ('CS', 'CS_SR_INVALID_TYPE');
           fnd_message.set_token('API_NAME', l_api_name_full);
           fnd_msg_pub.ADD;
	   x_return_status := FND_API.G_RET_STS_ERROR;
        else
	   l_flags_set     := 'Y';
	   x_return_status := FND_API.G_RET_STS_SUCCESS;
	end if;
	close val_type_unsecure;

      elsif ( p_operation = 'UPDATE_OLD') then
          open  val_type_unsecure;
	  fetch val_type_unsecure into x_cmro_flag, x_maintenance_flag,l_start_date,l_end_date;

	  if ( val_type_unsecure%notfound ) then
	   -- new message for 11.5.10
	   -- Invalid type. Given type is either end dated or does not exist
	   -- as a valid type.
           fnd_message.set_name ('CS', 'CS_SR_INVALID_TYPE');
	   fnd_message.set_token('API_NAME', l_api_name_full);
           fnd_msg_pub.ADD;
	   x_return_status := FND_API.G_RET_STS_ERROR;
         else
	   l_flags_set     := 'Y';
	   x_return_status := FND_API.G_RET_STS_SUCCESS;
	 end if;
	 close val_type_unsecure;

      end if; -- if ( p_operation = 'UPDATE') then
     end if;    -- if ( p_ss_srtype_restrict = 'Y' ) then
  else   -- p_business_usage = AGENT

  -- For bug 3474365 - included an if condition while called for validating old sr type
  -- when the security is off

  -- For bug 3732793 included the or condition for create
     if ( p_operation = 'UPDATE' OR p_operation = 'CREATE') then
     open val_type_secure;
     fetch val_type_secure into x_cmro_flag, x_maintenance_flag,l_start_date,l_end_date;

     if ( val_type_secure%notfound ) then
        -- new message for 11.5.10
        -- Current responsibility does not have sufficient priviledges to access
        -- service requests of this type. Please contact your system administrator.
        fnd_message.set_name ('CS', 'CS_SR_AGENT_NO_PRIV');
	fnd_message.set_token('API_NAME', l_api_name_full);
        fnd_msg_pub.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
     elsif (not( trunc(sysdate) >= trunc(nvl(l_start_date, sysdate))
                      and     trunc(sysdate) <= trunc(nvl(l_end_date, sysdate)) )) then
           fnd_message.set_name ('CS', 'CS_SR_INVALID_TYPE');
           fnd_message.set_token('API_NAME', l_api_name_full);
           fnd_msg_pub.ADD;
	   x_return_status := FND_API.G_RET_STS_ERROR;
     else
	l_flags_set     := 'Y';
	x_return_status := FND_API.G_RET_STS_SUCCESS;
     end if;
     close val_type_secure;
   elsif ( p_operation = 'UPDATE_OLD') then
          open  val_type_secure;
	  fetch val_type_secure into x_cmro_flag, x_maintenance_flag,l_start_date,l_end_date;

	  if ( val_type_secure%notfound ) then
	   -- new message for 11.5.10
	   -- Invalid type. Given type is either end dated or does not exist
	   -- as a valid type.
           -- For bug 3902711
           --fnd_message.set_name ('CS', 'CS_SR_INVALID_TYPE');
           fnd_message.set_name ('CS', 'CS_SR_AGENT_NO_PRIV');
	   fnd_message.set_token('API_NAME', l_api_name_full);
           fnd_msg_pub.ADD;
	   x_return_status := FND_API.G_RET_STS_ERROR;
         else
	   l_flags_set     := 'Y';
	   x_return_status := FND_API.G_RET_STS_SUCCESS;
	 end if;
	 close val_type_secure;

   end if; -- if ( p_operation = 'UPDATE') then
  end if;   -- if ( p_business_usage = 'SELF_SERVICE' ) then

  -- get the values of the flags for the out parameters if not set
  if ( x_return_status = FND_API.G_RET_STS_SUCCESS and
       l_flags_set     = 'N' ) then
     open  val_type_unsecure;
     fetch val_type_unsecure into x_cmro_flag, x_maintenance_flag,l_start_date,l_end_date;
     close val_type_unsecure;
  end if;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    Add_Invalid_Argument_Msg( p_token_an    => l_api_name_full,
	              	      p_token_v     => TO_CHAR(p_type_id),
			      p_token_p     => p_parameter_name,
                              p_table_name  => G_TABLE_NAME,
                              p_column_name => 'INCIDENT_TYPE_ID' );

  WHEN OTHERS THEN
	      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
	      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
	      fnd_msg_pub.ADD;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Validate_Type;
/*
** Validate_Status
** Note : This procedure is used during Create Service Request.
** 1. Find whether Status Group is Mapped to Type, If yes use Status Group (SG1)
** 2. Find whether Status Group is mapped to Type-Resp. If yes, use status Group (SG2)
** 3. If No status Group is mapped
**    Check whether status is a valid status with Valid_in_Create set as 'Y'
** 4. If a Status Group is mapped (SG1) or (SG2)
**    Is the Status a valid Status with Valid_In_Create set as 'Y'
**    Does Given Status exist in CS_ALLOWED_STATUSES for the Given Group?
** 5. Return to the caller via the p_close_flag parameter whether or not the
**    status is a "closed" status. This will be useful to the caller for
**    managing the closed date.
*/
PROCEDURE Validate_Status
( p_api_name             IN   VARCHAR2,
  p_parameter_name       IN   VARCHAR2,
  p_status_id 		 IN   NUMBER,
  p_subtype      	 IN   VARCHAR2,
  p_type_id      	 IN   NUMBER,
  p_resp_id		 IN   NUMBER,
  p_close_flag           OUT  NOCOPY VARCHAR2,
  p_operation         IN             VARCHAR2,
  x_return_status        OUT  NOCOPY VARCHAR2
)
IS

   l_status_group_id	  NUMBER := 0;

    -- Cursor to Validate Status

    CURSOR all_statuses_csr IS
    SELECT seeded_flag, close_flag
    FROM   cs_incident_statuses_b
    WHERE  incident_subtype = p_subtype
    AND    incident_status_id = p_status_id
    AND    valid_in_create_flag = 'Y'
    AND    TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date_active, SYSDATE))
    AND     TRUNC(NVL(end_date_active, SYSDATE));

    CURSOR all_statuses_csr1 IS
    SELECT seeded_flag, close_flag
      FROM cs_incident_statuses_b
     WHERE incident_subtype = p_subtype
       AND incident_status_id = p_status_id
       AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date_active, SYSDATE))
       AND TRUNC(NVL(end_date_active, SYSDATE));

    CURSOR group_for_type_Csr IS
    SELECT status_Group_id
    FROM   cs_incident_types_B
    WHERE  Incident_type_id = p_type_id;
    /* Type is already validated **/

    CURSOR group_for_type_resp_csr IS
    SELECT status_Group_id
    FROM   cs_sr_type_mapping
    WHERE  Incident_type_id = p_type_id
    AND    responsibility_id = p_resp_id
    AND    status_group_id IS NOT NULL;

    -- Check Status is allowed for the Group
    CURSOR allowed_Statuses_csr IS
    SELECT incident_status_id
    FROM   cs_sr_allowed_statuses
    WHERE  status_Group_id = l_status_group_id
    AND    incident_Status_id = p_status_id
    AND    TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date, SYSDATE))
                          AND     TRUNC(NVL(end_date, SYSDATE));

   l_seeded_flag          VARCHAR2(3);
   l_status               NUMBER;
   l_incident_Status_id   NUMBER;
   l_count         	  NUMBER;

   l_api_name      CONSTANT VARCHAR2(30)    := 'Validate_Status';
   l_api_name_full CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;
BEGIN
   -- Initialize the return status.
   x_return_status  := FND_API.G_RET_STS_SUCCESS;

   IF NVL(p_operation,'CREATE') = 'CREATE' THEN

      OPEN all_statuses_Csr;
      FETCH all_statuses_csr INTO l_seeded_flag, p_close_flag;
      IF (all_statuses_Csr%NOTFOUND) THEN
   	    CLOSE all_statuses_csr;
	    RAISE NO_DATA_FOUND ;
      END IF;
      CLOSE all_statuses_csr;
   ELSE
      OPEN all_statuses_Csr1;
	FETCH all_statuses_csr1 INTO l_seeded_flag, p_close_flag;
	IF (all_statuses_Csr1%NOTFOUND) THEN
	   CLOSE all_statuses_csr1;
	   RAISE NO_DATA_FOUND ;
	END IF;

	CLOSE all_statuses_csr1;
   END IF;


   -- Check Whether Any Group is mapped for Type and Resp.
   OPEN group_for_type_resp_csr;
   FETCH group_for_type_resp_csr INTO l_status_group_id;
   IF (group_for_type_resp_csr%NOTFOUND) THEN
 	    -- No Group is mapped for Type and Resp, try Type
       OPEN group_for_type_csr;
       FETCH group_for_type_csr INTO l_status_group_id;
       IF (group_for_type_csr%NOTFOUND) THEN
	      -- No Group is mapped for Type, All Valid statuses are Valid.
	      NULL;
       END IF;
	   CLOSE group_for_type_csr;
   END IF;
   CLOSE group_for_type_resp_csr;

   IF (l_status_group_id > 0) THEN
   	  -- Status group has been  Found
      -- Check for allowed statuses
      OPEN  allowed_Statuses_csr;
      FETCH allowed_Statuses_csr INTO l_incident_Status_id;
      IF (allowed_Statuses_csr%NOTFOUND) THEN
	   -- This Status is not Allowed for this Group
	   CLOSE allowed_Statuses_csr;
	   RAISE NO_DATA_FOUND ;
      END IF;
      CLOSE allowed_Statuses_csr;
   END IF;


EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

    Add_Invalid_Argument_Msg( p_token_an    => l_api_name_full,
	              	      p_token_v     => TO_CHAR(p_status_id),
			      p_token_p     => p_parameter_name,
                              p_table_name  => G_TABLE_NAME,
                              p_column_name => 'INCIDENT_STATUS_ID' );
  WHEN OTHERS THEN
	      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
	      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
	      fnd_msg_pub.ADD;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Validate_Status;

/*
** Validate_Updated_Status
** Note : This procedure is used during Update Service Request.
** 1. Find whether Status Group is Mapped to Type, If yes use Status Group (SG1)
** 2. Find whether Status Group is mapped to Type-Resp. If yes, use status Group (SG2)
** 3. If No status Group is mapped
**    Check whether status is a valid status.
** 4. If a Status Group is mapped (SG1) or (SG2)
**    Is Status Transition defined for this group
**    If yes, Is the current Transition Allowed
**    If Status Transition are not defined.
****    Does Given Status exist in CS_ALLOWED_STATUSES for the Given Group?
** 5. Return to the caller via the p_close_flag parameter whether or not the
**    status is a "closed" status. This will be useful to the caller for
**    managing the closed date.
*/

PROCEDURE Validate_Updated_Status
( p_api_name                   IN        VARCHAR2,
  p_parameter_name             IN        VARCHAR2,
  p_resp_id                    IN        NUMBER,
  p_new_status_id              IN        NUMBER,
  p_old_status_id              IN        NUMBER,
  p_subtype      	           IN        VARCHAR2,
  p_type_id      	           IN        NUMBER,
  p_old_type_id                IN        NUMBER := NULL,
  p_close_flag                OUT NOCOPY VARCHAR2,
  p_disallow_request_update   OUT NOCOPY VARCHAR2,
  p_disallow_owner_update     OUT NOCOPY VARCHAR2,
  p_disallow_product_update   OUT NOCOPY VARCHAR2,
  x_return_status             OUT NOCOPY VARCHAR2
)
IS

   l_status_group_id 		NUMBER := 0;
   l_status_Transition_id 	NUMBER;
   l_incident_status_id		NUMBER;
   l_old_status_group_id      NUMBER := 0;


    -- Cursor to Validate Status
    CURSOR all_statuses_csr IS
    SELECT seeded_flag, close_flag
    FROM   cs_incident_statuses_b
    WHERE  incident_subtype = p_subtype
    AND    incident_status_id = p_new_status_id
    AND    TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date_active, SYSDATE))
                        AND     TRUNC(NVL(end_date_active, SYSDATE));

    CURSOR group_for_type_Csr (l_type_id IN NUMBER) IS
    SELECT status_Group_id
    FROM   cs_incident_types_B
    WHERE  Incident_type_id = l_type_id
    AND    TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date_active, SYSDATE))
                        AND     TRUNC(NVL(end_date_active, SYSDATE));
    /* Type is already validated **/

    CURSOR group_for_type_resp_csr (l_type_id IN NUMBER, l_resp_id IN NUMBER) IS
    SELECT status_Group_id
    FROM   cs_sr_type_mapping
    WHERE  Incident_type_id = l_type_id
    AND    responsibility_id = l_resp_id
    AND    TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date, SYSDATE))
                        AND     TRUNC(NVL(end_date, SYSDATE)) ;

    -- Check Status is allowed for the Group
    CURSOR allowed_Statuses_csr ( p_status_group_id IN NUMBER) IS
    SELECT incident_status_id
    FROM   cs_sr_allowed_statuses
    WHERE  status_Group_id = p_status_group_id
    AND    incident_Status_id = p_new_status_id
    AND    TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date, SYSDATE))
                          AND     TRUNC(NVL(end_date, SYSDATE));

    -- Check Whether transitions are defined for the Group.
    CURSOR status_Transitions_csr IS
    SELECT status_Transition_id
    FROM   cs_sr_status_transitions
    WHERE  status_Group_id = l_status_group_id
    AND    TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date, SYSDATE))
                          AND     TRUNC(NVL(end_date, SYSDATE));
    /** This above should later be moved to use transition IND**/

    -- Check Whether Current update is a Valid transitions for the Group.
    CURSOR valid_status_Transitions_csr IS
    SELECT status_Transition_id
    FROM   cs_sr_status_transitions
    WHERE  status_Group_id = l_status_group_id
    AND    FROM_Incident_status_id =   p_old_status_id
    AND    TO_Incident_status_id   = p_new_status_id
    AND    TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date, SYSDATE))
                          AND     TRUNC(NVL(end_date, SYSDATE));

  l_api_name       CONSTANT VARCHAR2(30)    := 'Validate_Updated_Status';
  l_api_name_full  CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;
  l_status_valid            VARCHAR2(1);
  l_count	   NUMBER;

BEGIN

  -- Initialize the return status.
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_status_valid            := 'N' ;

   -- Verify the given status against the cs_incident_statuses table.
   -- Get all the values for the flags.
   -- Changed the new_status_id to old_status_id for fixing Bug# 2094344.
  -- For bug 3306908 - commented the date validation

   SELECT close_flag, disallow_request_update,
	      disallow_agent_dispatch, disallow_product_update
   INTO   p_close_flag, p_disallow_request_update,
	      p_disallow_owner_update, p_disallow_product_update
   FROM   cs_incident_statuses_b
   WHERE  incident_status_id = p_old_status_id
   AND    incident_subtype = p_subtype;
  -- AND    TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date_active, SYSDATE))
--		 	 AND     TRUNC(NVL(end_date_active, SYSDATE));

   --Added the query because the close_date did not populate with SYSDATE
   SELECT close_flag INTO p_close_flag
   FROM   cs_incident_statuses_b
   WHERE  incident_status_id = p_new_status_id
   AND    incident_subtype = p_subtype
   AND    TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date_active, SYSDATE))
                          AND     TRUNC(NVL(end_date_active, SYSDATE));
   /*** Move the Above as Cursors ****/

   -- Check Whether Any Group is mapped for Type and Resp.
   OPEN group_for_type_resp_csr(p_type_id,p_resp_id);
   FETCH group_for_type_resp_csr INTO l_status_group_id;
   IF (group_for_type_resp_csr%NOTFOUND) THEN
 	    -- No Group is mapped for Type and Resp, try Type
       OPEN group_for_type_csr(p_type_id);
       FETCH group_for_type_csr INTO l_status_group_id;
       IF (group_for_type_csr%NOTFOUND) THEN
	        -- No Group is mapped for Type, All Valid statuses are Valid.
	        NULL;
       END IF;
  	   CLOSE group_for_type_csr;
   END IF;
  CLOSE group_for_type_resp_csr;

   -- If the type has changed then get the status group mapped to the
   -- old SR Type

   IF (NVL(p_type_id ,00) <> NVL(p_old_type_id,00) AND
      (p_old_type_id IS NOT NULL)
	 )THEN

      -- Check Whether Any Group is mapped for Type and Resp.

       OPEN group_for_type_resp_csr(p_old_type_id,p_resp_id);
	 FETCH group_for_type_resp_csr INTO l_old_status_group_id;

	 IF (group_for_type_resp_csr%NOTFOUND) THEN
	    -- No Group is mapped for Type and Resp, try Type

	     OPEN group_for_type_csr(p_old_type_id);
	    FETCH group_for_type_csr INTO l_old_status_group_id;

	    IF (group_for_type_csr%NOTFOUND) THEN
  	       -- No Group is mapped for Type, All Valid statuses are Valid.
	       NULL;
	    END IF;
	    CLOSE group_for_type_csr;
	 END IF;
	 CLOSE group_for_type_resp_csr;
   END IF;

   IF (NVL(p_type_id ,00) <> NVL(p_old_type_id,00) AND
       p_old_type_id IS NOT NULL AND
	  l_status_group_id <> l_old_status_group_id
	 ) THEN
	 -- Since the type and status group is changed we need to validate only that the
	 -- status exists in the status group and not the transition.

	  OPEN allowed_Statuses_csr(l_status_group_id);
      FETCH allowed_Statuses_csr INTO l_incident_Status_id;

      IF (allowed_Statuses_csr%NOTFOUND) THEN
	    -- This Status is not Allowed for this Group
	    CLOSE allowed_Statuses_csr;
	    RAISE NO_DATA_FOUND ;
	 END IF;
	 CLOSE allowed_Statuses_csr;

   ELSE
      IF (l_status_group_id > 0) THEN
   	     -- Status group has been  Found , Check whether transition are defined.
         OPEN status_transitions_csr;
         FETCH status_transitions_csr INTO l_status_transition_id;

         IF (status_transitions_csr%NOTFOUND) THEN
	      -- Status transitions are not defined, ck only allowed Status
	      OPEN  allowed_Statuses_csr(l_status_group_id);
              FETCH allowed_Statuses_csr INTO l_incident_Status_id;

        	   IF (allowed_Statuses_csr%NOTFOUND) THEN
	   	       -- This Status is not Allowed for this Group
	   		   CLOSE allowed_Statuses_csr;
		   	   RAISE NO_DATA_FOUND ;
            END IF;
            CLOSE allowed_Statuses_csr;
         ELSE
 	        -- Status Transitions are defined, check whether current trans. is valid
	        OPEN valid_status_transitions_csr;
	        FETCH valid_status_transitions_csr INTO l_status_transition_id;
	        IF (valid_status_transitions_csr%NOTFOUND) THEN
		      CLOSE valid_status_transitions_csr;
		      RAISE NO_DATA_FOUND;
	        END IF;
	        CLOSE valid_status_transitions_csr;
  	     END IF;
      END IF;
   END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    Add_Invalid_Argument_Msg( p_token_an    => l_api_name_full,
	              	      p_token_v     => TO_CHAR(p_new_status_id),
		              p_token_p     => p_parameter_name,
                              p_table_name  => G_TABLE_NAME,
                              p_column_name => 'INCIDENT_STATUS_ID' );
  WHEN OTHERS THEN
	      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
	      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
	      fnd_msg_pub.ADD;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Validate_Updated_Status;


-- Validate_Severity
--	verify that the service request severity is a valid and active.
-- --------------------------------------------------------------------------------
  PROCEDURE Validate_Severity (
	p_api_name			 IN  VARCHAR2,
	p_parameter_name		 IN  VARCHAR2,
	p_severity_id			 IN  NUMBER,
	p_subtype			 IN  VARCHAR2,
	x_return_status			OUT  NOCOPY VARCHAR2
  ) IS

  l_dummy 	     VARCHAR2(1);
  l_api_name         CONSTANT VARCHAR2(30)    := 'Validate_Severity';
  l_api_name_full    CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

  BEGIN
    -- Initialize Return Status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    BEGIN
	  SELECT 'x' INTO l_dummy
	  FROM  cs_incident_severities_b
	  WHERE incident_subtype = p_subtype
	  AND   incident_severity_id = p_severity_id
	  AND   TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date_active, SYSDATE))
			AND TRUNC(NVL(end_date_active, SYSDATE));
    EXCEPTION
	WHEN NO_DATA_FOUND THEN
	   x_return_status := FND_API.G_RET_STS_ERROR;
           Add_Invalid_Argument_Msg( p_token_an    => l_api_name_full,
  		              	     p_token_v     => TO_CHAR(p_severity_id),
		      	     	     p_token_p     => p_parameter_name,
                                     p_table_name  => G_TABLE_NAME,
                                     p_column_name => 'SEVERITY_ID' );
	WHEN OTHERS THEN
	      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
	      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
	      fnd_msg_pub.ADD;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    END;
  END Validate_Severity ;


-- --------------------------------------------------------------------------------
--  Validate_Urgency
--	verify that the service request urgency is a valid and active.
-- --------------------------------------------------------------------------------
  PROCEDURE Validate_Urgency (
	p_api_name			 IN  VARCHAR2,
	p_parameter_name		 IN  VARCHAR2,
	p_urgency_id			 IN  NUMBER,
	x_return_status			 OUT NOCOPY VARCHAR2
  ) IS

    l_dummy 	           VARCHAR2(1);
    l_api_name             CONSTANT VARCHAR2(30)    := 'Validate_Urgency';
    l_api_name_full        CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

  BEGIN
    -- Initialize Return Status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    BEGIN
	  SELECT 'x' INTO l_dummy
	  FROM  cs_incident_urgencies_b
	  WHERE incident_urgency_id = p_urgency_id
	  AND   TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date_active, SYSDATE))
			AND TRUNC(NVL(end_date_active, SYSDATE));
    EXCEPTION
	WHEN NO_DATA_FOUND THEN
	   x_return_status := FND_API.G_RET_STS_ERROR;
           Add_Invalid_Argument_Msg( p_token_an    => l_api_name_full,
  		              	     p_token_v     => TO_CHAR(p_urgency_id),
			      	     p_token_p     => p_parameter_name,
                                     p_table_name  => G_TABLE_NAME,
                                     p_column_name => 'URGENCY_ID' );
	WHEN OTHERS THEN
	      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
	      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
	      fnd_msg_pub.ADD;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    END;
  END Validate_Urgency;


/*
** Validate_Closed_Date
** 1. The closed date is validated against the service request date.
**    Therefore, this procedure takes in the service request date as a
**    parameter.
** 2. Verify that the closed date is later than the service request date.
*/
  PROCEDURE Validate_Closed_Date
  ( p_api_name             IN   VARCHAR2,
    p_parameter_name       IN   VARCHAR2,
    p_closed_date          IN   DATE,
    p_request_date         IN   DATE,
    x_return_status        OUT  NOCOPY VARCHAR2
  )
  IS
 l_api_name        CONSTANT VARCHAR2(30)    := 'Validate_Closed_Date';
 l_api_name_full   CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;


  BEGIN
    IF p_closed_date >= p_request_date THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
    ELSE
      x_return_status := FND_API.G_RET_STS_ERROR;
      Add_Invalid_Argument_Msg( p_token_an    => l_api_name_full,
  	              	        p_token_v     => TO_CHAR(p_closed_date),
  		     		p_token_p     => p_parameter_name,
                                p_table_name  => G_TABLE_NAME ,
                                p_column_name => 'CLOSED_DATE' );
    END IF;

  EXCEPTION
	WHEN OTHERS THEN
	      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
	      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
	      fnd_msg_pub.ADD;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Closed_Date;

---- Added for Enh# 1830701
  PROCEDURE Validate_Inc_Reported_Date
  ( p_api_name             IN   VARCHAR2,
    p_parameter_name       IN   VARCHAR2,
    p_request_date         IN   DATE,
    p_inc_occurred_date    IN   DATE,
    x_return_status        OUT  NOCOPY VARCHAR2
  )
  IS
 l_api_name       CONSTANT VARCHAR2(30)    := 'Validate_Inc_Reported_Date';
 l_api_name_full  CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

  BEGIN
  /* p_request_date is the incident date and the incident date
     should be greater than and equal to the incident occured_date*/

    IF p_request_date >= p_inc_occurred_date THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
    ELSE
      x_return_status := FND_API.G_RET_STS_ERROR;
       fnd_message.set_name ('CS','CS_INC_DATES_MISMATCH');
       fnd_message.set_token ('INCIDENT_DATE',TO_CHAR(p_request_date));
       fnd_message.set_token ('INCIDENT_OCC_DATE',TO_CHAR(p_inc_occurred_date));
       FND_MSG_PUB.ADD;
    END IF;
  EXCEPTION
	WHEN OTHERS THEN
	      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
	      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
	      fnd_msg_pub.ADD;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Inc_Reported_Date;

  PROCEDURE Validate_Inc_Occurred_Date
  ( p_api_name             IN   VARCHAR2,
    p_parameter_name       IN   VARCHAR2,
    p_inc_occurred_date    IN   DATE,
    p_request_date         IN   DATE,
    x_return_status        OUT  NOCOPY VARCHAR2
  )
  IS
  l_api_name         CONSTANT VARCHAR2(30)    := 'Validate_Inc_Occurred_Date';
  l_api_name_full    CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

  BEGIN
    IF p_inc_occurred_date <= p_request_date THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
    ELSE
      x_return_status := FND_API.G_RET_STS_ERROR;
       fnd_message.set_name ('CS','CS_INC_DATES_MISMATCH');
       fnd_message.set_token ('INCIDENT_DATE',TO_CHAR(p_request_date));
       fnd_message.set_token ('INCIDENT_OCC_DATE',TO_CHAR(p_inc_occurred_date));
       FND_MSG_PUB.ADD;
    END IF;
  EXCEPTION
	WHEN OTHERS THEN
	      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
	      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
	      fnd_msg_pub.ADD;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Inc_Occurred_Date;

  PROCEDURE Validate_Inc_Resolved_Date
  ( p_api_name             IN   VARCHAR2,
    p_parameter_name       IN   VARCHAR2,
    p_inc_resolved_date    IN   DATE,
    p_request_date         IN   DATE,
    x_return_status        OUT  NOCOPY VARCHAR2
  )
  IS
 l_api_name        CONSTANT VARCHAR2(30)    := 'Validate_Inc_Resolved_Date';
 l_api_name_full   CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

  BEGIN
    IF p_inc_resolved_date >= p_request_date THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
    ELSE
      x_return_status := FND_API.G_RET_STS_ERROR;
      Add_Invalid_Argument_Msg( p_token_an    => l_api_name_full,
  	              	        p_token_v     => TO_CHAR(p_inc_resolved_date),
  			      	p_token_p     => p_parameter_name,
                                p_table_name  => G_TABLE_NAME,
                                p_column_name => 'INCIDENT_RESOLVED_DATE' );
    END IF;
  EXCEPTION
	WHEN OTHERS THEN
	      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
	      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
	      fnd_msg_pub.ADD;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Inc_Resolved_Date;

  PROCEDURE Validate_Inc_Responded_Date
  ( p_api_name               IN   VARCHAR2,
    p_parameter_name         IN   VARCHAR2,
    p_inc_responded_by_date  IN   DATE,
    p_request_date           IN   DATE,
    x_return_status          OUT  NOCOPY VARCHAR2
  )
  IS
  l_api_name          CONSTANT VARCHAR2(30)    := 'Validate_Inc_Responded_Date';
  l_api_name_full     CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

  BEGIN
    IF p_inc_responded_by_date >= p_request_date THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
    ELSE
      x_return_status := FND_API.G_RET_STS_ERROR;
      Add_Invalid_Argument_Msg( p_token_an    => l_api_name_full,
  	              	        p_token_v     => TO_CHAR(p_inc_responded_by_date),
  			      	p_token_p     => p_parameter_name,
                                p_table_name  => G_TABLE_NAME,
                                p_column_name => 'INC_RESPONDED_BY_DATE' );
    END IF;
  EXCEPTION
	WHEN OTHERS THEN
	      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
	      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
	      fnd_msg_pub.ADD;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Inc_Responded_Date;

---- Added for Enh# 1830701
-- -----------------------------------------------------------------------------
-- Modification History
-- Date     Name     Desc
-- -------- -------- -----------------------------------------------------------
-- 12/14/05 smisra   Bug 4386879
--                   Added a new out param x_incident_country and set it based
--                   on country associated with location
-- -----------------------------------------------------------------------------
  PROCEDURE Validate_Inc_Location_Id
  ( p_api_name             	IN   VARCHAR2,
    p_parameter_name       	IN   VARCHAR2,
    -- New parameter added for validation based on location type --anmukher -- 08/18/03
    p_incident_location_type	IN   VARCHAR2,
    p_incident_location_id 	IN   NUMBER,
    x_incident_country          OUT  NOCOPY VARCHAR2,
    x_return_status        	OUT  NOCOPY VARCHAR2
  )
  IS
    l_api_name                   CONSTANT VARCHAR2(30)    := 'Validate_Inc_Location_Id';
    l_api_name_full              CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

    -- Added for validation based on location type --anmukher -- 08/18/03
    e_invalid_location_type	 EXCEPTION;

  BEGIN

    -- Initialize Return Status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    BEGIN
    -- IF block added for validation based on location type --anmukher -- 08/18/03
      If p_incident_location_type = 'HZ_LOCATION' Then

	  SELECT country INTO x_incident_country
	  FROM  hz_locations
	  WHERE location_id = p_incident_location_id;
      Elsif p_incident_location_type = 'HZ_PARTY_SITE' Then

          SELECT b.country INTO x_incident_country
	  FROM   hz_party_sites a,
                 hz_locations b
          WHERE  party_site_id = p_incident_location_id
            AND  a.location_id = b.location_id;

       Else

           RAISE e_invalid_location_type;

       End If;


    EXCEPTION
	WHEN NO_DATA_FOUND THEN
	   x_return_status := FND_API.G_RET_STS_ERROR;
           Add_Invalid_Argument_Msg( p_token_an    => l_api_name_full,
  		              	     p_token_v     => TO_CHAR(p_incident_location_id),
			      	     p_token_p     => p_parameter_name,
                                     p_table_name  => G_TABLE_NAME ,
                                     p_column_name => 'INCIDENT_LOCATION_ID' );
        -- Added for validation based on location type --anmukher -- 08/18/03
        WHEN e_invalid_location_type THEN
	   x_return_status := FND_API.G_RET_STS_ERROR;
           Add_Invalid_Argument_Msg( p_token_an    => l_api_name_full,
  		              	     p_token_v     => p_incident_location_type,
			      	     p_token_p     => 'p_incident_location_type',
                                     p_table_name  => G_TABLE_NAME ,
                                     p_column_name => 'INCIDENT_LOCATION_TYPE' );
	WHEN OTHERS THEN
	      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
	      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
	      fnd_msg_pub.ADD;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    END;
  END Validate_Inc_Location_Id;

  PROCEDURE Validate_Incident_Country
  ( p_api_name             IN   VARCHAR2,
    p_parameter_name       IN   VARCHAR2,
    p_incident_country     IN   VARCHAR2,
    x_return_status        OUT  NOCOPY VARCHAR2
  )
  IS
  l_dummy              VARCHAR2(1);
  l_api_name           CONSTANT VARCHAR2(30)    := 'Validate_Incident_Country';
  l_api_name_full      CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

  BEGIN

    -- Initialize Return Status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    BEGIN
	  SELECT 'x' INTO l_dummy
	  FROM  fnd_territories
	  WHERE territory_code = p_incident_country;

    EXCEPTION
	WHEN NO_DATA_FOUND THEN
	   x_return_status := FND_API.G_RET_STS_ERROR;
           Add_Invalid_Argument_Msg( p_token_an    => l_api_name_full,
  		              	     p_token_v     => p_incident_country,
			      	     p_token_p     => p_parameter_name,
                                     p_table_name  => G_TABLE_NAME,
                                     p_column_name => 'INCIDENT_COUNTRY' );
	WHEN OTHERS THEN
	      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
	      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
	      fnd_msg_pub.ADD;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    END;
  END Validate_Incident_Country;

-------------------------------------------------------------------------------
-- Validate_Employee
-- Verify that the employee is valid and active.
-- Made the LOV query and cursor query in sync.by shijain dated 11th oct 2002

-------------------------------------------------------------------------------
-- -----------------------------------------------------------------------------
-- Modification History
-- Date     Name     Desc
-- -------- -------- -----------------------------------------------------------
-- 12/12/05 smisra   Contingent worker support project
--                   replaced the view per_employees_x with per_workforce_x so
--                   that emaployee and temp worker could be SR contact
-- -----------------------------------------------------------------------------
PROCEDURE Validate_Employee
( p_api_name		IN	VARCHAR2,
  p_parameter_name	IN	VARCHAR2,
  p_employee_id		IN	NUMBER,
  p_org_id		IN	NUMBER   := NULL,
  p_employee_name	OUT	NOCOPY VARCHAR2,
  x_return_status	OUT	NOCOPY VARCHAR2
)
IS
  l_orig_org_id		NUMBER;
  l_dummy  	       VARCHAR2(1);
  l_api_name           CONSTANT VARCHAR2(30)    := 'Validate_Employee';
  l_api_name_full      CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

 CURSOR employee IS
 SELECT  'x'
 FROM per_workforce_x hr
 WHERE hr.person_id = p_employee_id
 AND NVL(hr.termination_date,SYSDATE) >= SYSDATE;

BEGIN
  -- Initialize return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN employee;
  FETCH employee INTO l_dummy;
  IF (employee%NOTFOUND) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    CLOSE employee;

    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE employee;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
	Add_Invalid_Argument_Msg
	          ( p_token_an    => l_api_name_full,
                    p_token_v     => TO_CHAR(p_employee_id),
	            p_token_p     => p_parameter_name,
                    p_table_name  => G_TABLE_NAME,
                    p_column_name => 'EMPLOYEE_ID' );

    WHEN OTHERS THEN
	      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
	      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
	      fnd_msg_pub.ADD;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Validate_Employee;

-- --------------------------------------------------------------------------------
-- Validate_Customer
--	verify that the given customer is a valid and active customer.
--      Check that the party_type of the Customer is same as the passed Caller_type (Bug 3666089)
-- --------------------------------------------------------------------------------
  PROCEDURE Validate_Customer (
	p_api_name			IN   VARCHAR2,
	p_parameter_name		IN   VARCHAR2,
	p_customer_id			IN   NUMBER,
	p_caller_type                   IN   VARCHAR2,      --Bug 3666089
	x_return_status			OUT  NOCOPY VARCHAR2
  ) IS

-- l_dummy 	VARCHAR2(1);
 l_party_type     VARCHAR2(30);     -- Bug 3666089
 l_api_name                   CONSTANT VARCHAR2(30)    := 'Validate_Customer';
 l_api_name_full              CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

 --For bug 2885111
 l_associated_col1  VARCHAR2(240);
 l_token_v VARCHAR2(4000);

  BEGIN
    -- Initialize Return Status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --For bug 2885111
    l_associated_col1 := G_TABLE_NAME ||'.'||'CUSTOMER_ID';
    l_token_v := TO_CHAR(p_customer_id);

    BEGIN
	SELECT party_type INTO l_party_type    -- Bug 3666089
	  FROM  hz_parties a
	  WHERE a.party_id = p_customer_id
	  AND	a.status = 'A'
          AND   a.party_type IN ('ORGANIZATION','PERSON');

    EXCEPTION
	WHEN NO_DATA_FOUND THEN
		   x_return_status := FND_API.G_RET_STS_ERROR;

		   -- For bug 2885111 - adding a new error message
		    FND_MESSAGE.Set_Name('CS', 'CS_SR_INVALID_CUSTOMER');
		    FND_MESSAGE.Set_Token('API_NAME', l_api_name_full);
		    FND_MESSAGE.Set_Token('VALUE',l_token_v);
		    FND_MESSAGE.Set_Token('P_NAME', p_parameter_name);
		    FND_MSG_PUB.ADD_DETAIL(p_associated_column1 => l_associated_col1);


          /* Add_Invalid_Argument_Msg( p_token_an    => l_api_name_full,
  		              	     p_token_v     => TO_CHAR(p_customer_id),
		      	     	     p_token_p     => p_parameter_name,
                                     p_table_name  => G_TABLE_NAME,
                                     p_column_name => 'CUSTOMER_ID' ); */
	WHEN OTHERS THEN
	      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
	      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
	      fnd_msg_pub.ADD;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    END;
    --Addition for 3666089 starts
    IF (l_party_type <> p_caller_type) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.Set_Name('CS', 'CS_SR_INVALID_CUST_TYPE');
        FND_MSG_PUB.ADD; --3666089 (Jun 15)
    END IF;
    --Addition for 3666089 Ends

  END Validate_Customer;

/*
** Validate_Bill_To_Ship_To_Ct - validate_bill_to_ship_to_contact
** 1. Same procedure will be used to Validate Bill_To and Ship_To Contacts
** 2. Contat can be
**    a. If Bill_to_customer is person , contact can be same person (Self)
**    b. If bill_to_customer is person or Org, Contact can be a Relationship
**       between the Bill_To Customer and a Person
*/

PROCEDURE Validate_Bill_To_Ship_To_Ct (
   p_api_name             IN   VARCHAR2,
   p_parameter_name       IN   VARCHAR2,
   p_bill_to_contact_id   IN   NUMBER,
   p_bill_to_party_id     IN   NUMBER,
   p_customer_type	  IN   VARCHAR2,
   x_return_status        OUT  NOCOPY VARCHAR2 )
IS
   l_dummy  VARCHAR2(1);
   l_api_name         CONSTANT VARCHAR2(30) := 'Validate_Bill_To_Ship_To_Ct';
   l_api_name_full    CONSTANT VARCHAR2(70) := G_PKG_NAME||'.'||l_api_name;
   l_party_type       hz_parties.party_type % type;

   CURSOR bill_to_party_type_csr is
     SELECT party_type from hz_parties
      WHERE party_id = p_bill_to_party_id;

   CURSOR validate_bill_to_contact_csr IS
   SELECT 'x'
   FROM    Hz_Parties sub,
           Hz_Relationships r
   WHERE r.object_id    = p_bill_to_party_id
   AND   r.party_id     = p_bill_to_contact_id
   AND   sub.status     = 'A'
   AND   r.status       = 'A'
   AND   r.subject_id   = sub.party_id
   AND   sub.party_type = 'PERSON'
   AND   NVL(r.start_date, SYSDATE-1) < SYSDATE
   AND   NVL(r.end_date, SYSDATE+1) > SYSDATE;

BEGIN
   -- Initialize the return status.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   /*
   IF (p_bill_to_party_id = p_bill_to_contact_id AND
      p_customer_type = 'PERSON')           THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
   */
   /* if bill_to_party_id is same as bill_to_contact_id then bill_to_party_id
      has to be of type PERSON because contact has has to be of type PERSON
      2/11/04 smisra Bug 3379631
      Above 3 lines are replaced by 10 following lines
   */
   IF (p_bill_to_party_id = p_bill_to_contact_id) then
      OPEN bill_to_party_type_csr;
      FETCH bill_to_party_type_csr into l_party_type;
      CLOSE bill_to_party_type_csr;
      IF (l_party_type <> 'PERSON') then
         x_return_status := FND_API.G_RET_STS_ERROR;
         RAISE NO_DATA_FOUND;
      END IF;
   ELSE
      OPEN validate_bill_to_contact_csr;
      FETCH validate_bill_to_contact_csr INTO l_dummy;

      IF (validate_bill_to_contact_csr%NOTFOUND) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         CLOSE validate_bill_to_contact_csr;
         RAISE NO_DATA_FOUND;
      END IF;

      CLOSE validate_bill_to_contact_csr;
   END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      Add_Invalid_Argument_Msg(p_token_an    => l_api_name_full,
         p_token_v     => TO_CHAR(p_bill_to_contact_id),
         p_token_p     => p_parameter_name ,
         p_table_name  => G_TABLE_NAME,
         p_column_name => 'BILL_TO_CONTACT_ID' );

   WHEN OTHERS THEN
      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
      fnd_msg_pub.ADD;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Validate_Bill_To_Ship_To_Ct;


/*
** Validate_Customer_Contact
** 1. The validation of the customer contact depends on the value of the
**    service request customer. Therefore, the service request customer is
**    passed in as a parameter.
** 2. Since customer relationships is a multi-org entity, this procedure
**    accepts ORG_ID as a parameter.
** 3. Verify that the contact is an active contact within the operating unit.
** 4. Verify that the contact belongs to the service request customer, or one
**    of its related customers.
** 5. Made the LOV query and the validation in sync, dated oct 11th 2002 by
**    shijain, also the union part is removed from the cursor to check the
**    self condition as in that case the customer is already valid.
** 6. Added one more in parameter as p_customer_type, to get the header
**    customer_type by shijain.
*
**** Commented and replaced by Validate_bill_To_contact in 11.5.9 */
PROCEDURE Validate_Customer_Contact
( p_api_name             IN   VARCHAR2,
  p_parameter_name       IN   VARCHAR2,
  p_customer_contact_id  IN   NUMBER,
  p_customer_id  	 IN   NUMBER,
  p_org_id               IN   NUMBER     := NULL,
  p_customer_type        IN   VARCHAR2,
  x_return_status        OUT  NOCOPY VARCHAR2 )
IS
   l_dummy  VARCHAR2(1);
   l_api_name          CONSTANT VARCHAR2(30) := 'Validate_Customer_Contact';
   l_api_name_full     CONSTANT VARCHAR2(70) := G_PKG_NAME||'.'||l_api_name;

   CURSOR validate_bill_to_contact_csr IS
   SELECT 'x'
   FROM    Hz_Parties sub,
   Hz_Relationships r
   WHERE r.object_id = p_customer_id
   AND   r.party_id  = p_customer_contact_id
   AND   sub.status  = 'A'
   AND   r.status    = 'A'
   AND   r.subject_id = sub.party_id
   AND   sub.party_type = 'PERSON'
   AND   NVL(r.start_date, SYSDATE-1) < SYSDATE
   AND   NVL(r.end_date, SYSDATE+1) > SYSDATE;

BEGIN
   -- Initialize the return status.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF ( p_customer_id = p_customer_contact_id AND
	p_customer_type = 'PERSON')  THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
   ELSE
      OPEN validate_bill_to_contact_csr;
      FETCH validate_bill_to_contact_csr INTO l_dummy;

      IF (validate_bill_to_contact_csr%NOTFOUND) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         CLOSE validate_bill_to_contact_csr;
         RAISE NO_DATA_FOUND;
      END IF;

      CLOSE validate_bill_to_contact_csr;

   END IF;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      Add_Invalid_Argument_Msg(
	 p_token_an    => l_api_name_full,
         p_token_v     => TO_CHAR(p_customer_contact_id),
         p_token_p     => p_parameter_name,
         p_table_name  => G_TABLE_NAME,
         p_column_name => 'CUSTOMER_CONTACT_ID' );

   WHEN OTHERS THEN
      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
      fnd_msg_pub.ADD;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Validate_Customer_Contact;

--Procedure added to support contacts of type relation
--Added on Jan 22nd 2001
-- Made the LOV query and cursor query in sync.by shijain dated 11th oct 2002

-- 06/06/06 spusegao Modified the WHERE clause 'AND NVL(r.start_date, SYSDATE-1) < SYSDATE' to
--                   'AND NVL(r.start_date, SYSDATE-1) <= SYSDATE' for bug # 5216551.

PROCEDURE Validate_Org_Relationship
( p_api_name             IN   VARCHAR2,
  p_parameter_name       IN   VARCHAR2,
  p_customer_contact_id  IN   NUMBER,
  p_customer_id  	 IN   NUMBER,
  p_org_id               IN   NUMBER     := NULL,
  x_return_status        OUT  NOCOPY VARCHAR2
)
IS
    l_dummy  VARCHAR2(1);
  	l_api_name                   CONSTANT VARCHAR2(30)    := 'Validate_Org_Relationship';
    l_api_name_full              CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

  CURSOR party_relationship IS
  SELECT 'x'
  FROM    Hz_Parties sub,
          Hz_Relationships r,
          Hz_Parties obj
  WHERE r.object_id = p_customer_id
  AND   r.party_id  = p_customer_contact_id
  AND   sub.status = 'A'
  AND   r.status   = 'A'
  AND   obj.status = 'A'
  AND   r.subject_id = sub.party_id
  AND   r.object_id  = obj.party_id
  AND   sub.party_type = 'PERSON'
  AND   obj.party_type = 'ORGANIZATION'
  AND   NVL(r.start_date, SYSDATE-1) <= SYSDATE
  AND   NVL(r.end_date, SYSDATE+1) > SYSDATE;

BEGIN
  -- Initialize the return status.
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN party_relationship;
  FETCH party_relationship INTO l_dummy;

  IF (party_relationship%NOTFOUND) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    CLOSE party_relationship;
    RAISE NO_DATA_FOUND;
  END IF;

  CLOSE party_relationship;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
       	  x_return_status := FND_API.G_RET_STS_ERROR;
    	  Add_Invalid_Argument_Msg( p_token_an    => l_api_name_full,
	              	      	    p_token_v     => TO_CHAR(p_customer_contact_id),
				    p_token_p     => p_parameter_name,
                                    p_table_name  => G_TABLE_NAME,
                                    p_column_name => 'CUSTOMER_CONTACT_ID' );
   WHEN OTHERS THEN
	      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
	      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
	      fnd_msg_pub.ADD;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Validate_Org_Relationship;

-- Made the LOV query and cursor query in sync.by shijain dated 11th oct 2002

PROCEDURE Validate_Person_Relationship
( p_api_name             IN   VARCHAR2,
  p_parameter_name       IN   VARCHAR2,
  p_customer_contact_id  IN   NUMBER,
  p_customer_id  	 IN   NUMBER,
  p_org_id               IN   NUMBER     := NULL,
  x_return_status        OUT  NOCOPY VARCHAR2
)
IS
    l_dummy  VARCHAR2(1);
  	l_api_name                   CONSTANT VARCHAR2(30)    := 'Validate_Person_Relationship';
    l_api_name_full              CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

  CURSOR party_relationship_per IS
  SELECT 'x'
  FROM    Hz_Parties sub,
          Hz_Relationships r,
          Hz_Parties obj
  WHERE r.object_id = p_customer_id
  AND   r.party_id  = p_customer_contact_id
  AND   sub.status = 'A'
  AND   r.status   = 'A'
  AND   obj.status = 'A'
  AND   r.subject_id = sub.party_id
  AND   r.object_id  = obj.party_id
  AND   sub.party_type = 'PERSON'
  AND   obj.party_type = 'PERSON'
  -- Made below changes as per bug6629807 put <= instead of < rtripath 12/30/2007
  AND   NVL(r.start_date, SYSDATE-1) <= SYSDATE
  AND   NVL(r.end_date, SYSDATE+1) > SYSDATE;

BEGIN
  -- Initialize the return status.
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_customer_id = p_customer_contact_id THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
  ELSE
      OPEN party_relationship_per;
      FETCH party_relationship_per INTO l_dummy;
      IF (party_relationship_per%NOTFOUND) THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          CLOSE party_relationship_per;

          RAISE NO_DATA_FOUND;
      END IF;
      CLOSE party_relationship_per;
   END IF;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
    	  x_return_status := FND_API.G_RET_STS_ERROR;
    	  Add_Invalid_Argument_Msg( p_token_an    => l_api_name_full,
	              	      	    p_token_v     => TO_CHAR(p_customer_contact_id),
				    p_token_p     => p_parameter_name,
                                    p_table_name  => G_TABLE_NAME,
                                    p_column_name => 'CUSTOMER_CONTACT_ID' );
	WHEN OTHERS THEN
	      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
	      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
	      fnd_msg_pub.ADD;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Validate_Person_Relationship;

-----------------------------------------------------------------------------
-- Validate_Customer_Product
--   1. Since the installed base is a multi-org entity, this procedure accepts
--      ORG_ID as a parameter.
--   2. Verify that the customer pro
-----------------------------------------------------------------------------
PROCEDURE Validate_Customer_Product
( p_api_name		IN	VARCHAR2,
  p_parameter_name	IN	VARCHAR2,
  p_customer_product_id	IN	NUMBER,
  p_org_id		IN	NUMBER	:= NULL,
  p_customer_id		IN 	NUMBER,
  p_inventory_item_id	OUT	NOCOPY NUMBER,
  p_inventory_org_id    IN      NUMBER,
  x_return_status	OUT	NOCOPY VARCHAR2 )
IS
   l_api_name         CONSTANT VARCHAR2(30) := 'Validate_Customer_Product';
   l_api_name_full    CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_api_name;

BEGIN
   -- Initialize the return status.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Changes made by shijain dec 4th 2002, added the check if the profile
   -- value of cs_sr_restrict_ib is yes then check for hz_party_sites and
   -- hz_locations else don't need to check anything

   IF CS_ServiceRequest_PVT.g_restrict_ib = 'YES' THEN
      SELECT a.inventory_item_id
      INTO   p_inventory_item_id
      FROM   csi_item_instances a,
      mtl_system_items_b b,
      csi_i_parties cip
      WHERE  a.instance_id = p_customer_product_id
      --AND a.owner_party_id = p_customer_id
      AND cip.party_id = p_customer_id
      AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(a.active_start_date,SYSDATE))
      AND TRUNC(NVL(a.active_end_date, SYSDATE))
      AND a.location_type_code IN ('HZ_PARTY_SITES','HZ_LOCATIONS')
      AND a.owner_party_source_table = 'HZ_PARTIES'
      AND a.instance_id = cip.instance_id
      AND cip.party_source_table  = 'HZ_PARTIES'
      AND a.inventory_item_id = b.inventory_item_id
      AND b.organization_id = p_inventory_org_id
      -- Commented service_item_flag condition as this is not used
      -- anymore and added contract_item_type_code condition
      -- AND b.service_item_flag = 'N'
      -- For ER 3701924
      -- AND contract_item_type_code IS NULL
      AND b.enabled_flag  = 'Y'
      -- Added for Bug# 2167129,2175917
      AND b.serv_req_enabled_code = 'E'
      AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(b.start_date_active, SYSDATE))
      AND TRUNC(NVL(b.end_date_active, SYSDATE))
      AND rownum<2;
   ELSE
      SELECT a.inventory_item_id
      INTO   p_inventory_item_id
      FROM   csi_item_instances a,
      mtl_system_items_b b,
      csi_i_parties cip
      WHERE  a.instance_id = p_customer_product_id
      -- AND a.owner_party_id = p_customer_id
      AND cip.party_id = p_customer_id
      AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(a.active_start_date,SYSDATE))
      AND TRUNC(NVL(a.active_end_date, SYSDATE))
      AND a.owner_party_source_table = 'HZ_PARTIES'
      AND a.instance_id = cip.instance_id
      AND cip.party_source_table  = 'HZ_PARTIES'
      AND a.inventory_item_id = b.inventory_item_id
      AND b.organization_id = p_inventory_org_id
      -- Commented service_item_flag condition as this is not used
      -- anymore and added contract_item_type_code condition
      -- AND b.service_item_flag = 'N'
      -- For ER 3701924
      -- AND contract_item_type_code IS NULL
      AND b.enabled_flag  = 'Y'
      -- Added for Bug# 2167129,2175917
      AND b.serv_req_enabled_code = 'E'
      AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(b.start_date_active, SYSDATE))
      AND TRUNC(NVL(b.end_date_active, SYSDATE))
      AND rownum<2;
   END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      Add_Invalid_Argument_Msg(
	 p_token_an    => l_api_name_full,
         p_token_v     => TO_CHAR(p_customer_product_id),
         p_token_p     => p_parameter_name,
         p_table_name  => G_TABLE_NAME,
         p_column_name => 'CUSTOMER_PRODUCT_ID' );

   WHEN OTHERS THEN
      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
      fnd_msg_pub.ADD;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Validate_Customer_Product;

/*
Modification History
Date     Name     Desc
-------- -------- ---------------------------------------------------------------
03/25/05 smisra   Bug 4239975 Modified this procedure and removed validation of
                  current serial number when customer product is null and
                  inventory item is IB trackable.
*/
----------------------------------------------
PROCEDURE  Validate_Current_Serial(
   p_api_name               IN  VARCHAR2,
   p_parameter_name         IN  VARCHAR2,
   p_inventory_item_id      IN  NUMBER   := NULL,
   p_inventory_org_id       IN  NUMBER,
   p_customer_product_id    IN  NUMBER  := NULL,
   p_customer_id            IN NUMBER   := NULL,
   p_current_serial_number  IN VARCHAR2,
   x_return_status          OUT  NOCOPY VARCHAR2 )
IS
   l_dummy           VARCHAR2(1);
   inv_item_IB_trackable        VARCHAR2(1);
   l_api_name        CONSTANT VARCHAR2(30)    := 'Validate_Current_Serial';
   l_api_name_full   CONSTANT VARCHAR2(70)    := G_PKG_NAME||'.'||l_api_name;


BEGIN
   -- Initialize the return status.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --Check if installed base or not
   --Added a condition to fix bug# 1902127, since the script
   --fails while creating/updating an SR for non-IB.

   IF ( p_customer_product_id IS NOT NULL ) AND
      ( p_customer_product_id <> FND_API.G_MISS_NUM ) THEN

      -- Changes made by shijain dec 4th 2002, added the check if the profile
      -- value of cs_sr_restrict_ib is yes then check for hz_party_sites and
      -- hz_locations else don't need to check anything

      IF CS_ServiceRequest_PVT.g_restrict_ib = 'YES' THEN

         SELECT 'x' INTO l_dummy
         FROM   csi_item_instances a,
                mtl_system_items_b b,
                csi_i_parties cip
         WHERE  a.instance_id = p_customer_product_id
         AND a.serial_number = p_current_serial_number
         -- AND a.owner_party_account_id = p_customer_id
         AND cip.party_id = p_customer_id
         AND a.instance_id = cip.instance_id
         AND cip.party_source_table  = 'HZ_PARTIES'
         AND    b.serv_req_enabled_code = 'E'
         -- Added contract_item_type_code condition
	 -- For ER 3701924
         -- AND contract_item_type_code IS NULL
         -- Added for Bug# 2167129,2175917
         AND a.location_type_code IN ('HZ_PARTY_SITES','HZ_LOCATIONS')
         AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(a.active_start_date,SYSDATE))
         AND TRUNC(NVL(a.active_end_date, SYSDATE))
         AND b.inventory_item_id = a.inventory_item_id
         AND b.organization_id = p_inventory_org_id
         AND rownum<2;
      ELSE
         SELECT 'x' INTO l_dummy
         FROM   csi_item_instances a,
                mtl_system_items_b b,
                csi_i_parties cip
         WHERE  a.instance_id = p_customer_product_id
         AND a.serial_number = p_current_serial_number
         -- AND a.owner_party_account_id = p_customer_id
         AND cip.party_id = p_customer_id
         AND a.instance_id = cip.instance_id
         AND cip.party_source_table  = 'HZ_PARTIES'
         AND    b.serv_req_enabled_code = 'E'
         -- Added contract_item_type_code condition
	 -- For ER 3701924
         -- AND contract_item_type_code IS NULL
         AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(a.active_start_date,SYSDATE))
         AND TRUNC(NVL(a.active_end_date, SYSDATE))
         AND b.inventory_item_id = a.inventory_item_id
         AND b.organization_id = p_inventory_org_id
         AND rownum < 2;
      END IF;
   END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      Add_Invalid_Argument_Msg(p_token_an    => l_api_name_full,
         p_token_v     => p_current_serial_number,
         p_token_p     => p_parameter_name ,
         p_table_name  => G_TABLE_NAME,
         p_column_name => 'CURRENT_SERIAL_NUMBER');

   WHEN OTHERS THEN
      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
      fnd_msg_pub.ADD;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Validate_Current_Serial;

-- for cmro_eam
-- ------------------------------------------------------------------------------
-- Validate Inventory_Org
-- 1. verify that the given inventory org is valid
-- ------------------------------------------------------------------------------
-- -----------------------------------------------------------------------------
-- Modification History
-- Date     Name     Desc
-- -------- -------- -----------------------------------------------------------
-- 06/09/05 smisra   Release 12 changes
--                   removed parameter p_maintenance_flag and it's processing
-- -----------------------------------------------------------------------------
PROCEDURE Validate_Inventory_Org(
        p_api_name              IN VARCHAR2,
        p_parameter_name        IN VARCHAR2,
        p_inv_org_id            IN NUMBER,
        x_inv_org_master_org_flag OUT NOCOPY VARCHAR2,
        x_return_status           OUT NOCOPY VARCHAR2
) IS
   l_api_name                   CONSTANT VARCHAR2(30) := 'Validate_Inventory_Org';
   l_api_name_full              CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_api_name;
   l_dummy VARCHAR2(1);

l_eam_enabled             mtl_parameters.eam_enabled_flag       % TYPE;
l_maint_org_id            mtl_parameters.maint_organization_id  % TYPE;
l_master_org_id           mtl_parameters.master_organization_id % TYPE;
BEGIN
   -- Initialize Return Status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_inv_org_master_org_flag := NULL;

  get_org_details
  ( p_org_id           => p_inv_org_id
  , x_eam_enabled_flag => l_eam_enabled
  , x_maint_org_id     => l_maint_org_id
  , x_master_org_id    => l_master_org_id
  , x_return_Status    => x_return_status
  );
  IF x_return_status = FND_API.G_RET_STS_ERROR
  THEN
    RAISE NO_DATA_FOUND;
  END IF;
  IF p_inv_org_id = l_master_org_id
  THEN
    x_inv_org_master_org_flag := 'Y';
  ELSE
    x_inv_org_master_org_flag := 'N';
  END IF;
/***** replace this query ith the above procedure call 7/27/05 smisra
      select 'x' INTO l_dummy
      from mtl_parameters
      where organization_id = p_inv_org_id;
***/
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      Add_Invalid_Argument_Msg(
	 p_token_an    => l_api_name_full,
         p_token_v     => p_inv_org_id,
         p_token_p     => p_parameter_name ,
         p_table_name  => G_TABLE_NAME,
         p_column_name => 'INVENTORY_ORG_ID');

   WHEN OTHERS THEN
      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
      fnd_msg_pub.ADD;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Validate_Inventory_Org;

-- ------------------------------------------------------------------------------
-- Validate Owning Department
-- 1. verfity that the departmnet is activ in bom_departments
-- 2. verify that the department is vaild for the given organization
-- ------------------------------------------------------------------------------
PROCEDURE Validate_Owning_Department(
      p_api_name                IN VARCHAR2,
      p_parameter_name          IN VARCHAR2,
      p_inv_org_id              IN NUMBER,
      p_owning_dept_id          IN NUMBER,
      p_maintenance_flag        IN VARCHAR2,
      x_return_status           OUT NOCOPY VARCHAR2
    )IS
    l_api_name           CONSTANT VARCHAR2(30) := 'Validate_Owning_Department';
    l_api_name_full      CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_api_name;
    l_dummy VARCHAR2(1);
BEGIN
    -- Initialize Return Status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (p_maintenance_flag = 'Y' or p_maintenance_flag = 'y') THEN
      IF (p_owning_dept_id IS NOT NULL AND
            p_owning_dept_id <> FND_API.G_MISS_NUM) THEN
         select 'x' INTO l_dummy
         from bom_departments b
         where b.department_id = p_owning_dept_id
         and TRUNC(NVL(b.disable_date,SYSDATE+1)) > TRUNC(SYSDATE)
         and b.organization_id = p_inv_org_id;
      END IF;
   END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      Add_Invalid_Argument_Msg(
	 p_token_an    => l_api_name_full,
         p_token_v     => p_owning_dept_id,
         p_token_p     => p_parameter_name ,
         p_table_name  => G_TABLE_NAME,
         p_column_name => 'OWNING_DEPARTMENT_ID');

   WHEN OTHERS THEN
      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
      fnd_msg_pub.ADD;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Validate_Owning_Department;

-- --------------------------------------------------------------------------------
-- Validate_Product
-- 1. verify that the products exists in the given operating unit and the
--    inventory org specified in the profile options.
-- 2. ensure that the product is a serviceable item.
-- --------------------------------------------------------------------------------
-- -----------------------------------------------------------------------------
-- Modification History
-- Date     Name     Desc
-- -------- -------- -----------------------------------------------------------
-- 06/07/05 smisra   Release 12 changes
--                   Add parameter p_maint_organization_id to perform EAM item
--                   validation. Removed the existing query to validate EAM item
--                   As per new validation EAM item can belong to maint org or
--                   any org that is maintained by maint org.
--                   Old validation logic can be seen in file version:115.221
-- 08/03/05 smisra   added a new param p_inv_org_master_org_flag. if this flag
--                   is Y then item can belong to any org in the master org
--                   that is maintained by maint_organization_id otherwise
--                   item should belong to inv org only.
-- 08/25/05 smisra   gave error if maint_organization_id is G_MISS_NUM for
--                   EAM SRs
-- -----------------------------------------------------------------------------
PROCEDURE Validate_Product
( p_api_name              IN         VARCHAR2
, p_parameter_name        IN         VARCHAR2
, p_inventory_item_id     IN         NUMBER
, p_inventory_org_id      IN         NUMBER
, x_return_status         OUT NOCOPY VARCHAR2
, p_maintenance_flag      IN         VARCHAR2
, p_maint_organization_id   IN         NUMBER
, p_inv_org_master_org_flag IN VARCHAR2
) IS

l_dummy 	VARCHAR2(1);
l_api_name           CONSTANT VARCHAR2(30) := 'Validate_Product';
l_api_name_full      CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_api_name;


BEGIN
    -- Initialize Return Status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- for cmro_eam
  IF (p_maintenance_flag = 'Y' or p_maintenance_flag = 'y') THEN
    IF p_maint_organization_id IS NULL OR
       p_maint_organization_id = FND_API.G_MISS_NUM
    THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      Add_Null_Parameter_Msg
      ( p_token_an    => l_api_name_full
      , p_token_np    => 'p_maint_organization_id'
      , p_table_name  => G_TABLE_NAME
      , p_column_name => 'MAINT_ORGANIZATION_ID'
      );
    ELSIF p_inv_org_master_org_flag = 'Y'
    THEN
      SELECT 'X'
      INTO   l_dummy
      FROM   mtl_system_items_b msi,
             mtl_parameters     mp
      WHERE  msi.inventory_item_id     = p_inventory_item_id
        AND  msi.enabled_flag          = 'Y'
        AND  msi.serv_req_enabled_code = 'E'
        AND  msi.organization_id       = mp.organization_id
        AND  mp.maint_organization_id  = p_maint_organization_id
        AND  mp.master_organization_id = p_inventory_org_id
        AND  msi.eam_item_type IN (1,3)
        AND  TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date_active, SYSDATE))
                                AND TRUNC(NVL(end_date_active  , SYSDATE))
        AND  rownum = 1;
    ELSE
      SELECT 'X'
      INTO   l_dummy
      FROM   mtl_system_items_b msi,
             mtl_parameters     mp
      WHERE  msi.inventory_item_id     = p_inventory_item_id
        AND  msi.enabled_flag          = 'Y'
        AND  msi.serv_req_enabled_code = 'E'
        AND  msi.organization_id       = mp.organization_id
        AND  mp.maint_organization_id  = p_maint_organization_id
        AND  mp.organization_id = p_inventory_org_id
        AND  msi.eam_item_type IN (1,3)
        AND  TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date_active, SYSDATE))
                                AND TRUNC(NVL(end_date_active  , SYSDATE));
    END IF; -- end if for condition p_maint_organization_id IS NULL
  ELSE
    -- item is not EAM
    SELECT 'x' INTO l_dummy
    FROM  mtl_system_items_b msi
    WHERE msi.inventory_item_id     = p_inventory_item_id
      AND msi.enabled_flag          = 'Y'
      AND msi.serv_req_enabled_code = 'E'
      -- For ER 3701924
      -- AND   msi.contract_item_type_code IS NULL
      AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date_active, SYSDATE))
                             AND TRUNC(NVL(end_date_active  , SYSDATE))
      AND msi.organization_id = p_inventory_org_id;
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    Add_Invalid_Argument_Msg
    ( p_token_an    => l_api_name_full
    , p_token_v     => TO_CHAR(p_inventory_item_id)
    , p_token_p     => p_parameter_name
    , p_table_name  => G_TABLE_NAME
    , p_column_name => 'INVENTORY_ITEM_ID'
    );
  WHEN OTHERS THEN
    fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
    fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
    fnd_msg_pub.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Validate_Product;


-- --------------------------------------------------------------------------------
-- Validate_Problem_Code
--	verify that the problem code is an active problem code - same validation as UI
--      First based on the parameters, check whether u find records in cs_sr_prob_code_mapping
--      If 1 or more records are found
--                  then verify whether the given problem code is present in the records
--          Raise error if no problem code matches the given problem code
--      If 0 records are found in the Query, then validate the given problem code
--          agains cs_lookups
-- --------------------------------------------------------------------------------
--  DJ API Cleanup
--  Changed the validation of Problem code to invoke the problem code
--  validation api cs_sr_prob_code_mapping_pkg.validate_problem_code
PROCEDURE Validate_Problem_Code (
	p_api_name			 IN  VARCHAR2,
	p_parameter_name		 IN  VARCHAR2,
	p_problem_code 			 IN  VARCHAR2,
        p_incident_type_id               IN  NUMBER,
        p_inventory_item_id              IN  NUMBER,
	p_inventory_org_id               IN  NUMBER, -- added for API cleanup
	p_category_id                    IN  NUMBER, -- added for API cleanup
	x_return_status			OUT  NOCOPY VARCHAR2)
IS

   l_api_name         CONSTANT VARCHAR2(30)    := 'Validate_Problem_Code';
   l_api_name_full    CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

   l_pc_rec           cs_sr_prob_code_mapping_pkg.probcode_search_rec;

   lx_msg_count       NUMBER;
   lx_msg_data        VARCHAR2(2000);

BEGIN
   -- Initialize Return Status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- populate the problem code mapping record type
   l_pc_rec.service_request_type_id := p_incident_type_id;
   l_pc_rec.inventory_item_id       := p_inventory_item_id;
   l_pc_rec.organization_id         := p_inventory_org_id;
   l_pc_rec.product_category_id     := p_category_id;

   -- invoke the prob. code validation API that returns back if the given
   -- problem code is valid for the given mapping criteria. This API call
   -- is introduced in 11.5.10 and replaces the SQL logic that was present
   -- pre 11.5.10

   cs_sr_prob_code_mapping_pkg.validate_problem_code (
      p_api_version             => 1.0,
      p_init_msg_list           => FND_API.G_TRUE,
      p_probcode_criteria_rec   => l_pc_rec,
      p_problem_code            => p_problem_code,
      x_return_status           => x_return_status,
      x_msg_count               => lx_msg_count,
      x_msg_data                => lx_msg_data );

   if ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) then
      -- new message for 11.5.10
      -- Problem code is not valid. Please check the values for the following:\
      -- Service request type, inventory item and product category.
      fnd_message.set_name ('CS', 'CS_SR_PROB_CODE_INVALID');
      fnd_message.set_token('API_NAME', l_api_name_full );
      fnd_msg_pub.add;
   end if;


EXCEPTION
   WHEN OTHERS THEN
      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
      fnd_msg_pub.ADD;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Validate_Problem_Code;

-- -----------------------------------------------------------------------------
-- Validate_Cust_Pref_Lang_Code
-- -----------------------------------------------------------------------------

  PROCEDURE Validate_Cust_Pref_Lang_Code (
	p_api_name			 IN  VARCHAR2,
	p_parameter_name		 IN  VARCHAR2,
	p_cust_pref_lang_code		 IN  VARCHAR2,
	x_return_status			OUT  NOCOPY VARCHAR2
  ) IS

  l_dummy 	VARCHAR2(1);
  l_api_name                   CONSTANT VARCHAR2(30)    := 'Validate_Cust_Pref_Lang_Code';
  l_api_name_full              CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

  BEGIN
    -- Initialize Return Status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    BEGIN
	SELECT 'x' INTO l_dummy
	  FROM  cs_sr_preferred_lang_v
          WHERE language_code = p_cust_pref_lang_code
          AND   trunc(sysdate) between trunc(nvl(start_date_active,sysdate))
          AND   trunc(nvl(end_date_active,sysdate));

    EXCEPTION
	WHEN NO_DATA_FOUND THEN
	   x_return_status := FND_API.G_RET_STS_ERROR;
           Add_Invalid_Argument_Msg( p_token_an    => l_api_name_full,
  		              	     p_token_v     => p_cust_pref_lang_code,
				     p_token_p     => p_parameter_name,
                                     p_table_name  => G_TABLE_NAME,
                                     p_column_name => 'CUST_PERF_LANG_CODE');
	WHEN OTHERS THEN
	      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
	      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
	      fnd_msg_pub.ADD;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    END;
  END Validate_Cust_Pref_Lang_Code;

-- ----------------------------------------------------------------------------
-- Validate_Comm_Pref_Code
-- -----------------------------------------------------------------------------
  PROCEDURE Validate_Comm_Pref_Code (
	p_api_name			 IN  VARCHAR2,
	p_parameter_name		 IN  VARCHAR2,
	p_comm_pref_code		 IN  VARCHAR2,
	x_return_status			OUT  NOCOPY VARCHAR2
  ) IS
  l_dummy 	VARCHAR2(60);
  l_api_name                   CONSTANT VARCHAR2(30)    := 'Validate_Comm_Pref_Code';
  l_api_name_full              CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

  BEGIN
    -- Initialize Return Status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    BEGIN
	SELECT DISTINCT lookup_code INTO l_dummy
	  FROM  ar_lookups
          WHERE lookup_type = 'COMMUNICATION_TYPE'
          AND   lookup_code = p_comm_pref_code;

    EXCEPTION
	WHEN NO_DATA_FOUND THEN
	   x_return_status := FND_API.G_RET_STS_ERROR;
           Add_Invalid_Argument_Msg( p_token_an    => l_api_name_full,
  		              	     p_token_v     => p_comm_pref_code,
			      	     p_token_p     => p_parameter_name,
                                     p_table_name  => G_TABLE_NAME,
                                     p_column_name => 'COMM_PREF_CODE' );
	WHEN OTHERS THEN
	      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
	      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
	      fnd_msg_pub.ADD;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    END;
  END Validate_Comm_Pref_Code;

-- --------------------------------------------------------------------------------
-- Validate_Category_Id
/*
Modification History
Date       Name     Desc
---------- -------- ---------------------------------------------------------------
02/28/2005 smisra   Bug 4083288
                    Added a parameter category set id. Performed validation using
                    this parameter instead of profile option value for category set
                    id. Replaced invalid argument Error message with meaningful
                    Error message.
*/
-- --------------------------------------------------------------------------------
  PROCEDURE Validate_Category_Id(
	p_api_name			 IN  VARCHAR2,
	p_parameter_name		 IN  VARCHAR2,
	p_category_id                    IN  NUMBER,
        p_category_set_id                IN  NUMBER,
	x_return_status			OUT  NOCOPY VARCHAR2
  ) IS

  l_dummy 	VARCHAR2(1);
  l_profile     VARCHAR2(255);
  l_api_name                   CONSTANT VARCHAR2(30)    := 'Validate_Category_Id';
  l_api_name_full              CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

BEGIN
    -- Initialize Return Status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Changed the Profile CS_SR_PLATFORM_CATEGORY_SET to
    -- CS_SR_DEFAULT_CATEGORY_SET.Fix for Bug# 2102330

    --l_profile       := FND_PROFILE.VALUE('CS_SR_DEFAULT_CATEGORY_SET');
    l_profile := p_category_set_id;

    BEGIN
        IF (p_category_id IS NOT NULL AND
            l_profile IS NOT NULL ) THEN
	  SELECT 'x' INTO l_dummy
          --FROM  mtl_item_categories ic
          FROM  mtl_category_set_valid_cats ic
	  WHERE ic.category_id = p_category_id
	  AND	ic.category_set_id  = l_profile;
          --AND   ic.organization_id  = CS_STD.Get_Item_Valdn_Orgzn_Id;
        ELSE
          IF (l_profile IS NULL AND
              p_category_id IS NOT NULL) THEN
              RAISE NO_DATA_FOUND;
          END IF;
        END IF;

    EXCEPTION
	WHEN NO_DATA_FOUND THEN
	   x_return_status := FND_API.G_RET_STS_ERROR;
	   fnd_message.set_name ('CS', 'CS_SR_CAT_CATSET_COMB_INVALID');
	   fnd_message.set_token ('CAT_SET',nvl(l_profile,'NULL'));
	   fnd_message.set_token ('CAT_ID',p_category_id);
	   fnd_msg_pub.ADD;
	WHEN OTHERS THEN
	      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
	      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
	      fnd_msg_pub.ADD;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    END;
  END Validate_Category_Id;

-- --------------------------------------------------------------------------------
-- Validate_Category_Set_Id
/*
Modification History
Date       Name     Desc
---------- -------- ---------------------------------------------------------------
02/28/2005 smisra   Bug 4083288
                    Replaced invalid argument Error message with meaningful
                    Error message.
*/
-- --------------------------------------------------------------------------------
  PROCEDURE Validate_Category_Set_Id(
	p_api_name			 IN  VARCHAR2,
	p_parameter_name		 IN  VARCHAR2,
	p_category_id                    IN  NUMBER,
        p_category_set_id                IN  NUMBER,
        p_inventory_item_id              IN  NUMBER,
        p_inventory_org_id               IN  NUMBER,
	x_return_status			OUT  NOCOPY VARCHAR2
  ) IS

  l_dummy 	     VARCHAR2(1);
  l_api_name         CONSTANT VARCHAR2(30)    := 'Validate_Category_Set_Id';
  l_api_name_full    CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

  l_validation       varchar2(1);
BEGIN
    -- Initialize Return Status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF (p_inventory_item_id IS NULL OR
            p_inventory_item_id = FND_API.G_MISS_NUM) THEN
            l_validation := 'C';
	    SELECT 'x' INTO l_dummy
            FROM  mtl_category_set_valid_cats
	    WHERE category_id = p_category_id
	    AND	  category_set_id  = p_category_set_id;
        ELSIF (p_inventory_item_id IS NOT NULL) THEN
            l_validation := 'I';
             SELECT 'x' INTO l_dummy
             FROM   mtl_item_categories
             WHERE  inventory_item_id = p_inventory_item_id
             AND    category_id = p_category_id
             AND    category_set_id = p_category_set_id
             --AND    organization_id = CS_STD.Get_Item_Valdn_Orgzn_Id;
             AND    organization_id = p_inventory_org_id ;
	     /* Bug 2661668/2648017 - use org_id parameter for validation of org */
        END IF;

    EXCEPTION
	WHEN NO_DATA_FOUND THEN
	   x_return_status := FND_API.G_RET_STS_ERROR;
           IF (l_validation = 'I') THEN
	     fnd_message.set_name ('CS', 'CS_SR_CAT_ITEM_COMB_INVALID');
	     fnd_message.set_token ('CAT_SET',p_category_set_id);
	     fnd_message.set_token ('CAT_ID',nvl(to_char(p_category_id),'NULL'));
	     fnd_message.set_token ('ITEM_ID',nvl(to_char(p_inventory_item_id),'NULL'));
	     fnd_msg_pub.ADD;
           ELSE
	     fnd_message.set_name ('CS', 'CS_SR_CAT_CATSET_COMB_INVALID');
	     fnd_message.set_token ('CAT_SET',p_category_set_id);
	     fnd_message.set_token ('CAT_ID',nvl(to_char(p_category_id),'NULL'));
	     fnd_msg_pub.ADD;
           END IF;
	WHEN OTHERS THEN
	      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
	      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
	      fnd_msg_pub.ADD;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Category_Set_Id;

-- --------------------------------------------------------------------------------
-- Validate_External_Reference
-- --------------------------------------------------------------------------------
-- -----------------------------------------------------------------------------
-- Modification History
-- Date     Name     Desc
-- -------- -------- -----------------------------------------------------------
-- 12/16/05 smisra   4869097
--                   Modified queries for ext ref when cust prod is null and
--                   added two conditions:
--                   1. join between item instances and instance parties
--                   2. organization of item should be equal to parameter
--                      inventory org
-- -----------------------------------------------------------------------------
  PROCEDURE Validate_External_Reference(
    p_api_name			     IN  VARCHAR2,
    p_parameter_name		 IN  VARCHAR2,
    p_external_reference     IN  VARCHAR2,
    p_customer_product_id    IN  NUMBER,
    p_inventory_item_id      IN  NUMBER   := NULL,
    p_inventory_org_id       IN  NUMBER   := NULL,
    p_customer_id            IN NUMBER    := NULL,
    x_return_status			 OUT  NOCOPY VARCHAR2
  ) IS

  l_dummy 	VARCHAR2(1);
  inv_item_IB_trackable        VARCHAR2(1);
  l_api_name                   CONSTANT VARCHAR2(30)    := 'Validate_External_Reference';
  l_api_name_full              CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

CURSOR c_ib_restrict
  IS SELECT COMMS_NL_TRACKABLE_FLAG
	 FROM  mtl_system_items_b
	 WHERE inventory_item_id = p_inventory_item_id
	 AND organization_id = p_inventory_org_id;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- For bug 3746983

   IF ( p_customer_product_id IS NOT NULL ) AND
      ( p_customer_product_id <> FND_API.G_MISS_NUM ) THEN

      IF CS_ServiceRequest_PVT.g_restrict_ib = 'YES' THEN

         SELECT 'x' INTO l_dummy
         FROM   csi_item_instances a,
                mtl_system_items_b b,
                csi_i_parties cip
         WHERE  a.instance_id = p_customer_product_id
         AND a.external_reference = p_external_reference
         AND cip.party_id = p_customer_id
         AND a.instance_id = cip.instance_id
         AND cip.party_source_table  = 'HZ_PARTIES'
         AND    b.serv_req_enabled_code = 'E'
         AND a.location_type_code IN ('HZ_PARTY_SITES','HZ_LOCATIONS')
         AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(a.active_start_date,SYSDATE))
         AND TRUNC(NVL(a.active_end_date, SYSDATE))
         AND b.inventory_item_id = a.inventory_item_id
         AND b.organization_id = p_inventory_org_id
         AND rownum<2;
      ELSE

         SELECT 'x' INTO l_dummy
         FROM   csi_item_instances a,
                mtl_system_items_b b,
                csi_i_parties cip
         WHERE  a.instance_id = p_customer_product_id
         AND a.external_reference = p_external_reference
         AND cip.party_id = p_customer_id
         AND a.instance_id = cip.instance_id
         AND cip.party_source_table  = 'HZ_PARTIES'
         AND    b.serv_req_enabled_code = 'E'
         AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(a.active_start_date,SYSDATE))
         AND TRUNC(NVL(a.active_end_date, SYSDATE))
         AND b.inventory_item_id = a.inventory_item_id
         AND b.organization_id = p_inventory_org_id
         AND rownum < 2;
      END IF;
    ELSE

	   OPEN  c_ib_restrict;
	   FETCH c_ib_restrict INTO inv_item_IB_trackable;
	   CLOSE c_ib_restrict;

     IF inv_item_IB_trackable = 'Y' THEN

      IF CS_ServiceRequest_PVT.g_restrict_ib = 'YES' THEN

	     SELECT 'X' INTO l_dummy
             FROM csi_item_instances a,
             mtl_system_items_b b,
             csi_i_parties cip
	     WHERE b.inventory_item_id = p_inventory_item_id
             AND b.organization_id = p_inventory_org_id
	     AND b.inventory_item_id = a.inventory_item_id
	     AND cip.party_id = p_customer_id
             AND a.instance_id = cip.instance_id
	     AND a.external_reference = p_external_reference
             AND a.location_type_code IN ('HZ_PARTY_SITES','HZ_LOCATIONS')
             AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(a.active_start_date,SYSDATE))
             AND TRUNC(NVL(a.active_end_date, SYSDATE))
	     AND rownum < 2;

      ELSE

	     SELECT 'X' INTO l_dummy
	     FROM csi_item_instances a,
             mtl_system_items_b b,
	     csi_i_parties cip
	     WHERE b.inventory_item_id = p_inventory_item_id
             AND b.organization_id = p_inventory_org_id
	     AND b.inventory_item_id = a.inventory_item_id
	     AND cip.party_id = p_customer_id
             AND a.instance_id = cip.instance_id
	     AND a.external_reference = p_external_reference
             AND TRUNC(SYSDATE) BETWEEN TRUNC(NVL(a.active_start_date,SYSDATE))
             AND TRUNC(NVL(a.active_end_date, SYSDATE))
	     AND rownum < 2;

	  END IF;
     END IF;

   END IF;

    EXCEPTION
	WHEN NO_DATA_FOUND THEN
	   x_return_status := FND_API.G_RET_STS_ERROR;
           Add_Invalid_Argument_Msg( p_token_an    => l_api_name_full,
  		              	     p_token_v     => p_external_reference,
			      	     p_token_p     => p_parameter_name ,
                                     p_table_name  => G_TABLE_NAME,
                                     p_column_name => 'EXTERNAL_REFERENCE');
	WHEN OTHERS THEN
	      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
	      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
	      fnd_msg_pub.ADD;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Validate_External_Reference;

-- --------------------------------------------------------------------------------
-- Validate_System_Id
-- --------------------------------------------------------------------------------

  PROCEDURE Validate_System_Id(
	p_api_name			 IN  VARCHAR2,
	p_parameter_name		 IN  VARCHAR2,
	p_system_id                      IN  NUMBER,
	x_return_status			OUT  NOCOPY VARCHAR2
  ) IS

  l_dummy 	VARCHAR2(1);
  l_api_name                   CONSTANT VARCHAR2(30)    := 'Validate_System_Id';
  l_api_name_full              CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

BEGIN
    -- Initialize Return Status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT 'x' INTO l_dummy
    FROM  csi_systems_vl
    WHERE system_id = p_system_id;

    EXCEPTION
	WHEN NO_DATA_FOUND THEN
	   x_return_status := FND_API.G_RET_STS_ERROR;
           Add_Invalid_Argument_Msg( p_token_an    => l_api_name_full,
  		              	     p_token_v     => TO_CHAR(p_system_id),
			      	     p_token_p     => p_parameter_name,
                                     p_table_name  => G_TABLE_NAME,
                                     p_column_name => 'SYSTEM_ID' );
	WHEN OTHERS THEN
	      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
	      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
	      fnd_msg_pub.ADD;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END Validate_System_Id;

--------------------------------------------------------------------
/*
** Validate_Exp_Resolution_Date
** 1. The expected resolution date is validated against the service request
**    date. Therefore, this procedure takes in the service request date as a
**    parameter.
** 2. Verify that the expected resolution date is later than the service
**    request date.
*/
PROCEDURE Validate_Exp_Resolution_Date
( p_api_name             IN   VARCHAR2,
  p_parameter_name       IN   VARCHAR2,
  p_exp_resolution_date  IN   DATE,
  p_request_date         IN   DATE,
  x_return_status        OUT  NOCOPY VARCHAR2
)
IS
  l_api_name                   CONSTANT VARCHAR2(30)    := 'Validate_Exp_Resolution_Date';
  l_api_name_full              CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

BEGIN
  IF p_exp_resolution_date >= p_request_date THEN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  ELSE
    x_return_status := FND_API.G_RET_STS_ERROR;
    Add_Invalid_Argument_Msg( p_token_an    => l_api_name_full,
	              	      p_token_v     => TO_CHAR(p_exp_resolution_date),
			      p_token_p     => p_parameter_name,
                              p_table_name  => G_TABLE_NAME ,
                              p_column_name => 'EXPECTED_RESOLUTION_DATE' );
  END IF;

 EXCEPTION
	WHEN OTHERS THEN
	      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
	      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
	      fnd_msg_pub.ADD;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Validate_Exp_Resolution_Date;


-- --------------------------------------------------------------------------------
-- Validate_Bill_To_Ship_To_Party
-- Same procedure is used to validate Bill_to and Ship_To Parties
-- 1. Party must be Active of type Person or Organization
-- 2. Must have a valid relationship with the SR Customer.
-- 3. Added one more out parameter as x_customer_type to get the bill_to_party
--    customer type.
-- 4. Added one more in parameter as p_customer_type, to get the header
--    customer_type.
-- --------------------------------------------------------------------------------

PROCEDURE Validate_Bill_To_Ship_To_Party (
	p_api_name			 IN  VARCHAR2,
	p_parameter_name		 IN  VARCHAR2,
	p_bill_to_party_id		 IN  NUMBER,
	p_customer_id			 IN  NUMBER,
        x_customer_type                  IN OUT NOCOPY VARCHAR2,
	x_return_status			 OUT NOCOPY VARCHAR2
  )
AS
  l_api_name        CONSTANT VARCHAR2(30) := 'Validate_Bill_To_Ship_ToParty';
  l_api_name_full   CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_api_name;

  CURSOR Bill_To_Party  IS
    SELECT p.party_type
    FROM Hz_parties p ,
	 Hz_Relationships r
    WHERE p.party_id = p_bill_to_party_id
    AND   p.status = 'A'
    AND   p.party_type IN ('PERSON','ORGANIZATION')
    AND   r.object_id =  p_customer_id
    AND   r.subject_id = p.party_id
    AND   r.status = 'A'
    -- Added to remove TCA violation -- relationship should be active -- anmukher -- 08/14/03
    AND   TRUNC(SYSDATE) BETWEEN TRUNC(NVL(r.START_DATE, SYSDATE)) AND TRUNC(NVL(r.END_DATE, SYSDATE));

    l_dummy VARCHAR2(5);
    l_customer_type VARCHAR2(30);
BEGIN
  -- Initialize return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /* Changes made for 1159, added the condition that if the customer_id
     is same as the bill_to_party_id then we should just return success
     else we should check if its a valid relationship*/

  IF  (p_customer_id=p_bill_to_party_id) THEN
     x_return_status := FND_API.G_RET_STS_SUCCESS;
  ELSE
     OPEN bill_to_party;
     FETCH bill_to_party INTO l_customer_type;
     x_customer_type:= l_customer_type;
     IF (bill_to_party%NOTFOUND) THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
           CLOSE bill_to_party;

           RAISE NO_DATA_FOUND;
     END IF;
     CLOSE bill_to_party ;
  END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
               x_return_status := FND_API.G_RET_STS_ERROR;
               Add_Invalid_Argument_Msg
                             ( p_token_an    =>  l_api_name_full,
                               p_token_v     =>  TO_CHAR(p_bill_to_party_id),
                               p_token_p     =>  p_parameter_name,
                               p_table_name  =>  G_TABLE_NAME,
                               p_column_name =>  'BILL_TO_CUSTOMER_ID');
   WHEN OTHERS THEN
	fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
	fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
	fnd_msg_pub.ADD;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Validate_Bill_To_Ship_To_Party;

-- --------------------------------------------------------------------------------
-- Validate_Bill_To_Ship_To_Site (New Procedure for 11.5.9)
-- Same procedure is used to validate Bill_to and Ship_To Sites
-- 1. Site must be an active site attached to party
-- 2. Site USe must be Valid and Must be BILL_TO or SHIP_TO as required
-- 3. p_site_use_type will be BILL_TO or SHIP_TO
-- --------------------------------------------------------------------------------

PROCEDURE Validate_Bill_To_Ship_To_Site (
	p_api_name			 IN  VARCHAR2,
	p_parameter_name		 IN  VARCHAR2,
	p_bill_to_site_id		 IN  NUMBER,
	p_bill_to_party_id		 IN  NUMBER,
	p_site_use_type			 IN  VARCHAR2,
    x_site_use_id            OUT NOCOPY NUMBER,
	x_return_status			 OUT NOCOPY VARCHAR2
  )
AS
  l_api_name        CONSTANT VARCHAR2(30) := 'Validate_Bill_To_Ship_To_Site';
  l_api_name_full   CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_api_name;

  CURSOR Bill_To_Site  IS
    SELECT su.party_site_use_id
    FROM Hz_Party_Sites  s,
	 Hz_Party_Site_Uses su
    WHERE s.party_site_id = su.party_site_id
    AND   s.party_site_id = p_bill_to_site_id
    AND   s.party_id 	  = p_bill_to_party_id
    AND   s.status = 'A'
    AND   su.status = 'A'
    -- Commented out to remove TCA Violation -- Party site use dates not to be checked -- anmukher -- 08/14/03
    -- AND   TRUNC(SYSDATE) BETWEEN TRUNC(NVL(su.begin_date,SYSDATE))
			-- AND TRUNC(NVL(su.end_date,SYSDATE))
    AND   su.site_use_type = p_site_use_type;

    l_dummy VARCHAR2(5);
BEGIN
  -- Initialize return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN bill_to_site;
  FETCH bill_to_site INTO x_site_use_id;
  IF (bill_to_site%NOTFOUND) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    CLOSE bill_to_site;

    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE bill_to_site ;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
        CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg
                      ( p_token_an    =>  l_api_name_full,
                        p_token_v     =>  TO_CHAR(p_bill_to_site_id),
                        p_token_p     =>  p_parameter_name,
                        p_table_name  =>  G_TABLE_NAME ,
                        p_column_name =>  'BILL_TO_SITE_ID' );
   WHEN OTHERS THEN
	fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
	fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
	fnd_msg_pub.ADD;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Validate_Bill_To_Ship_To_Site ;


PROCEDURE Validate_Install_Site
( p_parameter_name       IN   VARCHAR2,
  p_install_site_id  	 IN   NUMBER,
  p_customer_id  	 IN   NUMBER,
  x_return_status        OUT  NOCOPY VARCHAR2
)
IS
  l_api_name         CONSTANT VARCHAR2(30)    := 'Validate_Install_Site';
  l_api_name_full    CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

  l_install_customer_id NUMBER;

  BEGIN
    -- Initialize Return Status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    BEGIN

	-- Fix to bug # 2529361.included keyword distinct in select clause.
	-- # 2615775 - removed reference to hz_party_site_uses..

        SELECT DISTINCT s.party_id  INTO l_install_customer_id
        FROM   Hz_Party_Sites s
        WHERE s.party_site_id = p_install_site_id
        AND   s.status = 'A'
		-- Belongs to SR Customer
        AND ( s.party_id = p_customer_id
		-- or one of its relationships
              OR s.party_id IN (
                 SELECT r.party_id
                 FROM   Hz_Relationships r
                 WHERE r.object_id     = p_customer_id
                 AND   r.status = 'A'
                 -- Added to remove TCA violation -- Relationship should be active -- anmukher -- 08/14/03
                 AND   TRUNC(SYSDATE) BETWEEN TRUNC(NVL(r.START_DATE, SYSDATE)) AND TRUNC(NVL(r.END_DATE, SYSDATE)) )
		-- or one of its Related parties
              OR s.party_id IN (
                 SELECT sub.party_id
                 FROM   Hz_Parties  p,
                        Hz_Parties sub,
                        Hz_Parties obj,
                        Hz_Relationships r
                 WHERE obj.party_id  = p_customer_id
                 AND   sub.status = 'A'
                 AND   obj.status = 'A'
                 AND   r.status   = 'A'
                 AND   p.status   = 'A'
                 AND   TRUNC(SYSDATE) BETWEEN TRUNC(NVL(r.START_DATE, SYSDATE)) AND TRUNC(NVL(r.END_DATE, SYSDATE))
                 AND   sub.party_type IN ('PERSON','ORGANIZATION')
                 AND   p.party_id = r.party_id
                 AND   r.object_id = obj.party_id
                 AND   r.subject_id = sub.party_id ));

    EXCEPTION
	WHEN NO_DATA_FOUND THEN
	   x_return_status := FND_API.G_RET_STS_ERROR;
           Add_Invalid_Argument_Msg( p_token_an    => l_api_name_full,
  		              	     p_token_v     => TO_CHAR(p_install_site_id),
  		      	             p_token_p     => p_parameter_name,
                                     p_table_name  => G_TABLE_NAME,
                                     p_column_name => 'INSTALL_SITE_ID' );

		WHEN OTHERS THEN
	      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
	      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
	      fnd_msg_pub.ADD;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    END;

END Validate_Install_Site;

/*
** Validate_Resolution_Code
** 1. Verify that the resolution code is an active resolution code.
*/
PROCEDURE Validate_Resolution_Code (
  p_api_name             IN   VARCHAR2,
  p_parameter_name       IN   VARCHAR2,
  p_resolution_code      IN   VARCHAR2,
  x_return_status        OUT  NOCOPY VARCHAR2)
IS
  l_dummy  VARCHAR2(1);
  l_api_name            CONSTANT VARCHAR2(30)    := 'Validate_Resolution_Code';
  l_api_name_full       CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

BEGIN
  -- Initialize the return status.
  x_return_status := FND_API.G_RET_STS_SUCCESS;




EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      Add_Invalid_Argument_Msg(
	 p_token_an    => l_api_name_full,
         p_token_v     => p_resolution_code,
         p_token_p     => p_parameter_name,
         p_table_name  => G_TABLE_NAME,
         p_column_name => 'RESOLUTION_CODE' );
   WHEN OTHERS THEN
      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
      fnd_msg_pub.ADD;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Validate_Resolution_Code;

-- --------------------------------------------------------------------------------
-- Validate_Act_Resolution_Date
-- 1. The actual resolution date must be validated against the service request date,
--	therefore this procedure takes in the service request date as a parameter.
-- 2. Verify that the actual resolution date is later than the service request date
-- --------------------------------------------------------------------------------
  PROCEDURE Validate_Act_Resolution_Date (
	p_api_name			 IN  VARCHAR2,
	p_parameter_name		 IN  VARCHAR2,
	p_act_resolution_date		 IN  DATE,
	p_request_date			 IN  DATE,
	x_return_status			OUT  NOCOPY VARCHAR2
  ) IS
  l_api_name                   CONSTANT VARCHAR2(30)    := 'Validate_Act_Resolution_Date';
  l_api_name_full              CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

  BEGIN

    IF p_act_resolution_date >= p_request_date THEN
	x_return_status := FND_API.G_RET_STS_SUCCESS;
    ELSE
	x_return_status := FND_API.G_RET_STS_ERROR;
        Add_Invalid_Argument_Msg( p_token_an    => l_api_name_full,
  		              	  p_token_v     => TO_CHAR(p_act_resolution_date),
			      	  p_token_p     => p_parameter_name,
                                  p_table_name  => G_TABLE_NAME,
                                  p_column_name => 'ACTUAL_RESOLUTION_DATE' );
    END IF;
  EXCEPTION
	WHEN OTHERS THEN
	      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
	      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
	      fnd_msg_pub.ADD;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Act_Resolution_Date;

----------------------------
-- 3224828 contracts : x_contract_id IN OUT parameter
PROCEDURE Validate_Contract_Service_Id
( p_api_name             IN   VARCHAR2,
  p_parameter_name       IN   VARCHAR2,
  p_contract_service_id  IN   NUMBER,
  x_contract_id          IN OUT  NOCOPY NUMBER,
  x_contract_number      OUT  NOCOPY VARCHAR2,
  x_return_status        OUT  NOCOPY VARCHAR2
)IS

  l_test             VARCHAR2(150);
  l_api_name         CONSTANT VARCHAR2(30)    := 'Validate_Contract_Service_Id';
  l_api_name_full    CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;
  l_contract_id          NUMBER;

BEGIN
	-- Initialize the return status.
	x_return_status := FND_API.G_RET_STS_SUCCESS;

        select chr_id
	into l_contract_id
	from okc_k_lines_b
	where id = p_contract_service_id;



	SELECT contract_number INTO x_contract_number
          FROM okc_k_headers_all_b
         WHERE id = l_contract_id;

	if (l_contract_id <> x_contract_id AND x_contract_id IS NOT NULL AND x_contract_id <> FND_API.G_MISS_NUM) then
	    x_contract_id := l_contract_id;
            Add_Param_Ignored_Msg( p_token_an   => l_api_name_full,
			           p_token_ip   => 'p_contract_id',
                                   p_table_name => G_TABLE_NAME,
                                   p_column_name => 'CONTRACT_ID' );

	end if;

         x_contract_id := l_contract_id;

  /*      SELECT line_number, chr_id
	INTO l_test, x_contract_id
	FROM okc_k_lines_b
	WHERE id = p_contract_service_id ;   */

        --SELECT chr_id INTO x_contract_id
        --FROM okc_k_lines_b
        --WHERE id = p_contract_service_id;

EXCEPTION
 WHEN NO_DATA_FOUND THEN
    	 x_return_status := FND_API.G_RET_STS_ERROR;
    	 Add_Invalid_Argument_Msg(p_token_an    => l_api_name_full,
	              	      	  p_token_v     => p_contract_service_id,
			      	  p_token_p     => p_parameter_name ,
                                  p_table_name  => G_TABLE_NAME,
                                  p_column_name => 'CONTRACT_SERVICE_ID');

   WHEN OTHERS THEN
	      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
	      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
	      fnd_msg_pub.ADD;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Validate_Contract_Service_Id;
---------------------------------------------------------------------------

PROCEDURE Validate_Contract_Id
( p_api_name             IN   VARCHAR2,
  p_parameter_name       IN   VARCHAR2,
  p_contract_id          IN   NUMBER,
  x_contract_number      OUT  NOCOPY VARCHAR2,
  x_return_status        OUT  NOCOPY VARCHAR2
)IS

  l_api_name                   CONSTANT VARCHAR2(30)    := 'Validate_Contract_Id';
  l_api_name_full              CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

BEGIN

	 -- Initialize the return status.
	 x_return_status := FND_API.G_RET_STS_SUCCESS;

         SELECT contract_number
	 INTO x_contract_number
	 FROM okc_k_headers_all_b
	 WHERE id = p_contract_id ;

EXCEPTION
	 WHEN NO_DATA_FOUND THEN
		 x_return_status := FND_API.G_RET_STS_ERROR;
		 Add_Invalid_Argument_Msg( p_token_an    => l_api_name_full,
	              	      		   p_token_v     => p_contract_id,
			      		   p_token_p     => p_parameter_name,
                                           p_table_name  => G_TABLE_NAME,
                                           p_column_name => 'CONTRACT_ID' );

	WHEN OTHERS THEN
	      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
	      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
	      fnd_msg_pub.ADD;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


END Validate_Contract_Id;

---------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
-- Modification History
-- Date     Name     Desc
-- -------- -------- -----------------------------------------------------------
-- 12/30/05 smisra   Bug 4869065
--                   Removed the logic because support_site_id will now be
--                   derived based on resource_id
--                   ****** Do not Use This Procedure *****
-- -----------------------------------------------------------------------------
PROCEDURE Validate_Support_Site_Id
( p_api_name             IN  VARCHAR2,
  p_parameter_name       IN  VARCHAR2,
  p_support_site_id      IN  NUMBER,
  p_owner_id             IN  NUMBER,
  p_resource_type        IN  VARCHAR2,
  p_org_id               IN  NUMBER,
  x_return_status        OUT NOCOPY VARCHAR2
)IS

  l_test           VARCHAR2(1);
  l_api_name       CONSTANT VARCHAR2(30)    := 'Validate_Support_Site_Id';
  l_api_name_full  CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;
BEGIN

	  -- Initialize the return status.
	  x_return_status := FND_API.G_RET_STS_ERROR;
/****
Bug 4869065
The sql is very expensive. Support site is a denormalized col.
so validation of resource id will determine the support site too. no need to
cross validate support site and resource
	  x_return_status := FND_API.G_RET_STS_SUCCESS;

     	 SELECT 'x'
	 INTO l_test
	 FROM cs_sr_owners_v
	 WHERE resource_type  =  UPPER(p_resource_type)
         AND resource_id = p_owner_id
         AND  support_site_id = p_support_site_id  ;
****/
EXCEPTION
   WHEN NO_DATA_FOUND THEN
    	 x_return_status := FND_API.G_RET_STS_ERROR;
    	 Add_Invalid_Argument_Msg(p_token_an    => l_api_name_full,
	              	          p_token_v     => p_support_site_id,
			      	  p_token_p     => p_parameter_name,
                                    p_table_name  => null,
                                  p_column_name => 'P_SUPPORT_SITE_ID' );

   WHEN OTHERS THEN
	      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
	      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
	      fnd_msg_pub.ADD;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Validate_Support_Site_Id;
---------------------------------------------------------

PROCEDURE Validate_Group_Type
( p_api_name             IN   VARCHAR2,
  p_parameter_name       IN   VARCHAR2,
  p_group_type           IN   VARCHAR2,
  -- p_resource_type        IN   VARCHAR2,
  x_return_status        OUT  NOCOPY VARCHAR2
)IS

  l_api_name          CONSTANT VARCHAR2(30)    := 'Validate_Group_Type';
  l_api_name_full     CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

BEGIN

  -- Initialize the return status.
  x_return_status := FND_API.G_RET_STS_SUCCESS;

/* For 1159, we changed the logic, as RS_TEAM is not supported anymore,
   if the resource_type is not RS_GROUP, we raise an error oherwise
   just return success by shijain*/

     IF (p_group_type = 'RS_GROUP') THEN
         x_return_status := FND_API.G_RET_STS_SUCCESS;
     ELSE
        x_return_status := FND_API.G_RET_STS_ERROR;
         Add_Invalid_Argument_Msg( p_token_an    =>  l_api_name_full,
                                   p_token_v     =>  p_group_type,
                                   p_token_p     =>  p_parameter_name ,
                                   p_table_name  => G_TABLE_NAME ,
                                   p_column_name => 'GROUP_TYPE' );
     END IF;
EXCEPTION
         WHEN NO_DATA_FOUND THEN
		 x_return_status := FND_API.G_RET_STS_ERROR;
		 Add_Invalid_Argument_Msg( p_token_an    =>  l_api_name_full,
                                           p_token_v     =>  p_group_type,
                                           p_token_p     =>  p_parameter_name,
                                           p_table_name  => G_TABLE_NAME ,
                                           p_column_name => 'GROUP_TYPE' );

	WHEN OTHERS THEN
	      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
	      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
	      fnd_msg_pub.ADD;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;


END Validate_Group_Type;

----------------------------------------
PROCEDURE Validate_Group_Id
( p_api_name             IN   VARCHAR2,
  p_parameter_name       IN   VARCHAR2,
  p_group_type           IN   VARCHAR2,
  p_owner_group_id       IN   NUMBER,
  x_group_name           OUT  NOCOPY VARCHAR2,
  x_return_status        OUT  NOCOPY VARCHAR2
)IS

  l_test            VARCHAR2(150);
  l_api_name        CONSTANT VARCHAR2(30)    := 'Validate_Group_Id';
  l_api_name_full   CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

BEGIN

  -- Initialize the return status.
  x_return_status := FND_API.G_RET_STS_SUCCESS;

/* This change is for 1159, only RS_GROUP group type is checked, if its not RS_GROUP then return an error*/

IF ( p_group_type = 'RS_GROUP' ) THEN
  SELECT grp.group_name INTO x_group_name
  FROM jtf_rs_groups_vl grp,
  jtf_rs_group_usages usg
  WHERE grp.group_id = p_owner_group_id
  AND   grp.group_id = usg.group_id
  AND   usg.usage    = 'SUPPORT'
  AND   SYSDATE BETWEEN NVL(start_date_active, SYSDATE)
  AND   NVL( end_date_active, SYSDATE ) ;
ELSE
  x_return_status := FND_API.G_RET_STS_ERROR;
  -- 3303106
      --   Add_Invalid_Argument_Msg
          Add_Null_Parameter_Msg ( p_token_an    =>  l_api_name_full,
                                   p_token_np    =>  'p_group_type',
                                   p_table_name  =>  G_TABLE_NAME,
                                   p_column_name =>  'GROUP_TYPE');
END IF;


EXCEPTION
         WHEN NO_DATA_FOUND THEN
		 x_return_status := FND_API.G_RET_STS_ERROR;
		 Add_Invalid_Argument_Msg( p_token_an    =>  l_api_name_full,
                                           p_token_v     =>  p_owner_group_id,
                                           p_token_p     =>  p_parameter_name,
                                           p_table_name  => G_TABLE_NAME,
                                           p_column_name => 'OWNER_GROUP_ID');

	WHEN OTHERS THEN
	      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
	      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
	      fnd_msg_pub.ADD;
	      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Validate_Group_Id;

----------------------------------------
-- DJ API Cleanup
-- Existing proc. modified to query from CS secure view on JTF resource
-- -----------------------------------------------------------------------------
-- Modification History
-- Date     Name     Desc
-- -------- -------- -----------------------------------------------------------
-- 07/20/05 smisra   Bug 3875584
--                   Added a new parameter p_mode. If value of this parameter
--                   is CREATE then this procedure gives warning for invalid
--                   owner id. for all other values of p_mode, this procedure
--                   give invalid parameter error for invalid owner id
-- 12/30/05 smisra   Bug 4773215, 4869065
--                   Added an out parameter x_resource_type. It is derived based
--                   on resource id. it is set to constant string 'RS_' and
--                   category associated with the resource. This value is
--                   validated using validate_resource_type procedure.
--                   Added an out parameter x_support_site_id. It is derived
--                   based on resource_id
-- -----------------------------------------------------------------------------
PROCEDURE Validate_Owner
( p_api_name             IN   VARCHAR2,
  p_parameter_name       IN   VARCHAR2,
  p_owner_id             IN   NUMBER,
  p_group_type           IN   VARCHAR2,
  p_owner_group_id       IN   NUMBER,
  p_org_id               IN   NUMBER,
  p_incident_type_id     IN   NUMBER, -- new for 11.5.10 for Security rule
  p_mode                 IN   VARCHAR2 DEFAULT NULL,
  x_owner_name           OUT  NOCOPY VARCHAR2,
  x_owner_id             OUT  NOCOPY NUMBER,
  x_resource_type        OUT NOCOPY VARCHAR2,
  x_support_site_id      OUT NOCOPY NUMBER,
  x_return_status        OUT  NOCOPY VARCHAR2 )
IS

  l_test                VARCHAR2(1);
  l_api_name            CONSTANT VARCHAR2(30):= 'Validate_Owner';
  l_api_name_full       CONSTANT VARCHAR2(61):= G_PKG_NAME||'.'||l_api_name;

  CURSOR get_valid_owner IS
  SELECT res.resource_name, res.resource_id, 'RS_' || res.category,
         DECODE(res.category, 'EMPLOYEE', res.support_site_id, NULL)
  FROM jtf_rs_group_members          grp,
       cs_jtf_rs_resource_extns_sec  res
       -- jtf_rs_resource_extns_tl res; Replaced with CS Secure view
  WHERE grp.resource_id = p_owner_id
  AND   grp.group_id    = p_owner_group_id
  AND   grp.resource_id = res.resource_id;

BEGIN
   -- Initialize the return status.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- set the context of the SR type before querying the CS Secure view
   -- for JTF resources
   cs_sr_security_context.set_sr_security_context (
      p_context_attribute         => 'SRTYPE_ID',
      p_context_attribute_value   =>  p_incident_type_id );

   IF (     p_owner_group_id IS NOT NULL
        AND p_owner_group_id <> FND_API.G_MISS_NUM )
   THEN
      OPEN  get_valid_owner;
      FETCH get_valid_owner INTO x_owner_name, x_owner_id, x_resource_type, x_support_site_id;
      IF ( get_valid_owner%NOTFOUND ) THEN
         CLOSE get_valid_owner;
         RAISE NO_DATA_FOUND ;
      END IF;
      CLOSE get_valid_owner;
   ELSE
      SELECT resource_name, resource_id , 'RS_' || res.category,
             DECODE(res.category, 'EMPLOYEE', res.support_site_id, NULL)
      INTO   x_owner_name, x_owner_id, x_resource_type, x_support_site_id
      FROM   cs_jtf_rs_resource_extns_sec res
      -- FROM   jtf_rs_resource_extns_vl res; Replaced with CS secure view
      WHERE  res.resource_id = p_owner_id
      AND    trunc(sysdate) between trunc(nvl(start_date_active, sysdate))
			    and     trunc(nvl(end_date_active,   sysdate));
   END IF;
   Validate_Resource_Type
   ( p_api_name       => l_api_name_full
   , p_parameter_name => 'p_resource_type'
   , p_resource_type  => x_resource_type
   , x_return_status  => x_return_status
   );

EXCEPTION
  WHEN NO_DATA_FOUND THEN
      IF p_mode = 'CREATE'
      THEN
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        -- 3277647 changed from error to warning Add_Invalid_Argument_Msg

        Add_Param_Ignored_MSg ( p_token_an    =>  l_api_name_full,
                                p_token_ip     =>  p_parameter_name,
                                p_table_name  =>  null,
                                p_column_name => 'P_OWNER_ID');
      ELSE
        x_return_status := FND_API.G_RET_STS_ERROR;
        Add_Invalid_Argument_Msg
        ( p_token_an    => l_api_name_full
        , p_token_v     => TO_CHAR(p_owner_id)
        , p_token_p     => p_parameter_name
        , p_table_name  => G_TABLE_NAME
        , p_column_name => 'incident_owner_id'
        );
      END IF;
  WHEN OTHERS THEN
       fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
       fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
       fnd_msg_pub.ADD;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Validate_Owner;

------------------------------------------------------

PROCEDURE Validate_Resource_Type
( p_api_name             IN   VARCHAR2,
  p_parameter_name       IN   VARCHAR2,
  p_resource_type        IN   VARCHAR2,
  x_return_status        OUT  NOCOPY VARCHAR2
)IS

  l_test            VARCHAR2(150);
  l_api_name        CONSTANT VARCHAR2(30)    := 'Validate_Resource_Type';
  l_api_name_full   CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

BEGIN

    -- Initialize the return status.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (UPPER(p_resource_type) IN ('RS_EMPLOYEE','RS_OTHER','RS_SUPPLIER_CONTACT', 'RS_PARTNER','RS_PARTY','RS_TBH'))
    THEN
         x_return_status := FND_API.G_RET_STS_SUCCESS;
    ELSE
         RAISE NO_DATA_FOUND;
    END IF;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         Add_Invalid_Argument_Msg( p_token_an    =>  p_api_name,
                                   p_token_v     =>  p_resource_type,
                                   p_token_p     =>  p_parameter_name,
                                   p_table_name  => G_TABLE_NAME,
                                   p_column_name => 'RESOURCE_TYPE');

     WHEN OTHERS THEN
         fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
       	 fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
       	 fnd_msg_pub.ADD;
       	 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Validate_Resource_Type;

----------------------------------------------------
-- Validate Platform Id
-- 11 jul 2006 Modified version 120.26 to fix bug # 5361090.
--                      Added x_serial_controlled_flag as OUT parameter to
--                      Validate_Platform_id procedure.

PROCEDURE Validate_Platform_Id
( p_api_name                 IN   VARCHAR2,
  p_parameter_name           IN   VARCHAR2,
  p_platform_id              IN   NUMBER,
  p_organization_id          IN   NUMBER,
  x_serial_controlled_flag  OUT NOCOPY VARCHAR2,
  x_return_status           OUT  NOCOPY VARCHAR2
)IS

  l_test                  VARCHAR2(1);
  l_api_name              CONSTANT VARCHAR2(30)    := 'Validate_Platform_Id';
  l_api_name_full         CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;
  l_control_code          NUMBER;
  no_platform_excp        EXCEPTION;

BEGIN
  -- Initialize the return status.
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SELECT NVL(revision_qty_control_code,0)
    INTO l_control_code
    FROM mtl_system_items_vl item,
         mtl_item_categories ic
   WHERE item.organization_id   = p_organization_id
     AND item.inventory_item_id = p_platform_id
     AND item.organization_id   = ic.organization_id
     AND item.inventory_item_id = ic.inventory_item_id
     AND ic.category_set_id     = fnd_profile.value('CS_SR_PLATFORM_CATEGORY_SET');

  IF l_control_code <> 2 THEN
     x_serial_controlled_flag := 'N';
  ELSIF l_control_code = 2 THEN
     x_serial_controlled_flag := 'Y';
  END IF ;

EXCEPTION
     WHEN no_data_found THEN
          x_serial_controlled_flag := 'N';
          x_return_status := FND_API.G_RET_STS_ERROR;

          Add_Invalid_Argument_Msg(p_token_an    =>  p_api_name,
                                   p_token_v     =>  p_platform_id,
                                   p_token_p     =>  p_parameter_name,
                                   p_table_name  =>  G_TABLE_NAME ,
                                   p_column_name => 'PLATFORM_ID' );

     WHEN OTHERS THEN
         fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
       	 fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
       	 fnd_msg_pub.ADD;
       	 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Validate_Platform_Id;

-- Validate Component Id

PROCEDURE Validate_CP_Comp_Id
( p_api_name             IN   VARCHAR2,
  p_parameter_name       IN   VARCHAR2,
  p_cp_component_id      IN   NUMBER,
  p_customer_product_id  IN   NUMBER,
  p_org_id               IN   NUMBER,
  x_return_status        OUT  NOCOPY  VARCHAR2
)IS

  l_test                  VARCHAR2(1);
  l_api_name              CONSTANT VARCHAR2(30)    := 'Validate_CP_Comp_Id';
  l_api_name_full         CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

BEGIN
	-- Initialize the return status.
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	SELECT 'x'
	INTO l_test
	FROM cs_sr_new_acc_cp_rg_v
	WHERE instance_id = p_cp_component_id
	AND object_id = p_customer_product_id
	AND rownum < 2;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         Add_Invalid_Argument_Msg( p_token_an    =>  p_api_name,
                                   p_token_v     =>  p_cp_component_id,
                                   p_token_p     =>  p_parameter_name,
                                   p_table_name  => G_TABLE_NAME ,
                                   p_column_name => 'CP_COMPONENT_ID');

    WHEN OTHERS THEN
         fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
       	 fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
       	 fnd_msg_pub.ADD;
       	 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Validate_CP_Comp_Id;

-- Validate Product Revision
PROCEDURE Validate_Product_Revision
( p_api_name             IN   VARCHAR2,
  p_parameter_name       IN   VARCHAR2,
  p_product_revision     IN   VARCHAR2,
  p_customer_product_id  IN   NUMBER,
  p_inventory_org_id     IN   NUMBER,
  p_inventory_item_id    IN   NUMBER,
  x_return_status        OUT  NOCOPY VARCHAR2
)IS

  l_test               VARCHAR2(1);
  l_rev_control_code   NUMBER;
  l_api_name           CONSTANT VARCHAR2(30)    := 'Validate_Product_Revision';
  l_api_name_full      CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

BEGIN
  -- Initialize the return status.
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  BEGIN
    SELECT revision_qty_control_code
    INTO l_rev_control_code
    FROM mtl_system_items_b
    WHERE inventory_item_id = p_inventory_item_id
    AND   organization_id = p_inventory_org_id;

    IF l_rev_control_code = 2 THEN
    BEGIN
        SELECT 'x'
	INTO l_test
	FROM csi_item_instances
	WHERE instance_id = p_customer_product_id
        AND   inventory_revision = p_product_revision;

    EXCEPTION
         WHEN NO_DATA_FOUND THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         Add_Invalid_Argument_Msg(
          p_token_an =>  p_api_name,
          p_token_v  =>  p_product_revision,
          p_token_p  =>  p_parameter_name,
          p_table_name => null,
          p_column_name => null);

	WHEN OTHERS THEN
         fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
       	 fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
       	 fnd_msg_pub.ADD;
       	 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    END;
    END IF;
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         Add_Invalid_Argument_Msg( p_token_an    =>  p_api_name,
                                   p_token_v     =>  p_product_revision,
                                   p_token_p     =>  p_parameter_name,
                                   p_table_name  => G_TABLE_NAME ,
                                   p_column_name => 'PRODUCT_REVISION');

    WHEN OTHERS THEN
	    x_return_status := FND_API.G_RET_STS_ERROR;
	    Add_Invalid_Argument_Msg( p_token_an    =>  p_api_name,
                                      p_token_v     =>  TO_CHAR(p_inventory_item_id),
                                      p_token_p     =>  p_parameter_name,
                                      p_table_name  => G_TABLE_NAME ,
                                      p_column_name => 'PRODUCT_REVISION' );
  END;

END Validate_Product_Revision;
-- This procedure can validate version of a customer product or
-- customer porduct component or customer product subcomponent
-- validate_compnent_version and validate_subcomponent procedure have
-- same logic and we need to change validation logic as per bug 3566783
-- so we creation this procedue that can be used for component version
-- and subcomponent version.
-- smisra 5/4/04
PROCEDURE Validate_product_Version
( p_parameter_name       IN     VARCHAR2,
  p_instance_id          IN     NUMBER,
  p_inventory_org_id     IN     NUMBER,
  p_product_version      IN OUT NOCOPY VARCHAR2,
  x_return_status        OUT    NOCOPY VARCHAR2
)IS

  l_test               VARCHAR2(1);
  l_api_name           CONSTANT VARCHAR2(30)    := 'Validate_product_Version';
  l_api_name_full      CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;
  l_dummy              NUMBER;
  l_rev_control_code   NUMBER;
  l_product_version  cs_incidents_all_b.component_version % type;

  CURSOR  c_inv_item
  IS SELECT inventory_item_id, inventory_revision
     FROM   CSI_ITEM_INSTANCES
     WHERE  INSTANCE_ID  = p_instance_id;


  CURSOR c_rev_code(l_inv_item_id IN NUMBER)
  IS SELECT revision_qty_control_code
     FROM mtl_system_items_b
     WHERE inventory_item_id = l_inv_item_id
     AND   organization_id = p_inventory_org_id;

BEGIN
    -- Initialize the return status.
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF p_instance_id is null THEN
       p_product_version := null;
    ELSE

       OPEN c_inv_item;
       FETCH c_inv_item INTO l_dummy, l_product_version;
       CLOSE c_inv_item;

       OPEN c_rev_code(l_dummy);
       FETCH c_rev_code INTO l_rev_control_code;
       CLOSE c_rev_code;


       IF l_rev_control_code = 2 THEN
          IF (p_product_version = FND_API.G_MISS_CHAR) then
              p_product_version := l_product_version;
          ELSIF (nvl(p_product_version,'@#') <> nvl(l_product_version,'@#')) THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
              Add_Invalid_Argument_Msg(
                    p_token_an =>  l_api_name_full,
                    p_token_v  =>  p_product_version,
                    p_token_p  =>  p_parameter_name,
                    p_table_name => null,
                    p_column_name => null);
          END IF;
       END IF;
    END IF;

EXCEPTION
      WHEN NO_DATA_FOUND THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
           Add_Invalid_Argument_Msg( p_token_an    =>  l_api_name_full,
                                     p_token_v     =>  p_product_version,
                                     p_token_p     =>  p_parameter_name,
                                     p_table_name  => G_TABLE_NAME ,
                                     p_column_name => 'COMPONENT_VERSION' );
      WHEN OTHERS  THEN
           fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
           fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
           fnd_msg_pub.ADD;
           x_return_status := fnd_api.g_ret_sts_unexp_error;
END Validate_product_Version;
--
-- Validate Component Version
PROCEDURE Validate_Component_Version
( p_api_name             IN   VARCHAR2,
  p_parameter_name       IN   VARCHAR2,
  p_component_version    IN   VARCHAR2,
  p_cp_component_id      IN   NUMBER,
  p_customer_product_id  IN   NUMBER,
  p_inventory_org_id     IN   NUMBER,
  x_return_status        OUT  NOCOPY VARCHAR2
)IS

  l_test               VARCHAR2(1);
  l_api_name           CONSTANT VARCHAR2(30)    := 'Validate_Component_Version';
  l_api_name_full      CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;
  l_dummy              NUMBER;
  l_rev_control_code   NUMBER;

  CURSOR  c_inv_item
  IS SELECT inventory_item_id
     FROM   CSI_ITEM_INSTANCES
     WHERE  INSTANCE_ID  = p_cp_component_id;


  CURSOR c_rev_code(l_inv_item_id IN NUMBER)
  IS SELECT revision_qty_control_code
     FROM mtl_system_items_b
     WHERE inventory_item_id = l_inv_item_id
     AND   organization_id = p_inventory_org_id;

BEGIN
	-- Initialize the return status.
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- For bug 3337848 - Check for revision control

	BEGIN

	   OPEN c_inv_item;
	   FETCH c_inv_item INTO l_dummy;
	   CLOSE c_inv_item;

	   OPEN c_rev_code(l_dummy);
	   FETCH c_rev_code INTO l_rev_control_code;
	   CLOSE c_rev_code;


	   IF l_rev_control_code = 2 THEN
	   BEGIN
	        SELECT 'x'
		INTO l_test
		FROM csi_item_instances
		WHERE instance_id = p_cp_component_id
	        AND   inventory_revision = p_component_version;

	   EXCEPTION
		 WHEN NO_DATA_FOUND THEN
                         -- 3352160 modified value of p_token_an
		         x_return_status := FND_API.G_RET_STS_ERROR;
		         Add_Invalid_Argument_Msg(
			          p_token_an =>  l_api_name_full,
			          p_token_v  =>  p_component_version,
			          p_token_p  =>  p_parameter_name,
			          p_table_name => null,
			          p_column_name => null);

		WHEN OTHERS THEN
			 fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
		       	 fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
		       	 fnd_msg_pub.ADD;
		       	 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  END;
	  END IF;




EXCEPTION
	 WHEN NO_DATA_FOUND THEN
		 x_return_status := FND_API.G_RET_STS_ERROR;
		 Add_Invalid_Argument_Msg( p_token_an    =>  l_api_name_full,
                                           p_token_v     =>  p_component_version,
                                           p_token_p     =>  p_parameter_name,
                                           p_table_name  => G_TABLE_NAME ,
                                           p_column_name => 'COMPONENT_VERSION' );
      WHEN OTHERS  THEN
		 fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
		 fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
		 fnd_msg_pub.ADD;
		 x_return_status := fnd_api.g_ret_sts_unexp_error;
 END;
END Validate_Component_Version;

-- Validate Subcomponent Version
PROCEDURE Validate_Subcomponent_Version
( p_api_name             IN   VARCHAR2,
  p_parameter_name       IN   VARCHAR2,
  p_subcomponent_version IN   VARCHAR2,
  p_cp_component_id      IN   NUMBER,
  p_cp_subcomponent_id   IN   NUMBER,
  p_customer_product_id  IN   NUMBER,
  p_inventory_org_id     IN   NUMBER,
  x_return_status        OUT  NOCOPY VARCHAR2
)IS

  l_test               VARCHAR2(1);
  l_api_name           CONSTANT VARCHAR2(30)    := 'Validate_Subcomponent_Version';
  l_api_name_full      CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;
  l_dummy              NUMBER;
  l_rev_control_code   NUMBER;

  CURSOR  c_inv_item
  IS SELECT inventory_item_id
     FROM   CSI_ITEM_INSTANCES
     WHERE  INSTANCE_ID  = p_cp_subcomponent_id;


  CURSOR c_rev_code(l_inv_item_id IN NUMBER)
  IS SELECT revision_qty_control_code
     FROM mtl_system_items_b
     WHERE inventory_item_id = l_inv_item_id
     AND   organization_id = p_inventory_org_id;

BEGIN
	-- Initialize the return status.
	x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- For bug 3337848 - for revision control

	  BEGIN
	   OPEN c_inv_item;
	   FETCH c_inv_item INTO l_dummy;
	   CLOSE c_inv_item;

	   OPEN c_rev_code(l_dummy);
	   FETCH c_rev_code INTO l_rev_control_code;
	   CLOSE c_rev_code;

	  IF l_rev_control_code = 2 THEN
	  BEGIN
	        SELECT 'x'
		INTO l_test
		FROM csi_item_instances
		WHERE instance_id = p_cp_subcomponent_id
	        AND   inventory_revision = p_subcomponent_version;

	 EXCEPTION
         WHEN NO_DATA_FOUND THEN
                 -- 3352160 - modified value of p_token_an
	         x_return_status := FND_API.G_RET_STS_ERROR;
	         Add_Invalid_Argument_Msg(
		          p_token_an =>  l_api_name_full,
		          p_token_v  =>  p_subcomponent_version,
		          p_token_p  =>  p_parameter_name,
		          p_table_name => null,
		          p_column_name => null);

	 WHEN OTHERS THEN
	         fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
	       	 fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
	       	 fnd_msg_pub.ADD;
	       	 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	END;
	END IF;



EXCEPTION
	 WHEN NO_DATA_FOUND THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         Add_Invalid_Argument_Msg( p_token_an    =>  l_api_name_full,
                                   p_token_v     =>  p_subcomponent_version,
                                   p_token_p     =>  p_parameter_name ,
                                   p_table_name  => G_TABLE_NAME,
                                   p_column_name => 'SUBCOMPONENT_VERSION');
      WHEN OTHERS  THEN
         fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
         fnd_msg_pub.ADD;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
 END;
END Validate_Subcomponent_Version;
----------------------------------------------------------------------------------

-- Validate Sub Component Id
PROCEDURE Validate_CP_SubComp_Id
( p_api_name             IN   VARCHAR2,
  p_parameter_name       IN   VARCHAR2,
  p_cp_subcomponent_id   IN   NUMBER,
  p_cp_component_id      IN   NUMBER,
  p_customer_product_id  IN   NUMBER,
  p_org_id               IN   NUMBER,
  x_return_status        OUT  NOCOPY VARCHAR2
)IS

  l_test            VARCHAR2(1);
  l_api_name        CONSTANT VARCHAR2(30)    := 'Validate_CP_SubComp_Id';
  l_api_name_full   CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

BEGIN
	-- Initialize the return status.
	x_return_status := FND_API.G_RET_STS_SUCCESS;

        /* SELECT 'x'
	 INTO l_test
	 FROM cs_customer_products_all
	 WHERE customer_product_id = p_cp_subcomponent_id
         AND   config_parent_id = p_cp_component_id
         AND   config_root_id   = p_customer_product_id; */

         -- For bug 3338046 - the view has records of ser_req_enabled = 'E'
	SELECT  'x'
	INTO l_test
	FROM cs_sr_new_acc_cp_rg_v
	WHERE instance_id = p_cp_subcomponent_id
	AND object_id = p_cp_component_id
	AND rownum < 2;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         Add_Invalid_Argument_Msg( p_token_an    =>  l_api_name_full,
                                   p_token_v     =>  TO_CHAR(p_cp_subcomponent_id),
                                   p_token_p     => p_parameter_name,
                                   p_table_name  => G_TABLE_NAME ,
                                   p_column_name => 'CP_SUBCOMPONENT_ID');

      WHEN OTHERS  THEN
         fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
         fnd_msg_pub.ADD;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

END Validate_CP_SubComp_Id;


-- Validate INV ITEM REVISION
PROCEDURE Validate_Inv_Item_Rev
( p_api_name                   IN   VARCHAR2,
  p_parameter_name             IN   VARCHAR2,
  p_inv_item_revision          IN   VARCHAR2,
  p_inventory_item_id          IN   NUMBER,
  p_inventory_org_id           IN   NUMBER,
  x_return_status              OUT  NOCOPY VARCHAR2
)IS

  l_test               VARCHAR2(1);
  l_rev_control_code   NUMBER;
  l_api_name           CONSTANT VARCHAR2(30)    := 'Validate_Inv_Item_Rev';
  l_api_name_full      CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

BEGIN
  -- Initialize the return status.
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  BEGIN
    SELECT revision_qty_control_code
    INTO l_rev_control_code
    FROM mtl_system_items_b
    WHERE inventory_item_id = p_inventory_item_id
    AND   serv_req_enabled_code = 'E'
    AND   organization_id = p_inventory_org_id;

    IF l_rev_control_code = 2 THEN
      BEGIN
         SELECT 'x'
	 INTO l_test
	 FROM mtl_item_revisions
	 WHERE inventory_item_id = p_inventory_item_id
         AND   organization_id  = p_inventory_org_id
	 AND   revision         = p_inv_item_revision;

      EXCEPTION
	 WHEN NO_DATA_FOUND THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         Add_Invalid_Argument_Msg( p_token_an    =>  l_api_name_full,
                                   p_token_v     =>  p_inv_item_revision,
                                   p_token_p     =>  p_parameter_name,
                                   p_table_name  => G_TABLE_NAME ,
                                   p_column_name => 'INV_ITEM_REVISION' );
     WHEN OTHERS  THEN
         fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
         fnd_msg_pub.ADD;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

      END;
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
	    x_return_status := FND_API.G_RET_STS_ERROR;
	    Add_Invalid_Argument_Msg( p_token_an    =>  l_api_name_full,
                                      p_token_v     =>  TO_CHAR(p_inventory_item_id),
                                      p_token_p     =>  p_parameter_name,
                                      p_table_name  => G_TABLE_NAME ,
                                      p_column_name => 'INVENTORY_ITEM_ID' );

      WHEN OTHERS  THEN
         fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
         fnd_msg_pub.ADD;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

END;
END Validate_Inv_Item_Rev;
------------------------------------------------------

-- Validate INV COMP ID
PROCEDURE Validate_Inv_Comp_Id
( p_api_name                   IN   VARCHAR2,
  p_parameter_name             IN   VARCHAR2,
  p_inventory_org_id           IN   NUMBER,
  p_inv_component_id           IN   NUMBER,
  p_inventory_item_id          IN   NUMBER,
  x_return_status              OUT  NOCOPY VARCHAR2
)IS

  l_test          VARCHAR2(1);
  l_api_name      CONSTANT VARCHAR2(30)    := 'Validate_Inv_Comp_Id';
  l_api_name_full CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

BEGIN
	-- Initialize the return status.
	x_return_status := FND_API.G_RET_STS_SUCCESS;


/*   commenting out this SQL as the view cs_sr_inv_components_v is not
     looking at the effective date of the inventory_item_id.
         SELECT 'x'
	 INTO l_test
	 FROM cs_sr_inv_components_v
	 WHERE organization_id = p_inventory_org_id
         AND   component_id = p_inv_component_id
         AND   inventory_item_id  = p_inventory_item_id;
*/

	SELECT 'X' INTO l_test
	FROM
	bom_bill_of_materials bom,
	bom_inventory_components bic,
	mtl_system_items_b kfv
	WHERE
	bom.organization_id = kfv.organization_id AND
	bic.bill_sequence_id = bom.common_bill_sequence_id AND
	trunc(sysdate) between trunc(bic.effectivity_date) and
	nvl(bic.disable_date, trunc(sysdate)) AND
	trunc(sysdate) between trunc(nvl(kfv.start_date_active,sysdate)) and
	nvl(kfv.end_date_active, trunc(sysdate)) AND
	kfv.inventory_item_id = bic.component_item_id AND
	bom.organization_id = p_inventory_org_id AND
	bom.assembly_item_id = p_inventory_item_id AND
	bic.component_item_id = p_inv_component_id AND
	bom.alternate_bom_designator IS NULL;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         Add_Invalid_Argument_Msg( p_token_an    =>  l_api_name_full,
                                   p_token_v     =>  TO_CHAR(p_inv_component_id),
                                   p_token_p     =>  p_parameter_name,
                                   p_table_name  => G_TABLE_NAME ,
                                   p_column_name => 'INV_COMPONENT_ID' );
      WHEN OTHERS  THEN
         fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
         fnd_msg_pub.ADD;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

END  Validate_Inv_Comp_Id;
-----------------------------------------

-- Validate INV COMP VER
-- For BUG 2930217, we check the revision_qty_control_code being 2, before we validate the
-- inv_component_version.

PROCEDURE Validate_Inv_Comp_Ver (
   p_api_name                   IN   VARCHAR2,
   p_parameter_name             IN   VARCHAR2,
   p_inventory_org_id           IN   NUMBER,
   p_inv_component_id           IN   NUMBER,
   p_inv_component_version      IN   VARCHAR2,
   x_return_status              OUT  NOCOPY VARCHAR2 )
IS
   l_rev_control_code   NUMBER;
   l_api_name           CONSTANT VARCHAR2(30) := 'Validate_Inv_Comp_Ver';
   l_api_name_full      CONSTANT VARCHAR2(70) := G_PKG_NAME||'.'||l_api_name;
   l_test               VARCHAR2(3);
BEGIN
   -- Initialize the return status.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   SELECT revision_qty_control_code
   INTO   l_rev_control_code
   FROM   mtl_system_items_b
   WHERE  inventory_item_id = p_inv_component_id
   AND    organization_id   = p_inventory_org_id;

   IF l_rev_control_code = 2 THEN
      SELECT 'x'
      INTO   l_test
      FROM   mtl_item_revisions
      WHERE  organization_id   = p_inventory_org_id
      AND    inventory_item_id = p_inv_component_id
      AND    revision          = p_inv_component_version ;
   END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      Add_Invalid_Argument_Msg(
	 p_token_an    => l_api_name_full,
         p_token_v     => p_inv_component_version,
         p_token_p     => p_parameter_name,
         p_table_name  => G_TABLE_NAME ,
         p_column_name => 'INV_COMPONENT_VERSION' );

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      Add_Invalid_Argument_Msg(
	 p_token_an    => l_api_name_full,
         p_token_v     => p_inv_component_version,
         p_token_p     => p_parameter_name,
         p_table_name  => G_TABLE_NAME ,
         p_column_name => 'INV_COMPONENT_VERSION' );

END  Validate_Inv_Comp_Ver;


-- Validate INV SUBCOMP ID
PROCEDURE Validate_Inv_SubComp_Id (
   p_api_name                   IN   VARCHAR2,
   p_parameter_name             IN   VARCHAR2,
   p_inventory_org_id           IN   NUMBER,
   p_inv_subcomponent_id        IN   NUMBER,
   p_inv_component_id           IN   NUMBER,
   x_return_status              OUT  NOCOPY VARCHAR2 )
IS

   l_test            VARCHAR2(1);
   l_api_name        CONSTANT VARCHAR2(30)    := 'Validate_Inv_SubComp_Id';
   l_api_name_full   CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

BEGIN
   -- Initialize the return status.
   x_return_status := FND_API.G_RET_STS_SUCCESS;

/* commenting out this SQL , as the view cs_sr_inv_subcomponents_v does not
   take the effective dates of the inv_subcomp_id in the invwentory table.
   SELECT 'x'
   INTO   l_test
   FROM   cs_sr_inv_subcomponents_v
   WHERE  organization_id = p_inventory_org_id
   AND    subcomponent_id = p_inv_subcomponent_id
   AND    component_id    = p_inv_component_id
   AND    rownum < 2 ;
*/

	SELECT 'X' INTO l_test
	FROM
	bom_bill_of_materials bom,
	bom_inventory_components bic,
	mtl_system_items_b kfv
	WHERE
	bom.organization_id = kfv.organization_id AND
	bic.bill_sequence_id = bom.common_bill_sequence_id AND
	trunc(sysdate) between trunc(bic.effectivity_date) and
	nvl(bic.disable_date, trunc(sysdate)) AND
	trunc(sysdate) between trunc(nvl(kfv.start_date_active,sysdate)) and
	nvl(kfv.end_date_active, trunc(sysdate)) AND
	kfv.inventory_item_id = bic.component_item_id AND
	bom.organization_id = p_inventory_org_id AND
	bom.assembly_item_id = p_inv_component_id AND
	bic.component_item_id = p_inv_subcomponent_id AND
	bom.alternate_bom_designator IS NULL;


EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      Add_Invalid_Argument_Msg( p_token_an    =>  l_api_name_full,
         p_token_v     =>  TO_CHAR(p_inv_subcomponent_id),
         p_token_p     =>  p_parameter_name,
         p_table_name  => G_TABLE_NAME ,
         p_column_name => 'INV_SUBCOMPONENT_ID' );

   WHEN OTHERS  THEN
      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
      fnd_msg_pub.ADD;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

END  Validate_Inv_SubComp_Id;
-------------------------------------

-- Validate INV SUb COMP VER
PROCEDURE Validate_Inv_SubComp_Ver
( p_api_name                   IN   VARCHAR2,
  p_parameter_name             IN   VARCHAR2,
  p_inventory_org_id           IN   NUMBER,
  p_inv_subcomponent_id        IN   NUMBER,
  p_inv_subcomponent_version   IN   VARCHAR2,
  x_return_status              OUT  NOCOPY VARCHAR2
)IS

  l_test            VARCHAR2(1);
  l_api_name        CONSTANT VARCHAR2(30)    := 'Validate_Inv_SubComp_Ver';
  l_api_name_full   CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;
  l_rev_control_code   NUMBER;

BEGIN
	-- Initialize the return status.
	x_return_status := FND_API.G_RET_STS_SUCCESS;

   SELECT revision_qty_control_code
   INTO   l_rev_control_code
   FROM   mtl_system_items_b
   WHERE  inventory_item_id = p_inv_subcomponent_id
   AND    organization_id   = p_inventory_org_id;

   IF l_rev_control_code = 2 THEN
	SELECT 'x'
	INTO l_test
	FROM mtl_item_revisions
	WHERE organization_id = p_inventory_org_id
        AND   inventory_item_id = p_inv_subcomponent_id
        AND   revision          = p_inv_subcomponent_version ;
   END IF;

EXCEPTION
      WHEN NO_DATA_FOUND THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         Add_Invalid_Argument_Msg( p_token_an    =>  l_api_name_full,
                                   p_token_v     =>  p_inv_subcomponent_version,
                                   p_token_p     =>  p_parameter_name,
                                   p_table_name  => G_TABLE_NAME ,
                                   p_column_name => 'INV_SUBCOMPONENT_VERSION' );
      WHEN OTHERS  THEN
         fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
         fnd_msg_pub.ADD;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

END  Validate_Inv_SubComp_Ver;

-- Validate  SR CREATION CHANNEL
PROCEDURE Validate_SR_Channel
( p_api_name                   IN   VARCHAR2,
  p_parameter_name             IN   VARCHAR2,
  p_sr_creation_channel        IN   VARCHAR2,
  x_return_status              OUT  NOCOPY VARCHAR2
)IS

  l_dummy         VARCHAR2(1);
  l_api_name      CONSTANT VARCHAR2(30)    := 'Validate_SR_Channel';
  l_api_name_full CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

BEGIN
	-- Initialize the return status.
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	SELECT 'x' INTO l_dummy
	FROM  CS_LOOKUPS
	WHERE lookup_code = UPPER(p_sr_creation_channel)
	AND   lookup_type = 'CS_SR_CREATION_CHANNEL'
	AND   TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date_active, SYSDATE))
			AND TRUNC(NVL(end_date_active, SYSDATE)) ;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         Add_Invalid_Argument_Msg( p_token_an    =>  l_api_name_full,
                                   p_token_v     =>  p_sr_creation_channel,
                                   p_token_p     =>  p_parameter_name,
                                   p_table_name  => G_TABLE_NAME ,
                                   p_column_name => 'SR_CREATION_CHANNEL' );
      WHEN OTHERS  THEN
         fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
         fnd_msg_pub.ADD;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

END  Validate_SR_Channel;
---------------------------------------------------------------------------------

-- Validate Language Id
PROCEDURE Validate_CP_Language_Id
( p_api_name                   IN  VARCHAR2,
  p_parameter_name             IN  VARCHAR2,
  p_language_id                IN  NUMBER,
  p_customer_product_id        IN  NUMBER,
  x_return_status              OUT NOCOPY VARCHAR2
)IS

  l_test            VARCHAR2(1);
  l_api_name        CONSTANT VARCHAR2(30)    := 'Validate_CP_Language_Id';
  l_api_name_full   CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

BEGIN
	-- Initialize the return status.
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	 SELECT 'x'
	 INTO l_test
	 FROM cs_cp_languages
	 WHERE cp_language_id = p_language_id
         AND    customer_product_id = p_customer_product_id;

EXCEPTION
	 WHEN NO_DATA_FOUND THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         Add_Invalid_Argument_Msg( p_token_an    =>  l_api_name_full ,
                                   p_token_v     =>  TO_CHAR(p_language_id),
                                   p_token_p     =>  p_parameter_name,
                                   p_table_name => G_TABLE_NAME,
                                   p_column_name => 'LANGUAGE_ID');
      WHEN OTHERS  THEN
         fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
         fnd_msg_pub.ADD;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

END Validate_CP_Language_Id;
---------------------------------------------------------------------------------------------

-- Validate Territory Id
PROCEDURE Validate_Territory_Id
( p_api_name                   IN   VARCHAR2,
  p_parameter_name             IN   VARCHAR2,
  p_territory_id                IN   NUMBER,
  p_owner_id                    IN    NUMBER,
  x_return_status              OUT  NOCOPY VARCHAR2
)IS

  l_test             VARCHAR2(1);
  l_api_name         CONSTANT VARCHAR2(30)    := 'Validate_Territory_Id';
  l_api_name_full    CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

BEGIN
	-- Initialize the return status.
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	SELECT 'x' INTO l_test
	FROM JTF_TERR_RSC_ALL
	WHERE resource_id = p_owner_id
        AND   terr_id = p_territory_id;

EXCEPTION
	 WHEN NO_DATA_FOUND THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         Add_Invalid_Argument_Msg( p_token_an    => l_api_name_full ,
                                   p_token_v     => TO_CHAR(p_territory_id),
                                   p_token_p     => p_parameter_name,
                                   p_table_name  => G_TABLE_NAME,
                                   p_column_name => 'TERRITORY_ID');
      WHEN OTHERS  THEN
         fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
         fnd_msg_pub.ADD;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

END Validate_Territory_Id;


--------------------
-- This validation has to look into JTF_CONTACT_POINTS_V because
-- this view has contact point ids  belonging to PARTIES only and not to PARTY_SITES
-- Validate Contact Point Id
PROCEDURE Validate_Per_Contact_Point_Id
( p_api_name                   IN   VARCHAR2,
  p_parameter_name             IN   VARCHAR2,
  p_contact_point_type         IN   VARCHAR2,
  p_contact_point_id           IN   NUMBER,
  p_party_id                   IN   NUMBER,
  x_return_status              OUT  NOCOPY VARCHAR2
)IS

  l_test             NUMBER;
  l_api_name         CONSTANT VARCHAR2(30)    := 'Validate_Per_Contact_Point_Id';
  l_api_name_full    CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

BEGIN
	-- Initialize the return status.
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	SELECT a.contact_point_id INTO l_test
	FROM HZ_CONTACT_POINTS a
	WHERE a.contact_point_type =  p_contact_point_type
	AND   a.contact_point_id   =  p_contact_point_id
	AND   a.OWNER_TABLE_ID     =  p_party_id
	AND   a.OWNER_TABLE_NAME   =  'HZ_PARTIES'
	AND   a.STATUS = 'A';
EXCEPTION
      WHEN NO_DATA_FOUND THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
      -- new message for 11.5.10
      -- Contact point is not valid. Please check the values for the following:
	  -- party ,contact point and contact point type.

         fnd_message.set_name ('CS', 'CS_SR_CONT_POINT_INVALID');
         fnd_message.set_token('API_NAME', l_api_name_full );
         fnd_msg_pub.add;

      WHEN OTHERS  THEN
         fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
         fnd_msg_pub.ADD;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

END Validate_Per_Contact_Point_Id;
---------------------------------------

-- Validate Contact Point Id
PROCEDURE Validate_Emp_Contact_Point_Id
( p_api_name                   IN   VARCHAR2,
  p_parameter_name             IN   VARCHAR2,
  p_employee_id                IN   NUMBER,
  p_contact_point_id           IN   NUMBER,
  x_return_status              OUT  NOCOPY VARCHAR2
)IS

  l_test             NUMBER;
  l_api_name         CONSTANT VARCHAR2(30)    := 'Validate_Emp_Contact_Point_Id';
  l_api_name_full    CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

BEGIN
	-- Initialize the return status.
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	SELECT PHONE_ID
	INTO  l_test
	FROM  per_phones
	WHERE parent_id  = p_employee_id
        AND   parent_table  = 'PER_ALL_PEOPLE_F'
	AND   phone_id = p_contact_point_id ;

EXCEPTION
	 WHEN NO_DATA_FOUND THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         Add_Invalid_Argument_Msg( p_token_an    =>  l_api_name_full ,
                                   p_token_v     =>  TO_CHAR(p_contact_point_id),
                                   p_token_p     =>  p_parameter_name,
                                   p_table_name  => 'CS_HZ_SR_CONTACT_POINTS' ,
                                   p_column_name => 'CONTACT_POINT_ID');
      WHEN OTHERS  THEN
         fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
         fnd_msg_pub.ADD;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

END Validate_Emp_Contact_Point_Id;
-----------------------------------------------------------------

-- Validate Contact Point Type
PROCEDURE Validate_Contact_Point_Type
( p_api_name                   IN   VARCHAR2,
  p_parameter_name             IN   VARCHAR2,
  p_contact_point_type         IN   VARCHAR2,
  x_return_status              OUT  NOCOPY VARCHAR2
)IS

  l_test           VARCHAR2(1);
  l_api_name       CONSTANT VARCHAR2(30)    := 'Validate_Contact_Point_Type';
  l_api_name_full  CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

BEGIN
  -- Initialize the return status.
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SELECT 'x'
  INTO l_test
  FROM AR_LOOKUPS
  WHERE  lookup_code = UPPER(p_contact_point_type)
  AND    (lookup_type = 'COMMUNICATION_TYPE' OR lookup_type = 'PHONE_LINE_TYPE')
  AND    TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date_active, SYSDATE))
  AND     TRUNC(NVL(end_date_active, SYSDATE))
  AND     ROWNUM <= 1 ;
EXCEPTION
 WHEN NO_DATA_FOUND THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     Add_Invalid_Argument_Msg( p_token_an    =>  l_api_name_full ,
                               p_token_v     =>  p_contact_point_type,
                               p_token_p     => p_parameter_name,
                               p_table_name => 'CS_HZ_SR_CONTACT_POINTS',
                               p_column_name  => 'CONTACT_POINT_TYPE');
 WHEN OTHERS  THEN
         fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
         fnd_msg_pub.ADD;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
END Validate_Contact_Point_Type;

-- Validate Contact Type
PROCEDURE Validate_Contact_Type
( p_api_name           IN   VARCHAR2,
  p_parameter_name     IN   VARCHAR2,
  p_contact_type       IN   VARCHAR2,
  x_return_status      OUT  NOCOPY VARCHAR2
)IS

  l_test            VARCHAR2(1);
  l_api_name        CONSTANT VARCHAR2(30)    := 'Validate_Contact_Type';
  l_api_name_full   CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

BEGIN
	-- Initialize the return status.
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	SELECT 'x' INTO l_test
	FROM CS_LOOKUPS
	WHERE  lookup_code = UPPER(p_contact_type)
        AND    (lookup_type = 'CS_SR_CONTACT_TYPES')
        AND    TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date_active, SYSDATE))
                        AND     TRUNC(NVL(end_date_active, SYSDATE))
        AND ROWNUM <= 1;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
     	x_return_status := FND_API.G_RET_STS_ERROR;
     	Add_Invalid_Argument_Msg( p_token_an    =>  l_api_name_full ,
                                  p_token_v     =>  p_contact_type,
                                  p_token_p     =>  p_parameter_name,
                                  p_table_name => 'CS_HZ_SR_CONTACT_POINTS',
                                  p_column_name  => 'CONTACT_TYPE');
      WHEN OTHERS  THEN
         fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
         fnd_msg_pub.ADD;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
END Validate_Contact_Type;
---------------------------------------

--Validate Account ID
PROCEDURE Validate_Account_Id
(p_api_name        IN   VARCHAR2,
 p_parameter_name  IN   VARCHAR2,
 p_account_id      IN   NUMBER,
 p_customer_id     IN   NUMBER,
 x_return_status   OUT  NOCOPY VARCHAR2
)
IS

  l_test            VARCHAR2(1);
  l_api_name        CONSTANT VARCHAR2(30)    := 'Validate_Account_Id';
  l_api_name_full   CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

BEGIN
	-- Initialize the return status.
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	SELECT 'x' INTO l_test
	FROM hz_cust_accounts   a
	WHERE a.cust_account_id = p_account_id
        AND   a.party_id = p_customer_id
	AND   a.status = 'A'
	-- Added to remove TCA violation -- Sysdate should fall within Account Activation Date and Termination Date -- anmukher -- 08/14/03
	AND   TRUNC(SYSDATE) BETWEEN TRUNC(NVL(a.ACCOUNT_ACTIVATION_DATE, SYSDATE)) AND TRUNC(NVL(a.ACCOUNT_TERMINATION_DATE, SYSDATE));
EXCEPTION
	 WHEN NO_DATA_FOUND THEN
		 x_return_status := FND_API.G_RET_STS_ERROR;
		 Add_Invalid_Argument_Msg( p_token_an    =>  l_api_name_full ,
                                           p_token_v     =>  TO_CHAR(p_account_id),
                                           p_token_p     =>  p_parameter_name,
                                           p_table_name  => G_TABLE_NAME ,
                                           p_column_name => 'ACCOUNT_ID');
      WHEN OTHERS  THEN
		 fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
		 fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
		 fnd_msg_pub.ADD;
		 x_return_status := fnd_api.g_ret_sts_unexp_error;

END Validate_Account_Id;

-- --------------------------------------------------------------------------------
-- Is_MultiOrg_Enabled
--  Description : Checks if the multiorg is enabled
--		returns TRUE if multiorg is enabled
-- --------------------------------------------------------------------------------
FUNCTION Is_MultiOrg_Enabled RETURN BOOLEAN IS
  l_multiorg_enabled  VARCHAR2(1);
BEGIN
    SELECT multi_org_flag INTO l_multiorg_enabled
	FROM FND_PRODUCT_GROUPS;

    IF l_multiorg_enabled = 'Y' THEN
	RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;

END Is_MultiOrg_Enabled;


-------------------------------------------------------------------------------
-- Function Is_Context_Enabled
-- Description:
--   Returns TRUE if the ConText Option is enabled.
-- ----------------------------------------------------------------------------
FUNCTION Is_Context_Enabled RETURN BOOLEAN IS
  l_dummy VARCHAR2(1);
BEGIN
  IF (FND_PROFILE.Value('INC_ENABLE_CONTEXT_SEARCH') = 'Y') THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN FALSE;
END Is_Context_Enabled;


--------------------------------------------------------------------------
-- Procedure Add_Desc_Flex_Msg
-- Usage:
--   This procedure is called from the Validate_Desc_Flex routine in the
--   Create_ServiceRequest API.
-- Description:
--   Add the error message from the FND_FLEX_DESCVAL package to the message
--   list.
--------------------------------------------------------------------------

PROCEDURE Add_Desc_Flex_Msg
( p_token_an	VARCHAR2,
  p_token_dfm	VARCHAR2
)
IS
BEGIN
  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
    FND_MESSAGE.Set_Name('CS', 'CS_API_SR_DESC_FLEX_ERROR');
    FND_MESSAGE.Set_Token('API_NAME', p_token_an);
    FND_MESSAGE.Set_Token('DESC_FLEX_MSG', p_token_dfm);
    FND_MSG_PUB.ADD;
  END IF;
END Add_Desc_Flex_Msg;


--------------------------------------------------------------------------
-- Add_Invalid_Argument_Msg
--------------------------------------------------------------------------

PROCEDURE Add_Invalid_Argument_Msg
( p_token_an	VARCHAR2,
  p_token_v	VARCHAR2,
  p_token_p	VARCHAR2
)
IS
-- bug 2833245 created a new local variable for assigning the value as NULL
l_token_v VARCHAR2(4000);
--end for bug 2833245

BEGIN

  --bug 2833245 condition to check the token value
  l_token_v := p_token_v;
  if l_token_v = FND_API.G_MISS_CHAR then
  l_token_v := NULL;
  end if;
  -- end for bug 2833245


  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
    FND_MESSAGE.Set_Name('CS', 'CS_API_ALL_INVALID_ARGUMENT');
    FND_MESSAGE.Set_Token('API_NAME', p_token_an);
    --bug 2833245 pass the local variable for setting the token
    FND_MESSAGE.Set_Token('VALUE',l_token_v);
    -- end for bug 2833245
    FND_MESSAGE.Set_Token('PARAMETER', p_token_p);
    FND_MSG_PUB.ADD;
  END IF;
END Add_Invalid_Argument_Msg;


--------------------------------------------------------------------------
-- Procedure Add_Key_Flex_Msg
-- Usage:
--   This procedure is called from the Convert_Key_Flex_To_ID routine in
--   the Create_ServiceRequest API.
-- Description:
--   Add the error message from the FND_FLEX_KEYVAL package to the message
--   list.
--------------------------------------------------------------------------

PROCEDURE Add_Key_Flex_Msg
( p_token_an	VARCHAR2,
  p_token_kfm	VARCHAR2
)
IS
BEGIN
  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
    FND_MESSAGE.Set_Name('CS', 'CS_API_SR_KEY_FLEX_ERROR');
    FND_MESSAGE.Set_Token('API_NAME', p_token_an);
    FND_MESSAGE.Set_Token('KEY_FLEX_MSG', p_token_kfm);
    FND_MSG_PUB.ADD;
  END IF;
END Add_Key_Flex_Msg;


--------------------------------------------------------------------------
-- Add_Null_Parameter_Msg
--------------------------------------------------------------------------

PROCEDURE Add_Null_Parameter_Msg
( p_token_an	VARCHAR2,
  p_token_np	VARCHAR2
)
IS
BEGIN
  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
    FND_MESSAGE.Set_Name('CS', 'CS_API_ALL_NULL_PARAMETER');
    FND_MESSAGE.Set_Token('API_NAME', p_token_an);
    FND_MESSAGE.Set_Token('NULL_PARAM', p_token_np);
    FND_MSG_PUB.ADD;
  END IF;
END Add_Null_Parameter_Msg;


--------------------------------------------------------------------------
-- Add_Param_Ignored_Msg
--------------------------------------------------------------------------

PROCEDURE Add_Param_Ignored_Msg
( p_token_an	VARCHAR2,
  p_token_ip	VARCHAR2
)
IS
BEGIN
  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
    FND_MESSAGE.Set_Name('CS', 'CS_API_ALL_PARAM_IGNORED');
    FND_MESSAGE.Set_Token('API_NAME', p_token_an);
    FND_MESSAGE.Set_Token('IGNORED_PARAM', p_token_ip);
    FND_MSG_PUB.ADD_DETAIL( p_message_type => FND_MSG_PUB.G_WARNING_MSG);
  END IF;
END Add_Param_Ignored_Msg;


--------------------------------------------------------------------------
-- Add_Cp_Flag_Ignored_Msg
--------------------------------------------------------------------------


PROCEDURE Add_Cp_Flag_Ignored_Msg
(p_token_an   VARCHAR2,
 p_token_ip   VARCHAR2,
 p_token_pv	  VARCHAR2
 )
IS
BEGIN
  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
    FND_MESSAGE.Set_Name('CS', 'CS_API_SR_CP_FLAG_IGNORED');
    FND_MESSAGE.Set_Token('API_NAME', p_token_an);
    FND_MESSAGE.Set_Token('VALUE', p_token_ip);
    FND_MESSAGE.Set_Token('DEFAULT_VALUE', p_token_pv);
    FND_MSG_PUB.ADD_DETAIL( p_message_type => FND_MSG_PUB.G_WARNING_MSG);
  END IF;
END Add_Cp_Flag_Ignored_Msg;


--------------------------------------------------------------------------
-- Add_Duplicate_Value__Msg
--------------------------------------------------------------------------

PROCEDURE Add_Duplicate_Value_Msg( p_token_an	IN   VARCHAR2,
				   p_token_p    IN   VARCHAR2 ) IS

BEGIN
  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
    FND_MESSAGE.Set_Name('CS', 'CS_API_ALL_DUPLICATE_VALUE');
    FND_MESSAGE.Set_Token('API_NAME', p_token_an);
    FND_MESSAGE.Set_Token('DUPLICATE_VAL_PARAM', p_token_p);
    FND_MSG_PUB.ADD;
  END IF;
END Add_Duplicate_Value_Msg;


PROCEDURE Add_Same_Val_Update_Msg( p_token_an	IN   VARCHAR2,
				   p_token_p	IN   VARCHAR2 ) IS
BEGIN
  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
    FND_MESSAGE.Set_Name('CS', 'CS_API_ALL_SAME_VAL_UPDATE');
    FND_MESSAGE.Set_Token('API_NAME', p_token_an);
    FND_MESSAGE.Set_Token('SAME_VAL_PARAM', p_token_p);
    FND_MSG_PUB.ADD;
  END IF;
END Add_Same_Val_Update_Msg;


PROCEDURE Add_Missing_Param_Msg( p_token_an	IN   VARCHAR2,
				 p_token_mp	IN   VARCHAR2 ) IS
BEGIN
  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
    FND_MESSAGE.SET_NAME('CS', 'CS_API_ALL_MISSING_PARAM');
    FND_MESSAGE.SET_TOKEN('API_NAME', p_token_an);
    FND_MESSAGE.SET_TOKEN('MISSING_PARAM', p_token_mp);
    FND_MSG_PUB.ADD;
  END IF;
END Add_Missing_Param_Msg;


PROCEDURE call_internal_hook( p_package_name IN VARCHAR2 ,
   p_api_name IN VARCHAR2 ,
   p_processing_type IN VARCHAR2,
   x_return_status OUT NOCOPY VARCHAR2 )
IS
  l_api_name                   CONSTANT VARCHAR2(30)    := 'call_internal_hook';
  l_api_name_full              CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;


  CURSOR c1  IS
    SELECT hook_package, hook_api
    FROM jtf_hooks_data
    WHERE package_name = p_package_name
    AND api_name = p_api_name
    AND execute_flag = 'Y'
    AND processing_type = p_processing_type
    ORDER BY execution_order;

    v_cursorid INTEGER ;
    v_blockstr VARCHAR2(2000);
    v_dummy INTEGER;

BEGIN

    FOR i IN c1  LOOP
         v_blockstr := ' begin '||i.hook_package || '.' ||i.hook_api||'(:1); end; ' ;
          EXECUTE IMMEDIATE v_blockstr USING OUT  x_return_status ;

         IF NOT (x_return_status = fnd_api.g_ret_sts_success)  THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
     END LOOP;
   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error  THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;

      WHEN OTHERS  THEN
         fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
         fnd_msg_pub.ADD;
         x_return_status := fnd_api.g_ret_sts_unexp_error;

END call_internal_hook ;

-- -----------------------------------------------------------------------
--  Procedure   : Validate_Bill_To_Ship_To_Acct
--  Function    : Verify that the Bill To Account is valid for given customer site OR customer.
--  Parameters  :
--  IN  :p_api_name             IN   VARCHAR2      Required Name of the calling procedure.
--       p_parameter_name       IN   VARCHAR2      Required Name of the parameter in the
--                                                 calling procedure (e.g. 'p_bill_to_account').
--       p_bill_to_account_id   IN   NUMBER        Required Unique bill to account identifier
--       p_bill_to_customer_id  IN   NUMBER        Unique Bill to customer ientifier
--  OUT :x_return_status        OUT  VARCHAR2(1)
--       FND_API.G_RET_STS_SUCCESS         => Bill_to_Account is valid
--       FND_API.G_RET_STS_ERROR           => Bill_to_Account is invalid
-- -----------------------------------------------------------------------

PROCEDURE Validate_Bill_To_Ship_To_Acct
( p_api_name             IN   VARCHAR2,
  p_parameter_name       IN   VARCHAR2,
  p_account_id   	 IN   NUMBER,
  p_party_id   		 IN   NUMBER,
  x_return_status        OUT  NOCOPY VARCHAR2
)
AS
  l_dummy 	  VARCHAR2(1);
  l_api_name      CONSTANT VARCHAR2(30)  := 'Validate_Bill_To_Ship_To_Acct';
  l_api_name_full CONSTANT VARCHAR2(61)  := G_PKG_NAME||'.'||l_api_name;

BEGIN
      -- Initialize the return status.
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      -- Validation
      SELECT 'x' INTO l_dummy
      FROM  hz_cust_accounts
      WHERE cust_account_id = p_account_id
      AND   party_id = p_party_id
      AND   status = 'A';
EXCEPTION
	WHEN NO_DATA_FOUND THEN
	   x_return_status := FND_API.G_RET_STS_ERROR;
	   Add_Invalid_Argument_Msg( p_token_an    => l_api_name_full,
				     p_token_v     => p_account_id,
				     p_token_p     => p_parameter_name,
                                     p_table_name  => G_TABLE_NAME,
                                     p_column_name => 'ACCOUNT_ID' );

      WHEN OTHERS  THEN
         fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
         fnd_msg_pub.ADD;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
END Validate_Bill_To_Ship_To_Acct ;

-- -----------------------------------------------------------------------
-- Start of Comments
--  Procedure   : Validate_source_program_code
--  Function    : Verify that the source program code is valid lookup code
--                from the lookup CS_SR_SOURCE_PROGRAMS.
--
--  Parameters  :
--
--    IN  : p_api_name             IN   VARCHAR2        Required
--                                 Name of the calling procedure.
--          p_parameter_name       IN   VARCHAR2        Required
--                                 Name of the parameter in the calling procedure
--                                 (e.g. 'p_source_program_code').
--          p_source_program_code  IN   VARCHAR2(30)    Required
--                                 Service request source program code
--
--    OUT : x_return_status        OUT  VARCHAR2(1)
--          FND_API.G_RET_STS_SUCCESS         => source_program_code is valid
--          FND_API.G_RET_STS_ERROR           => source_program_code is invalid
--
--  Notes : Unknown exceptions (i.e. unexpected errors) should be
--          handled by the calling procedure.
-- End of Comments
-- -----------------------------------------------------------------------


PROCEDURE Validate_source_program_Code
    ( p_api_name                      IN   VARCHAR2,
      p_parameter_name                IN   VARCHAR2,
      p_source_program_code           IN   VARCHAR2,
      x_return_status                 OUT  NOCOPY VARCHAR2
    )IS
  l_dummy  		VARCHAR2(1);
  l_api_name           CONSTANT VARCHAR2(30)    := 'Validate_source_program_Code';
  l_api_name_full      CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

BEGIN
      -- Initialize the return status.
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Verify the request CP against the database.
      SELECT 'x' INTO l_dummy
      FROM   CS_LOOKUPS
      WHERE  lookup_code = UPPER(p_source_program_code)
      AND    lookup_type = 'CS_SR_SOURCE_PROGRAMS'
      AND    enabled_flag = 'Y'
      AND    TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date_active, SYSDATE))
                            AND     TRUNC(NVL(end_date_active, SYSDATE));

EXCEPTION
	WHEN NO_DATA_FOUND THEN
	   x_return_status := FND_API.G_RET_STS_ERROR;
	   Add_Invalid_Argument_Msg( p_token_an => l_api_name_full,
				     p_token_v  => p_source_program_code,
				     p_token_p  => p_parameter_name,
                                     p_table_name  => G_TABLE_NAME,
                                     p_column_name => 'CREATION_PROGRAM_CODE' );

      WHEN OTHERS  THEN
         fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
         fnd_msg_pub.ADD;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
END Validate_source_program_Code;
-- -----------------------------------------------------------------------
-- Start of Comments
--  Procedure   : Validate_INC_DIST_QUAL_UOM
--  Function    : Verify that the INC_DIST_QUAL_UOM is valid lookup
--                code from the lookup CS_SR_DISTANCE_UOM
--
--  Parameters  :
--
--    IN  : p_api_name             IN   VARCHAR2        Required
--                                 Name of the calling procedure.
--          p_parameter_name       IN   VARCHAR2        Required
--                                 Name of the parameter in the calling procedure
--                                 (e.g. 'P_INC_DIST_QUAL_UOM').
--          P_INC_DIST_QUAL_UOM  IN   VARCHAR2(30)
--                              Service request incident distance qualifier UOM
--    OUT : x_return_status        OUT  VARCHAR2(1)
--          FND_API.G_RET_STS_SUCCESS   => INC_DIST_QUAL_UOM is valid
--          FND_API.G_RET_STS_ERROR     => INC_DIST_QUAL_UOM is invalid
--
--  Notes : Unknown exceptions (i.e. unexpected errors) should be
--          handled by the calling procedure.
-- End of Comments
-- -----------------------------------------------------------------------

PROCEDURE Validate_INC_DIST_QUAL_UOM
    ( p_api_name                      IN   VARCHAR2,
      p_parameter_name                IN   VARCHAR2,
      p_INC_DIST_QUAL_UOM             IN   VARCHAR2,
      x_return_status                 OUT  NOCOPY VARCHAR2
    ) IS
      l_dummy  VARCHAR2(1);
      l_api_name                   CONSTANT VARCHAR2(30)    := 'Validate_INC_DIST_QUAL_UOM';
      l_api_name_full              CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

BEGIN
      -- Initialize the return status.
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Verify the request CP against the database.
      SELECT 'x' INTO l_dummy
      FROM   CS_LOOKUPS
      WHERE  lookup_code = UPPER(p_INC_DIST_QUAL_UOM)
      AND    lookup_type = 'CS_SR_DISTANCE_UOM'
      AND    enabled_flag = 'Y'
      AND    TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date_active, SYSDATE))
                            AND     TRUNC(NVL(end_date_active, SYSDATE));

EXCEPTION
	WHEN NO_DATA_FOUND THEN
	   x_return_status := FND_API.G_RET_STS_ERROR;
	   Add_Invalid_Argument_Msg( p_token_an => l_api_name_full,
				     p_token_v  => p_INC_DIST_QUAL_UOM,
				     p_token_p  => p_parameter_name ,
                                     p_table_name => G_TABLE_NAME,
                                     p_column_name => 'INCIDENT_DISTANCE_QUAL_UOM');

      WHEN OTHERS  THEN
         fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
         fnd_msg_pub.ADD;
         x_return_status := fnd_api.g_ret_sts_unexp_error;


END Validate_INC_DIST_QUAL_UOM;


-- -----------------------------------------------------------------------
-- Start of Comments
--  Procedure   : Validate_INC_DIRECTION_QUAL
--  Function    : Verify that the INC_DIRECTION_QUAL is valid lookup
--                code from the lookup CS_SR_DIRECTIONS.
--
--  Parameters  :
--
--    IN  : p_api_name             IN   VARCHAR2        Required
--                                 Name of the calling procedure.
--          p_parameter_name       IN   VARCHAR2        Required
--                                 Name of the parameter in the calling procedure
--                                 (e.g. 'p_INC_DIRECTION_QUAL').
--          p_INC_DIRECTION_QUAL  IN   VARCHAR2(30)
--                                 Service request incident direction qualifier
--
--    OUT : x_return_status        OUT  VARCHAR2(1)
--          FND_API.G_RET_STS_SUCCESS => INC_DIRECTION_QUAL is valid
--          FND_API.G_RET_STS_ERROR   => INC_DIRECTION_QUAL is invalid
--
--  Notes : Unknown exceptions (i.e. unexpected errors) should be
--          handled by the calling procedure.
-- End of Comments
-- -----------------------------------------------------------------------

PROCEDURE Validate_INC_DIRECTION_QUAL
    ( p_api_name                      IN   VARCHAR2,
      p_parameter_name                IN   VARCHAR2,
      p_INC_DIRECTION_QUAL            IN   VARCHAR2,
      x_return_status                 OUT  NOCOPY VARCHAR2
    )IS
      l_dummy  		VARCHAR2(1);
      l_api_name        CONSTANT VARCHAR2(30)    := 'Validate_INC_DIRECTION_QUAL';
      l_api_name_full   CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

BEGIN
      -- Initialize the return status.
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Verify the request CP against the database.
      SELECT 'x' INTO l_dummy
      FROM   CS_LOOKUPS
      WHERE  lookup_code = UPPER(p_INC_DIRECTION_QUAL)
      AND    lookup_type = 'CS_SR_DIRECTIONS'
      AND    enabled_flag = 'Y'
      AND    TRUNC(SYSDATE) BETWEEN TRUNC(NVL(start_date_active, SYSDATE))
                            AND     TRUNC(NVL(end_date_active, SYSDATE));

EXCEPTION
	WHEN NO_DATA_FOUND THEN
	   x_return_status := FND_API.G_RET_STS_ERROR;
	   Add_Invalid_Argument_Msg( p_token_an => l_api_name_full,
				     p_token_v  => p_INC_DIRECTION_QUAL,
				     p_token_p  => p_parameter_name,
                                     p_table_name => G_TABLE_NAME,
                                     p_column_name => 'INCIDENT_DIRECTION_QUALIFIER' );

      WHEN OTHERS  THEN
         fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
         fnd_msg_pub.ADD;
         x_return_status := fnd_api.g_ret_sts_unexp_error;


END Validate_INC_DIRECTION_QUAL;


--------------------------------------------------------------------------
-- Procedure Add_Desc_Flex_Msg
-- Usage:
--   This procedure is called from the Validate_Desc_Flex routine in the
--   Create_ServiceRequest API.
-- Description:
--   Add the error message from the FND_FLEX_DESCVAL package to the message
--   list.
--------------------------------------------------------------------------

PROCEDURE Add_Desc_Flex_Msg
( p_token_an	   VARCHAR2,
  p_token_dfm  	   VARCHAR2,
  p_table_name  IN VARCHAR2 ,
  p_column_name IN VARCHAR2
)
IS
l_associated_col1  VARCHAR2(240);

BEGIN
  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN

    IF p_table_name IS NOT NULL THEN
       l_associated_col1 := p_table_name ;
       IF p_column_name IS NOT NULL THEN
          l_associated_col1 := l_associated_col1 ||'.'||p_column_name ;
       END IF ;
    ELSIF p_column_name IS NOT NULL THEN
       l_associated_col1 := p_column_name;
    ELSE
       l_associated_col1 := p_token_dfm ;
    END IF ;

    FND_MESSAGE.Set_Name('CS', 'CS_API_SR_DESC_FLEX_ERROR');
    FND_MESSAGE.Set_Token('API_NAME', p_token_an);
    FND_MESSAGE.Set_Token('DESC_FLEX_MSG', p_token_dfm);
    FND_MSG_PUB.ADD_DETAIL(p_associated_column1 => l_associated_col1);

  END IF;
END Add_Desc_Flex_Msg;

--------------------------------------------------------------------------
-- Start of comments
--  Procedure	: Add_Invalid_Argument_Msg
--  Description	: Overloaded procedure to Add the CS_API_ALL_INVALID_ARGUMENT
--                message to the message list.
--
--  Parameters	:
--  IN		:
--	p_token_an    IN  VARCHAR2  Required     --	Value of the API_NAME token.
--	p_token_v     IN  VARCHAR2  Required     --	Value of the VALUE token.
--	p_token_p     IN  VARCHAR2  Required     --	Value of the PARAMETER token.
--      p_column_name IN  VARCHAR2  Default Null --     Name of the database column/control
--                                                      parameter being validated
--      p_table_name  IN  VARCHAR2  Default Null --     Name of the database table/control
--                                                      parameter being validated
-- End of comments
--------------------------------------------------------------------------

PROCEDURE Add_Invalid_Argument_Msg ( p_token_an	   IN VARCHAR2,
                                     p_token_v	   IN VARCHAR2,
                                     p_token_p	   IN VARCHAR2 ,
                                     p_table_name  IN VARCHAR2 ,
                                     p_column_name IN VARCHAR2
)
IS
l_associated_col1  VARCHAR2(240);
--bug 2833245 created a new local variable for assigning the value as NULL
l_token_v VARCHAR2(4000);
--end for bug 2833245
BEGIN
  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN

    IF p_table_name IS NOT NULL THEN
       l_associated_col1 := p_table_name ;
       IF p_column_name IS NOT NULL THEN
          l_associated_col1 := l_associated_col1 ||'.'||p_column_name ;
       END IF ;
    ELSIF p_column_name IS NOT NULL THEN
       l_associated_col1 := p_column_name;
    ELSE
       l_associated_col1 := p_token_p ;
    END IF ;

    --bug 2833245 condition to check the token value
    l_token_v := p_token_v;
    if l_token_v = FND_API.G_MISS_CHAR then
    l_token_v := NULL;
    end if;
    -- end for bug 2833245

    FND_MESSAGE.Set_Name('CS', 'CS_API_ALL_INVALID_ARGUMENT');
    FND_MESSAGE.Set_Token('API_NAME', p_token_an);
    --bug 2833245 pass the local variable for setting the token
    FND_MESSAGE.Set_Token('VALUE',l_token_v);
    -- end for bug 2833245
    FND_MESSAGE.Set_Token('PARAMETER', p_token_p);
    FND_MSG_PUB.ADD_DETAIL(p_associated_column1 => l_associated_col1);

    --For bug 2885111 - to remove the blank message
    --FND_MSG_PUB.ADD_DETAIL(p_associated_column1 => l_associated_col1);
  END IF;
END Add_Invalid_Argument_Msg;


--------------------------------------------------------------------------
-- Start of comments
--  Procedure	: Add_Key_Flex_Msg
--  Description	: Overloaded Procedure to Add the CS_API_SR_KEY_FLEX_ERROR message to the i
--                message list.
--  Usage       : This procedure is called from the Convert_Key_Flex_To_ID routine in
--                the Create_ServiceRequest API.
--  Parameters	:
--  IN		:
--	p_token_an	IN  VARCHAR2	Required 	Value of the API_NAME token.
--	p_token_kfm	IN  VARCHAR2	Required	Value of the KEY_FLEX_MSG token.
-- End of comments
--------------------------------------------------------------------------

PROCEDURE Add_Key_Flex_Msg ( p_token_an    IN VARCHAR2,
                             p_token_kfm   IN VARCHAR2,
                             p_table_name  IN VARCHAR2 ,
                             p_column_name IN VARCHAR2
)
IS
l_associated_col1  VARCHAR2(240);
BEGIN
  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN

    IF p_table_name IS NOT NULL THEN
       l_associated_col1 := p_table_name ;
       IF p_column_name IS NOT NULL THEN
          l_associated_col1 := l_associated_col1 ||'.'||p_column_name ;
       END IF ;
    ELSIF p_column_name IS NOT NULL THEN
       l_associated_col1 := p_column_name;
    ELSE
       l_associated_col1 := p_token_kfm ;
    END IF ;
    FND_MESSAGE.Set_Name('CS', 'CS_API_SR_KEY_FLEX_ERROR');
    FND_MESSAGE.Set_Token('API_NAME', p_token_an);
    FND_MESSAGE.Set_Token('KEY_FLEX_MSG', p_token_kfm);
    FND_MSG_PUB.ADD_DETAIL(p_associated_column1 => l_associated_col1);
  END IF;
END Add_Key_Flex_Msg;

--------------------------------------------------------------------------
-- Start of comments
--  Procedure	: Add_Missing_Param_Msg
--  Description	: Overloaded Procedure to Add the CS_API_ALL_MISSING_PARAM message to the message
--		  list.
--  Parameters	:
--  IN		:
--	p_token_an    IN  VARCHAR2  Required     --	Value of the API_NAME token.
--	p_token_v     IN  VARCHAR2  Required     --	Value of the VALUE token.
--	p_token_p     IN  VARCHAR2  Required     --	Value of the PARAMETER token.
--      p_column_name IN  VARCHAR2  Default Null --     Name of the database column/control
--                                                      parameter being validated
--      p_table_name  IN  VARCHAR2  Default Null --     Name of the database table/control
--                                                      parameter being validated
-- End of comments
--------------------------------------------------------------------------

PROCEDURE Add_Missing_Param_Msg ( p_token_an    IN  VARCHAR2,
                                  p_token_mp    IN  VARCHAR2,
                                  p_table_name  IN  VARCHAR2 ,
                                  p_column_name IN  VARCHAR2 ) IS
l_associated_col1  VARCHAR2(240);
BEGIN
  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN

    IF p_table_name IS NOT NULL THEN
       l_associated_col1 := p_table_name ;
       IF p_column_name IS NOT NULL THEN
          l_associated_col1 := l_associated_col1 ||'.'||p_column_name ;
       END IF ;
    ELSIF p_column_name IS NOT NULL THEN
       l_associated_col1 := p_column_name;
    ELSE
       l_associated_col1 := p_token_mp ;
    END IF ;
    FND_MESSAGE.SET_NAME('CS', 'CS_API_ALL_MISSING_PARAM');
    FND_MESSAGE.SET_TOKEN('API_NAME', p_token_an);
    FND_MESSAGE.SET_TOKEN('MISSING_PARAM', p_token_mp);
    FND_MSG_PUB.ADD_DETAIL(p_associated_column1 => l_associated_col1);
  END IF;
END Add_Missing_Param_Msg;

--------------------------------------------------------------------------
-- Start of comments
--  Procedure	: Add_Null_Parameter_Msg
--  Description	: Overloaded Procedure to Add the CS_API_ALL_NULL_PARAMETER message to the message
--		  list.
--  Parameters	:
--  IN		:
--	p_token_an    IN  VARCHAR2  Required     --	Value of the API_NAME token.
--	p_token_v     IN  VARCHAR2  Required     --	Value of the VALUE token.
--	p_token_p     IN  VARCHAR2  Required     --	Value of the PARAMETER token.
--      p_column_name IN  VARCHAR2  Default Null --     Name of the database column/control
--                                                      parameter being validated
--      p_table_name  IN  VARCHAR2  Default Null --     Name of the database table/control
--                                                      parameter being validated
-- End of comments
--------------------------------------------------------------------------

PROCEDURE Add_Null_Parameter_Msg ( p_token_an    IN  VARCHAR2,
                                   p_token_np	 IN  VARCHAR2,
                                   p_table_name  IN  VARCHAR2 ,
                                   p_column_name IN  VARCHAR2
)
IS
l_associated_col1  VARCHAR2(240);
BEGIN
  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN

    IF p_table_name IS NOT NULL THEN
       l_associated_col1 := p_table_name ;
       IF p_column_name IS NOT NULL THEN
          l_associated_col1 := l_associated_col1 ||'.'||p_column_name ;
       END IF ;
    ELSIF p_column_name IS NOT NULL THEN
       l_associated_col1 := p_column_name;
    ELSE
       l_associated_col1 := p_token_np ;
    END IF ;
    FND_MESSAGE.Set_Name('CS', 'CS_API_ALL_NULL_PARAMETER');
    FND_MESSAGE.Set_Token('API_NAME', p_token_an);
    FND_MESSAGE.Set_Token('NULL_PARAM', p_token_np);
    FND_MSG_PUB.ADD_DETAIL(p_associated_column1 => l_associated_col1);
  END IF;
END Add_Null_Parameter_Msg;

--------------------------------------------------------------------------
-- Start of comments
--  Procedure	: Add_Param_Ignored_Msg
--  Description	: Overloaded Procedure to Add the CS_API_ALL_PARAM_IGNORED message to the message
--		  list.
--  Parameters	:
--  IN		:
--	p_token_an    IN  VARCHAR2  Required     --	Value of the API_NAME token.
--	p_token_v     IN  VARCHAR2  Required     --	Value of the VALUE token.
--	p_token_p     IN  VARCHAR2  Required     --	Value of the PARAMETER token.
--      p_column_name IN  VARCHAR2  Default Null --     Name of the database column/control
--                                                      parameter being validated
--      p_table_name  IN  VARCHAR2  Default Null --     Name of the database table/control
--                                                      parameter being validated
-- End of comments
--------------------------------------------------------------------------

PROCEDURE Add_Param_Ignored_Msg ( p_token_an	 IN  VARCHAR2,
                                  p_token_ip     IN  VARCHAR2,
                                  p_table_name   IN  VARCHAR2 ,
                                  p_column_name  IN  VARCHAR2
)
IS
l_associated_col1  VARCHAR2(240);
BEGIN
  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN

    IF p_table_name IS NOT NULL THEN
       l_associated_col1 := p_table_name ;
       IF p_column_name IS NOT NULL THEN
          l_associated_col1 := l_associated_col1 ||'.'||p_column_name ;
       END IF ;
    ELSIF p_column_name IS NOT NULL THEN
       l_associated_col1 := p_column_name;
    ELSE
       l_associated_col1 := p_token_ip ;
    END IF ;
    FND_MESSAGE.Set_Name('CS', 'CS_API_ALL_PARAM_IGNORED');
    FND_MESSAGE.Set_Token('API_NAME', p_token_an);
    FND_MESSAGE.Set_Token('IGNORED_PARAM', p_token_ip);
    FND_MSG_PUB.ADD_DETAIL(p_associated_column1 => l_associated_col1);
  END IF;
END Add_Param_Ignored_Msg;

--------------------------------------------------------------------------
-- Start of comments
--  Procedure	: Add_Duplicate_Value_Msg
--  Description	: Overloaded Procedure to Add the CS_API_ALL_PARAM_IGNORED message to the message
--		  list.
--  Parameters	:
--  IN		:
--	p_token_an    IN  VARCHAR2  Required     --	Value of the API_NAME token.
--	p_token_v     IN  VARCHAR2  Required     --	Value of the VALUE token.
--	p_token_p     IN  VARCHAR2  Required     --	Value of the PARAMETER token.
--      p_column_name IN  VARCHAR2  Default Null --     Name of the database column/control
--                                                      parameter being validated
--      p_table_name  IN  VARCHAR2  Default Null --     Name of the database table/control
--                                                      parameter being validated
-- End of comments
--------------------------------------------------------------------------

PROCEDURE Add_Duplicate_Value_Msg( p_token_an	 IN  VARCHAR2,
				   p_token_p     IN  VARCHAR2,
                                   p_table_name  IN  VARCHAR2 ,
                                   p_column_name IN  VARCHAR2 ) IS
l_associated_col1  VARCHAR2(240);

BEGIN
  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN

    IF p_table_name IS NOT NULL THEN
       l_associated_col1 := p_table_name ;
       IF p_column_name IS NOT NULL THEN
          l_associated_col1 := l_associated_col1 ||'.'||p_column_name ;
       END IF ;
    ELSIF p_column_name IS NOT NULL THEN
       l_associated_col1 := p_column_name;
    ELSE
       l_associated_col1 := p_token_p ;
    END IF ;
    FND_MESSAGE.Set_Name('CS', 'CS_API_ALL_DUPLICATE_VALUE');
    FND_MESSAGE.Set_Token('API_NAME', p_token_an);
    FND_MESSAGE.Set_Token('DUPLICATE_VAL_PARAM', p_token_p);
    FND_MSG_PUB.ADD_DETAIL(p_associated_column1 => l_associated_col1);
  END IF;
END Add_Duplicate_Value_Msg;

--------------------------------------------------------------------------
-- Start of comments
--  Procedure	: Add_Same_Val_Update_Msg
--  Description	: Overloaded Procedure to Add the CS_API_ALL_PARAM_IGNORED message to the message
--		  list.
--  Parameters	:
--  IN		:
--	p_token_an    IN  VARCHAR2  Required     --	Value of the API_NAME token.
--	p_token_v     IN  VARCHAR2  Required     --	Value of the VALUE token.
--	p_token_p     IN  VARCHAR2  Required     --	Value of the PARAMETER token.
--      p_column_name IN  VARCHAR2  Default Null --     Name of the database column/control
--                                                      parameter being validated
--      p_table_name  IN  VARCHAR2  Default Null --     Name of the database table/control
--                                                      parameter being validated
-- End of comments
--------------------------------------------------------------------------

PROCEDURE Add_Same_Val_Update_Msg( p_token_an	 IN  VARCHAR2,
				   p_token_p	 IN  VARCHAR2,
                                   p_table_name  IN  VARCHAR2 ,
                                   p_column_name IN  VARCHAR2 ) IS
l_associated_col1  VARCHAR2(240);
BEGIN
  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN

    IF p_table_name IS NOT NULL THEN
       l_associated_col1 := p_table_name ;
       IF p_column_name IS NOT NULL THEN
          l_associated_col1 := l_associated_col1 ||'.'||p_column_name ;
       END IF ;
    ELSIF p_column_name IS NOT NULL THEN
       l_associated_col1 := p_column_name;
    ELSE
       l_associated_col1 := p_token_p ;
    END IF ;
    FND_MESSAGE.Set_Name('CS', 'CS_API_ALL_SAME_VAL_UPDATE');
    FND_MESSAGE.Set_Token('API_NAME', p_token_an);
    FND_MESSAGE.Set_Token('SAME_VAL_PARAM', p_token_p);
    FND_MSG_PUB.ADD_DETAIL(p_associated_column1 => l_associated_col1,
                           p_message_type => FND_MSG_PUB.G_WARNING_MSG);
  END IF;
END Add_Same_Val_Update_Msg;

-- -----------------------------------------------------------------------------
---
-- Validate_Site_Site_Use
-- Same procedure is used to validate Bill_to and Ship_To Site and Sites Use.
-- 1. Site must be an active site attached to party
-- 2. Site Use must be Valid and Must be BILL_TO or SHIP_TO as required
-- 3. p_site_use_type will be BILL_TO or SHIP_TO
-- -----------------------------------------------------------------------------
-- Modification History
-- Date     Name     Desc
-- -------- -------- -----------------------------------------------------------
-- 07/22/05 smisra   Bug 4292583
--                   Modified query and replaced literal 'A' with a variable
--                   having a value 'A' for performance reasons.
-- -----------------------------------------------------------------------------
PROCEDURE Validate_Site_Site_Use (
        p_api_name                       IN  VARCHAR2,
        p_parameter_name                 IN  VARCHAR2,
        p_site_id                        IN  NUMBER,
        p_site_use_id                    IN  NUMBER,
        p_party_id                       IN  NUMBER,
        p_site_use_type                  IN  VARCHAR2,
        x_return_status                  OUT NOCOPY VARCHAR2
)
AS
l_literal_a VARCHAR2(3);
    l_api_name        CONSTANT VARCHAR2(30) := 'Validate_Site_Site_Use';
    l_api_name_full   CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_api_name;

  CURSOR Site_Site_Use  IS
    SELECT s.status
    FROM Hz_Party_Sites  s,
         Hz_Party_Site_Uses su
    WHERE s.party_site_id = su.party_site_id
    AND   s.party_site_id = p_site_id
    AND   s.party_id      = p_party_id
    AND   su.party_site_use_id = p_site_use_id
    AND   s.status = l_literal_a
    AND   su.status = l_literal_a
    -- Commented out to remove TCA Violation -- Party site use dates not to be checked -- anmukher -- 08/14/03
    -- AND   trunc(sysdate) between trunc(nvl(su.begin_date,sysdate))
                        -- and trunc(nvl(su.end_date,sysdate))
    AND   su.site_use_type = p_site_use_type;

    l_dummy Varchar2(5);
BEGIN
  -- Initialize return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_literal_a     := 'A';
  OPEN site_site_use;
  FETCH site_site_use INTO l_dummy;
  IF (site_site_use%NOTFOUND) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    CLOSE site_site_use;

    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE site_site_use ;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
        CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg
                         (p_token_an =>  l_api_name_full,
                          p_token_v  =>  'site_id:='||to_char(p_site_id)||' or site_use_id:='||to_char(p_site_use_id),
                          p_token_p  =>  p_parameter_name );

   WHEN OTHERS THEN
        fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
        fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
        fnd_msg_pub.add;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Validate_Site_Site_Use ;

-- -----------------------------------------------------------------------------
---
-- Validate_Bill_Ship_Site_Use
-- Same procedure is used to validate Bill_to and Ship_To Sites
-- 1. Site Use must be an active site attached to party
-- 2. Site USe must be Valid and Must be BILL_TO or SHIP_TO as required
-- 3. p_site_use_type will be BILL_TO or SHIP_TO
-- -----------------------------------------------------------------------------

PROCEDURE Validate_Bill_Ship_Site_Use (
        p_api_name                       IN  VARCHAR2,
        p_parameter_name                 IN  VARCHAR2,
        p_site_use_id                    IN  NUMBER,
        p_party_id                       IN  NUMBER,
        p_site_use_type                  IN  VARCHAR2,
        x_site_id                        OUT  NOCOPY NUMBER,
        x_return_status                  OUT  NOCOPY VARCHAR2
) IS
  l_api_name          CONSTANT VARCHAR2(30)    := 'Validate_Bill_Ship_Site_Use';
  l_api_name_full     CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

    CURSOR Bill_To_Site_Use  IS
    SELECT s.party_site_id
    FROM Hz_Party_Sites  s,
         Hz_Party_Site_Uses su
    WHERE s.party_site_id = su.party_site_id
    AND   su.party_site_use_id = p_site_use_id
    AND   s.party_id      = p_party_id
    AND   s.status = 'A'
    AND   su.status = 'A'
    -- Commented out to remove TCA Violation -- Party site use dates not to be checked -- anmukher -- 08/14/03
    -- AND   trunc(sysdate) between trunc(nvl(su.begin_date,sysdate))
                        -- and trunc(nvl(su.end_date,sysdate))
    AND   su.site_use_type = p_site_use_type;

BEGIN

  -- Initialize return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN bill_to_site_use;
  FETCH bill_to_site_use INTO x_site_id;
  IF (bill_to_site_use%NOTFOUND) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    CLOSE bill_to_site_use;

    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE bill_to_site_use ;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
        CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg(
                          p_token_an =>  l_api_name_full,
                          p_token_v  =>  to_char(p_site_use_id),
                          p_token_p  =>  p_parameter_name );

   WHEN OTHERS THEN
        fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
        fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
        fnd_msg_pub.add;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Validate_Bill_Ship_Site_Use;


-- DJ API Cleanup; added new proc
-- Procedure to be called when SR Type changes and service security is
-- enabled.
-- If there are any open Tasks, add a WARNING message to the Message stack,
-- but return back a success status. It is upto the calling program to pull
-- out the error msg. from the stack and processed as needed.

PROCEDURE TASK_OWNER_CROSS_VAL (
   p_incident_id          IN   NUMBER,
   x_return_status        OUT  NOCOPY VARCHAR2 )
IS
   l_dummy               NUMBER := 0;
   l_sr_agent_security   VARCHAR2(15);
   l_api_name            CONSTANT VARCHAR2(30) := 'TASK_OWNER_CROSS_VAL';
   l_api_name_full       CONSTANT VARCHAR2(70) := G_PKG_NAME||'.'||l_api_name;
BEGIN

   -- procedure always returns a success status but may populate a warning
   -- message in the message stack
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Check if service security is enable. This select will always return
   -- with atleast one record.
   select sr_agent_security
   into   l_sr_agent_security
   from   cs_system_options
   where  rownum = 1;

   if ( l_sr_agent_security <> 'ANONE' ) then
      select count(*)
      into   l_dummy
      from   jtf_tasks_b          a,
	     jtf_task_statuses_b  b
      where  a.source_object_id        = p_incident_id
      and    a.source_object_type_code = 'SR'
      and    a.task_status_id          = b.task_status_id
      and    b.closed_flag             <> 'Y';

      if ( l_dummy > 0 ) then
         -- put in a warning message into the msg. stack.
         -- new message for 11.5.10
         -- There are open tasks associated to the service request. Changing the
         -- service request type may invalidate some of the task assignments.
         -- Please verify that the task owners are valid for the new service
         -- request type.
         fnd_message.set_name ('CS', 'CS_SR_TASK_OWNER_INVALID');
         fnd_msg_pub.ADD;
      end if;
   end if;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
      fnd_msg_pub.add;

END TASK_OWNER_CROSS_VAL;

-- KP API Cleanup; added new proc
-- Procedure to be called when Incident Location Id or CP changes. If
-- Customer Product Id is passed , the incident Location Id should
-- be the same as Install Base location.

 PROCEDURE CP_INCIDENT_SITE_CROSS_VAL(
        p_parameter_name                 IN  VARCHAR2,
        p_incident_location_id           IN   NUMBER,
        p_customer_product_id            IN   NUMBER,
        x_return_status                  OUT NOCOPY varchar2  )
 IS
  l_dummy 	VARCHAR2(1);
  l_api_name                   CONSTANT VARCHAR2(30)    := 'CP_INCIDENT_SITE_CROSS_VAL';
  l_api_name_full              CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

 BEGIN

	x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT 'x' INTO l_dummy
    FROM   csi_item_instances a
    WHERE  a.instance_id = p_customer_product_id
    AND    a.location_id = p_incident_location_id;

 EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      fnd_message.set_name ('CS', 'CS_INVALID_INC_LOCATION');
      fnd_message.set_token('INCIDENT_LOCATION_ID',  p_incident_location_id);
      fnd_message.set_token('CUSTOMER_PRODUCT_ID',   p_customer_product_id);
	  fnd_msg_pub.add;

   WHEN OTHERS THEN
        fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
        fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
        fnd_msg_pub.add;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END CP_INCIDENT_SITE_CROSS_VAL;

-- KP API Cleanup; added new proc
-- Procedure to be called when install site Id or CP changes. If
-- Customer Product Id is passed , the install site Id should
-- be the same as Install Base location.

 PROCEDURE CP_INSTALL_SITE_CROSS_VAL (
        p_parameter_name                 IN  VARCHAR2,
        p_install_site_id           IN   NUMBER,
        p_customer_product_id            IN   NUMBER,
        x_return_status                  OUT NOCOPY varchar2  )
 IS
  l_dummy 	VARCHAR2(1);
  l_api_name                   CONSTANT VARCHAR2(30)    := 'CP_INSTALL_SITE_CROSS_VAL';
  l_api_name_full              CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;
  l_install_site_id		csi_item_instances.install_location_id%type;
  l_install_site_type		csi_item_instances.install_location_type_code%type;

 BEGIN

	x_return_status := FND_API.G_RET_STS_SUCCESS;
-- Changes made for bug 9061438 by Sanjana Rao on 08-jan-2010.As per new logic we will
--do the install site validation only when instance has a valid  install site type
-- of type 'HZ_PARTY_SITES'
    SELECT a.install_location_id,a.install_location_type_code
    INTO l_install_site_id,l_install_site_type
    FROM   csi_item_instances a
    WHERE  a.instance_id = p_customer_product_id;
-- If instance has install party sites of type HZ_PARTY_SITES
-- then validate that
	IF l_install_site_type='HZ_PARTY_SITES'  THEN
       IF l_install_site_id <> p_install_site_id THEN
      	x_return_status := FND_API.G_RET_STS_ERROR;
      	fnd_message.set_name ('CS', 'CS_INVALID_INSTALL_SITE');
      	fnd_message.set_token('INSTALL_SITE_ID',  p_install_site_id);
      	fnd_message.set_token('CUSTOMER_PRODUCT_ID',   p_customer_product_id);
	  	fnd_msg_pub.add;
	   END IF;
     END IF;

 EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      fnd_message.set_name ('CS', 'CS_INVALID_INSTALL_SITE');
      fnd_message.set_token('INSTALL_SITE_ID',  p_install_site_id);
      fnd_message.set_token('CUSTOMER_PRODUCT_ID',   p_customer_product_id);
	  fnd_msg_pub.add;

   WHEN OTHERS THEN
        fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
        fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
        fnd_msg_pub.add;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END CP_INSTALL_SITE_CROSS_VAL;


-- KP API Cleanup
-- Introduced the res. code cross val proc. for 11.5.10
-- Validate the resolution code to confirm that it is a valid RC for the
-- given mapping criteria: inventory_item_id, incident_type, category_id
-- and problem code
-- Invoke the res. code validation API:
--       cs_sr_res_code_mapping_pkg.vaidate_resolution_code

PROCEDURE Resolution_Code_Cross_Val (
   p_parameter_name                 IN  VARCHAR2,
   p_resolution_code                IN  VARCHAR2,
   p_problem_code                   IN  VARCHAR2,
   p_incident_type_id               IN  NUMBER,
   p_category_id                    IN  NUMBER,
   p_inventory_item_id              IN  NUMBER,
   p_inventory_org_id               IN  NUMBER,
   x_return_status                  OUT NOCOPY VARCHAR2  )
IS
  l_dummy 	VARCHAR2(1);
  l_api_name       CONSTANT VARCHAR2(30)    := 'resolution_code_cross_val';
  l_api_name_full  CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

  l_rc_rec         cs_sr_res_code_mapping_pkg.rescode_search_rec;
  lx_msg_count     NUMBER;
  lx_msg_data      VARCHAR2(2000);

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- populate the res. code record type

   l_rc_rec.service_request_type_id := p_incident_type_id;
   l_rc_rec.inventory_item_id       := p_inventory_item_id;
   l_rc_rec.organization_id         := p_inventory_org_id;
   l_rc_rec.product_category_id     := p_category_id;
   l_rc_rec.problem_code            := p_problem_code;

   cs_sr_res_code_mapping_pkg.validate_resolution_code (
      p_api_version            => 1.0,
      p_init_msg_list          => FND_API.G_TRUE,
      p_rescode_criteria_rec   => l_rc_rec,
      p_resolution_code        => p_resolution_code,
      x_return_status          => x_return_status,
      x_msg_count              => lx_msg_count,
      x_msg_data               => lx_msg_data );

   if ( x_return_status <> FND_API.G_RET_STS_SUCCESS ) then
      -- new message for 11.5.10
      -- Resolution code is not valid. Please check the values for the following:
      -- Service request type, inventory item, product category and problem code.
      fnd_message.set_name ('CS', 'CS_SR_RES_CODE_INVALID');
      fnd_message.set_token('API_NAME', l_api_name_full );
      fnd_msg_pub.add;
   end if;

EXCEPTION
   WHEN OTHERS THEN
      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
      fnd_msg_pub.add;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Resolution_Code_Cross_Val;

-- KP API Cleanup; added new proc
-- Procedure to be called when SR Status changes. Check if the SR
-- is changed to closed status. If yes then,
-- If there are any open Tasks, with the  restrict_flag set to 'Y''
-- raise error.

PROCEDURE Task_Restrict_Close_Cross_Val(
   p_incident_id          IN   NUMBER,
   p_status_id            IN   NUMBER,
   x_return_status        OUT  NOCOPY VARCHAR2 )
IS
   l_dummy            NUMBER                := 0;
   l_api_name         CONSTANT VARCHAR2(30) := 'TASK_RESTRICT_CLOSE_CROSS_VAL';
   l_api_name_full    CONSTANT VARCHAR2(70) := G_PKG_NAME||'.'||l_api_name;

   l_close_flag         VARCHAR2(10);

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   SELECT close_flag
   INTO   l_close_flag
   FROM   cs_incident_statuses_b
   WHERE  incident_status_id = p_status_id;

   IF ( l_close_flag = 'Y' ) THEN
     SELECT COUNT(*)
     INTO   l_dummy
     FROM   jtf_tasks_b
     WHERE  source_object_id        = p_incident_id
     AND    source_object_type_code = 'SR'
     AND    NVL(open_flag,'Y')      = 'Y'
     AND    restrict_closure_flag   = 'Y'
     AND    NVL(deleted_flag,'N')   = 'N';

      if ( l_dummy > 0 ) then
         x_return_status := FND_API.G_RET_STS_ERROR;
         -- This service request has open dependent tasks. Please close these
         -- tasks before closing the service request.
         fnd_message.set_name ('CS', 'CS_SR_CANNOT_CLOSE_SR');
         fnd_msg_pub.add;
      end if;

   END IF;

EXCEPTION
   WHEN OTHERS THEN
      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
      fnd_msg_pub.add;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END TASK_RESTRICT_CLOSE_CROSS_VAL;

-- KP API Cleanup; added new proc
-- -----------------------------------------------------------------------------
-- Modification History
-- Date     Name     Desc
-- -------- -------- -----------------------------------------------------------
-- 11/15/05 smisra   Bug 4105758 and 4432736
--                   Put validate_contract_line in comments and used
--                   oks_entitlement_pub.get_contract to get list of applicable
--                   contracts and compared input value with the list. If input
--                   is present in the list, contract is valid, otherwise it is
--                   invalid.
-- -------- -------- -----------------------------------------------------------
PROCEDURE CONTRACTS_CROSS_VAL (
   p_parameter_name          IN  VARCHAR2,
   p_contract_service_id     IN  NUMBER,
   p_busiproc_id             IN  NUMBER,
   p_request_date            IN  DATE,
   p_inventory_item_id	     IN  NUMBER,
   p_inv_org_id              IN  NUMBER,
   p_install_site_id	     IN  NUMBER,
   p_customer_product_id     IN  NUMBER,
   p_account_id		     IN  NUMBER,
   p_customer_id	     IN  NUMBER,
   p_system_id               IN  NUMBER,
   x_return_status           OUT NOCOPY varchar2  )
IS
   x_dummy 	         VARCHAR2(1);
   valid_contract_flag   VARCHAR2(1) := 'N';
   l_contract_index      BINARY_INTEGER;

   l_api_name            CONSTANT VARCHAR2(30) := 'contracts_cross_val';
   l_api_name_full       CONSTANT VARCHAR2(70) := G_PKG_NAME||'.'||l_api_name;

   -- Parameter to be used to pass to the contracts API.
   l_covlevel_tbl        OKS_ENTITLEMENTS_PUB.COVLEVEL_TBL_TYPE;
   lx_covlevel_tbl       OKS_ENTITLEMENTS_PUB.COVLEVEL_TBL_TYPE;

   lx_return_status      VARCHAR2(5);
   lx_msg_count          NUMBER;
   lx_msg_data           VARCHAR2(2000);

l_ent_contracts OKS_ENTITLEMENTS_PUB.get_contop_tbl;
px_inp_rec      OKS_ENTITLEMENTS_PUB.get_contin_rec;
l_match_found   BOOLEAN;
BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

  px_inp_rec.contract_number          := NULL;
  px_inp_rec.contract_number_modifier := NULL;
  px_inp_rec.service_line_id          := NULL;
  px_inp_rec.party_id                 := p_customer_id;
  px_inp_rec.site_id                  := p_install_site_id;
  px_inp_rec.cust_acct_id             := p_account_id;
  px_inp_rec.system_id                := p_system_id;
  px_inp_rec.item_id                  := p_inventory_item_id;
  px_inp_rec.product_id               := p_customer_product_id;
  px_inp_rec.request_date             := p_request_date;
  --px_inp_rec.incident_date            := p_incident_occurred_date;
  --px_inp_rec.severity_id              := p_severity_id;
  --px_inp_rec.time_zone_id             := p_time_zone_id;
  px_inp_rec.business_process_id      := p_busiproc_id;
  px_inp_rec.calc_resptime_flag       := 'N';
  px_inp_rec.validate_flag            := 'Y';
  --px_inp_rec.sort_key                 := 'RSN';
  px_inp_rec.dates_in_input_tz        := 'N';

  OKS_ENTITLEMENTS_PUB.get_contracts
  ( p_api_version   => 1.0
  , p_init_msg_list => fnd_api.g_false
  , p_inp_rec       => px_inp_rec
  , x_return_status => x_return_status
  , x_msg_count     => lx_msg_count
  , x_msg_data      => lx_msg_data
  , x_ent_contracts => l_ent_contracts
  );
  IF x_return_status = FND_API.G_RET_STS_SUCCESS
  THEN
    l_match_found := false;
    IF l_ent_contracts.count > 0
    THEN
      FOR loop_indx in l_ent_contracts.FIRST..l_ent_contracts.LAST
      LOOP
        IF p_contract_service_id = l_ent_contracts(loop_indx).service_line_id
        THEN
          l_match_found := true;
          EXIT;
        END IF;
      END LOOP;
    END IF;
    --  if contract is not found in contract list, set return status to Error
    IF l_match_found = false
    THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END IF;

   /*************** when bug 4109990 is fixed, uncomment this part
   l_covlevel_tbl(1).covlevel_code  := 'OKX_COVITEM';
   l_covlevel_tbl(1).covlevel_id    := p_inventory_item_id;
   l_covlevel_tbl(1).inv_org_id     := p_inv_org_id;
   l_covlevel_tbl(1).covered_yn     := 'N';

   l_covlevel_tbl(2).covlevel_code  := 'OKX_CUSTPROD';
   l_covlevel_tbl(2).covlevel_id    := p_customer_product_id;
   l_covlevel_tbl(2).inv_org_id     := NULL;
   l_covlevel_tbl(2).covered_yn     := 'N';

   l_covlevel_tbl(3).covlevel_code  := 'OKX_CUSTACCT';
   l_covlevel_tbl(3).covlevel_id    := p_account_id;
   l_covlevel_tbl(3).inv_org_id     := NULL;
   l_covlevel_tbl(3).covered_yn     := 'N';

   l_covlevel_tbl(4).covlevel_code  := 'OKX_PARTYSITE';
   l_covlevel_tbl(4).covlevel_id    := p_install_site_id;
   l_covlevel_tbl(4).inv_org_id     := NULL;
   l_covlevel_tbl(4).covered_yn     := 'N';

   l_covlevel_tbl(5).covlevel_code  := 'OKX_PARTY';
   l_covlevel_tbl(5).covlevel_id    := p_customer_id;
   l_covlevel_tbl(5).inv_org_id     := NULL;
   l_covlevel_tbl(5).covered_yn     := 'N';

   l_covlevel_tbl(6).covlevel_code  := 'OKX_COVSYST';
   l_covlevel_tbl(6).covlevel_id    := p_system_id;
   l_covlevel_tbl(6).inv_org_id     := NULL;
   l_covlevel_tbl(6).covered_yn     := 'N';

   OKS_ENTITLEMENTS_PUB.VALIDATE_CONTRACT_LINE (
      p_api_version          => 1,
      p_init_msg_list        => FND_API.G_FALSE,
      p_contract_line_id     => p_contract_service_id,
      p_busiproc_id          => p_busiproc_id,
      p_request_date         => p_request_date,
      p_covlevel_tbl_in      => l_covlevel_tbl,
      p_verify_combination   => 'N',
      x_return_status        => lx_return_status  ,
      x_msg_count            => lx_msg_count ,
      x_msg_data             => lx_msg_data,
      x_covlevel_tbl_out     => lx_covlevel_tbl,
      x_combination_valid    => x_dummy) ;

   l_contract_index := lx_covlevel_tbl.FIRST;

   IF ( lx_return_status = FND_API.G_RET_STS_SUCCESS ) then
      WHILE l_contract_index IS NOT NULL LOOP
         IF lx_covlevel_tbl(l_contract_index).covered_yn = 'Y' THEN
            valid_contract_flag := 'Y';
         END IF;
         l_contract_index := lx_covlevel_tbl.NEXT(l_contract_index);
      END LOOP;

      IF valid_contract_flag = 'N' THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         -- new message for 11.5.10
         -- Contract is not valid. Please check the values for the following:
         -- Service request type, inventory item, instance, account and
         -- install site.
         --fnd_message.set_name ('CS', 'CS_SR_CONTRACT_INVALID');
         --fnd_message.set_token('API_NAME', l_api_name_full );
         --fnd_msg_pub.add;
      END IF;
   ELSE     -- For BUG 3665768
         x_return_status := FND_API.G_RET_STS_ERROR;
         --fnd_message.set_name ('CS', 'CS_SR_CONTRACT_INVALID');
         --fnd_message.set_token('API_NAME', l_api_name_full );
         --fnd_msg_pub.add;
   END IF;    -- IF ( lx_return_status = FND_API.G_RET_STS_SUCCESS ) then
   *************** when bug 4109990 is fixed, uncomment this part  *********/

EXCEPTION
   WHEN OTHERS THEN
      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
      fnd_msg_pub.add;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END CONTRACTS_CROSS_VAL;

-- KP API Cleanup; added new proc
-- Procedure to be called when cp_component_id changes. Check if it has
-- has a valid relation with the inv_component_id

PROCEDURE INV_COMPONENT_CROSS_VAL(
   p_parameter_name        IN   VARCHAR2,
   p_inv_component_id      IN   NUMBER,
   p_cp_component_id       IN   NUMBER,
   x_return_status         OUT  NOCOPY VARCHAR2 )
IS
   l_dummy                 VARCHAR2(1);
   l_api_name              CONSTANT VARCHAR2(30) := 'Inv_Component_Cross_Val';
   l_api_name_full         CONSTANT VARCHAR2(70) := G_PKG_NAME||'.'||l_api_name;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   SELECT 'X'
   INTO   l_dummy
   FROM   CSI_ITEM_INSTANCES
   WHERE  INSTANCE_ID        = p_cp_component_id
   AND    INVENTORY_ITEM_ID  = p_inv_component_id;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
   -- For bug 3324210 and 3324179
      x_return_status := FND_API.G_RET_STS_ERROR;
      CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg(
         p_token_an =>  l_api_name_full,
      --   p_token_v  =>  to_char(p_cp_component_id), --3815710
        p_token_v => to_char(p_inv_component_id),
         p_token_p  =>  p_parameter_name );

   WHEN OTHERS THEN
      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
      fnd_msg_pub.add;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END INV_COMPONENT_CROSS_VAL;

-- KP API Cleanup; added new proc
-- Procedure to be called when cp_subcomponent_id changes. Check if it has
-- has a valid relation with the inv_subcomponent_id

PROCEDURE INV_SUBCOMPONENT_CROSS_VAL(
   p_parameter_name                 IN  VARCHAR2,
   p_inv_subcomponent_id            IN  NUMBER,
   p_cp_subcomponent_id             IN  NUMBER,
   x_return_status                  OUT NOCOPY VARCHAR2 )

IS
   l_dummy                      VARCHAR2(1);
   l_api_name                   CONSTANT VARCHAR2(30)    := 'Inv_Subcomponent_Cross_Val';
   l_api_name_full              CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   SELECT 'X' INTO l_dummy
   FROM CSI_ITEM_INSTANCES
   WHERE      INSTANCE_ID = p_cp_subcomponent_id
   AND  INVENTORY_ITEM_ID = p_inv_subcomponent_id;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      -- For bug 3324210 and 3324179
      x_return_status := FND_API.G_RET_STS_ERROR;
      CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg(
         p_token_an =>  l_api_name_full,
         p_token_v  =>  to_char(p_cp_subcomponent_id),
         p_token_p  =>  p_parameter_name );

   WHEN OTHERS THEN
      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
      fnd_msg_pub.add;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END INV_SUBCOMPONENT_CROSS_VAL;

-- where did this requirement come from?
-- security
-- Added new procedure to set the grants depending on the
-- value of the agent security.
-- C for Custom
-- S for Standard
-- N for None
PROCEDURE SETUP_SR_AGENT_SECURITY (
   p_sr_agent_security IN VARCHAR2,
   x_return_status     OUT NOCOPY VARCHAR2 )
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
END SETUP_SR_AGENT_SECURITY;


 -- Added new function if the responsibility has access to
-- the passed SR type

FUNCTION VALIDATE_INCIDENT_ACCESS (
   p_api_name               IN   VARCHAR2,
   p_resp_business_usage    IN   VARCHAR2,
   p_incident_id            IN   NUMBER )
RETURN BOOLEAN
IS

   l_access VARCHAR2(3) := 'N';

BEGIN
   IF p_resp_business_usage = 'AGENT' THEN

      SELECT 'Y'
      INTO l_access
      FROM cs_incidents_b_sec
      WHERE incident_id = p_incident_id;

   ELSE
      l_access := 'Y';
   END IF;

   IF l_access = 'N' THEN
      return false;
   ELSIF l_access = 'Y' THEN
      return true;
   END IF;
EXCEPTION
   when no_data_found then
      return false;
   when others then
      return false;
END VALIDATE_INCIDENT_ACCESS;

-- end for security

-- DJ API Cleanup; added new proc
-- Procedure to be called when either the inv. component or the cp component
-- changes.
--

PROCEDURE CP_COMP_ID_CROSS_VAL (
   p_inv_component_id    IN   NUMBER,
   p_cp_component_id     IN   NUMBER,
   x_return_status       OUT  NOCOPY VARCHAR2 )
IS
   l_dummy             NUMBER := 0;
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   /*
   select 1
   into   l_dummy
   from   csi_item_instances
   where

*/

END CP_COMP_ID_CROSS_VAL;

-- DJ API Cleanup
-- Procedure to disallow SR Type change for the following cases:
-- From EAM to Non Eam
-- From Non Eam to EAM

PROCEDURE VALIDATE_TYPE_CHANGE (
   p_old_eam_type_flag        IN          VARCHAR2,
   p_new_eam_type_flag        IN          VARCHAR2,
   x_return_status            OUT NOCOPY  VARCHAR2 )
IS
   l_api_name_full   VARCHAR2(70) := G_PKG_NAME||'.VALIDATE_TYPE_CHANGE';
BEGIN
   if ( p_old_eam_type_flag <> p_new_eam_type_flag ) then
      x_return_status := FND_API.G_RET_STS_ERROR;

      -- Set different message depending on the nature of the type change
      if ( p_old_eam_type_flag = 'Y' ) then
         -- new message for 11.5.10
         -- The system could not update the Type. The Type cannot be changed from a
         -- Maintenance Type to a non-Maintenance Type.
	 fnd_message.set_name ('CS', 'CS_SR_DISALLOW_TYPE_UPD_1');
	 fnd_message.set_token('API_NAME', l_api_name_full );
	 fnd_msg_pub.add;
      else
	 -- new message for 11.5.10
	 -- The system could not update the Type. The Type cannot be changed from a
	 -- non-Maintenance Type to a Maintenance Type.
	 fnd_message.set_name ('CS', 'CS_SR_DISALLOW_TYPE_UPD_2');
	 fnd_message.set_token('API_NAME', l_api_name_full );
	 fnd_msg_pub.add;
      end if;
   else
      x_return_status := FND_API.G_RET_STS_SUCCESS;
   end if;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.SET_NAME ('CS', 'CS_API_SR_UNKNOWN_ERROR');
      FND_MESSAGE.SET_TOKEN ('P_TEXT',l_api_name_full||'-'||SQLERRM);
      FND_MSG_PUB.ADD;

END VALIDATE_TYPE_CHANGE;


-- KP API Cleanup
-- Service request Cross Val procedure

-- -----------------------------------------------------------------------------
-- Modification History
-- Date     Name     Desc
-- -------- -------- -----------------------------------------------------------
-- 02/28/05 smisra   Bug 4083288
--                   Passed category_set_id to validate_category_id call.
--                   performed validation of category id if category_set_id
--                   is changed
-- 03/25/05 smisra   Bug 4239975 Modified call to validate_current_serial_number.
--                   Now it is called only if both customer product and
--                   current serial number are not null and one of them has
--                   changed.
-- 05/09/05 smisra   add validation of maint_organization_id
--                   used new procedure validation_customer_product_id to
--                   validate customer product. it takes an addtional parameter
--                   maint_organization_id
-- 05/12/05 smisra   removed validation of parameter item_serial_number
-- 08/03/05 smisra   1. added validation for owning dept
--                   2. retrieved inv_org_master_org_flag for inv org
--                   3. passed inv_org_master_org_flag to validate_product,
--                      validate_maint_organization_id,
--                      validate_customer_product_id
-- 08/15/05 smisra   called validate product on when maint org changes
-- 12/23/05 smisra   Bug 4894942
--                   Removed call to contracts_cross_val. Now it is moved to
--                   vldt_sr_rec procedure of PVT API.
-- 12/30/05 smisra   bug 4773215
--                   Removed owner validatation using validate_owner. This validation
--                   is done in vldt_sr_rec of PVT API itself so that resource type
--                   can be derived based on resource id
--                   removed call to validate resource type as it is now being derived
--                   based on resource id
--                   Removed call to validate support site. From now on, it is
--                   derived based onm resource id. Derivation happens in
--                   vldt_Sr_rec of PVT API.
-- -----------------------------------------------------------------------------
PROCEDURE SERVICEREQUEST_CROSS_VAL (
   p_new_sr_rec          IN   cs_servicerequest_pvt.service_request_rec_type,
   p_old_sr_rec          IN   cs_servicerequest_pvt.sr_oldvalues_rec_type,
   x_cross_val_out_rec   OUT  NOCOPY sr_cross_val_out_rec_type,
   x_return_status       OUT  NOCOPY VARCHAR2 )
IS
   lx_return_status    VARCHAR2(1);
   l_api_name_full     VARCHAR2(70) := G_PKG_NAME||'.SERVICEREQUEST_CROSS_VAL';

   -- Local variables used to store the value that is passed to the cross val
   -- procedures. This values is populated with the new value if passed, or if
   -- G_MISS_XXX is passed, the old values is retrieved and passed
   l_problem_code      VARCHAR2(30);
   l_res_code          VARCHAR2(30);
   l_sr_type_id        NUMBER;
   l_inv_item_id       NUMBER;
   l_inv_org_id        NUMBER;
   l_category_id       NUMBER;
   l_cont_srv_id       NUMBER; -- contract service id
   l_busi_proc_id      NUMBER; -- business process id
   l_request_date      DATE;
   l_inst_site_id      NUMBER; -- install site id
   l_cust_prod_id      NUMBER;
   l_account_id        NUMBER;
   l_customer_id       NUMBER;
   l_system_id         NUMBER;
   l_status_id         NUMBER;
   l_inc_loc_id        NUMBER; -- incident location id
   l_inc_loc_type      VARCHAR2(30);  -- incident location type  9/19 changes
   l_owner_id          NUMBER;
   l_group_type        VARCHAR2(240);
   l_owner_grp_id      NUMBER; -- owner group id
   l_maint_flag        VARCHAR2(10); -- EAM flag for SR Type
   -- 3303078
   l_inv_item_rev      VARCHAR2(240); --NUMBER;  -- inventory item revision
   l_inv_comp_id       NUMBER;  -- inventory component id
   l_cp_comp_id        NUMBER;
   l_cp_comp_ver       VARCHAR2(3); --NUMBER; -- cp component version
   l_sup_site_id       NUMBER;  -- support site id
   l_res_type          VARCHAR2(240); -- resource type
   l_bto_site_id       NUMBER;  -- bill to site id
   l_bto_party_id      NUMBER;  -- bill to party id
   l_sto_site_id       NUMBER;  -- ship to site id
   l_sto_party_id      NUMBER;  -- ship to party id
   l_bto_cont_id       NUMBER;  -- bill to contact id
   l_sto_cont_id       NUMBER;  -- ship to contact id
   l_cust_type         VARCHAR2(240); -- customer type
   l_bto_acc_id        NUMBER;  -- bill to account id
   l_sto_acc_id        NUMBER;  -- ship to account id
   l_external_ref      VARCHAR2(240); -- external reference
   l_prod_revision     VARCHAR2(240); -- inv. item revision
   l_cur_serial        VARCHAR2(240); -- current serial number
   l_inv_subcomp_id       NUMBER;        -- inv. subcomponent id
   l_cp_subcomp_id        NUMBER;        -- cp. subcomponent id
   l_inv_comp_ver      VARCHAR2(240); -- inv. component version
   l_inv_scomp_id      NUMBER; -- inv. subcomponent id
   l_inv_scomp_ver     VARCHAR2(240); -- inv. subcomponent version
   l_cat_set_id        NUMBER; -- category set id
   l_bto_site_use      NUMBER; -- bill to site use id
   l_sto_site_use      NUMBER; -- ship to site use id
   l_cp_scomp_id       NUMBER; -- cp subcomponent id
   l_cp_scomp_ver      VARCHAR2(3);  --NUMBER; -- cp subcomponent version

   lx_owner_name       VARCHAR2(240); -- used in validate_owner
   lx_owner_id         NUMBER;        -- used in validate_owner
   lx_site_use_id      NUMBER;        -- used in validate_bill_to_ship_to_site

 -- 3224828 contracts
   l_contract_id       NUMBER; -- contract id
   l_con_number        cs_incidents_all_b.contract_number % type;

 -- 3340433
   l_inv_change_by_cp  VARCHAR2(1):= 'N'; --set when inv_item_id is overwritten by cp
   l_inv_id_from_cp    NUMBER;
 -- 3360274
   l_resource_type     VARCHAR2(240); -- used in validate_resource_type

l_inv_org_master_org_flag VARCHAR2(1);
l_maint_organization_id   cs_incidents_all_b.maint_organization_id % TYPE;
l_owning_dept_id          cs_incidents_all_b.owning_department_id  % TYPE;

BEGIN
   -- Initialize return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Fetch the values that need to be used in the validation procedures. If the
   -- value is passed to the API, then use the passed in value, if not, use the
   -- existing DB value

   l_problem_code := get_right_char(
                        p_new_char_value => p_new_sr_rec.problem_code,
                        p_old_char_value => p_old_sr_rec.problem_code);
   l_sr_type_id   := get_right_num(
                        p_new_num_value  => p_new_sr_rec.type_id,
                        p_old_num_value  => p_old_sr_rec.incident_type_id);
   l_inv_item_id  := get_right_num(
                        p_new_num_value  => p_new_sr_rec.inventory_item_id,
                        p_old_num_value  => p_old_sr_rec.inventory_item_id);
   l_inv_org_id   := get_right_num(
                        p_new_num_value => p_new_sr_rec.inventory_org_id,
                        p_old_num_value => p_old_sr_rec.inv_organization_id);
   l_category_id  := get_right_num(
                        p_new_num_value => p_new_sr_rec.category_id,
                        p_old_num_value => p_old_sr_rec.category_id);
   l_res_code     := get_right_char(
                        p_new_char_value => p_new_sr_rec.resolution_code,
                        p_old_char_value => p_old_sr_rec.resolution_code);
   l_cont_srv_id  := get_right_num(
                        p_new_num_value  => p_new_sr_rec.contract_service_id,
                        p_old_num_value  => p_old_sr_rec.contract_service_id);
   l_request_date := get_right_date(
                        p_new_date_value  => p_new_sr_rec.request_date,
                        p_old_date_value  => p_old_sr_rec.incident_date);
   l_inst_site_id := get_right_num(
                        p_new_num_value  => p_new_sr_rec.install_site_id,
                        p_old_num_value  => p_old_sr_rec.install_site_id);
   l_cust_prod_id := get_right_num(
                        p_new_num_value  => p_new_sr_rec.customer_product_id,
                        p_old_num_value  => p_old_sr_rec.customer_product_id);
   l_account_id   := get_right_num(
                        p_new_num_value  => p_new_sr_rec.account_id,
                        p_old_num_value  => p_old_sr_rec.account_id);
   l_customer_id  := get_right_num(
                        p_new_num_value  => p_new_sr_rec.customer_id,
                        p_old_num_value  => p_old_sr_rec.customer_id);
   l_system_id    := get_right_num(
                        p_new_num_value  => p_new_sr_rec.system_id,
                        p_old_num_value  => p_old_sr_rec.system_id);
   l_status_id    := get_right_num(
                        p_new_num_value  => p_new_sr_rec.status_id,
                        p_old_num_value  => p_old_sr_rec.incident_status_id);
   l_inc_loc_id   := get_right_num(
                        p_new_num_value  => p_new_sr_rec.incident_location_id,
                        p_old_num_value  => p_old_sr_rec.incident_location_id);
   l_inc_loc_type   := get_right_char(
                        p_new_char_value  => p_new_sr_rec.incident_location_type,
                        p_old_char_value  => p_old_sr_rec.incident_location_type);
   l_owner_id     := get_right_num(
                        p_new_num_value  => p_new_sr_rec.owner_id,
                        p_old_num_value  => p_old_sr_rec.incident_owner_id);
   l_group_type   := get_right_char(
                        p_new_char_value => p_new_sr_rec.group_type,
                        p_old_char_value => p_old_sr_rec.group_type);
   l_owner_grp_id := get_right_num(
                        p_new_num_value  => p_new_sr_rec.owner_group_id,
                        p_old_num_value  => p_old_sr_rec.owner_group_id);
   l_maint_flag   := get_right_char(
                        p_new_char_value => p_new_sr_rec.new_type_maintenance_flag,
                        p_old_char_value => p_new_sr_rec.old_type_maintenance_flag);
   l_inv_item_rev := get_right_char(
                        p_new_char_value  => p_new_sr_rec.inv_item_revision,
                        p_old_char_value  => p_old_sr_rec.inv_item_revision);
   l_inv_comp_id  := get_right_num(
                        p_new_num_value  => p_new_sr_rec.inv_component_id,
                        p_old_num_value  => p_old_sr_rec.inv_component_id);
   l_cp_comp_id   := get_right_num(
                        p_new_num_value  => p_new_sr_rec.cp_component_id,
                        p_old_num_value  => p_old_sr_rec.cp_component_id);
   l_cp_comp_ver  := get_right_char(
                        p_new_char_value  => p_new_sr_rec.component_version,
                        p_old_char_value  => p_old_sr_rec.component_version);
   l_sup_site_id  := get_right_num(
                        p_new_num_value  => p_new_sr_rec.site_id,
                        p_old_num_value  => p_old_sr_rec.site_id);
   l_res_type     := get_right_char(
                        p_new_char_value => p_new_sr_rec.resource_type,
                        p_old_char_value => p_old_sr_rec.resource_type);
   l_bto_site_id := get_right_num(
                        p_new_num_value  => p_new_sr_rec.bill_to_site_id,
                        p_old_num_value  => p_old_sr_rec.bill_to_site_id);
   l_bto_party_id:= get_right_num(
                        p_new_num_value  => p_new_sr_rec.bill_to_party_id,
                        p_old_num_value  => p_old_sr_rec.bill_to_party_id);
   l_sto_site_id := get_right_num(
                        p_new_num_value  => p_new_sr_rec.ship_to_site_id,
                        p_old_num_value  => p_old_sr_rec.ship_to_site_id);
   l_sto_party_id:= get_right_num(
                        p_new_num_value  => p_new_sr_rec.ship_to_party_id,
                        p_old_num_value  => p_old_sr_rec.ship_to_party_id);
   l_bto_cont_id  := get_right_num(
                        p_new_num_value  => p_new_sr_rec.bill_to_contact_id,
                        p_old_num_value  => p_old_sr_rec.bill_to_contact_id);
   l_cust_type    := get_right_char(
                        p_new_char_value => p_new_sr_rec.caller_type,
                        p_old_char_value => p_old_sr_rec.caller_type);
   l_sto_cont_id  := get_right_num(
                        p_new_num_value  => p_new_sr_rec.ship_to_contact_id,
                        p_old_num_value  => p_old_sr_rec.ship_to_contact_id);
   l_bto_acc_id   := get_right_num(
                        p_new_num_value  => p_new_sr_rec.bill_to_account_id,
                        p_old_num_value  => p_old_sr_rec.bill_to_account_id);
   l_sto_acc_id   := get_right_num(
                        p_new_num_value  => p_new_sr_rec.ship_to_account_id,
                        p_old_num_value  => p_old_sr_rec.ship_to_account_id);
   l_external_ref := get_right_char(
                        p_new_char_value => p_new_sr_rec.external_reference,
                        p_old_char_value => p_old_sr_rec.external_reference);
   l_prod_revision:= get_right_char(
                        p_new_char_value => p_new_sr_rec.product_revision,
                        p_old_char_value => p_old_sr_rec.product_revision);
   l_cur_serial   := get_right_char(
                        p_new_char_value => p_new_sr_rec.current_serial_number,
                        p_old_char_value => p_old_sr_rec.current_serial_number);
   l_inv_subcomp_id  := get_right_num(
                        p_new_num_value  => p_new_sr_rec.inv_subcomponent_id,
                        p_old_num_value  => p_old_sr_rec.inv_subcomponent_id);
   l_cp_subcomp_id   := get_right_num(
                        p_new_num_value  => p_new_sr_rec.cp_subcomponent_id,
                        p_old_num_value  => p_old_sr_rec.cp_subcomponent_id);
   l_inv_comp_ver := get_right_char(
                        p_new_char_value => p_new_sr_rec.inv_component_version,
                        p_old_char_value => p_old_sr_rec.inv_component_version);
   l_inv_scomp_id := get_right_num(
                        p_new_num_value  => p_new_sr_rec.inv_subcomponent_id,
                        p_old_num_value  => p_old_sr_rec.inv_subcomponent_id);
   l_inv_scomp_ver:= get_right_char(
                        p_new_char_value => p_new_sr_rec.inv_subcomponent_version,
                        p_old_char_value => p_old_sr_rec.inv_subcomponent_version );
   l_cat_set_id   := get_right_num(
                        p_new_num_value  => p_new_sr_rec.category_set_id,
                        p_old_num_value  => p_old_sr_rec.category_set_id);
   l_cp_scomp_id  := get_right_num(
                        p_new_num_value  => p_new_sr_rec.cp_subcomponent_id,
                        p_old_num_value  => p_old_sr_rec.cp_subcomponent_id);
   l_bto_site_use := get_right_num(
                        p_new_num_value  => p_new_sr_rec.bill_to_site_use_id,
                        p_old_num_value  => p_old_sr_rec.bill_to_site_use_id);
   l_sto_site_use := get_right_num(
                        p_new_num_value  => p_new_sr_rec.ship_to_site_use_id,
                        p_old_num_value  => p_old_sr_rec.ship_to_site_use_id);
   l_cp_scomp_ver := get_right_char(
                        p_new_char_value  => p_new_sr_rec.subcomponent_version,
                        p_old_char_value  => p_old_sr_rec.subcomponent_version);
   l_maint_organization_id := get_right_num(
                        p_new_num_value  => p_new_sr_rec.maint_organization_id,
                        p_old_num_value  => p_old_sr_rec.maint_organization_id);
   l_owning_dept_id     := get_right_num
                           ( p_new_num_value  => p_new_sr_rec.owning_dept_id
                           , p_old_num_value  => p_old_sr_rec.owning_department_id
                           );

   -- 3224898 contracts
   l_contract_id := get_right_num(
                       p_new_num_value  => p_new_sr_rec.contract_id,
		       p_old_num_value  => p_old_sr_rec.contract_id);
   l_resource_type := get_right_char(
                        p_new_char_value  => p_new_sr_rec.resource_type,
                        p_old_char_value  => p_old_sr_rec.resource_type);



-- Start the cross validation checks and call outs
  -- this is done to inv_org_master_org_flag for further validation
  IF l_inv_org_id IS NOT NULL
  THEN
    CS_ServiceRequest_UTIL.Validate_Inventory_Org
    ( p_api_name                => 'CS_SERVICEREQUEST_UTIL.servicerequest_cross_val'
    , p_parameter_name          => 'Inventory Organization'
    , p_inv_org_id              => l_inv_org_id
    , x_inv_org_master_org_flag => l_inv_org_master_org_flag
    , x_return_status           => lx_return_status
    );
  END IF;
  -- validate maintenance organization id
  IF l_maint_organization_id IS NOT NULL AND
     (l_maint_organization_id <> NVL(p_old_sr_rec.maint_organization_id,-1) OR
     NVL(l_inv_org_id,-1) <> NVL(p_old_sr_rec.inv_organization_id,-1) )
  THEN
    validate_maint_organization_id
    ( p_maint_organization_id   => l_maint_organization_id
    , p_inventory_org_id        => l_inv_org_id
    , p_inv_org_master_org_flag => l_inv_org_master_org_flag
    , x_return_status           => lx_return_status
    );
    IF (lx_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  END IF;
  --
  IF l_owning_dept_id IS NOT NULL AND
     (l_owning_dept_id                <> NVL(p_old_sr_rec.owning_department_id ,-9) OR
      NVL(l_maint_organization_id,-9) <> NVL(p_old_sr_rec.maint_organization_id,-9))
  THEN
    CS_ServiceRequest_UTIL.Validate_Owning_department
    ( p_api_name         => 'CS_SERVICEREQUEST_UTIL.validate_owning_department',
      p_parameter_name   => 'Owning Department',
      p_inv_org_id       => l_maint_organization_id,
      p_owning_dept_id   => l_owning_dept_id,
      p_maintenance_flag => l_maint_flag,
      x_return_status    => lx_return_status
    );
    IF (lx_return_status <> FND_API.G_RET_STS_SUCCESS)
    THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  END IF;
  --
/* For bug 3340433 - moved validate_product and validate_customer_product
before the validations which uses inventory_item_id */
-- Inventory item cross validation
    IF  ((p_new_sr_rec.inventory_org_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.inventory_org_id,-99) <>
			       nvl(p_old_sr_rec.inv_organization_id,-99)))
     OR
       ((p_new_sr_rec.inventory_item_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.inventory_item_id,-99) <>
			       nvl(p_old_sr_rec.inventory_item_id,-99)))
     OR
	  ((p_new_sr_rec.customer_product_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.customer_product_id,-99) <>
			       nvl(p_old_sr_rec.customer_product_id,-99))) OR
       NVL(l_maint_organization_id,-99) <> NVL(p_old_sr_rec.maint_organization_id,-99)
   THEN
     if (l_inv_item_id IS NOT NULL and l_inv_item_id <> FND_API.G_MISS_NUM) then
       VALIDATE_PRODUCT (
         p_api_name             => NULL,
         p_parameter_name       => 'inventory_item_id',
         p_inventory_item_id    => l_inv_item_id,
         p_inventory_org_id     => l_inv_org_id,
         p_maintenance_flag     => l_maint_flag,
         p_maint_organization_id => l_maint_organization_id,
         p_inv_org_master_org_flag => l_inv_org_master_org_flag,
         x_return_status        => lx_return_status );

      IF (lx_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;
     END IF;
   END IF; -- validate inventory item end if




---  Validate customer product
   IF l_cust_prod_id IS NOT NULL AND
      ( l_cust_prod_id        <> NVL(p_old_sr_rec.customer_product_id,-1) OR
        NVL(l_inv_item_id,-1) <> NVL(p_old_sr_rec.inventory_item_id  ,-1) OR
        NVL(l_inv_org_id ,-1) <> NVL(p_old_sr_rec.inv_organization_id,-1) OR
        NVL(l_maint_organization_id,-1) <> NVL(p_old_sr_rec.maint_organization_id,-1))
   THEN
      validate_customer_product_id
      ( p_customer_product_id   => l_cust_prod_id
      , p_customer_id           => l_customer_id
      , p_inventory_item_id     => l_inv_id_from_cp
      , p_inventory_org_id      => l_inv_org_id
      , p_maint_organization_id => l_maint_organization_id
      , p_inv_org_master_org_flag => l_inv_org_master_org_flag
      , x_return_status         => lx_return_status
      );

      IF (lx_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;

     -- For bug 3340433
      if (nvl(l_inv_id_from_cp,-99) <> nvl(l_inv_item_id,-99) ) then
     -- For bug 3586812
       IF l_inv_item_id IS NOT NULL THEN
	       Add_Param_Ignored_Msg(
	           p_token_an  => l_api_name_full,
		       p_token_ip  => 'p_inventory_item_id' );
       END IF;
          l_inv_item_id := l_inv_id_from_cp;
          l_inv_change_by_cp := 'Y';
      end if;

   END IF;  -- validate customer product end if



-- Problem code cross validation
-- Validate problem code if any of the following changes: type, category or
-- item
   IF ((p_new_sr_rec.type_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.type_id,-99) <>
			       nvl(p_old_sr_rec.incident_type_id,-99)))
     OR
       ((p_new_sr_rec.problem_code <> FND_API.G_MISS_CHAR) AND
       (nvl(p_new_sr_rec.problem_code,-99) <>
                               nvl(p_old_sr_rec.problem_code,-99)))
     OR
      ((p_new_sr_rec.category_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.category_id,-99) <>
			       nvl(p_old_sr_rec.category_id,-99)))
     OR
      ((p_new_sr_rec.inventory_item_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.inventory_item_id,-99) <>
			       nvl(p_old_sr_rec.inventory_item_id,-99)))
    OR ( l_inv_change_by_cp = 'Y')
   THEN
      if ( l_problem_code IS NOT NULL and l_problem_code <> FND_API.G_MISS_CHAR ) then
         VALIDATE_PROBLEM_CODE (
            p_api_name             => NULL,
            p_parameter_name       => 'problem code',
            p_problem_code         => l_problem_code,
            p_incident_type_id     => l_sr_type_id,
            p_inventory_item_id    => l_inv_item_id,
	        p_inventory_org_id     => l_inv_org_id,
            p_category_id          => l_category_id,
            x_return_status        => lx_return_status );

         IF (lx_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            RETURN;
         END IF;
      END IF;   -- if ( l_problem_code IS NULL or l_problem_code <> FND_API
   END IF;  -- validate proble code end if

-- Resolution code cross validation
-- Validat resolution code if any of the following changes: type, category,
-- item or problem code
   IF ((p_new_sr_rec.type_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.type_id,-99) <>
			       nvl(p_old_sr_rec.incident_type_id,-99)))
     OR
      ((p_new_sr_rec.category_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.category_id,-99) <>
			       nvl(p_old_sr_rec.category_id,-99)))
     OR
      ((p_new_sr_rec.inventory_item_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.inventory_item_id,-99) <>
			       nvl(p_old_sr_rec.inventory_item_id,-99)))
     OR
      ((p_new_sr_rec.problem_code <> FND_API.G_MISS_CHAR) AND
       (nvl(p_new_sr_rec.problem_code,-99) <>
			       nvl(p_old_sr_rec.problem_code,-99)))
     OR
      ((p_new_sr_rec.resolution_code <> FND_API.G_MISS_CHAR) AND
       (nvl(p_new_sr_rec.resolution_code,-99) <>
                               nvl(p_old_sr_rec.resolution_code,-99)))
     OR ( l_inv_change_by_cp = 'Y')
   THEN

      if ( l_res_code IS NOT NULL and l_res_code <> FND_API.G_MISS_CHAR ) then
         RESOLUTION_CODE_CROSS_VAL (
            p_parameter_name       => 'problem code',
            p_resolution_code      => l_res_code,
            p_problem_code         => l_problem_code,
            p_incident_type_id     => l_sr_type_id,
            p_category_id          => l_category_id,
            p_inventory_item_id    => l_inv_item_id,
            p_inventory_org_id     => l_inv_org_id,
            x_return_status        => lx_return_status );

         IF (lx_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            RETURN;
         END IF;
      END IF;  -- if ( l_res_code IS NOT NULL or l_res_code <> FND_API

   END IF;  -- validate resolution code end if

-- contracts cross val
-- Validate contract if any one of the following changes: type, install site,
-- inv. item, customer product, account, customer or system
-- Need to perform the validation only if there is a value for the contract
-- service id. That is the reason the if condition has the contract service
-- id check as well
   x_cross_val_out_rec.contract_service_id_valid := 'Y';
   /* smisra 12/20/05 Bug 4894942
   Now this validation is called from vldt_sr_rec
   IF ((nvl(p_new_sr_rec.install_site_id,-99) <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.install_site_id,-99) <>
			       nvl(p_old_sr_rec.install_site_id,-99)))
     OR
      ((p_new_sr_rec.type_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.type_id,-99) <>
			       nvl(p_old_sr_rec.incident_type_id,-99)))
     OR
      ((nvl(p_new_sr_rec.inventory_item_id,-99) <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.inventory_item_id,-99) <>
			       nvl(p_old_sr_rec.inventory_item_id,-99)))
     OR
      ((nvl(p_new_sr_rec.customer_product_id,-99) <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.customer_product_id,-99) <>
			       nvl(p_old_sr_rec.customer_product_id,-99)))
     OR
      ((nvl(p_new_sr_rec.account_id,-99) <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.account_id,-99) <> nvl(p_old_sr_rec.account_id,-99)))
     OR
      ((p_new_sr_rec.customer_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.customer_id,-99) <> nvl(p_old_sr_rec.customer_id,-99)))
     OR
      ((nvl(p_new_sr_rec.system_id,-99) <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.system_id,-99) <> nvl(p_old_sr_rec.system_id,-99)))
     -- 3224898 contracts
     OR
      ((nvl(p_new_sr_rec.contract_id,-99) <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.contract_id,-99) <> nvl(p_old_sr_rec.contract_id,-99)))
     OR
       ((nvl(p_new_sr_rec.contract_service_id,-99) <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.contract_service_id,-99) <> nvl(p_old_sr_rec.contract_service_id,-99)))
     OR ( l_inv_change_by_cp = 'Y')
   THEN
      lx_return_status := FND_API.G_RET_STS_SUCCESS;

      if ( l_cont_srv_id IS NOT NULL and l_cont_srv_id <> FND_API.G_MISS_NUM ) then
         begin
            select business_process_id
            into   l_busi_proc_id
            from   cs_incident_types_b
            where  incident_type_id = l_sr_type_id;
         exception
            when no_data_found then
              raise fnd_api.g_exc_unexpected_error;
	      -- Invalid type. Given type is either end dated or does not exist
	      -- as a valid type.
              fnd_message.set_name ('CS', 'CS_SR_INVALID_TYPE');
	      fnd_message.set_token('API_NAME', l_api_name_full);
              fnd_msg_pub.ADD;
	      lx_return_status := FND_API.G_RET_STS_ERROR;
         end;

	 if ( lx_return_status = FND_API.G_RET_STS_SUCCESS ) then

	    -- 3224898 contracts
	     Validate_Contract_Service_Id(
                        p_api_name            => l_api_name_full,
                        p_parameter_name      => 'p_contract_service_id',
                        p_contract_service_id => l_cont_srv_id,
                        x_contract_id         => l_contract_id,
                        x_contract_number     => l_con_number,
                        x_return_status       => lx_return_status);

              IF (lx_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                -- x_return_status := FND_API.G_RET_STS_ERROR;
                 x_cross_val_out_rec.contract_service_id_valid := 'N';
                -- RETURN;
              ELSE
	        x_cross_val_out_rec.contract_id := l_contract_id;
	        x_cross_val_out_rec.contract_number := l_con_number;
                CONTRACTS_CROSS_VAL (
                   p_parameter_name          => 'contract_service_id',
                   p_contract_service_id     => l_cont_srv_id,
                   p_busiproc_id           => l_busi_proc_id,
                   p_request_date          => l_request_date,
                   p_inventory_item_id     => l_inv_item_id,
                   p_inv_org_id            => l_inv_org_id,
                   p_install_site_id       => l_inst_site_id,
                   p_customer_product_id   => l_cust_prod_id,
                   p_account_id            => l_account_id,
                   p_customer_id           => l_customer_id,
	           p_system_id             => l_system_id,
                   x_return_status         => lx_return_status );


                IF (lx_return_status <> FND_API.G_RET_STS_SUCCESS)
                THEN
                  --x_return_status := FND_API.G_RET_STS_ERROR;
                  lx_return_status  := FND_API.G_RET_STS_SUCCESS;
	          x_cross_val_out_rec.contract_service_id_valid := 'N';
	          x_cross_val_out_rec.contract_id               := NULL;
	          x_cross_val_out_rec.contract_number           := NULL;
                  --RETURN;
                END IF;
              END IF; -- end of else after validate_contract_service_id procedure
	 END IF; -- if ( lx_return_status = FND_API.G_RET_STS_SUCCESS ) then Business process process id else
      END IF;  --  if ( l_cont_srv_ind IS NOT NULL or l_cont_srv_ind
   END IF;  -- validate contracts end if
   *********/

-- Tasks restrict close cross val
-- When closing a SR, if there are any open tasks with the task restrict
-- closure flag set to Y, then do not allow the closure of the SR.
   IF ( p_new_sr_rec.status_id <> FND_API.G_MISS_NUM ) AND
      ( nvl(p_new_sr_rec.status_id,-99) <>
			      nvl(p_old_sr_rec.incident_status_id,-99) )
   THEN

      TASK_RESTRICT_CLOSE_CROSS_VAL (
         p_incident_id           => p_old_sr_rec.incident_id,
         p_status_id             => l_status_id,
         x_return_status         => lx_return_status );
   END IF;

   IF (lx_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
   END IF;

-- Incident Location cross val
-- 9/19 changes.
/* Commented out , as the SR UI , nor other UI's are doing this validation

   IF ( p_new_sr_rec.incident_location_id <> FND_API.G_MISS_NUM ) AND
      (nvl(p_new_sr_rec.incident_location_id,-99) <>
				   nvl(p_old_sr_rec.incident_location_id,-99))
     OR
      ((p_new_sr_rec.customer_product_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.customer_product_id,-99) <>
			       nvl(p_old_sr_rec.customer_product_id,-99)))
   THEN
      IF l_cust_prod_id <> NULL THEN

         CP_INCIDENT_SITE_CROSS_VAL (
            p_parameter_name        => 'incident_location_id',
            p_incident_location_id  => l_inc_loc_id,
            p_customer_product_id   => l_cust_prod_id,
            x_return_status         => lx_return_status );
     ELSE

          Validate_Inc_Location_Id  (
            p_api_name               => NULL,
            p_parameter_name         => 'incident_location_id',
            p_incident_location_id   => p_new_sr_rec.incident_location_id,
            p_incident_location_type => l_inc_loc_type,
            x_return_status          => lx_return_status );

     END IF;
   END IF;

   IF (lx_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
   END IF;
*/

--- Install site cross val

   IF ( p_new_sr_rec.install_site_id <> FND_API.G_MISS_NUM ) AND
      (nvl(p_new_sr_rec.install_site_id,-99) <>
				   nvl(p_old_sr_rec.install_site_id,-99))
     OR
      ((p_new_sr_rec.customer_product_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.customer_product_id,-99) <>
			       nvl(p_old_sr_rec.customer_product_id,-99)))
   THEN
     -- For bug 3342410 - included the cust_prod_id check
     if ( l_inst_site_id IS NOT NULL and l_inst_site_id <> FND_API.G_MISS_NUM )AND
         ( l_cust_prod_id IS NOT NULL and l_cust_prod_id <> FND_API.G_MISS_NUM) then
      CP_INSTALL_SITE_CROSS_VAL (
         p_parameter_name        => 'install site id',
         p_install_site_id       => l_inst_site_id,
         p_customer_product_id   => l_cust_prod_id,
         x_return_status         => lx_return_status );
   END IF;
  END IF;
   IF (lx_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
   END IF;

-- Task owner cross val. When SR Type changes, return back a warning message
-- that the change may invalidate some task owners.
   IF ((p_new_sr_rec.type_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.type_id,-99) <>
			       nvl(p_old_sr_rec.incident_type_id,-99)))
   THEN

      TASK_OWNER_CROSS_VAL (
         p_incident_id        => p_old_sr_rec.incident_id,
         x_return_status      => lx_return_status );

      IF (lx_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;
   END IF; -- task owner cross val



-- Inventory item revision cross val
-- Validate item revision when any of the following changes: item
-- 3303078 inv_item_revision should be G_MISS_CHAR
   IF ((p_new_sr_rec.inventory_item_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.inventory_item_id,-99) <>
			       nvl(p_old_sr_rec.inventory_item_id,-99)))
     OR
       ((p_new_sr_rec.inv_item_revision <> FND_API.G_MISS_CHAR) AND
       (nvl(p_new_sr_rec.inv_item_revision,-99) <>
			       nvl(p_old_sr_rec.inv_item_revision,-99)))
     OR ( l_inv_change_by_cp = 'Y')

   THEN
     if ( l_inv_item_rev IS NOT NULL and l_inv_item_rev <> FND_API.G_MISS_CHAR ) then
      VALIDATE_INV_ITEM_REV (
         p_api_name             => NULL,
         p_parameter_name       => 'inventory item revision',
         p_inv_item_revision    => l_inv_item_rev,
         p_inventory_item_id    => l_inv_item_id,
         p_inventory_org_id     => l_inv_org_id,
         x_return_status        => lx_return_status );

      IF (lx_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;
    END IF;
   END IF;  -- validate item revision end if

---  inventory component  validation

   IF ((p_new_sr_rec.inventory_item_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.inventory_item_id,-99) <>
			       nvl(p_old_sr_rec.inventory_item_id,-99)))
     OR
      ((p_new_sr_rec.inv_component_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.inv_component_id,-99) <>
			       nvl(p_old_sr_rec.inv_component_id,-99)))
     OR ( l_inv_change_by_cp = 'Y')
   THEN


     if ( l_inv_comp_id IS NOT NULL and l_inv_comp_id <> FND_API.G_MISS_NUM ) then
      VALIDATE_INV_COMP_ID (
         p_api_name             => NULL,
         p_parameter_name       => 'inventory component id',
         p_inv_component_id     => l_inv_comp_id,
         p_inventory_item_id    => l_inv_item_id,
         p_inventory_org_id     => l_inv_org_id,
         x_return_status        => lx_return_status );

      IF (lx_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;
    END IF;
   END IF;  -- validate item component end if

   -- Validate inv subcomponent smisra 12/21/03
   -- Made changes as one of the condition was missed out. On update even when the
   -- inv subsomp id had null the API will validate it. corected the code for this.

   IF ((p_new_sr_rec.inv_subcomponent_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.inv_subcomponent_id, -99) <>
	                   nvl(p_old_sr_rec.inv_subcomponent_id,-99)))
      OR
      ((p_new_sr_rec.inv_component_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.inv_component_id,-99) <>
	                   nvl(p_old_sr_rec.inv_component_id,-99)))
      OR
      ((p_new_sr_rec.inventory_org_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.inventory_org_id,-99) <>
			       nvl(p_old_sr_rec.inv_organization_id,-99)))
        THEN

     if ( l_inv_subcomp_id IS NOT NULL and l_inv_subcomp_id <> FND_API.G_MISS_NUM ) then

       CS_ServiceRequest_UTIL.Validate_Inv_SubComp_Id(
         p_api_name            => NULL,
         p_parameter_name      => 'p_inv_subcomponent_id',
         p_inventory_org_id    => l_inv_org_id,
         p_inv_subcomponent_id => l_inv_subcomp_id,
         p_inv_component_id    => l_inv_comp_id,
         x_return_status       => lx_return_status );

     IF (lx_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       RETURN;
     END IF;
    END IF;
   END IF;



---    Validate CP component id
   IF ((p_new_sr_rec.inv_component_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.inv_component_id,-99) <>
			       nvl(p_old_sr_rec.inv_component_id,-99)))
	OR ((p_new_sr_rec.cp_component_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.cp_component_id,-99) <>
			       nvl(p_old_sr_rec.cp_component_id,-99)))
   THEN
     if ( l_cp_comp_id IS NOT NULL and l_cp_comp_id <> FND_API.G_MISS_NUM ) then
      CP_COMP_ID_CROSS_VAL (
         p_inv_component_id     => l_inv_comp_id,
         p_cp_component_id      => l_cp_comp_id,
         x_return_status        => lx_return_status );

      IF (lx_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;
    END IF;
   END IF;  -- validate cp component id end if

---- Validate_Bill_To_Site

   IF ((l_bto_site_id <> FND_API.G_MISS_NUM AND l_bto_site_id IS NOT NULL))
   THEN
      IF (l_bto_party_id = FND_API.G_MISS_NUM OR l_bto_party_id IS NULL) THEN
          fnd_message.set_name ('CS', 'CS_SR_PARENT_CHILD_CHECK');
          fnd_message.set_token ('CHILD_PARAM','bill_to_site_id');
          fnd_message.set_token ('PARENT_PARAM','bill_to_party_id');
          fnd_msg_pub.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
          RETURN;
      END IF;
   END IF;
   IF ((p_new_sr_rec.bill_to_party_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.bill_to_party_id,-99) <>
			       nvl(p_old_sr_rec.bill_to_party_id,-99)))
     OR
      ((p_new_sr_rec.bill_to_site_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.bill_to_site_id,-99) <>
			       nvl(p_old_sr_rec.bill_to_site_id,-99)))
   THEN

     if ( l_bto_site_id IS NOT NULL and l_bto_site_id <> FND_API.G_MISS_NUM ) then
      VALIDATE_BILL_TO_SHIP_TO_SITE (
         p_api_name             => NULL,
         p_parameter_name       => 'bill to site id',
         p_bill_to_site_id      => l_bto_site_id,
         p_bill_to_party_id     => l_bto_party_id,
         p_site_use_type        => 'BILL_TO',
         x_site_use_id          => x_cross_val_out_rec.bill_to_site_use_id,
         x_return_status        => lx_return_status );

      IF (lx_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;
    END IF;
   END IF;  -- validate bill to site id end if

---- Validate_ship_to_Site

   IF ((l_sto_site_id <> FND_API.G_MISS_NUM AND l_sto_site_id IS NOT NULL))
   THEN
      IF (l_sto_party_id = FND_API.G_MISS_NUM OR l_sto_party_id IS NULL) THEN
          fnd_message.set_name ('CS', 'CS_SR_PARENT_CHILD_CHECK');
          fnd_message.set_token ('CHILD_PARAM','ship_to_site_id');
          fnd_message.set_token ('PARENT_PARAM','ship_to_party_id');
          fnd_msg_pub.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
          RETURN;
      END IF;
   END IF;

IF ((p_new_sr_rec.ship_to_party_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.ship_to_party_id,-99) <>
			       nvl(p_old_sr_rec.ship_to_party_id,-99)))
     OR
      ((p_new_sr_rec.ship_to_site_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.ship_to_site_id,-99) <>
			       nvl(p_old_sr_rec.ship_to_site_id,-99)))
   THEN

     if ( l_sto_site_id IS NOT NULL and l_sto_site_id <> FND_API.G_MISS_NUM ) then
      VALIDATE_BILL_TO_SHIP_TO_SITE (
         p_api_name             => NULL,
         p_parameter_name       => 'ship to site id',
         p_bill_to_site_id      => l_sto_site_id,
         p_bill_to_party_id     => l_sto_party_id,
         p_site_use_type        => 'SHIP_TO',
         x_site_use_id          => x_cross_val_out_rec.ship_to_site_use_id,
         x_return_status        => lx_return_status );

      IF (lx_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;
    END IF;
   END IF;  -- validate ship to site id end if

---- Validate Bill to contact id
   IF ((l_bto_cont_id <> FND_API.G_MISS_NUM AND l_bto_cont_id IS NOT NULL)) THEN
      IF (l_bto_party_id = FND_API.G_MISS_NUM OR l_bto_party_id IS NULL) THEN

          fnd_message.set_name ('CS', 'CS_SR_PARENT_CHILD_CHECK');
          fnd_message.set_token ('CHILD_PARAM','bill_to_contact_id');
          fnd_message.set_token ('PARENT_PARAM','bill_to_party_id');
          fnd_msg_pub.ADD;

         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;
   END IF;
   IF ((p_new_sr_rec.bill_to_party_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.bill_to_party_id,-99) <>
			       nvl(p_old_sr_rec.bill_to_party_id,-99)))
     OR
      ((p_new_sr_rec.bill_to_contact_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.bill_to_contact_id,-99) <>
			       nvl(p_old_sr_rec.bill_to_contact_id,-99)))
   THEN

     IF ( l_bto_cont_id IS NOT NULL and l_bto_cont_id <> FND_API.G_MISS_NUM ) then
      VALIDATE_BILL_TO_SHIP_TO_CT (
         p_api_name             => NULL,
         p_parameter_name       => 'bill to contact id',
         p_bill_to_contact_id   => l_bto_cont_id,
         p_bill_to_party_id     => l_bto_party_id,
         p_customer_type        => l_cust_type,
         x_return_status        => lx_return_status );

      IF (lx_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;
    END IF;  -- IF ( l_bto_cont_id IS NOT NULL and l_bto_cont_id <>
   END IF;  -- validate bill to contact id end if

---- Validate ship to contact id
   IF ((l_sto_cont_id <> FND_API.G_MISS_NUM AND l_sto_cont_id IS NOT NULL)) THEN
      IF (l_sto_party_id = FND_API.G_MISS_NUM OR l_sto_party_id IS NULL) THEN

          fnd_message.set_name ('CS', 'CS_SR_PARENT_CHILD_CHECK');
          fnd_message.set_token ('CHILD_PARAM','ship_to_contact_id');
          fnd_message.set_token ('PARENT_PARAM','ship_to_party_id');
          fnd_msg_pub.ADD;

         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;
   END IF;
   IF ((p_new_sr_rec.ship_to_party_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.ship_to_party_id,-99) <>
			       nvl(p_old_sr_rec.ship_to_party_id,-99)))
     OR
      ((p_new_sr_rec.ship_to_contact_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.ship_to_contact_id,-99) <>
			       nvl(p_old_sr_rec.ship_to_contact_id,-99)))

   THEN

     if ( l_sto_cont_id IS NOT NULL and l_sto_cont_id <> FND_API.G_MISS_NUM ) then
      VALIDATE_BILL_TO_SHIP_TO_CT (
         p_api_name             => NULL,
         p_parameter_name       => 'ship to contact id',
         p_bill_to_contact_id   => l_sto_cont_id,
         p_bill_to_party_id     => l_sto_party_id,
         p_customer_type        => l_cust_type,
         x_return_status        => lx_return_status );

      IF (lx_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;
    END IF;
   END IF;  -- validate ship to contact id end if

--- Validate Bill to account id

   IF ((p_new_sr_rec.bill_to_party_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.bill_to_party_id,-99) <>
			       nvl(p_old_sr_rec.bill_to_party_id,-99)))
     OR
      ((p_new_sr_rec.bill_to_account_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.bill_to_account_id,-99) <>
			       nvl(p_old_sr_rec.bill_to_account_id,-99)))

   THEN

     if ( l_bto_acc_id IS NOT NULL and l_bto_acc_id <> FND_API.G_MISS_NUM ) then
      VALIDATE_BILL_TO_SHIP_TO_ACCT (
         p_api_name             => NULL,
         p_parameter_name       => 'bill to account id',
         p_account_id           => l_bto_acc_id,
         p_party_id             => l_bto_party_id,
         x_return_status        => lx_return_status );

      IF (lx_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;
    END IF;
   END IF;  -- validate bill to account id end if

--- Validate ship to account id

   IF ((p_new_sr_rec.ship_to_party_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.ship_to_party_id,-99) <>
			       nvl(p_old_sr_rec.ship_to_party_id,-99)))
     OR
      ((p_new_sr_rec.ship_to_account_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.ship_to_account_id,-99) <>
			       nvl(p_old_sr_rec.ship_to_account_id,-99)))

   THEN

     if ( l_sto_acc_id IS NOT NULL and l_sto_acc_id <> FND_API.G_MISS_NUM ) then
      VALIDATE_BILL_TO_SHIP_TO_ACCT (
         p_api_name             => NULL,
         p_parameter_name       => 'ship to account id',
         p_account_id           => l_sto_acc_id,
         p_party_id             => l_sto_party_id,
         x_return_status        => lx_return_status );

      IF (lx_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;
    END IF;
   END IF;  -- validate ship to account id end if

--- Validate External Reference
   IF ((p_new_sr_rec.customer_product_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.customer_product_id,-99) <>
			       nvl(p_old_sr_rec.customer_product_id,-99)))
     OR
      ((p_new_sr_rec.external_reference <> FND_API.G_MISS_CHAR) AND
       (nvl(p_new_sr_rec.external_reference,-99) <>
			       nvl(p_old_sr_rec.external_reference,-99)))

   THEN

     if ( l_external_ref IS NOT NULL and l_external_ref <> FND_API.G_MISS_CHAR ) then
      -- For bug 3746983
      VALIDATE_EXTERNAL_REFERENCE (
         p_api_name               => NULL,
         p_parameter_name         => 'external reference',
         p_external_reference     => l_external_ref,
	 p_customer_product_id    => l_cust_prod_id,
         p_inventory_item_id      => l_inv_item_id,
         p_inventory_org_id       => l_inv_org_id,
         p_customer_id            => l_customer_id,
         x_return_status          => lx_return_status );

      IF (lx_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;
    END IF;
   END IF;  -- validate external reference end if

--- Validate Product Revision
   /**** Aug 13th 2004. Replaced with validate_product_version. This proc will return
   product revision if product revision is not passed
   IF ((p_new_sr_rec.inventory_item_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.inventory_item_id,-99) <>
			       nvl(p_old_sr_rec.inventory_item_id,-99)))
     OR
      ((p_new_sr_rec.customer_product_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.customer_product_id,-99) <>
			       nvl(p_old_sr_rec.customer_product_id,-99)))
     OR
      ((p_new_sr_rec.product_revision <> FND_API.G_MISS_CHAR) AND
       (nvl(p_new_sr_rec.product_revision,-99) <>
			       nvl(p_old_sr_rec.product_revision,-99)))
     OR ( l_inv_change_by_cp = 'Y')

   THEN

     if ( l_prod_revision IS NOT NULL and l_prod_revision <> FND_API.G_MISS_CHAR ) then
      VALIDATE_PRODUCT_REVISION (
         p_api_name             => NULL,
         p_parameter_name       => 'product revision',
         p_customer_product_id  => l_cust_prod_id,
         p_product_revision     => l_prod_revision,
         p_inventory_item_id    => l_inv_item_id,
         p_inventory_org_id     => l_inv_org_id,
         x_return_status        => lx_return_status );

      IF (lx_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;
    END IF;
   END IF;  -- validate product revision end if
   ****/
   l_prod_revision := p_new_sr_rec.product_revision;
   IF ((p_new_sr_rec.customer_product_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.customer_product_id,-99) <>
			       nvl(p_old_sr_rec.customer_product_id,-99)))
     OR
      (l_prod_revision is not null AND
       (nvl(p_new_sr_rec.product_revision,'-99') <>
			       nvl(p_old_sr_rec.product_revision,'-99')))

   THEN

     		VALIDATE_PRODUCT_VERSION
		( p_parameter_name       => 'Product Revision',
		  p_instance_id          => l_cust_prod_id,
		  p_inventory_org_id     => l_inv_org_id,
		  p_product_version      => l_prod_revision,
		  x_return_status        => lx_return_status );

      IF (lx_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;
   END IF;  -- validate product revision end if
   x_cross_val_out_rec.product_revision := l_prod_revision;

--- Validate current serial number

   IF ((p_new_sr_rec.customer_product_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.customer_product_id,-99) <>
			       nvl(p_old_sr_rec.customer_product_id,-99)))
     OR
      ((p_new_sr_rec.current_serial_number <> FND_API.G_MISS_CHAR) AND
       (nvl(p_new_sr_rec.current_serial_number,-99) <>
			       nvl(p_old_sr_rec.current_serial_number,-99)))

   THEN

     IF ( l_cur_serial   IS NOT NULL AND l_cur_serial   <> FND_API.G_MISS_CHAR ) AND
        ( l_cust_prod_id IS NOT NULL AND l_cust_prod_id <> FND_API.G_MISS_NUM  )
     THEN
        -- For bug 3746983
	  VALIDATE_CURRENT_SERIAL (
         p_api_name               => NULL,
         p_parameter_name         => 'current serial number',
	 p_inventory_item_id      => l_inv_item_id,
         p_inventory_org_id       => l_inv_org_id,
         p_customer_product_id    => l_cust_prod_id,
         p_customer_id            => l_customer_id,
         p_current_serial_number  => l_cur_serial,
         x_return_status          => lx_return_status );

      IF (lx_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;
    END IF;
   END IF;  -- validate current serial number end if

-- For bug 3592032 - moved call to INV_SUBCOMPONENT_CROSS_VAL after validate_cp_subcomp_id


-- Validate Inventory component version
   IF ((p_new_sr_rec.inv_component_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.inv_component_id,-99) <>
			       nvl(p_old_sr_rec.inv_component_id,-99)))
     OR
      ((p_new_sr_rec.inv_component_version <> FND_API.G_MISS_CHAR) AND
       (nvl(p_new_sr_rec.inv_component_version,-99) <>
			       nvl(p_old_sr_rec.inv_component_version,-99)))

   THEN

     if ( l_inv_comp_ver IS NOT NULL and l_inv_comp_ver <> FND_API.G_MISS_CHAR ) then
      VALIDATE_INV_COMP_VER (
         p_api_name               => NULL,
         p_parameter_name         => 'inventory component version',
         p_inv_component_id       => l_inv_comp_id,
         p_inventory_org_id       => l_inv_org_id,
         p_inv_component_version  => l_inv_comp_ver,
         x_return_status          => lx_return_status );

      IF (lx_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;
    END IF;
   END IF;  -- validate item component version end if

----    Validate CP component id

   IF ((p_new_sr_rec.customer_product_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.customer_product_id,-99) <>
			       nvl(p_old_sr_rec.customer_product_id,-99)))
     OR
      ((p_new_sr_rec.cp_component_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.cp_component_id,-99) <>
			       nvl(p_old_sr_rec.cp_component_id,-99)))

   THEN
     if ( l_cp_comp_id IS NOT NULL and l_cp_comp_id <> FND_API.G_MISS_NUM ) then
      VALIDATE_CP_COMP_ID (
         p_api_name             => NULL,
         p_parameter_name       => 'CP component id',
         p_customer_product_id  => l_cust_prod_id,
         p_cp_component_id      => l_cp_comp_id,
         p_org_id               => NULL,
	     x_return_status        => lx_return_status );

      IF (lx_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;
    END IF;
   END IF;  -- validate CP component id end if

----   Validate CP component version
-- For bug 3337848 - change from component_version_id to component_version
   /***
   IF ((p_new_sr_rec.cp_component_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.cp_component_id,-99) <>
			       nvl(p_old_sr_rec.cp_component_id,-99)))
     OR
      ((p_new_sr_rec.component_version <> FND_API.G_MISS_CHAR) AND
       (nvl(p_new_sr_rec.component_version,-99) <>
			       nvl(p_old_sr_rec.component_version,-99)))

   THEN

     if ( l_cp_comp_ver IS NOT NULL and l_cp_comp_ver <> FND_API.G_MISS_CHAR ) then
     		VALIDATE_COMPONENT_VERSION
		( p_api_name             => NULL,
		  p_parameter_name       => 'CP component version',
		  p_component_version    => l_cp_comp_ver,
		  p_cp_component_id      => l_cp_comp_id,
		  p_customer_product_id  => l_cust_prod_id,
		  p_inventory_org_id     => l_inv_org_id,
		  x_return_status        => lx_return_status );


      IF (lx_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;
     END IF;
   END IF;  -- validate CP component vesion end if
   ********************/
   l_cp_comp_ver := p_new_sr_rec.component_version;
   IF ((p_new_sr_rec.cp_component_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.cp_component_id,-99) <>
			       nvl(p_old_sr_rec.cp_component_id,-99)))
     OR
      ((l_cp_comp_id is not null) AND
       (nvl(p_new_sr_rec.component_version,'-99') <>
			       nvl(p_old_sr_rec.component_version,'-99')))

   THEN
     		VALIDATE_PRODUCT_VERSION
		( p_parameter_name       => 'CP component version',
		  p_instance_id          => l_cp_comp_id,
		  p_inventory_org_id     => l_inv_org_id,
		  p_product_version      => l_cp_comp_ver,
		  x_return_status        => lx_return_status );
      IF (lx_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;
   END IF;  -- validate CP component vesion end if
   x_cross_val_out_rec.component_version := l_cp_comp_ver;

   -- For bug 3592032 - moved call to VALIDATE_INV_SUBCOMP_VER after validate_cp_subcomp_id



---  Validate Category set id
   IF ((p_new_sr_rec.inventory_item_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.inventory_item_id,-99) <>
			       nvl(p_old_sr_rec.inventory_item_id,-99)))
     OR
      ((nvl(p_new_sr_rec.category_id,-99) <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.category_id,-99) <>
			       nvl(p_old_sr_rec.category_id,-99)))
     OR
      ((p_new_sr_rec.category_set_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.category_set_id,-99) <>
			       nvl(p_old_sr_rec.category_set_id,-99)))
     OR ( l_inv_change_by_cp = 'Y')
   THEN

     if ( l_cat_set_id IS NOT NULL and l_cat_set_id <> FND_API.G_MISS_NUM ) then
      VALIDATE_CATEGORY_SET_ID (
         p_api_name             => NULL,
         p_parameter_name       => 'Category set id',
         p_category_id          => l_category_id,
         p_category_set_id      => l_cat_set_id,
         p_inventory_item_id    => l_inv_item_id,
         p_inventory_org_id     => l_inv_org_id,
         x_return_status        => lx_return_status );

      IF (lx_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;
    END IF;
   END IF;  -- validate category set id end if

-- Validate the category_id
--   1. If the category_id has changed
--   2. check category_set_id is null ( passed/DB value)
   IF ((p_new_sr_rec.category_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.category_id,-99) <>
			       nvl(p_old_sr_rec.category_id,-99)) OR
       (nvl(p_new_sr_rec.category_set_id,-99) <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.category_set_id,-99) <>
			       nvl(p_old_sr_rec.category_set_id,-99)))
   THEN
     if ( l_cat_set_id IS NULL OR l_cat_set_id = FND_API.G_MISS_NUM ) then
	 VALIDATE_CATEGORY_ID
      ( p_api_name        => NULL,
        p_parameter_name  => 'Category id',
        p_category_id     => l_category_id,
        p_category_set_id => l_cat_set_id,
        x_return_status   => lx_return_status
      );
      IF (lx_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;
    END IF;
   END IF;  -- validate category id end if



--- Validate Inventory component id
   IF ((p_new_sr_rec.inv_component_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.inv_component_id,-99) <>
			       nvl(p_old_sr_rec.inv_component_id,-99)))
     OR
      ((p_new_sr_rec.cp_component_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.cp_component_id,-99) <>
			       nvl(p_old_sr_rec.cp_component_id,-99)))

   THEN
     if ( l_cp_comp_id IS NOT NULL and l_cp_comp_id <> FND_API.G_MISS_NUM ) and
        ( l_inv_comp_id IS NOT NULL and l_inv_comp_id <> FND_API.G_MISS_NUM ) then
      INV_COMPONENT_CROSS_VAL (
         p_parameter_name       => 'Inventory component',
         p_cp_component_id      => l_cp_comp_id,
         p_inv_component_id     => l_inv_comp_id,
         x_return_status        => lx_return_status );

      IF (lx_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;
    END IF;
   END IF;  -- validate Inventory  component end if

---  Validate CP subcomponent id

   IF ((p_new_sr_rec.cp_subcomponent_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.cp_subcomponent_id,-99) <>
			       nvl(p_old_sr_rec.cp_subcomponent_id,-99)))
     OR
      ((p_new_sr_rec.cp_component_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.cp_component_id,-99) <>
			       nvl(p_old_sr_rec.cp_component_id,-99)))
	 OR
	  ((p_new_sr_rec.customer_product_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.customer_product_id,-99) <>
			       nvl(p_old_sr_rec.customer_product_id,-99)))
   THEN

     if ( l_cp_scomp_id IS NOT NULL and l_cp_scomp_id <> FND_API.G_MISS_NUM ) then
      VALIDATE_CP_SUBCOMP_ID  (
         p_api_name             => NULL,
         p_parameter_name       => 'CP subcomponent id',
         p_cp_component_id      => l_cp_comp_id,
         p_cp_subcomponent_id   => l_cp_scomp_id,
         p_customer_product_id  => l_cust_prod_id,
         p_org_id               => NULL,
         x_return_status        => lx_return_status );

      IF (lx_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;
    END IF;
   END IF;  -- validate CP subcomponent end if

   -- For bug 3592032
   --- Validate Inventory subcomponent id
   IF ((p_new_sr_rec.inv_subcomponent_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.inv_subcomponent_id,-99) <>
			       nvl(p_old_sr_rec.inv_subcomponent_id,-99)))
     OR
      ((p_new_sr_rec.cp_subcomponent_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.cp_subcomponent_id,-99) <>
			       nvl(p_old_sr_rec.cp_subcomponent_id,-99)))

   THEN
     if ( l_cp_subcomp_id IS NOT NULL and l_cp_subcomp_id <> FND_API.G_MISS_NUM ) and
        ( l_inv_subcomp_id IS NOT NULL and l_inv_subcomp_id <> FND_API.G_MISS_NUM ) then
      INV_SUBCOMPONENT_CROSS_VAL (
         p_parameter_name       => 'inv subcomponent',
         p_inv_subcomponent_id  => l_inv_subcomp_id,
         p_cp_subcomponent_id   => l_cp_subcomp_id,
         x_return_status        => lx_return_status );

      IF (lx_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;
    END IF;
   END IF;  -- validate inventory subcomponent end if

   ---  Validate Inv subcomponent version
   IF ((p_new_sr_rec.inv_subcomponent_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.inv_subcomponent_id,-99) <>
			       nvl(p_old_sr_rec.inv_subcomponent_id,-99)))
     OR
      ((p_new_sr_rec.inv_subcomponent_version <> FND_API.G_MISS_CHAR) AND
       (nvl(p_new_sr_rec.inv_subcomponent_version,-99) <>
			       nvl(p_old_sr_rec.inv_subcomponent_version,-99)))

   THEN

     if ( l_inv_scomp_ver IS NOT NULL and l_inv_scomp_ver <> FND_API.G_MISS_CHAR ) then
      VALIDATE_INV_SUBCOMP_VER (
         p_api_name                 => NULL,
         p_parameter_name           => 'Inv subcomponent version',
         p_inv_subcomponent_version => l_inv_scomp_ver,
         p_inv_subcomponent_id      => l_inv_scomp_id,
         p_inventory_org_id         => l_inv_org_id,
         x_return_status            => lx_return_status );

      IF (lx_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;
    END IF;
   END IF;  -- validate Inv subcomponent version end if

   -- end of change for bug 3592032


--- Validate the CP suncomponent version
-- For bug 3337848 - change from component_version_id to component_version

   /*** smisra 5/4/04 bug 3566783
   IF ((p_new_sr_rec.cp_subcomponent_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.cp_subcomponent_id,-99) <>
			       nvl(p_old_sr_rec.cp_subcomponent_id,-99)))
     OR
      ((p_new_sr_rec.subcomponent_version <> FND_API.G_MISS_CHAR) AND
       (nvl(p_new_sr_rec.subcomponent_version,-99) <>
			       nvl(p_old_sr_rec.subcomponent_version,-99)))

   THEN
     if ( l_cp_scomp_ver IS NOT NULL and l_cp_scomp_ver <> FND_API.G_MISS_CHAR ) then
       VALIDATE_SUBCOMPONENT_VERSION (
         p_api_name             => NULL,
         p_parameter_name       => 'CP subcomponent version',
         p_cp_component_id      => l_cp_comp_id,
         p_cp_subcomponent_id   => l_cp_scomp_id,
         p_customer_product_id  => l_cust_prod_id,
         p_subcomponent_version => l_cp_scomp_ver,
	  p_inventory_org_id    => l_inv_org_id,
         x_return_status        => lx_return_status );

      IF (lx_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;
    END IF;
   END IF;  -- validate CP subcomponent version end if
   *********************************/
   l_cp_scomp_ver := p_new_sr_rec.subcomponent_version;
   IF ((p_new_sr_rec.cp_subcomponent_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.cp_subcomponent_id,-99) <>
			       nvl(p_old_sr_rec.cp_subcomponent_id,-99)))
     OR
      ((l_cp_scomp_id is not null) AND
       (nvl(p_new_sr_rec.subcomponent_version,'-99') <>
			       nvl(p_old_sr_rec.subcomponent_version,'-99')))

   THEN
     		VALIDATE_PRODUCT_VERSION
		( p_parameter_name       => 'CP subcomponent version',
		  p_instance_id          => l_cp_scomp_id,
		  p_inventory_org_id     => l_inv_org_id,
		  p_product_version      => l_cp_scomp_ver,
		  x_return_status        => lx_return_status );
      IF (lx_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;
   END IF;  -- validate CP component vesion end if
   x_cross_val_out_rec.subcomponent_version := l_cp_scomp_ver;



---    Validate bill to site and site use
   IF ((p_new_sr_rec.bill_to_party_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.bill_to_party_id,-99) <>
			       nvl(p_old_sr_rec.bill_to_party_id,-99)))
     OR
      ((p_new_sr_rec.bill_to_site_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.bill_to_site_id,-99) <>
			       nvl(p_old_sr_rec.bill_to_site_id,-99)))
     OR
      ((p_new_sr_rec.bill_to_site_use_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.bill_to_site_use_id,-99) <>
			       nvl(p_old_sr_rec.bill_to_site_use_id,-99)))

   THEN

     if ( l_bto_site_id IS NOT NULL and l_bto_site_id <> FND_API.G_MISS_NUM ) then
      VALIDATE_BILL_TO_SHIP_TO_SITE (
         p_api_name             => NULL,
         p_parameter_name       => 'bill to site id',
         p_bill_to_site_id      => l_bto_site_id,
         p_bill_to_party_id     => l_bto_party_id,
         p_site_use_type        => 'BILL_TO',
         --p_site_use_id          => l_bto_site_use,
         x_site_use_id          => lx_site_use_id,
         x_return_status        => lx_return_status );

      IF (lx_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         RETURN;
      END IF;
    END IF;
   END IF;  -- validate bill to site and site use end if

---    Validate ship to site and site use
  -- ship_to_party_id is a reqd field if ship_to_site_use_id is passed,
  -- so check if passed, else return error
   IF ((l_sto_site_use <> FND_API.G_MISS_NUM AND
        l_sto_site_use IS NOT NULL))
   THEN
      IF (l_sto_party_id = FND_API.G_MISS_NUM OR
          l_sto_party_id IS NULL) THEN
                   fnd_message.set_name ('CS', 'CS_SR_PARENT_CHILD_CHECK');
                   fnd_message.set_token ('CHILD_PARAM','ship_to_site_use_id');
                   fnd_message.set_token ('PARENT_PARAM','ship_to_party_id');
                   fnd_msg_pub.ADD;
             x_return_status := FND_API.G_RET_STS_ERROR;
             RETURN;
      END IF;
   END IF;
/*
    BUG 3702517 - Commented out
   IF ((p_new_sr_rec.ship_to_party_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.ship_to_party_id,-99) <>
			       nvl(p_old_sr_rec.ship_to_party_id,-99)))
     OR
      ((p_new_sr_rec.ship_to_site_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.ship_to_site_id,-99) <>
			       nvl(p_old_sr_rec.ship_to_site_id,-99)))
     OR
      ((p_new_sr_rec.ship_to_site_use_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.ship_to_site_use_id,-99) <>
			       nvl(p_old_sr_rec.ship_to_site_use_id,-99)))
   THEN

      if ( l_sto_site_use IS NOT NULL and l_sto_site_use <> FND_API.G_MISS_NUM ) then
         Validate_Site_Site_Use (
            p_api_name             => NULL,
            p_parameter_name       => 'ship_to_site_use_id',
            p_site_id              => l_sto_site_id,
            p_site_use_id          => l_sto_site_use,
            p_party_id             => l_sto_party_id,
            p_site_use_type        => 'SHIP_TO',
            x_return_status        => lx_return_status );

         if (lx_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            RETURN;
         end if;
      end if;
   END IF;  -- validate ship to site and site use end if
   end of comment out for Bug 3702517
*/
-- Bug 3702517 change begins
---------------------------
    IF
        (
            ( p_new_sr_rec.ship_to_party_id <> FND_API.G_MISS_NUM ) AND
            (
	        NVL(p_new_sr_rec.ship_to_party_id,-99) <> NVL(p_old_sr_rec.ship_to_party_id,-99)
            )
	)
        OR
        (
	    ( p_new_sr_rec.ship_to_site_id <> FND_API.G_MISS_NUM ) AND
            (
	        NVL(p_new_sr_rec.ship_to_site_id,-99) <> NVL(p_old_sr_rec.ship_to_site_id,-99)
	    )
	)
	OR
        (
            (p_new_sr_rec.ship_to_site_use_id <> FND_API.G_MISS_NUM ) AND
            (
                NVL(p_new_sr_rec.ship_to_site_use_id,-99) <> NVL(p_old_sr_rec.ship_to_site_use_id,-99)
            )
        )
    THEN
        IF
        -- Both ship_to_site_id and ship_to_site_use_id are available
        -- => call Validate_Site_Site_Use
	(
	    l_sto_site_use IS NOT NULL and l_sto_site_use <> FND_API.G_MISS_NUM AND
            l_sto_site_id  IS NOT NULL AND l_sto_site_id  <> FND_API.G_MISS_NUM
	)
	THEN
            Validate_Site_Site_Use
	    (
                p_api_name             => NULL,
                p_parameter_name       => 'SHIP_TO_SITE_USE_ID',
                p_site_id              => l_sto_site_id,
                p_site_use_id          => l_sto_site_use,
                p_party_id             => l_sto_party_id,
                p_site_use_type        => 'SHIP_TO',
                x_return_status        => lx_return_status
            );
            IF
                (lx_return_status <> FND_API.G_RET_STS_SUCCESS)
            THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                RETURN;
            END IF;

        ELSIF
        -- Ship_to_site_use_id is available, but ship_to_site_id is not passed
        -- => Call Validate_Bill_Ship_Site_Use
            (
                (
                    l_sto_site_use <> FND_API.G_MISS_NUM AND
                    l_sto_site_use IS NOT NULL
                )
                AND
                (
                    l_sto_site_id IS NULL  OR
                    l_sto_site_id = FND_API.G_MISS_NUM
                )
            )
        THEN
            Validate_Bill_Ship_Site_Use
            (
                p_api_name            => null,
                p_parameter_name      => 'SHIP_TO SITE USE ',
                p_site_use_id         => l_sto_site_use,
                p_party_id            => l_sto_party_id,
                p_site_use_type       => 'SHIP_TO',
                x_site_id             => l_sto_site_id,
                x_return_status       => lx_return_status
            );
            IF
                (lx_return_status <> FND_API.G_RET_STS_SUCCESS)
            THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                RETURN;
            ELSE
                x_cross_val_out_rec.ship_to_site_id := l_sto_site_id;
            END IF;

        ELSIF
	-- Ship_to_site_id is available, but ship_to_site_use_id is not passed
	-- => Call Validate_Bill_To_Ship_To_Site
	    (
                (
                    l_sto_site_id <> FND_API.G_MISS_NUM AND
                    l_sto_site_id IS NOT NULL
                )
                AND
                (
                    l_sto_site_use IS NULL  OR
                    l_sto_site_use = FND_API.G_MISS_NUM
                )
            )
        THEN
            Validate_Bill_To_Ship_To_Site
            (
                p_api_name            => null,
                p_parameter_name      => 'SHIP_TO SITE ',
                p_bill_to_site_id     => l_sto_site_id,  -- Parameter name is a misnomer,spec to be modified later
                p_bill_to_party_id    => l_sto_party_id, -- Parameter name is a misnomer,spec to be modified later
                p_site_use_type       => 'SHIP_TO',
                x_site_use_id         => l_sto_site_use,
                x_return_status       => lx_return_status
            );
            IF
                (lx_return_status <> FND_API.G_RET_STS_SUCCESS)
            THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                RETURN;
            ELSE
                x_cross_val_out_rec.ship_to_site_use_id := l_sto_site_use;
            END IF;
        END IF;
    END IF;
--Bug 3702517 change ends
-------------------------
---    Validate bill to site and site use
  IF ((l_bto_site_use <> FND_API.G_MISS_NUM AND
      l_bto_site_use IS NOT NULL))
  THEN
     IF (l_bto_party_id = FND_API.G_MISS_NUM OR
         l_bto_party_id IS NULL) THEN
                  fnd_message.set_name ('CS', 'CS_SR_PARENT_CHILD_CHECK');
                  fnd_message.set_token ('CHILD_PARAM','bill_to_site_use_id');
                  fnd_message.set_token ('PARENT_PARAM','bill_to_party_id');
                  fnd_msg_pub.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;
            RETURN;
     END IF;
  END IF;
   IF ((p_new_sr_rec.bill_to_party_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.bill_to_party_id,-99) <>
			       nvl(p_old_sr_rec.bill_to_party_id,-99)))
     OR
      ((p_new_sr_rec.bill_to_site_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.bill_to_site_id,-99) <>
			       nvl(p_old_sr_rec.bill_to_site_id,-99)))
     OR
      ((p_new_sr_rec.bill_to_site_use_id <> FND_API.G_MISS_NUM) AND
       (nvl(p_new_sr_rec.bill_to_site_use_id,-99) <>
			       nvl(p_old_sr_rec.bill_to_site_use_id,-99)))
   THEN
      IF ( l_bto_site_use IS NOT NULL and l_bto_site_use <> FND_API.G_MISS_NUM AND
           l_bto_site_id  IS NOT NULL AND l_bto_site_id  <> FND_API.G_MISS_NUM) THEN
         -- this call is made when both site use and site id are available
         Validate_Site_Site_Use (
            p_api_name             => NULL,
            p_parameter_name       => 'bill_to_site_use_id',
            p_site_id              => l_bto_site_id,
            p_site_use_id          => l_bto_site_use,
            p_party_id             => l_bto_party_id,
            p_site_use_type        => 'BILL_TO',
            x_return_status        => lx_return_status );

         if (lx_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            RETURN;
         end if;
      ELSIF ( ( l_bto_site_use <> FND_API.G_MISS_NUM AND l_bto_site_use IS NOT NULL )  AND
              ( l_bto_site_id IS NULL  OR l_bto_site_id = FND_API.G_MISS_NUM )
            ) THEN
            -- this call is made when site use is availabel but site id is not available
            CS_ServiceRequest_UTIL.Validate_Bill_Ship_Site_Use
            ( p_api_name            => null,
              -- p_parameter_name      => 'Ship_To Site Use ', /* Modified during 3702517 fix */
                 p_parameter_name      => 'BILL TO SITE USE',
              p_site_use_id         => l_bto_site_use,
              p_party_id            => l_bto_party_id,
              p_site_use_type       => 'BILL_TO',
              x_site_id             => l_bto_site_id,
              x_return_status       => lx_return_status
             );
           IF (lx_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
              RETURN;
           ELSE
              x_cross_val_out_rec.bill_to_site_id := l_bto_site_id;
           END IF;
      ELSIF ( ( l_bto_site_id <> FND_API.G_MISS_NUM AND l_bto_site_id IS NOT NULL )  AND
              ( l_bto_site_use IS NULL  OR l_bto_site_use = FND_API.G_MISS_NUM )
            ) THEN
            -- this call is made when site use is not available but site id is available
            CS_ServiceRequest_UTIL.Validate_Bill_To_Ship_To_Site
            ( p_api_name            => null,
              -- p_parameter_name      => 'Ship_To Site ', /* Modified during 3702517 fix */
              p_parameter_name      => 'SHIP TO SITE',
              p_bill_to_site_id     => l_bto_site_id,
              p_bill_to_party_id    => l_bto_party_id,
              p_site_use_type       => 'BILL_TO',
              x_site_use_id         => l_bto_site_use,
              x_return_status       => lx_return_status
            );
            IF (lx_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
              RETURN;
            ELSE
              x_cross_val_out_rec.bill_to_site_use_id := l_bto_site_use;
            END IF;
      END IF;
   END IF;  -- validate bill to site and site use end if


   /* For bug 3340433 - assigning the proper values to the out rec */
   x_cross_val_out_rec.inventory_item_id   := l_inv_item_id;



   /*
   x_cross_val_out_rec.bill_to_site_use_id := l_bto_site_use;
   x_cross_val_out_rec.ship_to_site_use_id :=
   x_cross_val_out_rec.bill_to_site_id     := l_bto_site_id;
   x_cross_val_out_rec.ship_to_site_id     :=
   x_cross_val_out_rec.contract_id         := l_contract_id;
   x_cross_val_out_rec.contract_number     := l_con_number;
*/


EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MESSAGE.SET_NAME ('CS', 'CS_API_SR_UNKNOWN_ERROR');
      FND_MESSAGE.SET_TOKEN ('P_TEXT',l_api_name_full||'-'||SQLERRM);
      FND_MSG_PUB.ADD;

END SERVICEREQUEST_CROSS_VAL;



-- -----------------------------------------------------------------------------
-- Modification History
-- Date     Name     Desc
-- -------- -------- -----------------------------------------------------------
-- 05/12/05 smisra   removed item_serial_number from select statement. This col
--                   is obsolete from release 12.
-- -----------------------------------------------------------------------------
PROCEDURE Prepare_Audit_Record (
       p_api_version            IN  VARCHAR2,
       p_request_id             IN  NUMBER,
       x_return_status          OUT  NOCOPY VARCHAR2,
       x_msg_count              OUT  NOCOPY NUMBER,
       x_msg_data               OUT  NOCOPY VARCHAR2,
       x_audit_vals_rec         OUT  NOCOPY  CS_ServiceRequest_PVT.SR_AUDIT_REC_TYPE) IS

CURSOR L_SERVICEREQUEST_CSR IS
     SELECT
                INCIDENT_STATUS_ID              INCIDENT_STATUS_ID  ,
                INCIDENT_STATUS_ID              OLD_INCIDENT_STATUS_ID     ,
                'N'                             CHANGE_INCIDENT_STATUS_FLAG    ,
                INCIDENT_TYPE_ID                INCIDENT_TYPE_ID ,
                INCIDENT_TYPE_ID                OLD_INCIDENT_TYPE_ID,
                'N'                             CHANGE_INCIDENT_TYPE_FLAG ,
                INCIDENT_URGENCY_ID             INCIDENT_URGENCY_ID ,
                INCIDENT_URGENCY_ID             OLD_INCIDENT_URGENCY_ID    ,
                'N'                             CHANGE_INCIDENT_URGENCY_FLAG   ,
                INCIDENT_SEVERITY_ID            INCIDENT_SEVERITY_ID,
                INCIDENT_SEVERITY_ID            OLD_INCIDENT_SEVERITY_ID   ,
                'N'                             CHANGE_INCIDENT_SEVERITY_FLAG  ,
                TO_NUMBER(NULL)                 RESPONSIBLE_GROUP_ID,
                TO_NUMBER(NULL)                 OLD_RESPONSIBLE_GROUP_ID   ,
                'N'                             CHANGE_RESPONSIBLE_GROUP_FLAG  ,
                INCIDENT_OWNER_ID               INCIDENT_OWNER_ID,
                INCIDENT_OWNER_ID               OLD_INCIDENT_OWNER_ID      ,
                'N'                             CHANGE_INCIDENT_OWNER_FLAG,
                'N'                             CREATE_MANUAL_ACTION      ,
                to_number(null)                 ACTION_ID ,
                EXPECTED_RESOLUTION_DATE        EXPECTED_RESOLUTION_DATE   ,
                EXPECTED_RESOLUTION_DATE        OLD_EXPECTED_RESOLUTION_DATE    ,
                'N'                             CHANGE_RESOLUTION_FLAG     ,
                'N'                             NEW_WORKFLOW_FLAG,
                TO_CHAR(NULL)                   WORKFLOW_PROCESS_NAME     ,
                TO_CHAR(NULL)                   WORKFLOW_PROCESS_ITEMKEY  ,
                OWNER_GROUP_ID                  GROUP_ID  ,
                OWNER_GROUP_ID                  OLD_GROUP_ID     ,
                'N'                             CHANGE_GROUP_FLAG,
                OBLIGATION_DATE                 OBLIGATION_DATE  ,
                OBLIGATION_DATE                 OLD_OBLIGATION_DATE ,
                'N'                             CHANGE_OBLIGATION_FLAG     ,
                SITE_ID                         SITE_ID   ,
                SITE_ID                         OLD_SITE_ID      ,
                'N'                             CHANGE_SITE_FLAG,
                BILL_TO_CONTACT_ID              BILL_TO_CONTACT_ID  ,
                BILL_TO_CONTACT_ID              OLD_BILL_TO_CONTACT_ID     ,
                'N'                             CHANGE_BILL_TO_FLAG,
                SHIP_TO_CONTACT_ID              SHIP_TO_CONTACT_ID  ,
                SHIP_TO_CONTACT_ID              OLD_SHIP_TO_CONTACT_ID     ,
                'N'                             CHANGE_SHIP_TO_FLAG ,
                INCIDENT_DATE                   INCIDENT_DATE   ,
                INCIDENT_DATE                   OLD_INCIDENT_DATE,
                'N'                             CHANGE_INCIDENT_DATE_FLAG  ,
                CLOSE_DATE                      CLOSE_DATE      ,
                CLOSE_DATE                      OLD_CLOSE_DATE   ,
                'N'                             CHANGE_CLOSE_DATE_FLAG ,
                CUSTOMER_PRODUCT_ID             CUSTOMER_PRODUCT_ID ,
                CUSTOMER_PRODUCT_ID             OLD_CUSTOMER_PRODUCT_ID    ,
                'N'                             CHANGE_CUSTOMER_PRODUCT_FLAG    ,
                PLATFORM_ID                     PLATFORM_ID      ,
                PLATFORM_ID                     OLD_PLATFORM_ID  ,
                'N'                             CHANGE_PLATFORM_ID_FLAG    ,
                PLATFORM_VERSION_ID             PLATFORM_VERSION_ID,
                PLATFORM_VERSION_ID             OLD_PLATFORM_VERSION_ID    ,
                'N'                             CHANGE_PLAT_VER_ID_FLAG    ,
                CP_COMPONENT_ID                 CP_COMPONENT_ID  ,
                CP_COMPONENT_ID                 OLD_CP_COMPONENT_ID ,
                'N'                             CHANGE_CP_COMPONENT_ID_FLAG,
                CP_COMPONENT_VERSION_ID         CP_COMPONENT_VERSION_ID    ,
                CP_COMPONENT_VERSION_ID         OLD_CP_COMPONENT_VERSION_ID,
                'N'                             CHANGE_CP_COMP_VER_ID_FLAG ,
                CP_SUBCOMPONENT_ID              CP_SUBCOMPONENT_ID  ,
                CP_SUBCOMPONENT_ID              OLD_CP_SUBCOMPONENT_ID     ,
                'N'                             CHANGE_CP_SUBCOMPONENT_ID_FLAG  ,
                CP_SUBCOMPONENT_VERSION_ID      CP_SUBCOMPONENT_VERSION_ID ,
                CP_SUBCOMPONENT_VERSION_ID      OLD_CP_SUBCOMPONENT_VERSION_ID  ,
                'N'                             CHANGE_CP_SUBCOMP_VER_ID_FLAG   ,
                LANGUAGE_ID                     LANGUAGE_ID      ,
                LANGUAGE_ID                     OLD_LANGUAGE_ID  ,
                'N'                             CHANGE_LANGUAGE_ID_FLAG    ,
                TERRITORY_ID                    TERRITORY_ID   ,
                TERRITORY_ID                    OLD_TERRITORY_ID ,
                'N'                             CHANGE_TERRITORY_ID_FLAG   ,
                CP_REVISION_ID                  CP_REVISION_ID   ,
                CP_REVISION_ID                  OLD_CP_REVISION_ID  ,
                'N'                             CHANGE_CP_REVISION_ID_FLAG ,
                INV_ITEM_REVISION               INV_ITEM_REVISION  ,
                INV_ITEM_REVISION               OLD_INV_ITEM_REVISION      ,
                'N'                             CHANGE_INV_ITEM_REVISION   ,
                INV_COMPONENT_ID                INV_COMPONENT_ID ,
                INV_COMPONENT_ID                OLD_INV_COMPONENT_ID,
                'N'                             CHANGE_INV_COMPONENT_ID    ,
                INV_COMPONENT_VERSION           INV_COMPONENT_VERSION      ,
                INV_COMPONENT_VERSION           OLD_INV_COMPONENT_VERSION  ,
                'N'                             CHANGE_INV_COMPONENT_VERSION    ,
                INV_SUBCOMPONENT_ID             INV_SUBCOMPONENT_ID,
                INV_SUBCOMPONENT_ID             OLD_INV_SUBCOMPONENT_ID    ,
                'N'                             CHANGE_INV_SUBCOMPONENT_ID ,
                INV_SUBCOMPONENT_VERSION        INV_SUBCOMPONENT_VERSION   ,
                INV_SUBCOMPONENT_VERSION        OLD_INV_SUBCOMPONENT_VERSION    ,
                'N'                             CHANGE_INV_SUBCOMP_VERSION ,
                RESOURCE_TYPE                   RESOURCE_TYPE  ,
                RESOURCE_TYPE                   OLD_RESOURCE_TYPE,
                'N'                             CHANGE_RESOURCE_TYPE_FLAG  ,
                SECURITY_GROUP_ID               SECURITY_GROUP_ID  ,
                'N'                             UPGRADED_STATUS_FLAG,
                GROUP_TYPE                      OLD_GROUP_TYPE   ,
                GROUP_TYPE                      GROUP_TYPE     ,
                'N'                             CHANGE_GROUP_TYPE_FLAG     ,
                OWNER_ASSIGNED_TIME             OLD_OWNER_ASSIGNED_TIME    ,
                OWNER_ASSIGNED_TIME             OWNER_ASSIGNED_TIME ,
                'N'                             CHANGE_ASSIGNED_TIME_FLAG  ,
                INV_PLATFORM_ORG_ID             INV_PLATFORM_ORG_ID,
                INV_PLATFORM_ORG_ID             OLD_INV_PLATFORM_ORG_ID    ,
                'N'                             CHANGE_PLATFORM_ORG_ID_FLAG,
                COMPONENT_VERSION               COMPONENT_VERSION  ,
                COMPONENT_VERSION               OLD_COMPONENT_VERSION      ,
                'N'                             CHANGE_COMP_VER_FLAG,
                SUBCOMPONENT_VERSION            SUBCOMPONENT_VERSION   ,
                SUBCOMPONENT_VERSION            OLD_SUBCOMPONENT_VERSION   ,
                'N'                             CHANGE_SUBCOMP_VER_FLAG    ,
                PRODUCT_REVISION                PRODUCT_REVISION ,
                PRODUCT_REVISION                OLD_PRODUCT_REVISION,
                'N'                             CHANGE_PRODUCT_REVISION_FLAG    ,
                STATUS_FLAG                     STATUS_FLAG      ,
                STATUS_FLAG                     OLD_STATUS_FLAG  ,
                'N'                             CHANGE_STATUS_FLAG  ,
                INVENTORY_ITEM_ID               INVENTORY_ITEM_ID  ,
                INVENTORY_ITEM_ID               OLD_INVENTORY_ITEM_ID     ,
                'N'                             CHANGE_INVENTORY_ITEM_FLAG,
                INV_ORGANIZATION_ID             INV_ORGANIZATION_ID      ,
                INV_ORGANIZATION_ID             OLD_INV_ORGANIZATION_ID   ,
                'N'                             CHANGE_INV_ORGANIZATION_FLAG   ,
                PRIMARY_CONTACT_ID              PRIMARY_CONTACT_ID ,
                'N'                             CHANGE_PRIMARY_CONTACT_FLAG    ,
                PRIMARY_CONTACT_ID              OLD_PRIMARY_CONTACT_ID        ,
                TO_CHAR(null)                   UPGRADE_FLAG_FOR_CREATE,
                INCIDENT_NUMBER                 OLD_INCIDENT_NUMBER,
                INCIDENT_NUMBER                 INCIDENT_NUMBER,
                CUSTOMER_ID                     OLD_CUSTOMER_ID   ,
                CUSTOMER_ID                     CUSTOMER_ID      ,
                BILL_TO_SITE_USE_ID             OLD_BILL_TO_SITE_USE_ID,
                BILL_TO_SITE_USE_ID             BILL_TO_SITE_USE_ID,
                EMPLOYEE_ID                     OLD_EMPLOYEE_ID,
                EMPLOYEE_ID                     EMPLOYEE_ID,
                SHIP_TO_SITE_USE_ID             OLD_SHIP_TO_SITE_USE_ID,
                SHIP_TO_SITE_USE_ID             SHIP_TO_SITE_USE_ID,
                PROBLEM_CODE                    OLD_PROBLEM_CODE,
                PROBLEM_CODE                    PROBLEM_CODE,
                ACTUAL_RESOLUTION_DATE          OLD_ACTUAL_RESOLUTION_DATE,
                ACTUAL_RESOLUTION_DATE          ACTUAL_RESOLUTION_DATE,
                INSTALL_SITE_USE_ID             OLD_INSTALL_SITE_USE_ID,
                INSTALL_SITE_USE_ID             INSTALL_SITE_USE_ID,
                CURRENT_SERIAL_NUMBER           OLD_CURRENT_SERIAL_NUMBER,
                CURRENT_SERIAL_NUMBER           CURRENT_SERIAL_NUMBER,
                SYSTEM_ID                       OLD_SYSTEM_ID,
                SYSTEM_ID                       SYSTEM_ID,
                INCIDENT_ATTRIBUTE_1            OLD_INCIDENT_ATTRIBUTE_1,
                INCIDENT_ATTRIBUTE_1            INCIDENT_ATTRIBUTE_1,
                INCIDENT_ATTRIBUTE_2            OLD_INCIDENT_ATTRIBUTE_2 ,
                INCIDENT_ATTRIBUTE_2            INCIDENT_ATTRIBUTE_2,
                INCIDENT_ATTRIBUTE_3            OLD_INCIDENT_ATTRIBUTE_3,
                INCIDENT_ATTRIBUTE_3            INCIDENT_ATTRIBUTE_3,
                INCIDENT_ATTRIBUTE_4            OLD_INCIDENT_ATTRIBUTE_4,
                INCIDENT_ATTRIBUTE_4            INCIDENT_ATTRIBUTE_4,
                INCIDENT_ATTRIBUTE_5            OLD_INCIDENT_ATTRIBUTE_5,
                INCIDENT_ATTRIBUTE_5            INCIDENT_ATTRIBUTE_5,
                INCIDENT_ATTRIBUTE_6            OLD_INCIDENT_ATTRIBUTE_6,
                INCIDENT_ATTRIBUTE_6            INCIDENT_ATTRIBUTE_6,
                INCIDENT_ATTRIBUTE_7            OLD_INCIDENT_ATTRIBUTE_7,
                INCIDENT_ATTRIBUTE_7            INCIDENT_ATTRIBUTE_7,
                INCIDENT_ATTRIBUTE_8            OLD_INCIDENT_ATTRIBUTE_8,
                INCIDENT_ATTRIBUTE_8            INCIDENT_ATTRIBUTE_8,
                INCIDENT_ATTRIBUTE_9            OLD_INCIDENT_ATTRIBUTE_9,
                INCIDENT_ATTRIBUTE_9            INCIDENT_ATTRIBUTE_9,
                INCIDENT_ATTRIBUTE_10            OLD_INCIDENT_ATTRIBUTE_10,
                INCIDENT_ATTRIBUTE_10            INCIDENT_ATTRIBUTE_10,
                INCIDENT_ATTRIBUTE_11            OLD_INCIDENT_ATTRIBUTE_11,
                INCIDENT_ATTRIBUTE_11            INCIDENT_ATTRIBUTE_11,
                INCIDENT_ATTRIBUTE_12            OLD_INCIDENT_ATTRIBUTE_12,
                INCIDENT_ATTRIBUTE_12            INCIDENT_ATTRIBUTE_12,
                INCIDENT_ATTRIBUTE_13            OLD_INCIDENT_ATTRIBUTE_13,
                INCIDENT_ATTRIBUTE_13            INCIDENT_ATTRIBUTE_13,
                INCIDENT_ATTRIBUTE_14            OLD_INCIDENT_ATTRIBUTE_14,
                INCIDENT_ATTRIBUTE_14            INCIDENT_ATTRIBUTE_14,
                INCIDENT_ATTRIBUTE_15            OLD_INCIDENT_ATTRIBUTE_15,
                INCIDENT_ATTRIBUTE_15            INCIDENT_ATTRIBUTE_15,
                INCIDENT_CONTEXT                 OLD_INCIDENT_CONTEXT,
                INCIDENT_CONTEXT                INCIDENT_CONTEXT,
                RESOLUTION_CODE                 OLD_RESOLUTION_CODE,
                RESOLUTION_CODE                 RESOLUTION_CODE,
                ORIGINAL_ORDER_NUMBER           OLD_ORIGINAL_ORDER_NUMBER,
                ORIGINAL_ORDER_NUMBER           ORIGINAL_ORDER_NUMBER,
                ORG_ID                          OLD_ORG_ID,
                ORG_ID                          ORG_ID,
                PURCHASE_ORDER_NUM              OLD_PURCHASE_ORDER_NUMBER,
                PURCHASE_ORDER_NUM              PURCHASE_ORDER_NUMBER,
                PUBLISH_FLAG                    OLD_PUBLISH_FLAG,
                PUBLISH_FLAG                    PUBLISH_FLAG,
                QA_COLLECTION_ID                OLD_QA_COLLECTION_ID,
                QA_COLLECTION_ID                QA_COLLECTION_ID,
                CONTRACT_ID                     OLD_CONTRACT_ID,
                CONTRACT_ID                     CONTRACT_ID,
                CONTRACT_NUMBER                 OLD_CONTRACT_NUMBER,
                CONTRACT_NUMBER                 CONTRACT_NUMBER,
                CONTRACT_SERVICE_ID             OLD_CONTRACT_SERVICE_ID,
                CONTRACT_SERVICE_ID             CONTRACT_SERVICE_ID,
                TIME_ZONE_ID                    OLD_TIME_ZONE_ID,
                TIME_ZONE_ID                    TIME_ZONE_ID,
                ACCOUNT_ID                      OLD_ACCOUNT_ID,
                ACCOUNT_ID                      ACCOUNT_ID,
                TIME_DIFFERENCE                 OLD_TIME_DIFFERENCE,
                TIME_DIFFERENCE                 TIME_DIFFERENCE,
                CUSTOMER_PO_NUMBER              OLD_CUSTOMER_PO_NUMBER,
                CUSTOMER_PO_NUMBER              CUSTOMER_PO_NUMBER,
                CUSTOMER_TICKET_NUMBER          OLD_CUSTOMER_TICKET_NUMBER,
                CUSTOMER_TICKET_NUMBER          CUSTOMER_TICKET_NUMBER,
                CUSTOMER_SITE_ID                OLD_CUSTOMER_SITE_ID,
                CUSTOMER_SITE_ID                CUSTOMER_SITE_ID,
                CALLER_TYPE                     OLD_CALLER_TYPE,
                CALLER_TYPE                     CALLER_TYPE,
                SECURITY_GROUP_ID               OLD_SECURITY_GROUP_ID,
                ORIG_SYSTEM_REFERENCE           OLD_ORIG_SYSTEM_REFERENCE,
                ORIG_SYSTEM_REFERENCE           ORIG_SYSTEM_REFERENCE,
                ORIG_SYSTEM_REFERENCE_ID        OLD_ORIG_SYSTEM_REFERENCE_ID,
                ORIG_SYSTEM_REFERENCE_ID        ORIG_SYSTEM_REFERENCE_ID,
                REQUEST_ID                      REQUEST_ID,
                PROGRAM_APPLICATION_ID          PROGRAM_APPLICATION_ID,
                PROGRAM_ID                      PROGRAM_ID,
                PROGRAM_UPDATE_DATE             PROGRAM_UPDATE_DATE,
                PROJECT_NUMBER                  OLD_PROJECT_NUMBER,
                PROJECT_NUMBER                  PROJECT_NUMBER,
                PLATFORM_VERSION                OLD_PLATFORM_VERSION,
                PLATFORM_VERSION                PLATFORM_VERSION,
                DB_VERSION                      OLD_DB_VERSION,
                DB_VERSION                      DB_VERSION,
                CUST_PREF_LANG_ID               OLD_CUST_PREF_LANG_ID,
                CUST_PREF_LANG_ID               CUST_PREF_LANG_ID,
                TIER                            OLD_TIER,
                TIER                            TIER,
                CATEGORY_ID                     OLD_CATEGORY_ID,
                CATEGORY_ID                     CATEGORY_ID,
                OPERATING_SYSTEM                OLD_OPERATING_SYSTEM,
                OPERATING_SYSTEM                OPERATING_SYSTEM,
                OPERATING_SYSTEM_VERSION        OLD_OPERATING_SYSTEM_VERSION,
                OPERATING_SYSTEM_VERSION        OPERATING_SYSTEM_VERSION,
                DATABASE                        OLD_DATABASE ,
                DATABASE                        DATABASE,
                GROUP_TERRITORY_ID              OLD_GROUP_TERRITORY_ID,
                GROUP_TERRITORY_ID              GROUP_TERRITORY_ID,
                COMM_PREF_CODE                  OLD_COMM_PREF_CODE,
                COMM_PREF_CODE                  COMM_PREF_CODE,
                LAST_UPDATE_CHANNEL             OLD_LAST_UPDATE_CHANNEL,
                LAST_UPDATE_CHANNEL             LAST_UPDATE_CHANNEL,
                CUST_PREF_LANG_CODE             OLD_CUST_PREF_LANG_CODE,
                CUST_PREF_LANG_CODE              CUST_PREF_LANG_CODE,
                ERROR_CODE                      OLD_ERROR_CODE,
                ERROR_CODE                      ERROR_CODE,
                CATEGORY_SET_ID                 OLD_CATEGORY_SET_ID,
                CATEGORY_SET_ID                 CATEGORY_SET_ID,
                EXTERNAL_REFERENCE              OLD_EXTERNAL_REFERENCE,
                EXTERNAL_REFERENCE              EXTERNAL_REFERENCE,
                INCIDENT_OCCURRED_DATE          OLD_INCIDENT_OCCURRED_DATE,
                INCIDENT_OCCURRED_DATE          INCIDENT_OCCURRED_DATE,
                INCIDENT_RESOLVED_DATE          OLD_INCIDENT_RESOLVED_DATE,
                INCIDENT_RESOLVED_DATE          INCIDENT_RESOLVED_DATE,
                INC_RESPONDED_BY_DATE           OLD_INC_RESPONDED_BY_DATE,
                INC_RESPONDED_BY_DATE           INC_RESPONDED_BY_DATE,
                INCIDENT_LOCATION_ID            OLD_INCIDENT_LOCATION_ID ,
                INCIDENT_LOCATION_ID            INCIDENT_LOCATION_ID,
                INCIDENT_ADDRESS                OLD_INCIDENT_ADDRESS,
                INCIDENT_ADDRESS                INCIDENT_ADDRESS,
                INCIDENT_CITY                   OLD_INCIDENT_CITY,
                INCIDENT_CITY                   INCIDENT_CITY,
                INCIDENT_STATE                  OLD_INCIDENT_STATE,
                INCIDENT_STATE                  INCIDENT_STATE,
                INCIDENT_COUNTRY                OLD_INCIDENT_COUNTRY,
                INCIDENT_COUNTRY                INCIDENT_COUNTRY,
                INCIDENT_PROVINCE               OLD_INCIDENT_PROVINCE,
                INCIDENT_PROVINCE               INCIDENT_PROVINCE,
                INCIDENT_POSTAL_CODE            OLD_INCIDENT_POSTAL_CODE,
                INCIDENT_POSTAL_CODE            INCIDENT_POSTAL_CODE,
                INCIDENT_COUNTY                 OLD_INCIDENT_COUNTY,
                INCIDENT_COUNTY                 INCIDENT_COUNTY,
                SR_CREATION_CHANNEL             OLD_SR_CREATION_CHANNEL,
                SR_CREATION_CHANNEL             SR_CREATION_CHANNEL,
                DEF_DEFECT_ID                   OLD_DEF_DEFECT_ID,
                DEF_DEFECT_ID                   DEF_DEFECT_ID,
                DEF_DEFECT_ID2                  OLD_DEF_DEFECT_ID2,
                DEF_DEFECT_ID2                  DEF_DEFECT_ID2,
                EXTERNAL_ATTRIBUTE_1            OLD_EXTERNAL_ATTRIBUTE_1,
                EXTERNAL_ATTRIBUTE_1            EXTERNAL_ATTRIBUTE_1,
                EXTERNAL_ATTRIBUTE_2            OLD_EXTERNAL_ATTRIBUTE_2,
                EXTERNAL_ATTRIBUTE_2            EXTERNAL_ATTRIBUTE_2,
                EXTERNAL_ATTRIBUTE_3            OLD_EXTERNAL_ATTRIBUTE_3,
                EXTERNAL_ATTRIBUTE_3            EXTERNAL_ATTRIBUTE_3,
                EXTERNAL_ATTRIBUTE_4            OLD_EXTERNAL_ATTRIBUTE_4,
                EXTERNAL_ATTRIBUTE_4            EXTERNAL_ATTRIBUTE_4,
                EXTERNAL_ATTRIBUTE_5            OLD_EXTERNAL_ATTRIBUTE_5,
                EXTERNAL_ATTRIBUTE_5            EXTERNAL_ATTRIBUTE_5,
                EXTERNAL_ATTRIBUTE_6            OLD_EXTERNAL_ATTRIBUTE_6,
                EXTERNAL_ATTRIBUTE_6            EXTERNAL_ATTRIBUTE_6,
                EXTERNAL_ATTRIBUTE_7            OLD_EXTERNAL_ATTRIBUTE_7,
                EXTERNAL_ATTRIBUTE_7            EXTERNAL_ATTRIBUTE_7,
                EXTERNAL_ATTRIBUTE_8            OLD_EXTERNAL_ATTRIBUTE_8,
                EXTERNAL_ATTRIBUTE_8            EXTERNAL_ATTRIBUTE_8,
                EXTERNAL_ATTRIBUTE_9            OLD_EXTERNAL_ATTRIBUTE_9,
                EXTERNAL_ATTRIBUTE_9            EXTERNAL_ATTRIBUTE_9,
                EXTERNAL_ATTRIBUTE_10            OLD_EXTERNAL_ATTRIBUTE_10,
                EXTERNAL_ATTRIBUTE_10            EXTERNAL_ATTRIBUTE_10,
                EXTERNAL_ATTRIBUTE_11            OLD_EXTERNAL_ATTRIBUTE_11,
                EXTERNAL_ATTRIBUTE_11            EXTERNAL_ATTRIBUTE_11,
                EXTERNAL_ATTRIBUTE_12            OLD_EXTERNAL_ATTRIBUTE_12,
                EXTERNAL_ATTRIBUTE_12            EXTERNAL_ATTRIBUTE_12,
                EXTERNAL_ATTRIBUTE_13            OLD_EXTERNAL_ATTRIBUTE_13,
                EXTERNAL_ATTRIBUTE_13            EXTERNAL_ATTRIBUTE_13,
                EXTERNAL_ATTRIBUTE_14            OLD_EXTERNAL_ATTRIBUTE_14,
                EXTERNAL_ATTRIBUTE_14            EXTERNAL_ATTRIBUTE_14,
                EXTERNAL_ATTRIBUTE_15            OLD_EXTERNAL_ATTRIBUTE_15,
                EXTERNAL_ATTRIBUTE_15            EXTERNAL_ATTRIBUTE_15,
                EXTERNAL_CONTEXT                 OLD_EXTERNAL_CONTEXT,
                EXTERNAL_CONTEXT                 EXTERNAL_CONTEXT,
                LAST_UPDATE_PROGRAM_CODE         OLD_LAST_UPDATE_PROGRAM_CODE,
                LAST_UPDATE_PROGRAM_CODE         LAST_UPDATE_PROGRAM_CODE,
                CREATION_PROGRAM_CODE            OLD_CREATION_PROGRAM_CODE,
                CREATION_PROGRAM_CODE            CREATION_PROGRAM_CODE,
                COVERAGE_TYPE                    OLD_COVERAGE_TYPE,
                COVERAGE_TYPE                    COVERAGE_TYPE,
                BILL_TO_ACCOUNT_ID               OLD_BILL_TO_ACCOUNT_ID,
                BILL_TO_ACCOUNT_ID               BILL_TO_ACCOUNT_ID,
                SHIP_TO_ACCOUNT_ID               OLD_SHIP_TO_ACCOUNT_ID,
                SHIP_TO_ACCOUNT_ID               SHIP_TO_ACCOUNT_ID,
                CUSTOMER_EMAIL_ID                OLD_CUSTOMER_EMAIL_ID,
                CUSTOMER_EMAIL_ID                CUSTOMER_EMAIL_ID,
                CUSTOMER_PHONE_ID                OLD_CUSTOMER_PHONE_ID,
                CUSTOMER_PHONE_ID                CUSTOMER_PHONE_ID,
                BILL_TO_PARTY_ID                 OLD_BILL_TO_PARTY_ID,
                BILL_TO_PARTY_ID                 BILL_TO_PARTY_ID,
                SHIP_TO_PARTY_ID                 OLD_SHIP_TO_PARTY_ID,
                SHIP_TO_PARTY_ID                 SHIP_TO_PARTY_ID,
                BILL_TO_SITE_ID                  OLD_BILL_TO_SITE_ID,
                BILL_TO_SITE_ID                  BILL_TO_SITE_ID,
                SHIP_TO_SITE_ID                  OLD_SHIP_TO_SITE_ID ,
                SHIP_TO_SITE_ID                  SHIP_TO_SITE_ID,
                PROGRAM_LOGIN_ID                 OLD_PROGRAM_LOGIN_ID,
                PROGRAM_LOGIN_ID                 PROGRAM_LOGIN_ID,
                INCIDENT_POINT_OF_INTEREST       OLD_INCIDENT_POINT_OF_INTEREST,
                INCIDENT_POINT_OF_INTEREST       INCIDENT_POINT_OF_INTEREST,
                INCIDENT_CROSS_STREET            OLD_INCIDENT_CROSS_STREET,
                INCIDENT_CROSS_STREET            INCIDENT_CROSS_STREET,
                INCIDENT_DIRECTION_QUALIFIER     OLD_INCIDENT_DIRECTION_QUALIF,
                INCIDENT_DIRECTION_QUALIFIER     INCIDENT_DIRECTION_QUALIF,
                INCIDENT_DISTANCE_QUALIFIER      OLD_INCIDENT_DISTANCE_QUALIF,
                INCIDENT_DISTANCE_QUALIFIER      INCIDENT_DISTANCE_QUALIF,
                INCIDENT_DISTANCE_QUAL_UOM       OLD_INCIDENT_DISTANCE_QUAL_UOM,
                INCIDENT_DISTANCE_QUAL_UOM       INCIDENT_DISTANCE_QUAL_UOM,
                INCIDENT_ADDRESS2                OLD_INCIDENT_ADDRESS2,
                INCIDENT_ADDRESS2                INCIDENT_ADDRESS2,
                INCIDENT_ADDRESS3                OLD_INCIDENT_ADDRESS3,
                INCIDENT_ADDRESS3                INCIDENT_ADDRESS3,
                INCIDENT_ADDRESS4                OLD_INCIDENT_ADDRESS4,
                INCIDENT_ADDRESS4                INCIDENT_ADDRESS4,
                INCIDENT_ADDRESS_STYLE           OLD_INCIDENT_ADDRESS_STYLE,
                INCIDENT_ADDRESS_STYLE           INCIDENT_ADDRESS_STYLE,
                INCIDENT_ADDR_LINES_PHONETIC     OLD_INCIDENT_ADDR_LNS_PHONETIC,
                INCIDENT_ADDR_LINES_PHONETIC     INCIDENT_ADDR_LNS_PHONETIC,
                INCIDENT_PO_BOX_NUMBER           OLD_INCIDENT_PO_BOX_NUMBER,
                INCIDENT_PO_BOX_NUMBER           INCIDENT_PO_BOX_NUMBER,
                INCIDENT_HOUSE_NUMBER            OLD_INCIDENT_HOUSE_NUMBER,
                INCIDENT_HOUSE_NUMBER            INCIDENT_HOUSE_NUMBER,
                INCIDENT_STREET_SUFFIX           OLD_INCIDENT_STREET_SUFFIX,
                INCIDENT_STREET_SUFFIX           INCIDENT_STREET_SUFFIX,
                INCIDENT_STREET                  OLD_INCIDENT_STREET,
                INCIDENT_STREET                  INCIDENT_STREET,
                INCIDENT_STREET_NUMBER           OLD_INCIDENT_STREET_NUMBER,
                INCIDENT_STREET_NUMBER           INCIDENT_STREET_NUMBER,
                INCIDENT_FLOOR                   OLD_INCIDENT_FLOOR,
                INCIDENT_FLOOR                   INCIDENT_FLOOR,
                INCIDENT_SUITE                   OLD_INCIDENT_SUITE,
                INCIDENT_SUITE                   INCIDENT_SUITE,
                INCIDENT_POSTAL_PLUS4_CODE       OLD_INCIDENT_POSTAL_PLUS4_CODE,
                INCIDENT_POSTAL_PLUS4_CODE       INCIDENT_POSTAL_PLUS4_CODE,
                INCIDENT_POSITION                OLD_INCIDENT_POSITION,
                INCIDENT_POSITION                INCIDENT_POSITION,
                INCIDENT_LOCATION_DIRECTIONS     OLD_INCIDENT_LOC_DIRECTIONS,
                INCIDENT_LOCATION_DIRECTIONS     INCIDENT_LOC_DIRECTIONS,
                INCIDENT_LOCATION_DESCRIPTION    OLD_INCIDENT_LOC_DESCRIPTION,
                INCIDENT_LOCATION_DESCRIPTION    INCIDENT_LOC_DESCRIPTION,
                INSTALL_SITE_ID                  OLD_INSTALL_SITE_ID,
                INSTALL_SITE_ID                  INSTALL_SITE_ID,
                INCIDENT_LAST_MODIFIED_DATE      INCIDENT_LAST_MODIFIED_DATE,
                TO_CHAR(null)                    UPDATED_ENTITY_CODE,
                TO_NUMBER(null)                  UPDATED_ENTITY_ID,
                TO_CHAR(null)                    ENTITY_ACTIVITY_CODE,
                TIER_VERSION                     OLD_TIER_VERSION,
                TIER_VERSION                     TIER_VERSION,
                OBJECT_VERSION_NUMBER            OLD_INC_OBJECT_VERSION_NUMBER ,
                OBJECT_VERSION_NUMBER            INC_OBJECT_VERSION_NUMBER,
                REQUEST_ID                       OLD_INC_REQUEST_ID,
                REQUEST_ID                       INC_REQUEST_ID,
                PROGRAM_APPLICATION_ID           OLD_INC_PROGRAM_APPLICATION_ID,
                PROGRAM_APPLICATION_ID           INC_PROGRAM_APPLICATION_ID,
                PROGRAM_ID                       OLD_INC_PROGRAM_ID,
                PROGRAM_ID                       INC_PROGRAM_ID,
                PROGRAM_UPDATE_DATE              OLD_INC_PROGRAM_UPDATE_DATE,
                PROGRAM_UPDATE_DATE              INC_PROGRAM_UPDATE_DATE,
                OWNING_DEPARTMENT_ID             OLD_OWNING_DEPARTMENT_ID ,
                OWNING_DEPARTMENT_ID             OWNING_DEPARTMENT_ID,
                INCIDENT_LOCATION_TYPE           OLD_INCIDENT_LOCATION_TYPE,
                INCIDENT_LOCATION_TYPE           INCIDENT_LOCATION_TYPE,
                UNASSIGNED_INDICATOR             OLD_UNASSIGNED_INDICATOR,
                UNASSIGNED_INDICATOR             UNASSIGNED_INDICATOR,
		MAINT_ORGANIZATION_ID            OLD_MAINT_ORGANIZATION_ID,
		MAINT_ORGANIZATION_ID            MAINT_ORGANIZATION_ID
         FROM   cs_incidents_all_b
        WHERE  incident_id = p_request_id;

    l_audit_vals_rec    CS_ServiceRequest_PVT.SR_AUDIT_REC_TYPE;
    l_api_name          CONSTANT VARCHAR2(30) := 'Prepare_Audit_Record';
    l_api_version       CONSTANT NUMBER       := 1.0;

  BEGIN

    -- Initialize return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN  l_ServiceRequest_csr;
  FETCH l_ServiceRequest_csr INTO x_audit_vals_rec;

  IF ( l_ServiceRequest_csr%NOTFOUND ) THEN

     CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg
                               ( p_token_an    =>  l_api_name,
                                 p_token_v     =>  TO_CHAR(p_request_id),
                                 p_token_p     =>  'p_request_id',
                                 p_table_name  =>  'CS_INCIDENTS_ALL_B',
                                 p_column_name => 'REQUEST_ID' );
     CLOSE l_ServiceRequest_csr;
  ELSE
     CLOSE l_ServiceRequest_csr;
  END IF;


 END Prepare_Audit_Record;
--
-- -------------------------------------------------------------------
-- Validate_Desc_Flex
-- -------------------------------------------------------------------

PROCEDURE Validate_Desc_Flex
( p_api_name			IN	VARCHAR2,
  p_application_short_name	IN	VARCHAR2,
  p_desc_flex_name		IN	VARCHAR2,
  p_desc_segment1		IN	VARCHAR2,
  p_desc_segment2		IN	VARCHAR2,
  p_desc_segment3		IN	VARCHAR2,
  p_desc_segment4		IN	VARCHAR2,
  p_desc_segment5		IN	VARCHAR2,
  p_desc_segment6		IN	VARCHAR2,
  p_desc_segment7		IN	VARCHAR2,
  p_desc_segment8		IN	VARCHAR2,
  p_desc_segment9		IN	VARCHAR2,
  p_desc_segment10		IN	VARCHAR2,
  p_desc_segment11		IN	VARCHAR2,
  p_desc_segment12		IN	VARCHAR2,
  p_desc_segment13		IN	VARCHAR2,
  p_desc_segment14		IN	VARCHAR2,
  p_desc_segment15		IN	VARCHAR2,
  p_desc_context		IN	VARCHAR2,
  p_resp_appl_id		IN	NUMBER		:= NULL,
  p_resp_id			IN	NUMBER		:= NULL,
  p_return_status		OUT	NOCOPY VARCHAR2
)
IS
  l_error_message	VARCHAR2(2000);
BEGIN
  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;


  IF ( p_desc_context   || p_desc_segment1  || p_desc_segment2  ||
       p_desc_segment3  || p_desc_segment4  || p_desc_segment5  ||
       p_desc_segment6  || p_desc_segment7  || p_desc_segment8  ||
       p_desc_segment9  || p_desc_segment10 || p_desc_segment11 ||
       p_desc_segment12 || p_desc_segment13 || p_desc_segment14 ||
       p_desc_segment15
     ) IS NOT NULL THEN

    FND_FLEX_DESCVAL.Set_Context_Value(p_desc_context);

    FND_FLEX_DESCVAL.Set_Column_Value('INCIDENT_ATTRIBUTE_1', p_desc_segment1);
    FND_FLEX_DESCVAL.Set_Column_Value('INCIDENT_ATTRIBUTE_2', p_desc_segment2);
    FND_FLEX_DESCVAL.Set_Column_Value('INCIDENT_ATTRIBUTE_3', p_desc_segment3);
    FND_FLEX_DESCVAL.Set_Column_Value('INCIDENT_ATTRIBUTE_4', p_desc_segment4);
    FND_FLEX_DESCVAL.Set_Column_Value('INCIDENT_ATTRIBUTE_5', p_desc_segment5);
    FND_FLEX_DESCVAL.Set_Column_Value('INCIDENT_ATTRIBUTE_6', p_desc_segment6);
    FND_FLEX_DESCVAL.Set_Column_Value('INCIDENT_ATTRIBUTE_7', p_desc_segment7);
    FND_FLEX_DESCVAL.Set_Column_Value('INCIDENT_ATTRIBUTE_8', p_desc_segment8);
    FND_FLEX_DESCVAL.Set_Column_Value('INCIDENT_ATTRIBUTE_9', p_desc_segment9);
    FND_FLEX_DESCVAL.Set_Column_Value('INCIDENT_ATTRIBUTE_10', p_desc_segment10);
    FND_FLEX_DESCVAL.Set_Column_Value('INCIDENT_ATTRIBUTE_11', p_desc_segment11);
    FND_FLEX_DESCVAL.Set_Column_Value('INCIDENT_ATTRIBUTE_12', p_desc_segment12);
    FND_FLEX_DESCVAL.Set_Column_Value('INCIDENT_ATTRIBUTE_13', p_desc_segment13);
    FND_FLEX_DESCVAL.Set_Column_Value('INCIDENT_ATTRIBUTE_14', p_desc_segment14);
    FND_FLEX_DESCVAL.Set_Column_Value('INCIDENT_ATTRIBUTE_15', p_desc_segment15);

    IF NOT FND_FLEX_DESCVAL.Validate_Desccols
             ( appl_short_name => p_application_short_name,
               desc_flex_name  => p_desc_flex_name,
               resp_appl_id    => p_resp_appl_id,
               resp_id         => p_resp_id
             ) THEN
      l_error_message := FND_FLEX_DESCVAL.Error_Message;
      CS_ServiceRequest_UTIL.Add_Desc_Flex_Msg(p_api_name, l_error_message);
      p_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END IF;

END Validate_Desc_Flex;
-- -----------------------------------------------------------------------------
-- Procedure Name : validate_party_role_code
-- Parameter      :
-- IN             : p_party_role_code    This is a foreign key to table
--                                       cs_pary_roles_b
--                : x_return_status      Indicates success or error condition
--                                       encountered by the procedure
-- Description    : This procedure checks whether party role code exist in
--                  party role table and is active on system date or not.
-- Modification History
-- Date     Name     Description
---------- -------- ------------------------------------------------------------
-- 04/21/05 smisra   Created
-- 05/12/05 smisra   Changed the database column names
--                   effective_[start|end]_date to [start|end]_date_active
-- -----------------------------------------------------------------------------
PROCEDURE validate_party_role_code
( p_party_role_code IN         VARCHAR2
, x_return_status   OUT NOCOPY VARCHAR2
) IS
l_start_dt DATE;
l_end_dt   DATE;
l_sys_dt   DATE;
CURSOR c_party_role IS
  SELECT
    NVL(start_date_active, SYSDATE-1)
  , NVL(end_date_active  , SYSDATE+1)
  FROM
    cs_party_roles_b
  WHERE party_role_code = p_party_role_code;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_sys_dt := SYSDATE;
  IF p_party_role_code <> 'CONTACT'
  THEN
    OPEN  c_party_role;
    FETCH c_party_role INTO l_start_dt, l_end_dt;

    IF c_party_role % NOTFOUND
    THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.set_name('CS','CS_SR_PARTY_ROLE_NE');
      FND_MESSAGE.set_token('API_NAME','cs_servicerequest_util.validate_party_role_code');
      FND_MESSAGE.set_token('PARTY_ROLE_CODE',p_party_role_code);
      FND_MSG_PUB.add_detail(p_associated_column1 => 'cs_hz_sr_contact_points.party_role_code');
      --FND_MSG_PUB.ADD_DETAIL(p_associated_column1 => l_associated_col1);
    ELSIF l_sys_dt < NVL(l_start_dt, l_sys_dt) OR
          l_sys_dt > NVL(l_end_dt  , l_sys_dt)
    THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.set_name('CS','CS_SR_PARTYROLE_INACTIVE');
      FND_MESSAGE.set_token('API_NAME','cs_servicerequest_util.validate_party_role_code');
      FND_MESSAGE.set_token('PARTY_ROLE_CODE',p_party_role_code);
      FND_MSG_PUB.add_detail(p_associated_column1 => 'cs_hz_sr_contact_points.party_role_code');
    END IF;
    CLOSE c_party_role;
  END IF;
--
EXCEPTION
  WHEN OTHERS THEN
    IF c_party_role%ISOPEN
    THEN
      CLOSE c_party_role;
    END IF;
    FND_MESSAGE.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
    FND_MESSAGE.set_token('P_TEXT','CS_SERVICEREQUEST_UTIL.validate_party_role_code'||'-'||SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END validate_party_role_code;
-- -----------------------------------------------------------------------------
-- Procedure Name : validate_org_id
-- Parameter      :
-- IN             : p_org_id        This is a foreign key to table
--                                  hr_all_organization_units
--                : x_return_status Indicates success or error condition
--                                  encountered by the procedure
-- Description    : This procedure checks whether org id exist in
--                  hr organization table and is active on system date or not.
-- Modification History
-- Date     Name     Description
---------- -------- ------------------------------------------------------------
-- 04/21/05 smisra   Created
-- 08/15/05 smisra   Changed the table name from hr_all_organization_units to
--                   hr_operating_units
-- 8/25/05 smisra    truncated local variable l_sys_dt because table
--                   hr_operating_units does not store time component.
-- -----------------------------------------------------------------------------
PROCEDURE validate_org_id
( p_org_id NUMBER
, x_return_status OUT NOCOPY VARCHAR2
) IS
l_dt_from  DATE;
l_dt_to    DATE;
l_sys_dt   DATE;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_sys_dt := TRUNC(SYSDATE);
  SELECT
    date_from
  , date_to
  INTO
    l_dt_from
  , l_dt_to
  FROM
    hr_operating_units
  WHERE organization_id = p_org_id;
  IF l_sys_dt < NVL(l_dt_from, l_sys_dt) OR
     l_sys_dt > NVL(l_dt_to  , l_sys_dt)
  THEN
    FND_MESSAGE.set_name ('CS', 'CS_SR_ORG_ID_INACTIVE');
    FND_MESSAGE.set_token ('API_NAME', 'CS_SERVICEREQUEST_UTIL.validate_org_id');
    FND_MESSAGE.set_token ('ORG_ID', p_org_id);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    Add_Invalid_Argument_Msg
    ( p_token_an    => 'cs_servicerequest_util.validate_org_id'
    , p_token_v     => TO_CHAR(p_org_id)
    , p_token_p     => 'p_org_id'
    , p_table_name  => G_TABLE_NAME
    , p_column_name => 'ORG_ID'
    );
   WHEN OTHERS THEN
     fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
     fnd_message.set_token ('P_TEXT','cs_servicerequest_util.validate_org_id'||'-'||SQLERRM);
     fnd_msg_pub.ADD;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END validate_org_id;
-- -----------------------------------------------------------------------------
-- Procedure Name : validate_maint_organization_id
-- Parameter      :
-- IN             : p_maint_organization_id maintenance organization
--                : p_inventory_org_id      Inventory organization id
--                : p_inv_org_master_org_flag
--                                          Indicates if inv org is a master Org
-- OUT            : x_return_stauts         indicates if validation failed or
--                                          succeeded
-- Description    : This procedure check if maint org exists in mtl paramters
--                  table, it is EAM enable. If inventory org is passed then
--                  it should be same as master organization associated with
--                  maintenance organization.
-- Modification History
-- Date     Name     Description
----------- -------- -----------------------------------------------------------
-- 05/05/05 smisra   Created
-- 08/03/05 smisra   Add param p_inv_org_master_org_flag
--                   if p_inv_org_master_org_flag is 'Y' then master org for
--                   maint_organization should be same as inv org
-- -----------------------------------------------------------------------------
PROCEDURE validate_maint_organization_id
( p_maint_organization_id   IN         NUMBER
, p_inventory_org_id        IN         NUMBER
, p_inv_org_master_org_flag IN         VARCHAR2
, x_return_status           OUT NOCOPY VARCHAR2
) IS
l_eam_enabled   mtl_parameters.eam_enabled_flag       % TYPE;
l_maint_org_id  mtl_parameters.maint_organization_id  % TYPE;
l_master_org_id mtl_parameters.master_organization_id % TYPE;
l_api_name_full VARCHAR2(61);
l_col           VARCHAR2(61);
BEGIN
  l_api_name_full := G_PKG_NAME || '.validate_maint_organization_id';
  l_col := G_TABLE_NAME || '.MAINT_ORGANIZATION_ID';
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF p_inv_org_master_org_flag = 'N' -- means inv org is not a master org
  THEN
    get_org_details
    ( p_org_id           => p_inventory_org_id
    , x_eam_enabled_flag => l_eam_enabled
    , x_maint_org_id     => l_maint_org_id
    , x_master_org_id    => l_master_org_id
    , x_return_Status    => x_return_status
    );
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
      Add_Invalid_Argument_Msg
      ( p_token_an    => l_api_name_full
      , p_token_v     => to_char(p_inventory_org_id)
      , p_token_p     => 'p_inventory_org_id'
      , p_table_name  => G_TABLE_NAME
      , p_column_name => 'INVENTORY_ORG_ID'
      );
    ELSIF NVL(l_maint_org_id,-99) <> p_maint_organization_id
    THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.set_name  ('CS'      , 'CS_SR_INV_ORG_NOT_MAINT_BY');
      FND_MESSAGE.set_token ('API_NAME', l_api_name_full);
      FND_MESSAGE.set_token ('MAINT_ORG_ID'   , TO_CHAR(p_maint_organization_id));
      FND_MESSAGE.set_token ('INV_ORG_ID'   , TO_CHAR(p_inventory_org_id));
      FND_MSG_PUB.add_detail(p_associated_column1 => l_col);
    END IF;
  ELSE -- inv org is a master org or inv org is not passed
    get_org_details
    ( p_org_id           => p_maint_organization_id
    , x_eam_enabled_flag => l_eam_enabled
    , x_maint_org_id     => l_maint_org_id
    , x_master_org_id    => l_master_org_id
    , x_return_Status    => x_return_status
    );
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
      Add_Invalid_Argument_Msg
      ( p_token_an    => l_api_name_full
      , p_token_v     => to_char(p_maint_organization_id)
      , p_token_p     => 'p_maint_organization_id'
      , p_table_name  => G_TABLE_NAME
      , p_column_name => 'MAINT_ORGANIZATION_ID'
      );
    ELSIF l_eam_enabled <> 'Y'
    THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.set_name  ('CS'      , 'CS_SR_MAINT_ORG_NON_EAM');
      FND_MESSAGE.set_token ('API_NAME', l_api_name_full);
      FND_MESSAGE.set_token ('MAINT_ORG_ID', TO_CHAR(p_maint_organization_id));
      FND_MSG_PUB.add_detail(p_associated_column1 => l_col);
    ELSIF p_inventory_org_id IS NOT NULL AND
          p_inventory_org_id <> FND_API.G_MISS_NUM AND
          p_inventory_org_id <> l_master_org_id
    THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.set_name  ('CS'        , 'CS_SR_MAINT_INV_ORG_MISMATCH');
      FND_MESSAGE.set_token ('API_NAME'  , l_api_name_full);
      FND_MESSAGE.set_token ('MAINT_ORG_ID' , TO_CHAR(p_maint_organization_id));
      FND_MSG_PUB.add_detail(p_associated_column1 => l_col);
    END IF;
  END IF;

END validate_maint_organization_id;
-- -----------------------------------------------------------------------------
-- Procedure Name : validate_customer_product_id
-- Parameter      :
-- IN             : p_customer_product_id   This foreign key to
--                                          csi_item_instances table.
--                : p_customer_id           Service Request customer
--                : p_inventory_org_id      Inventory organization id
--                : p_maint_organization_id maintenance organization
--                : p_inv_org_master_org_flag
--                                          Indicates if inv org is a master Org
-- OUT            : x_inventory_item_id     Inventory item associated with
--                                          customer product
--                : x_return_stauts         indicates if validation failed or
--                                          succeeded
-- Description    : This procedure performs following checks
--                  1. customer product should exist in csi_item_instances table
--                  2. service request customer should be related to customer
--                      product
--                  3. Inventory item associated with customer product should
--                     3.1 enabled
--                     3.2 Service Request enabled
--                  4. If maintenance organization is passed then validation org
--                     associated with customer product should be same as
--                     maint org or should be maintained by maintenance org
--                  5. if profile 'CS_SR_RESTRICT_IB is 'YES' then customer
--                     should be installed at a HZ_PARTY_SITE or HZ_LOCATION
-- Modification History
-- Date     Name     Description
----------- -------- -----------------------------------------------------------
-- 05/06/05 smisra   Created
-- 08/03/05 smisra   Add param p_inv_org_master_org_flag
-- 08/29/05 smisra   Corrected message codes and tokens
-- 10/27/05 smisra   Correct token name for message CS_SR_LVD_ORG_NOT_MAINT_BY
--                   removed variable l_return_Status as it is not used
--                   replaced hard coded procedure name in set token calls with
--                   a variable to avoid spelling differences
-- -----------------------------------------------------------------------------
PROCEDURE validate_customer_product_id
( p_customer_product_id     IN            NUMBER
, p_customer_id             IN            NUMBER
, p_inventory_org_id        IN            NUMBER
, p_maint_organization_id   IN            NUMBER
, p_inv_org_master_org_flag IN            VARCHAR2
, p_inventory_item_id       IN OUT NOCOPY NUMBER
, x_return_status              OUT NOCOPY VARCHAR2
) IS
--
CURSOR c_prod_rel IS
SELECT 1
FROM csi_i_parties
WHERE instance_id        = p_customer_product_id
  AND party_id           = p_customer_id
  AND party_source_table = 'HZ_PARTIES';

l_party_id          csi_i_parties.party_id                      % TYPE;
l_source_table      csi_item_instances.owner_party_source_table % TYPE;
l_loc_type          csi_item_instances.location_type_code       % TYPE;
l_external_ref      csi_item_instances.external_reference        % TYPE;
l_serial_number     csi_item_instances.serial_number            % TYPE;
l_inv_org_id        mtl_parameters.organization_id              % TYPE;
l_maint_org_id      mtl_parameters.organization_id              % TYPE;
l_master_org_id     mtl_parameters.organization_id              % TYPE;
l_eam_enabled_flag  mtl_parameters.eam_enabled_flag             % TYPE;
l_eam_type          mtl_system_items_b.eam_item_type            % TYPE;
l_inv_item_id       mtl_system_items_b.inventory_item_id        % TYPE;
l_enabled_flag      mtl_system_items_b.enabled_flag             % TYPE;
l_last_vld_org_id   mtl_system_items_b.inventory_item_id        % TYPE;
l_serv_req_enabled  mtl_system_items_b.serv_req_enabled_code    % TYPE;
l_sys_dt            DATE;
l_end_dt            DATE;
l_start_dt          DATE;
l_dummy             NUMBER;
l_proc_name         VARCHAR2(61);
BEGIN
  l_sys_dt    := SYSDATE;
  l_proc_name := 'CS_SERVICEREQUEST_UTIL.validate_customer_product_id';
  get_customer_product_details
  ( p_customer_product_id   => p_customer_product_id
  , x_party_source_table    => l_source_table
  , x_party_id              => l_party_id
  , x_inv_master_org_id     => l_inv_org_id
  , x_inv_item_id           => l_inv_item_id
  , x_maint_org_id          => l_last_vld_org_id
  , x_external_reference    => l_external_ref
  , x_serial_number         => l_serial_number
  , x_start_dt_active       => l_start_dt
  , x_end_dt_active         => l_end_dt
  , x_loc_type              => l_loc_type
  , x_return_status         => x_return_status
  );
  IF x_return_status <> FND_API.G_RET_STS_SUCCESS
  THEN
    RAISE NO_DATA_FOUND;
  END IF;
  --
  IF l_sys_dt < NVL(l_start_dt, l_sys_dt) OR
     l_sys_dt > NVL(l_end_dt  , l_sys_dt)
  THEN
    FND_MESSAGE.set_name('CS','CS_SR_CP_INACTIVE');
    FND_MESSAGE.set_token('CP_ID',TO_CHAR(p_customer_product_id));
    FND_MESSAGE.set_token('API_NAME'  , l_proc_name);
    FND_MSG_PUB.add_detail(p_associated_column1=> 'CS_INCIDENTS_ALL_B.CUSTOMER_PRODUCT_ID');
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  --
  IF CS_SERVICEREQUEST_PVT.g_restrict_ib = 'YES' AND
     l_loc_type NOT IN ('HZ_PARTY_SITES', 'HZ_LOCATIONS')
  THEN
    FND_MESSAGE.set_name('CS','CS_SR_CP_LOCATION_INVALID'); -- Customer porduct installed location is invalid
    FND_MESSAGE.set_token('LOC',l_loc_type);
    FND_MESSAGE.set_token('CP_ID',TO_CHAR(p_customer_product_id));
    FND_MESSAGE.set_token('API_NAME'  , l_proc_name);
    FND_MSG_PUB.add_detail(p_associated_column1=> 'CS_INCIDENTS_ALL_B.CUSTOMER_PRODUCT_ID');
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  --
  IF NVL(l_source_table,'#') <> 'HZ_PARTIES'
  THEN
    FND_MESSAGE.set_name('CS','CS_SR_CP_CUST_SOURCE_INVALID'); -- product is not for TCA parties
    FND_MESSAGE.set_token('PARTY_SOURCE',l_source_table);
    FND_MESSAGE.set_token('CP_ID',TO_CHAR(p_customer_product_id));
    FND_MSG_PUB.add_detail(p_associated_column1=> 'CS_INCIDENTS_ALL_B.CUSTOMER_PRODUCT_ID');
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  --
  IF p_customer_id <> NVL(l_party_id,-1)
  THEN
    OPEN c_prod_rel;
    FETCH c_prod_rel into l_dummy;
    IF c_prod_rel % NOTFOUND
    THEN
      FND_MESSAGE.set_name('CS','CS_SR_CP_CUST_INVALID'); -- cust not related to product
      FND_MESSAGE.set_token('CP_ID',TO_CHAR(p_customer_product_id));
      FND_MESSAGE.set_token('CUST_ID',TO_CHAR(p_customer_id));
      FND_MSG_PUB.add_detail(p_associated_column1=> 'CS_INCIDENTS_ALL_B.CUSTOMER_PRODUCT_ID');
      CLOSE c_prod_rel;
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      CLOSE c_prod_rel;
    END IF;
  END IF;
  --
  -- if inventory item is passed and is same as inv item associated with
  -- customer product then no need to check various flags associated with in v item
  -- because these checks were already performed during inv item validation.
  IF l_inv_item_id <> NVL(p_inventory_item_id,-1)
  THEN
    -- get item_details
    get_item_details
    ( p_inventory_org_id  => p_inventory_org_id
    , p_inv_item_id       => l_inv_item_id
    , x_enabled_flag      => l_enabled_flag
    , x_serv_req_enabled  => l_serv_req_enabled
    , x_eam_item_type     => l_eam_type
    , x_start_date_active => l_start_dt
    , x_end_date_active   => l_end_dt
    , x_return_status     => x_return_status
    );
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
      FND_MESSAGE.set_name('CS','CS_SR_CP_ITEM_ID'); -- item associated with CP does not exists
      FND_MESSAGE.set_token('CP_ID',TO_CHAR(p_customer_product_id));
      FND_MESSAGE.set_token('INV_ITEM_ID',TO_CHAR(l_inv_item_id));
      FND_MSG_PUB.add_detail(p_associated_column1=> 'CS_INCIDENTS_ALL_B.CUSTOMER_PRODUCT_ID');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF l_enabled_flag <> 'Y'
    THEN
      FND_MESSAGE.set_name('CS','CS_SR_CP_ITEM_DISABLED'); -- item associated with CP is not enabled
      FND_MESSAGE.set_token('CP_ID',TO_CHAR(p_customer_product_id));
      FND_MESSAGE.set_token('INV_ITEM_ID',TO_CHAR(l_inv_item_id));
      FND_MESSAGE.set_token('API_NAME'  , l_proc_name);
      FND_MSG_PUB.add_detail(p_associated_column1=> 'CS_INCIDENTS_ALL_B.CUSTOMER_PRODUCT_ID');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF l_serv_req_enabled <> 'E'
    THEN
      FND_MESSAGE.set_name('CS','CS_SR_CP_ITEM_NOT_SERV'); -- item associated with CP is not serviceable
      FND_MESSAGE.set_token('CP_ID',TO_CHAR(p_customer_product_id));
      FND_MESSAGE.set_token('INV',TO_CHAR(l_inv_item_id));
      FND_MESSAGE.set_token('API_NAME'  , l_proc_name);
      FND_MSG_PUB.add_detail(p_associated_column1=> 'CS_INCIDENTS_ALL_B.CUSTOMER_PRODUCT_ID');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF l_sys_dt < NVL(l_start_dt,l_sys_dt) OR
       l_sys_dt > NVL(l_end_dt  ,l_sys_dt)
    THEN
      FND_MESSAGE.set_name('CS','CS_SR_CP_ITEM_INACTIVE'); --Item associated with CP is inactive
      FND_MESSAGE.set_token('CP_ID',TO_CHAR(p_customer_product_id));
      FND_MESSAGE.set_token('INV_ITEM_ID',TO_CHAR(l_inv_item_id));
      FND_MSG_PUB.add_detail(p_associated_column1=> 'CS_INCIDENTS_ALL_B.CUSTOMER_PRODUCT_ID');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- All validations succeeded, so assign item for CP to p_inventory_item_id
    p_inventory_item_id := l_inv_item_id;
  END IF;
    -- Get org infor for last_vld_org
  IF p_maint_organization_id IS NOT NULL
  THEN
    get_org_details
    ( p_org_id           => l_last_vld_org_id
    , x_eam_enabled_flag => l_eam_enabled_flag
    , x_maint_org_id     => l_maint_org_id
    , x_master_org_id    => l_master_org_id
    , x_return_Status    => x_return_status
    );
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
      FND_MESSAGE.set_name('CS','CS_SR_CP_LAST_VLD_ORG'); -- Last validation org does not exists
      FND_MESSAGE.set_token('CP_ID',TO_CHAR(p_customer_product_id));
      FND_MESSAGE.set_token('MAINT_ORG_ID',TO_CHAR(l_last_vld_org_id));
      FND_MSG_PUB.add_detail(p_associated_column1=> 'CS_INCIDENTS_ALL_B.CUSTOMER_PRODUCT_ID');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    /* last vlg org may not be eam enabled but it might be maintained bu maint org
       so no need for this check
    IF l_eam_enabled_flag <> 'Y'
    THEN
      FND_MESSAGE.set_name('CS','CS_SR_CP_MAINT_EAM'); -- Maintenance Organization is NOT Eam Enabled
      FND_MESSAGE.set_token('MAINT_ORG_ID',TO_CHAR(p_maint_organization_id));
      FND_MSG_PUB.add_detail(p_associated_column1=> 'CS_INCIDENTS_ALL_B.CUSTOMER_PRODUCT_ID');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
     */
    IF l_maint_org_id <> p_maint_organization_id
    THEN
      FND_MESSAGE.set_name('CS','CS_SR_LVD_ORG_NOT_MAINT_BY'); -- CP is not maintained by Maintenance Organization
      FND_MESSAGE.set_token('API_NAME'  , l_proc_name);
      FND_MESSAGE.set_token('MAINT_ORG_ID',TO_CHAR(p_maint_organization_id));
      FND_MESSAGE.set_token('VAL_ORG_ID',TO_CHAR(l_maint_org_id));
      FND_MSG_PUB.add_detail(p_associated_column1=> 'CS_INCIDENTS_ALL_B.CUSTOMER_PRODUCT_ID');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    IF p_inv_org_master_org_flag = 'Y' AND
       l_master_org_id <> p_inventory_org_id
    THEN
      FND_MESSAGE.set_name('CS','CS_SR_VLD_INV_ORG_MISMATCH');
      FND_MESSAGE.set_token('VAL_ORG',TO_CHAR(l_maint_org_id));
      FND_MSG_PUB.add_detail(p_associated_column1=> 'CS_INCIDENTS_ALL_B.CUSTOMER_PRODUCT_ID');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF; -- p_maint_organization check
--
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    Add_Invalid_Argument_Msg
    ( p_token_an    => l_proc_name
    , p_token_v     => TO_CHAR(p_customer_product_id)
    , p_token_p     => 'customer_product_id'
    , p_table_name  => G_TABLE_NAME
    , p_column_name => 'CUSTOMER_PRODUCT_ID'
    );
  WHEN FND_API.G_EXC_ERROR  THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
END validate_customer_product_id;
-- -----------------------------------------------------------------------------
-- Procedure Name : get_reacted_resolved_dates
-- Parameter      :
-- IN             : p_incident_status_id         This foreign key to
--                                               cs_incideent_statuses_b
--                : p_old_incident_status_id     This foreign key to
--                                               cs_incideent_statuses_b
--                : p_old_incident_resolved_date old value of resolution date
--                : p_old_inc_responded_by_date  old value of response date
-- OUT            : x_incident_resolved_date     New value of resolution date
--                : x_inc_responded_by_date      New value of response date
--                : x_return_stauts              indicates if validation failed
--                                               or succeeded
-- Description    : This procedure defaults incident resolved and responded
--                  dates based on old and new value of service request status
-- Modification History
-- Date     Name     Description
-- -------- -------- -----------------------------------------------------------
-- 06/28/05 smisra   Created
-- 04/06/09 rtripath fix bug 8393539 return old value if flags are not set
-- -----------------------------------------------------------------------------
PROCEDURE get_reacted_resolved_dates
( p_incident_status_id         IN            NUMBER
, p_old_incident_status_id     IN            NUMBER
, p_old_inc_responded_by_date  IN            DATE
, p_old_incident_resolved_date IN            DATE
, x_inc_responded_by_date      IN OUT NOCOPY DATE
, x_incident_resolved_date     IN OUT NOCOPY DATE
, x_return_status                 OUT NOCOPY VARCHAR2
) IS
l_new_responded_flag   CS_INCIDENT_STATUSES_B.responded_flag % TYPE;
l_old_responded_flag   CS_INCIDENT_STATUSES_B.responded_flag % TYPE;
l_new_resolved_flag    CS_INCIDENT_STATUSES_B.resolved_flag  % TYPE;
l_old_resolved_flag    CS_INCIDENT_STATUSES_B.resolved_flag  % TYPE;
BEGIN
  -- Logic added for 11.5.10 enhancement : Usability changes
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  SELECT
    responded_flag
  , resolved_flag
  INTO
    l_new_responded_flag
  , l_new_resolved_flag
  FROM  cs_incident_statuses_vl
  WHERE incident_status_id=p_incident_status_id ;

  SELECT
    responded_flag
  , resolved_flag
  INTO
    l_old_responded_flag
  , l_old_resolved_flag
  FROM  cs_incident_statuses_vl
  WHERE incident_status_id=p_old_incident_status_id ;

  IF((l_old_responded_flag <>'Y' OR l_old_responded_flag is NULL) AND
     (l_new_responded_flag='Y'))
  THEN
    IF(x_inc_responded_by_date is NULL )
    THEN
      IF (p_old_inc_responded_by_date is NULL )
      THEN
         x_inc_responded_by_date:=SYSDATE;
      ELSE
        x_inc_responded_by_date:=p_old_inc_responded_by_date;
      END IF;
    END IF;
  ELSIF((l_old_responded_flag ='Y') AND (l_new_responded_flag='Y'))
  THEN
    IF (x_inc_responded_by_date is NULL)
    THEN
      IF (p_old_inc_responded_by_date is NULL)
      THEN
        x_inc_responded_by_date:=SYSDATE;
      ELSE
        x_inc_responded_by_date:=p_old_inc_responded_by_date;
      END IF;
    END IF;
  ELSIF((l_old_responded_flag ='Y') AND (l_new_responded_flag <> 'Y' OR
         l_new_responded_flag is NULL))
    THEN
    IF (x_inc_responded_by_date is NULL)
    THEN
       x_inc_responded_by_date:=p_old_inc_responded_by_date;
    END IF;
    END IF;
    -- fix for bug 8393539
  --ELSE
       --x_inc_responded_by_date:=p_old_inc_responded_by_date;
  --END IF;
--commented for 8507917
  IF((l_old_resolved_flag <> 'Y' OR l_old_resolved_flag is NULL) AND
    (l_new_resolved_flag='Y'))
  THEN
    IF (x_incident_resolved_date is NULL) THEN
      IF (p_old_incident_resolved_date is NULL )THEN
        x_incident_resolved_date:=SYSDATE;
      ELSE
        x_incident_resolved_date:=p_old_incident_resolved_date;
      END IF;
    END IF;
  ELSIF ((l_old_resolved_flag='Y') AND
         (l_new_resolved_flag  <> 'Y' OR l_new_resolved_flag is NULL))
  THEN
    IF(x_incident_resolved_date is NULL AND
       p_old_incident_resolved_date is NOT NULL)
    THEN
        x_incident_resolved_date:=NULL;
    END IF;
  ELSIF((l_old_resolved_flag='Y') AND (l_new_resolved_flag ='Y' )) THEN
    IF(x_incident_resolved_date is NULL AND
       p_old_incident_resolved_date is NOT NULL) THEN
      x_incident_resolved_date:=p_old_incident_resolved_date;
    ELSIF (x_incident_resolved_date is NULL AND
           p_old_incident_resolved_date is NULL) THEN
      x_incident_resolved_date:=SYSDATE;
    END IF ;
    END IF;

    -- fix for bug 8393539
  --ELSE
     -- x_incident_resolved_date:=p_old_incident_resolved_date;
     --END IF;
  -- commented for bug 8507917
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
    FND_MESSAGE.set_token
    ( 'P_TEXT'
    , 'CS_SERVICEREQUEST_UTIL.get_status_details'||'-'||SQLERRM
    );
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END get_reacted_resolved_dates;
-- -----------------------------------------------------------------------------
-- Procedure Name : get_party_details
-- Parameter      :
-- IN             : p_party_id           This is a foreign key to table
--                                       hz_parties
-- OUT            : x_party_type         it is the party type associated with
--                : x_status             represents active or inactive status
--                                       of party_id
--                                       party id
--                : x_return_status      Indicates success or error condition
--                                       encountered by the procedure
-- Description    : This procedure returns party type for a given party id
--                  if party id does not exist then it returns an error
-- Modification History
-- Date     Name     Description
---------- -------- ------------------------------------------------------------
-- 08/04/05 smisra   Created
---------- -------- ------------------------------------------------------------
PROCEDURE get_party_details
( p_party_id      IN            NUMBER
, x_party_type       OUT NOCOPY VARCHAR2
, x_status           OUT NOCOPY VARCHAR2
, x_return_status    OUT NOCOPY VARCHAR2
) IS
BEGIN
  -- Initialize Return Status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SELECT
    party_type
  , status
  INTO
    x_party_type
  , x_status
  FROM
     hz_parties a
  WHERE a.party_id = p_party_id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

  WHEN OTHERS THEN
    fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
    fnd_message.set_token
    ( 'P_TEXT'
    , 'CS_SERVICEREQUEST_UTIL.get_party_detail:'||'-'||SQLERRM
    );
    fnd_msg_pub.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END get_party_details;
-- -----------------------------------------------------------------------------
-- Procedure Name : update_task_address
-- Parameter      :
-- IN             : p_incident_id        This is a foreign key to table
--                                       cs_incidents_all_b
-- OUT            : p_location_type      This is location type of service
--                                       request
--                : p_location_id        This is incident location id of
--                                       service request
--                : x_return_status      Indicates success or error condition
--                                       encountered by the procedure
-- Description    : This procedure find all tasks for a service request and
--                  updates location id or address id of tasks depending on
--                  location type value of parameter location type.
--                  if location type is HZ_LOCATION then task.address_id
--                  is set to null, location id is set to parameter
--                  p_location_id otherwise task location is is set to null and
--                  task address id is set to parameter p_location id.
-- Modification History
-- Date     Name     Description
---------- -------- ------------------------------------------------------------
-- 10/04/05 smisra   Created
-- 10/06/05 smisra   modified query to get SR tasks so that rejected tasks too
--                   get selected.
-- 10/14/05 smisra   uncommented x_retrun_status setting
---------- -------- ------------------------------------------------------------
PROCEDURE update_task_address
( p_incident_id   IN         NUMBER
, p_location_type IN         VARCHAR2
, p_location_id   IN         NUMBER
, p_old_location_id   IN     NUMBER    -- Bug 8947959
, x_return_status OUT NOCOPY VARCHAR2
) IS
--
CURSOR c_tasks IS
 SELECT
   task.task_id
 , task.object_version_number
 , DECODE(typ.rule, 'DISPATCH', 'Y', 'N') fs_task
 , address_id -- Bug 8947959
 , location_id -- Bug 8947959
 FROM
   jtf_tasks_b          task
 , jtf_task_statuses_b  stat
 , jtf_task_types_b     typ
 WHERE source_object_type_code = 'SR'
   AND source_object_id        = p_incident_id
   AND stat.task_status_id     = task.task_status_id
   AND typ.task_type_id        = task.task_type_id
   AND NVL(stat.completed_flag, 'N') <> 'Y'
   AND NVL(stat.closed_flag   , 'N') <> 'Y'
   AND NVL(stat.cancelled_flag, 'N') <> 'Y'
 ;
l_site_id     cs_incidents_all_b.incident_location_id % TYPE;
l_location_id cs_incidents_all_b.incident_location_id % TYPE;
l_msg_count   NUMBER;
l_msg_data    VARCHAR2(4000);

l_upd_task Varchar2(2) := 'N'; -- Bug 8947959
--
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --
  FOR task_rec in c_tasks LOOP
    -- set address variables
    -- Start Bug 8947959
    If task_rec.address_id is not null and task_rec.address_id = p_old_location_id Then
       l_upd_task := 'Y';
    Elsif task_rec.location_id is not null and task_rec.location_id = p_old_location_id Then
       l_upd_task := 'Y';
    Else
       l_upd_task := 'N';
    End If;
    -- End bug 8947959
    If l_upd_task = 'Y' Then -- bug 8947959
    IF p_location_type = 'HZ_LOCATION'
    THEN
      l_location_id := p_location_id;
      l_site_id     := NULL;
    ELSE
      l_location_id := NULL;
      l_site_id     := p_location_id;
    END IF;
    --
    IF task_rec.fs_task = 'Y'
    THEN
      IF p_location_id IS NULL
      THEN
        FND_MESSAGE.set_name ('CS', 'CS_SR_OPEN_FS_TASKS');
        FND_MESSAGE.set_token
        ( 'API_NAME'
        , 'CS_SERVICEREQUEST_UTIL.update_task_address'
        );
        FND_MSG_PUB.ADD_DETAIL
        ( p_associated_column1 => 'CS_INCIDENTS_ALL_B.incident_location_id'
        );
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    --
    -- Call task update APIs
    --
    IF task_rec.fs_task = 'Y'
    THEN
      CSF_TASKS_PUB.update_task
      ( p_api_version           => 1.0
      , p_task_id               => task_rec.task_id
      , p_object_version_number => task_rec.object_version_number
      , p_location_id           => l_location_id
      , p_address_id            => l_site_id
      , x_return_status         => x_return_status
      , x_msg_count             => l_msg_count
      , x_msg_data              => l_msg_data
      );
    ELSE
      JTF_TASKS_PUB.update_task
      ( p_api_version           => 1.0
      , p_task_id               => task_rec.task_id
      , p_object_version_number => task_rec.object_version_number
      , p_location_id           => l_location_id
      , p_address_id            => l_site_id
      , p_enable_workflow       => FND_API.G_MISS_CHAR
      , p_abort_workflow        => FND_API.G_MISS_CHAR
      , p_task_split_flag       => FND_API.G_MISS_CHAR
      , x_return_status         => x_return_status
      , x_msg_count             => l_msg_count
      , x_msg_data              => l_msg_data
      );
    END IF;
    --
    -- check Error status
    --
    IF x_return_status = FND_API.G_RET_STS_ERROR
    THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    End If; -- bug 8947959
    --
  END LOOP;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR
  THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
  THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS
  THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END update_task_address;

-- Verify_LocationUpdate_For_FSTasks
-- Following procedure validates if the update to the service request location is allowed.
-- If there FS tasks associated with the SR and if the work on these FS tasks is in progress
-- OR if the FS tasks are scheduled then the update to the SR location is not allowed.

PROCEDURE Verify_LocUpdate_For_FSTasks
         (p_incident_id   IN NUMBER,
          x_return_status OUT NOCOPY VARCHAR2) IS

    l_task_id            NUMBER ;
    l_task_type_id       NUMBER ;
    l_task_status_id     NUMBER ;
    l_task_rule          VARCHAR2(30) ;
    l_assigned_flag      VARCHAR2(1) ;
    l_completed_flag     VARCHAR2(1) ;
    l_cancelled_flag     VARCHAR2(1) ;
    l_rejected_flag      VARCHAR2(1) ;
    l_schedulable_flag   VARCHAR2(1) ;
    l_closed_flag        VARCHAR2(1) ;
    l_start_date_type    VARCHAR2(30) ;
    l_end_date_type      VARCHAR2(30) ;

    l_planned_start_date   DATE ;
    l_planned_end_date     DATE ;
    l_scheduled_start_date DATE ;
    l_scheduled_end_date   DATE ;
    l_actual_start_date    DATE ;
    l_actual_end_date      DATE ;
    l_actual_effort        NUMBER ;
    l_actual_effort_uom    VARCHAR2(5);
    l_planned_effort       NUMBER ;
    l_planned_effort_uom   VARCHAR2(5);

    loc_update_not_alwd_exp EXCEPTION;

    -- cursor to get all the tasks for a service request.
    CURSOR c_tasks IS
           SELECT task_id,
                  task_type_id,
                  task_status_id,
                  planned_start_date,
                  planned_end_date,
                  scheduled_start_date,
                  scheduled_end_date,
                  actual_start_date,
                  actual_end_date,
                  planned_effort,
                  planned_effort_uom,
                  actual_effort,
                  actual_effort_uom
             FROM jtf_tasks_vl
            WHERE source_object_id = p_incident_id
              AND source_object_type_code = 'SR' ;

    -- Cursor to get the details of a task status
    CURSOR c_task_status (l_task_status_id IN NUMBER) IS
           SELECT assigned_flag,
                  completed_flag,
                  cancelled_flag,
                  rejected_flag,
                  schedulable_flag,
                  closed_flag,
                  start_date_type,
                  end_date_type
             FROM jtf_task_statuses_vl
            WHERE task_status_id = l_task_status_id ;

    -- Cursor to get the details of a task type
    CURSOR c_task_type (l_task_type_id IN NUMBER) IS
           SELECT rule
             FROM jtf_task_types_vl
            WHERE task_type_id = l_task_type_id ;

    -- Cursor to get the details of the task assignment.
    CURSOR c_assignee_id (l_task_id IN NUMBER) IS
           SELECT resource_id
             FROM jtf_task_assignments
            WHERE task_id = l_task_id ;
BEGIN
    -- Check if the profile option for the state restriction is set.
    -- then only apply the logic in this function

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF FND_PROFILE.VALUE('CS_SR_ENABLE_TASK_STATE_RESTRICTIONS') = 'Y' THEN
       -- Get all the tasks for the service request
       FOR c_tasks_rec IN c_tasks
           LOOP
              -- Check if it is a field service task
                 OPEN c_task_type (c_tasks_rec.task_type_id);
                FETCH c_task_type INTO l_task_rule;
                CLOSE c_task_type;

                IF l_task_rule = 'DISPATCH' THEN
                   -- get the task status details
                    OPEN c_task_status (c_tasks_rec.task_status_id);

                   FETCH c_task_status
                    INTO l_assigned_flag,
                         l_completed_flag,
                         l_cancelled_flag,
                         l_rejected_flag,
                         l_schedulable_flag,
                         l_closed_flag,
                         l_start_date_type,
                         l_end_date_type;

                   CLOSE c_task_status ;

                   IF( c_tasks_rec.scheduled_start_date IS NOT NULL    AND  -- SCHEDULED
                       c_tasks_rec.scheduled_end_date IS NOT NULL      AND
                       l_schedulable_flag = 'Y'              AND
                       l_start_date_type = 'SCHEDULED_START' AND
                       l_end_date_type = 'SCHEDULED_END'
                      ) OR -- ASSIGNED
                     ( c_tasks_rec.scheduled_start_date IS NOT NULL   AND
                       c_tasks_rec.scheduled_end_date IS NOT NULL     AND
                       l_assigned_flag = 'Y'                AND
                       l_start_date_type = 'SCHEDULED_START' AND
                       l_end_date_type = 'SCHEDULED_END'
                      ) OR -- EXECUTED
                     ( c_tasks_rec.actual_start_date IS NOT NULL       AND
                       c_tasks_rec.actual_end_date IS NOT NULL         AND
                       c_tasks_rec.actual_effort IS NOT NULL           AND
                       c_tasks_rec.actual_effort_uom IS NOT NULL       AND
                       l_completed_flag = 'Y'                AND
                       l_start_date_type = 'ACTUAL_START'    AND
                       l_end_date_type = 'ACTUAL_END'
                      ) OR -- EXECUTED
                     ( l_completed_flag = 'Y' OR
                       l_cancelled_flag = 'Y' OR
                       l_rejected_flag = 'Y'  OR
                       l_closed_flag = 'Y'
                     ) THEN
                     RAISE loc_update_not_alwd_exp ;
                   ELSE
                     x_return_status := FND_API.G_RET_STS_SUCCESS;
                   END IF ;
                END IF; -- end if for DISPATCH
           END LOOP;
    ELSE
     x_return_status := FND_API.G_RET_STS_SUCCESS;
    END IF;

EXCEPTION
     WHEN loc_update_not_alwd_exp THEN
          FND_MESSAGE.SET_Name('CS','CS_SR_LOC_UPD_NOT_ALLWD');
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
     WHEN FND_API.G_EXC_ERROR THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Verify_LocUpdate_For_FSTasks;


-- -------------------------------------------------------------------
-- Validate_External_Desc_Flex
-- Moved this procedure from cspsrb.pls as a part of bug fix for bug 5216510.
-- For ER# 2501166 added these external attributes date 1st oct 2002
-- -------------------------------------------------------------------
PROCEDURE Validate_External_Desc_Flex
( p_api_name                    IN      VARCHAR2,
  p_application_short_name      IN      VARCHAR2,
  p_ext_desc_flex_name          IN      VARCHAR2,
  p_ext_desc_segment1           IN      VARCHAR2,
  p_ext_desc_segment2           IN      VARCHAR2,
  p_ext_desc_segment3           IN      VARCHAR2,
  p_ext_desc_segment4           IN      VARCHAR2,
  p_ext_desc_segment5           IN      VARCHAR2,
  p_ext_desc_segment6           IN      VARCHAR2,
  p_ext_desc_segment7           IN      VARCHAR2,
  p_ext_desc_segment8           IN      VARCHAR2,
  p_ext_desc_segment9           IN      VARCHAR2,
  p_ext_desc_segment10          IN      VARCHAR2,
  p_ext_desc_segment11          IN      VARCHAR2,
  p_ext_desc_segment12          IN      VARCHAR2,
  p_ext_desc_segment13          IN      VARCHAR2,
  p_ext_desc_segment14          IN      VARCHAR2,
  p_ext_desc_segment15          IN      VARCHAR2,
  p_ext_desc_context            IN      VARCHAR2,
  p_resp_appl_id                IN      NUMBER          := NULL,
  p_resp_id                     IN      NUMBER          := NULL,
  p_return_status               OUT     NOCOPY VARCHAR2
)
IS
  l_error_message       VARCHAR2(2000);
BEGIN
  -- Initialize API return status to success
  p_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( p_ext_desc_context   || p_ext_desc_segment1  || p_ext_desc_segment2  ||
       p_ext_desc_segment3  || p_ext_desc_segment4  || p_ext_desc_segment5  ||
       p_ext_desc_segment6  || p_ext_desc_segment7  || p_ext_desc_segment8  ||
       p_ext_desc_segment9  || p_ext_desc_segment10 || p_ext_desc_segment11 ||
       p_ext_desc_segment12 || p_ext_desc_segment13 || p_ext_desc_segment14 ||
       p_ext_desc_segment15
     ) IS NOT NULL THEN

    FND_FLEX_DESCVAL.Set_Context_Value(p_ext_desc_context);
    FND_FLEX_DESCVAL.Set_Column_Value('EXTERNAL_ATTRIBUTE_1', p_ext_desc_segment1);
    FND_FLEX_DESCVAL.Set_Column_Value('EXTERNAL_ATTRIBUTE_2', p_ext_desc_segment2);
    FND_FLEX_DESCVAL.Set_Column_Value('EXTERNAL_ATTRIBUTE_3', p_ext_desc_segment3);
    FND_FLEX_DESCVAL.Set_Column_Value('EXTERNAL_ATTRIBUTE_4', p_ext_desc_segment4);
    FND_FLEX_DESCVAL.Set_Column_Value('EXTERNAL_ATTRIBUTE_5', p_ext_desc_segment5);
    FND_FLEX_DESCVAL.Set_Column_Value('EXTERNAL_ATTRIBUTE_6', p_ext_desc_segment6);
    FND_FLEX_DESCVAL.Set_Column_Value('EXTERNAL_ATTRIBUTE_7', p_ext_desc_segment7);
    FND_FLEX_DESCVAL.Set_Column_Value('EXTERNAL_ATTRIBUTE_8', p_ext_desc_segment8);
    FND_FLEX_DESCVAL.Set_Column_Value('EXTERNAL_ATTRIBUTE_9', p_ext_desc_segment9);
    FND_FLEX_DESCVAL.Set_Column_Value('EXTERNAL_ATTRIBUTE_10', p_ext_desc_segment10);
    FND_FLEX_DESCVAL.Set_Column_Value('EXTERNAL_ATTRIBUTE_11', p_ext_desc_segment11);
    FND_FLEX_DESCVAL.Set_Column_Value('EXTERNAL_ATTRIBUTE_12', p_ext_desc_segment12);
    FND_FLEX_DESCVAL.Set_Column_Value('EXTERNAL_ATTRIBUTE_13', p_ext_desc_segment13);
    FND_FLEX_DESCVAL.Set_Column_Value('EXTERNAL_ATTRIBUTE_14', p_ext_desc_segment14);
    FND_FLEX_DESCVAL.Set_Column_Value('EXTERNAL_ATTRIBUTE_15', p_ext_desc_segment15);

    IF NOT FND_FLEX_DESCVAL.Validate_Desccols
             ( appl_short_name => p_application_short_name,
               desc_flex_name  => p_ext_desc_flex_name,
               resp_appl_id    => p_resp_appl_id,
               resp_id         => p_resp_id
             ) THEN
      l_error_message := FND_FLEX_DESCVAL.Error_Message;
      CS_ServiceRequest_UTIL.Add_Desc_Flex_Msg(p_api_name, l_error_message);
      p_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
  END IF;

END Validate_External_Desc_Flex;

----------------------------------------------------
-- Validate Platform Version Id

PROCEDURE Validate_Platform_Version_Id
( p_api_name             IN   VARCHAR2,
  p_parameter_name       IN   VARCHAR2,
  p_platform_id          IN   NUMBER,
  p_organization_id      IN   NUMBER,
  p_platform_Version_id  IN   NUMBER,
  x_return_status        OUT  NOCOPY VARCHAR2
)IS

  l_api_name                  CONSTANT VARCHAR2(30)    := 'Validate_Platform_Version_Id';
  l_api_name_full             CONSTANT VARCHAR2(61)    := G_PKG_NAME||'.'||l_api_name;
  l_revision_qty_control_code          NUMBER;
  l_platform_Version_id                NUMBER;

  invld_platform_version_id_excp     EXCEPTION;

  CURSOR get_version_id IS
         SELECT revision_id
           INTO l_platform_Version_id
           FROM mtl_item_revisions
          WHERE organization_id   = p_organization_id
            AND inventory_item_id = p_platform_id
            AND revision_id       = p_platform_Version_id ;

BEGIN
  -- Initialize the return status.
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_platform_id IS NOT NULL THEN
     -- Check if the platform is serial number controlled

     SELECT revision_qty_control_code
       INTO l_revision_qty_control_code
       FROM mtl_system_items_b
      WHERE inventory_item_id = p_platform_id
        AND organization_id = p_organization_id ;

     IF NVL(l_revision_qty_control_code,-99) = 2 THEN

        OPEN get_version_id;
       FETCH get_version_id INTO l_platform_Version_id;
       CLOSE get_version_id;

       IF l_platform_Version_id IS NOT NULL THEN
          x_return_status :=  FND_API.G_RET_STS_SUCCESS;
       ELSE
          RAISE invld_platform_version_id_excp;
       END IF;
     END IF;
   END IF;

EXCEPTION
     WHEN invld_platform_version_id_excp THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          Add_Invalid_Argument_Msg
                (p_token_an    => l_api_name_full,
                 p_token_v     => TO_CHAR(p_platform_version_id),
                 p_token_p     => p_parameter_name ,
                 p_table_name  => G_TABLE_NAME,
                 p_column_name => 'PLATFORM_VERSION_ID' );

     WHEN OTHERS THEN
         fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
         fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
         fnd_msg_pub.ADD;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Validate_Platform_Version_Id;

FUNCTION BOOLEAN_TO_NUMBER (
   p_function_name       IN   VARCHAR2)
RETURN NUMBER
IS
BEGIN
   if ( FND_FUNCTION.TEST(p_function_name) ) then
      return 0;
   else
      return 1;
   end if;

 END  BOOLEAN_TO_NUMBER;


PROCEDURE VALIDATE_CREDIT_CARD
             (p_api_name                   IN VARCHAR2,
              p_parameter_name             IN VARCHAR2,
              p_instrument_payment_use_id  IN NUMBER,
              p_bill_to_acct_id            IN NUMBER,
  	         p_called_from                IN VARCHAR2,
              x_return_status        OUT  NOCOPY VARCHAR2)IS


CURSOR CREDITCARD_CUR(l_instr_payment_use_id NUMBER,
                      l_bill_to_acct_id NUMBER) IS
 Select ifpai.instr_assignment_id instrument_payment_use_id
   FROM IBY_FNDCPT_PAYER_ASSGN_INSTR_V ifpai,
        Iby_fndcpt_all_pmt_channels_v ifac
  Where ifpai.cust_account_id = l_bill_to_acct_id
   AND ifpai.instr_assignment_id = l_instr_payment_use_id
   And ifac.instrument_type = ifpai.instrument_type
   And ifac.payment_channel_code = 'CREDIT_CARD'
   And nvl(ifpai.card_single_use_flag, 'N') = 'N'
   And masked_card_expirydate is not null
   And ifpai.CARD_HOLDER_NAME is not null;

l_instrument_payment_use_id      NUMBER;
l_api_name_full  CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||p_api_name;

BEGIN

      OPEN CREDITCARD_CUR(p_instrument_payment_use_id,
                          p_bill_to_acct_id );
      FETCH CREDITCARD_CUR into l_instrument_payment_use_id;

      IF CREDITCARD_CUR%NOTFOUND then
        raise NO_DATA_FOUND;
      END IF;
      CLOSE CREDITCARD_CUR;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
         Add_Invalid_Argument_Msg
                (p_token_an    => l_api_name_full,
                 p_token_v     => TO_CHAR(p_instrument_payment_use_id),
                 p_token_p     => p_parameter_name ,
                 p_table_name  => G_TABLE_NAME,
                 p_column_name => 'INSTRUMENT_PAYEMENT_USE_ID' );
     x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    if p_called_from ='I' THEN
     FND_MESSAGE.Set_Name('CS', 'CS_Create_CREDIT_CARD_ERROR');
    else
     FND_MESSAGE.Set_Name('CS', 'CS_Create_UPDATE_CARD_ERROR');
    End if;
    fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
    fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
    fnd_msg_pub.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END VALIDATE_CREDIT_CARD;


END CS_ServiceRequest_UTIL;

/
