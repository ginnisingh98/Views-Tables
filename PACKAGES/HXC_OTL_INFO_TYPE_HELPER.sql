--------------------------------------------------------
--  DDL for Package HXC_OTL_INFO_TYPE_HELPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_OTL_INFO_TYPE_HELPER" AUTHID CURRENT_USER AS
/* $Header: hxcinfotypehelp.pkh 120.0 2005/06/03 08:24:59 appldev noship $ */

   Function form_otl_context
      (p_context_prefix in varchar2,
       p_context_code   in varchar2)
      Return varchar2;

   Function build_otl_contexts
      (p_otc_appl_short_name  in fnd_application.application_short_name%type,
       p_otc_flex_name in fnd_descriptive_flexs.descriptive_flexfield_name%type,
       p_context_prefix in varchar2,
       p_flex in FND_DFLEX.dflex_r,
       p_contexts in FND_DFLEX.contexts_dr,
       p_context_index in number,
       p_global_context in FND_DFLEX.context_r,
       p_preserve in boolean)
      Return Boolean;

END hxc_otl_info_type_helper;

 

/
