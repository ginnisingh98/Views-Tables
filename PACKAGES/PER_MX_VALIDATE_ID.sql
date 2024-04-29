--------------------------------------------------------
--  DDL for Package PER_MX_VALIDATE_ID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_MX_VALIDATE_ID" AUTHID CURRENT_USER AS
/* $Header: pemxvlid.pkh 120.0.12010000.1 2008/07/28 05:01:19 appldev ship $ */
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

    Name        : PER_MX_VALIDATE_ID

    Description : This package is a hook call for following APIs :-
                    1. create_applicant
                    2. hire_applicant

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  -------------------------------
    21-JUN-2004 sdahiya    115.0            Created.
  *****************************************************************************/


/*******************************************************************************
    Name    : validate_rfc_id
    Purpose : This procedure acts as wrapper for per_mx_validations.check_rfc.
*******************************************************************************/

PROCEDURE VALIDATE_RFC_ID(
            p_per_information2    per_all_people_f.per_information2%type,
            p_person_id           per_all_people_f.person_id%type);

/*******************************************************************************
    Name    : validate_ss_id
    Purpose : This procedure acts as wrapper for per_mx_validations.check_ss
*******************************************************************************/

PROCEDURE VALIDATE_SS_ID(
            p_per_information3    per_all_people_f.per_information3%type,
            p_person_id           per_all_people_f.person_id%type);

/*******************************************************************************
    Name    : validate_fga_id
    Purpose : This procedure acts as wrapper for per_mx_validations.check_fga
*******************************************************************************/

PROCEDURE VALIDATE_FGA_ID(
            p_per_information5    per_all_people_f.per_information5%type,
            p_person_id           per_all_people_f.person_id%type);


/*******************************************************************************
    Name    : validate_ms_id
    Purpose : This procedure acts as wrapper for per_mx_validations.check_ms
*******************************************************************************/

PROCEDURE VALIDATE_MS_ID(
            p_per_information6    per_all_people_f.per_information6%type,
            p_person_id           per_all_people_f.person_id%type);


/*******************************************************************************
    Name    : validate_imc_id
    Purpose : This procedure acts as wrapper for per_mx_validations.check_imc
*******************************************************************************/

PROCEDURE VALIDATE_IMC_ID(
            p_per_information4    per_all_people_f.per_information4%type);


/*******************************************************************************
    Name    : validate_regn_id
    Purpose : This procedure acts as wrapper for per_mx_validations.check_regstrn_id
*******************************************************************************/

PROCEDURE VALIDATE_REGN_ID(
            p_disability_id     number,
            p_registration_id   varchar2);


glb_proc_name varchar2(30);

END PER_MX_VALIDATE_ID;

/
