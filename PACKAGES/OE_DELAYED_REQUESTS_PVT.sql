--------------------------------------------------------
--  DDL for Package OE_DELAYED_REQUESTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_DELAYED_REQUESTS_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVREQS.pls 120.0.12010000.1 2008/07/25 08:06:59 appldev ship $ */

-- Log_Request will search if the request already exists based on the
-- combined key
-- entity_code, entity_id, and request_type and request_unique_key1-5.
-- The request is updated with
-- new values if the request exists else a new request is added to the
-- queue parameters.
/* Use this function to search if a request exists based on a key
   entity_code, entity_id, request_type.
   Parameters
   IN    p_entity_code
         p_entity_id
         p_request_type
         p_request_unique_key1
	 p_request_unique_key2
	 p_request_unique_key3
	 p_request_unique_key4
	 p_request_unique_key5
*/

g_delayed_requests		OE_Order_PUB.Request_Tbl_Type;

TYPE Entity_Id_Rec_Type IS RECORD
(    request_ind    NUMBER := FND_API.G_MISS_NUM
,    entity_id      NUMBER := FND_API.G_MISS_NUM
);

TYPE Entity_Id_Tbl_Type IS TABLE OF Entity_Id_Rec_Type
  INDEX BY BINARY_INTEGER;

Procedure Log_Request
(   p_entity_code	IN VARCHAR2
,   p_entity_id		IN NUMBER
,   p_requesting_entity_code 	IN VARCHAR2
,   p_requesting_entity_id	IN NUMBER
,   p_request_type	IN VARCHAR2
,   p_request_unique_key1	IN VARCHAR2 := NULL
,   p_request_unique_key2	IN VARCHAR2 := NULL
,   p_request_unique_key3	IN VARCHAR2 := NULL
,   p_request_unique_key4	IN VARCHAR2 := NULL
,   p_request_unique_key5	IN VARCHAR2 := NULL
,   p_param1		IN VARCHAR2 := NULL
,   p_param2		IN VARCHAR2 := NULL
,   p_param3		IN VARCHAR2 := NULL
,   p_param4		IN VARCHAR2 := NULL
,   p_param5		IN VARCHAR2 := NULL
,   p_param6		IN VARCHAR2 := NULL
,   p_param7		IN VARCHAR2 := NULL
,   p_param8		IN VARCHAR2 := NULL
,   p_param9		IN VARCHAR2 := NULL
,   p_param10		IN VARCHAR2 := NULL
,   p_param11		IN VARCHAR2 := NULL
,   p_param12		IN VARCHAR2 := NULL
,   p_param13		IN VARCHAR2 := NULL
,   p_param14 		IN VARCHAR2 := NULL
,   p_param15		IN VARCHAR2 := NULL
,   p_param16		IN VARCHAR2 := NULL
,   p_param17		IN VARCHAR2 := NULL
,   p_param18		IN VARCHAR2 := NULL
,   p_param19		IN VARCHAR2 := NULL
,   p_param20		IN VARCHAR2 := NULL
,   p_param21		IN VARCHAR2 := NULL
,   p_param22		IN VARCHAR2 := NULL
,   p_param23		IN VARCHAR2 := NULL
,   p_param24		IN VARCHAR2 := NULL
,   p_param25		IN VARCHAR2 := NULL
,   p_date_param1   IN DATE := NULL
,   p_date_param2   IN DATE := NULL
,   p_date_param3   IN DATE := NULL
,   p_date_param4   IN DATE := NULL
,   p_date_param5   IN DATE := NULL
,   p_date_param6   IN DATE := NULL
,   p_date_param7   IN DATE := NULL
,   p_date_param8   IN DATE := NULL
,   p_long_param1	IN VARCHAR2 := NULL
, x_return_status OUT NOCOPY VARCHAR2

);

Function Check_for_Request
(   p_entity_code   IN VARCHAR2
,   p_entity_id     IN NUMBER
,   p_request_type  IN VARCHAR2
,   p_request_unique_key1	IN VARCHAR2 := NULL
,   p_request_unique_key2	IN VARCHAR2 := NULL
,   p_request_unique_key3	IN VARCHAR2 := NULL
,   p_request_unique_key4	IN VARCHAR2 := NULL
,   p_request_unique_key5	IN VARCHAR2 := NULL
)
RETURN BOOLEAN;

FUNCTION Requests_Count
RETURN NUMBER;

/* Use this procedure to delete a request based on key
   entity_code, entity_id, request_type. The procedure does not do
   anything if the request does not exist.
   Parameters
   IN    p_entity_code
         p_entity_id
         p_request_type
         p_request_unique_key1
	 p_request_unique_key2
	 p_request_unique_key3
	 p_request_unique_key4
	 p_request_unique_key5
out nocopy x_return_status

*/
Procedure Delete_Request
(   p_entity_code	IN Varchar2
,   p_entity_id       in Number
,   p_request_Type    in Varchar2
,   p_request_unique_key1	IN VARCHAR2 := NULL
,   p_request_unique_key2	IN VARCHAR2 := NULL
,   p_request_unique_key3	IN VARCHAR2 := NULL
,   p_request_unique_key4	IN VARCHAR2 := NULL
,   p_request_unique_key5	IN VARCHAR2 := NULL
, x_return_status OUT NOCOPY Varchar2);


/* Use this procedure to clear all request in OE_Delayed_Requests
   Parameters
out nocopy x_return_status

*/
Procedure Clear_Request( x_return_status OUT NOCOPY VARCHAR2);


/* Use this procedure to process a request based on key
   entity_code, entity_id, request_type and request_unique_key1-5.
   The procedure does not do
   anything if the request does not exists. It will delete a request
   if parameter p_delete is set to FND_API.G_TRUE
   Parameters
   IN    p_entity_code
         p_entity_id
         p_request_type
         p_request_unique_key1
	 p_request_unique_key2
	 p_request_unique_key3
	 p_request_unique_key4
	 p_request_unique_key5
         p_delete
out nocopy x_return_status

*/
Procedure Process_Request( p_entity_code     in Varchar2
                        ,p_entity_id         in Number
                        ,p_request_Type      in Varchar2
                        ,p_request_unique_key1	IN VARCHAR2 := NULL
			,p_request_unique_key2	IN VARCHAR2 := NULL
			,p_request_unique_key3	IN VARCHAR2 := NULL
			,p_request_unique_key4	IN VARCHAR2 := NULL
			,p_request_unique_key5	IN VARCHAR2 := NULL
                        ,p_delete            in Varchar2 Default FND_API.G_TRUE
,x_return_status OUT NOCOPY Varchar2);


/* Use this procedure to process a request for a entity
   The procedure does not do anything if the request does not exists.
   It will delete a request if parameter p_delete is set to FND_API.G_TRUE
   Parameters
   IN    p_entity_code
   IN    p_delete
out nocopy x_return_status

*/
Procedure Process_Request_for_Entity
(   p_entity_code     in Varchar2
,   p_delete            in Varchar2 Default FND_API.G_TRUE
, x_return_status OUT NOCOPY Varchar2);


/* Use this procedure to process a request for a given request type
   The procedure does not do anything if the request does not exist.
   It will delete a request if parameter p_delete is set to FND_API.G_TRUE
   Parameters
   IN    p_request_type
   IN    p_delete
out nocopy x_return_status

*/
Procedure Process_Request_for_ReqType
(   p_request_type in Varchar2
,   p_delete         in Varchar2 Default FND_API.G_TRUE
, x_return_status OUT NOCOPY Varchar2

);

/* Use this procedure to process all requests in OE_Delayed_Requests
   The procedure does not do anything if the request does not exist.
   It will clear all the requests at the end.
   Parameters
out nocopy x_return_status

*/
Procedure Process_Delayed_Requests
( x_return_status OUT NOCOPY VARCHAR2

);


PROCEDURE Process_Order_Actions
(   p_validation_level		IN  NUMBER := FND_API.G_VALID_LEVEL_FULL
,   p_x_request_tbl		IN OUT NOCOPY /* file.sql.39 change */  OE_Order_PUB.request_tbl_type
,   p_process_WF_requests IN BOOLEAN := TRUE
 );

/* Use this procedure to delete all requests when an entity is deleted.
   IN    p_entity_code
         p_entity_id
out nocopy x_return_status

*/
-- Bug 3800577
-- Make p_entity_id an optional parameter so if it is null, delete
-- all requests for that entity code
Procedure Delete_Reqs_for_Deleted_Entity
(   p_entity_code	IN Varchar2
,   p_delete_against    IN BOOLEAN := TRUE
,   p_entity_id       in Number := NULL
, x_return_status OUT NOCOPY Varchar2);



End OE_Delayed_Requests_PVT;

/
