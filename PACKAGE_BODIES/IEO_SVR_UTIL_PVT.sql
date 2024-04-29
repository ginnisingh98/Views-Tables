--------------------------------------------------------
--  DDL for Package Body IEO_SVR_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEO_SVR_UTIL_PVT" AS
/* $Header: IEOSVUVB.pls 115.25 2004/04/27 00:56:03 edwang ship $ */

G_PKG_NAME 	CONSTANT VARCHAR2(30) := 'IEO_SVR_UTIL_PVT';

-- Sub-Program Units
-- Entry point routine for apps to retrieve The Load Specs for a specific type Of Server:
PROCEDURE GET_SVR_TYPE_LOAD_INFO
  (P_SERVER_TYPE_UUID   IN VARCHAR2
  )
  AS
  ty_major_load_max IEO_SVR_TYPES_B.MAX_MAJOR_LOAD_FACTOR%TYPE;
  ty_minor_load_max IEO_SVR_TYPES_B.MAX_MINOR_LOAD_FACTOR%TYPE;
  l_refresh_rate_secs  NUMBER(5);

BEGIN

  IF ((P_SERVER_TYPE_UUID IS NULL)) THEN
    raise_application_error
      (-20000
      ,'P_SERVER_TYPE_UUID cannot be NULL.'
      ,TRUE );
  END IF;

  SELECT
  --  DISTINCT
      type_table.MAX_MAJOR_LOAD_FACTOR,
      type_table.MAX_MINOR_LOAD_FACTOR,
      (type_table.RT_REFRESH_RATE * 60)
    INTO
      ty_major_load_max,
      ty_minor_load_max,
      l_refresh_rate_secs
    FROM
      IEO_SVR_TYPES_B type_table
    WHERE
      (type_table.TYPE_UUID = P_SERVER_TYPE_UUID) AND
      (ROWNUM <= 1);

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END GET_SVR_TYPE_LOAD_INFO;


-- Recursive routine to get all the nested groups within a given group
PROCEDURE GET_ALL_SUBGROUPS
  (P_GROUP_ID       IN  NUMBER
  ,X_GROUP_ID_LIST  OUT NOCOPY SYSTEM.IEO_SVR_ID_ARRAY
  )
  AS
    CURSOR c1 is
      SELECT
        SERVER_GROUP_ID
      FROM
        IEO_SVR_GROUPS
      WHERE
        GROUP_GROUP_ID = P_GROUP_ID;

    counter NUMBER := 1;
    sub_counter NUMBER := 1;
    v_all_group_ids SYSTEM.IEO_SVR_ID_ARRAY:= SYSTEM.IEO_SVR_ID_ARRAY(
                                       -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
                                       -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
                                       -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
                                       -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
                                       -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);
    v_tmp_group_ids SYSTEM.IEO_SVR_ID_ARRAY:= SYSTEM.IEO_SVR_ID_ARRAY(
                                       -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
                                       -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
                                       -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
                                       -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
                                       -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);

BEGIN

  FOR c1_rec IN c1
  LOOP
    v_all_group_ids(counter) := c1_rec.server_group_id;

    IF (c1%NOTFOUND) THEN
      EXIT;
    END IF;

    GET_ALL_SUBGROUPS(v_all_group_ids(c1%ROWCOUNT), v_tmp_group_ids);
    counter := counter + 1;

    WHILE (v_tmp_group_ids IS NOT NULL AND v_tmp_group_ids(sub_counter) >= 0)
    LOOP
      v_all_group_ids(counter) := v_tmp_group_ids(sub_counter);
      counter := counter + 1;
      sub_counter := sub_counter + 1;
    END LOOP; -- Inner WHILE
  END LOOP; -- Outer FOR

  X_GROUP_ID_LIST  := v_all_group_ids;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    X_GROUP_ID_LIST := NULL;
  WHEN OTHERS THEN
    RAISE;

END GET_ALL_SUBGROUPS;


-- Internal utility function to retrieve all the Group IDs A Given server is eligible
-- to use.  NOTE: Groups may be subsets of other groups therefore a
-- server may connect to any server within his group AND ALL subsets.
PROCEDURE LOCATE_ALL_GROUPS
  (P_SERVER_ID_LOOKING  IN  NUMBER
  ,X_GROUP_ID_LIST      OUT NOCOPY SYSTEM.IEO_SVR_ID_ARRAY
  )
  AS
    counter NUMBER := 1;
    sub_counter NUMBER := 1;
    v_all_group_ids SYSTEM.IEO_SVR_ID_ARRAY:= SYSTEM.IEO_SVR_ID_ARRAY(
                                       -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
                                       -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
                                       -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
                                       -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
                                       -1, -1, -1, -1, -1, -1, -1, -1, -1, -1);

    v_tmp_group_ids SYSTEM.IEO_SVR_ID_ARRAY;

BEGIN

  -- First get the group our server is using:
  SELECT
    DISTINCT
      NVL( svr_table.USING_SVR_GROUP_ID, svr_table.MEMBER_SVR_GROUP_ID )
    INTO
      v_all_group_ids(counter)
    FROM
      IEO_SVR_SERVERS svr_table
    WHERE
      (svr_table.SERVER_ID = P_SERVER_ID_LOOKING) AND
      (ROWNUM <= 1);

  -- Now get all sub groups our server may access:
  GET_ALL_SUBGROUPS(v_all_group_ids(counter), v_tmp_group_ids);

  counter := counter + 1;

  WHILE (v_tmp_group_ids IS NOT NULL AND v_tmp_group_ids(sub_counter) >= 0)
  LOOP
    v_all_group_ids(counter) := v_tmp_group_ids(sub_counter);
    counter := counter + 1;
    sub_counter := sub_counter + 1;
  END LOOP;

  X_GROUP_ID_LIST := v_all_group_ids;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    X_GROUP_ID_LIST := NULL;

  WHEN OTHERS THEN
    RAISE;

END LOCATE_ALL_GROUPS;

-- Internal utility function to get connection information for ALL servers
-- (of a specified type) within A single given group.
PROCEDURE GET_ALL_SERVERS_IN_GROUP
  (P_GROUP_ID           IN  NUMBER
  ,P_SERVER_TYPE_UUID   IN  VARCHAR2
  ,P_WIRE_PROTOCOL      IN  VARCHAR2
  ,P_COMP_DEF_NAME      IN  VARCHAR2
  ,P_COMP_DEF_VERSION   IN  NUMBER
  ,P_COMP_DEF_IMPL      IN  VARCHAR2
  ,P_COMP_NAME          IN  VARCHAR2
  ,X_SVR_INFO_LIST      OUT NOCOPY SYSTEM.IEO_SVR_INFO_ARRAY
  )
  AS
    CURSOR c1 IS
      SELECT
        svr_table.SERVER_ID,
        svr_table.SERVER_NAME,
        svr_table.USER_ADDRESS,
        svr_table.DNS_NAME,
        svr_table.IP_ADDRESS,
        prot_table.PORT,
        comp_table.COMP_NAME,
        rt_table.STATUS,
        rt_table.MAJOR_LOAD_FACTOR,
        rt_table.MINOR_LOAD_FACTOR,
        rt_table.LAST_UPDATE_DATE
      FROM
        IEO_SVR_TYPES_B type_table,
        IEO_SVR_SERVERS svr_table,
        IEO_SVR_COMP_DEFS cdef_table,
        IEO_SVR_COMPS comp_table,
        IEO_SVR_PROTOCOL_MAP prot_table,
        IEO_SVR_RT_INFO rt_table
      WHERE
        (type_table.TYPE_UUID = P_SERVER_TYPE_UUID) AND
        (type_table.TYPE_ID = svr_table.TYPE_ID) AND
        (svr_table.MEMBER_SVR_GROUP_ID = P_GROUP_ID) AND
        (cdef_table.COMP_DEF_NAME = P_COMP_DEF_NAME) AND
        (cdef_table.COMP_DEF_VERSION = P_COMP_DEF_VERSION) AND
        (cdef_table.IMPLEMENTATION = P_COMP_DEF_IMPL) AND
        (svr_table.SERVER_ID = comp_table.SERVER_ID) AND
        (comp_table.COMP_DEF_ID = cdef_table.COMP_DEF_ID) AND
        (prot_table.COMP_ID = comp_table.COMP_ID) AND
        (prot_table.WIRE_PROTOCOL = P_WIRE_PROTOCOL) AND
        -- NOTE: Outer on the RT INFO so servers which haven't updated
        -- this are NOT excluded
        (svr_table.SERVER_ID = rt_table.SERVER_ID (+)
        ) ;

    v_svr_info_list SYSTEM.IEO_SVR_INFO_ARRAY := SYSTEM.IEO_SVR_INFO_ARRAY
                                      (
                                    SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   );
    b_check_name BOOLEAN := TRUE;

BEGIN

  IF (P_COMP_NAME IS NULL)
  THEN
    b_check_name := FALSE;
  END IF;

  FOR c1_rec IN c1
  LOOP
  <<begin_loop>>

    IF (c1%NOTFOUND) THEN
      EXIT;
    END IF;

    IF (b_check_name)
    THEN
      IF (c1_rec.COMP_NAME <> P_COMP_NAME)
      THEN
        GOTO begin_loop;
      END IF;
    END IF;

    v_svr_info_list(c1%ROWCOUNT).SERVER_NAME := c1_rec.SERVER_NAME;
    v_svr_info_list(c1%ROWCOUNT).SERVER_ID := c1_rec.SERVER_ID;
    v_svr_info_list(c1%ROWCOUNT).USER_ADDR := c1_rec.USER_ADDRESS;
    v_svr_info_list(c1%ROWCOUNT).DNS_NAME := c1_rec.DNS_NAME;
    v_svr_info_list(c1%ROWCOUNT).IP_ADDR := c1_rec.IP_ADDRESS;
    v_svr_info_list(c1%ROWCOUNT).PORT := c1_rec.PORT;
    v_svr_info_list(c1%ROWCOUNT).COMP_NAME := c1_rec.COMP_NAME;
    v_svr_info_list(c1%ROWCOUNT).STATUS := c1_rec.STATUS;
    v_svr_info_list(c1%ROWCOUNT).MAJOR_LOAD := c1_rec.MAJOR_LOAD_FACTOR;
    v_svr_info_list(c1%ROWCOUNT).MINOR_LOAD := c1_rec.MINOR_LOAD_FACTOR;
    v_svr_info_list(c1%ROWCOUNT).LAST_UPDATE := c1_rec.LAST_UPDATE_DATE;
  END LOOP;

  X_SVR_INFO_LIST := v_svr_info_list;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    X_SVR_INFO_LIST := NULL;

  WHEN OTHERS THEN
    RAISE;

END GET_ALL_SERVERS_IN_GROUP;

-- Internal utility function to get connection information for ALL servers
-- (of a specified type) within A single given group.
PROCEDURE GET_ALL_SVRS_IN_GROUP_NST
  (P_GROUP_ID           IN  NUMBER
  ,P_SERVER_TYPE_UUID   IN  VARCHAR2
  ,P_WIRE_PROTOCOL      IN  VARCHAR2
  ,P_COMP_DEF_NAME      IN  VARCHAR2
  ,P_COMP_DEF_VERSION   IN  NUMBER
  ,P_COMP_DEF_IMPL      IN  VARCHAR2
  ,P_COMP_NAME          IN  VARCHAR2
  ,X_SVR_INFO_LIST      OUT NOCOPY SYSTEM.IEO_SVR_INFO_NST
  )
  AS
    CURSOR c1 IS
      SELECT
        svr_table.SERVER_ID,
        svr_table.SERVER_NAME,
        svr_table.USER_ADDRESS,
        svr_table.DNS_NAME,
        svr_table.IP_ADDRESS,
        prot_table.PORT,
        comp_table.COMP_NAME,
        rt_table.STATUS,
        rt_table.MAJOR_LOAD_FACTOR,
        rt_table.MINOR_LOAD_FACTOR,
        rt_table.LAST_UPDATE_DATE
      FROM
        IEO_SVR_TYPES_B type_table,
        IEO_SVR_SERVERS svr_table,
        IEO_SVR_COMP_DEFS cdef_table,
        IEO_SVR_COMPS comp_table,
        IEO_SVR_PROTOCOL_MAP prot_table,
        IEO_SVR_RT_INFO rt_table
      WHERE
        (type_table.TYPE_UUID = P_SERVER_TYPE_UUID) AND
        (type_table.TYPE_ID = svr_table.TYPE_ID) AND
        (svr_table.MEMBER_SVR_GROUP_ID = P_GROUP_ID) AND
        (cdef_table.COMP_DEF_NAME = P_COMP_DEF_NAME) AND
        (cdef_table.COMP_DEF_VERSION = P_COMP_DEF_VERSION) AND
        (cdef_table.IMPLEMENTATION = P_COMP_DEF_IMPL) AND
        (svr_table.SERVER_ID = comp_table.SERVER_ID) AND
        (comp_table.COMP_DEF_ID = cdef_table.COMP_DEF_ID) AND
        (prot_table.COMP_ID = comp_table.COMP_ID) AND
        (prot_table.WIRE_PROTOCOL = P_WIRE_PROTOCOL) AND
        -- NOTE: Outer on the RT INFO so servers which haven't updated
        -- this are NOT excluded
        (svr_table.SERVER_ID = rt_table.SERVER_ID (+)
        ) ;

    v_svr_info_list SYSTEM.IEO_SVR_INFO_ARRAY := SYSTEM.IEO_SVR_INFO_ARRAY
                                      (
                                    SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   );

    b_check_name BOOLEAN := TRUE;
    b_server_found BOOLEAN := FALSE;

BEGIN

  X_SVR_INFO_LIST := SYSTEM.IEO_SVR_INFO_NST();

  IF (P_COMP_NAME IS NULL)
  THEN
    b_check_name := FALSE;
  END IF;

  FOR c1_rec IN c1
  LOOP
  <<begin_loop>>

    IF (c1%NOTFOUND) THEN
      EXIT;
    END IF;

    IF (b_check_name)
    THEN
      IF (c1_rec.COMP_NAME <> P_COMP_NAME)
      THEN
        GOTO begin_loop;
      END IF;
    END IF;

    --dude!!! I am using a combination of VARRAY and NST.. because
    --VARRAYS allows assigning to individual object attributes i use it..

    --dbms_output.put_line( 'server found :' || c1_rec.SERVER_NAME );
    v_svr_info_list(c1%ROWCOUNT).SERVER_NAME := c1_rec.SERVER_NAME;
    v_svr_info_list(c1%ROWCOUNT).SERVER_ID := c1_rec.SERVER_ID;
    v_svr_info_list(c1%ROWCOUNT).USER_ADDR := c1_rec.USER_ADDRESS;
    v_svr_info_list(c1%ROWCOUNT).DNS_NAME := c1_rec.DNS_NAME;
    v_svr_info_list(c1%ROWCOUNT).IP_ADDR := c1_rec.IP_ADDRESS;
    v_svr_info_list(c1%ROWCOUNT).PORT := c1_rec.PORT;
    v_svr_info_list(c1%ROWCOUNT).COMP_NAME := c1_rec.COMP_NAME;
    v_svr_info_list(c1%ROWCOUNT).STATUS := c1_rec.STATUS;
    v_svr_info_list(c1%ROWCOUNT).MAJOR_LOAD := c1_rec.MAJOR_LOAD_FACTOR;
    v_svr_info_list(c1%ROWCOUNT).MINOR_LOAD := c1_rec.MINOR_LOAD_FACTOR;
    v_svr_info_list(c1%ROWCOUNT).LAST_UPDATE := c1_rec.LAST_UPDATE_DATE;

    X_SVR_INFO_LIST.EXTEND(1);
    X_SVR_INFO_LIST( X_SVR_INFO_LIST.LAST ) := v_svr_info_list(c1%ROWCOUNT);
    b_server_found := TRUE;

  END LOOP;

  IF ( b_server_found <> TRUE ) THEN
    --dbms_output.put_line( 'server not found' );
    X_SVR_INFO_LIST := NULL;
  END IF;


EXCEPTION
  WHEN NO_DATA_FOUND THEN
    X_SVR_INFO_LIST := NULL;

  WHEN OTHERS THEN
    RAISE;

END GET_ALL_SVRS_IN_GROUP_NST;

-- Main Entry Point for Apps. to get remote server connection info.
-- For all Servers of a specified type.
-- NOTE: THIS procedure ONLY supports up to a total of 49 nested groups and a TOTAL of 50
-- eligible servers within the nested group structure.
PROCEDURE GET_CONNECT_INFO_FOR_ALL_SVRS
  (P_SERVER_ID_LOOKING  IN  NUMBER
  ,P_SERVER_TYPE_UUID   IN  VARCHAR2
  ,P_WIRE_PROTOCOL      IN  VARCHAR2
  ,P_COMP_DEF_NAME      IN  VARCHAR2
  ,P_COMP_DEF_VERSION   IN  NUMBER
  ,P_COMP_DEF_IMPL      IN  VARCHAR2
  ,P_COMP_NAME          IN  VARCHAR2
  ,X_DB_TIME            OUT NOCOPY DATE
  ,X_SVR_COUNT          OUT NOCOPY NUMBER
  ,X_SVR_INFO_LIST      OUT NOCOPY SYSTEM.IEO_SVR_INFO_ARRAY
  )
  AS
    group_counter NUMBER := 1;
    svr_counter NUMBER := 1;
    tmp_counter NUMBER := 1;
    v_all_svr_info_list SYSTEM.IEO_SVR_INFO_ARRAY := SYSTEM.IEO_SVR_INFO_ARRAY(
                                    SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                   ,SYSTEM.IEO_SVR_INFO_OBJ('', 0, '', '', '', 0, '', 0, NULL, 0, 0)
                                  );
    v_tmp_svr_info_list SYSTEM.IEO_SVR_INFO_ARRAY;
    v_group_ids SYSTEM.IEO_SVR_ID_ARRAY;

BEGIN

  -- First validate input:
  IF ( (P_SERVER_ID_LOOKING IS NULL) OR
       (P_SERVER_TYPE_UUID IS NULL) OR
       (P_WIRE_PROTOCOL IS NULL) OR
       (P_COMP_DEF_NAME IS NULL) OR
       (P_COMP_DEF_VERSION IS NULL) OR
       (P_COMP_DEF_IMPL IS NULL) )
  THEN
    raise_application_error
      (-20000
      ,'A required parameter is null' ||
       '. (P_SERVER_TYPE_UUID = ' || P_SERVER_TYPE_UUID ||
       ') (P_WIRE_PROTOCOL = ' || P_WIRE_PROTOCOL ||
       ') (P_COMP_DEF_NAME = ' || P_COMP_DEF_NAME ||
       ') (P_COMP_DEF_VERSION = ' || P_COMP_DEF_VERSION ||
       ') (P_COMP_DEF_IMPL = ' || P_COMP_DEF_IMPL ||
       ')'
      ,TRUE );
  END IF;


  -- Retrieve all the groups which are within the given server's set:
  LOCATE_ALL_GROUPS(P_SERVER_ID_LOOKING, v_group_ids);

  IF ( (v_group_ids IS NULL) OR (v_group_ids(1) <= 0) )
  THEN
    raise_application_error
      (-20000
      ,'Invalid Server ID specified: ' || P_SERVER_ID_LOOKING
      ,TRUE );
  END IF;

  WHILE ( v_group_ids(group_counter) > 0 )
  LOOP
    GET_ALL_SERVERS_IN_GROUP( v_group_ids(group_counter)
                              ,P_SERVER_TYPE_UUID
                              ,P_WIRE_PROTOCOL
                              ,P_COMP_DEF_NAME
                              ,P_COMP_DEF_VERSION
                              ,P_COMP_DEF_IMPL
                              ,P_COMP_NAME
                              ,v_tmp_svr_info_list
                            );
    group_counter := group_counter + 1;

    tmp_counter := 1;

    WHILE ( (v_tmp_svr_info_list IS NOT NULL) AND
            v_tmp_svr_info_list(tmp_counter).is_valid() )
    LOOP
      v_all_svr_info_list(svr_counter) := v_tmp_svr_info_list(tmp_counter);
      svr_counter := svr_counter + 1;
      tmp_counter := tmp_counter + 1;
    END LOOP;
  END LOOP;

  X_SVR_COUNT := svr_counter - 1;
  IF (X_SVR_COUNT >= 0)
  THEN
    X_SVR_INFO_LIST := v_all_svr_info_list;

    -- Get the current time:
    SELECT sysdate
    INTO X_DB_TIME
    FROM dual;
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    RAISE;


END GET_CONNECT_INFO_FOR_ALL_SVRS;


-- Main Entry Point for Apps. to get remote server connection info.
-- For all Servers of a specified type.
-- NOTE: THIS procedure ONLY supports up to a total of 49 nested groups and a TOTAL of 50
-- eligible servers within the nested group structure.
PROCEDURE GET_CONN_INFO_FOR_ALL_SVRS_NST
  (P_SERVER_ID_LOOKING  IN  NUMBER
  ,P_SERVER_TYPE_UUID   IN  VARCHAR2
  ,P_WIRE_PROTOCOL      IN  VARCHAR2
  ,P_COMP_DEF_NAME      IN  VARCHAR2
  ,P_COMP_DEF_VERSION   IN  NUMBER
  ,P_COMP_DEF_IMPL      IN  VARCHAR2
  ,P_COMP_NAME          IN  VARCHAR2
  ,X_DB_TIME            OUT NOCOPY DATE
  ,X_SVR_COUNT          OUT NOCOPY NUMBER
  ,X_SVR_INFO_LIST      OUT NOCOPY SYSTEM.IEO_SVR_INFO_NST
  )
  AS
    group_counter NUMBER := 1;
    svr_counter NUMBER := 1;
    v_group_ids SYSTEM.IEO_SVR_ID_ARRAY;
    v_tmp_svr_info_list SYSTEM.IEO_SVR_INFO_NST;

BEGIN

  -- First validate input:
  IF ( (P_SERVER_ID_LOOKING IS NULL) OR
       (P_SERVER_TYPE_UUID IS NULL) OR
       (P_WIRE_PROTOCOL IS NULL) OR
       (P_COMP_DEF_NAME IS NULL) OR
       (P_COMP_DEF_VERSION IS NULL) OR
       (P_COMP_DEF_IMPL IS NULL) )
  THEN
    raise_application_error
      (-20000
      ,'A required parameter is null' ||
       '. (P_SERVER_TYPE_UUID = ' || P_SERVER_TYPE_UUID ||
       ') (P_WIRE_PROTOCOL = ' || P_WIRE_PROTOCOL ||
       ') (P_COMP_DEF_NAME = ' || P_COMP_DEF_NAME ||
       ') (P_COMP_DEF_VERSION = ' || P_COMP_DEF_VERSION ||
       ') (P_COMP_DEF_IMPL = ' || P_COMP_DEF_IMPL ||
       ')'
      ,TRUE );
  END IF;


  X_SVR_INFO_LIST := SYSTEM.IEO_SVR_INFO_NST();

  -- Retrieve all the groups which are within the given server's set:
  LOCATE_ALL_GROUPS(P_SERVER_ID_LOOKING, v_group_ids);

  IF ( (v_group_ids IS NULL) OR (v_group_ids(1) <= 0) )
  THEN
    raise_application_error
      (-20000
      ,'Invalid Server ID specified: ' || P_SERVER_ID_LOOKING
      ,TRUE );
  END IF;


  WHILE ( v_group_ids(group_counter) > 0 )
  LOOP
    --dbms_output.put_line( 'group name ' || v_group_ids(group_counter) );
    GET_ALL_SVRS_IN_GROUP_NST( v_group_ids(group_counter)
                              ,P_SERVER_TYPE_UUID
                              ,P_WIRE_PROTOCOL
                              ,P_COMP_DEF_NAME
                              ,P_COMP_DEF_VERSION
                              ,P_COMP_DEF_IMPL
                              ,P_COMP_NAME
                              ,v_tmp_svr_info_list
                            );
    group_counter := group_counter + 1;

   if (v_tmp_svr_info_list is not null)
   then
     FOR i IN v_tmp_svr_info_list.FIRST..v_tmp_svr_info_list.LAST
      LOOP
        X_SVR_INFO_LIST.extend(1);
        X_SVR_INFO_LIST( X_SVR_INFO_LIST.LAST ) := v_tmp_svr_info_list(i);
        svr_counter := svr_counter + 1;
      END LOOP;
   END IF;
  END LOOP;

  --dbms_output.put_line( 'after main for loop' );
  X_SVR_COUNT := svr_counter - 1;
  if (X_SVR_COUNT = 0)
  then
    X_SVR_INFO_LIST := NULL;
  end IF;

  SELECT sysdate INTO X_DB_TIME FROM dual;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;


END GET_CONN_INFO_FOR_ALL_SVRS_NST;

/* Used to update real-time server information with node id. */
PROCEDURE UPDATE_RT_INFO_V2
  (P_SERVER_ID            IN NUMBER
  ,P_STATUS               IN NUMBER
  ,P_NODE_ID              IN NUMBER
  ,P_MAJOR_LOAD_FACTOR    IN NUMBER
  ,P_MINOR_LOAD_FACTOR    IN NUMBER
  ,P_EXTRA                IN VARCHAR2
  )
  AS
BEGIN

  IF ((P_SERVER_ID IS NULL) OR (P_STATUS IS NULL)) THEN
    raise_application_error
      (-20000
      ,'P_SERVER_ID and P_STATUS cannot be NULL. (P_SERVER_ID = ' ||
       P_SERVER_ID || ') (P_STATUS = ' || P_STATUS || ')'
      ,TRUE );
  END IF;


  SAVEPOINT start_update;


  UPDATE IEO_SVR_RT_INFO
    SET
      STATUS = P_STATUS,
      NODE_ID = P_NODE_ID,
      MAJOR_LOAD_FACTOR = P_MAJOR_LOAD_FACTOR,
      MINOR_LOAD_FACTOR = P_MINOR_LOAD_FACTOR,
      EXTRA = P_EXTRA,
      LAST_UPDATE_DATE = SYSDATE
    WHERE
      SERVER_ID = P_SERVER_ID;


  IF (SQL%NOTFOUND OR (SQL%ROWCOUNT <= 0)) THEN

    INSERT INTO IEO_SVR_RT_INFO
      ( SERVER_ID,
        STATUS,
        NODE_ID,
        MAJOR_LOAD_FACTOR,
        MINOR_LOAD_FACTOR,
        EXTRA,
        LAST_UPDATE_DATE )
      VALUES (
        P_SERVER_ID,
        P_STATUS,
        P_NODE_ID,
        P_MAJOR_LOAD_FACTOR,
        P_MINOR_LOAD_FACTOR,
        P_EXTRA,
        SYSDATE );

  END IF;

  COMMIT;


EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO start_update;
    RAISE;

END UPDATE_RT_INFO_V2;





/* Used to update real-time server information when load information is not specified. */

PROCEDURE UPDATE_RT_INFO_NO_LOAD_V2
  (P_SERVER_ID            IN NUMBER
  ,P_STATUS               IN NUMBER
  ,P_NODE_ID              IN NUMBER
  ,P_EXTRA                IN VARCHAR2
  )
  AS
BEGIN

  IF ((P_SERVER_ID IS NULL) OR (P_STATUS IS NULL)) THEN
    raise_application_error
      (-20000
      ,'P_SERVER_ID and P_STATUS cannot be NULL. (P_SERVER_ID = ' ||
       P_SERVER_ID || ') (P_STATUS = ' || P_STATUS || ')'
      ,TRUE );
  END IF;


  SAVEPOINT start_update;


  UPDATE IEO_SVR_RT_INFO
    SET
      STATUS = P_STATUS,
      NODE_ID = P_NODE_ID,
      EXTRA = P_EXTRA,
      LAST_UPDATE_DATE = SYSDATE
    WHERE
      SERVER_ID = P_SERVER_ID;


  IF (SQL%NOTFOUND OR (SQL%ROWCOUNT <= 0)) THEN

    INSERT INTO IEO_SVR_RT_INFO
      ( SERVER_ID,
        STATUS,
        NODE_ID,
        EXTRA,
        LAST_UPDATE_DATE )
      VALUES (
        P_SERVER_ID,
        P_STATUS,
        P_NODE_ID,
        P_EXTRA,
        SYSDATE );

  END IF;

  COMMIT;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO start_update;
    RAISE;

END UPDATE_RT_INFO_NO_LOAD_V2;


/* Used to update real-time server information. */
PROCEDURE UPDATE_RT_INFO
  (P_SERVER_ID            IN NUMBER
  ,P_STATUS               IN NUMBER
  ,P_MAJOR_LOAD_FACTOR    IN NUMBER
  ,P_MINOR_LOAD_FACTOR    IN NUMBER
  ,P_EXTRA                IN VARCHAR2
  )
  AS
BEGIN

  IF ((P_SERVER_ID IS NULL) OR (P_STATUS IS NULL)) THEN
    raise_application_error
      (-20000
      ,'P_SERVER_ID and P_STATUS cannot be NULL. (P_SERVER_ID = ' ||
       P_SERVER_ID || ') (P_STATUS = ' || P_STATUS || ')'
      ,TRUE );
  END IF;


  SAVEPOINT start_update;


  UPDATE IEO_SVR_RT_INFO
    SET
      STATUS = P_STATUS,
      MAJOR_LOAD_FACTOR = P_MAJOR_LOAD_FACTOR,
      MINOR_LOAD_FACTOR = P_MINOR_LOAD_FACTOR,
      EXTRA = P_EXTRA,
      LAST_UPDATE_DATE = SYSDATE
    WHERE
      SERVER_ID = P_SERVER_ID;


  IF (SQL%NOTFOUND OR (SQL%ROWCOUNT <= 0)) THEN

    INSERT INTO IEO_SVR_RT_INFO
      ( SERVER_ID,
        STATUS,
        MAJOR_LOAD_FACTOR,
        MINOR_LOAD_FACTOR,
        EXTRA,
        LAST_UPDATE_DATE )
      VALUES (
        P_SERVER_ID,
        P_STATUS,
        P_MAJOR_LOAD_FACTOR,
        P_MINOR_LOAD_FACTOR,
        P_EXTRA,
        SYSDATE );

  END IF;

  COMMIT;


EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO start_update;
    RAISE;

END UPDATE_RT_INFO;





/* Used to update real-time server information when load information is not specified. */

PROCEDURE UPDATE_RT_INFO_NO_LOAD
  (P_SERVER_ID            IN NUMBER
  ,P_STATUS               IN NUMBER
  ,P_EXTRA                IN VARCHAR2
  )
  AS
BEGIN

  IF ((P_SERVER_ID IS NULL) OR (P_STATUS IS NULL)) THEN
    raise_application_error
      (-20000
      ,'P_SERVER_ID and P_STATUS cannot be NULL. (P_SERVER_ID = ' ||
       P_SERVER_ID || ') (P_STATUS = ' || P_STATUS || ')'
      ,TRUE );
  END IF;


  SAVEPOINT start_update;


  UPDATE IEO_SVR_RT_INFO
    SET
      STATUS = P_STATUS,
      EXTRA = P_EXTRA,
      LAST_UPDATE_DATE = SYSDATE
    WHERE
      SERVER_ID = P_SERVER_ID;


  IF (SQL%NOTFOUND OR (SQL%ROWCOUNT <= 0)) THEN

    INSERT INTO IEO_SVR_RT_INFO
      ( SERVER_ID,
        STATUS,
        EXTRA,
        LAST_UPDATE_DATE )
      VALUES (
        P_SERVER_ID,
        P_STATUS,
        P_EXTRA,
        SYSDATE );

  END IF;

  COMMIT ;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO start_update;
    RAISE;

END UPDATE_RT_INFO_NO_LOAD;




/* Locates a server of a particular type, given a group. */
PROCEDURE LOCATE_LEAST_LOADED_IN_GROUP
  (P_GROUP_ID           IN NUMBER
  ,P_SERVER_TYPE_UUID   IN VARCHAR2
  ,P_EXCLUDE_SERVER_ID  IN NUMBER
  ,X_SERVER_ID          OUT NOCOPY NUMBER
  ,P_TIMEOUT_TOLERANCE  IN NUMBER
  )
  AS

  rt_major_load_min IEO_SVR_RT_INFO.MAJOR_LOAD_FACTOR%TYPE;
  rt_major_load_max IEO_SVR_RT_INFO.MAJOR_LOAD_FACTOR%TYPE;

  rt_minor_load_min IEO_SVR_RT_INFO.MINOR_LOAD_FACTOR%TYPE;
  rt_minor_load_max IEO_SVR_RT_INFO.MINOR_LOAD_FACTOR%TYPE;

  ty_major_load_max IEO_SVR_TYPES_B.MAX_MAJOR_LOAD_FACTOR%TYPE;
  ty_minor_load_max IEO_SVR_TYPES_B.MAX_MINOR_LOAD_FACTOR%TYPE;

  l_exclude_server_id  IEO_SVR_SERVERS.SERVER_ID%TYPE;

  l_curr_time_secs     NUMBER(5);
  l_refresh_rate_secs  NUMBER(5);

  l_timeout_tolerance  NUMBER := P_TIMEOUT_TOLERANCE;

BEGIN


  IF ((P_GROUP_ID IS NULL) OR (P_SERVER_TYPE_UUID IS NULL)) THEN
    raise_application_error
      (-20000
      ,'P_GROUP_ID and P_SERVER_TYPE_UUID cannot be NULL. (P_GROUP_ID = ' ||
       P_GROUP_ID || ') (P_SERVER_TYPE_UUID = ' || P_SERVER_TYPE_UUID || ')'
      ,TRUE );
  END IF;


  --
  -- First we try for the lowest MAJOR_LOAD, and if they are all equal, then
  -- we try for the lowest MINOR_LOAD.  If they're all equal, then it's a wash
  -- and we just make sure something is selected.
  --


  --
  -- Collecting some information that we need in the next step(s).
  --


  IF (P_EXCLUDE_SERVER_ID IS NULL) THEN

    -- zero is an invalid number because the sequence min = 10000
    -- this allows the select statements to be stuctured the same because
    -- there's a WHERE (server_id <> exlude_server_id) in all of them.
    l_exclude_server_id := 0;

  ELSE

    l_exclude_server_id := P_EXCLUDE_SERVER_ID;

  END IF;


  --
  -- Parameter parsing, if the timeout is NULL, we'll use a default timeout.
  -- If it's negative, we'll turn off timeout checking entirely.
  --
  IF (l_timeout_tolerance IS NULL) THEN
    l_timeout_tolerance := 30;
  ELSIF (l_timeout_tolerance < 0) THEN
    l_timeout_tolerance := NULL;
  END IF;


  SELECT
    DISTINCT
      type_table.MAX_MAJOR_LOAD_FACTOR,
      type_table.MAX_MINOR_LOAD_FACTOR,
      (type_table.RT_REFRESH_RATE * 60)
    INTO
      ty_major_load_max,
      ty_minor_load_max,
      l_refresh_rate_secs
    FROM
      IEO_SVR_TYPES_B type_table
    WHERE
      (type_table.TYPE_UUID = P_SERVER_TYPE_UUID) AND
      (ROWNUM <= 1);


  l_curr_time_secs := to_number(to_char(SYSDATE,'SSSSS'));


  SELECT
    DISTINCT
      MIN(rt_table.MAJOR_LOAD_FACTOR),
      MAX(rt_table.MAJOR_LOAD_FACTOR),
      MIN(rt_table.MINOR_LOAD_FACTOR),
      MAX(rt_table.MINOR_LOAD_FACTOR)
    INTO
      rt_major_load_min,
      rt_major_load_max,
      rt_minor_load_min,
      rt_minor_load_max
    FROM
      IEO_SVR_SERVERS svr_table,
      IEO_SVR_TYPES_B type_table,
      IEO_SVR_RT_INFO rt_table
    WHERE
      (svr_table.TYPE_ID = type_table.TYPE_ID) AND
      (svr_table.SERVER_ID = rt_table.SERVER_ID) AND
      (svr_table.SERVER_ID <> l_exclude_server_id) AND
      (svr_table.MEMBER_SVR_GROUP_ID = P_GROUP_ID) AND
      (type_table.TYPE_UUID = P_SERVER_TYPE_UUID) AND
      (rt_table.STATUS > 0) AND
        (
          (l_timeout_tolerance IS NULL) OR
          (
            ABS( l_curr_time_secs -
                 (to_number(to_char(rt_table.LAST_UPDATE_DATE,'SSSSS'))) )
            <= (l_refresh_rate_secs + l_timeout_tolerance)
          )
        );


  --
  -- I've used GOTOs (where I would normally have used 'return's) rather than
  -- having a bunch of nested IFs that would be very difficult to follow (if
  -- you understand the logic below, and try to figure out what the nested IFs
  -- would look like, you'll see what I mean.
  --


  --
  -- Major load takes priority, if we've exceded all possible major loads, then
  -- we cannot issue a server.  Servers should make sure they publish a "proper"
  -- major load maximums to avoid this, if they don't want to use this feature.
  --
  IF (rt_major_load_min > ty_major_load_max) THEN
    X_SERVER_ID := NULL;
    GOTO done;
  END IF;


  --
  -- If the min = max it means we cannot use it to determine which server to
  -- select, and would have to use the Minor load to determine selection.
  --
  IF (rt_major_load_min <> rt_major_load_max) THEN

    BEGIN
      SELECT
        DISTINCT
          svr_table.SERVER_ID
        INTO
          X_SERVER_ID
        FROM
          IEO_SVR_SERVERS svr_table,
          IEO_SVR_TYPES_B type_table,
          IEO_SVR_RT_INFO rt_table
        WHERE
          (svr_table.TYPE_ID = type_table.TYPE_ID) AND
          (svr_table.SERVER_ID = rt_table.SERVER_ID) AND
          (svr_table.SERVER_ID <> l_exclude_server_id) AND
          (svr_table.MEMBER_SVR_GROUP_ID = P_GROUP_ID) AND
          (type_table.TYPE_UUID = P_SERVER_TYPE_UUID) AND
          (rt_table.STATUS > 0) AND
          (
            (l_timeout_tolerance IS NULL) OR
            (
              ABS( l_curr_time_secs -
                 (to_number(to_char(rt_table.LAST_UPDATE_DATE,'SSSSS'))) )
              <= (l_refresh_rate_secs + l_timeout_tolerance)
            )
          ) AND
          (rt_table.MAJOR_LOAD_FACTOR <= rt_major_load_min) AND
          (ROWNUM <= 1);

    EXCEPTION

      WHEN NO_DATA_FOUND THEN
        NULL;

      WHEN OTHERS THEN
        RAISE;

    END;

    GOTO done;

  END IF;


  --
  --
  -- If we get this far, we're supposed to determine load based on the Minor
  -- factor because we cannot determine it from the Major factor.
  --
  --


  --
  -- Minor load takes priority, if we've exceded all possible minor loads, then
  -- we cannot issue a server.  Servers should make sure they publish a "proper"
  -- minor load maximums to avoid this, if they don't want to use this feature.
  --
  IF (rt_minor_load_min > ty_minor_load_max) THEN
    X_SERVER_ID := NULL;
    GOTO done;
  END IF;


  --
  -- If the min = max it means we cannot use it to determine which server to
  -- select, and would have to use some random method to determine selection.
  --
  IF (rt_minor_load_min <> rt_minor_load_max) THEN

    BEGIN
      SELECT
        DISTINCT
          svr_table.SERVER_ID
        INTO
          X_SERVER_ID
        FROM
          IEO_SVR_SERVERS svr_table,
          IEO_SVR_TYPES_B type_table,
          IEO_SVR_RT_INFO rt_table
        WHERE
          (svr_table.TYPE_ID = type_table.TYPE_ID) AND
          (svr_table.SERVER_ID = rt_table.SERVER_ID) AND
          (svr_table.SERVER_ID <> l_exclude_server_id) AND
          (svr_table.MEMBER_SVR_GROUP_ID = P_GROUP_ID) AND
          (type_table.TYPE_UUID = P_SERVER_TYPE_UUID) AND
          (rt_table.STATUS > 0) AND
          (
            (l_timeout_tolerance IS NULL) OR
            (
              ABS( l_curr_time_secs -
                 (to_number(to_char(rt_table.LAST_UPDATE_DATE,'SSSSS'))) )
              <= (l_refresh_rate_secs + l_timeout_tolerance)
            )
          ) AND
          (rt_table.MINOR_LOAD_FACTOR <= rt_minor_load_min) AND
          (ROWNUM <= 1);

    EXCEPTION

      WHEN NO_DATA_FOUND THEN
        NULL;

      WHEN OTHERS THEN
        RAISE;

    END;

    GOTO done;

  END IF;


  --
  --
  -- If we get to this point, neither the Major nor the Minor was able to
  -- determine a server, yet everything is under the Maximums, so we have to
  -- "randomly" assign a server.
  --
  --

  --
  -- We'll just select the "First" server we can get.
  --
  BEGIN

    SELECT
      DISTINCT
        svr_table.SERVER_ID
      INTO
        X_SERVER_ID
      FROM
        IEO_SVR_SERVERS svr_table,
        IEO_SVR_TYPES_B type_table,
        IEO_SVR_RT_INFO rt_table
      WHERE
        (svr_table.TYPE_ID = type_table.TYPE_ID) AND
        (svr_table.SERVER_ID = rt_table.SERVER_ID) AND
        (svr_table.SERVER_ID <> l_exclude_server_id) AND
        (svr_table.MEMBER_SVR_GROUP_ID = P_GROUP_ID) AND
        (type_table.TYPE_UUID = P_SERVER_TYPE_UUID) AND
        (rt_table.STATUS > 0) AND
        (
          (l_timeout_tolerance IS NULL) OR
          (
            ABS( l_curr_time_secs -
               (to_number(to_char(rt_table.LAST_UPDATE_DATE,'SSSSS'))) )
            <= (l_refresh_rate_secs + l_timeout_tolerance)
          )
        ) AND
        (ROWNUM <= 1);

  EXCEPTION

    WHEN NO_DATA_FOUND THEN
      NULL;

    WHEN OTHERS THEN
      RAISE;

  END;


<<done>>
  NULL;


EXCEPTION
  WHEN OTHERS THEN
    RAISE;


END LOCATE_LEAST_LOADED_IN_GROUP;




















/* Locates a server of a particular type, given a group. */
PROCEDURE LOCATE_BY_MAJOR_LOAD
  (P_GROUP_ID           IN NUMBER
  ,P_SERVER_TYPE_UUID   IN VARCHAR2
  ,P_EXCLUDE_SERVER_ID  IN NUMBER
  ,X_SERVER_ID          OUT NOCOPY NUMBER
  ,P_TIMEOUT_TOLERANCE  IN NUMBER
  )
  AS

  rt_major_load_min IEO_SVR_RT_INFO.MAJOR_LOAD_FACTOR%TYPE;
  rt_major_load_max IEO_SVR_RT_INFO.MAJOR_LOAD_FACTOR%TYPE;


  ty_major_load_max IEO_SVR_TYPES_B.MAX_MAJOR_LOAD_FACTOR%TYPE;

  l_exclude_server_id  IEO_SVR_SERVERS.SERVER_ID%TYPE;

  l_curr_time_secs     NUMBER(5);
  l_refresh_rate_secs  NUMBER(5);

  l_timeout_tolerance  NUMBER := P_TIMEOUT_TOLERANCE;

BEGIN


  IF ((P_GROUP_ID IS NULL) OR (P_SERVER_TYPE_UUID IS NULL)) THEN
    raise_application_error
      (-20000
      ,'P_GROUP_ID and P_SERVER_TYPE_UUID cannot be NULL. (P_GROUP_ID = ' ||
       P_GROUP_ID || ') (P_SERVER_TYPE_UUID = ' || P_SERVER_TYPE_UUID || ')'
      ,TRUE );
  END IF;


  --
  -- First we try for the lowest MAJOR_LOAD, and if they are all equal, then
  -- we try for the lowest MINOR_LOAD.  If they're all equal, then it's a wash
  -- and we just make sure something is selected.
  --


  --
  -- Collecting some information that we need in the next step(s).
  --


  IF (P_EXCLUDE_SERVER_ID IS NULL) THEN

    -- zero is an invalid number because the sequence min = 10000
    -- this allows the select statements to be stuctured the same because
    -- there's a WHERE (server_id <> exlude_server_id) in all of them.
    l_exclude_server_id := 0;

  ELSE

    l_exclude_server_id := P_EXCLUDE_SERVER_ID;

  END IF;


  --
  -- Parameter parsing, if the timeout is NULL, we'll use a default timeout.
  -- If it's negative, we'll turn off timeout checking entirely.
  --
  IF (l_timeout_tolerance IS NULL) THEN
    l_timeout_tolerance := 30;
  ELSIF (l_timeout_tolerance < 0) THEN
    l_timeout_tolerance := NULL;
  END IF;


  SELECT
    DISTINCT
      type_table.MAX_MAJOR_LOAD_FACTOR,
      (type_table.RT_REFRESH_RATE * 60)
    INTO
      ty_major_load_max,
      l_refresh_rate_secs
    FROM
      IEO_SVR_TYPES_B type_table
    WHERE
      (type_table.TYPE_UUID = P_SERVER_TYPE_UUID) AND
      (ROWNUM <= 1);


  l_curr_time_secs := to_number(to_char(SYSDATE,'SSSSS'));


  SELECT
    DISTINCT
      MIN(rt_table.MAJOR_LOAD_FACTOR),
      MAX(rt_table.MAJOR_LOAD_FACTOR)
    INTO
      rt_major_load_min,
      rt_major_load_max
    FROM
      IEO_SVR_SERVERS svr_table,
      IEO_SVR_TYPES_B type_table,
      IEO_SVR_RT_INFO rt_table
    WHERE
      (svr_table.TYPE_ID = type_table.TYPE_ID) AND
      (svr_table.SERVER_ID = rt_table.SERVER_ID) AND
      (svr_table.SERVER_ID <> l_exclude_server_id) AND
      (svr_table.MEMBER_SVR_GROUP_ID = P_GROUP_ID) AND
      (type_table.TYPE_UUID = P_SERVER_TYPE_UUID) AND
      (rt_table.STATUS > 1) AND
        (
          (l_timeout_tolerance IS NULL) OR
          (
            ABS( l_curr_time_secs -
                 (to_number(to_char(rt_table.LAST_UPDATE_DATE,'SSSSS'))) )
            <= (l_refresh_rate_secs + l_timeout_tolerance)
          )
        );


  --
  -- I've used GOTOs (where I would normally have used 'return's) rather than
  -- having a bunch of nested IFs that would be very difficult to follow (if
  -- you understand the logic below, and try to figure out what the nested IFs
  -- would look like, you'll see what I mean.
  --


  --
  -- Major load takes priority, if we've exceded all possible major loads, then
  -- we cannot issue a server.  Servers should make sure they publish a "proper"
  -- major load maximums to avoid this, if they don't want to use this feature.
  --
  IF (rt_major_load_min > ty_major_load_max) THEN
    X_SERVER_ID := NULL;
    GOTO done;
  END IF;


  --
  -- If the min = max it means we cannot use it to determine which server to
  -- select, and would have to use the Minor load to determine selection.
  --
  IF (rt_major_load_min <> rt_major_load_max) THEN

    BEGIN
      SELECT
        DISTINCT
          svr_table.SERVER_ID
        INTO
          X_SERVER_ID
        FROM
          IEO_SVR_SERVERS svr_table,
          IEO_SVR_TYPES_B type_table,
          IEO_SVR_RT_INFO rt_table
        WHERE
          (svr_table.TYPE_ID = type_table.TYPE_ID) AND
          (svr_table.SERVER_ID = rt_table.SERVER_ID) AND
          (svr_table.SERVER_ID <> l_exclude_server_id) AND
          (svr_table.MEMBER_SVR_GROUP_ID = P_GROUP_ID) AND
          (type_table.TYPE_UUID = P_SERVER_TYPE_UUID) AND
          (rt_table.STATUS > 1) AND
          (
            (l_timeout_tolerance IS NULL) OR
            (
              ABS( l_curr_time_secs -
                 (to_number(to_char(rt_table.LAST_UPDATE_DATE,'SSSSS'))) )
              <= (l_refresh_rate_secs + l_timeout_tolerance)
            )
          ) AND
          (rt_table.MAJOR_LOAD_FACTOR <= rt_major_load_min) AND
          (ROWNUM <= 1);

    EXCEPTION

      WHEN NO_DATA_FOUND THEN
        NULL;

      WHEN OTHERS THEN
        RAISE;

    END;

    GOTO done;

  END IF;

  -- If we get to this point, the Major was not able to
  -- determine a server, yet everything is under the Maximums, so we have to
  -- "randomly" assign a server.
  --
  --

  --
  -- We'll just select the "First" server we can get.
  --
  BEGIN

    SELECT
      DISTINCT
        svr_table.SERVER_ID
      INTO
        X_SERVER_ID
      FROM
        IEO_SVR_SERVERS svr_table,
        IEO_SVR_TYPES_B type_table,
        IEO_SVR_RT_INFO rt_table
      WHERE
        (svr_table.TYPE_ID = type_table.TYPE_ID) AND
        (svr_table.SERVER_ID = rt_table.SERVER_ID) AND
        (svr_table.SERVER_ID <> l_exclude_server_id) AND
        (svr_table.MEMBER_SVR_GROUP_ID = P_GROUP_ID) AND
        (type_table.TYPE_UUID = P_SERVER_TYPE_UUID) AND
        (rt_table.STATUS > 1) AND
        (
          (l_timeout_tolerance IS NULL) OR
          (
            ABS( l_curr_time_secs -
               (to_number(to_char(rt_table.LAST_UPDATE_DATE,'SSSSS'))) )
            <= (l_refresh_rate_secs + l_timeout_tolerance)
          )
        ) AND
        (ROWNUM <= 1);

  EXCEPTION

    WHEN NO_DATA_FOUND THEN
      NULL;

    WHEN OTHERS THEN
      RAISE;

  END;


<<done>>
  NULL;


EXCEPTION
  WHEN OTHERS THEN
    RAISE;


END LOCATE_BY_MAJOR_LOAD;


















/* Locates a server of a particular type, given a group. */
PROCEDURE LOCATE_BY_MINOR_LOAD
  (P_GROUP_ID           IN NUMBER
  ,P_SERVER_TYPE_UUID   IN VARCHAR2
  ,P_EXCLUDE_SERVER_ID  IN NUMBER
  ,X_SERVER_ID          OUT NOCOPY NUMBER
  ,P_TIMEOUT_TOLERANCE  IN NUMBER
  )
  AS
  rt_minor_load_min IEO_SVR_RT_INFO.MINOR_LOAD_FACTOR%TYPE;
  rt_minor_load_max IEO_SVR_RT_INFO.MINOR_LOAD_FACTOR%TYPE;
  ty_minor_load_max IEO_SVR_TYPES_B.MAX_MINOR_LOAD_FACTOR%TYPE;

  l_exclude_server_id  IEO_SVR_SERVERS.SERVER_ID%TYPE;

  l_curr_time_secs     NUMBER(5);
  l_refresh_rate_secs  NUMBER(5);

  l_timeout_tolerance  NUMBER := P_TIMEOUT_TOLERANCE;

BEGIN


  IF ((P_GROUP_ID IS NULL) OR (P_SERVER_TYPE_UUID IS NULL)) THEN
    raise_application_error
      (-20000
      ,'P_GROUP_ID and P_SERVER_TYPE_UUID cannot be NULL. (P_GROUP_ID = ' ||
       P_GROUP_ID || ') (P_SERVER_TYPE_UUID = ' || P_SERVER_TYPE_UUID || ')'
      ,TRUE );
  END IF;


  --
  -- First we try for the lowest MAJOR_LOAD, and if they are all equal, then
  -- we try for the lowest MINOR_LOAD.  If they're all equal, then it's a wash
  -- and we just make sure something is selected.
  --


  --
  -- Collecting some information that we need in the next step(s).
  --


  IF (P_EXCLUDE_SERVER_ID IS NULL) THEN

    -- zero is an invalid number because the sequence min = 10000
    -- this allows the select statements to be stuctured the same because
    -- there's a WHERE (server_id <> exlude_server_id) in all of them.
    l_exclude_server_id := 0;

  ELSE

    l_exclude_server_id := P_EXCLUDE_SERVER_ID;

  END IF;


  --
  -- Parameter parsing, if the timeout is NULL, we'll use a default timeout.
  -- If it's negative, we'll turn off timeout checking entirely.
  --
  IF (l_timeout_tolerance IS NULL) THEN
    l_timeout_tolerance := 30;
  ELSIF (l_timeout_tolerance < 0) THEN
    l_timeout_tolerance := NULL;
  END IF;


  SELECT
    DISTINCT
      type_table.MAX_MINOR_LOAD_FACTOR,
      (type_table.RT_REFRESH_RATE * 60)
    INTO
      ty_minor_load_max,
      l_refresh_rate_secs
    FROM
      IEO_SVR_TYPES_B type_table
    WHERE
      (type_table.TYPE_UUID = P_SERVER_TYPE_UUID) AND
      (ROWNUM <= 1);


  l_curr_time_secs := to_number(to_char(SYSDATE,'SSSSS'));


  SELECT
    DISTINCT
      MIN(rt_table.MINOR_LOAD_FACTOR),
      MAX(rt_table.MINOR_LOAD_FACTOR)
    INTO
      rt_minor_load_min,
      rt_minor_load_max
    FROM
      IEO_SVR_SERVERS svr_table,
      IEO_SVR_TYPES_B type_table,
      IEO_SVR_RT_INFO rt_table
    WHERE
      (svr_table.TYPE_ID = type_table.TYPE_ID) AND
      (svr_table.SERVER_ID = rt_table.SERVER_ID) AND
      (svr_table.SERVER_ID <> l_exclude_server_id) AND
      (svr_table.MEMBER_SVR_GROUP_ID = P_GROUP_ID) AND
      (type_table.TYPE_UUID = P_SERVER_TYPE_UUID) AND
      (rt_table.STATUS > 1) AND
        (
          (l_timeout_tolerance IS NULL) OR
          (
            ABS( l_curr_time_secs -
                 (to_number(to_char(rt_table.LAST_UPDATE_DATE,'SSSSS'))) )
            <= (l_refresh_rate_secs + l_timeout_tolerance)
          )
        );

  --
  --
  -- If we get this far, we're supposed to determine load based on the Minor
  -- factor because we cannot determine it from the Major factor.
  --
  --


  --
  -- Minor load takes priority, if we've exceded all possible minor loads, then
  -- we cannot issue a server.  Servers should make sure they publish a "proper"
  -- minor load maximums to avoid this, if they don't want to use this feature.
  --
  IF (rt_minor_load_min > ty_minor_load_max) THEN
    X_SERVER_ID := NULL;
    GOTO done;
  END IF;


  --
  -- If the min = max it means we cannot use it to determine which server to
  -- select, and would have to use some random method to determine selection.
  --
  IF (rt_minor_load_min <> rt_minor_load_max) THEN

    BEGIN
      SELECT
        DISTINCT
          svr_table.SERVER_ID
        INTO
          X_SERVER_ID
        FROM
          IEO_SVR_SERVERS svr_table,
          IEO_SVR_TYPES_B type_table,
          IEO_SVR_RT_INFO rt_table
        WHERE
          (svr_table.TYPE_ID = type_table.TYPE_ID) AND
          (svr_table.SERVER_ID = rt_table.SERVER_ID) AND
          (svr_table.SERVER_ID <> l_exclude_server_id) AND
          (svr_table.MEMBER_SVR_GROUP_ID = P_GROUP_ID) AND
          (type_table.TYPE_UUID = P_SERVER_TYPE_UUID) AND
          (rt_table.STATUS > 1) AND
          (
            (l_timeout_tolerance IS NULL) OR
            (
              ABS( l_curr_time_secs -
                 (to_number(to_char(rt_table.LAST_UPDATE_DATE,'SSSSS'))) )
              <= (l_refresh_rate_secs + l_timeout_tolerance)
            )
          ) AND
          (rt_table.MINOR_LOAD_FACTOR <= rt_minor_load_min) AND
          (ROWNUM <= 1);

    EXCEPTION

      WHEN NO_DATA_FOUND THEN
        NULL;

      WHEN OTHERS THEN
        RAISE;

    END;

    GOTO done;

  END IF;


  --
  --
  -- If we get to this point, neither the Major nor the Minor was able to
  -- determine a server, yet everything is under the Maximums, so we have to
  -- "randomly" assign a server.
  --
  --

  --
  -- We'll just select the "First" server we can get.
  --
  BEGIN

    SELECT
      DISTINCT
        svr_table.SERVER_ID
      INTO
        X_SERVER_ID
      FROM
        IEO_SVR_SERVERS svr_table,
        IEO_SVR_TYPES_B type_table,
        IEO_SVR_RT_INFO rt_table
      WHERE
        (svr_table.TYPE_ID = type_table.TYPE_ID) AND
        (svr_table.SERVER_ID = rt_table.SERVER_ID) AND
        (svr_table.SERVER_ID <> l_exclude_server_id) AND
        (svr_table.MEMBER_SVR_GROUP_ID = P_GROUP_ID) AND
        (type_table.TYPE_UUID = P_SERVER_TYPE_UUID) AND
        (rt_table.STATUS > 1) AND
        (
          (l_timeout_tolerance IS NULL) OR
          (
            ABS( l_curr_time_secs -
               (to_number(to_char(rt_table.LAST_UPDATE_DATE,'SSSSS'))) )
            <= (l_refresh_rate_secs + l_timeout_tolerance)
          )
        ) AND
        (ROWNUM <= 1);

  EXCEPTION

    WHEN NO_DATA_FOUND THEN
      NULL;

    WHEN OTHERS THEN
      RAISE;

  END;


<<done>>
  NULL;


EXCEPTION
  WHEN OTHERS THEN
    RAISE;


END LOCATE_BY_MINOR_LOAD;










/* Locates a server of a particular type, given another server. */
PROCEDURE LOCATE_LEAST_LOADED_FOR_SVR
  (P_SERVER_ID_LOOKING  IN NUMBER
  ,P_SERVER_TYPE_UUID   IN VARCHAR2
  ,X_SERVER_ID_FOUND    OUT NOCOPY NUMBER
  ,P_TIMEOUT_TOLERANCE  IN NUMBER
  )
  AS

  l_group_id IEO_SVR_GROUPS.SERVER_GROUP_ID%TYPE;

BEGIN


  IF ((P_SERVER_ID_LOOKING IS NULL) OR (P_SERVER_TYPE_UUID IS NULL)) THEN
    raise_application_error
      (-20000
      ,'P_SERVER_ID_LOOKING and P_SERVER_TYPE_UUID cannot be NULL. (P_SERVER_ID_LOOKING = ' ||
       P_SERVER_ID_LOOKING || ') (P_SERVER_TYPE_UUID = ' || P_SERVER_TYPE_UUID || ')'
      ,TRUE );
  END IF;


  SELECT
    DISTINCT
      NVL( svr_table.USING_SVR_GROUP_ID, svr_table.MEMBER_SVR_GROUP_ID )
    INTO
      l_group_id
    FROM
      IEO_SVR_SERVERS svr_table
    WHERE
      (svr_table.SERVER_ID = P_SERVER_ID_LOOKING) AND
      (ROWNUM <= 1);

  --
  -- Locate a server in the proper group, excluding the server that is
  -- trying to perform the location.
  --
  LOCATE_LEAST_LOADED_IN_GROUP(
    l_group_id,
    p_server_type_uuid,
    p_server_id_looking,
    x_server_id_found,
    p_timeout_tolerance );


EXCEPTION
  WHEN OTHERS THEN
    RAISE;


END LOCATE_LEAST_LOADED_FOR_SVR;


/* Locates a server of a particular type, given another server, and obtains */
/* the connection information, based on some default rules.                 */
PROCEDURE LOCATE_LLS_AND_INFO
  (P_SERVER_ID          IN  NUMBER
  ,P_SERVER_TYPE_UUID   IN  VARCHAR2
  ,P_WIRE_PROTOCOL      IN  VARCHAR2
  ,P_COMP_DEF_NAME      IN  VARCHAR2
  ,P_COMP_DEF_VERSION   IN  NUMBER
  ,P_COMP_DEF_IMPL      IN  VARCHAR2
  ,P_COMP_NAME          IN  VARCHAR2
  ,X_SERVER_ID_FOUND    OUT NOCOPY NUMBER
  ,X_USER_ADDRESS       OUT NOCOPY VARCHAR2
  ,X_DNS_NAME           OUT NOCOPY VARCHAR2
  ,X_IP_ADDRESS         OUT NOCOPY VARCHAR2
  ,X_PORT               OUT NOCOPY NUMBER
  ,X_COMP_NAME          OUT NOCOPY VARCHAR2
  ,P_TIMEOUT_TOLERANCE  IN NUMBER
  )
  AS
BEGIN


  IF ( (P_SERVER_ID IS NULL) OR
       (P_SERVER_TYPE_UUID IS NULL) OR
       (P_WIRE_PROTOCOL IS NULL) OR
       (P_COMP_DEF_NAME IS NULL) OR
       (P_COMP_DEF_VERSION IS NULL) OR
       (P_COMP_DEF_IMPL IS NULL) )
  THEN
    raise_application_error
      (-20000
      ,'A required parameter is null' ||
       '. (P_SERVER_ID = ' || P_SERVER_ID ||
       ') (P_SERVER_TYPE_UUID = ' || P_SERVER_TYPE_UUID ||
       ') (P_WIRE_PROTOCOL = ' || P_WIRE_PROTOCOL ||
       ') (P_COMP_DEF_NAME = ' || P_COMP_DEF_NAME ||
       ') (P_COMP_DEF_VERSION = ' || P_COMP_DEF_VERSION ||
       ') (P_COMP_DEF_IMPL = ' || P_COMP_DEF_IMPL ||
       ')'
      ,TRUE );
  END IF;


  LOCATE_LEAST_LOADED_FOR_SVR(
    P_SERVER_ID,
    P_SERVER_TYPE_UUID,
    x_server_id_found,
    p_timeout_tolerance
    );


  IF (x_server_id_found IS NULL) THEN
      raise_application_error
      (-20010,
       'Could not locate a server to connect to.',
       TRUE );
  END IF;


  IF (P_COMP_NAME IS NULL) THEN

    SELECT
      DISTINCT
        comp_table.COMP_NAME
      INTO
        X_COMP_NAME
      FROM
        IEO_SVR_SERVERS svr_table,
        IEO_SVR_COMP_DEFS cdef_table,
        IEO_SVR_COMPS comp_table,
        IEO_SVR_PROTOCOL_MAP prot_table
      WHERE
        (svr_table.SERVER_ID = comp_table.SERVER_ID) AND
        (svr_table.SERVER_ID = x_server_id_found) AND
        (comp_table.COMP_DEF_ID = cdef_table.COMP_DEF_ID) AND
        (prot_table.COMP_ID = comp_table.COMP_ID) AND
        (prot_table.WIRE_PROTOCOL = P_WIRE_PROTOCOL) AND
        (cdef_table.COMP_DEF_NAME = P_COMP_DEF_NAME) AND
        (cdef_table.COMP_DEF_VERSION = P_COMP_DEF_VERSION) AND
        (cdef_table.IMPLEMENTATION = P_COMP_DEF_IMPL) AND
        (ROWNUM <= 1);

  ELSE

    X_COMP_NAME := P_COMP_NAME;

  END IF;


  SELECT
    DISTINCT
      svr_table.USER_ADDRESS,
      svr_table.DNS_NAME,
      svr_table.IP_ADDRESS,
      prot_table.PORT
    INTO
      X_USER_ADDRESS,
      X_DNS_NAME,
      X_IP_ADDRESS,
      X_PORT
    FROM
      IEO_SVR_SERVERS svr_table,
      IEO_SVR_COMP_DEFS cdef_table,
      IEO_SVR_COMPS comp_table,
      IEO_SVR_PROTOCOL_MAP prot_table
    WHERE
      (svr_table.SERVER_ID = x_server_id_found) AND
      (svr_table.SERVER_ID = comp_table.SERVER_ID) AND
      (comp_table.COMP_DEF_ID = cdef_table.COMP_DEF_ID) AND
      (prot_table.COMP_ID = comp_table.COMP_ID) AND
      (prot_table.WIRE_PROTOCOL = P_WIRE_PROTOCOL) AND
      (cdef_table.COMP_DEF_NAME = P_COMP_DEF_NAME) AND
      (cdef_table.COMP_DEF_VERSION = P_COMP_DEF_VERSION) AND
      (cdef_table.IMPLEMENTATION = P_COMP_DEF_IMPL) AND
      (comp_table.COMP_NAME = X_COMP_NAME) AND
      (ROWNUM <= 1);


EXCEPTION
  WHEN OTHERS THEN
    RAISE;


END LOCATE_LLS_AND_INFO;


/* Locates a server of a particular type, given a server group, and obtains */
/* the connection information, based on some default rules.                 */
PROCEDURE LOCATE_LLS_AND_INFO_BY_GROUP
  (P_SERVER_GROUP_ID    IN  NUMBER
  ,P_SERVER_TYPE_UUID   IN  VARCHAR2
  ,P_WIRE_PROTOCOL      IN  VARCHAR2
  ,P_COMP_DEF_NAME      IN  VARCHAR2
  ,P_COMP_DEF_VERSION   IN  NUMBER
  ,P_COMP_DEF_IMPL      IN  VARCHAR2
  ,P_COMP_NAME          IN  VARCHAR2
  ,X_SERVER_ID_FOUND    OUT NOCOPY NUMBER
  ,X_USER_ADDRESS       OUT NOCOPY VARCHAR2
  ,X_DNS_NAME           OUT NOCOPY VARCHAR2
  ,X_IP_ADDRESS         OUT NOCOPY VARCHAR2
  ,X_PORT               OUT NOCOPY NUMBER
  ,X_COMP_NAME          OUT NOCOPY VARCHAR2
  ,P_TIMEOUT_TOLERANCE  IN NUMBER
  )
  AS
BEGIN


  IF ( (P_SERVER_GROUP_ID IS NULL) OR
       (P_SERVER_TYPE_UUID IS NULL) OR
       (P_WIRE_PROTOCOL IS NULL) OR
       (P_COMP_DEF_NAME IS NULL) OR
       (P_COMP_DEF_VERSION IS NULL) OR
       (P_COMP_DEF_IMPL IS NULL) )
  THEN
    raise_application_error
      (-20000
      ,'A required parameter is null' ||
       '. (P_SERVER_GROUP_ID = ' || P_SERVER_GROUP_ID ||
       ') (P_SERVER_TYPE_UUID = ' || P_SERVER_TYPE_UUID ||
       ') (P_WIRE_PROTOCOL = ' || P_WIRE_PROTOCOL ||
       ') (P_COMP_DEF_NAME = ' || P_COMP_DEF_NAME ||
       ') (P_COMP_DEF_VERSION = ' || P_COMP_DEF_VERSION ||
       ') (P_COMP_DEF_IMPL = ' || P_COMP_DEF_IMPL ||
       ')'
      ,TRUE );
  END IF;


  LOCATE_LEAST_LOADED_IN_GROUP(
    P_SERVER_GROUP_ID,
    P_SERVER_TYPE_UUID,
    NULL,
    x_server_id_found,
    p_timeout_tolerance
    );


  IF (x_server_id_found IS NULL) THEN
      raise_application_error
      (-20010,
       'Could not locate a server to connect to.',
       TRUE );
  END IF;


  IF (P_COMP_NAME IS NULL) THEN

    begin
    SELECT
      DISTINCT
        comp_table.COMP_NAME
      INTO
        X_COMP_NAME
      FROM
        IEO_SVR_SERVERS svr_table,
        IEO_SVR_COMP_DEFS cdef_table,
        IEO_SVR_COMPS comp_table,
        IEO_SVR_PROTOCOL_MAP prot_table
      WHERE
        (svr_table.SERVER_ID = comp_table.SERVER_ID) AND
        (svr_table.SERVER_ID = x_server_id_found) AND
        (comp_table.COMP_DEF_ID = cdef_table.COMP_DEF_ID) AND
        (prot_table.COMP_ID = comp_table.COMP_ID) AND
        (prot_table.WIRE_PROTOCOL = P_WIRE_PROTOCOL) AND
        (cdef_table.COMP_DEF_NAME = P_COMP_DEF_NAME) AND
        (cdef_table.COMP_DEF_VERSION = P_COMP_DEF_VERSION) AND
        (cdef_table.IMPLEMENTATION = P_COMP_DEF_IMPL) AND
        (ROWNUM <= 1);
    exception
      when others then
        raise_application_error
          (-20020
          ,'Could not find Component Definition.' ||
            '  (SERVER_ID = ' || x_server_id_found ||
            ') (WIRE_PROTOCOL = ' || P_WIRE_PROTOCOL || ')' ||
            ') (COMP_DEF_NAME = ' || P_COMP_DEF_NAME || ')' ||
            ') (COMP_DEF_VERSION = ' || P_COMP_DEF_VERSION || ')' ||
            ') (COMP_DEF_IMPL = ' || P_COMP_DEF_IMPL || ')'
          ,TRUE );
      end;


  ELSE

    X_COMP_NAME := P_COMP_NAME;

  END IF;


  SELECT
    DISTINCT
      svr_table.USER_ADDRESS,
      svr_table.DNS_NAME,
      svr_table.IP_ADDRESS,
      prot_table.PORT
    INTO
      X_USER_ADDRESS,
      X_DNS_NAME,
      X_IP_ADDRESS,
      X_PORT
    FROM
      IEO_SVR_SERVERS svr_table,
      IEO_SVR_COMP_DEFS cdef_table,
      IEO_SVR_COMPS comp_table,
      IEO_SVR_PROTOCOL_MAP prot_table
    WHERE
      (svr_table.SERVER_ID = x_server_id_found) AND
      (svr_table.SERVER_ID = comp_table.SERVER_ID) AND
      (comp_table.COMP_DEF_ID = cdef_table.COMP_DEF_ID) AND
      (prot_table.COMP_ID = comp_table.COMP_ID) AND
      (prot_table.WIRE_PROTOCOL = P_WIRE_PROTOCOL) AND
      (cdef_table.COMP_DEF_NAME = P_COMP_DEF_NAME) AND
      (cdef_table.COMP_DEF_VERSION = P_COMP_DEF_VERSION) AND
      (cdef_table.IMPLEMENTATION = P_COMP_DEF_IMPL) AND
      (comp_table.COMP_NAME = X_COMP_NAME) AND
      (ROWNUM <= 1);


EXCEPTION
  WHEN OTHERS THEN
    RAISE;


END LOCATE_LLS_AND_INFO_BY_GROUP;



PROCEDURE GET_SVR_CONNECT_INFO
(
    p_api_version       IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 ,
  	p_commit	    	IN  VARCHAR2,
    p_server_id       IN NUMBER,
    p_server_type_id  IN NUMBER,
    p_comp_def_name   IN VARCHAR2,
    p_comp_def_version IN NUMBER,
  	x_return_status		OUT NOCOPY	VARCHAR2 ,
    x_msg_count		OUT NOCOPY	NUMBER	,
    x_msg_data		OUT NOCOPY	VARCHAR2,
    x_comp_id     OUT NOCOPY NUMBER,
    x_comp_name   OUT NOCOPY VARCHAR2,
    x_wire_protocol OUT NOCOPY VARCHAR2,
    x_port      OUT NOCOPY NUMBER,
    x_ip        OUT NOCOPY VARCHAR2,
    x_base_url  OUT NOCOPY VARCHAR2,
    x_url       OUT NOCOPY VARCHAR2
)
IS
l_api_name			CONSTANT VARCHAR2(30)	:= 'GET_SVR_CONNECT_INFO';
l_api_version           	CONSTANT NUMBER 		:= 1.0;
x_err_num NUMBER;
x_err_msg VARCHAR2(256);

l_comp_def_id NUMBER;

BEGIN
    IF NOT FND_API.Compatible_API_Call (l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			        l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;
	--  Initialize API return status to failure
    x_return_status := FND_API.G_RET_STS_SUCCESS ;
    x_msg_count := 0;
    x_msg_data := null;
    x_comp_id := -1;
    x_comp_name := null;
    x_wire_protocol := null;
    x_port := -1;

	-- API body

    select ip_address into x_ip
    from ieo_svr_servers where server_id = p_server_id;

    SELECT COMP_DEF_ID INTO l_comp_def_id FROM IEO_SVR_COMP_DEFS WHERE
	  COMP_DEF_NAME = p_comp_def_name and
      COMP_DEF_VERSION = p_comp_def_version and
      SERVER_TYPE_ID = p_server_type_id;

    SELECT A.COMP_ID, A.COMP_NAME, B.WIRE_PROTOCOL, B.PORT
      into x_comp_id, x_comp_name, x_wire_protocol, x_port
      FROM IEO_SVR_COMPS A, IEO_SVR_PROTOCOL_MAP B
      WHERE A.COMP_ID = B.COMP_ID
      AND A.COMP_DEF_ID = l_comp_def_id
      AND A.SERVER_ID = p_server_id;

    x_base_url := x_wire_protocol
                 || '://'
                 || x_ip
                 || ':'
                 || x_port
                 || '/' ;
    x_url := x_base_url || x_comp_name;

    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;

EXCEPTION
        WHEN NO_DATA_FOUND then
            rollback;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            x_msg_count := 1;
            x_err_num := SQLCODE;
            x_err_msg := SUBSTR(SQLERRM, 1, 100);
            x_msg_data := 'GET_SVR_CONNECT_INFO: IEO_EXC_ERROR'
                        || ' ErrorCode = ' || x_err_num
                        || ' ErrorMsg = ' || x_err_msg;

        WHEN FND_API.G_EXC_ERROR THEN
            rollback;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            x_msg_count := 1;
            x_err_num := SQLCODE;
            x_err_msg := SUBSTR(SQLERRM, 1, 100);
            x_msg_data := 'GET_SVR_CONNECT_INFO: IEO_EXC_ERROR'
                        || ' ErrorCode = ' || x_err_num
                        || ' ErrorMsg = ' || x_err_msg;
            --dbms_output.put_line(x_msg_data);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            --dbms_output.put_line('Unexpected error');
            ROLLBACK;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            x_msg_count := 1;
            x_err_num := SQLCODE;
            x_err_msg := SUBSTR(SQLERRM, 1, 100);
            x_msg_data := 'GET_SVR_CONNECT_INFO: IEO_UNEXPECTED_ERROR'
                        || ' ErrorCode = ' || x_err_num
                        || ' ErrorMsg = ' || x_err_msg;
            --dbms_output.put_line(x_msg_data);
        WHEN OTHERS THEN
            rollback;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            x_msg_count := 1;
            x_err_num := SQLCODE;
            x_err_msg := SUBSTR(SQLERRM, 1, 100);
            x_msg_data := 'GET_SVR_CONNECT_INFO: IEO_OTHERS_ERROR'
                        || ' ErrorCode = ' || x_err_num
                        || ' ErrorMsg = ' || x_err_msg;
            --dbms_output.put_line(x_msg_data);
END GET_SVR_CONNECT_INFO;




PROCEDURE IS_SERVER_UP
(
    p_api_version       IN	NUMBER,
  	p_init_msg_list		IN	VARCHAR2 ,
  	p_commit	    	IN  VARCHAR2,
    p_server_id           IN  NUMBER,
    p_server_type_id IN NUMBER,
  	x_return_status		OUT NOCOPY	VARCHAR2 ,
    x_msg_count		OUT NOCOPY	NUMBER	,
    x_msg_data		OUT NOCOPY	VARCHAR2,
    x_is_server_up   OUT NOCOPY  VARCHAR2,
    x_server_status   OUT NOCOPY NUMBER,
    x_server_name    OUT NOCOPY VARCHAR2,
    x_server_group_name OUT NOCOPY VARCHAR2
)
IS
l_api_name			CONSTANT VARCHAR2(30)	:= 'IS_SERVER_UP';
l_api_version           	CONSTANT NUMBER 		:= 1.0;
x_err_num NUMBER;
x_err_msg VARCHAR2(256);

l_refresh_rate NUMBER;
l_last_update_date DATE;
l_sysdate DATE;
BEGIN
    IF NOT FND_API.Compatible_API_Call (l_api_version        	,
        	    	    	    	 	p_api_version        	,
   	       	    	 			        l_api_name 	    	,
		    	    	    	    	G_PKG_NAME )
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list ) THEN
		FND_MSG_PUB.initialize;
	END IF;
	--  Initialize API return status to failure
    x_return_status := FND_API.G_RET_STS_SUCCESS ;
    x_msg_count := 0;
    x_msg_data := null;
    x_is_server_up := FND_API.G_FALSE;
    x_server_status := -1;
    x_server_name := null;
    x_server_group_name := null;


    SELECT RT_REFRESH_RATE into l_refresh_rate
    FROM IEO_SVR_TYPES_B
    WHERE TYPE_ID = p_server_type_id;

    SELECT STATUS, LAST_UPDATE_DATE, SYSDATE NOW
    into x_server_status, l_last_update_date, l_sysdate
    FROM IEO_SVR_RT_INFO
    WHERE SERVER_ID = p_server_id;

    --dbms_output.put_line('sysdate= ' || l_sysdate);
    --dbms_output.put_line('last_update_date ' || l_last_update_date);
    --dbms_output.put_line('refresh_rate= ' || l_refresh_rate);
    --dbms_output.put_line('diff= ' || to_char(l_sysdate - l_last_update_date));

    if (x_server_status >= 4) then
        if (((l_sysdate - l_last_update_date)*1440) <= l_refresh_rate) then
            x_is_server_up := FND_API.G_TRUE;
        end if;
    end if;

    select a.server_name, b.group_name into x_server_name, x_server_group_name
    from ieo_Svr_servers a, ieo_Svr_groups b
    where a.server_id = p_server_id and a.member_svr_group_id = b.server_group_id;

    IF FND_API.To_Boolean( p_commit ) THEN
        COMMIT WORK;
    END IF;

EXCEPTION
        WHEN NO_DATA_FOUND then
            rollback;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            x_msg_count := 1;
            x_err_num := SQLCODE;
            x_err_msg := SUBSTR(SQLERRM, 1, 100);
            x_msg_data := 'IS_SERVER_UP: IEO_NO_DATA_FOUND_ERROR'
                        || ' ErrorCode = ' || x_err_num
                        || ' ErrorMsg = ' || x_err_msg;

        WHEN FND_API.G_EXC_ERROR THEN
            rollback;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            x_msg_count := 1;
            x_err_num := SQLCODE;
            x_err_msg := SUBSTR(SQLERRM, 1, 100);
            x_msg_data := 'IS_SERVER_UP: IEO_EXC_ERROR'
                        || ' ErrorCode = ' || x_err_num
                        || ' ErrorMsg = ' || x_err_msg;
            --dbms_output.put_line(x_msg_data);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            --dbms_output.put_line('Unexpected error');
            ROLLBACK;
            x_return_status := FND_API.G_RET_STS_ERROR ;
            x_msg_count := 1;
            x_err_num := SQLCODE;
            x_err_msg := SUBSTR(SQLERRM, 1, 100);
            x_msg_data := 'IS_SERVER_UP: IEO_UNEXPECTED_ERROR'
                        || ' ErrorCode = ' || x_err_num
                        || ' ErrorMsg = ' || x_err_msg;
            --dbms_output.put_line(x_msg_data);
        WHEN OTHERS THEN
            rollback;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            x_msg_count := 1;
            x_err_num := SQLCODE;
            x_err_msg := SUBSTR(SQLERRM, 1, 100);
            x_msg_data := 'IS_SERVER_UP: IEO_OTHERS_ERROR'
                        || ' ErrorCode = ' || x_err_num
                        || ' ErrorMsg = ' || x_err_msg;
            --dbms_output.put_line(x_msg_data);
END IS_SERVER_UP;


-- Clears agent mappings to a particular server.  This mapping is
-- required in case of a client crash but, needs cleared following
-- a server crash.
PROCEDURE CLEAR_SERVER_BINDINGS
  (P_SERVER_ID        IN  NUMBER
  )
IS

BEGIN
  UPDATE IEU_UWQ_AGENT_BINDINGS
    SET
      NOT_VALID = 'Y',
      LAST_UPDATE_DATE = SYSDATE
    WHERE
      SERVER_ID = P_SERVER_ID;

  COMMIT ;

EXCEPTION
  WHEN OTHERS THEN
    NULL;

END CLEAR_SERVER_BINDINGS;

-- PL/SQL Block
END IEO_SVR_UTIL_PVT;

/
