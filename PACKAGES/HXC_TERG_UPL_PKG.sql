--------------------------------------------------------
--  DDL for Package HXC_TERG_UPL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_TERG_UPL_PKG" AUTHID CURRENT_USER AS
/* $Header: hxctergupl.pkh 115.0 2003/03/23 20:52:22 gpaytonm noship $ */
PROCEDURE load_time_entry_rule_group (
			p_time_entry_rule_group_name in VARCHAR2,
			p_owner                      in VARCHAR2,
			p_custom		     in VARCHAR2);

PROCEDURE load_time_entry_rule_grp_comp (
			p_time_entry_rule_name    in VARCHAR2,
			p_time_entry_group_name   in VARCHAR2,
			p_outcome                 in VARCHAR2,
			p_owner                   in VARCHAR2,
			p_custom                  in VARCHAR2);
END HXC_TERG_UPL_PKG;

 

/
