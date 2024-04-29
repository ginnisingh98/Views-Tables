--------------------------------------------------------
--  DDL for Package Body BIS_PMV_QUERY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_PMV_QUERY_PVT" AS
/* $Header: BISVQUEB.pls 120.1 2005/09/09 03:30:09 msaran noship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=plb \
-- dbdrv: checkfile(115.112=120.1):~PROD:~PATH:~FILE
--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- nbarik      19-SEP-2002       Bug Fix 2503050 NLS Sort for VARCHAR2
-- nbarik      26-SEP-2002       Bug Fix 1917856 Commented the formatting of date here,
--                               will be done in java files according to NLS Date format
-- nkishore    01-OCT-2002       Bug Fix 2598917 Query obtained is null
-- nbarik      03-OCT-2002       Bug Fix 2605121 Added where condition for cursor
-- ---------   ------  ------------------------------------------
-- Enter package declarations as shown below
gvAll VARCHAR2(3) := 'ALL';
gvCode VARCHAR2(100) := '';

-- serao - 02/20/02- This is the seperator used for bind variables while constructing the query string
SEPERATOR VARCHAR2(1) := '~';
ORDER_BY_SUBST_VAR VARCHAR2(16):= '&ORDER_BY_CLAUSE';
START_INDEX_SUBST_VAR VARCHAR(13) := '&START_INDEX';
END_INDEX_SUBST_VAR VARCHAR(11) := '&END_INDEX';
--serao - to split the variables for the in, 'not in' etc clauses of the queryt
-- so 234, 235 should become in :1, :2
procedure splitMultipleVariables (
  lString IN VARCHAR2,
  x_bind_variables IN OUT NOCOPY VARCHAR2, -- will contain the bind variables in the order
  --x_bind_indexes IN OUT NOCOPY VARCHAR2,
  x_bind_count IN OUT NOCOPY NUMBER,
  x_split_string OUT NOCOPY VARCHAR2 -- will contain :1, :2 etc.
) IS
 lindex NUMBER;
 firstTime BOOLEAN := TRUE;
 pString VARCHAR2(2000) := lString;
BEGIN

  lindex := instr (pSTring, ','); -- index of comma
  -- if there is a comma
  while (lindex >0) loop
    x_bind_variables := x_bind_variables ||SEPERATOR|| substr (pString, 1, lindex-1);

    x_bind_count := x_bind_count+1;
    if not(firstTime) THEN
      x_split_string := x_split_string || ' ,';
    else
      firstTime := FALSE;
    END IF;

    --x_bind_indexes := x_bind_indexes ||SEPERATOR|| x_bind_count;
    x_split_string := x_split_string || ' :'||x_bind_count;

    pString := substr (pString , lindex+1, length(pString));
    lindex := instr (pString, ',');
  end loop;

   -- for the last element
    x_bind_variables := x_bind_variables ||SEPERATOR|| pString;

    x_bind_count := x_bind_count+1;
    if not(firstTime) THEN
      x_split_string := x_split_string || ' ,';
    else
      firstTime := FALSE;
    END IF;

    --x_bind_indexes := x_bind_indexes ||SEPERATOR|| x_bind_count;
    x_split_string := x_split_string || ' :'||x_bind_count;

END splitMultipleVariables;

/** pvt procedure which will replace the paramName with value and return the bindVariable acc to the
 the boolean pUseBindVariable */
PROCEDURE replaceNameWithValue(
 pParamName IN VARCHAR2,
 pParamValue IN VARCHAR2,
 pUseBindVariable IN BOOLEAN DEFAULT true,
 p_initial_index IN NUMBER DEFAULT 0,
 p_original_sql in varchar2,
 xClause IN OUT NOCOPY VARCHAR2,
 x_bind_variables IN OUT NOCOPY VARCHAR2,
 x_plsql_bind_variables IN OUT NOCOPY VARCHAR2,
 x_bind_indexes IN OUT NOCOPY VARCHAR2,
 x_bind_datatypes IN OUT NOCOPY VARCHAR2,
 x_bind_count IN OUT NOCOPY NUMBER
) IS
BEGIN
  IF (pUseBindVariable) THEN
/*
    x_bind_variables := x_bind_variables||SEPERATOR||pParamValue;
    if (pBindIndex > 0) then
       x_bind_indexes := x_bind_indexes||SEPERATOR||p_initial_index;
    else
       x_bind_indexes := x_bind_indexes||SEPERATOR||x_bind_count;
    end if;
    x_bind_count := x_bind_count+1;
    xClause := replace(xClause, pParamName, ' :'||x_bind_count);
*/

    replace_with_bind_variables
    (p_search_string => pParamName,
     p_bind_value => pParamValue,
     p_initial_index => p_initial_index,
     p_original_sql => p_original_sql,
     x_custom_sql => xClause,
     x_bind_variables => x_bind_variables,
     x_plsql_bind_variables => x_plsql_bind_variables,
     x_bind_indexes => x_bind_indexes,
     x_bind_datatypes => x_bind_datatypes,
     x_bind_count => x_bind_count);

  ELSE
    xClause := replace(xClause, pParamName, pParamValue);
  END IF;
END replaceNameWithValue;

/** replaces the BIS_PREVIOUS_EFFECTIVE_START_DATE and BIS_PREVIOUS_EFFECTIVE_END_DATE substitution variables */

-- enh 2467584
-- kiprabha /jprabhud
-- added p_replace_mode
-- p_replace_mode = '1' => previous time value already known (passed as p_default_start_date,p_default_end_date)
--		  = '2' => API to get previous time values needs to get called
PROCEDURE replace_prev_time_parameters(
  p_user_session_rec IN BIS_PMV_SESSION_PVT.SESSION_REC_TYPE,
  p_time_parameter IN VARCHAR2,
  p_asof_date IN VARCHAR2,
  p_time_comparison_type IN VARCHAR2,
  p_default_start_date IN VARCHAR2,
  p_default_end_date IN VARCHAR2,
  p_original_sql in varchar2,
  p_replace_mode IN VARCHAR2,
  x_custom_sql IN OUT NOCOPY VARCHAR2,
  x_return_status out NOCOPY VARCHAR2,
  x_msg_count out NOCOPY NUMBER,
  x_msg_data out NOCOPY VARCHAR2,
  x_bind_variables IN OUT NOCOPY VARCHAR2,
  x_plsql_bind_variables IN OUT NOCOPY VARCHAR2,
  x_bind_indexes IN OUT NOCOPY VARCHAR2,
  x_bind_datatypes IN OUT NOCOPY VARCHAR2,
  x_bind_count IN OUT NOCOPY NUMBER
) IS
   l_time_id                     varchar2(32000);
   l_prev_start_Date             date;
   l_prev_end_Date               date;
   l_prev_start_Date_c           varchar2(200);
   l_prev_end_Date_c             varchar2(200);
   l_description                 varchar2(32000);
   l_index                       number;
BEGIN

     --Get the previous effetive start and end dates and replace them also.
        if (p_replace_mode <> '1') then
           BIS_PMV_TIME_LEVELS_PVT.GET_PREVIOUS_TIME_LEVEL_VALUE
           (p_DimensionLevel        => p_time_parameter
           ,p_region_code           => p_user_session_rec.region_code
           ,p_responsibility_id     => p_user_session_rec.responsibility_id
           ,p_asof_date              => p_asof_date
           ,p_time_comparison_type  => p_time_comparison_type
           ,x_time_level_id         => l_time_id
           ,x_time_level_Value      => l_description
           ,x_start_date            => l_prev_start_date
           ,x_end_date              => l_prev_end_date
           ,x_return_Status         => x_return_Status
           ,x_msg_count             => x_msg_count
           ,x_msg_data              => x_msg_data
        );
        else
	   l_prev_start_date_c := p_default_start_date ;
	   l_prev_end_date_c := p_default_end_date ;
        end if;

        l_index := instrb(p_original_sql, '&BIS_PREVIOUS_EFFECTIVE_START_DATE');
        if (l_index > 0 ) then
          if (l_prev_start_date is null or length(l_prev_start_date) =0) then
             l_prev_start_date_c := p_default_start_date;
          else
            l_prev_start_date_c := to_char(l_prev_start_date, 'DD-MON-YYYY');
          end if;

/*
          x_bind_indexes := x_bind_indexes||SEPERATOR||l_index;
          x_bind_variables := x_bind_variables||SEPERATOR||l_prev_Start_Date_c;
          x_bind_count := x_bind_count+1;
          x_custom_sql := replace(x_custom_sql,'&BIS_PREVIOUS_EFFECTIVE_START_DATE', 'to_Date(:'||x_bind_count||', ''DD-MON-YYYY'')');
*/

          replace_with_bind_variables
          (p_search_string => '&BIS_PREVIOUS_EFFECTIVE_START_DATE',
           p_bind_value => l_prev_Start_Date_c,
           p_initial_index => l_index,
           p_bind_to_date =>'Y',
           p_original_sql => p_original_sql,
           x_custom_sql => x_custom_sql,
           x_bind_variables => x_bind_variables,
           x_plsql_bind_variables => x_plsql_bind_variables,
           x_bind_indexes => x_bind_indexes,
           x_bind_datatypes => x_bind_Datatypes,
           x_bind_count => x_bind_count);

        END IF;

        l_index := instrb(p_original_sql, '&BIS_PREVIOUS_EFFECTIVE_END_DATE');
        if (l_index > 0 ) then
          if (l_prev_end_date is null or length(l_prev_end_date) =0) then
              l_prev_end_date_c := p_default_end_date;
          else
            l_prev_end_date_c := to_char(l_prev_end_date, 'DD-MON-YYYY');
          end if;

/*
          x_bind_indexes := x_bind_indexes||SEPERATOR||l_index;
          x_bind_variables := x_bind_variables||SEPERATOR||l_prev_end_Date_c;
          x_bind_count := x_bind_count+1;
          x_custom_sql := replace(x_custom_sql,'&BIS_PREVIOUS_EFFECTIVE_END_DATE', ' to_Date(:'||x_bind_count||',''DD-MON-YYYY'')');
*/

          replace_with_bind_variables
          (p_search_string => '&BIS_PREVIOUS_EFFECTIVE_END_DATE',
           p_bind_value => l_prev_end_Date_c,
           p_initial_index => l_index,
           p_bind_to_date => 'Y',
           p_original_sql => p_original_sql,
           x_custom_sql => x_custom_sql,
           x_bind_variables => x_bind_variables,
           x_plsql_bind_variables => x_plsql_bind_variables,
           x_bind_indexes => x_bind_indexes,
           x_bind_datatypes => x_bind_Datatypes,
           x_bind_count => x_bind_count);

      end if;


END replace_prev_time_parameters;

PROCEDURE retrieve_params_from_page (
  p_user_session_rec IN BIS_PMV_SESSION_PVT.SESSION_REC_TYPE,
  p_paramlvlparam_Tbl  IN BIS_PMV_PARAMETERS_PVT.parameter_tbl_Type,
  x_asof_date OUT NOCOPY VARCHAR2,
  x_prev_asof_date OUT NOCOPY VARCHAR2,
  x_time_comparison_type OUT NOCOPY VARCHAR2,
  x_return_status out NOCOPY VARCHAR2,
  x_msg_count out NOCOPY NUMBER,
  x_msg_data out NOCOPY VARCHAR2
) IS

   l_parameter_rec BIS_PMV_PARAMETERS_PVT.PARAMETER_REC_TYPE;
BEGIN
   -- retrieve the page level parameters

   l_parameter_rec :=  null;
   if (p_paramlvlparam_tbl.COUNT > 0) then
        FOR i in p_paramlvlparam_tbl.FIRST..p_paramlvlparam_tbl.LAST loop

          l_parameter_rec := p_paramlvlparam_tbl(i);
          if (l_parameter_rec.parameter_name = 'AS_OF_DATE') then
             x_asof_date := l_parameter_rec.
             parameter_description;
          end if;
          if (l_parameter_rec.parameter_name = 'BIS_P_ASOF_DATE') then
             x_prev_asof_date := l_parameter_rec.
             parameter_description;
          end if;

          if (l_parameter_Rec.dimension = 'TIME_COMPARISON_TYPE') then
              x_time_comparison_type := l_parameter_rec.parameter_description;
          end if;

      end loop;
   end if;

END retrieve_params_from_page;

--replaces the ASOF_DATE substitution variables
PROCEDURE replace_paramLvl_parameters(
  p_user_session_rec IN BIS_PMV_SESSION_PVT.SESSION_REC_TYPE,
  p_asof_date IN VARCHAR2,
  p_prev_asof_date IN VARCHAR2,
  p_time_comparison_type IN VARCHAR2,
  p_time_parameter IN VARCHAR2,
  p_original_sql in varchar2,
  x_custom_sql IN OUT NOCOPY VARCHAR2,
  x_return_status out NOCOPY VARCHAR2,
  x_msg_count out NOCOPY NUMBER,
  x_msg_data out NOCOPY VARCHAR2,
  x_bind_variables IN OUT NOCOPY VARCHAR2,
  x_plsql_bind_variables IN OUT NOCOPY VARCHAR2,
  x_bind_indexes IN OUT NOCOPY VARCHAR2,
  x_bind_datatypes IN OUT NOCOPY VARCHAR2,
  x_bind_count IN OUT NOCOPY NUMBER
) IS

  l_index number;
  l_bind_function varchar2(2000);

BEGIN

   l_index := instrb(p_original_sql,'&BIS_CURRENT_ASOF_DATE');
   if (l_index > 0) then
/*
        x_bind_indexes := x_bind_indexes||SEPERATOR||l_index;
        x_bind_variables := x_bind_variables||SEPERATOR||p_asof_date;
        x_bind_count := x_bind_count+1;
        x_custom_sql := replace(x_custom_sql,'&BIS_CURRENT_ASOF_DATE', ' to_Date(:'||x_bind_count||',''DD-MON-YYYY'')');
*/
          replace_with_bind_variables
          (p_search_string => '&BIS_CURRENT_ASOF_DATE',
           p_bind_value => p_asof_date,
           p_initial_index => l_index,
           p_bind_to_date => 'Y',
           p_original_sql => p_original_sql,
           x_custom_sql => x_custom_sql,
           x_bind_variables => x_bind_variables,
           x_plsql_bind_variables => x_plsql_bind_variables,
           x_bind_indexes => x_bind_indexes,
           x_bind_Datatypes => x_bind_datatypes,
           x_bind_count => x_bind_count);
   end if;

   --Get the previous as of date.
   l_index := instrb(p_original_sql, '&BIS_PREVIOUS_ASOF_DATE');
   if (l_index > 0) then
          replace_with_bind_variables
          (p_search_string => '&BIS_PREVIOUS_ASOF_DATE',
           p_bind_value => p_prev_asof_date,
           p_initial_index => l_index,
           p_bind_to_date => 'Y',
           p_original_sql => p_original_sql,
           x_custom_sql => x_custom_sql,
           x_bind_variables => x_bind_variables,
           x_plsql_bind_variables => x_plsql_bind_variables,
           x_bind_indexes => x_bind_indexes,
           x_bind_datatypes => x_bind_datatypes,
           x_bind_count => x_bind_count);

   end if;

END replace_paramLvl_parameters;



-- replaces the time parameters
PROCEDURE replace_report_parameters(
  p_user_session_rec IN BIS_PMV_SESSION_PVT.SESSION_REC_TYPE ,
  pParameterTbl IN BIS_PMV_PARAMETERS_PVT.PARAMETER_TBL_TYPE,
  pStartChar IN CHAR DEFAULT '&',
  pEndChar IN CHAR DEFAULT '',
  pUseBindVariable In BOOLEAN DEFAULT true,
  pReplaceSubstVariable In BOOLEAN DEFAULT true,
  pReplaceXTDVariable In BOOLEAN DEFAULT FALSE, -- replace xtd for custom stuff w/o binding - this is as per reqt.
  p_original_sql in varchar2,
  x_custom_sql IN OUT NOCOPY VARCHAR2,
  x_temp_Start_date OUT NOCOPY VARCHAR2,
  x_temp_end_date OUT NOCOPY VARCHAR2,
  x_time_parameter OUT NOCOPY VARCHAR2,
  x_asOf_date OUT NOCOPY VARCHAR2,
  x_prev_asof_date OUT NOCOPY VARCHAR2,
  x_time_comparison_type OUT NOCOPY VARCHAR2,
  x_bind_variables IN OUT NOCOPY VARCHAR2,
  x_plsql_bind_variables IN OUT NOCOPY VARCHAR2,
  x_bind_indexes IN OUT NOCOPY VARCHAR2,
  x_bind_datatypes IN OUT NOCOPY VARCHAR2,
  x_bind_count IN OUT NOCOPY NUMBER
) IS
   l_parameter_rec               BIS_PMV_PARAMETERS_PVT.PARAMETER_REC_TYPE;
   l_lookup_type                 varchar2(2000) := 'BIS_TIME_LEVEL_VALUES';
   l_Dimlevel_Acronym            varchar2(2000);
   l_index                       number;
   l_param_name                  VARCHAR2(32000);
BEGIN

   if (pParameterTbl.COUNT > 0) then
      for i in pParameterTbl.FIRST..pParameterTbl.LAST loop
          l_parameter_Rec := pParameterTbl(i);

          --check if as-of-date was in the current session
          --if (p_user_session_rec.page_id is null) then
             if (l_parameter_rec.parameter_name = 'AS_OF_DATE') then
             x_asof_date := l_parameter_rec.parameter_description;
             end if;
             if (l_parameter_rec.parameter_name = 'BIS_P_ASOF_DATE') then
             x_prev_asof_date := l_parameter_rec.parameter_description;
             end if;
             if (l_parameter_Rec.dimension = 'TIME_COMPARISON_TYPE') then
                 x_time_comparison_type := l_parameter_rec.parameter_description;
             end if;
          --end if;

          -- dim+dimlevel combination
          l_index := instrb(p_original_sql, pStartChar||l_parameter_rec.parameter_name||pEndChar);
          if (l_index > 0) then
              --jprabhud 08/06/02 - Bug #2468074 Selectively disable drill across links
              if(l_parameter_rec.parameter_name <> 'VIEW_BY') then
                  replaceNameWithValue(
               	     pParamName =>pStartChar|| l_parameter_rec.parameter_name||pEndChar,
               	     pParamValue => l_parameter_rec.parameter_value,
              	     pUseBindVariable => pUseBindVariable,
                     p_initial_index => l_index,
                     p_original_sql => p_original_sql,
              	     xClause => x_custom_sql,
              	     x_bind_variables => x_bind_variables,
              	     x_plsql_bind_variables => x_plsql_bind_variables,
              	     x_bind_indexes => x_bind_indexes,
                     x_bind_datatypes => x_bind_datatypes,
              	     x_bind_count => x_bind_count
                  );
               end if;
          end if;
          if (l_parameter_rec.parameter_name = 'VIEW_BY') then
              l_index := instrb(p_original_Sql,'&BIS_VIEW_BY');
              if (l_index > 0 and (instrb(x_custom_Sql,'&BIS_VIEW_BY') > 0) ) then
                  replaceNameWithValue(
               	     pParamName => '&BIS_VIEW_BY',
               	     pParamValue => l_parameter_rec.parameter_value,
              	     pUseBindVariable => pUseBindVariable,
                     p_initial_index => l_index,
                     p_original_sql => p_original_sql,
              	     xClause => x_custom_sql,
              	     x_bind_variables => x_bind_variables,
              	     x_plsql_bind_variables => x_plsql_bind_variables,
              	     x_bind_indexes => x_bind_indexes,
                     x_bind_datatypes => x_bind_datatypes,
              	     x_bind_count => x_bind_count
                  );
                end if;
           end if;

          if (pReplaceSubstVariable AND (l_parameter_rec.dimension = 'TIME' or l_parameter_Rec.dimension = 'EDW_TIME_M') ) then
             -- check if the xtd is to be replaced
              IF (pReplaceXTDVariable ) THEN
                l_dimlevel_acronym := getParameterAcronym (l_lookup_type,l_parameter_Rec.parameter_name);
                -- replace the lookup with the value e,g &_xtd without bind variables
                IF (instrb(x_custom_sql, '&XTD') > 0) then
                   x_custom_Sql := replace(x_custom_sql,'&XTD', l_dimlevel_acronym);
                END IF;
             END IF;

              --replace the start date
             if (substr(l_parameter_rec.parameter_name, length(l_parameter_Rec.parameter_name)-4) = '_FROM') then

                x_temp_Start_date := to_Char(l_parameter_rec.period_date,'DD-MON-YYYY');
                x_time_parameter := substr(l_parameter_rec.parameter_name,1, length(l_parameter_rec.parameter_name)-5);
                l_index := instrb(p_original_sql,'&BIS_CURRENT_EFFECTIVE_START_DATE');
                if (l_index >0 ) then
                  IF (pUseBindVariable) THEN
/*
                    x_bind_indexes := x_bind_indexes||SEPERATOR||l_index;
                    x_bind_variables := x_bind_variables||SEPERATOR||x_temp_start_date;
                    x_bind_count := x_bind_count+1;
                    x_custom_sql := replace(x_custom_sql, '&BIS_CURRENT_EFFECTIVE_START_DATE','to_Date(:'||x_bind_count||', ''DD-MON-YYYY'')');
*/
                    replace_with_bind_variables
                    (p_search_string => '&BIS_CURRENT_EFFECTIVE_START_DATE',
                     p_bind_value => x_temp_start_date,
                     p_initial_index => l_index,
                     p_bind_to_date => 'Y',
                     p_original_sql => p_original_sql,
                     x_custom_sql => x_custom_sql,
                     x_bind_variables => x_bind_variables,
                     x_plsql_bind_variables => x_plsql_bind_variables,
                     x_bind_indexes => x_bind_indexes,
                     x_bind_datatypes => x_bind_datatypes,
                     x_bind_count => x_bind_count);

                  ELSE
                    x_custom_sql := replace(x_custom_sql, '&BIS_CURRENT_EFFECTIVE_START_DATE', 'to_date('||x_temp_Start_date||', ''DD-MON-YYYY'')');
                  END IF;
                end if;

             end if;

             --replace the end date
             if (substr(l_parameter_rec.parameter_name, length(l_parameter_Rec.parameter_name)-2) = '_TO') then
                   x_temp_end_date := to_char(l_parameter_rec.period_date,'DD-MON-YYYY');

                l_index := instrb(p_original_sql,'&BIS_CURRENT_EFFECTIVE_END_DATE');
                if (l_index >0 ) then
                  IF (pUseBindVariable) THEN
/*
                    x_bind_indexes := x_bind_indexes||SEPERATOR||l_index;
                    x_bind_variables := x_bind_variables||SEPERATOR||x_temp_end_date;
                    x_bind_count := x_bind_count+1;
                    x_custom_sql := replace(x_custom_sql, '&BIS_CURRENT_EFFECTIVE_END_DATE', 'to_Date(:'||x_bind_count||', ''DD-MON-YYYY'')');
*/
                    replace_with_bind_variables
                    (p_search_string => '&BIS_CURRENT_EFFECTIVE_END_DATE',
                     p_bind_value => x_temp_end_date,
                     p_initial_index => l_index,
                     p_bind_to_date => 'Y',
                     p_original_sql => p_original_sql,
                     x_custom_sql => x_custom_sql,
                     x_bind_variables => x_bind_variables,
                     x_plsql_bind_variables => x_plsql_bind_variables,
                     x_bind_indexes => x_bind_indexes,
                     x_bind_Datatypes => x_bind_datatypes,
                     x_bind_count => x_bind_count);

                  ELSE
                    x_custom_sql := replace(x_custom_sql, '&BIS_CURRENT_EFFECTIVE_END_DATE', 'to_date('||x_temp_End_date||', ''DD-MON-YYYY'')');
                  END IF;
                end if;

             end if;

          end if; --TIME

      end loop;
   end if; --IF COUNT


END replace_report_parameters;

/** substitute each of the dim+dimLevels of the params (parameterName) present in the where clause*/

PROCEDURE replace_custom_sql(
  p_user_session_rec IN BIS_PMV_SESSION_PVT.SESSION_REC_TYPE ,
  pParameterTbl IN BIS_PMV_PARAMETERS_PVT.PARAMETER_TBL_TYPE ,
  p_original_sql in varchar2,
  p_where IN OUT NOCOPY VARCHAR2,
  x_bind_variables IN OUT NOCOPY VARCHAR2,
  x_plsql_bind_variables IN OUT NOCOPY VARCHAR2,
  x_bind_indexes IN OUT NOCOPY VARCHAR2,
  x_bind_datatypes IN OUT NOCOPY VARCHAR2,
  x_bind_count IN OUT NOCOPY NUMBER,
  x_return_status out NOCOPY VARCHAR2,
  x_msg_count out NOCOPY NUMBER,
  x_msg_data out NOCOPY VARCHAR2

) IS
   l_time_parameter              varchar2(2000);
   l_asof_date                   varchar2(2000) := to_char(sysdate,'DD-MON-YYYY');
   l_prev_asof_date                   varchar2(2000) := to_char(sysdate,'DD-MON-YYYY');
   l_time_comparison_type        varchar2(2000);
   l_asof_date_page                   varchar2(2000) := to_char(sysdate,'DD-MON-YYYY');
   l_prev_asof_date_page                   varchar2(2000) := to_char(sysdate,'DD-MON-YYYY');
   l_time_comparison_type_page        varchar2(2000);
   l_temp_start_date             varchar2(2000);
   l_temp_end_date               varchar2(2000);

   l_paramlvlparam_Tbl            BIS_PMV_PARAMETERS_PVT.parameter_tbl_Type;
BEGIN


  replace_report_parameters(
    p_user_session_rec => p_user_session_rec,
    pParameterTbl => pParameterTbl,
    p_original_sql => p_original_sql,
    x_custom_sql => p_where,
    x_temp_Start_date => l_temp_Start_date,
    x_temp_end_date => l_temp_end_date,
    x_time_parameter => l_time_parameter,
    x_asOf_date => l_asof_date,
    x_prev_asof_Date => l_prev_asof_Date,
    x_time_comparison_type => l_time_comparison_type,
    x_bind_variables => x_bind_variables,
    x_plsql_bind_variables => x_plsql_bind_variables,
    x_bind_indexes => x_bind_indexes,
    x_bind_datatypes => x_bind_datatypes,
    x_bind_count => x_bind_count
  ) ;

  IF (l_asof_date IS NULL OR l_time_comparison_type IS NULL) THEN

  BIS_PMV_PARAMETERS_PVT.RETRIEVE_PARAMLVL_PARAMETERS
   (p_user_session_Rec       => p_user_session_rec
   ,x_paramportlet_param_tbl => l_paramlvlparam_tbl
   ,x_return_Status          => x_return_Status
   ,x_msg_count              => x_msg_count
   ,x_msg_data               => x_msg_data
   );

    retrieve_params_from_page (
      p_user_session_rec => p_user_session_rec,
      p_paramlvlparam_Tbl => l_paramlvlparam_Tbl,
      x_asof_date => l_asof_date_page,
      x_prev_asof_date => l_prev_asof_date_page,
      x_time_comparison_type => l_time_comparison_type_page,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data
    ) ;
  END IF;

  IF (l_asOf_Date IS NULL) THEN
   IF (l_asof_date_page IS NOT NULL) THEN
     l_asof_date := l_asof_date_page;
   ELSE
     l_asof_date := to_char(sysdate,'DD-MON-YYYY');
   END IF;
  END IF;
  IF (l_prev_asOf_Date IS NULL) THEN
   IF (l_prev_asof_date_page IS NOT NULL) THEN
     l_prev_asof_date := l_prev_asof_date_page;
   ELSE
     l_prev_asof_date := to_char(sysdate,'DD-MON-YYYY');
   END IF;
  END IF;

  IF (l_time_comparison_type IS NULL AND l_time_comparison_type_page IS NOT NULL ) THEN
     l_time_comparison_type := l_time_comparison_type_page;
  END IF;

  replace_paramLvl_parameters(
    p_user_session_rec => p_user_session_rec,
    p_asof_date => l_asof_date ,
    p_prev_asof_date => l_prev_asof_date ,
    p_time_comparison_type => l_time_comparison_type ,
    p_time_parameter => l_time_parameter,
    p_original_sql => p_original_sql,
    x_custom_sql => p_where ,
    x_return_status => x_return_status ,
    x_msg_count => x_msg_count ,
    x_msg_data => x_msg_data ,
    x_bind_variables => x_bind_variables,
    x_plsql_bind_variables => x_plsql_bind_variables,
    x_bind_indexes => x_bind_indexes,
    x_bind_datatypes => x_bind_datatypes,
    x_bind_count => x_bind_count
    );


   IF (instrb(p_where,'&BIS_PREVIOUS_EFFECTIVE_START_DATE') >0 OR
       instrb(p_where,'&BIS_PREVIOUS_EFFECTIVE_END_DATE') > 0 ) THEN

      -- enh 2467584
      -- kiprabha /jprabhud
      -- added p_replace_mode
      -- p_replace_mode = '1' => previous time value already known (passed as p_default_start_date,p_default_end_date)
      --                = '2' => API to get previous time values needs to get called
      replace_prev_time_parameters(
        p_user_session_rec => p_user_session_rec,
        p_time_parameter => l_time_parameter,
        p_asof_date => l_asof_date,
        p_time_comparison_type => l_time_comparison_type,
        p_default_start_date => l_temp_Start_date,
        p_default_end_date => l_temp_end_date,
        p_original_sql => p_original_sql,
        p_replace_mode => '2',
        x_custom_sql => p_where,
        x_return_status => x_return_status,
        x_msg_count =>x_msg_count,
        x_msg_data => x_msg_data,
        x_bind_variables => x_bind_variables,
        x_plsql_bind_variables => x_plsql_bind_variables,
        x_bind_indexes => x_bind_indexes,
        x_bind_datatypes => x_bind_Datatypes,
        x_bind_count => x_bind_count
        );

   END IF;


END replace_custom_sql;



procedure getQuerySQL(p_region_code in VARCHAR2,
                      p_function_name in VARCHAR2,
                      p_user_id in VARCHAR2,
                      p_session_id in VARCHAR2,
                      p_resp_id in VARCHAR2,
                      p_page_id in VARCHAR2 DEFAULT NULL,
                      p_schedule_id in VARCHAR2 DEFAULT NULL,
                      p_sort_attribute in VARCHAR2 DEFAULT NULL,
                      p_sort_direction in VARCHAR2 DEFAULT NULL,
            		      p_source in varchar2 DEFAULT 'REPORT',
                      p_lower_bound IN INTEGER DEFAULT 1,
                      p_upper_bound IN INTEGER DEFAULT -1,
                      x_sql out NOCOPY VARCHAR2,
                      x_target_alias out NOCOPY VARCHAR2,
		      x_has_target out NOCOPY varchar2,
		      x_viewby_table out NOCOPY varchar2,
                      x_return_status out NOCOPY VARCHAR2,
                      x_msg_count out NOCOPY NUMBER,
                      x_msg_data out NOCOPY VARCHAR2,
                      x_bind_variables in OUT NOCOPY VARCHAR2,
                      x_plsql_bind_variables in OUT NOCOPY VARCHAR2,
                      x_bind_indexes in OUT NOCOPY VARCHAR2,
                      x_bind_datatypes IN OUT NOCOPY VARCHAR2,
                      x_view_by_value OUT NOCOPY VARCHAR2
                      ) is

l_viewby_select VARCHAR2(32000);
l_column_select VARCHAR2(32000);
l_target_select VARCHAR2(32000);
l_select   VARCHAR2(32000) := ' SELECT ';
l_from     VARCHAR2(2000) := ' FROM ';
l_where    VARCHAR2(32000) := ' WHERE ';
l_group_by VARCHAR2(2000);
l_order_by VARCHAR2(2000) := ' ';
l_user_groupby VARCHAR2(2000);
l_user_orderby VARCHAR2(2000);


-- parameter info from bis_user_attributes
l_user_session_rec BIS_PMV_SESSION_PVT.SESSION_REC_TYPE;
l_parameter_rec BIS_PMV_PARAMETERS_PVT.PARAMETER_REC_TYPE;
l_parameter_tbl BIS_PMV_PARAMETERS_PVT.PARAMETER_TBL_TYPE;

-- report info from ak_regions_vl
CURSOR ak_region_cursor (cpRegionCode VARCHAR2) IS
SELECT attribute1 disable_viewby,
       attribute6 user_groupby,
       attribute7 user_orderby,
       database_object_name source_view,
       region_object_type report_type,
       attribute8 plsql_function,
       attribute10 data_source,
       attribute11 where_clause
FROM   AK_REGIONS
WHERE  region_code = cpRegionCode;

l_ak_region_rec BIS_PMV_METADATA_PVT.AK_REGION_REC;
l_ak_region_tbl BIS_PMV_METADATA_PVT.AK_REGION_TBL;

/*
l_disable_viewby VARCHAR2(10);
l_user_groupby   VARCHAR2(2000);
l_user_orderby   VARCHAR2(2000);
l_source_view    VARCHAR2(2000);
l_report_type    VARCHAR2(10);
*/
-- save region items
CURSOR save_parameter_cursor (cpRegionCode VARCHAR2, cpParameterName VARCHAR2) IS
SELECT attribute2,
       attribute3 base_column,
       attribute4 where_clause,
       attribute14 data_type
FROM   AK_REGION_ITEMS
WHERE  region_code = cpRegionCode
AND nested_region_code is null
AND    (nvl(attribute2, attribute_code) = cpParameterName
        or attribute2||'_FROM' = cpParameterName
        or attribute2||'_TO' = cpParameterName)
ORDER BY display_sequence;

l_save_region_item_rec BIS_PMV_METADATA_PVT.SAVE_REGION_ITEM_REC;

-- report info from ak_region_items_vl
CURSOR ak_region_item_cursor (cpRegionCode VARCHAR2) IS
SELECT attribute1 attribute_type,
       attribute_code,
       attribute2,
       attribute3 base_column,
       attribute4 where_clause,
       attribute15 lov_table,
       attribute9 aggregate_function,
       attribute14 data_type,
       attribute7 data_format,
       order_sequence,
       order_direction,
       node_query_flag
       ,node_display_flag    -- 2371922
FROM   AK_REGION_ITEMS
WHERE  region_code = cpRegionCode
AND nested_region_code is null
ORDER BY display_sequence;

l_item_count number;
l_ak_region_item_rec BIS_PMV_METADATA_PVT.AK_REGION_ITEM_REC;
l_ak_region_item_tbl BIS_PMV_METADATA_PVT.AK_REGION_ITEM_TBL;
l_Ak_count number :=1;
l_base_column_tbl    BISVIEWER.t_char;
l_aggregation_tbl    BISVIEWER.t_char;

/*
l_attribute_type     VARCHAR2(2000);
l_attribute_code     VARCHAR2(2000);
l_attribute2         VARCHAR2(2000);
l_base_column        VARCHAR2(2000);
l_where_clause       VARCHAR2(2000);
l_aggregate_function VARCHAR2(2000);
l_data_type          VARCHAR2(2000);
l_data_format        VARCHAR2(2000);
l_sort_attribute     VARCHAR2(2000);
l_sort_direction     VARCHAR2(2000);
*/

-- report info from bis_ak_region_item_extension
CURSOR ak_region_item_ext_cursor (cpRegionCode VARCHAR2, cpAttributeCode VARCHAR2) IS
SELECT attribute16 extra_groupby
FROM   BIS_AK_REGION_ITEM_EXTENSION
WHERE  region_code = cpRegionCode
AND    attribute_code = cpAttributeCode;

l_ak_region_item_ext_rec BIS_PMV_METADATA_PVT.AK_REGION_ITEM_EXT_REC;
l_ak_region_item_ext_tbl BIS_PMV_METADATA_PVT.AK_REGION_ITEM_EXT_TBL;

--l_extra_groupby  VARCHAR2(2000);
CURSOR base_col_cursor IS
SELECT distinct attribute3 base_column, attribute9 aggregation_function
FROM AK_REGION_ITEMS
WHERE region_code = p_region_code
AND attribute9 is not null
AND nested_region_code is null
AND substr(attribute3,1,1) not in ('''','"');

--select variables
l_HR_report BOOLEAN := FALSE;
l_first_time BOOLEAN := TRUE;
l_no_target BOOLEAN := FALSE;

l_report_type  VARCHAR2(10);
l_plan_id VARCHAR2(2000);
l_select_string VARCHAR2(2000);
l_viewby_attribute_code VARCHAR2(2000);
l_viewby_attribute2  VARCHAR2(2000);
l_viewby_datatype    VARCHAR2(2000);
l_viewby_dimension   VARCHAR2(2000);
l_viewby_dimension_level  VARCHAR2(2000);
l_viewby_base_column VARCHAR2(2000);
l_viewby_table  VARCHAR2(2000);
l_viewby_id_name VARCHAR2(2000);
l_viewby_value_name   VARCHAR2(2000);
l_extra_groupby_label VARCHAR2(2000);
l_extra_groupby_name VARCHAR2(2000);
l_default_sort_attribute VARCHAR2(2000) := '';
l_def_sort_attr_tbl    BISVIEWER.t_char;
l_Def_sort_seq_tbl     BISVIEWER.t_Char;
l_def_sort_count       NUMBER := 1;
l_sort_attr_code       VARCHAR2(150);
--changed l_sort_attr_code size from 30 to 150 for bugfix 2598917
l_first_attr_code      VARCHAR2(2000);
l_sort_attr_type       VARCHAR2(2000);
l_sel_sort_attribute   VARCHAR2(2000);

l_time_from_value VARCHAR2(2000);
l_time_from_description VARCHAR2(2000);
l_time_to_value VARCHAR2(2000);
l_time_to_description VARCHAR2(2000);
l_time_attribute2 VARCHAR2(2000);
l_time_dimension VARCHAR2(2000);
l_time_dimension_level VARCHAR2(2000);
l_time_table VARCHAR2(2000);
l_time_id_name VARCHAR2(2000);
l_time_value_name VARCHAR2(2000);

l_share_vbt_table BOOLEAN := FALSE;
l_TM_alias VARCHAR2(10) := 'TM';

l_OLTP_org_level VARCHAR2(2000);
l_OLTP_org_value VARCHAR2(2000);
l_OLTP_flag      BOOLEAN := FALSE;

l_target_count number := 1;
l_target_alias VARCHAR2(2000);
l_target_alias_name VARCHAR2(2000);
l_target_alias_name_seperator VARCHAR2(1) := '#';
l_target_alias_group_seperator VARCHAR2(2000) := '*';

l_return_status VARCHAR2(2000);
l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);

l_main_order_by  VARCHAR2(100) :=NULL;
l_first_order_by  VARCHAR2(100) := NULL;
l_second_order_by  VARCHAR2(100) := NULL;
l_viewbyat   varchar2(1);
l_bind_count NUMBER := 0;
l_custom_where VARCHAR2(300);

l_nls_sort_type VARCHAR2(30); --nbarik 19-SEP-2002 NLS Sort for VARCHAR2

begin
  --set up user session info
  l_user_session_rec.function_name := p_function_name;
  l_user_session_rec.region_code := p_region_code;
  l_user_session_rec.page_id := p_page_id;
  l_user_session_rec.session_id := p_session_id;
  l_user_session_rec.user_id := p_user_id;
  l_user_session_rec.responsibility_id := p_resp_id;
  l_user_session_rec.schedule_id := p_schedule_id;

  --get report info from ak_regions_vl
  if ak_region_cursor%ISOPEN then
    close ak_region_cursor;
  end if;
  open ak_region_cursor(l_user_session_rec.region_code);
  fetch ak_region_cursor into l_ak_region_rec;
  close ak_region_cursor;
  --l_ak_region_rec.data_source := 'PLSQL_PROCEDURE_QUERYATTRIBUTES';
  if upper(nvl(l_ak_region_rec.report_type, 'OLTP')) = 'EDW' then
     l_report_type := 'EDW';
  else
     l_report_type := 'OLTP';
  end if;

  --get parameter info from BIS_USER_ATTRIBUTES
  if (p_schedule_id is null   and p_source <> 'ACTUAL_FOR_KPI') or
     (p_source = 'ACTUAL_FOR_KPI' and (p_page_id is null or p_page_id='')) then
     BIS_PMV_PARAMETERS_PVT.RETRIEVE_SESSION_PARAMETERS
     (p_user_session_rec => l_user_session_rec,
      x_user_param_tbl => l_parameter_tbl,
      x_return_status => l_return_status,
      x_msg_count => l_msg_count,
      x_msg_data => l_msg_data
      );
  elsif p_page_id is null or p_page_id = '' then

     BIS_PMV_PARAMETERS_PVT.RETRIEVE_SCHEDULE_PARAMETERS
     (p_schedule_id  => p_schedule_id,
      x_user_param_tbl => l_parameter_tbl,
      x_return_status => l_return_status,
      x_msg_count => l_msg_count,
      x_msg_data => l_msg_data
     );
  elsif p_source in ('ACTUAL','ACTUAL_FOR_KPI') then

     BIS_PMV_PARAMETERS_PVT.RETRIEVE_KPI_PARAMETERS
     (p_user_session_rec => l_user_session_rec,
      x_user_param_tbl => l_parameter_tbl,
      x_return_status => l_return_status,
      x_msg_count => l_msg_count,
      x_msg_data => l_msg_data
     );
   else
     BIS_PMV_PARAMETERS_PVT.RETRIEVE_PAGE_PARAMETERS
     (p_schedule_id  => p_schedule_id,
      p_user_session_rec => l_user_session_rec,
      x_user_param_tbl => l_parameter_tbl,
      x_return_status => l_return_status,
      x_msg_count => l_msg_count,
      x_msg_data => l_msg_data
     );
   end if;

  --set up parameters
  if l_parameter_tbl.COUNT > 0 then
    for i in l_parameter_tbl.FIRST..l_parameter_tbl.LAST loop
        l_parameter_rec := l_parameter_tbl(i);
        --business plan info
        if l_parameter_rec.parameter_name = 'BUSINESS_PLAN' then
           l_plan_id := l_parameter_rec.parameter_value;
        end if;
        --view by info
        if l_parameter_rec.parameter_name = 'VIEW_BY' then
           l_viewby_attribute2 := l_parameter_rec.parameter_value;
           l_viewby_dimension := substr(l_viewby_attribute2, 1, instr(l_viewby_attribute2,'+')-1);
           l_viewby_dimension_level := substr(l_viewby_attribute2, instr(l_viewby_attribute2,'+')+1);
        end if;
        --time info
        if l_parameter_rec.dimension in ('TIME', 'EDW_TIME_M') then
           if substr(l_parameter_rec.parameter_name,
                     length(l_parameter_rec.parameter_name)-length('_FROM')+1) = '_FROM' then
              l_time_attribute2 := substr(l_parameter_rec.parameter_name,
                                          1,
                                          length(l_parameter_rec.parameter_name)-length('_FROM')
                                          );
              l_time_from_value := l_parameter_rec.parameter_value;
              l_time_from_description := l_parameter_rec.parameter_description;
           elsif substr(l_parameter_rec.parameter_name,
                        length(l_parameter_rec.parameter_name)-length('_TO')+1) = '_TO' then
              if l_time_attribute2 is null or length(l_time_attribute2) = 0 then
                 l_time_attribute2 := substr(l_parameter_rec.parameter_name,
                                             1,
                                             length(l_parameter_rec.parameter_name)-length('_TO')
                                             );
              end if;
              l_time_to_value := l_parameter_rec.parameter_value;
              l_time_to_description := l_parameter_rec.parameter_description;
           end if;
           if l_time_dimension is null or length(l_time_dimension) = 0 then
              l_time_dimension := substr(l_time_attribute2, 1, instr(l_time_attribute2,'+')-1);
              l_time_dimension_level := substr(l_time_attribute2,instr(l_time_attribute2,'+')+1);
           end if;
        end if;
        --OLTP org info
        if l_parameter_rec.dimension = 'ORGANIZATION' then
           l_OLTP_org_level := substr(l_parameter_rec.parameter_name,
                                instr(l_parameter_rec.parameter_name,'+')+1);
           l_OLTP_org_value := l_parameter_rec.parameter_value;
           l_OLTP_flag := true;
        end if;
    end loop;
  end if;
  -- If the sql is given by the product teams do not bother to construct the sql
  -- just replace the variables with their values and return as is.
/*
  if (p_region_code = 'OPI_POR_COGS_COMP3') then
     l_ak_region_Rec.plsql_function := 'OPI_POR_MARGIN_REP_VIEW_PKG.GET_SQL';
  end if;
  if (p_region_code = 'OPI_POR_COGS_GRAPH_COMP3') then
     l_ak_Region_rec.plsql_function := 'OPI_POR_MARGIN_REP_VIEW_PKG.GET_GRAPH_SQL';
  end if;
  if (p_region_code = 'FII_FACT1') then
     l_ak_Region_rec.plsql_function := 'FII_MGR_PROTOTYPE.GET_MANAGER';
  end if;
  if (p_region_code = 'FII_FACT2') then
     l_ak_Region_rec.plsql_function := 'FII_MGR_PROTOTYPE.GET_LOB';
  end if;
  if (p_region_code = 'FII_FACT2') then
     l_ak_Region_rec.plsql_function := 'FII_MGR_PROTOTYPE.GET_LOB';
  end if;
*/
  if (l_ak_region_rec.plsql_function is not null) then
     get_custom_sql(p_Source => p_Source,
                    pAKRegionRec => l_ak_region_rec,
                    pParametertbl => l_parameter_tbl,
                    pUserSession => l_user_session_rec,
                    p_sort_attribute => p_sort_attribute,
                    p_sort_direction => p_sort_direction,
                    p_viewby_attribute2 => l_viewby_attribute2,
                    p_viewby_dimension => l_viewby_dimension,
                    p_viewby_dimension_level => l_viewby_dimension_level,
                    p_lower_bound => p_lower_bound,
                    p_upper_bound => p_upper_bound,
                    x_sql_string => x_sql,
            	    x_bind_variables => x_bind_variables,
            	    x_plsql_bind_variables => x_plsql_bind_variables,
            	    x_bind_indexes => x_bind_indexes,
                    x_bind_datatypes => x_bind_datatypes,
                    x_return_status => l_return_Status,
                    x_msg_data => l_msg_data,
                    x_msg_count => l_msg_count,
                    x_view_by_value => x_view_by_value
                   );
                   x_target_alias := '';
                   x_has_target := 'N';
                   x_viewby_table := '';

	return;
 end if;


  --get report info from ak_region_items_vl
  l_item_count := 1;
  if ak_region_item_cursor%ISOPEN then
    close ak_region_item_cursor;
  end if;
 --Get the base column and their aggregation function. We decided to use another query as this
 --might be faster than us having to manipulate the PL/SQL table to get rid of the duplicates.
  --Use a table of records instead
  if (base_col_cursor%ISOPEN) then
     close base_Col_cursor;
  end if;
  open base_col_cursor;
  fetch base_col_cursor bulk collect into l_base_Column_tbl, l_aggregation_tbl;
  close base_col_cursor;

  -- nbarik 19-SEP-2002 NLS Sort for VARCHAR2
  l_nls_sort_type  := fnd_profile.value('ICX_NLS_SORT');

  open ak_region_item_cursor(l_user_session_rec.region_code);
  loop
    fetch ak_region_item_cursor into l_ak_region_item_rec;
    exit when ak_region_item_cursor%NOTFOUND;
    /*l_ak_region_item_tbl(l_ak_count) := l_ak_region_item_rec;
    if (substr(l_ak_region_item_rec.base_column,1,1) <> '''' or
        substr(l_ak_region_item_rec.base_column,1,1) <> '"' ) then
        l_base_column_tbl(l_item_count) := l_ak_region_item_rec.base_column;
        l_item_count := l_item_count+1;
    end if;
    l_ak_count := l_ak_count+1;
  end loop;
  close ak_region_item_cursor;
  if (l_ak_region_item_tbl.COUNT > 0) THEN
  for i in l_ak_Region_item_tbl.FIRST..l_ak_region_item_tbl.LAST loop
      l_ak_region_item_rec := l_ak_region_item_tbl(i);*/
      if (p_Source = 'ACTUAL') then
        l_ak_region_rec.disable_viewby := 'Y';

      --jprabhud  - 02/25/03 - Bug 2806218
      elsif(p_Source = 'ACTUAL_FOR_KPI'  ) then
          if (l_viewby_dimension_level is null OR l_viewby_dimension_level ='' OR l_viewby_dimension_level='''''') then
            l_ak_region_rec.disable_viewby := 'Y';
          end if;

      end if;

  --set up time info
  if l_ak_region_item_rec.attribute2 = l_time_attribute2 then
     if l_viewby_attribute2 = l_time_attribute2 then
        l_share_vbt_table := true;
        l_TM_alias := 'VBT';
     else
        l_share_vbt_table := false;
        l_TM_alias := 'TM';
        l_time_table := l_ak_region_item_rec.lov_table;
        if l_time_table is null or length(l_time_table) = 0 then
           BIS_PMF_GET_DIMLEVELS_PUB.GET_DIMLEVEL_SELECT_STRING
           (p_DimLevelShortName => l_time_dimension_level,
            p_bis_source => l_report_type,
            x_select_string => l_select_string,
            x_table_name => l_time_table,
            x_id_name => l_time_id_name,
            x_value_name => l_time_value_name,
            x_return_status => l_return_status,
            x_msg_count => l_msg_count,
            x_msg_data => l_msg_data);
        else
           l_time_id_name := 'ID';
           l_time_value_name := 'VALUE';
        end if;
     end if;
  end if; -- end of set up time info

 --Get the type for the sort attribute code
  if (p_Sort_Attribute is not null and p_Sort_Attribute=l_ak_region_item_Rec.attribute_code) then
     l_sort_attr_type := l_ak_region_item_rec.data_type;
  end if;
  --set up view by info
  if l_ak_region_item_rec.attribute2 = l_viewby_attribute2 then
     l_viewby_attribute_code := l_ak_region_item_rec.attribute_code;
     l_viewby_base_column := l_ak_region_item_rec.base_column;
     l_viewby_table := l_ak_region_item_rec.lov_table;
     l_viewby_datatype := l_ak_region_item_rec.data_Type;
     if l_viewby_table is null or length(l_viewby_table) = 0 then
        BIS_PMF_GET_DIMLEVELS_PUB.GET_DIMLEVEL_SELECT_STRING
        (p_DimLevelShortName => l_viewby_dimension_level,
         p_bis_source => l_report_type,
         x_select_string => l_select_string,
         x_table_name => l_viewby_table,
         x_id_name => l_viewby_id_name,
         x_value_name => l_viewby_value_name,
         x_return_status => l_return_status,
         x_msg_count => l_msg_count,
         x_msg_data => l_msg_data);
     else
        l_viewby_id_name := 'ID';
        l_viewby_value_name := 'VALUE';
     end if;

     --get info from bis_ak_region_item_extension
     if ak_region_item_ext_cursor%ISOPEN then
        close ak_region_item_ext_cursor;
     end if;
     open ak_region_item_ext_cursor(l_user_session_rec.region_code, l_viewby_attribute_code);
     fetch ak_region_item_ext_cursor into l_ak_region_item_ext_rec;
     close ak_region_item_ext_cursor;

     if l_ak_region_item_ext_rec.extra_groupby is not null then
        l_extra_groupby_label := substr(l_ak_region_item_ext_rec.extra_groupby, 1,
                                 instr(l_ak_region_item_ext_rec.extra_groupby, '=')-1);
        l_extra_groupby_name := rtrim(ltrim(substr(l_ak_region_item_ext_rec.extra_groupby,
                                            instr(l_ak_region_item_ext_rec.extra_groupby, '=')+1)));
     end if;

     --construct viewby select string
     if nvl(l_ak_region_rec.disable_viewby,'N') <> 'Y' then
        if (l_viewby_datatype = 'D') then
            l_viewby_select := 'to_char';
        end if;
	  l_viewby_select := l_viewby_select || '(VBT.' || l_viewby_value_name || ') "VIEWBY", ';
        if (p_source = 'ACTUAL_FOR_KPI') then
           l_viewby_select := l_viewby_select || ' (VBT.' || l_viewby_id_name ||') "VIEWBYID", ';
        end if;
        l_viewbyat := 'Y';
        if gvCode is not null and length(gvCode) > 0 then
           BIS_PMV_QUERY_PVT.get_customized_order_by(p_viewby =>l_viewbyat,
                      p_attribute_code =>l_viewby_attribute_code,
                      p_region_code => p_region_code,
                      p_user_id     => p_user_id,
                      p_customization_code =>gvCode,
                      p_main_order_by => l_main_order_by,
                      p_first_order_by => l_first_order_by,
                      p_second_order_by => l_second_order_by);
        end if;
        if l_extra_groupby_name is not null then
           l_viewby_select := l_viewby_select || 'SV.' || l_extra_groupby_name || ' EXTRAVIEWBY, ';
        end if;
     end if;

  end if; --end of set up view by info
  --Set up the order by info
  if (l_ak_region_item_rec.order_sequence is not null and
      l_ak_region_item_rec.order_Sequence < 100)  and
      l_ak_region_item_rec.node_query_flag = 'N' then
      -- nvl(l_ak_region_rec.disable_viewby,'N') = 'Y' then
      IF (l_ak_region_item_rec.data_type = 'C') THEN -- nbarik 19-SEP-2002 NLS Sort for VARCHAR2
         IF l_nls_sort_type IS NOT NULL THEN
           l_sort_attr_code := ' NLSSORT('||l_ak_region_item_rec.attribute_code||', ''NLS_SORT = ' || l_nls_sort_type ||''') ';
         ELSE
           l_sort_attr_code := l_ak_region_item_rec.attribute_code;
         END IF;
      ELSIF (l_ak_region_item_rec.data_type = 'D') THEN
         l_sort_attr_code := l_ak_region_item_rec.attribute_code;
      ELSE
         l_sort_attr_code := l_ak_region_item_rec.attribute_code;
      END IF;
      l_def_sort_attr_tbl(l_def_sort_count) := l_sort_attr_code||'  '||
			 l_ak_region_item_rec.order_direction;
      l_Def_sort_seq_tbl(l_def_sort_count) := l_ak_region_item_rec.order_sequence;
      l_def_sort_count := l_def_sort_count+1;

  end if;
  if (l_first_time) then
     if  nvl(l_ak_region_rec.disable_viewby,'N') <>  'Y' then
         l_first_attr_code := 'VIEWBY';
         l_first_time := false;
     else
--	if (l_ak_Region_item_rec.node_query_flag = 'N') then
	if (l_ak_Region_item_rec.node_query_flag = 'N' and  l_ak_Region_item_rec.node_display_flag = 'Y') then
           if (l_ak_region_item_rec.data_type = 'D') then
              l_first_attr_code := l_ak_region_item_rec.attribute_code;
           ELSIF (l_ak_region_item_rec.data_type = 'C') THEN -- nbarik 19-SEP-2002 NLS Sort for VARCHAR2
             IF l_nls_sort_type IS NOT NULL THEN
               l_first_attr_code := ' NLSSORT('||l_ak_region_item_rec.attribute_code||', ''NLS_SORT = ' || l_nls_sort_type ||''') ';
             ELSE
               l_first_attr_code := l_ak_region_item_rec.attribute_code;
             END IF;
           else
              l_first_attr_code := l_ak_region_item_rec.attribute_code;
           end if;
           l_first_time := false;
        end if;
     end if;
  end if;

  --set up table columns info
  if (l_ak_region_item_rec.attribute_type = 'MEASURE'
  or  l_ak_region_item_rec.attribute_type = 'MEASURE_NOTARGET'
  or (l_ak_region_item_rec.attribute_type is null and l_ak_region_item_rec.node_query_flag = 'N')) then

     if (substr(l_ak_region_item_rec.base_column, 1, 1) = ''''
     or  substr(l_ak_region_item_rec.base_column, 1, 1) = '"') then
        --if instrb(l_ak_region_item_rec.base_column, '/') <= 0 then
           l_column_select := l_column_select || BIS_PMV_QUERY_PVT.GET_CALCULATE_SELECT(l_ak_region_item_rec, l_parameter_tbl, l_base_column_tbl,l_aggregation_tbl);
        --end if;
     else
        l_column_select := l_column_select || BIS_PMV_QUERY_PVT.GET_NORMAL_SELECT(l_ak_region_item_rec);
     end if;
     l_viewbyat := 'N';
     if gvCode is not null and length(gvCode) > 0 then
        BIS_PMV_QUERY_PVT.get_customized_order_by(p_viewby =>l_viewbyat,
                      p_attribute_code =>l_ak_region_item_rec.attribute_code,
                      p_region_code => p_region_code,
                      p_user_id     => p_user_id,
                      p_customization_code =>gvCode,
                      p_main_order_by => l_main_order_by,
                      p_first_order_by => l_first_order_by,
                      p_second_order_by => l_second_order_by);
     end if;

     if l_ak_region_item_rec.attribute_type = 'MEASURE' and p_source not in ('ACTUAL','ACTUAL_FOR_KPI') then
        BIS_PMV_QUERY_PVT.GET_TARGET_SELECT
                          (p_user_session_rec => l_user_session_rec,
                           p_ak_region_item_rec => l_ak_region_item_rec,
                           p_parameter_tbl => l_parameter_tbl,
                           p_report_type => l_report_type,
                           p_plan_id => l_plan_id,
                           p_viewby_dimension => l_viewby_dimension,
                           p_viewby_attribute2 => l_viewby_attribute2,
                           p_viewby_id_name => l_viewby_id_name,
                           p_time_from_description => l_time_from_description,
                           p_time_to_description => l_time_to_description,
                           x_target_select => l_target_select,
                           x_no_target => l_no_target,
                           x_bind_variables => x_bind_variables,
                           --x_bind_indexes => x_bind_indexes,
                           x_bind_count => l_bind_count);

        if l_target_select is not null and length(l_target_select) > 0 then
           if length(l_ak_region_item_rec.attribute_code) > 23 then
              l_target_alias_name := 'target'||l_target_count;
              l_target_count := l_target_count + 1;
              if l_target_alias is not null and length(l_target_alias) > 0 then
                 l_target_alias := l_target_alias || l_target_alias_group_seperator;
              end if;
              l_target_alias := l_target_alias || l_target_alias_name || l_target_alias_name_seperator
                                               || l_ak_region_item_rec.attribute_code;
           else
              l_target_alias_name := l_ak_region_item_rec.attribute_code || '_TARGET';
           end if;
           l_target_select := l_target_select || ' "'|| l_target_alias_name || '", ';
        end if;

        l_column_select := l_column_select || l_target_select;
     end if;

  end if; --end of set up table columns info

  end loop;
  --end if;
  --close ak_region_item_cursor;

  if l_share_vbt_table then
     l_time_id_name := l_viewby_id_name;
     l_time_value_name := l_viewby_value_name;
  end if;

  x_target_alias := l_target_alias;

  --set HR flag
  if substr(l_OLTP_org_level,1,2) = 'HR' or substr(l_time_dimension_level,1,2) = 'HR' then
     l_HR_report := true;
  end if;

  --get user group by and user order by
  if l_ak_region_rec.user_groupby is not null and length(l_ak_region_rec.user_groupby) > 0 then
     l_user_groupby := BIS_PMV_QUERY_PVT.GET_USER_STRING(l_ak_region_rec.user_groupby);
  end if;

  if l_ak_region_rec.user_orderby is not null and length(l_ak_region_rec.user_orderby) > 0 then
     l_user_orderby := BIS_PMV_QUERY_PVT.GET_USER_STRING(l_ak_region_rec.user_orderby);
  end if;

  --construct select string
  l_select := l_select || l_viewby_select || l_column_select;

  if substr(l_select, length(l_select)-1) = ', ' then
     l_select := substr(l_select, 1, length(l_select)-2);
  end if;

  if l_ak_region_rec.user_groupby is not null and length(l_ak_region_rec.user_groupby) > 0 then
     l_select := l_select || ', ' || l_user_groupby || ' ';
  end if;

  if l_ak_region_rec.user_orderby is not null and length(l_ak_region_rec.user_orderby) > 0 then
     l_select := l_select || ', ' || l_user_orderby || ' ';
  end if;

  --construct from string
  l_from := l_from || l_ak_region_rec.source_view || ' SV';
  if nvl(l_ak_region_rec.disable_viewby,'N') <> 'Y' then
     l_from := l_from || ', ' || l_viewby_table || ' VBT';
  end if;

  if not(l_share_vbt_table) and l_time_table is not null and length(l_time_table) > 0
  and ((l_time_from_value is not null and length(l_time_from_value) > 0)
       or (l_time_to_value is not null and length(l_time_to_value) > 0)
       or (l_report_type <> 'EDW' and not (l_HR_report))) then
     if (l_OLTP_flag)
     or nvl(l_time_to_value, 'All') <> 'All'
     or nvl(l_time_from_value,'All') <> 'All' then
        l_from := l_from || ', ' || l_time_table || ' TM';
     end if;
  end if;

  --construct where string
  if nvl(l_ak_region_rec.disable_viewby,'N') <> 'Y' then
     l_where := l_where || ' SV.' || l_viewby_base_column || '= VBT.' || l_viewby_id_name || ' ';
     if l_report_type <> 'EDW' and l_viewby_dimension = 'ORGANIZATION'
     and l_viewby_dimension_level in ('LEGAL ENTITY','OPERATING UNIT','HR ORGANIZATION','ORGANIZATION',
     'SET OF BOOKS','BUSINESS GROUP','HRI_ORG_HRCY_BX','HRI_ORG_HRCYVRSN_BX','HRI_ORG_HR_HX','HRI_ORG_INHV_H',
     'HRI_ORG_SSUP_H','HRI_ORG_BGR_HX','HRI_ORG_HR_H','HRI_ORG_SRHL') then
         x_bind_variables := x_bind_variables || SEPERATOR||l_user_session_rec.responsibility_id ;
         l_bind_count := l_bind_count +1;
         --x_bind_indexes := x_bind_indexes || SEPERATOR|| l_bind_count;
        l_where := l_where || 'and VBT.responsibility_id = :'||l_bind_count;
        --l_where := l_where || 'and VBT.responsibility_id = '|| l_user_session_rec.responsibility_id || ' ';
     end if;
  else
     l_where := l_where || ' 1=1 ';
  end if;

  if l_parameter_tbl.COUNT > 0 then
    for i in l_parameter_tbl.FIRST..l_parameter_tbl.LAST loop
        l_parameter_rec := l_parameter_tbl(i);
        if (l_parameter_rec.parameter_name <> 'VIEW_BY' AND
         l_parameter_rec.parameter_name <> 'BUSINESS_PLAN' AND
         substr(l_parameter_rec.parameter_name, length(l_parameter_rec.parameter_name)-length
                ('_HIERARCHY')+1) <> '_HIERARCHY') THEN
        --construct where string
        if save_parameter_cursor%ISOPEN then
           close save_parameter_cursor;
        end if;
        l_save_region_item_rec := NULL;
        open save_parameter_cursor(l_user_session_rec.region_code, l_parameter_rec.parameter_name);
        fetch save_parameter_cursor into l_save_region_item_rec;
        close save_parameter_cursor;
        -- continue only if there is a match
        IF (l_save_region_item_rec.base_column IS NOT NULL) THEN
          if  (substr(l_parameter_rec.parameter_name,
                   length(l_parameter_rec.parameter_name)-length('_HIERARCHY')+1) <> '_HIERARCHY') THEN

            if l_parameter_rec.dimension is not null and length(l_parameter_rec.dimension) > 0 then
               --serao - if rolling dimension - just append the base column name to the param value
               IF (l_parameter_rec.parameter_description = BIS_PMV_PARAMETERS_PVT.ROLLING_DIMENSION_DESCRIPTION AND l_parameter_rec.parameter_value is not null) THEN
                   l_where := l_where || ' and SV.'||l_save_region_item_rec.base_column || ' '||l_parameter_rec.parameter_value||' ';
               ELSE
                --Fix for 2435613 and 2435528
                 if l_parameter_rec.dimension in ('TIME', 'EDW_TIME_M') then
		-- Fix for bug 2763337
		-- Introduce checks similar to the ones for constructing
		-- the TM from clause
		-- Note however there is a slight difference -  the call
		-- to get_time_where also has to deal with l_tm_alias 'VBT'
		if (
		(not(l_share_vbt_table)
		and l_time_table is not null and length(l_time_table) > 0
  		and ((l_time_from_value is not null
				and length(l_time_from_value) > 0)
       			or (l_time_to_value is not null
				and length(l_time_to_value) > 0)
       			or (l_report_type <> 'EDW'
				and not (l_HR_report))))
		or
		 l_tm_alias  = 'VBT'
		)
		then

                    if (l_OLTP_flag)
                    or nvl(l_time_to_value, 'All') <> 'All'
                    or nvl(l_time_from_value,'All') <> 'All' then
                      l_where := l_where
                         || BIS_PMV_QUERY_PVT.GET_TIME_WHERE
                         (p_parameter_rec => l_parameter_rec,
                          p_save_region_item_rec => l_save_region_item_rec,
                          p_ak_region_rec => l_ak_region_rec,
                          p_org_dimension_level => l_OLTP_org_level,
                          p_org_dimension_level_value => l_OLTP_org_value,
                          p_viewby_dimension => l_viewby_dimension,
                          p_time_id_name => l_time_id_name,
                          p_time_value_name => l_time_value_name,
                          p_region_code => l_user_session_rec.region_code,
                          p_TM_alias => l_TM_alias,
                          x_bind_variables => x_bind_variables,
                          --x_bind_indexes => x_bind_indexes,
                          x_bind_count => l_bind_count);
                    end if;
		end if ; -- if not(l_share_vbt_table)
                  else
                    l_where := l_where
                               || BIS_PMV_QUERY_PVT.GET_NON_TIME_WHERE(l_parameter_rec,l_save_region_item_rec
                                           ,null,x_bind_variables,l_bind_count);
                end if;
              END IF ; -- not rolling dimension
            else
               l_where := l_where ||
               BIS_PMV_QUERY_PVT.GET_NON_DIMENSION_WHERE(l_parameter_rec,l_save_region_item_rec,
                                                         x_bind_variables,l_bind_count);
            end if;
        end if;

        if l_save_region_item_rec.where_clause is not null and length(l_save_region_item_rec.where_clause) > 0 then
           if nvl(l_ak_region_rec.disable_viewby,'N') = 'Y' or
             (nvl(l_ak_region_rec.disable_viewby,'N') <> 'Y' and l_viewby_attribute2 = l_parameter_rec.parameter_name) then
             l_where := l_where || BIS_PMV_QUERY_PVT.GET_LOV_WHERE(l_parameter_tbl,
                                                                   l_save_region_item_rec.where_clause,
                                                                   l_user_session_rec.region_code
                                                                  );

           end if;
        end if;

        END IF ; -- if l_save_region_item_rec.base column
      end if;
    end loop;
  end if;


  IF l_ak_region_rec.where_clause IS NOT NULL THEN
      l_custom_where := l_ak_region_rec.where_clause;
     replace_custom_sql( p_user_session_rec => l_user_session_rec,
                                                     pParameterTbl => l_parameter_tbl ,
                                                      p_original_sql => l_custom_where,
                                                      p_where => l_custom_where,
                                                      x_bind_variables => x_bind_variables,
                                                      x_plsql_bind_variables => x_plsql_bind_variables,
                                                      x_bind_indexes => x_bind_indexes,
                                                      x_bind_datatypes => x_bind_datatypes,
                                                      x_bind_count => l_bind_count,
                                                      x_return_status => l_return_status,
                                                      x_msg_count => l_msg_count,
                                                      x_msg_data => l_msg_data
                                                       );

    -- Fix for bug 2763337
    -- The Region-level where clause needs to have a leading space embedded
    -- l_where := l_where || l_custom_where;
    l_where := l_where || ' ' || l_custom_where;
  END IF;

  --construct group by string
  if (p_source = 'ACTUAL_FOR_KPI') then
     l_no_target := true;
  end if;
  l_group_by := BIS_PMV_QUERY_PVT.GET_GROUP_BY
               (p_disable_viewby => nvl(l_ak_region_rec.disable_viewby,'N'),
                p_viewby_id_name => l_viewby_id_name,
                p_viewby_value_name => l_viewby_value_name,
                p_viewby_dimension => l_viewby_dimension,
                p_viewby_dimension_level => l_viewby_dimension_level,
                p_extra_groupby => l_extra_groupby_name,
                p_user_groupby => l_user_groupby,
                p_user_orderby => l_user_orderby,
                p_no_target => l_no_target);
  if l_group_by is not null and length(l_group_by) > 0 then
     l_group_by := ' GROUP BY ' || l_group_by;
  end if;
  if (p_source = 'ACTUAL_FOR_KPI')  and
     ( nvl(l_ak_region_rec.disable_viewby,'N') <> 'Y') then
     l_group_by := l_group_by || ' ,VBT.'|| l_viewby_id_name ||' ';
  end if;

  if (l_def_sort_attr_tbl.COUNT > 0) THEN
     --Sort the specified order
     if (l_def_sort_attr_tbl.COUNT > 1) then
         BIS_PMV_QUERY_PVT.sort(l_def_sort_seq_tbl, l_def_sort_attr_tbl);
     end if;
     for i in l_def_sort_seq_tbl.FIRST..l_def_sort_seq_tbl.LAST loop
         l_default_sort_attribute := ' '|| l_default_sort_attribute || l_def_sort_attr_tbl(i)||',';
     end loop;
     l_default_sort_attribute := substr(l_default_sort_attribute, 1, length(l_default_sort_attribute)-1);
  else
     l_default_sort_attribute := l_first_attr_code;
  end if;

  --construct order by string
   --if (p_sort_attribute is not null and length(p_sort_attribute) >0 ) then
     if (p_source <> 'ACTUAL') then
      IF (l_sort_attr_type = 'C' and p_sort_attribute IS NOT NULL) THEN -- nbarik 27-AUG-2002 NLS Sort for VARCHAR2
         IF l_nls_sort_type IS NOT NULL THEN
           l_sel_sort_attribute := ' NLSSORT('||p_sort_Attribute||', ''NLS_SORT = ' || l_nls_sort_type ||''') ';
         ELSE
           l_sel_sort_attribute := p_sort_attribute;
         END IF;
      ELSIF (l_sort_attr_type = 'D' and p_sort_attribute is not null) then
         l_sel_sort_attribute := p_sort_Attribute;
     else
         l_sel_sort_attribute := p_sort_attribute;
     end if;
     l_order_by := ' ORDER BY ';
     l_order_by := l_order_by
             || BIS_PMV_QUERY_PVT.GET_ORDER_BY
               (p_disable_viewby => nvl(l_ak_region_rec.disable_viewby,'N'),
                p_sort_attribute => l_sel_sort_attribute,
                p_sort_direction => p_sort_direction,
                p_viewby_dimension => l_viewby_dimension,
                p_viewby_dimension_level => l_viewby_dimension_level,
                p_default_sort_attribute => l_default_sort_attribute,
                p_user_orderby => l_user_orderby);
   --end if;
    end if;

  if l_main_order_by is not null   then
    l_main_order_by := ' order by '||l_main_order_by||l_first_order_by||l_second_order_by;
    x_sql := l_select || l_from || l_where || l_group_by || l_main_order_by;
  else
    x_sql := l_select || l_from || l_where || l_group_by || l_order_by;
  end if;

  if (l_no_target) then
      x_has_target := 'N';
  else
      x_has_target := 'Y';
  end if;
  x_viewby_table := l_viewby_table;
  x_plsql_bind_variables := x_bind_variables;
end getQuerySQL;

procedure getQuery(p_region_code in VARCHAR2,
                      p_function_name in VARCHAR2,
                      p_user_id in VARCHAR2,
                      p_session_id in VARCHAR2,
                      p_resp_id in VARCHAR2,
                      p_page_id in VARCHAR2 DEFAULT NULL,
                      p_schedule_id in VARCHAR2 DEFAULT NULL,
                      p_sort_attribute in VARCHAR2 DEFAULT NULL,
                      p_sort_direction in VARCHAR2 DEFAULT NULL,
		      p_source         in varchar2 DEFAULT 'REPORT',
                      p_customization_code in varchar2 DEFAULT NULL,
                      p_lower_bound IN INTEGER DEFAULT 1,
                      p_upper_bound IN INTEGER DEFAULT -1,
                      x_sql out NOCOPY VARCHAR2,
                      x_target_alias out NOCOPY VARCHAR2,
		      x_has_target out NOCOPY varchar2,
		      x_viewby_table out NOCOPY varchar2,
                      x_return_status out NOCOPY VARCHAR2,
                      x_msg_count out NOCOPY NUMBER,
                      x_msg_data out NOCOPY VARCHAR2,
                      x_bind_variables out NOCOPY VARCHAR2,
                      x_plsql_bind_variables out NOCOPY VARCHAR2,
                      x_bind_indexes out NOCOPY VARCHAR2,
                      x_bind_datatypes OUT NOCOPY VARCHAR2,
                      x_view_by_value OUT NOCOPY VARCHAR2) is

begin

  gvCode := p_customization_code;
  getQuerySQL(p_region_code => p_region_code,
                      p_function_name => p_function_name,
                      p_user_id => p_user_id,
                      p_session_id => p_session_id,
                      p_resp_id => p_resp_id,
                      p_page_id => p_page_id,
                      p_schedule_id => p_schedule_id,
                      p_sort_attribute => p_sort_attribute,
                      p_sort_direction => p_sort_direction,
		      p_source         => p_source,
                      p_lower_bound => p_lower_bound,
                      p_upper_bound => p_upper_bound,
                      x_sql => x_sql,
                      x_target_alias => x_target_alias,
		      x_has_target => x_has_target,
		      x_viewby_table => x_viewby_table,
                      x_return_status => x_return_status,
                      x_msg_count => x_msg_count,
                      x_msg_data => x_msg_data,
                      x_bind_variables => x_bind_variables,
                      x_plsql_bind_variables => x_plsql_bind_variables,
                      x_bind_indexes => x_bind_indexes,
                      x_bind_datatypes => x_bind_datatypes,
                      x_view_by_value => x_view_by_value );
end getQuery;

function GET_NORMAL_SELECT(p_ak_region_item_rec in BIS_PMV_METADATA_PVT.AK_REGION_ITEM_REC)
return varchar2 is
  l_select_string varchar2(2000);
begin
  l_select_string := p_ak_region_item_rec.aggregate_function || '('
  || BIS_PMV_QUERY_PVT.APPLY_DATA_FORMAT(p_ak_region_item_rec) || ') "'
  || p_ak_region_item_rec.attribute_code || '", ';
  return l_select_string;
end GET_NORMAL_SELECT;

function APPLY_DATA_FORMAT(p_ak_region_item_rec in BIS_PMV_METADATA_PVT.AK_REGION_ITEM_REC)
return varchar2 is
  l_format_string varchar2(2000);
  l_default_date_format VARCHAR2(15) := 'DD-MON-RR';
begin
  if p_ak_region_item_rec.data_type = 'D' then
     --Bug Fix 1917856 Don't do the date formatting here, it will be done in Java files
     l_format_string := 'TO_CHAR(SV.'||p_ak_region_item_rec.base_column||','''|| l_default_date_format||''') ';
     /*
     if (p_ak_region_item_rec.data_format is null or length(p_ak_region_item_rec.data_format) = 0) then
        l_format_string := ' to_char(SV.'||p_ak_region_item_rec.base_column||' )';
     else
        l_format_string := 'TO_CHAR(SV.'||p_ak_region_item_rec.base_column||','''||
        p_ak_region_item_rec.data_format||''') ';
     end if;
     */
   else
     l_format_string := ' SV.'||p_ak_region_item_rec.base_column||' ';
   end if;
  return l_format_string;
end APPLY_DATA_FORMAT;

function GET_CALCULATE_SELECT(p_ak_region_item_rec in BIS_PMV_METADATA_PVT.AK_REGION_ITEM_REC
,p_parameter_tbl  in BIS_PMV_PARAMETERS_PVT.PARAMETER_TBL_TYPE
,p_base_column_tbl in out NOCOPY BISVIEWER.t_char
,p_aggregation_tbl in out NOCOPY BISVIEWER.t_char)
return varchar2 is
  l_calculate_select varchar2(2000);
begin
  if substr(p_ak_region_item_rec.base_column, 1, 1) = '''' then
     l_calculate_select := substr(p_ak_region_item_rec.base_column,2,length(p_ak_region_item_rec.base_column)-2)
     || ' "'||p_ak_region_item_rec.attribute_code||'", ';
  end if;
  if substr(p_ak_region_item_rec.base_column, 1, 1) = '"'
     and    instrb(p_ak_region_item_rec.base_column, '/') <= 0 then
     l_calculate_select := BIS_PMV_QUERY_PVT.REPLACE_FORMULA(p_ak_region_item_rec,
				p_parameter_tbl,
				p_base_column_tbl,
				p_aggregation_Tbl)
     || ' "'||p_ak_region_item_rec.attribute_code||'", ';
  end if;
  return l_calculate_select;
end GET_CALCULATE_SELECT;

--not implemented yet!!
function REPLACE_FORMULA(p_ak_region_item_rec in BIS_PMV_METADATA_PVT.AK_REGION_ITEM_REC
,p_parameter_tbl  in BIS_PMV_PARAMETERS_PVT.PARAMETER_TBL_TYPE
,p_base_column_tbl in out NOCOPY BISVIEWER.t_char
,p_aggregation_tbl in out NOCOPY BISVIEWER.t_char)
return varchar2 is
  l_formula varchar2(2000);
  l_param_name_tbl  BISVIEWER.t_char;
  l_param_value_tbl BISVIEWER.t_char;
  l_return_Status   VARCHAR2(1);
  l_msg_count       NUMBER;
  l_msg_data        VARCHAR2(2000);
  l_base_column     VARCHAR2(150);
  x                 number;  --added
begin
  --Sort the parameters in the decreasing order of their length and then substitute them
  -- in the formula. This is for conversion attributes and stuff...
x :=  p_parameter_tbl.COUNT;
  IF p_parameter_tbl.COUNT > 0 THEN
     for  i in p_parameter_tbl.FIRST..p_parameter_tbl.LAST LOOP
	l_param_name_tbl(i) := p_parameter_tbl(i).parameter_name;
        l_param_value_tbl(i) := p_parameter_tbl(i).parameter_description;
     end loop;
  END IF;
x := l_param_value_tbl.count;
  --Now sort these parameters
if x>0 then
  BIS_PMV_UTIL.sortAttributeCode
  (p_attributecode_tbl => l_param_name_tbl
  ,p_attributevalue_tbl => l_param_value_tbl
  ,x_return_status => l_return_status
  ,x_msg_count     => l_msg_count
  ,x_msg_data      => l_msg_data
  );
end if;
  l_base_column := p_ak_region_item_rec.base_column;
  IF (l_param_name_tbl.COUNT > 0) THEN
     FOR i in l_param_name_tbl.FIRST..l_param_name_tbl.LAST loop
         if (instrb(p_ak_region_item_rec.base_column, l_param_name_tbl(i)) > 0) THEN
            l_base_column := replace(l_base_column, l_param_name_tbl(i), l_param_value_tbl(i));
         end if;
     end loop;
  end if;
  l_formula := substr(l_base_column,2,length(ltrim(rtrim(l_base_column)))-2);
  --Now append the aggregation function to each base column.
x := p_aggregation_tbl.COUNT;
if x > 0 then
  BIS_PMV_UTIL.sortAttributeCode
  (p_attributecode_tbl => p_base_column_tbl
  ,p_attributevalue_tbl => p_aggregation_tbl
  ,x_return_Status => l_return_status
  ,x_msg_count => l_msg_count
  ,x_msg_data => l_msg_data
  );
end if;
  /*for i in p_base_column_tbl.FIRST..p_base_column_tbl.LAST
  loop
      l_base_column := p_base_column_tbl(i);
  end loop;*/
  if (p_base_column_tbl.COUNT > 0) then
     FOR i in p_base_column_tbl.FIRST..p_base_column_tbl.LAST LOOP
         if (instrb(l_formula, p_base_column_tbl(i)) > 0 and
             p_base_column_tbl(i) <> l_base_column) THEN
             --l_formula := replace(l_formula, p_base_Column_tbl(i), p_aggregation_tbl(i)||'(SV.'||
			          --p_base_column_tbl(i)||' )');
               l_formula := replace(l_formula, p_base_column_tbl(i), ':'||i||':');
         end if;
     end loop;
     for i in p_base_column_tbl.FIRST..p_base_column_tbl.LAST LOOP
         l_Formula := replace (l_formula, ':'||i||':', p_aggregation_tbl(i)||'(SV.'||
                                   p_base_column_tbl(i)||'  )');
     end loop;
  end if;
  return l_formula;
end REPLACE_FORMULA;

-- added by serao -02/11/02 - orders dimensions one time while constructing the query

PROCEDURE order_Dimensions(
 pSource In VARCHAR2,
 p_parameter_tbl in BIS_PMV_PARAMETERS_PVT.PARAMETER_TBL_TYPE,
 p_time_to_description in VARCHAR2,
 p_time_from_description in VARCHAR2,
 p_viewby_id_name IN VARCHAR2,
 p_viewby_dimension in VARCHAR2,
 p_viewby_attribute2 IN VARCHAR2,
 pMeasure_short_name In VARCHAR2,
 x_Ordered_Dimension_Select OUT NOCOPY VARCHAR2,
 x_target_level_id OUT NOCOPY NUMBER,
 x_no_target OUT NOCOPY BOOLEAN,
 x_bind_variables In OUT NOCOPY VARCHAR2,
 --x_bind_indexes In OUT NOCOPY VARCHAR2,
 x_bind_count in out NOCOPY NUMBER
)
IS

  l_parameter_rec BIS_PMV_PARAMETERS_PVT.PARAMETER_REC_TYPE;

  TYPE Dimension_Array IS TABLE OF VARCHAR2(80);
  l_dim_arr Dimension_Array := DImension_Array();
  l_dimLevel_arr Dimension_Array := DImension_Array();
  l_dimLevelValue_arr Dimension_Array := DImension_Array();


  l_Ordered_Dimension_Select VARCHAR2(2000) := '';
  l_dimension_level VARCHAR2(80);
  l_dimension_level_short_name  VARCHAR2(80);
  l_dimension_level_id NUMBER;
  l_dim_level_rec               BIS_DIMENSION_LEVEL_PUB.DIMENSION_LEVEL_REC_TYPE;
  l_return_status       VARCHAR2(2000);
  l_error_Tbl           BIS_UTILITIES_PUB.Error_Tbl_Type;
  l_measure_rec		      BIS_MEASURE_PUB.MEASURE_REC_TYPE;
  l_count NUMBER;
  l_no_target boolean := false;

  l_target_level_rec          BIS_TARGET_LEVEL_PUB.TARGET_LEVEL_REC_TYPE;

  l_dim1  VARCHAR2(80);
  l_dim2  VARCHAR2(80);
  l_dim3  VARCHAR2(80);

  lDimension1			VARCHAR2(80);
 lDim1Level		      VARCHAR2(80);
 lDim1LevelValue		VARCHAR2(80);
 lDimension2			VARCHAR2(80);
 lDim2Level		      VARCHAR2(80);
 lDim2LevelValue		VARCHAR2(80);
 lDimension3			VARCHAR2(80);
 lDim3Level		      VARCHAR2(80);
 lDim3LevelValue		VARCHAR2(80);
 lDimension4			VARCHAR2(80);
 lDim4Level		      VARCHAR2(80);
 lDim4LevelValue		VARCHAR2(80);
 lDimension5			VARCHAR2(80);
 lDim5Level		      VARCHAR2(80);
 lDim5LevelValue		VARCHAR2(80);
 lDimension6			VARCHAR2(80);
 lDim6Level		      VARCHAR2(80);
 lDim6LevelValue		VARCHAR2(80);
 lDimension7			VARCHAR2(80);
 lDim7Level		      VARCHAR2(80);
 lDim7LevelValue		VARCHAR2(80);

 lDim1_level_id NUMBER;
 lDim2_level_id NUMBER;
 lDim3_level_id NUMBER;
 lDim4_level_id NUMBER;
 lDim5_level_id NUMBER;
 lDim6_level_id NUMBER;
 lDim7_level_id NUMBER;


 CURSOR c_dim_lvl(p_dim_level_short_name in varchar2) IS
 SELECT level_id
 FROM bis_levels_vl
 WHERE short_name=p_dim_level_short_name;


BEGIN

-------------------SETTIN THE TARGET_LEVEL TO GET THE TARGET_LEVEL_ID (from ShNms pvt)--------------------
 l_target_level_rec.measure_short_name := pMeasure_short_name;

 -------------------------GET THE DIMENSIONS IN THE ORDER THEY ARE ---------------------------
l_count := 0;

  if p_parameter_tbl.COUNT > 0 then
    for i in p_parameter_tbl.FIRST..p_parameter_tbl.LAST loop
        l_parameter_rec := p_parameter_tbl(i);
	if (l_parameter_rec.parameter_name <> 'VIEW_BY' AND
            l_parameter_rec.parameter_name <> 'BUSINESS_PLAN' AND
            substr(l_parameter_rec.parameter_name, length(l_parameter_rec.parameter_name)-9) <> '_HIERARCHY' ) THEN
            if l_parameter_rec.dimension is not null and length(l_parameter_rec.dimension) > 0 then
               l_dimension_level := substr(l_parameter_rec.parameter_name, instr(l_parameter_rec.parameter_name,'+')+1);
               if (l_parameter_rec.dimension in ('TIME', 'EDW_TIME_M')
                  and nvl(p_time_from_description,'All') <> nvl(p_time_to_description,'All')
                  and l_parameter_rec.parameter_name not in (p_viewby_attribute2||'_FROM', p_viewby_attribute2||'_TO'))
                  or (instrb(l_parameter_rec.parameter_value, ''',''') > 0
                  and l_parameter_rec.parameter_name <> p_viewby_attribute2) then
                  l_no_target := true;
                  exit;
                end if;
		if l_parameter_rec.dimension in ('TIME','EDW_TIME_M') then
                   if (substr(l_dimension_level,length(l_dimension_level)-2) = '_TO') THEN
		       goto skip_loop;
                   else
                       l_dimension_level := substr(l_dimension_level, 1, length(l_dimension_level)-5);
                   end if;
                end if;
               			/* l_dimension_select := l_dimension_select || '''' || l_parameter_rec.dimension || ''','''
						|| l_dimension_level || ''',';*/
  	  		l_dim1 :=  l_parameter_rec.dimension ; -- quote here when appending
	  	  	l_dim2 := l_dimension_level ; -- quote here
                if l_parameter_rec.dimension = p_viewby_dimension then
                   -- l_dimension_select := l_dimension_select || 'VBT.' || p_viewby_id_name;
			l_dim3 := 'VBT.' || p_viewby_id_name;
                else
                    if (substr(l_parameter_rec.parameter_value,1,1)='''') then
                        	--l_Dimension_Select := l_dimension_select || l_parameter_Rec.parameter_value;
				  l_dim3 := l_parameter_Rec.parameter_value;
                    else
	                       -- l_dimension_select := l_dimension_select || ''''||l_parameter_rec.parameter_value||'''';
				 l_dim3 :=''''|| l_parameter_rec.parameter_value||''''; -- quote here
                    end if;
                end if;
	                --l_dimension_select := l_dimension_select || ',';
			l_dim_arr.EXTEND();
			l_dim_arr(l_dim_arr.COUNT) := l_dim1;

			l_dimlevel_arr.EXTEND();
			l_dimlevel_arr(l_dimlevel_arr.COUNT) := l_dim2;

			l_dimlevelValue_arr.EXTEND();
			l_dimlevelValue_arr(l_dimlevelValue_arr.COUNT) := l_dim3;

               l_count := l_count + 1;
             end if;
         end if;
         <<skip_loop>>
         null;
    end loop;
  end if;

x_no_target := l_no_target;

IF NOT(l_no_target) THEN --- do this only if there is a target dimension
----------------------------------------------------------------------------------------------------------
-- make sure that all the 7 are present cos the code will ask for the 7th element of the array
  if l_count < 7 then
     for i in l_count+1..7 loop
			l_dim_arr.EXTEND();
			l_dim_arr(l_dim_arr.COUNT) := NULL;

			l_dimlevel_arr.EXTEND();
			l_dimlevel_arr(l_dimlevel_arr.COUNT) := NULL;

			l_dimlevelValue_arr.EXTEND();
			l_dimlevelValue_arr(l_dimlevelValue_arr.COUNT) := NULL;
     end loop;
  end if;

----------------RETRIEVE THE MEASURE TO ORDER THE DIMENSION--------------------------------------

l_measure_rec.measure_short_name := pMeasure_short_name;
--l_measure_rec.measure_id := p_target_level_rec.measure_id;
BIS_MEASURE_PUB.RETRIEVE_MEASURE( p_api_version => 1.0
			           ,p_measure_rec => l_measure_rec
			           ,p_all_info  =>FND_API.G_TRUE
				   ,x_measure_rec => l_measure_rec
                                   ,x_return_status => l_return_status
                                   ,x_error_tbl     => l_error_tbl
				   );

-- should prob continue only if there is a valid measure id .

 ------------------------DIMENSION1 , will be repeated for all the dimensions-------------------

l_dimension_level_short_name := l_dimLevel_arr(1);
l_dimension_level_id := null;

  -- Step 1 - get the short name
  if (upper(l_dimLevelValue_arr(1)) = '''ALL''' OR
      l_dimLevelValue_arr(1) = '''''' OR
      (l_dimLevel_arr(1) is not null and l_dimLevelValue_arr(1) is null))
  then
     l_dimension_level_short_name := BIS_PMV_PMF_PVT.getTotalDimLevelName(l_dim_arr(1),pSource);
     l_dimLevelValue_arr(1) := BIS_PMV_PMF_PVT.getTotalDimValue(pSource,l_dim_arr(1)
								, l_dimension_level_short_name );
  end if;

  --Step 2 , get the dimension level id
  IF (l_dimension_level_short_name IS NOT NULL
     AND BIS_UTILITIES_PUB.Value_Not_Missing(l_dimension_level_short_name) = FND_API.G_TRUE) THEN
     OPEN c_dim_lvl(l_dimension_level_short_name);
     FETCH c_dim_lvl INTO l_dimension_level_id;
     CLOSE c_dim_lvl;
  END IF;

  --STEP 3
  --Get the dimension ids for all the dimension level ids-later used to sequence the dimension levels
  IF (l_dimension_level_id IS NOT NULL
      AND BIS_UTILITIES_PUB.Value_Not_Missing(l_dimension_level_id)= FND_API.G_TRUE) THEN
    l_dim_level_rec.dimension_level_id := l_dimension_level_id;
    BIS_DIMENSION_LEVEL_PUB.Retrieve_Dimension_Level( p_api_version      => 1.0
		                		   ,p_Dimension_Level_Rec => l_dim_level_rec
						   ,x_Dimension_Level_Rec => l_dim_level_rec
						   ,x_return_status       => l_return_status
						   ,x_error_Tbl           => l_error_tbl
								   );

	    --STEP 4 - assign the correct variable
	   IF (l_measure_rec.dimension1_id = l_dim_level_rec.dimension_id) THEN
		lDimension1 := l_dim_arr(1);
		lDim1Level := l_dimension_level_short_name;
		lDim1LevelValue := l_dimLevelValue_arr(1);
		lDim1_level_id := l_dimension_level_id;

	   ELSIF (l_measure_rec.dimension2_id = l_dim_level_rec.dimension_id) THEN
		lDimension2 := l_dim_arr(1);
		lDim2Level := l_dimension_level_short_name;
		lDim2LevelValue := l_dimLevelValue_arr(1);
		lDim2_level_id := l_dimension_level_id;

	   ELSIF (l_measure_rec.dimension3_id = l_dim_level_rec.dimension_id) THEN
		lDimension3 := l_dim_arr(1);
		lDim3Level := l_dimension_level_short_name;
		lDim3LevelValue := l_dimLevelValue_arr(1);
		lDim3_level_id := l_dimension_level_id;

	   ELSIF (l_measure_rec.dimension4_id = l_dim_level_rec.dimension_id) THEN
		lDimension4 := l_dim_arr(1);
		lDim4Level := l_dimension_level_short_name;
		lDim4LevelValue := l_dimLevelValue_arr(1);
		lDim4_level_id := l_dimension_level_id;

	   ELSIF (l_measure_rec.dimension5_id = l_dim_level_rec.dimension_id) THEN
		lDimension5 := l_dim_arr(1);
		lDim5Level := l_dimension_level_short_name;
		lDim5LevelValue := l_dimLevelValue_arr(1);
		lDim5_level_id := l_dimension_level_id;

	   ELSIF (l_measure_rec.dimension6_id = l_dim_level_rec.dimension_id) THEN
		lDimension6 := l_dim_arr(1);
		lDim6Level := l_dimension_level_short_name;
		lDim6LevelValue := l_dimLevelValue_arr(1);
		lDim6_level_id := l_dimension_level_id;

	   ELSIF (l_measure_rec.dimension7_id = l_dim_level_rec.dimension_id) THEN
		lDimension7 := l_dim_arr(1);
		lDim7Level := l_dimension_level_short_name;
		lDim7LevelValue := l_dimLevelValue_arr(1);
		lDim7_level_id := l_dimension_level_id;

	   END IF;
 END IF;

---------------------------DIMENSION 2 -------------------------
l_dimension_level_short_name := l_dimLevel_arr(2);
l_dimension_level_id := null;

  -- Step 1 - get the short name
  if (upper(l_dimLevelValue_arr(2)) = '''ALL''' OR
      l_dimLevelValue_arr(2) = '''''' OR
      (l_dimLevel_arr(2) is not null and l_dimLevelValue_arr(2) is null))
  then
     l_dimension_level_short_name := BIS_PMV_PMF_PVT.getTotalDimLevelName(l_dim_arr(2),pSource);
     l_dimLevelValue_arr(2) := BIS_PMV_PMF_PVT.getTotalDimValue(pSource,l_dim_arr(2)
								, l_dimension_level_short_name );

 end if;


  --Step 2 , get the dimension level id
  IF (l_dimension_level_short_name IS NOT NULL
     AND BIS_UTILITIES_PUB.Value_Not_Missing(l_dimension_level_short_name) = FND_API.G_TRUE) THEN
     OPEN c_dim_lvl(l_dimension_level_short_name);
     FETCH c_dim_lvl INTO l_dimension_level_id;
     CLOSE c_dim_lvl;
  END IF;

  --STEP 3
  --Get the dimension ids for all the dimension level ids-later used to sequence the dimension levels
  IF (l_dimension_level_id IS NOT NULL
      AND BIS_UTILITIES_PUB.Value_Not_Missing(l_dimension_level_id)= FND_API.G_TRUE) THEN
    l_dim_level_rec.dimension_level_id := l_dimension_level_id;
    BIS_DIMENSION_LEVEL_PUB.Retrieve_Dimension_Level( p_api_version      => 1.0
		                		   ,p_Dimension_Level_Rec => l_dim_level_rec
						   ,x_Dimension_Level_Rec => l_dim_level_rec
						   ,x_return_status       => l_return_status
						   ,x_error_Tbl           => l_error_tbl
								   );

  	 --STEP 4 - assign the correct variable
	  IF (l_measure_rec.dimension1_id = l_dim_level_rec.dimension_id) THEN
		lDimension1 := l_dim_arr(2);
		lDim1Level := l_dimension_level_short_name;
		lDim1LevelValue := l_dimLevelValue_arr(2);
		lDim1_level_id := l_dimension_level_id;

	  ELSIF (l_measure_rec.dimension2_id = l_dim_level_rec.dimension_id) THEN
		lDimension2 := l_dim_arr(2);
		lDim2Level := l_dimension_level_short_name;
		lDim2LevelValue := l_dimLevelValue_arr(2);
		lDim2_level_id := l_dimension_level_id;

	  ELSIF (l_measure_rec.dimension3_id = l_dim_level_rec.dimension_id) THEN
		lDimension3 := l_dim_arr(2);
		lDim3Level := l_dimension_level_short_name;
		lDim3LevelValue := l_dimLevelValue_arr(2);
		lDim3_level_id := l_dimension_level_id;

	  ELSIF (l_measure_rec.dimension4_id = l_dim_level_rec.dimension_id) THEN
		lDimension4 := l_dim_arr(2);
		lDim4Level := l_dimension_level_short_name;
		lDim4LevelValue := l_dimLevelValue_arr(2);
		lDim4_level_id := l_dimension_level_id;

	  ELSIF (l_measure_rec.dimension5_id = l_dim_level_rec.dimension_id) THEN
		lDimension5 := l_dim_arr(2);
		lDim5Level := l_dimension_level_short_name;
		lDim5LevelValue := l_dimLevelValue_arr(2);
		lDim5_level_id := l_dimension_level_id;

	  ELSIF (l_measure_rec.dimension6_id = l_dim_level_rec.dimension_id) THEN
		lDimension6 := l_dim_arr(2);
		lDim6Level := l_dimension_level_short_name;
		lDim6LevelValue := l_dimLevelValue_arr(2);
		lDim6_level_id := l_dimension_level_id;

	  ELSIF (l_measure_rec.dimension7_id = l_dim_level_rec.dimension_id) THEN
		lDimension7 := l_dim_arr(2);
		lDim7Level := l_dimension_level_short_name;
		lDim7LevelValue := l_dimLevelValue_arr(2);
		lDim7_level_id := l_dimension_level_id;

	  END IF;

END IF;

------------------------DIMENSION 3 ------------------------------------------
l_dimension_level_short_name := l_dimLevel_arr(3);
l_dimension_level_id := null;

  -- Step 1 - get the short name
  if (upper(l_dimLevelValue_arr(3)) = '''ALL''' OR
      l_dimLevelValue_arr(3) = '''''' OR
      (l_dimLevel_arr(3) is not null and l_dimLevelValue_arr(3) is null))
  then
     l_dimension_level_short_name := BIS_PMV_PMF_PVT.getTotalDimLevelName(l_dim_arr(3),pSource);
     l_dimLevelValue_arr(3) := BIS_PMV_PMF_PVT.getTotalDimValue(pSource,l_dim_arr(3)
								, l_dimension_level_short_name );

 end if;

  --Step 2 , get the dimension level id
  IF (l_dimension_level_short_name IS NOT NULL
     AND BIS_UTILITIES_PUB.Value_Not_Missing(l_dimension_level_short_name) = FND_API.G_TRUE) THEN
     OPEN c_dim_lvl(l_dimension_level_short_name);
     FETCH c_dim_lvl INTO l_dimension_level_id;
     CLOSE c_dim_lvl;
  END IF;

  --STEP 3
  --Get the dimension ids for all the dimension level ids-later used to sequence the dimension levels
  IF (l_dimension_level_id IS NOT NULL
      AND BIS_UTILITIES_PUB.Value_Not_Missing(l_dimension_level_id)= FND_API.G_TRUE) THEN
    --SetNULL(l_dim_level_rec,l_dim_level_rec);
    l_dim_level_rec.dimension_level_id := l_dimension_level_id;
    BIS_DIMENSION_LEVEL_PUB.Retrieve_Dimension_Level( p_api_version      => 1.0
		                		   ,p_Dimension_Level_Rec => l_dim_level_rec
						   ,x_Dimension_Level_Rec => l_dim_level_rec
						   ,x_return_status       => l_return_status
						   ,x_error_Tbl           => l_error_tbl
								   );

	   --STEP 4 - assign the correct variable
	  IF (l_measure_rec.dimension1_id = l_dim_level_rec.dimension_id) THEN
		lDimension1 := l_dim_arr(3);
		lDim1Level := l_dimension_level_short_name;
		lDim1LevelValue := l_dimLevelValue_arr(3);
		lDim1_level_id := l_dimension_level_id;

	  ELSIF (l_measure_rec.dimension2_id = l_dim_level_rec.dimension_id) THEN
		lDimension2 := l_dim_arr(3);
		lDim2Level := l_dimension_level_short_name;
		lDim2LevelValue := l_dimLevelValue_arr(3);
		lDim2_level_id := l_dimension_level_id;

	  ELSIF (l_measure_rec.dimension3_id = l_dim_level_rec.dimension_id) THEN
		lDimension3 := l_dim_arr(3);
		lDim3Level := l_dimension_level_short_name;
		lDim3LevelValue := l_dimLevelValue_arr(3);
		lDim3_level_id := l_dimension_level_id;

	  ELSIF (l_measure_rec.dimension4_id = l_dim_level_rec.dimension_id) THEN
		lDimension4 := l_dim_arr(3);
		lDim4Level := l_dimension_level_short_name;
		lDim4LevelValue := l_dimLevelValue_arr(3);
		lDim4_level_id := l_dimension_level_id;

	  ELSIF (l_measure_rec.dimension5_id = l_dim_level_rec.dimension_id) THEN
		lDimension5 := l_dim_arr(3);
		lDim5Level := l_dimension_level_short_name;
		lDim5LevelValue := l_dimLevelValue_arr(3);
		lDim5_level_id := l_dimension_level_id;

	  ELSIF (l_measure_rec.dimension6_id = l_dim_level_rec.dimension_id) THEN
		lDimension6 := l_dim_arr(3);
		lDim6Level := l_dimension_level_short_name;
		lDim6LevelValue := l_dimLevelValue_arr(3);
		lDim6_level_id := l_dimension_level_id;

	  ELSIF (l_measure_rec.dimension7_id = l_dim_level_rec.dimension_id) THEN
		lDimension7 := l_dim_arr(3);
		lDim7Level := l_dimension_level_short_name;
		lDim7LevelValue := l_dimLevelValue_arr(3);
		lDim7_level_id := l_dimension_level_id;

	  END IF;
   END IF;

----------------------------------------DIMENSION 4 -------------------------------
l_dimension_level_short_name := l_dimLevel_arr(4);
l_dimension_level_id := null;

  -- Step 1 - get the short name
  if (upper(l_dimLevelValue_arr(4)) = '''ALL''' OR
      l_dimLevelValue_arr(4) = '''''' OR
      (l_dimLevel_arr(4) is not null and l_dimLevelValue_arr(4) is null))
  then
     l_dimension_level_short_name := BIS_PMV_PMF_PVT.getTotalDimLevelName(l_dim_arr(4),pSource);
     l_dimLevelValue_arr(4) := BIS_PMV_PMF_PVT.getTotalDimValue(pSource,l_dim_arr(4)
								, l_dimension_level_short_name );
 end if;

  --Step 2 , get the dimension level id
  IF (l_dimension_level_short_name IS NOT NULL
     AND BIS_UTILITIES_PUB.Value_Not_Missing(l_dimension_level_short_name) = FND_API.G_TRUE) THEN
     OPEN c_dim_lvl(l_dimension_level_short_name);
     FETCH c_dim_lvl INTO l_dimension_level_id;
     CLOSE c_dim_lvl;
  END IF;

  --STEP 3
  --Get the dimension ids for all the dimension level ids-later used to sequence the dimension levels
  IF (l_dimension_level_id IS NOT NULL
      AND BIS_UTILITIES_PUB.Value_Not_Missing(l_dimension_level_id)= FND_API.G_TRUE) THEN
    --SetNULL(l_dim_level_rec,l_dim_level_rec);
    l_dim_level_rec.dimension_level_id := l_dimension_level_id;
    BIS_DIMENSION_LEVEL_PUB.Retrieve_Dimension_Level( p_api_version      => 1.0
		                		   ,p_Dimension_Level_Rec => l_dim_level_rec
						   ,x_Dimension_Level_Rec => l_dim_level_rec
						   ,x_return_status       => l_return_status
						   ,x_error_Tbl           => l_error_tbl
								   );

	   --STEP 4 - assign the correct variable
	  IF (l_measure_rec.dimension1_id = l_dim_level_rec.dimension_id) THEN
		lDimension1 := l_dim_arr(4);
		lDim1Level := l_dimension_level_short_name;
		lDim1LevelValue := l_dimLevelValue_arr(4);
		lDim1_level_id := l_dimension_level_id;

	  ELSIF (l_measure_rec.dimension2_id = l_dim_level_rec.dimension_id) THEN
		lDimension2 := l_dim_arr(4);
		lDim2Level := l_dimension_level_short_name;
		lDim2LevelValue := l_dimLevelValue_arr(4);
		lDim2_level_id := l_dimension_level_id;

	  ELSIF (l_measure_rec.dimension3_id = l_dim_level_rec.dimension_id) THEN
		lDimension3 := l_dim_arr(4);
		lDim3Level := l_dimension_level_short_name;
		lDim3LevelValue := l_dimLevelValue_arr(4);
		lDim3_level_id := l_dimension_level_id;

	  ELSIF (l_measure_rec.dimension4_id = l_dim_level_rec.dimension_id) THEN
		lDimension4 := l_dim_arr(4);
		lDim4Level := l_dimension_level_short_name;
		lDim4LevelValue := l_dimLevelValue_arr(4);
		lDim4_level_id := l_dimension_level_id;

	  ELSIF (l_measure_rec.dimension5_id = l_dim_level_rec.dimension_id) THEN
		lDimension5 := l_dim_arr(4);
		lDim5Level := l_dimension_level_short_name;
		lDim5LevelValue := l_dimLevelValue_arr(4);
		lDim5_level_id := l_dimension_level_id;

	  ELSIF (l_measure_rec.dimension6_id = l_dim_level_rec.dimension_id) THEN
		lDimension6 := l_dim_arr(4);
		lDim6Level := l_dimension_level_short_name;
		lDim6LevelValue := l_dimLevelValue_arr(4);
		lDim6_level_id := l_dimension_level_id;

	  ELSIF (l_measure_rec.dimension7_id = l_dim_level_rec.dimension_id) THEN
		lDimension7 := l_dim_arr(4);
		lDim7Level := l_dimension_level_short_name;
		lDim7LevelValue := l_dimLevelValue_arr(4);
		lDim7_level_id := l_dimension_level_id;
	 END IF;
END IF;

----------------------------------------DIMENSION 5 -------------------------

l_dimension_level_short_name := l_dimLevel_arr(5);
l_dimension_level_id := null;

  -- Step 1 - get the short name
  if (upper(l_dimLevelValue_arr(5)) = '''ALL''' OR
      l_dimLevelValue_arr(5) = '''''' OR
      (l_dimLevel_arr(5) is not null and l_dimLevelValue_arr(5) is null))
  then
     l_dimension_level_short_name := BIS_PMV_PMF_PVT.getTotalDimLevelName(l_dim_arr(5),pSource);
     l_dimLevelValue_arr(5) := BIS_PMV_PMF_PVT.getTotalDimValue(pSource,l_dim_arr(5)
								, l_dimension_level_short_name );

 end if;

  --Step 2 , get the dimension level id
  IF (l_dimension_level_short_name IS NOT NULL
     AND BIS_UTILITIES_PUB.Value_Not_Missing(l_dimension_level_short_name) = FND_API.G_TRUE) THEN
     OPEN c_dim_lvl(l_dimension_level_short_name);
     FETCH c_dim_lvl INTO l_dimension_level_id;
     CLOSE c_dim_lvl;
  END IF;

  --STEP 3
  --Get the dimension ids for all the dimension level ids-later used to sequence the dimension levels
  IF (l_dimension_level_id IS NOT NULL
      AND BIS_UTILITIES_PUB.Value_Not_Missing(l_dimension_level_id)= FND_API.G_TRUE) THEN
    --SetNULL(l_dim_level_rec,l_dim_level_rec);
    l_dim_level_rec.dimension_level_id := l_dimension_level_id;
    BIS_DIMENSION_LEVEL_PUB.Retrieve_Dimension_Level( p_api_version      => 1.0
		                		   ,p_Dimension_Level_Rec => l_dim_level_rec
						   ,x_Dimension_Level_Rec => l_dim_level_rec
						   ,x_return_status       => l_return_status
						   ,x_error_Tbl           => l_error_tbl
								   );

	   --STEP 4 - assign the correct variable
	  IF (l_measure_rec.dimension1_id = l_dim_level_rec.dimension_id) THEN
		lDimension1 := l_dim_arr(5);
		lDim1Level := l_dimension_level_short_name;
		lDim1LevelValue := l_dimLevelValue_arr(5);
		lDim1_level_id := l_dimension_level_id;

	  ELSIF (l_measure_rec.dimension2_id = l_dim_level_rec.dimension_id) THEN
		lDimension2 := l_dim_arr(5);
		lDim2Level := l_dimension_level_short_name;
		lDim2LevelValue := l_dimLevelValue_arr(5);
		lDim2_level_id := l_dimension_level_id;

	  ELSIF (l_measure_rec.dimension3_id = l_dim_level_rec.dimension_id) THEN
		lDimension3 := l_dim_arr(5);
		lDim3Level := l_dimension_level_short_name;
		lDim3LevelValue := l_dimLevelValue_arr(5);
		lDim3_level_id := l_dimension_level_id;

	  ELSIF (l_measure_rec.dimension4_id = l_dim_level_rec.dimension_id) THEN
		lDimension4 := l_dim_arr(5);
		lDim4Level := l_dimension_level_short_name;
		lDim4LevelValue := l_dimLevelValue_arr(5);
		lDim4_level_id := l_dimension_level_id;

	  ELSIF (l_measure_rec.dimension5_id = l_dim_level_rec.dimension_id) THEN
		lDimension5 := l_dim_arr(5);
		lDim5Level := l_dimension_level_short_name;
		lDim5LevelValue := l_dimLevelValue_arr(5);
		lDim5_level_id := l_dimension_level_id;

	  ELSIF (l_measure_rec.dimension6_id = l_dim_level_rec.dimension_id) THEN
		lDimension6 := l_dim_arr(5);
		lDim6Level := l_dimension_level_short_name;
		lDim6LevelValue := l_dimLevelValue_arr(5);
		lDim6_level_id := l_dimension_level_id;

	  ELSIF (l_measure_rec.dimension7_id = l_dim_level_rec.dimension_id) THEN
		lDimension7 := l_dim_arr(5);
		lDim7Level := l_dimension_level_short_name;
		lDim7LevelValue := l_dimLevelValue_arr(5);
		lDim7_level_id := l_dimension_level_id;

	  END IF;
  END IF;

-------------------------------------------DIMENSION 6 -----------------------
l_dimension_level_short_name := l_dimLevel_arr(6);
l_dimension_level_id := null;

  -- Step 1 - get the short name
  if (upper(l_dimLevelValue_arr(6)) = '''ALL''' OR
      l_dimLevelValue_arr(6) = '''''' OR
      (l_dimLevel_arr(6) is not null and l_dimLevelValue_arr(6) is null))
  then
     l_dimension_level_short_name := BIS_PMV_PMF_PVT.getTotalDimLevelName(l_dim_arr(6),pSource);
     l_dimLevelValue_arr(6) := BIS_PMV_PMF_PVT.getTotalDimValue(pSource,l_dim_arr(6)
								, l_dimension_level_short_name );

 end if;

  --Step 2 , get the dimension level id
  IF (l_dimension_level_short_name IS NOT NULL
     AND BIS_UTILITIES_PUB.Value_Not_Missing(l_dimension_level_short_name) = FND_API.G_TRUE) THEN
     OPEN c_dim_lvl(l_dimension_level_short_name);
     FETCH c_dim_lvl INTO l_dimension_level_id;
     CLOSE c_dim_lvl;
  END IF;

  --STEP 3
  --Get the dimension ids for all the dimension level ids-later used to sequence the dimension levels
  IF (l_dimension_level_id IS NOT NULL
      AND BIS_UTILITIES_PUB.Value_Not_Missing(l_dimension_level_id)= FND_API.G_TRUE) THEN
    --SetNULL(l_dim_level_rec,l_dim_level_rec);
    l_dim_level_rec.dimension_level_id := l_dimension_level_id;
    BIS_DIMENSION_LEVEL_PUB.Retrieve_Dimension_Level( p_api_version      => 1.0
		                		   ,p_Dimension_Level_Rec => l_dim_level_rec
						   ,x_Dimension_Level_Rec => l_dim_level_rec
						   ,x_return_status       => l_return_status
						   ,x_error_Tbl           => l_error_tbl
								   );

	   --STEP 4 - assign the correct variable
	  IF (l_measure_rec.dimension1_id = l_dim_level_rec.dimension_id) THEN
		lDimension1 := l_dim_arr(6);
		lDim1Level := l_dimension_level_short_name;
		lDim1LevelValue := l_dimLevelValue_arr(6);
		lDim1_level_id := l_dimension_level_id;

	  ELSIF (l_measure_rec.dimension2_id = l_dim_level_rec.dimension_id) THEN
		lDimension2 := l_dim_arr(6);
		lDim2Level := l_dimension_level_short_name;
		lDim2LevelValue := l_dimLevelValue_arr(6);
		lDim2_level_id := l_dimension_level_id;

	  ELSIF (l_measure_rec.dimension3_id = l_dim_level_rec.dimension_id) THEN
		lDimension3 := l_dim_arr(6);
		lDim3Level := l_dimension_level_short_name;
		lDim3LevelValue := l_dimLevelValue_arr(6);
		lDim3_level_id := l_dimension_level_id;

	  ELSIF (l_measure_rec.dimension4_id = l_dim_level_rec.dimension_id) THEN
		lDimension4 := l_dim_arr(6);
		lDim4Level := l_dimension_level_short_name;
		lDim4LevelValue := l_dimLevelValue_arr(6);
		lDim4_level_id := l_dimension_level_id;

	  ELSIF (l_measure_rec.dimension5_id = l_dim_level_rec.dimension_id) THEN
		lDimension5 := l_dim_arr(6);
		lDim5Level := l_dimension_level_short_name;
		lDim5LevelValue := l_dimLevelValue_arr(6);
		lDim5_level_id := l_dimension_level_id;

	 ELSIF (l_measure_rec.dimension6_id = l_dim_level_rec.dimension_id) THEN
		lDimension6 := l_dim_arr(6);
		lDim6Level := l_dimension_level_short_name;
		lDim6LevelValue := l_dimLevelValue_arr(6);
		lDim6_level_id := l_dimension_level_id;

	 ELSIF (l_measure_rec.dimension7_id = l_dim_level_rec.dimension_id) THEN
		lDimension7 := l_dim_arr(6);
		lDim7Level := l_dimension_level_short_name;
		lDim7LevelValue := l_dimLevelValue_arr(6);
		lDim7_level_id := l_dimension_level_id;

	 END IF;
  END IF;

-------------------------------------------------DIMENSION 7 -------------------
l_dimension_level_short_name := l_dimLevel_arr(7);
l_dimension_level_id := null;

  -- Step 1 - get the short name
  if (upper(l_dimLevelValue_arr(7)) = '''ALL''' OR
      l_dimLevelValue_arr(7) = '''''' OR
      (l_dimLevel_arr(7) is not null and l_dimLevelValue_arr(7) is null))
  then
     l_dimension_level_short_name := BIS_PMV_PMF_PVT.getTotalDimLevelName(l_dim_arr(7),pSource);
     l_dimLevelValue_arr(7) := BIS_PMV_PMF_PVT.getTotalDimValue(pSource,l_dim_arr(7)
								, l_dimension_level_short_name );

 end if;

  --Step 2 , get the dimension level id
  IF (l_dimension_level_short_name IS NOT NULL
     AND BIS_UTILITIES_PUB.Value_Not_Missing(l_dimension_level_short_name) = FND_API.G_TRUE) THEN
     OPEN c_dim_lvl(l_dimension_level_short_name);
     FETCH c_dim_lvl INTO l_dimension_level_id;
     CLOSE c_dim_lvl;
  END IF;

  --STEP 3
  --Get the dimension ids for all the dimension level ids-later used to sequence the dimension levels
  IF (l_dimension_level_id IS NOT NULL
      AND BIS_UTILITIES_PUB.Value_Not_Missing(l_dimension_level_id)= FND_API.G_TRUE) THEN
    --SetNULL(l_dim_level_rec,l_dim_level_rec);
    l_dim_level_rec.dimension_level_id := l_dimension_level_id;
    BIS_DIMENSION_LEVEL_PUB.Retrieve_Dimension_Level( p_api_version      => 1.0
		                		   ,p_Dimension_Level_Rec => l_dim_level_rec
						   ,x_Dimension_Level_Rec => l_dim_level_rec
						   ,x_return_status       => l_return_status
						   ,x_error_Tbl           => l_error_tbl
								   );

	   --STEP 4 - assign the correct variable
	  IF (l_measure_rec.dimension1_id = l_dim_level_rec.dimension_id) THEN
		lDimension1 := l_dim_arr(7);
		lDim1Level := l_dimension_level_short_name;
		lDim1LevelValue := l_dimLevelValue_arr(7);
		lDim1_level_id := l_dimension_level_id;

	  ELSIF (l_measure_rec.dimension2_id = l_dim_level_rec.dimension_id) THEN
		lDimension2 := l_dim_arr(7);
		lDim2Level := l_dimension_level_short_name;
		lDim2LevelValue := l_dimLevelValue_arr(7);
		lDim2_level_id := l_dimension_level_id;

	  ELSIF (l_measure_rec.dimension3_id = l_dim_level_rec.dimension_id) THEN
		lDimension3 := l_dim_arr(7);
		lDim3Level := l_dimension_level_short_name;
		lDim3LevelValue := l_dimLevelValue_arr(7);
		lDim3_level_id := l_dimension_level_id;

	  ELSIF (l_measure_rec.dimension4_id = l_dim_level_rec.dimension_id) THEN
		lDimension4 := l_dim_arr(7);
		lDim4Level := l_dimension_level_short_name;
		lDim4LevelValue := l_dimLevelValue_arr(7);
		lDim4_level_id := l_dimension_level_id;

	  ELSIF (l_measure_rec.dimension5_id = l_dim_level_rec.dimension_id) THEN
		lDimension5 := l_dim_arr(7);
		lDim5Level := l_dimension_level_short_name;
		lDim5LevelValue := l_dimLevelValue_arr(7);
		lDim5_level_id := l_dimension_level_id;

	  ELSIF (l_measure_rec.dimension6_id = l_dim_level_rec.dimension_id) THEN
		lDimension6 := l_dim_arr(7);
		lDim6Level := l_dimension_level_short_name;
		lDim6LevelValue := l_dimLevelValue_arr(7);
		lDim6_level_id := l_dimension_level_id;

	  ELSIF (l_measure_rec.dimension7_id = l_dim_level_rec.dimension_id) THEN
		lDimension7 := l_dim_arr(7);
		lDim7Level := l_dimension_level_short_name;
		lDim7LevelValue := l_dimLevelValue_arr(7);
		lDim7_level_id := l_dimension_level_id;

	  END IF;
  END IF;

------------------------------------DONE FOR ALL DIMENSIONS ------------------------

-----------------------GET THE TARGET_LEVEL_ID --------------------------------------------

  BEGIN
   l_target_level_rec.measure_name := l_measure_rec.measure_name;
   l_target_level_Rec.measure_id := l_measure_rec.measure_id;

   --also return to UOM
   l_target_level_rec.Unit_Of_Measure := l_measure_rec.Unit_Of_Measure_Class;

   l_target_level_rec.Dimension1_Level_ID:=  NVL(lDim1_level_id  ,FND_API.G_MISS_NUM);
   l_target_level_rec.Dimension2_Level_ID:= NVL(lDim2_level_id ,FND_API.G_MISS_NUM);
   l_target_level_rec.Dimension3_Level_ID:= NVL(lDim3_level_id ,FND_API.G_MISS_NUM);
   l_target_level_rec.Dimension4_Level_ID:= NVL(lDim4_level_id ,FND_API.G_MISS_NUM);
   l_target_level_rec.Dimension5_Level_ID:= NVL(lDim5_level_id ,FND_API.G_MISS_NUM);
   l_target_level_rec.Dimension6_Level_ID:= NVL(lDim6_level_id ,FND_API.G_MISS_NUM);
   l_target_level_rec.Dimension7_Level_ID:= NVL(lDim7_level_id ,FND_API.G_MISS_NUM);

   x_target_level_id  := BIS_TARGET_LEVEL_PVT.Get_Level_Id_From_Dimlevels(l_target_level_rec);

  EXCEPTION
	WHEN OTHERS THEN
		x_target_level_id := NULL;
  END;


--  x_bind_variables := x_bind_variables || SEPERATOR||x_target_level_id ;
--  x_Ordered_Dimension_Select := ' ?';
 -------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------
-- Append all the dimensions to form the actual string
-- The first 2 dimensions are always quoted, therfore they are always bound

    x_bind_variables := x_bind_variables || SEPERATOR||lDimension1;
    x_bind_count := x_bind_count +1;
    --x_bind_indexes := x_bind_indexes ||SEPERATOR|| x_bind_count;
x_Ordered_Dimension_Select := x_Ordered_Dimension_Select||' :'||x_bind_count;

    x_bind_variables := x_bind_variables || SEPERATOR||lDIm1Level;
    x_bind_count := x_bind_count+1;
    --x_bind_indexes := x_bind_indexes ||SEPERATOR|| x_bind_count;
x_Ordered_Dimension_Select := x_Ordered_Dimension_Select ||', :'||x_bind_count;


-- if the 3rd value is null, then append empty quotes.
if (lDIm1LevelValue is null ) THEN -- put in empty quotes
    x_bind_variables := x_bind_variables || SEPERATOR||'';
    x_bind_count := x_bind_count +1;
    --x_bind_indexes := x_bind_indexes ||SEPERATOR|| x_bind_count;
    x_Ordered_Dimension_Select := x_Ordered_Dimension_Select ||', :'||x_bind_count;
ELSE
  -- if single quote on both sides, then bind, else it is a column name
  if ( substr(lDIm1LevelValue, 1, 1)=''''  OR substr (lDIm1LevelValue, 1, 4) <> 'VBT.' ) then
    x_bind_variables := x_bind_variables || SEPERATOR||replace (lDIm1LevelValue, '''', null); --strip the quotes
    x_bind_count := x_bind_count+1;
    --x_bind_indexes := x_bind_indexes ||SEPERATOR|| x_bind_count;
    x_Ordered_Dimension_Select := x_Ordered_Dimension_Select ||', :'||x_bind_count;
  else
  	x_Ordered_Dimension_Select  :=  x_Ordered_Dimension_Select  ||',' ||lDIm1LevelValue;
  end if;
END IF;

    x_bind_variables := x_bind_variables || SEPERATOR||lDimension2;
    x_bind_count := x_bind_count +1;
    --x_bind_indexes := x_bind_indexes ||SEPERATOR|| x_bind_count;
x_Ordered_Dimension_Select := x_Ordered_Dimension_Select ||', :'||x_bind_count;

    x_bind_variables := x_bind_variables || SEPERATOR||lDIm2Level;
    x_bind_count := x_bind_count+1;
    --x_bind_indexes := x_bind_indexes ||SEPERATOR|| x_bind_count;
x_Ordered_Dimension_Select := x_Ordered_Dimension_Select ||', :'||x_bind_count;


-- if the 3rd value is null, then append empty quotes.
if (lDIm2LevelValue is null ) THEN -- put in empty quotes
    x_bind_variables := x_bind_variables || SEPERATOR||'';
    x_bind_count := x_bind_count +1;
    --x_bind_indexes := x_bind_indexes ||SEPERATOR|| x_bind_count;
    x_Ordered_Dimension_Select := x_Ordered_Dimension_Select ||', :'||x_bind_count;
ELSE
  -- if starts with single quote  then bind, else it is a column name
  if ( substr(lDIm2LevelValue, 1, 1)=''''  OR substr (lDIm2LevelValue, 1, 4) <> 'VBT.' ) then
    x_bind_variables := x_bind_variables || SEPERATOR||replace (lDIm2LevelValue, '''', null) ; --strip the quotes
    x_bind_count := x_bind_count +1;
    --x_bind_indexes := x_bind_indexes ||SEPERATOR|| x_bind_count;
    x_Ordered_Dimension_Select := x_Ordered_Dimension_Select ||', :'||x_bind_count;
  else
  	x_Ordered_Dimension_Select  :=  x_Ordered_Dimension_Select  ||',' ||lDIm2LevelValue;
  end if;
END IF;

    x_bind_variables := x_bind_variables || SEPERATOR||lDimension3;
    x_bind_count := x_bind_count +1;
    --x_bind_indexes := x_bind_indexes ||SEPERATOR|| x_bind_count;
x_Ordered_Dimension_Select := x_Ordered_Dimension_Select ||', :'||x_bind_count;

    x_bind_variables := x_bind_variables || SEPERATOR||lDIm3Level;
    x_bind_count := x_bind_count +1;
    --x_bind_indexes := x_bind_indexes ||SEPERATOR|| x_bind_count;
x_Ordered_Dimension_Select := x_Ordered_Dimension_Select ||', :'||x_bind_count;


-- if the 3rd value is null, then append empty quotes.
if (lDIm3LevelValue is null ) THEN -- put in empty quotes
    x_bind_variables := x_bind_variables || SEPERATOR||'';
    x_bind_count := x_bind_count +1;
    --x_bind_indexes := x_bind_indexes ||SEPERATOR|| x_bind_count;
    x_Ordered_Dimension_Select := x_Ordered_Dimension_Select ||', :'||x_bind_count;
ELSE
  -- if single quote on both sides, then bind, else it is a column name
  if ( substr(lDIm3LevelValue, 1, 1)=''''  OR substr (lDIm3LevelValue, 1, 4) <> 'VBT.' ) then
    x_bind_variables := x_bind_variables || SEPERATOR||replace (lDIm3LevelValue, '''', null) ; --strip the quotes
    x_bind_count := x_bind_count +1;
    --x_bind_indexes := x_bind_indexes ||SEPERATOR|| x_bind_count;
    x_Ordered_Dimension_Select := x_Ordered_Dimension_Select ||', :'||x_bind_count;
  else
  	x_Ordered_Dimension_Select  :=  x_Ordered_Dimension_Select  ||',' ||lDIm3LevelValue;
  end if;
END IF;

    x_bind_variables := x_bind_variables || SEPERATOR||lDimension4;
        x_bind_count := x_bind_count +1;
    --x_bind_indexes := x_bind_indexes ||SEPERATOR|| x_bind_count;
x_Ordered_Dimension_Select := x_Ordered_Dimension_Select ||', :'||x_bind_count;

    x_bind_variables := x_bind_variables || SEPERATOR||lDIm4Level;
        x_bind_count := x_bind_count +1;
    --x_bind_indexes := x_bind_indexes ||SEPERATOR|| x_bind_count;
x_Ordered_Dimension_Select := x_Ordered_Dimension_Select ||', :'||x_bind_count;

-- if the 3rd value is null, then append empty quotes.
if (lDIm4LevelValue is null ) THEN -- put in empty quotes
    x_bind_variables := x_bind_variables || SEPERATOR||'';
        x_bind_count := x_bind_count +1;
    --x_bind_indexes := x_bind_indexes ||SEPERATOR|| x_bind_count;
    x_Ordered_Dimension_Select := x_Ordered_Dimension_Select ||', :'||x_bind_count;
ELSE
  -- if single quote on both sides, then bind, else it is a column name
  if ( substr(lDIm4LevelValue, 1, 1)=''''  OR substr (lDIm4LevelValue, 1, 4) <> 'VBT.' ) then
    x_bind_variables := x_bind_variables || SEPERATOR||replace (lDIm4LevelValue, '''', null) ; --strip the quotes
        x_bind_count := x_bind_count +1;
    --x_bind_indexes := x_bind_indexes ||SEPERATOR|| x_bind_count;
    x_Ordered_Dimension_Select := x_Ordered_Dimension_Select ||', :'||x_bind_count;
  else
  	x_Ordered_Dimension_Select  :=  x_Ordered_Dimension_Select  ||',' ||lDIm4LevelValue;
  end if;
END IF;

    x_bind_variables := x_bind_variables || SEPERATOR||lDimension5;
        x_bind_count := x_bind_count +1;
    --x_bind_indexes := x_bind_indexes ||SEPERATOR|| x_bind_count;
x_Ordered_Dimension_Select := x_Ordered_Dimension_Select ||', :'||x_bind_count;

    x_bind_variables := x_bind_variables || SEPERATOR||lDIm5Level;
        x_bind_count := x_bind_count +1;
    --x_bind_indexes := x_bind_indexes ||SEPERATOR|| x_bind_count;
x_Ordered_Dimension_Select := x_Ordered_Dimension_Select ||', :'||x_bind_count;

-- if the 3rd value is null, then append empty quotes.
if (lDIm5LevelValue is null ) THEN -- put in empty quotes
    x_bind_variables := x_bind_variables || SEPERATOR||'';
        x_bind_count := x_bind_count +1;
    --x_bind_indexes := x_bind_indexes ||SEPERATOR|| x_bind_count;
    x_Ordered_Dimension_Select := x_Ordered_Dimension_Select ||', :'||x_bind_count;
ELSE
  -- if single quote on both sides, then bind, else it is a column name
  if ( substr(lDIm5LevelValue, 1, 1)=''''  OR substr (lDIm5LevelValue, 1, 4) <> 'VBT.' ) then
    x_bind_variables := x_bind_variables || SEPERATOR||replace (lDIm5LevelValue, '''', null) ; --strip the quotes
        x_bind_count := x_bind_count +1;
    --x_bind_indexes := x_bind_indexes ||SEPERATOR|| x_bind_count;
    x_Ordered_Dimension_Select := x_Ordered_Dimension_Select ||', :'||x_bind_count;
  else
  	x_Ordered_Dimension_Select  :=  x_Ordered_Dimension_Select  ||',' ||lDIm5LevelValue;
  end if;
END IF;


    x_bind_variables := x_bind_variables || SEPERATOR||lDimension6;
        x_bind_count := x_bind_count +1;
    --x_bind_indexes := x_bind_indexes ||SEPERATOR|| x_bind_count;
x_Ordered_Dimension_Select := x_Ordered_Dimension_Select ||', :'||x_bind_count;

    x_bind_variables := x_bind_variables || SEPERATOR||lDIm6Level;
        x_bind_count := x_bind_count +1;
    --x_bind_indexes := x_bind_indexes ||SEPERATOR|| x_bind_count;
x_Ordered_Dimension_Select := x_Ordered_Dimension_Select ||', :'||x_bind_count;

-- if the 3rd value is null, then append empty quotes.
if (lDIm6LevelValue is null ) THEN -- put in empty quotes
    x_bind_variables := x_bind_variables || SEPERATOR||'';
        x_bind_count := x_bind_count +1;
    --x_bind_indexes := x_bind_indexes ||SEPERATOR|| x_bind_count;
    x_Ordered_Dimension_Select := x_Ordered_Dimension_Select ||', :'||x_bind_count;
ELSE
  -- if single quote on both sides, then bind, else it is a column name
  if ( substr(lDIm6LevelValue, 1, 1)=''''  OR substr (lDIm6LevelValue, 1, 4) <> 'VBT.' ) then
    x_bind_variables := x_bind_variables || SEPERATOR||replace (lDIm6LevelValue, '''', null) ; --strip the quotes
        x_bind_count := x_bind_count +1;
    --x_bind_indexes := x_bind_indexes ||SEPERATOR|| x_bind_count;
    x_Ordered_Dimension_Select := x_Ordered_Dimension_Select ||', :'||x_bind_count;
  else
  	x_Ordered_Dimension_Select  :=  x_Ordered_Dimension_Select  ||',' ||lDIm6LevelValue;
  end if;
END IF;

    x_bind_variables := x_bind_variables || SEPERATOR||lDimension7;
        x_bind_count := x_bind_count +1;
    --x_bind_indexes := x_bind_indexes ||SEPERATOR|| x_bind_count;
x_Ordered_Dimension_Select := x_Ordered_Dimension_Select ||', :'||x_bind_count;

    x_bind_variables := x_bind_variables || SEPERATOR||lDIm7Level;
        x_bind_count := x_bind_count +1;
    --x_bind_indexes := x_bind_indexes ||SEPERATOR|| x_bind_count;
x_Ordered_Dimension_Select := x_Ordered_Dimension_Select ||', :'||x_bind_count;

-- if the 3rd value is null, then append empty quotes.
if (lDIm7LevelValue is null ) THEN -- put in empty quotes
    x_bind_variables := x_bind_variables || SEPERATOR||'';
        x_bind_count := x_bind_count +1;
    --x_bind_indexes := x_bind_indexes ||SEPERATOR|| x_bind_count;
    x_Ordered_Dimension_Select := x_Ordered_Dimension_Select ||', :'||x_bind_count;
ELSE
  -- if single quote on both sides, then bind, else it is a column name, or there is a dot => it is a column name
  -- this is cos sometimes there is a number
  if ( substr(lDIm7LevelValue, 1, 1)=''''  OR substr (lDIm7LevelValue, 1, 4) <> 'VBT.' ) then
    x_bind_variables := x_bind_variables || SEPERATOR||replace (lDIm7LevelValue, '''', null) ; --strip the quotes
        x_bind_count := x_bind_count +1;
    --x_bind_indexes := x_bind_indexes ||SEPERATOR|| x_bind_count;
    x_Ordered_Dimension_Select := x_Ordered_Dimension_Select ||', :'||x_bind_count;
  else
    IF (instrb (lDIm7LevelValue, '.') >0) then
  	    x_Ordered_Dimension_Select  :=  x_Ordered_Dimension_Select  ||',' ||lDIm7LevelValue;
    else
      x_bind_variables := x_bind_variables || SEPERATOR||lDIm7LevelValue ; --strip the quotes
          x_bind_count := x_bind_count +1;
      --x_bind_indexes := x_bind_indexes ||SEPERATOR|| x_bind_count;
      x_Ordered_Dimension_Select := x_Ordered_Dimension_Select ||', :'||x_bind_count;
    end if;
  end if;
END IF;

END IF; -- if not(l_no_target)
EXCEPTION
	WHEN OTHERS THEN
		x_target_level_id := NULL;
		x_no_target := TRUE;

END order_Dimensions;


procedure GET_TARGET_SELECT(p_user_session_rec in BIS_PMV_SESSION_PVT.SESSION_REC_TYPE,
                            p_ak_region_item_rec in BIS_PMV_METADATA_PVT.AK_REGION_ITEM_REC,
                            p_parameter_tbl in BIS_PMV_PARAMETERS_PVT.PARAMETER_TBL_TYPE,
                            p_report_type in VARCHAR2,
                            p_plan_id in VARCHAR2,
                            p_viewby_dimension in VARCHAR2,
                            p_viewby_attribute2 in VARCHAR2,
                            p_viewby_id_name in VARCHAR2,
                            p_time_from_description in VARCHAR2,
                            p_time_to_description in VARCHAR2,
                            x_target_select out NOCOPY VARCHAR2,
                            x_no_target out NOCOPY boolean,
                            x_bind_variables IN OUT NOCOPY VARCHAR2,
                            --x_bind_indexes IN OUT NOCOPY VARCHAR2,
                            x_bind_count IN OUT NOCOPY NUMBER) is
  l_target_select varchar2(2000);
  l_no_target boolean := false;
  l_dimension_select varchar2(2000);
  l_parameter_rec BIS_PMV_PARAMETERS_PVT.PARAMETER_REC_TYPE;
  l_measure_short_name varchar2(2000);
  l_dimension_level varchar2(2000);
  l_count number;
  l_target_level_id NUMBER;
  l_bind_variables VARCHAR2(2000);
  --l_bind_indexes VARCHAR2(2000);
begin

  l_measure_short_name := p_ak_region_item_rec.attribute2;
  l_count := 0;


  -- SERAO1 , 02/11/02 - added pvt function to order the dimensions once only instead of every time the query is run
  order_Dimensions(
	p_report_type,
 	p_parameter_tbl ,
	p_time_to_description ,
	p_time_from_description ,
	p_viewby_id_name ,
	p_viewby_dimension ,
	p_viewby_attribute2,
	l_measure_short_name,
	l_dimension_select,
	l_target_level_id,
	l_no_target,
        l_bind_variables,
        --l_bind_indexes,
        x_bind_count
  );

  -- The x_bind_count is first sent to the order_dimensions and then constructed here
  -- so numbering is not in the same order, but this does not matter for binding
  -- also the case if there was an excpetion in some place  in order_dimensions.

  if not(l_no_target) then
    l_target_select := l_target_select || 'BIS_PMV_PMF_PVT.get_target_new(';

    -- bind the first few variables
    x_bind_variables := x_bind_variables || SEPERATOR||p_report_type;
        x_bind_count := x_bind_count +1;
    --x_bind_indexes := x_bind_indexes ||SEPERATOR|| x_bind_count;
    l_target_select := l_target_select ||' :'||x_bind_count;

    x_bind_variables := x_bind_variables || SEPERATOR||p_user_session_rec.session_id  ;
        x_bind_count := x_bind_count +1;
    --x_bind_indexes := x_bind_indexes ||SEPERATOR|| x_bind_count;
    l_target_select := l_target_select ||', :'||x_bind_count;

    x_bind_variables := x_bind_variables || SEPERATOR||p_user_session_rec.region_code   ;
        x_bind_count := x_bind_count +1;
    --x_bind_indexes := x_bind_indexes ||SEPERATOR|| x_bind_count;
    l_target_select := l_target_select ||', :'||x_bind_count;

    x_bind_variables := x_bind_variables || SEPERATOR||p_user_session_rec.function_name   ;
        x_bind_count := x_bind_count +1;
    --x_bind_indexes := x_bind_indexes ||SEPERATOR|| x_bind_count;
    l_target_select := l_target_select ||', :'||x_bind_count;

    x_bind_variables := x_bind_variables || SEPERATOR||l_measure_short_name  ;
        x_bind_count := x_bind_count +1;
    --x_bind_indexes := x_bind_indexes ||SEPERATOR|| x_bind_count;
    l_target_select := l_target_select ||', :'||x_bind_count;

    x_bind_variables := x_bind_variables || SEPERATOR||p_plan_id ;
        x_bind_count := x_bind_count +1;
    --x_bind_indexes := x_bind_indexes ||SEPERATOR|| x_bind_count;
    l_target_select := l_target_select ||', :'||x_bind_count;

    x_bind_variables := x_bind_variables || SEPERATOR||l_target_level_id ;
        x_bind_count := x_bind_count +1;
    --x_bind_indexes := x_bind_indexes ||SEPERATOR|| x_bind_count;
    l_target_select := l_target_select ||', :'||x_bind_count ;

    if l_dimension_select is not null and length(l_dimension_select) > 0 then
        l_target_select := l_target_select || ',' || l_dimension_select;
        x_bind_variables := x_bind_variables ||  l_bind_variables;
        --x_bind_indexes := x_bind_indexes ||  l_bind_indexes;
    end if;

    l_target_select := l_target_select || ')';

  end if;

  x_target_select := l_target_select;
  x_no_target := l_no_target;

end GET_TARGET_SELECT;

function GET_DIMENSION_WHERE(p_parameter_rec in BIS_PMV_PARAMETERS_PVT.PARAMETER_REC_TYPE,
                             p_save_region_item_rec in BIS_PMV_METADATA_PVT.SAVE_REGION_ITEM_REC,
                             p_ak_region_rec in BIS_PMV_METADATA_PVT.AK_REGION_REC,
                             p_org_dimension_level in VARCHAR2,
                             p_org_dimension_level_value in VARCHAR2,
                             p_viewby_dimension in VARCHAR2,
                             p_time_id_name in VARCHAR2,
                             p_time_value_name in VARCHAR2,
                             p_region_code in VARCHAR2,
                             p_TM_alias in VARCHAR2,
                             x_bind_variables in OUT NOCOPY VARCHAR2,
                             --x_bind_indexes in OUT NOCOPY VARCHAR2,
                             x_bind_count in out NOCOPY number)
return varchar2 is
  l_dimension_where varchar2(2000);
begin
  if p_parameter_rec.dimension in ('TIME', 'EDW_TIME_M') then
     l_dimension_where := l_dimension_where
                       || BIS_PMV_QUERY_PVT.GET_TIME_WHERE(
                          p_parameter_rec => p_parameter_rec,
                          p_save_region_item_rec => p_save_region_item_rec,
                          p_ak_region_rec => p_ak_region_rec,
                          p_org_dimension_level => p_org_dimension_level,
                          p_org_dimension_level_value => p_org_dimension_level_value,
                          p_viewby_dimension => p_viewby_dimension,
                          p_time_id_name => p_time_id_name,
                          p_time_value_name => p_time_value_name,
                          p_region_code => p_region_code,
                          p_TM_alias => p_TM_alias,
                          x_bind_variables => x_bind_variables,
                          --x_bind_indexes => x_bind_indexes,
                          x_bind_count => x_bind_count);
  else
     l_dimension_where := l_dimension_where ||
BIS_PMV_QUERY_PVT.GET_NON_TIME_WHERE(p_parameter_rec,p_save_region_item_rec,null,
                                     x_bind_variables,x_bind_count);
  end if;
  return l_dimension_where;
end GET_DIMENSION_WHERE;

function GET_TIME_WHERE(p_parameter_rec in BIS_PMV_PARAMETERS_PVT.PARAMETER_REC_TYPE,
                        p_save_region_item_rec in BIS_PMV_METADATA_PVT.SAVE_REGION_ITEM_REC,
                        p_ak_region_rec in BIS_PMV_METADATA_PVT.AK_REGION_REC,
                        p_org_dimension_level in VARCHAR2,
                        p_org_dimension_level_value in VARCHAR2,
                        p_viewby_dimension in VARCHAR2,
                        p_time_id_name in VARCHAR2,
                        p_time_value_name in VARCHAR2,
                        p_region_code in VARCHAR2,
                        p_TM_alias in VARCHAR2,
                        x_bind_variables in OUT NOCOPY VARCHAR2,
                        --x_bind_indexes in OUT NOCOPY VARCHAR2,
                        x_bind_count in out NOCOPY number)
return varchar2 is
  l_time_where varchar2(2000);
  l_org_dimension_level varchar2(2000);
  l_org_dimension_level_value varchar2(2000);
  l_time_dimension_level varchar2(2000);
  l_split_string VARCHAR2(80);
begin
  --jprabhud - 11/06/02 - Bug 2657202 - Added check for single quotes
  if p_org_dimension_level_value is null or upper(p_org_dimension_level_value) = gvAll
     or p_org_dimension_level_value = '''''' then
     l_org_dimension_level := 'TOTAL_ORGANIZATIONS';
     l_org_dimension_level_value := '-1';
  else
     l_org_dimension_level := p_org_dimension_level;
     l_org_dimension_level_value := p_org_dimension_level_value;
  end if;

  l_time_dimension_level := substr(p_save_region_item_rec.attribute2,
                             instr(p_save_region_item_rec.attribute2,'+')+1);

if substr(p_parameter_rec.parameter_name, length(p_parameter_rec.parameter_name)-length('_FROM')+1) = '_FROM' then
  if upper(nvl(p_ak_region_rec.report_type, 'OLTP')) <> 'EDW' and substr(p_org_dimension_level,1,2) <> 'HR'
  and l_time_dimension_level in ('MONTH','QUARTER','YEAR','TOTAL_TIME') then

     if l_org_dimension_level is not null and length(l_org_dimension_level) > 0
     and l_org_dimension_level_value is not null and length(l_org_dimension_level_value) > 0 then
        l_time_where := l_time_where || ' and '||p_TM_alias||'.organization_id ';
        if instrb(l_org_dimension_level_value, ''',''') > 0 then
         l_split_string := '';
         splitMultipleVariables(replace (l_org_dimension_level_value, '''', null), x_bind_variables,
                                x_bind_count, l_split_string);
         l_time_where := l_time_where || ' in ('||l_split_string||')';

          -- l_time_where := l_time_where || ' in (' || l_org_dimension_level_value|| ')';
        else
         x_bind_variables := x_bind_variables || SEPERATOR||l_org_dimension_level_value;
                  x_bind_count := x_bind_count +1;
           --x_bind_indexes := x_bind_indexes ||SEPERATOR|| x_bind_count;
           l_time_where := l_time_where || ' = :'||x_bind_count ;
           -- l_time_where := l_time_where || ' = ' || l_org_dimension_level_value;
        end if;
         x_bind_variables := x_bind_variables || SEPERATOR|| l_org_dimension_level;
         x_bind_count := x_bind_count +1;
         --x_bind_indexes := x_bind_indexes ||SEPERATOR|| x_bind_count;
          l_time_where := l_time_where || ' and '||p_TM_alias||'.organization_type = :'||x_bind_count ;
           -- l_time_where := l_time_where || ' and '||p_TM_alias||'.organization_type = ''' || l_org_dimension_level ||''' ';

     end if;

     if nvl(p_ak_region_rec.disable_viewby,'N') <> 'Y' and p_TM_alias <> 'VBT' then
        if l_org_dimension_level_value is not null and length(l_org_dimension_level_value) > 0
        and p_viewby_dimension = 'TIME' then
           l_time_where := l_time_where || ' and VBT.organization_id';
           if instrb(l_org_dimension_level_value,''',''') > 0 then

            l_split_string := '';
            splitMultipleVariables(replace (l_org_dimension_level_value, '''', null),
                                   x_bind_variables, x_bind_count, l_split_string);
            l_time_where := l_time_where || ' in ('||l_split_string||')';

              --l_time_where := l_time_where || ' in (' || l_org_dimension_level_value || ')';
           else
              x_bind_variables := x_bind_variables || SEPERATOR||l_org_dimension_level_value;
              x_bind_count := x_bind_count +1;
              --x_bind_indexes := x_bind_indexes ||SEPERATOR|| x_bind_count;
              l_time_where := l_time_where || ' = :'||x_bind_count ;
              --l_time_where := l_time_where || ' = ' || l_org_dimension_level_value;
           end if;
             x_bind_variables := x_bind_variables || SEPERATOR||l_org_dimension_level;
             x_bind_count := x_bind_count +1;
             --x_bind_indexes := x_bind_indexes ||SEPERATOR|| x_bind_count;
            l_time_where := l_time_where || ' and VBT.organization_type = :'||x_bind_count;
            --l_time_where := l_time_where || ' and VBT.organization_type = '''|| l_org_dimension_level || '''';
        end if;
     end if;
  end if;

  if p_TM_alias <> 'VBT' then
     l_time_where := l_time_where || ' and SV.' || p_save_region_item_rec.base_column
                                  || ' = '||p_TM_alias||'.' || p_time_id_name;
  end if;

end if;

  if p_parameter_rec.parameter_description is not null
  and length(p_parameter_rec.parameter_description) > 0
  and upper(p_parameter_rec.parameter_description) <> gvAll then

     if (substr(p_region_code, length(p_region_code)-length('_BALANCES')+1) = '_BALANCES'
     and p_viewby_dimension not in ('TIME', 'EDW_TIME_M')) then
        if substr(p_parameter_rec.parameter_name, length(p_parameter_rec.parameter_name)-length('_TO')+1) = '_TO' then
             x_bind_variables := x_bind_variables || SEPERATOR||to_char(p_parameter_rec.period_date, 'DD-MON-YYYY');
                      x_bind_count := x_bind_count +1;
           --x_bind_indexes := x_bind_indexes ||SEPERATOR|| x_bind_count;
           l_time_where := l_time_where || ' and '||p_TM_alias||'.end_date = to_date( :'||x_bind_count||' ,''DD-MON-YYYY'') ';
        end if;
     else
        if substr(p_parameter_rec.parameter_name, length(p_parameter_rec.parameter_name)-length('_FROM')+1) = '_FROM' then
             x_bind_variables := x_bind_variables || SEPERATOR||to_char(p_parameter_rec.period_date,'DD-MON-YYYY');
             x_bind_count := x_bind_count +1;
           --x_bind_indexes := x_bind_indexes ||SEPERATOR|| x_bind_count;
           l_time_where := l_time_where || ' and '||p_TM_alias||'.start_date >= to_date( :'||x_bind_count||' ,''DD-MON-YYYY'') ';
        elsif substr(p_parameter_rec.parameter_name, length(p_parameter_rec.parameter_name)-length('_TO')+1) = '_TO' then
           x_bind_variables := x_bind_variables || SEPERATOR||to_char(p_parameter_rec.period_date,'DD-MON-YYYY');
                    x_bind_count := x_bind_count +1;
           --x_bind_indexes := x_bind_indexes ||SEPERATOR|| x_bind_count;
           l_time_where := l_time_where || ' and '||p_TM_alias||'.end_date <= to_date( :' ||x_bind_count||' ,''DD-MON-YYYY'') ';
        end if;
     end if;

     if instrb(p_parameter_rec.parameter_description,'(') > 0 then
        l_time_where := l_time_where || BIS_PMV_QUERY_PVT.GET_TIME_LABEL_WHERE(p_parameter_rec.parameter_description,
                                                                               p_time_value_name,
                                                                               p_TM_alias,
                                                                               x_bind_variables,
                                                                               --x_bind_indexes,
                                                                               x_bind_count);
     end if;

  end if;

  return l_time_where;
end GET_TIME_WHERE;

function GET_TIME_LABEL_WHERE(p_parameter_description in VARCHAR2,
                              p_time_value_name in VARCHAR2,
                              p_TM_alias in VARCHAR2,
                              x_bind_variables in OUT NOCOPY VARCHAR2,
                              --x_bind_indexes in OUT NOCOPY VARCHAR2,
                              x_bind_count in out NOCOPY number)
return varchar2 is
  l_time_label_where varchar2(2000);
  l_start_pos number;
  l_end_pos number;
  l_time_label varchar2(2000);
begin
  l_start_pos := instr(p_parameter_description,'(');
  l_end_pos := instr(p_parameter_description,')');
  l_time_label := substr(p_parameter_description, l_start_pos, l_end_pos-l_start_pos+1);
  if l_time_label is not null and length(l_time_label) > 0 then
      x_bind_variables := x_bind_variables || SEPERATOR||'%'||l_time_label||'%';
      x_bind_count := x_bind_count +1;
      --x_bind_indexes := x_bind_indexes || SEPERATOR|| x_bind_count;
     l_time_label_where := ' and '||p_TM_alias||'.'||p_time_value_name||' like :'||x_bind_count;
  end if;
  return l_time_label_where;
end GET_TIME_LABEL_WHERE;

function GET_NON_TIME_WHERE(p_parameter_rec in BIS_PMV_PARAMETERS_PVT.PARAMETER_REC_TYPE,
                            p_save_region_item_rec in BIS_PMV_METADATA_PVT.SAVE_REGION_ITEM_REC,
                            p_source in varchar2 default null,
                            x_bind_variables in OUT NOCOPY VARCHAR2,
                            --x_bind_indexes in OUT NOCOPY VARCHAR2,
                            x_bind_count in out NOCOPY number)
return varchar2 is
  l_non_time_where varchar2(2000);
  l_split_string VARCHAR2(80);
begin
  if p_parameter_rec.parameter_description is not null
  and length(p_parameter_rec.parameter_description) > 0
  and upper(p_parameter_rec.parameter_description) <> gvAll then
     if (p_source = 'FOR_DBC') then
          l_non_time_where := l_non_time_where || ' and ' || p_save_region_item_rec.base_column || ' ';
     else
          l_non_time_where := l_non_time_where || ' and SV.' || p_save_region_item_rec.base_column || ' ';
     end if;
     if p_parameter_rec.operator is not null and length(p_parameter_rec.operator) > 0 then
        if instrb(p_parameter_rec.parameter_value, ''',''') > 0 then
           if ltrim(rtrim(p_parameter_rec.operator)) = '!=' then
              l_non_time_where := l_non_time_where || 'not in ';
           elsif ltrim(rtrim(p_parameter_rec.operator)) = '=' then
              l_non_time_where := l_non_time_where || ' in ';
           else
              l_non_time_where := l_non_time_where || p_parameter_rec.operator || ' ';
           end if;

          l_split_string := '';
          splitMultipleVariables(replace (p_parameter_rec.parameter_value, '''', null),
                                 x_bind_variables, x_bind_count, l_split_string);
          l_non_time_where := l_non_time_where || '('||l_split_string||')';
        else
            x_bind_variables := x_bind_variables || SEPERATOR||p_parameter_rec.parameter_value;
            x_bind_count := x_bind_count +1;
            --x_bind_indexes := x_bind_indexes ||SEPERATOR|| x_bind_count;
           l_non_time_where := l_non_time_where||p_parameter_rec.operator||' :'||x_bind_count;
        end if;
     else
      if instrb(p_parameter_rec.parameter_value, ''',''') > 0 then
          l_split_string := '';
          splitMultipleVariables(replace (p_parameter_rec.parameter_value, '''', null),
                                 x_bind_variables,x_bind_count, l_split_string);
          l_non_time_where := l_non_time_where || ' in ('||l_split_string||')';
      else
         -- replace the quotes replace
         -- x_bind_variables := x_bind_variables || SEPERATOR||p_parameter_rec.parameter_value;
         x_bind_variables := x_bind_variables || SEPERATOR|| replace (p_parameter_rec.parameter_value, '''', null); --strip the quotes
         x_bind_count := x_bind_count +1;
         --x_bind_indexes := x_bind_indexes || SEPERATOR|| x_bind_count;
         l_non_time_where := l_non_time_where || ' = :'||x_bind_count;
      end if;
     end if;
  end if;
  return l_non_time_where;
end GET_NON_TIME_WHERE;

function GET_NON_DIMENSION_WHERE(p_parameter_rec in BIS_PMV_PARAMETERS_PVT.PARAMETER_REC_TYPE,
                                 p_save_region_item_rec in BIS_PMV_METADATA_PVT.SAVE_REGION_ITEM_REC,
                                 x_bind_variables in OUT NOCOPY VARCHAR2,
                                 --x_bind_indexes in OUT NOCOPY VARCHAR2,
                                 x_bind_count in out NOCOPY number)
return varchar2 is
  l_non_dimension_where varchar2(2000);
begin
  if p_parameter_rec.parameter_description is not null
  and length(p_parameter_rec.parameter_description) > 0
  and p_save_region_item_rec.base_column is not null
  and length(p_save_region_item_rec.base_column) > 0 then
    if p_parameter_rec.operator is not null and length(p_parameter_rec.operator) > 0 then
       x_bind_variables := x_bind_variables || SEPERATOR||p_parameter_rec.parameter_description;
                x_bind_count := x_bind_count +1;
       --x_bind_indexes := x_bind_indexes || SEPERATOR||x_bind_count;
       l_non_dimension_where := l_non_dimension_where || ' and SV.' || p_save_region_item_rec.base_column || ' '
       || p_parameter_rec.operator || ' :' ||x_bind_count;
       --|| p_parameter_rec.operator || ' ' || p_parameter_rec.parameter_description;
    else
       if p_save_region_item_rec.data_type = 'D' then
         x_bind_variables := x_bind_variables || SEPERATOR||p_parameter_rec.parameter_description;
                  x_bind_count := x_bind_count +1;
          --x_bind_indexes := x_bind_indexes || SEPERATOR||x_bind_count;
          l_non_dimension_where := l_non_dimension_where || ' and upper(ltrim(rtrim(to_char(SV.'
          || p_save_region_item_rec.base_column || ',''DD-MON-YY'')))) = upper(ltrim(rtrim(to_char(to_'||'date(:'||x_bind_count||'), ''DD-MON-YY'')))) ';
        --|| p_save_region_item_rec.base_column || ',''DD-MON-YY'')))) = upper(ltrim(rtrim(to_char(to_date('|| p_parameter_rec.parameter_description || '), ''DD-MON-YY'')))) ';
       else
           x_bind_variables := x_bind_variables || SEPERATOR||p_parameter_rec.parameter_description;
                    x_bind_count := x_bind_count +1;
          --x_bind_indexes := x_bind_indexes || SEPERATOR||x_bind_count;
          l_non_dimension_where := l_non_dimension_where || ' and upper(ltrim(rtrim(SV.'
          || p_save_region_item_rec.base_column || '))) like upper(ltrim(rtrim( :'||x_bind_count||' ))) ';
          --|| p_save_region_item_rec.base_column || '))) like upper(ltrim(rtrim('''
          --|| p_parameter_rec.parameter_description || '''))) ';
       end if;
    end if;
  end if;
  return l_non_dimension_where;
end GET_NON_DIMENSION_WHERE;

function GET_LOV_WHERE(p_parameter_tbl in BIS_PMV_PARAMETERS_PVT.PARAMETER_TBL_TYPE,
                       p_where_clause in VARCHAR2,
                       p_region_code in VARCHAR2 )
return varchar2 is
  l_lov_where varchar2(2000) := p_where_clause;
  -- Fix for bug 2763327
  -- Initialize l_index1 and l_index2
  l_index1 number := 1;
  l_index2 number := 1;
  l_attribute_code varchar2(2000);
  l_attribute2 varchar2(2000);
  l_parameter_name varchar2(2000);
  l_parameter_rec BIS_PMV_PARAMETERS_PVT.PARAMETER_REC_TYPE;
  l_parameter_value varchar2(2000);
  l_parameter_description varchar2(2000);
begin
-- Fix for bug 2763327
-- Added white space before appending the retrieved lov where
l_lov_where := ' ' || p_where_clause ;

  loop
      l_index1 := instr(l_lov_where, '{', l_index1, 1);
      l_index2 := instr(l_lov_where, '}', l_index1+1, 1);
      if l_index1 = 0 or l_index2 = 0 then
          exit;
      end if;
      l_attribute_code := substr(l_lov_where, l_index1+1, l_index2-l_index1-1);
      l_attribute2 := BIS_PARAMETER_VALIDATION.getDimensionForAttribute(rtrim(ltrim(l_attribute_code)), p_region_code);
      l_parameter_name := nvl(l_attribute2, l_attribute_code);

      if p_parameter_tbl.COUNT > 0 then
         for i in p_parameter_tbl.FIRST..p_parameter_tbl.LAST loop
           l_parameter_rec := p_parameter_tbl(i);
           if l_parameter_rec.parameter_name = l_parameter_name then
              l_parameter_value := l_parameter_rec.parameter_value;
              l_parameter_description := l_parameter_rec.parameter_description;
              exit;
           end if;
         end loop;
      end if;

      if l_attribute2 is not null then
         l_lov_where := replace(l_lov_where, '{'||l_attribute_code||'}','('||l_parameter_value||')');
      else
         l_lov_where := replace(l_lov_where, '{'||l_attribute_code||'}','('||l_parameter_description||')');
      end if;

      l_index1 := l_index2+1;
  end loop;

  l_lov_where := replace(l_lov_where, ' and ', ' and vbt.');
  l_lov_where := replace(l_lov_where, ' AND ', ' and vbt.');
  l_lov_where := replace(l_lov_where, ' And ', ' and vbt.');
  l_lov_where := replace(l_lov_where, ' or ', ' or vbt.');
  l_lov_where := replace(l_lov_where, ' OR ', ' or vbt.');
  l_lov_where := replace(l_lov_where, ' Or ', ' or vbt.');
  l_lov_where := replace(l_lov_where, ' in (All)',' is not null');
  l_lov_where := replace(l_lov_where, ' IN (All)',' is not null');
  l_lov_where := replace(l_lov_where, ' In (All)',' is not null');
  l_lov_where := replace(l_lov_where, ' in ()',' is not null');
  l_lov_where := replace(l_lov_where, ' IN ()',' is not null');
  l_lov_where := replace(l_lov_where, ' In ()',' is not null');

  return l_lov_where;

end GET_LOV_WHERE;

function GET_GROUP_BY(p_disable_viewby in VARCHAR2,
                      p_viewby_id_name in VARCHAR2,
                      p_viewby_value_name in VARCHAR2,
                      p_viewby_dimension in VARCHAR2,
                      p_viewby_dimension_level in VARCHAR2,
                      p_extra_groupby in VARCHAR2,
                      p_user_groupby in VARCHAR2,
                      p_user_orderby in VARCHAR2,
                      p_no_target in BOOLEAN DEFAULT TRUE)
return varchar2 is
  l_group_by varchar2(2000);
begin

  if p_disable_viewby <> 'Y' then
     l_group_by := 'VBT.' || p_viewby_value_name;

     if not(p_no_target) then
        l_group_by := l_group_by || ', VBT.' || p_viewby_id_name;
     end if;

     if p_extra_groupby is not null and length(p_extra_groupby) > 0 then
        l_group_by := l_group_by || ', SV.' || p_extra_groupby;
     end if;

     if p_viewby_dimension in ('TIME', 'EDW_TIME_M') and p_viewby_dimension_level <> 'EDW_TIME_A' then
        l_group_by := l_group_by || ', VBT.start_date';
     end if;
  end if;

  if p_user_groupby is not null and length(p_user_groupby) > 0 then
     if p_disable_viewby <> 'Y' then
        l_group_by := l_group_by || ', ';
     end if;
     l_group_by := l_group_by || p_user_groupby;
     if p_user_orderby is not null and length(p_user_orderby) > 0 then
        l_group_by := l_group_by || ', ' || p_user_orderby;
     end if;
  end if;

  return l_group_by;
end GET_GROUP_BY;

function GET_ORDER_BY(p_disable_viewby in VARCHAR2,
                      p_sort_attribute in VARCHAR2,
                      p_sort_direction in VARCHAR2,
                      p_viewby_dimension in VARCHAR2,
                      p_viewby_dimension_level in VARCHAR2,
                      p_default_sort_attribute in VARCHAR2,
                      p_user_orderby in VARCHAR2)
return varchar2 is
  l_order_by varchar2(2000);
  l_sort_attribute varchar2(2000) := p_sort_attribute;
  l_sort_direction varchar2(2000) := p_sort_direction;
  l_nls_sort_type  VARCHAR2(30);
begin

  if p_sort_direction is null or length(p_sort_direction) = 0 then
     l_sort_direction := 'ASC';
  else
     l_sort_direction := p_sort_direction;
  end if;

  if p_sort_attribute is null or length(p_sort_attribute) = 0 then
     l_sort_attribute := p_default_sort_attribute; -- cannot be null
  else
     l_sort_attribute := p_sort_attribute || ' '|| l_sort_direction;
  end if;

 --serao- 07/31/2002 - bug 2460600 - check the final sort attribute for viewby
  if (p_disable_viewby <> 'Y' and rtrim(ltrim(nvl(p_sort_attribute, l_sort_attribute))) = 'VIEWBY') then
     if p_viewby_dimension in ('TIME', 'EDW_TIME_M') and p_viewby_dimension_level <> 'EDW_TIME_A' then
        l_sort_attribute := 'VBT.start_date '|| l_sort_direction;
     else --NLS Sort for VIEWBY
        l_nls_sort_type := fnd_profile.value('ICX_NLS_SORT');
        IF l_nls_sort_type IS NOT NULL THEN
          l_sort_attribute := ' NLSSORT('||'VIEWBY'||', ''NLS_SORT = ' || l_nls_sort_type ||''') ' || l_sort_direction;
        END IF;
     end if;
  end if;

  l_order_by := l_sort_attribute;

  if p_user_orderby is not null and length(p_user_orderby) > 0 then
     l_order_by := l_order_by || ', ' || p_user_orderby;
  end if;

  return l_order_by;

end GET_ORDER_BY;

function GET_USER_STRING(p_user_string in VARCHAR2)
return varchar2 is
  l_user_string varchar2(2000) := p_user_string;
  l_user_function varchar2(2000);
begin
  if substr(p_user_string,1,1)='[' and substr(p_user_string,length(p_user_string),1)=']' then
     l_user_function := 'SELECT ' || substr(p_user_string, 2, length(p_user_string)-2) || ' FROM DUAL';
     execute immediate l_user_function into l_user_string;
  end if;
  l_user_string := replace(l_user_string, '<VIEW_NAME.>', 'SV.');
  return l_user_string;
end GET_USER_STRING;
procedure sort
(pSortNameTbl   in out NOCOPY BISVIEWER.t_char
,pSortValueTbl  in out NOCOPY BISVIEWER.t_char
)
IS
  l_temp_value   varchar2(2000);
  l_temp_name    varchar2(2000);
BEGIN
   for i in pSortNameTbl.FIRST+1..pSortNameTbl.LAST loop
      l_temp_name := pSortNameTbl(i);
      l_temp_value := pSortValueTbl(i);
      for j in pSortNameTbl.FIRST..(i-1) loop
          if (pSortNameTbl(j) > l_temp_name) then
              pSortNameTbl(j+1) := pSortNameTbl(j);
              pSortNameTbl(j) := l_temp_name;
              pSortValueTbl(j+1) := pSortValueTbl(j);
              pSortValueTbl(j) := l_temp_value;
           end if;
       end loop;
   end loop;
END;

procedure get_customized_order_by(p_viewby in varchar2,
                      p_attribute_code in varchar2,
                      p_region_code in varchar2,
                      p_user_id  in varchar2,
                      p_customization_code in varchar2,
                      p_main_order_by in out NOCOPY varchar2,
                      p_first_order_by in out NOCOPY varchar2,
                      p_second_order_by in out NOCOPY varchar2)
 is
  cursor c_orderby(cp_cust_code varchar2, cp_attribute_code varchar2, cp_property1 varchar2, cp_property2 varchar2) is
    select property_varchar2_value,property_name,attribute_code
    from ak_custom_region_items_vl
    where property_name in (cp_property1,cp_property2)
    and region_code =  p_region_code
    and customization_code = cp_cust_code
    and attribute_code = cp_attribute_code
    order by property_name;
  l_cust_code      varchar2(100);
  main_attribute_code   varchar2(100);
  first_attribute_code  varchar2(100);
  second_attribute_code varchar2(100);
  l_property_name   varchar2(80);
  l_property_value  varchar2(80);
  l_attribute_code  varchar2(80);
  l_user_id        varchar2(80);
begin
  --Performance Fix 2463060 adding order direction and initial sort sequence as bind variables
  for order_clause in  c_orderby(p_customization_code,p_attribute_code,'ORDER_DIRECTION','INITIAL_SORT_SEQUENCE') loop
     l_property_name  :=  order_clause.property_name;
     l_property_value :=  order_clause.property_varchar2_value;
     if l_property_name ='INITIAL_SORT_SEQUENCE' then
       if p_viewby = 'Y' then
         if l_property_value = '0' then
            p_main_order_by := ' '|| ' VIEWBY '||' ';
            main_attribute_code := p_attribute_code;
         elsif l_property_value = '1' then
            p_first_order_by := ' , '|| ' VIEWBY '||' ';
            first_attribute_code := p_attribute_code;
         elsif l_property_value = '2' then
            p_second_order_by := ' , '||' VIEWBY ' ||' ';
            second_attribute_code := p_attribute_code;
         end if;
       else
         if l_property_value = '0' then
            p_main_order_by := ' '|| p_attribute_code ||' ';
            main_attribute_code := p_attribute_code;
         elsif l_property_value = '1' then
            p_first_order_by := ' , '|| p_attribute_code ||' ';
            first_attribute_code := p_attribute_code;
         elsif l_property_value = '2' then
            p_second_order_by := ' , '|| p_attribute_code ||' ';
            second_attribute_code := p_attribute_code;
         end if;
       end if;
     end if;
     if l_property_name ='ORDER_DIRECTION' then
       if p_attribute_code = main_attribute_code and l_property_value = 'ascending' then
          p_main_order_by := p_main_order_by||' ASC ';
       elsif p_attribute_code = main_attribute_code then
          p_main_order_by := p_main_order_by||' DESC ';
       elsif p_attribute_code = first_attribute_code and l_property_value = 'ascending' then
          p_first_order_by := p_first_order_by||' ASC ';
       elsif p_attribute_code = first_attribute_code then
          p_first_order_by := p_first_order_by||' DESC ';
       elsif p_attribute_code = second_attribute_code and l_property_value = 'ascending' then
          p_second_order_by := p_second_order_by||' ASC ';
       elsif p_attribute_code = first_attribute_code then
          p_second_order_by := p_second_order_by||' DESC ';
       end if;
     end if;
  end loop;

end get_customized_order_by;

/** Procedure to retun thre order by clause for given metadata and parmeters */
procedure get_order_by_clause(
  p_source         in varchar2 DEFAULT 'REPORT',
  pAKRegionRec in BIS_PMV_METADATA_PVT.AK_REGION_REC,
  pUserSession  in BIS_PMV_SESSION_PVT.SESSION_REC_TYPE,
  p_sort_attribute in VARCHAR2 DEFAULT NULL,
  p_sort_direction in VARCHAR2 DEFAULT NULL,
  p_viewby_attribute2  IN VARCHAR2,
  p_viewby_dimension   IN VARCHAR2,
  p_viewby_dimension_level  In VARCHAR2,
  x_order_by OUT NOCOPY VARCHAR2

) IS
    l_ak_region_item_rec BIS_PMV_METADATA_PVT.AK_REGION_ITEM_REC;
    l_view_by_attr2                VARCHAR2(80);
    l_view_by_attr_code            VARCHAR2(80);
    l_main_order_by  VARCHAR2(100) :=NULL;
    l_first_order_by  VARCHAR2(100) := NULL;
    l_second_order_by  VARCHAR2(100) := NULL;
    l_def_sort_attr_tbl    BISVIEWER.t_char;
    l_Def_sort_seq_tbl     BISVIEWER.t_Char;
    l_sort_attr_code       VARCHAR2(150);
--changed l_sort_attr_code size from 30 to 150 for bugfix 2598917
    l_def_sort_count       NUMBER := 1;
    l_default_sort_attribute VARCHAR2(2000) := '';
    l_first_attr_code      VARCHAR2(2000);
    l_first_time BOOLEAN := TRUE;
    l_sort_attr_type       VARCHAR2(2000);
    l_sel_sort_attribute   VARCHAR2(2000);
    l_user_order_by VARCHAR2(2000);

    l_nls_sort_type VARCHAR2(30); -- nbarik 19-SEP-2002 NLS Sort for VARCHAR2


-- this is for the order gy clause which is independent of the parameter data
CURSOR ak_region_item_cursor (cpRegionCode VARCHAR2) IS
SELECT attribute1 attribute_type,
       attribute_code,
       attribute2,
       attribute3 base_column,
       attribute4 where_clause,
       attribute15 lov_table,
       attribute9 aggregate_function,
       attribute14 data_type,
       attribute7 data_format,
       order_sequence,
       order_direction,
       node_query_flag
       ,node_display_flag --2371922
FROM   AK_REGION_ITEMS
WHERE  region_code = cpRegionCode
AND nested_region_code is null
AND node_query_flag = 'N'
AND ( order_direction IS NOT NULL OR order_sequence IS NOT NULL ) --Bug Fix 2605121
ORDER BY display_sequence;

--serao - 2622281 - adding a new cursor which will select if non-view-by
CURSOR ak_item_non_viewby_cursor (cpRegionCode VARCHAR2) IS
SELECT attribute1 attribute_type,
       attribute_code,
       attribute2,
       attribute3 base_column,
       attribute4 where_clause,
       attribute15 lov_table,
       attribute9 aggregate_function,
       attribute14 data_type,
       attribute7 data_format,
       order_sequence,
       order_direction,
       node_query_flag
       ,node_display_flag --2371922
FROM   AK_REGION_ITEMS
WHERE  region_code = cpRegionCode
AND nested_region_code is null
AND node_query_flag = 'N'
ORDER BY display_sequence;

BEGIN

  l_nls_sort_type := fnd_profile.value('ICX_NLS_SORT'); -- nbarik 19-SEP-2002 NLS Sort for VARCHAR2

  --serao - 2622281 - adding a new cursor which will select if non-view-by
  IF nvl(pAKRegionRec.disable_viewby,'N') <>  'Y' THEN
    IF ak_region_item_cursor%ISOPEN THEN
      CLOSE ak_region_item_cursor;
    END IF;
    OPEN ak_region_item_cursor(pUserSession.region_code);
  ELSE
    IF ak_item_non_viewby_cursor%ISOPEN THEN
      CLOSE ak_item_non_viewby_cursor;
    END IF;
    OPEN ak_item_non_viewby_cursor(pUserSession.region_code);
  END IF;

  LOOP

    --serao - 2622281 - adding a new cursor which will select if non-view-by
    IF nvl(pAKRegionRec.disable_viewby,'N') <>  'Y' THEN
      FETCH ak_region_item_cursor INTO l_ak_region_item_rec;
      EXIT WHEN ak_region_item_cursor%NOTFOUND;
    ELSE
      FETCH ak_item_non_viewby_cursor INTO l_ak_region_item_rec;
      EXIT WHEN ak_item_non_viewby_cursor%NOTFOUND;
    END IF;

      IF (p_Sort_Attribute IS NOT NULL AND p_Sort_Attribute=l_ak_region_item_Rec.attribute_code) THEN
       l_sort_attr_type := l_ak_region_item_rec.data_type;
      END IF;

      IF (l_first_time) THEN
         IF  nvl(pAKRegionRec.disable_viewby,'N') <>  'Y' THEN
           l_first_attr_code := 'VIEWBY';
           l_first_time := false;
--         ELSIF (l_ak_Region_item_rec.node_query_flag = 'N') THEN
         ELSIF (l_ak_Region_item_rec.node_query_flag = 'N' and  l_ak_Region_item_rec.node_display_flag = 'Y') THEN
           IF (l_ak_region_item_rec.data_type = 'D') THEN
              l_first_attr_code := l_ak_region_item_rec.attribute_code;
           ELSIF (l_ak_region_item_rec.data_type = 'C') THEN --NLS Sort for VARCHAR2
              IF l_nls_sort_type IS NOT NULL THEN
                l_first_attr_code := ' NLSSORT('||l_ak_region_item_rec.attribute_code||', ''NLS_SORT = ' || l_nls_sort_type ||''') ';
              ELSE
                l_first_attr_code := l_ak_region_item_rec.attribute_code;
              END IF;
           ELSE
              l_first_attr_code := l_ak_region_item_rec.attribute_code;
           END IF;
           l_first_time := false;
         END IF;
      END IF;

   if gvCode is not null and length(gvCode) > 0 then

      IF l_ak_region_item_rec.attribute2 = p_viewby_attribute2 then
         -- for the view by attribute
         BIS_PMV_QUERY_PVT.get_customized_order_by(p_viewby =>'Y',
                        p_attribute_code =>l_ak_region_item_rec.attribute_code,
                        p_region_code => pUserSession.region_code,
                        p_user_id     => pUserSession.user_id,
                        p_customization_code =>gvCode,
                        p_main_order_by => l_main_order_by,
                        p_first_order_by => l_first_order_by,
                        p_second_order_by => l_second_order_by);
      END IF;

      -- for the measure
      IF (l_ak_region_item_rec.attribute_type = 'MEASURE'
       or l_ak_region_item_rec.attribute_type = 'MEASURE_NOTARGET'
            OR (l_ak_region_item_rec.attribute_type is null AND l_ak_region_item_rec.node_query_flag = 'N')) THEN

         BIS_PMV_QUERY_PVT.get_customized_order_by(p_viewby =>'N',
                        p_attribute_code =>l_ak_region_item_rec.attribute_code,
                        p_region_code => pUserSession.region_code,
                        p_user_id     => pUserSession.user_id,
                        p_customization_code =>gvCode,
                        p_main_order_by => l_main_order_by,
                        p_first_order_by => l_first_order_by,
                        p_second_order_by => l_second_order_by);
      END IF;

   end if;

        --Set up the order by info
      IF (l_ak_region_item_rec.order_sequence is not null AND
        l_ak_region_item_rec.order_Sequence < 100)  AND
        l_ak_region_item_rec.node_query_flag = 'N' THEN

          IF (l_ak_region_item_rec.data_type = 'C') THEN -- nbarik 19-SEP-2002 NLS Sort for VARCHAR2
             IF l_nls_sort_type IS NOT NULL THEN
               l_sort_attr_code := ' NLSSORT('||l_ak_region_item_rec.attribute_code||', ''NLS_SORT = ' || l_nls_sort_type ||''') ';
             ELSE
               l_sort_attr_code := l_ak_region_item_rec.attribute_code;
             END IF;
          ELSIF (l_ak_region_item_rec.data_type = 'D') THEN
             l_sort_attr_code := l_ak_region_item_rec.attribute_code;
          ELSE
           l_sort_attr_code := l_ak_region_item_rec.attribute_code;
          END IF;
          l_def_sort_attr_tbl(l_def_sort_count) := l_sort_attr_code||'  '||
          l_ak_region_item_rec.order_direction;
          l_Def_sort_seq_tbl(l_def_sort_count) := l_ak_region_item_rec.order_sequence;
          l_def_sort_count := l_def_sort_count+1;
      END IF;

  END LOOP;

  IF (l_first_attr_code IS NULL  AND nvl(pAKRegionRec.disable_viewby,'N') <>  'Y' )THEN
    l_first_attr_code := 'VIEWBY';
  END IF;

  IF l_main_order_by IS NULL THEN

    IF (l_def_sort_attr_tbl.COUNT > 0) THEN
      --Sort the specified order
      IF (l_def_sort_attr_tbl.COUNT > 1) THEN
         BIS_PMV_QUERY_PVT.sort(l_def_sort_seq_tbl, l_def_sort_attr_tbl);
      END IF;
      FOR i in l_def_sort_seq_tbl.FIRST..l_def_sort_seq_tbl.LAST LOOP
         l_default_sort_attribute := ' '|| l_default_sort_attribute || l_def_sort_attr_tbl(i)||',';
      END LOOP;
      l_default_sort_attribute := substr(l_default_sort_attribute, 1, length(l_default_sort_attribute)-1);
    ELSE
       l_default_sort_attribute := l_first_attr_code;
    END IF;

      --construct order by string
     IF (p_source <> 'ACTUAL') THEN
        IF (l_sort_attr_type = 'C' AND p_sort_attribute IS NOT NULL) THEN -- nbarik 19-SEP-2002 NLS Sort for VARCHAR2
         IF l_nls_sort_type IS NOT NULL THEN
           l_sel_sort_attribute := ' NLSSORT('||p_sort_Attribute||', ''NLS_SORT = ' || l_nls_sort_type ||''') ';
         ELSE
           l_sel_sort_attribute := p_sort_attribute;
         END IF;
       ELSIF (l_sort_attr_type = 'D' and p_sort_attribute is not null) then
         l_sel_sort_attribute := p_sort_Attribute;
       ELSE
         l_sel_sort_attribute := p_sort_attribute;
       END IF;

       IF pAKRegionRec.user_orderby IS NOT NULL THEN
        l_user_order_by := BIS_PMV_QUERY_PVT.GET_USER_STRING(pAKRegionRec.user_orderby);
       END IF;

       --x_order_by := ' ORDER BY ';
       x_order_by := x_order_by
             || BIS_PMV_QUERY_PVT.GET_ORDER_BY
               (p_disable_viewby => nvl(pAKRegionRec.disable_viewby,'N'),
                p_sort_attribute => l_sel_sort_attribute,
                p_sort_direction => p_sort_direction,
                p_viewby_dimension => p_viewby_dimension,
                p_viewby_dimension_level => p_viewby_dimension_level,
                p_default_sort_attribute => l_default_sort_attribute,
                p_user_orderby => l_user_order_by);
      END IF;

    ELSE
      x_order_by := l_main_order_by;
   END IF ;  -- if main_order_by
EXCEPTION
 WHEN OTHERS THEN
      NULL;
END get_order_by_clause;

/** Procedure to replace the start and end index substitution variables */
--serao- bug 2642688 -10/25/02 - use bind variables
procedure replaceStartEndIndex (
  p_custom_sql IN OUT NOCOPY VARCHAR2,
  p_lower_bound In INTEGER,
  p_upper_bound In INTEGER,
  p_original_sql in varchar2,
  x_bind_variables IN OUT NOCOPY VARCHAR2,
  x_plsql_bind_variables IN OUT NOCOPY VARCHAR2,
  x_bind_indexes IN OUT NOCOPY VARCHAR2,
 x_bind_datatypes IN OUT NOCOPY VARCHAR2,
  x_bind_count IN OUT NOCOPY NUMBER
) IS
l_index NUMBER;
BEGIN


   l_index := instrb(p_original_sql, START_INDEX_SUBST_VAR);
   if (l_index > 0) then

          replace_with_bind_variables
          (p_search_string => START_INDEX_SUBST_VAR,
           p_bind_value => p_lower_bound,
           p_bind_Datatype => BIS_PMV_PARAMETERS_PUB.INTEGER_BIND,
           p_initial_index => l_index,
           p_bind_function => NULL,
           p_bind_to_date => 'N',
           p_original_sql => p_original_sql,
           x_custom_sql => p_custom_sql,
           x_bind_variables => x_bind_variables,
           x_plsql_bind_variables => x_plsql_bind_variables,
           x_bind_indexes => x_bind_indexes,
           x_bind_datatypes => x_bind_datatypes,
           x_bind_count => x_bind_count);
   END IF;


   l_index := instrb(p_original_sql, END_INDEX_SUBST_VAR);
   if (l_index > 0) then

          replace_with_bind_variables
          (p_search_string => END_INDEX_SUBST_VAR,
           p_bind_value => p_upper_bound,
           p_bind_Datatype => BIS_PMV_PARAMETERS_PUB.INTEGER_BIND,
           p_initial_index => l_index,
           p_bind_function => NULL,
           p_bind_to_date => 'N',
           p_original_sql => p_original_sql,
           x_custom_sql => p_custom_sql,
           x_bind_variables => x_bind_variables,
           x_plsql_bind_variables => x_plsql_bind_variables,
           x_bind_indexes => x_bind_indexes,
           x_bind_datatypes => x_bind_datatypes,
           x_bind_count => x_bind_count);
   END IF;

END replaceStartEndIndex;

/** function to return the description of the param from fnd lookup */
FUNCTION getParameterAcronym (
  p_lookup_type IN VARCHAR2,
  p_Parameter_name IN VARCHAR2
) RETURN VARCHAR2 IS
   l_Dimlevel_Acronym            varchar2(2000);

   CURSOR c_lookups IS
   SELECt description
   FROM fnd_lookup_values_vl
   WHERE lookup_Type = p_lookup_type and
   (lookup_code||'_FROM' = p_Parameter_name or
   lookup_code||'_TO' = p_Parameter_name);
BEGIN

  IF c_lookups%ISOPEN then
    CLOSE c_lookups;
  END IF;
  OPEN c_lookups;
  FETCH c_lookups into l_dimlevel_acronym;
  CLOSE c_lookups;
  RETURN l_dimlevel_acronym;
END getParameterAcronym ;

/** Procedure to replace the view by parameter for a given user session rec*/
PROCEDURE process_custom_view_by(
  pUserSession  in BIS_PMV_SESSION_PVT.SESSION_REC_TYPE,
  pViewByParam IN VARCHAR2
) IS
  l_return_status VARCHAR2(80);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(2000);
  l_parameter_rec BIS_PMV_PARAMETERS_PVT.parameter_rec_type ;
  l_user_session_rec BIS_PMV_SESSION_PVT.SESSION_REC_TYPE := pUserSession;
BEGIN

  l_user_session_rec.page_id := null;
  --delete the existing view by
  if (l_user_session_Rec.schedule_id is not null) then
    BIS_PMV_PARAMETERS_PVT.DELETE_SCHEDULE_PARAMETER
    (p_parameter_name       => 'VIEW_BY'
    ,p_schedule_id      => l_user_session_rec.schedule_id
    ,x_return_status        => l_return_Status
    ,x_msg_count            => l_msg_count
    ,x_msg_data     => l_msg_Data
    );
  else
    BIS_PMV_PARAMETERS_PVT.DELETE_PARAMETER( p_user_session_rec =>l_user_session_rec
                                          ,p_parameter_name     => 'VIEW_BY'
                                          ,p_schedule_option  =>'NULL'
                                          ,x_return_status      =>l_return_status
                                          ,x_msg_count => l_msg_count
                                          ,x_msg_data   => l_msg_data );
  end if;


  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
    RETURN;
  END IF;

  -- create the param
  l_parameter_rec.parameter_name := 'VIEW_BY';
  l_parameter_rec.parameter_description := pViewByParam;
  l_parameter_rec.parameter_value := pViewByParam;

  --insert the new view-by param
  if (l_user_Session_Rec.schedule_id is not null) then
     insert into bis_user_attributes  (user_id, function_name,
                                      session_id, schedule_id, attribute_name,
                                      session_value, session_description,
                                      creation_date, created_by,
                                      last_update_Date, last_updated_by)
                              VALUES (l_user_session_rec.user_id, l_user_session_rec.function_name,
                                      l_user_session_rec.session_id, l_user_session_rec.schedule_id,
                                      l_parameter_rec.parameter_name,
                                      pViewByParam, pViewbyParam,
                                      sysdate, -1, sysdate, -1);
      commit;
 else

  BIS_PMV_PARAMETERS_PVT.CREATE_PARAMETER(p_user_session_rec	=>l_user_session_rec
                                          ,p_parameter_rec	=> l_parameter_rec
                                          ,x_return_status	=> l_return_status
                                          ,x_msg_count		=> l_msg_count
                                          ,x_msg_Data         => l_msg_data  );
  end if;

  IF (l_return_status <> FND_API.G_RET_STS_SUCCESS)THEN
    RETURN;
  END IF;

  commit;
END process_custom_view_by;

/** Procedure to process the custom output from a pl/sql procedure call*/
PROCEDURE process_custom_output(
  pUserSession  in BIS_PMV_SESSION_PVT.SESSION_REC_TYPE,
  pCustomOutput IN bis_map_tbl,
  xCustom_sql OUT NOCOPY VARCHAR2,
  x_view_by_value OUT NOCOPY VARCHAR2
) IS
BEGIN
  IF pCustomOutput IS NOT NULL AND pCustomOutput.COUNT >0 THEN
    FOR i in pCustomOutput.FIRST..pCustomOutput.LAST LOOP
      IF pCustomOutput(i).KEY = QUERY_STR_KEY  THEN
        xCustom_sql := pCustomOutput(i).VALUE;
      ELSIF pCustomOutput(i).KEY = VIEW_BY_KEY THEN
         x_view_by_value := pCustomOutput(i).VALUE;
         IF (x_view_by_value IS NOT NULL) THEN
        	process_custom_view_by( pUserSession => pUserSession,
                                pViewByParam =>x_view_by_value);
	END IF;
      END IF;
    END LOOP;
  END IF;
END process_custom_output;


procedure get_custom_sql (p_source         in varchar2 DEFAULT 'REPORT',
                          pAKRegionRec in BIS_PMV_METADATA_PVT.AK_REGION_REC,
                          pParameterTbl in BIS_PMV_PARAMETERS_PVT.PARAMETER_TBL_TYPE,
                          pUserSession  in BIS_PMV_SESSION_PVT.SESSION_REC_TYPE,
                          p_sort_attribute in VARCHAR2 DEFAULT NULL,
                          p_sort_direction in VARCHAR2 DEFAULT NULL,
                          p_viewby_attribute2  VARCHAR2,
                          p_viewby_dimension   VARCHAR2,
                          p_viewby_dimension_level  VARCHAR2,
                          p_lower_bound IN INTEGER  DEFAULT 1,
                          p_upper_bound IN INTEGER  DEFAULT -1,
                          x_sql_string  out NOCOPY VARCHAR2,
                          x_bind_variables OUT NOCOPY VARCHAR2,
                          x_plsql_bind_variables OUT NOCOPY VARCHAR2,
                          x_bind_indexes OUT NOCOPY VARCHAR2,
                          x_bind_Datatypes OUT NOCOPY VARCHAR2,
                          x_return_Status out NOCOPY VARCHAR2,
                          x_msg_data OUT NOCOPY varchar2,
                          x_msg_count OUT NOCOPY NUMBER,
                          x_view_by_value OUT NOCOPY VARCHAR2)
IS
   l_custom_sql                  varchar2(32000);
   l_dynamic_sql_str             varchar2(32000);
   l_parameter_rec               BIS_PMV_PARAMETERS_PVT.PARAMETER_REC_TYPE;
   l_lookup_type                 varchar2(2000) := 'BIS_TIME_LEVEL_VALUES';
   l_Dimlevel_Acronym            varchar2(2000);
   l_where_clause                varchar2(2000);
   l_prev_start_Date             date;
   l_prev_start_date_c           varchar2(2000);
   l_pRev_end_Date               date;
   l_prev_end_date_c             varchar2(2000);
   l_temp_start_date             varchar2(2000);
   l_temp_end_date               varchar2(2000);
   l_description                 varchar2(32000);
   l_time_id                     varchar2(32000);
   l_save_region_item_rec        BIS_PMV_METADATA_PVT.SAVE_REGION_ITEM_REC;
   l_bind_count                  number := 0;
   l_where                       varchar2(32000);
   l_bind_variables              varchar2(32000);
   l_bind_indexes                varchar2(32000);
   l_asof_date                   varchar2(2000) := to_char(sysdate,'DD-MON-YYYY');
   l_asof_date_page              varchar2(2000) := to_char(sysdate,'DD-MON-YYYY');
   l_asof_date_varchar           varchar2(2000);
   l_prev_asof_date              varchar2(2000) := to_char(sysdate,'DD-MON-YYYY');
   l_prev_asof_date_page         varchar2(2000) := to_char(sysdate,'DD-MON-YYYY');
   l_time_comparison_type        varchar2(2000);
   l_time_comparison_page        varchar2(2000);
   l_time_parameter              varchar2(2000);
   l_paramlvlparam_Tbl            BIS_PMV_PARAMETERS_PVT.parameter_tbl_Type;
   l_page_parameter_rec           BIS_PMV_PAGE_PARAMETER_REC :=
                                  BIS_PMV_PAGE_PARAMETER_REC(null,null,null,null,null,null); --msaran:4600562 - added null for operator
   l_page_parameter_tbl           BIS_PMV_PAGE_PARAMETER_TBL := BIS_PMV_PAGE_PARAMETER_TBL();
   l_query_attributes_tbl         BIS_QUERY_ATTRIBUTES_TBL := BIS_QUERY_ATTRIBUTES_TBL();
   l_time_comp_value              VARCHAR2(2000);
   l_index                        INTEGER;
   l_period_type                  VARCHAR2(2000);
   l_order_by                  VARCHAR2(2000);
   l_nested_pattern            NUMBER;
   l_viewby_attribute2  VARCHAR2(2000);
   l_current_report_start_date       VARCHAR2(2000) := to_char(sysdate,'DD-MON-YYYY');
   l_previous_report_start_date      VARCHAR2(2000) := to_char(sysdate,'DD-MON-YYYY');
   l_temp_prev_asof_Date             VARCHAR2(2000) := to_char(sysdate,'DD-MON-YYYY');
   l_temp_date                       VARCHAR2(2000) := to_char(sysdate, 'DD-MON-YYYY');
   l_replace_mode VARCHAR2(1);
   CURSOR save_parameter_cursor (cpRegionCode VARCHAR2, cpParameterName VARCHAR2) IS
   SELECT attribute2,
       attribute3 base_column,
       attribute4 where_clause,
       attribute14 data_type
   FROM   AK_REGION_ITEMS
   WHERE  region_code = cpRegionCode
   AND    (nvl(attribute2, attribute_code) = cpParameterName
        or attribute2||'_FROM' = cpParameterName
        or attribute2||'_TO' = cpParameterName)
ORDER BY display_sequence;

l_custom_output bis_map_tbl;

l_original_sql varchar2(32000);

BEGIN
/*
  --First get the special page level parameters.
   BIS_PMV_PARAMETERS_PVT.RETRIEVE_PARAMLVL_PARAMETERS
   (p_user_session_Rec       => pusersession
   ,x_paramportlet_param_tbl => l_paramlvlparam_tbl
   ,x_return_Status          => x_return_Status
   ,x_msg_count              => x_msg_count
   ,x_msg_data               => x_msg_data
   );
*/
  --First get the custom select
    l_page_parameter_tbl.delete;
    if (pAKRegionRec.data_source = 'PLSQL_PARAMETERS' OR pAKRegionRec.data_source = 'PLSQL_PROCEDURE_CALL'
        or pAKRegionRec.data_source = 'PLSQL_PROCEDURE_QUERYATTRIBUTE') then
      l_index := 1;
      -- Call the same function by passing all the parameters
      if (pParameterTbl.COUNT > 0) then
         for i in pParameterTbl.FIRST..pParameterTbl.LAST LOOP
             l_parameter_rec := pParameterTbl(i);
             if (l_parameter_rec.dimension = 'TIME_COMPARISON_TYPE') then
                l_page_parameter_rec.parameter_name := 'TIME_COMPARISON_TYPE';
                l_time_Comp_value := substr(l_parameter_rec.parameter_description
                                     ,instr(l_parameter_rec.parameter_description,'+')+1);
                l_page_parameter_rec.parameter_id := l_time_comp_value;
                l_page_parameter_rec.parameter_value := l_time_comp_value;
                -- enh 2467584
		-- kiprabha/jprabhud
		-- get the l_time_comparison_type
         	l_time_comparison_type := l_parameter_rec.parameter_description;
             elsif (l_parameter_rec.parameter_name = 'AS_OF_DATE') THEN
                l_page_parameter_rec.parameter_id := l_parameter_rec.parameter_value;
                l_page_parameter_rec.parameter_name := l_parameter_rec.parameter_name;
                l_page_parameter_rec.parameter_value := l_parameter_rec.parameter_description;
                -- enh 2467584
		-- kiprabha /jprabhud
		-- get the l_asof_date
             	l_asof_date := l_parameter_rec.parameter_description;
             elsif (l_parameter_rec.parameter_name = 'BIS_P_ASOF_DATE') THEN
                l_temp_prev_asof_date := l_parameter_rec.parameter_description;
                l_page_parameter_rec.parameter_id := l_parameter_rec.parameter_value;
                l_page_parameter_rec.parameter_name := 'BIS_PREVIOUS_ASOF_DATE'       ;
                l_page_parameter_rec.parameter_value := l_parameter_rec.parameter_description;
             elsif (l_parameter_rec.parameter_name = 'BIS_CUR_REPORT_START_DATE') THEN
                l_page_parameter_Rec.parameter_id := l_parameter_rec.parameter_value;
                l_page_parameter_rec.parameter_name := 'BIS_CURRENT_REPORT_START_DATE';
                l_page_parameter_rec.parameter_value := l_parameter_rec.parameter_description;
                l_current_report_start_date := l_parameter_rec.parameter_description;
             elsif (l_parameter_rec.parameter_name = 'BIS_PREV_REPORT_START_DATE') THEN
                l_page_parameter_Rec.parameter_id := l_parameter_rec.parameter_value;
                l_page_parameter_rec.parameter_name := 'BIS_PREVIOUS_REPORT_START_DATE';
                l_page_parameter_rec.parameter_value := l_parameter_rec.parameter_description;
                l_previous_report_start_date := l_parameter_rec.parameter_description;
             else
                 l_page_parameter_rec.parameter_id := l_parameter_rec.parameter_value;
                 l_page_parameter_rec.parameter_name := l_parameter_rec.parameter_name;
                 l_page_parameter_rec.parameter_value := l_parameter_rec.parameter_description;
             end if;
             l_page_parameter_rec.period_date := l_parameter_rec.period_Date;
             l_page_parameter_rec.dimension := l_parameter_rec.dimension;
             l_page_parameter_tbl.extend;
             l_page_parameter_tbl(l_page_parameter_tbl.LAST) := l_page_parameter_rec;
             l_index := l_index+1;
             if (l_parameter_rec.dimension = 'TIME' and
                 instrb(l_parameter_rec.parameter_name,'_FROM')> 0) then
                 l_period_type := substr(l_parameter_rec.parameter_name,
                 instr(l_parameter_rec.parameter_name,'+')+1);
                 l_period_type := substr(l_period_type, 1, length(l_period_Type)-5);
                 l_page_parameter_rec.parameter_name := 'PERIOD_TYPE';
                 l_page_parameter_rec.parameter_id   := l_period_type;
                 l_page_parameter_Rec.parameter_value := l_period_type;
                 l_page_parameter_tbl.extend;
                 l_page_parameter_tbl(l_page_parameter_tbl.LAST) := l_page_parameter_rec;
             end if;

             -- enh 2467584
		-- kiprabha /jprabhud
		-- get the l_time_parameter
       	     if (l_parameter_rec.dimension = 'TIME' or
              l_parameter_Rec.dimension = 'EDW_TIME_M') then

             	if (substr(l_parameter_rec.parameter_name, length(l_parameter_Rec.parameter_name)-4) = '_FROM') then
                l_time_parameter := substr(l_parameter_rec.parameter_name,1, length(l_parameter_rec.parameter_name)-5);
		end if ;
	     end if ;

         end loop;
      end if;
/*
      if (l_paramlvlparam_tbl.COUNT > 0) then
          for i in l_paramlvlparam_tbl.FIRST..l_paramlvlparam_tbl.LAST loop
             l_parameter_rec := l_paramlvlparam_tbl(i);
             if (l_parameter_rec.dimension = 'TIME_COMPARISON_TYPE') then
                l_page_parameter_rec.parameter_name := 'TIME_COMPARISON_TYPE';
                l_time_Comp_value := substr(l_parameter_rec.parameter_description
                                     ,instr(l_parameter_rec.parameter_description,'+')+1);
                l_page_parameter_rec.parameter_id := l_time_comp_value;
                l_page_parameter_rec.parameter_value := l_time_comp_value;
                -- enh 2467584
		-- kiprabha /jprabhud
		-- get the l_time_comparison_type
		if(l_parameter_rec.parameter_description is not null) then
             	 l_time_comparison_type := l_parameter_rec.parameter_description;
		end if ;
             elsif (l_parameter_rec.parameter_name = 'AS_OF_DATE') THEN
                l_page_parameter_rec.parameter_id := l_parameter_rec.parameter_value;
                l_page_parameter_rec.parameter_name := l_parameter_rec.parameter_name;
                l_page_parameter_rec.parameter_value := l_parameter_rec.parameter_description;
                -- enh 2467584
		-- kiprabha /jprabhud
		-- get the l_asof_date
		if(l_parameter_rec.parameter_description is not null) then
             	 l_asof_date := l_parameter_rec.parameter_description;
		end if ;
             elsif (l_parameter_rec.parameter_name = 'BIS_P_ASOF_DATE') THEN
                l_temp_prev_asof_date := l_parameter_rec.parameter_description;
                l_page_parameter_rec.parameter_id := l_parameter_rec.parameter_value;
                l_page_parameter_rec.parameter_name := 'BIS_PREVIOUS_ASOF_DATE';
                l_page_parameter_rec.parameter_value := l_parameter_rec.parameter_description;
             elsif (l_parameter_rec.parameter_name = 'BIS_CUR_REPORT_START_DATE') THEN
                l_page_parameter_Rec.parameter_id := l_parameter_rec.parameter_value;
                l_page_parameter_rec.parameter_name := 'BIS_CURRENT_REPORT_START_DATE';
                l_page_parameter_rec.parameter_value := l_parameter_rec.parameter_description;
                l_current_report_start_date := l_parameter_rec.parameter_description;
             elsif (l_parameter_rec.parameter_name = 'BIS_PREV_REPORT_START_DATE') THEN
                l_page_parameter_Rec.parameter_id := l_parameter_rec.parameter_value;
                l_page_parameter_rec.parameter_name := 'BIS_PREVIOUS_REPORT_START_DATE';
                l_page_parameter_rec.parameter_value := l_parameter_rec.parameter_description;
                l_previous_report_start_date := l_parameter_rec.parameter_description;
             else
                l_page_parameter_rec.parameter_id := l_parameter_rec.parameter_value;
                l_page_parameter_rec.parameter_name := l_parameter_rec.parameter_name;
                l_page_parameter_rec.parameter_value := l_parameter_rec.parameter_description;
             end if;
             l_page_parameter_rec.period_date := l_parameter_rec.period_Date;
             l_page_parameter_rec.dimension := l_parameter_rec.dimension;
             l_page_parameter_tbl.extend;
             l_page_parameter_tbl(l_page_parameter_tbl.LAST) := l_page_parameter_rec;
             l_index := l_index+1;
         end loop;
      end if;
*/
        -- get the order by
      get_order_by_clause(
            p_source => p_source,
            pAKRegionRec => pAKRegionRec,
            pUserSession  => pUserSession,
            p_sort_attribute => p_sort_attribute,
            p_sort_direction => p_sort_direction,
            p_viewby_attribute2 => p_viewby_attribute2,
            p_viewby_dimension   => p_viewby_dimension,
            p_viewby_dimension_level => p_viewby_dimension_level,
            x_order_by => l_order_by);


      l_page_parameter_rec.parameter_name	 := ORDER_BY_KEY;
      l_page_parameter_rec.parameter_id  := ORDER_BY_KEY;
      l_page_parameter_rec.parameter_value 	    := l_order_by;
      l_page_parameter_rec.dimension              := NULL;
      l_page_parameter_rec.period_date            := NULL;

      l_page_parameter_tbl.extend;
      l_page_parameter_tbl(l_page_parameter_tbl.LAST) := l_page_parameter_rec;


      -- begin enhancement 2467584


	-- Changes for enhancement 2467584
	-- Get Previous Time Level Values
        if (l_time_comparison_type = 'TIME_COMPARISON_TYPE+SEQUENTIAL') then
           l_temp_date :=  l_asof_date;
        else
           if (l_temp_prev_asof_date is null) then
              l_temp_prev_asof_Date := to_char(sysdate,'DD-MON-YYYY');
           end if;
           l_temp_date := l_temp_prev_asof_date;
        end if;
        BIS_PMV_TIME_LEVELS_PVT.GET_PREVIOUS_TIME_LEVEL_VALUE
        (p_DimensionLevel        => l_time_parameter
        ,p_region_code           => pUserSession.region_code
        ,p_responsibility_id     => pUserSession.responsibility_id
        --,p_asof_date              => to_date(l_asof_date)
        --This should be the previous as of date.
        ,p_asof_Date             => l_temp_Date
        ,p_time_comparison_type  => l_time_comparison_type
        ,x_time_level_id         => l_time_id
        ,x_time_level_Value      => l_description
        ,x_start_date            => l_prev_start_date
        ,x_end_date              => l_prev_end_date
        ,x_return_Status         => x_return_Status
        ,x_msg_count             => x_msg_count
        ,x_msg_data              => x_msg_data
        );

	-- Changes for enhancement 2467584
	-- Store the Previous Time Level Values in page_parameter_table

	l_page_parameter_rec.parameter_name := l_time_parameter || '_PFROM'  ;
      	l_page_parameter_rec.parameter_id  := l_time_id;
     	l_page_parameter_rec.parameter_value          := l_description;
      	l_page_parameter_rec.dimension              :=
              substr(l_time_parameter,1, instr(l_time_parameter,'+' )-1);
      	l_page_parameter_rec.period_date            := l_prev_start_date;

	l_page_parameter_tbl.extend ;
	l_page_parameter_tbl(l_page_parameter_tbl.LAST) := l_page_parameter_rec;

	l_page_parameter_rec.parameter_name        := l_time_parameter ||  '_PTO'  ;
      	l_page_parameter_rec.parameter_id  := l_time_id;
     	l_page_parameter_rec.parameter_value          := l_description;
      	l_page_parameter_rec.dimension              :=
              substr(l_time_parameter,1, instr(l_time_parameter,'+' )-1);
      	l_page_parameter_rec.period_date            := l_prev_end_date;

	l_page_parameter_tbl.extend ;
	l_page_parameter_tbl(l_page_parameter_tbl.LAST) := l_page_parameter_rec;

	-- end enhancement 2467584


      IF ( pAKRegionRec.data_source = 'PLSQL_PARAMETERS') THEN
           l_dynamic_sql_Str := 'BEGIN :1 :='|| pAKRegionRec.plsql_function ||' (:2); END;';
          execute immediate l_dynamic_sql_str using OUT l_custom_sql ,IN l_page_parameter_tbl ;

       ELSIF ( pAKRegionRec.data_source = 'PLSQL_PROCEDURE_CALL') THEN
          l_dynamic_sql_Str := 'BEGIN '|| pAKRegionRec.plsql_function ||' (:1, :2); END;';
          execute immediate l_dynamic_sql_str using IN l_page_parameter_tbl, OUT l_custom_output  ;
          process_custom_output( pUserSession  => pUserSession,
                                 pCustomOutput => l_custom_output,
                                 xCustom_sql => l_custom_sql,
                                 x_view_by_value => x_view_by_value );
       ELSIF (pAKRegionRec.data_source = 'PLSQL_PROCEDURE_QUERYATTRIBUTE') THEN
          l_dynamic_sql_str := 'BEGIN '||pAKRegionRec.plsql_function ||'(:1, :2, :3); END;';
          BEGIN
          execute immediate l_dynamic_sql_Str using IN l_page_parameter_tbl,
               OUT l_custom_sql, OUT l_query_attributes_Tbl;
          EXCEPTION
          WHEN OTHERS THEN
                 null;
          END;
       END IF; --if data source

    else
      if (pParameterTbl.COUNT > 0) then
         for i in pParameterTbl.FIRST..pParameterTbl.LAST LOOP
             l_parameter_rec := pParameterTbl(i);
             if (l_parameter_rec.parameter_name = 'BIS_P_ASOF_DATE') THEN
                l_temp_prev_asof_date := l_parameter_rec.parameter_description;
             elsif (l_parameter_rec.parameter_name = 'BIS_CUR_REPORT_START_DATE') THEN
                l_current_report_start_date := l_parameter_rec.parameter_description;
             elsif (l_parameter_rec.parameter_name = 'BIS_PREV_REPORT_START_DATE') THEN
                l_previous_report_start_date := l_parameter_rec.parameter_description;
             elsif (l_parameter_rec.dimension = 'TIME_COMPARISON_TYPE') then
		if(l_parameter_rec.parameter_description is not null) then
             	 l_time_comparison_type := l_parameter_rec.parameter_description;
                end if;
	      end if ;
         end loop;
       end if;
/*
         if (l_paramlvlparam_tbl.COUNT > 0) then
             for i in l_paramlvlparam_tbl.FIRST..l_paramlvlparam_tbl.LAST loop
             l_parameter_rec := l_paramlvlparam_tbl(i);
             if (l_parameter_rec.parameter_name = 'BIS_P_ASOF_DATE') THEN
                l_temp_prev_asof_date := l_parameter_rec.parameter_description;
             elsif (l_parameter_rec.parameter_name = 'BIS_CUR_REPORT_START_DATE') THEN
                l_current_report_start_date := l_parameter_rec.parameter_description;
             elsif (l_parameter_rec.parameter_name = 'BIS_PREV_REPORT_START_DATE') THEN
                l_previous_report_start_date := l_parameter_rec.parameter_description;
             elsif (l_parameter_rec.dimension = 'TIME_COMPARISON_TYPE') then
		if(l_parameter_rec.parameter_description is not null) then
             	  l_time_comparison_type := l_parameter_rec.parameter_description;
	        end if ;
             end if;
          end loop;
        end if;
*/
       --l_dynamic_sql_Str := 'SELECT '|| pAKRegionRec.plsql_function || ' FROM DUAL';
       l_Dynamic_sql_str := 'BEGIN :1 :='||pAKRegionRec.plsql_function||'(); END;';
       --l_dynamic_sql_Str := 'SELECT test_func.get_sql FROM DUAL';
       execute immediate l_dynamic_sql_str using OUT  l_custom_Sql;
    end if;

  l_original_sql := l_custom_sql;
  --We first need to replace the bind variables sent by the product teams queries.

  IF ( pAKRegionRec.data_source = 'PLSQL_PROCEDURE_QUERYATTRIBUTE') THEN
     replace_product_binds(pUserSession => pUserSession,
                           p_original_sql => l_original_sql,
                           p_custom_output => l_query_attributes_tbl,
                           x_custom_sql => l_custom_Sql,
                           x_bind_variables => x_bind_variables,
                           x_plsql_bind_variables => x_plsql_bind_variables,
                           x_bind_indexes => x_bind_indexes,
                           x_bind_Datatypes => x_bind_datatypes,
                           x_bind_count => l_bind_count,
                           x_view_by_value => x_view_by_value );
   END IF;
   --Replace time comparison type and period types
   l_index := instrb(l_original_sql,'&BIS_TIME_COMPARISON_TYPE');
   if (l_index > 0) then
          replace_with_bind_variables
          (p_search_string => '&BIS_TIME_COMPARISON_TYPE',
           p_bind_value => l_time_comp_value,
           p_initial_index => l_index,
           p_original_sql => l_original_sql,
           x_custom_sql => l_custom_sql,
           x_bind_variables => x_bind_variables,
           x_plsql_bind_variables => x_plsql_bind_variables,
           x_bind_indexes => x_bind_indexes,
           x_bind_datatypes => x_bind_datatypes,
           x_bind_count => l_bind_count);
  end if;
  l_index := instrb(l_original_sql,'&BIS_PERIOD_TYPE');
  if (l_index > 0) then
          replace_with_bind_variables
          (p_search_string => '&BIS_PERIOD_TYPE',
           p_bind_value => l_period_type,
           p_initial_index => l_index,
           p_original_sql => l_original_sql,
           x_custom_sql => l_custom_sql,
           x_bind_variables => x_bind_variables,
           x_plsql_bind_variables => x_plsql_bind_variables,
           x_bind_indexes => x_bind_indexes,
           x_bind_datatypes => x_bind_datatypes,
           x_bind_count => l_bind_count);
  end if;
  --REplace the nested bit pattern
  l_index := instrb(l_original_sql ,'&BIS_NESTED_PATTERN');
  if (l_index > 0) then
          --Get the nested pattern
          BIS_PMV_TIME_LEVELS_PVT.GET_NESTED_PATTERN
          (p_time_comparison_type => l_time_comparison_type
          ,p_time_level => l_period_type
          ,x_nested_pattern => l_nested_pattern
          ,x_return_Status => x_return_Status
          ,x_msg_count => x_msg_count
          ,x_msg_data => x_msg_data
          );
          replace_with_bind_variables
          (p_search_string => '&BIS_NESTED_PATTERN',
           p_bind_value => l_nested_pattern,
           p_bind_Datatype => BIS_PMV_PARAMETERS_PUB.INTEGER_BIND,
           p_initial_index => l_index,
           p_original_sql => l_original_sql,
           x_custom_sql => l_custom_sql,
           x_bind_variables => x_bind_variables,
           x_plsql_bind_variables => x_plsql_bind_variables,
           x_bind_indexes => x_bind_indexes,
           x_bind_datatypes => x_bind_datatypes,
           x_bind_count => l_bind_count);
  end if;
  l_index := instrb(l_original_sql , '&BIS_CURRENT_REPORT_START_DATE');
  if (l_index > 0) then
          if (l_current_report_start_date is null) then
              l_current_Report_start_date := to_char(sysdate,'DD-MON-YYYY');
          end if;
          replace_with_bind_variables
          (p_search_string => '&BIS_CURRENT_REPORT_START_DATE',
           p_bind_value => l_current_report_start_date,
           p_initial_index => l_index,
           p_bind_to_date => 'Y',
           p_original_sql => l_original_sql,
           x_custom_sql => l_custom_sql,
           x_bind_variables => x_bind_variables,
           x_plsql_bind_variables => x_plsql_bind_variables,
           x_bind_indexes => x_bind_indexes,
           x_bind_Datatypes => x_bind_datatypes,
           x_bind_count => l_bind_count);
   end if;
  l_index := instrb(l_original_sql , '&BIS_PREVIOUS_REPORT_START_DATE');
  if (l_index > 0) then
          if (l_previous_report_start_date is null) then
             l_previous_report_start_date := to_char(sysdate,'DD-MON-YYYY');
          end if;
          replace_with_bind_variables
          (p_search_string => '&BIS_PREVIOUS_REPORT_START_DATE',
           p_bind_value => l_previous_report_start_date,
           p_initial_index => l_index,
           p_bind_to_date => 'Y',
           p_original_sql => l_original_sql,
           x_custom_sql => l_custom_sql,
           x_bind_variables => x_bind_variables,
           x_plsql_bind_variables => x_plsql_bind_variables,
           x_bind_indexes => x_bind_indexes,
           x_bind_Datatypes => x_bind_datatypes,
           x_bind_count => l_bind_count);
   end if;
   --First search for all the parameters and replace them
  replace_report_parameters(
    p_user_session_rec => pUserSession,
    pParameterTbl => pParameterTbl,
    pStartChar => '&',
    pEndChar =>  '',
    pUseBindVariable => true,
    pReplaceSubstVariable => true,
    pReplaceXTDVariable => TRUE, -- replace xtd for custom stuff w/o binding
    p_original_sql => l_original_sql,
    x_custom_sql => l_custom_Sql,
    x_temp_Start_date => l_temp_Start_date,
    x_temp_end_date => l_temp_end_date,
    x_time_parameter => l_time_parameter,
    x_asOf_date => l_asOf_date,
    x_prev_asof_date => l_prev_asof_date,
    x_time_comparison_type => l_time_comparison_type,
    x_bind_variables => x_bind_variables,
    x_plsql_bind_variables => x_plsql_bind_variables,
    x_bind_indexes => x_bind_indexes,
    x_bind_Datatypes => x_bind_datatypes,
    x_bind_count => l_bind_count
  ) ;

/*
  IF (l_asof_date IS NULL OR l_time_comparison_type IS NULL) THEN

    retrieve_params_from_page (
      p_user_session_rec => pUserSession,
      p_paramlvlparam_Tbl => l_paramlvlparam_tbl,
      x_asof_date => l_asof_date_page,
      x_prev_asof_Date => l_prev_asof_date_page,
      x_time_comparison_type => l_time_comparison_page,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data
    ) ;
  END IF;
*/

  IF (l_asOf_Date IS NULL) THEN
   IF (l_asof_date_page IS NOT NULL) THEN
     l_asof_date := l_asof_date_page;
   ELSE
     l_asof_date := to_char(sysdate,'DD-MON-YYYY');
   END IF;
  END IF;
  IF (l_prev_asOf_Date IS NULL) THEN
   IF (l_prev_asof_date_page IS NOT NULL) THEN
     l_prev_asof_date := l_prev_asof_date_page;
   ELSE
     l_prev_asof_date := to_char(sysdate,'DD-MON-YYYY');
   END IF;
  END IF;

  IF (l_time_comparison_type IS NULL AND l_time_comparison_page IS NOT NULL ) THEN
     l_time_comparison_type := l_time_comparison_page;
  END IF;


  replace_paramLvl_parameters(
    p_user_session_rec => pUserSession,
    p_asof_date => l_asof_date,
    p_prev_asof_date => l_prev_asof_date,
    p_time_comparison_type => l_time_comparison_type,
    p_time_parameter => l_time_parameter,
    p_original_sql => l_original_sql,
    x_custom_sql => l_custom_sql,
    x_return_status => x_return_status,
    x_msg_count => x_msg_count,
    x_msg_data => x_msg_data,
    x_bind_variables => x_bind_variables,
    x_plsql_bind_variables => x_plsql_bind_variables,
    x_bind_indexes => x_bind_indexes,
    x_bind_Datatypes => x_bind_Datatypes,
    x_bind_count => l_bind_count
  ) ;

   IF (instrb(l_custom_sql,'&BIS_PREVIOUS_EFFECTIVE_START_DATE') >0 OR
       instrb(l_custom_Sql,'&BIS_PREVIOUS_EFFECTIVE_END_DATE') > 0 ) THEN


      -- jprabhud enh 2467584
      if (pAKRegionRec.data_source = 'PLSQL_PARAMETERS' OR pAKRegionRec.data_source = 'PLSQL_PROCEDURE_CALL'
        or pAKRegionRec.data_source = 'PLSQL_PROCEDURE_QUERYATTRIBUTE') then
          l_replace_mode :='1';
         if(l_prev_start_date is not null AND length(l_prev_start_date)<>0) then
            l_temp_start_date := to_char(l_prev_start_date,'DD-MON-YYYY') ;
         end if;
         if(l_prev_end_date is not null AND length(l_prev_end_date)<>0 ) then
            l_temp_end_date := to_char(l_prev_end_date,'DD-MON-YYYY') ;
         end if;

      else
        if (l_time_comparison_type = 'TIME_COMPARISON_TYPE+SEQUENTIAL') then
           l_temp_date :=  l_asof_date;
        else
           if (l_temp_prev_asof_date is null) then
              l_temp_prev_asof_Date := to_char(sysdate,'DD-MON-YYYY');
           end if;
           l_temp_date := l_temp_prev_asof_date;
        end if;
         l_replace_mode :='2';
      end if;

      -- enh 2467584
      -- kiprabha /jprabhud
      -- added p_replace_mode
      -- p_replace_mode = '1' => previous time value already known (passed as p_default_start_date,p_default_end_date)
      --		= '2' => API to get previous time values needs to get called
      replace_prev_time_parameters(
        p_user_session_rec => pUserSession,
        p_time_parameter => l_time_parameter,
        p_asof_date => l_temp_date,
        p_time_comparison_type => l_time_comparison_type,
        p_default_start_date => l_temp_Start_date,
        p_default_end_date => l_temp_end_date,
        p_original_sql => l_original_sql,
        p_replace_mode => l_replace_mode,
        x_custom_sql => l_custom_sql,
        x_return_status => x_return_status,
        x_msg_count =>x_msg_count,
        x_msg_data => x_msg_data,
        x_bind_variables => x_bind_variables,
        x_plsql_bind_variables => x_plsql_bind_variables,
        x_bind_indexes => x_bind_indexes,
        x_bind_Datatypes => x_bind_Datatypes,
        x_bind_count => l_bind_count
        );
   END IF;

   -- replace start and end subs variables
   --serao- bug 2642688 -10/25/02 - use bind variables
   replaceStartEndIndex (p_custom_sql => l_custom_sql,
                          p_lower_bound => p_lower_bound,
                          p_upper_bound => p_upper_bound+1,
                          p_original_sql => l_original_sql,
                          x_bind_variables => x_bind_variables,
                          x_plsql_bind_variables => x_plsql_bind_variables,
                          x_bind_indexes => x_bind_indexes,
                          x_bind_Datatypes => x_bind_Datatypes,
                          x_bind_count => l_bind_count
                        );


   -- replace order by subs variable
   IF (instrb(l_custom_sql, ORDER_BY_SUBST_VAR) >0 ) THEN
     -- order by could have been obtained for parameters
     IF (l_order_by IS NULL) THEN
        get_order_by_clause(
          p_source => p_source,
          pAKRegionRec => pAKRegionRec,
          pUserSession  => pUserSession,
          p_sort_attribute => p_sort_attribute,
          p_sort_direction => p_sort_direction,
          p_viewby_attribute2 => p_viewby_attribute2,
          p_viewby_dimension   => p_viewby_dimension,
          p_viewby_dimension_level => p_viewby_dimension_level,
          x_order_by => l_order_by);
      END IF;
      --serao - 2622281 - add order by only if non-null
     IF (l_order_by IS NOT NULL) THEN
       l_custom_sql := replace(l_Custom_sql, ORDER_BY_SUBST_VAR, ' ORDER BY '||l_order_by);
     END IF;
   END IF;

   x_sql_String := l_custom_sql;
exception
when others then
    null;
END;

PROCEDURE replaceAttrCodeWithDimension(
  pUserSession_rec IN BIS_PMV_SESSION_PVT.SESSION_REC_TYPE,
  x_custom_sql In OUT NOCOPY VARCHAR2
) IS
vAttributeCode VARCHAR2(150);
vAttribute2 VARCHAR2(150);
vIndex1 NUMBER := 1;
vIndex2 NUMBER;
BEGIN

  -- substitute the attribute code with the dimensions
  LOOP
      vIndex1 := instr(x_custom_sql, '{', vIndex1, 1);
      vIndex2 := instr(x_custom_sql, '}', vIndex1+1, 1);
      if vIndex1 = 0 or vIndex2 = 0 THEN
          EXIT;
      end if;
      vAttributeCode := substr(x_custom_sql, vIndex1+1, vIndex2-vIndex1-1);
      vAttribute2 := BIS_PARAMETER_VALIDATION.getDimensionForAttribute(rtrim(ltrim(vAttributeCode)), pUserSession_rec.region_Code);

      x_custom_sql := replace( x_custom_sql, vAttributeCode, vAttribute2);
      vIndex1 := vIndex2+1;
  END LOOP;

END replaceAttrCodeWithDimension;

PROCEDURE substitute_lov_where(
  pUserSession_rec IN BIS_PMV_SESSION_PVT.SESSION_REC_TYPE,
  pSchedule_id IN VARCHAR2,
  pSource In VARCHAR2 DEFAULT 'REPORT',
  x_lov_where IN OUT NOCOPY VARCHAR2,
  x_return_status out NOCOPY VARCHAR2,
  x_msg_count out NOCOPY NUMBER,
  x_msg_data out NOCOPY VARCHAR2
) IS

l_parameter_tbl BIS_PMV_PARAMETERS_PVT.PARAMETER_TBL_TYPE;
l_bind_variables VARCHAR2(1000);
l_plsql_bind_variables VARCHAR2(1000);
l_bind_indexes VARCHAR2(1000);
l_bind_datatypes VARCHAR2(32000);
l_bind_count NUMBER := 0;
l_temp VARCHAR2(30);
l_original_sql varchar2(32000) := x_lov_where;
BEGIN


 IF (x_lov_where IS NOT NULL) THEN
    --check if it has any subs variables
    IF (instrb(x_lov_where, '{' ) > 0) THEN

     BIS_PMV_PARAMETERS_PVT.RETRIEVE_PAGE_PARAMETERS
     (p_schedule_id  => pSchedule_id,
      p_user_session_rec => pUserSession_rec,
      x_user_param_tbl => l_parameter_tbl,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data
     );

     replaceAttrCodeWithDimension(
      pUserSession_rec =>pUserSession_rec,
      x_custom_sql =>x_lov_where
    );

    replace_report_parameters(
      p_user_session_rec =>pUserSession_rec,
      pParameterTbl =>l_parameter_tbl,
      pStartChar =>'{',
      pEndChar => '}',
      pUseBindVariable => false,
      pReplaceSubstVariable => false,
      pReplaceXTDVariable => false,
      p_original_sql => l_original_sql,
      x_custom_sql => x_lov_where,
      x_temp_Start_date => l_temp,
      x_temp_end_date => l_temp,
      x_time_parameter => l_temp,
      x_asOf_date => l_temp,
      x_prev_asof_date=> l_temp,
      x_time_comparison_type => l_temp,
      x_bind_variables => l_bind_variables,
      x_plsql_bind_variables => l_plsql_bind_variables,
      x_bind_indexes => l_bind_indexes,
      x_bind_Datatypes => l_bind_Datatypes,
      x_bind_count => l_bind_count
    ) ;


    END IF;
 END IF;

END substitute_lov_where;

procedure replace_with_bind_variables
(p_search_string in varchar2,
 p_bind_value in varchar2,
 p_bind_Datatype IN NUMBER DEFAULT 2,
 p_initial_index in number,
 p_bind_function in varchar2 default null,
 p_bind_to_date in varchar2 default 'N',
 p_original_sql in varchar2,
 x_custom_sql in out NOCOPY varchar2,
 x_bind_variables in out NOCOPY varchar2,
 x_plsql_bind_variables in out NOCOPY varchar2,
 x_bind_indexes in out NOCOPY varchar2,
 x_bind_datatypes IN OUT NOCOPY VARCHAR2,
 x_bind_count in out NOCOPY number) is

l_count number := 0;
l_index number := instrb(x_custom_sql, p_search_string);
l_bind_index number := p_initial_index;
l_bind_string varchar2(32000);
l_split_bind_values varchar2(32000);
l_split_bind_vars varchar2(32000);
l_split boolean := false;
l_old_bind_count number := x_bind_count;
l_diff number;
begin

if instrb(p_bind_value, ''',''') > 0 then
  l_split := true;
  splitMultipleVariables
  (lString => replace(p_bind_value,'''',null),
   x_bind_variables => l_split_bind_values,
   x_bind_count => x_bind_count,
   x_split_string => l_split_bind_vars
  );
  l_diff := x_bind_count - l_old_bind_count;
  x_plsql_bind_variables := x_plsql_bind_variables || l_split_bind_values;
else
  x_bind_count := x_bind_count + 1;
  x_plsql_bind_variables := x_plsql_bind_variables || SEPERATOR || p_bind_value;
end if;

  while (l_bind_index > 0) and (l_count < 1000) loop

   if l_split then
    for i in 1..l_diff loop
      x_bind_indexes := x_bind_indexes || SEPERATOR || l_bind_index;
      x_bind_datatypes := x_bind_datatypes || SEPERATOR || p_bind_datatype;
      l_bind_index := l_bind_index + 1;
    end loop;
    x_bind_variables := x_bind_variables || l_split_bind_values;
    l_bind_string := l_split_bind_vars;
   else
    x_bind_indexes := x_bind_indexes || SEPERATOR || l_bind_index;
    if (p_bind_datatype = BIS_PMV_PARAMETERS_PUB.DATE_BIND) THEN
       x_bind_datatypes := x_bind_datatypes || SEPERATOR|| BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
    else
       x_bind_datatypes := x_bind_datatypes || SEPERATOR || p_bind_datatype;
    end if;
    x_bind_variables := x_bind_variables || SEPERATOR || p_bind_value;

    if p_bind_to_date = 'Y' then
       l_bind_string := 'TO_DATE(:' || x_bind_count || ',''DD-MON-YYYY'')';
     elsif (p_bind_datatype = BIS_PMV_PARAMETERS_PUB.DATE_BIND) THEN
      l_bind_string := 'TO_DATE(:' || x_bind_count ||',''DD/MM/YYYY'')';
    else
       l_bind_string := ':' || x_bind_count;
    end if;
   end if; -- end of split case
    if p_bind_function is not null then
       l_bind_string := p_bind_function || '(' || l_bind_string || ')';
    end if;

    x_custom_sql := substrb(x_custom_sql, 0, l_index-1)
                 || l_bind_string
                 || substrb(x_custom_sql,l_index+lengthb(p_search_string));

    l_index := instrb(x_custom_sql, p_search_string);
    l_bind_index := instrb(p_original_sql, p_search_string, l_bind_index+1);
    l_count := l_count + 1;
  end loop;

end replace_with_bind_variables;

procedure replace_product_binds
(pUSerSession IN BIS_PMV_SESSION_PVT.SESSION_REC_TYPE,
p_original_sql IN VARCHAR2,
p_custom_output IN BIS_QUERY_ATTRIBUTES_TBL,
x_custom_sql IN OUT NOCOPY VARCHAR2,
x_bind_variables IN OUT NOCOPY VARCHAR2,
x_plsql_bind_variables IN OUT NOCOPY VARCHAR2,
x_bind_indexes IN OUT NOCOPY VARCHAR2,
x_bind_Datatypes IN OUT NOCOPY VARCHAR2,
x_bind_count IN OUT NOCOPY NUMBER,
x_view_by_value OUT NOCOPY VARCHAR2
)
IS
  l_index   number;
  l_bis_query_attributes  BIS_QUERY_ATTRIBUTES;
BEGIN
  if (p_custom_output is not null and p_custom_output.COUNT > 0 )
  then

   for i in  p_custom_output.FIRST..p_custom_output.LAST loop
       l_bis_Query_attributes := p_custom_output(i);
       if (l_bis_query_attributes.attribute_type = BIS_PMV_PARAMETERS_PUB.VIEW_BY_TYPE)
       then
          if (l_bis_query_attributes.attribute_value is not null and
              length(l_bis_query_attributes.attribute_value) > 0) then
          process_custom_view_by(pusersession, l_bis_query_attributes.attribute_value);
          x_view_by_value := l_bis_query_attributes.attribute_value;
          l_index := instrb(p_original_Sql,'&BIS_VIEW_BY');
          if (l_index > 0) then
             replaceNameWithValue(
       	     pParamName => '&BIS_VIEW_BY',
       	     pParamValue => l_bis_query_attributes.attribute_value,
             pUseBindVariable => true ,
             p_initial_index => l_index,
             p_original_sql => p_original_sql,
             xClause => x_custom_sql,
             x_bind_variables => x_bind_variables,
             x_plsql_bind_variables => x_plsql_bind_variables,
             x_bind_indexes => x_bind_indexes,
             x_bind_datatypes => x_bind_datatypes,
             x_bind_count => x_bind_count
             );
           end if;
          end if;
        end if;
       if (l_bis_query_attributes.attribute_type = BIS_PMV_PARAMETERS_PUB.BIND_TYPE) THEN
          l_index := instrb(p_original_sql, l_bis_query_attributes.attribute_name);
          if (l_index > 0) then
          replace_with_bind_variables
          (p_search_string => l_bis_query_attributes.attribute_name,
           p_bind_value => l_bis_Query_attributes.attribute_value,
           p_bind_datatype => l_bis_query_attributes.attribute_data_type,
           p_initial_index => l_index,
           p_original_sql => p_original_sql,
           x_custom_sql => x_custom_sql,
           x_bind_variables => x_bind_variables,
           x_plsql_bind_variables => x_plsql_bind_variables,
           x_bind_indexes => x_bind_indexes,
           x_bind_datatypes => x_bind_datatypes,
           x_bind_count => x_bind_count);
           end if;
       end if;
     end loop;
     null;
  end if;
END;
end BIS_PMV_QUERY_PVT;

/
