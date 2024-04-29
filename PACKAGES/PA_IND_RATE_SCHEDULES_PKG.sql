--------------------------------------------------------
--  DDL for Package PA_IND_RATE_SCHEDULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_IND_RATE_SCHEDULES_PKG" AUTHID CURRENT_USER as
-- $Header: PAXCIRSS.pls 120.1 2005/08/23 19:18:28 spunathi noship $
  procedure check_references(x_return_status        IN OUT NOCOPY number,
                             x_stage                IN OUT NOCOPY number,
                             x_ind_rate_sch_id      IN     number);

  procedure get_defined_type(x_return_status            IN OUT NOCOPY number,
                             x_stage                    IN OUT NOCOPY number,
                             x_ind_rate_schedule_type	IN OUT NOCOPY varchar2);

  procedure check_revisions(x_return_status        IN OUT NOCOPY number,
                            x_stage                IN OUT NOCOPY number,
                            x_ind_rate_sch_id      IN     number);

end PA_IND_RATE_SCHEDULES_PKG;

 

/
