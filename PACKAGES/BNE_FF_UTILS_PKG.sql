--------------------------------------------------------
--  DDL for Package BNE_FF_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BNE_FF_UTILS_PKG" AUTHID CURRENT_USER as
/* $Header: bneffutils.pls 120.0.12010000.1 2011/04/25 20:15:42 amgonzal noship $ */

function BNE_VALIDATE_CCID  ( p_app_short_name in varchar2
                        , p_key_flex_code in varchar2
                        , p_structure_number in number
                        , p_ccid in number
                        , p_resp_app_id in number
                        , p_resp_id in number
                        , p_user_id in number) RETURN VARCHAR2;

end BNE_FF_UTILS_PKG;

/
