--------------------------------------------------------
--  DDL for Package Body JAI_ENCUM_PRC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_ENCUM_PRC" AS
/* $Header: jai_encum_prc.plb 120.2.12010000.2 2009/03/19 07:30:56 mbremkum ship $ */
  PROCEDURE fetch_nr_tax( p_dist_type_tbl IN po_tbl_varchar30,
                          p_dist_id_tbl   IN po_tbl_number,
                          p_action        IN VARCHAR2,
                          p_doc_type      IN VARCHAR2,
                          p_nr_tax_tbl    OUT NOCOPY po_tbl_number,
                          p_return_status OUT NOCOPY VARCHAR2
                         )
  IS
  ln_nr_tax                NUMBER;--This will have the sum of nr tax fetched so far for the shipment of current distribution record
  ln_nr_tot_tax            NUMBER;--This will have the nr tax of the current shipment
  ln_line_location_id      NUMBER;--This will have the line_location_id of the current distribution record
  ln_next_line_location_id NUMBER;--This will have the line_location_id of the next distribution record
  ln_po_line_id            NUMBER;--This will have the PO line_id
  ln_req_line_id           NUMBER;--This will have the requistion_line_id of the current distribution
  ln_next_req_line_id      NUMBER;--This will have the requistion_line_id of the next distribution
  lv_last_record           VARCHAR2(10);--This will indicate if this is the last distribution in the current shipment
  ln_distribution_cnt      NUMBER;--This will have the count of distributions processed so far in the current shipment
  lv_doc_type              VARCHAR2(30);--This will have the document type
  lv_encum_exists          VARCHAR2(30);--This indicates if the IL encumbrance table already has the record.
  ln_doc_curr_tax_amt      NUMBER;--This has the non-recoverable tax of the distribution in document currency
  ln_conv_rate             NUMBER;--This has the currency conversion rate
  ln_doc_header_id         NUMBER;--Document header id
  ln_doc_line_id           NUMBER;--Document Line Id
  lv_doc_currency_code     VARCHAR2(30);--Document Currency code
  ln_func_curr_tax_amt     NUMBER;
  ln_il_encum_used         NUMBER;

  -- Added by Jia Li for Tax inclusive Computations on 2007/12/01, Begin
  -- TD13-Changed Support for encumbrance accounting
  ---------------------------------------------------------------------------------------
  ln_rec_tot_inclu_tax      NUMBER; -- This will have the inclusive recoverable amount
  ln_rec_tax_inclu          NUMBER; -- This will have the round inclusive recoverable amount of current distribution record
  ---------------------------------------------------------------------------------------
  -- Added by Jia Li for Tax inclusive Computations on 2007/12/01, End

  /*The cursor is used to see if a record already exists for the distribution in the IL table*/
  CURSOR cur_encum_exists( cp_document_type VARCHAR2, cp_distribution_id NUMBER )
  IS
  SELECT 'Encumbrance Exists'
    FROM jai_encum_tax_details
   WHERE document_type   = cp_document_type
     AND distribution_id = cp_distribution_id;

  /*Cursor used to fetch the line_location_id using distribution_id*/
  CURSOR cur_line_location_id(cp_distribution_id NUMBER)
  IS
  SELECT line_location_id
    FROM po_encumbrance_gt
   WHERE distribution_id = cp_distribution_id;

  /*Cursor to fetch the po_line_id using line_location_id*/
  CURSOR cur_po_line_id(cp_line_location_id NUMBER)
  IS
  SELECT po_line_id
    FROM po_line_locations_all
   WHERE line_location_id = cp_line_location_id;

  /*Cursor to fetch currency, conversion rate and header id of the PO*/
  CURSOR cur_po_hdr_dtls(cp_po_line_id NUMBER)
  IS
  SELECT poh.currency_code, poh.rate,poh.po_header_id
    FROM po_headers_all poh, po_lines_all pol
   WHERE poh.po_header_id = pol.po_header_id
     AND pol.po_line_id   = cp_po_line_id;

  po_hdr_dtls_rec     cur_po_hdr_dtls%ROWTYPE;

  /*
  Bug 7758094 - Modified cursor cur_req_line_id to fetch requisition line id from po_encumbrance_gt
  Data is not present in po_req_distributions_all as the Requisition is yet to be saved
  Hence fetched from the Global Temporary table
  */
  CURSOR cur_req_line_id(cp_distribution_id NUMBER)
  IS
  SELECT distinct(line_id)
  FROM po_encumbrance_gt
  WHERE distribution_id = cp_distribution_id;

  /*Cursor to fetch currency, conversion rate and header id of the requistion*/
  CURSOR cur_req_line_dtls(cp_req_line_id NUMBER)
  IS
  SELECT currency_code, rate,requisition_header_id
    FROM po_requisition_lines_all
   WHERE requisition_line_id = cp_req_line_id;

  req_line_dtls_rec   cur_req_line_dtls%ROWTYPE;

  CURSOR cur_il_encumbrance(cp_document_type VARCHAR2, cp_distribution_id NUMBER )
  IS
  SELECT *
    FROM jai_encum_tax_details
   WHERE document_type   = cp_document_type
     AND distribution_id = cp_distribution_id;

  il_encumbrance_rec cur_il_encumbrance%ROWTYPE;

  BEGIN
    p_nr_tax_tbl        := po_tbl_number(0);
    p_return_status     := 'E';
    lv_last_record      := 'FALSE';
    ln_distribution_cnt := 1;

    FOR i in 1..p_dist_type_tbl.COUNT LOOP

      ln_il_encum_used := 0;
      il_encumbrance_rec := NULL;

			IF p_dist_type_tbl(i) IN ( 'STANDARD','PLANNED', 'SCHEDULED','BLANKET', 'AGREEMENT') THEN

			  lv_doc_type := 'PO';

			  IF p_action <> PO_CONSTANTS_SV.RESERVE THEN

			    IF ln_line_location_id IS NULL THEN

						/*These values might be used to populate the IL table*/

						/*Fetch the line_location_id of the distribution*/
						OPEN cur_line_location_id(p_dist_id_tbl(i));
						FETCH cur_line_location_id INTO ln_line_location_id;
						CLOSE cur_line_location_id;

						/*Fetch the po_line_id of the shipment*/
						OPEN cur_po_line_id(ln_line_location_id);
						FETCH cur_po_line_id INTO ln_po_line_id;
						CLOSE cur_po_line_id;

					END IF;

			    ln_il_encum_used := 1;

			    OPEN  cur_il_encumbrance( lv_doc_type,p_dist_id_tbl(i));
			    FETCH cur_il_encumbrance INTO il_encumbrance_rec;
			    CLOSE cur_il_encumbrance;

			    IF il_encumbrance_rec.distribution_id IS NULL THEN
			      /*This means the document was RESERVED before the patch was applied*/
			      p_nr_tax_tbl(i) := 0;
            ln_rec_tax_inclu := 0;  -- Added by Jia Li for Tax inclusive Computations on 2007/12/01

			    ELSE
			      /*This means the document was RESERVED after the patch was applied*/
			      p_nr_tax_tbl(i) := il_encumbrance_rec.func_nr_tax_amount;

			    END IF;

        ELSE

				  IF ln_line_location_id IS NULL THEN/*If this is the first distribution in the shipment*/

							/*Fetch the line_location_id of the distribution*/
							OPEN cur_line_location_id(p_dist_id_tbl(i));
							FETCH cur_line_location_id INTO ln_line_location_id;
							CLOSE cur_line_location_id;

							/*Fetch the po_line_id of the shipment*/
							OPEN cur_po_line_id(ln_line_location_id);
							FETCH cur_po_line_id INTO ln_po_line_id;
							CLOSE cur_po_line_id;

							/*Fetch the non-recoverable tax of the shipment*/
							/*This should be in document currency*/
							SELECT nvl(sum(po_tax.tax_amount * DECODE(tax_code.modifiable_flag,nvl(po_tax.modvat_flag,'Y')
																																						,((100-nvl(tax_code.mod_cr_percentage,0))/100)
																																						,1 )
                                           * DECODE(po_tax.currency,'INR',1/nvl(poh.rate,1),1) ),0)
								INTO ln_nr_tot_tax
								FROM JAI_PO_TAXES PO_TAX,
										 JAI_CMN_TAXES_ALL              TAX_CODE,
										 PO_HEADERS_ALL               POH,
										 PO_LINE_LOCATIONS_ALL        POLL
							 WHERE po_tax.line_location_id   = poll.line_location_id
								 AND poll.po_header_id         = poh.po_header_id
								 AND po_tax.tax_id             = tax_code.tax_id
								 AND poll.line_location_id     = ln_line_location_id
                 AND NVL(tax_code.inclusive_tax_flag, 'N') = 'N'; -- Added by Jia Li for Tax inclusive Computations on 2007/12/01

              -- Added by Jia Li for Tax inclusive Computations on 2007/12/01, Begin
              -- TD13-Changed Support for encumbrance accounting
              -- Get inclusive recoverable tax amt
              ---------------------------------------------------------------------------------------
							SELECT NVL(SUM(po_tax.tax_amount * DECODE( tax_code.modifiable_flag
                                                       , NVL(po_tax.modvat_flag,'Y'), 1
																											 , (NVL(tax_code.mod_cr_percentage,0)/100))
                                               * DECODE( po_tax.currency
                                                       , 'INR', 1/NVL(poh.rate,1)
                                                       , 1)
                            ), 0)
								INTO
                  ln_rec_tot_inclu_tax
								FROM
                  jai_po_taxes          po_tax
                , jai_cmn_taxes_all     tax_code
                , po_headers_all        poh
                , po_line_locations_all poll
							 WHERE po_tax.line_location_id = poll.line_location_id
								 AND poll.po_header_id = poh.po_header_id
								 AND po_tax.tax_id = tax_code.tax_id
								 AND poll.line_location_id = ln_line_location_id
                 AND NVL(tax_code.inclusive_tax_flag, 'N') = 'Y';
              ---------------------------------------------------------------------------------------
              -- Added by Jia Li for Tax inclusive Computations on 2007/12/01, End

						END IF;

						IF i < p_dist_type_tbl.COUNT THEN /*If it is not the last record*/

							IF p_dist_type_tbl(i) <> p_dist_type_tbl(i + 1) THEN

							/*If the next distribution type is different then this is the last record in the shipment*/

								lv_last_record := 'TRUE';

							ELSE

								/*fetch the line_location_id of the next distribution*/
								OPEN cur_line_location_id(p_dist_id_tbl( i + 1));
								FETCH cur_line_location_id INTO ln_next_line_location_id;
								CLOSE cur_line_location_id;

								IF ln_next_line_location_id <> ln_line_location_id THEN /*If this is the last distribution in the shipment*/

									lv_last_record := 'TRUE';

								ELSE

									ln_distribution_cnt := ln_distribution_cnt + 1; /*Increment the count of the distributions*/

								END IF;

							END IF;

						ELSE/*if it is the last record*/

							lv_last_record := 'TRUE';

						END IF;

						/*Fetch the apportioned non-recoverable tax for the current distribution.Round it to 2 decimals*/
						/*This should be in document currency*/
						SELECT nvl(round(sum(po_tax.tax_amount * DECODE(tax_code.modifiable_flag,nvl(po_tax.modvat_flag,'Y')
																																					,((100-nvl(tax_code.mod_cr_percentage,0))/100)
																																					,1 )
																				 * DECODE(po_tax.currency,'INR',1/nvl(poh.rate,1),1)
																				 * ( dist.quantity_ordered / poll.quantity )),2),0)
							INTO p_nr_tax_tbl(i)
							FROM JAI_PO_TAXES PO_TAX,
									 JAI_CMN_TAXES_ALL              TAX_CODE,
									 PO_HEADERS_ALL               POH,
									 PO_DISTRIBUTIONS_ALL         DIST,
									 PO_LINE_LOCATIONS_ALL        POLL
						 WHERE po_tax.line_location_id   = dist.line_location_id
							 AND dist.line_location_id     = poll.line_location_id
							 AND dist.po_header_id         = poh.po_header_id
							 AND po_tax.tax_id             = tax_code.tax_id
							 AND dist.po_distribution_id   = p_dist_id_tbl(i)
               AND NVL(tax_code.inclusive_tax_flag, 'N') = 'N'; -- Added by Jia Li for Tax inclusive Computations on 2007/12/01

            -- Added by Jia Li for Tax inclusive Computations on 2007/12/01, Begin
            -- TD13-Changed Support for encumbrance accounting
            ---------------------------------------------------------------------------------------
						SELECT NVL(ROUND(SUM(po_tax.tax_amount * DECODE( tax_code.modifiable_flag
                                                           , NVL(po_tax.modvat_flag,'Y'), 1
																											     , (NVL(tax_code.mod_cr_percentage,0)/100))
																				           * DECODE( po_tax.currency
                                                           , 'INR',1/NVL(poh.rate,1)
                                                           , 1)
																				           * (dist.quantity_ordered/poll.quantity)
                                 ), 2), 0)
					  INTO
              ln_rec_tax_inclu
						FROM
              jai_po_taxes          po_tax
            , jai_cmn_taxes_all     tax_code
            , po_headers_all        poh
            , po_distributions_all  dist
            , po_line_locations_all poll
						WHERE po_tax.line_location_id = dist.line_location_id
						  AND dist.line_location_id = poll.line_location_id
							AND dist.po_header_id = poh.po_header_id
							AND po_tax.tax_id = tax_code.tax_id
							AND dist.po_distribution_id = p_dist_id_tbl(i)
              AND NVL(tax_code.inclusive_tax_flag, 'N') = 'Y';

            p_nr_tax_tbl(i) := p_nr_tax_tbl(i) - ln_rec_tax_inclu;
            ---------------------------------------------------------------------------------------
            -- Added by Jia Li for Tax inclusive Computations on 2007/12/01, End

        END IF;

			ELSIF p_dist_type_tbl(i) IN ('REQUISITION') THEN

			  lv_doc_type := 'REQ';

			  IF ((p_doc_type = PO_CONSTANTS_SV.PO)
			       OR (p_action <> PO_CONSTANTS_SV.RESERVE AND p_doc_type = PO_CONSTANTS_SV.REQUISITION )) THEN

			    ln_il_encum_used := 1;

					IF ln_req_line_id IS NULL THEN /*If this is the first distribution in the requisition line*/

						/*fetch the requisition_line_id of the current distribution*/

						OPEN  cur_req_line_id(p_dist_id_tbl(i));
						FETCH cur_req_line_id INTO ln_req_line_id;
          	CLOSE cur_req_line_id;

          END IF;

			    OPEN  cur_il_encumbrance( lv_doc_type,p_dist_id_tbl(i));
			    FETCH cur_il_encumbrance INTO il_encumbrance_rec;
			    CLOSE cur_il_encumbrance;

			    IF il_encumbrance_rec.distribution_id IS NULL THEN
			      /*This means the document was RESERVED before the patch was applied*/
			      p_nr_tax_tbl(i) := 0;
            ln_rec_tax_inclu := 0;  -- Added by Jia Li for Tax inclusive Computations on 2007/12/01

			    ELSE
			      /*This means the document was RESERVED after the patch was applied*/
			      p_nr_tax_tbl(i) := il_encumbrance_rec.func_nr_tax_amount;

			    END IF;

			  ELSE
					IF ln_req_line_id IS NULL THEN /*If this is the first distribution in the requisition line*/

						/*fetch the requisition_line_id of the current distribution*/

						OPEN  cur_req_line_id(p_dist_id_tbl(i));
						FETCH cur_req_line_id INTO ln_req_line_id;
						CLOSE cur_req_line_id;

					/*Fetch the non-recoverable tax of the requistion line*/
					/*This should be in functional currency*/
					SELECT nvl(sum(req_tax.tax_amount * DECODE(tax_code.modifiable_flag,nvl(req_tax.modvat_flag,'Y')
																																				 ,((100-nvl(tax_code.mod_cr_percentage,0))/100)
																																				 ,1 )
													 * DECODE(req_tax.currency,'INR',1,lines.rate) ),0)
						INTO ln_nr_tot_tax
						FROM JAI_PO_REQ_LINE_TAXES     Req_TAX,
								 JAI_CMN_TAXES_ALL          TAX_CODE,
								 PO_REQUISITION_LINES_ALL lines
					 WHERE req_tax.requisition_line_id   = lines.requisition_line_id
						 AND req_tax.requisition_header_id = lines.requisition_header_id
						 AND req_tax.tax_id                = tax_code.tax_id
						 AND lines.requisition_line_id     = ln_req_line_id
             AND NVL(tax_code.inclusive_tax_flag, 'N') = 'N';  -- Added by Jia Li for Tax inclusive Computations on 2007/12/01

          -- Added by Jia Li for Tax inclusive Computations on 2007/12/01, Begin
          -- TD13-Changed Support for encumbrance accounting
          -- Get inclusive recoverable tax amt
          ---------------------------------------------------------------------------------------
					SELECT NVL(SUM(req_tax.tax_amount * DECODE( tax_code.modifiable_flag
                                                    , NVL(req_tax.modvat_flag,'Y'), 1
                                                    , (NVL(tax_code.mod_cr_percentage,0)/100))
													                  * DECODE( req_tax.currency
                                                    , 'INR', 1
                                                    , lines.rate)
                         ), 0)
				  INTO
            ln_rec_tot_inclu_tax
					FROM
            jai_po_req_line_taxes    req_tax
          , jai_cmn_taxes_all        tax_code
          , po_requisition_lines_all lines
					WHERE req_tax.requisition_line_id = lines.requisition_line_id
						AND req_tax.requisition_header_id = lines.requisition_header_id
						AND req_tax.tax_id = tax_code.tax_id
						AND lines.requisition_line_id = ln_req_line_id
            AND NVL(tax_code.inclusive_tax_flag, 'N') = 'Y';
          ---------------------------------------------------------------------------------------
          -- Added by Jia Li for Tax inclusive Computations on 2007/12/01, End

					END IF;

					IF i < p_dist_type_tbl.COUNT THEN /*If it is not the last record*/


						IF p_dist_type_tbl(i) <> p_dist_type_tbl(i + 1) THEN
						/*If the next distribution type is different then this is the last record in the shipment*/

							lv_last_record := 'TRUE';

						ELSE
							/*Fetch the requistion line id of the next distribution*/
							OPEN  cur_req_line_id(p_dist_id_tbl(i + 1));
							FETCH cur_req_line_id INTO ln_next_req_line_id;
							CLOSE cur_req_line_id;

							IF ln_next_req_line_id <> ln_req_line_id THEN /*If this is the last distribution in the requisition*/

								lv_last_record := 'TRUE';

							ELSE

								ln_distribution_cnt := ln_distribution_cnt + 1; /*Increment the distribution count*/

							END IF;

						END IF;

					ELSE/*if it is the last record*/

						lv_last_record := 'TRUE';

					END IF;

					/*Fetch the apportioned tax amount for the current distribution.Round it to 2 decimals*/
					/*This should be in functional currency*/
					SELECT nvl(round(sum(req_tax.tax_amount * DECODE(tax_code.modifiable_flag,nvl(req_tax.modvat_flag,'Y')
																																				 ,((100-nvl(tax_code.mod_cr_percentage,0))/100)
																																				 ,1 )
													 * DECODE(req_tax.currency,'INR',1,lines.rate) * (dist.req_line_quantity/lines.quantity)),2),0)
						INTO p_nr_tax_tbl(i)
						FROM JAI_PO_REQ_LINE_TAXES     Req_TAX,
								 JAI_CMN_TAXES_ALL          TAX_CODE,
								 PO_REQ_DISTRIBUTIONS_ALL dist,
								 PO_REQUISITION_LINES_ALL lines
					 WHERE req_tax.requisition_line_id   = lines.requisition_line_id
						 AND req_tax.requisition_header_id = lines.requisition_header_id
						 AND lines.requisition_line_id     = dist.requisition_line_id
						 AND req_tax.tax_id                = tax_code.tax_id
						 AND dist.distribution_id          = p_dist_id_tbl(i)
             AND NVL(tax_code.inclusive_tax_flag, 'N') = 'N';  -- Added by Jia Li for Tax inclusive Computations on 2007/12/01

          -- Added by Jia Li for Tax inclusive Computations on 2007/12/01, Begin
          -- TD13-Changed Support for encumbrance accounting
          ---------------------------------------------------------------------------------------
					SELECT NVL(ROUND(SUM(req_tax.tax_amount * DECODE( tax_code.modifiable_flag
                                                          , NVL(req_tax.modvat_flag,'Y'), 1
																													, (NVL(tax_code.mod_cr_percentage,0)/100))
													                        * DECODE( req_tax.currency
                                                          , 'INR', 1
                                                          , lines.rate)
                                                  * (dist.req_line_quantity/lines.quantity)
                               ), 2), 0)
					INTO
            ln_rec_tax_inclu
					FROM
            jai_po_req_line_taxes    req_tax
          , jai_cmn_taxes_all        tax_code
          , po_req_distributions_all dist
          , po_requisition_lines_all lines
					WHERE req_tax.requisition_line_id = lines.requisition_line_id
						AND req_tax.requisition_header_id = lines.requisition_header_id
						AND lines.requisition_line_id = dist.requisition_line_id
						AND req_tax.tax_id = tax_code.tax_id
						AND dist.distribution_id = p_dist_id_tbl(i)
            AND nvl(tax_code.inclusive_tax_flag, 'N') = 'Y';

            p_nr_tax_tbl(i) := p_nr_tax_tbl(i) - ln_rec_tax_inclu;
          ---------------------------------------------------------------------------------------
          -- Added by Jia Li for Tax inclusive Computations on 2007/12/01, End

				END IF;

			END IF;

			IF ln_il_encum_used = 0 THEN

				IF lv_last_record = 'FALSE' THEN /*if this is not the last distribution */

					ln_nr_tax := nvl(ln_nr_tax,0) + p_nr_tax_tbl(i);	/*Add the current distribution's tax to ln_nr_tax*/

				ELSIF ln_distribution_cnt > 1 THEN /*If this is the last distribution and there are more than one distributions*/

					/*Calculate the tax amount by subtracting ln_nr_tax from ln_nr_tot_tax. This will eliminate any rounding differences*/
          -- Modified by Jia Li for Tax inclusive Computations on 2007/12/01, Begin
          --------------------------------------------------------------------------
					--p_nr_tax_tbl(i)          := nvl(ln_nr_tot_tax,0) - nvl(ln_nr_tax,0);
          p_nr_tax_tbl(i) := nvl(ln_nr_tot_tax, 0) - NVL(ln_rec_tot_inclu_tax, 0) - nvl(ln_nr_tax, 0);
          ---------------------------------------------------------------------------
          -- Modified by Jia Li for Tax inclusive Computations on 2007/12/01, End

				END IF;

				/*If the distribution_cnt is 1 and lv_last_record is TRUE then p_nr_tax_tbl(i) would be the one fetched from query only.*/
		  END IF;

			/*If the encumbrance action is any of the following then populate IL table*/
			IF p_action IN ( PO_CONSTANTS_SV.RESERVE, PO_CONSTANTS_SV.CANCEL, 'FINAL CLOSE' ) THEN

			  IF lv_doc_type = 'PO' THEN
			    /*fetch the document details*/
			    OPEN  cur_po_hdr_dtls(ln_po_line_id);
			    FETCH cur_po_hdr_dtls INTO po_hdr_dtls_rec;
			    CLOSE cur_po_hdr_dtls;

			    ln_doc_header_id     := po_hdr_dtls_rec.po_header_id;
			    ln_doc_line_id       := ln_po_line_id;
			    lv_doc_currency_code := po_hdr_dtls_rec.currency_code;

			    IF lv_doc_currency_code = 'INR' THEN

			      ln_conv_rate := 1;

			    ELSE

			      ln_conv_rate := po_hdr_dtls_rec.rate;

			    END IF;

			    ln_doc_curr_tax_amt  := p_nr_tax_tbl(i) ;
			    ln_func_curr_tax_amt := p_nr_tax_tbl(i) * ln_conv_rate;

			  ELSIF lv_doc_type = 'REQ' THEN
			    /*fetch the line details*/
			    OPEN  cur_req_line_dtls(ln_req_line_id);
			    FETCH cur_req_line_dtls INTO req_line_dtls_rec;
			    CLOSE cur_req_line_dtls;

			    ln_doc_header_id     := req_line_dtls_rec.requisition_header_id;
			    ln_doc_line_id       := ln_req_line_id;
			    lv_doc_currency_code := nvl(req_line_dtls_rec.currency_code,'INR');

			    IF lv_doc_currency_code = 'INR' THEN

			      ln_conv_rate := 1;

			    ELSE

			      ln_conv_rate := req_line_dtls_rec.rate;

			    END IF;

			    /*Covert the tax amount into document currency using conversion rate*/
			    ln_doc_curr_tax_amt  := p_nr_tax_tbl(i) / ln_conv_rate;
			    ln_func_curr_tax_amt := p_nr_tax_tbl(i);

			  END IF;


			  lv_encum_exists := NULL;
			  /*Check if the IL encumbrance table has the record*/
			  OPEN  cur_encum_exists(lv_doc_type,p_dist_id_tbl(i));
			  FETCH cur_encum_exists INTO lv_encum_exists;
			  CLOSE cur_encum_exists;

			  IF lv_encum_exists = 'Encumbrance Exists' THEN

			    /*If record exists then update it with the tax amount and status*/

			    UPDATE jai_encum_tax_details
			       SET nr_tax_amount      = ln_doc_curr_tax_amt,
			           func_nr_tax_amount = p_nr_tax_tbl(i),
			           status             = DECODE(p_action,PO_CONSTANTS_SV.RESERVE,'RESERVED',
			                                                PO_CONSTANTS_SV.CANCEL ,'CANCELLED',
			                                                'FINAL CLOSE'          ,'CLOSED'),
			           last_update_date   = sysdate,
			           last_updated_by    = fnd_global.user_id,
			           last_update_login  = fnd_global.login_id
			     WHERE document_type      = lv_doc_type
			       AND distribution_id    = p_dist_id_tbl(i);

			  ELSE

			    /*If the record does not exist create a new record*/

			    INSERT INTO
			      jai_encum_tax_details( DOCUMENT_TYPE          ,
																	 DOC_HEADER_ID          ,
																	 DOC_LINE_ID            ,
																	 LINE_LOCATION_ID       ,
																	 DISTRIBUTION_ID        ,
																	 CURRENCY_CODE          ,
																	 NR_TAX_AMOUNT          ,
																	 FUNC_NR_TAX_AMOUNT     ,
																	 STATUS                 ,
																	 CREATION_DATE          ,
																	 CREATED_BY             ,
																	 LAST_UPDATE_DATE       ,
																	 LAST_UPDATED_BY        ,
																	 LAST_UPDATE_LOGIN      ,
																	 OBJECT_VERSION_NUMBER
																	)
					                VALUES( lv_doc_type             ,
					                        ln_doc_header_id        ,
					                        ln_doc_line_id          ,
					                        ln_line_location_id			,
					                        p_dist_id_tbl(i)        ,
					                        lv_doc_currency_code    ,
					                        ln_doc_curr_tax_amt     ,
					                        ln_func_curr_tax_amt    ,
					                        DECODE(p_action,PO_CONSTANTS_SV.RESERVE,'RESERVED' ,
																				          PO_CONSTANTS_SV.CANCEL ,'CANCELLED',
			                                            'FINAL CLOSE'          ,'CLOSED')  ,
			                            sysdate                 ,
			                            fnd_global.user_id      ,
			                            sysdate                 ,
			                            fnd_global.user_id      ,
			                            fnd_global.login_id     ,
			                            NULL
			                           );

			  END IF;


			END IF;

			IF p_nr_tax_tbl.COUNT < p_dist_id_tbl.COUNT THEN

			  p_nr_tax_tbl.extend;

			END IF;

			IF lv_last_record = 'TRUE' THEN

			  /*Assign the initial values to the variables used*/
			  ln_line_location_id      := NULL;
			  ln_next_line_location_id := NULL;
			  ln_nr_tax                := 0;
			  ln_nr_tot_tax            := 0;
        ln_rec_tot_inclu_tax      := 0;  -- Added by Jia Li for Tax inclusive Computations on 2007/12/01, TD13
			  lv_last_record           := 'FALSE';
			  ln_distribution_cnt      := 1;

      END IF;

    END LOOP;

    p_return_status := 'S';

  EXCEPTION

    WHEN OTHERS THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END fetch_nr_tax;

	PROCEDURE fetch_encum_rev_amt( p_acct_txn_id	  IN 	NUMBER,
															 p_source_doc_type  IN  VARCHAR2,
															 p_source_doc_id    IN  NUMBER,
															 p_acct_source      IN  VARCHAR2,
															 p_nr_tax_amount    OUT NOCOPY NUMBER,
															 p_rec_tax_amount   OUT NOCOPY NUMBER,
															 p_err_num	        OUT NOCOPY NUMBER,
															 p_err_code	        OUT NOCOPY VARCHAR2,
															 p_err_msg	        OUT NOCOPY VARCHAR2
															)
  IS

  /*Cursor fetches the non-recoverable tax amount of PO stored in IL encumbrance table*/
  CURSOR cur_po_nr_tax_amt
  IS
  SELECT nr_tax_amount
    FROM jai_encum_tax_details
   WHERE document_type   = p_source_doc_type
     AND distribution_id = p_source_doc_id;

  /*Cursor fetches the non-recoverable tax amount of REQUISITION stored in IL encumbrance table*/
  CURSOR cur_req_nr_tax_amt
  IS
  SELECT nvl(sum(nr_tax_amount),0)
    FROM jai_encum_tax_details
   WHERE document_type   = p_source_doc_type
     AND doc_line_id     = p_source_doc_id;


  BEGIN

    p_err_num  := '';
		p_err_code := '';
    p_err_msg  := '';
    p_rec_tax_amount := 0; /*This will be zero as it is not used anywhere in encumbrance*/

    IF p_source_doc_type = 'PO' THEN

			/*Fetch the non-recoverable tax amount of the PO distribution*/
			OPEN cur_po_nr_tax_amt;
			FETCH cur_po_nr_tax_amt INTO p_nr_tax_amount;
			CLOSE cur_po_nr_tax_amt;

		ELSIF p_source_doc_type = 'REQ' THEN

			/*Fetch the non-recoverable tax amount of the Requisition line*/
			OPEN cur_req_nr_tax_amt;
			FETCH cur_req_nr_tax_amt INTO p_nr_tax_amount;
			CLOSE cur_req_nr_tax_amt;

		END IF;

		INSERT INTO jai_encum_tax_rvrsl_dtls( ACCT_TXN_ID            ,
																					SOURCE_DOC_ID          ,
																					ACCT_SOURCE            ,
																					SOURCE_DOC_TYPE        ,
																					DOC_NR_TAX             ,
																					DOC_REC_TAX            ,
																					LAST_UPDATE_DATE       ,
																					LAST_UPDATED_BY        ,
																					CREATION_DATE          ,
																					CREATED_BY             ,
																					LAST_UPDATE_LOGIN      ,
																					OBJECT_VERSION_NUMBER  )
																 VALUES ( p_acct_txn_id          ,
																          p_source_doc_id        ,
																          p_acct_source          ,
																          p_source_doc_type      ,
																          p_nr_tax_amount        ,
																          0                      ,
																          SYSDATE                ,
																          fnd_global.user_id     ,
																          SYSDATE                ,
																          fnd_global.user_id     ,
																          fnd_global.login_id    ,
																          NULL
																         );

  EXCEPTION

    WHEN OTHERS THEN

      p_err_num := SQLCODE;
      p_err_msg := 'jai_encum_prc.fetch_encum_rev_amt:' || substrb(SQLERRM,1,150);

  END fetch_encum_rev_amt;

END jai_encum_prc;

/
