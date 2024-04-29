--------------------------------------------------------
--  DDL for Package Body IGC_CC_INT_CC_REL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_CC_INT_CC_REL_PUB" AS
/*$Header: IGCCICRB.pls 120.6.12000000.4 2007/10/18 09:04:16 vumaasha ship $*/
   g_pkg_name   CONSTANT VARCHAR2 (30)    := 'IGC_CC_INT_CC_REL_PUB';
   g_debug_msg           VARCHAR2 (10000) := NULL;
--  g_debug_mode VARCHAR2(1) := NVL(FND_PROFILE.VALUE('IGC_DEBUG_ENABLED'),'N');
   g_debug_mode          VARCHAR2 (1)
                            := NVL (fnd_profile.VALUE ('AFLOG_ENABLED'), 'N');
--Variables for ATG Central logging
   g_debug_level         NUMBER           := fnd_log.g_current_runtime_level;
   g_state_level         NUMBER           := fnd_log.level_statement;
   g_proc_level          NUMBER           := fnd_log.level_procedure;
   g_event_level         NUMBER           := fnd_log.level_event;
   g_excep_level         NUMBER           := fnd_log.level_exception;
   g_error_level         NUMBER           := fnd_log.level_error;
   g_unexp_level         NUMBER           := fnd_log.level_unexpected;
   g_path                VARCHAR2 (255)
                               := 'IGC.PLSQL.IGCCICRB.IGC_CC_INT_CC_REL_PUB.';

--
-- Generic Procedure for putting out debug information
--
   PROCEDURE output_debug (p_path IN VARCHAR2, p_debug_msg IN VARCHAR2);

--
-- To fetch the release number.
--
   PROCEDURE release_cc_num (
      p_org_id           IN              igc_cc_headers.org_id%TYPE,
      x_release_cc_num   OUT NOCOPY      igc_cc_headers.cc_num%TYPE
   );

--
-- To fetch the release header Id.
--
   PROCEDURE release_cc_header_id (
      x_release_cc_header_id   OUT NOCOPY   igc_cc_headers.cc_header_id%TYPE
   );

--
-- To fetch the release account line Id.
--
   PROCEDURE release_cc_acct_line_id (
      x_release_cc_acct_line_id   OUT NOCOPY   igc_cc_acct_lines.cc_acct_line_id%TYPE
   );

--
-- To fetch the release payment forecast line Id.
--
   PROCEDURE release_cc_det_pf_line_id (
      x_release_cc_det_pf_line_id   OUT NOCOPY   igc_cc_det_pf.cc_det_pf_line_id%TYPE
   );

   PROCEDURE output_debug (p_path IN VARCHAR2, p_debug_msg IN VARCHAR2)
   IS
-- --------------------------------------------------------------------
-- Local Variables :
-- --------------------------------------------------------------------
/*   l_prod             VARCHAR2(3)           := 'IGC';
   l_sub_comp         VARCHAR2(7)           := 'CC_IRL';
   l_profile_name     VARCHAR2(255)         := 'IGC_DEBUG_LOG_DIRECTORY';
   l_Return_Status    VARCHAR2(1);*/
      l_api_name   CONSTANT VARCHAR2 (30) := 'Output_Debug';
   BEGIN
      /*IGC_MSGS_PKG.Put_Debug_Msg (p_debug_message    => p_debug_msg,
                                  p_profile_log_name => l_profile_name,
                                  p_prod             => l_prod,
                                  p_sub_comp         => l_sub_comp,
                                  p_filename_val     => NULL,
                                  x_Return_Status    => l_Return_Status
                                 );

      IF (l_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
         raise FND_API.G_EXC_ERROR;
      END IF;*/
      IF (g_state_level >= g_debug_level)
      THEN
         fnd_log.STRING (g_state_level, p_path, p_debug_msg);
      END IF;

      RETURN;
-- --------------------------------------------------------------------
-- Exception handler section for the Output_Debug procedure.
-- --------------------------------------------------------------------
   EXCEPTION
      /*WHEN FND_API.G_EXC_ERROR THEN
          RETURN;*/
      WHEN OTHERS
      THEN
         IF (fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
            )
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         RETURN;
   END output_debug;

   PROCEDURE create_releases (
      p_api_version          IN              NUMBER,
      p_init_msg_list        IN              VARCHAR2 := fnd_api.g_false,
      p_commit               IN              VARCHAR2 := fnd_api.g_false,
      p_validation_level     IN              NUMBER
            := fnd_api.g_valid_level_full,
      p_org_id               IN              igc_cc_headers.org_id%TYPE,
      p_sob_id               IN              igc_cc_headers.set_of_books_id%TYPE,
      p_cover_cc_header_id   IN              igc_cc_headers.cc_header_id%TYPE,
      p_invoice_id           IN              ap_invoices_all.invoice_id%TYPE,
      p_invoice_amount       IN              ap_invoices_all.invoice_amount%TYPE,
      p_vendor_id            IN              igc_cc_headers.vendor_id%TYPE,
      p_user_id              IN              igc_cc_headers.created_by%TYPE,
      p_login_id             IN              igc_cc_headers.last_update_login%TYPE,
      x_return_status        OUT NOCOPY      VARCHAR2,
      x_msg_count            OUT NOCOPY      NUMBER,
      x_msg_data             OUT NOCOPY      VARCHAR2,
      x_release_num          OUT NOCOPY      igc_cc_headers.cc_num%TYPE
   )
   IS
      l_api_name           CONSTANT VARCHAR2 (30)        := 'create_releases';
      l_api_version        CONSTANT NUMBER                             := 1.0;
      l_cc_headers_rec              igc_cc_headers%ROWTYPE;
      l_cc_acct_lines_rec           igc_cc_acct_lines%ROWTYPE;
      l_cc_det_pf_lines_rec         igc_cc_det_pf%ROWTYPE;
      l_ap_invoice_lines_rec        ap_invoices_all%ROWTYPE;
      l_cc_num_method                igc_cc_system_options_all.cc_num_method%TYPE;
      l_cc_num_datatype             igc_cc_system_options_all.cc_num_datatype%TYPE;
      l_cc_acct_func_amt            igc_cc_acct_lines.cc_acct_func_amt%TYPE
                                                                         := 0;
      l_cc_rel_func_total_amt       igc_cc_acct_lines.cc_acct_func_amt%TYPE
                                                                         := 0;
      l_cc_currency_code            igc_cc_headers.currency_code%TYPE;
      l_ap_currency_code            ap_invoices_all.invoice_currency_code%TYPE;
      l_ap_conversion_rate          ap_invoices_all.exchange_rate%TYPE;
      l_invoice_amount              ap_invoices_all.invoice_amount%TYPE  := 0;
      l_acct_available_amt          igc_cc_acct_lines.cc_acct_func_amt%TYPE
                                                                         := 0;
      l_release_cc_num              igc_cc_headers.cc_num%TYPE;
      l_release_cc_header_id        igc_cc_headers.cc_header_id%TYPE;
      l_release_cc_acct_line_id     igc_cc_acct_lines.cc_acct_line_id%TYPE;
      l_release_cc_det_pf_line_id   igc_cc_det_pf.cc_det_pf_line_id%TYPE;
      l_return_status               VARCHAR2 (1);
      l_msg_count                   NUMBER;
      l_msg_data                    VARCHAR2 (2000);
      l_row_id                      VARCHAR2 (18);
      l_debug                       VARCHAR2 (1);
      l_version_flag                VARCHAR2 (1);
      l_user_id                     NUMBER;
      l_login_id                    NUMBER;
      e_int_rel_no_sup              EXCEPTION;
      e_int_rel_no_inv              EXCEPTION;
      e_int_rel_no_cover_cc         EXCEPTION;
      e_int_rel_no_num_method       EXCEPTION;
      e_null_parameter              EXCEPTION;
      e_int_rel_invalid_user_id     EXCEPTION;
      e_int_rel_invalid_login_id    EXCEPTION;

      CURSOR c_cc_csr
      IS
         SELECT *
           FROM igc_cc_headers cc
          WHERE cc.cc_header_id = p_cover_cc_header_id
            AND cc.org_id = p_org_id
            AND cc.set_of_books_id = p_sob_id;

      CURSOR c_cc_acct_csr (p_cc_header_id IN NUMBER)
      IS
         SELECT *
           FROM igc_cc_acct_lines ccal
          WHERE ccal.cc_header_id = p_cc_header_id;

      CURSOR c_cc_det_pf_csr (p_cc_acct_line_id IN NUMBER)
      IS
         SELECT *
           FROM igc_cc_det_pf ccdpf
          WHERE ccdpf.cc_acct_line_id = p_cc_acct_line_id;

      CURSOR c_inv_csr
      IS
         SELECT *
           FROM ap_invoices_all ap
          WHERE ap.set_of_books_id = p_sob_id
            AND ap.org_id = p_org_id
            AND ap.invoice_id = p_invoice_id;

      l_full_path                   VARCHAR2 (255);
   BEGIN
      l_full_path := g_path || 'create_releases';
-- -------------------------------------------------------------------
-- Initialize the return values.
-- -------------------------------------------------------------------
      x_return_status := fnd_api.g_ret_sts_success;
      x_msg_data := NULL;
      x_msg_count := 0;
      x_release_num := NULL;
      SAVEPOINT int_rel_api_pt;

-- -------------------------------------------------------------------
-- Make sure that the appropriate version is being used
-- -------------------------------------------------------------------
      IF NOT fnd_api.compatible_api_call (l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          g_pkg_name
                                         )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

-- -------------------------------------------------------------------
-- Make sure that if the message stack is to be initialized it is.
-- -------------------------------------------------------------------
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

-- -------------------------------------------------------------------
-- Setup Debug info for API usage if needed.
-- -------------------------------------------------------------------
--   l_debug       := FND_PROFILE.VALUE('IGC_DEBUG_ENABLED');
--   IF (l_debug = 'Y') THEN
--       l_debug := FND_API.G_TRUE;
--   ELSE
--       l_debug := FND_API.G_FALSE;
--   END IF;
--   IGC_MSGS_PKG.g_debug_mode := FND_API.TO_BOOLEAN(l_debug);
--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
      IF (g_debug_mode = 'Y')
      THEN
         g_debug_msg :=
            'Internal Contract Commitment Releases API Main debug mode enabled...';
         output_debug (l_full_path, p_debug_msg => g_debug_msg);
      END IF;

-- -------------------------------------------------------------------
-- Internal Contract Commitment API releases Starts Here.
-- -------------------------------------------------------------------
      IF (p_org_id IS NULL)
      THEN
         fnd_message.set_name ('IGC', 'IGC_CC_NO_ORG_ID');

         IF (g_error_level >= g_debug_level)
         THEN
            fnd_log.MESSAGE (g_error_level, l_full_path, FALSE);
         END IF;

         fnd_msg_pub.ADD;
         RAISE e_null_parameter;
      END IF;

      IF (p_sob_id IS NULL)
      THEN
         fnd_message.set_name ('IGC', 'IGC_CC_NO_SOB');

         IF (g_error_level >= g_debug_level)
         THEN
            fnd_log.MESSAGE (g_error_level, l_full_path, FALSE);
         END IF;

         fnd_msg_pub.ADD;
         RAISE e_null_parameter;
      END IF;

      l_version_flag := 'X';

      IF p_vendor_id IS NULL
      THEN
         fnd_message.set_name ('IGC', 'IGC_CC_INT_REL_NO_SUP');

         IF (g_error_level >= g_debug_level)
         THEN
            fnd_log.MESSAGE (g_error_level, l_full_path, FALSE);
         END IF;

         fnd_msg_pub.ADD;
         RAISE e_int_rel_no_sup;
      END IF;

      IF p_invoice_id IS NULL
      THEN
         fnd_message.set_name ('IGC', 'IGC_CC_INT_REL_NO_INV');

         IF (g_error_level >= g_debug_level)
         THEN
            fnd_log.MESSAGE (g_error_level, l_full_path, FALSE);
         END IF;

         fnd_msg_pub.ADD;
         RAISE e_int_rel_no_inv;
      END IF;

      IF p_cover_cc_header_id IS NULL
      THEN
         fnd_message.set_name ('IGC', 'IGC_CC_INT_REL_NO_CC');

         IF (g_error_level >= g_debug_level)
         THEN
            fnd_log.MESSAGE (g_error_level, l_full_path, FALSE);
         END IF;

         fnd_msg_pub.ADD;
         RAISE e_int_rel_no_cover_cc;
      END IF;

      IF p_user_id IS NOT NULL
      THEN
         BEGIN
            SELECT user_id
              INTO l_user_id
              FROM fnd_user
             WHERE user_id = p_user_id;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               fnd_message.set_name ('IGC', 'IGC_CC_INT_REL_INVALID_USER_ID');
               fnd_message.set_token ('USER_ID', TO_CHAR (p_user_id), TRUE);

               IF (g_excep_level >= g_debug_level)
               THEN
                  fnd_log.MESSAGE (g_excep_level, l_full_path, FALSE);
               END IF;

               fnd_msg_pub.ADD;
               RAISE e_int_rel_invalid_user_id;
         END;
      END IF;

      IF p_login_id IS NOT NULL
      THEN
         BEGIN
            SELECT login_id
              INTO l_login_id
              FROM fnd_logins
             WHERE login_id = p_login_id;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               fnd_message.set_name ('IGC', 'IGC_CC_INT_REL_INVALID_LOGINID');
               fnd_message.set_token ('LOGIN_ID', TO_CHAR (p_login_id), TRUE);

               IF (g_excep_level >= g_debug_level)
               THEN
                  fnd_log.MESSAGE (g_excep_level, l_full_path, FALSE);
               END IF;

               fnd_msg_pub.ADD;
               RAISE e_int_rel_invalid_login_id;
         END;
      END IF;

-- -------------------------------------------------------------------
-- Amount Available or not check begins here.
-- -------------------------------------------------------------------
      IF p_cover_cc_header_id IS NOT NULL
      THEN
         BEGIN
            SELECT ap.invoice_currency_code, ap.exchange_rate
              INTO l_ap_currency_code, l_ap_conversion_rate
              FROM ap_invoices_all ap
             WHERE ap.invoice_id = p_invoice_id
               AND ap.org_id = p_org_id
               AND ap.set_of_books_id = p_sob_id;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               fnd_message.set_name ('IGC', 'IGC_CC_INT_REL_NO_INV_INFO');
               fnd_msg_pub.ADD;

               IF (g_excep_level >= g_debug_level)
               THEN
                  fnd_log.MESSAGE (g_excep_level, l_full_path, FALSE);
               END IF;

               RAISE e_int_rel_no_inv;
         END;

         BEGIN
            SELECT cc.currency_code
              INTO l_cc_currency_code
              FROM igc_cc_headers cc
             WHERE cc.cc_header_id = p_cover_cc_header_id;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               fnd_message.set_name ('IGC', 'IGC_CC_INT_REL_NO_COVER_INFO');

               IF (g_excep_level >= g_debug_level)
               THEN
                  fnd_log.MESSAGE (g_excep_level, l_full_path, FALSE);
               END IF;

               fnd_msg_pub.ADD;
               RAISE e_int_rel_no_cover_cc;
         END;

         BEGIN
            SELECT NVL (ccal.cc_acct_func_amt, 0)
              INTO l_cc_acct_func_amt
              FROM igc_cc_acct_lines ccal
             WHERE ccal.cc_header_id = p_cover_cc_header_id;
         EXCEPTION
            WHEN OTHERS
            THEN
               fnd_message.set_name ('IGC', 'IGC_CC_INT_REL_NO_COVER_AMT');

               IF (g_excep_level >= g_debug_level)
               THEN
                  fnd_log.MESSAGE (g_excep_level, l_full_path, FALSE);
               END IF;

               fnd_msg_pub.ADD;
               RAISE e_int_rel_no_cover_cc;
         END;

         BEGIN
            SELECT SUM (NVL (ccal.cc_acct_func_amt, 0))
              INTO l_cc_rel_func_total_amt
              FROM igc_cc_acct_lines ccal, igc_cc_headers cchd
             WHERE ccal.parent_header_id = p_cover_cc_header_id
               AND ccal.cc_header_id = cchd.cc_header_id;
         EXCEPTION
            WHEN OTHERS
            THEN
               fnd_message.set_name ('IGC', 'IGC_CC_INT_REL_NO_REL_AMT');

               IF (g_excep_level >= g_debug_level)
               THEN
                  fnd_log.MESSAGE (g_excep_level, l_full_path, FALSE);
               END IF;

               fnd_msg_pub.ADD;
               RAISE e_int_rel_no_cover_cc;
         END;

         IF NVL (l_cc_rel_func_total_amt, 0) <> 0
         THEN
            l_acct_available_amt :=
                NVL (l_cc_acct_func_amt, 0)
                - NVL (l_cc_rel_func_total_amt, 0);
         ELSE
            l_acct_available_amt := NVL (l_cc_acct_func_amt, 0);
         END IF;

         IF l_cc_currency_code <> l_ap_currency_code
         THEN
            l_invoice_amount :=
                             p_invoice_amount * NVL (l_ap_conversion_rate, 1);
         ELSE
            l_invoice_amount :=
                             p_invoice_amount * NVL (l_ap_conversion_rate, 1);
         END IF;

         IF (NVL (l_acct_available_amt, 0) < l_invoice_amount)
         THEN
            fnd_message.set_name ('IGC', 'IGC_CC_INT_REL_NO_AVAIL_AMT');

            IF (g_error_level >= g_debug_level)
            THEN
               fnd_log.MESSAGE (g_error_level, l_full_path, FALSE);
            END IF;

            fnd_msg_pub.ADD;
            RAISE e_int_rel_no_cover_cc;
         END IF;
      END IF;

-- -------------------------------------------------------------------
-- Amount available or not check ends here.
-- -------------------------------------------------------------------

      -- -------------------------------------------------------------------
-- Get the numbering method begins here.
-- -------------------------------------------------------------------
      BEGIN
         SELECT ccnm.cc_num_method, ccnm.cc_num_datatype
           INTO l_cc_num_method, l_cc_num_datatype
           FROM  igc_cc_system_options_all ccnm  /*igc_cc_number_methods */
          WHERE ccnm.org_id = p_org_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            fnd_message.set_name ('IGC', 'IGC_CC_NUM_METHOD_NOT_DEFINED');

            IF (g_excep_level >= g_debug_level)
            THEN
               fnd_log.MESSAGE (g_excep_level, l_full_path, FALSE);
            END IF;

            fnd_msg_pub.ADD;
            RAISE e_int_rel_no_num_method;
      END;

-- -------------------------------------------------------------------
-- Get the numbering method ends here.
-- -------------------------------------------------------------------

      -- -------------------------------------------------------------------
-- Creation of the internal contract commitment releases begins here.
-- -------------------------------------------------------------------
      OPEN c_inv_csr;

      LOOP
         FETCH c_inv_csr
          INTO l_ap_invoice_lines_rec;

         EXIT WHEN c_inv_csr%NOTFOUND;

         OPEN c_cc_csr;

         LOOP
            FETCH c_cc_csr
             INTO l_cc_headers_rec;

            EXIT WHEN c_cc_csr%NOTFOUND;

            IF l_cc_num_method IN ('A', 'M') AND l_release_cc_num IS NULL
            THEN
               /* mh: Comment out existing call to local procedure, instead call generic procedure
                  that can be called by other modules as well */
                /* existing: release_cc_num ( p_org_id           => p_org_id,
                                 x_release_cc_num   => l_release_cc_num);*/
                -- new
				igc_cc_system_options_pkg.create_auto_cc_num
                           (p_api_version           => 1.0,
                            p_init_msg_list         => fnd_api.g_false,
                            p_commit                => fnd_api.g_false,
                            p_validation_level      => fnd_api.g_valid_level_full,
                            x_return_status         => l_return_status,
                            x_msg_count             => l_msg_count,
                            x_msg_data              => l_msg_data,
                            p_org_id                => p_org_id,
                            p_sob_id                => p_sob_id,
                            x_cc_num                => l_release_cc_num
                           );

               -- mh: end
               IF l_release_cc_num IS NULL
               THEN
                  RAISE fnd_api.g_exc_unexpected_error;
               END IF;                                    -- CC Header Number.
            END IF;

            release_cc_header_id
                             (x_release_cc_header_id      => l_release_cc_header_id);

            IF l_release_cc_header_id IS NULL
            THEN
               RAISE fnd_api.g_exc_unexpected_error;
            END IF;                               -- CC Header Identification.

            igc_cc_headers_pkg.insert_row
               (p_api_version              => 1.0,
                p_init_msg_list            => fnd_api.g_false,
                p_commit                   => fnd_api.g_false,
                p_validation_level         => fnd_api.g_valid_level_full,
                x_return_status            => l_return_status,
                x_msg_count                => l_msg_count,
                x_msg_data                 => l_msg_data,
                p_rowid                    => l_row_id,
                p_cc_header_id             => l_release_cc_header_id,
                p_parent_header_id         => p_cover_cc_header_id,
                p_org_id                   => p_org_id,
                p_cc_type                  => 'R',
                p_cc_num                   => l_release_cc_num,
                p_cc_version_num           => 0,
                p_cc_state                 => 'CM',
                p_cc_ctrl_status           => 'O',
                p_cc_encmbrnc_status       => 'C',
                p_cc_apprvl_status         => 'AP',
                p_vendor_id                => l_ap_invoice_lines_rec.vendor_id,
                p_vendor_site_id           => l_ap_invoice_lines_rec.vendor_site_id,
                p_vendor_contact_id        => NULL,
                p_term_id                  => l_ap_invoice_lines_rec.terms_id,
                p_location_id              => l_cc_headers_rec.location_id,
                p_set_of_books_id          => l_cc_headers_rec.set_of_books_id,
                p_cc_acct_date             => l_cc_headers_rec.cc_acct_date,
                p_cc_desc                  => NULL,
                p_cc_start_date            => l_cc_headers_rec.cc_start_date,
                p_cc_end_date              => l_cc_headers_rec.cc_end_date,
                p_cc_owner_user_id         => l_cc_headers_rec.cc_owner_user_id,
                p_cc_preparer_user_id      => p_user_id,
                p_currency_code            => l_ap_invoice_lines_rec.invoice_currency_code,
                p_conversion_type          => l_ap_invoice_lines_rec.exchange_rate_type,
                p_conversion_date          => l_ap_invoice_lines_rec.exchange_date,
                p_conversion_rate          => l_ap_invoice_lines_rec.exchange_rate,
                p_last_update_date         => SYSDATE,
                p_last_updated_by          => p_user_id,
                p_last_update_login        => p_login_id,
                p_created_by               => p_user_id,
                p_creation_date            => SYSDATE,
                p_wf_item_type             => NULL,
                p_wf_item_key              => NULL,
                p_cc_current_user_id       => p_user_id,
                p_attribute1               => NULL,
                p_attribute2               => NULL,
                p_attribute3               => NULL,
                p_attribute4               => NULL,
                p_attribute5               => NULL,
                p_attribute6               => NULL,
                p_attribute7               => NULL,
                p_attribute8               => NULL,
                p_attribute9               => NULL,
                p_attribute10              => NULL,
                p_attribute11              => NULL,
                p_attribute12              => NULL,
                p_attribute13              => NULL,
                p_attribute14              => NULL,
                p_attribute15              => NULL,
                p_context                  => NULL,
                p_cc_guarantee_flag        => l_cc_headers_rec.cc_guarantee_flag,
                g_flag                     => l_version_flag
               );

            IF l_return_status <> fnd_api.g_ret_sts_success
            THEN
               x_msg_data := l_msg_data;
               x_msg_count := l_msg_count;
               RAISE fnd_api.g_exc_unexpected_error;
            ELSE
               OPEN c_cc_acct_csr (p_cover_cc_header_id);

               LOOP
                  FETCH c_cc_acct_csr
                   INTO l_cc_acct_lines_rec;

                  EXIT WHEN c_cc_acct_csr%NOTFOUND;
                  release_cc_acct_line_id
                      (x_release_cc_acct_line_id      => l_release_cc_acct_line_id);

                  IF l_release_cc_acct_line_id IS NULL
                  THEN
                     RAISE fnd_api.g_exc_unexpected_error;
                  END IF;                      -- Account Line Identification.

                  igc_cc_acct_lines_pkg.insert_row
                     (p_api_version                  => 1.0,
                      p_init_msg_list                => fnd_api.g_false,
                      p_commit                       => fnd_api.g_false,
                      p_validation_level             => fnd_api.g_valid_level_full,
                      x_return_status                => l_return_status,
                      x_msg_count                    => l_msg_count,
                      x_msg_data                     => l_msg_data,
                      p_rowid                        => l_row_id,
                      p_cc_acct_line_id              => l_release_cc_acct_line_id,
                      p_cc_header_id                 => l_release_cc_header_id,
                      p_parent_header_id             => p_cover_cc_header_id,
                      p_parent_acct_line_id          => l_cc_acct_lines_rec.cc_acct_line_id,
                      p_cc_charge_code_comb_id       => l_cc_acct_lines_rec.cc_charge_code_combination_id,
                      p_cc_acct_line_num             => l_cc_acct_lines_rec.cc_acct_line_num,
                      p_cc_budget_code_comb_id       => l_cc_acct_lines_rec.cc_budget_code_combination_id,
                      p_cc_acct_entered_amt          => p_invoice_amount,
                      p_cc_acct_func_amt             =>   p_invoice_amount
                                                        * NVL
                                                             (l_ap_invoice_lines_rec.exchange_rate,
                                                              1
                                                             ),
                      p_cc_acct_desc                 => l_cc_acct_lines_rec.cc_acct_desc,
                      p_cc_acct_billed_amt           => NULL,
                      p_cc_acct_unbilled_amt         => NULL,
                      p_cc_acct_taxable_flag         => l_cc_acct_lines_rec.cc_acct_taxable_flag,
                      p_tax_id                       => NULL,-- modified for Ebtax uptake for CC (Bug No-6472296)
                      p_cc_acct_encmbrnc_amt         =>   p_invoice_amount
                                                        * NVL
                                                             (l_ap_invoice_lines_rec.exchange_rate,
                                                              1
                                                             ),
                      p_cc_acct_encmbrnc_date        => l_cc_headers_rec.cc_acct_date,
                      p_cc_acct_encmbrnc_status      => 'C',
                      p_project_id                   => l_cc_acct_lines_rec.project_id,
                      p_task_id                      => l_cc_acct_lines_rec.task_id,
                      p_expenditure_type             => l_cc_acct_lines_rec.expenditure_type,
                      p_expenditure_org_id           => l_cc_acct_lines_rec.expenditure_org_id,
                      p_expenditure_item_date        => l_cc_acct_lines_rec.expenditure_item_date,
                      p_last_update_date             => SYSDATE,
                      p_last_updated_by              => p_user_id,
                      p_last_update_login            => p_login_id,
                      p_creation_date                => SYSDATE,
                      p_created_by                   => p_user_id,
                      p_attribute1                   => NULL,
                      p_attribute2                   => NULL,
                      p_attribute3                   => NULL,
                      p_attribute4                   => NULL,
                      p_attribute5                   => NULL,
                      p_attribute6                   => NULL,
                      p_attribute7                   => NULL,
                      p_attribute8                   => NULL,
                      p_attribute9                   => NULL,
                      p_attribute10                  => NULL,
                      p_attribute11                  => NULL,
                      p_attribute12                  => NULL,
                      p_attribute13                  => NULL,
                      p_attribute14                  => NULL,
                      p_attribute15                  => NULL,
                      p_context                      => NULL,
                      p_cc_func_withheld_amt         => l_cc_acct_lines_rec.cc_func_withheld_amt,
                      p_cc_ent_withheld_amt          => l_cc_acct_lines_rec.cc_ent_withheld_amt,
                      g_flag                         => l_version_flag,
		      p_tax_classif_code	     => l_cc_acct_lines_rec.tax_classif_code -- modified for Ebtax uptake (Bug No-6472296)
                     );

                  IF l_return_status <> fnd_api.g_ret_sts_success
                  THEN
                     x_msg_data := l_msg_data;
                     x_msg_count := l_msg_count;
                     RAISE fnd_api.g_exc_unexpected_error;
                  ELSE
                     -- Payment Forecast Details
                     OPEN c_cc_det_pf_csr
                                         (l_cc_acct_lines_rec.cc_acct_line_id);

                     LOOP
                        FETCH c_cc_det_pf_csr
                         INTO l_cc_det_pf_lines_rec;

                        EXIT WHEN c_cc_det_pf_csr%NOTFOUND;
                        release_cc_det_pf_line_id
                           (x_release_cc_det_pf_line_id      => l_release_cc_det_pf_line_id
                           );

                        IF l_release_cc_det_pf_line_id IS NULL
                        THEN
                           RAISE fnd_api.g_exc_unexpected_error;
                        END IF;       -- Payment Forecast Line Identification.

                        igc_cc_det_pf_pkg.insert_row
                           (p_api_version                    => 1.0,
                            p_init_msg_list                  => fnd_api.g_false,
                            p_commit                         => fnd_api.g_false,
                            p_validation_level               => fnd_api.g_valid_level_full,
                            x_return_status                  => l_return_status,
                            x_msg_count                      => l_msg_count,
                            x_msg_data                       => l_msg_data,
                            p_rowid                          => l_row_id,
                            p_cc_det_pf_line_id              => l_release_cc_det_pf_line_id,
                            p_cc_det_pf_line_num             => l_cc_det_pf_lines_rec.cc_det_pf_line_num,
                            p_cc_acct_line_id                => l_release_cc_acct_line_id,
                            p_parent_acct_line_id            => l_cc_det_pf_lines_rec.cc_acct_line_id,
                            p_parent_det_pf_line_id          => l_cc_det_pf_lines_rec.cc_det_pf_line_id,
                            p_cc_det_pf_entered_amt          => p_invoice_amount,
                            p_cc_det_pf_func_amt             =>   p_invoice_amount
                                                                * NVL
                                                                     (l_ap_invoice_lines_rec.exchange_rate,
                                                                      1
                                                                     ),
                            p_cc_det_pf_date                 => l_cc_det_pf_lines_rec.cc_det_pf_date,
                            p_cc_det_pf_billed_amt           => NULL,
                            p_cc_det_pf_unbilled_amt         => NULL,
                            p_cc_det_pf_encmbrnc_amt         =>   p_invoice_amount
                                                                * NVL
                                                                     (l_ap_invoice_lines_rec.exchange_rate,
                                                                      1
                                                                     ),
                            p_cc_det_pf_encmbrnc_date        => l_cc_det_pf_lines_rec.cc_det_pf_date,
                            p_cc_det_pf_encmbrnc_status      => 'C',
                            p_last_update_date               => SYSDATE,
                            p_last_updated_by                => p_user_id,
                            p_last_update_login              => p_login_id,
                            p_creation_date                  => SYSDATE,
                            p_created_by                     => p_user_id,
                            p_attribute1                     => NULL,
                            p_attribute2                     => NULL,
                            p_attribute3                     => NULL,
                            p_attribute4                     => NULL,
                            p_attribute5                     => NULL,
                            p_attribute6                     => NULL,
                            p_attribute7                     => NULL,
                            p_attribute8                     => NULL,
                            p_attribute9                     => NULL,
                            p_attribute10                    => NULL,
                            p_attribute11                    => NULL,
                            p_attribute12                    => NULL,
                            p_attribute13                    => NULL,
                            p_attribute14                    => NULL,
                            p_attribute15                    => NULL,
                            p_context                        => NULL,
                            g_flag                           => l_version_flag
                           );

                        IF l_return_status <> fnd_api.g_ret_sts_success
                        THEN
                           x_msg_data := l_msg_data;
                           x_msg_count := l_msg_count;
                           RAISE fnd_api.g_exc_unexpected_error;
                        ELSE
                           BEGIN
                              -- PO Creation.
                              igc_cc_po_interface_pkg.convert_cc_to_po
                                 (p_api_version           => 1.0,
                                  p_init_msg_list         => fnd_api.g_false,
                                  p_commit                => fnd_api.g_false,
                                  p_validation_level      => fnd_api.g_valid_level_full,
                                  x_return_status         => l_return_status,
                                  x_msg_count             => l_msg_count,
                                  x_msg_data              => l_msg_data,
                                  p_cc_header_id          => l_release_cc_header_id
                                 );

                              IF l_return_status <> fnd_api.g_ret_sts_success
                              THEN
                                 x_msg_data := l_msg_data;
                                 x_msg_count := l_msg_count;
                                 RAISE fnd_api.g_exc_unexpected_error;
                              ELSE
                                 BEGIN
                                    -- Update PO Approved Flag
                                    igc_cc_po_interface_pkg.update_po_approved_flag
                                       (p_api_version           => 1.0,
                                        p_init_msg_list         => fnd_api.g_false,
                                        p_commit                => fnd_api.g_false,
                                        p_validation_level      => fnd_api.g_valid_level_full,
                                        x_return_status         => l_return_status,
                                        x_msg_count             => l_msg_count,
                                        x_msg_data              => l_msg_data,
                                        p_cc_header_id          => l_release_cc_header_id
                                       );

                                    IF l_return_status <>
                                                     fnd_api.g_ret_sts_success
                                    THEN
                                       x_msg_data := l_msg_data;
                                       x_msg_count := l_msg_count;
                                       RAISE fnd_api.g_exc_unexpected_error;
                                    ELSE
                                       x_msg_data := l_msg_data;
                                       x_msg_count := l_msg_count;
                                       x_release_num := l_release_cc_num;
                                    END IF;               -- PO Approved Flag.
                                 END;
                              END IF;                          -- PO Creation.
                           END;
                        END IF;                  -- Payment Forecast Creation.
                     END LOOP;                        -- Payment Forecast Loop

                     CLOSE c_cc_det_pf_csr;
                  END IF;                            -- Account Line Creation.
               END LOOP;                                 -- Account Lines Loop

               CLOSE c_cc_acct_csr;
            END IF;                                    -- CC Headers Creation.
         END LOOP;                                          -- CC Headers Loop

         CLOSE c_cc_csr;
      END LOOP;                                            -- Ap Invoices Loop

      CLOSE c_inv_csr;

-- --------------------------------------------------------------------
-- Close Cursor
-- --------------------------------------------------------------------
      IF (c_cc_det_pf_csr%ISOPEN)
      THEN
         CLOSE c_cc_det_pf_csr;
      END IF;

      IF (c_cc_acct_csr%ISOPEN)
      THEN
         CLOSE c_cc_acct_csr;
      END IF;

      IF (c_cc_csr%ISOPEN)
      THEN
         CLOSE c_cc_csr;
      END IF;

      IF (c_inv_csr%ISOPEN)
      THEN
         CLOSE c_inv_csr;
      END IF;

      IF fnd_api.to_boolean (p_commit)
      THEN
--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
         IF (g_debug_mode = 'Y')
         THEN
            g_debug_msg := 'Internal Releases API Commiting Record...';
            output_debug (l_full_path, p_debug_msg => g_debug_msg);
         END IF;

         COMMIT WORK;
      END IF;

      RETURN;
   EXCEPTION
      WHEN e_int_rel_no_sup OR e_int_rel_no_inv OR e_int_rel_no_cover_cc OR e_int_rel_no_num_method OR e_int_rel_no_num_method OR e_int_rel_invalid_user_id OR e_int_rel_invalid_login_id
      THEN
         IF (c_cc_det_pf_csr%ISOPEN)
         THEN
            CLOSE c_cc_det_pf_csr;
         END IF;

         IF (c_cc_acct_csr%ISOPEN)
         THEN
            CLOSE c_cc_acct_csr;
         END IF;

         IF (c_cc_csr%ISOPEN)
         THEN
            CLOSE c_cc_csr;
         END IF;

         IF (c_inv_csr%ISOPEN)
         THEN
            CLOSE c_inv_csr;
         END IF;

         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );

         IF (g_excep_level >= g_debug_level)
         THEN
            fnd_log.STRING
               (g_excep_level,
                l_full_path,
                   'E_INT_REL_NO_SUP or E_INT_REL_NO_INV or E_INT_REL_NO_COVER_CC'
                || ' or E_INT_REL_NO_NUM_METHOD or E_INT_REL_NO_NUM_METHOD or E_INT_REL_INVALID_USER_ID or E_INT_REL_INVALID_LOGIN_ID'
               );
         END IF;
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         IF (c_cc_det_pf_csr%ISOPEN)
         THEN
            CLOSE c_cc_det_pf_csr;
         END IF;

         IF (c_cc_acct_csr%ISOPEN)
         THEN
            CLOSE c_cc_acct_csr;
         END IF;

         IF (c_cc_csr%ISOPEN)
         THEN
            CLOSE c_cc_csr;
         END IF;

         IF (c_inv_csr%ISOPEN)
         THEN
            CLOSE c_inv_csr;
         END IF;

         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );

         IF (g_excep_level >= g_debug_level)
         THEN
            fnd_log.STRING (g_excep_level,
                            l_full_path,
                            'FND_API.G_EXC_UNEXPECTED_ERROR Exception Raised'
                           );
         END IF;
      WHEN OTHERS
      THEN
         IF (c_cc_det_pf_csr%ISOPEN)
         THEN
            CLOSE c_cc_det_pf_csr;
         END IF;

         IF (c_cc_acct_csr%ISOPEN)
         THEN
            CLOSE c_cc_acct_csr;
         END IF;

         IF (c_cc_csr%ISOPEN)
         THEN
            CLOSE c_cc_csr;
         END IF;

         IF (c_inv_csr%ISOPEN)
         THEN
            CLOSE c_inv_csr;
         END IF;

         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );

         IF (g_unexp_level >= g_debug_level)
         THEN
            fnd_message.set_name ('IGC', 'IGC_LOGGING_UNEXP_ERROR');
            fnd_message.set_token ('CODE', SQLCODE);
            fnd_message.set_token ('MSG', SQLERRM);
            fnd_log.MESSAGE (g_unexp_level, l_full_path, TRUE);
         END IF;
   END create_releases;

   PROCEDURE release_cc_num (
      p_org_id           IN              igc_cc_headers.org_id%TYPE,
      x_release_cc_num   OUT NOCOPY      igc_cc_headers.cc_num%TYPE
   )
   IS
      l_api_name   CONSTANT VARCHAR2 (30)  := 'release_cc_num';
      l_full_path           VARCHAR2 (255);
   BEGIN
      l_full_path := g_path || 'release_cc_num';
      x_release_cc_num := NULL;

      BEGIN
         SELECT (ccnm.cc_next_num + 1)
           INTO x_release_cc_num
           FROM igc_cc_system_options_all ccnm
          WHERE ccnm.org_id = p_org_id AND ccnm.cc_num_method IN ('A', 'M');
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            x_release_cc_num := 1;
      END;

      IF x_release_cc_num IS NOT NULL
      THEN
         BEGIN
            UPDATE igc_cc_system_options_all ccnm
               SET ccnm.cc_next_num = x_release_cc_num
             WHERE ccnm.org_id = p_org_id AND ccnm.cc_num_method IN
                                                                   ('A', 'M');
         EXCEPTION
            WHEN OTHERS
            THEN
               fnd_message.set_name ('IGC', 'IGC_CC_NO_UPD_CC_NEXT_NUM');

               IF (g_excep_level >= g_debug_level)
               THEN
                  fnd_log.MESSAGE (g_excep_level, l_full_path, FALSE);
               END IF;

               fnd_msg_pub.ADD;
               RAISE fnd_api.g_exc_error;
         END;
      END IF;

      RETURN;
   EXCEPTION
      WHEN OTHERS
      THEN
         x_release_cc_num := NULL;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         IF (g_unexp_level >= g_debug_level)
         THEN
            fnd_message.set_name ('IGC', 'IGC_LOGGING_UNEXP_ERROR');
            fnd_message.set_token ('CODE', SQLCODE);
            fnd_message.set_token ('MSG', SQLERRM);
            fnd_log.MESSAGE (g_unexp_level, l_full_path, TRUE);
         END IF;

         RETURN;
   END release_cc_num;

   PROCEDURE release_cc_header_id (
      x_release_cc_header_id   OUT NOCOPY   igc_cc_headers.cc_header_id%TYPE
   )
   IS
      l_api_name   CONSTANT VARCHAR2 (30)  := 'release_cc_header_id';
      l_full_path           VARCHAR2 (255);
   BEGIN
      l_full_path := g_path || 'release_cc_header_id';
      x_release_cc_header_id := NULL;

      BEGIN
         SELECT igc_cc_headers_s.NEXTVAL
           INTO x_release_cc_header_id
           FROM DUAL;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            fnd_message.set_name ('IGC', 'IGC_CC_NO_CC_HDR_SEQ');

            IF (g_excep_level >= g_debug_level)
            THEN
               fnd_log.MESSAGE (g_excep_level, l_full_path, FALSE);
            END IF;

            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
      END;

      RETURN;
   EXCEPTION
      WHEN OTHERS
      THEN
         x_release_cc_header_id := NULL;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         IF (g_unexp_level >= g_debug_level)
         THEN
            fnd_message.set_name ('IGC', 'IGC_LOGGING_UNEXP_ERROR');
            fnd_message.set_token ('CODE', SQLCODE);
            fnd_message.set_token ('MSG', SQLERRM);
            fnd_log.MESSAGE (g_unexp_level, l_full_path, TRUE);
         END IF;

         RETURN;
   END release_cc_header_id;

   PROCEDURE release_cc_acct_line_id (
      x_release_cc_acct_line_id   OUT NOCOPY   igc_cc_acct_lines.cc_acct_line_id%TYPE
   )
   IS
      l_api_name   CONSTANT VARCHAR2 (30)  := 'release_cc_acct_line_id';
      l_full_path           VARCHAR2 (255);
   BEGIN
      l_full_path := g_path || 'release_cc_acct_line_id';
      x_release_cc_acct_line_id := NULL;

      BEGIN
         SELECT igc_cc_acct_lines_s.NEXTVAL
           INTO x_release_cc_acct_line_id
           FROM DUAL;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            fnd_message.set_name ('IGC', 'IGC_CC_NO_CC_ACCT_SEQ');

            IF (g_excep_level >= g_debug_level)
            THEN
               fnd_log.MESSAGE (g_excep_level, l_full_path, FALSE);
            END IF;

            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
      END;

      RETURN;
   EXCEPTION
      WHEN OTHERS
      THEN
         x_release_cc_acct_line_id := NULL;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         IF (g_unexp_level >= g_debug_level)
         THEN
            fnd_message.set_name ('IGC', 'IGC_LOGGING_UNEXP_ERROR');
            fnd_message.set_token ('CODE', SQLCODE);
            fnd_message.set_token ('MSG', SQLERRM);
            fnd_log.MESSAGE (g_unexp_level, l_full_path, TRUE);
         END IF;

         RETURN;
   END release_cc_acct_line_id;

   PROCEDURE release_cc_det_pf_line_id (
      x_release_cc_det_pf_line_id   OUT NOCOPY   igc_cc_det_pf.cc_det_pf_line_id%TYPE
   )
   IS
      l_api_name   CONSTANT VARCHAR2 (30)  := 'release_cc_det_pf_line_id';
      l_full_path           VARCHAR2 (255);
   BEGIN
      l_full_path := g_path || 'release_cc_det_pf_line_id';
      x_release_cc_det_pf_line_id := NULL;

      BEGIN
         SELECT igc_cc_det_pf_s.NEXTVAL
           INTO x_release_cc_det_pf_line_id
           FROM DUAL;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            fnd_message.set_name ('IGC', 'IGC_CC_NO_CC_DET_PF_SEQ');

            IF (g_excep_level >= g_debug_level)
            THEN
               fnd_log.MESSAGE (g_excep_level, l_full_path, FALSE);
            END IF;

            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
      END;

      RETURN;
   EXCEPTION
      WHEN OTHERS
      THEN
         x_release_cc_det_pf_line_id := NULL;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         IF (g_unexp_level >= g_debug_level)
         THEN
            fnd_message.set_name ('IGC', 'IGC_LOGGING_UNEXP_ERROR');
            fnd_message.set_token ('CODE', SQLCODE);
            fnd_message.set_token ('MSG', SQLERRM);
            fnd_log.MESSAGE (g_unexp_level, l_full_path, TRUE);
         END IF;

         RETURN;
   END release_cc_det_pf_line_id;
END igc_cc_int_cc_rel_pub;

/
