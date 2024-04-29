--------------------------------------------------------
--  DDL for Package CSTPPPSC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPPPSC" AUTHID CURRENT_USER AS
/* $Header: CSTPPSCS.pls 120.1 2005/06/30 17:02:55 bkuntz noship $ */

PROCEDURE open_period (
                                l_entity_id                     IN      NUMBER,
                                l_cost_type_id                  IN      NUMBER,
                                l_user_id                       IN      NUMBER,
                                l_login_id                      IN      NUMBER,
                                open_period_name                IN      VARCHAR2,
                                open_period_num                 IN      NUMBER,
                                open_period_year                IN      NUMBER,
                                open_period_set_name            IN      VARCHAR2,
				open_period_type		IN	VARCHAR2,
                                last_scheduled_close_date       IN OUT NOCOPY  DATE,
                                l_period_end_date               IN      DATE,

                                prior_open_period               OUT NOCOPY     BOOLEAN,
                                improper_order                  OUT NOCOPY     BOOLEAN,
                                new_pac_period_id               OUT NOCOPY     NUMBER,
                                duplicate_open_period           OUT NOCOPY     BOOLEAN,
                                undefined_cost_groups           OUT NOCOPY     BOOLEAN,
                                user_defined_error              OUT NOCOPY     BOOLEAN,
                                commit_complete                 OUT NOCOPY     BOOLEAN
);

PROCEDURE validate_open_period (
                                l_entity_id                     IN      NUMBER,
                                l_cost_type_id                  IN      NUMBER,
                                l_user_id                       IN      NUMBER,
                                l_login_id                      IN      NUMBER,
                                open_period_name                IN      VARCHAR2,
                                open_period_num                 IN      NUMBER,
                                open_period_year                IN      NUMBER,
                                open_period_set_name            IN      VARCHAR2,
                                open_period_type                IN      VARCHAR2,
                                last_scheduled_close_date       IN OUT NOCOPY  DATE,
                                l_period_end_date               IN      DATE,

                                prior_open_period               OUT NOCOPY     BOOLEAN,
                                improper_order                  OUT NOCOPY     BOOLEAN,
                                new_pac_period_id               OUT NOCOPY     NUMBER,
                                duplicate_open_period           OUT NOCOPY     BOOLEAN,
                                undefined_cost_groups           OUT NOCOPY     BOOLEAN,
                                user_defined_error              OUT NOCOPY     BOOLEAN,
                                commit_complete                 OUT NOCOPY     BOOLEAN
);


PROCEDURE api_close_period(
				errbuf               		OUT NOCOPY 	VARCHAR2,
                             	retcode              		OUT NOCOPY 	NUMBER,
				l_entity_id                     IN      NUMBER,
                                l_cost_type_id                  IN      NUMBER,
                                closing_pac_period_id           IN      NUMBER,
                                closing_period_type             IN      VARCHAR2,
                                l_closing_end_date                IN      VARCHAR2,
                                l_user_id                       IN      NUMBER,
                                l_login_id                      IN      NUMBER,
                                l_last_scheduled_close_date       IN 	VARCHAR2
);



PROCEDURE close_period (
			        l_entity_id                     IN      NUMBER,
                                l_cost_type_id                  IN      NUMBER,
                                closing_pac_period_id           IN      NUMBER,
				closing_period_type		IN	VARCHAR2,
                                closing_end_date                IN      DATE,
                                l_user_id                       IN      NUMBER,
                                l_login_id                      IN      NUMBER,

				last_scheduled_close_date       IN OUT NOCOPY  DATE,
                                end_date_is_passed              OUT NOCOPY     BOOLEAN,
                                incomplete_processing           OUT NOCOPY     BOOLEAN,
				pending_transactions		OUT NOCOPY	BOOLEAN,
				rerun_processor			OUT NOCOPY	BOOLEAN,
                                prompt_to_reclose               OUT NOCOPY     BOOLEAN,
                                undefined_cost_groups           OUT NOCOPY     BOOLEAN,
				backdated_transactions          OUT NOCOPY     BOOLEAN,
                                perpetual_periods_open          OUT NOCOPY     BOOLEAN,
				ap_period_open			OUT NOCOPY	BOOLEAN,
                ar_period_open          OUT NOCOPY  BOOLEAN,
                cogsgen_phase2_notrun   OUT NOCOPY  BOOLEAN,
                cogsgen_phase3_notrun   OUT NOCOPY  BOOLEAN,
                                user_defined_error              OUT NOCOPY     BOOLEAN,
                                commit_complete                 OUT NOCOPY     BOOLEAN,
				req_id				OUT NOCOPY	NUMBER
);

PROCEDURE validate_close_period (
                                l_entity_id                     IN      NUMBER,
                                l_cost_type_id                  IN      NUMBER,
                                closing_pac_period_id           IN      NUMBER,
                                closing_period_type             IN      VARCHAR2,
                                closing_end_date                IN      DATE,
                                l_user_id                       IN      NUMBER,
                                l_login_id                      IN      NUMBER,

                                last_scheduled_close_date       IN OUT NOCOPY  DATE,
                                end_date_is_passed              OUT NOCOPY     BOOLEAN,
                                incomplete_processing           OUT NOCOPY     BOOLEAN,
                                pending_transactions            OUT NOCOPY     BOOLEAN,
                                rerun_processor                 OUT NOCOPY     BOOLEAN,
                                prompt_to_reclose               OUT NOCOPY     BOOLEAN,
                                undefined_cost_groups           OUT NOCOPY     BOOLEAN,
				backdated_transactions		OUT NOCOPY	BOOLEAN,
				perpetual_periods_open		OUT NOCOPY	BOOLEAN,
				ap_period_open			OUT NOCOPY	BOOLEAN,
                ar_period_open          OUT NOCOPY  BOOLEAN,
                cogsgen_phase2_notrun   OUT NOCOPY  BOOLEAN,
                cogsgen_phase3_notrun   OUT NOCOPY  BOOLEAN,
				user_defined_error		OUT NOCOPY	BOOLEAN,
                                commit_complete                 OUT NOCOPY     BOOLEAN
);


END CSTPPPSC;

 

/
