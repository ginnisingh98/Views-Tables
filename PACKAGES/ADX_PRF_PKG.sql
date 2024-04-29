--------------------------------------------------------
--  DDL for Package ADX_PRF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ADX_PRF_PKG" AUTHID CURRENT_USER AS
 /* $Header: ADXPRFS.pls 120.0.12000000.2 2007/10/01 11:47:38 rdamodar ship $ */

--
-- PRINTLN (Internal)
--   Print messages as needed
-- IN
--    msg
--
procedure PRINTLN(msg in varchar2);

--
-- set_profile
--   Set Profile options via AutoConfig
-- IN
--   p_application_id
--   p_profile_option_name
--   p_level_id
--   p_level_value
--   p_profile_value
--   p_level_value_app_id
--   p_context_name
--   p_update_only
--   p_insert_only
--   p_level_value2
--
PROCEDURE set_profile(p_application_id      in number,
                        p_profile_option_name in varchar2,
                        p_level_id            in number,
                        p_level_value         in number,
                        p_profile_value       in varchar2,
                        p_level_value_app_id  in number,
                        p_context_name        in varchar2,
                        p_update_only         in boolean default FALSE,
                        p_insert_only         in boolean default FALSE,
                        p_level_value2        in varchar2 default NULL);

END  adx_prf_pkg;

 

/
