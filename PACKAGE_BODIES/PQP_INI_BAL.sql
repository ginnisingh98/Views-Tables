--------------------------------------------------------
--  DDL for Package Body PQP_INI_BAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_INI_BAL" AS
/* $Header: pqpbladj.pkb 115.15 2003/07/16 09:37:13 jcpereir noship $*/
g_err_info                    t_err_info;
upgrade_status                varchar2(1):= 'C';
adjustment_entry_count        NUMBER := 0;
l_prev_upgrade_status         VARCHAR2(2);
prev_yr_car_ni_amt            NUMBER:=0;
prev_yr_mc_ni_amt             NUMBER:=0;
prev_yr_pc_ni_amt             NUMBER:=0;

PROCEDURE route_balance_amt
AS
l_effective_date        DATE;
BEGIN

SAVEPOINT CARMILEAGE;
FOR i in 1..g_sum_bal_info.count
  LOOP
 IF g_sum_bal_info(i).PAYE_Taxable = 'N' and g_err_info.count = 0 THEN
   IF g_sum_bal_info(i).usage_type='C' THEN
    -- Create Adjustment Entries for Private-Casual Claims which are not PAYE Taxable
    create_element_entry
           ( p_effective_date            =>g_sum_bal_info(i).effective_date
            ,p_business_group_id         =>g_sum_bal_info(i).business_group_id
            ,p_assignment_id             =>g_sum_bal_info(i).assignment_id
            ,p_element_name              =>g_sum_bal_info(i).element_name||' Pvt Mlg Addl Ele1'
            ,p_base_element_name         =>g_sum_bal_info(i).element_name
            ,p_entry_value1              =>NULL
            ,p_entry_value2              =>g_sum_bal_info(i).Processed_Amt
            ,p_entry_value3              =>g_sum_bal_info(i).Processed_Miles
            ,p_entry_value4              =>g_sum_bal_info(i).Processed_Act_Miles
            ,p_entry_value5              =>NULL
            ,p_entry_value6              =>NULL
            ,p_entry_value7              =>NULL
            ,p_entry_value8              =>NULL
            ,p_entry_value9              =>NULL
            ,p_entry_value10             =>NULL
            ,p_entry_value11             =>NULL
            ,p_entry_value12             =>NULL
            ,p_entry_value13             =>NULL
            ,p_entry_value14             =>NULL
            ,p_entry_value15             =>NULL
            );
    create_element_entry
           ( p_effective_date            =>g_sum_bal_info(i).effective_date
            ,p_business_group_id         =>g_sum_bal_info(i).business_group_id
            ,p_assignment_id             =>g_sum_bal_info(i).assignment_id
            ,p_element_name              =>g_sum_bal_info(i).element_name||' Pvt Mlg Addl Ele2'
            ,p_base_element_name         =>g_sum_bal_info(i).element_name
            ,p_entry_value1              =>NULL
            ,p_entry_value2              =>g_sum_bal_info(i).Addl_Tax_Amt
            ,p_entry_value3              =>g_sum_bal_info(i).Addl_Pasg_Amt
            ,p_entry_value4              =>g_sum_bal_info(i).Addl_Pasg_Miles
            ,p_entry_value5              =>g_sum_bal_info(i).Addl_Pasg_Act_Miles
            ,p_entry_value6              =>NULL
            ,p_entry_value7              =>NULL
            ,p_entry_value8              =>NULL
            ,p_entry_value9              =>NULL
            ,p_entry_value10             =>g_sum_bal_info(i).NI_Amt
            ,p_entry_value11             =>NULL
            ,p_entry_value12             =>g_sum_bal_info(i).Taxable_Amt
            ,p_entry_value13             =>NULL
            ,p_entry_value14             =>g_sum_bal_info(i).IRAM_Amt
            ,p_entry_value15             =>NULL
            );



   ELSIF g_sum_bal_info(i).usage_type='E' THEN
    --Create Adjustment Entries for Private-Essential Claims which are not PAYE Taxable
    create_element_entry
           ( p_effective_date            =>g_sum_bal_info(i).effective_date
            ,p_business_group_id         =>g_sum_bal_info(i).business_group_id
            ,p_assignment_id             =>g_sum_bal_info(i).assignment_id
            ,p_element_name              =>g_sum_bal_info(i).element_name||' Pvt Mlg Addl Ele1'
            ,p_base_element_name         =>g_sum_bal_info(i).element_name
            ,p_entry_value1              =>NULL
            ,p_entry_value2              =>NULL
            ,p_entry_value3              =>NULL
            ,p_entry_value4              =>NULL
            ,p_entry_value5              =>NULL
            ,p_entry_value6              =>NULL
            ,p_entry_value7              =>NULL
            ,p_entry_value8              =>g_sum_bal_info(i).Processed_Amt
            ,p_entry_value9              =>g_sum_bal_info(i).Processed_Miles
            ,p_entry_value10             =>g_sum_bal_info(i).Processed_Act_Miles
            ,p_entry_value11             =>NULL
            ,p_entry_value12             =>NULL
            ,p_entry_value13             =>NULL
            ,p_entry_value14             =>NULL
            ,p_entry_value15             =>NULL
            );

    create_element_entry
           ( p_effective_date            =>g_sum_bal_info(i).effective_date
            ,p_business_group_id         =>g_sum_bal_info(i).business_group_id
            ,p_assignment_id             =>g_sum_bal_info(i).assignment_id
            ,p_element_name              =>g_sum_bal_info(i).element_name||' Pvt Mlg Addl Ele2'
            ,p_base_element_name         =>g_sum_bal_info(i).element_name
            ,p_entry_value1              =>NULL
            ,p_entry_value2              =>g_sum_bal_info(i).Addl_Tax_Amt
            ,p_entry_value3              =>g_sum_bal_info(i).Addl_Pasg_Amt
            ,p_entry_value4              =>g_sum_bal_info(i).Addl_Pasg_Miles
            ,p_entry_value5              =>g_sum_bal_info(i).Addl_Pasg_Act_Miles
            ,p_entry_value6              =>NULL
            ,p_entry_value7              =>NULL
            ,p_entry_value8              =>NULL
            ,p_entry_value9              =>NULL
            ,p_entry_value10             =>g_sum_bal_info(i).NI_Amt
            ,p_entry_value11             =>NULL
            ,p_entry_value12             =>g_sum_bal_info(i).Taxable_Amt
            ,p_entry_value13             =>NULL
            ,p_entry_value14             =>g_sum_bal_info(i).IRAM_Amt
            ,p_entry_value15             =>NULL
            );


   ELSIF g_sum_bal_info(i).ownership_type='C' THEN
    --Create Adjustment Entries for Company which are not PAYE Taxable
    create_element_entry
           ( p_effective_date            =>g_sum_bal_info(i).effective_date
            ,p_business_group_id         =>g_sum_bal_info(i).business_group_id
            ,p_assignment_id             =>g_sum_bal_info(i).assignment_id
            ,p_element_name              =>g_sum_bal_info(i).element_name||' Co Mlg Addl Ele1'
            ,p_base_element_name         =>g_sum_bal_info(i).element_name
            ,p_entry_value1              =>NULL
            ,p_entry_value2              =>g_sum_bal_info(i).Processed_Amt
            ,p_entry_value3              =>g_sum_bal_info(i).Processed_Miles
            ,p_entry_value4              =>g_sum_bal_info(i).Processed_Act_Miles
            ,p_entry_value5              =>NULL
            ,p_entry_value6              =>NULL
            ,p_entry_value7              =>NULL
            ,p_entry_value8              =>NULL
            ,p_entry_value9              =>NULL
            ,p_entry_value10             =>NULL
            ,p_entry_value11             =>NULL
            ,p_entry_value12             =>NULL
            ,p_entry_value13             =>NULL
            ,p_entry_value14             =>NULL
            ,p_entry_value15             =>NULL
            );
        create_element_entry
           ( p_effective_date            =>g_sum_bal_info(i).effective_date
            ,p_business_group_id         =>g_sum_bal_info(i).business_group_id
            ,p_assignment_id             =>g_sum_bal_info(i).assignment_id
            ,p_element_name              =>g_sum_bal_info(i).element_name||' Co Mlg Addl Ele2'
            ,p_base_element_name         =>g_sum_bal_info(i).element_name
            ,p_entry_value1              =>NULL
            ,p_entry_value2              =>g_sum_bal_info(i).Addl_Pasg_Amt
            ,p_entry_value3              =>g_sum_bal_info(i).Addl_Pasg_Miles
            ,p_entry_value4              =>g_sum_bal_info(i).Addl_Pasg_Miles
            ,p_entry_value5              =>NULL
            ,p_entry_value6              =>NULL
            ,p_entry_value7              =>NULL
            ,p_entry_value8              =>NULL
            ,p_entry_value9              =>NULL
            ,p_entry_value10             =>NULL
            ,p_entry_value11             =>NULL
            ,p_entry_value12             =>NULL
            ,p_entry_value13             =>NULL
            ,p_entry_value14             =>NULL
            ,p_entry_value15             =>NULL
            );
      END IF;
   ELSIF g_err_info.count = 0 THEN
   IF g_sum_bal_info(i).usage_type='C' THEN
    --Create Adjustment Entries for Private-Casual Claims which are PAYE Taxable
    create_element_entry
           ( p_effective_date            =>g_sum_bal_info(i).effective_date
            ,p_business_group_id         =>g_sum_bal_info(i).business_group_id
            ,p_assignment_id             =>g_sum_bal_info(i).assignment_id
            ,p_element_name              =>g_sum_bal_info(i).element_name||' Pvt Mlg Addl Ele3'
            ,p_base_element_name         =>g_sum_bal_info(i).element_name
            ,p_entry_value1              =>NULL
            ,p_entry_value2              =>g_sum_bal_info(i).Processed_Amt
            ,p_entry_value3              =>NULL
            ,p_entry_value4              =>g_sum_bal_info(i).Processed_Miles
            ,p_entry_value5              =>NULL
            ,p_entry_value6              =>NULL
            ,p_entry_value7              =>NULL
            ,p_entry_value8              =>NULL
            ,p_entry_value9              =>NULL
            ,p_entry_value10             =>g_sum_bal_info(i).Addl_Pasg_Amt
            ,p_entry_value11             =>g_sum_bal_info(i).Addl_Pasg_Miles
            ,p_entry_value12             =>NULL
            ,p_entry_value13             =>NULL
            ,p_entry_value14             =>NULL
            ,p_entry_value15             =>NULL
            );

   ELSIF g_sum_bal_info(i).usage_type='E' THEN
    --Create Adjustment Entries for Private-Essential Claims which are PAYE Taxable
    create_element_entry
           ( p_effective_date            =>g_sum_bal_info(i).effective_date
            ,p_business_group_id         =>g_sum_bal_info(i).business_group_id
            ,p_assignment_id             =>g_sum_bal_info(i).assignment_id
            ,p_element_name              =>g_sum_bal_info(i).element_name||' Pvt Mlg Addl Ele3'
            ,p_base_element_name         =>g_sum_bal_info(i).element_name
            ,p_entry_value1              =>NULL
            ,p_entry_value2              =>NULL
            ,p_entry_value3              =>NULL
            ,p_entry_value4              =>NULL
            ,p_entry_value5              =>NULL
            ,p_entry_value6              =>g_sum_bal_info(i).Processed_Amt
            ,p_entry_value7              =>NULL
            ,p_entry_value8              =>g_sum_bal_info(i).Processed_Miles
            ,p_entry_value9              =>NULL
            ,p_entry_value10             =>g_sum_bal_info(i).Addl_Pasg_Amt
            ,p_entry_value11             =>g_sum_bal_info(i).Addl_Pasg_Miles
            ,p_entry_value12             =>NULL
            ,p_entry_value13             =>NULL
            ,p_entry_value14             =>NULL
            ,p_entry_value15             =>NULL
            );


   ELSIF g_sum_bal_info(i).ownership_type='C' THEN
    --Create Adjustment Entries for Company Claims which are PAYE Taxable
    create_element_entry
           ( p_effective_date            =>g_sum_bal_info(i).effective_date
            ,p_business_group_id         =>g_sum_bal_info(i).business_group_id
            ,p_assignment_id             =>g_sum_bal_info(i).assignment_id
            ,p_element_name              =>g_sum_bal_info(i).element_name||' Co Mlg Addl Ele3'
            ,p_base_element_name         =>g_sum_bal_info(i).element_name
            ,p_entry_value1              =>NULL
            ,p_entry_value2              =>g_sum_bal_info(i).Processed_Amt
            ,p_entry_value3              =>NULL
            ,p_entry_value4              =>g_sum_bal_info(i).Processed_Miles
            ,p_entry_value5              =>NULL
            ,p_entry_value6              =>g_sum_bal_info(i).Addl_Pasg_Amt
            ,p_entry_value7              =>g_sum_bal_info(i).Addl_Pasg_Miles
            ,p_entry_value8              =>NULL
            ,p_entry_value9              =>NULL
            ,p_entry_value10             =>NULL
            ,p_entry_value11             =>NULL
            ,p_entry_value12             =>NULL
            ,p_entry_value13             =>NULL
            ,p_entry_value14             =>NULL
            ,p_entry_value15             =>NULL
            );

  END IF;


END IF; --PAYE Taxable check
  END LOOP;

/** If there has been company claims for this assignment , then we need to create an adjustment
    for this assignment containing the total actual miles claimed under company ownership **/
FOR i in 1..g_comp_act_miles.count
LOOP
 create_element_entry
            ( p_effective_date            =>g_sum_bal_info(1).effective_date
             ,p_business_group_id         =>g_sum_bal_info(1).business_group_id
             ,p_assignment_id             =>g_sum_bal_info(1).assignment_id
             ,p_element_name              =>g_comp_act_miles(i).element_name||' Mileage Res2'
             ,p_base_element_name         =>g_comp_act_miles(i).element_name
             ,p_entry_value1              =>NULL
             ,p_entry_value2              =>NULL
             ,p_entry_value3              =>NULL
             ,p_entry_value4              =>NULL
             ,p_entry_value5              =>g_comp_act_miles(i).Total_Act_Miles
             ,p_entry_value6              =>NULL
             ,p_entry_value7              =>NULL
             ,p_entry_value8              =>NULL
             ,p_entry_value9              =>NULL
             ,p_entry_value10             =>NULL
             ,p_entry_value11             =>NULL
             ,p_entry_value12             =>NULL
             ,p_entry_value13             =>NULL
             ,p_entry_value14             =>NULL
             ,p_entry_value15             =>NULL
             );
END LOOP;

--After the Number of Adjustments have reached a certain point we need to commit
IF adjustment_entry_count >= 1000 and g_err_info.count = 0 then
  COMMIT;
  adjustment_entry_count := 0;
END IF;

-- This is required during the second try, Suppose the adjustment went successful the second time
-- then we need to delete the error log entry that was created the first time
IF l_prev_upgrade_status = 'P' THEN
 DELETE FROM pay_us_rpt_totals
 WHERE business_group_id=g_sum_bal_info(1).business_group_id
 AND state_name='CARMILEAGE_UPGRADE'
 AND tax_unit_id = 250
 AND location_id = g_sum_bal_info(1).assignment_id;
END IF;

-- This effective date is used to get the date tracked assignment details which
-- will be used for the error log
l_effective_date := g_sum_bal_info(1).effective_date;

--Empty the g_sum_bal
g_sum_bal_info.delete;

--Empty the g_comp_act_miles
g_comp_act_miles.delete;

--Empty the cache containing payroll details
g_payroll_det_cache.delete;

IF g_err_info.count > 0 THEN
-- Suppose it has errored out for the current assignment
-- then we need to rollback to the previous assignment
rollback to CARMILEAGE;
upgrade_status := 'P';  --Partially Complete
END IF;
for i in 1..g_err_info.count
LOOP
-- Insert errored out details into pay_us_rpt_totals
-- This will be used during the second run.
        INSERT INTO
        pay_us_rpt_totals(
         business_group_id
        ,location_id
        ,location_name
        ,state_name
        ,organization_name
        ,tax_unit_id
        ) VALUES (
         g_err_info(i).business_group_id
        ,g_err_info(i).assignment_id
        ,g_err_info(i).element_name
        ,'CARMILEAGE_UPGRADE'
        ,fnd_date.date_to_canonical(l_effective_date)
        ,250
        );
END LOOP;

g_err_info.delete;

END;


-- In this Procedure we sum up all the related claim entries for a given assignment
-- For Example if there are 2 Non Paye Taxable Casual Car Entries and 2 Non Paye Taxable
-- Essential MotorCycle entries , then we create one entry containing the sum of the 2 Casual entries
-- and another entry containing the sum of the 2 Essential entries.
PROCEDURE categorize_balances (p_bal_info IN t_bal_info)
AS
l_count1                 NUMBER:=0;
l_count2                 NUMBER:=0;
l_count3                 NUMBER:=0;
l_count4                 NUMBER:=0;
l_count5                 NUMBER:=0;
l_count6                 NUMBER:=0;
l_count7                 NUMBER:=0;
l_count8                 NUMBER:=0;
l_count9                 NUMBER:=0;
l_count10                NUMBER:=0;
l_count11                NUMBER:=0;
l_count12                NUMBER:=0;
l_count13                NUMBER:=0;
l_count14                NUMBER:=0;
l_count15                NUMBER:=0;
l_count16                NUMBER:=0;
l_count17                NUMBER:=0;
l_count18                NUMBER:=0;
sumindex                 NUMBER:=0;
l_found                  NUMBER:=0;
l_count                  NUMBER:=0;
car_ni_amt               NUMBER:=0;
car_tax_amt              NUMBER:=0;
car_prc_amt              NUMBER:=0;
car_tot_miles            NUMBER:=0;
car_ni_diff              NUMBER:=0;
car_tax_diff             NUMBER:=0;
current_car_ni_amt       NUMBER:=0;
current_car_tax_amt      NUMBER:=0;
current_car_prc_amt      NUMBER:=0;
current_car_tot_miles    NUMBER:=0;
mc_ni_amt                NUMBER:=0;
mc_tax_amt               NUMBER:=0;
mc_prc_amt               NUMBER:=0;
mc_tot_miles             NUMBER:=0;
mc_ni_diff               NUMBER:=0;
mc_tax_diff              NUMBER:=0;
current_mc_ni_amt        NUMBER:=0;
current_mc_tax_amt       NUMBER:=0;
current_mc_prc_amt       NUMBER:=0;
current_mc_tot_miles     NUMBER:=0;
pc_ni_amt                NUMBER:=0;
pc_tax_amt               NUMBER:=0;
pc_prc_amt               NUMBER:=0;
pc_tot_miles             NUMBER:=0;
pc_ni_diff               NUMBER:=0;
pc_tax_diff              NUMBER:=0;
current_pc_ni_amt        NUMBER:=0;
current_pc_tax_amt       NUMBER:=0;
current_pc_prc_amt       NUMBER:=0;
current_pc_tot_miles     NUMBER:=0;
ret                      NUMBER;
ni_rate                  VARCHAR2(10);
high_band_iram_rate      VARCHAR2(10);
low_band_iram_rate       VARCHAR2(10);
err_msg                  VARCHAR2(100);
calculated_ni_amt        NUMBER;
calculated_tax_amt       NUMBER;


PROCEDURE set_value (sumind IN NUMBER,
                     balind IN NUMBER
                     )
AS
BEGIN
      g_sum_bal_info(sumind).PAYE_Taxable :=p_bal_info(balind).PAYE_Taxable;
      g_sum_bal_info(sumind).assignment_id :=p_bal_info(balind).assignment_id;
      g_sum_bal_info(sumind).business_group_id :=p_bal_info(balind).business_group_id;
      g_sum_bal_info(sumind).effective_date :=p_bal_info(balind).effective_date;
      g_sum_bal_info(sumind).Ownership_Type :=p_bal_info(balind).Ownership_Type;
      g_sum_bal_info(sumind).Vehicle_Type :=p_bal_info(balind).Vehicle_Type;
      g_sum_bal_info(sumind).Usage_type :=p_bal_info(balind).Usage_type;
      g_sum_bal_info(sumind).Element_name :=p_bal_info(balind).Element_name;
      g_sum_bal_info(sumind).Processed_Miles :=NVL(g_sum_bal_info(sumind).Processed_Miles,0)
                                         + NVL(p_bal_info(balind).Processed_Miles,0);
      g_sum_bal_info(sumind).Processed_Act_Miles :=NVL(g_sum_bal_info(sumind).Processed_Act_Miles,0)
                                         + NVL(p_bal_info(balind).Processed_Act_Miles,0);
      g_sum_bal_info(sumind).Processed_Amt :=NVL(g_sum_bal_info(sumind).Processed_Amt,0)
                                         + NVL(p_bal_info(balind).Processed_Amt,0);
      g_sum_bal_info(sumind).IRAM_Amt :=NVL(g_sum_bal_info(sumind).IRAM_Amt,0)
                                         + NVL(p_bal_info(balind).IRAM_Amt,0);
      g_sum_bal_info(sumind).NI_Amt :=NVL(g_sum_bal_info(sumind).NI_Amt,0)
                                         + NVL(p_bal_info(balind).NI_Amt,0);
      g_sum_bal_info(sumind).Taxable_Amt :=NVL(g_sum_bal_info(sumind).Taxable_Amt,0)
                                         + NVL(p_bal_info(balind).Taxable_Amt,0);
      hr_utility.set_location('***** ADDL PROCESSED AMT2: ',p_bal_info(balind).Addl_Pasg_Amt);
      g_sum_bal_info(sumind).Addl_Pasg_Amt :=NVL(g_sum_bal_info(sumind).Addl_Pasg_Amt,0)
                                         + NVL(p_bal_info(balind).Addl_Pasg_Amt,0);
      g_sum_bal_info(sumind).Addl_Ni_Amt :=NVL(g_sum_bal_info(sumind).Addl_Ni_Amt,0)
                                         + NVL(p_bal_info(balind).Addl_Ni_Amt,0);
      g_sum_bal_info(sumind).Addl_Tax_Amt :=NVL(g_sum_bal_info(sumind).Addl_Tax_Amt,0)
                                         + NVL(p_bal_info(balind).Addl_Tax_Amt,0);
      g_sum_bal_info(sumind).Addl_Pasg_Miles :=NVL(g_sum_bal_info(sumind).Addl_Pasg_Miles,0)
                                         + NVL(p_bal_info(balind).Addl_Pasg_Miles,0);
      g_sum_bal_info(sumind).Addl_Pasg_Act_Miles :=NVL(g_sum_bal_info(sumind).Addl_Pasg_Act_Miles,0)
                                         + NVL(p_bal_info(balind).Addl_Pasg_Act_Miles,0);


END;


BEGIN

  car_ni_amt     := 0;
  car_prc_amt    := 0;
  car_tot_miles  := 0;
  mc_ni_amt      := 0;
  mc_prc_amt     := 0;
  mc_tot_miles   := 0;
  pc_ni_amt      := 0;
  pc_prc_amt     := 0;
  pc_tot_miles   := 0;
-- Roll up all vehicle type info
-- The Entries are categorized based on usage type, PAYE Taxable and vehicle type
-- The entries belonging to each category will then be summed up.
  FOR i in 1..p_bal_info.count
   LOOP
   IF p_bal_info(i).ownership_type='C' THEN
      FOR j in 1..g_comp_act_miles.count
      LOOP
       IF g_comp_act_miles(j).element_name = p_bal_info(i).element_name THEN
          g_comp_act_miles(j).total_act_miles := g_comp_act_miles(j).total_act_miles + p_bal_info(i).Processed_Act_Miles;
          l_found := 1;
          EXIT;
       END IF;
      END LOOP;
      IF l_found = 0 THEN
         l_count := g_comp_act_miles.count + 1;
         g_comp_act_miles(l_count).total_act_miles := p_bal_info(i).Processed_Act_Miles;
         g_comp_act_miles(l_count).element_name := p_bal_info(i).element_name;
      END IF;
   END IF;
   IF p_bal_info(i).Paye_Taxable ='N' THEN
     IF p_bal_info(i).usage_type='C' AND
        p_bal_info(i).vehicle_type ='P'  THEN
        IF l_count1=0 THEN
           l_count1:=sumindex+1;
           sumindex:=sumindex+1;
        END IF;
        set_value (sumind =>l_count1
                  ,balind =>i
                  ) ;
        car_ni_amt := car_ni_amt + p_bal_info(i).NI_Amt;
        car_tax_amt := car_tax_amt + p_bal_info(i).Taxable_Amt;
        car_prc_amt := car_prc_amt + p_bal_info(i).Processed_Amt;
        car_tot_miles := car_tot_miles + p_bal_info(i).Processed_Act_Miles;
     ELSIF p_bal_info(i).usage_type='C' AND
           p_bal_info(i).vehicle_type ='PM' THEN
           IF l_count2=0 THEN
              l_count2:=sumindex+1;
              sumindex:=sumindex+1;
           END IF;
           set_value (sumind =>l_count2
                     ,balind =>i
                     );
           mc_ni_amt := mc_ni_amt + p_bal_info(i).NI_Amt;
           mc_tax_amt := mc_tax_amt + p_bal_info(i).Taxable_Amt;
           mc_prc_amt := mc_prc_amt + p_bal_info(i).Processed_Amt;
           mc_tot_miles := mc_tot_miles + p_bal_info(i).Processed_Act_Miles;
     ELSIF p_bal_info(i).usage_type='C' AND
           p_bal_info(i).vehicle_type ='PP' THEN
           IF l_count3=0 THEN
              l_count3:=sumindex+1;
              sumindex:=sumindex+1;
           END IF;
              set_value (sumind =>l_count3
                        ,balind =>i
                        );
           pc_ni_amt := pc_ni_amt + p_bal_info(i).NI_Amt;
           pc_tax_amt := pc_tax_amt + p_bal_info(i).Taxable_Amt;
           pc_prc_amt := pc_prc_amt + p_bal_info(i).Processed_Amt;
           pc_tot_miles := pc_tot_miles + p_bal_info(i).Processed_Act_Miles;
     ELSIF p_bal_info(i).usage_type='E' AND
           p_bal_info(i).vehicle_type ='P' THEN
           IF l_count4=0 THEN
              l_count4:=sumindex+1;
              sumindex:=sumindex+1;
           END IF;
           set_value (sumind =>l_count4
                     ,balind =>i
                     );
           car_ni_amt := car_ni_amt + p_bal_info(i).NI_Amt;
           car_tax_amt := car_tax_amt + p_bal_info(i).Taxable_Amt;
           car_prc_amt := car_prc_amt + p_bal_info(i).Processed_Amt;
           car_tot_miles := car_tot_miles + p_bal_info(i).Processed_Act_Miles;
     ELSIF p_bal_info(i).usage_type='E' AND
           p_bal_info(i).vehicle_type ='PM' THEN
           IF l_count5=0 THEN
              l_count5:=sumindex+1;
              sumindex:=sumindex+1;
           END IF;
           set_value (sumind =>l_count5
                     ,balind =>i
                     );
           mc_ni_amt := car_ni_amt + p_bal_info(i).NI_Amt;
           mc_tax_amt := mc_tax_amt + p_bal_info(i).Taxable_Amt;
           mc_prc_amt := mc_prc_amt + p_bal_info(i).Processed_Amt;
           mc_tot_miles := mc_tot_miles + p_bal_info(i).Processed_Act_Miles;
     ELSIF p_bal_info(i).usage_type='E' AND
           p_bal_info(i).vehicle_type ='PP' THEN
           IF l_count6=0 THEN
              l_count6:=sumindex+1;
              sumindex:=sumindex+1;
           END IF;
           set_value (sumind =>l_count6
                     ,balind =>i
                     );
           pc_ni_amt := car_ni_amt + p_bal_info(i).NI_Amt;
           pc_tax_amt := pc_tax_amt + p_bal_info(i).Taxable_Amt;
           pc_prc_amt := pc_prc_amt + p_bal_info(i).Processed_Amt;
           pc_tot_miles := pc_tot_miles + p_bal_info(i).Processed_Act_Miles;
     ELSIF p_bal_info(i).ownership_type='C' AND
           p_bal_info(i).vehicle_type ='C' THEN
           IF l_count7=0 THEN
              l_count7:=sumindex+1;
              sumindex:=sumindex+1;
           END IF;
           set_value (sumind =>l_count7
                     ,balind =>i
                     );
     ELSIF p_bal_info(i).ownership_type='C' AND
           p_bal_info(i).vehicle_type ='CM' THEN
           IF l_count8=0 THEN
              l_count8:=sumindex+1;
              sumindex:=sumindex+1;
           END IF;
           set_value (sumind =>l_count8
                     ,balind =>i
                     );
     ELSIF p_bal_info(i).ownership_type='C' AND
           p_bal_info(i).vehicle_type ='CP' THEN
           IF l_count9=0 THEN
              l_count9:=sumindex+1;
              sumindex:=sumindex+1;
           END IF;
           set_value (sumind =>l_count9
                     ,balind =>i
                     );
     END IF;
   ELSIF p_bal_info(i).Paye_Taxable ='Y' THEN
     IF p_bal_info(i).usage_type='C' AND
        p_bal_info(i).vehicle_type ='P' THEN
        IF l_count10=0 THEN
           l_count10:=sumindex+1;
           sumindex:=sumindex+1;
        END IF;
        set_value (sumind =>l_count10
                  ,balind =>i
                  ) ;
     ELSIF p_bal_info(i).usage_type='C' AND
           p_bal_info(i).vehicle_type ='PM' THEN
           IF l_count11=0 THEN
              l_count11:=sumindex+1;
              sumindex:=sumindex+1;
           END IF;
           set_value (sumind =>l_count11
                     ,balind =>i
                     );
     ELSIF p_bal_info(i).usage_type='C' AND
           p_bal_info(i).vehicle_type ='PP' THEN
           IF l_count12=0 THEN
              l_count12:=sumindex+1;
              sumindex:=sumindex+1;
           END IF;
           set_value (sumind =>l_count12
                     ,balind =>i
                     );
     ELSIF p_bal_info(i).usage_type='E' AND
           p_bal_info(i).vehicle_type ='P' THEN
           IF l_count13=0 THEN
              l_count13:=sumindex+1;
              sumindex:=sumindex+1;
           END IF;
           set_value (sumind =>l_count13
                     ,balind =>i
                     );
     ELSIF p_bal_info(i).usage_type='E' AND
           p_bal_info(i).vehicle_type ='PM' THEN
          IF l_count14=0 THEN
             l_count14:=sumindex+1;
             sumindex:=sumindex+1;
          END IF;
          set_value (sumind =>l_count14
                    ,balind =>i
                    );
     ELSIF p_bal_info(i).usage_type='E' AND
           p_bal_info(i).vehicle_type ='PP' THEN
           IF l_count15=0 THEN
              l_count15:=sumindex+1;
              sumindex:=sumindex+1;
           END IF;
           set_value (sumind =>l_count15
                     ,balind =>i
                     );
     ELSIF p_bal_info(i).ownership_type='C' AND
           p_bal_info(i).vehicle_type ='C' THEN
           IF l_count16=0 THEN
              l_count16:=sumindex+1;
              sumindex:=sumindex+1;
           END IF;
           set_value (sumind =>l_count16
                     ,balind =>i
                     );
     ELSIF p_bal_info(i).ownership_type='C' AND
           p_bal_info(i).vehicle_type ='CM' THEN
           IF l_count17=0 THEN
              l_count17:=sumindex+1;
              sumindex:=sumindex+1;
           END IF;
           set_value (sumind =>l_count17
                     ,balind =>i
                     );
     ELSIF p_bal_info(i).ownership_type='C' AND
           p_bal_info(i).vehicle_type ='CP' THEN
          IF l_count18=0 THEN
             l_count18:=sumindex+1;
             sumindex:=sumindex+1;
          END IF;
          set_value (sumind =>l_count18
                    ,balind =>i
                    );
     END IF;
    END IF;
   END LOOP;

   IF car_tot_miles <> 0 THEN
    -- Corrections need to be made to Vehicle Type Ni and Taxable Amt
    -- Reasons For this Correction :
    -- After the Upgrade takes place , the balance initialization won't be run immediately.
    -- In this case there will be a chance that if the Vehicle Type NI amt for a payroll run(just after the update)
    -- is -ve then this value could be set to 0. Such descrepancies could occur with Taxable amt too. Therefore
    -- some corrections need to be done. Here we calculate what the NI amt is suppossed to be for that vehicle type.
    -- We also sum all the adjustment values and the current balance value. If there is any difference beween the 2 values
    -- then we subtract that difference from the balance adjustment.
    current_car_ni_amt := get_balance_value(p_bal_info(1).assignment_id,'Car NI Even Amt');
    current_car_tax_amt := get_balance_value(p_bal_info(1).assignment_id,'Car Taxable Even Amt');
    current_car_prc_amt := get_balance_value(p_bal_info(1).assignment_id,'Car Casual Even Processed Amt')
                          + get_balance_value(p_bal_info(1).assignment_id,'Car Essential Even Processed Amt');
    current_car_tot_miles := get_balance_value(p_bal_info(1).assignment_id,'Car Casual Even Actual Miles')
                           + get_balance_value(p_bal_info(1).assignment_id,'Car Essential Even Actual Miles');
    car_ni_amt := car_ni_amt + current_car_ni_amt;
    car_tax_amt := car_tax_amt + current_car_tax_amt;
    car_prc_amt := car_prc_amt + current_car_prc_amt;
    car_tot_miles := car_tot_miles + current_car_tot_miles;
    ret := PQP_UTILITIES.PQP_GB_GET_TABLE_VALUE
                             (P_BUSINESS_GROUP_ID   => NULL
                             ,P_EFFECTIVE_DATE      => sysdate
                             ,P_TABLE_NAME          => 'PQP_NIC_MILEAGE_RATES'
                             ,P_COLUMN_NAME         => '9999'
                             ,P_ROW_NAME            => '99999'
                             ,P_VALUE               => ni_rate
                             ,P_ERROR_MSG           => err_msg );
    ret := PQP_UTILITIES.PQP_GB_GET_TABLE_VALUE
                             (P_BUSINESS_GROUP_ID   => NULL
                             ,P_EFFECTIVE_DATE      => sysdate
                             ,P_TABLE_NAME          => 'PQP_INLAND_REV_AUTH_MILEAGE_RATES'
                             ,P_COLUMN_NAME         => '9999'
                             ,P_ROW_NAME            => '10000'
                             ,P_VALUE               => low_band_iram_rate
                             ,P_ERROR_MSG           => err_msg );
    ret := PQP_UTILITIES.PQP_GB_GET_TABLE_VALUE
                             (P_BUSINESS_GROUP_ID   => NULL
                             ,P_EFFECTIVE_DATE      => sysdate
                             ,P_TABLE_NAME          => 'PQP_INLAND_REV_AUTH_MILEAGE_RATES'
                             ,P_COLUMN_NAME         => '9999'
                             ,P_ROW_NAME            => '99999'
                             ,P_VALUE               => high_band_iram_rate
                             ,P_ERROR_MSG           => err_msg );
    calculated_ni_amt := car_prc_amt -(to_number(ni_rate) * car_tot_miles);
    IF car_tot_miles > 10000 THEN
       calculated_tax_amt := car_prc_amt - ((car_tot_miles - 10000) * to_number(high_band_iram_rate) + 10000 * to_number(low_band_iram_rate));
    ELSE
       calculated_tax_amt := car_prc_amt - (car_tot_miles * to_number(low_band_iram_rate));
    END IF;
    IF calculated_ni_amt < 0 THEN
        calculated_ni_amt := 0;
    END IF;
    IF calculated_tax_amt < 0 THEN
       calculated_tax_amt := 0;
    END IF;
    car_ni_diff := car_ni_amt - calculated_ni_amt;
    car_tax_diff := car_tax_amt - calculated_tax_amt;
    IF l_count1 <>0 THEN
     g_sum_bal_info(l_count1).NI_Amt := g_sum_bal_info(l_count1).NI_Amt - car_ni_diff;
     g_sum_bal_info(l_count1).Taxable_Amt := g_sum_bal_info(l_count1).Taxable_Amt - car_tax_diff;
    ELSE
     g_sum_bal_info(l_count4).NI_Amt := g_sum_bal_info(l_count4).NI_Amt - car_ni_diff;
     g_sum_bal_info(l_count4).Taxable_Amt := g_sum_bal_info(l_count4).Taxable_Amt - car_tax_diff;
    END IF;
   END IF;

   IF mc_tot_miles <> 0 THEN
    -- Calculation for MotorCycle NI Correction
    current_mc_ni_amt := get_balance_value(p_bal_info(1).assignment_id,'Motorcycle NI Even Amt');
    current_mc_tax_amt := get_balance_value(p_bal_info(1).assignment_id,'Motorcycle Taxable Even Amt');
    current_mc_prc_amt := get_balance_value(p_bal_info(1).assignment_id,'Motorcycle Casual Even Processed Amt')
                           + get_balance_value(p_bal_info(1).assignment_id,'Motorcycle Essential Even Processed Amt');
    current_mc_tot_miles := get_balance_value(p_bal_info(1).assignment_id,'Motorcycle Casual Even Actual Miles')
                           + get_balance_value(p_bal_info(1).assignment_id,'Motorcycle Essential Even Actual Miles');
    mc_ni_amt := mc_ni_amt + current_mc_ni_amt;
    mc_tax_amt := mc_tax_amt + current_mc_tax_amt;
    mc_prc_amt := mc_prc_amt + current_mc_prc_amt;
    mc_tot_miles := mc_tot_miles + current_mc_tot_miles;
    ret := PQP_UTILITIES.PQP_GB_GET_TABLE_VALUE
                             (P_BUSINESS_GROUP_ID   => NULL
                             ,P_EFFECTIVE_DATE      => sysdate
                             ,P_TABLE_NAME          => 'PQP_NIC_MILEAGE_RATES'
                             ,P_COLUMN_NAME         => '9999'
                             ,P_ROW_NAME            => 'MOTOR CYCLE'
                             ,P_VALUE               => ni_rate
                             ,P_ERROR_MSG           => err_msg );
    ret := PQP_UTILITIES.PQP_GB_GET_TABLE_VALUE
                             (P_BUSINESS_GROUP_ID   => NULL
                             ,P_EFFECTIVE_DATE      => sysdate
                             ,P_TABLE_NAME          => 'PQP_INLAND_REV_AUTH_MILEAGE_RATES'
                             ,P_COLUMN_NAME         => '9999'
                             ,P_ROW_NAME            => 'MOTOR CYCLE'
                             ,P_VALUE               => low_band_iram_rate
                             ,P_ERROR_MSG           => err_msg );
    calculated_ni_amt := mc_prc_amt -(to_number(ni_rate) * mc_tot_miles);
    calculated_tax_amt := mc_prc_amt -(to_number(low_band_iram_rate) * mc_tot_miles);
    IF calculated_ni_amt < 0 THEN
       calculated_ni_amt := 0;
    END IF;
    IF calculated_tax_amt < 0 THEN
       calculated_tax_amt := 0;
    END IF;
    mc_ni_diff := mc_ni_amt - calculated_ni_amt;
    mc_tax_diff := mc_tax_amt - calculated_tax_amt;
    IF l_count2 <>0 THEN
     g_sum_bal_info(l_count2).NI_Amt := g_sum_bal_info(l_count2).NI_Amt - mc_ni_diff;
     g_sum_bal_info(l_count2).Taxable_Amt := g_sum_bal_info(l_count2).Taxable_Amt - mc_tax_diff;
    ELSE
     g_sum_bal_info(l_count5).NI_Amt := g_sum_bal_info(l_count5).NI_Amt - mc_ni_diff;
     g_sum_bal_info(l_count5).Taxable_Amt := g_sum_bal_info(l_count5).Taxable_Amt - mc_tax_diff;
    END IF;
   END IF;


   IF pc_tot_miles <> 0 THEN
    -- Calculation for PedalCycle NI Correction
    current_pc_ni_amt := get_balance_value(p_bal_info(1).assignment_id,'Pedalcycle NI Even Amt');
    current_pc_tax_amt := get_balance_value(p_bal_info(1).assignment_id,'Pedalcycle Taxable Even Amt');
    current_pc_prc_amt := get_balance_value(p_bal_info(1).assignment_id,'Pedalcycle Casual Even Processed Amt')
                           + get_balance_value(p_bal_info(1).assignment_id,'Pedalcycle Essential Even Processed Amt');
    current_pc_tot_miles := get_balance_value(p_bal_info(1).assignment_id,'Pedalcycle Casual Even Actual Miles')
                           + get_balance_value(p_bal_info(1).assignment_id,'Pedalcycle Essential Even Actual Miles');
    pc_ni_amt := pc_ni_amt + current_pc_ni_amt;
    pc_tax_amt := pc_tax_amt + current_pc_tax_amt;
    pc_prc_amt := pc_prc_amt + current_pc_prc_amt;
    pc_tot_miles := pc_tot_miles + current_pc_tot_miles;
    ret := PQP_UTILITIES.PQP_GB_GET_TABLE_VALUE
                             (P_BUSINESS_GROUP_ID   => NULL
                             ,P_EFFECTIVE_DATE      => sysdate
                             ,P_TABLE_NAME          => 'PQP_NIC_MILEAGE_RATES'
                             ,P_COLUMN_NAME         => '9999'
                             ,P_ROW_NAME            => 'PEDAL CYCLE'
                             ,P_VALUE               => ni_rate
                             ,P_ERROR_MSG           => err_msg );
    ret := PQP_UTILITIES.PQP_GB_GET_TABLE_VALUE
                             (P_BUSINESS_GROUP_ID   => NULL
                             ,P_EFFECTIVE_DATE      => sysdate
                             ,P_TABLE_NAME          => 'PQP_INLAND_REV_AUTH_MILEAGE_RATES'
                             ,P_COLUMN_NAME         => '9999'
                             ,P_ROW_NAME            => 'PEDAL CYCLE'
                             ,P_VALUE               => low_band_iram_rate
                             ,P_ERROR_MSG           => err_msg );
    calculated_ni_amt := pc_prc_amt -(to_number(ni_rate) * pc_tot_miles);
    calculated_tax_amt := pc_prc_amt -(to_number(low_band_iram_rate) * pc_tot_miles);
    IF calculated_ni_amt < 0 THEN
       calculated_ni_amt := 0;
    END IF;
    IF calculated_tax_amt < 0 THEN
       calculated_tax_amt := 0;
    END IF;
    pc_ni_diff := pc_ni_amt - calculated_ni_amt;
    pc_tax_diff := pc_tax_amt - calculated_tax_amt;
    IF l_count3 <>0 THEN
     g_sum_bal_info(l_count3).NI_Amt := g_sum_bal_info(l_count3).NI_Amt - pc_ni_diff;
     g_sum_bal_info(l_count3).Taxable_Amt := g_sum_bal_info(l_count3).Taxable_Amt - pc_tax_diff;
    ELSE
     g_sum_bal_info(l_count6).NI_Amt := g_sum_bal_info(l_count6).NI_Amt - pc_ni_diff;
     g_sum_bal_info(l_count6).Taxable_Amt := g_sum_bal_info(l_count6).Taxable_Amt - pc_tax_diff;
    END IF;
   END IF;

    -- Add the Previous Year's NI balances(Which are processed in the current year) to the
    -- Vehicle Type NI balances
    IF l_count1 <>0 THEN
     g_sum_bal_info(l_count1).NI_Amt := g_sum_bal_info(l_count1).NI_Amt + prev_yr_car_ni_amt;
    ELSIF l_count4 <> 0 THEN
     g_sum_bal_info(l_count4).NI_Amt := g_sum_bal_info(l_count4).NI_Amt + prev_yr_car_ni_amt;
    END IF;
    IF l_count2 <>0 THEN
     g_sum_bal_info(l_count2).NI_Amt := g_sum_bal_info(l_count2).NI_Amt + prev_yr_mc_ni_amt;
    ELSIF l_count5 <> 0 THEN
     g_sum_bal_info(l_count5).NI_Amt := g_sum_bal_info(l_count5).NI_Amt + prev_yr_mc_ni_amt;
    END IF;
    IF l_count3 <>0 THEN
     g_sum_bal_info(l_count3).NI_Amt := g_sum_bal_info(l_count3).NI_Amt + prev_yr_pc_ni_amt;
    ELSIF l_count6 <> 0 THEN
     g_sum_bal_info(l_count6).NI_Amt := g_sum_bal_info(l_count6).NI_Amt + prev_yr_pc_ni_amt;
    END IF;

route_balance_amt;
END;




FUNCTION get_payroll_det (p_assignment_id          IN NUMBER
                         ,p_business_group_id      IN NUMBER
                         ,p_payroll_id             OUT NOCOPY NUMBER
                         ,p_consolidation_set_id   OUT NOCOPY NUMBER
                           )
RETURN DATE
IS

--Gets Payroll Id and Consolidation Set Id
CURSOR c_get_payroll_det (cp_assignment_id     NUMBER
                         ,cp_business_group_id NUMBER
                         ,cp_max_date          DATE)
IS
 SELECT  ppa.payroll_id
        ,ppa.consolidation_set_id
   FROM pay_assignment_actions  paa
       ,pay_payroll_actions     ppa
  WHERE paa.assignment_id= cp_assignment_id
    AND ppa.payroll_action_id=paa.payroll_action_id
    AND ppa.effective_date = cp_max_date
    AND ppa.business_group_id= cp_business_group_id
    AND ppa.action_type in ('R','Q')
    AND ppa.action_status='C'
    AND paa.action_status='C'
    AND paa.run_type_id IS NOT NULL;


--Gets latest payroll run date for the assignment
CURSOR c_get_max_date  (cp_assignment_id     NUMBER
                         ,cp_business_group_id NUMBER
                         )
IS
 SELECT  max(ppa.effective_date) effective_date
  FROM  pay_payroll_actions     ppa
       ,pay_assignment_actions  paa
  WHERE paa.assignment_id= cp_assignment_id
    AND ppa.payroll_action_id=paa.payroll_action_id
    AND ppa.business_group_id= cp_business_group_id
    AND ppa.action_type in ('R','Q')
    AND ppa.action_status='C'
    AND paa.action_status='C'
    AND paa.run_type_id IS NOT NULL;


l_get_payroll_det             c_get_payroll_det%ROWTYPE;
l_effective_date              DATE;
l_proc    varchar2(72) ;--:= g_package ||'get_effective_date';
BEGIN
hr_utility.set_location(l_proc,10);
  OPEN c_get_max_date ( p_assignment_id
                       ,p_business_group_id
                         );
  FETCH c_get_max_date INTO l_effective_date;
  CLOSE c_get_max_date;
  OPEN c_get_payroll_det ( p_assignment_id
                          ,p_business_group_id
                          ,l_effective_date
                         );
  FETCH c_get_payroll_det INTO l_get_payroll_det;
  hr_utility.set_location(l_proc,20);
  CLOSE c_get_payroll_det;
  p_payroll_id :=l_get_payroll_det.payroll_id;
  p_consolidation_set_id := l_get_payroll_det.consolidation_set_id;
  RETURN(l_effective_date);
 hr_utility.set_location(l_proc,30);
END;

-- This function returns the element_type_id given the Element Name
FUNCTION get_element_id (p_business_group_id      IN NUMBER
                        ,p_element_name           IN VARCHAR2
                        ,p_effective_date         IN DATE
                        )
RETURN NUMBER
IS

Cursor c_element_type is
   select element_type_id
   from   pay_element_types_f
   where  element_name = p_element_name
   and    business_group_id = p_business_group_id
   and    p_effective_date between effective_start_date
   and    effective_end_date;
l_element_id       pay_element_types_f.element_type_id%TYPE;
BEGIN

Open  c_element_type;
Fetch c_element_type into l_element_id;
Close c_element_type;

RETURN l_element_id;
END;

-- This function returns the element_link_id given the Element Type Id and Assignment Id
FUNCTION get_element_link
         (p_assignment_id          IN NUMBER
         ,p_business_group_id      IN NUMBER
         ,p_element_id             IN NUMBER
         ,p_effective_date         IN DATE
          )
RETURN NUMBER
IS
l_element_link_id  pay_element_links_f.element_link_id%TYPE;

BEGIN

l_element_link_id := hr_entry_api.get_link(
                           p_assignment_id,
                           p_element_id,
                           p_effective_date);

RETURN l_element_link_id;
END get_element_link;



-- This procedure creates the balance adjustment entry
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
            )
AS

l_element_name                 pay_element_types_f.element_name%TYPE;
l_element_type_id              pay_element_types_f.element_type_id%TYPE := NULL;
l_base_element_type_id         pay_element_types_f.element_type_id%TYPE;
l_input_val                    t_input_val;
l_element_link_id              pay_element_links_f.element_link_id%TYPE;
l_row_id                       VARCHAR2(60);
l_effective_start_date         DATE;
l_effective_end_date           DATE;
l_element_entry_id             NUMBER;
l_object_version_number        NUMBER;
l_create_warning               BOOLEAN;
l_err_count                    NUMBER;
l_cache_count                  NUMBER;



-- Get the Input Value Ids for a given Element Type Id
CURSOR c_get_input_val_id (cp_element_id NUMBER)
IS
SELECT piv.input_value_id
      ,piv.display_sequence
      ,piv.name
  FROM pay_input_values_f piv
 WHERE piv.element_type_id =cp_element_id
   AND p_effective_date BETWEEN piv.effective_start_date
                   AND piv.effective_end_date
 ORDER BY piv.display_sequence;

l_consol_set_id     pay_payroll_actions.consolidation_set_id%TYPE;
--l_base_ele_det      c_base_ele_lnk_det%ROWTYPE;
l_get_input_val_id  c_get_input_val_id%ROWTYPE;
l_count             number:=0;
l_payroll_id        per_all_assignments_f.payroll_id%TYPE;
l_effective_date    DATE;
BEGIN

--Check the Payroll Cache for Payroll Details
 IF g_payroll_det_cache.count > 0 THEN
  l_effective_date := g_payroll_det_cache(1).effective_date;
  l_payroll_id := g_payroll_det_cache(1).payroll_id;
  l_consol_set_id := g_payroll_det_cache(1).consolidation_set_id;
 ELSE
  l_effective_date :=get_payroll_det
                    (p_assignment_id         =>p_assignment_id
                    ,p_business_group_id     =>p_business_group_id
                    ,p_payroll_id            =>l_payroll_id
                    ,p_consolidation_set_id  =>l_consol_set_id
                     );
 -- Enter the Entry into the cache
 -- At any point of time there needs to be only one record in the table
 -- That is because we are processing the records assignment wise
 -- Therefore once the assignment is processed the table will be emptied
 -- and a new entry will be made in the cache when processing the next assignment
  g_payroll_det_cache(1).assignment_id := p_assignment_id;
  g_payroll_det_cache(1).business_group_id := p_business_group_id;
  g_payroll_det_cache(1).payroll_id := l_payroll_id;
  g_payroll_det_cache(1).consolidation_set_id := l_consol_set_id;
  g_payroll_det_cache(1).effective_date := l_effective_date;
 END IF;

 hr_utility.set_location('Entering Query for Element Id: '||p_element_name,dbms_utility.get_time);

--Check the Element Cache for Element Type Id
 FOR i in 1..g_element_cache.count
 LOOP
  IF g_element_cache(i).element_name = p_element_name
     and g_element_cache(i).business_group_id = p_business_group_id
     and g_element_cache(i).effective_date = p_effective_date   THEN
   l_element_type_id := g_element_cache(i).element_type_id;
   exit;
  END IF;
 END LOOP;

 IF l_element_type_id IS NULL THEN  -- Not Found in Cache
 l_element_type_id :=get_element_id
                     (p_business_group_id     =>p_business_group_id
                     ,p_element_name          =>p_element_name
                     ,p_effective_date        =>p_effective_date
                     );
 -- Enter the Entry into the cache
 l_cache_count := g_element_cache.count+1;
 g_element_cache(l_cache_count).element_name := p_element_name;
 g_element_cache(l_cache_count).business_group_id := p_business_group_id;
 g_element_cache(l_cache_count).effective_date := p_effective_date;
 g_element_cache(l_cache_count).element_type_id := l_element_type_id;
 END IF;

 l_base_element_type_id :=get_element_id
                     (p_business_group_id     =>p_business_group_id
                     ,p_element_name          =>p_base_element_name
                     ,p_effective_date        =>p_effective_date
                     );

--Check the Cache For Input value Ids corresponding the Element Type
 FOR i in 1..g_input_val_cache.count
 LOOP
  IF g_input_val_cache(i).element_type_id = l_element_type_id THEN
   l_input_val(1).input_value_id := g_input_val_cache(i).input_val_id1;
   l_input_val(2).input_value_id := g_input_val_cache(i).input_val_id2;
   l_input_val(3).input_value_id := g_input_val_cache(i).input_val_id3;
   l_input_val(4).input_value_id := g_input_val_cache(i).input_val_id4;
   l_input_val(5).input_value_id := g_input_val_cache(i).input_val_id5;
   l_input_val(6).input_value_id := g_input_val_cache(i).input_val_id6;
   l_input_val(7).input_value_id := g_input_val_cache(i).input_val_id7;
   l_input_val(8).input_value_id := g_input_val_cache(i).input_val_id8;
   l_input_val(9).input_value_id := g_input_val_cache(i).input_val_id9;
   l_input_val(10).input_value_id := g_input_val_cache(i).input_val_id10;
   l_input_val(11).input_value_id := g_input_val_cache(i).input_val_id11;
   l_input_val(12).input_value_id := g_input_val_cache(i).input_val_id12;
   l_input_val(13).input_value_id := g_input_val_cache(i).input_val_id13;
   l_input_val(14).input_value_id := g_input_val_cache(i).input_val_id14;
   l_input_val(15).input_value_id := g_input_val_cache(i).input_val_id15;
   exit;
  END IF;
 END LOOP;

IF l_input_val.count = 0 THEN  --Entry Not Present in Cache
 OPEN c_get_input_val_id(l_element_type_id);
  LOOP
   FETCH c_get_input_val_id INTO l_get_input_val_id;
   EXIT WHEN c_get_input_val_id%NOTFOUND;
   IF l_count=0 and l_get_input_val_id.display_sequence=2 THEN
    l_input_val(1).input_value_id :=NULL;
    l_input_val(2).input_value_id :=l_get_input_val_id.input_value_id;
    l_count:=1;
   ELSE
     l_count:=l_get_input_val_id.display_sequence;
     l_input_val(l_get_input_val_id.display_sequence).input_value_id
                       :=l_get_input_val_id.input_value_id;
   END IF;
  END LOOP;
 CLOSE c_get_input_val_id;
 IF l_input_val.count < 15 THEN
  FOR i in l_input_val.count+1..15
   LOOP
    l_input_val(i).input_value_id :=NULL;
   END LOOP;
 END IF;

-- Need to create a entry in the Cache
 l_cache_count := g_input_val_cache.count+1;
 g_input_val_cache(l_cache_count).input_val_id1 := l_input_val(1).input_value_id;
 g_input_val_cache(l_cache_count).input_val_id2 := l_input_val(2).input_value_id;
 g_input_val_cache(l_cache_count).input_val_id3 := l_input_val(3).input_value_id;
 g_input_val_cache(l_cache_count).input_val_id4 := l_input_val(4).input_value_id;
 g_input_val_cache(l_cache_count).input_val_id5 := l_input_val(5).input_value_id;
 g_input_val_cache(l_cache_count).input_val_id6 := l_input_val(6).input_value_id;
 g_input_val_cache(l_cache_count).input_val_id7 := l_input_val(7).input_value_id;
 g_input_val_cache(l_cache_count).input_val_id8 := l_input_val(8).input_value_id;
 g_input_val_cache(l_cache_count).input_val_id9 := l_input_val(9).input_value_id;
 g_input_val_cache(l_cache_count).input_val_id10 := l_input_val(10).input_value_id;
 g_input_val_cache(l_cache_count).input_val_id11 := l_input_val(11).input_value_id;
 g_input_val_cache(l_cache_count).input_val_id12 := l_input_val(12).input_value_id;
 g_input_val_cache(l_cache_count).input_val_id13 := l_input_val(13).input_value_id;
 g_input_val_cache(l_cache_count).input_val_id14 := l_input_val(14).input_value_id;
 g_input_val_cache(l_cache_count).input_val_id15 := l_input_val(15).input_value_id;


END IF;


/*OPEN c_base_ele_lnk_det(l_base_element_type_id);
   FETCH c_base_ele_lnk_det INTO l_base_ele_det;
CLOSE c_base_ele_lnk_det;*/
l_element_link_id:=get_element_link
                     (p_assignment_id          =>p_assignment_id
                     ,p_business_group_id      =>p_business_group_id
                     ,p_element_id             =>l_element_type_id
                     ,p_effective_date         =>l_effective_date
                      );

 hr_utility.set_location('Exiting Function Call for Element Link: '||l_element_link_id,dbms_utility.get_time);

if l_element_type_id is not null then
l_effective_start_date := NULL;
l_effective_end_date   := NULL;
 hr_utility.set_location('Entering  Function to Create Adjustment: '||l_effective_date,dbms_utility.get_time);
 -- Create the Balance Adjustment Entry
 pay_balance_adjustment_api.create_adjustment(
           p_effective_date           =>l_effective_date
          ,p_assignment_id            =>p_assignment_id
          ,p_consolidation_set_id     =>l_consol_set_id
          ,p_element_link_id          =>l_element_link_id
         --,p_entry_type               =>'E'
          ,p_input_value_id1          =>l_input_val(1).input_value_id
          ,p_input_value_id2          =>l_input_val(2).input_value_id
          ,p_input_value_id3          =>l_input_val(3).input_value_id
          ,p_input_value_id4          =>l_input_val(4).input_value_id
          ,p_input_value_id5          =>l_input_val(5).input_value_id
          ,p_input_value_id6          =>l_input_val(6).input_value_id
          ,p_input_value_id7          =>l_input_val(7).input_value_id
          ,p_input_value_id8          =>l_input_val(8).input_value_id
          ,p_input_value_id9          =>l_input_val(9).input_value_id
          ,p_input_value_id10         =>l_input_val(10).input_value_id
          ,p_input_value_id11         =>l_input_val(11).input_value_id
          ,p_input_value_id12         =>l_input_val(12).input_value_id
          ,p_input_value_id13         =>l_input_val(13).input_value_id
          ,p_input_value_id14         =>l_input_val(14).input_value_id
          ,p_input_value_id15         =>l_input_val(15).input_value_id
          ,p_entry_value1             =>p_entry_value1
          ,p_entry_value2             =>p_entry_value2
          ,p_entry_value3             =>p_entry_value3
          ,p_entry_value4             =>p_entry_value4
          ,p_entry_value5             =>p_entry_value5
          ,p_entry_value6             =>p_entry_value6
          ,p_entry_value7             =>p_entry_value7
          ,p_entry_value8             =>p_entry_value8
          ,p_entry_value9             =>p_entry_value9
          ,p_entry_value10            =>p_entry_value10
          ,p_entry_value11            =>p_entry_value11
          ,p_entry_value12            =>p_entry_value12
          ,p_entry_value13            =>p_entry_value13
          ,p_entry_value14            =>p_entry_value14
          ,p_entry_value15            =>p_entry_value15
          ,p_element_entry_id         =>l_element_entry_id
          ,p_effective_start_date     =>l_effective_start_date
          ,p_effective_end_date       =>l_effective_end_date
          ,p_object_version_number    =>l_object_version_number
          ,p_create_warning           =>l_create_warning
 );

end if;
adjustment_entry_count := adjustment_entry_count + 1;

EXCEPTION
---------
WHEN OTHERS THEN
 l_err_count := g_err_info.count;
 g_err_info(l_err_count+1).element_name := p_element_name;
 g_err_info(l_err_count+1).business_group_id := p_business_group_id;
 g_err_info(l_err_count+1).assignment_id := p_assignment_id;

END create_element_entry;

/*** This Function is used to get the balance values for Vehicle Type Ni amt and
     Vehicle Type Taxable Amt. ***/

FUNCTION get_balance_value ( p_assignment_id  IN NUMBER
                            ,p_balance_name          IN VARCHAR2
                    )
return NUMBER
IS
CURSOR c_get_balance_det
IS
SELECT balance_name,balance_type_id
  FROM pay_balance_types
 WHERE balance_name = p_balance_name;

CURSOR c_assignment_action_id
IS
select max(assignment_action_id)
from pay_assignment_actions
where assignment_id = p_assignment_id;

l_assignment_action_id    NUMBER;

cursor c_get_balance_val(cp_balance_type_id       NUMBER
          ,cp_assignment_action_id NUMBER)
is
select /*+ RULE*/ nvl(sum(fnd_number.canonical_to_number(TARGET.result_value) *
FEED.scale),0)  tot
 from
      pay_balance_feeds_f     FEED
     ,pay_run_result_values    TARGET
     ,pay_run_results          RR
     ,pay_payroll_actions      PACT
     ,pay_assignment_actions   ASSACT
     ,pay_payroll_actions      BACT
     ,per_time_periods         BPTP
     ,per_time_periods         PPTP
     ,pay_assignment_actions   BAL_ASSACT
     ,per_assignments_f        ASS
     ,per_assignments_f        START_ASS
WHERE BAL_ASSACT.assignment_action_id = cp_assignment_action_id
AND   BAL_ASSACT.payroll_action_id = BACT.payroll_action_id
AND   FEED.balance_type_id         = cp_balance_type_id
AND   FEED.input_value_id          = TARGET.input_value_id
AND   TARGET.run_result_id         = RR.run_result_id
AND   RR.assignment_action_id      = ASSACT.assignment_action_id
AND   ASSACT.payroll_action_id     = PACT.payroll_action_id
AND   PACT.effective_date BETWEEN
      FEED.effective_start_date AND FEED.effective_end_date
AND   RR.status in ('P','PA')
AND   BPTP.time_period_id       = BACT.time_period_id
AND   PPTP.time_period_id       = PACT.time_period_id

AND   START_ASS.assignment_id   = BAL_ASSACT.assignment_id
AND   ASS.period_of_service_id  = START_ASS.period_of_service_id
AND   ASSACT.assignment_id      = ASS.assignment_id
AND   BACT.effective_date BETWEEN
      START_ASS.effective_start_date AND START_ASS.effective_end_date
AND   PACT.effective_date BETWEEN
      ASS.effective_start_date AND ASS.effective_end_date
AND   PACT.effective_date >=
     /* find the latest td payroll transfer date - compare each of the */
     /* assignment rows with its predecessor looking for the payroll   */
     /* that had a different tax district at that date                 */
     (SELECT nvl(max(NASS.effective_start_date),
             to_date('01/01/0001', 'DD/MM/YYYY'))

      FROM   per_assignments_f           NASS
            ,pay_payrolls_f              ROLL
            ,hr_soft_coding_keyflex      FLEX
            ,per_assignments_f           PASS
            ,pay_payrolls_f              PROLL
            ,hr_soft_coding_keyflex      PFLEX
      WHERE NASS.assignment_id           = ASS.assignment_id
        AND   ROLL.payroll_id              = NASS.payroll_id
        AND   NASS.effective_start_date BETWEEN
            ROLL.effective_start_date AND ROLL.effective_end_date
        AND   ROLL.soft_coding_keyflex_id  = FLEX.soft_coding_keyflex_id
        AND   NASS.assignment_id           = PASS.assignment_id
        AND   PASS.effective_end_date      = (NASS.effective_start_date - 1)

        AND   NASS.effective_start_date   <= BACT.effective_date
        AND   PROLL.payroll_id             = PASS.payroll_id
        AND   NASS.effective_start_date BETWEEN
              PROLL.effective_start_date AND PROLL.effective_end_date
        AND   PROLL.soft_coding_keyflex_id = PFLEX.soft_coding_keyflex_id
        AND   NASS.payroll_id              <> PASS.payroll_id
        AND   FLEX.segment1                <> PFLEX.segment1 )
AND   EXISTS
     /*  check that the current assignment tax districts match  */
     (SELECT NULL
      FROM   pay_payrolls_f                 BROLL
            ,hr_soft_coding_keyflex         BFLEX
            ,pay_payrolls_f                 PROLL

            ,hr_soft_coding_keyflex         PFLEX
      WHERE  BACT.payroll_id              = BROLL.payroll_id
      AND    PACT.payroll_id              = PROLL.payroll_id
      AND    BFLEX.soft_coding_keyflex_id = BROLL.soft_coding_keyflex_id
      AND    PFLEX.soft_coding_keyflex_id = PROLL.soft_coding_keyflex_id
      AND    BACT.effective_date BETWEEN
             BROLL.effective_start_date AND BROLL.effective_end_date
      AND    BACT.effective_date BETWEEN
             PROLL.effective_start_date AND PROLL.effective_end_date
      AND    BFLEX.segment1               = PFLEX.segment1 )
AND   PPTP.regular_payment_date      >=
      /*  fin year start is last two years for a even tax year and last one
       *  year for a odd tax year

       */
      to_date('06-04-' || to_char( fnd_number.canonical_to_number(
          to_char( BPTP.regular_payment_date,'YYYY'))
             +  decode(sign(BPTP.regular_payment_date - to_date('06-04-'
                 || to_char(BPTP.regular_payment_date,'YYYY'),'DD-MM-YYYY')),
           -1,-1,0) -
          mod(
           fnd_number.canonical_to_number(
          to_char( BPTP.regular_payment_date,'YYYY'))
             +  decode(sign( BPTP.regular_payment_date - to_date('06-04-'
                 || to_char(BPTP.regular_payment_date,'YYYY'),'DD-MM-YYYY')),
           -1,0,-1),2)
          ),'DD-MM-YYYY')

AND  ASSACT.action_sequence <= BAL_ASSACT.action_sequence                       ;




l_get_balance_det        c_get_balance_det%ROWTYPE;
l_get_balance_val        c_get_balance_val%ROWTYPE;
l_balance_type_id        NUMBER := NULL;
l_cache_count            NUMBER;
BEGIN

--Check the Balance Cache for Balance Type Id
 FOR i in 1..g_balance_cache.count
 LOOP
  IF g_balance_cache(i).balance_name = p_balance_name THEN
   l_balance_type_id := g_balance_cache(i).balance_type_id;
   exit;
  END IF;
 END LOOP;

 IF l_balance_type_id IS NULL THEN
  OPEN c_get_balance_det;
  FETCH c_get_balance_det INTO l_get_balance_det;
  CLOSE c_get_balance_det;
  l_balance_type_id := l_get_balance_det.balance_type_id;
  -- Make An Entry in Balance Cache
  l_cache_count := g_balance_cache.count+1;
  g_balance_cache(l_cache_count).balance_name := p_balance_name;
  g_balance_cache(l_cache_count).balance_type_id := l_balance_type_id;
END IF;

 OPEN c_assignment_action_id;
 FETCH c_assignment_action_id into l_assignment_action_id;
 CLOSE c_assignment_action_id;

 OPEN c_get_balance_val(l_balance_type_id
         ,l_assignment_action_id);
 FETCH c_get_balance_val INTO l_get_balance_val;
     return(NVL(l_get_balance_val.tot,0));
 CLOSE c_get_balance_val;


return(0);
END;



FUNCTION get_balance_value ( p_assignment_action_id  IN NUMBER
                    ,p_element_entry_id      IN NUMBER
                    ,p_business_group_id     IN NUMBER
                    ,p_payroll_action_id     IN NUMBER
                    ,p_balance_name          IN VARCHAR2
                    )
return NUMBER
IS
CURSOR c_get_balance_det
IS
SELECT balance_name,balance_type_id
  FROM pay_balance_types
 WHERE balance_name = p_balance_name;

cursor c_get_balance_val(cp_balance_type_id       NUMBER
          ,cp_assignment_action_id NUMBER
          ,cp_element_entry_id     NUMBER
          ,cp_payroll_action_id    NUMBER)
is
SELECT  nvl((fnd_number.canonical_to_number(TARGET.result_value)
        * FEED.scale),0) tot
FROM pay_run_result_values   TARGET
,      pay_balance_feeds_f     FEED
,      pay_run_results         RR
,      pay_assignment_actions  ASSACT
,      pay_assignment_actions  BAL_ASSACT
,      pay_payroll_actions     PACT
WHERE  BAL_ASSACT.assignment_action_id = cp_assignment_action_id
AND    FEED.balance_type_id  = cp_balance_type_id
AND    FEED.input_value_id     = TARGET.input_value_id
AND    TARGET.run_result_id    = RR.run_result_id
AND    RR.assignment_action_id = ASSACT.assignment_action_id
AND    ASSACT.payroll_action_id = PACT.payroll_action_id
AND    assact.payroll_action_id = cp_payroll_action_id
AND    PACT.effective_date between FEED.effective_start_date
                               AND FEED.effective_end_date
AND    RR.status in ('P','PA')
AND    ASSACT.action_sequence <= BAL_ASSACT.action_sequence
AND    ASSACT.assignment_id = BAL_ASSACT.assignment_id
AND    (( RR.source_id = cp_element_entry_id and source_type in ( 'E','I'))
 OR    ( rr.source_type in ('R','V') /* reversal */
                AND exists
                ( SELECT null from pay_run_results rr1
                  WHERE rr1.source_id = cp_element_entry_id
                  AND   rr1.run_result_id = rr.source_id
                  AND   rr1.source_type in ( 'E','I'))));




l_get_balance_det        c_get_balance_det%ROWTYPE;
l_get_balance_val        c_get_balance_val%ROWTYPE;
l_balance_type_id        NUMBER := NULL;
l_cache_count            NUMBER;
BEGIN

--Check the Balance Cache for Balance Type Id
 FOR i in 1..g_balance_cache.count
 LOOP
  IF g_balance_cache(i).balance_name = p_balance_name THEN
   l_balance_type_id := g_balance_cache(i).balance_type_id;
   exit;
  END IF;
 END LOOP;

 IF l_balance_type_id IS NULL THEN
  OPEN c_get_balance_det;
  FETCH c_get_balance_det INTO l_get_balance_det;
  CLOSE c_get_balance_det;
  l_balance_type_id := l_get_balance_det.balance_type_id;
  -- Make An Entry in Balance Cache
  l_cache_count := g_balance_cache.count+1;
  g_balance_cache(l_cache_count).balance_name := p_balance_name;
  g_balance_cache(l_cache_count).balance_type_id := l_balance_type_id;
END IF;

 OPEN c_get_balance_val(l_balance_type_id
         ,p_assignment_action_id
         ,p_element_entry_id
         ,p_payroll_action_id);
 FETCH c_get_balance_val INTO l_get_balance_val;
     return(NVL(l_get_balance_val.tot,0));
 CLOSE c_get_balance_val;


return(0);
END;


-------------------------------------------------------------
PROCEDURE Initialize_Balances(p_business_group_id IN NUMBER)
AS
--This cursor gets all the information on mileage claims
--necessary to initialize vehicle balances
--here the logic to get the are based on the date passed to
--the cursor as this date determines the date upto which the
--adjustment has to be done.This date is compared with
--creation date in pay payroll action table since the payroll
--could be run for future dates.
CURSOR c_get_info(cp_patch_status VARCHAR2
                  ,cp_effective_date DATE)
IS
Select prr.source_id element_entry_id
      ,prr.assignment_action_id
      ,prr.element_type_id
      ,pet.element_name element_name
      ,pet.business_group_id business_group_id
      ,paa.assignment_id assignment_id
      ,paa.payroll_action_id
      ,petei.EEI_INFORMATION1 Vehicle_Type
      ,ppa.effective_date effective_start_date
      ,prr.run_result_id
      ,prr.source_type
      ,prr.source_id
      ,to_char(NULL) usage_type
      ,to_char(NULL)  Ownership
      ,to_char(NULL) additional_passenger
      ,to_char(NULL) Paye_taxable
      ,to_date(NULL) Claim_end_date
      ,to_char(NULL) Rates_table
      ,to_number(NULL) Engine_capacity
      ,to_char(NULL) Calculation_Method
      ,to_number(NULL) Claimed_Mileage
      ,to_number(NULL) Actual_Mileage
From pay_element_types_f pet
     ,pay_element_type_extra_info petei
     ,pay_assignment_actions paa
     ,pay_run_results prr
     ,pay_payroll_actions ppa
WHERE pet.business_group_id = p_business_group_id
  AND pet.element_type_id=petei.element_type_id
  AND petei.information_type='PQP_VEHICLE_MILEAGE_INFO'
  AND petei.eei_information_category='PQP_VEHICLE_MILEAGE_INFO'
  AND petei.EEI_INFORMATION1 in ('C','P','CM','CP','PP','PM')
  AND prr.element_type_id=pet.element_type_id
  AND prr.assignment_action_id=paa.assignment_action_id
  AND ppa.payroll_action_id=paa.payroll_action_id
  AND ppa.business_group_id= pet.business_group_id
  AND ppa.effective_date >= to_date('04/06/2003','MM/DD/YYYY')
  AND TRUNC(ppa.creation_date) < cp_effective_date
  AND (cp_patch_status='N'
       OR  Exists(SELECT 'X'
                  FROM pay_us_rpt_totals
                  WHERE state_name = 'CARMILEAGE_UPGRADE'
                    AND tax_unit_id=250
                    AND location_id = paa.assignment_id
                    AND business_group_id = p_business_group_id))
--  AND prr.source_type in ('E','R')
 ORDER BY paa.assignment_id,ppa.effective_date,prr.run_result_id;


CURSOR c_get_input_values (cp_run_result_id NUMBER)
IS
  SELECT piv.input_value_id
      ,piv.name
      ,prrv.result_value entry_value
      ,piv.display_sequence
  FROM pay_input_values_f piv
       ,pay_run_result_values prrv
 WHERE prrv.run_result_id = cp_run_result_id
      AND piv.input_value_id=prrv.input_value_id
      AND piv.name IN ('Vehicle Type'
                    ,'Rate Type'
                    ,'No of Passengers'
                    ,'PAYE Taxable'
                    ,'Claim End Date'
                    ,'User Rates Table'
                    ,'Engine Capacity'
                    ,'Calculation Method'
                    ,'Claimed Mileage'
                    ,'Actual Mileage'
                     );
-- Get Previous Adjustment Process Status. If 'C' , then it is complete.
-- If 'P' then it is Partially Processed. If No Entry exists then the adjustment
-- Process hasn't been run before.
CURSOR c_patch_status
IS
select status
from pay_patch_status
where patch_name = 'CARMILEAGE_BALANCE_ADJ'
and patch_number = p_business_group_id
and phase = 'CARMILEAGE_BALANCE_ADJ';

-- Get the Date of Upgrade.
CURSOR c_upgrade_patch_status
IS
select update_date
from pay_patch_status
where patch_name = 'CARMILEAGE_UPDATE'
and patch_number = -100;

l_update_date                  DATE;
l_get_input_values             c_get_input_values%ROWTYPE;
l_get_info                     c_get_info%ROWTYPE;
l_bal_info                     t_bal_info;
l_count                        NUMBER :=0;
l_assignment_id                per_all_assignments_f.assignment_id%TYPE :=NULL;
l_proc_miles                   NUMBER;
l_act_miles                    NUMBER;
l_proc_amt                     NUMBER;
l_iram_amt                     NUMBER;
l_effective_start_date         DATE;
l_effective_end_date           DATE;
l_element_entry_date           DATE;
l_element_entry_id             NUMBER;
l_old_element_entry_id         NUMBER:= -1;
l_object_version_number        NUMBER;
l_create_warning               BOOLEAN;
l_ret_val                      NUMBER;
l_effective_date               DATE;
l_eng_capacity                 number;
l_rates_table                  PAY_USER_TABLES.USER_TABLE_NAME%TYPE;
l_calc_method                  VARCHAR2(1);
l_err_msg                      VARCHAR2(80);
l_fuel_type                    VARCHAR2(80);
l_addl_pass_amt                NUMBER(9,2);
l_ni_amt                       NUMBER(9,2);
l_tax_amt                      NUMBER(9,2);
l_addl_ni_amt                  NUMBER(9,2);
l_addl_tax_amt                 NUMBER(9,2);
l_defined_balance_id           pay_defined_balances.defined_balance_id%TYPE;
l_tax_free_amt                 NUMBER(9,2);
l_ni_free_amt                  NUMBER(9,2);
l_lo_eng_cap                   NUMBER;
l_hi_eng_cap                   NUMBER;
l_mileage_band                 NUMBER;
h_mileage_band                 NUMBER;
l_band_rate                    NUMBER;
h_band_rate                    NUMBER;
l_status_count                 NUMBER:=1;
total_paye_taxable_cl_miles    NUMBER;
--Pick all the element entries for that assignments which are fully or
--Partially processed.


---Start summing Element level ITD balances for Processed Amt,Processed Miles,Actual Miles
---stripped by Vehicle Types.


--Pick all the additional passenger element entries sum up the total

--Create element entries for the last Processed or partially processed and enter
--these values to the input values.

BEGIN

 OPEN c_patch_status;
  FETCH c_patch_status into l_prev_upgrade_status;
 CLOSE c_patch_status;
 --l_status_count keeps a count of the number of records in pay_patch_status
 --If 0 then it this the first run
 IF l_prev_upgrade_status is null THEN
   l_status_count := 0;
 END IF;

 l_prev_upgrade_status := NVL(l_prev_upgrade_status,'N');
 hr_utility.set_location('Up Grade Status '||l_prev_upgrade_status,1);

 IF l_prev_upgrade_status in ('N','P') THEN
  OPEN c_upgrade_patch_status;
   FETCH c_upgrade_patch_status INTO l_update_date;
  CLOSE c_upgrade_patch_status;

  OPEN c_get_info(l_prev_upgrade_status
                 ,l_update_date);
  LOOP
   FETCH c_get_info INTO l_get_info;
   EXIT WHEN c_get_info%NOTFOUND;
   OPEN c_get_input_values (l_get_info.run_result_id);
    LOOP
     FETCH  c_get_input_values INTO  l_get_input_values;
     EXIT WHEN  c_get_input_values%NOTFOUND;
      IF l_get_input_values.name='Vehicle Type' OR
         l_get_input_values.name='Rate Type' THEN
        l_get_info.usage_type:=l_get_input_values.entry_value;

        IF l_get_info.usage_type='E' OR l_get_info.usage_type='C' THEN
         l_get_info.ownership:='P';
        ELSIF l_get_info.usage_type='P' OR l_get_info.usage_type='S' THEN
         l_get_info.ownership:='C';
        END IF;

      ELSIF l_get_input_values.name='Claim End Date' THEN
        l_get_info.Claim_End_Date:=
                    fnd_date.canonical_to_date(l_get_input_values.entry_value);

      ELSIF l_get_input_values.name='User Rates Table' THEN
        l_get_info.Rates_Table:=l_get_input_values.entry_value;

      ELSIF l_get_input_values.name='Engine Capacity' THEN
         l_get_info.engine_capacity:=l_get_input_values.entry_value;

      ELSIF l_get_input_values.name='Calculation Method' THEN
        l_get_info.calculation_method:=l_get_input_values.entry_value;

      ELSIF l_get_input_values.name='No of Passengers' THEN
        l_get_info.additional_passenger:=l_get_input_values.entry_value;

      ELSIF l_get_input_values.name='PAYE Taxable' THEN
         l_get_info.paye_taxable:=l_get_input_values.entry_value;

      ELSIF l_get_input_values.name='Claimed Mileage' THEN
         l_get_info.Claimed_Mileage:=l_get_input_values.entry_value;

      ELSIF l_get_input_values.name='Actual Mileage' THEN
         l_get_info.Actual_Mileage:=l_get_input_values.entry_value;

      END IF;



   END LOOP;
   CLOSE  c_get_input_values;


   IF l_assignment_id IS NULL
      OR l_assignment_id <>l_get_info.assignment_id THEN
      IF l_assignment_id IS NOT NULL THEN
         --Sum up all the balances and create element entry for that assignment
         categorize_balances (p_bal_info =>  l_bal_info);
         l_bal_info.delete;
      END IF;
      comp_tot_paye_tax_cl_miles := 0;
      priv_tot_paye_tax_cl_miles := 0;
      prev_yr_car_ni_amt         :=0;
      prev_yr_mc_ni_amt          :=0;
      prev_yr_pc_ni_amt          :=0;
      l_assignment_id :=l_get_info.assignment_id;
   END IF;

   IF l_get_info.paye_Taxable = 'N' and l_get_info.Claim_End_Date >= to_date('04/06/2003','MM/DD/YYYY') THEN

     --Call balance functions
     l_count:=l_bal_info.count;
     l_effective_date := TRUNC(pqp_car_mileage_functions.
                          pqp_get_date_paid(l_get_info.payroll_action_id));
     --Get the Processed Miles for the particular Entry
     l_proc_miles :=pqp_clm_bal.get_vehicletype_balance
                   (p_assignment_id        =>l_get_info.assignment_id
                   ,p_business_group_id    =>l_get_info.business_group_id
                   ,p_vehicle_type         =>l_get_info.vehicle_type
                   ,p_ownership            =>l_get_info.ownership
                   ,p_usage_type           =>l_get_info.usage_type
                   ,p_balance_name         =>'Processed Miles'
                   ,p_element_entry_id     =>l_get_info.element_entry_id
                   ,p_assignment_action_id =>l_get_info.assignment_action_id
                    );

     --Get the Actual Miles for the particular Entry
     l_act_miles :=pqp_clm_bal.get_vehicletype_balance
                   (p_assignment_id        =>l_get_info.assignment_id
                   ,p_business_group_id    =>l_get_info.business_group_id
                   ,p_vehicle_type         =>l_get_info.vehicle_type
                   ,p_ownership            =>l_get_info.ownership
                   ,p_usage_type           =>l_get_info.usage_type
                   ,p_balance_name         =>'Processed Actual Miles'
                   ,p_element_entry_id     =>l_get_info.element_entry_id
                   ,p_assignment_action_id =>l_get_info.assignment_action_id
                    );

     -- This has been added because previous formula didn't return value to input value ITD_ACT_MILES
     -- for company claims. As a result Querying up balance for this value will return 0. Therefore for
     -- Company claims we use the run result value.
     IF l_get_info.ownership = 'C' THEN
      l_act_miles := l_get_info.Actual_Mileage;
      IF l_act_miles is NULL then
         l_act_miles := l_get_info.Claimed_Mileage;
      END IF;
     END IF;

     --Get the Processed Amt for the particular Entry
     l_proc_amt :=pqp_clm_bal.get_vehicletype_balance
                   (p_assignment_id        =>l_get_info.assignment_id
                   ,p_business_group_id    =>l_get_info.business_group_id
                   ,p_vehicle_type         =>l_get_info.vehicle_type
                   ,p_ownership            =>l_get_info.ownership
                   ,p_usage_type           =>l_get_info.usage_type
                   ,p_balance_name         =>'Processed Amt'
                   ,p_element_entry_id     =>l_get_info.element_entry_id
                   ,p_assignment_action_id =>l_get_info.assignment_action_id
                    );

     hr_utility.set_location('***** PROCESSED AMT: ',l_proc_amt);

     --Get the IRAM Amt for the particular Entry
     l_iram_amt :=pqp_clm_bal.get_vehicletype_balance
                   (p_assignment_id        =>l_get_info.assignment_id
                   ,p_business_group_id    =>l_get_info.business_group_id
                   ,p_vehicle_type         =>l_get_info.vehicle_type
                   ,p_ownership            =>l_get_info.ownership
                   ,p_usage_type           =>l_get_info.usage_type
                   ,p_balance_name         =>'IRAM Amt'
                   ,p_element_entry_id     =>l_get_info.element_entry_id
                   ,p_assignment_action_id =>l_get_info.assignment_action_id
                    );
     IF l_get_info.additional_passenger <> 0 THEN
      l_ret_val:= pqp_car_mileage_functions.pqp_get_attr_val
                  (p_assignment_id          =>l_get_info.assignment_id
                  ,p_business_group_id      =>l_get_info.business_group_id
                  ,p_payroll_action_id      =>l_get_info.payroll_action_id
                  ,p_car_type               =>l_get_info.usage_type
                  ,p_cc                     =>l_eng_capacity
                  ,p_rates_table            =>l_rates_table
                  ,p_calc_method            =>l_calc_method
                  ,p_error_msg              =>l_err_msg
                  ,p_claim_date             =>l_get_info.claim_end_date
                  ,p_fuel_type              =>l_fuel_type
                  );

      l_rates_table :=NVL(l_get_info.rates_table,l_rates_table);
      l_eng_capacity:=NVL(l_get_info.engine_capacity,l_eng_capacity);
      l_calc_method:=NVL(l_get_info.calculation_method,l_calc_method);
      IF l_get_info.source_type <> 'R' and l_get_info.source_type <> 'V' THEN
       IF l_get_info.ownership = 'C' THEN
        l_ret_val:=pqp_car_mileage_functions.pqp_get_addlpasg_rate
                  (p_business_group_id       =>l_get_info.business_group_id
                  ,p_payroll_action_id       =>l_get_info.payroll_action_id
                  ,p_vehicle_type            =>l_get_info.usage_type
                  ,p_claimed_mileage         =>abs(l_proc_miles)
                  ,p_itd_miles               =>0
                  ,p_total_passengers        =>abs(l_get_info.additional_passenger)
                  ,p_total_pasg_itd_val      =>0
                  ,p_cc                      =>l_eng_capacity
                  ,p_rates_table             =>l_rates_table
                  ,p_claim_end_date          =>l_get_info.claim_end_date
                  ,p_tax_free_amt            =>l_addl_pass_amt
                  ,p_ni_amt                  =>l_addl_ni_amt
                  ,p_tax_amt                 =>l_addl_tax_amt
                  ,p_err_msg                 =>l_err_msg
                  );
       ELSE
        l_ret_val:=pqp_car_mileage_functions.pqp_get_passenger_rate
                  (p_business_group_id       =>l_get_info.business_group_id
                  ,p_payroll_action_id       =>l_get_info.payroll_action_id
                  ,p_vehicle_type            =>l_get_info.usage_type
                  ,p_claimed_mileage         =>abs(l_proc_miles)
                  ,p_cl_itd_miles            =>0
                  ,p_actual_mileage          =>abs(l_act_miles)
                  ,p_ac_itd_miles            =>0
                  ,p_total_passengers        =>abs(l_get_info.additional_passenger)
                  ,p_total_pasg_itd_val      =>0
                  ,p_cc                      =>l_eng_capacity
                  ,p_rates_table             =>l_rates_table
                  ,p_claim_end_date          =>l_get_info.claim_end_date
                  ,p_tax_free_amt            =>l_addl_pass_amt
                  ,p_ni_amt                  =>l_addl_ni_amt
                  ,p_tax_amt                 =>l_addl_tax_amt
                  ,p_err_msg                 =>l_err_msg
                  );
       END IF;
      END IF;
      -- If the Run Result Entry is caused by Reverse Run then we need to find the
      -- the original entry and fine the processed values
      IF l_get_info.source_type = 'R' or l_get_info.source_type = 'V' THEN
        FOR i in 1..l_bal_info.count
        LOOP
         IF l_bal_info(i).run_result_id = l_get_info.source_id THEN
          l_addl_pass_amt := -l_bal_info(i).Addl_Pasg_Amt;
          l_addl_ni_amt := -l_bal_info(i).Addl_Ni_Amt;
          l_addl_tax_amt := -l_bal_info(i).Addl_Tax_Amt;
          EXIT;
         END IF;
        END LOOP;
      hr_utility.set_location('***** ADDL PROCESSED AMT: ',l_addl_pass_amt);
      END IF;

      hr_utility.set_location('Addl Pass Amt **'||l_addl_pass_amt,3);
      l_bal_info(l_count+1).Addl_Pasg_Amt          :=l_addl_pass_amt;
      l_bal_info(l_count+1).Addl_Ni_Amt            :=l_addl_ni_amt;
      l_bal_info(l_count+1).Addl_Tax_Amt           :=l_addl_tax_amt;
      l_bal_info(l_count+1).Addl_Pasg_Miles        :=l_proc_miles;
      l_bal_info(l_count+1).Addl_Pasg_Act_Miles    :=l_act_miles;
     END IF;
     --This section must be moved to sum proceure since we cannot get
     --itd level taxable amt which we may have to calculate.
     IF l_get_info.ownership='P' THEN
      l_ni_amt := get_balance_value
                          (p_assignment_action_id  => l_get_info.assignment_action_id
                          ,p_element_entry_id      => l_get_info.element_entry_id
                          ,p_business_group_id     => l_get_info.business_group_id
                          ,p_payroll_action_id     => l_get_info.payroll_action_id
                          ,p_balance_name          => 'Mileage Even Taxable Amt'
                           );
     --Calculate Taxable amt ( In the Previous template , NI Amt and Taxable Amt got inter-changed )
     l_tax_amt := get_balance_value
                          (p_assignment_action_id  => l_get_info.assignment_action_id
                          ,p_element_entry_id      => l_get_info.element_entry_id
                          ,p_business_group_id     => l_get_info.business_group_id
                          ,p_payroll_action_id     => l_get_info.payroll_action_id
                          ,p_balance_name          => 'NI Even Amt'
                           );
     l_bal_info(l_count+1).NI_Amt                 := l_ni_amt;
     l_bal_info(l_count+1).Taxable_Amt            := l_tax_amt;
     END IF;


     --l_bal_info(l_count+1).NI_Amt                 :=0;
     --l_bal_info(l_count+1).Taxable_Amt            :=0;
     l_bal_info(l_count+1).PAYE_Taxable           :='N';
     l_bal_info(l_count+1).Ownership_Type         :=l_get_info.ownership;
     l_bal_info(l_count+1).Vehicle_Type           :=l_get_info.vehicle_type;
     l_bal_info(l_count+1).Usage_Type             :=l_get_info.usage_type;
     l_bal_info(l_count+1).Element_Name           :=l_get_info.element_name;
     l_bal_info(l_count+1).Processed_Miles        :=l_proc_miles     ;
     l_bal_info(l_count+1).Processed_Act_Miles    :=l_act_miles;
     l_bal_info(l_count+1).Processed_Amt          :=l_proc_amt;
     l_bal_info(l_count+1).IRAM_Amt               :=l_iram_amt;
     l_bal_info(l_count+1).assignment_id          :=l_get_info.assignment_id;
     l_bal_info(l_count+1).business_group_id      :=l_get_info.business_group_id;
     l_bal_info(l_count+1).effective_date         :=l_get_info.effective_start_date;
     l_bal_info(l_count+1).run_result_id          :=l_get_info.run_result_id;



   ELSIF l_get_info.element_entry_id <> l_old_element_entry_id
    AND l_get_info.Claim_End_Date >= to_date('04/06/2003','MM/DD/YYYY') THEN
     --If Entry is Paye Taxable , Amount to be paid will have to be calculated
     l_count:=l_bal_info.count;
     l_effective_date := TRUNC(pqp_car_mileage_functions.
                          pqp_get_date_paid(l_get_info.payroll_action_id));
      /**       Calculation of PAYE Taxable amount            **/

     IF l_get_info.source_type <> 'R' and l_get_info.source_type <> 'V'THEN
      l_ret_val:= pqp_car_mileage_functions.pqp_get_attr_val
                  (p_assignment_id          =>l_get_info.assignment_id
                  ,p_business_group_id      =>l_get_info.business_group_id
                  ,p_payroll_action_id      =>l_get_info.payroll_action_id
                  ,p_car_type               =>l_get_info.usage_type
                  ,p_cc                     =>l_eng_capacity
                  ,p_rates_table            =>l_rates_table
                  ,p_calc_method            =>l_calc_method
                  ,p_error_msg              =>l_err_msg
                  ,p_claim_date             =>l_get_info.claim_end_date
                  ,p_fuel_type              =>l_fuel_type
                  );

      l_rates_table :=NVL(l_get_info.rates_table,l_rates_table);
      l_eng_capacity:=NVL(l_get_info.engine_capacity,l_eng_capacity);
      l_calc_method:=NVL(l_get_info.calculation_method,l_calc_method);


      l_ret_val:= pqp_car_mileage_functions.pqp_get_range
                  (p_assignment_id      => l_get_info.assignment_id
                  ,p_business_group_id   => l_get_info.business_group_id
                  ,p_payroll_action_id   =>l_get_info.payroll_action_id
                  ,p_table_name          =>l_rates_table
                  ,p_row_or_column       =>'COL'
                  ,p_value               => l_eng_capacity
                  ,p_claim_date          =>l_get_info.claim_end_date
                  ,p_low_value           =>l_lo_eng_cap
                  ,p_high_value          =>l_hi_eng_cap);
      IF l_get_info.ownership = 'C' THEN
        total_paye_taxable_cl_miles := comp_tot_paye_tax_cl_miles;
        comp_tot_paye_tax_cl_miles := comp_tot_paye_tax_cl_miles + l_get_info.Claimed_Mileage;
      ELSE
        total_paye_taxable_cl_miles := priv_tot_paye_tax_cl_miles;
        priv_tot_paye_tax_cl_miles := priv_tot_paye_tax_cl_miles + l_get_info.Claimed_Mileage;
      END IF;

      l_ret_val:= pqp_car_mileage_functions.pqp_get_range
                  (p_assignment_id       => l_get_info.assignment_id
                  ,p_business_group_id   => l_get_info.business_group_id
                  ,p_payroll_action_id   =>l_get_info.payroll_action_id
                  ,p_table_name          =>l_rates_table
                  ,p_row_or_column       =>'ROW'
                  ,p_value               => l_get_info.Claimed_Mileage + total_paye_taxable_cl_miles
                  ,p_claim_date          =>l_get_info.claim_end_date
                  ,p_low_value           =>l_mileage_band
                  ,p_high_value          =>h_mileage_band);
      -- Get the Lower Mileage Band Rate
      l_band_rate:= pqp_car_mileage_functions.pqp_get_table_value
                  (p_bus_group_id      => l_get_info.business_group_id
                  ,p_payroll_action_id => l_get_info.payroll_action_id
                  ,p_table_name        => l_rates_table
                  ,p_col_name          => l_hi_eng_cap
                  ,p_row_value         => l_mileage_band
                  ,p_effective_date    => l_get_info.claim_end_date
                  ,p_error_msg         => l_err_msg);

      -- Get the Higher Mileage Band Rate
       h_band_rate:= pqp_car_mileage_functions.pqp_get_table_value
                  (p_bus_group_id      => l_get_info.business_group_id
                  ,p_payroll_action_id => l_get_info.payroll_action_id
                  ,p_table_name        => l_rates_table
                  ,p_col_name          => l_hi_eng_cap
                  ,p_row_value         => h_mileage_band
                  ,p_effective_date    => l_get_info.claim_end_date
                  ,p_error_msg         => l_err_msg);

      IF l_mileage_band <>0 and total_paye_taxable_cl_miles < l_mileage_band THEN
          l_proc_amt := ((l_get_info.Claimed_Mileage + total_paye_taxable_cl_miles)-l_mileage_band)*h_band_rate
                         + (l_mileage_band - total_paye_taxable_cl_miles)*l_band_rate;
      ELSE
           l_proc_amt := l_get_info.Claimed_Mileage *h_band_rate;
      END IF;
     END IF;
     -- If the Run Result Entry is caused by Reverse Run then we need to find the
     -- the original entry and find the processed values
     IF l_get_info.source_type = 'R' or l_get_info.source_type = 'V' THEN
       FOR i in 1..l_bal_info.count
       LOOP
        IF l_bal_info(i).run_result_id = l_get_info.source_id THEN
         l_proc_amt :=   -l_bal_info(i).Processed_Amt;
         IF l_bal_info(i).Addl_Pasg_Amt IS NOT NULL THEN
          l_addl_pass_amt := -l_bal_info(i).Addl_Pasg_Amt;
         END IF;
         EXIT;
        END IF;
       END LOOP;
     END IF;
     hr_utility.set_location('***** PROCESSED AMT: ',l_proc_amt);


     IF l_get_info.additional_passenger <> 0 THEN
      IF l_get_info.source_type <> 'R' and l_get_info.source_type <> 'V'THEN
       l_ret_val:=pqp_car_mileage_functions.pqp_get_addlpasg_rate
                  (p_business_group_id       =>l_get_info.business_group_id
                  ,p_payroll_action_id       =>l_get_info.payroll_action_id
                  ,p_vehicle_type            =>l_get_info.usage_type
                  ,p_claimed_mileage         =>l_proc_miles
                  ,p_itd_miles               =>0
                  ,p_total_passengers        =>l_get_info.additional_passenger
                  ,p_total_pasg_itd_val      =>0
                  ,p_cc                      =>l_eng_capacity
                  ,p_rates_table             =>l_rates_table
                  ,p_claim_end_date          =>l_get_info.claim_end_date
                  ,p_tax_free_amt            =>l_addl_pass_amt
                  ,p_ni_amt                  =>l_addl_ni_amt
                  ,p_tax_amt                 =>l_addl_tax_amt
                  ,p_err_msg                 =>l_err_msg
                  );
      END IF;
      --l_proc_amt := l_proc_amt + l_addl_pass_amt;
      l_bal_info(l_count+1).Addl_Pasg_Amt          :=l_addl_pass_amt;
      l_bal_info(l_count+1).Addl_Ni_Amt            := 0;
      l_bal_info(l_count+1).Addl_Tax_Amt           := 0;
      l_bal_info(l_count+1).Addl_Pasg_Miles        := l_get_info.Claimed_Mileage;
      l_bal_info(l_count+1).Addl_Pasg_Act_Miles    :=0;
     END IF;
     hr_utility.set_location('***** ADDL PROCESSED AMT: ',l_addl_pass_amt);

     l_bal_info(l_count+1).NI_Amt                 := 0;
     l_bal_info(l_count+1).Taxable_Amt            := 0;
     l_bal_info(l_count+1).PAYE_Taxable           :='Y';
     l_bal_info(l_count+1).Ownership_Type         :=l_get_info.ownership;
     l_bal_info(l_count+1).Vehicle_Type           :=l_get_info.vehicle_type;
     l_bal_info(l_count+1).Usage_Type             :=l_get_info.usage_type;
     l_bal_info(l_count+1).Element_Name           :=l_get_info.element_name;
     l_bal_info(l_count+1).Processed_Miles        :=l_get_info.Claimed_Mileage;
     l_bal_info(l_count+1).Processed_Act_Miles    :=0;
     l_bal_info(l_count+1).Processed_Amt          :=l_proc_amt;
     l_bal_info(l_count+1).IRAM_Amt               :=0;
     l_bal_info(l_count+1).assignment_id          :=l_get_info.assignment_id;
     l_bal_info(l_count+1).business_group_id      :=l_get_info.business_group_id;
     l_bal_info(l_count+1).effective_date         :=l_get_info.effective_start_date;
     l_bal_info(l_count+1).run_result_id          :=l_get_info.run_result_id;

   ELSIF l_get_info.paye_Taxable = 'N' and l_get_info.ownership='P' THEN
   -- This means the claim is not PAYE Taxable but is claimed for the previous year
   -- but processed for the current year. This is for NI amt balances.
     l_ni_amt := get_balance_value
                    (p_assignment_action_id  => l_get_info.assignment_action_id
                    ,p_element_entry_id      => l_get_info.element_entry_id
                    ,p_business_group_id     => l_get_info.business_group_id
                    ,p_payroll_action_id     => l_get_info.payroll_action_id
                    ,p_balance_name          => 'Mileage Odd Taxable Amt'
                    );
     IF l_get_info.vehicle_type = 'P' THEN
        prev_yr_car_ni_amt := prev_yr_car_ni_amt + l_ni_amt;
     ELSIF l_get_info.vehicle_type = 'PM' THEN
        prev_yr_mc_ni_amt := prev_yr_mc_ni_amt + l_ni_amt;
     ELSIF l_get_info.vehicle_type = 'PP' THEN
        prev_yr_pc_ni_amt := prev_yr_pc_ni_amt + l_ni_amt;
     END IF;
   END IF;
   l_old_element_entry_id:=l_get_info.element_entry_id;
    --END IF;
  END LOOP;
 CLOSE c_get_info;
  l_count:=l_count+1;
  l_effective_date := TRUNC(pqp_car_mileage_functions.
                        pqp_get_date_paid(l_get_info.payroll_action_id));

  categorize_balances (p_bal_info =>  l_bal_info);
  --Insert into the pay_patch_status
  IF l_status_count=0 THEN
   INSERT INTO pay_patch_status
                            (ID
                            ,PATCH_NUMBER
                            ,PATCH_NAME
                            ,STATUS
                            ,PHASE
                            )
                     VALUES (pay_patch_status_s.NEXTVAL
                            ,p_business_group_id
                            ,'CARMILEAGE_BALANCE_ADJ'
                            ,upgrade_status
                            ,'CARMILEAGE_BALANCE_ADJ'
                            );
  ELSE
   update pay_patch_status
   set STATUS = upgrade_status
   where patch_name = 'CARMILEAGE_BALANCE_ADJ'
   and phase = 'CARMILEAGE_BALANCE_ADJ'
   and PATCH_NUMBER = p_business_group_id;
  END IF;
 END IF;
END initialize_balances;
--------------------------------------------------- End ---------------------------------------------------
END;


/
