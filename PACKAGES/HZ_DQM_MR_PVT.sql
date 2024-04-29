--------------------------------------------------------
--  DDL for Package HZ_DQM_MR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_DQM_MR_PVT" AUTHID CURRENT_USER AS
/* $Header: ARHDIMRS.pls 115.1 2003/08/15 22:06:37 cvijayan noship $ */

-------------------------------------------------------------------------
-- gen_pkg_spec: This procedure will generate the package spec
--               for a given match rule
-------------------------------------------------------------------------


PROCEDURE gen_pkg_spec (
        p_pkg_name            IN      VARCHAR2,
        p_match_rule_id       IN      NUMBER
);

-------------------------------------------------------------------------
-- gen_pkg_body: This procedure will generate the package body
--               pertaining to system dup identification ( tca vs tca)
--               for a given match rule.
-------------------------------------------------------------------------


PROCEDURE gen_pkg_body_tca_join (
        p_pkg_name            IN      VARCHAR2,
        p_match_rule_id       IN      NUMBER
);


-------------------------------------------------------------------------
-- gen_pkg_body_int_tca_join: This procedure will generate the package body
--               pertaining to interface dup identification ( interface vs tca)
--               for a given match rule.
-------------------------------------------------------------------------


PROCEDURE gen_pkg_body_int_tca_join (
        p_pkg_name            IN      VARCHAR2,
        p_match_rule_id       IN      NUMBER
);


-------------------------------------------------------------------------
-- gen_pkg_body_int_join: This procedure will generate the package body
--               pertaining to interface dup identification ( interface vs tca)
--               for a given match rule.
-------------------------------------------------------------------------


PROCEDURE gen_pkg_body_int_join(
        p_pkg_name            IN      VARCHAR2,
        p_match_rule_id       IN      NUMBER
);


PROCEDURE gen_footer;


FUNCTION get_match_threshold (p_match_rule_id number)
RETURN number ;

FUNCTION get_auto_merge_threshold (p_match_rule_id number)
RETURN number ;

FUNCTION has_party_filter_attributes (p_match_rule_id number)
RETURN varchar2;


END ;  -- HZ_DQM_MR_PVT



 

/
