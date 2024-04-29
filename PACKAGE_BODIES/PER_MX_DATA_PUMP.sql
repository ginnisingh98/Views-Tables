--------------------------------------------------------
--  DDL for Package Body PER_MX_DATA_PUMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_MX_DATA_PUMP" AS
/* $Header: hrmxdpmf.pkb 120.0 2005/05/31 01:28:48 appldev noship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 2004 Oracle India Pvt. Ltd.                     *
   *  IDC Hyderabad                                                 *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Name        : PER_MX_DATA_PUMP

    Description : This package defines mapping functions for data pump.

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  -------------------------------
    23-JUL-2004 sdahiya    115.0            Created.
  *****************************************************************************/

    g_proc_name varchar2(30);

/*******************************************************************************
    Name    : get_tax_unit_id
    Purpose : This function returns tax unit id for a given tax unit name under a
              given business group.
*******************************************************************************/

FUNCTION GET_TAX_UNIT_ID(
    p_tax_unit              in varchar2,
    p_business_group_id     in number
    ) RETURN NUMBER AS

    CURSOR csr_tax_unit_id IS
        SELECT hou.organization_id
          FROM hr_all_organization_units hou,
               hr_all_organization_units_tl houtl,
               hr_organization_information hoi,
               hr_organization_information hoi1
         WHERE hou.organization_id = hoi.organization_id(+)
           AND hou.organization_id = hoi1.organization_id
           AND hou.organization_id = houtl.organization_id
           AND hoi.org_information_context(+) = 'Employer Identification'
           AND hoi1.org_information_context = 'CLASS'
           AND hoi1.org_information1 = 'HR_LEGAL'
           AND hoi1.org_information2 = 'Y'
           AND houtl.language = userenv('LANG')
           AND hou.business_group_id = p_business_group_id
           AND hou.name = p_tax_unit;

    l_org_id        hr_all_organization_units.organization_id%type;
    l_proc_name     varchar2(100);
BEGIN

    l_proc_name := g_proc_name||'GET_TAX_UNIT_ID';
    hr_utility.trace('Entering '||l_proc_name);

    OPEN csr_tax_unit_id;
        FETCH csr_tax_unit_id INTO l_org_id;
    CLOSE csr_tax_unit_id;

    hr_utility.trace('Leaving '||l_proc_name);

    RETURN (l_org_id);
EXCEPTION
    WHEN others THEN
        hr_data_pump.fail('GET_TAX_UNIT_ID',
                          sqlerrm,
                          p_tax_unit,
                          p_business_group_id);
END GET_TAX_UNIT_ID;


/*******************************************************************************
    Name    : get_work_schedule_id
    Purpose : This function returns work schedule id for a given work schedule
              under MX legislation.
*******************************************************************************/

FUNCTION GET_WORK_SCHEDULE (p_work_schedule  varchar2) RETURN number IS
    CURSOR csr_get_work_schedule IS
        SELECT puc.user_column_id
          FROM pay_user_columns puc,
               pay_user_tables put
         WHERE puc.user_table_id = put.user_table_id
           AND puc.legislation_code = put.legislation_code
           AND puc.user_column_name = p_work_schedule
           AND put.user_table_name = 'COMPANY WORK SCHEDULES'
           AND put.legislation_code = 'MX'
           AND puc.business_group_id IS NULL;

    l_user_column_id pay_user_columns.user_column_id%type;
    l_proc_name varchar2(100);
BEGIN
    l_proc_name := g_proc_name || 'GET_WORK_SCHEDULE';
    hr_utility.trace('Entering '||l_proc_name);

    OPEN csr_get_work_schedule;
        FETCH csr_get_work_schedule INTO l_user_column_id;
    CLOSE csr_get_work_schedule;

    hr_utility.trace('Leaving '||l_proc_name);
    RETURN (l_user_column_id);
EXCEPTION
    WHEN others THEN
        hr_data_pump.fail('GET_WORK_SCHEDULE',
                          sqlerrm,
                          p_work_schedule);
END GET_WORK_SCHEDULE;


BEGIN
    g_proc_name := 'PER_MX_DATA_PUMP.';
END PER_MX_DATA_PUMP;

/
