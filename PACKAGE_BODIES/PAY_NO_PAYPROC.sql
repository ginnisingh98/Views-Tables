--------------------------------------------------------
--  DDL for Package Body PAY_NO_PAYPROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NO_PAYPROC" AS
 /* $Header: pynopproc.pkb 120.2.12010000.2 2009/05/06 09:24:47 rsengupt ship $ */

-- Globals
l_package    CONSTANT VARCHAR2(20):= 'PAY_NO_PAYPROC.';

  /* name of the process , this name is used to do any custom validation, it defaults to NO_ACK */

   g_process                   CONSTANT VARCHAR2 (10) := 'NO_ACK' ;
   c_data_exchange_dir         CONSTANT VARCHAR2 (30) := 'PER_DATA_EXCHANGE_DIR';

 /* Exception Variables */
   e_wrong_csr_routine                      EXCEPTION;
   e_err_in_csr 			    EXCEPTION;
   e_invalid_value                          EXCEPTION;
   e_record_too_long		            EXCEPTION;


   PRAGMA exception_init (e_invalid_value,  -1858);

   /* Global constants */
   c_warning                 CONSTANT NUMBER        := 1;
   c_error                   CONSTANT NUMBER        := 2;
   c_end_of_time             CONSTANT DATE          := to_date('12/31/4712','MM/DD/YYYY');


--------------------------------------------------------------------------------+
  -- Range cursor returns the ids of the assignments to be archived
  --------------------------------------------------------------------------------+
  PROCEDURE range_cursor(
                       p_payroll_action_id IN  NUMBER,
                       p_sqlstr            OUT NOCOPY VARCHAR2)
  IS
    l_proc_name VARCHAR2(100) ;
  BEGIN
    l_proc_name := l_package || 'range_code';
    hr_utility.set_location(l_proc_name, 10);
    p_sqlstr := 'SELECT DISTINCT person_id
                FROM   per_all_people_f    ppf,
                       pay_payroll_actions ppa
                WHERE  ppa.payroll_action_id = :payroll_action_id
                  AND  ppa.business_group_id = ppf.business_group_id
             ORDER BY  ppf.person_id';
    hr_utility.set_location(l_proc_name, 20);
  END range_cursor;
--

----------------------------------------------------------------------------------------------

 --------------------------------------------------------------------------------+
  -- Creates assignment action id for all the valid person id's in
  -- the range selected by the Range code.
  --------------------------------------------------------------------------------+
  PROCEDURE assignment_action_code(
                                   p_payroll_action_id  IN NUMBER,
                                   p_start_person_id    IN NUMBER,
                                   p_end_person_id      IN NUMBER,
                                   p_chunk_number       IN NUMBER)
  IS
    l_proc_name                VARCHAR2(100) ;


-- Bug 5943355 Fix : Changing action_type in pay_payroll_actions from 'Magnetic report' to 'Magnetic transfer'.
-- old : appa.action_type = 'X' (Magnetic report)
-- new : appa.action_type = 'M' (Magnetic transfer)

   CURSOR csr_asg(p_payroll_action_id NUMBER,
		  p_start_person_id   NUMBER,
		  p_end_person_id     NUMBER,
		  p_payroll_id        NUMBER,
		  p_consolidation_id  NUMBER,
		  p_assignment_set_id   NUMBER,
		  p_person_id   NUMBER) IS
   SELECT act.assignment_action_id,
          act.assignment_id,
          ppp.pre_payment_id
   FROM   pay_assignment_actions act,
          per_all_assignments_f  asg,
          pay_payroll_actions    pa2,
          pay_payroll_actions    pa1,
          pay_pre_payments       ppp,
          pay_org_payment_methods_f OPM,
          per_all_people_f	  pap,
   	  hr_soft_coding_keyflex hsk,
	  pay_payment_types ppt

   WHERE  pa1.payroll_action_id           = p_payroll_action_id
   AND    pa2.payroll_id		  = NVL(p_payroll_id,pa2.payroll_id)
   AND    pa2.effective_date 		  <= pa1.effective_date
   AND    pa2.action_type    		  IN ('U','P') -- Prepayments or Quickpay Prepayments
   AND    act.payroll_action_id		  = pa2.payroll_action_id
   AND    act.action_status    		  = 'C'
   AND    asg.assignment_id    		  = act.assignment_id
   AND    pa1.business_group_id		  = asg.business_group_id
   AND    pa1.effective_date between  asg.effective_start_date and asg.effective_end_date
   AND    pa1.effective_date between  pap.effective_start_date and pap.effective_end_date
   AND    pa1.effective_date between  opm.effective_start_date and opm.effective_end_date
   AND    pap.person_id			  = asg.person_id
   AND    pap.person_id      between  p_start_person_id and p_end_person_id
   AND    ppp.assignment_action_id 	  = act.assignment_action_id
   AND    ppp.org_payment_method_id 	  = opm.org_payment_method_id
   AND    ppt.payment_type_id= opm.payment_type_id
   AND    ( ppt.payment_type_name like 'NO Money Order' or ppt.category in ('MT'))
   AND    pap.person_id 		  = NVL(p_person_id,pap.person_id)
   AND    (ppt.category in ('MT') or exists ( select '1'
                                               FROM  per_addresses pad
                                              WHERE pad.person_id = asg.person_id
                                                and pad.PRIMARY_FLAG ='Y')
          )
   AND    (p_assignment_set_id IS NULL
   	            OR EXISTS (     SELECT ''
   	    	        	    FROM   hr_assignment_set_amendments hr_asg
   	    	        	    WHERE  hr_asg.assignment_set_id = p_assignment_set_id
   	    	        	    AND    hr_asg.assignment_id     = asg.assignment_id
           	                 ))
   AND    NOT EXISTS (SELECT /*+ ORDERED */ NULL
                   FROM   pay_action_interlocks pai1,
                          pay_assignment_actions act2,
                          pay_payroll_actions appa
                   WHERE  pai1.locked_action_id = act.assignment_action_id
                   AND    act2.assignment_action_id = pai1.locking_action_id
                   AND    act2.payroll_action_id = appa.payroll_action_id
                   -- AND    appa.action_type = 'X'
		   AND    appa.action_type = 'M'
                   AND    appa.report_type = 'NO_PP')
  and    hsk.SOFT_CODING_KEYFLEX_ID = asg.SOFT_CODING_KEYFLEX_ID
  and    hsk.enabled_flag = 'Y'
  and    hsk.segment2 in (
       select hoi2.org_information1
       from HR_ORGANIZATION_UNITS o1
	  , HR_ORGANIZATION_INFORMATION hoi1
	  , HR_ORGANIZATION_INFORMATION hoi2
       WHERE o1.business_group_id = pa1.business_group_id
            and hoi1.organization_id = o1.organization_id
            and hoi1.organization_id =  to_number(PAY_NO_PAYPROC_UTILITY.get_parameter
	                                         (pa1.payroll_action_id,'LEGAL_EMPLOYER'))
            and hoi1.ORG_INFORMATION_CONTEXT='CLASS'
            and hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
            and hoi1.organization_id = hoi2.organization_id
            and hoi2.ORG_INFORMATION_CONTEXT='NO_LOCAL_UNITS'
                        )  ;


  l_payroll_id 		VARCHAR2(15):=NULL;
  l_consolidation_set 	VARCHAR2(15):=NULL;
  l_locking_action_id   VARCHAR2(15):=NULL;
  l_assignment_set_id   VARCHAR2(15):=NULL;
  l_person_id		VARCHAR2(15):=NULL;

  BEGIN

    l_proc_name := l_package || 'assignment_action_code';
    hr_utility.set_location(l_proc_name, 10);

    l_payroll_id := to_number(PAY_NO_PAYPROC_UTILITY.get_parameter(p_payroll_action_id,'PAYROLL_ID'));
    l_consolidation_set := to_number(PAY_NO_PAYPROC_UTILITY.get_parameter(p_payroll_action_id,'CONSOLIDATION_SET_ID'));
    l_assignment_set_id :=to_number(PAY_NO_PAYPROC_UTILITY.get_parameter(p_payroll_action_id,'ASSIGNMENT_SET_ID'));

    hr_utility.set_location(l_proc_name, 20);

    FOR rec_asg IN csr_asg(p_payroll_action_id
    			  ,p_start_person_id
    			  ,p_end_person_id
    			  ,l_payroll_id
    			  ,l_consolidation_set
    			  ,l_assignment_set_id
    			  ,l_person_id) LOOP

      SELECT pay_assignment_actions_s.nextval
      INTO   l_locking_action_id
      FROM   dual;

       hr_nonrun_asact.insact(lockingactid  => l_locking_action_id,
                              assignid      => rec_asg.assignment_id,
                              pactid        => p_payroll_action_id,
                              chunk         => p_chunk_number,
                              greid         => NULL,
                              prepayid      => rec_asg.pre_payment_id,
                              status        => 'U');

       --
       -- insert the lock on the run action.
       --

        hr_nonrun_asact.insint(l_locking_action_id
                        , rec_asg.assignment_action_id);
       --

    END LOOP;
    hr_utility.set_location(l_proc_name, 40);

  EXCEPTION
    WHEN OTHERS THEN
      hr_utility.set_location('Error in assignment action code ',100);
      RAISE;
  END assignment_action_code;

-----------------------------------------------------------------------------------------------------------------

 FUNCTION get_application_header (
         p_transaction_date in varchar2
	,p_sequence_number in number
	,p_write_text1  OUT NOCOPY VARCHAR2 ) return varchar2 IS


  l_text varchar2(250); -- Bug 6969057

  begin

      l_text :=get_lookup_meaning ('NO_PAYMENT_PROCESS_LABELS','AH')||'2'||'00'||get_lookup_meaning ('NO_PAYMENT_PROCESS_LABELS','TBII')|| to_char(to_date(p_transaction_date,'YYYYMMDD'),'MMDD') || lpad(p_sequence_number,6,'0')||
                rpad(' ',8,' ')||rpad(' ',11,' ')||'04';

       p_write_text1 := l_text;

  RETURN '1';
  end get_application_header;

 ----------------------------------------------------------------------------

FUNCTION get_betfor00_record   (
                             p_Date_Earned  IN DATE
                            ,p_payment_method_id IN number
                            ,p_business_group_id IN number
                            ,p_payroll_id IN number
                            ,p_payroll_action_id IN number
                            ,p_production_date  IN VARCHAR2
                            ,p_seq_control  IN VARCHAR2
                            ,p_write_text1  OUT NOCOPY VARCHAR2
                            ,p_write_text2  OUT NOCOPY VARCHAR2
                            ,p_write_text3  OUT NOCOPY VARCHAR2
                            ,p_write_text4  OUT NOCOPY VARCHAR2
			    ,p_division in varchar2
			    ,p_password in varchar2
			    ,p_new_password in varchar2) return varchar2 IS

 cursor c_get_enterprise_number is
 select pop.pmeth_information1
     from pay_org_payment_methods_f pop,
             pay_payment_types ppt,
             pay_org_pay_method_usages_f ppu,
             pay_payroll_actions ppa

     where ppt.payment_type_id=pop.payment_type_id
        and ppt.category in ('MT')
        and ppu.payroll_id=p_payroll_id
        and pop.org_payment_method_id=ppu.org_payment_method_id
        and ppa.effective_date between pop.effective_start_date and pop.effective_end_date
        and ppa.payroll_action_id=p_payroll_action_id
        and rownum<2;


l_division varchar2(20) := NULL;
l_password varchar2(20) := NULL;
l_new_password varchar(20) := NULL;

l_enterprise_number number(11);

l_text1 varchar2(100);
l_text2 varchar2(100);
l_text3 varchar2(100);
l_text4 varchar2(100);

l_return_val varchar2(15);

 begin


   l_division := UPPER(p_division);
   l_password := UPPER(p_password);
   l_new_password := UPPER(p_new_password);


 open c_get_enterprise_number;
 fetch c_get_enterprise_number into l_enterprise_number;
 close c_get_enterprise_number;

if l_division is NULL then
   l_division := '   ';
 end if;

 if l_password is NULL then
    l_password := '   ';
 end if;

 if l_new_password is NULL then
   l_new_password := '   ';
 end if;

  l_text1 := get_lookup_meaning ('NO_PAYMENT_PROCESS_LABELS','BF00')||lpad(to_char(l_enterprise_number),11,'0')||rpad(UPPER(l_division),11,' ')||
             lpad(p_seq_control,4,'0')||rpad(' ',6,' ');

  l_text2 := to_char(to_date(p_production_date,'YYYYMMDD'),'MMDD')||
	     rpad(UPPER(l_password),10,' ')||get_lookup_meaning ('NO_PAYMENT_PROCESS_LABELS','VER')||rpad(UPPER(l_new_password),10,' ')||rpad(' ',11,' ')||' '||
	     rpad('0',6,'0')||rpad('0',20,'0')||rpad(' ',1,' ')||rpad(' ',7,' ');

  l_text3 := rpad(' ',80,' ');


  l_text4:= rpad(' ',56,' ')||lpad(p_payroll_action_id,15,'0')||rpad(' ',9,' ');

       p_write_text1 := l_text1;
       p_write_text2 := l_text2;
       p_write_text3 := l_text3;
       p_write_text4 := l_text4;

 l_return_val := lpad(to_char(l_enterprise_number),11,'0');
 RETURN l_return_val;

 end get_betfor00_record;

---------------------------------------------------------------------------------------------------

FUNCTION get_betfor99_record   (
                             p_Date_Earned  IN DATE
                            ,p_payment_method_id IN number
                            ,p_business_group_id IN number
                            ,p_payroll_id IN number
                            ,p_payroll_action_id IN number
                            ,p_production_date  IN VARCHAR2
                            ,p_seq_control  IN VARCHAR2
                            ,p_write_text1  OUT NOCOPY VARCHAR2
                            ,p_write_text2  OUT NOCOPY VARCHAR2
                            ,p_write_text3  OUT NOCOPY VARCHAR2
                            ,p_write_text4  OUT NOCOPY VARCHAR2
			    ,p_enterprise_no in varchar2
			    ,p_nos_payments in varchar2
			    ,p_nos_records in varchar2) return varchar2 IS



l_text1 varchar2(100);
l_text2 varchar2(100);
l_text3 varchar2(100);
l_text4 varchar2(100);

 begin


  update pay_payroll_actions set action_type='M' where payroll_action_id=p_payroll_action_id;


  l_text1 := get_lookup_meaning ('NO_PAYMENT_PROCESS_LABELS','BF99')||lpad(to_char(p_enterprise_no),11,'0')||rpad(' ',11,' ')||
             lpad(p_seq_control,4,'0')||rpad(' ',6,' ');

   -- Modified for bug fix 4253690
  l_text2 := to_char(to_date(p_production_date,'YYYYMMDD'),'MMDD')||lpad(p_nos_payments,4,'0')
            ||lpad('0',15,'0')||lpad(p_nos_records,5,'0')||rpad(' ',52,' ');

  l_text3 := rpad(' ',80,' ');


  l_text4:= rpad(' ',31,' ')||rpad(' ',4,' ')||rpad(' ',1,' ')||rpad(' ',1,' ')||rpad(' ',1,' ')
            ||rpad(' ',18,' ')||lpad(get_lookup_meaning ('NO_PAYMENT_PROCESS_LABELS','VERSW'),16,' ')||rpad(' ',8,' ');

       p_write_text1 := l_text1;
       p_write_text2 := l_text2;
       p_write_text3 := l_text3;
       p_write_text4 := l_text4;

 RETURN '1';
 end get_betfor99_record;

------------------------------------------------------------------------------------------------
FUNCTION get_betfor21_mass_record   (
                             p_assignment_id IN number
                            ,p_business_group_id IN number
                            ,p_per_pay_method_id IN number
   			    ,p_org_pay_method_id IN number
                            ,p_date_earned IN date
                            ,p_payroll_id IN number
                            ,p_payroll_action_id IN number
                            ,p_assignment_action_id IN number
                            ,p_org_account_number IN varchar2
                            ,p_payment_date  IN VARCHAR2
                            ,p_seq_control  IN VARCHAR2
			    ,p_enterprise_no IN varchar2
                            ,p_write_text1  OUT NOCOPY VARCHAR2
                            ,p_write_text2  OUT NOCOPY VARCHAR2
                            ,p_write_text3  OUT NOCOPY VARCHAR2
                            ,p_write_text4  OUT NOCOPY VARCHAR2 ) return varchar2 IS



l_enterprise_number number(11);

l_text1 varchar2(100);
l_text2 varchar2(100);
l_text3 varchar2(100);
l_text4 varchar2(100);

 begin


 l_text1 := get_lookup_meaning ('NO_PAYMENT_PROCESS_LABELS','BF21')||lpad(to_char(p_enterprise_no),11,'0')||lpad(to_char(p_org_account_number),11,'0')||
             lpad(p_seq_control,4,'0')||rpad(' ',6,' ');

 l_text2 := to_char(to_date(p_payment_date,'YYYYMMDD'),'YYMMDD')||rpad(' ',30,' ')||rpad(' ',1,' ')
            ||rpad('0',11,'0')||rpad(' ',30,' ')||rpad(' ',2,' ');

 l_text3 := rpad(' ',28,' ')||rpad(' ',30,' ')||rpad('0',4,'0')||rpad(' ',18,' ');

  -- Modified last two fields for bug fix 4253690
 l_text4 := rpad(' ',8,' ')||rpad('0',15,'0')||'604'||'L'||rpad(' ',1,' ')||rpad('0',15,'0')
           ||rpad(' ',5,' ')||rpad('0',6,'0')||rpad('0',6,'0')||rpad(' ',1,' ')||rpad(' ',9,' ')||lpad('0',10,'0');

       p_write_text1 := l_text1;
       p_write_text2 := l_text2;
       p_write_text3 := l_text3;
       p_write_text4 := l_text4;

 RETURN '1';
 end get_betfor21_mass_record;

----------------------------------------------------------------------------
FUNCTION get_next_value(p_sequence varchar2,p_type varchar2) return varchar2
is

l_next_value varchar2(50);
l_number number(10);

begin

l_number := to_number(p_sequence);

if l_number = 9999 and p_type = 'SERIAL_NUM' then
       hr_utility.set_message (801, 'PAY_376830_NO_SERIAL_NUM_OVER');
       hr_utility.raise_error;
       return '-1';
end if;

 if l_number = 9999 and p_type = 'SEQ_CONTROL' then
	l_number := -1;
 end if;

if l_number = 999999 and p_type = 'SEQ_NO' then
	l_number := 0;
 end if;

l_number := l_number+1;
l_next_value := to_char(l_number);

RETURN l_next_value;
end get_next_value;

---------------------------------------------------------------------------
FUNCTION get_betfor22_record   (
                             p_assignment_id IN number
                            ,p_business_group_id IN number
                            ,p_per_pay_method_id IN number
   			    ,p_org_pay_method_id IN number
                            ,p_date_earned IN date
                            ,p_payroll_id IN number
                            ,p_payroll_action_id IN number
                            ,p_assignment_action_id IN number
                            ,p_org_account_number IN varchar2
 			    ,p_last_name in varchar2
			    ,p_first_name in varchar2
			    ,p_amount in varchar2
			    ,p_serial_number in varchar2
                            ,p_seq_control  IN VARCHAR2
			    ,p_enterprise_no IN varchar2
                            ,p_write_text1  OUT NOCOPY VARCHAR2
                            ,p_write_text2  OUT NOCOPY VARCHAR2
                            ,p_write_text3  OUT NOCOPY VARCHAR2
                            ,p_write_text4  OUT NOCOPY VARCHAR2  ) return varchar2 is



l_enterprise_number number(11);

l_text1 varchar2(100);
l_text2 varchar2(100);
l_text3 varchar2(100);
l_text4 varchar2(100);


l_per_account_num PAY_EXTERNAL_ACCOUNTS.SEGMENT6%TYPE;

l_payee_name varchar2(100);
l_amount number(15);

cursor get_per_org_account_no is
  select pea.segment6
   from pay_external_accounts pea,
    	pay_personal_payment_methods_f ppp
   where
           ppp.personal_payment_method_id=p_per_pay_method_id
       and ppp.external_account_id=pea.external_account_id;

begin

     open get_per_org_account_no;
     fetch get_per_org_account_no into l_per_account_num;
     close get_per_org_account_no;

     l_payee_name := UPPER(substr(p_last_name || ' ' || p_first_name,1,30));
     l_amount := p_amount*100;


    l_text1 := get_lookup_meaning ('NO_PAYMENT_PROCESS_LABELS','BF22')||lpad(to_char(p_enterprise_no),11,'0')||p_org_account_number||
             lpad(p_seq_control,4,'0')||rpad(' ',6,' ');

    l_text2 := lpad(to_char(l_per_account_num),11,'0')||rpad(l_payee_name,30,' ')||lpad(l_amount,15,'0')
              ||rpad(' ',1,' ')||rpad(' ',23,' ');

    l_text3 := rpad(' ',80,' ');

     -- Modified for bug fix 4253690
    l_text4 := rpad(' ',42,' ')||lpad(p_assignment_action_id,10,'0')||lpad('0',4,'0')||rpad(' ',1,' ')||rpad(' ',23,' ');


       p_write_text1 := l_text1;
       p_write_text2 := l_text2;
       p_write_text3 := l_text3;
       p_write_text4 := l_text4;

RETURN '1';
end get_betfor22_record;

---------------------------------------------------------------------------

FUNCTION get_betfor21_invoice_record   (
                             p_assignment_id IN number
                            ,p_business_group_id IN number
                            ,p_per_pay_method_id IN number
   			    ,p_org_pay_method_id IN number
                            ,p_date_earned IN date
                            ,p_payroll_id IN number
                            ,p_payroll_action_id IN number
                            ,p_assignment_action_id IN number
                            ,p_org_account_number IN varchar2
                            ,p_payment_date  IN VARCHAR2
                            ,p_seq_control  IN VARCHAR2
			    ,p_enterprise_no IN varchar2
			    ,p_payee_first_name in varchar2
			    ,p_payee_last_name in varchar2
                            ,p_write_text1  OUT NOCOPY VARCHAR2
                            ,p_write_text2  OUT NOCOPY VARCHAR2
                            ,p_write_text3  OUT NOCOPY VARCHAR2
                            ,p_write_text4  OUT NOCOPY VARCHAR2
			    ,p_status OUT NOCOPY VARCHAR2
			    ,p_audit_address OUT NOCOPY VARCHAR2) return varchar2 is

l_enterprise_number number(11);

l_text1 varchar2(100);
l_text2 varchar2(100);
l_text3 varchar2(100);
l_text4 varchar2(100);

l_audit_text varchar2(500);

l_payee_name varchar2(100);


l_address1 	per_addresses.ADDRESS_LINE1%TYPE;
l_address2  	per_addresses.ADDRESS_LINE2%TYPE;
l_post_code 	per_addresses.POSTAL_CODE%TYPE;
--Modified for bug fix 4253729
l_city 		VARCHAR2(80); --per_addresses.TOWN_OR_CITY%TYPE;

--Modified cursor for bug fix 4253729
CURSOR csr_get_address(p_assignment_id number)
is
select ADDRESS_LINE1,ADDRESS_LINE2,POSTAL_CODE --,TOWN_OR_CITY
  FROM  per_addresses pad
       ,per_all_assignments_f paf
       ,per_all_people_f pef

    WHERE    paf.assignment_id=p_assignment_id
         and paf.person_id = pef.person_id
         and pad.person_id= pef.person_id
         and pad.PRIMARY_FLAG ='Y';

begin

     p_status := 'OK';
     open csr_get_address(p_assignment_id);
     --Modified for bug fix 4253729
     fetch csr_get_address into l_address1,l_address2,l_post_code ; --,l_city;
     --Added for bug fix 4253729
     l_city := substr(get_lookup_meaning ('NO_POSTAL_CODE',l_post_code),6);

     IF csr_get_address%NOTFOUND THEN
	 p_status := 'WARNING';

         p_write_text1 := ' ';
         p_write_text2 := ' ';
         p_write_text3 := ' ';
         p_write_text4 := ' ';
         p_audit_address := '*';

	 RETURN '1';
     END IF;
     close csr_get_address;


     l_payee_name := UPPER(substr(p_payee_last_name || ' ' || p_payee_first_name,1,30));

     if l_address1=NULL then
        l_address1 := '   '||'  ';
     end if;

     if l_address2=NULL then
        l_address2 := '   '||'  ';
     end if;




 l_text1 := get_lookup_meaning ('NO_PAYMENT_PROCESS_LABELS','BF21')||lpad(to_char(p_enterprise_no),11,'0')||p_org_account_number||
             lpad(p_seq_control,4,'0')||rpad(' ',6,' ');

 l_text2 := to_char(to_date(p_payment_date,'YYYYMMDD'),'YYMMDD')||lpad(to_char(p_assignment_action_id),30,'0')
              ||rpad(' ',1,' ')||lpad('19',11,'0')||rpad(l_payee_name,30,' ')||
	       rpad(UPPER(substr(rpad(NVL(l_address1,'  '),30,' '),1,2)),2,' ');

 l_text3 := rpad(UPPER(SUBSTR(rpad(NVL(l_address1,'  '),30,' '),3,28)),28,' ')||rpad(UPPER(NVL(l_address2,' ')),30,' ')||
               lpad(l_post_code,4,'0')||rpad(UPPER(SUBSTR(rpad(NVL(l_city,' '),26,' '),1,18)),18,' ');

 -- Modified last two fields for bug fix 4253690
 l_text4 := rpad(UPPER(SUBSTR(rpad(NVL(l_city,' '),26,' '),19,8)),8,' ')||rpad('0',15,'0')||'604'||'L'||rpad(' ',1,' ')
               ||rpad('0',15,'0')||rpad(' ',5,' ')||rpad('0',6,'0')||rpad('0',6,'0')||rpad(' ',1,' ')
	       ||rpad(' ',9,' ')||lpad('0',10,'0');



     l_audit_text := l_address1|| ',' ||l_address2|| ',' ||l_post_code||','||l_city;

       p_write_text1 := l_text1;
       p_write_text2 := l_text2;
       p_write_text3 := l_text3;
       p_write_text4 := l_text4;

       p_audit_address := l_audit_text;

RETURN '1';
end get_betfor21_invoice_record;

-----------------------------------------------------------------------------------------------------------

FUNCTION get_betfor23_record   (
                             p_assignment_id IN number
                            ,p_business_group_id IN number
                            ,p_per_pay_method_id IN number
   			    ,p_org_pay_method_id IN number
                            ,p_date_earned IN date
                            ,p_payroll_id IN number
                            ,p_payroll_action_id IN number
                            ,p_assignment_action_id IN number
                            ,p_org_account_number IN varchar2
			    ,p_amount in varchar2
                            ,p_seq_control  IN VARCHAR2
			    ,p_enterprise_no IN varchar2
                            ,p_write_text1  OUT NOCOPY VARCHAR2
                            ,p_write_text2  OUT NOCOPY VARCHAR2
                            ,p_write_text3  OUT NOCOPY VARCHAR2
                            ,p_write_text4  OUT NOCOPY VARCHAR2  ) return varchar2 is

l_text1 varchar2(100);
l_text2 varchar2(100);
l_text3 varchar2(100);
l_text4 varchar2(100);

l_amount number(15);

begin

    l_amount := p_amount*100;


    l_text1 := get_lookup_meaning ('NO_PAYMENT_PROCESS_LABELS','BF23')||lpad(to_char(p_enterprise_no),11,'0')||p_org_account_number||
             lpad(p_seq_control,4,'0')||rpad(' ',6,' ');

    l_text2 := rpad(' ',40,' ')||rpad(' ',40,' ');

    l_text3 := rpad(' ',40,' ')||rpad(' ',27,' ')||lpad(SUBSTR(lpad(to_char(p_assignment_action_id),30,'0'),1,13),13,'0');


    l_text4 := lpad(SUBSTR(lpad(to_char(p_assignment_action_id),30,'0'),14,17),17,'0')||lpad(l_amount,15,'0')||
               'D'||rpad(' ',20,' ')||rpad(' ',3,' ')||rpad(' ',1,' ')||rpad(' ',15,' ')||rpad('0',8,'0');

       p_write_text1 := l_text1;
       p_write_text2 := l_text2;
       p_write_text3 := l_text3;
       p_write_text4 := l_text4;

RETURN '1';
end get_betfor23_record;

--------------------------------------------------------------------------------

FUNCTION get_audit_record (
                             p_assignment_id IN number
                            ,p_business_group_id IN number
                            ,p_per_pay_method_id IN number
   			    ,p_org_pay_method_id IN number
                            ,p_date_earned IN date
                            ,p_payroll_id IN number
                            ,p_payroll_action_id IN number
                            ,p_assignment_action_id IN number
			    ,p_type_of_record  in varchar2
 			    ,p_last_name in varchar2
			    ,p_first_name in varchar2
			    ,p_amount in varchar2
                            ,p_report2_text1 OUT NOCOPY VARCHAR2
    			    ,p_ni_number in varchar2) return varchar2 is


l_text1 varchar2(300);


l_per_account_num 	PAY_EXTERNAL_ACCOUNTS.SEGMENT6%TYPE;

l_per_account_num_t  varchar2(17);
l_text_account_no varchar2(30);

l_payee_name varchar2(100);
l_amount varchar2(25);

cursor get_per_org_account_no is
  select pea.segment6
   from pay_external_accounts pea,
    	pay_personal_payment_methods_f ppp
   where
           ppp.personal_payment_method_id=p_per_pay_method_id
       and ppp.external_account_id=pea.external_account_id;


begin

IF p_type_of_record = 'BETFOR22' then

     open get_per_org_account_no;
     fetch get_per_org_account_no into l_per_account_num;
     close get_per_org_account_no;

     l_payee_name := UPPER(substr(p_last_name || ' ' || p_first_name,1,50));

     -- Bug 5943490 Fix : Correct Number Format
     -- l_amount := p_amount||'.00';
     l_amount := trim(to_char(trunc(p_amount,2),'999G999G999D99')) ;

     l_per_account_num_t := lpad(to_char(l_per_account_num),11,'0');

     l_text_account_no := SUBSTR(l_per_account_num_t,1,4)||'.'||SUBSTR(l_per_account_num_t,5,2)
                        ||'.'||SUBSTR(l_per_account_num_t,7,5);

     l_text1 := rpad(p_ni_number,30,' ')||rpad(l_payee_name,50,' ')||rpad(to_char(l_text_account_no),25,' ')||
                rpad(' ',5,' ')||rpad(l_amount,30,' ')||rpad(' ',5,' ');

     p_report2_text1 := l_text1;

elsif  p_type_of_record = 'BETFOR23' then

     l_payee_name := UPPER(substr(p_last_name || ' ' || p_first_name,1,30));

     -- Bug 5943490 Fix : Correct Number Format
     -- l_amount := p_amount||'.00';
     l_amount := trim(to_char(trunc(p_amount,2),'999G999G999D99')) ;

     l_text1 := rpad(p_ni_number,30,' ')||rpad(l_payee_name,50,' ')||rpad('-',30,' ')||
               rpad(l_amount,25,' ')||rpad(' ',5,' ');

     p_report2_text1 := l_text1;


end if;

RETURN '1';
end get_audit_record;

-----------------------------------------------------------------------------

FUNCTION get_legal_emp_name(p_business_group_id IN number,p_legal_emp_id IN varchar2
                             ,p_legal_emp_name OUT NOCOPY VARCHAR2)
return varchar2 is

 cursor c_get_legal_emp_name is
 select o.name
     from HR_ORGANIZATION_UNITS o
    WHERE o.business_group_id = p_business_group_id
       and o.organization_id = to_number(p_legal_emp_id);


l_legal_emp_name hr_organization_units.NAME%TYPE ;

begin


open c_get_legal_emp_name;
fetch c_get_legal_emp_name into l_legal_emp_name;
close c_get_legal_emp_name;

p_legal_emp_name := l_legal_emp_name;
return l_legal_emp_name;


end  get_legal_emp_name;
-------------------------------------------------------------------------------

FUNCTION update_seq_values   (
                             p_payroll_id IN number
			    ,p_ah_seq     IN varchar2
                            ,p_seq_control  IN VARCHAR2) return varchar2 IS

  l_org_pay_method_id NUMBER;
  l_ah_seq                   NUMBER ;
  l_seq_control             NUMBER  ;



BEGIN

  l_ah_seq            := to_number(p_ah_seq);
  l_seq_control       := to_number(p_seq_control);

select pop.ORG_PAYMENT_METHOD_ID
into l_org_pay_method_id
from pay_org_payment_methods_f pop,
     pay_payment_types ppt,
     pay_org_pay_method_usages_f ppu

where ppt.payment_type_id=pop.payment_type_id
  and ppt.category in ('MT')
  and ppu.payroll_id=p_payroll_id
  and pop.org_payment_method_id=ppu.org_payment_method_id
  and rownum<2;



if l_seq_control = 9999 then
	l_seq_control := 0;
 else
	l_seq_control := l_seq_control + 1;
end if;


if l_ah_seq = 999999  then
	l_ah_seq := 1;
 else
	l_ah_seq := l_ah_seq + 1;
end if;

update pay_org_payment_methods_f
set pmeth_information3=l_ah_seq , pmeth_information4=l_seq_control
where ORG_PAYMENT_METHOD_ID=l_org_pay_method_id;

RETURN '1';

end update_seq_values;
-------------------------------------------------------------------------------
/* Acknowledgement Reply Functions */

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
   PROCEDURE upload(
      errbuf                            OUT NOCOPY   VARCHAR2,
      retcode                           OUT NOCOPY   NUMBER,
      p_file_name                       IN           VARCHAR2,
      p_effective_date             	IN           VARCHAR2,
      p_business_group_id       	IN           VARCHAR2
   )
   IS

      /*  Constants */
      c_read_file              CONSTANT VARCHAR2 (1)         := 'r';
      c_max_linesize           CONSTANT NUMBER               := 4000;

      /*  Procedure name */
      l_proc                      CONSTANT VARCHAR2 (72)           :=    l_package||'.read' ;

     /*  File Handling variables */
      l_file_type               UTL_FILE.file_type;
      l_filename                VARCHAR2 (240);
      l_location                VARCHAR2 (4000);
      l_record_read             VARCHAR2 (1000)   ;
      l_record_write            VARCHAR2 (1000)   ;
      l_num_of_records          NUMBER  ;
      l_column_heading1         VARCHAR2 (1000)  ;
      l_column_heading2         VARCHAR2 (1000)  ;
      l_column_underline        VARCHAR2 (1000)   ;

      l_heading_emp         VARCHAR2 (100) ;
      l_heading_num         VARCHAR2 (100) ;
      l_heading_amt         VARCHAR2 (100) ;
      l_heading_return      VARCHAR2 (100) ;
      l_heading_code        VARCHAR2 (100) ;
      l_heading_seq         VARCHAR2 (100) ;
      l_heading_ah          VARCHAR2 (100) ;
      l_heading_ref         VARCHAR2 (100) ;
      l_heading_serial      VARCHAR2 (100) ;
      l_heading_name        VARCHAR2 (100) ;
      l_heading_remark      VARCHAR2 (100) ;

      /*  Variables to Read from File */
    l_trans_code            varchar2(8);
    l_val_seq_no            varchar2(20);
    l_val_return_code       varchar2(20);
    l_val_ref_no            varchar2(20);
    l_val_remark            varchar2(200);
    l_val_serial_no         varchar2(4);
    l_ah_trans_date         varchar2(20);
    l_ah_proc_id            varchar2(20);
    l_enterprise_no         varchar2(20);
    l_division              varchar2(20);
    l_production_date       varchar2(20);
    l_no_of_payments        varchar2(20);
    l_tot_amt_batch         varchar2(20);
    l_no_of_records         varchar2(20);
    l_emp_no                varchar2(20);
    l_emp_name              varchar2(50);
    l_own_ref               varchar2(30);
    l_asg_act_id            NUMBER;
    l_emp_name_old          varchar2(50) ;
    l_amount        	    varchar2(20);
    l_val_seq_no_prev        varchar2(20);

	/*  local Variables for calculation  */
	l_acc_pay_no       NUMBER:=0;
	l_acc_pay_amt      NUMBER:=0;
	l_rej_pay_no       NUMBER:=0;
    	l_rej_pay_amt      NUMBER:=0;


	  /*  Exceptions */
      e_fatal_error                   EXCEPTION;
      BETFOR00_NOT_FOUND              EXCEPTION;

    BEGIN


      l_record_read             := NULL;
      l_record_write             := NULL;
      l_num_of_records           := 0;
      l_column_heading1          := NULL;
      l_column_heading2           := NULL;
      l_column_underline        := NULL;

      l_emp_name_old         := ' ' ;
      l_heading_emp          := get_lookup_meaning ('NO_PAYMENT_PROCESS_LABELS','EMP');
      l_heading_num          := get_lookup_meaning ('NO_PAYMENT_PROCESS_LABELS','NUM');
      l_heading_amt          := get_lookup_meaning ('NO_PAYMENT_PROCESS_LABELS','AMT');
      l_heading_return       := get_lookup_meaning ('NO_PAYMENT_PROCESS_LABELS','RET');
      l_heading_code         := get_lookup_meaning ('NO_PAYMENT_PROCESS_LABELS','CODE');
      l_heading_seq          := get_lookup_meaning ('NO_PAYMENT_PROCESS_LABELS','SEQ');
      l_heading_ah           := get_lookup_meaning ('NO_PAYMENT_PROCESS_LABELS','AH');
      l_heading_ref          := get_lookup_meaning ('NO_PAYMENT_PROCESS_LABELS','REF');
      l_heading_serial       := get_lookup_meaning ('NO_PAYMENT_PROCESS_LABELS','SER');
      l_heading_name         := get_lookup_meaning ('NO_PAYMENT_PROCESS_LABELS','NAME');
      l_heading_remark       := get_lookup_meaning ('NO_PAYMENT_PROCESS_LABELS','REM');

	l_filename := p_file_name;
 	fnd_profile.get (c_data_exchange_dir, l_location);

      /*  error : I/O directory not defined */
      IF l_location IS NULL THEN
         RAISE e_fatal_error;
      END IF;

      ------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*   getting file header information
    - open the file
    - read the first record
    - check fro BETFOR00
    - if not present , raise error else print details */
BEGIN

	l_file_type := UTL_FILE.fopen (l_location, l_filename, c_read_file, c_max_linesize);
	/* read the entire record consisting of the 4 lines of data from file */
           read_lines (  p_process  => g_process
	                     ,p_file_type => l_file_type
                             ,p_record  => l_record_read );
	/* read the transaction code from the record */
	read_trans_code
	      (  p_process  => g_process
		,p_line        =>  l_record_read
		,p_trans_code   => l_trans_code
	      );
	   	 /* check for BETFOR00 */

	    fnd_file.put_line (fnd_file.LOG,'');
	    fnd_file.put_line (fnd_file.LOG,'');
	    fnd_file.put_line (fnd_file.LOG,get_lookup_meaning ('NO_PAYMENT_PROCESS_LABELS','NAL'));
	    fnd_file.put_line (fnd_file.LOG,'====================================================');
   	    fnd_file.put_line (fnd_file.LOG,'');

	    IF  l_trans_code <> 'BETFOR00' THEN

	    fnd_file.put_line (fnd_file.LOG,get_lookup_meaning ('NO_PAYMENT_PROCESS_LABELS','RNV00'));
	    RAISE BETFOR00_NOT_FOUND;
            ELSE
		  /* get batch details */
		    l_ah_trans_date     :=  SUBSTR(l_record_read,10,4);
		    l_ah_proc_id          :=  SUBSTR(l_record_read,6,4);
		    l_enterprise_no      :=  SUBSTR(l_record_read,49,11);
		    l_division               :=  SUBSTR(l_record_read,60,11);
		    l_production_date   :=  SUBSTR(l_record_read,81,4);

		  fnd_file.put_line (fnd_file.LOG,get_lookup_meaning ('NO_PAYMENT_PROCESS_LABELS','ARFN') || ' : ' || l_filename);
		  fnd_file.put_line (fnd_file.LOG,'');
		  fnd_file.put_line (fnd_file.LOG,l_heading_ah || ' - ' || get_lookup_meaning ('NO_PAYMENT_PROCESS_LABELS','TD') ||' : ' || l_ah_trans_date);
		  fnd_file.put_line (fnd_file.LOG,'');
		  fnd_file.put_line (fnd_file.LOG,l_heading_ah || ' - ' || get_lookup_meaning ('NO_PAYMENT_PROCESS_LABELS','PI') ||' : '  || l_ah_proc_id);
		  fnd_file.put_line (fnd_file.LOG,'');
		  fnd_file.put_line (fnd_file.LOG,get_lookup_meaning ('NO_PAYMENT_PROCESS_LABELS','EN') ||' : ' || l_enterprise_no);
		  fnd_file.put_line (fnd_file.LOG,'');
		  fnd_file.put_line (fnd_file.LOG,get_lookup_meaning ('NO_PAYMENT_PROCESS_LABELS','DIV') ||' : '  || l_division);
		  fnd_file.put_line (fnd_file.LOG,'');
		  fnd_file.put_line (fnd_file.LOG,get_lookup_meaning ('NO_PAYMENT_PROCESS_LABELS','PD') ||' : '  || l_production_date);
		  fnd_file.put_line (fnd_file.LOG,'');
           END IF;
	UTL_FILE.fclose (l_file_type);
	EXCEPTION
	    WHEN BETFOR00_NOT_FOUND
            THEN
	    	   fnd_file.put_line (fnd_file.LOG,'');
		   fnd_file.put_line (fnd_file.LOG,'');
	   fnd_file.put_line (fnd_file.LOG,get_lookup_meaning ('NO_PAYMENT_PROCESS_LABELS','EAL'));
	  fnd_file.put_line (fnd_file.LOG,'=========================================');
		  fnd_file.put_line (fnd_file.LOG,'');
        	   fnd_file.put_line (fnd_file.LOG,'');


	 END;

      ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
      /* regular redaing of the file */

      /* Open flat file */
      l_file_type := UTL_FILE.fopen (l_location, l_filename, c_read_file, c_max_linesize);


      /* Loop over the file, reading in each line.  GET_LINE will
          raise NO_DATA_FOUND when it is done, so we use that as the
          exit condition for the loop
       */

       l_column_heading1 :=     rpad(l_heading_ah || ' '  ||  l_heading_seq,16,' ')
                                       || rpad(l_heading_ah || ' '  ||  l_heading_return,13,' ')
                                       || rpad(l_heading_ref,14,' ')
                                       || rpad(l_heading_serial,10,' ')
                                       || rpad(l_heading_emp,31,' ')
				       || rpad(l_heading_emp,31,' ')
				       || rpad(l_heading_amt,17,' ')
                                       || rpad(l_heading_return || ' '  ||  l_heading_code,15,' ') ;

       l_column_heading2 :=     rpad(l_heading_num,16,' ')
                                       || rpad(l_heading_code,13,' ')
                                       || rpad(l_heading_num,14,' ')
                                       || rpad(l_heading_num,10,' ')
                                       || rpad(l_heading_num,31,' ')
				       || rpad(l_heading_name,31,' ')
				       || rpad(' ',17,' ')
                                       || rpad(l_heading_remark,15,' ') ;


      l_column_underline :=  lpad(' ',16 ,'=')
                                    || lpad(' ',13 ,'=')
				    || lpad(' ',14 ,'=')
				    || lpad(' ',10 ,'=')
				    || lpad(' ',31 ,'=')
				    || lpad(' ',31 ,'=')
				    || lpad(' ',17 ,'=')
				    || lpad(' ',15 ,'=');

      fnd_file.put_line (fnd_file.LOG,'');
      fnd_file.put_line (fnd_file.LOG,l_column_heading1 );
      fnd_file.put_line (fnd_file.LOG,l_column_heading2 );
      fnd_file.put_line (fnd_file.LOG,l_column_underline );
      fnd_file.put_line (fnd_file.LOG,'');

      <<read_lines_in_file>>
      LOOP
         BEGIN

	/* read the entire record consisting of the 4 lines of data from file */
           read_lines (  p_process  => g_process
	                     ,p_file_type => l_file_type
                             ,p_record  => l_record_read );

	/* read the transaction code from the record */
	read_trans_code
	      (  p_process  => g_process
		,p_line     =>  l_record_read
		,p_trans_code   => l_trans_code
	      );

        /* increment the no. of records */
	    l_num_of_records := l_num_of_records + 1;


        EXCEPTION
            WHEN VALUE_ERROR             -- Input line too large for buffer specified in UTL_FILE.fopen
            THEN
               IF UTL_FILE.is_open (l_file_type)
               THEN
                  UTL_FILE.fclose (l_file_type);
               END IF;
               retcode := c_error;
	       EXIT;

	    WHEN NO_DATA_FOUND
            THEN
		IF l_trans_code <> 'BETFOR99' THEN
			fnd_file.put_line (fnd_file.LOG,'');
			fnd_file.put_line (fnd_file.LOG,get_lookup_meaning ('NO_PAYMENT_PROCESS_LABELS','RNV99'));
		ELSE

			fnd_file.put_line (fnd_file.LOG,'');
			fnd_file.put_line (fnd_file.LOG,'');

			fnd_file.put_line (fnd_file.LOG,get_lookup_meaning ('NO_PAYMENT_PROCESS_LABELS','NAP') ||' : '  || l_acc_pay_no);
			fnd_file.put_line (fnd_file.LOG,get_lookup_meaning ('NO_PAYMENT_PROCESS_LABELS','TAA') ||' : '  || l_acc_pay_amt);
	                fnd_file.put_line (fnd_file.LOG,'');
			fnd_file.put_line (fnd_file.LOG,get_lookup_meaning ('NO_PAYMENT_PROCESS_LABELS','NRP') ||' : '  || l_rej_pay_no);
			fnd_file.put_line (fnd_file.LOG,get_lookup_meaning ('NO_PAYMENT_PROCESS_LABELS','TRA') ||' : '  || l_rej_pay_amt);
	                fnd_file.put_line (fnd_file.LOG,'');
			fnd_file.put_line (fnd_file.LOG,get_lookup_meaning ('NO_PAYMENT_PROCESS_LABELS','NP') ||' : '  || l_no_of_payments);
	                fnd_file.put_line (fnd_file.LOG,'');
			fnd_file.put_line (fnd_file.LOG,get_lookup_meaning ('NO_PAYMENT_PROCESS_LABELS','TAB') ||' : '  || l_tot_amt_batch);
			fnd_file.put_line (fnd_file.LOG,'');
			fnd_file.put_line (fnd_file.LOG,get_lookup_meaning ('NO_PAYMENT_PROCESS_LABELS','NR') ||' : '  || l_no_of_records);
			fnd_file.put_line (fnd_file.LOG,'');

		END IF;
	   fnd_file.put_line (fnd_file.LOG,'');
           fnd_file.put_line (fnd_file.LOG,'');
	   fnd_file.put_line (fnd_file.LOG,get_lookup_meaning ('NO_PAYMENT_PROCESS_LABELS','EAL'));
	  fnd_file.put_line (fnd_file.LOG,'=======================================================');
	   fnd_file.put_line (fnd_file.LOG,'');
	   fnd_file.put_line (fnd_file.LOG,'');
	  EXIT;

	 END;

	 BEGIN

	    read_record
	      (p_process             	=> 	g_process
		,p_line                 => 	l_record_read
	  	,p_trans_code     	=> 	l_trans_code
		,p_ah_seq_no       	=>	l_val_seq_no
		,p_ah_ret_code    	=>	l_val_return_code
		,p_ref_no             	=>	l_val_ref_no
		,p_serial_no         	=>	l_val_serial_no
		,p_emp_no           	=>	l_emp_no
		,p_emp_name     	=>	l_emp_name
		,p_amount           	=>	l_amount
		,p_ret_code_rem  	=>	l_val_remark
		,p_emp_name_old 	=>	l_emp_name_old
		,p_ah_seq_no_prev     	=> 	l_val_seq_no_prev
		,p_acc_pay_no     	=>	l_acc_pay_no
		,p_acc_pay_amt  	=>	l_acc_pay_amt
		,p_rej_pay_no     	=>	l_rej_pay_no
		,p_rej_pay_amt   	=>	l_rej_pay_amt
	);

		 /* Get specific fields from BETFORXX */
	    IF  l_trans_code = 'BETFOR22' THEN
		l_val_seq_no_prev := l_val_seq_no;

	    ELSIF  l_trans_code = 'BETFOR23' THEN
	         l_emp_name := l_emp_name_old;
		l_val_seq_no_prev := l_val_seq_no;

	    ELSIF l_trans_code = 'BETFOR99' THEN
		    l_no_of_payments      :=  SUBSTR(l_record_read,85,4);
		    l_tot_amt_batch         :=  SUBSTR(l_record_read,89,15);
		    l_no_of_records          :=  SUBSTR(l_record_read,104,5);

	    END IF;


 l_record_write:= rpad(l_val_seq_no ,16 , ' ') ||
                          rpad(l_val_return_code ,13,   ' ') ||
			  rpad(l_val_ref_no ,14 , ' ') ||
                	  rpad(l_val_serial_no ,10 ,      ' ') ||
			  rpad(l_emp_no ,31,' ') ||
                	  rpad(l_emp_name ,31,' ') ||
                	  rpad(l_amount ,17,' ') ||
			  l_val_remark;

 fnd_file.put_line (fnd_file.LOG,l_record_write);

 EXCEPTION
      WHEN e_record_too_long         --Record is too long
	     THEN                              -- Set retcode to 1, indicating a WARNING to the ConcMgr
		 retcode := c_warning;

         END;
      END LOOP read_lines_in_file;


      UTL_FILE.fclose (l_file_type);


   -- Most of these exceptions are not translated as they should not happen normally
   -- If they do happen, something is seriously wrong and SysAdmin interference will be necessary.

   EXCEPTION
      WHEN e_fatal_error
      -- No directory specified
      THEN
         -- Close the file in case of error
         IF UTL_FILE.is_open (l_file_type)
         THEN
            UTL_FILE.fclose (l_file_type);
         END IF;


         -- Set retcode to 2, indicating an ERROR to the ConcMgr
         retcode := c_error;

         -- Set the application error
         hr_utility.set_message (801, 'PAY_376826_NO_DATA_EXC_DIR_MIS');

         -- Return the message to the ConcMgr (This msg will appear in the log file)

	 errbuf := hr_utility.get_message;

      WHEN UTL_FILE.invalid_operation
      -- File could not be opened as requested, perhaps because of operating system permissions
      -- Also raised when attempting a write operation on a file opened for read, or a read operation
      -- on a file opened for write.

      THEN
         IF UTL_FILE.is_open (l_file_type)
         THEN
            UTL_FILE.fclose (l_file_type);
         END IF;

	 retcode := c_error;
         errbuf := 'Reading File ('||l_location ||' -> '
                                   || l_filename
                                   || ') - Invalid Operation.';
      WHEN UTL_FILE.internal_error
      -- Unspecified internal error
      THEN
         IF UTL_FILE.is_open (l_file_type)
         THEN
            UTL_FILE.fclose (l_file_type);
         END IF;

	 retcode := c_error;
         errbuf :=    'Reading File ('
                   || l_location
                   || ' -> '
                   || l_filename
                   || ') - Internal Error.';

      WHEN UTL_FILE.invalid_mode
      -- Invalid string specified for file mode
      THEN
         IF UTL_FILE.is_open (l_file_type)
         THEN
            UTL_FILE.fclose (l_file_type);
         END IF;

         retcode := c_error;
         errbuf :=    'Reading File ('
                   || l_location
                   || ' -> '
                   || l_filename
                   || ') - Invalid Mode.';

      WHEN UTL_FILE.invalid_path
      -- Directory or filename is invalid or not accessible
      THEN
         IF UTL_FILE.is_open (l_file_type)
         THEN
            UTL_FILE.fclose (l_file_type);
         END IF;

         retcode := c_error;
         errbuf :=    'Reading File ('
                   || l_location
                   || ' -> '
                   || l_filename
                   || ') - Invalid Path or Filename.';

      WHEN UTL_FILE.invalid_filehandle
      -- File type does not specify an open file
      THEN
         IF UTL_FILE.is_open (l_file_type)
         THEN
            UTL_FILE.fclose (l_file_type);
         END IF;

         retcode := c_error;
         errbuf :=    'Reading File ('
                   || l_location
                   || ' -> '
                   || l_filename
                   || ') - Invalid File Type.';
      WHEN UTL_FILE.read_error

      -- Operating system error occurred during a read operation
      THEN
         IF UTL_FILE.is_open (l_file_type)
         THEN
            UTL_FILE.fclose (l_file_type);
         END IF;

         retcode := c_error;
         errbuf :=    'Reading File ('
                   || l_location
                   || ' -> '
                   || l_filename
                   || ') - Read Error.';
    END upload;

-----------------------------------------------------------------------------------------------------------------------------------------------------------

PROCEDURE read_lines
	      (  p_process  IN VARCHAR2
	        ,p_file_type IN UTL_FILE.file_type
		,p_record   OUT NOCOPY VARCHAR2
	      )
	      is

	l_line_read                   VARCHAR2 (4000)                        := NULL;

	BEGIN

      IF (p_process = 'NO_ACK') THEN
     /* Read 4 lines of data from the acknowledgement reply file and combine it in 1 record */

            UTL_FILE.get_line (p_file_type, l_line_read);
	    p_record:=l_line_read;

	    UTL_FILE.get_line (p_file_type, l_line_read);
	    p_record:=p_record || l_line_read;

	    UTL_FILE.get_line (p_file_type, l_line_read);
   	    p_record:=p_record || l_line_read;

	    UTL_FILE.get_line (p_file_type, l_line_read);
	    p_record:=p_record || l_line_read;


   END IF;
END read_lines;

-----------------------------------------------------------------------------------------------------------------------------------------------------------

PROCEDURE read_trans_code
	      (  p_process  IN VARCHAR2
		,p_line     IN VARCHAR2
		,p_trans_code   OUT NOCOPY VARCHAR2
	      )
	 is

 --Variables to store the extra values read from the flat file
   l_record_length      NUMBER                                   :=4000;

   BEGIN

   IF (p_process = 'NO_ACK') THEN

      --Set record length
      l_record_length := 321;

        p_trans_code  := substr( p_line ,41,8);

   END IF;


   -- Error in record if it is too long according to given format
   IF (length(p_line)> l_record_length) THEN

    RAISE e_record_too_long;
   END IF;

   END read_trans_code;

-----------------------------------------------------------------------------------------------------------------------------------------------------------
   PROCEDURE read_record
	      (p_process  		IN VARCHAR2
		,p_line     		IN VARCHAR2
		,p_trans_code    	IN VARCHAR2
		,p_ah_seq_no       	OUT NOCOPY VARCHAR2
		,p_ah_ret_code    	OUT NOCOPY VARCHAR2
		,p_ref_no             	OUT NOCOPY VARCHAR2
		,p_serial_no       	OUT NOCOPY VARCHAR2
		,p_emp_no          	OUT NOCOPY VARCHAR2
		,p_emp_name       	OUT NOCOPY VARCHAR2
		,p_amount          	OUT NOCOPY VARCHAR2
		,p_ret_code_rem   	OUT NOCOPY VARCHAR2
		,p_emp_name_old  	IN OUT NOCOPY VARCHAR2
		,p_ah_seq_no_prev  	IN OUT NOCOPY VARCHAR2
		,p_acc_pay_no      	IN OUT NOCOPY VARCHAR2
		,p_acc_pay_amt   	IN OUT NOCOPY VARCHAR2
		,p_rej_pay_no      	IN OUT NOCOPY VARCHAR2
		,p_rej_pay_amt     	IN OUT NOCOPY VARCHAR2
		)
   IS


   --Variables to store the extra values read from the flat file
   l_record_length      NUMBER  :=4000;

   -- Procedure name
   l_proc    CONSTANT VARCHAR2 (72)   :=    l_package|| '.read_record';

   --local variables
   l_own_ref        varchar2(50);
   l_asg_act_id     pay_assignment_actions.assignment_action_id%TYPE ;


      /* cursor to get the emp no from the assignment_action_id */
   CURSOR  csr_emp_no(v_asg_act_id  pay_assignment_actions.assignment_action_id%TYPE)
      IS
	SELECT  ppf.employee_number
         FROM   per_all_people_f ppf,
                     per_all_assignments_f paf,
                     pay_assignment_actions paa
         WHERE ppf.person_id=paf.person_id
                 AND paf.assignment_id=paa.assignment_id
                 AND paa.assignment_action_id=v_asg_act_id;

   BEGIN

   IF (p_process = 'NO_ACK') THEN

    --Set record length
      l_record_length := 321;

       p_ah_seq_no       := substr( p_line ,14,6);
       p_ah_ret_code    := substr( p_line ,4,2);
       p_ret_code_rem  := pay_no_payproc.get_lookup_meaning ('NO_RETURN_CODES',p_ah_ret_code);


            IF p_trans_code = 'BETFOR00' THEN

		   p_ref_no           := '----';
		   p_serial_no        := '----';
		   p_emp_no           := '----';
		   p_emp_name         := '----';
		   p_amount           := '----';

           ELSIF p_trans_code = 'BETFOR21' THEN

		   p_ref_no           := substr( p_line ,75,6);
		   p_serial_no        := '----';
		   p_emp_no           := '----';
		   p_emp_name         := '----';
		   p_amount           := '----';
		   p_emp_name_old:=SUBSTR(p_line,129,30);
	           p_ah_seq_no_prev := p_ah_seq_no;

	    ELSIF p_trans_code = 'BETFOR22' THEN

		   p_ref_no           := substr( p_line ,75,6);
		   p_serial_no        := substr( p_line ,293,4);
		   p_emp_name         := substr( p_line ,92,30);
		   /* p_amount           := ltrim(SUBSTR(p_line,122,13),'0') || '.' || SUBSTR(p_line,134,2); */

		   /* Bug Fix 4410230 */
		   p_amount           := ltrim(SUBSTR(p_line,122,13),'0') || '.' || SUBSTR(p_line,135,2);

		    l_own_ref := SUBSTR(p_line,283,10);
		    l_asg_act_id := to_number(ltrim(l_own_ref,'0'));

		     OPEN csr_emp_no (l_asg_act_id);
		     FETCH csr_emp_no INTO p_emp_no;
		     CLOSE csr_emp_no;

		     IF p_emp_no IS NULL THEN
			p_emp_no := ' ';
		     END IF;

		     IF (trim(p_ah_ret_code)='01')  THEN
		          p_acc_pay_no := p_acc_pay_no  + 1;
		          p_acc_pay_amt  := p_acc_pay_amt   + to_number(p_amount);
		    ELSIF (p_ah_seq_no <> p_ah_seq_no_prev) THEN
			   p_rej_pay_no    := p_rej_pay_no  + 1;
		           p_rej_pay_amt   := p_rej_pay_amt + to_number(p_amount);
		    END IF;


	    ELSIF p_trans_code = 'BETFOR23' THEN

		   p_ref_no             := substr( p_line ,75,6);
		   p_serial_no         := substr( p_line ,294,3);
		   /* p_amount := ltrim(SUBSTR(p_line,258,13),'0') || '.' || SUBSTR(p_line,270,2) ; */

		   /* Bug Fix 4410230 */
		   p_amount := ltrim(SUBSTR(p_line,258,13),'0') || '.' || SUBSTR(p_line,271,2) ;

		     p_emp_name:= p_emp_name_old;

		     l_own_ref := SUBSTR(p_line,228,30);
		     l_asg_act_id := to_number(ltrim(l_own_ref,'0'));

		     OPEN csr_emp_no (l_asg_act_id);
		     FETCH csr_emp_no INTO p_emp_no;
		     CLOSE csr_emp_no;

		     IF p_emp_no IS NULL THEN
			p_emp_no := ' ';
		     END IF;

		     IF trim(p_ah_ret_code)='01' THEN
		          p_acc_pay_no := p_acc_pay_no  + 1;
		          p_acc_pay_amt  := p_acc_pay_amt   + to_number(p_amount);
		    ELSIF (p_ah_seq_no <> p_ah_seq_no_prev) THEN
			   p_rej_pay_no     := p_rej_pay_no  + 1;
		           p_rej_pay_amt   := p_rej_pay_amt + to_number(p_amount);
		    END IF;

	    ELSIF p_trans_code = 'BETFOR99' THEN

		   p_ref_no           := '----';
		   p_serial_no        := '----';
		   p_emp_no           := '----';
		   p_emp_name         := '----';
		   p_amount           := '----';

	    END IF;

   END IF;

   -- Error in record if it is too long according to given format
   IF (length(p_line)> l_record_length) THEN
    RAISE e_record_too_long;
   END IF;

   END read_record;


-----------------------------------------------------------------------------------------------------------------------------------------
-- function to get labels of items from a lookup
  FUNCTION get_lookup_meaning (p_lookup_type varchar2,p_lookup_code varchar2) RETURN VARCHAR2 IS
    CURSOR csr_lookup IS
    select meaning
    from   hr_lookups
    where  lookup_type = p_lookup_type
    and    lookup_code = p_lookup_code;
    l_meaning hr_lookups.meaning%type;
  BEGIN
    OPEN csr_lookup;
    FETCH csr_lookup INTO l_Meaning;
    CLOSE csr_lookup;
    RETURN l_meaning;
  END get_lookup_meaning;


  ---------------------------------------------------------------------------------------------------------------


------------------------------------------------------------------------
end  PAY_NO_PAYPROC;

/
