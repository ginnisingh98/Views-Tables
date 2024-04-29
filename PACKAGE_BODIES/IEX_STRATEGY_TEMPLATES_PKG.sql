--------------------------------------------------------
--  DDL for Package Body IEX_STRATEGY_TEMPLATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_STRATEGY_TEMPLATES_PKG" as
/* $Header: iextsttb.pls 120.4.12010000.3 2010/01/29 20:18:07 ehuh ship $ */

PG_DEBUG NUMBER(2) := TO_NUMBER(NVL(FND_PROFILE.value('IEX_DEBUG_LEVEL'), '20'));

procedure ADD_LANGUAGE
is
begin
  delete from IEX_STRATEGY_TEMPLATES_TL T
  where not exists
    (select NULL
     from IEX_STRATEGY_TEMPLATES_B B
     where B.STRATEGY_TEMP_ID = T.STRATEGY_TEMP_ID
    );

  update IEX_STRATEGY_TEMPLATES_TL T
        set (STRATEGY_NAME) =
             (select B.STRATEGY_NAME
              from IEX_STRATEGY_TEMPLATES_TL B
              where B.STRATEGY_TEMP_ID = T.STRATEGY_TEMP_ID
              and B.LANGUAGE = T.SOURCE_LANG)
        where (
              T.STRATEGY_TEMP_ID,T.LANGUAGE
               ) in (select
                       SUBT.STRATEGY_TEMP_ID,
                       SUBT.LANGUAGE
                     from IEX_STRATEGY_TEMPLATES_TL SUBB,
                          IEX_STRATEGY_TEMPLATES_TL SUBT
                     where SUBB.STRATEGY_TEMP_ID = SUBT.STRATEGY_TEMP_ID
                     and SUBB.LANGUAGE = SUBT.SOURCE_LANG
                     and SUBB.STRATEGY_NAME<> SUBT.STRATEGY_NAME
                     OR (SUBB.STRATEGY_NAME IS NULL AND SUBT.STRATEGY_NAME IS NOT NULL)
                     OR (SUBB.STRATEGY_NAME IS NOT NULL AND SUBT.STRATEGY_NAME IS NULL)
                );

  insert into IEX_STRATEGY_TEMPLATES_TL (
    STRATEGY_TEMP_ID,
    STRATEGY_NAME,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.STRATEGY_TEMP_ID,
    B.STRATEGY_NAME,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from IEX_STRATEGY_TEMPLATES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
     from IEX_STRATEGY_TEMPLATES_TL T
     where T.STRATEGY_TEMP_ID = B.STRATEGY_TEMP_ID
     and T.LANGUAGE = L.LANGUAGE_CODE);

end ADD_LANGUAGE;


procedure TRANSLATE_ROW (
  X_STRATEGY_TEMP_ID in NUMBER,
  X_STRATEGY_NAME in VARCHAR2,
  X_OBJECT_VERSION_NUMBER in NUMBER,
  X_OWNER in VARCHAR2
) IS

begin
	UPDATE IEX_STRATEGY_TEMPLATES_TL SET
		STRATEGY_NAME=X_STRATEGY_NAME,
		last_update_date = sysdate,
		last_updated_by = decode(X_OWNER, 'SEED', 1, 0),
		last_update_login = 0,
		source_lang = userenv('LANG')
	WHERE userenv('LANG') in (LANGUAGE, SOURCE_LANG) AND
		 STRATEGY_TEMP_id = X_STRATEGY_TEMP_ID;
end TRANSLATE_ROW;


PROCEDURE COPY_STRATEGY_GROUP(P_GROUP_ID in NUMBER, RETURN_STATUS OUT NOCOPY VARCHAR2) IS
 nNextGroupID number;
  nNextTempID number;
  nNextXrefID NUMBER;

  CURSOR c_templates(vGROUP_ID NUMBER) is
        SELECT
        STRATEGY_TEMP_ID,
        STRATEGY_TEMP_GROUP_ID,
        STRATEGY_ORDER_ID
        LAST_UPDATE_LOGIN,
        REQUEST_ID,
        STRATEGY_RANK,
        ENABLED_FLAG,
        CATEGORY_TYPE,
        CHANGE_STRATEGY_YN,
        CHECK_LIST_YN,
        CHECK_LIST_TEMP_ID ,
        VALID_FROM_DT,
        VALID_TO_DT,
        OBJECT_FILTER_ID,
        STRATEGY_LEVEL,
        SCORE_TOLERANCE,
        STRATEGY_NAME,
        STRATEGY_ORDER_ID
     FROM  IEX_STRATEGY_TEMPLATES_VL
        WHERE STRATEGY_TEMP_GROUP_ID = vGROUP_ID;

  CURSOR c_Xref(vTemplate_ID number) IS
     SELECT
        WORK_TEMP_XREF_ID,
        STRATEGY_TEMP_ID,
        WORK_ITEM_TEMP_ID,
        WORK_ITEM_ORDER,
        REQUIRED_YN,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        REQUEST_ID,
        OBJECT_VERSION_NUMBER
    FROM IEX_STRATEGY_WORK_TEMP_XREF
      WHERE STRATEGY_TEMP_ID = vTemplate_ID;

BEGIN

    SAVEPOINT IEX_STRY_TEMP_PKG_COPYSTRGRP;

    RETURN_STATUS := 'A';

    IEX_DEBUG_PUB.logmessage('Copy Strategy Group ');
    select IEX_STRATEGY_TEMPLATE_GROUPS_S.NEXTVAL
      into nNextGroupID from DUAL;

    IEX_DEBUG_PUB.logmessage('Next Strategy GROUP_ID ID = ' || nNextGroupID);
    IEX_DEBUG_PUB.logmessage('AAAAAAAAAAAAA = ' || nNextGroupID);
    RETURN_STATUS := 'B';

    INSERT INTO IEX_STRATEGY_TEMPLATE_GROUPS (
        OBJECT_VERSION_NUMBER,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        REQUEST_ID,
        GROUP_ID,
        GROUP_NAME,
        STRATEGY_RANK,
        ENABLED_FLAG,
        CATEGORY_TYPE,
        CHANGE_STRATEGY_YN,
        CHECK_LIST_YN,
        CHECK_LIST_TEMP_ID,
        VALID_FROM_DT,
        VALID_TO_DT,
        OBJECT_FILTER_ID,
        STRATEGY_LEVEL,
        SCORE_TOLERANCE,
        STRATEGY_TEMP_ID
      )
      SELECT
        1,
        FND_GLOBAL.USER_ID,
        SYSDATE,
        SYSDATE,
        FND_GLOBAL.USER_ID,
        ISTL.LAST_UPDATE_LOGIN,
        ISTL.REQUEST_ID,
        nNextGroupID,
        'Copy of ' || ISTL.GROUP_NAME,
        ISTL.STRATEGY_RANK,
        ISTL.ENABLED_FLAG,
        ISTL.CATEGORY_TYPE,
        ISTL.CHANGE_STRATEGY_YN,
        ISTL.CHECK_LIST_YN,
        ISTL.CHECK_LIST_TEMP_ID ,
        ISTL.VALID_FROM_DT,
        ISTL.VALID_TO_DT,
        ISTL.OBJECT_FILTER_ID,
        ISTL.STRATEGY_LEVEL,
        ISTL.SCORE_TOLERANCE,
        ISTL.STRATEGY_TEMP_ID
     FROM  IEX_STRATEGY_TEMPLATE_GROUPS istl
        WHERE istl.GROUP_ID = p_GROUP_ID AND
           NOT EXISTS (SELECT 1 FROM IEX_STRATEGY_TEMPLATE_GROUPS istg
              WHERE istg.GROUP_NAME  = 'Copy of ' || istl.GROUP_NAME );

   IEX_DEBUG_PUB.logmessage('Done copying the Group ');
   IEX_DEBUG_PUB.logmessage('BBBBBBBBBBBB = ' || nNextGroupID);
   IEX_DEBUG_PUB.logmessage('P_GROUP_ID = ' || p_group_id);

    FOR tempCur IN c_templates(P_GROUP_ID)  LOOP

       IEX_DEBUG_PUB.logmessage('Copy Strategy Template ' || tempCur.STRATEGY_TEMP_ID);

        select IEX_STRATEGY_TEMPLATES_S.NEXTVAL
           into nNextTempID from DUAL;

       IEX_DEBUG_PUB.logmessage('Next Strategy Template ID = ' || nNextTempID);
       IEX_DEBUG_PUB.logmessage('Copy FND_GLOBAL.USER_ID ' || FND_GLOBAL.USER_ID);
       IEX_DEBUG_PUB.logmessage('Copy LAST_UPDATE_LOGIN ' || tempCur.LAST_UPDATE_LOGIN);
       IEX_DEBUG_PUB.logmessage('Copy REQUEST_ID Template ' || tempCur.REQUEST_ID);
       IEX_DEBUG_PUB.logmessage('Copy STRATEGY_RANK  Template ' || tempCur.STRATEGY_RANK);
       IEX_DEBUG_PUB.logmessage('Copy ENABLED_FLAG Template ' || tempCur.ENABLED_FLAG);
       IEX_DEBUG_PUB.logmessage('Copy Strategy Template ' || tempCur.STRATEGY_TEMP_ID);

       INSERT INTO IEX_STRATEGY_TEMPLATES_B (
          OBJECT_VERSION_NUMBER,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN,
          REQUEST_ID,
          STRATEGY_TEMP_ID,
          STRATEGY_RANK,
          ENABLED_FLAG,
          CATEGORY_TYPE,
          CHANGE_STRATEGY_YN,
          CHECK_LIST_YN,
          CHECK_LIST_TEMP_ID,
          VALID_FROM_DT,
          VALID_TO_DT,
          OBJECT_FILTER_ID,
          STRATEGY_LEVEL,
          SCORE_TOLERANCE,
          STRATEGY_TEMP_GROUP_ID,
          STRATEGY_ORDER_ID
      )
      VALUES(
        1,
        FND_GLOBAL.USER_ID,
        SYSDATE,
        SYSDATE,
        FND_GLOBAL.USER_ID,
        FND_GLOBAL.USER_ID,-- bug 6671798 tempCur.LAST_UPDATE_LOGIN,
        tempCur.REQUEST_ID,
        nNextTempID,
        tempCur.STRATEGY_RANK,
        tempCur.ENABLED_FLAG,
        tempCur.CATEGORY_TYPE,
        tempCur.CHANGE_STRATEGY_YN,
        tempCur.CHECK_LIST_YN,
        tempCur.CHECK_LIST_TEMP_ID ,
        tempCur.VALID_FROM_DT,
        tempCur.VALID_TO_DT,
        tempCur.OBJECT_FILTER_ID,
        tempCur.STRATEGY_LEVEL,
        tempCur.SCORE_TOLERANCE,
        nNextGroupID,
        tempCur.STRATEGY_ORDER_ID
     );


     IEX_DEBUG_PUB.logmessage('Done inserting... IEX_STRATEGY_TEMPLATES_B');

     INSERT INTO IEX_STRATEGY_TEMPLATES_tl (
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN,
          STRATEGY_TEMP_ID,
          STRATEGY_NAME,
          SOURCE_LANG,
          LANGUAGE
          )
        VALUES (
        FND_GLOBAL.USER_ID,
        SYSDATE,
        SYSDATE,
        FND_GLOBAL.USER_ID,
        FND_GLOBAL.USER_ID,-- bug 6671798 tempCur.LAST_UPDATE_LOGIN,
        nNextTempID,
        'Copy of ' || tempCur.strategy_name,
        userenv('LANG'),
        userenv('LANG')
      );
      IEX_DEBUG_PUB.logmessage('End Copy Strategy Template ' || nNextTempID);

  -- begin added for a Bug 9305366
  insert into IEX_STRATEGY_TEMPLATES_TL (
    STRATEGY_TEMP_ID,
    STRATEGY_NAME,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.STRATEGY_TEMP_ID,
    B.STRATEGY_NAME,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from IEX_STRATEGY_TEMPLATES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
     from IEX_STRATEGY_TEMPLATES_TL T
     where T.STRATEGY_TEMP_ID = B.STRATEGY_TEMP_ID
     and T.LANGUAGE = L.LANGUAGE_CODE);

IEX_DEBUG_PUB.logmessage('End Copy Multi-Lang Strategy Template ' || nNextTempID);

  -- end added for a Bug 9305366



      FOR xrefCur IN c_Xref(tempCur.STRATEGY_TEMP_ID)  LOOP

       IEX_DEBUG_PUB.logmessage('Copy XRef for Template = ' || tempCur.STRATEGY_TEMP_ID ||
           ' and Xref ID = ' || xrefCur.WORK_TEMP_XREF_ID );

        select IEX_STRATEGY_WORK_TEMP_XREF_S.NEXTVAL
           into nNextXrefID FROM DUAL;

       IEX_DEBUG_PUB.logmessage('Next Work Item Xref ID from seq = ' || nNextXrefID);

        INSERT INTO IEX_STRATEGY_WORK_TEMP_XREF(
          WORK_TEMP_XREF_ID,
          STRATEGY_TEMP_ID,
          WORK_ITEM_TEMP_ID,
          WORK_ITEM_ORDER,
          REQUIRED_YN,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN,
          OBJECT_VERSION_NUMBER )
        VALUES (nNextXrefID,
          nNextTempID,
          xrefCur.WORK_ITEM_TEMP_ID,
          xrefCur.WORK_ITEM_ORDER,
          xrefCur.REQUIRED_YN,
          FND_GLOBAL.USER_ID,
          SYSDATE,
          SYSDATE,
          FND_GLOBAL.USER_ID,
          FND_GLOBAL.USER_ID,--  bug 6671798 xrefCur.LAST_UPDATE_LOGIN,
          1);

      END LOOP;  /* xrefCur */

   END LOOP;  /* tempCur */



   --RETURN_STATUS := 'S';
   RETURN_STATUS := nNextGroupID;  -- bug 7705188
   Commit Work;

EXCEPTION
   WHEN OTHERS THEN
    ROLLBACK TO IEX_STRY_TEMP_PKG_COPYSTRGRP;
    RETURN_STATUS := 'E';
END COPY_STRATEGY_GROUP;


end IEX_STRATEGY_TEMPLATES_PKG;

/
