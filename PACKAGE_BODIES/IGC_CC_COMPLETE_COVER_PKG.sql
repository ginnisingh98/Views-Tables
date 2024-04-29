--------------------------------------------------------
--  DDL for Package Body IGC_CC_COMPLETE_COVER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_CC_COMPLETE_COVER_PKG" AS
-- $Header: IGCCCOVB.pls 120.14.12010000.3 2008/11/19 09:35:23 schakkin ship $

   G_PKG_NAME CONSTANT VARCHAR2(30):= 'IGC_CC_COMPLETE_COVER_PKG';

   --g_debug_mode        VARCHAR2(1) := NVL(FND_PROFILE.VALUE('IGC_DEBUG_ENABLED'),'N');
   g_debug_mode        VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
--following variables added for bug 3199488: fnd logging changes: sdixit
   g_debug_level number	:=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   g_state_level number	:=	FND_LOG.LEVEL_STATEMENT;
   g_proc_level number	:=	FND_LOG.LEVEL_PROCEDURE;
   g_event_level number	:=	FND_LOG.LEVEL_EVENT;
   g_excep_level number	:=	FND_LOG.LEVEL_EXCEPTION;
   g_error_level number	:=	FND_LOG.LEVEL_ERROR;
   g_unexp_level number	:=	FND_LOG.LEVEL_UNEXPECTED;
   g_path varchar2(500) :=      'igc.plsql.igcccovb.igc_cc_complete_cover_pkg.';

   Procedure complete_cover ( errbuf               OUT NOCOPY VARCHAR2
                             ,retcode              OUT NOCOPY NUMBER
                             ,p_cc_header_id       IN  IGC_CC_HEADERS.CC_HEADER_ID%TYPE
	/*Bug No : 6341012. MOAC uptake SOB_ID,ORG_ID are retrieved from Packages rather than from Profile values */
                 --            ,p_set_of_books_id    IN  IGC_CC_HEADERS.SET_OF_BOOKS_ID%TYPE
                 --            ,p_org_id             IN  IGC_CC_HEADERS.ORG_ID%TYPE
                             ,p_comp_unmatched_rel IN VARCHAR2
                             ,p_comp_cover         IN VARCHAR2 ) IS

  /*Bug No : 6341012. MOAC uptake. Local variables for SOB_ID,ORG_ID,SOB_NAME */
      l_org_id IGC_CC_HEADERS.ORG_ID%TYPE;
      l_set_of_books_id IGC_CC_HEADERS.SET_OF_BOOKS_ID%TYPE;
      l_sob_name		VARCHAR2(30);

      l_request_id                NUMBER;
      l_validation_error_code     VARCHAR2(1);
      l_return_status             VARCHAR2(1);
      l_bc_status                 VARCHAR2(1);
      l_msg_count                 NUMBER;
      l_msg_data                  igc_cc_process_exceptions.exception_reason%TYPE;
      l_error_text                VARCHAR2(12000);

      l_stage1_parent_req         NUMBER;
      l_stage1_wait_for_request   BOOLEAN;
      l_stage1_phase              VARCHAR2(240);
      l_stage1_status             VARCHAR2(240);
      l_stage1_dev_phase          VARCHAR2(240);
      l_stage1_dev_status         VARCHAR2(240);
      l_stage1_message            VARCHAR2(240);

--      l_start_date                DATE;
      l_acct_date                 DATE;
--      l_end_date                  DATE;
--      l_count                     NUMBER;

      -- 01/03/02, added for checking if CC is enabled in IGI
      l_option_name               VARCHAR2(80);
      lv_message                  VARCHAR2(1000);
	l_full_path VARCHAR2(500) := g_path||'Complete_Cover';
---Variables related to the XML Report
      l_terr                      VARCHAR2(10):='US';
      l_lang                      VARCHAR2(10):='en';
      l_layout                    BOOLEAN;


      -- Cursor C_releases selects all releases for a cover commitment

      Cursor C_releases is
         Select *
         from igc_cc_headers
         where parent_header_id = p_cc_header_id
           and set_of_books_id  = l_set_of_books_id
           and org_id = l_org_id;

      -- Cursor C_cover selects the cover commitment information

      Cursor C_cover is
         Select *
         from igc_cc_headers
         where cc_header_id = p_cc_header_id
           and set_of_books_id  = l_set_of_books_id
           and org_id = l_org_id;

/*Bug 5464993 - No need to check for current year release payment forecasts
 * Commenting out c_fiscal_year_dates and c_payment_forecast cursors

      -- Cursor C_fiscal_year_dates selects the start and end dates of the current fiscal year

      Cursor C_fiscal_year_dates is
         -- Performance Tuning, replaced this sql with the one below.
         -- Select min(start_date) start_date, max(end_date) end_date
         -- from gl_periods_v
         -- where ( period_set_name
         --       , period_type) in ( Select period_set_name, period_type
         --                           from gl_sets_of_books_v
         --                           where set_of_books_id = ( select set_of_books_id
         --                                                     from ap_system_parameters))
         -- and period_year = to_char(sysdate, 'YYYY')
         -- and adjustment_period_flag = 'N';

         SELECT min(start_date) start_date, max(end_date) end_date
         FROM   gl_periods_v         a,
                gl_sets_of_books    b,
                ap_system_parameters c
         WHERE  a.period_set_name = b.period_set_name
         AND    a.period_type     = b.accounted_period_type
         AND    b.set_of_books_id = c.set_of_books_id
         AND    a.period_year = to_char(sysdate, 'YYYY')
         AND    a.adjustment_period_flag = 'N';


      -- Cursor C_payment_forecast counts the number of payment forecast lines
      -- in the current fiscal year for a particular CC Release

      Cursor C_payment_forecast (  x_start_date   IN DATE
                                 , x_end_date     IN DATE
                                 , x_cc_header_id IN IGC_CC_HEADERS.CC_HEADER_ID%TYPE ) IS
         Select count(*) lines
         from igc_cc_det_pf_v pf
         where pf.cc_acct_line_id in ( select al.cc_acct_line_id
                                       from igc_cc_acct_lines al
                                       where al.cc_header_id = x_cc_header_id)
           and pf.cc_det_pf_date between x_start_date and x_end_date;
*/

      -- Cursor C_purchase_orders selects the purchase orders created from a CC Release

      Cursor C_purchase_orders ( x_cc_num IN IGC_CC_HEADERS.CC_NUM%TYPE ) IS
         Select po_header_id
         from PO_HEADERS
         where segment1 = x_cc_num
           and type_lookup_code = 'STANDARD';

      /*modifed for 3199488 - fnd logging changes*/
      /*ocedure Writelog (l_full_path, p_mesg       in varchar2)IS
      Begin
            fnd_file.put_line( fnd_file.log , p_mesg ) ;
      End Writelog;*/
      PROCEDURE Writelog (
			      p_path           IN VARCHAR2,
                              p_debug_msg      IN VARCHAR2,
                              p_sev_level      IN VARCHAR2 := g_state_level
                             ) IS
      BEGIN

	IF p_sev_level >= g_debug_level THEN
		fnd_log.string(p_sev_level, p_path, p_debug_msg);
	END IF;
      END;

      -- Procedure initialise_variables initialises the variables

      Procedure initialise_variables IS
      Begin
         l_return_status   := NULL;
         l_bc_status       := NULL;
         l_msg_count       := NULL;
         l_msg_data        := NULL;
      End;

      -- Procedure update_releases update the columns of igc_cc_headers table

      Procedure Update_releases (  x_cc_state         IN IGC_CC_HEADERS.CC_STATE%TYPE
                                 , x_cc_apprvl_status IN IGC_CC_HEADERS.CC_APPRVL_STATUS%TYPE
                                 , x_ctrl_status      IN IGC_CC_HEADERS.CC_CTRL_STATUS%TYPE
                                 , x_cc_header_id     IN IGC_CC_HEADERS.CC_HEADER_ID%TYPE
                                 , x_set_of_books_id  IN IGC_CC_HEADERS.SET_OF_BOOKS_ID%TYPE
                                 , x_org_id           IN IGC_CC_HEADERS.ORG_ID%TYPE ) IS
      Begin
         Update igc_cc_headers
            set cc_state = x_cc_state
              , cc_apprvl_status = x_cc_apprvl_status
              , cc_ctrl_status = x_ctrl_status
         where cc_header_id = x_cc_header_id
           and set_of_books_id = x_set_of_books_id
           and org_id = x_org_id;
      Exception
         When others then
            raise fnd_api.g_exc_error;
      End Update_releases;


      -- Procedure Insert_exceptions insert validations or budgetary control errors
      -- for a CC in the igc_cc_process_exceptions table

      Procedure Insert_exception (
             x_request_id      IN IGC_CC_PROCESS_EXCEPTIONS.REQUEST_ID%TYPE
           , x_set_of_books_id IN IGC_CC_PROCESS_EXCEPTIONS.SET_OF_BOOKS_ID%TYPE
           , x_org_id          IN IGC_CC_PROCESS_EXCEPTIONS.ORG_ID%TYPE
           , x_process_type    IN IGC_CC_PROCESS_EXCEPTIONS.PROCESS_TYPE%TYPE
           , x_process_phase   IN IGC_CC_PROCESS_EXCEPTIONS.PROCESS_PHASE%TYPE
           , x_cc_header_id    IN IGC_CC_PROCESS_EXCEPTIONS.CC_HEADER_ID%TYPE
           , x_reason          IN IGC_CC_PROCESS_EXCEPTIONS.EXCEPTION_REASON%TYPE ) IS
      Begin
         Insert into igc_cc_process_exceptions (  process_type
                                                , process_phase
                                                , cc_header_id
                                                , exception_reason
                                                , org_id
                                                , set_of_books_id
                                                , request_id )
                                  values        ( x_process_type
                                                , x_process_phase
                                                , x_cc_header_id
                                                , x_reason
                                                , x_org_id
                                                , x_set_of_books_id
                                                , x_request_id );
      Exception
         When others then
            raise fnd_api.g_exc_error;
      End Insert_exception;

      -- Procedure Submit_report submits the exception report after the Cover commitment is
      -- processed

      Procedure Submit_report is
	l_full_path VARCHAR2(500) := g_path||'Submit_report';
      Begin

/*Bug No : 6341012. MOAC uptake. Set Operaating Unit for the request before submitting. */

	fnd_request.set_org_id(l_org_id);

         l_stage1_parent_req := Fnd_request.Submit_request
                          (  'IGC'
                           , 'IGCCCOVR'
                           , NULL
                           , NULL
                           , FALSE
                           , to_char(l_set_of_books_id)
                           , to_char(l_org_id)
                           , 'F'
                           , 'C'
                           , to_char(l_request_id)
                          );

         If  l_stage1_parent_req > 0 then
             IF g_debug_mode = 'Y' THEN
                Writelog (l_full_path,'IGCCCOVB - Submitted the Report IGCCCOVR ');
             END IF;
             Commit;
         Else
	     IF g_debug_mode = 'Y' THEN
                Writelog (l_full_path,'IGCCCOVB - Error Submitting the Report IGCCCOVR ');
             END IF;
             Raise_application_error
               (-20000,'IGCCCOVB - Error submitting IGCCCOVR '||
                        SQLERRM ||'-'||SQLCODE);
         End if;

         l_stage1_wait_for_request :=
            Fnd_concurrent.Wait_For_Request( l_stage1_parent_req,
                                             05,
                                             0,
                                             l_stage1_phase,
                                             l_stage1_status,
                                             l_stage1_dev_phase,
                                             l_stage1_dev_status,
                                             l_stage1_message );

         If ((l_stage1_dev_phase = 'COMPLETE') AND (l_stage1_dev_status = 'NORMAL')) THEN
            IF g_debug_mode = 'Y' THEN
               Writelog (l_full_path,'IGCCCOVB - COMPLETE / NORMAL status of IGCCCOVR request');
            END IF;
         Else
            IF g_debug_mode = 'Y' THEN
               Writelog (l_full_path,'IGCCCOVB - FAILED status of IGCCOVR request');
            END IF;
            Raise Fnd_api.g_exc_error;
         End if;


------------------------------------
---Run XML Report
------------------------------------
        IF IGC_CC_COMMON_UTILS_PVT.xml_report_enabled THEN
               IGC_CC_COMMON_UTILS_PVT.get_xml_layout_info(
                                            l_lang,
                                            l_terr,
                                            'IGCCCOVR_XML',
                                            'IGC',
                                            'IGCCCOVR_XML' );
               l_layout :=  FND_REQUEST.ADD_LAYOUT(
                                            'IGC',
                                            'IGCCCOVR_XML',
                                            l_lang,
                                            l_terr,
                                            'RTF');
               IF l_layout then
		         fnd_request.set_org_id(l_org_id);
                 l_stage1_parent_req := Fnd_request.Submit_request
                              (  'IGC'
                               , 'IGCCCOVR_XML'
                               , NULL
                               , NULL
                               , FALSE
                               , to_char(l_set_of_books_id)
                               , to_char(l_org_id)
                               , 'F'
                               , 'C'
                               , to_char(l_request_id)
                              );

              End if;
        End If;
        If  l_stage1_parent_req > 0 then
             IF g_debug_mode = 'Y' THEN
                Writelog (l_full_path,'IGCCCOVB - Submitted the XML Report IGCCCOVR_XML ');
             END IF;
             Commit;
         Else
	     IF g_debug_mode = 'Y' THEN
                Writelog (l_full_path,'IGCCCOVB - Error Submitting the XML Report IGCCCOVR_XML');
             END IF;
             Raise_application_error
               (-20000,'IGCCCOVB - Error submitting IGCCCOVR_XML '||
                        SQLERRM ||'-'||SQLCODE);
         End if;
         l_stage1_wait_for_request :=
            Fnd_concurrent.Wait_For_Request( l_stage1_parent_req,
                                             05,
                                             0,
                                             l_stage1_phase,
                                             l_stage1_status,
                                             l_stage1_dev_phase,
                                             l_stage1_dev_status,
                                             l_stage1_message );
         If ((l_stage1_dev_phase = 'COMPLETE') AND (l_stage1_dev_status = 'NORMAL')) THEN
            IF g_debug_mode = 'Y' THEN
               Writelog (l_full_path,'IGCCCOVB - COMPLETE / NORMAL status of IGCCCOVR_XML request');
            END IF;
         Else
            IF g_debug_mode = 'Y' THEN
               Writelog (l_full_path,'IGCCCOVB - FAILED status of IGCCOVR_XML request');
            END IF;
            Raise Fnd_api.g_exc_error;
         End if;
------------------------------------
---End Of XML Report
------------------------------------

      End Submit_report;

      Function matched_releases ( x_po_header_id IN PO_HEADERS.PO_HEADER_ID%TYPE )
                                  return boolean IS
         Cursor C_matched_releases is
         Select 'X'
         from ap_invoice_distributions ind
            , po_distributions pd
            , po_headers ph
         where ind.po_distribution_id = pd.po_distribution_id
           and pd.po_header_id = ph.po_header_id
           and ph.po_header_id = x_po_header_id;
         l_invoice_rec varchar2(1) := NULL;
      Begin
         Open C_matched_releases;
         Fetch C_matched_releases into l_invoice_rec;
         If C_matched_releases%found then
            Close c_matched_releases;
            return TRUE;
         Else
            Close C_matched_releases;
            return FALSE;
         End if;
      Exception
         When others then
            If C_matched_releases%isopen then
               Close C_matched_releases;
            End if;
            Raise Fnd_api.g_exc_error;
      End;


   -- Begin section of the complete cover procedure

   Begin


   -- 01/03/02, check to see if CC is installed

   IF NOT igi_gen.is_req_installed('CC') THEN

      SELECT meaning
      INTO l_option_name
      FROM igi_lookups
      WHERE lookup_code = 'CC'
      AND lookup_type = 'GCC_DESCRIPTION';

      FND_MESSAGE.SET_NAME('IGI', 'IGI_GEN_PROD_NOT_INSTALLED');
      FND_MESSAGE.SET_TOKEN('OPTION_NAME', l_option_name);
      IF(g_error_level >= g_debug_level) THEN
      	  FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
      END IF;
      lv_message := fnd_message.get;
      errbuf := lv_message;
      retcode := 2;
      return;
   END IF;

/* Bug No : 6341012. MOAC uptake.get ORG_ID,SOB_ID from Packages */
	l_org_id := MO_GLOBAL.get_current_org_id;
	MO_UTILS.get_ledger_info(l_org_id,l_set_of_books_id,l_sob_name);

--
      l_request_id := fnd_global.conc_request_id;
      l_validation_error_code := 'N';
      l_acct_date := SYSDATE;

      Delete from igc_cc_process_exceptions
      where process_type = 'C'
        and process_phase = 'F'
        and cc_header_id = p_cc_header_id
        and set_of_books_id = l_set_of_books_id
        and org_id = l_org_id ;

/*Commenting out the cursor for bug 5464993
 *
      Open C_fiscal_year_dates;
      Fetch C_fiscal_year_dates into l_start_date, l_end_date;
      Close C_fiscal_year_dates;
*/

      For C_rel_rec in C_releases loop
         l_msg_data := NULL;
         If ( c_rel_rec.cc_state = 'CL' and c_rel_rec.cc_apprvl_status = 'AP')
            or (c_rel_rec.cc_state = 'CT' and c_rel_rec.cc_apprvl_status = 'AP')
            or (c_rel_rec.cc_state = 'CT' and c_rel_rec.cc_apprvl_status = 'IN')
            or (c_rel_rec.cc_state = 'CM' and c_rel_rec.cc_apprvl_status = 'AP') then

/*Commenting out the cursor for bug 5464993
 *
           Open C_payment_forecast (  l_start_date
                                     , l_end_date
                                     , c_rel_rec.cc_header_id );
            Fetch C_payment_forecast into l_count;
            Close C_payment_forecast;
*/

--            If l_count > 0 then --commenting as part of fix for bug 5464993
               For C_purchase_orders_rec in C_purchase_orders ( c_rel_rec.cc_num ) loop
                  If p_comp_unmatched_rel = 'N' then
                     If matched_releases ( C_purchase_orders_rec.po_header_id) then
                        If Igc_cc_rep_yep_pvt.Invoice_canc_or_paid(c_rel_rec.cc_header_id) then
                           fnd_message.set_name('IGC', 'IGC_CC_PURCHASE_ORDER_ERROR');
                              IF(g_excep_level >= g_debug_level) THEN
                                  FND_LOG.MESSAGE(g_excep_level, l_full_path, FALSE);
                              END IF;
                           l_msg_data := fnd_message.get;
                           l_validation_error_code := 'Y';
                           Insert_exception (  l_request_id
                                             , c_rel_rec.set_of_books_id
                                             , c_rel_rec.org_id
                                             , 'C'
                                             , 'F'
                                             , c_rel_rec.cc_header_id
                                             , l_msg_data);
                           goto process_next;
                        End if;
                     Else
                        fnd_message.set_name('IGC', 'IGC_CC_INVOICE_MATCH_ERROR');
                        IF(g_error_level >= g_debug_level) THEN
                                  FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
                        END IF;
                        l_msg_data := fnd_message.get;
                        l_validation_error_code := 'Y';
                        Insert_exception (  l_request_id
                                          , c_rel_rec.set_of_books_id
                                          , c_rel_rec.org_id
                                          , 'C'
                                          , 'F'
                                          , c_rel_rec.cc_header_id
                                          , l_msg_data);
                        goto process_next;
                     End if;
                  End if;
               End loop;
               -- process the budgetary control for releases
               If ((c_rel_rec.cc_state = 'CM' and c_rel_rec.cc_apprvl_status = 'AP') OR
                   (c_rel_rec.cc_state = 'CT' and c_rel_rec.cc_apprvl_status = 'IN'))  then
                  initialise_variables;
                  Update_releases (  'CT'
                                   , 'IN'
                                   , 'C'
                                   , c_rel_rec.cc_header_id
                                   , c_rel_rec.set_of_books_id
                                   , c_rel_rec.org_id );
                  Igc_cc_po_interface_pkg.update_po_approved_flag (
                                         p_api_version      => 1.0
                                       , p_init_msg_list    => fnd_api.g_false
                                       , p_commit           => fnd_api.g_false
                                       , p_validation_level => fnd_api.g_valid_level_full
                                       , x_return_status    => l_return_status
                                       , x_msg_count        => l_msg_count
                                       , x_msg_data         => l_msg_data
                                       , p_cc_header_id     => c_rel_rec.cc_header_id );
                  If l_return_status = fnd_api.g_ret_sts_success then
                     initialise_variables;
                     Igc_cc_budgetary_ctrl_pkg.Execute_budgetary_ctrl (
                                         p_api_version      => 1.0
                                       , p_init_msg_list    => fnd_api.g_false
                                       , p_commit           => fnd_api.g_false
                                       , p_validation_level => fnd_api.g_valid_level_full
                                       , x_return_status    => l_return_status
                                       , x_bc_status        => l_bc_status
                                       , x_msg_count        => l_msg_count
                                       , x_msg_data         => l_msg_data
                                       , p_cc_header_id     => c_rel_rec.cc_header_id
                                       , p_accounting_date  => c_rel_rec.cc_acct_date
                                       , p_mode             => 'R'
                                       , p_notes            => null);
                     If l_return_status = fnd_api.g_ret_sts_success and l_bc_status = fnd_api.g_true then
                        Update_releases (  'CT'
                                         , 'AP'
                                         , 'C'
                                         , c_rel_rec.cc_header_id
                                         , c_rel_rec.set_of_books_id
                                         , c_rel_rec.org_id );
                        Igc_cc_po_interface_pkg.Convert_cc_to_po(
                                         p_api_version      => 1.0
                                       , p_init_msg_list    => fnd_api.g_false
                                       , p_commit           => fnd_api.g_false
                                       , p_validation_level => fnd_api.g_valid_level_full
                                       , x_return_status    => l_return_status
                                       , x_msg_count        => l_msg_count
                                       , x_msg_data         => l_msg_data
                                       , p_cc_header_id     => c_rel_rec.cc_header_id);
                        If l_return_status = fnd_api.g_ret_sts_success then
                           null;
                        Else
                           l_validation_error_code := 'Y';
                           Insert_exception (  l_request_id
                                             , c_rel_rec.set_of_books_id
                                             , c_rel_rec.org_id
                                             , 'C'
                                             , 'F'
                                             , c_rel_rec.cc_header_id
                                             , l_msg_data);
                        End if;
                     Else
                        l_validation_error_code := 'Y';
                        Insert_exception (  l_request_id
                                          , c_rel_rec.set_of_books_id
                                          , c_rel_rec.org_id
                                          , 'C'
                                          , 'F'
                                          , c_rel_rec.cc_header_id
                                          , l_msg_data);
                     End if;
                  Else
                     l_validation_error_code := 'Y';
                     Insert_exception (  l_request_id
                                       , c_rel_rec.set_of_books_id
                                       , c_rel_rec.org_id
                                       , 'C'
                                       , 'F'
                                       , c_rel_rec.cc_header_id
                                       , l_msg_data);
                  End if;
               End if;
--            End if; --Bug 5464993
         Else
            fnd_message.set_name('IGC', 'IGC_CC_COMPLETE_COVER_ERROR');
            fnd_message.set_token('RELEASE_STATE', c_rel_rec.cc_state);
            fnd_message.set_token('APPROVAL_STATUS', c_rel_rec.cc_apprvl_status);
            l_msg_data := fnd_message.get;
            IF(g_error_level >= g_debug_level) THEN
                 FND_LOG.MESSAGE(g_error_level, l_full_path, FALSE);
            END IF;
            l_validation_error_code := 'Y';
            Insert_exception (  l_request_id
                              , c_rel_rec.set_of_books_id
                              , c_rel_rec.org_id
                              , 'C'
                              , 'F'
                              , c_rel_rec.cc_header_id
                              , l_msg_data);
         End if;
         <<process_next>>
            null;
      End loop;

      If l_validation_error_code = 'N' and p_comp_cover = 'Y' then
         For c_cover_rec in C_cover loop
            If (c_cover_rec.cc_state = 'CM' and c_cover_rec.cc_apprvl_status = 'AP') then
               Initialise_variables;
               Update_releases (  'CT'
                                , 'IN'
                                , 'C'
                                , c_cover_rec.cc_header_id
                                , c_cover_rec.set_of_books_id
                                , c_cover_rec.org_id );
               Igc_cc_budgetary_ctrl_pkg.Execute_budgetary_ctrl (
                                         p_api_version      => 1.0
                                       , p_init_msg_list    => fnd_api.g_false
                                       , p_commit           => fnd_api.g_false
                                       , p_validation_level => fnd_api.g_valid_level_full
                                       , x_return_status    => l_return_status
                                       , x_bc_status        => l_bc_status
                                       , x_msg_count        => l_msg_count
                                       , x_msg_data         => l_msg_data
                                       , p_cc_header_id     => c_cover_rec.cc_header_id
                                       , p_accounting_date  => l_acct_date
                                       , p_mode             => 'R'
                                       , p_notes            => null);
               If l_return_status = fnd_api.g_ret_sts_success and l_bc_status = fnd_api.g_true then
                  Update_releases (  'CT'
                                   , 'AP'
                                   , 'C'
                                   , c_cover_rec.cc_header_id
                                   , c_cover_rec.set_of_books_id
                                   , c_cover_rec.org_id );
               Else
                  Insert_exception (  l_request_id
                                    , c_cover_rec.set_of_books_id
                                    , c_cover_rec.org_id
                                    , 'C'
                                    , 'F'
                                    , c_cover_rec.cc_header_id
                                    , l_msg_data);
               End if;
            End if;
         End loop;
      End if;

      Submit_report;

-- ------------------------------------------------------------------------------------
-- Ensure that any exceptions raised are output into the log file to be reported to
-- the user if any are present.
-- ------------------------------------------------------------------------------------
      FND_MSG_PUB.Count_And_Get ( p_count => l_msg_count,
                               p_data  => l_msg_data );

      IF (l_msg_count > 0) THEN
         l_error_text := '';
         FOR l_cur IN 1..l_msg_count LOOP
             l_error_text := ' Mesg No : '|| l_cur ||' '|| FND_MSG_PUB.GET(l_cur, FND_API.G_FALSE);
             fnd_file.put_line (FND_FILE.LOG,
                                l_error_text);
             WriteLog(l_full_path, l_error_text, g_excep_level);
         END LOOP;
      END IF;

      commit;
      retcode := 0;
      errbuf  := 'Normal Completion';

   -- Exception section of Complete_cover procedure

   Exception
      When Fnd_api.g_exc_error THEN
         If C_releases%isopen then
            Close C_releases;
         End if;
         If C_cover%isopen then
            Close C_cover;
         End if;
/*         IF C_fiscal_year_dates%isopen then
            Close C_fiscal_year_dates;
         End if;
         If C_payment_forecast%isopen then
            Close C_payment_forecast;
         End if; */
         If C_purchase_orders%isopen then
            Close C_purchase_orders;
         End if;
         retcode := 2;
         fnd_message.set_name('IGC','IGC_LOGGING_USER_ERROR');
	 errbuf  := fnd_message.get;
         IF g_unexp_level >= g_debug_level THEN
		fnd_message.set_name('IGC','IGC_LOGGING_UNEXP_ERROR');
                fnd_message.set_token('CODE',SQLCODE);
		fnd_message.set_token('MESG',SQLERRM);
                fnd_log.message(g_unexp_level,l_full_path,TRUE);
	 END IF;
         raise_application_error (-20000,'IGCCCOVB : '||SQLERRM ||'-'||SQLCODE);
         --raise_application_error (-20000,errbuf);
         IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
            FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Complete_cover');
         END IF;
         FND_MSG_PUB.Count_And_Get ( p_count => l_msg_count,
                                     p_data  => l_msg_data );

         IF (l_msg_count > 0) THEN

            l_error_text := '';
            FOR l_cur IN 1..l_msg_count LOOP
                l_error_text := l_cur ||' '|| FND_MSG_PUB.GET(l_cur, FND_API.G_FALSE);
                IF(g_excep_level >= g_debug_level) THEN
                      FND_LOG.STRING(g_excep_level, l_full_path, l_error_text);
                END IF;
                fnd_file.put_line (FND_FILE.LOG,
                                   l_error_text);
                WriteLog(l_full_path, l_error_text, g_excep_level);
            END LOOP;
         ELSE
            l_error_text := 'Error Returned but Error stack has no data';

            if g_excep_level >= g_debug_level then
                FND_LOG.STRING(g_excep_level, l_full_path, l_error_text);
            end if;

            fnd_file.put_line (FND_FILE.LOG,
                               l_error_text);
         END IF;

      When others then
         If C_releases%isopen then
            Close C_releases;
         End if;
         If C_cover%isopen then
            Close C_cover;
         End if;
/*         IF C_fiscal_year_dates%isopen then
            Close C_fiscal_year_dates;
         End if;
         If C_payment_forecast%isopen then
            Close C_payment_forecast;
         End if; */
         If C_purchase_orders%isopen then
            Close C_purchase_orders;
         End if;
         retcode := 2;
         fnd_message.set_name('IGC','IGC_LOGGING_USER_ERROR');
	 errbuf  := fnd_message.get;
         IF g_unexp_level >= g_debug_level THEN
		fnd_message.set_name('IGC','IGC_LOGGING_UNEXP_ERROR');
                fnd_message.set_token('CODE',SQLCODE);
		fnd_message.set_token('MESG',SQLERRM);
                fnd_log.message(g_unexp_level,l_full_path,TRUE);
	 END IF;
         raise_application_error (-20000,'IGCCCOVB : '||SQLERRM ||'-'||SQLCODE);
         IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
            FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Complete_cover');
         END IF;
         FND_MSG_PUB.Count_And_Get ( p_count => l_msg_count,
                                     p_data  => l_msg_data );

         IF (l_msg_count > 0) THEN

            l_error_text := '';
            FOR l_cur IN 1..l_msg_count LOOP
                l_error_text := ' Mesg No : '|| l_cur ||' '|| FND_MSG_PUB.GET(l_cur, FND_API.G_FALSE);
                fnd_file.put_line (FND_FILE.LOG,
                                   l_error_text);
                WriteLog(l_full_path, l_error_text, g_excep_level);
            END LOOP;
         ELSE
            l_error_text := 'Error Returned but Error stack has no data';
            fnd_file.put_line (FND_FILE.LOG,
                               l_error_text);
            WriteLog(l_full_path, l_error_text, g_excep_level);
         END IF;

   End Complete_cover ;

END IGC_CC_COMPLETE_COVER_PKG;

/
