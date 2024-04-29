--------------------------------------------------------
--  DDL for Package PQH_GL_POSTING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_GL_POSTING" AUTHID CURRENT_USER AS
/* $Header: pqglpost.pkh 120.1.12010000.1 2008/07/28 12:57:13 appldev ship $ */

-- Type to hold mapped segments and values
TYPE t_map_struct_type IS RECORD
(
 gl_segment_name       VARCHAR2(30),
 cost_segment_name     VARCHAR2(30),
 segment_value         VARCHAR2(100)
);

-- PL / SQL table based on the above structure
TYPE t_map_tab IS TABLE OF t_map_struct_type
  INDEX BY BINARY_INTEGER;

-- Type to hold segments and values
TYPE t_seg_val_type IS RECORD
(
 cost_segment_name     VARCHAR2(30),
 segment_value         VARCHAR2(100)
 );

-- PL / SQL table based on the above structure
TYPE t_seg_val_tab IS TABLE OF t_seg_val_type
  INDEX BY BINARY_INTEGER;

-- Type to hold period_name and amounts
TYPE t_period_amt_type IS RECORD
(
 period_id                   NUMBER(15),
 period_name                 VARCHAR2(30),
 accounting_date             DATE,
 cost_allocation_keyflex_id  NUMBER(15),
 project_id                  NUMBER(15),
 award_id                    NUMBER(15),
 task_id                     NUMBER(15),
 expenditure_type            VARCHAR2(30),
 organization_id             NUMBER(15),
 code_combination_id         NUMBER(15),
 amount1                     NUMBER,
 amount2                     NUMBER,
 amount3                     NUMBER
);

-- PL / SQL table based on the above structure
TYPE t_period_amt_tab IS TABLE OF t_period_amt_type
  INDEX BY BINARY_INTEGER;

-- global variables for the PL/SQL table of record defined above
   g_map_tab          t_map_tab;
   g_seg_val_tab      t_seg_val_tab;
   g_period_amt_tab   t_period_amt_tab;


PROCEDURE post_budget
(
 p_budget_version_id              IN  pqh_budget_versions.budget_version_id%TYPE,
 p_validate                       IN  boolean    default false,
 p_status                         OUT NOCOPY varchar2
);

PROCEDURE conc_post_budget
(
 errbuf                           OUT  NOCOPY VARCHAR2,
 retcode                          OUT  NOCOPY VARCHAR2,
 p_budget_version_id              IN  pqh_budget_versions.budget_version_id%TYPE,
 p_validate                       IN  varchar2    default 'N'
);

PROCEDURE populate_globals
(
  p_budget_version_id             IN  pqh_budget_versions.budget_version_id%TYPE
);

PROCEDURE populate_period_amt_tab
(
 p_budget_detail_id IN pqh_budget_details.budget_detail_id%TYPE
);

PROCEDURE update_period_amt_tab
(
 p_budget_detail_id IN pqh_budget_details.budget_detail_id%TYPE
);

PROCEDURE populate_pqh_gl_interface
(
 p_budget_detail_id     IN pqh_budget_details.budget_detail_id%TYPE
);

PROCEDURE insert_pqh_gl_interface
(
 p_budget_detail_id            IN  pqh_gl_interface.budget_detail_id%TYPE,
 p_period_name                 IN  pqh_gl_interface.period_name%TYPE,
 p_accounting_date             IN  pqh_gl_interface.accounting_date%TYPE,
 p_code_combination_id         IN  pqh_gl_interface.code_combination_id%TYPE,
 p_cost_allocation_keyflex_id  IN  pqh_gl_interface.cost_allocation_keyflex_id%TYPE,
 p_amount                      IN  pqh_gl_interface.amount_dr%TYPE,
 p_currency_code               IN  pqh_gl_interface.currency_code%TYPE
 );

PROCEDURE update_pqh_gl_interface
(
 p_budget_detail_id            IN  pqh_gl_interface.budget_detail_id%TYPE,
 p_period_name                 IN  pqh_gl_interface.period_name%TYPE,
 p_accounting_date             IN  pqh_gl_interface.accounting_date%TYPE,
 p_code_combination_id         IN  pqh_gl_interface.code_combination_id%TYPE,
 p_cost_allocation_keyflex_id  IN  pqh_gl_interface.cost_allocation_keyflex_id%TYPE,
 p_amount                      IN  pqh_gl_interface.amount_dr%TYPE,
 p_currency_code               IN  pqh_gl_interface.currency_code%TYPE
);

PROCEDURE populate_gl_tables;

PROCEDURE update_gl_status;

PROCEDURE get_gl_ccid
(
  p_budget_detail_id             IN    pqh_budget_details.budget_detail_id%TYPE,
  p_budget_period_id             IN   pqh_budget_periods.budget_period_id%TYPE,
  p_cost_allocation_keyflex_id   IN    pay_cost_allocation_keyflex.cost_allocation_keyflex_id%TYPE,
  p_code_combination_id          OUT   NOCOPY gl_code_combinations.code_combination_id%TYPE
);

FUNCTION get_value_from_array ( p_segment_name  IN  varchar2 )
  RETURN VARCHAR2;


PROCEDURE get_gl_period
(
  p_budget_period_id              IN   pqh_budget_periods.budget_period_id%TYPE,
  p_gl_period_statuses_rec        OUT  NOCOPY gl_period_statuses%ROWTYPE
);

FUNCTION get_amt1 ( p_budget_fund_src_id  IN  pqh_budget_fund_srcs.budget_fund_src_id%TYPE )
  RETURN NUMBER;

FUNCTION get_amt2 ( p_budget_fund_src_id  IN  pqh_budget_fund_srcs.budget_fund_src_id%TYPE )
  RETURN NUMBER;

FUNCTION get_amt3 ( p_budget_fund_src_id  IN  pqh_budget_fund_srcs.budget_fund_src_id%TYPE )
  RETURN NUMBER;

PROCEDURE  end_log;

PROCEDURE set_bdt_log_context
(
  p_budget_detail_id        IN  pqh_budget_details.budget_detail_id%TYPE,
  p_log_context             OUT NOCOPY pqh_process_log.log_context%TYPE
);

PROCEDURE set_bpr_log_context
(
 p_budget_period_id        IN  pqh_budget_periods.budget_period_id%TYPE,
 p_log_context              OUT NOCOPY pqh_process_log.log_context%TYPE
);

PROCEDURE set_bfs_log_context
(
  p_cost_allocation_keyflex_id       IN  pay_cost_allocation_keyflex.cost_allocation_keyflex_id%TYPE,
  p_log_context                     OUT NOCOPY pqh_process_log.log_context%TYPE
);

PROCEDURE populate_budget_gl_map
(
  p_budget_id             IN  pqh_budgets.budget_id%TYPE
);

PROCEDURE reverse_budget_details
(
 p_period_name              IN  pqh_gl_interface.period_name%TYPE,
 p_currency_code            IN  pqh_gl_interface.currency_code%TYPE,
 p_code_combination_id      IN  pqh_gl_interface.code_combination_id%TYPE
);

PROCEDURE populate_period_enc_tab
(
 p_budget_detail_id IN pqh_budget_details.budget_detail_id%TYPE
);
-- Type to hold old budget detail records
TYPE t_old_bdgt_dtls_type IS RECORD
(
 budget_version_id           NUMBER(15),
 budget_detail_id            NUMBER(15),
 period_name                 VARCHAR2(30),
 accounting_date             DATE,
 cost_allocation_keyflex_id  NUMBER(15),
 code_combination_id         NUMBER(15),
 project_id                  NUMBER(15),
 award_id                    NUMBER(15),
 task_id                     NUMBER(15),
 expenditure_type            VARCHAR2(30),
 organization_id             NUMBER(15),
 currency_code               VARCHAR2(30),
 amount_dr                   NUMBER,
 amount_cr                   NUMBER,
 reverse_flag                VARCHAR2(30)
);

-- PL / SQL table based on the above structure
TYPE t_old_bdgt_dtls_tab IS TABLE OF t_old_bdgt_dtls_type
  INDEX BY BINARY_INTEGER;

-- global variables for the PL/SQL table of record defined above
   g_old_bdgt_dtls_tab   t_old_bdgt_dtls_tab;

-- Type to hold Records to be imorted in to Grants
TYPE t_gms_import_rec is RECORD
(
  PERIOD_NAME                  VARCHAR2(30),
  PROJECT_ID                   NUMBER,
  TASK_ID                      NUMBER,
  AWARD_ID                     NUMBER,
  EXPENDITURE_TYPE             VARCHAR2(30),
  ORGANIZATION_ID              NUMBER,
  EXPENDITURE_ENDING_DATE      DATE,
  ORGANIZATION_NAME            pa_transaction_interface_all.ORGANIZATION_NAME%TYPE,
  EXPENDITURE_ITEM_DATE        DATE,
  PROJECT_NUMBER               pa_transaction_interface_all.PROJECT_NUMBER%TYPE,
  TASK_NUMBER                  pa_transaction_interface_all.TASK_NUMBER%TYPE,
  QUANTITY                     NUMBER,
  ORIG_TRANSACTION_REFERENCE   varchar2(30) ,
  ORG_ID                       NUMBER,
  DENOM_CURRENCY_CODE          VARCHAR2(15),
  Amount                       NUMBER,
  TRANSACTION_SOURCE           VARCHAR2(30)

);
-- PL / SQL table based on the above structure
TYPE t_gms_import_tab IS TABLE OF t_gms_import_rec
  INDEX BY BINARY_INTEGER;

-- global variables for the PL/SQL table of record defined above
   g_gms_import_tab   t_gms_import_tab;

PROCEDURE build_old_bdgt_dtls_tab
(
 p_budget_detail_id         IN pqh_budget_details.budget_detail_id%TYPE
);

PROCEDURE compare_old_bdgt_dtls_tab;

PROCEDURE reverse_old_bdgt_dtls_tab
(
 p_budget_detail_id         IN pqh_budget_details.budget_detail_id%TYPE
);

PROCEDURE get_default_currency;

PROCEDURE get_payroll_defaults
(
 p_budget_detail_id         IN pqh_budget_details.budget_detail_id%TYPE
);

PROCEDURE get_element_link_defaults
(
 p_budget_detail_id         IN pqh_budget_details.budget_detail_id%TYPE,
 p_budget_period_id         IN   pqh_budget_periods.budget_period_id%TYPE
);

PROCEDURE get_organization_defaults
(
 p_budget_detail_id         IN pqh_budget_details.budget_detail_id%TYPE
);

PROCEDURE reverse_prev_posted_version;


--
-- Added the foll wrapper function and calling it from commitment posting
--

PROCEDURE get_ccid_for_commitment(
p_budget_id                  IN pqh_budgets.budget_id%type,
p_chart_of_accounts_id       IN gl_interface.chart_of_accounts_id%TYPE,
p_budget_detail_id           IN pqh_budget_details.budget_detail_id%TYPE,
p_budget_period_id           IN pqh_budget_periods.budget_period_id%TYPE,
p_cost_allocation_keyflex_id IN pay_cost_allocation_keyflex.cost_allocation_keyflex_id%TYPE,
p_code_combination_id        OUT NOCOPY gl_code_combinations.code_combination_id%TYPE);
--

--
-- Added the foll wrapper function and calling it from commitment posting
--

PROCEDURE end_commitment_log(p_status          OUT NOCOPY     varchar2);
FUNCTION chk_budget_details(p_budget_version_id  in pqh_budget_details.budget_version_id%TYPE) return varchar2;

function get_gms_rejection_msg (p_rejection_code in varchar2) return varchar2;

END pqh_gl_posting;

/
