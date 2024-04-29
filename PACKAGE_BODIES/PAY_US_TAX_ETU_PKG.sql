--------------------------------------------------------
--  DDL for Package Body PAY_US_TAX_ETU_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_TAX_ETU_PKG" AS
/* $Header: pyusetug.pkb 120.1.12010000.1 2008/07/27 23:50:57 appldev ship $ */

g_debug                BOOLEAN;

/****************************************************************************
  Name        : HR_UTILITY_TRACE
  Description : This function prints debug messages during diagnostics mode.
*****************************************************************************/
PROCEDURE hr_utility_trace(trc_data VARCHAR2) IS
BEGIN
    IF g_debug THEN
        hr_utility.trace(trc_data);
    END IF;
END hr_utility_trace;


/*****************************************************************************
 Name      : create_vertex_etu
 Purpose   : Procedure create element type usages for VERTEX.
*****************************************************************************/
PROCEDURE create_vertex_etu(p_effective_date        IN     DATE
                           ,p_element_type_id       IN     NUMBER
                           ,p_business_group_id     IN     NUMBER
                           ,p_costable_type         IN     VARCHAR2
			    ) AS


  CURSOR c_run_type IS
  SELECT prt.* from pay_run_types_f  prt
   WHERE prt.run_type_name IN ('Regular Standard Run',
                               'Separate Payment Run',
                               'Tax Separate Run',
                               'Supplemental Standard Run',
                               'Regular',
                               'Supplemental')
    AND  prt.business_group_id IS NULL
    AND  prt.legislation_code = 'US';

  l_payroll_run_exist       VARCHAR2(10);
  l_vertex_etu_exist        VARCHAR2(10);
  l_us_tax_vertex_etu_exist VARCHAR2(10);
  l_workers_comp_etu_exist  VARCHAR2(10);

  CURSOR  c_vertex_element(p_element_name IN VARCHAR2) IS
  SELECT  element_type_id
    FROM  pay_element_types_f
   WHERE  element_name = p_element_name
     AND  legislation_code  = 'US'
     AND  business_group_id IS NULL;

  l_element_type_id    pay_element_types_f.element_type_id%TYPE;

BEGIN

  hr_utility_trace('pay_us_tax_etu_pkg.create_vertex_etu ');
  hr_utility_trace('p_effective_date -> ' || p_effective_date);
--  hr_utility_trace('p_organization_id -> ' || p_organization_id);
--  hr_utility_trace('p_org_info_type_code -> ' || p_org_info_type_code);

  l_payroll_run_exist := pay_us_vertex_interface.payroll_run_exist(p_business_group_id);
  hr_utility_trace('l_payroll_run_exist -> '|| l_payroll_run_exist);

  l_vertex_etu_exist :=  pay_us_vertex_interface.vertex_eletype_usage_exist('VERTEX',p_business_group_id);
  hr_utility_trace('l_vertex_etu_exist -> '|| l_vertex_etu_exist);

  l_us_tax_vertex_etu_exist := pay_us_vertex_interface.vertex_eletype_usage_exist('US_TAX_VERTEX',p_business_group_id);
  hr_utility_trace('l_us_tax_vertex_etu_exist -> '|| l_us_tax_vertex_etu_exist);

  l_workers_comp_etu_exist := pay_us_vertex_interface.vertex_eletype_usage_exist('Workers Compensation',p_business_group_id);
  hr_utility_trace('l_workers_comp_etu_exist -> '|| l_workers_comp_etu_exist);

  IF l_payroll_run_exist = 'N' THEN

     IF l_vertex_etu_exist = 'Y' THEN
        hr_utility.set_location('l_vertex_etu_exist ->'|| l_vertex_etu_exist,2001);
        pay_us_vertex_interface.delete_ele_type_usages('VERTEX'
                                                      , p_business_group_id);
     END IF;

     IF l_us_tax_vertex_etu_exist = 'Y' THEN
        hr_utility.set_location('IN HRAMERD, l_us_tax_vertex_etu_exist ->'|| l_us_tax_vertex_etu_exist,2001);
        pay_us_vertex_interface.delete_ele_type_usages('US_TAX_VERTEX'
                                                      , p_business_group_id);
     END IF;

     IF l_workers_comp_etu_exist = 'Y' THEN
        pay_us_vertex_interface.delete_ele_type_usages('Workers Compensation'
                                                      , p_business_group_id);
     END IF;

     OPEN c_vertex_element('VERTEX');
     FETCH c_vertex_element INTO l_element_type_id;
     CLOSE c_vertex_element;
     hr_utility_trace('l_element_type_id -> '|| l_element_type_id);

     FOR run_type IN c_run_type LOOP
            pay_us_vertex_interface.create_ele_tp_usg(p_element_type_id => l_element_type_id
                                                     ,p_run_type_id  => run_type.run_type_id
                                                     ,p_element_name => 'VERTEX'
                                                     ,p_run_type_name => run_type.run_type_name
                                                     ,p_inclusion_flag  => 'N'
                                                     ,p_effective_date  => run_type.effective_start_date
                                                     ,p_legislation_code => NULL
                                                     ,p_business_group_id => p_business_group_id);
     END LOOP;

     OPEN c_vertex_element('Workers Compensation');
     FETCH c_vertex_element INTO l_element_type_id;
     CLOSE c_vertex_element;
     hr_utility_trace('l_element_type_id -> '|| l_element_type_id);

     FOR run_type IN c_run_type LOOP
           pay_us_vertex_interface.create_ele_tp_usg
             ( p_element_type_id      => l_element_type_id
              ,p_run_type_id          => run_type.run_type_id
              ,p_element_name         => 'Workers Compensation'
              ,p_run_type_name        => run_type.run_type_name
              ,p_inclusion_flag       => 'N'
              ,p_effective_date       => run_type.effective_start_date
              ,p_legislation_code     => NULL
              ,p_business_group_id    => p_business_group_id);

	     hr_utility.trace('2136 -> Workers Compensation element excluded');
     END LOOP;

  ELSIF l_payroll_run_exist = 'Y' THEN
        NULL;
  END IF; --l_payroll_run_exist = 'N'

END create_vertex_etu;

--To put the trace just uncomment the below three lines.
--BEGIN
--  hr_utility.trace_on(null,'VERTEX');
--  g_debug := hr_utility.debug_enabled;
END pay_us_tax_etu_pkg;

/
