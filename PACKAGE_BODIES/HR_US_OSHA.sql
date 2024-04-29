--------------------------------------------------------
--  DDL for Package Body HR_US_OSHA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_US_OSHA" AS
/* $Header: peusosha.pkb 120.0 2005/05/31 22:42:20 appldev noship $ */
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
 Name        : hr_us_osha  (BODY)

 Description : This package declares a function required to generate
	       OSHA-reportable incident case numbers.

 Change List
 -----------

 Version Date      Author     ER/CR No. Description of Change
 -------+---------+----------+---------+--------------------------
 70.0    27-Apr-95 SSDESAI              Created
 70.2    10-JUL-97 MBOCUTT              By using profile options the
110.1                                   date format is now in canonical format
					so ammend the substr command on the
					p_incident_year to reflect this.
 115.1   13-AUG-01 GPERRY               Changed routine so that it creates
                                        unique case numbers and fills in missed
                                        case numbers.
                                        WWBUG 1714703.
 ================================================================= */
--
--
-- Called as a default for the Case Number segment of the
-- OSHA-reportable Incident Flex Structure.
--
-- Function used to generate the case number.
--
function generate_case_number return varchar2 IS
  --
  v_case_number	varchar2(150);
  l_dummy       varchar2(1);
  --
  cursor c1 is
    select null
    from   sys.dual
    where  exists (select null
                   from   per_analysis_criteria pac,
                          fnd_id_flex_structures fif
                   where  pac.id_flex_num = fif.id_flex_num
                   and    fif.id_flex_structure_code = 'OSHA-REPORTABLE_INCIDENT'
                   and    pac.segment1 = v_case_number);
  --
  cursor c2 is
    select max(pac.segment1)+v_case_number
    from   per_analysis_criteria pac,
           fnd_id_flex_structures fif
    where  pac.id_flex_num = fif.id_flex_num
    and    fif.id_flex_structure_code = 'OSHA-REPORTABLE_INCIDENT';
  --
begin
  --
  select per_osha_case_number_s.nextval
  into   v_case_number
  from   sys.dual;
  --
  -- If the value is taken then use the max value + sequence, that will be
  -- unique, otherwise use the sequence number to fill in some of the gaps.
  -- Gradually using this technique we would be able to fill in all the
  -- gaps.
  --
  open c1;
    --
    fetch c1 into l_dummy;
    --
    if c1%found then
      --
      -- The number has been taken so use the max id + the sequence number
      --
      open c2;
        --
        fetch c2 into v_case_number;
        --
      close c2;
      --
    end if;
    --
  close c1;
  --
  return(v_case_number);
  --
end generate_case_number;
--
END hr_us_osha;

/
