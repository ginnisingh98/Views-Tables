--------------------------------------------------------
--  DDL for Package CS_CORE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_CORE_UTIL" AUTHID CURRENT_USER AS
/* $Header: csucores.pls 120.2 2005/12/14 15:34:41 smisra noship $ */

-- ---------------------------------------------------------
-- Declare Data Types
-- ---------------------------------------------------------
TYPE DFF_Rec_Type IS RECORD
(
	context                         VARCHAR2(30)    := FND_API.G_MISS_CHAR,
	attribute1                      VARCHAR2(150)   := FND_API.G_MISS_CHAR,
	attribute2                      VARCHAR2(150)   := FND_API.G_MISS_CHAR,
	attribute3                      VARCHAR2(150)   := FND_API.G_MISS_CHAR,
	attribute4                      VARCHAR2(150)   := FND_API.G_MISS_CHAR,
	attribute5                      VARCHAR2(150)   := FND_API.G_MISS_CHAR,
	attribute6                      VARCHAR2(150)   := FND_API.G_MISS_CHAR,
	attribute7                      VARCHAR2(150)   := FND_API.G_MISS_CHAR,
	attribute8                      VARCHAR2(150)   := FND_API.G_MISS_CHAR,
	attribute9                      VARCHAR2(150)   := FND_API.G_MISS_CHAR,
	attribute10                     VARCHAR2(150)   := FND_API.G_MISS_CHAR,
	attribute11                     VARCHAR2(150)   := FND_API.G_MISS_CHAR,
	attribute12                     VARCHAR2(150)   := FND_API.G_MISS_CHAR,
	attribute13                     VARCHAR2(150)   := FND_API.G_MISS_CHAR,
	attribute14                     VARCHAR2(150)   := FND_API.G_MISS_CHAR,
	attribute15                     VARCHAR2(150)   := FND_API.G_MISS_CHAR
);


TYPE PRICE_ATT_Rec_Type IS RECORD
(
	PRICING_CONTEXT      VARCHAR2(30)       DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE1   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE2   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE3   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE4   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE5   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE6   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE7   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE8   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE9   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE10   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE11   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE12   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE13   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE14   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE15   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE16   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE17   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE18   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE19   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE20   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE21   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE22   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE23   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE24   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE25   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE26   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE27   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE28   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE29   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE30   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE31   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE32   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE33   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE34   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE35   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE36   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE37   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE38   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE39   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE40   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE41   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE42   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE43   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE44   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE45   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE46   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE47   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE48   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE49   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE50   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE51   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE52   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE53   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE54   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE55   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE56   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE57   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE58   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE59   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE60   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE61   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE62   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE63   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE64   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE65   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE66   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE67   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE68   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE69   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE70   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE71   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE72   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE73   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE74   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE75   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE76   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE77   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE78   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE79   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE80   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE81   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE82   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE83   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE84   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE85   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE86   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE87   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE88   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE89   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE90   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE91   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE92   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE93   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE94   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE95   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE96   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE97   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE98   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE99   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR,
     PRICING_ATTRIBUTE100   VARCHAR2(150) DEFAULT FND_API.G_MISS_CHAR
	);

------------------------------------------------------------------------------
--  Procedure   : Add_Duplicate_Value_Msg
--  Description : Add the CS_API_ALL_DUPLICATE_VALUE message to the message
--                list.
--  Parameters  :
--  IN          : p_token_an            IN      VARCHAR2        Required
--                      Value of the API_NAME token.
--                p_token_p             IN      VARCHAR2        Required
--                      Value of the DUPLICATE_VAL_PARAM token.
------------------------------------------------------------------------------

PROCEDURE Add_Duplicate_Value_Msg
  ( p_token_an  IN      VARCHAR2,
    p_token_p   IN      VARCHAR2 );

------------------------------------------------------------------------------
--  Procedure   : Add_Invalid_Argument_Msg
--  Description : Add the CS_API_ALL_INVALID_ARGUMENT message to the message
--                list.
--  Parameters  :
--  IN          : p_token_an            IN      VARCHAR2        Required
--                      Value of the API_NAME token.
--                p_token_v             IN      VARCHAR2        Required
--                      Value of the VALUE token.
--                p_token_p             IN      VARCHAR2        Required
--                      Value of the PARAMETER token.
------------------------------------------------------------------------------

PROCEDURE Add_Invalid_Argument_Msg
  ( p_token_an  IN      VARCHAR2,
    p_token_v   IN      VARCHAR2,
    p_token_p   IN      VARCHAR2 );

------------------------------------------------------------------------------
--  Procedure   : Add_Missing_Param_Msg
--  Description : Add the CS_API_ALL_MISSING_PARAM message to the message
--                list.
--  Parameters  :
--      p_token_an              IN      VARCHAR2        Required
--              Value of the API_NAME token.
--      p_token_mp              IN      VARCHAR2        Required
--              Value of the MISSING_PARAM token.
------------------------------------------------------------------------------

PROCEDURE Add_Missing_Param_Msg
  ( p_token_an  IN      VARCHAR2,
    p_token_mp  IN      VARCHAR2 );

------------------------------------------------------------------------------
--  Procedure   : Add_Null_Parameter_Msg
--  Description : Add the CS_API_ALL_NULL_PARAMETER message to the message
--                list.
--  Parameters  :
--  IN          : p_token_an            IN      VARCHAR2        Required
--                      Value of the API_NAME token.
--                p_token_np            IN      VARCHAR2        Required
--                      Value of the NULL_PARAM token.
------------------------------------------------------------------------------

PROCEDURE Add_Null_Parameter_Msg
  ( p_token_an  IN      VARCHAR2,
    p_token_np  IN      VARCHAR2 );

------------------------------------------------------------------------------
--  Procedure   : Add_Param_Ignored_Msg
--  Description : Add the CS_API_ALL_PARAM_IGNORED message to the message
--                list.
--  Parameters  :
--  IN          : p_token_an            IN      VARCHAR2        Required
--                      Value of the API_NAME token.
--                p_token_ip            IN      VARCHAR2        Required
--                      Value of the IGNORED_PARAM token.
------------------------------------------------------------------------------

PROCEDURE Add_Param_Ignored_Msg
  ( p_token_an  IN      VARCHAR2,
    p_token_ip  IN      VARCHAR2 );

------------------------------------------------------------------------------
--  Procedure   : Add_Same_Val_Update_Msg
--  Description : Add the CS_API_ALL_SAME_VAL_UPDATE message to the message
--                list.
--  Parameters  :
--  IN          : p_token_an            IN      VARCHAR2        Required
--                      Value of the API_NAME token.
--                p_token_p             IN      VARCHAR2        Required
--                      Value of the SAME_VAL_PARAM token.
------------------------------------------------------------------------------

PROCEDURE Add_Same_Val_Update_Msg
  ( p_token_an  IN   VARCHAR2,
    p_token_p   IN   VARCHAR2 );

------------------------------------------------------------------------------
--  Procedure   : Convert_Contact_To_ID
--  Description : Convert a contact last name and first name into the
--                corresponding internal ID.
--  Parameters  :
--  IN          : p_api_name            IN      VARCHAR2(30)    Required
--                      Name of the calling API (used for messages)
--                p_parameter_name_ln   IN      VARCHAR2(30)    Required
--                      Name of the first value-based parameter in the calling
--                      API (e.g. 'p_contact_lastname')
--                p_parameter_name_fn   IN      VARCHAR2(30)    Required
--                      Name of the second value-based parameter in the
--                      calling API (e.g. 'p_contact_firstname')
--                p_contact_lastname    IN      VARCHAR2(30)    Required
--                      Value of the contact last name to be converted
--                p_contact_firstname   IN      VARCHAR2(50)    Optional
--                      Value of the contact first name to be converted
--  OUT         : x_contact_id          OUT     NUMBER
--                x_return_status       OUT     VARCHAR2(1)
--                      FND_API.G_RET_STS_SUCCESS       => conversion success
--                      FND_API.G_RET_STS_ERROR         => conversion failure
------------------------------------------------------------------------------

PROCEDURE Convert_Contact_To_ID
  ( p_api_name          IN      VARCHAR2,
    p_parameter_name_ln IN      VARCHAR2,
    p_parameter_name_fn IN      VARCHAR2,
    p_contact_lastname  IN      VARCHAR2,
    p_contact_firstname IN      VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
    x_contact_id        OUT NOCOPY     NUMBER,
    x_return_status     OUT NOCOPY     VARCHAR2 );

------------------------------------------------------------------------------
--  Procedure   : Convert_Customer_To_ID
--  Description : Convert a customer name or a customer number into the
--                corresponding internal ID. Either p_customer_name or
--                p_customer_number must be passed. If both are passed,
--                p_customer_name will be ignored.
--  Parameters  :
--  IN          : p_api_name            IN      VARCHAR2(30)    Required
--                      Name of the calling API (used for messages)
--                p_parameter_name_nb   IN      VARCHAR2(30)    Required
--                      Name of the first value-based parameter in the calling
--                      API (e.g. 'p_customer_number')
--                p_parameter_name_n    IN      VARCHAR2(30)    Required
--                      Name of the second value-based parameter in the
--                      calling API (e.g. 'p_customer_name')
--                p_customer_number     IN      VARCHAR2(30)    Optional
--                      Value of the customer number to be converted
--                p_customer_name       IN      VARCHAR2(50)    Optional
--                      Value of the customer name to be converted
--  OUT         : x_customer_id         OUT     NUMBER
--                x_return_status       OUT     VARCHAR2(1)
--                      FND_API.G_RET_STS_SUCCESS       => conversion success
--                      FND_API.G_RET_STS_ERROR         => conversion failure
------------------------------------------------------------------------------

PROCEDURE Convert_Customer_To_ID
  ( p_api_name          IN      VARCHAR2,
    p_parameter_name_nb IN      VARCHAR2,
    p_parameter_name_n  IN      VARCHAR2,
    p_customer_number   IN      VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
    p_customer_name     IN      VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
    x_customer_id       OUT NOCOPY     NUMBER,
    x_return_status     OUT NOCOPY     VARCHAR2 );

------------------------------------------------------------------------------
--  Procedure   : Convert_Customer_To_Name
--  Description : Converts a customer ID to the customer name
--  Parameters  :
--  IN          : p_api_name            IN      VARCHAR2        Required
--                      Name of the calling API (used for messages)
--                p_parameter_name      IN      VARCHAR2        Required
--                      Name of the ID-based parameter in the calling API
--                      (e.g. 'p_customer_id')
--                p_customer_id         IN      NUMBER          Required
--                      Value of the customer ID to be converted
--  OUT         : x_customer_name       OUT     VARCHAR2(50)
--                x_return_status       OUT     VARCHAR2(1)
--                      FND_API.G_RET_STS_SUCCESS       => conversion success
--                      FND_API.G_RET_STS_ERROR         => conversion failure
------------------------------------------------------------------------------

PROCEDURE Convert_Customer_To_Name
  ( p_api_name          IN      VARCHAR2,
    p_parameter_name    IN      VARCHAR2,
    p_customer_id       IN      NUMBER,
    x_customer_name     OUT NOCOPY     VARCHAR2,
    x_return_status     OUT NOCOPY     VARCHAR2 );

------------------------------------------------------------------------------
--  Procedure   : Convert_Employee_To_ID
--  Description : Convert an employee name or an employee number into the
--                corresponding internal ID. Either p_employee_name or
--                p_employee_number must be passed. If both are passed,
--                p_employee_name will be ignored.
--  Parameters  :
--  IN          : p_api_name            IN      VARCHAR2(30)    Required
--                      Name of the calling API (used for messages)
--                p_parameter_name_nb   IN      VARCHAR2(30)    Required
--                      Name of the first value-based parameter in the calling
--                      API (e.g. 'p_employee_number')
--                p_parameter_name_n    IN      VARCHAR2(30)    Required
--                      Name of the second value-based parameter in the
--                      calling API (e.g. 'p_employee_name')
--                p_employee_number     IN      VARCHAR2(30)    Optional
--                      Value of the employee number to be converted
--                p_employee_name       IN      VARCHAR2(50)    Optional
--                      Value of the employee name to be converted
--  OUT         : x_employee_id         OUT     NUMBER
--                x_return_status       OUT     VARCHAR2(1)
--                      FND_API.G_RET_STS_SUCCESS       => conversion success
--                      FND_API.G_RET_STS_ERROR         => conversion failure
------------------------------------------------------------------------------

PROCEDURE Convert_Employee_To_ID
  ( p_api_name          IN      VARCHAR2,
    p_parameter_name_nb IN      VARCHAR2,
    p_parameter_name_n  IN      VARCHAR2,
    p_employee_number   IN      VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
    p_employee_name     IN      VARCHAR2 DEFAULT FND_API.G_MISS_CHAR,
    x_employee_id       OUT NOCOPY     NUMBER,
    x_return_status     OUT NOCOPY     VARCHAR2 );

------------------------------------------------------------------------------
--  Procedure   : Convert_Lookup_To_Code
--  Description : Convert a lookup meaning into the corresponding internal
--                code.
--  Parameters  :
--  IN          : p_api_name            IN      VARCHAR2(30)    Required
--              Name of the calling API (used for messages)
--                p_parameter_name      IN      VARCHAR2(30)    Required
--              Name of the value-based parameter in the calling API
--                p_meaning             IN      VARCHAR2(30)    Required
--              Value of the lookup meaning to be converted
--                p_lookup_type         IN      VARCHAR2(30)    Required
--  OUT         : x_lookup_code         OUT     VARCHAR2(30)
--                x_return_status       OUT     VARCHAR2(1)
--                      FND_API.G_RET_STS_SUCCESS       => conversion success
--                      FND_API.G_RET_STS_ERROR         => conversion failure
------------------------------------------------------------------------------

PROCEDURE Convert_Lookup_To_Code
  ( p_api_name          IN      VARCHAR2,
    p_parameter_name    IN      VARCHAR2,
    p_meaning           IN      VARCHAR2,
    p_lookup_type       IN      VARCHAR2,
    x_lookup_code       OUT NOCOPY     VARCHAR2,
    x_return_status     OUT NOCOPY     VARCHAR2 );

------------------------------------------------------------------------------
--  Procedure   : Convert_Org_To_ID
--  Description : Convert an operating unit name into the corresponding
--                internal ID.
--  Parameters  :
--  IN          : p_api_name            IN      VARCHAR2(30)    Required
--                      Name of the calling API (used for messages)
--                p_parameter_name      IN      VARCHAR2(30)    Required
--                      Name of the value-based parameter in the calling API
--                      (e.g. 'p_org_name')
--                p_org_name            IN      VARCHAR2(60)    Required
--                      Value of the operating unit name to be converted
--  OUT         : x_org_id              OUT     NUMBER
--                x_return_status       OUT     VARCHAR2(1)
--                      FND_API.G_RET_STS_SUCCESS       => conversion success
--                      FND_API.G_RET_STS_ERROR         => conversion failure
------------------------------------------------------------------------------

PROCEDURE Convert_Org_To_ID
  ( p_api_name          IN      VARCHAR2,
    p_parameter_name    IN      VARCHAR2,
    p_org_name          IN      VARCHAR2,
    x_org_id            OUT NOCOPY     NUMBER,
    x_return_status     OUT NOCOPY     VARCHAR2 );

------------------------------------------------------------------------------
--  Procedure   : Default_Common_Attributes
--  Description : Default application ID, responsibility ID, user ID, login
--                ID, operating unit ID and inventory organization ID.
--                If the parameter is FND_API.G_MISS_NUM, then the default
--                value for that attribute is returned. Else the passed value
--                is returned.
--  Parameters  :
--  IN          : p_api_name            IN      VARCHAR2(30)    Required
--                      Name of the calling API (used for messages)
--  IN OUT      : p_resp_appl_id        IN OUT  NUMBER          Required
--                p_resp_id             IN OUT  NUMBER          Required
--                p_user_id             IN OUT  NUMBER          Required
--                p_login_id            IN OUT  NUMBER          Required
--                p_org_id              IN OUT  NUMBER          Required
--                p_inventory_org_id    IN OUT  NUMBER          Required
------------------------------------------------------------------------------
/*
PROCEDURE Default_Common_Attributes
  ( p_api_name          IN      VARCHAR2,
    p_resp_appl_id      IN OUT  NUMBER,
    p_resp_id           IN OUT  NUMBER,
    p_user_id           IN OUT  NUMBER,
    p_login_id          IN OUT  NUMBER,
    p_org_id            IN OUT  NUMBER,
    p_inventory_org_id  IN OUT  NUMBER );
*/
------------------------------------------------------------------------------
--  Function    : Is_MultiOrg_Enabled
--  Description : Checks if the Multi-Org feature is enabled.
--  Parameters  : None.
--  Return      : BOOLEAN
--                      Returns TRUE if Multi-Org is enabled; FALSE otherwise
------------------------------------------------------------------------------

FUNCTION Is_MultiOrg_Enabled RETURN BOOLEAN;

------------------------------------------------------------------------------
--  Procedure   : Trunc_String_Length
--  Description : Verify that the string is shorter than the defined width of
--                the column. If the character value is longer than the
--                defined width of the VARCHAR2 column, truncate the value.
--  Parameters  :
--  IN          : p_api_name            IN      VARCHAR2(30)    Required
--                      Name of the calling API (used for messages)
--                p_parameter_name      IN      VARCHAR2(30)    Required
--                      Name of the parameter in the calling API
--                      (e.g. 'p_notes')
--                p_str                 IN      VARCHAR2        Required
--                      Value of the VARCHAR2 parameter
--                p_len                 IN      NUMBER          Required
--                      Length of the corresponding database column
--  OUT         : x_str                 OUT     VARCHAR2        Required
--                      Value of the VARCHAR2 parameter (may be truncated)
------------------------------------------------------------------------------

PROCEDURE Trunc_String_length
  ( p_api_name          IN      VARCHAR2,
    p_parameter_name    IN      VARCHAR2,
    p_str               IN      VARCHAR2,
    p_len               IN      NUMBER,
    x_str               OUT NOCOPY     VARCHAR2 );

------------------------------------------------------------------------------
--  Procedure   : Validate_Bill_To_Site
--  Description : Verify that the given site is a valid billing site within
--                the given operating unit, and it belongs to the given
--                customer or a related customer.
--  Parameters  :
--  IN          : p_api_name            IN      VARCHAR2        Required
--                      Name of the calling procedure
--                p_parameter_name      IN      VARCHAR2        Required
--                      Name of the parameter in the calling API
--                      (e.g. 'p_bill_to_site_use_id')
--                p_bill_to_site_id     IN      NUMBER          Required
--                p_customer_id         IN      NUMBER          Required
--                p_org_id              IN      NUMBER          Optional
--  OUT         : x_bill_to_customer_id OUT     NUMBER
--                x_return_status       OUT     VARCHAR2(1)
--                      FND_API.G_RET_STS_SUCCESS       => site is valid
--                      FND_API.G_RET_STS_ERROR         => site is invalid
------------------------------------------------------------------------------

PROCEDURE Validate_Bill_To_Site
  ( p_api_name                  IN      VARCHAR2,
    p_parameter_name            IN      VARCHAR2,
    p_bill_to_site_id           IN      NUMBER,
    p_customer_id               IN      NUMBER,
    p_org_id                    IN      NUMBER   := NULL,
    x_bill_to_customer_id       OUT NOCOPY     NUMBER,
    x_return_status             OUT NOCOPY     VARCHAR2 );

------------------------------------------------------------------------------
--  Function    : Validate_Comment
--  Description : Validate that the given comment is valid.
--  Parameters  :
--  IN          : p_api_name            IN      VARCHAR2(30)    Required
--                      Name of the calling API (used for messages)
--                p_parameter_name      IN      VARCHAR2(30)    Required
--                      Name of the parameter in the calling API
--                      (e.g. 'p_comment_id')
--                p_comment_id          IN      NUMBER          Required
--                      Comment ID
--  OUT         : x_return_status       OUT     VARCHAR2(1)
--                      FND_API.G_RET_STS_SUCCESS       => comment is valid
--                      FND_API.G_RET_STS_ERROR         => comment is invalid
/**** bug 4887572 smisra
Removed this procedure
------------------------------------------------------------------------------

PROCEDURE Validate_Comment
  ( p_api_name          IN      VARCHAR2,
    p_parameter_name    IN      VARCHAR2,
    p_comment_id        IN      NUMBER,
    x_return_status     OUT NOCOPY     VARCHAR2 );

------------------------------------------------------------------------------
****/
--  Procedure   : Validate_Customer
--  Description : Verify that the given customer is valid and active.
--  Parameters  :
--  IN          : p_api_name            IN      VARCHAR2        Required
--                      Name of the calling API (used for messages)
--                p_parameter_name      IN      VARCHAR2        Required
--                      Name of the parameter in the calling API
--                      (e.g. 'p_customer_id')
--                p_customer_id         IN      NUMBER
--  OUT         : x_return_status       OUT     VARCHAR2(1)
--                      FND_API.G_RET_STS_SUCCESS       => customer is valid
--                      FND_API.G_RET_STS_ERROR         => customer is invalid
------------------------------------------------------------------------------

PROCEDURE Validate_Customer
  ( p_api_name          IN      VARCHAR2,
    p_parameter_name    IN      VARCHAR2,
    p_customer_id       IN      NUMBER,
    x_return_status     OUT NOCOPY     VARCHAR2 );

------------------------------------------------------------------------------
--  Procedure   : Validate_Customer_Contact
--  Description : Verify that the customer contact is valid and active and
--                belongs to the given customer or a related customer.
--  Parameters  :
--  IN          : p_api_name            IN      VARCHAR2        Required
--                      Name of the calling API (used for messages)
--                p_parameter_name      IN      VARCHAR2        Required
--                      Name of the parameter in the calling API
--                      (e.g. 'p_contact_id').
--                p_customer_contact_id IN      NUMBER          Required
--                      ID of the customer contact.
--                p_customer_id         IN      NUMBER          Required
--                      ID of the service request customer.
--                p_org_id              IN      NUMBER          Optional
--                      Value of the organization ID.
--  OUT         : x_return_status       OUT     VARCHAR2(1)
--                      FND_API.G_RET_STS_SUCCESS       => contact is valid
--                      FND_API.G_RET_STS_ERROR         => contact is invalid
------------------------------------------------------------------------------

PROCEDURE Validate_Customer_Contact
  ( p_api_name                  IN      VARCHAR2,
    p_parameter_name            IN      VARCHAR2,
    p_customer_contact_id       IN      NUMBER,
    p_customer_id               IN      NUMBER,
    p_org_id                    IN      NUMBER   := NULL,
    x_return_status             OUT NOCOPY     VARCHAR2 );

------------------------------------------------------------------------------
--  Procedure   : Validate_Desc_Flex
--  Description : Validate descriptive flexfield information. Verify that none
--                of the values are invalid, disabled, expired or not
--                available for the current user because of value security
--                rules.
--  Parameters  :
--  IN          : p_api_name            IN      VARCHAR2(30)    Required
--                      Name of the calling API (used for messages)
--                p_appl_short_name     IN      VARCHAR2(30)    Optional
--                      Application short name of the descriptive flexfield
--                p_desc_flex_name      IN      VARCHAR2(30)    Required
--                      Name of the descriptive flexfield
--                p_column_name1-15     IN      VARCHAR2(30)    Required
--                      Names of the 15 descriptive flexfield columns
--                p_column_value1-15    IN      VARCHAR2(150)   Required
--                      Values of the 15 descriptive flexfield segments
--                p_context_value       IN      VARCHAR2(30)    Required
--                      Value of the descriptive flexfield structure defining
--                      column
--                p_resp_appl_id        IN      NUMBER          Optional
--                      Application identifier
--                p_resp_id             IN      NUMBER          Optional
--                      Responsibility identifier
--  OUT         : x_return_status       OUT     VARCHAR2(1)
--                      FND_API.G_RET_STS_SUCCESS       => values are valid
--                      FND_API.G_RET_STS_ERROR         => values are invalid
------------------------------------------------------------------------------

PROCEDURE Validate_Desc_Flex
  ( p_api_name          IN      VARCHAR2,
    p_appl_short_name   IN      VARCHAR2 DEFAULT 'CS',
    p_desc_flex_name    IN      VARCHAR2,
    p_column_name1      IN      VARCHAR2,
    p_column_name2      IN      VARCHAR2,
    p_column_name3      IN      VARCHAR2,
    p_column_name4      IN      VARCHAR2,
    p_column_name5      IN      VARCHAR2,
    p_column_name6      IN      VARCHAR2,
    p_column_name7      IN      VARCHAR2,
    p_column_name8      IN      VARCHAR2,
    p_column_name9      IN      VARCHAR2,
    p_column_name10     IN      VARCHAR2,
    p_column_name11     IN      VARCHAR2,
    p_column_name12     IN      VARCHAR2,
    p_column_name13     IN      VARCHAR2,
    p_column_name14     IN      VARCHAR2,
    p_column_name15     IN      VARCHAR2,
    p_column_value1     IN      VARCHAR2,
    p_column_value2     IN      VARCHAR2,
    p_column_value3     IN      VARCHAR2,
    p_column_value4     IN      VARCHAR2,
    p_column_value5     IN      VARCHAR2,
    p_column_value6     IN      VARCHAR2,
    p_column_value7     IN      VARCHAR2,
    p_column_value8     IN      VARCHAR2,
    p_column_value9     IN      VARCHAR2,
    p_column_value10    IN      VARCHAR2,
    p_column_value11    IN      VARCHAR2,
    p_column_value12    IN      VARCHAR2,
    p_column_value13    IN      VARCHAR2,
    p_column_value14    IN      VARCHAR2,
    p_column_value15    IN      VARCHAR2,
    p_context_value     IN      VARCHAR2,
    p_resp_appl_id      IN      NUMBER   := NULL,
    p_resp_id           IN      NUMBER   := NULL,
    x_return_status     OUT NOCOPY     VARCHAR2 );
------------------------------------------------------------------------------
--  Procedure   : Validate_Price_Attribs
--  Description : Validate Pricing attrib information. Verify that none
--                of the values are invalid, disabled, expired or not
--                available for the current user because of value security
--                rules.
--  Parameters  :
--  IN          : p_api_name            IN      VARCHAR2(30)    Required
--                      Name of the calling API (used for messages)
--                p_appl_short_name     IN      VARCHAR2(30)    Optional
--                      Application short name of the pricing attributes
--                p_price_attrib_name   IN      VARCHAR2(30)    Required
--                      Name of the pricing attributes
--                p_column_name1-15     IN      VARCHAR2(30)    Required
--                      Names of the 15 pricing attributes columns
--                p_column_value1-15    IN      VARCHAR2(150)   Required
--                      Values of the 15 pricing attributes segments
--                p_context_value       IN      VARCHAR2(30)    Required
--                      Value of the pricing attributes structure defining
--                      column
--                p_resp_appl_id        IN      NUMBER          Optional
--                      Application identifier
--                p_resp_id             IN      NUMBER          Optional
--                      Responsibility identifier
--  OUT         : x_return_status       OUT     VARCHAR2(1)
--                      FND_API.G_RET_STS_SUCCESS       => values are valid
--                      FND_API.G_RET_STS_ERROR         => values are invalid
------------------------------------------------------------------------------

PROCEDURE Validate_Price_Attribs
  ( p_api_name          IN      VARCHAR2,
    p_appl_short_name   IN      VARCHAR2 DEFAULT 'CS',
    p_desc_flex_name    IN      VARCHAR2,
	p_column_name1          IN VARCHAR2,
	p_column_name2          IN VARCHAR2,
	p_column_name3          IN VARCHAR2,
	p_column_name4          IN VARCHAR2,
	p_column_name5          IN VARCHAR2,
	p_column_name6          IN VARCHAR2,
	p_column_name7          IN VARCHAR2,
	p_column_name8          IN VARCHAR2,
	p_column_name9          IN VARCHAR2,
	p_column_name10         IN VARCHAR2,
	p_column_name11         IN VARCHAR2,
	p_column_name12         IN VARCHAR2,
	p_column_name13         IN VARCHAR2,
	p_column_name14         IN VARCHAR2,
	p_column_name15         IN VARCHAR2,
	p_column_name16         IN VARCHAR2,
	p_column_name17         IN VARCHAR2,
	p_column_name18         IN VARCHAR2,
	p_column_name19         IN VARCHAR2,
	p_column_name20         IN VARCHAR2,
	p_column_name21         IN VARCHAR2,
	p_column_name22         IN VARCHAR2,
	p_column_name23         IN VARCHAR2,
	p_column_name24         IN VARCHAR2,
	p_column_name25         IN VARCHAR2,
	p_column_name26         IN VARCHAR2,
	p_column_name27         IN VARCHAR2,
	p_column_name28         IN VARCHAR2,
	p_column_name29         IN VARCHAR2,
	p_column_name30         IN VARCHAR2,
	p_column_name31         IN VARCHAR2,
	p_column_name32         IN VARCHAR2,
	p_column_name33         IN VARCHAR2,
	p_column_name34         IN VARCHAR2,
	p_column_name35         IN VARCHAR2,
	p_column_name36         IN VARCHAR2,
	p_column_name37         IN VARCHAR2,
	p_column_name38         IN VARCHAR2,
	p_column_name39         IN VARCHAR2,
	p_column_name40         IN VARCHAR2,
	p_column_name41         IN VARCHAR2,
	p_column_name42         IN VARCHAR2,
	p_column_name43         IN VARCHAR2,
	p_column_name44         IN VARCHAR2,
	p_column_name45         IN VARCHAR2,
	p_column_name46         IN VARCHAR2,
	p_column_name47         IN VARCHAR2,
	p_column_name48         IN VARCHAR2,
	p_column_name49         IN VARCHAR2,
	p_column_name50         IN VARCHAR2,
	p_column_name51         IN VARCHAR2,
	p_column_name52         IN VARCHAR2,
	p_column_name53         IN VARCHAR2,
	p_column_name54         IN VARCHAR2,
	p_column_name55         IN VARCHAR2,
	p_column_name56         IN VARCHAR2,
	p_column_name57         IN VARCHAR2,
	p_column_name58         IN VARCHAR2,
	p_column_name59         IN VARCHAR2,
	p_column_name60         IN VARCHAR2,
	p_column_name61         IN VARCHAR2,
	p_column_name62         IN VARCHAR2,
	p_column_name63         IN VARCHAR2,
	p_column_name64         IN VARCHAR2,
	p_column_name65         IN VARCHAR2,
	p_column_name66         IN VARCHAR2,
	p_column_name67         IN VARCHAR2,
	p_column_name68         IN VARCHAR2,
	p_column_name69         IN VARCHAR2,
	p_column_name70         IN VARCHAR2,
	p_column_name71         IN VARCHAR2,
	p_column_name72         IN VARCHAR2,
	p_column_name73         IN VARCHAR2,
	p_column_name74         IN VARCHAR2,
	p_column_name75         IN VARCHAR2,
	p_column_name76         IN VARCHAR2,
	p_column_name77         IN VARCHAR2,
	p_column_name78         IN VARCHAR2,
	p_column_name79         IN VARCHAR2,
	p_column_name80         IN VARCHAR2,
	p_column_name81         IN VARCHAR2,
	p_column_name82         IN VARCHAR2,
	p_column_name83         IN VARCHAR2,
	p_column_name84         IN VARCHAR2,
	p_column_name85         IN VARCHAR2,
	p_column_name86         IN VARCHAR2,
	p_column_name87         IN VARCHAR2,
	p_column_name88         IN VARCHAR2,
	p_column_name89         IN VARCHAR2,
	p_column_name90         IN VARCHAR2,
	p_column_name91         IN VARCHAR2,
	p_column_name92         IN VARCHAR2,
	p_column_name93         IN VARCHAR2,
	p_column_name94         IN VARCHAR2,
	p_column_name95         IN VARCHAR2,
	p_column_name96         IN VARCHAR2,
	p_column_name97         IN VARCHAR2,
	p_column_name98         IN VARCHAR2,
	p_column_name99         IN VARCHAR2,
	p_column_name100        IN VARCHAR2,
	p_column_value1         IN VARCHAR2,
	p_column_value2         IN VARCHAR2,
	p_column_value3         IN VARCHAR2,
	p_column_value4         IN VARCHAR2,
	p_column_value5         IN VARCHAR2,
	p_column_value6         IN VARCHAR2,
	p_column_value7         IN VARCHAR2,
	p_column_value8         IN VARCHAR2,
	p_column_value9         IN VARCHAR2,
	p_column_value10                IN VARCHAR2,
	p_column_value11                IN VARCHAR2,
	p_column_value12                IN VARCHAR2,
	p_column_value13                IN VARCHAR2,
	p_column_value14                IN VARCHAR2,
	p_column_value15                IN VARCHAR2,
	p_column_value16                IN VARCHAR2,
	p_column_value17                IN VARCHAR2,
	p_column_value18                IN VARCHAR2,
	p_column_value19                IN VARCHAR2,
	p_column_value20                IN VARCHAR2,
	p_column_value21                IN VARCHAR2,
	p_column_value22                IN VARCHAR2,
	p_column_value23                IN VARCHAR2,
	p_column_value24                IN VARCHAR2,
	p_column_value25                IN VARCHAR2,
	p_column_value26                IN VARCHAR2,
	p_column_value27                IN VARCHAR2,
	p_column_value28                IN VARCHAR2,
	p_column_value29                IN VARCHAR2,
	p_column_value30                IN VARCHAR2,
	p_column_value31                IN VARCHAR2,
	p_column_value32                IN VARCHAR2,
	p_column_value33                IN VARCHAR2,
	p_column_value34                IN VARCHAR2,
	p_column_value35                IN VARCHAR2,
	p_column_value36                IN VARCHAR2,
	p_column_value37                IN VARCHAR2,
	p_column_value38                IN VARCHAR2,
	p_column_value39                IN VARCHAR2,
	p_column_value40                IN VARCHAR2,
	p_column_value41                IN VARCHAR2,
	p_column_value42                IN VARCHAR2,
	p_column_value43                IN VARCHAR2,
	p_column_value44                IN VARCHAR2,
	p_column_value45                IN VARCHAR2,
	p_column_value46                IN VARCHAR2,
	p_column_value47                IN VARCHAR2,
	p_column_value48                IN VARCHAR2,
	p_column_value49                IN VARCHAR2,
	p_column_value50                IN VARCHAR2,
	p_column_value51                IN VARCHAR2,
	p_column_value52                IN VARCHAR2,
	p_column_value53                IN VARCHAR2,
	p_column_value54                IN VARCHAR2,
	p_column_value55                IN VARCHAR2,
	p_column_value56                IN VARCHAR2,
	p_column_value57                IN VARCHAR2,
	p_column_value58                IN VARCHAR2,
	p_column_value59                IN VARCHAR2,
	p_column_value60                IN VARCHAR2,
	p_column_value61                IN VARCHAR2,
	p_column_value62                IN VARCHAR2,
	p_column_value63                IN VARCHAR2,
	p_column_value64                IN VARCHAR2,
	p_column_value65                IN VARCHAR2,
	p_column_value66                IN VARCHAR2,
	p_column_value67                IN VARCHAR2,
	p_column_value68                IN VARCHAR2,
	p_column_value69                IN VARCHAR2,
	p_column_value70                IN VARCHAR2,
	p_column_value71                IN VARCHAR2,
	p_column_value72                IN VARCHAR2,
	p_column_value73                IN VARCHAR2,
	p_column_value74                IN VARCHAR2,
	p_column_value75                IN VARCHAR2,
	p_column_value76                IN VARCHAR2,
	p_column_value77                IN VARCHAR2,
	p_column_value78                IN VARCHAR2,
	p_column_value79                IN VARCHAR2,
	p_column_value80                IN VARCHAR2,
	p_column_value81                IN VARCHAR2,
	p_column_value82                IN VARCHAR2,
	p_column_value83                IN VARCHAR2,
	p_column_value84                IN VARCHAR2,
	p_column_value85                IN VARCHAR2,
	p_column_value86                IN VARCHAR2,
	p_column_value87                IN VARCHAR2,
	p_column_value88                IN VARCHAR2,
	p_column_value89                IN VARCHAR2,
	p_column_value90                IN VARCHAR2,
	p_column_value91                IN VARCHAR2,
	p_column_value92                IN VARCHAR2,
	p_column_value93                IN VARCHAR2,
	p_column_value94                IN VARCHAR2,
	p_column_value95                IN VARCHAR2,
	p_column_value96                IN VARCHAR2,
	p_column_value97                IN VARCHAR2,
	p_column_value98                IN VARCHAR2,
	p_column_value99                IN VARCHAR2,
	p_column_value100               IN VARCHAR2,
    p_context_value     IN      VARCHAR2,
    p_resp_appl_id      IN      NUMBER   := NULL,
    p_resp_id           IN      NUMBER   := NULL,
    x_return_status     OUT NOCOPY     VARCHAR2 );

------------------------------------------------------------------------------
--  Procedure   : Validate_Employee
--  Description : Verify that the employee ID is a valid and active employee
--                assigned to the Oracle Personnel business group ID stored in
--                FINANCIALS_SYSTEM_PARAMETERS.
--  Parameters  :
--  IN          : p_api_name            IN      VARCHAR2        Required
--                      Name of the calling API (used for messages)
--                p_parameter_name      IN      VARCHAR2        Required
--                      Name of the parameter in the calling API
--                p_employee_id         IN      NUMBER          Required
--                p_org_id              IN      NUMBER          Optional
--                      If Multi-Org is enabled, this value cannot be null;
--                      otherwise this validation routine will fail.
--  OUT         : x_return_status       OUT     VARCHAR2(1)
--                      FND_API.G_RET_STS_SUCCESS       => employee is valid
--                      FND_API.G_RET_STS_ERROR         => employee is invalid
------------------------------------------------------------------------------

PROCEDURE Validate_Employee
  ( p_api_name          IN      VARCHAR2,
    p_parameter_name    IN      VARCHAR2,
    p_employee_id       IN      NUMBER,
    p_org_id            IN      NUMBER   := NULL,
    x_return_status     OUT NOCOPY     VARCHAR2 );

------------------------------------------------------------------------------
--  Procedure   : Validate_Later_Date
--  Description : Verify that the later date is later than the earlier date.
--  Parameters  :
--  IN          : p_api_name            IN      VARCHAR2        Required
--                      Name of the calling API (used for messages)
--                p_parameter_name      IN      VARCHAR2        Required
--                      Name of the parameter in the calling API
--                p_later_date          IN      DATE            Required
--                p_earlier_date        IN      DATE            Required
--  OUT         : x_return_status       OUT     VARCHAR2(1)
--                      FND_API.G_RET_STS_SUCCESS       => date is valid
--                      FND_API.G_RET_STS_ERROR         => date is invalid
------------------------------------------------------------------------------

PROCEDURE Validate_Later_Date
  ( p_api_name          IN      VARCHAR2,
    p_parameter_name    IN      VARCHAR2,
    p_later_date        IN      DATE,
    p_earlier_date      IN      DATE,
    x_return_status     OUT NOCOPY     VARCHAR2 );

------------------------------------------------------------------------------
--  Procedure   : Validate_Lookup_Code
--  Description : Validate that the lookup code is valid, enabled and active.
--  Parameters  :
--  IN          : p_api_name            IN      VARCHAR2        Required
--                      Name of the calling API (used for messages)
--                p_parameter_name      IN      VARCHAR2        Required
--                      Name of the parameter in the calling API
--                p_lookup_code         IN      VARCHAR2        Required
--                      Lookup code to be validated
--                p_lookup_type         IN      VARCHAR2        Required
--                      Type of the lookup code
--  OUT         : x_return_status       OUT     VARCHAR2(1)
--                      FND_API.G_RET_STS_SUCCESS       => code is valid
--                      FND_API.G_RET_STS_ERROR         => code is invalid
------------------------------------------------------------------------------

PROCEDURE Validate_Lookup_Code
  ( p_api_name          IN      VARCHAR2,
    p_parameter_name    IN      VARCHAR2,
    p_lookup_code       IN      VARCHAR2,
    p_lookup_type       IN      VARCHAR2,
    x_return_status     OUT NOCOPY     VARCHAR2 );

------------------------------------------------------------------------------
--  Function    : Validate_Operating_Unit
--  Description : Validate that the org ID identifies a valid operating unit
--  Parameters  :
--  IN          : p_api_name            IN      VARCHAR2(30)    Required
--                      Name of the calling API (used for messages)
--                p_parameter_name      IN      VARCHAR2(30)    Required
--                      Name of the parameter in the calling API
--                      (e.g. 'p_org_id')
--                p_org_id              IN      NUMBER          Required
--                      Operating Unit ID
--  OUT         : x_return_status       OUT     VARCHAR2(1)
--                      FND_API.G_RET_STS_SUCCESS       => org ID is valid
--                      FND_API.G_RET_STS_ERROR         => org ID is invalid
------------------------------------------------------------------------------

PROCEDURE Validate_Operating_Unit
  ( p_api_name          IN      VARCHAR2,
    p_parameter_name    IN      VARCHAR2,
    p_org_id            IN      NUMBER,
    x_return_status     OUT NOCOPY     VARCHAR2 );

------------------------------------------------------------------------------
--  Function    : Validate_Person
--  Description : Validate that the given person is a valid and active
--                employee assigned to any business group.
--  Parameters  :
--  IN          : p_api_name            IN      VARCHAR2(30)    Required
--                      Name of the calling API (used for messages)
--                p_parameter_name      IN      VARCHAR2(30)    Required
--                      Name of the parameter in the calling API
--                      (e.g. 'p_person_id')
--                p_person_id           IN      NUMBER          Required
--                      Person ID
--  OUT         : x_return_status       OUT     VARCHAR2(1)
--                      FND_API.G_RET_STS_SUCCESS       => person is valid
--                      FND_API.G_RET_STS_ERROR         => person is invalid
------------------------------------------------------------------------------

PROCEDURE Validate_Person
  ( p_api_name          IN      VARCHAR2,
    p_parameter_name    IN      VARCHAR2,
    p_person_id         IN      NUMBER,
    x_return_status     OUT NOCOPY     VARCHAR2 );

------------------------------------------------------------------------------
--  Procedure   : Validate_Ship_To_Site
--  Description : Verify that the given site is a valid shipping site within
--                the given operating unit, and it belongs to the given
--                customer or a related customer.
--  Parameters  :
--  IN          : p_api_name            IN      VARCHAR2        Required
--                      Name of the calling API (used for messages)
--                p_parameter_name      IN      VARCHAR2        Required
--                      Name of the parameter in the calling API
--                      (e.g. 'p_ship_to_site_use_id').
--                p_ship_to_site_use_id IN      NUMBER          Required
--                      Location ID of the customer site.
--                p_customer_id         IN      NUMBER          Required
--                      ID of the service request customer.
--                p_org_id              IN      NUMBER          Optional
--                      Value of the organization ID.
--  OUT         : x_ship_to_customer_id OUT     NUMBER
--                x_return_status       OUT     VARCHAR2(1)
--                      FND_API.G_RET_STS_SUCCESS       => site is valid
--                      FND_API.G_RET_STS_ERROR         => site is invalid
------------------------------------------------------------------------------

PROCEDURE Validate_Ship_To_Site
  ( p_api_name                  IN      VARCHAR2,
    p_parameter_name            IN      VARCHAR2,
    p_ship_to_site_use_id       IN      NUMBER,
    p_customer_id               IN      NUMBER,
    p_org_id                    IN      NUMBER   := NULL,
    x_ship_to_customer_id       OUT NOCOPY     NUMBER,
    x_return_status             OUT NOCOPY     VARCHAR2 );

-------------------------------------------------------------------------------
--  Procedure   : Validate_Source_Object_ID
--  Description : Validate that the given source object ID identifies a valid
--                record for the given source object type.
--  Parameters  :
--  IN          : p_api_name            IN      VARCHAR2(30)    Required
--                      Name of the calling API (used for messages)
--                p_parameter_name      IN      VARCHAR2(30)    Required
--                      Name of the parameter in the calling API
--                      (e.g. 'p_source_object_id')
--                p_source_object_id    IN      NUMBER          Required
--                      Source object identifier
--                p_source_object_code  IN      VARCHAR2(30)    Required
--                      Lookup code for the source object type
--                p_org_id              IN      NUMBER          Optional
--                      Value of the organization ID.
--  OUT         : x_return_status       OUT     VARCHAR2(1)
--                      FND_API.G_RET_STS_SUCCESS       => comment is valid
--                      FND_API.G_RET_STS_ERROR         => comment is invalid
-------------------------------------------------------------------------------

PROCEDURE Validate_Source_Object_ID
  ( p_api_name                  IN      VARCHAR2,
    p_parameter_name            IN      VARCHAR2,
    p_source_object_id          IN      NUMBER,
    p_source_object_code        IN      VARCHAR2 := 'INC',
    p_org_id                    IN      NUMBER   := NULL,
    x_return_status             OUT NOCOPY     VARCHAR2 );

------------------------------------------------------------------------------
--  Procedure   : Validate_Who_Info
--  Description : Verify that the user and login session are valid and active
--  Parameters  :
--  IN          : p_api_name            IN      VARCHAR2        Required
--                      Name of the calling API (used for messages)
--                p_parameter_name_usr  IN      VARCHAR2        Required
--                      Name of the user id parameter in the calling API
--                      (e.g. 'p_user_id')
--                p_parameter_name_log  IN      VARCHAR2        Required
--                      Name of the login id parameter in the calling API
--                      (e.g. 'p_login_id')
--                p_user_id             IN      NUMBER
--                p_login_id            IN      NUMBER
--                p_resp_id             IN      NUMBER          Optional
--                p_resp_appl_id        IN      NUMBER          Optional
--  OUT         : x_return_status       OUT     VARCHAR2(1)
--                      FND_API.G_RET_STS_SUCCESS       => IDs are valid
--                      FND_API.G_RET_STS_ERROR         => IDs are invalid
------------------------------------------------------------------------------

PROCEDURE Validate_Who_Info
  ( p_api_name                  IN      VARCHAR2,
    p_parameter_name_usr        IN      VARCHAR2,
    p_parameter_name_log        IN      VARCHAR2,
    p_user_id                   IN      NUMBER,
    p_login_id                  IN      NUMBER,
    p_resp_id                   IN      NUMBER   := NULL,
    p_resp_appl_id              IN      NUMBER   := NULL,
    x_return_status             OUT NOCOPY     VARCHAR2 );

PROCEDURE Is_DescFlex_Valid
(
	p_api_name                      IN      VARCHAR2,
	p_appl_short_name               IN      VARCHAR2        DEFAULT 'CS',
	p_desc_flex_name                IN      VARCHAR2,
	p_seg_partial_name              IN      VARCHAR2,
	p_num_of_attributes             IN      NUMBER,
	p_seg_values                    IN      DFF_Rec_Type,
	p_stack_err_msg         IN      BOOLEAN DEFAULT TRUE
);

PROCEDURE Is_PriceAttribs_Valid
(
	p_api_name                      IN      VARCHAR2,
	p_appl_short_name               IN      VARCHAR2        DEFAULT 'CS',
	p_price_attrib_name             IN      VARCHAR2,
	p_seg_partial_name              IN      VARCHAR2,
	p_seg_values                    IN      PRICE_ATT_Rec_Type,
	p_stack_err_msg         IN      BOOLEAN DEFAULT TRUE
);
------------------------------------------------------------------------------
--  Function            : get_g_false
--  Description : Used as a wrapper function to get FND_API.G_FALSE.
--  Parameters          :
--  IN                  : None
--  OUT                 : None
--  RETURN              : FND_API.G_FALSE       VARCHAR2
------------------------------------------------------------------------------

FUNCTION get_g_false return varchar2;

------------------------------------------------------------------------------
--  Function            : get_g_true
--  Description : Used as a wrapper function to get FND_API.G_TRUE.
--  Parameters          :
--  IN                  : None
--  OUT                 : None
--  RETURN              : FND_API.G_TRUE        VARCHAR2
------------------------------------------------------------------------------

FUNCTION get_g_true return varchar2;

------------------------------------------------------------------------------
--  Function            : get_g_valid_level_full
--  Description : Used as a wrapper function to get FND_API.G_VALID_LEVEL_FULL.
--  Parameters          :
--  IN                  : None
--  OUT                 : None
--  RETURN              : FND_API.G_VALID_LEVEL_FULL    VARCHAR2
------------------------------------------------------------------------------

FUNCTION get_g_valid_level_full return varchar2;

------------------------------------------------------------------------------
--  Function            : get_g_miss_num
--  Description : Used as a wrapper function to get FND_API.G_MISS_NUM.
--  Parameters          :
--  IN                  : None
--  OUT                 : None
--  RETURN              : FND_API.G_MISS_NUM    NUMBER
------------------------------------------------------------------------------

FUNCTION get_g_miss_num return number;

------------------------------------------------------------------------------
--  Function            : get_g_miss_char
--  Description : Used as a wrapper function to get FND_API.G_MISS_CHAR.
--  Parameters          :
--  IN                  : None
--  OUT                 : None
--  RETURN              : FND_API.G_MISS_CHAR   VARCHAR2
------------------------------------------------------------------------------

FUNCTION get_g_miss_char return varchar2;

------------------------------------------------------------------------------
--  Function            : get_g_MISS_DATE
--  Description : Used as a wrapper function to get FND_API.G_MISS_DATE.
--  Parameters          :
--  IN                  : None
--  OUT                 : None
--  RETURN              : FND_API.G_MISS_DATE   DATE
------------------------------------------------------------------------------

FUNCTION get_g_miss_date return date;

---------------------------- End of Code -----------------------------

END CS_CORE_UTIL;

 

/
