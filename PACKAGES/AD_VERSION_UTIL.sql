--------------------------------------------------------
--  DDL for Package AD_VERSION_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AD_VERSION_UTIL" AUTHID CURRENT_USER as
-- $Header: aduvers.pls 115.7 2004/06/01 10:55:40 sallamse ship $

  function validate_patch_level
            (p_patch_level       in         varchar2,
             p_product_shortname in         varchar2,
             p_error_msg         out nocopy varchar2)
   return boolean;

  procedure get_product_patch_level
             (p_appl_id      in         number,
              p_patch_level  out nocopy varchar2);

  procedure get_product_patch_level
             (p_appl_shortname in         varchar2,
              p_patch_level    out nocopy varchar2);

  procedure set_product_patch_level
             (p_appl_shortname  in varchar2,
              p_patchset_name   in varchar2,
              p_force_flag      in varchar2);

  procedure set_product_patch_level
             (p_appl_shortname  in varchar2,
              p_patchset_name   in varchar2);

  procedure get_patch_level_details
             (p_patch_level    in         varchar2,
              p_base_release   out nocopy varchar2,
              p_appl_shortname out nocopy varchar2,
              p_patchset_name  out nocopy varchar2);

  procedure get_patch_level_details
             (p_patch_level       in         varchar2,
              p_base_release      out nocopy varchar2,
              p_appl_shortname    out nocopy varchar2,
              p_patchset_name     out nocopy varchar2,
              p_patchset_revision out nocopy varchar2);

end;

 

/
