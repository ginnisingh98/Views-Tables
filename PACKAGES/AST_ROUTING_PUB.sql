--------------------------------------------------------
--  DDL for Package AST_ROUTING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AST_ROUTING_PUB" AUTHID CURRENT_USER AS
/* $Header: asttmrts.pls 115.10 2004/09/03 09:00:05 uadhikar ship $ */

  TYPE resource_access_rec_type is RECORD
  (
	resource_id		NUMBER,
	access_level		VARCHAR2(1)
  );

  TYPE resource_access_tbl_type is TABLE of resource_access_rec_type
	index by BINARY_INTEGER;

  G_NO_PARTY		CONSTANT	NUMBER := -1;
  G_MULTIPLE_PARTY	CONSTANT	NUMBER := -2;

------------------------------------------------------------------------------
--  Procedure	: 	getResourcesForParty
--  Usage		: 	Used for routing purposes by the UWQ / Telephony team
--  Description: 	This procedure takes party_id as input and returns
--				a table of resource_ids that have update access to
--				the party.
--  Parameters	:
--   p_party_id 	IN   NUMBER	Required
--   p_resources	OUT  resource_access_tbl_type
--
------------------------------------------------------------------------------

PROCEDURE getResourcesForParty (
	p_party_id 	IN 	NUMBER,
     p_resources 	OUT NOCOPY 	resource_access_tbl_type);

------------------------------------------------------------------------------
--  Procedure	: 	getResourcesForSourceCode
--  Usage		: 	Used for routing purposes by the UWQ / Telephony team
--  Description: 	This procedure takes source_code as input and returns
--				a table of resource_ids that can work on the
--				campaign schedule associated with this source code
--  Parameters	:
--   p_source_code 	IN   VARCHAR2	Required
--   p_resources	OUT  resource_access_tbl_type
--
------------------------------------------------------------------------------

PROCEDURE getResourcesForSourceCode (
	p_source_code 	IN 	VARCHAR2,
     p_resources 	OUT NOCOPY 	resource_access_tbl_type);

------------------------------------------------------------------------------
--  Procedure	: 	getPartyForObject
--  Usage		: 	Used for routing purposes by the UWQ / Telephony team
--  Description: 	This procedure takes a type and value as input and
--				returns a party_id
--  Parameters	:
--   p_object_type 	IN   VARCHAR2	Required
--   p_object_value	IN   VARCHAR2	Required
--   p_party_id	OUT  NUMBER
--
------------------------------------------------------------------------------

PROCEDURE getPartyForObject (
	p_object_type 	IN 	VARCHAR2,
	p_object_value	IN 	VARCHAR2,
	p_party_name 	OUT NOCOPY 	VARCHAR2,
	p_party_id 	OUT NOCOPY 	NUMBER);

-- overloaded procedure for multiple IVR parameters scenarios
-- Added for future changes
PROCEDURE getPartyForObject (
	p_object_type 		IN 		VARCHAR2,
	p_object_value		IN 		VARCHAR2,
	p_object2_type 	IN OUT NOCOPY 	VARCHAR2,
	p_object2_value	IN OUT NOCOPY 	VARCHAR2,
	p_party_name 		OUT NOCOPY 		VARCHAR2,
	p_party_id 		OUT NOCOPY 		NUMBER);

END AST_ROUTING_PUB;

 

/
