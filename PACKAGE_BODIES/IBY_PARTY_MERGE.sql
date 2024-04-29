--------------------------------------------------------
--  DDL for Package Body IBY_PARTY_MERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_PARTY_MERGE" AS
/* $Header: ibyptymergb.pls 120.0.12010000.5 2010/03/24 11:16:01 sgogula noship $ */

  G_DEBUG_MODULE CONSTANT VARCHAR2(100) := 'iby.plsql.IBY_PARTY_MERGE';


  PROCEDURE acct_owner_merge
  (p_entity_name   IN     VARCHAR2,
   p_from_id       IN     NUMBER,
   p_to_id         IN     OUT NOCOPY NUMBER,
   p_from_fk_id    IN     NUMBER,
   p_to_fk_id      IN     NUMBER,
   p_parent_entity_name IN VARCHAR2,
   p_batch_id      IN     NUMBER,
   p_batch_party_id IN    NUMBER,
   x_return_status IN     OUT NOCOPY VARCHAR2
   )
   IS
     l_dup_id         iby_account_owners.account_owner_party_id%TYPE := NULL;
     l_merge_reason   VARCHAR2(30);
     l_dbg_mod        VARCHAR2(100) := G_DEBUG_MODULE || '.acct_owner_merge';
     g_mesg           VARCHAR2(1000) := '';

    CURSOR c_dupeba
    (ci_owner_id IN iby_account_owners.account_owner_id%TYPE,
     ci_party_id IN iby_account_owners.account_owner_party_id%TYPE)
    IS
      SELECT account_owner_id
      FROM iby_account_owners mto,
        ( SELECT ext_bank_account_id
          FROM iby_account_owners
	  WHERE (account_owner_id = ci_owner_id) ) mfrom
      WHERE mto.account_owner_party_id = ci_party_id
      AND mto.ext_bank_account_id = mfrom.ext_bank_account_id;

   BEGIN

     g_mesg := 'Enter';
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );

     g_mesg := 'p_entity_name' || p_entity_name;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );
     g_mesg := 'p_from_id' || p_from_id;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );
     g_mesg := 'p_to_id' || p_to_id;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );
     g_mesg := 'p_from_fk_id' || p_from_fk_id;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );
     g_mesg := 'p_to_fk_id' || p_to_fk_id;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );
     g_mesg := 'p_parent_entity_name' || p_parent_entity_name;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );
     g_mesg := 'p_batch_id' || p_batch_id;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF c_dupeba%ISOPEN THEN CLOSE c_dupeba; END IF;

     IF (p_from_fk_id = p_to_fk_id) THEN
       p_to_id := p_from_id;
       RETURN;
     END IF;

     SELECT merge_reason_code
     INTO l_merge_reason
     FROM hz_merge_batch
     WHERE batch_id = p_batch_id;

   IF (p_parent_entity_name = 'HZ_PARTIES') THEN

     IF ( (l_merge_reason <> 'DUPLICATE') AND
          (l_merge_reason <> 'MERGER') AND
          (l_merge_reason <> 'DEDUPE') AND
          (l_merge_reason <> 'DUPLICATE_RELN_PARTY') AND
          (l_merge_reason <> 'De-duplication Merge') )
     THEN
       g_mesg := 'cannot unify non-duplicate bank account owners';
       fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );

       fnd_message.set_name('IBY','IBY_PARTY_UNIFY_BA_VETO');
       fnd_msg_pub.ADD;
       x_return_status := fnd_api.g_ret_sts_error;
       RETURN;
     END IF;

     OPEN c_dupeba(p_from_id,p_to_fk_id);
     FETCH c_dupeba INTO l_dup_id;
     CLOSE c_dupeba;

     g_mesg := 'duplicate account owner:='|| l_dup_id;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );

     UPDATE iby_account_owners
     SET account_owner_party_id = DECODE(l_dup_id, NULL,p_to_fk_id, account_owner_party_id),
       end_date = DECODE(l_dup_id, NULL,end_date, SYSDATE),
       last_update_date = hz_utility_pub.last_update_date,
       last_updated_by = hz_utility_pub.user_id,
       last_update_login = hz_utility_pub.last_update_login
     WHERE (account_owner_id = p_from_id);

     IF (l_dup_id IS NULL) THEN
       p_to_id := p_from_id;
     ELSE
       p_to_id := l_dup_id;
     END IF;

   END IF;
     g_mesg := 'Exit';
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );

     EXCEPTION
     WHEN OTHERS THEN

     g_mesg := 'Unexpected error:=' || SQLERRM;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );

     FND_MESSAGE.SET_NAME('IBY', 'IBY_9999');
     FND_MESSAGE.SET_TOKEN('MESSAGE_TEXT' ,SQLERRM);
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   END acct_owner_merge;



  PROCEDURE credit_card_merge
  (p_entity_name   IN     VARCHAR2,
   p_from_id       IN     NUMBER,
   p_to_id         IN     OUT NOCOPY NUMBER,
   p_from_fk_id    IN     NUMBER,
   p_to_fk_id      IN     NUMBER,
   p_parent_entity_name IN VARCHAR2,
   p_batch_id      IN     NUMBER,
   p_batch_party_id IN    NUMBER,
   x_return_status IN     OUT NOCOPY VARCHAR2
   )
   IS

    CURSOR c_dupecc
    (ci_instr_id IN iby_creditcard.instrid%TYPE,
     ci_owner_id IN iby_creditcard.card_owner_id%TYPE)
    IS
      SELECT instrid
      FROM iby_creditcard mto,
        (SELECT cc_number_hash1, cc_number_hash2
         FROM iby_creditcard WHERE (instrid = ci_instr_id)) mfrom
      WHERE
        mto.card_owner_id = ci_owner_id
        AND mto.cc_number_hash1 = mfrom.cc_number_hash1
        AND mto.cc_number_hash2 = mfrom.cc_number_hash2
        AND NVL(mto.active_flag,'Y') = 'Y'
        AND (NVL(mto.inactive_date,SYSDATE+10) > SYSDATE);

    l_merge_reason    VARCHAR2(30);
    l_dup_id          iby_creditcard.instrid%TYPE := NULL;
    l_dbg_mod         VARCHAR2(100) := G_DEBUG_MODULE || '.credit_card_merge';
    g_mesg           VARCHAR2(1000) := '';

   BEGIN

     g_mesg := 'Enter';
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );

     g_mesg := 'p_entity_name' || p_entity_name;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );
     g_mesg := 'p_from_id' || p_from_id;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );
     g_mesg := 'p_to_id' || p_to_id;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );
     g_mesg := 'p_from_fk_id' || p_from_fk_id;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );
     g_mesg := 'p_to_fk_id' || p_to_fk_id;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );
     g_mesg := 'p_parent_entity_name' || p_parent_entity_name;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );
     g_mesg := 'p_batch_id' || p_batch_id;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF (c_dupecc%ISOPEN) THEN CLOSE c_dupecc; END IF;

     SELECT merge_reason_code
     INTO l_merge_reason
     FROM hz_merge_batch
     WHERE batch_id = p_batch_id;

     IF (p_from_fk_id = p_to_fk_id) THEN
       p_to_id := p_from_id;
       RETURN;
     END IF;

     IF (p_parent_entity_name = 'HZ_PARTIES') THEN

     IF ( (l_merge_reason <> 'DUPLICATE') AND
          (l_merge_reason <> 'MERGER') AND
          (l_merge_reason <> 'DEDUPE') AND
          (l_merge_reason <> 'DUPLICATE_RELN_PARTY') AND
          (l_merge_reason <> 'De-duplication Merge') )
      THEN
	  g_mesg :='cannot unify non-duplicate credit cards';
	  fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );

          fnd_message.set_name('IBY','IBY_PARTY_UNIFY_CC_VETO');
          fnd_msg_pub.ADD;
         x_return_status := fnd_api.g_ret_sts_error;
	  RETURN;
       END IF;


       OPEN c_dupecc(p_from_id,p_to_fk_id);
       FETCH c_dupecc INTO l_dup_id;
       CLOSE c_dupecc;

       g_mesg :='duplicate card:='|| l_dup_id;
       fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );

       UPDATE iby_creditcard
       SET card_owner_id = DECODE(l_dup_id, NULL,p_to_fk_id, card_owner_id),
         active_flag = DECODE(l_dup_id, NULL,active_flag, 'N'),
         inactive_date = DECODE(l_dup_id, NULL,inactive_date, SYSDATE),
         last_update_date = hz_utility_pub.last_update_date,
         last_updated_by = hz_utility_pub.user_id,
         last_update_login = hz_utility_pub.last_update_login,
         request_id =  hz_utility_pub.request_id,
         program_application_id = hz_utility_pub.program_application_id,
         program_id = hz_utility_pub.program_id,
         program_update_date = sysdate
       WHERE (instrid = p_from_id);

       p_to_id := NVL(l_dup_id,p_from_id);

     ELSIF (p_parent_entity_name = 'HZ_PARTY_SITE_USES') THEN

       UPDATE iby_creditcard
       SET addressid = p_to_fk_id,
         last_update_date = hz_utility_pub.last_update_date,
         last_updated_by = hz_utility_pub.user_id,
         last_update_login = hz_utility_pub.last_update_login,
         request_id =  hz_utility_pub.request_id,
         program_application_id = hz_utility_pub.program_application_id,
         program_id = hz_utility_pub.program_id,
         program_update_date = sysdate
       WHERE (instrid = p_from_id);

       p_to_id := p_from_id;

     END IF;

     g_mesg :='Exit';
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );

   EXCEPTION
     WHEN OTHERS THEN

     g_mesg :='Unexpected error:=' || SQLERRM;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );

     FND_MESSAGE.SET_NAME('IBY', 'IBY_9999');
     FND_MESSAGE.SET_TOKEN('MESSAGE_TEXT' ,SQLERRM);
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   END credit_card_merge;


  PROCEDURE external_payer_merge
  (p_entity_name   IN     VARCHAR2,
   p_from_id       IN     NUMBER,
   p_to_id         IN     OUT NOCOPY NUMBER,
   p_from_fk_id    IN     NUMBER,
   p_to_fk_id      IN     NUMBER,
   p_parent_entity_name IN VARCHAR2,
   p_batch_id      IN     NUMBER,
   p_batch_party_id IN    NUMBER,
   x_return_status IN     OUT NOCOPY VARCHAR2
   )
  IS

    CURSOR c_dupepayer
    (ci_payer_id IN iby_external_payers_all.ext_payer_id%TYPE,
     ci_party_id IN iby_external_payers_all.party_id%TYPE)
    IS
      SELECT ext_payer_id
      FROM iby_external_payers_all mto,
        (SELECT payment_function,ci_party_id,cust_account_id,acct_site_use_id,
           org_type,org_id
         FROM iby_external_payers_all
         WHERE (ext_payer_id = ci_payer_id)) mfrom
      WHERE mto.ext_payer_id <> ci_payer_id
        AND mto.payment_function = mfrom.payment_function
        AND mto.party_id = ci_party_id
        AND NVL(mto.cust_account_id,-99) = NVL(mfrom.cust_account_id,-99)
        AND NVL(mto.acct_site_use_id,-99) = NVL(mfrom.acct_site_use_id,-99)
        AND NVL(mto.org_type,'!') = NVL(mfrom.org_type,'!')
        AND NVL(mto.org_id,-99) = NVL(mfrom.org_id,-99);

    l_dbg_mod         VARCHAR2(100) := G_DEBUG_MODULE || '.external_payer_merge';
    l_dup_id          iby_external_payers_all.ext_payer_id%TYPE;
    g_mesg            VARCHAR2(1000) := '';

  BEGIN

     g_mesg := 'Enter';
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );

     g_mesg := 'p_entity_name' || p_entity_name;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );
     g_mesg := 'p_from_id' || p_from_id;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );
     g_mesg := 'p_to_id' || p_to_id;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );
     g_mesg := 'p_from_fk_id' || p_from_fk_id;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );
     g_mesg := 'p_to_fk_id' || p_to_fk_id;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );
     g_mesg := 'p_parent_entity_name' || p_parent_entity_name;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );
     g_mesg := 'p_batch_id' || p_batch_id;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF (c_dupepayer%ISOPEN) THEN CLOSE c_dupepayer; END IF;

     IF (p_parent_entity_name = 'HZ_PARTIES') THEN

       IF (p_from_fk_id = p_to_fk_id) THEN
         p_to_id := p_from_id;
         RETURN;
       END IF;

       OPEN c_dupepayer(p_from_id,p_to_fk_id);
       FETCH c_dupepayer INTO l_dup_id;
       CLOSE c_dupepayer;

       g_mesg := 'duplicate payer:='|| l_dup_id;
       fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );

       IF (l_dup_id IS NULL) THEN
         UPDATE iby_external_payers_all
         SET party_id = p_to_fk_id,
           last_update_date = hz_utility_pub.last_update_date,
           last_updated_by = hz_utility_pub.user_id,
           last_update_login = hz_utility_pub.last_update_login
         WHERE ext_payer_id = p_from_id;
         p_to_id := p_from_id;
       ELSE
         p_to_id := l_dup_id;
       END IF;
     END IF;

     g_mesg := 'Exit';
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );

   EXCEPTION
     WHEN OTHERS THEN

       g_mesg := 'Unexpected error:=' || SQLERRM;
       fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );

       FND_MESSAGE.SET_NAME('IBY', 'IBY_9999');
       FND_MESSAGE.SET_TOKEN('MESSAGE_TEXT' ,SQLERRM);
       FND_MSG_PUB.ADD;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END external_payer_merge;

  PROCEDURE pmt_instrument_use_merge
  (p_entity_name   IN     VARCHAR2,
   p_from_id       IN     NUMBER,
   p_to_id         IN     OUT NOCOPY NUMBER,
   p_from_fk_id    IN     NUMBER,
   p_to_fk_id      IN     NUMBER,
   p_parent_entity_name IN VARCHAR2,
   p_batch_id      IN     NUMBER,
   p_batch_party_id IN    NUMBER,
   x_return_status IN     OUT NOCOPY VARCHAR2
   )
   IS

     l_dbg_mod   VARCHAR2(100) := G_DEBUG_MODULE || '.pmt_instrument_use_merge';
     l_dup_id    iby_pmt_instr_uses_all.instrument_payment_use_id%TYPE := NULL;
     l_flow_type iby_pmt_instr_uses_all.payment_flow%TYPE;
     g_mesg           VARCHAR2(1000) := '';

     CURSOR c_dupinstr
    (ci_use_id   IN iby_pmt_instr_uses_all.instrument_payment_use_id%TYPE,
     ci_instr_id IN iby_pmt_instr_uses_all.instrument_id%TYPE,
     ci_instr_type IN iby_pmt_instr_uses_all.instrument_type%TYPE)
     IS
      SELECT mto.instrument_payment_use_id
      FROM iby_pmt_instr_uses_all mto,
        (SELECT ext_pmt_party_id,payment_flow
         FROM iby_pmt_instr_uses_all
         WHERE instrument_payment_use_id = ci_use_id) mfrom
      WHERE
         mto.instrument_payment_use_id <> ci_use_id
         AND mto.payment_flow = mfrom.payment_flow
         AND mto.ext_pmt_party_id = mfrom.ext_pmt_party_id
         AND mto.instrument_type = ci_instr_type
         AND mto.instrument_id = ci_instr_id;

     CURSOR c_dupeparty
    (ci_use_id   IN iby_pmt_instr_uses_all.instrument_payment_use_id%TYPE,
     ci_party_id IN iby_pmt_instr_uses_all.ext_pmt_party_id%TYPE,
     ci_flow_type IN iby_pmt_instr_uses_all.payment_flow%TYPE)
    IS
      SELECT mto.instrument_payment_use_id
      FROM iby_pmt_instr_uses_all mto,
        (SELECT instrument_type,instrument_id
         FROM iby_pmt_instr_uses_all
         WHERE instrument_payment_use_id = ci_use_id) mfrom
      WHERE
         mto.instrument_payment_use_id <> ci_use_id
         AND mto.payment_flow = ci_flow_type
         AND mto.ext_pmt_party_id = ci_party_id
         AND mto.instrument_type = mfrom.instrument_type
         AND mto.instrument_id = mfrom.instrument_id;

   BEGIN

     g_mesg := 'Enter';
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );

     g_mesg := 'p_entity_name' || p_entity_name;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );
     g_mesg := 'p_from_id' || p_from_id;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );
     g_mesg := 'p_to_id' || p_to_id;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );
     g_mesg := 'p_from_fk_id' || p_from_fk_id;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );
     g_mesg := 'p_to_fk_id' || p_to_fk_id;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );
     g_mesg := 'p_parent_entity_name' || p_parent_entity_name;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );
     g_mesg := 'p_batch_id' || p_batch_id;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF (c_dupinstr%ISOPEN) THEN CLOSE c_dupinstr; END IF;
     IF (c_dupeparty%ISOPEN) THEN CLOSE c_dupeparty; END IF;

     IF (p_parent_entity_name = 'IBY_CREDITCARD') THEN

       IF (p_from_fk_id = p_to_fk_id) THEN
         p_to_id := p_from_id;
         RETURN;
       END IF;

       OPEN c_dupinstr(p_from_id,p_to_fk_id,'CREDITCARD');
       FETCH c_dupinstr INTO l_dup_id;
       CLOSE c_dupinstr;

       g_mesg := 'duplicate instr use:='|| l_dup_id;
       fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );

       UPDATE iby_pmt_instr_uses_all
       SET instrument_id = DECODE(l_dup_id, NULL,p_to_fk_id, instrument_id),
         end_date = DECODE(l_dup_id, NULL,end_date, SYSDATE),
         last_update_date = hz_utility_pub.last_update_date,
         last_updated_by = hz_utility_pub.user_id,
         last_update_login = hz_utility_pub.last_update_login
       WHERE (instrument_payment_use_id = p_from_id);

       IF (l_dup_id IS NULL) THEN
         p_to_id := p_from_id;
       ELSE
         p_to_id := l_dup_id;
       END IF;

     ELSIF (p_parent_entity_name = 'IBY_EXTERNAL_PAYERS_ALL')
     THEN

       IF (p_from_fk_id = p_to_fk_id) THEN
         p_to_id := p_from_id;
         RETURN;
       END IF;

       l_flow_type := 'FUNDS_CAPTURE';

       OPEN c_dupeparty(p_from_id,p_to_fk_id,l_flow_type);
       FETCH c_dupeparty INTO l_dup_id;
       CLOSE c_dupeparty;

       g_mesg := 'duplicate instr use:='|| l_dup_id;
       fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );

       UPDATE iby_pmt_instr_uses_all
       SET ext_pmt_party_id = DECODE(l_dup_id, NULL,p_to_fk_id, ext_pmt_party_id),
         end_date = DECODE(l_dup_id, NULL,end_date, SYSDATE),
         last_update_date = hz_utility_pub.last_update_date,
         last_updated_by = hz_utility_pub.user_id,
         last_update_login = hz_utility_pub.last_update_login
       WHERE (instrument_payment_use_id = p_from_id);

       IF (l_dup_id IS NULL) THEN
         p_to_id := p_from_id;
       ELSE
         p_to_id := l_dup_id;
       END IF;

     END IF;

     g_mesg := 'Exit';
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );

   EXCEPTION
     WHEN OTHERS THEN
       g_mesg := 'Unexpected error:=' || SQLERRM;
       fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );

       FND_MESSAGE.SET_NAME('IBY', 'IBY_9999');
       FND_MESSAGE.SET_TOKEN('MESSAGE_TEXT' ,SQLERRM);
       FND_MSG_PUB.ADD;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   END pmt_instrument_use_merge;


  PROCEDURE party_pmt_methods_merge
  (p_entity_name   IN     VARCHAR2,
   p_from_id       IN     NUMBER,
   p_to_id         IN     OUT NOCOPY NUMBER,
   p_from_fk_id    IN     NUMBER,
   p_to_fk_id      IN     NUMBER,
   p_parent_entity_name IN VARCHAR2,
   p_batch_id      IN     NUMBER,
   p_batch_party_id IN    NUMBER,
   x_return_status IN     OUT NOCOPY VARCHAR2
   )
   IS
     l_dbg_mod        VARCHAR2(100) := G_DEBUG_MODULE || '.party_pmt_methods_merge';
     l_dup_id         iby_ext_party_pmt_mthds.ext_party_pmt_mthd_id%TYPE := NULL;
     l_flow_type      iby_ext_party_pmt_mthds.payment_flow%TYPE;
     g_mesg           VARCHAR2(1000) := '';

     CURSOR c_dupemth
     (ci_mth_id   IN iby_ext_party_pmt_mthds.ext_party_pmt_mthd_id%TYPE,
      ci_party_id IN iby_ext_party_pmt_mthds.ext_pmt_party_id%TYPE,
      ci_flow_type IN iby_ext_party_pmt_mthds.payment_flow%TYPE)
     IS
       SELECT ext_party_pmt_mthd_id
       FROM iby_ext_party_pmt_mthds mto,
         (SELECT payment_method_code
          FROM iby_ext_party_pmt_mthds
          WHERE (ext_party_pmt_mthd_id = ci_mth_id)) mfrom
       WHERE
         mto.ext_pmt_party_id = ci_party_id
         AND mto.payment_flow = ci_flow_type
         AND mto.payment_method_code = mfrom.payment_method_code;


   BEGIN

     g_mesg := 'Enter';
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );

     g_mesg := 'p_entity_name' || p_entity_name;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );
     g_mesg := 'p_from_id' || p_from_id;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );
     g_mesg := 'p_to_id' || p_to_id;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );
     g_mesg := 'p_from_fk_id' || p_from_fk_id;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );
     g_mesg := 'p_to_fk_id' || p_to_fk_id;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );
     g_mesg := 'p_parent_entity_name' || p_parent_entity_name;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );
     g_mesg := 'p_batch_id' || p_batch_id;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF (p_from_fk_id = p_to_fk_id) THEN
       p_to_id := p_from_id;
       RETURN;
     END IF;

     IF (p_parent_entity_name = 'IBY_EXTERNAL_PAYERS_ALL') THEN
       l_flow_type := 'FUNDS_CAPTURE';

       OPEN c_dupemth(p_from_id,p_to_fk_id,l_flow_type);
       FETCH c_dupemth INTO l_dup_id;
       CLOSE c_dupemth;

       g_mesg := 'duplicate pmt method:='|| l_dup_id;
       fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );

       UPDATE iby_ext_party_pmt_mthds
       SET ext_pmt_party_id = DECODE(l_dup_id, NULL,p_to_fk_id, ext_pmt_party_id),
         inactive_date = DECODE(l_dup_id, NULL,inactive_date, SYSDATE),
         last_update_date = hz_utility_pub.last_update_date,
         last_updated_by = hz_utility_pub.user_id,
         last_update_login = hz_utility_pub.last_update_login
       WHERE (ext_party_pmt_mthd_id = p_from_id);

       IF (l_dup_id IS NULL) THEN
         p_to_id := p_from_id;
       ELSE
         p_to_id := l_dup_id;
       END IF;
     END IF;

     g_mesg := 'Exit';
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );

   EXCEPTION
     WHEN OTHERS THEN
       g_mesg := 'Unexpected error:=' || SQLERRM;
       fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );

       FND_MESSAGE.SET_NAME('IBY', 'IBY_9999');
       FND_MESSAGE.SET_TOKEN('MESSAGE_TEXT' ,SQLERRM);
       FND_MSG_PUB.ADD;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   END party_pmt_methods_merge;

  PROCEDURE fc_tx_extensions_merge
  (p_entity_name   IN     VARCHAR2,
   p_from_id       IN     NUMBER,
   p_to_id         IN     OUT NOCOPY NUMBER,
   p_from_fk_id    IN     NUMBER,
   p_to_fk_id      IN     NUMBER,
   p_parent_entity_name IN VARCHAR2,
   p_batch_id      IN     NUMBER,
   p_batch_party_id IN    NUMBER,
   x_return_status IN     OUT NOCOPY VARCHAR2
   )
   IS
     l_dbg_mod        VARCHAR2(100) := G_DEBUG_MODULE || '.fc_tx_extensions_merge';
     g_mesg           VARCHAR2(1000) := '';

   BEGIN
     g_mesg := 'Enter';
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );

     g_mesg := 'p_entity_name' || p_entity_name;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );
     g_mesg := 'p_from_id' || p_from_id;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );
     g_mesg := 'p_to_id' || p_to_id;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );
     g_mesg := 'p_from_fk_id' || p_from_fk_id;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );
     g_mesg := 'p_to_fk_id' || p_to_fk_id;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );
     g_mesg := 'p_parent_entity_name' || p_parent_entity_name;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );
     g_mesg := 'p_batch_id' || p_batch_id;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- extension is a transactional entity,it is never merged
     p_to_id := p_from_id;

     IF (p_from_fk_id = p_to_fk_id) THEN
       p_to_id := p_from_id;
       RETURN;
     END IF;

     IF (p_parent_entity_name = 'IBY_EXTERNAL_PAYERS_ALL') THEN

       UPDATE iby_fndcpt_tx_extensions
       SET ext_payer_id = p_to_fk_id,
         last_update_date = hz_utility_pub.last_update_date,
         last_updated_by = hz_utility_pub.user_id,
         last_update_login = hz_utility_pub.last_update_login
       WHERE (trxn_extension_id = p_from_id);

     ELSIF (p_parent_entity_name = 'IBY_PMT_INSTR_USES_ALL') THEN

       UPDATE iby_fndcpt_tx_extensions
       SET instr_assignment_id = p_to_fk_id,
         last_update_date = hz_utility_pub.last_update_date,
         last_updated_by = hz_utility_pub.user_id,
         last_update_login = hz_utility_pub.last_update_login
       WHERE (trxn_extension_id = p_from_id);

     END IF;

     g_mesg := 'Exit';
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );

   EXCEPTION
     WHEN OTHERS THEN
       g_mesg := 'Unexpected error:=' || SQLERRM;
       fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );

       FND_MESSAGE.SET_NAME('IBY', 'IBY_9999');
       FND_MESSAGE.SET_TOKEN('MESSAGE_TEXT' ,SQLERRM);
       FND_MSG_PUB.ADD;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   END fc_tx_extensions_merge;


  PROCEDURE txn_summ_all_merge
  (p_entity_name   IN     VARCHAR2,
   p_from_id       IN     NUMBER,
   p_to_id         IN     OUT NOCOPY NUMBER,
   p_from_fk_id    IN     NUMBER,
   p_to_fk_id      IN     NUMBER,
   p_parent_entity_name IN VARCHAR2,
   p_batch_id      IN     NUMBER,
   p_batch_party_id IN    NUMBER,
   x_return_status IN     OUT NOCOPY VARCHAR2
   )
   IS
     l_dbg_mod        VARCHAR2(100) := G_DEBUG_MODULE || '.txn_summ_all_merge';
     g_mesg           VARCHAR2(1000) := '';

   BEGIN
     g_mesg := 'Enter';
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );

     g_mesg := 'p_entity_name' || p_entity_name;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );
     g_mesg := 'p_from_id' || p_from_id;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );
     g_mesg := 'p_to_id' || p_to_id;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );
     g_mesg := 'p_from_fk_id' || p_from_fk_id;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );
     g_mesg := 'p_to_fk_id' || p_to_fk_id;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );
     g_mesg := 'p_parent_entity_name' || p_parent_entity_name;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );
     g_mesg := 'p_batch_id' || p_batch_id;
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- summaries is a transactional entity,it is never merged
     p_to_id := p_from_id;

     IF (p_from_fk_id = p_to_fk_id) THEN
       p_to_id := p_from_id;
       RETURN;
     END IF;

     IF (p_parent_entity_name = 'HZ_PARTIES') THEN

       UPDATE iby_trxn_summaries_all
       SET payerid = p_to_fk_id,
         last_update_date = hz_utility_pub.last_update_date,
         last_updated_by = hz_utility_pub.user_id,
         last_update_login = hz_utility_pub.last_update_login
       WHERE (trxnmid = p_from_id);

     ELSIF (p_parent_entity_name = 'IBY_PMT_INSTR_USES_ALL') THEN

       UPDATE iby_trxn_summaries_all
       SET payer_instr_assignment_id = p_to_fk_id,
         last_update_date = hz_utility_pub.last_update_date,
         last_updated_by = hz_utility_pub.user_id,
         last_update_login = hz_utility_pub.last_update_login
       WHERE (trxnmid = p_from_id);

     ELSIF (p_parent_entity_name = 'IBY_CREDITCARD') THEN

       UPDATE iby_trxn_summaries_all
       SET payerinstrid = p_to_fk_id,
         last_update_date = hz_utility_pub.last_update_date,
         last_updated_by = hz_utility_pub.user_id,
         last_update_login = hz_utility_pub.last_update_login
       WHERE (trxnmid = p_from_id)
         AND (instrtype = 'CREDITCARD');

     END IF;

     g_mesg := 'Exit';
     fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );

   EXCEPTION
     WHEN OTHERS THEN
       g_mesg := 'Unexpected error:=' || SQLERRM;
       fnd_file.put_line(fnd_file.log, g_mesg || l_dbg_mod );

       FND_MESSAGE.SET_NAME('IBY', 'IBY_9999');
       FND_MESSAGE.SET_TOKEN('MESSAGE_TEXT' ,SQLERRM);
       FND_MSG_PUB.ADD;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   END txn_summ_all_merge;


END IBY_PARTY_MERGE;


/