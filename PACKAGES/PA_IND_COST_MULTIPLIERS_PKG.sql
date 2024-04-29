--------------------------------------------------------
--  DDL for Package PA_IND_COST_MULTIPLIERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_IND_COST_MULTIPLIERS_PKG" AUTHID CURRENT_USER as
-- $Header: PAXCMULS.pls 120.2.12010000.2 2009/05/08 06:37:20 sgottimu ship $
  procedure copy_multipliers (x_return_status             IN OUT NOCOPY number,
                              x_stage                     IN OUT NOCOPY number,
                              x_ind_rate_sch_rev_id_from  IN number,
                              x_ind_rate_sch_rev_id_to    IN number,
                              x_calling_module 			  IN varchar2);

  procedure check_references (x_return_status             IN OUT NOCOPY number,
                              x_stage                     IN OUT NOCOPY number,
                              x_ind_rate_sch_revision_id  IN     number);

end PA_IND_COST_MULTIPLIERS_PKG;

/
