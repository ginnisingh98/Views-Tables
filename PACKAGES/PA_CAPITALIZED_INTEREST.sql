--------------------------------------------------------
--  DDL for Package PA_CAPITALIZED_INTEREST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CAPITALIZED_INTEREST" AUTHID CURRENT_USER as
-- $Header: PAXCINTS.pls 120.1 2005/08/09 04:16:29 avajain noship $

PROCEDURE cint_compile_schedule(errbuf IN OUT NOCOPY varchar2,
				retcode IN OUT NOCOPY varchar2,
				p_sch_rev_id IN varchar2);

PROCEDURE cint_compile_org_rates (p_rate_sch_rev_id	IN number,
                                  p_ind_rate_sch_id     IN NUMBER,
			 	  p_current_org_id	IN number,
			 	  p_org_id_parent	IN number,
			 	  p_org_struc_ver_id	IN number,
				  p_start_org  		IN number,
				  status		IN OUT NOCOPY  number,
				  stage		        IN OUT NOCOPY number);
END PA_CAPITALIZED_INTEREST;

 

/
