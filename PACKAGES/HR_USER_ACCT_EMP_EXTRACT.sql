--------------------------------------------------------
--  DDL for Package HR_USER_ACCT_EMP_EXTRACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_USER_ACCT_EMP_EXTRACT" AUTHID CURRENT_USER AS
/* $Header: hrempext.pkh 115.1 2002/12/11 06:48:18 hjonnala noship $*/
--
--
-- |--------------------------------------------------------------------------|
-- |--< PRIVATE GLOBAL VARIABLES >--------------------------------------------|
-- |--------------------------------------------------------------------------|

--
/*
||===========================================================================
|| PROCEDURE: run_process
||----------------------------------------------------------------------------
||
|| Description:
||     This procedure is invoked by Concurrent Manager to extract
||     employees based on input parameters passed.
||
|| Pre-Conditions:
||     Employee Data must exist on the database.
||
|| Input Parameters:
||
|| Output Parameters:
||
|| In out nocopy Parameters:
||
|| Post Success:
||      Selected employees are written to hr_pump_batch_lines table.
||
|| Post Failure:
||     Raise exception.
||
|| Access Status:
||     Public
||
||=============================================================================
*/
  PROCEDURE run_process (
     errbuf                     out nocopy varchar2
    ,retcode                    out nocopy number
    ,p_batch_name               in hr_pump_batch_headers.batch_name%TYPE
    ,p_date_from                in varchar2 default null
    ,p_date_to                  in varchar2 default null
    ,p_business_group_id        in per_all_people_f.business_group_id%type
    ,p_single_org_id            in per_organization_units.organization_id%type
                                   default null
    ,p_organization_structure_id in
                   per_organization_structures.organization_structure_id%type
                                   default null
    ,p_org_structure_version_id in
                   per_org_structure_versions.org_structure_version_id%type
                                   default null
    ,p_parent_org_id            in per_organization_units.organization_id%type
                                   default null
    ,p_run_type                 in varchar2
  );
--
--
END HR_USER_ACCT_EMP_EXTRACT;

 

/
