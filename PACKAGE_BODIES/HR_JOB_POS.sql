--------------------------------------------------------
--  DDL for Package Body HR_JOB_POS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_JOB_POS" AS
/* $Header: pejapdel.pkb 120.0 2005/05/31 10:32:28 appldev noship $ */
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
 ******************************************************************
 ==================================================================

 Name        : hr_job_pos  (BODY)

 Description : Contains the definition of job and position procedures
               as declared in the hr_job_pos package header

 Uses        : hr_utility

 Change List
 -----------

 Version Date      Author     ER/CR No. Description of Change
 -------+---------+----------+---------+--------------------------
 70.0    05-APR-93 TMATHERS             Date Created
 70.1    05-APR-93 TMATHERS             Change business_group_id into
                                        organization id for this test.
                                         added exit;
 70.2    05-APR-93 TMATHERS             Changed a comment line.
 70.3    22-APR-93 TMATHERS             Added hr_pos_bg_chk.
 115.1   02-Oct-99 SCNair               Date track position related changes.
 115.2   26-Jun-00 CCarter              Changed per_jobs to per_jobs_v for
								Job groups.
 =================================================================
*/
--
----------------------- BEGIN: hr_jp_predelete -------------------
--
--
PROCEDURE hr_jp_predelete(p_organization_id   INTEGER
                         ,p_business_group_id INTEGER) is
/*
  NAME
    hr_jp_predelete
  DESCRIPTION
    Battery of tests to see if an organization has jobs and positions
    and therefore may not be deleted.
  PARAMETERS
    p_organization_id  : Organization Id of Organization to be deleted.
    p_business_group_id   : Business Group id of Organization to be deleted.
*/
--
-- Storage Variable.
--
l_test_func varchar2(60);
--
begin
    --
     if p_business_group_id = p_organization_id then
    begin
    -- Do Any rows Exist in PER_JOBS.
    hr_utility.set_location('hr_job_pos.hr_jp_predelete',1);
    select '1'
    into l_test_func
    from sys.dual
    where exists ( select 1
    from PER_JOBS_V x
    where x.business_group_id = p_business_group_id);
    --
    if SQL%ROWCOUNT >0 THEN
      hr_utility.set_message(801,'HR_6131_ORG_JOBS_EXIST');
      hr_utility.raise_error;
    end if;
    exception
    when NO_DATA_FOUND THEN
      null;
    end;
    end if;
    --
    begin
    -- Do Any rows Exist in HR_ALL_POSITIONS_F.
    --
    -- Changed 02-Oct-99 SCNair (per_positions to hr_all_positions_f) date tracked position requirement
    --
    hr_utility.set_location('hr_job_pos.hr_jp_predelete',2);
    select '1'
    into l_test_func
    from sys.dual
    where exists ( select 1
    from HR_ALL_POSITIONS_F x
    where x.organization_id = p_organization_id);
    --
    if SQL%ROWCOUNT >0 THEN
      hr_utility.set_message(801,'HR_6557_ORG_POSITIONS_EXIST');
      hr_utility.raise_error;
    end if;
    exception
    when NO_DATA_FOUND THEN
      null;
    end;
    --
end hr_jp_predelete;
--
------------------------- END: hr_jp_predelete -------------------
--
----------------------- BEGIN: hr_pos_bg_chk -------------------
procedure hr_pos_bg_chk(
p_organization_id INTEGER) is
/*
  NAME
    hr_pos_bg_chk
  DESCRIPTION
    Tests to see if an organization has positions
    If so it may not be updated to a business group.
  PARAMETERS
    p_organization_id  : Organization Id of Business group to be created.
*/
--
-- Local Storage variable.
l_test_func varchar2(60);
begin
begin
-- Doing check on HR_ALL_POSITIONS_F.
--
-- Changed 02-Oct-99 SCNair (per_positions to HR_ALL_POSITIONS_F) Date tracked position requirement
hr_utility.set_location('hr_job_pos.hr_pos_bg_chk',1);
select '1'
into l_test_func
from sys.dual
where exists ( select 1
from HR_ALL_POSITIONS_F x
where x.ORGANIZATION_ID = p_organization_id);
--
if SQL%ROWCOUNT >0 THEN
  hr_utility.set_message(801,'HR_6726_BG_POS_EXIST');
  hr_utility.raise_error;
end if;
exception
when NO_DATA_FOUND THEN
  null;
end;
--
end hr_pos_bg_chk;
------------------------- END: hr_pos_bg_chk -------------------
--
end hr_job_pos;

/
