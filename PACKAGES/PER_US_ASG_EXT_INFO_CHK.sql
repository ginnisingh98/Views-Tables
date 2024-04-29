--------------------------------------------------------
--  DDL for Package PER_US_ASG_EXT_INFO_CHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_US_ASG_EXT_INFO_CHK" AUTHID CURRENT_USER AS
/* $Header: peuseitd.pkh 120.0 2005/05/31 22:37:11 appldev noship $ */
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
    );


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
    );

GLB_MODE varchar2(10);
GLB_ASG_EXTRA_INFO_ID per_assignment_extra_info.assignment_extra_info_id%type;

END PER_US_ASG_EXT_INFO_CHK;

 

/
