--------------------------------------------------------
--  DDL for Package Body IGI_IAC_REVAL_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IAC_REVAL_VALIDATION" AS
-- $Header: igiiarvb.pls 120.11.12000000.1 2007/08/01 16:18:26 npandya ship $
 --===========================FND_LOG.START=====================================

 g_state_level NUMBER;
 g_proc_level  NUMBER;
 g_event_level NUMBER;
 g_excep_level NUMBER;
 g_error_level NUMBER;
 g_unexp_level NUMBER;
 g_path        VARCHAR2(100);

 --===========================FND_LOG.END=======================================

l_rec igi_iac_revaluation_rates%rowtype;  -- create this for quicker access via sql navigator

function validate_period_counter ( fp_asset_id       number
                                  , fp_book_type_code varchar2
                                  , fp_period_counter number
                                  )
return  boolean is
  cursor c_not_valid is
    select max(period_counter) period_counter
    from  fa_deprn_summary
    where asset_id              = fp_asset_id
    and   book_type_code        = fp_book_type_code
    ;
    l_is_valid boolean ;
    l_path varchar2(100);
begin

    l_is_valid := false;
    l_path := g_path||'validate_period_counter';

  /* if the user attempts to process an asset which has had ocassional revaluation
     more than once per period, then return false */
  l_is_valid := false;
  for l_nv in c_not_valid loop
      if l_nv.period_counter > fp_period_counter then
         return false;
      else
         return true;
      end if;
  end loop;

  return l_is_valid;
exception when others then
   igi_iac_debug_pkg.debug_unexpected_msg(l_path);
   return false;
end;


function validate_cost        ( fp_asset_id       number
                              , fp_book_type_code varchar2
                              , fp_revaluation_id number
                              )
return boolean is
  cursor c_not_valid is
    select revaluation_factor
    from igi_iac_reval_asset_rules
    where asset_id       = fp_asset_id
    and   book_type_code = fp_book_type_code
    and   revaluation_id = fp_revaluation_id;
  l_path varchar2(100);
begin
   l_path := g_path||'validate_cost';
   for l_nv in c_not_valid loop
       if l_nv.revaluation_factor = 1 then
          return false;
       else
          return true;
       end if;
  end loop;
exception when others then
   igi_iac_debug_pkg.debug_unexpected_msg(l_path);
   return false;
end;


function validate_fully_retired ( fp_asset_id       number
                                 , fp_book_type_code varchar2
                                 )
return  boolean is
  cursor c_not_valid is
    select 'x' valid_rec
    from  fa_books
    where asset_id              = fp_asset_id
    and   book_type_code        = fp_book_type_code
    and   cost                  = 0
    and   transaction_header_id_out is null
    ;
    l_is_valid boolean;
    l_path varchar2(100);
begin

  l_is_valid := false;
  l_path := g_path||'validate_fully_retired';

  for l_nv in c_not_valid loop
         return false;
  end loop;

  return true;
exception when others then
   igi_iac_debug_pkg.debug_unexpected_msg(l_path);
   return false;
end;


function validate_reval_type     ( fp_asset_id       number
                                 , fp_revaluation_id number
                                 , fp_book_type_code varchar2
                                 , fp_reval_type     varchar2
                                 , fp_period_counter number
                                 )
return  boolean is

-- Bug 3013442 (Tpradhan) ... Begin
-- Added the condition to check for status not OBSOLETE to the cursor below

  cursor c_not_valid is
    select 'x'
    from  igi_iac_transaction_headers
    where asset_id              = fp_asset_id
    and   book_type_code        = fp_book_type_code
    and   period_counter        = fp_period_counter
    and   mass_Reference_id       <> fp_revaluation_id
    and   revaluation_type_flag in ( 'O', 'P' )
    and   fp_reval_type         = 'O'
    and adjustment_status <> 'OBSOLETE'
    ;

-- Bug 3013442 (Tpradhan) ... End

    l_is_valid boolean;
    l_path varchar2(100);
begin

    l_is_valid := true;
    l_path := g_path||'validate_reval_type';

  /* if the user attempts to process an asset which has had ocassional revaluation
     more than once per period, then return false */
  l_is_valid := true;
  for l_nv in c_not_valid loop
     l_is_valid := false;
     exit;
  end loop;

  return l_is_valid;
exception when others then
   igi_iac_debug_pkg.debug_unexpected_msg(l_path);
   return false;
end;

function validate_fa_revals   ( fp_asset_id       number
                              , fp_book_type_code varchar2
                              )
return boolean is
begin
 if igi_iac_common_utils.Any_Reval_in_Corp_Book ( P_book_type_Code => fp_book_type_code ,
                                                   P_Asset_id      => fp_asset_id
                                                   )
 then
     return false;
 else
     return true;
 end if;
exception when others then
   return true;
end;

function  validate_new_fa_txns ( fp_asset_id       number
                               , fp_book_type_code varchar2
                               , fp_period_counter number
                               )
return boolean is
  l_path varchar2(100);
begin

  l_path := g_path||'validate_new_fa_txns';

  if igi_iac_common_utils.Any_Txns_In_Open_Period( P_book_type_Code => fp_book_type_code ,
                                                   P_Asset_id       => fp_asset_id
                                                 )
  then
     return false;
  else
     return true;
  end if;
exception when others then
   igi_iac_debug_pkg.debug_unexpected_msg(l_path);
   return false;
end;


function  not_retired_in_curr_year ( fp_asset_id       number
                               , fp_book_type_code     varchar2
                               )
return  boolean is
 l_retirements varchar2(1);
 l_path varchar2(100);
begin

   l_retirements  := 'X';
   l_path := g_path||'not_retired_in_curr_year';

  igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Begin retirements check');
  if not igi_iac_common_utils.any_ret_in_curr_yr(p_book_type_code => fp_book_type_code
                                                ,p_asset_id => fp_asset_id
                                                ,p_retirements => l_retirements
                                                )
  then
     igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'Error retirements check');
  end if;

  igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Retirements '|| l_retirements);

  if l_retirements = 'Y' then
     return false;
  else
     return true;
  end if;
exception when others then
  igi_iac_debug_pkg.debug_unexpected_msg(l_path);
  return false;
end;

function  not_adjusted_asset      ( fp_asset_id       number
                               , fp_book_type_code varchar2
                               )
return boolean is
begin
 return true;
/****
 if not igi_iac_common_utils.ANY_ADJ_IN_BOOK(p_book_type_code => fp_book_type_code
                                                ,p_asset_id => fp_asset_id
                                                )
  then
    return true;
  end if;
***/
  return false;
exception when others then
  return true;
end;

FUNCTION Validate_Multiple_Previews( fp_asset_id       number
                              , fp_book_type_code varchar2
                              , fp_period_counter number
                              , fp_revaluation_id number
                              , fp_preview_reval_id OUT NOCOPY number
                               )
RETURN BOOLEAN IS
    CURSOR c_preview_in_curr_period IS
    SELECT mass_reference_id revaluation_id
    FROM  igi_iac_transaction_headers
    WHERE asset_id              = fp_asset_id
    AND   book_type_code        = fp_book_type_code
    AND   period_counter        = fp_period_counter
    AND   transaction_type_code = 'REVALUATION'
    AND   adjustment_status     = 'PREVIEW'
    AND   mass_Reference_id     <> fp_revaluation_id;

    l_path                  VARCHAR2(100);
    l_muliple_previews      BOOLEAN;

BEGIN
    l_path  := g_path||'is_Asset_in_Preview';
    l_muliple_previews := FALSE;
    FOR l_preview IN c_preview_in_curr_period LOOP
        l_muliple_previews := TRUE;
        fp_preview_reval_id := l_preview.revaluation_id;
        EXIT;
    END LOOP;

    IF l_muliple_previews THEN
        RETURN FALSE;
    ELSE
        RETURN TRUE;
    END IF;
EXCEPTION WHEN others THEN
  igi_iac_debug_pkg.debug_unexpected_msg(l_path);
  RETURN FALSE;
END Validate_Multiple_Previews;

function  validate_asset      ( fp_asset_id       number
                              , fp_book_type_code varchar2
                              , fp_period_counter number
                              , fp_reval_type     varchar2
                              , fp_revaluation_id number
                               )
return  boolean is
begin
  if  not_adjusted_asset      ( fp_asset_id      => fp_asset_id
                               , fp_book_type_code => fp_book_type_code
                               )
  and not_retired_in_curr_year ( fp_asset_id       => fp_asset_id
                               , fp_book_type_code => fp_book_type_code
                               )
  and validate_new_fa_txns ( fp_asset_id        => fp_asset_id
                           , fp_book_type_code => fp_book_type_code
                           , fp_period_counter => fp_period_counter
                           )
  and validate_fa_revals   ( fp_asset_id       => fp_asset_id
                           , fp_book_type_code => fp_book_type_code
                           )
  and validate_reval_type  ( fp_asset_id      => fp_asset_id
                              , fp_revaluation_id => fp_revaluation_id
                              , fp_book_type_code => fp_book_type_code
                              , fp_reval_type    => fp_reval_type
                              , fp_period_counter => fp_period_counter
                           )
  then
      return true;
  else
      return false;
  end if;

end;

function   validate_asset      ( fp_asset_id       number
                              , fp_book_type_code varchar2
                              , fp_period_counter number
                              , fp_reval_type     varchar2
                              , fp_revaluation_id number
                              , fp_exceptions          IN OUT NOCOPY    IGI_IAC_TYPES.iac_reval_exceptions
                              , fp_exceptions_idx      IN OUT NOCOPY    IGI_IAC_TYPES.iac_reval_exceptions_idx
                              )
return  boolean is
   l_success_ct number;
   l_failure_ct number;
   l_asset_num  varchar2(100);
   fp_exceptions_old     IGI_IAC_TYPES.iac_reval_exceptions;
   fp_exceptions_idx_old IGI_IAC_TYPES.iac_reval_exceptions_idx;
   l_path varchar2(100);
   l_preview_reval_id   NUMBER;

   procedure add_exception (p_mesg_code in varchar2)  is
     l_mesg varchar2(2000);
     l_path varchar2(100);
   begin

      l_path := g_path||'add_exception';

      igi_iac_debug_pkg.debug_other_string(g_excep_level,l_path,'+adding exception');
      begin
          fnd_message.set_name( 'IGI', p_mesg_code );
          igi_iac_debug_pkg.debug_other_msg(g_error_level,l_path,FALSE);
          l_mesg := fnd_message.get;
      exception when others then
	   igi_iac_debug_pkg.debug_unexpected_msg(l_path);
           l_mesg := p_mesg_code;
      end;
      if l_mesg is null then
        l_mesg := p_mesg_code;
      end if;
      igi_iac_debug_pkg.debug_other_string(g_excep_level,l_path,'+mesg is '|| l_mesg);
      fp_exceptions_idx := nvl(fp_exceptions_idx,0) + 1;
      fp_exceptions ( fp_exceptions_idx).asset_id       := fp_asset_id;
      fp_exceptions ( fp_exceptions_idx).book_type_code := fp_book_type_code;
      fp_exceptions ( fp_exceptions_idx).reason         := l_mesg ;
   end;

   procedure add_exception (p_mesg_code in varchar2,
                            p_token in number)  is
     l_mesg varchar2(2000);
     l_path varchar2(100);
   begin

     l_path := g_path||'add_exception';

     igi_iac_debug_pkg.debug_other_string(g_excep_level,l_path,'+adding exception');
      begin
          fnd_message.set_name( 'IGI', p_mesg_code );
          fnd_message.set_token('REVALUATION_ID',p_token);
          igi_iac_debug_pkg.debug_other_msg(g_error_level,l_path,FALSE);
          l_mesg := fnd_message.get;
      exception when others then
	   igi_iac_debug_pkg.debug_unexpected_msg(l_path);
           l_mesg := p_mesg_code;
      end;
      if l_mesg is null then
        l_mesg := p_mesg_code;
      end if;
      igi_iac_debug_pkg.debug_other_string(g_excep_level,l_path,'+mesg is '|| l_mesg);
      fp_exceptions_idx := nvl(fp_exceptions_idx,0) + 1;
      fp_exceptions ( fp_exceptions_idx).asset_id       := fp_asset_id;
      fp_exceptions ( fp_exceptions_idx).book_type_code := fp_book_type_code;
      fp_exceptions ( fp_exceptions_idx).reason         := l_mesg ;
   end;

begin

   l_success_ct := 0;
   l_failure_ct := 0;
   l_path := g_path||'validate_asset';

   fp_exceptions_old     := fp_exceptions;
   fp_exceptions_idx_old := fp_exceptions_idx;

  select asset_number
  into   l_asset_num
  from   fa_additions
  where  asset_id = fp_asset_id
  ;

  igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Validating the asset '|| l_asset_num);

  if validate_period_counter
                                 ( fp_asset_id       => fp_asset_id
                                 , fp_book_type_code => fp_book_type_code
                                 , fp_period_counter => fp_period_counter
                                 )
  then
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+The period counter is ok');
    l_success_ct := l_success_ct + 1;
  else
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Calling Add Exception');
    add_exception('IGI_IAC_REVAL_EXCEP_PERIOD_CTR');
    l_failure_ct := l_failure_ct + 1;
  end if;

  if not_adjusted_asset ( fp_asset_id       => fp_asset_id
                       , fp_book_type_code  => fp_book_type_code
                       )
  then
   igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'+The asset has not been adjusted');
     l_success_ct := l_success_ct + 1;
  else
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Calling Add Exception');
     add_exception('IGI_IAC_REVAL_EXCEP_ASSET_ADJ');
     l_failure_ct := l_failure_ct + 1;
  end if;

  if validate_cost( fp_asset_id       => fp_asset_id
                  , fp_book_type_code => fp_book_type_code
                  , fp_revaluation_id => fp_revaluation_id
                  )
  then
      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+The current cost and new cost of the asset are different');
      l_success_ct := l_success_ct + 1;
  else
      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Calling Add Exception');
      add_exception('IGI_IAC_REVAL_EXCEP_SAME_COSTS');
      l_failure_ct := l_failure_ct + 1;
  end if;

  if not_retired_in_curr_year ( fp_asset_id       => fp_asset_id
                       , fp_book_type_code  => fp_book_type_code
                       )
  then
   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+The asset has no pending retirements/reinstatements');
     l_success_ct := l_success_ct + 1;
  else
  /*For bug no 2647561 changed the name of the message to the right name*/
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Calling Add Exception');
     add_exception('IGI_IAC_REVAL_EXCEP_PEND_TXNS');
     l_failure_ct := l_failure_ct + 1;
  end if;

  if validate_fully_retired ( fp_asset_id       => fp_asset_id
                       , fp_book_type_code  => fp_book_type_code
                       )
  then
   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+The asset has no pending retirements/reinstatements');
     l_success_ct := l_success_ct + 1;
  else
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Calling Add Exception');
     add_exception('IGI_IAC_REVAL_EXCEP_PEND_TXNS');
     l_failure_ct := l_failure_ct + 1;
  end if;

  if  validate_new_fa_txns   ( fp_asset_id       => fp_asset_id
                              , fp_book_type_code => fp_book_type_code
                              , fp_period_counter => fp_period_counter
                              )
  then
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'the asset has no new transactions that would affect revaluation');
     l_success_ct := l_success_ct + 1;
  else
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Calling Add Exception');
     add_exception('IGI_IAC_REVAL_EXCEP_NEW_TXNS');
     l_failure_ct := l_failure_ct + 1;
  end if;

  if  validate_fa_revals   ( fp_asset_id       => fp_asset_id
                           , fp_book_type_code => fp_book_type_code
                           )
  then
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'the asset has no CORE FA revaluations');
     l_success_ct := l_success_ct + 1;
  else
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Calling Add Exception');
    add_exception('IGI_IAC_REVAL_EXCEP_PEND_TXNS');
     l_failure_ct := l_failure_ct + 1;
  end if;

  if  validate_reval_type  ( fp_asset_id       => fp_asset_id
                           , fp_revaluation_id => fp_revaluation_id
                           , fp_book_type_code => fp_book_type_code
                           , fp_reval_type     => fp_reval_type
                           , fp_period_counter => fp_period_counter
                           )
  then
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'the revaluation type is valid');
     l_success_ct := l_success_ct + 1;
  else
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Calling Add Exception');
    add_exception('IGI_IAC_REVAL_EXCEP_REVAL_TYPE');
     l_failure_ct := l_failure_ct + 1;
  end if;

  IF Validate_Multiple_Previews  ( fp_asset_id       => fp_asset_id
                           , fp_revaluation_id => fp_revaluation_id
                           , fp_book_type_code => fp_book_type_code
                           , fp_period_counter => fp_period_counter
                           , fp_preview_reval_id => l_preview_reval_id
                           )
  then
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'asset not in any other preview revaluation');
     l_success_ct := l_success_ct + 1;
  else
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Calling Add Exception');
    add_exception('IGI_IAC_REVAL_EXCEP_PREVIEW',l_preview_reval_id);
     l_failure_ct := l_failure_ct + 1;
  end if;

  if l_failure_ct = 0 then
     if l_success_ct = 0 then
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+validation did not do anything');
     else
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+validation checks passed');
     end if;
     return true ;
  else
     igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'+validation checks failed');
     return false;
  end if;

  igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'End validation of the asset');
exception when others then
   igi_iac_debug_pkg.debug_unexpected_msg(l_path);
   fp_exceptions     := fp_exceptions_old;
   fp_exceptions_idx := fp_exceptions_idx_old;
   return false;		-- Bug No. 2647561 (Tpradhan) - Replaced "Raise" with "return false" since Raise just raises the OTHERS exception which then propagates
   				--				to Do_Revaluation_Asset where the exception is handled and that procedure returns TRUE instead of FALSE

end;

BEGIN

 --===========================FND_LOG.START=====================================

 g_state_level 	     :=	FND_LOG.LEVEL_STATEMENT;
 g_proc_level  	     :=	FND_LOG.LEVEL_PROCEDURE;
 g_event_level 	     :=	FND_LOG.LEVEL_EVENT;
 g_excep_level 	     :=	FND_LOG.LEVEL_EXCEPTION;
 g_error_level 	     :=	FND_LOG.LEVEL_ERROR;
 g_unexp_level 	     :=	FND_LOG.LEVEL_UNEXPECTED;
 g_path              := 'IGI.PLSQL.igiiarvb.IGI_IAC_REVAL_VALIDATION.';

 --===========================FND_LOG.END=====================================

END;

/
