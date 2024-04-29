--------------------------------------------------------
--  DDL for Package PA_COST_BASE_VIEW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_COST_BASE_VIEW_PKG" AUTHID CURRENT_USER as
--  $Header: PAXCICVS.pls 120.1 2005/08/23 19:18:10 spunathi noship $

   procedure check_unique(cp_structure  IN varchar2,
			  c_base 	IN varchar2,
			  c_base_type   IN varchar2,
			  status	IN OUT NOCOPY number);

   procedure check_references(cp_structure IN     varchar2,
			      c_base	   IN     varchar2,
			      c_base_type  IN     varchar2,
			      status	   IN OUT NOCOPY number);

   procedure check_rev_compiled(cp_structure IN     varchar2,
			        status	     IN OUT NOCOPY number);

   procedure cascade_delete(cp_structure IN     varchar2,
			    c_base	 IN     varchar2,
			    c_base_type  IN     varchar2,
			    status	 IN OUT NOCOPY number);

end PA_COST_BASE_VIEW_PKG ;

 

/
