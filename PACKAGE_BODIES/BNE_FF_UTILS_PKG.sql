--------------------------------------------------------
--  DDL for Package Body BNE_FF_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BNE_FF_UTILS_PKG" as
/* $Header: bneffutilb.pls 120.0.12010000.1 2011/04/25 20:16:24 amgonzal noship $ */

--------------------------------------------------------------------------------
--  FUNCTION:   BNE_VALIDATE_CCID                                             --
--                                                                            --
--  DESCRIPTION: Finds if a KFF combination is valid under a FND context.     --
--               It takes into account always Secure Rules associated to      --
--               responsibility being used.                                   --
--                                                                            --
--                                                                            --
--  MODIFICATION HISTORY                                                      --
--  Date        Username Description                                          --
--  15-Apr-2011 amgonzal CREATED                                              --
--------------------------------------------------------------------------------
FUNCTION BNE_VALIDATE_CCID ( p_app_short_name in varchar2
                        , p_key_flex_code in varchar2
                        , p_structure_number in number
                        , p_ccid in number
                        , p_resp_app_id in number
                        , p_resp_id in number
                        , p_user_id in number) RETURN VARCHAR2 IS
  l_result VARCHAR2 (20);
  l_bool_result boolean := False;
BEGIN
    l_bool_result := FND_FLEX_KEYVAL.validate_ccid (
                     appl_short_name => p_app_short_name
                     , key_flex_code => p_key_flex_code
                     , structure_number => p_structure_number
                     , combination_Id => p_ccid
                     , security => 'ENFORCE'
                     , resp_appl_id => p_resp_app_id
                     , resp_id => p_resp_id
                     , user_id => p_user_id);
    if (l_bool_result) then
      return ('Y');
    ELSE
      return ('N');
    END IF;
END;

END;

/
