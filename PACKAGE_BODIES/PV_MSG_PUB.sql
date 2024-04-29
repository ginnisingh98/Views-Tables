--------------------------------------------------------
--  DDL for Package Body PV_MSG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_MSG_PUB" AS
/* $Header: pvxpmsgb.pls 115.7 2002/12/26 06:11:39 anubhavk ship $ */

--  Constants used as tokens for unexpected error messages.

    G_PKG_NAME	CONSTANT    VARCHAR2(15):=  'PV_MSG_PUB';

--  API message table type
--
--  	PL/SQL table of VARCHAR2(2000)
--	This is the datatype of the API message list

TYPE Msg_Tbl_Type IS TABLE OF VARCHAR2(2000)
 INDEX BY BINARY_INTEGER;

--  Global message table variable.
--  this variable is global to the FND_MSG_PUB package only.

    G_msg_tbl	    		Msg_Tbl_Type;

--  Global variable holding the message count.

    G_msg_count   		NUMBER      	:= 0;

--  Index used by the Get function to keep track of the last fetched
--  message.

    G_msg_index			NUMBER		:= 0;

--  Procedure	Initialize
--
--  Usage	Used by API callers and developers to intialize the
--		global message table.
--  Desc	Clears the G_msg_tbl and resets all its global
--		variables. Except for the message level threshold.
--

PROCEDURE Initialize
IS
BEGIN

G_msg_tbl.DELETE;
G_msg_count := 0;
G_msg_index := 0;

END;

--  FUNCTION	Count_Msg
--
--  Usage	Used by API callers and developers to find the count
--		of messages in the  message list.
--  Desc	Returns the value of G_msg_count
--
--  Parameters	None
--
--  Return	NUMBER

FUNCTION    Count_Msg 	RETURN NUMBER
IS
BEGIN

    RETURN G_msg_Count;

END Count_Msg;

--  PROCEDURE	Count_And_Get
--

PROCEDURE    Count_And_Get
(   p_encoded		    IN	VARCHAR2    := FND_API.G_TRUE	    ,
    p_count		    OUT NOCOPY NUMBER				    ,
    p_data		    OUT NOCOPY VARCHAR2
)
IS
l_msg_count	NUMBER;

BEGIN

    l_msg_count :=  Count_Msg;

    IF l_msg_count > 0 THEN

	FOR I IN 1..G_msg_tbl.COUNT LOOP

          p_data := p_data || ' ' || Get ( p_msg_index =>  I   ,
	                                     p_encoded   =>  p_encoded   );

          if length(p_data) > 1500 then
             exit;
          end if;

	END LOOP;


    END IF;

    p_count := l_msg_count ;

END Count_And_Get;

--  PROCEDURE 	Add
--
--  Usage	Used to add messages to the global message table.
--
--  Desc	Reads a message off the message dictionary stack and
--  	    	writes it in an encoded format to the global PL/SQL
--		message table.
--  	    	The message is appended at the bottom of the message
--    	    	table.
--

PROCEDURE Add
IS
BEGIN

    --	Increment message count

    G_msg_count := G_msg_count + 1;

    --	Write message.

    G_msg_tbl(G_msg_count) := PV_MESSAGE.GET_ENCODED;

END; -- Add

--  PROCEDURE 	Delete_Msg
--
--  Usage	Used to delete a specific message from the message
--		list, or clear the whole message list.
--
--  Desc	If instructed to delete a specific message, the
--		message is removed from the message table and the
--		table is compressed by moving the messages coming
--		after the deleted messages up one entry in the message
--		table.
--		If there is no entry found the Delete procedure does
--		nothing, and  no exception is raised.
--		If delete is passed no parameters it deletes the whole
--		message table.
--
--  Prameters	p_msg_index	IN NUMBER := FND_API.G_MISS_NUM  Optional
--		    holds the index of the message to be deleted.
--

PROCEDURE Delete_Msg
(   p_msg_index IN    NUMBER	:=  NULL
)
IS
l_msg_index	NUMBER;
BEGIN

    IF p_msg_index IS NULL THEN

	--  Delete the whole table.

	G_msg_tbl.DELETE;
	G_msg_count := 0;
	G_msg_index := 0;

    ELSE

	--  Check if entry exists

	IF G_msg_tbl.EXISTS(p_msg_index) THEN

	    IF p_msg_index <= G_msg_count THEN

		--  Move all messages up 1 entry.

		FOR I IN p_msg_index..G_msg_count-1 LOOP

		    G_msg_tbl( I ) := G_msg_tbl( I + 1 );

		END LOOP;

		--  Delete the last message table entry.

		G_msg_tbl.DELETE(G_msg_count)	;
		G_msg_count := G_msg_count - 1	;

	    END IF;

	END IF;

    END IF;

END Delete_Msg;

--  PROCEDURE 	Get
--

PROCEDURE    Get
(   p_msg_index	    IN	NUMBER	    := G_NEXT		,
    p_encoded	    IN	VARCHAR2    := FND_API.G_TRUE	,
    p_data	    OUT NOCOPY VARCHAR2			,
    p_msg_index_out OUT NOCOPY NUMBER
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

	p_data := G_msg_tbl( G_msg_index );

    ELSE

        PV_MESSAGE.SET_ENCODED ( G_msg_tbl( G_msg_index ) );
	p_data := PV_MESSAGE.GET;

    END IF;

    p_msg_index_out	:=  G_msg_index		    ;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

	--  No more messages, revert G_msg_index and return NULL;

	G_msg_index := l_msg_index;

	p_data		:=  NULL;
	p_msg_index_out	:=  NULL;

END Get;

--  FUNCTION	Get
--

FUNCTION    Get
(   p_msg_index	    IN NUMBER	:= G_NEXT	    ,
    p_encoded	    IN VARCHAR2	:= FND_API.G_TRUE
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

--  PROCEDURE	Reset
--
--  Usage	Used to reset the message table index used in reading
--		messages to point to the top of the message table or
--		the botom of the message table.
--
--  Desc	Sets G_msg_index to 0 or G_msg_count+1 depending on
--		the reset mode.
--
--  Parameters	p_mode	IN NUMBER := G_FIRST	Optional
--		    possible values are :
--			G_FIRST	resets index to the begining of msg tbl
--			G_LAST  resets index to the end of msg tbl
--

PROCEDURE Reset ( p_mode    IN NUMBER := G_FIRST )
IS
l_procedure_name    CONSTANT VARCHAR2(15):='Reset';
BEGIN

    IF p_mode = G_FIRST THEN

	G_msg_index := 0;

    ELSIF p_mode = G_LAST THEN

	G_msg_index := G_msg_count + 1 ;

    ELSE

	--  Invalid mode.

	FND_MSG_PUB.Add_Exc_Msg
    	(   p_pkg_name		=>  G_PKG_NAME			,
    	    p_procedure_name	=>  l_procedure_name		,
    	    p_error_text	=>  'Invalid p_mode: '||p_mode
	);

	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

END Reset;

--  FUNCTION 	Check_Msg_Level
--
--  Usage   	Used by API developers to check if the level of the
--  	    	message they want to write to the message table is
--  	    	higher or equal to the message level threshold or not.
--  	    	If the function returns TRUE the developer should go
--  	    	ahead and write the message to the message table else
--  	    	he/she should skip writing this message.
--  Desc    	Accepts a message level as input fetches the value of
--  	    	the message threshold profile option and compares it
--  	    	to the input level.
--  Return  	TRUE if the level is equal to or higher than the
--  	    	threshold. Otherwise, it returns FALSE.
--

FUNCTION Check_Msg_Level
(   p_message_level IN NUMBER := G_MSG_LVL_SUCCESS
) RETURN BOOLEAN
IS
BEGIN

    IF G_msg_level_threshold = FND_API.G_MISS_NUM THEN

    	--  Read the Profile option value.

    	G_msg_level_threshold :=
    	TO_NUMBER ( FND_PROFILE.VALUE('FND_AS_MSG_LEVEL_THRESHOLD') );

    	IF G_msg_level_threshold IS NULL THEN

       	    G_msg_level_threshold := G_MSG_LVL_SUCCESS;

    	END IF;

    END IF;

    RETURN p_message_level >= G_msg_level_threshold ;

END; -- Check_Msg_Level

PROCEDURE Build_Exc_Msg
( p_pkg_name	    IN VARCHAR2 :=FND_API.G_MISS_CHAR    ,
  p_procedure_name  IN VARCHAR2 :=FND_API.G_MISS_CHAR    ,
  p_error_text	    IN VARCHAR2 :=FND_API.G_MISS_CHAR
)
IS
l_error_text	VARCHAR2(240)	:=  p_error_text ;
BEGIN

    -- If p_error_text is missing use SQLERRM.

    IF p_error_text = FND_API.G_MISS_CHAR THEN

	l_error_text := SUBSTR (SQLERRM , 1 , 240);

    END IF;

    PV_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');

    IF p_pkg_name <> FND_API.G_MISS_CHAR THEN
    	PV_MESSAGE.SET_TOKEN('PKG_NAME',p_pkg_name);
    END IF;

    IF p_procedure_name <> FND_API.G_MISS_CHAR THEN
    	PV_MESSAGE.SET_TOKEN('PROCEDURE_NAME',p_procedure_name);
    END IF;

    IF l_error_text <> FND_API.G_MISS_CHAR THEN
    	PV_MESSAGE.SET_TOKEN('ERROR_TEXT',l_error_text);
    END IF;

END; -- Build_Exc_Msg

PROCEDURE Add_Exc_Msg
(   p_pkg_name		IN VARCHAR2 :=FND_API.G_MISS_CHAR   ,
    p_procedure_name	IN VARCHAR2 :=FND_API.G_MISS_CHAR   ,
    p_error_text	IN VARCHAR2 :=FND_API.G_MISS_CHAR
)
IS
BEGIN

    Build_Exc_Msg
    (	p_pkg_name	    ,
	p_procedure_name    ,
	p_error_text
    );

    Add;

END Add_Exc_Msg ;

--  PROCEDURE	Dump_Msg
--

PROCEDURE    Dump_Msg
(   p_msg_index		IN NUMBER )
IS
BEGIN

    null;
    -- dbms_output.put_line('Dumping Message number : '||p_msg_index);

    -- dbms_output.put_line('DATA = '||G_msg_tbl(p_msg_index));

END Dump_Msg;

--  PROCEDURE	Dump_List
--

PROCEDURE    Dump_List
(   p_messages	IN BOOLEAN  :=	FALSE
)
IS
BEGIN

    -- dbms_output.put_line('Dumping Message List :');
    -- dbms_output.put_line('G_msg_tbl.COUNT = '||G_msg_tbl.COUNT);
    -- dbms_output.put_line('G_msg_count = '||G_msg_count);
    -- dbms_output.put_line('G_msg_index = '||G_msg_index);

    IF p_messages THEN

	FOR I IN 1..G_msg_tbl.COUNT LOOP

	    dump_Msg (I);

	END LOOP;

    END IF;

END Dump_List;

END PV_MSG_PUB ;

/
