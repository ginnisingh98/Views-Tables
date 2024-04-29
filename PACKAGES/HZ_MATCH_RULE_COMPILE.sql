--------------------------------------------------------
--  DDL for Package HZ_MATCH_RULE_COMPILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_MATCH_RULE_COMPILE" AUTHID CURRENT_USER AS
/*$Header: ARHDQMCS.pls 120.5 2005/10/06 06:15:01 rchanamo noship $ */

PROCEDURE compile_match_rule (
	p_rule_id	IN	NUMBER,
        x_return_status         OUT NOCOPY     VARCHAR2,
        x_msg_count             OUT NOCOPY     NUMBER,
        x_msg_data              OUT NOCOPY     VARCHAR2
);

PROCEDURE compile_all_rules_nolog;

-- VJN INTRODUCED OVERLOADED PROCEDURE FOR COMPILING NEW MATCH RULES
-- INTRODUCED AS PART OF DQM4IMPORT
PROCEDURE compile_all_rules_nolog( p_rule_purpose IN varchar2 );

PROCEDURE compile_all_rules (
        errbuf                  OUT NOCOPY     VARCHAR2,
        retcode                 OUT NOCOPY     VARCHAR2
);

g_context VARCHAR2(20);

END HZ_MATCH_RULE_COMPILE;




 

/
