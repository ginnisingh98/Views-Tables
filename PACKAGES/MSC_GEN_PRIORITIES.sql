--------------------------------------------------------
--  DDL for Package MSC_GEN_PRIORITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_GEN_PRIORITIES" AUTHID CURRENT_USER AS
/* $Header: MSCPRIRS.pls 120.1 2006/05/09 10:34:33 eychen noship $  */
 procedure gen_priorities(p_rule_set_id in number) ;
 function all_defined(p_rule_set_id in number) return boolean;
END msc_gen_priorities;

 

/
