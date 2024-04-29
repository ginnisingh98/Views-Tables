--------------------------------------------------------
--  DDL for Package IEM_GETMERGEVALUE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_GETMERGEVALUE_PVT" AUTHID CURRENT_USER as
/* $Header: iemvmrgs.pls 115.3 2002/12/04 22:52:11 sboorela shipped $*/
TYPE template_merge_vals IS RECORD (
          field_name   varchar2(100),
          field_value varchar2(100));

TYPE template_merge_tbl IS TABLE OF template_merge_vals
           INDEX BY BINARY_INTEGER;
	PROCEDURE 	IEM_GET_MERGE_VALUES(
			p_msgid in number,
			x_merge_vals OUT NOCOPY template_merge_tbl,
			x_status	out NOCOPY varchar2);

	PROCEDURE 	IEM_GET_MERGE_VALUE(
			p_msgid in number,
			p_merge_key IN varchar2,
			x_merge_val OUT NOCOPY varchar2,
			x_status	out NOCOPY varchar2);

end IEM_GETMERGEVALUE_PVT;

 

/
