--------------------------------------------------------
--  DDL for Package Body OKC_TEMPLATE_KEYWORD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_TEMPLATE_KEYWORD_PVT" as
-- $Header: OKCVTKWB.pls 120.2 2005/10/11 02:46:34 ndoddi noship $

l_debug varchar2(1) := nvl(fnd_profile.value('AFLOG_ENABLED'),'N');

retcode_success   constant varchar2(1) := '0';
retcode_warning   constant varchar2(1) := '1';
retcode_error     constant varchar2(1) := '2';

  g_pkg_name                   constant   varchar2(200) := 'OKC_TEMPLATE_KEYWORD_PVT';

  g_dbg_level							  number 		:= FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  g_proc_level							  number		:= FND_LOG.LEVEL_PROCEDURE;
  g_excp_level							  number		:= FND_LOG.LEVEL_EXCEPTION;

procedure sync is
begin
   ad_ctx_ddl.set_effective_schema('okc');
   ad_ctx_ddl.sync_index('okc_terms_templates_ctx');
exception
when others then raise;
end;

procedure optimize is
begin
   ad_ctx_ddl.set_effective_schema('okc');
   ad_ctx_ddl.optimize_index (
      idx_name => 'okc_terms_templates_ctx',
      optlevel => ad_ctx_ddl.optlevel_full,
      maxtime  => ad_ctx_ddl.maxtime_unlimited
  );
exception
when others then raise;
end;

procedure sync_ctx(errbuf out nocopy varchar2, retcode out nocopy varchar2)
as
  l_api_name        constant varchar2(30) := 'concurrent_sync_ctx';
  l_api_version     constant varchar2(30) := 1.0;
begin
   /*if (l_debug = 'Y') then
      okc_debug.set_indentation(l_api_name);
      okc_debug.log('100: entering ',2);
   end if;*/

   if ( g_proc_level >= g_dbg_level ) then
	fnd_log.string(g_proc_level,
	    g_pkg_name, '100: entering ');
   end if;

   sync;
   retcode := retcode_success;
   /*if (l_debug = 'Y') then
      okc_debug.log('200: leaving ',2);
      okc_debug.reset_indentation;
   end if;*/

   if ( g_proc_level >= g_dbg_level ) then
	fnd_log.string(g_proc_level,
	    g_pkg_name, '200: leaving ');
   end if;
exception
when others then
   retcode := retcode_error;
   errbuf := substr(sqlerrm,1,200);
   /*if (l_debug = 'Y') then
      okc_debug.log('300: leaving ',2);
      okc_debug.reset_indentation;
   end if;*/

   if ( g_excp_level >= g_dbg_level ) then
	fnd_log.string(g_excp_level,
	    g_pkg_name, '300: leaving ');
   end if;
end;

procedure optimize_ctx(errbuf out nocopy varchar2, retcode out nocopy varchar2)
as
  l_api_name        constant varchar2(30) := 'concurrent_optimize_ctx';
  l_api_version     constant varchar2(30) := 1.0;
begin
   /*if (l_debug = 'Y') then
      okc_debug.set_indentation(l_api_name);
      okc_debug.log('100: entering ',2);
   end if;*/

   if ( g_proc_level >= g_dbg_level ) then
	fnd_log.string(g_proc_level,
	    g_pkg_name, '100: entering ');
   end if;

   sync_ctx(errbuf, retcode);
   if retcode <> retcode_success then
      /*if (l_debug = 'Y') then
         okc_debug.set_indentation(l_api_name);
         okc_debug.log('200: leaving ',2);
      end if;*/

      if ( g_proc_level >= g_dbg_level ) then
	 fnd_log.string(g_proc_level,
	     g_pkg_name, '200: leaving ');
      end if;
      return;
   end if;
   optimize;
   retcode := retcode_success;
   /*if (l_debug = 'Y') then
      okc_debug.set_indentation(l_api_name);
      okc_debug.log('300: leaving ',2);
   end if;*/

   if ( g_proc_level >= g_dbg_level ) then
      fnd_log.string(g_proc_level,
	  g_pkg_name, '300: leaving ');
   end if;

exception
when others then
   retcode := retcode_error;
   errbuf := substr(sqlerrm,1,200);
   /*if (l_debug = 'Y') then
      okc_debug.set_indentation(l_api_name);
      okc_debug.log('400: leaving ',2);
   end if;*/

   if ( g_excp_level >= g_dbg_level ) then
      fnd_log.string(g_excp_level,
	  g_pkg_name, '400: leaving ');
   end if;
end;

end;

/
