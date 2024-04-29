--------------------------------------------------------
--  DDL for Package Body PAY_IN_INDIA_BENEFITS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IN_INDIA_BENEFITS" AS
/* $Header: pyinmed.pkb 120.17 2008/04/24 14:35:34 lnagaraj noship $ */
--
-- Global Variables Section
--
  g_legislation_code     VARCHAR2(3);
  g_approval_info_type   VARCHAR2(40);
  g_element_value_list   t_element_values_tab;
  g_list_index           NUMBER;
  g_assignment_id        per_all_assignments_f.assignment_id%TYPE;
  g_index_assignment_id  per_all_assignments_f.assignment_id%TYPE;
  g_is_valid             BOOLEAN;
  g_index_values_valid   BOOLEAN;
  g_package              CONSTANT VARCHAR2(100) := 'pay_in_india_benefits.';
  g_debug                BOOLEAN;
--
-- The following type is declared to store all
-- the inputs values of tax elements.
--
  type t_input_values_rec is record
          (input_name      pay_input_values_f.name%TYPE
          ,input_value_id  pay_input_values_f.input_value_id%TYPE
          ,input_value     pay_element_entry_values.screen_entry_value%TYPE);

  type t_input_values_tab is table of t_input_values_rec
     index by binary_integer;

PROCEDURE create_ltc_element
(
 P_LTCBLOCK                     IN VARCHAR2
,P_PLACE_FROM                   IN VARCHAR2
,P_PLACE_TO                     IN VARCHAR2
,P_MODE_CLASS                   IN VARCHAR2
,P_CARRY_OVER                   IN VARCHAR2 DEFAULT NULL
,P_SUBMITTED                    IN NUMBER
,P_EXEMPTED                     IN NUMBER   DEFAULT NULL
,P_ELEMENT_ENTRY_ID             IN OUT NOCOPY NUMBER
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
,p_warnings OUT NOCOPY VARCHAR2
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

   CURSOR c_ltc_carry_over(p_element_entry_id NUMBER)
   IS SELECT nvl(peev.screen_entry_value,'N')
     FROM pay_element_entry_values_f peev,
          pay_input_values_f piv
     WHERE peev.element_entry_id = p_element_entry_id
       AND peev.input_value_id = piv.input_value_id
       AND piv.name ='Carryover from Prev Block';

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
   l_carry_over                 VARCHAR2(10);




BEGIN


     g_debug     := hr_utility.debug_enabled;
     p_warnings := 'TRUE';
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

     l_business_group_id :=  pay_in_med_web_adi.get_bg_id();

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


    OPEN c_ltc_carry_over(l_element_entry_id);
    FETCH c_ltc_carry_over INTO l_carry_over;
    CLOSE c_ltc_carry_over;

     IF (l_element_entry_id IS NOT NULL  AND l_carry_over = nvl(P_CARRY_OVER,'N'))THEN

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
      WHERE  ASSIGNMENT_EXTRA_INFO_ID = p_assignment_extra_info_id ;
    END IF;

    p_element_entry_id := nvl(l_element_entry_id,p_element_entry_id);



    pay_in_utils.trace('**************************************************','********************');
    pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,80);
     p_warnings := 'FALSE';
EXCEPTION
   WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg
         (p_pkg_name => g_package
         ,p_procedure_name => 'create_ltc_element'
         ,p_error_text => substr(sqlerrm, 1, 240)
         );
END create_ltc_element;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_MED_SUBMITTED                                   --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to get the total claim amount of approved  --
--                  or unapproved or all the medical bills for an       --
--                  assignment in a tax year.                           --
--                  Used in 'Change Medical Payment' tabular summary    --
--                                                                      --
---------------------------------------------------------------------------


  FUNCTION get_med_submitted(p_assignment_id NUMBER
                           ,p_tax_yr     VARCHAR2
			   ,p_created_from DATE DEFAULT NULL
			   ,p_created_to DATE DEFAULT NULL
			   ,p_approval_status VARCHAR2 DEFAULT NULL)
  RETURN NUMBER
  IS

    CURSOR csr_submitted_exempt IS
    SELECT SUM(fnd_number.canonical_to_number(pae.aei_information6)) submitted
      FROM per_assignment_extra_info pae
     WHERE pae.assignment_id = p_assignment_id
       AND pae.aei_information1 = p_tax_yr
       AND  pae.aei_information_category ='PER_IN_MEDICAL_BILLS'
       AND trunc(creation_date) >= nvl(p_created_from,to_date('01-01-1901','DD-MM-YYYY'))
       AND trunc(creation_date) <= nvl(p_created_to,to_date('31-12-4712','DD-MM-YYYY'))
       AND fnd_date.canonical_to_date(pae.aei_information3) >=
          (select min(effective_start_date)
	     from per_assignments_f
	    where assignment_id = p_assignment_id)
       AND pae.aei_information7 IS NOT NULL;

    CURSOR csr_submitted_unexempt IS
    SELECT SUM(fnd_number.canonical_to_number(pae.aei_information6)) submitted
      FROM per_assignment_extra_info pae
     WHERE pae.assignment_id = p_assignment_id
       AND pae.aei_information1 = p_tax_yr
       AND  pae.aei_information_category ='PER_IN_MEDICAL_BILLS'
       AND trunc(creation_date) >= nvl(p_created_from,to_date('01-01-1901','DD-MM-YYYY'))
       AND trunc(creation_date) <= nvl(p_created_to,to_date('31-12-4712','DD-MM-YYYY'))
       AND fnd_date.canonical_to_date(pae.aei_information3) >=
          (select min(effective_start_date)
	     from per_assignments_f
	    where assignment_id = p_assignment_id)
       AND pae.aei_information7 IS  NULL;

      l_submitted NUMBER;
      l_submitted_exempt NUMBER;
      l_submitted_unexempt NUMBER;

  BEGIN
    l_submitted :=0;


    OPEN csr_submitted_exempt;
    FETCH csr_submitted_exempt INTO l_submitted_exempt;
    CLOSE  csr_submitted_exempt;

    OPEN csr_submitted_unexempt;
    FETCH csr_submitted_unexempt INTO l_submitted_unexempt;
    CLOSE  csr_submitted_unexempt;

    IF p_approval_status = 'APPR' THEN
      l_submitted := NVL(l_submitted_exempt,0);
    ELSIF p_approval_status = 'UNAPPR' THEN
      l_submitted := NVL(l_submitted_unexempt,0);
    ELSE
      l_submitted := NVL(l_submitted_exempt,0) + NVL(l_submitted_unexempt,0);
    END IF;


    RETURN l_submitted;

  END get_med_submitted;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_LTC_SUBMITTED                                   --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Function to get the total claim amount of approved  --
--                  or unapproved or all                                --
--                  the LTC bills for an assignment in a LTC Block.     --
--                  Used in 'Change LTC Payment' tabular summary        --
--                                                                      --
---------------------------------------------------------------------------


  FUNCTION get_ltc_submitted(p_assignment_id NUMBER
                            ,p_tax_yr     VARCHAR2
		 	    ,p_created_from DATE DEFAULT NULL
		 	    ,p_created_to DATE DEFAULT NULL
			    ,p_approval_status VARCHAR2 DEFAULT NULL
			    ,p_carry_over VARCHAR2)
  RETURN NUMBER
  IS

    CURSOR csr_submitted_exempt IS
    SELECT SUM(fnd_number.canonical_to_number(pae.aei_information9)) submitted
      FROM per_assignment_extra_info pae
     WHERE pae.assignment_id = p_assignment_id
       AND pae.aei_information1 = p_tax_yr
       AND  pae.aei_information_category ='PER_IN_LTC_BILLS'
       AND trunc(creation_date) >= nvl(p_created_from,to_date('01-01-1901','DD-MM-YYYY'))
       AND trunc(creation_date) <= nvl(p_created_to,to_date('31-12-4712','DD-MM-YYYY'))
       AND pae.aei_information10 IS NOT NULL
       AND fnd_date.canonical_to_date(pae.aei_information13) >=
          (select min(effective_start_date)
	     from per_assignments_f
	    where assignment_id = p_assignment_id)
       AND NVL(pae.aei_information18,'N') =nvl(p_carry_over,'N') ;

    CURSOR csr_submitted_unexempt IS
    SELECT SUM(fnd_number.canonical_to_number(pae.aei_information9)) submitted
      FROM per_assignment_extra_info pae
     WHERE pae.assignment_id = p_assignment_id
       AND pae.aei_information1 = p_tax_yr
       AND  pae.aei_information_category ='PER_IN_LTC_BILLS'
       AND trunc(creation_date) >= nvl(p_created_from,to_date('01-01-1901','DD-MM-YYYY'))
       AND trunc(creation_date) <= nvl(p_created_to,to_date('31-12-4712','DD-MM-YYYY'))
       AND pae.aei_information10 IS  NULL
       AND fnd_date.canonical_to_date(pae.aei_information13) >=
          (select min(effective_start_date)
	     from per_assignments_f
	    where assignment_id = p_assignment_id)
       AND NVL(pae.aei_information18,'N') = nvl(p_carry_over,'N');

    l_submitted NUMBER;
    l_submitted_exempt NUMBER;
    l_submitted_unexempt NUMBER;

  BEGIN
    l_submitted :=0;


    OPEN csr_submitted_exempt;
    FETCH csr_submitted_exempt INTO l_submitted_exempt;
    CLOSE  csr_submitted_exempt;

    OPEN csr_submitted_unexempt;
    FETCH csr_submitted_unexempt INTO l_submitted_unexempt;
    CLOSE  csr_submitted_unexempt;

    IF p_approval_status = 'APPR' THEN
      l_submitted := NVL(l_submitted_exempt,0);
    ELSIF p_approval_status = 'UNAPPR' THEN
      l_submitted := NVL(l_submitted_unexempt,0);
    ELSE
     l_submitted := NVL(l_submitted_exempt,0) + NVL(l_submitted_unexempt,0);
    END IF;


    RETURN l_submitted;

  END get_ltc_submitted;

--------------------------------------------------------------------------
--                                                                       --
-- Name           : GET_MED_EXEMPTED                                     --
-- Type           : FUNCTION                                             --
-- Access         : Public                                               --
-- Description    : Function to get the total exempted amount of all the --
--                  approved or unapproved or all                        --
--                  the LTC bills for an assignment in a LTC Block.      --
--                  Used in 'Change LTC Payment' tabular summary         --
--                                                                       --
---------------------------------------------------------------------------

  FUNCTION get_med_exempted(p_assignment_id NUMBER
                           ,p_tax_yr     VARCHAR2
			   ,p_created_from DATE DEFAULT NULL
			   ,p_created_to DATE DEFAULT NULL
			   ,p_approval_status VARCHAR2 DEFAULT NULL)
  RETURN NUMBER
  IS

     CURSOR csr_submitted_exempt IS
    SELECT sum(nvl(fnd_number.canonical_to_number(nvl(aei_information7,0)),0)) approved
      FROM per_assignment_extra_info pae
     WHERE pae.assignment_id = p_assignment_id
       AND pae.aei_information1 = p_tax_yr
       AND  pae.aei_information_category ='PER_IN_MEDICAL_BILLS'
       AND trunc(creation_date) >= nvl(p_created_from,to_date('01-01-1901','DD-MM-YYYY'))
       AND trunc(creation_date) <= nvl(p_created_to,to_date('31-12-4712','DD-MM-YYYY'))
       AND fnd_date.canonical_to_date(pae.aei_information3) >=
          (select min(effective_start_date)
	     from per_assignments_f
	    where assignment_id = p_assignment_id)
       AND pae.aei_information7 IS NOT NULL;

    CURSOR csr_submitted_unexempt IS
    SELECT sum(nvl(fnd_number.canonical_to_number(nvl(aei_information7,0)),0)) approved
      FROM per_assignment_extra_info pae
     WHERE pae.assignment_id = p_assignment_id
       AND pae.aei_information1 = p_tax_yr
       AND  pae.aei_information_category ='PER_IN_MEDICAL_BILLS'
       AND trunc(creation_date) >= nvl(p_created_from,to_date('01-01-1901','DD-MM-YYYY'))
       AND trunc(creation_date) <= nvl(p_created_to,to_date('31-12-4712','DD-MM-YYYY'))
       AND fnd_date.canonical_to_date(pae.aei_information3) >=
          (select min(effective_start_date)
	     from per_assignments_f
	    where assignment_id = p_assignment_id)
       AND pae.aei_information7 IS  NULL;

      l_exempted NUMBER;

  BEGIN

    l_exempted :=0;


    OPEN csr_submitted_exempt;
    FETCH csr_submitted_exempt INTO l_exempted;
    CLOSE  csr_submitted_exempt;


    IF p_approval_status = 'APPR' THEN
      l_exempted := NVL(l_exempted,0);
    ELSIF p_approval_status = 'UNAPPR' THEN
      l_exempted :=0;
    ELSE
      l_exempted := NVL(l_exempted,0);
    END IF;


    RETURN l_exempted;

  END get_med_exempted ;

---------------------------------------------------------------------------
--                                                                        --
-- Name           : GET_LTC_EXEMPTED                                      --
-- Type           : FUNCTION                                              --
-- Access         : Public                                                --
-- Description    : Function to get the total exempted amount of approved --
--                  or unapproved or all                                  --
--                  the LTC bills for an assignment in a LTC Block.       --
--                  Used in 'Change LTC Payment' tabular summary          --
--                                                                        --
---------------------------------------------------------------------------


  FUNCTION get_ltc_exempted(p_assignment_id NUMBER
                           ,p_tax_yr     VARCHAR2
			   ,p_created_from DATE DEFAULT NULL
			   ,p_created_to DATE DEFAULT NULL
			   ,p_approval_status VARCHAR2 DEFAULT NULL
			   ,p_carry_over VARCHAR2)
  RETURN NUMBER
  IS

    CURSOR csr_submitted_exempt IS
    SELECT SUM(fnd_number.canonical_to_number(pae.aei_information10)) submitted
      FROM per_assignment_extra_info pae
     WHERE pae.assignment_id = p_assignment_id
       AND pae.aei_information1 = p_tax_yr
       AND  pae.aei_information_category ='PER_IN_LTC_BILLS'
       AND trunc(creation_date) >= nvl(p_created_from,to_date('01-01-1901','DD-MM-YYYY'))
       AND trunc(creation_date) <= nvl(p_created_to,to_date('31-12-4712','DD-MM-YYYY'))
       AND fnd_date.canonical_to_date(pae.aei_information13) >=
          (select min(effective_start_date)
	     from per_assignments_f
	    where assignment_id = p_assignment_id)
       AND pae.aei_information10 IS NOT NULL
       and NVL(pae.aei_information18,'N') = nvl(p_carry_over,'N');


    l_exempted NUMBER;

  BEGIN
    l_exempted :=0;


    OPEN csr_submitted_exempt;
    FETCH csr_submitted_exempt INTO l_exempted;
    CLOSE  csr_submitted_exempt;



    IF p_approval_status = 'APPR' THEN
      l_exempted := NVL(l_exempted,0);
    ELSIF p_approval_status = 'UNAPPR' THEN
      l_exempted := 0;
    ELSE
     l_exempted := NVL(l_exempted,0);
    END IF;


    RETURN l_exempted;


  END get_ltc_exempted;


--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_MED_BILL_DATE                                   --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : The procedure is responsible for returning the      --
--                  freeze period details like start date, along with   --
--                  a flag to indicate if it is the freeze period.      --
--                                                                      --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date        Userid      Description                            --
--------------------------------------------------------------------------
-- 1.0  24-Sep-2004  PUCHIL      Initial Version                        --
--------------------------------------------------------------------------




  FUNCTION get_med_bill_date(p_assignment_id NUMBER
                           ,p_tax_yr     VARCHAR2
			   ,p_created_from DATE DEFAULT NULL
			   ,p_created_to DATE DEFAULT NULL
			   ,p_approval_status VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2
  IS



    CURSOR csr_submitted_exempt IS
    SELECT 'Y'
      FROM per_assignment_extra_info pae
     WHERE pae.assignment_id = p_assignment_id
       AND pae.aei_information1 = p_tax_yr
       AND  pae.aei_information_category ='PER_IN_MEDICAL_BILLS'
       AND trunc(creation_date) >= nvl(p_created_from,to_date('01-01-1901','DD-MM-YYYY'))
       AND trunc(creation_date) <= nvl(p_created_to,to_date('31-12-4712','DD-MM-YYYY'))
       AND fnd_date.canonical_to_date(pae.aei_information3) >=
          (select min(effective_start_date)
	     from per_assignments_f
	    where assignment_id = p_assignment_id)
       AND pae.aei_information7 IS NOT NULL;

    CURSOR csr_submitted_unexempt IS
    SELECT 'Y'
      FROM per_assignment_extra_info pae
     WHERE pae.assignment_id = p_assignment_id
       AND pae.aei_information1 = p_tax_yr
       AND  pae.aei_information_category ='PER_IN_MEDICAL_BILLS'
       AND trunc(creation_date) >= nvl(p_created_from,to_date('01-01-1901','DD-MM-YYYY'))
       AND trunc(creation_date) <= nvl(p_created_to,to_date('31-12-4712','DD-MM-YYYY'))
       AND fnd_date.canonical_to_date(pae.aei_information3) >=
          (select min(effective_start_date)
	     from per_assignments_f
	    where assignment_id = p_assignment_id)
       AND pae.aei_information7 IS  NULL;

      l_submitted VARCHAR2(10);
      l_submitted_exempt VARCHAR2(10);
      l_submitted_unexempt VARCHAR2(10);

  BEGIN
    l_submitted :='N';


    OPEN csr_submitted_exempt;
    FETCH csr_submitted_exempt INTO l_submitted_exempt;
    CLOSE  csr_submitted_exempt;

    OPEN csr_submitted_unexempt;
    FETCH csr_submitted_unexempt INTO l_submitted_unexempt;
    CLOSE  csr_submitted_unexempt;

    IF p_approval_status = 'APPR' THEN
      l_submitted := NVL(l_submitted_exempt,'N');
    ELSIF p_approval_status = 'UNAPPR' THEN
      l_submitted := NVL(l_submitted_unexempt,'N');
    ELSE
       IF l_submitted_exempt ='N' and l_submitted_unexempt ='N' THEN
          l_submitted := 'N';
       ELSE
          l_submitted := 'Y';
       END IF;
    END IF;


    RETURN l_submitted;

 END get_med_bill_date ;

 FUNCTION get_last_updated_date
         (p_assignment_id      IN NUMBER
         ,p_block              IN VARCHAR2
         ,p_asg_info_type      IN VARCHAR2
	 ,p_created_from       IN DATE DEFAULT NULL
	 ,p_created_to         IN DATE DEFAULT NULL
	 ,p_approved           IN VARCHAR2 DEFAULT NULL
	 ,p_carry_over IN VARCHAR2 default null)
RETURN DATE
IS
/* CHANGE THIS CURSOR TO INCLUDE APPROVAL STATUS LATER */
   CURSOR csr_get_med_date_appr
   IS
   SELECT MAX(extra.last_update_date)
     FROM per_assignment_extra_info extra
    WHERE extra.information_type = 'PER_IN_MEDICAL_BILLS'
      and extra.aei_information1 = p_block
      AND extra.assignment_id = p_assignment_id
      AND trunc(creation_date) >= nvl(p_created_from,to_date('01-01-1901','DD-MM-YYYY'))
      and trunc(creation_date) <= nvl(p_created_to,to_date('31-12-4712','DD-MM-YYYY'))
       AND fnd_date.canonical_to_date(extra.aei_information3) >=
          (select min(effective_start_date)
	     from per_assignments_f
	    where assignment_id = p_assignment_id)
      AND extra.aei_information7 IS not NULL;


       CURSOR csr_get_ltc_date_appr
   IS
   SELECT MAX(extra.last_update_date)
     FROM per_assignment_extra_info extra
    WHERE extra.information_type = 'PER_IN_LTC_BILLS'
      and extra.aei_information1 = p_block
      AND extra.assignment_id = p_assignment_id
      AND trunc(creation_date) >= nvl(p_created_from,to_date('01-01-1901','DD-MM-YYYY'))
      and trunc(creation_date) <= nvl(p_created_to,to_date('31-12-4712','DD-MM-YYYY'))
      and NVL(extra.aei_information18,'N') = nvl(p_carry_over,'N')
       AND fnd_date.canonical_to_date(extra.aei_information13) >=
          (select min(effective_start_date)
	     from per_assignments_f
	    where assignment_id = p_assignment_id)
      and extra.aei_information10 is not null;

CURSOR csr_get_med_date_unappr
   IS
   SELECT MAX(extra.last_update_date)
     FROM per_assignment_extra_info extra
    WHERE extra.information_type = 'PER_IN_MEDICAL_BILLS'
      and extra.aei_information1 = p_block
      AND extra.assignment_id = p_assignment_id
      AND trunc(creation_date) >= nvl(p_created_from,to_date('01-01-1901','DD-MM-YYYY'))
      and trunc(creation_date) <= nvl(p_created_to,to_date('31-12-4712','DD-MM-YYYY'))
       AND fnd_date.canonical_to_date(extra.aei_information3) >=
          (select min(effective_start_date)
	     from per_assignments_f
	    where assignment_id = p_assignment_id)
      AND extra.aei_information7 IS  NULL;



       CURSOR csr_get_ltc_date_unappr
   IS
   SELECT MAX(extra.last_update_date)
     FROM per_assignment_extra_info extra
    WHERE extra.information_type = 'PER_IN_LTC_BILLS'
      and extra.aei_information1 = p_block
      AND extra.assignment_id = p_assignment_id
      AND trunc(creation_date) >= nvl(p_created_from,to_date('01-01-1901','DD-MM-YYYY'))
      and trunc(creation_date) <= nvl(p_created_to,to_date('31-12-4712','DD-MM-YYYY'))
      and NVL(extra.aei_information18,'N') = nvl(p_carry_over,'N')
       AND fnd_date.canonical_to_date(extra.aei_information13) >=
          (select min(effective_start_date)
	     from per_assignments_f
	    where assignment_id = p_assignment_id)
      and extra.aei_information10 is  null;

   --
   l_updated_date DATE;
   l_procedure     VARCHAR(100);
   l_upd_date_unappr date;
   l_upd_date_appr date;


   --
BEGIN
   --
    l_procedure := g_package || 'get_last_updated_date';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('p_assignment_id ',p_assignment_id);
      pay_in_utils.trace('p_block ', p_block);
      pay_in_utils.trace('p_asg_info_type Date: ', p_asg_info_type);
      pay_in_utils.trace('**************************************************','********************');
   END IF;

   --

   --

   IF p_asg_info_type ='PER_IN_MEDICAL_BILLS' THEN
     OPEN csr_get_med_date_appr;
     FETCH csr_get_med_date_appr INTO l_upd_date_appr;
     CLOSE csr_get_med_date_appr;

     OPEN csr_get_med_date_unappr;
     FETCH csr_get_med_date_unappr INTO l_upd_date_unappr;
     CLOSE csr_get_med_date_unappr;

   ELSE
     OPEN csr_get_ltc_date_appr;
     FETCH csr_get_ltc_date_appr INTO l_upd_date_appr;
     CLOSE csr_get_ltc_date_appr;

     OPEN csr_get_med_date_unappr;
     FETCH csr_get_med_date_unappr INTO l_upd_date_unappr;
     CLOSE csr_get_med_date_unappr;

   END IF;

   IF p_approved = 'APPR' THEN
      l_updated_date := l_upd_date_appr;
    ELSIF p_approved = 'UNAPPR' THEN
      l_updated_date := l_upd_date_unappr;
    ELSE
     l_updated_date :=  GREATEST(l_upd_date_appr,l_upd_date_unappr);
    END IF;
   --
   IF g_debug THEN
     pay_in_utils.trace('**************************************************','********************');
     pay_in_utils.trace('l_updated_date',l_updated_date);
     pay_in_utils.trace('**************************************************','********************');
   END IF;

   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,90);
   --
   RETURN l_updated_date;


END get_last_updated_date;


FUNCTION get_entry_value(p_assignment_id IN NUMBER
                        ,p_entry_id IN  NUMBER
                        ,p_input_name IN  VARCHAR2
			,p_date     IN  DATE)
RETURN VARCHAR2 IS

  CURSOR c_get_value
  IS
  SELECT screen_entry_value
    FROM pay_element_entry_values_f peev,
         pay_element_entries_f pev,
         pay_element_types_f pet,
         pay_input_values_f piv
    WHERE pev.assignment_id = p_assignment_id
      AND pev.element_type_id = pet.element_type_id
      AND pev.element_entry_id = peev.element_entry_id
      AND peev.element_entry_id = p_entry_id
      AND piv.name  = p_input_name
      AND piv.input_value_id = peev.input_value_id
      AND SYSDATE BETWEEN pet.effective_start_date AND pet.effective_end_date
      AND SYSDATE BETWEEN piv.effective_start_date AND piv.effective_end_date
      AND p_date BETWEEN pev.effective_start_date AND pev.effective_end_date
      AND p_date BETWEEN peev.effective_start_date AND peev.effective_end_date;

      l_value varchar2(300);

  BEGIN

    OPEN c_get_value;
    FETCH c_get_value INTO l_value;
    CLOSE c_get_value;

    RETURN l_value;
  END get_entry_value;




FUNCTION get_relationship(p_person_id IN NUMBER
                           ,p_business_group_id IN NUMBER)
  RETURN VARCHAR2
  IS

    CURSOR csr_relation
    IS
    SELECT hr_general.decode_lookup('CONTACT',relation.contact_type)
      FROM per_contact_relationships relation,
           per_all_people_f ppf
     WHERE ppf.person_id = relation.contact_person_id
      AND relation.contact_person_id = p_person_id
      AND ppf.business_group_id = p_business_group_id;

    l_relationship VARCHAR2(200);

  BEGIN

    OPEN csr_relation;
    FETCH csr_relation INTO l_relationship;
    CLOSE csr_relation;

    RETURN l_relationship;

  END get_relationship;

  PROCEDURE get_element_type_id(p_element_flag IN VARCHAR2
                             ,p_business_group_id in number
                             ,p_element_type_id OUT NOCOPY NUMBER)
is
CURSOR csr_element_ids IS
SELECT  DECODE(p_element_flag,'MEDBILL',org.org_information1,'MEDPAY',org.org_information2,'LTC_ELE',org.org_information3)
  FROM hr_organization_information org,
        hr_organization_units unit
    WHERE org.org_information_context = 'PER_IN_REIMBURSE_ELEMENTS'
      AND org.organization_id =unit.organization_id
      AND unit.business_group_id = p_business_group_id;


BEGIN
  OPEN csr_element_ids;
  FETCH csr_element_ids INTO p_element_type_id;
  CLOSE csr_element_ids;


END get_element_type_id;

PROCEDURE set_profile(p_person_id IN NUMBER)
IS
BEGIN

     fnd_profile.PUT('PER_PERSON_ID',p_person_id);
END set_profile;



PROCEDURE delete_medical_bill_entry(p_asg_extra_info_id IN NUMBER)
IS
 CURSOR csr_exists
    IS
    SELECT '1'
      FROM per_assignment_extra_info
     WHERE assignment_extra_info_id = p_asg_extra_info_id;

  l_ovn NUMBER;
  l_exists VARCHAR2(1);
BEGIN
   OPEN csr_exists;
   FETCH csr_exists INTO l_exists;
     IF csr_exists%FOUND THEN

      DELETE FROM per_assignment_extra_info
            WHERE assignment_extra_info_id = p_asg_extra_info_id;
     END IF;

   CLOSE csr_exists ;


END delete_medical_bill_entry;

PROCEDURE medical_bill_entry(p_asg_id IN NUMBER
                            ,p_financial_yr IN VARCHAR2 DEFAULT NULL /* needed mainly for PU*/
                            ,p_bill_date IN DATE DEFAULT NULL
	                    ,p_person_id IN NUMBER
			    ,p_con_person_id IN NUMBER DEFAULT NULL
			    ,p_old_bill_amt IN NUMBER DEFAULT NULL
			    ,p_new_bill_amt IN NUMBER DEFAULT NULL
			    ,p_old_exempt_amt IN NUMBER DEFAULT NULL
			    ,p_new_exempt_amt IN NUMBER DEFAULT NULL
			    ,p_element_entry_id IN NUMBER DEFAULT NULL
			    ,p_bill_number IN VARCHAR2 DEFAULT NULL
			    ,p_asg_extra_info_id IN NUMBER DEFAULT NULL
			    ,p_ovn IN NUMBER DEFAULT NULL
			    ,p_business_group_id IN NUMBER
			    ,p_element_entry_date IN DATE
			    ,p_super_user IN VARCHAR2
			    ,p_ee_comments IN VARCHAR2
			    ,p_er_comments IN VARCHAR2
                            )
IS



 CURSOR csr_get_ovn(l_asg_extra_info_d NUMBER)
 IS
 SELECT object_version_number
   FROM per_assignment_extra_info
  WHERE assignment_extra_info_id = l_asg_extra_info_d;


  l_bill_amt NUMBER ;
  l_ovn NUMBER;
  l_extra_id_out NUMBER;
  l_ovn_out NUMBER;
  l_element_entry_id pay_element_entries_f.element_entry_id%TYPE;

  l_person_profile_id NUMBER;
  l_bg_profile_id NUMBER;



 BEGIN

   g_debug     := hr_utility.debug_enabled;

   OPEN csr_get_ovn(p_asg_extra_info_id);
   FETCH csr_get_ovn into l_ovn;
   CLOSE csr_get_ovn;

     IF (g_debug)
     THEN
          pay_in_utils.trace('**************************************************','********************');
          pay_in_utils.set_location(g_debug,'Input Paramters values are',20);
          pay_in_utils.trace('p_asg_id',TO_CHAR (p_asg_id));
          pay_in_utils.trace('p_financial_yr',TO_CHAR (p_financial_yr));
          pay_in_utils.trace('p_bill_date',TO_CHAR (p_bill_date));
          pay_in_utils.trace('p_person_id',TO_CHAR (p_person_id));
          pay_in_utils.trace('p_con_person_id',TO_CHAR (p_con_person_id));
          pay_in_utils.trace('p_old_bill_amt',TO_CHAR (p_old_bill_amt));
          pay_in_utils.trace('p_old_exempt_amt',TO_CHAR (p_old_exempt_amt));
          pay_in_utils.trace('p_new_exempt_amt',TO_CHAR (p_new_exempt_amt));
          pay_in_utils.trace('p_element_entry_id',TO_CHAR (p_element_entry_id));
          pay_in_utils.trace('p_bill_number',TO_CHAR (p_bill_number));
          pay_in_utils.trace('p_asg_extra_info_id',TO_CHAR (p_asg_extra_info_id));
          pay_in_utils.trace('p_ovn',TO_CHAR (p_ovn));
          pay_in_utils.trace('p_business_group_id',TO_CHAR (p_business_group_id));
          pay_in_utils.trace('p_element_entry_date',TO_CHAR (p_element_entry_date));
          pay_in_utils.trace('p_super_user',TO_CHAR (p_super_user));
          pay_in_utils.trace('p_ee_comments',TO_CHAR(p_ee_comments));
          pay_in_utils.trace('p_er_comments',TO_CHAR(p_er_comments));

     END IF;

   IF p_super_user ='Y'
   THEN
        pay_in_med_web_adi.create_medical
        (p_tax_year       => p_financial_yr
        ,p_bill_date      => p_bill_date
        ,p_name           => p_con_person_id
        ,p_bill_number    => p_bill_number
        ,p_bill_amount    => p_new_bill_amt
        ,p_approved_bill_amount  => p_new_exempt_amt
        ,p_employee_remarks      => p_ee_comments
        ,p_employer_remarks      => p_er_comments
        ,p_element_entry_id      => p_element_entry_id
 	,p_assignment_id         => p_asg_id
	,p_employee_id           =>''
        ,p_employee_name         =>''
        ,p_assignment_extra_info_id => p_asg_extra_info_id
        ,p_entry_date               => p_element_entry_date
        );
   ELSE
     fnd_profile.PUT('PER_PERSON_ID',p_con_person_id);

     select fnd_profile.value('PER_PERSON_ID') into l_person_profile_id from dual;
     select fnd_profile.value('PER_BUSINESS_GROUP_ID') into l_bg_profile_id from dual;

          IF (g_debug)
          THEN
             pay_in_utils.set_location(g_debug,'PER_PERSON_ID'||TO_CHAR(l_person_profile_id),20);
             pay_in_utils.set_location(g_debug,'PER_BUSINESS_GROUP_ID'||TO_CHAR(l_bg_profile_id),20);
          END IF;






     IF p_asg_extra_info_id is null THEN
          IF (g_debug)
          THEN
             pay_in_utils.set_location(g_debug,'Creating new assignment extra information',20);
          END IF;

           hr_assignment_extra_info_api.create_assignment_extra_info(
                        p_assignment_id                => p_asg_id,
                        p_information_type             => 'PER_IN_MEDICAL_BILLS',
                        p_aei_information_category     => 'PER_IN_MEDICAL_BILLS',
                        p_aei_information1             => p_financial_yr,
                        p_aei_information2             => '',
                        p_aei_information3             => fnd_date.date_to_canonical(p_bill_date),
                        p_aei_information4             => p_person_id,
			p_aei_information5             => p_bill_number,
			p_aei_information6             => fnd_number.number_to_canonical(p_new_bill_amt) ,
                        p_aei_information8             => p_ee_comments,
			p_aei_information9             => p_er_comments,
			p_aei_information10            => l_element_entry_id,
			p_assignment_extra_info_id     => l_extra_id_out,
                        p_object_version_number        => l_ovn_out
                         );


     ELSE

        IF (g_debug)
        THEN
           pay_in_utils.set_location(g_debug,'Updating AEI'||TO_CHAR(p_asg_extra_info_id),20);
        END IF;

         hr_assignment_extra_info_api.update_assignment_extra_info(
                        p_aei_information1             => p_financial_yr,
                        p_aei_information2             => '',
                        p_aei_information3             => fnd_date.date_to_canonical(p_bill_date),
                        p_aei_information4             => p_con_person_id,
			p_aei_information5             => p_bill_number,
			p_aei_information6             => fnd_number.number_to_canonical(p_new_bill_amt) ,
                        p_aei_information8             => p_ee_comments,
			p_aei_information9             => p_er_comments,
			p_aei_information10            => l_element_entry_id,
			p_assignment_extra_info_id     => p_asg_extra_info_id,
                        p_object_version_number        => l_ovn);
     END IF;

   END IF;

END medical_bill_entry;



  PROCEDURE ltc_bill_entry(    p_asg_id IN NUMBER
                              ,p_ltc_block IN VARCHAR2 DEFAULT NULL /* needed mainly for PU*/
			      ,p_ben_name IN VARCHAR2 DEFAULT NULL
			      ,p_place_from IN VARCHAR2 DEFAULT NULL
			      ,p_bill_number IN VARCHAR2 DEFAULT NULL
			      ,p_ee_comments IN VARCHAR2
			      ,p_er_comments IN VARCHAR2
                              ,p_place_to IN VARCHAR2 DEFAULT NULL
			      ,p_travel_mode IN VARCHAR2 DEFAULT NULL
			      ,p_bill_amt IN NUMBER DEFAULT NULL
			      ,p_exempt_amt IN NUMBER DEFAULT NULL
			      ,p_element_entry_id IN OUT NOCOPY NUMBER
			      ,p_start_date IN DATE
			      ,p_end_date IN DATE
			      ,p_carry_over_flag IN VARCHAR2 DEFAULT NULL
			      ,p_asg_extra_info_id IN NUMBER DEFAULT NULL
			      ,p_element_entry_date IN DATE
			      ,p_super_user IN VARCHAR2
			      ,p_person_id IN NUMBER
			      , p_warnings OUT NOCOPY VARCHAR2
                              )
  IS

   l_procedure                  VARCHAR2(250);
   l_warnings    VARCHAR2(250);
  BEGIN


     g_debug     := hr_utility.debug_enabled;
     l_procedure := g_package ||'ltc_bill_entry';
     pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

     p_warnings := 'TRUE';

     IF (p_element_entry_id =0) THEN
        p_element_entry_id :='';
     END IF;

     IF (g_debug)
     THEN
          pay_in_utils.trace('**************************************************','********************');
          pay_in_utils.set_location(g_debug,'Input Paramters values are',20);
          pay_in_utils.trace('p_asg_id',TO_CHAR (p_asg_id));
          pay_in_utils.trace('p_ltc_block',TO_CHAR (p_ltc_block));
          pay_in_utils.trace('p_ben_name',TO_CHAR (p_ben_name));
          pay_in_utils.trace('p_place_from',TO_CHAR (p_place_from));
          pay_in_utils.trace('p_bill_number',TO_CHAR (p_bill_number));
          pay_in_utils.trace('p_ee_comments',TO_CHAR (p_ee_comments));
          pay_in_utils.trace('p_er_comments',TO_CHAR (p_er_comments));
          pay_in_utils.trace('p_place_to',TO_CHAR (p_place_to));
          pay_in_utils.trace('p_travel_mode',TO_CHAR (p_travel_mode));
          pay_in_utils.trace('p_bill_amt',TO_CHAR (p_bill_amt));
          pay_in_utils.trace('p_exempt_amt',TO_CHAR (p_exempt_amt));
          pay_in_utils.trace('p_element_entry_id',TO_CHAR (p_element_entry_id));
          pay_in_utils.trace('p_start_date',TO_CHAR (p_start_date));
          pay_in_utils.trace('p_end_date',TO_CHAR (p_end_date));
          pay_in_utils.trace('p_carry_over_flag',TO_CHAR (p_carry_over_flag));
          pay_in_utils.trace('p_asg_extra_info_id',TO_CHAR(p_asg_extra_info_id));
          pay_in_utils.trace('p_element_entry_date',TO_CHAR(p_element_entry_date));
          pay_in_utils.trace('p_super_user',TO_CHAR(p_super_user));
          pay_in_utils.trace('p_person_id',TO_CHAR(p_person_id));

     END IF;




    IF p_super_user ='Y'
    THEN
        create_ltc_element
	(p_ltcblock                    => p_ltc_block
        ,p_place_from                  => p_place_from
        ,p_place_to                    => p_place_to
        ,p_mode_class                  => p_travel_mode
        ,p_carry_over                  => p_carry_over_flag
        ,p_submitted                   => p_bill_amt
        ,p_exempted                    => p_exempt_amt
        ,p_element_entry_id            => p_element_entry_id
        ,p_start_date                  => p_start_date
        ,p_end_date                    => p_end_date
        ,p_bill_num                    => p_bill_number
        ,p_ee_comments                 => p_ee_comments
        ,p_er_comments                 => p_er_comments
        ,p_last_updated_date           => ''
        ,p_assignment_id               => p_asg_id
        ,p_employee_id                 => 0
        ,p_assignment_extra_info_id    => p_asg_extra_info_id
        ,p_entry_date                  => p_element_entry_date
	,p_warnings                    => l_warnings
       );
    ELSE
     NULL;
    END IF;



 pay_in_utils.trace('l_warnings',l_warnings);

    pay_in_utils.trace('**************************************************','********************');
    pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,80);
    p_warnings := l_warnings;
 pay_in_utils.trace('p_warnings',p_warnings);

END ltc_bill_entry;





FUNCTION get_ltc_balance (p_asg_id IN NUMBER,
                          p_ltc_block  IN VARCHAR2,
  	                  p_balance_name IN VARCHAR2)
RETURN NUMBER
IS
CURSOR csr_ltc_run_result( p_asg_action_id IN NUMBER,
  	                       p_balance_type_id IN VARCHAR2)
IS
SELECT  sum(nvl(target.result_value,0) )
  FROM  pay_run_result_values   TARGET
         ,pay_balance_feeds_f     FEED
         ,pay_run_results         RR
         ,pay_assignment_actions  ASSACT
         ,pay_assignment_actions  BAL_ASSACT
         ,pay_payroll_actions     PACT
         ,pay_payroll_actions     BACT
         ,pay_input_values_f      piv
         ,pay_run_result_values   srcVal
        ,pay_input_values_f      srcInp
  where  BAL_ASSACT.assignment_action_id = p_asg_action_id
  AND    BAL_ASSACT.payroll_action_id = BACT.payroll_action_id
  AND    FEED.input_value_id     = TARGET.input_value_id
  AND    nvl(TARGET.result_value, '0') <> '0'
    AND    TARGET.run_result_id    = RR.run_result_id
  AND    RR.assignment_action_id = ASSACT.assignment_action_id
  AND    ASSACT.payroll_action_id = PACT.payroll_action_id
  AND    PACT.effective_date between
            FEED.effective_start_date AND FEED.effective_end_date
  AND    RR.status in ('P','PA')
  AND    ASSACT.action_sequence <= BAL_ASSACT.action_sequence
  AND    ASSACT.assignment_id = BAL_ASSACT.assignment_id
  AND  feed.input_value_id = piv.input_value_id
  AND  feed.balance_type_id = p_balance_type_id
  AND    srcVal.run_result_id    = RR.run_result_id
  AND    srcVal.result_value   = p_ltc_block
  AND    srcVal.input_value_id = srcInp.input_value_id
  AND    srcInp.name            = 'LTC Journey Block';




CURSOR csr_max_assact_id(p_asg_id IN NUMBER)
IS
 SELECT assignment_action_id
   FROM pay_assignment_actions paa,
        pay_payroll_actions ppa
  WHERE paa.assignment_id = p_asg_id
    AND paa.payroll_action_id = PPA.PAYROLL_ACTION_ID
    AND ppa.action_type in('R','Q','B','I')
    AND paa.source_action_id IS NOT NULL
    ORDER BY paa.action_sequence DESC;


CURSOR csr_balance_type_id(p_balance_name IN VARCHAR2) IS
SELECT balance_type_id
  FROM pay_balance_types pbt
 WHERE pbt.balance_name = p_balance_name
   AND legislation_code ='IN';


   l_balance_type_id  NUMBER;
   l_max_assact_id NUMBER;
   l_pay_value NUMBER;
   l_taxable_adjust NUMBER;
   l_emplr_contr NUMBER;
   p_value NUMBER;

BEGIN


   OPEN csr_balance_type_id('Earnings');
   FETCH csr_balance_type_id INTO l_balance_type_id ;
   CLOSE csr_balance_type_id;

   OPEN csr_max_assact_id(p_asg_id);
   FETCH csr_max_assact_id INTO l_max_assact_id;
   CLOSE csr_max_assact_id;



   IF l_max_assact_id IS NOT NULL THEN
     OPEN csr_ltc_run_result(l_max_assact_id,l_balance_type_id);
     FETCH csr_ltc_run_result  INTO l_pay_value;
     CLOSE csr_ltc_run_result;
   END IF;


   OPEN csr_balance_type_id('Salary under Section 17');
   FETCH csr_balance_type_id INTO l_balance_type_id ;
   CLOSE csr_balance_type_id;

   IF l_max_assact_id IS NOT NULL THEN
     OPEN csr_ltc_run_result(l_max_assact_id,l_balance_type_id);
     FETCH csr_ltc_run_result  INTO l_taxable_adjust;
     CLOSE csr_ltc_run_result;
   END IF;


   OPEN csr_balance_type_id('Employer Contribution for LTC');
   FETCH csr_balance_type_id INTO l_balance_type_id ;
   CLOSE csr_balance_type_id;

   IF l_max_assact_id IS NOT NULL THEN
    OPEN csr_ltc_run_result(l_max_assact_id,l_balance_type_id);
    FETCH csr_ltc_run_result  INTO l_emplr_contr;
    CLOSE csr_ltc_run_result;
   END IF;

   IF (p_balance_name = 'Salary under Section 17') THEN
     p_value := nvl(l_emplr_contr,0) - (nvl(l_pay_value,0) - nvl(l_taxable_adjust,0));
   ELSE
     p_value := nvl(l_emplr_contr,0);
   END IF;
   if(p_value = 0) then
   return 0;
   end if;
   RETURN p_value;

END get_ltc_balance;


 FUNCTION get_medical_balance( p_asg_id IN NUMBER,
                               p_tax_year IN VARCHAR2,
			       p_balance_name IN VARCHAR2)
 RETURN NUMBER IS
 CURSOR csr_get_max_assact(p_year_start  DATE
                         ,p_year_end  DATE) IS
 SELECT assignment_action_id
   FROM pay_assignment_actions paa,
        pay_payroll_actions ppa
  WHERE paa.assignment_id = p_asg_id
    AND paa.payroll_action_id = PPA.PAYROLL_ACTION_ID
    AND ppa.action_type in('R','Q','B','I')
    AND ppa.effective_date BETWEEN p_year_start AND p_year_end
    AND paa.source_action_id IS NOT NULL
    ORDER BY paa.action_sequence DESC;

CURSOR csr_exists(p_year_start  DATE
                 ,p_year_end  DATE) IS
 SELECT assignment_action_id
   FROM pay_assignment_actions paa,
        pay_payroll_actions ppa
  WHERE paa.assignment_id = p_asg_id
    AND paa.payroll_action_id = PPA.PAYROLL_ACTION_ID
    AND ppa.action_type in('R','Q','B','I')
    AND ppa.effective_date BETWEEN p_year_start AND p_year_end
    AND paa.source_action_id IS NOT NULL
    and exists(select '1' from pay_run_results prr
                where source_id  in (select distinct(aei_information11)
		                       from per_assignment_extra_info
                                      where information_type ='PER_IN_MEDICAL_BILLS')
                  and prr.assignment_action_id = paa.assignment_action_id) ;

 CURSOR csr_defined_balance_id(p_balance_name  VARCHAR2,
                               p_dimension_name  VARCHAR2)
 IS
 SELECT pdb.defined_balance_id
       FROM   pay_defined_balances pdb
             ,pay_balance_types pbt
             ,pay_balance_dimensions pbd
       WHERE  pbt.balance_name =    p_balance_name
       AND    pbd.dimension_name =  p_dimension_name
       AND    pdb.balance_type_id = pbt.balance_type_id
       AND   pbt.legislation_code = 'IN'
       AND   pbd.legislation_code = 'IN'
       AND   pdb.legislation_code = 'IN'
       AND    pdb.balance_dimension_id = pbd.balance_dimension_id;


 l_max_assact_id NUMBER;
 l_defined_balance_id NUMBER;
 p_year_start DATE;
 p_year_end DATE;
 l_value NUMBER;


 BEGIN
  p_year_start := to_date('01-04-'||substr(p_tax_year,1,4),'DD-MM-YYYY');
  p_year_end := to_date('31-03-'||substr(p_tax_year,6,4),'DD-MM-YYYY');

  OPEN csr_exists(p_year_start,p_year_end);
  FETCH csr_exists INTO l_max_assact_id;
   IF csr_exists%NOTFOUND THEN
     l_value := 0;
     RETURN l_value;
   END IF;
  CLOSE csr_exists;

  OPEN csr_get_max_assact(p_year_start,p_year_end);
  FETCH csr_get_max_assact INTO l_max_assact_id;
  CLOSE csr_get_max_assact;

  l_value := 0;



    OPEN csr_defined_balance_id('Medical Reimbursement Amount','_ASG_YTD');
    FETCH csr_defined_balance_id INTO l_defined_balance_id;
    CLOSE csr_defined_balance_id;

      l_value := pay_balance_pkg.get_value(l_defined_balance_id,l_max_assact_id);

    IF (p_balance_name = 'Medical Reimbursement Amount') THEN
      if (l_value = 0) then
       return 0;
      else
      RETURN l_value;
      end if;
    ELSE
      OPEN csr_defined_balance_id('Salary under Section 17','_ASG_COMP_PTD');
      FETCH csr_defined_balance_id INTO l_defined_balance_id;
      CLOSE csr_defined_balance_id;


      l_value := l_value +  pay_balance_pkg.get_value(p_defined_balance_id  => l_defined_balance_id,
                                       p_assignment_Action_id => l_max_assact_id,
				       p_tax_unit_id          => null,
                                       p_jurisdiction_code    => null,
                                       p_source_id            => null,
                                       p_source_text          => null,
                                       p_tax_group            => null,
                                       p_date_earned          => null,
                                       p_get_rr_route         => null,
                                       p_get_rb_route         => null,
				       p_source_text2         =>'Employees Welfare Expense');
     RETURN l_value;
  END IF;

--  l_value := pay_balance_pkg.get_value(l_defined_balance_id,l_max_assact_id)

  RETURN l_value;
 END get_medical_balance;


PROCEDURE is_locked( p_person_id  IN  NUMBER
                    ,p_ltc_or_med IN VARCHAR2
                    ,p_locked     OUT NOCOPY VARCHAR2 )
IS

    CURSOR lock_dtls
    IS
    SELECT NVL(DECODE(p_ltc_or_med,'LTC',org_information1,'MED',org_information2),'N') lock_flag
    FROM
    hr_organization_information org
    ,per_people_f person
    WHERE
    org.org_information_context = 'PER_IN_BENEFITS_DECL_INFO'
    AND org.organization_id = person.business_group_id
    AND person.person_id = p_person_id
    AND SYSDATE BETWEEN person.effective_start_date
                    AND person.effective_end_date ;

   l_proc VARCHAR2(120);
   l_procedure   VARCHAR(100);
   l_message     VARCHAR2(250);
   --
BEGIN
   --
    l_procedure := g_package || 'is_locked';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('p_person_id',p_person_id);
      pay_in_utils.trace('**************************************************','********************');
    END IF;
    p_locked := 'N';
   --

   --
   OPEN  lock_dtls;
   FETCH lock_dtls INTO p_locked;
   CLOSE lock_dtls;
   --
   pay_in_utils.set_location(g_debug, l_proc, 20);
   --


    IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('p_locked ',p_locked);
      pay_in_utils.trace('**************************************************','********************');
    END IF;

   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);

   --

END is_locked;


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
,p_warnings                 OUT NOCOPY VARCHAR2
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

p_warnings := 'TRUE';
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

     BEGIN
         SELECT 1 INTO l_session FROM fnd_sessions WHERE SESSION_ID = USERENV('SESSIONID') AND ROWNUM=1;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         INSERT INTO fnd_sessions(session_id,effective_date) VALUES (USERENV('SESSIONID'),p_start_date);
     END ;

     l_business_group_id :=  pay_in_med_web_adi.get_bg_id();

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

p_warnings := 'FALSE';
    pay_in_utils.trace('**************************************************','********************');
    pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);
EXCEPTION
   WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg
         (p_pkg_name => g_package
         ,p_procedure_name => 'update_ltc_element'
         ,p_error_text => substr(sqlerrm, 1, 240)
         );


END update_ltc_element;

END pay_in_india_benefits;

/
