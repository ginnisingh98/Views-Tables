--------------------------------------------------------
--  DDL for Package Body EDW_SOURCE_INST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_SOURCE_INST_PKG" AS
/* $Header: EDWSRCB.pls 115.0 99/09/03 14:12:38 porting shi $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     EDWSRCIN.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |     API for translation, loading, downloading data for 		    |
REM |   edw_source_instances						    |
REM |
REM |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | 08-04-99 arsantha creation
REM +=======================================================================+
*/
--
G_PKG_NAME CONSTANT VARCHAR2(30):='EDW_SOURCE_INST_PKG';
--
--
--
Procedure Translate_edw_source_instances
( p_api_version       IN  NUMBER
, p_commit            IN  VARCHAR2 := FND_API.G_FALSE
, p_src_inst_rec      IN  EDW_SOURCE_INST_PKG.src_inst_rec_type
, p_owner             IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, x_return_status     OUT VARCHAR2
)
IS
l_user_id           NUMBER;
l_login_id          NUMBER;

BEGIN
  IF p_owner = BIS_UTILITIES_PUB.G_SEED_OWNER THEN
    l_user_id := BIS_UTILITIES_PUB.G_SEED_USER_ID;
  ELSE
    l_user_id := BIS_UTILITIES_PUB.G_CUSTOM_USER_ID;
  END IF;

  l_login_id := fnd_global.LOGIN_ID;


  UPDATE edw_source_instances_tl
	SET		DESCRIPTION = 	p_src_inst_rec.description
			,NAME		= p_src_inst_rec.name
		  , LAST_UPDATE_DATE  = SYSDATE
		  , LAST_UPDATED_BY   = l_user_id
		  , LAST_UPDATE_LOGIN = l_login_id
		  , SOURCE_LANG       = userenv('LANG')
	where instance_code = p_src_inst_rec.instance_code
	and userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;


END Translate_Edw_source_instances ;
--
Procedure Load_Edw_source_instances
( p_api_version       IN  NUMBER
, p_commit            IN  VARCHAR2 := FND_API.G_FALSE
, p_src_inst_rec      IN  EDW_SOURCE_INST_PKG.src_inst_rec_type
, p_owner             IN  VARCHAR2 := BIS_UTILITIES_PUB.G_CUSTOM_OWNER
, x_return_status     OUT VARCHAR2)
IS
l_user_id           NUMBER;
l_login_id          NUMBER;

BEGIN

  IF p_owner = BIS_UTILITIES_PUB.G_SEED_OWNER THEN
    l_user_id := BIS_UTILITIES_PUB.G_SEED_USER_ID;
  ELSE
    l_user_id := BIS_UTILITIES_PUB.G_CUSTOM_USER_ID;
  END IF;

  l_login_id := fnd_global.LOGIN_ID;


  BEGIN

	  UPDATE edw_source_instances
	SET	warehouse_to_instance_link = p_src_inst_rec.LINK
		  , LAST_UPDATE_DATE  = SYSDATE
		  , LAST_UPDATED_BY   = l_user_id
		  , LAST_UPDATE_LOGIN = l_login_id
	where instance_code = p_src_inst_rec.instance_code;

  UPDATE edw_source_instances_tl
	SET		DESCRIPTION = 	p_src_inst_rec.description
			,NAME		= p_src_inst_rec.name
		  , LAST_UPDATE_DATE  = SYSDATE
		  , LAST_UPDATED_BY   = l_user_id
		  , LAST_UPDATE_LOGIN = l_login_id
		  , SOURCE_LANG       = userenv('LANG')
	where instance_code = p_src_inst_rec.instance_code
	and userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

  EXCEPTION
   WHEN NO_DATA_FOUND OR FND_API.G_EXC_ERROR then

	INSERT INTO EDW_SOURCE_INSTANCES(
 		INSTANCE_CODE,		 ENABLED_FLAG,
		 WAREHOUSE_TO_INSTANCE_LINK,		 CREATION_DATE,
		 CREATED_BY,		 LAST_UPDATE_DATE,
		 LAST_UPDATE_LOGIN,		 LAST_UPDATED_BY)
		values
		(	p_src_inst_rec.Instance_code, p_src_inst_rec.enabled_flag,
			p_src_inst_rec.link, sysdate,
			l_user_id, sysdate,
			l_user_id, l_login_id);

	INSERT INTO EDW_SOURCE_INSTANCES_TL(
	 	INSTANCE_CODE,  LANGUAGE,
		TRANSLATED, SOURCE_LANG,
		NAME,  DESCRIPTION,
		CREATION_DATE, CREATED_BY,
		LAST_UPDATE_DATE, LAST_UPDATE_LOGIN, LAST_UPDATED_BY)
		select	e.instance_code, l.language_code,
			'Y', userenv('LANG'),
			p_src_inst_rec.name, p_src_inst_rec.description,
			sysdate, l_user_id,
			sysdate, l_login_id, l_user_id
		from fnd_languages L,
		edw_source_instances e
		where l.installed_flag in ('I', 'B')
		and e.instance_code = p_src_inst_rec.instance_code
		and NOT EXISTS
		(SELECT 'EXISTS'	FROM edw_source_instances e, edw_source_instances_tl tl
		WHERE tl.instance_code = e.instance_code
			and tl.language = l.language_code);

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_ERROR then
      x_return_status := FND_API.G_RET_STS_ERROR ;
   when FND_API.G_EXC_UNEXPECTED_ERROR then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
   when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END Load_edw_source_instances ;
--
--
END EDW_SOURCE_INST_PKG;

/
