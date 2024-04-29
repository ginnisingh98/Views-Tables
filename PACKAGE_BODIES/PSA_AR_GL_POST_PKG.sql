--------------------------------------------------------
--  DDL for Package Body PSA_AR_GL_POST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSA_AR_GL_POST_PKG" AS
/* $Header: PSAMFG1B.pls 120.2 2006/09/13 12:46:50 agovil noship $ */

 --===========================FND_LOG.START=====================================
   g_state_level NUMBER	:=	FND_LOG.LEVEL_STATEMENT;
   g_proc_level  NUMBER	:=	FND_LOG.LEVEL_PROCEDURE;
   g_event_level NUMBER	:=	FND_LOG.LEVEL_EVENT;
   g_excep_level NUMBER	:=	FND_LOG.LEVEL_EXCEPTION;
   g_error_level NUMBER	:=	FND_LOG.LEVEL_ERROR;
   g_unexp_level NUMBER	:=	FND_LOG.LEVEL_UNEXPECTED;
   g_path        VARCHAR2(50);
 --===========================FND_LOG.END=======================================

PROCEDURE transfer_to_gl(
			 p_start_date         IN DATE,
			 p_post_thru_date     IN DATE,
			 p_parent_req_id      IN NUMBER,
			 p_posting_control_id IN NUMBER,
                         p_summary_flag       IN VARCHAR2,
                         p_status_code       OUT NOCOPY VARCHAR2
			 ) IS

   -- Bug 3871686, replaced APPS with a subquery
   -- to find the exact schema name
   CURSOR  c_fv_pkg_chk
   IS
      SELECT DISTINCT 'Y' fv_package
      FROM ALL_OBJECTS
      WHERE object_name = 'FV_AR_PKG'
      AND   object_type = 'PACKAGE'
      AND   owner       = ( SELECT oracle_username
                            FROM fnd_oracle_userid
                            WHERE read_only_flag = 'U')
      AND   status      = 'VALID';

   l_req_id               NUMBER;
   l_org_id               psa_implementation_all.org_id%TYPE;
   l_psa_feature          psa_implementation_all.psa_feature%TYPE;
   l_enabled_flag         psa_implementation_all.status%TYPE;
   l_set_of_books_id      gl_sets_of_books.set_of_books_id%TYPE;
   l_start_date           VARCHAR2(20);
   l_post_thru_date       VARCHAR2(20);
   l_message              VARCHAR2(2000);

   -- ## FV
   fv_ar_stmt 	          VARCHAR2(4000);
   fv_package	          VARCHAR2(1);
   l_fv_pkg_chk	          c_fv_pkg_chk%rowtype;
   l_fv_profile_defined   BOOLEAN;
   l_post_det_acct_flag	  VARCHAR2(1);
   l_status               NUMBER;

   l_user_id	          fnd_user.user_id%type;
   l_resp_appl_id         fnd_application.application_id%TYPE;
   l_user_resp_id         fnd_responsibility.responsibility_id%TYPE;

   -- ## TC
   l_ussgl_option         VARCHAR2(3);

   l_errbuf               VARCHAR2(2000);
   l_retcode              VARCHAR2(1);

   PRODUCT_NOT_INSTALLED  EXCEPTION;
   FV_AR_EXCEPTION        EXCEPTION;
   PSA_MFAR_EXCEPTION     EXCEPTION;
   PSA_RESET_TC_EXCEPTION EXCEPTION;

   -- ========================= FND LOG ===========================
      l_full_path VARCHAR2(100) ;
   -- ========================= FND LOG ===========================

 BEGIN

  -- ## Default assignments done here due to GSCC standards.
     g_path                    :=  'PSA.PLSQL.PSAMFG1B.psa_ar_gl_post_pkg.';
     l_full_path               :=  g_path || 'Transfer_to_gl';
     l_post_det_acct_flag      :=  'Y';


  -- ## MFAR Process
  BEGIN

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,'  ');
      psa_utils.debug_other_string(g_state_level,l_full_path,' Starting PSA Code hook PSAMFG1B for MFAR');
      psa_utils.debug_other_string(g_state_level,l_full_path,'  ');
      psa_utils.debug_other_string(g_state_level,l_full_path,' PARAMETERS :');
      psa_utils.debug_other_string(g_state_level,l_full_path,' ============');
      psa_utils.debug_other_string(g_state_level,l_full_path,' p_start_date         -->' || p_start_date );
      psa_utils.debug_other_string(g_state_level,l_full_path,' p_post_thru_date     -->' || p_post_thru_date);
      psa_utils.debug_other_string(g_state_level,l_full_path,' p_parent_req_id      -->' || p_parent_req_id);
      psa_utils.debug_other_string(g_state_level,l_full_path,' p_posting_control_id -->' || p_posting_control_id);
      psa_utils.debug_other_string(g_state_level,l_full_path,' p_summary_flag       -->' || p_summary_flag);
   -- ========================= FND LOG ===========================

   p_status_code     := 'F';
   l_set_of_books_id := psa_mfar_utils.get_ar_sob_id;
   l_psa_feature     := 'MFAR';
   l_start_date      := TO_CHAR (p_start_date,    'YYYY/MM/DD');
   l_post_thru_date  := TO_CHAR (p_post_thru_date,'YYYY/MM/DD');
   fnd_profile.get ('ORG_ID', l_org_id);

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,'                           ');
      psa_utils.debug_other_string(g_state_level,l_full_path,' OTHER DEFAULTED VARIABLES ');
      psa_utils.debug_other_string(g_state_level,l_full_path,' ========================= ');
      psa_utils.debug_other_string(g_state_level,l_full_path,' l_org_id              --> ' || l_org_id );
      psa_utils.debug_other_string(g_state_level,l_full_path,' l_set_of_books_id     --> ' || l_set_of_books_id);
      psa_utils.debug_other_string(g_state_level,l_full_path,' l_start_date          --> ' || l_start_date);
      psa_utils.debug_other_string(g_state_level,l_full_path,' l_post_thru_date      --> ' || l_post_thru_date);
      psa_utils.debug_other_string(g_state_level,l_full_path,'                           ');
      psa_utils.debug_other_string(g_state_level,l_full_path,' PROCESS :                 ');
      psa_utils.debug_other_string(g_state_level,l_full_path,' =========                 ');
      psa_utils.debug_other_string(g_state_level,l_full_path,'                           ');
      psa_utils.debug_other_string(g_state_level,l_full_path,' TRANSFER_TO_GL ##> Checking MFAR is installed ');
   -- ========================= FND LOG ===========================


   -- Ensure that the FV_AR_PKG package is installed and valid
   OPEN  c_fv_pkg_chk;
   FETCH c_fv_pkg_chk INTO l_fv_pkg_chk;
   CLOSE c_fv_pkg_chk;

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,
                                   ' l_fv_pkg_chk.fv_package --> ' || l_fv_pkg_chk.fv_package);
   -- ========================= FND LOG ===========================

   IF l_fv_pkg_chk.fv_package = 'Y' THEN

      --
      -- Fetch profile option value for FV: Post Detailed Receipt Accounting
      --
      l_user_id      := FND_GLOBAL.user_id;
      l_resp_appl_id := FND_GLOBAL.resp_appl_id;
      l_user_resp_id := FND_GLOBAL.RESP_ID;

      FND_PROFILE.GET_SPECIFIC('FV_POST_DETAIL_REC_ACCOUNTING',
                               l_user_id,
                               l_user_resp_id,
                               l_resp_appl_id,
                               l_post_det_acct_flag,
                               l_fv_profile_defined);

      -- ========================= FND LOG ===========================
         psa_utils.debug_other_string(g_state_level,l_full_path,
                                   ' l_post_det_acct_flag --> ' || l_post_det_acct_flag);
      -- ========================= FND LOG ===========================

      IF l_post_det_acct_flag = 'N' THEN
         -- ========================= FND LOG ===========================
            psa_utils.debug_other_string(g_state_level,l_full_path,'    ');
            psa_utils.debug_other_string(g_state_level,l_full_path,' TRANSFER_TO_GL ##> Calling FV_AR_PKG ');
         -- ========================= FND LOG ===========================

         fv_ar_stmt :=
                'BEGIN FV_AR_PKG.delete_offsetting_unapp(:p_posting_control_id, :p_set_of_books_id, :p_status); END;';

         EXECUTE IMMEDIATE fv_ar_stmt
                       USING IN p_posting_control_id, IN l_set_of_books_id, OUT l_status;

         -- 0 (zero)/Null is success
         -- 1 is failure

         IF l_status = 1 THEN
            RAISE fv_ar_exception;
         END IF;

       -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path,'TRANSFER_TO_GL##> END of FV Processing ');
          psa_utils.debug_other_string(g_state_level,l_full_path,'      ');
       -- ========================= FND LOG ===========================

      END IF;
   END IF;

   -- ## checking whether PSA is installed
   IF (psa_implementation.get (P_ORG_ID       => l_org_id,
                               P_PSA_FEATURE  => l_psa_feature,
                               P_ENABLED_FLAG => l_enabled_flag)) THEN

   /*
   ## If the IF LOOP is true that means there is a record for this org id
   ## in psa_implementation_v but it does not mean the product is enabled.
   ## The p_enabled_flag will show whether the product is installed or not
   */

      IF NVL(l_enabled_flag,'N') = 'N' THEN
         RAISE product_not_installed;
      END IF;

   ELSE
      RAISE product_not_installed;
   END IF;

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,' TRANSFER_TO_GL ##> MFAR available');
      psa_utils.debug_other_string(g_state_level, l_full_path,
                                ' TRANSFER_TO_GL ##> Calling MFAR Transfer to GL --> PSA_xfr_to_gl_pkg.Transfer_to_gl');
      psa_utils.debug_other_string(g_state_level,l_full_path,'  ');
   -- ========================= FND LOG ===========================

   PSA_xfr_to_gl_pkg.Transfer_to_gl( errbuf               => l_errbuf,
                                     retcode              => l_retcode,
                                     p_set_of_books_id    => l_set_of_books_id,
                                     p_gl_date_from       => l_start_date,
                                     p_gl_date_to         => l_post_thru_date,
                                     p_gl_posted_date     => trunc(sysdate),
                                     p_parent_req_id      => p_parent_req_id,
                                     p_summary_flag       => p_summary_flag,
                                     p_pst_ctrl_id        => p_posting_control_id);

   -- ========================= FND LOG ===========================
      psa_utils.debug_other_string(g_state_level,l_full_path,' l_retcode --> ' || l_retcode);
   -- ========================= FND LOG ===========================

  IF  l_retcode = 'F' THEN
       RAISE PSA_MFAR_EXCEPTION;
  END IF;

  p_status_code := 'S';

 EXCEPTION
   WHEN product_not_installed THEN
        p_status_code := 'S';
 	l_message     := 'EXCEPTION - PRODUCT_NOT_INSTALLED PACKAGE -  PSA_AR_GL_POST_PKG.TRANSFER_TO_GL - ';
        -- ========================= FND LOG ===========================
        psa_utils.debug_other_string(g_excep_level,l_full_path,'  ');
        psa_utils.debug_other_string(g_excep_level,l_full_path,l_message);
        psa_utils.debug_other_string(g_excep_level,l_full_path,'  ');
        -- ========================= FND LOG ===========================

   WHEN fv_ar_exception THEN

        p_status_code := 'F';
        fnd_message.set_name ('AR', 'GENERIC_MESSAGE');
        fnd_message.set_token ('GENERIC_TEXT', 'EXCEPTION - FV_AR_EXCEPTION PACKAGE -  PSA_AR_GL_POST_PKG.TRANSFER_TO_GL - '|| sqlerrm);
        -- ========================= FND LOG ===========================
        psa_utils.debug_other_msg(g_excep_level,l_full_path,FALSE);
        -- ========================= FND LOG ===========================
        l_message := fnd_message.get;
        -- ========================= FND LOG ===========================
        psa_utils.debug_other_string(g_excep_level,l_full_path,' ');
        psa_utils.debug_other_string(g_excep_level,l_full_path,l_message);
        psa_utils.debug_other_string(g_excep_level,l_full_path,' ');
        -- ========================= FND LOG ===========================

   WHEN PSA_MFAR_EXCEPTION THEN
        p_status_code := 'F';
        l_message := 'EXCEPTION - PSA_MFAR_EXCEPTION PACKAGE - PSA_AR_GL_POST_PKG.TRANSFER_TO_GL - ';

        -- ========================= FND LOG ===========================
        psa_utils.debug_other_string(g_excep_level,l_full_path,' ');
        psa_utils.debug_other_string(g_excep_level,l_full_path,l_message);
        psa_utils.debug_other_string(g_excep_level,l_full_path,' ');
        -- ========================= FND LOG ===========================

   WHEN OTHERS THEN

        p_status_code := 'F';
        fnd_message.set_name ('AR', 'GENERIC_MESSAGE');
        fnd_message.set_token ('GENERIC_TEXT', 'EXCEPTION - OTHERS PACKAGE -  PSA_AR_GL_POST_PKG.TRANSFER_TO_GL - '|| sqlerrm);
        -- ========================= FND LOG ===========================
        psa_utils.debug_other_msg(g_unexp_level,l_full_path,FALSE);
        -- ========================= FND LOG ===========================
        l_message := fnd_message.get;
        -- ========================= FND LOG ===========================
        psa_utils.debug_other_string(g_excep_level,l_full_path,' ');
        psa_utils.debug_other_string(g_excep_level,l_full_path,l_message);
        psa_utils.debug_other_string(g_excep_level,l_full_path,' ');
        -- ========================= FND LOG ===========================

  END;  -- ## End MFAR process.

  /* ###################### RESET TRANSACTION CODES ########################## */

  BEGIN -- ## Reset Transaction Codes.

   /*
   ## IF MFAR process gets completed successfully then
   ## proceed with reset TC, because based on the
   ## return status, ARGLTP will commit or roll
   */

   IF p_status_code = 'S' THEN

      p_status_code := 'F';
      fnd_profile.get ('USSGL_OPTION', l_ussgl_option);

     -- ========================= FND LOG ===========================
       psa_utils.debug_other_string(g_state_level,l_full_path,'  ');
       psa_utils.debug_other_string(g_state_level,l_full_path,
                                ' TRANSFER_TO_GL ##> START RESET TRANSACTION CODES ');
       psa_utils.debug_other_string(g_state_level,l_full_path,'  ');
       psa_utils.debug_other_string(g_state_level,l_full_path,' l_ussgl_option --> ' || l_ussgl_option);
    -- ========================= FND LOG ===========================

    IF l_ussgl_option = 'Y' THEN

       -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_state_level,l_full_path,
                                ' TRANSFER_TO_GL ##> Calling PSA_AR_GL_INTERFACE.reset_transaction_codes ');
       -- ========================= FND LOG ===========================

       PSA_AR_GL_INTERFACE.reset_transaction_codes (err_buf              => l_errbuf,
                                                    ret_code             => l_retcode,
                                                    p_pstctrl_id         => p_posting_control_id);

       -- ========================= FND LOG ===========================
          psa_utils.debug_other_string(g_state_level,l_full_path,' l_retcode --> ' || l_retcode);
       -- ========================= FND LOG ===========================

       IF  l_retcode = 'F' THEN
           RAISE PSA_RESET_TC_EXCEPTION;
       END IF;

    END IF;
    p_status_code := 'S';

   END IF;

  EXCEPTION
   WHEN PSA_RESET_TC_EXCEPTION THEN

        p_status_code := 'F';
        l_message := 'EXCEPTION - PSA_RESET_TC_EXCEPTION PACKAGE - PSA_AR_GL_POST_PKG.TRANSFER_TO_GL - ' || sqlerrm;

        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_excep_level,l_full_path,' ');
           psa_utils.debug_other_string(g_excep_level,l_full_path,l_message);
           psa_utils.debug_other_string(g_excep_level,l_full_path,' ');
        -- ========================= FND LOG ===========================

    WHEN OTHERS THEN

        p_status_code := 'F';
        fnd_message.set_name ('AR', 'GENERIC_MESSAGE');
        fnd_message.set_token ('GENERIC_TEXT', 'EXCEPTION - OTHERS PACKAGE -  PSA_AR_GL_POST_PKG.TRANSFER_TO_GL - '|| sqlerrm);
        -- ========================= FND LOG ===========================
           psa_utils.debug_other_msg(g_unexp_level,l_full_path,FALSE);
        -- ========================= FND LOG ===========================
        l_message := fnd_message.get;
        -- ========================= FND LOG ===========================
           psa_utils.debug_other_string(g_excep_level,l_full_path,' ');
           psa_utils.debug_other_string(g_excep_level,l_full_path,l_message);
           psa_utils.debug_other_string(g_excep_level,l_full_path,' ');
        -- ========================= FND LOG ===========================
  END;  -- ## End  Reset Transaction Codes.

 END transfer_to_gl;
END psa_ar_gl_post_pkg;

/
