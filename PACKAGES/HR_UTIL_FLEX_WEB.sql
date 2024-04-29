--------------------------------------------------------
--  DDL for Package HR_UTIL_FLEX_WEB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_UTIL_FLEX_WEB" AUTHID CURRENT_USER as
/* $Header: hrutlflw.pkh 115.0 99/07/17 18:18:26 porting ship $ */
--
g_flexfield_not_found      exception;
g_both_seg_name_invalid    exception;
g_seg_name1_invalid        exception;
g_seg_name2_invalid        exception;
--
-- ---------------------------------------------------------------------------
-- -------------------- <get_keyflex_mapped_column_name> ---------------------
-- ---------------------------------------------------------------------------
Procedure get_keyflex_mapped_column_name
         (p_business_group_id      in number
         ,p_keyflex_code           in varchar2
         ,p_mapped_col_name1       out varchar2
         ,p_mapped_col_name2       out varchar2
         ,p_keyflex_id_flex_num    out number
         ,p_segment_separator      out varchar2
         ,p_warning                out varchar2);
--
-- ---------------------------------------------------------------------------
-- ------------------------< validate_seg_col_name > -------------------------
------------------------------------------------------------------------------
Procedure validate_seg_col_name(p_segment_name1  in varchar2 default null
                               ,p_segment_name2  in varchar2 default null
                               ,p_app_short_name in varchar2
                               ,p_flex_code      in varchar2
                               ,p_id_flex_num    in number
                               ,p_segment_name_valid  out varchar2
                               ,p_tbl_col_name_used   out varchar2
                               ,p_flexfield_rec       out
                                       fnd_flex_key_api.flexfield_type
                               ,p_structure_rec       out
                                       fnd_flex_key_api.structure_type);
--
-- ---------------------------------------------------------------------------
-- ------------------------- <get_keyflex_info> ------------------------------
-- ---------------------------------------------------------------------------
Procedure get_keyflex_info(p_app_short_name        in varchar2
                          ,p_flex_code             in varchar2
                          ,p_id_flex_num           in number
                          ,p_segment_name1         in varchar2 default null
                          ,p_segment_name2         in varchar2 default null
                          ,p_mapped_tbl_col_name1  out varchar2
                          ,p_mapped_tbl_col_name2  out varchar2
                          ,p_flexfield_rec         in
                                       fnd_flex_key_api.flexfield_type
                          ,p_structure_rec         in
                                       fnd_flex_key_api.structure_type);
-- ---------------------------------------------------------------------------
--
END hr_util_flex_web;

 

/
