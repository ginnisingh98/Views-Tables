--------------------------------------------------------
--  DDL for Package PQP_US_SRS_EXTRACTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_US_SRS_EXTRACTS" AUTHID CURRENT_USER As
-- $Header: pqpussrs.pkh 120.1 2005/06/09 15:10:46 rpinjala noship $
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- ~ Global Variables         ~
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~

g_proc_name               varchar2(65):= 'PQP_US_SRS_Extracts.';
g_assignment_id           per_all_assignments_f.assignment_id%Type;
g_business_group_id       per_all_assignments_f.business_group_id%TYPE;
g_legislation_code        varchar2(20);
g_ext_dtl_rcd_id          ben_ext_rcd.ext_rcd_id%TYPE;
g_ext_dfn_type            pqp_extract_attributes.ext_dfn_type%TYPE;
g_ext_dfn_id              pqp_extract_attributes.ext_dfn_id%TYPE;
g_effective_date          date;
g_extract_start_date      date;
g_extract_end_date        date;
g_extract_pay_date        date;
g_payroll_frequency       varchar(150);

g_eligible_comp_balance_C varchar2(150) := ' Eligible Comp';
g_SRS_balance_C           varchar2(150) := ' SRS Plan Name';
g_ER_balance_C            varchar2(150) := ' ER Contribution';
g_AT_Contribution_C       varchar2(150) := ' AT';
g_BuyBack_Balance_C       varchar2(150) := ' Buy Back';
g_Additional_Balance_C    varchar2(150) := ' Addl EE Contr Amt';
g_ER_Additional_C         varchar2(150) := ' Addl ER Contr Amt';

g_srs_balance             varchar2(150);
g_eligible_comp_balance   varchar2(150);
g_ER_balance              varchar2(150);
g_AT_Contribution         varchar2(150);
g_BuyBack_Balance         varchar2(150);
g_Additional_Balance      varchar2(150);
g_ER_Additional           varchar2(150);

g_dimension_name          varchar2(100);

g_plan_person_identifier  varchar2(150);
g_qualifies_10yr_rule     varchar2(150);
g_qualifies_GrdFathering  varchar2(150);
g_plan_start_date         date;
g_plan_end_date           date;
--
Type g_srs_plan_rec Is Record
            ( plan_name  varchar2(150)
             ,assignment_id per_all_assignments_f.assignment_id%TYPE);
Type t_srs_plan_type Is Table Of g_srs_plan_rec Index By Binary_Integer;
g_extract_plan_names   t_srs_plan_type ;
g_extract_plan_name    varchar2(150);
--
--
Type g_srs_payroll_rec Is Record
            (payroll_name  varchar2(150) );
Type t_srs_payroll_type Is Table Of g_srs_payroll_rec Index By Binary_Integer;
g_extract_payroll_names   t_srs_payroll_type ;
--
--
Type g_payroll_details Is Record
      (payroll_name        pay_payrolls_f.payroll_name%TYPE
      ,period_type         pay_payrolls_f.period_type%TYPE
      ,payroll_start_date  date
      ,payroll_end_date    date
      ,actual_pay_date     date
      );
Type t_payroll_details_type Is Table Of g_payroll_details Index By Binary_Integer;
g_payroll_names  t_payroll_details_type;
--
--
-- ============================
-- ~ Cursors Declarations     ~
-- ============================
--
-- Cursor to get the extract record id
--
Cursor csr_ext_rcd_id(c_hide_flag	In Varchar2
		             ,c_rcd_type_cd	In Varchar2
                      ) Is
select rcd.ext_rcd_id
 from  ben_ext_rcd rcd
      ,ben_ext_rcd_in_file rin
      ,ben_ext_dfn dfn
Where dfn.ext_dfn_id   = ben_ext_thread.g_ext_dfn_id -- The extract executing currently
  And rin.ext_file_id  = dfn.ext_file_id
  And rin.hide_flag    = c_hide_flag                 -- Y=Hidden, N=Not Hidden
  And rin.ext_rcd_id   = rcd.ext_rcd_id
  And rcd.rcd_type_cd  = c_rcd_type_cd;              -- D=Detail,H=Header,F=Footer

--
-- Cursor to get the defined balance id for a given balance and dimension
--
cursor csr_defined_bal ( c_balance_name    in varchar2
                        ,c_dimension_name  in varchar2
                        ,c_business_group_id in number) is
 select db.defined_balance_id
   from pay_balance_types pbt
       ,pay_defined_balances db
       ,pay_balance_dimensions bd
  where pbt.balance_name        = c_balance_name
    and pbt.balance_type_id     = db.balance_type_id
    and bd.balance_dimension_id = db.balance_dimension_id
    and bd.dimension_name       = c_dimension_name
    and (pbt.business_group_id  = c_business_group_id or
         pbt.legislation_code   = g_legislation_code)
    and (db.business_group_id   = pbt.business_group_id or
         db.legislation_code    = g_legislation_code);
--
-- Get the Payroll Id for the given assignment id, used in case the extract is PTD type
--
Cursor csr_get_payroll_id
        ( c_assignment_id  In per_all_assignments_f.assignment_id%TYPE
         ,c_effective_date In date) Is
 Select  paa.payroll_id
        ,paa.effective_start_date
        ,paa.effective_end_date
   from per_all_assignments_f paa
  where paa.assignment_id = c_assignment_id
    and ((c_effective_date between paa.effective_start_date
                               and paa.effective_end_date
          )
         Or
         (paa.effective_start_date =( select max(pax.effective_start_date)
                                        from per_all_assignments_f pax
                                       where pax.assignment_id = c_assignment_id)
          )
         );
--
-- Get the payroll_name and payroll frequency
--
Cursor csr_payroll_name (c_payroll_id     In per_all_assignments_f.payroll_id%TYPE
                        ,c_effective_date In date ) Is
  Select payroll_name, period_type
    from pay_payrolls_f
   Where c_effective_date Between effective_start_date
                              and effective_end_date
     and payroll_id = c_payroll_id;

--
-- Cursor to get the SRS Plans assignment extra info
--
Cursor csr_assig_extra_info
       ( c_assignment_id In per_all_assignments_f.assignment_id%TYPE
         ) Is
 Select *
   From per_assignment_extra_info pae
  Where pae.assignment_id            = c_assignment_id
    and pae.information_type         = 'PQP_US_SRS_PLAN_ASG_INFO'
    and pae.aei_information_category = 'PQP_US_SRS_PLAN_ASG_INFO'  ;

-- Based on the Payroll id and the effective date of the extract get the start
-- and end date of the period. Used only in case of the PTD as each assign. may have
-- different payroll frequency i.e. Monthly, Semi-Month, Weekly etc..
Cursor csr_time_period ( c_payroll_id     In pay_payrolls_f.payroll_id%TYPE
                        ,c_effective_date In date) Is
 Select start_date, end_date
   from per_time_periods
  where payroll_id  = c_payroll_id
    and c_effective_date between start_date
                             and end_date;
--
-- Cursor to get the primary assig. records active as of the given period
--
Cursor csr_assig_rec
       ( c_assignment_id      in per_all_assignments_f.assignment_id%TYPE
        ,c_business_group_id  in per_all_assignments_f.business_group_id%TYPE
        ,c_effective_date     in date
        ,c_extract_start_date in date
        ,c_extract_end_date   in date ) Is
  select *
    from per_all_assignments_f paa
   where paa.business_group_id = c_business_group_id
     and paa.assignment_id     = c_assignment_id
     and paa.primary_flag      = 'Y'
     and ((c_effective_date between paa.effective_start_date
                                and paa.effective_end_date
           )
         Or
          ( paa.effective_end_date = ( Select max(asx.effective_end_date)
                                         from per_all_assignments_f asx
                                        Where asx.assignment_id       = paa.assignment_id
                                          and asx.primary_flag        = 'Y'
                                          and ((asx.effective_end_date between c_extract_start_date
                                                                           and c_extract_end_date
                                                )
                                               Or
                                               (asx.effective_start_date between c_extract_start_date
                                                                             and c_extract_end_date
                                                )
                                              )
                                      )
           )
         );

Type t_pri_asg_type Is Table of  csr_assig_rec%ROWTYPE Index By BINARY_INTEGER;
g_primary_asg    t_pri_asg_type;
--
-- Cursor to get the secondary assig. records active as of the given period.
--
Cursor csr_sec_assignments
           (c_primary_assignment_id In per_all_assignments_f.assignment_id%TYPE
           ,c_person_id		        In per_all_people_f.person_id%TYPE
           ,c_effective_date    	In date
           ,c_extract_start_date    In date
           ,c_extract_end_date      In Date ) Is
  Select  *
    From per_all_assignments_f  asg
   Where asg.person_id = c_person_id
     And asg.assignment_id <> c_primary_assignment_id
     And asg.assignment_type ='E'
     And (( c_effective_date  Between asg.effective_start_date
                                 And asg.effective_end_date
           )
          Or
          ( asg.effective_end_date = ( Select max(asx.effective_end_date)
                                         from per_all_assignments_f asx
                                        Where asx.assignment_id   = asg.assignment_id
                                          and asx.person_id       = c_person_id
                                          and asx.assignment_type ='E'
                                          and ((asx.effective_end_date between c_extract_start_date
                                                                           and c_extract_end_date
                                                )
                                                Or
                                               (asx.effective_start_date between c_extract_start_date
                                                                             and c_extract_end_date
                                                )
                                               )
                                      )
           )
          )
   ORDER BY asg.effective_start_date ASC; -- effective first then future rows
TYPE t_sec_asgs_type IS TABLE OF csr_sec_assignments%ROWTYPE INDEX BY BINARY_INTEGER;
g_all_sec_asgs	t_sec_asgs_type;

-- ============================
-- ~ Functions Declarations   ~
-- ============================
Function Get_Header_Information
        (p_header_type In varchar2
        ,p_header_name In out nocopy Varchar2) Return Number;

Function Get_Payroll_Names
        (p_effective_date In Date
        ,p_payroll_name   In varchar2) Return Varchar2;
Function Get_Payroll_Name
        (p_assignment_id In per_all_assignments_f.assignment_id%TYPE
        ,p_payroll_name  In out nocopy varchar2) Return Number;

Function Get_Payroll_Start_Date
        (p_assignment_id In per_all_assignments_f.assignment_id%TYPE
        ,p_start_date    In out nocopy Varchar2) Return Number;

Function Get_Payroll_End_Date
        (p_assignment_id In per_all_assignments_f.assignment_id%TYPE
        ,p_end_date      In out nocopy Varchar2) Return Number;

Function Get_Actual_Pay_Date
        (p_assignment_id In per_all_assignments_f.assignment_id%TYPE
        ,p_pay_date      In out nocopy Varchar2) Return Number;

Function Get_SRS_Plan_Name
        (p_assignment_id In per_all_assignments_f.assignment_id%TYPE
        ,p_SRS_Plan_Name In out nocopy Varchar2) Return Number;

Function Get_Separation_Date
        (p_assignment_id  In per_all_assignments_f.assignment_id%TYPE
        ,p_Separation_Date In out nocopy Varchar2) Return Number;

Function Get_Assig_Status
        (p_assignment_id In per_all_assignments_f.assignment_id%TYPE
        ,p_status_code   In out nocopy Varchar2) Return Number;

Function Get_Person_Indentifier
        (p_assignment_id     In per_all_assignments_f.assignment_id%TYPE -- context
        ,p_person_identifier In out nocopy Varchar2 ) Return Number;

Function Get_SRS_Deduction_Balances
        (p_assignment_id  In per_all_assignments_f.assignment_id%TYPE
        ,p_balance_name   In pay_balance_types.balance_name%TYPE
        ,p_balance_amount In out nocopy Number
         ) Return Number;

Function Get_Balance_Value
        (p_business_group_id In per_all_assignments_f.business_group_id%TYPE
        ,p_assignment_id     In per_all_assignments_f.assignment_id%TYPE
        ,p_effective_date    In date
        ,p_balance_name      In varchar2
        ,p_dimension_name    In varchar2
         ) Return Number;

Function Get_Plan_Names
        (p_effective_date In Date
        ,p_extract_name   In varchar2 ) Return Varchar2;

Function Pay_US_SRS_Main_Criteria
        (p_assignment_id        In per_all_assignments_f.assignment_id%TYPE
        ,p_effective_date       In date
        ,p_business_group_id    In per_all_assignments_f.business_group_id%TYPE
        ,p_extract_plan_name    In Varchar2
        ,p_extract_payroll_name In Varchar2 Default Null
        ) Return Varchar2;

Function Create_Secondary_Assig_Lines
         (p_assignment_id in per_all_assignments_f.assignment_id%TYPE
          ) Return Varchar2;
Procedure Create_New_Lines
         (p_pri_assignment_id  In per_all_assignments_f.assignment_id%TYPE
         ,p_sec_assignment_id  In per_all_assignments_f.assignment_id%TYPE
         ,p_person_id          In per_all_people_f.person_id%TYPE
         ,p_record_name        In Varchar2
          );

Function Get_Secondary_Assignments
        (p_primary_assignment_id In per_all_assignments_f.assignment_id%TYPE
        ,p_person_id             In per_all_people_f.person_id%TYPE
        ,p_effective_date        In date
        ,p_extract_start_date    In date
        ,p_extract_end_date      In date ) Return Varchar2;

Function Check_Assig_Extra_Info
        (p_assignment_id      In per_all_assignments_f.assignment_id%TYPE
        ,p_extract_plan_name  In varchar2
        ,p_extract_start_date In date
        ,p_extract_end_date   In date
         ) Return Varchar2 ;

Function Del_Service_Detail_Recs
        (p_business_group_id  ben_ext_rslt_dtl.business_group_id%TYPE
         )Return Number;

---Added new function to get EE DCP contribution Limit
Function get_dcp_limit
        (p_effective_date date
         ) Return number;

---------------------------
-- ============================
-- ~ Procedures               ~
-- ============================
Procedure Update_Record_Values
         (p_ext_rcd_id            In ben_ext_rcd.ext_rcd_id%TYPE
         ,p_ext_data_element_name In ben_ext_data_elmt.name%TYPE
         ,p_data_element_value    In ben_ext_rslt_dtl.val_01%TYPE
         ,p_data_ele_seqnum       In Number Default Null
         ,p_ext_dtl_rec           In out nocopy ben_ext_rslt_dtl%ROWTYPE
         );

Function Get_PTD_Start_End_Date
        (p_assignment_id  In per_all_assignments_f.assignment_id%TYPE
        ,p_effective_date In Date
         ) Return Varchar2;

Procedure Ins_Rslt_Dtl
          (p_dtl_rec In out nocopy ben_ext_rslt_dtl%ROWTYPE );


End PQP_US_SRS_Extracts;

 

/
