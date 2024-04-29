--------------------------------------------------------
--  DDL for Package Body AMW_FIN_COSO_VIEWS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_FIN_COSO_VIEWS_PVT" as
/* $Header: amwcfcvb.pls 120.0.12000000.2 2007/04/02 16:45:02 dliao ship $ */


 PROCEDURE create_fin_ctrl_components
(P_CERTIFICATION_ID number ,
                  P_FINANCIAL_STATEMENT_ID number,
                  P_STATEMENT_GROUP_ID number,
                  P_FINANCIAL_ITEM_ID number,
                  P_ACCOUNT_GROUP_ID  number ,
                  P_ACCOUNT_ID        number ,
                  P_OBJECT_TYPE varchar2 ) is

/* ************************************** Example of Paraemters received *************************************

For Financial Items the Parameter Passed will be
    (P_CERTIFICATION_ID => l_certification_id,
                  P_FINANCIAL_STATEMENT_ID => Get_all_items_Rec.FINANCIAL_STATEMENT_ID ,
                  P_STATEMENT_GROUP_ID => Get_all_items_Rec.STATEMENT_GROUP_ID ,
                  P_FINANCIAL_ITEM_ID => Get_all_items_Rec.FINANCIAL_ITEM_ID,
                  P_ACCOUNT_GROUP_ID   => NULL,
                  P_ACCOUNT_ID         => NULL,
                  P_OBJECT_TYPE => 'FINANCIAL ITEM')

For Key Accounts the Parameter Passed will be

                  (P_CERTIFICATION_ID => l_certification_id,
                  P_STATEMENT_GROUP_ID => Get_all_accts_Rec.STATEMENT_GROUP_ID ,
                  P_FINANCIAL_STATEMENT_ID => Get_all_accts_Rec.FINANCIAL_STATEMENT_ID,
                  P_FINANCIAL_ITEM_ID => Get_all_accts_Rec.financial_item_id,
                  P_ACCOUNT_ID         => Get_all_accts_Rec.natural_account_id,
                  P_ACCOUNT_GROUP_ID   => Get_all_accts_Rec.account_group_id,
                  P_OBJECT_TYPE => 'ACCOUNT');


*******************************************************************************************************************
*/

begin
declare

-- type component_code_array is table of varchar2(30) index by pls_integer;

-- type total_control_array is table of number index by pls_integer;

-- type ineff_control_array is table of number index by pls_integer;

 ctr integer :=0;
 max_num_of_codes integer :=0;
 m_ctrl_attribute_type VARCHAR2(30) :='CTRL_COMPONENT';

 m_component_code component_code_array;
 m_total_control  total_control_array ;
 m_ineff_control  ineff_control_array ;
 m_acc_assert_flag component_code_array;
 m_evaluated_ctrls  total_control_array ;


 v_COMPONENT_CODE varchar2(30);

 g_user_id              NUMBER        := fnd_global.user_id;
 g_login_id             NUMBER        := fnd_global.conc_login_id;
 g_errbuf               VARCHAR2(2000) := null;
 g_retcode              VARCHAR2(2)    :=  '0';
 m_object_version_number NUMBER;

 m_display_flag varchar2(1) := 'N';

-- *************** Currsor to get all Control for the Fianancial Item being Passed ********** --

cursor ineff_ctrl_of_item
is
select
 count(1) numIneffCtrls,
  COMPONENT_CODE
from
 (select
    distinct
    ctrl.ORGANIZATION_ID,  ctrl.control_id, comp.COMPONENT_CODE
from
  amw_fin_item_acc_ctrl ctrl,
  amw_opinions_log_v opinion,
  amw_assessment_components comp,
  amw_control_associations ctrlAsso
where
 ctrl.FIN_CERTIFICATION_ID= P_CERTIFICATION_ID and
 ctrl.OBJECT_TYPE = 'FINANCIAL ITEM' and
 ctrl.FINANCIAL_ITEM_ID= P_FINANCIAL_ITEM_ID and
 -- ctrl.ACCOUNT_GROUP_ID is null and
 -- ctrl.NATURAL_ACCOUNT_ID is null and
 --opinion.OPINION_LOG_ID =   ctrl.OPINION_LOG_ID and
 opinion.pk1_value = ctrl.control_id and
 opinion.pk3_value = ctrl.ORGANIZATION_ID and
 opinion.audit_result_CODE <> 'EFFECTIVE' and
 opinion.OPINION_TYPE_CODE = 'EVALUATION' AND
 opinion.OBJECT_NAME = 'AMW_ORG_CONTROL'  and
 ctrl.CONTROL_REV_ID =comp.OBJECT_ID and
 comp.OBJECT_TYPE ='CONTROL' and
 ctrlAsso.OBJECT_TYPE='RISK_FINCERT' and
 opinion.OPINION_LOG_ID =   ctrlAsso.PK5 and
 ctrlAsso.PK1 = ctrl.FIN_CERTIFICATION_ID and
 ctrlAsso.PK2 = ctrl.ORGANIZATION_ID  and
 ctrlAsso.CONTROL_ID = ctrl.control_id)
group by COMPONENT_CODE;

--------------------------------------------------------------------------------
cursor tot_ctrl_of_item
is
select
 count(1) numOfCtrls,
 comp.COMPONENT_CODE
from
  amw.amw_fin_item_acc_ctrl ctrl,
  amw_assessment_components comp
where
 ctrl.FIN_CERTIFICATION_ID=P_CERTIFICATION_ID and
 ctrl.OBJECT_TYPE = 'FINANCIAL ITEM' and
 ctrl.FINANCIAL_ITEM_ID= P_FINANCIAL_ITEM_ID and
 --ctrl.ACCOUNT_GROUP_ID is null and
 --ctrl.NATURAL_ACCOUNT_ID is null and
 ctrl.CONTROL_REV_ID =comp.OBJECT_ID and
 comp.OBJECT_TYPE ='CONTROL'
group by COMPONENT_CODE;

--------------------------------------------------------------------------------------
cursor evaluated_ctrls_of_item
is
select
 count(1) numOfEvaluatedCtrls,
  COMPONENT_CODE
from
 (select
    distinct
    ctrl.ORGANIZATION_ID,  ctrl.control_id, comp.COMPONENT_CODE
from
  amw_fin_item_acc_ctrl ctrl,
  amw_opinions_v opinion,
  amw_assessment_components comp,
  amw_control_associations ctrlAsso
where
 ctrl.FIN_CERTIFICATION_ID=  P_CERTIFICATION_ID
 and
 ctrl.OBJECT_TYPE = 'FINANCIAL ITEM' and
 ctrl.FINANCIAL_ITEM_ID= P_FINANCIAL_ITEM_ID
 and
 opinion.pk1_value = ctrl.control_id and
 opinion.pk3_value = ctrl.ORGANIZATION_ID and
 opinion.OPINION_TYPE_CODE = 'EVALUATION' AND
 opinion.OBJECT_NAME = 'AMW_ORG_CONTROL'  and
 ctrl.CONTROL_REV_ID =comp.OBJECT_ID and
 comp.OBJECT_TYPE ='CONTROL' and
 ctrlAsso.OBJECT_TYPE='RISK_FINCERT' and
 ctrlAsso.PK1 = ctrl.FIN_CERTIFICATION_ID and
 ctrlAsso.PK2 = ctrl.ORGANIZATION_ID  and
 ctrlAsso.CONTROL_ID = ctrl.control_id)
group by COMPONENT_CODE;



-- *************** Currsor to get all Control for the Fianancial Item being Passed ********** --

cursor in_eff_ctrl_of_accounts
is
--fix bug 5768982 on 2-12-07
/*******
select
 count(1) numIneffCtrls,
  COMPONENT_CODE from
( select
    distinct
    ctrl.ORGANIZATION_ID,  ctrl.control_id, comp.COMPONENT_CODE
from
   amw_fin_item_acc_ctrl ctrl,
  amw_opinions_log_v opinion,
  amw_assessment_components comp,
  amw_control_associations ctrlAsso
where
 ctrl.FIN_CERTIFICATION_ID=  P_CERTIFICATION_ID and
 ctrl.OBJECT_TYPE = 'ACCOUNT' and
 --ctrl.FINANCIAL_ITEM_ID=  P_FINANCIAL_ITEM_ID and
 ctrl.ACCOUNT_GROUP_ID =  P_ACCOUNT_GROUP_ID
 and NATURAL_ACCOUNT_ID = P_ACCOUNT_ID and
 --opinion.OPINION_LOG_ID =   ctrl.OPINION_LOG_ID and
 opinion.pk1_value = ctrl.control_id and
 opinion.pk3_value = ctrl.ORGANIZATION_ID and
 opinion.audit_result_CODE <> 'EFFECTIVE' and
 opinion.OPINION_TYPE_CODE = 'EVALUATION' AND
 opinion.OBJECT_NAME = 'AMW_ORG_CONTROL'  and
 ctrl.CONTROL_REV_ID =comp.OBJECT_ID and
 comp.OBJECT_TYPE ='CONTROL' and
 ctrlAsso.OBJECT_TYPE='RISK_FINCERT' and
 opinion.OPINION_LOG_ID =   ctrlAsso.PK5 and
 ctrlAsso.PK1 = ctrl.FIN_CERTIFICATION_ID and
 ctrlAsso.PK2 = ctrl.ORGANIZATION_ID  and
 ctrlAsso.CONTROL_ID = ctrl.control_id)
group by COMPONENT_CODE;
*********/
SELECT COUNT(1) NUMINEFFCTRLS, COMPONENT_CODE
FROM
(SELECT DISTINCT CTRL.ORGANIZATION_ID, CTRL.CONTROL_ID, COMP.COMPONENT_CODE
  FROM AMW_FIN_ITEM_ACC_CTRL CTRL,
  AMW_ASSESSMENT_COMPONENTS COMP
  WHERE
  CTRL.FIN_CERTIFICATION_ID= P_CERTIFICATION_ID
  AND CTRL.OBJECT_TYPE = 'ACCOUNT'
  AND CTRL.ACCOUNT_GROUP_ID = P_ACCOUNT_GROUP_ID
  AND NATURAL_ACCOUNT_ID = P_ACCOUNT_ID
  AND CTRL.CONTROL_REV_ID =COMP.OBJECT_ID
  AND COMP.OBJECT_TYPE ='CONTROL'
  AND EXISTS
  (SELECT 1 FROM AMW_OPINIONS_LOG_V OPINION
  WHERE OPINION.PK1_VALUE = CTRL.CONTROL_ID
  AND OPINION.PK3_VALUE = CTRL.ORGANIZATION_ID
  AND OPINION.AUDIT_RESULT_CODE <> 'EFFECTIVE'
  AND OPINION.OPINION_TYPE_CODE = 'EVALUATION'
  AND OPINION.OBJECT_NAME = 'AMW_ORG_CONTROL'
  AND EXISTS
  (SELECT 1 FROM AMW_CONTROL_ASSOCIATIONS CTRLASSO
  WHERE
  CTRLASSO.OBJECT_TYPE='RISK_FINCERT'
  AND OPINION.OPINION_LOG_ID = CTRLASSO.PK5
  AND CTRLASSO.PK1 = P_CERTIFICATION_ID
  AND CTRLASSO.PK2 = OPINION.PK3_VALUE
  AND CTRLASSO.CONTROL_ID = OPINION.PK1_VALUE
  ))) GROUP BY COMPONENT_CODE;

-------------------------------------------------------------
cursor total_ctrl_of_accounts
is
select
 count(1) numOfCtrls,
 comp.COMPONENT_CODE
from
  amw.amw_fin_item_acc_ctrl ctrl,
  amw_assessment_components comp
where
 ctrl.FIN_CERTIFICATION_ID= P_CERTIFICATION_ID and
 ctrl.OBJECT_TYPE = 'ACCOUNT' and
 -- ctrl.FINANCIAL_ITEM_ID= P_FINANCIAL_ITEM_ID and
 ACCOUNT_GROUP_ID = P_ACCOUNT_GROUP_ID and
 NATURAL_ACCOUNT_ID =P_ACCOUNT_ID   and
 ctrl.CONTROL_REV_ID =comp.OBJECT_ID and
 comp.OBJECT_TYPE ='CONTROL'
group by COMPONENT_CODE;
-----------------------------------------------------------------
cursor evaluated_ctrls_of_acc
is
select
 count(1) numOfEvaluatedCtrls,
  COMPONENT_CODE from
( select
    distinct
    ctrl.ORGANIZATION_ID,  ctrl.control_id, comp.COMPONENT_CODE
from
   amw_fin_item_acc_ctrl ctrl,
  amw_opinions_log_v opinion,
  amw_assessment_components comp,
  amw_control_associations ctrlAsso
where
 ctrl.FIN_CERTIFICATION_ID=   P_CERTIFICATION_ID
 and
 ctrl.OBJECT_TYPE = 'ACCOUNT' and
 ctrl.ACCOUNT_GROUP_ID =   P_ACCOUNT_GROUP_ID and
 NATURAL_ACCOUNT_ID = P_ACCOUNT_ID and
 opinion.pk1_value = ctrl.control_id and
 opinion.pk3_value = ctrl.ORGANIZATION_ID and
 opinion.OPINION_TYPE_CODE = 'EVALUATION' AND
 opinion.OBJECT_NAME = 'AMW_ORG_CONTROL'  and
 ctrl.CONTROL_REV_ID =comp.OBJECT_ID and
 comp.OBJECT_TYPE ='CONTROL' and
 ctrlAsso.OBJECT_TYPE='RISK_FINCERT' and
 ctrlAsso.PK1 = ctrl.FIN_CERTIFICATION_ID and
 ctrlAsso.PK2 = ctrl.ORGANIZATION_ID  and
 ctrlAsso.CONTROL_ID = ctrl.control_id)
group by COMPONENT_CODE;


-- *************** Currsor to get all Control for the Fianancial Item being Passed ********** --

cursor COSO_COMPONENTS
 is
 select
  LOOKUP_CODE
 from
   amw_lookups
 where lookup_type = 'AMW_ASSESSMENT_COMPONENTS';

--********************* Get Inefftive Control *************************************************--





BEGIN

 --m_component_code := null;
 --ctr := 0;


 -- ************ Since the Table has 30 Fileds only initialize 30 Positios in the Array**************--
 ctr :=  1;

 loop
   EXIT  WHEN ctr > 30;

    m_component_code(ctr) := null;
    m_acc_assert_flag(ctr) := 'I';
    m_total_control(ctr) := 0;
    m_ineff_control(ctr) := 0;
    m_evaluated_ctrls(ctr) := 0;


    ctr := ctr + 1;
 end loop; --end of initialization

 -- ************ get All Control Components Codes and Load it in an Array for later use **************--

 ctr := 0;
 for coso_rec in COSO_COMPONENTS
 loop
    exit when COSO_COMPONENTS%notfound;
    ctr := ctr + 1;
    m_component_code(ctr) := coso_rec.LOOKUP_CODE;

 end loop; --end of COSO_COMPONENTS loop

 max_num_of_codes := ctr;

 --dbms_output.put_line(' max_num_of_codes: ');
 --dbms_output.put_line(max_num_of_codes);


 if  max_num_of_codes > 0 then

     -- ************ get Total Controls and Ineff Ctrl for each Components Codes For a Financial Item**************--

    if P_OBJECT_TYPE = 'FINANCIAL ITEM' then


       -- ************ get Total Controls for each Components Codes and Load it in an Array for later use **************--

       for tot_ctrls in tot_ctrl_of_item
       loop
          exit when tot_ctrl_of_item%notfound;
          v_COMPONENT_CODE := tot_ctrls.COMPONENT_CODE;

          ctr := 1;

          --  check the code is in which bucket and the appropriately add the counts

          while ctr <=  max_num_of_codes
          loop
             if  m_component_code(ctr) =  v_COMPONENT_CODE  then
               m_total_control(ctr) := tot_ctrls.numOfCtrls;

               --dbms_output.put_line( v_COMPONENT_CODE  );
               --dbms_output.put_line(' is the code and the total is ');

               --dbms_output.put_line(m_total_control(ctr) );

                exit;
             end if;
                 ctr := ctr + 1;

          end loop;
      end loop; --end of tot_ctrl_of_item for the Financial Item loop

       -- ************ get Total Controls Evaluted for each Components Codes and Load it in an Array for later use **************--

       for tot_eval_ctrls in evaluated_ctrls_of_item
       loop
          exit when evaluated_ctrls_of_item%notfound;
          v_COMPONENT_CODE := tot_eval_ctrls.COMPONENT_CODE;

          ctr := 1;

          --  check the code is in which bucket and the appropriately add the counts

          while ctr <=  max_num_of_codes
          loop
             if  m_component_code(ctr) =  v_COMPONENT_CODE  then
               m_evaluated_ctrls(ctr) := tot_eval_ctrls.numOfEvaluatedCtrls;


                exit;
             end if;
             ctr := ctr + 1;

          end loop;
      end loop; --end of evaluated_ctrls_of_item for the Financial Item loop

      -- ************ get Total Ineffective Controls for each Components Codes and Load it in an Array for later use **************--

       for tot_ineff_ctrls in ineff_ctrl_of_item
       loop
          exit when ineff_ctrl_of_item%notfound;
          v_COMPONENT_CODE := tot_ineff_ctrls.COMPONENT_CODE;

          ctr := 1;

          --  check the code is in which bucket and the appropriately add the counts

          while ctr <=  max_num_of_codes
          loop
             if  m_component_code(ctr) =  v_COMPONENT_CODE  then

                 m_ineff_control(ctr) :=  tot_ineff_ctrls.numIneffCtrls ;


               --dbms_output.put_line( v_COMPONENT_CODE  );
               --dbms_output.put_line(' is the code and the ineff ctrl is ');

               --dbms_output.put_line(m_ineff_control(ctr) );

                exit;
             end if;
               ctr := ctr + 1;

          end loop;
      end loop; --end of tot_ineff_ctrls  for the Financial Item loop



    end if; -- ****************** end if for P_OBJECT_TYPE = 'FINANCIAL ITEM'
     -- ******************************************************************************************** ----
     -- ************ get Total Controls and Ineff Ctrl for each Components Codes For a Account **************--
     -- ********************************************************************************************----

    if P_OBJECT_TYPE = 'ACCOUNT' then
       -- ************ get Total Controls for each Components Codes and Load it in an Array for later use **************--

       for tot_ctrls_acc in total_ctrl_of_accounts
       loop
          exit when total_ctrl_of_accounts%notfound;
          v_COMPONENT_CODE := tot_ctrls_acc.COMPONENT_CODE;

          ctr := 1;

          --  check the code is in which bucket and the appropriately add the counts

          while ctr <=  max_num_of_codes
          loop
             if  m_component_code(ctr) =  v_COMPONENT_CODE  then

                 m_total_control(ctr) := tot_ctrls_acc.numOfCtrls;
                exit;
             end if;
           ctr := ctr + 1;
          end loop;
      end loop; --end of total_ctrl_of_accounts   for the Account loop

    -- ************ get Total Controls Evaluted for each Components Codes and Load it in an Array for later use **************--

       for tot_eval_ctrls in evaluated_ctrls_of_acc
       loop
          exit when evaluated_ctrls_of_acc%notfound;
          v_COMPONENT_CODE := tot_eval_ctrls.COMPONENT_CODE;

          ctr := 1;

          --  check the code is in which bucket and the appropriately add the counts

          while ctr <=  max_num_of_codes
          loop
             if  m_component_code(ctr) =  v_COMPONENT_CODE  then
               m_evaluated_ctrls(ctr) := tot_eval_ctrls.numOfEvaluatedCtrls;


                exit;
             end if;
             ctr := ctr + 1;

          end loop;
      end loop; --end of evaluated_ctrls_of_acc for the Account loop




      -- ************ get Total Ineffective Controls for each Components Codes and Load it in an Array for later use **************--

       for tot_ineff_ctrls_acc in in_eff_ctrl_of_accounts
       loop
          exit when in_eff_ctrl_of_accounts%notfound;
          v_COMPONENT_CODE := tot_ineff_ctrls_acc.COMPONENT_CODE;

          ctr := 1;

          --  check the code is in which bucket and the appropriately add the counts

          while ctr <=  max_num_of_codes
          loop
             if  m_component_code(ctr) =  v_COMPONENT_CODE  then

                 m_ineff_control(ctr) :=  tot_ineff_ctrls_acc.numIneffCtrls;


                exit;
             end if;
            ctr := ctr + 1;
          end loop;
      end loop; --end of in_eff_ctrl_of_accounts  for the Account loop



    end if; -- end if for P_OBJECT_TYPE = 'ACCOUNT'

   --  *********************   set column flag to "ignore" if the total controls are 0 for the column

    ctr := 1;
    while ctr <=  max_num_of_codes
    loop

      if  nvl(m_total_control(ctr),0) > 0 then
          m_acc_assert_flag(ctr) := 'N';
      end if;
      ctr := ctr +1;
    end loop;


   -- ************* Check at lease one control exists for the row *******************************

     if set_display_flag(control_exists_array => m_total_control) then
        m_display_flag := 'Y';
     else
        m_display_flag := 'N';
     end if;

    -- ************************** CALL Proc to Insert Data into the Table **************************************** --

   m_object_version_number := 1;

    amw_fin_coso_views_pvt.INSERT_ROW(
     x_fin_certification_id       	=> 	P_CERTIFICATION_ID	,
     x_financial_statement_id    	=> 	P_FINANCIAL_STATEMENT_ID 	,
     x_financial_item_id         	=> 	P_FINANCIAL_ITEM_ID 	,
     x_account_group_id          	=> 	P_ACCOUNT_GROUP_ID  	,
     x_natural_account_id        	=> 	P_ACCOUNT_ID        	,
     x_object_type               	=> 	P_OBJECT_TYPE 	,
     x_ctrl_attribute_type       	=> 	 m_ctrl_attribute_type       	,
     x_ctrl_attr_code_1          	=> 	m_component_code(1)	,
     x_ineff_ctrl_attr_1         	=> 	m_ineff_control(1)	,
     x_total_ctrl_attr_1         	=> 	m_total_control(1)	,
     x_ctrl_attr_code_2          	=> 	m_component_code(2)	,
     x_ineff_ctrl_attr_2         	=> 	m_ineff_control(2)	,
     x_total_ctrl_attr_2         	=> 	m_total_control(2)	,
     x_ctrl_attr_code_3          	=> 	m_component_code(3)	,
     x_ineff_ctrl_attr_3         	=> 	m_ineff_control(3)	,
     x_total_ctrl_attr_3         	=> 	m_total_control(3)	,
     x_ctrl_attr_code_4          	=> 	m_component_code(4)	,
     x_ineff_ctrl_attr_4         	=> 	m_ineff_control(4)	,
     x_total_ctrl_attr_4         	=> 	m_total_control(4)	,
     x_ctrl_attr_code_5          	=> 	m_component_code(5)	,
     x_ineff_ctrl_attr_5         	=> 	m_ineff_control(5)	,
     x_total_ctrl_attr_5         	=> 	m_total_control(5)	,
     x_ctrl_attr_code_6          	=> 	m_component_code(6)	,
     x_ineff_ctrl_attr_6         	=> 	m_ineff_control(6)	,
     x_total_ctrl_attr_6         	=> 	m_total_control(6)	,
     x_ctrl_attr_code_7          	=> 	m_component_code(7)	,
     x_ineff_ctrl_attr_7         	=> 	m_ineff_control(7)	,
     x_total_ctrl_attr_7         	=> 	m_total_control(7)	,
     x_ctrl_attr_code_8          	=> 	m_component_code(8)	,
     x_ineff_ctrl_attr_8         	=> 	m_ineff_control(8)	,
     x_total_ctrl_attr_8         	=> 	m_total_control(8)	,
     x_ctrl_attr_code_9         	=> 	m_component_code(9)	,
     x_ineff_ctrl_attr_9         	=> 	m_ineff_control(9)	,
     x_total_ctrl_attr_9         	=> 	m_total_control(9)	,
     x_ctrl_attr_code_10         	=> 	m_component_code(10)	,
     x_ineff_ctrl_attr_10        	=> 	m_ineff_control(10)	,
     x_total_ctrl_attr_10        	=> 	m_total_control(10)	,
     x_ctrl_attr_code_11         	=> 	m_component_code(11)	,
     x_ineff_ctrl_attr_11        	=> 	m_ineff_control(11)	,
     x_total_ctrl_attr_11        	=> 	m_total_control(11)	,
     x_ctrl_attr_code_12         	=> 	m_component_code(12)	,
     x_ineff_ctrl_attr_12        	=> 	m_ineff_control(12)	,
     x_total_ctrl_attr_12        	=> 	m_total_control(12)	,
     x_ctrl_attr_code_13         	=> 	m_component_code(13)	,
     x_ineff_ctrl_attr_13        	=> 	m_ineff_control(13)	,
     x_total_ctrl_attr_13        	=> 	m_total_control(13)	,
     x_ctrl_attr_code_14         	=> 	m_component_code(14)	,
     x_ineff_ctrl_attr_14        	=> 	m_ineff_control(14)	,
     x_total_ctrl_attr_14        	=> 	m_total_control(14)	,
     x_ctrl_attr_code_15         	=> 	m_component_code(15)	,
     x_ineff_ctrl_attr_15        	=> 	m_ineff_control(15)	,
     x_total_ctrl_attr_15        	=> 	m_total_control(15)	,
     x_ctrl_attr_code_16         	=> 	m_component_code(16)	,
     x_ineff_ctrl_attr_16        	=> 	m_ineff_control(16)	,
     x_total_ctrl_attr_16        	=> 	m_total_control(16)	,
     x_ctrl_attr_code_17         	=> 	m_component_code(17)	,
     x_ineff_ctrl_attr_17        	=> 	m_ineff_control(17)	,
     x_total_ctrl_attr_17        	=> 	m_total_control(17)	,
     x_ctrl_attr_code_18         	=> 	m_component_code(18)	,
     x_ineff_ctrl_attr_18        	=> 	m_ineff_control(18)	,
     x_total_ctrl_attr_18        	=> 	m_total_control(18)	,
     x_ctrl_attr_code_19         	=> 	m_component_code(19)	,
     x_ineff_ctrl_attr_19        	=> 	m_ineff_control(19)	,
     x_total_ctrl_attr_19        	=> 	m_total_control(19)	,
     x_ctrl_attr_code_20         	=> 	m_component_code(20)	,
     x_ineff_ctrl_attr_20        	=> 	m_ineff_control(20)	,
     x_total_ctrl_attr_20        	=> 	m_total_control(20)	,
     x_ctrl_attr_code_21         	=> 	m_component_code(21)	,
     x_ineff_ctrl_attr_21        	=> 	m_ineff_control(21)	,
     x_total_ctrl_attr_21        	=> 	m_total_control(21)	,
     x_ctrl_attr_code_22         	=> 	m_component_code(22)	,
     x_ineff_ctrl_attr_22        	=> 	m_ineff_control(22)	,
     x_total_ctrl_attr_22        	=> 	m_total_control(22)	,
     x_ctrl_attr_code_23         	=> 	m_component_code(23)	,
     x_ineff_ctrl_attr_23        	=> 	m_ineff_control(23)	,
     x_total_ctrl_attr_23        	=> 	m_total_control(23)	,
     x_ctrl_attr_code_24         	=> 	m_component_code(24)	,
     x_ineff_ctrl_attr_24         	=> 	m_ineff_control(24)	,
     x_total_ctrl_attr_24        	=> 	m_total_control(24)	,
     x_ctrl_attr_code_25         	=> 	m_component_code(25)	,
     x_ineff_ctrl_attr_25        	=> 	m_ineff_control(25)	,
     x_total_ctrl_attr_25        	=> 	m_total_control(25)	,
     x_ctrl_attr_code_26         	=> 	m_component_code(26)	,
     x_ineff_ctrl_attr_26        	=> 	m_ineff_control(26)	,
     x_total_ctrl_attr_26        	=> 	m_total_control(26)	,
     x_ctrl_attr_code_27         	=> 	m_component_code(27)	,
     x_ineff_ctrl_attr_27        	=> 	m_ineff_control(27)	,
     x_total_ctrl_attr_27        	=> 	m_total_control(27)	,
     x_ctrl_attr_code_28         	=> 	m_component_code(28)	,
     x_ineff_ctrl_attr_28        	=> 	m_ineff_control(28)	,
     x_total_ctrl_attr_28        	=> 	m_total_control(28)	,
     x_ctrl_attr_code_29         	=> 	m_component_code(29)	,
     x_ineff_ctrl_attr_29        	=> 	m_ineff_control(29)	,
     x_total_ctrl_attr_29        	=> 	m_total_control(29)	,
     x_ctrl_attr_code_30         	=> 	m_component_code(30)	,
     x_ineff_ctrl_attr_30        	=> 	m_ineff_control(30)	,
     x_total_ctrl_attr_30        	=> 	m_total_control(30)	,
     x_created_by                	=> 	g_user_id	,
     x_creation_date             	=> 	SYSDATE	,
     x_last_updated_by           	=> 	g_user_id	,
     x_last_update_date          	=> 	SYSDATE	,
     x_last_update_login         	=> 	g_login_id	,
     --x_security_group_id         	=> 	null	,
     x_object_version_number     	=> 	m_object_version_number	,
     x_acc_assert_flag1         	=> 	m_acc_assert_flag(1),
     x_acc_assert_flag2         	=> 	m_acc_assert_flag(2),
     x_acc_assert_flag3         	=> 	m_acc_assert_flag(3),
     x_acc_assert_flag4         	=> 	m_acc_assert_flag(4),
     x_acc_assert_flag5         	=> 	m_acc_assert_flag(5),
     x_acc_assert_flag6         	=> 	m_acc_assert_flag(6),
     x_acc_assert_flag7         	=> 	m_acc_assert_flag(7),
     x_acc_assert_flag8         	=> 	m_acc_assert_flag(8),
     x_acc_assert_flag9         	=> 	m_acc_assert_flag(9),
     x_acc_assert_flag10        	=> 	m_acc_assert_flag(10),
     x_acc_assert_flag11         	=> 	m_acc_assert_flag(11),
     x_acc_assert_flag12         	=> 	m_acc_assert_flag(12),
     x_acc_assert_flag13         	=> 	m_acc_assert_flag(13),
     x_acc_assert_flag14         	=> 	m_acc_assert_flag(14),
     x_acc_assert_flag15         	=> 	m_acc_assert_flag(15),
     x_acc_assert_flag16         	=> 	m_acc_assert_flag(16),
     x_acc_assert_flag17         	=> 	m_acc_assert_flag(17),
     x_acc_assert_flag18         	=> 	m_acc_assert_flag(18),
     x_acc_assert_flag19         	=> 	m_acc_assert_flag(19),
     x_acc_assert_flag20        	=> 	m_acc_assert_flag(20),
     x_acc_assert_flag21         	=> 	m_acc_assert_flag(21),
     x_acc_assert_flag22         	=> 	m_acc_assert_flag(22),
     x_acc_assert_flag23         	=> 	m_acc_assert_flag(23),
     x_acc_assert_flag24         	=> 	m_acc_assert_flag(24),
     x_acc_assert_flag25         	=> 	m_acc_assert_flag(25),
     x_acc_assert_flag26         	=> 	m_acc_assert_flag(26),
     x_acc_assert_flag27         	=> 	m_acc_assert_flag(27),
     x_acc_assert_flag28         	=> 	m_acc_assert_flag(28),
     x_acc_assert_flag29         	=> 	m_acc_assert_flag(29),
     x_acc_assert_flag30        	=> 	m_acc_assert_flag(30),
     x_eval_ctrl_attr_1         	=> 	m_evaluated_ctrls(1),
     x_eval_ctrl_attr_2         	=> 	m_evaluated_ctrls(2),
     x_eval_ctrl_attr_3         	=> 	m_evaluated_ctrls(3),
     x_eval_ctrl_attr_4         	=> 	m_evaluated_ctrls(4),
     x_eval_ctrl_attr_5         	=> 	m_evaluated_ctrls(5),
     x_eval_ctrl_attr_6         	=> 	m_evaluated_ctrls(6),
     x_eval_ctrl_attr_7         	=> 	m_evaluated_ctrls(7),
     x_eval_ctrl_attr_8         	=> 	m_evaluated_ctrls(8),
     x_eval_ctrl_attr_9         	=> 	m_evaluated_ctrls(9),
     x_eval_ctrl_attr_10        	=> 	m_evaluated_ctrls(10),
     x_eval_ctrl_attr_11         	=> 	m_evaluated_ctrls(11),
     x_eval_ctrl_attr_12         	=> 	m_evaluated_ctrls(12),
     x_eval_ctrl_attr_13         	=> 	m_evaluated_ctrls(13),
     x_eval_ctrl_attr_14         	=> 	m_evaluated_ctrls(14),
     x_eval_ctrl_attr_15         	=> 	m_evaluated_ctrls(15),
     x_eval_ctrl_attr_16         	=> 	m_evaluated_ctrls(16),
     x_eval_ctrl_attr_17         	=> 	m_evaluated_ctrls(17),
     x_eval_ctrl_attr_18         	=> 	m_evaluated_ctrls(18),
     x_eval_ctrl_attr_19         	=> 	m_evaluated_ctrls(19),
     x_eval_ctrl_attr_20        	=> 	m_evaluated_ctrls(20),
     x_eval_ctrl_attr_21         	=> 	m_evaluated_ctrls(21),
     x_eval_ctrl_attr_22         	=> 	m_evaluated_ctrls(22),
     x_eval_ctrl_attr_23         	=> 	m_evaluated_ctrls(23),
     x_eval_ctrl_attr_24         	=> 	m_evaluated_ctrls(24),
     x_eval_ctrl_attr_25         	=> 	m_evaluated_ctrls(25),
     x_eval_ctrl_attr_26         	=> 	m_evaluated_ctrls(26),
     x_eval_ctrl_attr_27         	=> 	m_evaluated_ctrls(27),
     x_eval_ctrl_attr_28         	=> 	m_evaluated_ctrls(28),
     x_eval_ctrl_attr_29         	=> 	m_evaluated_ctrls(29),
     x_eval_ctrl_attr_30        	=> 	m_evaluated_ctrls(30),
     x_display_flag        	        => 	 m_display_flag );


 end if; -- end if for max_num_of_codes


 -- ************  EXCEPTION definitions for the Procedure **************--

EXCEPTION
     WHEN NO_DATA_FOUND
	     THEN
            fnd_file.put_line (fnd_file.LOG, SUBSTR ('No data found in Update_Next_Level_Proc_Info'
                || SUBSTR (SQLERRM, 1, 100), 1, 200));

     WHEN OTHERS
         THEN
            fnd_file.put_line (fnd_file.LOG, SUBSTR ('Unexpected Error in Update_Next_Level_Proc_Info'
                || SUBSTR (SQLERRM, 1, 100), 1, 200));

---COMMIT;
end;
end ; --create_fin_ctrl_components

/* ******************************** Logic to build Control Objective-wise Summary Data *************************************** */


 PROCEDURE create_fin_ctrl_objectives
(P_CERTIFICATION_ID number ,
                  P_FINANCIAL_STATEMENT_ID number,
                  P_STATEMENT_GROUP_ID number,
                  P_FINANCIAL_ITEM_ID number,
                  P_ACCOUNT_GROUP_ID  number ,
                  P_ACCOUNT_ID        number ,
                  P_OBJECT_TYPE varchar2 ) is

/* ************************************** Example of Paraemters received *************************************

For Financial Items the Parameter Passed will be
    (P_CERTIFICATION_ID => l_certification_id,
                  P_FINANCIAL_STATEMENT_ID => Get_all_items_Rec.FINANCIAL_STATEMENT_ID ,
                  P_STATEMENT_GROUP_ID => Get_all_items_Rec.STATEMENT_GROUP_ID ,
                  P_FINANCIAL_ITEM_ID => Get_all_items_Rec.FINANCIAL_ITEM_ID,
                  P_ACCOUNT_GROUP_ID   => NULL,
                  P_ACCOUNT_ID         => NULL,
                  P_OBJECT_TYPE => 'FINANCIAL ITEM')

For Key Accounts the Parameter Passed will be

                  (P_CERTIFICATION_ID => l_certification_id,
                  P_STATEMENT_GROUP_ID => Get_all_accts_Rec.STATEMENT_GROUP_ID ,
                  P_FINANCIAL_STATEMENT_ID => Get_all_accts_Rec.FINANCIAL_STATEMENT_ID,
                  P_FINANCIAL_ITEM_ID => Get_all_accts_Rec.financial_item_id,
                  P_ACCOUNT_ID         => Get_all_accts_Rec.natural_account_id,
                  P_ACCOUNT_GROUP_ID   => Get_all_accts_Rec.account_group_id,
                  P_OBJECT_TYPE => 'ACCOUNT');


*******************************************************************************************************************
*/

begin
declare


 ctr integer :=0;
 max_num_of_codes integer :=0;
 m_ctrl_attribute_type VARCHAR2(30) :='CTRL_OBJECTIVES';

 m_objectives_code component_code_array;
 m_total_control  total_control_array ;
 m_ineff_control  ineff_control_array ;
 m_acc_assert_flag component_code_array;
 m_evaluated_ctrls  total_control_array ;



 m_display_flag varchar2(1) := 'N';

 v_OBJECTIVE_CODE varchar2(30);

 g_user_id              NUMBER        := fnd_global.user_id;
 g_login_id             NUMBER        := fnd_global.conc_login_id;
 g_errbuf               VARCHAR2(2000) := null;
 g_retcode              VARCHAR2(2)    :=  '0';

-- *************** Currsor to get all Control for the Fianancial Item being Passed ********** --

cursor ineff_ctrl_of_item
is
select
 count(1) numIneffCtrls,
 OBJECTIVE_CODE
from
  (select
    distinct
    ctrl.ORGANIZATION_ID,  ctrl.control_id, comp.OBJECTIVE_CODE
from
  amw.amw_fin_item_acc_ctrl ctrl,
  amw_opinions_log_v opinion,
  amw_control_objectives comp,
  amw_control_associations ctrlAsso
where
 ctrl.FIN_CERTIFICATION_ID=  P_CERTIFICATION_ID and
 ctrl.OBJECT_TYPE = 'FINANCIAL ITEM' and
 ctrl.FINANCIAL_ITEM_ID= P_FINANCIAL_ITEM_ID and
 -- ctrl.ACCOUNT_GROUP_ID is null and
 -- ctrl.NATURAL_ACCOUNT_ID is null and
-- opinion.OPINION_LOG_ID =   ctrl.OPINION_LOG_ID and
 opinion.pk1_value = ctrl.control_id and
 opinion.pk3_value = ctrl.ORGANIZATION_ID and
 opinion.audit_result_CODE <> 'EFFECTIVE' and
 opinion.OPINION_TYPE_CODE = 'EVALUATION' AND
 opinion.OBJECT_NAME = 'AMW_ORG_CONTROL'  and
 ctrl.CONTROL_REV_ID =comp.CONTROL_REV_ID and
  ctrlAsso.OBJECT_TYPE='RISK_FINCERT' and
 opinion.OPINION_LOG_ID =   ctrlAsso.PK5 and
 ctrlAsso.PK1 = ctrl.FIN_CERTIFICATION_ID and
 ctrlAsso.PK2 = ctrl.ORGANIZATION_ID  and
 ctrlAsso.CONTROL_ID = ctrl.control_id)
group by OBJECTIVE_CODE;

---------------------------------------------------------------------------
cursor tot_ctrl_of_item
is
select
 count(1) numOfCtrls,
 comp.OBJECTIVE_CODE
from
  amw.amw_fin_item_acc_ctrl ctrl,
  amw_control_objectives comp
where
 ctrl.FIN_CERTIFICATION_ID=P_CERTIFICATION_ID and
 ctrl.OBJECT_TYPE = 'FINANCIAL ITEM' and
 ctrl.FINANCIAL_ITEM_ID= P_FINANCIAL_ITEM_ID and
 --ctrl.ACCOUNT_GROUP_ID is null and
 --ctrl.NATURAL_ACCOUNT_ID is null and
 ctrl.CONTROL_REV_ID =comp.CONTROL_REV_ID
group by OBJECTIVE_CODE;

-----------------------------------------------------------------------------
cursor evaluated_ctrls_of_item
is
select
 count(1) numOfEvaluatedCtrls,
 OBJECTIVE_CODE
from
  (select
    distinct
    ctrl.ORGANIZATION_ID,  ctrl.control_id, comp.OBJECTIVE_CODE
from
  amw.amw_fin_item_acc_ctrl ctrl,
  amw_opinions_log_v opinion,
  amw_control_objectives comp,
  amw_control_associations ctrlAsso
where
 ctrl.FIN_CERTIFICATION_ID=  P_CERTIFICATION_ID
 and
 ctrl.OBJECT_TYPE = 'FINANCIAL ITEM' and
 ctrl.FINANCIAL_ITEM_ID= P_FINANCIAL_ITEM_ID
 and
  opinion.pk1_value = ctrl.control_id and
 opinion.pk3_value = ctrl.ORGANIZATION_ID and
  opinion.OPINION_TYPE_CODE = 'EVALUATION' AND
 opinion.OBJECT_NAME = 'AMW_ORG_CONTROL'  and
 ctrl.CONTROL_REV_ID =comp.CONTROL_REV_ID and
  ctrlAsso.OBJECT_TYPE='RISK_FINCERT' and
  ctrlAsso.PK1 = ctrl.FIN_CERTIFICATION_ID and
 ctrlAsso.PK2 = ctrl.ORGANIZATION_ID  and
 ctrlAsso.CONTROL_ID = ctrl.control_id)
group by OBJECTIVE_CODE;


-- *************** Currsor to get all Control for the Fianancial Item being Passed ********** --

cursor in_eff_ctrl_of_accounts
is
--fix bug 5768982 on 2-12-2007
/*****
select
 count(1) numIneffCtrls,
 OBJECTIVE_CODE from
  (select
    distinct
    ctrl.ORGANIZATION_ID,  ctrl.control_id, comp.OBJECTIVE_CODE
from
  amw.amw_fin_item_acc_ctrl ctrl,
  amw_opinions_log_v opinion,
  amw_control_objectives comp,
  amw_control_associations ctrlAsso
where
 ctrl.FIN_CERTIFICATION_ID= P_CERTIFICATION_ID and
 ctrl.OBJECT_TYPE = 'ACCOUNT' and
 --ctrl.FINANCIAL_ITEM_ID= P_FINANCIAL_ITEM_ID and
 ctrl.ACCOUNT_GROUP_ID = P_ACCOUNT_GROUP_ID and
 NATURAL_ACCOUNT_ID = P_ACCOUNT_ID and
 --opinion.OPINION_LOG_ID =   ctrl.OPINION_LOG_ID and
 opinion.pk1_value = ctrl.control_id and
 opinion.pk3_value = ctrl.ORGANIZATION_ID and
 opinion.audit_result_CODE <> 'EFFECTIVE' and
 opinion.OPINION_TYPE_CODE = 'EVALUATION' AND
 opinion.OBJECT_NAME = 'AMW_ORG_CONTROL'      and
 ctrl.CONTROL_REV_ID =comp.CONTROL_REV_ID and
  ctrlAsso.OBJECT_TYPE='RISK_FINCERT' and
 opinion.OPINION_LOG_ID =   ctrlAsso.PK5 and
 ctrlAsso.PK1 = ctrl.FIN_CERTIFICATION_ID and
 ctrlAsso.PK2 = ctrl.ORGANIZATION_ID  and
 ctrlAsso.CONTROL_ID = ctrl.control_id)
group by OBJECTIVE_CODE;
****/
SELECT COUNT(1) NUMINEFFCTRLS, OBJECTIVE_CODE
FROM
  (SELECT DISTINCT CTRL.ORGANIZATION_ID, CTRL.CONTROL_ID, COMP.OBJECTIVE_CODE
  FROM AMW.AMW_FIN_ITEM_ACC_CTRL CTRL,
  AMW_CONTROL_OBJECTIVES COMP
  WHERE
  CTRL.FIN_CERTIFICATION_ID= P_CERTIFICATION_ID
  AND CTRL.OBJECT_TYPE = 'ACCOUNT'
  AND CTRL.ACCOUNT_GROUP_ID = P_ACCOUNT_GROUP_ID
  AND NATURAL_ACCOUNT_ID = P_ACCOUNT_ID
  AND CTRL.CONTROL_REV_ID =COMP.CONTROL_REV_ID
  AND EXISTS
  (SELECT 1 FROM
  AMW_CONTROL_ASSOCIATIONS CTRLASSO
  WHERE
  CTRLASSO.OBJECT_TYPE='RISK_FINCERT'
  AND CTRLASSO.PK1 = P_CERTIFICATION_ID
  AND CTRLASSO.PK2 = CTRL.ORGANIZATION_ID
  AND CTRLASSO.CONTROL_ID = CTRL.CONTROL_ID
  AND EXISTS
  (SELECT 1 FROM AMW_OPINIONS_LOG_V OPINION
   WHERE
   OPINION.OPINION_LOG_ID = CTRLASSO.PK5
   AND OPINION.PK1_VALUE = CTRLASSO.CONTROL_ID
   AND OPINION.PK3_VALUE = CTRLASSO.PK2
   AND OPINION.AUDIT_RESULT_CODE <> 'EFFECTIVE'
   AND OPINION.OPINION_TYPE_CODE = 'EVALUATION'
   AND OPINION.OBJECT_NAME = 'AMW_ORG_CONTROL'
   ))) GROUP BY OBJECTIVE_CODE ;

---------------------------------------------------------------------------------------------------
cursor evaluated_ctrls_of_acc
is
select
 count(1) numOfEvaluatedCtrls,
 OBJECTIVE_CODE from
  (select
    distinct
    ctrl.ORGANIZATION_ID,  ctrl.control_id, comp.OBJECTIVE_CODE
from
  amw.amw_fin_item_acc_ctrl ctrl,
  amw_opinions_log_v opinion,
  amw_control_objectives comp,
  amw_control_associations ctrlAsso
where
 ctrl.FIN_CERTIFICATION_ID= P_CERTIFICATION_ID
 and
 ctrl.OBJECT_TYPE = 'ACCOUNT' and
 ctrl.ACCOUNT_GROUP_ID = P_ACCOUNT_GROUP_ID
 and
 NATURAL_ACCOUNT_ID = P_ACCOUNT_ID
 and
 opinion.pk1_value = ctrl.control_id and
 opinion.pk3_value = ctrl.ORGANIZATION_ID and
 opinion.OPINION_TYPE_CODE = 'EVALUATION' AND
 opinion.OBJECT_NAME = 'AMW_ORG_CONTROL'      and
 ctrl.CONTROL_REV_ID =comp.CONTROL_REV_ID and
  ctrlAsso.OBJECT_TYPE='RISK_FINCERT' and
 ctrlAsso.PK1 = ctrl.FIN_CERTIFICATION_ID and
 ctrlAsso.PK2 = ctrl.ORGANIZATION_ID  and
 ctrlAsso.CONTROL_ID = ctrl.control_id)
group by OBJECTIVE_CODE;

------------------------------------------------------------------------------------------------
cursor total_ctrl_of_accounts
is
select
 count(1) numOfCtrls,
 comp.OBJECTIVE_CODE
from
  amw.amw_fin_item_acc_ctrl ctrl,
  amw_control_objectives comp
where
 ctrl.FIN_CERTIFICATION_ID= P_CERTIFICATION_ID and
 ctrl.OBJECT_TYPE = 'ACCOUNT' and
-- ctrl.FINANCIAL_ITEM_ID= P_FINANCIAL_ITEM_ID and
 ACCOUNT_GROUP_ID = P_ACCOUNT_GROUP_ID and
 NATURAL_ACCOUNT_ID =P_ACCOUNT_ID   and
 ctrl.CONTROL_REV_ID =comp.CONTROL_REV_ID
group by  OBJECTIVE_CODE;



 -- *************** Currsor to get all Control AMW_CONTROL_OBJECTIVES ********** --

cursor CTRL_OBJECTIVES
 is
 select
  LOOKUP_CODE
 from
   amw_lookups
 where lookup_type = 'AMW_CONTROL_OBJECTIVES';

--********************* Get Inefftive Control *************************************************--



BEGIN

 --m_objectives_code := null;
 --ctr := 0;


 -- ************ Since the Table has 30 Fileds only initialize 30 Positios in the Array**************--
 ctr :=  1;

 loop
   EXIT  WHEN ctr > 30;

    m_objectives_code(ctr) := null;
    m_acc_assert_flag(ctr) := 'I';
    m_total_control(ctr) := 0;
    m_ineff_control(ctr) := 0;
    m_evaluated_ctrls  (ctr) := 0;


    ctr := ctr + 1;

 end loop; --end of initialization

 -- ************ get All Control Components Codes and Load it in an Array for later use **************--

 ctr := 0;
 for coso_rec in CTRL_OBJECTIVES
 loop
    exit when CTRL_OBJECTIVES%notfound;
    ctr := ctr + 1;
    m_objectives_code(ctr) := coso_rec.LOOKUP_CODE;

 end loop; --end of CTRL_OBJECTIVES loop

 max_num_of_codes := ctr;

 --dbms_output.put_line(' max_num_of_codes: ');
 --dbms_output.put_line(max_num_of_codes);


 if  max_num_of_codes > 0 then

     -- ************ get Total Controls and Ineff Ctrl for each Control Objective Codes For a Financial Item**************--

    if P_OBJECT_TYPE = 'FINANCIAL ITEM' then
       -- ************ get Total Controls for each objective / category Codes and Load it in an Array for later use **************--

       for tot_ctrls in tot_ctrl_of_item
       loop
          exit when tot_ctrl_of_item%notfound;
          v_OBJECTIVE_CODE := tot_ctrls.OBJECTIVE_CODE;

          ctr := 1;

          --  check the code is in which bucket and the appropriately add the counts

          while ctr <=  max_num_of_codes
          loop
             if  m_objectives_code(ctr) =  v_OBJECTIVE_CODE  then
               m_total_control(ctr) := tot_ctrls.numOfCtrls;

               --dbms_output.put_line( v_OBJECTIVE_CODE  );
               --dbms_output.put_line(' is the code and the total is ');

               --dbms_output.put_line(m_total_control(ctr) );

                exit;
             end if;
                 ctr := ctr + 1;

          end loop;
      end loop; --end of tot_ctrl_of_item for the Financial Item loop

    -- ************ get Total Controls Evaluted for each objective/category Codes and Load it in an Array for later use **************--

       for tot_eval_ctrls in evaluated_ctrls_of_item
       loop
          exit when evaluated_ctrls_of_item%notfound;
          v_OBJECTIVE_CODE := tot_eval_ctrls.OBJECTIVE_CODE;

          ctr := 1;

          --  check the code is in which bucket and the appropriately add the counts

          while ctr <=  max_num_of_codes
          loop
                if  m_objectives_code(ctr) =  v_OBJECTIVE_CODE  then
                m_evaluated_ctrls(ctr) := tot_eval_ctrls.numOfEvaluatedCtrls;


                exit;
             end if;
             ctr := ctr + 1;

          end loop;
      end loop; --end of evaluated_ctrls_of_item for the Fin Item loop



      -- ************ get Total Ineffective Controls for each objectives/ category Codes and Load it in an Array for later use **************--

       for tot_ineff_ctrls in ineff_ctrl_of_item
       loop
          exit when ineff_ctrl_of_item%notfound;
          v_OBJECTIVE_CODE := tot_ineff_ctrls.OBJECTIVE_CODE;

          ctr := 1;

          --  check the code is in which bucket and the appropriately add the counts

          while ctr <=  max_num_of_codes
          loop
             if  m_objectives_code(ctr) =  v_OBJECTIVE_CODE  then

                 m_ineff_control(ctr) :=  tot_ineff_ctrls.numIneffCtrls ;



               --dbms_output.put_line( v_OBJECTIVE_CODE  );
               --dbms_output.put_line(' is the code and the ineff ctrl is ');

               --dbms_output.put_line(m_ineff_control(ctr) );

                exit;
             end if;
               ctr := ctr + 1;

          end loop;
      end loop; --end of tot_ineff_ctrls  for the Financial Item loop



    end if; -- ****************** end if for P_OBJECT_TYPE = 'FINANCIAL ITEM'
     -- ******************************************************************************************** ----
     -- ************ get Total Controls and Ineff Ctrl for each Components Codes For a Account **************--
     -- ********************************************************************************************----

    if P_OBJECT_TYPE = 'ACCOUNT' then
       -- ************ get Total Controls for each control objective/category Codes and Load it in an Array for later use **************--

       for tot_ctrls_acc in total_ctrl_of_accounts
       loop
          exit when total_ctrl_of_accounts%notfound;
          v_OBJECTIVE_CODE := tot_ctrls_acc.OBJECTIVE_CODE;

          ctr := 1;

          --  check the code is in which bucket and the appropriately add the counts

          while ctr <=  max_num_of_codes
          loop

             if  m_objectives_code(ctr) =  v_OBJECTIVE_CODE  then
                 m_total_control(ctr) := tot_ctrls_acc.numOfCtrls;
                exit;
             end if;
             ctr := ctr + 1;
          end loop;
      end loop; --end of total_ctrl_of_accounts   for the Account loop

    -- ************ get Total Controls Evaluted for each objective/category Codes and Load it in an Array for later use **************--

       for tot_eval_ctrls in evaluated_ctrls_of_acc
       loop
          exit when evaluated_ctrls_of_acc%notfound;
          v_OBJECTIVE_CODE := tot_eval_ctrls.OBJECTIVE_CODE;

          ctr := 1;

          --  check the code is in which bucket and the appropriately add the counts

          while ctr <=  max_num_of_codes
          loop
             if  m_objectives_code(ctr) =  v_OBJECTIVE_CODE  then
                m_evaluated_ctrls(ctr) := tot_eval_ctrls.numOfEvaluatedCtrls;
                exit;
             end if;
             ctr := ctr + 1;

          end loop;
      end loop; --end of evaluated_ctrls_of_acc for the Account loop


      -- ************ get Total Ineffective Controls for each Components Codes and Load it in an Array for later use **************--

       for tot_ineff_ctrls_acc in in_eff_ctrl_of_accounts
       loop
          exit when in_eff_ctrl_of_accounts%notfound;
          v_OBJECTIVE_CODE := tot_ineff_ctrls_acc.OBJECTIVE_CODE;

          ctr := 1;

          --  check the code is in which bucket and the appropriately add the counts

          while ctr <=  max_num_of_codes
          loop
             if  m_objectives_code(ctr) =  v_OBJECTIVE_CODE  then

                 m_ineff_control(ctr) :=  tot_ineff_ctrls_acc.numIneffCtrls;


                exit;
             end if;
             ctr := ctr + 1;
          end loop;
      end loop; --end of in_eff_ctrl_of_accounts  for the Account loop



    end if; -- end if for P_OBJECT_TYPE = 'ACCOUNT'

   --  *********************   set column flag to "N" if there is at least on control for the objective or cotinue to be
   --  "ignore" if the total controls are 0 for the column

    ctr := 1;
    while ctr <=  max_num_of_codes
    loop

      if  nvl(m_total_control(ctr),0) > 0 then
          m_acc_assert_flag(ctr) := 'N';
      end if;
      ctr := ctr +1;
    end loop;

   -- ************* Check at lease one control exists for the row *******************************

    if set_display_flag(control_exists_array => m_total_control) then
        m_display_flag := 'Y';
     else
        m_display_flag := 'N';
     end if;



    -- ************************** CALL Proc to Insert Data into the Table **************************************** --

     --dbms_output.put_line('Objective - before inserting data');

    amw_fin_coso_views_pvt.INSERT_ROW(
     x_fin_certification_id       	=> 	P_CERTIFICATION_ID	,
     x_financial_statement_id    	=> 	P_FINANCIAL_STATEMENT_ID 	,
     x_financial_item_id         	=> 	P_FINANCIAL_ITEM_ID 	,
     x_account_group_id          	=> 	P_ACCOUNT_GROUP_ID  	,
     x_natural_account_id        	=> 	P_ACCOUNT_ID        	,
     x_object_type               	=> 	P_OBJECT_TYPE 	,
     x_ctrl_attribute_type       	=> 	 m_ctrl_attribute_type       	,
     x_ctrl_attr_code_1          	=> 	m_objectives_code(1)	,
     x_ineff_ctrl_attr_1         	=> 	m_ineff_control(1)	,
     x_total_ctrl_attr_1         	=> 	m_total_control(1)	,
     x_ctrl_attr_code_2          	=> 	m_objectives_code(2)	,
     x_ineff_ctrl_attr_2         	=> 	m_ineff_control(2)	,
     x_total_ctrl_attr_2         	=> 	m_total_control(2)	,
     x_ctrl_attr_code_3          	=> 	m_objectives_code(3)	,
     x_ineff_ctrl_attr_3         	=> 	m_ineff_control(3)	,
     x_total_ctrl_attr_3         	=> 	m_total_control(3)	,
     x_ctrl_attr_code_4          	=> 	m_objectives_code(4)	,
     x_ineff_ctrl_attr_4         	=> 	m_ineff_control(4)	,
     x_total_ctrl_attr_4         	=> 	m_total_control(4)	,
     x_ctrl_attr_code_5          	=> 	m_objectives_code(5)	,
     x_ineff_ctrl_attr_5         	=> 	m_ineff_control(5)	,
     x_total_ctrl_attr_5         	=> 	m_total_control(5)	,
     x_ctrl_attr_code_6          	=> 	m_objectives_code(6)	,
     x_ineff_ctrl_attr_6         	=> 	m_ineff_control(6)	,
     x_total_ctrl_attr_6         	=> 	m_total_control(6)	,
     x_ctrl_attr_code_7          	=> 	m_objectives_code(7)	,
     x_ineff_ctrl_attr_7         	=> 	m_ineff_control(7)	,
     x_total_ctrl_attr_7         	=> 	m_total_control(7)	,
     x_ctrl_attr_code_8          	=> 	m_objectives_code(8)	,
     x_ineff_ctrl_attr_8         	=> 	m_ineff_control(8)	,
     x_total_ctrl_attr_8         	=> 	m_total_control(8)	,
     x_ctrl_attr_code_9         	=> 	m_objectives_code(9)	,
     x_ineff_ctrl_attr_9         	=> 	m_ineff_control(9)	,
     x_total_ctrl_attr_9         	=> 	m_total_control(9)	,
     x_ctrl_attr_code_10         	=> 	m_objectives_code(10)	,
     x_ineff_ctrl_attr_10        	=> 	m_ineff_control(10)	,
     x_total_ctrl_attr_10        	=> 	m_total_control(10)	,
     x_ctrl_attr_code_11         	=> 	m_objectives_code(11)	,
     x_ineff_ctrl_attr_11        	=> 	m_ineff_control(11)	,
     x_total_ctrl_attr_11        	=> 	m_total_control(11)	,
     x_ctrl_attr_code_12         	=> 	m_objectives_code(12)	,
     x_ineff_ctrl_attr_12        	=> 	m_ineff_control(12)	,
     x_total_ctrl_attr_12        	=> 	m_total_control(12)	,
     x_ctrl_attr_code_13         	=> 	m_objectives_code(13)	,
     x_ineff_ctrl_attr_13        	=> 	m_ineff_control(13)	,
     x_total_ctrl_attr_13        	=> 	m_total_control(13)	,
     x_ctrl_attr_code_14         	=> 	m_objectives_code(14)	,
     x_ineff_ctrl_attr_14        	=> 	m_ineff_control(14)	,
     x_total_ctrl_attr_14        	=> 	m_total_control(14)	,
     x_ctrl_attr_code_15         	=> 	m_objectives_code(15)	,
     x_ineff_ctrl_attr_15        	=> 	m_ineff_control(15)	,
     x_total_ctrl_attr_15        	=> 	m_total_control(15)	,
     x_ctrl_attr_code_16         	=> 	m_objectives_code(16)	,
     x_ineff_ctrl_attr_16        	=> 	m_ineff_control(16)	,
     x_total_ctrl_attr_16        	=> 	m_total_control(16)	,
     x_ctrl_attr_code_17         	=> 	m_objectives_code(17)	,
     x_ineff_ctrl_attr_17        	=> 	m_ineff_control(17)	,
     x_total_ctrl_attr_17        	=> 	m_total_control(17)	,
     x_ctrl_attr_code_18         	=> 	m_objectives_code(18)	,
     x_ineff_ctrl_attr_18        	=> 	m_ineff_control(18)	,
     x_total_ctrl_attr_18        	=> 	m_total_control(18)	,
     x_ctrl_attr_code_19         	=> 	m_objectives_code(19)	,
     x_ineff_ctrl_attr_19        	=> 	m_ineff_control(19)	,
     x_total_ctrl_attr_19        	=> 	m_total_control(19)	,
     x_ctrl_attr_code_20         	=> 	m_objectives_code(20)	,
     x_ineff_ctrl_attr_20        	=> 	m_ineff_control(20)	,
     x_total_ctrl_attr_20        	=> 	m_total_control(20)	,
     x_ctrl_attr_code_21         	=> 	m_objectives_code(21)	,
     x_ineff_ctrl_attr_21        	=> 	m_ineff_control(21)	,
     x_total_ctrl_attr_21        	=> 	m_total_control(21)	,
     x_ctrl_attr_code_22         	=> 	m_objectives_code(22)	,
     x_ineff_ctrl_attr_22        	=> 	m_ineff_control(22)	,
     x_total_ctrl_attr_22        	=> 	m_total_control(22)	,
     x_ctrl_attr_code_23         	=> 	m_objectives_code(23)	,
     x_ineff_ctrl_attr_23        	=> 	m_ineff_control(23)	,
     x_total_ctrl_attr_23        	=> 	m_total_control(23)	,
     x_ctrl_attr_code_24         	=> 	m_objectives_code(24)	,
     x_ineff_ctrl_attr_24         	=> 	m_ineff_control(24)	,
     x_total_ctrl_attr_24        	=> 	m_total_control(24)	,
     x_ctrl_attr_code_25         	=> 	m_objectives_code(25)	,
     x_ineff_ctrl_attr_25        	=> 	m_ineff_control(25)	,
     x_total_ctrl_attr_25        	=> 	m_total_control(25)	,
     x_ctrl_attr_code_26         	=> 	m_objectives_code(26)	,
     x_ineff_ctrl_attr_26        	=> 	m_ineff_control(26)	,
     x_total_ctrl_attr_26        	=> 	m_total_control(26)	,
     x_ctrl_attr_code_27         	=> 	m_objectives_code(27)	,
     x_ineff_ctrl_attr_27        	=> 	m_ineff_control(27)	,
     x_total_ctrl_attr_27        	=> 	m_total_control(27)	,
     x_ctrl_attr_code_28         	=> 	m_objectives_code(28)	,
     x_ineff_ctrl_attr_28        	=> 	m_ineff_control(28)	,
     x_total_ctrl_attr_28        	=> 	m_total_control(28)	,
     x_ctrl_attr_code_29         	=> 	m_objectives_code(29)	,
     x_ineff_ctrl_attr_29        	=> 	m_ineff_control(29)	,
     x_total_ctrl_attr_29        	=> 	m_total_control(29)	,
     x_ctrl_attr_code_30         	=> 	m_objectives_code(30)	,
     x_ineff_ctrl_attr_30        	=> 	m_ineff_control(30)	,
     x_total_ctrl_attr_30        	=> 	m_total_control(30)	,
     x_created_by                	=> 	g_user_id	,
     x_creation_date             	=> 	SYSDATE	,
     x_last_updated_by           	=> 	g_user_id	,
     x_last_update_date          	=> 	SYSDATE	,
     x_last_update_login         	=> 	g_login_id	,
     --x_security_group_id         	=> 	null	,
     x_object_version_number     	=> 	null	,
     x_acc_assert_flag1         	=> 	m_acc_assert_flag(1),
     x_acc_assert_flag2         	=> 	m_acc_assert_flag(2),
     x_acc_assert_flag3         	=> 	m_acc_assert_flag(3),
     x_acc_assert_flag4         	=> 	m_acc_assert_flag(4),
     x_acc_assert_flag5         	=> 	m_acc_assert_flag(5),
     x_acc_assert_flag6         	=> 	m_acc_assert_flag(6),
     x_acc_assert_flag7         	=> 	m_acc_assert_flag(7),
     x_acc_assert_flag8         	=> 	m_acc_assert_flag(8),
     x_acc_assert_flag9         	=> 	m_acc_assert_flag(9),
     x_acc_assert_flag10        	=> 	m_acc_assert_flag(10),
     x_acc_assert_flag11         	=> 	m_acc_assert_flag(11),
     x_acc_assert_flag12         	=> 	m_acc_assert_flag(12),
     x_acc_assert_flag13         	=> 	m_acc_assert_flag(13),
     x_acc_assert_flag14         	=> 	m_acc_assert_flag(14),
     x_acc_assert_flag15         	=> 	m_acc_assert_flag(15),
     x_acc_assert_flag16         	=> 	m_acc_assert_flag(16),
     x_acc_assert_flag17         	=> 	m_acc_assert_flag(17),
     x_acc_assert_flag18         	=> 	m_acc_assert_flag(18),
     x_acc_assert_flag19         	=> 	m_acc_assert_flag(19),
     x_acc_assert_flag20        	=> 	m_acc_assert_flag(20),
     x_acc_assert_flag21         	=> 	m_acc_assert_flag(21),
     x_acc_assert_flag22         	=> 	m_acc_assert_flag(22),
     x_acc_assert_flag23         	=> 	m_acc_assert_flag(23),
     x_acc_assert_flag24         	=> 	m_acc_assert_flag(24),
     x_acc_assert_flag25         	=> 	m_acc_assert_flag(25),
     x_acc_assert_flag26         	=> 	m_acc_assert_flag(26),
     x_acc_assert_flag27         	=> 	m_acc_assert_flag(27),
     x_acc_assert_flag28         	=> 	m_acc_assert_flag(28),
     x_acc_assert_flag29         	=> 	m_acc_assert_flag(29),
     x_acc_assert_flag30        	=> 	m_acc_assert_flag(30),
     x_eval_ctrl_attr_1         	=> 	m_evaluated_ctrls(1),
     x_eval_ctrl_attr_2         	=> 	m_evaluated_ctrls(2),
     x_eval_ctrl_attr_3         	=> 	m_evaluated_ctrls(3),
     x_eval_ctrl_attr_4         	=> 	m_evaluated_ctrls(4),
     x_eval_ctrl_attr_5         	=> 	m_evaluated_ctrls(5),
     x_eval_ctrl_attr_6         	=> 	m_evaluated_ctrls(6),
     x_eval_ctrl_attr_7         	=> 	m_evaluated_ctrls(7),
     x_eval_ctrl_attr_8         	=> 	m_evaluated_ctrls(8),
     x_eval_ctrl_attr_9         	=> 	m_evaluated_ctrls(9),
     x_eval_ctrl_attr_10        	=> 	m_evaluated_ctrls(10),
     x_eval_ctrl_attr_11         	=> 	m_evaluated_ctrls(11),
     x_eval_ctrl_attr_12         	=> 	m_evaluated_ctrls(12),
     x_eval_ctrl_attr_13         	=> 	m_evaluated_ctrls(13),
     x_eval_ctrl_attr_14         	=> 	m_evaluated_ctrls(14),
     x_eval_ctrl_attr_15         	=> 	m_evaluated_ctrls(15),
     x_eval_ctrl_attr_16         	=> 	m_evaluated_ctrls(16),
     x_eval_ctrl_attr_17         	=> 	m_evaluated_ctrls(17),
     x_eval_ctrl_attr_18         	=> 	m_evaluated_ctrls(18),
     x_eval_ctrl_attr_19         	=> 	m_evaluated_ctrls(19),
     x_eval_ctrl_attr_20        	=> 	m_evaluated_ctrls(20),
     x_eval_ctrl_attr_21         	=> 	m_evaluated_ctrls(21),
     x_eval_ctrl_attr_22         	=> 	m_evaluated_ctrls(22),
     x_eval_ctrl_attr_23         	=> 	m_evaluated_ctrls(23),
     x_eval_ctrl_attr_24         	=> 	m_evaluated_ctrls(24),
     x_eval_ctrl_attr_25         	=> 	m_evaluated_ctrls(25),
     x_eval_ctrl_attr_26         	=> 	m_evaluated_ctrls(26),
     x_eval_ctrl_attr_27         	=> 	m_evaluated_ctrls(27),
     x_eval_ctrl_attr_28         	=> 	m_evaluated_ctrls(28),
     x_eval_ctrl_attr_29         	=> 	m_evaluated_ctrls(29),
     x_eval_ctrl_attr_30        	=> 	m_evaluated_ctrls(30),
     x_display_flag        	        => 	 m_display_flag );


 end if; -- end if for max_num_of_codes


 -- ************  EXCEPTION definitions for the Procedure **************--

EXCEPTION
     WHEN NO_DATA_FOUND
	     THEN
                 --dbms_output.put_line('Objective - NO_DATA_FOUND');

            fnd_file.put_line (fnd_file.LOG, SUBSTR ('No data found in Update_Next_Level_Proc_Info'
                || SUBSTR (SQLERRM, 1, 100), 1, 200));

     WHEN OTHERS
         THEN
                 --dbms_output.put_line('Objective -WHEN OTHERS');

            fnd_file.put_line (fnd_file.LOG, SUBSTR ('Unexpected Error in Update_Next_Level_Proc_Info'
                || SUBSTR (SQLERRM, 1, 100), 1, 200));

---COMMIT;
end;
end ; --create_fin_ctrl_components

/* ******************************************************************************************************** */

/* ******************************** Logic to build Control ASSERTION_CODE-wise Summary Data *************************************** */


 PROCEDURE create_fin_ctrl_Assertions
(P_CERTIFICATION_ID number ,
                  P_FINANCIAL_STATEMENT_ID number,
                  P_STATEMENT_GROUP_ID number,
                  P_FINANCIAL_ITEM_ID number,
                  P_ACCOUNT_GROUP_ID  number ,
                  P_ACCOUNT_ID        number ,
                  P_OBJECT_TYPE varchar2 ) is

/* ************************************** Example of Paraemters received *************************************

For Financial Items the Parameter Passed will be
    (P_CERTIFICATION_ID => l_certification_id,
                  P_FINANCIAL_STATEMENT_ID => Get_all_items_Rec.FINANCIAL_STATEMENT_ID ,
                  P_STATEMENT_GROUP_ID => Get_all_items_Rec.STATEMENT_GROUP_ID ,
                  P_FINANCIAL_ITEM_ID => Get_all_items_Rec.FINANCIAL_ITEM_ID,
                  P_ACCOUNT_GROUP_ID   => NULL,
                  P_ACCOUNT_ID         => NULL,
                  P_OBJECT_TYPE => 'FINANCIAL ITEM')

For Key Accounts the Parameter Passed will be

                  (P_CERTIFICATION_ID => l_certification_id,
                  P_STATEMENT_GROUP_ID => Get_all_accts_Rec.STATEMENT_GROUP_ID ,
                  P_FINANCIAL_STATEMENT_ID => Get_all_accts_Rec.FINANCIAL_STATEMENT_ID,
                  P_FINANCIAL_ITEM_ID => Get_all_accts_Rec.financial_item_id,
                  P_ACCOUNT_ID         => Get_all_accts_Rec.natural_account_id,
                  P_ACCOUNT_GROUP_ID   => Get_all_accts_Rec.account_group_id,
                  P_OBJECT_TYPE => 'ACCOUNT');


*******************************************************************************************************************
*/

begin
declare


 ctr integer :=0;
 max_num_of_codes integer :=0;
 m_ctrl_attribute_type VARCHAR2(30) :='CTRL_ASSERTIONS';

 m_assertions_code component_code_array;
 m_total_control  total_control_array ;
 m_ineff_control  ineff_control_array ;
 m_acc_assert_flag component_code_array;
 m_evaluated_ctrls  total_control_array ;

-- **m_assert_maped_2_acc component_code_array;


 m_display_flag varchar2(1) := 'N';




 v_ASSERTION_CODE varchar2(30);

 g_user_id              NUMBER        := fnd_global.user_id;
 g_login_id             NUMBER        := fnd_global.conc_login_id;
 g_errbuf               VARCHAR2(2000) := null;
 g_retcode              VARCHAR2(2)    :=  '0';

-- *************** Currsor to get all Control for the Fianancial Item being Passed ********** --

cursor ineff_ctrl_of_item
is
select
 count(1) numIneffCtrls,
 ASSERTION_CODE
from
  (select
    distinct
    ctrl.ORGANIZATION_ID,  ctrl.control_id, comp.ASSERTION_CODE
from
  amw.amw_fin_item_acc_ctrl ctrl,
  amw_opinions_log_v opinion,
  amw_control_assertions comp,
  amw_control_associations ctrlAsso
where
 ctrl.FIN_CERTIFICATION_ID=  P_CERTIFICATION_ID and
 ctrl.OBJECT_TYPE = 'FINANCIAL ITEM' and
 ctrl.FINANCIAL_ITEM_ID=  P_FINANCIAL_ITEM_ID and
 -- ctrl.ACCOUNT_GROUP_ID is null and
 -- ctrl.NATURAL_ACCOUNT_ID is null and
 --opinion.OPINION_LOG_ID =   ctrl.OPINION_LOG_ID and
 opinion.pk1_value = ctrl.control_id and
 opinion.pk3_value = ctrl.ORGANIZATION_ID and
 opinion.audit_result_CODE <> 'EFFECTIVE' and
 opinion.OPINION_TYPE_CODE = 'EVALUATION' AND
 opinion.OBJECT_NAME = 'AMW_ORG_CONTROL'  and
 ctrl.CONTROL_REV_ID =comp.CONTROL_REV_ID  and
  ctrlAsso.OBJECT_TYPE='RISK_FINCERT' and
 opinion.OPINION_LOG_ID =   ctrlAsso.PK5 and
 ctrlAsso.PK1 = ctrl.FIN_CERTIFICATION_ID and
 ctrlAsso.PK2 = ctrl.ORGANIZATION_ID  and
 ctrlAsso.CONTROL_ID = ctrl.control_id)
group by ASSERTION_CODE;
-------------------------------------------------------------------------------------------

cursor evaluated_ctrls_of_item
is
select
 count(1) numOfEvaluatedCtrls,
 ASSERTION_CODE
from
  (select
    distinct
    ctrl.ORGANIZATION_ID,  ctrl.control_id, comp.ASSERTION_CODE
from
  amw.amw_fin_item_acc_ctrl ctrl,
  amw_opinions_v opinion,
  amw_control_assertions comp,
  amw_control_associations ctrlAsso
where
 ctrl.FIN_CERTIFICATION_ID=   P_CERTIFICATION_ID
 and
 ctrl.OBJECT_TYPE = 'FINANCIAL ITEM' and
 ctrl.FINANCIAL_ITEM_ID=  P_FINANCIAL_ITEM_ID
 and
 opinion.pk1_value = ctrl.control_id and
 opinion.pk3_value = ctrl.ORGANIZATION_ID and
 opinion.OPINION_TYPE_CODE = 'EVALUATION' AND
 opinion.OBJECT_NAME = 'AMW_ORG_CONTROL'  and
 ctrl.CONTROL_REV_ID =comp.CONTROL_REV_ID  and
  ctrlAsso.OBJECT_TYPE='RISK_FINCERT' and
 ctrlAsso.PK1 = ctrl.FIN_CERTIFICATION_ID and
 ctrlAsso.PK2 = ctrl.ORGANIZATION_ID  and
 ctrlAsso.CONTROL_ID = ctrl.control_id)
group by ASSERTION_CODE;

-------------------------------------------------------------------------------------------


cursor tot_ctrl_of_item
is
select
 count(1) numOfCtrls,
 comp.ASSERTION_CODE
from
  amw.amw_fin_item_acc_ctrl ctrl,
  amw_control_assertions comp
where
 ctrl.FIN_CERTIFICATION_ID=P_CERTIFICATION_ID and
 ctrl.OBJECT_TYPE = 'FINANCIAL ITEM' and
 ctrl.FINANCIAL_ITEM_ID= P_FINANCIAL_ITEM_ID and
 --ctrl.ACCOUNT_GROUP_ID is null and
 --ctrl.NATURAL_ACCOUNT_ID is null and
 ctrl.CONTROL_REV_ID =comp.CONTROL_REV_ID
group by ASSERTION_CODE;



-- *************** Currsor to get all Control for the Fianancial Item being Passed ********** --

cursor in_eff_ctrl_of_accounts
is
--fix bug 5768982 by dliao on 2-12-2007
/****
select
 count(1) numIneffCtrls,
 ASSERTION_CODE
from
  (select
    distinct
    ctrl.ORGANIZATION_ID,  ctrl.control_id, comp.ASSERTION_CODE
 from
  amw.amw_fin_item_acc_ctrl ctrl,
  amw_opinions_log_v opinion,
  amw_control_assertions comp,
  amw_control_associations ctrlAsso
where
 ctrl.FIN_CERTIFICATION_ID=  P_CERTIFICATION_ID and
 ctrl.OBJECT_TYPE = 'ACCOUNT' and
 --ctrl.FINANCIAL_ITEM_ID= P_FINANCIAL_ITEM_ID and
 ctrl.ACCOUNT_GROUP_ID = P_ACCOUNT_GROUP_ID and
 NATURAL_ACCOUNT_ID = P_ACCOUNT_ID and
 --opinion.OPINION_LOG_ID =   ctrl.OPINION_LOG_ID and
 opinion.pk1_value = ctrl.control_id and
 opinion.pk3_value = ctrl.ORGANIZATION_ID and
 opinion.audit_result_CODE <> 'EFFECTIVE' and
 opinion.OPINION_TYPE_CODE = 'EVALUATION' AND
 opinion.OBJECT_NAME = 'AMW_ORG_CONTROL'      and
 ctrl.CONTROL_REV_ID =comp.CONTROL_REV_ID and
  ctrlAsso.OBJECT_TYPE='RISK_FINCERT' and
 opinion.OPINION_LOG_ID =   ctrlAsso.PK5 and
 ctrlAsso.PK1 = ctrl.FIN_CERTIFICATION_ID and
 ctrlAsso.PK2 = ctrl.ORGANIZATION_ID  and
 ctrlAsso.CONTROL_ID = ctrl.control_id)
group by ASSERTION_CODE;
***/
SELECT COUNT(1) NUMINEFFCTRLS, ASSERTION_CODE
FROM
   (SELECT DISTINCT CTRL.ORGANIZATION_ID, CTRL.CONTROL_ID, COMP.ASSERTION_CODE
  FROM AMW.AMW_FIN_ITEM_ACC_CTRL CTRL, AMW_CONTROL_ASSERTIONS COMP
  WHERE
  CTRL.FIN_CERTIFICATION_ID= P_CERTIFICATION_ID
  AND CTRL.OBJECT_TYPE = 'ACCOUNT'
  AND CTRL.ACCOUNT_GROUP_ID = P_ACCOUNT_GROUP_ID
  AND NATURAL_ACCOUNT_ID = P_ACCOUNT_ID
  AND CTRL.CONTROL_REV_ID = COMP.CONTROL_REV_ID
  AND EXISTS
  (SELECT 1 FROM AMW_OPINIONS_LOG_V OPINION
   WHERE OPINION.PK1_VALUE = CTRL.CONTROL_ID
   AND OPINION.PK3_VALUE = CTRL.ORGANIZATION_ID
   AND OPINION.AUDIT_RESULT_CODE <> 'EFFECTIVE'
   AND OPINION.OPINION_TYPE_CODE = 'EVALUATION'
   AND OPINION.OBJECT_NAME = 'AMW_ORG_CONTROL'
  AND EXISTS
  (SELECT 1 FROM AMW_CONTROL_ASSOCIATIONS CTRLASSO
  WHERE CTRLASSO.OBJECT_TYPE='RISK_FINCERT'
  AND OPINION.OPINION_LOG_ID = CTRLASSO.PK5
  AND CTRLASSO.PK1 = P_CERTIFICATION_ID
  AND CTRLASSO.PK2 = OPINION.PK3_VALUE
  AND CTRLASSO.CONTROL_ID = OPINION.PK1_VALUE
  ))) GROUP BY ASSERTION_CODE;


-----------------------------------------------------------------------------------------------
cursor total_ctrl_of_accounts
is
select
 count(1) numOfCtrls,
 comp.ASSERTION_CODE
from
  amw.amw_fin_item_acc_ctrl ctrl,
  amw_control_assertions comp
where
 ctrl.FIN_CERTIFICATION_ID= P_CERTIFICATION_ID and
 ctrl.OBJECT_TYPE = 'ACCOUNT' and
-- ctrl.FINANCIAL_ITEM_ID= P_FINANCIAL_ITEM_ID and
 ctrl.ACCOUNT_GROUP_ID = P_ACCOUNT_GROUP_ID and
 NATURAL_ACCOUNT_ID =P_ACCOUNT_ID   and
 ctrl.CONTROL_REV_ID =comp.CONTROL_REV_ID
group by  ASSERTION_CODE;
-----------------------------------------------------------------------------------------------

cursor evaluated_ctrls_of_acc
is
select
 count(1) numOfEvaluatedCtrls,
 ASSERTION_CODE
from
  (select
    distinct
    ctrl.ORGANIZATION_ID,  ctrl.control_id, comp.ASSERTION_CODE
 from
  amw.amw_fin_item_acc_ctrl ctrl,
  amw_opinions_log_v opinion,
  amw_control_assertions comp,
  amw_control_associations ctrlAsso
where
 ctrl.FIN_CERTIFICATION_ID=  P_CERTIFICATION_ID and
 ctrl.OBJECT_TYPE = 'ACCOUNT' and
 ctrl.ACCOUNT_GROUP_ID = P_ACCOUNT_GROUP_ID and
 NATURAL_ACCOUNT_ID =  P_ACCOUNT_ID and
 opinion.pk1_value = ctrl.control_id and
 opinion.pk3_value = ctrl.ORGANIZATION_ID and
 opinion.OPINION_TYPE_CODE = 'EVALUATION' AND
 opinion.OBJECT_NAME = 'AMW_ORG_CONTROL'      and
 ctrl.CONTROL_REV_ID =comp.CONTROL_REV_ID and
  ctrlAsso.OBJECT_TYPE='RISK_FINCERT' and
 ctrlAsso.PK1 = ctrl.FIN_CERTIFICATION_ID and
 ctrlAsso.PK2 = ctrl.ORGANIZATION_ID  and
 ctrlAsso.CONTROL_ID = ctrl.control_id)
group by ASSERTION_CODE;



 -- *************** Currsor to get all Control AMW_CONTROL_OBJECTIVES ********** --

cursor CTRL_ASSERTIONS
 is
 select
  LOOKUP_CODE
 from
   amw_lookups
 where lookup_type = 'AMW_CONTROL_ASSERTIONS';

--********************* Get Account Assertion COdes FOR AN ACCOUNT *************************************************--
/*
cursor ACC_ASSERT_CODES
 is
select
ASSERTION_CODE
from
amw_account_assertions
where
NATURAL_ACCOUNT_ID =P_ACCOUNT_ID  ;
*/

cursor ACC_ASSERT_CODES
 is
select
distinct
ASSERTION_CODE
from
amw_account_assertions
where
((NATURAL_ACCOUNT_ID =P_ACCOUNT_ID) or (NATURAL_ACCOUNT_ID in (select CHILD_NATURAL_ACCOUNT_ID from amw_fin_key_acct_flat
where  PARENT_NATURAL_ACCOUNT_ID  =P_ACCOUNT_ID and ACCOUNT_GROUP_ID=P_ACCOUNT_GROUP_ID)));


-- =================================  Get Account Assertion COdes FOR A FINANCIAL ITEM ===============================
cursor ACC_ASSERT_FOR_FIN_ITEM
 is
select DISTINCT
ASSERTION_CODE
from
amw_account_assertions
where
NATURAL_ACCOUNT_ID IN
(select DISTINCT NATURAL_ACCOUNT_ID from amw_fin_cert_scope where fin_certification_id = P_CERTIFICATION_ID and
financial_item_id = P_FINANCIAL_ITEM_ID );



-- *****************************************************************************************************



BEGIN

 --m_assertions_code := null;
 --ctr := 0;


 -- ************ Since the Table has 30 Fileds only initialize 30 Positios in the Array**************--
 ctr :=  1;

 loop
   EXIT  WHEN ctr > 30;

    m_assertions_code(ctr) := null;
    m_total_control(ctr) := 0;
    m_ineff_control(ctr) := 0;
    m_evaluated_ctrls(ctr) := 0;

  -- **m_assert_maped_2_acc(ctr) := 'N';

   --**************************************************************************************************************** --
   -- DEFAULT ASSUMPTION for m_acc_assert_flag(ctr) : The assertion is Not important for any of the accounts ot accounts
   -- of fin. Item then set the flag to 'I', (means ignore this column in the UI) based on which the data will be hidden
   -- in the UI
   --**************************************************************************************************************** --

    m_acc_assert_flag(ctr) := 'I';

    ctr := ctr + 1;

 end loop; --end of initialization

 -- ************ get All Control Components Codes and Load it in an Array for later use **************--

 ctr := 0;
 for coso_rec in CTRL_ASSERTIONS
 loop
    exit when CTRL_ASSERTIONS%notfound;
    ctr := ctr + 1;
    m_assertions_code(ctr) := coso_rec.LOOKUP_CODE;

 end loop; --end of CTRL_ASSERTIONS loop

 max_num_of_codes := ctr;


 --dbms_output.put_line(' max_num_of_codes: ');
 --dbms_output.put_line(max_num_of_codes);


 if  max_num_of_codes > 0 then

     -- ************ get Total Controls and Ineff Ctrl for each Components Codes For a Financial Item**************--

    if P_OBJECT_TYPE = 'FINANCIAL ITEM' then
       -- ************ get Total Controls for each Components Codes and Load it in an Array for later use **************--

       for tot_ctrls in tot_ctrl_of_item
       loop
          exit when tot_ctrl_of_item%notfound;
          v_ASSERTION_CODE := tot_ctrls.ASSERTION_CODE;

          ctr := 1;

          --  check the code is in which bucket and the appropriately add the counts

          while ctr <=  max_num_of_codes
          loop
             if  m_assertions_code(ctr) =  v_ASSERTION_CODE  then

                   m_total_control(ctr) := tot_ctrls.numOfCtrls;

               --dbms_output.put_line( v_ASSERTION_CODE  );
               --dbms_output.put_line(' is the code and the total is ');

               --dbms_output.put_line(m_total_control(ctr) );

                exit;
             end if;
                 ctr := ctr + 1;

          end loop;
      end loop; --end of tot_ctrl_of_item for the Financial Item loop


    -- ************ get Total Controls Evaluted for each Assertions Codes and Load it in an Array for later use **************--

       for tot_eval_ctrls in evaluated_ctrls_of_item
       loop
          exit when evaluated_ctrls_of_item%notfound;
          v_ASSERTION_CODE := tot_eval_ctrls.ASSERTION_CODE;

          ctr := 1;

          --  check the code is in which bucket and the appropriately add the counts

          while ctr <=  max_num_of_codes
          loop
            if  m_assertions_code(ctr) =  v_ASSERTION_CODE  then

                    m_evaluated_ctrls(ctr) := tot_eval_ctrls.numOfEvaluatedCtrls;
                 exit;
             end if;
             ctr := ctr + 1;

          end loop;
      end loop; --end of evaluated_ctrls_of_item for the Financial Item loop

      -- ************ get Total Ineffective Controls for each Components Codes and Load it in an Array for later use **************--

       for tot_ineff_ctrls in ineff_ctrl_of_item
       loop
          exit when ineff_ctrl_of_item%notfound;
          v_ASSERTION_CODE := tot_ineff_ctrls.ASSERTION_CODE;

          ctr := 1;

          --  check the code is in which bucket and the appropriately add the counts

          while ctr <=  max_num_of_codes
          loop
             if  m_assertions_code(ctr) =  v_ASSERTION_CODE  then

                    m_ineff_control(ctr) :=  tot_ineff_ctrls.numIneffCtrls ;


               --dbms_output.put_line( v_ASSERTION_CODE  );
               --dbms_output.put_line(' is the code and the ineff ctrl is ');

               --dbms_output.put_line(m_ineff_control(ctr) );

                exit;
             end if;
               ctr := ctr + 1;

          end loop;
      end loop; --end of tot_ineff_ctrls  for the Financial Item loop

  -- ======================== The Image Display Flag setting should be done last as it need ineffective control array ====== --

       for acc_assertions in ACC_ASSERT_FOR_FIN_ITEM
       loop
          exit when ACC_ASSERT_FOR_FIN_ITEM%notfound;

          ctr := 1;
          while ctr <=  max_num_of_codes
          loop

            --************************************************************************************************** --
            -- NOT ONLY CHECK WHETHER ONE OF THE ACCOUNT FOR THE FINANCIAL ITEM IS MAPPED TO THE ASSERTION CODE BUT ALSO
            -- THERE IS AT LEAST ONE CONROL (WHICH MAPPED TO THE SAME ASSERTION) AND ACCOUNT (THORUGH)
            -- IT RELATION TO PROCESS IS INEFFECTIVE
            --************************************************************************************************** --

             if  m_assertions_code(ctr) =  acc_assertions.ASSERTION_CODE then

                -- if the assertion is important for one of the accounts of fin. Item and one of
                -- the control is invlaid then set the flag to 'Y', based on which an image will appear in UI

                if nvl(m_ineff_control(ctr),0) > 0  then

                   m_acc_assert_flag(ctr) := 'Y';

                --************************************************************************************************** --
                -- else if the assertion is important for one of the accounts of fin. Item and No controls exist for the
                --  processes associated with the accounts then set the flag to 'Y', based on which an image will
                --- appear in UI
                --************************************************************************************************** --

                 elsif (nvl(m_total_control(ctr),0) = 0) then

                   m_acc_assert_flag(ctr) := 'Y';


                 --- ********** ie assertion is Not important for any of the accounts of fin. Item  and(nvl(m_total_control(ctr),0) > 0)
                 else
                    m_acc_assert_flag(ctr) := 'N';

                 end if;

                exit;
             end if;

             ctr := ctr +1;
          end loop;
       end loop; --end of acc_assertions in ACC_ASSERT_FOR_FIN_ITEM

--------------------------**********************************************------------------------


    end if; -- ****************** end if for P_OBJECT_TYPE = 'FINANCIAL ITEM'


     -- ******************************************************************************************** ----
     -- ************ get Total Controls and Ineff Ctrl for each Components Codes For a Account **************--
     -- ********************************************************************************************----

    if P_OBJECT_TYPE = 'ACCOUNT' then

       -- ************ get Total Controls for each Components Codes and Load it in an Array for later use **************--

       for tot_ctrls_acc in total_ctrl_of_accounts
       loop
          exit when total_ctrl_of_accounts%notfound;
          v_ASSERTION_CODE := tot_ctrls_acc.ASSERTION_CODE;

          ctr := 1;

          --  check the code is in which bucket and the appropriately add the counts

          while ctr <=  max_num_of_codes
          loop
             if  m_assertions_code(ctr) =  v_ASSERTION_CODE  then

                    m_total_control(ctr) := tot_ctrls_acc.numOfCtrls;

                exit;
             end if;
            ctr := ctr + 1;
          end loop;
      end loop; --end of total_ctrl_of_accounts   for the Account loop

   -- ************ get Total Controls Evaluted for each Components Codes and Load it in an Array for later use **************--

       for tot_eval_ctrls in evaluated_ctrls_of_acc
       loop
          exit when evaluated_ctrls_of_acc%notfound;
            v_ASSERTION_CODE := tot_eval_ctrls.ASSERTION_CODE;

          ctr := 1;

          --  check the code is in which bucket and the appropriately add the counts

          while ctr <=  max_num_of_codes
          loop
               if  m_assertions_code(ctr) =  v_ASSERTION_CODE  then

                     m_evaluated_ctrls(ctr) := tot_eval_ctrls.numOfEvaluatedCtrls;

                exit;
             end if;
             ctr := ctr + 1;

          end loop;
      end loop; --end of evaluated_ctrls_of_acc for the Account loop


      -- ************ get Total Ineffective Controls for each Components Codes and Load it in an Array for later use **************--

       for tot_ineff_ctrls_acc in in_eff_ctrl_of_accounts
       loop
          exit when in_eff_ctrl_of_accounts%notfound;
          v_ASSERTION_CODE := tot_ineff_ctrls_acc.ASSERTION_CODE;

          ctr := 1;

          --  check the code is in which bucket and the appropriately add the counts

          while ctr <=  max_num_of_codes
          loop
             if  m_assertions_code(ctr) =  v_ASSERTION_CODE  then


                    m_ineff_control(ctr) :=  tot_ineff_ctrls_acc.numIneffCtrls;


                exit;
             end if;
             ctr := ctr + 1;
          end loop;
      end loop; --end of in_eff_ctrl_of_accounts  for the Account loop


  --************ The Image Display Flag setting should be done last as it need ineffective control array *********--

       for acc_assertions in ACC_ASSERT_CODES
       loop
          exit when ACC_ASSERT_CODES%notfound;

          ctr := 1;
          while ctr <=  max_num_of_codes
          loop

            -- NOT ONLY CHECK WHETHER THE ACCOUNT IS MAPPED TO THE ASSERTION CODE BUT ALSO
            -- THERE IS AT LEASE ONE CONROL (WHICH MAPPED TO THE SAME ASSERTION) AND ACCOUNT (THORUGH)
            -- IT RELATION TO PROCESS IS INEFFECTIVE

             if  (m_assertions_code(ctr) =  acc_assertions.ASSERTION_CODE) then

                -- if the assertion is important for the accounts and one of
                -- the control is invlaid then set the flag to 'Y', based on which an image will appear in UI


                if nvl(m_ineff_control(ctr),0) > 0  then

                   m_acc_assert_flag(ctr) := 'Y';

                --************************************************************************************************** --
                -- else if the assertion is important for the account and No controls exist for the
                --  processes associated with the accounts then set the flag to 'Y', based on which an image will
                --- appear in UI
                --************************************************************************************************** --

                 elsif (nvl(m_total_control(ctr),0) = 0) then

                   m_acc_assert_flag(ctr) := 'Y';


                 --- ********** ie assertion is Not important for the account and(nvl(m_total_control(ctr),0) > 0)
                 else
                    m_acc_assert_flag(ctr) := 'N';

                 end if;

                exit;
             end if;
             ctr := ctr +1;
          end loop;
       end loop; --end of acc_assertions in ACC_ASSERT_CODES
  --------------------------**********************************************------------------------

    end if; -- end if for P_OBJECT_TYPE = 'ACCOUNT'


   -- ************* Check at lease one control exists for the row *******************************


    if set_flag_for_assertions( assert_acc_reln_exist=>  m_acc_assert_flag) then

        m_display_flag := 'Y';
     else
        m_display_flag := 'N';
     end if;



    -- ************************** CALL Proc to Insert Data into the Table **************************************** --

     --dbms_output.put_line('Objective - before inserting data');

    amw_fin_coso_views_pvt.INSERT_ROW(
     x_fin_certification_id       	=> 	P_CERTIFICATION_ID	,
     x_financial_statement_id    	=> 	P_FINANCIAL_STATEMENT_ID 	,
     x_financial_item_id         	=> 	P_FINANCIAL_ITEM_ID 	,
     x_account_group_id          	=> 	P_ACCOUNT_GROUP_ID  	,
     x_natural_account_id        	=> 	P_ACCOUNT_ID        	,
     x_object_type               	=> 	P_OBJECT_TYPE 	,
     x_ctrl_attribute_type       	=> 	m_ctrl_attribute_type       	,
     x_ctrl_attr_code_1          	=> 	m_assertions_code(1)	,
     x_ineff_ctrl_attr_1         	=> 	m_ineff_control(1)	,
     x_total_ctrl_attr_1         	=> 	m_total_control(1)	,
     x_ctrl_attr_code_2          	=> 	m_assertions_code(2)	,
     x_ineff_ctrl_attr_2         	=> 	m_ineff_control(2)	,
     x_total_ctrl_attr_2         	=> 	m_total_control(2)	,
     x_ctrl_attr_code_3          	=> 	m_assertions_code(3)	,
     x_ineff_ctrl_attr_3         	=> 	m_ineff_control(3)	,
     x_total_ctrl_attr_3         	=> 	m_total_control(3)	,
     x_ctrl_attr_code_4          	=> 	m_assertions_code(4)	,
     x_ineff_ctrl_attr_4         	=> 	m_ineff_control(4)	,
     x_total_ctrl_attr_4         	=> 	m_total_control(4)	,
     x_ctrl_attr_code_5          	=> 	m_assertions_code(5)	,
     x_ineff_ctrl_attr_5         	=> 	m_ineff_control(5)	,
     x_total_ctrl_attr_5         	=> 	m_total_control(5)	,
     x_ctrl_attr_code_6          	=> 	m_assertions_code(6)	,
     x_ineff_ctrl_attr_6         	=> 	m_ineff_control(6)	,
     x_total_ctrl_attr_6         	=> 	m_total_control(6)	,
     x_ctrl_attr_code_7          	=> 	m_assertions_code(7)	,
     x_ineff_ctrl_attr_7         	=> 	m_ineff_control(7)	,
     x_total_ctrl_attr_7         	=> 	m_total_control(7)	,
     x_ctrl_attr_code_8          	=> 	m_assertions_code(8)	,
     x_ineff_ctrl_attr_8         	=> 	m_ineff_control(8)	,
     x_total_ctrl_attr_8         	=> 	m_total_control(8)	,
     x_ctrl_attr_code_9         	=> 	m_assertions_code(9)	,
     x_ineff_ctrl_attr_9         	=> 	m_ineff_control(9)	,
     x_total_ctrl_attr_9         	=> 	m_total_control(9)	,
     x_ctrl_attr_code_10         	=> 	m_assertions_code(10)	,
     x_ineff_ctrl_attr_10        	=> 	m_ineff_control(10)	,
     x_total_ctrl_attr_10        	=> 	m_total_control(10)	,
     x_ctrl_attr_code_11         	=> 	m_assertions_code(11)	,
     x_ineff_ctrl_attr_11        	=> 	m_ineff_control(11)	,
     x_total_ctrl_attr_11        	=> 	m_total_control(11)	,
     x_ctrl_attr_code_12         	=> 	m_assertions_code(12)	,
     x_ineff_ctrl_attr_12        	=> 	m_ineff_control(12)	,
     x_total_ctrl_attr_12        	=> 	m_total_control(12)	,
     x_ctrl_attr_code_13         	=> 	m_assertions_code(13)	,
     x_ineff_ctrl_attr_13        	=> 	m_ineff_control(13)	,
     x_total_ctrl_attr_13        	=> 	m_total_control(13)	,
     x_ctrl_attr_code_14         	=> 	m_assertions_code(14)	,
     x_ineff_ctrl_attr_14        	=> 	m_ineff_control(14)	,
     x_total_ctrl_attr_14        	=> 	m_total_control(14)	,
     x_ctrl_attr_code_15         	=> 	m_assertions_code(15)	,
     x_ineff_ctrl_attr_15        	=> 	m_ineff_control(15)	,
     x_total_ctrl_attr_15        	=> 	m_total_control(15)	,
     x_ctrl_attr_code_16         	=> 	m_assertions_code(16)	,
     x_ineff_ctrl_attr_16        	=> 	m_ineff_control(16)	,
     x_total_ctrl_attr_16        	=> 	m_total_control(16)	,
     x_ctrl_attr_code_17         	=> 	m_assertions_code(17)	,
     x_ineff_ctrl_attr_17        	=> 	m_ineff_control(17)	,
     x_total_ctrl_attr_17        	=> 	m_total_control(17)	,
     x_ctrl_attr_code_18         	=> 	m_assertions_code(18)	,
     x_ineff_ctrl_attr_18        	=> 	m_ineff_control(18)	,
     x_total_ctrl_attr_18        	=> 	m_total_control(18)	,
     x_ctrl_attr_code_19         	=> 	m_assertions_code(19)	,
     x_ineff_ctrl_attr_19        	=> 	m_ineff_control(19)	,
     x_total_ctrl_attr_19        	=> 	m_total_control(19)	,
     x_ctrl_attr_code_20         	=> 	m_assertions_code(20)	,
     x_ineff_ctrl_attr_20        	=> 	m_ineff_control(20)	,
     x_total_ctrl_attr_20        	=> 	m_total_control(20)	,
     x_ctrl_attr_code_21         	=> 	m_assertions_code(21)	,
     x_ineff_ctrl_attr_21        	=> 	m_ineff_control(21)	,
     x_total_ctrl_attr_21        	=> 	m_total_control(21)	,
     x_ctrl_attr_code_22         	=> 	m_assertions_code(22)	,
     x_ineff_ctrl_attr_22        	=> 	m_ineff_control(22)	,
     x_total_ctrl_attr_22        	=> 	m_total_control(22)	,
     x_ctrl_attr_code_23         	=> 	m_assertions_code(23)	,
     x_ineff_ctrl_attr_23        	=> 	m_ineff_control(23)	,
     x_total_ctrl_attr_23        	=> 	m_total_control(23)	,
     x_ctrl_attr_code_24         	=> 	m_assertions_code(24)	,
     x_ineff_ctrl_attr_24         	=> 	m_ineff_control(24)	,
     x_total_ctrl_attr_24        	=> 	m_total_control(24)	,
     x_ctrl_attr_code_25         	=> 	m_assertions_code(25)	,
     x_ineff_ctrl_attr_25        	=> 	m_ineff_control(25)	,
     x_total_ctrl_attr_25        	=> 	m_total_control(25)	,
     x_ctrl_attr_code_26         	=> 	m_assertions_code(26)	,
     x_ineff_ctrl_attr_26        	=> 	m_ineff_control(26)	,
     x_total_ctrl_attr_26        	=> 	m_total_control(26)	,
     x_ctrl_attr_code_27         	=> 	m_assertions_code(27)	,
     x_ineff_ctrl_attr_27        	=> 	m_ineff_control(27)	,
     x_total_ctrl_attr_27        	=> 	m_total_control(27)	,
     x_ctrl_attr_code_28         	=> 	m_assertions_code(28)	,
     x_ineff_ctrl_attr_28        	=> 	m_ineff_control(28)	,
     x_total_ctrl_attr_28        	=> 	m_total_control(28)	,
     x_ctrl_attr_code_29         	=> 	m_assertions_code(29)	,
     x_ineff_ctrl_attr_29        	=> 	m_ineff_control(29)	,
     x_total_ctrl_attr_29        	=> 	m_total_control(29)	,
     x_ctrl_attr_code_30         	=> 	m_assertions_code(30)	,
     x_ineff_ctrl_attr_30        	=> 	m_ineff_control(30)	,
     x_total_ctrl_attr_30        	=> 	m_total_control(30)	,
     x_created_by                	=> 	g_user_id	,
     x_creation_date             	=> 	SYSDATE	,
     x_last_updated_by           	=> 	g_user_id	,
     x_last_update_date          	=> 	SYSDATE	,
     x_last_update_login         	=> 	g_login_id	,
     --x_security_group_id         	=> 	null	,
     x_object_version_number     	=> 	null	,
     x_acc_assert_flag1         	=> 	m_acc_assert_flag(1),
     x_acc_assert_flag2         	=> 	m_acc_assert_flag(2),
     x_acc_assert_flag3         	=> 	m_acc_assert_flag(3),
     x_acc_assert_flag4         	=> 	m_acc_assert_flag(4),
     x_acc_assert_flag5         	=> 	m_acc_assert_flag(5),
     x_acc_assert_flag6         	=> 	m_acc_assert_flag(6),
     x_acc_assert_flag7         	=> 	m_acc_assert_flag(7),
     x_acc_assert_flag8         	=> 	m_acc_assert_flag(8),
     x_acc_assert_flag9         	=> 	m_acc_assert_flag(9),
     x_acc_assert_flag10        	=> 	m_acc_assert_flag(10),
     x_acc_assert_flag11         	=> 	m_acc_assert_flag(11),
     x_acc_assert_flag12         	=> 	m_acc_assert_flag(12),
     x_acc_assert_flag13         	=> 	m_acc_assert_flag(13),
     x_acc_assert_flag14         	=> 	m_acc_assert_flag(14),
     x_acc_assert_flag15         	=> 	m_acc_assert_flag(15),
     x_acc_assert_flag16         	=> 	m_acc_assert_flag(16),
     x_acc_assert_flag17         	=> 	m_acc_assert_flag(17),
     x_acc_assert_flag18         	=> 	m_acc_assert_flag(18),
     x_acc_assert_flag19         	=> 	m_acc_assert_flag(19),
     x_acc_assert_flag20        	=> 	m_acc_assert_flag(20),
     x_acc_assert_flag21         	=> 	m_acc_assert_flag(21),
     x_acc_assert_flag22         	=> 	m_acc_assert_flag(22),
     x_acc_assert_flag23         	=> 	m_acc_assert_flag(23),
     x_acc_assert_flag24         	=> 	m_acc_assert_flag(24),
     x_acc_assert_flag25         	=> 	m_acc_assert_flag(25),
     x_acc_assert_flag26         	=> 	m_acc_assert_flag(26),
     x_acc_assert_flag27         	=> 	m_acc_assert_flag(27),
     x_acc_assert_flag28         	=> 	m_acc_assert_flag(28),
     x_acc_assert_flag29         	=> 	m_acc_assert_flag(29),
     x_acc_assert_flag30        	=> 	m_acc_assert_flag(30),
     x_eval_ctrl_attr_1         	=> 	m_evaluated_ctrls(1),
     x_eval_ctrl_attr_2         	=> 	m_evaluated_ctrls(2),
     x_eval_ctrl_attr_3         	=> 	m_evaluated_ctrls(3),
     x_eval_ctrl_attr_4         	=> 	m_evaluated_ctrls(4),
     x_eval_ctrl_attr_5         	=> 	m_evaluated_ctrls(5),
     x_eval_ctrl_attr_6         	=> 	m_evaluated_ctrls(6),
     x_eval_ctrl_attr_7         	=> 	m_evaluated_ctrls(7),
     x_eval_ctrl_attr_8         	=> 	m_evaluated_ctrls(8),
     x_eval_ctrl_attr_9         	=> 	m_evaluated_ctrls(9),
     x_eval_ctrl_attr_10        	=> 	m_evaluated_ctrls(10),
     x_eval_ctrl_attr_11         	=> 	m_evaluated_ctrls(11),
     x_eval_ctrl_attr_12         	=> 	m_evaluated_ctrls(12),
     x_eval_ctrl_attr_13         	=> 	m_evaluated_ctrls(13),
     x_eval_ctrl_attr_14         	=> 	m_evaluated_ctrls(14),
     x_eval_ctrl_attr_15         	=> 	m_evaluated_ctrls(15),
     x_eval_ctrl_attr_16         	=> 	m_evaluated_ctrls(16),
     x_eval_ctrl_attr_17         	=> 	m_evaluated_ctrls(17),
     x_eval_ctrl_attr_18         	=> 	m_evaluated_ctrls(18),
     x_eval_ctrl_attr_19         	=> 	m_evaluated_ctrls(19),
     x_eval_ctrl_attr_20        	=> 	m_evaluated_ctrls(20),
     x_eval_ctrl_attr_21         	=> 	m_evaluated_ctrls(21),
     x_eval_ctrl_attr_22         	=> 	m_evaluated_ctrls(22),
     x_eval_ctrl_attr_23         	=> 	m_evaluated_ctrls(23),
     x_eval_ctrl_attr_24         	=> 	m_evaluated_ctrls(24),
     x_eval_ctrl_attr_25         	=> 	m_evaluated_ctrls(25),
     x_eval_ctrl_attr_26         	=> 	m_evaluated_ctrls(26),
     x_eval_ctrl_attr_27         	=> 	m_evaluated_ctrls(27),
     x_eval_ctrl_attr_28         	=> 	m_evaluated_ctrls(28),
     x_eval_ctrl_attr_29         	=> 	m_evaluated_ctrls(29),
     x_eval_ctrl_attr_30        	=> 	m_evaluated_ctrls(30),
     x_display_flag        	        => 	 m_display_flag );

 end if; -- end if for max_num_of_codes


 -- ************  EXCEPTION definitions for the Procedure **************--

EXCEPTION
     WHEN NO_DATA_FOUND
	     THEN
                 --dbms_output.put_line('Objective - NO_DATA_FOUND');

            fnd_file.put_line (fnd_file.LOG, SUBSTR ('No data found in Update_Next_Level_Proc_Info'
                || SUBSTR (SQLERRM, 1, 100), 1, 200));

     WHEN OTHERS
         THEN
                 --dbms_output.put_line('Objective -WHEN OTHERS');

            fnd_file.put_line (fnd_file.LOG, SUBSTR ('Unexpected Error in Update_Next_Level_Proc_Info'
                || SUBSTR (SQLERRM, 1, 100), 1, 200));

---COMMIT;
end;
end ; --create_fin_ctrl_components

/* ******************************************************************************************************** */





/* **************************** DELETE_ROWS in case of refresh data for a particular certification ******************* */

procedure DELETE_ROWS ( x_fin_certification_id    NUMBER  ) IS

begin

DELETE
from
 amw_fin_cert_ctrl_sum
where
 fin_certification_id     = x_fin_certification_id  ;


EXCEPTION
WHEN OTHERS THEN
 fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
-- dbms_output.put_line(SQLERRM);
  fnd_file.put_line(fnd_file.LOG,  'fin_certification_id  ' || x_fin_certification_id  );

-- g_errbuf := SUBSTR (SQLERRM, 1, 2000)  ;
-- g_retcode := '2';

 RAISE ;
 RETURN;

end DELETE_ROWS ;

-------------------------------------------------------------------------------------
/* ************** Check at least one control exists and set display flag to Yes **********************************/

function set_display_flag(control_exists_array total_control_array)
return boolean is
begin
 declare
  ctr number := 1;

  begin

   --  Check at least one control exists and set display flag to Yes


   while ctr <=  30
   loop


 -- ========= nvl was introduced --

   if  nvl(control_exists_array(ctr),0) > 0 then
       return True;
       exit;
   end if;
   ctr := ctr + 1;

   end loop;
   return False;
 END;
end set_display_flag;
-------------------------------------------------------------------------------------
/* ************** Check at least one assertion is important to the Item or Accounts before setting display flag to Yes **********************************/

function set_flag_for_assertions( assert_acc_reln_exist component_code_array)
return boolean is
begin
 declare
  ctr number := 1;

  begin

   --******************************************************************************************************************
   --  Check at least one assertion is mapped to the account or the accounts of the fin. item and then set display flag
   -- to Yes in the UI Page this FALG is used to control whether to show a line will all column values 0 (zero) or not..
   --******************************************************************************************************************
   while ctr <=  30
   loop

   -- "Y" means a relation between account/fin item and the an Assertion exists and it also has an ineffective or zero control
   -- "N" means a relation between account/fin item and the an Assertion exists and it has controls but no ineffective ones.
   -- The other value do the assert_acc_reln_exist could be "I" , means ignore this column and not intersted in the UI. If all
   -- column are to be ignored (I), the whole record need not be displayed,hence the DISPLAY_FLAG will be set to "N"


   if  (assert_acc_reln_exist(ctr) = 'Y' or assert_acc_reln_exist(ctr) = 'N') then
       return True;
       exit;
   end if;
   ctr := ctr + 1;

   end loop;
   return False;
 END;
end set_flag_for_assertions;


/* ******************************************* INSERT_ROW  ************************************************************* */

procedure INSERT_ROW (
 x_fin_certification_id       	NUMBER  ,
 x_financial_statement_id    	 NUMBER ,
 x_financial_item_id         	 NUMBER ,
 x_account_group_id          	 NUMBER,
 x_natural_account_id        	 NUMBER,
 x_object_type               	 VARCHAR2,
 x_ctrl_attribute_type       	 VARCHAR2,
 x_ctrl_attr_code_1          	 VARCHAR2,
 x_ineff_ctrl_attr_1         	 NUMBER,
 x_total_ctrl_attr_1         	 NUMBER,
 x_ctrl_attr_code_2          	 VARCHAR2,
 x_ineff_ctrl_attr_2         	 NUMBER,
 x_total_ctrl_attr_2         	 NUMBER,
 x_ctrl_attr_code_3          	 VARCHAR2,
 x_ineff_ctrl_attr_3         	 NUMBER,
 x_total_ctrl_attr_3         	 NUMBER,
 x_ctrl_attr_code_4          	 VARCHAR2,
 x_ineff_ctrl_attr_4         	 NUMBER,
 x_total_ctrl_attr_4         	 NUMBER,
 x_ctrl_attr_code_5          	 VARCHAR2,
 x_ineff_ctrl_attr_5         	 NUMBER,
 x_total_ctrl_attr_5         	 NUMBER,
 x_ctrl_attr_code_6          	 VARCHAR2,
 x_ineff_ctrl_attr_6         	 NUMBER,
 x_total_ctrl_attr_6         	 NUMBER,
 x_ctrl_attr_code_7          	 VARCHAR2,
 x_ineff_ctrl_attr_7         	 NUMBER,
 x_total_ctrl_attr_7         	 NUMBER,
 x_ctrl_attr_code_8          	 VARCHAR2,
 x_ineff_ctrl_attr_8         	 NUMBER,
 x_total_ctrl_attr_8         	 NUMBER,
 x_ctrl_attr_code_9         	  VARCHAR2,
 x_ineff_ctrl_attr_9         	 NUMBER,
 x_total_ctrl_attr_9         	 NUMBER,
 x_ctrl_attr_code_10         	  VARCHAR2,
 x_ineff_ctrl_attr_10        	  NUMBER,
 x_total_ctrl_attr_10        	  NUMBER,
 x_ctrl_attr_code_11         	  VARCHAR2,
 x_ineff_ctrl_attr_11        	  NUMBER,
 x_total_ctrl_attr_11        	  NUMBER,
 x_ctrl_attr_code_12         	  VARCHAR2,
 x_ineff_ctrl_attr_12        	  NUMBER,
 x_total_ctrl_attr_12        	  NUMBER,
 x_ctrl_attr_code_13         	  VARCHAR2,
 x_ineff_ctrl_attr_13        	  NUMBER,
 x_total_ctrl_attr_13        	  NUMBER,
 x_ctrl_attr_code_14         	  VARCHAR2,
 x_ineff_ctrl_attr_14        	  NUMBER,
 x_total_ctrl_attr_14        	  NUMBER,
 x_ctrl_attr_code_15         	  VARCHAR2,
 x_ineff_ctrl_attr_15        	  NUMBER,
 x_total_ctrl_attr_15        	  NUMBER,
 x_ctrl_attr_code_16         	  VARCHAR2,
 x_ineff_ctrl_attr_16        	  NUMBER,
 x_total_ctrl_attr_16        	  NUMBER,
 x_ctrl_attr_code_17         	  VARCHAR2,
 x_ineff_ctrl_attr_17        	  NUMBER,
 x_total_ctrl_attr_17        	  NUMBER,
 x_ctrl_attr_code_18         	  VARCHAR2,
 x_ineff_ctrl_attr_18        	  NUMBER,
 x_total_ctrl_attr_18        	  NUMBER,
 x_ctrl_attr_code_19         	  VARCHAR2,
 x_ineff_ctrl_attr_19        	  NUMBER,
 x_total_ctrl_attr_19        	  NUMBER,
 x_ctrl_attr_code_20         	  VARCHAR2,
 x_ineff_ctrl_attr_20        	  NUMBER,
 x_total_ctrl_attr_20        	  NUMBER,
 x_ctrl_attr_code_21         	  VARCHAR2,
 x_ineff_ctrl_attr_21        	  NUMBER,
 x_total_ctrl_attr_21        	  NUMBER,
 x_ctrl_attr_code_22         	  VARCHAR2,
 x_ineff_ctrl_attr_22        	  NUMBER,
 x_total_ctrl_attr_22        	  NUMBER,
 x_ctrl_attr_code_23         	  VARCHAR2,
 x_ineff_ctrl_attr_23        	  NUMBER,
 x_total_ctrl_attr_23        	  NUMBER,
 x_ctrl_attr_code_24         	  VARCHAR2,
 x_ineff_ctrl_attr_24         	 NUMBER,
 x_total_ctrl_attr_24        	  NUMBER,
 x_ctrl_attr_code_25         	  VARCHAR2,
 x_ineff_ctrl_attr_25        	  NUMBER,
 x_total_ctrl_attr_25        	  NUMBER,
 x_ctrl_attr_code_26         	  VARCHAR2,
 x_ineff_ctrl_attr_26        	  NUMBER,
 x_total_ctrl_attr_26        	  NUMBER,
 x_ctrl_attr_code_27         	  VARCHAR2,
 x_ineff_ctrl_attr_27        	  NUMBER,
 x_total_ctrl_attr_27        	  NUMBER,
 x_ctrl_attr_code_28         	  VARCHAR2,
 x_ineff_ctrl_attr_28        	  NUMBER,
 x_total_ctrl_attr_28        	  NUMBER,
 x_ctrl_attr_code_29         	  VARCHAR2,
 x_ineff_ctrl_attr_29        	  NUMBER,
 x_total_ctrl_attr_29        	  NUMBER,
 x_ctrl_attr_code_30         	  VARCHAR2,
 x_ineff_ctrl_attr_30        	  NUMBER,
 x_total_ctrl_attr_30        	  NUMBER,
 x_created_by                	 NUMBER ,
 x_creation_date             	 DATE ,
 x_last_updated_by           	 NUMBER,
 x_last_update_date          	 DATE ,
 x_last_update_login         	 NUMBER,
-- x_security_group_id         	 NUMBER,
 x_object_version_number     	 NUMBER,
x_acc_assert_flag1         	  VARCHAR2,
x_acc_assert_flag2         	  VARCHAR2,
x_acc_assert_flag3         	  VARCHAR2,
x_acc_assert_flag4         	  VARCHAR2,
x_acc_assert_flag5         	  VARCHAR2,
x_acc_assert_flag6         	  VARCHAR2,
x_acc_assert_flag7         	  VARCHAR2,
x_acc_assert_flag8         	  VARCHAR2,
x_acc_assert_flag9         	  VARCHAR2,
x_acc_assert_flag10        	  VARCHAR2,
x_acc_assert_flag11         	  VARCHAR2,
x_acc_assert_flag12         	  VARCHAR2,
x_acc_assert_flag13         	  VARCHAR2,
x_acc_assert_flag14         	  VARCHAR2,
x_acc_assert_flag15         	  VARCHAR2,
x_acc_assert_flag16         	  VARCHAR2,
x_acc_assert_flag17         	  VARCHAR2,
x_acc_assert_flag18         	  VARCHAR2,
x_acc_assert_flag19         	  VARCHAR2,
x_acc_assert_flag20        	  VARCHAR2,
x_acc_assert_flag21         	  VARCHAR2,
x_acc_assert_flag22         	  VARCHAR2,
x_acc_assert_flag23         	  VARCHAR2,
x_acc_assert_flag24         	  VARCHAR2,
x_acc_assert_flag25         	  VARCHAR2,
x_acc_assert_flag26         	  VARCHAR2,
x_acc_assert_flag27         	  VARCHAR2,
x_acc_assert_flag28         	  VARCHAR2,
x_acc_assert_flag29         	  VARCHAR2,
x_acc_assert_flag30        	  VARCHAR2,
x_eval_ctrl_attr_1         	  NUMBER,
x_eval_ctrl_attr_2         	  NUMBER,
x_eval_ctrl_attr_3         	  NUMBER,
x_eval_ctrl_attr_4         	  NUMBER,
x_eval_ctrl_attr_5         	  NUMBER,
x_eval_ctrl_attr_6         	  NUMBER,
x_eval_ctrl_attr_7         	  NUMBER,
x_eval_ctrl_attr_8         	  NUMBER,
x_eval_ctrl_attr_9         	  NUMBER,
x_eval_ctrl_attr_10        	  NUMBER,
x_eval_ctrl_attr_11         	  NUMBER,
x_eval_ctrl_attr_12         	  NUMBER,
x_eval_ctrl_attr_13         	  NUMBER,
x_eval_ctrl_attr_14         	  NUMBER,
x_eval_ctrl_attr_15         	  NUMBER,
x_eval_ctrl_attr_16         	  NUMBER,
x_eval_ctrl_attr_17         	  NUMBER,
x_eval_ctrl_attr_18         	  NUMBER,
x_eval_ctrl_attr_19         	  NUMBER,
x_eval_ctrl_attr_20        	  NUMBER,
x_eval_ctrl_attr_21         	  NUMBER,
x_eval_ctrl_attr_22         	  NUMBER,
x_eval_ctrl_attr_23         	  NUMBER,
x_eval_ctrl_attr_24         	  NUMBER,
x_eval_ctrl_attr_25         	  NUMBER,
x_eval_ctrl_attr_26         	  NUMBER,
x_eval_ctrl_attr_27         	  NUMBER,
x_eval_ctrl_attr_28         	  NUMBER,
x_eval_ctrl_attr_29         	  NUMBER,
x_eval_ctrl_attr_30        	  NUMBER,
x_display_flag              	  VARCHAR2
) is

begin
declare
 var_fin_certification_id  number;

m_object_version_number NUMBER := 1;



 begin

/*  select
      fin_certification_id       into var_fin_certification_id
from
 amw_fin_cert_ctrl_sum
where
 fin_certification_id     = x_fin_certification_id      and
 financial_statement_id   = x_financial_statement_id    and
 NVL(financial_item_id, -1)        = NVL(x_financial_item_id, -1) and
 NVL(account_group_id, -1) =  NVL(x_account_group_id, -1) and
 nvl(natural_account_id, -1) = nvl(x_natural_account_id, -1)   and
 CTRL_ATTRIBUTE_TYPE =  x_ctrl_attribute_type       and
 object_type	= x_object_type       ;
 EXCEPTION
WHEN NO_DATA_FOUND THEN
*/
 --dbms_output.put_line('inserting data');

 insert into amw_fin_cert_ctrl_sum (
 fin_certification_id      ,
 financial_statement_id    ,
 financial_item_id         ,
 account_group_id          ,
 natural_account_id        ,
 object_type               ,
 ctrl_attribute_type       ,
 ctrl_attr_code_1          ,
 ineff_ctrl_attr_1         ,
 total_ctrl_attr_1         ,
 ctrl_attr_code_2          ,
 ineff_ctrl_attr_2         ,
 total_ctrl_attr_2         ,
 ctrl_attr_code_3          ,
 ineff_ctrl_attr_3         ,
 total_ctrl_attr_3         ,
 ctrl_attr_code_4          ,
 ineff_ctrl_attr_4         ,
 total_ctrl_attr_4         ,
 ctrl_attr_code_5          ,
 ineff_ctrl_attr_5         ,
 total_ctrl_attr_5         ,
 ctrl_attr_code_6          ,
 ineff_ctrl_attr_6         ,
 total_ctrl_attr_6         ,
 ctrl_attr_code_7          ,
 ineff_ctrl_attr_7         ,
 total_ctrl_attr_7         ,
 ctrl_attr_code_8          ,
 ineff_ctrl_attr_8         ,
 total_ctrl_attr_8         ,
  ctrl_attr_code_9         ,
 ineff_ctrl_attr_9         ,
 total_ctrl_attr_9         ,
 ctrl_attr_code_10         ,
 ineff_ctrl_attr_10        ,
 total_ctrl_attr_10        ,
 ctrl_attr_code_11         ,
 ineff_ctrl_attr_11        ,
 total_ctrl_attr_11        ,
 ctrl_attr_code_12         ,
 ineff_ctrl_attr_12        ,
 total_ctrl_attr_12        ,
 ctrl_attr_code_13         ,
 ineff_ctrl_attr_13        ,
 total_ctrl_attr_13        ,
 ctrl_attr_code_14         ,
 ineff_ctrl_attr_14        ,
 total_ctrl_attr_14        ,
 ctrl_attr_code_15         ,
 ineff_ctrl_attr_15        ,
 total_ctrl_attr_15        ,
 ctrl_attr_code_16         ,
 ineff_ctrl_attr_16        ,
 total_ctrl_attr_16        ,
 ctrl_attr_code_17         ,
 ineff_ctrl_attr_17        ,
 total_ctrl_attr_17        ,
 ctrl_attr_code_18         ,
 ineff_ctrl_attr_18        ,
 total_ctrl_attr_18        ,
 ctrl_attr_code_19         ,
 ineff_ctrl_attr_19        ,
 total_ctrl_attr_19        ,
 ctrl_attr_code_20         ,
 ineff_ctrl_attr_20        ,
 total_ctrl_attr_20        ,
 ctrl_attr_code_21         ,
 ineff_ctrl_attr_21        ,
 total_ctrl_attr_21        ,
 ctrl_attr_code_22         ,
 ineff_ctrl_attr_22        ,
 total_ctrl_attr_22        ,
 ctrl_attr_code_23         ,
 ineff_ctrl_attr_23        ,
 total_ctrl_attr_23        ,
 ctrl_attr_code_24         ,
ineff_ctrl_attr_24         ,
 total_ctrl_attr_24        ,
 ctrl_attr_code_25         ,
 ineff_ctrl_attr_25        ,
 total_ctrl_attr_25        ,
 ctrl_attr_code_26         ,
 ineff_ctrl_attr_26        ,
 total_ctrl_attr_26        ,
 ctrl_attr_code_27         ,
 ineff_ctrl_attr_27        ,
 total_ctrl_attr_27        ,
 ctrl_attr_code_28         ,
 ineff_ctrl_attr_28        ,
 total_ctrl_attr_28        ,
 ctrl_attr_code_29         ,
 ineff_ctrl_attr_29        ,
 total_ctrl_attr_29        ,
 ctrl_attr_code_30         ,
 ineff_ctrl_attr_30        ,
 total_ctrl_attr_30        ,
 created_by                ,
 creation_date             ,
 last_updated_by           ,
 last_update_date          ,
 last_update_login         ,
 -- Removed security_group_id         ,
 object_version_number,
 acc_assert_flag_1 ,
 acc_assert_flag_2 ,
 acc_assert_flag_3 ,
 acc_assert_flag_4 ,
 acc_assert_flag_5 ,
 acc_assert_flag_6 ,
 acc_assert_flag_7 ,
 acc_assert_flag_8 ,
 acc_assert_flag_9 ,
 acc_assert_flag_10,
 acc_assert_flag_11 ,
 acc_assert_flag_12 ,
 acc_assert_flag_13 ,
 acc_assert_flag_14 ,
 acc_assert_flag_15 ,
 acc_assert_flag_16 ,
 acc_assert_flag_17 ,
 acc_assert_flag_18 ,
 acc_assert_flag_19 ,
 acc_assert_flag_20,
 acc_assert_flag_21 ,
 acc_assert_flag_22 ,
 acc_assert_flag_23 ,
 acc_assert_flag_24 ,
 acc_assert_flag_25 ,
 acc_assert_flag_26 ,
 acc_assert_flag_27 ,
 acc_assert_flag_28 ,
 acc_assert_flag_29 ,
 acc_assert_flag_30 ,
 eval_ctrl_attr_1    ,
 eval_ctrl_attr_2    ,
 eval_ctrl_attr_3    ,
 eval_ctrl_attr_4    ,
 eval_ctrl_attr_5    ,
 eval_ctrl_attr_6    ,
 eval_ctrl_attr_7    ,
 eval_ctrl_attr_8    ,
 eval_ctrl_attr_9    ,
 eval_ctrl_attr_10   ,
 eval_ctrl_attr_11    ,
 eval_ctrl_attr_12    ,
 eval_ctrl_attr_13    ,
 eval_ctrl_attr_14    ,
 eval_ctrl_attr_15    ,
 eval_ctrl_attr_16    ,
 eval_ctrl_attr_17    ,
 eval_ctrl_attr_18    ,
 eval_ctrl_attr_19    ,
 eval_ctrl_attr_20   ,
 eval_ctrl_attr_21    ,
 eval_ctrl_attr_22    ,
 eval_ctrl_attr_23    ,
 eval_ctrl_attr_24    ,
 eval_ctrl_attr_25    ,
 eval_ctrl_attr_26    ,
 eval_ctrl_attr_27    ,
 eval_ctrl_attr_28    ,
 eval_ctrl_attr_29    ,
 eval_ctrl_attr_30    ,
 CONTROLS_EXIST_FLAG,
 ineff_ctrl_prcnt_1        ,
 ineff_ctrl_prcnt_2        ,
 ineff_ctrl_prcnt_3        ,
 ineff_ctrl_prcnt_4        ,
 ineff_ctrl_prcnt_5        ,
 ineff_ctrl_prcnt_6        ,
 ineff_ctrl_prcnt_7        ,
 ineff_ctrl_prcnt_8        ,
 ineff_ctrl_prcnt_9        ,
 ineff_ctrl_prcnt_10        ,
 ineff_ctrl_prcnt_11        ,
 ineff_ctrl_prcnt_12        ,
 ineff_ctrl_prcnt_13        ,
 ineff_ctrl_prcnt_14        ,
 ineff_ctrl_prcnt_15        ,
 ineff_ctrl_prcnt_16        ,
 ineff_ctrl_prcnt_17        ,
 ineff_ctrl_prcnt_18        ,
 ineff_ctrl_prcnt_19        ,
 ineff_ctrl_prcnt_20        ,
 ineff_ctrl_prcnt_21        ,
 ineff_ctrl_prcnt_22        ,
 ineff_ctrl_prcnt_23        ,
 ineff_ctrl_prcnt_24        ,
 ineff_ctrl_prcnt_25        ,
 ineff_ctrl_prcnt_26        ,
 ineff_ctrl_prcnt_27        ,
 ineff_ctrl_prcnt_28        ,
 ineff_ctrl_prcnt_29        ,
 ineff_ctrl_prcnt_30
)
values (
 x_fin_certification_id       ,
 x_financial_statement_id    ,
 x_financial_item_id         ,
 x_account_group_id          ,
 x_natural_account_id        ,
 x_object_type               ,
 x_ctrl_attribute_type       ,
 x_ctrl_attr_code_1          ,
 x_ineff_ctrl_attr_1         ,
 x_total_ctrl_attr_1         ,
 x_ctrl_attr_code_2          ,
 x_ineff_ctrl_attr_2         ,
 x_total_ctrl_attr_2         ,
 x_ctrl_attr_code_3          ,
 x_ineff_ctrl_attr_3         ,
 x_total_ctrl_attr_3         ,
 x_ctrl_attr_code_4          ,
 x_ineff_ctrl_attr_4         ,
 x_total_ctrl_attr_4         ,
 x_ctrl_attr_code_5          ,
 x_ineff_ctrl_attr_5         ,
 x_total_ctrl_attr_5         ,
 x_ctrl_attr_code_6          ,
 x_ineff_ctrl_attr_6         ,
 x_total_ctrl_attr_6         ,
 x_ctrl_attr_code_7          ,
 x_ineff_ctrl_attr_7         ,
 x_total_ctrl_attr_7         ,
 x_ctrl_attr_code_8          ,
 x_ineff_ctrl_attr_8         ,
 x_total_ctrl_attr_8         ,
 x_ctrl_attr_code_9         ,
 x_ineff_ctrl_attr_9         ,
 x_total_ctrl_attr_9         ,
 x_ctrl_attr_code_10         ,
 x_ineff_ctrl_attr_10        ,
 x_total_ctrl_attr_10        ,
 x_ctrl_attr_code_11         ,
 x_ineff_ctrl_attr_11        ,
 x_total_ctrl_attr_11        ,
 x_ctrl_attr_code_12         ,
 x_ineff_ctrl_attr_12        ,
 x_total_ctrl_attr_12        ,
 x_ctrl_attr_code_13         ,
 x_ineff_ctrl_attr_13        ,
 x_total_ctrl_attr_13        ,
 x_ctrl_attr_code_14         ,
 x_ineff_ctrl_attr_14        ,
 x_total_ctrl_attr_14        ,
 x_ctrl_attr_code_15         ,
 x_ineff_ctrl_attr_15        ,
 x_total_ctrl_attr_15        ,
 x_ctrl_attr_code_16         ,
 x_ineff_ctrl_attr_16        ,
 x_total_ctrl_attr_16        ,
 x_ctrl_attr_code_17         ,
 x_ineff_ctrl_attr_17        ,
 x_total_ctrl_attr_17        ,
 x_ctrl_attr_code_18         ,
 x_ineff_ctrl_attr_18        ,
 x_total_ctrl_attr_18        ,
 x_ctrl_attr_code_19         ,
 x_ineff_ctrl_attr_19        ,
 x_total_ctrl_attr_19        ,
 x_ctrl_attr_code_20         ,
 x_ineff_ctrl_attr_20        ,
 x_total_ctrl_attr_20        ,
 x_ctrl_attr_code_21         ,
 x_ineff_ctrl_attr_21        ,
 x_total_ctrl_attr_21        ,
 x_ctrl_attr_code_22         ,
 x_ineff_ctrl_attr_22        ,
 x_total_ctrl_attr_22        ,
 x_ctrl_attr_code_23         ,
 x_ineff_ctrl_attr_23        ,
 x_total_ctrl_attr_23        ,
 x_ctrl_attr_code_24         ,
 x_ineff_ctrl_attr_24         ,
 x_total_ctrl_attr_24        ,
 x_ctrl_attr_code_25         ,
 x_ineff_ctrl_attr_25        ,
 x_total_ctrl_attr_25        ,
 x_ctrl_attr_code_26         ,
 x_ineff_ctrl_attr_26        ,
 x_total_ctrl_attr_26        ,
 x_ctrl_attr_code_27         ,
 x_ineff_ctrl_attr_27        ,
 x_total_ctrl_attr_27        ,
 x_ctrl_attr_code_28         ,
 x_ineff_ctrl_attr_28        ,
 x_total_ctrl_attr_28        ,
 x_ctrl_attr_code_29         ,
 x_ineff_ctrl_attr_29        ,
 x_total_ctrl_attr_29        ,
 x_ctrl_attr_code_30         ,
 x_ineff_ctrl_attr_30        ,
 x_total_ctrl_attr_30        ,
 x_created_by                ,
 x_creation_date             ,
 x_last_updated_by           ,
 x_last_update_date          ,
 x_last_update_login         ,
-- Removed  x_security_group_id         ,
-- x_object_version_number,
m_object_version_number ,
x_acc_assert_flag1 ,
x_acc_assert_flag2 ,
x_acc_assert_flag3 ,
x_acc_assert_flag4 ,
x_acc_assert_flag5 ,
x_acc_assert_flag6 ,
x_acc_assert_flag7 ,
x_acc_assert_flag8 ,
x_acc_assert_flag9 ,
x_acc_assert_flag10,
x_acc_assert_flag11 ,
x_acc_assert_flag12 ,
x_acc_assert_flag13 ,
x_acc_assert_flag14 ,
x_acc_assert_flag15 ,
x_acc_assert_flag16 ,
x_acc_assert_flag17 ,
x_acc_assert_flag18 ,
x_acc_assert_flag19 ,
x_acc_assert_flag20,
x_acc_assert_flag21 ,
x_acc_assert_flag22 ,
x_acc_assert_flag23 ,
x_acc_assert_flag24 ,
x_acc_assert_flag25 ,
x_acc_assert_flag26 ,
x_acc_assert_flag27 ,
x_acc_assert_flag28 ,
x_acc_assert_flag29 ,
x_acc_assert_flag30,
x_eval_ctrl_attr_1    ,
x_eval_ctrl_attr_2    ,
x_eval_ctrl_attr_3    ,
x_eval_ctrl_attr_4    ,
x_eval_ctrl_attr_5    ,
x_eval_ctrl_attr_6    ,
x_eval_ctrl_attr_7    ,
x_eval_ctrl_attr_8    ,
x_eval_ctrl_attr_9    ,
x_eval_ctrl_attr_10   ,
x_eval_ctrl_attr_11    ,
x_eval_ctrl_attr_12    ,
x_eval_ctrl_attr_13    ,
x_eval_ctrl_attr_14    ,
x_eval_ctrl_attr_15    ,
x_eval_ctrl_attr_16    ,
x_eval_ctrl_attr_17    ,
x_eval_ctrl_attr_18    ,
x_eval_ctrl_attr_19    ,
x_eval_ctrl_attr_20   ,
x_eval_ctrl_attr_21    ,
x_eval_ctrl_attr_22    ,
x_eval_ctrl_attr_23    ,
x_eval_ctrl_attr_24    ,
x_eval_ctrl_attr_25    ,
x_eval_ctrl_attr_26    ,
x_eval_ctrl_attr_27    ,
x_eval_ctrl_attr_28    ,
x_eval_ctrl_attr_29    ,
x_eval_ctrl_attr_30   ,
x_display_flag ,
   round((x_ineff_ctrl_attr_1	 /  decode(x_total_ctrl_attr_1,null,1,0,1,x_total_ctrl_attr_1) ) * 100,0),
   round((x_ineff_ctrl_attr_2	 /  decode(x_total_ctrl_attr_2,null,1,0,1,x_total_ctrl_attr_2) ) * 100,0),
   round((x_ineff_ctrl_attr_3	 /  decode(x_total_ctrl_attr_3,null,1,0,1,x_total_ctrl_attr_3) ) * 100,0),
   round((x_ineff_ctrl_attr_4	 /  decode(x_total_ctrl_attr_4,null,1,0,1,x_total_ctrl_attr_4) ) * 100,0),
   round((x_ineff_ctrl_attr_5	 /  decode(x_total_ctrl_attr_5,null,1,0,1,x_total_ctrl_attr_5) ) * 100,0),
   round((x_ineff_ctrl_attr_6	 /  decode(x_total_ctrl_attr_6,null,1,0,1,x_total_ctrl_attr_6) ) * 100,0),
   round((x_ineff_ctrl_attr_7	 /  decode(x_total_ctrl_attr_7,null,1,0,1,x_total_ctrl_attr_7) ) * 100,0),
   round((x_ineff_ctrl_attr_8	 /  decode(x_total_ctrl_attr_8,null,1,0,1,x_total_ctrl_attr_8) ) * 100,0),
   round((x_ineff_ctrl_attr_9	 /  decode(x_total_ctrl_attr_9,null,1,0,1,x_total_ctrl_attr_9) ) * 100,0),
   round((x_ineff_ctrl_attr_10 /  decode(x_total_ctrl_attr_10,null,1,0,1,x_total_ctrl_attr_10) ) * 100,0),
   round((x_ineff_ctrl_attr_11 /  decode(x_total_ctrl_attr_11,null,1,0,1,x_total_ctrl_attr_11) ) * 100,0),
   round((x_ineff_ctrl_attr_12 /  decode(x_total_ctrl_attr_12,null,1,0,1,x_total_ctrl_attr_12) ) * 100,0),
   round((x_ineff_ctrl_attr_13 /  decode(x_total_ctrl_attr_13,null,1,0,1,x_total_ctrl_attr_13) ) * 100,0),
   round((x_ineff_ctrl_attr_14 /  decode(x_total_ctrl_attr_14,null,1,0,1,x_total_ctrl_attr_14) ) * 100,0),
   round((x_ineff_ctrl_attr_15 /  decode(x_total_ctrl_attr_15,null,1,0,1,x_total_ctrl_attr_15) ) * 100,0),
   round((x_ineff_ctrl_attr_16 /  decode(x_total_ctrl_attr_16,null,1,0,1,x_total_ctrl_attr_16) ) * 100,0),
   round((x_ineff_ctrl_attr_17 /  decode(x_total_ctrl_attr_17,null,1,0,1,x_total_ctrl_attr_17) ) * 100,0),
   round((x_ineff_ctrl_attr_18 /  decode(x_total_ctrl_attr_18,null,1,0,1,x_total_ctrl_attr_18) ) * 100,0),
   round((x_ineff_ctrl_attr_19 /  decode(x_total_ctrl_attr_19,null,1,0,1,x_total_ctrl_attr_19) ) * 100,0),
   round((x_ineff_ctrl_attr_20 /  decode(x_total_ctrl_attr_20,null,1,0,1,x_total_ctrl_attr_20) ) * 100,0),
   round((x_ineff_ctrl_attr_21 /  decode(x_total_ctrl_attr_21,null,1,0,1,x_total_ctrl_attr_21) ) * 100,0),
   round((x_ineff_ctrl_attr_22 /  decode(x_total_ctrl_attr_22,null,1,0,1,x_total_ctrl_attr_22) ) * 100,0),
   round((x_ineff_ctrl_attr_23 /  decode(x_total_ctrl_attr_23,null,1,0,1,x_total_ctrl_attr_23) ) * 100,0),
   round((x_ineff_ctrl_attr_24 /  decode(x_total_ctrl_attr_24,null,1,0,1,x_total_ctrl_attr_24) ) * 100,0),
   round((x_ineff_ctrl_attr_25 /  decode(x_total_ctrl_attr_25,null,1,0,1,x_total_ctrl_attr_25) ) * 100,0),
   round((x_ineff_ctrl_attr_26 /  decode(x_total_ctrl_attr_26,null,1,0,1,x_total_ctrl_attr_26) ) * 100,0),
   round((x_ineff_ctrl_attr_27 /  decode(x_total_ctrl_attr_27,null,1,0,1,x_total_ctrl_attr_27) ) * 100,0),
   round((x_ineff_ctrl_attr_28 /  decode(x_total_ctrl_attr_28,null,1,0,1,x_total_ctrl_attr_28) ) * 100,0),
   round((x_ineff_ctrl_attr_29 /  decode(x_total_ctrl_attr_29,null,1,0,1,x_total_ctrl_attr_29) ) * 100,0),
   round((x_ineff_ctrl_attr_30 /  decode(x_total_ctrl_attr_30,null,1,0,1,x_total_ctrl_attr_30) ) * 100,0)
);

EXCEPTION
WHEN DUP_VAL_ON_INDEX THEN
 fnd_file.put_line(fnd_file.LOG, 'Duplicate row insert');
 fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
-- dbms_output.put_line(SQLERRM);
 fnd_file.put_line(fnd_file.LOG, 'natural_account_id' || x_natural_account_id );
 fnd_file.put_line(fnd_file.LOG,  'financial_item_id' || x_financial_item_id);
 fnd_file.put_line(fnd_file.LOG,  'fin_certification_id  ' || x_fin_certification_id  );

WHEN OTHERS THEN
 fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
-- dbms_output.put_line(SQLERRM);
 fnd_file.put_line(fnd_file.LOG, 'natural_account_id' || x_natural_account_id );
 fnd_file.put_line(fnd_file.LOG,  'financial_item_id' || x_financial_item_id);
 fnd_file.put_line(fnd_file.LOG,  'fin_certification_id  ' || x_fin_certification_id  );

 --g_errbuf := SUBSTR (SQLERRM, 1, 2000)  ;
 --g_retcode := '2';

RAISE ;
 RETURN;
end;

end INSERT_ROW;
--******************************************************************************************************
/* ************************* Code to be executed for updating COSO COMPONENT LEVEL DATA
-- when business evevnt is rised on opinion changes **** */
--******************************************************************************************************
 PROCEDURE Update_item_ctrl_components
(P_CERTIFICATION_ID number ,
                  P_FINANCIAL_STATEMENT_ID number,
                  P_STATEMENT_GROUP_ID number,
                  P_FINANCIAL_ITEM_ID number,
                  P_CONTROL_ID        number ,
                  P_ORG_ID        number ,
                  P_CHANGE_FLAG VARCHAR2,
                  P_NEW_FLAG VARCHAR2) is

begin

 declare

cursor existing_code(par_type varchar2)
is
 select
   ctrl_attr_code_1,
   ctrl_attr_code_2,
   ctrl_attr_code_3,
   ctrl_attr_code_4,
   ctrl_attr_code_5,
   ctrl_attr_code_6,
   ctrl_attr_code_7,
   ctrl_attr_code_8,
   ctrl_attr_code_9,
   ctrl_attr_code_10,
   ctrl_attr_code_11,
   ctrl_attr_code_12,
   ctrl_attr_code_13,
   ctrl_attr_code_14,
   ctrl_attr_code_15,
   ctrl_attr_code_16,
   ctrl_attr_code_17,
   ctrl_attr_code_18,
   ctrl_attr_code_19,
   ctrl_attr_code_20,
   ctrl_attr_code_21,
   ctrl_attr_code_22,
   ctrl_attr_code_23,
   ctrl_attr_code_24,
   ctrl_attr_code_25,
   ctrl_attr_code_26,
   ctrl_attr_code_27,
   ctrl_attr_code_28,
   ctrl_attr_code_29,
   ctrl_attr_code_30
from
 amw_fin_cert_ctrl_sum
where
 fin_certification_id = P_CERTIFICATION_ID and
 ctrl_attribute_type = par_type and
 ROWNUM <2;

cursor comp_of_the_ctrl
is
select
 distinct
 comp.COMPONENT_CODE
from
  amw.amw_fin_item_acc_ctrl ctrl,
  amw_assessment_components comp
where
 ctrl.FIN_CERTIFICATION_ID= P_CERTIFICATION_ID and
 ctrl.OBJECT_TYPE = 'FINANCIAL ITEM' and
 ctrl.FINANCIAL_ITEM_ID= P_FINANCIAL_ITEM_ID  and
 ctrl.CONTROL_REV_ID =comp.OBJECT_ID and
 comp.OBJECT_TYPE ='CONTROL' and
 ctrl.ORGANIZATION_ID = P_ORG_ID and
 ctrl.CONTROL_ID =  P_CONTROL_ID ;



 g_user_id              NUMBER        := fnd_global.user_id;
 g_login_id             NUMBER        := fnd_global.conc_login_id;
 m_object_version_number NUMBER;
 ctr integer :=0;
 max_num_of_codes integer :=0;
 m_ctrl_attribute_type VARCHAR2(30) :='CTRL_COMPONENT';
 m_OBJECT_TYPE VARCHAR2(50) := 'FINANCIAL ITEM';


 m_component_code component_code_array;
 m_ineff_control  ineff_control_array ;
-- m_acc_assert_flag component_code_array;
 m_add_to_eval_ctrls  total_control_array ;

 add_or_deduct_value number :=0;

 begin

 -- ************ Since the Table has 30 Fileds only initialize 30 Positios in the Array**************--
  /******** comment out by dong because index-by table doesn't need intialization. *************
 ctr :=  1;

 loop
   EXIT  WHEN ctr > 30;

    m_component_code(ctr) := null;
  --  m_acc_assert_flag(ctr) := 'N';
    m_ineff_control(ctr) := 0;
    m_add_to_eval_ctrls(ctr) := 0;

    ctr := ctr + 1;

 end loop; --end of initialization
 ***********************************************************************************/

 -- ************ get All Control Components Codes and Load it in an Array for later use **************--
 m_ctrl_attribute_type := 'CTRL_COMPONENT';

 --- P_CHANGE_FLAG = 'F' means the Opinion is changed from Ineffective to Efective
 --- P_CHANGE_FLAG = 'B' means the Opinion is changed from Efective to Ineffective

 if P_CHANGE_FLAG = 'B' then
    add_or_deduct_value := 1;

  -- note on next elseif: -- do this deduction only if the effectivity is changed from ineffective othereise if it is a new opinion for the
  --- control no need to take action

 elsif (P_CHANGE_FLAG = 'F' and P_NEW_FLAG <> 'Y') then
    add_or_deduct_value := -1;
 elsif P_CHANGE_FLAG = 'N' then
  return;
 end if;

 ctr := 0;
 for coso_rec in existing_code(m_ctrl_attribute_type)
 loop
    exit when existing_code%notfound;

   m_component_code(1) :=  coso_rec.ctrl_attr_code_1;
   m_component_code(2) :=  coso_rec.ctrl_attr_code_2;
   m_component_code(3) :=  coso_rec.ctrl_attr_code_3;
   m_component_code(4) :=   coso_rec.ctrl_attr_code_4;
   m_component_code(5) :=coso_rec.ctrl_attr_code_5;
   m_component_code(6) :=coso_rec.ctrl_attr_code_6;
   m_component_code(7) :=coso_rec.ctrl_attr_code_7;
   m_component_code(8) :=coso_rec.ctrl_attr_code_8;
   m_component_code(9) :=coso_rec.ctrl_attr_code_9;
   m_component_code(10) :=coso_rec.ctrl_attr_code_10;
   m_component_code(11) :=coso_rec.ctrl_attr_code_11;
   m_component_code(12) :=coso_rec.ctrl_attr_code_12;
   m_component_code(13) :=coso_rec.ctrl_attr_code_13;
   m_component_code(14) :=coso_rec.ctrl_attr_code_14;
   m_component_code(15) :=coso_rec.ctrl_attr_code_15;
   m_component_code(16) :=coso_rec.ctrl_attr_code_16;
   m_component_code(17) :=coso_rec.ctrl_attr_code_17;
   m_component_code(18) :=coso_rec.ctrl_attr_code_18;
   m_component_code(19) :=coso_rec.ctrl_attr_code_19;
   m_component_code(20) :=coso_rec.ctrl_attr_code_20;
   m_component_code(21) :=coso_rec.ctrl_attr_code_21;
   m_component_code(22) :=coso_rec.ctrl_attr_code_22;
   m_component_code(23) :=coso_rec.ctrl_attr_code_23;
   m_component_code(24) :=coso_rec.ctrl_attr_code_24;
   m_component_code(25) :=coso_rec.ctrl_attr_code_25;
   m_component_code(26) :=coso_rec.ctrl_attr_code_26;
   m_component_code(27) :=coso_rec.ctrl_attr_code_27;
   m_component_code(28) :=coso_rec.ctrl_attr_code_28;
   m_component_code(29) :=coso_rec.ctrl_attr_code_29;
   m_component_code(30) :=coso_rec.ctrl_attr_code_30;

 end loop; --end of COSO_COMPONENTS loop


-- **************** Check the REVISION of the Control came with the event has what COSO Codes *******************
-- and in which filed (out of 1 to 30) it is falling and the init varaible with the -1 or +1 corrsponding to that
--****************************************************************************************************************
 ctr := 0;
 for ctrl_coso_codes in comp_of_the_ctrl
 loop
    exit when comp_of_the_ctrl%notfound;
    ctr := 1;
    while ctr <=  30
    loop
      if m_component_code(ctr) = ctrl_coso_codes.COMPONENT_CODE then
         m_ineff_control(ctr) :=  add_or_deduct_value;

         if  P_NEW_FLAG = 'Y' then
             m_add_to_eval_ctrls(ctr) := 1;
         end if;

      end if;
       ctr := ctr + 1;

    end loop;


 end loop; --end of ctrl_coso_codes in comp_of_the_ctrl loop




    amw_fin_coso_views_pvt.UPDATE_FIN_ITEM_ROW(
     x_fin_certification_id       	=> 	P_CERTIFICATION_ID	,
     x_financial_statement_id    	=> 	P_FINANCIAL_STATEMENT_ID 	,
     x_financial_item_id         	=> 	P_FINANCIAL_ITEM_ID 	,
     x_account_group_id          	=> 	null	,
     x_natural_account_id        	=> 	null,
     x_object_type               	=> 	m_OBJECT_TYPE 	,
     x_ctrl_attribute_type       	=> 	m_ctrl_attribute_type       	,
     x_ineff_ctrl_attr_1         	=> 	m_ineff_control(1)	,
     x_ineff_ctrl_attr_2         	=> 	m_ineff_control(2)	,
     x_ineff_ctrl_attr_3         	=> 	m_ineff_control(3)	,
     x_ineff_ctrl_attr_4         	=> 	m_ineff_control(4)	,
     x_ineff_ctrl_attr_5         	=> 	m_ineff_control(5)	,
     x_ineff_ctrl_attr_6         	=> 	m_ineff_control(6)	,
     x_ineff_ctrl_attr_7         	=> 	m_ineff_control(7)	,
     x_ineff_ctrl_attr_8         	=> 	m_ineff_control(8)	,
     x_ineff_ctrl_attr_9         	=> 	m_ineff_control(9)	,
     x_ineff_ctrl_attr_10        	=> 	m_ineff_control(10)	,
     x_ineff_ctrl_attr_11        	=> 	m_ineff_control(11)	,
     x_ineff_ctrl_attr_12        	=> 	m_ineff_control(12)	,
     x_ineff_ctrl_attr_13        	=> 	m_ineff_control(13)	,
     x_ineff_ctrl_attr_14        	=> 	m_ineff_control(14)	,
     x_ineff_ctrl_attr_15        	=> 	m_ineff_control(15)	,
     x_ineff_ctrl_attr_16        	=> 	m_ineff_control(16)	,
     x_ineff_ctrl_attr_17        	=> 	m_ineff_control(17)	,
     x_ineff_ctrl_attr_18        	=> 	m_ineff_control(18)	,
     x_ineff_ctrl_attr_19        	=> 	m_ineff_control(19)	,
     x_ineff_ctrl_attr_20        	=> 	m_ineff_control(20)	,
     x_ineff_ctrl_attr_21        	=> 	m_ineff_control(21)	,
     x_ineff_ctrl_attr_22        	=> 	m_ineff_control(22)	,
     x_ineff_ctrl_attr_23        	=> 	m_ineff_control(23)	,
     x_ineff_ctrl_attr_24         	=> 	m_ineff_control(24)	,
     x_ineff_ctrl_attr_25        	=> 	m_ineff_control(25)	,
     x_ineff_ctrl_attr_26        	=> 	m_ineff_control(26)	,
     x_ineff_ctrl_attr_27        	=> 	m_ineff_control(27)	,
     x_ineff_ctrl_attr_28        	=> 	m_ineff_control(28)	,
     x_ineff_ctrl_attr_29        	=> 	m_ineff_control(29)	,
     x_ineff_ctrl_attr_30        	=> 	m_ineff_control(30)	,
     x_last_updated_by           	=> 	g_user_id	,
     x_last_update_date          	=> 	SYSDATE	,
     x_last_update_login         	=> 	g_login_id,
     x_eval_ctrl_attr_1         	=> 	m_add_to_eval_ctrls(1),
     x_eval_ctrl_attr_2         	=> 	m_add_to_eval_ctrls(2),
     x_eval_ctrl_attr_3         	=> 	m_add_to_eval_ctrls(3),
     x_eval_ctrl_attr_4         	=> 	m_add_to_eval_ctrls(4),
     x_eval_ctrl_attr_5         	=> 	m_add_to_eval_ctrls(5),
     x_eval_ctrl_attr_6         	=> 	m_add_to_eval_ctrls(6),
     x_eval_ctrl_attr_7         	=> 	m_add_to_eval_ctrls(7),
     x_eval_ctrl_attr_8         	=> 	m_add_to_eval_ctrls(8),
     x_eval_ctrl_attr_9         	=> 	m_add_to_eval_ctrls(9),
     x_eval_ctrl_attr_10        	=> 	m_add_to_eval_ctrls(10),
     x_eval_ctrl_attr_11         	=> 	m_add_to_eval_ctrls(11),
     x_eval_ctrl_attr_12         	=> 	m_add_to_eval_ctrls(12),
     x_eval_ctrl_attr_13         	=> 	m_add_to_eval_ctrls(13),
     x_eval_ctrl_attr_14         	=> 	m_add_to_eval_ctrls(14),
     x_eval_ctrl_attr_15         	=> 	m_add_to_eval_ctrls(15),
     x_eval_ctrl_attr_16         	=> 	m_add_to_eval_ctrls(16),
     x_eval_ctrl_attr_17         	=> 	m_add_to_eval_ctrls(17),
     x_eval_ctrl_attr_18         	=> 	m_add_to_eval_ctrls(18),
     x_eval_ctrl_attr_19         	=> 	m_add_to_eval_ctrls(19),
     x_eval_ctrl_attr_20        	=> 	m_add_to_eval_ctrls(20),
     x_eval_ctrl_attr_21         	=> 	m_add_to_eval_ctrls(21),
     x_eval_ctrl_attr_22         	=> 	m_add_to_eval_ctrls(22),
     x_eval_ctrl_attr_23         	=> 	m_add_to_eval_ctrls(23),
     x_eval_ctrl_attr_24         	=> 	m_add_to_eval_ctrls(24),
     x_eval_ctrl_attr_25         	=> 	m_add_to_eval_ctrls(25),
     x_eval_ctrl_attr_26         	=> 	m_add_to_eval_ctrls(26),
     x_eval_ctrl_attr_27         	=> 	m_add_to_eval_ctrls(27),
     x_eval_ctrl_attr_28         	=> 	m_add_to_eval_ctrls(28),
     x_eval_ctrl_attr_29         	=> 	m_add_to_eval_ctrls(29),
     x_eval_ctrl_attr_30        	=> 	m_add_to_eval_ctrls(30));

  EXCEPTION
     WHEN NO_DATA_FOUND
	     THEN
            fnd_file.put_line (fnd_file.LOG, SUBSTR ('No data found in Update_item_ctrl_components'
                || SUBSTR (SQLERRM, 1, 100), 1, 200));

     WHEN OTHERS
         THEN
            fnd_file.put_line (fnd_file.LOG, SUBSTR ('Unexpected Error in Update_item_ctrl_components'
                || SUBSTR (SQLERRM, 1, 100), 1, 200));


  end;
end ; --Update_item_ctrl_components

------------------------------ fOR THE ACCOUNTS ------------------------------------------------------------------------------

PROCEDURE Update_acc_ctrl_components
(P_CERTIFICATION_ID number ,
                  P_ACCOUNT_GROUP_ID  number ,
                  P_ACCOUNT_ID        number ,
                  P_CONTROL_ID        number ,
                  P_ORG_ID        number ,
                  P_CHANGE_FLAG VARCHAR2,
                  P_NEW_FLAG VARCHAR2) is



begin
declare
cursor existing_code(par_type varchar2)
is
 select
   ctrl_attr_code_1,
   ctrl_attr_code_2,
   ctrl_attr_code_3,
   ctrl_attr_code_4,
   ctrl_attr_code_5,
   ctrl_attr_code_6,
   ctrl_attr_code_7,
   ctrl_attr_code_8,
   ctrl_attr_code_9,
   ctrl_attr_code_10,
   ctrl_attr_code_11,
   ctrl_attr_code_12,
   ctrl_attr_code_13,
   ctrl_attr_code_14,
   ctrl_attr_code_15,
   ctrl_attr_code_16,
   ctrl_attr_code_17,
   ctrl_attr_code_18,
   ctrl_attr_code_19,
   ctrl_attr_code_20,
   ctrl_attr_code_21,
   ctrl_attr_code_22,
   ctrl_attr_code_23,
   ctrl_attr_code_24,
   ctrl_attr_code_25,
   ctrl_attr_code_26,
   ctrl_attr_code_27,
   ctrl_attr_code_28,
   ctrl_attr_code_29,
   ctrl_attr_code_30,
   ineff_ctrl_attr_1,
   ineff_ctrl_attr_2,
   ineff_ctrl_attr_3,
   ineff_ctrl_attr_4,
   ineff_ctrl_attr_5,
   ineff_ctrl_attr_6,
   ineff_ctrl_attr_7,
   ineff_ctrl_attr_8,
   ineff_ctrl_attr_9,
   ineff_ctrl_attr_10,
   ineff_ctrl_attr_11,
   ineff_ctrl_attr_12,
   ineff_ctrl_attr_13,
   ineff_ctrl_attr_14,
   ineff_ctrl_attr_15,
   ineff_ctrl_attr_16,
   ineff_ctrl_attr_17,
   ineff_ctrl_attr_18,
   ineff_ctrl_attr_19,
   ineff_ctrl_attr_20,
   ineff_ctrl_attr_21,
   ineff_ctrl_attr_22,
   ineff_ctrl_attr_23,
   ineff_ctrl_attr_24,
   ineff_ctrl_attr_25,
   ineff_ctrl_attr_26,
   ineff_ctrl_attr_27,
   ineff_ctrl_attr_28,
   ineff_ctrl_attr_29,
   ineff_ctrl_attr_30
from
 amw_fin_cert_ctrl_sum
where
 fin_certification_id = P_CERTIFICATION_ID and
 ctrl_attribute_type = par_type and
 ROWNUM <2
 AND  account_group_id =  P_ACCOUNT_GROUP_ID and
 natural_account_id  =  P_ACCOUNT_ID        and
 object_type	= 'ACCOUNT' ;


----------------------------------------------
cursor comp_of_the_ctrl
is select
 distinct
 comp.COMPONENT_CODE
from
  amw.amw_fin_item_acc_ctrl ctrl,
  amw_assessment_components comp
where
 ctrl.FIN_CERTIFICATION_ID= P_CERTIFICATION_ID
 and
 ctrl.OBJECT_TYPE = 'ACCOUNT' and
 ctrl.ACCOUNT_GROUP_ID= P_ACCOUNT_GROUP_ID AND
 ctrl.NATURAL_ACCOUNT_ID= P_ACCOUNT_ID and
 ctrl.CONTROL_REV_ID =comp.OBJECT_ID and
 comp.OBJECT_TYPE ='CONTROL' and
 ctrl.ORGANIZATION_ID = P_ORG_ID and
 ctrl.CONTROL_ID =  P_CONTROL_ID ;
----------------------------------------------------
 g_user_id              NUMBER        := fnd_global.user_id;
 g_login_id             NUMBER        := fnd_global.conc_login_id;
 m_object_version_number NUMBER;
 ctr integer :=0;
 max_num_of_codes integer :=0;
 m_ctrl_attribute_type VARCHAR2(30) :='CTRL_COMPONENT';
 m_OBJECT_TYPE VARCHAR2(50) := 'ACCOUNT';


 m_component_code component_code_array;
 m_ineff_control  ineff_control_array ;
 --m_acc_assert_flag component_code_array;
 m_add_to_eval_ctrls  total_control_array ;


 add_or_deduct_value number :=0;

begin

 -- ************ Since the Table has 30 Fileds only initialize 30 Positios in the Array**************--
 ctr :=  1;

 loop
   EXIT  WHEN ctr > 30;

    m_component_code(ctr) := null;
    --m_acc_assert_flag(ctr) := 'N';
    m_ineff_control(ctr) := 0;
    m_add_to_eval_ctrls(ctr) := 0;

    ctr := ctr + 1;

 end loop; --end of initialization

 -- ************ get All Control Components Codes and Load it in an Array for later use **************--
 m_ctrl_attribute_type := 'CTRL_COMPONENT';

 --- P_CHANGE_FLAG = 'F' means the Opinion is changed from Ineffective to Efective
 --- P_CHANGE_FLAG = 'B' means the Opinion is changed from Efective to Ineffective

  if P_CHANGE_FLAG = 'B' then
    add_or_deduct_value := 1;
elsif (P_CHANGE_FLAG = 'F' and P_NEW_FLAG <> 'Y') then
    add_or_deduct_value := -1;
 elsif P_CHANGE_FLAG = 'N' then
  return;
 end if;

 ctr := 0;
 for coso_rec in existing_code(m_ctrl_attribute_type)
 loop
    exit when existing_code%notfound;

   m_component_code(1) :=  coso_rec.ctrl_attr_code_1;
   m_component_code(2) :=  coso_rec.ctrl_attr_code_2;
   m_component_code(3) :=  coso_rec.ctrl_attr_code_3;
   m_component_code(4) :=   coso_rec.ctrl_attr_code_4;
   m_component_code(5) :=coso_rec.ctrl_attr_code_5;
   m_component_code(6) :=coso_rec.ctrl_attr_code_6;
   m_component_code(7) :=coso_rec.ctrl_attr_code_7;
   m_component_code(8) :=coso_rec.ctrl_attr_code_8;
   m_component_code(9) :=coso_rec.ctrl_attr_code_9;
   m_component_code(10) :=coso_rec.ctrl_attr_code_10;
   m_component_code(11) :=coso_rec.ctrl_attr_code_11;
   m_component_code(12) :=coso_rec.ctrl_attr_code_12;
   m_component_code(13) :=coso_rec.ctrl_attr_code_13;
   m_component_code(14) :=coso_rec.ctrl_attr_code_14;
   m_component_code(15) :=coso_rec.ctrl_attr_code_15;
   m_component_code(16) :=coso_rec.ctrl_attr_code_16;
   m_component_code(17) :=coso_rec.ctrl_attr_code_17;
   m_component_code(18) :=coso_rec.ctrl_attr_code_18;
   m_component_code(19) :=coso_rec.ctrl_attr_code_19;
   m_component_code(20) :=coso_rec.ctrl_attr_code_20;
   m_component_code(21) :=coso_rec.ctrl_attr_code_21;
   m_component_code(22) :=coso_rec.ctrl_attr_code_22;
   m_component_code(23) :=coso_rec.ctrl_attr_code_23;
   m_component_code(24) :=coso_rec.ctrl_attr_code_24;
   m_component_code(25) :=coso_rec.ctrl_attr_code_25;
   m_component_code(26) :=coso_rec.ctrl_attr_code_26;
   m_component_code(27) :=coso_rec.ctrl_attr_code_27;
   m_component_code(28) :=coso_rec.ctrl_attr_code_28;
   m_component_code(29) :=coso_rec.ctrl_attr_code_29;
   m_component_code(30) :=coso_rec.ctrl_attr_code_30;


    m_ineff_control(1) :=  coso_rec.ineff_ctrl_attr_1;
   m_ineff_control(2) :=  coso_rec.ineff_ctrl_attr_2;
   m_ineff_control(3) :=  coso_rec.ineff_ctrl_attr_3;
   m_ineff_control(4) :=   coso_rec.ineff_ctrl_attr_4;
   m_ineff_control(5) :=coso_rec.ineff_ctrl_attr_5;
   m_ineff_control(6) :=coso_rec.ineff_ctrl_attr_6;
   m_ineff_control(7) :=coso_rec.ineff_ctrl_attr_7;
   m_ineff_control(8) :=coso_rec.ineff_ctrl_attr_8;
   m_ineff_control(9) :=coso_rec.ineff_ctrl_attr_9;
   m_ineff_control(10) :=coso_rec.ineff_ctrl_attr_10;
   m_ineff_control(11) :=coso_rec.ineff_ctrl_attr_11;
   m_ineff_control(12) :=coso_rec.ineff_ctrl_attr_12;
   m_ineff_control(13) :=coso_rec.ineff_ctrl_attr_13;
   m_ineff_control(14) :=coso_rec.ineff_ctrl_attr_14;
   m_ineff_control(15) :=coso_rec.ineff_ctrl_attr_15;
   m_ineff_control(16) :=coso_rec.ineff_ctrl_attr_16;
   m_ineff_control(17) :=coso_rec.ineff_ctrl_attr_17;
   m_ineff_control(18) :=coso_rec.ineff_ctrl_attr_18;
   m_ineff_control(19) :=coso_rec.ineff_ctrl_attr_19;
   m_ineff_control(20) :=coso_rec.ineff_ctrl_attr_20;
   m_ineff_control(21) :=coso_rec.ineff_ctrl_attr_21;
   m_ineff_control(22) :=coso_rec.ineff_ctrl_attr_22;
   m_ineff_control(23) :=coso_rec.ineff_ctrl_attr_23;
   m_ineff_control(24) :=coso_rec.ineff_ctrl_attr_24;
   m_ineff_control(25) :=coso_rec.ineff_ctrl_attr_25;
   m_ineff_control(26) :=coso_rec.ineff_ctrl_attr_26;
   m_ineff_control(27) :=coso_rec.ineff_ctrl_attr_27;
   m_ineff_control(28) :=coso_rec.ineff_ctrl_attr_28;
   m_ineff_control(29) :=coso_rec.ineff_ctrl_attr_29;
   m_ineff_control(30) :=coso_rec.ineff_ctrl_attr_30;

 end loop; --end of COSO_COMPONENTS loop


-- **************** Check the REVISION of the Control came with the event has what COSO Codes *******************
-- and in which filed (out of 1 to 30) it is falling and the init varaible with the -1 or +1 corrsponding to that
--****************************************************************************************************************
 ctr := 0;
 for ctrl_coso_codes in comp_of_the_ctrl
 loop
    exit when comp_of_the_ctrl%notfound;
    ctr := 1;
    while ctr <=  30
    loop
      if m_component_code(ctr) = ctrl_coso_codes.COMPONENT_CODE then

       /********** insanity check for the numbers ******
  	********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b  ****/
        IF( (NVL(m_ineff_control(ctr),0) + add_or_deduct_value) < 0 or   (NVL(m_ineff_control(ctr),0) + add_or_deduct_value) > m_add_to_eval_ctrls(ctr))
  	THEN
  	AMW_FINSTMT_CERT_BES_PKG.G_REFRESH_FLAG := 'Y';
  	IF AMW_FINSTMT_CERT_BES_PKG.m_certification_list.exists(P_CERTIFICATION_ID) THEN
  	  EXIT;
  	ELSE
  	AMW_FINSTMT_CERT_BES_PKG.m_certification_list(AMW_FINSTMT_CERT_BES_PKG.m_certification_list.COUNT+1) := P_CERTIFICATION_ID;
  	EXIT;
  	END IF;
        END IF;

         m_ineff_control(ctr) :=  NVL(m_ineff_control(ctr),0) + add_or_deduct_value;



         if  P_NEW_FLAG = 'Y' then
             m_add_to_eval_ctrls(ctr) := 1;

         end if;

      end if;
       ctr := ctr + 1;

    end loop;


 end loop; --end of ctrl_coso_codes in comp_of_the_ctrl loop



    amw_fin_coso_views_pvt.UPDATE_FIN_ACC_ROW(
     x_fin_certification_id       	=> 	P_CERTIFICATION_ID	,
     x_financial_statement_id    	=> 	NULL 	,
     x_financial_item_id         	=> 	NULL	,
     x_account_group_id          	=> 	P_ACCOUNT_GROUP_ID,
     x_natural_account_id        	=> 	P_ACCOUNT_ID,
     x_object_type               	=> 	m_OBJECT_TYPE 	,
     x_ctrl_attribute_type       	=> 	m_ctrl_attribute_type       	,
     x_ineff_ctrl_attr_1         	=> 	m_ineff_control(1)	,
     x_ineff_ctrl_attr_2         	=> 	m_ineff_control(2)	,
     x_ineff_ctrl_attr_3         	=> 	m_ineff_control(3)	,
     x_ineff_ctrl_attr_4         	=> 	m_ineff_control(4)	,
     x_ineff_ctrl_attr_5         	=> 	m_ineff_control(5)	,
     x_ineff_ctrl_attr_6         	=> 	m_ineff_control(6)	,
     x_ineff_ctrl_attr_7         	=> 	m_ineff_control(7)	,
     x_ineff_ctrl_attr_8         	=> 	m_ineff_control(8)	,
     x_ineff_ctrl_attr_9         	=> 	m_ineff_control(9)	,
     x_ineff_ctrl_attr_10        	=> 	m_ineff_control(10)	,
     x_ineff_ctrl_attr_11        	=> 	m_ineff_control(11)	,
     x_ineff_ctrl_attr_12        	=> 	m_ineff_control(12)	,
     x_ineff_ctrl_attr_13        	=> 	m_ineff_control(13)	,
     x_ineff_ctrl_attr_14        	=> 	m_ineff_control(14)	,
     x_ineff_ctrl_attr_15        	=> 	m_ineff_control(15)	,
     x_ineff_ctrl_attr_16        	=> 	m_ineff_control(16)	,
     x_ineff_ctrl_attr_17        	=> 	m_ineff_control(17)	,
     x_ineff_ctrl_attr_18        	=> 	m_ineff_control(18)	,
     x_ineff_ctrl_attr_19        	=> 	m_ineff_control(19)	,
     x_ineff_ctrl_attr_20        	=> 	m_ineff_control(20)	,
     x_ineff_ctrl_attr_21        	=> 	m_ineff_control(21)	,
     x_ineff_ctrl_attr_22        	=> 	m_ineff_control(22)	,
     x_ineff_ctrl_attr_23        	=> 	m_ineff_control(23)	,
     x_ineff_ctrl_attr_24         	=> 	m_ineff_control(24)	,
     x_ineff_ctrl_attr_25        	=> 	m_ineff_control(25)	,
     x_ineff_ctrl_attr_26        	=> 	m_ineff_control(26)	,
     x_ineff_ctrl_attr_27        	=> 	m_ineff_control(27)	,
     x_ineff_ctrl_attr_28        	=> 	m_ineff_control(28)	,
     x_ineff_ctrl_attr_29        	=> 	m_ineff_control(29)	,
     x_ineff_ctrl_attr_30        	=> 	m_ineff_control(30)	,
     x_last_updated_by           	=> 	g_user_id	,
     x_last_update_date          	=> 	SYSDATE	,
     x_last_update_login         	=> 	g_login_id,
     x_eval_ctrl_attr_1         	=> 	m_add_to_eval_ctrls(1),
     x_eval_ctrl_attr_2         	=> 	m_add_to_eval_ctrls(2),
     x_eval_ctrl_attr_3         	=> 	m_add_to_eval_ctrls(3),
     x_eval_ctrl_attr_4         	=> 	m_add_to_eval_ctrls(4),
     x_eval_ctrl_attr_5         	=> 	m_add_to_eval_ctrls(5),
     x_eval_ctrl_attr_6         	=> 	m_add_to_eval_ctrls(6),
     x_eval_ctrl_attr_7         	=> 	m_add_to_eval_ctrls(7),
     x_eval_ctrl_attr_8         	=> 	m_add_to_eval_ctrls(8),
     x_eval_ctrl_attr_9         	=> 	m_add_to_eval_ctrls(9),
     x_eval_ctrl_attr_10        	=> 	m_add_to_eval_ctrls(10),
     x_eval_ctrl_attr_11         	=> 	m_add_to_eval_ctrls(11),
     x_eval_ctrl_attr_12         	=> 	m_add_to_eval_ctrls(12),
     x_eval_ctrl_attr_13         	=> 	m_add_to_eval_ctrls(13),
     x_eval_ctrl_attr_14         	=> 	m_add_to_eval_ctrls(14),
     x_eval_ctrl_attr_15         	=> 	m_add_to_eval_ctrls(15),
     x_eval_ctrl_attr_16         	=> 	m_add_to_eval_ctrls(16),
     x_eval_ctrl_attr_17         	=> 	m_add_to_eval_ctrls(17),
     x_eval_ctrl_attr_18         	=> 	m_add_to_eval_ctrls(18),
     x_eval_ctrl_attr_19         	=> 	m_add_to_eval_ctrls(19),
     x_eval_ctrl_attr_20        	=> 	m_add_to_eval_ctrls(20),
     x_eval_ctrl_attr_21         	=> 	m_add_to_eval_ctrls(21),
     x_eval_ctrl_attr_22         	=> 	m_add_to_eval_ctrls(22),
     x_eval_ctrl_attr_23         	=> 	m_add_to_eval_ctrls(23),
     x_eval_ctrl_attr_24         	=> 	m_add_to_eval_ctrls(24),
     x_eval_ctrl_attr_25         	=> 	m_add_to_eval_ctrls(25),
     x_eval_ctrl_attr_26         	=> 	m_add_to_eval_ctrls(26),
     x_eval_ctrl_attr_27         	=> 	m_add_to_eval_ctrls(27),
     x_eval_ctrl_attr_28         	=> 	m_add_to_eval_ctrls(28),
     x_eval_ctrl_attr_29         	=> 	m_add_to_eval_ctrls(29),
     x_eval_ctrl_attr_30        	=> 	m_add_to_eval_ctrls(30)
);


EXCEPTION
     WHEN NO_DATA_FOUND
	     THEN
            fnd_file.put_line (fnd_file.LOG, SUBSTR ('No data found in Update_acc_ctrl_components'
                || SUBSTR (SQLERRM, 1, 100), 1, 200));

     WHEN OTHERS
         THEN
            fnd_file.put_line (fnd_file.LOG, SUBSTR ('Unexpected Error in Update_acc_ctrl_components'
                || SUBSTR (SQLERRM, 1, 100), 1, 200));


end;
end ; --Update_acc_ctrl_components

--******************************************************************************************************
/* ************************* Code to be executed for updating Control Objective LEVEL DATA
-- when business evevnt is rised on opinion changes **** */
--******************************************************************************************************

PROCEDURE Update_item_ctrl_objectives
(P_CERTIFICATION_ID number ,
                  P_FINANCIAL_STATEMENT_ID number,
                  P_STATEMENT_GROUP_ID number,
                  P_FINANCIAL_ITEM_ID number,
                  P_CONTROL_ID        number ,
                  P_ORG_ID        number ,
                  P_CHANGE_FLAG VARCHAR2,
                  P_NEW_FLAG VARCHAR2) is

begin

 declare

cursor existing_code(par_type varchar2)
is
 select
   ctrl_attr_code_1,
   ctrl_attr_code_2,
   ctrl_attr_code_3,
   ctrl_attr_code_4,
   ctrl_attr_code_5,
   ctrl_attr_code_6,
   ctrl_attr_code_7,
   ctrl_attr_code_8,
   ctrl_attr_code_9,
   ctrl_attr_code_10,
   ctrl_attr_code_11,
   ctrl_attr_code_12,
   ctrl_attr_code_13,
   ctrl_attr_code_14,
   ctrl_attr_code_15,
   ctrl_attr_code_16,
   ctrl_attr_code_17,
   ctrl_attr_code_18,
   ctrl_attr_code_19,
   ctrl_attr_code_20,
   ctrl_attr_code_21,
   ctrl_attr_code_22,
   ctrl_attr_code_23,
   ctrl_attr_code_24,
   ctrl_attr_code_25,
   ctrl_attr_code_26,
   ctrl_attr_code_27,
   ctrl_attr_code_28,
   ctrl_attr_code_29,
   ctrl_attr_code_30,
    ineff_ctrl_attr_1,
   ineff_ctrl_attr_2,
   ineff_ctrl_attr_3,
   ineff_ctrl_attr_4,
   ineff_ctrl_attr_5,
   ineff_ctrl_attr_6,
   ineff_ctrl_attr_7,
   ineff_ctrl_attr_8,
   ineff_ctrl_attr_9,
   ineff_ctrl_attr_10,
   ineff_ctrl_attr_11,
   ineff_ctrl_attr_12,
   ineff_ctrl_attr_13,
   ineff_ctrl_attr_14,
   ineff_ctrl_attr_15,
   ineff_ctrl_attr_16,
   ineff_ctrl_attr_17,
   ineff_ctrl_attr_18,
   ineff_ctrl_attr_19,
   ineff_ctrl_attr_20,
   ineff_ctrl_attr_21,
   ineff_ctrl_attr_22,
   ineff_ctrl_attr_23,
   ineff_ctrl_attr_24,
   ineff_ctrl_attr_25,
   ineff_ctrl_attr_26,
   ineff_ctrl_attr_27,
   ineff_ctrl_attr_28,
   ineff_ctrl_attr_29,
   ineff_ctrl_attr_30
from
 amw_fin_cert_ctrl_sum
where
 fin_certification_id = P_CERTIFICATION_ID and
 ctrl_attribute_type = par_type and
 ROWNUM <2;

cursor obj_of_the_ctrl
is
select
 distinct
 comp.OBJECTIVE_CODE
from
  amw.amw_fin_item_acc_ctrl ctrl,
  amw_control_objectives  comp
where
 ctrl.FIN_CERTIFICATION_ID= P_CERTIFICATION_ID
 and
 ctrl.OBJECT_TYPE = 'FINANCIAL ITEM' and
 ctrl.FINANCIAL_ITEM_ID= P_FINANCIAL_ITEM_ID
 and
 ctrl.CONTROL_REV_ID =comp.CONTROL_REV_ID and
 ctrl.ORGANIZATION_ID = P_ORG_ID
 and
 ctrl.CONTROL_ID =  P_CONTROL_ID ;



 g_user_id              NUMBER        := fnd_global.user_id;
 g_login_id             NUMBER        := fnd_global.conc_login_id;
 m_object_version_number NUMBER;
 ctr integer :=0;
 max_num_of_codes integer :=0;
 m_ctrl_attribute_type VARCHAR2(30) :='CTRL_OBJECTIVES';
 m_OBJECT_TYPE VARCHAR2(50) := 'FINANCIAL ITEM';


 m_component_code component_code_array;
 m_ineff_control  ineff_control_array ;
 --m_acc_assert_flag component_code_array;
 m_add_to_eval_ctrls  total_control_array ;


 add_or_deduct_value number :=0;

 begin

 -- ************ Since the Table has 30 Fileds only initialize 30 Positios in the Array**************--
 ctr :=  1;

 loop
   EXIT  WHEN ctr > 30;

    m_component_code(ctr) := null;
  --  m_acc_assert_flag(ctr) := 'N';
    m_ineff_control(ctr) := 0;
    m_add_to_eval_ctrls(ctr) := 0;

    ctr := ctr + 1;

 end loop; --end of initialization

 -- ************ get All Control Components Codes and Load it in an Array for later use **************--
 m_ctrl_attribute_type :='CTRL_OBJECTIVES';

 --- P_CHANGE_FLAG = 'F' means the Opinion is changed from Ineffective to Efective
 --- P_CHANGE_FLAG = 'B' means the Opinion is changed from Efective to Ineffective

  if P_CHANGE_FLAG = 'B' then
    add_or_deduct_value := 1;
 elsif (P_CHANGE_FLAG = 'F' and P_NEW_FLAG <> 'Y') then
    add_or_deduct_value := -1;
 elsif P_CHANGE_FLAG = 'N' then
  return;
 end if;

 ctr := 0;
 for objective_rec  in existing_code(m_ctrl_attribute_type)
 loop
    exit when existing_code%notfound;

   m_component_code(1) :=  objective_rec .ctrl_attr_code_1;
   m_component_code(2) :=  objective_rec .ctrl_attr_code_2;
   m_component_code(3) :=  objective_rec .ctrl_attr_code_3;
   m_component_code(4) :=   objective_rec .ctrl_attr_code_4;
   m_component_code(5) :=objective_rec .ctrl_attr_code_5;
   m_component_code(6) :=objective_rec .ctrl_attr_code_6;
   m_component_code(7) :=objective_rec .ctrl_attr_code_7;
   m_component_code(8) :=objective_rec .ctrl_attr_code_8;
   m_component_code(9) :=objective_rec .ctrl_attr_code_9;
   m_component_code(10) :=objective_rec .ctrl_attr_code_10;
   m_component_code(11) :=objective_rec .ctrl_attr_code_11;
   m_component_code(12) :=objective_rec .ctrl_attr_code_12;
   m_component_code(13) :=objective_rec .ctrl_attr_code_13;
   m_component_code(14) :=objective_rec .ctrl_attr_code_14;
   m_component_code(15) :=objective_rec .ctrl_attr_code_15;
   m_component_code(16) :=objective_rec .ctrl_attr_code_16;
   m_component_code(17) :=objective_rec .ctrl_attr_code_17;
   m_component_code(18) :=objective_rec .ctrl_attr_code_18;
   m_component_code(19) :=objective_rec .ctrl_attr_code_19;
   m_component_code(20) :=objective_rec .ctrl_attr_code_20;
   m_component_code(21) :=objective_rec .ctrl_attr_code_21;
   m_component_code(22) :=objective_rec .ctrl_attr_code_22;
   m_component_code(23) :=objective_rec .ctrl_attr_code_23;
   m_component_code(24) :=objective_rec .ctrl_attr_code_24;
   m_component_code(25) :=objective_rec .ctrl_attr_code_25;
   m_component_code(26) :=objective_rec .ctrl_attr_code_26;
   m_component_code(27) :=objective_rec .ctrl_attr_code_27;
   m_component_code(28) :=objective_rec .ctrl_attr_code_28;
   m_component_code(29) :=objective_rec .ctrl_attr_code_29;
   m_component_code(30) :=objective_rec .ctrl_attr_code_30;

   m_ineff_control(1) :=  objective_rec.ineff_ctrl_attr_1;
   m_ineff_control(2) :=  objective_rec.ineff_ctrl_attr_2;
   m_ineff_control(3) :=  objective_rec.ineff_ctrl_attr_3;
   m_ineff_control(4) :=   objective_rec.ineff_ctrl_attr_4;
   m_ineff_control(5) :=objective_rec.ineff_ctrl_attr_5;
   m_ineff_control(6) :=objective_rec.ineff_ctrl_attr_6;
   m_ineff_control(7) :=objective_rec.ineff_ctrl_attr_7;
   m_ineff_control(8) :=objective_rec.ineff_ctrl_attr_8;
   m_ineff_control(9) :=objective_rec.ineff_ctrl_attr_9;
   m_ineff_control(10) :=objective_rec.ineff_ctrl_attr_10;
   m_ineff_control(11) :=objective_rec.ineff_ctrl_attr_11;
   m_ineff_control(12) :=objective_rec.ineff_ctrl_attr_12;
   m_ineff_control(13) :=objective_rec.ineff_ctrl_attr_13;
   m_ineff_control(14) :=objective_rec.ineff_ctrl_attr_14;
   m_ineff_control(15) :=objective_rec.ineff_ctrl_attr_15;
   m_ineff_control(16) :=objective_rec.ineff_ctrl_attr_16;
   m_ineff_control(17) :=objective_rec.ineff_ctrl_attr_17;
   m_ineff_control(18) :=objective_rec.ineff_ctrl_attr_18;
   m_ineff_control(19) :=objective_rec.ineff_ctrl_attr_19;
   m_ineff_control(20) :=objective_rec.ineff_ctrl_attr_20;
   m_ineff_control(21) :=objective_rec.ineff_ctrl_attr_21;
   m_ineff_control(22) :=objective_rec.ineff_ctrl_attr_22;
   m_ineff_control(23) :=objective_rec.ineff_ctrl_attr_23;
   m_ineff_control(24) :=objective_rec.ineff_ctrl_attr_24;
   m_ineff_control(25) :=objective_rec.ineff_ctrl_attr_25;
   m_ineff_control(26) :=objective_rec.ineff_ctrl_attr_26;
   m_ineff_control(27) :=objective_rec.ineff_ctrl_attr_27;
   m_ineff_control(28) :=objective_rec.ineff_ctrl_attr_28;
   m_ineff_control(29) :=objective_rec.ineff_ctrl_attr_29;
   m_ineff_control(30) :=objective_rec.ineff_ctrl_attr_30;


 end loop; --end of control objectives loop


-- **************** Check the REVISION of the Control came with the event has what COSO Codes *******************
-- and in which filed (out of 1 to 30) it is falling and the init varaible with the -1 or +1 corrsponding to that
--****************************************************************************************************************
 ctr := 0;
 for ctrl_objective_codes in obj_of_the_ctrl
 loop
    exit when obj_of_the_ctrl%notfound;
    ctr := 1;
    while ctr <=  30
    loop


      -- Only  '+1' or '-1' is stored and the actual addition or deduction (Addition of negative value)
      -- is done with the original value during the actual Table update

         if m_component_code(ctr) = ctrl_objective_codes.OBJECTIVE_CODE then

       /********** insanity check for the numbers ******
  	********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b  ****/
        IF( (NVL(m_ineff_control(ctr),0) + add_or_deduct_value) < 0 or   (NVL(m_ineff_control(ctr),0) + add_or_deduct_value) > m_add_to_eval_ctrls(ctr))
  	THEN
  	AMW_FINSTMT_CERT_BES_PKG.G_REFRESH_FLAG := 'Y';
  	IF AMW_FINSTMT_CERT_BES_PKG.m_certification_list.exists(P_CERTIFICATION_ID) THEN
  	  EXIT;
  	ELSE
  	AMW_FINSTMT_CERT_BES_PKG.m_certification_list(AMW_FINSTMT_CERT_BES_PKG.m_certification_list.COUNT+1) := P_CERTIFICATION_ID;
  	EXIT;
  	END IF;
        END IF;

         m_ineff_control(ctr) :=  NVL(m_ineff_control(ctr),0) + add_or_deduct_value;


         if  P_NEW_FLAG = 'Y' then
      m_add_to_eval_ctrls(ctr) := 1;

         end if;

      end if;
       ctr := ctr + 1;

    end loop;


 end loop; --end of ctrl_objective_codes in obj_of_the_ctrl loop




    amw_fin_coso_views_pvt.UPDATE_FIN_ITEM_ROW(
     x_fin_certification_id       	=> 	P_CERTIFICATION_ID	,
     x_financial_statement_id    	=> 	P_FINANCIAL_STATEMENT_ID 	,
     x_financial_item_id         	=> 	P_FINANCIAL_ITEM_ID 	,
     x_account_group_id          	=> 	null	,
     x_natural_account_id        	=> 	null,
     x_object_type               	=> 	m_OBJECT_TYPE 	,
     x_ctrl_attribute_type       	=> 	m_ctrl_attribute_type       	,
     x_ineff_ctrl_attr_1         	=> 	m_ineff_control(1)	,
     x_ineff_ctrl_attr_2         	=> 	m_ineff_control(2)	,
     x_ineff_ctrl_attr_3         	=> 	m_ineff_control(3)	,
     x_ineff_ctrl_attr_4         	=> 	m_ineff_control(4)	,
     x_ineff_ctrl_attr_5         	=> 	m_ineff_control(5)	,
     x_ineff_ctrl_attr_6         	=> 	m_ineff_control(6)	,
     x_ineff_ctrl_attr_7         	=> 	m_ineff_control(7)	,
     x_ineff_ctrl_attr_8         	=> 	m_ineff_control(8)	,
     x_ineff_ctrl_attr_9         	=> 	m_ineff_control(9)	,
     x_ineff_ctrl_attr_10        	=> 	m_ineff_control(10)	,
     x_ineff_ctrl_attr_11        	=> 	m_ineff_control(11)	,
     x_ineff_ctrl_attr_12        	=> 	m_ineff_control(12)	,
     x_ineff_ctrl_attr_13        	=> 	m_ineff_control(13)	,
     x_ineff_ctrl_attr_14        	=> 	m_ineff_control(14)	,
     x_ineff_ctrl_attr_15        	=> 	m_ineff_control(15)	,
     x_ineff_ctrl_attr_16        	=> 	m_ineff_control(16)	,
     x_ineff_ctrl_attr_17        	=> 	m_ineff_control(17)	,
     x_ineff_ctrl_attr_18        	=> 	m_ineff_control(18)	,
     x_ineff_ctrl_attr_19        	=> 	m_ineff_control(19)	,
     x_ineff_ctrl_attr_20        	=> 	m_ineff_control(20)	,
     x_ineff_ctrl_attr_21        	=> 	m_ineff_control(21)	,
     x_ineff_ctrl_attr_22        	=> 	m_ineff_control(22)	,
     x_ineff_ctrl_attr_23        	=> 	m_ineff_control(23)	,
     x_ineff_ctrl_attr_24         	=> 	m_ineff_control(24)	,
     x_ineff_ctrl_attr_25        	=> 	m_ineff_control(25)	,
     x_ineff_ctrl_attr_26        	=> 	m_ineff_control(26)	,
     x_ineff_ctrl_attr_27        	=> 	m_ineff_control(27)	,
     x_ineff_ctrl_attr_28        	=> 	m_ineff_control(28)	,
     x_ineff_ctrl_attr_29        	=> 	m_ineff_control(29)	,
     x_ineff_ctrl_attr_30        	=> 	m_ineff_control(30)	,
     x_last_updated_by           	=> 	g_user_id	,
     x_last_update_date          	=> 	SYSDATE	,
     x_last_update_login         	=> 	g_login_id,
     x_eval_ctrl_attr_1         	=> 	m_add_to_eval_ctrls(1),
     x_eval_ctrl_attr_2         	=> 	m_add_to_eval_ctrls(2),
     x_eval_ctrl_attr_3         	=> 	m_add_to_eval_ctrls(3),
     x_eval_ctrl_attr_4         	=> 	m_add_to_eval_ctrls(4),
     x_eval_ctrl_attr_5         	=> 	m_add_to_eval_ctrls(5),
     x_eval_ctrl_attr_6         	=> 	m_add_to_eval_ctrls(6),
     x_eval_ctrl_attr_7         	=> 	m_add_to_eval_ctrls(7),
     x_eval_ctrl_attr_8         	=> 	m_add_to_eval_ctrls(8),
     x_eval_ctrl_attr_9         	=> 	m_add_to_eval_ctrls(9),
     x_eval_ctrl_attr_10        	=> 	m_add_to_eval_ctrls(10),
     x_eval_ctrl_attr_11         	=> 	m_add_to_eval_ctrls(11),
     x_eval_ctrl_attr_12         	=> 	m_add_to_eval_ctrls(12),
     x_eval_ctrl_attr_13         	=> 	m_add_to_eval_ctrls(13),
     x_eval_ctrl_attr_14         	=> 	m_add_to_eval_ctrls(14),
     x_eval_ctrl_attr_15         	=> 	m_add_to_eval_ctrls(15),
     x_eval_ctrl_attr_16         	=> 	m_add_to_eval_ctrls(16),
     x_eval_ctrl_attr_17         	=> 	m_add_to_eval_ctrls(17),
     x_eval_ctrl_attr_18         	=> 	m_add_to_eval_ctrls(18),
     x_eval_ctrl_attr_19         	=> 	m_add_to_eval_ctrls(19),
     x_eval_ctrl_attr_20        	=> 	m_add_to_eval_ctrls(20),
     x_eval_ctrl_attr_21         	=> 	m_add_to_eval_ctrls(21),
     x_eval_ctrl_attr_22         	=> 	m_add_to_eval_ctrls(22),
     x_eval_ctrl_attr_23         	=> 	m_add_to_eval_ctrls(23),
     x_eval_ctrl_attr_24         	=> 	m_add_to_eval_ctrls(24),
     x_eval_ctrl_attr_25         	=> 	m_add_to_eval_ctrls(25),
     x_eval_ctrl_attr_26         	=> 	m_add_to_eval_ctrls(26),
     x_eval_ctrl_attr_27         	=> 	m_add_to_eval_ctrls(27),
     x_eval_ctrl_attr_28         	=> 	m_add_to_eval_ctrls(28),
     x_eval_ctrl_attr_29         	=> 	m_add_to_eval_ctrls(29),
     x_eval_ctrl_attr_30        	=> 	m_add_to_eval_ctrls(30));

  EXCEPTION
     WHEN NO_DATA_FOUND
	     THEN
            fnd_file.put_line (fnd_file.LOG, SUBSTR ('No data found in Update_item_ctrl_components'
                || SUBSTR (SQLERRM, 1, 100), 1, 200));

     WHEN OTHERS
         THEN
            fnd_file.put_line (fnd_file.LOG, SUBSTR ('Unexpected Error in Update_item_ctrl_components'
                || SUBSTR (SQLERRM, 1, 100), 1, 200));


  end;
end ; --Update_item_ctrl_objectives

------------------------------ fOR THE ACCOUNTS ------------------------------------------------------------------------------


PROCEDURE Update_acc_ctrl_objectives
(P_CERTIFICATION_ID number ,
                  P_ACCOUNT_GROUP_ID  number ,
                  P_ACCOUNT_ID        number ,
                  P_CONTROL_ID        number ,
                  P_ORG_ID        number ,
                  P_CHANGE_FLAG VARCHAR2,
                  P_NEW_FLAG VARCHAR2) is



begin
declare
cursor existing_code(par_type varchar2)
is
 select
   ctrl_attr_code_1,
   ctrl_attr_code_2,
   ctrl_attr_code_3,
   ctrl_attr_code_4,
   ctrl_attr_code_5,
   ctrl_attr_code_6,
   ctrl_attr_code_7,
   ctrl_attr_code_8,
   ctrl_attr_code_9,
   ctrl_attr_code_10,
   ctrl_attr_code_11,
   ctrl_attr_code_12,
   ctrl_attr_code_13,
   ctrl_attr_code_14,
   ctrl_attr_code_15,
   ctrl_attr_code_16,
   ctrl_attr_code_17,
   ctrl_attr_code_18,
   ctrl_attr_code_19,
   ctrl_attr_code_20,
   ctrl_attr_code_21,
   ctrl_attr_code_22,
   ctrl_attr_code_23,
   ctrl_attr_code_24,
   ctrl_attr_code_25,
   ctrl_attr_code_26,
   ctrl_attr_code_27,
   ctrl_attr_code_28,
   ctrl_attr_code_29,
   ctrl_attr_code_30,
 ineff_ctrl_attr_1,
   ineff_ctrl_attr_2,
   ineff_ctrl_attr_3,
   ineff_ctrl_attr_4,
   ineff_ctrl_attr_5,
   ineff_ctrl_attr_6,
   ineff_ctrl_attr_7,
   ineff_ctrl_attr_8,
   ineff_ctrl_attr_9,
   ineff_ctrl_attr_10,
   ineff_ctrl_attr_11,
   ineff_ctrl_attr_12,
   ineff_ctrl_attr_13,
   ineff_ctrl_attr_14,
   ineff_ctrl_attr_15,
   ineff_ctrl_attr_16,
   ineff_ctrl_attr_17,
   ineff_ctrl_attr_18,
   ineff_ctrl_attr_19,
   ineff_ctrl_attr_20,
   ineff_ctrl_attr_21,
   ineff_ctrl_attr_22,
   ineff_ctrl_attr_23,
   ineff_ctrl_attr_24,
   ineff_ctrl_attr_25,
   ineff_ctrl_attr_26,
   ineff_ctrl_attr_27,
   ineff_ctrl_attr_28,
   ineff_ctrl_attr_29,
   ineff_ctrl_attr_30
from
 amw_fin_cert_ctrl_sum
where
 fin_certification_id = P_CERTIFICATION_ID and
 ctrl_attribute_type = par_type and
 ROWNUM <2
AND  account_group_id =  P_ACCOUNT_GROUP_ID and
 natural_account_id  =  P_ACCOUNT_ID        and
 object_type	= 'ACCOUNT' ;


----------------------------------------------
cursor obj_of_the_ctrl
is
 select
 distinct
  comp.OBJECTIVE_CODE
from
  amw.amw_fin_item_acc_ctrl ctrl,
  amw_control_objectives  comp
where
 ctrl.FIN_CERTIFICATION_ID=  P_CERTIFICATION_ID
 and
 ctrl.OBJECT_TYPE = 'ACCOUNT' and
 ctrl.ACCOUNT_GROUP_ID=   P_ACCOUNT_GROUP_ID
 AND
 ctrl.NATURAL_ACCOUNT_ID = P_ACCOUNT_ID
 and
 ctrl.CONTROL_REV_ID =comp.CONTROL_REV_ID and
 ctrl.ORGANIZATION_ID = P_ORG_ID
 and
 ctrl.CONTROL_ID =  P_CONTROL_ID ;

----------------------------------------------------
 g_user_id              NUMBER        := fnd_global.user_id;
 g_login_id             NUMBER        := fnd_global.conc_login_id;
 m_object_version_number NUMBER;
 ctr integer :=0;
 max_num_of_codes integer :=0;
 m_ctrl_attribute_type VARCHAR2(30) :='CTRL_OBJECTIVES';
 m_OBJECT_TYPE VARCHAR2(50) := 'ACCOUNT';


 m_component_code component_code_array;
 m_ineff_control  ineff_control_array ;
-- m_acc_assert_flag component_code_array;
 m_add_to_eval_ctrls  total_control_array ;

 add_or_deduct_value number :=0;

begin

 -- ************ Since the Table has 30 Fileds only initialize 30 Positios in the Array**************--
 ctr :=  1;

 loop
   EXIT  WHEN ctr > 30;

    m_component_code(ctr) := null;
  --  m_acc_assert_flag(ctr) := 'N';
    m_ineff_control(ctr) := 0;
    m_add_to_eval_ctrls(ctr) := 0;

    ctr := ctr + 1;

 end loop; --end of initialization

 -- ************ get All Control Components Codes and Load it in an Array for later use **************--
 m_ctrl_attribute_type  :='CTRL_OBJECTIVES';

 --- P_CHANGE_FLAG = 'F' means the Opinion is changed from Ineffective to Efective
 --- P_CHANGE_FLAG = 'B' means the Opinion is changed from Efective to Ineffective

  if P_CHANGE_FLAG = 'B' then
    add_or_deduct_value := 1;
 elsif (P_CHANGE_FLAG = 'F' and P_NEW_FLAG <> 'Y') then
    add_or_deduct_value := -1;
 elsif P_CHANGE_FLAG = 'N' then
  return;
 end if;

 ctr := 0;
 for objective_rec  in existing_code(m_ctrl_attribute_type)
 loop
    exit when existing_code%notfound;

       m_component_code(1) :=  objective_rec .ctrl_attr_code_1;
   m_component_code(2) :=  objective_rec .ctrl_attr_code_2;
   m_component_code(3) :=  objective_rec .ctrl_attr_code_3;
   m_component_code(4) :=   objective_rec .ctrl_attr_code_4;
   m_component_code(5) :=objective_rec .ctrl_attr_code_5;
   m_component_code(6) :=objective_rec .ctrl_attr_code_6;
   m_component_code(7) :=objective_rec .ctrl_attr_code_7;
   m_component_code(8) :=objective_rec .ctrl_attr_code_8;
   m_component_code(9) :=objective_rec .ctrl_attr_code_9;
   m_component_code(10) :=objective_rec .ctrl_attr_code_10;
   m_component_code(11) :=objective_rec .ctrl_attr_code_11;
   m_component_code(12) :=objective_rec .ctrl_attr_code_12;
   m_component_code(13) :=objective_rec .ctrl_attr_code_13;
   m_component_code(14) :=objective_rec .ctrl_attr_code_14;
   m_component_code(15) :=objective_rec .ctrl_attr_code_15;
   m_component_code(16) :=objective_rec .ctrl_attr_code_16;
   m_component_code(17) :=objective_rec .ctrl_attr_code_17;
   m_component_code(18) :=objective_rec .ctrl_attr_code_18;
   m_component_code(19) :=objective_rec .ctrl_attr_code_19;
   m_component_code(20) :=objective_rec .ctrl_attr_code_20;
   m_component_code(21) :=objective_rec .ctrl_attr_code_21;
   m_component_code(22) :=objective_rec .ctrl_attr_code_22;
   m_component_code(23) :=objective_rec .ctrl_attr_code_23;
   m_component_code(24) :=objective_rec .ctrl_attr_code_24;
   m_component_code(25) :=objective_rec .ctrl_attr_code_25;
   m_component_code(26) :=objective_rec .ctrl_attr_code_26;
   m_component_code(27) :=objective_rec .ctrl_attr_code_27;
   m_component_code(28) :=objective_rec .ctrl_attr_code_28;
   m_component_code(29) :=objective_rec .ctrl_attr_code_29;
   m_component_code(30) :=objective_rec .ctrl_attr_code_30;

  m_ineff_control(1) :=  objective_rec.ineff_ctrl_attr_1;
   m_ineff_control(2) :=  objective_rec.ineff_ctrl_attr_2;
   m_ineff_control(3) :=  objective_rec.ineff_ctrl_attr_3;
   m_ineff_control(4) :=   objective_rec.ineff_ctrl_attr_4;
   m_ineff_control(5) :=objective_rec.ineff_ctrl_attr_5;
   m_ineff_control(6) :=objective_rec.ineff_ctrl_attr_6;
   m_ineff_control(7) :=objective_rec.ineff_ctrl_attr_7;
   m_ineff_control(8) :=objective_rec.ineff_ctrl_attr_8;
   m_ineff_control(9) :=objective_rec.ineff_ctrl_attr_9;
   m_ineff_control(10) :=objective_rec.ineff_ctrl_attr_10;
   m_ineff_control(11) :=objective_rec.ineff_ctrl_attr_11;
   m_ineff_control(12) :=objective_rec.ineff_ctrl_attr_12;
   m_ineff_control(13) :=objective_rec.ineff_ctrl_attr_13;
   m_ineff_control(14) :=objective_rec.ineff_ctrl_attr_14;
   m_ineff_control(15) :=objective_rec.ineff_ctrl_attr_15;
   m_ineff_control(16) :=objective_rec.ineff_ctrl_attr_16;
   m_ineff_control(17) :=objective_rec.ineff_ctrl_attr_17;
   m_ineff_control(18) :=objective_rec.ineff_ctrl_attr_18;
   m_ineff_control(19) :=objective_rec.ineff_ctrl_attr_19;
   m_ineff_control(20) :=objective_rec.ineff_ctrl_attr_20;
   m_ineff_control(21) :=objective_rec.ineff_ctrl_attr_21;
   m_ineff_control(22) :=objective_rec.ineff_ctrl_attr_22;
   m_ineff_control(23) :=objective_rec.ineff_ctrl_attr_23;
   m_ineff_control(24) :=objective_rec.ineff_ctrl_attr_24;
   m_ineff_control(25) :=objective_rec.ineff_ctrl_attr_25;
   m_ineff_control(26) :=objective_rec.ineff_ctrl_attr_26;
   m_ineff_control(27) :=objective_rec.ineff_ctrl_attr_27;
   m_ineff_control(28) :=objective_rec.ineff_ctrl_attr_28;
   m_ineff_control(29) :=objective_rec.ineff_ctrl_attr_29;
   m_ineff_control(30) :=objective_rec.ineff_ctrl_attr_30;

 end loop; --end of COSO_COMPONENTS loop


-- **************** Check the REVISION of the Control came with the event has what COSO Codes *******************
-- and in which filed (out of 1 to 30) it is falling and the init varaible with the -1 or +1 corrsponding to that
--****************************************************************************************************************
 ctr := 0;
 for ctrl_objective_codes in obj_of_the_ctrl
 loop
    exit when obj_of_the_ctrl%notfound;
    ctr := 1;
    while ctr <=  30
    loop
      if m_component_code(ctr) = ctrl_objective_codes.OBJECTIVE_CODE then

         m_ineff_control(ctr) :=  NVL(m_ineff_control(ctr),0) + add_or_deduct_value;

         -- m_ineff_control(ctr) :=  add_or_deduct_value;

         if  P_NEW_FLAG = 'Y' then
          m_add_to_eval_ctrls(ctr) := 1;

         end if;

      end if;
       ctr := ctr + 1;

    end loop;


 end loop; --end of ctrl_objective_codes in obj_of_the_ctrl loop




    amw_fin_coso_views_pvt.UPDATE_FIN_ACC_ROW(
     x_fin_certification_id       	=> 	P_CERTIFICATION_ID	,
     x_financial_statement_id    	=> 	NULL 	,
     x_financial_item_id         	=> 	NULL	,
     x_account_group_id          	=> 	P_ACCOUNT_GROUP_ID,
     x_natural_account_id        	=> 	P_ACCOUNT_ID,
     x_object_type               	=> 	m_OBJECT_TYPE 	,
     x_ctrl_attribute_type       	=> 	m_ctrl_attribute_type       	,
     x_ineff_ctrl_attr_1         	=> 	m_ineff_control(1)	,
     x_ineff_ctrl_attr_2         	=> 	m_ineff_control(2)	,
     x_ineff_ctrl_attr_3         	=> 	m_ineff_control(3)	,
     x_ineff_ctrl_attr_4         	=> 	m_ineff_control(4)	,
     x_ineff_ctrl_attr_5         	=> 	m_ineff_control(5)	,
     x_ineff_ctrl_attr_6         	=> 	m_ineff_control(6)	,
     x_ineff_ctrl_attr_7         	=> 	m_ineff_control(7)	,
     x_ineff_ctrl_attr_8         	=> 	m_ineff_control(8)	,
     x_ineff_ctrl_attr_9         	=> 	m_ineff_control(9)	,
     x_ineff_ctrl_attr_10        	=> 	m_ineff_control(10)	,
     x_ineff_ctrl_attr_11        	=> 	m_ineff_control(11)	,
     x_ineff_ctrl_attr_12        	=> 	m_ineff_control(12)	,
     x_ineff_ctrl_attr_13        	=> 	m_ineff_control(13)	,
     x_ineff_ctrl_attr_14        	=> 	m_ineff_control(14)	,
     x_ineff_ctrl_attr_15        	=> 	m_ineff_control(15)	,
     x_ineff_ctrl_attr_16        	=> 	m_ineff_control(16)	,
     x_ineff_ctrl_attr_17        	=> 	m_ineff_control(17)	,
     x_ineff_ctrl_attr_18        	=> 	m_ineff_control(18)	,
     x_ineff_ctrl_attr_19        	=> 	m_ineff_control(19)	,
     x_ineff_ctrl_attr_20        	=> 	m_ineff_control(20)	,
     x_ineff_ctrl_attr_21        	=> 	m_ineff_control(21)	,
     x_ineff_ctrl_attr_22        	=> 	m_ineff_control(22)	,
     x_ineff_ctrl_attr_23        	=> 	m_ineff_control(23)	,
     x_ineff_ctrl_attr_24         	=> 	m_ineff_control(24)	,
     x_ineff_ctrl_attr_25        	=> 	m_ineff_control(25)	,
     x_ineff_ctrl_attr_26        	=> 	m_ineff_control(26)	,
     x_ineff_ctrl_attr_27        	=> 	m_ineff_control(27)	,
     x_ineff_ctrl_attr_28        	=> 	m_ineff_control(28)	,
     x_ineff_ctrl_attr_29        	=> 	m_ineff_control(29)	,
     x_ineff_ctrl_attr_30        	=> 	m_ineff_control(30)	,
     x_last_updated_by           	=> 	g_user_id	,
     x_last_update_date          	=> 	SYSDATE	,
     x_last_update_login         	=> 	g_login_id,
     x_eval_ctrl_attr_1         	=> 	m_add_to_eval_ctrls(1),
     x_eval_ctrl_attr_2         	=> 	m_add_to_eval_ctrls(2),
     x_eval_ctrl_attr_3         	=> 	m_add_to_eval_ctrls(3),
     x_eval_ctrl_attr_4         	=> 	m_add_to_eval_ctrls(4),
     x_eval_ctrl_attr_5         	=> 	m_add_to_eval_ctrls(5),
     x_eval_ctrl_attr_6         	=> 	m_add_to_eval_ctrls(6),
     x_eval_ctrl_attr_7         	=> 	m_add_to_eval_ctrls(7),
     x_eval_ctrl_attr_8         	=> 	m_add_to_eval_ctrls(8),
     x_eval_ctrl_attr_9         	=> 	m_add_to_eval_ctrls(9),
     x_eval_ctrl_attr_10        	=> 	m_add_to_eval_ctrls(10),
     x_eval_ctrl_attr_11         	=> 	m_add_to_eval_ctrls(11),
     x_eval_ctrl_attr_12         	=> 	m_add_to_eval_ctrls(12),
     x_eval_ctrl_attr_13         	=> 	m_add_to_eval_ctrls(13),
     x_eval_ctrl_attr_14         	=> 	m_add_to_eval_ctrls(14),
     x_eval_ctrl_attr_15         	=> 	m_add_to_eval_ctrls(15),
     x_eval_ctrl_attr_16         	=> 	m_add_to_eval_ctrls(16),
     x_eval_ctrl_attr_17         	=> 	m_add_to_eval_ctrls(17),
     x_eval_ctrl_attr_18         	=> 	m_add_to_eval_ctrls(18),
     x_eval_ctrl_attr_19         	=> 	m_add_to_eval_ctrls(19),
     x_eval_ctrl_attr_20        	=> 	m_add_to_eval_ctrls(20),
     x_eval_ctrl_attr_21         	=> 	m_add_to_eval_ctrls(21),
     x_eval_ctrl_attr_22         	=> 	m_add_to_eval_ctrls(22),
     x_eval_ctrl_attr_23         	=> 	m_add_to_eval_ctrls(23),
     x_eval_ctrl_attr_24         	=> 	m_add_to_eval_ctrls(24),
     x_eval_ctrl_attr_25         	=> 	m_add_to_eval_ctrls(25),
     x_eval_ctrl_attr_26         	=> 	m_add_to_eval_ctrls(26),
     x_eval_ctrl_attr_27         	=> 	m_add_to_eval_ctrls(27),
     x_eval_ctrl_attr_28         	=> 	m_add_to_eval_ctrls(28),
     x_eval_ctrl_attr_29         	=> 	m_add_to_eval_ctrls(29),
     x_eval_ctrl_attr_30        	=> 	m_add_to_eval_ctrls(30)

);


EXCEPTION
     WHEN NO_DATA_FOUND
	     THEN
            fnd_file.put_line (fnd_file.LOG, SUBSTR ('No data found in Update_acc_ctrl_components'
                || SUBSTR (SQLERRM, 1, 100), 1, 200));

     WHEN OTHERS
         THEN
            fnd_file.put_line (fnd_file.LOG, SUBSTR ('Unexpected Error in Update_acc_ctrl_components'
                || SUBSTR (SQLERRM, 1, 100), 1, 200));


end;
end ; --Update_acc_ctrl_objectives
------------------------------------------------------------------------------------------------------------
--******************************************************************************************************
/* ************************* End of Code to be executed for updating Control Objective LEVEL DATA
-- when business evevnt is rised on opinion changes **** */
--******************************************************************************************************


------------------------------------------------------------------------------------------------------------

--******************************************************************************************************
/* ************************* Code to be executed for updating Control Assertions LEVEL DATA
-- when business evevnt is rised on opinion changes **** */
--******************************************************************************************************

PROCEDURE Update_item_ctrl_Assertions
(P_CERTIFICATION_ID number ,
                  P_FINANCIAL_STATEMENT_ID number,
                  P_STATEMENT_GROUP_ID number,
                  P_FINANCIAL_ITEM_ID number,
                  P_CONTROL_ID        number ,
                  P_ORG_ID        number ,
                  P_CHANGE_FLAG VARCHAR2,
                  P_NEW_FLAG VARCHAR2) is

begin

 declare

cursor existing_code(par_type varchar2)
is
 select
   ctrl_attr_code_1,
   ctrl_attr_code_2,
   ctrl_attr_code_3,
   ctrl_attr_code_4,
   ctrl_attr_code_5,
   ctrl_attr_code_6,
   ctrl_attr_code_7,
   ctrl_attr_code_8,
   ctrl_attr_code_9,
   ctrl_attr_code_10,
   ctrl_attr_code_11,
   ctrl_attr_code_12,
   ctrl_attr_code_13,
   ctrl_attr_code_14,
   ctrl_attr_code_15,
   ctrl_attr_code_16,
   ctrl_attr_code_17,
   ctrl_attr_code_18,
   ctrl_attr_code_19,
   ctrl_attr_code_20,
   ctrl_attr_code_21,
   ctrl_attr_code_22,
   ctrl_attr_code_23,
   ctrl_attr_code_24,
   ctrl_attr_code_25,
   ctrl_attr_code_26,
   ctrl_attr_code_27,
   ctrl_attr_code_28,
   ctrl_attr_code_29,
   ctrl_attr_code_30,
ineff_ctrl_attr_1,
   ineff_ctrl_attr_2,
   ineff_ctrl_attr_3,
   ineff_ctrl_attr_4,
   ineff_ctrl_attr_5,
   ineff_ctrl_attr_6,
   ineff_ctrl_attr_7,
   ineff_ctrl_attr_8,
   ineff_ctrl_attr_9,
   ineff_ctrl_attr_10,
   ineff_ctrl_attr_11,
   ineff_ctrl_attr_12,
   ineff_ctrl_attr_13,
   ineff_ctrl_attr_14,
   ineff_ctrl_attr_15,
   ineff_ctrl_attr_16,
   ineff_ctrl_attr_17,
   ineff_ctrl_attr_18,
   ineff_ctrl_attr_19,
   ineff_ctrl_attr_20,
   ineff_ctrl_attr_21,
   ineff_ctrl_attr_22,
   ineff_ctrl_attr_23,
   ineff_ctrl_attr_24,
   ineff_ctrl_attr_25,
   ineff_ctrl_attr_26,
   ineff_ctrl_attr_27,
   ineff_ctrl_attr_28,
   ineff_ctrl_attr_29,
   ineff_ctrl_attr_30,
acc_assert_flag_1 ,
acc_assert_flag_2 ,
acc_assert_flag_3 ,
acc_assert_flag_4 ,
acc_assert_flag_5 ,
acc_assert_flag_6 ,
acc_assert_flag_7 ,
acc_assert_flag_8 ,
acc_assert_flag_9 ,
acc_assert_flag_10,
acc_assert_flag_11 ,
acc_assert_flag_12 ,
acc_assert_flag_13 ,
acc_assert_flag_14 ,
acc_assert_flag_15 ,
acc_assert_flag_16 ,
acc_assert_flag_17 ,
acc_assert_flag_18 ,
acc_assert_flag_19 ,
acc_assert_flag_20,
acc_assert_flag_21 ,
acc_assert_flag_22 ,
acc_assert_flag_23 ,
acc_assert_flag_24 ,
acc_assert_flag_25 ,
acc_assert_flag_26 ,
acc_assert_flag_27 ,
acc_assert_flag_28 ,
acc_assert_flag_29 ,
acc_assert_flag_30

from
 amw_fin_cert_ctrl_sum
where
 fin_certification_id = P_CERTIFICATION_ID and
 ctrl_attribute_type = par_type and
 ROWNUM <2;

cursor assertion_of_the_ctrl
is
select
 distinct
 comp.ASSERTION_CODE
from
  amw.amw_fin_item_acc_ctrl ctrl,
    amw_control_assertions comp
where
 ctrl.FIN_CERTIFICATION_ID=  P_CERTIFICATION_ID
 and
 ctrl.OBJECT_TYPE = 'FINANCIAL ITEM' and
 ctrl.FINANCIAL_ITEM_ID=  P_FINANCIAL_ITEM_ID
 and
 ctrl.CONTROL_REV_ID =comp.CONTROL_REV_ID and
 ctrl.ORGANIZATION_ID = P_ORG_ID
 and
 ctrl.CONTROL_ID =  P_CONTROL_ID ;

-- =================================  Get Account Assertion COdes FOR A FINANCIAL ITEM ===============================
cursor ACC_ASSERT_FOR_FIN_ITEM
 is
select DISTINCT
ASSERTION_CODE
from
amw_account_assertions
where
NATURAL_ACCOUNT_ID IN
(select DISTINCT NATURAL_ACCOUNT_ID from amw_fin_cert_scope where fin_certification_id = P_CERTIFICATION_ID and
financial_item_id = P_FINANCIAL_ITEM_ID );



-- *****************************************************************************************************



 g_user_id              NUMBER        := fnd_global.user_id;
 g_login_id             NUMBER        := fnd_global.conc_login_id;
 m_object_version_number NUMBER;
 ctr integer :=0;
 max_num_of_codes integer :=0;
  m_ctrl_attribute_type VARCHAR2(30) :='CTRL_ASSERTIONS';
 m_OBJECT_TYPE VARCHAR2(50) := 'FINANCIAL ITEM';


 m_component_code component_code_array;
 m_ineff_control  ineff_control_array ;
 m_acc_assert_flag component_code_array;
 m_add_to_eval_ctrls  total_control_array ;

 add_or_deduct_value number :=0;

 begin

 -- ************ Since the Table has 30 Fileds only initialize 30 Positios in the Array**************--
 ctr :=  1;

 loop
   EXIT  WHEN ctr > 30;

    m_component_code(ctr) := null;
    m_acc_assert_flag(ctr) := 'N';
    m_ineff_control(ctr) := 0;
    m_add_to_eval_ctrls(ctr) := 0;

    ctr := ctr + 1;

 end loop; --end of initialization

 -- ************ get All Control Components Codes and Load it in an Array for later use **************--
  m_ctrl_attribute_type :='CTRL_ASSERTIONS';

 --- P_CHANGE_FLAG = 'F' means the Opinion is changed from Ineffective to Efective
 --- P_CHANGE_FLAG = 'B' means the Opinion is changed from Efective to Ineffective

  if P_CHANGE_FLAG = 'B' then
    add_or_deduct_value := 1;
 elsif (P_CHANGE_FLAG = 'F' and P_NEW_FLAG <> 'Y') then
    add_or_deduct_value := -1;
 elsif P_CHANGE_FLAG = 'N' then
  return;
 end if;

 ctr := 0;
 for assertion_rec  in existing_code(m_ctrl_attribute_type)
 loop
    exit when existing_code%notfound;

       m_component_code(1) :=  assertion_rec .ctrl_attr_code_1;
   m_component_code(2) :=  assertion_rec .ctrl_attr_code_2;
   m_component_code(3) :=  assertion_rec .ctrl_attr_code_3;
   m_component_code(4) :=   assertion_rec .ctrl_attr_code_4;
   m_component_code(5) :=assertion_rec .ctrl_attr_code_5;
   m_component_code(6) :=assertion_rec .ctrl_attr_code_6;
   m_component_code(7) :=assertion_rec .ctrl_attr_code_7;
   m_component_code(8) :=assertion_rec .ctrl_attr_code_8;
   m_component_code(9) :=assertion_rec .ctrl_attr_code_9;
   m_component_code(10) :=assertion_rec .ctrl_attr_code_10;
   m_component_code(11) :=assertion_rec .ctrl_attr_code_11;
   m_component_code(12) :=assertion_rec .ctrl_attr_code_12;
   m_component_code(13) :=assertion_rec .ctrl_attr_code_13;
   m_component_code(14) :=assertion_rec .ctrl_attr_code_14;
   m_component_code(15) :=assertion_rec .ctrl_attr_code_15;
   m_component_code(16) :=assertion_rec .ctrl_attr_code_16;
   m_component_code(17) :=assertion_rec .ctrl_attr_code_17;
   m_component_code(18) :=assertion_rec .ctrl_attr_code_18;
   m_component_code(19) :=assertion_rec .ctrl_attr_code_19;
   m_component_code(20) :=assertion_rec .ctrl_attr_code_20;
   m_component_code(21) :=assertion_rec .ctrl_attr_code_21;
   m_component_code(22) :=assertion_rec .ctrl_attr_code_22;
   m_component_code(23) :=assertion_rec .ctrl_attr_code_23;
   m_component_code(24) :=assertion_rec .ctrl_attr_code_24;
   m_component_code(25) :=assertion_rec .ctrl_attr_code_25;
   m_component_code(26) :=assertion_rec .ctrl_attr_code_26;
   m_component_code(27) :=assertion_rec .ctrl_attr_code_27;
   m_component_code(28) :=assertion_rec .ctrl_attr_code_28;
   m_component_code(29) :=assertion_rec .ctrl_attr_code_29;
   m_component_code(30) :=assertion_rec .ctrl_attr_code_30;


   m_acc_assert_flag(1) :=  assertion_rec .acc_assert_flag_1;
   m_acc_assert_flag(2) :=  assertion_rec .acc_assert_flag_2;
   m_acc_assert_flag(3) :=  assertion_rec .acc_assert_flag_3;
   m_acc_assert_flag(4) :=   assertion_rec .acc_assert_flag_4;
   m_acc_assert_flag(5) :=assertion_rec .acc_assert_flag_5;
   m_acc_assert_flag(6) :=assertion_rec .acc_assert_flag_6;
   m_acc_assert_flag(7) :=assertion_rec .acc_assert_flag_7;
   m_acc_assert_flag(8) :=assertion_rec .acc_assert_flag_8;
   m_acc_assert_flag(9) :=assertion_rec .acc_assert_flag_9;
   m_acc_assert_flag(10) :=assertion_rec .acc_assert_flag_10;
   m_acc_assert_flag(11) :=assertion_rec .acc_assert_flag_11;
   m_acc_assert_flag(12) :=assertion_rec .acc_assert_flag_12;
   m_acc_assert_flag(13) :=assertion_rec .acc_assert_flag_13;
   m_acc_assert_flag(14) :=assertion_rec .acc_assert_flag_14;
   m_acc_assert_flag(15) :=assertion_rec .acc_assert_flag_15;
   m_acc_assert_flag(16) :=assertion_rec .acc_assert_flag_16;
   m_acc_assert_flag(17) :=assertion_rec .acc_assert_flag_17;
   m_acc_assert_flag(18) :=assertion_rec .acc_assert_flag_18;
   m_acc_assert_flag(19) :=assertion_rec .acc_assert_flag_19;
   m_acc_assert_flag(20) :=assertion_rec .acc_assert_flag_20;
   m_acc_assert_flag(21) :=assertion_rec .acc_assert_flag_21;
   m_acc_assert_flag(22) :=assertion_rec .acc_assert_flag_22;
   m_acc_assert_flag(23) :=assertion_rec .acc_assert_flag_23;
   m_acc_assert_flag(24) :=assertion_rec .acc_assert_flag_24;
   m_acc_assert_flag(25) :=assertion_rec .acc_assert_flag_25;
   m_acc_assert_flag(26) :=assertion_rec .acc_assert_flag_26;
   m_acc_assert_flag(27) :=assertion_rec .acc_assert_flag_27;
   m_acc_assert_flag(28) :=assertion_rec .acc_assert_flag_28;
   m_acc_assert_flag(29) :=assertion_rec .acc_assert_flag_29;
   m_acc_assert_flag(30) :=assertion_rec .acc_assert_flag_30;

   m_ineff_control(1) :=  assertion_rec.ineff_ctrl_attr_1;
   m_ineff_control(2) :=  assertion_rec.ineff_ctrl_attr_2;
   m_ineff_control(3) :=  assertion_rec.ineff_ctrl_attr_3;
   m_ineff_control(4) :=   assertion_rec.ineff_ctrl_attr_4;
   m_ineff_control(5) :=assertion_rec.ineff_ctrl_attr_5;
   m_ineff_control(6) :=assertion_rec.ineff_ctrl_attr_6;
   m_ineff_control(7) :=assertion_rec.ineff_ctrl_attr_7;
   m_ineff_control(8) :=assertion_rec.ineff_ctrl_attr_8;
   m_ineff_control(9) :=assertion_rec.ineff_ctrl_attr_9;
   m_ineff_control(10) :=assertion_rec.ineff_ctrl_attr_10;
   m_ineff_control(11) :=assertion_rec.ineff_ctrl_attr_11;
   m_ineff_control(12) :=assertion_rec.ineff_ctrl_attr_12;
   m_ineff_control(13) :=assertion_rec.ineff_ctrl_attr_13;
   m_ineff_control(14) :=assertion_rec.ineff_ctrl_attr_14;
   m_ineff_control(15) :=assertion_rec.ineff_ctrl_attr_15;
   m_ineff_control(16) :=assertion_rec.ineff_ctrl_attr_16;
   m_ineff_control(17) :=assertion_rec.ineff_ctrl_attr_17;
   m_ineff_control(18) :=assertion_rec.ineff_ctrl_attr_18;
   m_ineff_control(19) :=assertion_rec.ineff_ctrl_attr_19;
   m_ineff_control(20) :=assertion_rec.ineff_ctrl_attr_20;
   m_ineff_control(21) :=assertion_rec.ineff_ctrl_attr_21;
   m_ineff_control(22) :=assertion_rec.ineff_ctrl_attr_22;
   m_ineff_control(23) :=assertion_rec.ineff_ctrl_attr_23;
   m_ineff_control(24) :=assertion_rec.ineff_ctrl_attr_24;
   m_ineff_control(25) :=assertion_rec.ineff_ctrl_attr_25;
   m_ineff_control(26) :=assertion_rec.ineff_ctrl_attr_26;
   m_ineff_control(27) :=assertion_rec.ineff_ctrl_attr_27;
   m_ineff_control(28) :=assertion_rec.ineff_ctrl_attr_28;
   m_ineff_control(29) :=assertion_rec.ineff_ctrl_attr_29;
   m_ineff_control(30) :=assertion_rec.ineff_ctrl_attr_30;

 end loop; --end of Control Assertion Rec loop


-- **************** Check the REVISION of the Control came with the event has what COSO Codes *******************
-- and in which filed (out of 1 to 30) it is falling and the init varaible with the -1 or +1 corrsponding to that
--****************************************************************************************************************
 ctr := 0;
 for ctrl_assertion_codes in assertion_of_the_ctrl
 loop
    exit when assertion_of_the_ctrl%notfound;
    ctr := 1;
    while ctr <=  30
    loop
      if m_component_code(ctr) = ctrl_assertion_codes.ASSERTION_CODE then

       /********** insanity check for the numbers ******
  	********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b  ****/
        IF( (NVL(m_ineff_control(ctr),0) + add_or_deduct_value) < 0 or   (NVL(m_ineff_control(ctr),0) + add_or_deduct_value) > m_add_to_eval_ctrls(ctr))
  	THEN
  	AMW_FINSTMT_CERT_BES_PKG.G_REFRESH_FLAG := 'Y';
  	IF AMW_FINSTMT_CERT_BES_PKG.m_certification_list.exists(P_CERTIFICATION_ID) THEN
  	  EXIT;
  	ELSE
  	AMW_FINSTMT_CERT_BES_PKG.m_certification_list(AMW_FINSTMT_CERT_BES_PKG.m_certification_list.COUNT+1) := P_CERTIFICATION_ID;
  	EXIT;
  	END IF;
        END IF;

       m_ineff_control(ctr) :=  NVL(m_ineff_control(ctr),0) + add_or_deduct_value;


         if  P_NEW_FLAG = 'Y' then
            m_add_to_eval_ctrls(ctr) := 1;

         end if;

      end if;
       ctr := ctr + 1;

    end loop;


 end loop; --end of ctrl_assertion_codes in assertion_of_the_ctrl loop


   --************ The Image Display Flag setting should be done last as it need ineffective control array *********--
       for acc_assertions in ACC_ASSERT_FOR_FIN_ITEM
       loop
          exit when ACC_ASSERT_FOR_FIN_ITEM%notfound;

          ctr := 1;
          while ctr <=  30
          loop

            -- NOT ONLY CHECK WHETHER THE ACCOUNT IS MAPPED TO THE ASSERTION CODE BUT ALSO
            -- THERE IS AT LEASE ONE CONROL (WHICH MAPPED TO THE SAME ASSERTION) AND ACCOUNT (THORUGH)
            -- IT RELATION TO PROCESS IS INEFFECTIVE

             if  (m_component_code(ctr) =  acc_assertions.ASSERTION_CODE
                 and m_ineff_control(ctr) > 0 ) then
                 m_acc_assert_flag(ctr) := 'Y';
                exit;
             end if;
             ctr := ctr +1;
          end loop;
       end loop; --end of acc_assertions in ACC_ASSERT_CODES




    amw_fin_coso_views_pvt.UPDATE_FINITEM_ASSERT_ROW(
     x_fin_certification_id       	=> 	P_CERTIFICATION_ID	,
     x_financial_statement_id    	=> 	P_FINANCIAL_STATEMENT_ID 	,
     x_financial_item_id         	=> 	P_FINANCIAL_ITEM_ID 	,
     x_account_group_id          	=> 	null	,
     x_natural_account_id        	=> 	null,
     x_object_type               	=> 	m_OBJECT_TYPE 	,
     x_ctrl_attribute_type       	=> 	m_ctrl_attribute_type       	,
     x_ineff_ctrl_attr_1         	=> 	m_ineff_control(1)	,
     x_ineff_ctrl_attr_2         	=> 	m_ineff_control(2)	,
     x_ineff_ctrl_attr_3         	=> 	m_ineff_control(3)	,
     x_ineff_ctrl_attr_4         	=> 	m_ineff_control(4)	,
     x_ineff_ctrl_attr_5         	=> 	m_ineff_control(5)	,
     x_ineff_ctrl_attr_6         	=> 	m_ineff_control(6)	,
     x_ineff_ctrl_attr_7         	=> 	m_ineff_control(7)	,
     x_ineff_ctrl_attr_8         	=> 	m_ineff_control(8)	,
     x_ineff_ctrl_attr_9         	=> 	m_ineff_control(9)	,
     x_ineff_ctrl_attr_10        	=> 	m_ineff_control(10)	,
     x_ineff_ctrl_attr_11        	=> 	m_ineff_control(11)	,
     x_ineff_ctrl_attr_12        	=> 	m_ineff_control(12)	,
     x_ineff_ctrl_attr_13        	=> 	m_ineff_control(13)	,
     x_ineff_ctrl_attr_14        	=> 	m_ineff_control(14)	,
     x_ineff_ctrl_attr_15        	=> 	m_ineff_control(15)	,
     x_ineff_ctrl_attr_16        	=> 	m_ineff_control(16)	,
     x_ineff_ctrl_attr_17        	=> 	m_ineff_control(17)	,
     x_ineff_ctrl_attr_18        	=> 	m_ineff_control(18)	,
     x_ineff_ctrl_attr_19        	=> 	m_ineff_control(19)	,
     x_ineff_ctrl_attr_20        	=> 	m_ineff_control(20)	,
     x_ineff_ctrl_attr_21        	=> 	m_ineff_control(21)	,
     x_ineff_ctrl_attr_22        	=> 	m_ineff_control(22)	,
     x_ineff_ctrl_attr_23        	=> 	m_ineff_control(23)	,
     x_ineff_ctrl_attr_24         	=> 	m_ineff_control(24)	,
     x_ineff_ctrl_attr_25        	=> 	m_ineff_control(25)	,
     x_ineff_ctrl_attr_26        	=> 	m_ineff_control(26)	,
     x_ineff_ctrl_attr_27        	=> 	m_ineff_control(27)	,
     x_ineff_ctrl_attr_28        	=> 	m_ineff_control(28)	,
     x_ineff_ctrl_attr_29        	=> 	m_ineff_control(29)	,
     x_ineff_ctrl_attr_30        	=> 	m_ineff_control(30)	,
     x_last_updated_by           	=> 	g_user_id	,
     x_last_update_date          	=> 	SYSDATE	,
     x_last_update_login         	=> 	g_login_id,
     x_eval_ctrl_attr_1         	=> 	m_add_to_eval_ctrls(1),
     x_eval_ctrl_attr_2         	=> 	m_add_to_eval_ctrls(2),
     x_eval_ctrl_attr_3         	=> 	m_add_to_eval_ctrls(3),
     x_eval_ctrl_attr_4         	=> 	m_add_to_eval_ctrls(4),
     x_eval_ctrl_attr_5         	=> 	m_add_to_eval_ctrls(5),
     x_eval_ctrl_attr_6         	=> 	m_add_to_eval_ctrls(6),
     x_eval_ctrl_attr_7         	=> 	m_add_to_eval_ctrls(7),
     x_eval_ctrl_attr_8         	=> 	m_add_to_eval_ctrls(8),
     x_eval_ctrl_attr_9         	=> 	m_add_to_eval_ctrls(9),
     x_eval_ctrl_attr_10        	=> 	m_add_to_eval_ctrls(10),
     x_eval_ctrl_attr_11         	=> 	m_add_to_eval_ctrls(11),
     x_eval_ctrl_attr_12         	=> 	m_add_to_eval_ctrls(12),
     x_eval_ctrl_attr_13         	=> 	m_add_to_eval_ctrls(13),
     x_eval_ctrl_attr_14         	=> 	m_add_to_eval_ctrls(14),
     x_eval_ctrl_attr_15         	=> 	m_add_to_eval_ctrls(15),
     x_eval_ctrl_attr_16         	=> 	m_add_to_eval_ctrls(16),
     x_eval_ctrl_attr_17         	=> 	m_add_to_eval_ctrls(17),
     x_eval_ctrl_attr_18         	=> 	m_add_to_eval_ctrls(18),
     x_eval_ctrl_attr_19         	=> 	m_add_to_eval_ctrls(19),
     x_eval_ctrl_attr_20        	=> 	m_add_to_eval_ctrls(20),
     x_eval_ctrl_attr_21         	=> 	m_add_to_eval_ctrls(21),
     x_eval_ctrl_attr_22         	=> 	m_add_to_eval_ctrls(22),
     x_eval_ctrl_attr_23         	=> 	m_add_to_eval_ctrls(23),
     x_eval_ctrl_attr_24         	=> 	m_add_to_eval_ctrls(24),
     x_eval_ctrl_attr_25         	=> 	m_add_to_eval_ctrls(25),
     x_eval_ctrl_attr_26         	=> 	m_add_to_eval_ctrls(26),
     x_eval_ctrl_attr_27         	=> 	m_add_to_eval_ctrls(27),
     x_eval_ctrl_attr_28         	=> 	m_add_to_eval_ctrls(28),
     x_eval_ctrl_attr_29         	=> 	m_add_to_eval_ctrls(29),
     x_eval_ctrl_attr_30        	=> 	m_add_to_eval_ctrls(30),
     x_acc_assert_flag1         	=> 	m_acc_assert_flag(1),
     x_acc_assert_flag2         	=> 	m_acc_assert_flag(2),
     x_acc_assert_flag3         	=> 	m_acc_assert_flag(3),
     x_acc_assert_flag4         	=> 	m_acc_assert_flag(4),
     x_acc_assert_flag5         	=> 	m_acc_assert_flag(5),
     x_acc_assert_flag6         	=> 	m_acc_assert_flag(6),
     x_acc_assert_flag7         	=> 	m_acc_assert_flag(7),
     x_acc_assert_flag8         	=> 	m_acc_assert_flag(8),
     x_acc_assert_flag9         	=> 	m_acc_assert_flag(9),
     x_acc_assert_flag10        	=> 	m_acc_assert_flag(10),
     x_acc_assert_flag11         	=> 	m_acc_assert_flag(11),
     x_acc_assert_flag12         	=> 	m_acc_assert_flag(12),
     x_acc_assert_flag13         	=> 	m_acc_assert_flag(13),
     x_acc_assert_flag14         	=> 	m_acc_assert_flag(14),
     x_acc_assert_flag15         	=> 	m_acc_assert_flag(15),
     x_acc_assert_flag16         	=> 	m_acc_assert_flag(16),
     x_acc_assert_flag17         	=> 	m_acc_assert_flag(17),
     x_acc_assert_flag18         	=> 	m_acc_assert_flag(18),
     x_acc_assert_flag19         	=> 	m_acc_assert_flag(19),
     x_acc_assert_flag20        	=> 	m_acc_assert_flag(20),
     x_acc_assert_flag21         	=> 	m_acc_assert_flag(21),
     x_acc_assert_flag22         	=> 	m_acc_assert_flag(22),
     x_acc_assert_flag23         	=> 	m_acc_assert_flag(23),
     x_acc_assert_flag24         	=> 	m_acc_assert_flag(24),
     x_acc_assert_flag25         	=> 	m_acc_assert_flag(25),
     x_acc_assert_flag26         	=> 	m_acc_assert_flag(26),
     x_acc_assert_flag27         	=> 	m_acc_assert_flag(27),
     x_acc_assert_flag28         	=> 	m_acc_assert_flag(28),
     x_acc_assert_flag29         	=> 	m_acc_assert_flag(29),
     x_acc_assert_flag30        	=> 	m_acc_assert_flag(30)
 );

  EXCEPTION
     WHEN NO_DATA_FOUND
	     THEN
            fnd_file.put_line (fnd_file.LOG, SUBSTR ('No data found in Update_item_ctrl_components'
                || SUBSTR (SQLERRM, 1, 100), 1, 200));

     WHEN OTHERS
         THEN
            fnd_file.put_line (fnd_file.LOG, SUBSTR ('Unexpected Error in Update_item_ctrl_components'
                || SUBSTR (SQLERRM, 1, 100), 1, 200));


  end;
end ; --Update_item_ctrl_Assertions

------------------------------ fOR THE ACCOUNTS ------------------------------------------------------------------------------


PROCEDURE Update_acc_ctrl_Assertions
(P_CERTIFICATION_ID number ,
                  P_ACCOUNT_GROUP_ID  number ,
                  P_ACCOUNT_ID        number ,
                  P_CONTROL_ID        number ,
                  P_ORG_ID        number ,
                  P_CHANGE_FLAG VARCHAR2,
                  P_NEW_FLAG VARCHAR2) is



begin
declare
cursor existing_code(par_type varchar2)
is
 select
   ctrl_attr_code_1,
   ctrl_attr_code_2,
   ctrl_attr_code_3,
   ctrl_attr_code_4,
   ctrl_attr_code_5,
   ctrl_attr_code_6,
   ctrl_attr_code_7,
   ctrl_attr_code_8,
   ctrl_attr_code_9,
   ctrl_attr_code_10,
   ctrl_attr_code_11,
   ctrl_attr_code_12,
   ctrl_attr_code_13,
   ctrl_attr_code_14,
   ctrl_attr_code_15,
   ctrl_attr_code_16,
   ctrl_attr_code_17,
   ctrl_attr_code_18,
   ctrl_attr_code_19,
   ctrl_attr_code_20,
   ctrl_attr_code_21,
   ctrl_attr_code_22,
   ctrl_attr_code_23,
   ctrl_attr_code_24,
   ctrl_attr_code_25,
   ctrl_attr_code_26,
   ctrl_attr_code_27,
   ctrl_attr_code_28,
   ctrl_attr_code_29,
   ctrl_attr_code_30,
   ineff_ctrl_attr_1,
   ineff_ctrl_attr_2,
   ineff_ctrl_attr_3,
   ineff_ctrl_attr_4,
   ineff_ctrl_attr_5,
   ineff_ctrl_attr_6,
   ineff_ctrl_attr_7,
   ineff_ctrl_attr_8,
   ineff_ctrl_attr_9,
   ineff_ctrl_attr_10,
   ineff_ctrl_attr_11,
   ineff_ctrl_attr_12,
   ineff_ctrl_attr_13,
   ineff_ctrl_attr_14,
   ineff_ctrl_attr_15,
   ineff_ctrl_attr_16,
   ineff_ctrl_attr_17,
   ineff_ctrl_attr_18,
   ineff_ctrl_attr_19,
   ineff_ctrl_attr_20,
   ineff_ctrl_attr_21,
   ineff_ctrl_attr_22,
   ineff_ctrl_attr_23,
   ineff_ctrl_attr_24,
   ineff_ctrl_attr_25,
   ineff_ctrl_attr_26,
   ineff_ctrl_attr_27,
   ineff_ctrl_attr_28,
   ineff_ctrl_attr_29,
   ineff_ctrl_attr_30,
acc_assert_flag_1 ,
acc_assert_flag_2 ,
acc_assert_flag_3 ,
acc_assert_flag_4 ,
acc_assert_flag_5 ,
acc_assert_flag_6 ,
acc_assert_flag_7 ,
acc_assert_flag_8 ,
acc_assert_flag_9 ,
acc_assert_flag_10,
acc_assert_flag_11 ,
acc_assert_flag_12 ,
acc_assert_flag_13 ,
acc_assert_flag_14 ,
acc_assert_flag_15 ,
acc_assert_flag_16 ,
acc_assert_flag_17 ,
acc_assert_flag_18 ,
acc_assert_flag_19 ,
acc_assert_flag_20,
acc_assert_flag_21 ,
acc_assert_flag_22 ,
acc_assert_flag_23 ,
acc_assert_flag_24 ,
acc_assert_flag_25 ,
acc_assert_flag_26 ,
acc_assert_flag_27 ,
acc_assert_flag_28 ,
acc_assert_flag_29 ,
acc_assert_flag_30
from
 amw_fin_cert_ctrl_sum
where
 fin_certification_id = P_CERTIFICATION_ID and
 ctrl_attribute_type = par_type and
 ROWNUM <2
AND  account_group_id =  P_ACCOUNT_GROUP_ID and
 natural_account_id  =  P_ACCOUNT_ID        and
 object_type	= 'ACCOUNT' ;


----------------------------------------------
cursor assertion_of_the_ctrl
is
  select
 distinct
  comp.ASSERTION_CODE
from
  amw.amw_fin_item_acc_ctrl ctrl,
 amw_control_assertions comp
where
 ctrl.FIN_CERTIFICATION_ID=  P_CERTIFICATION_ID
 and
 ctrl.OBJECT_TYPE = 'ACCOUNT' and
 ctrl.ACCOUNT_GROUP_ID=   P_ACCOUNT_GROUP_ID
 AND
 ctrl.NATURAL_ACCOUNT_ID = P_ACCOUNT_ID
 and
 ctrl.CONTROL_REV_ID =comp.CONTROL_REV_ID and
 ctrl.ORGANIZATION_ID = P_ORG_ID
 and
 ctrl.CONTROL_ID =  P_CONTROL_ID ;

--********************* Get Account Assertion COdes *************************************************--
/*
cursor ACC_ASSERT_CODES
 is
select
ASSERTION_CODE
from
amw_account_assertions
where
NATURAL_ACCOUNT_ID =P_ACCOUNT_ID  ;
*/

cursor ACC_ASSERT_CODES
 is
select
distinct
ASSERTION_CODE
from
amw_account_assertions
where
((NATURAL_ACCOUNT_ID =P_ACCOUNT_ID) or (NATURAL_ACCOUNT_ID in (select CHILD_NATURAL_ACCOUNT_ID from amw_fin_key_acct_flat
where  PARENT_NATURAL_ACCOUNT_ID  =P_ACCOUNT_ID and ACCOUNT_GROUP_ID=P_ACCOUNT_GROUP_ID)));

----------------------------------------------------
 g_user_id              NUMBER        := fnd_global.user_id;
 g_login_id             NUMBER        := fnd_global.conc_login_id;
 m_object_version_number NUMBER;
 ctr integer :=0;
 max_num_of_codes integer :=0;  m_ctrl_attribute_type VARCHAR2(30) :='CTRL_ASSERTIONS';
 m_OBJECT_TYPE VARCHAR2(50) := 'ACCOUNT';

m_assertions_code component_code_array;
 m_component_code component_code_array;
 m_ineff_control  ineff_control_array ;
 m_acc_assert_flag component_code_array;
 m_add_to_eval_ctrls  total_control_array ;

 add_or_deduct_value number :=0;

begin

 -- ************ Since the Table has 30 Fileds only initialize 30 Positios in the Array**************--
 ctr :=  1;

 loop
   EXIT  WHEN ctr > 30;

    m_component_code(ctr) := null;
    m_acc_assert_flag(ctr) := 'N';
    m_ineff_control(ctr) := 0;
    m_add_to_eval_ctrls(ctr) := 0;

    ctr := ctr + 1;

 end loop; --end of initialization

 -- ************ get All Control Components Codes and Load it in an Array for later use **************--
  m_ctrl_attribute_type :='CTRL_ASSERTIONS';

 --- P_CHANGE_FLAG = 'F' means the Opinion is changed from Ineffective to Efective
 --- P_CHANGE_FLAG = 'B' means the Opinion is changed from Efective to Ineffective

  if P_CHANGE_FLAG = 'B' then
    add_or_deduct_value := 1;
 elsif (P_CHANGE_FLAG = 'F' and P_NEW_FLAG <> 'Y') then
    add_or_deduct_value := -1;
 elsif P_CHANGE_FLAG = 'N' then
  return;
 end if;

 ctr := 0;
 for assertion_rec  in existing_code(m_ctrl_attribute_type)
 loop
    exit when existing_code%notfound;

   m_component_code(1) :=  assertion_rec .ctrl_attr_code_1;
   m_component_code(2) :=  assertion_rec .ctrl_attr_code_2;
   m_component_code(3) :=  assertion_rec .ctrl_attr_code_3;
   m_component_code(4) :=   assertion_rec .ctrl_attr_code_4;
   m_component_code(5) :=assertion_rec .ctrl_attr_code_5;
   m_component_code(6) :=assertion_rec .ctrl_attr_code_6;
   m_component_code(7) :=assertion_rec .ctrl_attr_code_7;
   m_component_code(8) :=assertion_rec .ctrl_attr_code_8;
   m_component_code(9) :=assertion_rec .ctrl_attr_code_9;
   m_component_code(10) :=assertion_rec .ctrl_attr_code_10;
   m_component_code(11) :=assertion_rec .ctrl_attr_code_11;
   m_component_code(12) :=assertion_rec .ctrl_attr_code_12;
   m_component_code(13) :=assertion_rec .ctrl_attr_code_13;
   m_component_code(14) :=assertion_rec .ctrl_attr_code_14;
   m_component_code(15) :=assertion_rec .ctrl_attr_code_15;
   m_component_code(16) :=assertion_rec .ctrl_attr_code_16;
   m_component_code(17) :=assertion_rec .ctrl_attr_code_17;
   m_component_code(18) :=assertion_rec .ctrl_attr_code_18;
   m_component_code(19) :=assertion_rec .ctrl_attr_code_19;
   m_component_code(20) :=assertion_rec .ctrl_attr_code_20;
   m_component_code(21) :=assertion_rec .ctrl_attr_code_21;
   m_component_code(22) :=assertion_rec .ctrl_attr_code_22;
   m_component_code(23) :=assertion_rec .ctrl_attr_code_23;
   m_component_code(24) :=assertion_rec .ctrl_attr_code_24;
   m_component_code(25) :=assertion_rec .ctrl_attr_code_25;
   m_component_code(26) :=assertion_rec .ctrl_attr_code_26;
   m_component_code(27) :=assertion_rec .ctrl_attr_code_27;
   m_component_code(28) :=assertion_rec .ctrl_attr_code_28;
   m_component_code(29) :=assertion_rec .ctrl_attr_code_29;
   m_component_code(30) :=assertion_rec .ctrl_attr_code_30;


   m_ineff_control(1) :=  assertion_rec.ineff_ctrl_attr_1;
   m_ineff_control(2) :=  assertion_rec.ineff_ctrl_attr_2;
   m_ineff_control(3) :=  assertion_rec.ineff_ctrl_attr_3;
   m_ineff_control(4) :=   assertion_rec.ineff_ctrl_attr_4;
   m_ineff_control(5) :=assertion_rec.ineff_ctrl_attr_5;
   m_ineff_control(6) :=assertion_rec.ineff_ctrl_attr_6;
   m_ineff_control(7) :=assertion_rec.ineff_ctrl_attr_7;
   m_ineff_control(8) :=assertion_rec.ineff_ctrl_attr_8;
   m_ineff_control(9) :=assertion_rec.ineff_ctrl_attr_9;
   m_ineff_control(10) :=assertion_rec.ineff_ctrl_attr_10;
   m_ineff_control(11) :=assertion_rec.ineff_ctrl_attr_11;
   m_ineff_control(12) :=assertion_rec.ineff_ctrl_attr_12;
   m_ineff_control(13) :=assertion_rec.ineff_ctrl_attr_13;
   m_ineff_control(14) :=assertion_rec.ineff_ctrl_attr_14;
   m_ineff_control(15) :=assertion_rec.ineff_ctrl_attr_15;
   m_ineff_control(16) :=assertion_rec.ineff_ctrl_attr_16;
   m_ineff_control(17) :=assertion_rec.ineff_ctrl_attr_17;
   m_ineff_control(18) :=assertion_rec.ineff_ctrl_attr_18;
   m_ineff_control(19) :=assertion_rec.ineff_ctrl_attr_19;
   m_ineff_control(20) :=assertion_rec.ineff_ctrl_attr_20;
   m_ineff_control(21) :=assertion_rec.ineff_ctrl_attr_21;
   m_ineff_control(22) :=assertion_rec.ineff_ctrl_attr_22;
   m_ineff_control(23) :=assertion_rec.ineff_ctrl_attr_23;
   m_ineff_control(24) :=assertion_rec.ineff_ctrl_attr_24;
   m_ineff_control(25) :=assertion_rec.ineff_ctrl_attr_25;
   m_ineff_control(26) :=assertion_rec.ineff_ctrl_attr_26;
   m_ineff_control(27) :=assertion_rec.ineff_ctrl_attr_27;
   m_ineff_control(28) :=assertion_rec.ineff_ctrl_attr_28;
   m_ineff_control(29) :=assertion_rec.ineff_ctrl_attr_29;
   m_ineff_control(30) :=assertion_rec.ineff_ctrl_attr_30;

   m_acc_assert_flag(1) :=  assertion_rec .acc_assert_flag_1;
   m_acc_assert_flag(2) :=  assertion_rec .acc_assert_flag_2;
   m_acc_assert_flag(3) :=  assertion_rec .acc_assert_flag_3;
   m_acc_assert_flag(4) :=   assertion_rec .acc_assert_flag_4;
   m_acc_assert_flag(5) :=assertion_rec .acc_assert_flag_5;
   m_acc_assert_flag(6) :=assertion_rec .acc_assert_flag_6;
   m_acc_assert_flag(7) :=assertion_rec .acc_assert_flag_7;
   m_acc_assert_flag(8) :=assertion_rec .acc_assert_flag_8;
   m_acc_assert_flag(9) :=assertion_rec .acc_assert_flag_9;
   m_acc_assert_flag(10) :=assertion_rec .acc_assert_flag_10;
   m_acc_assert_flag(11) :=assertion_rec .acc_assert_flag_11;
   m_acc_assert_flag(12) :=assertion_rec .acc_assert_flag_12;
   m_acc_assert_flag(13) :=assertion_rec .acc_assert_flag_13;
   m_acc_assert_flag(14) :=assertion_rec .acc_assert_flag_14;
   m_acc_assert_flag(15) :=assertion_rec .acc_assert_flag_15;
   m_acc_assert_flag(16) :=assertion_rec .acc_assert_flag_16;
   m_acc_assert_flag(17) :=assertion_rec .acc_assert_flag_17;
   m_acc_assert_flag(18) :=assertion_rec .acc_assert_flag_18;
   m_acc_assert_flag(19) :=assertion_rec .acc_assert_flag_19;
   m_acc_assert_flag(20) :=assertion_rec .acc_assert_flag_20;
   m_acc_assert_flag(21) :=assertion_rec .acc_assert_flag_21;
   m_acc_assert_flag(22) :=assertion_rec .acc_assert_flag_22;
   m_acc_assert_flag(23) :=assertion_rec .acc_assert_flag_23;
   m_acc_assert_flag(24) :=assertion_rec .acc_assert_flag_24;
   m_acc_assert_flag(25) :=assertion_rec .acc_assert_flag_25;
   m_acc_assert_flag(26) :=assertion_rec .acc_assert_flag_26;
   m_acc_assert_flag(27) :=assertion_rec .acc_assert_flag_27;
   m_acc_assert_flag(28) :=assertion_rec .acc_assert_flag_28;
   m_acc_assert_flag(29) :=assertion_rec .acc_assert_flag_29;
   m_acc_assert_flag(30) :=assertion_rec .acc_assert_flag_30;



 end loop; --end of Control Assertion Rec loop

 -- **************** Check the REVISION of the Control came with the event has what COSO Codes *******************
-- and in which filed (out of 1 to 30) it is falling and the init varaible with the -1 or +1 corrsponding to that
--****************************************************************************************************************
 ctr := 0;
 for ctrl_assertion_codes in assertion_of_the_ctrl
 loop
    exit when assertion_of_the_ctrl%notfound;
    ctr := 1;
    while ctr <=  30
    loop
      if m_component_code(ctr) = ctrl_assertion_codes.ASSERTION_CODE then

          /********** insanity check for the numbers ******
  	********* If the display format is a/b/c, then a >= 0 and b>= a and c>= b  ****/
        IF( (NVL(m_ineff_control(ctr),0) + add_or_deduct_value) < 0 or   (NVL(m_ineff_control(ctr),0) + add_or_deduct_value) > m_add_to_eval_ctrls(ctr))
  	THEN
  	AMW_FINSTMT_CERT_BES_PKG.G_REFRESH_FLAG := 'Y';
  	IF AMW_FINSTMT_CERT_BES_PKG.m_certification_list.exists(P_CERTIFICATION_ID) THEN
  	  EXIT;
  	ELSE
  	AMW_FINSTMT_CERT_BES_PKG.m_certification_list(AMW_FINSTMT_CERT_BES_PKG.m_certification_list.COUNT+1) := P_CERTIFICATION_ID;
  	EXIT;
  	END IF;
        END IF;

         m_ineff_control(ctr) :=  NVL(m_ineff_control(ctr),0) + add_or_deduct_value;

         if  P_NEW_FLAG = 'Y' then
            m_add_to_eval_ctrls(ctr) := 1;

         end if;

      end if;
       ctr := ctr + 1;

    end loop;


 end loop; --end of ctrl_assertion_codes in assertion_of_the_ctrl loop

--************ The Image Display Flag setting should be done last as it need ineffective control array *********--

       for acc_assertions in ACC_ASSERT_CODES
       loop
          exit when ACC_ASSERT_CODES%notfound;

          ctr := 1;
          while ctr <=  30
          loop

            -- NOT ONLY CHECK WHETHER THE ACCOUNT IS MAPPED TO THE ASSERTION CODE BUT ALSO
            -- THERE IS AT LEASE ONE CONROL (WHICH MAPPED TO THE SAME ASSERTION) AND ACCOUNT (THORUGH)
            -- IT RELATION TO PROCESS IS INEFFECTIVE

             if  (m_component_code(ctr) =  acc_assertions.ASSERTION_CODE
                 and m_ineff_control(ctr) > 0 ) then
                 m_acc_assert_flag(ctr) := 'Y';
                exit;
             end if;
             ctr := ctr +1;
          end loop;
       end loop; --end of acc_assertions in ACC_ASSERT_CODES


    amw_fin_coso_views_pvt.UPDATE_FIN_ACC_ASSERT_ROW(
     x_fin_certification_id       	=> 	P_CERTIFICATION_ID	,
     x_financial_statement_id    	=> 	NULL 	,
     x_financial_item_id         	=> 	NULL	,
     x_account_group_id          	=> 	P_ACCOUNT_GROUP_ID,
     x_natural_account_id        	=> 	P_ACCOUNT_ID,
     x_object_type               	=> 	m_OBJECT_TYPE 	,
     x_ctrl_attribute_type       	=> 	m_ctrl_attribute_type       	,
     x_ineff_ctrl_attr_1         	=> 	m_ineff_control(1)	,
     x_ineff_ctrl_attr_2         	=> 	m_ineff_control(2)	,
     x_ineff_ctrl_attr_3         	=> 	m_ineff_control(3)	,
     x_ineff_ctrl_attr_4         	=> 	m_ineff_control(4)	,
     x_ineff_ctrl_attr_5         	=> 	m_ineff_control(5)	,
     x_ineff_ctrl_attr_6         	=> 	m_ineff_control(6)	,
     x_ineff_ctrl_attr_7         	=> 	m_ineff_control(7)	,
     x_ineff_ctrl_attr_8         	=> 	m_ineff_control(8)	,
     x_ineff_ctrl_attr_9         	=> 	m_ineff_control(9)	,
     x_ineff_ctrl_attr_10        	=> 	m_ineff_control(10)	,
     x_ineff_ctrl_attr_11        	=> 	m_ineff_control(11)	,
     x_ineff_ctrl_attr_12        	=> 	m_ineff_control(12)	,
     x_ineff_ctrl_attr_13        	=> 	m_ineff_control(13)	,
     x_ineff_ctrl_attr_14        	=> 	m_ineff_control(14)	,
     x_ineff_ctrl_attr_15        	=> 	m_ineff_control(15)	,
     x_ineff_ctrl_attr_16        	=> 	m_ineff_control(16)	,
     x_ineff_ctrl_attr_17        	=> 	m_ineff_control(17)	,
     x_ineff_ctrl_attr_18        	=> 	m_ineff_control(18)	,
     x_ineff_ctrl_attr_19        	=> 	m_ineff_control(19)	,
     x_ineff_ctrl_attr_20        	=> 	m_ineff_control(20)	,
     x_ineff_ctrl_attr_21        	=> 	m_ineff_control(21)	,
     x_ineff_ctrl_attr_22        	=> 	m_ineff_control(22)	,
     x_ineff_ctrl_attr_23        	=> 	m_ineff_control(23)	,
     x_ineff_ctrl_attr_24         	=> 	m_ineff_control(24)	,
     x_ineff_ctrl_attr_25        	=> 	m_ineff_control(25)	,
     x_ineff_ctrl_attr_26        	=> 	m_ineff_control(26)	,
     x_ineff_ctrl_attr_27        	=> 	m_ineff_control(27)	,
     x_ineff_ctrl_attr_28        	=> 	m_ineff_control(28)	,
     x_ineff_ctrl_attr_29        	=> 	m_ineff_control(29)	,
     x_ineff_ctrl_attr_30        	=> 	m_ineff_control(30)	,
     x_last_updated_by           	=> 	g_user_id	,
     x_last_update_date          	=> 	SYSDATE	,
     x_last_update_login         	=> 	g_login_id,
     x_eval_ctrl_attr_1         	=> 	m_add_to_eval_ctrls(1),
     x_eval_ctrl_attr_2         	=> 	m_add_to_eval_ctrls(2),
     x_eval_ctrl_attr_3         	=> 	m_add_to_eval_ctrls(3),
     x_eval_ctrl_attr_4         	=> 	m_add_to_eval_ctrls(4),
     x_eval_ctrl_attr_5         	=> 	m_add_to_eval_ctrls(5),
     x_eval_ctrl_attr_6         	=> 	m_add_to_eval_ctrls(6),
     x_eval_ctrl_attr_7         	=> 	m_add_to_eval_ctrls(7),
     x_eval_ctrl_attr_8         	=> 	m_add_to_eval_ctrls(8),
     x_eval_ctrl_attr_9         	=> 	m_add_to_eval_ctrls(9),
     x_eval_ctrl_attr_10        	=> 	m_add_to_eval_ctrls(10),
     x_eval_ctrl_attr_11         	=> 	m_add_to_eval_ctrls(11),
     x_eval_ctrl_attr_12         	=> 	m_add_to_eval_ctrls(12),
     x_eval_ctrl_attr_13         	=> 	m_add_to_eval_ctrls(13),
     x_eval_ctrl_attr_14         	=> 	m_add_to_eval_ctrls(14),
     x_eval_ctrl_attr_15         	=> 	m_add_to_eval_ctrls(15),
     x_eval_ctrl_attr_16         	=> 	m_add_to_eval_ctrls(16),
     x_eval_ctrl_attr_17         	=> 	m_add_to_eval_ctrls(17),
     x_eval_ctrl_attr_18         	=> 	m_add_to_eval_ctrls(18),
     x_eval_ctrl_attr_19         	=> 	m_add_to_eval_ctrls(19),
     x_eval_ctrl_attr_20        	=> 	m_add_to_eval_ctrls(20),
     x_eval_ctrl_attr_21         	=> 	m_add_to_eval_ctrls(21),
     x_eval_ctrl_attr_22         	=> 	m_add_to_eval_ctrls(22),
     x_eval_ctrl_attr_23         	=> 	m_add_to_eval_ctrls(23),
     x_eval_ctrl_attr_24         	=> 	m_add_to_eval_ctrls(24),
     x_eval_ctrl_attr_25         	=> 	m_add_to_eval_ctrls(25),
     x_eval_ctrl_attr_26         	=> 	m_add_to_eval_ctrls(26),
     x_eval_ctrl_attr_27         	=> 	m_add_to_eval_ctrls(27),
     x_eval_ctrl_attr_28         	=> 	m_add_to_eval_ctrls(28),
     x_eval_ctrl_attr_29         	=> 	m_add_to_eval_ctrls(29),
     x_eval_ctrl_attr_30        	=> 	m_add_to_eval_ctrls(30),
     x_acc_assert_flag1         	=> 	m_acc_assert_flag(1),
     x_acc_assert_flag2         	=> 	m_acc_assert_flag(2),
     x_acc_assert_flag3         	=> 	m_acc_assert_flag(3),
     x_acc_assert_flag4         	=> 	m_acc_assert_flag(4),
     x_acc_assert_flag5         	=> 	m_acc_assert_flag(5),
     x_acc_assert_flag6         	=> 	m_acc_assert_flag(6),
     x_acc_assert_flag7         	=> 	m_acc_assert_flag(7),
     x_acc_assert_flag8         	=> 	m_acc_assert_flag(8),
     x_acc_assert_flag9         	=> 	m_acc_assert_flag(9),
     x_acc_assert_flag10        	=> 	m_acc_assert_flag(10),
     x_acc_assert_flag11         	=> 	m_acc_assert_flag(11),
     x_acc_assert_flag12         	=> 	m_acc_assert_flag(12),
     x_acc_assert_flag13         	=> 	m_acc_assert_flag(13),
     x_acc_assert_flag14         	=> 	m_acc_assert_flag(14),
     x_acc_assert_flag15         	=> 	m_acc_assert_flag(15),
     x_acc_assert_flag16         	=> 	m_acc_assert_flag(16),
     x_acc_assert_flag17         	=> 	m_acc_assert_flag(17),
     x_acc_assert_flag18         	=> 	m_acc_assert_flag(18),
     x_acc_assert_flag19         	=> 	m_acc_assert_flag(19),
     x_acc_assert_flag20        	=> 	m_acc_assert_flag(20),
     x_acc_assert_flag21         	=> 	m_acc_assert_flag(21),
     x_acc_assert_flag22         	=> 	m_acc_assert_flag(22),
     x_acc_assert_flag23         	=> 	m_acc_assert_flag(23),
     x_acc_assert_flag24         	=> 	m_acc_assert_flag(24),
     x_acc_assert_flag25         	=> 	m_acc_assert_flag(25),
     x_acc_assert_flag26         	=> 	m_acc_assert_flag(26),
     x_acc_assert_flag27         	=> 	m_acc_assert_flag(27),
     x_acc_assert_flag28         	=> 	m_acc_assert_flag(28),
     x_acc_assert_flag29         	=> 	m_acc_assert_flag(29),
     x_acc_assert_flag30        	=> 	m_acc_assert_flag(30)
 );


EXCEPTION
     WHEN NO_DATA_FOUND
	     THEN
            fnd_file.put_line (fnd_file.LOG, SUBSTR ('No data found in Update_acc_ctrl_components'
                || SUBSTR (SQLERRM, 1, 100), 1, 200));

     WHEN OTHERS
         THEN
            fnd_file.put_line (fnd_file.LOG, SUBSTR ('Unexpected Error in Update_acc_ctrl_components'
                || SUBSTR (SQLERRM, 1, 100), 1, 200));


end;
end ; --Update_acc_ctrl_Assertions
------------------------------------------------------------------------------------------------------------
--******************************************************************************************************
/* ************************* End of Code to be executed for updating  Control Assertions LEVEL DATA
-- when business evevnt is rised on opinion changes **** */
--******************************************************************************************************



------------------------------------------------------------------------------------------------------------

procedure UPDATE_FINITEM_ASSERT_ROW (
 x_fin_certification_id       	NUMBER  ,
 x_financial_statement_id    	 NUMBER ,
 x_financial_item_id         	 NUMBER ,
 x_account_group_id          	 NUMBER,
 x_natural_account_id        	 NUMBER,
 x_object_type               	 VARCHAR2,
 x_ctrl_attribute_type       	 VARCHAR2,
 x_ineff_ctrl_attr_1         	 NUMBER,
 x_ineff_ctrl_attr_2         	 NUMBER,
 x_ineff_ctrl_attr_3         	 NUMBER,
 x_ineff_ctrl_attr_4         	 NUMBER,
 x_ineff_ctrl_attr_5         	 NUMBER,
 x_ineff_ctrl_attr_6         	 NUMBER,
 x_ineff_ctrl_attr_7         	 NUMBER,
 x_ineff_ctrl_attr_8         	 NUMBER,
 x_ineff_ctrl_attr_9         	 NUMBER,
 x_ineff_ctrl_attr_10        	  NUMBER,
 x_ineff_ctrl_attr_11        	  NUMBER,
 x_ineff_ctrl_attr_12        	  NUMBER,
 x_ineff_ctrl_attr_13        	  NUMBER,
 x_ineff_ctrl_attr_14        	  NUMBER,
 x_ineff_ctrl_attr_15        	  NUMBER,
 x_ineff_ctrl_attr_16        	  NUMBER,
 x_ineff_ctrl_attr_17        	  NUMBER,
 x_ineff_ctrl_attr_18        	  NUMBER,
 x_ineff_ctrl_attr_19        	  NUMBER,
 x_ineff_ctrl_attr_20        	  NUMBER,
 x_ineff_ctrl_attr_21        	  NUMBER,
 x_ineff_ctrl_attr_22        	  NUMBER,
 x_ineff_ctrl_attr_23        	  NUMBER,
 x_ineff_ctrl_attr_24         	 NUMBER,
 x_ineff_ctrl_attr_25        	  NUMBER,
 x_ineff_ctrl_attr_26        	  NUMBER,
 x_ineff_ctrl_attr_27        	  NUMBER,
 x_ineff_ctrl_attr_28        	  NUMBER,
 x_ineff_ctrl_attr_29        	  NUMBER,
 x_ineff_ctrl_attr_30        	  NUMBER,
 x_last_updated_by           	 NUMBER,
 x_last_update_date          	 DATE ,
 x_last_update_login         	 NUMBER,
x_eval_ctrl_attr_1         	  NUMBER,
x_eval_ctrl_attr_2         	  NUMBER,
x_eval_ctrl_attr_3         	  NUMBER,
x_eval_ctrl_attr_4         	  NUMBER,
x_eval_ctrl_attr_5         	  NUMBER,
x_eval_ctrl_attr_6         	  NUMBER,
x_eval_ctrl_attr_7         	  NUMBER,
x_eval_ctrl_attr_8         	  NUMBER,
x_eval_ctrl_attr_9         	  NUMBER,
x_eval_ctrl_attr_10        	  NUMBER,
x_eval_ctrl_attr_11         	  NUMBER,
x_eval_ctrl_attr_12         	  NUMBER,
x_eval_ctrl_attr_13         	  NUMBER,
x_eval_ctrl_attr_14         	  NUMBER,
x_eval_ctrl_attr_15         	  NUMBER,
x_eval_ctrl_attr_16         	  NUMBER,
x_eval_ctrl_attr_17         	  NUMBER,
x_eval_ctrl_attr_18         	  NUMBER,
x_eval_ctrl_attr_19         	  NUMBER,
x_eval_ctrl_attr_20        	  NUMBER,
x_eval_ctrl_attr_21         	  NUMBER,
x_eval_ctrl_attr_22         	  NUMBER,
x_eval_ctrl_attr_23         	  NUMBER,
x_eval_ctrl_attr_24         	  NUMBER,
x_eval_ctrl_attr_25         	  NUMBER,
x_eval_ctrl_attr_26         	  NUMBER,
x_eval_ctrl_attr_27         	  NUMBER,
x_eval_ctrl_attr_28         	  NUMBER,
x_eval_ctrl_attr_29         	  NUMBER,
x_eval_ctrl_attr_30        	  NUMBER,
x_acc_assert_flag1         	  VARCHAR2,
x_acc_assert_flag2         	  VARCHAR2,
x_acc_assert_flag3         	  VARCHAR2,
x_acc_assert_flag4         	  VARCHAR2,
x_acc_assert_flag5         	  VARCHAR2,
x_acc_assert_flag6         	  VARCHAR2,
x_acc_assert_flag7         	  VARCHAR2,
x_acc_assert_flag8         	  VARCHAR2,
x_acc_assert_flag9         	  VARCHAR2,
x_acc_assert_flag10        	  VARCHAR2,
x_acc_assert_flag11         	  VARCHAR2,
x_acc_assert_flag12         	  VARCHAR2,
x_acc_assert_flag13         	  VARCHAR2,
x_acc_assert_flag14         	  VARCHAR2,
x_acc_assert_flag15         	  VARCHAR2,
x_acc_assert_flag16         	  VARCHAR2,
x_acc_assert_flag17         	  VARCHAR2,
x_acc_assert_flag18         	  VARCHAR2,
x_acc_assert_flag19         	  VARCHAR2,
x_acc_assert_flag20        	  VARCHAR2,
x_acc_assert_flag21         	  VARCHAR2,
x_acc_assert_flag22         	  VARCHAR2,
x_acc_assert_flag23         	  VARCHAR2,
x_acc_assert_flag24         	  VARCHAR2,
x_acc_assert_flag25         	  VARCHAR2,
x_acc_assert_flag26         	  VARCHAR2,
x_acc_assert_flag27         	  VARCHAR2,
x_acc_assert_flag28         	  VARCHAR2,
x_acc_assert_flag29         	  VARCHAR2,
x_acc_assert_flag30        	  VARCHAR2
) is

begin
declare
 var_fin_certification_id  number;

 begin

 --******************************************************************************************************
 -- NOTE: The values in x_ineff_ctrl_attr_(1 .. 30) may be +1 or -1 depending on the change_flag b or f respectively
 --******************************************************************************************************
  UPDATE
    amw_fin_cert_ctrl_sum
  SET
      ineff_ctrl_attr_1= x_ineff_ctrl_attr_1
     ,ineff_ctrl_attr_2= x_ineff_ctrl_attr_2
     ,ineff_ctrl_attr_3= x_ineff_ctrl_attr_3
     ,ineff_ctrl_attr_4= x_ineff_ctrl_attr_4
     ,ineff_ctrl_attr_5= x_ineff_ctrl_attr_5
     ,ineff_ctrl_attr_6= x_ineff_ctrl_attr_6
     ,ineff_ctrl_attr_7= x_ineff_ctrl_attr_7
     ,ineff_ctrl_attr_8= x_ineff_ctrl_attr_8
     ,ineff_ctrl_attr_9= x_ineff_ctrl_attr_9
     ,ineff_ctrl_attr_10= x_ineff_ctrl_attr_10
     ,ineff_ctrl_attr_11= x_ineff_ctrl_attr_11
     ,ineff_ctrl_attr_12= x_ineff_ctrl_attr_12
     ,ineff_ctrl_attr_13= x_ineff_ctrl_attr_13
     ,ineff_ctrl_attr_14= x_ineff_ctrl_attr_14
     ,ineff_ctrl_attr_15= x_ineff_ctrl_attr_15
     ,ineff_ctrl_attr_16= x_ineff_ctrl_attr_16
     ,ineff_ctrl_attr_17= x_ineff_ctrl_attr_17
     ,ineff_ctrl_attr_18= x_ineff_ctrl_attr_18
     ,ineff_ctrl_attr_19= x_ineff_ctrl_attr_19
     ,ineff_ctrl_attr_20= x_ineff_ctrl_attr_20
     ,ineff_ctrl_attr_21= x_ineff_ctrl_attr_21
     ,ineff_ctrl_attr_22= x_ineff_ctrl_attr_22
     ,ineff_ctrl_attr_23= x_ineff_ctrl_attr_23
     ,ineff_ctrl_attr_24= x_ineff_ctrl_attr_24
     ,ineff_ctrl_attr_25= x_ineff_ctrl_attr_25
     ,ineff_ctrl_attr_26= x_ineff_ctrl_attr_26
     ,ineff_ctrl_attr_27= x_ineff_ctrl_attr_27
     ,ineff_ctrl_attr_28= x_ineff_ctrl_attr_28
     ,ineff_ctrl_attr_29= x_ineff_ctrl_attr_29
     ,ineff_ctrl_attr_30= x_ineff_ctrl_attr_30,
     eval_ctrl_attr_1    =	nvl(eval_ctrl_attr_1,0) + x_eval_ctrl_attr_1  ,
     eval_ctrl_attr_2    =	nvl(eval_ctrl_attr_2,0) + x_eval_ctrl_attr_2  ,
     eval_ctrl_attr_3    =	nvl(eval_ctrl_attr_3,0) + x_eval_ctrl_attr_3  ,
     eval_ctrl_attr_4    =	nvl(eval_ctrl_attr_4,0) + x_eval_ctrl_attr_4  ,
     eval_ctrl_attr_5    =	nvl(eval_ctrl_attr_5,0) + x_eval_ctrl_attr_5  ,
     eval_ctrl_attr_6    =	nvl(eval_ctrl_attr_6,0) + x_eval_ctrl_attr_6  ,
     eval_ctrl_attr_7    =	nvl(eval_ctrl_attr_7,0) + x_eval_ctrl_attr_7  ,
     eval_ctrl_attr_8    =	nvl(eval_ctrl_attr_8,0) + x_eval_ctrl_attr_8  ,
     eval_ctrl_attr_9    =	nvl(eval_ctrl_attr_9,0) + x_eval_ctrl_attr_9  ,
     eval_ctrl_attr_10   =	nvl(eval_ctrl_attr_10,0) +  x_eval_ctrl_attr_10  ,
     eval_ctrl_attr_11    =	nvl(eval_ctrl_attr_11,0) + x_eval_ctrl_attr_11  ,
     eval_ctrl_attr_12    =	nvl(eval_ctrl_attr_12,0) + x_eval_ctrl_attr_12  ,
     eval_ctrl_attr_13    =	nvl(eval_ctrl_attr_13,0) + x_eval_ctrl_attr_13  ,
     eval_ctrl_attr_14    =	nvl(eval_ctrl_attr_14,0) + x_eval_ctrl_attr_14  ,
     eval_ctrl_attr_15    =	nvl(eval_ctrl_attr_15,0) + x_eval_ctrl_attr_15  ,
     eval_ctrl_attr_16    =	nvl(eval_ctrl_attr_16,0) + x_eval_ctrl_attr_16  ,
     eval_ctrl_attr_17    =	nvl(eval_ctrl_attr_17,0) + x_eval_ctrl_attr_17  ,
     eval_ctrl_attr_18    =	nvl(eval_ctrl_attr_18,0) + x_eval_ctrl_attr_18  ,
     eval_ctrl_attr_19    =	nvl(eval_ctrl_attr_19,0) + x_eval_ctrl_attr_19  ,
     eval_ctrl_attr_20   =	nvl(eval_ctrl_attr_20,0) +  x_eval_ctrl_attr_20  ,
     eval_ctrl_attr_21  =	nvl(eval_ctrl_attr_21,0) + x_eval_ctrl_attr_21  ,
     eval_ctrl_attr_22    =	nvl(eval_ctrl_attr_22,0) + x_eval_ctrl_attr_22  ,
     eval_ctrl_attr_23    =	nvl(eval_ctrl_attr_23,0) + x_eval_ctrl_attr_23  ,
     eval_ctrl_attr_24    =	nvl(eval_ctrl_attr_24,0) + x_eval_ctrl_attr_24  ,
     eval_ctrl_attr_25    =	nvl(eval_ctrl_attr_25,0) + x_eval_ctrl_attr_25  ,
     eval_ctrl_attr_26    =	nvl(eval_ctrl_attr_26,0) + x_eval_ctrl_attr_26  ,
     eval_ctrl_attr_27    =	nvl(eval_ctrl_attr_27,0) + x_eval_ctrl_attr_27  ,
     eval_ctrl_attr_28    =	nvl(eval_ctrl_attr_28,0) + x_eval_ctrl_attr_28  ,
     eval_ctrl_attr_29    =	nvl(eval_ctrl_attr_29,0) + x_eval_ctrl_attr_29  ,
     eval_ctrl_attr_30   =	nvl(eval_ctrl_attr_30,0) + x_eval_ctrl_attr_30
     ,ineff_ctrl_prcnt_1=  round((x_ineff_ctrl_attr_1	 /  decode(total_ctrl_attr_1,null,1,0,1,total_ctrl_attr_1) ) * 100,0)
     ,ineff_ctrl_prcnt_2 = round((x_ineff_ctrl_attr_2	 /  decode(total_ctrl_attr_2,null,1,0,1,total_ctrl_attr_2) ) * 100,0)
     ,ineff_ctrl_prcnt_3=  round((x_ineff_ctrl_attr_3	 /  decode(total_ctrl_attr_3,null,1,0,1,total_ctrl_attr_3) ) * 100,0)
     ,ineff_ctrl_prcnt_4=  round((x_ineff_ctrl_attr_4	 /  decode(total_ctrl_attr_4,null,1,0,1,total_ctrl_attr_4) ) * 100,0)
     ,ineff_ctrl_prcnt_5=  round((x_ineff_ctrl_attr_5	 /  decode(total_ctrl_attr_5,null,1,0,1,total_ctrl_attr_5) ) * 100,0)
     ,ineff_ctrl_prcnt_6=  round((x_ineff_ctrl_attr_6	 /  decode(total_ctrl_attr_6,null,1,0,1,total_ctrl_attr_6) ) * 100,0)
     ,ineff_ctrl_prcnt_7=  round((x_ineff_ctrl_attr_7	 /  decode(total_ctrl_attr_7,null,1,0,1,total_ctrl_attr_7) ) * 100,0)
     ,ineff_ctrl_prcnt_8=  round((x_ineff_ctrl_attr_8	 /  decode(total_ctrl_attr_8,null,1,0,1,total_ctrl_attr_8) ) * 100,0)
     ,ineff_ctrl_prcnt_9=  round((x_ineff_ctrl_attr_9	 /  decode(total_ctrl_attr_9,null,1,0,1,total_ctrl_attr_9) ) * 100,0)
     ,ineff_ctrl_prcnt_10= round((x_ineff_ctrl_attr_10 /  decode(total_ctrl_attr_10,null,1,0,1,total_ctrl_attr_10) ) * 100,0)
     ,ineff_ctrl_prcnt_11= round((x_ineff_ctrl_attr_11 /  decode(total_ctrl_attr_11,null,1,0,1,total_ctrl_attr_11) ) * 100,0)
     ,ineff_ctrl_prcnt_12= round((x_ineff_ctrl_attr_12 /  decode(total_ctrl_attr_12,null,1,0,1,total_ctrl_attr_12) ) * 100,0)
     ,ineff_ctrl_prcnt_13= round((x_ineff_ctrl_attr_13 /  decode(total_ctrl_attr_13,null,1,0,1,total_ctrl_attr_13) ) * 100,0)
     ,ineff_ctrl_prcnt_14= round((x_ineff_ctrl_attr_14 /  decode(total_ctrl_attr_14,null,1,0,1,total_ctrl_attr_14) ) * 100,0)
     ,ineff_ctrl_prcnt_15= round((x_ineff_ctrl_attr_15 /  decode(total_ctrl_attr_15,null,1,0,1,total_ctrl_attr_15) ) * 100,0)
     ,ineff_ctrl_prcnt_16= round((x_ineff_ctrl_attr_16 /  decode(total_ctrl_attr_16,null,1,0,1,total_ctrl_attr_16) ) * 100,0)
     ,ineff_ctrl_prcnt_17= round((x_ineff_ctrl_attr_17 /  decode(total_ctrl_attr_17,null,1,0,1,total_ctrl_attr_17) ) * 100,0)
     ,ineff_ctrl_prcnt_18= round((x_ineff_ctrl_attr_18 /  decode(total_ctrl_attr_18,null,1,0,1,total_ctrl_attr_18) ) * 100,0)
     ,ineff_ctrl_prcnt_19= round((x_ineff_ctrl_attr_19 /  decode(total_ctrl_attr_19,null,1,0,1,total_ctrl_attr_19) ) * 100,0)
     ,ineff_ctrl_prcnt_20= round((x_ineff_ctrl_attr_20 /  decode(total_ctrl_attr_20,null,1,0,1,total_ctrl_attr_20) ) * 100,0)
     ,ineff_ctrl_prcnt_21= round((x_ineff_ctrl_attr_21 /  decode(total_ctrl_attr_21,null,1,0,1,total_ctrl_attr_21) ) * 100,0)
     ,ineff_ctrl_prcnt_22= round((x_ineff_ctrl_attr_22 /  decode(total_ctrl_attr_22,null,1,0,1,total_ctrl_attr_22) ) * 100,0)
     ,ineff_ctrl_prcnt_23= round((x_ineff_ctrl_attr_23 /  decode(total_ctrl_attr_23,null,1,0,1,total_ctrl_attr_23) ) * 100,0)
     ,ineff_ctrl_prcnt_24= round((x_ineff_ctrl_attr_24 /  decode(total_ctrl_attr_24,null,1,0,1,total_ctrl_attr_24) ) * 100,0)
     ,ineff_ctrl_prcnt_25= round((x_ineff_ctrl_attr_25 /  decode(total_ctrl_attr_25,null,1,0,1,total_ctrl_attr_25) ) * 100,0)
     ,ineff_ctrl_prcnt_26= round((x_ineff_ctrl_attr_26 /  decode(total_ctrl_attr_26,null,1,0,1,total_ctrl_attr_26) ) * 100,0)
     ,ineff_ctrl_prcnt_27= round((x_ineff_ctrl_attr_27 /  decode(total_ctrl_attr_27,null,1,0,1,total_ctrl_attr_27) ) * 100,0)
     ,ineff_ctrl_prcnt_28= round((x_ineff_ctrl_attr_28 /  decode(total_ctrl_attr_28,null,1,0,1,total_ctrl_attr_28) ) * 100,0)
     ,ineff_ctrl_prcnt_29= round((x_ineff_ctrl_attr_29 /  decode(total_ctrl_attr_29,null,1,0,1,total_ctrl_attr_29) ) * 100,0)
     ,ineff_ctrl_prcnt_30= round((x_ineff_ctrl_attr_30 /  decode(total_ctrl_attr_30,null,1,0,1,total_ctrl_attr_30) ) * 100,0)
     ,acc_assert_flag_1  = 	x_acc_assert_flag1
     ,acc_assert_flag_2  = 	x_acc_assert_flag2
     ,acc_assert_flag_3  = 	x_acc_assert_flag3
     ,acc_assert_flag_4  = 	x_acc_assert_flag4
     ,acc_assert_flag_5  = 	x_acc_assert_flag5
     ,acc_assert_flag_6  = 	x_acc_assert_flag6
     ,acc_assert_flag_7  = 	x_acc_assert_flag7
     ,acc_assert_flag_8  = 	x_acc_assert_flag8
     ,acc_assert_flag_9  = 	x_acc_assert_flag9
     ,acc_assert_flag_10 = 	x_acc_assert_flag10
     ,acc_assert_flag_11  = 	x_acc_assert_flag11
     ,acc_assert_flag_12  = 	x_acc_assert_flag12
     ,acc_assert_flag_13  = 	x_acc_assert_flag13
     ,acc_assert_flag_14  = 	x_acc_assert_flag14
     ,acc_assert_flag_15  = 	x_acc_assert_flag15
     ,acc_assert_flag_16  = 	x_acc_assert_flag16
     ,acc_assert_flag_17  = 	x_acc_assert_flag17
     ,acc_assert_flag_18  = 	x_acc_assert_flag18
     ,acc_assert_flag_19  = 	x_acc_assert_flag19
     ,acc_assert_flag_20 = 	x_acc_assert_flag20
     ,acc_assert_flag_21  = 	x_acc_assert_flag21
     ,acc_assert_flag_22  = 	x_acc_assert_flag22
     ,acc_assert_flag_23  = 	x_acc_assert_flag23
     ,acc_assert_flag_24  = 	x_acc_assert_flag24
     ,acc_assert_flag_25  = 	x_acc_assert_flag25
     ,acc_assert_flag_26  = 	x_acc_assert_flag26
     ,acc_assert_flag_27  = 	x_acc_assert_flag27
     ,acc_assert_flag_28  = 	x_acc_assert_flag28
     ,acc_assert_flag_29  = 	x_acc_assert_flag29
     ,acc_assert_flag_30  = 	x_acc_assert_flag30
     ,last_updated_by           =  x_last_updated_by
     ,last_update_date          =  x_last_update_date
     ,last_update_login         = x_last_update_login
     ,object_version_number = object_version_number +1
where
 fin_certification_id     = x_fin_certification_id      and
 financial_statement_id   = x_financial_statement_id    and
 NVL(financial_item_id, -1)        = NVL(x_financial_item_id, -1) and
 NVL(account_group_id, -1) =  NVL(x_account_group_id, -1) and
 nvl(natural_account_id, -1) = nvl(x_natural_account_id, -1)   and
 CTRL_ATTRIBUTE_TYPE =  x_ctrl_attribute_type       and
 object_type	= x_object_type       ;

/* EXCEPTION
  WHEN OTHERS THEN
 fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
  fnd_file.put_line(fnd_file.LOG, 'natural_account_id' || x_natural_account_id );
 fnd_file.put_line(fnd_file.LOG,  'financial_item_id' || x_financial_item_id);
 fnd_file.put_line(fnd_file.LOG,  'fin_certification_id  ' || x_fin_certification_id  );


 RAISE ;
 RETURN; */

end;
end UPDATE_FINITEM_ASSERT_ROW;

--***********************************************************************************************************
procedure UPDATE_FIN_ITEM_ROW(
 x_fin_certification_id       	NUMBER  ,
 x_financial_statement_id    	 NUMBER ,
 x_financial_item_id         	 NUMBER ,
 x_account_group_id          	 NUMBER,
 x_natural_account_id        	 NUMBER,
 x_object_type               	 VARCHAR2,
 x_ctrl_attribute_type       	 VARCHAR2,
 x_ineff_ctrl_attr_1         	 NUMBER,
 x_ineff_ctrl_attr_2         	 NUMBER,
 x_ineff_ctrl_attr_3         	 NUMBER,
 x_ineff_ctrl_attr_4         	 NUMBER,
 x_ineff_ctrl_attr_5         	 NUMBER,
 x_ineff_ctrl_attr_6         	 NUMBER,
 x_ineff_ctrl_attr_7         	 NUMBER,
 x_ineff_ctrl_attr_8         	 NUMBER,
 x_ineff_ctrl_attr_9         	 NUMBER,
 x_ineff_ctrl_attr_10        	  NUMBER,
 x_ineff_ctrl_attr_11        	  NUMBER,
 x_ineff_ctrl_attr_12        	  NUMBER,
 x_ineff_ctrl_attr_13        	  NUMBER,
 x_ineff_ctrl_attr_14        	  NUMBER,
 x_ineff_ctrl_attr_15        	  NUMBER,
 x_ineff_ctrl_attr_16        	  NUMBER,
 x_ineff_ctrl_attr_17        	  NUMBER,
 x_ineff_ctrl_attr_18        	  NUMBER,
 x_ineff_ctrl_attr_19        	  NUMBER,
 x_ineff_ctrl_attr_20        	  NUMBER,
 x_ineff_ctrl_attr_21        	  NUMBER,
 x_ineff_ctrl_attr_22        	  NUMBER,
 x_ineff_ctrl_attr_23        	  NUMBER,
 x_ineff_ctrl_attr_24         	 NUMBER,
 x_ineff_ctrl_attr_25        	  NUMBER,
 x_ineff_ctrl_attr_26        	  NUMBER,
 x_ineff_ctrl_attr_27        	  NUMBER,
 x_ineff_ctrl_attr_28        	  NUMBER,
 x_ineff_ctrl_attr_29        	  NUMBER,
 x_ineff_ctrl_attr_30        	  NUMBER,
 x_last_updated_by           	 NUMBER,
 x_last_update_date          	 DATE ,
 x_last_update_login         	 NUMBER,
x_eval_ctrl_attr_1         	  NUMBER,
x_eval_ctrl_attr_2         	  NUMBER,
x_eval_ctrl_attr_3         	  NUMBER,
x_eval_ctrl_attr_4         	  NUMBER,
x_eval_ctrl_attr_5         	  NUMBER,
x_eval_ctrl_attr_6         	  NUMBER,
x_eval_ctrl_attr_7         	  NUMBER,
x_eval_ctrl_attr_8         	  NUMBER,
x_eval_ctrl_attr_9         	  NUMBER,
x_eval_ctrl_attr_10        	  NUMBER,
x_eval_ctrl_attr_11         	  NUMBER,
x_eval_ctrl_attr_12         	  NUMBER,
x_eval_ctrl_attr_13         	  NUMBER,
x_eval_ctrl_attr_14         	  NUMBER,
x_eval_ctrl_attr_15         	  NUMBER,
x_eval_ctrl_attr_16         	  NUMBER,
x_eval_ctrl_attr_17         	  NUMBER,
x_eval_ctrl_attr_18         	  NUMBER,
x_eval_ctrl_attr_19         	  NUMBER,
x_eval_ctrl_attr_20        	  NUMBER,
x_eval_ctrl_attr_21         	  NUMBER,
x_eval_ctrl_attr_22         	  NUMBER,
x_eval_ctrl_attr_23         	  NUMBER,
x_eval_ctrl_attr_24         	  NUMBER,
x_eval_ctrl_attr_25         	  NUMBER,
x_eval_ctrl_attr_26         	  NUMBER,
x_eval_ctrl_attr_27         	  NUMBER,
x_eval_ctrl_attr_28         	  NUMBER,
x_eval_ctrl_attr_29         	  NUMBER,
x_eval_ctrl_attr_30        	  NUMBER
) is

begin
declare
 var_fin_certification_id  number;

 begin

 --******************************************************************************************************
 -- NOTE: The values in x_ineff_ctrl_attr_(1 .. 30) may be +1 or -1 depending on the change_flag b or f respectively
 --******************************************************************************************************
  UPDATE
    amw_fin_cert_ctrl_sum
  SET
      ineff_ctrl_attr_1=  x_ineff_ctrl_attr_1
     ,ineff_ctrl_attr_2 = x_ineff_ctrl_attr_2
     ,ineff_ctrl_attr_3= x_ineff_ctrl_attr_3
     ,ineff_ctrl_attr_4= x_ineff_ctrl_attr_4
     ,ineff_ctrl_attr_5= x_ineff_ctrl_attr_5
     ,ineff_ctrl_attr_6= x_ineff_ctrl_attr_6
     ,ineff_ctrl_attr_7= x_ineff_ctrl_attr_7
     ,ineff_ctrl_attr_8= x_ineff_ctrl_attr_8
     ,ineff_ctrl_attr_9= x_ineff_ctrl_attr_9
     ,ineff_ctrl_attr_10= x_ineff_ctrl_attr_10
     ,ineff_ctrl_attr_11= x_ineff_ctrl_attr_11
     ,ineff_ctrl_attr_12= x_ineff_ctrl_attr_12
     ,ineff_ctrl_attr_13= x_ineff_ctrl_attr_13
     ,ineff_ctrl_attr_14= x_ineff_ctrl_attr_14
     ,ineff_ctrl_attr_15= x_ineff_ctrl_attr_15
     ,ineff_ctrl_attr_16= x_ineff_ctrl_attr_16
     ,ineff_ctrl_attr_17= x_ineff_ctrl_attr_17
     ,ineff_ctrl_attr_18= x_ineff_ctrl_attr_18
     ,ineff_ctrl_attr_19= x_ineff_ctrl_attr_19
     ,ineff_ctrl_attr_20= x_ineff_ctrl_attr_20
     ,ineff_ctrl_attr_21= x_ineff_ctrl_attr_21
     ,ineff_ctrl_attr_22= x_ineff_ctrl_attr_22
     ,ineff_ctrl_attr_23= x_ineff_ctrl_attr_23
     ,ineff_ctrl_attr_24= x_ineff_ctrl_attr_24
     ,ineff_ctrl_attr_25= x_ineff_ctrl_attr_25
     ,ineff_ctrl_attr_26= x_ineff_ctrl_attr_26
     ,ineff_ctrl_attr_27= x_ineff_ctrl_attr_27
     ,ineff_ctrl_attr_28= x_ineff_ctrl_attr_28
     ,ineff_ctrl_attr_29= x_ineff_ctrl_attr_29
     ,ineff_ctrl_attr_30= x_ineff_ctrl_attr_30,
eval_ctrl_attr_1    =	nvl(eval_ctrl_attr_1,0) + x_eval_ctrl_attr_1  ,
eval_ctrl_attr_2    =	nvl(eval_ctrl_attr_2,0) + x_eval_ctrl_attr_2  ,
eval_ctrl_attr_3    =	nvl(eval_ctrl_attr_3,0) + x_eval_ctrl_attr_3  ,
eval_ctrl_attr_4    =	nvl(eval_ctrl_attr_4,0) + x_eval_ctrl_attr_4  ,
eval_ctrl_attr_5    =	nvl(eval_ctrl_attr_5,0) + x_eval_ctrl_attr_5  ,
eval_ctrl_attr_6    =	nvl(eval_ctrl_attr_6,0) + x_eval_ctrl_attr_6  ,
eval_ctrl_attr_7    =	nvl(eval_ctrl_attr_7,0) + x_eval_ctrl_attr_7  ,
eval_ctrl_attr_8    =	nvl(eval_ctrl_attr_8,0) + x_eval_ctrl_attr_8  ,
eval_ctrl_attr_9    =	nvl(eval_ctrl_attr_9,0) + x_eval_ctrl_attr_9  ,
eval_ctrl_attr_10   =	nvl(eval_ctrl_attr_10,0) +  x_eval_ctrl_attr_10  ,
eval_ctrl_attr_11    =	nvl(eval_ctrl_attr_11,0) + x_eval_ctrl_attr_11  ,
eval_ctrl_attr_12    =	nvl(eval_ctrl_attr_12,0) + x_eval_ctrl_attr_12  ,
eval_ctrl_attr_13    =	nvl(eval_ctrl_attr_13,0) + x_eval_ctrl_attr_13  ,
eval_ctrl_attr_14    =	nvl(eval_ctrl_attr_14,0) + x_eval_ctrl_attr_14  ,
eval_ctrl_attr_15    =	nvl(eval_ctrl_attr_15,0) + x_eval_ctrl_attr_15  ,
eval_ctrl_attr_16    =	nvl(eval_ctrl_attr_16,0) + x_eval_ctrl_attr_16  ,
eval_ctrl_attr_17    =	nvl(eval_ctrl_attr_17,0) + x_eval_ctrl_attr_17  ,
eval_ctrl_attr_18    =	nvl(eval_ctrl_attr_18,0) + x_eval_ctrl_attr_18  ,
eval_ctrl_attr_19    =	nvl(eval_ctrl_attr_19,0) + x_eval_ctrl_attr_19  ,
eval_ctrl_attr_20   =	nvl(eval_ctrl_attr_20,0) +  x_eval_ctrl_attr_20  ,
eval_ctrl_attr_21  =	nvl(eval_ctrl_attr_21,0) + x_eval_ctrl_attr_21  ,
eval_ctrl_attr_22    =	nvl(eval_ctrl_attr_22,0) + x_eval_ctrl_attr_22  ,
eval_ctrl_attr_23    =	nvl(eval_ctrl_attr_23,0) + x_eval_ctrl_attr_23  ,
eval_ctrl_attr_24    =	nvl(eval_ctrl_attr_24,0) + x_eval_ctrl_attr_24  ,
eval_ctrl_attr_25    =	nvl(eval_ctrl_attr_25,0) + x_eval_ctrl_attr_25  ,
eval_ctrl_attr_26    =	nvl(eval_ctrl_attr_26,0) + x_eval_ctrl_attr_26  ,
eval_ctrl_attr_27    =	nvl(eval_ctrl_attr_27,0) + x_eval_ctrl_attr_27  ,
eval_ctrl_attr_28    =	nvl(eval_ctrl_attr_28,0) + x_eval_ctrl_attr_28  ,
eval_ctrl_attr_29    =	nvl(eval_ctrl_attr_29,0) + x_eval_ctrl_attr_29,
eval_ctrl_attr_30   =	nvl(eval_ctrl_attr_30,0) + x_eval_ctrl_attr_30
,ineff_ctrl_prcnt_1=  round((x_ineff_ctrl_attr_1	 /  decode(total_ctrl_attr_1,null,1,0,1,total_ctrl_attr_1) ) * 100,0)
     ,ineff_ctrl_prcnt_2 = round((x_ineff_ctrl_attr_2	 /  decode(total_ctrl_attr_2,null,1,0,1,total_ctrl_attr_2) ) * 100,0)
     ,ineff_ctrl_prcnt_3=  round((x_ineff_ctrl_attr_3	 /  decode(total_ctrl_attr_3,null,1,0,1,total_ctrl_attr_3) ) * 100,0)
     ,ineff_ctrl_prcnt_4=  round((x_ineff_ctrl_attr_4	 /  decode(total_ctrl_attr_4,null,1,0,1,total_ctrl_attr_4) ) * 100,0)
     ,ineff_ctrl_prcnt_5=  round((x_ineff_ctrl_attr_5	 /  decode(total_ctrl_attr_5,null,1,0,1,total_ctrl_attr_5) ) * 100,0)
     ,ineff_ctrl_prcnt_6=  round((x_ineff_ctrl_attr_6	 /  decode(total_ctrl_attr_6,null,1,0,1,total_ctrl_attr_6) ) * 100,0)
     ,ineff_ctrl_prcnt_7=  round((x_ineff_ctrl_attr_7	 /  decode(total_ctrl_attr_7,null,1,0,1,total_ctrl_attr_7) ) * 100,0)
     ,ineff_ctrl_prcnt_8=  round((x_ineff_ctrl_attr_8	 /  decode(total_ctrl_attr_8,null,1,0,1,total_ctrl_attr_8) ) * 100,0)
     ,ineff_ctrl_prcnt_9=  round((x_ineff_ctrl_attr_9	 /  decode(total_ctrl_attr_9,null,1,0,1,total_ctrl_attr_9) ) * 100,0)
     ,ineff_ctrl_prcnt_10= round((x_ineff_ctrl_attr_10 /  decode(total_ctrl_attr_10,null,1,0,1,total_ctrl_attr_10) ) * 100,0)
     ,ineff_ctrl_prcnt_11= round((x_ineff_ctrl_attr_11 /  decode(total_ctrl_attr_11,null,1,0,1,total_ctrl_attr_11) ) * 100,0)
     ,ineff_ctrl_prcnt_12= round((x_ineff_ctrl_attr_12 /  decode(total_ctrl_attr_12,null,1,0,1,total_ctrl_attr_12) ) * 100,0)
     ,ineff_ctrl_prcnt_13= round((x_ineff_ctrl_attr_13 /  decode(total_ctrl_attr_13,null,1,0,1,total_ctrl_attr_13) ) * 100,0)
     ,ineff_ctrl_prcnt_14= round((x_ineff_ctrl_attr_14 /  decode(total_ctrl_attr_14,null,1,0,1,total_ctrl_attr_14) ) * 100,0)
     ,ineff_ctrl_prcnt_15= round((x_ineff_ctrl_attr_15 /  decode(total_ctrl_attr_15,null,1,0,1,total_ctrl_attr_15) ) * 100,0)
     ,ineff_ctrl_prcnt_16= round((x_ineff_ctrl_attr_16 /  decode(total_ctrl_attr_16,null,1,0,1,total_ctrl_attr_16) ) * 100,0)
     ,ineff_ctrl_prcnt_17= round((x_ineff_ctrl_attr_17 /  decode(total_ctrl_attr_17,null,1,0,1,total_ctrl_attr_17) ) * 100,0)
     ,ineff_ctrl_prcnt_18= round((x_ineff_ctrl_attr_18 /  decode(total_ctrl_attr_18,null,1,0,1,total_ctrl_attr_18) ) * 100,0)
     ,ineff_ctrl_prcnt_19= round((x_ineff_ctrl_attr_19 /  decode(total_ctrl_attr_19,null,1,0,1,total_ctrl_attr_19) ) * 100,0)
     ,ineff_ctrl_prcnt_20= round((x_ineff_ctrl_attr_20 /  decode(total_ctrl_attr_20,null,1,0,1,total_ctrl_attr_20) ) * 100,0)
     ,ineff_ctrl_prcnt_21= round((x_ineff_ctrl_attr_21 /  decode(total_ctrl_attr_21,null,1,0,1,total_ctrl_attr_21) ) * 100,0)
     ,ineff_ctrl_prcnt_22= round((x_ineff_ctrl_attr_22 /  decode(total_ctrl_attr_22,null,1,0,1,total_ctrl_attr_22) ) * 100,0)
     ,ineff_ctrl_prcnt_23= round((x_ineff_ctrl_attr_23 /  decode(total_ctrl_attr_23,null,1,0,1,total_ctrl_attr_23) ) * 100,0)
     ,ineff_ctrl_prcnt_24= round((x_ineff_ctrl_attr_24 /  decode(total_ctrl_attr_24,null,1,0,1,total_ctrl_attr_24) ) * 100,0)
     ,ineff_ctrl_prcnt_25= round((x_ineff_ctrl_attr_25 /  decode(total_ctrl_attr_25,null,1,0,1,total_ctrl_attr_25) ) * 100,0)
     ,ineff_ctrl_prcnt_26= round((x_ineff_ctrl_attr_26 /  decode(total_ctrl_attr_26,null,1,0,1,total_ctrl_attr_26) ) * 100,0)
     ,ineff_ctrl_prcnt_27= round((x_ineff_ctrl_attr_27 /  decode(total_ctrl_attr_27,null,1,0,1,total_ctrl_attr_27) ) * 100,0)
     ,ineff_ctrl_prcnt_28= round((x_ineff_ctrl_attr_28 /  decode(total_ctrl_attr_28,null,1,0,1,total_ctrl_attr_28) ) * 100,0)
     ,ineff_ctrl_prcnt_29= round((x_ineff_ctrl_attr_29 /  decode(total_ctrl_attr_29,null,1,0,1,total_ctrl_attr_29) ) * 100,0)
     ,ineff_ctrl_prcnt_30= round((x_ineff_ctrl_attr_30 /  decode(total_ctrl_attr_30,null,1,0,1,total_ctrl_attr_30) ) * 100,0)
     ,last_updated_by           =  x_last_updated_by
     ,last_update_date          =  x_last_update_date
     ,last_update_login         = x_last_update_login
     ,object_version_number = object_version_number +1
where
 fin_certification_id     = x_fin_certification_id      and
 financial_statement_id   = x_financial_statement_id    and
 NVL(financial_item_id, -1)        = NVL(x_financial_item_id, -1) and
 NVL(account_group_id, -1) =  NVL(x_account_group_id, -1) and
 nvl(natural_account_id, -1) = nvl(x_natural_account_id, -1)   and
 CTRL_ATTRIBUTE_TYPE =  x_ctrl_attribute_type       and
 object_type	= x_object_type       ;

/* EXCEPTION
  WHEN OTHERS THEN
 fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
  fnd_file.put_line(fnd_file.LOG, 'natural_account_id' || x_natural_account_id );
 fnd_file.put_line(fnd_file.LOG,  'financial_item_id' || x_financial_item_id);
 fnd_file.put_line(fnd_file.LOG,  'fin_certification_id  ' || x_fin_certification_id  );


 RAISE ;
 RETURN; */

end;
end UPDATE_FIN_ITEM_ROW;
--*************************************************************************************************************
procedure UPDATE_FIN_ACC_ASSERT_ROW (
 x_fin_certification_id       	NUMBER  ,
 x_financial_statement_id    	 NUMBER ,
 x_financial_item_id         	 NUMBER ,
 x_account_group_id          	 NUMBER,
 x_natural_account_id        	 NUMBER,
 x_object_type               	 VARCHAR2,
 x_ctrl_attribute_type       	 VARCHAR2,
 x_ineff_ctrl_attr_1         	 NUMBER,
 x_ineff_ctrl_attr_2         	 NUMBER,
 x_ineff_ctrl_attr_3         	 NUMBER,
 x_ineff_ctrl_attr_4         	 NUMBER,
 x_ineff_ctrl_attr_5         	 NUMBER,
 x_ineff_ctrl_attr_6         	 NUMBER,
 x_ineff_ctrl_attr_7         	 NUMBER,
 x_ineff_ctrl_attr_8         	 NUMBER,
 x_ineff_ctrl_attr_9         	 NUMBER,
 x_ineff_ctrl_attr_10        	  NUMBER,
 x_ineff_ctrl_attr_11        	  NUMBER,
 x_ineff_ctrl_attr_12        	  NUMBER,
 x_ineff_ctrl_attr_13        	  NUMBER,
 x_ineff_ctrl_attr_14        	  NUMBER,
 x_ineff_ctrl_attr_15        	  NUMBER,
 x_ineff_ctrl_attr_16        	  NUMBER,
 x_ineff_ctrl_attr_17        	  NUMBER,
 x_ineff_ctrl_attr_18        	  NUMBER,
 x_ineff_ctrl_attr_19        	  NUMBER,
 x_ineff_ctrl_attr_20        	  NUMBER,
 x_ineff_ctrl_attr_21        	  NUMBER,
 x_ineff_ctrl_attr_22        	  NUMBER,
 x_ineff_ctrl_attr_23        	  NUMBER,
 x_ineff_ctrl_attr_24         	 NUMBER,
 x_ineff_ctrl_attr_25        	  NUMBER,
 x_ineff_ctrl_attr_26        	  NUMBER,
 x_ineff_ctrl_attr_27        	  NUMBER,
 x_ineff_ctrl_attr_28        	  NUMBER,
 x_ineff_ctrl_attr_29        	  NUMBER,
 x_ineff_ctrl_attr_30        	  NUMBER,
 x_last_updated_by           	 NUMBER,
 x_last_update_date          	 DATE ,
 x_last_update_login         	 NUMBER,
x_eval_ctrl_attr_1         	  NUMBER,
x_eval_ctrl_attr_2         	  NUMBER,
x_eval_ctrl_attr_3         	  NUMBER,
x_eval_ctrl_attr_4         	  NUMBER,
x_eval_ctrl_attr_5         	  NUMBER,
x_eval_ctrl_attr_6         	  NUMBER,
x_eval_ctrl_attr_7         	  NUMBER,
x_eval_ctrl_attr_8         	  NUMBER,
x_eval_ctrl_attr_9         	  NUMBER,
x_eval_ctrl_attr_10        	  NUMBER,
x_eval_ctrl_attr_11         	  NUMBER,
x_eval_ctrl_attr_12         	  NUMBER,
x_eval_ctrl_attr_13         	  NUMBER,
x_eval_ctrl_attr_14         	  NUMBER,
x_eval_ctrl_attr_15         	  NUMBER,
x_eval_ctrl_attr_16         	  NUMBER,
x_eval_ctrl_attr_17         	  NUMBER,
x_eval_ctrl_attr_18         	  NUMBER,
x_eval_ctrl_attr_19         	  NUMBER,
x_eval_ctrl_attr_20        	  NUMBER,
x_eval_ctrl_attr_21         	  NUMBER,
x_eval_ctrl_attr_22         	  NUMBER,
x_eval_ctrl_attr_23         	  NUMBER,
x_eval_ctrl_attr_24         	  NUMBER,
x_eval_ctrl_attr_25         	  NUMBER,
x_eval_ctrl_attr_26         	  NUMBER,
x_eval_ctrl_attr_27         	  NUMBER,
x_eval_ctrl_attr_28         	  NUMBER,
x_eval_ctrl_attr_29         	  NUMBER,
x_eval_ctrl_attr_30        	  NUMBER,
x_acc_assert_flag1         	  VARCHAR2,
x_acc_assert_flag2         	  VARCHAR2,
x_acc_assert_flag3         	  VARCHAR2,
x_acc_assert_flag4         	  VARCHAR2,
x_acc_assert_flag5         	  VARCHAR2,
x_acc_assert_flag6         	  VARCHAR2,
x_acc_assert_flag7         	  VARCHAR2,
x_acc_assert_flag8         	  VARCHAR2,
x_acc_assert_flag9         	  VARCHAR2,
x_acc_assert_flag10        	  VARCHAR2,
x_acc_assert_flag11         	  VARCHAR2,
x_acc_assert_flag12         	  VARCHAR2,
x_acc_assert_flag13         	  VARCHAR2,
x_acc_assert_flag14         	  VARCHAR2,
x_acc_assert_flag15         	  VARCHAR2,
x_acc_assert_flag16         	  VARCHAR2,
x_acc_assert_flag17         	  VARCHAR2,
x_acc_assert_flag18         	  VARCHAR2,
x_acc_assert_flag19         	  VARCHAR2,
x_acc_assert_flag20        	  VARCHAR2,
x_acc_assert_flag21         	  VARCHAR2,
x_acc_assert_flag22         	  VARCHAR2,
x_acc_assert_flag23         	  VARCHAR2,
x_acc_assert_flag24         	  VARCHAR2,
x_acc_assert_flag25         	  VARCHAR2,
x_acc_assert_flag26         	  VARCHAR2,
x_acc_assert_flag27         	  VARCHAR2,
x_acc_assert_flag28         	  VARCHAR2,
x_acc_assert_flag29         	  VARCHAR2,
x_acc_assert_flag30        	  VARCHAR2
) is

begin
declare
 var_fin_certification_id  number;

 begin

 --******************************************************************************************************
 -- NOTE: The values in x_ineff_ctrl_attr_(1 .. 30) may be +1 or -1 depending on the change_flag b or f respectively
 --******************************************************************************************************


  UPDATE
    amw_fin_cert_ctrl_sum
  SET
      ineff_ctrl_attr_1=  x_ineff_ctrl_attr_1
     ,ineff_ctrl_attr_2 = x_ineff_ctrl_attr_2
     ,ineff_ctrl_attr_3=  x_ineff_ctrl_attr_3
     ,ineff_ctrl_attr_4=  x_ineff_ctrl_attr_4
     ,ineff_ctrl_attr_5=  x_ineff_ctrl_attr_5
     ,ineff_ctrl_attr_6=  x_ineff_ctrl_attr_6
     ,ineff_ctrl_attr_7=  x_ineff_ctrl_attr_7
     ,ineff_ctrl_attr_8=  x_ineff_ctrl_attr_8
     ,ineff_ctrl_attr_9=  x_ineff_ctrl_attr_9
     ,ineff_ctrl_attr_10= x_ineff_ctrl_attr_10
     ,ineff_ctrl_attr_11= x_ineff_ctrl_attr_11
     ,ineff_ctrl_attr_12= x_ineff_ctrl_attr_12
     ,ineff_ctrl_attr_13= x_ineff_ctrl_attr_13
     ,ineff_ctrl_attr_14= x_ineff_ctrl_attr_14
     ,ineff_ctrl_attr_15= x_ineff_ctrl_attr_15
     ,ineff_ctrl_attr_16= x_ineff_ctrl_attr_16
     ,ineff_ctrl_attr_17= x_ineff_ctrl_attr_17
     ,ineff_ctrl_attr_18= x_ineff_ctrl_attr_18
     ,ineff_ctrl_attr_19= x_ineff_ctrl_attr_19
     ,ineff_ctrl_attr_20= x_ineff_ctrl_attr_20
     ,ineff_ctrl_attr_21= x_ineff_ctrl_attr_21
     ,ineff_ctrl_attr_22= x_ineff_ctrl_attr_22
     ,ineff_ctrl_attr_23= x_ineff_ctrl_attr_23
     ,ineff_ctrl_attr_24= x_ineff_ctrl_attr_24
     ,ineff_ctrl_attr_25= x_ineff_ctrl_attr_25
     ,ineff_ctrl_attr_26= x_ineff_ctrl_attr_26
     ,ineff_ctrl_attr_27= x_ineff_ctrl_attr_27
     ,ineff_ctrl_attr_28= x_ineff_ctrl_attr_28
     ,ineff_ctrl_attr_29= x_ineff_ctrl_attr_29
     ,ineff_ctrl_attr_30= x_ineff_ctrl_attr_30
     ,acc_assert_flag_1  = 	x_acc_assert_flag1
     ,acc_assert_flag_2  = 	x_acc_assert_flag2
     ,acc_assert_flag_3  = 	x_acc_assert_flag3
     ,acc_assert_flag_4  = 	x_acc_assert_flag4
     ,acc_assert_flag_5  = 	x_acc_assert_flag5
     ,acc_assert_flag_6  = 	x_acc_assert_flag6
     ,acc_assert_flag_7  = 	x_acc_assert_flag7
     ,acc_assert_flag_8  = 	x_acc_assert_flag8
     ,acc_assert_flag_9  = 	x_acc_assert_flag9
     ,acc_assert_flag_10 = 	x_acc_assert_flag10
     ,acc_assert_flag_11  = 	x_acc_assert_flag11
     ,acc_assert_flag_12  = 	x_acc_assert_flag12
     ,acc_assert_flag_13  = 	x_acc_assert_flag13
     ,acc_assert_flag_14  = 	x_acc_assert_flag14
     ,acc_assert_flag_15  = 	x_acc_assert_flag15
     ,acc_assert_flag_16  = 	x_acc_assert_flag16
     ,acc_assert_flag_17  = 	x_acc_assert_flag17
     ,acc_assert_flag_18  = 	x_acc_assert_flag18
     ,acc_assert_flag_19  = 	x_acc_assert_flag19
     ,acc_assert_flag_20 = 	x_acc_assert_flag20
     ,acc_assert_flag_21  = 	x_acc_assert_flag21
     ,acc_assert_flag_22  = 	x_acc_assert_flag22
     ,acc_assert_flag_23  = 	x_acc_assert_flag23
     ,acc_assert_flag_24  = 	x_acc_assert_flag24
     ,acc_assert_flag_25  = 	x_acc_assert_flag25
     ,acc_assert_flag_26  = 	x_acc_assert_flag26
     ,acc_assert_flag_27  = 	x_acc_assert_flag27
     ,acc_assert_flag_28  = 	x_acc_assert_flag28
     ,acc_assert_flag_29  = 	x_acc_assert_flag29
     ,acc_assert_flag_30  = 	x_acc_assert_flag30,
     eval_ctrl_attr_1    =	nvl(eval_ctrl_attr_1,0) + x_eval_ctrl_attr_1  ,
     eval_ctrl_attr_2    =	nvl(eval_ctrl_attr_2,0) + x_eval_ctrl_attr_2  ,
     eval_ctrl_attr_3    =	nvl(eval_ctrl_attr_3,0) + x_eval_ctrl_attr_3  ,
     eval_ctrl_attr_4    =	nvl(eval_ctrl_attr_4,0) + x_eval_ctrl_attr_4  ,
     eval_ctrl_attr_5    =	nvl(eval_ctrl_attr_5,0) + x_eval_ctrl_attr_5  ,
     eval_ctrl_attr_6    =	nvl(eval_ctrl_attr_6,0) + x_eval_ctrl_attr_6  ,
     eval_ctrl_attr_7    =	nvl(eval_ctrl_attr_7,0) + x_eval_ctrl_attr_7  ,
     eval_ctrl_attr_8    =	nvl(eval_ctrl_attr_8,0) + x_eval_ctrl_attr_8  ,
     eval_ctrl_attr_9    =	nvl(eval_ctrl_attr_9,0) + x_eval_ctrl_attr_9  ,
     eval_ctrl_attr_10   =	nvl(eval_ctrl_attr_10,0) +  x_eval_ctrl_attr_10  ,
     eval_ctrl_attr_11    =	nvl(eval_ctrl_attr_11,0) + x_eval_ctrl_attr_11  ,
     eval_ctrl_attr_12    =	nvl(eval_ctrl_attr_12,0) + x_eval_ctrl_attr_12  ,
     eval_ctrl_attr_13    =	nvl(eval_ctrl_attr_13,0) + x_eval_ctrl_attr_13  ,
     eval_ctrl_attr_14    =	nvl(eval_ctrl_attr_14,0) + x_eval_ctrl_attr_14  ,
     eval_ctrl_attr_15    =	nvl(eval_ctrl_attr_15,0) + x_eval_ctrl_attr_15  ,
     eval_ctrl_attr_16    =	nvl(eval_ctrl_attr_16,0) + x_eval_ctrl_attr_16  ,
     eval_ctrl_attr_17    =	nvl(eval_ctrl_attr_17,0) + x_eval_ctrl_attr_17  ,
     eval_ctrl_attr_18    =	nvl(eval_ctrl_attr_18,0) + x_eval_ctrl_attr_18  ,
     eval_ctrl_attr_19    =	nvl(eval_ctrl_attr_19,0) + x_eval_ctrl_attr_19  ,
     eval_ctrl_attr_20   =	nvl(eval_ctrl_attr_20,0) +  x_eval_ctrl_attr_20  ,
     eval_ctrl_attr_21  =	nvl(eval_ctrl_attr_21,0) + x_eval_ctrl_attr_21  ,
     eval_ctrl_attr_22    =	nvl(eval_ctrl_attr_22,0) + x_eval_ctrl_attr_22  ,
     eval_ctrl_attr_23    =	nvl(eval_ctrl_attr_23,0) + x_eval_ctrl_attr_23  ,
     eval_ctrl_attr_24    =	nvl(eval_ctrl_attr_24,0) + x_eval_ctrl_attr_24  ,
     eval_ctrl_attr_25    =	nvl(eval_ctrl_attr_25,0) + x_eval_ctrl_attr_25  ,
     eval_ctrl_attr_26    =	nvl(eval_ctrl_attr_26,0) + x_eval_ctrl_attr_26  ,
     eval_ctrl_attr_27    =	nvl(eval_ctrl_attr_27,0) + x_eval_ctrl_attr_27  ,
     eval_ctrl_attr_28    =	nvl(eval_ctrl_attr_28,0) + x_eval_ctrl_attr_28  ,
     eval_ctrl_attr_29    =	nvl(eval_ctrl_attr_29,0) + x_eval_ctrl_attr_29  ,
     eval_ctrl_attr_30   =	nvl(eval_ctrl_attr_30,0) + x_eval_ctrl_attr_30
     ,ineff_ctrl_prcnt_1=  round((x_ineff_ctrl_attr_1	 /  decode(total_ctrl_attr_1,null,1,0,1,total_ctrl_attr_1) ) * 100,0)
     ,ineff_ctrl_prcnt_2 = round((x_ineff_ctrl_attr_2	 /  decode(total_ctrl_attr_2,null,1,0,1,total_ctrl_attr_2) ) * 100,0)
     ,ineff_ctrl_prcnt_3=  round((x_ineff_ctrl_attr_3	 /  decode(total_ctrl_attr_3,null,1,0,1,total_ctrl_attr_3) ) * 100,0)
     ,ineff_ctrl_prcnt_4=  round((x_ineff_ctrl_attr_4	 /  decode(total_ctrl_attr_4,null,1,0,1,total_ctrl_attr_4) ) * 100,0)
     ,ineff_ctrl_prcnt_5=  round((x_ineff_ctrl_attr_5	 /  decode(total_ctrl_attr_5,null,1,0,1,total_ctrl_attr_5) ) * 100,0)
     ,ineff_ctrl_prcnt_6=  round((x_ineff_ctrl_attr_6	 /  decode(total_ctrl_attr_6,null,1,0,1,total_ctrl_attr_6) ) * 100,0)
     ,ineff_ctrl_prcnt_7=  round((x_ineff_ctrl_attr_7	 /  decode(total_ctrl_attr_7,null,1,0,1,total_ctrl_attr_7) ) * 100,0)
     ,ineff_ctrl_prcnt_8=  round((x_ineff_ctrl_attr_8	 /  decode(total_ctrl_attr_8,null,1,0,1,total_ctrl_attr_8) ) * 100,0)
     ,ineff_ctrl_prcnt_9=  round((x_ineff_ctrl_attr_9	 /  decode(total_ctrl_attr_9,null,1,0,1,total_ctrl_attr_9) ) * 100,0)
     ,ineff_ctrl_prcnt_10= round((x_ineff_ctrl_attr_10 /  decode(total_ctrl_attr_10,null,1,0,1,total_ctrl_attr_10) ) * 100,0)
     ,ineff_ctrl_prcnt_11= round((x_ineff_ctrl_attr_11 /  decode(total_ctrl_attr_11,null,1,0,1,total_ctrl_attr_11) ) * 100,0)
     ,ineff_ctrl_prcnt_12= round((x_ineff_ctrl_attr_12 /  decode(total_ctrl_attr_12,null,1,0,1,total_ctrl_attr_12) ) * 100,0)
     ,ineff_ctrl_prcnt_13= round((x_ineff_ctrl_attr_13 /  decode(total_ctrl_attr_13,null,1,0,1,total_ctrl_attr_13) ) * 100,0)
     ,ineff_ctrl_prcnt_14= round((x_ineff_ctrl_attr_14 /  decode(total_ctrl_attr_14,null,1,0,1,total_ctrl_attr_14) ) * 100,0)
     ,ineff_ctrl_prcnt_15= round((x_ineff_ctrl_attr_15 /  decode(total_ctrl_attr_15,null,1,0,1,total_ctrl_attr_15) ) * 100,0)
     ,ineff_ctrl_prcnt_16= round((x_ineff_ctrl_attr_16 /  decode(total_ctrl_attr_16,null,1,0,1,total_ctrl_attr_16) ) * 100,0)
     ,ineff_ctrl_prcnt_17= round((x_ineff_ctrl_attr_17 /  decode(total_ctrl_attr_17,null,1,0,1,total_ctrl_attr_17) ) * 100,0)
     ,ineff_ctrl_prcnt_18= round((x_ineff_ctrl_attr_18 /  decode(total_ctrl_attr_18,null,1,0,1,total_ctrl_attr_18) ) * 100,0)
     ,ineff_ctrl_prcnt_19= round((x_ineff_ctrl_attr_19 /  decode(total_ctrl_attr_19,null,1,0,1,total_ctrl_attr_19) ) * 100,0)
     ,ineff_ctrl_prcnt_20= round((x_ineff_ctrl_attr_20 /  decode(total_ctrl_attr_20,null,1,0,1,total_ctrl_attr_20) ) * 100,0)
     ,ineff_ctrl_prcnt_21= round((x_ineff_ctrl_attr_21 /  decode(total_ctrl_attr_21,null,1,0,1,total_ctrl_attr_21) ) * 100,0)
     ,ineff_ctrl_prcnt_22= round((x_ineff_ctrl_attr_22 /  decode(total_ctrl_attr_22,null,1,0,1,total_ctrl_attr_22) ) * 100,0)
     ,ineff_ctrl_prcnt_23= round((x_ineff_ctrl_attr_23 /  decode(total_ctrl_attr_23,null,1,0,1,total_ctrl_attr_23) ) * 100,0)
     ,ineff_ctrl_prcnt_24= round((x_ineff_ctrl_attr_24 /  decode(total_ctrl_attr_24,null,1,0,1,total_ctrl_attr_24) ) * 100,0)
     ,ineff_ctrl_prcnt_25= round((x_ineff_ctrl_attr_25 /  decode(total_ctrl_attr_25,null,1,0,1,total_ctrl_attr_25) ) * 100,0)
     ,ineff_ctrl_prcnt_26= round((x_ineff_ctrl_attr_26 /  decode(total_ctrl_attr_26,null,1,0,1,total_ctrl_attr_26) ) * 100,0)
     ,ineff_ctrl_prcnt_27= round((x_ineff_ctrl_attr_27 /  decode(total_ctrl_attr_27,null,1,0,1,total_ctrl_attr_27) ) * 100,0)
     ,ineff_ctrl_prcnt_28= round((x_ineff_ctrl_attr_28 /  decode(total_ctrl_attr_28,null,1,0,1,total_ctrl_attr_28) ) * 100,0)
     ,ineff_ctrl_prcnt_29= round((x_ineff_ctrl_attr_29 /  decode(total_ctrl_attr_29,null,1,0,1,total_ctrl_attr_29) ) * 100,0)
     ,ineff_ctrl_prcnt_30= round((x_ineff_ctrl_attr_30 /  decode(total_ctrl_attr_30,null,1,0,1,total_ctrl_attr_30) ) * 100,0)
     ,last_updated_by           =  x_last_updated_by           ,
     last_update_date          =  x_last_update_date          ,
     last_update_login         = x_last_update_login
     ,object_version_number = object_version_number +1
where
 fin_certification_id = x_fin_certification_id and
 account_group_id =  x_account_group_id        and
 natural_account_id  =  x_natural_account_id   and
 CTRL_ATTRIBUTE_TYPE =  x_ctrl_attribute_type  and
 object_type	= x_object_type       ;

/* EXCEPTION
  WHEN OTHERS THEN
 fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
  fnd_file.put_line(fnd_file.LOG, 'natural_account_id' || x_natural_account_id );
 fnd_file.put_line(fnd_file.LOG,  'financial_item_id' || x_financial_item_id);
 fnd_file.put_line(fnd_file.LOG,  'fin_certification_id  ' || x_fin_certification_id  );


 RAISE ;
 RETURN; */

end;
end UPDATE_FIN_ACC_ASSERT_ROW ;
-- ****************************************** Business Event Subscription for Account Assertion ---------------


--*************************************************************************************************************
procedure UPDATE_FIN_ACC_ROW (
 x_fin_certification_id       	NUMBER  ,
 x_financial_statement_id    	 NUMBER ,
 x_financial_item_id         	 NUMBER ,
 x_account_group_id          	 NUMBER,
 x_natural_account_id        	 NUMBER,
 x_object_type               	 VARCHAR2,
 x_ctrl_attribute_type       	 VARCHAR2,
 x_ineff_ctrl_attr_1         	 NUMBER,
 x_ineff_ctrl_attr_2         	 NUMBER,
 x_ineff_ctrl_attr_3         	 NUMBER,
 x_ineff_ctrl_attr_4         	 NUMBER,
 x_ineff_ctrl_attr_5         	 NUMBER,
 x_ineff_ctrl_attr_6         	 NUMBER,
 x_ineff_ctrl_attr_7         	 NUMBER,
 x_ineff_ctrl_attr_8         	 NUMBER,
 x_ineff_ctrl_attr_9         	 NUMBER,
 x_ineff_ctrl_attr_10        	  NUMBER,
 x_ineff_ctrl_attr_11        	  NUMBER,
 x_ineff_ctrl_attr_12        	  NUMBER,
 x_ineff_ctrl_attr_13        	  NUMBER,
 x_ineff_ctrl_attr_14        	  NUMBER,
 x_ineff_ctrl_attr_15        	  NUMBER,
 x_ineff_ctrl_attr_16        	  NUMBER,
 x_ineff_ctrl_attr_17        	  NUMBER,
 x_ineff_ctrl_attr_18        	  NUMBER,
 x_ineff_ctrl_attr_19        	  NUMBER,
 x_ineff_ctrl_attr_20        	  NUMBER,
 x_ineff_ctrl_attr_21        	  NUMBER,
 x_ineff_ctrl_attr_22        	  NUMBER,
 x_ineff_ctrl_attr_23        	  NUMBER,
 x_ineff_ctrl_attr_24         	 NUMBER,
 x_ineff_ctrl_attr_25        	  NUMBER,
 x_ineff_ctrl_attr_26        	  NUMBER,
 x_ineff_ctrl_attr_27        	  NUMBER,
 x_ineff_ctrl_attr_28        	  NUMBER,
 x_ineff_ctrl_attr_29        	  NUMBER,
 x_ineff_ctrl_attr_30        	  NUMBER,
 x_last_updated_by           	 NUMBER,
 x_last_update_date          	 DATE ,
 x_last_update_login         	 NUMBER,
x_eval_ctrl_attr_1         	  NUMBER,
x_eval_ctrl_attr_2         	  NUMBER,
x_eval_ctrl_attr_3         	  NUMBER,
x_eval_ctrl_attr_4         	  NUMBER,
x_eval_ctrl_attr_5         	  NUMBER,
x_eval_ctrl_attr_6         	  NUMBER,
x_eval_ctrl_attr_7         	  NUMBER,
x_eval_ctrl_attr_8         	  NUMBER,
x_eval_ctrl_attr_9         	  NUMBER,
x_eval_ctrl_attr_10        	  NUMBER,
x_eval_ctrl_attr_11         	  NUMBER,
x_eval_ctrl_attr_12         	  NUMBER,
x_eval_ctrl_attr_13         	  NUMBER,
x_eval_ctrl_attr_14         	  NUMBER,
x_eval_ctrl_attr_15         	  NUMBER,
x_eval_ctrl_attr_16         	  NUMBER,
x_eval_ctrl_attr_17         	  NUMBER,
x_eval_ctrl_attr_18         	  NUMBER,
x_eval_ctrl_attr_19         	  NUMBER,
x_eval_ctrl_attr_20        	  NUMBER,
x_eval_ctrl_attr_21         	  NUMBER,
x_eval_ctrl_attr_22         	  NUMBER,
x_eval_ctrl_attr_23         	  NUMBER,
x_eval_ctrl_attr_24         	  NUMBER,
x_eval_ctrl_attr_25         	  NUMBER,
x_eval_ctrl_attr_26         	  NUMBER,
x_eval_ctrl_attr_27         	  NUMBER,
x_eval_ctrl_attr_28         	  NUMBER,
x_eval_ctrl_attr_29         	  NUMBER,
x_eval_ctrl_attr_30        	  NUMBER
) is

begin
declare
 var_fin_certification_id  number;

 begin

 --******************************************************************************************************
 -- NOTE: The values in x_ineff_ctrl_attr_(1 .. 30) may be +1 or -1 depending on the change_flag b or f respectively
 --******************************************************************************************************




  UPDATE
    amw_fin_cert_ctrl_sum
  SET
      ineff_ctrl_attr_1=  x_ineff_ctrl_attr_1
     ,ineff_ctrl_attr_2 = x_ineff_ctrl_attr_2
     ,ineff_ctrl_attr_3=  x_ineff_ctrl_attr_3
     ,ineff_ctrl_attr_4=  x_ineff_ctrl_attr_4
     ,ineff_ctrl_attr_5=  x_ineff_ctrl_attr_5
     ,ineff_ctrl_attr_6=  x_ineff_ctrl_attr_6
     ,ineff_ctrl_attr_7=  x_ineff_ctrl_attr_7
     ,ineff_ctrl_attr_8=  x_ineff_ctrl_attr_8
     ,ineff_ctrl_attr_9=  x_ineff_ctrl_attr_9
     ,ineff_ctrl_attr_10= x_ineff_ctrl_attr_10
     ,ineff_ctrl_attr_11= x_ineff_ctrl_attr_11
     ,ineff_ctrl_attr_12= x_ineff_ctrl_attr_12
     ,ineff_ctrl_attr_13= x_ineff_ctrl_attr_13
     ,ineff_ctrl_attr_14= x_ineff_ctrl_attr_14
     ,ineff_ctrl_attr_15= x_ineff_ctrl_attr_15
     ,ineff_ctrl_attr_16= x_ineff_ctrl_attr_16
     ,ineff_ctrl_attr_17= x_ineff_ctrl_attr_17
     ,ineff_ctrl_attr_18= x_ineff_ctrl_attr_18
     ,ineff_ctrl_attr_19= x_ineff_ctrl_attr_19
     ,ineff_ctrl_attr_20= x_ineff_ctrl_attr_20
     ,ineff_ctrl_attr_21= x_ineff_ctrl_attr_21
     ,ineff_ctrl_attr_22= x_ineff_ctrl_attr_22
     ,ineff_ctrl_attr_23= x_ineff_ctrl_attr_23
     ,ineff_ctrl_attr_24= x_ineff_ctrl_attr_24
     ,ineff_ctrl_attr_25= x_ineff_ctrl_attr_25
     ,ineff_ctrl_attr_26= x_ineff_ctrl_attr_26
     ,ineff_ctrl_attr_27= x_ineff_ctrl_attr_27
     ,ineff_ctrl_attr_28= x_ineff_ctrl_attr_28
     ,ineff_ctrl_attr_29= x_ineff_ctrl_attr_29
     ,ineff_ctrl_attr_30= x_ineff_ctrl_attr_30,
     eval_ctrl_attr_1    =	nvl(eval_ctrl_attr_1,0) + x_eval_ctrl_attr_1  ,
     eval_ctrl_attr_2    =	nvl(eval_ctrl_attr_2,0) + x_eval_ctrl_attr_2  ,
     eval_ctrl_attr_3    =	nvl(eval_ctrl_attr_3,0) + x_eval_ctrl_attr_3  ,
     eval_ctrl_attr_4    =	nvl(eval_ctrl_attr_4,0) + x_eval_ctrl_attr_4  ,
     eval_ctrl_attr_5    =	nvl(eval_ctrl_attr_5,0) + x_eval_ctrl_attr_5  ,
     eval_ctrl_attr_6    =	nvl(eval_ctrl_attr_6,0) + x_eval_ctrl_attr_6  ,
     eval_ctrl_attr_7    =	nvl(eval_ctrl_attr_7,0) + x_eval_ctrl_attr_7  ,
     eval_ctrl_attr_8    =	nvl(eval_ctrl_attr_8,0) + x_eval_ctrl_attr_8  ,
     eval_ctrl_attr_9    =	nvl(eval_ctrl_attr_9,0) + x_eval_ctrl_attr_9  ,
     eval_ctrl_attr_10   =	nvl(eval_ctrl_attr_10,0) +  x_eval_ctrl_attr_10  ,
     eval_ctrl_attr_11    =	nvl(eval_ctrl_attr_11,0) + x_eval_ctrl_attr_11  ,
     eval_ctrl_attr_12    =	nvl(eval_ctrl_attr_12,0) + x_eval_ctrl_attr_12  ,
     eval_ctrl_attr_13    =	nvl(eval_ctrl_attr_13,0) + x_eval_ctrl_attr_13  ,
     eval_ctrl_attr_14    =	nvl(eval_ctrl_attr_14,0) + x_eval_ctrl_attr_14  ,
     eval_ctrl_attr_15    =	nvl(eval_ctrl_attr_15,0) + x_eval_ctrl_attr_15  ,
     eval_ctrl_attr_16    =	nvl(eval_ctrl_attr_16,0) + x_eval_ctrl_attr_16  ,
     eval_ctrl_attr_17    =	nvl(eval_ctrl_attr_17,0) + x_eval_ctrl_attr_17  ,
     eval_ctrl_attr_18    =	nvl(eval_ctrl_attr_18,0) + x_eval_ctrl_attr_18  ,
     eval_ctrl_attr_19    =	nvl(eval_ctrl_attr_19,0) + x_eval_ctrl_attr_19  ,
     eval_ctrl_attr_20   =	nvl(eval_ctrl_attr_20,0) +  x_eval_ctrl_attr_20  ,
     eval_ctrl_attr_21  =	nvl(eval_ctrl_attr_21,0) + x_eval_ctrl_attr_21  ,
     eval_ctrl_attr_22    =	nvl(eval_ctrl_attr_22,0) + x_eval_ctrl_attr_22  ,
     eval_ctrl_attr_23    =	nvl(eval_ctrl_attr_23,0) + x_eval_ctrl_attr_23  ,
     eval_ctrl_attr_24    =	nvl(eval_ctrl_attr_24,0) + x_eval_ctrl_attr_24  ,
     eval_ctrl_attr_25    =	nvl(eval_ctrl_attr_25,0) + x_eval_ctrl_attr_25  ,
     eval_ctrl_attr_26    =	nvl(eval_ctrl_attr_26,0) + x_eval_ctrl_attr_26  ,
     eval_ctrl_attr_27    =	nvl(eval_ctrl_attr_27,0) + x_eval_ctrl_attr_27  ,
     eval_ctrl_attr_28    =	nvl(eval_ctrl_attr_28,0) + x_eval_ctrl_attr_28  ,
     eval_ctrl_attr_29    =	nvl(eval_ctrl_attr_29,0) + x_eval_ctrl_attr_29  ,
     eval_ctrl_attr_30   =	nvl(eval_ctrl_attr_30,0) + x_eval_ctrl_attr_30
     ,ineff_ctrl_prcnt_1=  round((x_ineff_ctrl_attr_1	 /  decode(total_ctrl_attr_1,null,1,0,1,total_ctrl_attr_1) ) * 100,0)
     ,ineff_ctrl_prcnt_2 = round((x_ineff_ctrl_attr_2	 /  decode(total_ctrl_attr_2,null,1,0,1,total_ctrl_attr_2) ) * 100,0)
     ,ineff_ctrl_prcnt_3=  round((x_ineff_ctrl_attr_3	 /  decode(total_ctrl_attr_3,null,1,0,1,total_ctrl_attr_3) ) * 100,0)
     ,ineff_ctrl_prcnt_4=  round((x_ineff_ctrl_attr_4	 /  decode(total_ctrl_attr_4,null,1,0,1,total_ctrl_attr_4) ) * 100,0)
     ,ineff_ctrl_prcnt_5=  round((x_ineff_ctrl_attr_5	 /  decode(total_ctrl_attr_5,null,1,0,1,total_ctrl_attr_5) ) * 100,0)
     ,ineff_ctrl_prcnt_6=  round((x_ineff_ctrl_attr_6	 /  decode(total_ctrl_attr_6,null,1,0,1,total_ctrl_attr_6) ) * 100,0)
     ,ineff_ctrl_prcnt_7=  round((x_ineff_ctrl_attr_7	 /  decode(total_ctrl_attr_7,null,1,0,1,total_ctrl_attr_7) ) * 100,0)
     ,ineff_ctrl_prcnt_8=  round((x_ineff_ctrl_attr_8	 /  decode(total_ctrl_attr_8,null,1,0,1,total_ctrl_attr_8) ) * 100,0)
     ,ineff_ctrl_prcnt_9=  round((x_ineff_ctrl_attr_9	 /  decode(total_ctrl_attr_9,null,1,0,1,total_ctrl_attr_9) ) * 100,0)
     ,ineff_ctrl_prcnt_10= round((x_ineff_ctrl_attr_10 /  decode(total_ctrl_attr_10,null,1,0,1,total_ctrl_attr_10) ) * 100,0)
     ,ineff_ctrl_prcnt_11= round((x_ineff_ctrl_attr_11 /  decode(total_ctrl_attr_11,null,1,0,1,total_ctrl_attr_11) ) * 100,0)
     ,ineff_ctrl_prcnt_12= round((x_ineff_ctrl_attr_12 /  decode(total_ctrl_attr_12,null,1,0,1,total_ctrl_attr_12) ) * 100,0)
     ,ineff_ctrl_prcnt_13= round((x_ineff_ctrl_attr_13 /  decode(total_ctrl_attr_13,null,1,0,1,total_ctrl_attr_13) ) * 100,0)
     ,ineff_ctrl_prcnt_14= round((x_ineff_ctrl_attr_14 /  decode(total_ctrl_attr_14,null,1,0,1,total_ctrl_attr_14) ) * 100,0)
     ,ineff_ctrl_prcnt_15= round((x_ineff_ctrl_attr_15 /  decode(total_ctrl_attr_15,null,1,0,1,total_ctrl_attr_15) ) * 100,0)
     ,ineff_ctrl_prcnt_16= round((x_ineff_ctrl_attr_16 /  decode(total_ctrl_attr_16,null,1,0,1,total_ctrl_attr_16) ) * 100,0)
     ,ineff_ctrl_prcnt_17= round((x_ineff_ctrl_attr_17 /  decode(total_ctrl_attr_17,null,1,0,1,total_ctrl_attr_17) ) * 100,0)
     ,ineff_ctrl_prcnt_18= round((x_ineff_ctrl_attr_18 /  decode(total_ctrl_attr_18,null,1,0,1,total_ctrl_attr_18) ) * 100,0)
     ,ineff_ctrl_prcnt_19= round((x_ineff_ctrl_attr_19 /  decode(total_ctrl_attr_19,null,1,0,1,total_ctrl_attr_19) ) * 100,0)
     ,ineff_ctrl_prcnt_20= round((x_ineff_ctrl_attr_20 /  decode(total_ctrl_attr_20,null,1,0,1,total_ctrl_attr_20) ) * 100,0)
     ,ineff_ctrl_prcnt_21= round((x_ineff_ctrl_attr_21 /  decode(total_ctrl_attr_21,null,1,0,1,total_ctrl_attr_21) ) * 100,0)
     ,ineff_ctrl_prcnt_22= round((x_ineff_ctrl_attr_22 /  decode(total_ctrl_attr_22,null,1,0,1,total_ctrl_attr_22) ) * 100,0)
     ,ineff_ctrl_prcnt_23= round((x_ineff_ctrl_attr_23 /  decode(total_ctrl_attr_23,null,1,0,1,total_ctrl_attr_23) ) * 100,0)
     ,ineff_ctrl_prcnt_24= round((x_ineff_ctrl_attr_24 /  decode(total_ctrl_attr_24,null,1,0,1,total_ctrl_attr_24) ) * 100,0)
     ,ineff_ctrl_prcnt_25= round((x_ineff_ctrl_attr_25 /  decode(total_ctrl_attr_25,null,1,0,1,total_ctrl_attr_25) ) * 100,0)
     ,ineff_ctrl_prcnt_26= round((x_ineff_ctrl_attr_26 /  decode(total_ctrl_attr_26,null,1,0,1,total_ctrl_attr_26) ) * 100,0)
     ,ineff_ctrl_prcnt_27= round((x_ineff_ctrl_attr_27 /  decode(total_ctrl_attr_27,null,1,0,1,total_ctrl_attr_27) ) * 100,0)
     ,ineff_ctrl_prcnt_28= round((x_ineff_ctrl_attr_28 /  decode(total_ctrl_attr_28,null,1,0,1,total_ctrl_attr_28) ) * 100,0)
     ,ineff_ctrl_prcnt_29= round((x_ineff_ctrl_attr_29 /  decode(total_ctrl_attr_29,null,1,0,1,total_ctrl_attr_29) ) * 100,0)
     ,ineff_ctrl_prcnt_30= round((x_ineff_ctrl_attr_30 /  decode(total_ctrl_attr_30,null,1,0,1,total_ctrl_attr_30) ) * 100,0)
     ,last_updated_by           =  x_last_updated_by           ,
     last_update_date          =  x_last_update_date          ,
     last_update_login         = x_last_update_login
     ,object_version_number = object_version_number +1
where
 fin_certification_id = x_fin_certification_id and
 account_group_id =  x_account_group_id        and
 natural_account_id  =  x_natural_account_id   and
 CTRL_ATTRIBUTE_TYPE =  x_ctrl_attribute_type  and
 object_type	= x_object_type       ;

/* EXCEPTION
  WHEN OTHERS THEN
 fnd_file.put_line(fnd_file.LOG, SUBSTR (SQLERRM, 1, 2000));
  fnd_file.put_line(fnd_file.LOG, 'natural_account_id' || x_natural_account_id );
 fnd_file.put_line(fnd_file.LOG,  'financial_item_id' || x_financial_item_id);
 fnd_file.put_line(fnd_file.LOG,  'fin_certification_id  ' || x_fin_certification_id  );


 RAISE ;
 RETURN; */

end;
end UPDATE_FIN_ACC_ROW;

-- ****************************************** Business Event Subscription for Account Assertion ---------------
 PROCEDURE update_acc_assert_flags
( P_ACCOUNT_ID        number ) is


begin
declare


 ctr integer :=0;
 max_num_of_codes integer :=0;
 m_ctrl_attribute_type VARCHAR2(30) :='CTRL_ASSERTIONS';

 m_assertions_code component_code_array;
 m_acc_assert_flag component_code_array;
 m_total_control  total_control_array ;

 m_cert_id number ;

 m_ineff_control  ineff_control_array ;

 v_ASSERTION_CODE varchar2(30);
 m_display_flag varchar2(1) := 'N';

 g_user_id              NUMBER        := fnd_global.user_id;
 g_login_id             NUMBER        := fnd_global.conc_login_id;
 g_errbuf               VARCHAR2(2000) := null;
 g_retcode              VARCHAR2(2)    :=  '0';

-- *************** Currsor to get all Control for the account being Passed ********** --
/*
cursor ACC_ASSERT_CODES
 is
select
ASSERTION_CODE
from
amw_account_assertions
where
NATURAL_ACCOUNT_ID =P_ACCOUNT_ID  ;
*/


M_ACCOUNT_GROUP_ID number :=0;

cursor ACC_ASSERT_CODES
 is
select
distinct
ASSERTION_CODE
from
amw_account_assertions
where
((NATURAL_ACCOUNT_ID =P_ACCOUNT_ID) or (NATURAL_ACCOUNT_ID in (select CHILD_NATURAL_ACCOUNT_ID from amw_fin_key_acct_flat
where  PARENT_NATURAL_ACCOUNT_ID  =P_ACCOUNT_ID and ACCOUNT_GROUP_ID=M_ACCOUNT_GROUP_ID)));

-----------------------------------------------------------------------------------------

M_STATEMENT_GROUP_ID NUMBER :=0;
M_STATEMENT_ID NUMBER :=0;

cursor getAccGroupID IS
select  distinct ACCOUNT_GROUP_ID from   AMW_FIN_ITEMS_KEY_ACC where   STATEMENT_GROUP_ID = M_STATEMENT_GROUP_ID
and FINANCIAL_STATEMENT_ID = M_STATEMENT_ID;

--------------------------------------------------------------------------------------------
cursor existing_codes
is
 select
 distinct
   cert.certification_id ,
   cert.STATEMENT_GROUP_ID,
   cert.FINANCIAL_STATEMENT_ID,
   ctrl_attr_code_1,
   ctrl_attr_code_2,
   ctrl_attr_code_3,
   ctrl_attr_code_4,
   ctrl_attr_code_5,
   ctrl_attr_code_6,
   ctrl_attr_code_7,
   ctrl_attr_code_8,
   ctrl_attr_code_9,
   ctrl_attr_code_10,
   ctrl_attr_code_11,
   ctrl_attr_code_12,
   ctrl_attr_code_13,
   ctrl_attr_code_14,
   ctrl_attr_code_15,
   ctrl_attr_code_16,
   ctrl_attr_code_17,
   ctrl_attr_code_18,
   ctrl_attr_code_19,
   ctrl_attr_code_20,
   ctrl_attr_code_21,
   ctrl_attr_code_22,
   ctrl_attr_code_23,
   ctrl_attr_code_24,
   ctrl_attr_code_25,
   ctrl_attr_code_26,
   ctrl_attr_code_27,
   ctrl_attr_code_28,
   ctrl_attr_code_29,
   ctrl_attr_code_30,
   ineff_ctrl_attr_1,
   ineff_ctrl_attr_2,
   ineff_ctrl_attr_3,
   ineff_ctrl_attr_4,
   ineff_ctrl_attr_5,
   ineff_ctrl_attr_6,
   ineff_ctrl_attr_7,
   ineff_ctrl_attr_8,
   ineff_ctrl_attr_9,
   ineff_ctrl_attr_10,
   ineff_ctrl_attr_11,
   ineff_ctrl_attr_12,
   ineff_ctrl_attr_13,
   ineff_ctrl_attr_14,
   ineff_ctrl_attr_15,
   ineff_ctrl_attr_16,
   ineff_ctrl_attr_17,
   ineff_ctrl_attr_18,
   ineff_ctrl_attr_19,
   ineff_ctrl_attr_20,
   ineff_ctrl_attr_21,
   ineff_ctrl_attr_22,
   ineff_ctrl_attr_23,
   ineff_ctrl_attr_24,
   ineff_ctrl_attr_25,
   ineff_ctrl_attr_26,
   ineff_ctrl_attr_27,
   ineff_ctrl_attr_28,
   ineff_ctrl_attr_29,
   ineff_ctrl_attr_30,
 total_ctrl_attr_1,
 total_ctrl_attr_2,
 total_ctrl_attr_3,
 total_ctrl_attr_4,
 total_ctrl_attr_5,
 total_ctrl_attr_6,
 total_ctrl_attr_7,
 total_ctrl_attr_8,
 total_ctrl_attr_9,
 total_ctrl_attr_10,
 total_ctrl_attr_11,
 total_ctrl_attr_12,
 total_ctrl_attr_13,
 total_ctrl_attr_14,
 total_ctrl_attr_15,
 total_ctrl_attr_16,
 total_ctrl_attr_17,
 total_ctrl_attr_18,
 total_ctrl_attr_19,
 total_ctrl_attr_20,
 total_ctrl_attr_21,
 total_ctrl_attr_22,
 total_ctrl_attr_23,
 total_ctrl_attr_24,
 total_ctrl_attr_25,
 total_ctrl_attr_26,
 total_ctrl_attr_27,
 total_ctrl_attr_28,
 total_ctrl_attr_29,
 total_ctrl_attr_30
from
  amw_certification_vl cert,
 amw_fin_cert_ctrl_sum ctrlsum
where
 cert.certification_id = ctrlsum.fin_certification_id and
 ctrl_attribute_type = 'CTRL_ASSERTIONS'
and
(CERTIFICATION_STATUS= 'ACTIVE' or CERTIFICATION_STATUS= 'DRAFT')
and cert.OBJECT_TYPE ='FIN_STMT' AND
ctrlsum.OBJECT_TYPE='ACCOUNT' AND
ctrlsum.NATURAL_ACCOUNT_ID=P_ACCOUNT_ID ;




BEGIN

 --m_assertions_code := null;
 --ctr := 0;


 -- ************ Since the Table has 30 Fileds only initialize 30 Positios in the Array**************--

 for load_current_codes in existing_codes
 loop
    exit when existing_codes%notfound;

    ctr :=  1;

    loop -- for each certification initialize the array
     EXIT WHEN ctr > 30;

      m_assertions_code(ctr) := null;
      m_acc_assert_flag(ctr) := 'I'; -- make ignore as the default and make it Y or N based on the interest of the Account on Assertion
      m_ineff_control(ctr) :=0;
      ctr := ctr + 1;

    end loop; --end of initialization


   m_assertions_code(1) :=  load_current_codes.ctrl_attr_code_1;
   m_assertions_code(2) :=  load_current_codes.ctrl_attr_code_2;
   m_assertions_code(3) :=  load_current_codes.ctrl_attr_code_3;
   m_assertions_code(4) :=   load_current_codes.ctrl_attr_code_4;
   m_assertions_code(5) :=load_current_codes.ctrl_attr_code_5;
   m_assertions_code(6) :=load_current_codes.ctrl_attr_code_6;
   m_assertions_code(7) :=load_current_codes.ctrl_attr_code_7;
   m_assertions_code(8) :=load_current_codes.ctrl_attr_code_8;
   m_assertions_code(9) :=load_current_codes.ctrl_attr_code_9;
   m_assertions_code(10) :=load_current_codes.ctrl_attr_code_10;
   m_assertions_code(11) :=load_current_codes.ctrl_attr_code_11;
   m_assertions_code(12) :=load_current_codes.ctrl_attr_code_12;
   m_assertions_code(13) :=load_current_codes.ctrl_attr_code_13;
   m_assertions_code(14) :=load_current_codes.ctrl_attr_code_14;
   m_assertions_code(15) :=load_current_codes.ctrl_attr_code_15;
   m_assertions_code(16) :=load_current_codes.ctrl_attr_code_16;
   m_assertions_code(17) :=load_current_codes.ctrl_attr_code_17;
   m_assertions_code(18) :=load_current_codes.ctrl_attr_code_18;
   m_assertions_code(19) :=load_current_codes.ctrl_attr_code_19;
   m_assertions_code(20) :=load_current_codes.ctrl_attr_code_20;
   m_assertions_code(21) :=load_current_codes.ctrl_attr_code_21;
   m_assertions_code(22) :=load_current_codes.ctrl_attr_code_22;
   m_assertions_code(23) :=load_current_codes.ctrl_attr_code_23;
   m_assertions_code(24) :=load_current_codes.ctrl_attr_code_24;
   m_assertions_code(25) :=load_current_codes.ctrl_attr_code_25;
   m_assertions_code(26) :=load_current_codes.ctrl_attr_code_26;
   m_assertions_code(27) :=load_current_codes.ctrl_attr_code_27;
   m_assertions_code(28) :=load_current_codes.ctrl_attr_code_28;
   m_assertions_code(29) :=load_current_codes.ctrl_attr_code_29;
   m_assertions_code(30) :=load_current_codes.ctrl_attr_code_30;

   m_ineff_control(1) :=  load_current_codes.ineff_ctrl_attr_1;
   m_ineff_control(2) :=  load_current_codes.ineff_ctrl_attr_2;
   m_ineff_control(3) :=  load_current_codes.ineff_ctrl_attr_3;
   m_ineff_control(4) :=   load_current_codes.ineff_ctrl_attr_4;
   m_ineff_control(5) :=load_current_codes.ineff_ctrl_attr_5;
   m_ineff_control(6) :=load_current_codes.ineff_ctrl_attr_6;
   m_ineff_control(7) :=load_current_codes.ineff_ctrl_attr_7;
   m_ineff_control(8) :=load_current_codes.ineff_ctrl_attr_8;
   m_ineff_control(9) :=load_current_codes.ineff_ctrl_attr_9;
   m_ineff_control(10) :=load_current_codes.ineff_ctrl_attr_10;
   m_ineff_control(11) :=load_current_codes.ineff_ctrl_attr_11;
   m_ineff_control(12) :=load_current_codes.ineff_ctrl_attr_12;
   m_ineff_control(13) :=load_current_codes.ineff_ctrl_attr_13;
   m_ineff_control(14) :=load_current_codes.ineff_ctrl_attr_14;
   m_ineff_control(15) :=load_current_codes.ineff_ctrl_attr_15;
   m_ineff_control(16) :=load_current_codes.ineff_ctrl_attr_16;
   m_ineff_control(17) :=load_current_codes.ineff_ctrl_attr_17;
   m_ineff_control(18) :=load_current_codes.ineff_ctrl_attr_18;
   m_ineff_control(19) :=load_current_codes.ineff_ctrl_attr_19;
   m_ineff_control(20) :=load_current_codes.ineff_ctrl_attr_20;
   m_ineff_control(21) :=load_current_codes.ineff_ctrl_attr_21;
   m_ineff_control(22) :=load_current_codes.ineff_ctrl_attr_22;
   m_ineff_control(23) :=load_current_codes.ineff_ctrl_attr_23;
   m_ineff_control(24) :=load_current_codes.ineff_ctrl_attr_24;
   m_ineff_control(25) :=load_current_codes.ineff_ctrl_attr_25;
   m_ineff_control(26) :=load_current_codes.ineff_ctrl_attr_26;
   m_ineff_control(27) :=load_current_codes.ineff_ctrl_attr_27;
   m_ineff_control(28) :=load_current_codes.ineff_ctrl_attr_28;
   m_ineff_control(29) :=load_current_codes.ineff_ctrl_attr_29;
   m_ineff_control(30) :=load_current_codes.ineff_ctrl_attr_30;

 m_total_control(1) := load_current_codes.total_ctrl_attr_1;
 m_total_control(2) :=  load_current_codes.total_ctrl_attr_2;
 m_total_control(3) := load_current_codes.total_ctrl_attr_3;
 m_total_control(4) := load_current_codes.total_ctrl_attr_4;
 m_total_control(5) := load_current_codes.total_ctrl_attr_5;
 m_total_control(6) := load_current_codes.total_ctrl_attr_6;
 m_total_control(7) := load_current_codes.total_ctrl_attr_7;
 m_total_control(8) := load_current_codes.total_ctrl_attr_8;
 m_total_control(9) := load_current_codes.total_ctrl_attr_9;
 m_total_control(10) := load_current_codes.total_ctrl_attr_10;
 m_total_control(11) := load_current_codes.total_ctrl_attr_11;
 m_total_control(12) := load_current_codes.total_ctrl_attr_12;
 m_total_control(13) := load_current_codes.total_ctrl_attr_13;
 m_total_control(14) := load_current_codes.total_ctrl_attr_14;
 m_total_control(15) := load_current_codes.total_ctrl_attr_15;
 m_total_control(16) := load_current_codes.total_ctrl_attr_16;
 m_total_control(17) := load_current_codes.total_ctrl_attr_17;
 m_total_control(18) := load_current_codes.total_ctrl_attr_18;
 m_total_control(19) := load_current_codes.total_ctrl_attr_19;
 m_total_control(20) := load_current_codes.total_ctrl_attr_20;
 m_total_control(21) := load_current_codes.total_ctrl_attr_21;
 m_total_control(22) := load_current_codes.total_ctrl_attr_22;
 m_total_control(23) := load_current_codes.total_ctrl_attr_23;
 m_total_control(24) := load_current_codes.total_ctrl_attr_24;
 m_total_control(25) := load_current_codes.total_ctrl_attr_25;
 m_total_control(26) := load_current_codes.total_ctrl_attr_26;
 m_total_control(27) := load_current_codes.total_ctrl_attr_27;
 m_total_control(28) := load_current_codes.total_ctrl_attr_28;
 m_total_control(29) := load_current_codes.total_ctrl_attr_29;
 m_total_control(30) := load_current_codes.total_ctrl_attr_30;

 m_cert_id :=load_current_codes.certification_id ;
 M_STATEMENT_GROUP_ID := load_current_codes.STATEMENT_GROUP_ID;
 M_STATEMENT_ID := load_current_codes.FINANCIAL_STATEMENT_ID;
 -------------------------------------------------------------------------------------
 --  JUST GET THE ACCOUNT GROUP FOR THE CERTIFICATION --

  for acc_group in getAccGroupID
  loop
      exit when getAccGroupID%notfound;
      M_ACCOUNT_GROUP_ID := acc_group.ACCOUNT_GROUP_ID ;

   end loop; --end of acc_group in getAccGroupID

  -------------------------------------------------------------

  for acc_assertions in ACC_ASSERT_CODES
  loop
      exit when ACC_ASSERT_CODES%notfound;

      ctr := 1;
      while ctr <=  30
      loop
          if (m_assertions_code(ctr) =  acc_assertions.ASSERTION_CODE  ) then

             if nvl(m_ineff_control(ctr),0) > 0  then

                   m_acc_assert_flag(ctr) := 'Y';

                --************************************************************************************************** --
                -- else if the assertion is important for one of the accounts of fin. Item and No controls exist for the
                --  processes associated with the accounts then set the flag to 'Y', based on which an image will
                --- appear in UI
                --************************************************************************************************** --

                 elsif (nvl(m_total_control(ctr),0) = 0) then

                   m_acc_assert_flag(ctr) := 'Y';


                 --- ********** ie assertion is Not important for any of the accounts of fin. Item  and(nvl(m_total_control(ctr),0) > 0)
                 else
                    m_acc_assert_flag(ctr) := 'N';

                 end if;


             --m_acc_assert_flag(ctr) := 'Y';
             exit;

           end if;
           ctr := ctr +1;
      end loop;
   end loop; --end of acc_assertions in ACC_ASSERT_CODES
 ---------------------------------------------------------------------------------------------

    if set_flag_for_assertions( assert_acc_reln_exist=>  m_acc_assert_flag) then

        m_display_flag := 'Y';
     else
        m_display_flag := 'N';
     end if;


 ---------------------------------------------------------------------------------------------

    amw_fin_coso_views_pvt.UPDATE_CTRLSUM_FLAG(
     x_fin_certification_id       	=> 	m_cert_id   	,
     x_natural_account_id        	=> 	P_ACCOUNT_ID        	,
     x_ctrl_attribute_type       	=> 	m_ctrl_attribute_type       	,
     x_created_by                	=> 	g_user_id	,
     x_creation_date             	=> 	SYSDATE	,
     x_last_updated_by           	=> 	g_user_id	,
     x_last_update_date          	=> 	SYSDATE	,
     x_last_update_login         	=> 	g_login_id	,
    -- x_object_version_number     	=> 	null,
     x_acc_assert_flag1         	=> 	m_acc_assert_flag(1),
     x_acc_assert_flag2         	=> 	m_acc_assert_flag(2),
     x_acc_assert_flag3         	=> 	m_acc_assert_flag(3),
     x_acc_assert_flag4         	=> 	m_acc_assert_flag(4),
     x_acc_assert_flag5         	=> 	m_acc_assert_flag(5),
     x_acc_assert_flag6         	=> 	m_acc_assert_flag(6),
     x_acc_assert_flag7         	=> 	m_acc_assert_flag(7),
     x_acc_assert_flag8         	=> 	m_acc_assert_flag(8),
     x_acc_assert_flag9         	=> 	m_acc_assert_flag(9),
     x_acc_assert_flag10        	=> 	m_acc_assert_flag(10),
     x_acc_assert_flag11         	=> 	m_acc_assert_flag(11),
     x_acc_assert_flag12         	=> 	m_acc_assert_flag(12),
     x_acc_assert_flag13         	=> 	m_acc_assert_flag(13),
     x_acc_assert_flag14         	=> 	m_acc_assert_flag(14),
     x_acc_assert_flag15         	=> 	m_acc_assert_flag(15),
     x_acc_assert_flag16         	=> 	m_acc_assert_flag(16),
     x_acc_assert_flag17         	=> 	m_acc_assert_flag(17),
     x_acc_assert_flag18         	=> 	m_acc_assert_flag(18),
     x_acc_assert_flag19         	=> 	m_acc_assert_flag(19),
     x_acc_assert_flag20        	=> 	m_acc_assert_flag(20),
     x_acc_assert_flag21         	=> 	m_acc_assert_flag(21),
     x_acc_assert_flag22         	=> 	m_acc_assert_flag(22),
     x_acc_assert_flag23         	=> 	m_acc_assert_flag(23),
     x_acc_assert_flag24         	=> 	m_acc_assert_flag(24),
     x_acc_assert_flag25         	=> 	m_acc_assert_flag(25),
     x_acc_assert_flag26         	=> 	m_acc_assert_flag(26),
     x_acc_assert_flag27         	=> 	m_acc_assert_flag(27),
     x_acc_assert_flag28         	=> 	m_acc_assert_flag(28),
     x_acc_assert_flag29         	=> 	m_acc_assert_flag(29),
     x_acc_assert_flag30        	=> 	m_acc_assert_flag(30),
     x_display_flag                     =>      m_display_flag  );

 -------------------------------------------------------------------------------------

  amw_fin_coso_views_pvt.update_parentacc_assert_flags
  (P_ACCOUNT_ID        =>P_ACCOUNT_ID  ,
  P_CERTFICATION_ID => 	m_cert_id   	,
  P_ACCOUNT_GROUP_ID => M_ACCOUNT_GROUP_ID);

 -------------------------------------------------------------------------------------

  amw_fin_coso_views_pvt.update_item_assert_flags
  ( P_NATRL_ACCOUNT_ID => P_ACCOUNT_ID  );

 ---------------------------------------------------------------------------------------
 end loop; -- end of load_current_codes loop

 EXCEPTION
     WHEN NO_DATA_FOUND
	     THEN
            fnd_file.put_line (fnd_file.LOG, SUBSTR ('No data found in Update_Next_Level_Proc_Info'
                || SUBSTR (SQLERRM, 1, 100), 1, 200));

     WHEN OTHERS
         THEN
            fnd_file.put_line (fnd_file.LOG, SUBSTR ('Unexpected Error in Update_Next_Level_Proc_Info'
                || SUBSTR (SQLERRM, 1, 100), 1, 200));

---COMMIT;
end;
end ; -- update_acc_assert_flags

-- ************************************************************************************************************* --


PROCEDURE update_item_assert_flags
( P_NATRL_ACCOUNT_ID        number ) is


begin
declare


 ctr integer :=0;
 max_num_of_codes integer :=0;
 m_ctrl_attribute_type VARCHAR2(30) :='CTRL_ASSERTIONS';

 m_assertions_code component_code_array;
 m_acc_assert_flag component_code_array;
 m_total_control  total_control_array ;

 m_cert_id number ;
m_fin_item_id number ;
 m_ineff_control  ineff_control_array ;
m_display_flag varchar2(1) := 'N';

 v_ASSERTION_CODE varchar2(30);

 g_user_id              NUMBER        := fnd_global.user_id;
 g_login_id             NUMBER        := fnd_global.conc_login_id;
 g_errbuf               VARCHAR2(2000) := null;
 g_retcode              VARCHAR2(2)    :=  '0';


----------------------------------------------------------------------------------------------------------
-- First find out all the Financial Certifications (Not Closed) and the Financial Items in that which are
-- assoicated with the account (then in another cursor select all the accounts for the financial items and
-- then get the Assertion Codes. (e.g an Assertion might have been removed from the Account but its parent
-- financial item might still have anothe account which has mapped to that assertion, in which case the Image
-- flags has to be maintened. If no Accounts mapped to the Item have association to the assertion then that
-- column can be updated with ignore flag. For a Financial Item, this cannot be derived only by looking at
-- the account - assertion being changed.
----------------------------------------------------------------------------------------------------------
cursor existing_codes
is
 select
 distinct
   cert.certification_id ,
   ctrlsum.financial_item_id,
   ctrl_attr_code_1,
   ctrl_attr_code_2,
   ctrl_attr_code_3,
   ctrl_attr_code_4,
   ctrl_attr_code_5,
   ctrl_attr_code_6,
   ctrl_attr_code_7,
   ctrl_attr_code_8,
   ctrl_attr_code_9,
   ctrl_attr_code_10,
   ctrl_attr_code_11,
   ctrl_attr_code_12,
   ctrl_attr_code_13,
   ctrl_attr_code_14,
   ctrl_attr_code_15,
   ctrl_attr_code_16,
   ctrl_attr_code_17,
   ctrl_attr_code_18,
   ctrl_attr_code_19,
   ctrl_attr_code_20,
   ctrl_attr_code_21,
   ctrl_attr_code_22,
   ctrl_attr_code_23,
   ctrl_attr_code_24,
   ctrl_attr_code_25,
   ctrl_attr_code_26,
   ctrl_attr_code_27,
   ctrl_attr_code_28,
   ctrl_attr_code_29,
   ctrl_attr_code_30,
   ineff_ctrl_attr_1,
   ineff_ctrl_attr_2,
   ineff_ctrl_attr_3,
   ineff_ctrl_attr_4,
   ineff_ctrl_attr_5,
   ineff_ctrl_attr_6,
   ineff_ctrl_attr_7,
   ineff_ctrl_attr_8,
   ineff_ctrl_attr_9,
   ineff_ctrl_attr_10,
   ineff_ctrl_attr_11,
   ineff_ctrl_attr_12,
   ineff_ctrl_attr_13,
   ineff_ctrl_attr_14,
   ineff_ctrl_attr_15,
   ineff_ctrl_attr_16,
   ineff_ctrl_attr_17,
   ineff_ctrl_attr_18,
   ineff_ctrl_attr_19,
   ineff_ctrl_attr_20,
   ineff_ctrl_attr_21,
   ineff_ctrl_attr_22,
   ineff_ctrl_attr_23,
   ineff_ctrl_attr_24,
   ineff_ctrl_attr_25,
   ineff_ctrl_attr_26,
   ineff_ctrl_attr_27,
   ineff_ctrl_attr_28,
   ineff_ctrl_attr_29,
   ineff_ctrl_attr_30,
 total_ctrl_attr_1,
 total_ctrl_attr_2,
 total_ctrl_attr_3,
 total_ctrl_attr_4,
 total_ctrl_attr_5,
 total_ctrl_attr_6,
 total_ctrl_attr_7,
 total_ctrl_attr_8,
 total_ctrl_attr_9,
 total_ctrl_attr_10,
 total_ctrl_attr_11,
 total_ctrl_attr_12,
 total_ctrl_attr_13,
 total_ctrl_attr_14,
 total_ctrl_attr_15,
 total_ctrl_attr_16,
 total_ctrl_attr_17,
 total_ctrl_attr_18,
 total_ctrl_attr_19,
 total_ctrl_attr_20,
 total_ctrl_attr_21,
 total_ctrl_attr_22,
 total_ctrl_attr_23,
 total_ctrl_attr_24,
 total_ctrl_attr_25,
 total_ctrl_attr_26,
 total_ctrl_attr_27,
 total_ctrl_attr_28,
 total_ctrl_attr_29,
 total_ctrl_attr_30
from
  amw_certification_vl cert,
 amw_fin_cert_ctrl_sum ctrlsum,
  amw_fin_cert_scope scope
where
 cert.certification_id = ctrlsum.fin_certification_id and
 ctrl_attribute_type = 'CTRL_ASSERTIONS'
and
(CERTIFICATION_STATUS= 'ACTIVE' or CERTIFICATION_STATUS= 'DRAFT')
and cert.OBJECT_TYPE ='FIN_STMT'
and ctrlsum.object_type='FINANCIAL ITEM'
and scope.fin_certification_id = ctrlsum.fin_certification_id
and scope.NATURAL_ACCOUNT_ID = P_NATRL_ACCOUNT_ID
AND SCOPE.financial_item_id = ctrlsum.financial_item_id ;

-- *************** Currsor to get all Control for the Fianancial Item being Passed ********** --


cursor ACC_ASSERT_FOR_FIN_ITEM(P_CERTIFICATION_ID  NUMBER, P_FINANCIAL_ITEM_ID NUMBER)
 is
select DISTINCT
ASSERTION_CODE
from
amw_account_assertions
where
NATURAL_ACCOUNT_ID IN
(select DISTINCT NATURAL_ACCOUNT_ID from amw_fin_cert_scope where fin_certification_id = P_CERTIFICATION_ID and
financial_item_id = P_FINANCIAL_ITEM_ID  );
----------------------------------------------------------------------------------------------
BEGIN

 --m_assertions_code := null;
 --ctr := 0;


 -- ************ Since the Table has 30 Fileds only initialize 30 Positios in the Array**************--

 for load_current_codes in existing_codes
 loop
    exit when existing_codes%notfound;

    ctr :=  1;

    loop -- for each certification initialize the array
     EXIT WHEN ctr > 30;

      m_assertions_code(ctr) := null;
      m_acc_assert_flag(ctr) := 'I'; -- make ignore as the default and make it Y or N based on the interest of the Account on Assertion
      m_ineff_control(ctr) :=0;
      ctr := ctr + 1;

    end loop; --end of initialization


   m_assertions_code(1) :=  load_current_codes.ctrl_attr_code_1;
   m_assertions_code(2) :=  load_current_codes.ctrl_attr_code_2;
   m_assertions_code(3) :=  load_current_codes.ctrl_attr_code_3;
   m_assertions_code(4) :=   load_current_codes.ctrl_attr_code_4;
   m_assertions_code(5) :=load_current_codes.ctrl_attr_code_5;
   m_assertions_code(6) :=load_current_codes.ctrl_attr_code_6;
   m_assertions_code(7) :=load_current_codes.ctrl_attr_code_7;
   m_assertions_code(8) :=load_current_codes.ctrl_attr_code_8;
   m_assertions_code(9) :=load_current_codes.ctrl_attr_code_9;
   m_assertions_code(10) :=load_current_codes.ctrl_attr_code_10;
   m_assertions_code(11) :=load_current_codes.ctrl_attr_code_11;
   m_assertions_code(12) :=load_current_codes.ctrl_attr_code_12;
   m_assertions_code(13) :=load_current_codes.ctrl_attr_code_13;
   m_assertions_code(14) :=load_current_codes.ctrl_attr_code_14;
   m_assertions_code(15) :=load_current_codes.ctrl_attr_code_15;
   m_assertions_code(16) :=load_current_codes.ctrl_attr_code_16;
   m_assertions_code(17) :=load_current_codes.ctrl_attr_code_17;
   m_assertions_code(18) :=load_current_codes.ctrl_attr_code_18;
   m_assertions_code(19) :=load_current_codes.ctrl_attr_code_19;
   m_assertions_code(20) :=load_current_codes.ctrl_attr_code_20;
   m_assertions_code(21) :=load_current_codes.ctrl_attr_code_21;
   m_assertions_code(22) :=load_current_codes.ctrl_attr_code_22;
   m_assertions_code(23) :=load_current_codes.ctrl_attr_code_23;
   m_assertions_code(24) :=load_current_codes.ctrl_attr_code_24;
   m_assertions_code(25) :=load_current_codes.ctrl_attr_code_25;
   m_assertions_code(26) :=load_current_codes.ctrl_attr_code_26;
   m_assertions_code(27) :=load_current_codes.ctrl_attr_code_27;
   m_assertions_code(28) :=load_current_codes.ctrl_attr_code_28;
   m_assertions_code(29) :=load_current_codes.ctrl_attr_code_29;
   m_assertions_code(30) :=load_current_codes.ctrl_attr_code_30;

   m_ineff_control(1) :=  load_current_codes.ineff_ctrl_attr_1;
   m_ineff_control(2) :=  load_current_codes.ineff_ctrl_attr_2;
   m_ineff_control(3) :=  load_current_codes.ineff_ctrl_attr_3;
   m_ineff_control(4) :=   load_current_codes.ineff_ctrl_attr_4;
   m_ineff_control(5) :=load_current_codes.ineff_ctrl_attr_5;
   m_ineff_control(6) :=load_current_codes.ineff_ctrl_attr_6;
   m_ineff_control(7) :=load_current_codes.ineff_ctrl_attr_7;
   m_ineff_control(8) :=load_current_codes.ineff_ctrl_attr_8;
   m_ineff_control(9) :=load_current_codes.ineff_ctrl_attr_9;
   m_ineff_control(10) :=load_current_codes.ineff_ctrl_attr_10;
   m_ineff_control(11) :=load_current_codes.ineff_ctrl_attr_11;
   m_ineff_control(12) :=load_current_codes.ineff_ctrl_attr_12;
   m_ineff_control(13) :=load_current_codes.ineff_ctrl_attr_13;
   m_ineff_control(14) :=load_current_codes.ineff_ctrl_attr_14;
   m_ineff_control(15) :=load_current_codes.ineff_ctrl_attr_15;
   m_ineff_control(16) :=load_current_codes.ineff_ctrl_attr_16;
   m_ineff_control(17) :=load_current_codes.ineff_ctrl_attr_17;
   m_ineff_control(18) :=load_current_codes.ineff_ctrl_attr_18;
   m_ineff_control(19) :=load_current_codes.ineff_ctrl_attr_19;
   m_ineff_control(20) :=load_current_codes.ineff_ctrl_attr_20;
   m_ineff_control(21) :=load_current_codes.ineff_ctrl_attr_21;
   m_ineff_control(22) :=load_current_codes.ineff_ctrl_attr_22;
   m_ineff_control(23) :=load_current_codes.ineff_ctrl_attr_23;
   m_ineff_control(24) :=load_current_codes.ineff_ctrl_attr_24;
   m_ineff_control(25) :=load_current_codes.ineff_ctrl_attr_25;
   m_ineff_control(26) :=load_current_codes.ineff_ctrl_attr_26;
   m_ineff_control(27) :=load_current_codes.ineff_ctrl_attr_27;
   m_ineff_control(28) :=load_current_codes.ineff_ctrl_attr_28;
   m_ineff_control(29) :=load_current_codes.ineff_ctrl_attr_29;
   m_ineff_control(30) :=load_current_codes.ineff_ctrl_attr_30;

 m_total_control(1) := load_current_codes.total_ctrl_attr_1;
 m_total_control(2) :=  load_current_codes.total_ctrl_attr_2;
 m_total_control(3) := load_current_codes.total_ctrl_attr_3;
 m_total_control(4) := load_current_codes.total_ctrl_attr_4;
 m_total_control(5) := load_current_codes.total_ctrl_attr_5;
 m_total_control(6) := load_current_codes.total_ctrl_attr_6;
 m_total_control(7) := load_current_codes.total_ctrl_attr_7;
 m_total_control(8) := load_current_codes.total_ctrl_attr_8;
 m_total_control(9) := load_current_codes.total_ctrl_attr_9;
 m_total_control(10) := load_current_codes.total_ctrl_attr_10;
 m_total_control(11) := load_current_codes.total_ctrl_attr_11;
 m_total_control(12) := load_current_codes.total_ctrl_attr_12;
 m_total_control(13) := load_current_codes.total_ctrl_attr_13;
 m_total_control(14) := load_current_codes.total_ctrl_attr_14;
 m_total_control(15) := load_current_codes.total_ctrl_attr_15;
 m_total_control(16) := load_current_codes.total_ctrl_attr_16;
 m_total_control(17) := load_current_codes.total_ctrl_attr_17;
 m_total_control(18) := load_current_codes.total_ctrl_attr_18;
 m_total_control(19) := load_current_codes.total_ctrl_attr_19;
 m_total_control(20) := load_current_codes.total_ctrl_attr_20;
 m_total_control(21) := load_current_codes.total_ctrl_attr_21;
 m_total_control(22) := load_current_codes.total_ctrl_attr_22;
 m_total_control(23) := load_current_codes.total_ctrl_attr_23;
 m_total_control(24) := load_current_codes.total_ctrl_attr_24;
 m_total_control(25) := load_current_codes.total_ctrl_attr_25;
 m_total_control(26) := load_current_codes.total_ctrl_attr_26;
 m_total_control(27) := load_current_codes.total_ctrl_attr_27;
 m_total_control(28) := load_current_codes.total_ctrl_attr_28;
 m_total_control(29) := load_current_codes.total_ctrl_attr_29;
 m_total_control(30) := load_current_codes.total_ctrl_attr_30;


   m_cert_id :=load_current_codes.certification_id ;
   m_fin_item_id := load_current_codes.financial_item_id;


 -------------------------------------------------------------------------------------

 end loop; -- end of load_current_codes loop


   for acc_assertions  in ACC_ASSERT_FOR_FIN_ITEM(m_cert_id , m_fin_item_id )
   loop
       exit when ACC_ASSERT_FOR_FIN_ITEM%notfound;
      ctr := 1;
      while ctr <=  30
      loop
          if (m_assertions_code(ctr) =  acc_assertions.ASSERTION_CODE  ) then

             if nvl(m_ineff_control(ctr),0) > 0  then

                   m_acc_assert_flag(ctr) := 'Y';

                --************************************************************************************************** --
                -- else if the assertion is important for one of the accounts of fin. Item and No controls exist for the
                --  processes associated with the accounts then set the flag to 'Y', based on which an image will
                --- appear in UI
                --************************************************************************************************** --

                 elsif (nvl(m_total_control(ctr),0) = 0) then

                   m_acc_assert_flag(ctr) := 'Y';


                 --- ********** ie assertion is Not important for any of the accounts of fin. Item  and(nvl(m_total_control(ctr),0) > 0)
                 else
                    m_acc_assert_flag(ctr) := 'N';

                 end if;


             --m_acc_assert_flag(ctr) := 'Y';
             exit;

           end if;
           ctr := ctr +1;
      end loop;
   end loop; --end of acc_assertions in ACC_ASSERT_FOR_FIN_ITEM
 ---------------------------------------------------------------------------------------------

    if set_flag_for_assertions( assert_acc_reln_exist=>  m_acc_assert_flag) then

        m_display_flag := 'Y';
     else
        m_display_flag := 'N';
     end if;


 ---------------------------------------------------------------------------------------------
    amw_fin_coso_views_pvt.UPDATE_CTRLSUM_ITEM_FLAG(
     x_fin_certification_id       	=> 	m_cert_id   	,
     x_financial_item_id         	=> 	m_fin_item_id   		,
     x_ctrl_attribute_type       	=> 	m_ctrl_attribute_type ,
     x_created_by                	=> 	g_user_id	,
     x_creation_date             	=> 	SYSDATE	,
     x_last_updated_by           	=> 	g_user_id	,
     x_last_update_date          	=> 	SYSDATE	,
     x_last_update_login         	=> 	g_login_id	,
    -- x_object_version_number     	=> 	null,
     x_acc_assert_flag1         	=> 	m_acc_assert_flag(1),
     x_acc_assert_flag2         	=> 	m_acc_assert_flag(2),
     x_acc_assert_flag3         	=> 	m_acc_assert_flag(3),
     x_acc_assert_flag4         	=> 	m_acc_assert_flag(4),
     x_acc_assert_flag5         	=> 	m_acc_assert_flag(5),
     x_acc_assert_flag6         	=> 	m_acc_assert_flag(6),
     x_acc_assert_flag7         	=> 	m_acc_assert_flag(7),
     x_acc_assert_flag8         	=> 	m_acc_assert_flag(8),
     x_acc_assert_flag9         	=> 	m_acc_assert_flag(9),
     x_acc_assert_flag10        	=> 	m_acc_assert_flag(10),
     x_acc_assert_flag11         	=> 	m_acc_assert_flag(11),
     x_acc_assert_flag12         	=> 	m_acc_assert_flag(12),
     x_acc_assert_flag13         	=> 	m_acc_assert_flag(13),
     x_acc_assert_flag14         	=> 	m_acc_assert_flag(14),
     x_acc_assert_flag15         	=> 	m_acc_assert_flag(15),
     x_acc_assert_flag16         	=> 	m_acc_assert_flag(16),
     x_acc_assert_flag17         	=> 	m_acc_assert_flag(17),
     x_acc_assert_flag18         	=> 	m_acc_assert_flag(18),
     x_acc_assert_flag19         	=> 	m_acc_assert_flag(19),
     x_acc_assert_flag20        	=> 	m_acc_assert_flag(20),
     x_acc_assert_flag21         	=> 	m_acc_assert_flag(21),
     x_acc_assert_flag22         	=> 	m_acc_assert_flag(22),
     x_acc_assert_flag23         	=> 	m_acc_assert_flag(23),
     x_acc_assert_flag24         	=> 	m_acc_assert_flag(24),
     x_acc_assert_flag25         	=> 	m_acc_assert_flag(25),
     x_acc_assert_flag26         	=> 	m_acc_assert_flag(26),
     x_acc_assert_flag27         	=> 	m_acc_assert_flag(27),
     x_acc_assert_flag28         	=> 	m_acc_assert_flag(28),
     x_acc_assert_flag29         	=> 	m_acc_assert_flag(29),
     x_acc_assert_flag30        	=> 	m_acc_assert_flag(30),
     x_display_flag                     =>      m_display_flag  );


 EXCEPTION
     WHEN NO_DATA_FOUND
	     THEN
            fnd_file.put_line (fnd_file.LOG, SUBSTR ('No data found in Update_Next_Level_Proc_Info'
                || SUBSTR (SQLERRM, 1, 100), 1, 200));

     WHEN OTHERS
         THEN
            fnd_file.put_line (fnd_file.LOG, SUBSTR ('Unexpected Error in Update_Next_Level_Proc_Info'
                || SUBSTR (SQLERRM, 1, 100), 1, 200));

---COMMIT;
end;
end ; -- update_item_assert_flags
/* ******************************************* UPDATE_ACC_ASSERT_FLAG ************************************************************* */

procedure UPDATE_CTRLSUM_ITEM_FLAG(

 x_fin_certification_id       	NUMBER  ,
 x_financial_item_id         	 NUMBER ,
 x_ctrl_attribute_type       	varchar2,
 x_created_by             number ,
 x_creation_date          date   	,
 x_last_updated_by        number   	,
 x_last_update_date       date,
 x_last_update_login      number   	,
 x_acc_assert_flag1         	  VARCHAR2,
 x_acc_assert_flag2         	  VARCHAR2,
 x_acc_assert_flag3         	  VARCHAR2,
 x_acc_assert_flag4         	  VARCHAR2,
 x_acc_assert_flag5         	  VARCHAR2,
 x_acc_assert_flag6         	  VARCHAR2,
 x_acc_assert_flag7         	  VARCHAR2,
 x_acc_assert_flag8         	  VARCHAR2,
 x_acc_assert_flag9         	  VARCHAR2,
 x_acc_assert_flag10        	  VARCHAR2,
 x_acc_assert_flag11         	  VARCHAR2,
 x_acc_assert_flag12         	  VARCHAR2,
 x_acc_assert_flag13         	  VARCHAR2,
 x_acc_assert_flag14         	  VARCHAR2,
 x_acc_assert_flag15         	  VARCHAR2,
 x_acc_assert_flag16         	  VARCHAR2,
 x_acc_assert_flag17         	  VARCHAR2,
 x_acc_assert_flag18         	  VARCHAR2,
 x_acc_assert_flag19         	  VARCHAR2,
 x_acc_assert_flag20        	  VARCHAR2,
 x_acc_assert_flag21         	  VARCHAR2,
 x_acc_assert_flag22         	  VARCHAR2,
 x_acc_assert_flag23         	  VARCHAR2,
 x_acc_assert_flag24         	  VARCHAR2,
 x_acc_assert_flag25         	  VARCHAR2,
 x_acc_assert_flag26         	  VARCHAR2,
 x_acc_assert_flag27         	  VARCHAR2,
 x_acc_assert_flag28         	  VARCHAR2,
 x_acc_assert_flag29         	  VARCHAR2,
 x_acc_assert_flag30        	  VARCHAR2,
 x_display_flag                   VARCHAR2
) is

begin
UPDATE
    amw_fin_cert_ctrl_sum
  SET
      acc_assert_flag_1=   x_acc_assert_flag1
     ,acc_assert_flag_2 =  x_acc_assert_flag2
     ,acc_assert_flag_3=   x_acc_assert_flag3
     ,acc_assert_flag_4=   x_acc_assert_flag4
     ,acc_assert_flag_5=   x_acc_assert_flag5
     ,acc_assert_flag_6=   x_acc_assert_flag6
     ,acc_assert_flag_7=   x_acc_assert_flag7
     ,acc_assert_flag_8=   x_acc_assert_flag8
     ,acc_assert_flag_9=   x_acc_assert_flag9
     ,acc_assert_flag_10=  x_acc_assert_flag10
     ,acc_assert_flag_11=  x_acc_assert_flag11
     ,acc_assert_flag_12=  x_acc_assert_flag12
     ,acc_assert_flag_13=  x_acc_assert_flag13
     ,acc_assert_flag_14=  x_acc_assert_flag14
     ,acc_assert_flag_15=  x_acc_assert_flag15
     ,acc_assert_flag_16=  x_acc_assert_flag16
     ,acc_assert_flag_17=  x_acc_assert_flag17
     ,acc_assert_flag_18=  x_acc_assert_flag18
     ,acc_assert_flag_19=  x_acc_assert_flag19
     ,acc_assert_flag_20=  x_acc_assert_flag20
     ,acc_assert_flag_21=  x_acc_assert_flag21
     ,acc_assert_flag_22=  x_acc_assert_flag22
     ,acc_assert_flag_23=  x_acc_assert_flag23
     ,acc_assert_flag_24=  x_acc_assert_flag24
     ,acc_assert_flag_25=  x_acc_assert_flag25
     ,acc_assert_flag_26=  x_acc_assert_flag26
     ,acc_assert_flag_27=  x_acc_assert_flag27
     ,acc_assert_flag_28=  x_acc_assert_flag28
     ,acc_assert_flag_29=  x_acc_assert_flag29
     ,acc_assert_flag_30=  x_acc_assert_flag30
     ,CONTROLS_EXIST_FLAG =x_display_flag
     ,last_updated_by           =  x_last_updated_by
     ,last_update_date          =  x_last_update_date
     ,last_update_login         = x_last_update_login
     ,object_version_number = object_version_number +1
where
 fin_certification_id = x_fin_certification_id and
 financial_item_id         = x_financial_item_id and
 NVL(account_group_id, -1) = '-1' and
 nvl(natural_account_id, -1) = '-1'   and
 CTRL_ATTRIBUTE_TYPE =  x_ctrl_attribute_type       and
 object_type	= 'FINANCIAL ITEM' ;



end UPDATE_CTRLSUM_ITEM_FLAG;



/* ******************************************* UPDATE_ACC_ASSERT_FLAG ***************************************** */

procedure UPDATE_CTRLSUM_FLAG(
 x_fin_certification_id       	NUMBER  ,
 x_natural_account_id        	 NUMBER,
 x_ctrl_attribute_type       	varchar2,
 x_created_by             number ,
 x_creation_date          date   	,
 x_last_updated_by        number   	,
 x_last_update_date       date,
 x_last_update_login      number   	,
 x_acc_assert_flag1         	  VARCHAR2,
 x_acc_assert_flag2         	  VARCHAR2,
 x_acc_assert_flag3         	  VARCHAR2,
 x_acc_assert_flag4         	  VARCHAR2,
 x_acc_assert_flag5         	  VARCHAR2,
 x_acc_assert_flag6         	  VARCHAR2,
 x_acc_assert_flag7         	  VARCHAR2,
 x_acc_assert_flag8         	  VARCHAR2,
 x_acc_assert_flag9         	  VARCHAR2,
 x_acc_assert_flag10        	  VARCHAR2,
 x_acc_assert_flag11         	  VARCHAR2,
 x_acc_assert_flag12         	  VARCHAR2,
 x_acc_assert_flag13         	  VARCHAR2,
 x_acc_assert_flag14         	  VARCHAR2,
 x_acc_assert_flag15         	  VARCHAR2,
 x_acc_assert_flag16         	  VARCHAR2,
 x_acc_assert_flag17         	  VARCHAR2,
 x_acc_assert_flag18         	  VARCHAR2,
 x_acc_assert_flag19         	  VARCHAR2,
 x_acc_assert_flag20        	  VARCHAR2,
 x_acc_assert_flag21         	  VARCHAR2,
 x_acc_assert_flag22         	  VARCHAR2,
 x_acc_assert_flag23         	  VARCHAR2,
 x_acc_assert_flag24         	  VARCHAR2,
 x_acc_assert_flag25         	  VARCHAR2,
 x_acc_assert_flag26         	  VARCHAR2,
 x_acc_assert_flag27         	  VARCHAR2,
 x_acc_assert_flag28         	  VARCHAR2,
 x_acc_assert_flag29         	  VARCHAR2,
 x_acc_assert_flag30        	  VARCHAR2,
 x_display_flag                   VARCHAR2

) is

begin
UPDATE
    amw_fin_cert_ctrl_sum
  SET
      acc_assert_flag_1=   x_acc_assert_flag1
     ,acc_assert_flag_2 =  x_acc_assert_flag2
     ,acc_assert_flag_3=   x_acc_assert_flag3
     ,acc_assert_flag_4=   x_acc_assert_flag4
     ,acc_assert_flag_5=   x_acc_assert_flag5
     ,acc_assert_flag_6=   x_acc_assert_flag6
     ,acc_assert_flag_7=   x_acc_assert_flag7
     ,acc_assert_flag_8=   x_acc_assert_flag8
     ,acc_assert_flag_9=   x_acc_assert_flag9
     ,acc_assert_flag_10=  x_acc_assert_flag10
     ,acc_assert_flag_11=  x_acc_assert_flag11
     ,acc_assert_flag_12=  x_acc_assert_flag12
     ,acc_assert_flag_13=  x_acc_assert_flag13
     ,acc_assert_flag_14=  x_acc_assert_flag14
     ,acc_assert_flag_15=  x_acc_assert_flag15
     ,acc_assert_flag_16=  x_acc_assert_flag16
     ,acc_assert_flag_17=  x_acc_assert_flag17
     ,acc_assert_flag_18=  x_acc_assert_flag18
     ,acc_assert_flag_19=  x_acc_assert_flag19
     ,acc_assert_flag_20=  x_acc_assert_flag20
     ,acc_assert_flag_21=  x_acc_assert_flag21
     ,acc_assert_flag_22=  x_acc_assert_flag22
     ,acc_assert_flag_23=  x_acc_assert_flag23
     ,acc_assert_flag_24=  x_acc_assert_flag24
     ,acc_assert_flag_25=  x_acc_assert_flag25
     ,acc_assert_flag_26=  x_acc_assert_flag26
     ,acc_assert_flag_27=  x_acc_assert_flag27
     ,acc_assert_flag_28=  x_acc_assert_flag28
     ,acc_assert_flag_29=  x_acc_assert_flag29
     ,acc_assert_flag_30=  x_acc_assert_flag30
     ,CONTROLS_EXIST_FLAG =x_display_flag
     ,last_updated_by           =  x_last_updated_by
     ,last_update_date          =  x_last_update_date
     ,last_update_login         = x_last_update_login
     ,object_version_number = object_version_number +1
where
 fin_certification_id = x_fin_certification_id and
  natural_account_id  =  x_natural_account_id   and
  object_type	= 'ACCOUNT' and
  CTRL_ATTRIBUTE_TYPE = 'CTRL_ASSERTIONS';

end UPDATE_CTRLSUM_FLAG;


--*************************************************************************************************************
FUNCTION take_new_acc_assertions
( p_subscription_guid   in     raw,
  p_event               in out NOCOPY wf_event_t)
return varchar2
IS

 l_key                    varchar2(240) := p_event.GetEventKey();
 l_acccount_id            NUMBER;
 l_user_id 	          NUMBER;
 l_resp_id 	          NUMBER;
 l_resp_appl_id           NUMBER;
 l_security_group_id      NUMBER;


BEGIN


  l_acccount_id  := p_event.GetValueForParameter('ACCOUNT_ID');
  l_user_id := p_event.GetValueForParameter('USER_ID');
  l_resp_id := p_event.GetValueForParameter('RESP_ID');
  l_resp_appl_id := p_event.GetValueForParameter('RESP_APPL_ID');
  l_security_group_id := null;

 --p_event.GetValueForParameter('SECURITY_GROUP_ID');

 -- fnd_global.apps_initialize (l_user_id, l_resp_id, l_resp_appl_id, l_security_group_id);

 amw_fin_coso_views_pvt.update_acc_assert_flags(l_acccount_id);


RETURN 'SUCCESS';
EXCEPTION
 WHEN OTHERS THEN
     WF_CORE.CONTEXT('amw_fin_coso_views_pvt', 'update_acc_assert_flags', p_event.getEventName(), p_subscription_guid);
     WF_EVENT.setErrorInfo(p_event, 'ERROR');
     RETURN 'ERROR';

end take_new_acc_assertions;
--*************************************************************************************************************

------------------------------------------
PROCEDURE update_parentacc_assert_flags
( P_ACCOUNT_ID        number,
  P_CERTFICATION_ID number,
  P_ACCOUNT_GROUP_ID number) is


begin
declare


 ctr integer :=0;
 max_num_of_codes integer :=0;
 m_ctrl_attribute_type VARCHAR2(30) :='CTRL_ASSERTIONS';

 m_assertions_code component_code_array;
 m_acc_assert_flag component_code_array;
 m_total_control  total_control_array ;

 m_cert_id number ;

 m_ineff_control  ineff_control_array ;

 v_ASSERTION_CODE varchar2(30);
 m_display_flag varchar2(1) := 'N';

 g_user_id              NUMBER        := fnd_global.user_id;
 g_login_id             NUMBER        := fnd_global.conc_login_id;
 g_errbuf               VARCHAR2(2000) := null;
 g_retcode              VARCHAR2(2)    :=  '0';

-- *************** Currsor to get all Control for the account being Passed ********** --


--M_ACCOUNT_GROUP_ID number :=0;
-----------------------------------------------------------------------------------------

M_PARENT_ACCOUNT_ID number :=0;

cursor ACC_ASSERT_CODES
 is
select
distinct
ASSERTION_CODE
from
amw_account_assertions
where
((NATURAL_ACCOUNT_ID =M_PARENT_ACCOUNT_ID) or (NATURAL_ACCOUNT_ID in (select CHILD_NATURAL_ACCOUNT_ID from amw_fin_key_acct_flat
where  PARENT_NATURAL_ACCOUNT_ID  =M_PARENT_ACCOUNT_ID and ACCOUNT_GROUP_ID=P_ACCOUNT_GROUP_ID)));

-----------------------------------------------------------------------------------------

M_STATEMENT_GROUP_ID NUMBER :=0;
M_STATEMENT_ID NUMBER :=0;

cursor getParentAcc IS
    select PARENT_NATURAL_ACCOUNT_ID from amw_fin_key_acct_flat
where  CHILD_NATURAL_ACCOUNT_ID  =P_ACCOUNT_ID and ACCOUNT_GROUP_ID=p_ACCOUNT_GROUP_ID;

--------------------------------------------------------------------------------------------
cursor existing_codes
is
 select
 distinct
   FIN_CERTIFICATION_ID,
   FINANCIAL_STATEMENT_ID,
   ctrl_attr_code_1,
   ctrl_attr_code_2,
   ctrl_attr_code_3,
   ctrl_attr_code_4,
   ctrl_attr_code_5,
   ctrl_attr_code_6,
   ctrl_attr_code_7,
   ctrl_attr_code_8,
   ctrl_attr_code_9,
   ctrl_attr_code_10,
   ctrl_attr_code_11,
   ctrl_attr_code_12,
   ctrl_attr_code_13,
   ctrl_attr_code_14,
   ctrl_attr_code_15,
   ctrl_attr_code_16,
   ctrl_attr_code_17,
   ctrl_attr_code_18,
   ctrl_attr_code_19,
   ctrl_attr_code_20,
   ctrl_attr_code_21,
   ctrl_attr_code_22,
   ctrl_attr_code_23,
   ctrl_attr_code_24,
   ctrl_attr_code_25,
   ctrl_attr_code_26,
   ctrl_attr_code_27,
   ctrl_attr_code_28,
   ctrl_attr_code_29,
   ctrl_attr_code_30,
   ineff_ctrl_attr_1,
   ineff_ctrl_attr_2,
   ineff_ctrl_attr_3,
   ineff_ctrl_attr_4,
   ineff_ctrl_attr_5,
   ineff_ctrl_attr_6,
   ineff_ctrl_attr_7,
   ineff_ctrl_attr_8,
   ineff_ctrl_attr_9,
   ineff_ctrl_attr_10,
   ineff_ctrl_attr_11,
   ineff_ctrl_attr_12,
   ineff_ctrl_attr_13,
   ineff_ctrl_attr_14,
   ineff_ctrl_attr_15,
   ineff_ctrl_attr_16,
   ineff_ctrl_attr_17,
   ineff_ctrl_attr_18,
   ineff_ctrl_attr_19,
   ineff_ctrl_attr_20,
   ineff_ctrl_attr_21,
   ineff_ctrl_attr_22,
   ineff_ctrl_attr_23,
   ineff_ctrl_attr_24,
   ineff_ctrl_attr_25,
   ineff_ctrl_attr_26,
   ineff_ctrl_attr_27,
   ineff_ctrl_attr_28,
   ineff_ctrl_attr_29,
   ineff_ctrl_attr_30,
 total_ctrl_attr_1,
 total_ctrl_attr_2,
 total_ctrl_attr_3,
 total_ctrl_attr_4,
 total_ctrl_attr_5,
 total_ctrl_attr_6,
 total_ctrl_attr_7,
 total_ctrl_attr_8,
 total_ctrl_attr_9,
 total_ctrl_attr_10,
 total_ctrl_attr_11,
 total_ctrl_attr_12,
 total_ctrl_attr_13,
 total_ctrl_attr_14,
 total_ctrl_attr_15,
 total_ctrl_attr_16,
 total_ctrl_attr_17,
 total_ctrl_attr_18,
 total_ctrl_attr_19,
 total_ctrl_attr_20,
 total_ctrl_attr_21,
 total_ctrl_attr_22,
 total_ctrl_attr_23,
 total_ctrl_attr_24,
 total_ctrl_attr_25,
 total_ctrl_attr_26,
 total_ctrl_attr_27,
 total_ctrl_attr_28,
 total_ctrl_attr_29,
 total_ctrl_attr_30
from
 amw_fin_cert_ctrl_sum ctrlsum
where
FIN_CERTIFICATION_ID= P_CERTFICATION_ID
and ctrl_attribute_type = 'CTRL_ASSERTIONS'
AND OBJECT_TYPE='ACCOUNT' AND
NATURAL_ACCOUNT_ID=M_PARENT_ACCOUNT_ID AND
ACCOUNT_GROUP_ID =P_ACCOUNT_GROUP_ID ;




BEGIN

 --m_assertions_code := null;
 --ctr := 0;


for parentAccounts in getParentAcc
 loop
    exit when getParentAcc %notfound;
    M_PARENT_ACCOUNT_ID := parentAccounts.PARENT_NATURAL_ACCOUNT_ID ;


 -- ************ Since the Table has 30 Fileds only initialize 30 Positios in the Array**************--

 for load_current_codes in existing_codes
 loop
    exit when existing_codes%notfound;

    ctr :=  1;

    loop -- for each certification initialize the array
     EXIT WHEN ctr > 30;

      m_assertions_code(ctr) := null;
      m_acc_assert_flag(ctr) := 'I'; -- make ignore as the default and make it Y or N based on the interest of the Account on Assertion
      m_ineff_control(ctr) :=0;
      ctr := ctr + 1;

    end loop; --end of initialization


   m_assertions_code(1) :=  load_current_codes.ctrl_attr_code_1;
   m_assertions_code(2) :=  load_current_codes.ctrl_attr_code_2;
   m_assertions_code(3) :=  load_current_codes.ctrl_attr_code_3;
   m_assertions_code(4) :=   load_current_codes.ctrl_attr_code_4;
   m_assertions_code(5) :=load_current_codes.ctrl_attr_code_5;
   m_assertions_code(6) :=load_current_codes.ctrl_attr_code_6;
   m_assertions_code(7) :=load_current_codes.ctrl_attr_code_7;
   m_assertions_code(8) :=load_current_codes.ctrl_attr_code_8;
   m_assertions_code(9) :=load_current_codes.ctrl_attr_code_9;
   m_assertions_code(10) :=load_current_codes.ctrl_attr_code_10;
   m_assertions_code(11) :=load_current_codes.ctrl_attr_code_11;
   m_assertions_code(12) :=load_current_codes.ctrl_attr_code_12;
   m_assertions_code(13) :=load_current_codes.ctrl_attr_code_13;
   m_assertions_code(14) :=load_current_codes.ctrl_attr_code_14;
   m_assertions_code(15) :=load_current_codes.ctrl_attr_code_15;
   m_assertions_code(16) :=load_current_codes.ctrl_attr_code_16;
   m_assertions_code(17) :=load_current_codes.ctrl_attr_code_17;
   m_assertions_code(18) :=load_current_codes.ctrl_attr_code_18;
   m_assertions_code(19) :=load_current_codes.ctrl_attr_code_19;
   m_assertions_code(20) :=load_current_codes.ctrl_attr_code_20;
   m_assertions_code(21) :=load_current_codes.ctrl_attr_code_21;
   m_assertions_code(22) :=load_current_codes.ctrl_attr_code_22;
   m_assertions_code(23) :=load_current_codes.ctrl_attr_code_23;
   m_assertions_code(24) :=load_current_codes.ctrl_attr_code_24;
   m_assertions_code(25) :=load_current_codes.ctrl_attr_code_25;
   m_assertions_code(26) :=load_current_codes.ctrl_attr_code_26;
   m_assertions_code(27) :=load_current_codes.ctrl_attr_code_27;
   m_assertions_code(28) :=load_current_codes.ctrl_attr_code_28;
   m_assertions_code(29) :=load_current_codes.ctrl_attr_code_29;
   m_assertions_code(30) :=load_current_codes.ctrl_attr_code_30;

   m_ineff_control(1) :=  load_current_codes.ineff_ctrl_attr_1;
   m_ineff_control(2) :=  load_current_codes.ineff_ctrl_attr_2;
   m_ineff_control(3) :=  load_current_codes.ineff_ctrl_attr_3;
   m_ineff_control(4) :=   load_current_codes.ineff_ctrl_attr_4;
   m_ineff_control(5) :=load_current_codes.ineff_ctrl_attr_5;
   m_ineff_control(6) :=load_current_codes.ineff_ctrl_attr_6;
   m_ineff_control(7) :=load_current_codes.ineff_ctrl_attr_7;
   m_ineff_control(8) :=load_current_codes.ineff_ctrl_attr_8;
   m_ineff_control(9) :=load_current_codes.ineff_ctrl_attr_9;
   m_ineff_control(10) :=load_current_codes.ineff_ctrl_attr_10;
   m_ineff_control(11) :=load_current_codes.ineff_ctrl_attr_11;
   m_ineff_control(12) :=load_current_codes.ineff_ctrl_attr_12;
   m_ineff_control(13) :=load_current_codes.ineff_ctrl_attr_13;
   m_ineff_control(14) :=load_current_codes.ineff_ctrl_attr_14;
   m_ineff_control(15) :=load_current_codes.ineff_ctrl_attr_15;
   m_ineff_control(16) :=load_current_codes.ineff_ctrl_attr_16;
   m_ineff_control(17) :=load_current_codes.ineff_ctrl_attr_17;
   m_ineff_control(18) :=load_current_codes.ineff_ctrl_attr_18;
   m_ineff_control(19) :=load_current_codes.ineff_ctrl_attr_19;
   m_ineff_control(20) :=load_current_codes.ineff_ctrl_attr_20;
   m_ineff_control(21) :=load_current_codes.ineff_ctrl_attr_21;
   m_ineff_control(22) :=load_current_codes.ineff_ctrl_attr_22;
   m_ineff_control(23) :=load_current_codes.ineff_ctrl_attr_23;
   m_ineff_control(24) :=load_current_codes.ineff_ctrl_attr_24;
   m_ineff_control(25) :=load_current_codes.ineff_ctrl_attr_25;
   m_ineff_control(26) :=load_current_codes.ineff_ctrl_attr_26;
   m_ineff_control(27) :=load_current_codes.ineff_ctrl_attr_27;
   m_ineff_control(28) :=load_current_codes.ineff_ctrl_attr_28;
   m_ineff_control(29) :=load_current_codes.ineff_ctrl_attr_29;
   m_ineff_control(30) :=load_current_codes.ineff_ctrl_attr_30;

 m_total_control(1) := load_current_codes.total_ctrl_attr_1;
 m_total_control(2) :=  load_current_codes.total_ctrl_attr_2;
 m_total_control(3) := load_current_codes.total_ctrl_attr_3;
 m_total_control(4) := load_current_codes.total_ctrl_attr_4;
 m_total_control(5) := load_current_codes.total_ctrl_attr_5;
 m_total_control(6) := load_current_codes.total_ctrl_attr_6;
 m_total_control(7) := load_current_codes.total_ctrl_attr_7;
 m_total_control(8) := load_current_codes.total_ctrl_attr_8;
 m_total_control(9) := load_current_codes.total_ctrl_attr_9;
 m_total_control(10) := load_current_codes.total_ctrl_attr_10;
 m_total_control(11) := load_current_codes.total_ctrl_attr_11;
 m_total_control(12) := load_current_codes.total_ctrl_attr_12;
 m_total_control(13) := load_current_codes.total_ctrl_attr_13;
 m_total_control(14) := load_current_codes.total_ctrl_attr_14;
 m_total_control(15) := load_current_codes.total_ctrl_attr_15;
 m_total_control(16) := load_current_codes.total_ctrl_attr_16;
 m_total_control(17) := load_current_codes.total_ctrl_attr_17;
 m_total_control(18) := load_current_codes.total_ctrl_attr_18;
 m_total_control(19) := load_current_codes.total_ctrl_attr_19;
 m_total_control(20) := load_current_codes.total_ctrl_attr_20;
 m_total_control(21) := load_current_codes.total_ctrl_attr_21;
 m_total_control(22) := load_current_codes.total_ctrl_attr_22;
 m_total_control(23) := load_current_codes.total_ctrl_attr_23;
 m_total_control(24) := load_current_codes.total_ctrl_attr_24;
 m_total_control(25) := load_current_codes.total_ctrl_attr_25;
 m_total_control(26) := load_current_codes.total_ctrl_attr_26;
 m_total_control(27) := load_current_codes.total_ctrl_attr_27;
 m_total_control(28) := load_current_codes.total_ctrl_attr_28;
 m_total_control(29) := load_current_codes.total_ctrl_attr_29;
 m_total_control(30) := load_current_codes.total_ctrl_attr_30;

 m_cert_id :=load_current_codes.FIN_CERTIFICATION_ID ;
-- M_STATEMENT_GROUP_ID := load_current_codes.STATEMENT_GROUP_ID;
 M_STATEMENT_ID := load_current_codes.FINANCIAL_STATEMENT_ID;

  for acc_assertions in ACC_ASSERT_CODES
  loop
      exit when ACC_ASSERT_CODES%notfound;

      ctr := 1;
      while ctr <=  30
      loop
          if (m_assertions_code(ctr) =  acc_assertions.ASSERTION_CODE  ) then

             if nvl(m_ineff_control(ctr),0) > 0  then

                   m_acc_assert_flag(ctr) := 'Y';

                --************************************************************************************************** --
                -- else if the assertion is important for one of the accounts of fin. Item and No controls exist for the
                --  processes associated with the accounts then set the flag to 'Y', based on which an image will
                --- appear in UI
                --************************************************************************************************** --

                 elsif (nvl(m_total_control(ctr),0) = 0) then

                   m_acc_assert_flag(ctr) := 'Y';


                 --- ********** ie assertion is Not important for any of the accounts of fin. Item  and(nvl(m_total_control(ctr),0) > 0)
                 else
                    m_acc_assert_flag(ctr) := 'N';

                 end if;


             --m_acc_assert_flag(ctr) := 'Y';
             exit;

           end if;
           ctr := ctr +1;
      end loop;
   end loop; --end of acc_assertions in ACC_ASSERT_CODES
 ---------------------------------------------------------------------------------------------

    if set_flag_for_assertions( assert_acc_reln_exist=>  m_acc_assert_flag) then

        m_display_flag := 'Y';
     else
        m_display_flag := 'N';
     end if;


 ---------------------------------------------------------------------------------------------

    amw_fin_coso_views_pvt.UPDATE_CTRLSUM_FLAG(
     x_fin_certification_id       	=> 	m_cert_id   	,
     x_natural_account_id        	=> 	M_PARENT_ACCOUNT_ID ,
     x_ctrl_attribute_type       	=> 	m_ctrl_attribute_type       	,
     x_created_by                	=> 	g_user_id	,
     x_creation_date             	=> 	SYSDATE	,
     x_last_updated_by           	=> 	g_user_id	,
     x_last_update_date          	=> 	SYSDATE	,
     x_last_update_login         	=> 	g_login_id	,
    -- x_object_version_number     	=> 	null,
     x_acc_assert_flag1         	=> 	m_acc_assert_flag(1),
     x_acc_assert_flag2         	=> 	m_acc_assert_flag(2),
     x_acc_assert_flag3         	=> 	m_acc_assert_flag(3),
     x_acc_assert_flag4         	=> 	m_acc_assert_flag(4),
     x_acc_assert_flag5         	=> 	m_acc_assert_flag(5),
     x_acc_assert_flag6         	=> 	m_acc_assert_flag(6),
     x_acc_assert_flag7         	=> 	m_acc_assert_flag(7),
     x_acc_assert_flag8         	=> 	m_acc_assert_flag(8),
     x_acc_assert_flag9         	=> 	m_acc_assert_flag(9),
     x_acc_assert_flag10        	=> 	m_acc_assert_flag(10),
     x_acc_assert_flag11         	=> 	m_acc_assert_flag(11),
     x_acc_assert_flag12         	=> 	m_acc_assert_flag(12),
     x_acc_assert_flag13         	=> 	m_acc_assert_flag(13),
     x_acc_assert_flag14         	=> 	m_acc_assert_flag(14),
     x_acc_assert_flag15         	=> 	m_acc_assert_flag(15),
     x_acc_assert_flag16         	=> 	m_acc_assert_flag(16),
     x_acc_assert_flag17         	=> 	m_acc_assert_flag(17),
     x_acc_assert_flag18         	=> 	m_acc_assert_flag(18),
     x_acc_assert_flag19         	=> 	m_acc_assert_flag(19),
     x_acc_assert_flag20        	=> 	m_acc_assert_flag(20),
     x_acc_assert_flag21         	=> 	m_acc_assert_flag(21),
     x_acc_assert_flag22         	=> 	m_acc_assert_flag(22),
     x_acc_assert_flag23         	=> 	m_acc_assert_flag(23),
     x_acc_assert_flag24         	=> 	m_acc_assert_flag(24),
     x_acc_assert_flag25         	=> 	m_acc_assert_flag(25),
     x_acc_assert_flag26         	=> 	m_acc_assert_flag(26),
     x_acc_assert_flag27         	=> 	m_acc_assert_flag(27),
     x_acc_assert_flag28         	=> 	m_acc_assert_flag(28),
     x_acc_assert_flag29         	=> 	m_acc_assert_flag(29),
     x_acc_assert_flag30        	=> 	m_acc_assert_flag(30),
     x_display_flag                     =>      m_display_flag  );



 end loop; -- end of load_current_codes loop

end loop; -- parent account loop

 EXCEPTION
     WHEN NO_DATA_FOUND
	     THEN
            fnd_file.put_line (fnd_file.LOG, SUBSTR ('No data found in Update_Next_Level_Proc_Info'
                || SUBSTR (SQLERRM, 1, 100), 1, 200));

     WHEN OTHERS
         THEN
            fnd_file.put_line (fnd_file.LOG, SUBSTR ('Unexpected Error in Update_Next_Level_Proc_Info'
                || SUBSTR (SQLERRM, 1, 100), 1, 200));

---COMMIT;
end;
end ; -- update_parentacc_assert_flags

-- ************************************************************************************************************* --



END amw_fin_coso_views_pvt;

/
