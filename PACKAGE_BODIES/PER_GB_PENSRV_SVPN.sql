--------------------------------------------------------
--  DDL for Package Body PER_GB_PENSRV_SVPN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_GB_PENSRV_SVPN" AS
/* $Header: pegbasgp.pkb 120.2.12010000.3 2008/11/07 11:31:08 npannamp ship $ */

--Globals
gv_package_name       VARCHAR2(100);
g_svpn_flag          VARCHAR2(4);

-- This procedure is used to calculate service period numbers.
-- ----------------------------------------------------------------------------
-- |-------------------------< derive_svpn >--------------------------|
-- ----------------------------------------------------------------------------

PROCEDURE create_gb_spn(p_assignment_id IN NUMBER,
                        p_effective_date IN DATE)

IS
-- local variables

l_procedure_name         VARCHAR2(100);
l_ass_attribute_category VARCHAR2(300);
l_column_name            VARCHAR2(30);
l_pvc_information2       VARCHAR2(30);
l_bg_id                  NUMBER;
l_query                  VARCHAR2(1000);
l_value                  VARCHAR2(30);
l_spn                    NUMBER;
l_assignment_extra_info_id NUMBER;
l_object_version_number    NUMBER;
g_assignment_id            NUMBER;
g_effective_date           DATE;
l_ni_number                VARCHAR2(30);
l_pri_flag                 VARCHAR2(4);


TYPE base_table_ref_csr_typ IS REF CURSOR;
c_base_table        base_table_ref_csr_typ;

-- Cursor to fetch the business_group_id

  CURSOR get_bg_id(c_assignment_id NUMBER,
                  c_effective_date DATE)
  IS
  SELECT business_group_id
  FROM   per_all_assignments_f
  WHERE  assignment_id = c_assignment_id
  AND    c_effective_date BETWEEN effective_start_date AND effective_end_date;


-- Cursor to fetch the columns name agaist which the Pension scheme is configured

  CURSOR get_penserv_config(c_business_group_id NUMBER)
  IS
  SELECT pcv_information1,pcv_information2
  FROM   pqp_configuration_values pcv,
         pqp_configuration_types pct
  WHERE  pcv.pcv_information_category = pct.configuration_type
  AND    pct.configuration_type = 'PQP_GB_PENSERVER_ELIGBLTY_CONF'
  AND    pcv.business_group_id = c_business_group_id;

-- Cursor to check if emp is elegible for spn calculation
-- if SPN already exist, no calculation required*/

  CURSOR cur_get_eit_info(c_assignment_id NUMBER)
  IS
  SELECT aei_information1
  FROM   per_assignment_Extra_info
  WHERE  assignment_id = c_assignment_id
  AND    aei_information_category = 'PQP_GB_PENSERV_SVPN';

-- Cursor to fetch maximum service period number

  CURSOR cur_get_svpn(c_ni_number VARCHAR2)
  IS
  SELECT max(to_number(paei.aei_information1))+1
  FROM  per_all_people_f papf,
        per_all_assignments_f paaf,
        per_assignment_extra_info paei
  WHERE papf.NATIONAL_IDENTIFIER = c_ni_number
  AND   papf.person_id = paaf.person_id
  AND   paei.assignment_id = paaf.assignment_id
  AND   paei.aei_information_category = 'PQP_GB_PENSERV_SVPN';

-- Cursor to fetch NI number for the give assignment
  CURSOR cur_get_NI_number(c_assignment_id NUMBER,
                           c_effective_date DATE)
  IS
  SELECT papf1.NATIONAL_IDENTIFIER
  FROM  per_all_people_f papf1,
        per_all_assignments_f paaf1
  WHERE paaf1.assignment_id = c_assignment_id
  AND   c_effective_date BETWEEN paaf1.effective_start_date AND paaf1.effective_end_date
  AND   papf1.person_id = paaf1.person_id
  AND   c_effective_date BETWEEN papf1.effective_start_date AND papf1.effective_end_date;

-- Cursor to fetch Matain service period number flag

  CURSOR csr_svpn_maintain_flag(c_business_group_id NUMBER)
  IS
  SELECT pcv_information4
  FROM  pqp_configuration_values pcv,
        pqp_configuration_types pct
  WHERE pcv.pcv_information_category = pct.configuration_type
  AND   pct.configuration_type = 'PQP_GB_PENSERVER_PAYPOINT_INFO'
  AND   pcv.business_group_id = c_business_group_id;

  -- Cursor to fetch assignment details (Primary or not)
  CURSOR csr_get_asg_detials(c_assignment_id NUMBER,
                           c_effective_date DATE)
  IS
  SELECT paaf.primary_flag
  FROM  per_all_assignments_f paaf
  WHERE paaf.assignment_id = c_assignment_id
  AND   c_effective_date BETWEEN paaf.effective_start_date AND paaf.effective_end_date;

BEGIN

    l_procedure_name := '.create_gb_spn';
    g_assignment_id   :=  p_assignment_id;
    g_effective_date  :=  p_effective_date;

    hr_utility.set_location('attrbute_category is :'||l_ass_attribute_category, 10);
    hr_utility.set_location('g_assignment_id is :'||g_assignment_id, 20);
    hr_utility.set_location('g_effective_date is :'||g_effective_date, 30);

    -- fetching primary assignment details
    OPEN csr_get_asg_detials(g_assignment_id,g_effective_date);
    FETCH csr_get_asg_detials INTO l_pri_flag;
    CLOSE csr_get_asg_detials;



    -- if the assignment is primary assignment then proceed
    IF l_pri_flag = 'Y' THEN
    -- fetching business groupid
    OPEN get_bg_id(g_assignment_id,g_effective_date);
    FETCH get_bg_id INTO l_bg_id;
    CLOSE get_bg_id;

/* Start Bug 7132727 */
    OPEN get_penserv_config(l_bg_id);
    FETCH get_penserv_config INTO l_ass_attribute_category,
                                     l_column_name;
    CLOSE get_penserv_config;

    IF l_ass_attribute_category is not null
    then

  /* End Bug 7132727 */

    -- fetching Maintaion service period flag
    OPEN csr_svpn_maintain_flag(l_bg_id);
    FETCH csr_svpn_maintain_flag INTO g_svpn_flag;
    CLOSE csr_svpn_maintain_flag;

     hr_utility.set_location(' l_bg_id :'||l_bg_id,40);
     hr_utility.set_location('g_svpn_flag'||g_svpn_flag,45);

     IF g_svpn_flag = 'Yes' THEN


       -- Query to fetch configured value for the assignment.
       l_query :=   'select '||l_column_name||' '||
                    'from per_all_assignments_f'||' '||
                    'where business_group_id = '||l_bg_id||' '||
                    'and assignment_id = '||g_assignment_id||' ';
       IF l_ass_attribute_category <> 'Global Data Elements' THEN
            l_query := l_query||
                   'and ASS_ATTRIBUTE_CATEGORY = '''||l_ass_attribute_category||''''||' ';
       END IF;

       l_query := l_query||
                    'and to_date('''||TO_CHAR(g_effective_date,'dd/mm/yyyy')||''',''dd/mm/yyyy'')  between effective_start_date'||' '||
                   'and effective_end_date';

       hr_utility.set_location('l_query: '||l_query,50);

       -- fetch the value of from the column name
       OPEN c_base_table FOR l_query;
       FETCH c_base_table INTO l_value;
       CLOSE c_base_table;

       IF l_value IS NULL THEN
         hr_utility.set_location('value is NULL :', 60);
         hr_utility.set_location(' l_value'||l_value,70);
         NULL;
       ELSE
         hr_utility.set_location('attribute value is not NULL :', 80);
         hr_utility.set_location(' l_value'||l_value,90);

        -- fetch EIT information
         OPEN cur_get_eit_info(c_assignment_id => g_assignment_id);
         FETCH cur_get_eit_info INTO l_spn;
         CLOSE cur_get_eit_info;

         hr_utility.set_location(' spn value :'||l_spn, 100);

         -- Check whether service period number is null or not

         IF l_spn IS NULL THEN
           OPEN cur_get_NI_number(g_assignment_id,g_effective_date);
       	   FETCH cur_get_NI_number INTO l_ni_number;
	       CLOSE cur_get_NI_number;

	   -- Checking whether NI number is null or not
           IF l_ni_number IS NOT NULL
	   AND UPPER(SUBSTR(l_ni_number,1,2)) <> 'TN' THEN

         	 OPEN cur_get_svpn(l_ni_number);
        	 FETCH cur_get_svpn INTO l_spn;
                 CLOSE cur_get_svpn;
        	 hr_utility.set_location(' l_spn value :'||l_spn, 105);
        	 IF l_spn IS null THEN
        	   l_spn := 1;
                 END IF;
                 -- Inserting the service period number
	         HR_ASSIGNMENT_EXTRA_INFO_API.create_assignment_extra_info(p_assignment_id   => g_assignment_id
                                                             ,p_information_type         => 'PQP_GB_PENSERV_SVPN'
                                                             ,p_aei_information_category => 'PQP_GB_PENSERV_SVPN'
                                                             ,p_aei_information1         => lpad(l_spn,2,'0')
                                                             ,p_assignment_extra_info_id => l_assignment_extra_info_id
                                                             ,p_object_version_number    => l_object_version_number);
             hr_utility.set_location(' inserted successfully :'||l_spn, 100);
             END IF;
          ELSE
            hr_utility.set_location(' Spn calculation not required :',110);
          END IF;
       END IF;
     ELSE
          fnd_file.put_line(fnd_file.log,'Maitain Service Period No. is not set to "Yes" for the configuration PAYPOINT and CUTOVER INFORMATION
and hence service period number will not be populated for this assignment');
 END IF;
/* Start Bug 7132727 */
else
NULL;
end if;
/* End Bug 7132727 */
 END IF;
  fnd_file.put_line(fnd_file.log,'Leaving ' || gv_package_name || l_procedure_name);

END create_gb_spn;


-- ----------------------------------------------------------------------------
-- Bug #7307266. FTE Calculation logic is available in PUI through PQH_GEN.pld
-- The same code is moved here so that SSHR can also access this.
-- This procedure is used to calculate FTE.
-- |-------------------------< auto calc FTE >--------------------------|
-- ----------------------------------------------------------------------------

procedure AUTO_CALC_FTE (p_assignment_id in Number,
                         P_EFFECTIVE_START_DATE in Date)
IS
    l_business_group_id     pqp_configuration_values.business_group_id%TYPE;
    l_legislation_code      pqp_configuration_values.legislation_code%TYPE;
    l_abv_uom               pqp_configuration_values.pcv_information1%TYPE;
    l_assignment_id         per_all_assignments_f.assignment_id%TYPE;
    l_effective_start_date  per_all_assignments_f.effective_start_date%TYPE;
    l_assignment_type       varchar2(30);

    -- added by akarmaka for the BUG:5047827
    l_contract_type_exist     NUMBER;
    l_fte_exist               NUMBER;

    l_error_message         fnd_new_messages.message_text%TYPE;
    g_debug boolean := true;

    -- Pick up only those UOMS which are enabled and have some
    -- process defnition. There is no validation as yet on the configuration
    -- which prevents the user from storing just one, however subsequent
    -- processing cannot take place without both.
    CURSOR csr_abvm_uoms_to_process
      (p_business_group_id       IN     NUMBER
      ,p_legislation_code        IN     VARCHAR2
      ) IS
    SELECT mtn.configuration_value_id
          ,mtn.configuration_name
          ,mtn.business_group_id
          ,mtn.legislation_code
          ,mtn.pcv_information1               uom
          ,mtn.pcv_information2               is_enabled
          ,def.configuration_value_id         defn_config_value_id
          ,def.configuration_name             defn_config_name
          ,def.business_group_id              defn_bg_id
          ,def.legislation_code               defn_leg_code
          ,def.pcv_information4               defn_custom_function
    FROM   pqp_configuration_values  mtn
          ,pqp_configuration_values  def
    WHERE  mtn.pcv_information_category = 'PQP_ABVM_MAINTENANCE'
      AND  def.pcv_information_category = 'PQP_ABVM_DEFINITION'
      AND  def.pcv_information1 = mtn.pcv_information1
      AND  mtn.pcv_information2 = 'Y'
      AND  ( mtn.business_group_id = p_business_group_id
            OR
             ( ( mtn.business_group_id IS NULL AND mtn.legislation_code = p_legislation_code )
              AND -- there does not exist a config for this UOM at bg level
               NOT EXISTS
               (SELECT 1
                FROM   pqp_configuration_values bgmtn
                WHERE  bgmtn.pcv_information_category = 'PQP_ABVM_MAINTENANCE'
                  AND  bgmtn.pcv_information1 = mtn.pcv_information1
                  AND  bgmtn.business_group_id = p_business_group_id
               ) -- NOT EXISTS
             ) -- OR
            OR
             ( ( mtn.business_group_id IS NULL AND mtn.legislation_code IS NULL )
              AND -- there does not exist a config for this UOM at a higher level
               NOT EXISTS
               (SELECT 1
                FROM   pqp_configuration_values hlmtn
                WHERE  hlmtn.pcv_information_category = 'PQP_ABVM_MAINTENANCE'
                  AND  hlmtn.pcv_information1 = mtn.pcv_information1
                  AND  ( hlmtn.business_group_id = p_business_group_id
                        OR
                         hlmtn.legislation_code = p_legislation_code
                       )
               ) -- NOT EXISTS
             ) -- OR
           ) -- AND
      AND  ( def.business_group_id = p_business_group_id
            OR
             def.business_group_id IS NULL AND def.legislation_code = p_legislation_code
            OR
             def.business_group_id IS NULL AND def.legislation_code IS NULL
           );

  -- check to find if the contract type is ever attached to this person's assignment
  CURSOR  csr_chk_asg_contract_exist( p_assignment_id IN NUMBER)
  IS
  SELECT 1
    FROM pqp_assignment_attributes_f
   WHERE assignment_id = p_assignment_id
     AND contract_type is NOT NULL
     AND  rownum < 2;

-- chk to find if an FTE row exist for the Assignment
   CURSOR  csr_chk_asg_abv_exist(p_assignment_id  IN  NUMBER
				,p_uom            IN  VARCHAR2)
   IS
   SELECT 1
   FROM per_assignment_budget_values_f
   WHERE ASSIGNMENT_ID = p_assignment_id
   and unit = p_uom ;

-- fetch assignment_type and business_group_id. Added newly for 7307266.
   CURSOR  get_ass_typ_bus_grp_id(p_assignment_id  IN  NUMBER,
                                  p_effective_date in Date)
   IS
   select assignment_type, business_group_id
   from per_all_assignments_f
   where assignment_id = p_assignment_id
   and p_effective_date between effective_start_date and effective_end_date ;

 BEGIN --Begin Procedure

-- Added for BUG: 5287675
  IF g_debug is null THEN
     g_debug := hr_utility.debug_enabled;
  END IF;
-- Addition ends for BUG: 5287675
-- hr_utility.trace_on(null,'FTE');
 hr_utility.trace('Entering '||gv_package_name||'.AUTO_CALC_FTE');
 hr_utility.trace('p_assignment_id :'||p_assignment_id);
 hr_utility.trace('P_EFFECTIVE_START_DATE :'||P_EFFECTIVE_START_DATE);

 BEGIN
 l_assignment_id := p_assignment_id;
 l_effective_start_date := P_EFFECTIVE_START_DATE;

 l_legislation_code := PER_ASG_BUS1.return_legislation_code(P_ASSIGNMENT_ID => P_ASSIGNMENT_ID);

 --fetch bus_grp_id and asgn_type
 open get_ass_typ_bus_grp_id(p_assignment_id => l_assignment_id, p_effective_date => l_effective_start_date);
 fetch get_ass_typ_bus_grp_id into l_assignment_type, l_business_group_id;
 close get_ass_typ_bus_grp_id;

 hr_utility.trace('l_business_group_id :'||l_business_group_id);
 hr_utility.trace('l_assignment_type :'||l_assignment_type);
 hr_utility.trace('l_legislation_code :'||l_legislation_code);


       IF (l_assignment_id IS NOT NULL AND l_assignment_type  = 'E')
       THEN

       --
       -- This code will attempt to update the FTE value for
       -- an assignment. It is within its own block because we don't
       -- want to rollback the update to the assignment in the event that
       -- the FTE processing fails for some reason.
            hr_utility.trace('Inside '||gv_package_name||'.AUTO_CALC_FTE'||
                               l_assignment_id||' on '||
                               fnd_date.date_to_canonical(l_effective_start_date)
                             );
          FOR this_abvm IN csr_abvm_uoms_to_process
             (p_business_group_id => l_business_group_id
             ,p_legislation_code => l_legislation_code
             )
          LOOP

            IF g_debug THEN                             -- BUG: 5287675
              hr_utility.trace('AUTO_CALC_FTE this_abvm.configuration_value_id:'||this_abvm.configuration_value_id);
              hr_utility.trace('AUTO_CALC_FTE this_abvm.configuration_name:'||this_abvm.configuration_name);
              hr_utility.trace('AUTO_CALC_FTE this_abvm.business_group_id:'||this_abvm.business_group_id);
              hr_utility.trace('AUTO_CALC_FTE this_abvm.legislation_code:'||this_abvm.legislation_code);
              hr_utility.trace('AUTO_CALC_FTE this_abvm.uom:'||this_abvm.uom);
              hr_utility.trace('AUTO_CALC_FTE this_abvm.is_enabled:'||this_abvm.is_enabled);
              hr_utility.trace('AUTO_CALC_FTE this_abvm.defn_config_value_id:'||this_abvm.defn_config_value_id);
              hr_utility.trace('AUTO_CALC_FTE this_abvm.defn_config_name:'||this_abvm.defn_config_name);
              hr_utility.trace('AUTO_CALC_FTE this_abvm.defn_bg_id:'||this_abvm.defn_bg_id);
              hr_utility.trace('AUTO_CALC_FTE this_abvm.defn_leg_code:'||this_abvm.defn_leg_code);
              hr_utility.trace('AUTO_CALC_FTE this_abvm.defn_custom_function:'||this_abvm.defn_custom_function);
            END IF;


            l_abv_uom := this_abvm.uom;

             -- the condition below also checks for this_abvm.defn_custom_function IS NOT NULL implicitly
            IF ( this_abvm.defn_custom_function = 'pqp_budget_maintenance.get_FTE_event_dates' )
            THEN


              OPEN csr_chk_asg_contract_exist (p_assignment_id  => l_assignment_id );
              FETCH csr_chk_asg_contract_exist INTO l_contract_type_exist;
              CLOSE csr_chk_asg_contract_exist ;


              OPEN csr_chk_asg_abv_exist (p_assignment_id      => l_assignment_id
					  ,p_uom                =>  l_abv_uom);
              FETCH csr_chk_asg_abv_exist INTO l_fte_exist ;
              CLOSE csr_chk_asg_abv_exist ;

              IF g_debug THEN                         -- BUG: 5287675
                IF l_contract_type_exist IS NOT NULL THEN
                  hr_utility.trace('l_contract_type_exist: TRUE');
                ELSE
                  hr_utility.trace('l_contract_type_exist: FALSE');
                END IF;
                IF l_fte_exist IS NOT NULL THEN
                  hr_utility.trace('l_fte_exist: TRUE');
                ELSE
                    hr_utility.trace('l_fte_exist: FALSE');
                END IF;
              END IF;

              IF (l_contract_type_exist IS NOT NULL  OR  l_fte_exist IS NOT NULL )
              THEN

                pqp_budget_maintenance.maintain_abv_for_assignment
                (p_uom               => this_abvm.uom
                ,p_assignment_id     => l_assignment_id
                ,p_business_group_id => l_business_group_id
                ,p_effective_date    => l_effective_start_date
                ,p_action            => 'Normal'
                );
              END IF;

            ELSE  --  IF this_abvm.defn_custom_function != 'pqp_budget_maintenance.get_FTE_event_dates'


              pqp_budget_maintenance.maintain_abv_for_assignment
                (p_uom               => this_abvm.uom
                ,p_assignment_id     => l_assignment_id
                ,p_business_group_id => l_business_group_id
                ,p_effective_date    => l_effective_start_date
                ,p_action            => 'Normal'
                );

            END IF; -- IF ( this_abvm.business_group_id IS NULL AND this_abvm.legislation_code = 'GB' )

         END LOOP; -- FOR this_abvm IN csr_abvm_uoms_to_process

         IF g_debug THEN                      -- BUG: 5287675
           hr_utility.trace('Leaving '||gv_package_name||'.AUTO_CALC_FTE'||' for '||
                            l_assignment_id||' on '||
                            fnd_date.date_to_canonical(l_effective_start_date)
                           );
         END IF;
      END IF; -- IF (l_assignment_id IS NOT NULL AND l_assignment_type  = 'E')

      END;
      EXCEPTION
      WHEN OTHERS THEN
        hr_utility.trace('Error in '||gv_package_name||'.AUTO_CALC_FTE'||'  for '||
                             l_assignment_id||' on '||
                             fnd_date.date_to_canonical(l_effective_start_date)
                          );
        --fnd_message.RETRIEVE;
        l_error_message := fnd_message.get;
        l_error_message := NVL(RTRIM(LTRIM(l_error_message)),'SQLERRM:'||SQLERRM);
        IF g_debug THEN                              -- BUG: 5287675
          hr_utility.trace(gv_package_name||'.AUTO_CALC_FTE : Error msg '||l_error_message);
        END IF;
        hr_utility.set_message(8303,'PQP_230514_FTE_FAILURE');
        fnd_message.set_token('ABVUOM',l_abv_uom);
        fnd_message.set_token('ERRORMSG',l_error_message);
        hr_utility.set_warning;


END AUTO_CALC_FTE;

BEGIN
 gv_package_name := 'per_gb_pensrv_svpn';
END per_gb_pensrv_svpn;


/
