--------------------------------------------------------
--  DDL for Package HR_APPLICANT_DATAUPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_APPLICANT_DATAUPD" AUTHID CURRENT_USER as
/* $Header: hraplupd.pkh 120.0 2005/05/30 22:43 appldev noship $ */

-- --------------------------------------------------------------------------+
-- --------------------< ConvertToApplicant >--------------------------------|
-- --------------------------------------------------------------------------+
-- Description:
-- This procedure converts person into applicant whenever if finds active
-- applicant assignments opened and the application has a termination date.
--
PROCEDURE ConvertToApplicant(p_start_rowid     IN rowid
                            ,p_end_rowid       IN rowid
                            ,p_rows_processed OUT nocopy number);

-- --------------------------------------------------------------------------+
-- -----------------< Update_APL_using_LTU >---------------------------------|
-- --------------------------------------------------------------------------+
--
PROCEDURE Update_APL_using_LTU
   (errbuf              OUT nocopy varchar2
   ,retcode             OUT nocopy number
   ,p_this_worker       IN number
   ,p_total_workers     IN number
   ,p_table_owner       IN varchar2
   ,p_table_name        IN varchar2
   ,p_update_name       IN varchar2
   ,p_batchsize         IN number);

-- --------------------------------------------------------------------------+
--                        Update_APL_inCM
-- --------------------------------------------------------------------------+
-- This is run as a concurrent program
--
PROCEDURE Update_APL_inCM_Manager
   (p_errbuf        out nocopy varchar2
   ,p_retcode       out nocopy varchar2
   ,X_batch_size    in  number
   ,X_Num_Workers   in  number
   ,p_process_All   in  varchar2
   ,p_caller        in  varchar2
   ,p_apl_id        in  number default 0   -- if prm is optional in SRS def,
                                           -- then we need a default value here
   );

PROCEDURE Update_APL_inCM_Worker
   (p_errbuf        out nocopy varchar2
   ,p_retcode       out nocopy varchar2
   ,X_batch_size    in  number
   ,X_Worker_Id     in  number
   ,X_Num_Workers   in  number
   ,p_process_All   in  varchar2
   ,p_caller        in  varchar2
   ,p_updateName    in  varchar2
   ,p_apl_id        in  number default 0    -- if prm is optional in SRS def,
                                            -- then we need a default value here
   );

-- --------------------------------------------------------------------------+
--                           ValidateRun
-- --------------------------------------------------------------------------+
-- Returns 'TRUE' if process has been run otherwise 'FALSE'
--
PROCEDURE ValidateRun(p_result OUT nocopy varchar2);
-- --------------------------------------------------------------------------+
--                      RunUpdateMode
-- --------------------------------------------------------------------------+
-- Returns the value of the profile option:
--    + P: run within adpatch
--    + D: run when concurrent program is re-started (deferred process)
-- If profile value is not set, then returns "ADPATCH"
--
FUNCTION RunUpdateMode RETURN varchar2;
--
-- --------------------------------------------------------------------------+
--                     isADPATCHMode
-- --------------------------------------------------------------------------+
FUNCTION isADPATCHMode return boolean;
--
-- --------------------------------------------------------------------------+
--                     isDEFERMode
-- --------------------------------------------------------------------------+
FUNCTION isDEFERMode return boolean;
--
--
end hr_applicant_dataupd;

 

/
