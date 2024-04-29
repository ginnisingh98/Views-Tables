--------------------------------------------------------
--  DDL for Package PER_RI_PRE_DATAPUMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RI_PRE_DATAPUMP" AUTHID CURRENT_USER as
/* $Header: perripmp.pkh 120.0 2006/04/11 14:50:40 ndorai noship $ */
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
        This is a wrapper procedure for Datapump functionality from
        workbench
History
	Date		Who		Version	What?
	----		---		-------	-----
	16 Jan 2006	ikasire 	115.0		Created
*/
--
-- --------------------------------------------------------------------------------
-- |-----------------------------< PRE_DATAPUMP_PROCESS >-------------------------|
-- -------------------------------------------------------------------------------+
procedure pre_datapump_process
          (errbuf                     out nocopy varchar2,
           retcode                    out nocopy number,
           p_batch_id                 in  number  default null,
           p_validate                 in  varchar2 default 'N'
  );
--
--
end per_ri_pre_datapump;

 

/
