--------------------------------------------------------
--  DDL for Package HR_ORG_PRE_DELETE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ORG_PRE_DELETE" AUTHID CURRENT_USER AS
/* $Header: pedelorg.pkh 115.0 99/07/17 18:53:58 porting ship $ */
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
 Name        : hr_org_pre_delete  (HEADER)

 Description : This package declares procedures required to test for referential               integrity errors which could potentially be caused by deleting
               an organization which relationship rows with other tables.
               (Although ORACLE7 does this automatically the message isn't
                vey user friendly).

 Change List
 -----------

 Version Date      Author     ER/CR No. Description of Change
 -------+---------+----------+---------+--------------------------
70.0     31-MAR-93 TMATHERS             Date Created.
70.1     01-APR-93 TMATHERS             Moved shared org tests to peorganz.
70.2     22-APR-93 TMATHERS             Added hr_strong_bg_chk procedure.
*/
----------------------------- hr_org_predel_check ------------------------
--
-- Procedure used to check whether an organization
-- or business group (an org with a information type of business group)
-- can be deleted.
  PROCEDURE hr_org_predel_check
  (p_organization_id INTEGER
  ,p_business_group_id INTEGER);
--
--
---------------------------- hr_strong_bg_chk ------------------------------
--
-- Procedure to check whether an organization
-- can become a business group.
procedure hr_strong_bg_chk(
p_organization_id INTEGER);
--
END hr_org_pre_delete;

 

/
