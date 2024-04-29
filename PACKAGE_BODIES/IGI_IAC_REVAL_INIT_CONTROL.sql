--------------------------------------------------------
--  DDL for Package Body IGI_IAC_REVAL_INIT_CONTROL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IAC_REVAL_INIT_CONTROL" AS
-- $Header: igiiarib.pls 120.6.12000000.1 2007/08/01 16:17:15 npandya ship $

--===========================FND_LOG.START=====================================

g_state_level NUMBER	     :=	FND_LOG.LEVEL_STATEMENT;
g_proc_level  NUMBER	     :=	FND_LOG.LEVEL_PROCEDURE;
g_event_level NUMBER	     :=	FND_LOG.LEVEL_EVENT;
g_excep_level NUMBER	     :=	FND_LOG.LEVEL_EXCEPTION;
g_error_level NUMBER	     :=	FND_LOG.LEVEL_ERROR;
g_unexp_level NUMBER	     :=	FND_LOG.LEVEL_UNEXPECTED;
g_path        VARCHAR2(100)  := 'IGI.PLSQL.igiiarib.IGI_IAC_REVAL_INIT_CONTROL.';

--===========================FND_LOG.END=======================================

function init_control_for_srs    ( fp_asset_id               in number
                                 , fp_book_type_code         in varchar2
                                 , fp_revaluation_id         in number
                                 , fp_revaluation_mode       in varchar2
                                 , fp_period_counter         in number
                                 , fp_iac_reval_control_type out NOCOPY IGI_IAC_TYPES.iac_reval_control_type
                                 )
return  boolean is
  l_reval_control_type IGI_IAC_TYPES.iac_reval_control_type;
  fp_iac_reval_control_type_old IGI_IAC_TYPES.iac_reval_control_type;
  l_path varchar2(100) := g_path||'init_control_for_srs';

begin
   l_reval_control_type.commit_flag      := TRUE;
   l_reval_control_type.print_report     := TRUE;
   l_reval_control_type.show_exceptions  := TRUE;
   l_reval_control_type.transaction_type_code := 'REVALUATION';
   l_reval_control_type.calling_program := 'REVALUATION';
   l_reval_control_type.adjustment_status     := 'PREVIEW';
   l_reval_control_type.revaluation_mode := fp_revaluation_mode;

   fp_iac_reval_control_type := l_reval_control_type;
   return true;
exception when others then
   fp_iac_reval_control_type := fp_iac_reval_control_type_old;
   igi_iac_debug_pkg.debug_unexpected_msg(l_path);
   return false;
end;

/*
-- initialize if called for calculation from the form
*/

function init_control_for_calc    ( fp_asset_id               in number
                                  , fp_book_type_code         in varchar2
                                  , fp_revaluation_id         in number
                                  , fp_revaluation_mode       in varchar2
                                  , fp_period_counter         in number
                                  , fp_iac_reval_control_type out NOCOPY IGI_IAC_TYPES.iac_reval_control_type
                                 )
return  boolean is
  l_reval_control_type IGI_IAC_TYPES.iac_reval_control_type;
  fp_iac_reval_control_type_old IGI_IAC_TYPES.iac_reval_control_type;
  l_path varchar2(100) := g_path||'init_control_for_calc';
 begin
   l_reval_control_type.commit_flag      := FALSE;
   l_reval_control_type.print_report     := FALSE;
   l_reval_control_type.show_exceptions  := FALSE;
   l_reval_control_type.transaction_type_code := 'REVALUATION';
   l_reval_control_type.calling_program := 'REVALUATION';
   l_reval_control_type.adjustment_status     := 'PREVIEW';
   l_reval_control_type.revaluation_mode := fp_revaluation_mode;
   fp_iac_reval_control_type := l_reval_control_type;
   return true;
exception when others then
   fp_iac_reval_control_type := fp_iac_reval_control_type_old;
   igi_iac_debug_pkg.debug_unexpected_msg(l_path);
   return false;
end;

END;

/
