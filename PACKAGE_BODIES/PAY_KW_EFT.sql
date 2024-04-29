--------------------------------------------------------
--  DDL for Package Body PAY_KW_EFT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_KW_EFT" as
 /* $Header: pykweftp.pkb 120.0 2005/05/29 06:36:59 appldev noship $ */
 g_package                  varchar2(33) := 'PAY_KW_PAYFILE.';
 -- Global Variables
 hr_formula_error  EXCEPTION;
 g_formula_exists  BOOLEAN := TRUE;
 g_formula_cached  BOOLEAN := FALSE;
 g_formula_id      ff_formulas_f.formula_id%TYPE;
 g_formula_name    ff_formulas_f.formula_name%TYPE;
 --
 FUNCTION get_customer_formula_header    (
                             p_Date_Earned  IN DATE
                            ,p_payment_method_id IN number
                            ,p_business_group_id IN number
                            ,p_payroll_id IN number
                            ,p_payroll_action_id IN number
                            ,p_creation_date  IN VARCHAR2
                            ,p_process_date   IN VARCHAR2
                            ,p_count          IN VARCHAR2
                            ,p_sum            IN VARCHAR2
                            ,p_write_text1  OUT NOCOPY VARCHAR2
                            ,p_write_text2  OUT NOCOPY VARCHAR2
                            ,p_write_text3  OUT NOCOPY VARCHAR2
                            ,p_write_text4  OUT NOCOPY VARCHAR2
                            ,p_write_text5  OUT NOCOPY VARCHAR2
                            ,p_report_text1 OUT NOCOPY VARCHAR2
                            ,p_report_text2 OUT NOCOPY VARCHAR2
                            ,p_report_text3 OUT NOCOPY VARCHAR2
                            ,p_report_text4 OUT NOCOPY VARCHAR2
                            ,p_report_text5 OUT NOCOPY VARCHAR2
                            ,p_report_text6 OUT NOCOPY VARCHAR2
                            ,p_report_text7 OUT NOCOPY VARCHAR2
                            ,p_report_text8 OUT NOCOPY VARCHAR2
                            ,p_report_text9 OUT NOCOPY VARCHAR2
                            ,p_report_text10 OUT NOCOPY VARCHAR2
				    ,p_bank_code IN VARCHAR2
                  	    ,p_employer_code IN VARCHAR2) return varchar2 IS
 l_header varchar2(100);
 l_body varchar2(100);
 l_footer varchar2(100);
 l_bank_code varchar2(100);
 l_employer_code varchar2(100);
 l_inputs ff_exec.inputs_t;
 l_outputs ff_exec.outputs_t;
 cursor c_get_name(p_payment_method_id NUMBER) is
 select PMETH_INFORMATION1,PMETH_INFORMATION2,PMETH_INFORMATION3,PMETH_INFORMATION4,PMETH_INFORMATION5
 from PAY_ORG_PAYMENT_METHODS_F where ORG_PAYMENT_METHOD_ID = p_payment_method_id;
 begin
 --hr_utility.trace_on(null,'EFT');
 l_payment_method_id := p_payment_method_id;
 open c_get_name(p_payment_method_id);
 fetch c_get_name into l_id_header,l_id_body,l_id_footer,l_employer_code,l_bank_code;
 close c_get_name;
                   l_inputs(1).name  := 'DATE_EARNED';
                   l_inputs(1).value := fnd_date.date_to_canonical(p_date_earned);
                   l_inputs(2).name  := 'ORG_PAY_METHOD_ID';
                   l_inputs(2).value := p_payment_method_id;
                   l_inputs(3).name  := 'BUSINESS_GROUP_ID';
                   l_inputs(3).value := p_business_group_id;
                   l_inputs(4).name  := 'PAYROLL_ID';
                   l_inputs(4).value := p_payroll_id;
                   l_inputs(5).name  := 'PAYROLL_ACTION_ID';
                   l_inputs(5).value := p_payroll_action_id;
                   l_inputs(6).name  := 'CREATION_DATE';
                   l_inputs(6).value := p_creation_date;
                   l_inputs(7).name  := 'PAYMENT_DATE';
                   l_inputs(7).value := p_process_date;
                   l_inputs(8).name  := 'COUNT1';
                   l_inputs(8).value := p_count;
                   l_inputs(9).name  := 'SUM1';
                   l_inputs(9).value := p_sum;
			 l_inputs(10).name  := 'BANK_CODE';
                   l_inputs(10).value := l_bank_code;
			 l_inputs(11).name  := 'EMPLOYER_CODE';
                   l_inputs(11).value := l_employer_code;
                   l_outputs(1).name := 'WRITE_TEXT1';
                   l_outputs(2).name := 'WRITE_TEXT2';
                   l_outputs(3).name := 'WRITE_TEXT3';
                   l_outputs(4).name := 'WRITE_TEXT4';
                   l_outputs(5).name := 'WRITE_TEXT5';
                   l_outputs(6).name := 'REPORT1_TEXT1';
                   l_outputs(7).name := 'REPORT1_TEXT2';
                   l_outputs(8).name := 'REPORT1_TEXT3';
                   l_outputs(9).name := 'REPORT1_TEXT4';
                   l_outputs(10).name := 'REPORT1_TEXT5';
                   l_outputs(11).name := 'REPORT2_TEXT1';
                   l_outputs(12).name := 'REPORT2_TEXT2';
                   l_outputs(13).name := 'REPORT2_TEXT3';
                   l_outputs(14).name := 'REPORT2_TEXT4';
                   l_outputs(15).name := 'REPORT2_TEXT5';
 IF l_id_header is not null then
         run_formula
                 (l_id_header
                  ,p_Date_Earned
                  ,l_inputs
                  ,l_outputs);
 END IF;
   IF l_outputs.count > 0 and l_outputs.count > 0 THEN
     FOR i IN l_outputs.first..l_outputs.last LOOP
         IF l_outputs(i).name like 'WRITE_TEXT1' THEN
           p_write_text1 := l_outputs(i).value;
       ELSIF l_outputs(i).name like 'WRITE_TEXT2'  THEN
           p_write_text2 := l_outputs(i).value;
       ELSIF l_outputs(i).name like 'WRITE_TEXT3'  THEN
           p_write_text3 := l_outputs(i).value;
       ELSIF l_outputs(i).name like 'WRITE_TEXT4'  THEN
           p_write_text4 := l_outputs(i).value;
       ELSIF l_outputs(i).name like 'WRITE_TEXT5'  THEN
           p_write_text5 := l_outputs(i).value;
       ELSIF l_outputs(i).name like 'REPORT1_TEXT1'  THEN
           p_report_text1 := l_outputs(i).value;
       ELSIF l_outputs(i).name like 'REPORT1_TEXT2'  THEN
           p_report_text2 := l_outputs(i).value;
       ELSIF l_outputs(i).name like 'REPORT1_TEXT3'  THEN
           p_report_text3 := l_outputs(i).value;
       ELSIF l_outputs(i).name like 'REPORT1_TEXT4'  THEN
           p_report_text4 := l_outputs(i).value;
       ELSIF l_outputs(i).name like 'REPORT1_TEXT5'  THEN
           p_report_text5 := l_outputs(i).value;
      ELSIF l_outputs(i).name like 'REPORT2_TEXT1'  THEN
           p_report_text6 := l_outputs(i).value;
      ELSIF l_outputs(i).name like 'REPORT2_TEXT2'  THEN
           p_report_text7 := l_outputs(i).value;
      ELSIF l_outputs(i).name like 'REPORT2_TEXT3'  THEN
           p_report_text8 := l_outputs(i).value;
      ELSIF l_outputs(i).name like 'REPORT2_TEXT4'  THEN
           p_report_text9 := l_outputs(i).value;
      ELSIF l_outputs(i).name like 'REPORT2_TEXT5'  THEN
           p_report_text10 := l_outputs(i).value;
         END IF;
      END LOOP;
   END IF;
 RETURN '1';
 END get_customer_formula_header;
 --
 FUNCTION get_customer_formula_body      (
                                  p_assignment_id IN number,
                                  p_business_group_id IN number,
                                  p_per_pay_method_id IN number,
                                  p_date_earned IN date,
                                  p_payroll_id IN number,
                                  p_payroll_action_id IN number,
                                  p_assignment_action_id IN number,
                                  p_organization_id IN number,
                                  p_tax_unit_id IN number,
                                  p_amount IN varchar2,
                                  p_first_name IN varchar2,
                                  p_last_name IN varchar2,
                                  p_initials IN varchar2,
                                  p_emp_no IN varchar2,
                                  p_asg_no IN varchar2,
                                  p_count IN varchar2,
                                  p_sum IN varchar2
                                 ,p_write_text1  OUT NOCOPY VARCHAR2
                                 ,p_write_text2  OUT NOCOPY VARCHAR2
                                 ,p_write_text3  OUT NOCOPY VARCHAR2
                                 ,p_write_text4  OUT NOCOPY VARCHAR2
                                 ,p_write_text5  OUT NOCOPY VARCHAR2
                                 ,p_report_text1 OUT NOCOPY VARCHAR2
                                 ,p_report_text2 OUT NOCOPY VARCHAR2
                                 ,p_report_text3 OUT NOCOPY VARCHAR2
                                 ,p_report_text4 OUT NOCOPY VARCHAR2
                                 ,p_report_text5 OUT NOCOPY VARCHAR2
                                 ,p_report_text6 OUT NOCOPY VARCHAR2
                                 ,p_report_text7 OUT NOCOPY VARCHAR2
                                 ,p_report_text8 OUT NOCOPY VARCHAR2
                                 ,p_report_text9 OUT NOCOPY VARCHAR2
                                 ,p_report_text10 OUT NOCOPY VARCHAR2
                                 ,p_local_nationality IN VARCHAR2
					   ,p_bank_code IN VARCHAR2
                     	         ,p_employer_code IN VARCHAR2) return varchar2 IS
 l_header varchar2(100);
 l_body varchar2(100);
 l_footer varchar2(100);
 l_bank_code varchar2(100);
 l_employer_code varchar2(100);
 l_inputs ff_exec.inputs_t;
 l_outputs ff_exec.outputs_t;
 cursor c_get_name(p_payment_method_id NUMBER) is
 select PMETH_INFORMATION1,PMETH_INFORMATION2,PMETH_INFORMATION3,PMETH_INFORMATION4,PMETH_INFORMATION5
 from PAY_ORG_PAYMENT_METHODS_F where ORG_PAYMENT_METHOD_ID = p_payment_method_id;
 begin
 open c_get_name(l_payment_method_id);
 fetch c_get_name into l_id_header,l_id_body,l_id_footer,l_employer_code,l_bank_code;
 close c_get_name;
                   l_inputs(1).name  := 'ASSIGNMENT_ID';
                   l_inputs(1).value := p_assignment_id;
                   l_inputs(2).name  := 'BUSINESS_GROUP_ID';
                   l_inputs(2).value := p_business_group_id;
                   l_inputs(3).name  := 'PER_PAY_METHOD_ID';
                   l_inputs(3).value := p_per_pay_method_id;
                   l_inputs(4).name  := 'DATE_EARNED';
                   l_inputs(4).value := fnd_date.date_to_canonical(p_date_earned);
                   l_inputs(5).name  := 'PAYROLL_ID';
                   l_inputs(5).value := p_payroll_id;
                   l_inputs(6).name  := 'PAYROLL_ACTION_ID';
                   l_inputs(6).value := p_payroll_action_id;
                   l_inputs(7).name  := 'ASSIGNMENT_ACTION_ID';
                   l_inputs(7).value := p_assignment_action_id;
                   l_inputs(8).name  := 'ORGANIZATION_ID';
                   l_inputs(8).value := p_organization_id;
                   l_inputs(9).name  := 'TAX_UNIT_ID';
                   l_inputs(9).value := p_tax_unit_id;
                   l_inputs(10).name  := 'AMOUNT';
                   l_inputs(10).value := p_amount;
                   l_inputs(11).name  := 'FIRST_NAME';
                   l_inputs(11).value := p_first_name;
                   l_inputs(12).name  := 'LAST_NAME';
                   l_inputs(12).value := p_last_name;
                   l_inputs(13).name  := 'INITIALS';
                   l_inputs(13).value := p_initials;
                   l_inputs(14).name  := 'EMP_NO';
                   l_inputs(14).value := p_emp_no;
                   l_inputs(15).name  := 'ASG_NO';
                   l_inputs(15).value := p_asg_no;
                   l_inputs(16).name  := 'TRANSFER_COUNT1';
                   l_inputs(16).value := p_count;
                   l_inputs(17).name  := 'TRANSFER_SUM1';
                   l_inputs(17).value := p_sum;
                   l_inputs(18).name  := 'ORG_PAY_METHOD_ID';
                   l_inputs(18).value := l_payment_method_id;
                   l_inputs(19).name  := 'LOCAL_NATIONALITY';
                   l_inputs(19).value := p_local_nationality;
			 l_inputs(20).name  := 'BANK_CODE';
                   l_inputs(20).value := l_bank_code;
			 l_inputs(21).name  := 'EMPLOYER_CODE';
                   l_inputs(21).value := l_employer_code;
                   l_outputs(1).name := 'WRITE_TEXT1';
                   l_outputs(2).name := 'WRITE_TEXT2';
                   l_outputs(3).name := 'WRITE_TEXT3';
                   l_outputs(4).name := 'WRITE_TEXT4';
                   l_outputs(5).name := 'WRITE_TEXT5';
                   l_outputs(6).name := 'REPORT1_TEXT1';
                   l_outputs(7).name := 'REPORT1_TEXT2';
                   l_outputs(8).name := 'REPORT1_TEXT3';
                   l_outputs(9).name := 'REPORT1_TEXT4';
                   l_outputs(10).name := 'REPORT1_TEXT5';
                   l_outputs(11).name := 'REPORT2_TEXT1';
                   l_outputs(12).name := 'REPORT2_TEXT2';
                   l_outputs(13).name := 'REPORT2_TEXT3';
                   l_outputs(14).name := 'REPORT2_TEXT4';
                   l_outputs(15).name := 'REPORT2_TEXT5';
 IF l_id_body is not null then
         run_formula
                 (l_id_body
                  ,p_Date_Earned
                  ,l_inputs
                  ,l_outputs);
 END IF;
   IF l_outputs.count > 0 and l_outputs.count > 0 THEN
     FOR i IN l_outputs.first..l_outputs.last LOOP
         IF l_outputs(i).name like 'WRITE_TEXT1' THEN
           p_write_text1 := l_outputs(i).value;
      ELSIF l_outputs(i).name like 'WRITE_TEXT2'  THEN
           p_write_text2 := l_outputs(i).value;
      ELSIF l_outputs(i).name like 'WRITE_TEXT3'  THEN
           p_write_text3 := l_outputs(i).value;
      ELSIF l_outputs(i).name like 'WRITE_TEXT4'  THEN
           p_write_text4 := l_outputs(i).value;
      ELSIF l_outputs(i).name like 'WRITE_TEXT5'  THEN
           p_write_text5 := l_outputs(i).value;
      ELSIF l_outputs(i).name like 'REPORT1_TEXT1'  THEN
           p_report_text1 := l_outputs(i).value;
      ELSIF l_outputs(i).name like 'REPORT1_TEXT2'  THEN
           p_report_text2 := l_outputs(i).value;
      ELSIF l_outputs(i).name like 'REPORT1_TEXT3'  THEN
           p_report_text3 := l_outputs(i).value;
      ELSIF l_outputs(i).name like 'REPORT1_TEXT4'  THEN
           p_report_text4 := l_outputs(i).value;
      ELSIF l_outputs(i).name like 'REPORT1_TEXT5'  THEN
           p_report_text5 := l_outputs(i).value;
      ELSIF l_outputs(i).name like 'REPORT2_TEXT1'  THEN
           p_report_text6 := l_outputs(i).value;
      ELSIF l_outputs(i).name like 'REPORT2_TEXT2'  THEN
           p_report_text7 := l_outputs(i).value;
      ELSIF l_outputs(i).name like 'REPORT2_TEXT3'  THEN
           p_report_text8 := l_outputs(i).value;
      ELSIF l_outputs(i).name like 'REPORT2_TEXT4'  THEN
           p_report_text9 := l_outputs(i).value;
      ELSIF l_outputs(i).name like 'REPORT2_TEXT5'  THEN
           p_report_text10 := l_outputs(i).value;
	END IF;
      END LOOP;
   END IF;
 RETURN '1';
 end get_customer_formula_body;
 ------
 -------------
 --
 FUNCTION get_customer_formula_footer    (
                                  p_Date_Earned  IN DATE
                                 ,p_payment_method_id IN number
                                 ,p_business_group_id IN number
                                 ,p_payroll_id IN number
                                 ,p_payroll_action_id IN number
                                 ,p_creation_date  IN VARCHAR2
                                 ,p_process_date   IN VARCHAR2
                                 ,p_count          IN VARCHAR2
                                 ,p_sum            IN VARCHAR2
                                 ,p_write_text1  OUT NOCOPY VARCHAR2
                                 ,p_write_text2  OUT NOCOPY VARCHAR2
                                 ,p_write_text3  OUT NOCOPY VARCHAR2
                                 ,p_write_text4  OUT NOCOPY VARCHAR2
                                 ,p_write_text5  OUT NOCOPY VARCHAR2
                                 ,p_report_text1 OUT NOCOPY VARCHAR2
                                 ,p_report_text2 OUT NOCOPY VARCHAR2
                                 ,p_report_text3 OUT NOCOPY VARCHAR2
                                 ,p_report_text4 OUT NOCOPY VARCHAR2
                                 ,p_report_text5 OUT NOCOPY VARCHAR2
                                 ,p_report_text6 OUT NOCOPY VARCHAR2
                                 ,p_report_text7 OUT NOCOPY VARCHAR2
                                 ,p_report_text8 OUT NOCOPY VARCHAR2
                                 ,p_report_text9 OUT NOCOPY VARCHAR2
                                 ,p_report_text10 OUT NOCOPY VARCHAR2
					   ,p_bank_code IN VARCHAR2
                     	         ,p_employer_code IN VARCHAR2) return varchar2 IS
 l_header varchar2(100);
 l_body varchar2(100);
 l_footer varchar2(100);
 l_bank_code varchar2(100);
 l_employer_code varchar2(100);
 l_inputs ff_exec.inputs_t;
 l_outputs ff_exec.outputs_t;
 cursor c_get_name(p_payment_method_id NUMBER) is
 select PMETH_INFORMATION1,PMETH_INFORMATION2,PMETH_INFORMATION3,PMETH_INFORMATION4,PMETH_INFORMATION5
 from PAY_ORG_PAYMENT_METHODS_F where ORG_PAYMENT_METHOD_ID = p_payment_method_id;
 begin
 l_payment_method_id := p_payment_method_id;
 open c_get_name(p_payment_method_id);
 fetch c_get_name into l_id_header,l_id_body,l_id_footer,l_employer_code,l_bank_code;
 close c_get_name;
                   l_inputs(1).name  := 'DATE_EARNED';
                   l_inputs(1).value := fnd_date.date_to_canonical(p_date_earned);
                   l_inputs(2).name  := 'ORG_PAY_METHOD_ID';
                   l_inputs(2).value := p_payment_method_id;
                   l_inputs(3).name  := 'BUSINESS_GROUP_ID';
                   l_inputs(3).value := p_business_group_id;
                   l_inputs(4).name  := 'PAYROLL_ID';
                   l_inputs(4).value := p_payroll_id;
                   l_inputs(5).name  := 'PAYROLL_ACTION_ID';
                   l_inputs(5).value := p_payroll_action_id;
                   l_inputs(6).name  := 'CREATION_DATE';
                   l_inputs(6).value := p_creation_date;
                   l_inputs(7).name  := 'PAYMENT_DATE';
                   l_inputs(7).value := p_process_date;
                   l_inputs(8).name  := 'COUNT1';
                   l_inputs(8).value := p_count;
                   l_inputs(9).name  := 'SUM1';
                   l_inputs(9).value := p_sum;
			 l_inputs(10).name  := 'BANK_CODE';
                   l_inputs(10).value := l_bank_code;
			 l_inputs(11).name  := 'EMPLOYER_CODE';
                   l_inputs(11).value := l_employer_code;
                   l_outputs(1).name := 'WRITE_TEXT1';
                   l_outputs(2).name := 'WRITE_TEXT2';
                   l_outputs(3).name := 'WRITE_TEXT3';
                   l_outputs(4).name := 'WRITE_TEXT4';
                   l_outputs(5).name := 'WRITE_TEXT5';
                   l_outputs(6).name := 'REPORT1_TEXT1';
                   l_outputs(7).name := 'REPORT1_TEXT2';
                   l_outputs(8).name := 'REPORT1_TEXT3';
                   l_outputs(9).name := 'REPORT1_TEXT4';
                   l_outputs(10).name := 'REPORT1_TEXT5';
                   l_outputs(11).name := 'REPORT2_TEXT1';
                   l_outputs(12).name := 'REPORT2_TEXT2';
                   l_outputs(13).name := 'REPORT2_TEXT3';
                   l_outputs(14).name := 'REPORT2_TEXT4';
                   l_outputs(15).name := 'REPORT2_TEXT5';
 IF l_id_footer is not null then
 run_formula
                 (l_id_footer
                  ,p_Date_Earned
                  ,l_inputs
                  ,l_outputs);
 END IF;
   IF l_outputs.count > 0 and l_outputs.count > 0 THEN
     FOR i IN l_outputs.first..l_outputs.last LOOP
         IF l_outputs(i).name like 'WRITE_TEXT1' THEN
           p_write_text1 := l_outputs(i).value;
      ELSIF l_outputs(i).name like 'WRITE_TEXT2'  THEN
           p_write_text2 := l_outputs(i).value;
      ELSIF l_outputs(i).name like 'WRITE_TEXT3'  THEN
           p_write_text3 := l_outputs(i).value;
      ELSIF l_outputs(i).name like 'WRITE_TEXT4'  THEN
           p_write_text4 := l_outputs(i).value;
      ELSIF l_outputs(i).name like 'WRITE_TEXT5'  THEN
           p_write_text5 := l_outputs(i).value;
      ELSIF l_outputs(i).name like 'REPORT1_TEXT1'  THEN
           p_report_text1 := l_outputs(i).value;
      ELSIF l_outputs(i).name like 'REPORT1_TEXT2'  THEN
           p_report_text2 := l_outputs(i).value;
      ELSIF l_outputs(i).name like 'REPORT1_TEXT3'  THEN
           p_report_text3 := l_outputs(i).value;
      ELSIF l_outputs(i).name like 'REPORT1_TEXT4'  THEN
           p_report_text4 := l_outputs(i).value;
      ELSIF l_outputs(i).name like 'REPORT1_TEXT5'  THEN
           p_report_text5 := l_outputs(i).value;
      ELSIF l_outputs(i).name like 'REPORT2_TEXT1'  THEN
           p_report_text6 := l_outputs(i).value;
      ELSIF l_outputs(i).name like 'REPORT2_TEXT2'  THEN
           p_report_text7 := l_outputs(i).value;
      ELSIF l_outputs(i).name like 'REPORT2_TEXT3'  THEN
           p_report_text8 := l_outputs(i).value;
      ELSIF l_outputs(i).name like 'REPORT2_TEXT4'  THEN
           p_report_text9 := l_outputs(i).value;
      ELSIF l_outputs(i).name like 'REPORT2_TEXT5'  THEN
           p_report_text10 := l_outputs(i).value;
         END IF;
      END LOOP;
   END IF;
 RETURN '1';
 end get_customer_formula_footer;
 ---
 ----------
 -----
 PROCEDURE run_formula(p_formula_id      IN NUMBER
                      ,p_effective_date  IN DATE
                      ,p_inputs          IN ff_exec.inputs_t
                      ,p_outputs         IN OUT NOCOPY ff_exec.outputs_t) IS
 l_inputs ff_exec.inputs_t;
 l_outputs ff_exec.outputs_t;
 BEGIN
   hr_utility.set_location('--In Formula ',20);
   --
   -- Initialize the formula
   --
   ff_exec.init_formula(p_formula_id, p_effective_date  , l_inputs, l_outputs);
   --
  hr_utility.trace('after ff_exec');
   -- Set up the input values
   --
   IF l_inputs.count > 0 and p_inputs.count > 0 THEN
     FOR i IN l_inputs.first..l_inputs.last LOOP
       FOR j IN p_inputs.first..p_inputs.last LOOP
         IF l_inputs(i).name = p_inputs(j).name THEN
            l_inputs(i).value := p_inputs(j).value;
            exit;
         END IF;
      END LOOP;
     END LOOP;
   END IF;
   --
   -- Run the formula
   --
  hr_utility.trace('about to exec');
   ff_exec.run_formula(l_inputs,l_outputs);
   --
  hr_utility.trace('After exec');
   -- Populate the output table
   --
   IF l_outputs.count > 0 and p_inputs.count > 0 then
     FOR i IN l_outputs.first..l_outputs.last LOOP
         FOR j IN p_outputs.first..p_outputs.last LOOP
             IF l_outputs(i).name = p_outputs(j).name THEN
               p_outputs(j).value := l_outputs(i).value;
               exit;
             END IF;
         END LOOP;
     END LOOP;
   END IF;
   hr_utility.set_location('--Leaving Formula ',21);
   EXCEPTION
   WHEN hr_formula_error THEN
       fnd_message.set_name('PER','FFX22J_FORMULA_NOT_FOUND');
       fnd_message.set_token('1', g_formula_name);
       fnd_message.raise_error;
   WHEN OTHERS THEN
     raise;
 --
 END run_formula;
 END PAY_KW_EFT;

/
