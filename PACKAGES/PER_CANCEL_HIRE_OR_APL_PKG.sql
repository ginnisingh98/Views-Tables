--------------------------------------------------------
--  DDL for Package PER_CANCEL_HIRE_OR_APL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CANCEL_HIRE_OR_APL_PKG" AUTHID CURRENT_USER as
/* $Header: pecanhir.pkh 120.0.12010000.2 2008/09/12 11:35:12 ghshanka ship $ */

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
 Name        : hr_person  (BODY)

 Description : This package declares procedures needed to cancel an
               employee's hire.

 Change List
 -----------

 Version Date      Author     ER/CR No. Description of Change
 -------+---------+----------+---------+--------------------------
70.0     27-Oct-94 Tmathers             First Version into Arcs.
70.1     13-May-95 ARoussel		Fix error at end to report on header
70.2     15-May-95 RFine		...and also in the show errors line
70.3     11-Jun-97 Teyres		Change 'is' to 'as' in create or replace
110.1    04-AUG-97 Mbocutt              Changed package name to comply with
					standards.
115.2    11-JUN-02 MGettins             Added dbdrv commands
115.3    12-JUN-02 adhunter             corrected dbdrv line
115.4    20-NOV-02 MGettins             Added lock_cwk_rows procedure.
115.5    04-DEC-02 MGettins             NOCOPY changes
115.6    12-Sep-08 ghshanka             Bug 7001197 Added a mew procedure to handle the
					emp_apl cancel hire issue.
*/
--
PROCEDURE lock_cwk_rows
  (p_person_id         IN per_all_people_f.person_id%TYPE
  ,p_business_group_id IN per_all_people_f.business_group_id%TYPE
  ,p_effective_date    IN DATE);
--
procedure lock_per_rows(p_person_id NUMBER
                      ,p_primary_id NUMBER
                      ,p_primary_date DATE
                      ,p_business_group_id NUMBER
                      ,p_person_type VARCHAR2);
--
procedure pre_cancel_checks(p_person_id NUMBER
                           ,p_where   IN OUT NOCOPY VARCHAR2
                           ,p_business_group_id NUMBER
                           ,p_system_person_type VARCHAR2
                           ,p_primary_id NUMBER
                           ,p_primary_date DATE
                           ,p_cancel_type VARCHAR2);
--
procedure do_cancel_hire(p_person_id NUMBER
                        ,p_date_start DATE
                        ,p_end_of_time DATE
                        ,p_business_group_id NUMBEr
                        ,p_period_of_service_id NUMBER);
--
procedure do_cancel_appl(p_person_id NUMBER
                        ,p_date_received DATE
                        ,p_end_of_time DATE
                        ,p_business_group_id NUMBER
                        ,p_application_id NUMBER);
--
procedure update_person_list (p_person_id NUMBER);
--
PROCEDURE do_cancel_placement
  (p_person_id            IN per_people_f.person_id%TYPE
  ,p_business_group_id    IN per_people_f.business_group_id%TYPE
  ,p_effective_date       IN DATE
  ,p_date_start           IN DATE);
--
PROCEDURE pre_cancel_placement_checks
  (p_person_id           IN     NUMBER
  ,p_business_group_id   IN     NUMBER
  ,p_effective_date      IN     DATE
  ,p_date_start          IN     DATE
  ,p_supervisor_warning  IN OUT NOCOPY BOOLEAN
  ,p_recruiter_warning   IN OUT NOCOPY BOOLEAN
  ,p_event_warning       IN OUT NOCOPY BOOLEAN
  ,p_interview_warning   IN OUT NOCOPY BOOLEAN
  ,p_review_warning      IN OUT NOCOPY BOOLEAN
  ,p_vacancy_warning     IN OUT NOCOPY BOOLEAN
  ,p_requisition_warning IN OUT NOCOPY BOOLEAN
  ,p_budget_warning      IN OUT NOCOPY BOOLEAN
  ,p_payment_warning     IN OUT NOCOPY BOOLEAN);
--
procedure cancel_emp_apl_hire
(
   p_person_id NUMBER
  ,p_date_start DATE
  ,p_end_of_time DATE
  ,p_business_group_id NUMBEr
  ,p_period_of_service_id NUMBER);
  --
FUNCTION return_legislation_code
  (p_person_id  IN NUMBER ) RETURN VARCHAR2;
--
END per_cancel_hire_or_apl_pkg;

/
