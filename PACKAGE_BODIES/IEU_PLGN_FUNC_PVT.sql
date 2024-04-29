--------------------------------------------------------
--  DDL for Package Body IEU_PLGN_FUNC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_PLGN_FUNC_PVT" AS
/* $Header: IEUVPLGB.pls 120.2 2006/01/18 07:33:35 smeade ship $ */


FUNCTION DO_LAUNCH_SR_PLG
 (
   P_RESOURCE_ID  NUMBER
  ,P_AGENT_EXTN   NUMBER
  ,P_USER_ID      NUMBER
  ,P_RESP_ID      NUMBER
  ,P_RESP_APPL_ID NUMBER
  ,P_USER_LANG    VARCHAR2
 ) RETURN VARCHAR2
IS
  l_retval VARCHAR2(1);
BEGIN

  l_retval := 'N';
    --insert into plsqldbug values( sysdate, 'inside do_launch' );
    --commit;

  IF( FND_PROFILE.VALUE( 'IEU_MSG_ENABLE_PLUGIN' ) = 'Y' )
  THEN
    l_retval := 'Y';
  END IF;

  RETURN l_retval;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN null;

END DO_LAUNCH_SR_PLG;

FUNCTION DO_LAUNCH_EVENT_VIEWER
 (
   P_RESOURCE_ID  NUMBER
  ,P_AGENT_EXTN   NUMBER
  ,P_USER_ID      NUMBER
  ,P_RESP_ID      NUMBER
  ,P_RESP_APPL_ID NUMBER
  ,P_USER_LANG    VARCHAR2
 ) RETURN VARCHAR2
IS
  l_retval VARCHAR2(1);

BEGIN
  l_retval := 'N';
    --insert into plsqldbug values( sysdate, 'inside do_launch' );
    --commit;

  IF( FND_PROFILE.VALUE( 'IEU_CTRL_EVENT_VIEWER' ) = 'Y' AND
      (  IEU_PUB.IS_AGENT_ELIGIBLE_FOR_MEDIA( P_RESOURCE_ID ) = TRUE OR
         FND_PROFILE.VALUE( 'IEU_MSG_ENABLE_PLUGIN' ) = 'Y' ) )
  THEN
    l_retval := 'Y';
  END IF;

  RETURN l_retval;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN null;

END DO_LAUNCH_EVENT_VIEWER;

FUNCTION DO_LAUNCH_SOFTPHONE
 (
   P_RESOURCE_ID  NUMBER
  ,P_AGENT_EXTN   NUMBER
  ,P_USER_ID      NUMBER
  ,P_RESP_ID      NUMBER
  ,P_RESP_APPL_ID NUMBER
  ,P_USER_LANG    VARCHAR2
 ) RETURN VARCHAR2
IS
  l_retval              VARCHAR2(1);
  l_classes             IEU_PVT.ClientClasses;
  l_media_types         IEU_PVT.EligibleAllMediaList;
  l_tel_eligible_flag   VARCHAR2(1) := 'N';
  l_ao_man_mode         BOOLEAN := False;
  l_nosoft_mode         VARCHAR2(5);
  l_deleted_flag        VARCHAR2(1);
  l_soft_disabled_param VARCHAR2(32);

BEGIN

  l_retval := 'N';
  l_nosoft_mode := 'FALSE';
  l_deleted_flag := 'D';
  l_soft_disabled_param := 'DISABLE_SOFTPHONE';

  IEU_PVT.DETERMINE_ALL_MEDIA_TYPES_EXTN(P_RESOURCE_ID, l_media_types, l_tel_eligible_flag);

  IEU_PVT.DETERMINE_CLI_PLUGINS(
    P_RESOURCE_ID,
    l_classes );

  IF (l_classes is not null and l_classes.COUNT > 0) THEN
    FOR i IN l_classes.FIRST..l_classes.LAST LOOP
         IF ( (l_tel_eligible_flag = 'Y') AND
              (l_classes(i) =
              'oracle.apps.cct.softphone.SoftphoneWrap')
            )
         THEN
          l_retval := 'Y';
          EXIT;
        END IF;
    END LOOP;
  END IF;

  IF (l_retval = 'Y' and P_AGENT_EXTN is not null)
  THEN

   BEGIN

    SELECT val.value
    INTO l_nosoft_mode
    FROM CCT_MIDDLEWARE_PARAMS par,
         CCT_MIDDLEWARE_VALUES val,
         CCT_MIDDLEWARES mid
    WHERE mid.MIDDLEWARE_ID = val.MIDDLEWARE_ID
    AND par.MIDDLEWARE_PARAM_ID = val.MIDDLEWARE_PARAM_ID
    AND (mid.F_DELETEDFLAG is null OR mid.F_DELETEDFLAG <> l_deleted_flag)
    AND (par.F_DELETEDFLAG is null OR par.F_DELETEDFLAG <> l_deleted_flag)
    AND (val.F_DELETEDFLAG is null OR val.F_DELETEDFLAG <> l_deleted_flag)
    AND par.NAME = l_soft_disabled_param
    AND mid.MIDDLEWARE_ID =
        (SELECT tel.MIDDLEWARE_ID
         FROM CCT_TELESETS tel
         WHERE tel.TELESET_HARDWARE_NUMBER = to_char(P_AGENT_EXTN)
         AND (tel.F_DELETEDFLAG is null OR tel.F_DELETEDFLAG <> l_deleted_flag)
         AND tel.SERVER_GROUP_ID =
             (SELECT res.SERVER_GROUP_ID
              FROM JTF_RS_RESOURCE_EXTNS res
              WHERE res.RESOURCE_ID = P_RESOURCE_ID) );

    EXCEPTION
      WHEN OTHERS THEN
      NULL;
   END;

   IF (l_nosoft_mode = 'TRUE')
   THEN
     l_retval := 'N';
   END IF;

  END IF;

  RETURN l_retval;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN null;

END DO_LAUNCH_SOFTPHONE;


PROCEDURE GET_NON_CONTROLLER_PLUGINS
 (
   P_RESOURCE_ID  IN  NUMBER
  ,P_USER_ID      IN  NUMBER
  ,P_RESP_ID      IN  NUMBER
  ,P_RESP_APPL_ID IN  NUMBER
  ,X_CLASSES      OUT NOCOPY SYSTEM.IEU_CTRL_STRING_NST
 )
AS
  l_classes IEU_PVT.ClientClasses;
  l_class   IEU_UWQ_CLI_MED_PLUGINS.CLI_PLUGIN_CLASS%TYPE;

BEGIN

  FND_GLOBAL.APPS_INITIALIZE( P_USER_ID, P_RESP_ID, P_RESP_APPL_ID );

  IEU_PVT.DETERMINE_CLI_PLUGINS(
    P_RESOURCE_ID,
    l_classes );

  X_CLASSES := SYSTEM.IEU_CTRL_STRING_NST();

  IF (l_classes IS NOT NULL and l_classes.COUNT > 0) THEN

    FOR i IN l_classes.FIRST..l_classes.LAST LOOP

      BEGIN
        SELECT DISTINCT
          ptable.class_name
        INTO
          l_class
        FROM
          IEU_CTL_PLUGINS_B ptable
        WHERE
          l_classes(i) = ptable.class_name;

      EXCEPTION
        WHEN OTHERS THEN
          l_class := '';

      END;

      IF (l_class IS NULL) THEN
       X_CLASSES.extend( 1 );
       X_CLASSES( X_CLASSES.LAST ) := SYSTEM.IEU_CTRL_STRING_OBJ( l_classes(i) );
      END IF;

    END LOOP;

  END IF;

END GET_NON_CONTROLLER_PLUGINS;

-- loads client side media provider plugins
PROCEDURE GET_CLI_PROV_PLUGINS
 (
   P_RESOURCE_ID  IN  NUMBER
  ,P_USER_ID      IN  NUMBER
  ,P_RESP_ID      IN  NUMBER
  ,P_RESP_APPL_ID IN  NUMBER
  ,X_CLASSES      OUT NOCOPY SYSTEM.IEU_CTRL_STRING_NST
 )
AS
  l_media_types  IEU_PVT.EligibleMediaList;
  l_class        IEU_CLI_PROV_PLUGINS.PLUGIN_CLASS_NAME%TYPE;
  l_cond_launch_func  VARCHAR2(255);
  j  NUMBER := 0;
  l_func_call VARCHAR2(1000);
  l_launch_func_return VARCHAR2(1);

BEGIN

  FND_GLOBAL.APPS_INITIALIZE( P_USER_ID, P_RESP_ID, P_RESP_APPL_ID );
  X_CLASSES := SYSTEM.IEU_CTRL_STRING_NST();

  -- IEU_CLI_PROV_PLUGIN_MED_MAPS.CONDITIONAL_FUNC:
  -- This may contain the fully qualified name of a
  -- function w/ the following signature:
  -- FUNCTION <func_name>( P_RESOURCE_ID IN NUMBER,
  --                       P_USER_ID     IN NUMBER,
  --                       P_RESP_ID     IN NUMBER,
  --                       P_RESP_APPL_ID IN NUMBER,
  --                       P_MEDIA_TYPE_ID IN NUMBER
  --                       RETURN BOOLEAN;
  --
  IEU_PVT.DETERMINE_ELIGIBLE_MEDIA_TYPES(
    P_RESOURCE_ID,
    l_media_types );

  IF (l_media_types is NOT NULL AND l_media_types.COUNT > 0) THEN

    FOR i IN l_media_types.FIRST..l_media_types.LAST
    LOOP
      BEGIN
        l_launch_func_return := 'N';

        SELECT DISTINCT
          cliprov.PLUGIN_CLASS_NAME,
          climap.CONDITIONAL_FUNC
        INTO
          l_class,
          l_cond_launch_func
        FROM
          IEU_CLI_PROV_PLUGINS cliprov,
          IEU_CLI_PROV_PLUGIN_MED_MAPS climap
        WHERE
          climap.MEDIA_TYPE_ID = l_media_types(i).media_type_id
          AND climap.PLUGIN_ID =  cliprov.PLUGIN_ID;

      EXCEPTION
        WHEN OTHERS THEN
          l_class := NULL;
      END;

      IF ( l_class IS NOT NULL )
      THEN
        l_launch_func_return := 'Y';

        IF ( l_cond_launch_func IS NOT NULL )
        THEN
          BEGIN
          l_func_call := ':l_launch_func_return = call ' || l_cond_launch_func
              || '(' || P_RESOURCE_ID || ','
              || P_USER_ID || ','
              || P_RESP_ID || ','
              || P_RESP_APPL_ID || ','
              || l_media_types(i).media_type_id || '); ';
          EXECUTE IMMEDIATE l_func_call USING OUT l_launch_func_return;

          EXCEPTION
            WHEN OTHERS THEN
              l_launch_func_return := 'N';
          END;
        END IF;

        IF ( l_launch_func_return = 'Y' )
        THEN
          X_CLASSES.extend( 1 );
          X_CLASSES( X_CLASSES.LAST ) := SYSTEM.IEU_CTRL_STRING_OBJ(l_class);
        END IF;
      END IF;

    END LOOP;

  END IF;

END GET_CLI_PROV_PLUGINS;

END IEU_PLGN_FUNC_PVT;


/
