--------------------------------------------------------
--  DDL for Package PAY_CONSOLIDATION_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CONSOLIDATION_SETS_PKG" AUTHID CURRENT_USER as
/* $Header: pycss01t.pkh 115.0 99/07/17 05:55:53 porting ship $ */
--
PROCEDURE get_next_sequence(p_consolidation_set_id       IN out  number);
--
PROCEDURE check_unique_name(p_consolidation_set_name     in varchar2,
			    p_business_group_id          in number,
			    p_rowid                      in varchar2);
--
PROCEDURE check_delete(p_business_group_id       in number,
		       p_consolidation_set_id    in number);
--
END PAY_CONSOLIDATION_SETS_PKG;

 

/
