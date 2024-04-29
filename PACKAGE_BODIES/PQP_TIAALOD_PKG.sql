--------------------------------------------------------
--  DDL for Package Body PQP_TIAALOD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_TIAALOD_PKG" As
/* $Header: pqtiaald.pkb 120.0.12000000.1 2007/01/16 04:34:33 appldev noship $ */
   ------------------------------------- Global Varaibles ---------------------------
   l_start_date               pay_payroll_actions.start_date%TYPE;
   l_end_date                 pay_payroll_actions.effective_date%TYPE;
   l_business_group_id        pay_payroll_actions.business_group_id%TYPE;
   l_payroll_action_id        pay_payroll_actions.payroll_action_id%TYPE;
   l_effective_date           pay_payroll_actions.effective_date%TYPE;
   l_action_type              pay_payroll_actions.action_type%TYPE;
   l_assignment_action_id     pay_assignment_actions.assignment_action_id%TYPE;
   l_assignment_id            pay_assignment_actions.assignment_id%TYPE;
   l_tax_unit_id              hr_organization_units.organization_id%TYPE;
   l_gre_name                 hr_organization_units.name%TYPE;
   l_organization_id          hr_organization_units.organization_id%TYPE;
   l_org_name                 hr_organization_units.name%TYPE;
   l_location_id              hr_locations.location_id%TYPE;
   l_location_code            hr_locations.location_code%TYPE;
   l_ppp_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE;
   l_bal_value                NUMBER(11,2);
   l_leg_param                VARCHAR2(240);
   l_leg_start_date           DATE;
   l_leg_end_date             DATE;
   t_payroll_id               NUMBER(15);
   t_consolidation_set_id     NUMBER(15);
   t_gre_id                   NUMBER(15);
   t_payroll_action_id        pay_payroll_actions.payroll_action_id%TYPE;
   l_defined_balance_id       NUMBER;
   l_row_count                NUMBER :=0;
   l_national_id              per_people_v.national_identifier%TYPE;
   l_last_name                per_all_people_f.last_name%TYPE;
   l_first_name		      per_all_people_f.first_name%TYPE;
   l_middle_name	      per_all_people_f.middle_names%TYPE;
   l_dob                      per_all_people_f.date_of_birth%TYPE;
   l_asg_ppg_code             per_assignment_extra_info.aei_information1%TYPE;
   l_pay_mode                 pay_payrolls_f.prl_information4%TYPE;
   l_ppg_billing              pay_payrolls_f.prl_information7%TYPE;
   l_payroll_id               per_assignments_f.payroll_id%TYPE;
   l_org_ppg                  hr_organization_information.org_information1%TYPE;
   l_err_msg                  VARCHAR2(800);
   l_err_num                  VARCHAR2(800);
   l_chunk_no                 number;
   l_ld_payroll_id            pay_payroll_actions.payroll_id%TYPE;
   l_prev_payroll_id          pay_payroll_actions.payroll_id%TYPE;

   TYPE r_pay_mode IS RECORD (payroll_id        per_assignments_f.payroll_id%TYPE,
                              payment_mode      pay_payrolls_f.prl_information4%TYPE,
                              ppg_billing_code  pay_payrolls_f.prl_information7%TYPE,
                              effective_date    date);

   TYPE t_pay_mode IS TABLE OF r_pay_mode INDEX BY BINARY_INTEGER;

   pay_mode_t     t_pay_mode;

   TYPE r_org_ppg IS RECORD (org_ppg_code hr_organization_information.org_information1%TYPE,
                             tax_unit_id  pay_assignment_actions.tax_unit_id%TYPE);

   TYPE t_org_ppg IS TABLE OF r_org_ppg INDEX BY BINARY_INTEGER;
   org_ppg_t      t_org_ppg;

   TYPE r_ins_val IS RECORD
      (last_name            per_all_people_f.last_name%TYPE,
       first_name           per_all_people_f.first_name%TYPE,
       middle_name          per_all_people_f.middle_names%TYPE,
       dob                  per_all_people_f.date_of_birth%TYPE,
       national_id          per_all_people_f.national_identifier%TYPE,
       asg_ppg_code         per_assignment_extra_info.aei_information1%TYPE,
       org_ppg              hr_organization_information.org_information1%TYPE,
       pay_mode             pay_payrolls_f.prl_information4%TYPE,
       gre_name             hr_organization_units.name%TYPE,
       org_name             hr_organization_units.name%TYPE,
       effective_date       DATE,
       ppg_billing          pay_payrolls_f.prl_information7%TYPE,

       balance_name1        pay_balance_types.balance_name%TYPE,
       balance_value1       NUMBER,
       balance_name2        pay_balance_types.balance_name%TYPE,
       balance_value2       NUMBER,
       balance_name3        pay_balance_types.balance_name%TYPE,
       balance_value3       NUMBER,
       balance_name4        pay_balance_types.balance_name%TYPE,
       balance_value4       NUMBER,
       balance_name5        pay_balance_types.balance_name%TYPE,
       balance_value5       NUMBER,
       balance_name6        pay_balance_types.balance_name%TYPE,
       balance_value6       NUMBER,
       input_date           per_assignments_f.effective_end_date%TYPE,
       input_start_date     per_assignments_f.effective_end_date%TYPE,
       assignment_id        per_assignments_f.assignment_id%TYPE,
       assignment_action_id pay_assignment_actions.assignment_action_id%TYPE,
       err_num              VARCHAR2(800),
       err_msg              VARCHAR2(800),
       payroll_id           NUMBER
      );
   TYPE t_ins_val IS TABLE OF r_ins_val
                     INDEX BY BINARY_INTEGER;
   ins_val_t       t_ins_val;

   CURSOR c1 IS
     SELECT db.defined_balance_id, pbt.balance_name
       FROM pay_balance_types pbt,
            pay_defined_balances db,
            pay_balance_dimensions bd
      WHERE pbt.balance_name IN  ('RA GRA PLAN BY INST',
                                  'RA GRA PLAN REDUCT',
                                  'RA PLAN DEDUCT',
                                  'RA ADDL DEDUCT',
                                  'RA ADDL REDUCT',
                                  'SRA GSRA REDUCT')
        AND bd.dimension_name       =  'Assignment Default Run'
        AND pbt.balance_type_id     =  db.balance_type_id
        AND bd.balance_dimension_id =  db.balance_dimension_id
     ORDER BY pbt.balance_name;

   TYPE t_def_bal IS TABLE OF c1%ROWTYPE
                     INDEX BY BINARY_INTEGER;
   g_balance_rec     t_def_bal;

-- ------------------------------------------------------------------------
-- |-----------------------------< Chk_Neg_Amt>----------------------------|
-- ------------------------------------------------------------------------
-- This procedure was added as assignment_actions are spilt across
-- various chunks when the values CHUNK_SIZE and the THREADS in
-- pay_action_parameters are more than 1 and there may be more than one
-- record in the pay_us_rpt_totals for an assignment and we need to
-- consider the sum of all the records for a given pay_mode and assignment_id
-- so see if there any -ve balances being reported, which would be reported
-- in the exception report. This procedure would be called in the report
-- PAYUSTIM.rdf after-param report trigger.
--
PROCEDURE Chk_Neg_Amt( p_payroll_action_id IN number) IS

   CURSOR csr_rpt IS
    SELECT DISTINCT
            attribute5
           ,attribute12
           ,value9
      FROM pay_us_rpt_totals
     WHERE tax_unit_id = p_payroll_action_id
       AND attribute14 = '999'
       AND attribute15 = 'NEGATIVE BALANCE'
       AND attribute1 <> 'TIAA-CREF';

   CURSOR csr_asg  ( c_payroll_action_id IN NUMBER
                    ,c_assignment_id     IN VARCHAR2
                    ,c_payroll_id        IN NUMBER) IS
     SELECT attribute5
           ,SUM(value2) value2
           ,SUM(value3) value3
           ,SUM(value4) value4
           ,SUM(value5) value5
           ,SUM(value6) value6
           ,SUM(value7) value7
      FROM  pay_us_rpt_totals
     WHERE  tax_unit_id          =  c_payroll_action_id
       AND  attribute1          <> 'TIAA-CREF'
       AND  attribute5           =  c_assignment_id
       AND  value9               =  c_payroll_id
      -- AND  NVL(attribute12,'X') =  NVL(c_payment_mode,'X')
     GROUP BY  attribute5
     HAVING SUM(value2) < 0 OR
            SUM(value3) < 0 OR
            SUM(value4) < 0 OR
            SUM(value5) < 0 OR
            SUM(value6) < 0 OR
            SUM(value7) < 0;

   l_proc_name   VARCHAR2(150) := g_proc_name ||'Chk_Neg_Amt';
   csr_asg_rec   csr_asg%ROWTYPE;

BEGIN
  hr_utility.set_location('Entering : '||l_proc_name, 10);
  FOR rpt_rec IN csr_rpt
  LOOP
    OPEN  csr_asg (c_payroll_action_id => p_payroll_action_id
                  ,c_assignment_id     => rpt_rec.attribute5
                  ,c_payroll_id        => rpt_rec.value9);
    FETCH csr_asg INTO csr_asg_rec;
    IF csr_asg%NOTFOUND THEN
       UPDATE pay_us_rpt_totals
          SET  attribute14 = NULL
              ,attribute15 = NULL
       WHERE tax_unit_id  = p_payroll_action_id
         AND attribute5   = rpt_rec.attribute5
         AND attribute15  = 'NEGATIVE BALANCE'
         AND value9       = rpt_rec.value9;
    END IF;
    CLOSE csr_asg;
    COMMIT;
  END LOOP;
  hr_utility.set_location('Leaving : '||l_proc_name, 90);
EXCEPTION
  WHEN others THEN
   hr_utility.set_location('..Error in Chk_Neg_Amt :' ||SQLERRM,150);
   hr_utility.set_location('Leaving : '||l_proc_name, 150);
   RAISE;
END Chk_Neg_Amt;

-- ---------------------------------------------------------------------
-- |-----------------------< insert_rpt_data >--------------------------|
-- ---------------------------------------------------------------------
-- Insert_Rpt_Data procedure inserts the records from the PL/SQL table
-- into pay_us_rpt_totals table only if there exists at least one balance
-- value which is <> 0, i.e. if all the six balances for the TIAA-CREF
-- are zero for the assignment then that record from the PL/SQL table is
-- ignored. The PL/SQL record for the assignment is deleted from the PL/SQL
-- table once the insert is done(or not).
-- ---------------------------------------------------------------------
PROCEDURE insert_rpt_data  (p_assignment_id        IN NUMBER
                           ,p_assignment_action_id IN NUMBER
                           ,p_dimension_name       IN VARCHAR2
                           ,p_effective_date       IN DATE
                           ,p_ppa_finder           IN VARCHAR2) IS
  l_insert_valid BOOLEAN := FALSE;
  l_proc_name    VARCHAR2(150) := g_proc_name ||'insert_rpt_data';
  i              per_assignments_f.assignment_id%TYPE;

BEGIN
   hr_utility.set_location('Entering : '||l_proc_name, 10);
   -- Check if for the assignment id if there are any non-zero balances
   i := p_assignment_id;
   IF ins_val_t.EXISTS(i) THEN
     IF ins_val_t(i).assignment_id = p_assignment_id AND
       (ins_val_t(i).balance_value1 <> 0 OR
        ins_val_t(i).balance_value2 <> 0 OR
        ins_val_t(i).balance_value3 <> 0 OR
        ins_val_t(i).balance_value4 <> 0 OR
        ins_val_t(i).balance_value5 <> 0 OR
        ins_val_t(i).balance_value6 <> 0 ) THEN
        l_insert_valid := TRUE;
        IF (ins_val_t(i).balance_value1 < 0 OR
            ins_val_t(i).balance_value2 < 0 OR
            ins_val_t(i).balance_value3 < 0 OR
            ins_val_t(i).balance_value4 < 0 OR
            ins_val_t(i).balance_value5 < 0 OR
            ins_val_t(i).balance_value6 < 0 ) THEN

            ins_val_t(i).err_num := '999';
            ins_val_t(i).err_msg := 'NEGATIVE BALANCE';
        END IF;
     END IF;
  END IF;

   hr_utility.set_location('..After the check if atleast one balance is <> 0', 15);
   IF l_insert_valid THEN
      hr_utility.set_location('..Valid for Assignment : '||p_assignment_id, 20);
      INSERT INTO pay_us_rpt_totals
           (tax_unit_id,
            gre_name,
            organization_name,
            location_name,
            attribute1,
            value1,
            attribute2,
            attribute3,
            attribute5,
            attribute6,
            attribute7,
            attribute8,
            attribute9,
            attribute10,
            attribute11,
            attribute12,
            attribute13,
            attribute14,
            attribute15,
            attribute16,
            attribute17,
            attribute18,
       	    attribute19,
            attribute21,
            attribute22,
            attribute23,
            attribute24,
            attribute25,
            attribute26,
            value2,
            value3,
            value4,
            value5,
            value6,
            value7,
            organization_id, value8,value9 )
          VALUES
           (l_payroll_action_id,                     --tax_unit_id
            ins_val_t(i).gre_name,                   --gre_name
            ins_val_t(i).org_name,                   --org_name
            l_location_code,                         --location_code
            'BALANCE',                               --'BALANCE'
            l_payroll_action_id,                     --value1
            '',                                      --attribute2
            p_dimension_name,                        --attribute3
            p_assignment_id,                         --attribute5
            ins_val_t(i).last_name,                  --attribute6
            ins_val_t(i).first_name,                 --attribute7
            TO_CHAR(ins_val_t(i).dob,'DD-MON-YYYY'), --attribute8
            ins_val_t(i).national_id,                --attribute9
            ins_val_t(i).asg_ppg_code,               --attribute10
            ins_val_t(i).org_ppg,                    --attribute11
            ins_val_t(i).pay_mode,                   --attribute12
            ins_val_t(i).middle_name,                --attribute13
            ins_val_t(i).err_num,                    --attribute14
            ins_val_t(i).err_msg,                    --attribute15
            TO_CHAR(ins_val_t(i).input_start_date,'DD-MON-YYYY'), --attribute16
            TO_CHAR(ins_val_t(i).input_date,'DD-MON-YYYY'),       --attribute17
            TO_CHAR(l_effective_date,'DD-MON-YYYY'),              --attribute18
      	    ins_val_t(i).ppg_billing,                             --attribute19
            ins_val_t(i).balance_name1,                           --attribute21
            ins_val_t(i).balance_name2,                           --attribute22
            ins_val_t(i).balance_name3,                           --attribute23
            ins_val_t(i).balance_name4,                           --attribute24
            ins_val_t(i).balance_name5,                           --attribute25
            ins_val_t(i).balance_name6,                           --attribute26
            ins_val_t(i).balance_value1,                          --value2
            ins_val_t(i).balance_value2,                          --value3
            ins_val_t(i).balance_value3,                          --value4
            ins_val_t(i).balance_value4,                          --value5
            ins_val_t(i).balance_value5,                          --value6
            ins_val_t(i).balance_value6,                          --value7
            ins_val_t(i).assignment_action_id,                    --organization_id
            l_chunk_no,                                           --value8
            ins_val_t(i).payroll_id );                            --value9
            hr_utility.set_location('..Inserted for assignment :'||p_assignment_id, 25);
    END IF; -- IF l_insert_valid Then
    -- Delete all the records from the PL/SQL table for the assignment id
    hr_utility.set_location('..After Inserting into pay_us_rpt_totals ', 70);

    IF ins_val_t.EXISTS(i) THEN
       ins_val_t.DELETE(i);
       hr_utility.set_location('..Deleting for Assg ID : '||p_assignment_id,75);
    END IF;
    l_err_msg := NULL;
    l_err_num := NULL;

    hr_utility.set_location('..After Deleting rows from PL/SQL table', 80);
    hr_utility.set_location('Leaving : '||l_proc_name, 90);

EXCEPTION
  WHEN OTHERS THEN
   hr_utility.set_location('..Error in Insert_Rpt_Data :' ||SQLERRM,150);
   hr_utility.set_location('Leaving : '||l_proc_name, 150);
   RAISE;

END insert_rpt_data;

-- ---------------------------------------------------------------------
-- |------------------------< load_balances >---------------------------|
-- ---------------------------------------------------------------------
PROCEDURE load_balances(p_assignment_id        IN NUMBER,
                        p_assignment_action_id IN NUMBER,
                        p_dimension_name       IN VARCHAR2,
                        p_effective_date       IN DATE,
                        p_ppa_finder           IN VARCHAR2) IS

  l_comp_balance        NUMBER :=0;
  l_balance             NUMBER;
  l_balance_start       NUMBER;
  l_balance_end         NUMBER;
  l_defined_balance_id  NUMBER;
  l_def_balance_id      pay_defined_balances.defined_balance_id%TYPE;
  l_balance_name        pay_balance_types.balance_name%TYPE := ' ';
  l_tax_id              NUMBER;
  l_count_bal           NUMBER :=0;
  l_input_date          per_assignments_f.effective_end_date%TYPE;
  l_input_start_date    per_assignments_f.effective_start_date%TYPE;
  v_start_date          per_assignments_f.effective_start_date%TYPE;
  v_end_date            per_assignments_f.effective_end_date%TYPE;
  l_update_flag         BOOLEAN;
  l_insert_valid        BOOLEAN;
  l_proc_name           VARCHAR2(150) := g_proc_name ||'load_balances';
  i                     per_all_assignments_f.assignment_id%TYPE;

BEGIN
   hr_utility.set_location('Entering : '||l_proc_name, 10);
   IF l_org_ppg      IS NULL AND
      l_asg_ppg_code IS NULL AND
      l_ppg_billing  IS NULL THEN
      l_err_num := '999';
      l_err_msg := 'PPG CODE REQUIRED';
   END IF;

   -- set the date earned and tax unit id context for the balance pkg
   hr_utility.set_location('..Set the tax and date earned contexts ', 15);
   pay_balance_pkg.set_context('tax_unit_id',l_tax_unit_id);

   hr_utility.set_location('..No. of def. balances : '||g_balance_rec.count, 20);

   FOR i_bals IN 1..g_balance_rec.count
   LOOP
     l_defined_balance_id := g_balance_rec(i_bals).defined_balance_id;
     l_balance_name       := g_balance_rec(i_bals).balance_name;

     -- Get the value for each of the def. balance id for the given assig. action
     l_balance_end := pay_balance_pkg.get_value
                       (p_defined_balance_id   => l_defined_balance_id,
                        p_assignment_action_id => p_assignment_action_id );
     hr_utility.set_location('..Balance name  : '||l_balance_name, 25);

     l_balance := NVL(l_balance_end,0);
     l_update_flag := FALSE;
     i := p_assignment_id;

     IF ins_val_t.EXISTS(i) THEN
        IF    l_balance_name = 'RA GRA PLAN BY INST' AND
              l_balance_name = ins_val_t(i).balance_name1 THEN
              ins_val_t(i).balance_value1   := ins_val_t(i).balance_value1 + l_balance;
              l_update_flag := TRUE;
        ELSIF l_balance_name = 'RA GRA PLAN REDUCT' AND
              l_balance_name = ins_val_t(i).balance_name2 THEN
              ins_val_t(i).balance_value2   := ins_val_t(i).balance_value2 + l_balance;
              l_update_flag := TRUE;
        ELSIF l_balance_name = 'RA PLAN DEDUCT' AND
              l_balance_name = ins_val_t(i).balance_name3 THEN
              ins_val_t(i).balance_value3   := ins_val_t(i).balance_value3 + l_balance;
              l_update_flag := TRUE;
        ELSIF l_balance_name = 'RA ADDL REDUCT' AND
              l_balance_name = ins_val_t(i).balance_name4 THEN
              ins_val_t(i).balance_value4   := ins_val_t(i).balance_value4 + l_balance;
              l_update_flag := TRUE;
        ELSIF l_balance_name = 'RA ADDL DEDUCT' AND
              l_balance_name = ins_val_t(i).balance_name5 THEN
              ins_val_t(i).balance_value5   := ins_val_t(i).balance_value5 + l_balance;
              l_update_flag := TRUE;
        ELSIF l_balance_name = 'SRA GSRA REDUCT' AND
              l_balance_name = ins_val_t(i).balance_name6 THEN
              ins_val_t(i).balance_value6   := ins_val_t(i).balance_value6 + l_balance;
              l_update_flag := TRUE;
        END IF;
        IF NOT l_update_flag THEN
           hr_utility.set_location('..New balance for the same assignment id :'||l_balance_name, 25);
           IF    l_balance_name = 'RA GRA PLAN BY INST' THEN
                 ins_val_t(i).balance_name1    := l_balance_name;
                 ins_val_t(i).balance_value1   := l_balance;
           ELSIF l_balance_name = 'RA GRA PLAN REDUCT' THEN
                 ins_val_t(i).balance_name2    := l_balance_name;
                 ins_val_t(i).balance_value2   := l_balance;
           ELSIF l_balance_name = 'RA PLAN DEDUCT' THEN
                 ins_val_t(i).balance_name3    := l_balance_name;
                 ins_val_t(i).balance_value3   := l_balance;
           ELSIF l_balance_name = 'RA ADDL REDUCT' THEN
                 ins_val_t(i).balance_name4    := l_balance_name;
                 ins_val_t(i).balance_value4   := l_balance;
           ELSIF l_balance_name = 'RA ADDL DEDUCT' THEN
                 ins_val_t(i).balance_name5    := l_balance_name;
                 ins_val_t(i).balance_value5   := l_balance;
           ELSIF l_balance_name = 'SRA GSRA REDUCT' THEN
                 ins_val_t(i).balance_name6    := l_balance_name;
                 ins_val_t(i).balance_value6   := l_balance;
           END IF;
           l_update_flag := TRUE;
        END IF;
        IF l_update_flag THEN
           ins_val_t(i).asg_ppg_code     := l_asg_ppg_code;
           ins_val_t(i).org_ppg          := l_org_ppg;
           ins_val_t(i).pay_mode         := l_pay_mode;
           ins_val_t(i).gre_name         := l_gre_name;
           ins_val_t(i).org_name         := l_org_name;
           ins_val_t(i).effective_date   := l_effective_date;
           ins_val_t(i).ppg_billing      := l_ppg_billing;
           ins_val_t(i).input_date       := l_input_date;
           ins_val_t(i).input_start_date := l_input_start_date;
           ins_val_t(i).payroll_id       := l_ld_payroll_id;
        END IF;
     END IF;
     hr_utility.set_location('..After Checking the PL/SQL table ', 40);

     IF NOT l_update_flag  THEN
        i := p_assignment_id;
        hr_utility.set_location('..Next new index used : '||i, 40);
        ins_val_t(i).assignment_id        := p_assignment_id;
        ins_val_t(i).assignment_action_id := p_assignment_action_id;

        IF    l_balance_name = 'RA GRA PLAN BY INST' THEN
              ins_val_t(i).balance_name1    := l_balance_name;
              ins_val_t(i).balance_value1   := l_balance;
        ELSIF l_balance_name = 'RA GRA PLAN REDUCT' THEN
              ins_val_t(i).balance_name2    := l_balance_name;
              ins_val_t(i).balance_value2   := l_balance;
        ELSIF l_balance_name = 'RA PLAN DEDUCT' THEN
              ins_val_t(i).balance_name3    := l_balance_name;
              ins_val_t(i).balance_value3   := l_balance;
        ELSIF l_balance_name = 'RA ADDL REDUCT' THEN
              ins_val_t(i).balance_name4    := l_balance_name;
              ins_val_t(i).balance_value4   := l_balance;
        ELSIF l_balance_name = 'RA ADDL DEDUCT' THEN
              ins_val_t(i).balance_name5    := l_balance_name;
              ins_val_t(i).balance_value5   := l_balance;
        ELSIF l_balance_name = 'SRA GSRA REDUCT' THEN
              ins_val_t(i).balance_name6    := l_balance_name;
              ins_val_t(i).balance_value6   := l_balance;
        END IF;

        ins_val_t(i).last_name        := l_last_name;
        ins_val_t(i).first_name       := l_first_name;
        ins_val_t(i).middle_name      := l_middle_name;
        ins_val_t(i).dob              := l_dob;
        ins_val_t(i).national_id      := l_national_id;
        ins_val_t(i).asg_ppg_code     := l_asg_ppg_code;
        ins_val_t(i).org_ppg          := l_org_ppg;
        ins_val_t(i).pay_mode         := l_pay_mode;
        ins_val_t(i).gre_name         := l_gre_name;
        ins_val_t(i).org_name         := l_org_name;
        ins_val_t(i).effective_date   := l_effective_date;
        ins_val_t(i).ppg_billing      := l_ppg_billing;
        ins_val_t(i).input_date       := l_input_date;
        ins_val_t(i).input_start_date := l_input_start_date;
     END IF;
     IF (l_err_num IS NOT NULL OR
         l_err_msg IS NOT NULL ) AND
         ins_val_t.EXISTS(i)  THEN
         IF ins_val_t(i).err_num IS NULL THEN
            ins_val_t(i).err_msg  := l_err_msg;
            ins_val_t(i).err_num  := l_err_num;
         END IF;
     END IF;
    END LOOP; --For i_bals in 1..g_balance_rec.count

    hr_utility.set_location('..After looping thru g_balance_rec PL/SQL table ', 85);
    hr_utility.set_location('Leaving : '||l_proc_name, 90);
EXCEPTION
  WHEN OTHERS THEN
   hr_utility.set_location('..Error:' ||SQLERRM,150);
   hr_utility.set_location('Leaving : '||l_proc_name, 150);
   RAISE;
END load_balances;

-- ---------------------------------------------------------------------
-- |-------------------------< ppg_billing >----------------------------|
-- ---------------------------------------------------------------------
PROCEDURE ppg_billing(p_payroll_id IN NUMBER) IS

 CURSOR c_ppg_billing IS
  SELECT prl.prl_information7
    FROM pay_payrolls_f prl
   WHERE prl.payroll_id = p_payroll_id
     AND prl.prl_information_category = 'US'
     AND l_effective_date BETWEEN prl.effective_start_date
                              AND prl.effective_end_date;
  l_count     NUMBER                           ;
  lpayroll_id per_assignments_f.payroll_id%TYPE;
BEGIN
  l_ppg_billing:='';
  FOR i IN 1..pay_mode_t.count
  LOOP
      IF pay_mode_t(i).payroll_id = p_payroll_id AND
         pay_mode_t(i).effective_date = TRUNC(l_effective_date) THEN
         l_count       := pay_mode_t.count;
         l_ppg_billing := pay_mode_t(i).ppg_billing_code;
         lpayroll_id   := p_payroll_id;
      END IF;
  END LOOP;
  IF  l_ppg_billing IS NULL THEN
      OPEN c_ppg_billing;
        LOOP
             FETCH c_ppg_billing INTO l_ppg_billing;
             EXIT WHEN c_ppg_billing%NOTFOUND;
               pay_mode_t(l_count).ppg_billing_code:= l_ppg_billing;
        END LOOP;
       CLOSE c_ppg_billing;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
  hr_utility.trace('Error occurred load_er_liab ...' ||SQLERRM);
END ppg_billing;

-- ---------------------------------------------------------------------
-- |---------------------------< pay_mode >-----------------------------|
-- ---------------------------------------------------------------------
PROCEDURE pay_mode(p_payroll_id IN NUMBER)  IS

  CURSOR c_pay_mode IS
   SELECT  prl.prl_information4
          ,prl.prl_information7
     FROM  pay_payrolls_f prl
    WHERE  prl.payroll_id               = p_payroll_id
      AND  prl.prl_information_category = 'US'
      AND  l_effective_date BETWEEN prl.effective_start_date
                                AND  prl.effective_end_date;
  l_count     NUMBER;
  lpayroll_id  per_assignments_f.payroll_id%TYPE;
BEGIN
  l_pay_mode:='';
  lpayroll_id:='';
  l_ppg_billing:='';

  FOR i IN 1..pay_mode_t.count
   LOOP
     IF pay_mode_t(i).payroll_id     = p_payroll_id AND
        pay_mode_t(i).effective_date = TRUNC(l_effective_date) THEN
        l_pay_mode    := pay_mode_t(i).payment_mode;
        l_ppg_billing := pay_mode_t(i).ppg_billing_code;
        lpayroll_id   := p_payroll_id;
     END IF;
   END LOOP;
  IF  lpayroll_id IS NULL THEN
      OPEN c_pay_mode;
        LOOP
             FETCH c_pay_mode INTO l_pay_mode,l_ppg_billing;
             EXIT WHEN c_pay_mode%NOTFOUND;
               l_count:= pay_mode_t.count + 1;
               pay_mode_t(l_count).payroll_id      := p_payroll_id;
               pay_mode_t(l_count).payment_mode    := l_pay_mode;
               pay_mode_t(l_count).ppg_billing_code:= l_ppg_billing;
               pay_mode_t(l_count).effective_date  := TRUNC(l_effective_date);
       END LOOP;
       CLOSE c_pay_mode;
  END IF;

  IF l_pay_mode IS NULL THEN
     l_err_num:='999';
     l_err_msg:='MODE IS NULL';
  END IF;

EXCEPTION
  WHEN OTHERS THEN
   hr_utility.trace('Error occurred load_er_liab ...' ||SQLERRM);
END pay_mode;

-- ---------------------------------------------------------------------
-- |------------------------< load_asg_ppg >----------------------------|
-- ---------------------------------------------------------------------
PROCEDURE load_asg_ppg(p_assignment IN NUMBER) IS
  CURSOR asg_ppg IS
  SELECT paei.aei_information1,
         pasg.payroll_id
    FROM per_assignment_extra_info paei ,
         per_assignments_f pasg
   WHERE pasg.assignment_id       = p_assignment
     AND pasg.assignment_id       = paei.assignment_id(+)
     AND paei.information_type(+) =   'PQP_US_TIAA_CREF_CODES'
     AND l_effective_date BETWEEN pasg.effective_start_date
                              AND pasg.effective_end_date;

BEGIN
   l_asg_ppg_code:='';
   OPEN asg_ppg;
   LOOP
     FETCH asg_ppg INTO l_asg_ppg_code,l_payroll_id;
     EXIT WHEN asg_ppg%NOTFOUND;
     pay_mode(l_payroll_id );
   END LOOP;
   CLOSE asg_ppg;
EXCEPTION
   WHEN OTHERS THEN
   hr_utility.trace('Error occurred load_asg_ppg ...' ||SQLERRM);
END load_asg_ppg;

-- ---------------------------------------------------------------------
-- |------------------------< load_details >----------------------------|
-- ---------------------------------------------------------------------
PROCEDURE load_details (p_assignment IN NUMBER) IS
  msg1 VARCHAR2(2000);
  l_term_date date;
  l_actual_date date;
  CURSOR per_det IS
    SELECT ppv.last_name,
           ppv.first_name,
           ppv.middle_names,
           ppv.date_of_birth,
           ppv.national_identifier
     FROM  per_all_people_f  ppv,
           per_assignments_f paf
     WHERE paf.assignment_id = p_assignment
       AND paf.person_id     = ppv.person_id
       AND l_actual_date   BETWEEN ppv.effective_start_date
                                AND ppv.effective_end_date
       AND l_actual_date   BETWEEN paf.effective_start_date
                                AND paf.effective_end_date;
  CURSOR asg_end_date IS
    SELECT MAX(effective_end_date)
     FROM per_assignments_f paf
    WHERE  paf.assignment_id = p_assignment
      AND paf.business_group_id =l_business_group_id;

BEGIN
    l_last_name  :='';
    l_first_name :='';
    l_middle_name:='';
    l_dob        :='';
    l_national_id:='';


    l_actual_date := l_leg_end_date;


    OPEN per_det;
      FETCH per_det INTO l_last_name,l_first_name,l_middle_name,l_dob,l_national_id;
    CLOSE per_det;


    IF l_national_id IS NULL THEN

     OPEN asg_end_date;
      FETCH asg_end_date INTO l_term_date;
     CLOSE asg_end_date;

     IF l_term_date < l_leg_end_date AND l_term_date IS NOT NULL  THEN
      l_actual_date := l_term_date;

     ELSE
      l_actual_date := l_leg_end_date;
     END IF;
     OPEN per_det;
      FETCH per_det INTO l_last_name,l_first_name,l_middle_name,l_dob,l_national_id;
     CLOSE per_det;
    END IF;
    IF  l_national_id IS NULL THEN
          l_err_num := '999';
          l_err_msg := 'SSN MISSING';
      END IF;

EXCEPTION
  WHEN OTHERS THEN
  msg1:=SQLERRM;
  hr_utility.trace('Error occurred load_details ...' ||SQLERRM);
END load_details;
-- ---------------------------------------------------------------------
-- |------------------------< load_org_ppg >----------------------------|
-- ---------------------------------------------------------------------
PROCEDURE load_org_ppg(p_tax_unit_id IN NUMBER) IS

   CURSOR  c_org_ppg IS
    SELECT org_information1
      FROM hr_organization_information
     WHERE org_information_context   = 'PQP_US_TIAA_CREF_CODES'
       AND organization_id           = p_tax_unit_id;
  ltaxunit_id              hr_organization_units.organization_id%TYPE := NULL;
BEGIN
   l_org_ppg:='';
   FOR i IN 1..org_ppg_t.count
   LOOP
      IF org_ppg_t(i).tax_unit_id = p_tax_unit_id THEN
          l_org_ppg   := org_ppg_t(i).org_ppg_code;
          ltaxunit_id := p_tax_unit_id;
      END IF;
   END LOOP;
   IF  ltaxunit_id IS NULL THEN
       OPEN c_org_ppg;
        LOOP
             FETCH c_org_ppg INTO l_org_ppg;
             EXIT WHEN  c_org_ppg%NOTFOUND;
               org_ppg_t(1).tax_unit_id  := p_tax_unit_id;
               org_ppg_t(1).org_ppg_code := l_org_ppg;
        END LOOP;
       CLOSE c_org_ppg;
   END IF;
EXCEPTION
 WHEN OTHERS THEN
  hr_utility.trace('Error occurred load_org_ppg ...' ||SQLERRM);
END load_org_ppg;

-- ---------------------------------------------------------------------
-- |-------------------------< load_data >------------------------------|
-- ---------------------------------------------------------------------
PROCEDURE load_data
  (pactid            IN     VARCHAR2,
   chnkno            IN     NUMBER,
   ppa_finder        IN     VARCHAR2,
   p_dimension_name  IN     VARCHAR2) IS

   CURSOR sel_aaid (l_pactid NUMBER,
                    l_chnkno NUMBER) IS
     SELECT DISTINCT
          paa.assignment_id            assignment_id,
          ppa_gen.start_date           start_date,
          ppa_gen.effective_date       end_date,
          ppa_gen.business_group_id    business_group_id,
          ppa_gen.payroll_action_id    payroll_action_id,
          ppa.effective_date           effective_date,
          ppa.action_type              action_type,
          paa.tax_unit_id              tax_unit_id,
          hou.name                     gre_name,
          paf.organization_id          organization_id,
          hox.name                     organization_name,
          paf.location_id              location_id,
          hrl.location_code            location_code,
          paa.assignment_action_id     assignment_action_id,
          ppa.payroll_id               pay_payroll_id
  FROM    hr_locations_all             hrl,
          hr_organization_units        hox,
          hr_organization_units        hou,
          per_assignments_f            paf,
          pay_payroll_actions          ppa,
          pay_assignment_actions       paa,
          pay_action_interlocks        pai,
          pay_assignment_actions       paa_gen,
          pay_payroll_actions          ppa_gen
    WHERE
          ppa_gen.payroll_action_id    = l_pactid
      AND paa_gen.payroll_action_id    = ppa_gen.payroll_action_id
      AND paa_gen.chunk_number         = l_chnkno
      AND pai.locking_action_id        = paa_gen.assignment_action_id
      AND paa.assignment_action_id     = pai.locked_action_id
      AND paa.action_status            = 'C'
      AND paa.tax_unit_id              = NVL(t_gre_id,
                                             paa.tax_unit_id)
      AND ppa.consolidation_set_id     = NVL(t_consolidation_set_id,
                                             ppa.consolidation_set_id)
      AND ppa.payroll_id               = NVL(t_payroll_id,
                                             ppa.payroll_id)
      AND ppa.payroll_action_id        = paa.payroll_action_id
      AND ppa.action_type              IN ('R','V','Q','B')
      AND ppa.action_status            = 'C'
      AND ppa.effective_date BETWEEN ppa_gen.start_date
                                 AND ppa_gen.effective_date
      AND ppa.effective_date BETWEEN paf.effective_start_date
                                 AND paf.effective_end_date
      AND paf.assignment_id            = paa.assignment_id
      AND paf.business_group_id        = ppa_gen.business_group_id
      AND hrl.location_id              = paf.location_id
      AND hox.organization_id          = paf.organization_id
      AND hou.organization_id          = paa.tax_unit_id
      ORDER BY paa.assignment_id,ppa.payroll_id, paa.assignment_action_id;

  l_prev_assignment_id          per_all_assignments_f.assignment_id%TYPE := NULL;
  l_prev_assignment_action_id   pay_assignment_actions.assignment_action_id%TYPE;
  l_prev_end_date               date;
  l_count                       NUMBER(5);
  l_proc_name                   VARCHAR2(150) := g_proc_name ||'load_data';

BEGIN
   hr_utility.set_location('Entering : '||l_proc_name, 10);
   l_chunk_no := chnkno;
   BEGIN
        SELECT ppa.legislative_parameters,
               ppa.business_group_id,
               ppa.start_date,
               ppa.effective_date,
               pay_paygtn_pkg.get_parameter('TRANSFER_CONC_SET',ppa.legislative_parameters),
               pay_paygtn_pkg.get_parameter('TRANSFER_PAYROLL',ppa.legislative_parameters),
               pay_paygtn_pkg.get_parameter('TRANSFER_GRE',ppa.legislative_parameters),
               ppa.payroll_action_id
          INTO l_leg_param,
               l_business_group_id,
               l_leg_start_date,
               l_leg_end_date,
               t_consolidation_set_id,
               t_payroll_id,
               t_gre_id,
               t_payroll_action_id
          FROM pay_payroll_actions ppa
         WHERE ppa.payroll_action_id = pactid;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
     hr_utility.set_location('..Legislative Details not found...',30);
     RAISE;
   END;

   IF chnkno = 1 THEN
       INSERT INTO pay_us_rpt_totals
        ( tax_unit_id, attribute1, organization_id,
          attribute2,  attribute3, attribute4,
          attribute5
         )
       VALUES
        (pactid,      'TIAA-CREF', ppa_finder,
         l_leg_param, l_business_group_id, TO_CHAR(l_leg_start_date,'MM/DD/YYYY'),
         TO_CHAR(l_leg_end_date,'MM/DD/YYYY')
         );
       COMMIT;
   END IF;
   --
   -- Store all the six balances in a PL/SQL as they would be the same for
   -- all assignments.
   --
   hr_utility.set_location('..Store the balances in the PL/SQL table',35);
   l_count := 1;
   FOR bal_rec IN c1
   LOOP
      g_balance_rec(l_count).defined_balance_id := bal_rec.defined_balance_id;
      g_balance_rec(l_count).balance_name       := bal_rec.balance_name;
      l_count := l_count + 1;
   END LOOP;
   hr_utility.set_location('..Open and loop thru the SEL_AAID Cursor',40);
   OPEN sel_aaid (TO_NUMBER(pactid),chnkno);
    LOOP
      FETCH sel_aaid INTO  l_assignment_id,
                           l_start_date,
                           l_end_date,
                           l_business_group_id,
                           l_payroll_action_id,
                           l_effective_date,
                           l_action_type,
                           l_tax_unit_id,
                           l_gre_name,
                           l_organization_id,
                           l_org_name,
                           l_location_id,
                           l_location_code,
                           l_assignment_action_id,
                           l_ld_payroll_id;
      EXIT WHEN sel_aaid%NOTFOUND;

      hr_utility.set_location('..Chunk No          = '||TO_CHAR(chnkno),50);
      hr_utility.set_location('..PPA_FINDER        = '||ppa_finder,25);
      hr_utility.set_location('..Start Date        = '||TO_CHAR(l_start_date),50);
      hr_utility.set_location('..End Date          = '||TO_CHAR(l_end_date),50);
      hr_utility.set_location('..BG ID             = '||TO_CHAR(l_business_group_id),50);
      hr_utility.set_location('..Payroll Action ID = '||TO_CHAR(l_payroll_action_id),50);
      hr_utility.set_location('..Effective Date    = '||TO_CHAR(l_effective_date),50);
      hr_utility.set_location('..Action Type       = '||l_action_type,50);
      hr_utility.set_location('..Asg Act ID        = '||TO_CHAR(l_assignment_action_id),50);
      hr_utility.set_location('..Asg ID            = '||TO_CHAR(l_assignment_id),50);
      hr_utility.set_location('..Tax Unit ID       = '||TO_CHAR(l_tax_unit_id),50);
      hr_utility.set_location('..GRE Name          = '||l_gre_name,50);
      hr_utility.set_location('..ORG ID            = '||TO_CHAR(l_organization_id),50);
      hr_utility.set_location('..ORG Name          = '||l_org_name,50);
      hr_utility.set_location('..Loc ID            = '||TO_CHAR(l_location_id),50);
      hr_utility.set_location('..Loc Code          = '||l_location_code,50);

      -- If its diff. assign. Id then insert into pay_us_rpt_totals for that
      -- assignment id.
      IF l_prev_assignment_id IS NOT NULL         AND
         (l_assignment_id <>  l_prev_assignment_id OR
          l_ld_payroll_id <>  l_prev_payroll_id ) THEN
         hr_utility.set_location('..Calling INSERT_RPT_DATA within loop ', 55);
         insert_rpt_data (p_assignment_id        => l_prev_assignment_id
                         ,p_assignment_action_id => l_prev_assignment_action_id
                         ,p_dimension_name       => p_dimension_name
                         ,p_effective_date       => l_prev_end_date
                         ,p_ppa_finder           => ppa_finder);
      END IF;
      l_prev_assignment_id        := l_assignment_id;
      l_prev_assignment_action_id := l_assignment_action_id;
      l_prev_end_date             := l_end_date;
      l_prev_payroll_id           := l_ld_payroll_id;

      load_asg_ppg(l_assignment_id);
      load_details(l_assignment_id);
      load_org_ppg(l_tax_unit_id);

      load_balances(p_assignment_id        => l_assignment_id
                   ,p_assignment_action_id => l_assignment_action_id
                   ,p_dimension_name       => p_dimension_name
                   ,p_effective_date       => l_end_date
                   ,p_ppa_finder           => ppa_finder
                   );

      -- Issue a commit after processing 200 records
      l_row_count := l_row_count +1 ;
      IF l_row_count = 200 THEN
         l_row_count := 0;
         COMMIT;
      END IF;
    END LOOP;
    hr_utility.set_location('..Calling INSERT_RPT_DATA outside loop ', 60);
    insert_rpt_data (p_assignment_id        => l_prev_assignment_id
                    ,p_assignment_action_id => l_prev_assignment_action_id
                    ,p_dimension_name       => p_dimension_name
                    ,p_effective_date       => l_prev_end_date
                    ,p_ppa_finder           => ppa_finder);

    CLOSE sel_aaid;
    ins_val_t.DELETE;
    COMMIT;
    hr_utility.set_location('Leaving : '||l_proc_name, 90);
EXCEPTION
   WHEN others THEN
   hr_utility.set_location('..Error in LOAD_DATA :' ||SQLERRM,150);
   hr_utility.set_location('Leaving : '||l_proc_name, 150);
   RAISE;
END load_data;

END pqp_tiaalod_pkg;

/
