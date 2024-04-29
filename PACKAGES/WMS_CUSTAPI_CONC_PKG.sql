--------------------------------------------------------
--  DDL for Package WMS_CUSTAPI_CONC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_CUSTAPI_CONC_PKG" AUTHID CURRENT_USER as
 /* $Header: WMSCCPKS.pls 120.1 2006/08/10 11:31:17 bradha noship $ */
--
--
-- ---------------------------------------------------------------------------|
-- |-------------------------------< trace >----------------------------------|
-- ---------------------------------------------------------------------------|
-- {Start Of Comments}
--
-- Description:
-- Wrapper around the tracing utility.
--
-- Prerequisites:
-- None
--
-- In Parameters:
--   Name        Reqd Type     Description
--   p_message   Yes  varchar2 Message to be displayed in the log file.
--   p_prompt    Yes  varchar2 Prompt.
--   p_level     No   number   Level.
--
-- Post Success:
--   None.
--
-- Post Failure:
--   None
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--

Procedure trace(
   p_message  in varchar2
,  p_level    in number default 4
);
--
-- -------------------------------------------------------------------------------------------
-- |---------------------------< gen_wms_custapi_sys_objs >-----------------------------------|
-- -------------------------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Wrapper procedure to call API to create the spec and body for the system generated
--   package.
--
-- Prerequisites:
--   None
--
-- In Parameters:
--   Name                Reqd Type     Description
--   ----------------    ---- -------- -------------------
--   none
--
--
-- Post success:
--   The system package spec(s)/body(s) are created in the database.
--
-- Post Failure:
--   Unexpected Oracle errors and serious application errors will be raised
--   as a PL/SQL exception. When these errors are raised this procedure will
--   abort the processing.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
Procedure gen_wms_custapi_sys_objs(
   errbuf   out NOCOPY varchar2
,  retcode  out NOCOPY number
);
--
-- -------------------------------------------------------------------------------------------
-- |---------------------------< create_delete_api_calls >------------------------------------|
-- -------------------------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description:
--   Wrapper procedure to call API to create or delete Custom API hook calls.
--
-- Prerequisites:
--   None
--
-- In Parameters:
--   Name                Reqd Type     Description
--   ----------------    ---- -------- -------------------
--   none
--
--
-- Post success:
--   The system package spec(s)/body(s) are created in the database.
--
-- Post Failure:
--   Unexpected Oracle errors and serious application errors will be raised
--   as a PL/SQL exception. When these errors are raised this procedure will
--   abort the processing.
--
-- Access Status:
--   Internal Development Use Only.
--
-- {End Of Comments}
--
Procedure create_delete_api_calls(
   errbuf                 out NOCOPY varchar2
,  retcode                out NOCOPY number
,  p_hook_short_name_id   in  number
,  p_call_package      	  in  varchar2
,  p_call_procedure       in  varchar2
,  p_call_description     in  varchar2
,  p_effective_to_date 	  in  varchar2
,  p_mode                 in  varchar2
);
--
end wms_custapi_conc_pkg;

 

/
