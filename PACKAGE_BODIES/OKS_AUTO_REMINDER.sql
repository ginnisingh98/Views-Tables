--------------------------------------------------------
--  DDL for Package Body OKS_AUTO_REMINDER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_AUTO_REMINDER" AS
/* $Header: OKSARNWB.pls 120.26.12010000.8 2009/05/19 11:49:08 vgujarat ship $ */
   g_pkg_name                     CONSTANT VARCHAR2 (200)
                                                       := 'OKS_AUTO_REMINDER';
   g_level_procedure              CONSTANT NUMBER := fnd_log.level_procedure;
   g_module                       CONSTANT VARCHAR2 (250)
                                         := 'oks.plsql.' ||
                                            g_pkg_name ||
                                            '.';
   g_application_id               CONSTANT NUMBER := 515;   -- OKS Application
   g_false                        CONSTANT VARCHAR2 (1) := fnd_api.g_false;
   g_true                         CONSTANT VARCHAR2 (1) := fnd_api.g_true;
   g_ret_sts_success              CONSTANT VARCHAR2 (1)
                                                  := fnd_api.g_ret_sts_success;
   g_ret_sts_error                CONSTANT VARCHAR2 (1)
                                                    := fnd_api.g_ret_sts_error;
   g_ret_sts_unexp_error          CONSTANT VARCHAR2 (1)
                                              := fnd_api.g_ret_sts_unexp_error;

   FUNCTION get_org_context
      RETURN NUMBER
   IS
   BEGIN
      okc_context.set_okc_org_context;
      RETURN okc_context.get_okc_org_id;
   END;

   FUNCTION get_org_id
      RETURN VARCHAR2
   IS
   BEGIN
      okc_context.set_okc_org_context;
      RETURN TO_CHAR (okc_context.get_okc_org_id);
   END;

   FUNCTION get_org_context (
      p_org_id                                 NUMBER
   )
      RETURN NUMBER
   IS
   BEGIN
      okc_context.set_okc_org_context (p_org_id                           => p_org_id);
      RETURN okc_context.get_okc_org_id;
   END;

   PROCEDURE get_qto_email (
      p_chr_id                        IN       NUMBER,
      x_qto_email                     OUT NOCOPY VARCHAR2
   )
   IS
      CURSOR l_qto_details_csr (
         p_chr_id                                 NUMBER
      )
      IS
         SELECT quote_to_email_id
           FROM oks_k_headers_b
          WHERE chr_id = p_chr_id;

      CURSOR l_emailaddress_csr (
         p_contactpoint_id                        NUMBER
      )
      IS
         SELECT email_address
           FROM okx_contact_points_v
          WHERE contact_point_id = p_contactpoint_id;

      l_email_address                         VARCHAR2 (2000)
                                                        := okc_api.g_miss_char;
      l_contact_id                            NUMBER;
      l_api_name                     CONSTANT VARCHAR2 (30) := 'get_QTO_email';
   BEGIN
      OPEN l_qto_details_csr (p_chr_id);

      FETCH l_qto_details_csr
       INTO l_contact_id;

      IF l_qto_details_csr%FOUND
      THEN
         OPEN l_emailaddress_csr (l_contact_id);

         FETCH l_emailaddress_csr
          INTO l_email_address;

         IF l_emailaddress_csr%NOTFOUND
         THEN
            l_email_address            := okc_api.g_miss_char;
         END IF;

         CLOSE l_emailaddress_csr;
      END IF;

      CLOSE l_qto_details_csr;

      x_qto_email                := l_email_address;
   EXCEPTION
      WHEN OTHERS
      THEN
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
   END;

   -- Traverse thru the global defaults and get the template set id
   -- associated for this contract
   PROCEDURE get_party_id (
      p_chr_id                        IN       NUMBER,
      x_party_id                      OUT NOCOPY NUMBER
   )
   IS
      CURSOR csr_party_dtls
      IS
         SELECT r.object1_id1 AS party_id
           FROM okc_k_party_roles_b r,
                hz_parties p
          WHERE p.party_id = r.object1_id1
            AND r.jtot_object1_code = 'OKX_PARTY'
            AND r.rle_code IN
                   ('CUSTOMER', 'SUBSCRIBER')
                                         -- gets only the CUSTOMER /SUBSCRIBER
            AND r.cle_id IS NULL
            AND r.chr_id = p_chr_id;
/*
        CURSOR l_CustPartyId_csr IS
               SELECT distinct hp.party_id
               FROM okc_k_party_roles_b okpr,
                    hz_parties hp,
                   --NPALEPU
                    --08-AUG-2005
                    --TCA Project
                    --Replaced hz_party_relationships table with hz_relationships table
                    -- hz_party_relationships hpr --
                    hz_relationships hpr
                    --END NPALEPU
               WHERE okpr.rle_code = 'CUSTOMER'
               AND jtot_object1_code = 'OKX_PARTY'
               AND okpr.object1_id1 = hp.party_id
               AND hpr.object_id = hp.party_id
               AND okpr.dnz_chr_id = p_chr_id;
*/
   BEGIN
/*
        OPEN l_CustPartyId_csr;
        FETCH l_CustPartyId_csr into x_party_id;
        CLOSE l_CustPartyId_csr;
*/
      OPEN csr_party_dtls;

      FETCH csr_party_dtls
       INTO x_party_id;

      CLOSE csr_party_dtls;
   END get_party_id;

   PROCEDURE get_qtoparty_id (
      p_chr_id                        IN       NUMBER,
      x_party_id                      OUT NOCOPY NUMBER
   )
   IS
/*
        CURSOR l_QtoPartyId_csr IS
        SELECT hzr.party_id
        FROM oks_k_headers_b kh,
             --NPALEPU
             --08-AUG-2005
             --TCA Project
             --Replaced hz_party_relationships table with hz_relationships table and ra_hcontacts with OKS_RA_HCONTACTS_V
              --Replaced hzr.party_relationship_id column with hzr.relationship_id column and added new conditions
             --ra_hcontacts rah,
             hz_party_relationships hzr
        WHERE kh.chr_id  = p_chr_id
        AND kh.quote_to_contact_id = rah.contact_id
        AND rah.party_relationship_id = hzr.party_relationship_id;
             OKS_RA_HCONTACTS_V rah,
             hz_relationships hzr
        WHERE kh.chr_id  = p_chr_id
        AND kh.quote_to_contact_id = rah.contact_id
        AND rah.party_relationship_id = hzr.relationship_id
        AND hzr.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
        AND hzr.OBJECT_TABLE_NAME = 'HZ_PARTIES'
        AND hzr.DIRECTIONAL_FLAG = 'F';
        --END NPALEPU
*/

      -- skekkar
      l_person_party_id                       oks_k_headers_b.person_party_id%TYPE;
      l_quote_to_contact_id                   oks_k_headers_b.quote_to_contact_id%TYPE;

      CURSOR csr_person_party_id
      IS
         SELECT ks.person_party_id,
                ks.quote_to_contact_id
           FROM oks_k_headers_b ks
          WHERE ks.chr_id = p_chr_id;

      CURSOR csr_qtc_person_party_id (
         p_quote_to_contact_id           IN       NUMBER
      )
      IS
         SELECT hzp.party_id
           FROM hz_cust_account_roles car,
                hz_relationships rln,
                hz_parties hzp
          WHERE car.cust_account_role_id = p_quote_to_contact_id
            AND car.party_id = rln.party_id
            AND rln.subject_id = hzp.party_id
            AND car.role_type = 'CONTACT'
            AND rln.directional_flag = 'F'
            AND rln.content_source_type = 'USER_ENTERED';
   BEGIN
/*
        OPEN l_QtoPartyId_csr;
        FETCH l_QtoPartyId_csr into x_party_id;
        CLOSE l_QtoPartyId_csr;
*/

      -- Get the Person Party Id and quote_to_contact_id from oks_k_headers_b
      OPEN csr_person_party_id;

      FETCH csr_person_party_id
       INTO l_person_party_id,
            l_quote_to_contact_id;

      CLOSE csr_person_party_id;

      -- if the person_party_id is NULL then get person_party_id for quote_to_contact_id
      IF l_person_party_id IS NULL
      THEN
         OPEN csr_qtc_person_party_id
                              (p_quote_to_contact_id              => l_quote_to_contact_id);

         FETCH csr_qtc_person_party_id
          INTO l_person_party_id;

         CLOSE csr_qtc_person_party_id;
      END IF;

      x_party_id                 := l_person_party_id;
   END get_qtoparty_id;

/*
   PROCEDURE create_user (
                   p_user_name         IN         VARCHAR2,
                   x_password          OUT NOCOPY VARCHAR2,
                   x_return_status     OUT NOCOPY VARCHAR2,
                   x_err_msg           OUT NOCOPY VARCHAR2
       ) IS

       l_counter        NUMBER;
       l_err_msg        OKS_AUTO_REMINDER.message_rec_tbl;

   BEGIN

       OKS_AUTO_REMINDER.create_user(
                            p_user_name         => p_user_name,
                            x_password          => x_password,
                            x_return_status     => x_return_status,
                            x_err_msg           => l_err_msg
                          );

       IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN

          l_counter := l_err_msg.FIRST;
          IF l_counter > 0 THEN
             LOOP
                x_err_msg := x_err_msg || ';' || l_err_msg(l_counter).description;

                EXIT WHEN l_counter = l_err_msg.LAST;
                l_counter := l_err_msg.next(l_counter);
             END LOOP;
          END IF;
      END IF;

   EXCEPTION
        WHEN OTHERS THEN
           x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
           OKC_API.set_message ( G_APP_NAME,
                                 G_UNEXPECTED_ERROR,
                                 G_SQLCODE_TOKEN,
                                 SQLCODE,
                                 G_SQLERRM_TOKEN,
                                 SQLERRM
                               );

   END;
*/

   /*
SSO Changes for 11.5.10 CU3

Pseudo Logic:
-------------
Step 1: Get the person_party_id for quote to contact id

Step 2: Get the user_name and person_party_id in fnd_user where user_name is quote to contact email address
    Case A:  Record found in fnd_user
            If person_party_id in fnd_user is null then
                UPDATE fnd_user record with person_party_id from step 1 above
            If person_party_id in fnd_user is NOT the same as person_party_id from step 1 above
                      RAISE error here
            If person_party_id in fnd_user = person_party_id from step 1 above
                        we are fine, do nothing

    Case B:  Record NOT found in fnd_user
        Call FND_USER_PKG.TestUserName
           --@ TestUserName() returns:
           --@ USER_OK_CREATE                 constant pls_integer := 0;
           --@ USER_INVALID_NAME              constant pls_integer := 1;
           --@ USER_EXISTS_IN_FND             constant pls_integer := 2;
           --@ USER_SYNCHED                   constant pls_integer := 3;
           --@ USER_EXISTS_NO_LINK_ALLOWED    constant pls_integer := 4;
          IF l_test_user IN (0,3) THEN
            CALL FND_USER_PKG.CreateUserIdParty
            Note : Call FND_CRYPTO for generating the password (track bug 4358822)
            FND_USER_RESP_GROUPS_API.insert_assignment with responsibility as 'OKS_ERN_WEB'
          ELSE -- l_test_user <> 0 ,3
                -- error, raise exception
                RAISE FND_API.G_EXC_ERROR;
          END IF;

*/
   PROCEDURE create_user (
      p_user_name                     IN       VARCHAR2,
      p_contract_id                   IN       NUMBER,
      x_password                      OUT NOCOPY VARCHAR2,
      x_return_status                 OUT NOCOPY VARCHAR2,
      x_err_msg                       OUT NOCOPY oks_auto_reminder.message_rec_tbl
   )
   IS
      CURSOR l_user_csr (
         p_user_name                     IN       VARCHAR2
      )
      IS
         SELECT user_id,
                person_party_id
           FROM fnd_user
          WHERE UPPER (user_name) = p_user_name
            AND SYSDATE BETWEEN NVL (start_date, SYSDATE)
                            AND NVL (end_date, SYSDATE);

      CURSOR l_user_resp_csr (
         p_user_id                       IN       NUMBER,
         p_responsibility_id             IN       NUMBER
      )
      IS
         SELECT user_id
           FROM fnd_user_resp_groups
          WHERE user_id = p_user_id
            AND responsibility_id = p_responsibility_id
            AND SYSDATE BETWEEN NVL (start_date, SYSDATE)
                            AND NVL (end_date, SYSDATE);

      CURSOR l_resp_csr (
         p_resp_key                               VARCHAR2
      )
      IS
         SELECT responsibility_id
           FROM fnd_responsibility
          WHERE responsibility_key = p_resp_key
            AND SYSDATE BETWEEN NVL (start_date, SYSDATE)
                            AND NVL (end_date, SYSDATE);

      CURSOR l_security_grp_csr (
         p_security_grp_key                       VARCHAR2
      )
      IS
         SELECT security_group_id
           FROM fnd_security_groups
          WHERE security_group_key = p_security_grp_key;

        -- modified cursor to always generate minimum length password
      -- as defined by the Signon Password Length profile option.
      -- Bug fix 4228115
      CURSOR l_password_csr
      IS
         SELECT CONCAT
                   (DBMS_RANDOM.STRING
                          ('l',
                           (NVL
                               (fnd_profile.VALUE ('SIGNON_PASSWORD_LENGTH'),
                                7) -
                            3
                           )),
                    ROUND (DBMS_RANDOM.VALUE (100, 999)))
           FROM DUAL;

      l_return_status                         VARCHAR2 (1)
                                                  := okc_api.g_ret_sts_success;
      l_user_name                             VARCHAR2 (100);
      l_user_id                               NUMBER (15);
      l_temp_user_id                          NUMBER (15);
      l_responsibility_id                     NUMBER (15);
      l_security_grp_id                       NUMBER (15);
      l_return_value                          BOOLEAN;
      l_count                                 BINARY_INTEGER := 1;

-- SSO changes
      CURSOR csr_qtc_person_party_id
      IS
         SELECT hzp.party_id
           FROM hz_cust_account_roles car,
                hz_relationships rln,
                hz_parties hzp,
                oks_k_headers_b ks
          WHERE ks.quote_to_contact_id = car.cust_account_role_id
            AND car.party_id = rln.party_id
            AND rln.subject_id = hzp.party_id
            AND car.role_type = 'CONTACT'
            AND rln.directional_flag = 'F'
            AND rln.content_source_type = 'USER_ENTERED'
            AND ks.chr_id = p_contract_id;

      l_api_name                     CONSTANT VARCHAR2 (30) := 'create_user';
      l_test_user                             PLS_INTEGER;
      l_qtc_person_party_id                   fnd_user.person_party_id%TYPE;
      l_fnd_person_party_id                   fnd_user.person_party_id%TYPE;
      l_row_notfound                          BOOLEAN := TRUE;
--
   BEGIN
      -- start debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '100: Entered ' ||
                         g_pkg_name ||
                         '.' ||
                         l_api_name
                        );
      END IF;

      --  Initialize API return status to success
      x_return_status            := fnd_api.g_ret_sts_success;

      OPEN csr_qtc_person_party_id;

      FETCH csr_qtc_person_party_id
       INTO l_qtc_person_party_id;

      CLOSE csr_qtc_person_party_id;

      l_user_name                := UPPER (TRIM (p_user_name));

      OPEN l_user_csr (l_user_name);

      FETCH l_user_csr
       INTO l_user_id,
            l_fnd_person_party_id;

      l_row_notfound             := l_user_csr%NOTFOUND;

      CLOSE l_user_csr;

      IF l_row_notfound
      THEN
         -- create a NEW FND USER
         -- Call the testUserName pkg
         --@ TestUserName() returns:
         --@ USER_OK_CREATE                 constant pls_integer := 0;
         --@ USER_INVALID_NAME              constant pls_integer := 1;
         --@ USER_EXISTS_IN_FND             constant pls_integer := 2;
         --@ USER_SYNCHED                   constant pls_integer := 3;
         --@ USER_EXISTS_NO_LINK_ALLOWED    constant pls_integer := 4;
         l_test_user                :=
                       fnd_user_pkg.testusername (x_user_name                        => l_user_name);

         IF l_test_user IN (0, 3)
         THEN
            IF l_test_user = 0
            THEN
               -- ok to create a new user
               x_password                 :=
                  DBMS_RANDOM.STRING
                       ('l',
                        (NVL (fnd_profile.VALUE ('SIGNON_PASSWORD_LENGTH'),
                              7) -
                         3
                        )) ||
                  ROUND (DBMS_RANDOM.VALUE (100, 999));
               l_user_id                  :=
                  fnd_user_pkg.createuseridparty
                                 (x_user_name                        => UPPER
                                                                           (TRIM
                                                                               (p_user_name)),
                                  x_owner                            => 'CUST',
                                  x_unencrypted_password             => x_password,
                                  x_description                      => 'Electronic renewals User',
                                  x_email_address                    => UPPER
                                                                           (TRIM
                                                                               (p_user_name)),
                                  x_person_party_id                  => l_qtc_person_party_id
                                 );
            ELSE                                            -- l_test_user = 3
               -- USER_SYNCHED                   constant pls_integer := 3;
               -- Call the FND_USER_PKG.CreateUserIdParty WITHOUT password as password exists in OID
               -- in Notification, put the password as *******'
               l_user_id                  :=
                  fnd_user_pkg.createuseridparty
                                (x_user_name                        => UPPER
                                                                          (TRIM
                                                                              (p_user_name)),
                                 x_owner                            => 'SEED',
                                 x_description                      => 'Electronic renewals User',
                                 x_email_address                    => UPPER
                                                                          (TRIM
                                                                              (p_user_name)),
                                 x_person_party_id                  => l_qtc_person_party_id
                                );
               x_password                 := '******';
            END IF;                                    -- l_test_user = 0 or 3

            IF l_user_id IS NOT NULL
            THEN
               -- assign responsibility to user created
               OPEN l_resp_csr (p_resp_key                         => g_ern_web_responsibility);

               FETCH l_resp_csr
                INTO l_responsibility_id;

               CLOSE l_resp_csr;

               OPEN l_security_grp_csr ('STANDARD');

               FETCH l_security_grp_csr
                INTO l_security_grp_id;

               CLOSE l_security_grp_csr;

               fnd_user_resp_groups_api.insert_assignment
                                   (user_id                            => l_user_id,
                                    responsibility_id                  => l_responsibility_id,
                                    responsibility_application_id      => 515,
                                    security_group_id                  => l_security_grp_id,
                                    description                        => 'Electronic renewals User',
                                    start_date                         => SYSDATE,
                                    end_date                           => NULL
                                   );
               l_return_value             :=
                  fnd_profile.SAVE (x_name                             => 'APPLICATIONS_HOME_PAGE',
                                    x_value                            => 'PHP',
                                    x_level_name                       => 'USER',
                                    x_level_value                      => TO_CHAR
                                                                             (l_user_id)
                                   );

               IF l_return_value
               THEN
                  RETURN;
               ELSE
                  -- error in fnd_profile.save
                  fnd_message.set_name ('OKS', 'OKS_SSO_FND_PROFILE_ERROR');
                  x_err_msg (l_count).description := fnd_message.get;
                  RAISE fnd_api.g_exc_error;
               END IF;
            ELSE
               -- l_user_id is null, raise exception
               fnd_message.set_name ('OKS', 'OKS_SSO_USER_ID_NULL');
               x_err_msg (l_count).description := fnd_message.get;
               RAISE fnd_api.g_exc_error;
            END IF;                                   -- l_user_id is not null
         ELSE                                           -- l_test_user <> 0 ,3
            -- error, raise exception
            fnd_message.set_name ('OKS', 'OKS_SSO_TEST_USER_ERROR');
            fnd_message.set_token ('RETURN_VAL', l_test_user);
            x_err_msg (l_count).description := fnd_message.get;
            RAISE fnd_api.g_exc_error;
         END IF;                                          -- l_test_user check
      ELSE            -- l_row_notfound is false i.e record exists in fnd_user
         x_password                 := '******';
         IF l_fnd_person_party_id IS NULL
         THEN
            fnd_user_pkg.updateuserparty
                                  (x_user_name                        => UPPER
                                                                            (TRIM
                                                                                (p_user_name)),
                                   x_owner                            => 'CUST',
                                   x_person_party_id                  => l_qtc_person_party_id
                                  );
         ELSIF l_fnd_person_party_id <> l_qtc_person_party_id
         THEN
            -- fnd_user.person_party_id does NOT match oks_person_party_id
            fnd_message.set_name ('OKS', 'OKS_SSO_PERSON_PARTY_ERROR');
            x_err_msg (l_count).description := fnd_message.get;
            RAISE fnd_api.g_exc_error;
         ELSE
            -- l_fnd_person_party_id = l_qtc_person_party_id
            RETURN;
         END IF;                                      -- person_party_id check
      END IF;                                            --  IF l_row_notfound

      -- end debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '1000: Leaving ' ||
                         g_pkg_name ||
                         '.' ||
                         l_api_name
                        );
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_procedure,
                            g_module ||
                            l_api_name,
                            '2000: Leaving ' ||
                            g_pkg_name ||
                            '.' ||
                            l_api_name
                           );
         END IF;

         x_return_status            := g_ret_sts_error;
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_procedure,
                            g_module ||
                            l_api_name,
                            '3000: Leaving ' ||
                            g_pkg_name ||
                            '.' ||
                            l_api_name
                           );
         END IF;

         x_return_status            := g_ret_sts_unexp_error;
      WHEN OTHERS
      THEN
         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_procedure,
                            g_module ||
                            l_api_name,
                            '4000: Leaving ' ||
                            g_pkg_name ||
                            '.' ||
                            l_api_name
                           );
         END IF;

         x_return_status            := okc_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
   END create_user;

   PROCEDURE update_contract_status (
      p_chr_id                        IN       VARCHAR2,
      p_status                        IN       VARCHAR2,
      x_return_status                 OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name                     CONSTANT VARCHAR2 (30)
                                                  := 'update_contract_status';
   -- bug 5161013 check STE_CODE for the contract
    CURSOR csr_k_ste_code IS
    SELECT s.ste_code
      FROM okc_k_headers_all_b  k,
           okc_statuses_b s
     WHERE k.sts_code = s.code
       AND k.id = p_chr_id;

    l_ste_code           okc_statuses_b.ste_code%TYPE;

   BEGIN
     -- bug 5161013
     -- check if the STE_CODE of the contract is ENTERED and only then update the status
      OPEN csr_k_ste_code;
        FETCH csr_k_ste_code INTO l_ste_code;
      CLOSE csr_k_ste_code;

      IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level  THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||l_api_name,
			 'l_ste_code : ' ||l_ste_code||
                         ' (p_chr_id=> ' ||p_chr_id ||
                         ' p_status=>' ||p_status ||')'
                         );
      END IF;

      IF l_ste_code = 'ENTERED' THEN
          oks_auto_reminder.update_contract_status
                                          (p_chr_id                           => TO_NUMBER
                                                                                    (p_chr_id),
                                           p_status                           => p_status,
                                           x_return_status                    => x_return_status
                                          );
      END IF;

   EXCEPTION
      WHEN OTHERS
      THEN
         x_return_status            := okc_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
   END;

   PROCEDURE update_contract_status (
      p_chr_id                        IN       NUMBER,
      p_status                        IN       VARCHAR2,
      x_return_status                 OUT NOCOPY VARCHAR2
   )
   IS
      l_api_version                  CONSTANT NUMBER := 1.0;
      l_api_name                     CONSTANT VARCHAR2 (50)
                                                  := 'update_contract_status';
      l_chrv_rec                              okc_contract_pub.chrv_rec_type;
      x_chrv_rec                              okc_contract_pub.chrv_rec_type;
      l_clev_rec                              okc_contract_pub.clev_rec_type;
      x_clev_rec                              okc_contract_pub.clev_rec_type;
      l_return_status                         VARCHAR2 (1)
                                                 := okc_api.g_ret_sts_success;
      l_msg_data                              VARCHAR2 (2000);
      l_msg_count                             NUMBER;
      l_status_code                           VARCHAR2(40);

      CURSOR l_lines_csr
      IS
         SELECT ID,
                sts_code
           FROM okc_k_lines_b
          WHERE dnz_chr_id = p_chr_id;

      /*added for bug6651207*/
      CURSOR l_lines_entered_csr
      IS    SELECT ID,
                 sts_code
           FROM okc_k_lines_b
          WHERE dnz_chr_id = p_chr_id
           AND (DATE_TERMINATED IS NULL AND DATE_CANCELLED IS NULL);

      /*start of bug8345674*/
      CURSOR c_old_sts is
      SELECT STS_CODE
        FROM OKC_K_HEADERS_ALL_B okck,
             OKC_STATUSES_B sts
       WHERE id = p_chr_id
         AND sts.code = okck.sts_code;

       l_old_sts OKC_STATUSES_B.CODE%TYPE;
       /*end of bug8345674*/

      FUNCTION GET_STATUS(pcode IN VARCHAR2) RETURN VARCHAR2
      IS
      lcode VARCHAR2(40);
      BEGIN
        SELECT STE_CODE INTO lcode FROM okc_statuses_b WHERE code = pcode;
        RETURN lcode;
        EXCEPTION
        WHEN OTHERS THEN
         RETURN pcode;
      END;

   BEGIN

    /*added for bug7535583*/
 	         l_status_code := get_status(p_status);

      IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         'Entered ' ||
                         g_pkg_name ||
                         '.' ||
                         l_api_name ||
                         '(p_chr_id=>' ||
                         p_chr_id ||
                         'p_status=>' ||
                         p_status ||
                         ')'
                        );
      END IF;

      --  Initialize API return status to success
      x_return_status            := g_ret_sts_success;
      mo_global.init (p_appl_short_name                  => 'OKC');
      l_chrv_rec.ID              := p_chr_id;
      l_chrv_rec.sts_code        := p_status;

      IF fnd_log.level_event >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING
                      (fnd_log.level_event,
                       g_module ||
                       l_api_name ||
                       '.external_call.before',
                       'OKC_CONTRACT_PUB.update_contract_header(p_chr_id=' ||
                       p_chr_id ||
                       ')'
                      );
      END IF;

     /*modified for FP bug7607862*/
 	      IF l_status_code = 'CANCELLED' THEN
 	        l_chrv_rec.datetime_cancelled := SYSDATE;
 	        l_chrv_rec.term_cancel_source := 'CUSTOMER';
 	        l_chrv_rec.trn_code := 'NFC';
 	        l_chrv_rec.new_ste_code := 'CANCELLED';
     /*commented and modified for bug8345674
 	       okc_contract_pub.update_contract_header
 	                                       (p_api_version                      => l_api_version,
 	                                        p_init_msg_list                    => okc_api.g_false,
 	                                        x_return_status                    => l_return_status,
 	                                        x_msg_count                        => l_msg_count,
 	                                        x_msg_data                         => l_msg_data,
 	                                        p_restricted_update                => okc_api.g_true,
 	                                        p_chrv_rec                         => l_chrv_rec,
 	                                        x_chrv_rec                         => x_chrv_rec
 	                                       );
     */
      /*start of bug8345674*/
      OPEN c_old_sts;
      FETCH c_old_sts INTO l_old_sts;
      CLOSE c_old_sts;

       OKS_CHANGE_STATUS_PVT.UPDATE_HEADER_STATUS (
                               x_return_status      => l_return_status,
                               x_msg_data           => l_msg_data,
                               x_msg_count          => l_msg_count,
                               p_init_msg_list      => G_FALSE,
                               p_id                 => p_chr_id,
                               p_new_sts_code       => p_status,
                               p_old_sts_code       => l_old_sts,
                               p_canc_reason_code   => 'NFC',
                               p_comments           => 'Automatic Cancellation of Contract',
                               p_term_cancel_source => 'CUSTOMER',
                               p_date_cancelled     => SYSDATE,
                               p_validate_status    => 'N') ;

       UPDATE oks_k_headers_b
          SET renewal_status = 'QUOTE_CNCLD'
        WHERE chr_id = p_chr_id;
      /*end of bug8345674*/
 	      ELSE


      okc_contract_pub.update_contract_header
                                      (p_api_version                      => l_api_version,
                                       p_init_msg_list                    => okc_api.g_false,
                                       x_return_status                    => l_return_status,
                                       x_msg_count                        => l_msg_count,
                                       x_msg_data                         => l_msg_data,
                                       p_restricted_update                => okc_api.g_false,
                                       p_chrv_rec                         => l_chrv_rec,
                                       x_chrv_rec                         => x_chrv_rec
                                      );
               END IF;

      IF fnd_log.level_event >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING
              (fnd_log.level_event,
               g_module ||
               l_api_name ||
               '.external_call.after',
               'OKC_CONTRACT_PUB.update_contract_header(x_return_status= ' ||
               l_return_status ||
               ' l_msg_count =' ||
               l_msg_count ||
               ')'
              );
      END IF;

      IF l_return_status = g_ret_sts_unexp_error
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      ELSIF l_return_status = g_ret_sts_error
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      IF fnd_log.level_event >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_event,
                         g_module ||
                         l_api_name ||
                         '.external_call.before',
                         'OKC_CONTRACT_PUB.update_contract_line - Loop begin'
                        );
      END IF;

      l_clev_rec.sts_code        := p_status;

	/*MODIFIED FOR BUG6651207*/
      IF Nvl(l_status_code,'X') = 'ENTERED' THEN
      FOR l_lines_rec IN l_lines_entered_csr
      LOOP
         l_clev_rec.ID              := l_lines_rec.ID;

         IF fnd_log.level_event >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_event,
                            g_module ||
                            l_api_name,
                            'Updating line: ' ||
                            l_lines_rec.ID
                           );
         END IF;

         okc_contract_pub.update_contract_line
                                      (p_api_version                      => l_api_version,
                                       p_init_msg_list                    => okc_api.g_false,
                                       x_return_status                    => l_return_status,
                                       x_msg_count                        => l_msg_count,
                                       x_msg_data                         => l_msg_data,
                                       p_restricted_update                => okc_api.g_false,
                                       p_clev_rec                         => l_clev_rec,
                                       x_clev_rec                         => x_clev_rec
                                      );

         IF fnd_log.level_event >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_event,
                            g_module ||
                            l_api_name,
                            'Result: ' ||
                            l_return_status
                           );
         END IF;

         IF l_return_status = g_ret_sts_unexp_error
         THEN
            RAISE fnd_api.g_exc_unexpected_error;
         ELSIF l_return_status = g_ret_sts_error
         THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      END LOOP;
    ELSE
      FOR l_lines_rec IN l_lines_csr
      LOOP
         l_clev_rec.ID              := l_lines_rec.ID;

         IF fnd_log.level_event >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_event,
                            g_module ||
                            l_api_name,
                            'Updating line: ' ||
                            l_lines_rec.ID
                           );
         END IF;
	       /*modified by sjanakir for FP bug7607862*/
 	        IF l_status_code = 'CANCELLED' THEN
	 	/*commented code here for bug8345674 as the line and subline level
	         cancellation is taken care at header level by
                OKS_CHANGE_STATUS_PVT.UPDATE_HEADER_STATUS api
 	          l_clev_rec.date_cancelled := SYSDATE;
 	          l_clev_rec.term_cancel_source := 'CUSTOMER';
 	          l_clev_rec.trn_code := 'NFC';
 	          l_clev_rec.new_ste_code := 'CANCELLED';
 	          okc_contract_pub.update_contract_line
 	                                       (p_api_version                      => l_api_version,
 	                                        p_init_msg_list                    => okc_api.g_false,
 	                                        x_return_status                    => l_return_status,
 	                                        x_msg_count                        => l_msg_count,
 	                                        x_msg_data                         => l_msg_data,
 	                                        p_restricted_update                => okc_api.g_true,
 	                                        p_clev_rec                         => l_clev_rec,
 	                                        x_clev_rec                         => x_clev_rec
 	                                       );
		*/
		   NULL;
 	         ELSE
         okc_contract_pub.update_contract_line
                                      (p_api_version                      => l_api_version,
                                       p_init_msg_list                    => okc_api.g_false,
                                       x_return_status                    => l_return_status,
                                       x_msg_count                        => l_msg_count,
                                       x_msg_data                         => l_msg_data,
                                       p_restricted_update                => okc_api.g_false,
                                       p_clev_rec                         => l_clev_rec,
                                       x_clev_rec                         => x_clev_rec
                                      );
                 END IF;

         IF fnd_log.level_event >= fnd_log.g_current_runtime_level
         THEN
            fnd_log.STRING (fnd_log.level_event,
                            g_module ||
                            l_api_name,
                            'Result: ' ||
                            l_return_status
                           );
         END IF;

         IF l_return_status = g_ret_sts_unexp_error
         THEN
            RAISE fnd_api.g_exc_unexpected_error;
         ELSIF l_return_status = g_ret_sts_error
         THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      END LOOP;
    END IF; /*IF NVL(l_status_code,'X') = 'ENTERED' THEN*/

      IF fnd_log.level_event >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_event,
                         g_module ||
                         l_api_name ||
                         '.external_call.after',
                         'OKC_CONTRACT_PUB.update_contract_line - loop end'
                        );
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         fnd_msg_pub.count_and_get (p_encoded                          => 'F',
                                    p_count                            => l_msg_count,
                                    p_data                             => l_msg_data
                                   );

         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_procedure,
                            g_module ||
                            l_api_name,
                            'Leaving ' ||
                            g_pkg_name ||
                            '.' ||
                            l_api_name ||
                            ' from G_EXC_ERROR'
                           );
            fnd_log.STRING (fnd_log.level_procedure,
                            g_module ||
                            l_api_name,
                            l_msg_data
                           );
         END IF;

         x_return_status            := g_ret_sts_error;
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         fnd_msg_pub.count_and_get (p_encoded                          => 'F',
                                    p_count                            => l_msg_count,
                                    p_data                             => l_msg_data
                                   );

         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_procedure,
                            g_module ||
                            l_api_name,
                            'Leaving ' ||
                            g_pkg_name ||
                            '.' ||
                            l_api_name ||
                            ' from G_EXC_UNEXPECTED_ERROR'
                           );
            fnd_log.STRING (fnd_log.level_procedure,
                            g_module ||
                            l_api_name,
                            l_msg_data
                           );
         END IF;

         x_return_status            := g_ret_sts_unexp_error;
      WHEN OTHERS
      THEN
         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_procedure,
                            g_module ||
                            l_api_name,
                            'Leaving ' ||
                            g_pkg_name ||
                            '.' ||
                            l_api_name ||
                            ' from OTHERS sqlcode = ' ||
                            SQLCODE ||
                            ', sqlerrm = ' ||
                            SQLERRM
                           );
            fnd_msg_pub.add_exc_msg (g_pkg_name,
                                     l_api_name,
                                     SUBSTR (SQLERRM,
                                             1,
                                             240
                                            )
                                    );
         END IF;

         fnd_msg_pub.count_and_get (p_encoded                          => 'F',
                                    p_count                            => l_msg_count,
                                    p_data                             => l_msg_data
                                   );
         x_return_status            := g_ret_sts_unexp_error;
   END update_contract_status;

   PROCEDURE get_time_stats (
      p_start_date                    IN       DATE,
      p_end_date                      IN       DATE,
      x_duration                      OUT NOCOPY NUMBER,
      x_period                        OUT NOCOPY VARCHAR2,
      x_return_status                 OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name                     CONSTANT VARCHAR2 (30)
                                                          := 'get_time_stats';
      l_duration                              NUMBER;
      l_period                                VARCHAR2 (10);
      l_return_status                         VARCHAR2 (1)
                                                 := okc_api.g_ret_sts_success;
   BEGIN
      IF p_start_date > p_end_date
      THEN
         okc_time_util_pub.get_duration (p_start_date                       => p_end_date,
                                         p_end_date                         => p_start_date,
                                         x_duration                         => l_duration,
                                         x_timeunit                         => l_period,
                                         x_return_status                    => l_return_status
                                        );
         x_duration                 := l_duration;
      ELSE
         okc_time_util_pub.get_duration (p_start_date                       => p_start_date,
                                         p_end_date                         => p_end_date,
                                         x_duration                         => l_duration,
                                         x_timeunit                         => l_period,
                                         x_return_status                    => l_return_status
                                        );
         x_duration                 := l_duration *
                                       -1;
      END IF;

      IF l_return_status <> okc_api.g_ret_sts_success
      THEN
         x_duration                 := okc_api.g_miss_num;
         x_period                   := okc_api.g_miss_char;
      ELSE
         x_period                   := l_period;
      END IF;

      x_return_status            := l_return_status;
   EXCEPTION
      WHEN OTHERS
      THEN
         x_return_status            := okc_api.g_ret_sts_error;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
   END;

   PROCEDURE get_duration (
      p_start_date                    IN       DATE,
      p_end_date                      IN       DATE,
      p_source_uom                    IN       VARCHAR2,
      x_duration                      OUT NOCOPY NUMBER
   )
   IS
      l_api_name                     CONSTANT VARCHAR2 (30) := 'get_duration';
      l_duration                              NUMBER;
      l_period                                VARCHAR2 (10);
   BEGIN
      IF p_start_date > p_end_date
      THEN
         l_duration                 :=
            oks_time_measures_pub.get_quantity (p_start_date                       => p_end_date,
                                                p_end_date                         => p_start_date,
                                                p_source_uom                       => p_source_uom
                                               );
         x_duration                 := l_duration;
      ELSE
         l_duration                 :=
            oks_time_measures_pub.get_quantity (p_start_date                       => p_start_date,
                                                p_end_date                         => p_end_date,
                                                p_source_uom                       => p_source_uom
                                               );
         x_duration                 := l_duration *
                                       -1;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         x_duration                 := okc_api.g_miss_num;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
   END;

   PROCEDURE update_renewal_status (
      p_chr_id                        IN       NUMBER,
      p_renewal_status                IN       VARCHAR2,
      x_return_status                 OUT NOCOPY VARCHAR2
   )
   IS
      l_api_name                     CONSTANT VARCHAR2 (30)
                                                   := 'update_renewal_status';
      l_return_status                         VARCHAR2 (1) := 'S';
      l_api_version                           NUMBER := 1.0;
      l_init_msg_list                         VARCHAR2 (1) := 'F';
      l_msg_count                             NUMBER;
      l_msg_data                              VARCHAR2 (2000);
      l_khdr_rec_in                           oks_contract_hdr_pub.khrv_rec_type;
      l_khdr_rec_out                          oks_contract_hdr_pub.khrv_rec_type;
      l_kdetails_rec                          oks_qp_int_pvt.k_details_rec;
   BEGIN
      l_return_status            := okc_api.g_ret_sts_success;
      oks_qp_int_pvt.get_k_details (p_id                               => p_chr_id,
                                    p_type                             => 'KHR',
                                    x_k_det_rec                        => l_kdetails_rec
                                   );
      l_khdr_rec_in.chr_id       := p_chr_id;
      l_khdr_rec_in.renewal_status := p_renewal_status;
      l_khdr_rec_in.ID           := l_kdetails_rec.ID;
      l_khdr_rec_in.object_version_number :=
                                          l_kdetails_rec.object_version_number;
      oks_contract_hdr_pub.update_header (p_api_version                      => l_api_version,
                                          p_init_msg_list                    => l_init_msg_list,
                                          x_return_status                    => l_return_status,
                                          x_msg_count                        => l_msg_count,
                                          x_msg_data                         => l_msg_data,
                                          p_khrv_rec                         => l_khdr_rec_in,
                                          x_khrv_rec                         => l_khdr_rec_out,
                                          p_validate_yn                      => 'N'
                                         );

      IF (l_return_status <> okc_api.g_ret_sts_success)
      THEN
         RAISE g_exception_halt_validation;
      END IF;

      x_return_status            := l_return_status;
   EXCEPTION
      WHEN g_exception_halt_validation
      THEN
         x_return_status            := l_return_status;
      WHEN OTHERS
      THEN
         x_return_status            := l_return_status;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
   END;

   FUNCTION get_product_name (
      p_lse_id                        IN       NUMBER,
      p_object_id                     IN       NUMBER,
      p_inv_org_id                    IN       NUMBER DEFAULT NULL
   )
      RETURN VARCHAR2
   IS
      l_name                                  VARCHAR2 (1000);
      l_return_status                         VARCHAR2 (1);

      CURSOR c1
      IS
         SELECT mtl.NAME
           FROM okx_system_items_v mtl,
                okx_cust_prod_v cp
          WHERE mtl.id1 = cp.inventory_item_id
            AND mtl.organization_id = p_inv_org_id
            AND cp.customer_product_id = p_object_id;

      CURSOR c2
      IS
         SELECT NAME
           FROM okx_parties_v
          WHERE id1 = p_object_id
            AND id2 = '#';

      CURSOR c3
      IS
         SELECT NAME
           FROM okx_systems_v
          WHERE id1 = p_object_id
            AND id2 = '#';
   BEGIN
      IF p_lse_id = 25
      THEN
         OPEN c1;

         FETCH c1
          INTO l_name;

         CLOSE c1;
      END IF;

      IF p_lse_id = 35
      THEN
         OPEN c2;

         FETCH c2
          INTO l_name;

         CLOSE c2;
      END IF;

      IF p_lse_id = 11
      THEN
         OPEN c3;

         FETCH c3
          INTO l_name;

         CLOSE c3;
      END IF;

      RETURN l_name;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END;

   FUNCTION get_no_of_users (
      p_lse_id                        IN       NUMBER,
      p_object_id                     IN       NUMBER
   )
      RETURN VARCHAR2
   IS
      l_name                                  VARCHAR2 (1000);

      CURSOR l_users_csr
      IS
         SELECT pricing_attribute3
           FROM cs_customer_products_all
          WHERE customer_product_id = p_object_id;
   BEGIN
      IF p_lse_id = 25
      THEN
         OPEN l_users_csr;

         FETCH l_users_csr
          INTO l_name;

         CLOSE l_users_csr;
      END IF;

      RETURN l_name;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END;

   FUNCTION get_service_name (
      p_line_id                       IN       NUMBER,
      p_contract_id                   IN       NUMBER
   )
      RETURN VARCHAR2
   IS
      CURSOR l_service_csr
      IS
         SELECT NAME
           FROM okx_system_items_v mtl,
                okc_k_items itm
          WHERE mtl.id1 = itm.object1_id1
            AND mtl.id2 = itm.object1_id2
            AND itm.cle_id = p_line_id
            AND itm.dnz_chr_id = p_contract_id;

      l_service_name                          okx_system_items_v.NAME%TYPE;
   BEGIN
      OPEN l_service_csr;

      FETCH l_service_csr
       INTO l_service_name;

      CLOSE l_service_csr;

      RETURN l_service_name;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF l_service_csr%ISOPEN
         THEN
            CLOSE l_service_csr;
         END IF;

         RETURN NULL;
   END;

   FUNCTION get_license_level (
      p_lse_id                        IN       NUMBER,
      p_object_id                     IN       NUMBER
   )
      RETURN VARCHAR2
   IS
      l_name                                  VARCHAR2 (1000);

      CURSOR l_license_level_csr
      IS
         SELECT pricing_attribute5
           FROM cs_customer_products_all
          WHERE customer_product_id = p_object_id;
   BEGIN
      IF p_lse_id = 25
      THEN
         OPEN l_license_level_csr;

         FETCH l_license_level_csr
          INTO l_name;

         CLOSE l_license_level_csr;
      END IF;

      RETURN l_name;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END;

   FUNCTION get_pricing_type (
      p_lse_id                        IN       NUMBER,
      p_object_id                     IN       NUMBER
   )
      RETURN VARCHAR2
   IS
      l_name                                  VARCHAR2 (1000);

      CURSOR l_pricing_type_csr
      IS
         SELECT pricing_attribute4
           FROM cs_customer_products_all
          WHERE customer_product_id = p_object_id;
   BEGIN
      IF p_lse_id = 25
      THEN
         OPEN l_pricing_type_csr;

         FETCH l_pricing_type_csr
          INTO l_name;

         CLOSE l_pricing_type_csr;
      END IF;

      RETURN l_name;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END;

   FUNCTION get_billto_contact (
      p_org_id                        IN       NUMBER,
      p_inv_org_id                    IN       NUMBER,
      p_contract_id                   IN       NUMBER
   )
      RETURN VARCHAR2
   IS
      CURSOR l_billto_contact_csr
      IS
         SELECT object1_id1
           FROM okc_contacts ct
          WHERE ct.cro_code = 'BILLING'
            AND ct.dnz_chr_id = p_contract_id;

      l_id                                    NUMBER;
      l_name                                  VARCHAR2 (240);

      CURSOR l_btc_name_csr
      IS
         SELECT NAME
           FROM okx_party_contacts_v
          WHERE id1 = l_id;
   BEGIN
      okc_context.set_okc_org_context (p_org_id, p_inv_org_id);

      OPEN l_billto_contact_csr;

      FETCH l_billto_contact_csr
       INTO l_id;

      CLOSE l_billto_contact_csr;

      OPEN l_btc_name_csr;

      FETCH l_btc_name_csr
       INTO l_name;

      CLOSE l_btc_name_csr;

      RETURN l_name;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END;

   FUNCTION get_billto_phone (
      p_contract_id                   IN       NUMBER
   )
      RETURN VARCHAR2
   IS
      CURSOR l_phone_csr (
         p_id                                     NUMBER
      )
      IS
         SELECT   phone_area_code ||
                  '-' ||
                  phone_number
             FROM okx_contact_points_v
            WHERE owner_table_id = p_id
              AND owner_table_name = 'HZ_PARTIES'
              AND contact_point_type = 'PHONE'
              AND phone_number IS NOT NULL
         ORDER BY DECODE (phone_line_type,
                          'GEN', 1,
                          'OFFICE', 2,
                          'PHONE', 3,
                          'Direct Phone', 4,
                          5
                         );

      CURSOR l_svc_admin_csr
      IS
         SELECT object1_id1
           FROM okc_contacts ct
          WHERE ct.cro_code = 'BILLING'
            AND ct.dnz_chr_id = p_contract_id;

      l_id                                    NUMBER;
      l_phone                                 VARCHAR2 (240);
   BEGIN
      OPEN l_svc_admin_csr;

      FETCH l_svc_admin_csr
       INTO l_id;

      CLOSE l_svc_admin_csr;

      OPEN l_phone_csr (l_id);

      FETCH l_phone_csr
       INTO l_phone;

      CLOSE l_phone_csr;

      RETURN l_phone;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END;

   FUNCTION get_billto_fax (
      p_contract_id                   IN       NUMBER
   )
      RETURN VARCHAR2
   IS
      CURSOR l_phone_csr (
         p_id                                     NUMBER
      )
      IS
         SELECT phone_area_code ||
                '-' ||
                phone_number
           FROM okx_contact_points_v
          WHERE owner_table_id = p_id
            AND owner_table_name = 'HZ_PARTIES'
            AND contact_point_type IN ('PHONE', 'FAX')
            AND phone_line_type = 'FAX';

      CURSOR l_svc_admin_csr
      IS
         SELECT object1_id1
           FROM okc_contacts ct
          WHERE ct.cro_code = 'BILLING'
            AND ct.dnz_chr_id = p_contract_id;

      l_id                                    NUMBER;
      l_phone                                 VARCHAR2 (240);
   BEGIN
      OPEN l_svc_admin_csr;

      FETCH l_svc_admin_csr
       INTO l_id;

      CLOSE l_svc_admin_csr;

      OPEN l_phone_csr (l_id);

      FETCH l_phone_csr
       INTO l_phone;

      CLOSE l_phone_csr;

      RETURN l_phone;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END;

   FUNCTION get_billto_email (
      p_contract_id                   IN       NUMBER
   )
      RETURN VARCHAR2
   IS
/*
 Forward port for bug 5051455 (bug 5082822)
 modified the below cursor to get billto_email addres
*/
CURSOR l_billto_email IS
 SELECT hcp.email_address
   FROM hz_contact_points hcp,
        okc_contacts kc
  WHERE hcp.owner_table_id = kc.object1_id1
    AND kc.cro_code = 'BILLING'
    AND hcp.contact_point_type='EMAIL'
    AND hcp.owner_table_name = 'HZ_PARTIES'
    AND hcp.content_source_type = 'USER_ENTERED'
    AND hcp.status = 'A'
    AND kc.dnz_chr_id= p_contract_id
ORDER BY hcp.primary_flag desc;

      l_email                                 VARCHAR2 (2000);

   BEGIN
        -- Forward port Bug 5051455
         OPEN l_billto_email;
           FETCH l_billto_email INTO l_email;
         CLOSE l_billto_email;

      RETURN l_email;

   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END;

   PROCEDURE log_interaction (
      x_return_status                 OUT NOCOPY VARCHAR2,
      x_msg_count                     OUT NOCOPY NUMBER,
      x_msg_data                      OUT NOCOPY VARCHAR2,
      p_chr_id                        IN       VARCHAR2,
      p_subject                       IN       VARCHAR2 DEFAULT NULL,
      p_msg_body                      IN       VARCHAR2 DEFAULT NULL,
      p_sent2_email                   IN       VARCHAR2 DEFAULT NULL
   )
   IS
   BEGIN
      oks_auto_reminder.log_interaction (p_api_version                      => 1.0,
                                         p_init_msg_list                    => 'F',
                                         x_return_status                    => x_return_status,
                                         x_msg_count                        => x_msg_count,
                                         x_msg_data                         => x_msg_data,
                                         p_chr_id                           => TO_NUMBER
                                                                                  (p_chr_id),
                                         p_subject                          => p_subject,
                                         p_msg_body                         => p_msg_body,
                                         p_sent2_email                      => p_sent2_email
                                        );
   EXCEPTION
      WHEN OTHERS
      THEN
         x_return_status            := okc_api.g_ret_sts_unexp_error;
         okc_api.set_message (g_app_name,
                              g_unexpected_error,
                              g_sqlcode_token,
                              SQLCODE,
                              g_sqlerrm_token,
                              SQLERRM
                             );
   END;

   PROCEDURE log_interaction (
      p_api_version                   IN       NUMBER,
      p_init_msg_list                 IN       VARCHAR2,
      x_return_status                 OUT NOCOPY VARCHAR2,
      x_msg_count                     OUT NOCOPY NUMBER,
      x_msg_data                      OUT NOCOPY VARCHAR2,
      p_chr_id                        IN       NUMBER,
      p_subject                       IN       VARCHAR2 DEFAULT NULL,
      p_msg_body                      IN       VARCHAR2 DEFAULT NULL,
      p_sent2_email                   IN       VARCHAR2 DEFAULT NULL,
      p_media_type                    IN       VARCHAR2 DEFAULT 'EMAIL'
   )
   IS
      l_api_version                  CONSTANT NUMBER := 1.0;
      l_api_name                     CONSTANT VARCHAR2 (50)
                                                         := 'log_interaction';

      CURSOR l_kdetails_csr (
         p_chr_id                                 NUMBER
      )
      IS
         SELECT contract_number,
                contract_number_modifier
           FROM okc_k_headers_all_b
          WHERE ID = p_chr_id;

      CURSOR l_userres_csr (
         p_user_id                                NUMBER
      )
      IS
         SELECT rsc.resource_id resource_id
           FROM jtf_rs_resource_extns rsc,
                fnd_user u
          WHERE u.user_id = rsc.user_id
            AND u.user_id = p_user_id;

      l_rownotfound                           BOOLEAN := FALSE;
      l_salesrep_resource_id                  NUMBER;
      l_salesrep_id                           NUMBER;
      l_salesrep_name                         VARCHAR2 (100);
      l_qto_email                             VARCHAR2 (2000);
      l_party_id                              NUMBER;
      l_subject                               VARCHAR2 (200);
      l_interaction_body                      VARCHAR2 (2000);
      l_interaction_id                        NUMBER;
      l_kdetails_rec                          l_kdetails_csr%ROWTYPE;
   BEGIN
      IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         'Entered ' ||
                         g_pkg_name ||
                         '.' ||
                         l_api_name ||
                         '(p_chr_id=>' ||
                         p_chr_id ||
                         'p_subject=>' ||
                         SUBSTR (p_subject,
                                 1,
                                 240
                                ) ||
                         'p_msg_body=>' ||
                         SUBSTR (p_msg_body,
                                 1,
                                 240
                                ) ||
                         'p_sent2_email=>' ||
                         SUBSTR (p_sent2_email,
                                 1,
                                 240
                                ) ||
                         ')'
                        );
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         fnd_msg_pub.initialize;
      END IF;

      --  Initialize API return status to success
      x_return_status            := g_ret_sts_success;
      mo_global.init (p_appl_short_name                  => 'OKC');

      OPEN l_kdetails_csr (p_chr_id);

      FETCH l_kdetails_csr
       INTO l_kdetails_rec;

      l_rownotfound              := l_kdetails_csr%NOTFOUND;

      CLOSE l_kdetails_csr;

      IF l_rownotfound
      THEN
         fnd_message.set_name (g_app_name, 'OKS_INVD_CONTRACT_ID');
         fnd_message.set_token ('HDR_ID', p_chr_id);
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
      END IF;

      IF fnd_log.level_event >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_event,
                         g_module ||
                         l_api_name ||
                         '.external_call.before',
                         'OKS_AUTO_REMINDER.get_qtoparty_id(p_chr_id= ' ||
                         p_chr_id ||
                         ')'
                        );
      END IF;

      -- Get the party ID for logging interaction history
      oks_auto_reminder.get_qtoparty_id (p_chr_id                           => p_chr_id,
                                         x_party_id                         => l_party_id);

      IF fnd_log.level_event >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_event,
                         g_module ||
                         l_api_name ||
                         '.external_call.after',
                         'OKS_AUTO_REMINDER.get_qtoparty_id(x_party_id= ' ||
                         l_party_id ||
                         ')'
                        );
      END IF;

      IF l_party_id IS NULL
      THEN
         fnd_message.set_name (g_app_name, 'OKS_NO_QTO_CONTACT');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
      END IF;

      -- Get Salesrep user name which will be used as performer
      IF fnd_log.level_event >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING (fnd_log.level_event,
                         g_module ||
                         l_api_name ||
                         '.external_call.before',
                         'OKS_RENEW_CONTRACT_PVT.GET_USER_NAME(p_chr_id=' ||
                         p_chr_id ||
                         ')'
                        );
      END IF;

      oks_renew_contract_pvt.get_user_name
                                          (p_api_version                      => l_api_version,
                                           p_init_msg_list                    => g_false,
                                           x_return_status                    => x_return_status,
                                           x_msg_count                        => x_msg_count,
                                           x_msg_data                         => x_msg_data,
                                           p_chr_id                           => p_chr_id,
                                           p_hdesk_user_id                    => NULL,
                                           x_user_id                          => l_salesrep_id,
                                           x_user_name                        => l_salesrep_name
                                          );

      IF fnd_log.level_event >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING
                 (fnd_log.level_event,
                  g_module ||
                  l_api_name ||
                  '.external_call.after',
                  'OKS_RENEW_CONTRACT_PVT.GET_USER_NAME(x_return_status= ' ||
                  x_return_status ||
                  ' x_msg_count =' ||
                  x_msg_count ||
                  ')'
                 );
         fnd_log.STRING (fnd_log.level_event,
                         g_module ||
                         l_api_name ||
                         '.external_call.after',
                         ' x_user_id =' ||
                         l_salesrep_id ||
                         ' x_user_name =' ||
                         l_salesrep_name
                        );
      END IF;

      IF x_return_status = g_ret_sts_unexp_error
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      ELSIF x_return_status = g_ret_sts_error
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;

      OPEN l_userres_csr (l_salesrep_id);

      FETCH l_userres_csr
       INTO l_salesrep_resource_id;

      l_rownotfound              := l_userres_csr%NOTFOUND;

      CLOSE l_userres_csr;

      IF    l_rownotfound
         OR l_salesrep_resource_id IS NULL
      THEN
         fnd_message.set_name (g_app_name, 'OKS_INTERACTION_FAILED');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
      END IF;

      IF p_subject IS NULL
      THEN
         fnd_message.set_name ('OKS', 'OKS_INT_HISTORY_SUBJECT');
         l_subject                  := fnd_message.get;
      ELSE
         l_subject                  := p_subject;
      END IF;

      IF p_msg_body IS NULL
      THEN
         -- assemble interaction history body
         fnd_message.set_name ('OKS', 'OKS_INT_HISTORY_MSG_BODY');
         fnd_message.set_token ('TOKEN1', l_kdetails_rec.contract_number);
         fnd_message.set_token ('TOKEN2',
                                l_kdetails_rec.contract_number_modifier);

         IF p_sent2_email IS NULL
         THEN
            oks_auto_reminder.get_qto_email (p_chr_id                           => p_chr_id,
                                             x_qto_email                        => l_qto_email);

            IF l_qto_email = okc_api.g_miss_char
            THEN
               fnd_message.set_name (g_app_name, 'OKS_NO_QTO_EMAIL');
               fnd_msg_pub.ADD;
               RAISE fnd_api.g_exc_error;
            END IF;

            fnd_message.set_token ('TOKEN3', l_qto_email);
         ELSE
            fnd_message.set_token ('TOKEN3', p_sent2_email);
         END IF;

         l_interaction_body         := fnd_message.get;
      ELSE
         l_interaction_body         := p_msg_body;
      END IF;

      IF fnd_log.level_event >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING
             (fnd_log.level_event,
              g_module ||
              l_api_name ||
              '.external_call.before',
              'OKC_INTERACT_HISTORY_PUB.CREATE_INTERACT_HISTORY(p_chr_id=' ||
              p_chr_id ||
              'p_notes=>' ||
              SUBSTR (l_subject,
                      1,
                      240
                     ) ||
              'p_notes_detail=>' ||
              SUBSTR (l_interaction_body,
                      1,
                      240
                     ) ||
              'p_resource1_id=>' ||
              l_party_id ||
              'p_resource2_id=>' ||
              l_salesrep_resource_id ||
              ')'
             );
      END IF;

      okc_interact_history_pub.create_interact_history
                                    (x_return_status                    => x_return_status,
                                     x_msg_count                        => x_msg_count,
                                     x_msg_data                         => x_msg_data,
                                     x_interaction_id                   => l_interaction_id,
                                     p_media_type                       => p_media_type,
                                     p_action_item_id                   => 45,
                                                              -- Email Message
                                     p_outcome_id                       => 41,
                                                                    -- Compose
                                     p_touchpoint1_type                 => 'PARTY',
                                     p_resource1_id                     => l_party_id,
                                     p_touchpoint2_type                 => 'EMPLOYEE',
                                     p_resource2_id                     => l_salesrep_resource_id,
                                     p_contract_id                      => p_chr_id,
                                     p_int_start_date                   => SYSDATE,
                                     p_int_end_date                     => SYSDATE,
                                     p_notes                            => l_subject,
                                     p_notes_detail                     => l_interaction_body
                                    );

      IF fnd_log.level_event >= fnd_log.g_current_runtime_level
      THEN
         fnd_log.STRING
            (fnd_log.level_event,
             g_module ||
             l_api_name ||
             '.external_call.after',
             'OKC_INTERACT_HISTORY_PUB.CREATE_INTERACT_HISTORY(x_return_status= ' ||
             x_return_status ||
             ' x_msg_count =' ||
             x_msg_count ||
             'x_interaction_id =' ||
             l_interaction_id ||
             ')'
            );
      END IF;

      IF x_return_status = g_ret_sts_unexp_error
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      ELSIF x_return_status = g_ret_sts_error
      THEN
         RAISE fnd_api.g_exc_error;
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         fnd_msg_pub.count_and_get (p_encoded                          => 'F',
                                    p_count                            => x_msg_count,
                                    p_data                             => x_msg_data
                                   );

         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_procedure,
                            g_module ||
                            l_api_name,
                            'Leaving ' ||
                            g_pkg_name ||
                            '.' ||
                            l_api_name ||
                            ' from G_EXC_ERROR'
                           );
            fnd_log.STRING (fnd_log.level_procedure,
                            g_module ||
                            l_api_name,
                            x_msg_data
                           );
         END IF;

         x_return_status            := g_ret_sts_error;
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         fnd_msg_pub.count_and_get (p_encoded                          => 'F',
                                    p_count                            => x_msg_count,
                                    p_data                             => x_msg_data
                                   );

         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_procedure,
                            g_module ||
                            l_api_name,
                            'Leaving ' ||
                            g_pkg_name ||
                            '.' ||
                            l_api_name ||
                            ' from G_EXC_UNEXPECTED_ERROR'
                           );
            fnd_log.STRING (fnd_log.level_procedure,
                            g_module ||
                            l_api_name,
                            x_msg_data
                           );
         END IF;

         x_return_status            := g_ret_sts_unexp_error;
      WHEN OTHERS
      THEN
         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_procedure,
                            g_module ||
                            l_api_name,
                            'Leaving ' ||
                            g_pkg_name ||
                            '.' ||
                            l_api_name ||
                            ' from OTHERS sqlcode = ' ||
                            SQLCODE ||
                            ', sqlerrm = ' ||
                            SQLERRM
                           );
            fnd_msg_pub.add_exc_msg (g_pkg_name,
                                     l_api_name,
                                     SUBSTR (SQLERRM,
                                             1,
                                             240
                                            )
                                    );
         END IF;

         fnd_msg_pub.count_and_get (p_encoded                          => 'F',
                                    p_count                            => x_msg_count,
                                    p_data                             => x_msg_data
                                   );
         x_return_status            := g_ret_sts_unexp_error;
   END log_interaction;

   FUNCTION get_fnd_message RETURN VARCHAR2 IS
    i               NUMBER := 0;
    l_return_status VARCHAR2(1);
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);
    l_msg_index_out NUMBER;
    l_mesg          VARCHAR2(2000) := NULL;
   BEGIN
    FOR i in 1..fnd_msg_pub.count_msg
    LOOP
       fnd_msg_pub.get
       (
         p_msg_index     => i,
         p_encoded       => 'F',
         p_data          => l_msg_data,
         p_msg_index_out => l_msg_index_out
       );
       IF l_mesg IS NULL THEN
          l_mesg := i || ':' || l_msg_data;
       ELSE
          l_mesg := l_mesg || ':' || i || ':' || l_msg_data;
       END IF;
    END LOOP;
    RETURN l_mesg;
   END get_fnd_message;

   PROCEDURE validate_autoreminder_k (
      p_chr_id                        IN       VARCHAR2,
      x_is_eligible                   OUT NOCOPY VARCHAR2,
      x_quote_id                      OUT NOCOPY VARCHAR2,
      x_cover_id                      OUT NOCOPY VARCHAR2,
      x_sender                        OUT NOCOPY VARCHAR2,
      x_qto_email                     OUT NOCOPY VARCHAR2,
      x_subject                       OUT NOCOPY VARCHAR2,
      x_status                        OUT NOCOPY VARCHAR2,
      x_attachment_name               OUT NOCOPY VARCHAR2,
      x_return_status                 OUT NOCOPY VARCHAR2,
      x_msg_count                     OUT NOCOPY VARCHAR2,
      x_msg_data                      OUT NOCOPY VARCHAR2
   )
   IS
      l_template_set_id               NUMBER;
      l_duration                      NUMBER;
      l_period                        VARCHAR2 (10);
      l_report_type                   VARCHAR2 (90);
      l_temp_duration                 NUMBER;
      l_count                         NUMBER := 0;
      l_wf_name                       VARCHAR2 (150);
      l_wf_process_name               VARCHAR2 (150);
      l_package_name                  VARCHAR2 (150);
      l_procedure_name                VARCHAR2 (150);
      l_usage                         VARCHAR2 (150);
      l_concat_k_number               VARCHAR2 (250);

      CURSOR l_k_details_csr (
         p_chr_id                                 NUMBER
      )
      IS
         SELECT kh.ID,
                kh.contract_number,
                kh.contract_number_modifier,
                kh.start_date,
                kh.end_date,
                kh.sts_code
           FROM okc_k_headers_b kh
          WHERE kh.ID = p_chr_id;

      l_k_details_rec                         l_k_details_csr%ROWTYPE;

      CURSOR l_reports_csr (
         l_template_set                           VARCHAR2,
         l_period                                 VARCHAR2,
         p_process_code                           VARCHAR2,
         p_applies_to                             VARCHAR2
      )
      IS
         SELECT message_template_id,
                report_duration,
                report_period,
                template_set_type,
                report_id,
                attachment_name,
                sts_code
           FROM oks_report_templates
          WHERE template_set_id = l_template_set
            AND (   DECODE (process_code,
                            'B', 'B',
                            'X'
                           ) = 'B'
                 OR process_code = p_process_code
                )
            AND (   DECODE (applies_to,
                            'B', 'B',
                            'X'
                           ) = 'B'
                 OR applies_to = p_applies_to
                )
            AND report_period <> l_period
            AND report_duration <> 0
            AND SYSDATE BETWEEN NVL (start_date, SYSDATE)
                            AND NVL (end_date, SYSDATE);

      CURSOR l_reportmatch_csr (
         p_template_set                           VARCHAR2,
         p_duration                               NUMBER,
         p_period                                 VARCHAR2,
         p_process_code                           VARCHAR2,
         p_applies_to                             VARCHAR2
      )
      IS
         SELECT message_template_id,
                template_set_type,
                report_id,
                attachment_name,
                sts_code
           FROM oks_report_templates
          WHERE template_set_id = p_template_set
            AND report_duration = p_duration
            AND report_period = p_period
            AND (   DECODE (process_code,
                            'B', 'B',
                            'X'
                           ) = 'B'
                 OR process_code = p_process_code
                )
            AND (   DECODE (applies_to,
                            'B', 'B',
                            'X'
                           ) = 'B'
                 OR applies_to = p_applies_to
                )
            AND SYSDATE BETWEEN NVL (start_date, SYSDATE)
                            AND NVL (end_date, SYSDATE);

      l_reportmatch_rec                       l_reportmatch_csr%ROWTYPE;

      CURSOR l_duration_csr (
         p_template_set                           VARCHAR2,
         p_duration                               NUMBER,
         p_process_code                           VARCHAR2,
         p_applies_to                             VARCHAR2
      )
      IS
         SELECT message_template_id,
                template_set_type,
                report_id,
                attachment_name,
                sts_code
           FROM oks_report_templates
          WHERE template_set_id = p_template_set
            AND report_duration = p_duration
            AND (   DECODE (process_code,
                            'B', 'B',
                            'X'
                           ) = 'B'
                 OR process_code = p_process_code
                )
            AND (   DECODE (applies_to,
                            'B', 'B',
                            'X'
                           ) = 'B'
                 OR applies_to = p_applies_to
                )
            AND SYSDATE BETWEEN NVL (start_date, SYSDATE)
                            AND NVL (end_date, SYSDATE);

      l_duration_rec                          l_duration_csr%ROWTYPE;

      CURSOR l_user_email_csr (p_user_id NUMBER) IS
      SELECT source_email
      FROM jtf_rs_resource_extns
      WHERE user_id = p_user_id;

      l_api_name         CONSTANT VARCHAR2 (30) := 'validate_autoreminder_k';
      l_item_key         wf_items.item_key%TYPE := '';
      l_online_yn        VARCHAR2 (1) := 'N';
      l_process_code     oks_report_templates_v.process_code%TYPE;
      l_applies_to       oks_report_templates_v.applies_to%TYPE;
      l_salesrep_id      NUMBER;
      l_salesrep_name    VARCHAR2 (1000);

      CURSOR csr_k_hdr_details IS
      SELECT DECODE (renewal_type_used,NULL,'N','R'), wf_item_key
      FROM oks_k_headers_b
      WHERE chr_id = p_chr_id;

      CURSOR csr_xdo_template_name(p_attachment_template_id IN NUMBER) IS
      SELECT template_name
      FROM xdo_templates_vl
      WHERE template_id=p_attachment_template_id;

     /*added for bug6956935*/
 Cursor l_chrv_csr(p_chr_id NUMBER) Is
    select 'Y'
    from oks_k_headers_b
   where chr_id = p_chr_id
   and RENEWAL_TYPE_USED = 'ERN'
   and date_accepted is not null;
  l_cust_accept_flag VARCHAR2(1);



   BEGIN

      -- Contract is eligibile for a reminder or cancellation notice
      x_is_eligible   := 'Y';
      x_return_status := g_ret_sts_success;

      IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE , G_MODULE||l_api_name,
                       'Entered with p_chr_id '||p_chr_id);
      END IF;
      -- Initialize message stack
      FND_MSG_PUB.initialize;

      OPEN l_k_details_csr (TO_NUMBER (p_chr_id));
      FETCH l_k_details_csr INTO l_k_details_rec;
      IF l_k_details_csr%NOTFOUND THEN
        CLOSE l_k_details_csr;
        x_is_eligible := 'N';
        FND_MESSAGE.SET_NAME(G_APP_NAME,'OKS_INVD_CONTRACT_ID');
        FND_MESSAGE.SET_TOKEN('HDR_ID',p_chr_id);
        FND_MSG_PUB.add;
      ELSE
        CLOSE l_k_details_csr;
        IF l_k_details_rec.contract_number_modifier IS NULL THEN
          l_concat_k_number := l_k_details_rec.contract_number;
        ELSE
          l_concat_k_number := l_k_details_rec.contract_number || ' - ' ||
                               l_k_details_rec.contract_number_modifier;
        END IF;
      END IF;

      -- STEP 1: Check for active workflow processes
      IF x_is_eligible = 'Y' THEN
        IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                 'okc_contract_pub.get_active_process(p_contract_number= '||
                 l_k_details_rec.contract_number||
                 ' p_contract_number_modifier ='||l_k_details_rec.contract_number_modifier||')');
        END IF;
        okc_contract_pub.get_active_process
        (
         p_api_version               => 1.0,
         p_init_msg_list             => 'Y',
         x_return_status             => x_return_status,
         x_msg_count                 => x_msg_count,
         x_msg_data                  => x_msg_data,
         p_contract_number           => l_k_details_rec.contract_number,
         p_contract_number_modifier  => l_k_details_rec.contract_number_modifier,
         x_wf_name                   => l_wf_name,
         x_wf_process_name           => l_wf_process_name,
         x_package_name              => l_package_name,
         x_procedure_name            => l_procedure_name,
         x_usage                     => l_usage
        );
        IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                 'okc_contract_pub.get_active_process(x_return_status= '||x_return_status||
                 ' x_msg_count ='||x_msg_count||')');
        END IF;

        /*BUG6956935*/
 	         /*changes made in order to check whether customer has accepted the renewal contract, if yes then we should not send auto reminder for that contract*/
 	         OPEN l_chrv_csr(to_number(p_chr_id));
 	         FETCH l_chrv_csr into l_cust_accept_flag;
 	         IF l_chrv_csr%NOTFOUND THEN
 	           l_cust_accept_flag := 'N';
 	         ELSE
 	           l_cust_accept_flag := 'Y';
 	         END IF;
 	         CLOSE l_chrv_csr;

        -- If error, skip this contract and proceed with the next
        IF x_return_status <> g_ret_sts_success OR l_wf_name IS NOT NULL OR l_cust_accept_flag = 'Y' THEN
          x_is_eligible := 'N';
          FND_MESSAGE.SET_NAME(G_APP_NAME,'OKS_K_IN_APPROVAL_PROCESS');
          FND_MESSAGE.SET_TOKEN('K_NUMBER',l_concat_k_number);
          FND_MSG_PUB.add;
        END IF;
      END IF;

      -- STEP 2: Get template set
      IF x_is_eligible = 'Y' THEN
        -- get the workflow key
        OPEN csr_k_hdr_details;
        FETCH csr_k_hdr_details INTO l_applies_to, l_item_key;
        CLOSE csr_k_hdr_details;

        IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                 'OKS_WF_K_PROCESS_PVT.is_online_k_yn(p_contract_id= '||p_chr_id||
                 ' p_item_key ='||l_item_key||')');
        END IF;
        -- check if the current contract is ONLINE or MANUAL
        OKS_WF_K_PROCESS_PVT.is_online_k_yn
        (
         p_api_version          => 1.0,
         p_init_msg_list        => FND_API.G_FALSE,
         p_contract_id          => p_chr_id ,
         p_item_key             => l_item_key ,
         x_online_yn            => l_online_yn ,
         x_return_status        => x_return_status,
         x_msg_count            => x_msg_count,
         x_msg_data             => x_msg_data
        );
        IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                 'OKS_WF_K_PROCESS_PVT.is_online_k_yn(x_return_status= '||x_return_status||
                 ' x_msg_count ='||x_msg_count||'l_online_yn '||l_online_yn||')');
        END IF;
        --- If any errors happen treat it as online K
        IF (x_return_status <> g_ret_sts_success) THEN
           l_online_yn     := 'Y';
           x_return_status := g_ret_sts_success;
        END IF;

        IF l_online_yn = 'Y' THEN
           l_process_code := 'O';
        ELSE
           l_process_code := 'M';
        END IF;

        BEGIN
          IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                   'oks_renew_util_pub.get_template_set_id(p_contract_id= '||
                   l_k_details_rec.ID||')');
          END IF;

          l_template_set_id := oks_renew_util_pub.get_template_set_id(l_k_details_rec.ID);

          IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                   'oks_renew_util_pub.get_template_set_id(x_template_set_id= '||
                   l_template_set_id||')');
          END IF;
          IF l_template_set_id IS NULL THEN
            x_is_eligible := 'N';
            FND_MESSAGE.SET_NAME(G_APP_NAME,'OKS_NO_TEMPLATE_SET');
            FND_MESSAGE.SET_TOKEN('K_NUMBER',l_concat_k_number);
            FND_MSG_PUB.add;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
             x_is_eligible := 'N';
             x_return_status   := g_ret_sts_unexp_error;
             FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
        END;
      END IF;

      -- STEP 3: Check if the contract qualifies for a reminder / cancelation notice
      IF l_template_set_id IS NOT NULL AND x_is_eligible = 'Y' THEN
        l_duration := TRUNC (SYSDATE) - TRUNC (l_k_details_rec.start_date);
        l_period   := oks_time_measures_pub.get_uom_code ('DAY', 1);

        IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                 'l_duration: ' ||l_duration||' l_period: '||l_period );
        END IF;

        -- If there is an error getting the duration skip this contract
        IF l_duration <> 0 THEN
          -- Check if we have a report having the same duration, period
          -- in the Template set. If foudn pick the report for generating
          -- the email message
          OPEN l_reportmatch_csr (p_template_set => l_template_set_id,
                                  p_duration     => l_duration,
                                  p_period       => l_period,
                                  p_process_code => l_process_code,
                                  p_applies_to   => l_applies_to
                                 );
          FETCH l_reportmatch_csr INTO l_reportmatch_rec;
          IF l_reportmatch_csr%FOUND THEN
            x_cover_id        := l_reportmatch_rec.message_template_id;
            x_quote_id        := l_reportmatch_rec.report_id;
            x_attachment_name := l_reportmatch_rec.attachment_name;
            l_report_type     := l_reportmatch_rec.template_set_type;
            x_status          := l_reportmatch_rec.sts_code;

            CLOSE l_reportmatch_csr;
          ELSE                                -- Straight match not found
            CLOSE l_reportmatch_csr;

            IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
              FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                     'Exact match not found; continue search by converting ');
            END IF;
            -- Now trying to convert and look for match
            FOR l_reports_rec IN l_reports_csr (l_template_set_id,
                                                l_period,
                                                l_process_code,
                                                l_applies_to
                                               )
            LOOP
               IF l_reports_rec.report_duration < 0 THEN
                 l_temp_duration := oks_time_measures_pub.get_target_qty
                                    (
                                     p_start_date => TRUNC(SYSDATE),
                                     p_source_qty => ABS(l_reports_rec.report_duration),
                                     p_source_uom => l_reports_rec.report_period,
                                     p_target_uom => l_period,
                                     p_round_dec  => 18
                                    );
                 l_temp_duration := (l_temp_duration - 1) * -1;
               ELSE
                 l_temp_duration := oks_time_measures_pub.get_target_qty
                                    (
                                     p_start_date => TRUNC(l_k_details_rec.start_date),
                                     p_source_qty => l_reports_rec.report_duration,
                                     p_source_uom => l_reports_rec.report_period,
                                     p_target_uom => l_period,
                                     p_round_dec  => 18
                                    );
                  l_temp_duration := l_temp_duration - 1;
               END IF;

               IF (l_duration = l_temp_duration) THEN
                 x_cover_id        := l_reports_rec.message_template_id;
                 x_quote_id        := l_reports_rec.report_id;
                 x_attachment_name := l_reports_rec.attachment_name;
                 l_report_type     := l_reports_rec.template_set_type;
                 x_status          := l_reports_rec.sts_code;
                 EXIT;
               END IF;
            END LOOP;  -- Inner loop for iterating thru report templates
          END IF;                               -- Report Match cursor IF
        -- Special handler for 0 duration
        ELSIF l_duration = 0 THEN
          OPEN l_duration_csr (l_template_set_id,
                               l_duration,
                               l_process_code,
                               l_applies_to
                              );
          FETCH l_duration_csr INTO l_duration_rec;
          IF l_duration_csr%FOUND THEN
            x_cover_id        := l_duration_rec.message_template_id;
            x_quote_id        := l_duration_rec.report_id;
            x_attachment_name := l_duration_rec.attachment_name;
            l_report_type     := l_duration_rec.template_set_type;
            x_status          := l_duration_rec.sts_code;
          END IF;
          CLOSE l_duration_csr;
        END IF;                               -- Get Duration Status check
        IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                 'x_cover_id: ' ||x_cover_id);
        END IF;

        IF NVL(x_quote_id, x_cover_id) IS NULL THEN
          x_is_eligible := 'N';
          FND_MESSAGE.SET_NAME(G_APP_NAME,'OKS_NO_QUAL_NOTICE');
          FND_MESSAGE.SET_TOKEN('K_NUMBER',l_concat_k_number);
          FND_MSG_PUB.add;
        END IF;
      END IF;

      -- STEP 4: Get Quote to contact email address
      IF NVL(x_quote_id, x_cover_id) IS NOT NULL AND x_is_eligible = 'Y' THEN
        BEGIN
          IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.before',
                   'oks_auto_reminder.get_qto_email(p_chr_id= '||
                   l_k_details_rec.ID||')');
          END IF;
          oks_auto_reminder.get_qto_email
          (
           p_chr_id    => l_k_details_rec.ID,
           x_qto_email => x_qto_email
          );
          IF FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            fnd_log.string(FND_LOG.LEVEL_EVENT,G_MODULE||l_api_name||'.external_call.after',
                   'oks_auto_reminder.get_qto_email(x_qto_email= '||
                   x_qto_email||')');
          END IF;
          IF x_qto_email IS NULL OR x_qto_email = okc_api.g_miss_char THEN
            x_is_eligible := 'N';
            FND_MESSAGE.SET_NAME(G_APP_NAME,'OKS_NO_QTO_EMAIL');
            FND_MSG_PUB.add;
          END IF;
        EXCEPTION
          WHEN OTHERS THEN
             x_is_eligible   := 'N';
             x_return_status := g_ret_sts_unexp_error;
             FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
        END;
      END IF;

      -- STEP 5: Get Sender email address
      IF x_is_eligible = 'Y' THEN
        IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
          fnd_log.STRING(fnd_log.level_event,g_module ||l_api_name ||
                 '.external_call.before',
                 'OKS_RENEW_CONTRACT_PVT.GET_USER_NAME(p_chr_id=' ||
                 l_k_details_rec.ID ||')');
        END IF;
        oks_renew_contract_pvt.get_user_name
        (
         p_api_version    => 1.0,
         p_init_msg_list  => g_false,
         x_return_status  => x_return_status,
         x_msg_count      => x_msg_count,
         x_msg_data       => x_msg_data,
         p_chr_id         => l_k_details_rec.ID,
         p_hdesk_user_id  => NULL,
         x_user_id        => l_salesrep_id,
         x_user_name      => l_salesrep_name
        );
        IF fnd_log.level_event >= fnd_log.g_current_runtime_level THEN
          fnd_log.STRING(fnd_log.level_event,g_module ||l_api_name ||
                 '.external_call.after',
                 'OKS_RENEW_CONTRACT_PVT.GET_USER_NAME(x_return_status= ' ||
                 x_return_status ||' x_msg_count ='||x_msg_count||')');
          fnd_log.STRING (fnd_log.level_event,g_module ||l_api_name ||
                 '.external_call.after',' x_user_id =' ||l_salesrep_id ||
                 ' x_user_name =' ||l_salesrep_name);
        END IF;

        IF x_return_status = g_ret_sts_success AND
           l_salesrep_id IS NOT NULL THEN
          OPEN l_user_email_csr (l_salesrep_id);
          FETCH l_user_email_csr INTO x_sender;
          CLOSE l_user_email_csr;
        END IF;
        IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
          FND_LOG.STRING( FND_LOG.LEVEL_STATEMENT ,G_MODULE||l_api_name,
                 'x_sender: ' ||x_sender);
        END IF;
        IF x_sender IS NULL THEN
          x_is_eligible := 'N';
          FND_MESSAGE.SET_NAME(G_APP_NAME,'OKS_EMAIL_NOT_FOUND');
          FND_MSG_PUB.add;
        END IF;
      END IF;

      -- STEP 6: Get email subject
      IF x_sender IS NOT NULL AND x_is_eligible = 'Y' THEN
        IF l_report_type = 'RMN' THEN
          fnd_message.set_name ('OKS','OKS_AREM_RNT_SUBJECT');
        ELSE
          fnd_message.set_name ('OKS','OKS_AREM_CNT_SUBJECT');
        END IF;
        fnd_message.set_token('TOKEN1',l_concat_k_number);
        x_subject := fnd_message.get;
      END IF;

      -- if attachment name is NULL then get template name from xdo_templates_vl
      IF x_is_eligible = 'Y' AND x_quote_id IS NOT NULL AND
         x_attachment_name IS NULL THEN
        OPEN csr_xdo_template_name(p_attachment_template_id => x_quote_id);
        FETCH csr_xdo_template_name INTO x_attachment_name;
        CLOSE csr_xdo_template_name;
      END IF;
      IF x_is_eligible = 'N' THEN
        x_msg_data    := get_fnd_message;
      END IF;

   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         x_is_eligible := 'N';
         x_msg_data    := get_fnd_message;
      WHEN OTHERS THEN
         x_is_eligible := 'N';
         x_msg_data    := 'Exception: ' || SQLERRM;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
   END validate_autoreminder_k;

/*

PROCEDURE create_sso_user
Pseudo Logic:
-------------

Step 1: Get the person_party_id from oks_k_headers_b

   IF oks_k_headers_b.person_party_id IS NULL THEN
     Fetch the person_party_id for quote to contact id
     UPDATE oks_k_headers_b record with the person_party_id for quote to contact id

Step 2: Check if record exists in fnd_user for the above person_party_id  (filter expired records here)
     -- 1 or more Record Exists
      If record found then
         take the first hit record and put the user name and password in the email notification
       check if this user has the responsibility' Electronic Renewal'
         If yes then return
    else
      add responsibility and return
    end if;

Step 3: If no record found in step 2 above then check in fnd_user if record exists with the user name as quote to contact email

      CASE A: Record NOT Found in fnd_user

         Call FND_USER_PKG.TestUserName
           --@ TestUserName() returns:
           --@ USER_OK_CREATE                 constant pls_integer := 0;
           --@ USER_INVALID_NAME              constant pls_integer := 1;
           --@ USER_EXISTS_IN_FND             constant pls_integer := 2;
           --@ USER_SYNCHED                   constant pls_integer := 3;
           --@ USER_EXISTS_NO_LINK_ALLOWED    constant pls_integer := 4;

          IF l_test_user IN (0,3) THEN
            CALL FND_USER_PKG.CreateUserIdParty
            FND_USER_RESP_GROUPS_API.insert_assignment with responsibility as 'OKS_ERN_WEB'

          ELSE -- l_test_user <> 0 ,3
                -- error, raise exception
                RAISE FND_API.G_EXC_ERROR;
          END IF;


      CASE B: Record Found in fnd_user

         Check if fnd_user is Valid or expired
            Case Valid

               Check person_party_id of fnd_user
                  CASE 1: fnd_user person_party_id is NULL
                     UPDATE fnd_user record with person_party_id from step 1 above
                  CASE 2: person_party_id of fnd_user DOES NOT MATCH the person_party_id from step 1 above
                             (logic introduced as part of bugfix for 58983305)
                            CASE i: If the value of the profile option OKS Overide SSO Behaviour is Y then
                                    Update the person_party_id of oks_k_headers_b and continue publishing
                            CASE ii:If the value of the profile option OKS Overide SSO Behaviour is N
                      RAISE error here
                  CASE 3: person_party_id of fnd_user MATCHES the person_party_id from step 1 above
                       we are fine, do nothing

            Case Expired

                 fnd_user exists and is expired , raise exception


*/
   PROCEDURE create_sso_user (
      p_user_name                     IN       VARCHAR2,
      p_contract_id                   IN       NUMBER,
      x_user_name                     OUT NOCOPY VARCHAR2,
      x_password                      OUT NOCOPY VARCHAR2,
      x_return_status                 OUT NOCOPY VARCHAR2,
      x_msg_data                      OUT NOCOPY VARCHAR2,
      x_msg_count                     OUT NOCOPY NUMBER
   )
   AS
      l_api_name                     CONSTANT VARCHAR2 (30)
                                                         := 'create_sso_user';
      l_person_party_id                       oks_k_headers_b.person_party_id%TYPE;
      l_fnd_person_party_id                   fnd_user.person_party_id%TYPE;
      l_start_date                            fnd_user.start_date%TYPE;
      l_end_date                              fnd_user.end_date%TYPE;
      l_test_user                             PLS_INTEGER;
      l_responsibility_id                     fnd_responsibility_vl.responsibility_id%TYPE;
      l_security_grp_id                       fnd_security_groups.security_group_id%TYPE;
      l_return_value                          BOOLEAN;
      l_user_id                               fnd_user.user_id%TYPE;
      l_quote_to_contact_id                   oks_k_headers_b.quote_to_contact_id%TYPE;

      l_suggested_user_name                   fnd_user.user_name%TYPE;

      CURSOR csr_person_party_id
      IS
         SELECT ks.person_party_id,
                ks.quote_to_contact_id
           FROM oks_k_headers_b ks
          WHERE ks.chr_id = p_contract_id;

      CURSOR csr_qtc_person_party_id (
         p_quote_to_contact_id           IN       NUMBER
      )
      IS
         SELECT hzp.party_id
           FROM hz_cust_account_roles car,
                hz_relationships rln,
                hz_parties hzp
          WHERE car.cust_account_role_id = p_quote_to_contact_id
            AND car.party_id = rln.party_id
            AND rln.subject_id = hzp.party_id
            AND car.role_type = 'CONTACT'
            AND rln.directional_flag = 'F'
            AND rln.content_source_type = 'USER_ENTERED';

      CURSOR csr_check_fnd_user_exists (
         p_person_party_id               IN       NUMBER
      )
      IS
         SELECT user_id,
                user_name,
                encrypted_user_password
           FROM fnd_user
          WHERE SYSDATE BETWEEN start_date AND NVL (end_date, SYSDATE +
                                                     1)
            AND person_party_id = p_person_party_id;

      CURSOR csr_chk_qtc_fnd_user (
         p_user_name                     IN       VARCHAR2
      )
      IS
         SELECT f.person_party_id,
                f.start_date,
                f.end_date,
                f.encrypted_user_password
           FROM fnd_user f
          WHERE f.user_name = p_user_name;

      CURSOR l_resp_csr (
         p_resp_key                               VARCHAR2
      )
      IS
         SELECT responsibility_id
           FROM fnd_responsibility
          WHERE responsibility_key = p_resp_key
            AND SYSDATE BETWEEN NVL (start_date, SYSDATE)
                            AND NVL (end_date, SYSDATE);

      CURSOR l_security_grp_csr (
         p_security_grp_key                       VARCHAR2
      )
      IS
         SELECT security_group_id
           FROM fnd_security_groups
          WHERE security_group_key = p_security_grp_key;

      CURSOR csr_get_per_party_name (p_party_id IN NUMBER) IS
      SELECT party_name
        FROM hz_parties
       WHERE party_id = p_party_id;

      l_oks_per_party_name           hz_parties.party_name%TYPE;
      l_fnd_per_party_name           hz_parties.party_name%TYPE;

      CURSOR csr_get_party_name (p_party_id IN NUMBER) IS
       SELECT p.party_name , p.party_id
         FROM hz_relationships r , hz_parties p
       WHERE p.party_id = r.object_id
         AND r.subject_type='PERSON'
         AND r.object_type='ORGANIZATION'
         AND r.subject_id = p_party_id;

      l_oks_party_name           hz_parties.party_name%TYPE;
      l_fnd_party_name           hz_parties.party_name%TYPE;
      l_oks_party_id             hz_parties.party_id%TYPE;
      l_fnd_party_id             hz_parties.party_id%TYPE;

      /*bug7552071*/
 	         l_result                VARCHAR2(10);
 	         v_counter                NUMBER := 1;

   BEGIN
      -- start debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '100: Entered ' ||
                         g_pkg_name ||
                         '.' ||
                         l_api_name
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '100: Parameter p_user_name : ' ||
                         p_user_name
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '100: p_contract_id : ' ||
                         p_contract_id
                        );
      END IF;

      -- log file
      fnd_file.put_line (fnd_file.LOG, '  ');
      fnd_file.put_line
               (fnd_file.LOG,
                '----------------------------------------------------------  ');
      fnd_file.put_line (fnd_file.LOG, 'Entered create_sso_user');
      fnd_file.put_line (fnd_file.LOG, 'Parameters  ');
      fnd_file.put_line (fnd_file.LOG, 'p_user_name :  ' ||
                          p_user_name);
      fnd_file.put_line (fnd_file.LOG, 'p_contract_id :  ' ||
                          p_contract_id);
      fnd_file.put_line
               (fnd_file.LOG,
                '----------------------------------------------------------  ');
      fnd_file.put_line (fnd_file.LOG, '  ');
      --  Initialize API return status to success
      x_return_status            := fnd_api.g_ret_sts_success;

      -- Get the Person Party Id and quote_to_contact_id from oks_k_headers_b
      OPEN csr_person_party_id;

      FETCH csr_person_party_id
       INTO l_person_party_id,
            l_quote_to_contact_id;

      CLOSE csr_person_party_id;

      -- debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '110: l_person_party_id : ' ||
                         l_person_party_id
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '110: l_quote_to_contact_id : ' ||
                         l_quote_to_contact_id
                        );
      END IF;

      -- log file
      fnd_file.put_line (fnd_file.LOG,
                         'OKS l_person_party_id :  ' ||
                         l_person_party_id);
      fnd_file.put_line (fnd_file.LOG,
                         'OKS l_quote_to_contact_id :  ' ||
                         l_quote_to_contact_id);

      -- if the person_party_id is NULL then get person_party_id for quote_to_contact_id
      IF l_person_party_id IS NULL
      THEN
         OPEN csr_qtc_person_party_id
                              (p_quote_to_contact_id              => l_quote_to_contact_id);

         FETCH csr_qtc_person_party_id
          INTO l_person_party_id;

         CLOSE csr_qtc_person_party_id;

         -- debug log
         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING
                          (fnd_log.level_procedure,
                           g_module ||
                           l_api_name,
                           '120: l_person_party_id for quote to contact: ' ||
                           l_person_party_id
                          );
         END IF;

         -- log file
         fnd_file.put_line (fnd_file.LOG,
                            'HZ l_person_party_id :  ' ||
                            l_person_party_id);

         -- update the oks_k_headers_b with the person_party_id
         UPDATE oks_k_headers_b
            SET person_party_id = l_person_party_id,
                object_version_number = object_version_number +
                                        1,
                last_update_date = SYSDATE,
                last_updated_by = fnd_global.user_id,
                last_update_login = fnd_global.login_id
          WHERE chr_id = p_contract_id;

         -- bump up the minor version number
         UPDATE okc_k_vers_numbers
            SET minor_version = minor_version +
                                1,
                object_version_number = object_version_number +
                                        1,
                last_update_date = SYSDATE,
                last_updated_by = fnd_global.user_id,
                last_update_login = fnd_global.login_id
          WHERE chr_id = p_contract_id;
      END IF;                  -- l_person_party_id is null in oks_k_headers_b

      -- Check if record exists in fnd_user for the above person_party_id
      OPEN csr_check_fnd_user_exists (p_person_party_id                  => l_person_party_id);

      FETCH csr_check_fnd_user_exists
       INTO l_user_id,
            x_user_name,
            x_password;

      CLOSE csr_check_fnd_user_exists;

      -- debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '130: l_user_id : ' ||
                         l_user_id
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '130: x_user_name : ' ||
                         x_user_name
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '130: x_password : ' ||
                         x_password
                        );
      END IF;

      -- log file
      fnd_file.put_line (fnd_file.LOG,
                         'Check FND User record for person_party_id : ' ||
                         l_person_party_id);
      fnd_file.put_line (fnd_file.LOG, 'l_user_id : ' ||
                          l_user_id);
      fnd_file.put_line (fnd_file.LOG, 'x_user_name : ' ||
                          x_user_name);

      -- Check if valid fnd_user found
      IF x_user_name IS NOT NULL
      THEN
         x_password                 := '******';
         -- log file
         fnd_file.put_line (fnd_file.LOG,
                            'Found FND User record for person_party_id : ' ||
                            l_person_party_id);
         -- Bug 4650639
         -- FND USER found, check if this user has the responsibility G_ERN_WEB_RESPONSIBILITY
         fnd_file.put_line (fnd_file.LOG,
                            'Check if the user has ERN responsibility');

         OPEN l_resp_csr (p_resp_key                         => g_ern_web_responsibility);

         FETCH l_resp_csr
          INTO l_responsibility_id;

         CLOSE l_resp_csr;

         OPEN l_security_grp_csr ('STANDARD');

         FETCH l_security_grp_csr
          INTO l_security_grp_id;

         CLOSE l_security_grp_csr;

         IF fnd_user_resp_groups_api.assignment_exists (l_user_id,
                                                        l_responsibility_id,
                                                        515,
                                                        l_security_grp_id
                                                       )
         THEN
            -- user has the ERN responsibility
            fnd_file.put_line (fnd_file.LOG,
                               'user : ' ||
                               x_user_name ||
                               ' has ERN responsibility');
            RETURN;
         ELSE
            -- add responsibility and return
                        -- log file
            fnd_file.put_line (fnd_file.LOG,
                               'user : ' ||
                               x_user_name ||
                               ' DOES NOT HAVE ERN responsibility');
            fnd_file.put_line (fnd_file.LOG,
                               'assign responsibility to user created');
            fnd_file.put_line (fnd_file.LOG,
                               'l_responsibility_id : ' ||
                               l_responsibility_id);
            fnd_file.put_line (fnd_file.LOG,
                               'l_security_grp_id : ' ||
                               l_security_grp_id);
            fnd_user_resp_groups_api.insert_assignment
                                   (user_id                            => l_user_id,
                                    responsibility_id                  => l_responsibility_id,
                                    responsibility_application_id      => 515,
                                    security_group_id                  => l_security_grp_id,
                                    description                        => 'Electronic renewals User',
                                    start_date                         => SYSDATE,
                                    end_date                           => NULL
                                   );
            l_return_value             :=
               fnd_profile.SAVE (x_name                             => 'APPLICATIONS_HOME_PAGE',
                                 x_value                            => 'PHP',
                                 x_level_name                       => 'USER',
                                 x_level_value                      => TO_CHAR
                                                                          (l_user_id)
                                );

            IF l_return_value
            THEN
               RETURN;
            ELSE
                 -- error in fnd_profile.save
               -- debug log
               IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level
                  )
               THEN
                  fnd_log.STRING (fnd_log.level_procedure,
                                  g_module ||
                                  l_api_name,
                                  '135: error in fnd_profile.save : '
                                 );
               END IF;

               -- log file
               fnd_file.put_line (fnd_file.LOG, 'error in fnd_profile.save ');
               fnd_file.put_line (fnd_file.LOG, SQLERRM);
               RAISE fnd_api.g_exc_error;
            END IF;                                         --  l_return_value
         END IF;                                          -- assignment_exists
      END IF;                                  -- x_user_name IS NOT NULL THEN

      -- check in fnd_user if record exists with the user name as quote to contact email
      OPEN csr_chk_qtc_fnd_user (p_user_name                        => UPPER
                                                                          (TRIM
                                                                              (p_user_name)));

      FETCH csr_chk_qtc_fnd_user
       INTO l_fnd_person_party_id,
            l_start_date,
            l_end_date,
            x_password;

      -- debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '140: l_fnd_person_party_id : ' ||
                         l_fnd_person_party_id
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '140: l_start_date : ' ||
                         l_start_date
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '140: l_end_date : ' ||
                         l_end_date
                        );
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '140: x_password : ' ||
                         x_password
                        );
      END IF;

      -- log file
      fnd_file.put_line (fnd_file.LOG,
                         'Check FND User record for user name : ' ||
                         p_user_name);
      fnd_file.put_line (fnd_file.LOG,
                         'l_fnd_person_party_id : ' ||
                         l_fnd_person_party_id);
      fnd_file.put_line (fnd_file.LOG, 'l_start_date : ' ||
                          l_start_date);
      fnd_file.put_line (fnd_file.LOG, 'l_end_date : ' ||
                          l_end_date);

      IF csr_chk_qtc_fnd_user%NOTFOUND
      THEN
         -- create a NEW FND USER
         -- Call the testUserName pkg
         --@ TestUserName() returns:
         --@ USER_OK_CREATE                 constant pls_integer := 0;
         --@ USER_INVALID_NAME              constant pls_integer := 1;
         --@ USER_EXISTS_IN_FND             constant pls_integer := 2;
         --@ USER_SYNCHED                   constant pls_integer := 3;
         --@ USER_EXISTS_NO_LINK_ALLOWED    constant pls_integer := 4;

          -- log file
         fnd_file.put_line
                      (fnd_file.LOG,
                       'Getting Suggested username, calling UMX_PUB.get_suggested_username');

         -- Call API UMX_PUB.get_suggested_username to get the suggested user name
          UMX_PUB.get_suggested_username(p_person_party_id    => l_person_party_id,
		                                 x_suggested_username => l_suggested_user_name);

          -- log file
         fnd_file.put_line
                      (fnd_file.LOG,
                       'Suggested username : '||l_suggested_user_name);

         -- debug log
         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_procedure,
                            g_module ||
                            l_api_name,
                            '145: l_suggested_user_name from UMX_PUB.get_suggested_username : ' ||
                            l_suggested_user_name
                           );
         END IF;

         IF l_suggested_user_name IS NULL THEN
            -- suggested name same as email address
            l_suggested_user_name := UPPER(TRIM(p_user_name));
         END IF;

         -- debug log
         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_procedure,
                            g_module ||
                            l_api_name,
                            '146: l_suggested_user_name : ' ||
                            l_suggested_user_name
                           );
         END IF;

         -- log file
         fnd_file.put_line
                      (fnd_file.LOG,
                       'Creating New user, calling FND_USER_PKG.TestUserName for username :'||l_suggested_user_name);
         l_test_user                :=
            fnd_user_pkg.testusername
                                     (x_user_name                        => l_suggested_user_name);

         -- debug log
         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_procedure,
                            g_module ||
                            l_api_name,
                            '150: l_test_user : ' ||
                            l_test_user
                           );
         END IF;

         -- log file
         fnd_file.put_line
                  (fnd_file.LOG,
                   'After calling FND_USER_PKG.TestUserName l_test_user : ' ||
                   l_test_user);

         IF l_test_user IN (0, 3)
         THEN
            IF l_test_user = 0
            THEN
               -- ok to create a new user
               /*
               x_password := dbms_random.string('l', (NVL(FND_PROFILE.value('SIGNON_PASSWORD_LENGTH'),7)-3))||
                             round(dbms_random.value(100,999));
               */

               -- log file
               fnd_file.put_line
                   (fnd_file.LOG,
                    'ok to create a new user, calling FND_CRYPTO.randombytes');
               x_password                 :=
                  fnd_crypto.randomstring
                           (NVL (fnd_profile.VALUE ('SIGNON_PASSWORD_LENGTH'),
                                 4));
 /*modified for bug7552071*//*modified by sjanakir for FP bug7607862*/
 	          /*    IF Nvl(fnd_profile.value('SIGNON_PASSWORD_HARD_TO_GUESS'),'N') = 'Y' THEN */
 	                 -- loop till password clears the validations
 	                l_result := FND_WEB_SEC.validate_password (l_suggested_user_name, x_password);
 	                 WHILE ((l_result <> 'Y') AND (v_counter <= 100)) LOOP

 	                 -- incrementing the counter
 	                 v_counter := v_counter + 1;

 	                 -- generate password
 	                 x_password                 :=
 	                   fnd_crypto.randomstring
 	                            (NVL (fnd_profile.VALUE ('SIGNON_PASSWORD_LENGTH'),
 	                                  4));

 	                 fnd_file.put_line
 	                    (fnd_file.LOG,
 	                     'validating password, calling FND_WEB_SEC.validate_password');

 	                 l_result := FND_WEB_SEC.validate_password (l_suggested_user_name, x_password);

 	                   IF ( v_counter = 100 ) THEN
 	                     IF ( l_result <> 'Y' ) THEN
 	                       -- Throw exception as even though generated password 100 times, but
 	                       -- cannot pass validation criteria
 	                       fnd_file.put_line(fnd_file.LOG,
 	                                 'password validation failed, raised user defined exception');
 	                       raise_application_error (-20000,'Could not generated password automatically which satisfies validation requirements.');
 	                     END IF;
 	                   END IF;
 	                 END LOOP;
 	         /*     END IF; */
 	                 /*end of modification for bug7552071*/
               l_user_id                  :=
                  fnd_user_pkg.createuseridparty
                                (x_user_name                        => l_suggested_user_name,
                                 x_owner                            => 'SEED',
                                 x_unencrypted_password             => x_password,
                                 x_description                      => 'Electronic renewals User',
                                 x_email_address                    => UPPER
                                                                          (TRIM
                                                                              (p_user_name)),
                                 x_person_party_id                  => l_person_party_id
                                );
               x_user_name                := l_suggested_user_name;
               -- log file
               fnd_file.put_line
                             (fnd_file.LOG,
                              'FND_USER_PKG.CreateUserIdParty l_user_id : ' ||
                              l_user_id);
            ELSE                                            -- l_test_user = 3
               -- USER_SYNCHED                   constant pls_integer := 3;
               -- Call the FND_USER_PKG.CreateUserIdParty WITHOUT password as password exists in OID
               -- in Notification, put the password as '******'

               -- log file
               fnd_file.put_line
                     (fnd_file.LOG,
                      'USER_SYNCHED , calling FND_USER_PKG.CreateUserIdParty');
               l_user_id                  :=
                  fnd_user_pkg.createuseridparty
                                (x_user_name                        => l_suggested_user_name,
                                 x_owner                            => 'SEED',
                                 x_description                      => 'Electronic renewals User',
                                 x_email_address                    => UPPER
                                                                          (TRIM
                                                                              (p_user_name)),
                                 x_person_party_id                  => l_person_party_id
                                );
               x_user_name                := l_suggested_user_name;
               x_password                 := '******';
               -- log file
               fnd_file.put_line
                             (fnd_file.LOG,
                              'FND_USER_PKG.CreateUserIdParty l_user_id : ' ||
                              l_user_id);
            END IF;                                    -- l_test_user = 0 or 3

            -- debug log
            IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING (fnd_log.level_procedure,
                               g_module ||
                               l_api_name,
                               '160: l_user_id : ' ||
                               l_user_id
                              );
               fnd_log.STRING (fnd_log.level_procedure,
                               g_module ||
                               l_api_name,
                               '160: x_user_name : ' ||
                               x_user_name
                              );
               fnd_log.STRING (fnd_log.level_procedure,
                               g_module ||
                               l_api_name,
                               '160: x_password : ' ||
                               x_password
                              );
            END IF;

            -- log file
            fnd_file.put_line (fnd_file.LOG, 'l_user_id : ' ||
                                l_user_id);
            fnd_file.put_line (fnd_file.LOG, 'x_user_name : ' ||
                                x_user_name);

            IF l_user_id IS NOT NULL
            THEN
               -- assign responsibility to user created
               OPEN l_resp_csr (p_resp_key                         => g_ern_web_responsibility);

               FETCH l_resp_csr
                INTO l_responsibility_id;

               CLOSE l_resp_csr;

               OPEN l_security_grp_csr ('STANDARD');

               FETCH l_security_grp_csr
                INTO l_security_grp_id;

               CLOSE l_security_grp_csr;

               -- debug log
               IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level
                  )
               THEN
                  fnd_log.STRING (fnd_log.level_procedure,
                                  g_module ||
                                  l_api_name,
                                  '170: l_responsibility_id : ' ||
                                  l_responsibility_id
                                 );
                  fnd_log.STRING (fnd_log.level_procedure,
                                  g_module ||
                                  l_api_name,
                                  '170: l_security_grp_id : ' ||
                                  l_security_grp_id
                                 );
               END IF;

               -- log file
               fnd_file.put_line (fnd_file.LOG,
                                  'assign responsibility to user created');
               fnd_file.put_line (fnd_file.LOG,
                                  'l_responsibility_id : ' ||
                                  l_responsibility_id);
               fnd_file.put_line (fnd_file.LOG,
                                  'l_security_grp_id : ' ||
                                  l_security_grp_id);
               fnd_user_resp_groups_api.insert_assignment
                                   (user_id                            => l_user_id,
                                    responsibility_id                  => l_responsibility_id,
                                    responsibility_application_id      => 515,
                                    security_group_id                  => l_security_grp_id,
                                    description                        => 'Electronic renewals User',
                                    start_date                         => SYSDATE,
                                    end_date                           => NULL
                                   );
               l_return_value             :=
                  fnd_profile.SAVE (x_name                             => 'APPLICATIONS_HOME_PAGE',
                                    x_value                            => 'FWK',
                                    x_level_name                       => 'USER',
                                    x_level_value                      => TO_CHAR
                                                                             (l_user_id)
                                   );

               IF l_return_value
               THEN
                  RETURN;
               ELSE
                    -- error in fnd_profile.save
                  -- debug log
                  IF (fnd_log.level_procedure >=
                                               fnd_log.g_current_runtime_level
                     )
                  THEN
                     fnd_log.STRING (fnd_log.level_procedure,
                                     g_module ||
                                     l_api_name,
                                     '180: error in fnd_profile.save : '
                                    );
                  END IF;

                  -- log file
                  fnd_file.put_line (fnd_file.LOG,
                                     'error in fnd_profile.save ');
                  fnd_file.put_line (fnd_file.LOG, SQLERRM);
                  RAISE fnd_api.g_exc_error;
               END IF;
            ELSE
               -- l_user_id is null, raise exception
                  -- debug log
               IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level
                  )
               THEN
                  fnd_log.STRING (fnd_log.level_procedure,
                                  g_module ||
                                  l_api_name,
                                  '190: l_user_id is null, raise exception '
                                 );
               END IF;

               -- log file
               fnd_file.put_line (fnd_file.LOG,
                                  'l_user_id is null, raise exception ');
               fnd_file.put_line (fnd_file.LOG, SQLERRM);
               RAISE fnd_api.g_exc_error;
            END IF;                                   -- l_user_id is not null
         ELSE                                           -- l_test_user <> 0 ,3
            -- error, raise exception
            fnd_message.set_name ('OKS', 'OKS_SSO_TEST_USER_ERROR');
            fnd_message.set_token ('RETURN_VAL', l_test_user);
            fnd_msg_pub.ADD;
            -- log file
            fnd_file.put_line (fnd_file.LOG, 'OKS_SSO_TEST_USER_ERROR');
            fnd_file.put_line (fnd_file.LOG, 'l_test_user: ' ||
                                l_test_user);
            RAISE fnd_api.g_exc_error;
         END IF;                                          -- l_test_user check
      ELSE                                       -- csr_chk_qtc_fnd_user%FOUND
         -- check if the above fnd_user is valid
         IF SYSDATE BETWEEN l_start_date AND NVL (l_end_date, SYSDATE +
                                                   1)
         THEN
            -- fnd user is valid

            -- log file
            fnd_file.put_line
               (fnd_file.LOG,
                'chk_qtc_fnd_user%FOUND, check if the above fnd_user is valid');
            fnd_file.put_line (fnd_file.LOG,
                               'l_fnd_person_party_id : ' ||
                               l_fnd_person_party_id);
            fnd_file.put_line (fnd_file.LOG,
                               'l_person_party_id : ' ||
                               l_person_party_id);

            -- Check the person_party_id of the fnd_user
            IF l_fnd_person_party_id IS NULL
            THEN
               -- fnd_user.person_party_id IS NULL
               UPDATE fnd_user
                  SET person_party_id = l_person_party_id
                WHERE user_name = UPPER (TRIM (p_user_name));
            ELSIF l_person_party_id <> l_fnd_person_party_id
            THEN
                  --codefix for bug 5893305
                  --check the value of the profile option oks_override_sso and update
                  --oks_k_headers_b table accordingly.
                  IF NVL(FND_PROFILE.VALUE('OKS_OVERRIDE_SSO'),'N') <>'N'
                  THEN
                     fnd_file.put_line (fnd_file.LOG,'Overriding SSO behavior');
                     --update oks_k_headers_b with fnd_profile value.
                     UPDATE oks_k_headers_b
                       SET person_party_id =l_fnd_person_party_id
                     WHERE chr_id=p_contract_id;
                     fnd_file.put_line (fnd_file.LOG,'OKS Person Party ID updated to:'||l_fnd_person_party_id);
                  ELSE

                     fnd_file.put_line (fnd_file.LOG,'Using SSO behavior');
               -- fnd_user.person_party_id does NOT match oks_person_party_id
               -- get the party names from hz_parties and raise error
               -- oks person party name
                OPEN csr_get_per_party_name (p_party_id => l_person_party_id);
                   FETCH csr_get_per_party_name INTO l_oks_per_party_name;
                CLOSE csr_get_per_party_name;
                 -- log file
                 fnd_file.put_line (fnd_file.LOG,'OKS Person Party Name: '||l_oks_per_party_name);

               -- fnd person party name
                OPEN csr_get_per_party_name (p_party_id => l_fnd_person_party_id);
                   FETCH csr_get_per_party_name INTO l_fnd_per_party_name;
                CLOSE csr_get_per_party_name;
                 -- log file
                 fnd_file.put_line (fnd_file.LOG,'FND Person Party Name: '||l_fnd_per_party_name);

                -- get the party name (organization name) for oks person
                OPEN csr_get_party_name (p_party_id => l_person_party_id);
                  FETCH csr_get_party_name INTO l_oks_party_name, l_oks_party_id;
                CLOSE csr_get_party_name;
                -- log file
                 fnd_file.put_line (fnd_file.LOG,'OKS Party Name: '||l_oks_party_name);
                 fnd_file.put_line (fnd_file.LOG,'OKS Party ID: '||l_oks_party_id);

                 -- get the party name (organization name) for FND person
                OPEN csr_get_party_name (p_party_id => l_fnd_person_party_id);
                  FETCH csr_get_party_name INTO l_fnd_party_name, l_fnd_party_id;
                CLOSE csr_get_party_name;
                -- log file
                 fnd_file.put_line (fnd_file.LOG,'FND Party Name: '||l_fnd_party_name);
                 fnd_file.put_line (fnd_file.LOG,'FND Party ID: '||l_fnd_party_id);

               -- set error message
               fnd_message.set_name ('OKS', 'OKS_SSO_PERSON_PARTY_ERROR');
               fnd_message.set_token ('OKS_USER_NAME', p_user_name);
	       fnd_message.set_token ('OKS_PARTY_ID', l_oks_party_id);
	       fnd_message.set_token ('OKS_PARTY_NAME', l_oks_party_name);
	       fnd_message.set_token ('FND_PARTY_ID', l_fnd_party_id);
	       fnd_message.set_token ('FND_PARTY_NAME', l_fnd_party_name);
	       fnd_message.set_token ('OKS_PERSON_PARTY_ID', l_person_party_id);
               fnd_message.set_token ('FND_PERSON_PARTY_ID', l_fnd_person_party_id);
               fnd_message.set_token ('OKS_PERSON_PARTY_NAME', l_oks_per_party_name); -- bug 6338286
               fnd_message.set_token ('FND_PERSON_PARTY_NAME', l_fnd_per_party_name); -- bug 6338286
               fnd_msg_pub.ADD;

               -- log file
               fnd_file.put_line (fnd_file.LOG, 'OKS_SSO_PERSON_PARTY_ERROR');
               RAISE fnd_api.g_exc_error;
              END IF; --profile value check
            END IF;                                   -- person_party_id check

            x_user_name := UPPER (TRIM (p_user_name));
            x_password  := '******';  -- bug 5357772

            CLOSE csr_chk_qtc_fnd_user;

            RETURN;
         ELSE
            -- fnd user has expired RAISE exception;
            fnd_message.set_name ('OKS', 'OKS_SSO_USER_EXPIRED');
            fnd_message.set_token ('USER_NAME', UPPER (TRIM (p_user_name)));
            fnd_msg_pub.ADD;
            -- log file
            fnd_file.put_line (fnd_file.LOG, 'OKS_SSO_USER_EXPIRED ');
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;

      CLOSE csr_chk_qtc_fnd_user;

      -- log file
      fnd_file.put_line (fnd_file.LOG, '  ');
      fnd_file.put_line
               (fnd_file.LOG,
                '----------------------------------------------------------  ');
      fnd_file.put_line (fnd_file.LOG, 'Leaving create_sso_user');
      fnd_file.put_line
               (fnd_file.LOG,
                '----------------------------------------------------------  ');
      fnd_file.put_line (fnd_file.LOG, '  ');
-- Standard call to get message count and if count is 1, get message info.
      fnd_msg_pub.count_and_get (p_encoded                          => 'F',
                                 p_count                            => x_msg_count,
                                 p_data                             => x_msg_data
                                );


      -- end debug log
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         g_module ||
                         l_api_name,
                         '1000: Leaving ' ||
                         g_pkg_name ||
                         '.' ||
                         l_api_name
                        );
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_procedure,
                            g_module ||
                            l_api_name,
                            '2000: Leaving ' ||
                            g_pkg_name ||
                            '.' ||
                            l_api_name
                           );
         END IF;

         fnd_file.put_line (fnd_file.LOG, '2000: Leaving create_sso_user');

         x_return_status            := g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_encoded                          => 'F',
                                    p_count                            => x_msg_count,
                                    p_data                             => x_msg_data
                                   );
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_procedure,
                            g_module ||
                            l_api_name,
                            '3000: Leaving ' ||
                            g_pkg_name ||
                            '.' ||
                            l_api_name
                           );
         END IF;

         fnd_file.put_line (fnd_file.LOG, '3000: Leaving create_sso_user');

         x_return_status            := g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         fnd_msg_pub.count_and_get (p_encoded                          => 'F',
                                    p_count                            => x_msg_count,
                                    p_data                             => x_msg_data
                                   );
      WHEN OTHERS
      THEN
         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_procedure,
                            g_module ||
                            l_api_name,
                            '4000: Leaving ' ||
                            g_pkg_name ||
                            '.' ||
                            l_api_name
                           );
         END IF;

         fnd_file.put_line (fnd_file.LOG, '4000: Leaving create_sso_user');

         x_return_status            := g_ret_sts_error;
         fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         fnd_msg_pub.count_and_get (p_encoded                          => 'F',
                                    p_count                            => x_msg_count,
                                    p_data                             => x_msg_data
                                   );
   END create_sso_user;
END oks_auto_reminder;

/
