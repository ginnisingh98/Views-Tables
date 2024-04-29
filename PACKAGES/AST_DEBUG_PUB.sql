--------------------------------------------------------
--  DDL for Package AST_DEBUG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AST_DEBUG_PUB" AUTHID CURRENT_USER as
/* $Header: astidbgs.pls 115.4 2003/01/07 19:37:56 karamach ship $ */
-- Start of Comments
-- Package name     : AST_DEBUG_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


    G_PKG_NAME      CONSTANT    VARCHAR2(15):=  'AST_DEBUG_PUB';
    G_Debug_Level   NUMBER := to_number(nvl(
   		                      fnd_profile.value('IEX_DEBUG_LEVEL'), '0'));
    G_DIR           Varchar2(255)      :=
                               fnd_profile.value('UTL_FILE_DIR');
    G_FILE          Varchar2(255)      := null;
    G_FILE_PTR      utl_file.file_type;

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
                     debug_level in Number default 1,
                     print_date in varchar2 default 'N');


/* Name SetDebugLevel (p_debug_level in number);
** Set g_debug_level to the desired one if running outside of application
** since the debug_level is set through a profile
*/
Procedure SetDebugLevel(p_debug_level in number);

END AST_DEBUG_PUB;

 

/
