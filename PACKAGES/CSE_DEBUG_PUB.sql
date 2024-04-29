--------------------------------------------------------
--  DDL for Package CSE_DEBUG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSE_DEBUG_PUB" AUTHID CURRENT_USER AS
/* $Header: CSEPDBGS.pls 120.1 2006/08/16 06:39:38 brmanesh noship $ */

  G_PKG_NAME  CONSTANT    VARCHAR2(15):=  'CSE_DEBUG_PUB';
  G_BASIC     CONSTANT    Number := 0;
  G_Detailed  CONSTANT    Number := 1;
  G_DIR                   Varchar2(80) := nvl(fnd_profile.value ('CSE_DEBUG_LOG_DIRECTORY'), '/tmp');
  G_FILE        Varchar2(255)     := null;
  G_FILE_PTR    utl_file.file_type;
  G_DEBUG_LEVEL number := G_Detailed;
  G_DEBUG       Boolean := FALSE;


  -- Set Debug File, Use this function to set the debug file name,
  -- CSE will generate a random file name if you call this procedure without
  -- a user specified file name.
  -- The function returns the debug file name including the directory name
  FUNCTION set_debug_file(P_FILE in Varchar2 default null) Return Varchar2;

  -- Set Debug Level use this function to set the debug level.
  -- The default level is Detailed ie 1. You can use this function to set the
  -- debug level to 0 ie Basic.
  PROCEDURE set_debug_level(p_debug_level in Number );

  -- Name   Debug_On
  -- Purpose To Turn the debugging on. Use this proceudre to enable debuging
  -- for the current sesssion. Any subsquent call to the statment add will result
  -- in the debug statments cached to the debug table
  PROCEDURE Debug_ON;


  -- Name   Debug_Off
  -- Purpose To Turn off the debugging. Use this proceudre to disable debugging
  -- for the current sesssion. Call to ADD will be ignored. Please note that
  -- Function dCSEs not clear the cache and any debuging information is retained
  PROCEDURE Debug_OFF;

  -- Name   IsDebugOn
  -- Purpose To test if the debugging is enabled.
  FUNCTION ISDebugOn Return Boolean;


  -- Name   Add
  -- Purpose To add a debugging message. This message will be placed in
  -- the table only if the debugging is turned on.
  PROCEDURE Add(debug_msg   in Varchar2, debug_level in Number    default G_DETAILED);

END cse_debug_pub;

 

/
