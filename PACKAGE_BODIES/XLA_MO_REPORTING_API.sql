--------------------------------------------------------
--  DDL for Package Body XLA_MO_REPORTING_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_MO_REPORTING_API" AS
/*  $Header: XLAMORPB.pls 120.8.12010000.4 2010/01/20 10:06:31 nmsubram ship $ */

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
   FND_MESSAGE.SET_NAME('FND', 'SQL_PLSQL_ERROR');
   FND_MESSAGE.SET_TOKEN('ROUTINE', routine);
   FND_MESSAGE.SET_TOKEN('ERRNO', errcode);
   FND_MESSAGE.SET_TOKEN('REASON', errmsg);
   IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED, routine, FALSE);
   END IF;
   APP_EXCEPTION.RAISE_EXCEPTION;
EXCEPTION
   WHEN OTHERS THEN RAISE;
END;




--
--  App_Error (Internal)
--
PROCEDURE App_Error
  (  routine            IN VARCHAR2
   , error_name         IN VARCHAR2
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
  fnd_message.set_name('XLA',error_name);

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

  IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR, routine, FALSE);
  END IF;

  app_exception.raise_exception;

EXCEPTION
  WHEN OTHERS THEN
    Generic_Error(  'xla.plsql.XLA_MO_REPORTING_API.APP_ERROR'
                  , sqlcode
                  , sqlerrm);
END App_Error;




--
-- Use this procedure to initialize the reporting API.
--
PROCEDURE Initialize
  (  p_reporting_level        IN VARCHAR2 DEFAULT '3000'
   , p_reporting_entity_id    IN NUMBER
   , p_pred_type              IN VARCHAR2 DEFAULT 'AUTO'
  )
IS

BEGIN
   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     'xla.plsql.XLA_MO_REPORTING_API.INITIALIZE.begin',
                     'Calling PL/SQL procedure XLA_MO_REPORTING_API.INITIALIZE:'||
                     ' p_reporting_level=>'||p_reporting_level||
                     ',p_reporting_entity_id=>'||p_reporting_entity_id||
                     ',p_pred_type=>'||p_pred_type);
   END IF;

   initialize(p_reporting_level,
             p_reporting_entity_id,
             p_pred_type,
             'Y');

   IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                     'xla.plsql.XLA_MO_REPORTING_API.INITIALIZE.end',
                     'Returning from PL/SQL procedure XLA_MO_REPORTING_API.INITIALIZE:');

   END IF;

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
                           , '/*+ '||p_hint||' */');

  l_return_pred := replace(  l_return_pred
                           , ':p_reporting_entity_id'
                           , p_variable_override);

  RETURN l_return_pred;

EXCEPTION
  WHEN OTHERS THEN
    Generic_Error(  'xla.plsql.XLA_MO_REPORTING_API.GET_PREDICATE'
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
  WHERE   lookup_type = 'XLA_MO_REPORTING_LEVEL'
  AND     lookup_code = g_reporting_level;

  RETURN l_reporting_level_name;

EXCEPTION
  WHEN OTHERS THEN
    Generic_Error(  'xla.plsql.XLA_MO_REPORTING_API.GET_REPORTING_LEVEL_NAME'
                  , sqlcode
                  , sqlerrm);

END Get_Reporting_Level_Name;




--
-- Get the reporting entity name
--
FUNCTION Get_Reporting_Entity_Name
RETURN VARCHAR2
IS
  l_reporting_entity_name       xla_mo_reporting_entities_v
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
    Generic_Error(  'xla.plsql.XLA_MO_REPORTING_API.GET_REPORTING_ENTITY_NAME'
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
    WHERE    lookup_type = 'XLA_MO_REPORTING_LEVEL'
    AND      lookup_code = x_reporting_level
    AND      TO_NUMBER(lookup_code) >=
             TO_NUMBER(x_top_reporting_level);

  l_dummy NUMBER;

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                    'xla.plsql.XLA_MO_REPORTING_API.VALIDATE_REPORTING_LEVEL.begin',
                    'Calling PL/SQL procedure XLA_MO_REPORTING_API.VALIDATE_REPORTING_LEVEL:'||
                    ' p_reporting_level=>'||p_reporting_level);
  END IF;

  l_top_reporting_level := fnd_profile.value('XLA_MO_TOP_REPORTING_LEVEL');

  IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_EVENT,
                    'xla.plsql.XLA_MO_REPORTING_API.VALIDATE_REPORTING_LEVEL.config',
                    'MO: Top Reporting Level='||l_top_reporting_level);
  END IF;

  OPEN l_check_reporting_level( p_reporting_level, l_top_reporting_level);
  FETCH l_check_reporting_level INTO l_dummy;

  IF (l_check_reporting_level%NOTFOUND )
  THEN
    CLOSE l_check_reporting_level;
    App_Error(  'xla.plsql.XLA_MO_REPORTING_API.VALIDATE_REPORTING_LEVEL'
              , 'XLA_MO_RPTAPI_LEVEL'
              , 'REPORTING_LEVEL', p_reporting_level
              , 'TOP_REPORTING_LEVEL', l_top_reporting_level);

  END IF;

  CLOSE l_check_reporting_level;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                    'xla.plsql.XLA_MO_REPORTING_API.VALIDATE_REPORTING_LEVEL.end',
                    'Returning from PL/SQL procedure '||
                    'XLA_MO_REPORTING_API.VALIDATE_REPORTING_LEVEL');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Generic_Error(  'xla.plsql.XLA_MO_REPORTING_API.VALIDATE_REPORTING_LEVEL'
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
  FROM    XLA_MO_REPORTING_ENTITIES_V
  WHERE   reporting_level = p_reporting_level
/* Commented out NOCOPY the code below, since it does not work for reporting set
   of books. Intead, making a call to validate_reporting_level to make sure
   that p_reporting_level value is within the allowed value for profile option
   value for MO: Top Reporting Level.
  AND DECODE(  fnd_profile.value_wnps('XLA_MO_TOP_REPORTING_LEVEL')
             , '1000', set_of_books_id
             , '2000', legal_entity_id
             , '3000', operating_unit_id) =
      ( SELECT DECODE(  fnd_profile.value_wnps('XLA_MO_TOP_REPORTING_LEVEL')
                      , '1000', TO_NUMBER(org_information3)
                      , '2000', TO_NUMBER(org_information2)
                      , '3000', organization_id )
        FROM   hr_organization_information
        WHERE  organization_id = fnd_profile.value_wnps('ORG_ID')
        AND    org_information_context = 'Operating Unit Information'
      )
*/
  AND entity_id = x_reporting_entity_id;

  l_dummy NUMBER;

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                    'xla.plsql.XLA_MO_REPORTING_API.VALIDATE_REPORTING_ENTITY.begin',
                    'Calling PL/SQL procedure XLA_MO_REPORTING_API.VALIDATE_REPORTING_ENTITY:'||
                    ' p_reporting_level=>'||p_reporting_level||
                    ',p_reporting_entity_id=>'||p_reporting_entity_id);
  END IF;

  validate_reporting_level(p_reporting_level);

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                    'xla.plsql.XLA_MO_REPORTING_API.VALIDATE_REPORTING_ENTITY.rep_level_valid',
                    'Reporting level is valid');
  END IF;

  OPEN l_check_reporting_entity ( p_reporting_level, p_reporting_entity_id );
  FETCH l_check_reporting_entity INTO l_dummy;

  IF ( l_check_reporting_entity%NOTFOUND )
  THEN
    CLOSE l_check_reporting_entity;
    App_Error('xla.plsql.XLA_MO_REPORTING_API.VALIDATE_REPORTING_ENTITY',
              'XLA_MO_RPTAPI_ENTITY',
              'REPORTING_ENTITY',
              p_reporting_entity_id);
  END IF;

  CLOSE l_check_reporting_entity;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                    'xla.plsql.XLA_MO_REPORTING_API.VALIDATE_REPORTING_ENTITY.end',
                    'Returning from PL/SQL procedure '||
                    'XLA_MO_REPORTING_API.VALIDATE_REPORTING_ENTITY:');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Generic_Error(  'xla.plsql.XLA_MO_REPORTING_API.VALIDATE_REPORTING_ENTITY'
                  , sqlcode
                  , sqlerrm);

END Validate_Reporting_Entity;

--
-- DESCRIPTION
--   This procedure initializes the reporting API.
--
--   The parameter p_use_nvl indicates whether the NVL should be used
--   around ORG_ID in the generated predicate. In a non Multi-Org
--   environment the NVL is always used (i.e. p_use_nvl is ignored).
--   In a Multi-Org environment p_use_nvl should be set to 'Y' unless
--   there are performance reasons not to use it. Keep in mind that
--   for some tables NVL must always be used because they may contain
--   null ORG_ID values. It is up to the caller of this procedure to
--   determine whether this is the case. See bug 3025408.
--
-- PARAMETERS
--   p_reporting_level     - The reporting level (1000, 2000, 3000
--                           for set of books, legal entity and operating
--                           unit respectively).
--   p_reporting_entity_id - The identifier of the reporting entity.
--   p_pred_type           - The type of the generated predicate.
--                           (AUTO, EXISTS, IN_LIST, IN_SELECT, INSTR)
--   p_use_nvl             - Set it to 'N' to eliminate NVL from the
--                           predicate. Any other value will include
--                           the NVL function.
--
PROCEDURE Initialize
  (  p_reporting_level        IN VARCHAR2 DEFAULT '3000'
   , p_reporting_entity_id    IN NUMBER
   , p_pred_type              IN VARCHAR2 DEFAULT 'AUTO'
   , p_use_nvl                IN VARCHAR2
  )
IS

  l_count       NUMBER := 0;
  l_pred        VARCHAR2(2000)  DEFAULT NULL;
  l_pred_type   VARCHAR2(30)    DEFAULT 'EXISTS';
  l_multi_org_enabled   fnd_product_groups.multi_org_flag%TYPE;

  l_sob_type  VARCHAR2(1);
  l_reporting_entity_id   NUMBER(15);

  l_use_nvl     VARCHAR2(1);

BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                    'xla.plsql.XLA_MO_REPORTING_API.INITIALIZE.begin',
                    'Calling PL/SQL procedure XLA_MO_REPORTING_API.INITIALIZE:'||
                    ' p_reporting_level=>'||p_reporting_level||
                    ',p_reporting_entity_id=>'||p_reporting_entity_id||
                    ',p_pred_type=>'||p_pred_type||
                    ',p_use_nvl=>'||p_use_nvl);
  END IF;

  SELECT nvl(multi_org_flag, 'N')
    INTO l_multi_org_enabled
    FROM fnd_product_groups
   WHERE product_group_id = 1;

  IF (l_multi_org_enabled = 'Y' AND p_use_nvl = 'N') THEN
    l_use_nvl := 'N';
  ELSE
    l_use_nvl := 'Y';
  END IF;

  IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_EVENT,
                    'xla.plsql.XLA_MO_REPORTING_API.INITIALIZE.use_nvl',
                    'nvl(fnd_product_groups.multi_org_flag,''N'')='||l_multi_org_enabled||
                    ',l_use_nvl='||l_use_nvl);
  END IF;

  -- Validate_Reporting_Level( p_reporting_level );
  -- Validate_Reporting_Entity( p_reporting_level, p_reporting_entity_id );

  g_reporting_level := p_reporting_level;
  g_reporting_entity_id := p_reporting_entity_id;

  l_reporting_entity_id := p_reporting_entity_id;
  -- Check if the SOB is Primary or Reporting if reporting level is 1000
  -- If reporting, we need to get the primary set of books and then use that
  -- value to get the operating unit information from HR tables. There is no
  -- association of primary and reporting set of books in HR.
  IF p_reporting_level = '1000' then
    gl_mc_info.get_sob_type(p_reporting_entity_id, l_sob_type);

    IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EVENT,
                      'xla.plsql.XLA_MO_REPORTING_API.INITIALIZE.get_sob_type',
                      'gl_mc_info.get_sob_type='||l_sob_type);
    END IF;

    IF l_sob_type = 'R' then

      -- Use MRC API to get the primary set of books. The API will return the
      -- first primary set of books if a reportign SOb is assigned to multiple
      -- primary SOB. MRC team mentioned that this is not supported currently.
      -- When this is supported both MRC and our code needs to be changed.
      -- a given reporting set of books.
      l_reporting_entity_id :=
                 gl_mc_info.get_primary_set_of_books_id(p_reporting_entity_id);

      IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_EVENT,
                        'xla.plsql.XLA_MO_REPORTING_API.INITIALIZE.primary_sob_id',
                        'gl_mc_info.primary_set_of_books_id='||l_reporting_entity_id);
      END IF;

    END IF;
  END IF;

  IF (   p_pred_type = 'AUTO'
      OR p_pred_type = 'INSTR'
      OR p_pred_type IS NULL
     )
  THEN

    --
    --8803371 Added hint to force the usage of index

    SELECT /*+ INDEX(HR_ORGANIZATION_INFORMATION HR_ORGANIZATION_INFORMATIO_FK1) */ count(*)
    INTO    l_count
    FROM    hr_organization_information
    WHERE   org_information_context = 'Operating Unit Information'
    AND     DECODE(  p_reporting_level
                     , '1000'   , org_information3
                     , '2000'   , org_information2) =
            to_char(l_reporting_entity_id); -- bug 9108714

    IF ( l_count <= g_max_num )
    THEN
      l_pred_type := 'INSTR';
    ELSE
      l_pred_type := 'EXISTS';
    END IF;

    IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EVENT,
                      'xla.plsql.XLA_MO_REPORTING_API.INITIALIZE.pred_type',
                      'Determined predicate type:'||
                      ' l_count='||l_count||
                      ',g_max_num='||g_max_num||
                      ',l_pred_type='||l_pred_type);
    END IF;

  ELSIF (   p_pred_type = 'EXISTS'
         OR p_pred_type = 'IN_SELECT'
         OR p_pred_type = 'IN_LIST'
        )
  THEN

    l_pred_type := p_pred_type;

    IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EVENT,
                      'xla.plsql.XLA_MO_REPORTING_API.INITIALIZE.pred_type',
                      'Determined predicate type: '||
                      'l_pred_type='||l_pred_type);
    END IF;

  END IF;


  IF ( p_reporting_level = '3000' )  /* Operating Unit Level */  THEN

    IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EVENT,
                      'xla.plsql.XLA_MO_REPORTING_API.INITIALIZE.pred_text',
                      'Generating predicate for reporting level 3000');
    END IF;

    IF (l_use_nvl = 'Y') THEN
      l_pred := ' AND NVL(/*ALIAS*/ORG_ID, :p_reporting_entity_id) = '
              ||':p_reporting_entity_id ';
    ELSE
      l_pred := ' AND /*ALIAS*/ORG_ID = :p_reporting_entity_id ';
    END IF;

  ELSIF (  (     p_reporting_level = '2000'  /* Legal Entity Level */
           OR  p_reporting_level = '1000'  /* Set of Books Level */
           )  AND l_pred_type = 'IN_LIST' )  THEN

-- replaced IN logic with EXISTS for performance reasons

    IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EVENT,
                      'xla.plsql.XLA_MO_REPORTING_API.INITIALIZE.pred_text',
                      'Generating EXISTS predicate for reporting level 1000/2000');
    END IF;

    IF (l_use_nvl = 'Y') THEN
      l_pred := ' AND (/*ALIAS*/org_id IS NULL OR ';
    ELSE
      l_pred := ' AND ( ';
    END IF;

    l_pred := l_pred
        ||'EXISTS '
        ||'( SELECT  /*HINT*/ 1'
        || ' FROM    hr_organization_information org_info'
        || ' WHERE   /*ALIAS*/org_id = org_info.organization_id'
        || ' AND     org_info.org_information_context = ''Operating Unit Information''';

    IF (p_reporting_level = '1000')
    THEN
    --bug 9108714
      l_pred := l_pred||' AND org_info.org_information3 = TO_CHAR('
                      ||    l_reporting_entity_id || ')';

    ELSIF (p_reporting_level = '2000')
    THEN
    --bug 9108714
      l_pred := l_pred||' AND org_info.org_information2 = TO_CHAR(:p_reporting_entity_id)' ;

    END IF;

    l_pred := l_pred||')) ';

--

  ELSIF (  (     p_reporting_level = '2000'
           OR  p_reporting_level = '1000' )
        AND l_pred_type = 'INSTR'  )  THEN

-- replaced INSTR logic with EXISTS for performance reasons

    IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EVENT,
                      'xla.plsql.XLA_MO_REPORTING_API.INITIALIZE.pred_text',
                      'Generating EXISTS predicate for reporting level 1000/2000');
    END IF;

    IF (l_use_nvl = 'Y') THEN
      l_pred := ' AND (/*ALIAS*/org_id IS NULL OR ';
    ELSE
      l_pred := ' AND ( ';
    END IF;

    l_pred := l_pred
        ||'EXISTS '
        ||'( SELECT  /*HINT*/ 1'
        || ' FROM    hr_organization_information org_info'
        || ' WHERE   /*ALIAS*/org_id = org_info.organization_id'
        || ' AND     org_info.org_information_context = ''Operating Unit Information''';

    IF (p_reporting_level = '1000')
    THEN
    --bug 9108714
      l_pred := l_pred||' AND org_info.org_information3 = TO_CHAR('
                      ||    l_reporting_entity_id || ')';

    ELSIF (p_reporting_level = '2000')
    THEN
    --bug 9108714
      l_pred := l_pred||' AND org_info.org_information2 = TO_CHAR(:p_reporting_entity_id)' ;

    END IF;

    l_pred := l_pred||')) ';

--

  ELSIF (  (  p_reporting_level = '2000'
    OR  p_reporting_level = '1000'  )
    AND l_pred_type = 'EXISTS'  )  THEN

    IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EVENT,
                      'xla.plsql.XLA_MO_REPORTING_API.INITIALIZE.pred_text',
                      'Generating EXISTS predicate for reporting level 1000/2000');
    END IF;

    IF (l_use_nvl = 'Y') THEN
      l_pred := ' AND (/*ALIAS*/org_id IS NULL OR ';
    ELSE
      l_pred := ' AND ( ';
    END IF;

    l_pred := l_pred
        ||'EXISTS '
        ||'( SELECT  /*HINT*/ 1'
        || ' FROM    hr_organization_information org_info'
        || ' WHERE   /*ALIAS*/org_id = org_info.organization_id'
        || ' AND     org_info.org_information_context = ''Operating Unit Information''';

    IF (p_reporting_level = '1000')
    THEN
    --bug 9108714
      l_pred := l_pred||' AND org_info.org_information3 = TO_CHAR('
                      ||    l_reporting_entity_id || ')';

    ELSIF (p_reporting_level = '2000')
    THEN
    --bug 9108714
      l_pred := l_pred||' AND org_info.org_information2 = TO_CHAR(:p_reporting_entity_id)' ;

    END IF;

    l_pred := l_pred||')) ';

  ELSIF ( (  p_reporting_level = '2000'
           OR  p_reporting_level = '1000' )
         AND l_pred_type = 'IN_SELECT' )  THEN

    IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EVENT,
                      'xla.plsql.XLA_MO_REPORTING_API.INITIALIZE.pred_text',
                      'Generating IN_SELECT predicate for reporting level 1000/2000');
    END IF;

    IF (l_use_nvl = 'Y') THEN
      l_pred := ' AND (NVL(/*ALIAS*/org_id, -99) IN '
        ||'( SELECT  -99'
        || ' FROM    DUAL'
        || ' UNION'
        || ' SELECT  /*HINT*/ organization_id'
        || ' FROM    hr_organization_information'
        || ' WHERE   org_information_context = ''Operating Unit Information''';
    ELSE
      l_pred := ' AND (/*ALIAS*/org_id IN '
        ||'( SELECT  /*HINT*/ organization_id'
        || ' FROM    hr_organization_information'
        || ' WHERE   org_information_context = ''Operating Unit Information''';
    END IF;

    IF (p_reporting_level = '1000')
    THEN
    --bug 9108714
      l_pred := l_pred||' AND org_information3 = TO_CHAR('
                      ||    l_reporting_entity_id || ')';

    ELSIF (p_reporting_level = '2000')
    THEN
    --bug 9108714
      l_pred := l_pred||' AND org_information2 = TO_CHAR(:p_reporting_entity_id)' ;

    END IF;

    l_pred := l_pred||')) ';

  END IF;

  g_pred := l_pred;

  l_pred := NULL;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                    'xla.plsql.XLA_MO_REPORTING_API.INITIALIZE.end',
                    'Returning from PL/SQL procedure XLA_MO_REPORTING_API.INITIALIZE:'||
                    ' g_reporting_level='||g_reporting_level||
                    ',g_reporting_entity_id='||g_reporting_entity_id||
                    ',g_max_num='||g_max_num||
                    ',g_pred='||g_pred);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    Generic_Error(  'xla.plsql.XLA_MO_REPORTING_API.INITIALIZE'
                  , sqlcode
                  , sqlerrm);

END initialize;


END XLA_MO_REPORTING_API;

/
