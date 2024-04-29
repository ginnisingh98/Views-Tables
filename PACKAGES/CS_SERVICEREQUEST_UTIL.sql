--------------------------------------------------------
--  DDL for Package CS_SERVICEREQUEST_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_SERVICEREQUEST_UTIL" AUTHID CURRENT_USER AS
/* $Header: csusrs.pls 120.15.12010000.3 2010/04/03 18:09:24 rgandhi ship $ */

-- --------------------------------------------------------------------------------
-- Start of comments
--  UTIL Name   : Convert_Request_Number_To_ID
--  Type        : Private
--  Description : Convert Incident_Number to Incident_ID.
--  Parameters  :
--  IN:	p_api_name	    IN   VARCHAR2  Required
--	  Name of the calling procedure
--	p_parameter_name    IN   VARCHAR2  Required
--	  Name of the value based parameter in the calling procedure
--	p_request_number    IN   VARCHAR2  Required Length = 64
--	  Value of the parameter to be converted
--      p_org_id 	    IN   NUMBER    Optional
--  OUT:p_request_id	    OUT  NUMBER    Required Length = 15
--	    x_return_status OUT  VARCHAR2  Required Length = 1
-- End of comments
-- --------------------------------------------------------------------------------
  PROCEDURE Convert_Request_Number_To_ID (
	p_api_name		IN  VARCHAR2,
	p_parameter_name	IN  VARCHAR2,
	p_request_number	IN  VARCHAR2,
	p_org_id		IN  NUMBER := NULL,
 	p_request_id	        OUT NOCOPY NUMBER ,
	x_return_status		OUT NOCOPY VARCHAR2
  ) ;

-- --------------------------------------------------------------------------------
-- Start of comments
--  UTIL Name   : Convert_Type_To_ID
--  Type        : Private
--  Description : Convert Name to Incident_Type_ID.
--  Parameters  :
--  IN:	p_api_name	 IN  VARCHAR2   Required
--	 Name of the calling procedure
--	p_parameter_name IN  VARCHAR2   Required
--	  Name of the value based parameter in the calling procedure
--	p_type_name	 IN  VARCHAR2 	Required Length = 30
--	  Value of the parameter to be converted
--	p_subtype	 IN  VARCHAR2	Required Length = 30
--	p_parent_type_id IN  NUMBER	Optional Length = 15
--  OUT:p_type_id	 OUT NUMBER 	Required Length = 15
--	x_return_status	 OUT VARCHAR2   Required Length = 1
-- End of comments
-- --------------------------------------------------------------------------------
  PROCEDURE Convert_Type_To_ID (
	p_api_name		IN  VARCHAR2,
	p_parameter_name	IN  VARCHAR2,
	p_type_name		IN  VARCHAR2,
	p_subtype		IN  VARCHAR2,
	p_parent_type_id	IN  NUMBER	:= FND_API.G_MISS_NUM,
 	p_type_id	        OUT NOCOPY NUMBER,
	x_return_status		OUT NOCOPY VARCHAR2
  ) ;

-- --------------------------------------------------------------------------------
-- Start of comments
--  UTIL Name   : Convert_Status_To_ID
--  Type        : Private
--  Description : Convert Name to Incident_Status_ID.
--  Parameters  :
--  IN:	p_api_name	 IN  VARCHAR2   Required
--	  Name of the calling procedure
--	p_parameter_name IN  VARCHAR2   Required
--	  Name of the value based parameter in the calling procedure
--	p_status_name	 IN  VARCHAR2 	Required Length = 30
--	  Value of the parameter to be converted
--	p_subtype	 IN  VARCHAR2	Required Length = 30
-- OUT:	p_status_id	 OUT NUMBER 	Required Length = 15
--	x_return_status	 OUT VARCHAR2   Required Length = 1
-- End of comments
-- --------------------------------------------------------------------------------
  PROCEDURE Convert_Status_To_ID (
	p_api_name	 IN  VARCHAR2,
	p_parameter_name IN  VARCHAR2,
	p_status_name	 IN  VARCHAR2,
	p_subtype	 IN  VARCHAR2,
 	p_status_id	 OUT NOCOPY NUMBER,
	x_return_status	 OUT NOCOPY VARCHAR2
  ) ;

-- --------------------------------------------------------------------------------
-- Start of comments
--  UTIL Name   : Convert_Severity_To_ID
--  Type        : Private
--  Description : Convert Name to Incident_Severity_ID.
--  Parameters  :
--  IN:	p_api_name	 IN  VARCHAR2  Required
--	  Name of the calling procedure
--	p_parameter_name IN  VARCHAR2  Required
--	  Name of the value based parameter in the calling procedure
--	p_severity_name	 IN  VARCHAR2  Required Length = 30
--	  Value of the parameter to be converted
--	p_subtype	 IN  VARCHAR2  Required Length = 30
--  OUT:p_severity_id	 OUT NUMBER    Required Length = 15
--	x_return_status	 OUT VARCHAR2  Required Length = 1
-- End of comments
-- --------------------------------------------------------------------------------
  PROCEDURE Convert_Severity_To_ID (
	p_api_name		IN  VARCHAR2,
	p_parameter_name	IN  VARCHAR2,
	p_severity_name		IN  VARCHAR2,
	p_subtype		IN  VARCHAR2,
	p_severity_id		OUT NOCOPY NUMBER,
	x_return_status		OUT NOCOPY VARCHAR2
  ) ;

-- -----------------------------------------------------------------------
-- Start of Comments
--  Procedure   : Convert_Urgency_To_ID
--  Function    : Converts a service request urgency into the corresponding
--                internal ID.
--  Parameters  :
--  IN  : p_api_name             IN   VARCHAR2        Required
--          Name of the calling procedure.
--        p_parameter_name       IN   VARCHAR2        Required
--          Name of the value-based parameter in the calling procedure
--          (e.g. 'p_urgency_name').
--        p_urgency_name         IN   VARCHAR2(30)    Required
--          Value of the urgency name to be converted.
--  OUT : p_urgency_id           OUT  NUMBER
--        x_return_status        OUT  VARCHAR2(1)
-- End of Comments
-- -----------------------------------------------------------------------

PROCEDURE Convert_Urgency_To_ID
( p_api_name             IN   VARCHAR2,
  p_parameter_name       IN   VARCHAR2,
  p_urgency_name         IN   VARCHAR2,
  p_urgency_id           OUT  NOCOPY NUMBER,
  x_return_status        OUT  NOCOPY VARCHAR2
);

-- -----------------------------------------------------------------------
-- Start of Comments
--  Procedure   : Convert_Customer_To_ID
--  Function    : Converts a customer name or a customer number into the
--                corresponding internal ID.
--  Parameters  :
--    IN  : p_api_name             IN   VARCHAR2        Required
--            Name of the calling procedure.
--          p_parameter_name_nb    IN   VARCHAR2        Required
--            Name of the first value-based parameter in the calling
--            procedure (e.g. 'p_customer_number').
--          p_parameter_name_n     IN   VARCHAR2        Required
--            Name of the second value-based parameter in the calling
--            procedure (e.g. 'p_customer_name').
--          p_customer_number      IN   VARCHAR2(30)    Optional
--            Default = FND_API.G_MISS_CHAR
--            Value of the customer number to be converted.
--          p_customer_name        IN   VARCHAR2(50)    Optional
--            Default = FND_API.G_MISS_CHAR
--            Value of the customer name to be converted.
--    OUT : p_customer_id          OUT  NUMBER
--          x_return_status        OUT  VARCHAR2(1)
--
--  Notes       : Either p_customer_name or p_customer_number must be passed.
--                If both are passed, p_customer_name will be ignored.
-- End of Comments
-- -----------------------------------------------------------------------
PROCEDURE Convert_Customer_To_ID
( p_api_name             IN   VARCHAR2,
  p_parameter_name_nb    IN   VARCHAR2,
  p_parameter_name_n     IN   VARCHAR2,
  p_customer_number      IN   VARCHAR2  := FND_API.G_MISS_CHAR,
  p_customer_name        IN   VARCHAR2  := FND_API.G_MISS_CHAR,
  p_customer_id          OUT  NOCOPY NUMBER,
  x_return_status        OUT  NOCOPY VARCHAR2
);

-- -----------------------------------------------------------------------
-- Start of Comments
--  Procedure   : Convert_Employee_To_ID
--  Function    : Converts an employee name or an employee number into the
--                corresponding internal ID.
--  Parameters  :
--    IN  : p_api_name             IN   VARCHAR2        Required
--            Name of the calling procedure.
--          p_parameter_name_nb    IN   VARCHAR2        Required
--            Name of the first value-based parameter in the calling
--            procedure (e.g. 'p_employee_number').
--          p_parameter_name_n     IN   VARCHAR2        Required
--            Name of the second value-based parameter in the calling
--            procedure (e.g. 'p_employee_name').
--          p_employee_number      IN   VARCHAR2(30)    Optional
--            Default = FND_API.G_MISS_CHAR
--            Value of the employee number to be converted.
--          p_employee_name        IN   VARCHAR2(50)    Optional
--            Default = FND_API.G_MISS_CHAR
--            Value of the employee name to be converted.
--    OUT : p_employee_id          OUT  NUMBER
--          x_return_status        OUT  VARCHAR2(1)
--
--  Notes       : Either p_employee_name or p_employee_number must be passed.
--                If both are passed, p_employee_name will be ignored.
-- End of Comments
-- -----------------------------------------------------------------------

PROCEDURE Convert_Employee_To_ID
( p_api_name             IN   VARCHAR2,
  p_parameter_name_nb    IN   VARCHAR2,
  p_employee_number      IN   VARCHAR2  := FND_API.G_MISS_CHAR,
  p_employee_id          OUT  NOCOPY NUMBER,
  x_return_status        OUT  NOCOPY VARCHAR2
);

-- -----------------------------------------------------------------------
-- Start of Comments
--  Procedure   : Convert_CP_Ref_Number_To_ID
--  Function    : Converts a customer product reference number to its
--                corresponding customer product ID.
--  Parameters  :
--    IN  : p_api_name             IN   VARCHAR2 Required
--            Name of the calling procedure.
--          p_parameter_name       IN   VARCHAR2 Required
--            Name of the value-based parameter in the calling procedure
--            (e.g. 'p_cp_ref_number').
--          p_cp_ref_number        IN   NUMBER     Required
--            Value of the reference number to be converted.
--          p_org_id               IN   NUMBER   Optional Default = NULL
--            Value of the organization ID.
--    OUT : p_customer_product_id  OUT  NUMBER
--          x_return_status        OUT  VARCHAR2(1)
-- End of Comments
-- -----------------------------------------------------------------------

PROCEDURE Convert_CP_Ref_Number_To_ID
( p_api_name             IN   VARCHAR2,
  p_parameter_name       IN   VARCHAR2,
  p_cp_ref_number        IN   NUMBER,  -- 3784008
  p_org_id               IN   NUMBER := NULL,
  p_customer_product_id  OUT  NOCOPY NUMBER,
  x_return_status        OUT  NOCOPY VARCHAR2
);


-- -----------------------------------------------------------------------
-- Start of Comments
--  Procedure   : Convert_RMA_Number_To_ID
--  Function    : Converts a RMA number into the corresponding sales order
--                header ID.
--  Parameters  :
--    IN  : p_api_name             IN   VARCHAR2        Required
--            Name of the calling procedure.
--          p_parameter_name       IN   VARCHAR2        Required
--            Name of the value-based parameter in the calling procedure
--            (e.g. 'p_rma_number').
--          p_rma_number           IN   NUMBER          Required
--            Value of the RMA number to be converted.
--          p_order_type_id        IN   NUMBER          Optional
--            ID of the order type of the RMA.
--          p_org_id               IN   NUMBER          Optional
--            Value of the organization ID.
--    OUT : p_rma_header_id        OUT  NUMBER
--          x_return_status        OUT  VARCHAR2(1)
--  Notes       : This procedure assumes that the number passed in is a valid
--                RMA number (order category is 'RMA').
-- End of Comments
-- -----------------------------------------------------------------------
PROCEDURE Convert_RMA_Number_To_ID
( p_api_name             IN   VARCHAR2,
  p_parameter_name       IN   VARCHAR2,
  p_rma_number           IN   NUMBER,
  p_order_type_id        IN   NUMBER := NULL,
  p_org_id               IN   NUMBER := NULL,
  p_rma_header_id        OUT  NOCOPY NUMBER,
  x_return_status        OUT  NOCOPY VARCHAR2
);

-- --------------------------------------------------------------------------------
-- Start of comments
--  UTIL Name   : Validate_Who_info
--  Type        : Private
--  Description : Verify that the user_id and login_id are valid and active.
--  Parameters  :
--  IN:	    p_api_name		IN  VARCHAR2   Required
--	      Name of the calling procedure
--	    p_parameter_name	IN  VARCHAR2   Required
--	      Name of the value based parameter in the calling procedure
--	    p_user_id		IN  NUMBER	Required Length = 15
--	    p_login_id		IN  NUMBER	Required Length = 15
--  OUT:    x_return_status	OUT VARCHAR2    Required Length = 1
--	    FND_API.G_RET_STS_SUCCESS	  => validation success
--	    FND_API.G_RET_STS_ERROR	  => validation failure
--	    FND_API.G_RET_STS_UNEXP_ERROR => unexpected error occurred
-- End of comments
-- --------------------------------------------------------------------------------
  PROCEDURE Validate_Who_Info (
	p_api_name		 IN  VARCHAR2,
	p_parameter_name_usr	 IN  VARCHAR2,
	p_parameter_name_login	 IN  VARCHAR2,
	p_user_id		 IN  NUMBER,
	p_login_id		 IN  NUMBER,
	x_return_status		 OUT NOCOPY VARCHAR2
  ) ;

-- -----------------------------------------------------------------------
-- Start of Comments
--  Procedure   : Validate_Type
--  Function    : Verify that the service request type is a valid and active
--                type.
--  Parameters  :
--    IN  : p_api_name          IN   VARCHAR2        Required
--            Name of the calling procedure.
--          p_parameter_name    IN   VARCHAR2        Required
--            Name of the parameter in the calling procedure
--            (e.g. 'p_type_id').
--          p_type_id  		IN   NUMBER          Required
--            Unique identifier of the service request type to be validated.
--          p_subtype    	IN   VARCHAR2(30)    Required
--            Service request subtype (e.g. 'INC').
--          p_status_id    	IN   NUMBER          Required
--            Identifier of the service request status.
--    OUT : x_return_status     OUT  VARCHAR2(1)
--            FND_API.G_RET_STS_SUCCESS         => type is valid
--            FND_API.G_RET_STS_ERROR           => type is invalid
--
--  Notes       : Unknown exceptions (i.e. unexpected errors) should be
--                handled by the calling procedure.
-- End of Comments
-- -----------------------------------------------------------------------
/* PROCEDURE Validate_Type
( p_api_name         IN   VARCHAR2,
  p_parameter_name   IN   VARCHAR2,
  p_type_id 	     IN   NUMBER,
  p_subtype   	     IN   VARCHAR2,
  p_status_id	     IN   NUMBER,
  p_resp_id          IN   NUMBER:= NULL,
  p_operation        IN   VARCHAR2:=NULL,
  x_return_status    OUT  NOCOPY VARCHAR2
);
*/
-- KP API Cleanup

PROCEDURE Validate_Type (
   p_parameter_name       IN   VARCHAR2,
   p_type_id   		      IN   NUMBER,
   p_subtype  		      IN   VARCHAR2,
   p_status_id            IN   NUMBER:= NULL,   -- not used in proc.
   p_resp_id              IN   NUMBER:= NULL,
   p_resp_appl_id         IN   NUMBER,   -- new for 11.5.10 default NULL
   p_business_usage       IN   VARCHAR2, -- new for 11.5.10 default NULL
   p_ss_srtype_restrict   IN   VARCHAR2, -- new for 11.5.10 default 'N'
   p_operation            IN   VARCHAR2, -- not used in proc.
   x_return_status        OUT  NOCOPY VARCHAR2,
   x_cmro_flag            OUT  NOCOPY VARCHAR2, -- new for 11.5.10
   x_maintenance_flag     OUT  NOCOPY VARCHAR2 ); -- new for 11.5.10

-- -----------------------------------------------------------------------
-- Start of Comments
--  Procedure   : Validate_Status
--  Function    : Verify that the service request status is a valid and active
--                for the type.
--  Parameters  :
--    IN  : p_api_name          IN   VARCHAR2        Required
--            Name of the calling procedure.
--          p_parameter_name    IN   VARCHAR2        Required
--            Name of the parameter in the calling procedure
--            (e.g. 'p_status_id').
--          p_status_id    	IN   NUMBER          Required
--            Unique identifier of the service request status to be validated.
--          p_subtype 	        IN   VARCHAR2(30)    Required
--            Service request subtype (e.g. 'INC').
--          p_type_id   	IN   NUMBER          Required
--            Identifier of the service request type related to the status.
--    OUT : p_close_flag        OUT  VARCHAR2(1)
--          x_return_status     OUT  VARCHAR2(1)
--            FND_API.G_RET_STS_SUCCESS         => status is valid
--            FND_API.G_RET_STS_ERROR           => status is invalid
--  Notes       : Unknown exceptions (i.e. unexpected errors) should be
--                handled by the calling procedure.
-- End of Comments
-- -----------------------------------------------------------------------
PROCEDURE Validate_Status
( p_api_name         IN   VARCHAR2,
  p_parameter_name   IN   VARCHAR2,
  p_status_id	     IN   NUMBER,
  p_subtype          IN   VARCHAR2,
  p_type_id          IN   NUMBER,
  p_resp_id          IN   NUMBER,
  p_close_flag       OUT  NOCOPY VARCHAR2,
  p_operation         IN         VARCHAR2 :='CREATE',
  x_return_status    OUT  NOCOPY VARCHAR2
);

PROCEDURE Validate_Updated_Status
( p_api_name                 IN   VARCHAR2,
  p_parameter_name           IN   VARCHAR2,
  p_resp_id                  IN   NUMBER,
  p_new_status_id            IN   NUMBER,
  p_old_status_id            IN   NUMBER,
  p_subtype      	         IN   VARCHAR2,
  p_type_id      	         IN   NUMBER,
  p_old_type_id              IN   NUMBER := NULL,
  p_close_flag              OUT  NOCOPY VARCHAR2,
  p_disallow_request_update OUT NOCOPY VARCHAR2,
  p_disallow_owner_update   OUT NOCOPY VARCHAR2,
  p_disallow_product_update OUT NOCOPY VARCHAR2,
  x_return_status           OUT NOCOPY VARCHAR2
)  ;

-- --------------------------------------------------------------------------------
-- Start of comments
--  UTIL Name   : Validate_Severity
--  Type        : Private
--  Description : Verify that the service request severity is a valid, active severity
--  Parameters  :
--  IN:	p_api_name		 IN  VARCHAR2   Required
--	  Name of the calling procedure
--	p_parameter_name	 IN  VARCHAR2   Required
--	  Name of the value based parameter in the calling procedure
--	p_severity_id		 IN  NUMBER	Required Length = 15
--	  ID of the severity
--      p_subtype		 IN  VARCHAR2	Required Length = 30
--  OUT:x_return_status		 OUT VARCHAR2   Required Length = 1
-- End of comments
-- --------------------------------------------------------------------------------
  PROCEDURE Validate_Severity (
	p_api_name		IN  VARCHAR2,
	p_parameter_name	IN  VARCHAR2,
	p_severity_id		IN  NUMBER,
	p_subtype		IN  VARCHAR2,
	x_return_status		OUT NOCOPY VARCHAR2
  ) ;

-- --------------------------------------------------------------------------------
-- Start of comments
--  UTIL Name   : Validate_Urgency
--  Type        : Private
--  Description : Verify that the service request urgency is a valid, active urgency
--  Parameters  :
--  IN:	p_api_name		IN  VARCHAR2   Required
--	  Name of the calling procedure
--	p_parameter_name	IN  VARCHAR2   Required
--	  Name of the value based parameter in the calling procedure
--	p_urgency_id		IN  NUMBER	   Required Length = 15
--  OUT:x_return_status		OUT  VARCHAR2  Required Length = 1
--	  FND_API.G_RET_STS_SUCCESS	=> validation success
--	  FND_API.G_RET_STS_ERROR	=> validation failure
--	  FND_API.G_RET_STS_UNEXP_ERROR => unexpected error occurred
-- End of comments
-- --------------------------------------------------------------------------------
  PROCEDURE Validate_Urgency (
	p_api_name		IN  VARCHAR2,
	p_parameter_name	IN  VARCHAR2,
	p_urgency_id		IN  NUMBER,
	x_return_status		OUT NOCOPY VARCHAR2
  ) ;

-- -----------------------------------------------------------------------
-- Start of Comments
--  Procedure   : Validate_Closed_Date
--  Function    : Verify that the closed date is later than service request date.
--  Parameters  :
--    IN  : p_api_name             IN   VARCHAR2        Required
--            Name of the calling procedure.
--          p_parameter_name       IN   VARCHAR2        Required
--            Name of the parameter in the calling procedure
--            (e.g. 'p_closed_date').
--          p_closed_date          IN   DATE            Required
--            Closed date.
--          p_request_date         IN   DATE            Required
--            Service request date.
--    OUT : x_return_status        OUT  VARCHAR2(1)
--            FND_API.G_RET_STS_SUCCESS         => date is valid
--            FND_API.G_RET_STS_ERROR           => date is invalid
--  Notes       : Unknown exceptions (i.e. unexpected errors) should be
--                handled by the calling procedure.
-- End of Comments
-- -----------------------------------------------------------------------
  PROCEDURE Validate_Closed_Date
  ( p_api_name             IN   VARCHAR2,
    p_parameter_name       IN   VARCHAR2,
    p_closed_date          IN   DATE,
    p_request_date         IN   DATE,
    x_return_status        OUT  NOCOPY VARCHAR2
  );

  ---- Added for Enh# 1830701
  PROCEDURE Validate_Inc_Reported_Date
  ( p_api_name             IN   VARCHAR2,
    p_parameter_name       IN   VARCHAR2,
    p_request_date         IN   DATE,
    p_inc_occurred_date    IN   DATE,
    x_return_status        OUT  NOCOPY VARCHAR2
  );

  PROCEDURE Validate_Inc_Occurred_Date
  ( p_api_name             IN   VARCHAR2,
    p_parameter_name       IN   VARCHAR2,
    p_inc_occurred_date    IN   DATE,
    p_request_date         IN   DATE,
    x_return_status        OUT  NOCOPY VARCHAR2
  );

  PROCEDURE Validate_Inc_Resolved_Date
  ( p_api_name             IN   VARCHAR2,
    p_parameter_name       IN   VARCHAR2,
    p_inc_resolved_date    IN   DATE,
    p_request_date         IN   DATE,
    x_return_status        OUT  NOCOPY VARCHAR2
  );

  PROCEDURE Validate_Inc_Responded_Date
  ( p_api_name               IN   VARCHAR2,
    p_parameter_name         IN   VARCHAR2,
    p_inc_responded_by_date  IN   DATE,
    p_request_date           IN   DATE,
    x_return_status          OUT  NOCOPY VARCHAR2
  );

  ---- Added for Enh# 222054
  PROCEDURE Validate_Inc_Location_Id
  ( p_api_name             	IN   VARCHAR2,
    p_parameter_name       	IN   VARCHAR2,
    -- New parameter added for validation based on location type --anmukher -- 08/18/03
    p_incident_location_type	IN   VARCHAR2,
    p_incident_location_id 	IN   NUMBER,
    x_incident_country          OUT  NOCOPY VARCHAR2,
    x_return_status        	OUT  NOCOPY VARCHAR2
  );

  PROCEDURE Validate_Incident_Country
  ( p_api_name             IN   VARCHAR2,
    p_parameter_name       IN   VARCHAR2,
    p_incident_country     IN   VARCHAR2,
    x_return_status        OUT  NOCOPY VARCHAR2
  );

-- -----------------------------------------------------------------------
-- Start of Comments
--  Procedure   : Validate_Employee
--  Function    : Verify that the employee is valid and active.
--  Parameters  :
--    IN  : p_api_name		IN	VARCHAR2	Required
--            Name of the calling procedure.
--          p_parameter_name	IN	VARCHAR2	Required
--            Name of the parameter in the calling procedure
--            (e.g. 'p_customer_contact').
--          p_employee_id	IN	NUMBER		Required
--            Employee ID.
--          p_org_id		IN	NUMBER		Optional
--            Organization ID.
--    OUT : p_employee_name	OUT	VARCHAR2(240)
--          x_return_status	OUT	VARCHAR2(1)
--            FND_API.G_RET_STS_SUCCESS         => contact is valid
--            FND_API.G_RET_STS_ERROR           => contact is invalid
--  Notes       : Unknown exceptions (i.e. unexpected errors) should be
--                handled by the calling procedure.
-- End of Comments
-- -----------------------------------------------------------------------
PROCEDURE Validate_Employee
( p_api_name		IN	VARCHAR2,
  p_parameter_name	IN	VARCHAR2,
  p_employee_id		IN	NUMBER,
  p_org_id		IN	NUMBER   := NULL,
  p_employee_name	OUT	NOCOPY VARCHAR2,
  x_return_status	OUT	NOCOPY VARCHAR2
);

-- --------------------------------------------------------------------------------
-- Start of comments
--  UTIL Name   : Validate_Customer
--  Type        : Private
--  Description : Verify that the service request customer is a valid customer
--                Check the passed Caller Type is same as that of the party. (Bug 3666089)
--  Parameters  :
--  IN:	p_api_name	 IN  VARCHAR2   Required
--	  Name of the calling procedure
--	p_parameter_name IN  VARCHAR2   Required
--	  Name of the value based parameter in the calling procedure
--	p_customer_id	 IN  NUMBER	Required Length = 15
--                  Addition for Bug 3666089
--      p_caller_type    IN VARCHAR2
--          Party_type information passed by the SR invocation program.
--                  Addition for Bug 3666089 Ends.
--  OUT:x_return_status	 OUT VARCHAR2   Required Length = 1
--	  FND_API.G_RET_STS_SUCCESS	=> validation success
--	  FND_API.G_RET_STS_ERROR	=> validation failure
--	  FND_API.G_RET_STS_UNEXP_ERROR => unexpected error occurred
-- End of comments
-- --------------------------------------------------------------------------------
  PROCEDURE Validate_Customer (
	p_api_name		 IN  VARCHAR2,
	p_parameter_name	 IN  VARCHAR2,
	p_customer_id		 IN  NUMBER,
	p_caller_type            IN VARCHAR2,       --Bug 3666089
	x_return_status		 OUT NOCOPY VARCHAR2
  ) ;

-- -----------------------------------------------------------------------
-- Start of Comments
--  Procedure   : Validate_Customer_Contact
--  Function    : Verify that the customer contact is valid and active.
--  Parameters  :
--    IN  : p_api_name             IN   VARCHAR2        Required
--            Name of the calling procedure.
--          p_parameter_name       IN   VARCHAR2        Required
--            Name of the parameter in the calling procedure
--            (e.g. 'p_customer_contact').
--          p_customer_contact_id  IN   NUMBER          Required
--            ID of the customer contact.
--          p_customer_id  	   IN   NUMBER          Required
--            ID of the service request customer.
--          p_org_id               IN   NUMBER          Optional
--            Value of the organization ID.
--    OUT : x_return_status        OUT  VARCHAR2(1)
--            FND_API.G_RET_STS_SUCCESS         => contact is valid
--            FND_API.G_RET_STS_ERROR           => contact is invalid
--  Notes       : Unknown exceptions (i.e. unexpected errors) should be
--                handled by the calling procedure.
--  Added one more in parameter as p_customer_type, to get the header
--  customer_type by shijain.
-- End of Comments
-- -----------------------------------------------------------------------
PROCEDURE Validate_Customer_Contact
( p_api_name             IN   VARCHAR2,
  p_parameter_name       IN   VARCHAR2,
  p_customer_contact_id  IN   NUMBER,
  p_customer_id  	 IN   NUMBER,
  p_org_id               IN   NUMBER     := NULL,
  p_customer_type        IN   VARCHAR2,
  x_return_status        OUT  NOCOPY VARCHAR2
);

PROCEDURE Validate_Org_Relationship
( p_api_name             IN   VARCHAR2,
  p_parameter_name       IN   VARCHAR2,
  p_customer_contact_id  IN   NUMBER,
  p_customer_id  	 IN   NUMBER,
  p_org_id               IN   NUMBER     := NULL,
  x_return_status        OUT  NOCOPY VARCHAR2)  ;

PROCEDURE Validate_Person_Relationship
( p_api_name             IN   VARCHAR2,
  p_parameter_name       IN   VARCHAR2,
  p_customer_contact_id  IN   NUMBER,
  p_customer_id  	 IN   NUMBER,
  p_org_id               IN   NUMBER     := NULL,
  x_return_status        OUT  NOCOPY VARCHAR2)  ;

-- -----------------------------------------------------------------------
-- Start of Comments
--  Procedure   : Validate_Customer_Product
--  Function    : Verify that the customer product is an active CP in the
--                installed base of the given operating unit.
--  Parameters  :
--    IN  : p_api_name			IN	VARCHAR2	Required
--            Name of the calling procedure.
--          p_parameter_name		IN	VARCHAR2	Required
--            Name of the parameter in the calling procedure
--            (e.g. 'p_customer_product_id').
--          p_customer_product_id	IN	NUMBER		Required
--            ID of the service request customer product.
--          p_org_id			IN	NUMBER		Optional
--            Value of the organization ID.
--    OUT : p_customer_id		OUT	NUMBER
--          p_inventory_item_id		OUT	NUMBER
--          x_return_status		OUT	VARCHAR2(1)
--            FND_API.G_RET_STS_SUCCESS         => CP is valid
--            FND_API.G_RET_STS_ERROR           => CP is invalid
--  Notes       : Unknown exceptions (i.e. unexpected errors) should be
--                handled by the calling procedure.
-- End of Comments
-- -----------------------------------------------------------------------
PROCEDURE Validate_Customer_Product
( p_api_name		IN  VARCHAR2,
  p_parameter_name	IN  VARCHAR2,
  p_customer_product_id	IN  NUMBER,
  p_org_id		IN  NUMBER	:= NULL,
  p_customer_id		IN  NUMBER,
  p_inventory_item_id	OUT NOCOPY NUMBER,
  p_inventory_org_id    IN  NUMBER,
  x_return_status       OUT NOCOPY VARCHAR2
);

-- --------------------------------------------------------------------------------
-- Start of comments
--  UTIL Name   : Validate_Product
--  Type        : Private
--  Description : Verify that the product exists in the given operating unit and
--		  the inventory org specified by the service system parameters
--  Parameters  :
--  IN:	p_api_name			 IN  VARCHAR2   Required
--	  Name of the calling procedure
--	p_parameter_name		 IN  VARCHAR2   Required
--	  Name of the value based parameter in the calling procedure
--	p_inventory_item_id		 IN  NUMBER	Required Length = 15
--	p_inventory_org_id		 IN  NUMBER	Required Length = 15
--      p_maint_organization_id          IN  NUMBER     Required Length = 15
--  OUT:x_return_status			OUT  VARCHAR2   Required Length = 1
--	  FND_API.G_RET_STS_SUCCESS	=> validation success
--	  FND_API.G_RET_STS_ERROR   	=> validation failure
--	  FND_API.G_RET_STS_UNEXP_ERROR => unexpected error occurred
-- Modification History
-- Date     Name     Description
-- -------- -------- -----------------------------------------------------------
-- 06/07/05 smisra   Added p_maint_organization_id parameter
-- -----------------------------------------------------------------------------
-- End of comments
-- --------------------------------------------------------------------------------
  PROCEDURE Validate_Product (
	p_api_name	 	 IN  VARCHAR2,
	p_parameter_name	 IN  VARCHAR2,
	p_inventory_item_id	 IN  NUMBER,
	p_inventory_org_id	 IN  NUMBER,
	x_return_status		 OUT NOCOPY VARCHAR2,
	--------------anmukher--------------08/04/03
	-- Added the flag for CMRO-EAM project of 11.5.10
	p_maintenance_flag	 IN  VARCHAR2,
        p_maint_organization_id  IN  NUMBER   ,
        p_inv_org_master_org_flag IN        VARCHAR2
  ) ;

-- --------------------------------------------------------------------------------
-- Start of comments
--  UTIL Name   : Validate_Cust_Pref_Lang
--  Type        : Private
--  Description : Verify that the cust_pref_lang_id is a valid id
--                from fnd_languages
--  Parameters  :
--  IN:	p_api_name		 IN  VARCHAR2   Required
--	  Name of the calling procedure
--	p_parameter_name	 IN  VARCHAR2   Required
--	  Name of the value based parameter in the calling procedure
--	p_cust_pref_lang_id	 IN  NUMBER      Required
--  OUT:x_return_status		 OUT VARCHAR2   Required Length = 1
--	  FND_API.G_RET_STS_SUCCESS	=> validation success
--	  FND_API.G_RET_STS_ERROR	=> validation failure
--	  FND_API.G_RET_STS_UNEXP_ERROR => unexpected error occurred
-- End of comments

  PROCEDURE Validate_Cust_Pref_Lang_Code (
	p_api_name		  IN  VARCHAR2,
	p_parameter_name	  IN  VARCHAR2,
	p_cust_pref_lang_code     IN  VARCHAR2,
	x_return_status		  OUT NOCOPY VARCHAR2
  ) ;

  PROCEDURE Validate_Comm_Pref_Code (
	p_api_name		 IN  VARCHAR2,
	p_parameter_name	 IN  VARCHAR2,
	p_comm_pref_code	 IN  VARCHAR2,
	x_return_status		 OUT NOCOPY VARCHAR2
  ) ;
/*
Modification History
Date     Name       Desc
-------- ---------  --------------------------------------------------------
02/28/05 smisra     Bug 4083288
                    added an addition parameter p_category_set_id
*/
  PROCEDURE Validate_Category_Id (
	p_api_name		 IN  VARCHAR2,
	p_parameter_name	 IN  VARCHAR2,
	p_category_id   	 IN  NUMBER,
        p_category_set_id        IN  NUMBER,
	x_return_status		 OUT NOCOPY VARCHAR2
  ) ;

  PROCEDURE Validate_Category_Set_Id (
       p_api_name           IN  VARCHAR2,
       p_parameter_name     IN  VARCHAR2,
       p_category_id        IN  NUMBER,
       p_category_set_id    IN  NUMBER,
       p_inventory_item_id  IN  NUMBER,
       p_inventory_org_id   IN  NUMBER,
       x_return_status      OUT NOCOPY VARCHAR2
  );

  PROCEDURE Validate_External_Reference (
       p_api_name              IN  VARCHAR2,
       p_parameter_name        IN  VARCHAR2,
       p_external_reference    IN  VARCHAR2,
       p_customer_product_id   IN  NUMBER,
       p_inventory_item_id     IN  NUMBER     := NULL,
       p_inventory_org_id      IN  NUMBER     := NULL,
       p_customer_id           IN  NUMBER     := NULL,
       x_return_status         OUT NOCOPY VARCHAR2
  );

  PROCEDURE Validate_System_Id (
       p_api_name           IN  VARCHAR2,
       p_parameter_name     IN  VARCHAR2,
       p_system_id          IN  NUMBER,
       x_return_status      OUT NOCOPY VARCHAR2
  );

-- ------------------------------
-- Start of Comments
--  Procedure   : Validate_Exp_Resolution_Date
--  Function    : Verify that the expected resolution date is later than the
--                service request date.
--  Parameters  :
--    IN  : p_api_name             IN   VARCHAR2        Required
--            Name of the calling procedure.
--          p_parameter_name       IN   VARCHAR2        Required
--            Name of the parameter in the calling procedure
--            (e.g. 'p_exp_resolution_date').
--          p_exp_resolution_date  IN   DATE            Required
--            Expected resolution date.
--          p_request_date         IN   DATE            Required
--            Service request date.
--    OUT : x_return_status        OUT  VARCHAR2(1)
--            FND_API.G_RET_STS_SUCCESS         => date is valid
--            FND_API.G_RET_STS_ERROR           => date is invalid
--  Notes       : Unknown exceptions (i.e. unexpected errors) should be
--                handled by the calling procedure.
-- End of Comments
-- -----------------------------------------------------------------------

  PROCEDURE Validate_Problem_Code (
	p_api_name		 IN  VARCHAR2,
	p_parameter_name	 IN  VARCHAR2,
	p_problem_code		 IN  VARCHAR2,
        p_incident_type_id       IN  NUMBER,
        p_inventory_item_id      IN  NUMBER,
	p_inventory_org_id       IN  NUMBER, -- added for API cleanup
	p_category_id            IN  NUMBER, -- added for API cleanup
	x_return_status		 OUT NOCOPY VARCHAR2
  ) ;

-- -----------------------------------------------------------------------
-- Start of Comments
--  Procedure   : Validate_Exp_Resolution_Date
--  Function    : Verify that the expected resolution date is later than the
--                service request date.
--  Parameters  :
--    IN  : p_api_name             IN   VARCHAR2        Required
--            Name of the calling procedure.
--          p_parameter_name       IN   VARCHAR2        Required
--            Name of the parameter in the calling procedure
--            (e.g. 'p_exp_resolution_date').
--          p_exp_resolution_date  IN   DATE            Required
--            Expected resolution date.
--          p_request_date         IN   DATE            Required
--            Service request date.
--    OUT : x_return_status        OUT  VARCHAR2(1)
--            FND_API.G_RET_STS_SUCCESS         => date is valid
--            FND_API.G_RET_STS_ERROR           => date is invalid
--  Notes       : Unknown exceptions (i.e. unexpected errors) should be
--                handled by the calling procedure.
-- End of Comments
-- -----------------------------------------------------------------------
PROCEDURE Validate_Exp_Resolution_Date
( p_api_name             IN   VARCHAR2,
  p_parameter_name       IN   VARCHAR2,
  p_exp_resolution_date  IN   DATE,
  p_request_date         IN   DATE,
  x_return_status        OUT  NOCOPY VARCHAR2
);

-- -----------------------------------------------------------------------
-- Start of Comments
--  Procedure   : Validate_Install_Site
--  Function    : Verify that the given customer site is a valid INSTALL_AT site
--                within the given operating unit.
--  Parameters  :
--    IN  : p_parameter_name       IN VARCHAR2        Required
--            Name of the parameter in the calling procedure
--            (e.g. 'p_install_site_use_id').
--          p_install_site_id      IN NUMBER          Required
--            Party site id .
--          p_customer_id          IN NUMBER          Required
--            ID of the service request customer.
--    OUT : p_install_customer_id  OUT NUMBER
--          x_return_status        OUT VARCHAR2(1)
--            FND_API.G_RET_STS_SUCCESS         => site is valid
--            FND_API.G_RET_STS_ERROR           => site is invalid
--  Notes       : Unknown exceptions (i.e. unexpected errors) should be
--                handled by the calling procedure.
-- End of Comments
-- -----------------------------------------------------------------------
PROCEDURE Validate_Install_Site
( p_parameter_name       IN   VARCHAR2,
  p_install_site_id      IN   NUMBER,
  p_customer_id          IN   NUMBER,
  x_return_status        OUT  NOCOPY VARCHAR2
);

-----------------------------------------------------------------------------
-- Start of Comments
--  Procedure   : Validate_Resolution_Code
--  Function    : Verify that the resolution code is an active resolution
--                code.
--  Parameters  :
--    IN  : p_api_name             IN   VARCHAR2        Required
--            Name of the calling procedure.
--          p_parameter_name       IN   VARCHAR2        Required
--            Name of the parameter in the calling procedure
--            (e.g. 'p_resolution_code').
--          p_resolution_code      IN   VARCHAR2(30)    Required
--            Resolution code.
--    OUT : x_return_status        OUT  VARCHAR2(1)
--            FND_API.G_RET_STS_SUCCESS         => code is valid
--            FND_API.G_RET_STS_ERROR           => code is invalid
--  Notes       : Unknown exceptions (i.e. unexpected errors) should be
--                handled by the calling procedure.
-- End of Comments
-- -----------------------------------------------------------------------
PROCEDURE Validate_Resolution_Code
( p_api_name             IN   VARCHAR2,
  p_parameter_name       IN   VARCHAR2,
  p_resolution_code      IN   VARCHAR2,
  x_return_status        OUT  NOCOPY VARCHAR2
);

-- --------------------------------------------------------------------------------
-- Start of comments
--  UTIL Name   : Validate_Act_Resolution_Date
--  Type        : Private
--  Description : Verify that the actual resolution date is later than the service
--		          request date
--  Parameters  :
--  IN:	p_api_name			 IN  VARCHAR2   Required
--		Name of the calling procedure
--	p_parameter_name		 IN  VARCHAR2   Required
--		Name of the value based parameter in the calling procedure
--	p_act_resolution_date	 IN  DATE	Required
--	p_request_date			 IN  DATE	Required
--  OUT:x_return_status		 OUT  VARCHAR2   Required Length = 1
--	  FND_API.G_RET_STS_SUCCESS	=> validation success
--	  FND_API.G_RET_STS_ERROR	=> validation failure
--	  FND_API.G_RET_STS_UNEXP_ERROR => unexpected error occurred
-- End of comments
-- --------------------------------------------------------------------------------
  PROCEDURE Validate_Act_Resolution_Date (
	p_api_name		 IN  VARCHAR2,
	p_parameter_name	 IN  VARCHAR2,
	p_act_resolution_date    IN  DATE,
	p_request_date		 IN  DATE,
	x_return_status		 OUT NOCOPY VARCHAR2
  ) ;
-- contracts : made contract_id IN OUT parameter
PROCEDURE Validate_Contract_Service_Id
( p_api_name             IN   VARCHAR2,
  p_parameter_name       IN   VARCHAR2,
  p_contract_service_id  IN   NUMBER,
  x_contract_id          IN OUT  NOCOPY NUMBER,
  x_contract_number      OUT  NOCOPY VARCHAR2,
  x_return_status        OUT  NOCOPY VARCHAR2
);

PROCEDURE Validate_Contract_Id
( p_api_name             IN   VARCHAR2,
  p_parameter_name       IN   VARCHAR2,
  p_contract_id          IN   NUMBER,
  x_contract_number      OUT  NOCOPY VARCHAR2,
  x_return_status        OUT  NOCOPY VARCHAR2
);

PROCEDURE Validate_Account_Id
(p_api_name        IN   VARCHAR2,
 p_parameter_name  IN   VARCHAR2,
 p_account_id      IN   NUMBER,
 p_customer_id     IN   NUMBER,
 x_return_status   OUT  NOCOPY VARCHAR2
);

-- Validate Platform Id
PROCEDURE Validate_Platform_Id
( p_api_name                IN   VARCHAR2,
  p_parameter_name          IN   VARCHAR2,
  p_platform_id             IN   NUMBER,
  p_organization_id         IN   NUMBER,
  x_serial_controlled_flag  OUT NOCOPY VARCHAR2,
  x_return_status           OUT  NOCOPY VARCHAR2
);

-- Validate Component Id
PROCEDURE Validate_CP_Comp_Id
( p_api_name             IN   VARCHAR2,
  p_parameter_name       IN   VARCHAR2,
  p_cp_component_id      IN   NUMBER,
  p_customer_product_id  IN   NUMBER,
  p_org_id               IN   NUMBER,
  x_return_status        OUT  NOCOPY VARCHAR2
);

-- Validate Product Revision
PROCEDURE Validate_Product_Revision
( p_api_name             IN   VARCHAR2,
  p_parameter_name       IN   VARCHAR2,
  p_product_revision     IN   VARCHAR2,
  p_customer_product_id  IN   NUMBER,
  p_inventory_org_id     IN   NUMBER,
  p_inventory_item_id    IN   NUMBER,
  x_return_status        OUT  NOCOPY VARCHAR2
);

-- Validate Component Version
-- For bug 3337848 - pass inv_org_id to check for revision control
PROCEDURE Validate_Component_Version
( p_api_name             IN   VARCHAR2,
  p_parameter_name       IN   VARCHAR2,
  p_component_version    IN   VARCHAR2,
  p_cp_component_id      IN   NUMBER,
  p_customer_product_id  IN   NUMBER,
  p_inventory_org_id     IN   NUMBER,
  x_return_status        OUT  NOCOPY VARCHAR2
);

-- Validate SubComponent Version
-- For bug 3337848 - pass inv_org_id to check for revision control
PROCEDURE Validate_Subcomponent_Version
( p_api_name             IN   VARCHAR2,
  p_parameter_name       IN   VARCHAR2,
  p_subcomponent_version IN   VARCHAR2,
  p_cp_component_id      IN   NUMBER,
  p_cp_subcomponent_id   IN   NUMBER,
  p_customer_product_id  IN   NUMBER,
  p_inventory_org_id     IN   NUMBER,
  x_return_status        OUT  NOCOPY VARCHAR2
);

-- Validate Sub Component Id
PROCEDURE Validate_CP_SubComp_Id
( p_api_name             IN   VARCHAR2,
  p_parameter_name       IN   VARCHAR2,
  p_cp_subcomponent_id   IN   NUMBER,
  p_cp_component_id      IN   NUMBER,
  p_customer_product_id  IN   NUMBER,
  p_org_id               IN   NUMBER,
  x_return_status        OUT  NOCOPY VARCHAR2
);

PROCEDURE Validate_Inv_Item_Rev
( p_api_name             IN   VARCHAR2,
  p_parameter_name       IN   VARCHAR2,
  p_inv_item_revision    IN   VARCHAR2,
  p_inventory_item_id    IN   NUMBER,
  p_inventory_org_id     IN   NUMBER,
  x_return_status        OUT  NOCOPY VARCHAR2
);

-------------------------------
PROCEDURE Validate_Inv_Comp_Id
( p_api_name             IN   VARCHAR2,
  p_parameter_name       IN   VARCHAR2,
  p_inventory_org_id     IN   NUMBER,
  p_inv_component_id     IN   NUMBER,
  p_inventory_item_id    IN   NUMBER,
  x_return_status        OUT  NOCOPY VARCHAR2
);

-------------------------------
PROCEDURE Validate_Inv_Comp_Ver
( p_api_name                   IN   VARCHAR2,
  p_parameter_name             IN   VARCHAR2,
  p_inventory_org_id           IN   NUMBER,
  p_inv_component_id           IN   NUMBER,
  p_inv_component_version      IN   VARCHAR2,
  x_return_status              OUT  NOCOPY VARCHAR2
);

PROCEDURE Validate_Inv_SubComp_Id
( p_api_name                   IN   VARCHAR2,
  p_parameter_name             IN   VARCHAR2,
  p_inventory_org_id           IN   NUMBER,
  p_inv_subcomponent_id        IN   NUMBER,
  p_inv_component_id           IN   NUMBER,
  x_return_status              OUT  NOCOPY VARCHAR2
);

PROCEDURE Validate_Inv_SubComp_Ver
( p_api_name                   IN   VARCHAR2,
  p_parameter_name             IN   VARCHAR2,
  p_inventory_org_id           IN   NUMBER,
  p_inv_subcomponent_id        IN   NUMBER,
  p_inv_subcomponent_version   IN   VARCHAR2,
  x_return_status              OUT  NOCOPY VARCHAR2
);

PROCEDURE Validate_Support_Site_Id
( p_api_name             IN VARCHAR2,
  p_parameter_name       IN VARCHAR2,
  p_support_site_id      IN NUMBER,
  p_owner_id             IN NUMBER,
  p_resource_type        IN VARCHAR2,
  p_org_id               IN NUMBER,
  x_return_status        OUT NOCOPY VARCHAR2
);

PROCEDURE Validate_Group_Type
( p_api_name             IN   VARCHAR2,
  p_parameter_name       IN   VARCHAR2,
  p_group_type           IN   VARCHAR2,
  --p_resource_type      IN   VARCHAR2,
  x_return_status        OUT  NOCOPY VARCHAR2
);

PROCEDURE Validate_Group_Id
( p_api_name             IN   VARCHAR2,
  p_parameter_name       IN   VARCHAR2,
  p_group_type           IN   VARCHAR2,
  p_owner_group_id       IN   NUMBER,
  x_group_name           OUT  NOCOPY VARCHAR2,
  x_return_status        OUT  NOCOPY VARCHAR2
);

PROCEDURE Validate_Owner
( p_api_name             IN  VARCHAR2,
  p_parameter_name       IN  VARCHAR2,
  p_owner_id             IN  NUMBER,
  p_group_type           IN  VARCHAR2,
  p_owner_group_id       IN  NUMBER,
  p_org_id               IN  NUMBER,
  p_incident_type_id     IN  NUMBER, -- new for 11.5.10 for Security rule
  p_mode                 IN  VARCHAR2 DEFAULT NULL,
  x_owner_name           OUT NOCOPY VARCHAR2,
  x_owner_id             OUT NOCOPY NUMBER,
  x_resource_type        OUT NOCOPY VARCHAR2,
  x_support_site_id      OUT NOCOPY NUMBER,
  x_return_status        OUT NOCOPY VARCHAR2
);

PROCEDURE Validate_Resource_Type
( p_api_name             IN   VARCHAR2,
  p_parameter_name       IN   VARCHAR2,
  p_resource_type        IN   VARCHAR2,
  x_return_status        OUT  NOCOPY VARCHAR2
);

PROCEDURE Validate_SR_Channel
( p_api_name                   IN  VARCHAR2,
  p_parameter_name             IN  VARCHAR2,
  p_sr_creation_channel        IN  VARCHAR2,
  x_return_status              OUT NOCOPY VARCHAR2
);

-- Validate Language Id
PROCEDURE Validate_CP_Language_Id
( p_api_name                   IN  VARCHAR2,
  p_parameter_name             IN  VARCHAR2,
  p_language_id                IN  NUMBER,
  p_customer_product_id        IN  NUMBER,
  x_return_status              OUT NOCOPY VARCHAR2
);

------------------------------------------------------------
-- Validate Territory Id
PROCEDURE Validate_Territory_Id
( p_api_name                   IN   VARCHAR2,
  p_parameter_name             IN   VARCHAR2,
  p_territory_id               IN   NUMBER,
  p_owner_id                   IN   NUMBER,
  x_return_status              OUT  NOCOPY VARCHAR2
);

PROCEDURE Validate_Per_Contact_Point_Id
( p_api_name                   IN   VARCHAR2,
  p_parameter_name             IN   VARCHAR2,
  p_contact_point_type         IN   VARCHAR2,
  p_contact_point_id           IN   NUMBER,
  p_party_id                   IN   NUMBER,
  x_return_status              OUT  NOCOPY VARCHAR2
);

PROCEDURE Validate_Emp_Contact_Point_Id
( p_api_name                   IN   VARCHAR2,
  p_parameter_name             IN   VARCHAR2,
  p_employee_id                IN   NUMBER,
  p_contact_point_id           IN   NUMBER,
  x_return_status              OUT  NOCOPY VARCHAR2
);

PROCEDURE Validate_Contact_Point_Type
( p_api_name                   IN   VARCHAR2,
  p_parameter_name             IN   VARCHAR2,
  p_contact_point_type         IN   VARCHAR2,
  x_return_status              OUT  NOCOPY VARCHAR2
);

PROCEDURE Validate_Contact_Type
( p_api_name                   IN   VARCHAR2,
  p_parameter_name             IN   VARCHAR2,
  p_contact_type               IN   VARCHAR2,
  x_return_status              OUT  NOCOPY VARCHAR2
);

--------*******************************************************
-- Start of comments
--  UTIL Name   : Is_MultiOrg_Enabled
--  Type        : Private
--  Description : Checks if the multiorg is enabled
--  Parameters  : None
--  Return Value:
--      p_multiorg_enabled	BOOLEAN
--		returns TRUE if multiorg is enabled
-- End of comments
-- --------------------------------------------------------------------------------
   FUNCTION Is_MultiOrg_Enabled  RETURN BOOLEAN;

-------------------------------------------------------------------------------
-- Start of comments
--  UTIL Name   : Is_Context_Enabled
--  Type        : Private
--  Description : Check if the ConText Option is enabled
--  Parameters  : None
--  Return Value:
--    Returns TRUE if the ConText Option is enabled.
-- End of comments
-------------------------------------------------------------------------------
  FUNCTION Is_Context_Enabled RETURN BOOLEAN;

--------------------------------------------------------------------------
-- Start of comments
--  Procedure	: Add_Desc_Flex_Msg
--  Description	: Add the CS_API_SR_DESC_FLEX_ERROR message to the message
--		  list.
--  Parameters	:
--  IN		:
--	p_token_an		IN	VARCHAR2		Required
--		Value of the API_NAME token.
--	p_token_dfm		IN	VARCHAR2		Required
--		Value of the DESC_FLEX_MSG token.
-- End of comments
--------------------------------------------------------------------------
PROCEDURE Add_Desc_Flex_Msg
( p_token_an		IN	VARCHAR2,
  p_token_dfm		IN	VARCHAR2
);

--------------------------------------------------------------------------
-- Start of comments
--  Procedure	: Add_Invalid_Argument_Msg
--  Description	: Add the CS_API_ALL_INVALID_ARGUMENT message to the message
--		  list.
--  Parameters	:
--  IN		:
--	p_token_an		IN	VARCHAR2		Required
--		Value of the API_NAME token.
--	p_token_v		IN	VARCHAR2		Required
--		Value of the VALUE token.
--	p_token_p		IN	VARCHAR2		Required
--		Value of the PARAMETER token.
-- End of comments
--------------------------------------------------------------------------
PROCEDURE Add_Invalid_Argument_Msg
( p_token_an	VARCHAR2,
  p_token_v	    VARCHAR2,
  p_token_p	    VARCHAR2
);

--------------------------------------------------------------------------
-- Start of comments
--  Procedure	: Add_Key_Flex_Msg
--  Description	: Add the CS_API_SR_KEY_FLEX_ERROR message to the message
--		  list.
--  Parameters	:
--  IN		:
--	p_token_an		IN	VARCHAR2		Required
--		Value of the API_NAME token.
--	p_token_kfm		IN	VARCHAR2		Required
--		Value of the KEY_FLEX_MSG token.
-- End of comments
--------------------------------------------------------------------------
PROCEDURE Add_Key_Flex_Msg
( p_token_an		IN	VARCHAR2,
  p_token_kfm		IN	VARCHAR2
);

--------------------------------------------------------------------------
-- Start of comments
--  Procedure	: Add_Missing_Param_Msg
--  Description	: Add the CS_API_ALL_MISSING_PARAM message to the message list.
--  Parameters	:
--  IN		:
--	p_token_an		IN	VARCHAR2		Required
--		Value of the API_NAME token.
--	p_token_mp		IN	VARCHAR2		Required
--		Value of the MISSING_PARAM token.
-- End of comments
--------------------------------------------------------------------------
PROCEDURE Add_Missing_Param_Msg
( p_token_an		IN	VARCHAR2,
  p_token_mp		IN	VARCHAR2
);

--------------------------------------------------------------------------
-- Start of comments
--  Procedure	: Add_Null_Parameter_Msg
--  Description	: Add the CS_API_ALL_NULL_PARAMETER message to the message list.
--  Parameters	:
--  IN		:
--	p_token_an		IN	VARCHAR2		Required
--		Value of the API_NAME token.
--	p_token_np		IN	VARCHAR2		Required
--		Value of the NULL_PARAM token.
-- End of comments
--------------------------------------------------------------------------
PROCEDURE Add_Null_Parameter_Msg
( p_token_an		IN	VARCHAR2,
  p_token_np		IN	VARCHAR2
);

--------------------------------------------------------------------------
-- Start of comments
--  Procedure	: Add_Param_Ignored_Msg
--  Description	: Add the CS_API_ALL_PARAM_IGNORED message to the message list.
--  Parameters	:
--  IN		:
--	p_token_an		IN	VARCHAR2		Required
--		Value of the API_NAME token.
--	p_token_ip		IN	VARCHAR2		Required
--		Value of the IGNORED_PARAM token.
-- End of comments
--------------------------------------------------------------------------
PROCEDURE Add_Param_Ignored_Msg
( p_token_an		IN	VARCHAR2,
  p_token_ip		IN	VARCHAR2 );

PROCEDURE Add_Cp_Flag_Ignored_Msg
( p_token_an            IN      VARCHAR2,
  p_token_ip            IN      VARCHAR2,
  p_token_pv	        IN      VARCHAR2);

PROCEDURE Add_Duplicate_Value_Msg
( p_token_an   IN   VARCHAR2,
  p_token_p    IN   VARCHAR2 );

PROCEDURE Add_Same_Val_Update_Msg
( p_token_an	IN   VARCHAR2,
  p_token_p	    IN   VARCHAR2 );

PROCEDURE call_internal_hook( p_package_name    IN VARCHAR2 ,
	                          p_api_name        IN VARCHAR2 ,
	                          p_processing_type IN VARCHAR2,
		                      x_return_status   OUT NOCOPY VARCHAR2 );

PROCEDURE  Validate_Current_Serial(
    p_api_name              IN  VARCHAR2,
    p_parameter_name        IN  VARCHAR2,
    p_inventory_item_id     IN  NUMBER     := NULL,
    p_inventory_org_id      IN  NUMBER,
    p_customer_product_id   IN  NUMBER    := NULL,
    p_customer_id           IN  NUMBER    := NULL,
    p_current_serial_number IN  VARCHAR2,
    x_return_status         OUT NOCOPY VARCHAR2  ) ;

-- -----------------------------------------------------------------------
-- Start of Comments
--  Procedure   : Validate_source_program_code
--  Function    : Verify that the source program code is valid lookup code
--                from the lookup CS_SR_SOURCE_PROGRAMS.
--  Parameters  :
--    IN  : p_api_name             IN   VARCHAR2        Required
--              Name of the calling procedure.
--          p_parameter_name       IN   VARCHAR2        Required
--              Name of the parameter in the calling procedure
--              (e.g. 'p_source_program_code').
--          p_source_program_code  IN   VARCHAR2(30)    Required
--              Service request source program code
--    OUT : x_return_status        OUT  VARCHAR2(1)
--          	FND_API.G_RET_STS_SUCCESS => source_program_code is valid
--          	FND_API.G_RET_STS_ERROR   => source_program_code is invalid
--  Notes : Unknown exceptions (i.e. unexpected errors) should be
--          handled by the calling procedure.
-- End of Comments
-- -----------------------------------------------------------------------
PROCEDURE Validate_source_program_Code
    ( p_api_name                      IN   VARCHAR2,
      p_parameter_name                IN   VARCHAR2,
      p_source_program_code           IN   VARCHAR2,
      x_return_status                 OUT  NOCOPY VARCHAR2
    ) ;

-- -----------------------------------------------------------------------
/*
** Validate_Bill_To_Ship_To_Ct - validate_bill_to_ship_to_contact
** 1. Same PROCEDURE will be used TO VALIDATE Bill_To AND Ship_To Contacts
** 2. Contat can be
**    a. IF Bill_to_customer IS person , contact can be same person (Self)
**    b. IF bill_to_customer IS person OR Org, Contact can be a Relationship
**       BETWEEN the Bill_To Customer AND a Person
*/

PROCEDURE Validate_Bill_To_Ship_To_Ct
( p_api_name             IN   VARCHAR2,
  p_parameter_name       IN   VARCHAR2,
  p_bill_to_contact_id   IN   NUMBER,
  p_bill_to_party_id     IN   NUMBER,
  p_customer_type	     IN   VARCHAR2,
  x_return_status        OUT  NOCOPY VARCHAR2
);

-- --------------------------------------------------------------------------------
-- Validate_Bill_To_Ship_To_Party
-- Same procedure is used to validate Bill_to and Ship_To Parties
-- 1. Party must be Active of type Person or Organization
-- 2. Must have a valid relationship with the SR Customer.
-- 3. Added one more in out parameter as x_customer_type, to get the bill_to
--    customer_type and to give the header customer type.
-- --------------------------------------------------------------------------------

  PROCEDURE Validate_Bill_To_Ship_To_Party (
	p_api_name			     IN  VARCHAR2,
	p_parameter_name		 IN  VARCHAR2,
	p_bill_to_party_id		 IN  NUMBER,
	p_customer_id			 IN  NUMBER,
    x_customer_type          IN  OUT NOCOPY VARCHAR2,
	x_return_status			 OUT NOCOPY VARCHAR2
  ) ;

-- --------------------------------------------------------------------------------
-- Validate_Bill_To_Ship_To_Site (New Procedure for 11.5.9)
-- Same procedure is used to validate Bill_to and Ship_To Sites
-- 1. Site must be an active site attached to party
-- 2. Site USe must be Valid and Must be BILL_TO or SHIP_TO as required
-- 3. p_site_use_type will be BILL_TO or SHIP_TO
-- --------------------------------------------------------------------------------

  PROCEDURE Validate_Bill_To_Ship_To_Site (
	p_api_name			     IN  VARCHAR2,
	p_parameter_name		 IN  VARCHAR2,
	p_bill_to_site_id		 IN  NUMBER,
	p_bill_to_party_id		 IN  NUMBER,
	p_site_use_type			 IN  VARCHAR2,
        x_site_use_id                    OUT NOCOPY NUMBER,
	x_return_status			 OUT NOCOPY VARCHAR2
  ) ;

-- -----------------------------------------------------------------------
--  Procedure   : Validate_Bill_To_Ship_To_Acct
--  Function    : Verify that the Bill To Account is valid for given customer site OR customer.
--  Parameters  :
--  IN  :p_api_name             IN   VARCHAR2      Required Name of the calling procedure.
--       p_parameter_name       IN   VARCHAR2      Required Name of parameter in the calling procedure (e.g. 'p_bill_to_account').
--       p_bill_to_account_id   IN   NUMBER        Required Unique bill to account identifier
--       p_bill_to_customer_id  IN   NUMBER        Unique Bill to customer ientifier
--  OUT :x_return_status        OUT  VARCHAR2(1)
--       FND_API.G_RET_STS_SUCCESS         => Bill_to_Account is valid
--       FND_API.G_RET_STS_ERROR           => Bill_to_Account is invalid
-- -----------------------------------------------------------------------

PROCEDURE Validate_Bill_To_Ship_To_Acct
( p_api_name         IN   VARCHAR2,
  p_parameter_name   IN   VARCHAR2,
  p_account_id   	 IN   NUMBER,
  p_party_id   		 IN   NUMBER,
  x_return_status    OUT  NOCOPY VARCHAR2
) ;

-- -----------------------------------------------------------------------
-- Start of Comments
--  Procedure   : Validate_INC_DIST_QUAL_UOM
--  Function    : Verify that the INC_DIST_QUAL_UOM is valid lookup
--                code from the lookup CS_SR_DISTANCE_UOM
--  Parameters  :
--    IN  : p_api_name             IN   VARCHAR2        Required
--             Name of the calling procedure.
--          p_parameter_name       IN   VARCHAR2        Required
--             Name of the parameter in the calling procedure
--             (e.g. 'P_INC_DIST_QUAL_UOM').
--          P_INC_DIST_QUAL_UOM    IN   VARCHAR2(30)
--             Service request incident distance qualifier UOM
--    OUT : x_return_status        OUT  VARCHAR2(1)
--          FND_API.G_RET_STS_SUCCESS   => INC_DIST_QUAL_UOM is valid
--          FND_API.G_RET_STS_ERROR     => INC_DIST_QUAL_UOM is invalid
--  Notes : Unknown exceptions (i.e. unexpected errors) should be
--          handled by the calling procedure.
-- End of Comments
-- -----------------------------------------------------------------------
PROCEDURE Validate_INC_DIST_QUAL_UOM
    ( p_api_name                      IN   VARCHAR2,
      p_parameter_name                IN   VARCHAR2,
      p_INC_DIST_QUAL_UOM             IN   VARCHAR2,
      x_return_status                 OUT  NOCOPY VARCHAR2
    ) ;

-- -----------------------------------------------------------------------
-- Start of Comments
--  Procedure   : Validate_INC_DIRECTION_QUAL
--  Function    : Verify that the INC_DIRECTION_QUAL is valid lookup
--                code from the lookup CS_SR_DIRECTIONS.
--  Parameters  :
--    IN  : p_api_name             IN   VARCHAR2        Required
--            Name of the calling procedure.
--          p_parameter_name       IN   VARCHAR2        Required
--            Name of the parameter in the calling procedure
--            (e.g. 'p_INC_DIRECTION_QUAL').
--          p_INC_DIRECTION_QUAL  IN   VARCHAR2(30)
--             Service request incident direction qualifier
--    OUT : x_return_status        OUT  VARCHAR2(1)
--          FND_API.G_RET_STS_SUCCESS => INC_DIRECTION_QUAL is valid
--          FND_API.G_RET_STS_ERROR   => INC_DIRECTION_QUAL is invalid
--  Notes : Unknown exceptions (i.e. unexpected errors) should be
--          handled by the calling procedure.
-- End of Comments
-- -----------------------------------------------------------------------

PROCEDURE Validate_INC_DIRECTION_QUAL
    ( p_api_name                      IN   VARCHAR2,
      p_parameter_name                IN   VARCHAR2,
      p_INC_DIRECTION_QUAL            IN   VARCHAR2,
      x_return_status                 OUT  NOCOPY VARCHAR2
    ) ;

--------------------------------------------------------------------------
-- Start of comments
--  Procedure   : Add_Desc_Flex_Msg
--  Description : Overloaded Procedure to Add the CS_API_SR_DESC_FLEX_ERROR message to the message
--                list.
--  Parameters  :
--  IN          :
--      p_token_an              IN      VARCHAR2                Required
--              Value of the API_NAME token.
--      p_token_kfm             IN      VARCHAR2                Required
--              Value of the KEY_FLEX_MSG token.
--      p_column_name           IN      VARCHAR2                Default Null
--              Name of the database column/control parameter being validated
--      p_table_name            IN      VARCHAR2                Default Null
--              Name of the database table/control parameter being validated
-- End of comments
--------------------------------------------------------------------------
PROCEDURE Add_Desc_Flex_Msg
( p_token_an       VARCHAR2,
  p_token_dfm      VARCHAR2,
  p_table_name  IN VARCHAR2,
  p_column_name IN VARCHAR2
) ;

--------------------------------------------------------------------------
-- Start of comments
--  Procedure	: Add_Invalid_Argument_Msg
--  Description	: Overloaded procedure to Add the CS_API_ALL_INVALID_ARGUMENT
--                message to the message list.
--  Parameters	:
--  IN		:
--	    p_token_an		IN	VARCHAR2	Required
--		  Value of the API_NAME token.
--	    p_token_v		IN	VARCHAR2	Required
--		  Value of the VALUE token.
--	    p_token_p		IN	VARCHAR2	Required
--		  Value of the PARAMETER token.
--      p_column_name   IN  VARCHAR2    Default Null
--        Name of the database column/control parameter being validated
--      p_table_name    IN  VARCHAR2    Default Null
--        Name of the database table/control parameter being validated
-- End of comments
--------------------------------------------------------------------------
PROCEDURE Add_Invalid_Argument_Msg ( p_token_an	   IN VARCHAR2,
                                     p_token_v	   IN VARCHAR2,
                                     p_token_p	   IN VARCHAR2,
                                     p_table_name  IN VARCHAR2,
                                     p_column_name IN VARCHAR2 );

--------------------------------------------------------------------------
-- Start of comments
--  Procedure	: Add_Key_Flex_Msg
--  Description	: Overloaded Procedure to Add the CS_API_SR_KEY_FLEX_ERROR message to the message
--		  list.
--  Parameters	:
--  IN		:
--	    p_token_an		IN	 VARCHAR2	  Required
--		  Value of the API_NAME token.
--	    p_token_kfm		IN	 VARCHAR2	  Required
--		  Value of the KEY_FLEX_MSG token.
--      p_column_name   IN   VARCHAR2     Default Null
--        Name of the database column/control parameter being validated
--      p_table_name    IN   VARCHAR2     Default Null
--         Name of the database table/control parameter being validated
-- End of comments
--------------------------------------------------------------------------
PROCEDURE Add_Key_Flex_Msg ( p_token_an    IN VARCHAR2,
                             p_token_kfm   IN VARCHAR2,
                             p_table_name  IN VARCHAR2,
                             p_column_name IN VARCHAR2 );

--------------------------------------------------------------------------
-- Start of comments
--  Procedure	: Add_Missing_Param_Msg
--  Description	: Overloaded Procedure to Add the CS_API_ALL_MISSING_PARAM message to the message
--		  list.
--  Parameters	:
--  IN		:
--	p_token_an		IN	VARCHAR2		Required
--		Value of the API_NAME token.
--	p_token_mp		IN	VARCHAR2		Required
--		Value of the MISSING_PARAM token.
--      p_column_name           IN      VARCHAR2                Default Null
--              Name of the database column/control parameter being validated
--      p_table_name            IN      VARCHAR2                Default Null
--              Name of the database table/control parameter being validated
-- End of comments
--------------------------------------------------------------------------

PROCEDURE Add_Missing_Param_Msg ( p_token_an    IN  VARCHAR2,
                                  p_token_mp    IN  VARCHAR2,
                                  p_table_name  IN  VARCHAR2,
                                  p_column_name IN  VARCHAR2);

--------------------------------------------------------------------------
-- Start of comments
--  Procedure	: Add_Null_Parameter_Msg
--  Description	: Overloaded Procedure to Add the CS_API_ALL_NULL_PARAMETER message to the message
--		  list.
--  Parameters	:
--  IN		:
--	p_token_an		IN	VARCHAR2		Required
--		Value of the API_NAME token.
--	p_token_np		IN	VARCHAR2		Required
--		Value of the NULL_PARAM token.
--      p_column_name           IN      VARCHAR2                Default Null
--              Name of the database column/control parameter being validated
--      p_table_name            IN      VARCHAR2                Default Null
--              Name of the database table/control parameter being validated
-- End of comments
--------------------------------------------------------------------------

PROCEDURE Add_Null_Parameter_Msg ( p_token_an    IN  VARCHAR2,
                                   p_token_np	 IN  VARCHAR2,
                                   p_table_name  IN  VARCHAR2,
                                   p_column_name IN  VARCHAR2 );

--------------------------------------------------------------------------
-- Start of comments
--  Procedure	: Add_Param_Ignored_Msg
--  Description	: Overloaded Procedure to Add the CS_API_ALL_PARAM_IGNORED message to the message
--		  list.
--  Parameters	:
--  IN		:
--	p_token_an		IN	VARCHAR2		Required
--		Value of the API_NAME token.
--	p_token_ip		IN	VARCHAR2		Required
--		Value of the IGNORED_PARAM token.
--      p_column_name           IN      VARCHAR2                Default Null
--              Name of the database column/control parameter being validated
--      p_table_name            IN      VARCHAR2                Default Null
--              Name of the database table/control parameter being validated
-- End of comments
--------------------------------------------------------------------------

PROCEDURE Add_Param_Ignored_Msg ( p_token_an	 IN  VARCHAR2,
                                  p_token_ip     IN  VARCHAR2,
                                  p_table_name   IN  VARCHAR2,
                                  p_column_name  IN  VARCHAR2);



--------------------------------------------------------------------------
-- Start of comments
--  Procedure	: Add_Duplicate_Value_Msg
--  Description	: Overloaded Procedure to Add the CS_API_ALL_PARAM_IGNORED message to the message
--		  list.
--  Parameters	:
--  IN		:
--	p_token_an		IN	VARCHAR2		Required
--		Value of the API_NAME token.
--	p_token_ip		IN	VARCHAR2		Required
--		Value of the IGNORED_PARAM token.
--      p_column_name           IN      VARCHAR2                Default Null
--              Name of the database column/control parameter being validated
--      p_table_name            IN      VARCHAR2                Default Null
--              Name of the database table/control parameter being validated
-- End of comments
--------------------------------------------------------------------------

PROCEDURE Add_Duplicate_Value_Msg( p_token_an	 IN  VARCHAR2,
				   p_token_p     IN  VARCHAR2,
                                   p_table_name  IN  VARCHAR2,
                                   p_column_name IN  VARCHAR2 );

--------------------------------------------------------------------------
-- Start of comments
--  Procedure	: Add_Same_Val_Update_Msg
--  Description	: Overloaded Procedure to Add the CS_API_ALL_PARAM_IGNORED message to the message
--		  list.
--  Parameters	:
--  IN		:
--	p_token_an		IN	VARCHAR2		Required
--		Value of the API_NAME token.
--	p_token_ip		IN	VARCHAR2		Required
--		Value of the IGNORED_PARAM token.
--      p_column_name           IN      VARCHAR2                Default Null
--              Name of the database column/control parameter being validated
--      p_table_name            IN      VARCHAR2                Default Null
--              Name of the database table/control parameter being validated
-- End of comments
--------------------------------------------------------------------------
PROCEDURE Add_Same_Val_Update_Msg( p_token_an	 IN  VARCHAR2,
				   p_token_p	 IN  VARCHAR2,
                                   p_table_name  IN  VARCHAR2,
                                   p_column_name IN  VARCHAR2 );

-- -----------------------------------------------------------------------------
---
-- Validate_Site_Site_Use
-- Same procedure is used to validate Bill_to and Ship_To Site and Sites Use.
-- 1. Site must be an active site attached to party
-- 2. Site USe must be Valid and Must be BILL_TO or SHIP_TO as required
-- 3. p_site_use_type will be BILL_TO or SHIP_TO
-- -----------------------------------------------------------------------------
---

  PROCEDURE Validate_Site_Site_Use (
        p_api_name                       IN  VARCHAR2,
        p_parameter_name                 IN  VARCHAR2,
        p_site_id                        IN  NUMBER,
        p_site_use_id                    IN  NUMBER,
        p_party_id                       IN  NUMBER,
        p_site_use_type                  IN  VARCHAR2,
        x_return_status                  OUT NOCOPY VARCHAR2
  );

-- -----------------------------------------------------------------------------
---
-- Validate_Bill_Ship_Site_Use
-- 1. Site use must be an active site attached to party
-- 2. Site USe must be Valid and Must be BILL_TO or SHIP_TO as required
-- 3. p_site_use_type will be BILL_TO or SHIP_TO
-- -----------------------------------------------------------------------------
---
 PROCEDURE Validate_Bill_Ship_Site_Use (
        p_api_name                       IN  VARCHAR2,
        p_parameter_name                 IN  VARCHAR2,
        p_site_use_id                    IN  NUMBER,
        p_party_id                       IN  NUMBER,
        p_site_use_type                  IN  VARCHAR2,
        x_site_id                        OUT  NOCOPY NUMBER,
        x_return_status                  OUT  NOCOPY VARCHAR2
  );

  -------------anmukher-------------08/04/03
  -- Added new procedure for CMRO-EAM project of 11.5.10
  -- Checks that the inventory org id is a valid inventory org
-- -----------------------------------------------------------------------------
-- Modification History
-- Date     Name     Description
-- -------- -------- -----------------------------------------------------------
-- 06/07/05 smisra   Removed parameter p_maintenance_flag
-- -----------------------------------------------------------------------------
  PROCEDURE Validate_Inventory_Org
  (
  	p_api_name			    IN  VARCHAR2,
  	p_parameter_name		IN  VARCHAR2,
  	p_inv_org_id			IN  NUMBER,
        x_inv_org_master_org_flag OUT NOCOPY VARCHAR2,
  	x_return_status			OUT NOCOPY VARCHAR2
  );

  ------------anmukher--------------08/04/03
  -- Added new procedure for CMRO-EAM project of 11.5.10
  -- Checks that the owning dept id is a valid department
  PROCEDURE Validate_Owning_Department
  (
  	p_api_name			    IN  VARCHAR2,
  	p_parameter_name		IN  VARCHAR2,
  	p_inv_org_id			IN  NUMBER,
  	p_owning_dept_id		IN  NUMBER,
  	p_maintenance_flag		IN  VARCHAR2,
  	x_return_status			OUT NOCOPY VARCHAR2
  );

 -- security
 -- Added new procedure to set the grants depending on the
 -- value of the agent security.
 -- C for Custom
 -- S for Standard
 -- N for None
 PROCEDURE Setup_SR_Agent_Security
 (
 	p_sr_agent_security IN VARCHAR2,
   	x_return_status     OUT NOCOPY VARCHAR2
 );

-- Added new function if the responsibility has access to
-- the passed SR type
FUNCTION Validate_Incident_Access (
	p_api_name	IN VARCHAR2,
	p_resp_business_usage IN VARCHAR2,
	p_incident_id	IN NUMBER)
RETURN BOOLEAN;


-- Introduced in 11.5.10
-- Procedure to disallow SR Type change for the following cases:
-- From EAM to Non Eam
-- From Non Eam to EAM

PROCEDURE VALIDATE_TYPE_CHANGE (
   p_old_eam_type_flag        IN          VARCHAR2,
   p_new_eam_type_flag        IN          VARCHAR2,
   x_return_status            OUT NOCOPY  VARCHAR2 );

--- KP API Cleanup
-- Procedure to be called when SR Type changes. If there are any open
-- Tasks, add a WARNING message to the Message stack, but return back
-- a success status. It is upto the calling program to pull of the
-- error msg. from the stack to be displayed or processed as needed.

 PROCEDURE TASK_OWNER_CROSS_VAL (
   p_incident_id          IN   NUMBER,
   x_return_status        OUT  NOCOPY  VARCHAR2 );


-- Procedure to be called when Incident Location Id changes. If
-- Customer Product Id is passed , the incident Location Id should
-- be the same as Install Base location.

 PROCEDURE CP_INCIDENT_SITE_CROSS_VAL(
        p_parameter_name                 IN  VARCHAR2,
        p_incident_location_id           IN   NUMBER,
        p_customer_product_id            IN   NUMBER,
        x_return_status                  OUT NOCOPY varchar2  );

-- KP API Cleanup; added new proc
-- Procedure to be called when install site Id or CP changes. If
-- Customer Product Id is passed , the install site Id should
-- be the same as Install Base location.

 PROCEDURE CP_INSTALL_SITE_CROSS_VAL (
        p_parameter_name                 IN  VARCHAR2,
        p_install_site_id           IN   NUMBER,
        p_customer_product_id            IN   NUMBER,
        x_return_status                       OUT NOCOPY varchar2  );

-- New Procedure created
 PROCEDURE Resolution_Code_Cross_Val (
        p_parameter_name                 IN  VARCHAR2,
        p_resolution_code                IN  VARCHAR2,
        p_problem_code                   IN  VARCHAR2,
        p_incident_type_id               IN  NUMBER,
        p_category_id                    IN  NUMBER,
        p_inventory_item_id              IN  NUMBER,
	p_inventory_org_id               IN  NUMBER,
        x_return_status                  OUT NOCOPY VARCHAR2  );


-- Procedure to be called when SR Status changes. Check if the SR
-- is changed to closed status. If yes then,
-- If there are any open Tasks, with the  restrict_flag set to 'Y''
-- raise error.

 PROCEDURE Task_Restrict_Close_Cross_Val(
   p_incident_id          IN   NUMBER,
   p_status_id            IN   NUMBER,
   x_return_status        OUT  NOCOPY  VARCHAR2 );


-- Procedure to be called when contract, inv item, install site
-- customer product or account changes.

 Procedure contracts_cross_val (
        p_parameter_name                 IN  VARCHAR2,
        p_contract_service_id            IN  NUMBER,
        p_busiproc_id                    IN  NUMBER,
        p_request_date                   IN  DATE,
	    p_inventory_item_id		         IN  NUMBER,
	    p_inv_org_id         		     IN  NUMBER,
	    p_install_site_id		         IN  NUMBER,
	    p_customer_product_id		     IN  NUMBER,
	    p_account_id			         IN  NUMBER,
	    p_customer_id			         IN  NUMBER,
	    p_system_id                  IN   NUMBER,
        x_return_status                  OUT NOCOPY varchar2  )	;


-- Procedure to be called when cp_component_id changes. Check if it has
-- has a valid relation with the inv_component_id

 PROCEDURE Inv_Component_Cross_Val(
   p_parameter_name                 IN   VARCHAR2,
   p_inv_component_id               IN   NUMBER,
   p_cp_component_id                IN   NUMBER,
   x_return_status                  OUT  NOCOPY VARCHAR2 );


-- Procedure to be called when cp_subcomponent_id changes. Check if it has
-- has a valid relation with the inv_subcomponent_id

 PROCEDURE Inv_Subcomponent_Cross_Val(
   p_parameter_name                 IN  VARCHAR2,
   p_inv_subcomponent_id            IN  NUMBER,
   p_cp_subcomponent_id             IN  NUMBER,
   x_return_status                  OUT NOCOPY VARCHAR2 );

-- Record Type for the out parameters of  SERVICEREQUEST_CROSS_VAL procedure.
TYPE sr_cross_val_out_rec_type IS RECORD
(
  inventory_item_id                   NUMBER,
  bill_to_site_use_id                 NUMBER,
  ship_to_site_use_id                 NUMBER,
  bill_to_site_id                     NUMBER,
  ship_to_site_id                     NUMBER,
  contract_id                         NUMBER,
  contract_number                     VARCHAR2(120),
  product_revision                    VARCHAR2(240),
  component_version                   VARCHAR2(3),
  subcomponent_version                VARCHAR2(3),
  contract_service_id_valid           VARCHAR2(1)
  );

-- Procedure SR Cross val enforces all the data relationship between the SR attributes
-- to be satisfied.
-- This procedure invokes all the other cross validation procedures; this was introduced
-- as part of the SR API Cleanup project for 11.5.10
PROCEDURE SERVICEREQUEST_CROSS_VAL (
   p_new_sr_rec          IN   cs_servicerequest_pvt.service_request_rec_type,
   p_old_sr_rec          IN   cs_servicerequest_pvt.sr_oldvalues_rec_type,
   x_cross_val_out_rec   OUT  NOCOPY sr_cross_val_out_rec_type,
   x_return_status       OUT  NOCOPY VARCHAR2 );


-- -----------------------------------------------------------------------------
---
-- Prepare_Audit_Record
-- Takes request_id as input and creates a audit_record type rec with the
-- old and new values set to the vlaues in the DB for the given request_id.
-- -----------------------------------------------------------------------------
---
 PROCEDURE Prepare_Audit_Record (
        p_api_version            IN  VARCHAR2,
        p_request_id             IN  NUMBER,
        x_return_status         OUT  NOCOPY VARCHAR2,
        x_msg_count             OUT  NOCOPY NUMBER,
        x_msg_data              OUT  NOCOPY VARCHAR2,
        x_audit_vals_rec        OUT  NOCOPY  CS_ServiceRequest_PVT.SR_AUDIT_REC_TYPE
  );
-- --------------------------------------------------------------------------------
-- This procedure validates internal descriptive flexfield
-- --------------------------------------------------------------------------------
PROCEDURE Validate_Desc_Flex
( p_api_name                    IN      VARCHAR2,
  p_application_short_name      IN      VARCHAR2,
  p_desc_flex_name              IN      VARCHAR2,
  p_desc_segment1               IN      VARCHAR2,
  p_desc_segment2               IN      VARCHAR2,
  p_desc_segment3               IN      VARCHAR2,
  p_desc_segment4               IN      VARCHAR2,
  p_desc_segment5               IN      VARCHAR2,
  p_desc_segment6               IN      VARCHAR2,
  p_desc_segment7               IN      VARCHAR2,
  p_desc_segment8               IN      VARCHAR2,
  p_desc_segment9               IN      VARCHAR2,
  p_desc_segment10              IN      VARCHAR2,
  p_desc_segment11              IN      VARCHAR2,
  p_desc_segment12              IN      VARCHAR2,
  p_desc_segment13              IN      VARCHAR2,
  p_desc_segment14              IN      VARCHAR2,
  p_desc_segment15              IN      VARCHAR2,
  p_desc_context                IN      VARCHAR2,
  p_resp_appl_id                IN      NUMBER          := NULL,
  p_resp_id                     IN      NUMBER          := NULL,
  p_return_status               OUT     NOCOPY VARCHAR2
);
-- --------------------------------------------------------------------------------
-- This procedure validates component and subcomponent version.
-- this could be use to validate product_revision too.
-- --------------------------------------------------------------------------------
PROCEDURE Validate_product_Version
( p_parameter_name       IN     VARCHAR2,
  p_instance_id          IN     NUMBER,
  p_inventory_org_id     IN     NUMBER,
  p_product_version      IN OUT NOCOPY VARCHAR2,
  x_return_status        OUT    NOCOPY VARCHAR2);

/*
Function Name:s get_unassigned_indicator
Parameters   :
IN           : p_incident_owner_id NUMBER
             : p_owner_group_id    NUMBER

Description  : This function determines unassigned indicator value based on
               incident owner and group owner ids.
Modification History
Date     Name       Desc
-------- ---------  --------------------------------------------------------
03/25/05 smisra     Bug 4028675.
                    Created
*/
FUNCTION get_unassigned_indicator
( p_incident_owner_id IN NUMBER
, p_owner_group_id    IN NUMBER
) RETURN NUMBER;
--
PROCEDURE validate_party_role_code
( p_party_role_code IN         VARCHAR2
, x_return_status   OUT NOCOPY VARCHAR2
);
PROCEDURE validate_org_id
( p_org_id NUMBER
, x_return_status OUT NOCOPY VARCHAR2
);
PROCEDURE validate_maint_organization_id
( p_maint_organization_id IN         NUMBER
, p_inventory_org_id      IN         NUMBER
, p_inv_org_master_org_flag IN        VARCHAR2
, x_return_status         OUT NOCOPY VARCHAR2
);
PROCEDURE validate_customer_product_id
( p_customer_product_id   IN         NUMBER
, p_customer_id           IN         NUMBER
, p_inventory_org_id      IN         NUMBER
, p_maint_organization_id IN         NUMBER
, p_inv_org_master_org_flag IN        VARCHAR2
, p_inventory_item_id  IN OUT NOCOPY NUMBER
, x_return_status         OUT NOCOPY VARCHAR2
);
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
);
PROCEDURE get_reacted_resolved_dates
( p_incident_status_id         IN            NUMBER
, p_old_incident_status_id     IN            NUMBER
, p_old_inc_responded_by_date  IN            DATE
, p_old_incident_resolved_date IN            DATE
, x_inc_responded_by_date      IN OUT NOCOPY DATE
, x_incident_resolved_date     IN OUT NOCOPY DATE
, x_return_status                 OUT NOCOPY VARCHAR2
);
PROCEDURE get_party_details
( p_party_id      IN            NUMBER
, x_party_type       OUT NOCOPY VARCHAR2
, x_status           OUT NOCOPY VARCHAR2
, x_return_status    OUT NOCOPY VARCHAR2
);
--
PROCEDURE update_task_address
( p_incident_id   IN         NUMBER
, p_location_type IN         VARCHAR2
, p_location_id   IN         NUMBER
, p_old_location_id   IN     NUMBER    -- Bug 8947959
, x_return_status OUT NOCOPY VARCHAR2
);

-- Verify_LocationUpdate_For_FSTasks
-- Following procedure validates if the update to the service request location is allowed.
-- If there FS tasks associated with the SR and if the work on these FS tasks is in progress
-- OR if the FS tasks are scheduled then the update to the SR location is not allowed.

PROCEDURE Verify_LocUpdate_For_FSTasks
         (p_incident_id   IN NUMBER,
          x_return_status OUT NOCOPY VARCHAR2);

--------------------------------------------------------------------------
-- Procedure Validate_External_Desc_Flex
-- Description:
--   Validate External descriptive flexfield segment IDs and context.
-- Notes:
--   This procedure currently does not accept a concatenated string of
--   segment IDs as input, since the descriptive flexfield API does not
--   allow access to the segment column names in the same order that the
--   segment IDs are returned. In other words, there is no way to breakup
--   the concatenated segments into 15 attribute column values.
--------------------------------------------------------------------------

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
);

-- Procedure to validate the platform version id
-- Reinstated to resolve bug # 5350764

PROCEDURE Validate_Platform_Version_Id
( p_api_name             IN   VARCHAR2,
  p_parameter_name       IN   VARCHAR2,
  p_platform_id          IN   NUMBER,
  p_organization_id      IN   NUMBER,
  p_platform_Version_id  IN   NUMBER,
  x_return_status        OUT  NOCOPY VARCHAR2) ;

FUNCTION BOOLEAN_TO_NUMBER
( p_function_name       IN   VARCHAR2
) RETURN NUMBER;

/* Credit Card 9358401 */

PROCEDURE VALIDATE_CREDIT_CARD
             (p_api_name                   IN VARCHAR2,
              p_parameter_name             IN VARCHAR2,
              p_instrument_payment_use_id  IN NUMBER,
              p_bill_to_acct_id            IN NUMBER,
		    p_called_from                IN VARCHAR2,
              x_return_status        OUT  NOCOPY VARCHAR2);

END CS_ServiceRequest_UTIL;

/
