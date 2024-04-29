--------------------------------------------------------
--  DDL for Package OKL_DEBUG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_DEBUG_PUB" AUTHID CURRENT_USER as
/* $Header: OKLPDEGS.pls 115.2 2003/01/28 12:44:32 rabhupat noship $ */
-- Start of Comments
-- Package name     : OKL_DEBUG_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


    G_PKG_NAME      CONSTANT    VARCHAR2(15):=  'OKL_DEBUG_PUB';
    G_Debug_Level   NUMBER := to_number(nvl(
   		                      fnd_profile.value('OKL_DEBUG_LEVEL'), '0'));
    G_DIR           Varchar2(255)      :=
                               fnd_profile.value('UTL_FILE_DIR');
    G_FILE          Varchar2(255)      := null;
    G_FILE_PTR      utl_file.file_type;
/* Inserted by SPILLAIP Begin*/
  g_session_id  Varchar2(255):= OKC_API.G_MISS_CHAR;
  g_profile_log_level Number := 0;
/* Inserted by SPILLAIP END*/

/* Name   OpenFile
** It Opens the file if given , else creates a new file
*/
Function  OpenFile(P_file in varchar2 default null) return varchar2;


/* Name   LogMessage
** Purpose To add a debugging message. This message will be placed in
** the file only if the debug level is greater than the g_debug_level
** which is based on a profile
*/
PROCEDURE LogMessage(debug_msg in Varchar2,
                     debug_level in Number default 10,
                     print_date in varchar2 default 'N');


/* Name SetDebugLevel (p_debug_level in number);
** Set g_debug_level to the desired one if running outside of application
** since the debug_level is set through a profile
*/
Procedure SetDebugLevel(p_debug_level in number);

Procedure SetDebugFileDir(P_FILEDIR IN VARCHAR2);

/*Inserted by SPILLAIP BEGIN*/
--
--Function to check if the debug is enabled in the System profile.
FUNCTION CHECK_LOG_ENABLED
  RETURN varchar2;

--
--Function to check if particular module is enabled for a given level
--Only on success of this function, procedure log_debug can be called.
--
FUNCTION CHECK_LOG_ON
  ( p_module IN varchar2,
    p_level IN number)
   RETURN  boolean;

PROCEDURE set_connection_context;

--
--Procedure to log debug messages using FND_LOG. Debug messages will be
--logged only if the debg level in fnd_profile is less than the specified
--level during the call of this procedure.
--

PROCEDURE LOG_DEBUG
  ( p_log_level IN number,
    p_module IN varchar2,
    p_message IN varchar2);
/*Inserted by SPILLAIP END*/
END OKL_DEBUG_PUB;

 

/
