--------------------------------------------------------
--  DDL for Package BEN_COPY_EXTRACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_COPY_EXTRACT" AUTHID CURRENT_USER AS
/* $Header: bexcpapi.pkh 115.5 2002/12/24 21:34:45 rpillay noship $ */

TYPE FormulaId IS TABLE OF NUMBER(15) INDEX BY BINARY_INTEGER;

PROCEDURE copy_extract(p_extract_dfn_id 	IN NUMBER
		      ,p_new_extract_name 	IN VARCHAR2
		      ,p_business_group_id 	IN NUMBER
		      ,p_legislation_code	IN VARCHAR2
		      ,p_effective_date		IN DATE
		      ,p_formulas	 OUT NOCOPY FormulaID
		      );

FUNCTION fix_name_length(p_curr_name	IN VARCHAR2
			,p_name_maxlen	IN NUMBER
			) RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(fix_name_length, RNDS, WNDS);

END ben_copy_extract;

 

/
