--------------------------------------------------------
--  DDL for Package Body IEU_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_PVT" AS
/* $Header: IEU_VB.pls 120.4.12010000.4 2008/10/24 09:57:47 majha ship $ */

 IEU_UWQ_SEL_RT_NODES_LIST     IEU_UWQ_SEL_RT_NODES_TAB;
 IEU_UWQ_RTNODE_BIND_VALS_LIST IEU_UWQ_RTNODE_BIND_VALS_TAB;

 SEL_RT_NODE_ID_LIST        NUMBER_TAB;
 CREATED_BY_LIST            NUMBER_TAB;
 CREATION_DATE_LIST         DATE_TAB;
 LAST_UPDATED_BY_LIST       NUMBER_TAB;
 LAST_UPDATE_DATE_LIST      DATE_TAB;
 LAST_UPDATE_LOGIN_LIST     NUMBER_TAB;
 RESOURCE_ID_LIST           NUMBER_TAB;
 SEL_ENUM_ID_LIST           NUMBER_TAB;
 NODE_ID_LIST               NUMBER_TAB;
 NODE_TYPE_LIST             NUMBER_TAB;
 NODE_LABEL_LIST            NODE_LABEL_TAB;
 COUNT_LIST                 NUMBER_TAB;
 DATA_SOURCE_LIST           DATA_SOURCE_TAB;
 VIEW_NAME_LIST             VIEW_NAME_TAB;
 MEDIA_TYPE_ID_LIST         NUMBER_TAB;
 SEL_ENUM_PID_LIST          NUMBER_TAB;
 NODE_PID_LIST              NUMBER_TAB;
 NODE_WEIGHT_LIST           NUMBER_TAB;
 WHERE_CLAUSE_LIST          WHERE_CLAUSE_TAB;
 HIDE_IF_EMPTY_LIST         HIDE_IF_EMPTY_TAB;
 NOT_VALID_LIST             NOT_VALID_TAB;
 SECURITY_GROUP_ID_LIST     NUMBER_TAB;
 OBJECT_VERSION_NUMBER_LIST NUMBER_TAB;
 REFRESH_VIEW_NAME_LIST     REFRESH_VIEW_NAME_TAB;
 RES_CAT_ENUM_FLAG_LIST     RES_CAT_ENUM_FLAG_TAB;
 REFRESH_VIEW_SUM_COL_LIST  REFRESH_VIEW_SUM_COL_TAB;
 NODE_DEPTH_LIST            NUMBER_TAB;

 BIND_OBJ_VERSION_NUMBER_LIST    NUMBER_TAB;
 BIND_CREATED_BY_LIST            NUMBER_TAB;
 BIND_CREATION_DATE_LIST         DATE_TAB;
 BIND_LAST_UPDATED_BY_LIST       NUMBER_TAB;
 BIND_LAST_UPDATE_DATE_LIST      DATE_TAB;
 BIND_LAST_UPDATE_LOGIN_LIST     NUMBER_TAB;
 BIND_SECURITY_GROUP_ID_LIST     NUMBER_TAB;
 BIND_SEL_RT_NODE_ID_LIST        NUMBER_TAB;
 BIND_RESOURCE_ID_LIST           NUMBER_TAB;
 BIND_NODE_ID_LIST               NUMBER_TAB;
 BIND_VAR_NAME_LIST              BIND_VAR_NAME_TAB;
 BIND_VAR_VALUE_LIST             BIND_VAR_VALUE_TAB;
 BIND_VAR_DATATYPE_LIST          BIND_VAR_DATATYPE_TAB;
 NOT_VALID_FLAG_LIST             NOT_VALID_FLAG_TAB;

 SEL_RT_NODE_ID_REF_LIST        NUMBER_TAB;
 REF_COUNT_LIST                 NUMBER_TAB;

 L_IND_LIST_ITR    NUMBER;
 L_RT_NODES_ITR    NUMBER;
 L_BIND_VALS_ITR   NUMBER;
 L_SEL_REF_COUNTER NUMBER;

 array_dml_errors EXCEPTION;
 PRAGMA exception_init(array_dml_errors, -24381);

-- Sub-Program Units


/* Used to determine what style of WB is set for an agent */
FUNCTION DETERMINE_WB_STYLE ( RESOURCE_ID IN NUMBER ) RETURN VARCHAR2
  AS

  l_wb_style VARCHAR2(1000);

BEGIN

  --  Work Blending Styles are as follows:
  --
  --  'N'    -    Not Blended
  --  'O'    -    Optional Blended
  --  'F'    -    Force Blended

  BEGIN
    FND_PROFILE.GET( 'IEU_BLENDING_STYLE', l_wb_style );
  EXCEPTION
    WHEN OTHERS THEN
      l_wb_style := 'N';
  END;

  --
  -- Putting some protective logic in here... if we get an invalid style
  -- then we'll force it to 'N' not-blended.
  --
  -- This is because we don't have time to implement the LOV logic for the
  -- profile SQL statement, and I'm worried that someone can enter crap for
  -- the blending style.
  --
  if ( (l_wb_style <> 'F') and (l_wb_style <> 'SF')
       and (l_wb_style <> 'O') and (l_wb_style <> 'SO') )
  then
    l_wb_style := 'N';
  end if;

  return l_wb_style;

END DETERMINE_WB_STYLE;


/* Used to determine classes to load by the client plugin loader */
PROCEDURE DETERMINE_CLI_PLUGINS
  (P_RESOURCE_ID  IN  NUMBER
  ,X_CLASSES      OUT NOCOPY ClientClasses
  )
  AS

  l_media_types  EligibleMediaList;
  l_class        IEU_UWQ_CLI_MED_PLUGINS.CLI_PLUGIN_CLASS%TYPE;

  j  NUMBER := 0;

BEGIN

  --
  -- We detect what the agent can work on, and relate this to what plugins
  -- need to be loaded (based on media type id).
  --
  DETERMINE_ELIGIBLE_MEDIA_TYPES(
    P_RESOURCE_ID,
    l_media_types );

  IF (l_media_types is not null and l_media_types.COUNT > 0) THEN

--      x_classes := ClientClasses();

    FOR i IN l_media_types.FIRST..l_media_types.LAST LOOP

      BEGIN

        SELECT DISTINCT
          ptable.CLI_PLUGIN_CLASS
        INTO
          l_class
        FROM
          IEU_UWQ_CLI_MED_PLUGINS ptable
        WHERE
          (ptable.MEDIA_TYPE_ID = l_media_types(i).media_type_id);

      EXCEPTION
        WHEN OTHERS THEN
          l_class := '';

      END;

      IF (l_class is not null) THEN
        j := j+1;
        X_CLASSES(j) := l_class;
      END IF;

    END LOOP;

  END IF;

/*
  IF (FND_PROFILE.VALUE('IEU_MDEN_TELEPHONY') = 'Y')
  THEN
    --
    -- assume that the plugin for INBOUND or OUTBOUND will do...
    -- picking by who's been around the longest...
    --
    BEGIN
      SELECT
        DISTINCT
          ptable.CLI_PLUGIN_CLASS
        INTO
          l_class
        FROM
          IEU_UWQ_CLI_MED_PLUGINS ptable
        WHERE
          ( (ptable.MEDIA_TYPE_ID = IEU_CONSTS_PUB.G_MTID_INBOUND_TELEPHONY)
              OR
            (ptable.MEDIA_TYPE_ID = IEU_CONSTS_PUB.G_MTID_OUTBOUND_TELEPHONY)
              OR
            (ptable.MEDIA_TYPE_ID = IEU_CONSTS_PUB.G_MTID_ADV_OUTB_TELEPHONY))
            AND
          (ROWNUM <= 1)
        ORDER BY
          ptable.CLI_PLUGIN_ID;
    EXCEPTION
      WHEN OTHERS THEN
        l_class := '';
    END;

    --
    -- make sure the class gets loaded at run-time...
    --
    IF (l_class is not null) THEN
      j := j+1;
      X_CLASSES(j) := l_class;
    END IF;

  END IF;


  IF (FND_PROFILE.VALUE('IEU_MDEN_EMAIL') = 'Y')
  THEN

    --
    -- assume that the plugin for one of the email enablers will do...
    -- picking by who's been around the longest...
    --
    BEGIN
      SELECT
        DISTINCT
          ptable.CLI_PLUGIN_CLASS
        INTO
          l_class
        FROM
          IEU_UWQ_CLI_MED_PLUGINS ptable
        WHERE
          ( (ptable.MEDIA_TYPE_ID = IEU_CONSTS_PUB.G_MTID_INBOUND_EMAIL) OR
            (ptable.MEDIA_TYPE_ID = IEU_CONSTS_PUB.G_MTID_DIRECT_EMAIL) ) AND
          (ROWNUM <= 1)
        ORDER BY
          ptable.CLI_PLUGIN_ID;
    EXCEPTION
      WHEN OTHERS THEN
        l_class := '';
    END;

    --
    -- make sure the class gets loaded at run-time...
    --
    IF (l_class is not null) THEN
      j := j+1;
      X_CLASSES(j) := l_class;
    END IF;

  END IF;
*/

END DETERMINE_CLI_PLUGINS;

PROCEDURE DETERMINE_ALL_MEDIA_TYPES_EXTN
  (P_RESOURCE_ID    IN  NUMBER,
   X_ALL_MEDIA_LIST OUT NOCOPY EligibleAllMediaList,
   X_EXTN_FLAG      OUT NOCOPY VARCHAR2)
AS

BEGIN
    DETERMINE_ALL_MEDIA_TYPES(P_RESOURCE_ID, X_ALL_MEDIA_LIST);
    X_EXTN_FLAG := IS_TEL_EXTN_REQUIRED (X_ALL_MEDIA_LIST);
END DETERMINE_ALL_MEDIA_TYPES_EXTN;

PROCEDURE DETERMINE_ALL_MEDIA_TYPES

  (P_RESOURCE_ID   IN  NUMBER,
   X_ALL_MEDIA_LIST OUT NOCOPY EligibleAllMediaList
   ) AS

   l_media_type_uuid    varchar2(38);
   l_ctr                pls_integer;
   l_elg_media_list     EligibleMediaList;
   l_all_media_list     EligibleAllMediaList;
   l_uuid_string_list   varchar2(4000);

   l_tel_reqd_flag      varchar2(1);
   l_svr_connect_rule   varchar2(255);
   l_tel_media_type     varchar2(255);

   str   varchar2(255);
   text  varchar2(255);
   pos   number;
   len   number;
   l_media_type_uuid_1    varchar2(38);
   l_media_type_id_1      number;

BEGIN

    DETERMINE_ELIGIBLE_MEDIA_TYPES(P_RESOURCE_ID, l_elg_media_list);

    l_ctr := l_elg_media_list.count;

    FOR i IN 1..l_elg_media_list.COUNT LOOP

      l_media_type_uuid := l_elg_media_list(i).MEDIA_TYPE_UUID;

      begin
        select a.tel_reqd_flag, decode(b.login_rule_type, 'FUNC', b.login_rule, null),
               decode(b.login_rule_type, 'MUUID', b.login_rule, null)
          into l_tel_reqd_flag, l_svr_connect_rule, l_tel_media_type
          from ieu_uwq_media_types_b a, ieu_uwq_login_rules_b b
         where a.media_type_uuid   = l_media_type_uuid
           and a.svr_login_rule_id = b.svr_login_rule_id(+);
      exception
         when no_data_found then null;
      end;

      X_ALL_MEDIA_LIST(i).MEDIA_TYPE_ID         := l_elg_media_list(i).MEDIA_TYPE_ID;
      X_ALL_MEDIA_LIST(i).MEDIA_TYPE_UUID       := l_elg_media_list(i).MEDIA_TYPE_UUID;
      X_ALL_MEDIA_LIST(i).tel_reqd_flag         := l_tel_reqd_flag;
      X_ALL_MEDIA_LIST(i).svr_connect_rule      := l_svr_connect_rule;
      X_ALL_MEDIA_LIST(i).tel_media_type        := l_tel_media_type;
      X_ALL_MEDIA_LIST(i).ORIGIN_FLAG           := 'E';

      if  l_svr_connect_rule is not null then
          execute immediate
          'begin '|| l_svr_connect_rule || '(' || ':p_resource_id,' || ':p_media_type_uuid,' || ':l_uuid_string_list);end;'
          using  in p_resource_id, l_media_type_uuid, out l_uuid_string_list;
      elsif l_tel_media_type is not null then
          l_uuid_string_list := l_tel_media_type;
      end if;

      l_svr_connect_rule := null;
      l_tel_media_type   := null;

      ------------- Parse string into separate UUID's ------------

        l_ctr := i + 1;

        str  := l_uuid_string_list;
        len  := length(str);
        select instr(str, '|') into pos from dual;
        while len > 0 loop
        select instr(str, '|') into pos from dual;
        if pos = 0 then
           text := str;
           str  := null;
        else
           text := substr(str,1, pos -1);
           str  := substr(str, pos + 1, len);
        end if;
        len  := length(str);

        l_media_type_uuid_1 := text;

        begin

         select a.media_type_id, a.media_type_uuid, a.tel_reqd_flag, decode(b.login_rule_type, 'FUNC', b.login_rule, null),
               decode(b.login_rule_type, 'MUUID', b.login_rule, null)
          into l_media_type_id_1, l_media_type_uuid_1, l_tel_reqd_flag, l_svr_connect_rule, l_tel_media_type
          from ieu_uwq_media_types_b a, ieu_uwq_login_rules_b b
         where a.media_type_uuid   = l_media_type_uuid_1
           and a.svr_login_rule_id = b.svr_login_rule_id(+);

           X_ALL_MEDIA_LIST(l_ctr).MEDIA_TYPE_ID         := l_media_type_id_1;
           X_ALL_MEDIA_LIST(l_ctr).MEDIA_TYPE_UUID       := l_media_type_uuid_1;
           X_ALL_MEDIA_LIST(l_ctr).tel_reqd_flag         := l_tel_reqd_flag;
           X_ALL_MEDIA_LIST(l_ctr).svr_connect_rule      := l_svr_connect_rule;
           X_ALL_MEDIA_LIST(l_ctr).tel_media_type        := l_tel_media_type;
           X_ALL_MEDIA_LIST(l_ctr).ORIGIN_FLAG           := 'R';

           l_ctr := l_ctr + 1;
        exception
           when no_data_found then null;
        end;
     end loop;
    END LOOP;
END DETERMINE_ALL_MEDIA_TYPES;


FUNCTION IS_TEL_EXTN_REQUIRED (p_eligibleallmedialist IN EligibleAllMediaList ) RETURN VARCHAR2
  AS
BEGIN
  IF p_eligibleAllMediaList is not null or p_eligibleAllMediaList.count > 0 then
     for i in 1..p_eligibleAllMediaList.count loop
         if p_eligibleAllMediaList(i).tel_reqd_flag = 'Y'
            and p_eligibleAllMediaList(i).origin_flag  = 'E'
            and p_eligibleAllMediaList(i).svr_connect_rule is null
            and p_eligibleAllMediaList(i).tel_media_type is null then
            RETURN 'Y';
         end if;
         if p_eligibleAllMediaList(i).origin_flag = 'R'
            and p_eligibleAllMediaList(i).tel_reqd_flag = 'Y' then
            RETURN 'Y';
         end if;
     end loop;
  END IF;
  RETURN 'N';
END;

/* Used to determine the eligible media types the resource can work on */
PROCEDURE DETERMINE_ELIGIBLE_MEDIA_TYPES
  (P_RESOURCE_ID  IN  NUMBER
  ,X_PLUGINS      OUT NOCOPY EligibleMediaList
  )
  AS

  CURSOR c_types IS
  SELECT
    DISTINCT
      mttab.MEDIA_TYPE_ID,
      mttab.MEDIA_TYPE_UUID
    FROM
-- sjm got rid of server side checks altogether for Client Provider enh.
-- this is simpler and more flexible for 3rd party providers
-- now just check for all media types that have media provider plugins defined
/*      JTF_RS_RESOURCE_EXTNS restab,
      IEO_SVR_SERVERS svrtab,
      IEO_SVR_SERVERS svrtab2,
      IEU_UWQ_SVR_MPS_MMAPS mmptab,
      IEU_UWQ_MEDIA_TYPES_B mttab
    WHERE
      (restab.RESOURCE_ID = p_resource_id) AND
      (restab.SERVER_GROUP_ID IS NOT NULL) AND
      ( (svrtab.MEMBER_SVR_GROUP_ID IS NOT NULL) AND
        (
          (restab.SERVER_GROUP_ID = svrtab.MEMBER_SVR_GROUP_ID) OR
            (
              (svrtab.USING_SVR_GROUP_ID IS NOT NULL) AND
              (svrtab.SERVER_ID = svrtab2.SERVER_ID) AND
              (svrtab.USING_SVR_GROUP_ID = svrtab2.MEMBER_SVR_GROUP_ID) AND
              (svrtab2.MEMBER_SVR_GROUP_ID = restab.SERVER_GROUP_ID)
            )
        )
      ) AND
      (svrtab.TYPE_ID = mmptab.SVR_TYPE_ID) AND
      (mmptab.MEDIA_TYPE_ID = mttab.MEDIA_TYPE_ID);
*/
      IEU_UWQ_MEDIA_TYPES_B mttab
    WHERE
      mttab.MEDIA_TYPE_ID in
        (SELECT MEDIA_TYPE_ID
         FROM IEU_UWQ_SVR_MPS_MMAPS
         UNION  -- 10/5/04 changed to union #3926849
           SELECT subclimap.MEDIA_TYPE_ID
            FROM IEU_CLI_PROV_PLUGIN_MED_MAPS subclimap,
                 IEU_CLI_PROV_PLUGINS cliplugins
            WHERE
              subclimap.PLUGIN_ID = cliplugins.PLUGIN_ID
              AND (cliplugins.IS_ACTIVE_FLAG is NULL
                OR upper(cliplugins.IS_ACTIVE_FLAG) = 'Y')

        );

  i  number := 0;

 l_valid  boolean;
 l_doCheck  boolean;
 L_WORK_Q_ENABLE_PROFILE_OPTION IEU_UWQ_SEL_ENUMERATORS.WORK_Q_ENABLE_PROFILE_OPTION%TYPE;
 l_profile_id  NUMBER;

BEGIN

  --
  -- We will determine the eligible media types based on the RESOURCE_ID.
  --


  --
  -- Don't have any admin to this currently, so will select based on the
  -- servers in the server group the agent is assigned to.  Another way to
  -- implement this is to have more param/values associated with the
  -- resource that are y/n flags (i.e., Inbound Telephony Enabled, etc).
  --

--  x_plugins := EligibleMediaList();

  FOR c_rec IN c_types LOOP

    l_valid := TRUE;
    l_doCheck := TRUE;

    BEGIN
     SELECT WORK_Q_ENABLE_PROFILE_OPTION
     INTO   L_WORK_Q_ENABLE_PROFILE_OPTION
     FROM   IEU_UWQ_SEL_ENUMERATORS
     WHERE  media_type_id = c_rec.MEDIA_TYPE_ID
      AND  NVL(not_valid_flag, 'N') = 'N';
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
      -- 07/24/02: NOW Assume there must be a valid profile option defined!
      l_doCheck := FALSE;
      l_valid := FALSE;
    END;

    -- 07/24/02: Now assume we must have a valid profile option
    IF (l_doCheck = TRUE)
    THEN
    --  TODO: find a better way to determine a valid profile option:
      BEGIN
        SELECT
          PROFILE_OPTION_ID
        INTO
          l_profile_id
        FROM
          FND_PROFILE_OPTIONS
        WHERE
          PROFILE_OPTION_NAME = L_WORK_Q_ENABLE_PROFILE_OPTION;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_doCheck := FALSE;
          l_valid := FALSE;
      END;

      -- Assume a profile value of Y or NULL is valid!
      IF (FND_PROFILE.VALUE(L_WORK_Q_ENABLE_PROFILE_OPTION) = 'N'
          AND l_doCheck = TRUE)
      THEN
        l_valid := FALSE;
      END IF;
    END IF;

    IF (l_valid = TRUE)
    THEN
--    x_plugins.EXTEND;
--    x_plugins(x_plugins.LAST).MEDIA_TYPE_ID   := c_rec.MEDIA_TYPE_ID;
--    x_plugins.EXTEND;
--    x_plugins(x_plugins.LAST).MEDIA_TYPE_UUID := c_rec.MEDIA_TYPE_UUID;

      i := i + 1;

      x_plugins(i).MEDIA_TYPE_ID   := c_rec.MEDIA_TYPE_ID;
      x_plugins(i).MEDIA_TYPE_UUID := c_rec.MEDIA_TYPE_UUID;

    END IF;

  END LOOP;


EXCEPTION
  WHEN OTHERS THEN
    NULL;

END DETERMINE_ELIGIBLE_MEDIA_TYPES;

/* Used to determine if a particular media is eligible */
FUNCTION IS_MEDIA_TYPE_ELIGIBLE
  (P_RESOURCE_ID      IN  NUMBER
  ,P_MEDIA_TYPE_UUID  IN  VARCHAR2
  ) RETURN VARCHAR2
  AS

  l_media_types  EligibleMediaList;

BEGIN


  -- NOTE:  This implementation really bothers me because it's slow... I
  --        originally had this doing the specific select required.
  --        However, with the addition of the User Profile options to turn
  --        off specific Queues, I don't want to spread that logic out.
  --        Therefore, I'm just using the DETERMINE, and looking for the
  --        one we're interested in.  Slower, but a bit more maintainable.


  DETERMINE_ELIGIBLE_MEDIA_TYPES(
    P_RESOURCE_ID,
    l_media_types );


  IF (l_media_types is null OR l_media_types.COUNT <= 0) THEN
    RETURN 'N';
  END IF;


  FOR i IN l_media_types.FIRST..l_media_types.LAST LOOP

    IF (l_media_types(i).media_type_uuid = P_MEDIA_TYPE_UUID) THEN
      RETURN 'Y';
    END IF;

  END LOOP;


  RETURN 'N';


EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return 'N';

  WHEN OTHERS THEN
    return 'N';

END IS_MEDIA_TYPE_ELIGIBLE;

/* Used to determine if a particular media is eligible
FUNCTION IS_MEDIA_TYPE_ELIGIBLE
  (P_RESOURCE_ID      IN  NUMBER
  ,P_MEDIA_TYPE_UUID  IN  VARCHAR2
  ) RETURN BOOLEAN
  AS

  l_media_types  EligibleMediaList;

BEGIN


  -- NOTE:  This implementation really bothers me because it's slow... I
  --        originally had this doing the specific select required.
  --        However, with the addition of the User Profile options to turn
  --        off specific Queues, I don't want to spread that logic out.
  --        Therefore, I'm just using the DETERMINE, and looking for the
  --        one we're interested in.  Slower, but a bit more maintainable.


  DETERMINE_ELIGIBLE_MEDIA_TYPES(
    P_RESOURCE_ID,
    l_media_types );


  IF (l_media_types is null OR l_media_types.COUNT <= 0) THEN
    RETURN FALSE;
  END IF;


  FOR i IN l_media_types.FIRST..l_media_types.LAST LOOP

    IF (l_media_types(i).media_type_uuid = P_MEDIA_TYPE_UUID) THEN
      RETURN TRUE;
    END IF;

  END LOOP;


  RETURN FALSE;


EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;

  WHEN OTHERS THEN
    return FALSE;


END IS_MEDIA_TYPE_ELIGIBLE;
*/

/* Used to determine if a particular media is eligible */
FUNCTION IS_MEDIA_TYPE_ELIGIBLE
  (P_RESOURCE_ID    IN  NUMBER
  ,P_MEDIA_TYPE_ID  IN  NUMBER
  ) RETURN BOOLEAN
  AS

  l_media_types  EligibleMediaList;

BEGIN


  -- NOTE:  This implementation really bothers me because it's slow... I
  --        originally had this doing the specific select required.
  --        However, with the addition of the User Profile options to turn
  --        off specific Queues, I don't want to spread that logic out.
  --        Therefore, I'm just using the DETERMINE, and looking for the
  --        one we're interested in.  Slower, but a bit more maintainable.


  DETERMINE_ELIGIBLE_MEDIA_TYPES(
    P_RESOURCE_ID,
    l_media_types );


  IF (l_media_types is null OR l_media_types.COUNT <= 0) THEN
    RETURN FALSE;
  END IF;


  FOR i IN l_media_types.FIRST..l_media_types.LAST LOOP

 --   dbms_output.put_line('l_media_types(i).media_type_id '||l_media_types(i).media_type_id||' P_MEDIA_TYPE_ID: '||P_MEDIA_TYPE_ID);
    IF (l_media_types(i).media_type_id = P_MEDIA_TYPE_ID) THEN
      RETURN TRUE;
    END IF;

  END LOOP;


  RETURN FALSE;


EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;

  WHEN OTHERS THEN
    return FALSE;

END IS_MEDIA_TYPE_ELIGIBLE;


/* Used to build nodes table for Forms tree view. */
PROCEDURE ENUMERATE_WORK_NODES
  (P_RESOURCE_ID IN NUMBER
  ,P_LANGUAGE    IN VARCHAR2
  ,P_SOURCE_LANG IN VARCHAR2
  )
  AS

  l_savepoint_valid NUMBER(1):=0;

  l_media_count  PLS_INTEGER;
  l_node_label   VARCHAR2(80);
  l_wb_style     VARCHAR2(2);
  l_media_eligible VARCHAR2(5) := null;

  CURSOR c_enum IS
    SELECT
      e.SEL_ENUM_ID sel_enum_id,
      e.ENUM_PROC enum_proc,
      nvl(IEU_UWQ_UTIL_PUB.to_number_noerr(fnd_profile.value(e.work_q_order_profile_option)), e.work_q_order_system_default) display_order,
      e.work_q_register_type,
      e.media_type_id
    FROM
      IEU_UWQ_SEL_ENUMERATORS e
    WHERE EXISTS (select 'x' from FND_PROFILE_OPTIONS b
                  where b.PROFILE_OPTION_NAME = upper(e.work_q_enable_profile_option)
			   and (b.end_date_active is null                     -- Niraj, bug 4738501, Added
			   or  trunc(b.end_date_active) > trunc(sysdate)))    -- Niraj, Bug 5031721, Added
      AND ((e.NOT_VALID_FLAG is NULL) OR (e.NOT_VALID_FLAG = 'N')) AND
      (nvl(fnd_profile.value(e.work_q_enable_profile_option),'Y') = 'Y')
    ORDER BY
      display_order;

BEGIN

    UPDATE IEU_UWQ_SEL_RT_NODES
    SET not_valid = 'Y'
    WHERE resource_id = P_RESOURCE_ID;

    UPDATE IEU_UWQ_RTNODE_BIND_VALS
    SET not_valid_flag = 'Y'
    WHERE resource_id = P_RESOURCE_ID;

  --
  -- We simply call the enumeration procedures for each media type and pass
  -- the resource id and media type uuid.  The repetition of the uuid is in
  -- case we want to have some procedures that are capable of doing multiple
  -- media types.  The procedure can simply check the UUID if needed.
  --

  l_wb_style := ieu_pvt.determine_wb_style( p_resource_id );

  FOR cur_rec IN c_enum LOOP

    BEGIN

     l_media_eligible := null;

     if ( ( (l_wb_style = 'F') or  (l_wb_style = 'SF') )
          and (cur_rec.work_q_register_type = 'M') )            -- Full/Simple Forced Blending
     then

       IEU_DEFAULT_MEDIA_ENUMS_PVT.create_blended_node( p_resource_id, p_language, p_source_lang );

     else

      if ( ( (l_wb_style = 'O') or (l_wb_style = 'SO') )
            and (cur_rec.work_q_register_type = 'M') )          -- Full/Simple Optional Blending
      then

             IEU_DEFAULT_MEDIA_ENUMS_PVT.create_blended_node( p_resource_id, p_language, p_source_lang );

      end if;
       --
       -- Note that P_RESOURCE_ID is not escaped because it is a number, whereas
       -- the MEDIA_TYPE_UUID is a string, so must be in single quotes.
       --

      -- Here we are excluding Inbound and Acquired email as these will not have servers now.
      IF ( not( (cur_rec.media_type_id = 10001) or (cur_rec.media_type_id = 10008) ))
      THEN

       IF ((cur_rec.work_q_register_type = 'M') and (cur_rec.media_type_id is not NULL))
       THEN

           IF (IEU_PVT.IS_MEDIA_TYPE_ELIGIBLE
                 (P_RESOURCE_ID ,cur_rec.media_type_id) = FALSE)
           THEN
              l_media_eligible := 'FALSE';
           ELSE
              l_media_eligible := 'TRUE';
           END IF;

       END IF;
      END IF;

 --      dbms_output.put_line('l_media_eligible : '||l_media_eligible||' enum proc : '||cur_rec.enum_proc);
       IF ( (l_media_eligible is null) or (l_media_eligible = 'TRUE') )
       THEN

              EXECUTE IMMEDIATE
                'begin ' || cur_rec.ENUM_PROC ||
                '( ' ||
                   'p_resource_id => :1, ' ||
                   'p_language => :2, ' ||
                   'p_source_lang => :3, ' ||
                   'p_sel_enum_id => :4 ' ||
                '); end;'
             USING
               IN P_RESOURCE_ID,
               IN P_LANGUAGE,
               IN P_SOURCE_LANG,
               IN cur_rec.SEL_ENUM_ID;

 --            dbms_output.put_line('l_media_eligible : '||l_media_eligible||' enum proc : '||cur_rec.enum_proc);

            -- if we don't commit every time, the entire transaction will be rolled
            -- back if one of the enumerators does a rollback... including any
            -- previous enumerators progress!!
            -- Ray Cardillo 06-24-2000
            -- sjm 09/01/00 for efficiency don't do a commit on ea. iteration
            --COMMIT;
            -- Instead we'll roll back to the last successful upon exception
            SAVEPOINT last_enum_success;

           -- if we got here, the savepoint has been executed
           l_savepoint_valid := 1;

       END IF;

      end if;

     EXCEPTION
      WHEN OTHERS THEN
        -- Adding this condition will prevent an error if the exception
        -- was caused by the first record

        if (l_savepoint_valid = 1) then
          ROLLBACK TO last_enum_success;
        end if;
    END;


  END LOOP;


  -- Removed call to CREATE_MYWORK_NODE because we're now putting that
  -- node in as an enumerated entity of it's own.
  --
  -- R.Cardillo  02/07/01


  --
  -- After all nodes have enumerated, we'll see if we need to add the
  -- special "Media" node or not.  This directly corresponds to the new
  -- logic in ADD_UWQ_NODE_DATA that forces the root node to "Media" if
  -- MEDIA_TYPE_ID is valid.  (Ray Cardillo / 05-22-01)
  --
  begin
    select
      rownum
    into
      l_media_count
    from
      IEU_UWQ_SEL_RT_NODES
    where
      (resource_id = p_resource_id) and
      (not_valid = 'N') and
      (media_type_id IS NOT NULL) and
      (rownum = 1);
  exception
    when others then
      l_media_count := 0;
  end;


  if (l_media_count >= 1)
  then

    Select
      meaning
    into
      l_node_label
    from
      fnd_lookup_values_vl
    where
      (lookup_type         = 'IEU_NODE_LABELS') and
      (view_application_id = 696) and
      (lookup_code         = 'IEU_MEDIA_LBL');

    IEU_UWQ_SEL_RT_NODES_PKG.LOAD_ROW (
      X_RESOURCE_ID          => p_resource_id,
      X_SEL_ENUM_ID          => 0,
      X_NODE_ID              => IEU_CONSTS_PUB.G_SNID_MEDIA,
      X_NODE_TYPE            => 0,
      X_NODE_PID             => 0,
      X_NODE_WEIGHT          => nvl(IEU_UWQ_UTIL_PUB.to_number_noerr(fnd_profile.value('IEU_QOR_MEDIA')) , IEU_CONSTS_PUB.G_SNID_MEDIA),
      X_NODE_DEPTH           => 1,
      X_SEL_ENUM_PID         => 0,
      X_MEDIA_TYPE_ID        => NULL,
      X_COUNT                => 0,
      X_DATA_SOURCE          => 'IEU_UWQ_MEDIA_DS',
      X_VIEW_NAME            => 'IEU_UWQ_MEDIA_V',
      X_WHERE_CLAUSE         => '',
      X_HIDE_IF_EMPTY        => NULL,
      X_NOT_VALID            => 'N',
      X_NODE_LABEL           => l_node_label,
      X_REFRESH_VIEW_NAME    => 'IEU_UWQ_MEDIA_V',
      X_RES_CAT_ENUM_FLAG    => NULL,
      X_REFRESH_VIEW_SUM_COL => 'QUEUE_COUNT'
     );

  end if;


  COMMIT;

EXCEPTION
    WHEN OTHERS THEN
         -- Adding this condition will prevent an error if the exception
         -- was caused in the update statements
         ROLLBACK WORK;

END ENUMERATE_WORK_NODES;


/* Used to refresh nodes table for Forms tree view. */
PROCEDURE REFRESH_WORK_NODE_COUNTS( P_RESOURCE_ID IN NUMBER )
AS

  l_count         NUMBER;
  l_where_clause  VARCHAR2(30000);
  l_refresh_view_name varchar2(200);
  l_refresh_view_sum_col varchar2(200);
  l_sel_rt_node_id number;
  l_node_id number(10);
  l_node_pid number(10);
  l_sel_enum_id number(15);
  l_res_cat_enum_flag varchar2(1);
  l_view_name varchar2(512);
  l_media_type_id number;

  l_tsk_count         NUMBER;
  l_tsk_where_clause  VARCHAR2(30000);
  l_tsk_refresh_view_name varchar2(200);
  l_tsk_refresh_view_sum_col varchar2(200);
  l_tsk_sel_rt_node_id number;
  l_tsk_node_id number(10);
  l_tsk_node_pid number(10);
  l_tsk_sel_enum_id number(15);
  l_tsk_res_cat_enum_flag varchar2(1);
  l_tsk_view_name varchar2(512);
  l_tsk_media_type_id number;
  l_bindvallist    BindValList;
  i  number := 1;

  j NUMBER;
  l_bulk_count NUMBER;

  CURSOR c_nodes IS
    SELECT
      rt_nodes.sel_rt_node_id,
      rt_nodes.node_id,
      rt_nodes.node_pid,
      rt_nodes.view_name,
      rt_nodes.where_clause,
      rt_nodes.media_type_id,
      rt_nodes.sel_enum_id,
      rt_nodes.refresh_view_name,
      rt_nodes.refresh_view_sum_col,
      rt_nodes.res_cat_enum_flag,
      rt_nodes.node_depth
    FROM

      ieu_uwq_sel_rt_nodes rt_nodes
    WHERE
      (rt_nodes.resource_id = p_resource_id) AND
      (rt_nodes.node_id > 0) AND
/*      (rt_nodes.node_id <> IEU_CONSTS_PUB.G_SNID_MEDIA) and */
      (rt_nodes.not_valid = 'N');

/*
 CURSOR c_media_nodes IS
    SELECT
      rt_nodes.sel_rt_node_id,
      rt_nodes.node_id,
      rt_nodes.node_pid,
      rt_nodes.where_clause,
      rt_nodes.sel_enum_id,
      rt_nodes.refresh_view_name,
      rt_nodes.refresh_view_sum_col,
      rt_nodes.res_cat_enum_flag,
      rt_nodes.view_name
    FROM
      ieu_uwq_sel_rt_nodes rt_nodes
    WHERE
      (rt_nodes.resource_id = p_resource_id) AND
      (rt_nodes.node_id = IEU_CONSTS_PUB.G_SNID_MEDIA) and
      (rt_nodes.not_valid = 'N');
*/

  CURSOR c_bindVal IS
    SELECT
      rt_nodes_bind_val.SEL_RT_NODE_ID,
      rt_nodes_bind_val.node_id,
      rt_nodes_bind_val.BIND_VAR_NAME,
      rt_nodes_bind_val.bind_var_value
    FROM
      ieu_uwq_rtnode_bind_vals rt_nodes_bind_val
    WHERE
      (rt_nodes_bind_val.resource_id = p_resource_id) AND
      (rt_nodes_bind_val.node_id > 0) AND
      (rt_nodes_bind_val.not_valid_flag = 'N');


BEGIN

  j := 0;
  IF IEU_PVT.SEL_RT_NODE_ID_REF_LIST.FIRST IS NOT NULL THEN
   IEU_PVT.SEL_RT_NODE_ID_REF_LIST.DELETE;
   IEU_PVT.REF_COUNT_LIST.DELETE;
  END IF;

  For b in c_bindVal
  loop
     l_bindvallist(i).sel_rt_node_id := b.sel_rt_node_id;
     l_bindvallist(i).node_id := b.node_id;
     l_bindvallist(i).bind_var_name := b.bind_var_name;
     l_bindvallist(i).bind_var_value := b.bind_var_value;

     i := i + 1;

  end loop;

  begin
    FOR node in c_nodes
    LOOP

      l_count := 0;

      if (node.node_id = IEU_CONSTS_PUB.G_SNID_MEDIA)
      then

         l_sel_rt_node_id := node.sel_rt_node_id;
         l_node_id := node.node_id;
         l_node_pid := node.node_pid;
         l_view_name := node.view_name;
         l_where_clause := node.where_clause;
         l_media_type_id := node.media_type_id;
         l_sel_enum_id := node.sel_enum_id;
         l_refresh_view_name  := node.refresh_view_name;
         l_refresh_view_sum_col  := node.refresh_view_sum_col;
         l_res_cat_enum_flag := node.res_cat_enum_flag;

      elsif (node.sel_enum_id = 10054 and node.node_depth = 1)
      then

         l_tsk_sel_rt_node_id := node.sel_rt_node_id;
         l_tsk_node_id := node.node_id;
         l_tsk_node_pid := node.node_pid;
         l_tsk_view_name := node.view_name;
         l_tsk_where_clause := node.where_clause;
         l_tsk_media_type_id := node.media_type_id;
         l_tsk_sel_enum_id := node.sel_enum_id;
         l_tsk_refresh_view_name  := node.refresh_view_name;
         l_tsk_refresh_view_sum_col  := node.refresh_view_sum_col;
         l_tsk_res_cat_enum_flag := node.res_cat_enum_flag;

      else
         l_bulk_count := '';
         refresh_node(node.node_id, node.node_pid, node.sel_enum_id, node.where_clause,
         node.res_cat_enum_flag, node.refresh_view_name, node.refresh_view_sum_col,
         node.sel_rt_node_id, l_count, p_resource_id, node.view_name,l_bindvallist, l_bulk_count );

         IEU_PVT.SEL_RT_NODE_ID_REF_LIST(j) := node.sel_rt_node_id;
         IEU_PVT.REF_COUNT_LIST(j) := l_bulk_count;
         j := j + 1;
      end if;

    END LOOP;

    BEGIN
     IF IEU_PVT.SEL_RT_NODE_ID_REF_LIST.FIRST IS NOT NULL THEN
      FORALL x IN IEU_PVT.SEL_RT_NODE_ID_REF_LIST.FIRST..IEU_PVT.SEL_RT_NODE_ID_REF_LIST.LAST SAVE EXCEPTIONS
       UPDATE IEU_UWQ_SEL_RT_NODES
       SET COUNT = IEU_PVT.REF_COUNT_LIST(x)
       WHERE SEL_RT_NODE_ID = IEU_PVT.SEL_RT_NODE_ID_REF_LIST(x)
       AND RESOURCE_ID = P_RESOURCE_ID;
       COMMIT;

      IEU_PVT.SEL_RT_NODE_ID_REF_LIST.delete;
      IEU_PVT.REF_COUNT_LIST.delete;
     END IF;

    EXCEPTION
     WHEN OTHERS THEN
      IEU_PVT.SEL_RT_NODE_ID_REF_LIST.delete;
      IEU_PVT.REF_COUNT_LIST.delete;
    END;

  end;

  if (l_node_id is not null) and (l_node_id = IEU_CONSTS_PUB.G_SNID_MEDIA)
  then
         l_count := 0;
         l_bulk_count := '';

         refresh_node(l_node_id, l_node_pid, l_sel_enum_id, l_where_clause,
         l_res_cat_enum_flag, l_refresh_view_name, l_refresh_view_sum_col,
         l_sel_rt_node_id, l_count, p_resource_id,l_view_name, l_bindvallist, l_bulk_count);

         BEGIN
          UPDATE IEU_UWQ_SEL_RT_NODES
          SET COUNT = l_bulk_count
          WHERE SEL_RT_NODE_ID = l_sel_rt_node_id
          AND RESOURCE_ID = P_RESOURCE_ID;
          COMMIT;

         EXCEPTION
          WHEN OTHERS THEN
           NULL;
         END;
  end if;

  if (l_tsk_node_id is not null)
  then
         l_tsk_count := 0;
         l_bulk_count := '';

         refresh_node(l_tsk_node_id, l_tsk_node_pid, l_tsk_sel_enum_id, l_tsk_where_clause,
         l_tsk_res_cat_enum_flag, l_tsk_refresh_view_name, l_tsk_refresh_view_sum_col,
         l_tsk_sel_rt_node_id, l_tsk_count, p_resource_id,l_tsk_view_name, l_bindvallist, l_bulk_count);

         BEGIN
          UPDATE IEU_UWQ_SEL_RT_NODES
          SET COUNT = l_bulk_count
          WHERE SEL_RT_NODE_ID = l_tsk_sel_rt_node_id
          AND RESOURCE_ID = P_RESOURCE_ID;
          COMMIT;

         EXCEPTION
          WHEN OTHERS THEN
           NULL;
         END;
  end if;


/*
  begin
    open c_media_nodes;

    fetch c_media_nodes
    into l_sel_rt_node_id,l_node_id, l_node_pid, l_where_clause, l_sel_enum_id,
    l_refresh_view_name,l_refresh_view_sum_col, l_res_cat_enum_flag, l_view_name;

    if c_media_nodes%NOTFOUND then
      null;
    else
      l_count := 0;

      refresh_node(l_node_id, l_node_pid, l_sel_enum_id, l_where_clause,
      l_res_cat_enum_flag, l_refresh_view_name, l_refresh_view_sum_col,
      l_sel_rt_node_id, l_count, p_resource_id,l_view_name);

    end if;
  END;
*/
commit;

END REFRESH_WORK_NODE_COUNTS;

PROCEDURE REFRESH_NODE(
       p_node_id in number,
       p_node_pid in number,
       p_sel_enum_id in number,
       p_where_clause in varchar2,
       p_res_cat_enum_flag in varchar2,
       p_refresh_view_name in varchar2,
       p_refresh_view_sum_col in varchar2,
       p_sel_rt_node_id in number,
       p_count in number,
       p_resource_id in number,
       p_view_name in varchar2,
       p_bindvallist in BindValList,
       x_count out  NOCOPY number) AS

  l_count         NUMBER;
  l_refresh_proc  VARCHAR2(100);
  l_where_clause  VARCHAR2(30000);
  l_res_cat_where_clause     VARCHAR2(30000);
  l_sql_stmt VARCHAR2(30000);
  l_cursor_name INTEGER;
  l_rows_processed INTEGER;
  l_rtnode_bind_var_flag   Varchar2(50);
  l_enum_bind_var_flag 	   Varchar2(50);
  l_resource_id_flag 	   Varchar2(10);
  l_node_count  number;
  l_param_pk_value varchar2(500);
  l_media_sql_stmt varchar2(10000);

    BEGIN

    l_rtnode_bind_var_flag := 'T';
    l_enum_bind_var_flag := '';
    l_resource_id_flag := '';
      --
      -- I don't really like the way this turned out... we need some more
      -- indicator columns so this logic can truly be a "blind loop" doing
      -- the same processing for every node.  Unfortunately, we can't meet
      -- our requirements if we do that right now, and the final code pull
      -- is upon us... so this will have to do for now...
      --
      -- (Ray Cardillo / 05-08-00)
      --


      if ( (p_node_id = IEU_CONSTS_PUB.G_SNID_MEDIA) or
           (p_node_id = IEU_CONSTS_PUB.G_SNID_BLENDED) )
      then
        begin
          select
            where_clause
          into
            l_res_cat_where_clause
          from
            ieu_uwq_res_cats_b
          where
            res_cat_id = 10001;

        exception
          when no_data_found then
            null;
        end;
      else
        l_res_cat_where_clause := ieu_pub.get_enum_res_cat(p_sel_enum_id);
      end if;

      if (p_where_clause is NULL)
      then
        l_where_clause := l_res_cat_where_clause;
        l_rtnode_bind_var_flag := 'F';
      else

        if (p_res_cat_enum_flag = 'Y') OR (p_res_cat_enum_flag is NULL)
        then
          if  (l_res_cat_where_clause) is not null
          then
            l_where_clause :=
              l_res_cat_where_clause || ' and ' || p_where_clause;
            --l_rtnode_bind_var_flag := 'F';
            l_rtnode_bind_var_flag := 'T';
          end if;
        else
          l_where_clause := p_where_clause;
          l_rtnode_bind_var_flag := 'T';
        end if;
      end if;


      if (l_res_cat_where_clause is not null)
	 then
       select
        decode(
          (instr(l_res_cat_where_clause, ':resource_id', 1, 1)), 0, 'F','T' )
       into
        l_enum_bind_var_flag
       from
        dual;
      else
	  l_enum_bind_var_flag := 'F';
      end if;


      BEGIN


        -- Use sel_enum_id to find which proc to call
        BEGIN
          select
            refresh_proc
          into
            l_refresh_proc
          from
            ieu_uwq_sel_enumerators
          where
            sel_enum_id = p_sel_enum_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;

        END;

        --
        -- If Refresh Proc is present then get the count from refresh proc
        -- otherwise, get count from the refresh view, or default query.
        --
        IF (l_refresh_proc IS not NULL)
        THEN

          -- If any refresh proc produces an error, then ignore it.
          -- (Ray Cardillo / 05-22-01)

          BEGIN

            execute immediate
              'begin '|| l_refresh_proc || '(' || ':P_RESOURCE_ID' ||
              ', '|| ':p_node_id ' || ',:l_count);end;'
            using
              in p_resource_id, in p_node_id, out l_count;
          EXCEPTION
            when others then
              null;
          END;

        ELSE

          --

          -- if we have a refresh view then get the count from the refresh
          -- view else from the base view .
          --
          IF (p_refresh_view_name IS NOT NULL)
          THEN

            --
            -- If there is a SUM column specified for the node, then use that
            -- to perform a sum on the specified column in refresh view.
            --
            IF (p_REFRESH_VIEW_SUM_COL IS NOT NULL)
            THEN


              --
              -- special processing for SUM count logic (i.e., Media nodes)
              --
              l_sql_stmt :=
                'Select sum(' || p_REFRESH_VIEW_SUM_COL || ') from ' ||
                p_REFRESH_view_name || ' where ' || l_where_clause ||
                ' and ieu_param_pk_value is not null';

              /* this following codes added because in passive mode there is no classification but 'ANY'
                 so, the above select would not work for 'ANY' */

               if p_node_pid = 4000 then
                  l_media_sql_stmt :=
                      'begin select count(*) into :l_node_count from '||
                       p_refresh_view_name||' where resource_id =  '||':p_resource_id'||'; end;';

                  EXECUTE IMMEDIATE l_media_sql_stmt
                  USING out l_node_count, in p_resource_id;

                  if l_node_count = 1 then
                    l_media_sql_stmt :=
                      'begin select ieu_param_pk_value into :l_param_pk_value from '||
                       p_refresh_view_name||' where resource_id =  '||':p_resource_id'||'; end;';

                     EXECUTE IMMEDIATE l_media_sql_stmt
                     USING out l_param_pk_value, in p_resource_id;

                     if l_param_pk_value is null then
                        l_sql_stmt :=
                              'Select sum(' || p_REFRESH_VIEW_SUM_COL || ') from ' ||
                               p_REFRESH_view_name || ' where ' || l_where_clause;
                     end if;
                  end if;

               end if;

            ELSE
            -- Begin fix by spamujul for Bug 7024226
	     If p_refresh_view_name = 'IEU_UWQ_TASK_GA_REF_V v'  then
		l_sql_stmt := 'select /*+ index(v.tasks JTF_TASKS_B_U1) */  count(resource_id) from ' || p_refresh_view_name || ' where ' || l_where_clause;
  	     else
	     -- End fix by spamujul for Bug 7024226
              l_sql_stmt :=
                'select count(resource_id) from ' || p_refresh_view_name ||
                ' where ' || l_where_clause;
	     end if ;-- Added by spamujul for Bug 7024226


            END IF;

          ELSE

            --
            -- we'll have to collect the count on our own... usually slower...
            --
            l_sql_stmt :=
              'select count(resource_id) from ' || p_view_name ||
              ' where ' || l_where_clause;

          END IF;

          --
          -- Execute the sql_stmt to get the count
          --

          BEGIN
            l_cursor_name := dbms_sql.open_cursor;
            DBMS_SQL.PARSE(l_cursor_name,l_sql_stmt , dbms_sql.native);

            If (l_rtnode_bind_var_flag = 'T')
            then

              -- Check if resource_id is present.
		    if (l_where_clause is not null)
		    then
                select
                   decode((instr(l_where_clause, ':resource_id', 1, 1)), 0, 'F','T' )
                into
                   l_resource_id_flag
                from
                   dual;
              else
			 l_resource_id_flag := 'F';
              end if;

              if (l_resource_id_flag = 'T')
              then
                DBMS_SQL.BIND_VARIABLE (
                  l_cursor_name,
                  ':resource_id',
                  p_resource_id );
              end if;

              for i in p_bindvallist.first..p_bindvallist.last
              loop

                if ( (p_bindvallist(i).sel_rt_node_id = p_sel_rt_node_id) and
                     (p_bindvallist(i).node_id   = p_node_id) )
                then

                  -- Ignore bind Var :resource_id here.
                  If (p_bindvallist(i).bind_var_name <> ':resource_id')
                  then

                      DBMS_SQL.BIND_VARIABLE (
                        l_cursor_name,
                        p_bindvallist(i).bind_var_name,
                        p_bindvallist(i).bind_var_value );
                  end if;

                end if;

              end loop;


            else

              if (l_enum_bind_var_flag = 'T')
              then
                DBMS_SQL.BIND_VARIABLE (
                  l_cursor_name,
                  ':resource_id',
                  p_resource_id );
              end if;

            end if;


            --DBMS_SQL.BIND_VARIABLE(l_cursor_name, ':resource_id', 3807);
            DBMS_SQL.DEFINE_COLUMN(l_cursor_name, 1, l_count);
            l_rows_processed := dbms_sql.execute(l_cursor_name);

            IF (DBMS_SQL.FETCH_ROWS(l_cursor_name) > 0)
            THEN
              -- get column values of the row
              DBMS_SQL.COLUMN_VALUE(l_cursor_name, 1, l_count);
            END IF;

            DBMS_SQL.close_cursor(l_cursor_name);

          EXCEPTION

            WHEN OTHERS THEN
              DBMS_SQL.CLOSE_CURSOR(l_cursor_name);

          END;

        END IF;

      exception
        WHEN OTHERS THEN
          l_count := 0;
          --dbms_output.put_line(SQLCODE);
          --dbms_output.put_line(SQLERRM);


      end;

      IF (l_count IS NULL)
      THEN
        l_count := 0;
      END IF;

      --
      -- now update the count for the row
      --
/*      UPDATE
        IEU_UWQ_SEL_RT_NODES nodes
      SET

        nodes.count = l_count
      WHERE
        (nodes.sel_rt_node_id = p_sel_rt_node_id) AND
        (nodes.resource_id = p_resource_id);
*/
      x_count := l_count;
    EXCEPTION
      WHEN OTHERS THEN
        -- nothing we can really do if this fails...
        NULL;
        --dbms_output.put_line('exception : '||substr(sqlerrm, 1, 50));

END refresh_node;


/* Returns information needed to connect UWQ Client to a UWQ Server. */
PROCEDURE UWQ_CLIENT_LOCATE_UWQ_SERVER
  (P_RESOURCE_ID            IN     NUMBER
  ,P_WIRE_PROTOCOL          IN     VARCHAR2
  ,P_COMP_DEF_NAME          IN     VARCHAR2
  ,P_COMP_DEF_VERSION       IN     NUMBER
  ,P_COMP_DEF_IMPL          IN     VARCHAR2
  ,P_COMP_NAME              IN     VARCHAR2
  ,X_COMP_NAME              OUT NOCOPY    VARCHAR2
  ,X_SVR_USER_ADDRESS       OUT NOCOPY    VARCHAR2
  ,X_SVR_IP_ADDRESS         OUT NOCOPY    VARCHAR2
  ,X_SVR_DNS_NAME           OUT NOCOPY    VARCHAR2
  ,X_SVR_PORT               OUT NOCOPY    NUMBER
  ,X_USE_PROXY              OUT NOCOPY    VARCHAR2
  ,X_SESSION_TIMEOUT        OUT NOCOPY    NUMBER
  ,X_SYNC_TIMEOUT           OUT NOCOPY    NUMBER
  ,X_RESPONSE_TIMEOUT       OUT NOCOPY    NUMBER
  ,X_RECONNECT_RETRY_DELAY  OUT NOCOPY    NUMBER
  ,X_HEART_RATE             OUT NOCOPY    NUMBER
  )
  AS

  l_server_id        IEO_SVR_SERVERS.SERVER_ID%TYPE;
  l_server_group_id  IEO_SVR_GROUPS.SERVER_GROUP_ID%TYPE;

  l_last_update_secs  PLS_INTEGER;
  l_curr_time_secs    PLS_INTEGER;
  l_threshold_secs    PLS_INTEGER;
  l_use_refresh_time  VARCHAR2(10);

BEGIN


  IF ( (P_RESOURCE_ID IS NULL) OR
       (P_WIRE_PROTOCOL IS NULL) OR
       (P_COMP_DEF_NAME IS NULL) OR
       (P_COMP_DEF_VERSION IS NULL) OR
       (P_COMP_DEF_IMPL IS NULL) )
  THEN
    raise_application_error
      (-20000
      ,'A required parameter is null' ||
       '. (P_RESOURCE_ID = ' || P_RESOURCE_ID ||
       ') (P_WIRE_PROTOCOL = ' || P_WIRE_PROTOCOL ||
       ') (P_COMP_DEF_NAME = ' || P_COMP_DEF_NAME ||
       ') (P_COMP_DEF_VERSION = ' || P_COMP_DEF_VERSION ||
       ') (P_COMP_DEF_IMPL = ' || P_COMP_DEF_IMPL ||
       ')'
      ,TRUE );
  END IF;


  --
  -- Here are the steps we need to perform:
  --
  --   1. Find the server group this agent belongs to, based on RESOURCE_ID.
  --
  --   2. See if a cached server connection is present.
  --
  --   3. Locate least loaded UWQ server by group, if not cached.
  --
  --   4. Select additional information, and return info to the client.
  --


  --
  -- 1. Given the RESOURCE_ID, find the server group that this agent belongs to.
  --

  SELECT
    DISTINCT
      SERVER_GROUP_ID
    INTO
      l_server_group_id
    FROM
      JTF_RS_RESOURCE_EXTNS
    WHERE
      (RESOURCE_ID = P_RESOURCE_ID) AND
      (ROWNUM <= 1);

  --
  -- 2. See if a cached server connection is present.
  --

  BEGIN

    --
    -- see if there is a cached entry
    --
    SELECT
        binds.SERVER_ID
      INTO
        l_server_id
      FROM
        IEU_UWQ_AGENT_BINDINGS  binds,
        IEO_SVR_SERVERS         srvrs,
        IEO_SVR_RT_INFO         rti
      WHERE
        (binds.RESOURCE_ID = P_RESOURCE_ID) AND
        (binds.SERVER_ID = srvrs.SERVER_ID) AND
        (nvl(binds.NOT_VALID,'N') = 'N') AND
        (srvrs.TYPE_ID = IEU_CONSTS_PUB.G_STID_UWQ) AND
        (srvrs.SERVER_ID = rti.SERVER_ID) AND
        (nvl(rti.STATUS,0) > 0) AND
        (ROWNUM <= 1);

    IF (l_server_id is null)
    THEN
      RAISE NO_DATA_FOUND;
    END IF;

    --
    -- See what the last update time was for this server
    --
    SELECT
      DISTINCT
        to_number(to_char(rti.LAST_UPDATE_DATE,'SSSSS'))
      INTO
        l_last_update_secs
      FROM
        IEO_SVR_RT_INFO rti
      WHERE
        (rti.SERVER_ID = l_server_id) AND
        (ROWNUM <= 1);

    --
    -- calculate the interval in seconds + a buffer
    --
    SELECT
      DISTINCT
        ((stype.RT_REFRESH_RATE * 60) + 60)
      INTO
        l_threshold_secs
      FROM
        IEO_SVR_SERVERS srvrs,
        IEO_SVR_TYPES_B stype
      WHERE
        (srvrs.SERVER_ID = l_server_id) AND
        (srvrs.TYPE_ID = stype.TYPE_ID) AND
        (ROWNUM <= 1);

    l_curr_time_secs := to_number(to_char(SYSDATE,'SSSSS'));

    --
    -- See if this server is "dead".
    --
    IF ( ABS(l_curr_time_secs - l_last_update_secs) > l_threshold_secs )
    THEN
      l_server_id := null;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      l_server_id := null;
  END;

  --
  -- 3. Locate least loaded UWQ server by group.
  --

  IF (l_server_id is null)
  THEN

    BEGIN
    IEO_SVR_UTIL_PVT.LOCATE_LLS_AND_INFO_BY_GROUP
      (
      l_server_group_id,                    -- server group id
      'E59Bf3F0B7DF11D3A05000C04F53FBA6',   -- server type uuid
      P_WIRE_PROTOCOL,                      -- wire protocol
      P_COMP_DEF_NAME,                      -- compenent definition name
      P_COMP_DEF_VERSION,                   -- version of component definition
      P_COMP_DEF_IMPL,                      -- implementation
      P_COMP_NAME,                          -- component name, or NULL
      l_server_id,                          -- server id found
      X_SVR_USER_ADDRESS,                   -- user connect address
      X_SVR_DNS_NAME,                       -- dns name
      X_SVR_IP_ADDRESS,                     -- ip address
      X_SVR_PORT,                           -- port to connect to
      X_COMP_NAME,                          -- component name
      60                                    -- rt timeout tolerance
      );

      EXCEPTION
        WHEN OTHERS THEN
          IEO_SVR_UTIL_PVT.LOCATE_LLS_AND_INFO_BY_GROUP
          (
          l_server_group_id,                    -- server group id
          'E59Bf3F0B7DF11D3A05000C04F53FBA6',   -- server type uuid
          P_WIRE_PROTOCOL,                      -- wire protocol
          P_COMP_DEF_NAME,                      -- compenent definition name
          P_COMP_DEF_VERSION,                -- version of component definition
          P_COMP_DEF_IMPL,                      -- implementation
          P_COMP_NAME,                          -- component name, or NULL
          l_server_id,                          -- server id found
          X_SVR_USER_ADDRESS,                   -- user connect address
          X_SVR_DNS_NAME,                       -- dns name
          X_SVR_IP_ADDRESS,                     -- ip address
          X_SVR_PORT,                           -- port to connect to
          X_COMP_NAME,                          -- component name
          -1                                    -- rt timeout tolerance
          );
    END;

  ELSE

    --
    -- just slammed this code in from IEO for now... really need another
    -- helper in IEO... but don't have the time to validate right now.
    --
    -- Ray Cardillo (05-11-00)
    --
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
          (svr_table.SERVER_ID = l_server_id) AND
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
        X_SVR_USER_ADDRESS,
        X_SVR_DNS_NAME,
        X_SVR_IP_ADDRESS,
        X_SVR_PORT
      FROM
        IEO_SVR_SERVERS svr_table,
        IEO_SVR_COMP_DEFS cdef_table,
        IEO_SVR_COMPS comp_table,
        IEO_SVR_PROTOCOL_MAP prot_table
      WHERE
        (svr_table.SERVER_ID = l_server_id) AND
        (svr_table.SERVER_ID = comp_table.SERVER_ID) AND
        (comp_table.COMP_DEF_ID = cdef_table.COMP_DEF_ID) AND
        (prot_table.COMP_ID = comp_table.COMP_ID) AND
        (prot_table.WIRE_PROTOCOL = P_WIRE_PROTOCOL) AND
        (cdef_table.COMP_DEF_NAME = P_COMP_DEF_NAME) AND
        (cdef_table.COMP_DEF_VERSION = P_COMP_DEF_VERSION) AND
        (cdef_table.IMPLEMENTATION = P_COMP_DEF_IMPL) AND
        (comp_table.COMP_NAME = X_COMP_NAME) AND
        (ROWNUM <= 1);

  END IF;


  --
  -- 4. Select additional information, and return info to the client.
  --

  --
  -- For now, just hard-coding the return values... we'll have to make sure
  -- this is seeded in the server params table first, and then associate
  -- values, defaulting whatever is not found.
  --
  -- Note:  l_server_id was collected above so we can use it to get
  --        variables that may be associated with the server.
  --

  FND_PROFILE.GET( 'IEU_CLI_NET_USE_PROXY', X_USE_PROXY );
  IF (X_USE_PROXY <> 'Y')
  THEN
    X_USE_PROXY             := '';
  END IF;

  X_SESSION_TIMEOUT       := 180;
  X_SYNC_TIMEOUT          := 360000;
  X_RESPONSE_TIMEOUT      := 360000;
  X_RECONNECT_RETRY_DELAY := 4;
  X_HEART_RATE            := 9;


EXCEPTION
  WHEN OTHERS THEN
    NULL;  -- may need to do something in the future
    RAISE;


END UWQ_CLIENT_LOCATE_UWQ_SERVER;


/* Used by UWQ Server to set an agent binding to a server. */
PROCEDURE BIND_AGENT( P_RESOURCE_ID IN NUMBER, P_SERVER_ID IN NUMBER ) AS

  CURSOR c_binds(svr_type_id NUMBER) IS
    SELECT
      ab.SERVER_ID
    FROM
      IEU_UWQ_AGENT_BINDINGS  ab,
      IEO_SVR_SERVERS         srvrs
    WHERE
      ab.RESOURCE_ID = P_RESOURCE_ID AND
      ab.SERVER_ID = srvrs.SERVER_ID AND
      srvrs.TYPE_ID = svr_type_id;

  l_svr_type_id  NUMBER(15,0);

BEGIN

  IF ((P_SERVER_ID IS NULL) OR (P_RESOURCE_ID IS NULL)) THEN
    raise_application_error
      (-20000
      ,'P_RESOURCE_ID and P_SERVER_ID cannot be NULL. (P_RESOURCE_ID = ' ||
       P_RESOURCE_ID || ') (P_SERVER_ID = ' || P_SERVER_ID || ')'
      ,TRUE
    );
  END IF;


  SAVEPOINT start_bind;


  SELECT
    TYPE_ID
  INTO
    l_svr_type_id
  FROM
    IEO_SVR_SERVERS
  WHERE
    SERVER_ID = P_SERVER_ID;


  --
  -- first invalidate all other entries of the same server type...
  --
  FOR cur in c_binds( l_svr_type_id )
  LOOP

    UPDATE
      IEU_UWQ_AGENT_BINDINGS  ab
    SET
      ab.LAST_UPDATE_DATE = SYSDATE,
      ab.NOT_VALID        = 'Y'
    WHERE
      ab.RESOURCE_ID = P_RESOURCE_ID AND
      ab.SERVER_ID = cur.SERVER_ID;

  END LOOP;


  UPDATE IEU_UWQ_AGENT_BINDINGS ab
    SET
      ab.LAST_UPDATE_DATE = SYSDATE,
      ab.NOT_VALID        = NULL
    WHERE
      ab.RESOURCE_ID  = P_RESOURCE_ID AND
      ab.SERVER_ID    = P_SERVER_ID;


  IF (SQL%NOTFOUND OR (SQL%ROWCOUNT <= 0)) THEN

    INSERT INTO IEU_UWQ_AGENT_BINDINGS
      ( RESOURCE_ID,
        SERVER_ID,
        LAST_UPDATE_DATE,
        NOT_VALID )
      VALUES (
        P_RESOURCE_ID,
        P_SERVER_ID,
        SYSDATE,
        NULL );

  END IF;


EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO start_bind;
    RAISE;

END BIND_AGENT;


/* Used by UWQ Server to unset an agent binding to a server. */
PROCEDURE UNBIND_AGENT( P_RESOURCE_ID IN NUMBER, P_SERVER_ID IN NUMBER ) AS
BEGIN

  IF ((P_SERVER_ID IS NULL) OR (P_RESOURCE_ID IS NULL)) THEN
    raise_application_error
      (-20000
      ,'P_RESOURCE_ID and P_SERVER_ID cannot be NULL. (P_RESOURCE_ID = ' ||
       P_RESOURCE_ID || ') (P_SERVER_ID = ' || P_SERVER_ID || ')'
      ,TRUE
    );
  END IF;


  SAVEPOINT start_unbind;


  UPDATE IEU_UWQ_AGENT_BINDINGS ab
    SET
      ab.LAST_UPDATE_DATE = SYSDATE,
      ab.NOT_VALID        = 'Y'
    WHERE
      ab.RESOURCE_ID  = P_RESOURCE_ID AND
      ab.SERVER_ID    = P_SERVER_ID;


  IF (SQL%NOTFOUND OR (SQL%ROWCOUNT <= 0)) THEN
    -- this would mean we tried to unbind, but it wasn't found... I can't think of
    -- any harm this would cause because we're trying to unbind anyway.  (rcardill)
    NULL;
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO start_unbind;
    RAISE;

END UNBIND_AGENT;


/* Used by UWQ Server to unset an agent binding to a server. */
PROCEDURE CLEAR_ALL_AGENT_BINDINGS( P_RESOURCE_ID IN NUMBER
                                   ,P_SERVER_ID IN NUMBER
                                   ,P_MAJOR_LOAD_FACTOR IN NUMBER
                                   ,P_MINOR_LOAD_FACTOR IN NUMBER )
AS
BEGIN

  IF (P_RESOURCE_ID IS NULL) THEN
    raise_application_error
      (-20000
      ,'P_RESOURCE_ID cannot be NULL. (P_RESOURCE_ID = ' || P_RESOURCE_ID || ')'
      ,TRUE );
  END IF;


  SAVEPOINT start_unbind;


  UPDATE IEU_UWQ_AGENT_BINDINGS ab
    SET
      ab.LAST_UPDATE_DATE = SYSDATE,
      ab.NOT_VALID        = 'Y'
    WHERE
      ab.RESOURCE_ID  = P_RESOURCE_ID;

  IF (SQL%NOTFOUND OR (SQL%ROWCOUNT <= 0)) THEN
    NULL;
  END IF;

  /* update rt info */
  /*server status is always 4 when agent logs in*/
  IEO_SVR_UTIL_PVT.UPDATE_RT_INFO( P_SERVER_ID, 4,
                                   P_MAJOR_LOAD_FACTOR,
                                   P_MINOR_LOAD_FACTOR, ' ' );

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO start_unbind;
    RAISE;

END CLEAR_ALL_AGENT_BINDINGS;

PROCEDURE UPDATE_SERVER_STARTUP_INFO( P_SERVER_ID IN NUMBER
                                     ,P_IP_ADDRESS IN VARCHAR2
                                     ,P_DNS_NAME IN VARCHAR2
                                     ,P_USER_ADDRESS IN VARCHAR2 )
AS

BEGIN

/*clear all old server bindings*/
IEO_SVR_UTIL_PVT.CLEAR_SERVER_BINDINGS( P_SERVER_ID );

/*update server information*/
UPDATE IEO_SVR_SERVERS
   SET DNS_NAME = P_DNS_NAME,
       IP_ADDRESS = P_IP_ADDRESS,
       USER_ADDRESS = P_USER_ADDRESS
   WHERE SERVER_ID = P_SERVER_ID;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END UPDATE_SERVER_STARTUP_INFO;

PROCEDURE BIND_AGENT_AND_UPDATE_LOAD( P_RESOURCE_ID IN NUMBER
                           ,P_SERVER_ID IN NUMBER
                           ,P_MAJOR_LOAD_FACTOR IN NUMBER
                           ,P_MINOR_LOAD_FACTOR IN NUMBER
                           ,X_EXISTING_BINDINGS OUT NOCOPY BINDING_CURSOR )
AS
  l_binding_cursor BINDING_CURSOR;
  l_binding_statement VARCHAR2(350);
BEGIN
  IF ((P_SERVER_ID IS NULL) OR (P_RESOURCE_ID IS NULL)) THEN
    raise_application_error
      (-20000
      ,'P_RESOURCE_ID and P_SERVER_ID cannot be NULL. (P_RESOURCE_ID = ' ||
       P_RESOURCE_ID || ') (P_SERVER_ID = ' || P_SERVER_ID || ')'
      ,TRUE
    );
  END IF;

  /*create uwq binding*/
  BIND_AGENT( P_RESOURCE_ID, P_SERVER_ID );

  /* update rt info */
  /*server status is always 4 when agent logs in*/
  IEO_SVR_UTIL_PVT.UPDATE_RT_INFO( P_SERVER_ID, 4,
                                   P_MAJOR_LOAD_FACTOR,
                                   P_MINOR_LOAD_FACTOR, ' ' );

  /*
    this will have problems if multiple servers with the same type have valid bindings
    with the agent. But in this case we rely on the fact that every time a valid
    binding is created all other valid bindings for the same server type are reset
    (see BIND_AGENT proc.) so this case should never happen and we should get just
    one server. - ssk
  */
  l_binding_statement := 'SELECT bindings.server_id, svr_types.type_id FROM ' ||
                         ' ieu_uwq_agent_bindings bindings, ' ||
                         ' ieo_svr_types_b svr_types, ' ||
                         ' ieo_svr_servers svrs ' ||
                         ' WHERE bindings.resource_id = :1 ' ||
                         ' AND bindings.server_id=svrs.server_id ' ||
                         ' AND svr_types.type_id = svrs.type_id ' ||
                         ' AND bindings.NOT_VALID IS NULL';

  OPEN l_binding_cursor for l_binding_statement using P_RESOURCE_ID;

  X_EXISTING_BINDINGS := l_binding_cursor;

  return;
EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END BIND_AGENT_AND_UPDATE_LOAD;


/* Used by UWQ Server to communicate Queue information to client. */
PROCEDURE FORCE_UPDATE_MRT_DATA
  (P_RESOURCE_ID      IN IEU.IEU_UWQ_SEL_MRT_DATA.RESOURCE_ID%TYPE
  ,P_SERVER_TYPE_ID   IN IEU.IEU_UWQ_SEL_MRT_DATA.SVR_TYPE_ID%TYPE
  ,P_MEDIA_TYPE_ID    IN IEU.IEU_UWQ_SEL_MRT_DATA.MEDIA_TYPE_ID%TYPE
  ,P_QUEUE_LIST       IN SYSTEM.IEU_UWQ_SEL_MRT_QUEUES_NST
  )
  AS
BEGIN

  IF ( (P_RESOURCE_ID IS NULL) OR
       (P_SERVER_TYPE_ID IS NULL) OR
       (P_MEDIA_TYPE_ID IS NULL) )
  THEN
    raise_application_error
      (-20000
      ,'P_RESOURCE_ID, P_SERVER_TYPE_ID, and P_MEDIA_TYPE_ID cannot be NULL.' ||
         '(P_RESOURCE_ID = '    || P_RESOURCE_ID ||
       ') (P_SERVER_TYPE_ID = ' || P_SERVER_TYPE_ID ||
       ') (P_MEDIA_TYPE_ID = '  || P_MEDIA_TYPE_ID || ')'
      ,TRUE
    );
  END IF;


  SAVEPOINT start_update;


  --
  -- The technique used here is to always clear all entries for this
  -- combination of (resource_id + server_type + media_type), and then
  -- reset them to the values passed in on this UPDATE.  The reason for the
  -- combination is that the same table can be used by multiple providers,
  -- or even the same provider, with different media types (i.e., MCM).
  -- UWQ plugins using this technique can simply publish their current state
  -- periodically.
  --
  -- NOTE:  This procedure is called FORCE_XXX because we may want to come up
  --        with an incremental update sometime in the future for providers
  --        that have large amounts of data, with only small changes.
  --
  -- Ray Cardillo (01/24/2000)
  --

  UPDATE IEU_UWQ_SEL_MRT_DATA
    SET
      NOT_VALID = 'Y',
      LAST_UPDATE_DATE = SYSDATE
    WHERE
      (RESOURCE_ID = P_RESOURCE_ID) AND
      (SVR_TYPE_ID = P_SERVER_TYPE_ID) AND
      (MEDIA_TYPE_ID = P_MEDIA_TYPE_ID);


  --
  -- Note:  It's completely valid to send us a NULL queue list... it just means
  --        that there are no more entries that are valid.
  --

  IF (P_QUEUE_LIST IS NOT NULL) THEN

    FOR i IN P_QUEUE_LIST.FIRST..P_QUEUE_LIST.LAST LOOP

      IF ((P_QUEUE_LIST(i) IS NOT NULL) AND
          (P_QUEUE_LIST(i).QUEUE_COUNT IS NOT NULL)) THEN


        --
        -- NOTE:  Updated (ROWNUM <= 1) because we saw an environment
        --        that had duplicated rows (prob. from a DB copy) and
        --        both rows remained forever after that point.  By only
        --        validating one per criteria, we will avoid this problem.
        --

        -- Added condition for NULL QUEUE_NAME in the where clause because NULL
        -- names could not be compared and the update clause always ended up
        -- adding new rows to the table when the queue name was NULL
        UPDATE IEU_UWQ_SEL_MRT_DATA
          SET
            NOT_VALID = NULL,
            LAST_UPDATE_DATE = SYSDATE,
            QUEUE_COUNT = P_QUEUE_LIST(i).QUEUE_COUNT,
            PROVIDER_REF = p_QUEUE_LIST(i).PROVIDER_REF
          WHERE
            (RESOURCE_ID = P_RESOURCE_ID) AND
            (SVR_TYPE_ID = P_SERVER_TYPE_ID) AND
            (MEDIA_TYPE_ID = P_MEDIA_TYPE_ID) AND
            ( ( (QUEUE_NAME IS NULL) AND
                (P_QUEUE_LIST(i).QUEUE_NAME IS NULL ) ) OR
              (QUEUE_NAME = P_QUEUE_LIST(i).QUEUE_NAME) ) AND
            (ROWNUM <= 1);


        --
        -- If the update failed, we need to insert a new row...
        --

        IF (SQL%NOTFOUND OR (SQL%ROWCOUNT <= 0)) THEN

          INSERT INTO IEU_UWQ_SEL_MRT_DATA
            ( SEL_MRT_ID,
              RESOURCE_ID,
              SVR_TYPE_ID,
              MEDIA_TYPE_ID,
              LAST_UPDATE_DATE,
              NOT_VALID,
              QUEUE_NAME,
              QUEUE_COUNT,
              PROVIDER_REF )
            VALUES (
              IEU_UWQ_SEL_MRT_DATA_S1.NEXTVAL,
              P_RESOURCE_ID,
              P_SERVER_TYPE_ID,
              P_MEDIA_TYPE_ID,
              SYSDATE,
              NULL,
              P_QUEUE_LIST(i).QUEUE_NAME,
              P_QUEUE_LIST(i).QUEUE_COUNT,
              P_QUEUE_LIST(i).PROVIDER_REF );

        END IF;

      ELSE
        -- Somebody passed us crap...
        NULL;
      END IF;

    END LOOP;

  END IF;


EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO start_update;
    RAISE;

END FORCE_UPDATE_MRT_DATA;


/* Used to determine if agent is eligible for ANY media */
FUNCTION IS_AGENT_ELIGIBLE_FOR_MEDIA( P_RESOURCE_ID IN NUMBER )
  RETURN BOOLEAN
  AS

  l_media_types  EligibleMediaList;

BEGIN

  DETERMINE_ELIGIBLE_MEDIA_TYPES(
    P_RESOURCE_ID,
    l_media_types );

  IF (l_media_types is not null and l_media_types.COUNT > 0) THEN
    RETURN TRUE;
  END IF;

  RETURN FALSE;

END IS_AGENT_ELIGIBLE_FOR_MEDIA;


/* Used to determine if a connection to the UWQ server is required */
FUNCTION IS_UWQ_SERVER_REQUIRED( P_RESOURCE_ID IN NUMBER )
  RETURN BOOLEAN
  AS

BEGIN

  -- for now, these are the same...
  -- maybe they will be different some day

  RETURN IS_AGENT_ELIGIBLE_FOR_MEDIA( P_RESOURCE_ID );

END IS_UWQ_SERVER_REQUIRED;


/* Used to enumerate while setting FND_GLOBAL session variables */
PROCEDURE ENUMERATE_WORK_NODES_FOR_SVR
  (P_RESOURCE_ID   IN NUMBER
  ,P_USER_ID       IN NUMBER
  ,P_RESP_ID       IN NUMBER
  ,P_RESP_APPL_ID  IN NUMBER
  ,P_LANGUAGE    IN VARCHAR2
  ,P_SOURCE_LANG IN VARCHAR2
  )
  AS

      l_old_lang varchar2(100);
      l_new_lang varchar2(100);
      l_lang     varchar2(100);

BEGIN


  -- Changed on 02/21/01. Pseudo-translation was not maintained when view was
  -- refreshed.
  -- So we alter the session to set the NLS language to P_LANGUAGE which corresponds to the
  -- language set in the ICX Profile.

  -- set NLS_LANGUAGE
  l_lang := 'alter session set nls_language = '|| ''''||
             substr(p_language, 1, (instr(p_language,'_',1,1) - 1) ) ||'''';
  execute immediate l_lang;

  -- Set NLS_TERRITORY

  l_lang := 'alter session set nls_territory = '|| ''''||
            substr(p_language, ( instr(p_language,'_',1,1) + 1 ), ( instr(p_language,'.',1,1) -
                               instr(p_language,'_',1,1) - 1) ) || '''';
  execute immediate l_lang;

  FND_GLOBAL.APPS_INITIALIZE( p_user_id, p_resp_id, p_resp_appl_id );

  ENUMERATE_WORK_NODES( P_RESOURCE_ID, '', '' );

END ENUMERATE_WORK_NODES_FOR_SVR;


/* Used to refresh while setting FND_GLOBAL session variables */
PROCEDURE REFRESH_WORK_NODE_FOR_SVR
  (P_RESOURCE_ID   IN NUMBER
  ,P_USER_ID       IN NUMBER
  ,P_RESP_ID       IN NUMBER
  ,P_RESP_APPL_ID  IN NUMBER

   )
  AS


BEGIN

  FND_GLOBAL.APPS_INITIALIZE( p_user_id, p_resp_id, p_resp_appl_id );

  REFRESH_WORK_NODE_COUNTS( P_RESOURCE_ID );



END REFRESH_WORK_NODE_FOR_SVR;


/* Used to add data to the UWQ node table */
PROCEDURE ADD_UWQ_NODE_DATA
  (P_RESOURCE_ID             IN NUMBER,
   P_SEL_ENUM_ID             IN NUMBER,
   P_ENUMERATOR_DATAREC_LIST IN IEU_PUB.EnumeratorDataRecordList
  )
  AS

  temp_err_msg    VARCHAR2(4000);
  x_iterator      NUMBER;
  x_new_node_id   NUMBER;
  l_prnt_node_id  NUMBER;
  l_curr_node_id  NUMBER;
  l_node_weight   NUMBER;

BEGIN


  --
  -- Make sure there is something to add!
  --
  BEGIN
    IF ( (P_ENUMERATOR_DATAREC_LIST IS NULL) OR
         (P_ENUMERATOR_DATAREC_LIST.LAST < 0) )
    THEN
      return;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      return;
  END;


  --
  -- Get the next node ID
  --
  begin

    select
      (max(node_id)+1)
    into
      l_curr_node_id
    from
      ieu_uwq_sel_rt_nodes
    where
      (resource_id = p_resource_id) and
      (not_valid = 'N');

  exception
    when no_data_found then
      l_curr_node_id := 10010;
  end;


  if ((l_curr_node_id is null) or (l_curr_node_id < 10010)) then
    l_curr_node_id := 10010;
  end if;


  --
  -- check top level nodes to see if associated with Media.  if associated
  -- with media, then it belongs under the reserved "Media" node area.
  --
  -- NOTE:  purposely avoiding doing this in recursive WALK_TREE_ADD
  --        to avoid doing this check every time when it's only really needed
  --        for the top node.  (Ray Cardillo / 05-22-01)
  --
  if ( (P_ENUMERATOR_DATAREC_LIST(0).MEDIA_TYPE_ID IS NOT NULL) )
  then
    l_prnt_node_id := IEU_CONSTS_PUB.G_SNID_MEDIA;
  else
    l_prnt_node_id := 0;
  end if;

  IEU_PVT.L_IND_LIST_ITR := 0;
  IEU_PVT.L_RT_NODES_ITR := 0;
  IEU_PVT.L_BIND_VALS_ITR := 0;

  -- Call the recursive procedure to insert or update the nodes
  IEU_PVT.WALK_TREE_ADD (
    P_ENUMERATOR_DATAREC_LIST,
    l_prnt_node_id,
    l_curr_node_id,
    0,
    p_sel_enum_id,
    p_resource_id,
    x_iterator,
    x_new_node_id
    );

  BEGIN
   IF IEU_PVT.NODE_ID_LIST.FIRST IS NOT NULL THEN
    FORALL i IN IEU_PVT.NODE_ID_LIST.FIRST..IEU_PVT.NODE_ID_LIST.LAST SAVE EXCEPTIONS
     UPDATE IEU_UWQ_SEL_RT_NODES SET
     SEL_ENUM_ID          = IEU_PVT.SEL_ENUM_ID_LIST(i),
     NODE_TYPE            = IEU_PVT.NODE_TYPE_LIST(i),
     NODE_PID             = IEU_PVT.NODE_PID_LIST(i),
     NODE_WEIGHT          = IEU_PVT.NODE_WEIGHT_LIST(i),
     NODE_DEPTH           = IEU_PVT.NODE_DEPTH_LIST(i),
     SEL_ENUM_PID         = IEU_PVT.SEL_ENUM_PID_LIST(i),
     MEDIA_TYPE_ID        = IEU_PVT.MEDIA_TYPE_ID_LIST(i),
     COUNT                = IEU_PVT.COUNT_LIST(i),
     DATA_SOURCE          = IEU_PVT.DATA_SOURCE_LIST(i),
     VIEW_NAME            = IEU_PVT.VIEW_NAME_LIST(i),
     WHERE_CLAUSE         = IEU_PVT.WHERE_CLAUSE_LIST(i),
     HIDE_IF_EMPTY        = IEU_PVT.HIDE_IF_EMPTY_LIST(i),
     REFRESH_VIEW_NAME    = IEU_PVT.REFRESH_VIEW_NAME_LIST(i),
     REFRESH_VIEW_SUM_COL = IEU_PVT.REFRESH_VIEW_SUM_COL_LIST(i),
     RES_CAT_ENUM_FLAG    = IEU_PVT.RES_CAT_ENUM_FLAG_LIST(i),
     NOT_VALID            = IEU_PVT.NOT_VALID_LIST(i),
     NODE_LABEL           = IEU_PVT.NODE_LABEL_LIST(i),
     LAST_UPDATE_DATE     = IEU_PVT.LAST_UPDATE_DATE_LIST(i),
     LAST_UPDATED_BY      = IEU_PVT.LAST_UPDATED_BY_LIST(i),
     LAST_UPDATE_LOGIN    = IEU_PVT.LAST_UPDATE_LOGIN_LIST(i)
     WHERE RESOURCE_ID = IEU_PVT.RESOURCE_ID_LIST(i)
     AND NODE_ID = IEU_PVT.NODE_ID_LIST(i);

    IEU_PVT.LAST_UPDATED_BY_LIST.delete;
    IEU_PVT.LAST_UPDATE_DATE_LIST.delete;
    IEU_PVT.LAST_UPDATE_LOGIN_LIST.delete;
    IEU_PVT.RESOURCE_ID_LIST.delete;
    IEU_PVT.SEL_ENUM_ID_LIST.delete;
    IEU_PVT.NODE_ID_LIST.delete;
    IEU_PVT.NODE_TYPE_LIST.delete;
    IEU_PVT.NODE_LABEL_LIST.delete;
    IEU_PVT.COUNT_LIST.delete;
    IEU_PVT.DATA_SOURCE_LIST.delete;
    IEU_PVT.VIEW_NAME_LIST.delete;
    IEU_PVT.MEDIA_TYPE_ID_LIST.delete;
    IEU_PVT.SEL_ENUM_PID_LIST.delete;
    IEU_PVT.NODE_PID_LIST.delete;
    IEU_PVT.NODE_WEIGHT_LIST.delete;
    IEU_PVT.WHERE_CLAUSE_LIST.delete;
    IEU_PVT.HIDE_IF_EMPTY_LIST.delete;
    IEU_PVT.NOT_VALID_LIST.delete;
    IEU_PVT.REFRESH_VIEW_NAME_LIST.delete;
    IEU_PVT.RES_CAT_ENUM_FLAG_LIST.delete;
    IEU_PVT.REFRESH_VIEW_SUM_COL_LIST.delete;
    IEU_PVT.NODE_DEPTH_LIST.delete;
   END IF;

   IF IEU_PVT.IEU_UWQ_SEL_RT_NODES_LIST.FIRST IS NOT NULL THEN
    FORALL i IN IEU_PVT.IEU_UWQ_SEL_RT_NODES_LIST.FIRST..IEU_PVT.IEU_UWQ_SEL_RT_NODES_LIST.LAST SAVE EXCEPTIONS
     insert into IEU_UWQ_SEL_RT_NODES values IEU_PVT.IEU_UWQ_SEL_RT_NODES_LIST(i);

    IEU_PVT.IEU_UWQ_SEL_RT_NODES_LIST.delete;
   END IF;

   IF IEU_PVT.BIND_VAR_NAME_LIST.FIRST IS NOT NULL THEN
    FORALL i IN IEU_PVT.BIND_VAR_NAME_LIST.FIRST..IEU_PVT.BIND_VAR_NAME_LIST.LAST SAVE EXCEPTIONS
     UPDATE IEU_UWQ_RTNODE_BIND_VALS SET
      LAST_UPDATED_BY       = IEU_PVT.BIND_LAST_UPDATED_BY_LIST(i),
      LAST_UPDATE_DATE      = IEU_PVT.BIND_LAST_UPDATE_DATE_LIST(i),
      LAST_UPDATE_LOGIN     = IEU_PVT.BIND_LAST_UPDATE_LOGIN_LIST(i),
      BIND_VAR_VALUE        = IEU_PVT.BIND_VAR_VALUE_LIST(i),
      BIND_VAR_DATATYPE     = IEU_PVT.BIND_VAR_DATATYPE_LIST(i),
      NOT_VALID_FLAG        = IEU_PVT.NOT_VALID_FLAG_LIST(i),
      SEL_RT_NODE_ID        = IEU_PVT.BIND_SEL_RT_NODE_ID_LIST(i),
      OBJECT_VERSION_NUMBER = OBJECT_VERSION_NUMBER + 1
     WHERE RESOURCE_ID     = IEU_PVT.BIND_RESOURCE_ID_LIST(i)
     AND   NODE_ID         = IEU_PVT.BIND_NODE_ID_LIST(i)
     AND   BIND_VAR_NAME   = IEU_PVT.BIND_VAR_NAME_LIST(i);

    IEU_PVT.BIND_LAST_UPDATED_BY_LIST.delete;
    IEU_PVT.BIND_LAST_UPDATE_DATE_LIST.delete;
    IEU_PVT.BIND_LAST_UPDATE_LOGIN_LIST.delete;
    IEU_PVT.BIND_SEL_RT_NODE_ID_LIST.delete;
    IEU_PVT.BIND_RESOURCE_ID_LIST.delete;
    IEU_PVT.BIND_NODE_ID_LIST.delete;
    IEU_PVT.BIND_VAR_NAME_LIST.delete;
    IEU_PVT.BIND_VAR_VALUE_LIST.delete;
    IEU_PVT.BIND_VAR_DATATYPE_LIST.delete;
    IEU_PVT.NOT_VALID_FLAG_LIST.delete;
   END IF;

   IF IEU_PVT.IEU_UWQ_RTNODE_BIND_VALS_LIST.FIRST IS NOT NULL THEN
    FORALL i IN IEU_PVT.IEU_UWQ_RTNODE_BIND_VALS_LIST.FIRST..IEU_PVT.IEU_UWQ_RTNODE_BIND_VALS_LIST.LAST SAVE EXCEPTIONS
     insert into IEU_UWQ_RTNODE_BIND_VALS values IEU_PVT.IEU_UWQ_RTNODE_BIND_VALS_LIST(i);

    IEU_PVT.IEU_UWQ_RTNODE_BIND_VALS_LIST.delete;
   END IF;
--   COMMIT;

  EXCEPTION
   WHEN OTHERS THEN
    IEU_PVT.LAST_UPDATED_BY_LIST.delete;
    IEU_PVT.LAST_UPDATE_DATE_LIST.delete;
    IEU_PVT.LAST_UPDATE_LOGIN_LIST.delete;
    IEU_PVT.RESOURCE_ID_LIST.delete;
    IEU_PVT.SEL_ENUM_ID_LIST.delete;
    IEU_PVT.NODE_ID_LIST.delete;
    IEU_PVT.NODE_TYPE_LIST.delete;
    IEU_PVT.NODE_LABEL_LIST.delete;
    IEU_PVT.COUNT_LIST.delete;
    IEU_PVT.DATA_SOURCE_LIST.delete;
    IEU_PVT.VIEW_NAME_LIST.delete;
    IEU_PVT.MEDIA_TYPE_ID_LIST.delete;
    IEU_PVT.SEL_ENUM_PID_LIST.delete;
    IEU_PVT.NODE_PID_LIST.delete;
    IEU_PVT.NODE_WEIGHT_LIST.delete;
    IEU_PVT.WHERE_CLAUSE_LIST.delete;
    IEU_PVT.HIDE_IF_EMPTY_LIST.delete;
    IEU_PVT.NOT_VALID_LIST.delete;
    IEU_PVT.REFRESH_VIEW_NAME_LIST.delete;
    IEU_PVT.RES_CAT_ENUM_FLAG_LIST.delete;
    IEU_PVT.REFRESH_VIEW_SUM_COL_LIST.delete;
    IEU_PVT.NODE_DEPTH_LIST.delete;

    IEU_PVT.IEU_UWQ_SEL_RT_NODES_LIST.delete;

    IEU_PVT.BIND_LAST_UPDATED_BY_LIST.delete;
    IEU_PVT.BIND_LAST_UPDATE_DATE_LIST.delete;
    IEU_PVT.BIND_LAST_UPDATE_LOGIN_LIST.delete;
    IEU_PVT.BIND_SEL_RT_NODE_ID_LIST.delete;
    IEU_PVT.BIND_RESOURCE_ID_LIST.delete;
    IEU_PVT.BIND_NODE_ID_LIST.delete;
    IEU_PVT.BIND_VAR_NAME_LIST.delete;
    IEU_PVT.BIND_VAR_VALUE_LIST.delete;
    IEU_PVT.BIND_VAR_DATATYPE_LIST.delete;
    IEU_PVT.NOT_VALID_FLAG_LIST.delete;

    IEU_PVT.IEU_UWQ_RTNODE_BIND_VALS_LIST.delete;

    RAISE;
  END;

  -- we're going to make sure the proper node weight is put into the
  -- table, we also have to make sure that the UI is honoring the
  -- display order as well.  (Ray Cardillo / 12-21-2000)
  select
    nvl (
      IEU_UWQ_UTIL_PUB.to_number_noerr (
        fnd_profile.value(e.work_q_order_profile_option) ) ,
      e.work_q_order_system_default
      )
  into
    l_node_weight
  from
    ieu_uwq_sel_enumerators e
  where
    e.sel_enum_id = p_sel_enum_id;

  update
    ieu_uwq_sel_rt_nodes
  set
    node_weight = l_node_weight
  where
    resource_id = p_resource_id and
    node_id = l_curr_node_id;

END ADD_UWQ_NODE_DATA;

PROCEDURE WALK_TREE_ADD(
  P_ENUM_REC_LIST          IN   IEU_PUB.EnumeratorDataRecordList,
  P_PID                    IN   PLS_INTEGER,
  P_CURR_NODE_ID           IN   PLS_INTEGER,
  P_REC_LIST_ITERATOR      IN   PLS_INTEGER,
  P_S_ENUM_ID              IN   NUMBER,
  P_RESOURCE_ID            IN   NUMBER,
  X_NEW_REC_LIST_ITERATOR  IN OUT NOCOPY PLS_INTEGER,
  X_NEW_CURR_NODE_ID       IN OUT NOCOPY PLS_INTEGER) AS

  l_curr_node_id       PLS_INTEGER;
  i                    PLS_INTEGER;
  l_sel_rt_node_id     ieu_uwq_sel_rt_nodes.sel_rt_node_id%type;
  l_bind_var_name      IEU_UWQ_RTNODE_BIND_VALS.BIND_VAR_NAME%TYPE;
  L_BIND_VAR_VALUE     IEU_UWQ_RTNODE_BIND_VALS.BIND_VAR_VALUE%TYPE;
  L_BIND_VAR_DATA_TYPE IEU_UWQ_RTNODE_BIND_VALS.BIND_VAR_DATATYPE%TYPE;
  tempString           varchar2(2000);
  l_counter            number;
  j                    NUMBER;
  k                    NUMBER;

  l_not_valid_flag        VARCHAR2(1);
  l_object_version_number NUMBER;
  L_RTNODE_INSERT_FLAG    VARCHAR2(1);
  L_BINDVALS_INSERT_FLAG  VARCHAR2(1);
  L_RTNODE_BIND_VAR_ID    NUMBER;

BEGIN

  l_not_valid_flag := 'N';
  l_object_version_number := 1;

  i := p_rec_list_iterator;
  l_curr_node_id := p_curr_node_id;

  loop
/*
    -- insert or update IEU_UWQ_RTNODE_BIND_VALS
    IEU_UWQ_SEL_RT_NODES_PKG.LOAD_ROW (
      X_RESOURCE_ID          => p_resource_id,
      X_SEL_ENUM_ID          => p_s_enum_id,
      X_NODE_ID              => l_curr_node_id,
      X_NODE_TYPE            => P_ENUM_REC_LIST(i).NODE_TYPE ,
      X_NODE_PID             => p_pid,
      X_NODE_WEIGHT          => l_curr_node_id,
      X_NODE_DEPTH           => P_ENUM_REC_LIST(I).NODE_DEPTH,
      X_SEL_ENUM_PID         => null,
      X_MEDIA_TYPE_ID        => P_ENUM_REC_LIST(i).MEDIA_TYPE_ID,
      X_COUNT                => NULL,
      X_DATA_SOURCE          => P_ENUM_REC_LIST(i).DATA_SOURCE,
      X_VIEW_NAME            => P_ENUM_REC_LIST(i).VIEW_NAME,
      X_WHERE_CLAUSE         => P_ENUM_REC_LIST(i).WHERE_CLAUSE,
      X_HIDE_IF_EMPTY        => P_ENUM_REC_LIST(i).HIDE_IF_EMPTY,
      X_NOT_VALID            => 'N',
      X_NODE_LABEL           => P_ENUM_REC_LIST(i).NODE_LABEL,
      X_REFRESH_VIEW_NAME    => P_ENUM_REC_LIST(i).REFRESH_VIEW_NAME,
      X_RES_CAT_ENUM_FLAG    => P_ENUM_REC_LIST(i).RES_CAT_ENUM_FLAG,
      X_REFRESH_VIEW_SUM_COL => P_ENUM_REC_LIST(i).REFRESH_VIEW_SUM_COL
     );
*/

    L_RTNODE_INSERT_FLAG := '';
    L_SEL_RT_NODE_ID := '';
    BEGIN
     select sel_rt_node_id
     into l_sel_rt_node_id
     from ieu_uwq_sel_rt_nodes
     where RESOURCE_ID = P_RESOURCE_ID
     and NODE_ID = l_curr_node_id;

     L_RTNODE_INSERT_FLAG := 'N';
    EXCEPTION
     WHEN NO_DATA_FOUND THEN
      SELECT IEU_UWQ_SEL_RT_NODES_S1.NEXTVAL INTO L_SEL_RT_NODE_ID FROM DUAL;
      L_RTNODE_INSERT_FLAG := 'Y';
    END;
    IF NVL(L_RTNODE_INSERT_FLAG, 'X') = 'N' THEN
     IEU_PVT.LAST_UPDATED_BY_LIST(i)      := FND_GLOBAL.USER_ID;
     IEU_PVT.LAST_UPDATE_DATE_LIST(i)     := sysdate;
     IEU_PVT.LAST_UPDATE_LOGIN_LIST(i)    := FND_GLOBAL.LOGIN_ID;
     IEU_PVT.RESOURCE_ID_LIST(i)          := P_RESOURCE_ID;
     IEU_PVT.SEL_ENUM_ID_LIST(i)          := P_S_ENUM_ID;
     IEU_PVT.NODE_ID_LIST(i)              := l_curr_node_id;
     IEU_PVT.NODE_TYPE_LIST(i)            := P_ENUM_REC_LIST(i).NODE_TYPE;
     IEU_PVT.NODE_LABEL_LIST(i)           := P_ENUM_REC_LIST(i).NODE_LABEL;
     IEU_PVT.COUNT_LIST(i)                := null;
     IEU_PVT.DATA_SOURCE_LIST(i)          := P_ENUM_REC_LIST(i).DATA_SOURCE;
     IEU_PVT.VIEW_NAME_LIST(i)            := P_ENUM_REC_LIST(i).VIEW_NAME;
     IEU_PVT.MEDIA_TYPE_ID_LIST(i)        := P_ENUM_REC_LIST(i).MEDIA_TYPE_ID;
     IEU_PVT.SEL_ENUM_PID_LIST(i)         := null;
     IEU_PVT.NODE_PID_LIST(i)             := p_pid;
     IEU_PVT.NODE_WEIGHT_LIST(i)          := l_curr_node_id;
     IEU_PVT.WHERE_CLAUSE_LIST(i)         := P_ENUM_REC_LIST(i).WHERE_CLAUSE;
     IEU_PVT.HIDE_IF_EMPTY_LIST(i)        := P_ENUM_REC_LIST(i).HIDE_IF_EMPTY;
     IEU_PVT.NOT_VALID_LIST(i)            := L_NOT_VALID_FLAG;
     IEU_PVT.REFRESH_VIEW_NAME_LIST(i)    := P_ENUM_REC_LIST(i).REFRESH_VIEW_NAME;
     IEU_PVT.RES_CAT_ENUM_FLAG_LIST(i)    := P_ENUM_REC_LIST(i).RES_CAT_ENUM_FLAG;
     IEU_PVT.REFRESH_VIEW_SUM_COL_LIST(i) := P_ENUM_REC_LIST(i).REFRESH_VIEW_SUM_COL;
     IEU_PVT.NODE_DEPTH_LIST(i)           := P_ENUM_REC_LIST(i).NODE_DEPTH;
    ELSE
     IEU_PVT.IEU_UWQ_SEL_RT_NODES_LIST(IEU_PVT.L_RT_NODES_ITR).SEL_RT_NODE_ID        := L_SEL_RT_NODE_ID;
     IEU_PVT.IEU_UWQ_SEL_RT_NODES_LIST(IEU_PVT.L_RT_NODES_ITR).CREATED_BY            := FND_GLOBAL.USER_ID;
     IEU_PVT.IEU_UWQ_SEL_RT_NODES_LIST(IEU_PVT.L_RT_NODES_ITR).CREATION_DATE         := sysdate;
     IEU_PVT.IEU_UWQ_SEL_RT_NODES_LIST(IEU_PVT.L_RT_NODES_ITR).LAST_UPDATED_BY       := FND_GLOBAL.USER_ID;
     IEU_PVT.IEU_UWQ_SEL_RT_NODES_LIST(IEU_PVT.L_RT_NODES_ITR).LAST_UPDATE_DATE      := sysdate;
     IEU_PVT.IEU_UWQ_SEL_RT_NODES_LIST(IEU_PVT.L_RT_NODES_ITR).LAST_UPDATE_LOGIN     := FND_GLOBAL.LOGIN_ID;
     IEU_PVT.IEU_UWQ_SEL_RT_NODES_LIST(IEU_PVT.L_RT_NODES_ITR).RESOURCE_ID           := P_RESOURCE_ID;
     IEU_PVT.IEU_UWQ_SEL_RT_NODES_LIST(IEU_PVT.L_RT_NODES_ITR).SEL_ENUM_ID           := P_S_ENUM_ID;
     IEU_PVT.IEU_UWQ_SEL_RT_NODES_LIST(IEU_PVT.L_RT_NODES_ITR).NODE_ID               := l_curr_node_id;
     IEU_PVT.IEU_UWQ_SEL_RT_NODES_LIST(IEU_PVT.L_RT_NODES_ITR).NODE_TYPE             := P_ENUM_REC_LIST(i).NODE_TYPE;
     IEU_PVT.IEU_UWQ_SEL_RT_NODES_LIST(IEU_PVT.L_RT_NODES_ITR).NODE_LABEL            := P_ENUM_REC_LIST(i).NODE_LABEL;
     IEU_PVT.IEU_UWQ_SEL_RT_NODES_LIST(IEU_PVT.L_RT_NODES_ITR).COUNT                 := null;
     IEU_PVT.IEU_UWQ_SEL_RT_NODES_LIST(IEU_PVT.L_RT_NODES_ITR).DATA_SOURCE           := P_ENUM_REC_LIST(i).DATA_SOURCE;
     IEU_PVT.IEU_UWQ_SEL_RT_NODES_LIST(IEU_PVT.L_RT_NODES_ITR).VIEW_NAME             := P_ENUM_REC_LIST(i).VIEW_NAME;
     IEU_PVT.IEU_UWQ_SEL_RT_NODES_LIST(IEU_PVT.L_RT_NODES_ITR).MEDIA_TYPE_ID         := P_ENUM_REC_LIST(i).MEDIA_TYPE_ID;
     IEU_PVT.IEU_UWQ_SEL_RT_NODES_LIST(IEU_PVT.L_RT_NODES_ITR).SEL_ENUM_PID          := null;
     IEU_PVT.IEU_UWQ_SEL_RT_NODES_LIST(IEU_PVT.L_RT_NODES_ITR).NODE_PID              := p_pid;
     IEU_PVT.IEU_UWQ_SEL_RT_NODES_LIST(IEU_PVT.L_RT_NODES_ITR).NODE_WEIGHT           := l_curr_node_id;
     IEU_PVT.IEU_UWQ_SEL_RT_NODES_LIST(IEU_PVT.L_RT_NODES_ITR).WHERE_CLAUSE          := P_ENUM_REC_LIST(i).WHERE_CLAUSE;
     IEU_PVT.IEU_UWQ_SEL_RT_NODES_LIST(IEU_PVT.L_RT_NODES_ITR).HIDE_IF_EMPTY         := P_ENUM_REC_LIST(i).HIDE_IF_EMPTY;
     IEU_PVT.IEU_UWQ_SEL_RT_NODES_LIST(IEU_PVT.L_RT_NODES_ITR).NOT_VALID             := L_NOT_VALID_FLAG;
     IEU_PVT.IEU_UWQ_SEL_RT_NODES_LIST(IEU_PVT.L_RT_NODES_ITR).SECURITY_GROUP_ID     := null;
     IEU_PVT.IEU_UWQ_SEL_RT_NODES_LIST(IEU_PVT.L_RT_NODES_ITR).OBJECT_VERSION_NUMBER := L_OBJECT_VERSION_NUMBER;
     IEU_PVT.IEU_UWQ_SEL_RT_NODES_LIST(IEU_PVT.L_RT_NODES_ITR).REFRESH_VIEW_NAME     := P_ENUM_REC_LIST(i).REFRESH_VIEW_NAME;
     IEU_PVT.IEU_UWQ_SEL_RT_NODES_LIST(IEU_PVT.L_RT_NODES_ITR).RES_CAT_ENUM_FLAG     := P_ENUM_REC_LIST(i).RES_CAT_ENUM_FLAG;
     IEU_PVT.IEU_UWQ_SEL_RT_NODES_LIST(IEU_PVT.L_RT_NODES_ITR).REFRESH_VIEW_SUM_COL  := P_ENUM_REC_LIST(i).REFRESH_VIEW_SUM_COL;
     IEU_PVT.IEU_UWQ_SEL_RT_NODES_LIST(IEU_PVT.L_RT_NODES_ITR).NODE_DEPTH            := P_ENUM_REC_LIST(i).NODE_DEPTH;
     IEU_PVT.L_RT_NODES_ITR := IEU_PVT.L_RT_NODES_ITR + 1;
    END IF;

    -- Bind Variables are inserted into IEU_UWQ_RTNODE_BIND_VALS
    -- based on sel_rt_node_id. So select sel_node_id from
    -- ieu_uwq_sel_rt_nodes based on resource_id and node_id.
/*
    select
      sel_rt_node_id
    into
      l_sel_rt_node_id
    from
      ieu_uwq_sel_rt_nodes
    where
      RESOURCE_ID = P_RESOURCE_ID and
      NODE_ID = l_curr_node_id;
*/

    -- Parse the bind_var list and insert the bind names, values and types
    -- into IEU_UWQ_RTNODE_BIND_VALS
    -- Bind_var list is passed as <name1|val1|datatype1><name2|val2|datatype2>

    j:= 1;
    l_counter := 1;
    k := 1;


    If (LENGTH(P_ENUM_REC_LIST(i).BIND_VARS) is not NULL)
    then

      While (l_counter < LENGTH(P_ENUM_REC_LIST(i).BIND_VARS) )
      loop

        tempString :=
          substr (
            P_ENUM_REC_LIST(i).BIND_VARS,
            instr(P_ENUM_REC_LIST(i).BIND_VARS, '<',1,j),
            ( instr(P_ENUM_REC_LIST(i).BIND_VARS, '>',1,j) -
              instr(P_ENUM_REC_LIST(i).BIND_VARS, '<',1,j)+1 )
            );

        L_BIND_VAR_NAME :=
          substr (
            tempString,
            2,
            instr(tempString, '|',1,k) - 2
            );
        L_BIND_VAR_VALUE :=
          substr (
            tempString,
            instr(tempString, '|',1,k) + 1,
            ( instr(tempString,'|',1,k+1) -
              instr(tempString, '|',1,k) - 1)
          );
        L_BIND_VAR_DATA_TYPE :=
          substr (
            tempString,
            instr(tempString, '|',1,k+1) + 1,
            length(tempstring) - instr(tempString, '|',1,k+1) -1
            );

        l_counter := instr(P_ENUM_REC_LIST(i).BIND_VARS, '>',1,j);
        j := j+1;

/*
        -- insert or update IEU_UWQ_RTNODE_BIND_VALS
        IEU_UWQ_RTNODE_BIND_VAL_PKG.LOAD_ROW (
          P_RESOURCE_ID => P_RESOURCE_ID,
          P_NODE_ID => L_CURR_NODE_ID,
          P_SEL_RT_NODE_ID => L_SEL_RT_NODE_ID,
          P_BIND_VAR_NAME => L_BIND_VAR_NAME,
          P_BIND_VAR_VALUE => L_BIND_VAR_VALUE,
          P_BIND_VAR_DATA_TYPE => L_BIND_VAR_DATA_TYPE
          );
*/

       L_BINDVALS_INSERT_FLAG := '';
       L_RTNODE_BIND_VAR_ID := '';
       BEGIN
        select rtnode_bind_var_id
        into l_rtnode_bind_var_id
        from ieu_uwq_rtnode_bind_vals
        where RESOURCE_ID = P_RESOURCE_ID
        and NODE_ID = l_curr_node_id
        and BIND_VAR_NAME = L_BIND_VAR_NAME;

        L_BINDVALS_INSERT_FLAG := 'N';
       EXCEPTION
        WHEN NO_DATA_FOUND THEN
         SELECT IEU_UWQ_RTNODE_BIND_VALS_S1.NEXTVAL INTO L_RTNODE_BIND_VAR_ID FROM DUAL;
         L_BINDVALS_INSERT_FLAG := 'Y';
       END;
       IF NVL(L_BINDVALS_INSERT_FLAG, 'X') = 'N' THEN
        IEU_PVT.BIND_LAST_UPDATED_BY_LIST(IEU_PVT.L_IND_LIST_ITR)       := FND_GLOBAL.USER_ID;
        IEU_PVT.BIND_LAST_UPDATE_DATE_LIST(IEU_PVT.L_IND_LIST_ITR)      := SYSDATE;
        IEU_PVT.BIND_LAST_UPDATE_LOGIN_LIST(IEU_PVT.L_IND_LIST_ITR)     := FND_GLOBAL.LOGIN_ID;
        IEU_PVT.BIND_SEL_RT_NODE_ID_LIST(IEU_PVT.L_IND_LIST_ITR)        := L_SEL_RT_NODE_ID;
        IEU_PVT.BIND_RESOURCE_ID_LIST(IEU_PVT.L_IND_LIST_ITR)           := P_RESOURCE_ID ;
        IEU_PVT.BIND_NODE_ID_LIST(IEU_PVT.L_IND_LIST_ITR)               := L_CURR_NODE_ID ;
        IEU_PVT.BIND_VAR_NAME_LIST(IEU_PVT.L_IND_LIST_ITR)              := L_BIND_VAR_NAME ;
        IEU_PVT.BIND_VAR_VALUE_LIST(IEU_PVT.L_IND_LIST_ITR)             := L_BIND_VAR_VALUE;
        IEU_PVT.BIND_VAR_DATATYPE_LIST(IEU_PVT.L_IND_LIST_ITR)          := L_BIND_VAR_DATA_TYPE;
        IEU_PVT.NOT_VALID_FLAG_LIST(IEU_PVT.L_IND_LIST_ITR)             := L_NOT_VALID_FLAG;
        IEU_PVT.L_IND_LIST_ITR := IEU_PVT.L_IND_LIST_ITR + 1;
       ELSE
        IEU_PVT.IEU_UWQ_RTNODE_BIND_VALS_LIST(IEU_PVT.L_BIND_VALS_ITR).RTNODE_BIND_VAR_ID    := L_RTNODE_BIND_VAR_ID;
        IEU_PVT.IEU_UWQ_RTNODE_BIND_VALS_LIST(IEU_PVT.L_BIND_VALS_ITR).OBJECT_VERSION_NUMBER := L_OBJECT_VERSION_NUMBER;
        IEU_PVT.IEU_UWQ_RTNODE_BIND_VALS_LIST(IEU_PVT.L_BIND_VALS_ITR).CREATED_BY            := FND_GLOBAL.USER_ID;
        IEU_PVT.IEU_UWQ_RTNODE_BIND_VALS_LIST(IEU_PVT.L_BIND_VALS_ITR).CREATION_DATE         := sysdate;
        IEU_PVT.IEU_UWQ_RTNODE_BIND_VALS_LIST(IEU_PVT.L_BIND_VALS_ITR).LAST_UPDATED_BY       := FND_GLOBAL.USER_ID;
        IEU_PVT.IEU_UWQ_RTNODE_BIND_VALS_LIST(IEU_PVT.L_BIND_VALS_ITR).LAST_UPDATE_DATE      := sysdate;
        IEU_PVT.IEU_UWQ_RTNODE_BIND_VALS_LIST(IEU_PVT.L_BIND_VALS_ITR).LAST_UPDATE_LOGIN     := FND_GLOBAL.LOGIN_ID;
        IEU_PVT.IEU_UWQ_RTNODE_BIND_VALS_LIST(IEU_PVT.L_BIND_VALS_ITR).SECURITY_GROUP_ID     := null;
        IEU_PVT.IEU_UWQ_RTNODE_BIND_VALS_LIST(IEU_PVT.L_BIND_VALS_ITR).SEL_RT_NODE_ID        := L_SEL_RT_NODE_ID;
        IEU_PVT.IEU_UWQ_RTNODE_BIND_VALS_LIST(IEU_PVT.L_BIND_VALS_ITR).RESOURCE_ID           := P_RESOURCE_ID;
        IEU_PVT.IEU_UWQ_RTNODE_BIND_VALS_LIST(IEU_PVT.L_BIND_VALS_ITR).NODE_ID               := L_CURR_NODE_ID;
        IEU_PVT.IEU_UWQ_RTNODE_BIND_VALS_LIST(IEU_PVT.L_BIND_VALS_ITR).BIND_VAR_NAME         := L_BIND_VAR_NAME;
        IEU_PVT.IEU_UWQ_RTNODE_BIND_VALS_LIST(IEU_PVT.L_BIND_VALS_ITR).BIND_VAR_VALUE        := L_BIND_VAR_VALUE;
        IEU_PVT.IEU_UWQ_RTNODE_BIND_VALS_LIST(IEU_PVT.L_BIND_VALS_ITR).BIND_VAR_DATATYPE     := L_BIND_VAR_DATA_TYPE;
        IEU_PVT.IEU_UWQ_RTNODE_BIND_VALS_LIST(IEU_PVT.L_BIND_VALS_ITR).NOT_VALID_FLAG        := L_NOT_VALID_FLAG;
        IEU_PVT.L_BIND_VALS_ITR := IEU_PVT.L_BIND_VALS_ITR + 1;
       END IF;
      END LOOP;
    END IF;


    if ( (i = p_enum_rec_list.last)
         or
         (p_enum_rec_list(i).node_depth > p_enum_rec_list(i+1).node_depth)
         or
         (p_enum_rec_list(P_REC_LIST_ITERATOR).node_depth
                                         > p_enum_rec_list(i).node_depth))
    then

      -- exit out of the loop as this is either the end of the list or the
      -- node depth of the next node is greater then the prev node

       if ( (i < p_enum_rec_list.last )
           and
          (p_enum_rec_list(i).node_depth > p_enum_rec_list(i+1).node_depth ) )
       then

        -- increment the node id and i if it is not the last element
        -- and if the node depth of the current node is greater than
        -- node depth of the next node.

           l_curr_node_id := l_curr_node_id + 1;
           i := i + 1;

       end if;
      exit;

    elsif (p_enum_rec_list(i).node_depth < p_enum_rec_list(i+1).node_depth )
    then

      -- call the recursive algorithm for all the sub nodes
      walk_tree_add (
        p_enum_rec_list,     -- complete enum record list
        l_curr_node_id,      -- node p_id
        l_curr_node_id + 1,  -- current node id
        i + 1,               -- list iterator
        p_s_enum_id,         -- enum id
        p_resource_id,       -- resource id
        i,                   -- new list iterator
        l_curr_node_id       -- new current node id
        );

    elsif (( (i < p_enum_rec_list.last )
            and
           (p_enum_rec_list(i).node_depth = p_enum_rec_list(i+1).node_depth )) )
    then

      -- if node depths are equal just increment the node id and set the pid

      l_curr_node_id := l_curr_node_id + 1;
      i := i + 1;

    end if;

    exit when (i >= p_enum_rec_list.count );

  end loop;

  -- i should not be incremented until the node depth of the i is equal
  -- to the node depth of the current node

  if ((i = p_enum_rec_list.last )
       and
      (p_enum_rec_list(P_REC_LIST_ITERATOR).node_depth
                                              = p_enum_rec_list(i).node_depth ) )
  then

      l_curr_node_id := l_curr_node_id + 1;
      i := i + 1;

  end if;

  x_new_curr_node_id := l_curr_node_id;
  X_NEW_REC_LIST_ITERATOR := i;


END WALK_TREE_ADD;

PROCEDURE CHECK_AO_MANUAL_MODE(l_resource_id IN NUMBER,
                               l_ret_val OUT NOCOPY BOOLEAN)
AS

   l_sql_stmt        VARCHAR2(1000);
   l_count           NUMBER;
   l_count1          NUMBER;   --Added for bug7149127
   l_obj_code_flag   VARCHAR2(1);
   l_select_id       JTF_OBJECTS_B.SELECT_ID%TYPE;
   l_select_name     JTF_OBJECTS_B.SELECT_NAME%TYPE;
   l_select_details  JTF_OBJECTS_B.SELECT_DETAILS%TYPE;
   l_from_table      JTF_OBJECTS_B.FROM_TABLE%TYPE;
   l_where_Clause    JTF_OBJECTS_B.WHERE_CLAUSE%TYPE;

BEGIN

     l_obj_code_flag := 'T';
     BEGIN
       SELECT select_id, select_name, select_details, from_table,where_clause
       INTO   l_select_id,l_select_name, l_select_details, l_from_table, l_where_clause
       FROM   jtf_objects_b
       WHERE  object_code = 'AOMANMODE';
     EXCEPTION
       WHEN OTHERS THEN
         l_count := 0;
     END;

/* Start of fix for bug7149127 */

 BEGIN
       select count(*) into l_count1 from ast_grp_campaigns a, IEC_G_EXECUTING_LISTS_V b, -- for bug 6982201
       JTF_RS_GROUP_MEMBERS c,  JTF_RS_GROUPS_DENORM d
       where c.group_id = d.group_id
       and  a.group_id = d.parent_group_id
       and c.resource_id = l_resource_id
       and a.campaign_id = b.schedule_id
       and b.DIALING_METHOD <> 'MAN';
     EXCEPTION
       WHEN OTHERS THEN
         l_count1 := 0;
     END;

/* End of fix for bug7149127 */

     l_sql_stmt := 'BEGIN SELECT '|| l_select_id || ' INTO :l_count ';
     l_sql_stmt := l_sql_stmt || ' FROM '|| l_from_table ||
                   ' WHERE ' ||l_where_clause || ';END; ';


     IF (l_obj_code_flag = 'T')
     THEN

        EXECUTE IMMEDIATE l_sql_stmt
        USING out l_count, in l_resource_id;

     END IF;

/*Start of fix for bug7149127 */

   /*  IF (l_count IS NULL)
     THEN
         l_count := 0;
     END IF;

     IF (l_count = 0)
     THEN
       l_ret_val := True;  -- AO Manual Mode
     ELSE
       l_ret_val := False; -- Ao Normal Mode
     END IF; */

   IF (l_count IS NULL and l_count1 IS NULL)
     THEN
         l_count := 0;
	 l_count1 := 0;
     END IF;

     IF (l_count = 0 and l_count1 = 0)
     THEN
       l_ret_val := True;  -- AO Manual Mode
     ELSE
       l_ret_val := False; -- Ao Normal Mode
     END IF;

/* End of fix for bug7149127 */

END CHECK_AO_MANUAL_MODE;

-- Niraj, 26-May-2005, Added for Bug 4389449
PROCEDURE REFRESH_CUR_NODE_CNTS_FOR_SVR (
	P_RESOURCE_ID	IN NUMBER
	,P_USER_ID 	IN NUMBER
	,P_RESP_ID	IN NUMBER
	,P_RESP_APPL_ID IN NUMBER
	,p_node_id 	IN NUMBER
	,x_node_id_list OUT NOCOPY varchar2) AS
BEGIN
	FND_GLOBAL.APPS_INITIALIZE( p_user_id, p_resp_id, p_resp_appl_id);
	REFRESH_CUR_NODE_COUNTS(p_resource_id, p_node_id, x_node_id_list);
END REFRESH_CUR_NODE_CNTS_FOR_SVR;


PROCEDURE REFRESH_CUR_NODE_COUNTS(p_resource_id in number, p_node_id in number, x_node_id_list OUT NOCOPY varchar2) AS

  l_where_clause  VARCHAR2(30000);
  l_refresh_view_name varchar2(200);
  l_refresh_view_sum_col varchar2(200);
  l_sel_rt_node_id number;
  l_node_id number(10);
  l_node_pid number(10);
  l_node_depth number;
  l_sel_enum_id number(15);
  l_res_cat_enum_flag varchar2(1);
  l_view_name varchar2(512);
  l_bindvallist    BindValList;
  j  number := 1;


  i integer := 0;
  curr_node_id number(10);
  curr_node_depth number;

  l_ref_flag varchar2(1);

    cursor c_nodes(p_sel_enum_id in number, p_node_depth in number) is
    SELECT
      sel_rt_node_id,
      node_id,
      node_pid,
      node_depth,
      view_name,
      where_clause,
      sel_enum_id,
      refresh_view_name,
      refresh_view_sum_col,
      res_cat_enum_flag
  from
   (  SELECT
      rt_nodes.sel_rt_node_id,
      rt_nodes.node_id,
      rt_nodes.node_pid,
      rt_nodes.node_depth,
      rt_nodes.view_name,
      rt_nodes.where_clause,
      rt_nodes.sel_enum_id,
      rt_nodes.refresh_view_name,
      rt_nodes.refresh_view_sum_col,
      rt_nodes.res_cat_enum_flag
    FROM
      ieu_uwq_sel_rt_nodes rt_nodes
    WHERE
      (rt_nodes.resource_id = p_resource_id) AND
      (rt_nodes.sel_enum_id = p_sel_enum_id) AND
      (rt_nodes.not_valid = 'N')
    ) ieu_uwq_sel_enumerators
  -- connect by  node_pid = node_id;     -- Niraj: Bug 4352211, 06-May-2005: Commented this and added below 2 statements,
  start with node_depth = p_node_depth   -- Niraj: Bug 4389449, 24-May-2005: Added p_node_depth instead of hardcoding to 1
  connect by prior node_id = node_pid;

/*
    cursor c_nodes(p_sel_enum_id in number) is
    SELECT
      rt_nodes.sel_rt_node_id,
      rt_nodes.node_id,
      rt_nodes.node_pid,
      rt_nodes.node_depth,
      rt_nodes.view_name,
      rt_nodes.where_clause,
      rt_nodes.sel_enum_id,
      rt_nodes.refresh_view_name,
      rt_nodes.refresh_view_sum_col,
      rt_nodes.res_cat_enum_flag
    FROM
      ieu_uwq_sel_rt_nodes rt_nodes
    WHERE
      (rt_nodes.resource_id = p_resource_id) AND
      (rt_nodes.sel_enum_id = p_sel_enum_id) AND
      (rt_nodes.not_valid = 'N');
*/

    cursor c_media_nodes is
    SELECT
      rt_nodes.sel_enum_id, rt_nodes.node_depth
    FROM
      ieu_uwq_sel_rt_nodes rt_nodes
    WHERE
      (rt_nodes.resource_id = p_resource_id) AND
      (rt_nodes.node_pid = 4000) AND
      (rt_nodes.not_valid = 'N');

  CURSOR c_bindVal IS
    SELECT
      rt_nodes_bind_val.SEL_RT_NODE_ID,
      rt_nodes_bind_val.node_id,
      rt_nodes_bind_val.BIND_VAR_NAME,
      rt_nodes_bind_val.bind_var_value
    FROM
      ieu_uwq_rtnode_bind_vals rt_nodes_bind_val
    WHERE
      (rt_nodes_bind_val.resource_id = p_resource_id) AND
      (rt_nodes_bind_val.node_id > 0) AND
      (rt_nodes_bind_val.not_valid_flag = 'N');

 l_count number;
 l_iterator number;

BEGIN

  l_iterator := 0;

  IF IEU_PVT.SEL_RT_NODE_ID_REF_LIST.FIRST IS NOT NULL THEN
   IEU_PVT.SEL_RT_NODE_ID_REF_LIST.DELETE;
   IEU_PVT.REF_COUNT_LIST.DELETE;
  END IF;

  l_ref_flag := '';
  For b in c_bindVal
  loop
   --  j := 1;
     l_bindvallist(j).sel_rt_node_id := b.sel_rt_node_id;
     l_bindvallist(j).node_id := b.node_id;
     l_bindvallist(j).bind_var_name := b.bind_var_name;
     l_bindvallist(j).bind_var_value := b.bind_var_value;

     j := j + 1;
  end loop;

  begin
    SELECT
      rt_nodes.sel_rt_node_id,
      rt_nodes.node_id,
      rt_nodes.node_pid,
      rt_nodes.node_depth,
      rt_nodes.view_name,
      rt_nodes.where_clause,
      rt_nodes.sel_enum_id,
      rt_nodes.refresh_view_name,
      rt_nodes.refresh_view_sum_col,
      rt_nodes.res_cat_enum_flag
    INTO
      l_sel_rt_node_id,
      l_node_id,
      l_node_pid,
      l_node_depth,
      l_view_name,
      l_where_clause,
      l_sel_enum_id,
      l_refresh_view_name,
      l_refresh_view_sum_col,
      l_res_cat_enum_flag
    FROM
      ieu_uwq_sel_rt_nodes rt_nodes
    WHERE
      (rt_nodes.resource_id = p_resource_id) AND
      (rt_nodes.node_id = p_node_id) AND
      (rt_nodes.not_valid = 'N');
    exception when others then null;
    end;

    curr_node_id := l_node_id;
    curr_node_depth := l_node_depth;

    if (curr_node_id <> 4000) then

    for node in c_nodes(l_sel_enum_id, l_node_depth)
    loop

       if (node.node_id = l_node_id) then
          l_ref_flag := 'T';
       end if;

       curr_node_depth := node.node_depth;
--       curr_node_id := node.node_pid;
       i := i +1;

       if (curr_node_depth > l_node_depth) and (nvl(l_ref_flag, 'F') = 'T') then

 --      if (curr_node_depth > l_node_depth)
   --       and (curr_node_id = node.node_pid) then

         l_count := '';
         l_iterator := l_iterator  + 1;
         IEU_PVT.REFRESH_NODE(p_node_id => node.node_id,
                         p_node_pid => node.node_pid,
                         p_sel_enum_id => node.sel_enum_id,
                         p_where_clause => node.where_clause,
                         p_res_cat_enum_flag => node.res_cat_enum_flag,
                         p_refresh_view_name => node.refresh_view_name,
                         p_refresh_view_sum_col => node.refresh_view_sum_col,
                         p_sel_rt_node_id => node.sel_rt_node_id,
                         p_count => 0,
                         p_resource_id => p_resource_id,
                         p_view_name => node.view_name,
                         p_bindvallist => l_bindvallist,
                         x_count => l_count);
           x_node_id_list := x_node_id_list||node.node_id||fnd_global.local_chr(20);

           IEU_PVT.SEL_RT_NODE_ID_REF_LIST(l_iterator) := node.sel_rt_node_id;
           IEU_PVT.REF_COUNT_LIST(l_iterator) := l_count;

        elsif (node.node_depth <= l_node_depth) and (nvl(l_ref_flag, 'F') = 'T') and (node.node_id  <> l_node_id) then
           l_ref_flag := '';
           exit;
       end if;
     end loop;

     BEGIN
      IF IEU_PVT.SEL_RT_NODE_ID_REF_LIST.FIRST IS NOT NULL THEN
       FORALL x IN IEU_PVT.SEL_RT_NODE_ID_REF_LIST.FIRST..IEU_PVT.SEL_RT_NODE_ID_REF_LIST.LAST SAVE EXCEPTIONS
        UPDATE IEU_UWQ_SEL_RT_NODES
        SET COUNT = IEU_PVT.REF_COUNT_LIST(x)
        WHERE SEL_RT_NODE_ID = IEU_PVT.SEL_RT_NODE_ID_REF_LIST(x)
        AND RESOURCE_ID = P_RESOURCE_ID;
       COMMIT;

       IEU_PVT.SEL_RT_NODE_ID_REF_LIST.delete;
       IEU_PVT.REF_COUNT_LIST.delete;
      END IF;

     EXCEPTION
      WHEN OTHERS THEN
       IEU_PVT.SEL_RT_NODE_ID_REF_LIST.delete;
       IEU_PVT.REF_COUNT_LIST.delete;
     END;

    i := i + 1;
     x_node_id_list := x_node_id_list||l_node_id||fnd_global.local_chr(20);

    l_count := '';
     IEU_PVT.REFRESH_NODE(p_node_id => l_node_id,
                          p_node_pid => l_node_pid,
                          p_sel_enum_id => l_sel_enum_id,
                          p_where_clause => l_where_clause,
                          p_res_cat_enum_flag => l_res_cat_enum_flag,
                          p_refresh_view_name => l_refresh_view_name,
                          p_refresh_view_sum_col => l_refresh_view_sum_col,
                          p_sel_rt_node_id => l_sel_rt_node_id,
                          p_count => 0,
                          p_resource_id => p_resource_id,
                          p_view_name => l_view_name,
                          p_bindvallist => l_bindvallist,
                          x_count => l_count);

     BEGIN
      UPDATE IEU_UWQ_SEL_RT_NODES
      SET COUNT = l_count
      WHERE SEL_RT_NODE_ID = l_sel_rt_node_id
      AND RESOURCE_ID = P_RESOURCE_ID;
      COMMIT;

     EXCEPTION
      WHEN OTHERS THEN
       NULL;
     END;

    elsif (l_node_id = 4000) then
       x_node_id_list := x_node_id_list||l_node_id||fnd_global.local_chr(20);

     for media_nodes in c_media_nodes
     loop
         for node in c_nodes(media_nodes.sel_enum_id, media_nodes.node_depth)
         loop
         i := i + 1;

         l_count := '';
         l_iterator := l_iterator  + 1;
         IEU_PVT.REFRESH_NODE(p_node_id => node.node_id,
                         p_node_pid => node.node_pid,
                         p_sel_enum_id => node.sel_enum_id,
                         p_where_clause => node.where_clause,
                         p_res_cat_enum_flag => node.res_cat_enum_flag,
                         p_refresh_view_name => node.refresh_view_name,
                         p_refresh_view_sum_col => node.refresh_view_sum_col,
                         p_sel_rt_node_id => node.sel_rt_node_id,
                         p_count => 0,
                         p_resource_id => p_resource_id,
                         p_view_name => node.view_name,
                         p_bindvallist => l_bindvallist,
                         x_count => l_count);

            x_node_id_list := x_node_id_list||node.node_id||fnd_global.local_chr(20);

         IEU_PVT.SEL_RT_NODE_ID_REF_LIST(l_iterator) := node.sel_rt_node_id;
         IEU_PVT.REF_COUNT_LIST(l_iterator) := l_count;

         end loop;
      end loop;

      BEGIN
       IF IEU_PVT.SEL_RT_NODE_ID_REF_LIST.FIRST IS NOT NULL THEN
        FORALL x IN IEU_PVT.SEL_RT_NODE_ID_REF_LIST.FIRST..IEU_PVT.SEL_RT_NODE_ID_REF_LIST.LAST SAVE EXCEPTIONS
         UPDATE IEU_UWQ_SEL_RT_NODES
         SET COUNT = IEU_PVT.REF_COUNT_LIST(x)
         WHERE SEL_RT_NODE_ID = IEU_PVT.SEL_RT_NODE_ID_REF_LIST(x)
         AND RESOURCE_ID = P_RESOURCE_ID;
        COMMIT;

        IEU_PVT.SEL_RT_NODE_ID_REF_LIST.delete;
        IEU_PVT.REF_COUNT_LIST.delete;
       END IF;

      EXCEPTION
       WHEN OTHERS THEN
        IEU_PVT.SEL_RT_NODE_ID_REF_LIST.delete;
        IEU_PVT.REF_COUNT_LIST.delete;
      END;

      l_count := '';
      IEU_PVT.REFRESH_NODE(p_node_id => l_node_id,
                         p_node_pid => l_node_pid,
                         p_sel_enum_id => l_sel_enum_id,
                         p_where_clause => l_where_clause,
                         p_res_cat_enum_flag => l_res_cat_enum_flag,
                         p_refresh_view_name => l_refresh_view_name,
                         p_refresh_view_sum_col => l_refresh_view_sum_col,
                         p_sel_rt_node_id => l_sel_rt_node_id,
                         p_count => 0,
                         p_resource_id => p_resource_id,
                         p_view_name => l_view_name,
                         p_bindvallist => l_bindvallist,
                         x_count => l_count);

      BEGIN
       UPDATE IEU_UWQ_SEL_RT_NODES
       SET COUNT = l_count
       WHERE SEL_RT_NODE_ID = l_sel_rt_node_id
       AND RESOURCE_ID = P_RESOURCE_ID;
       COMMIT;

      EXCEPTION
       WHEN OTHERS THEN
        NULL;
      END;

   end if;

end;

PROCEDURE NEW_AO_TEL_CONNECT_RULE(
 p_resource_id IN NUMBER,
 p_elig_media_uuid  IN VARCHAR2,
 x_login_media_uuid OUT NOCOPY varchar2) AS

l_media_UUID_OUT VARCHAR2(38);
l_ao_man_mode         BOOLEAN := False;

BEGIN

  ieu_pvt.check_ao_manual_mode(p_resource_id, l_ao_man_mode);

  IF (NOT l_ao_man_mode)
  THEN
       l_media_UUID_OUT := '50BFCF20B6F511D3A05000C04F53FBA6';  -- AO Normal Mode
  ELSE
       l_media_UUID_OUT := null;  -- AO Manual Mode
  END IF;

--  IEU_PUB.SET_MEDIA_UUID_FOR_LOGIN(l_media_UUID_OUT, x_media_uuid);
  x_login_media_uuid := l_media_UUID_OUT;

END;

-- Niraj, 26-May-2005, Added for Bug 4389449
PROCEDURE REFRESH_SEL_NODE_CNTS_FOR_SVR (
	P_RESOURCE_ID		IN NUMBER
	,P_USER_ID 		IN NUMBER
	,P_RESP_ID      	IN NUMBER
	,P_RESP_APPL_ID 	IN NUMBER
	,p_node_id_string 	in varchar2
	,x_node_id_list 	OUT NOCOPY varchar2)
AS
BEGIN
	FND_GLOBAL.APPS_INITIALIZE( p_user_id, p_resp_id, p_resp_appl_id );
	REFRESH_SELECTIVE_NODE_COUNTS(p_resource_id, p_node_id_string, x_node_id_list);
END REFRESH_SEL_NODE_CNTS_FOR_SVR;


PROCEDURE REFRESH_SELECTIVE_NODE_COUNTS(p_resource_id in number, p_node_id_string in varchar2, x_node_id_list OUT NOCOPY varchar2 )

IS

    current_node_id number;
    j number := 1;
    l_counter number := 1;
    temp number;
    i integer := 0;
    p_node_id_list  varchar2(4000);
BEGIN

     if (length(p_node_id_string)) is not null then

        temp := (instr(p_node_id_string, fnd_global.local_chr(20), 1, j));

           if temp = 0 then

            current_node_id := to_number(p_node_id_string);
           IEU_PVT.REFRESH_CUR_NODE_COUNTS(p_resource_id, current_node_id, p_node_id_list);

           x_node_id_list := p_node_id_list;

           else

        while (l_counter < length(p_node_id_string))
        loop
           i := i + 1;

           temp := (instr(p_node_id_string, fnd_global.local_chr(20), 1, j)) - l_counter;

           current_node_id :=  to_number(substr(p_node_id_string, l_counter, temp));

           IEU_PVT.REFRESH_CUR_NODE_COUNTS(p_resource_id, current_node_id, p_node_id_list);

           x_node_id_list := x_node_id_list||p_node_id_list;

           l_counter := (instr(p_node_id_string, fnd_global.local_chr(20),1,j))+1;

           j := j +1;
        end loop;
        end if;

    end if;
END;

--just a wrapper to enable calling DETERMINE_ELIGIBLE_MEDIA_TYPES from
--java because jdbc does not allow passing of records
PROCEDURE GET_WB_MEDIA_LOGIN_MEDIA_TYPES(
   P_RESOURCE_ID  IN NUMBER
  ,P_USER_ID      IN NUMBER
  ,P_RESP_ID      IN NUMBER
  ,P_RESP_APPL_ID IN NUMBER
  ,X_MEDIA_TYPE_NST OUT NOCOPY SYSTEM.IEU_UWQ_MEDIA_TYPE_NST
)
AS
  l_media_types  EligibleMediaList;
BEGIN

  FND_GLOBAL.APPS_INITIALIZE( p_user_id, p_resp_id, p_resp_appl_id );

  DETERMINE_ELIGIBLE_MEDIA_TYPES(
    P_RESOURCE_ID,
    l_media_types );

  IF (l_media_types is not null and l_media_types.COUNT > 0)
  THEN

    X_MEDIA_TYPE_NST := SYSTEM.IEU_UWQ_MEDIA_TYPE_NST();
    FOR i IN l_media_types.FIRST..l_media_types.LAST
    LOOP
      X_MEDIA_TYPE_NST.extend(1);
      X_MEDIA_TYPE_NST( X_MEDIA_TYPE_NST.LAST ) :=
        SYSTEM.IEU_UWQ_MEDIA_TYPE_OBJ( l_media_types(i).media_type_id,
                                       l_media_types(i).media_type_uuid );
    END LOOP;
  END IF;

END;

-- PL/SQL Block
END IEU_PVT;

/
