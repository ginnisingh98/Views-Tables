--------------------------------------------------------
--  DDL for Package OE_MSG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_MSG_PUB" AUTHID CURRENT_USER AS
/* $Header: OEXUMSGS.pls 120.6.12010000.2 2009/05/21 06:40:54 sgoli ship $ */

--  Global constants used by the Get function/procedure to
--  determine which message to get.

    G_FIRST	    CONSTANT	NUMBER	:=  -1	;
    G_NEXT	    CONSTANT	NUMBER	:=  -2	;
    G_LAST	    CONSTANT	NUMBER	:=  -3	;
    G_PREVIOUS	    CONSTANT	NUMBER	:=  -4	;

--  global that holds the value of the message level profile option.

    G_msg_level_threshold	NUMBER    	:= FND_API.G_MISS_NUM;

--message context record group
TYPE G_MSG_CONTEXT_REC_TYPE IS RECORD
    (ENTITY_CODE       		VARCHAR2(30)
    ,ENTITY_REF       		VARCHAR2(50)
    ,ENTITY_ID         		NUMBER
    ,HEADER_ID         		NUMBER
    ,LINE_ID           		NUMBER
    ,ORDER_SOURCE_ID            NUMBER
    ,ORIG_SYS_DOCUMENT_REF	VARCHAR2(50)
    ,ORIG_SYS_DOCUMENT_LINE_REF	VARCHAR2(50)
    ,ORIG_SYS_SHIPMENT_REF	VARCHAR2(50)
    ,CHANGE_SEQUENCE		VARCHAR2(50)
    ,SOURCE_DOCUMENT_TYPE_ID    NUMBER
    ,SOURCE_DOCUMENT_ID		NUMBER
    ,SOURCE_DOCUMENT_LINE_ID	NUMBER
    ,ATTRIBUTE_CODE       	VARCHAR2(30)
    ,CONSTRAINT_ID		NUMBER
    ,PROCESS_ACTIVITY		NUMBER
    ,ORDER_NUMBER               NUMBER
   );

TYPE Msg_Context_Tbl_Type IS TABLE OF G_MSG_CONTEXT_REC_TYPE
 INDEX BY BINARY_INTEGER;

G_msg_context_tbl                   Msg_Context_Tbl_Type;
G_msg_context_count                 NUMBER          := 0;
G_msg_context_index                 NUMBER          := 0;


-- API message record type
   TYPE G_MSG_REC_TYPE IS RECORD
   ( MESSAGE          		  Varchar2(2000)
    ,ENTITY_CODE       		  VARCHAR2(30)
    ,ENTITY_ID         		  NUMBER
    ,HEADER_ID         		  NUMBER
    ,LINE_ID           		  NUMBER
    ,ORDER_SOURCE_ID              NUMBER
    ,ORIG_SYS_DOCUMENT_REF	  VARCHAR2(50)
    ,ORIG_SYS_DOCUMENT_LINE_REF   VARCHAR2(50)
    ,SOURCE_DOCUMENT_TYPE_ID      NUMBER
    ,SOURCE_DOCUMENT_ID		  NUMBER
    ,SOURCE_DOCUMENT_LINE_ID	  NUMBER
    ,ATTRIBUTE_CODE       	  VARCHAR2(30)
    ,CONSTRAINT_ID		  NUMBER
    ,PROCESS_ACTIVITY		  NUMBER
    ,NOTIFICATION_FLAG            VARCHAR2(1)
    ,MESSAGE_TEXT                 Varchar2(2000)
    ,TYPE                 	  Varchar2(30)
    ,ENTITY_REF       		  VARCHAR2(50)
    ,ORIG_SYS_SHIPMENT_REF   	  VARCHAR2(50)
    ,CHANGE_SEQUENCE   	  	  VARCHAR2(50)
    ,PROCESSED                    VARCHAR2(1)
    ,ORG_ID                       NUMBER
   );


--  API message table type
--
--  	PL/SQL table of VARCHAR2(2000)
--	This is the datatype of the API message list

    TYPE Msg_Tbl_Type IS TABLE OF G_MSG_REC_TYPE
    INDEX BY BINARY_INTEGER;

--  Global message table variable.
--  this variable is global to the OE_MSG_PUB package only.
    G_msg_tbl	    		Msg_Tbl_Type;

--  Global variable holding the message count.
    G_msg_count   		NUMBER      	:= 0;

--  Index used by the Get function to keep track of the last fetched
--  message.
    G_msg_index			NUMBER		:= 0;

--  Global variable holding the process_activity values.
    G_process_activity	        NUMBER          := NULL;

-----------------------------------------------------------------
--  Procedure	Initialize
--
--  Usage	Used by API callers and developers to intialize the
--		global message table.
--  Desc	Clears the G_msg_tbl and resets all its global
--		variables. Except for the message level threshold.
--

PROCEDURE Initialize;

--  FUNCTION	Count_Msg
--
--  Usage	Used by API callers and developers to find the count
--		of messages in the  message list.
--  Desc	Returns the value of G_msg_count
--
--  Parameters	None
--
--  Return	NUMBER

FUNCTION    Count_Msg  RETURN NUMBER;

PROCEDURE Set_Process_Activity(
     p_process_activity             IN NUMBER           DEFAULT NULL);


PROCEDURE Set_Msg_Context (
     p_entity_code       	    IN	VARCHAR2	DEFAULT NULL
    ,p_entity_ref         	    IN	VARCHAR2	DEFAULT NULL
    ,p_entity_id         	    IN	NUMBER		DEFAULT NULL
    ,p_header_id         	    IN	NUMBER		DEFAULT NULL
    ,p_line_id           	    IN	NUMBER		DEFAULT NULL
    ,p_order_source_id              IN  NUMBER          DEFAULT NULL
    ,p_orig_sys_document_ref	    IN	VARCHAR2	DEFAULT NULL
    ,p_orig_sys_document_line_ref   IN	VARCHAR2	DEFAULT NULL
    ,p_orig_sys_shipment_ref   	    IN	VARCHAR2	DEFAULT NULL
    ,p_change_sequence   	    IN	VARCHAR2	DEFAULT NULL
    ,p_source_document_type_id      IN  NUMBER          DEFAULT NULL
    ,p_source_document_id	    IN  NUMBER		DEFAULT NULL
    ,p_source_document_line_id	    IN  NUMBER		DEFAULT NULL
    ,p_attribute_code       	    IN  VARCHAR2	DEFAULT NULL
    ,p_constraint_id		    IN  NUMBER		DEFAULT NULL
--  ,p_process_activity             IN  NUMBER		DEFAULT NULL
 );

PROCEDURE Reset_Msg_Context(p_entity_code IN VARCHAR2);

PROCEDURE Update_Msg_Context (
     p_entity_code       	  IN	VARCHAR2  DEFAULT FND_API.G_MISS_CHAR
    ,p_entity_id         	  IN	NUMBER 	  DEFAULT FND_API.G_MISS_NUM
    ,p_header_id         	  IN	NUMBER	  DEFAULT FND_API.G_MISS_NUM
    ,p_line_id           	  IN	NUMBER	  DEFAULT FND_API.G_MISS_NUM
    ,p_order_source_id            IN    NUMBER    DEFAULT FND_API.G_MISS_NUM
    ,p_orig_sys_document_ref	  IN	VARCHAR2  DEFAULT FND_API.G_MISS_CHAR
    ,p_orig_sys_document_line_ref IN	VARCHAR2  DEFAULT FND_API.G_MISS_CHAR
    ,p_orig_sys_shipment_ref      IN    VARCHAR2  DEFAULT FND_API.G_MISS_CHAR
    ,p_change_sequence            IN	VARCHAR2  DEFAULT FND_API.G_MISS_CHAR
    ,p_source_document_type_id    IN    NUMBER    DEFAULT FND_API.G_MISS_NUM
    ,p_source_document_id	  IN	NUMBER	  DEFAULT FND_API.G_MISS_NUM
    ,p_source_document_line_id	  IN	NUMBER	  DEFAULT FND_API.G_MISS_NUM
    ,p_attribute_code       	  IN	VARCHAR2  DEFAULT FND_API.G_MISS_CHAR
    ,p_constraint_id		  IN	NUMBER	  DEFAULT FND_API.G_MISS_NUM
--    ,p_process_activity		  IN	NUMBER	  DEFAULT FND_API.G_MISS_NUM
  );

procedure get_msg_context(
     p_msg_index 		    IN  NUMBER
,x_entity_code OUT NOCOPY VARCHAR2

,x_entity_ref OUT NOCOPY VARCHAR2

,x_entity_id OUT NOCOPY NUMBER

,x_header_id OUT NOCOPY NUMBER

,x_line_id OUT NOCOPY NUMBER

,x_order_source_id OUT NOCOPY NUMBER

,x_orig_sys_document_ref OUT NOCOPY VARCHAR2

,x_orig_sys_line_ref OUT NOCOPY VARCHAR2

,x_orig_sys_shipment_ref OUT NOCOPY VARCHAR2

,x_change_sequence OUT NOCOPY VARCHAR2

,x_source_document_type_id OUT NOCOPY NUMBER

,x_source_document_id OUT NOCOPY NUMBER

,x_source_document_line_id OUT NOCOPY NUMBER

,x_attribute_code OUT NOCOPY VARCHAR2

,x_constraint_id OUT NOCOPY NUMBER

,x_process_activity OUT NOCOPY NUMBER

,x_notification_flag OUT NOCOPY VARCHAR2

,x_type OUT NOCOPY VARCHAR2

 );

--  PROCEDURE	Count_And_Get
--
--  Usage	Used by API developers to find the count of messages
--		in the message table. If there is only one message in
--		the table it retrieves this message.
--
--  Desc	This procedure is a cover that calls the function
--		Count_Msg and if the count of messages is 1. It calls the
--		procedure Get. It serves as a shortcut for API
--		developers. to make one call instead of making a call
--		to count, a check, and then another call to get.
--
--  Parameters	p_encoded   IN VARCHAR2(1) := FND_API.G_TRUE    Optional
--		    If TRUE the message is returned in an encoded
--		    format, else it is translated and returned.
--		p_count OUT NUMBER
--		    Message count.
--		p_data	    OUT VARCHAR2(2000)
--		    Message data.
--

PROCEDURE    Count_And_Get
(   p_encoded		    IN	VARCHAR2    := FND_API.G_TRUE	    ,
p_count OUT NOCOPY NUMBER ,

p_data OUT NOCOPY VARCHAR2

);


--  PROCEDURE 	Add
--
--  Usage	Used to add messages to the global message table.
--
--  Desc	Reads a message off the message dictionary stack and
--  	    	writes it in an encoded format to the global PL/SQL
--		message table.
--  	    	The message is appended at the bottom of the message
--    	    	table.

PROCEDURE Add(p_context_flag IN VARCHAR2 DEFAULT 'Y');


-- PROCEDURE   Add
--
--  Usage       Used by Devlopers to add messages to Global stack from FND
--              stack .
--
--  Desc        Accepts the  message as input and writes to global_PL/SQL
--              message table.
--              The message is appended at the bottom of the message
--              table.
--
PROCEDURE Add_Text(p_message_text IN VARCHAR2
                  ,p_type IN VARCHAR2 DEFAULT 'ERROR'
                  ,p_context_flag IN VARCHAR2 DEFAULT 'Y');


--  PROCEDURE   Delete_Msg
--
--  Usage       Used to delete a specific message from the message
--              list, or clear the whole message list.
--
--  Desc        If instructed to delete a specific message, the
--              message is removed from the message table and the
--              table is compressed by moving the messages coming
--              after the deleted messages up one entry in the message
--              table.
--              If there is no entry found the Delete procedure does
--              nothing, and  no exception is raised.
--              If delete is passed no parameters it deletes the whole
--              message table.
--
--  Prameters   p_msg_index     IN NUMBER := FND_API.G_MISS_NUM  Optional
--                  holds the index of the message to be deleted.
--

PROCEDURE Delete_Msg
(   p_msg_index IN    NUMBER    :=      NULL
);

--  PROCEDURE   Get
--
--  Usage       Used to get message info from the global message table.
--
--  Desc        Gets the next message from the message table.
--              This procedure utilizes the G_msg_index to keep track
--              of the last message fetched from the global table and
--              then fetches the next.
--
--  Parameters  p_msg_index     IN NUMBER := G_NEXT
--                  Index of message to be fetched. the default is to
--                  fetch the next message starting by the first
--                  message. Possible values are :
--
--                  G_FIRST
--                  G_NEXT
--                  G_LAST
--                  G_PREVIOUS
--                  Specific message index.
--
--              p_encoded   IN VARCHAR2(1) := G_TRUE    Optional
--                  When set to TRUE retieves the message in an
--                  encoded format. If FALSE, the function calls the
--                  message dictionary utilities to translate the
--                  message and do the token substitution, the message
--                  text is then returned.
--
--              p_msg_data          OUT VARCHAR2(2000)
--              p_msg_index_out     OUT NUMBER

PROCEDURE    Get
(   p_msg_index     IN  NUMBER      := G_NEXT           ,
    p_encoded       IN  VARCHAR2    := FND_API.G_TRUE   ,
p_data OUT NOCOPY VARCHAR2 ,

p_msg_index_out OUT NOCOPY NUMBER

);

--  FUNCTION    Get
--
--  Usage       Used to get message info from the message table.
--
--  Desc        Gets the next message from the message table.
--              This procedure utilizes the G_msg_index to keep track
--              of the last message fetched from the table and
--              then fetches the next or previous message depending on
--              the mode the function is being called in..
--
--  Parameters  p_msg_index     IN NUMBER := G_NEXT
--                  Index of message to be fetched. the default is to
--                  fetch the next message starting by the first
--                  message. Possible values are :
--
--                  G_FIRST
--                  G_NEXT
--                  G_LAST
--                  G_PREVIOUS
--                  Specific message index.
--
--              p_encoded   IN VARCHAR2(1) := FND_API.G_TRUE    Optional
--                  When set to TRUE Get retrieves the message in an
--                  encoded format. If FALSE, the function calls the
--                  message dictionary utilities to translate the
--                  message and do the token substitution, the message
--                  text is then returned.
--
--  Return      VARCHAR2(2000) message data.
--              If there are no more messages it returns NULL.
--
--  Notes       The function name Get is overloaded with another
--              procedure Get that performs the exact same function as
--              the function, the only difference is that the
--              procedure returns the message data as well as its
--              index i the message list.

FUNCTION    Get
(   p_msg_index     IN NUMBER   := G_NEXT           ,
    p_encoded       IN VARCHAR2 := FND_API.G_TRUE
)
RETURN VARCHAR2;

PROCEDURE Reset
( p_mode    IN NUMBER := G_FIRST );

--  Pre-defined API message levels
--
--      Valid values for message levels are from 1-50.
--      1 being least severe and 50 highest.
--
--      The pre-defined levels correspond to standard API
--      return status. Debug levels are used to control the amount of
--      debug information a program writes to the PL/SQL message table.

G_MSG_LVL_UNEXP_ERROR   CONSTANT NUMBER := 60;
G_MSG_LVL_ERROR         CONSTANT NUMBER := 50;
G_MSG_LVL_SUCCESS       CONSTANT NUMBER := 40;
G_MSG_LVL_DEBUG_HIGH    CONSTANT NUMBER := 30;
G_MSG_LVL_DEBUG_MEDIUM  CONSTANT NUMBER := 20;
G_MSG_LVL_DEBUG_LOW     CONSTANT NUMBER := 10;

--  FUNCTION    Check_Msg_Level
--
--  Usage       Used by API developers to check if the level of the
--              message they want to write to the message table is
--              higher or equal to the message level threshold or not.
--              If the function returns TRUE the developer should go
--              ahead and write the message to the message table else
--              he/she should skip writing this message.
--  Desc        Accepts a message level as input fetches the value of
--              the message threshold profile option and compares it
--              to the input level.
--  Return      TRUE if the level is equal to or higher than the
--              threshold. Otherwise, it returns FALSE.
--

FUNCTION Check_Msg_Level
(   p_message_level IN NUMBER := G_MSG_LVL_SUCCESS
)
RETURN BOOLEAN;


--  PROCEDURE   Build_Exc_Msg()
--
--  USAGE       Used by APIs to issue a standard message when
--              encountering an unexpected error.
--  Desc        The IN parameters are used as tokens to a standard
--              message 'FND_API_UNEXP_ERROR'.
--  Parameters  p_pkg_name          IN VARCHAR2     Optional
--              p_procedure_name    IN VARCHAR2     Optional
--              p_error_text        IN VARCHAR2(240)    Optional
--                  If p_error_text is missing SQLERRM is used.

PROCEDURE Build_Exc_Msg
(   p_pkg_name          IN VARCHAR2 :=FND_API.G_MISS_CHAR    ,
    p_procedure_name    IN VARCHAR2 :=FND_API.G_MISS_CHAR    ,
    p_error_text        IN VARCHAR2 :=FND_API.G_MISS_CHAR
);


--  PROCEDURE   Add_Exc_Msg()
--
--  USAGE   	Same as Build_Exc_Msg but in addition to constructing
--		the messages the procedure Adds it to the global
--		mesage table.

PROCEDURE Add_Exc_Msg
( p_pkg_name		IN VARCHAR2 :=FND_API.G_MISS_CHAR   ,
  p_procedure_name	IN VARCHAR2 :=FND_API.G_MISS_CHAR   ,
  p_error_text		IN VARCHAR2 :=FND_API.G_MISS_CHAR  ,
  p_context_flag      IN VARCHAR2 DEFAULT  'Y'
);

--  PROCEDURE Dump_Msg and Dump_List are used for debugging purposes.
--

PROCEDURE    Dump_Msg
(   p_msg_index IN NUMBER );

PROCEDURE    Dump_List
(   p_messages	IN BOOLEAN  :=	FALSE );


-- PROCEDURE Save_Messages takes all the messages from the
-- message stack and inserts them into the OE_PROCESSING_MESSAGES table.

PROCEDURE Save_Messages(p_request_id IN NUMBER
                        ,p_message_source_code IN VARCHAR2 DEFAULT 'C');

PROCEDURE Insert_Message
(   p_msg_index	          IN NUMBER,
    p_request_id    IN NUMBER,
    p_message_source_code IN VARCHAR2);


PROCEDURE Get_Msg_tbl(x_msg_tbl IN OUT NOCOPY /* file.sql.39 change */ msg_tbl_type);

PROCEDURE Populate_Msg_tbl(p_msg_tbl IN msg_tbl_type); --Added for bug 4716444

PROCEDURE Save_UI_Messages(p_request_id     IN NUMBER
                           ,p_message_source_code IN VARCHAR2);

PROCEDURE Update_Notification_Flag(p_transaction_id IN NUMBER);

PROCEDURE Update_UI_Notification_Flag(p_msg_ind IN NUMBER);

FUNCTION Get_Single_message
(
x_return_status OUT NOCOPY VARCHAR2

)
RETURN VARCHAR2;

PROCEDURE DELETE_MESSAGE
          (p_message_source_code     IN VARCHAR2   DEFAULT  NULL
          ,p_request_id_from         IN NUMBER     DEFAULT  NULL
          ,p_request_id_to           IN NUMBER     DEFAULT  NULL
          ,p_order_number_from       IN NUMBER     DEFAULT  NULL
          ,p_order_number_to         IN NUMBER     DEFAULT  NULL
          ,p_creation_date_from      IN VARCHAR2   DEFAULT  NULL -- 5121760 Datatype changed from date to varchar2
          ,p_creation_date_to        IN VARCHAR2   DEFAULT  NULL --5121760
          ,p_program_id              IN NUMBER     DEFAULT  NULL
          ,p_process_activity_name   IN VARCHAR2   DEFAULT  NULL
          ,p_order_type_id           IN NUMBER     DEFAULT  NULL
          ,p_attribute_code          IN VARCHAR2   DEFAULT  NULL
          ,p_organization_id         IN NUMBER     DEFAULT  NULL
          ,p_created_by              IN NUMBER     DEFAULT  NULL);

PROCEDURE DELETE_OI_MESSAGE
           (p_request_id                  IN NUMBER     DEFAULT  NULL
           ,p_order_source_id             IN NUMBER     DEFAULT  NULL
           ,p_orig_sys_document_ref       IN VARCHAR2   DEFAULT  NULL
           ,p_change_sequence             IN VARCHAR2   DEFAULT  NULL
           ,p_orig_sys_document_line_ref  IN VARCHAR2   DEFAULT  NULL
           ,p_orig_sys_shipment_ref       IN VARCHAR2   DEFAULT  NULL
           ,p_entity_code                 IN VARCHAR2   DEFAULT  NULL
           ,p_entity_ref                  IN VARCHAR2   DEFAULT  NULL
           ,p_org_id                      IN NUMBER     DEFAULT  NULL);

-- 4171408 - Added parameter p_type.
PROCEDURE Transfer_Msg_Stack
( p_msg_index IN  NUMBER DEFAULT  NULL,
  p_type      IN  VARCHAR2 DEFAULT NULL);

PROCEDURE Save_API_Messages (p_request_id    IN NUMBER DEFAULT  NULL
                            ,p_message_source_code IN VARCHAR2 DEFAULT 'A');

PROCEDURE Update_status_code(
     p_request_id                  IN  NUMBER      DEFAULT NULL
    ,p_org_id                      IN  NUMBER      DEFAULT NULL
    ,p_entity_code                 IN  VARCHAR2    DEFAULT NULL
    ,p_entity_id                   IN  NUMBER      DEFAULT NULL
    ,p_header_id                   IN  NUMBER      DEFAULT NULL
    ,p_line_id                     IN  NUMBER      DEFAULT NULL
    ,p_order_source_id             IN  NUMBER      DEFAULT NULL
    ,p_orig_sys_document_ref       IN  VARCHAR2    DEFAULT NULL
    ,p_orig_sys_document_line_ref  IN  VARCHAR2    DEFAULT NULL
    ,p_orig_sys_shipment_ref       IN  VARCHAR2    DEFAULT NULL
    ,p_change_sequence             IN  VARCHAR2    DEFAULT NULL
    ,p_source_document_type_id     IN  NUMBER      DEFAULT NULL
    ,p_source_document_id          IN  NUMBER      DEFAULT NULL
    ,p_source_document_line_id     IN  NUMBER      DEFAULT NULL
    ,p_attribute_code              IN  VARCHAR2    DEFAULT NULL
    ,p_constraint_id               IN  NUMBER      DEFAULT NULL
    ,p_process_activity            IN  NUMBER      DEFAULT NULL
    ,p_sold_to_org_id              IN  NUMBER      DEFAULT NULL
    ,p_status_code                 IN  Varchar2);

--bug 5007836, Created this overloaded API
FUNCTION save_messages( p_request_id     IN NUMBER
                       ,p_message_source_code IN VARCHAR2 DEFAULT 'A')
RETURN VARCHAR2;

--Bug 8514085 Starts
G_msg_tbl_Copy            Msg_Tbl_Type;
/* This global will indicate that there a timer created in forms to show multiple
messages in one window, instead of one after other. */
G_msg_timer_created       BOOLEAN:=FALSE;
/* This global will indicate that before the multi message timer has been processed, the
message table has been initialzed.*/
G_msg_init_with_timer     BOOLEAN:=FALSE;

PROCEDURE Add_Msgs_To_CopyMsgTbl;
PROCEDURE Add_Msgs_From_CopyMsgTbl;

--Will be used from Forms PLSQL Libraries(PLLs) to set the global G_msg_timer_created.
PROCEDURE Set_Msg_Timer_Created(p_msg_timer_created IN BOOLEAN);

--Will be used by Forms PLSQL Libraries(PLLs) to get the global G_Initialized_with_timer.
FUNCTION Get_Msg_Init_with_timer RETURN BOOLEAN;
--Bug 8514085 Ends

END OE_MSG_PUB ;

/
