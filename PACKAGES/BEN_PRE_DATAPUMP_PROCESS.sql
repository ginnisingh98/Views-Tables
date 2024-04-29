--------------------------------------------------------
--  DDL for Package BEN_PRE_DATAPUMP_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PRE_DATAPUMP_PROCESS" AUTHID CURRENT_USER as
/* $Header: benripmp.pkh 120.1 2006/03/23 17:44:46 ikasired noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|                       Copyright (c) 1998 Oracle Corporation                  |
|                          Redwood Shores, California, USA                     |
|                               All rights reserved.                           |
+==============================================================================+
--
Name
        Enrollment Process
Purpose
        This is a wrapper procedure for Benefits enrollments pre datapump process.
History
	Date		Who		Version	What?
	----		---		-------	-----
	10 Jan 06	ikasire 	115.0		Created
        23 Mar 06       ikasired        115.1           Added beneficiaries too
*/
--
-- --------------------------------------------------------------------------------
-- |-----------------------------< PROCESS_DEPENDENT >-------------------------|
-- -------------------------------------------------------------------------------+
procedure pre_create_enrollment
          (p_batch_id                 in number  default null,
           p_validate                 in  varchar2 default 'N'
  ) ;
--
-- --------------------------------------------------------------------------------
-- |-----------------------------< PROCESS_DEPENDENT >-------------------------|
-- -------------------------------------------------------------------------------+
procedure pre_process_dependent
          (p_batch_id                 in number  default null,
           p_validate                 in  varchar2 default 'N'
  ) ;
--
-- --------------------------------------------------------------------------------
-- |-----------------------------< PROCESS_BENEFICIARY >-------------------------|
-- -------------------------------------------------------------------------------+
procedure pre_process_beneficiary
          (p_batch_id                 in number  default null,
           p_validate                 in  varchar2 default 'N'
  ) ;
--
end ben_pre_datapump_process;

 

/
