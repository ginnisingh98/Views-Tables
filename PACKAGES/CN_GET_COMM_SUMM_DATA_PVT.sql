--------------------------------------------------------
--  DDL for Package CN_GET_COMM_SUMM_DATA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_GET_COMM_SUMM_DATA_PVT" AUTHID CURRENT_USER AS
  /*$Header: cnvcomms.pls 120.4 2006/03/13 01:04:18 sjustina noship $*/

TYPE comm_summ_rec_type IS RECORD
  (srp_plan_assign_id      NUMBER,
   role_name               VARCHAR2(80),
   plan_name               VARCHAR2(80),
   start_date              DATE,
   end_date                DATE,
   ytd_total_earnings      NUMBER,
   ptd_total_earnings      NUMBER,
   salesrep_id             NUMBER);

TYPE comm_summ_tbl_type IS TABLE OF comm_summ_rec_type
  INDEX BY binary_integer;

TYPE salesrep_tbl_type IS TABLE OF NUMBER
  INDEX BY binary_integer;

TYPE group_code_tbl_type IS TABLE OF VARCHAR2(30)
  INDEX BY binary_integer;
/**
Types created by Sarah
*/
TYPE pe_info_rec_type IS RECORD
(
   srp_plan_assign_id     NUMBER,
   quota_group_code     VARCHAR2(30),
   x_annual_quota          NUMBER,
   x_pct_annual_quota    NUMBER,
   x_ytd_target           NUMBER,
   x_ytd_credit           NUMBER,
   x_ytd_earnings         NUMBER,
   x_ptd_target           NUMBER,
   x_ptd_credit            NUMBER,
   x_ptd_earnings          NUMBER,
   x_itd_unachieved_quota  NUMBER,
   x_itd_tot_target        NUMBER);

TYPE pe_info_tbl_type IS TABLE OF pe_info_rec_type
INDEX BY binary_integer;

TYPE salesrep_info_rec_type IS RECORD
(
x_name                  VARCHAR2(360),
x_emp_num               VARCHAR2(30),
x_cost_center           VARCHAR2(30),
x_charge_to_cost_center VARCHAR2(30),
x_analyst_name          VARCHAR2(100),
x_salesrep_id           NUMBER);

TYPE salesrep_info_tbl_type IS TABLE OF salesrep_info_rec_type
INDEX BY binary_integer;

TYPE pe_ptd_credit_info IS RECORD
(
   quota_id      NUMBER,
   x_ptd_credit  NUMBER);

TYPE pe_ptd_credit_tbl_type IS TABLE OF pe_ptd_credit_info
INDEX BY binary_integer;
/**
Types created by Sarah
*/

-- gets all salesreps under given analyst
PROCEDURE Get_Salesrep_List
  (p_first                 IN    NUMBER,
   p_last                  IN    NUMBER,
   p_period_id             IN    NUMBER,
   p_analyst_id            IN    NUMBER,
   p_org_id                IN    NUMBER,
   x_total_rows            OUT NOCOPY   NUMBER,
   x_salesrep_tbl          OUT NOCOPY   salesrep_tbl_type);

-- gets salesrep info
PROCEDURE Get_Salesrep_Info
  (p_salesrep_id           IN    NUMBER,
   p_org_id                IN    NUMBER,
   x_name                  OUT NOCOPY   VARCHAR2,
   x_emp_num               OUT NOCOPY   VARCHAR2,
   x_cost_center           OUT NOCOPY   VARCHAR2,
   x_charge_to_cost_center OUT NOCOPY   VARCHAR2,
   x_analyst_name          OUT NOCOPY   VARCHAR2);

-- gets comm summ report for given rep - one rec for each plan assigned
PROCEDURE Get_Quota_Summary
  (p_salesrep_id           IN    NUMBER,
   p_period_id             IN    NUMBER,
   p_credit_type_id        IN    NUMBER,
   p_org_id                IN    NUMBER,
   x_result_tbl            OUT NOCOPY   comm_summ_tbl_type);
/**
Procs created by Sarah
*/
PROCEDURE Get_Quota_Manager_Summary
  (
   p_period_id             IN    NUMBER,
   p_credit_type_id        IN    NUMBER,
   p_org_id                IN NUMBER,
   x_result_tbl            OUT NOCOPY   comm_summ_tbl_type);

PROCEDURE Get_Quota_Analyst_Summary
  (
   p_period_id             IN    NUMBER,
   p_credit_type_id        IN    NUMBER,
   p_org_id                IN    NUMBER,
   p_analyst_id            IN    NUMBER,
   x_result_tbl            OUT NOCOPY   comm_summ_tbl_type);

/**
Procs created by Sarah
*/
-- gets info for each plan assign and quota group
PROCEDURE Get_Pe_Info
  (p_srp_plan_assign_id    IN    NUMBER,
   p_period_id             IN    NUMBER,
   p_credit_type_id        IN    NUMBER,
   p_quota_group_code      IN    VARCHAR2,
   p_quota_id              IN    NUMBER := NULL ,
   p_org_id                IN    NUMBER,
   x_annual_quota          OUT NOCOPY   NUMBER,
   x_pct_annual_quota      OUT NOCOPY   NUMBER,
   x_ytd_target            OUT NOCOPY   NUMBER,
   x_ytd_credit            OUT NOCOPY   NUMBER,
   x_ytd_earnings          OUT NOCOPY   NUMBER,
   x_ptd_target            OUT NOCOPY   NUMBER,
   x_ptd_credit            OUT NOCOPY   NUMBER,
   x_ptd_earnings          OUT NOCOPY   NUMBER,
   x_itd_unachieved_quota  OUT NOCOPY   NUMBER,
   x_itd_tot_target        OUT NOCOPY   NUMBER
   );

/**
Procs created by Sarah
*/
PROCEDURE Get_Salesrep_Pe_Info
(
    p_salesrep_id in number,
   p_period_id             IN    NUMBER,
   p_credit_type_id        IN    NUMBER,
   p_org_id                IN NUMBER,
   x_result_tbl OUT NOCOPY pe_info_tbl_type
);

PROCEDURE Get_Manager_Pe_Info
(
   p_period_id             IN    NUMBER,
   p_credit_type_id        IN    NUMBER,
   p_org_id                IN NUMBER,
   x_result_tbl OUT NOCOPY pe_info_tbl_type
);

PROCEDURE Get_Analyst_Pe_Info
(
   p_period_id             IN    NUMBER,
   p_credit_type_id        IN    NUMBER,
   p_org_id                IN NUMBER,
   p_analyst_id            IN    NUMBER,
   x_result_tbl OUT NOCOPY pe_info_tbl_type
);

PROCEDURE Get_Salesrep_Details
(p_salesrep_id in number,
p_org_id in number,
x_result_tbl out nocopy salesrep_info_tbl_type);

PROCEDURE Get_Manager_Details
(p_org_id in number,
x_result_tbl out nocopy salesrep_info_tbl_type);

PROCEDURE Get_Analyst_Details
(
p_org_id in number,
p_analyst_id in number,
x_result_tbl out nocopy salesrep_info_tbl_type);
/**
Procs created by Sarah
*/
-- get list of all quota groups
PROCEDURE Get_Group_Codes
  (p_org_id               IN            NUMBER,
  x_result_tbl            OUT NOCOPY   group_code_tbl_type);

PROCEDURE Get_Ptd_Credit
(p_salesrep_id      IN NUMBER,
 p_payrun_id         IN NUMBER,
 p_org_id IN NUMBER,
 x_result_tbl IN OUT NOCOPY pe_ptd_credit_tbl_type
);

FUNCTION GET_CONVERSION_TYPE(p_org_id IN NUMBER) RETURN VARCHAR2;

  END CN_GET_COMM_SUMM_DATA_PVT;

 

/
