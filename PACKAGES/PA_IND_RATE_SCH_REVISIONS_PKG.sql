--------------------------------------------------------
--  DDL for Package PA_IND_RATE_SCH_REVISIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_IND_RATE_SCH_REVISIONS_PKG" AUTHID CURRENT_USER as
-- $Header: PAXCIRRS.pls 120.1.12000000.3 2007/04/18 05:46:19 svivaram ship $
  procedure check_dates(x_return_status		IN OUT NOCOPY number,
			x_stage			IN OUT NOCOPY number,
			x_ind_rate_sch_id	IN     number,
			x_start_date_active	IN     date,
			x_end_date_active	IN     date,
			x_max_revision_id	IN OUT NOCOPY number,
			x_max_end_date_active	IN OUT NOCOPY date);

  procedure start_to_gl(x_return_status         IN OUT NOCOPY number,
                        x_stage                 IN OUT NOCOPY number,
                        x_start_date_active     IN     date);

  procedure end_to_gl(x_return_status         IN OUT NOCOPY number,
                      x_stage                 IN OUT NOCOPY number,
                      x_end_date_active       IN     date);

  procedure check_references(x_return_status            IN OUT NOCOPY number,
                             x_stage                    IN OUT NOCOPY number,
                             x_ind_rate_sch_revision_id IN     number);

 procedure check_end_date_limit(x_return_status    IN OUT NOCOPY number,
                               x_end_date_active   IN date,
                               x_ind_rate_sch_revision_id IN number);

  procedure check_start_date(x_return_status            IN OUT NOCOPY number,
                             x_stage                    IN OUT NOCOPY number,
                             x_prev_end_date_active     IN OUT NOCOPY date,
                             x_prev_revision_id         IN OUT NOCOPY number,
                             x_ind_rate_sch_revision_id IN     number,
                             x_ind_rate_sch_id          IN     number,
                             x_start_date_active        IN     date);

  procedure check_end_date(x_return_status            IN OUT NOCOPY number,
                           x_stage                    IN OUT NOCOPY number,
                           x_next_start_date_active   IN OUT NOCOPY date,
                           x_next_revision_id         IN OUT NOCOPY number,
                           x_ind_rate_sch_revision_id IN     number,
                           x_ind_rate_sch_id          IN     number,
                           x_end_date_active          IN     date);

  procedure check_multipliers(x_ind_rate_sch_revision_id IN     number,
			      x_return_status            IN OUT NOCOPY number,
                              x_stage                    IN OUT NOCOPY number);

  procedure check_ready_compile(x_ind_rate_sch_revision_id IN     number,
				x_ready_compile_flag	   IN OUT NOCOPY varchar2,
                                x_ready_for_compile        IN OUT NOCOPY varchar2,  /*2933915*/
				x_compiled_flag	   	   IN OUT NOCOPY varchar2,
			        x_return_status            IN OUT NOCOPY number,
                                x_stage                    IN OUT NOCOPY number);


end PA_IND_RATE_SCH_REVISIONS_PKG;

 

/
