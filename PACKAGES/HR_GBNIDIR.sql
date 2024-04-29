--------------------------------------------------------
--  DDL for Package HR_GBNIDIR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_GBNIDIR" AUTHID CURRENT_USER as
/* $Header: pygbnicd.pkh 120.0.12010000.2 2008/12/03 07:31:21 npannamp ship $ */
--
-----------------------------------------------------------------
  function ni_able_dir_ytd
     (
      p_assignment_action_id       IN number ,
      p_category  		   IN varchar2 ,
      p_pension                    IN varchar2
     ) return number;
pragma restrict_references (ni_able_dir_ytd, WNDS, WNPS);
--
  function ni_balances_per_dir_td_ytd
     (
      p_assignment_action_id   IN    number,
      p_global_name            IN    varchar2
     )
      return number ;
--
  function director_weeks
     (
      p_assignment_id              IN number
     ) return number;
pragma restrict_references (director_weeks, WNDS, WNPS);
--
--
  function validate_user_value
     ( p_user_table    IN             varchar2,
       p_user_column   IN             varchar2,
       p_user_value    IN             varchar2
     )
      return number;
pragma restrict_references (validate_user_value, WNDS, WNPS);
--
  function user_value_by_label
     ( p_user_table    IN             varchar2,
       p_user_column   IN             varchar2,
       p_label         IN             varchar2)
      return number ;
pragma restrict_references (user_value_by_label, WNDS, WNPS);
--
  function user_range_by_label
     ( p_user_table    IN             varchar2,
       p_high_or_low   IN             varchar2,
       p_label         IN             varchar2)
      return number ;
pragma restrict_references (user_range_by_label, WNDS, WNPS);
--
  function ni_co_rate_from_ci_rate
       ( p_ci_rate         IN             number)
      return number ;
pragma restrict_references (ni_co_rate_from_ci_rate, WNDS, WNPS);
--
  function ni_cm_rate_from_ci_rate
       ( p_ci_rate         IN             number)
      return number ;
pragma restrict_references (ni_cm_rate_from_ci_rate, WNDS, WNPS);
--
  function statutory_period_start_date
       ( p_assignment_action_id number )
      return date ;

pragma restrict_references (statutory_period_start_date, WNDS, WNPS);
--
  function statutory_period_number
       ( p_date in date ,
         p_period_type in varchar2 )
      return number ;

pragma restrict_references (statutory_period_number, WNDS, WNPS);
--
--
  function ni_able_per_ptd
     (
      p_assignment_action_id       IN number ,
      p_category  		   IN varchar2 ,
      p_pension                    IN varchar2
     ) return number;
--pragma restrict_references (ni_able_per_ptd, WNDS, WNPS);
--
  function count_assignments
     (
      p_assignment_id  IN             number
     )
      return number ;

pragma restrict_references (count_assignments, WNDS, WNPS);
--
  function count_assignments_on_payroll
     (
      p_date IN date,
      p_payroll_id in number
     )
      return number ;

pragma restrict_references (count_assignments_on_payroll, WNDS, WNPS);
--
  function period_type_check
      ( p_assignment_id number )
      return number ;

pragma restrict_references (period_type_check, WNDS, WNPS);
--
  function PAYE_STAT_PERIOD_START_DATE
       ( p_assignment_action_id number )
      return date;
--
pragma restrict_references (paye_stat_period_start_date, WNDS, WNPS);

  function ELEMENT_ENTRY_VALUE
       ( p_assignment_id number,
         p_effective_date date,
         p_element_name varchar2,
         p_input_name varchar2)
      return varchar2;
--
pragma restrict_references (element_entry_value, WNDS, WNPS);
--
  function NI_ELEMENT_ENTRY_VALUE
       ( p_assignment_id number,
         p_effective_date date)
      return varchar2;
--
pragma restrict_references (ni_element_entry_value, WNDS);
--
  function NI_BALANCES_PER_NI_PTD
     (
      p_assignment_action_id   IN    number,
      p_global_name            IN    varchar2
     )
      return number ;
--
  function statutory_period_date_mode (p_assignment_id  IN NUMBER,
				       p_effective_date IN DATE) RETURN DATE;
  pragma restrict_references (statutory_period_date_mode, WNDS, WNPS);
--
  function niable_bands (L_NIABLE      IN NUMBER,
                         L_NI_CAT_ABLE IN NUMBER,
                         L_TOT_NIABLE  IN NUMBER,
                         L_LEL         IN NUMBER,
                         L_EET         IN NUMBER,
                         L_ET          IN NUMBER,
                         L_UEL         IN NUMBER,
                         NI_ABLE_LEL   IN OUT NOCOPY NUMBER,
                         NI_ABLE_EET   IN OUT NOCOPY NUMBER,
                         NI_ABLE_ET    IN OUT NOCOPY NUMBER,
                         NI_ABLE_UEL   IN OUT NOCOPY NUMBER,
                         NI_UPPER      IN OUT NOCOPY NUMBER,
                         NI_LOWER      IN OUT NOCOPY NUMBER
                                       ) RETURN NUMBER;

--7312374 Start: Over Loaded function Added for UAP.
  function niable_bands (L_NIABLE      IN NUMBER,
                         L_NI_CAT_ABLE IN NUMBER,
                         L_TOT_NIABLE  IN NUMBER,
                         L_LEL         IN NUMBER,
                         L_EET         IN NUMBER,
                         L_ET          IN NUMBER,
                         L_UAP         IN NUMBER, -- EOY 08/09
                         L_UEL         IN NUMBER,
                         NI_ABLE_LEL   IN OUT NOCOPY NUMBER,
                         NI_ABLE_EET   IN OUT NOCOPY NUMBER,
                         NI_ABLE_ET    IN OUT NOCOPY NUMBER,
                         NI_ABLE_UAP   IN OUT NOCOPY NUMBER, -- EOY 08/09
                         NI_ABLE_UEL   IN OUT NOCOPY NUMBER,
                         NI_UPPER      IN OUT NOCOPY NUMBER,
                         NI_LOWER      IN OUT NOCOPY NUMBER
                                       ) RETURN NUMBER;
--7312374 End
end hr_gbnidir;

/
