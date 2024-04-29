--------------------------------------------------------
--  DDL for Package Body BIS_RSS_PORTLETS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_RSS_PORTLETS_PUB" AS
/* $Header: BISPRSSB.pls 120.2 2005/11/03 12:53:09 serao noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 2004 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISPRSSB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     Module: Public package for populating the RSS Portlets tables     |
REM |             - BIS_RSS_PORTLETS                                        |
REM |             - BIS_RSS_PORTLETS_TL                                     |
REM | NOTES                                                                 |
REM | 01/20/05  nbarik   Initial Creation.                                  |
REM | 10/27/05  ugodavar Bug.Fix.4700227 - Procedure Add_Language           |
REM |                                                                       |
REM +=======================================================================+
*/


PROCEDURE Load_Row(
  p_Commit              IN          VARCHAR2
 ,p_Rss_Portlet_Rec     IN          BIS_RSS_PORTLETS_PUB.Rss_Portlet_Type
 ,x_Return_Status       OUT NOCOPY  VARCHAR2
 ,x_Msg_Count           OUT NOCOPY  NUMBER
 ,x_Msg_Data            OUT NOCOPY  VARCHAR2
)
IS
    l_commit                VARCHAR2(30);
BEGIN
    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;
    IF p_Commit IS NULL THEN
        l_commit := FND_API.G_FALSE;
    ELSE
        l_commit := p_Commit;
    END IF;

	INSERT INTO BIS_RSS_PORTLETS
	  (    PORTLET_SHORT_NAME
	     , XML_URL
	     , XSL_URL
	     , CREATED_BY
	     , CREATION_DATE
	     , LAST_UPDATED_BY
	     , LAST_UPDATE_DATE
         , LAST_UPDATE_LOGIN
       )
	  SELECT
	       p_Rss_Portlet_Rec.Portlet_Short_Name
	     , p_Rss_Portlet_Rec.Xml_Url
	     , p_Rss_Portlet_Rec.Xsl_Url
	     , nvl(p_Rss_Portlet_Rec.Created_By, FND_GLOBAL.USER_ID)
	     , nvl(p_Rss_Portlet_Rec.Creation_Date, sysdate)
	     , nvl(p_Rss_Portlet_Rec.Last_Updated_By, FND_GLOBAL.USER_ID)
	     , nvl(p_Rss_Portlet_Rec.Last_Update_Date, sysdate)
	     , nvl(p_Rss_Portlet_Rec.Last_Update_login, FND_GLOBAL.LOGIN_ID)
   	FROM DUAL;

	INSERT INTO BIS_RSS_PORTLETS_TL
	  (    PORTLET_SHORT_NAME
	     , NAME
	     , DESCRIPTION
	     , LANGUAGE
	     , SOURCE_LANG
	     , CREATED_BY
	     , CREATION_DATE
	     , LAST_UPDATED_BY
	     , LAST_UPDATE_DATE
         , LAST_UPDATE_LOGIN
       )
	  SELECT
	       p_Rss_Portlet_Rec.Portlet_Short_Name
	     , p_Rss_Portlet_Rec.Name
	     , p_Rss_Portlet_Rec.Description
	     , language_code
	     , userenv('LANG')
	     , nvl(p_Rss_Portlet_Rec.Created_By, FND_GLOBAL.USER_ID)
	     , nvl(p_Rss_Portlet_Rec.Creation_Date, sysdate)
	     , nvl(p_Rss_Portlet_Rec.Last_Updated_By, FND_GLOBAL.USER_ID)
	     , nvl(p_Rss_Portlet_Rec.Last_Update_Date, sysdate)
	     , nvl(p_Rss_Portlet_Rec.Last_Update_login, FND_GLOBAL.LOGIN_ID)
	FROM fnd_languages l
  	WHERE L.INSTALLED_FLAG IN ('I', 'B')
	AND NOT EXISTS
		(SELECT null
		FROM bis_rss_portlets_tl
		WHERE portlet_short_name = p_Rss_Portlet_Rec.Portlet_Short_Name
		AND language = l.language_code);

    IF (l_commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    if (x_msg_data is null) then
      x_msg_data := SQLERRM;
    end if;
END Load_Row;

PROCEDURE Translate_Row (
 p_Commit               IN          VARCHAR2
,p_Rss_Portlet_Rec      IN          BIS_RSS_PORTLETS_PUB.Rss_Portlet_Type
,x_return_status                OUT NOCOPY VARCHAR2
,x_msg_count                    OUT NOCOPY NUMBER
,x_msg_data                     OUT NOCOPY VARCHAR2
) IS

BEGIN

    FND_MSG_PUB.Initialize;
    x_Return_Status := FND_API.G_RET_STS_SUCCESS;

	IF p_Rss_Portlet_Rec.Portlet_Short_Name IS NOT NULL THEN
		BEGIN
			UPDATE bis_rss_portlets_tl
			SET name = p_Rss_Portlet_Rec.Name,
			    description = p_Rss_Portlet_Rec.Description,
			    created_by = nvl(p_Rss_Portlet_Rec.Created_By, FND_GLOBAL.USER_ID),
			    creation_date = nvl(p_Rss_Portlet_Rec.Creation_Date, sysdate),
			    last_updated_by = nvl(p_Rss_Portlet_Rec.Last_Updated_By, FND_GLOBAL.USER_ID),
			    last_update_date = nvl(p_Rss_Portlet_Rec.Last_Update_Date, sysdate),
			    last_update_login = nvl(p_Rss_Portlet_Rec.Last_Update_Login, FND_GLOBAL.LOGIN_ID),
        		source_lang = userenv('LANG')
			WHERE portlet_short_name = p_Rss_Portlet_Rec.Portlet_Short_Name
			AND USERENV('LANG') IN (LANGUAGE, SOURCE_LANG);
		EXCEPTION
			WHEN OTHERS THEN NULL;
		END;
	END IF;

    IF (p_Commit = FND_API.G_TRUE) THEN
      COMMIT;
    END IF;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN NO_DATA_FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_encoded => 'F' ,p_count  =>      x_msg_count
                              ,p_data   =>      x_msg_data);
    IF (x_msg_data IS NULL) THEN
      x_msg_data := SQLERRM;
    END IF;
END Translate_Row;

-- procedure to add a language.	 Bug.Fix.4700227
PROCEDURE Add_Language IS
BEGIN

    DELETE FROM BIS_RSS_PORTLETS_TL T
    WHERE NOT EXISTS
    (
      SELECT NULL
      FROM   BIS_RSS_PORTLETS B
      WHERE  B.PORTLET_SHORT_NAME = T.PORTLET_SHORT_NAME
    );

    UPDATE BIS_RSS_PORTLETS_TL T SET (
        NAME, DESCRIPTION
    ) = (SELECT
            B.NAME, B.DESCRIPTION
         FROM  BIS_RSS_PORTLETS_TL B
         WHERE B.PORTLET_SHORT_NAME = T.PORTLET_SHORT_NAME
         AND   B.LANGUAGE           = T.SOURCE_LANG)
         WHERE (
            T.PORTLET_SHORT_NAME,
            T.LANGUAGE
         ) IN (SELECT
                SUBT.PORTLET_SHORT_NAME,
                SUBT.LANGUAGE
                FROM  BIS_RSS_PORTLETS_TL SUBB, BIS_RSS_PORTLETS_TL SUBT
                WHERE SUBB.PORTLET_SHORT_NAME = SUBT.PORTLET_SHORT_NAME
                AND   SUBB.LANGUAGE           = SUBT.SOURCE_LANG
                AND (SUBB.NAME <> SUBT.NAME
		      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
		      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
		      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
		  ));

    INSERT INTO BIS_RSS_PORTLETS_TL
    (
      PORTLET_SHORT_NAME,
      NAME,
      DESCRIPTION,
      LANGUAGE,
      SOURCE_LANG,
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATE_LOGIN
    )
    SELECT
       B.PORTLET_SHORT_NAME,
       B.NAME,
       B.DESCRIPTION,
       L.LANGUAGE_CODE,
       B.SOURCE_LANG,
       B.CREATED_BY,
       B.CREATION_DATE,
       B.LAST_UPDATED_BY,
       B.LAST_UPDATE_DATE,
       B.LAST_UPDATE_LOGIN
   FROM  BIS_RSS_PORTLETS_TL B, FND_LANGUAGES L
   WHERE L.INSTALLED_FLAG IN ('I', 'B')
   AND   B.LANGUAGE = USERENV('LANG')
   AND   NOT EXISTS
        (
          SELECT NULL
          FROM   BIS_RSS_PORTLETS_TL T
          WHERE  T.PORTLET_SHORT_NAME = B.PORTLET_SHORT_NAME
          AND    T.LANGUAGE           = L.LANGUAGE_CODE
        );

END Add_Language;

END BIS_RSS_PORTLETS_PUB;

/
