--------------------------------------------------------
--  DDL for Package Body FND_APP_SERVER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_APP_SERVER_PKG" AS
/* $Header: AFSCASRB.pls 120.7.12010000.4 2010/05/20 18:36:22 pdeluna ship $ */

/* create_server_id
**
** Returns a new unique server_id. The server_id is a string of 64 characters.
** The 1st 32 is a globally unique id and the next 32 is a randomnly
** generated number. Dynamic sql is being used to create the globally unique id
** because PL/SQL doesn't yet support it. This is called by
** AdminAppServer.createServerId().
*/
FUNCTION create_server_id
  RETURN VARCHAR2
IS
  svrid fnd_nodes.server_id%TYPE;
  guid   VARCHAR2(32);
  rnd_dt VARCHAR2(32);
  curs   INTEGER;
  sqlbuf VARCHAR2(2000);
  rows   INTEGER;
BEGIN
  curs   := dbms_sql.open_cursor;
  sqlbuf := 'select substr(RawToHex(sys_op_guid()),0,32) from dual';
  dbms_sql.parse(curs, sqlbuf, dbms_sql.v7);
  dbms_sql.define_column(curs, 1, guid, 32);
  rows := dbms_sql.execute(curs);
  rows := dbms_sql.fetch_rows(curs);
  dbms_sql.column_value(curs, 1, guid);
  dbms_sql.close_cursor(curs);
  fnd_random_pkg.init(7);
  fnd_random_pkg.seed(to_number(TO_CHAR(sysdate, 'JSSSSS')), 10, FALSE);
  rnd_dt:=SUBSTR((TO_CHAR(fnd_random_pkg.get_next)||TO_CHAR(fnd_random_pkg.get_next)||TO_CHAR(fnd_random_pkg.get_next)||TO_CHAR(fnd_random_pkg.get_next)),0,32);
  RETURN guid||rnd_dt;
END;

/* get_platform_code
**
** This is a private API that Returns the platform_code based on the
** lookup_type 'PLATFORM' defined in afoamluplt.ldt. This is called by
** insert_server and update_server.
**
** Testcase to test API:
set serverout on
begin
  dbms_output.put_line('Solaris = '||
    FND_APP_SERVER_PKG.get_platform_code('Solaris'));
  dbms_output.put_line('HP-UX = '||
    FND_APP_SERVER_PKG.get_platform_code('HP-UX'));
  dbms_output.put_line('UNIX Alpha = '||
    FND_APP_SERVER_PKG.get_platform_code('UNIX Alpha'));
  dbms_output.put_line('IBM AIX = '||
    FND_APP_SERVER_PKG.get_platform_code('IBM AIX'));
  dbms_output.put_line('Intel_Solaris = '||
    FND_APP_SERVER_PKG.get_platform_code('Intel_Solaris'));
  dbms_output.put_line('Linux = '||
    FND_APP_SERVER_PKG.get_platform_code('Linux'));
  dbms_output.put_line('Windows NT = '||
    FND_APP_SERVER_PKG.get_platform_code('Windows NT'));
  dbms_output.put_line('Others = '||
    FND_APP_SERVER_PKG.get_platform_code('Others'));
  -- R12 only
  dbms_output.put_line('Others = '||
    FND_APP_SERVER_PKG.get_platform_code('LINUX_X86-64'));
end;

Output should be similar to this:

Solaris = 453 (23 for R12)
HP-UX = 2 (59 for R12)
UNIX Alpha = 87
IBM AIX = 319 (212 for R12)
Intel_Solaris = 173
Linux = 46
Windows NT = 912
Others = 100000
LINUX_X86-64 = 226 (R12)
*/
FUNCTION get_platform_code(p_platform IN VARCHAR2)
  RETURN VARCHAR2
IS
  l_platform_code VARCHAR2(30);
BEGIN
  -- The FND_LOOKUP_VALUES.TAG column was updated for the PLATFORM lookup_type
  -- to support the p_platform values derived from
  -- SystemCheck.DetectPlatform().
  --
  -- The following query was modeled not to violate the FND_LOOKUP_VALUES_U1
  -- unique index. See bug 5723530.
  SELECT lookup_code
  INTO l_platform_code
  FROM fnd_lookup_values
  WHERE lookup_type       = 'PLATFORM'
  AND tag                 = p_platform
  AND language            = userenv('LANG')
  AND view_application_id = 0
  AND security_group_id   = 0;

  RETURN l_platform_code;
EXCEPTION
  WHEN no_data_found THEN
    raise no_data_found;
END;

/* node_name_exists
**
** Check to see if the node_name already exists in FND_NODES
*/
FUNCTION node_name_exists(p_node_name IN VARCHAR2)
  RETURN BOOLEAN
IS
  kount       NUMBER       := 0;
  l_node_name VARCHAR2(30) := UPPER(p_node_name);
BEGIN
  SELECT COUNT(*)
  INTO kount
  FROM fnd_nodes
  WHERE upper(node_name) = l_node_name;

  IF kount > 0 THEN
    RETURN true;
  ELSE
    RETURN false;
  END IF;
END;

/* desktop_node_exists
**
** Check to see if the node_name already exists in FND_NODES where the
** support_* columns = 'N'.
*/
FUNCTION desktop_node_exists(p_node_name IN OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN
IS
  kount       NUMBER       := 0;
  l_node_name VARCHAR2(30) := UPPER(p_node_name);
BEGIN
  -- Check if a node_name exists with support_* = 'N' and server_address <> '*'
  SELECT COUNT(*)
  INTO kount
  FROM fnd_nodes
  WHERE upper(node_name) = l_node_name
  AND SUPPORT_CP         = 'N'
  AND SUPPORT_FORMS      = 'N'
  AND SUPPORT_WEB        = 'N'
  AND SUPPORT_ADMIN      = 'N'
  AND SUPPORT_DB         = 'N'
  AND PLATFORM_CODE      = '100000'
  AND ((SERVER_ADDRESS  IS NOT NULL
  AND SERVER_ADDRESS    <> '*')
  OR SERVER_ADDRESS     IS NULL);

  IF kount > 0 THEN
    RETURN true;
  ELSE
    RETURN false;
  END IF;
END;

/* server_address_exists
**
** Check to see if the server_address already exists in FND_NODES
*/
FUNCTION server_address_exists(p_address IN VARCHAR2)
  RETURN BOOLEAN
IS
  kount NUMBER := 0;
BEGIN
  SELECT COUNT(*)
  INTO kount
  FROM fnd_nodes
  WHERE server_address = p_address;

  IF kount > 0 THEN
    RETURN true;
  ELSE
    RETURN false;
  END IF;
END;

/* get_server_id
**
** Returns the server_id given a unique node_name or server_address. This API is
** biased towards the unique node_name. The server_address is used only when the
** node_name cannot be used. server_id can be null if the node has been
** deleted" using delete_server or delete_desktop_server.
*/
FUNCTION get_server_id
  (
    p_node_name IN VARCHAR2 DEFAULT NULL,
    p_address   IN VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2
IS
  l_server_id fnd_nodes.server_id%TYPE := NULL;
  l_node_name VARCHAR2(30)             := UPPER(p_node_name);
BEGIN
  -- Node name is unique, so if node name is passed in, that is what the code
  -- uses to obtain the server_id.
  IF l_node_name IS NOT NULL AND node_name_exists(l_node_name) THEN
    SELECT server_id
    INTO l_server_id
    FROM fnd_nodes
    WHERE upper(node_name) = l_node_name;
    -- Server address should be unique but since it is nullable in FND_NODES,
    -- it may not be the best condition to use to derive a unique server_id.
    -- However, if the server_address exists, return one of the server_ids.
  elsif p_address IS NOT NULL AND server_address_exists(p_address) THEN
    SELECT server_id
    INTO l_server_id
    FROM fnd_nodes
    WHERE server_address = p_address
    AND server_id IS NOT NULL
    AND rownum < 2;
  END IF;

  RETURN l_server_id;
END;

/* get_server_address
**
** Returns the server_address given a unique node_name. server_address can be
** null for desktop nodes.
**
*/
FUNCTION get_server_address(p_node_name IN VARCHAR2)
  RETURN VARCHAR2
IS
  l_server_address fnd_nodes.server_address%TYPE := NULL;
  l_node_name VARCHAR2(30)                       := UPPER(p_node_name);
BEGIN
  IF node_name_exists(l_node_name)THEN
    SELECT server_address
    INTO l_server_address
    FROM fnd_nodes
    WHERE upper(node_name) = l_node_name;
  END IF;

  RETURN l_server_address;
END;

/* get_node_name
**
** Returns a node_name given a server_address. server_address is nullable and
** has no unique constraint, so it is possible to have multiple nodes having the
** same server_address. In such a case, the API will return one of the
** node_name(s).
**
*/
FUNCTION get_node_name(p_address IN VARCHAR2)
  RETURN VARCHAR2
IS
  l_node_name fnd_nodes.node_name%TYPE := NULL;
BEGIN
  IF server_address_exists(p_address)THEN
    SELECT node_name
    INTO l_node_name
    FROM fnd_nodes
    WHERE server_address = p_address
    AND node_name IS NOT NULL
    AND rownum < 2;
  END IF;

  RETURN l_node_name;
END;

/* insert_server
**
** Inserts information for a new Application Server. The function
** create_server_id must be called to generate a valid id prior to
** calling this api. This is called by AdminAppServer.changeServerInDB().
**
** FND_APP_SERVER_PKG.INSERT_SERVER is a wrapper to
** FND_CONCURRENT.REGISTER_NODE.
*/
PROCEDURE insert_server
  (
    p_server_id               IN OUT NOCOPY VARCHAR2,
    p_address                 IN VARCHAR2,
    p_node_name               IN VARCHAR2,
    p_description             IN VARCHAR2 DEFAULT NULL,
    p_webhost                 IN VARCHAR2 DEFAULT NULL,
    p_platform_code           IN VARCHAR2 DEFAULT NULL,
    p_support_cp              IN VARCHAR2 DEFAULT NULL,
    p_support_forms           IN VARCHAR2 DEFAULT NULL,
    p_support_web             IN VARCHAR2 DEFAULT NULL,
    p_support_admin           IN VARCHAR2 DEFAULT NULL,
    p_support_db              IN VARCHAR2 DEFAULT NULL)
IS
  kount           NUMBER       := 0;
  curr_node_id    NUMBER       := 0;
  curr_node_name  VARCHAR2(30) := NULL;
  l_node_name     VARCHAR2(30) := UPPER(p_node_name);
  l_platform_code VARCHAR2(30);
BEGIN
  -- Bug 3736714: Platform Code is required by FND_NODES to register a
  -- node. AdminAppServer has been modified to support platform code.
  l_platform_code := get_platform_code(p_platform_code);

  -- If a desktop node is being inserted using insert_server, then redirect to
  -- insert_desktop_server. A desktop node has the support_* columns = 'N' and
  -- p_address <> '*'.
  IF (p_support_cp = 'N' AND p_support_forms = 'N' AND p_support_web = 'N' AND
      p_support_admin = 'N' AND p_support_db = 'N') AND ((p_address IS NOT NULL
      AND p_address <> '*') OR p_address IS NULL) THEN
    insert_desktop_server(l_node_name, p_server_id, p_address, p_description);
  ELSE
    -- If node exists and
    IF server_address_exists(p_address) THEN
      /* Added for Bug 3736714 to clean up entries that have node names which
      ** are not fully qualified hostnames.
      */
      -- If platform_code passed in is UNIX Alpha
      IF (l_platform_code = '87') THEN
        -- Then, get the node_id and node_name of the existing node
        -- entry.
        SELECT node_id, node_name
        INTO curr_node_id, curr_node_name
        FROM fnd_nodes
        WHERE server_address = p_address;

        -- If the current node_name is not a fully qualified hostname
        IF INSTR(curr_node_name, '.') = 0 THEN
          -- Insert the new node using fnd_concurrent.register_node
          FND_CONCURRENT.REGISTER_NODE(
            name => l_node_name,
            platform_id => to_number(l_platform_code),
            forms_tier => p_support_forms,
            cp_tier => p_support_cp,
            web_tier => p_support_web,
            admin_tier => p_support_admin,
            p_server_id => p_server_id,
            p_address => p_address,
            p_description => p_description,
            db_tier => p_support_db);

          -- Update the old node with the correct platform and null
          -- out server_id and server_address so that the node does
          -- not get referenced again.
          UPDATE FND_NODES
          SET PLATFORM_CODE = '87',
            SERVER_ADDRESS  = NULL,
            SERVER_ID       = NULL
          WHERE NODE_ID     = curr_node_id;

          -- Added for Bug 3292353.
          SELECT COUNT(*)
          INTO kount
          FROM fnd_nodes
          WHERE UPPER(node_name) = l_node_name;

          -- Since fnd_concurrent.register_node() does not handle
          -- the hostname at this time, it will be manually inserted
          -- using the update_server API IF the node was properly
          -- inserted using fnd_concurrent.register_node().
          IF kount > 0 THEN
            -- If webhost was provided.
            IF (p_webhost IS NOT NULL) THEN
              update_server(p_server_id, p_address, p_description, p_webhost);
            END IF;
          END IF; -- kount > 0
        END IF;   -- INSTR(curr_node_name, '.') = 0

      ELSE
        /* Node already exists.  It should not be inserted again, just
           updated.*/
        update_server(p_server_id, p_address, p_description, p_webhost,
          p_platform_code);
      END IF; -- (l_platform_code = '87')

    ELSE /* Node does not exist, the server will be inserted. */

      -- Check if p_node_name is a fully qualified hostname with domain.
      -- FND_NODES.NODE_NAME should only have hostname if platform is not
      -- UNIX Alpha.
      IF (l_platform_code <> '87' AND INSTR(p_node_name, '.') <> 0) THEN
        -- The hostname should be the beginning of the string up until
        -- the first period.  FND_NODES.NODE_NAME is stored in
        -- UPPERCASE.
        l_node_name := UPPER(SUBSTR(p_node_name, 0,
          INSTR(p_node_name, '.') - 1));
      END IF;

      -- Insert the node using fnd_concurrent.register_node
      FND_CONCURRENT.REGISTER_NODE(
        name => l_node_name,
        platform_id => to_number(l_platform_code),
        forms_tier => p_support_forms,
        cp_tier => p_support_cp,
        web_tier => p_support_web,
        admin_tier => p_support_admin,
        p_server_id => p_server_id,
        p_address => p_address,
        p_description => p_description,
        db_tier => p_support_db);

      -- Added for Bug 3292353.
      SELECT COUNT(*)
      INTO kount
      FROM fnd_nodes
      WHERE UPPER(node_name) = l_node_name;

      -- Since fnd_concurrent.register_node() does not handle the hostname
      -- at this time, it will be manually inserted using the
      -- update_server API IF the node was properly inserted using
      -- fnd_concurrent.register_node().
      IF kount > 0 THEN
        -- If webhost was provided, update only the servers, not desktop
        -- nodes.
        IF (p_webhost IS NOT NULL) AND (l_platform_code <> '100000') THEN
          update_server(p_server_id, p_address, p_description, p_webhost);
        END IF;
      ELSE -- kount = 0
        -- Bug 5279502: DESKTOP NODE SUPPORT IN FND_APP_SERVER_PKG
        -- Added this for better error handling.
        -- If for any reason that the FND_CONCURRENT.REGISTER_NODE() fails
        -- to add the node, no_data_found should be raised to signal the
        -- failure to add the node_name.  If the node existed prior to
        -- calling FND_CONCURRENT.REGISTER_NODE(), kount should still be
        -- > 0.
        RAISE no_data_found;
      END IF;
    END IF; -- kount > 0
  END IF;   -- desktop node
END insert_server;

/* delete_server
**
** This procedure used to remove an Application Server row from the database.
** Due to the migration of FND_APPLICATION_SERVERS to FND_NODES,
** fnd_nodes.server_id is nulled out instead in order to preserve the
** node_name and avoid dangling references to the node_name. This is called by
** AdminAppServer.delSvrFromDB().
*/
PROCEDURE delete_server(p_address IN VARCHAR2)
IS
BEGIN
  UPDATE fnd_nodes
  SET server_id = NULL
  WHERE server_address = p_address;
EXCEPTION
  WHEN no_data_found THEN
    raise no_data_found;
END;

/* update_server
**
** This procedure should only be used for updating Application Server Nodes.
** The server_id, description, host and domain are updated if they are not
** NULL. If a new server_id is required, the create_server_id function should
** be called prior to this. This is called by
** AdminAppServer.changeServerInDB().
*/
PROCEDURE update_server
  (
    p_server_id   IN VARCHAR2 DEFAULT NULL,
    p_address     IN VARCHAR2,
    p_description IN VARCHAR2 DEFAULT NULL,
    p_webhost     IN VARCHAR2 DEFAULT NULL,
    p_platform    IN VARCHAR2 DEFAULT NULL)
IS
  l_node_name     VARCHAR2(30);
  l_support_cp    VARCHAR2(1);
  l_support_forms VARCHAR2(1);
  l_support_web   VARCHAR2(1);
  l_support_admin VARCHAR2(1);
  l_support_db    VARCHAR2(1);
  l_platform      VARCHAR2(30);
  l_platform2     VARCHAR2(30);

BEGIN
  /*  Bug 5279502: DESKTOP NODE SUPPORT IN FND_APP_SERVER_PKG */
  -- The API should not allow updates of Desktop Nodes.  This query obtains
  -- the value of columns that determines a Desktop Node.

  SELECT NODE_NAME,
    SUPPORT_CP,
    SUPPORT_FORMS,
    SUPPORT_WEB,
    SUPPORT_ADMIN,
    SUPPORT_DB,
    PLATFORM_CODE
  INTO l_node_name,
    l_support_cp,
    l_support_forms,
    l_support_web,
    l_support_admin,
    l_support_db,
    l_platform
  FROM fnd_nodes
  WHERE server_address = p_address;

  IF SQL%notfound THEN
    RAISE no_data_found;
  END IF;

  -- Desktop Nodes will have the SUPPORT_* columns explicitly set to 'N' and
  -- PLATFORM_CODE = '100000' when registered.  If any of the column values
  -- are not what a Desktop should have, then it can be processed in this API
  IF (((l_support_cp  = 'Y' OR l_support_forms = 'Y' OR l_support_web = 'Y' OR
    l_support_admin = 'Y' OR l_support_db = 'Y') AND (p_address IS NOT NULL))
  -- Bug 9688017: added for Authentication row
    OR (p_address = '*')) THEN

    IF(l_node_name <> UPPER(l_node_name)) THEN
      UPDATE fnd_nodes
      SET node_name        = UPPER(l_node_name)
      WHERE server_address = p_address;
    END IF;

    IF(p_server_id IS NOT NULL) THEN
      UPDATE fnd_nodes
      SET server_id = p_server_id
      WHERE server_address = p_address;
    END IF;

    IF(p_description IS NOT NULL) THEN
      UPDATE fnd_nodes
      SET description      = p_description
      WHERE server_address = p_address;
    END IF;

    -- Added for Bug 3292353.  ICX code will be calling FND_NODES.WEBHOST so
    -- there needs to be a way to populate/update the column.  This may
    -- later be changed to use CP APIs.
    IF(p_webhost IS NOT NULL) THEN
      UPDATE fnd_nodes
      SET webhost = p_webhost
      WHERE server_address = p_address;
    END IF;

    -- Added for Bug 3736714.  Since AdminAppServer derives the platform and
    -- only AdminAppServer calls FND_APP_SERVER_PKG, then if a platform is
    -- passed in, the platform_code is likely correct and the platform_code
    -- for the node needs to be updated.
    IF (p_platform IS NOT NULL) THEN
      l_platform2  := get_platform_code(p_platform);
      UPDATE fnd_nodes
      SET PLATFORM_CODE    = l_platform2
      WHERE server_address = p_address;
    END IF;

    /*
    Bug 3773424:AUTHENTICATION NODE HAS NO VALUES FOR FND_NODES.SUPPORT_*
    COLUMNS.  A system alert is being logged stating that it "Could not
    contact Service Manager FNDSM_AUTHENTICATION_*".  It seems that the
    ICM attempts to tnsping all remote Service Managers using the query:

      SELECT NODE_NAME, STATUS, NODE_MODE
      FROM FND_NODES
      WHERE NOT (SUPPORT_CP = 'N' AND
      SUPPORT_WEB = 'N' AND SUPPORT_FORMS = 'N' AND
      SUPPORT_ADMIN = 'N' AND SUPPORT_CP is NOT NULL AND
      SUPPORT_WEB is NOT NULL AND
      SUPPORT_ADMIN is NOT NULL AND SUPPORT_FORMS is NOT NULL)

    Since the AUTHENTICATION row is inserted without these SUPPORT_*
    columns, the system alert gets logged.  This IF block has been added
    to check whether those columns have a value for the AUTHENTICATION row.
    It the column(s) have a null value, 'N' is explicitly set for the
    applicable SUPPORT_* column.
    */
    IF (p_address = '*') THEN

      IF (l_support_cp IS NULL) THEN
        UPDATE fnd_nodes
        SET SUPPORT_CP = 'N'
        WHERE server_address = p_address;
      END IF;

      IF (l_support_forms IS NULL) THEN
        UPDATE fnd_nodes
        SET SUPPORT_FORMS = 'N'
        WHERE server_address = p_address;
      END IF;

      IF (l_support_web IS NULL) THEN
        UPDATE fnd_nodes
        SET SUPPORT_WEB = 'N'
        WHERE server_address = p_address;
      END IF;

      IF (l_support_admin IS NULL) THEN
        UPDATE fnd_nodes
        SET SUPPORT_ADMIN = 'N'
        WHERE server_address = p_address;
      END IF;

      IF (l_support_db IS NULL) THEN
        UPDATE fnd_nodes
        SET SUPPORT_DB = 'N'
        WHERE server_address = p_address;
      END IF;

      /* Bug 3736714 - Need to ensure that AUTHENTICATION row has the right
      ** platform.
      */
      IF (p_platform IS NOT NULL) THEN
        l_platform2  := get_platform_code(p_platform);
        IF (l_platform <> l_platform2) THEN
          UPDATE fnd_nodes
          SET PLATFORM_CODE = l_platform2
          WHERE server_address = p_address;
        END IF;
      END IF;
    END IF;
  END IF; -- IF THEN for Desktop Node
END update_server;

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
** This is called by AdminAppServer.setAuthentication().and ((SERVER_ADDRESS
** is not NULL and SERVER_ADDRESS <> '*') or SERVER_ADDRESS is null);
**
** Bug 3736714: the p_platform argument was added so that the authentication
** row can be added with the correct platform.  The platform is determined in
** AdminAppServer.java.
*/
PROCEDURE authenticate
  (
    p_value        IN OUT NOCOPY VARCHAR2,
    p_platformcode IN VARCHAR2 DEFAULT NULL )
IS
BEGIN
  /* Bug 3736714 - The AUTHENTICATION row should be seeded with the correct
  ** platform even if it isn't technically a node.
  */
  update_server(
    p_server_id => p_value,
    p_address => '*',
    p_description => 'Authentication Value',
    p_platform => p_platformcode);
EXCEPTION
  WHEN no_data_found THEN
    /*
    insert_server(p_value,'*','AUTHENTICATION','Authentication value');

    Bug 3773424:AUTHENTICATION NODE HAS NO VALUES FOR FND_NODES.SUPPORT_*
    COLUMNS.  A system alert is being logged stating that it "Could not
    contact Service Manager FNDSM_AUTHENTICATION_*".  It seems that the
    ICM attempts to tnsping all remote Service Managers using the query:

      SELECT NODE_NAME, STATUS, NODE_MODE
      FROM FND_NODES
      WHERE NOT (SUPPORT_CP = 'N' AND
      SUPPORT_WEB = 'N' AND SUPPORT_FORMS = 'N' AND
      SUPPORT_ADMIN = 'N' AND SUPPORT_CP is NOT NULL AND
      SUPPORT_WEB is NOT NULL AND
      SUPPORT_ADMIN is NOT NULL AND SUPPORT_FORMS is NOT NULL)

    Since the AUTHENTICATION row is inserted without these SUPPORT_*
    columns, the system alert gets logged.  The call to insert_server has
    been modified to explicitly set the SUPPORT_* with a value of 'N'.
    */
    insert_server (
      p_server_id => p_value,
      p_address => '*',
      p_node_name => 'AUTHENTICATION',
      p_description => 'Authentication value',
      p_platform_code => p_platformcode,
      p_support_cp => 'N',
      p_support_forms => 'N',
      p_support_web => 'N',
      p_support_admin => 'N',
      p_support_db => 'N');
END;

/* insert_desktop_server
**
** This API is used for Desktop Nodes only.
** It calls insert_server and sets all the SUPPORT_* collumns to 'N' and the
** PLATFORM_CODE to 'Others'.  It also places 'Desktop Node' as the description
** if NULL was passed.
** A server_id is passed into this API from the caller. This API does not
** check whether the server_id exists because the caller would have already
** checked whether it exists or not.
*/
PROCEDURE insert_desktop_server
  (
    p_node_name            IN VARCHAR2,
    p_server_id            IN OUT NOCOPY VARCHAR2,
    p_address              IN VARCHAR2 DEFAULT NULL,
    p_description          IN VARCHAR2 DEFAULT NULL)
IS
  l_node_name fnd_nodes.node_name%TYPE := UPPER(p_node_name);
  l_node_name_from_address fnd_nodes.node_name%TYPE := NULL;
  l_server_id fnd_nodes.server_id%TYPE := NULL;
  l_server_address fnd_nodes.server_address%TYPE;
BEGIN
  /*  Bug 5279502: DESKTOP NODE SUPPORT IN FND_APP_SERVER_PKG */
  /*===============+
  | Desktop Node  |
  ================*/
  -- If the node_name is used by a desktop node, then just update the
  -- desktop node record.
  IF desktop_node_exists(l_node_name) THEN
    update_desktop_server(l_node_name, p_server_id, p_address, p_description);
  ELSE

    -- Case 1. node_name does not exist in FND_NODES
    --         and server_address does not exist or is null.
    -- Action: register desktop_node using FND_CONCURRENT.REGISTER_NODE
    IF (NOT node_name_exists(l_node_name) AND ((p_address IS NOT NULL AND
      NOT server_address_exists(p_address)) OR p_address IS NULL)) THEN
      -- Insert the node using fnd_concurrent.register_node
      FND_CONCURRENT.REGISTER_NODE(
        name => l_node_name,
        platform_id => to_number(get_platform_code('Others')),
        forms_tier => 'N',
        cp_tier => 'N',
        web_tier => 'N',
        admin_tier => 'N',
        p_server_id => NVL(insert_desktop_server.p_server_id,
          FND_APP_SERVER_PKG.CREATE_SERVER_ID),
        p_address => insert_desktop_server.p_address,
        p_description => NVL(insert_desktop_server.p_description,
          'Desktop Node'),
        db_tier => 'N');

      -- Case 2. node_name exists in FND_NODES
      -- Action: return server_id of node. if server_id is null, then:
      --         a. use server_id passed in,
      --         b. update record and convert node into desktop_node
      --         c. return server_id of node.
    ELSIF node_name_exists(l_node_name) THEN
      -- node_name exists, retrieve the server_id of existing node and return
      -- the server_id to the desktop node, so that it builds the dbc file with
      -- that server_id.
      l_server_id := get_server_id(l_node_name, NULL);
      -- If server_id is null, then the node was deleted using
      -- delete_server. So, the node is currently a deleted server_node.
      IF l_server_id IS NULL THEN
        -- Use the server_id passed in and convert the deleted server node into
        -- a desktop node. Note that the server address provided is not updated
        -- for the desktop node, primarily because the server_node usually has
        -- the right server_address and there's no need to change.
        UPDATE fnd_nodes
        SET server_id          = insert_desktop_server.p_server_id,
          support_forms        = 'N',
          support_cp           = 'N',
          support_web          = 'N',
          support_admin        = 'N',
          support_db           = 'N',
          platform_code        = '100000',
          description          = 'Desktop Node, converted from Server'
        WHERE upper(node_name) = l_node_name
        AND ((SERVER_ADDRESS  IS NOT NULL
        AND SERVER_ADDRESS    <> '*')
        OR SERVER_ADDRESS     IS NULL);
      ELSE
        p_server_id := l_server_id;
      END IF;

      -- Case 3. node_name does not exist BUT server_address exists.
      -- Action: return server_id of one of the nodes. If server_id is null, then:
      --	       a. use server_id passed in
      --	       b. update record and convert node into desktop_node
      --	       c. return server_id of node.
    ELSIF (NOT node_name_exists(l_node_name) AND (p_address IS NOT NULL
      AND server_address_exists(p_address))) THEN
      -- node_name does not exist but server_address does, so retrieve the
      -- server_id of existing node and return the server_id to the desktop node,
      -- so that it builds the dbc file with that server_id.
      l_server_id := get_server_id(NULL, p_address);

      -- If server_id is null, then the node was deleted using
      -- delete_server. So, the node is currently a deleted server_node.
      IF l_server_id IS NULL THEN

        -- Get the node_name of a node using server_address to use as the
        -- condition to update the record. Since it is possible to have
        -- multiple nodes with the same server_address and the server_id
        -- returned for the server_address provided, we can convert one of the
        -- nodes by obtaining a unique node_name.
        l_node_name_from_address := get_node_name(p_address);

        -- Use the server_id passed in and convert the deleted server node into
        -- a desktop node.
        UPDATE fnd_nodes
        SET server_id          = insert_desktop_server.p_server_id,
          support_forms        = 'N',
          support_cp           = 'N',
          support_web          = 'N',
          support_admin        = 'N',
          support_db           = 'N',
          platform_code        = '100000',
          description          = 'Desktop Node, converted from Server'
        WHERE upper(node_name) = l_node_name_from_address
        AND ((SERVER_ADDRESS  IS NOT NULL
        AND SERVER_ADDRESS    <> '*')
        OR SERVER_ADDRESS     IS NULL);
      ELSE
        p_server_id := l_server_id;
      END IF;
    END IF;
  END IF;
END insert_desktop_server;

/* update_desktop_server
**
** This API is used for Desktop Nodes only.
** Update the FND_NODES row associated with p_node_name with the specified
** values for server_id, address, and description. If NULLs are passed, do not
** update. update_server cannot be used here because it uses p_address as the
** where condition.
*/
PROCEDURE update_desktop_server
  (
    p_node_name            IN VARCHAR2,
    p_server_id            IN VARCHAR2 DEFAULT NULL,
    p_address              IN VARCHAR2 DEFAULT NULL,
    p_description          IN VARCHAR2 DEFAULT NULL)
IS
  kount       NUMBER       := 0;
  l_node_name fnd_nodes.node_name%TYPE := UPPER(p_node_name);
BEGIN
  -- If desktop node exists, proceed to update the desktop node.
  -- If not a desktop node, do nothing. A desktop node maybe using the
  -- server_id of a server node. A desktop node cannot update a server node's
  -- data.
  IF desktop_node_exists(l_node_name) THEN
    -- If server_id is provided, update using the node_name as condition.
    IF(p_server_id IS NOT NULL) THEN
      UPDATE fnd_nodes
      SET server_id          = p_server_id
      WHERE upper(node_name) = l_node_name
      AND support_cp         = 'N'
      AND support_forms      = 'N'
      AND support_web        = 'N'
      AND support_admin      = 'N'
      AND support_db         = 'N'
      AND platform_code      = '100000'
      AND ((SERVER_ADDRESS  IS NOT NULL
      AND SERVER_ADDRESS    <> '*')
      OR SERVER_ADDRESS     IS NULL);
    END IF;

    -- If a server_address is given, update using the node_name as
    -- condition. server_address cannot be equal to '*' for a desktop node.
    -- The (p_address <> '*') condition is intentionally left redundant.
    IF (p_address IS NOT NULL) AND (p_address <> '*')
      AND NOT (server_address_exists(p_address)) THEN
      UPDATE fnd_nodes
      SET server_address     = p_address
      WHERE upper(node_name) = l_node_name
      AND support_cp         = 'N'
      AND support_forms      = 'N'
      AND support_web        = 'N'
      AND support_admin      = 'N'
      AND support_db         = 'N'
      AND platform_code      = '100000'
      AND ((SERVER_ADDRESS  IS NOT NULL
      AND SERVER_ADDRESS    <> '*')
      OR SERVER_ADDRESS     IS NULL);
    END IF;

    -- If a description is given, update using the node_name as condition.
    -- Default value is 'Desktop Node', per insert_desktop_server().
    IF(p_description IS NOT NULL) THEN
      UPDATE fnd_nodes
      SET description        = p_description
      WHERE upper(node_name) = l_node_name
      AND support_cp         = 'N'
      AND support_forms      = 'N'
      AND support_web        = 'N'
      AND support_admin      = 'N'
      AND support_db         = 'N'
      AND platform_code      = '100000'
      AND ((SERVER_ADDRESS  IS NOT NULL
      AND SERVER_ADDRESS    <> '*')
      OR SERVER_ADDRESS     IS NULL);
    END IF;
  END IF;
END update_desktop_server;

/* delete_desktop_server
**
** This API is used for Desktop Nodes only.
** Similar to delete_server, server_id is NULLed out, the row is not physically
** deleted.
*/
PROCEDURE delete_desktop_server(p_node_name IN VARCHAR2)
IS
  l_node_name fnd_nodes.node_name%TYPE := UPPER(p_node_name);
BEGIN
  -- If desktop node exists, proceed
  -- If not a desktop node, do nothing. A desktop node maybe using the
  -- server_id of a server node. A desktop node cannot update a server node's
  -- data.
  IF desktop_node_exists(l_node_name) THEN
    UPDATE fnd_nodes
    SET server_id         = NULL
    WHERE node_name       = l_node_name
    AND support_cp        = 'N'
    AND support_forms     = 'N'
    AND support_web       = 'N'
    AND support_admin     = 'N'
    AND support_db        = 'N'
    AND platform_code     = '100000'
    AND ((SERVER_ADDRESS IS NOT NULL
    AND SERVER_ADDRESS   <> '*')
    OR SERVER_ADDRESS    IS NULL);
  END IF;
END delete_desktop_server;

END fnd_app_server_pkg;

/
