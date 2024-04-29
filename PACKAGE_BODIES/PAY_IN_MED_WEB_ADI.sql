--------------------------------------------------------
--  DDL for Package Body PAY_IN_MED_WEB_ADI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IN_MED_WEB_ADI" AS
/* $Header: pyinmadi.pkb 120.8.12010000.2 2008/11/10 09:29:00 rsaharay ship $ */
g_package          CONSTANT VARCHAR2(100) := 'pay_in_med_web_adi.';
g_debug            BOOLEAN ;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_BG_ID                                           --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to return the business group id            --
--                                                                      --
-- Parameters     :                                                     --
--             IN :                                                     --
--         RETURN : VARCHAR2                                            --
---------------------------------------------------------------------------
FUNCTION get_bg_id
RETURN NUMBER
IS
 CURSOR  c_bg
 IS
    SELECT FND_PROFILE.VALUE('PER_BUSINESS_GROUP_ID')
    FROM   dual;
--
  l_bg          NUMBER;
  l_procedure   VARCHAR2(250);
  l_message     VARCHAR2(250);
BEGIN
   g_debug     := hr_utility.debug_enabled;
   l_procedure := g_package ||'get_bg_id';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   OPEN  c_bg;
   FETCH c_bg INTO l_bg;
   CLOSE c_bg;

   IF (g_debug)
   THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.trace('l_bg',l_bg);
        pay_in_utils.trace('**************************************************','********************');
   END IF;
   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);

   RETURN l_bg;

 END get_bg_id;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : CREATE_MEDICAL                                      --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Function to create and update the Medical Bill and  --
--                  Benefit element enrty as per the Med Bill details   --
--                  passed from the Web ADI Excel Sheet.                --
--                                                                      --
---------------------------------------------------------------------------
PROCEDURE create_medical
        (P_TAX_YEAR                     IN VARCHAR2
        ,P_MONTH                        IN VARCHAR2 DEFAULT NULL
        ,P_BILL_DATE                    IN DATE
        ,P_NAME                         IN VARCHAR2
        ,P_BILL_NUMBER                  IN VARCHAR2   DEFAULT NULL
        ,P_BILL_AMOUNT                  IN NUMBER DEFAULT NULL
        ,P_APPROVED_BILL_AMOUNT         IN NUMBER
        ,P_EMPLOYEE_REMARKS             IN VARCHAR2 DEFAULT NULL
        ,P_EMPLOYER_REMARKS             IN VARCHAR2 DEFAULT NULL
        ,P_ELEMENT_ENTRY_ID             IN NUMBER   DEFAULT NULL
        ,P_LAST_UPDATED_DATE            IN DATE     DEFAULT NULL
 	,P_ASSIGNMENT_ID                IN NUMBER
        ,P_EMPLOYEE_ID                  IN NUMBER
        ,P_EMPLOYEE_NAME                IN VARCHAR2
        ,P_ASSIGNMENT_EXTRA_INFO_ID     IN NUMBER
        ,P_ENTRY_DATE                   IN DATE   DEFAULT NULL
        )
IS

   CURSOR c_element_name(p_business_group_id NUMBER)
   IS
   SELECT  hoi.org_information1
          ,hoi.org_information2
   FROM    hr_organization_information hoi
   WHERE   hoi.organization_id = p_business_group_id
   AND     org_information_context='PER_IN_REIMBURSE_ELEMENTS';


   --Get Element Details (type id and link id)
   CURSOR csr_element_details(p_assignment_id    NUMBER
                             ,p_effective_date    DATE
			     ,p_element_name     VARCHAR2
                             )
   IS
   SELECT types.element_type_id
         ,link.element_link_id
   FROM   per_assignments_f assgn
        , pay_element_links_f link
        , pay_element_types_f types
   WHERE assgn.assignment_id  = p_assignment_id
   AND   link.element_link_id = pay_in_utils.get_element_link_id(p_assignment_id
                                                                ,P_ENTRY_DATE
                                                                ,types.element_type_id
                                                                )
   AND   (types.processing_type = 'R' OR assgn.payroll_id IS NOT NULL)
   AND   link.business_group_id = assgn.business_group_id
   AND   link.element_type_id = types.element_type_id
   AND   types.element_type_id = p_element_name
   AND   p_effective_date BETWEEN assgn.effective_start_date AND assgn.effective_end_date
   AND   p_effective_date BETWEEN link.effective_start_date  AND link.effective_end_date
   AND   p_effective_date BETWEEN types.effective_start_date AND types.effective_end_date;


   CURSOR c_input_rec(p_element_type_id         NUMBER
                     ,p_effective_date          DATE
                     )
   IS
   SELECT   inputs.name                   name
          , inputs.input_value_id         id
	  , inputs.default_value          value
   FROM     pay_element_types_f types
          , pay_input_values_f inputs
   WHERE    types.element_type_id = p_element_type_id
   AND      inputs.element_type_id = types.element_type_id
   AND      p_effective_date BETWEEN types.effective_start_date  AND types.effective_end_date
   AND      p_effective_date BETWEEN inputs.effective_start_date AND inputs.effective_end_date
   ORDER BY inputs.display_sequence;




   CURSOR c_get_ele_object_version(p_element_entryid NUMBER )
   IS
   SELECT object_version_number
          ,effective_start_date
   FROM   pay_element_entries_f
   WHERE  element_entry_id = p_element_entryid;

   CURSOR c_get_screen_value (p_element_entryid NUMBER
                             ,p_input           NUMBER )
   IS
   SELECT screen_entry_value
   FROM   pay_element_entry_values_f
   WHERE  element_entry_id = p_element_entryid
   AND    input_value_id   = p_input;


   CURSOR c_check_element_entry(p_element_type_id NUMBER
                               ,p_effective_date  DATE )
   IS
   SELECT pee.element_entry_id
   FROM   pay_element_entries_f pee
   WHERE  pee.element_type_id = p_element_type_id
   AND    pee.assignment_id = p_assignment_id
   AND    p_effective_date BETWEEN pee.effective_start_date AND pee.effective_end_date;

   CURSOR c_get_ele_type_id(p_element_entryid NUMBER)
   IS
   SELECT element_type_id
   FROM   pay_element_entries_f
   WHERE  element_entry_id = p_element_entryid;

   CURSOR c_get_prev_amts
   IS
   SELECT pae.aei_information7, pae.aei_information11
   FROM   per_assignment_extra_info pae
   WHERE  pae.assignment_extra_info_id = p_assignment_extra_info_id;

   CURSOR c_element(p_element_type_id NUMBER)
   IS
   SELECT element_name
   FROM   pay_element_types_f
   WHERE  element_type_id = p_element_type_id ;


--Variables Initialization
   TYPE t_input_values_rec IS RECORD
        (input_name      pay_input_values_f.name%TYPE
        ,input_value_id  pay_input_values_f.input_value_id%TYPE
        ,value           pay_input_values_f.default_value%TYPE
        );

   TYPE t_input_values_tab IS TABLE OF t_input_values_rec INDEX BY BINARY_INTEGER;

   l_procedure                  VARCHAR2(250);
   l_message                    VARCHAR2(250);
   l_warnings                   BOOLEAN;
   l_input_values_rec           t_input_values_tab;
   l_ben_input_values_rec       t_input_values_tab;
   l_business_group_id          NUMBER;
   l_medical_bill_element       hr_organization_information.org_information2%TYPE ;
   l_medical_ben_element        hr_organization_information.org_information2%TYPE ;
   l_element                    pay_element_types.element_name%TYPE ;
   l_count                      NUMBER;
   l_assignment_id              NUMBER;
   l_bill_element_type_id       NUMBER;
   l_bill_element_link_id       NUMBER;
   l_ben_element_type_id        NUMBER;
   l_ben_element_link_id        NUMBER;
   l_element_entry_id           NUMBER := NULL ;
   l_bill_entry_id              NUMBER := NULL ;
   l_ben_entry_id               NUMBER := NULL ;
   l_start_date                 DATE ;
   l_end_date                   DATE ;
   l_effective_start_date       DATE ;
   l_ben_start_date             DATE ;
   l_object_version_no          per_assignment_extra_info.object_version_number%TYPE ;
   l_ben_version_no             per_assignment_extra_info.object_version_number%TYPE ;
   l_entry_information1         pay_element_entries_f.entry_information2%TYPE ;
   l_entry_information3         pay_element_entries_f.entry_information2%TYPE ;
   l_entry_information5         pay_element_entries_f.entry_information2%TYPE ;
   l_entry_information7         pay_element_entries_f.entry_information2%TYPE ;
   l_check                      NUMBER :=0;
   l_approved_bill_amount       NUMBER ;
   l_prev_bill_amount           NUMBER ;




BEGIN

--hr_utility.trace_on(null,'LNAGARAJ');
     g_debug     := hr_utility.debug_enabled;
     l_procedure := g_package ||'create_medical';
     pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
     IF (g_debug)
     THEN
          pay_in_utils.trace('**************************************************','********************');
          pay_in_utils.set_location(g_debug,'Input Paramters values are',20);
          pay_in_utils.trace('p_tax_year',TO_CHAR (p_tax_year));
          pay_in_utils.trace('p_month',TO_CHAR (p_month));
          pay_in_utils.trace('p_bill_date',TO_CHAR (p_bill_date));
          pay_in_utils.trace('p_name',TO_CHAR (p_name));
          pay_in_utils.trace('p_bill_number',TO_CHAR (p_bill_number));
          pay_in_utils.trace('p_bill_amount',TO_CHAR (p_bill_amount));
          pay_in_utils.trace('p_approved_bill_amount',TO_CHAR (p_approved_bill_amount));
          pay_in_utils.trace('p_employee_remarks',TO_CHAR (p_employee_remarks));
          pay_in_utils.trace('p_employer_remarks',TO_CHAR (p_employer_remarks));
          pay_in_utils.trace('p_element_entry_id',TO_CHAR (p_element_entry_id));
          pay_in_utils.trace('p_last_updated_date',TO_CHAR (p_last_updated_date));
          pay_in_utils.trace('p_assignment_id',TO_CHAR (p_assignment_id));
          pay_in_utils.trace('p_employee_id',TO_CHAR (p_employee_id));
          pay_in_utils.trace('p_employee_name',TO_CHAR (p_employee_name));
          pay_in_utils.trace('p_assignment_extra_info_id',TO_CHAR (p_assignment_extra_info_id));
          pay_in_utils.trace('p_entry_date',TO_CHAR(p_entry_date));


     END IF;

     IF P_BILL_AMOUNT < 0 THEN
         hr_utility.set_message(800, 'PER_IN_BEN_AMOUNT');
 	 hr_utility.raise_error;
     END IF ;

     IF P_APPROVED_BILL_AMOUNT < 0 THEN
         hr_utility.set_message(800, 'PER_IN_BEN_APPROVED_AMOUNT');
 	 hr_utility.raise_error;
     END IF ;


     l_business_group_id :=  get_bg_id();

     IF (g_debug)
     THEN
          pay_in_utils.trace('l_business_group_id',TO_CHAR (l_business_group_id));
     END IF;

    IF ((p_element_entry_id IS NOT NULL))
    THEN

        pay_in_utils.set_location(g_debug,'Updating Element Entries: '||l_procedure,30);

	/*Code to change the Medical Bill Entry if the approved amount of a existing medical
	  bill has been changed.*/

	l_element_entry_id := p_element_entry_id;

        OPEN c_get_ele_object_version(p_element_entry_id) ;
        FETCH c_get_ele_object_version INTO l_object_version_no,l_effective_start_date ;
        CLOSE c_get_ele_object_version ;

	OPEN c_get_ele_type_id(p_element_entry_id);
	FETCH c_get_ele_type_id INTO l_bill_element_type_id ;
	CLOSE c_get_ele_type_id ;

	OPEN  c_get_prev_amts ;
	FETCH c_get_prev_amts INTO l_prev_bill_amount,l_ben_entry_id ;
	CLOSE c_get_prev_amts ;



	l_count := 1;
        FOR c_rec IN c_input_rec(l_bill_element_type_id,l_effective_start_date)
        LOOP
                l_input_values_rec(l_count).input_name     := c_rec.name;
                l_input_values_rec(l_count).input_value_id := c_rec.id;
                l_input_values_rec(l_count).value          := c_rec.value;

		IF (g_debug)
                THEN
			  pay_in_utils.trace('Input Value Name:'||l_count,TO_CHAR (c_rec.name));
			  pay_in_utils.trace('l_input_values_rec(1).input_value_id',TO_CHAR (l_input_values_rec(1).input_value_id));
		 END IF;

		l_count := l_count + 1;
        END LOOP;




        OPEN c_get_screen_value(P_ELEMENT_ENTRY_ID, l_input_values_rec(1).input_value_id);
	FETCH c_get_screen_value INTO l_entry_information1 ;
	CLOSE c_get_screen_value ;

	IF (g_debug)
        THEN
	   pay_in_utils.trace('l_entry_information1',TO_CHAR (l_entry_information1));
	END IF;



	IF (g_debug)
        THEN
	   pay_in_utils.trace('l_prev_bill_amount',TO_CHAR (l_prev_bill_amount));
	END IF;



        l_approved_bill_amount := NVL(p_approved_bill_amount,0) + NVL(l_entry_information1,0) - NVL(l_prev_bill_amount,0);
        l_approved_bill_amount := greatest(l_approved_bill_amount,0);

        pay_element_entry_api.update_element_entry
                 (p_datetrack_update_mode    => hr_api.g_correction
                 ,p_effective_date           => l_effective_start_date
                 ,p_business_group_id        => l_business_group_id
                 ,p_element_entry_id         => p_element_entry_id
                 ,p_object_version_number    => l_object_version_no
                 ,p_input_value_id1          => l_input_values_rec(1).input_value_id
                 ,p_input_value_id2          => l_input_values_rec(2).input_value_id
                 ,p_entry_value1             => l_approved_bill_amount
                 ,p_entry_value2             => l_input_values_rec(2).value
                 ,p_effective_start_date     => l_start_date
                 ,p_effective_end_date       => l_end_date
                 ,p_update_warning           => l_warnings
                 );


	l_object_version_no := NULL ;

      /*Code to change the Medical Benefit Entry if the approved
        amount of an existing bill has been modified.*/
      IF l_ben_entry_id IS NOT NULL
      THEN

        OPEN c_get_ele_type_id(l_ben_entry_id);
	FETCH c_get_ele_type_id INTO l_ben_element_type_id ;
	CLOSE c_get_ele_type_id ;

	OPEN c_get_ele_object_version(l_ben_entry_id) ;
        FETCH c_get_ele_object_version INTO l_ben_version_no,l_ben_start_date ;
        CLOSE c_get_ele_object_version ;


	l_count := 1;
        FOR c_rec IN c_input_rec(l_ben_element_type_id,l_ben_start_date)
        LOOP
                l_ben_input_values_rec(l_count).input_name     := c_rec.name;
                l_ben_input_values_rec(l_count).input_value_id := c_rec.id;
                l_ben_input_values_rec(l_count).value          := c_rec.value;

		IF (g_debug)
                THEN
			  pay_in_utils.trace('Benefit Input Value Name:'||l_count,TO_CHAR (c_rec.name));
		 END IF;

		l_count := l_count + 1;
         END LOOP;


	OPEN c_get_screen_value(l_ben_entry_id, l_ben_input_values_rec(3).input_value_id);
	FETCH c_get_screen_value INTO l_entry_information3 ;
	CLOSE c_get_screen_value ;

	OPEN c_get_screen_value(l_ben_entry_id, l_ben_input_values_rec(5).input_value_id);
	FETCH c_get_screen_value INTO l_entry_information5 ;
	CLOSE c_get_screen_value ;

	OPEN c_get_screen_value(l_ben_entry_id, l_ben_input_values_rec(7).input_value_id);
	FETCH c_get_screen_value INTO l_entry_information7 ;
	CLOSE c_get_screen_value ;

	IF (g_debug)
        THEN
	   pay_in_utils.trace('l_entry_information3',TO_CHAR (l_entry_information3));
	   pay_in_utils.trace('l_entry_information5',TO_CHAR (l_entry_information5));
	   pay_in_utils.trace('l_entry_information7',TO_CHAR (l_entry_information7));
	END IF;


       l_approved_bill_amount := NVL(p_approved_bill_amount,0) + NVL(l_entry_information3,0) - NVL(l_prev_bill_amount,0);
       l_approved_bill_amount := GREATEST (l_approved_bill_amount,0);


        pay_element_entry_api.update_element_entry
                 (p_datetrack_update_mode    => hr_api.g_correction
                 ,p_effective_date           => l_ben_start_date
                 ,p_business_group_id        => l_business_group_id
                 ,p_element_entry_id         => l_ben_entry_id
                 ,p_object_version_number    => l_ben_version_no
                 ,p_input_value_id1          => l_ben_input_values_rec(1).input_value_id
                 ,p_input_value_id2          => l_ben_input_values_rec(2).input_value_id
                 ,p_input_value_id3          => l_ben_input_values_rec(3).input_value_id
                 ,p_input_value_id4          => l_ben_input_values_rec(4).input_value_id
                 ,p_input_value_id5          => l_ben_input_values_rec(5).input_value_id
                 ,p_input_value_id6          => l_ben_input_values_rec(6).input_value_id
                 ,p_input_value_id7          => l_ben_input_values_rec(7).input_value_id
                 ,p_input_value_id8          => l_ben_input_values_rec(8).input_value_id
                 ,p_input_value_id9          => l_ben_input_values_rec(9).input_value_id
                 ,p_entry_value1             => l_ben_input_values_rec(1).value
                 ,p_entry_value2             => l_ben_input_values_rec(2).value
                 ,p_entry_value3             => l_approved_bill_amount
                 ,p_entry_value4             => l_ben_input_values_rec(4).value
                 ,p_entry_value5             => l_entry_information5
                 ,p_entry_value6             => l_ben_input_values_rec(6).value
                 ,p_entry_value7             => l_entry_information7
                 ,p_entry_value8             => l_ben_input_values_rec(8).value
                 ,p_entry_value9             => l_ben_input_values_rec(9).value
		 ,p_effective_start_date     => l_start_date
                 ,p_effective_end_date       => l_end_date
                 ,p_update_warning           => l_warnings
                 );


	l_ben_version_no := NULL ;

      END IF ;
    ELSIF ((p_element_entry_id IS NULL) )
    THEN


     OPEN  c_element_name(l_business_group_id);
     FETCH c_element_name INTO l_medical_bill_element, l_medical_ben_element ;
     CLOSE c_element_name ;

     IF (g_debug)
     THEN
          pay_in_utils.trace('l_medical_bill_element',TO_CHAR (l_medical_bill_element));
          pay_in_utils.trace('l_medical_ben_element ',TO_CHAR (l_medical_ben_element));
     END IF;

     OPEN csr_element_details(p_assignment_id, P_ENTRY_DATE, l_medical_bill_element) ;
     FETCH csr_element_details INTO l_bill_element_type_id, l_bill_element_link_id ;
     CLOSE csr_element_details ;

     OPEN csr_element_details(p_assignment_id, P_ENTRY_DATE, l_medical_ben_element) ;
     FETCH csr_element_details INTO l_ben_element_type_id, l_ben_element_link_id ;
     CLOSE csr_element_details ;


      IF (g_debug)
        THEN
             pay_in_utils.trace('l_bill_element_type_id',TO_CHAR (l_bill_element_type_id));
             pay_in_utils.trace('l_bill_element_link_id',TO_CHAR (l_bill_element_link_id));
             pay_in_utils.trace('l_ben_element_type_id ',TO_CHAR (l_ben_element_type_id));
             pay_in_utils.trace('l_ben_element_link_id ',TO_CHAR (l_ben_element_link_id));
      END IF;

     OPEN c_check_element_entry(l_bill_element_type_id, P_ENTRY_DATE);
     FETCH c_check_element_entry INTO l_element_entry_id ;
     CLOSE c_check_element_entry ;

     IF l_element_entry_id IS NOT NULL THEN

        pay_in_utils.set_location(g_debug,'Updating Element Entries: '||l_procedure,40);

        /*Code to change the Medical Bill Entry if an additional bill has been approved.*/
        OPEN c_get_ele_object_version(l_element_entry_id) ;
        FETCH c_get_ele_object_version INTO l_object_version_no,l_effective_start_date ;
        CLOSE c_get_ele_object_version ;


	l_count := 1;
        FOR c_rec IN c_input_rec(l_bill_element_type_id,l_effective_start_date)
        LOOP
                l_input_values_rec(l_count).input_name     := c_rec.name;
                l_input_values_rec(l_count).input_value_id := c_rec.id;
                l_input_values_rec(l_count).value          := c_rec.value;

		IF (g_debug)
                THEN
			  pay_in_utils.trace('Bill'||l_count,TO_CHAR (c_rec.name));
		 END IF;

		l_count := l_count + 1;
        END LOOP;



        OPEN c_get_screen_value(l_element_entry_id, l_input_values_rec(1).input_value_id);
	FETCH c_get_screen_value INTO l_entry_information1 ;
	CLOSE c_get_screen_value ;

	IF (g_debug)
        THEN
	   pay_in_utils.trace('l_entry_information1',TO_CHAR (l_entry_information1));
	END IF;


       l_approved_bill_amount := NVL(p_approved_bill_amount,0) + NVL(l_entry_information1,0) ;
       l_approved_bill_amount := GREATEST (l_approved_bill_amount,0);

        pay_element_entry_api.update_element_entry
                 (p_datetrack_update_mode    => hr_api.g_correction
                 ,p_effective_date           => l_effective_start_date
                 ,p_business_group_id        => l_business_group_id
                 ,p_element_entry_id         => l_element_entry_id
                 ,p_object_version_number    => l_object_version_no
                 ,p_input_value_id1          => l_input_values_rec(1).input_value_id
                 ,p_input_value_id2          => l_input_values_rec(2).input_value_id
                 ,p_entry_value1             => l_approved_bill_amount
                 ,p_entry_value2             => l_input_values_rec(2).value
                 ,p_effective_start_date     => l_start_date
                 ,p_effective_end_date       => l_end_date
                 ,p_update_warning           => l_warnings
                 );


	l_object_version_no := NULL ;


        /*Code to change the Medical Benefit Entry if an additional bill has been approved.*/
	OPEN c_check_element_entry(l_ben_element_type_id, P_ENTRY_DATE);
        FETCH c_check_element_entry INTO l_ben_entry_id ;
        CLOSE c_check_element_entry ;

	IF l_ben_entry_id IS NOT NULL
	THEN

        OPEN c_get_ele_object_version(l_ben_entry_id) ;
        FETCH c_get_ele_object_version INTO l_ben_version_no,l_ben_start_date ;
        CLOSE c_get_ele_object_version ;

        l_count := 1;
        FOR c_rec IN c_input_rec(l_ben_element_type_id,l_ben_start_date)
        LOOP
                l_ben_input_values_rec(l_count).input_name     := c_rec.name;
                l_ben_input_values_rec(l_count).input_value_id := c_rec.id;
                l_ben_input_values_rec(l_count).value          := c_rec.value;

		IF (g_debug)
                THEN
			  pay_in_utils.trace('Benefit Input Value Name:'||l_count,TO_CHAR (c_rec.name));
		 END IF;

		l_count := l_count + 1;
         END LOOP;


	OPEN c_get_screen_value(l_ben_entry_id, l_ben_input_values_rec(3).input_value_id);
	FETCH c_get_screen_value INTO l_entry_information3 ;
	CLOSE c_get_screen_value ;

	OPEN c_get_screen_value(l_ben_entry_id, l_ben_input_values_rec(5).input_value_id);
	FETCH c_get_screen_value INTO l_entry_information5 ;
	CLOSE c_get_screen_value ;

	OPEN c_get_screen_value(l_ben_entry_id, l_ben_input_values_rec(7).input_value_id);
	FETCH c_get_screen_value INTO l_entry_information7 ;
	CLOSE c_get_screen_value ;


	IF (g_debug)
        THEN
	   pay_in_utils.trace('l_entry_information3',TO_CHAR (l_entry_information3));
	   pay_in_utils.trace('l_entry_information5',TO_CHAR (l_entry_information5));
	   pay_in_utils.trace('l_entry_information7',TO_CHAR (l_entry_information7));
	END IF;


       l_approved_bill_amount := NVL(p_approved_bill_amount,0) + NVL(l_entry_information3,0) ;
       l_approved_bill_amount := GREATEST (l_approved_bill_amount,0);

        pay_element_entry_api.update_element_entry
                 (p_datetrack_update_mode    => hr_api.g_correction
                 ,p_effective_date           => l_ben_start_date
                 ,p_business_group_id        => l_business_group_id
                 ,p_element_entry_id         => l_ben_entry_id
                 ,p_object_version_number    => l_ben_version_no
                 ,p_input_value_id1          => l_ben_input_values_rec(1).input_value_id
                 ,p_input_value_id2          => l_ben_input_values_rec(2).input_value_id
                 ,p_input_value_id3          => l_ben_input_values_rec(3).input_value_id
                 ,p_input_value_id4          => l_ben_input_values_rec(4).input_value_id
                 ,p_input_value_id5          => l_ben_input_values_rec(5).input_value_id
                 ,p_input_value_id6          => l_ben_input_values_rec(6).input_value_id
                 ,p_input_value_id7          => l_ben_input_values_rec(7).input_value_id
                 ,p_input_value_id8          => l_ben_input_values_rec(8).input_value_id
                 ,p_input_value_id9          => l_ben_input_values_rec(9).input_value_id
                 ,p_entry_value1             => l_ben_input_values_rec(1).value
                 ,p_entry_value2             => l_ben_input_values_rec(2).value
                 ,p_entry_value3             => l_approved_bill_amount
                 ,p_entry_value4             => l_ben_input_values_rec(4).value
                 ,p_entry_value5             => l_entry_information5
                 ,p_entry_value6             => l_ben_input_values_rec(6).value
                 ,p_entry_value7             => l_entry_information7
                 ,p_entry_value8             => l_ben_input_values_rec(8).value
                 ,p_entry_value9             => l_ben_input_values_rec(9).value
		 ,p_effective_start_date     => l_start_date
                 ,p_effective_end_date       => l_end_date
                 ,p_update_warning           => l_warnings
                 );


	l_ben_version_no := NULL ;

        END IF ;



     ELSE

      IF l_bill_element_link_id IS NULL THEN

         OPEN  c_element(TO_NUMBER(l_medical_bill_element));
	 FETCH c_element INTO l_element;
         CLOSE c_element;

         hr_utility.set_message(800, 'PER_IN_MISSING_LINK');
         hr_utility.set_message_token('ELEMENT_NAME', l_element);
         hr_utility.raise_error;
       END IF;

       IF l_ben_element_link_id IS NULL THEN

         OPEN  c_element(TO_NUMBER(l_medical_ben_element));
	 FETCH c_element INTO l_element;
         CLOSE c_element;

         hr_utility.set_message(800, 'PER_IN_MISSING_LINK');
         hr_utility.set_message_token('ELEMENT_NAME', l_element);
	 hr_utility.raise_error;
       END IF;

       --Populate the input value id, name records
      l_count := 1;
      FOR c_rec IN c_input_rec(l_bill_element_type_id,P_ENTRY_DATE)
      LOOP
                l_input_values_rec(l_count).input_name     := c_rec.name;
                l_input_values_rec(l_count).input_value_id := c_rec.id;
                l_input_values_rec(l_count).value          := c_rec.value;

		IF (g_debug)
                THEN
			  pay_in_utils.trace('Bill Input Value Name:'||l_count,TO_CHAR (c_rec.name));
		 END IF;

		l_count := l_count + 1;
      END LOOP;

      l_count := 1;
      FOR c_rec IN c_input_rec(l_ben_element_type_id,P_ENTRY_DATE)
      LOOP
                l_ben_input_values_rec(l_count).input_name     := c_rec.name;
                l_ben_input_values_rec(l_count).input_value_id := c_rec.id;
                l_ben_input_values_rec(l_count).value          := c_rec.value;

		IF (g_debug)
                THEN
			  pay_in_utils.trace('Benefit Input Value Name:'||l_count,TO_CHAR (c_rec.name));
		 END IF;

		l_count := l_count + 1;
      END LOOP;






            pay_in_utils.set_location(g_debug,'Creating Benefit Element Entries: '||l_procedure,50);

          IF(p_approved_bill_amount IS NOT NULL) THEN
	     pay_element_entry_api.create_element_entry
                 (p_effective_date        => p_entry_date
                 ,p_business_group_id     => l_business_group_id
                 ,p_assignment_id         => p_assignment_id
                 ,p_element_link_id       => l_ben_element_link_id
                 ,p_entry_type            => 'E'
                 ,p_input_value_id1       => l_ben_input_values_rec(1).input_value_id
                 ,p_input_value_id2       => l_ben_input_values_rec(2).input_value_id
                 ,p_input_value_id3       => l_ben_input_values_rec(3).input_value_id
                 ,p_input_value_id4       => l_ben_input_values_rec(4).input_value_id
                 ,p_input_value_id5       => l_ben_input_values_rec(5).input_value_id
                 ,p_input_value_id6       => l_ben_input_values_rec(6).input_value_id
                 ,p_input_value_id7       => l_ben_input_values_rec(7).input_value_id
                 ,p_input_value_id8       => l_ben_input_values_rec(8).input_value_id
                 ,p_input_value_id9       => l_ben_input_values_rec(9).input_value_id
                 ,p_entry_value1          => l_ben_input_values_rec(1).value
                 ,p_entry_value2          => l_ben_input_values_rec(2).value
                 ,p_entry_value3          => p_approved_bill_amount
                 ,p_entry_value4          => l_ben_input_values_rec(4).value
                 ,p_entry_value5          => l_ben_input_values_rec(5).value
                 ,p_entry_value6          => l_ben_input_values_rec(6).value
                 ,p_entry_value7          => l_ben_input_values_rec(7).value
                 ,p_entry_value8          => l_ben_input_values_rec(8).value
                 ,p_entry_value9          => l_ben_input_values_rec(9).value
                 ,p_effective_start_date  => l_start_date
                 ,p_effective_end_date    => l_end_date
                 ,p_element_entry_id      => l_ben_entry_id
                 ,p_object_version_number => l_object_version_no
                 ,p_create_warning        => l_warnings
                 );
           END IF;
	 pay_in_utils.set_location(g_debug,'Benefit Element Creation Completed'||l_procedure,60);


         pay_in_utils.set_location(g_debug,'Creating Benefit Bill Element Entries: '||l_procedure,70);

	     IF(p_approved_bill_amount IS NOT NULL) THEN
	       pay_element_entry_api.create_element_entry
                 (p_effective_date        => p_entry_date
                 ,p_business_group_id     => l_business_group_id
                 ,p_assignment_id         => p_assignment_id
                 ,p_element_link_id       => l_bill_element_link_id
                 ,p_entry_type            => 'E'
                 ,p_input_value_id1       => l_input_values_rec(1).input_value_id
                 ,p_input_value_id2       => l_input_values_rec(2).input_value_id
                 ,p_entry_value1          => p_approved_bill_amount
                 ,p_entry_value2          => l_input_values_rec(2).value
                 ,p_effective_start_date  => l_start_date
                 ,p_effective_end_date    => l_end_date
                 ,p_element_entry_id      => l_bill_entry_id
                 ,p_object_version_number => l_object_version_no
                 ,p_create_warning        => l_warnings
                 );
            END IF;

	 pay_in_utils.set_location(g_debug,'Benefit Bill Element Creation Completed'||l_procedure,80);

     END IF ;
    END IF;


        pay_in_utils.set_location(g_debug,'Updating Assignment_Extra_Info: '||l_procedure,90);




    UPDATE per_assignment_extra_info
    SET    AEI_INFORMATION7      = p_approved_bill_amount
          ,AEI_INFORMATION9      = p_employer_remarks
          ,AEI_INFORMATION10     = nvl(l_bill_entry_id,l_element_entry_id)
          ,AEI_INFORMATION11     = l_ben_entry_id
    WHERE  ASSIGNMENT_EXTRA_INFO_ID = p_assignment_extra_info_id ;


    pay_in_utils.trace('**************************************************','********************');
    pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,100);
END create_medical;


--------------------------------------------------------------------------
--                                                                      --
-- Name           : CREATE_MEDICAL_BEN                                  --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Function to update the Med Ben element enrty as per --
--                  the details passed from the Web ADI Excel Sheet.    --
--                                                                      --
---------------------------------------------------------------------------

PROCEDURE create_medical_ben
( P_employee_number		        IN VARCHAR2
,P_full_name			        IN VARCHAR2
,P_effective_start_date		        IN DATE
,P_effective_end_date		        IN DATE   DEFAULT NULL
,P_Benefit			        IN NUMBER
,P_Add_to_NetPay           		IN VARCHAR2
,P_AnnualLimit                          IN NUMBER  DEFAULT NULL
,P_assignment_id			IN NUMBER
,P_element_entry_id		        IN NUMBER DEFAULT NULL
)

IS

   CURSOR c_input_rec(p_element_type_id         NUMBER
                     ,p_effective_date          DATE
                     )
   IS
   SELECT   inputs.name                   name
          , inputs.input_value_id         id
	  , inputs.default_value          value
   FROM     pay_element_types_f types
          , pay_input_values_f inputs
   WHERE    types.element_type_id = p_element_type_id
   AND      inputs.element_type_id = types.element_type_id
   AND      p_effective_date BETWEEN types.effective_start_date  AND types.effective_end_date
   AND      p_effective_date BETWEEN inputs.effective_start_date AND inputs.effective_end_date
   ORDER BY inputs.display_sequence;



   CURSOR c_get_ele_object_version(p_element_entryid NUMBER )
   IS
   SELECT object_version_number
   FROM   pay_element_entries_f
   WHERE  element_entry_id = p_element_entryid;


   CURSOR c_get_ele_type_id(p_element_entryid NUMBER)
   IS
   SELECT element_type_id
   FROM   pay_element_entries_f
   WHERE  element_entry_id = p_element_entryid;


--Variables Initialization
   TYPE t_input_values_rec IS RECORD
        (input_name      pay_input_values_f.name%TYPE
        ,input_value_id  pay_input_values_f.input_value_id%TYPE
        ,value           pay_input_values_f.default_value%TYPE
        );

   TYPE t_input_values_tab IS TABLE OF t_input_values_rec INDEX BY BINARY_INTEGER;

   l_procedure                  VARCHAR2(250);
   l_warnings                   BOOLEAN;
   l_input_values_rec           t_input_values_tab;
   l_business_group_id          NUMBER;
   l_count                      NUMBER;
   l_element_type_id            NUMBER;
   l_start_date                 DATE ;
   l_end_date                   DATE ;
   l_object_version_no          per_assignment_extra_info.object_version_number%TYPE ;



BEGIN


     g_debug     := hr_utility.debug_enabled;
     l_procedure := g_package ||'create_medical_ben';
     pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
     IF (g_debug)
     THEN
          pay_in_utils.trace('**************************************************','********************');
          pay_in_utils.set_location(g_debug,'Input Paramters value is',20);
          pay_in_utils.trace('P_employee_number',TO_CHAR (P_employee_number));
          pay_in_utils.trace('P_full_name',TO_CHAR (P_full_name));
          pay_in_utils.trace('P_effective_start_date',TO_CHAR (P_effective_start_date));
          pay_in_utils.trace('P_effective_end_date',TO_CHAR (P_effective_end_date));
          pay_in_utils.trace('P_Benefit',TO_CHAR (P_Benefit));
          pay_in_utils.trace('P_Add_to_NetPay',TO_CHAR (P_Add_to_NetPay));
          pay_in_utils.trace('P_AnnualLimit',TO_CHAR (P_AnnualLimit));
          pay_in_utils.trace('P_assignment_id',TO_CHAR (P_assignment_id));
          pay_in_utils.trace('P_element_entry_id',TO_CHAR (P_element_entry_id));


     END IF;

     IF P_Benefit < 0 THEN
         hr_utility.set_message(800, 'PER_IN_BEN_APPROVED_AMOUNT');
 	 hr_utility.raise_error;
     END IF ;



     l_business_group_id :=  get_bg_id();

     IF (g_debug)
     THEN
          pay_in_utils.trace('Business Group:',TO_CHAR (l_business_group_id));
     END IF;


IF ((p_element_entry_id IS NOT NULL))
    THEN

        pay_in_utils.set_location(g_debug,'Updating Element Entries: '||l_procedure,30);

        OPEN c_get_ele_object_version(p_element_entry_id) ;
        FETCH c_get_ele_object_version INTO l_object_version_no ;
        CLOSE c_get_ele_object_version ;

	OPEN c_get_ele_type_id(p_element_entry_id);
	FETCH c_get_ele_type_id INTO l_element_type_id ;
	CLOSE c_get_ele_type_id ;

	l_count := 1;
        FOR c_rec IN c_input_rec(l_element_type_id,P_effective_start_date)
        LOOP
                l_input_values_rec(l_count).input_name     := c_rec.name;
                l_input_values_rec(l_count).input_value_id := c_rec.id;
                l_input_values_rec(l_count).value          := c_rec.value;

		IF (g_debug)
                THEN
			  pay_in_utils.trace('Input Value Name'||l_count,TO_CHAR (c_rec.name));
		 END IF;

		l_count := l_count + 1;
        END LOOP;



        pay_element_entry_api.update_element_entry
                 (p_datetrack_update_mode    => hr_api.g_correction
                 ,p_effective_date           => P_effective_start_date
                 ,p_business_group_id        => l_business_group_id
                 ,p_element_entry_id         => p_element_entry_id
                 ,p_object_version_number    => l_object_version_no
                 ,p_input_value_id1          => l_input_values_rec(1).input_value_id
                 ,p_input_value_id2          => l_input_values_rec(2).input_value_id
                 ,p_input_value_id3          => l_input_values_rec(3).input_value_id
                 ,p_input_value_id4          => l_input_values_rec(4).input_value_id
                 ,p_input_value_id5          => l_input_values_rec(5).input_value_id
                 ,p_input_value_id6          => l_input_values_rec(6).input_value_id
                 ,p_input_value_id7          => l_input_values_rec(7).input_value_id
                 ,p_input_value_id8          => l_input_values_rec(8).input_value_id
                 ,p_input_value_id9          => l_input_values_rec(9).input_value_id
                 ,p_entry_value1             => l_input_values_rec(1).value
                 ,p_entry_value2             => l_input_values_rec(2).value
                 ,p_entry_value3             => P_Benefit
                 ,p_entry_value4             => l_input_values_rec(4).value
                 ,p_entry_value5             => P_AnnualLimit
                 ,p_entry_value6             => l_input_values_rec(6).value
                 ,p_entry_value7             => P_Add_to_NetPay
                 ,p_entry_value8             => l_input_values_rec(8).value
                 ,p_entry_value9             => l_input_values_rec(9).value
                 ,p_effective_start_date     => l_start_date
                 ,p_effective_end_date       => l_end_date
                 ,p_update_warning           => l_warnings
                 );



END IF ;


    pay_in_utils.trace('**************************************************','********************');
    pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);




END create_medical_ben;


--------------------------------------------------------------------------
--                                                                      --
-- Name           : CREATE_LTC_ELEMENT                                  --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Function to create and update the LTC element enrty --
--                  as per the LTC Bill details passed from the Web ADI --
--		    Excel Sheet.                                        --
--                                                                      --
---------------------------------------------------------------------------

PROCEDURE create_ltc_element
(
 P_LTCBLOCK                     IN VARCHAR2
,P_PLACE_FROM                   IN VARCHAR2
,P_PLACE_TO                     IN VARCHAR2
,P_MODE_CLASS                   IN VARCHAR2
,P_CARRY_OVER                   IN VARCHAR2 DEFAULT NULL
,P_SUBMITTED                    IN NUMBER
,P_EXEMPTED                     IN NUMBER   DEFAULT NULL
,P_ELEMENT_ENTRY_ID             IN NUMBER
,P_START_DATE                   IN DATE
,P_END_DATE                     IN DATE
,P_BILL_NUM                     IN VARCHAR2 DEFAULT NULL
,P_EE_COMMENTS                  IN VARCHAR2 DEFAULT NULL
,P_ER_COMMENTS                  IN VARCHAR2 DEFAULT NULL
,P_LAST_UPDATED_DATE            IN DATE
,P_ASSIGNMENT_ID                IN NUMBER
,P_EMPLOYEE_ID                  IN NUMBER
,P_ASSIGNMENT_EXTRA_INFO_ID     IN NUMBER
,P_ENTRY_DATE                   IN DATE   DEFAULT NULL
)
IS
   CURSOR c_element_name(p_business_group_id NUMBER)
   IS
   SELECT  hoi.org_information3
   FROM    hr_organization_information hoi
   WHERE   hoi.organization_id = p_business_group_id
   AND     org_information_context='PER_IN_REIMBURSE_ELEMENTS';



   --Get Element Details (type id and link id)
   CURSOR csr_element_details(p_assignment_id    NUMBER
                             ,p_effective_date    DATE
			     ,p_element_name     VARCHAR2
                             )
   IS
   SELECT types.element_type_id
         ,link.element_link_id
   FROM   per_assignments_f assgn
        , pay_element_links_f link
        , pay_element_types_f types
   WHERE assgn.assignment_id  = p_assignment_id
   AND   link.element_link_id = pay_in_utils.get_element_link_id(p_assignment_id
                                                                ,P_ENTRY_DATE
                                                                ,types.element_type_id
                                                                )
   AND   (types.processing_type = 'R' OR assgn.payroll_id IS NOT NULL)
   AND   link.business_group_id = assgn.business_group_id
   AND   link.element_type_id = types.element_type_id
   AND   types.element_type_id = p_element_name
   AND   p_effective_date BETWEEN assgn.effective_start_date AND assgn.effective_end_date
   AND   p_effective_date BETWEEN link.effective_start_date  AND link.effective_end_date
   AND   p_effective_date BETWEEN types.effective_start_date AND types.effective_end_date;


   CURSOR c_input_rec(p_element_type_id         NUMBER
                     ,p_effective_date          DATE
                     )
   IS
   SELECT   inputs.name                   name
          , inputs.input_value_id         id
	  , inputs.default_value          value
   FROM     pay_element_types_f types
          , pay_input_values_f inputs
   WHERE    types.element_type_id = p_element_type_id
   AND      inputs.element_type_id = types.element_type_id
   AND      p_effective_date BETWEEN types.effective_start_date  AND types.effective_end_date
   AND      p_effective_date BETWEEN inputs.effective_start_date AND inputs.effective_end_date
   ORDER BY inputs.display_sequence;




   CURSOR c_get_ele_object_version(p_element_entryid NUMBER )
   IS
   SELECT object_version_number
          ,effective_start_date
   FROM   pay_element_entries_f
   WHERE  element_entry_id = p_element_entryid;

   CURSOR c_get_screen_value (p_element_entryid NUMBER
                             ,p_input           NUMBER )
   IS
   SELECT screen_entry_value
   FROM   pay_element_entry_values_f
   WHERE  element_entry_id = p_element_entryid
   AND    input_value_id   = p_input;


   CURSOR c_check_element_entry(p_element_type_id NUMBER
                               ,p_effective_date  DATE )
   IS
   SELECT pee.element_entry_id
   FROM   pay_element_entries_f pee
   WHERE  pee.element_type_id = p_element_type_id
   AND    pee.assignment_id = p_assignment_id
   AND    TO_CHAR(p_effective_date,'RRRR') = TO_CHAR(pee.effective_start_date,'RRRR') ;

   CURSOR c_get_ele_type_id(p_element_entryid NUMBER)
   IS
   SELECT element_type_id
   FROM   pay_element_entries_f
   WHERE  element_entry_id = p_element_entryid;

   CURSOR c_get_prev_amts
   IS
   SELECT pae.aei_information9,
          pae.aei_information10
   FROM   per_assignment_extra_info pae
   WHERE  pae.assignment_extra_info_id = p_assignment_extra_info_id;

   CURSOR c_element(p_element_type_id NUMBER)
   IS
   SELECT element_name
   FROM   pay_element_types_f
   WHERE  element_type_id = p_element_type_id ;

--Variables Initialization
   TYPE t_input_values_rec IS RECORD
        (input_name      pay_input_values_f.name%TYPE
        ,input_value_id  pay_input_values_f.input_value_id%TYPE
        ,value           pay_input_values_f.default_value%TYPE
        );

   TYPE t_input_values_tab IS TABLE OF t_input_values_rec INDEX BY BINARY_INTEGER;

   l_procedure                  VARCHAR2(250);
   l_message                    VARCHAR2(250);
   l_warnings                   BOOLEAN;
   l_input_values_rec           t_input_values_tab;
   l_ben_input_values_rec       t_input_values_tab;
   l_business_group_id          NUMBER;
   l_medical_bill_element       hr_organization_information.org_information2%TYPE ;
   l_ltc_element                hr_organization_information.org_information2%TYPE ;
   l_element                    pay_element_types.element_name%TYPE ;
   l_count                      NUMBER;
   l_assignment_id              NUMBER;
   l_ltc_element_type_id        NUMBER;
   l_bill_element_link_id       NUMBER;
   l_ltc_element_link_id        NUMBER;
   l_element_entry_id           NUMBER := NULL ;
   l_start_date                 DATE ;
   l_end_date                   DATE ;
   l_effective_start_date       DATE ;
   l_object_version_no          per_assignment_extra_info.object_version_number%TYPE ;
   l_entry_information5         pay_element_entries_f.entry_information2%TYPE ;
   l_entry_information3         pay_element_entries_f.entry_information2%TYPE ;
   l_submitted                  NUMBER ;
   l_prev_submitted             NUMBER ;
   l_check                      NUMBER :=0;
   l_exempted_amount            NUMBER ;
   l_prev_exempted_amount       NUMBER ;
   l_session                    NUMBER ;





BEGIN
     g_debug     := hr_utility.debug_enabled;
     l_procedure := g_package ||'create_ltc_element';
     pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
     IF (g_debug)
     THEN
          pay_in_utils.trace('**************************************************','********************');
          pay_in_utils.set_location(g_debug,'Input Paramters value is',20);
          pay_in_utils.trace('P_LTCBLOCK',TO_CHAR (P_LTCBLOCK));
          pay_in_utils.trace('P_PLACE_FROM',TO_CHAR (P_PLACE_FROM));
          pay_in_utils.trace('P_PLACE_TO',TO_CHAR (P_PLACE_TO));
          pay_in_utils.trace('P_MODE_CLASS',TO_CHAR (P_MODE_CLASS));
          pay_in_utils.trace('P_CARRY_OVER',TO_CHAR (P_CARRY_OVER));
          pay_in_utils.trace('P_SUBMITTED',TO_CHAR (P_SUBMITTED));
          pay_in_utils.trace('P_EXEMPTED',TO_CHAR (P_EXEMPTED));
          pay_in_utils.trace('P_ELEMENT_ENTRY_ID',TO_CHAR (P_ELEMENT_ENTRY_ID));
          pay_in_utils.trace('P_START_DATE',TO_CHAR (P_START_DATE));
          pay_in_utils.trace('P_END_DATE',TO_CHAR (P_END_DATE));
          pay_in_utils.trace('P_BILL_NUM',TO_CHAR (P_BILL_NUM));
          pay_in_utils.trace('P_EE_COMMENTS',TO_CHAR (P_EE_COMMENTS));
          pay_in_utils.trace('P_ER_COMMENTS',TO_CHAR (P_ER_COMMENTS));
          pay_in_utils.trace('P_LAST_UPDATED_DATE',TO_CHAR (P_LAST_UPDATED_DATE));
          pay_in_utils.trace('P_ASSIGNMENT_ID',TO_CHAR (P_ASSIGNMENT_ID));
          pay_in_utils.trace('P_EMPLOYEE_ID',TO_CHAR (P_EMPLOYEE_ID));
	  pay_in_utils.trace('P_ASSIGNMENT_EXTRA_INFO_ID ',TO_CHAR (P_ASSIGNMENT_EXTRA_INFO_ID));
	  pay_in_utils.trace('P_ENTRY_DATE ',TO_CHAR (P_ENTRY_DATE));


     END IF;

     IF P_SUBMITTED < 0 THEN
         hr_utility.set_message(800, 'PER_IN_BEN_AMOUNT');
 	 hr_utility.raise_error;
     END IF ;

     IF P_EXEMPTED < 0 THEN
         hr_utility.set_message(800, 'PER_IN_BEN_APPROVED_AMOUNT');
 	 hr_utility.raise_error;
     END IF ;


     l_business_group_id :=  get_bg_id();

     IF (g_debug)
     THEN
          pay_in_utils.trace('l_business_group_id',TO_CHAR (l_business_group_id));
     END IF;

     BEGIN
         SELECT 1 INTO l_session FROM fnd_sessions WHERE SESSION_ID = USERENV('SESSIONID') AND ROWNUM=1;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         INSERT INTO fnd_sessions(session_id,effective_date) VALUES (USERENV('SESSIONID'),P_ENTRY_DATE);
     END ;


    IF ((p_element_entry_id IS NOT NULL))
    THEN

        pay_in_utils.set_location(g_debug,'Updating Element Entries: '||l_procedure,30);

        OPEN c_get_ele_object_version(p_element_entry_id) ;
        FETCH c_get_ele_object_version INTO l_object_version_no,l_effective_start_date ;
        CLOSE c_get_ele_object_version ;

	OPEN c_get_ele_type_id(p_element_entry_id);
	FETCH c_get_ele_type_id INTO l_ltc_element_type_id ;
	CLOSE c_get_ele_type_id ;

	l_count := 1;
        FOR c_rec IN c_input_rec(l_ltc_element_type_id,l_effective_start_date)
        LOOP
                l_input_values_rec(l_count).input_name     := c_rec.name;
                l_input_values_rec(l_count).input_value_id := c_rec.id;
                l_input_values_rec(l_count).value          := c_rec.value;

		IF (g_debug)
                THEN
			  pay_in_utils.trace('Input Value Name'||l_count,TO_CHAR (c_rec.name));
		 END IF;

		l_count := l_count + 1;
        END LOOP;


       	OPEN c_get_screen_value(p_element_entry_id, l_input_values_rec(3).input_value_id);
	FETCH c_get_screen_value INTO l_entry_information3 ;
	CLOSE c_get_screen_value ;

	IF (g_debug)
        THEN
	   pay_in_utils.trace('l_entry_information3',TO_CHAR (l_entry_information3));
	END IF;


	OPEN c_get_screen_value(p_element_entry_id, l_input_values_rec(5).input_value_id);
	FETCH c_get_screen_value INTO l_entry_information5 ;
	CLOSE c_get_screen_value ;

        OPEN  c_get_prev_amts ;
	FETCH c_get_prev_amts INTO l_prev_submitted, l_prev_exempted_amount;
	CLOSE c_get_prev_amts ;

	IF (g_debug)
        THEN
	   pay_in_utils.trace('l_prev_submitted',TO_CHAR (l_prev_submitted));
	   pay_in_utils.trace('l_prev_exempted_amount',TO_CHAR (l_prev_exempted_amount));
	END IF;


       l_submitted       := NVL(P_EXEMPTED,0) + NVL(l_entry_information3,0) - NVL(l_prev_exempted_amount,0) ;
       l_submitted       := GREATEST (l_submitted,0);
       l_exempted_amount := NVL(P_EXEMPTED,0)  + NVL(l_entry_information5,0) - NVL(l_prev_exempted_amount,0) ;
       l_exempted_amount := GREATEST (l_exempted_amount,0);

        pay_element_entry_api.update_element_entry
                 (p_datetrack_update_mode    => hr_api.g_correction
                 ,p_effective_date           => l_effective_start_date
                 ,p_business_group_id        => l_business_group_id
                 ,p_element_entry_id         => p_element_entry_id
                 ,p_object_version_number    => l_object_version_no
                 ,p_input_value_id1          => l_input_values_rec(1).input_value_id
                 ,p_input_value_id2          => l_input_values_rec(2).input_value_id
                 ,p_input_value_id3          => l_input_values_rec(3).input_value_id
                 ,p_input_value_id4          => l_input_values_rec(4).input_value_id
                 ,p_input_value_id5          => l_input_values_rec(5).input_value_id
                 ,p_input_value_id6          => l_input_values_rec(6).input_value_id
                 ,p_input_value_id7          => l_input_values_rec(7).input_value_id
                 ,p_input_value_id8          => l_input_values_rec(8).input_value_id
                 ,p_input_value_id9          => l_input_values_rec(9).input_value_id
                 ,p_entry_value1             => l_input_values_rec(1).value
                 ,p_entry_value2             => l_input_values_rec(2).value
                 ,p_entry_value3             => l_submitted
                 ,p_entry_value4             => P_LTCBLOCK
                 ,p_entry_value5             => l_exempted_amount
                 ,p_entry_value6             => P_CARRY_OVER
                 ,p_entry_value7             => l_input_values_rec(7).value
                 ,p_entry_value8             => l_input_values_rec(8).value
                 ,p_entry_value9             => l_input_values_rec(9).value
                 ,p_effective_start_date     => l_start_date
                 ,p_effective_end_date       => l_end_date
                 ,p_update_warning           => l_warnings
                 );



	l_object_version_no := NULL ;


    ELSIF ((p_element_entry_id IS NULL) )
    THEN


     OPEN  c_element_name(l_business_group_id);
     FETCH c_element_name INTO  l_ltc_element ;
     CLOSE c_element_name ;

     IF (g_debug)
     THEN
          pay_in_utils.trace('l_ltc_element ',TO_CHAR (l_ltc_element));
     END IF;


     OPEN csr_element_details(p_assignment_id, p_entry_date, l_ltc_element) ;
     FETCH csr_element_details INTO l_ltc_element_type_id, l_ltc_element_link_id ;
     CLOSE csr_element_details ;


      IF (g_debug)
        THEN
             pay_in_utils.trace('l_ltc_element_type_id ',TO_CHAR (l_ltc_element_type_id));
             pay_in_utils.trace('l_ltc_element_link_id ',TO_CHAR (l_ltc_element_link_id));
      END IF;

     OPEN c_check_element_entry(l_ltc_element_type_id, p_entry_date);
     FETCH c_check_element_entry INTO l_element_entry_id ;
     CLOSE c_check_element_entry ;

     IF l_element_entry_id IS NOT NULL THEN

        pay_in_utils.set_location(g_debug,'Updating Element Entries: '||l_procedure,40);

        OPEN c_get_ele_object_version(l_element_entry_id) ;
        FETCH c_get_ele_object_version INTO l_object_version_no,l_effective_start_date ;
        CLOSE c_get_ele_object_version ;




	l_count := 1;
        FOR c_rec IN c_input_rec(l_ltc_element_type_id,l_effective_start_date)
        LOOP
                l_input_values_rec(l_count).input_name     := c_rec.name;
                l_input_values_rec(l_count).input_value_id := c_rec.id;
                l_input_values_rec(l_count).value          := c_rec.value;

		IF (g_debug)
                THEN
			  pay_in_utils.trace('Input Value Name'||l_count,TO_CHAR (c_rec.name));
		 END IF;

		l_count := l_count + 1;
        END LOOP;

	OPEN c_get_screen_value(l_element_entry_id, l_input_values_rec(3).input_value_id);
	FETCH c_get_screen_value INTO l_entry_information3 ;
	CLOSE c_get_screen_value ;

	IF (g_debug)
        THEN
	   pay_in_utils.trace('l_entry_information3',TO_CHAR (l_entry_information3));
	END IF;


	OPEN c_get_screen_value(l_element_entry_id, l_input_values_rec(5).input_value_id);
	FETCH c_get_screen_value INTO l_entry_information5 ;
	CLOSE c_get_screen_value ;

	IF (g_debug)
        THEN
	   pay_in_utils.trace('l_entry_information5',TO_CHAR (l_entry_information5));
	END IF;



       l_submitted       := NVL(P_EXEMPTED,0) + NVL(l_entry_information3,0) ;
       l_submitted       := GREATEST (l_submitted,0);
       l_exempted_amount := NVL(P_EXEMPTED,0) + NVL(l_entry_information5,0) ;
       l_exempted_amount := GREATEST (l_exempted_amount,0);

        pay_element_entry_api.update_element_entry
                 (p_datetrack_update_mode    => hr_api.g_correction
                 ,p_effective_date           => l_effective_start_date
                 ,p_business_group_id        => l_business_group_id
                 ,p_element_entry_id         => l_element_entry_id
                 ,p_object_version_number    => l_object_version_no
                 ,p_input_value_id1          => l_input_values_rec(1).input_value_id
                 ,p_input_value_id2          => l_input_values_rec(2).input_value_id
                 ,p_input_value_id3          => l_input_values_rec(3).input_value_id
                 ,p_input_value_id4          => l_input_values_rec(4).input_value_id
                 ,p_input_value_id5          => l_input_values_rec(5).input_value_id
                 ,p_input_value_id6          => l_input_values_rec(6).input_value_id
                 ,p_input_value_id7          => l_input_values_rec(7).input_value_id
                 ,p_input_value_id8          => l_input_values_rec(8).input_value_id
                 ,p_input_value_id9          => l_input_values_rec(9).input_value_id
                 ,p_entry_value1             => l_input_values_rec(1).value
                 ,p_entry_value2             => l_input_values_rec(2).value
                 ,p_entry_value3             => l_submitted
                 ,p_entry_value4             => P_LTCBLOCK
                 ,p_entry_value5             => l_exempted_amount
                 ,p_entry_value6             => P_CARRY_OVER
                 ,p_entry_value7             => l_input_values_rec(7).value
                 ,p_entry_value8             => l_input_values_rec(8).value
                 ,p_entry_value9             => l_input_values_rec(9).value
                 ,p_effective_start_date     => l_start_date
                 ,p_effective_end_date       => l_end_date
                 ,p_update_warning           => l_warnings
                 );



	l_object_version_no := NULL ;



     ELSE



       IF l_ltc_element_link_id IS NULL THEN

         OPEN  c_element(TO_NUMBER(l_ltc_element));
	 FETCH c_element INTO l_element;
         CLOSE c_element;

         hr_utility.set_message(800, 'PER_IN_MISSING_LINK');
         hr_utility.set_message_token('ELEMENT_NAME', l_element);
	 hr_utility.raise_error;
       END IF;

       --Populate the input value id, name records

      l_count := 1;
      FOR c_rec IN c_input_rec(l_ltc_element_type_id,p_entry_date)
      LOOP
                l_ben_input_values_rec(l_count).input_name     := c_rec.name;
                l_ben_input_values_rec(l_count).input_value_id := c_rec.id;
                l_ben_input_values_rec(l_count).value          := c_rec.value;

		IF (g_debug)
                THEN
			  pay_in_utils.trace('Input Value Name:'||l_count,TO_CHAR (c_rec.name));
		 END IF;

		l_count := l_count + 1;
      END LOOP;

            pay_in_utils.set_location(g_debug,'Creating Benefit Element Entries: '||l_procedure,50);






          IF (P_EXEMPTED IS NOT NULL) THEN
            pay_element_entry_api.create_element_entry
                 (p_effective_date           => p_entry_date
                 ,p_business_group_id        => l_business_group_id
                 ,p_assignment_id            => p_assignment_id
                 ,p_element_link_id          => l_ltc_element_link_id
                 ,p_entry_type               => 'E'
                 ,p_input_value_id1          => l_ben_input_values_rec(1).input_value_id
                 ,p_input_value_id2          => l_ben_input_values_rec(2).input_value_id
                 ,p_input_value_id3          => l_ben_input_values_rec(3).input_value_id
                 ,p_input_value_id4          => l_ben_input_values_rec(4).input_value_id
                 ,p_input_value_id5          => l_ben_input_values_rec(5).input_value_id
                 ,p_input_value_id6          => l_ben_input_values_rec(6).input_value_id
                 ,p_input_value_id7          => l_ben_input_values_rec(7).input_value_id
                 ,p_input_value_id8          => l_ben_input_values_rec(8).input_value_id
                 ,p_input_value_id9          => l_ben_input_values_rec(9).input_value_id
                 ,p_entry_value1             => l_ben_input_values_rec(1).value
                 ,p_entry_value2             => l_ben_input_values_rec(2).value
                 ,p_entry_value3             => P_EXEMPTED
                 ,p_entry_value4             => P_LTCBLOCK
                 ,p_entry_value5             => P_EXEMPTED
                 ,p_entry_value6             => P_CARRY_OVER
                 ,p_entry_value7             => l_ben_input_values_rec(7).value
                 ,p_entry_value8             => l_ben_input_values_rec(8).value
                 ,p_entry_value9             => l_ben_input_values_rec(9).value
                 ,p_effective_start_date     => l_start_date
                 ,p_effective_end_date       => l_end_date
                 ,p_element_entry_id         => l_element_entry_id
                 ,p_object_version_number    => l_object_version_no
                 ,p_create_warning           => l_warnings
                 );

          END IF;
	 pay_in_utils.set_location(g_debug,'Benefit Element Creation Completed'||l_procedure,60);



     END IF ;
    END IF;


        pay_in_utils.set_location(g_debug,'Updating Assignment_Extra_Info: '||l_procedure,70);

    IF P_EMPLOYEE_ID <> 0 THEN /* To prevent this from Self Service page and execute only for web adi*/

      UPDATE per_assignment_extra_info
      SET    AEI_INFORMATION10      = P_EXEMPTED
            ,AEI_INFORMATION6      =  P_ER_COMMENTS
            ,AEI_INFORMATION11     =  nvl(l_element_entry_id,p_element_entry_id)
	    ,aei_information18     = P_CARRY_OVER
      WHERE  ASSIGNMENT_EXTRA_INFO_ID = p_assignment_extra_info_id ;
    END IF;

    pay_in_utils.trace('**************************************************','********************');
    pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,80);
END create_ltc_element;


--------------------------------------------------------------------------
--                                                                      --
-- Name           : UPDATE_LTC_ELEMENT                                  --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Function to update the LTC element enrty as per the --
--                  details passed from the Web ADI Excel Sheet.        --
--                                                                      --
---------------------------------------------------------------------------

PROCEDURE update_ltc_element
(
 p_employee_number          IN VARCHAR2
,p_full_name                IN VARCHAR2
,p_start_date               IN DATE
,p_effective_end_date       IN DATE DEFAULT NULL
,p_fare		            IN NUMBER
,p_blockYr		    IN VARCHAR2
,p_carry		    IN VARCHAR2
,p_benefit		    IN NUMBER
,p_assignment_id            IN NUMBER
,p_element_entry_id         IN NUMBER  DEFAULT NULL
)
IS




   CURSOR c_input_rec(p_element_type_id         NUMBER
                     ,p_effective_date          DATE
                     )
   IS
   SELECT   inputs.name                   name
          , inputs.input_value_id         id
	  , inputs.default_value          value
   FROM     pay_element_types_f types
          , pay_input_values_f inputs
   WHERE    types.element_type_id = p_element_type_id
   AND      inputs.element_type_id = types.element_type_id
   --AND      inputs.legislation_code = 'IN'
   AND      p_effective_date BETWEEN types.effective_start_date  AND types.effective_end_date
   AND      p_effective_date BETWEEN inputs.effective_start_date AND inputs.effective_end_date
   ORDER BY inputs.display_sequence;




   CURSOR c_get_ele_object_version(p_element_entryid NUMBER )
   IS
   SELECT object_version_number
   FROM   pay_element_entries_f
   WHERE  element_entry_id = p_element_entryid;



   CURSOR c_get_ele_type_id(p_element_entryid NUMBER)
   IS
   SELECT element_type_id
   FROM   pay_element_entries_f
   WHERE  element_entry_id = p_element_entryid;


--Variables Initialization
   TYPE t_input_values_rec IS RECORD
        (input_name      pay_input_values_f.name%TYPE
        ,input_value_id  pay_input_values_f.input_value_id%TYPE
        ,value           pay_input_values_f.default_value%TYPE
        );

   TYPE t_input_values_tab IS TABLE OF t_input_values_rec INDEX BY BINARY_INTEGER;

   l_procedure                  VARCHAR2(250);
   l_warnings                   BOOLEAN;
   l_input_values_rec           t_input_values_tab;
   l_business_group_id          NUMBER;
   l_count                      NUMBER;
   l_element_type_id            NUMBER;
   l_start_date                 DATE ;
   l_end_date                   DATE ;
   l_object_version_no          per_assignment_extra_info.object_version_number%TYPE ;
   l_session                    NUMBER ;



BEGIN


     g_debug     := hr_utility.debug_enabled;
     l_procedure := g_package ||'update_ltc_element';
     pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
     IF (g_debug)
     THEN
          pay_in_utils.trace('**************************************************','********************');
          pay_in_utils.set_location(g_debug,'Input Paramters value is',20);
          pay_in_utils.trace('p_employee_number',TO_CHAR (p_employee_number));
          pay_in_utils.trace('p_full_name',TO_CHAR (p_full_name));
          pay_in_utils.trace('p_start_date',TO_CHAR (p_start_date));
          pay_in_utils.trace('p_effective_end_date',TO_CHAR (p_effective_end_date));
          pay_in_utils.trace('p_fare',TO_CHAR (p_fare));
          pay_in_utils.trace('p_blockYr',TO_CHAR (p_blockYr));
          pay_in_utils.trace('p_carry',TO_CHAR (p_carry));
          pay_in_utils.trace('p_benefit',TO_CHAR (p_benefit));
          pay_in_utils.trace('p_assignment_id',TO_CHAR (p_assignment_id));
	 pay_in_utils.trace(' p_element_entry_id',TO_CHAR (p_element_entry_id));

     END IF;

     IF p_fare < 0 THEN
         hr_utility.set_message(800, 'PER_IN_BEN_AMOUNT');
 	 hr_utility.raise_error;
     END IF ;


     IF p_benefit < 0 THEN
         hr_utility.set_message(800, 'PER_IN_BEN_APPROVED_AMOUNT');
 	 hr_utility.raise_error;
     END IF ;


     BEGIN
         SELECT 1 INTO l_session FROM fnd_sessions WHERE SESSION_ID = USERENV('SESSIONID') AND ROWNUM=1;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         INSERT INTO fnd_sessions(session_id,effective_date) VALUES (USERENV('SESSIONID'),p_start_date);
     END ;

     l_business_group_id :=  get_bg_id();

     IF (g_debug)
     THEN
          pay_in_utils.trace('Business Group:',TO_CHAR (l_business_group_id));
     END IF;


IF ((p_element_entry_id IS NOT NULL))
    THEN

        pay_in_utils.set_location(g_debug,'Updating Element Entries: '||l_procedure,30);

        OPEN c_get_ele_object_version(p_element_entry_id) ;
        FETCH c_get_ele_object_version INTO l_object_version_no ;
        CLOSE c_get_ele_object_version ;

	OPEN c_get_ele_type_id(p_element_entry_id);
	FETCH c_get_ele_type_id INTO l_element_type_id ;
	CLOSE c_get_ele_type_id ;

	l_count := 1;
        FOR c_rec IN c_input_rec(l_element_type_id,p_start_date)
        LOOP
                l_input_values_rec(l_count).input_name     := c_rec.name;
                l_input_values_rec(l_count).input_value_id := c_rec.id;
                l_input_values_rec(l_count).value          := c_rec.value;

		IF (g_debug)
                THEN
			  pay_in_utils.trace('Input Values Name:'||l_count,TO_CHAR (c_rec.name));
		 END IF;

		l_count := l_count + 1;
        END LOOP;



        pay_element_entry_api.update_element_entry
                 (p_datetrack_update_mode    => hr_api.g_correction
                 ,p_effective_date           => p_start_date
                 ,p_business_group_id        => l_business_group_id
                 ,p_element_entry_id         => p_element_entry_id
                 ,p_object_version_number    => l_object_version_no
                 ,p_input_value_id1          => l_input_values_rec(1).input_value_id
                 ,p_input_value_id2          => l_input_values_rec(2).input_value_id
                 ,p_input_value_id3          => l_input_values_rec(3).input_value_id
                 ,p_input_value_id4          => l_input_values_rec(4).input_value_id
                 ,p_input_value_id5          => l_input_values_rec(5).input_value_id
                 ,p_input_value_id6          => l_input_values_rec(6).input_value_id
                 ,p_input_value_id7          => l_input_values_rec(7).input_value_id
                 ,p_input_value_id8          => l_input_values_rec(8).input_value_id
                 ,p_input_value_id9          => l_input_values_rec(9).input_value_id
                 ,p_entry_value1             => l_input_values_rec(1).value
                 ,p_entry_value2             => l_input_values_rec(2).value
                 ,p_entry_value3             => p_fare
                 ,p_entry_value4             => p_blockYr
                 ,p_entry_value5             => p_benefit
                 ,p_entry_value6             => p_carry
                 ,p_entry_value7             => l_input_values_rec(7).value
                 ,p_entry_value8             => l_input_values_rec(8).value
                 ,p_entry_value9             => l_input_values_rec(9).value
                 ,p_effective_start_date     => l_start_date
                 ,p_effective_end_date       => l_end_date
                 ,p_update_warning           => l_warnings
                 );


END IF ;

UPDATE per_assignment_extra_info
    SET    AEI_INFORMATION18     = p_carry
   where AEI_INFORMATION11     = p_element_entry_id
   and assignment_id = p_assignment_id;

    pay_in_utils.trace('**************************************************','********************');
    pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);




END update_ltc_element;

END pay_in_med_web_adi;

/
