--------------------------------------------------------
--  DDL for Package INV_ITEM_MSG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_ITEM_MSG" AUTHID CURRENT_USER AS
/* $Header: INVVIMSS.pls 120.1 2006/05/25 10:44:09 lparihar noship $ */


----------------------- Global variables and constants -----------------------

g_MISS_CHAR    CONSTANT  VARCHAR2(1)  :=  fnd_api.g_MISS_CHAR;
g_MISS_NUM     CONSTANT  NUMBER       :=  fnd_api.g_MISS_NUM;
g_MISS_DATE    CONSTANT  DATE         :=  fnd_api.g_MISS_DATE;
g_YES          CONSTANT  VARCHAR2(1)  :=  'Y';
g_NO           CONSTANT  VARCHAR2(1)  :=  'N';

-- Global constants used by the Write_Message procedure to
-- determine which message to write.

G_FIRST        CONSTANT  NUMBER  :=  -1 ;
G_NEXT         CONSTANT  NUMBER  :=  -2 ;
G_LAST         CONSTANT  NUMBER  :=  -3 ;
G_PREVIOUS     CONSTANT  NUMBER  :=  -4 ;

-- Message/debug level

g_Level_Unexpected  CONSTANT  NUMBER  :=  6;  -- Message level Unexpected Error
g_Level_Error       CONSTANT  NUMBER  :=  5;  -- Message level Error
g_Level_Warning     CONSTANT  NUMBER  :=  4;  -- Message level Warning
g_Level_Event       CONSTANT  NUMBER  :=  3;  -- Message level Debug Event
g_Level_Procedure   CONSTANT  NUMBER  :=  2;  -- Message level Debug Procedure
g_Level_Statement   CONSTANT  NUMBER  :=  1;  -- Message level Debug Statement


-- Globals to store data for logging interface errors

g_Organization_Id    NUMBER        :=  NULL;
g_Table_Name         VARCHAR2(30)  :=  NULL;

g_User_id            NUMBER  :=  -1;
g_Login_id           NUMBER  :=  -1;
g_Prog_appid         NUMBER  :=  -1;
g_Prog_id            NUMBER  :=  -1;
g_Request_id         NUMBER  :=  -1;


-------------------------- Global type declarations --------------------------

-- Message context type for debug messages

TYPE Msg_Ctx_type IS RECORD
(
   Package_Name       VARCHAR2(30)  :=  NULL
,  Procedure_Name     VARCHAR2(30)  :=  NULL
);

------------------------------------------------------------------------------


--------------------------------- Initialize ---------------------------------

PROCEDURE Initialize;

PROCEDURE Initialize_Error_Handler;

----------------------------- set_Message_Level ------------------------------

PROCEDURE set_Message_Level (p_Msg_Level  IN  NUMBER);


------------------------------ set_Message_Mode ------------------------------

FUNCTION set_Message_Mode (p_Mode  IN  VARCHAR2)
RETURN VARCHAR2;

PROCEDURE set_Message_Mode (p_Mode  IN  VARCHAR2);


-------------------------------- Add_Message ---------------------------------

PROCEDURE Add_Message
(  p_Msg_Name        IN  VARCHAR2
,  p_token1          IN  VARCHAR2  DEFAULT  fnd_api.g_MISS_CHAR
,  p_value1          IN  VARCHAR2  DEFAULT  fnd_api.g_MISS_CHAR
,  p_token2          IN  VARCHAR2  DEFAULT  fnd_api.g_MISS_CHAR
,  p_value2          IN  VARCHAR2  DEFAULT  fnd_api.g_MISS_CHAR
,  p_token3          IN  VARCHAR2  DEFAULT  fnd_api.g_MISS_CHAR
,  p_value3          IN  VARCHAR2  DEFAULT  fnd_api.g_MISS_CHAR
,  p_translate       IN  VARCHAR2  DEFAULT  fnd_api.g_FALSE
,  p_transaction_id  IN  NUMBER    DEFAULT  fnd_api.g_MISS_NUM
,  p_column_name     IN  VARCHAR2  DEFAULT  NULL
);


---------------------------------- Add_Error ---------------------------------

PROCEDURE Add_Error
(  p_Msg_Name   IN  VARCHAR2
,  p_token      IN  VARCHAR2  DEFAULT  fnd_api.g_MISS_CHAR
,  p_value      IN  VARCHAR2  DEFAULT  fnd_api.g_MISS_CHAR
,  p_translate  IN  VARCHAR2  DEFAULT  fnd_api.g_FALSE
);


--------------------------------- Add_Warning --------------------------------

PROCEDURE Add_Warning
(  p_Msg_Name   IN  VARCHAR2
,  p_token      IN  VARCHAR2  DEFAULT  fnd_api.g_MISS_CHAR
,  p_value      IN  VARCHAR2  DEFAULT  fnd_api.g_MISS_CHAR
,  p_translate  IN  VARCHAR2  DEFAULT  fnd_api.g_FALSE
);


---------------------------- Add_Unexpected_Error ----------------------------

PROCEDURE Add_Unexpected_Error
(  p_Msg_Ctx        IN  INV_ITEM_MSG.Msg_Ctx_type
,  p_Error_Text     IN  VARCHAR2
);


----------------------------------- Debug ------------------------------------

PROCEDURE Debug
(  p_Msg_Ctx        IN  INV_ITEM_MSG.Msg_Ctx_type
,  p_Msg_Text       IN  VARCHAR2
);


---------------------------------- Count_Msg ---------------------------------

FUNCTION Count_Msg
RETURN  NUMBER;


-------------------------------- Count_And_Get -------------------------------

PROCEDURE Count_And_Get
(  p_encoded     IN   VARCHAR2  :=  FND_API.g_TRUE
,  p_count       OUT  NOCOPY NUMBER
,  p_data        OUT  NOCOPY VARCHAR2
);


-------------------------------- Write_Message -------------------------------

-- Usage	Used to unload a message from the INV_ITEM_MSG message table.

PROCEDURE Write_Message
(  p_msg_index    IN  NUMBER
);


--------------------------------- Write_List ---------------------------------

-- Usage      Used to unload all messages from the INV_ITEM_MSG message table.

PROCEDURE Write_List
(  p_delete    IN  BOOLEAN  DEFAULT  TRUE
);

--  PROCEDURE 	Get
--
--  Usage	Used to get message info from the global message table.
--
--  Desc	Gets the next message from the message table.
--		This procedure utilizes the G_msg_index to keep track
--		of the last message fetched from the global table and
--		then fetches the next.
--
--  Parameters	p_msg_index	IN NUMBER := G_NEXT
--		    Index of message to be fetched. the default is to
--		    fetch the next message starting by the first
--		    message. Possible values are :
--
--		    G_FIRST
--		    G_NEXT
--		    G_LAST
--		    G_PREVIOUS
--		    Specific message index.
--
--		p_encoded   IN VARCHAR2(1) := G_TRUE	Optional
--		    When set to TRUE retieves the message in an
--		    encoded format. If FALSE, the function calls the
--		    message dictionary utilities to translate the
--		    message and do the token substitution, the message
--		    text is then returned.
--
--		p_msg_data	    OUT	VARCHAR2(2000)
--		p_msg_index_out	    OUT NUMBER

PROCEDURE    Get
(   p_msg_index	    IN	NUMBER	    := G_NEXT		,
    p_encoded	    IN	VARCHAR2    := 'T'              ,
    p_data	    OUT	NOCOPY VARCHAR2			,
    p_msg_index_out OUT	NOCOPY NUMBER
);

--  FUNCTION	Get
--
--  Usage	Used to get message info from the message table.
--
--  Desc	Gets the next message from the message table.
--		This procedure utilizes the G_msg_index to keep track
--		of the last message fetched from the table and
--		then fetches the next or previous message depending on
--		the mode the function is being called in..
--
--  Parameters	p_msg_index	IN NUMBER := G_NEXT
--		    Index of message to be fetched. the default is to
--		    fetch the next message starting by the first
--		    message. Possible values are :
--
--		    G_FIRST
--		    G_NEXT
--		    G_LAST
--		    G_PREVIOUS
--		    Specific message index.
--
--		p_encoded   IN VARCHAR2(1) := 'T'	Optional
--		    When set to TRUE Get retrieves the message in an
--		    encoded format. If FALSE, the function calls the
--		    message dictionary utilities to translate the
--		    message and do the token substitution, the message
--		    text is then returned.
--
--  Return	VARCHAR2(2000) message data.
--		If there are no more messages it returns NULL.
--
--  Notes	The function name Get is overloaded with another
--		procedure Get that performs the exact same function as
--		the function, the only difference is that the
--		procedure returns the message data as well as its
--		index i the message list.

FUNCTION    Get
(   p_msg_index	    IN NUMBER	:= G_NEXT	    ,
    p_encoded	    IN VARCHAR2 := 'T'
)
RETURN VARCHAR2;


END INV_ITEM_MSG;

 

/
