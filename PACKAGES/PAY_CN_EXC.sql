--------------------------------------------------------
--  DDL for Package PAY_CN_EXC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CN_EXC" AUTHID CURRENT_USER AS
/* $Header: pycnexc.pkh 120.0 2005/05/29 01:58:41 appldev noship $ */

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

PROCEDURE start_code_p12mth ( p_effective_date     IN         DATE
                            , p_start_date         OUT NOCOPY DATE
			    , p_payroll_id         IN         NUMBER
			    , p_bus_grp            IN         NUMBER
			    , p_asg_action         IN         NUMBER
			    );

PROCEDURE start_code_pmth ( p_effective_date     IN         DATE
                          , p_start_date         OUT NOCOPY DATE
			  , p_payroll_id         IN         NUMBER
			  , p_bus_grp            IN         NUMBER
			  , p_asg_action         IN         NUMBER
			  );

PROCEDURE start_code_pyear ( p_effective_date     IN         DATE
                           , p_start_date         OUT NOCOPY DATE
			   , p_payroll_id         IN         NUMBER
			   , p_bus_grp            IN         NUMBER
			   , p_asg_action         IN         NUMBER
			   );

END pay_cn_exc;

 

/
