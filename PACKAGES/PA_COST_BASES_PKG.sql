--------------------------------------------------------
--  DDL for Package PA_COST_BASES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_COST_BASES_PKG" AUTHID CURRENT_USER as
-- $Header: PAXCCBAS.pls 120.1 2005/08/23 19:17:11 spunathi noship $
  procedure check_unique (x_return_status  IN OUT NOCOPY number,
                          x_rowid          IN     varchar2,
                          x_cost_base      IN     varchar2,
                          x_cost_base_type IN     varchar2);

  procedure check_ref_cost_base(x_return_status  IN OUT NOCOPY number,
                              x_stage          IN OUT NOCOPY number,
                              x_cost_base      IN     varchar2);

  procedure check_references(x_return_status  IN OUT NOCOPY number,
                             x_stage          IN OUT NOCOPY number,
                             x_cost_base      IN     varchar2,
                             x_cost_base_type IN     varchar2);


end PA_COST_BASES_PKG;

 

/
