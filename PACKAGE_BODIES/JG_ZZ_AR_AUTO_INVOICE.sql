--------------------------------------------------------
--  DDL for Package Body JG_ZZ_AR_AUTO_INVOICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_ZZ_AR_AUTO_INVOICE" AS
/* $Header: jgzztnub.pls 120.0.12010000.9 2010/02/26 11:43:27 mbarrett ship $ */

   Function Is_context_enabled (l_country_code In Varchar2) Return Boolean IS
   l_exist Varchar2(30);
   Begin

     /* Checks whether the context is enabled for the country. It checks the contexts
        only for the JG_RA_CUSTOMER_TRX_LINES gdf. */
          SELECT 'YES' INTO l_exist
          FROM fnd_descr_flex_contexts
          WHERE application_id  = 7003
          AND descriptive_flexfield_name like 'JG_RA_CUSTOMER_TRX_LINES'
          AND descriptive_flex_context_code like '%ARXTWMAI.REGISTER_INFO%'
          AND substr(descriptive_flex_context_code, 4, 2) =  l_country_code;
          IF l_exist = 'YES' THEN
             Return TRUE;
          ELSE
             Return FALSE;
          END IF;
   Exception
      When Others Then
         Return FALSE;
   End;


   Function Is_Reg_Loc_Enabled Return Boolean IS
      l_country_code Varchar2(30);
   Begin
      fnd_profile.get('JGZZ_COUNTRY_CODE', l_country_code);
       -- Start Bug 8982308
      If (l_country_code = 'TW' or l_country_code = 'AR' or l_country_code = 'BR') THEN
       -- Start Bug 8982308
         Return TRUE;
      Elsif Is_context_enabled(l_country_code) THEN
         Return TRUE;
	  Else
         Return FALSE;
      End If;
   Exception
      When Others Then
         Return FALSE;
   End;

   Procedure Trx_Num_Upd (p_request_id In Number) Is
      Cursor C_Trx_Lines (x_request_id Number) Is
         Select l.trx_number
               ,l.customer_trx_id
           From ra_customer_trx_all l
          Where l.request_id = x_request_id
            And l.complete_flag = 'Y'
            And l.customer_trx_id Is Not Null;

      CURSOR C_AR_Batch_Details (p_batch_source_id In Number, p_org_id In Number) IS
           SELECT substr(global_attribute2,1,4),
                  substr(global_attribute3,1,1),
                  auto_trx_numbering_flag,
		  global_attribute8,
                  global_attribute9
            FROM   ra_batch_sources_all
            WHERE  batch_source_id = p_batch_source_id
              AND  org_id = p_org_id;

	-- Start Bug 8982308

	l_copy_doc_number_flag VARCHAR2(1) := NULL; -- 9090969

	    CURSOR C_BR_Batch_Details (l_batch_source_id Number,l_org_id Number) IS
	     SELECT auto_trx_numbering_flag , copy_doc_number_flag -- 9090969
	     FROM   ra_batch_sources_all
	     WHERE  batch_source_id = l_batch_source_id
	     and  org_id = l_org_id;
	 --  End Bug 8982308

      -- Start Bug 8709620
      CURSOR C_BR_Imp_Batch_Source (p_batch_source_id In Number, p_org_id In Number) IS
           SELECT rbc_1.global_attribute1 imp_batch_source_id
             FROM ra_batch_sources_all rbc_1
            WHERE rbc_1.batch_source_id = p_batch_source_id
              AND rbc_1.org_id = p_org_id;
      -- End Bug 8709620

      TYPE trx_id  is Table of ra_customer_trx_all.customer_trx_id%Type;
      TYPE trx_num is Table of ra_customer_trx_all.trx_number%Type;

      customer_trx_id trx_id;
      trx_number trx_num;

      l_batch_source_id   Number;
      l_auto_trx_num_flag Varchar2(1);
      l_copy_doc_num_flag Varchar2(1);
      l_inv_word          Varchar2(2);
      l_init_trx_num      Varchar2(8);
      l_fin_trx_num       Varchar2(8);
      l_last_trx_date     Varchar2(30);
      l_adv_days          Number;
      l_org_id            Number;
      l_seq_name          Varchar2(30);
      l_seq_number        Number;
      l_err_code          Number;
      l_trx_number        Varchar2(30);
      l_debug_loc         Varchar2(100);
      l_country_code      Varchar2(30);
      FATAL_ERROR         Exception;
      l_branch_number     Varchar2(4);
      l_document_letter   Varchar2(1);
      l_cai_num           Varchar2(15);
      l_cai_due_date      Varchar2(20);
      f_org_id            Varchar2(15);
      temp1               Number;
      temp2               Number;
      -- Start Bug 8709620
      l_imp_batch_source_id Number;
      -- End Bug 8709620

   Begin
      fnd_profile.get('JGZZ_COUNTRY_CODE', l_country_code);
      --fnd_profile.get('ORG_ID',l_org_id);
        l_org_id := MO_GLOBAL.get_current_org_id;            -- bug 8304339

      If l_country_code = 'TW' Then
         l_debug_loc := 'jg_zz_ar_auto_invoice.trx_num_upd, country code TW';
         Open C_Trx_lines(p_request_id);
         Fetch C_Trx_lines Bulk Collect Into trx_number, customer_trx_id;
         Close C_Trx_lines;

         Select To_number(cr.argument3)
         Into l_batch_source_id
         From fnd_concurrent_requests cr
         Where request_id = p_request_id;

         l_debug_loc := 'ja_tw_sh_gui_utils.get_trx_src_info';
         ja_tw_sh_gui_utils.get_trx_src_info(
            l_batch_source_id
           ,l_auto_trx_num_flag
           ,l_inv_word
           ,l_init_trx_num
           ,l_fin_trx_num
           ,l_last_trx_date
           ,l_adv_days
           ,l_org_id);

         l_seq_name := ja_tw_sh_gui_utils.get_seq_name(l_batch_source_id);

         BEGIN
           SELECT COPY_DOC_NUMBER_FLAG INTO l_copy_doc_num_flag FROM RA_BATCH_SOURCES_ALL
                WHERE BATCH_SOURCE_ID = l_batch_source_id
                      AND ORG_ID = l_org_id;
         EXCEPTION
             WHEN OTHERS THEN
              null;
         END;

         If trx_number.count > 0 and l_copy_doc_num_flag <> 'Y' Then
            For i in customer_trx_id.FIRST .. customer_trx_id.LAST Loop
               l_debug_loc := 'ja_tw_sh_gui_utils.val_trx_num';
               If ja_tw_sh_gui_utils.val_trx_num(
                     NULL
                     ,l_batch_source_id
                     ,l_fin_trx_num
                     ,'RAXTRX') = 'FATAL' Then
                  Exit;
               Else
                  ja_tw_sh_gui_utils.get_next_seq_num(
                     l_seq_name
                    ,l_seq_number
                    ,l_err_code);
                  l_trx_number := l_inv_word || LPAD(l_seq_number,8,'0');
                  trx_number(i) := l_trx_number;
               End If;
            End Loop;

            Forall j in customer_trx_id.FIRST .. customer_trx_id.LAST
               Update ra_customer_trx_all
                  Set trx_number = trx_number(j)
                Where customer_trx_id = customer_trx_id(j)
                  and request_id = p_request_id;
         End If;

      Elsif l_country_code = 'AR' Then
         --fnd_profile.get('ORG_ID',f_org_id);
         f_org_id := MO_GLOBAL.get_current_org_id;

	 l_debug_loc := 'jg_zz_ar_auto_invoice.trx_num_upd, country code AR';
         Open C_Trx_lines(p_request_id);
         Fetch C_Trx_lines Bulk Collect Into trx_number, customer_trx_id;
         Close C_Trx_lines;

         SELECT to_number(cr.argument3)
                INTO l_batch_source_id
                FROM fnd_concurrent_requests cr
                WHERE request_id = p_request_id;


         /* Code added for Transaction created by CopyTo Operation */
            --Start
           IF l_batch_source_id IS NULL THEN

             SELECT B.batch_source_id INTO temp1
                 FROM ra_customer_trx_all A, ra_customer_trx_all B
                 WHERE A.RECURRED_FROM_TRX_NUMBER = B.trx_number
                       AND A.trx_number = trx_number(1) AND B.ORG_ID = f_org_id and rownum =1;
                 BEGIN

                 SELECT GLOBAL_ATTRIBUTE1 INTO temp2
                       FROM RA_BATCH_SOURCES_ALL WHERE BATCH_SOURCE_ID = temp1;
                 EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                      null;
                 END;
                 IF temp2 IS NULL THEN
                      l_batch_source_id := temp1;
                 ELSE
                      l_batch_source_id := temp2;
                 END IF;

           END IF;
            --End

         IF l_batch_source_id IS NOT NULL THEN
	    l_debug_loc := 'Getting Transaction Source Information';

	    OPEN C_AR_Batch_Details(l_batch_source_id, l_org_id);
	    FETCH C_AR_Batch_Details INTO l_branch_number,l_document_letter,l_auto_trx_num_flag,
	                                  l_cai_num,l_cai_due_date;
	    CLOSE C_AR_Batch_Details;

	   l_seq_name := 'JL_ZZ_TRX_NUM_'
	               || to_char(l_batch_source_id)
		       || '_'
                       || f_org_id
		       || '_S';

	  END IF;

	  IF trx_number.count > 0 AND l_auto_trx_num_flag = 'Y' THEN
            FOR i IN customer_trx_id.FIRST .. customer_trx_id.LAST LOOP
               l_debug_loc := 'Getting Next Sequence number';
	       JL_ZZ_AR_LIBRARY_1_PKG.get_next_seq_number (l_seq_name, l_seq_number,1,l_err_code);
                  IF l_err_code = 0 THEN
                       l_trx_number := l_document_letter || '-' || l_branch_number || '-'
                                       || lpad(l_seq_number,8,'0');
                       trx_number(i) := l_trx_number;
		  END IF;
            END LOOP;

            FORALL j IN customer_trx_id.FIRST .. customer_trx_id.LAST
               UPDATE ra_customer_trx_all
                  SET trx_number = trx_number(j),
		      global_attribute17 = l_cai_num,
		      global_attribute18 = l_cai_due_date
                WHERE customer_trx_id = customer_trx_id(j)
                  AND request_id = p_request_id;
          END IF;

   -- Start Bug 8982308
     Elsif l_country_code = 'BR' Then

	--  fnd_profile.get('ORG_ID',f_org_id);
            f_org_id := MO_GLOBAL.get_current_org_id;
            l_debug_loc := 'jg_zz_ar_auto_invoice.trx_num_upd, country code BR';
            Open C_Trx_lines(p_request_id);
            Fetch C_Trx_lines Bulk Collect Into trx_number, customer_trx_id;
            Close C_Trx_lines;

            Select to_number(cr.argument3)
            Into l_batch_source_id
            From fnd_concurrent_requests cr
            Where request_id = p_request_id;

            /* Code added for Transaction created by CopyTo Operation */
            If l_batch_source_id IS NULL THEN

               Select B.batch_source_id
               into temp1
               From  ra_customer_trx_all A, ra_customer_trx_all B
               Where A.recurred_from_trx_number = B.trx_number
               And   A.trx_number = trx_number(1) AND B.ORG_ID = f_org_id and rownum =1;

               Begin
                  Select GLOBAL_ATTRIBUTE1
                  Into   temp2
                  From   RA_BATCH_SOURCES_ALL
                  Where  BATCH_SOURCE_ID = temp1;
               Exception
                  When NO_DATA_FOUND THEN
                     null;
               End;
               If temp2 IS NULL THEN
                  l_batch_source_id := temp1;
               Else
                  l_batch_source_id := temp2;
               End If;

            End If;

            IF l_batch_source_id IS NOT NULL THEN
               l_debug_loc := 'Getting Transaction Source Information';

               -- Start Bug 8709620
               Open C_BR_Imp_Batch_Source (l_batch_source_id, f_org_id);
               Fetch C_BR_Imp_Batch_Source Into l_imp_batch_source_id;
               Close C_BR_Imp_Batch_Source;

               If l_imp_batch_source_id is null Then
               -- End Bug 8709620
                  Open  C_BR_Batch_Details(l_batch_source_id,f_org_id);
                  Fetch C_BR_Batch_Details Into l_auto_trx_num_flag,l_copy_doc_number_flag ;
                  Close C_BR_Batch_Details;

                  l_seq_name := 'JL_BR_TRX_NUM_'
                          || to_char(l_batch_source_id)
                          || '_'
                          || f_org_id
                          || '_S';

               -- Start Bug 8709620
               Else
                  Open  C_BR_Batch_Details(l_imp_batch_source_id,f_org_id);
                  Fetch C_BR_Batch_Details Into l_auto_trx_num_flag,l_copy_doc_number_flag ;
                  Close C_BR_Batch_Details;

                  l_seq_name := 'JL_BR_TRX_NUM_'
                          || to_char(l_imp_batch_source_id)
                          || '_'
                          || f_org_id
                          || '_S';
               End if;
               -- End Bug 8709620
             End If;

            If trx_number.count > 0 AND l_auto_trx_num_flag = 'Y' AND NVL(l_copy_doc_number_flag,'N') = 'N' THEN

               FOR i IN customer_trx_id.FIRST .. customer_trx_id.LAST LOOP
                  l_debug_loc := 'Getting Next Sequence number';
                  JL_ZZ_AR_LIBRARY_1_PKG.get_next_seq_number (l_seq_name, l_seq_number,1,l_err_code);
                     IF l_err_code = 0 THEN
                          trx_number(i) := l_seq_number;
                     END IF;
               END LOOP;

               FORALL j IN customer_trx_id.FIRST .. customer_trx_id.LAST
                  UPDATE ra_customer_trx_all
                     SET trx_number = trx_number(j)
                   WHERE customer_trx_id = customer_trx_id(j)
                     AND request_id = p_request_id;
            End If;
         -- End Bug 8982308

      End If;

   Exception
      When Others Then
         arp_standard.debug('-- Found an exception at ' || l_debug_loc||'.');
         arp_standard.debug('-- ' || SQLERRM);
   End;

PROCEDURE val_trx_range (p_request_id IN Number, p_flag OUT NOCOPY Number) IS
      CURSOR C_Trx_Lines IS
         SELECT l.customer_trx_id
           FROM ra_customer_trx_all l
           WHERE l.request_id = p_request_id
            --And l.complete_flag = 'Y'
           AND l.customer_trx_id IS NOT NULL;

      CURSOR C_Reject_Entry (p_trx_id NUMBER) IS
            SELECT A.customer_trx_line_id line_id, B.cust_trx_line_gl_dist_id dist_id
	      FROM ra_customer_trx_lines_all A ,ra_cust_trx_line_gl_dist_all B
              WHERE A.customer_trx_id = p_trx_id AND
                    A.customer_trx_line_id = B.customer_trx_line_id
		    AND ROWNUM = 1;

      TYPE trx_id  IS TABLE OF ra_customer_trx_all.customer_trx_id%Type;

      customer_trx_id trx_id;

      l_batch_source_id   Number;
      l_auto_trx_num_flag Varchar2(1);
      l_copy_doc_num_flag Varchar2(1);
      l_inv_word          Varchar2(2);
      l_init_trx_num      Varchar2(8);
      l_fin_trx_num       Varchar2(8);
      l_last_trx_date     Varchar2(30);
      l_adv_days          Number;
      l_seq_name          Varchar2(30);
      l_seq_number        Number;
      l_err_code          Number;
      l_trx_number        Varchar2(30);
      l_debug_loc         Varchar2(100);
      l_country_code      Varchar2(30);
      l_org_id            Varchar2(15);
      l_count             Number DEFAULT 0;
      l_line_id           Number;
      l_dist_id           Number;
      l_last_trx_num      Varchar2(8);
      l_message_text      Varchar2(240);
      l_batch_source_name Varchar2(50);
   BEGIN
      fnd_profile.get('JGZZ_COUNTRY_CODE', l_country_code);
      --fnd_profile.get('ORG_ID',l_org_id);
      l_org_id := MO_GLOBAL.get_current_org_id;

      BEGIN
          SELECT TO_NUMBER(cr.argument3) INTO l_batch_source_id
             FROM fnd_concurrent_requests cr
                  WHERE request_id = p_request_id;

         EXCEPTION
            WHEN OTHERS THEN
             null;
      END;

      BEGIN
           SELECT COPY_DOC_NUMBER_FLAG INTO l_copy_doc_num_flag FROM RA_BATCH_SOURCES_ALL
                WHERE BATCH_SOURCE_ID = l_batch_source_id
                      AND ORG_ID = l_org_id;
         EXCEPTION
             WHEN OTHERS THEN
              null;
      END;


      IF l_country_code = 'TW' and l_copy_doc_num_flag <> 'Y' THEN
         p_flag := 0;
         l_debug_loc := 'Country code TW';

	 OPEN C_Trx_lines;
         FETCH C_Trx_lines BULK COLLECT INTO customer_trx_id;
         CLOSE C_Trx_lines;


	 SELECT name INTO l_batch_source_name
	     FROM RA_BATCH_SOURCES_ALL
	     WHERE batch_source_id = l_batch_source_id;

         l_debug_loc := 'Getting Transaction Source details';
         ja_tw_sh_gui_utils.get_trx_src_info(
            l_batch_source_id
           ,l_auto_trx_num_flag
           ,l_inv_word
           ,l_init_trx_num
           ,l_fin_trx_num
           ,l_last_trx_date
           ,l_adv_days
           ,l_org_id);

         l_seq_name := ja_tw_sh_gui_utils.get_seq_name(l_batch_source_id);
         l_last_trx_num := ja_tw_sh_gui_utils.get_last_trx_num(l_seq_name);

	 --fnd_message.set_name( 'JA','JA_TW_GUI_NUM_OVERLIMIT_CHQ');
	 fnd_message.set_name( 'JA','JA_TW_AR_GUI_NUM_OUT_OF_RANGE');
         fnd_message.set_token('BATCH_SOURCE_NAME',l_batch_source_name);
         l_message_text := fnd_message.GET;

	 IF customer_trx_id.count > 0 THEN
	    l_debug_loc := 'Checking for the Sequence maximum limit';
            FOR i IN customer_trx_id.FIRST .. customer_trx_id.LAST LOOP
                  IF to_number(l_last_trx_num) < to_number(l_fin_trx_num) THEN
		     null;
		  ELSE
		     l_count := i;
		     EXIT;
		  END IF;
		  l_last_trx_num := to_number(l_last_trx_num + 1);
	    END LOOP;
	 END IF;

	 IF l_count > 0 THEN
	     l_debug_loc := 'Inserting into Interface Error over limit transactions';
             FOR i IN l_count .. customer_trx_id.LAST LOOP
		  FOR C_Reject_Entry_Rec IN C_Reject_Entry(customer_trx_id(i)) LOOP
		      INSERT INTO ra_interface_errors(
                             interface_line_id,
                             --interface_distribution_id, --bug 8306469
                             message_text,
                             org_id)
                         VALUES(
                             C_Reject_Entry_Rec.line_id,
                             --C_Reject_Entry_Rec.dist_id,
                             l_message_text,
                             l_org_id);
		      p_flag := p_flag + 1;
		  END LOOP;
             END LOOP;

         END IF;

      END IF;

      /* To nullify the global attribute columns. This is to avoid populating
         Global columns while Copying transaction by "CopyTo" function		  */
      --IF Is_context_enabled(l_country_code) THEN
      --    arp_standard.debug('-- Start JE_GLOBAL_PKG.nullify_globalcolumns ');
      --     JE_COMMON_PKG.nullify_globalcolumns(p_request_id);
      --    arp_standard.debug('-- End JE_GLOBAL_PKG.nullify_globalcolumns ');
      --END IF;

   EXCEPTION
      WHEN OTHERS THEN
         p_flag := 0;
         arp_standard.debug('-- Found an exception at :' || l_debug_loc||'.');
         arp_standard.debug('-- ' || SQLERRM);
   END;

End JG_ZZ_AR_AUTO_INVOICE;


/
