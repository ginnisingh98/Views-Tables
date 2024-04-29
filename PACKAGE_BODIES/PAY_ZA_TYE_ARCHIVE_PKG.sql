--------------------------------------------------------
--  DDL for Package Body PAY_ZA_TYE_ARCHIVE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ZA_TYE_ARCHIVE_PKG" as
/* $Header: pyzatyea.pkb 120.0.12010000.9 2010/03/23 11:56:45 parusia noship $ */

g_package varchar2(30) := 'pay_za_tye_archive_pkg.' ;
sql_range          varchar2(4000);

/*
ZA Tax Year End Data Archive Structure
--------------------------------------
Action Context Type : PA
Action_Info_Categiry: ZATYE_EMPLOYER_INFO
Action_Information1 : Code 2010 (Trading name)
Action_Information2 : Code 2020 (PAYE Ref Number)
Action_Information3 : Code 2022 (SDL Ref Num)
Action_Information4 : Code 2024 (UIF Ref Num)
Action_Information5 : Code 2025 (Employer Contact Person)
Action_Information6 : Code 2026 (Employer Contact Number)
Action_Information7 : Code 2027 (Employer e-mail Address)
Action_Information8 : Code 2028 (Payroll Software)
Action_Information9 : Code 2030 (Transaction Year)
Action_Information10: Code 2031 (Period of Reconciliation)
Action_Information11: Code 2035 (Employer Trade Classification)
Action_Information12: Code 2061 (Er Address : Unit Num)
Action_Information13: Code 2062 (Er Address : Complex)
Action_Information14: Code 2063 (Er Address : Street Num)
Action_Information15: Code 2064 (Er Address : Street / Name of Farm)
Action_Information16: Code 2065 (Er Address : Suburb/District)
Action_Information17: Code 2066 (Er Address : City/Town)
Action_Information18: Code 2080 (Er Address: Postal Code)

Action Context Type : AAP
Action_Info_Categiry: ZATYE_EMPLOYEE_INFO
Action_Information1 : Code 3010 (Certificate Num)
Action_Information2 : Code 3015 (Type of Certificate)
Action_Information3 : Code 3020 (Nature of Person)
Action_Information4 : Code 3025 (Year of Assessment)
Action_Information5 : Code 3030 (Surname or Trading Name)
Action_Information6 : Code 3040 (First 2 Names)
Action_Information7 : Code 3050 (Initials)
Action_Information8 : Code 3060 (Identity Number)
Action_Information9 : Code 3070 (Passport Number)
Action_Information10: Code 3075 (Country of Issue)
Action_Information11: Code 3080 (Date of Birth)
Action_Information12: Code 3100 (Income Tax Ref Num)
Action_Information13: Code 3160 (Employee Number)
Action_Information14: Code 3170 (Date Employed From)
Action_Information15: Code 3180 (Date Employed To)
Action_Information16: Code 3200 (Pay prds in Yr of  Assessment)
Action_Information17: Code 3210 (Pay Periods Worked)
Action_Information18: Code 3230_1 (Directive Number - 1)
Action_Information19: Code 3230_2 (Directive Number - 2)
Action_Information20: Code 3230_3 (Directive Number - 3)
Action_Information21: Code 3240 (Bank Account Type)
Action_Information22: Code 3241 (Bank Account Number)
Action_Information23: Code 3242 (Bank Branch Number)
Action_Information24: Code 3243 (Bank Name)
Action_Information25: Code 3244 (Bank Branch Name)
Action_Information26: Code 3245 (A/c Holder Name)
Action_Information27: Code 3246 (A/C Holder Relationship)
Action_Information28: Old/Manual Certificate (O/M/OM)
Action_Information29: Manual Certificate Number
Action_Information30: Temporary Certificate Number


Action Context Type : AAP
Action_Info_Categiry: ZATYE_EMPLOYEE_CONTACT_INFO
Action_Information1 : Code 3010 (Certificate Num)
Action_Information2 : Code 3125 (Contact E-mail)
Action_Information3 : Code 3135 (Home Telephone Num)
Action_Information4 : Code 3136 (Bus Telephone Num)
Action_Information5 : Code 3137 (Fax Num)
Action_Information6 : Code 3138 (Cell Num)
Action_Information7 : Code 3144 (Addr Bus: Unit Num)
Action_Information8 : Code 3145 (Addr Bus: Complex)
Action_Information9 : Code 3146 (Addr Bus : Street Num)
Action_Information10: Code 3147 (Addr Bus: Street/Name of Farm)
Action_Information11: Code 3148 (Addr Bus: Suburb/District)
Action_Information12: Code 3149 (Addr Bus: City/Town)
Action_Information13: Code 3150 (Addr Bus: Postal Code)
Action_Information14: Code 3211 (Addr Res: Unit Number)
Action_Information15: Code 3212 (Addr Res: Complex)
Action_Information16: Code 3213 (Addr Res: Street Number)
Action_Information17: Code 3214 (Addr Res: Street/Name of Farm)
Action_Information18: Code 3215 (Addr Res: Suburb/District)
Action_Information19: Code 3216 (Addr Res: City/Town)
Action_Information20: Code 3217 (Addr Res: Postal Code)
Action_Information21: Code 3218 (Postal Addr Same as Res)
Action_Information22: Code 3221 (Addr Pos: Line 1)
Action_Information23: Code 3222 (Addr Pos: Line2)
Action_Information24: Code 3223 (Addr Pos: Line3)
Action_Information25: Code 3229 (Addr Pos: Postal Code)
Action_Information26: Main Cert(MAIN)/Lumpsum Cert(LMPSM)
Action_Information30: Temporary Certificate Number


Action Context Type : AAP
Action_Info_Categiry: ZATYE_EMPLOYEE_INCOME
Action_Information1 : Code 3010 (Certificate Num)
Action_Information2 : Code Name
Action_Information3 : Code Included In
Action_Information4 : Code Value
Action_Information5 : Code Group Value
Action_Information30: Temporary Certificate Number

Action Context Type : AAP
Action_Info_Categiry: ZATYE_EMPLOYEE_LUMPSUMS
Action_Information1 : Code 3010 (Certificate Num)
Action_Information2 : Code Name
Action_Information3 : Code Included In
Action_Information4 : Normal Ceritificate Code Value
Action_Information5 : Code Group Value
Action_Information6 : Normal Certificate Directive
Action_Information7 : Directive 1
Action_Information8 : Directive 1 Value
Action_Information9 : Directive 2
Action_Information10: Directive 2 Value
Action_Information11: Directive 3
Action_Information12: Directive 3 Value
Action_Information30: Temporary Certificate Number

Action Context Type : AAP
Action_Info_Categiry: ZATYE_FINAL_EE_INCOME_1
Action_Information1  : Code 3010 (Certificate Num)
Action_Information2  : Code Name
Action_Information3  : Code Value
Action_Information4  : Code Name
Action_Information5  : Code Value
Action_Information6  : Code Name
Action_Information7  : Code Value
Action_Information8  : Code Name
Action_Information9  : Code Value
Action_Information10 : Code Name
Action_Information11 : Code Value
Action_Information12 : Code Name
Action_Information13 : Code Value
Action_Information14 : Code Name
Action_Information15 : Code Value
Action_Information16 : Code Name
Action_Information17 : Code Value
Action_Information18 : Code Name
Action_Information19 : Code Value
Action_Information20 : Code Name
Action_Information21 : Code Value
Action_Information22 : Code Name
Action_Information23 : Code Value
Action_Information24 : Code Name
Action_Information25 : Code Value
Action_Information26 : Code Name
Action_Information27 : Code Value
Action_Information30: Temporary Certificate Number

Action Context Type : AAP
Action_Info_Categiry: ZATYE_FINAL_EE_INCOME_2
Action_Information1  : Code 3010 (Certificate Num)
Action_Information2  : Code Name
Action_Information3  : Code Value
Action_Information4  : Code Name
Action_Information5  : Code Value
Action_Information6  : Code Name
Action_Information7  : Code Value
Action_Information8  : Code Name
Action_Information9  : Code Value
Action_Information10 : Code Name
Action_Information11 : Code Value
Action_Information12 : Code Name
Action_Information13 : Code Value
Action_Information14 : Code Name
Action_Information15 : Code Value
Action_Information16 : Code Name
Action_Information17 : Code Value
Action_Information18 : Code Name
Action_Information19 : Code Value
Action_Information20 : Code Name
Action_Information21 : Code Value
Action_Information22 : Code Name
Action_Information23 : Code Value
Action_Information24 : Code Name
Action_Information25 : Code Value
Action_Information26 : Code Name
Action_Information27 : Code Value
Action_Information30: Temporary Certificate Number

Action Context Type : AAP
Action_Info_Categiry: ZATYE_EMPLOYEE_GROSS_REMUNERATIONS
Action_Information1 : Code 3010 (Certificate Num)
Action_Information2 : Code 3696 (Non-Taxable Income)
Action_Information3 : Code 3697 (Gross Retirement Funding Income)
Action_Information4 : Code 3698 (Gross Non-Retire't Funding Inc)
Action_Information5 : Gross PKG (for use in exception log)
Action_Information30: Temporary Certificate Number

Action Context Type : AAP
Action_Info_Categiry: ZATYE_EMPLOYEE_DEDUCTIONS
Action_Information1 : Code 3010 (Certificate Num)
Action_Information2 : Code Name
Action_Information3 : Code Included In
Action_Information4 : Code Value
Action_Information5 : Code Group Value
Action_Information30: Temporary Certificate Number

Action Context Type : AAP
Action_Info_Categiry: ZATYE_FINAL_EE_DEDUCTIONS
Action_Information1  : Code 3010 (Certificate Num)
Action_Information2  : Code Name
Action_Information3  : Code Value
Action_Information4  : Code Name
Action_Information5  : Code Value
Action_Information6  : Code Name
Action_Information7  : Code Value
Action_Information8  : Code Name
Action_Information9  : Code Value
Action_Information10 : Code Name
Action_Information11 : Code Value
Action_Information12 : Code Name
Action_Information13 : Code Value
Action_Information14 : Code Name
Action_Information15 : Code Value
Action_Information16 : Code Name
Action_Information17 : Code Value
Action_Information18 : Code Name
Action_Information19 : Code Value
Action_Information20 : Code Name
Action_Information21 : Code Value
Action_Information22 : Code Name
Action_Information23 : Code Value
Action_Information24 : Code Name
Action_Information25 : Code Value
Action_Information26 : Code Name
Action_Information27 : Code Value
Action_Information30: Temporary Certificate Number

Action Context Type : AAP
Action_Info_Categiry: ZATYE_EMPLOYEE_TAX_AND_REASONS
Action_Information1 : Code 3010 (Certificate Num)
Action_Information2 : Code 4497(Total Deductions/ Contributions)
Action_Information3 : Code 4101 (SITE)
Action_Information4 : Code 4102 (PAYE+Voluntary Tax + Tax On Lumpsum)
Action_Information5 : Code 4115 (PAYE on retire't lumpsum benefits)
Action_Information6 : Code 4141 (Ee + Er UIF Contributions)
Action_Information7 : Code 4142 (Er SDL Contributions)
Action_Information8 : Code 4149 (Total Tax, SDL, UIF)
Action_Information9 : Code 4150 (Reason Code for IT3(a))
Action_Information10: Tax (for use in Exception log)
Action_Information11: PAYE(for use in Exception log)
Action_Information30: Temporary Certificate Number
*/


  -----------------
  -- Declare PL/SQL tables
  -----------------

  ----
  -- This table stores distinct code_names and a broad classification of them
  -- (INCOME, LUMPSUM, DEDUCTION, SITE, PAYE, PAYE_RET_LMPSM).
  -- Attribute lumpsum = Y/N
  -- Index will be code_name
  ----
  type code_list is record
       ( code_type              varchar2(100),
         lumpsum                varchar2(1)
       );

  ----
  -- This table stores the details for every code.
  -- Index will be a running sequence
  -- This table may contain multiple rows for a code
  -- Each row will contain the code_name, balance feeding this code,
  -- and a subtype
  -- (NON_TAXABLE, RFI, NRFI, PKG -- for income sources
  --  RFI_LUMPSUM, LUMPSUM        -- for Lumpsum sources
  --  DEDUCTION                   -- for deduction sources
  --  SITE, PAYE, PAYE_RET_LMPSM)
  ----
  type code_balances is record
       ( code                   number,
         defined_balance_id    number,
         full_balance_name      varchar2(100),
         balance_type_id        number,
         sub_type               varchar2(100)
       );


  ----
  -- This table stores values for all codes per assignment
  -- This will be initialised and used as a local variable in the archive_code section
  -- For that particular assignment, this table will contain the values of various codes
  ----
  type asg_code_rec is record
       ( value                  number
       , included_in            varchar2(100)
       , group_value            number
       );

  ----
  -- This table stores the directive numbers for an assignment
  -- This will be initialised and used as a local variable in the archive_code section
  -- For that particular assignemnt, this table will contain all the directive numbers
  -- including 'To Be Advised' of present.
  ----
  type dir_num_rec is record
       ( certificate_type             varchar2(4),
         certificate_merged_with_main varchar2(1)
       );

  ---
  -- This table will store the final code values to be reported for this assignment
  -- Index will the SARS codes
  -- This is used so as to traverse from first to last of its index (code)
  -- thereby producing the output as sorted by code
  ---
  type final_archive_rec is record (
         value                  number,
         code_type              varchar2(20)
       );

  ----
  -- This table will be used as a transit variable to pass information column values to
  -- archive api
  ----
  type act_info_rec is record
       ( assignment_id          number(20)
        ,person_id              number(20)
        ,effective_date         date
        ,action_info_category   varchar2(50)
        ,act_info1              varchar2(300)
        ,act_info2              varchar2(300)
        ,act_info3              varchar2(300)
        ,act_info4              varchar2(300)
        ,act_info5              varchar2(300)
        ,act_info6              varchar2(300)
        ,act_info7              varchar2(300)
        ,act_info8              varchar2(300)
        ,act_info9              varchar2(300)
        ,act_info10             varchar2(300)
        ,act_info11             varchar2(300)
        ,act_info12             varchar2(300)
        ,act_info13             varchar2(300)
        ,act_info14             varchar2(300)
        ,act_info15             varchar2(300)
        ,act_info16             varchar2(300)
        ,act_info17             varchar2(300)
        ,act_info18             varchar2(300)
        ,act_info19             varchar2(300)
        ,act_info20             varchar2(300)
        ,act_info21             varchar2(300)
        ,act_info22             varchar2(300)
        ,act_info23             varchar2(300)
        ,act_info24             varchar2(300)
        ,act_info25             varchar2(300)
        ,act_info26             varchar2(300)
        ,act_info27             varchar2(300)
        ,act_info28             varchar2(300)
        ,act_info29             varchar2(300)
        ,act_info30             varchar2(300)
       );

  type code_list_table     is table of code_list     index by binary_integer;
  type code_balances_table is table of code_balances index by binary_integer;
  type code_table          is table of asg_code_rec  index by varchar2(100);
  type dir_num_table       is table of dir_num_rec   index by varchar2(100);
  type action_info_table   is table of act_info_rec  index by binary_integer;
  type final_archive_table is table of final_archive_rec index by binary_integer;


  -------------------
  -- Forward declaration of functions and procedures
  -------------------
  procedure set_code_tables;
  function names(name varchar2)    return varchar2 ;
  function initials(name varchar2) return varchar2 ;
  procedure get_phones (p_person_id           in     number
                      , p_effective_date      in     date
                      , p_home_phone          out    nocopy varchar2
                      , p_work_phone          out    nocopy varchar2
                      , p_fax                 out    nocopy varchar2
                      , p_cell_number         out    nocopy varchar2
                      );
  procedure combine_certificates(
                        p_main_cert_type      in     varchar2
                      , p_main_cert_dir_num   in     varchar2
                      , t_dir_num             in out nocopy dir_num_table
                      , p_directive_1         out    nocopy varchar2
                      , p_directive_2         out    nocopy varchar2
                      , p_directive_3         out    nocopy varchar2
                      );
  procedure insert_archive_row(
                        p_assactid             in     number
                      , p_tab_rec_data         in     action_info_table
                      ) ;
  procedure fetch_balances (
                        p_assignment_action_id in number
                      , t_dir_num              in dir_num_table
                      , t_code                 out nocopy code_table
                       );
  function get_balance_value (
                        p_bal_name            in     varchar2
                      , p_dim_name            in     varchar2
		              , p_asg_act_id          in     number  )
                      return number ;
  procedure populate_irp5_indicators(
                        p_run_assact_id       in     number
                      , t_code                in     code_table
                      , p_main_cert_type      out    nocopy varchar2
                      , t_dir_num             in out nocopy dir_num_table
                      ) ;
  procedure consolidate_codes(
                        t_dir_num             in out nocopy dir_num_table
                      , t_code                in out nocopy code_table
                      );
  function it3a_reason_code(
                       p_run_assact_id       in      number
                     , p_nature              in      varchar2
                     , p_tax_status          in      varchar2
                     , p_normal_directive_value in   varchar2
                     , p_gross_total         in      number
                     , p_gross_non_txble_income in   number
                     , p_lmpsm_cert          in      varchar2
                     , p_tax_on_lmpsm        in      number
                     , p_independent_contractor in   varchar2
                     , p_foreign_income      in      varchar2
                     , p_labour_broker       in      varchar2)
                     return varchar2 ;
  procedure  copy_record (
                       from_rec            in     act_info_rec
                     , to_rec              in out nocopy act_info_rec
                     ) ;
  function final_code   (
                        p_code_complete   in    varchar2
                      , p_nature          in    varchar2
                      , p_tax_status      in    varchar2
                      , p_foreign_income  in    varchar2
                     ) return varchar2 ;
  function get_def_bal_id (
                         p_bal_type_id    in    number
                       , p_dim_name       in    varchar2) return number ;

  procedure fetch_person_data (p_assactid                in  number
                           , p_effective_date            in  date
                           , p_itreg_batch               in  varchar2
                           , p_tax_status                in  varchar2
                           , p_employee_info_rec         out nocopy act_info_rec
                           , p_employee_contact_info_rec out nocopy act_info_rec
                           , p_assignment_id             out nocopy number
                           , p_person_id                 out nocopy number
                           , p_foreign_income            out nocopy varchar2
                           , pactid                      out nocopy number
                           , p_nature                    out nocopy varchar2
                           , p_independent_contractor    out nocopy varchar2
                           , p_labour_broker             out nocopy varchar2
                           , p_lumpsum_date              out nocopy date);

   -----------------------------
   -- Global variables
   -----------------------------
   g_code_list      code_list_table ;
   g_code_bal       code_balances_table;
   g_defined_balance_lst_normal  pay_balance_pkg.t_balance_value_tab; -- used for batch balance retrieval
   g_defined_balance_lst_lmpsm   pay_balance_pkg.t_balance_value_tab; -- used for batch balance retrieval


/*--------------------------------------------------------------------------
  Name      : range_cursor
  Purpose   : 1) Archives Employer level information
              2) This returns the select statement that is used to create the
                 range rows.
  Arguments :
  Notes     : The range cursor determines which people should be processed.
              The normal practice is to include everyone, and then limit
              the list during the assignment action creation.
--------------------------------------------------------------------------*/
procedure range_cursor     (pactid  in number,
                            sqlstr  out nocopy varchar2) as

-- Get 'ZA Tax Information' (Context ZA_LEGAL_ENTITY)
cursor csr_tax_info (p_legal_entity_org hr_all_organization_units.organization_id%type)is
   select substr(hoi.org_information1, 1, 90) er_trade_name,	  	-- Employer Trading or Other Name (Code 2010)
          hoi.org_information3                paye_ref_num, 	  	-- PAYE Ref Num (Code 2020)
          upper(hoi.org_information6)         uif_ref_num, 		  	-- UIF  Ref Num (Code 2024)
          upper(hoi.org_information12)        sdl_ref_num, 		  	-- UIF  Ref Num (Code 2024)
          hoi.org_information13               er_trade_class        -- Employer Trade Classification (Code 2035)
   from   hr_organization_information hoi
   where  hoi.organization_id  = p_legal_entity_org
     and  hoi.org_information_context = 'ZA_LEGAL_ENTITY';

-- Get 'ZA Tax File Information' (Context ZA_GRE_TAX_FILE_ENTITY)
cursor csr_tax_file_creater_inf(p_legal_entity_org number)  is
   select (substr(hoi.org_information1, 1, 30)) er_contact_person,  -- code 2025
          hoi.org_information2                  er_contact_number,  -- code 2026
          hoi.org_information3                  er_email_address,   -- code 2027
          substr(hoi.org_information4,1,5)      unit_number,        -- Address : Unit Number (Code 2061)
          substr(hoi.org_information5,1,25)     complex,            -- Address : Complex (Code 2062)
          substr(hoi.org_information6,1,5)      street_number,      -- Address : Street Number (Code 2063)
          substr(hoi.org_information7,1,25)     street_farm,        -- Address : Street/Name of Farm (Code 2064)
          substr(hoi.org_information8,1,34)     suburb_district,    -- Address : Suburb/District (Code 2065)
          substr(hoi.org_information9,1,23)     town_city,          -- Address : Town/Cuty (Code 2066)
          substr(hoi.org_information10,1,4)     postal_code         -- Address : Postal Code (Code 2080)
   from   hr_organization_information hoi
   where  hoi.organization_id = p_legal_entity_org
     and  hoi.org_information_context = 'ZA_GRE_TAX_FILE_ENTITY';

l_proc                   varchar2(100) := g_package||'range_cursor';
l_legal_entity_org       number;
l_action_info_id         number;
l_ovn                    number;
l_tax_year               varchar2(4);
l_cert_type_param        varchar2(1);
l_itreg_batch            varchar2(1);
rec_tax_info             csr_tax_info%rowtype;
rec_tax_file_creater_inf csr_tax_file_creater_inf%rowtype;
leg_param                pay_payroll_actions.legislative_parameters%type;
begin
   fnd_file.put_line(fnd_file.log,'inside ' ||l_proc);
   hr_utility.set_location('Entering '||l_proc,10);

   -- Archive Legal Entity Level (Employer) Information

   -- Retrieve legislative parameters from the archiver payroll action
   select legislative_parameters
   into   leg_param
   from   pay_payroll_actions
   where  payroll_action_id = pactid;

   l_legal_entity_org := get_parameter('LEGAL_ENTITY', leg_param);
   l_tax_year         := get_parameter('TAX_YEAR',  leg_param);
   l_cert_type_param := get_parameter('CERT_TYPE',  leg_param);

   if l_cert_type_param = 1 then
      -- This is a normal (IRP5/IT3A) archive process
      l_itreg_batch := 'N';
      hr_utility.set_location(l_proc,15);
   else
      -- This is an ITREG batch process
      l_itreg_batch := 'Y';
      hr_utility.set_location(l_proc,16);
   end if;

   hr_utility.set_location(l_proc,20);

   -- Fetch Legal Entity level information
   open  csr_tax_info(l_legal_entity_org);
   fetch csr_tax_info into rec_tax_info;
   close csr_tax_info ;

   open csr_tax_file_creater_inf(l_legal_entity_org);
   fetch csr_tax_file_creater_inf into rec_tax_file_creater_inf;
   close csr_tax_file_creater_inf;

   hr_utility.set_location(l_proc,30);

   -- remove special characters from UIF Ref Num
   rec_tax_info.uif_ref_num := translate(rec_tax_info.uif_ref_num,
                                        'U0123456789ABCDEFGHIJKLMNOPQRSTVWXYZ- "\/?@&$!#+=;:,''().',
                                        'U0123456789');

   -- archive data
   hr_utility.set_location(l_proc,40);
         pay_action_information_api.create_action_information
         (
            p_action_information_id       => l_action_info_id,
            p_action_context_id           => pactid,
            p_action_context_type         => 'PA',
            p_object_version_number       => l_ovn,
            p_effective_date              => sysdate,
            p_action_information_category => 'ZATYE_EMPLOYER_INFO',
            p_action_information1         => rec_tax_info.er_trade_name,
            p_action_information2         => rec_tax_info.paye_ref_num,
            p_action_information3         => rec_tax_info.sdl_ref_num,
            p_action_information4         => rec_tax_info.uif_ref_num,
            p_action_information5         => rec_tax_file_creater_inf.er_contact_person,
            p_action_information6         => rec_tax_file_creater_inf.er_contact_number,
            p_action_information7         => rec_tax_file_creater_inf.er_email_address,
            p_action_information8         => 'ORACLE HRMS', -- revisit
            p_action_information9         => case when l_itreg_batch='N' then l_tax_year else null end,
            p_action_information10        => case when l_itreg_batch='N' then (l_tax_year || '02') else null end,
            p_action_information11        => rec_tax_info.er_trade_class,
            p_action_information12        => rec_tax_file_creater_inf.unit_number,
            p_action_information13        => rec_tax_file_creater_inf.complex,
            p_action_information14        => rec_tax_file_creater_inf.street_number,
            p_action_information15        => rec_tax_file_creater_inf.street_farm,
            p_action_information16        => rec_tax_file_creater_inf.suburb_district,
            p_action_information17        => rec_tax_file_creater_inf.town_city,
            p_action_information18        => rec_tax_file_creater_inf.postal_code
         );

   hr_utility.set_location(l_proc,50);
   sql_range :=
   'SELECT distinct ASG.person_id
    FROM   per_assignments_f   ASG,
           pay_payrolls_f      PPY,
           pay_payroll_actions PPA
    WHERE  PPA.payroll_action_id     = :payroll_action_id
      AND  ASG.business_group_id     = PPA.business_group_id
      AND  ASG.assignment_type       = ''E''
      AND  PPY.payroll_id            = ASG.payroll_id
    ORDER  BY ASG.person_id';

   sqlstr := sql_range;
   hr_utility.set_location('Leaving '||l_proc,999);
end ;




/*--------------------------------------------------------------------------
  Name      : archinit
  Purpose   : This procedure can be used to perform an initialisation
              section
  Arguments :
  Notes     : Call set_code_tables to initialize global pl/sql tables
--------------------------------------------------------------------------*/
procedure archinit(p_payroll_action_id in number) as
begin
   set_code_tables;
end ;




/*--------------------------------------------------------------------------
  Name      : action_creation
  Purpose   : This creates the assignment actions for a specific chunk.
  Arguments :
  Notes     :
--------------------------------------------------------------------------*/
procedure action_creation(pactid in number,
                          stperson in number,
                          endperson in number,
                          chunk in number)  as
-- This cursor returns all assignments for which processing took place
-- in the Tax Year.
-- Note: This cursor does not date effectively join to per_assignments_f.
--       Duplicate assignments are, however, removed in the cursor loop.
/*
   "The cursor looks for assignments that are assigned AT TAX YEAR END to
   "specific legal entity that was given in the TYE Archiver SRS -
   "BUT, this means it will find the All Assignments it was on during
   "the Tax year (and for which processing took place), whenever the TYE Archiver SRS
   "is run for each of those legal entities.
*/

cursor get_asg( p_legal_entity hr_all_organization_units.organization_id%TYPE
              , p_payroll_id pay_all_payrolls_f.payroll_id%TYPE
              , p_tax_year   varchar2
              , p_itreg_batch varchar2) is
   SELECT /*+ INDEX(asg PER_ASSIGNMENTS_F_N12) */
          /* we used the above hint to always ensure that the use the person_id
             index on per_assignments_f, otherwise, it is feasible the CBO may decide to
             choose the N7 (payroll_id) index due to it being a bind */
          asg.person_id     person_id
        , asg.assignment_id assignment_id
     FROM
          per_all_assignments_f asg
        , pay_payroll_actions   ppa_arch
        , per_assignment_extra_info aei
    WHERE
          ppa_arch.payroll_action_id = pactid
      AND asg.business_group_id + 0 = ppa_arch.business_group_id
      AND asg.person_id BETWEEN stperson AND endperson
      AND aei.assignment_id = asg.assignment_id
      AND aei.aei_information7 = to_char(p_legal_entity)
      AND asg.payroll_id is not null
      AND asg.payroll_id = nvl(p_payroll_id,asg.payroll_id)
      AND
        ( ppa_arch.effective_date BETWEEN asg.effective_start_date
                                      AND asg.effective_end_date
          OR
           ( asg.effective_end_date <= ppa_arch.effective_date
             AND asg.effective_end_date =
               ( SELECT MAX(asg2.effective_end_date)
                   FROM per_all_assignments_f asg2
                  WHERE asg2.assignment_id  = asg.assignment_id
               )
           )
        )
      -- for ITREG batch, pick up only persons with Nature A/B/C/N
      AND (p_itreg_batch = 'N'
           or
             (p_itreg_batch = 'Y'  and aei.aei_information4 in ('01','02','03','11'))
           )
      AND EXISTS (SELECT /*+ ORDERED */
                         /* the ordered hint will force the paa table to be joined to first */
                    NULL
                    FROM pay_assignment_actions     paa
                       , pay_payroll_actions        ppa
                       , per_time_periods           ptp
                   WHERE paa.assignment_id        = asg.assignment_id
                     AND paa.payroll_action_id    = ppa.payroll_action_id
                     AND ppa.action_type          IN ('R', 'Q', 'V', 'B', 'I')
                     AND ptp.time_period_id       = ppa.time_period_id
                     AND ptp.prd_information1     = p_tax_year
                     AND paa.action_status        = 'C'
                     AND ppa.action_status        = 'C'
                 )
   order by 1, 2;

asg_set_id         number;
person_id          number;
l_payroll_id       number;
asg_include        boolean;
lockingactid       number;
v_incl_sw          char;
prev_asg_id        number := 0;
l_legal_entity_org number;
l_tax_year         varchar2(4);
l_ppa_payroll_id   number;
l_proc             varchar2(100)  := g_package||'action_creation';
leg_param          pay_payroll_actions.legislative_parameters%type;
l_cert_type        varchar2(1);
l_itreg_batch      varchar2(1);
BEGIN

--   hr_utility.trace_on(null,'ZATRC');
   hr_utility.set_location('Entering '||l_proc, 10);
   fnd_file.put_line(fnd_file.log,'inside ' ||l_proc);

   -- Get the legislative parameters from the archiver payroll action
   select legislative_parameters,payroll_id
   into   leg_param,l_ppa_payroll_id
   from   pay_payroll_actions
   where  payroll_action_id = pactid;

   asg_set_id         := get_parameter('ASG_SET_ID', leg_param);
   person_id          := get_parameter('PERSON_ID',  leg_param);
   l_legal_entity_org := get_parameter('LEGAL_ENTITY', leg_param);
   l_payroll_id       := get_parameter('PAYROLL_ID', leg_param);
   l_tax_year         := get_parameter('TAX_YEAR', leg_param);
   l_cert_type        := get_parameter('CERT_TYPE', leg_param);

   hr_utility.set_location(l_proc,10);

   if l_cert_type = '1' then
      l_itreg_batch := 'N';
   else
      l_itreg_batch := 'Y';
   end if;

   -- Update the Payroll Action with the Payroll ID
   --
   IF l_ppa_payroll_id IS NULL and l_payroll_id is not null THEN
      update pay_payroll_actions
         set payroll_id = l_payroll_id
       where payroll_action_id = pactid;
   END IF;

   if  asg_set_id is not null then
       begin
         select distinct include_or_exclude
         into v_incl_sw
         from   hr_assignment_set_amendments
         where  assignment_set_id = asg_set_id;
       exception
         when no_data_found  then
              v_incl_sw := 'I';
       end;
   end if;

   hr_utility.set_location(l_proc,20);

   for asgrec in get_asg(l_legal_entity_org,l_payroll_id,l_tax_year,l_itreg_batch) loop
      hr_utility.set_location('Assignment_id : ' || to_char(asgrec.assignment_id), 20);
      asg_include := TRUE;

      -- Remove duplicate assignments
      if prev_asg_id <> asgrec.assignment_id then -- revisit -- check if required ?

         prev_asg_id := asgrec.assignment_id;

         if asg_set_id is not null then

            declare
               inc_flag varchar2(5);
            begin
               select include_or_exclude
               into   inc_flag
               from   hr_assignment_set_amendments
               where  assignment_set_id = asg_set_id
                 and  assignment_id = asgrec.assignment_id;

               if inc_flag = 'E' then
                  asg_include := FALSE;
               end if;
            exception
               when no_data_found then
                    if  v_incl_sw = 'I' then
                        asg_include := FALSE;
                    else
                        asg_include := TRUE;
                    end if;
            end ;

         end if;

         if person_id is not null then
            if person_id <> asgrec.person_id then
               asg_include := FALSE;
            end if;
         end if;

         /* Earlier we were creating separate assignment actions for every directive number
            attached to the assignment.
            But now we are creating only one assignment action per assignment
          */
        if asg_include = TRUE then
            -- Create one assignment action for every assignment
            hr_utility.set_location('Archiving for assignment_id '||asgrec.assignment_id, 50);
            select pay_assignment_actions_s.nextval
            into   lockingactid
            from   dual;

            -- Insert assignment into pay_assignment_actions
            hr_nonrun_asact.insact
            (
               lockingactid,
               asgrec.assignment_id,
               pactid,
               chunk,
               null
            );
         end if;

      end if;
   end loop;

   hr_utility.set_location('Leaving '||l_proc, 999);
--   hr_utility.trace_off;
end action_creation;




/*--------------------------------------------------------------------------
  Name      : archive_data
  Purpose   : This sets up the contexts needed for the live (non-archive)
              database items
  Arguments :
  Notes     : Every possible context for a specific assignment action has to
              be added to the PL/SQL table

PL/SQL Tables used -
1) t_code    - contains values of all codes for this assignment
             - index by code(for normal codes) or code-dirnum (for lumpsums)
             - Attributes : a) Value
2) t_dir_num - all directive numbers for this assignment,
             - index by directive_number
             - Attributes : a) certificate_type - IRP5/IT3A/ITREG
                            b) clubbed with main certificate flag - Y (for dirnums which are clubbed with main certificate)
                                                                  - N (for dirnums which have separate certificates)

Code flow -
1) Set PL/SQL tables, Fetch ZA_Tax Element Details for last payroll_run for this assignment
2) Fetch employee's basic data
3) Populate t_dir_num with all directive numbers for this assignment in this tax year including ('To Be Advised')
4) Fetch_balances() - Populate t_code with values for income/lumpsum/deduction/gross codes for this assignment
5) Populate_irp5_indicators() - Identify type(IRP5/IT3A/ITREG) of main certificate and lumpsum certificates
6) Combine_certificates() - Identify which lumpsum certificates can be merged with main certificate
7) Consolidate_codes() - Consolidate codes for
   a) Codes which are to be incorporated into other codes as per SARS
   b) All codes of lumpsum certificates are to be merged with main certificate
   c) For codes 3907, 3697, and 3698
      Merge t_code(code-To Be Advised) into t_code(code) to avoid duplicate reporting
8) Populate employee's Main Certificate information into l_archive_tab
9) Populate employee's Lumpsum Certificate information into l_archive_tab
10) Call archive API to archive data from l_archive_tab

--------------------------------------------------------------------------*/
procedure archive_data (p_assactid         in   number,
                        p_effective_date   in   date) as

cursor curdirnum (p_ass_id in number, p_tax_year varchar2) is
select distinct prrv.result_value directive_number
from pay_payroll_actions      ppa
    , per_time_periods        ptp
    , pay_assignment_actions  paa
    , pay_run_results         prr
    , pay_run_result_values   prrv
    , pay_element_types_f     peef
    , pay_input_values_f      piv
WHERE ppa.action_type in ('R', 'Q', 'V', 'B', 'I')
  and ppa.action_status = 'C'
  and ppa.time_period_id = ptp.time_period_id
  and ptp.prd_information1 = p_tax_year
  and paa.payroll_action_id = ppa.payroll_action_id
  and paa.action_status = 'C'
  and paa.assignment_id = p_ass_id
  and prr.assignment_action_id = paa.assignment_action_id
  and prrv.run_result_id = prr.run_result_id
  and peef.element_type_id = prr.element_type_id
  and piv.input_value_id = prrv.input_value_id
  and piv.name = 'Tax Directive Number'
  and peef.element_name <> 'ZA_Tax'
  and ppa.effective_date between peef.effective_start_date and peef.effective_end_date
  and ppa.effective_date between piv.effective_start_date and piv.effective_end_date;

cursor csr_tax_status (p_run_assact_id number, p_input_value_name varchar2)is
      select max(peevf.screen_entry_value)
      from   pay_element_entry_values_f peevf,
             pay_element_entries_f      peef,
             pay_link_input_values_f    plivf,
             pay_input_values_f         pivf,
             pay_element_types_f        petf,
             pay_payroll_actions        ppa,
             pay_assignment_actions     paa
      where  paa.assignment_action_id = p_run_assact_id
      and    ppa.payroll_action_id    = paa.payroll_action_id
      and    petf.element_name        = 'ZA_Tax'
      and    petf.legislation_code    = 'ZA'
      and    petf.business_group_id   is null
      and    ppa.effective_date between petf.effective_start_date
                                and     petf.effective_end_date
      and    pivf.element_type_id = petf.element_type_id
      and    pivf.name            = p_input_value_name
      and    ppa.effective_date between pivf.effective_start_date
                                and     pivf.effective_end_date
      and    plivf.input_value_id = pivf.input_value_id
      and    ppa.effective_date between plivf.effective_start_date
                                and     plivf.effective_end_date
      and    peef.element_link_id  = plivf.element_link_id
      and    peef.assignment_id    = paa.assignment_id
      and    peevf.element_entry_id = peef.element_entry_id
      and    peef.effective_start_date =
      (
         select max(peef2.effective_start_date)
         from   pay_element_entries_f peef2
         where  peef2.effective_start_date <= ppa.effective_date
         and    peef2.element_link_id       = plivf.element_link_id
         and    peef2.assignment_id         = paa.assignment_id
      )
      and    peevf.input_value_id       = pivf.input_value_id
      and    peevf.effective_start_date = peef.effective_start_date
      and    peevf.effective_end_date   = peef.effective_end_date;

l_proc varchar2(100) := g_package||'archive_data';
l_tax_year          varchar2(4);
l_run_action_seq    number;
l_run_assact_id     number;
l_assignment_id     number;
l_pact_id           number;
l_main_cert_type    varchar2(4);
l_main_cert_dir_num varchar2(100);
l_directive_1       varchar2(100);
l_directive_2       varchar2(100);
l_directive_3       varchar2(100);
l_rec_count         number := 0;
l_code_final        varchar2(2);
l_code_complete     varchar2(100);
l_tax_status        varchar2(100);
l_foreign_income    varchar2(1);
l_person_id         number;
l_dir_num           varchar2(100);
l_cert_count        number:=1 ; -- to generate temporary certificate numbers
l_main_cert_dir_val varchar2(100);
l_nature            varchar2(2);
l_independent_contractor varchar2(1);
l_labour_broker     varchar2(1);
l_reason_for_IT3A   varchar2(2);
l_leg_param         pay_payroll_actions.legislative_parameters%type;
t_final_arch        final_archive_table;
t_code              code_table;    -- values of all codes for this assignment, index by code / code-dirnum
t_dir_num           dir_num_table; -- all directive numbers for this assignment,
                                   -- index by directive_number

l_temp_cert_num     varchar2(30);
l_row_count         number := 0;
l_code              varchar2(4);
l_archive_tab       action_info_table;
l_inc1_rec          number;
l_inc2_rec          number;
l_ded_rec           number;
l_inc_count         number := 2; -- start from action_information2
l_ded_count         number := 2; -- start from action_information2
l_rec               number;
l_field             number;
l_cert_type_param   varchar2(1);
l_itreg_batch       varchar2(1);
l_lumpsum_effective_date date;
l_code_arch         varchar2(4);

l_4101              varchar2(100);
l_4102              varchar2(100);
l_4103              varchar2(100);
l_4115              varchar2(100);
l_4141              varchar2(100);
l_4142              varchar2(100);
l_4149              varchar2(100);
l_4150              varchar2(100);
begin
null;
 -- hr_utility.trace_on(null,'ZATRC');
   fnd_file.put_line(fnd_file.log,'inside ' ||l_proc);
   hr_utility.set_location('Entering '||l_proc,1);
   hr_utility.set_location('p_assactid : '||p_assactid,1);
   hr_utility.set_location('p_effective_date : '||p_effective_date,1);
   ------------------------------------------------------------------------
   -- 1. Set PL/SQL Tables
   --    Fetch ZA_Tax Element Details for last payroll_run for this assignment
   ------------------------------------------------------------------------

   -- set pl/sql tables is not already set
   if g_code_list.count = 0 then
      set_code_tables;
   end if ;

   select ppa.legislative_parameters
        , paa.assignment_id
   into   l_leg_param
        , l_assignment_id
   from   pay_payroll_actions    ppa
        , pay_assignment_actions paa
   where  paa.assignment_action_id = p_assactid
     and  ppa.payroll_action_id = paa.payroll_action_id ;
   l_tax_year  := get_parameter('TAX_YEAR',  l_leg_param);
   l_cert_type_param := get_parameter('CERT_TYPE',  l_leg_param);

   hr_utility.trace('Certificate type param: '|| l_cert_type_param);

   if l_cert_type_param = 1 then
      -- This is a normal (IRP5/IT3A) archive process
      l_itreg_batch := 'N';
   else
      -- This is an ITREG batch process
      l_itreg_batch := 'Y';
   end if;

   -- Fetch assignment_action_id for last payroll run for that assignment
   -- in this tax year
   select max(paa.action_sequence)
   into   l_run_action_seq
   from   pay_assignment_actions     paa,
          pay_payroll_actions        ppa,
          per_time_periods           ptp
   where  paa.assignment_id = l_assignment_id
     and  paa.action_status = 'C'
     and  paa.payroll_action_id = ppa.payroll_action_id
     and  ppa.action_type IN ('R', 'Q', 'V', 'B', 'I')
     and  ppa.action_status = 'C'
     and  ppa.time_period_id = ptp.time_period_id
     and  ptp.prd_information1 = l_tax_year;

   select assignment_action_id
   into   l_run_assact_id
   from   pay_assignment_actions
   where  assignment_id = l_assignment_id
     and  action_sequence = l_run_action_seq;

  hr_utility.trace('Last payroll run assignment_action_id : '|| l_run_assact_id);

  hr_utility.set_location(l_proc,10);
  open csr_tax_status (l_run_assact_id, 'Tax Status');
  fetch csr_tax_status into l_tax_status;
  close csr_tax_status;

  open csr_tax_status (l_run_assact_id, 'Tax Directive Number');
  fetch csr_tax_status into l_main_cert_dir_num;
  close csr_tax_status;

  open csr_tax_status (l_run_assact_id, 'Tax Directive Value');
  fetch csr_tax_status into l_main_cert_dir_val;
  close csr_tax_status;

  l_tax_status := nvl(l_tax_status,'A');

  hr_utility.set_location(l_proc,20);


   ------------------------------------------------------------------------
   -- 2. Fetch employee's basic data
   ------------------------------------------------------------------------
   fetch_person_data(  p_assactid
                     , p_effective_date
                     , l_itreg_batch
                     , l_tax_status
                     -- Out parameters
                     , l_archive_tab(0)
                     , l_archive_tab(1)
                     , l_assignment_id
                     , l_person_id
                     , l_foreign_income
                     , l_pact_id
                     , l_nature
                     , l_independent_contractor
                     , l_labour_broker
                     , l_lumpsum_effective_date);

   hr_utility.set_location(l_proc,30);

   ------------------------------------------------------------------------
   -- 3. Populate t_dir_num with all directive numbers for this assignment in this tax year
   ------------------------------------------------------------------------
   if l_itreg_batch = 'N' then
   for dirnum in curdirnum(l_assignment_id, l_tax_year)
   loop
        hr_utility.trace('t_dir_num('||dirnum.directive_number||')');
        t_dir_num(dirnum.directive_number).certificate_type  :=  null;
        t_dir_num(dirnum.directive_number).certificate_merged_with_main :=  null;
   end loop;
   end if;

  hr_utility.set_location(l_proc,40);


   ------------------------------------------------------------------------
   -- 4. Populate t_code with values for income/lumpsum/deduction/gross codes for this assignment
   ------------------------------------------------------------------------
   if l_itreg_batch = 'N'  then
   fetch_balances ( l_run_assact_id
                  , t_dir_num
                  , t_code);
   end if;

  hr_utility.set_location(l_proc,50);


   ------------------------------------------------------------------------
   --  5. Identify type(IRP5/IT3A/ITREG) of main certificate and lumpsum certificates
   ------------------------------------------------------------------------
  if l_itreg_batch = 'N' then
  populate_irp5_indicators(l_run_assact_id
                         , t_code
                         , l_main_cert_type
                         , t_dir_num);
   end if;

   hr_utility.set_location(l_proc,60);


   ------------------------------------------------------------------------
   --  6. Identify which lumpsum certificates can be merged with main certificate
   ------------------------------------------------------------------------
   -- Bug 9499475 - Removing the functionality of combining lumpsum certificates
   -- with the main certificate.
   -- This is done because we are introducing the functionality of Aug's certificate
   -- number to be re-used in Feb, if the Aug's certificate number is not reused
   -- then for SARS, Feb's certificate would mean an additional information, else
   -- it would mean replacement of Aug's information with Feb's information
   --
   -- If we keep allowing for certificate combination, then the lumpsum cert
   -- combining with main cert might be different in Aug and Feb, but generated
   -- under same certificate number. Then should we reuse the Aug's cert num, OR
   -- generate a new cert num. Both would be wrong.
   --
   -- Hence the functionality of certificate number combination has been removed
   --
   if l_itreg_batch = 'N' then
     if t_dir_num.exists('To Be Advised') then
         t_dir_num('To Be Advised').certificate_merged_with_main := 'Y';
     end if;
   /*
   combine_certificates( l_main_cert_type
                       , l_main_cert_dir_num
                       , t_dir_num
                       , l_directive_1
                       , l_directive_2
                       , l_directive_3);
  */
   end if;

   hr_utility.set_location(l_proc,70);


   ------------------------------------------------------------------------
   --  7. Consolidate codes for
   --     1) Codes which are to be incorporated into other codes as per SARS
   --     2) All codes of lumpsum certificates are to be merged with main certificate
   --     3) For codes 3907, 3697, 3698, and 4102
   --        Merge t_code(code-To Be Advised) into t_code(code) to avoid duplicate reporting
   ------------------------------------------------------------------------
   if l_itreg_batch = 'N' then
   consolidate_codes(t_dir_num
                   , t_code);
   end if;

   hr_utility.set_location(l_proc,80);


   ------------------------------------------------------------------------
   --  8. Populate employee's Main Certificate information into archive_tab
   ------------------------------------------------------------------------
   l_temp_cert_num := lpad(p_assactid,25,'0')||'-'||lpad(l_cert_count,4,'0');

   -- Update employee's basic information
   if l_itreg_batch = 'N'  then
       if l_main_cert_type = 'IRP5' then
          l_archive_tab(0).act_info2  := 'IRP5'; -- Main Certificate Type (IRP5/IT3A/ITREG/A)
       elsif l_main_cert_type = 'IT3A' then
          l_archive_tab(0).act_info2  := 'IT3(a)'; -- Main Certificate Type (IRP5/IT3A/ITREG/A)
       elsif l_main_cert_type = 'A' then
              l_archive_tab(0).act_info2  := 'A';
       end if;
   else
       l_archive_tab(0).act_info2  := 'ITREG';
   end if;

   l_archive_tab(0).act_info18 := l_directive_1;    -- Directive1
   l_archive_tab(0).act_info19 := l_directive_2;    -- Directive2
   l_archive_tab(0).act_info20 := l_directive_3;    -- Directive3
   l_archive_tab(0).act_info30 := l_temp_cert_num;   -- Temporary certificate Number

   l_archive_tab(1).act_info26 := 'MAIN';           -- employee's main certificate
   l_archive_tab(1).act_info30  := l_temp_cert_num;   -- Temporary certificate Number
   l_rec_count := 1;

   hr_utility.set_location(l_proc,90);

  -- Archive Income/Deduction codes data only if this is not an itreg batch
  if l_itreg_batch = 'N' then
  -- Employee's main certificate income/deduction information - all codes
  hr_utility.set_location(l_proc,100);
  l_code_complete := t_code.first;
  loop
        l_code    := substr(l_code_complete,1,4);

        hr_utility.set_location('Code : '|| l_code_complete||'  Value : '||trunc(t_code(l_code_complete).group_value),110);

        if length(l_code_complete)>5 and l_code not in ('4102','4115','3697','3698')then
           -- For 3907, t_code(3907-dirnum) will be archived under Lumpsums
           -- Lumpsum code
           l_dir_num := substr(l_code_complete,6);
           if l_dir_num = 'To Be Advised' then
              -- Archive only To Be Advised record for lumpsums
              -- separate directive_num values will be archived in same record

              hr_utility.set_location(l_proc,120);

              l_rec_count := l_rec_count + 1;
              l_archive_tab(l_rec_count).assignment_id  := l_assignment_id;
              l_archive_tab(l_rec_count).person_id      := l_person_id;
              l_archive_tab(l_rec_count).action_info_category := 'ZATYE_EMPLOYEE_LUMPSUMS';
              l_archive_tab(l_rec_count).act_info2      := final_code(l_code_complete,l_nature,l_tax_status,l_foreign_income);
              l_archive_tab(l_rec_count).act_info3      := final_code(t_code(l_code_complete).included_in,l_nature,l_tax_status,l_foreign_income);
              l_archive_tab(l_rec_count).act_info4      := t_code(l_code_complete).value;
              l_archive_tab(l_rec_count).act_info5      := trunc(t_code(l_code_complete).group_value);
              l_archive_tab(l_rec_count).act_info6      := l_main_cert_dir_num; -- from ZA_Tax element
              if l_directive_1 is not null then
                  l_archive_tab(l_rec_count).act_info7      := l_directive_1;
                  if l_directive_1 = l_main_cert_dir_num then
                      l_archive_tab(l_rec_count).act_info8  := null;
                  else
                      l_archive_tab(l_rec_count).act_info8  := t_code(l_code||'-'||l_directive_1).group_value;
                  end if;
              end if;
              if l_directive_2 is not null then
                  l_archive_tab(l_rec_count).act_info9      := l_directive_2;
                  l_archive_tab(l_rec_count).act_info10     := t_code(l_code||'-'||l_directive_2).group_value;
              end if;

              if l_directive_3 is not null then
                  l_archive_tab(l_rec_count).act_info11     := l_directive_3;
                  l_archive_tab(l_rec_count).act_info12     := t_code(l_code||'-'||l_directive_3).group_value;
              end if;
              l_archive_tab(l_rec_count).act_info30         := l_temp_cert_num;
           end if;
        else
           -- Not Lumpsum

           l_code := substr(l_code_complete,1,4);
           if g_code_list.exists(l_code) then
              if g_code_list(l_code).code_type = 'INCOME' then

                 hr_utility.set_location(l_proc,130);

                 -- Income Code
                 -- For 3907, t_code(3907) will be archived as Normal Income
                 l_rec_count := l_rec_count + 1;
                 l_archive_tab(l_rec_count).assignment_id  := l_assignment_id;
                 l_archive_tab(l_rec_count).person_id      := l_person_id;
                 l_archive_tab(l_rec_count).action_info_category := 'ZATYE_EMPLOYEE_INCOME';
                 l_archive_tab(l_rec_count).act_info2      := final_code(l_code,l_nature,l_tax_status,l_foreign_income);
                 l_archive_tab(l_rec_count).act_info3      := final_code(t_code(l_code).included_in,l_nature,l_tax_status,l_foreign_income);
                 l_archive_tab(l_rec_count).act_info4      := t_code(l_code).value;
                 l_archive_tab(l_rec_count).act_info5      := trunc(t_code(l_code).group_value);
                 l_archive_tab(l_rec_count).act_info30     := l_temp_cert_num;
              elsif g_code_list(l_code).code_type = 'DEDUCTION' then
                 -- Deduction code

                 hr_utility.set_location(l_proc,140);

                 l_rec_count := l_rec_count + 1;
                 l_archive_tab(l_rec_count).assignment_id  := l_assignment_id;
                 l_archive_tab(l_rec_count).person_id      := l_person_id;
                 l_archive_tab(l_rec_count).action_info_category := 'ZATYE_EMPLOYEE_DEDUCTIONS';
                 l_archive_tab(l_rec_count).act_info2      := l_code_complete;
                 l_archive_tab(l_rec_count).act_info3      := t_code(l_code_complete).included_in;
                 l_archive_tab(l_rec_count).act_info4      := t_code(l_code_complete).value;
                 l_archive_tab(l_rec_count).act_info5      := trunc(t_code(l_code_complete).group_value);
                 l_archive_tab(l_rec_count).act_info30     := l_temp_cert_num;
              else
                 --ignore this code
                 hr_utility.set_location(l_proc,150);

              end if;
           else
              -- Can be a Gross code, ignore this code
              null;
           end if;
         end if;

        l_code_complete := t_code.next(l_code_complete);
        exit when l_code_complete is null;
  end loop;

  hr_utility.set_location(l_proc,160);

  -- Employee's main certificate income/deduction information - final record
  t_final_arch.delete;

  l_rec_count      := l_rec_count + 1;
  l_inc1_rec       := l_rec_count;
  l_archive_tab(l_inc1_rec).assignment_id  := l_assignment_id;
  l_archive_tab(l_inc1_rec).person_id      := l_person_id;
  l_archive_tab(l_inc1_rec).action_info_category := 'ZATYE_FINAL_EE_INCOME_1';
  l_archive_tab(l_inc1_rec).act_info30           := l_temp_cert_num;

  l_rec_count      := l_rec_count + 1;
  l_inc2_rec       := l_rec_count;
  l_archive_tab(l_inc2_rec).assignment_id  := l_assignment_id;
  l_archive_tab(l_inc2_rec).person_id      := l_person_id;
  l_archive_tab(l_inc2_rec).action_info_category := 'ZATYE_FINAL_EE_INCOME_2';
  l_archive_tab(l_inc2_rec).act_info30           := l_temp_cert_num;

  l_rec_count      := l_rec_count + 1;
  l_ded_rec        := l_rec_count;
  l_archive_tab(l_ded_rec).assignment_id  := l_assignment_id;
  l_archive_tab(l_ded_rec).person_id      := l_person_id;
  l_archive_tab(l_ded_rec).action_info_category := 'ZATYE_FINAL_EE_DEDUCTIONS';
  l_archive_tab(l_ded_rec).act_info30           := l_temp_cert_num;

  l_code_complete := t_code.first;
  l_code          := substr(l_code_complete,1,4);
  l_dir_num       := substr(l_code_complete,6);
  loop
     -- Only those codes which have not already been included
     if g_code_list.exists(l_code)
        and
        t_code(l_code_complete).included_in is null
        and
        t_code(l_code_complete).group_value <> 0 then
         --  Normal Income or 'To Be Advised' Lumpsum
         -- (For all lumpsum certificates, which are merged
         --  with main cert, their amounts have already been
         --  added to 'To Be Advised' group_value)

         -- Both t_code(3907) and t_code(3907-To Be Advised) can exist
         -- Hence ignore t_code(3907-To Be Advised)
         -- and report the combined value (already combined in consolidate_codes) ONCE with t_code(3907)
          if ((length(l_code_complete)>5 and  l_dir_num = 'To Be Advised' and l_code not in ('4102','4115','3697','3698')) -- Lumpsum
               or
               (g_code_list(l_code).code_type = 'INCOME' and length(l_code_complete) = 4)            -- Income
              )
              and
              l_code_complete <> '3907-To Be Advised'  then         -- ignore 3907-To Be Advised
                l_code_arch := final_code(l_code_complete,l_nature,l_tax_status,l_foreign_income);
                t_final_arch(l_code_arch).value     := trunc(t_code(l_code_complete).group_value);
                t_final_arch(l_code_arch).code_type := 'INCOME';
          elsif g_code_list(l_code).code_type = 'DEDUCTION' then
               -- ZATYE_FINAL_EE_DEDUCTIONS
                l_code_arch := l_code;
                t_final_arch(l_code_arch).value     := trunc(t_code(l_code).group_value);
                t_final_arch(l_code_arch).code_type := 'DEDUCTION';
          else
              null ;
              -- ignore this code
          end if;
      end if;

      -- fetch next code
      l_code_complete := t_code.next(l_code_complete);
      l_code          := substr(l_code_complete,1,4);
      l_dir_num       := substr(l_code_complete,6);
      exit when l_code is null;
  end loop;

  hr_utility.set_location(l_proc,170);

  l_code := t_final_arch.first;
  while l_code is not null
  loop
      -- identify the record and field to be updated
      if t_final_arch(l_code).code_type = 'INCOME' then
         if l_inc_count <=26 then
            -- ZATYE_FINAL_EE_INCOME_1
            l_rec       := l_inc1_rec;
            l_field     := l_inc_count;
            l_inc_count := l_inc_count + 2 ;
         else
            -- ZATYE_FINAL_EE_INCOME_2
            l_rec       := l_inc2_rec;
            l_field     := mod(l_inc_count,28)+2;
            l_inc_count := l_inc_count + 2 ;
         end if;
      else
         l_rec       := l_ded_rec;
         l_field     := l_ded_count;
         l_ded_count := l_ded_count + 2 ;
      end if;

      if    l_field = 2 then
            l_archive_tab(l_rec).act_info2  := l_code;
            l_archive_tab(l_rec).act_info3  := t_final_arch(l_code).value;
      elsif l_field = 4 then
            l_archive_tab(l_rec).act_info4  := l_code;
            l_archive_tab(l_rec).act_info5  := t_final_arch(l_code).value;
      elsif l_field = 6 then
            l_archive_tab(l_rec).act_info6  := l_code;
            l_archive_tab(l_rec).act_info7  := t_final_arch(l_code).value;
      elsif l_field = 8 then
            l_archive_tab(l_rec).act_info8  := l_code;
            l_archive_tab(l_rec).act_info9  := t_final_arch(l_code).value;
      elsif l_field = 10 then
            l_archive_tab(l_rec).act_info10 := l_code;
            l_archive_tab(l_rec).act_info11 := t_final_arch(l_code).value;
      elsif l_field = 12 then
            l_archive_tab(l_rec).act_info12 := l_code;
            l_archive_tab(l_rec).act_info13 := t_final_arch(l_code).value;
      elsif l_field = 14 then
            l_archive_tab(l_rec).act_info14 := l_code;
            l_archive_tab(l_rec).act_info15 := t_final_arch(l_code).value;
      elsif l_field = 16 then
            l_archive_tab(l_rec).act_info16 := l_code;
            l_archive_tab(l_rec).act_info17 := t_final_arch(l_code).value;
      elsif l_field = 18 then
            l_archive_tab(l_rec).act_info18 := l_code;
            l_archive_tab(l_rec).act_info19 := t_final_arch(l_code).value;
      elsif l_field = 20 then
            l_archive_tab(l_rec).act_info20 := l_code;
            l_archive_tab(l_rec).act_info21 := t_final_arch(l_code).value;
      elsif l_field = 22 then
            l_archive_tab(l_rec).act_info22 := l_code;
            l_archive_tab(l_rec).act_info23 := t_final_arch(l_code).value;
      elsif l_field = 24 then
            l_archive_tab(l_rec).act_info24 := l_code;
            l_archive_tab(l_rec).act_info25 := t_final_arch(l_code).value;
      elsif l_field = 26 then
            l_archive_tab(l_rec).act_info26 := l_code;
            l_archive_tab(l_rec).act_info27 := t_final_arch(l_code).value;
      end if;

      l_code := t_final_arch.next(l_code);
  end loop;

  hr_utility.set_location(l_proc,180);

  -- Employee's main certificate Gross Remunerations
   l_rec_count := l_rec_count + 1;
   l_archive_tab(l_rec_count).assignment_id  := l_assignment_id;
   l_archive_tab(l_rec_count).person_id      := l_person_id;
   l_archive_tab(l_rec_count).action_info_category := 'ZATYE_EMPLOYEE_GROSS_REMUNERATIONS';
   if trunc(t_code(3696).group_value) > 0 then
      -- if no non-taxable income exists, then this value must be nil
      l_archive_tab(l_rec_count).act_info2      := trunc(t_code(3696).group_value);
   end if;
   if l_inc_count > 2 then
      -- if there is no income code, then 3697, 3698 must be nil
      l_archive_tab(l_rec_count).act_info3      := trunc(t_code(3697).group_value);
      l_archive_tab(l_rec_count).act_info4      := trunc(t_code(3698).group_value);
   end if;
   l_archive_tab(l_rec_count).act_info5      := trunc(t_code(9999).group_value);-- Gross PKG , only used in excpetion log calculations
   l_archive_tab(l_rec_count).act_info30     := l_temp_cert_num;

   hr_utility.set_location(l_proc,190);

  -- Employee's main certificate Tax and Reasons
   l_rec_count := l_rec_count + 1;
   l_archive_tab(l_rec_count).assignment_id  := l_assignment_id;
   l_archive_tab(l_rec_count).person_id      := l_person_id;
   l_archive_tab(l_rec_count).action_info_category := 'ZATYE_EMPLOYEE_TAX_AND_REASONS';
   if l_ded_count > 2 then
       -- if no deduction code, then this value must be nil
       l_archive_tab(l_rec_count).act_info2      := trunc(t_code(4497).group_value);
   end if;

   hr_utility.set_location(l_proc,191);

   l_4101 := trim(to_char(t_code(4101).group_value,'99999999990D99'));
   if t_dir_num.exists('To Be Advised') then -- Lumpsum amounts exist
       l_4102 := trim(to_char(t_code(4102).group_value + t_code(4102||'-To Be Advised').group_value,'99999999990D99'));
       l_4115 := trim(to_char(t_code(4115||'-To Be Advised').group_value,'99999999990D99'));
       if (t_code('3915-To Be Advised').group_value = 0 and
           t_code('3920-To Be Advised').group_value = 0 and
           t_code('3921-To Be Advised').group_value = 0 and
           l_4115 = '0.00') then
           l_4115 := null;
       end if;
   else                                      -- No Lumpsum amounts
       l_4102 := trim(to_char(t_code(4102).group_value,'99999999990D99'));
       l_4115 := null;
   end if;

   hr_utility.set_location(l_proc,192);

   l_4141 := trim(to_char(t_code(4141).group_value,'99999999990D99')); -- UIF
   l_4142 := trim(to_char(t_code(4142).group_value,'99999999990D99')); -- SDL
   l_4149 := trim(to_char((to_number(l_4101) +
                           to_number(l_4102) +
                           nvl(to_number(l_4115),0) +
                           to_number(l_4141) +
                           to_number(l_4142))
                         ,'99999999990D99'));

   hr_utility.set_location(l_proc,193);

   if l_main_cert_type = 'IT3A' then
       if l_4101 = '0.00' then l_4101 := null; end if;
       if l_4102 = '0.00' then l_4102 := null; end if;
       if l_4115 = '0.00' then l_4115 := null; end if;
       l_4150 := it3a_reason_code( l_run_assact_id, l_nature, l_tax_status, l_main_cert_dir_val
                                 , t_code(3697).group_value + t_code(3698).group_value
                                 , t_code(3696).group_value
                                 , 'N', null, l_independent_contractor, l_foreign_income, l_labour_broker ) ;
   end if;

   hr_utility.set_location(l_proc,195);

   l_archive_tab(l_rec_count).act_info3 := l_4101;
   l_archive_tab(l_rec_count).act_info4 := l_4102;
   l_archive_tab(l_rec_count).act_info5 := l_4115;
   l_archive_tab(l_rec_count).act_info6 := l_4141;
   l_archive_tab(l_rec_count).act_info7 := l_4142;
   l_archive_tab(l_rec_count).act_info8 := l_4149;
   l_archive_tab(l_rec_count).act_info9 := l_4150;
   l_archive_tab(l_rec_count).act_info10:= t_code(9997).group_value;   -- Tax_ASG_TAX_YTD  - for use in exception log
   l_archive_tab(l_rec_count).act_info11:= t_code(9998).group_value;   -- PAYE_ASG_TAX_YTD - for use in exception log
   l_archive_tab(l_rec_count).act_info30:= l_temp_cert_num;

   hr_utility.set_location(l_proc,200);


   ------------------------------------------------------------------------
   --  9. Populate employee's Lumpsum Certificate information into archive_tab
   ------------------------------------------------------------------------
   l_dir_num := t_dir_num.first;
   if l_dir_num is not null then
   loop
      -- If the directive number is NOT merged with main certificate
      if t_dir_num(l_dir_num).certificate_merged_with_main is null then
         hr_utility.set_location('Archiving for directive_number '||l_dir_num,210);

         l_cert_count    := l_cert_count + 1; -- increase certificate number count
         l_temp_cert_num := lpad(p_assactid,25,'0')||'-'||lpad(l_cert_count,4,'0'); -- Temporary certificate number

         -- Employee information record
         l_rec_count := l_rec_count + 1;   -- increase archive record count
         l_archive_tab(l_rec_count).act_info30 := l_temp_cert_num;  -- Temporary certificate Number
         copy_record(l_archive_tab(0),l_archive_tab(l_rec_count));
         if t_dir_num(l_dir_num).certificate_type = 'IRP5' then     -- Main Certificate Type (IRP5/IT3A/ITREG/A)
              l_archive_tab(l_rec_count).act_info2  := 'IRP5';
         elsif t_dir_num(l_dir_num).certificate_type = 'IT3A' then
              l_archive_tab(l_rec_count).act_info2  := 'IT3(a)';
         elsif t_dir_num(l_dir_num).certificate_type = 'A' then
              l_archive_tab(l_rec_count).act_info2  := 'A';
         end if;

         --l_archive_tab(l_rec_count).act_info14 := trim(to_char(l_lumpsum_effective_date,'YYYYMMDD'));  -- Date Employed From
         --l_archive_tab(l_rec_count).act_info15 := trim(to_char(l_lumpsum_effective_date,'YYYYMMDD'));  -- Date Employed To
         l_archive_tab(l_rec_count).act_info16 := '1.0000';  -- Total Pay Periods in tax Year
         l_archive_tab(l_rec_count).act_info17 := '1.0000';  -- Pay Periods Worked
         l_archive_tab(l_rec_count).act_info18 := l_dir_num;        -- Directive1
         l_archive_tab(l_rec_count).act_info19 := null;             -- Directive2
         l_archive_tab(l_rec_count).act_info20 := null;             -- Directive3
         l_archive_tab(l_rec_count).act_info30 := l_temp_cert_num;  -- Temporary certificate Number

         -- Employee contact information record
         l_rec_count := l_rec_count + 1;
         l_archive_tab(l_rec_count).act_info30 := l_temp_cert_num;
         copy_record(l_archive_tab(1),l_archive_tab(l_rec_count));
         l_archive_tab(l_rec_count).act_info26 := 'LMPSM';          -- employee's lumpsum certificate
         l_archive_tab(l_rec_count).act_info30 := l_temp_cert_num;

         hr_utility.set_location(l_proc,220);

         -- Employee's lumpsum information records
         l_code := g_code_list.first;
         loop
               if g_code_list(l_code).lumpsum = 'Y' and l_code not in('4102','4115')then
                 l_rec_count := l_rec_count + 1;
                 l_archive_tab(l_rec_count).assignment_id  := l_assignment_id;
                 l_archive_tab(l_rec_count).person_id      := l_person_id;
                 l_archive_tab(l_rec_count).action_info_category := 'ZATYE_EMPLOYEE_LUMPSUMS';
                 l_archive_tab(l_rec_count).act_info2      := final_code(l_code,l_nature,l_tax_status,l_foreign_income);
                 l_archive_tab(l_rec_count).act_info3      := final_code(t_code(l_code||'-'||l_dir_num).included_in,l_nature,l_tax_status,l_foreign_income);
                 l_archive_tab(l_rec_count).act_info4      := t_code(l_code||'-'||l_dir_num).value;
                 l_archive_tab(l_rec_count).act_info5      := t_code(l_code||'-'||l_dir_num).group_value;
                 l_archive_tab(l_rec_count).act_info30     := l_temp_cert_num;
               end if;
             l_code := g_code_list.next(l_code);
             exit when l_code is null;
         end loop;

         hr_utility.set_location(l_proc,230);

         -- Employee's lumpsum certificate income information - final record
         t_final_arch.delete;
         l_rec_count      := l_rec_count + 1;
         l_archive_tab(l_rec_count).assignment_id  := l_assignment_id;
         l_archive_tab(l_rec_count).person_id      := l_person_id;
         l_archive_tab(l_rec_count).action_info_category := 'ZATYE_FINAL_EE_INCOME_1';
         l_archive_tab(l_rec_count).act_info30           := l_temp_cert_num;

         l_code := g_code_list.first;
         loop
            if g_code_list(l_code).lumpsum = 'Y' and l_code not in('4102','4115') then
               if t_code(l_code||'-'||l_dir_num).included_in is null
                 and t_code(l_code||'-'||l_dir_num).group_value <>0  then
                  l_code_complete := l_code||'-'||l_dir_num;
                  l_code_arch    := final_code(l_code_complete,l_nature,l_tax_status,l_foreign_income);
                  t_final_arch(l_code_arch).value := trunc(t_code(l_code_complete).group_value);
                  t_final_arch(l_code_arch).code_type  := 'INCOME';
               end if;
            end if;
            l_code := g_code_list.next(l_code);
            exit when l_code is null;
         end loop;

         l_inc_count      := 2;
         l_code := t_final_arch.first;
         while l_code is not null
         loop
             if    l_inc_count = 2 then
                   l_archive_tab(l_rec_count).act_info2  := l_code;
                   l_archive_tab(l_rec_count).act_info3  := t_final_arch(l_code).value;
             elsif l_inc_count = 4 then
                   l_archive_tab(l_rec_count).act_info4  := l_code;
                   l_archive_tab(l_rec_count).act_info5  := t_final_arch(l_code).value;
             elsif l_inc_count = 6 then
                   l_archive_tab(l_rec_count).act_info6  := l_code;
                   l_archive_tab(l_rec_count).act_info7  := t_final_arch(l_code).value;
             elsif l_inc_count = 8 then
                   l_archive_tab(l_rec_count).act_info8  := l_code;
                   l_archive_tab(l_rec_count).act_info9  := t_final_arch(l_code).value;
             elsif l_inc_count = 10 then
                   l_archive_tab(l_rec_count).act_info10 := l_code;
                   l_archive_tab(l_rec_count).act_info11 := t_final_arch(l_code).value;
             elsif l_inc_count = 12 then
                   l_archive_tab(l_rec_count).act_info12 := l_code;
                   l_archive_tab(l_rec_count).act_info13 := t_final_arch(l_code).value;
             elsif l_inc_count = 14 then
                   l_archive_tab(l_rec_count).act_info14 := l_code;
                   l_archive_tab(l_rec_count).act_info15 := t_final_arch(l_code).value;
             elsif l_inc_count = 16 then
                   l_archive_tab(l_rec_count).act_info16 := l_code;
                   l_archive_tab(l_rec_count).act_info17 := t_final_arch(l_code).value;
             elsif l_inc_count = 18 then
                   l_archive_tab(l_rec_count).act_info18 := l_code;
                   l_archive_tab(l_rec_count).act_info19 := t_final_arch(l_code).value;
             elsif l_inc_count = 20 then
                   l_archive_tab(l_rec_count).act_info20 := l_code;
                   l_archive_tab(l_rec_count).act_info21 := t_final_arch(l_code).value;
             elsif l_inc_count = 22 then
                   l_archive_tab(l_rec_count).act_info22 := l_code;
                   l_archive_tab(l_rec_count).act_info23 := t_final_arch(l_code).value;
             elsif l_inc_count = 24 then
                   l_archive_tab(l_rec_count).act_info24 := l_code;
                   l_archive_tab(l_rec_count).act_info25 := t_final_arch(l_code).value;
             elsif l_inc_count = 26 then
                   l_archive_tab(l_rec_count).act_info26 := l_code;
                   l_archive_tab(l_rec_count).act_info27 := t_final_arch(l_code).value;
             end if;
             l_inc_count      := l_inc_count+ 2;

             l_code := t_final_arch.next(l_code);
         end loop;

         hr_utility.set_location(l_proc,240);

        -- Employee's lumpsum gross remuneration
         l_rec_count := l_rec_count + 1;
         l_archive_tab(l_rec_count).assignment_id  := l_assignment_id;
         l_archive_tab(l_rec_count).person_id      := l_person_id;
         l_archive_tab(l_rec_count).action_info_category := 'ZATYE_EMPLOYEE_GROSS_REMUNERATIONS';
         l_archive_tab(l_rec_count).act_info2      := null; -- Non-Taxable Income
         if l_inc_count > 2 then
             l_archive_tab(l_rec_count).act_info3      := t_code(3697||'-'||l_dir_num).group_value;
             l_archive_tab(l_rec_count).act_info4      := t_code(3698||'-'||l_dir_num).group_value;
         end if;
         l_archive_tab(l_rec_count).act_info30     := l_temp_cert_num;


         -- Employee's lumpsum tax and reasons
         l_rec_count := l_rec_count + 1;
         l_archive_tab(l_rec_count).assignment_id  := l_assignment_id;
         l_archive_tab(l_rec_count).person_id      := l_person_id;
         l_archive_tab(l_rec_count).action_info_category := 'ZATYE_EMPLOYEE_TAX_AND_REASONS';

         l_4101 := '0.00'; -- SITE
         l_4102 := trim(to_char(t_code('4102-'||l_dir_num).group_value,'99999999990D99'));
         l_4115 := trim(to_char(t_code('4115-'||l_dir_num).group_value,'99999999990D99'));
         l_4141 := '0.00';
         l_4142 := '0.00';
         l_4149 := trim(to_char(to_number(l_4102) + nvl(to_number(l_4115),0),'99999999990D99'));
         l_4150 := null;

         -- if there is no value in 3915, 3920 and 3921, then code 4115 must not be specified
         -- if there is still a value in 4115, then it should be reported as error in exception log
         if (t_code('3915-'||l_dir_num).group_value = 0 and
             t_code('3920-'||l_dir_num).group_value = 0 and
             t_code('3921-'||l_dir_num).group_value = 0 and
             l_4115 = '0.00') then
             l_4115 := null;
         end if;

        if t_dir_num(l_dir_num).certificate_type = 'IT3A' then
           if l_4101 = '0.00' then l_4101 := null; end if;
           if l_4102 = '0.00' then l_4102 := null; end if;
           if l_4115 = '0.00' then l_4115 := null; end if;
           l_4150 := it3a_reason_code( l_run_assact_id, l_nature, l_tax_status, l_main_cert_dir_val
                                 , t_code(3697||'-'||l_dir_num).group_value + t_code(3698||'-'||l_dir_num).group_value
                                 , 0, 'Y'
                                 , t_code(4102||'-'||l_dir_num).group_value
                                 , l_independent_contractor, l_foreign_income, l_labour_broker ) ;
        end if;
        l_archive_tab(l_rec_count).act_info2 := null; -- Total Deductions
        l_archive_tab(l_rec_count).act_info3 := l_4101;
        l_archive_tab(l_rec_count).act_info4 := l_4102;
        l_archive_tab(l_rec_count).act_info5 := l_4115;
        l_archive_tab(l_rec_count).act_info6 := l_4141;
        l_archive_tab(l_rec_count).act_info7 := l_4142;
        l_archive_tab(l_rec_count).act_info8 := l_4149;
        l_archive_tab(l_rec_count).act_info9 := l_4150;
        l_archive_tab(l_rec_count).act_info10:= null;
        l_archive_tab(l_rec_count).act_info11:= null;
        l_archive_tab(l_rec_count).act_info30:= l_temp_cert_num;

      end if;

      hr_utility.set_location(l_proc,240);
      l_dir_num := t_dir_num.next(l_dir_num);
      exit when l_dir_num is null;
  end loop;
  end if;
  end if; -- end of    "if l_itreg_batch = 'N'"

  hr_utility.set_location(l_proc,230);

  ------------------------------------------------------------------------
  --  10. Call archive API to archive data from l_archive_tab
  ------------------------------------------------------------------------

  insert_archive_row(p_assactid, l_archive_tab);

  hr_utility.set_location('Leaving '||l_proc,999);

end archive_data;



---------------------------------------------------------------------------
--  Procedure deinit_code
---------------------------------------------------------------------------
procedure archdinit(pactid in number) as

   cursor csr_employee_info_rec is
   select pai.action_information30
        , pai.action_context_id
        , pai.action_context_type
   from pay_payroll_actions ppa
      , pay_assignment_actions paa
      , pay_action_information pai
   where ppa.payroll_action_id = pactid
     and ppa.action_status     = 'C'
     and paa.payroll_action_id = ppa.payroll_action_id
     and paa.action_status     = 'C'
     and pai.action_context_id = paa.assignment_action_id
     and pai.action_context_type = 'AAP'
     and pai.action_information_category = 'ZATYE_EMPLOYEE_INFO'
     and action_information1 is null
  order by pai.action_information30     ;


   l_req_id           NUMBER ;
   l_start_date       DATE;
   l_end_date         DATE;
   leg_param          pay_payroll_actions.legislative_parameters%type;
   l_legal_entity_org number;
   l_tax_year         varchar2(4);
   l_proc             varchar2(100) := g_package||'deinit_code';
   l_cert_type        varchar2(1);
   l_itreg_batch      varchar2(1);
   l_itreg_cert_num   varchar2(30) := lpad('0',30,'0');
begin
   fnd_file.put_line(fnd_file.log,'inside ' ||l_proc);

   hr_utility.set_location('Entering '|| l_proc,10);

   select legislative_parameters
   into   leg_param
   from   pay_payroll_actions
   where  payroll_action_id = pactid;

   l_legal_entity_org := get_parameter('LEGAL_ENTITY', leg_param);
   l_tax_year         := get_parameter('TAX_YEAR', leg_param);
   l_cert_type        := get_parameter('CERT_TYPE', leg_param);

   if l_cert_type = '1' then
      l_itreg_batch := 'N';
   else
      l_itreg_batch := 'Y';
   end if;

   if l_itreg_batch = 'Y' then
      for emprec in csr_employee_info_rec
      loop
          l_itreg_cert_num := lpad(l_itreg_cert_num + 1,30,'0');

          update pay_action_information
          set    action_information1  = l_itreg_cert_num
          where  action_context_type  = emprec.action_context_type
            and  action_context_id    = emprec.action_context_id
            and  action_information30 = emprec.action_information30 ;

      end loop;
   end if;

   -- Fork Exception Log Concurrent Program
   l_start_date  := to_date(get_parameter('START_DATE', leg_param),'YYYY/MM/DD hh24:mi:ss');
   l_end_date    := to_date(get_parameter('END_DATE',  leg_param),'YYYY/MM/DD hh24:mi:ss');

   l_req_id      := fnd_request.submit_request( 'PAY', -- application
        'PYZATYVL2010', -- program
        'Create Tax Year End exception log',  -- description
        NULL,                         -- start_time
        NULL,                         -- sub_request
        pactid,l_start_date,l_end_date,l_tax_year,chr(0),-- Start of Parameters or Arguments
        '','','','','',
        '','','','','','','','','','',
        '','','','','','','','','','',
        '','','','','','','','','','',
        '','','','','','','','','','',
        '','','','','','','','','','',
        '','','','','','','','','','',
        '','','','','','','','','','',
        '','','','','','','','','','',
        '','','','','','','','','','');

     IF (l_req_id = 0) THEN
         FND_FILE.PUT_LINE(FND_FILE.LOG, 'Unable to Create Tax Certificate Exception Log');
     END IF;

     hr_utility.set_location('Leaving '|| l_proc,999);

end archdinit;


/*--------------------------------------------------------------------------
  Name      : set_code_tables
  Purpose   : This procedure can be used to set the global pl/sql tables
  Arguments :
  Notes     : This will initialize the global tables -
              1) g_code_list - indexed by unique codes, contains code type
                               Contain single row per code
              2) g_code_bal  - indexed by running sequence, contains details
                               of codes and balances feeding that code.
                               Can contain multiple rows per code
              3) g_defined_balance_lst_lmpsm - defined balance list for lumpsum
                                balances - to be used in batch balance retrieval
              4) g_defined_balance_lst_normal - defined balance list for normal
                                balances - to be used in batch balance retrieval
--------------------------------------------------------------------------*/
procedure set_code_tables is

    -- INCOME SOURCES
    -- normal codes
    -- Normal     : 3601-3607,3609-3613,3615-3617
    -- Allowances : 3701-3706,3708-3717
    -- Fringe     : 3801-3810,3813
    -- Other Lumpsum : 3907 (only Other Lumpsum taxed as annual payment - balance seq 1) ,3908
    --
    -- Lumpsum codes
    -- 3608,3614,3707,3718,3901,3906,3907(only balance sequence 3),3909,3915,3920,3921
    --
    -- DEDUCTIONS/ CONTRIBUTIONS
    -- 4001-4007,4018,4024,4026,4030,4474,4493

   -- initialize code table
   cursor csr_code_details is
   select code,
          decode(code,
                 '3601','INCOME','3602','INCOME','3603','INCOME','3604','INCOME',
                 '3605','INCOME','3606','INCOME','3607','INCOME','3609','INCOME',
                 '3610','INCOME','3611','INCOME','3612','INCOME','3613','INCOME',
                 '3615','INCOME','3616','INCOME','3617','INCOME',
                 '3701','INCOME','3702','INCOME','3703','INCOME','3704','INCOME',
                 '3705','INCOME','3706','INCOME','3708','INCOME','3709','INCOME',
                 '3710','INCOME','3711','INCOME','3712','INCOME','3713','INCOME',
                 '3714','INCOME','3715','INCOME','3716','INCOME','3717','INCOME',
                 '3801','INCOME','3802','INCOME','3803','INCOME','3804','INCOME',
                 '3805','INCOME','3806','INCOME','3807','INCOME','3808','INCOME',
                 '3809','INCOME','3810','INCOME','3813','INCOME',
                 '3907','INCOME','3908','INCOME',
                 '3608','LUMPSUM','3614','LUMPSUM','3707','LUMPSUM','3718','LUMPSUM',
                 '3901','LUMPSUM','3906','LUMPSUM','3907','LUMPSUM','3909','LUMPSUM',
                 '3915','LUMPSUM','3920','LUMPSUM','3921','LUMPSUM',
                 '4001','DEDUCTION','4002','DEDUCTION','4003','DEDUCTION','4004','DEDUCTION',
                 '4005','DEDUCTION','4006','DEDUCTION','4007','DEDUCTION','4018','DEDUCTION',
                 '4024','DEDUCTION','4026','DEDUCTION','4030','DEDUCTION','4474','DEDUCTION',
                 '4493','DEDUCTION',
                 '4101','SITE','4102','PAYE','4115','PAYE_RET_LMPSM') code_type,
          sub_type(code,user_name,balance_sequence)   code_sub_type,
          full_balance_name,
          balance_type_id,
          balance_sequence
    from pay_za_irp5_bal_codes
    where (  code in (3601,3602,3603,3604,3605,3606,3607,3609,3610,3611,3612,3613,3615,3616,3617,
                   3701,3702,3703,3704,3705,3706,3708,3709,3710,3711,3712,3713,3714,3715,3716,3717,
                   3801,3802,3803,3804,3805,3806,3807,3808,3809,3810,3813,3908,
                   4001,4002,4003,4004,4005,4006,4007,4018,4024,4026,4030,4474,4493,
                   4101)
             and balance_sequence = 1
          )
          or
          (code = 4005 and balance_sequence = 2)
          or
          (code = 3907 and balance_sequence = 1 and full_balance_name <> 'Other Lump Sums')
          or
          (code = 4102 and balance_sequence = 1 and full_balance_name <> 'Tax on Lump Sums')
          or
          (  code in (3608,3614,3707,3718,3901,3906,3907,3909,3915,3920,3921,4102,4115)
             and balance_sequence = 3
          )
    order by code asc, balance_sequence desc;

    l_prev_code varchar2(4) := '0000';
    l_count           number      := 1;
    l_lmpsm_count     number      := 1;
    l_normal_count    number      := 1;
    l_def_bal_id      number;
    l_proc varchar2(100) := g_package||'set_code_tables';
begin
   fnd_file.put_line(fnd_file.log,'inside ' ||l_proc);
   hr_utility.set_location('Entering '|| l_proc,10);

   for code_rec in csr_code_details
   loop
           -- Add next distinct code to g_code_list
           if l_prev_code <> code_rec.code then
               if code_rec.balance_sequence = 3 then
                   g_code_list(code_rec.code).lumpsum   := 'Y'; -- for 3907 lumpsum=Y', but code_type = 'INCOME'
                   g_code_list(code_rec.code).code_type := code_rec.code_type;
               else
                   g_code_list(code_rec.code).lumpsum   := 'N';
                   g_code_list(code_rec.code).code_type := code_rec.code_type;
               end if;
               l_prev_code  := code_rec.code;

           end if;

         -- Add code details to g_code_bal and
         -- populate def_bal_list for lmpsm and normal used for batch balance retreival
          if ( code_rec.balance_sequence = 3) then
                 l_def_bal_id := get_def_bal_id(code_rec.balance_type_id, '_ASG_LMPSM_TAX_YTD');
                 g_code_bal(l_count).code               := code_rec.code;
                 g_code_bal(l_count).defined_balance_id := l_def_bal_id;
                 g_code_bal(l_count).full_balance_name  := code_rec.full_balance_name;
                 g_code_bal(l_count).sub_type           := code_rec.code_sub_type;
                 g_code_bal(l_count).balance_type_id    := code_rec.balance_type_id;
                 g_defined_balance_lst_lmpsm(l_lmpsm_count).defined_balance_id  := l_def_bal_id;
                 l_lmpsm_count := l_lmpsm_count + 1;
                 l_count       := l_count + 1;
          else
                 l_def_bal_id := get_def_bal_id(code_rec.balance_type_id, '_ASG_TAX_YTD');
                 g_code_bal(l_count).code               := code_rec.code;
                 g_code_bal(l_count).defined_balance_id := l_def_bal_id;
                 g_code_bal(l_count).full_balance_name  := code_rec.full_balance_name;
                 g_code_bal(l_count).sub_type           := code_rec.code_sub_type;
                 g_code_bal(l_count).balance_type_id    := code_rec.balance_type_id;
		 -- balances for code 4005,seq 2, have already been included with code 3810
                 if not (code_rec.code = '4005' and code_rec.balance_sequence = 2) then
                     g_defined_balance_lst_normal(l_normal_count).defined_balance_id   := l_def_bal_id;
                     l_normal_count := l_normal_count + 1;
                 end if;
		 l_count        := l_count + 1;
          end if;
   end loop;

   hr_utility.set_location('Leaving '|| l_proc,999);
end set_code_tables;


----------------------------------------------------------------------------
--- This function returns the subtype of code
-- (NON_TAXABLE, RFI, NRFI, PKG -- for income sources
--  RFI_LUMPSUM, LUMPSUM        -- for Lumpsum sources
--  DEDUCTION                   -- for deduction sources
--  SITE, PAYE, PAYE_RET_LMPSM)
-----------------------------------------------------------------------------
function sub_type(p_code number, user_name varchar2, p_balance_sequence number) return varchar2 is
begin
    if    p_code in (4115) then
         return  'PAYE_RET_LMPSM';
    elsif p_code in (4102) then
         return  'PAYE';
    elsif p_code in (4101) then
         return  'SITE';
    -- Lumpsums
    elsif substr(user_name,-22,22) = '_RFI_ASG_LMPSM_TAX_YTD' then
         return 'RFI_LUMPSUM';
    elsif p_balance_sequence = 3 then -- this will take 3907 - Other Lump sums
         return 'LUMPSUM';
    -- Deductions
    elsif p_code in (4001,4002,4003,4004,4005,4006,4007,4018,4024,4026,4030,4474,4493) then
         return 'DEDUCTION';
    -- Non Taxable Income
    elsif p_code in  (3602,3604,3609,3612,3703,3714,3705,3709,3716,3908) then
         return 'NON_TAXABLE';
    -- Income sources
    elsif substr(user_name,-16,16) = '_RFI_ASG_TAX_YTD' or substr(user_name,-20,20)='_RFI_NTG_ASG_TAX_YTD' then
         return 'RFI';
    elsif substr(user_name,-17,17) = '_NRFI_ASG_TAX_YTD' or substr(user_name,-21,21)='_NRFI_NTG_ASG_TAX_YTD' then
         return 'NRFI';
    elsif substr(user_name,-16,16) = '_PKG_ASG_TAX_YTD'  OR substr(user_name,-20,20) = '_PKG_NTG_ASG_TAX_YTD' then
         return 'PKG';
    else
         return null;
    end if;
end sub_type;




-------------------------------------------------------------------------
--- Function to fetch employee's basic data
-------------------------------------------------------------------------
procedure fetch_person_data (p_assactid                  in  number
                           , p_effective_date            in  date
                           , p_itreg_batch               in  varchar2
                           , p_tax_status                in  varchar2
                           , p_employee_info_rec         out nocopy act_info_rec
                           , p_employee_contact_info_rec out nocopy act_info_rec
                           , p_assignment_id             out nocopy number
                           , p_person_id                 out nocopy number
                           , p_foreign_income            out nocopy varchar2
                           , pactid                      out nocopy number
                           , p_nature                    out nocopy varchar2
                           , p_independent_contractor    out nocopy varchar2
                           , p_labour_broker             out nocopy varchar2
                           , p_lumpsum_date              out nocopy date) is
cursor csr_asg_info is
    select aei.assignment_id
         , substr(aei.AEI_INFORMATION2,1,120) trade_name
         , hr_general.decode_lookup('ZA_PER_NATURES',aei.AEI_INFORMATION4) nature
         , paa.payroll_action_id
         , aei.aei_information6  independent_contractor
         , aei.aei_information10 labour_broker
         , aei.aei_information15 foreign_income
         , aei.aei_information13 payment_type
         , aei.aei_information14 personal_pay_method_id
    from per_assignment_extra_info aei
       , pay_assignment_actions paa
    where paa.assignment_action_id     =  p_assactid
      and aei.assignment_id            = paa.assignment_id
      and aei.aei_information_category = 'ZA_SPECIFIC_INFO';


cursor csr_person_info(p_assignment_id number, l_effective_date date) is
    select ppf.person_id
         , substr(ltrim(rtrim(ppf.last_name)),1,120) last_name
         , ppf.first_name || ',' || ppf.middle_names first_two_names
         , ppf.national_identifier  id_number
         , ppf.per_information2     passport_number
         , ppf.per_information10  country_of_passport_issue
         , to_char(ppf.date_of_birth,'YYYYMMDD') date_of_birth
         , ppf.per_information1     income_tax_ref_num
         , ppf.employee_number
         , ppf.email_address
         , a.location_id
    from   per_all_people_f ppf
         , per_all_assignments_f a
    where  a.assignment_id = p_assignment_id
      and  ppf.person_id = a.person_id
      and  l_effective_date between a.effective_start_date and a.effective_end_date
     and   l_effective_date between ppf.effective_start_date and ppf.effective_end_date ;

   -- Cursor to fetch Business/Residential address
   cursor csr_sars_address(p_person_id number, l_effective_date date
                         , p_address_style varchar2, p_address_type varchar2) is
    select address_line1
         , address_line2
         , address_line3
         , region_1
         , region_2
         , town_or_city
         , postal_code
      from per_addresses
     where person_id = p_person_id
       and l_effective_date between date_from and nvl(date_to,to_date('31-12-4712','DD-MM-YYYY'))
       and style        = p_address_style
       and address_type = p_address_type;

    cursor csr_sars_loc_address(p_location_id number)
    is
     select lei_information1  ee_unit_num
          , lei_information2  ee_complex
          , lei_information3  ee_street_num
          , lei_information4  ee_street_name
          , lei_information5  ee_suburb_district
          , lei_information6  ee_town_city
          , lei_information7  ee_postal_code
       from hr_location_extra_info
      where location_id      = p_location_id
        and information_type ='ZA_SARS_ADDRESS';

   -- Cursor to fetch Postal address
   cursor csr_postal_address(p_person_id number, l_effective_date date) is
    select decode(region_2,'Y','X',null)                        -- Postal Address same as residential address flag
         , decode(region_2,'Y',null,address_line1)  -- if flag = Y, then don't populate remaining postal address fields
         , decode(region_2,'Y',null,address_line2)
         , decode(region_2,'Y',null,address_line3)
         , decode(region_2,'Y',null,postal_code)
      from per_addresses
     where person_id = p_person_id
       and l_effective_date between date_from and nvl(date_to,to_date('31-12-4712','DD-MM-YYYY'))
       and style        = 'ZA'
       and primary_flag = 'Y';

   --Added for ER 9387986
   cursor csr_asg_bank_ddf (p_assignment_id number, l_effective_date date) is
     select personal_payment_method_id personal_pay_method_id
          , ppm_information1 account_type
       from pay_personal_payment_methods_f
      where assignment_id = p_assignment_id
        and PPM_INFORMATION_CATEGORY in ('ZA_ACB','ZA_CHEQUE','ZA_CREDIT TRANSFER','ZA_MANUAL PAYMENT')
        and ppm_information1 in ('Y','0','7')
        and l_effective_date between effective_start_date and effective_end_date;


   cursor asg_account_details( p_personal_pay_method_id number, l_effective_date date) is
     select pea.segment2                account_type      -- account_type
          , pea.segment3                account_number    -- account number
          , pea.segment1                branch_code       -- bank branch code
          , translate(bnk.bank_name,
                    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz- ,''0123456789~%^&*<>{}[]"\/?@&$!#+=;:().',
                    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz- ,''') bank_name
          , translate(bnk.branch_name,
                    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz- ,''0123456789~%^&*<>{}[]"\/?@&$!#+=;:().',
                    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz- ,''') bank_branch_name
          , substr(pea.segment4,1,50)   ac_holder_name    -- account holder name
          , pea.segment6                ac_holder_relation-- account holder relationship
       from PAY_PERSONAL_PAYMENT_METHODS_F PPM
          , pay_external_accounts pea
          , pay_za_branch_cdv_details bnk
      where PPM.PERSONAL_PAYMENT_METHOD_ID = p_personal_pay_method_id
        and PPM.EXTERNAL_ACCOUNT_ID = PEA.EXTERNAL_ACCOUNT_ID
        and bnk.branch_code = pea.segment1
        and l_effective_date between PPM.effective_start_date and PPM.effective_end_date ;

l_assignment_id         number;
l_person_id             number;
asg_rec                 csr_asg_info%rowtype;
person_rec              csr_person_info%rowtype;
asg_bnk_ddf_rec         csr_asg_bank_ddf%rowtype;
l_surname_or_trade_name varchar2(120);
l_first_two_names       varchar2(90);
l_initials              varchar2(5);
l_effective_date        date;
acc                     asg_account_details%rowtype;
l_run_assact_id         number;
l_proc                  varchar2(100) := g_package||'fetch_person_data';
l_tax_year              varchar2(4);
l_leg_param             varchar2(1000);
l_max_act_seq           number;
l_payroll_id            number;
l_tax_year_start_date   date;
l_tax_year_end_date     date;
l_days_in_tax_year      number;
l_total_tax_periods     number;
l_asg_hire_date         date;
l_asg_term_date         date;

l_late_payment          varchar2(1);
l_date_employed_from    date;
l_date_employed_to      date;
l_total_pay_periods     varchar2(8);
l_pay_periods_worked    varchar2(8);
l_itreg_cert_num        varchar2(30);
begin
   hr_utility.set_location('Entering '||l_proc,10);
   select ppa.legislative_parameters
        , paa.assignment_id
   into   l_leg_param
        , l_assignment_id
   from   pay_payroll_actions    ppa
        , pay_assignment_actions paa
   where  paa.assignment_action_id = p_assactid
     and  ppa.payroll_action_id = paa.payroll_action_id ;

   l_tax_year  := get_parameter('TAX_YEAR',  l_leg_param);

   -- fetch person and assignment details
   open  csr_asg_info;
   fetch csr_asg_info into asg_rec;
   close csr_asg_info;

   l_assignment_id := asg_rec.assignment_id;

   -- get l_effective_date to fetch person/phones/bank etc data
   select least(p_effective_date,max(effective_end_date))
   into   l_effective_date
   from   per_all_assignments_f
   where  assignment_id = l_assignment_id;

   hr_utility.set_location(l_proc,20);

   open  csr_person_info(l_assignment_id,l_effective_date);
   fetch csr_person_info into person_rec;
   close csr_person_info;

   l_person_id := person_rec.person_id;

   -- payroll_id for which payroll process for this assignment
   -- was run in this tax year
   select max(paa.action_sequence)
   into   l_max_act_seq
   from pay_assignment_actions     paa
      , pay_payroll_actions        ppa
      , per_time_periods           ptp
   where paa.assignment_id        = l_assignment_id
     and paa.payroll_action_id    = ppa.payroll_action_id
     and ppa.action_type          in ('R', 'Q', 'V', 'B', 'I')
     and ptp.time_period_id       = ppa.time_period_id
     and ptp.prd_information1     = l_tax_year
     and paa.action_status        = 'C'
     and ppa.action_status        = 'C';

   select ppa.payroll_id, paa.assignment_action_id, ptp.start_date
   into   l_payroll_id, l_run_assact_id, p_lumpsum_date
   from pay_payroll_actions ppa
      , pay_assignment_actions paa
      , per_time_periods ptp
   where paa.assignment_id = l_assignment_id
     and paa.action_sequence = l_max_act_seq
     and ppa.payroll_action_id = paa.payroll_action_id
     and ptp.time_period_id = ppa.time_period_id ;

   hr_utility.trace('Payroll ID :' || l_payroll_id);

   -- Might need to be revisited if we cater to Mid Tax Year later on
   select min(start_date), max(end_date)
   into l_tax_year_start_date, l_tax_year_end_date
   from per_time_periods
   where payroll_id = l_payroll_id
     and prd_information1 = l_tax_year;

   l_days_in_tax_year := l_tax_year_end_date - l_tax_year_start_date + 1 ;

   select count(start_date)
   into l_total_tax_periods
   from per_time_periods
   where    payroll_id   = l_payroll_id
     and prd_information1 = l_tax_year;

   select nvl(min(paaf.effective_start_date), fnd_date.canonical_to_date('1001/01/01 00:00:00'))
        , nvl(max(paaf.effective_end_date), fnd_date.canonical_to_date('4712/12/31 00:00:00'))
   into   l_asg_hire_date
        , l_asg_term_date
   from per_assignment_status_types past,
	    per_all_assignments_f       paaf
   where  paaf.assignment_id             = l_assignment_id
     and    paaf.effective_start_date   <= l_tax_year_end_date
     and    paaf.assignment_status_type_id = past.assignment_status_type_id
  	 and    past.per_system_status in ('ACTIVE_ASSIGN', 'SUSP_ASSIGN');

   hr_utility.trace('Assignment_id : '||l_assignment_id);
   hr_utility.trace('Assignment Hire Date  :' || l_asg_hire_date);
   hr_utility.trace('Assignment Termination Date  :' || l_asg_term_date);

   if l_asg_term_date < l_tax_year_start_date then
      l_late_payment := 'Y';
   else
      l_late_payment := 'N';
   end if;

   if l_tax_year_start_date < l_asg_hire_date then
        l_date_employed_from := l_asg_hire_date;
   else
        if l_late_payment = 'Y' then
            l_date_employed_from := l_asg_term_date;
        else
            l_date_employed_from := l_tax_year_start_date;
        end if;
   end if;

   if l_tax_year_end_date < l_asg_term_date then
       l_date_employed_to := l_tax_year_end_date;
   else
        if l_late_payment = 'Y' then
            l_date_employed_to := l_date_employed_from;
        else
            l_date_employed_to := l_asg_term_date;
        end if;
   end if;

   if p_tax_status = 'G' then
       l_total_pay_periods := trim(to_char(trunc(l_days_in_tax_year,4),'990D9999')) ;
       if l_late_payment = 'Y' then
           l_pay_periods_worked := '1.0000';
       else
           l_pay_periods_worked := trim(to_char(trunc( nvl(get_balance_value('Total Seasonal Workers Days Worked','_ASG_TAX_YTD',l_run_assact_id),0), 4),'990D9999'));
       end if;
   else
       l_total_pay_periods := trim(to_char(trunc(l_total_tax_periods,4),'990D9999')) ;
       if l_late_payment = 'Y' then
           l_pay_periods_worked := '1.0000';
       else
           select trim(to_char(trunc( (l_date_employed_to - l_date_employed_from + 1)/
                                     (( l_tax_year_end_date - l_tax_year_start_date +1)/l_total_tax_periods)
                                     ,4),'990D9999'))
           into l_pay_periods_worked
           from dual;
       end if;
   end if;

   hr_utility.set_location(l_proc,30);

   if asg_rec.nature in ('A','B','C','N') then
       l_surname_or_trade_name := person_rec.last_name;
   else
       l_surname_or_trade_name := asg_rec.trade_name;
   end if;

   if asg_rec.nature in ('D','E','F','G','H') then
       l_first_two_names := null;
       l_initials := null;
   else
       l_first_two_names := substr(names(person_rec.first_two_names),1,90);
       l_initials        := initials(person_rec.first_two_names);
   end if;

   if asg_rec.nature in ('B','D','E','F','G','H') then
      person_rec.id_number  := null;
      person_rec.passport_number := null;
      person_rec.country_of_passport_issue := null;
   end if ;

   if asg_rec.nature = 'B' then
      person_rec.country_of_passport_issue  := 'ZNC';
   end if ;

   if asg_rec.nature in ('D','E','F','G','H') then
       person_rec.date_of_birth := null;
   end if ;

   if asg_rec.nature = 'F' then
       person_rec.income_tax_ref_num := null;
   end if;

   hr_utility.set_location(l_proc,40);

   -- Bank Account Information
   -- At bank detail DDF, account type contains values
   -- Y (Internal Account Payment)
   -- 0 (Cash Payment)
   -- 7 (Foreign Bank Account Payment)

   -- At Assignment Extra Info, Payment Type contains values
   -- 0 (Cash Payment)
   -- 1 (Internal Account Payment)
   -- 7 (Foreign Bank Account Payment)

   -- If it is 1 (Internal Account Payment),
   -- then account details need to be fetched and reported
   -- else Employee Bank Account Type will be set to 0/7 and rest of the details reported as null

   open csr_asg_bank_ddf(l_assignment_id,l_effective_date);
   fetch csr_asg_bank_ddf into asg_bnk_ddf_rec;
   if csr_asg_bank_ddf%found then
       if asg_bnk_ddf_rec.account_type = 'Y' then
           open  asg_account_details(asg_bnk_ddf_rec.personal_pay_method_id, l_effective_date);
           fetch asg_account_details into acc;
           close asg_account_details;
       else
           acc.account_type := asg_bnk_ddf_rec.account_type;
       end if;
   --Bank Detail DDF not set, hence retrieve from Assignment EIT
   elsif asg_rec.payment_type = 1 then
       open  asg_account_details(asg_rec.personal_pay_method_id, l_effective_date);
       fetch asg_account_details into acc;
       close asg_account_details;
   else
       acc.account_type := asg_rec.payment_type;
   end if;
   close csr_asg_bank_ddf;


   -- certificate number for ITREG batch
   if p_itreg_batch = 'Y' then
     if person_rec.id_number is not null then
         l_itreg_cert_num := lpad(person_rec.id_number,30,'0');
     elsif person_rec.passport_number is not null then
         l_itreg_cert_num := lpad(person_rec.passport_number,30,'0');
     end if;
   end if;

   hr_utility.set_location(l_proc,50);

   p_employee_info_rec.assignment_id        := l_assignment_id;
   p_employee_info_rec.person_id            := l_person_id;
   p_employee_info_rec.action_info_category := 'ZATYE_EMPLOYEE_INFO';
   p_employee_info_rec.act_info1            := case when p_itreg_batch='Y' then l_itreg_cert_num else null end;            -- Certificate Number -- will be generated in IRP5/IT3A process
   p_employee_info_rec.act_info2            := null;            -- Certificate Type   -- This will be populated in archive code
   p_employee_info_rec.act_info3            := asg_rec.nature;
   p_employee_info_rec.act_info4            := case when p_itreg_batch='N' then l_tax_year else null end; -- Year of Assessment
   p_employee_info_rec.act_info5            := l_surname_or_trade_name;
   p_employee_info_rec.act_info6            := l_first_two_names;
   p_employee_info_rec.act_info7            := l_initials;
   p_employee_info_rec.act_info8            := person_rec.id_number;
   p_employee_info_rec.act_info9            := person_rec.passport_number;
   p_employee_info_rec.act_info10           := person_rec.country_of_passport_issue;
   p_employee_info_rec.act_info11           := person_rec.date_of_birth;
   p_employee_info_rec.act_info12           := person_rec.income_tax_ref_num;
   p_employee_info_rec.act_info13           := person_rec.employee_number;
   p_employee_info_rec.act_info14           := case when p_itreg_batch='N' then to_char(l_date_employed_from,'YYYYMMDD') else null end; -- Date Employed From
   p_employee_info_rec.act_info15           := case when p_itreg_batch='N' then to_char(l_date_employed_to,'YYYYMMDD') else null end;   -- Date Employed To
   p_employee_info_rec.act_info16           := case when p_itreg_batch='N' then l_total_pay_periods else null end;  -- Pay Periods in Year of Assessment
   p_employee_info_rec.act_info17           := case when p_itreg_batch='N' then l_pay_periods_worked else null end; -- Pay periods worked
   p_employee_info_rec.act_info18           := null;            -- Directive1   -- This will be populated in archive code
   p_employee_info_rec.act_info19           := null;            -- Directive2   -- This will be populated in archive code
   p_employee_info_rec.act_info20           := null;            -- Directive3   -- This will be populated in archive code
   p_employee_info_rec.act_info21           := acc.account_type;
   p_employee_info_rec.act_info22           := acc.account_number;
   p_employee_info_rec.act_info23           := acc.branch_code;
   p_employee_info_rec.act_info24           := acc.bank_name;
   p_employee_info_rec.act_info25           := acc.bank_branch_name;
   p_employee_info_rec.act_info26           := acc.ac_holder_name;
   p_employee_info_rec.act_info27           := acc.ac_holder_relation;
   p_employee_info_rec.act_info28           := null;            -- Old/Manual Certificate
   p_employee_info_rec.act_info29           := null;            -- Manual Certificate Number
   p_employee_info_rec.act_info30           := null;            -- Temporary Certificate Number -- This will be populated in deinit code

   hr_utility.set_location(l_proc,60);

   -- EMPLOYEE_CONTACT_INFORMATION
  p_employee_contact_info_rec.assignment_id := l_assignment_id;
  p_employee_contact_info_rec.person_id := l_person_id;
  p_employee_contact_info_rec.action_info_category := 'ZATYE_EMPLOYEE_CONTACT_INFO';
  p_employee_contact_info_rec.act_info1 := case when p_itreg_batch='Y' then l_itreg_cert_num else null end;            -- Certificate Number -- will be generated in IRP5/IT3A process
  p_employee_contact_info_rec.act_info2 := person_rec.email_address ;

  hr_utility.set_location(l_proc,70);

  -- Populate Phone numbers
  get_phones (l_person_id
            , l_effective_date
            , p_employee_contact_info_rec.act_info3
            , p_employee_contact_info_rec.act_info4
            , p_employee_contact_info_rec.act_info5
            , p_employee_contact_info_rec.act_info6) ;

   hr_utility.set_location(l_proc,80);

  -- Populate Address Information

--  hr_utility.trace_on(null,'ZATRC');
  hr_utility.trace('l_effective_date = '||to_char(l_effective_date));
  -- Business Address
  -- Fetch peron's address with address_style 'South Africa(SARS)' and address_type 'ZA-Business'
  open csr_sars_address(l_person_id, l_effective_date, 'ZA_SARS', 'ZA_BUS');
  fetch csr_sars_address into p_employee_contact_info_rec.act_info7
                       , p_employee_contact_info_rec.act_info8
                       , p_employee_contact_info_rec.act_info9
                       , p_employee_contact_info_rec.act_info10
                       , p_employee_contact_info_rec.act_info11
                       , p_employee_contact_info_rec.act_info12
                       , p_employee_contact_info_rec.act_info13;
  if csr_sars_address%notfound then
     open csr_sars_loc_address(person_rec.location_id);
     fetch csr_sars_loc_address into p_employee_contact_info_rec.act_info7
                           , p_employee_contact_info_rec.act_info8
                           , p_employee_contact_info_rec.act_info9
                           , p_employee_contact_info_rec.act_info10
                           , p_employee_contact_info_rec.act_info11
                           , p_employee_contact_info_rec.act_info12
                           , p_employee_contact_info_rec.act_info13;
     close csr_sars_loc_address;
     end if;
  close csr_sars_address;

  -- Residential Address
  -- Fetch peron's address with address_style 'South Africa(SARS)' and address_type 'ZA-Residential'
  open csr_sars_address(l_person_id, l_effective_date, 'ZA_SARS', 'ZA_RES');
  fetch csr_sars_address into p_employee_contact_info_rec.act_info14
                       , p_employee_contact_info_rec.act_info15
                       , p_employee_contact_info_rec.act_info16
                       , p_employee_contact_info_rec.act_info17
                       , p_employee_contact_info_rec.act_info18
                       , p_employee_contact_info_rec.act_info19
                       , p_employee_contact_info_rec.act_info20;
   close csr_sars_address;
   hr_utility.set_location(l_proc,90);

  -- Postal Address
  -- Fetch peron's Primary address with address_style 'South Africa'
  open csr_postal_address(l_person_id, l_effective_date);
  fetch csr_postal_address into p_employee_contact_info_rec.act_info21
                       , p_employee_contact_info_rec.act_info22
                       , p_employee_contact_info_rec.act_info23
                       , p_employee_contact_info_rec.act_info24
                       , p_employee_contact_info_rec.act_info25;
  close csr_postal_address;

   hr_utility.set_location(l_proc,100);

   p_employee_contact_info_rec.act_info26 := null;        -- Main/Lumpsum certificate -- this will be populated in archive code

   hr_utility.set_location(l_proc,110);

-- Set Output parameters
p_assignment_id          := l_assignment_id;
p_person_id              := l_person_id;
p_foreign_income         := asg_rec.foreign_income;
pactid                   := asg_rec.payroll_action_id;
p_nature                 := asg_rec.nature;
p_independent_contractor := asg_rec.independent_contractor;
p_labour_broker          := asg_rec.labour_broker;

hr_utility.set_location('Leaving '||l_proc,999);
end fetch_person_data;



-----------------------------------------------------------------------------------------
-- Function to populate t_code with values for
-- income/lumpsum/deduction/gross codes for this assignment
-- Input parameter  - 1) Assignment action id of last payroll run
--                    2) t_dir_num (List of directive numbers for this assignment)
-- Output parameter - t_code  (PL/SQL table populated with values for various code for this assignment)
-----------------------------------------------------------------------------------------
procedure fetch_balances ( p_assignment_action_id in number
                         , t_dir_num              in dir_num_table
                         , t_code                 out nocopy code_table
                         ) is
l_def_bal_count          number := 1;
l_code                   varchar2(100);
l_prev_code              varchar2(100);
l_total                  number := 0;
l_dir_num                varchar2(100);
l_def_bal_id             number;
l_gross_rfi              number := 0;
l_gross_nrfi             number := 0;
l_gross_txble_income     number := 0;
l_gross_non_txble_income number := 0;
l_gross_pkg              number := 0;
l_gross_deduction        number := 0;
l_gross_rfi_lmpsm        number := 0;
l_gross_income_lmpsm     number := 0;
l_value                  number := 0;
l_tax                    number := 0;
l_paye                   number := 0;
l_proc                   varchar2(100) := g_package||'fetch_balances';
l_context_lst            pay_balance_pkg.t_context_tab;          -- used for batch balance retrieval
l_output_table           pay_balance_pkg.t_detailed_bal_out_tab; -- output of batch balance retrieval
begin
    hr_utility.set_location('Entering '||l_proc,10);

    ----------------------------------------------------------------------------------------
    -- Fetch Normal income/deduction codes
    ----------------------------------------------------------------------------------------
    -- set context list
    l_context_lst(1).tax_unit_id		:=null;
    l_context_lst(1).jurisdiction_code	:=null;
    l_context_lst(1).source_id		    :=null;
    l_context_lst(1).source_text    	:=null;
    l_context_lst(1).source_number		:=null;
    l_context_lst(1).source_text2		:=null;
    l_context_lst(1).time_def_id		:=null;
    l_context_lst(1).balance_date		:=null;
    l_context_lst(1).local_unit_id	  	:=null;
    l_context_lst(1).source_number2	    :=null;
    l_context_lst(1).organization_id	:=null;

    -- Fetch values for Normal Income codes using batch balance retrieval
    pay_balance_pkg.get_value(p_assignment_action_id => p_assignment_action_id
			                , p_defined_balance_lst  => g_defined_balance_lst_normal
		                    , p_context_lst          => l_context_lst
		                    , p_output_table         => l_output_table
                         );

    hr_utility.set_location(l_proc,20);

    -- Output table l_output_table gives balance values per defined balance id
    -- Loop through output_table to separate out values for each code
    for j in l_output_table.first .. l_output_table.last
    loop
          -- g_code_bal contains code details for each defined_balance_id
          l_def_bal_id := l_output_table(j).defined_balance_id;

          for i in g_code_bal.first .. g_code_bal.last loop
              if g_code_bal(i).defined_balance_id = l_def_bal_id then
                 l_code  := g_code_bal(i).code;
                 l_value := nvl(l_output_table(j).balance_value,0);
                 if l_code not in (4101,4102,4115) then
                    l_value := trunc(l_value);
                 end if;

                 hr_utility.trace('CODE : '||l_code||'   VALUE : '||l_value);

                 -- Populate code and value in t_code table using index "code"
                 if t_code.exists(l_code) then
                    t_code(l_code).value       := t_code(l_code).value + l_value;
                    t_code(l_code).group_value := t_code(l_code).value;
                 else
                    t_code(l_code).value       := l_value;
                    t_code(l_code).group_value := t_code(l_code).value;
                 end if;

                 -- Add amount to gross variables depending upon code subtypes
                 if g_code_bal(i).sub_type in ('RFI') then
                    l_gross_rfi               := l_gross_rfi + l_value;
                 end if;
                 if g_code_bal(i).sub_type in ('PKG') then
                    l_gross_pkg              := l_gross_pkg + l_value;
                 end if;
                 if g_code_bal(i).sub_type in ('RFI','NRFI','PKG') then
                    l_gross_txble_income     := l_gross_txble_income + l_value;
                end if;
                if g_code_bal(i).sub_type in ('NON_TAXABLE') then
                    l_gross_non_txble_income := l_gross_non_txble_income + l_value;
                end if;
                if g_code_bal(i).sub_type in ('DEDUCTION') then
                    l_gross_deduction        := l_gross_deduction + l_value;
                end if;
                if g_code_bal(i).full_balance_name = 'PAYE' then
                    l_paye                   := l_value;
                end if ;
            end if;
         end loop;
    end loop;

      -- set value for gross deduction
      t_code(4497).value         :=   l_gross_deduction;
      t_code(4497).group_value   :=   l_gross_deduction;

      hr_utility.set_location(l_proc,30);

    ----------------------------------------------------------------------------------------
    --- Fetch Lumpsum codes for all directive numbers (including 'To Be Advised')
    ----------------------------------------------------------------------------------------
   hr_utility.trace('Going for lumpsums .. ');
   l_dir_num := t_dir_num.first;

   if l_dir_num is not null then
   loop
       hr_utility.trace('Directive Number : '||l_dir_num);

       -- reset pl/sql tables, total and count variables
       l_gross_rfi_lmpsm    := 0;
       l_gross_income_lmpsm := 0;
       l_context_lst.delete;
       l_output_table.delete;

        -- set context list
        l_context_lst(1).tax_unit_id		    :=null;
        l_context_lst(1).jurisdiction_code	    :=null;
        l_context_lst(1).source_id		        :=null;
        l_context_lst(1).source_text    		:=l_dir_num;  -- directive number
        l_context_lst(1).source_number		    :=null;
        l_context_lst(1).source_text2		    :=null;
        l_context_lst(1).time_def_id		    :=null;
        l_context_lst(1).balance_date		    :=null;
        l_context_lst(1).local_unit_id	     	:=null;
        l_context_lst(1).source_number2	        :=null;
        l_context_lst(1).organization_id    	:=null;

        -- Fetch values for Lumpsum codes using batch balance retrieval
        pay_balance_pkg.get_value(p_assignment_action_id => p_assignment_action_id
  			                     ,p_defined_balance_lst  => g_defined_balance_lst_lmpsm
   		                         ,p_context_lst          => l_context_lst
     		                     ,p_output_table         => l_output_table
                             );

       hr_utility.set_location(l_proc,40);

      -- Output table l_output_table gives balance values per defined balance id
      -- Loop through output_table to separate out values for each code
      for j in l_output_table.first .. l_output_table.last
      loop
           -- g_code_bal contains code details for each defined_balance_id
           l_def_bal_id := l_output_table(j).defined_balance_id;

          for i in g_code_bal.first .. g_code_bal.last loop
              if g_code_bal(i).defined_balance_id = l_def_bal_id then
                  l_code  := g_code_bal(i).code;
                  l_value := nvl(l_output_table(j).balance_value,0);
                  if l_code not in (4101,4102,4115) then
                     l_value := trunc(l_value);
                  end if;
                  hr_utility.trace('CODE : '||l_code||'   VALUE : '||l_value);

                  -- Populate code and value in t_code table using index "code-dirnum"
                  if t_code.exists(l_code||'-'||l_dir_num) then
                      t_code(l_code||'-'||l_dir_num).value       := t_code(l_code||'-'||l_dir_num).value + l_value;
                      t_code(l_code||'-'||l_dir_num).group_value := t_code(l_code||'-'||l_dir_num).value;
                  else
                      t_code(l_code||'-'||l_dir_num).value       := l_value;
                      t_code(l_code||'-'||l_dir_num).group_value := t_code(l_code||'-'||l_dir_num).value;
                  end if;

                  -- Add amount to gross variables depending upon code subtypes
                  if g_code_bal(i).sub_type in ('RFI_LUMPSUM') then
                      l_gross_rfi_lmpsm       := l_gross_rfi_lmpsm + l_value;
                  end if;

                  if g_code_bal(i).sub_type in ('RFI_LUMPSUM','LUMPSUM') then
                      l_gross_income_lmpsm    := l_gross_income_lmpsm + l_value;
                  end if;
              end if;
          end loop;
      end loop;

      hr_utility.set_location(l_proc,50);

      t_code(3697||'-'||l_dir_num).value       := l_gross_rfi_lmpsm ;
      t_code(3697||'-'||l_dir_num).group_value := l_gross_rfi_lmpsm ;
      t_code(3698||'-'||l_dir_num).value       := l_gross_income_lmpsm - l_gross_rfi_lmpsm;
      t_code(3698||'-'||l_dir_num).group_value := l_gross_income_lmpsm - l_gross_rfi_lmpsm;

       -- Go for next directive number
       l_dir_num := t_dir_num.next(l_dir_num);
       exit when l_dir_num is null;
   end loop;
   end if;

   hr_utility.set_location(l_proc,60);

   --  add 'Taxable Package Components RFI' and  'Annual Taxable Package Components RFI' to gross_rfi
   l_gross_rfi := l_gross_rfi
                + nvl(get_balance_value ('Taxable Package Components RFI','_ASG_TAX_YTD',p_assignment_action_id),0)
                + nvl(get_balance_value ('Annual Taxable Package Components RFI','_ASG_TAX_YTD',p_assignment_action_id),0);
   l_tax       := nvl(get_balance_value ('Tax','_ASG_TAX_YTD',p_assignment_action_id),0);
   t_code(3696).value       := l_gross_non_txble_income;
   t_code(3696).group_value := l_gross_non_txble_income;
   t_code(3697).value       := l_gross_rfi;
   t_code(3697).group_value := l_gross_rfi;
   t_code(3698).value       := l_gross_txble_income - l_gross_rfi;
   t_code(3698).group_value := l_gross_txble_income - l_gross_rfi;
   t_code(9997).value       := l_tax;       -- Archive Tax_ASG_TAX_YTD - for in exception log calcualtions
   t_code(9997).group_value := l_tax;
   t_code(9998).value       := l_paye;      -- Archive PAYE_ASG_TAX_YTD- for in exception log calcualtions
   t_code(9998).group_value := l_paye;
   t_code(9999).value       := l_gross_pkg; -- Archive Gross PKG       - for in exception log calcualtions
   t_code(9999).group_value := l_gross_pkg;

   -- UIF Conributions
   hr_utility.set_location(l_proc,70);
   t_code(4141).value       := nvl(get_balance_value ('UIF Employee Contribution', '_ASG_TAX_YTD', p_assignment_action_id),0)
                             + nvl(get_balance_value ('UIF Employer Contribution', '_ASG_TAX_YTD', p_assignment_action_id),0);
   t_code(4141).group_value := t_code(4141).value;

   -- SDL Conributions
   t_code(4142).value       := nvl(get_balance_value ('Skills Levy', '_ASG_TAX_YTD', p_assignment_action_id),0);
   t_code(4142).group_value := t_code(4142).value;

   hr_utility.set_location('Leaving '||l_proc,999);

end fetch_balances;


---------------------------------------------------------------------------
-- This function is used to identify certificate types (IRP5/ IT3A/ ITREG)
-- Output -
-- 1) p_main_cert_type (type of main certificate)
-- 2) t_dir_num : populates the field 'certificate_type' for each directive number
---------------------------------------------------------------------------
procedure populate_irp5_indicators
(
   p_run_assact_id        in     number
 , t_code                 in     code_table
 , p_main_cert_type       out    nocopy varchar2
 , t_dir_num              in out nocopy dir_num_table
) is

l_dir_num            varchar2(100);
l_site               number(15, 3);
l_paye_plus_vol_tax  number(15, 3);
l_total_tax          number(15);
l_lmpsm_sum          number(15);
l_total_income       number(15) := 0;
l_all_lumpsum_income number(15) := 0;
l_lumpsum_income     number(15) := 0;
l_main_cert_income   number(15) := 0;
l_deductions         number(15) := 0;
l_proc varchar2(100) := g_package||'populate_irp5_indicators';
l_4115_ToBeAdvised   number(15) := 0;
begin
   hr_utility.set_location('Entering '||l_proc,10);
   -----------------------------------------
   -- Checking type of Lumpsum Certificates
   -----------------------------------------
   l_dir_num := t_dir_num.first;
   if l_dir_num is not null then
   loop
      hr_utility.set_location('Directive Num '||l_dir_num,20);
      if l_dir_num <> 'To Be Advised' then
          l_total_tax      :=  t_code('4102-'||l_dir_num).group_value
                             + t_code('4115-'||l_dir_num).group_value;
          l_lumpsum_income :=  t_code('3697-'||l_dir_num).group_value
                             + t_code('3698-'||l_dir_num).group_value;

          --hr_utility.set_location('Total Tax  '||l_total_tax,20);
          --hr_utility.set_location('l_lumpsum_income  '||l_lumpsum_income,20);

          if l_lumpsum_income<=0 then
               -- If the assignment had zero for all his balances then don't include him
               t_dir_num(l_dir_num).certificate_type := 'A';
          else   -- Check for IRP5/IT3A
               if l_total_tax > 0 then
                   t_dir_num(l_dir_num).certificate_type := 'IRP5';
               else
                   t_dir_num(l_dir_num).certificate_type := 'IT3A';
               end if;
          end if;

          l_all_lumpsum_income := l_all_lumpsum_income + l_lumpsum_income;
      end if;
      hr_utility.set_location('Cert type for '||l_dir_num||' is ' || t_dir_num(l_dir_num).certificate_type,10);
      l_dir_num := t_dir_num.next(l_dir_num);
      exit when l_dir_num is null;
   end loop;
   end if;

   -------------------------------------
   -- Checking type of main certificate
   -------------------------------------
   hr_utility.set_location(l_proc,30);
   l_site              := t_code('4101').group_value;
   if t_code.exists('4102-To Be Advised') then
      l_paye_plus_vol_tax := t_code('4102').group_value + t_code('4102-To Be Advised').group_value;
      l_4115_ToBeAdvised  := t_code('4115-To Be Advised').group_value;
   else
      l_paye_plus_vol_tax := t_code('4102').group_value;
   end if;

   -- Total Tax paid on main certificate
   l_total_tax := l_paye_plus_vol_tax + l_site + l_4115_ToBeAdvised;

   -- Total Main certificate income
   if t_code.exists('3697-To Be Advised') then
       l_main_cert_income  := t_code(3696).group_value
                            + t_code(3697).group_value
                            + t_code(3698).group_value
                            + t_code(3697||'-To Be Advised').group_value
                            + t_code(3698||'-To Be Advised').group_value;
   else
       l_main_cert_income  := t_code(3696).group_value
                            + t_code(3697).group_value
                            + t_code(3698).group_value;
   end if;

   -- Total Main certificate deductions
   l_deductions  :=  t_code(4497).group_value;

   --hr_utility.set_location('l_site  '||l_site,20);
   --hr_utility.set_location('l_total_tax  '||l_total_tax,20);
   --hr_utility.set_location('l_main_cert_income  '||l_main_cert_income,20);
   --hr_utility.set_location('l_deductions  '||l_deductions,20);

   hr_utility.set_location(l_proc,40);
   if l_main_cert_income<=0 and l_deductions<=0 then
      -- If the assignment had zero for all his balances
      -- then don't include him
      p_main_cert_type := 'A';
   else   -- Check for IRP5/IT3A
      if l_total_tax > 0 then
         p_main_cert_type := 'IRP5';
      else
         p_main_cert_type := 'IT3A';
      end if;
   end if;
   hr_utility.set_location('Cert type for Main Certificate is ' || p_main_cert_type,50);
   hr_utility.set_location('Leaving '||l_proc,999);
end populate_irp5_indicators;


-----------------------------------------------------------------------------------------
-- Procudure to identify which lumpsum certificates can be merged with main certificate
-- Inputs -
--    1) p_main_cert_type    (Main certificate type
--    2) p_main cert_dir_num ( Main certificate directive Number - given in ZA_TAX element)
-- Outputs -
--    1) p_directive_1       (Directive Number of first  merged lumpsum certificate)
--    2) p_directive_2       (Directive Number of second merged lumpsum certificate)
--    3) p_directive_3       (Directive Number of third  merged lumpsum certificate)
-- In/Out  -
--    1) t_dir_num           (Directive Number table
--                            for directive numbers which are merged with main certificate
--                            set attribute certificate_merged_with_main = 'Y'
--
-- Note - If there is a main certificate number given in ZA_TAX element
--        Then this will be the first merged directive number
--             and we can have only 2 further lumpsum certificates merged
-----------------------------------------------------------------------------------------
procedure combine_certificates(p_main_cert_type    in     varchar2
                             , p_main_cert_dir_num in     varchar2
                             , t_dir_num           in out nocopy dir_num_table
                             , p_directive_1       out    nocopy varchar2
                             , p_directive_2       out    nocopy varchar2
                             , p_directive_3       out    nocopy varchar2) is
l_combined_cert_count number := 0;
l_dir_num   varchar2(100);
l_proc      varchar2(100) := g_package || 'combine_certificates';
begin
     hr_utility.set_location('Entering '|| l_proc,10);

     if t_dir_num.exists('To Be Advised') then
         t_dir_num('To Be Advised').certificate_merged_with_main := 'Y';
     end if;

     if p_main_cert_dir_num is not null then
        l_combined_cert_count:= 1;
        p_directive_1 := p_main_cert_dir_num;
     end if;

    -- Lumpsum certificates will get merged in main certificate
    -- in order of their directive number names
    -- as we are looping through t_dir_num from first to last
    l_dir_num := t_dir_num.first;
    if l_dir_num is not null then
    loop
        if l_dir_num <> 'To Be Advised' then
        if t_dir_num(l_dir_num).certificate_type = p_main_cert_type then
            l_combined_cert_count := l_combined_cert_count + 1;
            t_dir_num(l_dir_num).certificate_merged_with_main := 'Y';

           if l_combined_cert_count = 1 then
               p_directive_1 := l_dir_num;
           elsif l_combined_cert_count = 2 then
               p_directive_2 := l_dir_num;
           elsif l_combined_cert_count = 3 then
               p_directive_3 := l_dir_num;
           end if;

           exit when  l_combined_cert_count = 3;
        end if;
        end if;

        l_dir_num := t_dir_num.next(l_dir_num);
        exit when l_dir_num is null;
    end loop;
    end if;

    hr_utility.set_location('Directive Number 1 : '|| p_directive_1,20);
    hr_utility.set_location('Directive Number 2 : '|| p_directive_2,20);
    hr_utility.set_location('Directive Number 3 : '|| p_directive_3,20);
    hr_utility.set_location('Leaving '|| l_proc,999);
end combine_certificates;




-----------------------------------------------------------------------------------------
-- Procudure to merge code values of -
--  1) Codes whose values have been directed by SARS to be merged with other codes
--     a) Codes 3603, 3607, 3610 to be merged into 3601.
--     b) Codes 3604, 3609, 3612 to be merged into 3602.
--     c) Codes 3706, 3710, 3711, 3712 to be merged into 3713.
--     d) Codes 3705, 3709, 3716 to be merged into 3714.
--     e) Codes 3803, 3804, 3805, 3806, 3807, 3808, 3809 to be merged into 3801.
--     f) Codes 4004 to be merged into 4003.
--  2) All codes of lumpsum certificates which have been identified to be merged
--     with main certificate
--  3) For codes 3907, 3697, and 3698
--     both t_code(code) ad well as t_code(code-To Be Advised) might exist
--     If so, then  merge t_code(code-To Be Advised) into t_code(code)
--     to avoid them from being reported twice
--
-- Inputs  - t_dir_num  (Directive Number table)
-- In/Out  - t_code     (Code Values table for that assignment)
--
-- Note - When a code B is merged with code A -
--        1) t_code(B).group_value is added to t_code(A).group_value
--        2) t_code(B).included_in = A
--
-----------------------------------------------------------------------------------------
procedure consolidate_codes(t_dir_num in out nocopy dir_num_table
                          , t_code    in out nocopy code_table) as

l_dir_num varchar2(100);
l_proc    varchar2(100) := g_package||'consolidate_codes';
l_code    varchar2(4);
l_code_complete varchar2(100);
l_code_temp     varchar2(4);

   -- procedure to merge code_B into code_A
   procedure merge (code_B varchar2, code_A varchar2) is
   begin
     if t_code.exists(code_A) then
         t_code(code_A).group_value := t_code(code_A).group_value + t_code(code_B).group_value;
     else
         if substr(code_A,6) = 'To Be Advised' then
              -- Create new directive number 'To Be Advised'

              t_dir_num('To Be Advised').certificate_type  :=  null;
              t_dir_num('To Be Advised').certificate_merged_with_main :=  'Y';
              l_code_temp := g_code_list.first;
              loop
                  if g_code_list(l_code_temp).lumpsum = 'Y' then
                     t_code(l_code_temp||'-To Be Advised').value       := 0;
                     t_code(l_code_temp||'-To Be Advised').group_value := 0;
                  end if;
                  l_code_temp := g_code_list.next(l_code_temp);
                  exit when l_code_temp is null;
              end loop;
              t_code('3697-To Be Advised').value := 0;
              t_code('3697-To Be Advised').group_value := 0;

              t_code('3698-To Be Advised').value := 0;
              t_code('3698-To Be Advised').group_value := 0;

              -- Add code_B value to code_A
              t_code(code_A).value       := 0;
              t_code(code_A).group_value := t_code(code_B).group_value;

         end if;
     end if;
     t_code(code_B).included_in := code_A;
   end merge;

begin
    hr_utility.set_location('Entering '||l_proc,10);

    ------------------------------------------------------------------------------
    -- 1) Codes whose values have been directed by SARS to be merged with other codes
    ------------------------------------------------------------------------------

    merge(3603,3601);
    merge(3607,3601);
    merge(3610,3601);
    merge(3604,3602);
    merge(3609,3602);
    merge(3612,3602);
    merge(3706,3713);
    merge(3710,3713);
    merge(3711,3713);
    merge(3712,3713);
    merge(3705,3714);
    merge(3709,3714);
    merge(3716,3714);
    merge(3803,3801);
    merge(3804,3801);
    merge(3805,3801);
    merge(3806,3801);
    merge(3807,3801);
    merge(3808,3801);
    merge(3809,3801);
    merge(4004,4003);

    hr_utility.set_location(l_proc,20);

   ---------------------------------------------------------------------------------------
   -- 2) Codes of lumpsum certificates which have been identified to be merged with main cert
   ---------------------------------------------------------------------------------------

   -- Loop through all directive numbers
   l_dir_num := t_dir_num.first;
   if l_dir_num is not null then
   loop
      -- if directive number has been identified to be merged with main certificate
      if t_dir_num(l_dir_num).certificate_merged_with_main = 'Y' and l_dir_num <> 'To Be Advised' then
          -- loop through all codes for this assignment
          l_code := g_code_list.first;
          loop
             -- if the code is a lumpsum code
             if g_code_list(l_code).lumpsum = 'Y' then
                  -- merge t_code(code-dirnum) into t_code(code-To Be Advised)
                  merge(l_code||'-'||l_dir_num , l_code||'-To Be Advised');
             end if;
             l_code := g_code_list.next(l_code);
             exit when l_code is null;
          end loop;
          -- merge 3697/3698-dirnum into 3697/3698-To Be Advised
          merge(3697||'-'||l_dir_num , 3697||'-To Be Advised');
          merge(3698||'-'||l_dir_num , 3698||'-To Be Advised');
      end if;

      l_dir_num := t_dir_num.next(l_dir_num);
      exit when l_dir_num is null;

   end loop;
   end if;

   hr_utility.set_location(l_proc,30);

   ---------------------------------------------------------------------------------------
   -- 3) For codes 3907, 3697, and 3698
   --    Merge t_code(code-To Be Advised) into t_code(code)
   ---------------------------------------------------------------------------------------
   if t_code.exists('3907-To Be Advised') then
     merge('3907-To Be Advised',3907);
     merge('3697-To Be Advised',3697);
     merge('3698-To Be Advised',3698);
   end if;
   hr_utility.set_location('Leaving '||l_proc,999);
end consolidate_codes;




-------------------------------------------
---Function to provide IT3A Reason code
-------------------------------------------
function it3a_reason_code( p_run_assact_id number
                         , p_nature varchar2
                         , p_tax_status varchar2
                         , p_normal_directive_value varchar2
                         , p_gross_total number
                         , p_gross_non_txble_income number
                         , p_lmpsm_cert varchar2
                         , p_tax_on_lmpsm number
                         , p_independent_contractor varchar2
                         , p_foreign_income varchar2
                         , p_labour_broker varchar2) return varchar2 is
l_tax_threshold_ind      number ;
l_reason_code            varchar2(2) := '&&';
l_normal_directive_value number;
l_proc                   varchar2(100) := g_package || 'it3a_reason_code';
begin
    hr_utility.set_location('Entering '||l_proc,10);
	begin
      l_tax_threshold_ind := nvl(get_balance_value('Tax Threshold Ind','_ASG_TAX_YTD',p_run_assact_id),0);
    exception when others then
      l_tax_threshold_ind := 0;
    end ;

    begin
      l_normal_directive_value := to_number(p_normal_directive_value);
    exception when others then
      l_normal_directive_value := 0;
    end ;

    if p_gross_total = 0 and p_gross_non_txble_income >0 then
        l_reason_code := '04';
    end if;

   if p_tax_status = 'H' then
      l_reason_code := '04';
   end if;

   if (p_tax_status = 'C' or p_tax_status = 'D') and l_normal_directive_value = 0 then
      l_reason_code := '04';
   end if;

   if l_reason_code = '&&' and l_tax_threshold_ind > 0 then
      l_reason_code := '02';
   end if;

   if p_independent_contractor = 'Y' then
      l_reason_code := '03';
   end if;

   if p_foreign_income = 'Y' then
      l_reason_code := '05';
   end if;

   if p_tax_status = 'Q' then
      l_reason_code := '06';
   end if;

   if l_reason_code = '06' and l_tax_threshold_ind > 0 then
      l_reason_code := '02';
   end if;

   if l_reason_code = '&&' then
      l_reason_code := '02';
   end if;

   if p_labour_broker = 'Y' then
      l_reason_code := '07';
   end if;

   if p_lmpsm_cert = 'Y' then
      if p_tax_on_lmpsm <= 0 then
          l_reason_code := '04';
      end if;
   end if;

   hr_utility.set_location('IT3A Reason Code : '||l_reason_code,20);

   hr_utility.set_location('Leaving '||l_proc,999);
   return l_reason_code;
end it3a_reason_code;




-----------------------------------------------------
-- function to return final code to be archived
-----------------------------------------------------
function final_code (p_code_complete   in    varchar2
                   , p_nature          in    varchar2
                   , p_tax_status      in    varchar2
                   , p_foreign_income  in    varchar2
                    ) return varchar2 is
l_code varchar2(4);
begin
   l_code := to_number(substr(p_code_complete,1,4));

   -- For Director of private company/ Member of close corporation
   -- the income under 3601 needs to be reported under 3615
   if (p_nature = 'C'  and l_code = '3601') then
      l_code := '3615';
   end if;

      -- Check for foreign income code
      if (p_foreign_income = 'Y' and to_number(l_code) >= 3601 and to_number(l_code) <= 3907
                                 and to_number(l_code) not in (3614,3908,3909,3915,3920,3921
                                                                    ,3696, 3697, 3698))
      then
          l_code := to_char(l_code + 50);
      end if;

     return l_code;
end final_code;




------------------------------------------------------------------------------
-- Procedure to fetch and return Home Phone, Work Phone, Fax and Cell Number
-- of the person
------------------------------------------------------------------------------
procedure get_phones (p_person_id number
                    , p_effective_date date
                    , p_home_phone out nocopy varchar2
                    , p_work_phone out nocopy varchar2
                    , p_fax out nocopy varchar2
                    , p_cell_number out nocopy varchar2 ) is
  cursor csr_phones (p_phone_type varchar2) is
    select translate(upper(phone_number),
                    '0123456789+-. ',
                    '0123456789')   -- remove any character other than digits
      from per_phones
      where parent_table = 'PER_ALL_PEOPLE_F'
       and parent_id  = p_person_id
       and phone_type = p_phone_type
       and p_effective_date between date_from and nvl(date_to,to_date('31-12-4712','DD-MM-YYYY')) ;
  l_temp number;
begin
  -- Home Phone
  open csr_phones('H1');
  fetch csr_phones into p_home_phone;
  close csr_phones;

  if p_home_phone is null then
     open csr_phones('H2');
     fetch csr_phones into p_home_phone;
     close csr_phones;

     if p_home_phone is null then
        open csr_phones('H3');
        fetch csr_phones into p_home_phone;
        close csr_phones;
     end if;
  end if ;

  --
  -- Business Phone
  --
  open csr_phones('W1');
  fetch csr_phones into p_work_phone;
  close csr_phones;

  if p_work_phone is null then
     open csr_phones('W2');
     fetch csr_phones into p_work_phone;
     close csr_phones;

     if p_work_phone is null then
        open csr_phones('W3');
        fetch csr_phones into p_work_phone;
        close csr_phones;
     end if;
  end if ;

  --
  -- Fax
  --
  open csr_phones('WF');
  fetch csr_phones into p_fax;
  close csr_phones;

  if p_fax is null then
     open csr_phones('HF');
     fetch csr_phones into p_fax;
     close csr_phones;
  end if;

  --
  -- Mobile
  --
  open csr_phones('M');
  fetch csr_phones into p_cell_number;
  close csr_phones;

end get_phones;





-------------------------------------------------------------------------
-- Procedure to create a copy of an archive record
-------------------------------------------------------------------------

procedure copy_record(from_rec in act_info_rec
                     ,to_rec   in out nocopy act_info_rec) is
begin
   to_rec.assignment_id        := from_rec.assignment_id       ;
   to_rec.person_id            := from_rec.person_id           ;
   to_rec.action_info_category := from_rec.action_info_category;
   to_rec.act_info1            := from_rec.act_info1           ;
   to_rec.act_info2            := from_rec.act_info2           ;
   to_rec.act_info3            := from_rec.act_info3           ;
   to_rec.act_info4            := from_rec.act_info4           ;
   to_rec.act_info5            := from_rec.act_info5           ;
   to_rec.act_info6            := from_rec.act_info6           ;
   to_rec.act_info7            := from_rec.act_info7           ;
   to_rec.act_info8            := from_rec.act_info8           ;
   to_rec.act_info9            := from_rec.act_info9           ;
   to_rec.act_info10           := from_rec.act_info10          ;
   to_rec.act_info11           := from_rec.act_info11          ;
   to_rec.act_info12           := from_rec.act_info12          ;
   to_rec.act_info13           := from_rec.act_info13          ;
   to_rec.act_info14           := from_rec.act_info14          ;
   to_rec.act_info15           := from_rec.act_info15          ;
   to_rec.act_info16           := from_rec.act_info16          ;
   to_rec.act_info17           := from_rec.act_info17          ;
   to_rec.act_info18           := from_rec.act_info18          ;
   to_rec.act_info19           := from_rec.act_info19          ;
   to_rec.act_info20           := from_rec.act_info20          ;
   to_rec.act_info21           := from_rec.act_info21          ;
   to_rec.act_info22           := from_rec.act_info22          ;
   to_rec.act_info23           := from_rec.act_info23          ;
   to_rec.act_info24           := from_rec.act_info24          ;
   to_rec.act_info25           := from_rec.act_info25          ;
   to_rec.act_info26           := from_rec.act_info26          ;
   to_rec.act_info27           := from_rec.act_info27          ;
   to_rec.act_info28           := from_rec.act_info28          ;
   to_rec.act_info29           := from_rec.act_info29          ;
   to_rec.act_info30           := from_rec.act_info30          ;
end  copy_record;





-------------------------------------------------------------------------
--- This function returns defined_balance_id for a balance and dimenesion
-------------------------------------------------------------------------
function get_def_bal_id (p_bal_type_id   number,
                         p_dim_name      varchar2) return number is
  cursor c_get_def_bal_id is
    select pdb.defined_balance_id
    from   pay_balance_dimensions  pbd
        ,  pay_defined_balances    pdb
    where  pbd.dimension_name   =  p_dim_name
      and  pbd.legislation_code =  'ZA'
      and  pdb.balance_type_id  =  p_bal_type_id
      and  pdb.balance_dimension_id     =  pbd.balance_dimension_id;

   l_def_bal_id number;
begin
   open c_get_def_bal_id;
   fetch c_get_def_bal_id into l_def_bal_id ;
   close c_get_def_bal_id ;

   return l_def_bal_id;
end get_def_bal_id;




-----------------------------------------------------------------
-- Function to get balance Value
------------------------------------------------------------------
function get_balance_value (p_bal_name varchar2,
                            p_dim_name varchar2,
			                      p_asg_act_id number)
                            return number is
 cursor csr_bal_id (p_bal_name varchar2)is
   select balance_type_id
   from   pay_balance_types
   where  balance_name = p_bal_name
     and legislation_code = 'ZA';

 cursor c_get_bal_value( p_def_bal_id in number) is
 select pay_balance_pkg.get_value(p_def_bal_id, --p_def_bal_id
  p_asg_act_id, --assignment_action_id
  null,
  null,
  null,
  null,
  null,
  null,
  null,
  'TRUE')
 from dual;

l_def_bal_id number;
l_bal_val number;
l_bal_id  number;
begin
    open csr_bal_id(p_bal_name);
    fetch csr_bal_id into l_bal_id;
    close csr_bal_id;

    l_def_bal_id := get_def_bal_id (l_bal_id, p_dim_name );

    open c_get_bal_value(l_def_bal_id);
    fetch c_get_bal_value into l_bal_val;
    close c_get_bal_value;

return fnd_number.canonical_to_number(l_bal_val);
end get_balance_value;




/*--------------------------------------------------------------------------
  Name      : get_parameter
  Purpose   : Returns a legislative parameter
  Arguments :
  Notes     : The legislative parameter field must be of the form:
              PARAMETER_NAME=PARAMETER_VALUE. No spaces is allowed in either
              the PARAMETER_NAME or the PARAMETER_VALUE.
--------------------------------------------------------------------------*/
function get_parameter
(
   name        in varchar2,
   parameter_list varchar2
)  return varchar2 is

start_ptr number;
end_ptr   number;
token_val pay_payroll_actions.legislative_parameters%type;
par_value pay_payroll_actions.legislative_parameters%type;

begin

   token_val := name || '=';

   start_ptr := instr(parameter_list, token_val) + length(token_val);
   end_ptr   := instr(parameter_list, ' ', start_ptr);

   /* if there is no spaces, then use the length of the string */
   if end_ptr = 0 then
     end_ptr := length(parameter_list) + 1;
   end if;

   /* Did we find the token */
   if instr(parameter_list, token_val) = 0 then
     par_value := NULL;
   else
     par_value := substr(parameter_list, start_ptr, end_ptr - start_ptr);
   end if;

   return par_value;

end get_parameter;




----------------------------------------------------------------------------
--- Function to return first two names
----------------------------------------------------------------------------
function names(name varchar2) return varchar2 is

l_pos    number;
l_pos2   number;
l_name   varchar2(255);
l_answer varchar2(255);

begin

   -- Remove any unnecessary spaces
   l_name := ltrim(rtrim(name));

   -- Get the first name
   l_pos := instr(l_name, ',', 1, 1);
   l_answer := rtrim(substr(l_name, 1, l_pos - 1));

   -- Append the second name
   l_pos2 := instr(l_name, ',', l_pos + 1, 1);
   if l_pos2 = 0 then

      -- Concatenate the rest of the string
      l_answer := l_answer || ' ' || ltrim(rtrim( substr(l_name, l_pos + 1) ));

   else

      -- Concatenate the name up to the comma
      l_answer := l_answer || ' ' || ltrim(rtrim( substr(l_name, l_pos + 1, l_pos2 - l_pos - 1) ));

   end if;

   l_answer := ltrim(rtrim(l_answer));

   return l_answer;

end names;




--------------------------------------------------------------------------------------------
-- This function is used to return the initials of the employee
-- Note: initials('Francois, Daniel, van der Merwe') would return 'FDV'
-- Note: A maximum of five characters is returned
--------------------------------------------------------------------------------------------
function initials(name varchar2) return varchar2 is

   l_initials varchar2(255);
   l_pos      number;
   l_name     varchar2(255);
   l_trc_initial varchar2(4);

begin

   -- Get the first initial
   l_name := rtrim(ltrim(name));
   -- replace all apostrophe with null
   l_name := translate(l_name,'@''','@');
   -- remove all numeric digits for ER 9369854
   l_name := trim(translate(l_name,' 0123456789',' '));
   -- replace all hyphen and spaces with comma
   l_name := translate(l_name,'- ',',,');

   if length(l_name) > 0 then
      l_name := ','||l_name;
    --  l_initials := substr(l_name, 1, 1);

   end if;

   -- Check for a comma
   if l_initials = ',' then

      l_initials := '';

   end if;

   l_pos := instr(l_name, ',', 1, 1);
   while l_pos <> 0 loop

      -- Move the Position indicator to the character after the comma
      l_pos := l_pos + 1;

      -- Move forward until you find something that is not a space
      while substr(l_name, l_pos, 1) = ',' loop

         l_pos := l_pos + 1;

      end loop;

      -- Append the initial
      l_trc_initial := substr(l_name, l_pos, 1);

      --Initial must contain only a to z OR A to Z
      while (l_trc_initial not between 'a' and 'z') and (l_trc_initial not between 'A' and 'Z')
      loop
           l_pos := l_pos + 1;
           l_trc_initial := substr(l_name, l_pos, 1);
      end loop;

      l_initials := l_initials || l_trc_initial;
      -- Find the next initial
      l_pos := instr(l_name, ',', l_pos, 1);

   end loop;

   -- Format the result and limit it to 5 characters
   l_initials := substr(l_initials, 1, 5);

   return l_initials;

end initials;




----------------------------------------------------------------------
-- Procedure to call archive API to to archive the data
-- present in the PL/SQL table
----------------------------------------------------------------------
procedure insert_archive_row(p_assactid       in number,
                             p_tab_rec_data   in action_info_table) is
     l_proc  constant varchar2(50):= g_package||'insert_archive_row';
     l_ovn       number;
     l_action_id number;
begin
     hr_utility.set_location('Entering: '||l_proc,1);
     if p_tab_rec_data.count > 0 then
        for i in p_tab_rec_data.first .. p_tab_rec_data.last loop

            hr_utility.trace('Defining category '|| p_tab_rec_data(i).action_info_category);
            hr_utility.trace('action_context_id = '|| p_assactid);
            hr_utility.trace('p_tab_rec_data(i).action_info_category = '|| p_tab_rec_data(i).action_info_category);
            if p_tab_rec_data(i).action_info_category is not null then
               pay_action_information_api.create_action_information(
                p_action_information_id => l_action_id,
                p_object_version_number => l_ovn,
                p_action_information_category => p_tab_rec_data(i).action_info_category,
                p_action_context_id    => p_assactid,
                p_action_context_type  => 'AAP',
                p_assignment_id        => p_tab_rec_data(i).assignment_id,
                p_effective_date       => sysdate,
                p_action_information1  => p_tab_rec_data(i).act_info1,
                p_action_information2  => p_tab_rec_data(i).act_info2,
                p_action_information3  => p_tab_rec_data(i).act_info3,
                p_action_information4  => p_tab_rec_data(i).act_info4,
                p_action_information5  => p_tab_rec_data(i).act_info5,
                p_action_information6  => p_tab_rec_data(i).act_info6,
                p_action_information7  => p_tab_rec_data(i).act_info7,
                p_action_information8  => p_tab_rec_data(i).act_info8,
                p_action_information9  => p_tab_rec_data(i).act_info9,
                p_action_information10 => p_tab_rec_data(i).act_info10,
                p_action_information11 => p_tab_rec_data(i).act_info11,
                p_action_information12 => p_tab_rec_data(i).act_info12,
                p_action_information13 => p_tab_rec_data(i).act_info13,
                p_action_information14 => p_tab_rec_data(i).act_info14,
                p_action_information15 => p_tab_rec_data(i).act_info15,
                p_action_information16 => p_tab_rec_data(i).act_info16,
                p_action_information17 => p_tab_rec_data(i).act_info17,
                p_action_information18 => p_tab_rec_data(i).act_info18,
                p_action_information19 => p_tab_rec_data(i).act_info19,
                p_action_information20 => p_tab_rec_data(i).act_info20,
                p_action_information21 => p_tab_rec_data(i).act_info21,
                p_action_information22 => p_tab_rec_data(i).act_info22,
                p_action_information23 => p_tab_rec_data(i).act_info23,
                p_action_information24 => p_tab_rec_data(i).act_info24,
                p_action_information25 => p_tab_rec_data(i).act_info25,
                p_action_information26 => p_tab_rec_data(i).act_info26,
                p_action_information27 => p_tab_rec_data(i).act_info27,
                p_action_information28 => p_tab_rec_data(i).act_info28,
                p_action_information29 => p_tab_rec_data(i).act_info29,
                p_action_information30 => p_tab_rec_data(i).act_info30
                );
            end if;
        end loop;
     end if;
     hr_utility.set_location('Leaving: '||l_proc,999);
end insert_archive_row;


end PAY_ZA_TYE_ARCHIVE_PKG;


/
