--------------------------------------------------------
--  DDL for Package FND_FLEX_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_FLEX_APIS" AUTHID CURRENT_USER AS
/* $Header: AFFFAPIS.pls 120.1.12010000.2 2010/05/25 17:10:27 tebarnes ship $ */

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
  RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(get_qualifier_segnum, WNDS, WNPS);


-- ----------------------------------------------------------------------
FUNCTION get_segment_column(x_application_id  in NUMBER,
			    x_id_flex_code    in VARCHAR2,
			    x_id_flex_num     in NUMBER,
			    x_seg_attr_type   in VARCHAR2,
			    x_app_column_name in out nocopy VARCHAR2)
  RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(get_segment_column, WNDS, WNPS);

-- ----------------------------------------------------------------------
FUNCTION get_segment_info(x_application_id in NUMBER,
			  x_id_flex_code   in VARCHAR2,
			  x_id_flex_num    in NUMBER,
			  x_seg_num        in NUMBER,
			  x_appcol_name    out nocopy VARCHAR2,
			  x_seg_name       out nocopy VARCHAR2,
			  x_prompt         out nocopy VARCHAR2,
			  x_value_set_name out nocopy VARCHAR2)
  RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(get_segment_info, WNDS, WNPS);


-- ----------------------------------------------------------------------
FUNCTION get_enabled_segment_num(x_application_id  in NUMBER,
				 x_conc_prog_name  in VARCHAR2,
				 x_num_of_segments out nocopy NUMBER)
  return BOOLEAN;
PRAGMA RESTRICT_REFERENCES(get_enabled_segment_num, WNDS, WNPS);

-- ----------------------------------------------------------------------
FUNCTION get_segment_delimiter(x_application_id in NUMBER,
			       x_id_flex_code   in VARCHAR2,
			       x_id_flex_num    in NUMBER)
  return VARCHAR2;
PRAGMA RESTRICT_REFERENCES(get_segment_delimiter, WNDS, WNPS);

-- ----------------------------------------------------------------------
FUNCTION gbl_get_segment_delimiter(x_application_id in NUMBER,
				   x_id_flex_code   in VARCHAR2,
				   x_id_flex_num    in NUMBER)
  return VARCHAR2;
PRAGMA RESTRICT_REFERENCES(gbl_get_segment_delimiter, WNDS, WNPS);

-- ----------------------------------------------------------------------
FUNCTION is_descr_setup(x_application_id in NUMBER,
			x_desc_flex_name in VARCHAR2)
  return BOOLEAN;
PRAGMA RESTRICT_REFERENCES(is_descr_setup, WNDS, WNPS);

-- ----------------------------------------------------------------------
FUNCTION gbl_is_descr_setup(x_application_id in NUMBER,
			    x_desc_flex_name in VARCHAR2)
  return BOOLEAN;
PRAGMA RESTRICT_REFERENCES(gbl_is_descr_setup, WNDS, WNPS);

-- ----------------------------------------------------------------------
FUNCTION is_descr_required(x_application_id in NUMBER,
			   x_desc_flex_name in VARCHAR2)
  return BOOLEAN;
PRAGMA RESTRICT_REFERENCES(is_descr_required, WNDS, WNPS);

-- ----------------------------------------------------------------------
FUNCTION gbl_is_descr_required(x_application_id in NUMBER,
                           x_desc_flex_name in VARCHAR2)
  return BOOLEAN;
PRAGMA RESTRICT_REFERENCES(gbl_is_descr_required, WNDS, WNPS);

-- ----------------------------------------------------------------------
PROCEDURE descr_setup_or_required(x_application_id IN NUMBER,
				  x_desc_flex_name IN VARCHAR2,
				  enabled_flag     OUT nocopy VARCHAR2,
				  required_flag    OUT nocopy VARCHAR2);
PRAGMA RESTRICT_REFERENCES(descr_setup_or_required, WNDS, WNPS);

-- ----------------------------------------------------------------------
PROCEDURE gbl_descr_setup_or_required(x_application_id IN NUMBER,
				      x_desc_flex_name IN VARCHAR2,
				      enabled_flag     OUT nocopy VARCHAR2,
				      required_flag    OUT nocopy VARCHAR2);
PRAGMA RESTRICT_REFERENCES(gbl_descr_setup_or_required, WNDS, WNPS);

-- ----------------------------------------------------------------------
TYPE varchar2_table IS TABLE OF VARCHAR2(32000) INDEX BY BINARY_INTEGER;

--
-- Stores the count and the names of required segments of a given DFF context.
-- Segment names are stored in 1 based array. (1 <= i <= required_segment_count)
--
TYPE dff_required_segments_info IS RECORD
  (context_code            fnd_descr_flex_contexts.descriptive_flex_context_code%TYPE,
   required_segment_names  varchar2_table,
   required_segment_count  NUMBER);

-- ----------------------------------------------------------------------
-- Gets the required segment information for global segments of a given descriptive flexfield.
--
-- p_application_id - Application id of the DFF.
-- p_flexfield_name - Name of the DFF.
-- x_is_context_segment_required - Whether or not the context segment is required.
-- x_global_req_segs_info - Information about global required segments.
-- ----------------------------------------------------------------------
PROCEDURE get_dff_global_req_segs_info(p_application_id               IN NUMBER,
                                       p_flexfield_name               IN VARCHAR2,
                                       x_is_context_segment_required  OUT nocopy BOOLEAN,
                                       x_global_req_segs_info         OUT nocopy dff_required_segments_info);

-- ----------------------------------------------------------------------
-- Gets the required segment information for a context of a given descriptive flexfield.
--
-- p_application_id - Application id of the DFF.
-- p_flexfield_name - Name of the DFF.
-- p_context_code - Internal code of the context value.
-- x_context_req_segs_info - Information about context sensitive required segments.
-- ----------------------------------------------------------------------
PROCEDURE get_dff_context_req_segs_info(p_application_id               IN NUMBER,
                                        p_flexfield_name               IN VARCHAR2,
                                        p_context_code                 IN VARCHAR2,
                                        x_context_req_segs_info        OUT nocopy dff_required_segments_info);

END FND_FLEX_APIS;

/
