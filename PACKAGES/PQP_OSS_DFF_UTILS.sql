--------------------------------------------------------
--  DDL for Package PQP_OSS_DFF_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_OSS_DFF_UTILS" AUTHID CURRENT_USER AS
/* $Header: pqphrossutil.pkh 120.0 2005/05/29 02:21:46 appldev noship $ */

-- =============================================================================
-- ~ Package Body Global variables:
-- =============================================================================

   g_pkg           CONSTANT Varchar2(150) := 'pqp_oss_ddf_utils';

   TYPE t_delim_contxt IS RECORD
   (con_seg_delim                fnd_descriptive_flexs.concatenated_segment_delimiter%TYPE
   ,con_col_name                 fnd_descriptive_flexs.context_column_name%TYPE
   );

   TYPE t_seg_valsetid IS RECORD
   (seg_name                     fnd_descr_flex_column_usages.application_column_name%TYPE
   ,flx_valset_id                fnd_descr_flex_column_usages.flex_value_set_id%TYPE
   );


-- =============================================================================
-- ~ parse_segment:
-- =============================================================================
FUNCTION parse_segment
        (p_seg_valset_rec IN t_seg_valsetid)
RETURN Varchar2;


-- =============================================================================
-- ~ get_concat_dff_segs:
-- =============================================================================
FUNCTION get_concat_dff_segs
         (p_ddf_name      IN Varchar2
         ,p_dp_view_name  IN Varchar2
         ,p_batch_id      IN Number
         ,p_app_id        IN Number
         ,p_link_value    IN Number   DEFAULT NULL)
RETURN Varchar2;

END PQP_OSS_DFF_UTILS;


 

/
