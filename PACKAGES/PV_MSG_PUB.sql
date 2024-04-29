--------------------------------------------------------
--  DDL for Package PV_MSG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_MSG_PUB" AUTHID CURRENT_USER AS
/* $Header: pvxpmsgs.pls 115.6 2002/12/26 06:11:24 anubhavk ship $ */

--  Global constants used by the Get function/procedure to
--  determine which message to get.

    G_FIRST	    CONSTANT	NUMBER	:=  -1	;
    G_NEXT	    CONSTANT	NUMBER	:=  -2	;
    G_LAST	    CONSTANT	NUMBER	:=  -3	;
    G_PREVIOUS	    CONSTANT	NUMBER	:=  -4	;

--  global that holds the value of the message level profile option.

    G_msg_level_threshold	NUMBER    	:= FND_API.G_MISS_NUM;

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
    p_count		    OUT NOCOPY NUMBER				    ,
    p_data		    OUT NOCOPY VARCHAR2
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
--

PROCEDURE Add;

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
(   p_msg_index IN    NUMBER	:=	NULL
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
    p_encoded	    IN	VARCHAR2    := FND_API.G_TRUE	,
    p_data	    OUT NOCOPY VARCHAR2			,
    p_msg_index_out OUT NOCOPY NUMBER
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
--		p_encoded   IN VARCHAR2(1) := FND_API.G_TRUE	Optional
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
    p_encoded	    IN VARCHAR2 := FND_API.G_TRUE
)
RETURN VARCHAR2;

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
--  Exceptions	FND_API.G_EXC_UNEXPECTED_ERROR if it is passed an
--		invalid mode.

PROCEDURE Reset
( p_mode    IN NUMBER := G_FIRST );

--  Pre-defined API message levels
--
--  	Valid values for message levels are from 1-50.
--  	1 being least severe and 50 highest.
--
--  	The pre-defined levels correspond to standard API
--  	return status. Debug levels are used to control the amount of
--	debug information a program writes to the PL/SQL message table.

G_MSG_LVL_UNEXP_ERROR	CONSTANT NUMBER	:= 60;
G_MSG_LVL_ERROR	    	CONSTANT NUMBER	:= 50;
G_MSG_LVL_SUCCESS    	CONSTANT NUMBER	:= 40;
G_MSG_LVL_DEBUG_HIGH   	CONSTANT NUMBER	:= 30;
G_MSG_LVL_DEBUG_MEDIUM 	CONSTANT NUMBER	:= 20;
G_MSG_LVL_DEBUG_LOW   	CONSTANT NUMBER	:= 10;

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
)
RETURN BOOLEAN;

--  PROCEDURE	Build_Exc_Msg()
--
--  USAGE   	Used by APIs to issue a standard message when
--		encountering an unexpected error.
--  Desc    	The IN parameters are used as tokens to a standard
--		message 'FND_API_UNEXP_ERROR'.
--  Parameters	p_pkg_name  	    IN VARCHAR2(30)	Optional
--  	    	p_procedure_name    IN VARCHAR2(30)	Optional
--  	    	p_error_text  	    IN VARCHAR2(240)	Optional
--		    If p_error_text is missing SQLERRM is used.

PROCEDURE Build_Exc_Msg
(   p_pkg_name		IN VARCHAR2 :=FND_API.G_MISS_CHAR    ,
    p_procedure_name	IN VARCHAR2 :=FND_API.G_MISS_CHAR    ,
    p_error_text	IN VARCHAR2 :=FND_API.G_MISS_CHAR
);

--  PROCEDURE	Add_Exc_Msg()
--
--  USAGE   	Same as Build_Exc_Msg but in addition to constructing
--		the messages the procedure Adds it to the global
--		mesage table.

PROCEDURE Add_Exc_Msg
( p_pkg_name		IN VARCHAR2 :=FND_API.G_MISS_CHAR   ,
  p_procedure_name	IN VARCHAR2 :=FND_API.G_MISS_CHAR   ,
  p_error_text		IN VARCHAR2 :=FND_API.G_MISS_CHAR
);

--  PROCEDURE Dump_Msg and Dump_List are used for debugging purposes.
--

PROCEDURE    Dump_Msg
(   p_msg_index IN NUMBER );

PROCEDURE    Dump_List
(   p_messages	IN BOOLEAN  :=	FALSE );

END PV_MSG_PUB ;

 

/
