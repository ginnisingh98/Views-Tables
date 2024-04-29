--------------------------------------------------------
--  DDL for Package OE_PC_GLOBALS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_PC_GLOBALS" AUTHID CURRENT_USER AS
/* $Header: OEXPPCGS.pls 115.9 2003/10/20 07:07:46 appldev ship $ */


-- type declaration

-- Constrained Entities
-- These constants correspond to the entity_id column on oe_pc_entities_v
G_ENTITY_HEADER     		constant number  := 1;
G_ENTITY_LINE     			constant number  := 2;
G_ENTITY_HEADER_SCREDIT 		constant number  := 5;
G_ENTITY_HEADER_ADJ 		constant number  := 6;
G_ENTITY_LINE_SCREDIT  		constant number  := 7;
G_ENTITY_LINE_ADJ  			constant number  := 8;
G_ENTITY_BLANKET_HEADER     		constant number  := 1018;
G_ENTITY_BLANKET_LINE     			constant number  := 1019;
--serla begin
G_ENTITY_HEADER_PAYMENT                 constant number  := 1024;
G_ENTITY_LINE_PAYMENT           constant number  := 1025;
--serla end
-- constants
YES     		constant number  := 1;
NO      		constant number  := 0;
ERROR   		constant number  := -1;
MSDATA_LEN	constant number  := 238;

-- on operation actions
DONT       constant number  := 0;
RREASON    constant number  := 1;
RHISTORY   constant number  := 2;
RVERSN     constant number  := 0.1;
VERSNONLY  constant number  := 0.2;

-- condition type flag
WF_VALIDATION	      constant varchar2(5) := 'WF';
TBL_VALIDATION     	constant varchar2(5) := 'TBL';
API_VALIDATION	      constant varchar2(5) := 'API';


YES_FLAG    constant  varchar2(3) := 'Y';
NO_FLAG     constant  varchar2(3) := 'N';

CREATE_OP 	constant varchar2(1)  := 'C';
RETRIEVE_OP constant varchar2(1)  := 'R';
UPDATE_OP	constant varchar2(1)  := 'U';
DELETE_OP   constant varchar2(1)  := 'D';
CANCEL_OP   constant varchar2(1)  := 'X';
SPLIT_OP   constant varchar2(1)  := 'S';
EXECUTE_OP  constant varchar2(1)  := 'E';


MAX_WRITE_LENGTH  	constant number := 1200;
MIN_WRITE_LENGTH  	constant number := 1100;

COMMENT           	constant varchar2(1) := 'C';
PKG            	      constant varchar2(1) := 'P';
SQLSTR          	      constant varchar2(1) := 'S';

NEWLINE         	      constant varchar2(10) := '
';  -- *** IMPORTANT : this should be kept in two lines
HOST_CONC_PROGRAM       constant varchar2(30) := 'OECOMPF';

-- Record And Table Type to return the list of authorized WF
-- Roles for a constraint. Used by the function
-- Get_Authorized_WF_Roles

TYPE Authorized_WF_Role_TYPE IS RECORD
( Name			VARCHAR2(100)
, Display_Name		VARCHAR2(240)
);

TYPE Authorized_WF_Roles_TBL IS TABLE OF Authorized_WF_Role_TYPE
	INDEX BY BINARY_INTEGER;

-- Bug 2003823:
-- Cache the value of profile that controls whether generic update
-- constraints apply to DFF or not.
G_CHECK_UPDATE_ALL_FOR_DFF VARCHAR2(30) := nvl(FND_PROFILE.VALUE
                                   ('ONT_PC_UPDATE_ALL_FOR_DFF'),'Y');

--  Start of Comments
--  API name    Debug_Print
--  Type        Private
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments
-------------------------------------------
Procedure  Debug_Print (
  p_buffer long
  ,p_title in varchar2 default null
);

END Oe_PC_GLOBALS;

 

/
