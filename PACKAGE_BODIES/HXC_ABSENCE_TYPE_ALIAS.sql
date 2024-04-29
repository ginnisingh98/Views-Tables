--------------------------------------------------------
--  DDL for Package Body HXC_ABSENCE_TYPE_ALIAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_ABSENCE_TYPE_ALIAS" AS
/* $Header: hxcabstypealias.pkb 120.0.12010000.9 2010/01/07 13:55:51 amakrish noship $ */

g_package varchar2(30) 	:= 'hxc_absence_type_alias.';
g_debug BOOLEAN 	:= hr_utility.debug_enabled;

PROCEDURE ins_otl_abs_type_elements_temp(p_tc_abs_type_alias_def_id IN hxc_alias_definitions_tl.alias_definition_id%TYPE,
                                         p_tc_abs_payroll_id        IN pay_payrolls_f.payroll_id%TYPE,
                                         p_tc_abs_element_set_id    IN pay_element_sets_tl.element_set_id%TYPE,
                                         p_tc_abs_absence_type_id   IN per_abs_attendance_types_tl.absence_attendance_type_id%TYPE) IS
PRAGMA AUTONOMOUS_TRANSACTION;

l_tc_abs_type_alias_def_id 	hxc_alias_definitions_tl.alias_definition_id%TYPE;
l_tc_abs_payroll_id 		pay_payrolls_f.payroll_id%TYPE;
l_tc_abs_element_set_id 	pay_element_sets_tl.element_set_id%TYPE;
l_tc_abs_absence_type_id 	per_abs_attendance_types_tl.absence_attendance_type_id%TYPE;

l_proc 				VARCHAR2(100);

BEGIN

  g_debug := hr_utility.debug_enabled;

  IF g_debug THEN
     l_proc := g_package||'ins_otl_abs_type_elements_temp';
     hr_utility.set_location('ABS:Processing '||l_proc, 10);
  END IF;

  l_tc_abs_type_alias_def_id := p_tc_abs_type_alias_def_id;
  l_tc_abs_payroll_id 	     := p_tc_abs_payroll_id;
  l_tc_abs_element_set_id    := p_tc_abs_element_set_id;
  l_tc_abs_absence_type_id   := p_tc_abs_absence_type_id;


  IF g_debug THEN
     hr_utility.trace('ABS:l_tc_abs_type_alias_def_id ::'||l_tc_abs_type_alias_def_id);
     hr_utility.trace('ABS:l_tc_abs_payroll_id ::'||l_tc_abs_payroll_id);
     hr_utility.trace('ABS:l_tc_abs_element_set_id ::'||l_tc_abs_element_set_id);
     hr_utility.trace('ABS:l_tc_abs_absence_type_id ::'||l_tc_abs_absence_type_id);
  END IF;


  DELETE FROM hxc_absence_type_elements_temp;

  INSERT INTO hxc_absence_type_elements_temp
    (absence_attendance_type_id
    ,absence_attendance_type_name
    ,element_type_id
    ,element_name
    ,uom
    ,alias_value_name
    ,absence_category
    ,absence_category_meaning
    )
    (SELECT /*+ ORDERED */
           paatt.absence_attendance_type_id,
    	   paatt.name,
    	   petft.element_type_id,
    	   petft.element_name,
    	   hae.uom,
    	   paatt.name || ' (' || ntl.meaning || ')',
    	   acl.lookup_code absence_category,
    	   acl.meaning absence_category_meaning
     FROM hxc_absence_type_elements hae,
     	  per_absence_attendance_types paat,
     	  per_abs_attendance_types_tl paatt,
     	  pay_element_types_f    petf,
     	  pay_element_types_f_tl petft,
     	  hr_lookups ntl, -- NAME_TRANSLATIONS
     	  hr_lookups acl  -- ABSENCE_CATEGORY
    WHERE hae.absence_attendance_type_id   = paat.absence_attendance_type_id
      AND hae.element_type_id 		   = petf.element_type_id
      AND ntl.lookup_type                  = 'NAME_TRANSLATIONS'
      AND ntl.lookup_code                  = hae.uom
      AND acl.lookup_type(+)               = 'ABSENCE_CATEGORY'
      AND acl.lookup_code(+)               = hae.absence_category
      AND paatt.LANGUAGE                   = petft.LANGUAGE
      AND paatt.LANGUAGE                   = userenv('LANG')
      AND paatt.absence_attendance_type_id = paat.absence_attendance_type_id
      AND petft.element_type_id	           = petf.element_type_id
      AND paat.business_group_id           = petf.business_group_id
      AND paat.business_group_id           = fnd_profile.value('PER_BUSINESS_GROUP_ID'));

  IF g_debug THEN
     hr_utility.set_location('ABS:Processing '||l_proc, 20);
  END IF;


  IF l_tc_abs_type_alias_def_id IS NOT NULL THEN

    DELETE hxc_absence_type_elements_temp haet
    WHERE to_char(haet.element_type_id) NOT IN
      (SELECT hav.attribute1
         FROM hxc_alias_definitions_tl hadt,
              hxc_alias_definitions had,
              hxc_alias_values hav
        WHERE had.alias_context_code = 'PAYROLL_ELEMENTS'
          AND hadt.alias_definition_id = had.alias_definition_id
          AND hadt.alias_definition_id = hav.alias_definition_id
          AND hadt.alias_definition_id = l_tc_abs_type_alias_def_id
          AND hadt.LANGUAGE = userenv('LANG'));

  END IF;

  IF g_debug THEN
     hr_utility.set_location('ABS:Processing '||l_proc, 30);
  END IF;

  IF l_tc_abs_payroll_id IS NOT NULL THEN

    DELETE hxc_absence_type_elements_temp haet
    WHERE haet.element_type_id NOT IN
      (SELECT pelf.element_type_id
         FROM pay_payrolls_f papf,
              pay_element_links_f pelf
        WHERE papf.payroll_id = pelf.payroll_id
          AND papf.payroll_id = l_tc_abs_payroll_id);

  END IF;

  IF l_tc_abs_element_set_id IS NOT NULL THEN

    DELETE hxc_absence_type_elements_temp haet
    WHERE haet.element_type_id NOT IN
      (SELECT petr.element_type_id
         FROM pay_element_sets_tl pest,
              pay_element_sets pes,
              pay_element_type_rules petr
        WHERE pest.element_set_id = pes.element_set_id
          AND pes.element_set_id = petr.element_set_id
          AND pes.element_set_id = l_tc_abs_element_set_id
          AND pes.element_set_type = 'R'
          AND LANGUAGE = userenv('LANG'));

  END IF;

  IF g_debug THEN
     hr_utility.set_location('ABS:Processing '||l_proc, 40);
  END IF;

  IF l_tc_abs_absence_type_id IS NOT NULL THEN

    DELETE hxc_absence_type_elements_temp haet
    WHERE haet.element_type_id NOT IN
      (SELECT pivf.element_type_id
         FROM per_abs_attendance_types_tl paatt,
              per_absence_attendance_types paat,
              pay_input_values_f pivf
        WHERE paatt.absence_attendance_type_id = paat.absence_attendance_type_id
          AND paat.absence_attendance_type_id = l_tc_abs_absence_type_id
          AND paat.input_value_id = pivf.input_value_id
          AND paatt.LANGUAGE = userenv('LANG'));

  END IF;

  IF g_debug THEN
     hr_utility.set_location('ABS:Processing '||l_proc, 50);
  END IF;


  COMMIT;

END ins_otl_abs_type_elements_temp;

PROCEDURE create_alias_definition(p_alias_definition_id          OUT nocopy NUMBER,
                                  p_alias_definition_name        IN VARCHAR2,
                                  p_object_version_number        OUT nocopy NUMBER,
                                  p_alias_definition_name_exists OUT nocopy VARCHAR2) IS

l_alias_definition_id     hxc_alias_definitions.ALIAS_DEFINITION_ID%type;
l_alias_definition_id_ovn hxc_alias_definitions.OBJECT_VERSION_NUMBER%type;
l_alias_type_id           hxc_alias_definitions.ALIAS_TYPE_ID%type;
l_alias_definition_name   hxc_alias_definitions.ALIAS_DEFINITION_NAME%type;

l_exists                  VARCHAR2(1) := 'N';
l_messages                hxc_message_table_type;

l_proc 			  VARCHAR2(100);

BEGIN

  g_debug := hr_utility.debug_enabled;

  IF g_debug THEN
     l_proc := g_package||'create_alias_definition';
     hr_utility.set_location('ABS:Processing '||l_proc, 10);
  END IF;

  l_alias_definition_name := p_alias_definition_name;

  IF g_debug THEN
     hr_utility.trace('ABS:l_alias_definition_name ::'||l_alias_definition_name);
  END IF;

  SELECT  alias_type_id
    INTO  l_alias_type_id
    FROM  hxc_alias_types
   WHERE  alias_type = 'OTL_ALT_DDF'
     AND  reference_object = 'PAYROLL_ELEMENTS';

  IF g_debug THEN
     hr_utility.set_location('ABS:Processing '||l_proc, 20);
     hr_utility.trace('ABS:l_alias_type_id ::'||l_alias_type_id);
  END IF;

  BEGIN

    SELECT 'Y'
      INTO l_exists
      FROM hxc_alias_definitions_tl
     WHERE alias_definition_name = l_alias_definition_name
       AND LANGUAGE = userenv('LANG');

    IF g_debug THEN
       hr_utility.set_location('ABS:Processing '||l_proc, 30);
    END IF;


  EXCEPTION

    WHEN NO_DATA_FOUND THEN

      IF g_debug THEN
         hr_utility.set_location('ABS:Processing '||l_proc, 40);
         hr_utility.trace('ABS:Calling hxc_alias_definitions_api.create_alias_definition procedure.');
      END IF;

      l_exists := 'N';
      hxc_alias_definitions_api.create_alias_definition(p_alias_definition_id => p_alias_definition_id,
                                                  p_alias_definition_name     => l_alias_definition_name,
                                                  p_alias_context_code        => 'PAYROLL_ELEMENTS',
                                                  p_timecard_field            => NULL,
                                                  p_object_version_number     => p_object_version_number,
                                                  p_alias_type_id             => l_alias_type_id,
                                                  p_business_group_id         => fnd_profile.VALUE('PER_BUSINESS_GROUP_ID'),
                                                  p_prompt                    => 'Hours Type'
                                                  );

      IF g_debug THEN
         hr_utility.trace('ABS:End of hxc_alias_definitions_api.create_alias_definition procedure.');
         hr_utility.set_location('ABS:Processing '||l_proc, 50);
      END IF;

  END;

  p_alias_definition_name_exists := l_exists;

  IF g_debug THEN
     hr_utility.trace('ABS:p_alias_definition_name_exists ::'||p_alias_definition_name_exists);
     hr_utility.set_location('ABS:Processing '||l_proc, 60);
  END IF;

END create_alias_definition;

PROCEDURE create_alias_value(p_alias_value_name        IN VARCHAR2,
                             p_alias_definition_id     IN NUMBER,
                             p_attribute1              IN VARCHAR2 DEFAULT NULL,
                             p_date_from               IN VARCHAR2,
                             p_date_to                 IN VARCHAR2,
                             p_alias_value_name_exists OUT nocopy VARCHAR2) IS

l_alias_value_id     hxc_alias_values.alias_value_id%type;
l_alias_value_id_ovn hxc_alias_values.object_version_number%type;
l_alias_value_name   hxc_alias_values.alias_value_name%type;

l_proc 		     VARCHAR2(100);

BEGIN

  g_debug := hr_utility.debug_enabled;

  IF g_debug THEN
     l_proc := g_package||'create_alias_value';
     hr_utility.set_location('ABS:Processing '||l_proc, 10);
  END IF;

  l_alias_value_name 	    := p_alias_value_name;
  p_alias_value_name_exists := 'N';

  IF g_debug THEN
    hr_utility.trace('ABS:l_alias_value_name ::'||l_alias_value_name);
    hr_utility.trace('ABS:p_alias_definition_id ::'||p_alias_definition_id);
    hr_utility.trace('ABS:p_attribute1 ::'||p_attribute1);
    hr_utility.trace('ABS:p_date_from ::'||p_date_from);
    hr_utility.trace('ABS:p_date_to ::'||p_date_to);
  END IF;

  BEGIN

    SELECT 'Y'
      INTO p_alias_value_name_exists
      FROM hxc_alias_values_tl havt,
           hxc_alias_values hav
     WHERE substr(havt.alias_value_name,1,instr(havt.alias_value_name,'(')-2)
			           = substr(l_alias_value_name,1,instr(havt.alias_value_name,'(')-2)
       AND havt.alias_value_id     = hav.alias_value_id
       AND hav.alias_definition_id = p_alias_definition_id
       AND havt.LANGUAGE           = userenv('LANG');

    IF g_debug THEN
       hr_utility.set_location('ABS:Processing '||l_proc, 20);
       hr_utility.trace('ABS:p_alias_value_name_exists ::'||p_alias_value_name_exists);
    END IF;

    IF p_alias_value_name_exists = 'Y' THEN

      SELECT  hav.alias_value_id,
              hav.object_version_number
        INTO  l_alias_value_id,
              l_alias_value_id_ovn
        FROM  hxc_alias_values_tl havt,
              hxc_alias_values hav
       WHERE  substr(havt.alias_value_name,1,instr(havt.alias_value_name,'(')-2)
			              = substr(l_alias_value_name,1,instr(havt.alias_value_name,'(')-2)
         AND  havt.alias_value_id     = hav.alias_value_id
         AND  hav.alias_definition_id = p_alias_definition_id
         AND  havt.LANGUAGE           = userenv('LANG');

      IF g_debug THEN
	hr_utility.set_location('ABS:Processing '||l_proc, 30);
        hr_utility.trace('ABS:l_alias_value_id ::'||l_alias_value_id);
    	hr_utility.trace('ABS:l_alias_value_id_ovn ::'||l_alias_value_id_ovn);
    	hr_utility.trace('ABS:Calling hxc_alias_values_api.update_alias_value procedure.');
      END IF;

      hxc_alias_values_api.update_alias_value(p_alias_value_id        => l_alias_value_id,
                                              p_alias_value_name      => l_alias_value_name,
                                              p_alias_definition_id   => p_alias_definition_id,
                                              p_enabled_flag          => 'Y',
                                              p_attribute_category    => 'PAYROLL_ELEMENTS',
                                              p_attribute1            => p_attribute1,
  	                  		      p_date_from             => to_date(p_date_from,FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK')),
                                              p_date_to               => to_date(p_date_to,FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK')),
                                              p_object_version_number => l_alias_value_id_ovn);

      IF g_debug THEN
         hr_utility.trace('ABS:End of hxc_alias_values_api.update_alias_value procedure.');
         hr_utility.set_location('ABS:Processing '||l_proc, 40);
      END IF;


    END IF;

  EXCEPTION

    WHEN NO_DATA_FOUND THEN

      IF g_debug THEN
	hr_utility.set_location('ABS:Processing '||l_proc, 50);
        hr_utility.trace('ABS:l_alias_value_id ::'||l_alias_value_id);
    	hr_utility.trace('ABS:l_alias_value_id_ovn ::'||l_alias_value_id_ovn);
    	hr_utility.trace('ABS:Calling hxc_alias_values_api.create_alias_value procedure.');
      END IF;

      hxc_alias_values_api.create_alias_value(p_alias_value_id        => l_alias_value_id,
                                              p_alias_value_name      => l_alias_value_name,
                                              p_alias_definition_id   => p_alias_definition_id,
                                              p_enabled_flag 	      => 'Y',
                                              p_attribute_category    => 'PAYROLL_ELEMENTS',
                                              p_attribute1 	      => p_attribute1,
  	                  		      p_date_from  	      => to_date(p_date_from,FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK')),
                                              p_date_to               => to_date(p_date_to,FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK')),
                                              p_object_version_number => l_alias_value_id_ovn);

      IF g_debug THEN
	 hr_utility.trace('ABS:End of hxc_alias_values_api.create_alias_value procedure.');
         hr_utility.set_location('ABS:Processing '||l_proc, 60);
      END IF;

  END;


  EXCEPTION
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    hxc_hav_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    hxc_hav_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    hxc_hav_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));

END create_alias_value;



PROCEDURE create_time_category(p_time_category_name IN VARCHAR2,
                               p_description        IN VARCHAR2,
                               p_time_category_id      OUT nocopy NUMBER,
                               p_object_version_number OUT nocopy NUMBER,
                               p_component_type_id     OUT nocopy NUMBER,
                               p_time_category_exists  OUT nocopy VARCHAR2)  IS

l_exists                  VARCHAR2(1) := 'N';
l_messages                hxc_message_table_type;

l_proc 			  VARCHAR2(100);

BEGIN

  g_debug := hr_utility.debug_enabled;

  IF g_debug THEN
     l_proc := g_package||'create_time_category';
     hr_utility.set_location('ABS:Processing '||l_proc, 10);
  END IF;

  IF g_debug THEN
     hr_utility.trace('ABS:p_time_category_name ::'||p_time_category_name);
     hr_utility.trace('ABS:p_description ::'||p_description);
  END IF;

  BEGIN

    SELECT 'Y'
      INTO l_exists
      FROM hxc_time_categories
     WHERE time_category_name = p_time_category_name;

    IF g_debug THEN
       hr_utility.set_location('ABS:Processing '||l_proc, 20);
    END IF;


  EXCEPTION

    WHEN NO_DATA_FOUND THEN

      IF g_debug THEN
         hr_utility.set_location('ABS:Processing '||l_proc, 30);
         hr_utility.trace('ABS:Calling hxc_time_category_api.create_time_category procedure.');
      END IF;

      l_exists := 'N';
      hxc_time_category_api.create_time_category
      		(p_time_category_id         => p_time_category_id
  		,p_object_version_number    => p_object_version_number
  		,p_time_category_name       => p_time_category_name
  		,p_operator                 => 'OR'
  		,p_description              => p_description
  		,p_display                  => 'Y');

      IF g_debug THEN
         hr_utility.trace('ABS:Completed hxc_time_category_api.create_time_category procedure.');
     	 hr_utility.trace('ABS:p_time_category_id ::'||p_time_category_id);
     	 hr_utility.trace('ABS:p_object_version_number ::'||p_object_version_number);
         hr_utility.set_location('ABS:Processing '||l_proc, 40);
      END IF;

  END;

  p_time_category_exists := l_exists;

  select mapping_component_id
    into p_component_type_id
    from hxc_mapping_components
   where field_name = 'Dummy Element Context';


  IF g_debug THEN
     hr_utility.trace('ABS:p_time_category_exists ::'||p_time_category_exists);
     hr_utility.trace('ABS:p_component_type_id ::'||p_component_type_id);
     hr_utility.set_location('ABS:Processing '||l_proc, 50);
  END IF;

END create_time_category;


PROCEDURE create_time_category_comp(p_time_category_id IN NUMBER,
				    p_value_id IN VARCHAR2,
				    p_component_type_id IN NUMBER,
                                    p_time_category_comp_exists OUT nocopy VARCHAR2)  IS

l_time_category_comp_id     hxc_time_category_comps.TIME_CATEGORY_COMP_ID%type;
l_time_category_comp_ovn    hxc_time_category_comps.OBJECT_VERSION_NUMBER%type;
l_component_type_id         hxc_mapping_components.MAPPING_COMPONENT_ID%TYPE;

l_proc 		     VARCHAR2(100);

BEGIN

  g_debug := hr_utility.debug_enabled;

  IF g_debug THEN
     l_proc := g_package||'create_time_category_comp';
     hr_utility.set_location('ABS:Processing '||l_proc, 10);
  END IF;

  IF g_debug THEN
    hr_utility.trace('ABS:p_time_category_id ::'||p_time_category_id);
    hr_utility.trace('ABS:p_value_id ::'||p_value_id);
    hr_utility.trace('ABS:p_component_type_id ::'||p_component_type_id);
  END IF;

  BEGIN

    l_component_type_id := p_component_type_id;

    IF l_component_type_id = -1 OR l_component_type_id is null
    THEN
        select mapping_component_id
          into l_component_type_id
          from hxc_mapping_components
         where field_name = 'Dummy Element Context';
    END IF;

    SELECT 'Y'
      INTO p_time_category_comp_exists
      FROM hxc_time_category_comps
     WHERE time_category_id = p_time_category_id
       AND value_id = p_value_id;

    IF g_debug THEN
       hr_utility.set_location('ABS:Processing '||l_proc, 20);
       hr_utility.trace('ABS:p_time_category_comp_exists ::'||p_time_category_comp_exists);
    END IF;

    IF p_time_category_comp_exists = 'Y' THEN

      SELECT  time_category_comp_id,
              object_version_number
        INTO  l_time_category_comp_id,
              l_time_category_comp_ovn
        FROM  hxc_time_category_comps
       WHERE  time_category_id = p_time_category_id
         AND  value_id = p_value_id;

      IF g_debug THEN
	hr_utility.set_location('ABS:Processing '||l_proc, 30);
        hr_utility.trace('ABS:l_time_category_comp_id ::'||l_time_category_comp_id);
    	hr_utility.trace('ABS:l_time_category_comp_ovn ::'||l_time_category_comp_ovn);
    	hr_utility.trace('ABS:Calling hxc_time_category_comp_api.update_time_category_comp procedure.');
      END IF;

      hxc_time_category_comp_api.update_time_category_comp
		  (p_time_category_comp_id        => l_time_category_comp_id
		  ,p_object_version_number        => l_time_category_comp_ovn
		  ,p_time_category_id             => p_time_category_id
		  ,p_ref_time_category_id         => null
		  ,p_component_type_id            => l_component_type_id
		  ,p_flex_value_set_id            => -1
		  ,p_value_id                     => p_value_id
		  ,p_is_null                      => 'N'
		  ,p_equal_to                     => 'Y'
		  ,p_type                         => 'MC' );

      IF g_debug THEN
         hr_utility.trace('ABS:Completed hxc_time_category_comp_api.update_time_category_comp procedure.');
         hr_utility.set_location('ABS:Processing '||l_proc, 40);
      END IF;


    END IF;


  EXCEPTION

    WHEN NO_DATA_FOUND THEN

      IF g_debug THEN
	hr_utility.set_location('ABS:Processing '||l_proc, 30);
    	hr_utility.trace('ABS:When NO_DATA_FOUND exception');
      END IF;

      IF g_debug THEN
	hr_utility.set_location('ABS:Processing '||l_proc, 40);
	hr_utility.trace('ABS:l_component_type_id = '||l_component_type_id);
    	hr_utility.trace('ABS:Calling hxc_time_category_comp_api.create_time_category_comp procedure.');
      END IF;

      hxc_time_category_comp_api.create_time_category_comp
		  (p_time_category_comp_id        => l_time_category_comp_id
		  ,p_object_version_number        => l_time_category_comp_ovn
		  ,p_time_category_id             => p_time_category_id
		  ,p_ref_time_category_id         => null
		  ,p_component_type_id            => l_component_type_id
		  ,p_flex_value_set_id            => -1
		  ,p_value_id                     => p_value_id
		  ,p_is_null                      => 'N'
		  ,p_equal_to                     => 'Y'
		  ,p_type                         => 'MC' );

      IF g_debug THEN
	 hr_utility.trace('ABS:Completed of hxc_time_category_comp_api.create_time_category_comp procedure.');
         hr_utility.set_location('ABS:Processing '||l_proc, 50);
      END IF;

      p_time_category_comp_exists := 'N';

  END;


  EXCEPTION
  When hr_api.check_integrity_violated Then
    -- A check constraint has been violated
    --
    hxc_hav_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.parent_integrity_violated Then
    -- Parent integrity has been violated
    --
    hxc_hav_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));
  When hr_api.unique_integrity_violated Then
    -- Unique integrity has been violated
    --
    hxc_hav_shd.constraint_error
      (p_constraint_name => hr_api.strip_constraint_name(SQLERRM));

END create_time_category_comp;


END hxc_absence_type_alias;


/
