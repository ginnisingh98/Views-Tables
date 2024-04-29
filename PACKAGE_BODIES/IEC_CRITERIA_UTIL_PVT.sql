--------------------------------------------------------
--  DDL for Package Body IEC_CRITERIA_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_CRITERIA_UTIL_PVT" AS
/* $Header: IECCRUTB.pls 115.4 2004/05/18 19:38:07 minwang noship $ */

g_pkg_name CONSTANT VARCHAR2(30) := 'IEC_CRITERIA_UTIL_PVT';

TYPE RULE_CRITERIA IS RECORD ( OWNER_ID IEC_G_RULES.OWNER_ID%TYPE
                             , RULE_ID IEC_G_RULES.RULE_ID%TYPE
                             , CRITERIA_ID IEC_G_FIELD_CRITERIA.CRITERIA_ID%TYPE
                             , CRITERIA_COMB_CODE IEC_G_FIELD_CRITERIA.COMBINATION_CODE%TYPE
                             , FIELD_NAME IEC_G_FIELDS.FIELD_NAME%TYPE
                             , FIELD_VALUE IEC_G_FIELDS.FIELD_VALUE%TYPE
                             , FIELD_OP_CODE IEC_G_FIELDS.OPERATOR_CODE%TYPE
                             , FIELD_OPERATOR IEC_O_ALG_OP_DEFS_B.SQL_OPERATOR%TYPE
                             , UNARY_FLAG IEC_O_ALG_OP_DEFS_B.IS_UNARY_FLAG%TYPE
                             , FIELD_DATATYPE USER_TAB_COLUMNS.DATA_TYPE%TYPE
                             );

TYPE BIND_VARIABLE IS RECORD ( NAME         VARCHAR2(30)
                             , DATA_TYPE    NUMBER
                             , DATE_VALUE   DATE
                             , NUMBER_VALUE NUMBER
                             , STRING_VALUE VARCHAR2(500));

TYPE BindVariableCollection IS TABLE OF BIND_VARIABLE INDEX BY BINARY_INTEGER;
TYPE ruleCriteriaCollection IS TABLE OF RULE_CRITERIA INDEX BY BINARY_INTEGER;

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : Get_Criteria
--  Type        : Private
--  Pre-reqs    : None
--  Function    : Procedure will append the criteria currently
--                present in the IEC_G_RULES, IEC_G_FIELD_CRITERIA,
--                and IEC_G_FIELDS tables for the specified owner_id,
--                and owner_type_code to the ruleCriteriaCollection
--                x_criteria_collection.  The owner is either a
--                subset or record filter.
--
--  Parameters  : p_source_id            IN     NUMBER                       Required
--                p_owner_id             IN     NUMBER                       Required
--                p_owner_type_code      IN     VARCHAR2                     Required
--                p_view_name            IN     VARCHAR2                     Required
--                x_criteria_collection  IN OUT ruleCriteriaCollection       Required
--                x_return_code             OUT VARCHAR2                     Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE Get_Criteria
   ( p_source_id           IN            NUMBER
   , p_owner_id            IN            NUMBER
   , p_owner_type_code     IN            VARCHAR2
   , p_view_name           IN            VARCHAR2
   , x_criteria_collection IN OUT NOCOPY ruleCriteriaCollection
   , x_return_code            OUT NOCOPY VARCHAR2
   )
IS

  l_status_code VARCHAR2(1);
  l_index       NUMBER;
  L_FIELD_TYPE  USER_TAB_COLUMNS.DATA_TYPE%TYPE;

BEGIN
  l_status_code := FND_API.G_RET_STS_SUCCESS;

  ----------------------------------------------------------------
  -- Set a save point that can be rolled back to for this procedure.
  ----------------------------------------------------------------
  SAVEPOINT GET_CRITERIA_SP;

  X_RETURN_CODE := FND_API.G_RET_STS_SUCCESS;

  ----------------------------------------------------------------
  -- Retrieve all of the rules that have been defined for this
  -- entity from the IEC_G_RULES table.
  ----------------------------------------------------------------
  FOR rule_rec IN (SELECT RULE_ID
                   FROM   IEC_G_RULES
                   WHERE  OWNER_ID = p_owner_id
                   AND    OWNER_TYPE_CODE = p_owner_type_code)
  LOOP

    ----------------------------------------------------------------
    -- Retrieve all of the field criteria that have been defined for
    -- the current rule from the IEC_G_FIELD_CRITERIA table.  The
    -- combination code is also retrieved, this is either an AND
    -- or an OR value that is used when creating the entity's
    -- contribution to the dynamic SQL where clause.
    ----------------------------------------------------------------
    FOR criteria_rec IN (SELECT CRITERIA_ID
                         ,      COMBINATION_CODE
                         FROM   IEC_G_FIELD_CRITERIA
                         WHERE  RULE_ID = rule_rec.RULE_ID)
    LOOP

      ----------------------------------------------------------------
      -- Retrieve all of the fields that have been defined for
      -- the current field criterion from the IEC_G_FIELDS table.  The
      -- columns retrieved are used when creating the entity's
      -- contribution to the dynamic SQL where clause.
      ----------------------------------------------------------------
      FOR field_rec IN (SELECT A.FIELD_NAME FIELD_NAME
                        ,      A.FIELD_VALUE FIELD_VALUE
                        ,      A.OPERATOR_CODE OPERATOR_CODE
                        ,      B.SQL_OPERATOR SQL_OPERATOR
                        ,      B.IS_UNARY_FLAG IS_UNARY_FLAG
                        FROM   IEC_G_FIELDS A
                        ,      IEC_O_ALG_OP_DEFS_B B
                        WHERE  A.CRITERIA_ID = criteria_rec.CRITERIA_ID
                        AND    A.OPERATOR_CODE = B.OPERATOR_CODE)
      LOOP

        ----------------------------------------------------------------
        -- We need to get the data type for the view column used in
        -- order to handle it correctly when we create the dynamic SQL.
        ----------------------------------------------------------------
        BEGIN
          SELECT DATA_TYPE
          INTO   L_FIELD_TYPE
          FROM   USER_TAB_COLUMNS
          WHERE  TABLE_NAME = P_VIEW_NAME
          AND    COLUMN_NAME = field_rec.FIELD_NAME;
        EXCEPTION
          ----------------------------------------------------------------
          -- There isn't a column in the specified view, or the view
          -- doesn't exist.  We probably should invalidate the entity
          -- at this point, but for now we just skip this column and try
          -- to continue.
          ----------------------------------------------------------------
          WHEN NO_DATA_FOUND THEN
            EXIT;

          WHEN OTHERS THEN
            RAISE;

        END;

        ----------------------------------------------------------------
        -- Store all of the relevant information that will be needed to
        -- build the entity's criteria portion of the dynamic SQL statement.
        ----------------------------------------------------------------
        l_index := x_criteria_collection.COUNT + 1;
        x_criteria_collection(l_index).OWNER_ID :=  p_owner_id;
        x_criteria_collection(l_index).RULE_ID :=  rule_rec.RULE_ID;
        x_criteria_collection(l_index).CRITERIA_ID :=  criteria_rec.CRITERIA_ID;
        x_criteria_collection(l_index).CRITERIA_COMB_CODE :=  criteria_rec.COMBINATION_CODE;
        x_criteria_collection(l_index).FIELD_NAME :=  field_rec.FIELD_NAME;
        x_criteria_collection(l_index).FIELD_VALUE :=  field_rec.FIELD_VALUE;
        x_criteria_collection(l_index).FIELD_OP_CODE :=  field_rec.OPERATOR_CODE;
        x_criteria_collection(l_index).FIELD_OPERATOR :=  field_rec.SQL_OPERATOR;
        x_criteria_collection(l_index).UNARY_FLAG :=  field_rec.IS_UNARY_FLAG;
        x_criteria_collection(l_index).FIELD_DATATYPE :=  L_FIELD_TYPE;

      END LOOP; -- end field loop


    END LOOP; -- end criteria loop


  END LOOP; -- end rule loop


EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO GET_CRITERIA_SP;
      X_RETURN_CODE := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE;

END Get_Criteria;

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : Get_CriteriaStrings
--  Type        : Private
--  Pre-reqs    : None
--  Function    : Parse the ruleCriteriaCollection to create a string
--                representation of the criteria (SQL) that will be
--                appended to x_criteria_strings.  This query, represented
--                as DBMS_SQL.VARCHAR2S can be executed via DBMS_SQL.
--
--  Parameters  : p_source_id            IN     NUMBER                       Required
--                p_criteria_collection  IN     ruleCriteriaCollection       Required
--                x_criteria_strings     IN OUT DBMS_SQL.VARCHAR2S           Required
--                x_return_code             OUT VARCHAR2                     Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE Get_CriteriaStrings
   ( p_source_id            IN            NUMBER
   , p_criteria_collection  IN            ruleCriteriaCollection
   , x_criteria_strings     IN OUT NOCOPY DBMS_SQL.VARCHAR2S
   , x_return_code             OUT NOCOPY VARCHAR2
   )
IS
  l_status_code VARCHAR2(1);
  l_index NUMBER;

  l_last_owner_id IEC_G_RULES.OWNER_ID%TYPE;
  l_last_rule_id IEC_G_RULES.RULE_ID%TYPE;
  l_last_criteria_id IEC_G_FIELD_CRITERIA.CRITERIA_ID%TYPE;

  l_first_field_flag BOOLEAN := TRUE;
  l_first_rule_flag BOOLEAN := TRUE;
  l_first_criteria_flag BOOLEAN := TRUE;

  l_curr_string VARCHAR2(2000);
  l_field_value_cln VARCHAR2(240);

BEGIN
  l_status_code := 'S';
  l_last_owner_id := -1;
  l_last_rule_id := -1;
  l_last_criteria_id := -1;
  ----------------------------------------------------------------
  -- Initialize the return code.
  ----------------------------------------------------------------
  X_RETURN_CODE := FND_API.G_RET_STS_SUCCESS;

  ----------------------------------------------------------------
  -- Create save point for this procedure.
  ----------------------------------------------------------------
  SAVEPOINT GET_CRITERIA_STRINGS_SP;

  ----------------------------------------------------------------
  -- If we have criteria then we need to build the string,
  -- otherwise we simply return with no additional criteria being
  -- added.
  ----------------------------------------------------------------
  IF p_criteria_collection.COUNT > 0
  THEN

    FOR i IN 1..p_criteria_collection.COUNT
    LOOP

      ----------------------------------------------------------------
      -- If this is the first criteria owner then we need a paranthesis to
      -- group all of the rules for this owner.
      ----------------------------------------------------------------
      IF l_last_owner_id = -1
      THEN
        l_curr_string := l_curr_string || ' (';

      ----------------------------------------------------------------
      -- This is a new set of rules for a new owner.
      ----------------------------------------------------------------
      ELSIF l_last_owner_id <> p_criteria_collection(i).OWNER_ID
      THEN
        l_curr_string := l_curr_string || '))) OR (';
        l_first_rule_flag := TRUE;
      END IF;

      ----------------------------------------------------------------
      -- Set the value of the last owner id for future iterations.
      ----------------------------------------------------------------
      l_last_owner_id := p_criteria_collection(i).OWNER_ID;

      ----------------------------------------------------------------
      -- If this is the first rule then we need a paranthesis to
      -- group all of the criteria for this rule.
      ----------------------------------------------------------------
      IF l_first_rule_flag = TRUE
      THEN
        l_curr_string := l_curr_string || ' (';
        l_first_rule_flag := FALSE;
        l_first_criteria_flag := TRUE;

      ----------------------------------------------------------------
      -- This is a new rule for the owner.
      ----------------------------------------------------------------
      ELSIF l_last_rule_id <> p_criteria_collection(i).RULE_ID
      THEN
        l_curr_string := l_curr_string || ')) OR (';
        l_first_criteria_flag := TRUE;
      END IF;

      ----------------------------------------------------------------
      -- Set the value of the last rule id for future iterations.
      ----------------------------------------------------------------
      l_last_rule_id := p_criteria_collection(i).RULE_ID;

      ----------------------------------------------------------------
      -- If this is the first criteria or a new criteria then add
      -- parenthesis for grouping of fields.
      ----------------------------------------------------------------
      IF (l_first_criteria_flag = TRUE)
      THEN
        l_curr_string := l_curr_string || ' (';
        l_first_field_flag := TRUE;
        l_first_criteria_flag := FALSE;

      ----------------------------------------------------------------
      -- This is a new criteria (not the first) for the rule.
      ----------------------------------------------------------------
      ELSIF l_last_criteria_id <> p_criteria_collection(i).CRITERIA_ID
      THEN
        l_curr_string := l_curr_string || ') AND (';
        l_first_field_flag := TRUE;
      END IF;

      ----------------------------------------------------------------
      -- Set the value of the last criteria id for future iterations.
      ----------------------------------------------------------------
      l_last_criteria_id := p_criteria_collection(i).CRITERIA_ID;

      ----------------------------------------------------------------
      -- If this is the first field.
      ----------------------------------------------------------------
      IF (l_first_field_flag = TRUE)
      THEN
        l_curr_string := l_curr_string || ' (';
        l_first_field_flag := FALSE;

      ----------------------------------------------------------------
      -- If this is not the first field then append the criteria
      -- combination code in front of the (.
      ----------------------------------------------------------------
      ELSE
        l_curr_string := l_curr_string ||
                         p_criteria_collection(i).CRITERIA_COMB_CODE ||
                         ' (';
      END IF;

      l_curr_string := l_curr_string || 'UPPER(' ||
                       p_criteria_collection(i).FIELD_NAME || ') ';

      ----------------------------------------------------------------
      -- Append the operator.
      ----------------------------------------------------------------
      l_curr_string := l_curr_string || p_criteria_collection(i).FIELD_OPERATOR;

      ----------------------------------------------------------------
      -- If the unary flag is set to 'N' then we have to append a
      -- value.
      ----------------------------------------------------------------
      IF p_criteria_collection(i).UNARY_FLAG = 'N'
      THEN

        ----------------------------------------------------------------
        -- If this is a VARCHAR2 field then put quotes around everything.
        ----------------------------------------------------------------
        IF (p_criteria_collection(i).FIELD_DATATYPE = 'VARCHAR2')
        THEN
          l_curr_string := l_curr_string || ' ''';

          -- Escape all quotes in field value to prevent sql injection
          l_field_value_cln := NULL;
          FOR j IN 1..LENGTH(p_criteria_collection(i).FIELD_VALUE) LOOP
             IF SUBSTR(p_criteria_collection(i).FIELD_VALUE, j, 1) = '''' THEN
                l_field_value_cln := l_field_value_cln || '''' || SUBSTR(p_criteria_collection(i).FIELD_VALUE, j, 1);
             ELSE
                l_field_value_cln := l_field_value_cln || SUBSTR(p_criteria_collection(i).FIELD_VALUE, j, 1);
             END IF;
          END LOOP;

          ----------------------------------------------------------------
          -- If the sql operator is like then we have to figure out where
          -- to place the wildcards.
          ----------------------------------------------------------------
          IF (p_criteria_collection(i).FIELD_OPERATOR = 'LIKE')
          THEN

            ----------------------------------------------------------------
            --  If the operation is "begins with" then place the
            --  wildcard at the beginning.
            ----------------------------------------------------------------
            IF (p_criteria_collection(i).FIELD_OP_CODE = 'BGWITH')
            THEN

              l_curr_string := l_curr_string || UPPER(l_field_value_cln) || '%';

            ----------------------------------------------------------------
            --  If the operation is "ends with" then place the
            --  wildcard at the end.
            ----------------------------------------------------------------
            ELSIF (p_criteria_collection(i).FIELD_OP_CODE = 'ENDWITH')
            THEN
              l_curr_string := l_curr_string || '%' || UPPER(l_field_value_cln);

            ----------------------------------------------------------------
            --  If the operation is "contains" then place the
            --  wildcard at the beginning and end.
            ----------------------------------------------------------------
            ELSIF (p_criteria_collection(i).FIELD_OP_CODE = 'CONTAINS')
            THEN
              l_curr_string := l_curr_string || '%' || UPPER(l_field_value_cln) || '%';

            ELSE
              ----------------------------------------------------------------
              -- This should throw an error.  Not sure if this should
              -- somehow signal to turn a subset off or not.
              ----------------------------------------------------------------
              NULL;
            END IF;

          ELSE
            l_curr_string := l_curr_string || UPPER(l_field_value_cln);
          END IF;

          l_curr_string := l_curr_string || ''' ';

        ----------------------------------------------------------------
        -- If this is not a VARCHAR2 field then don't worry about the
        -- uppercase.
        ----------------------------------------------------------------
        ELSE
          l_curr_string := l_curr_string || UPPER(p_criteria_collection(i).FIELD_VALUE);
        END IF;

      END IF;

      ----------------------------------------------------------------
      -- Close the grouping around this field.
      ----------------------------------------------------------------
      l_curr_string := l_curr_string || ') ';

      ----------------------------------------------------------------
      -- If this is the last entry then we need to close up the
      -- subset, rule, and criteria grouping.
      ----------------------------------------------------------------
      IF (i = p_criteria_collection.COUNT)
      THEN
        l_curr_string := l_curr_string || '))) ';
      END IF;

      l_index := x_criteria_strings.COUNT + 1;
      x_criteria_strings(l_index) := l_curr_string;
      l_curr_string := '';
    END LOOP;
  END IF;

EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO GET_CRITERIA_STRINGS_SP;
      X_RETURN_CODE := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE;

END Get_CriteriaStrings;

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : Append_RecFilterCriteriaClause
--  Type        : Private
--  Pre-reqs    : None
--  Function    : Append a SQL representation of the record filter criteria
--                to a collection of VARCHAR2s.  This query, represented
--                as DBMS_SQL.VARCHAR2S can be executed via DBMS_SQL.
--
--  Parameters  : p_source_id            IN     NUMBER                       Required
--                p_record_filter_id     IN     NUMBER                       Required
--                p_source_type_view     IN     VARCHAR2                     Required
--                x_criteria_sql         IN OUT DBMS_SQL.VARCHAR2S           Required
--                x_return_code             OUT VARCHAR2                     Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE Append_RecFilterCriteriaClause
   ( p_source_id            IN            NUMBER
   , p_record_filter_id     IN            NUMBER
   , p_source_type_view     IN            VARCHAR2
   , x_criteria_sql         IN OUT NOCOPY DBMS_SQL.VARCHAR2S
   , x_return_code             OUT NOCOPY VARCHAR2
   )
IS
  l_status_code VARCHAR2(1);
  l_criteria_collection ruleCriteriaCollection;

BEGIN
  l_status_code := 'S';
  ----------------------------------------------------------------
  -- Initialize the return code.
  ----------------------------------------------------------------
  X_RETURN_CODE := FND_API.G_RET_STS_SUCCESS;

  Get_Criteria(p_source_id, p_record_filter_id, 'RLC', p_source_type_view, l_criteria_collection, l_status_code);

  ----------------------------------------------------------------
  -- If rules where found for this record filter then continue
  -- otherwise stop processing and alert the calling procedure
  -- by returning a N.
  ----------------------------------------------------------------
  IF (l_criteria_collection.COUNT > 0)
  THEN
     Get_CriteriaStrings(p_source_id, l_criteria_collection, x_criteria_sql, l_status_code);
  ELSE
     X_RETURN_CODE := 'N';
  END IF;


EXCEPTION
    WHEN OTHERS THEN
      X_RETURN_CODE := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE;
END Append_RecFilterCriteriaClause;

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : Append_SubsetCriteriaClause
--  Type        : Private
--  Pre-reqs    : None
--  Function    : Append a SQL representation of the subset criteria
--                to a collection of VARCHAR2S.  This query, represented
--                as DBMS_SQL.VARCHAR2S can be executed via DBMS_SQL.
--
--  Parameters  : p_source_id            IN     NUMBER                       Required
--                p_record_filter_id     IN     NUMBER                       Required
--                p_source_type_view     IN     VARCHAR2                       Required
--                x_criteria_sql         IN OUT DBMS_SQL.VARCHAR2S           Required
--                x_return_code             OUT VARCHAR2                     Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE Append_SubsetCriteriaClause
   ( p_source_id            IN            NUMBER
   , p_subset_id            IN            NUMBER
   , p_source_type_view     IN            VARCHAR2
   , x_criteria_sql         IN OUT NOCOPY DBMS_SQL.VARCHAR2S
   , x_return_code             OUT NOCOPY VARCHAR2
   )
IS
  l_status_code VARCHAR2(1);
  l_criteria_collection ruleCriteriaCollection;

BEGIN
  l_status_code := 'S';
  ----------------------------------------------------------------
  -- Initialize the return code.
  ----------------------------------------------------------------
  X_RETURN_CODE := FND_API.G_RET_STS_SUCCESS;

  Get_Criteria(p_source_id, p_subset_id, 'SUBSET', p_source_type_view, l_criteria_collection, l_status_code);

  Get_CriteriaStrings(p_source_id, l_criteria_collection, x_criteria_sql, l_status_code);


EXCEPTION
    WHEN OTHERS THEN
      X_RETURN_CODE := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE;

END Append_SubsetCriteriaClause;

END IEC_CRITERIA_UTIL_PVT;

/
