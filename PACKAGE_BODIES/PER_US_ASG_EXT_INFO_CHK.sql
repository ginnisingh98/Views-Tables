--------------------------------------------------------
--  DDL for Package Body PER_US_ASG_EXT_INFO_CHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_US_ASG_EXT_INFO_CHK" AS
/* $Header: peuseitd.pkb 120.0 2005/05/31 22:36:54 appldev noship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1993 Oracle Corporation.                        *
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

    Name        : PER_US_ASG_EXT_INFO_CHK

    Description : This package checks for unique combination of state and involuntary
                  deduction category entered from EIT. This package is called by
                  before process hooks of create_assignment_extra_info and
                  update_assignment_extra_info APIs.

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  -------------------------------
    26-MAY-2004 sdahiya    115.0            Created.
  *****************************************************************************/


/*******************************************************************************
    Name    : chk_dup_proration_ins
    Purpose : This procedure checks for unique combination of state and involuntary
              deduction category while inserting assignment EIT records.
*******************************************************************************/

PROCEDURE CHK_DUP_PRORATION_INS(
    p_assignment_id per_assignment_extra_info.assignment_id%TYPE,
    p_aei_information_category per_assignment_extra_info.aei_information_category%TYPE,
    p_aei_information1 per_assignment_extra_info.aei_information1%TYPE,
    p_aei_information2 per_assignment_extra_info.aei_information2%TYPE
    ) IS

    CURSOR c_dup_records IS
        SELECT COUNT(1)
          FROM per_assignment_extra_info
         WHERE assignment_id = p_assignment_id
           AND aei_information1 = p_aei_information1
           AND aei_information2 = p_aei_information2
           AND ((assignment_extra_info_id <> GLB_ASG_EXTRA_INFO_ID AND GLB_MODE IS NOT NULL) OR
                (GLB_MODE IS NULL))
           AND aei_information_category = 'US_PRORATION_RULE';

    l_count number;
    l_proc_name varchar2(100);

BEGIN

    l_proc_name := 'PER_US_ASG_EXT_INFO_CHK.CHK_DUP_PRORATION_INS';
    hr_utility.trace('Entering '||l_proc_name);
    hr_utility.set_location (l_proc_name,10);
    hr_utility.trace('Input parameters....');
    hr_utility.trace('P_ASSIGNMENT_ID = '||P_ASSIGNMENT_ID);
    hr_utility.trace('P_AEI_INFORMATION_CATEGORY = '||P_AEI_INFORMATION_CATEGORY);
    hr_utility.trace('P_AEI_INFORMATION1 = '||P_AEI_INFORMATION1);
    hr_utility.trace('P_AEI_INFORMATION2 = '||P_AEI_INFORMATION2);

    IF p_aei_information_category = 'US_PRORATION_RULE' THEN
        OPEN c_dup_records;
            FETCH c_dup_records INTO l_count;
        CLOSE c_dup_records;

        hr_utility.trace('Number of records = '||l_count);
        IF l_count >= 1 THEN
            hr_utility.set_location (l_proc_name,20);
            hr_utility.set_message(800, 'PER_US_DUP_PRORATION');
            hr_utility.raise_error;
        END IF;
    END IF;
    hr_utility.set_location (l_proc_name,30);
    hr_utility.trace('Leaving '||l_proc_name);

END CHK_DUP_PRORATION_INS;


/*******************************************************************************
    Name    : chk_dup_proration_upd
    Purpose : This procedure checks for unique combination of state and involuntary
              deduction category while updating assignment EIT records.
*******************************************************************************/

PROCEDURE CHK_DUP_PRORATION_UPD(
    p_assignment_extra_info_id per_assignment_extra_info.assignment_extra_info_id%TYPE,
    p_aei_information_category per_assignment_extra_info.aei_information_category%TYPE,
    p_aei_information1 per_assignment_extra_info.aei_information1%TYPE,
    p_aei_information2 per_assignment_extra_info.aei_information2%TYPE
    ) IS
    CURSOR c_asg_id IS
        SELECT assignment_id
          FROM per_assignment_extra_info
         WHERE assignment_extra_info_id = p_assignment_extra_info_id;

    l_asg_id per_assignment_extra_info.assignment_id%TYPE;
    l_proc_name varchar2(100);
BEGIN
    l_proc_name := 'PER_US_ASG_EXT_INFO_CHK.CHK_DUP_PRORATION_UPD';
    hr_utility.trace('Entering '||l_proc_name);
    hr_utility.set_location(l_proc_name, 10);
    hr_utility.trace('Input parameters....');
    hr_utility.trace('P_ASSIGNMENT_EXTRA_INFO_ID = '||P_ASSIGNMENT_EXTRA_INFO_ID);
    hr_utility.trace('P_AEI_INFORMATION_CATEGORY = '||P_AEI_INFORMATION_CATEGORY);
    hr_utility.trace('P_AEI_INFORMATION1 = '||P_AEI_INFORMATION1);
    hr_utility.trace('P_AEI_INFORMATION2 = '||P_AEI_INFORMATION2);
    OPEN c_asg_id;
        FETCH c_asg_id INTO l_asg_id;
    CLOSE c_asg_id;

    GLB_MODE := 'UPDATE';
    GLB_ASG_EXTRA_INFO_ID := p_assignment_extra_info_id;

    CHK_DUP_PRORATION_INS(
            l_asg_id,
            p_aei_information_category,
            p_aei_information1,
            p_aei_information2
            );

    GLB_MODE := NULL;
    hr_utility.set_location(l_proc_name, 20);
    hr_utility.trace('Leaving '||l_proc_name);
END CHK_DUP_PRORATION_UPD;

END PER_US_ASG_EXT_INFO_CHK;

/
