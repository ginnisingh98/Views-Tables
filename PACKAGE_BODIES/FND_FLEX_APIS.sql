--------------------------------------------------------
--  DDL for Package Body FND_FLEX_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_FLEX_APIS" AS
/* $Header: AFFFAPIB.pls 120.1.12010000.3 2010/05/25 17:13:40 tebarnes ship $ */

--  ------------------------------------------------------------------------
-- 	Gets the segment number corresponding to the **UNIQUE** qualifier
-- 	name entered.  Segment number is the display order of the segment
-- 	not to be confused with the SEGMENT_NUM column of the
-- 	FND_ID_FLEX_SEGMENTS table.  Returns TRUE segment_number if ok,
-- 	or FALSE and sets error using FND_MESSAGES on error.
--  ------------------------------------------------------------------------
FUNCTION get_qualifier_segnum(appl_id          IN  NUMBER,
			      key_flex_code    IN  VARCHAR2,
			      structure_number IN  NUMBER,
			      flex_qual_name   IN  VARCHAR2,
			      segment_number   OUT nocopy NUMBER)
  RETURN BOOLEAN
  IS
     this_segment_num	NUMBER;
BEGIN
   SELECT s.segment_num INTO this_segment_num
     FROM fnd_id_flex_segments s, fnd_segment_attribute_values sav,
     fnd_segment_attribute_types sat
     WHERE s.application_id = appl_id
     AND s.id_flex_code = key_flex_code
     AND s.id_flex_num = structure_number
     AND s.enabled_flag = 'Y'
     AND s.application_column_name = sav.application_column_name
     AND sav.application_id = appl_id
     AND sav.id_flex_code = key_flex_code
     AND sav.id_flex_num = structure_number
     AND sav.attribute_value = 'Y'
     AND sav.segment_attribute_type = sat.segment_attribute_type
     AND sat.application_id = appl_id
     AND sat.id_flex_code = key_flex_code
     AND sat.unique_flag = 'Y'
     AND sat.segment_attribute_type = flex_qual_name
     AND '$Header: AFFFAPIB.pls 120.1.12010000.3 2010/05/25 17:13:40 tebarnes ship $' IS NOT NULL;

   SELECT count(segment_num) INTO segment_number
     FROM fnd_id_flex_segments
     WHERE application_id = appl_id
     AND id_flex_code = key_flex_code
     AND id_flex_num = structure_number
     AND enabled_flag = 'Y'
     AND segment_num <= this_segment_num
     AND '$Header: AFFFAPIB.pls 120.1.12010000.3 2010/05/25 17:13:40 tebarnes ship $' IS NOT NULL;

   return(TRUE);
EXCEPTION
   WHEN OTHERS then
      return(FALSE);
END get_qualifier_segnum;

-- ----------------------------------------------------------------------
FUNCTION get_segment_column(x_application_id  in NUMBER,
			    x_id_flex_code    in VARCHAR2,
			    x_id_flex_num     in NUMBER,
			    x_seg_attr_type   in VARCHAR2,
			    x_app_column_name in out nocopy VARCHAR2)
  return BOOLEAN
  IS
BEGIN
   SELECT application_column_name
     INTO x_app_column_name
     FROM fnd_segment_attribute_values
     WHERE application_id = x_application_id
     AND id_flex_code = x_id_flex_code
     AND id_flex_num  = x_id_flex_num
     AND segment_attribute_type = x_seg_attr_type
     AND attribute_value = 'Y'
     AND '$Header: AFFFAPIB.pls 120.1.12010000.3 2010/05/25 17:13:40 tebarnes ship $' IS NOT NULL;

   RETURN (TRUE);
EXCEPTION
   WHEN OTHERS THEN
      RETURN (FALSE);
END get_segment_column;

-- ----------------------------------------------------------------------
FUNCTION get_segment_info(x_application_id in NUMBER,
			  x_id_flex_code in VARCHAR2,
			  x_id_flex_num in NUMBER,
			  x_seg_num in NUMBER,
			  x_appcol_name out nocopy VARCHAR2,
			  x_seg_name out nocopy VARCHAR2,
			  x_prompt out nocopy VARCHAR2,
			  x_value_set_name out nocopy VARCHAR2)
  RETURN BOOLEAN
  IS
BEGIN
   SELECT application_column_name, segment_name,
     form_left_prompt, flex_value_set_name
     INTO x_appcol_name, x_seg_name,
     x_prompt, x_value_set_name
     FROM fnd_id_flex_segments_vl s, fnd_flex_value_sets vs
     WHERE s.application_id = x_application_id
     AND s.id_flex_code = x_id_flex_code
     AND s.id_flex_num  = x_id_flex_num
     AND s.segment_num = x_seg_num
     AND s.enabled_flag = 'Y'
     AND s.flex_value_set_id = vs.flex_value_set_id
     AND '$Header: AFFFAPIB.pls 120.1.12010000.3 2010/05/25 17:13:40 tebarnes ship $' IS NOT NULL;

   RETURN (TRUE);
EXCEPTION
   WHEN OTHERS THEN
      RETURN (FALSE);
END get_segment_info;

-- ----------------------------------------------------------------------
FUNCTION get_enabled_segment_num(x_application_id in NUMBER,
				 x_conc_prog_name in VARCHAR2,
				 x_num_of_segments out nocopy NUMBER)
  RETURN BOOLEAN
  IS
BEGIN
   SELECT COUNT(*)
     INTO x_num_of_segments
     FROM fnd_descr_flex_column_usages
     WHERE application_id = x_application_id
     AND descriptive_flexfield_name = '$SRS$.'||x_conc_prog_name
     AND enabled_flag = 'Y'
     AND '$Header: AFFFAPIB.pls 120.1.12010000.3 2010/05/25 17:13:40 tebarnes ship $' IS NOT NULL;

   return (TRUE);
EXCEPTION
   WHEN OTHERS THEN
      RETURN (FALSE);
END get_enabled_segment_num;

-- ----------------------------------------------------------------------
FUNCTION get_segment_delimiter(x_application_id in NUMBER,
			       x_id_flex_code in VARCHAR2,
			       x_id_flex_num in NUMBER)
  return VARCHAR2
  IS
     delimiter VARCHAR2(1) default NULL;
BEGIN
   SELECT concatenated_segment_delimiter
     INTO delimiter
     FROM fnd_id_flex_structures
     WHERE application_id = x_application_id
     AND id_flex_code = x_id_flex_code
     AND id_flex_num = x_id_flex_num
     AND '$Header: AFFFAPIB.pls 120.1.12010000.3 2010/05/25 17:13:40 tebarnes ship $' IS NOT NULL;

   RETURN delimiter;

EXCEPTION
   WHEN OTHERS THEN
      RETURN NULL;
END get_segment_delimiter;

-- ----------------------------------------------------------------------
-- This function is for use from GLOBAL libraries only
-- ----------------------------------------------------------------------
FUNCTION gbl_get_segment_delimiter(x_application_id in NUMBER,
				   x_id_flex_code in VARCHAR2,
				   x_id_flex_num in NUMBER)
  RETURN VARCHAR2
  IS
BEGIN
   return get_segment_delimiter(x_application_id, x_id_flex_code,
				x_id_flex_num);
END gbl_get_segment_delimiter;

-- ----------------------------------------------------------------------
FUNCTION is_descr_setup(x_application_id in NUMBER,
			x_desc_flex_name in VARCHAR2)
  return BOOLEAN
  IS
     row_count NUMBER;
BEGIN
    /* Changed existence check logic: Bug 4081024 */
   SELECT 1
     INTO row_count
     FROM fnd_descr_flex_column_usages u, fnd_descr_flex_contexts c
     WHERE u.application_id = x_application_id
     AND u.descriptive_flexfield_name = x_desc_flex_name
     AND c.application_id = u.application_id
     AND c.descriptive_flexfield_name = u.descriptive_flexfield_name
     AND c.descriptive_flex_context_code = u.descriptive_flex_context_code
     AND c.enabled_flag = 'Y'
     AND u.enabled_flag = 'Y'
     AND '$Header: AFFFAPIB.pls 120.1.12010000.3 2010/05/25 17:13:40 tebarnes ship $' IS NOT NULL
     AND ROWNUM = 1;

   return (TRUE);

EXCEPTION
   WHEN no_data_found THEN
      return (FALSE);

END is_descr_setup;

-- ----------------------------------------------------------------------
-- This is for use from GLOBAL libraries only
-- ----------------------------------------------------------------------
FUNCTION gbl_is_descr_setup(x_application_id in NUMBER,
			    x_desc_flex_name in VARCHAR2)
  return BOOLEAN
  IS
BEGIN
   return is_descr_setup(x_application_id, x_desc_flex_name);
END gbl_is_descr_setup;

-- ----------------------------------------------------------------------

FUNCTION is_descr_required(x_application_id in NUMBER,
			   x_desc_flex_name in VARCHAR2)
  return BOOLEAN
  IS
     row_count NUMBER;
BEGIN
    /* Changed existence check logic: Bug 4081024 */
   SELECT 1
     INTO row_count
     FROM fnd_descr_flex_column_usages u, fnd_descr_flex_contexts c
     WHERE u.application_id = x_application_id
     AND u.descriptive_flexfield_name = x_desc_flex_name
     AND c.application_id = u.application_id
     AND c.descriptive_flexfield_name = u.descriptive_flexfield_name
     AND c.descriptive_flex_context_code = u.descriptive_flex_context_code
     AND c.enabled_flag = 'Y'
     AND u.enabled_flag = 'Y'
     AND u.required_flag = 'Y'
     AND '$Header: AFFFAPIB.pls 120.1.12010000.3 2010/05/25 17:13:40 tebarnes ship $' IS NOT NULL
     AND ROWNUM = 1;

   return (TRUE);

EXCEPTION
   WHEN no_data_found THEN
      return (FALSE);

END is_descr_required;


-- ----------------------------------------------------------------------
-- This is for use from GLOBAL libraries only
-- ----------------------------------------------------------------------
-- ----------------------------------------------------------------------
/* Bug 7046189 - logic changed from checking required_flag to checking
 * display_flag. If a  DFF has enabled and displayed segments defined,
 * it should be marked as required for display in a folder block
 * Bug 9074261 - new gbl function created for 7046189 solution */

FUNCTION gbl_is_descr_required(x_application_id in NUMBER,
                           x_desc_flex_name in VARCHAR2)
  return BOOLEAN
  IS
     row_count NUMBER;
BEGIN
    /* Changed existence check logic: Bug 4081024 */
   SELECT 1
     INTO row_count
     FROM fnd_descr_flex_column_usages u, fnd_descr_flex_contexts c
     WHERE u.application_id = x_application_id
     AND u.descriptive_flexfield_name = x_desc_flex_name
     AND c.application_id = u.application_id
     AND c.descriptive_flexfield_name = u.descriptive_flexfield_name
     AND c.descriptive_flex_context_code = u.descriptive_flex_context_code
     AND c.enabled_flag = 'Y'
     AND u.enabled_flag = 'Y'
     AND u.display_flag = 'Y'
     AND '$Header: AFFFAPIB.pls 120.1.12010000.3 2010/05/25 17:13:40 tebarnes ship $' IS NOT NULL
     AND ROWNUM = 1;

   return (TRUE);

EXCEPTION
   WHEN no_data_found THEN
      return (FALSE);

END gbl_is_descr_required;

-- ----------------------------------------------------------------------
PROCEDURE descr_setup_or_required(x_application_id IN NUMBER,
				  x_desc_flex_name IN VARCHAR2,
				  enabled_flag     OUT nocopy VARCHAR2,
				  required_flag    OUT nocopy VARCHAR2)
  IS
BEGIN
   if(fnd_flex_apis.is_descr_setup(x_application_id,
				   x_desc_flex_name)) then
      enabled_flag := 'Y';
    else
      enabled_flag := 'N';
   end if;
   if(fnd_flex_apis.is_descr_required(x_application_id,
				      x_desc_flex_name)) then
      required_flag := 'Y';
    else
      required_flag := 'N';
   end if;
END descr_setup_or_required;

-- ----------------------------------------------------------------------
-- This function is for use from GLOBAL libraries only
-- ----------------------------------------------------------------------
PROCEDURE gbl_descr_setup_or_required(x_application_id IN NUMBER,
				      x_desc_flex_name IN VARCHAR2,
				      enabled_flag     OUT nocopy VARCHAR2,
				      required_flag    OUT nocopy VARCHAR2)
  IS
BEGIN
   if(fnd_flex_apis.is_descr_setup(x_application_id,
                                   x_desc_flex_name)) then
      enabled_flag := 'Y';
    else
      enabled_flag := 'N';
   end if;
   if(fnd_flex_apis.gbl_is_descr_required(x_application_id,
                                      x_desc_flex_name)) then
      required_flag := 'Y';
    else
      required_flag := 'N';
   end if;
END gbl_descr_setup_or_required;


-- ----------------------------------------------------------------------
PROCEDURE get_dff_req_segs_info_private(p_application_id  IN NUMBER,
					p_flexfield_name  IN VARCHAR2,
					p_context_code    IN VARCHAR2,
					px_req_segs_info  IN OUT nocopy dff_required_segments_info)
  IS
     CURSOR c_required_segments(p_application_id IN NUMBER,
				p_flexfield_name IN VARCHAR2,
				p_context_code   IN VARCHAR2)
       IS
	  SELECT end_user_column_name
	    FROM fnd_descr_flex_column_usages
	    WHERE application_id = p_application_id
	    AND descriptive_flexfield_name = p_flexfield_name
	    AND descriptive_flex_context_code = p_context_code
	    AND enabled_flag = 'Y'
	    AND required_flag = 'Y';
BEGIN
   px_req_segs_info.context_code := p_context_code;
   px_req_segs_info.required_segment_count := 0;

   FOR l_required_segment IN c_required_segments(p_application_id, p_flexfield_name, p_context_code) LOOP
      px_req_segs_info.required_segment_count := px_req_segs_info.required_segment_count + 1;
      px_req_segs_info.required_segment_names(px_req_segs_info.required_segment_count) := l_required_segment.end_user_column_name;
   END LOOP;
END get_dff_req_segs_info_private;

-- ----------------------------------------------------------------------
PROCEDURE get_dff_global_req_segs_info(p_application_id               IN NUMBER,
                                       p_flexfield_name               IN VARCHAR2,
                                       x_is_context_segment_required  OUT nocopy BOOLEAN,
                                       x_global_req_segs_info         OUT nocopy dff_required_segments_info)
  IS
     l_context_required_flag fnd_descriptive_flexs.context_required_flag%TYPE;
BEGIN
   --
   -- Get the context segment info:
   --
   BEGIN
      SELECT context_required_flag
	INTO l_context_required_flag
	FROM fnd_descriptive_flexs
	WHERE application_id = p_application_id
	AND descriptive_flexfield_name = p_flexfield_name;
   EXCEPTION
      WHEN OTHERS THEN
	 l_context_required_flag := 'N';
   END;

   IF (l_context_required_flag = 'Y') THEN
      x_is_context_segment_required := TRUE;
    ELSE
      x_is_context_segment_required := FALSE;
   END IF;

   --
   -- Get the 'Global Data Elements' segments info:
   --
   get_dff_req_segs_info_private(p_application_id, p_flexfield_name, 'Global Data Elements',
				 x_global_req_segs_info);

END get_dff_global_req_segs_info;

-- ----------------------------------------------------------------------
PROCEDURE get_dff_context_req_segs_info(p_application_id               IN NUMBER,
                                        p_flexfield_name               IN VARCHAR2,
                                        p_context_code                 IN VARCHAR2,
                                        x_context_req_segs_info        OUT nocopy dff_required_segments_info)
  IS
BEGIN
   --
   -- Get the context sensitive segment info for the given context.
   --
   get_dff_req_segs_info_private(p_application_id, p_flexfield_name, p_context_code,
				 x_context_req_segs_info);

END get_dff_context_req_segs_info;

END FND_FLEX_APIS;

/
