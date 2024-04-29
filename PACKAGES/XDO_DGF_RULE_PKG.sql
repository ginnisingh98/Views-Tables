--------------------------------------------------------
--  DDL for Package XDO_DGF_RULE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDO_DGF_RULE_PKG" AUTHID CURRENT_USER AS
/* $Header: XDODGFRLS.pls 120.0 2008/01/19 00:13:31 bgkim noship $ */


procedure evaluate_rules(p_rule_table IN OUT NOCOPY XDO_DGF_RPT_PKG.RULE_TABLE_TYPE)
;

function evaluate_rules(p_rule_table  IN XDO_DGF_RPT_PKG.RULE_TABLE_TYPE)
return XDO_DGF_RPT_PKG.RULE_TABLE_TYPE
;

function eval_simple_rule(p_rule_var             IN varchar2,
                          p_rule_operator        IN varchar2,
                          p_rule_values          IN varchar2,
                          p_rule_values_datatype varchar2)

 return boolean;

END;

/
