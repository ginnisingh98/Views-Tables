--------------------------------------------------------
--  DDL for Package Body FA_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_UTIL_PUB" as
/* $Header: FAPUTILB.pls 120.2.12010000.2 2009/07/19 09:52:45 glchen ship $   */

 g_log_statement_level      CONSTANT NUMBER   := FND_LOG.LEVEL_STATEMENT;
 g_log_procedure_level      CONSTANT NUMBER   := FND_LOG.LEVEL_PROCEDURE;
 g_log_event_level          CONSTANT NUMBER   := FND_LOG.LEVEL_EVENT ;
 g_log_exception_level      CONSTANT NUMBER   := FND_LOG.LEVEL_EXCEPTION;
 g_log_error_level          CONSTANT NUMBER   := FND_LOG.LEVEL_ERROR;
 g_log_unexpected_level     CONSTANT NUMBER   := FND_LOG.LEVEL_UNEXPECTED;
 g_log_runtime_level        NUMBER   := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

 g_print_debug              boolean ;

FUNCTION get_log_level_rec
   (x_log_level_rec         OUT NOCOPY FA_API_TYPES.log_level_rec_type) RETURN
BOOLEAN IS

begin

   -- needed to initialze the profile and release caches first
   if not fa_cache_pkg.fazprof then
      null;
   end if;

   g_log_runtime_level := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   x_log_level_rec.statement_level :=
               g_log_statement_level >= g_log_runtime_level;
   x_log_level_rec.procedure_level :=
               g_log_procedure_level >= g_log_runtime_level;
   x_log_level_rec.event_level :=
               g_log_event_level >= g_log_runtime_level;
   x_log_level_rec.exception_level :=
               g_log_exception_level >= g_log_runtime_level;
   x_log_level_rec.error_level :=
               g_log_error_level >= g_log_runtime_level;
   x_log_level_rec.unexpected_level :=
               g_log_unexpected_level >= g_log_runtime_level;
   x_log_level_rec.current_runtime_level := g_log_runtime_level;

   if (fa_cache_pkg.fazarel_release = 11) then

      -- intentional initialization here after the cache call
      g_print_debug := fa_cache_pkg.fa_print_debug;


      if (g_print_debug) then
          x_log_level_rec.statement_level       := TRUE;
          x_log_level_rec.current_runtime_level := g_log_statement_level;
      else
          x_log_level_rec.statement_level       := FALSE;
          x_log_level_rec.current_runtime_level := g_log_exception_level;
      end if;
   end if;

   x_log_level_rec.initialized := TRUE;

   return TRUE;
end;

END FA_UTIL_PUB ;

/
