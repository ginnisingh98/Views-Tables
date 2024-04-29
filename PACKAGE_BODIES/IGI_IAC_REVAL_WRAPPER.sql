--------------------------------------------------------
--  DDL for Package Body IGI_IAC_REVAL_WRAPPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IAC_REVAL_WRAPPER" AS
-- $Header: igiiarwb.pls 120.6.12000000.1 2007/08/01 16:18:35 npandya ship $

l_rec igi_iac_revaluation_rates%rowtype;  -- create this for quicker access via sql navigator

--===========================FND_LOG.START=====================================

g_state_level NUMBER	     :=	FND_LOG.LEVEL_STATEMENT;
g_proc_level  NUMBER	     :=	FND_LOG.LEVEL_PROCEDURE;
g_event_level NUMBER	     :=	FND_LOG.LEVEL_EVENT;
g_excep_level NUMBER	     :=	FND_LOG.LEVEL_EXCEPTION;
g_error_level NUMBER	     :=	FND_LOG.LEVEL_ERROR;
g_unexp_level NUMBER	     :=	FND_LOG.LEVEL_UNEXPECTED;
g_path        VARCHAR2(100)  := 'IGI.PLSQL.igiiarwb.IGI_IAC_REVAL_WRAPPER.';

--===========================FND_LOG.END=======================================

function do_reval_calc_asset ( L_reval_params in out NOCOPY IGI_IAC_TYPES.iac_reval_params
                             , fp_reval_output_asset  IN OUT NOCOPY IGI_IAC_TYPES.iac_reval_output_asset
                             )
return boolean is

 l_reval_params_old        IGI_IAC_TYPES.iac_reval_params;
 fp_reval_output_asset_old IGI_IAC_TYPES.iac_reval_output_asset;
 l_path 		   varchar2(100) := g_path||'do_reval_calc_asset';
begin

   l_reval_params_old        := l_reval_params;
   fp_reval_output_asset_old := fp_reval_output_asset;

   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Revaluation engine prepare for calculations');
   IF NOT IGI_IAC_REVAL_ENGINE.Prepare_calculations
      ( p_iac_reval_params => L_reval_params )
   THEN
      -- add to the message stack!
      igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'Failure IGI_IAC_REVAL_ENGINE.Prepare_calculations');
      return false;
   END IF;
   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Revaluation engine first set of calculations...');
   IF NOT IGI_IAC_REVAL_ENGINE.First_set_calculations
      ( p_iac_reval_params => L_reval_params )
   THEN
      igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'Failure IGI_IAC_REVAL_ENGINE.First_set_calculations');
      -- add to the message stack!
      return false;
   END IF;

   fp_reval_output_asset := L_Reval_params.reval_output_asset;

   /* call the apis to create/update records in  db (first set) */
   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'CRUD for the first set of calculations.');
   IF NOT IGI_IAC_REVAL_CRUD.crud_iac_tables
      ( fp_reval_params => L_Reval_params
      , fp_second_set   => false
      )
   THEN
      igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'Failure CRUD IGI_IAC_REVAL_ENGINE.First_set_calculations');
       return false;
   END IF;

   /* call to next set of calculations */
   IF L_reval_params.reval_control.mixed_scenario THEN
       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'If mixed, call SWAP and process the second set of calculations');
       DECLARE
          L_reval_params2  IGI_IAC_TYPES.iac_reval_params := L_reval_params;
       BEGIN
          IF NOT IGI_IAC_REVAL_ENGINE.swap ( fp_reval_params1 => L_Reval_params
                                             , fp_reval_params2 => L_reval_params2 )
          THEN
              igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'Failure IGI_IAC_REVAL_ENGINE.swap');
              return false;
          END IF;

          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'performing the second set of calculations');
          IF NOT IGI_IAC_REVAL_ENGINE.Next_set_calculations
              ( p_iac_reval_params => L_reval_params2 )
          THEN
              igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'Failure IGI_IAC_REVAL_ENGINE.Next_set_calculations');
              return false;
          END IF;
          fp_reval_output_asset := L_Reval_params2.reval_output_asset;
          /* call the apis to create/update records in  db (second set) */
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'CRUD for the second set of calculations');
          IF NOT IGI_IAC_REVAL_CRUD.crud_iac_tables
                  ( fp_reval_params => L_Reval_params2
                  , fp_second_set   => true
                   )
          THEN
                  igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'failure CRUD IGI_IAC_REVAL_ENGINE.Next_set_calculations');
                   return false;
          END IF;

       END;
   END IF;
   return true;
exception when others then
   l_reval_params       := l_reval_params_old;
   fp_reval_output_asset:= fp_reval_output_asset_old;
   igi_iac_debug_pkg.debug_unexpected_msg(l_path);
   return false;
end;

procedure print_exceptions ( fp_reval_exceptions in  igi_iac_types.iac_reval_exceptions
                           , fp_revaluation_id   in  number
                            ) is
  idx binary_integer;
  l_exception_line igi_iac_types.iac_reval_Exception_line;
  l_path varchar2(100) := g_path||'print_exceptions';
begin

  idx := fp_reval_exceptions.FIRST;
  while idx <= fp_reval_exceptions.LAST loop
      l_exception_line := fp_reval_exceptions( idx) ;
      IF NOT IGI_IAC_REVAL_CRUD.create_exceptions
        ( fp_reval_exceptions   => l_exception_line
        , fp_revaluation_id     => fp_revaluation_id
        )
      THEN
         igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'+unable to create any exceptions');
         return;
      END IF;

      if idx < fp_reval_exceptions.LAST then
         idx := fp_reval_exceptions.next( idx );
      else
         exit;
      end if;

  end loop;
end;

function do_revaluation_asset
         ( fp_revaluation_id in number
         , fp_asset_id       in number
         , fp_book_type_code in varchar2
         , fp_reval_mode     in varchar2
         , fp_reval_rate     in number
         , fp_period_counter in number
         , fp_calling_program   in varchar2
         , fp_reval_output_asset in out NOCOPY IGI_IAC_TYPES.iac_reval_output_asset
         , fp_reval_messages in out NOCOPY IGI_IAC_TYPES.iac_reval_mesg
         , fp_reval_messages_idx  in out NOCOPY IGI_IAC_TYPES.iac_reval_mesg_idx
         , fp_reval_exceptions in out NOCOPY IGI_IAC_TYPES.iac_reval_exceptions
         , fp_reval_exceptions_idx in out NOCOPY IGI_IAC_TYPES.iac_reval_exceptions_idx
         )
return  boolean is
  L_reval_control              IGI_IAC_TYPES.iac_reval_control_type;
  L_reval_params               IGI_IAC_TYPES.iac_reval_params;
  L_Reval_output_dists         IGI_IAC_TYPES.iac_reval_output_dists;
  L_reval_output_dists_idx     IGI_IAC_TYPES.iac_reval_output_dists_idx;
  L_exception_info             IGI_IAC_TYPES.iac_reval_exception_line;
  l_path 		       varchar2(100) := g_path||'do_revaluation_asset';
begin
   /* initialize the control record for the asset   */
   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Initialization of the control structure');
   if fp_calling_program = 'IGIIARVC' then
       IF NOT IGI_IAC_REVAL_INIT_CONTROL.init_control_for_srs
       ( fp_asset_id               => fp_asset_id
        , fp_book_type_code        => fp_book_type_code
        , fp_revaluation_id       => fp_revaluation_id
        , fp_revaluation_mode     => fp_reval_mode
        , fp_period_counter       => fp_period_counter
        , fp_iac_reval_control_type => L_reval_control
        ) then
              -- add message to the stack
              igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'Failed IGI_IAC_REVAL_INIT_CONTROL.init_control_for_srs');
              return false;
        end if;
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'success IGI_IAC_REVAL_INIT_CONTROL.init_control_for_srs');
   elsif   fp_calling_program = 'IGIIAIAR' then
       IF NOT IGI_IAC_REVAL_INIT_CONTROL.init_control_for_calc
       ( fp_asset_id               => fp_asset_id
        , fp_book_type_code        => fp_book_type_code
        , fp_revaluation_id       => fp_revaluation_id
        , fp_revaluation_mode     => fp_reval_mode
        , fp_period_counter       => fp_period_counter
        , fp_iac_reval_control_type => L_reval_control
        ) then
              igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'Failed IGI_IAC_REVAL_INIT_CONTROL.init_control_for_calc');
              return false;
        end if;
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'success IGI_IAC_REVAL_INIT_CONTROL.init_control_for_calc');
   end if;

   /* initialize the structures and records         */
     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Initialization of data structures.');
     if fp_calling_program = 'IGIIARVC' then
       IF NOT IGI_IAC_REVAL_INIT_STRUCT.init_struct_for_srs
       ( fp_asset_id                => fp_asset_id
        , fp_book_type_code         => fp_book_type_code
        , fp_revaluation_id         => fp_revaluation_id
        , fp_revaluation_mode       => fp_reval_mode
        , fp_period_counter         => fp_period_counter
        , fp_control                => L_reval_control
        , fp_reval_params           => L_reval_params
        ) then
              igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'failed IGI_IAC_REVAL_INIT_STRUCT.init_struct_for_srs');
              return false;
        end if;
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'success IGI_IAC_REVAL_INIT_STRUCT.init_struct_for_srs');
   elsif fp_calling_program = 'IGIIAIAR' then
       IF NOT IGI_IAC_REVAL_INIT_STRUCT.init_struct_for_calc
       ( fp_asset_id                => fp_asset_id
        , fp_book_type_code         => fp_book_type_code
        , fp_revaluation_id         => fp_revaluation_id
        , fp_revaluation_mode       => fp_reval_mode
        , fp_period_counter         => fp_period_counter
        , fp_control                => L_reval_control
        , fp_reval_params           => L_reval_params
        ) then
        igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'failed IGI_IAC_REVAL_INIT_STRUCT.init_struct_for_calc');
              -- add message to the stack
              return false;
        end if;
    else
        igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'Unknown calling program.Exiting.');
    end if;

  /* validate the asset for business rules         */
  /* this should return true to proceed, false to stop */

    IF L_reval_params.reval_control.validate_business_rules THEN

          fp_reval_exceptions_idx := fp_reval_exceptions_idx + 1;
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Validation of business rules.');
          declare
             l_reval_exceptions  igi_iac_types.iac_reval_exceptions;
             l_reval_idx         igi_iac_types.iac_reval_exceptions_idx;
          begin
              IF NOT IGI_IAC_REVAL_VALIDATION.validate_asset
                ( fp_asset_id               => fp_asset_id
                , fp_book_type_code         => fp_book_type_code
                , fp_revaluation_id         => fp_revaluation_id
                , fp_reval_type             => L_reval_params.reval_asset_rules.revaluation_type
                , fp_period_counter         => fp_period_counter
                , fp_exceptions             => l_reval_exceptions
                , fp_exceptions_idx         => l_reval_idx
                ) then
                    -- add exception to exception stack
                    -- validation has failed, so do not proceed with this asset.
		    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Failed IGI_IAC_REVAL_VALIDATION.validate_asset');
                    fp_reval_exceptions := l_reval_exceptions ;
                    IF  L_reval_params.reval_control.crud_allowed THEN

                        print_exceptions ( fp_reval_exceptions => fp_reval_exceptions,
                                           fp_Revaluation_id   => fp_revaluation_id
                                         );

                        return true;
                    END IF;
                end if;

       EXCEPTION WHEN OTHERS THEN
           return true;
       END;

   END IF;
   /* calls to the revaluation engine (calc)        */

   if not do_reval_calc_asset ( L_reval_params => L_reval_params
                             , fp_reval_output_asset  => fp_reval_output_asset
                             )
   then
       igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'Calculation has failed.');
       return false;
   end if;

   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Success IGI_IAC_REVAL_WRAPPER.do_revaluation_asset');
   return true;
exception when others then
   igi_iac_debug_pkg.debug_unexpected_msg(l_path);
   return false;
end;

function do_calculation_asset
       (  fp_revaluation_id  number
       ,  fp_asset_id        number
       ,  fp_book_type_code  varchar2
       ,  fp_reval_mode      varchar2
       ,  fp_reval_rate      number
       ,  fp_period_counter  number
       ,  fp_iac_reval_output_asset out NOCOPY IGI_IAC_TYPES.iac_reval_output_asset
       )
return boolean is
   pragma autonomous_transaction;
   l_reval_messages       IGI_IAC_TYPES.iac_reval_mesg;
   l_reval_messages_idx   IGI_IAC_TYPES.iac_reval_mesg_idx := 1;
   l_reval_exceptions     IGI_IAC_TYPES.iac_reval_exceptions;
   l_reval_exceptions_idx IGI_IAC_TYPES.iac_reval_exceptions_idx := 1;
   l_reval_output_asset   IGI_IAC_TYPES.iac_reval_output_asset;
   l_path 		  varchar2(100) := g_path||'do_calculation_asset';
begin

  if not do_revaluation_asset
         ( fp_revaluation_id => fp_revaluation_id
         , fp_asset_id       => fp_asset_id
         , fp_book_type_code => fp_book_type_code
         , fp_reval_mode     => fp_reval_mode
         , fp_reval_rate     => fp_reval_rate
         , fp_period_counter => fp_period_counter
         , fp_calling_program  => 'IGIIAIAR'
         , fp_reval_messages  => l_reval_messages
         , fp_reval_output_asset => l_reval_output_asset
         , fp_reval_messages_idx  => l_reval_messages_idx
         , fp_reval_exceptions    => l_reval_exceptions
         , fp_reval_exceptions_idx => l_reval_exceptions_idx )
  then
    rollback;
    return false;
  end if;

  fp_iac_reval_output_asset := l_reval_output_asset;
  rollback;
  return true;
exception when others then
  rollback;
  igi_iac_debug_pkg.debug_unexpected_msg(l_path);
  return false;
end;

END;

/
