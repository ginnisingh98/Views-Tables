--------------------------------------------------------
--  DDL for Package HR_ORGANIZATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ORGANIZATION" AUTHID CURRENT_USER AS
/* $Header: peorganz.pkh 115.4 2002/08/20 11:30:10 skota ship $ */
/*
 ******************************************************************
 *                                                                *
 *  Copyright (C) 1992 Oracle Corporation UK Ltd.,                *
 *                   Chertsey, England.                           *
 *                                                                *
 *  All rights reserved.                                          *
 *                                                                *
 *  This material has been provided pursuant to an agreement      *
 *  containing restrictions on its use.  The material is also     *
 *  protected by copyright law.  No part of this material may     *
 *  be copied or distributed, transmitted or transcribed, in      *
 *  any form or by any means, electronic, mechanical, magnetic,   *
 *  manual, or otherwise, or disclosed to third parties without   *
 *  the express written permission of Oracle Corporation UK Ltd,  *
 *  Oracle Park, Bittams Lane, Guildford Road, Chertsey, Surrey,  *
 *  England.                                                      *
 *                                                                *
 ****************************************************************** */
/*
 Name        : hr_organization  (HEADER)

 Description : This package declares procedures required to INSERT
               or UPDATE organizations in any application. DELETE
               control is being handled via Foreign Key Constraints
               on the ORGANIZATION_UNIT, four of which will allow
               CASCADE DELETE to
                    HR_ORGANIZATION_INFORMATION
                    PER_NUMBER_GENERATION_CONTROLS
                    PER_ASSIGNMENT_STATUS_TYPE
                    PER_PERSON_TYPES.
            Note: none of these tables can be deleted directly and
                  INSERTS into the PER tables are controlled by the
                  After Row Insert trigger on HR_ORGANIZATION_INFORMATION.

 Change List
 -----------

 Version Date      Author     ER/CR No. Description of Change
 -------+---------+----------+---------+--------------------------
 70.0    17-NOV-92 SZWILLIA             Date Created
 70.1    17-NOV-92 SZWILLIA             Commenting
 70.2    20-NOV-92 SZWILLIA             Added declaration of
                                        insert_bus_grp_details.
 70.4    01-MAR-93 TMATHERS             Added declaration of
                                        org_predel_check.
 70.5    04-MAR-93 SZWILLIA             Changed parameters to DATES
 70.6    11-MAR-93 NKHAN		Added 'exit' to the end
 70.7    31-MAR-93 TMATHERS		removed org_predel_check to
                                        separate package.
 70.8    01-APR-93 TMATHERS		Included shared org_predel_check
                                        procedure.(WHich includes only shared
                                        tables of the Org CBB).
 70.9    22-APR-93 TMATHERS		Included shared hr_weak_bg_chk
 70.12   02-JUN-94 TMathers             Added get_flex_msg as a result of
                                        using FND PLSQL in PERORDOR.
 115.1   05-JUN-00 CCarter              Added parameter p_org_information6
								to insert_bus_grp_details in order
								to create a Job Group everytime a
								Business Group is created.
 115.2   12-jun-02 adhunter             added dbdrv lines
 ================================================================= */
--
-- ----------------------- insert_business_group_details ------------
-- Called from trigger hr_org_info_ari
--
PROCEDURE insert_bus_grp_details (p_organization_id   NUMBER
                                 ,p_org_information9  VARCHAR2
						   ,p_org_information6  VARCHAR2
                                 ,p_last_update_date  DATE
                                 ,p_last_updated_by   NUMBER
                                 ,p_last_update_login NUMBER
                                 ,p_created_by        NUMBER
                                 ,p_creation_date     DATE);
--
-----------------------------  unique_name -----------------------
--
-- Procedure used to check for unique organization name
--
  PROCEDURE  unique_name
  (p_business_group_id NUMBER,
   p_organization_id NUMBER,
   p_organization_name VARCHAR2);
--
--
-----------------------------  date_range ------------------------
--
-- Procedure used to check date range on organization
--
  PROCEDURE date_range
  (p_date_from DATE,
   p_date_to   DATE);
--
--
----------------------------- org_predel_check ------------------------
--
-- Procedure used to check whether an organization
-- can be deleted from a shared enviromnment..
-- (Personnel/Payroll Specific checks will not be made).
--
  PROCEDURE org_predel_check
  (p_organization_id INTEGER
  ,p_business_group_id INTEGER);
--
--
-- Procedure used to check whether an organization
-- can become a business group.
--
procedure hr_weak_bg_chk(p_organization_id INTEGER);
--
-- Procedure required due to FND PLSQL not being able to handle hr_message
--
procedure get_flex_msg;
--
END hr_organization;

 

/
