--------------------------------------------------------
--  DDL for Package Body HR_SE_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_SE_UTILITY" AS
-- $Header: hrseutil.pkb 120.2.12010000.2 2009/11/27 10:32:18 dchindar ship $
g_package varchar2(30) := 'hr_se_utility';
 FUNCTION per_se_full_name(
        p_first_name       in varchar2
       ,p_middle_names     in varchar2
       ,p_last_name        in varchar2
       ,p_known_as         in varchar2
       ,p_title            in varchar2
       ,p_suffix           in varchar2
       ,p_pre_name_adjunct in varchar2
       ,p_per_information1 in varchar2
       ,p_per_information2 in varchar2
       ,p_per_information3 in varchar2
       ,p_per_information4 in varchar2
       ,p_per_information5 in varchar2
       ,p_per_information6 in varchar2
       ,p_per_information7 in varchar2
       ,p_per_information8 in varchar2
       ,p_per_information9 in varchar2
       ,p_per_information10 in varchar2
       ,p_per_information11 in varchar2
       ,p_per_information12 in varchar2
       ,p_per_information13 in varchar2
       ,p_per_information14 in varchar2
       ,p_per_information15 in varchar2
       ,p_per_information16 in varchar2
       ,p_per_information17 in varchar2
       ,p_per_information18 in varchar2
       ,p_per_information19 in varchar2
       ,p_per_information20 in varchar2
       ,p_per_information21 in varchar2
       ,p_per_information22 in varchar2
       ,p_per_information23 in varchar2
       ,p_per_information24 in varchar2
       ,p_per_information25 in varchar2
       ,p_per_information26 in varchar2
       ,p_per_information27 in varchar2
       ,p_per_information28 in varchar2
       ,p_per_information29 in varchar2
       ,p_per_information30 in VARCHAR2
       )
       RETURN VARCHAR2 AS
	--
	l_full_name varchar2(240);
	--
BEGIN
   --
   l_full_name := p_last_name|| ', '||p_first_name;
   if p_middle_names is not null then
         l_full_name := l_full_name||', '||p_middle_names||' ';
   end if;
   if p_pre_name_adjunct is not null then
         l_full_name := p_pre_name_adjunct||' '||l_full_name;
   end if;

   return (rtrim(l_full_name));
   --
END;
--
--
FUNCTION per_se_order_name(
        p_first_name       in varchar2
       ,p_middle_names     in varchar2
       ,p_last_name        in varchar2
       ,p_known_as         in varchar2
       ,p_title            in varchar2
       ,p_suffix           in varchar2
       ,p_pre_name_adjunct in varchar2
       ,p_per_information1 in varchar2
       ,p_per_information2 in varchar2
       ,p_per_information3 in varchar2
       ,p_per_information4 in varchar2
       ,p_per_information5 in varchar2
       ,p_per_information6 in varchar2
       ,p_per_information7 in varchar2
       ,p_per_information8 in varchar2
       ,p_per_information9 in varchar2
       ,p_per_information10 in varchar2
       ,p_per_information11 in varchar2
       ,p_per_information12 in varchar2
       ,p_per_information13 in varchar2
       ,p_per_information14 in varchar2
       ,p_per_information15 in varchar2
       ,p_per_information16 in varchar2
       ,p_per_information17 in varchar2
       ,p_per_information18 in varchar2
       ,p_per_information19 in varchar2
       ,p_per_information20 in varchar2
       ,p_per_information21 in varchar2
       ,p_per_information22 in varchar2
       ,p_per_information23 in varchar2
       ,p_per_information24 in varchar2
       ,p_per_information25 in varchar2
       ,p_per_information26 in varchar2
       ,p_per_information27 in varchar2
       ,p_per_information28 in varchar2
       ,p_per_information29 in varchar2
       ,p_per_information30 in VARCHAR2
       )
       RETURN VARCHAR2 AS
	--
	l_order_name varchar2(240);
	--
BEGIN
   --
   l_order_name := p_last_name || '              ' || p_first_name;
   return (rtrim(l_order_name));
   --
END;

 -- Checks whether the input is a valid date.
 --
 FUNCTION chk_valid_date
	(p_date IN VARCHAR2)
	 RETURN VARCHAR2 AS
	l_date DATE;
 BEGIN
	IF substr(p_date,5,2)  - 60  > 0 THEN
		l_date:=to_date(19||(p_date- 60),'YYYYMMDD');
	ELSE
	 	l_date:=to_date(19||p_date,'YYYYMMDD');
	END IF;
        RETURN '1';
 exception
 	WHEN others THEN
 	RETURN '0';
 END ;

FUNCTION validate_account_number
 (p_account_number IN VARCHAR2,
  p_session_id IN NUMBER,
  p_bg_id IN NUMBER
 ) RETURN NUMBER AS
 l_account_type  VARCHAR2(2);
 l_modulus_type  VARCHAR2(2);
 l_no_of_digits  NUMBER;
 l_chk_format  NUMBER;
 l_i  NUMBER;
 l_rem  NUMBER;
 l_calc  NUMBER;
 l_account_number  VARCHAR2(16);
 l_effective_date DATE;
 l_business_group_id	NUMBER;
 begin
		--Fetching the Effective Date for the session.
 		--
 	  begin
 	  	SELECT effective_date
 	  	INTO 	 l_effective_date
 	  	FROM fnd_sessions
 	  	WHERE session_id=p_session_id;
 	  exception
 	  	WHEN others THEN
 	  	null;
 	  end;

	  begin
 		--Check for the Account Type.There are two types of Accounts ie Type 1 and Type 2.
 		--
 		l_account_type:=hruserdt.get_table_value 				(p_bg_id,'SE_BANK_DETAILS','ACCOUNT_TYPE',SUBSTR(p_account_number,1,4),l_effective_date);
 		IF l_account_type IS NULL THEN
 			RETURN 1;
 		END IF;
 		--Fetch the Modulus Type.There are two types of Modulus ie Modulus 10 and Modulus 11.
 		--
 		l_modulus_type:=hruserdt.get_table_value 				(p_bg_id,'SE_BANK_DETAILS','MODULUS_TYPE',SUBSTR(p_account_number,1,4),l_effective_date);

 		--Fetch the No of Digits for Validation.
 		--
 		l_no_of_digits:=hruserdt.get_table_value 				(p_bg_id,'SE_BANK_DETAILS','NO_OF_DIGITS',SUBSTR(p_account_number,1,4),l_effective_date);

 		IF  l_account_type ='1' THEN

 			--The No of Digits should be between 11	and 16
 			--
 			IF  LENGTH(p_account_number) < 11 THEN
 				RETURN 1;
 			END IF;
 			--Pad the last 7 seven Digits upto 12 spaces with 0
 			--
 		  l_account_number := SUBSTR(p_account_number,1,4)||LPAD(SUBSTR(p_account_number,5,12),12,'0');

 		  --Check for Integer Digits
 			--

 		  l_chk_format := hr_ni_chk_pkg.chk_nat_id_format(l_account_number,'DDDDDDDDDDDDDDDD');

 		  -- Using Modulus 11 Validation
  		--
  		l_i := 0;

  		IF l_no_of_digits=11 THEN
  			l_i := l_i + substr(l_account_number,  1, 1) * 1;
  		END IF;
  		l_i := l_i + substr(l_account_number, 2, 1) * 10;
  		l_i := l_i + substr(l_account_number, 3, 1) * 9;
  		l_i := l_i + substr(l_account_number, 4, 1) * 8;
  		l_i := l_i + substr(l_account_number, 10, 1) * 7;
  		l_i := l_i + substr(l_account_number, 11, 1) * 6;
  		l_i := l_i + substr(l_account_number, 12, 1) * 5;
  		l_i := l_i + substr(l_account_number, 13, 1) * 4;
  		l_i := l_i + substr(l_account_number, 14, 1) * 3;
  		l_i := l_i + substr(l_account_number, 15, 1) * 2;
  		l_i := l_i + substr(l_account_number, 16, 1) * 1;

  		l_rem := mod( l_i, 11 );
  		IF l_rem = 0 THEN
  	 		RETURN 0 ;
  		ELSE
  	 		RETURN 1;
  		END IF;
 		ELSE
 			--The No of Digits should be between 6 and 16
 			--
 			IF  LENGTH(p_account_number)NOT BETWEEN 6 AND 16 THEN
 				RETURN 1;
 			END IF;
 			--Pad the last 7 seven Digits upto 12 spaces with 0
 			--
 		  l_account_number := SUBSTR(p_account_number,1,4)||LPAD(SUBSTR(p_account_number,5,10),12,'0');

 		  --Check for Integer Digits
 			--
 		  l_chk_format := hr_ni_chk_pkg.chk_nat_id_format(l_account_number,'DDDDDDDDDDDDDDDD');

 		  -- Using Modulus 10/11 Validation according to Type
  		--
 		  IF l_modulus_type='11' THEN
 		  	-- Using Modulus 11 Validation
  			--
  			l_i := 0;

  			l_i := l_i + substr(l_account_number,  8, 1) * 9;
  			l_i := l_i + substr(l_account_number,  9, 1) * 8;
  			l_i := l_i + substr(l_account_number,  10, 1) * 7;
  			l_i := l_i + substr(l_account_number,  11, 1) * 6;
  			l_i := l_i + substr(l_account_number,  12, 1) * 5;
  			l_i := l_i + substr(l_account_number,  13, 1) * 4;
  			l_i := l_i + substr(l_account_number,  14, 1) * 3;
  			l_i := l_i + substr(l_account_number,  15, 1) * 2;
  			l_i := l_i + substr(l_account_number,  16, 1) * 1;

  			l_rem := mod( l_i, 11 );
  			IF l_rem = 0 THEN
  	 			RETURN 0 ;
  			ELSE
  	 			RETURN 1 ;
  			END IF;
  		ELSE
  			-- Using Modulus 10 Validation
  			--
  		   l_calc :=0;

  			IF l_no_of_digits=12 THEN
  			 l_calc :=l_calc + nvl(substr((substr(l_account_number,5,1)* 2),1,1),0)
				  + nvl(substr((substr(l_account_number,5,1)* 2),2,1),0) ;
   			 l_calc :=l_calc + nvl(substr((substr(l_account_number,6,1)* 1),1,1),0)
				  + nvl(substr((substr(l_account_number,6,1)* 1),2,1),0);
   			END IF;
   			 l_calc :=l_calc + nvl(substr((substr(l_account_number,7,1)* 2),1,1),0)
				  + nvl(substr((substr(l_account_number,7,1)* 2),2,1),0);
   			 l_calc :=l_calc + nvl(substr((substr(l_account_number,8,1)* 1),1,1),0)
				  + nvl(substr((substr(l_account_number,8,1)* 1),2,1),0);
   			 l_calc :=l_calc + nvl(substr((substr(l_account_number,9,1)* 2),1,1),0)
				   + nvl(substr((substr(l_account_number,9,1)* 2),2,1),0)  ;
   			 l_calc :=l_calc + nvl(substr((substr(l_account_number,10,1)* 1),1,1),0)
				  + nvl(substr((substr(l_account_number,10,1)* 1),2,1),0);
   			 l_calc :=l_calc + nvl(substr((substr(l_account_number,11,1)* 2),1,1),0)
				  + nvl(substr((substr(l_account_number,11,1)* 2),2,1),0)  ;
   			 l_calc :=l_calc + nvl(substr((substr(l_account_number,12,1)* 1),1,1),0)
				  + nvl(substr((substr(l_account_number,12,1)* 1),2,1),0)    ;
   			 l_calc :=l_calc + nvl(substr((substr(l_account_number,13,1)* 2),1,1),0)
				  + nvl(substr((substr(l_account_number,13,1)* 2),2,1),0) ;
   			 l_calc :=l_calc + nvl(substr((substr(l_account_number,14,1)* 1),1,1),0)
				  + nvl(substr((substr(l_account_number,14,1)* 1),2,1),0)  ;
   			 l_calc :=l_calc + nvl(substr((substr(l_account_number,15,1)* 2),1,1),0)
				  + nvl(substr((substr(l_account_number,15,1)* 2),2,1),0)    ;
   			 l_calc :=l_calc + nvl(substr((substr(l_account_number,16,1)* 1),1,1),0)
				  + nvl(substr((substr(l_account_number,16,1)* 1),2,1),0) ;

   			 IF mod(l_calc,10)= 0 THEN
   					RETURN 0;
   			 ELSE
   			 	  RETURN 1;
   			 END IF;
  		END IF;
 		END IF;
	exception
 	  	WHEN others THEN
 	  	RETURN 1;
 	  end;
 	end;


----
-- Function added for IBAN Validation
----
FUNCTION validate_iban_acc(p_account_no VARCHAR2)RETURN NUMBER IS
BEGIN
     IF IBAN_VALIDATION_PKG.validate_iban_acc(p_account_no) = 1 then
     RETURN 1;
     else
     RETURN 0;
     END IF;
END validate_iban_acc;

----
-- This function will get called from the bank keyflex field segments
----
FUNCTION validate_account_entered
(p_acc_no        IN VARCHAR2,
 p_is_iban_acc   IN varchar2,
 p_session_id    IN NUMBER default NULL,
 p_bg_id         IN NUMBER default NULL) RETURN NUMBER IS
   --
   l_ret NUMBER ;
 begin
--   hr_utility.trace_on(null,'ACCVAL');
  l_ret :=0;
  hr_utility.set_location('p_is_iban_acc    ' || p_is_iban_acc,1);
  hr_utility.set_location('p_account_number ' || p_acc_no,1);

  IF (p_acc_no IS NOT NULL AND p_is_iban_acc = 'N') then
    l_ret := validate_account_number(p_acc_no, p_session_id, p_bg_id);
    hr_utility.set_location('l_ret ' || l_ret,1);
    RETURN l_ret;
  ELSIF (p_acc_no IS NOT NULL AND p_is_iban_acc = 'Y') then
    l_ret := validate_iban_acc(p_acc_no);
    hr_utility.set_location('l_ret ' || l_ret,3);
    RETURN l_ret;
  ELSIF (p_acc_no IS NULL AND p_is_iban_acc IS NULL) then
    hr_utility.set_location('Both Account Nos Null',4);
    RETURN 1;
  ELSE
    hr_utility.set_location('l_ret: 3 ' ,5);
    RETURN 3;
  END if;
End validate_account_entered;





--------------------------

FUNCTION get_court_order_details
 (p_assignment_id		IN          NUMBER
 ,p_effective_date		IN	   DATE
 ,p_reserved_amount		OUT NOCOPY  NUMBER
 ,p_disdraint_amount	OUT NOCOPY  NUMBER
 ,p_suspension_flag		OUT NOCOPY  VARCHAR2
 ) RETURN NUMBER IS
  --

CURSOR get_details(p_assignment_id NUMBER , p_effective_date  DATE , p_input_value VARCHAR2 ) IS
   SELECT eev1.screen_entry_value  screen_entry_value
   FROM   per_all_assignments_f      asg1
         ,per_all_assignments_f      asg2
         ,per_all_people_f           per
         ,pay_element_links_f        el
         ,pay_element_types_f        et
         ,pay_input_values_f         iv1
         ,pay_element_entries_f      ee
         ,pay_element_entry_values_f eev1
   WHERE  asg1.assignment_id    = p_assignment_id
     AND p_effective_date BETWEEN asg1.effective_start_date AND asg1.effective_end_date
     AND p_effective_date BETWEEN asg2.effective_start_date AND asg2.effective_end_date
     AND p_effective_date BETWEEN ee.effective_start_date AND ee.effective_end_date
     AND p_effective_date BETWEEN eev1.effective_start_date AND eev1.effective_end_date
     AND  per.person_id         = asg1.person_id
     AND  asg2.person_id        = per.person_id
     AND  asg2.primary_flag     = 'Y'
     AND  et.element_name       = 'Court Order Information'
     AND  et.legislation_code   = 'SE'
     AND  iv1.element_type_id   = et.element_type_id
     AND  iv1.name              = p_input_value
     AND  el.business_group_id  = per.business_group_id
     AND  el.element_type_id    = et.element_type_id
     AND  ee.assignment_id      = asg2.assignment_id
     AND  ee.element_link_id    = el.element_link_id
     AND  eev1.element_entry_id = ee.element_entry_id
     AND  eev1.input_value_id   = iv1.input_value_id;

	l_rec get_details%ROWTYPE;
  ---
 BEGIN
  --
  OPEN  get_details(p_assignment_id , p_effective_date ,'Reserved Amount');
  FETCH get_details INTO l_rec;
  p_reserved_amount             := l_rec.screen_entry_value ;
  CLOSE get_details;


  OPEN  get_details(p_assignment_id , p_effective_date , 'Distraint Amount');
  FETCH get_details INTO l_rec;
  p_disdraint_amount            := l_rec.screen_entry_value ;
  CLOSE get_details;


  OPEN  get_details(p_assignment_id , p_effective_date ,'Suspension Flag');
  FETCH get_details INTO l_rec;

  p_suspension_flag        := l_rec.screen_entry_value ;

  CLOSE get_details;


  --
  RETURN 1;
  exception
 	  	WHEN others THEN
 	  	RETURN 1;
  --
 END get_court_order_details;

------------Mileage

FUNCTION GET_COMPANY_MILEAGE_LIMIT
(p_effective_date       IN DATE
,p_business_group_id    IN NUMBER
,p_tax_unit_id		    IN NUMBER
,p_car_type		    IN VARCHAR2
) RETURN NUMBER IS

	CURSOR c_get_details(p_business_group_id NUMBER , p_tax_unit_id NUMBER, p_effective_date DATE) IS
     SELECT hoi2.org_information1,hoi2.org_information2,hoi2.org_information3
     FROM hr_organization_units o1
     , hr_organization_information hoi1
     , hr_organization_information hoi2
     WHERE  o1.business_group_id = p_business_group_id
     AND hoi1.organization_id = o1.organization_id
     AND hoi1.organization_id =  p_tax_unit_id
     AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
     AND hoi1.org_information_context = 'CLASS'
     AND o1.organization_id = hoi2.organization_id
     AND hoi2.ORG_INFORMATION_CONTEXT ='SE_COMPANY_MILEAGE_RATES'
     AND p_effective_date BETWEEN fnd_date.canonical_to_date(hoi2.org_information4) AND
     nvl(fnd_date.canonical_to_date(hoi2.org_information5),to_date('31/12/4712','DD/MM/YYYY'))   ;

		l_rec c_get_details%ROWTYPE;
		l_return NUMBER;

--
BEGIN

	OPEN c_get_details(p_business_group_id,p_tax_unit_id,p_effective_date);
	FETCH c_get_details INTO l_rec;
	CLOSE c_get_details;

	IF p_car_type ='PRIVATE CAR' THEN
		l_return := l_rec.org_information1;
	ELSIF p_car_type ='COMPANY PETROL CAR' THEN
	    l_return := l_rec.org_information2;
    ELSIF p_car_type ='COMPANY DIESEL CAR' THEN
	    l_return := l_rec.org_information3;
	END IF;


	RETURN l_return;

EXCEPTION
 		WHEN others THEN
 		RETURN NULL;

END GET_COMPANY_MILEAGE_LIMIT;

  ------------------------------------------------------------------------
-- Function GET_MESSAGE
-- This function is used to obtain a message.
-- The token parameters must be of the form 'TOKEN_NAME:TOKEN_VALUE' i.e.
-- If you want to set the value of a token called ELEMENT to Social Ins
-- the token parameter would be 'ELEMENT:Social Ins.'
------------------------------------------------------------------------
	function get_message
			(p_product           in varchar2
			,p_message_name      in varchar2
			,p_token1            in varchar2 default null
                        ,p_token2            in varchar2 default null
                        ,p_token3            in varchar2 default null) return varchar2
			is
			   l_message varchar2(2000);
			   l_token_name varchar2(20);
			   l_token_value varchar2(80);
			   l_colon_position number;
			   l_proc varchar2(72) ;
                           l_product varchar2(72);
	--
begin
	--
	   l_proc:= g_package||'.get_message' ;
	   hr_utility.set_location('Entered '||l_proc,5);
	   hr_utility.set_location('.  Message Name: '||p_message_name,40);
           IF p_product in ('800','801') THEN
                l_product :=hr_general.get_application_short_name(p_product);
           else
                l_product :=p_product;
           END IF;
	   fnd_message.set_name(l_product, p_message_name);
	   if p_token1 is not null then
	      /* Obtain token 1 name and value */
	      l_colon_position := instr(p_token1,':');
	      l_token_name  := substr(p_token1,1,l_colon_position-1);
	      l_token_value := substr(p_token1,l_colon_position+1,length(p_token1));
	      fnd_message.set_token(l_token_name, l_token_value);
	      hr_utility.set_location('.  Token1: '||l_token_name||'. Value: '||l_token_value,50);
	   end if;
	   if p_token2 is not null  then
	      /* Obtain token 2 name and value */
	      l_colon_position := instr(p_token2,':');
	      l_token_name  := substr(p_token2,1,l_colon_position-1);
	      l_token_value := substr(p_token2,l_colon_position+1,length(p_token2));
	      fnd_message.set_token(l_token_name, l_token_value);
	      hr_utility.set_location('.  Token2: '||l_token_name||'. Value: '||l_token_value,60);
	   end if;
	   if p_token3 is not null then
	      /* Obtain token 3 name and value */
	      l_colon_position := instr(p_token3,':');
	      l_token_name  := substr(p_token3,1,l_colon_position-1);
	      l_token_value := substr(p_token3,l_colon_position+1,length(p_token3));
	      fnd_message.set_token(l_token_name, l_token_value);
	      hr_utility.set_location('.  Token3: '||l_token_name||'. Value: '||l_token_value,70);
	   end if;
	   l_message := substr(fnd_message.get,1,254);
	   hr_utility.set_location('leaving '||l_proc,100);
	   return l_message;
end get_message;



--------------------------------------------------------------------------
--                                                                      --
-- Name           : get_IANA_charset                                    --
-- Type           : Function                                            --
-- Access         : Public                                              --
-- Description    : Function to IANA charset equivalent of              --
--                  NLS_CHARACTERSET                                    --
-- Parameters     :                                                     --
--             IN : N/A                                                 --
--            OUT : N/A                                                 --
--         RETURN : VARCHAR2                                            --
--                                                                      --
--------------------------------------------------------------------------
FUNCTION get_IANA_charset RETURN VARCHAR2 IS
    CURSOR csr_get_iana_charset IS
        SELECT tag
          FROM fnd_lookup_values
         WHERE lookup_type = 'FND_ISO_CHARACTER_SET_MAP'
           AND lookup_code = SUBSTR(USERENV('LANGUAGE'),
                                    INSTR(USERENV('LANGUAGE'), '.') + 1)
           AND language = 'US';

    lv_iana_charset fnd_lookup_values.tag%type;
BEGIN
    OPEN csr_get_iana_charset;
        FETCH csr_get_iana_charset INTO lv_iana_charset;
    CLOSE csr_get_iana_charset;

    hr_utility.trace('IANA Charset = '||lv_iana_charset);
    RETURN (lv_iana_charset);
END get_IANA_charset;




END hr_se_utility ;

/
