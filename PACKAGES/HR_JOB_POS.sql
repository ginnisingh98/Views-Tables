--------------------------------------------------------
--  DDL for Package HR_JOB_POS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_JOB_POS" AUTHID CURRENT_USER AS
/* $Header: pejapdel.pkh 115.0 99/07/18 13:54:30 porting ship $ */
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
 Name        : hr_job_pos  (HEADER)

 Description : This package declares procedures required for jobs and
               positions occurring in an organization/business group
               for applications that have the Org CBB and use Jobs and
               Positions.

 Change List
 -----------

 Version Date      Author     ER/CR No. Description of Change
 -------+---------+----------+---------+--------------------------
 70.0    05-APR-93 TMATHERS             Date Created
 70.1    05-APR-93 TMATHERS             Added Exit.
 70.2    22-APR-93 TMATHERS             Added hr_pos_bg_chk.
*/
--
-- Procedure to check for the existsence of jbs and positions
-- when HR is not installed and the application using Organizations
-- also uses Jobs and Positions.
--
PROCEDURE hr_jp_predelete(p_organization_id INTEGER
                         ,p_business_group_id INTEGER);
--
-- Procedure to check the existence of positions
-- when attempting to create a business_group.
--
procedure hr_pos_bg_chk(
p_organization_id INTEGER);
--
end hr_job_pos;

 

/
