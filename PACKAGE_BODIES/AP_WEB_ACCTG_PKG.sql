--------------------------------------------------------
--  DDL for Package Body AP_WEB_ACCTG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_ACCTG_PKG" AS
/* $Header: apwacctb.pls 120.14.12010000.7 2010/03/14 16:42:08 rveliche ship $ */

--Cache for FND_FLEX_APIS.GET_QUALIFIER_SEGNUM
gqs_cost_center_segnum t_cost_center_segnum_table;

PROCEDURE GetEmployeeCostCenter(
        p_employee_id                   IN NUMBER,
        p_emp_ccid                      IN NUMBER,
        p_cost_center                   OUT NOCOPY VARCHAR2) IS

  l_debug_info varchar2(200);

BEGIN

  --
  -- Call CustomDefaultCostCenter for cost center, otherwise retrieve
  -- cost center segment by deriving from employee ccid.
  --
   -----------------------------------------------------
   l_debug_info := 'AP_WEB_CUST_DFLEX_PKG.CustomDefaultCostCenter';
   -----------------------------------------------------
  p_cost_center := AP_WEB_CUST_DFLEX_PKG.CustomDefaultCostCenter(p_employee_id);

  if (p_cost_center is null) then
    p_cost_center := GetCostCenter(p_emp_ccid);
  end if;
END GetEmployeeCostCenter;

FUNCTION GetCostCenter(
        p_ccid                          IN NUMBER,
        p_chart_of_accounts_id          IN NUMBER)
RETURN VARCHAR2 IS

  l_debug_info varchar2(200);

  l_chart_of_accounts_id        number := p_chart_of_accounts_id;
  l_segments                    FND_FLEX_EXT.SEGMENTARRAY;
  l_num_of_segments             NUMBER;
  l_cost_ctr_seg_num            NUMBER;

BEGIN

  -- Only get the chart of accounts ID if none/null is passed in
  IF (l_chart_of_accounts_id IS NULL) THEN
    -----------------------------------------------------
    l_debug_info := 'AP_WEB_DB_AP_INT_PKG.GetCOAofSOB';
    -----------------------------------------------------
    IF (NOT AP_WEB_DB_AP_INT_PKG.GetCOAofSOB(l_chart_of_accounts_id)) THEN
      l_chart_of_accounts_id := NULL;
    END IF;
  END IF;

    -----------------------------------------------------
    l_debug_info := 'Retrieve segments from code combination id';
    -----------------------------------------------------
    IF (NOT FND_FLEX_EXT.GET_SEGMENTS('SQLGL',
                                      'GL#',
                                      l_chart_of_accounts_id,
                                      p_ccid,
                                      l_num_of_segments,
                                      l_segments)) THEN
      return NULL;
    END IF;

    -----------------------------------------------------
    l_debug_info := 'Get Cost Center segment number';
    -----------------------------------------------------
    BEGIN
      -- Check cache
      l_cost_ctr_seg_num := gqs_cost_center_segnum(l_chart_of_accounts_id);
    EXCEPTION
        -- Not found in cache, retrieve segment number
        WHEN NO_DATA_FOUND THEN
      IF (NOT FND_FLEX_APIS.GET_QUALIFIER_SEGNUM(
                                          101,
                                          'GL#',
                                          l_chart_of_accounts_id,
                                          'FA_COST_CTR',
                                          l_cost_ctr_seg_num)) THEN
        return NULL;
      END IF;

      -- Put segment number in cache for chart of accounts ID
      gqs_cost_center_segnum(l_chart_of_accounts_id) := l_cost_ctr_seg_num;
    END;
    -----------------------------------------------------
    l_debug_info := 'Get Cost Center segment';
    -----------------------------------------------------
    return l_segments(l_cost_ctr_seg_num);


EXCEPTION
 WHEN OTHERS THEN
   AP_WEB_DB_UTIL_PKG.RaiseException( 'GetCostCenter' );
   APP_EXCEPTION.RAISE_EXCEPTION;

END GetCostCenter;


PROCEDURE GetCostCenterApprovalRule(
        p_alphanumeric_allowed_flag     OUT NOCOPY      VARCHAR2,
        p_uppercase_only_flag           OUT NOCOPY      VARCHAR2,
        p_numeric_mode_enabled_flag     OUT NOCOPY      VARCHAR2,
        p_maximum_size                  OUT NOCOPY      NUMBER) IS

  l_debug_info varchar2(200);

l_chart_of_accounts_id      gl_sets_of_books.chart_of_accounts_id%type;
l_cost_center_seg_num       NUMBER;
l_appcol_name               fnd_id_flex_segments_vl.application_column_name%type;
l_seg_name                  fnd_id_flex_segments_vl.segment_name%type;
l_prompt                    fnd_id_flex_segments_vl.form_left_prompt%type;
l_value_set_name            fnd_flex_value_sets.flex_value_set_name%type;

BEGIN

    -----------------------------------------------------
    l_debug_info := 'AP_WEB_DB_AP_INT_PKG.GetCOAofSOB';
    -----------------------------------------------------
   IF (NOT AP_WEB_DB_AP_INT_PKG.GetCOAofSOB(l_chart_of_accounts_id)) THEN
        l_chart_of_accounts_id := NULL;
   END IF;

    -----------------------------------------------------
    l_debug_info := 'Get the segment number corresponding to the costcenter qualifier.';
    -----------------------------------------------------
   IF (NOT FND_FLEX_APIS.GET_QUALIFIER_SEGNUM(
                                101,
                                'GL#',
                                l_chart_of_accounts_id,
                                'FA_COST_CTR',
                                l_cost_center_seg_num)) then
     return;
   END IF;

    -----------------------------------------------------
    l_debug_info := 'Get the valueset associated with the Department (costcenter qualifier)';
    -----------------------------------------------------
   IF (NOT FND_FLEX_APIS.GET_SEGMENT_INFO(
                                101,
                                'GL#',
                                l_chart_of_accounts_id,
                                l_cost_center_seg_num,
                                l_appcol_name,
                                l_seg_name,
                                l_prompt,
                                l_value_set_name)) then
     return;
   END IF;

    -----------------------------------------------------
    l_debug_info := 'Get Cost Center Approval rules';
    -----------------------------------------------------
   select alphanumeric_allowed_flag, uppercase_only_flag, numeric_mode_enabled_flag, maximum_size
   into p_alphanumeric_allowed_flag, p_uppercase_only_flag ,p_numeric_mode_enabled_flag, p_maximum_size
   from fnd_flex_value_sets
   where flex_value_set_name like l_value_set_name;

EXCEPTION
 WHEN OTHERS THEN
   AP_WEB_DB_UTIL_PKG.RaiseException( 'GetCostCenterApprovalRule' );
   APP_EXCEPTION.RAISE_EXCEPTION;

END GetCostCenterApprovalRule;


/*Bug 2690715 : Declared a function to get the dependent segment
                of cost center segment.
*/
FUNCTION GetDependentSegment(
        p_value_set_name        IN     fnd_flex_value_sets.flex_value_set_name%type,
        p_chart_of_accounts_id  IN AP_WEB_DB_AP_INT_PKG.glsob_chartOfAccountsID,
        p_dependent_seg_num     OUT NOCOPY  NUMBER) RETURN BOOLEAN IS

        l_parent_flex_value_set_id fnd_flex_value_sets.parent_flex_value_set_id%type;

BEGIN

          select PARENT_FLEX_VALUE_SET_ID into l_parent_flex_value_set_id
          from fnd_flex_value_sets
          where flex_value_set_name like p_value_set_name
          and PARENT_FLEX_VALUE_SET_ID is not null;

        IF (l_parent_flex_value_set_id IS NOT NULL) THEN

          SELECT s.segment_num into p_dependent_seg_num
          FROM fnd_id_flex_segments s, fnd_segment_attribute_values sav,
          fnd_segment_attribute_types sat
            WHERE s.application_id = 101
            AND s.id_flex_code = 'GL#'
            AND s.id_flex_num = p_chart_of_accounts_id
            AND s.enabled_flag = 'Y'
            AND s.application_column_name = sav.application_column_name
            AND sav.application_id = 101
            AND sav.id_flex_code = 'GL#'
            AND sav.id_flex_num = p_chart_of_accounts_id
            AND sav.attribute_value = 'Y'
            AND sav.segment_attribute_type = sat.segment_attribute_type
            AND sat.application_id = 101
            AND sat.id_flex_code = 'GL#'
            AND sat.unique_flag = 'Y'
            AND s.FLEX_VALUE_SET_ID=l_parent_flex_value_set_id
            AND rownum =1;
   END IF;


        return TRUE;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return FALSE;
  WHEN OTHERS THEN
    AP_WEB_DB_UTIL_PKG.RaiseException('GetDependentSegment');
    APP_EXCEPTION.RAISE_EXCEPTION;
    return FALSE;
END GetDependentSegment;


PROCEDURE ValidateCostCenter(
        p_cost_center                   IN VARCHAR2,
        p_employee_id                   IN NUMBER,
        p_emp_set_of_books_id           IN NUMBER,
        p_default_emp_ccid              IN VARCHAR2,
        p_chart_of_accounts_id          IN NUMBER,
        p_cost_center_valid             OUT NOCOPY BOOLEAN) IS

  l_debug_info varchar2(200);

l_flex_segment_delimiter  varchar2(1);
l_cost_center_seg_num     number;
l_num_segments            number;
l_default_emp_segments    FND_FLEX_EXT.SEGMENTARRAY;
l_appcol_name               fnd_id_flex_segments_vl.application_column_name%type;
l_seg_name                  fnd_id_flex_segments_vl.segment_name%type;
l_prompt                    fnd_id_flex_segments_vl.form_left_prompt%type;
l_value_set_name            fnd_flex_value_sets.flex_value_set_name%type;
l_dependent_seg_num         number := 0;
l_concatenated_segments   varchar2(2000);

BEGIN

   -- Get the character used as the segment delimiter. This would be
   -- used to prepare the concatenated segment from segment array to a string.
    -----------------------------------------------------
    l_debug_info := 'Get segment delimiter';
    -----------------------------------------------------
   l_flex_segment_delimiter := FND_FLEX_EXT.GET_DELIMITER(
                                        'SQLGL',
                                        'GL#',
                                        p_chart_of_accounts_id);

   -- Get the segment number corresponding to the costcenter qualifier.
   -- This is used to overlay the costcenter segment
    -----------------------------------------------------
    l_debug_info := 'Get cost center segment number';
    -----------------------------------------------------
   if (NOT FND_FLEX_APIS.GET_QUALIFIER_SEGNUM(
                                101,
                                'GL#',
                                p_chart_of_accounts_id,
                                'FA_COST_CTR',
                                l_cost_center_seg_num)) then
        p_cost_center_valid := FALSE;
        return;
   end if;

   -- Get the segment array and number of segments for the employee
   -- code combination id.
    -----------------------------------------------------
    l_debug_info := 'Get employee default segments';
    -----------------------------------------------------
   if (NOT FND_FLEX_EXT.GET_SEGMENTS(
                                'SQLGL',
                                'GL#',
                                p_chart_of_accounts_id,
                                p_default_emp_ccid,
                                l_num_segments,
                                l_default_emp_segments)) then
        p_cost_center_valid := FALSE;
        return;
    end if;

    /*Bug 2690715 : Called function to get the dependent segment
                of cost center segment and then do the validation.
    */
    -----------------------------------------------------
    l_debug_info := 'FND_FLEX_APIS.GET_SEGMENT_INFO';
    -----------------------------------------------------
    IF (FND_FLEX_APIS.GET_SEGMENT_INFO(
                                    101,
                                    'GL#',
                                    p_chart_of_accounts_id,
                                    l_cost_center_seg_num,
                                    l_appcol_name,
                                    l_seg_name,
                                    l_prompt,
                                    l_value_set_name)) then

        -----------------------------------------------------
        l_debug_info := 'GetDependentSegment';
        -----------------------------------------------------
        IF (GetDependentSegment(l_value_set_name,
                            p_chart_of_accounts_id,
                            l_dependent_seg_num)) THEN
                NULL;
        END IF;

    END IF;

/*Bug 2690715 : Dont set the segment to NULL , if dependent valueset
                of cost center segment exists.
*/
   IF (l_dependent_seg_num IS NULL) THEN
    FOR i in 1 .. l_num_segments LOOP
       l_default_emp_segments(i) := '';
    END LOOP;
   END IF;

    -- Overlay the costcenter segment with the costcenter entered in the
    -- expense report
    -----------------------------------------------------
    l_debug_info := 'Overlay cost center segment with expense report cost center';
    -----------------------------------------------------
    l_default_emp_segments(l_cost_center_seg_num) := p_cost_center;

    -- Get the concatenated segments with all segments set to null, except the
    -- costcenter, Concatenates segments from segment array
    -- (l_default_emp_segments) to a string(l_concatenated_segments).
    -----------------------------------------------------
    l_debug_info := 'Concatenate segments';
    -----------------------------------------------------
    l_concatenated_segments :=  FND_FLEX_EXT.concatenate_segments(l_num_segments,
                                l_default_emp_segments,
                                l_flex_segment_delimiter);

    /* -----------------------------------------------------------------------+
    + Validate only the costcenter segment, since we are passing other        +
    + segments as null we need to set allow_nulls to true                     +
    + Allow_nulls will allow required segments that are NULL to be valid      +
    + allow_orphans will validate dependent segment values without associated +
    + parent values, allowing ANY possible dependent value, regardless        +
    + of what the parent value would be,  to be considered valid.             +
    +------------------------------------------------------------------------*/
/*Bug 2706584: Passed VRULE as a parameter to Validate_Segs so that
               it does not pass the cost center for which
               Posting Allowed is  Unchecked.
*/

/*Bug 2690715:Validate using only segment of COST CENTER if
              No Dependent Segment is present.Else validate
              using Combination,Flex Field does not support
              partial combination validation. i.e Like 01-520----
             can not be successfully validated.
*/
    -----------------------------------------------------
    l_debug_info := 'Validate segments';
    -----------------------------------------------------
IF (l_dependent_seg_num IS NULL) THEN
    if ( fnd_flex_keyval.validate_segs(operation=>'CHECK_SEGMENTS',
               appl_short_name=>'SQLGL',
               key_flex_code=>'GL#',
               structure_number=>p_chart_of_accounts_id,
               concat_segments=>l_concatenated_segments,
               VRULE=>'GL_GLOBAL\nDETAIL_POSTING_ALLOWED\nI\nNAME=AP_ALL_POSTING_NA\nY\0\nSUMMARY_FLAG\nI\nNAME=Flex-Parent not allowed\nN',
               allow_nulls=>TRUE,
               allow_orphans=>TRUE ) ) then
        p_cost_center_valid := TRUE;
        return;
    else
        p_cost_center_valid := FALSE;
        return;
    end if;
ELSE
    if ( fnd_flex_keyval.validate_segs(operation=>'CHECK_COMBINATION',
               appl_short_name=>'SQLGL',
               key_flex_code=>'GL#',
               structure_number=>p_chart_of_accounts_id,
               concat_segments=>l_concatenated_segments,
               VRULE=>'GL_GLOBAL\nDETAIL_POSTING_ALLOWED\nI\nNAME=AP_ALL_POSTING_NA\nY\0\nSUMMARY_FLAG\nI\nNAME=Flex-Parent not allowed\nN',
               allow_nulls=>TRUE,
               allow_orphans=>TRUE ) ) then
        p_cost_center_valid := TRUE;
        return;
    else
        p_cost_center_valid := FALSE;
        return;
    end if;
END IF;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
                p_cost_center_valid := FALSE;

        WHEN OTHERS THEN
                p_cost_center_valid := FALSE;

END ValidateCostCenter;


PROCEDURE GetExpenseTypeCostCenter(
        p_exp_type_parameter_id		IN NUMBER,
        p_cost_center			OUT NOCOPY VARCHAR2) IS

  l_debug_info varchar2(200);

l_chart_of_accounts_id    number;
l_flex_segment_delimiter  varchar2(1);
l_cost_center_seg_num     number;
l_num_segments            number;
l_exp_type_template_array       FND_FLEX_EXT.SEGMENTARRAY;
l_FlexConcactenated       AP_EXPENSE_REPORT_PARAMS.flex_concactenated%TYPE;

BEGIN

    -----------------------------------------------------
    l_debug_info := 'AP_WEB_DB_AP_INT_PKG.GetCOAofSOB';
    -----------------------------------------------------
   IF (NOT AP_WEB_DB_AP_INT_PKG.GetCOAofSOB(l_chart_of_accounts_id)) THEN
        l_chart_of_accounts_id := NULL;
   END IF;

   -- Get the character used as the segment delimiter. This would be
   -- used to prepare the concatenated segment from segment array to a string.
    -----------------------------------------------------
    l_debug_info := 'Get segment delimeter';
    -----------------------------------------------------
   l_flex_segment_delimiter := FND_FLEX_EXT.GET_DELIMITER(
                                        'SQLGL',
                                        'GL#',
                                        l_chart_of_accounts_id);

   -- Get the segment number corresponding to the costcenter qualifier.
   -- This is used to get the cost center for the expense type
    -----------------------------------------------------
    l_debug_info := 'Get segment number';
    -----------------------------------------------------
   if (NOT FND_FLEX_APIS.GET_QUALIFIER_SEGNUM(
                                101,
                                'GL#',
                                l_chart_of_accounts_id,
                                'FA_COST_CTR',
                                l_cost_center_seg_num)) then
        return;
   end if;

   begin
    -----------------------------------------------------
    l_debug_info := 'Get FLEX_CONCACTENATED';
    -----------------------------------------------------
     SELECT FLEX_CONCACTENATED into l_FlexConcactenated
     FROM   ap_expense_report_params_all
     WHERE parameter_id = p_exp_type_parameter_id;
   exception
     when others then
       return;
   end;

   /* Bug 4212250: Since l_FlexConcactenated is null, no need to
    *              proceed further.
    */
   IF l_FlexConcactenated IS NULL THEN
      return;
   END IF;

    -----------------------------------------------------
    l_debug_info := 'Break up segments';
    -----------------------------------------------------
   l_num_segments := FND_FLEX_EXT.Breakup_Segments(l_FlexConcactenated,
                                                    l_flex_segment_delimiter,
                                                    l_exp_type_template_array);

   IF nvl(l_num_segments,0) = 0 THEN
      return;
   ELSE
      IF (l_exp_type_template_array(l_cost_center_seg_num) IS NOT NULL) THEN
         p_cost_center := l_exp_type_template_array(l_cost_center_seg_num);
      ELSE
         return;
      END IF;
   END IF;

EXCEPTION
 WHEN OTHERS THEN
   AP_WEB_DB_UTIL_PKG.RaiseException( 'GetExpenseTypeCostCenter' );
   APP_EXCEPTION.RAISE_EXCEPTION;

END GetExpenseTypeCostCenter;


PROCEDURE GetCostCenterSegmentName(
        p_cost_center_segment_name      OUT NOCOPY VARCHAR2) IS

  l_debug_info varchar2(200);

  l_chart_of_accounts_id    number;

BEGIN

      /* This query will exclude terminated contingent
         workers and terminated employees who became
         contingent workers to avoid duplicate rows.
         Otherwise 2 rows for the same person could be
         possible. */
      -- Query up the Chart of Accounts Id for the Employee
      SELECT GS.chart_of_accounts_id
      INTO   l_chart_of_accounts_id
      FROM   ap_system_parameters S,
             gl_sets_of_books GS
      WHERE  GS.set_of_books_id = S.set_of_books_id
      AND    rownum = 1;
      -- Get the Column Name which implements the Cost Center Segment
      IF ( FND_FLEX_APIS.GET_SEGMENT_COLUMN(101,
                                            'GL#',
                                            l_chart_of_accounts_id,
                                            'FA_COST_CTR',
                                            p_cost_center_segment_name) )
      THEN
         RETURN;
      ELSE
         -- RAISE EXCEPTION THAT COST CTR IMPLEMENTATION COULD NOT BE FOUND!!!
         p_cost_center_segment_name := 'SEGMENT2';
         RETURN;
      END IF;

      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            -- RAISE EXCEPTION FOR INVALID CHART OF ACCOUNTS
            p_cost_center_segment_name := 'SEGMENT2';
            RETURN;
         WHEN OTHERS THEN
            -- RAISE SOME EXCEPTION
            p_cost_center_segment_name := 'SEGMENT2';
            RETURN;

END GetCostCenterSegmentName;


-------------------------------------------------------------------------
--
-- PROCEDURE GetDistributionSegments
--
-- Parameters
--        p_chart_of_accounts_id          Flexfield structure num
--        p_report_distribution_id        report_distribution_id
--        p_segments                      AP_OIE_KFF_SEGMENTS_T
--
-- Returns VARCHAR2
--   Returns the segment values array of the key flexfield
--
-- Description
--   There is no equivalent for this function. This function takes
--   the segment values stored in ap_exp_report_dists and returns
--   the segment values array according to the kff structure.
--
-- Modification History
--  ALING    30-SEP-04        Created.
--
-------------------------------------------------------------------------
PROCEDURE GetDistributionSegments(
        p_chart_of_accounts_id          IN    GL_SETS_OF_BOOKS.chart_of_accounts_id%TYPE,
        p_report_distribution_id        IN    NUMBER,
        p_segments                      OUT NOCOPY AP_OIE_KFF_SEGMENTS_T) IS
--------------------------------------------------------------------------------

  l_debug_info                  VARCHAR2(1000);
  sqlstmt                       varchar2(2000);
  colname                       fnd_id_flex_segments.application_column_name%type;
  c                             integer;
  l_concat_segments             VARCHAR2(1000);
  rows                          integer;
  l_num_segments                NUMBER;
  l_segment_array               FND_FLEX_EXT.SEGMENTARRAY;
  l_flex_segment_delimiter  varchar2(1);

cursor cflex(p_chart_accounts_id IN NUMBER) is
  SELECT flex.application_column_name
  FROM   fnd_id_flex_segments flex
  WHERE  flex.application_id = 101
  AND    flex.id_flex_code = 'GL#'
  AND    flex.id_flex_num = p_chart_accounts_id
  AND    flex.enabled_flag='Y'
  AND    flex.display_flag='Y'
  order by segment_num;

BEGIN

   -- Get the character used as the segment delimiter. This would be
   -- used to prepare the concatenated segment from segment array to a string.
    -----------------------------------------------------
    l_debug_info := 'Get segment delimiter';
    -----------------------------------------------------
   l_flex_segment_delimiter := FND_FLEX_EXT.GET_DELIMITER(
                                        'SQLGL',
                                        'GL#',
                                        p_chart_of_accounts_id);

  ------------------------------------------------------------
  l_debug_info := 'First build the select statment';
  ------------------------------------------------------------
  sqlstmt := null;
  if cflex%isopen then close cflex;
  end if;

  open cflex(p_chart_of_accounts_id);

    LOOP
      FETCH cflex INTO colname;
      EXIT WHEN cflex%NOTFOUND;

        IF sqlstmt IS NOT NULL THEN
          sqlstmt := sqlstmt || '||''' || l_flex_segment_delimiter || '''||' ||colname;
        ELSE
          sqlstmt := colname;
        END IF;

    END LOOP;

  sqlstmt := 'SELECT '||sqlstmt||' FROM AP_EXP_REPORT_DISTS
              WHERE report_distribution_id = :report_distribution_id';

  close cflex;

  -----------------
  -- Now execute it
  -----------------
  c := dbms_sql.open_cursor;
  -----------------------------------------------------
  l_debug_info := 'parse cursor';
  -----------------------------------------------------
  dbms_sql.parse(c, sqlstmt, dbms_sql.native);

  -----------------------------------------------------
  l_debug_info := 'bind values to the placeholder';
  -----------------------------------------------------
  dbms_sql.bind_variable(c, ':report_distribution_id', p_report_distribution_id);

  -----------------------------------------------------
  l_debug_info := 'setup output';
  -----------------------------------------------------
  dbms_sql.define_column(c, 1, l_concat_segments, 1000);

  -----------------------------------------------------
  l_debug_info := 'execute cursor';
  -----------------------------------------------------
  rows := dbms_sql.execute(c);

  -----------------------------------------------------
  l_debug_info := 'fetch a row';
  -----------------------------------------------------
  IF dbms_sql.fetch_rows(c) > 0 then
    -- fetch columns from the row
    dbms_sql.column_value(c, 1, l_concat_segments);
  END IF;

  dbms_sql.column_value(c, 1, l_concat_segments);

  dbms_sql.close_cursor(c);


  IF cflex%isopen THEN
     CLOSE cflex;
  END IF;

  --------------------------------------------------------------
  l_debug_info:='Break Up Segments';
  --------------------------------------------------------------
  l_num_segments := FND_FLEX_EXT.Breakup_Segments(l_concat_segments,
                                                  l_flex_segment_delimiter,
                                                  l_segment_array);


  -----------------------------------------------------
  l_debug_info := 'Assign values to p_segments';
  -----------------------------------------------------
  p_segments := AP_OIE_KFF_SEGMENTS_T('');
  p_segments.extend(l_segment_array.count);
  FOR i IN 1..l_segment_array.count LOOP
        p_segments(i) := l_segment_array(i);
  END LOOP;


EXCEPTION
  WHEN OTHERS THEN
    IF cflex%isopen THEN
      close cflex;
    END IF;
    IF dbms_sql.is_open(c) THEN
      dbms_sql.close_cursor(c);
    END IF;

    IF (SQLCODE <> -20001) THEN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', 'GetDistributionSegments');
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
    END IF;
    APP_EXCEPTION.RAISE_EXCEPTION;
END GetDistributionSegments;


PROCEDURE GetConcatenatedSegments(
        p_chart_of_accounts_id          IN NUMBER,
        p_segments                      IN AP_OIE_KFF_SEGMENTS_T,
        p_concatenated_segments         OUT NOCOPY VARCHAR2) IS

  l_debug_info                  VARCHAR2(100);

  l_flex_segment_delimiter      VARCHAR2(1);
  l_segments                    FND_FLEX_EXT.SEGMENTARRAY;

BEGIN

  IF (p_chart_of_accounts_id is null) THEN
    FND_MESSAGE.Set_Name('SQLAP', 'OIE_MISS_CHART_OF_ACC_ID');
    RAISE AP_WEB_OA_MAINFLOW_PKG.G_EXC_ERROR;
  END IF;

  ----------------------------------------
  l_debug_info := 'Get Segment Delimiter like .';
  ----------------------------------------
  l_flex_segment_delimiter := FND_FLEX_EXT.GET_DELIMITER(
                                        'SQLGL',
                                        'GL#',
                                        p_chart_of_accounts_id);

  IF (l_flex_segment_delimiter IS NULL) THEN
    RAISE AP_WEB_OA_MAINFLOW_PKG.G_EXC_ERROR;
  END IF; /* l_flex_segment_delimiter IS NULL */

  ------------------------------------------------------------------------
  l_debug_info := 'Convert AP_OIE_KFF_SEGMENTS_T to FND_FLEX_EXT.SEGMENTARRAY';
  ------------------------------------------------------------------------
  FOR i IN 1..p_segments.count LOOP
        l_segments(i) := p_segments(i);
  END LOOP;

  ------------------------------------------------------------------------
  l_debug_info := 'calling FND_FLEX_EXT.concatenate_segments';
  ------------------------------------------------------------------------
  p_concatenated_segments :=  FND_FLEX_EXT.concatenate_segments(l_segments.count,
                              l_segments,
                              l_flex_segment_delimiter);

EXCEPTION
 WHEN OTHERS THEN
   AP_WEB_DB_UTIL_PKG.RaiseException( 'GetConcatenatedSegments' );
   APP_EXCEPTION.RAISE_EXCEPTION;

END GetConcatenatedSegments;


PROCEDURE BuildAccount(
        p_report_header_id              IN NUMBER,
        p_report_line_id                IN NUMBER,
        p_employee_id                   IN NUMBER,
        p_cost_center                   IN VARCHAR2,
        p_line_cost_center              IN VARCHAR2,
        p_exp_type_parameter_id         IN NUMBER,
        p_segments                      IN AP_OIE_KFF_SEGMENTS_T,
        p_ccid                          IN NUMBER,
        p_build_mode                    IN VARCHAR2,
        p_new_segments                  OUT NOCOPY AP_OIE_KFF_SEGMENTS_T,
        p_new_ccid                      OUT NOCOPY NUMBER,
        p_return_error_message          OUT NOCOPY VARCHAR2) IS


  l_debug_info                  VARCHAR2(100);

  l_default_emp_ccid            AP_WEB_DB_EXPRPT_PKG.expHdr_employeeCCID;
  l_chart_of_accounts_id        NUMBER;
  l_cost_center_seg_num         NUMBER;
  l_flex_segment_delimiter      VARCHAR2(1);
  l_default_emp_segments        FND_FLEX_EXT.SEGMENTARRAY;
  l_FlexConcactenated           AP_EXPENSE_REPORT_PARAMS.FLEX_CONCACTENATED%TYPE;
  l_exp_type_template_array     FND_FLEX_EXT.SEGMENTARRAY;
  l_exp_line_acct_segs_array    FND_FLEX_EXT.SEGMENTARRAY;
  l_num_segments                NUMBER:=NULL;
  l_concatenated_segments   varchar2(2000);

BEGIN

  if (AP_WEB_CUS_ACCTG_PKG.BuildAccount(
        p_report_header_id => p_report_header_id,
        p_report_line_id => p_report_line_id,
        p_employee_id => p_employee_id,
        p_cost_center => p_cost_center,
        p_exp_type_parameter_id => p_exp_type_parameter_id,
        p_segments => p_segments,
        p_ccid => p_ccid,
        p_build_mode => p_build_mode,
        p_new_segments => p_new_segments,
        p_new_ccid => p_new_ccid,
        p_return_error_message => p_return_error_message)) then

    --------------------------------------------------------------------
    l_debug_info := 'Custom BuildAccount';
    --------------------------------------------------------------------

    return;

  end if;

  if (p_build_mode not in (C_DEFAULT, C_DEFAULT_VALIDATE, C_BUILD_VALIDATE, C_VALIDATE)) then

    --------------------------------------------------------------------
    l_debug_info := 'Invalid p_build_mode';
    --------------------------------------------------------------------

    return;

  end if;

  -- Bug: 9467530, Set AFF Validation to null to avoid Value not found in value set error.
  GL_GLOBAL.set_aff_validation('XX', null);

  -----------------------------------------------------
  l_debug_info := 'Get the HR defaulted Employee CCID';
  -----------------------------------------------------
  IF (NOT AP_WEB_DB_EXPRPT_PKG.GetDefaultEmpCCID(
         p_employee_id          => p_employee_id,
         p_default_emp_ccid     => l_default_emp_ccid)) THEN
      NULL;
  END IF;

  IF (l_default_emp_ccid is null) THEN
    FND_MESSAGE.Set_Name('SQLAP', 'AP_WEB_EXP_MISSING_EMP_CCID');
    RAISE AP_WEB_OA_MAINFLOW_PKG.G_EXC_ERROR;
  END IF;

  -----------------------------------------------------
  l_debug_info := 'Get the Employee Chart of Accounts ID';
  -----------------------------------------------------
  IF (NOT AP_WEB_DB_EXPRPT_PKG.GetChartOfAccountsID(
         p_employee_id          => p_employee_id,
         p_chart_of_accounts_id => l_chart_of_accounts_id)) THEN
      NULL;
  END IF;

  IF (l_chart_of_accounts_id is null) THEN
    FND_MESSAGE.Set_Name('SQLAP', 'OIE_MISS_CHART_OF_ACC_ID');
    RAISE AP_WEB_OA_MAINFLOW_PKG.G_EXC_ERROR;
  END IF;

  -----------------------------------------------------------------
  l_debug_info := 'Get employee default ccid account segments';
  -----------------------------------------------------------------
  IF (l_default_emp_ccid IS NOT NULL) THEN
    IF (NOT FND_FLEX_EXT.GET_SEGMENTS(
                                'SQLGL',
                                'GL#',
                                l_chart_of_accounts_id,
                                l_default_emp_ccid,
                                l_num_segments,
                                l_default_emp_segments)) THEN
      RAISE AP_WEB_OA_MAINFLOW_PKG.G_EXC_ERROR;
    END IF; /* GET_SEGMENTS */
  END IF;

  ----------------------------------------
  l_debug_info := 'Get Cost Center Segment Number';
  ----------------------------------------
  IF (NOT FND_FLEX_APIS.GET_QUALIFIER_SEGNUM(
                                101,
                                'GL#',
                                l_chart_of_accounts_id,
                                'FA_COST_CTR',
                                l_cost_center_seg_num)) THEN
    /* We could not find the cost center segment, but we can still overlay the
     * expense type mask, so do nothing */
    null;
  END IF;

  ----------------------------------------
  l_debug_info := 'Get Segment Delimiter like .';
  ----------------------------------------
  l_flex_segment_delimiter := FND_FLEX_EXT.GET_DELIMITER(
                                        'SQLGL',
                                        'GL#',
                                        l_chart_of_accounts_id);

  IF (l_flex_segment_delimiter IS NULL) THEN
    FND_MSG_PUB.Add;
    RAISE AP_WEB_OA_MAINFLOW_PKG.G_EXC_ERROR;
  END IF;


  ----------------------------------------
  l_debug_info := 'Check if p_ccid or p_segments is passed';
  ----------------------------------------
  if (p_ccid is not null) then

    ----------------------------------------
    l_debug_info := 'Convert p_ccid into a segment array';
    ----------------------------------------
    IF (NOT FND_FLEX_EXT.GET_SEGMENTS('SQLGL',
                                      'GL#',
                                      l_chart_of_accounts_id,
                                      p_ccid,
                                      l_num_segments,
                                      l_exp_line_acct_segs_array)) THEN
      return;
    END IF;

  elsif (p_segments is not null and p_segments.count > 0) then

    ----------------------------------------
    l_debug_info := 'Convert p_segments into a segment array';
    ----------------------------------------

    IF (l_num_segments IS NULL) THEN
      l_num_segments := p_segments.count;
    END IF;

    -----------------------------------------------------
    l_debug_info := 'Assign values to l_exp_line_acct_segs_array';
    -----------------------------------------------------
    FOR i IN 1..l_num_segments LOOP
          l_exp_line_acct_segs_array(i) := p_segments(i);
    END LOOP;

  end if /* p_ccid is not null or p_segments is not null */;


  if (p_exp_type_parameter_id is not null) then
    ------------------------------------------------------------------------
    l_debug_info := 'calling AP_WEB_DB_EXPRPT_PKG.GetFlexConcactenated';
    ------------------------------------------------------------------------
    IF (AP_WEB_DB_EXPRPT_PKG.GetFlexConcactenated(
               p_parameter_id => p_exp_type_parameter_id,
               p_FlexConcactenated => l_FlexConcactenated)) THEN

       IF l_FlexConcactenated is not null THEN

          --------------------------------------------------------------
          l_debug_info:='Break Up Segments';
          --------------------------------------------------------------
          l_num_segments := FND_FLEX_EXT.Breakup_Segments(l_FlexConcactenated,
                                                          l_flex_segment_delimiter,
                                                          l_exp_type_template_array);
       END IF;

    END IF;

  end if; /* p_exp_type_parameter_id is not null */


  --------------------------------------------------------------
  l_debug_info:='Check Build Account Mode';
  --------------------------------------------------------------
  if (p_build_mode in (C_DEFAULT, C_DEFAULT_VALIDATE, C_BUILD_VALIDATE)) then


     -- Overlay the incoming segment values with the segment values
     -- defined in expense type template IF the incoming segment value
     -- is NULL.

        FOR i IN 1..l_num_segments LOOP
          -- If the incoming segment is not null, then keep this value, do nothing.
          IF (p_segments IS NOT NULL AND
              p_segments.EXISTS(i) AND
              p_segments(i) IS NOT NULL) THEN

            NULL;

          ELSIF (l_exp_type_template_array is not null and
              l_exp_type_template_array.count > 0 and
              l_exp_type_template_array(i) IS NOT NULL) THEN

            l_exp_line_acct_segs_array(i) := l_exp_type_template_array(i);

          ELSE

          /* If cost center is not defined on the expense type mask, override it from line
           * or header, if defined, in that order.  */

            IF i = l_cost_center_seg_num AND p_line_cost_center is not null THEN
              l_exp_line_acct_segs_array(i) := p_line_cost_center;

            ELSIF i = l_cost_center_seg_num AND p_cost_center is not null THEN
              l_exp_line_acct_segs_array(i) := p_cost_center;

            ELSIF (p_build_mode in (C_DEFAULT, C_DEFAULT_VALIDATE)) THEN
              l_exp_line_acct_segs_array(i) := l_default_emp_segments(i);
            END IF;

          END IF; /* l_exp_type_template_array(i) IS NOT NULL */

        END LOOP; /* 1..l_num_segments */

  end if; /* p_build_mode in (C_DEFAULT, C_DEFAULT_VALIDATE, C_BUILD_VALIDATE) */


  --------------------------------------------------------------
  l_debug_info:='Check Build Account Mode';
  --------------------------------------------------------------
  if (p_build_mode in (C_DEFAULT_VALIDATE, C_BUILD_VALIDATE, C_VALIDATE)) then

      --------------------------------------------------------------
      l_debug_info:='Build Account Mode contains VALIDATE';
      --------------------------------------------------------------

      --------------------------------------------------------------
      l_debug_info := 'Retrieve new ccid';
      --------------------------------------------------------------
      -- Work around for bug 1569108
      l_concatenated_segments :=  FND_FLEX_EXT.concatenate_segments(l_num_segments,
                        l_exp_line_acct_segs_array,
                        l_flex_segment_delimiter);

      ------------------------------------------------------------------------
      l_debug_info := 'calling FND_FLEX_KEYVAL.validate_segs';
      ------------------------------------------------------------------------
      IF (FND_FLEX_KEYVAL.validate_segs('CREATE_COMBINATION',
                                        'SQLGL',
                                        'GL#',
                                        l_chart_of_accounts_id,
                                        l_concatenated_segments)) THEN

        p_new_ccid := FND_FLEX_KEYVAL.combination_id;

      ELSE

        p_return_error_message := FND_FLEX_KEYVAL.error_message;
        FND_MESSAGE.set_encoded(FND_FLEX_KEYVAL.encoded_error_message);
        fnd_msg_pub.add();

      END IF; /* FND_FLEX_KEYVAL.validate_segs */

  end if; /* p_build_mode in (C_DEFAULT_VALIDATE, C_BUILD_VALIDATE, C_VALIDATE) */

  -----------------------------------------------------
  l_debug_info := 'Assign values to p_new_segments';
  -----------------------------------------------------
  p_new_segments := AP_OIE_KFF_SEGMENTS_T('');
  p_new_segments.extend(l_num_segments);
  FOR i IN 1..l_num_segments LOOP
        p_new_segments(i) := l_exp_line_acct_segs_array(i);
  END LOOP;


EXCEPTION
 WHEN OTHERS THEN
   AP_WEB_DB_UTIL_PKG.RaiseException( 'BuildAccount' );
   APP_EXCEPTION.RAISE_EXCEPTION;

END BuildAccount;


PROCEDURE BuildDistProjectAccount(
        p_report_header_id              IN              NUMBER,
        p_report_line_id                IN              NUMBER,
        p_report_distribution_id        IN              NUMBER,
        p_exp_type_parameter_id         IN              NUMBER,
        p_new_segments                  OUT NOCOPY AP_OIE_KFF_SEGMENTS_T,
        p_new_ccid                      OUT NOCOPY      NUMBER,
        p_return_error_message          OUT NOCOPY      VARCHAR2,
        p_return_status                 OUT NOCOPY      VARCHAR2) IS

  CURSOR pa_cur IS
    SELECT
           aerh.employee_id,
           aerh.flex_concatenated header_cost_center,
           aerh.default_currency_code reimbursement_currency_code,
           aerh.week_end_date,
           aerh.attribute_category header_attribute_category,
           aerh.attribute1 header_attribute1,
           aerh.attribute2 header_attribute2,
           aerh.attribute3 header_attribute3,
           aerh.attribute4 header_attribute4,
           aerh.attribute5 header_attribute5,
           aerh.attribute6 header_attribute6,
           aerh.attribute7 header_attribute7,
           aerh.attribute8 header_attribute8,
           aerh.attribute9 header_attribute9,
           aerh.attribute10 header_attribute10,
           aerh.attribute11 header_attribute11,
           aerh.attribute12 header_attribute12,
           aerh.attribute13 header_attribute13,
           aerh.attribute14 header_attribute14,
           aerh.attribute15 header_attribute15,
           aerl.start_expense_date,
           dist.amount,
           aerl.credit_card_trx_id,
           aerl.expenditure_item_date,
           aerl.expenditure_type,
           aerl.pa_quantity,
           dist.expenditure_organization_id,
           aerl.adjustment_reason,
           aerl.category_code,
           aerl.attribute_category line_attribute_category,
           aerl.attribute1 line_attribute1,
           aerl.attribute2 line_attribute2,
           aerl.attribute3 line_attribute3,
           aerl.attribute4 line_attribute4,
           aerl.attribute5 line_attribute5,
           aerl.attribute6 line_attribute6,
           aerl.attribute7 line_attribute7,
           aerl.attribute8 line_attribute8,
           aerl.attribute9 line_attribute9,
           aerl.attribute10 line_attribute10,
           aerl.attribute11 line_attribute11,
           aerl.attribute12 line_attribute12,
           aerl.attribute13 line_attribute13,
           aerl.attribute14 line_attribute14,
           aerl.attribute15 line_attribute15,
           dist.cost_center line_flex_concat,
           aerl.ap_validation_error,
           dist.project_id,
           dist.task_id,
           dist.award_id,
           s.base_currency_code,
           s.default_exchange_rate_type,
           sob.chart_of_accounts_id,
           erp.pa_expenditure_type new_expenditure_type
    FROM   ap_expense_report_headers aerh,
           ap_expense_report_lines aerl,
           ap_exp_report_dists dist,
           ap_system_parameters s,
           fnd_currencies_vl c,
           gl_sets_of_books sob,
           ap_expense_report_params erp
    WHERE  c.currency_code = s.base_currency_code
    AND    sob.set_of_books_id = s.set_of_books_id
    AND    erp.parameter_id = p_exp_type_parameter_id
    AND    dist.report_distribution_id = p_report_distribution_id
    AND    dist.report_line_id = aerl.report_line_id
    AND    aerh.report_header_id = aerl.report_header_id;

  ln_default_exchange_rate      NUMBER;
  ln_acct_raw_cost              NUMBER;
  ln_vendor_id                  NUMBER;
  ln_award_set_id               NUMBER;
  lv_expense_report_cost_center AP_WEB_DB_EXPRPT_PKG.expHdr_flexConcat;
  lv_procedure_billable_flag    VARCHAR2(200);
  lv_msg_type                   VARCHAR2(2000);
  l_pa_CCID                     gl_code_combinations.code_combination_id%TYPE;
  lv_concat_segs                VARCHAR2(2000);
  lv_concat_ids                 VARCHAR2(2000);
  lv_concat_description         VARCHAR2(2000);
  l_segments                    FND_FLEX_EXT.SEGMENTARRAY;
  ln_segment_count              NUMBER := 0;
  lv_flex_segment_delimiter     VARCHAR2(1);
  lb_gms_accounting_created     BOOLEAN := false;

  pa_rec pa_cur%ROWTYPE;
  l_debug_info varchar2(200);
  l_default_emp_ccid       AP_WEB_DB_EXPRPT_PKG.expHdr_employeeCCID;
BEGIN

  IF    p_report_header_id is null
     OR p_report_line_id is null
     OR p_report_distribution_id is null
     OR p_exp_type_parameter_id is null THEN
    p_new_ccid := to_number(null);
    p_return_status := 'ERROR';
    RETURN;
  END IF;

  if (AP_WEB_CUS_ACCTG_PKG.BuildDistProjectAccount(
         p_report_header_id => p_report_header_id,
         p_report_line_id => p_report_line_id,
         p_report_distribution_id => p_report_distribution_id,
         p_exp_type_parameter_id => p_exp_type_parameter_id,
         p_new_segments => p_new_segments,
         p_new_ccid => p_new_ccid,
         p_return_error_message => p_return_error_message,
         p_return_status => p_return_status)) then

      --------------------------------------------------------------------
      l_debug_info := 'Custom BuildDistProjectAccount';
      --------------------------------------------------------------------

     return;

  end if;

  p_return_status := 'SUCCESS';

  OPEN pa_cur;
  FETCH pa_cur into pa_rec;
  IF pa_cur%NOTFOUND THEN
    CLOSE pa_cur;
    p_new_ccid := to_number(null);
    p_return_status := 'ERROR';
    RETURN;
  END IF;
  CLOSE pa_cur;

    -----------------------------------------------------
    l_debug_info := 'Get vendor ID if exists for this employee';
    -----------------------------------------------------
  IF (NOT AP_WEB_DB_AP_INT_PKG.GetVendorID(pa_rec.employee_id, ln_vendor_id)) THEN
      ln_vendor_id := NULL;
  END IF; /* GetVendorID */

  -- For PATC: Get the default exchange rate for the week_end_date reimbursement currency/functional currency
    -----------------------------------------------------
    l_debug_info := 'AP_UTILITIES_PKG.get_exchange_rate';
    -----------------------------------------------------
  ln_default_exchange_rate := AP_UTILITIES_PKG.get_exchange_rate(pa_rec.base_currency_code,
                                                                 pa_rec.reimbursement_currency_code,
                                                                 pa_rec.default_exchange_rate_type,
                                                                 pa_rec.week_end_date,
                                                                'ValidatePATransaction');

  -- Calculate the receipt amount in the functional currency
  ln_acct_raw_cost := NULL;
  IF ln_default_exchange_rate IS NOT NULL AND ln_default_exchange_rate <> 0 THEN
    ln_acct_raw_cost := AP_WEB_UTILITIES_PKG.OIE_ROUND_CURRENCY(pa_rec.amount/ln_default_exchange_rate, pa_rec.base_currency_code);
  END IF;

    -----------------------------------------------------
    l_debug_info := 'Call PATC to get billable flag value';
    -----------------------------------------------------
  AP_WEB_PROJECT_PKG.ValidatePATransaction(p_project_id         => pa_rec.project_id,
                                           p_task_id            => pa_rec.task_id,
                                           p_ei_date            => pa_rec.expenditure_item_date,
                                           p_expenditure_type   => pa_rec.new_expenditure_type,
                                           p_non_labor_resource => NULL,
                                           p_person_id          => pa_rec.employee_id,
                                           p_quantity           => NULL,
                                           p_denom_currency_code=> pa_rec.reimbursement_currency_code,
                                           p_acct_currency_code => pa_rec.base_currency_code,
                                           p_denom_raw_cost     => pa_rec.amount,
                                           p_acct_raw_cost      => ln_acct_raw_cost,
                                           p_acct_rate_type     => pa_rec.default_exchange_rate_type,
                                           p_acct_rate_date     => pa_rec.week_end_date,
                                           p_acct_exchange_rate => ln_default_exchange_rate,
                                           p_transfer_ei        => NULL,
                                           p_incurred_by_org_id => pa_rec.expenditure_organization_id,
                                           p_nl_resource_org_id => NULL,
                                           p_transaction_source => NULL,
                                           p_calling_module     => 'SelfService',
                                           p_vendor_id          => ln_vendor_id,
                                           p_entered_by_user_id => NULL,
                                           p_attribute_category => pa_rec.line_attribute_category,
                                           p_attribute1         => pa_rec.line_attribute1,
                                           p_attribute2         => pa_rec.line_attribute2,
                                           p_attribute3         => pa_rec.line_attribute3,
                                           p_attribute4         => pa_rec.line_attribute4,
                                           p_attribute5         => pa_rec.line_attribute5,
                                           p_attribute6         => pa_rec.line_attribute6,
                                           p_attribute7         => pa_rec.line_attribute7,
                                           p_attribute8         => pa_rec.line_attribute8,
                                           p_attribute9         => pa_rec.line_attribute9,
                                           p_attribute10        => pa_rec.line_attribute10,
                                           p_attribute11        => pa_rec.line_attribute11,
                                           p_attribute12        => pa_rec.line_attribute12,
                                           p_attribute13        => pa_rec.line_attribute13,
                                           p_attribute14        => pa_rec.line_attribute14,
                                           p_attribute15        => pa_rec.line_attribute15,
                                           p_msg_type           => lv_msg_type,
                                           p_msg_data           => p_return_error_message,
                                           p_billable_flag      => lv_procedure_billable_flag);

  IF (p_return_error_message is not null) AND (lv_msg_type = AP_WEB_DFLEX_PKG.C_CustValidResMsgTypeError) THEN
    /* validation failed, we cannot generate the projects CCID */
    p_new_ccid := to_number(null);
    p_return_status := 'VALIDATION_ERROR';
    RETURN;
  ELSE
    /* For some reason the projects API returns error even though validation is succesful.
     * When the message data is also provided then the validation actually failed. Since these
     * same variables are used elsewhere resetting them to null when validation was succesful */
    lv_msg_type := NULL;
    p_return_error_message := NULL;
  END IF;

  -- Get Award Set ID before calling A/C generator
  ln_award_set_id := null;

  IF (GMS_OIE_INT_PKG.IsGrantsEnabled() and pa_rec.award_id is not null) THEN
    -----------------------------------------------------
    l_debug_info := 'GMS_OIE_INT_PKG.CreateACGenADL';
    -----------------------------------------------------
    ln_award_set_id := GMS_OIE_INT_PKG.CreateACGenADL(p_award_id   => pa_rec.award_id,
                                                      p_project_id => pa_rec.project_id,
                                                      p_task_id    => pa_rec.task_id);
    lb_gms_accounting_created := true;
  END IF;

  IF (pa_rec.line_flex_concat is not null) THEN
    lv_expense_report_cost_center := pa_rec.line_flex_concat;
  ELSE
    lv_expense_report_cost_center := pa_rec.header_cost_center;
  END IF;

  --bug 4629320
  IF AP_WEB_DB_EXPRPT_PKG.GetDefaultEmpCCID(pa_rec.employee_id, l_default_emp_ccid) THEN
     null;
  END IF;
    -----------------------------------------------------
    l_debug_info := 'pa_acc_gen_wf_pkg.ap_er_generate_account';
    -----------------------------------------------------
  IF ( NOT pa_acc_gen_wf_pkg.ap_er_generate_account (p_project_id                 => pa_rec.project_id,
                                                     p_task_id                    => pa_rec.task_id,
                                                     p_expenditure_type           => pa_rec.new_expenditure_type,
                                                     p_vendor_id                  => ln_vendor_id,
                                                     p_expenditure_organization_id=> pa_rec.expenditure_organization_id,

                                                     p_expenditure_item_date      => pa_rec.expenditure_item_date,
                                                     p_billable_flag              => lv_procedure_billable_flag,
                                                     p_chart_of_accounts_id       => pa_rec.chart_of_accounts_id,
                                                     p_calling_module             => 'SelfService',
                                                     p_employee_id                => pa_rec.employee_id,
                                                     p_employee_ccid              => l_default_emp_ccid,
                                                     p_expense_type               => p_exp_type_parameter_id,
                                                     p_expense_cc                 => lv_expense_report_cost_center,
                                                     p_attribute_category         => pa_rec.header_attribute_category,
                                                     p_attribute1                 => pa_rec.header_attribute1,
                                                     p_attribute2                 => pa_rec.header_attribute2,
                                                     p_attribute3                 => pa_rec.header_attribute3,
                                                     p_attribute4                 => pa_rec.header_attribute4,
                                                     p_attribute5                 => pa_rec.header_attribute5,
                                                     p_attribute6                 => pa_rec.header_attribute6,
                                                     p_attribute7                 => pa_rec.header_attribute7,
                                                     p_attribute8                 => pa_rec.header_attribute8,
                                                     p_attribute9                 => pa_rec.header_attribute9,
                                                     p_attribute10                => pa_rec.header_attribute10,
                                                     p_attribute11                => pa_rec.header_attribute11,
                                                     p_attribute12                => pa_rec.header_attribute12,
                                                     p_attribute13                => pa_rec.header_attribute13,
                                                     p_attribute14                => pa_rec.header_attribute14,
                                                     p_attribute15                => pa_rec.header_attribute15,
                                                     p_line_attribute_category    => pa_rec.line_attribute_category,
                                                     p_line_attribute1            => pa_rec.line_attribute1,
                                                     p_line_attribute2            => pa_rec.line_attribute2,
                                                     p_line_attribute3            => pa_rec.line_attribute3,
                                                     p_line_attribute4            => pa_rec.line_attribute4,
                                                     p_line_attribute5            => pa_rec.line_attribute5,
                                                     p_line_attribute6            => pa_rec.line_attribute6,
                                                     p_line_attribute7            => pa_rec.line_attribute7,
                                                     p_line_attribute8            => pa_rec.line_attribute8,
                                                     p_line_attribute9            => pa_rec.line_attribute9,
                                                     p_line_attribute10           => pa_rec.line_attribute10,
                                                     p_line_attribute11           => pa_rec.line_attribute11,
                                                     p_line_attribute12           => pa_rec.line_attribute12,
                                                     p_line_attribute13           => pa_rec.line_attribute13,
                                                     p_line_attribute14           => pa_rec.line_attribute14,
                                                     p_line_attribute15           => pa_rec.line_attribute15,
                                                     x_return_ccid                => l_pa_ccid,
                                                     x_concat_segs                => lv_concat_segs,
                                                     x_concat_ids                 => lv_concat_ids,
                                                     x_concat_descrs              => lv_concat_description,
                                                     x_error_message              => p_return_error_message,
                                                     x_award_set_id               => ln_award_set_id)) THEN

    IF (p_return_error_message is not null) THEN
      /* could not generate the projects CCID */
      p_new_ccid := to_number(null);
      p_return_status := 'GENERATION_ERROR';
      RETURN;

  END IF;

  END IF; /*  pa_acc_gen_wf_pkg.ap_er_generate_account */

  IF (lb_gms_accounting_created = true) THEN
    -----------------------------------------------------
    l_debug_info := 'gms_oie_int_pkg.DeleteACGenADL';
    -----------------------------------------------------
    IF gms_oie_int_pkg.DeleteACGenADL(ln_award_set_id) THEN
      null;
    END IF;
  END IF;

    -----------------------------------------------------
    l_debug_info := 'Get segment delimeter';
    -----------------------------------------------------
  lv_flex_segment_delimiter := FND_FLEX_EXT.GET_DELIMITER('SQLGL','GL#',pa_rec.chart_of_accounts_id);

    -----------------------------------------------------
    l_debug_info := 'Break up segments';
    -----------------------------------------------------
  ln_segment_count := FND_FLEX_EXT.Breakup_Segments(lv_concat_segs, lv_flex_segment_delimiter, l_segments);

   -----------------------------------------------------
   l_debug_info := 'Assign values to p_new_segments';
   -----------------------------------------------------
   p_new_segments := AP_OIE_KFF_SEGMENTS_T('');
   p_new_segments.extend(ln_segment_count);
   FOR i IN 1..ln_segment_count LOOP
      p_new_segments(i) := l_segments(i);
   END LOOP;

  -- create account if don't already exist
  IF (l_pa_ccid = -1) THEN

    -----------------------------------------------------
    l_debug_info := 'Validate segments';
    -----------------------------------------------------
    IF (FND_FLEX_KEYVAL.validate_segs('CREATE_COMBINATION',
                                      'SQLGL',
                                      'GL#',
                                      pa_rec.chart_of_accounts_id,
                                      lv_concat_segs)) THEN
      l_pa_ccid := FND_FLEX_KEYVAL.combination_id;
    ELSE
      p_return_error_message := FND_FLEX_KEYVAL.error_message;
      /* could not generate the projects CCID */
      p_new_ccid := to_number(null);
      p_return_status := 'GENERATION_ERROR';
      return;
    END IF; /* FND_FLEX_KEYVAL.validate_segs */

  END IF; /* l_pa_ccid = -1 */

  IF (l_pa_ccid is null OR l_pa_ccid = -1) THEN
    p_new_ccid := to_number(null);
    p_return_status := 'GENERATION_ERROR';
  ELSE
    p_new_ccid := l_pa_ccid;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    /* could not generate the projects CCID */
    p_new_ccid := to_number(null);
    p_return_status := 'ERROR';

END BuildDistProjectAccount;

PROCEDURE ValidateProjectAccounting(
	p_report_line_id                IN              NUMBER,
	p_web_parameter_id		IN		NUMBER,
	p_project_id			IN		NUMBER,
	p_task_id			IN		NUMBER,
	p_award_id			IN              NUMBER,
	p_award_number			IN              VARCHAR2,
	p_expenditure_org_id		IN		NUMBER,
	p_amount			IN		NUMBER,
	p_return_error_message		OUT NOCOPY	VARCHAR2,
	p_msg_count			OUT NOCOPY	NUMBER,
	p_msg_data			OUT NOCOPY	VARCHAR2
	) IS

 CURSOR pa_cur IS
	SELECT
           aerh.employee_id,
           aerh.flex_concatenated header_cost_center,
           aerh.default_currency_code reimbursement_currency_code,
           aerh.week_end_date,
           aerh.attribute_category header_attribute_category,
           aerh.attribute1 header_attribute1,
           aerh.attribute2 header_attribute2,
           aerh.attribute3 header_attribute3,
           aerh.attribute4 header_attribute4,
           aerh.attribute5 header_attribute5,
           aerh.attribute6 header_attribute6,
           aerh.attribute7 header_attribute7,
           aerh.attribute8 header_attribute8,
           aerh.attribute9 header_attribute9,
           aerh.attribute10 header_attribute10,
           aerh.attribute11 header_attribute11,
           aerh.attribute12 header_attribute12,
           aerh.attribute13 header_attribute13,
           aerh.attribute14 header_attribute14,
           aerh.attribute15 header_attribute15,
           aerl.start_expense_date,
           aerl.end_expense_date,
           aerl.credit_card_trx_id,
           aerl.expenditure_item_date,
           aerl.expenditure_type,
           aerl.pa_quantity,
           aerl.adjustment_reason,
           aerl.category_code,
           aerl.attribute_category line_attribute_category,
           aerl.attribute1 line_attribute1,
           aerl.attribute2 line_attribute2,
           aerl.attribute3 line_attribute3,
           aerl.attribute4 line_attribute4,
           aerl.attribute5 line_attribute5,
           aerl.attribute6 line_attribute6,
           aerl.attribute7 line_attribute7,
           aerl.attribute8 line_attribute8,
           aerl.attribute9 line_attribute9,
           aerl.attribute10 line_attribute10,
           aerl.attribute11 line_attribute11,
           aerl.attribute12 line_attribute12,
           aerl.attribute13 line_attribute13,
           aerl.attribute14 line_attribute14,
           aerl.attribute15 line_attribute15,
           aerl.ap_validation_error,
           s.base_currency_code,
           s.default_exchange_rate_type,
           sob.chart_of_accounts_id,
           erp.pa_expenditure_type new_expenditure_type
    FROM   ap_expense_report_headers_all aerh,
           ap_expense_report_lines_all aerl,
           ap_system_parameters_all s,
           fnd_currencies_vl c,
           gl_sets_of_books sob,
           ap_expense_report_params_all erp
    WHERE  c.currency_code = s.base_currency_code
    AND    sob.set_of_books_id = s.set_of_books_id
    AND    erp.parameter_id = p_web_parameter_id
    AND    aerh.report_header_id = aerl.report_header_id
    AND	   aerl.report_line_id = p_report_line_id;

 pa_rec				pa_cur%ROWTYPE;
 lv_msg_type			VARCHAR2(2000);
 lv_procedure_billable_flag	VARCHAR2(200);
 ln_vendor_id			NUMBER;
 ln_default_exchange_rate	NUMBER;
 ln_acct_raw_cost		NUMBER;
 l_errors			AP_WEB_UTILITIES_PKG.expError;
 l_receipts_errors              AP_WEB_UTILITIES_PKG.receipt_error_stack;
 I				INTEGER;
BEGIN
 IF p_report_line_id is null or p_web_parameter_id is null THEN
	p_return_error_message := 'ERROR';
	RETURN;
 END IF;

 -- Bug: 7176464
 IF (AP_WEB_CUS_ACCTG_PKG.CustomValidateProjectDist(
                         p_report_line_id,
                         p_web_parameter_id,
                         p_project_id,
                         p_task_id,
                         p_award_id,
                         p_expenditure_org_id,
                         p_amount,
                         p_return_error_message)) THEN
      -- Custom Validate Project Allocations
      IF (p_return_error_message is not null) THEN

        AP_WEB_UTILITIES_PKG.AddExpError(l_errors,
                      p_return_error_message,
                      lv_msg_type,
		      'PATC',
                      1,
                      AP_WEB_UTILITIES_PKG.C_PATCMessageCategory, AP_WEB_UTILITIES_PKG.IsMobileApp);
        p_msg_count := 1;
        p_msg_data := p_return_error_message;
        fnd_msg_pub.count_and_get(p_count => p_msg_count,p_data  => p_msg_data);
        -- Bug 7497991 Commenting Return Statement to continue ValidationS
        -- return;
      END IF;
 END IF;

 OPEN pa_cur;

 FETCH pa_cur into pa_rec;
 IF pa_cur%NOTFOUND THEN
   CLOSE pa_cur;
   p_return_error_message := 'ERROR';
   RETURN;
 END IF;
 CLOSE pa_cur;

 AP_WEB_UTILITIES_PKG.InitMessages(1, l_receipts_errors);

 IF (NOT AP_WEB_DB_AP_INT_PKG.GetVendorID(pa_rec.employee_id, ln_vendor_id)) THEN
	ln_vendor_id := NULL;
 END IF; /* GetVendorID */

 ln_default_exchange_rate := AP_UTILITIES_PKG.get_exchange_rate(pa_rec.base_currency_code,
                                                                 pa_rec.reimbursement_currency_code,
                                                                 pa_rec.default_exchange_rate_type,
                                                                 pa_rec.week_end_date,
                                                                'ValidatePATransaction');

 -- Calculate the receipt amount in the functional currency
 ln_acct_raw_cost := NULL;
 IF ln_default_exchange_rate IS NOT NULL AND ln_default_exchange_rate <> 0 THEN
	ln_acct_raw_cost := AP_WEB_UTILITIES_PKG.OIE_ROUND_CURRENCY(p_amount/ln_default_exchange_rate, pa_rec.base_currency_code);
 END IF;


 AP_WEB_PROJECT_PKG.ValidatePATransaction(p_project_id  => p_project_id,
				   p_task_id            => p_task_id,
				   p_ei_date            => pa_rec.start_expense_date,
				   p_expenditure_type   => pa_rec.new_expenditure_type,
				   p_non_labor_resource => NULL,
				   p_person_id          => pa_rec.employee_id,
				   p_quantity           => NULL,
				   p_denom_currency_code=> pa_rec.reimbursement_currency_code,
				   p_acct_currency_code => pa_rec.base_currency_code,
				   p_denom_raw_cost     => p_amount,
				   p_acct_raw_cost      => ln_acct_raw_cost,
				   p_acct_rate_type     => pa_rec.default_exchange_rate_type,
				   p_acct_rate_date     => pa_rec.week_end_date,
				   p_acct_exchange_rate => ln_default_exchange_rate,
				   p_transfer_ei        => NULL,
				   p_incurred_by_org_id => p_expenditure_org_id,
				   p_nl_resource_org_id => NULL,
				   p_transaction_source => NULL,
				   p_calling_module     => 'SelfService',
				   p_vendor_id          => ln_vendor_id,
				   p_entered_by_user_id => NULL,
				   p_attribute_category => pa_rec.line_attribute_category,
				   p_attribute1         => pa_rec.line_attribute1,
				   p_attribute2         => pa_rec.line_attribute2,
				   p_attribute3         => pa_rec.line_attribute3,
				   p_attribute4         => pa_rec.line_attribute4,
				   p_attribute5         => pa_rec.line_attribute5,
				   p_attribute6         => pa_rec.line_attribute6,
				   p_attribute7         => pa_rec.line_attribute7,
				   p_attribute8         => pa_rec.line_attribute8,
				   p_attribute9         => pa_rec.line_attribute9,
				   p_attribute10        => pa_rec.line_attribute10,
				   p_attribute11        => pa_rec.line_attribute11,
				   p_attribute12        => pa_rec.line_attribute12,
				   p_attribute13        => pa_rec.line_attribute13,
				   p_attribute14        => pa_rec.line_attribute14,
				   p_attribute15        => pa_rec.line_attribute15,
				   p_msg_type           => lv_msg_type,
				   p_msg_data           => p_return_error_message,
				   p_billable_flag      => lv_procedure_billable_flag);

 if (p_return_error_message IS NOT NULL AND lv_msg_type = AP_WEB_DFLEX_PKG.C_CustValidResMsgTypeError) then
              AP_WEB_UTILITIES_PKG.AddExpError(l_errors,
                      p_return_error_message,
                      lv_msg_type,
		      'PATC',
                      1,
                      AP_WEB_UTILITIES_PKG.C_PATCMessageCategory, AP_WEB_UTILITIES_PKG.IsMobileApp);
 else
      -- Bug: 6936055, GMS Integration, Award Validation
      if (GMS_OIE_INT_PKG.IsGrantsEnabled() and p_award_id is not null and
		not GMS_OIE_INT_PKG.DoGrantsValidation(p_project_id  => p_project_id,
		  				       p_task_id     => p_task_id,
						       p_award_id    => p_award_id,
						       p_award_number => p_award_number,
						       p_expenditure_type   => pa_rec.new_expenditure_type,
						       p_expenditure_item_date => pa_rec.start_expense_date,
						       p_calling_module => 'SelfService',
						       p_err_msg => p_return_error_message)) then
		AP_WEB_UTILITIES_PKG.AddExpError(l_errors,
                      p_return_error_message,
                      AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
		      'GMS',
                      1,
                      AP_WEB_UTILITIES_PKG.C_PATCMessageCategory, AP_WEB_UTILITIES_PKG.IsMobileApp);
      else
	p_return_error_message := null;
	lv_msg_type := null;
      end if;
 end if;
  if (p_return_error_message is null and pa_rec.end_expense_date is not null) then
         AP_WEB_PROJECT_PKG.ValidatePATransaction(p_project_id  => p_project_id,
                                     p_task_id            => p_task_id,
                                     p_ei_date            => pa_rec.end_expense_date,
                                     p_expenditure_type   => pa_rec.new_expenditure_type,
                                     p_non_labor_resource => NULL,
                                     p_person_id          => pa_rec.employee_id,
                                     p_quantity           => NULL,
                                     p_denom_currency_code=> pa_rec.reimbursement_currency_code,
                                     p_acct_currency_code => pa_rec.base_currency_code,
                                     p_denom_raw_cost     => p_amount,
                                     p_acct_raw_cost      => ln_acct_raw_cost,
                                     p_acct_rate_type     => pa_rec.default_exchange_rate_type,
                                     p_acct_rate_date     => pa_rec.week_end_date,
                                     p_acct_exchange_rate => ln_default_exchange_rate,
                                     p_transfer_ei        => NULL,
                                     p_incurred_by_org_id => p_expenditure_org_id,
                                     p_nl_resource_org_id => NULL,
                                     p_transaction_source => NULL,
                                     p_calling_module     => 'SelfService',
                                     p_vendor_id          => ln_vendor_id,
                                     p_entered_by_user_id => NULL,
                                     p_attribute_category => pa_rec.line_attribute_category,
                                     p_attribute1         => pa_rec.line_attribute1,
                                     p_attribute2         => pa_rec.line_attribute2,
                                     p_attribute3         => pa_rec.line_attribute3,
                                     p_attribute4         => pa_rec.line_attribute4,
                                     p_attribute5         => pa_rec.line_attribute5,
                                     p_attribute6         => pa_rec.line_attribute6,
                                     p_attribute7         => pa_rec.line_attribute7,
                                     p_attribute8         => pa_rec.line_attribute8,
                                     p_attribute9         => pa_rec.line_attribute9,
                                     p_attribute10        => pa_rec.line_attribute10,
                                     p_attribute11        => pa_rec.line_attribute11,
                                     p_attribute12        => pa_rec.line_attribute12,
                                     p_attribute13        => pa_rec.line_attribute13,
                                     p_attribute14        => pa_rec.line_attribute14,
                                     p_attribute15        => pa_rec.line_attribute15,
                                     p_msg_type           => lv_msg_type,
                                     p_msg_data           => p_return_error_message,
                                     p_billable_flag      => lv_procedure_billable_flag);

      if (p_return_error_message IS NOT NULL AND lv_msg_type = AP_WEB_DFLEX_PKG.C_CustValidResMsgTypeError) then
        AP_WEB_UTILITIES_PKG.AddExpError(l_errors,
                p_return_error_message,
                lv_msg_type,
                'PATC',
                1,
                AP_WEB_UTILITIES_PKG.C_PATCMessageCategory, AP_WEB_UTILITIES_PKG.IsMobileApp);
      else
        -- Bug: 6936055, GMS Integration, Award Validation
        if (GMS_OIE_INT_PKG.IsGrantsEnabled() and p_award_id is not null and
		not GMS_OIE_INT_PKG.DoGrantsValidation(p_project_id  => p_project_id,
		  				       p_task_id     => p_task_id,
						       p_award_id    => p_award_id,
						       p_award_number => p_award_number,
						       p_expenditure_type   => pa_rec.new_expenditure_type,
						       p_expenditure_item_date => pa_rec.end_expense_date,
						       p_calling_module => 'SelfService',
						       p_err_msg => p_return_error_message)) then
		AP_WEB_UTILITIES_PKG.AddExpError(l_errors,
                      p_return_error_message,
                      AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
		      'GMS',
                      1,
                      AP_WEB_UTILITIES_PKG.C_PATCMessageCategory, AP_WEB_UTILITIES_PKG.IsMobileApp);
        else
	  p_return_error_message := null;
	  lv_msg_type := null;
        end if;
      end if;
   end if;

 fnd_msg_pub.count_and_get(p_count => p_msg_count,p_data  => p_msg_data);

 EXCEPTION
   WHEN OTHERS THEN
     fnd_msg_pub.count_and_get(p_count => p_msg_count,p_data  => p_msg_data);
 END ValidateProjectAccounting;

-- Bug: 6631437, CC Segment not rendered if it has a parent segment
 PROCEDURE GetDependentSegmentValue(p_employee_id IN         NUMBER,
                                    p_vset_name   IN         VARCHAR2,
                                    p_seg_value   OUT NOCOPY VARCHAR2) IS
 l_EmpInfoRec                AP_WEB_DB_HR_INT_PKG.EmployeeInfoRec;
 l_chart_of_accounts_id      gl_sets_of_books.chart_of_accounts_id%type;
 l_dep_seg_num 	             NUMBER;
 l_segments                  FND_FLEX_EXT.SEGMENTARRAY;
 l_num_of_segments           NUMBER;
 BEGIN
   -- Fetch the Employee Info
   IF (AP_WEB_DB_HR_INT_PKG.GetEmployeeInfo(p_employee_id, l_EmpInfoRec)) THEN
      NULL;
   END IF;
   -- Fetch the Chart of Accounts
   IF (AP_WEB_DB_AP_INT_PKG.GetCOAofSOB(l_chart_of_accounts_id)) THEN
      NULL;
   END IF;
   -- Get the dependent segment number
   IF (GetDependentSegment(p_vset_name, l_chart_of_accounts_id, l_dep_seg_num)) THEN
      NULL;
   END IF;
   -- Get the segments
   IF (FND_FLEX_EXT.GET_SEGMENTS('SQLGL',
                             'GL#',
                             l_chart_of_accounts_id,
                             l_EmpInfoRec.emp_ccid,
                             l_num_of_segments,
                             l_segments)) THEN
      -- Get the segment value
      p_seg_value := l_segments(l_dep_seg_num);
   END IF;

   EXCEPTION
     WHEN OTHERS THEN
     AP_WEB_DB_UTIL_PKG.RaiseException( 'GetDependentSegmentValue' );
     APP_EXCEPTION.RAISE_EXCEPTION;

 END GetDependentSegmentValue;

END AP_WEB_ACCTG_PKG;

/
