--------------------------------------------------------
--  DDL for Package PON_BIZRULE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_BIZRULE_PKG" AUTHID CURRENT_USER AS
/* $Header: PONBIZRS.pls 120.0 2005/06/01 20:39:07 appldev noship $ */

PROCEDURE add_rule(p_rule_id    NUMBER);

PROCEDURE delete_rule(p_rule_id    NUMBER);

PROCEDURE edit_rule(p_rule_id    NUMBER);

END PON_BIZRULE_PKG;

 

/
