--------------------------------------------------------
--  DDL for Package Body PQP_OSS_DFF_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_OSS_DFF_UTILS" AS
/* $Header: pqphrossutil.pkb 120.0 2005/05/29 02:21:32 appldev noship $ */

-- =============================================================================
-- ~ parse_segment :
--   Function checks the Segment if it has Value Set 'FND_DATE' attached to it
--   If so then formats it in correct format and returns it
--   Else it simply returns the segment value back
--   Later this function can also be used to other operations also
-- =============================================================================

FUNCTION parse_segment (p_seg_valset_rec IN t_seg_valsetid)
RETURN Varchar2 IS

  -- Cursor to check if the passed segment is a Date Field
  CURSOR csr_get_valset_name (c_val_set_id IN
                       fnd_descr_flex_column_usages.flex_value_set_id%TYPE) IS
  SELECT flex_value_set_name
    FROM fnd_flex_value_sets
   WHERE flex_value_set_id = c_val_set_id;

 l_flx_valset_name  fnd_flex_value_sets.flex_value_set_name%TYPE;
 l_return_seg       Varchar2(2000);

BEGIN

    OPEN  csr_get_valset_name (c_val_set_id => p_seg_valset_rec.flx_valset_id);
    FETCH csr_get_valset_name INTO l_flx_valset_name;
    CLOSE csr_get_valset_name;

    IF l_flx_valset_name = 'FND_STANDARD_DATE' THEN

       l_return_seg := 'fnd_date.canonical_to_date(P_' ||
                        p_seg_valset_rec.seg_name || ')';

    ELSE

       l_return_seg := 'P_' || p_seg_valset_rec.seg_name;

    END IF;
    RETURN l_return_seg;

END parse_segment;

-- =============================================================================
-- ~ get_concat_dff_segs :
--   Function returns the concatenated string of Segment Values for a given DFF
-- =============================================================================

FUNCTION get_concat_dff_segs
         (p_ddf_name      IN Varchar2
         ,p_dp_view_name  IN Varchar2
         ,p_batch_id      IN Number
         ,p_app_id        IN Number
         ,p_link_value    IN Number)
RETURN Varchar2 IS

  -- Cursor to get Delimiter and the Context for a given DFF
  CURSOR csr_get_delim_contxt (c_ddf_name IN Varchar2
                              ,c_app_id   IN Number) IS
  SELECT concatenated_segment_delimiter, context_column_name
    FROM fnd_descriptive_flexs
   WHERE descriptive_flexfield_name IN (c_ddf_name)
     AND application_id = c_app_id;

  -- Cursor to get segments for a given DFF and Context
  CURSOR csr_get_segments(c_ddf_name      IN Varchar2
                         ,c_context_value IN Varchar2
                         ,c_app_id        IN Number) IS
  SELECT application_column_name, flex_value_set_id
    FROM fnd_descr_flex_column_usages
   WHERE descriptive_flexfield_name = c_ddf_name
     AND descriptive_flex_context_code IN ('Global Data Elements', c_context_value)
     AND enabled_flag = 'Y'
     AND display_flag = 'Y'
     AND application_id = c_app_id
   ORDER BY descriptive_flex_context_code, column_seq_num;

  -- Dynamic Ref Cursor
  TYPE ref_cur_typ IS REF CURSOR;
  csr_get_dff_ctx_val       ref_cur_typ;
  csr_get_cnct_segs         ref_cur_typ;

  l_func_name   CONSTANT    Varchar2(150):= g_pkg ||'pqp_oss_get_concat_ddfsegs';

  l_delimiter               fnd_descriptive_flexs.concatenated_segment_delimiter%TYPE;
  l_dff_ctx_val             fnd_descr_flex_column_usages.descriptive_flex_context_code%TYPE;

  l_delim_ctx_rec           t_delim_contxt;
  l_seg_val_rec             t_seg_valsetid;

  l_dyn_sql_qry             Varchar(500);
  l_cnct_segs               Varchar2(2000);
  l_ck_all_null_segvals     Varchar2(2000);

BEGIN

  Hr_Utility.set_location('Entering: '||l_func_name, 5);

  -- Get the Delimiter and Context for the given DFF
  OPEN  csr_get_delim_contxt(c_ddf_name => p_ddf_name
                            ,c_app_id   => p_app_id
                            );
  FETCH csr_get_delim_contxt INTO l_delim_ctx_rec;

  -- If Delimiter is not found then that means the passed DFF doesn't exist for
  -- the passed application id. Raise an Error
  IF csr_get_delim_contxt%NOTFOUND THEN
     CLOSE csr_get_delim_contxt;
     Hr_Utility.raise_error;
  END IF;
  CLOSE csr_get_delim_contxt;



  -- Get a Context Value from Data Pump Interface Values
  -- Prepare a string for Dynamic SQL
  -- P_ has been concatenated since all the column names of DP views are
  -- suffixed by P_
  l_dyn_sql_qry := 'SELECT P_'            || l_delim_ctx_rec.con_col_name ||
                   '  FROM '              || p_dp_view_name               ||
             	   ' WHERE batch_id = '   || p_batch_id;

  IF p_link_value IS NOT NULL THEN
     l_dyn_sql_qry := l_dyn_sql_qry ||' AND link_value = ' || p_link_value;
  END IF;

  OPEN  csr_get_dff_ctx_val FOR  l_dyn_sql_qry;
  FETCH csr_get_dff_ctx_val INTO l_dff_ctx_val;
  CLOSE csr_get_dff_ctx_val;




  -- Get the Segments for a given DFF and corresponding Context &
  -- Global Data Elements Context
  OPEN  csr_get_segments(c_ddf_name      => p_ddf_name
                        ,c_context_value => l_dff_ctx_val
                        ,c_app_id        => p_app_id
                        );
  FETCH csr_get_segments INTO l_seg_val_rec;
  -- If there is no segment returned by the cursor that means,
  -- there is some issue with parameter values to function and return null
  IF csr_get_segments%NOTFOUND THEN
     CLOSE csr_get_segments;
     RETURN NULL;
  END IF;




  -- Prepare a dynamic SQL string to get the Concatenated String
  -- for all the segments enabled and displayable for a DFF.
  --
  -- Also prepare a "l_ck_all_null_segvals" if all the segment values have
  -- NULL value in Interface Tables. If that is the case then we return NULL
  -- This is required because in some DFFs like 'Person Developer DF'
  -- Context value in the Data Pump Interface Tables is entered even if user
  -- didn't enter any data for the DFF segments. For such DFFs if no data has
  -- been entered in the segments, return NULL

  l_delimiter := l_delim_ctx_rec.con_seg_delim;

  IF l_dff_ctx_val IS NOT NULL THEN

     l_dyn_sql_qry         := 'SELECT ''' || l_dff_ctx_val || l_delimiter ||
                              '''|| '     || parse_segment(l_seg_val_rec);
     l_ck_all_null_segvals := l_dff_ctx_val || l_delimiter;

  ELSE

     l_dyn_sql_qry := 'SELECT ' || parse_segment(l_seg_val_rec);

  END IF;


  -- Loop to prepare the dynamic SQL for all the Segments for a given Context
  LOOP
    FETCH csr_get_segments INTO l_seg_val_rec;
    EXIT WHEN csr_get_segments%NOTFOUND;

    l_dyn_sql_qry         := l_dyn_sql_qry || ' ||'''  || l_delimiter ||
                                       ''' || ' || parse_segment(l_seg_val_rec);
    l_ck_all_null_segvals := l_ck_all_null_segvals || l_delimiter;
  END LOOP;


  CLOSE csr_get_segments;

  l_dyn_sql_qry := l_dyn_sql_qry || ' FROM ' || p_dp_view_name ||
                   ' WHERE batch_id   = '    || p_batch_id;

  IF p_link_value IS NOT NULL THEN
     l_dyn_sql_qry := l_dyn_sql_qry ||' AND link_value = ' || p_link_value;
  END IF;



  -- Execute the query to get the concatenated Segment Vaues String
  OPEN  csr_get_cnct_segs FOR  l_dyn_sql_qry;
  FETCH csr_get_cnct_segs INTO l_cnct_segs;
  CLOSE csr_get_cnct_segs;


  -- This check is required because in some DFFs like 'Person Developer DF'
  -- Context value in the Data Pump Interface Tables is entered even if user
  -- didn't enter any data for the DFF segments. For such DFFs if no data has
  -- been entered in the segments, return NULL
  IF l_ck_all_null_segvals = l_cnct_segs THEN
     RETURN NULL;
  ELSE
     RETURN l_cnct_segs;
  END IF;

  Hr_Utility.set_location('Leaving: '||l_func_name, 10);

END get_concat_dff_segs;
END PQP_OSS_DFF_UTILS;


/
