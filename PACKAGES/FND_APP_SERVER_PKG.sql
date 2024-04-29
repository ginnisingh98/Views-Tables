--------------------------------------------------------
--  DDL for Package FND_APP_SERVER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_APP_SERVER_PKG" AUTHID CURRENT_USER AS
/* $Header: AFSCASRS.pls 120.3.12010000.3 2010/01/29 16:25:56 pdeluna ship $ */

/* create_server_id
**
** Returns a new unique server_id. The server_id is a string of 64 characters.
** The 1st 32 is a globally unique id and the next 32 is a randomnly
** generated number. This is called by AdminAppServer.createServerId().
*/
FUNCTION create_server_id RETURN VARCHAR2;

/* get_server_id
**
** Returns the server_id given a unique node_name or server_address. This API is
** biased towards the unique node_name. The server_address is used only when the
** node_name cannot be used. server_id can be null if the node has been
** deleted" using delete_server or delete_desktop_server.
*/
FUNCTION get_server_id(
  p_node_name IN VARCHAR2 DEFAULT NULL,
  p_address   IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

/* insert_server
**
** Inserts information for a new Application Server. The function
** create_server_id must be called to generate a valid id prior to
** calling this api. This is called by AdminAppServer.changeServerInDB().
*/
PROCEDURE insert_server(
   p_server_id      IN OUT NOCOPY VARCHAR2,
   p_address        IN VARCHAR2,
   p_node_name      IN VARCHAR2,
   p_description    IN VARCHAR2 DEFAULT NULL,
   p_webhost        IN VARCHAR2 DEFAULT NULL,
   p_platform_code  IN VARCHAR2 DEFAULT NULL,
   p_support_cp     IN VARCHAR2 DEFAULT NULL,
   p_support_forms  IN VARCHAR2 DEFAULT NULL,
   p_support_web    IN VARCHAR2 DEFAULT NULL,
   p_support_admin  IN VARCHAR2 DEFAULT NULL,
   p_support_db     IN VARCHAR2 DEFAULT NULL);

/* delete_server
**
** This procedure used to remove an Application Server row from the database.
** Due to the migration of FND_APPLICATION_SERVERS to FND_NODES,
** fnd_nodes.server_id is nulled out instead in order to preserve the
** node_name and avoid dangling references to the node_name. This is called by
** AdminAppServer.delSvrFromDB().
*/
PROCEDURE delete_server(p_address IN VARCHAR2);

/* update_server
**
** This procedure should only be used for updating Application Server Nodes.
** The server_id, description, host and domain are updated if they are not
** NULL. If a new server_id is required, the create_server_id function should
** be called prior to this. This is called by
** AdminAppServer.changeServerInDB().
*/
PROCEDURE update_server(
   p_server_id   IN VARCHAR2 DEFAULT NULL,
   p_address     IN VARCHAR2,
   p_description IN VARCHAR2 DEFAULT NULL,
   p_webhost     IN VARCHAR2 DEFAULT NULL,
   p_platform    IN VARCHAR2 DEFAULT NULL);

/* authenticate
**
** This procedure is used to turn toggle AUTHENTICATION for an Application
** Server Node. If the AUTHENTICATION row does not exist yet, the procedure
** will insert it. The row with server_address='*' indicates the authentication
** value. If the row already exists, the procedure updates the value to what
** has been passed. The valid AUTHENTICATION values are:
**    'ON'
**    'OFF'
**    'SECURE'
** This is called by AdminAppServer.setAuthentication().
**
** Bug 3736714: the p_platform argument was added so that the authentication
** row can be added with the correct platform.  The platform is determined in
** AdminAppServer.java.
*/
PROCEDURE authenticate(
   p_value        IN OUT NOCOPY VARCHAR2,
   p_platformcode IN VARCHAR2 DEFAULT NULL);

/* insert_desktop_server
**
** This API is used for Desktop Nodes only.
** It calls insert_server and sets all the SUPPORT_* collumns to 'N' and the
** PLATFORM_CODE to 'Others'.  It also places 'Desktop Node' as the description
** if NULL was passed.
*/
PROCEDURE insert_desktop_server(
   p_node_name    IN VARCHAR2,
   p_server_id    IN OUT NOCOPY VARCHAR2,
   p_address      IN VARCHAR2 DEFAULT NULL,
   p_description  IN VARCHAR2 DEFAULT NULL);

/* update_desktop_server
**
** This API is used for Desktop Nodes only.
** Update the FND_NODES row associated with p_node_name with the specified
** values for server_id, address, and description. If NULLs are passed, do not
** update. update_server cannot be used here because it uses p_address as the
** where condition.
*/
PROCEDURE update_desktop_server(
   p_node_name   IN VARCHAR2,
   p_server_id   IN VARCHAR2 DEFAULT NULL,
   p_address     IN VARCHAR2 DEFAULT NULL,
   p_description IN VARCHAR2 DEFAULT NULL);

/* delete_desktop_server
**
** This API is used for Desktop Nodes only.
** Similar to delete_server, server_id is NULLed out, the row is not physically
** deleted.
*/
PROCEDURE delete_desktop_server (p_node_name IN VARCHAR2);

END fnd_app_server_pkg;

/
