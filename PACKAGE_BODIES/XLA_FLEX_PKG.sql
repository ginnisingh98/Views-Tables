--------------------------------------------------------
--  DDL for Package Body XLA_FLEX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLA_FLEX_PKG" AS
/* $Header: xlacmflx.pkb 120.18.12010000.6 2009/06/19 09:35:19 rajose ship $ */
/*======================================================================+
|             Copyright (c) 2001-2002 Oracle Corporation                |
|                       Redwood Shores, CA, USA                         |
|                         All rights reserved.                          |
+=======================================================================+
| PACKAGE NAME                                                          |
|    xla_flex_pkg                                                       |
|                                                                       |
| DESCRIPTION                                                           |
|    XLA Flex Package                                                   |
|                                                                       |
| HISTORY                                                               |
|    01-May-01 Dimple Shah    Created                                   |
|    18-Jun-01 P. Labrevois   Added cache                               |
|                             Added table value set support             |
|    23-May-03 Shishir Joshi  Removed message number from the message   |
|                             name                                      |
|                                                                       |
+======================================================================*/

--
-- Flex value set cache
--
g_flex_value_set_name                 VARCHAR2(80);
g_flex_value_set_id                   INTEGER;

--
-- Coa cache
--
g_coa_application_id                  INTEGER;
g_coa_flex_code                       VARCHAR2(4);
g_coa_id                              INTEGER;
g_coa_name                            VARCHAR2(80);

--
-- Flex value meaning cache
--
g_meaning_flex_value_set_id           INTEGER;
g_meaning_flex_value                  VARCHAR2(4000);
g_meaning_meaning                     VARCHAR2(4000);

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_value_set_name                                                    |
|                                                                       |
| Get the value set name for the value set id                           |
|                                                                       |
+======================================================================*/
FUNCTION  get_value_set_name
  (p_flex_value_set_id            IN  INTEGER)
RETURN VARCHAR2

IS

BEGIN
xla_utility_pkg.trace('> xla_flex_pkg.get_value_set_name'                        , 20);

xla_utility_pkg.trace('Value set id              = '||p_flex_value_set_id           , 40);

IF p_flex_value_set_id = g_flex_value_set_id  THEN

   NULL;

ELSE

   SELECT flex_value_set_name
   INTO   g_flex_value_set_name
   FROM   fnd_flex_value_sets
   WHERE  flex_value_set_id = p_flex_value_set_id
   ;

   g_flex_value_set_id   := p_flex_value_set_id;
END IF;

xla_utility_pkg.trace('Value set name                   = '||g_flex_value_set_name  , 40);

xla_utility_pkg.trace('< xla_flex_pkg.get_value_set_name'                        , 20);

RETURN g_flex_value_set_name;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_flex_pkg.get_value_set_name');
END get_value_set_name;


/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_chart_of_accounts_name                                            |
|                                                                       |
| Get the chart of accounts name for the chart of accounts id           |
|                                                                       |
+======================================================================*/
FUNCTION  get_chart_of_accounts_name
  (p_application_id               IN   INTEGER
  ,p_flex_code                    IN   VARCHAR2
  ,p_chart_of_accounts_id         IN   INTEGER)
RETURN VARCHAR2
IS

l_chart_of_accounts_name                  VARCHAR2(80);

BEGIN
xla_utility_pkg.trace('> xla_flex_pkg.get_chart_of_accounts_name'                   , 20);

xla_utility_pkg.trace('Application id                     = '||p_application_id        , 40);
xla_utility_pkg.trace('Flex code                          = '||p_flex_code             , 40);
xla_utility_pkg.trace('Chart of accounts id               = '||p_chart_of_accounts_id  , 40);

IF     (p_application_id       = g_coa_application_id
   AND  p_flex_code            = g_coa_flex_code
   AND  p_chart_of_accounts_id = g_coa_id)  THEN

   NULL;

ELSE

   SELECT id_flex_structure_name
   INTO   g_coa_name
   FROM   fnd_id_flex_structures_v
   WHERE  application_id = p_application_id
     AND  id_flex_code   = p_flex_code
     AND  id_flex_num    = p_chart_of_accounts_id
   ;

   g_coa_application_id  := p_application_id;
   g_coa_flex_code       := p_flex_code;
   g_coa_id              := p_chart_of_accounts_id;
END IF;

xla_utility_pkg.trace('Chart of accounts name             = '||g_coa_name              , 40);

xla_utility_pkg.trace('< xla_flex_pkg.get_chart_of_accounts_name'                   , 20);

RETURN g_coa_name;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_flex_pkg.get_chart_of_accounts_name');
END get_chart_of_accounts_name;


/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_flexfield_segment_name                                            |
|                                                                       |
| Get the segment name for the segment code                             |
|                                                                       |
+======================================================================*/
FUNCTION  get_flexfield_segment_name
  (p_application_id                  IN  INTEGER
  ,p_flex_code                       IN  VARCHAR2
  ,p_chart_of_accounts_id            IN  INTEGER
  ,p_flexfield_segment_code          IN  VARCHAR2)

RETURN VARCHAR2
IS

l_flexfield_segment_name  VARCHAR2(80);

CURSOR c_segment_name
IS
SELECT segment_name
FROM   fnd_id_flex_segments_vl
WHERE  application_id          = p_application_id
  AND  id_flex_code            = p_flex_code
  AND  id_flex_num             = p_chart_of_accounts_id
  AND  application_column_name = p_flexfield_segment_code
;

BEGIN

xla_utility_pkg.trace('> xla_flex_pkg.get_flexfield_segment_name'             , 20);

xla_utility_pkg.trace('Application id              = '||p_application_id         , 40);
xla_utility_pkg.trace('Flex code                   = '||p_flex_code              , 40);
xla_utility_pkg.trace('Chart of accounts id        = '||p_chart_of_accounts_id   , 40);
xla_utility_pkg.trace('Flexfield Segment Code      = '||p_flexfield_segment_code , 40);

OPEN c_segment_name;

FETCH c_segment_name
INTO l_flexfield_segment_name;

CLOSE c_segment_name;

xla_utility_pkg.trace('Segment name             = '||l_flexfield_segment_name    , 40);

xla_utility_pkg.trace('< xla_flex_pkg.get_flexfield_segment_name'             , 20);

RETURN l_flexfield_segment_name;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   IF c_segment_name%ISOPEN THEN
      CLOSE c_segment_name;
   END IF;
   RAISE;
WHEN OTHERS                                   THEN
   IF c_segment_name%ISOPEN THEN
      CLOSE c_segment_name;
   END IF;
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_flex_pkg.get_flexfield_segment_name');
END get_flexfield_segment_name;


/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_flex_value_meaning                                                |
|                                                                       |
| Get the meaning for the flex_value                                    |
|                                                                       |
+======================================================================*/
FUNCTION  get_flex_value_meaning
  (p_flex_value_set_id               IN  INTEGER
  ,p_flex_value                      IN  VARCHAR2)

RETURN VARCHAR2
IS

l_validation_type                    VARCHAR2(1);
l_statement                          VARCHAR2(4000);
l_statement_run                      VARCHAR2(4000);
l_additional_where_clause            VARCHAR2(4000);
l_number                             NUMBER;

BEGIN
xla_utility_pkg.trace('> xla_flex_pkg.get_flex_value_meaning'                , 20);

xla_utility_pkg.trace('Flex_value_set_id              = '||p_flex_value_set_id  , 40);
xla_utility_pkg.trace('Flex_value                     = '||p_flex_value         , 40);

IF     (p_flex_value_set_id = g_meaning_flex_value_set_id
   AND  p_flex_value        = g_meaning_flex_value) THEN

   NULL;

ELSE

   SELECT validation_type
   INTO   l_validation_type
   FROM   fnd_flex_value_sets
   WHERE  flex_value_set_id = p_flex_value_set_id;

   IF l_validation_type in ('I','X') THEN

      --
      -- Independant value set
      --
      SELECT flex_value_meaning
      INTO   g_meaning_meaning
      FROM   fnd_flex_values_vl
      WHERE  flex_value_set_id      = p_flex_value_set_id
        AND  flex_value             = p_flex_value
      ;

      g_meaning_flex_value_set_id    := p_flex_value_set_id;
      g_meaning_flex_value           := p_flex_value;

   ELSIF l_validation_type = 'F' THEN

      IF xla_flex_pkg.id_column_is_null(p_flex_value_set_id) THEN

         g_meaning_meaning := p_flex_value;
         g_meaning_flex_value_set_id    := p_flex_value_set_id;
         g_meaning_flex_value           := p_flex_value;

      ELSE

         SELECT additional_where_clause
           INTO l_additional_where_clause
           FROM fnd_flex_validation_tables
          WHERE flex_value_set_id = p_flex_value_set_id;

         IF l_additional_where_clause is not null THEN

            l_additional_where_clause :=
                Ltrim(l_additional_where_clause);

            l_number := Instr(Upper(l_additional_where_clause),'ORDER BY ');
            IF (l_number = 1) THEN
               l_additional_where_clause := null;
            ELSE
               l_number := Instr(Upper(l_additional_where_clause),'WHERE ');

               IF (l_number = 1) THEN
                  l_additional_where_clause :=
                    Substr(l_additional_where_clause,7);
               ELSE
                  l_additional_where_clause := l_additional_where_clause;
               END IF;
            END IF;
         END IF;

         IF l_additional_where_clause is null THEN

            --
            -- Table value set
            --
            SELECT 'SELECT DISTINCT '||value_column_name
               ||  xla_environment_pkg.g_chr_newline
               ||  'FROM   '||application_table_name
               ||  xla_environment_pkg.g_chr_newline
               ||  'WHERE  '||id_column_name  || ' = :1'
            INTO    l_statement
            FROM    fnd_flex_validation_tables
            WHERE   flex_value_set_id       = p_flex_value_set_id
            ;

         ELSE
            --
            -- Table value set
            --
            SELECT 'SELECT DISTINCT '||value_column_name
               ||  xla_environment_pkg.g_chr_newline
               ||  'FROM   '||application_table_name
               ||  xla_environment_pkg.g_chr_newline
               ||  'WHERE  '||id_column_name  || ' = :1'
               ||  ' AND  '||l_additional_where_clause
            INTO    l_statement
            FROM    fnd_flex_validation_tables
            WHERE   flex_value_set_id       = p_flex_value_set_id
            ;


         END IF;

        xla_utility_pkg.trace('Statement                      = '||l_statement          , 50);

        --
        -- Bug912223 with 8i
        --
        l_statement_run := l_statement;

        EXECUTE IMMEDIATE l_statement_run
        INTO  g_meaning_meaning
        USING p_flex_value;

        g_meaning_flex_value_set_id    := p_flex_value_set_id;
        g_meaning_flex_value           := p_flex_value;

      END IF;



   ELSE
      xla_exceptions_pkg.raise_message
        ('XLA'      ,'XLA_COMMON_ERROR'
        ,'ERROR'    ,'Unsupported value set'
        ,'LOCATION' ,'xla_flex_pkg.get_flex_value_meaning');
   END IF;
END IF;

xla_utility_pkg.trace('Flex_value_meaning             = '||g_meaning_meaning     , 40);

xla_utility_pkg.trace('< xla_flex_pkg.get_flex_value_meaning'                 , 20);

RETURN g_meaning_meaning;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_flex_pkg.get_flex_value_meaning');
END get_flex_value_meaning;


/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_flexfield_segment_info                                            |
|                                                                       |
| Get the segment name and display segment num for the segment code     |
|                                                                       |
+======================================================================*/
FUNCTION  get_flexfield_segment_info
  (p_application_id                  IN     INTEGER
  ,p_flex_code                       IN     VARCHAR2
  ,p_chart_of_accounts_id            IN     INTEGER
  ,p_flexfield_segment_code          IN     VARCHAR2
  ,p_flexfield_segment_name          IN OUT NOCOPY VARCHAR2
  ,p_flexfield_segment_num           IN OUT NOCOPY INTEGER)

RETURN BOOLEAN
IS

this_segment_num    NUMBER(38);

CURSOR c_segment_info
IS
SELECT segment_name
      ,segment_num
FROM   fnd_id_flex_segments_vl
WHERE  application_id          = p_application_id
  AND  id_flex_code            = p_flex_code
  AND  id_flex_num             = p_chart_of_accounts_id
  AND  application_column_name = p_flexfield_segment_code
  AND  enabled_flag            = 'Y'
;


CURSOR c_segment_num
IS
SELECT count(segment_num)
FROM   fnd_id_flex_segments
WHERE  application_id          = p_application_id
  AND  id_flex_code            = p_flex_code
  AND  id_flex_num             = p_chart_of_accounts_id
  AND  enabled_flag            = 'Y'
  AND  display_flag            = 'Y'
  AND  segment_num             <= this_segment_num
;

BEGIN

xla_utility_pkg.trace('> xla_flex_pkg.get_flexfield_segment_info'                , 20);

xla_utility_pkg.trace('Application id              = '||p_application_id            , 40);
xla_utility_pkg.trace('Flex code                   = '||p_flex_code                 , 40);
xla_utility_pkg.trace('Chart of accounts id        = '||p_chart_of_accounts_id      , 40);
xla_utility_pkg.trace('Flexfield Segment Code      = '||p_flexfield_segment_code    , 40);

OPEN c_segment_info;

FETCH c_segment_info
INTO  p_flexfield_segment_name
     ,this_segment_num;

CLOSE c_segment_info;

OPEN c_segment_num;

FETCH c_segment_num
INTO p_flexfield_segment_num;

CLOSE c_segment_num;

xla_utility_pkg.trace('Segment name                = '||p_flexfield_segment_name    , 40);
xla_utility_pkg.trace('Segment num                  = '||p_flexfield_segment_num    , 40);

xla_utility_pkg.trace('< xla_flex_pkg.get_flexfield_segment_info'                , 20);

RETURN TRUE;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   IF c_segment_info%ISOPEN THEN
      CLOSE c_segment_info;
   END IF;
   RAISE;
WHEN OTHERS                                   THEN
   IF c_segment_info%ISOPEN THEN
      CLOSE c_segment_info;
   END IF;
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_flex_pkg.get_flexfield_segment_info');
END get_flexfield_segment_info;

/*======================================================================+
|                                                                       |
| Public Procedure                                                      |
|                                                                       |
| get_table_vset_select                                                 |
|                                                                       |
| Get the select for a table validated valueset                         |
|                                                                       |
+======================================================================*/
PROCEDURE get_table_vset_select
  (p_flex_value_set_id               IN     INTEGER
  ,p_select                          OUT NOCOPY    VARCHAR2
  ,p_mapping_code                    OUT NOCOPY    VARCHAR2
  ,p_success                         OUT NOCOPY    NUMBER)

IS


BEGIN

xla_utility_pkg.trace('> xla_flex_pkg.get_table_vset_select'                , 20);

xla_utility_pkg.trace('flex_value_set_id       = '||p_flex_value_set_id            , 40);

   fnd_flex_val_api.get_table_vset_select
                        (p_value_set_id           => p_flex_value_set_id
                        ,x_select                 => p_select
                        ,x_mapping_code           => p_mapping_code
                        ,x_success                => p_success);


xla_utility_pkg.trace('select       = '||p_select            , 40);
xla_utility_pkg.trace('mapping code       = '||p_mapping_code            , 40);
xla_utility_pkg.trace('success       = '||p_success            , 40);

xla_utility_pkg.trace('< xla_flex_pkg.get_table_vset_select'                , 20);

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_flex_pkg.get_table_vset_select');
END get_table_vset_select;


/* get_table_vset_return_col procedure is used to dynamically built the where clause while
searching on input/output value field  for flexfield type in Mapping sets
form XLAABDMS.fmb in detail block
p_select_col   indicates which column to be used in the select clause
p_where_col    indicates which column to be used in the where clause
               for the search criteria
p_type_out   1- indicates input Value can be searched as it is
             2- indicates input value should be searched on meaning column name
                SELECT column is value_column_name
             3- indicates input value should be searched on value column name
                SELECT column is id_column_name
             4- indicates input value should be searched on value column name
                SELECT column is id_column_name
For any exceptions search as it is ie p_type_out is 1
*/

PROCEDURE get_table_vset_return_col
  (p_flex_value_set_id               IN     INTEGER
  ,p_select_col                      OUT NOCOPY  VARCHAR2
  ,p_where_col                       OUT NOCOPY  VARCHAR2
  ,p_type_out                        OUT NOCOPY  INTEGER
  ) IS
CURSOR c_fvt IS
SELECT * FROM fnd_flex_validation_tables fvt
WHERE fvt.flex_value_set_id          = p_flex_value_set_id;

c_fvt_rec  c_fvt%ROWTYPE;


BEGIN

   OPEN c_fvt;
   FETCH c_fvt INTO c_fvt_rec;
   CLOSE c_fvt;

   IF (xla_flex_pkg.id_column_is_null(p_flex_value_set_id) and
               xla_flex_pkg.meaning_column_is_null(p_flex_value_set_id))
   THEN
       p_select_col := NULL;
       p_where_col  := NULL;
       p_type_out   := 1;
   ELSIF  xla_flex_pkg.id_column_is_null(p_flex_value_set_id)  THEN
       p_select_col  := c_fvt_rec.value_column_name;
       p_where_col   := c_fvt_rec.value_column_name;
       p_type_out    := 2;
   ELSIF xla_flex_pkg.meaning_column_is_null(p_flex_value_set_id)  THEN
       p_select_col  := c_fvt_rec.id_column_name;
       p_where_col   := c_fvt_rec.value_column_name;
       p_type_out    := 3;
   ELSE
       p_select_col  := c_fvt_rec.id_column_name;
       p_where_col   := c_fvt_rec.value_column_name;
       p_type_out    := 4;
   END IF ;

 EXCEPTION
     WHEN others THEN
     p_select_col :=  NULL;
     p_where_col  :=  NULL;
     p_type_out   := 1;
END get_table_vset_return_col;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| segment_qualifier_is_enabled                                          |
|                                                                       |
| Returns true if the segment qualifer is enabled for the coa specified |
|                                                                       |
+======================================================================*/
FUNCTION  segment_qualifier_is_enabled
  (p_application_id                  IN  INTEGER
  ,p_flex_code                       IN  VARCHAR2
  ,p_chart_of_accounts_id            IN  INTEGER
  ,p_flexfield_segment_code          IN  VARCHAR2)

RETURN BOOLEAN
IS

   l_return BOOLEAN;
   l_exist  VARCHAR2(1);

CURSOR c_qualifier
IS
SELECT 'x'
FROM   fnd_segment_attribute_values
WHERE  application_id          = p_application_id
  AND  id_flex_code            = p_flex_code
  AND  id_flex_num             = p_chart_of_accounts_id
  AND  segment_attribute_type  = p_flexfield_segment_code
  AND  attribute_value         = 'Y'
;

BEGIN

xla_utility_pkg.trace('> xla_flex_pkg.segment_qualifier_is_enabled'             , 20);

xla_utility_pkg.trace('Application id              = '||p_application_id         , 40);
xla_utility_pkg.trace('Flex code                   = '||p_flex_code              , 40);
xla_utility_pkg.trace('Chart of accounts id        = '||p_chart_of_accounts_id   , 40);
xla_utility_pkg.trace('Flexfield segment code      = '||p_flexfield_segment_code , 40);

IF p_flexfield_segment_code in ('GL_BALANCING','GL_ACCOUNT','GL_INTERCOMPANY',
                                'GL_MANAGEMENT','FA_COST_CTR') THEN
   OPEN c_qualifier;
   FETCH c_qualifier
   INTO l_exist;
   IF c_qualifier%found THEN
      l_return := TRUE;
   ELSE
      l_return := FALSE;
   END IF;
   CLOSE c_qualifier;
ELSE
   l_return := TRUE;
END IF;

xla_utility_pkg.trace('< xla_flex_pkg.segment_qualifier_is_enabled'             , 20);

RETURN l_return;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   IF c_qualifier%ISOPEN THEN
      CLOSE c_qualifier;
   END IF;
   RAISE;
WHEN OTHERS                                   THEN
   IF c_qualifier%ISOPEN THEN
      CLOSE c_qualifier;
   END IF;
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_flex_pkg.segment_qualifier_is_enabled');
END segment_qualifier_is_enabled;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| id_column_is_null                                                     |
|                                                                       |
| Returns true if the id column is null                                 |
|                                                                       |
+======================================================================*/
FUNCTION  id_column_is_null
  (p_flex_value_set_id               IN  INTEGER)
RETURN BOOLEAN
IS

   l_id_column_name   varchar2(240);
   l_return           boolean;

BEGIN
xla_utility_pkg.trace('> xla_flex_pkg.id_column_is_null'                , 20);

xla_utility_pkg.trace('Flex_value_set_id              = '||p_flex_value_set_id  , 40);

   SELECT id_column_name
     INTO l_id_column_name
     FROM fnd_flex_validation_tables
    WHERE flex_value_set_id = p_flex_value_set_id;

   IF l_id_column_name is null THEN
      l_return := TRUE;
   ELSE
      l_return := FALSE;
   END IF;

xla_utility_pkg.trace('< xla_flex_pkg.id_column_is_null'                 , 20);

RETURN l_return;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_flex_pkg.id_column_is_null');
END id_column_is_null;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| meaning_column_is_null                                                |
|                                                                       |
| Returns true if the meaning column is null                            |
|                                                                       |
+======================================================================*/
FUNCTION  meaning_column_is_null
  (p_flex_value_set_id               IN  INTEGER)
RETURN BOOLEAN
IS

   l_meaning_column_name   varchar2(240);
   l_return           boolean;

BEGIN
xla_utility_pkg.trace('> xla_flex_pkg.meaning_column_is_null'                , 20);

xla_utility_pkg.trace('Flex_value_set_id              = '||p_flex_value_set_id  , 40);

   SELECT meaning_column_name
     INTO l_meaning_column_name
     FROM fnd_flex_validation_tables
    WHERE flex_value_set_id = p_flex_value_set_id;

   IF l_meaning_column_name is null THEN
      l_return := TRUE;
   ELSE
      l_return := FALSE;
   END IF;

xla_utility_pkg.trace('< xla_flex_pkg.meaning_column_is_null'                 , 20);

RETURN l_return;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_flex_pkg.meaning_column_is_null');
END meaning_column_is_null;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| chk_additional_where_clause                                           |
|                                                                       |
| Returns true if the additional where caluse does not have $FLEX$      |
|                                                                       |
+======================================================================*/
FUNCTION  chk_additional_where_clause
  (p_flex_value_set_id               IN  INTEGER)
RETURN VARCHAR2
IS

   l_additional_where_clause   varchar2(4000);
   l_return                   varchar2(30);

BEGIN
xla_utility_pkg.trace('> xla_flex_pkg.chk_additional_where_clause'                , 20);

xla_utility_pkg.trace('Flex_value_set_id              = '||p_flex_value_set_id  , 40);

   BEGIN
      SELECT additional_where_clause
        INTO l_additional_where_clause
        FROM fnd_flex_validation_tables
       WHERE flex_value_set_id = p_flex_value_set_id;

      IF l_additional_where_clause is not null THEN

         IF instr(l_additional_where_clause, '$FLEX$',1,1) > 0 THEN
            l_return := 'FALSE';
         ELSE
            l_return := 'TRUE';
         END IF;
      ELSE
         l_return := 'TRUE';
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         l_return := 'TRUE';
      WHEN VALUE_ERROR THEN
         l_return := 'FALSE';
   END;

xla_utility_pkg.trace('< xla_flex_pkg.chk_additional_where_clause'                 , 20);

RETURN l_return;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   RAISE;
WHEN OTHERS                                   THEN
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_flex_pkg.chk_additional_where_clause');
END chk_additional_where_clause;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_qualifier_segment                                                 |
|                                                                       |
| Returns the segment for the qualifier specified                       |
|                                                                       |
+======================================================================*/
FUNCTION  get_qualifier_segment
  (p_application_id                  IN     INTEGER
  ,p_id_flex_code                    IN     VARCHAR2
  ,p_id_flex_num                     IN     INTEGER
  ,p_qualifier_segment               IN     VARCHAR2)
RETURN VARCHAR2
IS

   l_application_column_name  VARCHAR2(30);

CURSOR c_segment
IS
SELECT application_column_name
FROM   fnd_segment_attribute_values
WHERE  application_id          = p_application_id
  AND  id_flex_code            = p_id_flex_code
  AND  id_flex_num             = p_id_flex_num
  AND  segment_attribute_type  = p_qualifier_segment
  AND  attribute_value         = 'Y'
;

BEGIN

xla_utility_pkg.trace('> xla_flex_pkg.get_qualifier_segment'             , 20);

xla_utility_pkg.trace('Application id              = '||p_application_id         , 40);
xla_utility_pkg.trace('Flex code                   = '||p_id_flex_code             , 40);
xla_utility_pkg.trace('Chart of accounts id        = '||p_id_flex_num   , 40);
xla_utility_pkg.trace('Flexfield segment code      = '||p_qualifier_segment , 40);

   OPEN c_segment;
   FETCH c_segment
   INTO l_application_column_name;
   CLOSE c_segment;

xla_utility_pkg.trace('< xla_flex_pkg.get_qualifier_segment'             , 20);

RETURN l_application_column_name;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   IF c_segment%ISOPEN THEN
      CLOSE c_segment;
   END IF;
   RAISE;
WHEN OTHERS                                   THEN
   IF c_segment%ISOPEN THEN
      CLOSE c_segment;
   END IF;
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_flex_pkg.get_qualifier_segment');
END get_qualifier_segment;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_segment_qualifier                                                 |
|                                                                       |
| Returns the qualifier for the segment specified                       |
|                                                                       |
+======================================================================*/
FUNCTION  get_segment_qualifier
  (p_application_id                  IN     INTEGER
  ,p_id_flex_code                    IN     VARCHAR2
  ,p_id_flex_num                     IN     INTEGER
  ,p_segment_code                    IN     VARCHAR2)
RETURN VARCHAR2
IS

   l_segment_attribute_type  VARCHAR2(30);

CURSOR c_qualifier
IS
SELECT segment_attribute_type
FROM   fnd_segment_attribute_values
WHERE  application_id          = p_application_id
  AND  id_flex_code            = p_id_flex_code
  AND  id_flex_num             = p_id_flex_num
  AND  application_column_name = p_segment_code
  AND  attribute_value         = 'Y'
;

BEGIN

xla_utility_pkg.trace('> xla_flex_pkg.get_segment_qualifier'             , 20);

xla_utility_pkg.trace('Application id              = '||p_application_id         , 40);
xla_utility_pkg.trace('Flex code                   = '||p_id_flex_code             , 40);
xla_utility_pkg.trace('Structure id                = '||p_id_flex_num   , 40);
xla_utility_pkg.trace('Flexfield segment code      = '||p_segment_code , 40);

   OPEN c_qualifier;
   FETCH c_qualifier
   INTO l_segment_attribute_type;
   CLOSE c_qualifier;

xla_utility_pkg.trace('< xla_flex_pkg.get_segment_qualifier'             , 20);

   IF l_segment_attribute_type = null THEN
      l_segment_attribute_type := 'X';
   END IF;

RETURN l_segment_attribute_type;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   IF c_qualifier%ISOPEN THEN
      CLOSE c_qualifier;
   END IF;
   RAISE;
WHEN OTHERS                                   THEN
   IF c_qualifier%ISOPEN THEN
      CLOSE c_qualifier;
   END IF;
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_flex_pkg.get_segment_qualifier');
END get_segment_qualifier;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_segment_valueset                                                  |
|                                                                       |
| Returns the valuset for the segment specified                         |
|                                                                       |
+======================================================================*/
FUNCTION  get_segment_valueset
  (p_application_id                  IN     INTEGER
  ,p_id_flex_code                    IN     VARCHAR2
  ,p_id_flex_num                     IN     INTEGER
  ,p_segment_code                    IN     VARCHAR2)
RETURN NUMBER
IS

   l_flex_value_set_id    NUMBER(15);

CURSOR c_valueset
IS
SELECT flex_value_set_id
FROM   fnd_id_flex_segments
WHERE  application_id          = p_application_id
  AND  id_flex_code            = p_id_flex_code
  AND  id_flex_num             = p_id_flex_num
  AND  application_column_name = p_segment_code
;

BEGIN

xla_utility_pkg.trace('> xla_flex_pkg.get_segment_valueset'             , 20);

xla_utility_pkg.trace('Application id              = '||p_application_id         , 40);
xla_utility_pkg.trace('Flex code                   = '||p_id_flex_code            , 40);
xla_utility_pkg.trace('Structure id                = '||p_id_flex_num   , 40);
xla_utility_pkg.trace('Flexfield segment code      = '||p_segment_code , 40);

   OPEN c_valueset;
   FETCH c_valueset
   INTO l_flex_value_set_id;
   CLOSE c_valueset;

xla_utility_pkg.trace('< xla_flex_pkg.get_segment_valueset'             , 20);

   IF l_flex_value_set_id = null THEN
      l_flex_value_set_id := -99;
   END IF;

RETURN l_flex_value_set_id;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   IF c_valueset%ISOPEN THEN
      CLOSE c_valueset;
   END IF;
   RAISE;
WHEN OTHERS                                   THEN
   IF c_valueset%ISOPEN THEN
      CLOSE c_valueset;
   END IF;
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_flex_pkg.get_segment_valueset');
END get_segment_valueset;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_qualifier_name                                                    |
|                                                                       |
| Returns the name for the flexfield qualifier                          |
|                                                                       |
+======================================================================*/
FUNCTION  get_qualifier_name
  (p_application_id                  IN     INTEGER
  ,p_id_flex_code                    IN     VARCHAR2
  ,p_qualifier_segment               IN     VARCHAR2)
RETURN VARCHAR2
IS
   l_segment_prompt  VARCHAR2(80);

CURSOR c_segment
IS
SELECT segment_prompt
FROM   fnd_segment_attribute_types
WHERE  application_id          = p_application_id
  AND  id_flex_code            = p_id_flex_code
  AND  segment_attribute_type  = p_qualifier_segment;

BEGIN

xla_utility_pkg.trace('> xla_flex_pkg.get_qualifier_name'             , 20);

xla_utility_pkg.trace('Application id              = '||p_application_id         , 40);
xla_utility_pkg.trace('Flex code                   = '||p_id_flex_code            , 40);
xla_utility_pkg.trace('Flexfield segment code      = '||p_qualifier_segment , 40);

   OPEN c_segment;
   FETCH c_segment
   INTO l_segment_prompt;
   CLOSE c_segment;

xla_utility_pkg.trace('< xla_flex_pkg.get_qualifier_name'             , 20);

RETURN l_segment_prompt;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   IF c_segment%ISOPEN THEN
      CLOSE c_segment;
   END IF;
   RAISE;
WHEN OTHERS                                   THEN
   IF c_segment%ISOPEN THEN
      CLOSE c_segment;
   END IF;
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_flex_pkg.get_qualifier_name');
END get_qualifier_name;

/*======================================================================+
|                                                                       |
| Public Function                                                       |
|                                                                       |
| get_flexfield_structure                                               |
|                                                                       |
| Returns the flexfield structure for the key flexfields that support   |
| single structure                                                      |
|                                                                       |
+======================================================================*/
FUNCTION  get_flexfield_structure
  (p_application_id                  IN     INTEGER
  ,p_id_flex_code                    IN     VARCHAR2)
RETURN NUMBER
IS
   l_id_flex_num  NUMBER(15);

CURSOR c_struc
IS
SELECT id_flex_num
FROM   fnd_id_flex_structures_vl
WHERE  application_id          = p_application_id
  AND  id_flex_code            = p_id_flex_code;

BEGIN

xla_utility_pkg.trace('> xla_flex_pkg.get_flexfield_structure'             , 20);

xla_utility_pkg.trace('Application id              = '||p_application_id         , 40);
xla_utility_pkg.trace('Flex code                   = '||p_id_flex_code            , 40);

   OPEN c_struc;
   FETCH c_struc
   INTO l_id_flex_num;
   CLOSE c_struc;

xla_utility_pkg.trace('< xla_flex_pkg.get_flexfield_structure'             , 20);

RETURN l_id_flex_num;

EXCEPTION
WHEN xla_exceptions_pkg.application_exception THEN
   IF c_struc%ISOPEN THEN
      CLOSE c_struc;
   END IF;
   RAISE;
WHEN OTHERS                                   THEN
   IF c_struc%ISOPEN THEN
      CLOSE c_struc;
   END IF;
   xla_exceptions_pkg.raise_message
      (p_location   => 'xla_flex_pkg.get_flexfield_structure');
END get_flexfield_structure;

END xla_flex_pkg;

/
