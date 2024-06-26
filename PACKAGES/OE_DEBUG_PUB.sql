--------------------------------------------------------
--  DDL for Package OE_DEBUG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_DEBUG_PUB" AUTHID CURRENT_USER AS
/* $Header: OEXPDBGS.pls 120.0 2005/06/01 03:05:44 appldev noship $ */

--  Constants used as tokens for unexpected error Debugs.

    G_PKG_NAME  CONSTANT    VARCHAR2(15):=  'OE_DEBUG_PUB';

--  API Debugging table type
--
--      PL/SQL table of VARCHAR2(2000)

G_DEBUG_LEN        CONSTANT Number := 500;
TYPE Debug_tbl_type IS TABLE OF VARCHAR2(500)
     INDEX BY BINARY_INTEGER;

    G_Debug_Tbl                 Debug_Tbl_Type;

--  Global variable holding the Debug count.

    G_Debug_count   NUMBER := 0;

--  Global variable holding the desired debug_level.

    G_Debug_Level   NUMBER :=  FND_PROFILE.VALUE('ONT_DEBUG_LEVEL');

--  Index used by the Get function to keep track of the last fetched
--  Debug.

    G_Debug_index   NUMBER     := 0;
--  Flag to indicate if the debugging is on.
--  The call to procedure ADD will add the string to the debug cache
    G_DEBUG      Varchar2(1)    := FND_API.G_FALSE;
    G_DEBUG_MODE VARCHAR2(30)   := 'TABLE';
                                -- Table , default mode
                                -- file , write to log file
    G_DIR         Varchar2(255)     := nvl(fnd_profile.value
			('OE_DEBUG_LOG_DIRECTORY'), '/tmp');
    G_FILE        Varchar2(255)     := null;
    G_FILE_PTR    utl_file.file_type;
/* Name   Set_Debug_mode
** Purpose Sets the debug mode to be FILE or TABLE.
** It will set the debug mode to FILE if specified so else
** the mode is set to TABLE, It reuturns the name of the file if
** the mode desired is FILE else returns null
*/
Function Set_Debug_Mode(P_Mode in varchar2) Return Varchar2;
/* Name   Initialize
** Purpose Clears the debug cache. Use this procedure to clear out the
** any debugging statments cached in the debug table.
*/
PROCEDURE Initialize;
/* Name   Debug_On
** Purpose To Turn the debugging on. Use this proceudre to enable debuging
** for the current sesssion. Any subsquent call to the statment add will result
** in the debug statments cached to the debug table
*/
Procedure Debug_ON;
/* Name   Debug_Off
** Purpose To Turn off the debugging. Use this proceudre to disable debugging
** for the current sesssion. Call to ADD will be ignored. Please note that
** Function does not clear the cache and any debuging information is retained
*/
Procedure Debug_OFF;
/* Name   IsDebugOn
** Purpose To test if the debugging is enabled.
*/
Function ISDebugOn Return Boolean;
/* Name   CountDebug
** Purpose To get the number of debugging message cached
*/
FUNCTION CountDebug RETURN NUMBER;
/* Name   Add
** Purpose To add a debugging message. This message will be placed in
** the table only if the debuggin is turned on.
*/
PROCEDURE Add(debug_msg in Varchar2, debug_level in Number default 5);
/* Name   GetFirst
** Purpose To Get the First Message. This prcocude will reset the debug index
*/
Procedure GetFirst(Debug_msg out NOCOPY /* file.sql.39 change */ Varchar2);
/* Name   GetNext
** Purpose To Get the Next Message from the  debug cache.
** This Procedure will increment the debug index  by one
*/
Procedure GetNext(debug_msg out NOCOPY /* file.sql.39 change */ varchar2);
/* Name  GetNextBuffer
** Purpose To Get the Next Set of message separted by a new line
** The routine will concatnate the message until reaching the end of the
** mesage cache or the total messages exceed as specified in the p_msg_count
** This Procedure will increment the debug index  acordingly
*/
Procedure GetNextBuffer( p_debug_msg in out NOCOPY /* file.sql.39 change */ varchar2);
/* Name DumpDebug
** Purpose To disply debug message from the sql prompt.
** This routine will display all the mesages in the cahce using the procedure
** dbms_out.put_line.
*/
PROCEDURE DumpDebug;
/* Name ResetIndex
** resest the debug index, setting the index pointer to the beginging of the
** cache
*/
Procedure ResetIndex;

/* Name SetDebugLevel (p_debug_level in number);
** Set g_debug_level to the desired one
*/
Procedure SetDebugLevel(p_debug_level in number);

Procedure Start_ONT_Debugger(p_directory    IN  VARCHAR2,
                             p_filename     IN  VARCHAR2,
                             p_file_handle  IN  UTL_FILE.File_Type);

Procedure Stop_ONT_Debugger;

END OE_DEBUG_PUB;

 

/
