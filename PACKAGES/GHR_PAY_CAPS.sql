--------------------------------------------------------
--  DDL for Package GHR_PAY_CAPS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_PAY_CAPS" AUTHID CURRENT_USER AS
/* $Header: ghpaycap.pkh 120.3.12010000.1 2008/07/28 10:36:03 appldev ship $ */
--
  -- This record structure will keep all the in parameters that were passed to the main pay calc process
  TYPE pay_cap_in_rec_type IS RECORD
	                  (effective_date               DATE
                        ,pay_rate_determinant         VARCHAR2(30)
                        ,pay_plan                     VARCHAR2(30)
                        ,to_position_id               NUMBER
                        ,pay_basis                    VARCHAR2(30)
                        ,person_id                    NUMBER
                        ,basic_pay                    NUMBER
                        ,locality_adj                 NUMBER
                        ,adj_basic_pay                NUMBER
                        ,total_salary                 NUMBER
                        ,other_pay_amount             NUMBER
                        ,au_overtime                  NUMBER
                        ,availability_pay             NUMBER
                        ,noa_code                     ghr_pa_requests.first_noa_code%type -- New 8/28
                        ,retention_allowance          NUMBER -- New 8/28
                        ,retention_allow_percentage          NUMBER -- New 8/28
                        ,supervisory_allowance        NUMBER -- New 8/28
                        ,staffing_differential        NUMBER -- New 8/28
                        ,capped_other_pay             NUMBER -- New 8/28
                        ,pa_request_id                NUMBER -- New 12/12
                         );

  --
  TYPE pay_cap_out_rec_type IS RECORD
	                  (open_pay_fields              BOOLEAN
                        ,message_set                  BOOLEAN
                        ,locality_adj                 NUMBER -- New 8/28
                        ,adj_basic_pay                NUMBER -- New 8/28
                        ,total_salary                 NUMBER -- New 8/28
                        ,other_pay_amount             NUMBER -- New 8/28
                        ,retention_allowance          NUMBER -- New 8/28
                        ,retention_allow_percentage          NUMBER -- New 8/28
                        ,au_overtime                  NUMBER -- New 8/28
                        ,availability_pay             NUMBER -- New 8/28
                        ,capped_other_pay             NUMBER -- New 8/28
                        ,adj_basic_mesg_flag NUMBER -- Change on 8/30
                        ,pay_cap_message              BOOLEAN -- New 8/28
                        ,pay_cap_adj                  NUMBER -- New 8/28
                        ,total_pay_check              VARCHAR2(1) ---- Bug 2064497 New 11/21
                        );

  --

  FUNCTION update34_implemented_date (p_person_id IN NUMBER)
  RETURN DATE;

 --
FUNCTION perf_certified(p_agency_code   IN ghr_pa_requests.from_Agency_code%TYPE,
                       p_org_id         IN hr_positions_f.organization_id%TYPE,
                       p_pay_plan       IN ghr_pa_Requests.from_pay_plan%TYPE,
                       p_effective_date IN ghr_pa_Requests.effective_date%TYPE)
RETURN BOOLEAN;

--Bug# 5132113

function pay_cap_chk_ttl_38(l_user_table_id     IN  pay_user_tables.user_table_id%TYPE,
                             l_user_clomun_name IN  pay_user_columns.user_column_name%TYPE,
                             l_market_pay       IN  number,
                             p_effective_date   IN  ghr_pa_Requests.effective_date%TYPE)
RETURN BOOLEAN;
--Bug# 5132113

--
FUNCTION get_job_from_pos(p_effective_date  IN   DATE
                         ,p_position_id     IN   NUMBER)
RETURN VARCHAR2;

--
  PROCEDURE update34_implement (p_person_id  IN NUMBER
                               ,P_date       IN DATE);
  --
  PROCEDURE do_pay_caps_main (p_pa_request_id     IN    NUMBER      --NEW
                        ,p_effective_date       IN    DATE
                        ,p_pay_rate_determinant IN    VARCHAR2
                        ,p_pay_plan             IN    VARCHAR2
                        ,p_to_position_id       IN    NUMBER
                        ,p_pay_basis            IN    VARCHAR2
                        ,p_person_id            IN    NUMBER
                        ,p_noa_code             IN    VARCHAR2      --New
                        ,p_basic_pay            IN    NUMBER
                        ,p_locality_adj         IN OUT NOCOPY   NUMBER
                        ,p_adj_basic_pay        IN OUT NOCOPY   NUMBER
                        ,p_total_salary         IN OUT NOCOPY   NUMBER
                        ,p_other_pay_amount     IN OUT NOCOPY   NUMBER
                        ,p_capped_other_pay     IN OUT NOCOPY   NUMBER      --New
                        ,p_retention_allowance  IN OUT NOCOPY   NUMBER      --New
                        ,p_retention_allow_percentage  IN OUT NOCOPY  NUMBER      --New
                        ,p_supervisory_allowance IN     NUMBER      --New
                        ,p_staffing_differential IN     NUMBER      --New
                        ,p_au_overtime          IN OUT NOCOPY   NUMBER
                        ,p_availability_pay     IN OUT NOCOPY   NUMBER
                        ,p_adj_basic_message       OUT NOCOPY    BOOLEAN
                        ,p_pay_cap_message         OUT NOCOPY    BOOLEAN
                        ,p_pay_cap_adj             OUT NOCOPY    NUMBER
                        ,p_open_pay_fields        OUT NOCOPY  BOOLEAN
                        ,p_message_set            OUT NOCOPY  BOOLEAN
                        ,p_total_pay_check        OUT NOCOPY  VARCHAR2);

  --


  --
 PROCEDURE do_pay_caps_sql (p_pa_request_id     IN    NUMBER      --NEW
                        ,p_effective_date   IN    DATE
                        ,p_pay_rate_determinant IN    VARCHAR2
                        ,p_pay_plan             IN    VARCHAR2
                        ,p_to_position_id       IN    NUMBER
                        ,p_pay_basis            IN    VARCHAR2
                        ,p_person_id            IN    NUMBER
                        ,p_noa_code             IN    VARCHAR2      --New
                        ,p_basic_pay            IN    NUMBER
                        ,p_locality_adj         IN OUT NOCOPY    NUMBER
                        ,p_adj_basic_pay        IN OUT NOCOPY    NUMBER
                        ,p_total_salary         IN OUT NOCOPY    NUMBER
                        ,p_other_pay_amount     IN OUT NOCOPY    NUMBER
                        ,p_capped_other_pay     IN OUT NOCOPY    NUMBER     --New
                        ,p_retention_allowance  IN OUT NOCOPY    NUMBER     --New
                        ,p_retention_allow_percentage  IN OUT NOCOPY    NUMBER     --New
                        ,p_supervisory_allowance IN     NUMBER      --New
                        ,p_staffing_differential IN     NUMBER      --New
                        ,p_au_overtime          IN OUT NOCOPY   NUMBER
                        ,p_availability_pay     IN OUT NOCOPY   NUMBER
                        ,p_adj_basic_message       OUT NOCOPY    BOOLEAN
                        ,p_pay_cap_message         OUT NOCOPY    BOOLEAN
                        ,p_pay_cap_adj             OUT NOCOPY    NUMBER
                        ,p_open_pay_fields         OUT NOCOPY  BOOLEAN
                        ,p_message_set          IN OUT NOCOPY  BOOLEAN
                        ,p_total_pay_check        OUT NOCOPY  VARCHAR2);


--
END ghr_pay_caps;

/
