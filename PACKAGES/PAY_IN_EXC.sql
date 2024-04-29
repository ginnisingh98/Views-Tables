--------------------------------------------------------
--  DDL for Package PAY_IN_EXC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IN_EXC" AUTHID CURRENT_USER AS
/* $Header: pyinexc.pkh 120.1 2008/06/03 11:21:49 rsaharay noship $ */

PROCEDURE date_ec ( p_owner_payroll_action_id    IN         NUMBER
                  , p_user_payroll_action_id     IN         NUMBER
                  , p_owner_assignment_action_id IN         NUMBER
                  , p_user_assignment_action_id  IN         NUMBER
                  , p_owner_effective_date       IN         DATE
                  , p_user_effective_date        IN         DATE
                  , p_dimension_name             IN         VARCHAR2
                  , p_expiry_information         OUT NOCOPY NUMBER
                  );

PROCEDURE date_ec ( p_owner_payroll_action_id    IN         NUMBER
                  , p_user_payroll_action_id     IN         NUMBER
                  , p_owner_assignment_action_id IN         NUMBER
                  , p_user_assignment_action_id  IN         NUMBER
                  , p_owner_effective_date       IN         DATE
                  , p_user_effective_date        IN         DATE
                  , p_dimension_name             IN         VARCHAR2
                  , p_expiry_information         OUT NOCOPY DATE
                  );

PROCEDURE cal_hy_start(p_effective_date  IN  DATE     ,
                     p_start_date      OUT NOCOPY DATE,
                     p_start_date_code IN  VARCHAR2 DEFAULT NULL,
                     p_payroll_id      IN  NUMBER   DEFAULT NULL,
                     p_bus_grp         IN  NUMBER   DEFAULT NULL,
                     p_action_type     IN  VARCHAR2 DEFAULT NULL,
                     p_asg_action      IN  NUMBER   DEFAULT NULL);


PROCEDURE prov_ytd_start(p_effective_date  IN  DATE     ,
                         p_start_date      OUT NOCOPY DATE,
                         p_start_date_code IN  VARCHAR2 DEFAULT NULL,
                         p_payroll_id      IN  NUMBER   DEFAULT NULL,
                         p_bus_grp         IN  NUMBER   DEFAULT NULL,
                         p_action_type     IN  VARCHAR2 DEFAULT NULL,
                         p_asg_action      IN  NUMBER   DEFAULT NULL);

PROCEDURE hytd_start(p_effective_date  IN  DATE     ,
                     p_start_date      OUT NOCOPY DATE,
                     p_start_date_code IN  VARCHAR2 DEFAULT NULL,
                     p_payroll_id      IN  NUMBER   DEFAULT NULL,
                     p_bus_grp         IN  NUMBER   DEFAULT NULL,
                     p_action_type     IN  VARCHAR2 DEFAULT NULL,
                     p_asg_action      IN  NUMBER   DEFAULT NULL);

PROCEDURE start_code_pmth ( p_effective_date     IN         DATE
                          , p_start_date         OUT NOCOPY DATE
			  , p_payroll_id         IN         NUMBER
			  , p_bus_grp            IN         NUMBER
			  , p_asg_action         IN         NUMBER
			  );

PROCEDURE start_code_p10mth ( p_effective_date     IN         DATE
                            , p_start_date         OUT NOCOPY DATE
			    , p_payroll_id         IN         NUMBER
			    , p_bus_grp            IN         NUMBER
			    , p_asg_action         IN         NUMBER
			   );


END pay_in_exc;

/
