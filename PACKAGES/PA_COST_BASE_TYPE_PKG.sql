--------------------------------------------------------
--  DDL for Package PA_COST_BASE_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_COST_BASE_TYPE_PKG" AUTHID CURRENT_USER as
-- $Header: PAXLOUPS.pls 120.2 2005/08/08 12:40:35 sbharath noship $
procedure check_unique (x_return_status  IN OUT NOCOPY number,
                        x_rowid          IN     varchar2,
                        x_lookup_code    IN     varchar2);

procedure check_references (x_return_status  IN OUT NOCOPY number,
                            x_stage          IN OUT NOCOPY number,
                            x_lookup_code    IN     varchar2);


end PA_COST_BASE_TYPE_PKG;

 

/
