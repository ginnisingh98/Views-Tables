--------------------------------------------------------
--  DDL for Package Body BIS_KPILIST_WIZARD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_KPILIST_WIZARD_PKG" AS
/* $Header: BISFKPIB.pls 120.0 2005/06/01 17:42:44 appldev noship $ */
/*
REM +=======================================================================+
REM |    Copyright (c) 1998 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |     BISFKPIB.pls                                                      |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM | NOTES                                                                 |
REM |                                                                       |
REM | HISTORY                                                               |
REM | 14-OCT-03   akchan   Initial Creation                                 |
REM | 11-FEB-2004   gbhaloti  Added API for deleting a function		    |
REM | 05-APR-2004   smargand  Removed pXMLDefinition Hardcoding for #3551755|
REM | 13-SEP-2004   arhegde  bug# 3885788 Added userId to createdby         |
REM +=======================================================================+
*/
--
--
--
PROCEDURE CREATE_FUNCTION
( p_function_name IN  VARCHAR2
, p_document_name IN  VARCHAR2
, p_portlet_name  IN  VARCHAR2
, p_description   IN  VARCHAR2 := NULL
, x_function_id   OUT NOCOPY VARCHAR2
)
IS

  p_param       VARCHAR2(1000) := 'pXMLDefinition=' || p_document_name;
  x_rowid       ROWID;
  x_fid         NUMBER;
  p_web_portlet VARCHAR2(1000);

BEGIN

  SELECT FND_FORM_FUNCTIONS_S.nextval
  INTO   x_fid
  FROM   sys.dual;

  p_web_portlet := 'OA.jsp?akRegionCode=BIS_PMF_PORTLET_TABLE_LAYOUT&akRegionApplicationId=191';



  FND_FORM_FUNCTIONS_PKG.INSERT_ROW
                        ( X_ROWID                      => x_rowid
                         ,X_FUNCTION_ID                => x_fid
                         ,X_WEB_HOST_NAME              => ''
                         ,X_WEB_AGENT_NAME             => ''
                         ,X_WEB_HTML_CALL              => p_web_portlet
                         ,X_WEB_ENCRYPT_PARAMETERS     => 'N'
                         ,X_WEB_SECURED                => 'N'
                         ,X_WEB_ICON                   => ''
                         ,X_OBJECT_ID                  => NULL
                         ,X_REGION_APPLICATION_ID      => NULL
                         ,X_REGION_CODE                => ''
                         ,X_FUNCTION_NAME              => p_function_name
                         ,X_APPLICATION_ID             => NULL
                         ,X_FORM_ID                    => NULL
                         ,X_PARAMETERS                 => p_param
                         ,X_TYPE                       => 'WEBPORTLET'
                         ,X_USER_FUNCTION_NAME         => p_portlet_name
                         ,X_DESCRIPTION                => p_description
                         ,X_CREATION_DATE              => sysdate
                         ,X_CREATED_BY                 => FND_GLOBAL.user_id
                         ,X_LAST_UPDATE_DATE           => sysdate
                         ,X_LAST_UPDATED_BY            => FND_GLOBAL.user_id
                         ,X_LAST_UPDATE_LOGIN          => FND_GLOBAL.user_id
                         ,X_MAINTENANCE_MODE_SUPPORT   => 'NONE'
                         ,X_CONTEXT_DEPENDENCE         => 'RESP'
                        );

  x_function_id := '' || x_fid;

END CREATE_FUNCTION;


PROCEDURE UPDATE_FUNCTION
( p_function_id        IN VARCHAR2
, p_function_name      IN VARCHAR2
, p_parameters         IN VARCHAR2
, p_user_function_name IN VARCHAR2
, p_description        IN VARCHAR2 := NULL
)

IS

  params  VARCHAR2(300);

BEGIN

  --params := 'pXMLDefinition=' || p_parameters;

  UPDATE fnd_form_functions
  SET    function_name = p_function_name,
         parameters = p_parameters
  WHERE  function_id = p_function_id;


  UPDATE fnd_form_functions_tl
  SET    user_function_name = p_user_function_name,
         description = p_description
  WHERE  function_id = p_function_id;

END UPDATE_FUNCTION;

PROCEDURE UPDATE_FUNCTION_PARAMETERS
( p_function_short_name   IN VARCHAR2
, p_parameters            IN VARCHAR2
, p_user_function_name    IN VARCHAR2
)
IS

fid  NUMBER;

BEGIN

  UPDATE fnd_form_functions_vl
  SET parameters = p_parameters,
      user_function_name = p_user_function_name
  WHERE function_name = p_function_short_name;


  SELECT function_id INTO fid
  FROM fnd_form_functions_vl
  WHERE function_name = p_function_short_name;

  UPDATE fnd_form_functions_tl
  SET    user_function_name = p_user_function_name
  WHERE  function_id = fid;


END UPDATE_FUNCTION_PARAMETERS;


--Procedure to delete a function entry
PROCEDURE DELETE_FUNCTION
( p_function_name       IN VARCHAR2
, x_return_status       OUT NOCOPY VARCHAR2
)
IS
    l_function_id   fnd_form_functions.function_id%TYPE;
    l_created_by    fnd_form_functions.created_by%TYPE;
    l_seed_user	    fnd_form_functions.created_by%TYPE;

    l_menu_id	    fnd_menu_entries.menu_id%TYPE;
    l_entry_sequence fnd_menu_entries.entry_sequence%TYPE;

    CURSOR function_id_crsr IS
        SELECT function_id, created_by
        FROM fnd_form_functions
        WHERE function_name = p_function_name;

    CURSOR menu_crsr (p_function_id fnd_menu_entries.function_id%TYPE) IS
	SELECT menu_id, entry_sequence
	FROM fnd_menu_entries
	WHERE function_id = p_function_id;
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (function_id_crsr%ISOPEN) THEN
        CLOSE function_id_crsr;
    END IF;

    OPEN function_id_crsr;
    FETCH function_id_crsr INTO l_function_id, l_created_by;
    CLOSE function_id_crsr;

    l_seed_user := fnd_load_util.owner_id('ORACLE');

    IF (l_created_by = l_seed_user) THEN /* CRUDE Assumption here that for all seeded data created_by = 1*/
	--THE FUNCTION WAS SEEDED
	x_return_status := 'ISSEED';
    ELSE
  	DELETE FROM fnd_form_functions where function_name = p_function_name;
	DELETE FROM fnd_form_functions_tl where function_id = l_function_id;
    END IF;

    /* Also delete the menu entries corresponding to this function */
    OPEN menu_crsr(l_function_id);
    FETCH menu_crsr INTO l_menu_id, l_entry_sequence;
    CLOSE menu_crsr;

    DELETE FROM fnd_menu_entries WHERE function_id = l_function_id;
    DELETE FROM fnd_menu_entries_tl WHERE menu_id = l_menu_id AND entry_sequence = l_entry_sequence;


EXCEPTION
    WHEN OTHERS THEN
       IF (function_id_crsr%ISOPEN) THEN
         CLOSE function_id_crsr;
       END IF;
    x_return_status := 'ERROR';

END DELETE_FUNCTION;



END BIS_KPILIST_WIZARD_PKG;

/
