--------------------------------------------------------
--  DDL for Package CLN_DEBUG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CLN_DEBUG_PUB" AUTHID CURRENT_USER AS
/* $Header: CLNDBGS.pls 120.1 2006/03/28 05:07:50 amchaudh noship $ */
/*#
* Debug API for CLN transactions
* @rep:scope private
* @rep:product CLN
* @rep:displayname Debug transactions
* @rep:category BUSINESS_ENTITY  CLN_TRADING_PARTNER_COLL
* @rep:compatibility  S
* @rep:lifecycle  active
*/
--  Constants used as tokens for unexpected error Debugs.

    G_PKG_NAME  CONSTANT    VARCHAR2(15):=  'CLN_DEBUG_PUB';

--  API Debugging table type
--
--      PL/SQL table of VARCHAR2(2000)

    G_DEBUG_LEN        CONSTANT Number := 500; -- Maximum length of a message
    TYPE Debug_tbl_type IS TABLE OF VARCHAR2(500)
     INDEX BY BINARY_INTEGER;

    G_Debug_Tbl                 Debug_Tbl_Type;

--  Global variable holding the Debug count.

    G_Debug_count   NUMBER := 0;

--  Global variable holding the desired debug_level.

    G_Debug_Level   NUMBER :=  to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '0')); /*   1 to 6
                                                        STATEMENT       1
                                                        PROCEDURE       2
                                                        EVENT   3
                                                        EXCEPTION       4
                                                        ERROR   5
                                                        UNEXPECTED      6
                                                        */
--  Index used by the Get function to keep track of the last fetched
--  Debug.

    G_Debug_index   NUMBER     := 0;

--  Flag to indicate if the debugging is on.
--  The call to procedure ADD will add the string to the debug cache
    G_DEBUG      Varchar2(1)    := FND_API.G_FALSE;
    G_DEBUG_MODE VARCHAR2(30)   := 'FILE';
                                -- Table , default mode
                                -- file , write to log file
                                -- CONC , write to log file and concurrent log
    G_DIR         Varchar2(255)     := nvl(fnd_profile.value
                        ('CLN_DEBUG_LOG_DIRECTORY'), '/tmp');
    G_FILE        Varchar2(255)     := null;
    G_FILE_PTR    utl_file.file_type;

/* Name   Set_Debug_mode
** Purpose Sets the debug mode to be FILE or TABLE or CONC.
** It will set the debug mode to FILE if specified so else
** the mode is set to TABLE, It reuturns the name of the file if
** the mode desired is FILE else returns null
*/

/*#
* Sets the Debug mode
* @param p_mode mode
* @return rtn_val  value
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Set Debug Mode
*/
Function Set_Debug_Mode(P_Mode in varchar2) Return Varchar2;

/* Name   Initialize
** Purpose Clears the debug cache. Use this procedure to clear out the
** any debugging statments cached in the debug table.
*/

/*#
* Initializes package variables
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Initialize package variables
*/
PROCEDURE Initialize;

/* Name   Debug_On
** Purpose To Turn the debugging on. Use this proceudre to enable debuging
** for the current sesssion. Any subsquent call to the statment add will result
** in the debug statments cached to the debug table
*/

/*#
* Sets FND api variables
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Set variable values
 */
Procedure Debug_ON;

/* Name   Debug_Off
** Purpose To Turn off the debugging. Use this proceudre to disable debugging
** for the current sesssion. Call to ADD will be ignored. Please note that
** Function does not clear the cache and any debuging information is retained
*/

/*#
* Sets FND api variables
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Set variable values
*/
Procedure Debug_OFF;

/* Name   IsDebugOn
** Purpose To test if the debugging is enabled.
*/

/*#
* Gets package variable value debugon
* @return booleanvalue
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Get debugon value
*/
Function ISDebugOn Return Boolean;

/* Name   GetDebugCount
** Purpose To get the number of debugging message cached
*/

/*#
* Gets package variable value debugcount
* @return  value debugcount
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Get debugcount value
*/
FUNCTION GetDebugCount RETURN NUMBER;

/* Name   Add
** Purpose To add a debugging message. This message will be placed in
** the table only if the debuggin is turned on.
*/

/*#
* Sets FND api variables
* @param p_debug_msg value
* @param p_debug_level value
* @return  value debugcount
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Get variable values
*/
PROCEDURE Add(p_debug_msg in Varchar2, p_debug_level in Number default 5);

/* Name   GetFirst
** Purpose To Get the First Message. This prcocude will reset the debug index
*/

/*#
* Gets first debug message
* @param debug_msg value
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Get first debug message
*/
Procedure GetFirst(Debug_msg OUT NOCOPY Varchar2);

/* Name   GetNext
** Purpose To Get the Next Message from the  debug cache.
** This Procedure will increment the debug index  by one
*/

/*#
* Gets  debug message
* @param debug_msg value
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Get debug message
*/
Procedure GetNext(debug_msg OUT NOCOPY varchar2);

/* Name  GetNextBuffer
** Purpose To Get the Next Set of message separted by a new line
** The routine will concatnate the message until reaching the end of the
** mesage cache or the total messages exceed as specified in the p_msg_count
** This Procedure will increment the debug index  acordingly
*/

/*#
* Gets the next message in the buffer
* @param p_debug_msg value
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Get the next message in the buffer
*/
Procedure GetNextBuffer( p_debug_msg in OUT NOCOPY varchar2);

/* Name ResetIndex
** resest the debug index, setting the index pointer to the beginging of the
** cache
*/

/*#
* Resets package variable values
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Resets package variable values
*/
Procedure ResetIndex;

/* Name SetDebugLevelFromProfile;
** Set g_debug_level to the value specified in the profile CLN_DEBUG_LEVEL
*/


Procedure SetDebugLevelFromProfile;

/* Name SetDebugLevel (p_debug_level in number);
** Set g_debug_level to the desired one
*/
Procedure SetDebugLevel(p_debug_level in number);


END CLN_DEBUG_PUB;

 

/
