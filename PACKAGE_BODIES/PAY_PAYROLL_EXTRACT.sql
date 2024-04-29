--------------------------------------------------------
--  DDL for Package Body PAY_PAYROLL_EXTRACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYROLL_EXTRACT" as
/* $Header: payextract.pkb 120.3 2007/02/23 13:54:55 jdevasah noship $ */

 /******************************************************************
  ** private package global declarations
  ******************************************************************/

  g_package               VARCHAR2(50)  := 'pay_payroll_extract';
  g_debug                 boolean       := FALSE;

   -- Enter procedure, function bodies as shown below

   --FUNCTION get_xmldoc_clob
   --  ( p_payroll_action_id IN varchar2
   --    ) RETURN CLOB IS

   FUNCTION get_xmldoc_clob
     ( p_payroll_action_id IN varchar2,
       p_process_type IN Varchar2,
       p_assignment_set_id IN Varchar2,
       p_element_set_id IN Varchar2) RETURN CLOB IS

     l_proc          VARCHAR2(100) := g_package||'.get_xmldoc_clob';
     tmp_clob CLOB;
     l_query  VARCHAR2(32000);
     l_qryCtx DBMS_XMLGEN.ctxHandle;
     storage_limit integer;
     clob_length number;

     lv_assignment_set_id varchar2(30);
     lv_element_set_id varchar2(30);
     rowKount Number(10);
     noDataFound exception;

   BEGIN

        hr_utility.trace('Entering '||l_proc);

        hr_utility.trace('p_payroll_action_id ='||p_payroll_action_id);
        hr_utility.trace('p_process_type ='||p_process_type);
        hr_utility.trace('p_assignment_set_id ='||p_assignment_set_id);
        hr_utility.trace('p_element_set_id ='||p_element_set_id);
        if p_assignment_set_id is null then
           lv_assignment_set_id := 'NULL';
        else
           lv_assignment_set_id := p_assignment_set_id;
        end if;
        hr_utility.trace('lv_assignment_set_id ='||lv_assignment_set_id);

        if p_element_set_id is null then
           lv_element_set_id := 'NULL';
        else
           lv_element_set_id := p_element_set_id;
        end if;
        hr_utility.trace('lv_element_set_id ='||lv_element_set_id);

        -- Original Query without Assignment Set and Element Set
        --
/*
        l_query := 'SELECT payroll_name as "@Payroll"
        ,ppa.effective_date as "@Date_Paid"
        ,full_name as "@Name"
        ,assignment_number as "@Assignment_Number"
        ,paf.assignment_id as "@Assignment_Id"
        ,run_type_name as "@Run_Type"
        ,element_name as "@Element"
        ,jurisdiction_code as "@Jurisdiction"
        ,NAME as "@Input_Value"
        ,result_value as "@Run_Result"
        ,balance_name as "@Balance"
        ,DECODE(scale,1, ''+'', -1, ''-'') as "@ADD_Subtract"
        ,pp.person_id as "@person_id"
        FROM pay_payrolls_f ppf
        ,pay_payroll_actions ppa
        ,pay_assignment_actions paa
        ,per_assignments_f paf
        ,pay_run_results prr
        ,per_people_f pp
        ,pay_run_result_values prv
        ,pay_element_types_f pet
        ,pay_input_values_f piv
        ,pay_balance_types bt
        ,pay_balance_feeds_f bf
        ,pay_run_types_f rt
        WHERE  ppa.payroll_action_id = '||p_payroll_action_id ||'
        AND ppa.payroll_id = ppf.payroll_id
        and paa.payroll_action_id = ppa.payroll_action_id
        AND ppa.effective_date BETWEEN ppf.effective_start_date
                           AND ppf.effective_end_date
        and ppf.payroll_id = paf.payroll_id
        AND paf.person_id = pp.person_id
        AND ppa.effective_date BETWEEN pp.effective_start_date
                               AND pp.effective_end_date
        AND ppa.effective_date BETWEEN paf.effective_start_date
                               AND paf.effective_end_date
        AND paf.assignment_id = paa.assignment_id
        AND prr.assignment_action_id  = paa.assignment_action_id
        AND pet.element_type_id  = prr.element_type_id
        AND ppa.effective_date BETWEEN pet.effective_start_date
                               AND  pet.effective_end_date
        AND prr.run_result_id = prv.run_result_id
        AND piv.input_value_id  = prv.input_value_id
        AND ppa.effective_date BETWEEN piv.effective_start_date
                               AND piv.effective_end_date
        AND piv.input_value_id = bf.input_value_id
        AND bt.balance_type_id  = bf.balance_type_id
        AND ppa.effective_date BETWEEN bf.effective_start_date
                               AND bf.effective_end_date
        AND rt.run_type_id = NVL(paa.run_type_id, ppa.run_type_id)
        union all
        SELECT payroll_name Payroll
        ,ppa.effective_date Date_Paid
        ,full_name Name
        ,assignment_number Assignment_Number
        ,paf.assignment_id Assignment_Id
        ,NULL Run_Type
        ,NULL Element
        ,NULL Jurisdiction
        ,NULL Input_Value
        ,NULL Run_Result
        ,NULL Balance
        ,NULL ADD_Subtract
        ,pp.person_id person_id
        FROM pay_payrolls_f ppf
        ,pay_payroll_actions ppa
        ,per_people_f pp
        ,per_assignments_f paf
        where
        ppa.payroll_action_id = '||p_payroll_action_id ||'
        AND ppa.payroll_id = ppf.payroll_id
        AND ppa.effective_date BETWEEN ppf.effective_start_date
                               AND ppf.effective_end_date
        and ppf.payroll_id = paf.payroll_id
        AND paf.person_id = pp.person_id
        AND ppa.effective_date BETWEEN pp.effective_start_date
                               AND pp.effective_end_date
        AND ppa.effective_date BETWEEN paf.effective_start_date
                               AND paf.effective_end_date
        AND not exists ( select 1 from pay_assignment_actions paa
                          where paf.assignment_id = paa.assignment_id
                           and  paa.payroll_action_id = '||p_payroll_action_id ||' )
        ORDER BY  1,2,13, 5, 7, 9, 11';

*/
     /* Bug# 5886859 if process type = tax
                      extract in balance mode
		else extract balance and element mode */
     if(p_process_type = 'TAX') then
      l_query := 'SELECT  full_name as "@Name"
        ,assignment_number as "@Assignment_Number"
        ,paf.assignment_id as "@Assignment_Id"
        ,balance_name as "@Balance"
        ,sum(nvl(result_value,0)) as "@Run_Result"
        FROM pay_payrolls_f ppf
        ,pay_payroll_actions ppa
        ,pay_assignment_actions paa
        ,per_assignments_f paf
        ,pay_run_results prr
        ,per_people_f pp
        ,pay_run_result_values prv
        ,pay_element_types_f pet
        ,pay_balance_types bt
        ,pay_balance_feeds_f bf
        ,pay_run_types_f rt
        WHERE  ppa.payroll_action_id = '||p_payroll_action_id ||'
        AND ppa.payroll_id = ppf.payroll_id
        and paa.payroll_action_id = ppa.payroll_action_id
        AND ppa.effective_date BETWEEN ppf.effective_start_date
                           AND ppf.effective_end_date
        and ppf.payroll_id = paf.payroll_id
        AND paf.person_id = pp.person_id
        AND ppa.effective_date BETWEEN pp.effective_start_date
                               AND pp.effective_end_date
        AND ppa.effective_date BETWEEN paf.effective_start_date
                               AND paf.effective_end_date
        AND paf.assignment_id = paa.assignment_id
        AND prr.assignment_action_id  = paa.assignment_action_id
        AND pet.element_type_id  = prr.element_type_id
        AND ppa.effective_date BETWEEN pet.effective_start_date
                               AND  pet.effective_end_date
        AND prr.run_result_id = prv.run_result_id
	AND prv.input_value_id = bf.input_value_id
	AND prv.input_value_id in (
		  select input_value_id
	    from pay_input_values_f piv
	   where ppa.effective_date BETWEEN piv.effective_start_date
                               AND piv.effective_end_date)
        AND bt.balance_type_id  = bf.balance_type_id
        AND ppa.effective_date BETWEEN bf.effective_start_date
                               AND bf.effective_end_date
        AND rt.run_type_id = NVL(paa.run_type_id, ppa.run_type_id)
        and ('||lv_assignment_set_id ||' is NULL
             or ( '||lv_assignment_set_id ||' is not NULL
                 and '||lv_assignment_set_id ||' in
                    (select assignment_set_id
                       from hr_assignment_set_amendments hasa
                      where hasa.assignment_set_id = '||lv_assignment_set_id ||'
                        and paf.assignment_id = hasa.assignment_id
                   )
               )
             )
        and ('||lv_element_set_id ||' is null
                or ('||lv_element_set_id ||' is not null
                    and exists
                        (select ''x'' from pay_element_type_rules petr
                           where petr.element_set_id = '||lv_element_set_id ||'
                             and petr.element_type_id = pet.element_type_id
                             and petr.include_or_exclude = ''I''
                         union all
                          select ''x'' from pay_element_types_f pet1
                           where pet1.classification_id in
                                 (select classification_id
                                    from pay_ele_classification_rules
                                   where element_set_id = '||lv_element_set_id ||')
                             and pet1.element_type_id = pet.element_type_id
                         minus
                          select ''x'' from pay_element_type_rules petr
                           where petr.element_set_id = '||lv_element_set_id ||'
                             and petr.element_type_id = pet.element_type_id
                             and petr.include_or_exclude = ''E''
                        )
                   )
            )
        group by pp.person_id,paf.assignment_id,balance_name,full_name,assignment_number
        ORDER BY  3, 4';
     else
        l_query := 'SELECT payroll_name as "@Payroll"
        ,ppa.effective_date as "@Date_Paid"
        ,full_name as "@Name"
        ,assignment_number as "@Assignment_Number"
        ,paf.assignment_id as "@Assignment_Id"
        ,run_type_name as "@Run_Type"
        ,element_name as "@Element"
        ,jurisdiction_code as "@Jurisdiction"
        ,NAME as "@Input_Value"
        ,result_value as "@Run_Result"
        ,balance_name as "@Balance"
        ,DECODE(scale,1, ''+'', -1, ''-'') as "@ADD_Subtract"
        ,pp.person_id as "@person_id"
        FROM pay_payrolls_f ppf
        ,pay_payroll_actions ppa
        ,pay_assignment_actions paa
        ,per_assignments_f paf
        ,pay_run_results prr
        ,per_people_f pp
        ,pay_run_result_values prv
        ,pay_element_types_f pet
        ,pay_input_values_f piv
        ,pay_balance_types bt
        ,pay_balance_feeds_f bf
        ,pay_run_types_f rt
        WHERE  ppa.payroll_action_id = '||p_payroll_action_id ||'
        AND ppa.payroll_id = ppf.payroll_id
        and paa.payroll_action_id = ppa.payroll_action_id
        AND ppa.effective_date BETWEEN ppf.effective_start_date
                           AND ppf.effective_end_date
        and ppf.payroll_id = paf.payroll_id
        AND paf.person_id = pp.person_id
        AND ppa.effective_date BETWEEN pp.effective_start_date
                               AND pp.effective_end_date
        AND ppa.effective_date BETWEEN paf.effective_start_date
                               AND paf.effective_end_date
        AND paf.assignment_id = paa.assignment_id
        AND prr.assignment_action_id  = paa.assignment_action_id
        AND pet.element_type_id  = prr.element_type_id
        AND ppa.effective_date BETWEEN pet.effective_start_date
                               AND  pet.effective_end_date
        AND prr.run_result_id = prv.run_result_id
        AND piv.input_value_id  = prv.input_value_id
        AND ppa.effective_date BETWEEN piv.effective_start_date
                               AND piv.effective_end_date
        AND piv.input_value_id = bf.input_value_id
        AND bt.balance_type_id  = bf.balance_type_id
        AND ppa.effective_date BETWEEN bf.effective_start_date
                               AND bf.effective_end_date
        AND rt.run_type_id = NVL(paa.run_type_id, ppa.run_type_id)
        and ('||lv_assignment_set_id ||' is NULL
             or ( '||lv_assignment_set_id ||' is not NULL
                 and '||lv_assignment_set_id ||' in
                    (select assignment_set_id
                       from hr_assignment_set_amendments hasa
                      where hasa.assignment_set_id = '||lv_assignment_set_id ||'
                        and paf.assignment_id = hasa.assignment_id
                   )
               )
             )
        and ('||lv_element_set_id ||' is null
                or ('||lv_element_set_id ||' is not null
                    and exists
                        (select ''x'' from pay_element_type_rules petr
                           where petr.element_set_id = '||lv_element_set_id ||'
                             and petr.element_type_id = pet.element_type_id
                             and petr.include_or_exclude = ''I''
                         union all
                          select ''x'' from pay_element_types_f pet1
                           where pet1.classification_id in
                                 (select classification_id
                                    from pay_ele_classification_rules
                                   where element_set_id = '||lv_element_set_id ||')
                             and pet1.element_type_id = pet.element_type_id
                         minus
                          select ''x'' from pay_element_type_rules petr
                           where petr.element_set_id = '||lv_element_set_id ||'
                             and petr.element_type_id = pet.element_type_id
                             and petr.include_or_exclude = ''E''
                        )
                   )
            )
            ORDER BY  1,2,13, 5, 7, 9, 11';
    end if; /*Bug# 5886859 ending here*/

    hr_utility.trace('lenght of l_query = '||to_char(length(l_query)));

    hr_utility.trace ('Processing '||p_payroll_action_id);

    hr_utility.trace('setting l_qryCtx');

    l_qryCtx := dbms_xmlgen.newcontext(l_query);

    hr_utility.trace('calling xml l_qryCtx');

    tmp_clob := dbms_xmlgen.getxml(l_qryCtx);

    rowKount := dbms_xmlgen.getnumrowsprocessed(l_qryCtx);
    hr_utility.trace('rowKount = '||rowKount);

    --storage_limit := DBMS_LOB.GET_STORAGE_LIMIT();
    --hr_utility.trace ('storage_limit '||to_char(storage_limit));

    if rowKount = 0 then
       debug_mesg := 'In get_xmldoc_clob Query return: No Data Found';
       raise noDataFound;
    else
    clob_length := dbms_lob.getlength(tmp_clob);
    hr_utility.trace('clob length  '||to_char(clob_length));
    end if;

    DBMS_XMLGEN.closeContext(l_qryCtx);
    hr_utility.trace('Leaving '||l_proc);
   return tmp_clob;

   EXCEPTION
         when noDataFound then
            if debug_mesg IS NULL THEN
               debug_mesg := 'In get_xmldoc_clob Exception : noDataFound';
            end if;
            hr_utility.trace(debug_mesg) ;
            hr_utility.raise_error;
         WHEN others THEN
            if debug_mesg IS NULL THEN
               debug_mesg := 'In get_xmldoc_clob Exception : OTHERS';
            end if;
            hr_utility.trace(debug_mesg) ;
            raise;
   END;

--begin
  --hr_utility.trace_on(null, 'payextract');

END PAY_PAYROLL_EXTRACT;

/
