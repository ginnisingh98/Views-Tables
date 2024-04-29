--------------------------------------------------------
--  DDL for Package PA_RBS_PREC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RBS_PREC_PUB" AUTHID CURRENT_USER AS
/* $Header: PARBSPRS.pls 120.0 2005/05/29 15:24:52 appldev noship $ */

FUNCTION	calc_rc_precedence
		(
		resource_type_id	number,
		res_class_id		number
		)
		RETURN NUMBER ;

FUNCTION	calc_rule_precedence
		(
		rule_type_id	        varchar,
		res_class_id		number
		)
		RETURN NUMBER ;

END; --end package PA_RBS_PREC_PUB

 

/
