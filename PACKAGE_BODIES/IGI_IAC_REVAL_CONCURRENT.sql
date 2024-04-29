--------------------------------------------------------
--  DDL for Package Body IGI_IAC_REVAL_CONCURRENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IAC_REVAL_CONCURRENT" AS
-- $Header: igiiarcb.pls 120.11.12000000.2 2007/10/03 13:16:43 npandya ship $

--===========================FND_LOG.START=====================================

g_state_level NUMBER	     ;
g_proc_level  NUMBER	     ;
g_event_level NUMBER	     ;
g_excep_level NUMBER	     ;
g_error_level NUMBER	     ;
g_unexp_level NUMBER	     ;
g_path        VARCHAR2(100)  ;

--===========================FND_LOG.END=======================================

l_rec igi_iac_revaluation_rates%rowtype;  -- create this for quicker access via sql navigator
/*
-- Commit if not in debug mode.
*/
procedure do_commit is
begin
    if IGI_IAC_REVAL_UTILITIES.debug then
       rollback;
    else
        commit;
    end if;
end;

/*
-- Submit Revaluation Report
*/
procedure submit_revaluation_report ( p_revaluation_id in number
                                    , p_revaluation_mode in varchar2
                                    )
is
  cursor c_reval is
    select revaluation_id, book_type_code, revaluation_period
    from   igi_iac_revaluations
    where  revaluation_id = p_revaluation_id
    ;
  l_report_request_id number;
  l_retcode number;
  l_errbuf  varchar2(2000);
  l_reval_res c_reval%ROWTYPE;
  l_path varchar2(100) ;
begin
  l_path := g_path||'submit_revaluation_report';

/* Sekhar The request i ssubmitted only for preview mode*/
   if p_revaluation_mode not in ( 'P' ) then
      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Do not submit_revaluation_report');
      return;
   end if;

   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'submit_revaluation_report');

   for l_rev in c_reval loop
       l_reval_res := l_rev;
   end loop;

   /* Sekhar The request is submitted only for preview mode
   commented the call for submmiting the asset balance report
   now only preview report is called*/
/*   igi_iac_submit_Asset_balance.submit_report
                          ( ERRBUF                    => l_errbuf,
                            RETCODE                   => l_retcode ,
                            p_book_type_code          => l_reval_res.book_type_code ,
                            p_period_counter          => l_reval_res.revaluation_period ,
                            p_mode                    => 'A' ,
                            p_category_struct_id      => null ,
                            p_category_id             => null ,
                            p_called_from             => 'IGIIAIAR' ) ;*/

        /*Summary preview report*/
        l_report_Request_id := FND_REQUEST.SUBMIT_REQUEST ( 'IGI'
                                                         , 'IGIIARPS'
                                                         , null
                                                         , null
                                                         , FALSE          -- Is a sub request
                                                         , 'P_BOOK_TYPE_CODE='||l_reval_res.book_type_code
                                                         , 'P_REVALUATION_ID='||p_revaluation_id
                                                         , 'P_PERIOD_COUNTER='||l_reval_res.revaluation_period
                                                         );
	 igi_iac_debug_pkg.debug_other_string(g_event_level,l_path,'Asset Revlaution Preview Summary  report .... ');
         IF Not l_report_Request_id > 0 Then
	 	  igi_iac_debug_pkg.debug_other_string(g_excep_level,l_path,'Error in Asset Revlaution Preview Summary report .... ');
         END IF;
           /*Detail preview report */

          l_report_Request_id := FND_REQUEST.SUBMIT_REQUEST ( 'IGI'
                                                         , 'IGIIARPR'
                                                         , null
                                                         , null
                                                         , FALSE          -- Is a sub request
                                                         , 'P_BOOK_TYPE_CODE='||l_reval_res.book_type_code
                                                         , 'P_REVALUATION_ID='||p_revaluation_id
                                                         , 'P_PERIOD_COUNTER='||l_reval_res.revaluation_period
                                                         );
	 igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Asset Revlaution Preveiw Detail report .... ');
         IF Not l_report_Request_id > 0 Then
	     	  igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Error in Asset Revlaution Preview Detail  report .... ');
         END IF;

         commit;

   return;
exception when others then
   igi_iac_debug_pkg.debug_unexpected_msg(l_path);
   rollback;
end;

/*
-- convert from preview to live
*/
function preview_mode_hist_transform ( fp_revaluation_id in number
                                     , fp_book_type_code in varchar2
                                     , fp_period_counter in number
                                     )
return   boolean is

    /*
    -- Revaluation form must set the status to 'PREVIEW' before the 'NEW' or 'PREVIEWED'
    -- record is processed again.
    */
   cursor c_revaluations is
     select iir.revaluation_id, iir.book_type_code
     from   igi_iac_revaluations iir
     where  iir.revaluation_id = fp_revaluation_id
       and  iir.book_type_code = fp_book_type_code
       ;

   cursor c_reval_categories (cp_revaluation_id in number
                             , cp_book_type_code in varchar2
                             ) is
     select category_id
     from   igi_iac_reval_categories
     where  revaluation_id = cp_revaluation_id
       and  book_type_code = cp_book_type_code
       and  nvl(select_category,'X') = 'Y';

    cursor c_get_assets ( cp_revaluation_id in number
                    , cp_book_type_code in varchar2
                    , cp_category_id    in number
                    ) is
       select ac.asset_id, ac.revaluation_type, ac.revaluation_factor, fadd.asset_number
       from   igi_iac_reval_asset_rules ac, fa_additions fadd
       where  ac.revaluation_id = cp_revaluation_id
         and  ac.book_type_code = cp_book_type_code
         and  ac.category_id    = cp_category_id
         and  ac.asset_id       = fadd.asset_id
         and  nvl(ac.selected_for_reval_flag,'X') = 'Y'
         and  exists ( select 1
                       from igi_iac_transaction_headers
                           where asset_id = ac.asset_id
                           and   book_type_code = ac.book_type_code
                           and  mass_reference_id = ac.revaluation_id
                           and  adjustment_status = 'PREVIEW'
             )
         ;
         l_success_ct  number ;
         l_failure_ct  number ;
	 l_path varchar2(100) ;

         -- bulk changes
         TYPE asset_id_tbl_type IS TABLE OF   IGI_IAC_REVAL_ASSET_RULES.ASSET_ID%TYPE
              INDEX BY BINARY_INTEGER;
         TYPE reval_type_tbl_type IS TABLE OF  IGI_IAC_REVAL_ASSET_RULES. REVALUATION_TYPE%TYPE
             INDEX BY BINARY_INTEGER;
         TYPE reval_factor_tbl_type IS TABLE OF   IGI_IAC_REVAL_ASSET_RULES.REVALUATION_FACTOR%TYPE
              INDEX BY BINARY_INTEGER;
         TYPE asset_no_tbl_type IS TABLE OF FA_ADDITIONS.ASSET_NUMBER%TYPE
              INDEX BY BINARY_INTEGER;

         l_asset_id asset_id_tbl_type;
         l_reval_type reval_type_tbl_type;
         l_reval_factor reval_factor_tbl_type;
         l_asset_no asset_no_tbl_type;

         l_loop_count                 number;
         l_event_id                   number; --Added for SLA uptake

        --bulk fetch changes

begin
         l_success_ct   := 0;
         l_failure_ct   := 0;
	 l_path  := g_path||'preview_mode_hist_transform';

      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'begin preview_mode_hist_transform');
      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Status '|| IGI_IAC_TYPES.gc_running_status);

      savepoint sp;
      for l_reval in c_revaluations loop          -- get the revaluation for preview
                                                  -- found record to process.
	  igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'>>found revaluation record to process');
          for l_reval_cats in c_reval_categories       -- get the  category information
             ( cp_revaluation_id => l_reval.revaluation_id
             , cp_book_type_code => l_reval.book_type_code )
          loop
             igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'>>found revaluation category record to process '
                 || l_reval_cats.category_id);

          /*     for l_assets in c_assets                  -- get assets
                   ( cp_revaluation_id => l_reval.revaluation_id
                   , cp_book_type_code => l_reval.book_type_code
                   , cp_category_id    => l_reval_cats.category_id
                   )*/
            -- bulk fetch changes
            OPEN c_get_assets( cp_revaluation_id => l_reval.revaluation_id
                   , cp_book_type_code => l_reval.book_type_code
                   , cp_category_id    => l_reval_cats.category_id
                   );
           FETCH c_get_assets  BULK COLLECT INTO
                l_asset_id,
                l_reval_type,
                l_reval_factor,
                l_asset_no;
           CLOSE c_get_assets;

          FOR l_loop_count IN 1.. l_asset_id.count
          loop
	       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'>>found asset record to process : asset number '|| l_asset_no(l_loop_count) );
	       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'>>                                asset id     '|| l_asset_id(l_loop_count));
               --
               -- update balance information
               --
                if IGI_IAC_REVAL_CRUD.update_balances
                     ( fp_reval_id       => l_reval.revaluation_id
                     , fp_asset_id       => l_asset_id(l_loop_count)
                     , fp_period_counter => fp_period_counter
                     , fp_book_type_code => l_reval.book_type_code
                     )
                then
                   l_success_ct := l_success_ct + 1;
                else
                   l_failure_ct := l_failure_ct + 1;
                end if;
               --
               -- Adjustment_status of igi_iac_transaction_headers is updated
               --   from 'PREVIEW' to 'RUN'.
               --
               IF IGI_IAC_REVAL_CRUD.adjustment_status_to_run
                 ( fp_reval_id    => l_reval.revaluation_id
                 , fp_asset_id    => l_asset_id(l_loop_count))
               then
                   l_success_ct := l_success_ct + 1;
                else
                   l_failure_ct := l_failure_ct + 1;
                end if;

               IF IGI_IAC_REVAL_CRUD.allow_transfer_to_gl
                 ( fp_reval_id       => l_reval.revaluation_id
                 , fp_book_type_code => l_reval.book_type_code
                 , fp_asset_id       => l_asset_id(l_loop_count)
                 )
               then
                   l_success_ct := l_success_ct + 1;
               else
                   l_failure_ct := l_failure_ct + 1;
               end if;

               declare
                 l_adjustment_id number;
               begin
                /* here the assumption is that the latest adjustment id
                   belongs to revaluation
                */
                 begin
                     select adjustment_id
                     into   l_adjustment_id
                     from   igi_iac_transaction_headers
                     where  book_type_code = l_reval.book_type_code
                     and    asset_id       = l_asset_id(l_loop_count)
                     and    adjustment_id_out is null
                     ;
                 exception when no_data_found then
                     l_adjustment_id := -1;
                 end;

                 if l_adjustment_id = -1 then
                    l_failure_ct := l_failure_ct + 1;
                 else
                     if not igi_iac_reval_crud.update_reval_rates
                          ( fp_adjustment_id => l_adjustment_id )
                     then
                         l_failure_ct := l_failure_ct + 1;
                     else
                         l_success_ct := l_success_ct + 1;
                     end if;
                 end if;

               exception when others then null;
               end;

             end loop;                                     -- get assets

          end loop;                                     -- get the category information


          /* Added for SLA uptake.
           Following code will create SLA event and stamp it in revaluation and adjustment tables*/

           IF l_failure_ct = 0 then
              igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Calling event capture routine');
              If IGI_IAC_XLA_EVENTS_PKG.create_revaluation_event(l_reval.revaluation_id,l_event_id) then
                 igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Event created successfully, Event_id = ' ||l_event_id);
              else
                 igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Event creation failed');
                 l_failure_ct := l_failure_ct + 1;
              end if;
           End if;

          /* Added For SLA uptake*/
          IF l_failure_ct = 0 then
             IF NOT IGI_IAC_REVAL_CRUD.reval_status_to_completed ( l_reval.revaluation_id,l_event_id )
             THEN
	             igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'>>failed reval_status_to_completed');
	             igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'>>not preview_mode_hist_transform');
	             igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'end preview_mode_hist_transform');
                 return false;
             ELSE
                --Stamp sla event to tables
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'>>start stamp_sla_event');
                IF NOT IGI_IAC_REVAL_CRUD.stamp_sla_event ( l_reval.revaluation_id,
                                                                  l_reval.book_type_code,
                                                                  l_event_id)
                THEN
	                 igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'>>failed stamp_sla_event');
	                  return false;
                 end if;
                --Stamp sla event to tables
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'>>success reval_status_to_run');
             END IF;
          ELSE
             IF NOT IGI_IAC_REVAL_CRUD.reval_status_to_failed_run ( l_reval.revaluation_id )
             THEN
	        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'>>failed reval_status_to_run');
	        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'>>not preview_mode_hist_transform');
	        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'end preview_mode_hist_transform');
                return false;
             ELSE
	        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'>>success reval_status_to_failed_run');
             END IF;
          END IF;

           /* Added for SLA uptake.
           Following code will delete SLA event in case of failure*/
          if l_failure_ct = 0 and l_success_ct > 0 then
	         igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Revaluation is complete...');
          else
             igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Calling event deletion routine');
             If IGI_IAC_XLA_EVENTS_PKG.delete_revaluation_event(l_reval.revaluation_id) then
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Event deleted successfully');
             else
                igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Event deletion failed');
             end if;
          end if;
          /* Added For SLA uptake*/

      end loop;                                      -- get the revaluation for preview

      if l_failure_ct = 0 and l_success_ct > 0 then
	        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'>>preview_mode_hist_transform');
      else
         rollback to sp;
         igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'>>not preview_mode_hist_transform');
         return false;
      end if;

      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'end preview_mode_hist_transform');

   return true;
end;
/*
-- Generate data in preview mode
*/

function preview_mode_hist_generate  ( fp_revaluation_id in number
                                     , fp_book_type_code in varchar2
                                     , fp_period_counter in number
                                     , fp_wait_request_id in number
                                     )
return   boolean is

    /*
    -- Revaluation form must set the status to 'PREVIEW' before the 'NEW' or 'PREVIEWED'
    -- record is processed again.
    */
   l_number number ;
   cursor c_revaluations is
     select iir.revaluation_id, iir.book_type_code
     from   igi_iac_revaluations iir
     where  iir.revaluation_id = fp_revaluation_id
       and  iir.book_type_code = fp_book_type_code
--     and  upper(iir.status)  = IGI_IAC_TYPES.gc_previewed_status
       ;

   cursor c_reval_categories (cp_revaluation_id in number
                             , cp_book_type_code in varchar2
                             ) is
     select category_id
     from   igi_iac_reval_categories
     where  revaluation_id = cp_revaluation_id
       and  book_type_code = cp_book_type_code
       and  nvl(select_category,'X') = 'Y'
       ;
       -- modify this later to ensure selected categories are retrieved

    cursor c_get_assets ( cp_revaluation_id in number
                    , cp_book_type_code in varchar2
                    , cp_category_id    in number
                    ) is
       select r.asset_id, r.revaluation_type, r.revaluation_factor, fadd.asset_number
       from   igi_iac_reval_asset_rules r, fa_additions fadd
       where  r.revaluation_id = cp_revaluation_id
         and  r.book_type_code = cp_book_type_code
         and  r.category_id    = cp_category_id
         and  nvl(r.selected_for_reval_flag,'X') = 'Y'
         and  r.asset_id       = fadd.asset_id
         and not exists ( select 'x'
                          from igi_iac_transaction_headers
                          where asset_id = r.asset_id
                          and   book_type_code = r.book_type_code
                          and   mass_reference_id = r.revaluation_id
                          and   transaction_type_code = 'REVALUATION'
                        )
         ;
         l_failure_ct number ;
         l_success_ct number ;

	 l_path varchar2(100) ;

         l_reval_messages       IGI_IAC_TYPES.iac_reval_mesg;
         l_reval_messages_idx   IGI_IAC_TYPES.iac_reval_mesg_idx ;
         l_reval_exceptions     IGI_IAC_TYPES.iac_reval_exceptions;
         l_reval_exceptions_idx IGI_IAC_TYPES.iac_reval_exceptions_idx ;

         /* Bulk Fetch */
         TYPE asset_id_tbl_type IS TABLE OF   IGI_IAC_REVAL_ASSET_RULES.ASSET_ID%TYPE
          INDEX BY BINARY_INTEGER;
         TYPE reval_type_tbl_type IS TABLE OF  IGI_IAC_REVAL_ASSET_RULES. REVALUATION_TYPE%TYPE
          INDEX BY BINARY_INTEGER;
         TYPE reval_factor_tbl_type IS TABLE OF   IGI_IAC_REVAL_ASSET_RULES.REVALUATION_FACTOR%TYPE
          INDEX BY BINARY_INTEGER;
         TYPE asset_no_tbl_type IS TABLE OF FA_ADDITIONS.ASSET_NUMBER%TYPE
          INDEX BY BINARY_INTEGER;

         l_asset_id asset_id_tbl_type;
         l_reval_type reval_type_tbl_type;
         l_reval_factor reval_factor_tbl_type;
         l_asset_no asset_no_tbl_type;

         l_loop_count                 number;

         /* Bulk Fetch */
begin
   	l_number  := fp_revaluation_id;
         l_failure_ct  := 0;
         l_success_ct  := 0;
	 l_path  := g_path||'preview_mode_hist_generate';
         l_reval_messages_idx   := 1;
         l_reval_exceptions_idx  := 1;

      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'begin preview_mode_hist_generate');
      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'status '|| IGI_IAC_TYPES.gc_previewed_status);

      savepoint sp;
      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+after savepoint');
      for l_reval in c_revaluations loop          -- get the revaluation for preview

          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'>>found revaluation record to process');
          for l_reval_cats in c_reval_categories       -- get the  category information
             ( cp_revaluation_id => l_reval.revaluation_id
             , cp_book_type_code => l_reval.book_type_code )
          loop
	     igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'>>found revaluation category record to process '
                  || l_reval_cats.category_id);
           /* Bulk fetch*/
           OPEN c_get_assets ( cp_revaluation_id => l_reval.revaluation_id
                   , cp_book_type_code => l_reval.book_type_code
                   , cp_category_id    => l_reval_cats.category_id
                   );
           FETCH c_get_assets  BULK COLLECT INTO
                    l_asset_id,
                    l_reval_type,
                    l_reval_factor,
                    l_asset_no;
            CLOSE c_get_assets;


        /*     for l_assets in c_assets                  -- get assets
                  ( cp_revaluation_id => l_reval.revaluation_id
                   , cp_book_type_code => l_reval.book_type_code
                   , cp_category_id    => l_reval_cats.category_id
                   )*/

              FOR l_loop_count IN 1.. l_asset_id.count
              LOOP


	        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'>>found asset record to process '|| l_asset_id(l_loop_count));
                -- now call the reval wrapper!
   	          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'>> -- ------------------------------------------- ');
   	          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'>> -- Parameters for do_revaluation_asset ');
   	          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'>> -- ------------------------------------------- ');
   	          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'>> -- Revaluation id : '|| l_reval.revaluation_id );
   	          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'>> -- Book Type code : '|| l_reval.book_type_code);
   	          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'>> -- Reval mode     : P ');
   	          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'>> -- Period counter : '|| fp_period_counter);
   	          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'>> -- calling program: IGIIARVC');
   	          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'>> -- ------------------------------------------- ');
                declare
                   l_reval_output_asset   IGI_IAC_TYPES.iac_reval_output_asset;
                begin
   	          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'>> -- ------------------------------------------- ');
   	          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'>> -- Asset number   : '|| l_asset_no(l_loop_count));
   	          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'>> -- Asset id       : '|| l_asset_id(l_loop_count) );
   	          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'>> -- reval rate     : '|| l_reval_factor(l_loop_count));
   	          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'>> -- ------------------------------------------- ');
                  if not IGI_IAC_REVAL_WRAPPER.do_revaluation_asset
                         ( fp_revaluation_id => l_reval.revaluation_id
                         , fp_asset_id       => l_asset_id(l_loop_count)
                         , fp_book_type_code =>  l_reval.book_type_code
                         , fp_reval_mode     =>  'P'
                         , fp_reval_rate     => l_reval_factor(l_loop_count)
                         , fp_period_counter => fp_period_counter
                         , fp_calling_program  => 'IGIIARVC'
                         , fp_reval_messages  => l_reval_messages
                         , fp_reval_output_asset => l_reval_output_asset
                         , fp_reval_messages_idx  => l_reval_messages_idx
                         , fp_reval_exceptions    => l_reval_exceptions
                         , fp_reval_exceptions_idx => l_reval_exceptions_idx )
                  then
     	            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'>>failed do_revaluation');
                    l_failure_ct := l_failure_ct + 1;
                  else
                    l_success_ct := l_success_ct + 1;
     	            igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'>>success do_revaluation');
                  end if;
                  -- return true;
                exception when others then
                    IF NOT IGI_IAC_REVAL_CRUD.reval_status_to_failed_pre ( l_reval.revaluation_id )
                    THEN
	   	          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'>>failure reval_status_to_previewed');
                    ELSE
	   	          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'>>success reval_status_to_previewed');
                    END IF;
      	            igi_iac_debug_pkg.debug_unexpected_msg(l_path);
                    l_failure_ct := l_failure_ct + 1;
                end;

             end loop;                                     -- get assets
          end loop;                                     -- get the category information

      end loop;                                      -- get the revaluation for preview

      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'>> failure count '|| l_failure_ct);
      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'>> success count '|| l_success_ct);
      IF NOT igi_iac_reval_utilities.synchronize_accounts(p_book_type_code => fp_book_type_code,
                                                          p_period_counter =>  fp_period_counter,
                                                          p_calling_function =>  'REVALUATION') THEN
  	    FND_MESSAGE.SET_NAME('IGI', 'IGI_IAC_ACCOUNT_NOT_FOUND');
        FND_MESSAGE.SET_TOKEN('PROCESS','Revaluation',TRUE);
  	    igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
		  	p_full_path => l_path,
		  	p_remove_from_stack => FALSE);
	    fnd_file.put_line(fnd_file.log, fnd_message.get);

        l_failure_ct := l_failure_ct + 1;
      END IF;

      IF l_failure_ct = 0 THEN
               IF NOT IGI_IAC_REVAL_CRUD.reval_status_to_previewed ( l_number )
              THEN
      	          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'>>failed reval_status_to_previewed');
      	          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'>>not preview_mode_hist_generate');
      	          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'end preview_mode_hist_generate');
              ELSE
      	          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'>>success reval_status_to_previewed');
              END IF;
              return true;
      ELSE
              rollback to sp;
              IF NOT IGI_IAC_REVAL_CRUD.reval_status_to_failed_pre ( l_number )
              THEN
      	          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'>>failed reval_status_to_failed_pre');
      	          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'>>not preview_mode_hist_generate');
      	          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'end preview_mode_hist_generate');
              ELSE
      	          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'>>success reval_status_to_failed_pre');
              END IF;
              return false;
      END IF;

end;
/*
-- Delete preview history completely
*/

function preview_mode_hist_delete  ( fp_revaluation_id in number)
return   boolean is
     cursor c_reval_rates is
         select distinct asset_id, book_type_code, period_counter
         from   igi_iac_transaction_headers
         where  mass_reference_id    = fp_revaluation_id
           and  transaction_type_code = 'REVALUATION'
         ;
    cursor c_txn_headers (cp_book_type_code in varchar2
                         ,cp_asset_id       in number
                         ,cp_period_counter in number
                         ) is
         select adjustment_id
         from   igi_iac_transaction_headers t
         where  book_type_code   = cp_book_type_code
           and  asset_id         = cp_asset_id
           and  transaction_type_code = 'REVALUATION'
           and  period_counter        = cp_period_counter
           and  mass_reference_id     = fp_revaluation_id
           and exists ( select 'x'
                        from igi_iac_reval_asset_rules
                        where asset_id = t.asset_id
                        and   book_type_code = t.book_type_code
                        and   revaluation_id = t.mass_reference_id
                        and   nvl(allow_prof_update,'X') = 'Y'
                      )
          ;
      l_delete_flag boolean;
      l_prev_adj_id number;

      l_path varchar2(100);
begin
      l_path  := g_path||'preview_mode_hist_delete';

   igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Begin preview_mode_hist_delete');
   for l_rates in c_reval_rates loop
       l_delete_flag := false;
       igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+found reval records to process');
       for l_headers in c_txn_headers ( cp_book_type_code => l_rates.book_type_code
                                      , cp_asset_id       => l_rates.asset_id
                                      , cp_period_counter => l_rates.period_counter
                                      )
       loop
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+adjustment id '||l_headers.adjustment_id);
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+delete from exceptions table');
          l_delete_flag := true;
          delete from igi_iac_exceptions
          where asset_id = l_rates.asset_id
          and   revaluation_id = fp_revaluation_id
          and   book_type_code = l_rates.book_type_code
          ;
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+delete from the transaction headers table');
          delete igi_iac_transaction_headers
          where  adjustment_id     = l_headers.adjustment_id
          and    adjustment_id_out is null
/*          and not exists ( select 'x'
                       from igi_iac_transaction_headers
                       where adjustment_id_out = l_headers.adjustment_id
                     )*/
          ;
          if sql%notfound then
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+there have been additional transactions after this');
            rollback;
            return false;
          end if;
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+update previous transaction row if one exists');
          declare
             cursor c_exist is
               select 'x'
               from  igi_iac_transaction_headers
               where adjustment_id_out = l_headers.adjustment_id
               ;
               l_exists_prev boolean := false;
          begin
              for l_exist in c_exist loop
                l_exists_prev := true;
              end loop;
              if l_exists_prev then
                  igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+previous transaction row exists');
                  update igi_iac_transaction_headers
                  set    adjustment_id_out = null
                  where  adjustment_id_out = l_headers.adjustment_id
                  and    book_type_code    = l_rates.book_type_code
                  and    asset_id          = l_rates.asset_id
                  ;
                  if sql%notfound then
	             igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+error occurred in igi_iac_transaction_headers');
                     rollback;
                     return false;
                  end if;
              end if;
          end;
          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+delete from the adjustments table');
          delete igi_iac_adjustments
          where  adjustment_id     = l_headers.adjustment_id
          ;
          if sql%found then
             igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+deleted the iac adjustments');
          end if;

           igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+delete from the det balances table');
          delete igi_iac_det_balances
          where  adjustment_id     = l_headers.adjustment_id
          ;
          if sql%found then
             igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+deleted the det balances info');
          end if;

          igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+delete from the revaluation rates table');
          delete from igi_iac_revaluation_rates
          where  adjustment_id  = l_headers.adjustment_id
          ;
          if sql%found then
             igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+deleted the revaluation rates info');
          end if;
       end loop;



   end loop;

   if not l_delete_flag then
      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'no preview_mode_hist_delete');
   else
      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'yes preview_mode_hist_delete');
   end if;

   return true;
exception when others then
   return false;
end;

/*
-- Test whether preview has been run again
*/

function preview_mode_hist_available ( fp_revaluation_id in  number )
return boolean is
   cursor c_pmha is
      select distinct asset_id, book_type_code, period_counter
         from   igi_iac_transaction_headers
         where  mass_reference_id    = fp_revaluation_id
           and  transaction_type_code = 'REVALUATION'
           and  adjustment_status     = 'PREVIEW'
         ;

   l_path varchar2(100) ;
begin
   l_path  := g_path||'preview_mode_hist_available';
    for l_pmha in c_pmha loop
      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'yes preview_mode_hist_available');
      return true;
    end loop;
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'no preview_mode_hist_available');
    return false;
end;

/*
-- Test whether Run mode has processed successfully.
*/

function run_mode_hist_available ( fp_revaluation_id in  number )
return boolean is
      cursor c_rmha is
          select distinct asset_id, book_type_code, period_counter
         from   igi_iac_transaction_headers
         where  mass_reference_id    = fp_revaluation_id
           and  transaction_type_code = 'REVALUATION'
           and  adjustment_status     = 'RUN'
         ;

       l_path varchar2(100) ;
begin
       l_path  := g_path||'run_mode_hist_available';
   for l_rmha in c_rmha loop
      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'yes run_mode_hist_available');
      return true;
    end loop;
    igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'no run_mode_hist_available');
    return false;
end;

procedure revaluation
                   ( errbuf            out NOCOPY varchar2
                   , retcode           out NOCOPY number
                   , revaluation_id    in number
                   , book_type_code    in varchar2
                   , revaluation_mode  in varchar2 -- 'P' preview, 'R' run
                   , period_counter    in  number
                   , create_request_id in number
                   )
is
  l_number number ;
  l_path varchar2(100) ;
begin
  l_number  := revaluation_id ;
  l_path  := g_path||'revaluation';

      /* Bug 2480915 this function synchronizes igi_iac_fa_depr table data */
      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,' Synchronizing Depreciation Data ');
      IF NOT igi_iac_common_utils.populate_iac_fa_deprn_data(book_type_code,
	    							  'REVALUATION') THEN
	        igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'Failure in Synchronizing Depreciation Data ');
         rollback;
         errbuf := 'Failure in Synchronizing Depreciation Data. Submit Synchronize Depreciation Data request.';
         igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'Failure in Synchronizing Depreciation Data. Submit Synchronize Depreciation Data request.');
         retcode := 2;
 		 return ;
      END IF;
   /*
   -- conditions
   -- **********
   -- if this is in preview mode, create entries in igi_iac_transaction_headers
   -- if the user resubmits the record in the preview mode, delete the existing records
   -- and re-generate!
   -- if the user is in run mode and there are no run mode records, only preview records,
   -- then update the preview information to show that it is live.
   -- if the user is in run mode and there are run mode records, directly print the
   -- Asset Balance report.
   --
   --
   */
   declare
         l_phase         varchar2(240);
         l_status        varchar2(240);
         l_dev_status    varchar2(240);
         l_dev_phase     varchar2(240);
         l_message       varchar2(240);

   begin

      igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Create request id is '|| create_request_id);
      if create_request_id is not null then
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+begin wait for create request id '|| create_request_id);
        if not fnd_concurrent.wait_for_request (
                request_id  => create_request_id
                ,phase      => l_phase
                ,status     => l_status
                ,dev_phase  => l_dev_status
                ,dev_status => l_dev_phase
                ,message    => l_message
                )
        then
           igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+failed wait for create request id '|| create_request_id);
        end if;
        igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'+end wait for create request id '|| create_request_id || ' status '|| l_status);
      end if;
   end;
   commit; -- save changes
   if run_mode_hist_available ( fp_revaluation_id => revaluation_id ) then
      /** already in run mode **/
      if revaluation_mode = 'P' then
         rollback;
         errbuf := 'Already in run mode.';
         igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'Already in run mode.');
         retcode := 2;
         IF NOT IGI_IAC_REVAL_CRUD.reval_status_to_failed_run ( l_number )
         THEN
                  null;
         END IF;
         return;
      end if;

      if revaluation_mode = 'R' then
         submit_revaluation_report ( p_revaluation_id => revaluation_id
                                   , p_revaluation_mode => revaluation_mode
                                    );
         errbuf := 'Normal completion';
         igi_iac_debug_pkg.debug_other_string(g_state_level,l_path,'Normal completion');
         retcode := 0;
         IF NOT IGI_IAC_REVAL_CRUD.reval_status_to_completed ( l_number,null )
         THEN
                  null;
         END IF;
         return;
      end if;

      errbuf := 'Incorrect status passed.';
      igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'Incorrect status passed.');
      retcode := 1;
      return;

   end if; /** already in run mode **/

   if preview_mode_hist_available ( fp_revaluation_id => revaluation_id) then
      if revaluation_mode = 'P' and
         preview_mode_hist_delete ( fp_revaluation_id => revaluation_id ) then
             if not preview_mode_hist_generate ( fp_revaluation_id => revaluation_id ,
                                                 fp_book_type_code => book_type_code ,
                                                 fp_period_counter => period_counter ,
                                                 fp_wait_request_id => create_request_id
                                               ) then
                rollback;
                errbuf := 'Unable to generate history for Revaluation Preview.';
                igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'Unable to generate history for Revaluation Preview.');
                retcode := 2;
                IF NOT IGI_IAC_REVAL_CRUD.reval_status_to_previewed ( l_number )
                THEN
                  null;
                END IF;
                return;
             end if;
      end if;

      if revaluation_mode = 'R' then
         if not preview_mode_hist_transform (  fp_revaluation_id => revaluation_id
                                               , fp_book_type_code => book_type_code
                                               , fp_period_counter => period_counter
                                               )  then
            rollback;
            errbuf := 'Unable to generate history for Revaluation Preview.';
            igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'Unable to generate history for Revaluation Preview.');
            retcode := 2;
            IF NOT IGI_IAC_REVAL_CRUD.reval_status_to_failed_run ( l_number )
            THEN
               null;
            END IF;
            return;
         end if;

      end if;
   else  -- PReview mode history not available!!
        if revaluation_mode = 'P' then
             if not preview_mode_hist_generate ( fp_revaluation_id => revaluation_id
                                               , fp_book_type_code => book_type_code
                                               , fp_period_counter => period_counter
                                               , fp_wait_request_id => create_request_id
                                               ) then
                rollback;
                errbuf := 'Unable to generate history for Revaluation Preview.';
                igi_iac_debug_pkg.debug_other_string(g_error_level,l_path,'Unable to generate history for Revaluation Preview.');
                retcode := 2;
                IF NOT IGI_IAC_REVAL_CRUD.reval_status_to_failed_pre ( l_number )
                THEN
                   null;
                END IF;
                return;
             end if;
        end if;


        if revaluation_mode = 'R' then
            rollback;
            errbuf := 'No preview records';
            retcode := 0;
            IF NOT IGI_IAC_REVAL_CRUD.reval_status_to_completed ( l_number,null )
            THEN
               null;
            END IF;
            return;
          end if;
   end if;

   do_commit; -- save changes.

   submit_revaluation_report ( p_revaluation_id  => revaluation_id
                             , p_revaluation_mode => revaluation_mode
                             );

   errbuf := 'Normal completion';
   retcode := 0;
exception when others then
      errbuf := SQLERRM;
      retcode := 2;

	igi_iac_debug_pkg.debug_unexpected_msg(l_path);

end;

BEGIN
--===========================FND_LOG.START=====================================

g_state_level 	     :=	FND_LOG.LEVEL_STATEMENT;
g_proc_level  	     :=	FND_LOG.LEVEL_PROCEDURE;
g_event_level 	     :=	FND_LOG.LEVEL_EVENT;
g_excep_level 	     :=	FND_LOG.LEVEL_EXCEPTION;
g_error_level 	     :=	FND_LOG.LEVEL_ERROR;
g_unexp_level 	     :=	FND_LOG.LEVEL_UNEXPECTED;
g_path          := 'IGI.PLSQL.igiiarcb.IGI_IAC_REVAL_CONCURRENT.';

--===========================FND_LOG.END=======================================
END;


/
