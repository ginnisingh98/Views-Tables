--------------------------------------------------------
--  DDL for Package Body PON_SOURCING_OPENAPI_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_SOURCING_OPENAPI_GRP" AS
/* $Header: PONRNBAB.pls 120.27.12010000.2 2012/10/19 09:54:23 svalampa ship $ */

g_call_purge BOOLEAN := false;

PROCEDURE Add_Catalog_Descriptors (p_document_number IN NUMBER,
                                   p_interface_id IN NUMBER,
                                   p_from_line_number       IN  NUMBER,
                                   p_to_line_number         IN  NUMBER);

PROCEDURE INITIALISE_GLOBALS(p_interface_id IN NUMBER);

PROCEDURE create_draft_neg_interface_pvt (
                     p_interface_id NUMBER,
                     p_is_concurrent_call IN VARCHAR2,
                     p_document_number IN NUMBER,
					 x_document_number OUT NOCOPY NUMBER,
					 x_document_url OUT NOCOPY VARCHAR2,
                     x_request_id OUT NOCOPY NUMBER,
					 x_result OUT NOCOPY VARCHAR2,
					 x_error_code OUT NOCOPY VARCHAR2,
					 x_error_message OUT NOCOPY VARCHAR2);

/*======================================================================
 PROCEDURE :  create_draft_neg_interface   PUBLIC
   PARAMETERS:
   p_interface_id     IN   interface id for data to convert
   x_document_number  OUT NOCOPY  newly created draft negotiation number
   x_document_url     OUT NOCOPY  document_url to edit the draft negotiation
   x_result           OUT NOCOPY  result returned to called indicating SUCCESS or FAILURE
   x_error_code       OUT NOCOPY  error code if x_result is FAILURE, NULL otherwise
   x_error_message    OUT NOCOPY  error message if x_result is FAILURE, NULL otherwise
                           size is 250.

   COMMENT   : This is a wrapper over create_draft_neg_interface_pvt. This
               retains the signature compatibility with PO code
   ======================================================================*/

   PROCEDURE create_draft_neg_interface (p_interface_id NUMBER,
					 x_document_number OUT NOCOPY NUMBER,
					 x_document_url OUT NOCOPY VARCHAR2,
					 x_result OUT NOCOPY VARCHAR2,
					 x_error_code OUT NOCOPY VARCHAR2,
					 x_error_message OUT NOCOPY VARCHAR2)
   IS
   l_request_id NUMBER;
   BEGIN

         if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
        fnd_log.string(fnd_log.level_statement,
                   'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface',
                   'Entered with input -- '||
                   'p_interface_id : '|| p_interface_id);
        end if;


        create_draft_neg_interface_pvt (
                     p_interface_id => p_interface_id,
                     p_is_concurrent_call => 'N',
                     p_document_number => null,
					 x_document_number => x_document_number,
					 x_document_url => x_document_url,
                     x_request_id => l_request_id,
					 x_result => x_result,
					 x_error_code => x_error_code,
					 x_error_message => x_error_message
                     );

      if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
        fnd_log.string(fnd_log.level_statement,
                   'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface',
                   'returning with output -- '||
                   'x_document_number : '|| x_document_number ||
                   'x_document_url : ' || x_document_url ||
                   'x_request_id : ' || l_request_id ||
                   'x_result : ' || x_result ||
                    'x_error_code : ' || x_error_code ||
                    'x_error_message : ' || x_error_message);
      end if;


   END;

/*======================================================================
 PROCEDURE :  create_draft_neg_interface   PUBLIC
   PARAMETERS:
   p_interface_id     IN   interface id for data to convert
   x_document_number  OUT NOCOPY  newly created draft negotiation number
   x_document_url     OUT NOCOPY  document_url to edit the draft negotiation
   x_concurrent_program_started OUT NOCOPY  This will be Y if a concurrent program has stared.
   x_request_id       OUT NOCOPY  request id of the concurrent request that is
                                   submitted in the case of super large auctions
   x_result           OUT NOCOPY  result returned to called indicating SUCCESS or FAILURE
   x_error_code       OUT NOCOPY  error code if x_result is FAILURE, NULL otherwise
   x_error_message    OUT NOCOPY  error message if x_result is FAILURE, NULL otherwise
                           size is 250.

   COMMENT   : This is a wrapper over create_draft_neg_interface_pvt. This
               retains the signature compatibility with PO code
   ======================================================================*/

   PROCEDURE create_draft_neg_interface (p_interface_id NUMBER,
					 x_document_number OUT NOCOPY NUMBER,
					 x_document_url OUT NOCOPY VARCHAR2,
                     x_concurrent_program_started OUT NOCOPY VARCHAR2,
                     x_request_id OUT NOCOPY NUMBER,
					 x_result OUT NOCOPY VARCHAR2,
					 x_error_code OUT NOCOPY VARCHAR2,
					 x_error_message OUT NOCOPY VARCHAR2)
   IS
   BEGIN

         if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
        fnd_log.string(fnd_log.level_statement,
                   'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface',
                   'Entered with input -- '||
                   'p_interface_id : '|| p_interface_id);
        end if;

        x_request_id := -1;

        x_concurrent_program_started := 'N';

        create_draft_neg_interface_pvt (
                     p_interface_id => p_interface_id,
                     p_is_concurrent_call => 'N',
                     p_document_number => null,
					 x_document_number => x_document_number,
					 x_document_url => x_document_url,
                     x_request_id => x_request_id,
					 x_result => x_result,
					 x_error_code => x_error_code,
					 x_error_message => x_error_message
                     );

         if(x_request_id > 0) then

            x_concurrent_program_started := 'Y';

         end if;

      if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
        fnd_log.string(fnd_log.level_statement,
                   'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface',
                   'returning with output -- '||
                   'x_document_number : '|| x_document_number ||
                   'x_document_url : ' || x_document_url ||
                   'x_request_id : ' || x_request_id ||
                   'x_concurrent_program_started : ' || x_concurrent_program_started ||
                   'x_result : ' || x_result ||
                    'x_error_code : ' || x_error_code ||
                    'x_error_message : ' || x_error_message);
      end if;


   END;

/*======================================================================
 PROCEDURE :  create_draft_neg_interface_pvt   PRIVATE
   PARAMETERS:
   p_interface_id     IN   interface id for data to convert
   p_is_concurrent_call IN  Indicates if this procedure is called from a concurrent program or not.
                        Valid values are 'Y' and 'N' with usual meaning
   x_document_number  OUT NOCOPY  newly created draft negotiation number
   x_document_url     OUT NOCOPY  document_url to edit the draft negotiation
   x_result           OUT NOCOPY  result returned to called indicating SUCCESS or FAILURE
   x_error_code       OUT NOCOPY  error code if x_result is FAILURE, NULL otherwise
   x_error_message    OUT NOCOPY  error message if x_result is FAILURE, NULL otherwise
                           size is 250.

   COMMENT   : Create draft negotiation by reading data from interface tables
   ======================================================================*/

   PROCEDURE create_draft_neg_interface_pvt (
                     p_interface_id NUMBER,
                     p_is_concurrent_call IN VARCHAR2,
                     p_document_number IN NUMBER,
					 x_document_number OUT NOCOPY NUMBER,
					 x_document_url OUT NOCOPY VARCHAR2,
                     x_request_id OUT NOCOPY NUMBER,
					 x_result OUT NOCOPY VARCHAR2,
					 x_error_code OUT NOCOPY VARCHAR2,
					 x_error_message OUT NOCOPY VARCHAR2)
   IS

      v_debug_status         VARCHAR2(100);
      v_error_code           VARCHAR2(100);
      v_error_message        VARCHAR2(400);
      v_functional_currency_code        pon_auction_headers_all.currency_code%TYPE;
      v_currency_precision   pon_auction_headers_all.number_price_decimals%TYPE;
      v_doctype_id	     pon_auc_doctypes.doctype_id%TYPE;
      v_transaction_type     pon_auc_doctypes.transaction_type%TYPE;
      v_site_id 	     pon_auction_headers_all.trading_partner_id%TYPE;
      v_site_name 	     pon_auction_headers_all.trading_partner_name%TYPE;
      v_trading_partner_id   pon_bidding_parties.trading_partner_id%TYPE;
      v_trading_partner_name pon_bidding_parties.trading_partner_name%TYPE;
      v_trading_partner_contact_id   pon_bidding_parties.trading_partner_contact_id%TYPE;
      v_trading_partner_contact_name pon_bidding_parties.trading_partner_contact_name%TYPE;
      v_blanket_bidders_curr VARCHAR2(1) := 'N';
      v_set_as_bidders_curr  VARCHAR2(1) := 'N';
      v_order_type_lookup_code po_line_types_b.order_type_lookup_code%TYPE;

      -- The v_bidders_currency_rate multiplier is initially defaulted to 1.
      -- If the auction is in functional currency multiplying with this will
      -- have no effect.

      v_bidders_currency_rate NUMBER := 1;
      v_att_category_id	      fnd_document_categories.category_id%TYPE;
      v_seq_num		      fnd_attached_documents.seq_num%TYPE;
      v_uom_code	      pon_auction_item_prices_all.uom_code%TYPE;
      v_amount_based_lines    NUMBER;

      v_contracts_doctype    VARCHAR2(60);
      v_return_status	     VARCHAR2(1);
      v_msg_data	     VARCHAR2(400);
      v_msg_count	     NUMBER;
      v_auc_contact_id 	     pon_auction_headers_all.trading_partner_contact_id%TYPE;
      v_supplier_site_id     pon_bidding_parties.vendor_site_id%TYPE;
      v_supplier_site_code   pon_bidding_parties.vendor_site_code%TYPE;

      v_price_break_response                pon_auction_headers_all.price_break_response%type;
      v_price_break_type        pon_auction_item_prices_all.price_break_type%type;
      v_price_break_neg_flag    pon_auction_item_prices_all.price_break_neg_flag%type;
      v_price_tiers_indicator   pon_auction_headers_all.price_tiers_indicator%type;

      l_is_super_large_neg VARCHAR2(1) := 'N';
      l_number_of_lines NUMBER := -1;
      l_request_id NUMBER := -1;
      l_max_line_number NUMBER;
      l_batch_start NUMBER;
      l_batch_end NUMBER;
      l_batch_size NUMBER;
      l_last_line_number NUMBER;

      -- multi org changes
      l_old_org_id             NUMBER;
      l_old_policy             VARCHAR2(2);

      l_style_name                         po_doc_style_headers.style_name%TYPE;
      l_style_description                  po_doc_style_headers.style_description%TYPE;
      l_style_type                         po_doc_style_headers.style_type%TYPE;
      l_status                             po_doc_style_headers.status%TYPE;
      l_advances_flag                      po_doc_style_headers.advances_flag%TYPE;
      l_retainage_flag                     po_doc_style_headers.retainage_flag%TYPE;
      l_price_breaks_flag                  po_doc_style_headers.price_breaks_flag%TYPE;
      l_price_differentials_flag           po_doc_style_headers.price_differentials_flag%TYPE;
      l_progress_payment_flag              po_doc_style_headers.progress_payment_flag%TYPE;
      l_contract_financing_flag            po_doc_style_headers.contract_financing_flag%TYPE;
      l_line_type_allowed                  po_doc_style_headers.line_type_allowed%TYPE;

   BEGIN

      -- Set a savepoint, so that we can always rollback to it.
      -- Whatever happens we donot wan't to put corrupt data in
      -- the transaction tables. This is our way of assuring that
      -- this does not happen.
      SAVEPOINT pon_before_insert;

      --
      --If it is a concurrent call set the return values
      --
      IF (p_is_concurrent_call = 'Y') THEN

          if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
            fnd_log.string(fnd_log.level_statement,
                       'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                       'This is a concurrent call');
          end if;

          x_document_number := p_document_number;
          x_document_url := null;
          x_request_id := -1;
      END IF;


      -- Read data into record for convenience
      --Call INITIALISE _GLOBALS here
      INITIALISE_GLOBALS(p_interface_id =>  p_interface_id);

      -- Get site ID for the enterprise
      v_debug_status := 'SITE_ID';
      pos_enterprise_util_pkg.get_enterprise_partyId(v_site_id,
						     v_error_code,
						     v_error_message);
      IF (v_error_code IS NOT NULL OR v_site_id IS NULL) THEN
         X_RESULT := 'FAILURE';
         x_error_code := 'CREATE_DRAFT:GET_ENTERPRISE_ID';
         x_error_message := 'Could not get the Enterprise ID. Error returned by get_enterprise_partyId method is - ' || Substr(v_error_message,1,150) ;

         -- Update the process_status column in header table
         UPDATE pon_auc_headers_interface
           SET process_status = 'REJECTED'
           WHERE interface_auction_header_id = p_interface_id;

          if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
            fnd_log.string(fnd_log.level_statement,
                       'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                       x_error_message);
          end if;

         RETURN;
      END IF;

      -- Get site name for the enterprise
      v_debug_status := 'SITE_NAME';
      pos_enterprise_util_pkg.get_enterprise_party_name(v_site_name,
							v_error_code,
							v_error_message);
      IF (v_error_code IS NOT NULL) THEN
         X_RESULT := 'FAILURE';
         x_error_code := 'CREATE_DRAFT:GET_ENTERPRISE_NAME';
         x_error_message := 'Could not get the Enterprise Name. Error returned by get_enterprise_partyId method is - ' || Substr(v_error_message,1,150) ;

         -- Update the process_status column in header table
         UPDATE pon_auc_headers_interface
           SET process_status = 'REJECTED'
           WHERE interface_auction_header_id = p_interface_id;

          if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
            fnd_log.string(fnd_log.level_statement,
                       'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                       x_error_message);
          end if;

         RETURN;
      END IF;

      if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
          fnd_log.string(fnd_log.level_statement,
                 'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                 'Counting the number of lines for p_interface_id : ' || p_interface_id);
      end if;

      SELECT count(p_interface_id)
      INTO l_number_of_lines
      FROM pon_auc_items_interface
      WHERE interface_auction_header_id = p_interface_id;

      if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
          fnd_log.string(fnd_log.level_statement,
                 'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                 'l_number_of_lines (number of lines to copy into PON tables, which may not be the same as the value in number_of_lines field in PON_AUCTION_HEADERS_ALL for this auction) : '||
l_number_of_lines ||';Cheking if l_number_of_lines > Threshold for  p_party_id: '|| v_site_id);
      end if;

      PON_PROFILE_UTIL_PKG.LINES_MORE_THAN_THRESHOLD(
                p_number_of_lines => l_number_of_lines,
                p_party_id => v_site_id,
                x_is_super_large_neg => l_is_super_large_neg);

--This is for testing
--Assign l_is_super_large_neg the value 'Y'
--l_is_super_large_neg := 'Y';

      -- Get functional currency for this organization
      v_debug_status := 'CURRENCY_CODE';
      SELECT sob.currency_code, fc.precision INTO v_functional_currency_code, v_currency_precision
    FROM gl_sets_of_books sob, financials_system_params_all fsp,fnd_currencies fc
    WHERE nvl(fsp.org_id,-9999) = nvl(g_header_rec.org_id,-9999)
    AND sob.set_of_books_id = fsp.set_of_books_id
    AND sob.currency_code = fc.currency_code;


      IF (v_functional_currency_code <> g_header_rec.currency_code) THEN
     --Since functional currency code is different than the
     -- transactional code the blanket is in bidders currency
     v_blanket_bidders_curr := 'Y';
     v_bidders_currency_rate := g_header_rec.rate;
      END IF;

      -- Check to see if we are allowing other bid currencies. In which
      -- case the bidders currency gets set as a allowable foreigh currency for bidding.
      IF (g_header_rec.allow_other_bid_currency_flag = 'Y') THEN
         -- if there are amount based lines, don't allow other currencies.
         SELECT count(*) INTO v_amount_based_lines
       FROM pon_auc_items_interface paii, po_line_types_b polt
      WHERE paii.interface_auction_header_id = p_interface_id
        AND paii.line_type_id = polt.line_type_id
            AND polt.order_type_lookup_code = 'AMOUNT';

         IF (v_amount_based_lines = 0) THEN
        v_set_as_bidders_curr := 'Y';
         END IF;
      END IF ;


      -- Get doctypeID
      v_debug_status := 'DOCTYPE_ID';
      SELECT doctype_id, transaction_type
    INTO v_doctype_id, v_transaction_type
    FROM pon_auc_doctypes
    WHERE internal_name = g_header_rec.neg_type;

      -- price break header setting
      PON_AUCTION_PKG.get_default_hdr_pb_settings (
                                       v_doctype_id,
                                       v_site_id,
                                       v_price_break_response);


--ONLINE FROM HERE-------------------------------------------------------------------------------------
      --
      -- Handle Header data if it is an online call
      --
      IF (p_is_concurrent_call = 'N') THEN

          if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
              fnd_log.string(fnd_log.level_statement,
                     'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                     'This is not a concurrent call; Handling Header information now; Validating the header');
          end if;

          -- Validate data in the PON_AUC_HEADERS_INTERFACE table
          v_debug_status := 'VALIDATE_HEADER';
          val_auc_headers_interface(p_interface_id,v_error_code, v_error_message);

          -- Error encountered while validating auction header interface table data
          IF (v_error_code IS NOT NULL )  THEN
             x_result := 'FAILURE';
             x_error_code := v_error_code;
             x_error_message := v_error_message;

             -- Update the process_status column in header table
             UPDATE pon_auc_headers_interface
               SET process_status = 'REJECTED'
               WHERE interface_auction_header_id = p_interface_id;

              if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
                  fnd_log.string(fnd_log.level_statement,
                         'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                         'Error in validating the header; error mesg : ' ||x_error_message);
              end if;

             RETURN;
          END IF;


          --Insert a row in the transaction table
          v_debug_status := 'INSERT_PON_AUC_HEADERS';


         if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
            fnd_log.string(fnd_log.level_statement,
                 'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                 'preparing to insert a row in the transaction table');
          end if;

          -- Get the document_number from sequence and store it so that it can
          -- be returned

         if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
            fnd_log.string(fnd_log.level_statement,
                 'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                 'Getting the document_number from sequence');
          end if;

          SELECT pon_auction_headers_all_s.NEXTVAL INTO x_document_number
        FROM dual;

        if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
            fnd_log.string(fnd_log.level_statement,
                 'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                 'New document_number is (x_document_number) : ' ||x_document_number);
          end if;

          --Also get the document url and store it
          x_document_url := '&' || 'auctionID=' || x_document_number || '&' || 'from=RENEGOTIATE_BLANKET';

          -- copy any contracts from Blanket onto the new Document
          if (pon_conterms_utl_pvt.is_contracts_installed() = 'T') then
        begin
              select fnd_user.employee_id
              into v_auc_contact_id
          from
                fnd_user,
                hz_relationships
              where
                fnd_user.user_id = fnd_global.user_id()
                and hz_relationships.object_id = v_site_id
                and hz_relationships.subject_id = fnd_user.person_party_id
                and hz_relationships.relationship_type = 'POS_EMPLOYMENT'
                and hz_relationships.relationship_code = 'EMPLOYEE_OF'
                and hz_relationships.start_date <= SYSDATE
                and hz_relationships.end_date >= SYSDATE
                and nvl(fnd_user.end_date,sysdate) >= sysdate;
        exception
          when others then
            v_auc_contact_id := null;
                if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
              fnd_log.string(fnd_log.level_statement,
                     'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface',
                     'Could not determine contact_id for fnd_user_id ' || fnd_global.user_id());
                end if;
            end;

        v_contracts_doctype := pon_conterms_utl_pvt.get_negotiation_doc_type(v_doctype_id);

        if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
            fnd_log.string(fnd_log.level_statement,
                 'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                 'Calling okc_terms_copy_grp.copy_doc with parameters -- '||
                 'v_contracts_doctype : ' || v_contracts_doctype ||
                 'x_document_number : ' || x_document_number ||
                 'v_auc_contact_id : '|| v_auc_contact_id
                 );
       end if;

       --
       -- Get the current policy
       --
       l_old_policy := mo_global.get_access_mode();
       l_old_org_id := mo_global.get_current_org_id();
       if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
            fnd_log.string(fnd_log.level_statement,
                 'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                 'Getting current policy -- '||
                 'old policy  : ' || l_old_policy ||
                 'old org_id : ' || l_old_org_id
                 );
       end if;

       --
       -- Set the connection policy context. Bug 5040821.
       --
       mo_global.set_policy_context('S', g_header_rec.org_id);


        okc_terms_copy_grp.copy_doc(
          P_API_VERSION		=>	1.0,				-- p_api_version
          P_INIT_MSG_LIST	=>	fnd_api.g_false,		-- p_init_msg_list
          P_COMMIT		=>	fnd_api.g_false,		-- p_commit
              P_SOURCE_DOC_TYPE	=>	'PA_'||g_header_rec.origination_code, --  (origination_code is CONTRACT or BLANKET)
          P_SOURCE_DOC_ID	=> 	g_header_rec.source_doc_id,	-- p_source_doc_id
          P_TARGET_DOC_TYPE	=>	v_contracts_doctype,		-- p_target_doc_type
          P_TARGET_DOC_ID	=>	x_document_number,		-- p_target_doc_id
          P_KEEP_VERSION 	=>	'N',				-- p_keep_version (N = copy latest version)
          P_ARTICLE_EFFECTIVE_DATE =>	sysdate,			-- p_article_effective_date
          P_INITIALIZE_STATUS_YN =>	'Y',				-- p_initialize_status_yn
          P_RESET_FIXED_DATE_YN	=>	'Y',				-- p_reset_fixed_date_yn
          P_INTERNAL_PARTY_ID	=>	g_header_rec.org_id,		-- p_internal_party_id
          P_INTERNAL_CONTACT_ID	=>	v_auc_contact_id,		-- p_internal_contact_id
              P_TARGET_CONTRACTUAL_DOCTYPE	=> 'PA_'||g_header_rec.origination_code, -- (origination_code is CONTRACT or BLANKET)
          P_COPY_DEL_ATTACHMENTS_YN	=>'Y',				-- p_copy_del_attachments_yn
              P_EXTERNAL_PARTY_ID	=>	null,				-- p_external_party_id
              P_EXTERNAL_CONTACT_ID	=>	null,				-- p_external_contact_id
          P_COPY_DELIVERABLES	=>	'Y',				-- p_copy_deliverables
          P_DOCUMENT_NUMBER	=>	x_document_number,		-- p_document_number
          P_COPY_FOR_AMENDMENT	=>	'N',				-- p_copy_for_amendment
          P_COPY_DOC_ATTACHMENTS =>	'N',				-- p_copy_doc_attachments
              P_ALLOW_DUPLICATE_TERMS =>	'Y',                            -- p_allow_duplicate_terms
              P_COPY_ATTACHMENTS_BY_REF =>	'N',                            -- p_copy_attachments_by_ref
          X_RETURN_STATUS	=>	v_return_status,		-- x_return_status (S, E, U)
          X_MSG_DATA		=>	v_msg_data,			-- x_msg_data
          X_MSG_COUNT		=>	v_msg_count,			-- x_msg_count
          P_EXTERNAL_PARTY_SITE_ID =>	null		                -- p_external_party_site_id
        );

      --
      -- Set the org context back
      --
      mo_global.set_policy_context(l_old_policy, l_old_org_id);


      if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
            fnd_log.string(fnd_log.level_statement,
                   'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                   'Executed copy_doc() ; returned with status : ' ||v_return_status);
              end if;

        if (v_return_status <> fnd_api.g_ret_sts_success) then
              if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
                    fnd_log.string(fnd_log.level_statement,
                           'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                           'Call to copy_doc() failed for source_id=' || g_header_rec.source_doc_id || ' target_id=' || x_document_number);
                      end if;

                  x_result := 'FAILURE';
                  x_error_code := v_msg_data;
                  x_error_message := v_msg_data;
                  return ;
              end if;
          end if;


        --
        -- R12.1 Price Tiers Project
        -- We need to check if PO style allows price breaks or not
        --
        IF ( g_header_rec.po_style_id IS NOT NULL) THEN
	         PO_DOC_STYLE_GRP.GET_DOCUMENT_STYLE_SETTINGS(
                     p_api_version           => 1.0
                    , p_style_id             => g_header_rec.po_style_id
                    , x_style_name           => l_style_name
                    , x_style_description    => l_style_description
                    , x_style_type           => l_style_type
                    , x_status               => l_status
                    , x_advances_flag        => l_advances_flag
                    , x_retainage_flag       => l_retainage_flag
                    , x_price_breaks_flag    => l_price_breaks_flag
                    , x_price_differentials_flag => l_price_differentials_flag
                    , x_progress_payment_flag    => l_progress_payment_flag
                    , x_contract_financing_flag  => l_contract_financing_flag
                    , x_line_type_allowed       =>  l_line_type_allowed);
        END IF;

        -- R12.1 Price tiers Project
        -- Get Default price tiers indicator
        -- As Reneg blanket does not allow styles to be set while creation
        -- user can cng the style once a draft neg has been created.
        -- Default style allows quantity based price tiers passing Y as p_qty_price_tiers_enabled.

        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN --{
            fnd_log.string(fnd_log.level_statement,
                   'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                    'Calling the PON_AUCTION_PKG.GET_DEFAULT_TIERS_INDICATOR API to get the' ||
                    ' default price tiers indicator value.');
        END IF;


        PON_AUCTION_PKG.GET_DEFAULT_TIERS_INDICATOR(
                                   p_contract_type             =>  g_header_rec.contract_type,
                                   p_price_breaks_enabled      =>  l_price_breaks_flag,
                                   p_qty_price_tiers_enabled   =>  'Y',
                                   p_doctype_id                =>   v_doctype_id,
                                   x_price_tiers_indicator     =>   v_price_tiers_indicator);

        if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
            fnd_log.string(fnd_log.level_statement,
                   'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                   'Inserting row into PON_AUCTION_HEADERS_ALL with the following filed values -- ' ||
                   'auction_header_id  (x_document_number) : '|| x_document_number ||
                   '; document_number  (x_document_number) : ' || x_document_number ||
                   '; amendment_number : ' || 0 ||
                    '; auction_status : ' || 'DRAFT' ||
                    '; award_status : ' || 'NO' ||
                    '; auction_type (v_transaction_type) : '|| v_transaction_type ||
                    '; contract_type (g_header_rec.contract_type) : '|| g_header_rec.contract_type ||
                    '; trading_partner_name (v_site_name) : ' || v_site_name ||
                    '; trading_partner_name_upper (Upper(v_site_name)) : ' || Upper(v_site_name) ||
                    '; trading_partner_id (v_site_id) : '|| v_site_id ||
                    '; language_code (g_header_rec.language_code) : ' || g_header_rec.language_code ||
                    '; bid_visibility_code : ' || 'OPEN_BIDDING' ||
                    '; attachment_flag : ' || 'N' ||
                    '; ship_to_location_id (g_header_rec.ship_to_location_id) :  ' || g_header_rec.ship_to_location_id ||
                    '; bill_to_location_id (g_header_rec.bill_to_location_id) : ' || g_header_rec.bill_to_location_id ||
                    '; payment_terms_id (g_header_rec.payment_terms_id) : ' || g_header_rec.payment_terms_id ||
                    '; freight_terms_code (g_header_rec.freight_terms_code) : ' || g_header_rec.freight_terms_code ||
                    '; fob_code (g_header_rec.fob_code) : '|| g_header_rec.fob_code ||
                    '; carrier_code (g_header_rec.carrier_code) : '|| g_header_rec.carrier_code ||
                    '; note_to_bidders (g_header_rec.note_to_bidders) : ' || g_header_rec.note_to_bidders ||
                    '; po_agreed_amount (round(g_header_rec.po_agreed_amount * v_bidders_currency_rate,v_currency_precision)) : ' || round(g_header_rec.po_agreed_amount * v_bidders_currency_rate,v_currency_precision) ||
                    '; currency precision : ' || 10000 ||
                    '; global_agreement_flag ( Nvl(g_header_rec.global_agreement_flag,''N'') ) : ' || Nvl(g_header_rec.global_agreement_flag,'N') ||
                    '; creation_date : ' || sysdate ||
                    '; created_by (g_header_rec.user_id) : ' || g_header_rec.user_id ||
                    '; last_update_date : ' || sysdate ||
                    '; last_updated_by : ' || g_header_rec.user_id ||
                    '; auction_origination_code (g_header_rec.origination_code) : '|| g_header_rec.origination_code ||
                    '; doctype_id (v_doctype_id) : ' || v_doctype_id ||
                    '; org_id (g_header_rec.org_id) : ' || g_header_rec.org_id ||
                    '; buyer_id (g_header_rec.user_id) : '|| g_header_rec.user_id ||
                    '; manual_edit_flag : ' || 'N' ||
                    '; Source document number (g_header_rec.source_doc_number) : ' || g_header_rec.source_doc_number ||
                    '; Source doc id (g_header_rec.source_doc_id) : ' || g_header_rec.source_doc_id ||
                    '; Source doc number message to be displayed (g_header_rec.source_doc_msg) : ' || g_header_rec.source_doc_msg ||
                    '; Source doc line level message to be displayed (g_header_rec.source_doc_line_msg) : '|| g_header_rec.source_doc_line_msg ||
                    '; 3 character message app name (g_header_rec.source_doc_msg_app) : ' || g_header_rec.source_doc_msg_app ||
                    '; Security level code : ' || 'PUBLIC' ||
                    '; Share Award Decision : '|| 'N' ||
                    '; Approval Status : ' || 'NOT_REQUIRED' ||
                    '; po style id (g_header_rec.po_style_id) : ' || g_header_rec.po_style_id ||
                    '; price_break_response (v_price_break_response) : '|| v_price_break_response ||
                    '; Attribute Line Number : ' || -1 ||
                    '; Flag to indicate if Header Attributes are present : ' || 'N' ||
                    '; complete_flag : ' || 'N' ||
                    '; v_price_tiers_indicator : ' || v_price_tiers_indicator
                   );
          end if;


          INSERT INTO pon_auction_headers_all
        (auction_header_id,
             document_number,
             auction_header_id_orig_amend,
             auction_header_id_orig_round,
             amendment_number,
             auction_status,
         award_status,
         auction_type,
         contract_type,
         trading_partner_name,
         trading_partner_name_upper,
         trading_partner_id,
             language_code,
         bid_visibility_code,
         attachment_flag,
         ship_to_location_id,
         bill_to_location_id,
         payment_terms_id,
         freight_terms_code,
         fob_code,
         carrier_code,
         note_to_bidders,
         allow_other_bid_currency_flag,
             rate_type,
         po_agreed_amount,
         po_min_rel_amount,
         currency_code,
         number_price_decimals,
         global_agreement_flag,
         creation_date,
         created_by,
         last_update_date,
         last_updated_by,
         auction_origination_code,
         doctype_id,
         org_id,
         buyer_id,
         manual_edit_flag,
         source_doc_number,
         source_doc_id,
         source_doc_msg,
         source_doc_line_msg,
         source_doc_msg_app,
         security_level_code,
         share_award_decision,
         approval_status,
             po_style_id,
             price_break_response,
          attribute_line_number,
          has_hdr_attr_flag,
          has_items_flag,
          complete_flag,
	  progress_payment_type,
      price_tiers_indicator)
        VALUES
        (x_document_number,                  -- auction_header_id
             x_document_number,                  -- document_number
             x_document_number,                  -- auction_header_id_orig_amend,
             x_document_number,                  -- auction_header_id_orig_round,
             0,                                  -- amendment_number
         'DRAFT',                            -- auction_status
         'NO',                               -- award_status
         v_transaction_type,                 -- auction_type
         g_header_rec.contract_type,         -- contract_type
         v_site_name,                        -- trading_partner_name
         Upper(v_site_name),                 -- trading_partner_name_upper
         v_site_id,                          -- trading_partner_id
             g_header_rec.language_code,         -- language_code
         'OPEN_BIDDING',                     -- bid_visibility_code
         'N',                                -- attachment_flag
         g_header_rec.ship_to_location_id,   -- ship_to_location_id
         g_header_rec.bill_to_location_id,   -- bill_to_location_id
         g_header_rec.payment_terms_id,      -- payment_terms_id
         g_header_rec.freight_terms_code,    -- freight_terms_code
         g_header_rec.fob_code,              -- fob_code
         g_header_rec.carrier_code,          -- carrier_code
         g_header_rec.note_to_bidders,       -- note_to_bidders
         Decode(v_set_as_bidders_curr, 'Y', Decode(v_blanket_bidders_curr,'Y','Y','N'), 'N'), -- allow_other_bid_currency_flag
             Decode(v_blanket_bidders_curr,'Y',g_header_rec.rate_type, null),  -- rate_type
        round(g_header_rec.po_agreed_amount * v_bidders_currency_rate,v_currency_precision),      -- po_agreed_amount
        decode(g_header_rec.global_agreement_flag, 'Y', null, Round(g_header_rec.po_min_rel_amount * v_bidders_currency_rate,v_currency_precision)),     -- po_min_release_amount
        Decode (v_blanket_bidders_curr, 'Y',v_functional_currency_code,g_header_rec.currency_code),         -- currency_code
        10000,                              -- currency precision set to ANY
        Nvl(g_header_rec.global_agreement_flag,'N'),  -- global_agreement_flag
        Sysdate,                            -- creation_date
        g_header_rec.user_id,               -- created_by
        Sysdate,                            -- last_update_date
        g_header_rec.user_id,               -- last_updated_date
        g_header_rec.origination_code,      -- auction_origination_code
        v_doctype_id,                       -- doctype_id
        g_header_rec.org_id,                -- org_id
        g_header_rec.user_id,               -- buyer_id
        'N',                                 -- manual_edit_flag
        g_header_rec.source_doc_number,     -- Source document number
        g_header_rec.source_doc_id,         -- Source doc id
        g_header_rec.source_doc_msg,         -- Source doc number message to be displayed
        g_header_rec.source_doc_line_msg,    -- Source doc line level message to be displayed
        g_header_rec.source_doc_msg_app,     -- 3 character message app name
        'PUBLIC',                            -- Security level code
        'N',                                 -- Share Award Decision
        'NOT_REQUIRED',                      -- Approval Status
            g_header_rec.po_style_id,            -- po style id
            v_price_break_response,              -- price_break_response,
         -1,                                  -- Attribute Line Number
         'N',                                  -- Flag to indicate if Header Attributes are present
          decode(g_header_rec.contract_type,'CONTRACT','N','Y'), -- Has Items Flag
          'N',                                  --complete_flag
	  'NONE',       --Progress_Payment_Type
	  v_price_tiers_indicator               --price_tiers_indicator
      );

      if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
            fnd_log.string(fnd_log.level_statement,
                   'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                   'Inserted recore into pon_auction_headers_all');
              end if;

    END IF; --end of IF (p_is_concurrent_call = 'N')
--ONLINE TILL HERE-----------------------------------------------------------------------------------------------------


    --
    --Handle children only if
    --(a) It is not a super large negotiation OR
    --(b) It is a super large negotiation and this procedure is called from a conc_program
    --

    IF (l_is_super_large_neg = 'N') OR (l_is_super_large_neg = 'Y' AND p_is_concurrent_call = 'Y') THEN
    --{
          -- price break line setting, this should be called after header is inserted
          if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
                fnd_log.string(fnd_log.level_statement,
                       'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                       'calling PON_AUCTION_PKG.get_default_pb_settings with x_document_number : ' || x_document_number);
                  end if;

          PON_AUCTION_PKG.get_default_pb_settings (x_document_number,
                                               v_price_break_type,
                                               v_price_break_neg_flag);

          if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
                fnd_log.string(fnd_log.level_statement,
                       'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                       'v_price_break_type : ' || v_price_break_type || '; v_price_break_neg_flag : ' || v_price_break_neg_flag);
          end if;


          IF (g_header_rec.origination_code <> 'CONTRACT') THEN
           -- Validate data in the PON_AUCTION_ITEM_PRICES_INTERFACE table
           v_debug_status := 'VALIDATE_ITEM' ;

          if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
                fnd_log.string(fnd_log.level_statement,
                       'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                       'validating PON_AUCTION_ITEM_PRICES_INTERFACE; calling val_auc_items_interface with p_interface_id : ' || p_interface_id);
                  end if;

           val_auc_items_interface(p_interface_id, v_error_code, v_error_message);

           IF (v_error_code IS NOT NULL) THEN
            -- Error encountered while validating the line items
            x_result := 'FAILURE';
            x_error_code := v_error_code;
            x_error_message := v_error_message;


            -- Update the process_status column in header table
            UPDATE pon_auc_headers_interface
            SET process_status = 'REJECTED'
            WHERE interface_auction_header_id = p_interface_id;

              if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
                    fnd_log.string(fnd_log.level_statement,
                           'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                           'error when validating PON_AUCTION_ITEM_PRICES_INTERFACE; x_error_message : ' || x_error_message);
                      end if;

            RETURN;
          END IF;-- error code not null

           -- Validate data in the PON_AUCTION_SHIPMENTS_INTERFACE table

          if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
                fnd_log.string(fnd_log.level_statement,
                       'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                       'validating PON_AUCTION_SHIPMENTS_INTERFACE; calling val_auc_shipments_interface with p_interface_id : ' || p_interface_id);
                  end if;

           val_auc_shipments_interface(p_interface_id,v_error_code, v_error_message);

           IF (v_error_code IS NOT NULL ) THEN
             -- Error encountered while validating the shipments
             x_result := 'FAILURE';
             x_error_code := v_error_code;
             x_error_message := v_error_message;

            -- Update the process_status column in header table
            UPDATE pon_auc_headers_interface
            SET process_status = 'REJECTED'
            WHERE interface_auction_header_id = p_interface_id;

              if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
                    fnd_log.string(fnd_log.level_statement,
                           'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                           'error when validating PON_AUCTION_SHIPMENTS_INTERFACE; x_error_message : ' || x_error_message);
                      end if;

            RETURN;
          END IF;-- error code not null
        END IF; -- end if (g_header_rec.origination_code <> 'CONTRACT')

          if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
                fnd_log.string(fnd_log.level_statement,
                       'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                       'validating PON_ATTACHMENTS_INTERFACE; calling val_attachments_interface with p_interface_id : ' || p_interface_id);
          end if;

         -- Validate data in the PON_ATTACHMENTS_INTERFACE table
         val_attachments_interface(p_interface_id,v_error_code, v_error_message);

         IF (v_error_code IS NOT NULL ) THEN
         -- Error encountered while validating the attachments
         x_result := 'FAILURE';
         x_error_code := v_error_code;
         x_error_message := v_error_message;

         -- Update the process_status column in header table
         UPDATE pon_auc_headers_interface
           SET process_status = 'REJECTED'
           WHERE interface_auction_header_id = p_interface_id;

              if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
                    fnd_log.string(fnd_log.level_statement,
                           'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                           'error when validating PON_ATTACHMENTS_INTERFACE; x_error_message : ' || x_error_message);
              end if;

         RETURN;
          END IF;

          if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
                fnd_log.string(fnd_log.level_statement,
                       'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                       'getting category id for VENDOR attachments');
          end if;

          -- get category id for VENDOR attachments
          v_debug_status := 'ATTACHMENT_CATEGORY_ID';
          BEGIN
            SELECT category_id
              INTO v_att_category_id
              FROM fnd_document_categories
             WHERE upper(name) = 'VENDOR';
          EXCEPTION
              WHEN no_data_found THEN
                   X_RESULT := 'FAILURE';
                   X_ERROR_CODE := 'CREATE_DRAFT:ATTACHMENT_CATEGORY_ID';
                   X_ERROR_MESSAGE := 'The attachment category id for name=VENDOR could not be found';
                  if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
                        fnd_log.string(fnd_log.level_statement,
                               'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                               'error when getting category id for VENDOR attachments; x_error_message : ' || X_ERROR_MESSAGE);
                   end if;

              RETURN;
          END;

          if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
                fnd_log.string(fnd_log.level_statement,
                       'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                       'getting  UOM for amount based line types');
          end if;

          -- Get UOM for amount based line types
          v_debug_status := 'UOM_SELECT';
          BEGIN
            SELECT preference_value
            INTO v_uom_code
            FROM pon_party_preferences
            WHERE preference_name = 'AMOUNT_BASED_UOM'
              AND app_short_name = 'PON'
              AND party_id = v_site_id;
          EXCEPTION
            WHEN others THEN
          -- Don't fail!  Use 'Each' and let the user change it later
              v_debug_status := 'UOM_SELECT_EACH';
              SELECT uom_code
              INTO v_uom_code
              FROM mtl_units_of_measure
              WHERE unit_of_measure = 'Each';
          END;


        UPDATE pon_auction_headers_all
        SET price_tiers_indicator = 'PRICE_BREAKS'
        Where exists (SELECT 'Y'
              FROM   pon_auc_shipments_interface
              WHERE  interface_auction_header_id = p_interface_id
              AND rownum=1)
        AND  auction_header_id = x_document_number;

----------------------------------------------------------------------------------------------------
--BATCHING STARTS HERE--
----------------------------------------------------------------------------------------------------

          --get the number of rows to be copied

          SELECT nvl(max(interface_line_number),0) INTO l_max_line_number FROM pon_auc_items_interface
          WHERE interface_auction_header_id = p_interface_id;

          if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
                fnd_log.string(fnd_log.level_statement,
                       'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                       'Max lines to copy (l_max_line_number) : ' || l_max_line_number);
          end if;


        IF (l_max_line_number) > 0 then
            -- Draft with no lines, or RFI,CPA with no lines we need to skip batching
            -- its build into the loop logic but just to be explicit about this condition

            -- Get the batch size
            l_batch_size := PON_LARGE_AUCTION_UTIL_PKG.BATCH_SIZE;

          if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
                fnd_log.string(fnd_log.level_statement,
                       'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                       'Starting batching with batchsize (l_batch_size) : ' || l_batch_size);
          end if;

--    for testing purpose
--    l_batch_size := 2;

            -- Define the initial batch range (line numbers are indexed from 1)
             l_batch_start := 1;

             IF (l_max_line_number <l_batch_size) THEN
                l_batch_end := l_max_line_number;
             ELSE
                l_batch_end := l_batch_size;
             END IF;

            WHILE (l_batch_start <= l_max_line_number) LOOP

              if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
                    fnd_log.string(fnd_log.level_statement,
                           'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                           'Batching the line_numbers in the range '|| l_batch_start ||' to '|| l_batch_end ||' (inclusive)');
              end if;


                IF (g_header_rec.origination_code <> 'CONTRACT') THEN
                  -- Insert item level data from interface tables into transaction tables
                  -- Before that prepare the interface table. This means updating some internal
                  -- columns in the interface item level columns.
                  v_debug_status := 'INSERT_PON_AUC_ITEMS';

                 if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
                    fnd_log.string(fnd_log.level_statement,
                           'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                           'Handling Item level data; updating the pon_auc_items_interface table with the correct order_type_lookup_code values');
                  end if;


                  -- First update the pon_auc_items_interface table with the correct order_type_lookup_code values.

                  UPDATE pon_auc_items_interface paii
                SET paii.order_type_lookup_code =
                (SELECT polt.order_type_lookup_code
                 FROM po_line_types_b polt
                 WHERE paii.line_type_id = polt.line_type_id)
                WHERE paii.interface_auction_header_id = p_interface_id
                AND interface_line_number >= l_batch_start
                AND interface_line_number <= l_batch_end;

                 if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
                    fnd_log.string(fnd_log.level_statement,
                           'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                           'inserting into pon_auction_item_prices_all for auction_header_id (x_document_number) : ' || x_document_number);
                  end if;

                  -- Then insert into the items transaction table.
                  -- Here we will initially set the has_shipments flag to 'N'
                  -- and then do an update by checking if shipments are present
                  INSERT INTO pon_auction_item_prices_all
                (auction_header_id,
                 line_number,
                     disp_line_number,
                     last_amendment_update,
                     modified_date,
                 item_description,
                 category_id,
                 category_name,
                     ip_category_id,
                 uom_code,
                 residual_quantity,
                 number_of_bids,
                 creation_date,
                 created_by,
                 last_update_date,
                 last_updated_by,
                 note_to_bidders,
                 has_attributes_flag,
                 org_id,
                 line_type_id,
                 order_type_lookup_code,
                 item_id,
                 item_number,
                 item_revision,
                 line_origination_code,
                 source_doc_id,
                 source_line_id,
                 source_doc_number,
                 source_line_number,
                 current_price,
                 quantity,
                 po_min_rel_amount,
                 price_break_type,
                 price_break_neg_flag,
                 has_shipments_flag,
                 has_quantity_tiers,
                 price_disabled_flag,
                 quantity_disabled_flag,
                 --ADDED FOR SERVICES PROCUREMENT PROJECT - additional 3 columns
                 job_id,
                 po_agreed_amount,
                 purchase_basis,
                 price_diff_shipment_number,
                     group_type,
                 document_disp_line_number,
                 sub_line_sequence_number
                 )
                SELECT x_document_number,               -- auction_header_id,
                interface_line_number,                  -- line_number
                    interface_line_number,                  -- disp_line_number
                    0,                                      -- last_amendment_update
                    sysdate,                                -- modified_date
                item_description,                       -- item_description
                pon_auc_items_interface.category_id,                            -- category_id
                -- for the bug 14778209
                -- Replacing 'FND_FLEX_EXT.get_segs' method call with CONCATENATED_SEGMENTS
                -- FND_FLEX_EXT.get_segs('INV', 'MCAT', mtl_categories_kfv.STRUCTURE_ID, mtl_categories_kfv.CATEGORY_ID), -- category_name from mtl_categories_kfv table
                mtl_categories_kfv.CONCATENATED_SEGMENTS, -- category_name from mtl_categories_kfv table
                    pon_auc_items_interface.ip_category_id, -- ip_category_id
                Decode (order_type_lookup_code,'AMOUNT',v_uom_code, uom_code), -- uom_code
                Decode (order_type_lookup_code,'AMOUNT',1, quantity), -- residual quantity
                0,                                      -- number_of_bids
                Sysdate,                                -- creation_date
                g_header_rec.user_id,                   -- created_by
                Sysdate,                                -- last_update_date
                g_header_rec.user_id,                   -- last_updated_by
                note_to_bidders,                        -- note_to_bidders
                'N',                                    -- has_attribute_flag
                org_id,                                 -- org_id
                    line_type_id,                           -- line_type_id
                order_type_lookup_code,                 -- order_type_lookup_code
                item_id,                                -- item_id
                item_number,                            -- item_number
                item_revision,                          -- item_revision
                origination_code,                       -- line_origination_code
                source_doc_id,                          -- source_doc_id
                source_line_id,                         -- source_line_id
                source_doc_number,                      -- source_doc_number
                source_line_number,                     -- source_line_number
                --Decode (order_type_lookup_code, 'AMOUNT',round(quantity * v_bidders_currency_rate,v_currency_precision),round(current_price * v_bidders_currency_rate, v_currency_precision)),    -- current_price
                decode(current_price, 0, to_number(null), current_price * v_bidders_currency_rate),    -- current_price
                Decode (order_type_lookup_code,'AMOUNT',1, quantity),      -- quantity
                round(po_min_rel_amount * v_bidders_currency_rate,v_currency_precision), -- po_min_rel_amount
                Decode (order_type_lookup_code,'AMOUNT', 'NONE',  'FIXED PRICE', 'NONE', decode(price_break_type, null, 'NON-CUMULATIVE', 'NON CUMULATIVE', 'NON-CUMULATIVE', price_break_type)),  -- price_break_type
                'Y',                                    -- price_break_neg_flag. Those pbs are from po, so should always be optional
                'N',                                    -- has_shipments_flag initially set to 'N'
                'N',                                    -- has_quantity_tiers initially set to 'N'
                'N',                                    -- price_disabled_flag initially set to 'N'
                'N',                                    -- quantity_disabled_flag initially set to 'N'
                job_id,                                  -- ADDED FOR SERVICES PROCUREMENT PROJECT - job id
                po_agreed_amount,                         -- ADDED  FOR SERVICES PROCUREMENT PROJECT - PO Agreed Amount,
                purchase_basis,                          -- ADDED FOR SERVICES PROCUREMENT PROJECT - Purchase basis of line type
                -1,                                      -- Always set the price_diff_shipment_number to -1 for blankets
                    'LINE',					-- Group Type
                interface_line_number,			-- document_disp_line_number
                interface_line_number			-- sub_line_sequence_number
                FROM pon_auc_items_interface,
                mtl_categories_kfv
                WHERE interface_auction_header_id = p_interface_id
                AND interface_line_number >= l_batch_start
                AND interface_line_number <= l_batch_end
                AND mtl_categories_kfv.category_id (+) = pon_auc_items_interface.category_id;

                  -- Update the shipments flag based on if their are shipments

                 if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
                    fnd_log.string(fnd_log.level_statement,
                           'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                           ' Updating the shipments flag based on if there are shipments');
                  end if;

                  UPDATE pon_auction_item_prices_all
                  SET has_shipments_flag = 'Y'
                  WHERE (line_number) IN
                           (SELECT interface_line_number
                            FROM   pon_auc_shipments_interface
                            WHERE  interface_auction_header_id = p_interface_id
                            AND interface_line_number >= l_batch_start
                            AND interface_line_number <= l_batch_end)
                AND  auction_header_id = x_document_number;

                  -- ADDED FOR SERVICES PROCUREMENT PROJECT
                  -- Update the price differntials flag based on if their are price differentials at item level
                  if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
                    fnd_log.string(fnd_log.level_statement,
                           'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                           ' Updating the price differntials flag based on if their are price differentials at item level');
                  end if;

                  UPDATE pon_auction_item_prices_all
                  SET has_price_differentials_flag = 'Y',
                  differential_response_type = 'OPTIONAL'
                  WHERE (line_number) IN
                           (SELECT interface_line_number
                            FROM   pon_price_differ_interface
                            WHERE  interface_auction_header_id = p_interface_id
                            AND interface_line_number >= l_batch_start
                            AND interface_line_number <= l_batch_end
                            AND    interface_shipment_number = -1)
                AND  auction_header_id = x_document_number;


                  --Update the attachment_flag in pon_auction_item_prices_all table for all the
                --items that have an attachment.
            --  Since attachments can come from either po line or item itself
            --  update the flag after attachments have been inserted.
            --	UPDATE pon_auction_item_prices_all
            --	  SET attachment_flag = 'Y'
            --	  WHERE auction_header_id = x_document_number
            --	  AND line_number IN (SELECT interface_line_number
            --			      FROM pon_attachments_interface
            --			      WHERE interface_auction_header_id = p_interface_id
            --			      AND interface_line_number IS NOT NULL);

                  if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
                        fnd_log.string(fnd_log.level_statement,
                               'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                               ' CAlling Add_Catalog_Descriptors with x_document_number : ' || x_document_number || '; p_interface_id : ' || p_interface_id);
                  end if;

                  Add_Catalog_Descriptors (x_document_number, p_interface_id,l_batch_start,l_batch_end);

                  -- Insert price breaks information into the transaction table
                  v_debug_status := 'INSERT_SHIPMENTS';

                  -- When selecting price breaks we donot select the effective start date
                  -- and effective end date values. Also we want to collapse (so to speak)
                  -- all price breaks that differ only in quantity, ship_to_location_id
                  -- and the ship_to_organization_id column values. Hence we apply a group by
                  -- clause

                  if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
                        fnd_log.string(fnd_log.level_statement,
                               'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                               ' copying price breaks and price break level price differentials' );
                  end if;

                  INSERT INTO pon_auction_shipments_all
                (auction_header_id,
                 line_number,
                 shipment_number,
                 shipment_type,
                 ship_to_organization_id,
                 ship_to_location_id,
                 quantity,
                 price,
                 effective_start_date,
                 effective_end_date,
                 org_id,
                 creation_date,
                 created_by,
                 last_update_date,
                 last_updated_by,
                 has_price_differentials_flag
                 )
                SELECT
                x_document_number,           -- auction_header_id
                interface_line_number,       -- line_number
                MIN(interface_ship_number),  -- shipment_number
                'PRICE BREAK',               -- shipment_type
                ship_to_organization_id,     -- ship_to_organization_id
                ship_to_location_id,         -- ship_to_location_id
                quantity,                    -- quantity
                MIN(price * v_bidders_currency_rate), -- price
                NULL,                        -- effective_start_date
                NULL,                        -- effective_end_date
                MIN(org_id),                 -- org_id
                Sysdate,                     -- creation_date
                g_header_rec.user_id,        -- created_by
                Sysdate,                     -- last_update_date
                g_header_rec.user_id,        -- last_updated_by
                'N'
                FROM pon_auc_shipments_interface
                WHERE interface_auction_header_id = p_interface_id
                    AND interface_line_number >= l_batch_start
                    AND interface_line_number <= l_batch_end
                GROUP BY interface_line_number,ship_to_organization_id, ship_to_location_id, quantity;

                   -- ADDED FOR SERVICES PROCUREMENT PROJECT
                  -- Update the price differntials flag based on if their are price differentials at shipments level
                  UPDATE pon_auction_shipments_all
                SET has_price_differentials_flag = 'Y',
                differential_response_type = 'OPTIONAL'
                  WHERE (shipment_number) IN
                           (SELECT interface_shipment_number
                            FROM   pon_price_differ_interface
                        WHERE  interface_auction_header_id = p_interface_id
                    AND interface_shipment_number <> -1)
                AND  auction_header_id = x_document_number;

                  -- ADDED FOR SERVICES PROCUREMENT PROJECT
                  -- Insert price differentials information into the transaction table
                  -- at item level
                  v_debug_status := 'INSERT_PRICE_DIFFERENTIALS_ITEM';

                  if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
                        fnd_log.string(fnd_log.level_statement,
                               'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                               'Inserting price differentials information into the transaction table at item level' );
                  end if;

                  INSERT INTO pon_price_differentials
                (auction_header_id,
                 line_number,
                 shipment_number,
                 price_differential_number,
                 price_type,
                 multiplier,
                 creation_date,
                 created_by,
                 last_update_date,
                 last_updated_by
                 )
                SELECT
                x_document_number,              -- auction_header_id
                interface_line_number,          -- line_number
                interface_shipment_number,      -- shipment_number
                interface_price_differ_number,  -- price differentials number
                price_type,                     -- price differential type
                multiplier,                     -- multiplier
                Sysdate,                        -- creation_date
                g_header_rec.user_id,           -- created_by
                Sysdate,                        -- last_update_date
                g_header_rec.user_id            -- last_updated_by
                FROM pon_price_differ_interface
                WHERE interface_auction_header_id = p_interface_id
                AND interface_line_number >= l_batch_start
                AND interface_line_number <= l_batch_end
                AND interface_shipment_number = -1;


                  v_debug_status := 'INSERT_PRICE_DIFFERENTIALS_SHIP';

                  -- We need to store the price differentials into the transaction table.
                  -- But only store those price differentials for which the shipments have
                  -- been copied into the transaction table.
                  -- Because of the grouping above its possible that you will have some
                  -- price differentials for whom the parent shipments have been grouped
                  -- into one.

                  -- Insert price differentials information into the transaction table
                  -- at shipment level

                  if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
                        fnd_log.string(fnd_log.level_statement,
                               'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                               'Inserting price differentials information into the transaction table at shipment level' );
                  end if;

                  INSERT INTO pon_price_differentials
                (auction_header_id,
                 line_number,
                 shipment_number,
                 price_differential_number,
                 price_type,
                 multiplier,
                 creation_date,
                 created_by,
                 last_update_date,
                 last_updated_by
                 )
                SELECT
                x_document_number,              -- auction_header_id
                interface_line_number,          -- line_number
                interface_shipment_number,      -- shipment_number
                interface_price_differ_number,  -- price differentials number
                price_type,                     -- price differential type
                multiplier,                     -- multiplier
                Sysdate,                        -- creation_date
                g_header_rec.user_id,           -- created_by
                Sysdate,                        -- last_update_date
                g_header_rec.user_id            -- last_updated_by
                FROM pon_price_differ_interface
                WHERE interface_auction_header_id = p_interface_id
                AND interface_line_number >= l_batch_start
                AND interface_line_number <= l_batch_end
                AND interface_shipment_number <> -1
                AND interface_shipment_number IN (SELECT min(interface_ship_number)
                                                  FROM pon_auc_shipments_interface
                                  WHERE interface_auction_header_id = p_interface_id
                                  GROUP BY interface_line_number,ship_to_organization_id, ship_to_location_id, quantity);

                   -- Copy over the attachments from the PON_ATTACHMENTS_INTERFACE table
                  v_debug_status := 'INSERT_LINE_ATTACHMENTS';

                  if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
                        fnd_log.string(fnd_log.level_statement,
                               'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                               'Copying over the (Line) attachments from the PON_ATTACHMENTS_INTERFACE table' );
                  end if;

                  INSERT INTO fnd_attached_documents
                ( attached_document_id,
                  document_id,
                  creation_date,
                  created_by,
                  last_update_date,
                  last_updated_by,
                  last_update_login,
                  seq_num,
                  entity_name,
                  pk1_value,
                  pk2_value,
                  pk3_value,
                  pk4_value,
                  pk5_value,
                  automatically_added_flag,
                  column1
                  )
                SELECT fnd_attached_documents_s.nextval,      -- attached_document_id
                document_id,                           -- document_id,
                Sysdate,                               -- creation_date
                g_header_rec.user_id,                  -- created_by
                Sysdate,                               -- last_update_date
                g_header_rec.user_id,                  -- last_updated_by
                NULL,                                  -- last_update_login
                seq_num,                               -- seq_num
                'PON_AUCTION_ITEM_PRICES_ALL',         -- entity_name
                x_document_number,                     -- pk1_value
                    interface_line_number,                 -- pk2_value
                NULL,                                  -- pk3_value
                NULL,                                  -- pk4_value
                NULL,                                  -- pk5_value
                'N',                                   -- automatically_added_flag
                NULL                                   -- column1
                FROM pon_attachments_interface
                WHERE interface_auction_header_id = p_interface_id
                AND interface_line_number IS NOT NULL
                AND interface_line_number >= l_batch_start
                AND interface_line_number <= l_batch_end;

                  --Update the attachment_flag in pon_auction_item_prices_all
                  --table for all the items that have attachments.

                  if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
                        fnd_log.string(fnd_log.level_statement,
                               'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                               'Updating the attachment_flag in pon_auction_item_prices_all table for all the items that have attachments.' );
                  end if;

                UPDATE pon_auction_item_prices_all
                   SET attachment_flag = 'Y'
                 WHERE auction_header_id = x_document_number
                   AND line_number IN (SELECT to_number(pk2_value)
                                 FROM fnd_attached_documents
                                WHERE entity_name = 'PON_AUCTION_ITEM_PRICES_ALL'
                                  AND pk1_value = to_char(x_document_number))
                                  AND line_number >= l_batch_start
                                  AND line_number <= l_batch_end;


               END IF; --End if  (g_header_rec.origination_code <> 'CONTRACT')


            --commit the DML transactions of this batch only if it is a concurrent call

             IF (p_is_concurrent_call = 'Y') THEN
                if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
                      fnd_log.string(fnd_log.level_statement,
                             'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                             'This being a concurrent call, the batch is being committed( from line numbers ' || l_batch_start || ' to ' || l_batch_end);
                end if;

                COMMIT;

             END IF;

            l_batch_start := l_batch_end + 1;

            IF (l_batch_end + l_batch_size > l_max_line_number) THEN
                l_batch_end := l_max_line_number;
            ELSE
                l_batch_end := l_batch_end + l_batch_size;
            END IF;

            if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
                  fnd_log.string(fnd_log.level_statement,
                         'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                         'Computed the window for next batch to be ' || l_batch_start || ' to ' || l_batch_end || ' (inclusive) ' );
            end if;

        END LOOP;

    END IF;

----------------------------------------------------------------------------------------------------
--BATCHING ENDS HERE--
----------------------------------------------------------------------------------------------------

     --}
      END IF; --IF (l_is_super_large_neg = N) OR (l_is_super_large_neg = 'Y' AND p_is_concurrent_call = 'Y')

      --
      --Handle the remaining header information
      --and miscellaneous information like supplier details etc
      --Do this task only if it is an online call
      --
      IF (p_is_concurrent_call = 'N') THEN

           -- Copy over the attachments from the PON_ATTACHMENTS_INTERFACE table
           v_debug_status := 'INSERT_HEADER_ATTACHMENTS';

              if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
                    fnd_log.string(fnd_log.level_statement,
                           'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                           'Copying over the (header)attachments from the PON_ATTACHMENTS_INTERFACE table' );
              end if;

           INSERT INTO fnd_attached_documents
            ( attached_document_id,
              document_id,
              creation_date,
              created_by,
              last_update_date,
              last_updated_by,
              last_update_login,
              seq_num,
              entity_name,
              pk1_value,
              pk2_value,
              pk3_value,
              pk4_value,
              pk5_value,
              automatically_added_flag,
              column1
              )
            SELECT
            fnd_attached_documents_s.nextval,      -- attached_document_id
            document_id,                           -- document_id,
            Sysdate,                               -- creation_date
            g_header_rec.user_id,                  -- created_by
            Sysdate,                               -- last_update_date
            g_header_rec.user_id,                  -- last_updated_by
            NULL,                                  -- last_update_login
            seq_num,                               -- seq_num
            'PON_AUCTION_HEADERS_ALL',             -- entity_name
            x_document_number,                     -- pk1_value
            NULL,                                  -- pk2_value
            NULL,                                  -- pk3_value
            NULL,                                  -- pk4_value
            NULL,                                  -- pk5_value
            'N',                                   -- automatically_added_flag
            NULL                                   -- column1
            FROM pon_attachments_interface
            WHERE interface_auction_header_id = p_interface_id
            AND interface_line_number IS NULL;


              -- If the Blanket was in bidders currency see if the user wanted us to
              -- copy over the currency into PON_AUC_CURR_INFO table
              v_debug_status := 'INSERT_BIDDERS_CURR';

              IF (v_set_as_bidders_curr = 'Y' AND v_blanket_bidders_curr = 'Y') THEN

              if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
                    fnd_log.string(fnd_log.level_statement,
                           'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                           'Copying over the currency into PON_AUC_CURR_INFO table' );
              end if;

             INSERT INTO pon_auction_currency_rates
               ( auction_header_id,
                 auction_currency_code,
                 bid_currency_code,
                 --rate,
                 --rate_dsp,
                 number_price_decimals,
                 sequence_number,
                 last_update_date,
                 last_updated_by,
                 creation_date,
                 created_by
                 ) VALUES
               ( x_document_number,                             -- auction_header_id
                 v_functional_currency_code,                    -- auction_currency_code
                 g_header_rec.currency_code,                    -- bid_currency_code
                 --Decode(g_header_rec.rate_type,'User',g_header_rec.rate, NULL),   -- rate
                 --Decode(g_header_rec.rate_type,'User',1/g_header_rec.rate, NULL), -- rate_dsp
                 10000,                                         -- number_price_decimals set to ANY
                 10,                                            -- sequence_number
                 Sysdate,                                       -- last_update_date
                 g_header_rec.user_id,                          -- last_updated_by
                 Sysdate,                                       -- creation_date
                 g_header_rec.user_id                           -- created_by
                 )	     	     ;
              END IF;

              -- Add the supplier information on the blanket to the PON_BIDDING_PARTIES
              -- transaction table.
              v_debug_status := 'INSERT_SUPPLIER_INFO';

              if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
                    fnd_log.string(fnd_log.level_statement,
                           'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                           'Addding the supplier information on the blanket to the PON_BIDDING_PARTIES; selectiong supplier_site_id' );
              end if;

            select supplier_site_id
            into  v_supplier_site_id
            from pon_auc_headers_interface
            WHERE interface_auction_header_id = p_interface_id;

            if(v_supplier_site_id is not null and v_supplier_site_id <> -1)  then
             BEGIN
                select vendor_site_code
                into  v_supplier_site_code
                from po_vendor_sites_all
                where vendor_site_id = v_supplier_site_id  ;
             EXCEPTION
              WHEN no_data_found THEN
                    v_supplier_site_code := '-1';
             END;

            else
             v_supplier_site_id := -1;
             v_supplier_site_code := '-1';
            end if;

        --lxchen
              if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
                    fnd_log.string(fnd_log.level_statement,
                           'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                           'Getting supplier information' );
              end if;

              -- Get the supplier information
              get_trading_partner_info(g_header_rec.supplier_id,
                           v_trading_partner_id,
                           v_trading_partner_name,
                           v_trading_partner_contact_id,
                           v_trading_partner_contact_name,
                           v_error_code,
                           v_error_message);

              IF (v_error_code IS NOT NULL) THEN
                 X_RESULT := 'FAILURE';
                 x_error_code := v_error_code;
                 x_error_message := v_error_message;

                 -- Update the process_status column in header table
                 UPDATE pon_auc_headers_interface
                   SET process_status = 'REJECTED'
                   WHERE interface_auction_header_id = p_interface_id;

                  if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
                        fnd_log.string(fnd_log.level_statement,
                               'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                               'Error in retrieving supplier information for supplier_id : ' || g_header_rec.supplier_id );
                  end if;

                 RETURN;
              END IF;

              if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
                    fnd_log.string(fnd_log.level_statement,
                           'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                           'Inserting record into PON_BIDDING_PARTIES' );
              end if;


              INSERT INTO pon_bidding_parties
            (auction_header_id,
                 list_id,
             sequence,
             trading_partner_name,
             trading_partner_id,
             trading_partner_contact_id,
             trading_partner_contact_name,
             --bid_currency_code,
             --number_price_decimals,
             --rate,
             --rate_dsp,
             vendor_site_id,
             vendor_site_code,
             last_update_date,
             last_updated_by,
             creation_date,
             created_by,
                 access_type
             )VALUES
            (x_document_number,                    -- auction_header_id
                 -1,                                   -- list id
             10,                                    -- sequence
             v_trading_partner_name,               -- trading_partner_name
             v_trading_partner_id,                 -- trading_partner_id
             v_trading_partner_contact_id,         -- trading_partner_contact_id
             v_trading_partner_contact_name,       -- trading_partner_contact_name
             --g_header_rec.currency_code,           -- bid_currency_code
             --10000,                 -- number_price_decimals,set to ANY
             --Decode(g_header_rec.rate_type,'USER',g_header_rec.rate, NULL),   -- rate
             --Decode(g_header_rec.rate_type,'USER',1/g_header_rec.rate, NULL), -- rate_dsp
             v_supplier_site_id,                 -- default vendor site id
             v_supplier_site_code,                -- default vendor site code
             Sysdate,                              -- last_update_date
             g_header_rec.user_id,                 -- last_updated_by
             Sysdate,                              -- creation_date
             g_header_rec.user_id,                 -- created_by
                 'FULL'                                -- access_type
             );

            --
            --If it's a super large auction, then raise a concurrent request here
            --to handle the children
            --
          if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
                fnd_log.string(fnd_log.level_statement,
                       'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                       'Is this auction super large? (l_is_super_large_neg) : ' || l_is_super_large_neg);
          end if;

            IF (l_is_super_large_neg = 'Y') THEN
                  if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
                        fnd_log.string(fnd_log.level_statement,
                               'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                               'Raising a concurrent request here');
                  end if;

                        --RAISE CONCURRENT REQUEST HERE
                        l_request_id := FND_REQUEST.submit_request(
                                                        application    =>    'PON',
                                                        program        =>    'PON_RENEGOTIATE_BLANKET',
                                                        description    =>    null,
                                                        start_time     =>    null,
                                                        sub_request    =>    FALSE,
                                                        argument1      =>    to_char(p_interface_id),
                                                        argument2      =>    to_char(x_document_number),
                                                        argument3      =>    FND_GLOBAL.USER_NAME
                                                        );

                  if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
                        fnd_log.string(fnd_log.level_statement,
                               'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                               'Concurrent request successfully raised; Request id : ' || l_request_id ||' ; setting the request information into pon_auction_headers_all');
                  end if;

                  update pon_auction_headers_all set
                    request_id = l_request_id,
                    number_of_lines = 0,
                    requested_by = g_header_rec.user_id ,
                    request_date = sysdate,
                    last_update_date = sysdate,
                    last_updated_by = g_header_rec.user_id ,
                    complete_flag = 'N'
                  where auction_header_id = x_document_number;

                  x_request_id := l_request_id;

            END IF;

     END IF; --IF (p_is_concurrent_call = 'N')

-----------------------------------------------------------------------------
      -- Set the result to success and unset any variables required.
      if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
            fnd_log.string(fnd_log.level_statement,
                   'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                   'Setting the result to success');
      end if;

      x_result := 'SUCCESS';

      --
      --Update the header record process_status to ACCEPTED and
      --COMPLETE_FLAG in pon_auction_headers_all to 'Y'.
      --Also set the NUMBER_OF_LINES and LAST_LINE_NUMBER fields
      --This should not be done if
      --(a) It is not a super large auction OR
      --(b) It is a super large auction and the call to this function is
      --    from a concurrent program
      --
    IF (l_is_super_large_neg = 'N') OR (l_is_super_large_neg = 'Y' AND p_is_concurrent_call = 'Y') THEN

        if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
            fnd_log.string(fnd_log.level_statement,
                   'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                   'updating the process_status in pon_auc_headers_interface to ACCEPTED');
        end if;

        UPDATE pon_auc_headers_interface
        SET process_status = 'ACCEPTED'
        WHERE interface_auction_header_id = p_interface_id;

        if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
            fnd_log.string(fnd_log.level_statement,
                   'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                   'updating the complete_flag in pon_auc_headers_all to Y');
        end if;


        SELECT
        COUNT(LINE_NUMBER) number_of_lines, MAX (DECODE (GROUP_TYPE, 'LOT_LINE', 0, 'GROUP_LINE', 0, SUB_LINE_SEQUENCE_NUMBER)) last_line_number
        INTO l_number_of_lines, l_last_line_number
        FROM PON_AUCTION_ITEM_PRICES_ALL
        WHERE
        AUCTION_HEADER_ID = x_document_number;




        UPDATE pon_auction_headers_all
        SET complete_flag = 'Y', number_of_lines = l_number_of_lines, last_line_number = l_last_line_number
        WHERE auction_header_id = x_document_number;

    END IF; --IF (l_is_super_large_neg = N) OR (l_is_super_large_neg = 'Y' AND p_is_concurrent_call = 'Y')

      --call commit. This is for TEST purposes only
      --COMMIT;

      if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
        fnd_log.string(fnd_log.level_statement,
                   'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                   'returning with output -- '||
                   'x_document_number : '|| x_document_number ||
                   'x_document_url : ' || x_document_url ||
                   'x_result : ' || x_result ||
                    'x_error_code : ' || x_error_code ||
                    'x_error_message : ' || x_error_message);
      end if;

   EXCEPTION
      WHEN others THEN
	 fnd_message.set_name('PON','PON_AUC_PLSQL_ERR');
	 fnd_message.set_token('PACKAGE','PON_SOURCING_OPENAPI_GRP');
	 fnd_message.set_token('PROCEDURE', 'create_draft_neg_interface');
	 fnd_message.set_token('ERROR',v_debug_status || '[' || SQLERRM || ']');

	 ROLLBACK  TO SAVEPOINT pon_before_insert;

	 app_exception.raise_exception;

   END create_draft_neg_interface_pvt;

/*======================================================================
 PROCEDURE :  val_auc_headers_interface   PUBLIC
   PARAMETERS:
   p_interface_id           IN    interface id for the auction that is being validated
   x_error_code            OUT NOCOPY    error code if any error generate
   x_error_message         OUT NOCOPY    error message if any error

   COMMENT : validates the data in the pon_auc_headers_interface table
   ======================================================================*/

   PROCEDURE val_auc_headers_interface(p_interface_id NUMBER,
				       x_error_code OUT NOCOPY VARCHAR2,
				       x_error_message OUT NOCOPY VARCHAR2)
   IS
      v_debug_status VARCHAR2(100);
      v_count_auc_headers_interface  NUMBER := 0;
      v_multi_org fnd_product_groups.multi_org_flag%TYPE := 'Y';
      v_process_status VARCHAR2(25);

   BEGIN

      v_debug_status := 'VALIDATE_HEADER';

      -- Validate that the actual parameter p_interfaceid is a valid value
      IF (p_interface_id IS NULL) THEN
	 x_error_code := 'VALIDATE_HEADER:NULL_INTERFACE_ID';
	 x_error_message := 'Interface ID cannot be null';

	 RETURN;
      END IF;


      -- Validate that there is a single record for p_interface_id
      -- in the PON_AUC_HEADERS_INTERFACE table.
      SELECT COUNT(*) INTO v_count_auc_headers_interface
	FROM pon_auc_headers_interface
	WHERE interface_auction_header_id = p_interface_id;

      IF (v_count_auc_headers_interface = 0 )THEN
	  x_error_code := 'VALIDATE_HDR:INVALID_INTERFACE_ID';
	  x_error_message := 'Cannot find header interface data for interface id ' || p_interface_id ;
	  RETURN;
      END IF;

      -- Validate that the process_status for the record is null
      /**
      SELECT process_status INTO v_process_status
	FROM pon_auc_headers_interface
	WHERE interface_auction_header_id = p_interface_id;

      IF (v_process_status IS NOT NULL) THEN
	 x_error_code := 'VALIDATE_HDR:INVALIDATE_PROCESS_STATUS';
	 x_error_message := 'Process status value cannot be set before creating draft negotiation.';
	 RETURN;
      END IF ;
	**/


      -- Read data into record for convenience
      --Call INITIALISE _GLOBALS is no more needed
      --here as it is called in create_draft_neg_interface_pvt

      --INITIALISE_GLOBALS(p_interface_id =>  p_interface_id);


       -- Validate org_id is not null
       IF (g_header_rec.org_id IS NULL) THEN
	  x_error_code := 'VALIDATE_HDR:NULL_ORG_ID';
	  x_error_message := 'Please specify an ORG_ID';
	  RETURN;
       END IF;

       -- Validate that the origination_code is 'BLANKET' or 'CONTRACT'
       IF (g_header_rec.origination_code <> 'BLANKET' AND g_header_rec.origination_code <> 'CONTRACT') THEN
	  x_error_code := 'VALIDATE_HDR:INVALID_AUCTION_ORIGNATION_CODE';
	  x_error_message := 'Invalid origination_code ' || g_header_rec.origination_code || ' in header interface table' ;

	  RETURN;
       END IF;


       -- Validate that the contract_type is 'BLANKET'
       IF g_header_rec.contract_type <> 'BLANKET' THEN
	  x_error_code := 'VALIDATE_HDR:INVALID_CONTRACT_TYPE';
	  x_error_message := 'Invalid contract_type ' || g_header_rec.contract_type || ' in header interface table' ;

	  RETURN;
       END IF;

       -- Validate that the document_type is 'BUYER_AUCTION' or 'REQUEST_FOR_QUOTE' only
       IF NOT (g_header_rec.neg_type = 'BUYER_AUCTION' OR g_header_rec.neg_type = 'REQUEST_FOR_QUOTE') THEN
	  x_error_code := 'VALIDATE_HDR:INVALID_NEG_TYPE';
	  x_error_message := 'Invalid neg_type. Valid values are BUYER_AUCTION or REQUEST_FOR_QUOTE only';
	  RETURN;
       END IF;

       -- Validate that the buyer_id is not null
       IF (g_header_rec.user_id IS NULL) THEN
	  x_error_code := 'VALIDATE_HDR:INVALID_BUYER_ID';
	  x_error_message := 'Invalid buyer_id. This field should not be empty.';
	  RETURN;
       END IF;


    EXCEPTION
     WHEN others THEN
	fnd_message.set_name('PON','PON_AUC_PLSQL_ERR');
	fnd_message.set_token('PACKAGE','PON_SOURCING_OPENAPI_GRP');
	fnd_message.set_token('PROCEDURE', 'val_auc_headers_interface');
	fnd_message.set_token('ERROR',v_debug_status || '[' || SQLERRM || ']');
	app_exception.raise_exception;

   END val_auc_headers_interface;


/*======================================================================
 PROCEDURE :  val_auc_items_interface   PUBLIC
   PARAMETERS:
   p_interface_id           IN     interfaceid for the auction that is being validated
   x_error_code            OUT NOCOPY    errcode if any error generate
   x_error_message         OUT NOCOPY    error message if any error

   COMMENT : validates the data in the pon_auc_items_interface table
   In this procedure we do column wise validation
   ======================================================================*/

   PROCEDURE val_auc_items_interface(p_interface_id NUMBER,
				     x_error_code OUT NOCOPY VARCHAR2,
				     x_error_message OUT NOCOPY VARCHAR2)
   IS
      v_debug_status VARCHAR2(100);
      v_invalid_item_recs  NUMBER;
      v_item_org_id NUMBER := 0;

   BEGIN

      v_debug_status := 'VALIDATING_ITEMS';

      if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
            fnd_log.string(fnd_log.level_statement,
                   'pon.plsql.pon_sourcing_openapi_grp.val_auc_items_interface',
                   'Validating the lines in the range ; validating item org_id');
      end if;

      -- validate item org_id is the same as that in the header

      SELECT MIN(interface_line_number) INTO v_invalid_item_recs
	 FROM pon_auc_items_interface
	 WHERE interface_auction_header_id = p_interface_id
	 AND org_id <> g_header_rec.org_id;

       IF (v_invalid_item_recs IS NOT NULL ) THEN

          if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
                fnd_log.string(fnd_log.level_statement,
                       'pon.plsql.pon_sourcing_openapi_grp.val_auc_items_interface',
                       'Error in validating item org_id');
          end if;

          x_error_code := 'VALIDATE_ITEMS:INCORRECT_ORG_ID';
          x_error_message := 'Item interface table org_id does not match the header org id - ' || g_header_rec.org_id || ' for line ' || v_invalid_item_recs;

	  RETURN;
       END IF;

       -- Validate origination_code is BLANKET

      if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
            fnd_log.string(fnd_log.level_statement,
                   'pon.plsql.pon_sourcing_openapi_grp.val_auc_items_interface',
                   'Validating origination_code is BLANKET');
      end if;

       v_debug_status := 'VALIDATE_LINE_ORG_CODE';

       SELECT MIN(interface_line_number) INTO v_invalid_item_recs
	 FROM pon_auc_items_interface
	 WHERE interface_auction_header_id = p_interface_id
 	 AND origination_code <> 'BLANKET';

       IF (v_invalid_item_recs IS NOT NULL )  THEN

          if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
                fnd_log.string(fnd_log.level_statement,
                       'pon.plsql.pon_sourcing_openapi_grp.val_auc_items_interface',
                       'Error in validating origination_code is BLANKET');
          end if;

          x_error_code := 'VALIDATE_ITEMS:INVALID_LINE_ORIGINATION_CODE';
          x_error_message := 'Invalid origination_code in item interface table' ;

          RETURN;
       END if;

       -- Validate that price_break_type values are CUMULATIVE, NON-CUMMULATIVE or null

      if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
            fnd_log.string(fnd_log.level_statement,
                   'pon.plsql.pon_sourcing_openapi_grp.val_auc_items_interface',
                   'Validating that price_break_type values are CUMULATIVE, NON-CUMMULATIVE or null');
      end if;

       v_debug_status := 'VALIDATE_PRICE_BREAK_TYPE';

       SELECT MIN(interface_line_number) INTO v_invalid_item_recs
	 FROM pon_auc_items_interface
	 WHERE interface_auction_header_id = p_interface_id
 	 AND decode(price_break_type, null, 'NONE', 'NON CUMULATIVE', 'NON-CUMULATIVE', price_break_type) NOT IN ('CUMULATIVE', 'NON-CUMULATIVE','NONE');

       IF (v_invalid_item_recs IS NOT NULL )  THEN

          if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
                fnd_log.string(fnd_log.level_statement,
                       'pon.plsql.pon_sourcing_openapi_grp.val_auc_items_interface',
                       'Error in validating that price_break_type values are CUMULATIVE, NON-CUMMULATIVE or null');
          end if;

          x_error_code := 'VALIDATE_ITEMS:INVALID_PRICE_BREAK_TYPE';
          x_error_message := 'Invalid price break type in item interface table' ;

          RETURN;
       END if;

      if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
            fnd_log.string(fnd_log.level_statement,
                   'pon.plsql.pon_sourcing_openapi_grp.val_auc_items_interface',
                   'Returning with x_error_code : ' || x_error_code || '; x_error_message : ' || x_error_message);
      end if;

    EXCEPTION
       WHEN others THEN
	  fnd_message.set_name('PON','PON_AUC_PLSQL_ERR');
	  fnd_message.set_token('PACKAGE','PON_SOURCING_OPENAPI_GRP');
	  fnd_message.set_token('PROCEDURE', 'val_auc_items_interface');
	  fnd_message.set_token('ERROR',v_debug_status || '[' || SQLERRM || ']');
	  app_exception.raise_exception;

    END val_auc_items_interface;


/*======================================================================
 PROCEDURE :  val_auc_shipments_interface   PUBLIC
   PARAMETERS:
   p_interface_id           IN     interfaceid for the auction that is being validated
   x_error_code            OUT NOCOPY    errcode if any error generate
   x_error_message         OUT NOCOPY    error message if any error

   COMMENT : validates the data in the pon_auc_shipments_interface table
   ======================================================================*/

   PROCEDURE val_auc_shipments_interface(p_interface_id NUMBER,
					 x_error_code OUT NOCOPY VARCHAR2,
					 x_error_message OUT NOCOPY VARCHAR2)
   IS
      v_debug_status VARCHAR2(100);
      v_shipment_number NUMBER := 0;
      v_shipment_org_id NUMBER := 0;
      v_shipment_rec VARCHAR2(40);

   BEGIN

      if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
            fnd_log.string(fnd_log.level_statement,
                   'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                   'Entered the procedure');
      end if;

      -- validate item org_id is the same as that in the header

      SELECT MIN (To_char(interface_line_number) || '-' || To_char(interface_ship_number))
	INTO v_shipment_rec
	FROM pon_auc_shipments_interface
	WHERE interface_auction_header_id = p_interface_id
	AND org_id <> g_header_rec.org_id;

      IF (v_shipment_rec IS NOT null) THEN

          if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
                fnd_log.string(fnd_log.level_statement,
                       'pon.plsql.pon_sourcing_openapi_grp.val_auc_items_interface',
                       'Error in validating item org_id');
          end if;

         x_error_code := 'VALIDATE_SHIPMENTS:INCORRECT_ORG_ID';
         x_error_message := 'Shipments interface table org_id does not match the header org id - ' || g_header_rec.org_id || ' for record - ' || v_shipment_rec;

         RETURN;
      END IF;

      -- Validate the shipment type columns have correct values

      if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
            fnd_log.string(fnd_log.level_statement,
                   'pon.plsql.pon_sourcing_openapi_grp.create_draft_neg_interface_pvt',
                   'Validating the shipment type columns have correct values');
      end if;

      v_debug_status := 'VALIDATE_SHIPMENT_TYPE';
      SELECT MIN(To_char(interface_line_number) || '-' || To_char(interface_ship_number))
	INTO v_shipment_rec
	FROM pon_auc_shipments_interface
	WHERE interface_auction_header_id = p_interface_id
	AND shipment_type <> 'PRICE BREAK';

      IF (v_shipment_rec IS NOT NULL ) THEN

         x_error_code := 'VALIDATE_SHIPMENTS:INVALID_SHIP_TYPE';
         x_error_message := 'Invalid shipment_type in val_auc_shipments_interface table at record ' || v_shipment_rec;
         RETURN;
      END IF;


   EXCEPTION
      WHEN others THEN
	 fnd_message.set_name('PON','PON_AUC_PLSQL_ERR');
	 fnd_message.set_token('PACKAGE','PON_SOURCING_OPENAPI_GRP');
	 fnd_message.set_token('PROCEDURE', 'val_auc_shipments_interface');
	 fnd_message.set_token('ERROR',v_debug_status || '[' || SQLERRM || ']');
	 app_exception.raise_exception;

   END val_auc_shipments_interface;

/*======================================================================
 PROCEDURE :  val_attachments_interface   PUBLIC
   PARAMETERS:
   p_interface_id          IN     Interface Header Id
   x_error_code            OUT NOCOPY    errcode if any error generate
   x_error_message         OUT NOCOPY    error message if any error

   COMMENT : validates the data in the pon_attachments_interface table.
   The basic validation that is performed is to make sure that every
   record in this table corresponds to a valid header or valid line item
   in the other interface tables.
   ======================================================================*/

   PROCEDURE val_attachments_interface(p_interface_id NUMBER,
				       x_error_code OUT NOCOPY VARCHAR2,
				       x_error_message OUT NOCOPY VARCHAR2)
   IS
      v_debug_status VARCHAR2(100);

   BEGIN
      v_debug_status := 'ATTACHMENTS';

      RETURN;

   EXCEPTION
      WHEN others THEN
	 fnd_message.set_name('PON','PON_AUC_PLSQL_ERR');
	 fnd_message.set_token('PACKAGE','PON_SOURCING_OPENAPI_GRP');
	 fnd_message.set_token('PROCEDURE', 'val_attachments_interface');
	 fnd_message.set_token('ERROR',v_debug_status || '[' || SQLERRM || ']');
	 app_exception.raise_exception;

   END val_attachments_interface;


/*======================================================================
 PROCEDURE :  get_trading_partner_info   PUBLIC
   PARAMETERS:
   p_vendor_id                   IN     vendor id for whom we need info
   x_trading_partner_id          OUT NOCOPY    trading_partner_id
   x_trading_partner_name        OUT NOCOPY    name of the supplier
   x_trading_partner_contact_id  OUT NOCOPY    id of the first contact person
   for this trading_partner
   x_trading_partner_contact_name OUT NOCOPY   trading_partner contact name
   x_error_code                  OUT NOCOPY    errcode if any error generate
   x_error_message               OUT NOCOPY    error message if any error

   COMMENT : gets the trading_partner_information given a vendor id
   ======================================================================*/

   PROCEDURE get_trading_partner_info(p_vendor_id NUMBER,
				      x_trading_partner_id OUT NOCOPY NUMBER,
				      x_trading_partner_name OUT NOCOPY VARCHAR2,
				      x_trading_partner_contact_id OUT NOCOPY VARCHAR2,
				      x_trading_partner_contact_name OUT NOCOPY VARCHAR2,
				      x_error_code OUT NOCOPY VARCHAR2,
				      x_error_message OUT NOCOPY varchar2)
   IS
      v_debug_status VARCHAR2(100);
      v_relationship_id NUMBER;
      v_exception_message VARCHAR2(400);
      v_error_status VARCHAR2(100);

   BEGIN

      -- Get the trading_partner_name and trading_partner_id of the supplier on
      -- the existing blanket
      v_debug_status := 'TRADING_PARTNER';
      x_trading_partner_id := pos_vendor_util_pkg.get_party_id_for_vendor(p_vendor_id);

      SELECT party_name INTO x_trading_partner_name
	FROM hz_parties
	WHERE party_id = x_trading_partner_id;

      -- Get the first contact as default contact for this trading_partner
      v_debug_status := 'TRADING_PARTNER_CONTACT';

      BEGIN
	 SELECT object_id INTO x_trading_partner_contact_id
	   FROM hz_relationships
	   WHERE subject_id = x_trading_partner_id
	   AND relationship_type = 'CONTACT'
	   AND relationship_code = 'CONTACT_OF'
	   AND start_date < Sysdate
	   AND Nvl(end_date, Sysdate+1) > Sysdate
	   AND status = 'A'
	   AND ROWNUM = 1;

	 SELECT user_name INTO x_trading_partner_contact_name
	   FROM fnd_user
	   WHERE person_party_id = x_trading_partner_contact_id
         AND nvl(fnd_user.end_date,sysdate) >= sysdate;

      EXCEPTION

	 WHEN too_many_rows THEN
        IF ( FND_LOG.level_error >= fnd_log.g_current_runtime_level) then
          FND_LOG.string(log_level => FND_LOG.level_error,
                         module    => ' get_trading_partner_info ',
                         message   => ' Error while fetching UserName from fnd_user '|| SQLERRM);
        END IF;

	    SELECT user_name
        INTO x_trading_partner_contact_name
	    FROM fnd_user
	    WHERE person_party_id = x_trading_partner_contact_id
        AND nvl(end_date,sysdate) >= sysdate
        AND ROWNUM = 1;
       RETURN;

	 WHEN no_data_found THEN
	    --When no trading_partner_contact is found donot return error.
	    --x_error_code := 'GET_TRADING_PARTNER_INFO:NO_TP_CONTACT_FOUND';
	    --x_error_message := 'Could not find default contact for TP';
	    x_trading_partner_contact_name := NULL;
	    RETURN;
      END;

      RETURN;

   EXCEPTION
      WHEN others THEN
	 fnd_message.set_name('PON','PON_AUC_PLSQL_ERR');
	 fnd_message.set_token('PACKAGE','PON_SOURCING_OPENAPI_GRP');
	 fnd_message.set_token('PROCEDURE', 'get_trading_partner_info');
	 fnd_message.set_token('ERROR',v_debug_status || '[' || SQLERRM || ']');
	 app_exception.raise_exception;

   END get_trading_partner_info;



/*======================================================================
 PROCEDURE :  purge_interface_table   PUBLIC
   PARAMETERS:
   p_interface_id     IN     interfaceid for the auction that is being validated
   x_result           OUT NOCOPY  result returned to called indicating SUCCESS or FAILURE
   x_error_code       OUT NOCOPY    errcode if any error generate
   x_error_message    OUT NOCOPY    error message if any error. size is 250.

   COMMENT : gets the trading_partner_information given a vendor id
   ======================================================================*/

   PROCEDURE purge_interface_table(p_interface_id IN NUMBER,
				   x_result OUT NOCOPY VARCHAR2,
				   x_error_code OUT NOCOPY VARCHAR2,
				   x_error_message OUT NOCOPY VARCHAR2
				   )
   IS

      v_debug_status VARCHAR2(100);

   BEGIN

      IF (NOT g_call_purge) THEN
        x_result := 'SUCCESS';
        return;
      END IF;

      x_result := 'FAILURE';

      -- Delete records from header table
      v_debug_status := 'DELETE_HEADER';

      DELETE FROM pon_auc_headers_interface
	WHERE interface_auction_header_id = p_interface_id;

      -- Delete records from item table
      v_debug_status := 'DELETE_ITEM';

      DELETE FROM pon_auc_items_interface
	WHERE interface_auction_header_id = p_interface_id;

      -- Deletes records from attributes table
      v_debug_status := 'DELETE_ATTRIBUTES';

      DELETE FROM pon_attributes_interface
        WHERE interface_auction_header_id = p_interface_id;

      -- Delete records from shipments table
      v_debug_status := 'DELETE_SHIPMENTS';

      DELETE FROM pon_auc_shipments_interface
	WHERE interface_auction_header_id = p_interface_id;

      -- ADDED FOR SERVICES PROCUREMENT PROJECT
      -- Delete records from price differentials table
      v_debug_status := 'DELETE_PRICE_DIFFERENTIALS';

      DELETE FROM pon_price_differ_interface
	WHERE interface_auction_header_id = p_interface_id;

      -- Delete records from attachments table
      v_debug_status := ' DELETE_ATTACHMENTS';

      DELETE FROM pon_attachments_interface
	WHERE interface_auction_header_id = p_interface_id;

      x_result := 'SUCCESS';

      RETURN;

   EXCEPTION
      WHEN others THEN
	 fnd_message.set_name('PON','PON_AUC_PLSQL_ERR');
	 fnd_message.set_token('PACKAGE','PON_SOURCING_OPENAPI_GRP');
	 fnd_message.set_token('PROCEDURE', 'purge_interface_table');
	 fnd_message.set_token('ERROR','[' || SQLERRM || ']');
	 app_exception.raise_exception;
   END purge_interface_table;

-------------------------------------------------------------------------------
--Start of Comments
--Name: is_cpa_integration_enabled
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This procedure determines if CPA outcome from rfq feature is enabled  or not.
--Parameters:
--IN:
--p_init_msg_list
--  True/False parameter to initialize message list
--  Defaults to false if nothing specified
--p_api_version
--  API version
--OUT:
--x_msg_count
--  Message count
--x_msg_data
--  message data
--x_return_status
--  FND_API.G_RET_STS_UNEXP_ERROR - for unexpected error
--x_cpa_enabled
--  Y  if creation of CPA from sourcing is enabled
--  N  if creation of CPA from sourcing is disabled.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE is_cpa_integration_enabled
            (p_api_version               IN VARCHAR2
            ,p_init_msg_list             IN VARCHAR2
            ,x_return_status             OUT NOCOPY VARCHAR2
            ,x_msg_count                 OUT NOCOPY NUMBER
            ,x_msg_data                  OUT NOCOPY VARCHAR2
            ,x_cpa_enabled               OUT NOCOPY VARCHAR2) IS

  -- declare local variables
  l_api_name CONSTANT VARCHAR2(30) := 'IS_CPA_INTEGRATION_ENABLED';
  l_pkg_name CONSTANT VARCHAR2(30) := 'PON_SOURCING_OPENAPI_GRP';
  l_api_version CONSTANT VARCHAR2(5) := '1.0';

BEGIN

   IF NOT (FND_API.compatible_api_call(l_api_version
                                     ,p_api_version
                                     ,l_api_name
                                     ,l_pkg_name)) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- initialize API return status to success
   x_return_status:= FND_API.G_RET_STS_SUCCESS;

   -- initialize meesage list
   IF (FND_API.to_Boolean(nvl(p_init_msg_list,FND_API.G_FALSE))) THEN
       FND_MSG_PUB.initialize;
   END IF;

   x_cpa_enabled := 'Y';

EXCEPTION
     WHEN OTHERS THEN
     X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg(l_pkg_name, l_api_name,SQLERRM);
         IF ( FND_LOG.level_unexpected >= fnd_log.g_current_runtime_level) then
           FND_LOG.string(log_level => FND_LOG.level_unexpected
                          ,module    => l_pkg_name ||'.'||l_api_name
                          ,message   => SQLERRM);
         END IF;
     END IF;
     FND_MSG_PUB.Count_and_Get(p_count => x_msg_count
                              ,p_data  => x_msg_data);
END is_cpa_integration_enabled;

/* ======================================================================
PROCEDURE :  get_display_line_number  PUBLIC
   PARAMETERS:
   p_api_version          IN   API Version (currently 1.0)
   p_init_msg_list        IN   call FND_MSG_PUB.initialize() ? T/F
   p_auction_header_id    IN   Auction Header Id of Sourcing document
   p_auction_line_number  IN   Line Number (internal) within the Sourcing document
   x_display_line_number  OUT  Line Number for display to users (buffer size 25)
   x_result               OUT  One of G_RET_STS_SUCCESS, G_RET_STS_ERROR, G_RET_STS_UNEXP_ERROR
   x_error_code           OUT  Error code if x_result <> SUCCESS
   x_error_message        OUT  Error message if x_result is FAILURE (buffer size 250)
   x_return_status        OUT  One of G_RET_STS_SUCCESS, G_RET_STS_ERROR, G_RET_STS_UNEXP_ERROR
   x_msg_count            OUT  Error message count
   x_msg_data             OUT  Error message data

   COMMENT:
        This procedure translates the auction_line_number to a string to
display to the user.  Since the display_line_number can change at any time
during auction creation, this procedure should be called each time the line
is displayed rather than cacheing the return value.
====================================================================== */

procedure get_display_line_number(
                p_api_version           IN NUMBER,
                p_init_msg_list         IN VARCHAR2,
                p_auction_header_id     IN NUMBER,
                p_auction_line_number   IN NUMBER,
                x_display_line_number   OUT NOCOPY VARCHAR2,
                x_return_status         OUT NOCOPY VARCHAR2,
                x_msg_count             OUT NOCOPY NUMBER,
                x_msg_data              OUT NOCOPY VARCHAR2) IS

  l_pkg_name CONSTANT VARCHAR2(30) := 'PON_SOURCING_OPENAPI_GRP';
  l_api_name CONSTANT VARCHAR2(30) := 'get_display_line_number';
  l_api_version CONSTANT NUMBER := 1.0;

begin
  IF NOT (FND_API.compatible_api_call(l_api_version,
                                      p_api_version,
                                      l_api_name,
                                      l_pkg_name)) THEN
    FND_MSG_PUB.Count_and_Get(p_count => x_msg_count,
                              p_data  => x_msg_data);
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- initialize meesage list
  IF (FND_API.to_Boolean(nvl(p_init_msg_list, FND_API.G_FALSE))) THEN
    FND_MSG_PUB.initialize();
  END IF;

  begin
    select
      document_disp_line_number
    into
      x_display_line_number
    from
      pon_auction_item_prices_all
    where
      auction_header_id = p_auction_header_id and
      line_number = p_auction_line_number;
  exception
    when others then
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MSG_PUB.add_exc_msg(l_pkg_name, l_api_name, SQLERRM);
        IF ( FND_LOG.level_error >= fnd_log.g_current_runtime_level) then
          FND_LOG.string(log_level => FND_LOG.level_error,
                         module    => l_pkg_name || '.' || l_api_name,
                         message   => 'Negotiation ' || p_auction_header_id || ' and line ' || p_auction_line_number || ' not found. ' || SQLERRM);
        END IF;
      END IF;
      FND_MSG_PUB.Count_and_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      return;
  end;

  x_return_status := fnd_api.g_ret_sts_success;

exception
  when others then
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
      FND_MSG_PUB.add_exc_msg(l_pkg_name, l_api_name, SQLERRM);
      IF (FND_LOG.level_unexpected >= fnd_log.g_current_runtime_level) then
        FND_LOG.string(log_level => FND_LOG.level_unexpected,
                       module    => l_pkg_name ||'.'|| l_api_name,
                       message   => SQLERRM);
      END IF;
    END IF;
    FND_MSG_PUB.Count_and_Get(p_count => x_msg_count,
                              p_data  => x_msg_data);
end get_display_line_number;


/* ======================================================================
PROCEDURE :  get_display_line_number  PUBLIC
   PARAMETERS:

    p_document_number IN NUMBER   Auction_header_id in PON_AUCTION_HEADERS_ALL
    p_interface_id IN NUMBER      interface id
    p_from_line_number       IN     Line number from whcih the validation has to start
    p_to_line_number         IN     Line number till whcih the validation has to be done

   COMMENT:
    Adds catalog to the lines that are in the range p_from_line_number to
    p_to_line_number (inclusive)
====================================================================== */

PROCEDURE Add_Catalog_Descriptors (p_document_number IN NUMBER,
                                   p_interface_id IN NUMBER,
                                   p_from_line_number       IN  NUMBER,
                                   p_to_line_number         IN  NUMBER) IS
v_ip_attr_default_option VARCHAR2(10);
v_default_attr_group pon_auction_attributes.attr_group%TYPE;
v_max_seq_number       NUMBER;
v_attr_group_name      fnd_lookup_values.meaning%TYPE;

CURSOR lines IS
   SELECT interface_line_number
   FROM   pon_auc_items_interface
   WHERE  interface_auction_header_id = p_interface_id
   AND interface_line_number >= p_from_line_number
   AND interface_line_number <= p_to_line_number;

BEGIN

  v_ip_attr_default_option := fnd_profile.value('PON_IP_ATTR_DEFAULT_OPTION');

  IF (v_ip_attr_default_option is null or v_ip_attr_default_option = 'NONE') THEN
    RETURN;
  END IF;

  select nvl(ppp.preference_value,'GENERAL'),
         flv.meaning
  into   v_default_attr_group,
         v_attr_group_name
  from pon_party_preferences ppp,
       fnd_lookup_values flv
  where ppp.app_short_name = 'PON' and
        ppp.preference_name = 'LINE_ATTR_DEFAULT_GROUP' and
        ppp.party_id = (select trading_partner_id from pon_auction_headers_all where auction_header_id = p_document_number) and
        flv.lookup_type = 'PON_LINE_ATTRIBUTE_GROUPS' and
        nvl(ppp.preference_value,'GENERAL') = flv.lookup_code and
        flv.view_application_id = 0 and
        flv.security_group_id = 0 and
        flv.language = nvl(g_header_rec.language_code, userenv('LANG'));

  v_max_seq_number := 9999999999999;

  FOR line in LINES
  LOOP

    INSERT INTO PON_AUCTION_ATTRIBUTES (
       AUCTION_HEADER_ID,
       LINE_NUMBER,
       ATTRIBUTE_NAME,
       DESCRIPTION,
       DATATYPE,
       MANDATORY_FLAG,
       VALUE,
       DISPLAY_PROMPT,
       HELP_TEXT,
       DISPLAY_TARGET_FLAG,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       ATTRIBUTE_LIST_ID,
       DISPLAY_ONLY_FLAG,
       SEQUENCE_NUMBER,
       COPIED_FROM_CAT_FLAG,
       WEIGHT,
       SCORING_TYPE,
       ATTR_LEVEL,
       ATTR_GROUP,
       SECTION_NAME,
       ATTR_MAX_SCORE,
       INTERNAL_ATTR_FLAG,
       ATTR_GROUP_SEQ_NUMBER,
       ATTR_DISP_SEQ_NUMBER,
       MODIFIED_FLAG,
       MODIFIED_DATE,
       LAST_AMENDMENT_UPDATE,
       IP_CATEGORY_ID,
       IP_DESCRIPTOR_ID
    )
    SELECT
       P_DOCUMENT_NUMBER,                -- AUCTION_HEADER_ID
       line.interface_line_number,       -- LINE_NUMBER
       ATTRIBUTE_NAME,                   -- ATTRIBUTE_NAME
       null,                             -- DESCRIPTION
       DATATYPE,                         -- DATATYPE
       'N',                              -- MANDATORY_FLAG
       VALUE,                            -- VALUE
       null,                             -- DISPLAY_PROMPT
       null,                             -- HELP_TEXT
       'N',                              -- DISPLAY_TARGET_FLAG
       SYSDATE,                          -- CREATION_DATE
       g_header_rec.user_id,             -- CREATED_BY
       SYSDATE,                          -- LAST_UPDATE_DATE
       g_header_rec.user_id,             -- LAST_UPDATED_BY
       -1,                               -- ATTRIBUTE_LIST_ID
       'N',                              -- DISPLAY_ONLY_FLAG
       (ROWNUM*10),                      -- SEQUENCE_NUMBER
       null,                             -- COPIED_FROM_CAT_FLAG
       null,                             -- WEIGHT
       null,                             -- SCORING_TYPE
       'LINE',                           -- ATTR_LEVEL
       v_default_attr_group,             -- ATTR_GROUP
       v_attr_group_name,                -- SECTION_NAME
       null,                             -- ATTR_MAX_SCORE
       'N',                              -- INTERNAL_ATTR_FLAG
       10,                               -- ATTR_GROUP_SEQ_NUMBER
       (ROWNUM*10),                      -- ATTR_DISP_SEQ_NUMBER
       null,                             -- MODIFIED_FLAG
       null,                             -- MODIFIED_DATE
       null,                             -- LAST_AMENDMENT_UPDATE
       IP_CATEGORY_ID,                   -- IP_CATEGORY_ID
       IP_DESCRIPTOR_ID                  -- IP_DESCRIPTOR_ID
    FROM
       (SELECT attribute_name, datatype, value, ip_category_id, ip_descriptor_id
        FROM   pon_attributes_interface
        WHERE  interface_auction_header_id = p_interface_id AND
               interface_line_number = line.interface_line_number AND
               ((ip_category_id = 0 and v_ip_attr_default_option in ('ALL', 'BASE')) or
                (ip_category_id <> 0 and v_ip_attr_default_option in ('ALL', 'CATEGORY')))
        ORDER BY nvl(interface_sequence_number, v_max_seq_number) asc);

  END LOOP;

END Add_Catalog_Descriptors;


/* ======================================================================
PROCEDURE :  INITIALISE_GLOBALS  PRIVATE
   PARAMETERS:
           p_interface_id     IN   interface id for data to convert

   COMMENT:
        This procedure is used to initialise the global variables.
====================================================================== */

PROCEDURE INITIALISE_GLOBALS(p_interface_id IN NUMBER)
is
BEGIN

      if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
        fnd_log.string(fnd_log.level_statement,
                   'pon.plsql.pon_sourcing_openapi_grp.initialise_globals',
                   'Entered the procedure; initialising g_header_rec');
      end if;

      -- Read data into header record for convenience
       SELECT * INTO g_header_rec
	 FROM pon_auc_headers_interface
	 WHERE interface_auction_header_id = p_interface_id;

     if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
    fnd_log.string(fnd_log.level_statement,
               'pon.plsql.pon_sourcing_openapi_grp.initialise_globals',
               'initialised g_header_rec; Entered the procedure');
     end if;

END INITIALISE_GLOBALS;


--PROCEDURE FOR RENEGOTIATING SUPER LARGE NEGOTIATIONS
--This procedure will be called by the concurrent
--manager. This inturn calls the create_draft_neg_interface_pvt
--procedure with p_is_conc_call = 'Y'


PROCEDURE PON_RENEG_SUPER_LARGE_NEG  (
          EFFBUF           OUT NOCOPY VARCHAR2,
          RETCODE          OUT NOCOPY VARCHAR2,
          p_interface_id    IN NUMBER,
          p_auction_header_id IN NUMBER,
          p_user_name IN VARCHAR2
          )
is
    l_document_number NUMBER := null;
    l_document_url  VARCHAR2(240) := null;
    l_result    VARCHAR2(240) := null;
    l_error_code VARCHAR2(240) := null;
    l_error_message VARCHAR2(240) := null;
    l_request_id NUMBER;
    dummy NUMBER;
    l_message_suffix varchar2(1);

BEGIN
      if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
        fnd_log.string(fnd_log.level_statement,
                   'pon.plsql.pon_sourcing_openapi_grp.pon_reneg_super_large_neg',
                   'This is a concurrent program; Entered the procedure');
      end if;

--set the message_suffix
      IF (g_header_rec.neg_type = PON_WF_UTL_PKG.SRC_AUCTION) THEN
      --if it is an auction then the suffix is _B
         l_message_suffix := 'B';
      ELSE
      --it is an RFQ
         l_message_suffix := 'R';
      END IF;

      l_request_id := FND_GLOBAL.CONC_REQUEST_ID;

      if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
        fnd_log.string(fnd_log.level_statement,
                   'pon.plsql.pon_sourcing_openapi_grp.pon_reneg_super_large_neg',
                   'The request Id of this concurrent process is ' || l_request_id ||'; Now calling create_draft_neg_interface_pvt');
      end if;

        create_draft_neg_interface_pvt (
                     p_interface_id => p_interface_id,
                     p_is_concurrent_call => 'Y',
                     p_document_number => p_auction_header_id,
					 x_document_number => l_document_number,
					 x_document_url => l_document_url,
                     x_request_id => dummy,
					 x_result => l_result,
					 x_error_code => l_error_code,
					 x_error_message => l_error_message
                     );
         IF (l_result <> 'SUCCESS') THEN
            RETCODE := '2' ;

              if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
                fnd_log.string(fnd_log.level_statement,
                           'pon.plsql.pon_sourcing_openapi_grp.pon_reneg_super_large_neg',
                           l_error_message);
              end if;

         ELSE

              if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
                fnd_log.string(fnd_log.level_statement,
                           'pon.plsql.pon_sourcing_openapi_grp.pon_reneg_super_large_neg',
                           'purging the tables; calling PON_SOURCING_OPENAPI_GRP.PURGE_INTERFACE_TABLE()');
              end if;

                g_call_purge := true;
            	PURGE_INTERFACE_TABLE (
                    p_interface_id => p_interface_id,
                    x_result => l_result,
                    x_error_code => l_error_code,
                    x_error_message => l_error_message);
                g_call_purge := false;
                 IF (l_result <> 'SUCCESS') THEN
                    RETCODE := '2' ;

                      if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
                        fnd_log.string(fnd_log.level_statement,
                                   'pon.plsql.pon_sourcing_openapi_grp.pon_reneg_super_large_neg',
                                   l_error_message);
                      end if;

                  END IF;

                if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
                    fnd_log.string(fnd_log.level_statement,
                               'pon.plsql.pon_sourcing_openapi_grp.pon_reneg_super_large_neg',
                               'Notifying SUCCESS');
                end if;

            	PON_WF_UTL_PKG.ReportConcProgramStatus (
                    p_request_id => l_request_id,
                    p_messagetype => 'S',
                    p_RecepientUsername => p_user_name,
                    p_recepientType => 'BUYER',
                    p_auction_header_id => p_auction_header_id,
                    p_ProgramTypeCode => 'NEG_RENEGOTIATE',
                    p_DestinationPageCode => 'PON_MANAGE_DRAFT_NEG',
                    p_bid_number => NULL);

--
--Don't clear the request_id as the status of the
--concurrent program has to be shown to the user
--
--Ref: ECO - 4517992
--

/*                if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
                  fnd_log.string(fnd_log.level_statement,
                           'pon.plsql.pon_sourcing_openapi_grp.pon_reneg_super_large_neg',
                           'Clearing request_id in pon_auction_headers_all');
                end if;

                update pon_auction_headers_all
                set request_id = null
                where auction_header_id = p_auction_header_id;
*/
            	RETCODE := '0';

                if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
                  fnd_log.string(fnd_log.level_statement,
                           'pon.plsql.pon_sourcing_openapi_grp.pon_reneg_super_large_neg',
                           'Cleared request_id in pon_auction_headers_all for auction_header_id : ' || p_auction_header_id ||' ; returning');
                end if;

            	Commit;

         END IF;

         IF (RETCODE <> '0') THEN
         	PON_WF_UTL_PKG.ReportConcProgramStatus (
                p_request_id => l_request_id,
                p_messagetype => 'E',
                p_RecepientUsername => p_user_name,
                p_recepientType => 'BUYER',
                p_auction_header_id => p_auction_header_id,
                p_ProgramTypeCode => 'NEG_RENEGOTIATE',
                p_DestinationPageCode =>  'PON_MANAGE_DRAFT_NEG',
                p_bid_number => NULL);
                if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
                    fnd_log.string(fnd_log.level_statement,
                               'pon.plsql.pon_sourcing_openapi_grp.pon_reneg_super_large_neg',
                               'Notifying FAILURE');
              end if;

         END IF;



EXCEPTION
    WHEN OTHERS THEN

--when an  unexpected exception arises in the COPY_NEGOTIATION
--procedure, we need to do the following

--rollback the transactions
       rollback;

--report error to the user

        PON_WF_UTL_PKG.ReportConcProgramStatus (
            p_request_id => l_request_id,
            p_messagetype => 'E',
            p_RecepientUsername => p_user_name,
            p_recepientType => 'BUYER',
            p_auction_header_id => p_auction_header_id,
            p_ProgramTypeCode => 'NEG_RENEGOTIATE',
            p_DestinationPageCode =>  'PON_MANAGE_DRAFT_NEG',
            p_bid_number => NULL);

--insert into interface errors table

       insert into pon_interface_errors (
           ERROR_MESSAGE_NAME,
           request_id,
           auction_header_id,
           application_short_name,
           token1_name,
           token1_value,
           token2_name,
           token2_value,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login,
           expiration_date
         )
       values(
          'PON_RENEG_ERROR_MSG_'||l_message_suffix,
          l_request_id,
          p_auction_header_id,
          'PON',
          'DOC_NUM',
          p_auction_header_id,
          'REQUEST_ID',
          l_request_id,
          g_header_rec.user_id,
          SYSDATE,
          g_header_rec.user_id,
          SYSDATE,
          fnd_global.login_id,
          sysdate + 7);

        if (fnd_log.level_statement >= fnd_log.g_current_runtime_level) then
            fnd_log.string(fnd_log.level_statement,
                       'pon.plsql.pon_sourcing_openapi_grp.pon_reneg_super_large_neg',
                       'Notifying FAILURE');
        end if;

--set the return code
       RETCODE := '2';

--commit
       COMMIT;

END;


END PON_SOURCING_OPENAPI_GRP;

/
