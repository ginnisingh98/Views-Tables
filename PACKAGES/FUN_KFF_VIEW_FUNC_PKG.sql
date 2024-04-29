--------------------------------------------------------
--  DDL for Package FUN_KFF_VIEW_FUNC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_KFF_VIEW_FUNC_PKG" AUTHID CURRENT_USER AS
/* $Header: funxtmkffvfcs.pls 120.0 2005/06/08 20:40:19 kmizuta noship $ */

function derive_format_attributes(p_value_set_id in number,
                                  p_qualifiers in varchar2) return varchar2;

function format_attributes(p_value_set_id in number,
                           p_compiled_value_attributes in varchar2) return varchar2;

function is_valid_on_security_rules(p_value_set_id in number,
                                    p_flex_value in varchar2) return varchar2;

END;

 

/
