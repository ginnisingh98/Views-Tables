--------------------------------------------------------
--  DDL for Package PAY_DK_GENERAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_DK_GENERAL" AUTHID CURRENT_USER AS
/* $Header: pydkgenr.pkh 120.4.12010000.3 2009/11/18 11:13:47 knadhan ship $ */

 --
 FUNCTION get_tax_card_details
 (p_assignment_id		IN      NUMBER
 ,p_effective_date		IN      DATE
 ,p_tax_card_type		OUT NOCOPY VARCHAR2
 ,p_tax_percentage		OUT NOCOPY NUMBER
 ,p_tax_free_threshold		OUT NOCOPY NUMBER
 ,p_monthly_tax_deduction	OUT NOCOPY NUMBER
 ,p_bi_weekly_tax_deduction	OUT NOCOPY NUMBER
 ,p_weekly_tax_deduction        OUT NOCOPY NUMBER
 ,p_daily_tax_deduction		OUT NOCOPY NUMBER) RETURN NUMBER;
 --

  FUNCTION get_tax_details
 (p_assignment_id		IN      NUMBER
 ,p_effective_date		IN      DATE
 ,p_effective_start_date	OUT NOCOPY DATE
 ,p_effective_end_date		OUT NOCOPY DATE
 ) RETURN NUMBER;

 --

  FUNCTION get_le_employment_details
  (p_org_id			IN	VARCHAR2
  ,p_le_work_hours		OUT NOCOPY NUMBER
  ,p_freq			OUT NOCOPY VARCHAR2
  )RETURN NUMBER;

 --

  FUNCTION get_atp_details
 (p_assignment_id		IN      NUMBER
 ,p_effective_date		IN      DATE
 ,p_effective_start_date	OUT NOCOPY DATE
 ,p_effective_end_date		OUT NOCOPY DATE
 ) RETURN NUMBER;


 --

FUNCTION get_sp_details
 (p_payroll_action_id		IN      NUMBER
 ,p_cvr_number                  OUT NOCOPY VARCHAR2
  ) RETURN NUMBER;


FUNCTION get_atp_override_hours
 (p_assignment_id		IN      NUMBER
 ,p_effective_date		IN      DATE
  ) RETURN NUMBER;

FUNCTION get_holiday_details
	 (p_assignment_id               IN      NUMBER
	 ,p_effective_date              IN      DATE
     ,p_abs_start_date              IN      DATE
     ,p_abs_end_date                IN      DATE
	 ,p_start_date                  OUT NOCOPY DATE
	 ,p_end_date                    OUT NOCOPY DATE
     ,p_over_days                   OUT NOCOPY NUMBER
     ,p_over_hours                  OUT NOCOPY NUMBER
     ) RETURN NUMBER;

FUNCTION get_IANA_charset RETURN VARCHAR2;

FUNCTION get_hour_sal_flag
(p_assignment_id		IN      NUMBER
,p_effective_date		IN      DATE
) RETURN VARCHAR2;

FUNCTION GET_UTF8TOANSI
(p_utf8_str		IN      VARCHAR2
) RETURN VARCHAR2;

/* 9127044 */
FUNCTION get_asg_start_date
(p_business_group_id           IN       NUMBER
,p_assignment_id               IN       NUMBER)
  RETURN DATE;

END PAY_DK_GENERAL;

/
