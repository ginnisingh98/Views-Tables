--------------------------------------------------------
--  DDL for Package PA_COST_BASE_EXP_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_COST_BASE_EXP_TYPES_PKG" AUTHID CURRENT_USER as
--  $Header: PAXCICES.pls 120.1 2005/08/23 19:17:49 spunathi noship $

   procedure check_unique(cp_structure  IN varchar2,
                          c_base_type   IN varchar2,
                          exp_type      IN varchar2,
                          status        IN OUT NOCOPY number);

    procedure check_structure_used(structure IN varchar2,
                                  status IN OUT NOCOPY number,
                                  stage  IN OUT NOCOPY number);

   procedure get_description(exp_type IN varchar2, descpt IN OUT NOCOPY varchar2);

end PA_COST_BASE_EXP_TYPES_PKG ;

 

/
