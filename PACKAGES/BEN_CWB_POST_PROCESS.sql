--------------------------------------------------------
--  DDL for Package BEN_CWB_POST_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_POST_PROCESS" AUTHID CURRENT_USER AS
/* $Header: bencwbpp.pkh 120.13.12010000.2 2008/08/05 14:37:57 ubhat ship $ */
/* ===========================================================================+
 * Name
 *   Compensation Workbench Post Process
 * Purpose
 *      This package is used to check validity of parameters passed in via SRS
 *      or via a PL/SQL function or procedure. This package will make a call
 *      to process compensation workbench enrollment for all comp. object for
 *      each person that their default enrollment date is over due.
 *
 * Version Date        Author    Comment
 * -------+-----------+---------+----------------------------------------------
 * 115.0   23-DEC-2002 aprabhak   created
 * 115.1   08-FEB-2002 aprabhak   new version
 * 115.2   08-MAR-2002 aprabhak   added the p_audit_log param
 *                                to compensation_object
 * 115.3   11-MAR-2002 aprabhak   changed the sequence of the personid in
 *                                process routine.
 * 115.4   25-JUN-2002 aprabhak   Corrected the dbdrv comman for bug number
 *                                #2429696
 * 115.5   03-Sep-2002 maagrawa   Removed private procedures.
 * 115.6   02-Jan-04   aprabhak   Global Budgeting
 * 115.8   08-Mar-04   aprabhak   Added missing person_name
 * 115.9   04-Jun-04   aprabhak   Corrected the threading issue
 * 115.10  06-Mar-06   steotia    Enhancing logging for new audit report
 *                                and logging
 * 115.11  06-mar-06   steotia    same as above
 * 115.12  22-Mar-06   steotia    5109850: taking in LE ocrd date as varchar2
 * 115.13  27-Mar-06   steotia    added elmnt_processing_type
 * 115.14  16-Mar-06   steotia    5222874: missing data for recurring element
 * 115.15  14-Jul-06   steotia    Added force close of LE
 * 115.16  13-Sep-06   steotia    5529091: String buffer overflow
 * 115.17  20-Sep-2006 steotia    5531065: Using Performance Overrides (but
 *                                only if used through SS)
 * 115.18  04-Mar-2007 steotia    5505775: CWB Enhancement
 *				  Introduced Person Selection Rule
 * 115.19  25-Apr-2007 steotia    Closing LE of placeholder mgs also.
 * 115.21  25-Apr-2007 steotia    postings on WS Rate Start Date enabled.
 * 115.22  27-May-2008 sgnanama   7126872:Added g_is_cwb_component_plan which is
 *                                used by salary api to distinguish unapproved
 *                                proposal from cwb
 * 115.23  10-Jun-2008  cakunuru  Changed the dbdrv checkfile comment.
 * ==========================================================================+
 */
--
-- Global Cursors and Global variables.
--
TYPE g_number_type IS VARRAY (200) OF NUMBER;

  TYPE g_cache_person_process_object IS RECORD (
    person_id               ben_person_actions.person_id%TYPE
  , person_action_id        ben_person_actions.person_action_id%TYPE
  , object_version_number   ben_person_actions.object_version_number%TYPE
  , per_in_ler_id           ben_person_actions.ler_id%TYPE
  , non_person_cd           ben_person_actions.non_person_cd%TYPE
  );

  TYPE g_exceution_params_rec IS RECORD (
    persons_selected    NUMBER (15)                                                    -- PER_SLCTD
  , persons_proc_succ   NUMBER (15)                                                -- PER_PROC_SUCC
  , persons_errored     NUMBER (15)                                                      -- PER_ERR
  , lf_evt_closed       NUMBER (15)                                                     -- PER_PROC
  , lf_evt_not_closed   NUMBER (15)                                                   -- PER_UNPROC
  , business_group_id   NUMBER (15)
  , benefit_action_id   NUMBER (15)
  , start_date          DATE
  , end_date            DATE
  , start_time          VARCHAR (90)
  , end_time            VARCHAR (90)
  );

  g_exec_param_rec         g_exceution_params_rec;

  TYPE g_cwb_rpt_summary_rec IS RECORD (
    person_id       NUMBER (15)
  , country_code    VARCHAR2(30)
  , person_name     VARCHAR2(240)
  , bg_id           NUMBER (15)
  , bg_name         VARCHAR2 (240)
  , status          VARCHAR2 (2)
  , lf_evt_closed   VARCHAR2 (1)
  , benefit_action_id     NUMBER(15)
  );

  TYPE g_cwb_rpt_person_rec IS RECORD (
    person_rate_id        NUMBER (15)
  , pl_id                 NUMBER (15)
  , person_id             NUMBER (15)
  , group_per_in_ler_id   NUMBER (15)
  , oipl_id               NUMBER (15)
  , group_pl_id           NUMBER (15)
  , group_oipl_id         NUMBER (15)
  , full_name             VARCHAR2 (240)
  , emp_number            VARCHAR2 (30)
  , business_group_name   VARCHAR2 (240)
  , business_group_id     NUMBER (15)
  , manager_name          VARCHAR2 (240)
  , ws_mgr_id             NUMBER (15)
  , pl_name               VARCHAR2 (240)
  , opt_name              VARCHAR2 (240)
  , amount                NUMBER
  , units                 VARCHAR2 (30)
  , performance_rating    VARCHAR2 (30)
  , assignment_changed    VARCHAR2 (30)
  , status                VARCHAR2 (2)
  , lf_evt_closed         VARCHAR2 (1)
  , error_or_warning_text VARCHAR2 (2000)
  , benefit_action_id     NUMBER(15)
  , base_salary_currency  VARCHAR2 (30)
  , currency              VARCHAR2 (30)
  , base_salary           NUMBER
  , elig_salary           NUMBER
  , percent_of_elig_sal   NUMBER
  , base_sal_freq         VARCHAR2(30)
  , pay_ann_factor        NUMBER
  , pl_ann_factor         NUMBER
  , conversion_factor     NUMBER
  , adjusted_amount       NUMBER
  , prev_sal              NUMBER
  , pay_proposal_id       NUMBER
  , pay_basis_id          NUMBER
  , element_entry_id      NUMBER
  , amount_posted         NUMBER
  , exchange_rate         NUMBER
  , effective_date        DATE
  , reason                VARCHAR2(240)
  , eligibility           VARCHAR2(30)
  , fte_factor            NUMBER
  , element_input_value   VARCHAR2(80)		--sg
  , ws_sub_acty_typ_cd    VARCHAR2(30)
  , assignment_id         NUMBER
  , element_entry_value_id NUMBER
  , input_value_id        NUMBER
  , element_type_id       NUMBER
  , eev_screen_entry_value NUMBER
  , uom_precision         NUMBER
  , posted_rating         VARCHAR2(240)
  , rating_type           VARCHAR2(240)
  , prior_job             VARCHAR2(700)
  , posted_job            VARCHAR2(700)
  , proposed_job          VARCHAR2(700)
  , prior_position        VARCHAR2(240)
  , posted_position       VARCHAR2(240)
  , proposed_position     VARCHAR2(240)
  , prior_grade           VARCHAR2(240)
  , posted_grade          VARCHAR2(240)
  , proposed_grade        VARCHAR2(240)
  , prior_group           VARCHAR2(240)
  , posted_group          VARCHAR2(240)
  , proposed_group        VARCHAR2(240)
  , prior_flex1           VARCHAR2(240)
  , posted_flex1          VARCHAR2(240)
  , proposed_flex1        VARCHAR2(240)
  , prior_flex2           VARCHAR2(240)
  , posted_flex2          VARCHAR2(240)
  , proposed_flex2        VARCHAR2(240)
  , prior_flex3           VARCHAR2(240)
  , posted_flex3          VARCHAR2(240)
  , proposed_flex3        VARCHAR2(240)
  , prior_flex4           VARCHAR2(240)
  , posted_flex4          VARCHAR2(240)
  , proposed_flex4        VARCHAR2(240)
  , prior_flex5           VARCHAR2(240)
  , posted_flex5          VARCHAR2(240)
  , proposed_flex5        VARCHAR2(240)
  , prior_flex6           VARCHAR2(240)
  , posted_flex6          VARCHAR2(240)
  , proposed_flex6        VARCHAR2(240)
  , prior_flex7           VARCHAR2(240)
  , posted_flex7          VARCHAR2(240)
  , proposed_flex7        VARCHAR2(240)
  , prior_flex8           VARCHAR2(240)
  , posted_flex8          VARCHAR2(240)
  , proposed_flex8        VARCHAR2(240)
  , prior_flex9           VARCHAR2(240)
  , posted_flex9          VARCHAR2(240)
  , proposed_flex9        VARCHAR2(240)
  , prior_flex10          VARCHAR2(240)
  , posted_flex10         VARCHAR2(240)
  , proposed_flex10       VARCHAR2(240)
  , prior_flex11          VARCHAR2(240)
  , posted_flex11         VARCHAR2(240)
  , proposed_flex11       VARCHAR2(240)
  , prior_flex12          VARCHAR2(240)
  , posted_flex12         VARCHAR2(240)
  , proposed_flex12       VARCHAR2(240)
  , prior_flex13          VARCHAR2(240)
  , posted_flex13         VARCHAR2(240)
  , proposed_flex13       VARCHAR2(240)
  , prior_flex14          VARCHAR2(240)
  , posted_flex14         VARCHAR2(240)
  , proposed_flex14       VARCHAR2(240)
  , prior_flex15          VARCHAR2(240)
  , posted_flex15         VARCHAR2(240)
  , proposed_flex15       VARCHAR2(240)
  , prior_flex16          VARCHAR2(240)
  , posted_flex16         VARCHAR2(240)
  , proposed_flex16       VARCHAR2(240)
  , prior_flex17          VARCHAR2(240)
  , posted_flex17         VARCHAR2(240)
  , proposed_flex17       VARCHAR2(240)
  , prior_flex18          VARCHAR2(240)
  , posted_flex18         VARCHAR2(240)
  , proposed_flex18       VARCHAR2(240)
  , prior_flex19          VARCHAR2(240)
  , posted_flex19         VARCHAR2(240)
  , proposed_flex19       VARCHAR2(240)
  , prior_flex20          VARCHAR2(240)
  , posted_flex20         VARCHAR2(240)
  , proposed_flex20       VARCHAR2(240)
  , prior_flex21          VARCHAR2(240)
  , posted_flex21         VARCHAR2(240)
  , proposed_flex21       VARCHAR2(240)
  , prior_flex22          VARCHAR2(240)
  , posted_flex22         VARCHAR2(240)
  , proposed_flex22       VARCHAR2(240)
  , prior_flex23          VARCHAR2(240)
  , posted_flex23         VARCHAR2(240)
  , proposed_flex23       VARCHAR2(240)
  , prior_flex24          VARCHAR2(240)
  , posted_flex24         VARCHAR2(240)
  , proposed_flex24       VARCHAR2(240)
  , prior_flex25          VARCHAR2(240)
  , posted_flex25         VARCHAR2(240)
  , proposed_flex25       VARCHAR2(240)
  , prior_flex26          VARCHAR2(240)
  , posted_flex26         VARCHAR2(240)
  , proposed_flex26       VARCHAR2(240)
  , prior_flex27          VARCHAR2(240)
  , posted_flex27         VARCHAR2(240)
  , proposed_flex27       VARCHAR2(240)
  , prior_flex28          VARCHAR2(240)
  , posted_flex28         VARCHAR2(240)
  , proposed_flex28       VARCHAR2(240)
  , prior_flex29          VARCHAR2(240)
  , posted_flex29         VARCHAR2(240)
  , proposed_flex29       VARCHAR2(240)
  , prior_flex30          VARCHAR2(2000)
  , posted_flex30         VARCHAR2(2000)
  , proposed_flex30       VARCHAR2(2000)
  , asgn_change_reason    VARCHAR2(240)
  , pending_workflow      VARCHAR2(30)
  , country_code          VARCHAR2(30)
  , lf_evt_ocrd_date      DATE
  , rating_date           DATE
  , new_sal               NUMBER
  , elmnt_processing_type VARCHAR2(30)
  , prev_eev_screen_entry_value NUMBER
  );

  TYPE g_cache_cwb_rpt_person_rec IS TABLE OF g_cwb_rpt_person_rec
    INDEX BY BINARY_INTEGER;

  TYPE g_cache_cwb_rpt_summary_rec IS TABLE OF g_cwb_rpt_summary_rec
    INDEX BY BINARY_INTEGER;


  TYPE g_cache_person_process_rec IS TABLE OF g_cache_person_process_object
    INDEX BY BINARY_INTEGER;

  TYPE g_cache_group_options_rec IS TABLE OF VARCHAR2 (240)
    INDEX BY BINARY_INTEGER;

  TYPE g_cache_actual_plans_rec IS TABLE OF VARCHAR2 (240)
    INDEX BY BINARY_INTEGER;

  TYPE g_cache_actual_options_rec IS TABLE OF VARCHAR2 (240)
    INDEX BY BINARY_INTEGER;

  g_group_plan_name        VARCHAR2 (240);
  g_is_force_on_per        VARCHAR2 (30);
  g_cwb_rpt_person         g_cwb_rpt_person_rec;
  g_cache_cwb_rpt_person   g_cache_cwb_rpt_person_rec;
  g_cache_cwb_sum_person   g_cache_cwb_rpt_summary_rec;
  g_cache_person_process   g_cache_person_process_rec;
  g_cache_group_options    g_cache_group_options_rec;
  g_cache_actual_plans     g_cache_actual_plans_rec;
  g_cache_actual_options   g_cache_actual_options_rec;
  g_is_cwb_component_plan  VARCHAR2 (30);

--
-- *************************************************************************
-- *                          << Procedure: Process >>
-- *************************************************************************
--
  PROCEDURE process (
    errbuf               OUT NOCOPY      VARCHAR2
  , retcode              OUT NOCOPY      NUMBER
  , p_effective_date     IN              VARCHAR2
  , p_validate           IN              VARCHAR2
  , p_pl_id              IN              NUMBER
  , p_lf_evt_orcd_date   IN              VARCHAR2
  , p_person_id          IN              NUMBER DEFAULT NULL
  , p_manager_id         IN              NUMBER DEFAULT NULL
  , p_employees_in_bg    IN              NUMBER DEFAULT NULL
  , p_grant_price_val    IN              NUMBER DEFAULT NULL
  , p_audit_log          IN              VARCHAR2 DEFAULT 'N'
  , p_hidden_audit_log   IN              VARCHAR2
  , p_debug_level        IN              VARCHAR2 DEFAULT 'L'
  , p_bg_id              IN              NUMBER
  , p_is_multi_thread    IN              VARCHAR2 DEFAULT 'Y'
  , p_is_force_on_per    IN              VARCHAR2 DEFAULT 'N'
  , p_is_self_service    IN              VARCHAR2 DEFAULT 'N'
  , p_person_selection_rule_id IN        NUMBER   DEFAULT NULL
  , p_use_rate_start_date IN             VARCHAR2 DEFAULT 'N'
  );

  PROCEDURE do_multithread (
    errbuf                OUT NOCOPY      VARCHAR2
  , retcode               OUT NOCOPY      NUMBER
  , p_validate            IN              VARCHAR2 DEFAULT 'N'
  , p_benefit_action_id   IN              NUMBER
  , p_thread_id           IN              NUMBER
  , p_effective_date      IN              VARCHAR2
  , p_audit_log           IN              VARCHAR2 DEFAULT 'N'
  , p_is_force_on_per     IN              VARCHAR2 DEFAULT 'N'
  , p_is_self_service     IN              VARCHAR2 DEFAULT 'N'
  , p_use_rate_start_date IN              VARCHAR2 DEFAULT 'N'
  );
END;

/
