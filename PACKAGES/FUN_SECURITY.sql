--------------------------------------------------------
--  DDL for Package FUN_SECURITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_SECURITY" AUTHID CURRENT_USER AS
/* $Header: FUNSECAS.pls 120.3 2004/11/10 05:48:29 panaraya noship $*/



--------------------------------------
--------------------------------------
-- declaration of procedures
--------------------------------------
--------------------------------------


/*-----------------------------------------------------
 * PROCEDURE create_assign
 * ----------------------------------------------------
 * Create grants for the specified person to the
 * specified organization.
 * ---------------------------------------------------*/
 PROCEDURE create_assign (
   p_api_version	IN		NUMBER,
   p_init_msg_list	IN		VARCHAR2  default null,
   p_commit		IN		VARCHAR2,
   x_return_status	OUT NOCOPY	VARCHAR2,
   x_msg_count		OUT NOCOPY	NUMBER,
   x_msg_data		OUT NOCOPY	VARCHAR2,
   p_org_id		IN		NUMBER DEFAULT NULL,
   p_person_id		IN		NUMBER,
   p_create_all		IN		VARCHAR2,
   p_create_contact	IN		VARCHAR2 default null,
   p_enabled_flag	IN		VARCHAR2 default null
   );

/*-----------------------------------------------------
 * PROCEDURE update_assign
 * ----------------------------------------------------
 * Updates grants for the specified person to the
 * specified organization.
 * ---------------------------------------------------*/

 PROCEDURE update_assign (
   p_api_version	IN		NUMBER,
   p_init_msg_list	IN		VARCHAR2  default null,
   p_commit		IN		VARCHAR2,
   x_return_status	OUT NOCOPY	VARCHAR2,
   x_msg_count		OUT NOCOPY	NUMBER,
   x_msg_data		OUT NOCOPY	VARCHAR2,
   p_org_id		IN		NUMBER,
   p_person_id		IN		NUMBER,
   p_status		IN		VARCHAR2
   );


/*-----------------------------------------------------
 * FUNCTION is_access_allow
 * ----------------------------------------------------
 * Checks whether an FND grant on intercompany objects
 * exists for the person.
 * ---------------------------------------------------*/

 FUNCTION is_access_allow (
   p_person_id		IN		NUMBER,
   p_org_id		IN		NUMBER
   ) RETURN VARCHAR2;


/*-----------------------------------------------------
 * FUNCTION is_access_valid
 * ----------------------------------------------------
 * Checks whether an FND grant on intercompany objects
 * is valid or not.
 * ---------------------------------------------------*/

 FUNCTION is_access_valid (
   p_person_id		IN		NUMBER,
   p_org_id		IN		NUMBER
   ) RETURN VARCHAR2;

END FUN_SECURITY;

 

/
