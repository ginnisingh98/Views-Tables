--------------------------------------------------------
--  DDL for Package PQP_INI_BAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_INI_BAL" AUTHID CURRENT_USER AS
/* $Header: pqpbladj.pkh 115.6 2003/07/11 11:57:59 jcpereir noship $*/

TYPE r_err_info is Record
   ( element_name           VARCHAR2(80)
    ,business_group_id      NUMBER
    ,assignment_id          NUMBER
   );

-- This Table is used for storing information of errored out entries
TYPE t_err_info is Table of r_err_info
                   INDEX BY binary_integer  ;

TYPE r_element_cache is Record
   ( element_name           VARCHAR2(80)
    ,business_group_id      NUMBER
    ,effective_date         Date
    ,element_type_id        NUMBER
   );

-- This Table is used as a Cache to retrieve the Element Type Id , for given Element Name
TYPE t_element_cache is Table of r_element_cache
                   INDEX BY binary_integer;

g_element_cache   t_element_cache;

TYPE r_payroll_det_cache is Record
   ( assignment_id          NUMBER
    ,business_group_id      NUMBER
    ,payroll_id             NUMBER
    ,consolidation_set_id   NUMBER
    ,effective_date         DATE);

-- This Table is used as a Cache to retrieve the Payroll Details , for given Assignment
TYPE t_payroll_det_cache is Table of r_payroll_det_cache
                   INDEX BY binary_integer  ;

g_payroll_det_cache   t_payroll_det_cache;

TYPE r_comp_act_miles is Record
   ( element_name           VARCHAR2(80)
    ,total_act_miles      NUMBER);

-- This Table is used as a Cache to retrieve the Payroll Details , for given Assignment
TYPE t_comp_act_miles is Table of r_comp_act_miles
                   INDEX BY binary_integer  ;

g_comp_act_miles   t_comp_act_miles;


TYPE r_bal_info is Record
   ( PAYE_Taxable           VARCHAR2(1)
    ,Ownership_Type         VARCHAR2(3)
    ,Vehicle_Type           VARCHAR2(3)
    ,Usage_Type             VARCHAR2(1)
    ,Element_Name           VARCHAR2(80)
    ,Processed_Miles        NUMBER(11,2)
    ,Processed_Act_Miles    NUMBER(11,2)
    ,Processed_Amt          NUMBER(11,2)
    ,IRAM_Amt               NUMBER(11,2)
    ,NI_Amt                 NUMBER(11,2)
    ,Taxable_Amt            NUMBER(11,2)
    ,Addl_Pasg              NUMBER(9)
    ,Addl_Pasg_Amt          NUMBER(11,2)
    ,Addl_Ni_Amt            NUMBER(11,2)
    ,Addl_Tax_Amt           NUMBER(11,2)
    ,Addl_Pasg_Miles        NUMBER(11,2)
    ,Addl_Pasg_Act_Miles    NUMBER(11,2)
    ,effective_date         DATE
    ,business_group_id      NUMBER
    ,assignment_id          NUMBER
    ,run_result_id          NUMBER
   );

TYPE t_bal_info is Table of r_bal_info
                   INDEX BY binary_integer  ;

g_sum_bal_info      t_bal_info;

-- These variables will contain sum of PAYE Taxable Claimed miles.
-- These will be used to get the Mileage Band for the given PAYE Taxable claim
comp_tot_paye_tax_cl_miles NUMBER;
priv_tot_paye_tax_cl_miles NUMBER;

/*TYPE r_input_val is Record
     ( input_value_id1    pay_element_entry_values_f .input_value_id%TYPE
      ,input_value_id2    pay_element_entry_values_f .input_value_id%TYPE
      ,input_value_id3    pay_element_entry_values_f .input_value_id%TYPE
      ,input_value_id4    pay_element_entry_values_f .input_value_id%TYPE
      ,input_value_id5    pay_element_entry_values_f .input_value_id%TYPE
      ,input_value_id6    pay_element_entry_values_f .input_value_id%TYPE
      ,input_value_id7    pay_element_entry_values_f .input_value_id%TYPE
      ,input_value_id8    pay_element_entry_values_f .input_value_id%TYPE
      ,input_value_id9    pay_element_entry_values_f .input_value_id%TYPE
      ,input_value_id10   pay_element_entry_values_f .input_value_id%TYPE
      ,input_value_id11   pay_element_entry_values_f .input_value_id%TYPE
      ,input_value_id12   pay_element_entry_values_f .input_value_id%TYPE
      ,input_value_id13   pay_element_entry_values_f .input_value_id%TYPE
      ,input_value_id14   pay_element_entry_values_f .input_value_id%TYPE
      ,input_value_id15   pay_element_entry_values_f .input_value_id%TYPE
      ,entry_id1          pay_element_entry_values_f .element_entry_id%TYPE
      ,entry_id2          pay_element_entry_values_f .element_entry_id%TYPE
      ,entry_id3          pay_element_entry_values_f .element_entry_id%TYPE
      ,entry_id4          pay_element_entry_values_f .element_entry_id%TYPE
      ,entry_id5          pay_element_entry_values_f .element_entry_id%TYPE
      ,entry_id6          pay_element_entry_values_f .element_entry_id%TYPE
      ,entry_id7          pay_element_entry_values_f .element_entry_id%TYPE
      ,entry_id8          pay_element_entry_values_f .element_entry_id%TYPE
      ,entry_id9          pay_element_entry_values_f .element_entry_id%TYPE
      ,entry_id10         pay_element_entry_values_f .element_entry_id%TYPE
      ,entry_id11         pay_element_entry_values_f .element_entry_id%TYPE
      ,entry_id12         pay_element_entry_values_f .element_entry_id%TYPE
      ,entry_id13         pay_element_entry_values_f .element_entry_id%TYPE
      ,entry_id14         pay_element_entry_values_f .element_entry_id%TYPE
      ,entry_id15          pay_element_entry_values_f .element_entry_id%TYPE
      );*/
TYPE r_input_val is Record
     ( input_value_id    pay_element_entry_values_f .input_value_id%TYPE
     );

TYPE t_input_val is Table of r_input_val
                   INDEX BY binary_integer  ;

PROCEDURE Initialize_Balances(p_business_group_id IN NUMBER);

TYPE r_balance_cache is Record
   ( balance_name           VARCHAR2(80)
    ,balance_type_id        NUMBER
);

TYPE t_balance_cache is Table of r_balance_cache
                   INDEX BY binary_integer;

g_balance_cache   t_balance_cache;

FUNCTION get_balance_value (p_assignment_id  IN NUMBER
                           ,p_balance_name   IN VARCHAR2
                            )
return NUMBER;


PROCEDURE create_element_entry
           ( p_effective_date            IN DATE
            ,p_business_group_id         IN NUMBER
            ,p_assignment_id             IN NUMBER
            ,p_element_name              IN VARCHAR2
            ,p_base_element_name         IN VARCHAR2
            ,p_entry_value1              IN VARCHAR2
            ,p_entry_value2              IN VARCHAR2
            ,p_entry_value3              IN VARCHAR2
            ,p_entry_value4              IN VARCHAR2
            ,p_entry_value5              IN VARCHAR2
            ,p_entry_value6              IN VARCHAR2
            ,p_entry_value7              IN VARCHAR2
            ,p_entry_value8              IN VARCHAR2
            ,p_entry_value9              IN VARCHAR2
            ,p_entry_value10             IN VARCHAR2
            ,p_entry_value11             IN VARCHAR2
            ,p_entry_value12             IN VARCHAR2
            ,p_entry_value13             IN VARCHAR2
            ,p_entry_value14             IN VARCHAR2
            ,p_entry_value15             IN VARCHAR2
            );

TYPE r_input_val_cache is Record
   ( element_type_id        NUMBER
    ,input_val_id1          pay_element_entry_values_f .input_value_id%TYPE
    ,input_val_id2          pay_element_entry_values_f .input_value_id%TYPE
    ,input_val_id3          pay_element_entry_values_f .input_value_id%TYPE
    ,input_val_id4          pay_element_entry_values_f .input_value_id%TYPE
    ,input_val_id5          pay_element_entry_values_f .input_value_id%TYPE
    ,input_val_id6          pay_element_entry_values_f .input_value_id%TYPE
    ,input_val_id7          pay_element_entry_values_f .input_value_id%TYPE
    ,input_val_id8          pay_element_entry_values_f .input_value_id%TYPE
    ,input_val_id9          pay_element_entry_values_f .input_value_id%TYPE
    ,input_val_id10         pay_element_entry_values_f .input_value_id%TYPE
    ,input_val_id11         pay_element_entry_values_f .input_value_id%TYPE
    ,input_val_id12         pay_element_entry_values_f .input_value_id%TYPE
    ,input_val_id13         pay_element_entry_values_f .input_value_id%TYPE
    ,input_val_id14         pay_element_entry_values_f .input_value_id%TYPE
    ,input_val_id15         pay_element_entry_values_f .input_value_id%TYPE
);

-- This Table is used as a Cache to retrieve the Input Value Ids , for a given Element
TYPE t_input_val_cache is Table of r_input_val_cache
                   INDEX BY binary_integer;

g_input_val_cache   t_input_val_cache;

PROCEDURE route_balance_amt ;
FUNCTION get_element_id (p_business_group_id      IN NUMBER
                        ,p_element_name           IN VARCHAR2
                        ,p_effective_date         IN DATE
                        )
RETURN NUMBER;
END;

 

/
