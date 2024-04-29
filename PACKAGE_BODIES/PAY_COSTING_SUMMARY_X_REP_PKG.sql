--------------------------------------------------------
--  DDL for Package Body PAY_COSTING_SUMMARY_X_REP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_COSTING_SUMMARY_X_REP_PKG" AS
/* $Header: pyprxcsr.pkb 120.0.12010000.2 2010/04/14 12:00:36 sivanara ship $ */

/*************************************************************************
*                   Local Package Variables                              *
*************************************************************************/
    gv_package_name        VARCHAR2(50);
    gtr_costing_segment    costing_tab;
    g_xml_data             CLOB;    --For storing the XML output data.

/******************************************************************
*  Function for returning the optional where clause for the       *
*  cursor c_asg_costing_details                                   *
*******************************************************************/

FUNCTION get_optional_where_clause(cp_payroll_id IN NUMBER
                                    ,cp_consolidation_set_id IN NUMBER
                                    ,cp_tax_unit_id IN NUMBER
				    ,cp_costing_process_flag VARCHAR2
				    ,cp_costing   IN VARCHAR2
				    ,cp_cost_type IN VARCHAR2)
				    RETURN  VARCHAR2 IS

  dynamic_where_clause VARCHAR2(10000);

BEGIN

    IF cp_consolidation_set_id IS NOT NULL THEN
         dynamic_where_clause := ' AND pcd.consolidation_set_id = '||
	                         to_char(cp_consolidation_set_id);
    END IF;

    IF cp_payroll_id IS NOT NULL THEN
         dynamic_where_clause := dynamic_where_clause ||
		                 ' AND pcd.payroll_id = '||
			         to_char(cp_payroll_id);
    END IF;

    IF cp_tax_unit_id IS NOT NULL THEN
         dynamic_where_clause:= dynamic_where_clause ||
		                ' AND pcd.tax_unit_id = ' ||
			        to_char(cp_tax_unit_id);
    END IF;

    IF cp_costing_process_flag ='Y' THEN
         dynamic_where_clause := dynamic_where_clause ||
		                 ' AND pcd.payroll_action_id = ' ||
			         cp_costing;
    END IF;

    IF cp_cost_type  IS NULL THEN
         dynamic_where_clause := dynamic_where_clause ||
                                ' AND pcd.cost_type = ''COST_TMP''' ;
    ELSIF cp_cost_type  = 'EST_MODE_COST' THEN
         dynamic_where_clause := dynamic_where_clause ||
                                 ' AND pcd.cost_type IN (''COST_TMP'',
			                            ''EST_COST'') ';
    ELSIF cp_cost_type  = 'EST_MODE_ALL' THEN
         dynamic_where_clause := dynamic_where_clause ||
                                 ' AND pcd.cost_type IN (''COST_TMP'',
			                                 ''EST_COST'',
					                 ''EST_REVERSAL'') ';
    END IF;

    RETURN dynamic_where_clause;

END get_optional_where_clause;
--
/*******************************************************************
**This Function is used to get the template name from the template**
**code provided by the user.                                      **
*******************************************************************/

FUNCTION GET_TEMPLATE_NAME(P_App_Short_Name VARCHAR2
                          ,P_Template_Code VARCHAR2) RETURN VARCHAR2 IS

 l_template_name xdo_templates_tl.TEMPLATE_NAME%type;
BEGIN

    l_template_name := 'Not Defined';
    SELECT TEMPLATE_NAME
    INTO l_template_name
    FROM XDO_TEMPLATES_TL
    WHERE APPLICATION_SHORT_NAME= P_App_Short_Name
    AND	TEMPLATE_CODE= P_Template_Code
    AND	LANGUAGE=userenv('LANG');

 RETURN l_template_name;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN l_template_name;
END GET_TEMPLATE_NAME;
--
/********************************************************************
** This Function is used to return the string of parameters        **
** with the tags.                                                  **
********************************************************************/

FUNCTION getTaggedParameters(p_business_group          VARCHAR2
			    ,p_start_date              DATE
   			    ,p_end_date                DATE
			    ,p_costing                 VARCHAR2
                            ,p_payroll_name            VARCHAR2
                            ,p_consolidation_set_name  VARCHAR2
                            ,p_gre_name                VARCHAR2
                            ,p_include_accruals        VARCHAR2
                            ,p_sort_order1             VARCHAR2
                            ,p_sort_order2             VARCHAR2
			    ,p_template_name           VARCHAR2
			    )RETURN  VARCHAR2 IS
--
    l_costing  VARCHAR2(300) DEFAULT NULL;
--
BEGIN
--
    IF(p_costing IS NOT NULL) THEN
         l_costing := fnd_date.date_to_displaydate( p_start_date)||
				                   '('||p_costing||')';
    END IF;

    RETURN pay_prl_xml_utils.getTag(p_tag_Name   => 'C_BUSINESS_GROUP'
                                   ,p_tag_value  => p_business_group)||
	   pay_prl_xml_utils.getTag(p_tag_Name => 'C_STARTDATE_ICX'
                                   ,p_tag_value => fnd_date.date_to_displaydate(
				    p_start_date))||
	   pay_prl_xml_utils.getTag(p_tag_Name => 'C_ENDDATE_ICX'
                                   ,p_tag_value => fnd_date.date_to_displaydate(
				   p_end_date))||
	   pay_prl_xml_utils.getTag(p_tag_Name => 'C_COSTING'
                                   ,p_tag_value => l_costing)||
           pay_prl_xml_utils.getTag(p_tag_Name => 'C_PAYROLL_NAME'
                                   ,p_tag_value => p_payroll_name)||
	   pay_prl_xml_utils.getTag(p_tag_Name => 'C_CONSOLIDATION_SET'
                                   ,p_tag_value => p_consolidation_set_name)||
	   pay_prl_xml_utils.getTag(p_tag_Name => 'C_GRE_NAME'
                                   ,p_tag_value => p_gre_name)||
	   pay_prl_xml_utils.getTag(p_tag_Name => 'C_INCLUDE_ACCRUALS'
                                   ,p_tag_value => p_include_accruals)||
           pay_prl_xml_utils.getTag(p_tag_Name => 'C_SORT_ORDER1'
                                   ,p_tag_value => p_sort_order1)||
	   pay_prl_xml_utils.getTag(p_tag_Name => 'C_SORT_ORDER2'
                                   ,p_tag_value => p_sort_order2)||
	   pay_prl_xml_utils.getTag(p_tag_name => 'C_TEMPLATE_NAME'
	                           ,p_tag_value => get_template_name(
				                   p_app_short_name => 'PAY'
                                                  ,p_template_code  =>
						   p_template_name));

--
END getTaggedParameters;
--
--
/********************************************************************
** This Procedure is used to fill the global table variable        **
** gtr_costing_segment with the Cost Allocation Keyflex's enabled  **
** segments and thier respective values.                           **
********************************************************************/
--
PROCEDURE getNFillCostFlexSegments(p_business_group_id NUMBER)
IS
--
/***********************************************************
** Cursor to get the Costing flex which IS setup at       **
** Business Group.					  **
************************************************************/
--
        CURSOR c_costing_flex_id (cp_business_group_id IN NUMBER) IS
	      SELECT org_information7
	        FROM hr_organization_information hoi
	       WHERE organization_id = cp_business_group_id
	         AND org_information_context = 'Business Group Information';
--
/************************************************************
** Cursor returns all the segments defined for the Costing **
** Flex which are enabled and displayed.                   **
*************************************************************/
	CURSOR c_costing_flex_segments (cp_id_flex_num IN NUMBER) IS
	      SELECT segment_name, application_column_name
	        FROM fnd_id_flex_segments
	       WHERE id_flex_code = 'COST'
	         AND id_flex_num = cp_id_flex_num
	         AND enabled_flag = 'Y'
	         AND display_flag = 'Y'
	      ORDER BY segment_num;

ln_costing_id_flex_num         NUMBER;
lv_segment_name                VARCHAR2(100);
lv_column_name                 VARCHAR2(100);
ln_count                       NUMBER DEFAULT 0;

--
BEGIN
--
    OPEN c_costing_flex_id (p_business_group_id);
	   FETCH c_costing_flex_id INTO ln_costing_id_flex_num;
	   IF c_costing_flex_id%found THEN
	      hr_utility.set_location(gv_package_name || '.costing_summary', 20);
	      OPEN c_costing_flex_segments (ln_costing_id_flex_num);
	      LOOP
	        FETCH c_costing_flex_segments INTO lv_segment_name, lv_column_name;
	        IF c_costing_flex_segments%NOTFOUND THEN
	           exit;
	        END IF;
	        gtr_costing_segment(ln_count).segment_label := lv_segment_name;
	        gtr_costing_segment(ln_count).column_name   := lv_column_name;
	        ln_count := ln_count + 1;
	      END LOOP;
	      CLOSE c_costing_flex_segments;
	   END IF;
    CLOSE c_costing_flex_id;
--
END getNFillCostFlexSegments;
--
--
/***************************************************************
**  Procedure: costing_summary			              **
**                                                            **
**  Purpose  : This procedure is the one that is called from  **
**             the concurrent program.It's going to populate  **
**             the report output in XML format into the       **
**             global variable and then to the out variable.  **
****************************************************************/

PROCEDURE  costing_summary (p_xml                   OUT NOCOPY CLOB
                            ,p_business_group_id    IN NUMBER
                            ,p_start_date           IN VARCHAR2
                            ,p_dummy_start          IN VARCHAR2
                            ,p_end_date             IN VARCHAR2
                            ,p_costing              IN VARCHAR2
			    ,p_dummy_costing        IN VARCHAR2
                            ,p_payroll_id           IN NUMBER
                            ,p_consolidation_set_id IN NUMBER
                            ,p_tax_unit_id          IN NUMBER
                            ,p_cost_type            IN VARCHAR2
                            ,p_sort_order1          IN VARCHAR2
                            ,p_sort_order2          IN VARCHAR2
			    ,p_template_name        IN VARCHAR2
			    ) IS
--
--
TYPE  cur_type IS REF CURSOR;
c_asg_costing_details cur_type;
c_query VARCHAR2(5000);
c_clause1 VARCHAR2(5000);
--
/**********************************************************
** CURSOR to get the Business group name                 **
***********************************************************/
--
	CURSOR c_get_organization_name (cp_organization_id IN NUMBER) IS
              SELECT name
                FROM hr_organization_units
               WHERE organization_id=cp_organization_id;
--
/***********************************************************
** CURSORs to get payroll,consolidation set names         **
***********************************************************/
--
        CURSOR c_get_payroll_name (cp_payroll_id IN NUMBER) IS
              SELECT payroll_name
                FROM pay_payrolls_f
               WHERE payroll_id = cp_payroll_id;
--
        CURSOR c_get_consolidation_set_name (cp_consolidation_set_id IN NUMBER) IS
              SELECT consolidation_set_name
                FROM pay_consolidation_sets
               WHERE consolidation_set_id=cp_consolidation_set_id;
--
/***********************************************************
** CURSOR to get effective date for a payroll action id   **
************************************************************/
--
	CURSOR c_get_effective_date(cp_payroll_action_id IN NUMBER) IS
              SELECT effective_date
                FROM pay_payroll_actions
               WHERE payroll_action_id=cp_payroll_action_id;
--
        CURSOR c_get_accruals(cp_cost_type IN VARCHAR2) IS
              SELECT nvl(hr_general.decode_lookup('PAY_PAYRPCBR',cp_cost_type),' ')
                FROM dual;
--

/************************************************************
** Cursor returns  the session id                          **
*************************************************************/
--
        CURSOR c_get_session_id IS
             SELECT userenv('sessionid')
               FROM dual;

/************************************************************
** Cursor returns payroll/gre totals			   **
************************************************************/
--
	CURSOR c_costing_summary_rpt_details (cp_session_id IN NUMBER
                                              ,cp_business_group_id IN NUMBER
	                                      ,cp_csr IN VARCHAR2
	                                      ,cp_sort_order1 IN VARCHAR2
	                                      ,cp_sort_order2 IN VARCHAR2) IS
             SELECT decode(upper(cp_sort_order1),'PAYROLL NAME',attribute32
                           ,gre_name)
                           ,attribute34  --UOM
                           ,sum(value1)
                           ,sum(value2)
                           ,attribute1
                           ,attribute2
                           ,attribute3
                           ,attribute4
                           ,attribute5
                           ,attribute6
                           ,attribute7
                           ,attribute8
                           ,attribute9
                           ,attribute10
                           ,attribute11
                           ,attribute12
                           ,attribute13
                           ,attribute14
                           ,attribute15
                           ,attribute16
                           ,attribute17
                           ,attribute18
                           ,attribute19
                           ,attribute20
                           ,attribute21
                           ,attribute22
                           ,attribute23
                           ,attribute24
                           ,attribute25
                           ,attribute26
                           ,attribute27
                           ,attribute28
                           ,attribute29
                           ,attribute30
                FROM pay_us_rpt_totals
               WHERE business_group_id=cp_business_group_id
                 and attribute31=cp_csr
                 and session_id=cp_session_id
               GROUP BY decode(upper(cp_sort_order1), 'PAYROLL NAME',attribute32,
	                       gre_name)
	               ,attribute1
                       ,attribute2
	               ,attribute3
                       ,attribute4
                       ,attribute5
                       ,attribute6
                       ,attribute7
                       ,attribute8
                       ,attribute9
                       ,attribute10
                       ,attribute11
                       ,attribute12
                       ,attribute13
                       ,attribute14
                       ,attribute15
                       ,attribute16
                       ,attribute17
                       ,attribute18
                       ,attribute19
                       ,attribute20
                       ,attribute21
                       ,attribute22
                       ,attribute23
                       ,attribute24
                       ,attribute25
                       ,attribute26
                       ,attribute27
                       ,attribute28
                       ,attribute29
                       ,attribute30
                       ,attribute34
		order by
			attribute1
		       ,attribute2
	               ,attribute3
                       ,attribute4
                       ,attribute5
                       ,attribute6
                       ,attribute7
                       ,attribute8
                       ,attribute9
                       ,attribute10
                       ,attribute11
                       ,attribute12
                       ,attribute13
                       ,attribute14
                       ,attribute15
                       ,attribute16
                       ,attribute17
                       ,attribute18
                       ,attribute19
                       ,attribute20
                       ,attribute21
                       ,attribute22
                       ,attribute23
                       ,attribute24
                       ,attribute25
                       ,attribute26
                       ,attribute27
                       ,attribute28
                       ,attribute29
                       ,attribute30
                       ,attribute34
                       ;
--
/************************************************************
** Cursor returns grand totals				   **
************************************************************/
--
	CURSOR c_costing_grand_totals (cp_session_id IN NUMBER
                                        ,cp_business_group_id IN NUMBER
	                                ,cp_csr IN VARCHAR2
                                        ) IS
                  SELECT     attribute34 --UOM
                    ,sum(value1)
                    ,sum(value2)
                    ,attribute1
                    ,attribute2
                    ,attribute3
                    ,attribute4
                    ,attribute5
                    ,attribute6
                    ,attribute7
                    ,attribute8
                    ,attribute9
                    ,attribute10
                    ,attribute11
                    ,attribute12
                    ,attribute13
                    ,attribute14
                    ,attribute15
                    ,attribute16
                    ,attribute17
                    ,attribute18
                    ,attribute19
                    ,attribute20
                    ,attribute21
                    ,attribute22
                    ,attribute23
                    ,attribute24
                    ,attribute25
                    ,attribute26
                    ,attribute27
                    ,attribute28
                    ,attribute29
                    ,attribute30
                FROM pay_us_rpt_totals
               WHERE business_group_id=cp_business_group_id
                 AND attribute31=cp_csr
                 AND session_id=cp_session_id
               GROUP BY
                    attribute1
                    ,attribute2
                    ,attribute3
                    ,attribute4
                    ,attribute5
                    ,attribute6
                    ,attribute7
                    ,attribute8
                    ,attribute9
                    ,attribute10
                    ,attribute11
                    ,attribute12
                    ,attribute13
                    ,attribute14
                    ,attribute15
                    ,attribute16
                    ,attribute17
                    ,attribute18
                    ,attribute19
                    ,attribute20
                    ,attribute21
                    ,attribute22
                    ,attribute23
                    ,attribute24
                    ,attribute25
                    ,attribute26
                    ,attribute27
                    ,attribute28
                    ,attribute29
                    ,attribute30
                    ,attribute34
			order by
			attribute1
		       ,attribute2
	               ,attribute3
                       ,attribute4
                       ,attribute5
                       ,attribute6
                       ,attribute7
                       ,attribute8
                       ,attribute9
                       ,attribute10
                       ,attribute11
                       ,attribute12
                       ,attribute13
                       ,attribute14
                       ,attribute15
                       ,attribute16
                       ,attribute17
                       ,attribute18
                       ,attribute19
                       ,attribute20
                       ,attribute21
                       ,attribute22
                       ,attribute23
                       ,attribute24
                       ,attribute25
                       ,attribute26
                       ,attribute27
                       ,attribute28
                       ,attribute29
                       ,attribute30
                       ,attribute34
                       ;


/**************************************************************
**Cursor to get GRE/Payroll totals			     **
***************************************************************/
--
        CURSOR c_get_gre_or_payroll_totals(cp_session_id IN NUMBER
                                          ,cp_business_group_id IN NUMBER
                                          ,cp_total_flag IN VARCHAR2
                                          ,cp_sort_order1 IN VARCHAR2
                                           ) IS
             SELECT decode(upper(cp_sort_order1), 'PAYROLL NAME',attribute32,
	                       gre_name)
                     ,attribute34 --UOM
                     ,sum(value1)
                     ,sum(value2)
                 FROM pay_us_rpt_totals
                WHERE session_id=cp_session_id
                  AND business_group_id=cp_business_group_id
                  AND attribute31=cp_total_flag
                GROUP BY decode(upper(cp_sort_order1), 'PAYROLL NAME',attribute32,
	                       gre_name)
                        ,attribute34;
--
/**************************************************************
**CURSOR to get report total				     **
***************************************************************/
        CURSOR c_get_report_totals (cp_session_id IN NUMBER
                                   ,cp_business_group_id IN NUMBER
                                   ,cp_total_flag IN VARCHAR2
                                      ) IS
             SELECT attribute34 --UOM
                    ,sum(value1)
                    ,sum(value2)
                FROM pay_us_rpt_totals
               WHERE session_id=cp_session_id
                 AND business_group_id=cp_business_group_id
                 AND attribute31=cp_total_flag
               GROUP BY attribute34;
--
/*************************************************************
**          Local Variables                                 **
**************************************************************/
	    lv_consolidation_set_name      VARCHAR2(100);
	    lv_business_group_name         VARCHAR2(100);
	    lv_payroll_name                VARCHAR2(100);
	    lv_gre_name                    VARCHAR2(240);
	    lv_input_value_name            VARCHAR2(100);
	    lv_uom                         VARCHAR2(100);
	    ln_credit_amount               NUMBER;
	    ln_debit_amount                NUMBER;
	    lv_effective_date              DATE;
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

	    lv_segment_value               VARCHAR2(100);
	    lv_column_name                 VARCHAR2(100);

	    lv_accrual_type                VARCHAR2(100);
	    lv_cost_mode                   VARCHAR2(100);

            lv_gre_or_payroll              VARCHAR2(240);
            lv_session_id                  NUMBER;
            lv_credit_sum                  NUMBER;
            lv_debit_sum                   NUMBER;

            lv_start_date                  DATE;
            lv_END_date                    DATE;
            lv_costing_process_flag        VARCHAR2(1);
            lv_include_accruals            VARCHAR2(100);

	    l_tag		           VARCHAR2(2000);
	    l_count                        NUMBER;

	    lv_tagged_parameters           VARCHAR2(2000);
	    lv_tableHeadings               VARCHAR2(1000);
	    lv_total_heading               VARCHAR2(240);
	    lv_csr_heading                 VARCHAR2(240);

	    l_nodata_flag                  BOOLEAN DEFAULT TRUE;
	    l_rec_count                    NUMBER DEFAULT 0;

--
BEGIN
--
	gv_package_name :='pay_costing_summary_x_rep_pkg';
	hr_utility.set_location(gv_package_name || '.costing_summary', 10);
        hr_utility.trace('Start Date = '       || p_start_date);
	hr_utility.trace('End Date = '         || p_END_date);
        hr_utility.trace('Business Group ID = '|| p_business_group_id);
        hr_utility.trace('Costing Process = ' || p_costing);
        hr_utility.trace('Payroll ID = ' || p_payroll_id);
        hr_utility.trace('Consolidation Set ID = ' || p_consolidation_set_id);
        hr_utility.trace('Tax unit ID = ' || p_tax_unit_id);
        hr_utility.trace('Cost Type = ' || p_cost_type);
        hr_utility.trace('Sort Order 1 = ' || p_sort_order1);
        hr_utility.trace('Sort Order 2 = ' || p_sort_order2);

    lv_costing_process_flag := 'N';
    --Clearing the PL/SQL table of package pay_prl_xml_utils
    pay_prl_xml_utils.gXMLTable.DELETE;
--
    fnd_file.put_line(fnd_file.log,'Creating the XML...');

    --Creating a CLOB and opening the CLOB.
    DBMS_LOB.CREATETEMPORARY(g_xml_data,FALSE,DBMS_LOB.CALL);
    DBMS_LOB.OPEN(g_xml_data,dbms_lob.lob_readwrite);
--
    l_tag :='<?xml version="1.0"  encoding="UTF-8"?>';
    DBMS_LOB.WRITEAPPEND(g_xml_data, length(l_tag), l_tag);
--
    l_tag := '<PAYRPCSR>';
    DBMS_LOB.WRITEAPPEND(g_xml_data, length(l_tag), l_tag);
    fnd_file.put_line(fnd_file.log,'Started...');
--
    --Fill the Global PL/SQL table with the CostAllocation Keyflex's
    --enabled segments and their corresponding values.
    getNFillCostFlexSegments(p_business_group_id);
--
    OPEN c_get_organization_name(p_business_group_id);
       FETCH c_get_organization_name INTO lv_business_group_name;
    CLOSE c_get_organization_name;

    OPEN c_get_organization_name(p_tax_unit_id);
       FETCH c_get_organization_name INTO lv_gre_name;
    CLOSE c_get_organization_name;

    OPEN c_get_payroll_name(p_payroll_id);
       FETCH c_get_payroll_name INTO lv_payroll_name;
    CLOSE c_get_payroll_name;

    OPEN c_get_consolidation_set_name(p_consolidation_set_id);
       FETCH c_get_consolidation_set_name INTO lv_consolidation_set_name;
    CLOSE c_get_consolidation_set_name;

    hr_utility.set_location(gv_package_name || '.costing_summary', 30);

    lv_include_accruals:= nvl(hr_general.decode_lookup('PAY_PAYRPCBR',
                                                       p_cost_type),' ');

    IF p_costing IS NOT NULL THEN
         OPEN c_get_effective_date(TO_NUMBER(p_costing));
	      FETCH c_get_effective_date INTO lv_start_date;
         CLOSE c_get_effective_date;
         lv_END_date := lv_start_date;
         lv_costing_process_flag:='Y';
         hr_utility.trace('lv_start_date'|| lv_start_date);
    ELSE
         lv_start_date:=to_date(p_start_date, 'YYYY/MM/DD HH24:MI:SS');
         lv_END_date:=to_date(p_END_date, 'YYYY/MM/DD HH24:MI:SS');
         lv_costing_process_flag:='N';
    END IF;

    lv_tagged_parameters := getTaggedParameters(
                             p_business_group  => lv_business_group_name
			    ,p_start_date      =>lv_start_date
   			    ,p_end_date        =>lv_END_date
			    ,p_costing         =>p_costing
                            ,p_payroll_name    =>lv_payroll_name
                            ,p_consolidation_set_name
			                       =>lv_consolidation_set_name
                            ,p_gre_name        =>lv_gre_name
                            ,p_include_accruals=>lv_include_accruals
                            ,p_sort_order1     =>p_sort_order1
                            ,p_sort_order2     =>p_sort_order2
			    ,p_template_name   =>p_template_name
                            );
    /*Finding the headings of the tables*/
    IF p_sort_order1='Payroll Name' THEN
 	lv_csr_heading   :='Costing Summary Report - Payroll Totals';
 	lv_total_heading := 'Payroll Totals';
    ELSE
        lv_csr_heading   :='Costing Summary Report - GRE Totals';
        lv_total_heading := 'GRE Totals';
    END IF;

    lv_tableHeadings := pay_prl_xml_utils.getTag('CSR_GRE_OR_PAYROLL_HEADING',
                        lv_csr_heading)||
			pay_prl_xml_utils.getTag('GRE_OR_PAYROLL_TOTAL_HEADING',
			lv_total_heading);
    lv_tagged_parameters := lv_tagged_parameters || lv_tableHeadings;

/***********************************************************************
*   The following code is for populating the CLOB with the data of the *
*   Costing details of payrolls.                                        *
***********************************************************************/
--
    l_tag := '<LIST_G_ASG_COSTING_DETAILS>';
    DBMS_LOB.WRITEAPPEND(g_xml_data, length(l_tag), l_tag);
--
    OPEN c_get_session_id;
       FETCH c_get_session_id INTO lv_session_id;
    CLOSE c_get_session_id;
--
    -- Get the WHERE CLAUSE depending upon the parameters provided.
    c_clause1:=get_optional_where_clause(p_payroll_id,
                                        p_consolidation_set_id,
                                        p_tax_unit_id,
                                        lv_costing_process_flag,
                                        p_costing,
                                        p_cost_type);

    --Construct the Query depending on the WHERE CLAUSE.
    c_query := 'SELECT
		     pcd.payroll_name
		    ,pcd.gre_name
		    ,pcd.input_value_name
		    ,pcd.uom
		    ,sum(pcd.credit_amount)
		    ,sum(pcd.debit_amount)
		    ,pcd.cost_type
		    ,pcd.concatenated_segments
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
		FROM pay_costing_details_v pcd
	       WHERE
		     pcd.effective_date between :cp_start_date and :cp_end_date
		       ' || c_clause1 || '
		 and pcd.business_group_id = :cp_business_group_id
		GROUP BY pcd.payroll_name,pcd.gre_name
			,pcd.input_value_name
			,pcd.uom,pcd.cost_type
			,pcd.concatenated_segments
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
	       ORDER BY  pcd.cost_type
			,decode (upper(:cp_sort_order1), ''PAYROLL NAME'', pcd.payroll_name,
					pcd.gre_name)
			,decode(upper(:cp_sort_order2), ''GRE'', pcd.gre_name,''PAYROLL NAME'',
					pcd.payroll_name,''X'')
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
		        ,pcd.segment30';
         hr_utility.trace('Query is : '||c_query );
--
    --Opening the REFCURSOR for getting and populating into the XML variable.
    OPEN c_asg_costing_details
         FOR c_query USING TO_DATE(NVL(p_start_date,'0001/01/01 00:00:00'), 'YYYY/MM/DD HH24:MI:SS')
                      ,TO_DATE(nvl(p_end_date,'4712/12/31 00:00:00'), 'YYYY/MM/DD HH24:MI:SS')
		      ,p_business_group_id
                      ,p_sort_order1
                      ,p_sort_order2;
    LOOP
        FETCH c_asg_costing_details into
	                        lv_payroll_name
	                       ,lv_gre_name
                               ,lv_input_value_name
	                       ,lv_uom
	                       ,ln_credit_amount
	                       ,ln_debit_amount
	                       ,lv_cost_mode
	                       ,lv_concatenated_segments
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
	                       ,lv_segment30;

         IF c_asg_costing_details%NOTFOUND THEN
              hr_utility.set_location(gv_package_name || '.costing_summary', 60);

	      --If no data is returned from the cursor then need to populate the
	      --XML data with no values.
	      IF(l_nodata_flag = TRUE) THEN
	           lv_tagged_parameters := lv_tagged_parameters||
		                           pay_prl_xml_utils.getTag(
					   'C_G_ASG_COSTING_DETAILS_NODATA',
					   '1');
	           l_tag := '<G_ASG_COSTING_DETAILS>';

	           l_tag := l_tag||
	                    pay_prl_xml_utils.getTag('PAYROLL_NAME',NULL)||
			    pay_prl_xml_utils.getTag('GRE_NAME', NULL)||
		            pay_prl_xml_utils.getTag('INPUT_VALUE_NAME',
		                                      NULL)||
	                    pay_prl_xml_utils.getTag('UOM',NULL)||
	                    pay_prl_xml_utils.getTag('CREDIT_AMOUNT',NULL)||
		            pay_prl_xml_utils.getTag('DEBIT_AMOUNT',NULL)||
		            pay_prl_xml_utils.getTag('ACCRUAL_TYPE', NULL);

		   --Need to provide the Heading of the columns eventhough no data
		   --found.So here it's going to fill the Column heading data.
		   FOR i IN gtr_costing_segment.first .. gtr_costing_segment.last LOOP
	                    l_tag:= l_tag||'<G_ASG_COSTING_DETAILS_SEGMENT>'||
			            pay_prl_xml_utils.getTag('SEGMENT',INITCAP(
				    gtr_costing_segment(i).segment_label))||
                                    pay_prl_xml_utils.getTag('VALUE',NULL)||
				    '</G_ASG_COSTING_DETAILS_SEGMENT>';
		   END LOOP;
		   l_tag :=l_tag||'</G_ASG_COSTING_DETAILS>';
	           DBMS_LOB.WRITEAPPEND(g_xml_data, length(l_tag), l_tag);
	      END IF;
              EXIT;
         END IF;
--
         --If no data is there, then need to fill one NodataFound Flag
	 -- in the XML output.
         l_nodata_flag := FALSE;
	 IF(l_rec_count = 0) THEN
		lv_tagged_parameters := lv_tagged_parameters||
		                        pay_prl_xml_utils.getTag(
		                        'C_G_ASG_COSTING_DETAILS_NODATA',
					'0');
	 END IF;
	 l_rec_count := l_rec_count + 1;
         lv_accrual_type:=nvl(hr_general.decode_lookup('PAY_PAYRPCBR',lv_cost_mode),' ');
	 /*insert into pay_us_rpt_totals*/
	 insert into pay_us_rpt_totals(session_id,business_group_id,gre_name,value1 ,value2 ,attribute1,attribute2
                                    ,attribute3,attribute4,attribute5,attribute6,attribute7,attribute8
                                    ,attribute9,attribute10,attribute11,attribute12,attribute13
                                    ,attribute14,attribute15,attribute16,attribute17,attribute18
                                    ,attribute19,attribute20,attribute21,attribute22,attribute23
                                    ,attribute24,attribute25,attribute26,attribute27,attribute28
                                    ,attribute29,attribute30,attribute31,attribute32,attribute33
                                    ,attribute34) values
                         (lv_session_id            -- session ID is passed
                         ,p_business_group_id
                         ,lv_gre_name
                         ,ln_credit_amount
                         ,ln_debit_amount
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
                         ,'CSR'     --attribute31               -- denotes that the record is for Costing Summary Report
                         ,lv_payroll_name --attribute32
                         ,lv_concatenated_segments --attribute33
                         ,lv_uom --attribute34
			 );


	 hr_utility.set_location(gv_package_name || '.costing_summary', 70);

         --Filling the data along with the XML tags into the local XML
	 --data variable.
	 l_tag := '<G_ASG_COSTING_DETAILS>';

	 l_tag := l_tag||
	          pay_prl_xml_utils.getTag('PAYROLL_NAME',lv_payroll_name)||
		  pay_prl_xml_utils.getTag('GRE_NAME', lv_gre_name)||
		  pay_prl_xml_utils.getTag('INPUT_VALUE_NAME',
		                            lv_input_value_name)||
	          pay_prl_xml_utils.getTag('UOM',lv_uom)||
	          pay_prl_xml_utils.getTag('CREDIT_AMOUNT',ln_credit_amount)||
		  pay_prl_xml_utils.getTag('DEBIT_AMOUNT',ln_debit_amount)||
		  pay_prl_xml_utils.getTag('ACCRUAL_TYPE', lv_accrual_type);

         DBMS_LOB.WRITEAPPEND(g_xml_data, length(l_tag), l_tag);

	 l_count := 1;

	 --Filling the Cost Allocation KFF Values into the XML data Variable.
	 FOR i IN gtr_costing_segment.first .. gtr_costing_segment.last LOOP
	           IF gtr_costing_segment(i).column_name = 'SEGMENT1' THEN
                      lv_segment_value := lv_segment1;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT2' THEN
                      lv_segment_value := lv_segment2;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT3' THEN
                      lv_segment_value := lv_segment3;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT4' THEN
                      lv_segment_value := lv_segment4;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT5' THEN
                      lv_segment_value := lv_segment5;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT6' THEN
                      lv_segment_value := lv_segment6;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT7' THEN
                      lv_segment_value := lv_segment7;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT8' THEN
                      lv_segment_value := lv_segment8;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT9' THEN
                      lv_segment_value := lv_segment9;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT10' THEN
                      lv_segment_value := lv_segment10;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT11' THEN
                      lv_segment_value := lv_segment11;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT12' THEN
                      lv_segment_value := lv_segment12;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT13' THEN
                      lv_segment_value := lv_segment13;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT14' THEN
                      lv_segment_value := lv_segment14;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT15' THEN
                      lv_segment_value := lv_segment15;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT16' THEN
                      lv_segment_value := lv_segment16;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT17' THEN
                      lv_segment_value := lv_segment17;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT18' THEN
                      lv_segment_value := lv_segment18;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT19' THEN
                      lv_segment_value := lv_segment19;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT20' THEN
                      lv_segment_value := lv_segment20;
		  elsIF gtr_costing_segment(i).column_name = 'SEGMENT21' THEN
                      lv_segment_value := lv_segment21;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT22' THEN
                      lv_segment_value := lv_segment22;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT23' THEN
                      lv_segment_value := lv_segment23;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT24' THEN
                      lv_segment_value := lv_segment24;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT25' THEN
                      lv_segment_value := lv_segment25;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT26' THEN
                      lv_segment_value := lv_segment26;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT27' THEN
                      lv_segment_value := lv_segment27;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT28' THEN
                      lv_segment_value := lv_segment28;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT29' THEN
                      lv_segment_value := lv_segment29;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT30' THEN
                      lv_segment_value := lv_segment30;
                   END IF;

                   pay_prl_xml_utils.gXMLTable(l_count).Name  := INITCAP(
				  gtr_costing_segment(i).segment_label);
	           pay_prl_xml_utils.gXMLTable(l_count).Value := lv_segment_value;

	           l_count  := l_count  + 1;

         END LOOP ;

	 pay_prl_xml_utils.twoColumnar(p_type     => 'G_ASG_COSTING_DETAILS_SEGMENT'
	                              ,p_data     => pay_prl_xml_utils.gXMLTable
				      ,p_count    => l_count
				      ,p_xml_data => g_xml_data);
	 pay_prl_xml_utils.gXMLTable.delete;

	 l_tag := '</G_ASG_COSTING_DETAILS>';

	 --Appending the XML data into the Global XML data variable.
	 DBMS_LOB.WRITEAPPEND(g_xml_data, length(l_tag), l_tag);

    END LOOP;
    CLOSE c_asg_costing_details;

    l_tag := '</LIST_G_ASG_COSTING_DETAILS>';
    DBMS_LOB.WRITEAPPEND(g_xml_data, length(l_tag), l_tag);

/********************************************************************
*   This code is for populating the XML with the Costing Summary    *
*   Report for GRE/Payroll Depends on the parameter.                *
********************************************************************/

    pay_prl_xml_utils.gXMLTable.delete;

    l_nodata_flag := TRUE;
    l_rec_count := 0;

    l_tag := '<LIST_G_CSR_GRE_OR_PRL_TOTAL>';
    DBMS_LOB.WRITEAPPEND(g_xml_data, length(l_tag), l_tag);


    --Opening the Cursor for the data of the Second table
    --i.e., Costing Summary Details Table
    OPEN c_costing_summary_rpt_details (lv_session_id
                                         ,p_business_group_id
                                         ,'CSR'
                                         ,p_sort_order1
                                         ,p_sort_order2
                                         );
    LOOP
         FETCH c_costing_summary_rpt_details into
                                     lv_gre_or_payroll
                                    ,lv_uom
                                    ,ln_credit_amount
                                    ,ln_debit_amount
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
                                    ,lv_segment30;
         IF c_costing_summary_rpt_details % NOTFOUND THEN
              hr_utility.set_location(gv_package_name || '.costing_summary', 100);

	      --If no data is returned from the cursor then need to populate the
	      --XML data with no values.
	      IF(l_nodata_flag = TRUE) THEN

	           lv_tagged_parameters := lv_tagged_parameters||
		                           pay_prl_xml_utils.getTag(
					   'C_G_CSR_GRE_OR_PRL_TOTAL_NODATA',
					   '1');
     	           l_tag := '<G_CSR_GRE_OR_PRL_TOTAL>';
	           l_tag := l_tag||
	                    pay_prl_xml_utils.getTag('GRE_OR_PAYROLL',NULL)||
	                    pay_prl_xml_utils.getTag('UOM',NULL)||
	                    pay_prl_xml_utils.getTag('CREDIT_AMOUNT',NULL)||
		            pay_prl_xml_utils.getTag('DEBIT_AMOUNT',NULL);

		   --Need to provide the Heading of the columns eventhough no data
		   --found.So here it's going to fill the Column heading data.
		   FOR i IN gtr_costing_segment.first .. gtr_costing_segment.last LOOP
	                    l_tag := l_tag ||'<G_CSR_GRE_OR_PRL_TOTAL_SEGMENT>'||
			             pay_prl_xml_utils.getTag('SEGMENT',INITCAP(
				     gtr_costing_segment(i).segment_label))||
                                     pay_prl_xml_utils.getTag('VALUE',NULL)||
				     '</G_CSR_GRE_OR_PRL_TOTAL_SEGMENT>';
		   END LOOP;

		   l_tag :=l_tag ||'</G_CSR_GRE_OR_PRL_TOTAL>';

	           DBMS_LOB.WRITEAPPEND(g_xml_data, length(l_tag), l_tag);
              END IF;

              EXIT;
      END IF;

         --If no data is there, then need to fill one NodataFound Flag
	 -- in the XML output.
	 l_nodata_flag := FALSE;
	 IF(l_rec_count = 0)THEN
		lv_tagged_parameters := lv_tagged_parameters||
		                        pay_prl_xml_utils.getTag(
				        'C_G_CSR_GRE_OR_PRL_TOTAL_NODATA',
					'0');
	 END IF;
         l_rec_count := l_rec_count + 1;

	 --Filling the data along with the XML tags into the local XML
	 --data variable.
	 l_tag := '<G_CSR_GRE_OR_PRL_TOTAL>';

	 l_tag := l_tag||
	          pay_prl_xml_utils.getTag('GRE_OR_PAYROLL',lv_gre_or_payroll)||
	          pay_prl_xml_utils.getTag('UOM',lv_uom)||
	          pay_prl_xml_utils.getTag('CREDIT_AMOUNT',ln_credit_amount)||
		  pay_prl_xml_utils.getTag('DEBIT_AMOUNT',ln_debit_amount);

         DBMS_LOB.WRITEAPPEND(g_xml_data, length(l_tag), l_tag);

	 l_count := 1;
	 --Filling the Cost Allocation KFF Values into the XML data Variable.
         FOR i IN gtr_costing_segment.first .. gtr_costing_segment.last LOOP
	           IF gtr_costing_segment(i).column_name = 'SEGMENT1' THEN
                      lv_segment_value := lv_segment1;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT2' THEN
                      lv_segment_value := lv_segment2;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT3' THEN
                      lv_segment_value := lv_segment3;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT4' THEN
                      lv_segment_value := lv_segment4;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT5' THEN
                      lv_segment_value := lv_segment5;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT6' THEN
                      lv_segment_value := lv_segment6;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT7' THEN
                      lv_segment_value := lv_segment7;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT8' THEN
                      lv_segment_value := lv_segment8;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT9' THEN
                      lv_segment_value := lv_segment9;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT10' THEN
                      lv_segment_value := lv_segment10;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT11' THEN
                      lv_segment_value := lv_segment11;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT12' THEN
                      lv_segment_value := lv_segment12;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT13' THEN
                      lv_segment_value := lv_segment13;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT14' THEN
                      lv_segment_value := lv_segment14;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT15' THEN
                      lv_segment_value := lv_segment15;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT16' THEN
                      lv_segment_value := lv_segment16;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT17' THEN
                      lv_segment_value := lv_segment17;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT18' THEN
                      lv_segment_value := lv_segment18;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT19' THEN
                      lv_segment_value := lv_segment19;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT20' THEN
                      lv_segment_value := lv_segment20;
  	           elsIF gtr_costing_segment(i).column_name = 'SEGMENT21' THEN
                      lv_segment_value := lv_segment21;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT22' THEN
                      lv_segment_value := lv_segment22;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT23' THEN
                      lv_segment_value := lv_segment23;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT24' THEN
                      lv_segment_value := lv_segment24;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT25' THEN
                      lv_segment_value := lv_segment25;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT26' THEN
                      lv_segment_value := lv_segment26;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT27' THEN
                      lv_segment_value := lv_segment27;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT28' THEN
                      lv_segment_value := lv_segment28;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT29' THEN
                      lv_segment_value := lv_segment29;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT30' THEN
                      lv_segment_value := lv_segment30;
                   END IF;

                   pay_prl_xml_utils.gXMLTable(l_count).Name  := INITCAP(
				  gtr_costing_segment(i).segment_label);
	           pay_prl_xml_utils.gXMLTable(l_count).Value := lv_segment_value;

	           l_count  := l_count  + 1;

         END LOOP ;

	 pay_prl_xml_utils.twoColumnar(p_type     => 'G_CSR_GRE_OR_PRL_TOTAL_SEGMENT'
	                              ,p_data     => pay_prl_xml_utils.gXMLTable
				      ,p_count    => l_count
				      ,p_xml_data => g_xml_data);
	 pay_prl_xml_utils.gXMLTable.delete;

	 l_tag := '</G_CSR_GRE_OR_PRL_TOTAL>';

	 --Appending the XML data into the Global XML data variable.
	 DBMS_LOB.WRITEAPPEND(g_xml_data, length(l_tag), l_tag);

    END LOOP;
    CLOSE  c_costing_summary_rpt_details;

    l_tag := '</LIST_G_CSR_GRE_OR_PRL_TOTAL>';
    DBMS_LOB.WRITEAPPEND(g_xml_data, length(l_tag), l_tag);

/********************************************************************
**  This code is for populating the XML with the Costing Summary   **
**  Report for GRE/Payroll totals Depends on the parameter.        **
********************************************************************/

    pay_prl_xml_utils.gXMLTable.delete;

    l_nodata_flag := TRUE;
    l_rec_count := 0;
    l_tag := '<LIST_G_GRE_OR_PRL_TOTAL>';
    DBMS_LOB.WRITEAPPEND(g_xml_data, length(l_tag), l_tag);

    --Opening the Cursor for the data of the Third table
    --i.e., GRE/Payroll Totals Table
    OPEN c_get_gre_or_payroll_totals (lv_session_id
                                       ,p_business_group_id
                                       ,'CSR'
                                       ,p_sort_order1
                                       );
    LOOP

         FETCH c_get_gre_or_payroll_totals INTO lv_gre_or_payroll
                                            ,lv_uom
                                            ,ln_credit_amount
                                            ,ln_debit_amount;
         IF c_get_gre_or_payroll_totals%NOTFOUND THEN
              hr_utility.set_location(gv_package_name ||
	                              '.costing_summary', 90);

	      --If no data is returned from the cursor then need to populate the
	      --XML data with no values.
	      IF(l_nodata_flag=TRUE) THEN
	           lv_tagged_parameters := lv_tagged_parameters||
		                        pay_prl_xml_utils.getTag(
				        'C_G_GRE_OR_PRL_TOTAL_NODATA',
					'1');
	           l_tag := '<G_GRE_OR_PRL_TOTAL>';
	           l_tag := l_tag||
	                    pay_prl_xml_utils.getTag('GRE_OR_PAYROLL',NULL)||
	                    pay_prl_xml_utils.getTag('CREDIT_AMOUNT',NULL)||
		            pay_prl_xml_utils.getTag('DEBIT_AMOUNT',NULL)||
		            pay_prl_xml_utils.getTag('UOM',NULL)||
		            '</G_GRE_OR_PRL_TOTAL>';
	           DBMS_LOB.WRITEAPPEND(g_xml_data, length(l_tag), l_tag);
	      END IF;
              EXIT;
         END IF;

         --If no data is there, then need to fill one NodataFound Flag
	 -- in the XML output.
	 l_nodata_flag := FALSE;
	 IF(l_rec_count = 0)THEN
		lv_tagged_parameters := lv_tagged_parameters||
		                        pay_prl_xml_utils.getTag(
				        'C_G_GRE_OR_PRL_TOTAL_NODATA',
					'0');
	 END IF;
	 l_rec_count := l_rec_count + 1;
         l_count := 1;
	 pay_prl_xml_utils.gXMLTable(l_count).Name  := 'GRE_OR_PAYROLL';
	 pay_prl_xml_utils.gXMLTable(l_count).Value := lv_gre_or_payroll;
	 l_count := l_count + 1;

	 pay_prl_xml_utils.gXMLTable(l_count).Name  := 'CREDIT_AMOUNT';
	 pay_prl_xml_utils.gXMLTable(l_count).Value := ln_credit_amount;
	 l_count := l_count + 1;

	 pay_prl_xml_utils.gXMLTable(l_count).Name  := 'DEBIT_AMOUNT';
	 pay_prl_xml_utils.gXMLTable(l_count).Value := ln_debit_amount;
	 l_count := l_count + 1;

	 pay_prl_xml_utils.gXMLTable(l_count).Name  := 'UOM';
	 pay_prl_xml_utils.gXMLTable(l_count).Value := lv_uom;

	 --Appending the XML data into the Global XML data variable by
	 --invoking the multiColumnar in the pay_prl_xml_utils package.
	 pay_prl_xml_utils.multiColumnar(
	                   'G_GRE_OR_PRL_TOTAL',
			   pay_prl_xml_utils.gXMLTable,
			   l_count,
			   g_xml_data);
	 pay_prl_xml_utils.gXMLTable.delete;

    END LOOP;
    CLOSE c_get_gre_or_payroll_totals;

    l_tag := '</LIST_G_GRE_OR_PRL_TOTAL>';
    DBMS_LOB.WRITEAPPEND(g_xml_data, length(l_tag), l_tag);

/********************************************************************
*   This code is for populating the XML with the Costing Summary    *
*   Report for Grand Totals.                                        *
********************************************************************/

    pay_prl_xml_utils.gXMLTable.delete;

    l_nodata_flag := TRUE;
    l_rec_count := 0;
    l_tag := '<LIST_G_CSR_GRAND_TOTAL>';
    DBMS_LOB.WRITEAPPEND(g_xml_data, length(l_tag), l_tag);

    --Opening the Cursor for the data of the Fourth table
    --i.e., Costing Summary Report - Grand Totals Table
    OPEN c_costing_grand_totals (lv_session_id
                                  ,p_business_group_id
                                  ,'CSR'
                                  );
    LOOP
         FETCH c_costing_grand_totals into   lv_uom
                                         ,ln_credit_amount
                                         ,ln_debit_amount
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
                                         ,lv_segment30;

         lv_credit_sum:= lv_credit_sum + ln_credit_amount;
         lv_debit_sum:= lv_debit_sum + ln_debit_amount;

          IF c_costing_grand_totals%NOTFOUND THEN
              hr_utility.set_location(gv_package_name ||
	                              '.costing_summary', 120);

	      IF (l_nodata_flag = TRUE)THEN
	            lv_tagged_parameters := lv_tagged_parameters||
		                           pay_prl_xml_utils.getTag(
					   'C_G_CSR_GRAND_TOTAL_NODATA',
					   '1');
		   l_tag := '<G_CSR_GRAND_TOTAL>';

	           l_tag := l_tag||
	                    pay_prl_xml_utils.getTag('UOM',NULL)||
	                    pay_prl_xml_utils.getTag('CREDIT_AMOUNT',NULL)||
		            pay_prl_xml_utils.getTag('DEBIT_AMOUNT',NULL);

	           FOR i IN gtr_costing_segment.first .. gtr_costing_segment.last LOOP
	                    l_tag := l_tag ||'<G_CSR_GRAND_TOTAL_SEGMENT>'||
			             pay_prl_xml_utils.getTag('SEGMENT',INITCAP(
				     gtr_costing_segment(i).segment_label))||
                                     pay_prl_xml_utils.getTag('VALUE',NULL)||
				     '</G_CSR_GRAND_TOTAL_SEGMENT>';
		   END LOOP;
	           l_tag := l_tag ||'</G_CSR_GRAND_TOTAL>';
                   DBMS_LOB.WRITEAPPEND(g_xml_data, length(l_tag), l_tag);
	      END IF;
              EXIT;
         END IF;

         l_nodata_flag := FALSE;
	 IF(l_rec_count = 0) THEN
		lv_tagged_parameters := lv_tagged_parameters||
		                        pay_prl_xml_utils.getTag(
					'C_G_CSR_GRAND_TOTAL_NODATA',
					'0');
	 END IF;
	 l_rec_count := l_rec_count + 1;
	 l_tag := '<G_CSR_GRAND_TOTAL>';

	 l_tag := l_tag||
	          pay_prl_xml_utils.getTag('UOM',lv_uom)||
	          pay_prl_xml_utils.getTag('CREDIT_AMOUNT',ln_credit_amount)||
		  pay_prl_xml_utils.getTag('DEBIT_AMOUNT',ln_debit_amount);

	 DBMS_LOB.WRITEAPPEND(g_xml_data, length(l_tag), l_tag);

	 l_count := 1;
	 FOR i IN gtr_costing_segment.first .. gtr_costing_segment.last LOOP
	           IF gtr_costing_segment(i).column_name = 'SEGMENT1' THEN
                      lv_segment_value := lv_segment1;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT2' THEN
                      lv_segment_value := lv_segment2;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT3' THEN
                      lv_segment_value := lv_segment3;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT4' THEN
                      lv_segment_value := lv_segment4;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT5' THEN
                      lv_segment_value := lv_segment5;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT6' THEN
                      lv_segment_value := lv_segment6;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT7' THEN
                      lv_segment_value := lv_segment7;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT8' THEN
                      lv_segment_value := lv_segment8;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT9' THEN
                      lv_segment_value := lv_segment9;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT10' THEN
                      lv_segment_value := lv_segment10;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT11' THEN
                      lv_segment_value := lv_segment11;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT12' THEN
                      lv_segment_value := lv_segment12;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT13' THEN
                      lv_segment_value := lv_segment13;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT14' THEN
                      lv_segment_value := lv_segment14;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT15' THEN
                      lv_segment_value := lv_segment15;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT16' THEN
                      lv_segment_value := lv_segment16;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT17' THEN
                      lv_segment_value := lv_segment17;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT18' THEN
                      lv_segment_value := lv_segment18;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT19' THEN
                      lv_segment_value := lv_segment19;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT20' THEN
                      lv_segment_value := lv_segment20;
		   elsIF gtr_costing_segment(i).column_name = 'SEGMENT21' THEN
                      lv_segment_value := lv_segment21;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT22' THEN
                      lv_segment_value := lv_segment22;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT23' THEN
                      lv_segment_value := lv_segment23;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT24' THEN
                      lv_segment_value := lv_segment24;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT25' THEN
                      lv_segment_value := lv_segment25;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT26' THEN
                      lv_segment_value := lv_segment26;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT27' THEN
                      lv_segment_value := lv_segment27;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT28' THEN
                      lv_segment_value := lv_segment28;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT29' THEN
                      lv_segment_value := lv_segment29;
                   elsIF gtr_costing_segment(i).column_name = 'SEGMENT30' THEN
                      lv_segment_value := lv_segment30;
                   END IF;

                   pay_prl_xml_utils.gXMLTable(l_count).Name  := INITCAP(
				  gtr_costing_segment(i).segment_label);
	           pay_prl_xml_utils.gXMLTable(l_count).Value := lv_segment_value;

	           l_count  := l_count  + 1;

         END LOOP ;

	 pay_prl_xml_utils.twoColumnar(p_type     => 'G_CSR_GRAND_TOTAL_SEGMENT'
	                              ,p_data     => pay_prl_xml_utils.gXMLTable
				      ,p_count    => l_count
				      ,p_xml_data => g_xml_data);

	 pay_prl_xml_utils.gXMLTable.delete;

	 l_tag := '</G_CSR_GRAND_TOTAL>';
	 DBMS_LOB.WRITEAPPEND(g_xml_data, length(l_tag), l_tag);

    END LOOP;
    CLOSE c_costing_grand_totals;

    l_tag := '</LIST_G_CSR_GRAND_TOTAL>';
    DBMS_LOB.WRITEAPPEND(g_xml_data, length(l_tag), l_tag);

/********************************************************************
*   This code is for populating the XML with the Costing Summary    *
*   Report for Report Totals.                                        *
********************************************************************/

    pay_prl_xml_utils.gXMLTable.delete;
    l_rec_count := 0;

    l_tag := '<LIST_G_REPORT_TOTAL>';
    DBMS_LOB.WRITEAPPEND(g_xml_data, length(l_tag), l_tag);

    hr_utility.trace('Session id : '||lv_session_id);
    OPEN c_get_report_totals(lv_session_id,p_business_group_id,'CSR');
    LOOP
         FETCH c_get_report_totals INTO
              lv_uom
             ,lv_credit_sum
             ,lv_debit_sum;

         IF c_get_report_totals%NOTFOUND THEN
              hr_utility.set_location(gv_package_name || '.costing_summary', 150);
              IF (l_nodata_flag = TRUE) THEN
		   lv_tagged_parameters := lv_tagged_parameters||
		                        pay_prl_xml_utils.getTag(
					'C_G_REPORT_TOTAL_NODATA',
					'1');
	           l_tag := '<G_REPORT_TOTAL>';
	           l_tag := l_tag||
	                    pay_prl_xml_utils.getTag('CREDIT_AMOUNT',NULL)||
		            pay_prl_xml_utils.getTag('DEBIT_AMOUNT',NULL)||
		            pay_prl_xml_utils.getTag('UOM',NULL)||
		            '</G_REPORT_TOTAL>';

	           DBMS_LOB.WRITEAPPEND(g_xml_data, length(l_tag), l_tag);
	      END IF;
              EXIT;
         END IF;

	 l_nodata_flag := FALSE;

	 IF(l_rec_count = 0) THEN
		lv_tagged_parameters := lv_tagged_parameters||
		                        pay_prl_xml_utils.getTag(
					'C_G_REPORT_TOTAL_NODATA',
					'0');
	 END IF;
	 l_rec_count := l_rec_count + 1;

	 l_count := 1;
	 pay_prl_xml_utils.gXMLTable(l_count).Name  := 'CREDIT_AMOUNT';
	 pay_prl_xml_utils.gXMLTable(l_count).Value := lv_credit_sum;
	 l_count := l_count + 1;

	 pay_prl_xml_utils.gXMLTable(l_count).Name  := 'DEBIT_AMOUNT';
	 pay_prl_xml_utils.gXMLTable(l_count).Value := lv_debit_sum;
	 l_count := l_count + 1;

	 pay_prl_xml_utils.gXMLTable(l_count).Name  := 'UOM';
	 pay_prl_xml_utils.gXMLTable(l_count).Value := lv_uom;

	 pay_prl_xml_utils.multiColumnar(
	                   'G_REPORT_TOTAL',
			   pay_prl_xml_utils.gXMLTable,
			   l_count,
			   g_xml_data);
	 pay_prl_xml_utils.gXMLTable.delete;

    END LOOP;
    CLOSE c_get_report_totals;

    l_tag := '</LIST_G_REPORT_TOTAL>';
    DBMS_LOB.WRITEAPPEND(g_xml_data, length(l_tag), l_tag);

    DBMS_LOB.WRITEAPPEND(g_xml_data, length(lv_tagged_parameters),
                         lv_tagged_parameters);

    l_tag := '</PAYRPCSR>';
    DBMS_LOB.WRITEAPPEND(g_xml_data, length(l_tag), l_tag);

    DELETE FROM pay_us_rpt_totals where attribute31='CSR';

    p_xml := g_xml_data;


--
END costing_summary;
--
--
END pay_costing_summary_x_rep_pkg;

/
