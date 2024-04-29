--------------------------------------------------------
--  DDL for Package PAY_JP_PRE_TAX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_JP_PRE_TAX_PKG" AUTHID CURRENT_USER AS
/* $Header: pyjppret.pkh 120.3 2006/09/14 13:38:04 sgottipa noship $ */
	PROCEDURE RUN_ASSACT(
	  p_errbuf                       OUT NOCOPY VARCHAR2,
	  p_retcode                      OUT NOCOPY VARCHAR2,
	  p_locked_assignment_action_id	 IN  pay_assignment_actions.assignment_action_id%TYPE,
          p_locking_assignment_action_id IN  pay_assignment_actions.assignment_action_id%TYPE);
--
        PROCEDURE REFRESH(
                errbuf                  OUT NOCOPY VARCHAR2,
		retcode                 OUT NOCOPY VARCHAR2);
--
        PROCEDURE ROLLBACK_ASSACT(
          p_errbuf            OUT NOCOPY VARCHAR2,
          p_retcode           OUT NOCOPY VARCHAR2,
          p_business_group_id IN  pay_payroll_actions.business_group_id%TYPE,
          p_payroll_id        IN  pay_all_payrolls_f.payroll_id%TYPE,
          p_from_date         IN  DATE,
          p_to_date           IN  DATE);
--
        PROCEDURE RUN_SINGLE_ASSACT(
          p_errbuf               OUT NOCOPY VARCHAR2,
          p_retcode              OUT NOCOPY VARCHAR2,
          p_assignment_action_id IN  pay_assignment_actions.assignment_action_id%TYPE);
--
END PAY_JP_PRE_TAX_PKG;

 

/
