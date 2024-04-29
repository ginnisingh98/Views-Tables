--------------------------------------------------------
--  DDL for Package Body INV_ITEM_MSG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_ITEM_MSG" AS
/* $Header: INVVIMSB.pls 120.3 2006/05/29 05:40:32 lparihar noship $ */


---------------------- Package variables and constants -----------------------

G_PKG_NAME      CONSTANT  VARCHAR2(30)  :=  'INV_ITEM_MSG';

-- Datatype of the message record and table

TYPE Msg_Rec_type IS RECORD
(
   Msg_Data           VARCHAR2(2000)
,  Msg_Name           VARCHAR2(30)
,  Transaction_Id     NUMBER
,  Column_Name        VARCHAR2(30)
);

TYPE Msg_Tbl_type IS TABLE OF Msg_Rec_type
                     INDEX BY BINARY_INTEGER;

-- Global message table variable

g_Msg_Tbl             Msg_Tbl_type;

-- Global variable holding the message count

g_Msg_Count           NUMBER  :=  0;

-- Index used by the Get function to keep track of the last fetched message

g_Msg_Index           NUMBER  :=  0;

-- Set message level to Error by default
--
g_Message_Level       NUMBER  :=  g_Level_Error;

-- Message mode (output control).
-- Valid values:
--   'FILE'
--   'CP_LOG'
--   'CONSOLE'
--
g_Message_Mode        VARCHAR2(30)  :=  'FILE';

/*
log file
IF (l_debug = 1) THEN
   debug level
END IF;
IF (l_debug = 1) THEN
   trace on/off
END IF;

INV_ITEM_OI_DEBUG_TRACE (yes/no)
INV_ITEM_OI_DEBUG_LEVEL (fatal, error, warning, debug, trace)
*/
------------------------------------------------------------------------------


--------------------------------- Initialize ---------------------------------

-- Usage	Used by INV_ITEM_MSG API callers to intialize the
--		global message table.
-- Desc		Clears the g_Msg_Tbl and resets all its global variables.
--		Except for the message level threshold.

PROCEDURE Initialize
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   g_Msg_Tbl.DELETE;
   g_Msg_Count := 0;
   g_Msg_Index := 0;

END Initialize;

PROCEDURE Initialize_Error_Handler
IS
BEGIN
   Error_Handler.Initialize;
   Error_Handler.Set_BO_Identifier ('INV_ITEM');
END Initialize_Error_Handler;
------------------------------------------------------------------------------


----------------------------- set_Message_Level ------------------------------

PROCEDURE set_Message_Level (p_Msg_Level  IN  NUMBER)
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   g_Message_Level := p_Msg_Level;

END set_Message_Level;
------------------------------------------------------------------------------


------------------------------ set_Message_Mode ------------------------------

FUNCTION set_Message_Mode (p_Mode  IN  VARCHAR2)
RETURN VARCHAR2
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   g_Message_Mode := p_Mode;
   RETURN (NULL);

/*
   IF (p_Mode = 'FILE') THEN
      g_Message_Mode := 'FILE';
      RETURN (NULL);

      IF (G_DIR IS NULL) THEN
         select value
	   INTO G_DIR
	 from v$PARAMETER
         where name = 'utl_file_dir';

	 if instr(G_DIR,',') > 0 then
	    G_DIR := substr(G_DIR,1,instr(G_DIR,',')-1);
	 end if;
      END IF;

      IF (G_FILE IS NULL) THEN
         select substr('l'|| substr(to_char(sysdate,'MI'),1,1)
                || lpad(BIS_debug_s.nextval,6,'0'),1,8) || '.BIS'
           into G_FILE
         from dual;

         G_FILE_PTR := UTL_FILE.fopen(G_DIR, G_FILE, 'w');
      END IF;

      RETURN (G_DIR || '/' || g_file);

   ELSIF (p_Mode = 'CONSOLE') THEN
      g_Message_Mode := 'CONSOLE';
      RETURN (NULL);
   ELSE
      g_Message_Mode := 'TABLE';
      RETURN (NULL);
   END IF;

EXCEPTION

   WHEN others THEN
      g_Message_Mode := 'TABLE';
      RETURN (NULL);
*/

END set_Message_Mode;


PROCEDURE set_Message_Mode (p_Mode  IN  VARCHAR2)
IS
   l_file_ptr    VARCHAR2(2000);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   l_file_ptr := set_Message_Mode (p_Mode  =>  p_Mode);

END set_Message_Mode;


--------------------------- Insert_Interface_Error ---------------------------

-- Private package procedure

PROCEDURE Insert_Interface_Error
(
   p_Msg_Name        IN  VARCHAR2
,  p_Msg_Text        IN  VARCHAR2
,  p_transaction_id  IN  NUMBER
,  p_column_name     IN  VARCHAR2
);
------------------------------------------------------------------------------


-------------------------------- Add_Message ---------------------------------

-- Usage	Used to add messages to the message table.
--
-- Desc		Puts a message and tokens on the message dictionary stack,
--		reads the message off the message dictionary stack, and
--  	    	writes it in an encoded format to the message table.
--  	    	The message is appended at the bottom of the message table.

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
)
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);

BEGIN

   INVPUTLI.info('Add_Message: p_Msg_Name=' || p_Msg_Name);

   --bis_debug_pub.debug_on;
   --BIS_VG_UTIL.Add_Error_Message (...);
   --inv_debug.message(p_Msg_Text);

   FND_MESSAGE.Set_Name('INV', p_Msg_Name);
   IF ( p_token1 <> fnd_api.g_MISS_CHAR ) THEN
      FND_MESSAGE.Set_Token(p_token1, p_value1, FND_API.To_Boolean(p_translate));
   END IF;
   IF ( p_token2 <> fnd_api.g_MISS_CHAR ) THEN
      FND_MESSAGE.Set_Token(p_token2, p_value2, FND_API.To_Boolean(p_translate));
   END IF;
   IF ( p_token3 <> fnd_api.g_MISS_CHAR ) THEN
      FND_MESSAGE.Set_Token(p_token3, p_value3, FND_API.To_Boolean(p_translate));
   END IF;

   -- Increment message count

   g_Msg_Count := g_Msg_Count + 1;

   -- Add message in encoded format to the message table

   g_Msg_Tbl( g_Msg_Count ).Msg_Data       := FND_MESSAGE.Get_Encoded ;
   g_Msg_Tbl( g_Msg_Count ).Msg_Name       := p_Msg_Name ;
   g_Msg_Tbl( g_Msg_Count ).Transaction_Id := p_transaction_id ;
   g_Msg_Tbl( g_Msg_Count ).Column_Name    := p_column_name ;

END Add_Message;
------------------------------------------------------------------------------


---------------------------------- Add_Error ---------------------------------

PROCEDURE Add_Error
(  p_Msg_Name   IN  VARCHAR2
,  p_token      IN  VARCHAR2  DEFAULT  fnd_api.g_MISS_CHAR
,  p_value      IN  VARCHAR2  DEFAULT  fnd_api.g_MISS_CHAR
,  p_translate  IN  VARCHAR2  DEFAULT  fnd_api.g_FALSE
)
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   IF (g_Level_Error >= g_Message_Level) THEN
      Add_Message
      (  p_Msg_Name   =>  p_Msg_Name
      ,  p_token1     =>  p_token
      ,  p_value1     =>  p_value
      ,  p_translate  =>  p_translate
      );
   END IF;

END Add_Error;
------------------------------------------------------------------------------


--------------------------------- Add_Warning --------------------------------

PROCEDURE Add_Warning
(  p_Msg_Name   IN  VARCHAR2
,  p_token      IN  VARCHAR2  DEFAULT  fnd_api.g_MISS_CHAR
,  p_value      IN  VARCHAR2  DEFAULT  fnd_api.g_MISS_CHAR
,  p_translate  IN  VARCHAR2  DEFAULT  fnd_api.g_FALSE
)
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   IF (g_Level_Warning >= g_Message_Level) THEN
      Add_Message
      (  p_Msg_Name   =>  p_Msg_Name
      ,  p_token1     =>  p_token
      ,  p_value1     =>  p_value
      ,  p_translate  =>  p_translate
      );
   END IF;

END Add_Warning;
------------------------------------------------------------------------------


---------------------------- Add_Unexpected_Error ----------------------------

PROCEDURE Add_Unexpected_Error
(  p_Msg_Ctx        IN  INV_ITEM_MSG.Msg_Ctx_type
,  p_Error_Text     IN  VARCHAR2
)
IS
--   l_Error_Text    VARCHAR2(2000);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

/*
   IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.g_MSG_LVL_UNEXP_ERROR) THEN

      FND_MSG_PUB.Add_Exc_Msg
      (  p_pkg_name         =>  G_PKG_NAME
      ,  p_procedure_name   =>  g_api_name
      ,  p_error_text       =>  p_Error_Text
      );
*/
/*
   IF ( Log_Mode = 'CP_LOG' ) THEN
      l_Error_Text := SUBSTRB (p_Error_Text, 1,240);
   ELSE
      l_Error_Text := p_Error_Text;
   END IF;
*/

   IF (g_Level_Unexpected >= g_Message_Level) THEN
      Add_Message
      (  p_Msg_Name    =>  'INV_ITEM_UNEXPECTED_ERROR'
      ,  p_token1      =>  'PKG_NAME'
      ,  p_value1      =>  p_Msg_Ctx.Package_Name
      ,  p_token2      =>  'PROCEDURE_NAME'
      ,  p_value2      =>  p_Msg_Ctx.Procedure_Name
      ,  p_token3      =>  'ERROR_TEXT'
      ,  p_value3      =>  p_Error_Text
      );
   END IF;

END Add_Unexpected_Error;
------------------------------------------------------------------------------


----------------------------------- Debug ------------------------------------

PROCEDURE Debug
(  p_Msg_Ctx        IN  INV_ITEM_MSG.Msg_Ctx_type
,  p_Msg_Text       IN  VARCHAR2
)
IS
--   l_msg_text       VARCHAR2(2000);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

--   l_msg_text := g_Package_Name || '.' || g_Procedure_Name ': ' p_Msg_Text;

   -- Use Add_Message for debugging as well in order to have a consistent way
   -- of getting all messages in encoded format irrespective of the message level.

   IF (g_Level_Statement >= g_Message_Level) THEN
      Add_Message
      (  p_Msg_Name    =>  'INV_API_DEBUG_TEXT'
      ,  p_token1      =>  'PACKAGE_NAME'
      ,  p_value1      =>  p_Msg_Ctx.Package_Name
      ,  p_token2      =>  'PROCEDURE_NAME'
      ,  p_value2      =>  p_Msg_Ctx.Procedure_Name
      ,  p_token3      =>  'TEXT'
      ,  p_value3      =>  p_Msg_Text
      );
   END IF;

END Debug;
------------------------------------------------------------------------------


---------------------------------- Count_Msg ---------------------------------

-- Usage	Used by API callers and developers to find the count
--		of messages in the message list.
--
-- Desc		Returns the value of g_Msg_Count.

FUNCTION Count_Msg
RETURN  NUMBER
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   RETURN g_Msg_Count;

END Count_Msg;


-------------------------------- Count_And_Get -------------------------------

-- Usage	Used by API developers to find the count of messages
--		in the message table. If there is only one message in
--		the table it retrieves this message.

PROCEDURE Count_And_Get
(  p_encoded     IN   VARCHAR2  :=  FND_API.g_TRUE
,  p_count       OUT  NOCOPY NUMBER
,  p_data        OUT  NOCOPY VARCHAR2
)
IS
   l_Msg_Index      NUMBER  :=  g_Msg_Index;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   IF ( g_Msg_Count = 1 ) THEN

      g_Msg_Index := 1;  -- G_FIRST

      IF ( FND_API.To_Boolean( p_encoded ) ) THEN
         p_data := g_Msg_Tbl( g_Msg_Index ).Msg_Data;
      ELSE
         FND_MESSAGE.Set_Encoded ( g_Msg_Tbl( g_Msg_Index ).Msg_Data );
         p_data := FND_MESSAGE.Get;
      END IF;
   ELSE
      p_data := NULL;
   END IF;  -- (g_Msg_Count = 1)

   p_count := g_Msg_Count ;

EXCEPTION

   WHEN no_data_found THEN

      -- Revert g_Msg_Index and return
      g_Msg_Index := l_Msg_Index;

      p_data := NULL;

END Count_And_Get;


-------------------------------- Write_Message -------------------------------

-- Usage	Used to unload a message from the message table.
--

PROCEDURE Write_Message
(  p_msg_index    IN  NUMBER
)
IS
   l_Msg_Index         NUMBER          :=  g_Msg_Index;
   l_Msg_Name          VARCHAR2(30);
   l_msg_text          VARCHAR2(2000);
   l_transaction_id    NUMBER;
   l_column_name       VARCHAR2(30);
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

-- Get message without token substitution
--l_msg_text := FND_MESSAGE.Get_String('INV', 'INV_CAT_SET_CAT_COMB');

   IF ( p_msg_index = G_NEXT ) THEN
      g_Msg_Index := g_Msg_Index + 1;
   ELSIF ( p_msg_index = G_PREVIOUS ) THEN
      g_Msg_Index := g_Msg_Index - 1;
   ELSIF ( p_msg_index = G_FIRST ) THEN
      g_Msg_Index := 1;
   ELSIF ( p_msg_index = G_LAST ) THEN
      g_Msg_Index := g_Msg_Count;
   ELSE
      g_Msg_Index := p_msg_index;
   END IF;

   -- Get translated message text
   BEGIN

      FND_MESSAGE.Set_Encoded( g_Msg_Tbl( g_Msg_Index ).Msg_Data );
      l_msg_text := FND_MESSAGE.Get;

   EXCEPTION
      WHEN no_data_found THEN
         -- No more messages, revert g_Msg_Index and return
         g_Msg_Index := l_Msg_Index;

         --l_msg_text := NULL;
         RETURN;
   END;

   IF (g_Message_Mode = 'CP_LOG') THEN

      -- Write the message into concurrent request log file,
      -- and insert into the interface error table

      FND_FILE.Put_Line (FND_FILE.Log, SUBSTRB(l_msg_text, 1,240));

      l_Msg_Name       := g_Msg_Tbl( g_Msg_Index ).Msg_Name ;
      l_transaction_id := g_Msg_Tbl( g_Msg_Index ).Transaction_Id ;

      IF ( l_transaction_id = fnd_api.g_MISS_NUM ) THEN
         l_transaction_id := NULL;
      END IF;

      l_column_name := g_Msg_Tbl( g_Msg_Index ).Column_Name ;

      Insert_Interface_Error
      (
         p_Msg_Name        =>  l_Msg_Name
      ,  p_Msg_Text        =>  l_msg_text
      ,  p_transaction_id  =>  l_transaction_id
      ,  p_column_name     =>  l_column_name
      );

   ELSIF (g_Message_Mode = 'FILE') THEN
   -- Write the message into concurrent request log file,
      FND_FILE.Put_Line (FND_FILE.Log, SUBSTRB(l_msg_text, 1,240));
   ELSIF (g_Message_Mode = 'PLM_LOG') THEN

      -- Write into Error handler.
      Error_Handler.Add_Error_Message
        (p_message_text  => l_msg_text
	,p_message_type  =>  'E');

   ELSIF (g_Message_Mode = 'CONSOLE') THEN
      null;
      --DBMS_OUTPUT.put_line ( SUBSTRB( REPLACE(l_msg_text, chr(0), ' '), 1,250) );

--Bug: 2451359 Added the PLSQL message_mode.
   ELSIF (g_Message_Mode = 'PLSQL') THEN
      FND_MESSAGE.Set_Encoded( g_Msg_Tbl( g_Msg_Index ).Msg_Data );
      FND_MSG_PUB.Add;

   END IF;  -- g_Message_Mode

/* to get message text
   l_msg_text := FND_MSG_PUB.Get (  p_msg_index  =>  FND_MSG_PUB.g_LAST
                                 ,  p_encoded    =>  FND_API.g_FALSE
                                 );

   -- Reset current message index value back to 0
   FND_MSG_PUB.Reset (FND_MSG_PUB.g_FIRST);
*/

END Write_Message;


--------------------------------- Write_List ---------------------------------

-- Usage      Used to write all messages from the message table.
--

PROCEDURE Write_List
(  p_delete    IN  BOOLEAN  DEFAULT  TRUE
)
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   FOR i IN 1 .. g_Msg_Count LOOP  -- g_Msg_Tbl.COUNT
      Write_Message (i);
   END LOOP;

   -- Clear the message table and reset its global variables

   IF ( p_delete ) THEN
      Initialize;
   END IF;

END Write_List;


--------------------------- Insert_Interface_Error ---------------------------

PROCEDURE Insert_Interface_Error
(
   p_Msg_Name        IN  VARCHAR2
,  p_Msg_Text        IN  VARCHAR2
,  p_transaction_id  IN  NUMBER
,  p_column_name     IN  VARCHAR2
)
IS
   l_Msg_Name       VARCHAR2(30)   :=  SUBSTRB(p_Msg_Name, 1,30);
   l_Msg_Text       VARCHAR2(240)  :=  SUBSTRB(p_Msg_Text, 1,240);
   l_Sysdate        DATE           :=  SYSDATE;
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN

   INSERT INTO mtl_interface_errors
   (
      TRANSACTION_ID
   ,  UNIQUE_ID
   ,  ORGANIZATION_ID
   ,  TABLE_NAME
   ,  COLUMN_NAME
   ,  MESSAGE_NAME
   ,  ERROR_MESSAGE
   ,  CREATION_DATE
   ,  CREATED_BY
   ,  LAST_UPDATE_DATE
   ,  LAST_UPDATED_BY
   ,  LAST_UPDATE_LOGIN
   ,  PROGRAM_APPLICATION_ID
   ,  PROGRAM_ID
   ,  REQUEST_ID
   ,  PROGRAM_UPDATE_DATE
   )
   VALUES
   (
      p_transaction_id
   ,  mtl_system_items_interface_s.NEXTVAL
   ,  g_Organization_Id
   ,  g_Table_Name
   ,  p_column_name
   ,  l_Msg_Name
   ,  l_Msg_Text
   ,  l_Sysdate
   ,  g_User_id
   ,  l_Sysdate
   ,  g_User_id
   ,  g_Login_id
   ,  g_Prog_appid
   ,  g_Prog_id
   ,  g_Request_id
   ,  l_Sysdate
   );

EXCEPTION

   WHEN others THEN
      FND_FILE.Put_Line( FND_FILE.Log, SUBSTRB('Unexpected error in INV_ITEM_MSG.Insert_Interface_Error: ' || SQLERRM, 1,240) );

END Insert_Interface_Error;
------------------------------------------------------------------------------

--  PROCEDURE 	Get
--

PROCEDURE    Get
(   p_msg_index	    IN	NUMBER	    := G_NEXT		,
    p_encoded	    IN	VARCHAR2    := 'T'	,
    p_data	    OUT	NOCOPY VARCHAR2			,
    p_msg_index_out OUT	NOCOPY NUMBER
)
IS
l_msg_index NUMBER := G_msg_index;
BEGIN

    IF p_msg_index = G_NEXT THEN
	G_msg_index := G_msg_index + 1;
    ELSIF p_msg_index = G_FIRST THEN
	G_msg_index := 1;
    ELSIF p_msg_index = G_PREVIOUS THEN
	G_msg_index := G_msg_index - 1;
    ELSIF p_msg_index = G_LAST THEN
	G_msg_index := G_msg_count ;
    ELSE
	G_msg_index := p_msg_index ;
    END IF;


    IF FND_API.To_Boolean( p_encoded ) THEN
       FND_MESSAGE.Set_Encoded( g_Msg_Tbl( g_Msg_Index ).Msg_Data );
       p_data := FND_MESSAGE.Get;
    END IF;

    p_msg_index_out	:=  G_msg_index;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

	--  No more messages, revert G_msg_index and return NULL;

	G_msg_index := l_msg_index;

	p_data		:=  NULL;
	p_msg_index_out	:=  NULL;

END Get;

------------------------------------------------------------------------------
--  FUNCTION	Get
--

FUNCTION    Get
(   p_msg_index	    IN NUMBER	:= G_NEXT	    ,
    p_encoded	    IN VARCHAR2	:= 'T'
)
RETURN VARCHAR2
IS
    l_data	    VARCHAR2(2000)  ;
    l_msg_index_out NUMBER	    ;
BEGIN

    Get
    (	p_msg_index	    ,
	p_encoded	    ,
	l_data		    ,
	l_msg_index_out
    );

    RETURN l_data ;

END Get;
------------------------------------------------------------------------------

END INV_ITEM_MSG;

/
