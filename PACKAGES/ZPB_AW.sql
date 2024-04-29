--------------------------------------------------------
--  DDL for Package ZPB_AW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZPB_AW" AUTHID CURRENT_USER AS
/* $Header: zpbaw.pls 120.5 2007/12/04 14:43:43 mbhat ship $ */

-------------------------------------------------------------------------------
-- EXECUTE
--
-- Function to call dbms_aw.execute
--
-- IN:  p_cmd (varchar2) - The AW command to execute
--
-------------------------------------------------------------------------------
procedure EXECUTE (p_cmd in varchar2);

-------------------------------------------------------------------------------
-- INTERP <--DEPRECATED! Use EVAL_TEXT and EVAL_NUMBER instead -->
--
-- Wrapper around the call to the AW, which will parse the output.  If no
-- output is expected, you may just run zpb_aw.execute() instead.
--
-- IN:  p_cmd (varchar2) - The AW command to execute
-- OUT:        varchar2  - The output of the the AW command
--
-------------------------------------------------------------------------------
function INTERP (p_cmd in varchar2)
   return varchar2;

-------------------------------------------------------------------------------
-- INTERPBOOL
--
-- Wrapper around the call the AW with boolean (yes/no) output expected.
-- Will handle conversion within the NLS_LANGUAGE setting (Bug 4058390).
--
-- IN:  p_cmd (varchar2) - The AW boolean command to execute
-- OUT:        boolean   - The output of the the AW command
--
-------------------------------------------------------------------------------
function INTERPBOOL (p_cmd in varchar2)
   return boolean;

-------------------------------------------------------------------------------
-- EVAL_TEXT
--
-- Improved version of INTERP, which avoids many OLAP bugs.  No need to
-- use "show" in front of command.  Returns text-based queries, null if NA.
-- -
-- IN:  p_cmd (varchar2) - The AW command to execute
-- OUT:        varchar2  - The output of the the AW command
--
-------------------------------------------------------------------------------
function EVAL_TEXT (p_cmd in VARCHAR2)
   return VARCHAR2;

-------------------------------------------------------------------------------
-- EVAL_NUMBER
--
-- Improved version of INTERP, which avoids many OLAP bugs.  No need to
-- use "show" in front of command.  Returns numeric queries, null if NA.
-- -
-- IN:  p_cmd (varchar2) - The AW command to execute
-- OUT:        varchar2  - The output of the the AW command
--
-------------------------------------------------------------------------------
function EVAL_NUMBER (p_cmd in VARCHAR2)
   return NUMBER;

------------------------------------------------------------------------------
-- DETACH_ALL
--
-- Detaches all AW's on the session
------------------------------------------------------------------------------
procedure DETACH_ALL;

-------------------------------------------------------------------------------
-- GET_ANNOTATION_AW
--
-- Returns the un-qualified (schema not prepended) annotation aw name for
-- the business area.
--
-- IN: p_business_area_id (number) - The Business Area ID.  If null, then
--                                   uses the Business Area in context, or
--                                   the business area currently logged in as
-------------------------------------------------------------------------------
function GET_ANNOTATION_AW
     (p_business_area_id IN ZPB_BUSINESS_AREAS.BUSINESS_AREA_ID%type := null)
   return ZPB_BUSINESS_AREAS.ANNOTATION_AW%type;

-------------------------------------------------------------------------------
-- GET_CODE_AW
--
-- Returns the un-qualified (schema not prepended) code aw name for
-- this user.
--
-- IN: p_user (varchar2) - The FND_USER USER_ID
-------------------------------------------------------------------------------
function GET_CODE_AW (p_user in varchar2 := null)
   return varchar2;

-------------------------------------------------------------------------------
-- GET_PERSONAL_AW
--
-- Returns the un-qualified (schema not prepended) personal aw name for
-- this user.
--
-- IN: p_user (varchar2) - The FND_USER USER_ID
-------------------------------------------------------------------------------
function GET_PERSONAL_AW (p_user in varchar2 := null,
                 p_business_area_id in ZPB_BUSINESS_AREAS.BUSINESS_AREA_ID%type
                                                := null)
   return ZPB_USERS.PERSONAL_AW%type;

-------------------------------------------------------------------------------
-- GET_SHARED_AW
--
-- Returns the un-qualified (schema not prepended) shared aw name for
-- the business area.
--
-- IN: p_business_area_id (number) - The Business Area ID.  If null, then
--                                   uses the Business Area in context, or
--                                   the business area currently logged in as
-------------------------------------------------------------------------------
function GET_SHARED_AW
     (p_business_area_id IN ZPB_BUSINESS_AREAS.BUSINESS_AREA_ID%type := null)
   return ZPB_BUSINESS_AREAS.DATA_AW%type;

-------------------------------------------------------------------------------
-- GET_SCHEMA
--
-- Returns the schema where the aw's reside
-------------------------------------------------------------------------------
function GET_SCHEMA
   return varchar2;

-------------------------------------------------------------------------------
-- GET_AW_SHORT_NAME
--
-- Procedure to get the AW short name, used in CWM and view names.  If a
-- developer AW is passed in, will use the username.  Otherwise, is the same as
-- the AW actual name
--
-- IN:  p_aw (varchar2) - The actual name of the AW
-- OUT:       varchar2  - The short name of the AW
--
-------------------------------------------------------------------------------
function GET_AW_SHORT_NAME (p_aw in varchar2) return varchar2;

-------------------------------------------------------------------------------
-- GET_AW_TINY_NAME
--
-- Procedure to get ZPB followed by business area id from ZPB.ZPBDATAXXX
-- Used in CWM and view names.  If a personal AW is passed in,
-- its name will not be changed other than the stripping of schema prefix.
--
-- IN:  p_aw (varchar2) - The actual name of the AW
-- OUT:       varchar2  - ZPB + BA_ID
--
-------------------------------------------------------------------------------
function GET_AW_TINY_NAME (p_aw in varchar2) return varchar2;

-------------------------------------------------------------------------------
-- INITIALIZE
--
-- Initializes the AW session by attaching code, annotation and shared AW for
-- the Business Area specified, and setting context and session-wide
-- parameters
--
-- No commit is done by this procedure
--
-- IN: p_business_area_id NUMBER - The Business Area ID to work under
--     p_shadow_id        NUMBER - The shadow user ID, if different than
--                                 FND_GLOBAL.USER_ID
--     p_shared_rw        VARCHAR2 - Whether to attach shared AW r/w.  Should
--                                   only be true in a conc. req.
--     p_annot_rw         VARCHAR2 - Whether to attach shared AW r/w.  Annot AW
--                                   should only be r/w for as small a period
--                                   of time as possible
--
-------------------------------------------------------------------------------
PROCEDURE initialize(p_api_version       IN  NUMBER,
                     p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
                     p_validation_level  IN  NUMBER
                                                := FND_API.G_VALID_LEVEL_FULL,
                     x_return_status     OUT NOCOPY varchar2,
                     x_msg_count         OUT NOCOPY number,
                     x_msg_data          OUT NOCOPY varchar2,
                     p_business_area_id  IN  NUMBER,
                     p_shadow_id         IN  NUMBER := FND_GLOBAL.USER_ID,
                     p_shared_rw         IN  VARCHAR2 := FND_API.G_FALSE,
                     p_annot_rw          IN  VARCHAR2 := FND_API.G_FALSE,
                                         p_detach_all        IN  VARCHAR2 := FND_API.G_TRUE);

-------------------------------------------------------------------------------
-- INITIALIZE_FOR_AC
--
-- Initializes the AW session by attaching code, annotation and shared AW for
-- the business process specified, and setting context and session-wide
-- parameters
--
-- No commit is done by this procedure
--
-- IN: p_analysis_cycle_id NUMBER - The Analysis Cycle to initialize against
-------------------------------------------------------------------------------
PROCEDURE initialize_for_ac(p_api_version       IN  NUMBER,
                            p_init_msg_list     IN  VARCHAR2:= FND_API.G_FALSE,
                            p_validation_level  IN  NUMBER
                                                 := FND_API.G_VALID_LEVEL_FULL,
                            x_return_status     OUT NOCOPY varchar2,
                            x_msg_count         OUT NOCOPY number,
                            x_msg_data          OUT NOCOPY varchar2,
                            p_analysis_cycle_id IN  NUMBER,
                            p_shared_rw         IN  VARCHAR2:=FND_API.G_FALSE,
                            p_annot_rw          IN  VARCHAR2:=FND_API.G_FALSE);

-------------------------------------------------------------------------------
-- INITIALIZE_USER
--
-- Initializes the AW session by attaching the personal AW for
-- the user specified.  Will initialize the shared AW's
--
-- No commit is done by this procedure
--
-- IN: p_user             NUMBER - The User ID to initialize against
--     p_business_area_id NUMBER - The Business Area ID to work under. Defaults
--                                 to the current context, which is set if
--                                 INITIALIZE(_FOR_AC) has already been called.
--                                 Will error if not set or passed in.
--     p_attach_readwrite VARCHAR2 - Whether to attach personal rw or ro
--     p_sync_shared      VARCHAR2 - Whether to synch the shared with the
--                                   personal.  Should be done before any
--                                   processing happens.
-------------------------------------------------------------------------------
PROCEDURE INITIALIZE_USER(p_api_version       IN  NUMBER,
                          p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
                          p_validation_level  IN  NUMBER
                                                := FND_API.G_VALID_LEVEL_FULL,
                          x_return_status     OUT NOCOPY varchar2,
                          x_msg_count         OUT NOCOPY number,
                          x_msg_data          OUT NOCOPY varchar2,
                          p_user              IN  FND_USER.USER_ID%type,
                          p_business_area_id  IN  NUMBER
                             := sys_context('ZPB_CONTEXT', 'business_area_id'),
                          p_attach_readwrite  IN  VARCHAR2 := FND_API.G_FALSE,
                          p_sync_shared       IN  VARCHAR2 := FND_API.G_TRUE,
                                                  p_detach_all        IN  VARCHAR2 := FND_API.G_FALSE);

-------------------------------------------------------------------------------
-- clean_workspace
--
-- Procedure detaches the code and shared AWs and resets the ZPB context.
-- Designed to be called by backend programs that initiate an
-- OLAP workspace with full data access.
--
-- No commit is done by this procedure
--
-------------------------------------------------------------------------------
PROCEDURE clean_workspace ( p_api_version       IN NUMBER,
                            p_init_msg_list     IN VARCHAR2 := FND_API.G_FALSE,
                            p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
                            x_return_status     OUT NOCOPY varchar2,
                            x_msg_count         OUT NOCOPY number,
                            x_msg_data          OUT NOCOPY varchar2);


end ZPB_AW;

/
