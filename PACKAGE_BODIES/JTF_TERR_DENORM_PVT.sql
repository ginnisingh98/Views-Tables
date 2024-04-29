--------------------------------------------------------
--  DDL for Package Body JTF_TERR_DENORM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TERR_DENORM_PVT" AS
/* $Header: jtftrdnb.pls 115.4 2000/07/09 12:42:28 pkm ship      $ */

PROCEDURE Populate_API(
		  P_ERROR_CODE      OUT  NUMBER
		, P_ERROR_MSG       OUT  VARCHAR2
            , P_SOURCE_ID       IN   NUMBER
            )  IS

L_REQUEST_ID          NUMBER := FND_GLOBAL.CONC_REQUEST_ID();
L_PROGRAM_APPL_ID     NUMBER := FND_GLOBAL.PROG_APPL_ID();
L_PROGRAM_ID          NUMBER := FND_GLOBAL.CONC_PROGRAM_ID();
L_USER_ID             NUMBER := FND_GLOBAL.USER_ID();
L_SYSDATE             DATE   := SYSDATE;

L_NUM_ROWS_READ       INTEGER   := 0;
L_NUM_ROWS_INSERTED   INTEGER   := 0;

L_ROOT_TERR_ID        NUMBER    := 1;

L_TERR_ID             JTF_TERR.TERR_ID%TYPE;
L_PARENT_TERR_ID      JTF_TERR.PARENT_TERRITORY_ID%TYPE;
L_NEW_PARENT_TERR_ID  JTF_TERR.PARENT_TERRITORY_ID%TYPE;
L_LEAF_FLAG           JTF_TERR_DENORM.LEAF_FLAG%TYPE;

L_LEVEL_FROM_PARENT   NUMBER    := 0;

CURSOR LC_TERR IS
    SELECT    TR1.TERR_ID  TERR_ID
            , TR1.PARENT_TERRITORY_ID  PARENT_TERR_ID
    FROM      JTF_TERR TR1
            , JTF_TERR_USGS TRUSG
    WHERE     TR1.TERR_ID     = TRUSG.TERR_ID
    AND       TRUSG.SOURCE_ID = P_SOURCE_ID ;

l_status varchar2(10);
l_industry varchar2(10);
l_applsys_schema varchar2(30);
l_result boolean;

BEGIN

        l_result := fnd_installation.get_app_info('JTF',
                                                  l_status,
                                                  l_industry,
                                                  l_applsys_schema);

  EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || l_applsys_schema || '.JTF_TERR_DENORM';

  FOR LR_TERR IN LC_TERR
  LOOP

       L_NUM_ROWS_READ     := L_NUM_ROWS_READ + 1 ;
       L_TERR_ID           := LR_TERR.TERR_ID;
       L_PARENT_TERR_ID    := LR_TERR.PARENT_TERR_ID;
       L_LEVEL_FROM_PARENT := 0;

       SELECT DECODE(COUNT(*),0,'Y','N')
        INTO  L_LEAF_FLAG
        FROM  JTF_TERR
        WHERE PARENT_TERRITORY_ID = L_TERR_ID ;

       BEGIN

          INSERT INTO JTF_TERR_DENORM (
                         TERR_ID
                       , PARENT_TERR_ID
                       , CREATION_DATE
                       , CREATED_BY
                       , LAST_UPDATE_DATE
                       , LAST_UPDATED_BY
                       , LAST_UPDATE_LOGIN
                       , REQUEST_ID
                       , PROGRAM_APPLICATION_ID
                       , PROGRAM_ID
                       , PROGRAM_UPDATE_DATE
                       , IMMEDIATE_PARENT_FLAG
                       , ROOT_FLAG
                       , LEAF_FLAG
                       , LEVEL_FROM_PARENT
                     )
             VALUES  (
                         L_TERR_ID
                       , L_TERR_ID
                       , L_SYSDATE
                       , L_USER_ID
                       , L_SYSDATE
                       , L_USER_ID
                       , L_USER_ID
                       , L_REQUEST_ID
                       , L_PROGRAM_APPL_ID
                       , L_PROGRAM_ID
                       , L_SYSDATE
                       , 'N'
                       , 'N'
                       , L_LEAF_FLAG
                       , L_LEVEL_FROM_PARENT
                     );

                     L_NUM_ROWS_INSERTED := L_NUM_ROWS_INSERTED + 1;

       END;

       IF L_PARENT_TERR_ID IS NOT NULL THEN

          -- Insert immediate parent details
          BEGIN

                L_LEVEL_FROM_PARENT := L_LEVEL_FROM_PARENT + 1;

                INSERT INTO JTF_TERR_DENORM (
                            TERR_ID
                          , PARENT_TERR_ID
                          , CREATION_DATE
                          , CREATED_BY
                          , LAST_UPDATE_DATE
                          , LAST_UPDATED_BY
                          , LAST_UPDATE_LOGIN
                          , REQUEST_ID
                          , PROGRAM_APPLICATION_ID
                          , PROGRAM_ID
                          , PROGRAM_UPDATE_DATE
                          , IMMEDIATE_PARENT_FLAG
                          , ROOT_FLAG
                          , LEAF_FLAG
                          , LEVEL_FROM_PARENT
                        )
                  VALUES  (
                            L_TERR_ID
                          , L_PARENT_TERR_ID
                          , L_SYSDATE
                          , L_USER_ID
                          , L_SYSDATE
                          , L_USER_ID
                          , L_USER_ID
                          , L_REQUEST_ID
                          , L_PROGRAM_APPL_ID
                          , L_PROGRAM_ID
                          , L_SYSDATE
                          , 'Y'
                          , DECODE(L_PARENT_TERR_ID,L_ROOT_TERR_ID,'Y','N')
                          , L_LEAF_FLAG
                          , L_LEVEL_FROM_PARENT
                   );

                L_NUM_ROWS_INSERTED := L_NUM_ROWS_INSERTED + 1;

          END;  -- Immediate parent

          LOOP

          -- Check for the ancestors
          BEGIN

                SELECT   TR1.PARENT_TERRITORY_ID
                INTO     L_NEW_PARENT_TERR_ID
                FROM     JTF_TERR TR1
                WHERE    TR1.TERR_ID = L_PARENT_TERR_ID ;

          END;

          EXIT WHEN L_NEW_PARENT_TERR_ID IS NULL ;

          -- Insert the ancestor details
          BEGIN
                L_LEVEL_FROM_PARENT := L_LEVEL_FROM_PARENT + 1;

                INSERT INTO JTF_TERR_DENORM (
                            TERR_ID
                          , PARENT_TERR_ID
                          , CREATION_DATE
                          , CREATED_BY
                          , LAST_UPDATE_DATE
                          , LAST_UPDATED_BY
                          , LAST_UPDATE_LOGIN
                          , REQUEST_ID
                          , PROGRAM_APPLICATION_ID
                          , PROGRAM_ID
                          , PROGRAM_UPDATE_DATE
                          , IMMEDIATE_PARENT_FLAG
                          , ROOT_FLAG
                          , LEAF_FLAG
                          , LEVEL_FROM_PARENT
                         )
                VALUES (
                         L_TERR_ID
                       , L_NEW_PARENT_TERR_ID
                       , L_SYSDATE
                       , L_USER_ID
                       , L_SYSDATE
                       , L_USER_ID
                       , L_USER_ID
                       , L_REQUEST_ID
                       , L_PROGRAM_APPL_ID
                       , L_PROGRAM_ID
                       , L_SYSDATE
                       , 'N'
                       , 'N'
                       , L_LEAF_FLAG
                       , L_LEVEL_FROM_PARENT
                    );

                L_NUM_ROWS_INSERTED := L_NUM_ROWS_INSERTED + 1;

                L_PARENT_TERR_ID := L_NEW_PARENT_TERR_ID;

          END;

          END LOOP;

       END IF; -- END OF IF L_PARENT_TERR_ID IS NOT NULL

  END LOOP;

  COMMIT;

  --DBMS_OUTPUT.PUT_LINE('ROWS READ    : ' || L_NUM_ROWS_READ);
  --DBMS_OUTPUT.PUT_LINE('ROWS INSERTED: ' || L_NUM_ROWS_INSERTED);

EXCEPTION
WHEN OTHERS THEN
	P_ERROR_CODE := sqlcode;
	P_ERROR_MSG := sqlerrm;
END Populate_API;

END JTF_TERR_DENORM_PVT;

/
