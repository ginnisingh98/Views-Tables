--------------------------------------------------------
--  DDL for Package Body FND_MO_REPORTING_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_MO_REPORTING_API" AS
/*  $Header: FNDMORPB.pls 120.4.12010000.3 2009/09/11 16:09:17 abhaktha ship $ */

  g_max_num             NUMBER          DEFAULT 100;
  g_pred                VARCHAR2(2000)  DEFAULT NULL;
  g_reporting_level     VARCHAR2(10)    DEFAULT '3000';
  g_reporting_entity_id NUMBER;



--
-- Generic_Error (Internal)
--
-- Set error message and raise exception for unexpected sql errors.
--
PROCEDURE Generic_Error
  (  routine            IN VARCHAR2
   , errcode            IN NUMBER
   , errmsg             IN VARCHAR2
  )
IS
BEGIN
    fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
    fnd_message.set_token('ROUTINE', routine);
    fnd_message.set_token('ERRNO', errcode);
    fnd_message.set_token('REASON', errmsg);
    app_exception.raise_exception;

EXCEPTION
  WHEN OTHERS THEN RAISE;
END;




--
--  App_Error (Internal)
--
PROCEDURE App_Error
  (  error_name         IN VARCHAR2
   , token1             IN VARCHAR2 DEFAULT NULL
   , value1             IN VARCHAR2 DEFAULT NULL
   , token2             IN VARCHAR2 DEFAULT NULL
   , value2             IN VARCHAR2 DEFAULT NULL
   , token3             IN VARCHAR2 DEFAULT NULL
   , value3             IN VARCHAR2 DEFAULT NULL
   , token4             IN VARCHAR2 DEFAULT NULL
   , value4             IN VARCHAR2 DEFAULT NULL
  )
IS
BEGIN
  fnd_message.set_name('FND',error_name);

  IF (token1 IS NOT NULL AND value1 IS NOT NULL)
  THEN
    fnd_message.set_token(token1,value1);
  END IF;

  IF (token2 IS NOT NULL AND value2 IS NOT NULL)
  THEN
    fnd_message.set_token(token2,value2);
  END IF;

  IF (token3 IS NOT NULL AND value3 IS NOT NULL)
  THEN
    fnd_message.set_token(token3,value3);
  END IF;

  IF (token4 IS NOT NULL AND value4 IS NOT NULL)
  THEN
    fnd_message.set_token(token4,value4);
  END IF;

  app_exception.raise_exception;

EXCEPTION
  WHEN OTHERS THEN
    Generic_Error(  'FND_MO_REPORTING_API.App_Error'
                  , sqlcode
                  , sqlerrm);
END App_Error;




--
-- Initialize
--
PROCEDURE Initialize
  (  p_reporting_level        IN VARCHAR2
   , p_reporting_entity_id    IN NUMBER
   , p_pred_type              IN VARCHAR2 DEFAULT 'AUTO'
  )
IS

  l_count       NUMBER := 0;
  l_pred        VARCHAR2(2000)  DEFAULT NULL;
  l_pred_type   VARCHAR2(30)    DEFAULT 'EXISTS';
  l_multi_org_enabled   fnd_product_groups.multi_org_flag%TYPE;


BEGIN

 -- Validate_Reporting_Level( p_reporting_level );
 -- Validate_Reporting_Entity( p_reporting_level, p_reporting_entity_id );

  g_reporting_level := p_reporting_level;
  g_reporting_entity_id := p_reporting_entity_id;

  SELECT multi_org_flag
  INTO   l_multi_org_enabled
  FROM   fnd_product_groups
  WHERE  product_group_id = 1;

  IF (   p_pred_type = 'AUTO'
      OR p_pred_type = 'INSTR'
      OR p_pred_type IS NULL
     )
  THEN
   --bug 8649027
    IF p_reporting_level = '1000' THEN
      SELECT  count(*)
      INTO    l_count
      FROM    hr_organization_information
      WHERE   org_information_context = 'Operating Unit Information'
      AND     TO_NUMBER(trim(org_information3)) = p_reporting_entity_id;
    END IF;

    IF ( l_count <= g_max_num )
    THEN
      l_pred_type := 'INSTR';
    ELSE
      l_pred_type := 'EXISTS';
    END IF;

  ELSIF (   p_pred_type = 'EXISTS'
         OR p_pred_type = 'IN_SELECT'
         OR p_pred_type = 'IN_LIST'
        )
  THEN

    l_pred_type := p_pred_type;

  END IF;


  IF ( p_reporting_level = '3000' )  /* Operating Unit Level */
  THEN
    l_pred := ' AND NVL(/*ALIAS*/ORG_ID, :p_reporting_entity_id) = '
            ||':p_reporting_entity_id ';

  ELSIF (
               p_reporting_level = '1000'  /* Set of Books Level */
         AND l_pred_type = 'IN_LIST'
        )
  THEN

    l_pred := ' AND (NVL(/*ALIAS*/ORG_ID, -99) IN ( -99';

    FOR l_org_rec IN
        ( SELECT  organization_id
          FROM    hr_organization_information
          WHERE   org_information_context = 'Operating Unit Information'
          AND     DECODE(  p_reporting_level
                         , '1000'   , TO_NUMBER(trim(org_information3))
                         , '3000' , organization_id ) =
                           p_reporting_entity_id )
    LOOP

      l_pred := l_pred||', '||l_org_rec.organization_id;

    END LOOP;

    l_pred := l_pred||')) ';

  ELSIF (  p_reporting_level = '1000' AND l_pred_type = 'INSTR'
        )
  THEN

    l_pred := ' AND (/*ALIAS*/ORG_ID IS NULL OR INSTRB(''*';

    FOR l_org_rec IN
        ( SELECT  organization_id
          FROM    hr_organization_information
          WHERE   org_information_context = 'Operating Unit Information'
          AND     DECODE(  p_reporting_level
                         , '1000'   , TO_NUMBER(trim(org_information3))
                         , '3000' , organization_id ) =
                           p_reporting_entity_id )
    LOOP

      l_pred := l_pred||l_org_rec.organization_id||'*';

    END LOOP;

    l_pred := l_pred||''', ''*''||TO_CHAR(/*ALIAS*/ORG_ID)||''*'') > 0) ';

  ELSIF (  p_reporting_level = '1000' AND l_pred_type = 'EXISTS'
        )
  THEN

    l_pred :=
          ' AND (/*ALIAS*/org_id IS NULL OR '
        ||'EXISTS '
        ||'( SELECT  /*HINT*/ 1'
        || ' FROM    hr_organization_information org_info'
        || ' WHERE   /*ALIAS*/org_id = org_info.organization_id'
        || ' AND     org_info.org_information_context = ''Operating Unit Information''';

    IF (p_reporting_level = '1000')
    THEN
      l_pred := l_pred||' AND TO_NUMBER(trim(org_info.org_information3)) = '
                      ||    ' :p_reporting_entity_id';

    ELSIF (p_reporting_level = '2000')
    THEN
      l_pred := l_pred||' AND TO_NUMBER(trim(org_info.org_information2)) = '
                      ||    ' :p_reporting_entity_id';

    END IF;

    l_pred := l_pred||')) ';

  ELSIF ( p_reporting_level = '1000' AND l_pred_type = 'IN_SELECT'
        )
  THEN

    l_pred :=
          ' AND (NVL(/*ALIAS*/org_id, -99) IN '
        ||'( SELECT  -99'
        || ' FROM    DUAL'
        || ' UNION'
        || ' SELECT  /*HINT*/ organization_id'
        || ' FROM    hr_organization_information'
        || ' WHERE   org_information_context = ''Operating Unit Information''';

    IF (p_reporting_level = '1000')
    THEN
      l_pred := l_pred||' AND TO_NUMBER(trim(org_information3)) = '
                      ||    ' :p_reporting_entity_id';

    ELSIF (p_reporting_level = '2000')
    THEN
      l_pred := l_pred||' AND TO_NUMBER(trim(org_information2)) = '
                      ||    ' :p_reporting_entity_id';

    END IF;

    l_pred := l_pred||')) ';

  END IF;

  g_pred := l_pred;

  l_pred := NULL;

EXCEPTION
  WHEN OTHERS THEN
    Generic_Error(  'FND_MO_REPORTING_API.Initialize'
                  , sqlcode
                  , sqlerrm);

END Initialize;


--
-- Get predicate
--
FUNCTION Get_Predicate
  (  p_alias                    IN VARCHAR2 DEFAULT NULL
   , p_hint                     IN VARCHAR2 DEFAULT NULL
   , p_variable_override        IN VARCHAR2 DEFAULT ' :p_reporting_entity_id '
  )
RETURN VARCHAR2
IS

l_return_pred VARCHAR2(2000) DEFAULT NULL;

BEGIN

  l_return_pred := replace(  g_pred
                           , '/*ALIAS*/'
                           , p_alias||'.');

  l_return_pred := replace(  l_return_pred
                           , '/*HINT*/'
                           , '/* '||p_hint||' */');

  l_return_pred := replace(  l_return_pred
                           , ':p_reporting_entity_id'
                           , p_variable_override);

  RETURN l_return_pred;

EXCEPTION
  WHEN OTHERS THEN
    Generic_Error(  'FND_MO_REPORTING_API.Get_Predicate'
                  , sqlcode
                  , sqlerrm);

END Get_Predicate;


--
-- Get the reporting level name
--
FUNCTION Get_Reporting_Level_Name
RETURN VARCHAR2
IS
  l_reporting_level_name        fnd_lookups.meaning%TYPE;

BEGIN
  SELECT  meaning
  INTO    l_reporting_level_name
  FROM    fnd_lookups
  WHERE   lookup_type = 'FND_MO_REPORTING_LEVEL'
  AND     lookup_code = g_reporting_level;

  RETURN l_reporting_level_name;

EXCEPTION
  WHEN OTHERS THEN
    Generic_Error(  'FND_MO_REPORTING_API.Get_Reporting_Level_Name'
                  , sqlcode
                  , sqlerrm);

END Get_Reporting_Level_Name;




--
-- Get the reporting entity name
--
FUNCTION Get_Reporting_Entity_Name
RETURN VARCHAR2
IS
  l_reporting_entity_name       fnd_mo_reporting_entities_v
                                .entity_name%TYPE;

BEGIN

  IF g_reporting_level = '1000'
  THEN
    SELECT   name
    INTO     l_reporting_entity_name
    FROM     gl_sets_of_books
    WHERE    set_of_books_id = g_reporting_entity_id;
  ELSE
    SELECT   name
    INTO     l_reporting_entity_name
    FROM     hr_all_organization_units
    WHERE    organization_id = g_reporting_entity_id;
  END IF;

  RETURN l_reporting_entity_name;

EXCEPTION
  WHEN OTHERS THEN
    Generic_Error(  'FND_MO_REPORTING_API.Get_Reporting_Entity_Name'
                  , sqlcode
                  , sqlerrm);

END Get_Reporting_Entity_Name;




--
-- Validate the reporting level
--
PROCEDURE Validate_Reporting_Level
  (  p_reporting_level          IN VARCHAR2 )
IS

  l_top_reporting_level fnd_profile_option_values.profile_option_value%TYPE;

  CURSOR l_check_reporting_level
    (  x_reporting_level      IN VARCHAR2
     , x_top_reporting_level  IN VARCHAR2
    )
  IS
    SELECT   1
    FROM     fnd_lookups lp
    WHERE    lookup_type = 'FND_MO_REPORTING_LEVEL'
    AND      lookup_code = x_reporting_level
    AND      TO_NUMBER(trim(lookup_code)) >=
             TO_NUMBER(trim(x_top_reporting_level));

  l_dummy NUMBER;

BEGIN

  l_top_reporting_level := fnd_profile.value('FND_MO_TOP_REPORTING_LEVEL');

  OPEN l_check_reporting_level( p_reporting_level, l_top_reporting_level);
  FETCH l_check_reporting_level INTO l_dummy;

  IF (l_check_reporting_level%NOTFOUND )
  THEN
    CLOSE l_check_reporting_level;
    App_Error(  'FND_MO_RPTAPI_LEVEL'
              , 'REPORTING_LEVEL', p_reporting_level
              , 'TOP_REPORTING_LEVEL', l_top_reporting_level);

  END IF;

  CLOSE l_check_reporting_level;

EXCEPTION
  WHEN OTHERS THEN
    Generic_Error(  'FND_MO_REPORTING_API.Validate_Reporting_Level'
                  , sqlcode
                  , sqlerrm);

END Validate_Reporting_Level;




--
-- Validate the reporting entity
--
PROCEDURE Validate_Reporting_Entity
  (  p_reporting_level           IN VARCHAR2
   , p_reporting_entity_id       IN NUMBER
  )
IS

  CURSOR l_check_reporting_entity
    (  x_reporting_level IN VARCHAR2
     , x_reporting_entity_id IN NUMBER
    )
  IS
  SELECT  1
  FROM    FND_MO_REPORTING_ENTITIES_V
  WHERE   reporting_level = p_reporting_level
  AND DECODE(  fnd_profile.value_wnps('FND_MO_TOP_REPORTING_LEVEL')
             , '1000', ledger_id
             , '3000', operating_unit_id) =
      ( SELECT DECODE(  fnd_profile.value_wnps('FND_MO_TOP_REPORTING_LEVEL')
                      , '1000', TO_NUMBER(trim(org_information3))
                      , '3000', organization_id )
        FROM   hr_organization_information
        WHERE  organization_id = fnd_profile.value_wnps('ORG_ID')
        AND    org_information_context = 'Operating Unit Information'
      )
  AND entity_id = x_reporting_entity_id;

  l_dummy NUMBER;

BEGIN

  OPEN l_check_reporting_entity ( p_reporting_level, p_reporting_entity_id );
  FETCH l_check_reporting_entity INTO l_dummy;

  IF ( l_check_reporting_entity%NOTFOUND )
  THEN
    CLOSE l_check_reporting_entity;
    App_Error('FND_MO_RPTAPI_ENTITY', 'REPORTING_ENTITY', p_reporting_entity_id);

  END IF;

  CLOSE l_check_reporting_entity;

EXCEPTION
  WHEN OTHERS THEN
    Generic_Error(  'FND_MO_REPORTING_API.Validate_Reporting_Entity'
                  , sqlcode
                  , sqlerrm);

END Validate_Reporting_Entity;




END FND_MO_REPORTING_API;

/
