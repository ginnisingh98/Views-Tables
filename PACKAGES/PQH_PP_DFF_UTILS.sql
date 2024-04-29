--------------------------------------------------------
--  DDL for Package PQH_PP_DFF_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_PP_DFF_UTILS" AUTHID CURRENT_USER AS
/* $Header: pqhppdff.pkh 120.0 2006/02/06 14:44:30 rthiagar noship $ */

-- =============================================================================
-- ~Global variables:
-- =============================================================================

   g_pkg           CONSTANT Varchar2(150) := 'pqh_ddf_utils';
   g_desc_flex_content  fnd_descr_flex_column_usages.descriptive_flex_context_code%TYPE;
   g_delimiter          fnd_descriptive_flexs.concatenated_segment_delimiter%TYPE;


-- =============================================================================
-- ~ get_concat_dff_segs:
-- =============================================================================
FUNCTION get_concat_dff_segs
         (p_context_value In Varchar2
          ,p_attribute1   In Varchar2
          ,p_attribute2   In Varchar2
          ,p_attribute3   In Varchar2
          ,p_attribute4   In Varchar2
          ,p_attribute5   In Varchar2
          ,p_attribute6   In Varchar2
          ,p_attribute7   In Varchar2
          ,p_attribute8   In Varchar2
          ,p_attribute9   In Varchar2
          ,p_attribute10   In Varchar2
          ,p_attribute11   In Varchar2
          ,p_attribute12   In Varchar2
          ,p_attribute13   In Varchar2
          ,p_attribute14   In Varchar2
          ,p_attribute15   In Varchar2
          ,p_attribute16   In Varchar2
          ,p_attribute17   In Varchar2
          ,p_attribute18   In Varchar2
          ,p_attribute19   In Varchar2
          ,p_attribute20   In Varchar2
          )
RETURN Varchar2;

END PQH_PP_DFF_UTILS;


 

/
