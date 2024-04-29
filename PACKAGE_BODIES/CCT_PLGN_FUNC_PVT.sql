--------------------------------------------------------
--  DDL for Package Body CCT_PLGN_FUNC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_PLGN_FUNC_PVT" AS
/* $Header: cctvplgb.pls 115.0 2002/09/18 01:37:45 edwang noship $ */

FUNCTION DO_LAUNCH_CLIENT_SDK
 (
   P_RESOURCE_ID  NUMBER
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

BEGIN

  l_retval := 'N';

  IEU_PVT.DETERMINE_ALL_MEDIA_TYPES_EXTN(P_RESOURCE_ID, l_media_types, l_tel_eligible_flag);

  IEU_PVT.DETERMINE_CLI_PLUGINS(
    P_RESOURCE_ID,
    l_classes );

  IF (l_classes is not null and l_classes.COUNT > 0) THEN
    FOR i IN l_classes.FIRST..l_classes.LAST LOOP
         IF ( (l_tel_eligible_flag = 'Y') AND
              (l_classes(i) =
              'oracle.apps.cct.ccc.clientsdk.gui.MediaControllerPlugginImpl')
            )
         THEN
          l_retval := 'Y';
          EXIT;
        END IF;
    END LOOP;
  END IF;

  RETURN l_retval;

  EXCEPTION
    WHEN OTHERS THEN
      RETURN null;

END DO_LAUNCH_CLIENT_SDK;

END CCT_PLGN_FUNC_PVT;


/
