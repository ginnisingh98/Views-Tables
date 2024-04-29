--------------------------------------------------------
--  DDL for Package Body WMS_CUSTAPI_CONC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_CUSTAPI_CONC_PKG" as
 /* $Header: WMSCCPKB.pls 120.1 2006/08/10 11:32:38 bradha noship $ */
--
l_debug  	  number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
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
,  p_level    in number
) is
begin
      INV_LOG_UTIL.trace(p_message, 'WMS_CUSTAPI_CONC_PKG', p_level);
end trace;
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
) is

  l_proc       varchar2(72) := 'GEN_WMS_CUSTAPI_SYS_OBJS :';
  l_msg_count  number;
  l_msg_data   varchar2(240);
begin
   if (l_debug = 1) then
      trace(l_proc ||' Entering procedure gen_wms_custapi_sys_objs  '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
      trace(l_proc ||' Before calling "wms_atf_reg_cust_apis.create_wms_system_objects"....', 1);
      trace(l_proc ||' No Input Parameters ');
   end if;

   wms_atf_reg_cust_apis.create_wms_system_objects(
	                    x_retcode  => retcode
	                 ,  x_errbuf   => errbuf );

   if (l_debug = 1) then
      trace(l_proc ||' After calling "wms_atf_reg_cust_apis.create_wms_system_objects"....', 1);
      trace(l_proc ||' Out Parameters ');
      trace(l_proc ||' errbuf is ' || errbuf);
      trace(l_proc ||' l_msg_count is ' || l_msg_count);
      trace(l_proc ||' l_msg_data is ' || l_msg_data);
      trace(l_proc ||'      ');
      trace(l_proc ||'      ');
      trace(l_proc ||' Exiting procedure gen_wms_custapi_sys_objs  '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
   end if;
end gen_wms_custapi_sys_objs;
--
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
) is

  l_proc       varchar2(72) := 'CREATE_DELETE_API_CALLS :';
  l_msg_count  number;
  l_msg_data   varchar2(240);
  --l_hook_short_name_id  number;

begin

   if (l_debug = 1) then
      trace(l_proc ||' Entering procedure create_delete_api_calls  '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
      trace(l_proc ||' Input Parameters ');
      trace(l_proc ||' Short Name ID: '|| p_hook_short_name_id);
      trace(l_proc ||' Call Package : '|| p_call_package);
      trace(l_proc ||' Call Procedure : '|| p_call_procedure);
      trace(l_proc ||' Call Description : '|| p_call_description);
      trace(l_proc ||' Effective To Date : '|| p_effective_to_date);
      trace(l_proc ||' Call Mode : '|| p_mode);
      trace(l_proc ||' Before calling "wms_atf_reg_cust_apis.create_delete_api_calls"....', 1);
   end if;

   wms_atf_reg_cust_apis.create_delete_api_call(
       p_hook_short_name_id  =>  p_hook_short_name_id
   ,   p_call_package        =>  p_call_package
   ,   p_call_procedure      =>  p_call_procedure
   ,   p_call_description    =>  p_call_description
   ,   p_effective_to_date   =>  FND_DATE.canonical_to_date(p_effective_to_date)
   ,   p_mode                =>  p_mode
   ,   x_retcode             =>  retcode
   ,   x_errbuf              =>  errbuf
   );

   if (l_debug = 1) then
      trace(l_proc ||' After calling "wms_atf_reg_cust_apis.create_delete_api_calls"....', 1);
      trace(l_proc ||' Out Parameters ');
      trace(l_proc ||' errbuf is ' || errbuf);
      trace(l_proc ||' retcode is ' || retcode);
      trace(l_proc ||'      ');
      trace(l_proc ||'      ');
      trace(l_proc ||' Exiting procedure create_delete_api_call  '|| to_char(sysdate, 'YYYY-MM-DD HH:DD:SS'), 1);
   end if;
end create_delete_api_calls;

end wms_custapi_conc_pkg;

/
