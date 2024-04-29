--------------------------------------------------------
--  DDL for Package PA_COST_BASE_COST_CODES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_COST_BASE_COST_CODES_PKG" AUTHID CURRENT_USER as
--  $Header: PAXCICIS.pls 120.1 2005/08/23 19:17:56 spunathi noship $

   procedure check_unique(cp_structure  IN varchar2,
			  c_base 	IN varchar2,
			  c_base_type   IN varchar2,
			  icc		IN varchar2,
			  status	IN OUT NOCOPY number);

end PA_COST_BASE_COST_CODES_PKG ;

 

/
