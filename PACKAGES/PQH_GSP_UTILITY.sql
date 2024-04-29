--------------------------------------------------------
--  DDL for Package PQH_GSP_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_GSP_UTILITY" AUTHID CURRENT_USER as
/* $Header: pqgsputl.pkh 120.6.12010000.1 2008/07/28 12:58:11 appldev ship $ */


function get_gsp_plntyp_str_date (p_business_group_id  in number
                                 ,p_copy_entity_txn_id  in number default  null )
return date;

function gsp_plan_type_exists (p_business_group_id  in number)
return varchar2;
--
---------------------------CHK_GRADE_EXIST_IN_GL-----------------------------
--
-- mvankada
Function chk_grade_exist_in_gl
(p_copy_entity_txn_id   IN  ben_copy_entity_results.copy_entity_result_id%TYPE )
RETURN  VARCHAR2;

--mvankada
Procedure remove_grade_from_grdldr
(
 p_Grade_Result_Id	  IN    ben_copy_entity_results.copy_entity_result_id%TYPE,
 p_Copy_Entity_Txn_Id     IN    ben_copy_entity_results.copy_entity_txn_id%TYPE,
 p_Business_Group_Id      IN    Number,
 p_Effective_Date         IN    Date,
 p_rec_exists             OUT NOCOPY   Varchar2
);


FUNCTION GET_PGM_TYP(p_cpy_enty_txn_id       in  number)
RETURN varchar2;
--
FUNCTION ENABLE_DISABLE_START_ICON(p_gsp_node in varchar2,
                                   p_copy_enty_txn_id in number,
                                   p_table_alias in varchar2)
RETURN varchar2;
--
FUNCTION GET_STATUS(p_gsp_node in varchar2,
                                   p_copy_enty_txn_id in number,
                                   p_table_alias in varchar2)
RETURN varchar2;
--
--mvankada
FUNCTION USE_POINT_OR_STEP(p_copy_entity_txn_id       in  number)
RETURN varchar2;
--
--mvankada
Procedure remove_step_from_grade
(
 p_step_result_id         IN    ben_copy_entity_results.copy_entity_result_id%TYPE,
 p_copy_entity_txn_id     IN    number,
 p_effective_date         IN    Date,
 p_use_points             IN    varchar2 ,
 p_step_id                IN    ben_copy_entity_results.information1%TYPE default NULL,
 p_celing_step_flag       IN    varchar2 default 'N',
 p_rec_exists             OUT NOCOPY   Varchar2
 );
--
--mvankada
FUNCTION CHK_PROFILE_EXISTS
( p_copy_entity_result_id IN Ben_Copy_Entity_Results.Copy_Entity_Result_Id%Type,
  p_copy_entity_txn_id    IN Ben_Copy_Entity_Results.Copy_Entity_Txn_Id%Type
)  RETURN varchar2;


--mvankada
FUNCTION DISPLAY_ICON
(p_page                    IN   Varchar2,
 p_Table_Alias             IN   Ben_Copy_Entity_Results.Table_Alias%Type,
 p_action                  IN   Varchar2,
 p_copy_entity_txn_id      IN   Ben_Copy_Entity_Results.Copy_Entity_Txn_Id%Type,
 p_copy_entity_result_id   IN   Ben_Copy_Entity_Results.Copy_Entity_Result_Id%Type
 ) RETURN varchar2;


procedure chk_grd_details
(
 p_name IN per_grades.name%TYPE ,
 p_short_name IN per_grades.short_name%TYPE,
 p_business_group_id IN per_grades.business_group_id%TYPE,
 p_grade_id IN per_grades.grade_id%TYPE default NULL,
 p_copy_entity_result_id IN ben_copy_entity_results.copy_entity_result_id%TYPE default NULL,
 p_copy_entity_txn_id IN ben_copy_entity_results.copy_entity_txn_id%TYPE,
 p_status OUT  NOCOPY VARCHAR
);

--mvankada
FUNCTION GET_STEP_PRG_RULE_HGRID_NAME( p_copy_entity_result_id  in  Number,
                              p_copy_entity_txn_id     in  Number,
                              p_Table_Alias            in ben_copy_entity_results.Table_Alias%Type,
                              p_hgrid                  in Varchar Default NULL)
RETURN varchar2;
--

Function get_standard_rate(p_copy_entity_result_id   in number,
                           p_effective_date          in date)
RETURN number;
--
procedure delete_transaction
(p_pqh_copy_entity_txn_id IN pqh_copy_entity_txns.copy_entity_txn_id%TYPE);
--
procedure del_gl_details_from_stage
(p_pqh_copy_entity_txn_id IN pqh_copy_entity_txns.copy_entity_txn_id%TYPE);

procedure enddate_grade_ladder
(p_ben_pgm_id IN ben_pgm_f.pgm_id%TYPE,
 p_effective_date_in IN ben_pgm_f.effective_start_date%TYPE);

Function Get_Step_Dtls
(P_Entity_id       In Number,
 P_Effective_Date  In Date,
 P_Id_name         In Varchar2,
 P_Curr_Prop	   In Varchar2)

RETURN Number;

Function Get_Cur_Sal
(P_Assignment_id In Per_All_Assignments_F.ASSIGNMENT_ID%TYPE,
 P_Effective_Date  In Date)
Return Number;

Function Get_CAGR_Name
(P_CAGR_Id IN Per_Collective_Agreements.Collective_Agreement_ID%TYPE)
return varchar2;

Function gen_txn_display_name
(p_program_name IN pqh_copy_entity_txns.display_name%TYPE,
p_mode IN varchar2)
Return Varchar2;

Function get_grade_ladder_name_from_txn
(p_pqh_copy_entity_txn_id IN pqh_copy_entity_txns.copy_entity_txn_id%TYPE)
Return Varchar2;

--mvankada
Procedure chk_default_ladder_exist
( p_pgm_id               in   number,
  p_business_group_id    in   number,
  p_effective_date       in   Date);

--mvankada
Procedure chk_add_steps_in_all_grades
 ( p_copy_entity_txn_id   in   number,
   p_business_group_id    in   number);

--mvankada
Procedure chk_valid_grd_in_grdldr
( p_copy_entity_txn_id     in   number,
  p_effective_date         in   date,
  p_business_group_id      in   Number);

--mvankada
Procedure chk_inactivate_grdldr
 (p_pgm_id             in Number,
  p_effective_date     in Date,
  p_business_group_id  in Number,
  p_activate           in Varchar Default 'A');

Function Get_Emp_Los
(P_Person_id In Per_All_PEOPLE_F.Person_Id%TYPE,
 P_Effective_Date  In Date)
Return Number;

Function Get_Currency
(P_Corrency_Code In Fnd_Currencies_Vl.Currency_Code%TYPE)
Return Varchar2;

Function Get_SpinalPoint_Name
(p_Point_id    IN       per_spinal_points.Spinal_Point_Id%TYPE)
Return Varchar2;

--mvankada
Procedure update_or_delete_grade
( p_copy_entity_txn_id     in   number,
  p_grade_result_id        in   number,
  p_effective_date         in   Date);

--mvankada
Procedure update_or_delete_step
( p_copy_entity_txn_id     in   Number,
  p_step_result_id         in   Number,
  p_step_id                in   Number,
  p_point_result_id        in   Number,
  p_effective_date         in   Date);


procedure set_step_name(p_copy_entity_txn_id in number,
			p_effective_start_date in date,
			p_grd_result_id in number);
--mvankada
Procedure chk_unlink_grd_from_grdldr
           (p_pgm_id               in   Number
           ,p_copy_entity_txn_id   in   Number
           ,p_business_group_id    in   Number
           ,p_effective_date       in   Date
           ,p_status               OUT NOCOPY   Varchar2
           );

--mvankada
Procedure chk_unlink_step_from_grdldr
           (p_copy_entity_txn_id   in   Number
           ,p_business_group_id    in   Number
           ,p_effective_date       in   Date
           );

--mvankada
Procedure chk_gl_sht_name_code_unique
           ( p_pgm_id               in   Number
            ,p_business_group_id    in   Number
            ,p_short_name           in   varchar2 Default Null
            ,p_short_code           in   varchar2 Default Null);

-- mvankada
Procedure chk_grdldr_name_unique
           ( p_pgm_id               in   Number
            ,p_business_group_id    in   Number
            ,p_name                 in   varchar2
            );
--
-- The following procedure validates the grade ladder before it is saved.
--
Procedure validate_grade_ladder(
   p_pgm_id                         in number
  ,p_effective_start_date           in date        default null
  ,p_effective_end_date             in date        default null
  ,p_name                           in  varchar2   default null
  ,p_pgm_stat_cd                    in  varchar2   default null
  ,p_pgm_typ_cd                     in  varchar2   default null
  ,p_enrt_cvg_strt_dt_cd            in  varchar2   default null
  ,p_enrt_cvg_strt_dt_rl            in  number     default null
  ,p_rt_strt_dt_cd                  in  varchar2   default null
  ,p_rt_strt_dt_rl                  in  number     default null
  ,p_pgm_uom                        in  varchar2   default null
  ,p_enrt_cd                        in  varchar2   default null
  ,p_enrt_mthd_cd                   in  varchar2   default null
  ,p_enrt_rl                        in  number     default null
  ,p_auto_enrt_mthd_rl              in  number     default null
  ,p_business_group_id              in  number     default null
  ,p_Dflt_pgm_flag                  in  Varchar2   default null
  ,p_Use_prog_points_flag           in  Varchar2   default null
  ,p_Dflt_step_cd                   in  Varchar2   default null
  ,p_Dflt_step_rl                   in  number     default null
  ,p_Update_salary_cd               in  Varchar2   default null
  ,p_Use_multi_pay_rates_flag       in  Varchar2   default null
  ,p_dflt_element_type_id           in  number     default null
  ,p_Dflt_input_value_id            in  number     default null
  ,p_Use_scores_cd                  in  Varchar2   default null
  ,p_Scores_calc_mthd_cd            in  Varchar2   default null
  ,p_Scores_calc_rl                 in  number     default null
  ,p_gsp_allow_override_flag        in  varchar2   default null
  ,p_use_variable_rates_flag        in  varchar2   default null
  ,p_salary_calc_mthd_cd            in  varchar2   default null
  ,p_salary_calc_mthd_rl            in  number     default null
  ,p_effective_date                 in  date
  ,p_short_name                     in  varchar2   default null
  ,p_short_code                     in  varchar2   default null
 );
--

Procedure chk_grdldr_grd_curreny_rate
(p_copy_entity_txn_id    In Number,
 p_business_group_id     In Number,
 p_effective_date        In Date);


--mvankada
Procedure chk_review_submit_val
(p_copy_entity_txn_id     in   Number,
 p_effective_date         in   Date,
 p_pgm_id                 in   Number default null,
 p_business_group_id      in   Number,
 p_status                 OUT NOCOPY   Varchar2,
 p_prog_le_created_flag   OUT NOCOPY   Varchar2,
 p_sync_le_created_flag   OUT NOCOPY   Varchar2,
 p_plan_tp_created_flag   OUT NOCOPY   Varchar2
);
--


--
Function get_rates_icon_enabled
(p_copy_entity_txn_id	in Number,
 p_copy_entity_result_id in Number,
 p_rate_hgrid_node      in varchar2)
Return Varchar2;
--
--
-- Function to return the annualization factor for frequency codes used in Benefits.
--
Function pgm_freq_annual_factor
         (p_ref_perd_cd   in varchar2) return number;
 --

Procedure create_pay_rate(p_business_group_id  in number,
                          p_ldr_period_code    in varchar2,
                          p_rate_id           Out nocopy number,
                          p_ovn               Out nocopy number);
--
Procedure create_pay_rate (p_business_group_id  in number,
                         p_scale_id          in number,
                         p_rate_name         in varchar2,
                         p_rate_id           Out nocopy number,
                         p_ovn               Out nocopy number);
--
procedure step_exists_for_point(p_copy_entity_txn_id in number,
    p_points_result_id in number,
    p_status out nocopy varchar);
--
procedure chk_scale_name(p_copy_entity_txn_id in number,
   p_business_group_id in number,
   p_copy_entity_result_id in number,
   p_parent_spine_id in number,
   p_name in varchar,
   p_status out nocopy varchar);
--
Function get_dflt_salary_rate
(p_copy_entity_txn_id	in Number,
 p_copy_entity_result_id in Number,
 p_rate_hgrid_node      in varchar2)
Return Number;
--
Function is_crrate_there_icon
(p_copy_entity_txn_id	in Number,
 p_copy_entity_result_id in Number,
 p_effective_date_in       in date,
 p_rate_hgrid_node      in varchar2)
Return Varchar2;
--
procedure chk_steps_in_grade(p_copy_entity_txn_id in number,
			p_grade_result_id in number,
			p_status out nocopy varchar2);

Function PGM_TO_BASIS_CONVERSION
(P_Pgm_ID               IN Number
,P_EFFECTIVE_DATE       IN Date
,P_AMOUNT               IN Number
,P_ASSIGNMENT_ID        IN Number)

Return Number;

Function get_num_steps_in_grade(p_copy_entity_txn_id in number,
                                p_grade_cer_id in number)
Return Number;

--
--
Function get_dflt_point_rate (p_copy_entity_txn_id  in number,
                              p_point_cer_id        in number,
                              p_effective_date      in date)
RETURN NUMBER;

Function Get_person_name (P_Person_id      IN Number,
                          P_Effective_Date IN  Date)

Return Varchar2;

Function Get_Assgt_Status (P_Assgt_Status_Id IN Number)
Return varchar2;
--

Procedure check_sal_basis_iv (p_input_value_id    in number,
                              p_basis_id          in number,
                              p_business_group_id in number,
                              p_exists_flag       Out nocopy varchar2);
--
procedure update_oipl_records(
                    p_effective_date          IN DATE,
                    p_copy_entity_result_id   IN ben_copy_entity_results.copy_entity_result_id%TYPE,
                    p_point_name           IN ben_copy_entity_results.information99%TYPE,
                    p_sequence              IN ben_copy_entity_results.information263%TYPE,
                    p_copy_entity_txn_id              IN ben_copy_entity_results.copy_entity_txn_id%TYPE
                    );
--
Procedure validate_crset_values(p_copy_entity_txn_id in number,
                                p_effective_date     in date);
Procedure chk_duplicate_crset_exists(
                           p_copy_entity_txn_id in number,
                           p_effective_date     in date,
                           p_cset_id            in number    default null,
                           p_location_id        in number    default null,
                           p_job_id             in number    default null,
                           p_org_id             in number    default null,
                           p_rule_id            in number    default null,
                           p_person_type_id     in number    default null,
                           p_service_area_id    in number    default null,
                           p_barg_unit_cd       in varchar2  default null,
                           p_full_part_time_cd  in varchar2  default null,
                           p_perf_type_cd       in varchar2  default null,
                           p_rating_type_cd     in varchar2  default null,
                           p_duplicate_exists  out nocopy varchar2,
                           p_duplicate_cset_name out nocopy varchar2);
Procedure move_data_stage_to_hr
(p_copy_entity_txn_id     in   Number,
 p_effective_date         in   Date,
 p_business_area          in   varchar2 default 'PQH_GSP_TASK_LIST',
 p_business_group_id      in   Number,
 p_datetrack_mode         in   Varchar2,
 p_error_msg              out  Nocopy Varchar2
);
procedure get_grade_name (
	p_grade_definition_id 	IN NUMBER,
	p_business_group_id  	IN NUMBER,
	p_concatenated_segments OUT NOCOPY VARCHAR2);
FUNCTION GET_DML_OPERATION
(p_in_dml_operation in ben_copy_entity_results.dml_operation%TYPE)
RETURN VARCHAR2;
--
Procedure chk_no_asg_grd_ldr(p_asg_grade_ladder_id in number,
                             p_asg_grade_id        in number,
                             p_asg_org_id          in number,
                             p_asg_bg_id           in number,
                             p_effective_date      in date);
--
FUNCTION  bus_area_pgm_entity_exist(p_bus_area_cd IN Varchar2,
                                    P_pgm_id IN NUMBER)
RETURN varchar2 ;
PROCEDURE unlink_step_or_point (p_copy_entity_result_id IN NUMBER);

--ggnanagu
   PROCEDURE chk_delete_option (
      p_copy_entity_txn_id   IN   NUMBER,
      p_opt_cer_id       IN   NUMBER,
      p_point_id         IN   NUMBER,
      p_opt_id           IN   NUMBER,
      p_pspine_id        IN   NUMBER,
      p_effective_date   IN   DATE

   );
--
   PROCEDURE chk_new_ceiling (
      p_effective_date   IN   DATE,
      p_grade_cer_id     IN   NUMBER,
      p_new_ceiling      IN   NUMBER
   );
   --ggnanagu
      PROCEDURE change_ceiling_step (
         p_copy_entity_txn_id   IN   NUMBER,
         p_effective_date       IN   DATE,
         p_initial_ceiling_id   IN   NUMBER,
         p_final_ceiling_id     IN   NUMBER,
         p_grade_result_id      IN   NUMBER
   );

   ----ggnanagu

   procedure update_frps_point_rate(p_point_cer_id in number,
                                 p_copy_entity_txn_id in number,
                                 p_business_group_id in number,
                                 p_salary_rate        in number,
                                 p_gross_index        in number,
                                 p_effective_date     in date
                              );
Function chk_from_steps(p_parent_spine_id IN per_parent_spines.parent_spine_id%TYPE)
RETURN VARCHAR2;
function check_crset(p_crset_type in VARCHAR2,p_crset_id IN NUMBER,p_copy_entity_txn_id IN NUMBER,p_scale_cer_id in number)
return varchar2;
procedure change_scale_name(p_copy_entity_txn_id in number,p_pl_cer_id in number,p_short_name in varchar2);
procedure remove_steps(p_copy_entity_txn_id IN NUMBER, p_grade_result_id IN NUMBER);
procedure change_rates_date(p_copy_entity_txn_id in number,p_pl_cer_id in number,p_start_date in DATE);
FUNCTION GET_CURRENCY_CODE(p_copy_entity_txn_id in  number) RETURN varchar2;
FUNCTION get_grd_start_date(p_copy_entity_result_id in ben_copy_entity_results.copy_entity_result_id%TYPE)RETURN DATE;
procedure change_start_step(p_copy_entity_txn_id in number
                	,p_init_start_step in number
      			,p_final_start_step in number
    			,p_grade_result_id in number
            );

FUNCTION get_bg_currency(p_business_group_id in  number) RETURN varchar2;
FUNCTION get_formula_name (p_formula_id IN NUMBER, p_effective_date IN DATE)
      RETURN VARCHAR2;

FUNCTION get_element_name (p_element_type_id IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION get_input_val_name (p_input_value_id IN NUMBER)
      RETURN VARCHAR2;
PROCEDURE chk_grd_ldr_details (
   p_business_group_id   IN   NUMBER,
   p_name                IN   VARCHAR2,
   p_dflt_pgm_flag       IN   VARCHAR2,
   p_pgm_id              IN   NUMBER,
   p_effective_date      IN   DATE
);

function get_gl_ann_factor(p_pgm_id in number)   return varchar2;

--rlpatil

PROCEDURE upd_ceiling_info(p_grade_cer_id IN NUMBER, p_step_id IN number);

End pqh_gsp_utility;

/
