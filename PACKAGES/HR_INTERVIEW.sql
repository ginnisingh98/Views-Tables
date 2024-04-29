--------------------------------------------------------
--  DDL for Package HR_INTERVIEW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_INTERVIEW" AUTHID CURRENT_USER AS
/* $Header: peintviw.pkh 115.1 2003/12/23 21:20:10 bsubrama ship $ */
/*
 ******************************************************************
 *                                                                *
 *  Copyright (C) 1992 Oracle Corporation UK Ltd.,                *
 *                   Chertsey, England.                           *
 *                                                                *
 *  All rights reserved.                                          *
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
 Name        : hr_interview  (HEADER)

 Description : This package declares procedures required to
               INSERT, UPDATE and DELETE Assignment Statuses for
               Applicant Interviews called from PERREAB.

 Change List
 -----------

 Version Date      Author     ER/CR No. Description of Change
 -------+---------+----------+---------+-----------------------
 70.0    09-FEB-93 PShergill            Date Created
 70.1  11-MAR-93 NKhan     Added 'exit' to end
 70.2    05-APR-93 A.McGhee             Corrected incorrect END identifier
               name.
 115.1   24-Dec-03 bsubrama   3333891   Added dbdrv and commit
 ================================================================= */

--
--
------------------- insert_interview -----------------------------
/*
  NAME
     insert_interview

  DESCRIPTION
     Inserts an assignment of type specified in the paramenter list
     starting from applicant interview start date
  PARAMETERS
     p_assignment_id             - assignment_id of applicant
     p_idate                     - New Interview Date
     p_assignment_status_type_id - Assignment Status Type Id of Interview
     p_last_updated_by           - Required for Auditing
     p_last_update_login         - Required for Auditing
*/
PROCEDURE insert_interview
                            (
                             p_assignment_id IN INTEGER,
                             p_idate IN DATE,
                             p_assignment_status_type_id IN INTEGER,
                             p_last_updated_by IN INTEGER,
                             p_last_update_login IN INTEGER
                             );
--
--
------------------- delete_interview -----------------------------
/*
  NAME
     delete_interview
  DESCRIPTION
     Deletes assignment for associated applicant interview
  PARAMETERS
     p_assignment_id             - assignment_id of applicant
     p_idate                     - New Interview Date
     p_last_updated_by           - Required for Auditing
     p_last_update_login         - Required for Auditing
*/
PROCEDURE delete_interview
                            (p_assignment_id IN INTEGER,
                             p_idate IN DATE,
                             p_last_updated_by IN INTEGER,
                             p_last_update_login IN INTEGER
                             );
--
--
------------------- update_interview -------------------------------
/*
  NAME
       update_interview
  DESCRIPTION
       Update assignment for associated applicant interview
  PARAMETERS
     p_assignment_id             - assignment_id of applicant
     p_idate                     - New Interview Date
     p_odate                     - Old Interview Date
     p_last_updated_by           - Required for Auditing
     p_last_update_login         - Required for Auditing
*/
PROCEDURE update_interview
                            (p_assignment_id IN INTEGER,
                             p_idate IN DATE,
                             p_odate IN DATE,
                             p_last_updated_by IN INTEGER,
                             p_last_update_login IN INTEGER
                             );
--
--
end hr_interview;

 

/
