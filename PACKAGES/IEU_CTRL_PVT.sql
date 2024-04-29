--------------------------------------------------------
--  DDL for Package IEU_CTRL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEU_CTRL_PVT" AUTHID CURRENT_USER AS
/* $Header: IEUVCTLS.pls 120.1 2005/07/14 15:20:54 appldev ship $ */
PROCEDURE SET_LANG_INFO
 (
   P_USER_LANG IN VARCHAR2
 );

----------------------------------------------------------------------------
-- Utility procedure to set language stuff and return the previous lang
-- settings
----------------------------------------------------------------------------
PROCEDURE SET_LANG_INFO_X
 (
   P_USER_LANG IN VARCHAR2,
   X_EXISTING_LANG OUT NOCOPY VARCHAR2
 );

----------------------------------------------------------------------------
-- Stored procedure to retrieve a ctrl message object from the db based on
-- filter criteria. It returns a nested table of message objects
-- dont think any xlation will play a part here
----------------------------------------------------------------------------

PROCEDURE GET_CTRL_MESSAGES
 (
   P_RESOURCE_ID IN NUMBER,
   P_STATUS_ID   IN NUMBER,
   P_AGE_FILTER  IN NUMBER,
   X_CTRL_MESSAGES_NST OUT NOCOPY SYSTEM.IEU_CTRL_MESSAGES_NST
 );

----------------------------------------------------------------------------
-- Stored procedure to retrieve a ctrl message object from the db based on
-- filter criteria( with a time range ).
----------------------------------------------------------------------------

PROCEDURE GET_CTRL_MESSAGES_T
 (
   P_RESOURCE_ID IN NUMBER,
   P_STATUS_ID   IN NUMBER,
   P_START_FILTER  IN NUMBER,
   P_END_FILTER  IN NUMBER,
   X_CTRL_MESSAGES_NST OUT NOCOPY SYSTEM.IEU_CTRL_MESSAGES_NST
 );

----------------------------------------------------------------------------
-- Stored Procedure to store modified ctrl message objects to the db
-- This automatically updates the last_update_date
-- It takes in a nested table of message objects
----------------------------------------------------------------------------

PROCEDURE SAVE_CTRL_MESSAGES
 (
   P_CTRL_MESSAGES_NST IN SYSTEM.IEU_CTRL_MESSAGES_NST
 );

----------------------------------------------------------------------------
-- Stored procedure used to get the information of the plugins
-- which are to be loaded by the desktop agent
----------------------------------------------------------------------------
PROCEDURE GET_CTRL_PLUGINS
 (
   P_RESOURCE_ID  IN NUMBER
  ,P_AGENT_EXTN   IN NUMBER
  ,P_USER_ID      IN NUMBER
  ,P_RESP_ID      IN NUMBER
  ,P_RESP_APPL_ID IN NUMBER
  ,P_USER_LANG    IN VARCHAR2
  ,X_CTRL_PLUGINS_NST OUT NOCOPY SYSTEM.IEU_CTRL_PLUGINS_NST
 );


----------------------------------------------------------------------------
-- Used to get the FND Error Message text strings during  Error Panel
-- initialization. The messages are obtained on the basis of
-- messages names passed to the procedure
--
-- The P_MESSAGE_NST parameter will contain the message names
-- and the X_MESSAGE_NST will contain the message name and the
-- text. Refer to IEU_CTRL_OD.sql for definitions
----------------------------------------------------------------------------
PROCEDURE GET_FND_ERROR_MESSAGES
 (
   P_RESOURCE_ID  IN  NUMBER
  ,P_FND_MESSAGES_NST  IN  SYSTEM.IEU_FND_MESSAGES_NST
  ,P_USER_LANG    IN  VARCHAR2
  ,X_FND_MESSAGES_NST  OUT NOCOPY SYSTEM.IEU_FND_MESSAGES_NST
 );

----------------------------------------------------------------------------
-- Used to get FND Lookup Codes and values( meaning ) based on the
-- lookup type and application ID
----------------------------------------------------------------------------
PROCEDURE GET_FND_LOOKUP_VALUES
 (
   P_RESOURCE_ID   IN  NUMBER
  ,P_APP_ID        IN  NUMBER
  ,P_LOOKUP_TYPE   IN  VARCHAR2
  ,P_USER_LANG     IN  VARCHAR2
  ,X_FND_MESSAGES_NST  OUT NOCOPY SYSTEM.IEU_FND_MESSAGES_NST
 );

---------------------------------------------------------------------------
-- Used to get FND Lookup Codes and values( meaning ) based on the
-- lookup type and application ID and sorted on meaning
----------------------------------------------------------------------------
PROCEDURE GET_FND_LOOKUP_VALUES_SRT
 (
   P_RESOURCE_ID   IN  NUMBER
  ,P_APP_ID        IN  NUMBER
  ,P_LOOKUP_TYPE   IN  VARCHAR2
  ,P_USER_LANG     IN  VARCHAR2
  ,X_FND_MESSAGES_NST  OUT NOCOPY SYSTEM.IEU_FND_MESSAGES_NST
 );

----------------------------------------------------------------------------
-- Used to get FND Lookup Codes and values( meaning ) based on the
-- lookup type and application ID
----------------------------------------------------------------------------
PROCEDURE GET_FND_LOOKUP_CODES
 (
   P_RESOURCE_ID     IN  NUMBER
  ,P_APP_ID          IN  NUMBER
  ,P_CTRL_STRING_NST IN  SYSTEM.IEU_CTRL_STRING_NST
  ,P_USER_LANG       IN  VARCHAR2
  ,X_FND_CODES_NST   OUT NOCOPY SYSTEM.IEU_FND_CODES_NST
 );

END IEU_CTRL_PVT;

 

/
