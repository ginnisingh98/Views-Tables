--------------------------------------------------------
--  DDL for Package Body PAY_COSTING_DETAIL_REP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_COSTING_DETAIL_REP_PKG" AS
/* $Header: pycstrep.pkb 120.2 2006/05/02 13:56:03 ppanda noship $ */
--
  /************************************************************
  ** Local Package Variables
  ************************************************************/
  gv_title               VARCHAR2(100);
  --gv_title               VARCHAR2(100) := ' Costing Detail Report';
  gc_csv_delimiter       VARCHAR2(1) := ',';
  gc_csv_data_delimiter  VARCHAR2(1) := '"';

  gv_html_start_data     VARCHAR2(5) := '<td>'  ;
  gv_html_end_data       VARCHAR2(5) := '</td>' ;

  gv_package_name        VARCHAR2(50) := 'pay_costing_detail_rep_pkg';


  /******************************************************************
  ** Function Returns the formated input string based on the
  ** Output format. If the format is CSV then the values are returned
  ** seperated by comma (,). If the format is HTML then the returned
  ** string as the HTML tags. The parameter p_bold only works for
  ** the HTML format.
  ******************************************************************/
  FUNCTION formated_data_string
             (p_input_string     in varchar2
             ,p_output_file_type in varchar2
             ,p_bold             in varchar2 default 'N'
             )
  RETURN VARCHAR2
  IS

    lv_format          varchar2(1000);

  BEGIN
    hr_utility.set_location(gv_package_name || '.formated_data_string', 10);
    if p_output_file_type = 'CSV' then
       hr_utility.set_location(gv_package_name || '.formated_data_string', 20);
       lv_format := gc_csv_data_delimiter || p_input_string ||
                           gc_csv_data_delimiter || gc_csv_delimiter;
    elsif p_output_file_type = 'HTML' then
       if p_input_string is null then
          hr_utility.set_location(gv_package_name || '.formated_data_string', 30);
          lv_format := gv_html_start_data || '&nbsp;' || gv_html_end_data;
       else
          if p_bold = 'Y' then
             hr_utility.set_location(gv_package_name || '.formated_data_string', 40);
             lv_format := gv_html_start_data || '<b> ' || p_input_string
                             || '</b>' || gv_html_end_data;
          else
             hr_utility.set_location(gv_package_name || '.formated_data_string', 50);
             lv_format := gv_html_start_data || p_input_string || gv_html_end_data;
          end if;
       end if;
    end if;

    hr_utility.set_location(gv_package_name || '.formated_data_string', 60);
    return lv_format;

  END formated_data_string;


  /************************************************************
  ** Function returns the string with the HTML Header tags
  ************************************************************/
  FUNCTION formated_header_string
             (p_input_string     in varchar2
             ,p_output_file_type in varchar2
             )
  RETURN VARCHAR2
  IS
    lv_format          varchar2(1000);
  BEGIN
    hr_utility.set_location(gv_package_name || '.formated_header_string', 10);
    if p_output_file_type = 'CSV' then
       hr_utility.set_location(gv_package_name || '.formated_header_string', 20);
       lv_format := p_input_string;
    elsif p_output_file_type = 'HTML' then
       hr_utility.set_location(gv_package_name || '.formated_header_string', 30);
       lv_format := '<HTML><HEAD> <CENTER> <H1> <B>' || p_input_string ||
                             '</B></H1></CENTER></HEAD>';
    end if;
    hr_utility.set_location(gv_package_name || '.formated_header_string', 40);
    return lv_format;
  END formated_header_string;


  /*****************************************************************
  ** This procudure returns the Mandatory Static Labels and the
  ** Other Additional Static columns. The other static columns are
  ** printed after all the Element Information is printed for each
  ** employee assignment.
  ** The users can add hooks to this package to print more additional
  ** data which they require for this report.
  ** The package prints the user data from a PL/SQL table. The users
  ** can insert data and the label in this PL/SQL table which will
  ** be printed at the end of the report.
  ** The PL/SQL table which needs to be populated is
  ** LTR_ELEMENT_EXTRACT_DATA. This PL/SQL table is defined in the
  ** Package pay_element_extract_data_pkg (pyelerpd.pkh/pkb).
  *****************************************************************/
  PROCEDURE formated_static_header(
              p_output_file_type  in varchar2
             ,p_static_label1    out nocopy varchar2
             ,p_static_label2    out nocopy varchar2
             ,p_chk_ni_prt       in  varchar2 -- Bug 4142845
             ,p_business_group_id in varchar2 -- Bug 2007614
             )
  IS

--Bug 2007614
    cursor c_legislation_code is
      select  legislation_code
       from   per_business_groups
      where   business_group_id = p_business_group_id;

    lv_legislation_code varchar2(150);-- Bug 2007614
    lv_ssl_number       varchar2(150); -- Bug 2007614
    lv_format1          varchar2(32000);
    lv_format2          varchar2(32000);

  BEGIN

--  bug 3039073 replace hardcoded strings with translatable variables from
--  FND_COMMON_LOOKUPS table using the hr_general.decode_fnd_comm_lookup
--  function from the hrgenral.pkb package
--  Bug 2007614
      open c_legislation_code ;
      fetch c_legislation_code into lv_legislation_code;
      /* Commented for Bug # 5192802
      if lv_legislation_code = 'CA' then
          lv_ssl_number := 'SIN';
      else
          lv_ssl_number := 'SSN';
      end if;
     */
      /* This is added to fix Bug # 5179163 */
      fnd_message.set_name('PER','HR_NATIONAL_ID_NUMBER_'||lv_legislation_code);
      lv_ssl_number := fnd_message.get;
      if lv_ssl_number IS NULL
      then
         lv_ssl_number := 'National Identifier';
      end if;
      hr_utility.trace('HR_NATIONAL_ID_NUMBER_'||lv_legislation_code ||' = ' || lv_ssl_number);


      hr_utility.set_location(gv_package_name || '.formated_static_header', 10);
      lv_format1 :=
                    formated_data_string (p_input_string =>
                                           hr_general.decode_fnd_comm_lookup
                                             ('PAYROLL_REPORTS',  --lookup_type
                                              'CONS_SET_NAME')--lookup_code
                                         ,p_bold         => 'Y'
                                         ,p_output_file_type => p_output_file_type) ||
                    formated_data_string (p_input_string =>
                                           hr_general.decode_fnd_comm_lookup
                                             ('PAYROLL_REPORTS',  --lookup_type
                                              'PR_NAME')--lookup_code
                                         ,p_bold         => 'Y'
                                         ,p_output_file_type => p_output_file_type) ||
                    formated_data_string (p_input_string =>
                                           hr_general.decode_fnd_comm_lookup
                                             ('PAYROLL_REPORTS',  --lookup_type
                                              'GRE')--lookup_code
                                         ,p_bold         => 'Y'
                                         ,p_output_file_type => p_output_file_type) ||
                    formated_data_string (p_input_string =>
                                           hr_general.decode_fnd_comm_lookup
                                             ('PAYROLL_REPORTS',  --lookup_type
                                              'L_NAME')--lookup_code
                                         ,p_bold         => 'Y'
                                         ,p_output_file_type => p_output_file_type) ||
                    formated_data_string (p_input_string =>
                                           hr_general.decode_fnd_comm_lookup
                                             ('PAYROLL_REPORTS',  --lookup_type
                                              'F_NAME')--lookup_code
                                         ,p_bold         => 'Y'
                                         ,p_output_file_type => p_output_file_type) ||
                    formated_data_string (p_input_string =>
                                           hr_general.decode_fnd_comm_lookup
                                             ('PAYROLL_REPORTS',  --lookup_type
                                              'MI_NAME')--lookup_code
                                         ,p_bold         => 'Y'
                                         ,p_output_file_type => p_output_file_type) ||
                    formated_data_string (p_input_string =>
                                           hr_general.decode_fnd_comm_lookup
                                             ('PAYROLL_REPORTS',  --lookup_type
                                              'EFF_DT')--lookup_code
                                         ,p_bold         => 'Y'
                                         ,p_output_file_type => p_output_file_type) ||
                    formated_data_string (p_input_string =>
                                           hr_general.decode_fnd_comm_lookup
                                             ('PAYROLL_REPORTS',  --lookup_type
                                              'ELE_NAME')--lookup_code
                                         ,p_bold         => 'Y'
                                         ,p_output_file_type => p_output_file_type) ||
                    formated_data_string (p_input_string =>
                                           hr_general.decode_fnd_comm_lookup
                                             ('PAYROLL_REPORTS',  --lookup_type
                                              'INP_VAL')--lookup_code
                                         ,p_bold         => 'Y'
                                         ,p_output_file_type => p_output_file_type) ||
                    formated_data_string (p_input_string =>
                                           hr_general.decode_fnd_comm_lookup
                                             ('PAYROLL_REPORTS',  --lookup_type
                                              'UOM')--lookup_code
                                         ,p_bold         => 'Y'
                                         ,p_output_file_type => p_output_file_type) ||
                    formated_data_string (p_input_string =>
                                           hr_general.decode_fnd_comm_lookup
                                             ('PAYROLL_REPORTS',  --lookup_type
                                              'COST_ALLOC_SEGM')--lookup_code
                                         ,p_bold         => 'Y'
                                         ,p_output_file_type => p_output_file_type) ||
                    formated_data_string (p_input_string =>
                                           hr_general.decode_fnd_comm_lookup
                                             ('PAYROLL_REPORTS',  --lookup_type
                                              'CR_AMT')--lookup_code
                                         ,p_bold         => 'Y'
                                         ,p_output_file_type => p_output_file_type) ||
                    formated_data_string (p_input_string =>
                                           hr_general.decode_fnd_comm_lookup
                                             ('PAYROLL_REPORTS',  --lookup_type
                                              'DR_AMT')--lookup_code
                                         ,p_bold         => 'Y'
                                         ,p_output_file_type => p_output_file_type) ;


      hr_utility.set_location(gv_package_name || '.formated_static_header', 20);
      lv_format2 :=
                    formated_data_string (p_input_string =>
                                           hr_general.decode_fnd_comm_lookup
                                             ('PAYROLL_REPORTS',  --lookup_type
                                              'ORG_NAME')--lookup_code
                                         ,p_bold         => 'Y'
                                         ,p_output_file_type => p_output_file_type) ||
                    formated_data_string (p_input_string =>
                                           hr_general.decode_fnd_comm_lookup
                                             ('PAYROLL_REPORTS',  --lookup_type
                                              'LOC_NAME')--lookup_code
                                         ,p_bold         => 'Y'
                                         ,p_output_file_type => p_output_file_type) ;
/* Added by ssmukher for Bug 4142845 */
     if p_chk_ni_prt = 'Y' then
       lv_format2 := lv_format2 ||
                    formated_data_string (p_input_string =>
                                           NVL(hr_general.decode_fnd_comm_lookup
                                               ('PAYROLL_REPORTS',  --lookup_type
                                                lv_ssl_number),
					      lv_ssl_number)--lookup_code Bug 2007614
                                         ,p_bold         => 'Y'
                                         ,p_output_file_type => p_output_file_type) ;
     end if;

       lv_format2 := lv_format2 ||
                    formated_data_string (p_input_string =>
                                           hr_general.decode_fnd_comm_lookup
                                             ('PAYROLL_REPORTS',  --lookup_type
                                              'EMP_NO')--lookup_code
                                         ,p_bold         => 'Y'
                                         ,p_output_file_type => p_output_file_type) ||
                    formated_data_string (p_input_string =>
                                           hr_general.decode_fnd_comm_lookup
                                             ('PAYROLL_REPORTS',  --lookup_type
                                              'ASSIGN_NO')--lookup_code
                                         ,p_bold         => 'Y'
                                         ,p_output_file_type => p_output_file_type)
                    ;

      hr_utility.set_location(gv_package_name || '.formated_static_header', 30);

      p_static_label1 := lv_format1;
      p_static_label2 := lv_format2;
      hr_utility.trace('Static Label1 = ' || lv_format1);
      hr_utility.trace('Static Label2 = ' || lv_format2);
      hr_utility.set_location(gv_package_name || '.formated_static_header', 40);

  END formated_static_header;


  /*****************************************************************
  ** This procudure returns the Mandatory Static Labels and the
  ** Other Additional Static columns. The other static columns are
  ** printed after all the Element Information is printed for each
  ** employee assignment.
  ** The users can add hooks to this package to print more additional
  ** data which they require for this report.
  ** The package prints the user data from a PL/SQL table. The users
  ** can insert data and the label in this PL/SQL table which will
  ** be printed at the end of the report.
  ** The PL/SQL table which needs to be populated is
  ** LTR_ELEMENT_EXTRACT_DATA. This PL/SQL table is defined in the
  ** Package pay_element_extract_data_pkg (pyelerpd.pkh/pkb).
  *****************************************************************/
  PROCEDURE formated_static_data (
                   p_consolidation_set_name    in varchar2
                  ,p_payroll_name              in varchar2
                  ,p_gre_name                  in varchar2
                  ,p_emp_last_name             in varchar2
                  ,p_emp_first_name            in varchar2
                  ,p_emp_middle_names          in varchar2
                  ,p_action_effective_date     in date
                  ,p_element_name              in varchar2
                  ,p_input_value_name          in varchar2
                  ,p_uom                       in varchar2 -- Bug 3072270
                  ,p_credit_amount             in number
                  ,p_debit_amount              in number
		  ,p_accrual_type              in varchar2 --Bug 3179050
                  ,p_concatenated_segments     in varchar2
                  ,p_org_name                  in varchar2
                  ,p_location_code             in varchar2
                  ,p_emp_employee_number       in varchar2
                  ,p_emp_national_identifier   in varchar2
                  ,p_assignment_number         in varchar2
                  ,p_chk_ni_prt                in varchar2   --Bug 4142845
                  ,p_output_file_type          in varchar2
                  ,p_static_data1             out nocopy varchar2
                  ,p_static_data2             out nocopy varchar2
             )
  IS

    lv_format1 VARCHAR2(32000);
    lv_format2 VARCHAR2(32000);

    lv_action_effective_date     varchar2(20);

  BEGIN

      hr_utility.set_location(gv_package_name || '.formated_static_data', 10);
      lv_action_effective_date := to_char(p_action_effective_date, 'dd-MON-yyyy');
      lv_format1 :=
                    formated_data_string (p_input_string => p_consolidation_set_name
                                         ,p_output_file_type => p_output_file_type) ||
                    formated_data_string (p_input_string => p_payroll_name
                                         ,p_output_file_type => p_output_file_type) ||
                    formated_data_string (p_input_string => p_gre_name
                                         ,p_output_file_type => p_output_file_type) ||
                    formated_data_string (p_input_string => p_emp_last_name
                                         ,p_output_file_type => p_output_file_type) ||
                    formated_data_string (p_input_string => p_emp_first_name
                                         ,p_output_file_type => p_output_file_type) ||
                    formated_data_string (p_input_string => p_emp_middle_names
                                         ,p_output_file_type => p_output_file_type) ||
                    formated_data_string (p_input_string => lv_action_effective_date
                                         ,p_output_file_type => p_output_file_type) ||
                    formated_data_string (p_input_string => p_element_name
                                         ,p_output_file_type => p_output_file_type) ||
                    formated_data_string (p_input_string => p_input_value_name
                                         ,p_output_file_type => p_output_file_type) ||
                    formated_data_string (p_input_string => p_uom    -- Bug 3072270
                                         ,p_output_file_type => p_output_file_type) ||
                    formated_data_string (p_input_string => p_concatenated_segments
                                         ,p_output_file_type => p_output_file_type) ||
                    formated_data_string (p_input_string => p_credit_amount
                                         ,p_output_file_type => p_output_file_type) ||
                    formated_data_string (p_input_string => p_debit_amount
                                         ,p_output_file_type => p_output_file_type) ||
		    formated_data_string (p_input_string => p_accrual_type
		                         ,p_output_file_type => p_output_file_type)
                    ;

      hr_utility.set_location(gv_package_name || '.formated_static_data', 20);

      lv_format2 :=
                    formated_data_string (p_input_string => p_org_name
                                         ,p_output_file_type => p_output_file_type) ||
                    formated_data_string (p_input_string => p_location_code
                                         ,p_output_file_type => p_output_file_type);

/* Added by ssmukher for Bug 4142845 */
     if p_chk_ni_prt = 'Y' then
       lv_format2 := lv_format2 ||
                     formated_data_string (p_input_string => p_emp_national_identifier
                                         ,p_output_file_type => p_output_file_type);
     end if;

      lv_format2  := lv_format2 ||
                    formated_data_string (p_input_string => p_emp_employee_number
                                         ,p_output_file_type => p_output_file_type) ||
                    formated_data_string (p_input_string => p_assignment_number
                                         ,p_output_file_type => p_output_file_type)
                    ;

      hr_utility.set_location(gv_package_name || '.formated_static_data', 30);

      p_static_data1 := lv_format1;
      p_static_data2 := lv_format2;
      hr_utility.trace('Static Data1 = ' || lv_format1);
      hr_utility.trace('Static Data2 = ' || lv_format2);
      hr_utility.set_location(gv_package_name || '.formated_static_data', 40);

  END;

 /******************************************************************
  Function for returning the optional where clause for the cursor
  c_asg_costing_details
  Bug 3179050 To include Partial Period Accruals
  ******************************************************************/

  function get_optional_where_clause(cp_payroll_id in number
                                    ,cp_consolidation_set_id in number
                                    ,cp_tax_unit_id in number
                                    ,cp_organization_id in number
                                    ,cp_location_id in number
                                    ,cp_person_id in number) return varchar2 is

  dynamic_where_clause varchar2(10000);

  begin

  if cp_consolidation_set_id is not null then
    dynamic_where_clause := ' and pcd.consolidation_set_id = '|| to_char(cp_consolidation_set_id);
  end if;

  if cp_payroll_id is not null then
    dynamic_where_clause := dynamic_where_clause || ' and pcd.payroll_id = '|| to_char(cp_payroll_id);
  end if;

  if cp_tax_unit_id is not null then
    dynamic_where_clause:= dynamic_where_clause || ' and pcd.tax_unit_id = ' || to_char(cp_tax_unit_id);
  end if;

  if cp_organization_id is not null then
    dynamic_where_clause := dynamic_where_clause || ' and pcd.organization_id = ' || to_char(cp_organization_id);
  end if;

  if cp_location_id is not null then
    dynamic_where_clause := dynamic_where_clause || ' and pcd.location_id = ' || to_char(cp_location_id);
  end if;

  if cp_person_id is not null then
    dynamic_where_clause := dynamic_where_clause || ' and pcd.person_id = ' || to_char(cp_person_id);
  end if;

  return dynamic_where_clause;

  end get_optional_where_clause;

  /*****************************************************************
  ** This is the main procedure which is called from the Concurrent
  ** Request. All the paramaters are passed based on which it will
  ** either print a CSV format or an HTML format file.
  *****************************************************************/
  PROCEDURE costing_extract
             (errbuf                      out nocopy varchar2
             ,retcode                     out nocopy number
             ,p_business_group_id         in  number
             ,p_start_date                in  varchar2
             ,p_end_date                  in  varchar2
             ,p_selection_criteria        in  varchar2
             ,p_is_ele_set                in  varchar2
             ,p_element_set_id            in  number
             ,p_is_ele_class              in  varchar2
             ,p_element_classification_id in  number
             ,p_is_ele                    in  varchar2
             ,p_element_type_id           in  number
             ,p_payroll_id                in  number
             ,p_consolidation_set_id      in  number
             ,p_tax_unit_id               in  number
             ,p_organization_id           in  number
             ,p_location_id               in  number
             ,p_person_id                 in  number
             ,p_assignment_set_id         in  number
             ,p_cost_type                 in  varchar2  --Bug 3179050
             ,p_output_file_type          in  varchar2
             )
  IS

   /************************************************************
   ** Added by ssmukher for Bug 4142845
   ** Cursor to get the Legislation Code for the Business Group.
   ************************************************************/
   cursor c_leg_code(cp_business_group in number) is
     select legislation_code
      from  per_business_groups
     where  business_group_id = cp_business_group;

   /************************************************************
   ** Added by ssmukher for Bug 4142845
   ** Cursor to get the Legislation Rule info for printing the
   ** National Identifier
   ************************************************************/
   cursor c_national_identifier(cp_legislation_code in varchar) is
     select  nvl(rule_mode,'Y')
      from   pay_legislative_field_info
     where   field_name = 'NATIONAL_IDENTIFIER_PRT'
       and   rule_type = 'DISPLAY'
       and   legislation_code  = cp_legislation_code;


    /************************************************************
    ** Cursor to get the Costing flex which is setup at
    ** Business Group.
    ************************************************************/
    cursor c_costing_flex_id (cp_business_group_id in number) is
      select org_information7
        from hr_organization_information hoi
       where organization_id = cp_business_group_id
         and org_information_context = 'Business Group Information';

    /************************************************************
    ** Cursor returns all the segments defined for the Costing
    ** Flex which are enabled and displayed.
    ************************************************************/
    cursor c_costing_flex_segments (cp_id_flex_num in number) is
      select segment_name, application_column_name
        from fnd_id_flex_segments
       where id_flex_code = 'COST'
         and id_flex_num = cp_id_flex_num
         and enabled_flag = 'Y'
         and display_flag = 'Y'
      order by segment_num;

    /*************************************************************
    ** Local Variables
    *************************************************************/
    lv_consolidation_set_name      VARCHAR2(100);
    lv_payroll_name                VARCHAR2(100);
    lv_gre_name                    VARCHAR2(240);
    lv_org_name                    VARCHAR2(240);
    lv_location_code               VARCHAR2(100);
    lv_emp_last_name               VARCHAR2(150);
    lv_emp_first_name              VARCHAR2(150);
    lv_emp_middle_names            VARCHAR2(100);
    lv_emp_employee_number         VARCHAR2(100);
    lv_assignment_number           VARCHAR2(100);
    lv_element_name                VARCHAR2(100);
    lv_input_value_name            VARCHAR2(100);
    lv_uom                         VARCHAR2(20);-- Bug 3072270
    ln_credit_amount               NUMBER;
    ln_debit_amount                NUMBER;

    lv_emp_national_identifier     VARCHAR2(100);
    ld_effective_date              DATE;
    lv_concatenated_segments       VARCHAR2(200);
    lv_segment1                    VARCHAR2(200);
    lv_segment2                    VARCHAR2(200);
    lv_segment3                    VARCHAR2(200);
    lv_segment4                    VARCHAR2(200);
    lv_segment5                    VARCHAR2(200);
    lv_segment6                    VARCHAR2(200);
    lv_segment7                    VARCHAR2(200);
    lv_segment8                    VARCHAR2(200);
    lv_segment9                    VARCHAR2(200);
    lv_segment10                   VARCHAR2(200);
    lv_segment11                   VARCHAR2(200);
    lv_segment12                   VARCHAR2(200);
    lv_segment13                   VARCHAR2(200);
    lv_segment14                   VARCHAR2(200);
    lv_segment15                   VARCHAR2(200);
    lv_segment16                   VARCHAR2(200);
    lv_segment17                   VARCHAR2(200);
    lv_segment18                   VARCHAR2(200);
    lv_segment19                   VARCHAR2(200);
    lv_segment20                   VARCHAR2(200);
    lv_segment21                   VARCHAR2(200);
    lv_segment22                   VARCHAR2(200);
    lv_segment23                   VARCHAR2(200);
    lv_segment24                   VARCHAR2(200);
    lv_segment25                   VARCHAR2(200);
    lv_segment26                   VARCHAR2(200);
    lv_segment27                   VARCHAR2(200);
    lv_segment28                   VARCHAR2(200);
    lv_segment29                   VARCHAR2(200);
    lv_segment30                   VARCHAR2(200);

    ln_assignment_id               NUMBER;
    ln_costing_id_flex_num         NUMBER;
    lv_segment_name                VARCHAR2(100);
    lv_segment_value               VARCHAR2(100);
    lv_column_name                 VARCHAR2(100);

    lv_header_label                VARCHAR2(32000);
    lv_header_label1               VARCHAR2(32000);
    lv_header_label2               VARCHAR2(32000);

    lv_data_row                    VARCHAR2(32000);
    lv_data_row1                   VARCHAR2(32000);
    lv_data_row2                   VARCHAR2(32000);

    lv_chk_ni_prt                  VARCHAR2(30);         --Bug 4142845
    lv_legislation_code            VARCHAR2(10);

    ln_count                       NUMBER := 0;
    lv_accrual_type                varchar2(100);   --Bug 3179050
    lv_cost_mode                   varchar2(100);   --Bug 3179050

    ltr_costing_segment  costing_tab;
    lv_before_report_flag          BOOLEAN;
    TYPE  cur_type is REF CURSOR;     -- Bug 3179050
    c_asg_costing_details cur_type;                 --Bug 3179050

    c_query varchar2(5000);     --for the cursor query (Bug 3179050)
    c_clause1 varchar2(5000);   --to store the optional where clause (Bug 3179050)

BEGIN

   hr_utility.trace('Cost Type = ' || p_cost_type);
   hr_utility.set_location(gv_package_name || '.costing_extract', 10);
   hr_utility.trace('Start Date = '       || p_start_date);
   hr_utility.trace('End Date = '         || p_end_date);
   hr_utility.trace('Business Group ID = '|| p_business_group_id);
   hr_utility.trace('Classification ID = '|| nvl(to_char(p_element_classification_id), 'NULL'));
   hr_utility.trace('Element Set ID = '   || nvl(to_char(p_element_set_id), 'NULL'));
   hr_utility.trace('Element Type ID = '  || nvl(to_char(p_element_type_id), 'NULL'));
   hr_utility.trace('Person ID = '        || p_person_id);
   hr_utility.trace('Location ID = '      || p_location_id);
   hr_utility.trace('Organization ID = '  || p_organization_id);
   hr_utility.trace('Tax Unit ID = '      || p_tax_unit_id);
   hr_utility.trace('Payroll ID = '       || p_payroll_id);
   hr_utility.trace('Consolidation ID = ' || p_consolidation_set_id);
   hr_utility.trace('Asgn Set ID = '      || p_assignment_set_id);
   hr_utility.set_location(gv_package_name || '.costing_extract', 20);

/* Added by ssmukher for Bug 4142845  */
   open c_leg_code(p_business_group_id);
   fetch c_leg_code into lv_legislation_code;
   close c_leg_code;

   open c_national_identifier( lv_legislation_code);
   fetch c_national_identifier into lv_chk_ni_prt;
   if c_national_identifier%notfound then
      lv_chk_ni_prt := 'Y';
      close c_national_identifier;
   else
      close c_national_identifier;
   end if;

   formated_static_header( p_output_file_type
                          ,lv_header_label1
                          ,lv_header_label2
                          ,lv_chk_ni_prt      --  --Bug 4142845
                          ,p_business_group_id);

   lv_header_label := lv_header_label1;

   hr_utility.set_location(gv_package_name || '.costing_extract', 30);
   lv_header_label := lv_header_label ||
                        formated_data_string (
			        p_input_string => 'Accrual Type'
                               ,p_bold         => 'Y'
			       ,p_output_file_type => p_output_file_type);

   open c_costing_flex_id (p_business_group_id);
   fetch c_costing_flex_id into ln_costing_id_flex_num;
   if c_costing_flex_id%found then
      hr_utility.set_location(gv_package_name || '.costing_extract', 40);
      open c_costing_flex_segments (ln_costing_id_flex_num);
      loop
        fetch c_costing_flex_segments into lv_segment_name, lv_column_name;
        if c_costing_flex_segments%notfound then
           exit;
        end if;
        lv_header_label := lv_header_label ||
                             formated_data_string (
                                     p_input_string => lv_segment_name
                                    ,p_bold         => 'Y'
                                    ,p_output_file_type => p_output_file_type);

        ltr_costing_segment(ln_count).segment_label := lv_segment_name;
        ltr_costing_segment(ln_count).column_name   := lv_column_name;
        ln_count := ln_count + 1;

      end loop;
      close c_costing_flex_segments;

   end if;
   close c_costing_flex_id;
   hr_utility.set_location(gv_package_name || '.costing_extract', 50);

   /****************************************************************
   ** Concatnating the second Header Label which includes the
   ** data set which has to be printed at the end of the report.
   ****************************************************************/
   lv_header_label := lv_header_label || lv_header_label2;

   hr_utility.set_location(gv_package_name || '.costing_extract', 60);
   hr_utility.trace('Static and Element Label = ' || lv_header_label);

   gv_title := hr_general.decode_fnd_comm_lookup
                 ('PAYROLL_REPORTS',
                  'COSTING_REPORT_TITLE');

   fnd_file.put_line(fnd_file.output, formated_header_string(
                                          gv_title
                                         ,p_output_file_type
                                         ));

   hr_utility.set_location(gv_package_name || '.costing_extract', 70);
   /****************************************************************
   ** Print the Header Information. If the format is HTML then open
   ** the body and table before printing the header info, otherwise
   ** just print the header information.
   ****************************************************************/
   if p_output_file_type ='HTML' then
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<body>');
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<table border=1>');
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<tr>');
   end if;

   fnd_file.put_line(fnd_file.output, lv_header_label);

   if p_output_file_type ='HTML' then
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</tr>');
   end if;

   hr_utility.set_location(gv_package_name || '.costing_extract', 80);
   /*****************************************************
   ** Start of the Data Section of the Report
   *****************************************************/
   /*Bug 3179050 - changed cursor c_asg_costing_details to a REF CURSOR*/
   c_clause1:=get_optional_where_clause(p_payroll_id,
                                        p_consolidation_set_id,
                                        p_tax_unit_id,
                                        p_organization_id,
                                        p_location_id,
                                        p_person_id);
   --3581378
    if p_element_type_id is not null then
        c_query :=
               'select  pcd.cost_type
                       ,pcd.consolidation_set_name
                       ,pcd.payroll_name
                       ,pcd.gre_name
                       ,pcd.organization_name
                       ,pcd.location_code
                       ,pcd.last_name
                       ,pcd.first_name
                       ,pcd.middle_names
                       ,pcd.employee_number
                       ,pcd.assignment_number
                       ,nvl(pcd.reporting_name,pcd.element_name)
                       ,pcd.input_value_name
                       ,pcd.uom
                       ,pcd.credit_amount
                       ,pcd.debit_amount
                       ,pcd.national_identifier
                       ,pcd.effective_date
                       ,pcd.concatenated_segments
                       ,pcd.assignment_id
                       ,pcd.segment1
                       ,pcd.segment2
                       ,pcd.segment3
                       ,pcd.segment4
                       ,pcd.segment5
                       ,pcd.segment6
                       ,pcd.segment7
                       ,pcd.segment8
                       ,pcd.segment9
                       ,pcd.segment10
                       ,pcd.segment11
                       ,pcd.segment12
                       ,pcd.segment13
                       ,pcd.segment14
                       ,pcd.segment15
                       ,pcd.segment16
                       ,pcd.segment17
                       ,pcd.segment18
                       ,pcd.segment19
                       ,pcd.segment20
                       ,pcd.segment21
                       ,pcd.segment22
                       ,pcd.segment23
                       ,pcd.segment24
                       ,pcd.segment25
                       ,pcd.segment26
                       ,pcd.segment27
                       ,pcd.segment28
                       ,pcd.segment29
                       ,pcd.segment30
          from pay_costing_details_v pcd
         where pcd.effective_date between :cp_start_date and :cp_end_date
               ' || c_clause1 || '
	   and pcd.business_group_id = ' || NVL(p_business_group_id,0) || '
           and (:cp_assignment_set_id is NULL
	     or (
	        :cp_assignment_set_id is not NULL
	         and :cp_assignment_set_id in
		        (select assignment_set_id
                           from hr_assignment_set_amendments hasa
		          where hasa.assignment_set_id = :cp_assignment_set_id
		            and pcd.assignment_id = hasa.assignment_id
		        )
               )
              )
         and (:cp_element_type_id is null
               or (:cp_element_type_id is not null
                   and pcd.element_type_id = :cp_element_type_id)
             )
         and ((:cp_cost_type = ''EST_MODE_COST''
               and pcd.cost_type in (''COST_TMP'',''EST_COST''))
              or
              (:cp_cost_type = ''EST_MODE_ALL''
              and pcd.cost_type in (''COST_TMP'',''EST_COST'',''EST_REVERSAL''))
              or
              (:cp_cost_type is null
               and pcd.cost_type = ''COST_TMP'')
             )
	order by pcd.last_name, pcd.first_name,
               pcd.middle_names, pcd.effective_date,pcd.cost_type';

  elsif p_element_set_id is not null then
    c_query :=
               'select  pcd.cost_type
                       ,pcd.consolidation_set_name
                       ,pcd.payroll_name
                       ,pcd.gre_name
                       ,pcd.organization_name
                       ,pcd.location_code
                       ,pcd.last_name
                       ,pcd.first_name
                       ,pcd.middle_names
                       ,pcd.employee_number
                       ,pcd.assignment_number
                       ,nvl(pcd.reporting_name,pcd.element_name)
                       ,pcd.input_value_name
                       ,pcd.uom
                       ,pcd.credit_amount
                       ,pcd.debit_amount
                       ,pcd.national_identifier
                       ,pcd.effective_date
                       ,pcd.concatenated_segments
                       ,pcd.assignment_id
                       ,pcd.segment1
                       ,pcd.segment2
                       ,pcd.segment3
                       ,pcd.segment4
                       ,pcd.segment5
                       ,pcd.segment6
                       ,pcd.segment7
                       ,pcd.segment8
                       ,pcd.segment9
                       ,pcd.segment10
                       ,pcd.segment11
                       ,pcd.segment12
                       ,pcd.segment13
                       ,pcd.segment14
                       ,pcd.segment15
                       ,pcd.segment16
                       ,pcd.segment17
                       ,pcd.segment18
                       ,pcd.segment19
                       ,pcd.segment20
                       ,pcd.segment21
                       ,pcd.segment22
                       ,pcd.segment23
                       ,pcd.segment24
                       ,pcd.segment25
                       ,pcd.segment26
                       ,pcd.segment27
                       ,pcd.segment28
                       ,pcd.segment29
                       ,pcd.segment30
          from pay_costing_details_v pcd
         where pcd.effective_date between :cp_start_date and :cp_end_date
              ' || c_clause1 || '
	   and pcd.business_group_id = ' || NVL(p_business_group_id,0) || '
           and (:cp_assignment_set_id is NULL
	     or ( :cp_assignment_set_id is not NULL
	         and :cp_assignment_set_id in
	            (select assignment_set_id
                       from hr_assignment_set_amendments hasa
		      where hasa.assignment_set_id = :cp_assignment_set_id
		        and pcd.assignment_id = hasa.assignment_id
	           )
               )
             )
         and (:cp_element_set_id is null
                or (:cp_element_set_id is not null
                    and exists
                        (select ''x'' from pay_element_type_rules petr
                           where petr.element_set_id = :cp_element_set_id
                             and petr.element_type_id = pcd.element_type_id
                             and petr.include_or_exclude = ''I''
                         union all
                          select ''x'' from pay_element_types_f pet1
                           where pet1.classification_id in
                                    (select classification_id
                                       from pay_ele_classification_rules
                                      where element_set_id = :cp_element_set_id)
                             and pet1.element_type_id = pcd.element_type_id
                         minus
                          select ''x'' from pay_element_type_rules petr
                           where petr.element_set_id = :cp_element_set_id
                             and petr.element_type_id = pcd.element_type_id
                             and petr.include_or_exclude = ''E''
                        )
                   )
             )
         and ((:cp_cost_type = ''EST_MODE_COST''
               and pcd.cost_type in (''COST_TMP'',''EST_COST''))
              or
              (:cp_cost_type = ''EST_MODE_ALL''
              and pcd.cost_type in (''COST_TMP'',''EST_COST'',''EST_REVERSAL''))
              or
              (:cp_cost_type is null
               and pcd.cost_type = ''COST_TMP'')
             )
	order by pcd.last_name, pcd.first_name,
               pcd.middle_names, pcd.effective_date,pcd.cost_type';
  elsif p_element_classification_id is not null then
    c_query :=
               'select  pcd.cost_type
                       ,pcd.consolidation_set_name
                       ,pcd.payroll_name
                       ,pcd.gre_name
                       ,pcd.organization_name
                       ,pcd.location_code
                       ,pcd.last_name
                       ,pcd.first_name
                       ,pcd.middle_names
                       ,pcd.employee_number
                       ,pcd.assignment_number
                       ,nvl(pcd.reporting_name,pcd.element_name)
                       ,pcd.input_value_name
                       ,pcd.uom
                       ,pcd.credit_amount
                       ,pcd.debit_amount
                       ,pcd.national_identifier
                       ,pcd.effective_date
                       ,pcd.concatenated_segments
                       ,pcd.assignment_id
                       ,pcd.segment1
                       ,pcd.segment2
                       ,pcd.segment3
                       ,pcd.segment4
                       ,pcd.segment5
                       ,pcd.segment6
                       ,pcd.segment7
                       ,pcd.segment8
                       ,pcd.segment9
                       ,pcd.segment10
                       ,pcd.segment11
                       ,pcd.segment12
                       ,pcd.segment13
                       ,pcd.segment14
                       ,pcd.segment15
                       ,pcd.segment16
                       ,pcd.segment17
                       ,pcd.segment18
                       ,pcd.segment19
                       ,pcd.segment20
                       ,pcd.segment21
                       ,pcd.segment22
                       ,pcd.segment23
                       ,pcd.segment24
                       ,pcd.segment25
                       ,pcd.segment26
                       ,pcd.segment27
                       ,pcd.segment28
                       ,pcd.segment29
                       ,pcd.segment30
          from pay_costing_details_v pcd
         where pcd.effective_date between :cp_start_date and :cp_end_date
              ' || c_clause1 || '
	   and pcd.business_group_id = ' || NVL(p_business_group_id,0) || '
           and (:cp_assignment_set_id is NULL
	     or ( :cp_assignment_set_id is not NULL
	         and :cp_assignment_set_id in
		        (select assignment_set_id
                           from hr_assignment_set_amendments hasa
		          where hasa.assignment_set_id = :cp_assignment_set_id
		            and pcd.assignment_id = hasa.assignment_id
		           )
               )
             )
         and (:cp_element_classification_id is null
               or (:cp_element_classification_id is not null
                   and pcd.classification_id = :cp_element_classification_id)
             )
         and ((:cp_cost_type = ''EST_MODE_COST''
               and pcd.cost_type in (''COST_TMP'',''EST_COST''))
              or
              (:cp_cost_type = ''EST_MODE_ALL''
              and pcd.cost_type in (''COST_TMP'',''EST_COST'',''EST_REVERSAL''))
              or
              (:cp_cost_type is null
               and pcd.cost_type = ''COST_TMP'')
             )
	order by pcd.last_name, pcd.first_name,
               pcd.middle_names, pcd.effective_date,pcd.cost_type';
  elsif   (p_element_type_id is null)
   and (p_element_set_id is null)
   and (p_element_classification_id is null) then
    c_query :=
               'select  pcd.cost_type
                       ,pcd.consolidation_set_name
                       ,pcd.payroll_name
                       ,pcd.gre_name
                       ,pcd.organization_name
                       ,pcd.location_code
                       ,pcd.last_name
                       ,pcd.first_name
                       ,pcd.middle_names
                       ,pcd.employee_number
                       ,pcd.assignment_number
                       ,nvl(pcd.reporting_name,pcd.element_name)
                       ,pcd.input_value_name
                       ,pcd.uom
                       ,pcd.credit_amount
                       ,pcd.debit_amount
                       ,pcd.national_identifier
                       ,pcd.effective_date
                       ,pcd.concatenated_segments
                       ,pcd.assignment_id
                       ,pcd.segment1
                       ,pcd.segment2
                       ,pcd.segment3
                       ,pcd.segment4
                       ,pcd.segment5
                       ,pcd.segment6
                       ,pcd.segment7
                       ,pcd.segment8
                       ,pcd.segment9
                       ,pcd.segment10
                       ,pcd.segment11
                       ,pcd.segment12
                       ,pcd.segment13
                       ,pcd.segment14
                       ,pcd.segment15
                       ,pcd.segment16
                       ,pcd.segment17
                       ,pcd.segment18
                       ,pcd.segment19
                       ,pcd.segment20
                       ,pcd.segment21
                       ,pcd.segment22
                       ,pcd.segment23
                       ,pcd.segment24
                       ,pcd.segment25
                       ,pcd.segment26
                       ,pcd.segment27
                       ,pcd.segment28
                       ,pcd.segment29
                       ,pcd.segment30
          from pay_costing_details_v pcd
         where pcd.effective_date between :cp_start_date and :cp_end_date
              ' || c_clause1 || '
	   and pcd.business_group_id = ' || NVL(p_business_group_id,0) || '
           and (:cp_assignment_set_id is NULL
	     or ( :cp_assignment_set_id is not NULL
	         and :cp_assignment_set_id in
		      (select assignment_set_id
                         from hr_assignment_set_amendments hasa
	                where hasa.assignment_set_id = :cp_assignment_set_id
		          and pcd.assignment_id = hasa.assignment_id
		      )
               )
             )
         and ((:cp_cost_type = ''EST_MODE_COST''
               and pcd.cost_type in (''COST_TMP'',''EST_COST''))
              or
              (:cp_cost_type = ''EST_MODE_ALL''
              and pcd.cost_type in (''COST_TMP'',''EST_COST'',''EST_REVERSAL''))
              or
              (:cp_cost_type is null
               and pcd.cost_type = ''COST_TMP'')
             )
	order by pcd.last_name, pcd.first_name,
               pcd.middle_names, pcd.effective_date,pcd.cost_type';
       end if;

   if p_element_type_id is not null then
    OPEN c_asg_costing_details
     FOR c_query USING to_date(p_start_date, 'YYYY/MM/DD HH24:MI:SS')
                      ,to_date(p_end_date, 'YYYY/MM/DD HH24:MI:SS')
                      ,p_assignment_set_id,p_assignment_set_id
                      ,p_assignment_set_id,p_assignment_set_id
                      ,p_element_type_id,p_element_type_id,p_element_type_id
                      ,p_cost_type,p_cost_type,p_cost_type;
   elsif p_element_set_id is not null then
    OPEN c_asg_costing_details
     FOR c_query USING to_date(p_start_date, 'YYYY/MM/DD HH24:MI:SS')
                      ,to_date(p_end_date, 'YYYY/MM/DD HH24:MI:SS')
                      ,p_assignment_set_id,p_assignment_set_id
                      ,p_assignment_set_id,p_assignment_set_id
                      ,p_element_set_id,p_element_set_id,p_element_set_id
                      ,p_element_set_id,p_element_set_id
                      ,p_cost_type,p_cost_type,p_cost_type;
   elsif p_element_classification_id is not null then
      OPEN c_asg_costing_details
     FOR c_query USING to_date(p_start_date, 'YYYY/MM/DD HH24:MI:SS')
                      ,to_date(p_end_date, 'YYYY/MM/DD HH24:MI:SS')
                      ,p_assignment_set_id,p_assignment_set_id
                      ,p_assignment_set_id,p_assignment_set_id
                      ,p_element_classification_id,p_element_classification_id
                      ,p_element_classification_id
                      ,p_cost_type,p_cost_type,p_cost_type;
   elsif   (p_element_type_id is null)
    and (p_element_set_id is null)
    and (p_element_classification_id is null) then


    OPEN c_asg_costing_details
     FOR c_query USING to_date(p_start_date, 'YYYY/MM/DD HH24:MI:SS')
                      ,to_date(p_end_date, 'YYYY/MM/DD HH24:MI:SS')
                      ,p_assignment_set_id,p_assignment_set_id
                      ,p_assignment_set_id,p_assignment_set_id
                      ,p_cost_type,p_cost_type,p_cost_type;
   end if;

   loop
      fetch c_asg_costing_details into
                       lv_cost_mode
		      ,lv_consolidation_set_name
                      ,lv_payroll_name
                      ,lv_gre_name
                      ,lv_org_name
                      ,lv_location_code
                      ,lv_emp_last_name
                      ,lv_emp_first_name
                      ,lv_emp_middle_names
                      ,lv_emp_employee_number
                      ,lv_assignment_number
                      ,lv_element_name
                      ,lv_input_value_name
                      ,lv_uom         -- Bug 3072270
                      ,ln_credit_amount
                      ,ln_debit_amount
                      ,lv_emp_national_identifier
                      ,ld_effective_date
                      ,lv_concatenated_segments
                      ,ln_assignment_id
                      ,lv_segment1
                      ,lv_segment2
                      ,lv_segment3
                      ,lv_segment4
                      ,lv_segment5
                      ,lv_segment6
                      ,lv_segment7
                      ,lv_segment8
                      ,lv_segment9
                      ,lv_segment10
                      ,lv_segment11
                      ,lv_segment12
                      ,lv_segment13
                      ,lv_segment14
                      ,lv_segment15
                      ,lv_segment16
                      ,lv_segment17
                      ,lv_segment18
                      ,lv_segment19
                      ,lv_segment20
                      ,lv_segment21
                      ,lv_segment22
                      ,lv_segment23
                      ,lv_segment24
                      ,lv_segment25
                      ,lv_segment26
                      ,lv_segment27
                      ,lv_segment28
                      ,lv_segment29
                      ,lv_segment30
                      ;

      if c_asg_costing_details%notfound then
         hr_utility.set_location(gv_package_name || '.costing_extract', 90);
         exit;
      end if;

      lv_accrual_type:=nvl(hr_general.decode_lookup('PAY_PAYRPCBR',lv_cost_mode),' ');
      if p_output_file_type='HTML' and lv_accrual_type = ' ' then
         lv_accrual_type:='&nbsp;';
      end if;

      /************************************************************
      ** If Assignment Set is used, pick up only those employee
      ** assignments which are part of the Assignment Set - STATIC
      ** or DYNAMIC.
      ************************************************************/
      hr_utility.set_location(gv_package_name || '.costing_extract', 100);
      hr_utility.trace('Assignment ID = '     || ln_assignment_id);

      if hr_assignment_set.assignment_in_set(
                            p_assignment_set_id
                           ,ln_assignment_id)    = 'Y' then


         hr_utility.set_location(gv_package_name || '.costing_extract', 110);

         formated_static_data(
                   p_consolidation_set_name  => lv_consolidation_set_name
                  ,p_payroll_name            => lv_payroll_name
                  ,p_gre_name                => lv_gre_name
                  ,p_emp_last_name           => lv_emp_last_name
                  ,p_emp_first_name          => lv_emp_first_name
                  ,p_emp_middle_names        => lv_emp_middle_names
                  ,p_action_effective_date   => ld_effective_date
                  ,p_element_name            => lv_element_name
                  ,p_input_value_name        => lv_input_value_name
                  ,p_uom                     => lv_uom -- Bug 3072270
                  ,p_credit_amount           => ln_credit_amount
                  ,p_debit_amount            => ln_debit_amount
		  ,p_accrual_type            => lv_accrual_type
                  ,p_concatenated_segments   => lv_concatenated_segments
                  ,p_org_name                => lv_org_name
                  ,p_location_code           => lv_location_code
                  ,p_emp_employee_number     => lv_emp_employee_number
                  ,p_emp_national_identifier => lv_emp_national_identifier
                  ,p_assignment_number       => lv_assignment_number
                  ,p_chk_ni_prt              => lv_chk_ni_prt       --Bug 4142845 Added by ssmukher
                  ,p_output_file_type        => p_output_file_type
                  ,p_static_data1            => lv_data_row1
                  ,p_static_data2            => lv_data_row2);

         lv_data_row := lv_data_row1;
         hr_utility.set_location(gv_package_name || '.costing_extract', 120);

         for i in ltr_costing_segment.first .. ltr_costing_segment.last loop
             if ltr_costing_segment(i).column_name = 'SEGMENT1' then
                lv_segment_value := lv_segment1;
             elsif ltr_costing_segment(i).column_name = 'SEGMENT2' then
                lv_segment_value := lv_segment2;
             elsif ltr_costing_segment(i).column_name = 'SEGMENT3' then
                lv_segment_value := lv_segment3;
             elsif ltr_costing_segment(i).column_name = 'SEGMENT4' then
                lv_segment_value := lv_segment4;
             elsif ltr_costing_segment(i).column_name = 'SEGMENT5' then
                lv_segment_value := lv_segment5;
             elsif ltr_costing_segment(i).column_name = 'SEGMENT6' then
                lv_segment_value := lv_segment6;
             elsif ltr_costing_segment(i).column_name = 'SEGMENT7' then
                lv_segment_value := lv_segment7;
             elsif ltr_costing_segment(i).column_name = 'SEGMENT8' then
                lv_segment_value := lv_segment8;
             elsif ltr_costing_segment(i).column_name = 'SEGMENT9' then
                lv_segment_value := lv_segment9;
             elsif ltr_costing_segment(i).column_name = 'SEGMENT10' then
                lv_segment_value := lv_segment10;
             elsif ltr_costing_segment(i).column_name = 'SEGMENT11' then
                lv_segment_value := lv_segment11;
             elsif ltr_costing_segment(i).column_name = 'SEGMENT12' then
                lv_segment_value := lv_segment12;
             elsif ltr_costing_segment(i).column_name = 'SEGMENT13' then
                lv_segment_value := lv_segment13;
             elsif ltr_costing_segment(i).column_name = 'SEGMENT14' then
                lv_segment_value := lv_segment14;
             elsif ltr_costing_segment(i).column_name = 'SEGMENT15' then
                lv_segment_value := lv_segment15;
             elsif ltr_costing_segment(i).column_name = 'SEGMENT16' then
                lv_segment_value := lv_segment16;
             elsif ltr_costing_segment(i).column_name = 'SEGMENT17' then
                lv_segment_value := lv_segment17;
             elsif ltr_costing_segment(i).column_name = 'SEGMENT18' then
                lv_segment_value := lv_segment18;
             elsif ltr_costing_segment(i).column_name = 'SEGMENT19' then
                lv_segment_value := lv_segment19;
             elsif ltr_costing_segment(i).column_name = 'SEGMENT20' then
                lv_segment_value := lv_segment20;
             elsif ltr_costing_segment(i).column_name = 'SEGMENT21' then
                lv_segment_value := lv_segment21;
             elsif ltr_costing_segment(i).column_name = 'SEGMENT22' then
                lv_segment_value := lv_segment22;
             elsif ltr_costing_segment(i).column_name = 'SEGMENT23' then
                lv_segment_value := lv_segment23;
             elsif ltr_costing_segment(i).column_name = 'SEGMENT24' then
                lv_segment_value := lv_segment24;
             elsif ltr_costing_segment(i).column_name = 'SEGMENT25' then
                lv_segment_value := lv_segment25;
             elsif ltr_costing_segment(i).column_name = 'SEGMENT26' then
                lv_segment_value := lv_segment26;
             elsif ltr_costing_segment(i).column_name = 'SEGMENT27' then
                lv_segment_value := lv_segment27;
             elsif ltr_costing_segment(i).column_name = 'SEGMENT28' then
                lv_segment_value := lv_segment28;
             elsif ltr_costing_segment(i).column_name = 'SEGMENT29' then
                lv_segment_value := lv_segment29;
             elsif ltr_costing_segment(i).column_name = 'SEGMENT30' then
                lv_segment_value := lv_segment30;
             end if;

             lv_data_row := lv_data_row ||
                                     formated_data_string (
                                          p_input_string => lv_segment_value
                                         ,p_output_file_type => p_output_file_type);
         end loop ;
         hr_utility.set_location(gv_package_name || '.costing_extract', 130);

         /****************************************************************
         ** Concatnating the second Header Label which includes the
         ** data set which is printed at the end of the report.
         ****************************************************************/
         lv_data_row := lv_data_row || lv_data_row2;
         hr_utility.set_location(gv_package_name || '.costing_extract', 140);

         if p_output_file_type ='HTML' then
            lv_data_row := '<tr>' || lv_data_row || '</tr>' ;
         end if;

         FND_FILE.PUT_LINE(FND_FILE.OUTPUT, lv_data_row);

      end if;   /********** End of Assignment Set ************************/

      /*****************************************************************
      ** initialize Data varaibles
      *****************************************************************/
      lv_data_row  := null;
      lv_data_row1 := null;
      lv_data_row2 := null;
   end loop;
   close c_asg_costing_details;

   /*****************************************************
   ** Close of the Data Section of the Report
   *****************************************************/

   if p_output_file_type ='HTML' then
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '</table></body></html>');
   end if;
   hr_utility.trace('Concurrent Request ID = ' || FND_GLOBAL.CONC_REQUEST_ID);

  END costing_extract;

  function get_costing_tax_unit_id(p_ACTION_TYPE            pay_payroll_actions.action_type%TYPE,
                                   p_TAX_UNIT_ID            pay_assignment_actions.TAX_UNIT_ID%TYPE,
                                   p_assignment_action_id   pay_assignment_actions.assignment_action_id%TYPE,
                                   p_element_type_id        pay_element_types_f.element_type_id%TYPE
                                  ) return number IS
    CURSOR c_tax_unit is
    select paa.tax_unit_id
      from pay_run_results prr,
           PAY_ASSIGNMENT_ACTIONS paa,
           pay_action_interlocks pai
     where paa.assignment_action_id = prr.assignment_action_id
       AND paa.assignment_action_id = pai.LOCKED_ACTION_ID
       and pai.locking_action_id    = p_assignment_action_id
       and prr.element_type_id      = p_element_type_id;
     L_TAX_UNIT_ID            pay_assignment_actions.TAX_UNIT_ID%TYPE;
  BEGIN
    IF P_ACTION_TYPE = 'EC' THEN
       return P_TAX_UNIT_ID;
    ELSE
       OPEN c_tax_unit;
       FETCH c_tax_unit INTO l_tax_unit_id;
       CLOSE c_tax_unit;
       return l_tax_unit_id;
    END IF;
  END;

  function get_costing_tax_unit_name(p_tax_unit_id   HR_ORGANIZATION_UNITS.ORGANIZATION_ID%TYPE)
    return VARCHAR2 IS
    CURSOR c_tax_unit_name is
    select HOU_GRE.NAME
      from HR_ORGANIZATION_UNITS HOU_GRE
     where HOU_GRE.ORGANIZATION_ID = p_tax_unit_id;
     L_TAX_UNIT_NAME            hr_organization_units.NAME%TYPE;
  BEGIN
       IF p_tax_unit_id IS NULL THEN
          return NULL;
       END IF;
       IF g_tax_unit_name.EXISTS(p_tax_unit_id) then
         l_tax_unit_name := g_tax_unit_name(p_tax_unit_id);
         return l_tax_unit_name;
       END IF;
       OPEN c_tax_unit_name;
       FETCH c_tax_unit_name INTO l_tax_unit_name;
       CLOSE c_tax_unit_name;
       g_tax_unit_name(p_tax_unit_id)  := l_tax_unit_name;
       return l_tax_unit_name;
  END;
--begin
--hr_utility.trace_on(null, 'COSTING');
end pay_costing_detail_rep_pkg;

/
