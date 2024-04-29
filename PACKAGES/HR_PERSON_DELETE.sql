--------------------------------------------------------
--  DDL for Package HR_PERSON_DELETE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PERSON_DELETE" AUTHID CURRENT_USER AS
/* $Header: peperdel.pkh 120.0 2005/05/31 13:48:51 appldev noship $ */
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
 Name        : hr_person  (HEADER)

 Description : This package declares procedures required to DELETE
   people on Oracle Human Resources. Note, this
   does not include extra validation provided by calling programs (such
   as screen QuickPicks and HRLink validation) OR that provided by use
   of constraints and triggers held against individual tables.
 Change List
 -----------

 Version Date      Author     ER/CR No. Description of Change
 -------+---------+----------+---------+--------------------------
 70.0    10-AUG-93 TMATHERS             Date Created
 80.0                                   Removed these procedures
                                        from peperson(hr_person).
                                        Orignally coded by PBARRY.
                                        Moved to reduce size of
                                        original package.
 70.3    14-Jun-95 TMathers             Created new procedure
                                        moderate_predel_validation
 ================================================================= */
--
--
-- ----------------------- product_installed --------------------------
--
-- Has this product been installed? Return status and oracleid also.
--
  PROCEDURE product_installed (p_application_short_name IN varchar2,
                              p_status          OUT NOCOPY varchar2,
                              p_yes_no          OUT NOCOPY varchar2,
                              p_oracle_username OUT NOCOPY varchar2);
--
-- ----------------------- weak_predel_validation --------------------------
--
-- Weak pre-delete validation called primarily from Delete Person form.
--
  PROCEDURE weak_predel_validation (p_person_id 	IN number,
				    p_session_date	IN date,
                                    p_dt_delete_mode    IN varchar2 default 'ZAP'); -- 4169275

--
-- ----------------------- Moderate_predel_validation -----------------------
--
-- Moderate pre-delete validation called from the Stong_predel_validation
-- procedure and HR API's.
--
  PROCEDURE moderate_predel_validation (p_person_id IN number,
                                      p_session_date IN date,
                                      p_dt_delete_mode    IN varchar2 default 'ZAP'); -- 4169275
--
-- ----------------------- strong_predel_validation --------------------------
--
-- Strong pre-delete validation called from the Enter Person and Applicant
-- Quick Entry forms.
--
  PROCEDURE strong_predel_validation (p_person_id IN number,
				      p_session_date IN date,
                                      p_dt_delete_mode    IN varchar2 default 'ZAP'); -- 4169275
--
-- ----------------------- check_contact --------------------------
--
-- Whilst deleteing a contact relationship, is this contact 'used' for
-- anything else? If not then delete this person.
--
  PROCEDURE check_contact (p_person_id                  IN number,
                           p_contact_person_id          IN number,
                           p_contact_relationship_id    IN number,
			   p_session_date		IN date);
--
-- ----------------------- delete_a_person --------------------------
--
-- Delete a person completely from the HR database. Deletes from all tables
-- referencing this person. Used primarily by Delete Person form.
--
  PROCEDURE delete_a_person (p_person_id        IN number,
                             p_form_call        IN boolean,
			     p_session_date	IN date);
--
-- ----------------------- people_default_deletes --------------------------
--
-- Delete people who only have default information entered for them.
-- Used primarily by the Enter Person form.
--
  PROCEDURE people_default_deletes (p_person_id IN number,
                                    p_form_call IN boolean);
--
-- ----------------------- applicant_default_deletes --------------------------
--
-- Delete applicants who only have default information entered for them.
-- Used primarily by the Applicant Quick Entry form.
--
  PROCEDURE applicant_default_deletes (p_person_id      IN number,
                                       p_form_call      IN boolean);
--
end hr_person_delete;

 

/
