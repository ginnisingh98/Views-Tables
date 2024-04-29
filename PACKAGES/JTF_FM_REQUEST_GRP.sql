--------------------------------------------------------
--  DDL for Package JTF_FM_REQUEST_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_FM_REQUEST_GRP" AUTHID CURRENT_USER AS
/* $Header: jtfgfms.pls 120.2 2005/12/27 00:36:01 anchaudh ship $*/
-- Priority Levels of the fulfillment requests.
-- Lower number represents higher priority
G_PRIORITY_HIGHEST   CONSTANT    NUMBER := 1;
G_PRIORITY_REGULAR CONSTANT    NUMBER := 7;
G_PRIORITY_BATCH_REQUEST CONSTANT    NUMBER := 8;

-- Table of string
TYPE G_VARCHAR_TBL_TYPE IS TABLE OF VARCHAR2(1000)
 INDEX BY BINARY_INTEGER;

L_VARCHAR_TBL G_VARCHAR_TBL_TYPE;

-- Table of numbers
TYPE G_NUMBER_TBL_TYPE IS TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;

L_NUMBER_TBL G_NUMBER_TBL_TYPE;


---------------------------------------------------------------------
-- PROCEDURE
--    Start_Request
--
-- PURPOSE
--    Start a new Fulfillment Request.
--
-- PARAMETERS
--    x_request_id - Unique request id
-- NOTES
--    . A unique request_id will be returned to the user
---------------------------------------------------------------------

PROCEDURE Start_Request
(
     p_api_version         IN  NUMBER,
  p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2,
 x_request_id OUT NOCOPY NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    Get_Content_XML
--
-- PURPOSE
--    Forms the XML request for a content based on the parameters passed
--   and returns it as an output parameter.
--
-- PARAMETERS
--    p_content_id: Unique Id of the content. (Required)
--   p_content_nm: The Name of the content.
--   p_quantity: Quantity of the content to be sent (Default = 1) .
--   p_media_type: Type of media - FAX, EMAIL, PRINTER, PATH.
--   p_printer:   Address of the printer
--   p_email:  Email Address
--   p_fax : Fax Address
--   p_file_path : File Path address
--   p_user_note: Any note that the agent wants to attach
--   p_content_type: Type of the content - QUERY, ATTACHMENT or COLLATERAL
--   p_bind_var : The list of bind variables
--   p_bind_var_type: The type of the corresponding bind variables
--   p_bind_val: Actual values of the corresponding bind variables.
--   p_request_id: The request ID obtained by calling the Start_Request API.
--   x_content_xml: Output content XML
--
-- NOTES
--    1. The content_type can be of type QUERY, COLLATERAL or ATTACHMENT.
--    2. The API currently does not form XML for DATA type of requests.
--    3. The Get_Content_XML API further handles only one Content per call.
--     Hence the output content_XML string needs to be appended to the
-- content_xml from the previous calls.
---------------------------------------------------------------------

PROCEDURE Get_Content_XML
(
     p_api_version         IN  NUMBER,
  p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2,
 p_content_id IN  NUMBER,
 p_content_nm IN  VARCHAR2 := FND_API.G_MISS_CHAR,
 p_document_type IN  VARCHAR2 := FND_API.G_MISS_CHAR, -- depreciated
 p_quantity IN  NUMBER := 1,
 p_media_type IN  VARCHAR2,
 p_printer IN  VARCHAR2 := FND_API.G_MISS_CHAR,
 p_email IN  VARCHAR2 := FND_API.G_MISS_CHAR,
 p_fax IN  VARCHAR2 := FND_API.G_MISS_CHAR,
 p_file_path IN  VARCHAR2 := FND_API.G_MISS_CHAR,
 p_user_note IN  VARCHAR2 := FND_API.G_MISS_CHAR,
 p_content_type IN  VARCHAR2,
 p_bind_var  IN G_VARCHAR_TBL_TYPE := L_VARCHAR_TBL,
 p_bind_val IN G_VARCHAR_TBL_TYPE := L_VARCHAR_TBL,
 p_bind_var_type IN G_VARCHAR_TBL_TYPE := L_VARCHAR_TBL,
 p_request_id IN NUMBER,
 x_content_xml OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE (Overloaded method added by SXKRISHN 10-28-02)
--    Get_Content_XML
--
-- PURPOSE
--    Forms the XML request for a content based on the parameters passed
--   and returns it as an output parameter.
--
-- PARAMETERS
--    p_content_id: Unique Id of the content. (Required)
--   p_content_nm: The Name of the content.
--   p_quantity: Quantity of the content to be sent (Default = 1) .
--   p_media_type: Type of media - FAX, EMAIL, PRINTER, PATH.
--   p_printer:   Address of the printer
--   p_email:  Email Address
--   p_fax : Fax Address
--   p_file_path : File Path address
--   p_user_note: Any note that the agent wants to attach
--   p_content_type: Type of the content - QUERY, ATTACHMENT or COLLATERAL
--   p_bind_var : The list of bind variables
--   p_bind_var_type: The type of the corresponding bind variables
--   p_bind_val: Actual values of the corresponding bind variables.
--   p_request_id: The request ID obtained by calling the Start_Request API.
--   x_content_xml: Output content XML
--	p_content_source  ; Source where the content is stored, MES Repository or OCM Repository (default mes)
--  p_body     : whether content needs to be body of the email        :
--  p_version  : If using OCM content, need to provide version of the document,default is latest
--
-- NOTES
--    1. The content_type can be of type QUERY, COLLATERAL or ATTACHMENT.
--    2. The API currently does not form XML for DATA type of requests.
--    3. The Get_Content_XML API further handles only one Content per call.
--     Hence the output content_XML string needs to be appended to the
-- content_xml from the previous calls.
---------------------------------------------------------------------

PROCEDURE Get_Content_XML
(
  p_api_version         IN  NUMBER,
  p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2,
  p_content_id IN  NUMBER,
  p_content_nm IN  VARCHAR2 := FND_API.G_MISS_CHAR,
  p_document_type IN  VARCHAR2 := FND_API.G_MISS_CHAR, -- depreciated
  p_quantity IN  NUMBER := 1,
  p_media_type IN  VARCHAR2,
  p_printer IN  VARCHAR2 := FND_API.G_MISS_CHAR,
  p_email IN  VARCHAR2 := FND_API.G_MISS_CHAR,
  p_fax IN  VARCHAR2 := FND_API.G_MISS_CHAR,
  p_file_path IN  VARCHAR2 := FND_API.G_MISS_CHAR,
  p_user_note IN  VARCHAR2 := FND_API.G_MISS_CHAR,
  p_content_type IN  VARCHAR2,
  p_bind_var  IN G_VARCHAR_TBL_TYPE := L_VARCHAR_TBL,
  p_bind_val IN G_VARCHAR_TBL_TYPE := L_VARCHAR_TBL,
  p_bind_var_type IN G_VARCHAR_TBL_TYPE := L_VARCHAR_TBL,
  p_request_id IN NUMBER,
  x_content_xml OUT NOCOPY  VARCHAR2,
  p_content_source        IN VARCHAR2  := 'mes',
  p_version               IN NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    Send_Request
--
-- PURPOSE
--  This procedure can be used to submit a new request for a single customer
--  to the fulfillment system.  This overloaded Submit_Request procedure allows
--  the caller to specify whether this request should be dispatched or simply
--  previewed
--
-- PARAMETERS
--   p_user_id: Agent/User Id
--   p_party_id: Customer ID
--   p_priority: These are defined as global constants in package JTF_FM_Request_GRP.
--   User Note - Unused priority numbers are for future use.
--   p_source_code_id : Campaign/promotion field
--   p_source_code    : Campaign/promotion field
--   p_object_type    : Campaign/promotion field
--   p_object_id      : Campaign/promotion field
--   p_order_id: Unique identifier of the order
--   p_server_id: Unique identifier of the sever
--   p_queue_response : Field to specify if response needs to queued in Response queue
--   p_content_xml :  The content xml formed by calling the Get_Content_XML
--  or Get_Multiple_Content_XML API's.
--   p_request_id : Request ID obtained by calling the Start_Request API.
--   p_preview : boolean condition of whether or not this is a preview request.

-- NOTES
--  1. The API will generate an XML request and submit it to the Fulfillment
--     Request Queue.
--  2. It also updates/creates fulfillment History and status records.
--  3. Default priority is G_PRIORITY_REGULAR
-------------------------------------------------------------------------

----------------------------------------------------------------------
-- PROCEDURE
--    Send_Request
--
-- HISTORY
--    10/01/99  nyalaman  Create.
--    05/07/01 sxkrishn overloaded with org_id
---------------------------------------------------------------
PROCEDURE Send_Request
(p_api_version       IN  NUMBER,
 p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
 p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
 p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
 x_return_status     OUT NOCOPY VARCHAR2,
 x_msg_count         OUT NOCOPY NUMBER,
 x_msg_data          OUT NOCOPY VARCHAR2,
 p_template_id       IN  NUMBER := FND_API.G_MISS_NUM,
 p_subject           IN  VARCHAR2 := FND_API.G_MISS_CHAR,
 p_party_id          IN  NUMBER := FND_API.G_MISS_NUM,
 p_party_name        IN  VARCHAR2 := FND_API.G_MISS_CHAR,
 p_user_id           IN  NUMBER,
 p_priority          IN  NUMBER := G_PRIORITY_REGULAR,
 p_source_code_id    IN  NUMBER := FND_API.G_MISS_NUM,
 p_source_code       IN  VARCHAR2 := FND_API.G_MISS_CHAR,
 p_object_type       IN  VARCHAR2 := FND_API.G_MISS_CHAR,
 p_object_id         IN  NUMBER := FND_API.G_MISS_NUM,
 p_order_id          IN  NUMBER := FND_API.G_MISS_NUM,
 p_doc_id            IN  NUMBER := FND_API.G_MISS_NUM,
 p_doc_ref           IN  VARCHAR2 := FND_API.G_MISS_CHAR,
 p_server_id         IN  NUMBER := FND_API.G_MISS_NUM,
 p_queue_response    IN  VARCHAR2 := 'S',
 p_extended_header   IN  VARCHAR2 := FND_API.G_MISS_CHAR,
 p_content_xml       IN  VARCHAR2,
 p_request_id        IN  NUMBER,
 p_preview           IN  VARCHAR2 := FND_API.G_FALSE
);


---------------------------------------------------------------------
-- PROCEDURE
--    Submit_Request
--
-- PURPOSE
--  This procedure can be used to submit a new request for a single customer
--  to the fulfillment system.
--
-- PARAMETERS
--   p_user_id: Agent/User Id
--   p_party_id: Customer ID
--   p_priority: These are defined as global constants in package JTF_FM_Request_GRP.
--   User Note - Unused priority numbers are for future use.
--   p_source_code_id : Campaign/promotion field
--   p_source_code    : Campaign/promotion field
--   p_object_type    : Campaign/promotion field
--   p_object_id      : Campaign/promotion field
--   p_order_id:  Unique identifier of the order
--   p_server_id: Unique identifier of the sever
--   p_queue_response  : Field to specify if response needs to queued in Response queue
--   p_content_xml    :  The content xml formed by calling the Get_Content_XML
--  or Get_Multiple_Content_XML API's.
--   p_request_id      : Request ID obtained by calling the Start_Request API.

-- NOTES
--  1. The API will generate an XML request and submit it to the Fulfillment
--     Request Queue.
--  2. It also updates/creates fulfillment History and status records.
--  3. Default priority is G_PRIORITY_REGULAR
-------------------------------------------------------------------------

PROCEDURE Submit_Request
( p_api_version      IN  NUMBER,
  p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status    OUT NOCOPY VARCHAR2,
  x_msg_count        OUT NOCOPY NUMBER,
  x_msg_data         OUT NOCOPY VARCHAR2,
  p_template_id      IN  NUMBER := FND_API.G_MISS_NUM,
  p_subject          IN  VARCHAR2 := FND_API.G_MISS_CHAR,
  p_party_id         IN  NUMBER := FND_API.G_MISS_NUM,
  p_party_name       IN  VARCHAR2 := FND_API.G_MISS_CHAR,
  p_user_id          IN  NUMBER,
  p_priority         IN  NUMBER := G_PRIORITY_REGULAR,
  p_source_code_id   IN  NUMBER := FND_API.G_MISS_NUM,
  p_source_code      IN  VARCHAR2 := FND_API.G_MISS_CHAR,
  p_object_type      IN  VARCHAR2 := FND_API.G_MISS_CHAR,
  p_object_id        IN  NUMBER := FND_API.G_MISS_NUM,
  p_order_id         IN  NUMBER := FND_API.G_MISS_NUM,
  p_doc_id           IN  NUMBER := FND_API.G_MISS_NUM,
  p_doc_ref          IN  VARCHAR2 := FND_API.G_MISS_CHAR,
  p_server_id        IN  NUMBER := FND_API.G_MISS_NUM,
  p_queue_response   IN  VARCHAR2 := FND_API.G_FALSE,
  p_extended_header  IN  VARCHAR2 := FND_API.G_MISS_CHAR,
  p_content_xml      IN  VARCHAR2,
  p_request_id       IN  NUMBER
);




PROCEDURE Submit_Previewed_Request(
p_api_version        IN  NUMBER,
p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE,
p_commit             IN  VARCHAR2 := FND_API.G_FALSE,
p_validation_level   IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
x_return_status      OUT NOCOPY VARCHAR2,
x_msg_count          OUT NOCOPY NUMBER,
x_msg_data           OUT NOCOPY VARCHAR2,
p_request_id         IN  NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    Resubmit_Request (overloaded)
--
-- PURPOSE
--    Allows the agent/user to resubmit a fulfillment that is already in the
--  system.
--
-- PARAMETERS
--   p_request_id: System generated fulfillment request id - from the previously
--  created request
--   x_request_id: OUT parameter.  New design, a new reqest id is created for
--   every request submitted
--
-- NOTES
--    1. Currently 1-to-1 fulfillment does not allow modifying a request
--   that was previously submitted and resubmitting it.
--   Signature has been modified to send back a new request id
--     To be consistent with the new schema changes, every req is unique
---------------------------------------------------------------------

PROCEDURE Resubmit_Request(
     p_api_version         IN  NUMBER,
  p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2,
    p_request_id IN  NUMBER,
	x_request_id          OUT NOCOPY NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    Resubmit_Request
--
-- PURPOSE
--    Allows the agent/user to resubmit a fulfillment that is already in the
--  system.
--
-- PARAMETERS
--   p_request_id: System generated fulfillment request id - from the previously
--  created request
--
-- NOTES
--    1. Currently 1-to-1 fulfillment does not allow modifying a request
--   that was previously submitted and resubmitting it.
--   Signature has been modified to send back a new request id
--     To be consistent with the new schema changes, every req is unique
---------------------------------------------------------------------

PROCEDURE Resubmit_Request(
     p_api_version         IN  NUMBER,
  p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2,
    p_request_id IN  NUMBER

);


---------------------------------------------------------------------
-- PROCEDURE
--    Cancel_Request
--
-- PURPOSE
--    Allows the agent/user to cancel a fulfillment that is already in the system.
--
-- PARAMETERS
--   p_request_id: System generated fulfillment request id - from the previously
--  created request
--
-- NOTES
--    1. Only messages that are still in the request queue will be cancelled.
--   Once the fulfillment engine dequeues the message from the request queue,
--   the request cannot be cancelled.
---------------------------------------------------------------------

PROCEDURE Cancel_Request(
     p_api_version         IN  NUMBER,
  p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY  NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2,
    p_request_id IN  NUMBER,
 p_submit_dt_tm IN  DATE := FND_API.G_MISS_DATE
);

---------------------------------------------------------------------
-- PROCEDURE
--    Get_Multiple_Content_XML
--
-- PURPOSE
--    Forms the XML request for multiple contents based on parameters passed and
--  returns the XML as an output parameter.
--
-- PARAMETERS
--    p_content_id: Unique Id of the content. (Required)
--   p_content_nm: The Name of the content.
--   p_quantity: Quantity of the content to be sent (Default = 1) .
--   p_media_type: Type of media - FAX, EMAIL, PRINTER, PATH.
--   p_printer:   Address of the printer
--   p_email:  Email Address
--   p_fax : Fax Address
--   p_file_path : File Path address
--   p_user_note: Any note that the agent wants to attach
--   p_content_type: Type of the content - QUERY, ATTACHMENT or COLLATERAL
--   p_bind_var : The list of bind variables
--   p_bind_var_type: The type of the corresponding bind variables
--   p_bind_val: Actual values of the corresponding bind variables.
--   p_request_id: The request ID obtained by calling the Start_Request API.
--   x_content_xml: Output content XML
--
-- NOTES
--    1. The content_type can be of type COLLATERAL or ATTACHMENT.
--    2. This API currently does not form XML for QUERY or DATA type of requests.
--    3. The Get_Multiple_Content_XML API can handle multiple Contents per call.
--     Again the output content_XML string needs to be appended to the
-- content_xml from the previous calls.
---------------------------------------------------------------------

PROCEDURE Get_Multiple_Content_XML
(
     p_api_version         IN  NUMBER,
  p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2,
 p_request_id IN  NUMBER,
 p_content_type IN  G_VARCHAR_TBL_TYPE := L_VARCHAR_TBL,
 p_content_id IN  G_NUMBER_TBL_TYPE := L_NUMBER_TBL,
 p_content_nm IN  G_VARCHAR_TBL_TYPE := L_VARCHAR_TBL,
 p_document_type IN  G_VARCHAR_TBL_TYPE := L_VARCHAR_TBL, --depreciated
 p_media_type IN  G_VARCHAR_TBL_TYPE := L_VARCHAR_TBL,
 p_printer IN  G_VARCHAR_TBL_TYPE := L_VARCHAR_TBL,
 p_email IN  G_VARCHAR_TBL_TYPE := L_VARCHAR_TBL,
 p_fax IN  G_VARCHAR_TBL_TYPE := L_VARCHAR_TBL,
 p_file_path IN  G_VARCHAR_TBL_TYPE := L_VARCHAR_TBL,
 p_user_note          IN  G_VARCHAR_TBL_TYPE := L_VARCHAR_TBL,
 p_quantity          IN  G_NUMBER_TBL_TYPE := L_NUMBER_TBL,
 x_content_xml OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Submit_Batch_Request (Overloaded - Striped by org_id p_org_id)
--
-- PURPOSE
--    This procedure can be used to submit a new batch request for a multiple
--  customers to the fulfillment system
--
-- PARAMETERS
--   p_user_id: Agent/User Id
--   p_party_id: Customer ID
--   p_priority: These are defined as global constants in package JTF_FM_Request_GRP.
--   User Note - Unused priority numbers are for future use.
--   p_source_code_id : Campaign/promotion field
--   p_source_code    : Campaign/promotion field
--   p_object_type    : Campaign/promotion field
--   p_object_id      : Campaign/promotion field
--   p_order_id   :  Unique identifier of the order
--   p_list_type    : Specifies whether the customer list an their addresses
--       are to be picked up from a view in the database or if
-- the list is passed on the API.
--   p_view_name    : The name of the view in the database.
--   p_party_id       : List of  Customer ID's for the batch request
--   p_email          : The list of email addresses of the customers
--   p_fax            : The list of fax addresses of the customers
--   p_printer        : The list of printer addresses of the customers
--   p_file_path      : The list of file path addresses of the customers
--   p_server_id   : Unique identifier of the sever
--   p_queue_response  : Field to specify if response needs to queued in Response queue
--   p_content_xml    :  The content xml formed by calling the Get_Content_XML
--     or Get_Multiple_Content_XML API's.
--   p_request_id      : Request ID obtained by calling the Start_Request API.
--   p_per_user_history : The value of this parameter determines whether detailed
--     user level history is to be written for the batch request.
--    p_org_id          : Striping by org_id
--
-- NOTES
--    1. The API will generate an XML request and submit it to the Fulfillment
--     Request Queue.
--    2. It also updates/creates fulfillment History and status records.
--  3. The priority for batch request will always be G_PRIORITY_BATCH_REQUEST
---------------------------------------------------------------------

PROCEDURE Submit_Batch_Request
(   p_api_version            IN  NUMBER,
  p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit   IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level      IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status          OUT  NOCOPY VARCHAR2,
      x_msg_count              OUT NOCOPY NUMBER,
      x_msg_data               OUT NOCOPY VARCHAR2,
  p_template_id            IN  NUMBER := NULL,
  p_subject                IN  VARCHAR2 := FND_API.G_MISS_CHAR,
  p_user_id    IN  NUMBER,
  p_source_code_id         IN  NUMBER := FND_API.G_MISS_NUM,
  p_source_code   IN  VARCHAR2 := FND_API.G_MISS_CHAR,
  p_object_type   IN  VARCHAR2 := FND_API.G_MISS_CHAR,
  p_object_id    IN  NUMBER := FND_API.G_MISS_NUM,
  p_order_id   IN  NUMBER := FND_API.G_MISS_NUM,
  p_doc_id   IN  NUMBER := FND_API.G_MISS_NUM,
  p_doc_ref    IN  VARCHAR2 := FND_API.G_MISS_CHAR,
  p_list_type   IN  VARCHAR2,
  p_view_nm   IN  VARCHAR2 := FND_API.G_MISS_CHAR,
  p_party_id     IN  G_NUMBER_TBL_TYPE := L_NUMBER_TBL,
  p_party_name    IN  G_VARCHAR_TBL_TYPE := L_VARCHAR_TBL,
  p_printer    IN  G_VARCHAR_TBL_TYPE := L_VARCHAR_TBL,
  p_email    IN  G_VARCHAR_TBL_TYPE := L_VARCHAR_TBL,
  p_fax    IN  G_VARCHAR_TBL_TYPE := L_VARCHAR_TBL,
  p_file_path    IN  G_VARCHAR_TBL_TYPE := L_VARCHAR_TBL,
  p_server_id   IN  NUMBER := FND_API.G_MISS_NUM,
  p_queue_response   IN  VARCHAR2 := FND_API.G_FALSE,
  p_extended_header   IN  VARCHAR2 := FND_API.G_MISS_CHAR,
  p_content_xml      IN  VARCHAR2,
  p_request_id    IN  NUMBER,
  p_per_user_history       IN  VARCHAR2 := FND_API.G_FALSE
);

---------------------------------------------------------------------------

PROCEDURE Submit_Mass_Request
(    p_api_version        IN  NUMBER,
     p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE,
     p_commit             IN  VARCHAR2 := FND_API.G_FALSE,
     p_validation_level   IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
     x_return_status      OUT NOCOPY VARCHAR2,
     x_msg_count          OUT NOCOPY NUMBER,
     x_msg_data           OUT NOCOPY VARCHAR2,
     p_template_id        IN  NUMBER := NULL,
     p_subject            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
     p_user_id            IN  NUMBER,
     p_source_code_id     IN  NUMBER := FND_API.G_MISS_NUM,
     p_source_code        IN  VARCHAR2 := FND_API.G_MISS_CHAR,
     p_object_type        IN  VARCHAR2 := FND_API.G_MISS_CHAR,
     p_object_id          IN  NUMBER := FND_API.G_MISS_NUM,
     p_order_id           IN  NUMBER := FND_API.G_MISS_NUM,
     p_doc_id             IN  NUMBER := FND_API.G_MISS_NUM,
     p_doc_ref            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
     p_list_type          IN  VARCHAR2,   --deprecated
     p_view_nm            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
     p_server_id          IN  NUMBER := FND_API.G_MISS_NUM,
     p_queue_response     IN  VARCHAR2 := FND_API.G_FALSE,
     p_extended_header    IN  VARCHAR2 := FND_API.G_MISS_CHAR,
     p_content_xml        IN  VARCHAR2,
     p_request_id         IN  NUMBER,
     p_per_user_history   IN  VARCHAR2 := FND_API.G_FALSE,
     p_mass_query_id          IN  NUMBER,       --deprecated
     p_mass_bind_var          IN  JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE := JTF_FM_REQUEST_GRP.L_VARCHAR_TBL,   --deprecated
     p_mass_bind_var_type     IN  JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE := JTF_FM_REQUEST_GRP.L_VARCHAR_TBL,     --deprecated
     p_mass_bind_val          IN  JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE := JTF_FM_REQUEST_GRP.L_VARCHAR_TBL      --deprecated
) ;

---------------------------------------------------------------------------
--What parameters does it need?
-- 1. REQUEST_ID
-- 2. WHAT_TO_DO : EITHER PAUSE OR RESUME
--
--What does it do?
--	Gets all the DISTINCT MESSAGE IDS from STATUS TABLE
-- PUT MESSAGES INTO PAUSE QUEUE.
--	Also Update STATUS for these requests to "PAUSED"
--
--This should be available to public.
-------------------------------------------------------------
PROCEDURE PAUSE_RESUME_REQUEST
(
     p_api_version            IN  NUMBER,
     p_init_msg_list          IN  VARCHAR2,
     p_commit                 IN  VARCHAR2,
     p_validation_level       IN  NUMBER,
     x_return_status          OUT NOCOPY VARCHAR2,
     x_msg_count              OUT NOCOPY NUMBER,
     x_msg_data               OUT NOCOPY VARCHAR2,
     p_request_id             IN  NUMBER,
     p_what_to_do		      IN  VARCHAR
);

---------------------------------------------------------------------------
--What parameters does it need?
-- 1. REQUEST_ID
-- 2. WHAT_TO_DO : EITHER PAUSE OR RESUME
--
--What does it do?
--
--This should be available to public.
-------------------------------------------------------------
PROCEDURE NEW_PAUSE_RESUME_REQUEST --anchaudh added
(
     p_api_version            IN  NUMBER,
     p_init_msg_list          IN  VARCHAR2,
     p_commit                 IN  VARCHAR2,
     p_validation_level       IN  NUMBER,
     x_return_status          OUT NOCOPY VARCHAR2,
     x_msg_count              OUT NOCOPY NUMBER,
     x_msg_data               OUT NOCOPY VARCHAR2,
     p_request_id             IN  NUMBER,
     p_what_to_do	      IN  VARCHAR
);

---------------------------------------------------------------------
-- PROCEDURE
--    New_Cancel_Request
--
-- PURPOSE
--    Allows the agent/user to cancel a fulfillment that is already in the system.
--
-- PARAMETERS
--   p_request_id: System generated fulfillment request id - from the previously
--  created request
--
-- NOTES
--
---------------------------------------------------------------------
PROCEDURE New_Cancel_Request --anchaudh added
(
  p_api_version         IN  NUMBER,
  p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
  p_validation_level    IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY  NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2,
  p_request_id          IN  NUMBER,
  p_submit_dt_tm        IN  DATE := FND_API.G_MISS_DATE
);

------------------------------------------------------------
--Determines which route the request has taken for its processing.
--The NEWROUTE/OLDROUTE
----------------------------------------------------------------
PROCEDURE Determine_Request_Path --anchaudh added
(
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY  NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2,
  x_determined_path     OUT NOCOPY VARCHAR2,
  p_request_id          IN  NUMBER
);

------------------------------------------------------------
--Resubmit Individual Jobs within a Mass Request
-- This API allows the user to resubmit it using a new media
-- The new media type and address can be passed to this api

----------------------------------------------------------------

PROCEDURE RESUBMIT_JOB(
     p_api_version            IN  NUMBER,
     p_init_msg_list          IN  VARCHAR2,
     p_commit                 IN  VARCHAR2,
     p_validation_level       IN  NUMBER,
     x_return_status          OUT NOCOPY  VARCHAR2,
     x_msg_count              OUT NOCOPY  NUMBER,
     x_msg_data               OUT NOCOPY  VARCHAR2,
     p_request_id             IN  NUMBER,
	 p_job_id                 IN  NUMBER,
	 p_media_type             IN  VARCHAR2,
	 p_media_address          IN  VARCHAR2,
	 x_request_id             OUT NOCOPY  NUMBER

);

--------------------------------------------------------
-- API To correct malformed email addresss
-- A list of jobs and corresponding email addresses will be accepted
-- By this API for a given request Id.
-- The list can contain 1 elelent too.
---------------------------------------------------
PROCEDURE CORRECT_MALFORMED
(
   p_api_version            IN  NUMBER,
   p_init_msg_list          IN  VARCHAR2,
   p_commit                 IN  VARCHAR2,
   p_validation_level       IN  NUMBER,
   x_msg_count              OUT NOCOPY  NUMBER,
   x_msg_data               OUT NOCOPY  VARCHAR2,
   p_request_id  IN NUMBER,
   p_job         IN JTF_FM_REQUEST_GRP.G_NUMBER_TBL_TYPE,
   p_corrected_address IN JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE,
   x_return_status OUT NOCOPY VARCHAR2
);

------------------------------------------------------------
-- API To Resubmit Malformed Emails
-- This API will check to see if Malformed Emails have been
-- corrected, if so it will resubmit the request to the
-- corrected address.
--
------------------------------------------------------------

PROCEDURE RESUBMIT_MALFORMED(
   p_api_version            IN  NUMBER,
   p_init_msg_list          IN  VARCHAR2,
   p_commit                 IN  VARCHAR2,
   p_validation_level       IN  NUMBER,
   x_msg_count              OUT NOCOPY  NUMBER,
   x_msg_data               OUT NOCOPY  VARCHAR2,
   p_request_id IN NUMBER,
   x_request_id OUT NOCOPY JTF_FM_REQUEST_GRP.G_NUMBER_TBL_TYPE,
   x_return_status OUT NOCOPY VARCHAR2
   );

-- Utility function to replace XML tags
FUNCTION REPLACE_TAG
(
     p_string         IN  VARCHAR2
)
RETURN VARCHAR2;

END JTF_FM_REQUEST_GRP;






 

/
