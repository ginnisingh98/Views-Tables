--------------------------------------------------------
--  DDL for Package Body CE_BANK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CE_BANK_PUB" AS
/*$Header: ceextbab.pls 120.12.12010000.12 2009/12/23 09:56:39 vnetan ship $ */

  --l_DEBUG varchar2(1) := NVL(FND_PROFILE.value('CE_DEBUG'), 'N');
  l_DEBUG varchar2(1) := 'Y';


  /*=======================================================================+
   | PRIVATE FUNCTION get_country					   |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Get country of the bank given the bank party_id.                    |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | MODIFICATION HISTORY                                                  |
   |   07-SEP-2004    Xin Wang      Created.  	                           |
   +=======================================================================*/
  FUNCTION get_country (
    p_bank_id		   IN     NUMBER,
    x_return_status        IN OUT NOCOPY VARCHAR2
  ) RETURN VARCHAR2 IS
    CURSOR c_country IS
      SELECT org.home_country
      FROM   hz_organization_profiles  org
      WHERE  org.party_id = p_bank_id
      AND    SYSDATE between TRUNC(effective_start_date)
             and NVL(TRUNC(effective_end_date), SYSDATE+1);
    l_country	VARCHAR2(60);
  BEGIN
    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    OPEN c_country;
    FETCH c_country INTO l_country;
    IF c_country%NOTFOUND THEN
      fnd_message.set_name('CE', 'CE_API_NO_BANK');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
    END IF;
    CLOSE c_country;

    RETURN NVL(l_country, 'NULL');
  END get_country;


  /*=======================================================================+
   | PRIVATE PROCEDURE find_bank_info                                      |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Get the party_id and country of the bank given a bank_branch_id.    |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | MODIFICATION HISTORY                                                  |
   |   08-SEP-2004    Xin Wang      Created.                               |
   +=======================================================================*/
  PROCEDURE find_bank_info (
    p_branch_id            IN     NUMBER,
    x_return_status        IN OUT NOCOPY VARCHAR2,
    x_bank_id		   OUT    NOCOPY NUMBER,
    x_country_code	   OUT    NOCOPY VARCHAR2,
    x_bank_name		   OUT    NOCOPY VARCHAR2,
    x_bank_number          OUT    NOCOPY VARCHAR2
  ) IS
    CURSOR c_bank IS
      SELECT hz_bank.party_id AS bank_id,
	     hz_bankorg.home_country,
             hz_bank.party_name,
             hz_bankorg.bank_or_branch_number
      FROM   hz_parties                hz_bank,
             hz_organization_profiles  hz_bankorg,
             hz_parties                hz_branch,
             hz_relationships          hz_rel,
             hz_code_assignments       hz_bankCA,
             hz_code_assignments       hz_branchCA
      WHERE  hz_branchCA.owner_table_name = 'HZ_PARTIES'
      AND    hz_branchCA.owner_table_id = hz_branch.party_id
      AND    hz_branchCA.class_category = 'BANK_INSTITUTION_TYPE'
      AND    hz_branchCA.class_code = 'BANK_BRANCH'
      AND    NVL(hz_branchCA.STATUS, 'A') = 'A'
      AND    hz_bankCA.CLASS_CATEGORY = 'BANK_INSTITUTION_TYPE'
      AND    hz_bankCA.CLASS_CODE = 'BANK'
      AND    hz_bankCA.OWNER_TABLE_NAME = 'HZ_PARTIES'
      AND    hz_bankCA.OWNER_TABLE_ID = hz_bank.PARTY_ID
      AND    NVL(hz_bankCA.STATUS, 'A') = 'A'
      AND    hz_rel.OBJECT_ID = hz_bank.PARTY_ID
      And    hz_branch.PARTY_ID = hz_rel.SUBJECT_ID
      And    hz_rel.RELATIONSHIP_TYPE = 'BANK_AND_BRANCH'
      And    hz_rel.RELATIONSHIP_CODE = 'BRANCH_OF'
      And    hz_rel.STATUS = 'A'
      And    hz_rel.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
      And    hz_rel.SUBJECT_TYPE =  'ORGANIZATION'
      And    hz_rel.OBJECT_TABLE_NAME = 'HZ_PARTIES'
      And    hz_rel.OBJECT_TYPE = 'ORGANIZATION'
      AND    hz_bank.party_id = hz_bankorg.party_id
      AND    SYSDATE between TRUNC(hz_bankorg.effective_start_date)
             and NVL(TRUNC(hz_bankorg.effective_end_date), SYSDATE+1)
      AND    hz_branch.party_id = p_branch_id;
  BEGIN
    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    OPEN c_bank;
    FETCH c_bank INTO x_bank_id, x_country_code, x_bank_name, x_bank_number;
    IF c_bank%NOTFOUND THEN
      fnd_message.set_name('CE', 'CE_API_NO_BANK');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
    END IF;
    CLOSE c_bank;

  END find_bank_info;


   /*=======================================================================+
   | PUBLIC PROCEDURE create_bank                                          |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Create a bank as a TCA organization party.                          |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_bank_pub.create_bank                                             |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list          Initialize message stack if it is set to |
   |                              FND_API.G_TRUE. Default is fnd_api.g_false
   |     p_country_code             Country code of the bank.              |
   |     p_bank_name                Bank name.                             |
   |     p_bank_number              Bank number.                           |
   |     p_alternate_bank_name      Alternate bank name.                   |
   |     p_short_bank_name          Short bank name.                       |
   |     p_description              Description.                           |
   |     p_tax_payer_id             Tax payer ID.                          |
   |     p_tax_registration_number  Tax registration number                |
   |   IN/OUT:                                                             |
   |   OUT:                                                                |
   |     x_bank_id            Party ID for the bank.                       |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   25-AUG-2004    Xin Wang           Created.                          |
   +=======================================================================*/
  PROCEDURE create_bank (
        p_init_msg_list            IN     VARCHAR2:= fnd_api.g_false,
        p_country_code             IN     VARCHAR2,
        p_bank_name                IN     VARCHAR2,
        p_bank_number              IN     VARCHAR2 DEFAULT NULL,
        p_alternate_bank_name      IN     VARCHAR2 DEFAULT NULL,
        p_short_bank_name          IN     VARCHAR2 DEFAULT NULL,
        p_description              IN     VARCHAR2 DEFAULT NULL,
        p_tax_payer_id             IN     VARCHAR2 DEFAULT NULL,
        p_tax_registration_number  IN     VARCHAR2 DEFAULT NULL,
        p_attribute_category       IN     VARCHAR2 DEFAULT NULL,
        p_attribute1               IN     VARCHAR2 DEFAULT NULL,
        p_attribute2               IN     VARCHAR2 DEFAULT NULL,
        p_attribute3               IN     VARCHAR2 DEFAULT NULL,
        p_attribute4               IN     VARCHAR2 DEFAULT NULL,
        p_attribute5               IN     VARCHAR2 DEFAULT NULL,
        p_attribute6               IN     VARCHAR2 DEFAULT NULL,
        p_attribute7               IN     VARCHAR2 DEFAULT NULL,
        p_attribute8               IN     VARCHAR2 DEFAULT NULL,
        p_attribute9               IN     VARCHAR2 DEFAULT NULL,
        p_attribute10              IN     VARCHAR2 DEFAULT NULL,
        p_attribute11              IN     VARCHAR2 DEFAULT NULL,
        p_attribute12              IN     VARCHAR2 DEFAULT NULL,
        p_attribute13              IN     VARCHAR2 DEFAULT NULL,
        p_attribute14              IN     VARCHAR2 DEFAULT NULL,
        p_attribute15              IN     VARCHAR2 DEFAULT NULL,
        p_attribute16              IN     VARCHAR2 DEFAULT NULL,
        p_attribute17              IN     VARCHAR2 DEFAULT NULL,
        p_attribute18              IN     VARCHAR2 DEFAULT NULL,
        p_attribute19              IN     VARCHAR2 DEFAULT NULL,
        p_attribute20              IN     VARCHAR2 DEFAULT NULL,
        p_attribute21              IN     VARCHAR2 DEFAULT NULL,
        p_attribute22              IN     VARCHAR2 DEFAULT NULL,
        p_attribute23              IN     VARCHAR2 DEFAULT NULL,
        p_attribute24              IN     VARCHAR2 DEFAULT NULL,
        x_bank_id                  OUT  NOCOPY  NUMBER,
        x_return_status            OUT  NOCOPY  VARCHAR2,
        x_msg_count                OUT  NOCOPY  NUMBER,
        x_msg_data                 OUT  NOCOPY  VARCHAR2
  ) IS
    l_bank_rec  	 hz_bank_pub.bank_rec_type;
    l_org_rec   	 hz_party_v2pub.organization_rec_type;
    l_party_rec 	 hz_party_v2pub.party_rec_type;
    l_party_number  	 VARCHAR2(30);
    l_profile_id    	 NUMBER(15);
    l_code_assignment_id NUMBER(15);
    l_bank_number	 VARCHAR2(30);
    l_gen_party_num      VARCHAR2(1);
  BEGIN
    SAVEPOINT create_bank;

    IF l_DEBUG in ('Y', 'C') THEN
      cep_standard.debug('>>CE_EXT_BANK_ACCT_PUB.create_bank.');
    END IF;

    -- initialize message list
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    -- first check all required params
    IF (p_country_code IS NULL or
        p_bank_name IS NULL) THEN
      fnd_message.set_name('CE', 'CE_API_REQUIRED_PARAM');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- country specific validation API call here
    ce_validate_bankinfo.ce_validate_bank(p_country_code,
					  p_bank_number,
					  p_bank_name,
					  p_alternate_bank_name,
					  p_tax_payer_id,
					  null,    -- bank_id
                                          FND_API.G_FALSE,  -- do not re-initialize msg stack
                                          x_msg_count,
					  x_msg_data,
					  l_bank_number,   -- reformated bank number
					  x_return_status);

    -- raise an exception if country specific validations fail
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    l_party_rec.attribute_category := p_attribute_category;
    l_party_rec.attribute1 := p_attribute1;
    l_party_rec.attribute2 := p_attribute2;
    l_party_rec.attribute3 := p_attribute3;
    l_party_rec.attribute4 := p_attribute4;
    l_party_rec.attribute5 := p_attribute5;
    l_party_rec.attribute6 := p_attribute6;
    l_party_rec.attribute7 := p_attribute7;
    l_party_rec.attribute8 := p_attribute8;
    l_party_rec.attribute9 := p_attribute9;
    l_party_rec.attribute10 := p_attribute10;
    l_party_rec.attribute11 := p_attribute11;
    l_party_rec.attribute12 := p_attribute12;
    l_party_rec.attribute13 := p_attribute13;
    l_party_rec.attribute14 := p_attribute14;
    l_party_rec.attribute15 := p_attribute15;
    l_party_rec.attribute16 := p_attribute16;
    l_party_rec.attribute17 := p_attribute17;
    l_party_rec.attribute18 := p_attribute18;
    l_party_rec.attribute19 := p_attribute19;
    l_party_rec.attribute20 := p_attribute20;
    l_party_rec.attribute21 := p_attribute21;
    l_party_rec.attribute22 := p_attribute22;
    l_party_rec.attribute23 := p_attribute23;
    l_party_rec.attribute24 := p_attribute24;

    l_org_rec.organization_name := p_bank_name;
    l_org_rec.organization_name_phonetic := p_alternate_bank_name;
    l_org_rec.known_as := p_short_bank_name;
    l_org_rec.mission_statement := p_description;
    l_org_rec.jgzz_fiscal_code := p_tax_payer_id;
    l_org_rec.tax_reference := p_tax_registration_number;
    l_org_rec.created_by_module := 'CE';
    l_org_rec.party_rec := l_party_rec;

    l_bank_rec.bank_or_branch_number := l_bank_number;
    l_bank_rec.country := p_country_code;
    l_bank_rec.institution_type := 'BANK';
    l_bank_rec.organization_rec := l_org_rec;

    l_gen_party_num := fnd_profile.value('HZ_GENERATE_PARTY_NUMBER');
    if (l_gen_party_num = 'N') then
      fnd_profile.put('HZ_GENERATE_PARTY_NUMBER', 'Y');
    end if;

    hz_bank_pub.create_bank(fnd_api.g_false, l_bank_rec, x_bank_id, l_party_number,
   			    l_profile_id, l_code_assignment_id,
			    x_return_status, x_msg_count, x_msg_data);

    if (l_gen_party_num = 'N') then
      fnd_profile.put('HZ_GENERATE_PARTY_NUMBER', 'N');
    end if;

    -- raise an exception if error creating bank
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);

    IF l_DEBUG in ('Y', 'C') THEN
      cep_standard.debug('<<CE_EXT_BANK_ACCT_PUB.create_bank.');
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_bank;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      IF l_DEBUG in ('Y', 'C') THEN
        cep_standard.debug_msg_stack(x_msg_count, x_msg_data);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_bank;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      IF l_DEBUG in ('Y', 'C') THEN
        cep_standard.debug_msg_stack(x_msg_count, x_msg_data);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO create_bank;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('CE', 'CE_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR',SQLERRM);
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      IF l_DEBUG in ('Y', 'C') THEN
        cep_standard.debug_msg_stack(x_msg_count, x_msg_data);
      END IF;

  END create_bank;


   /*=======================================================================+
   | PUBLIC PROCEDURE update_bank                                          |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Update a bank organization.                                         |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_bank_pub.update_bank                                             |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list          Initialize message stack if it is set to |
   |                              FND_API.G_TRUE. Default is fnd_api.g_false
   |     p_bank_id                  Party ID of the bank to be updated.    |
   |     p_bank_name                Bank name.                             |
   |     p_bank_number              Bank number.                           |
   |     p_alternate_bank_name      Alternate bank name.                   |
   |     p_short_bank_name          Short bank name.                       |
   |     p_description              Description.                           |
   |     p_tax_payer_id             Tax payer ID.                          |
   |     p_tax_registration_number  Tax registration number                |
   |   IN/OUT:                                                             |
   |     p_object_version_number Current object version number for the bank|
   |   OUT:                                                                |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   25-AUG-2004    Xin Wang           Created.			   |
   |   05-MAR-2009    TALAPATI  Added a new parameter p_country_validate   |
   |                            to enable or disable the country specific  |
   |                            validation.(Bug #8286747)                  |
   +=======================================================================*/
  PROCEDURE update_bank (
        p_init_msg_list            IN     VARCHAR2:= fnd_api.g_false,
        p_bank_id                  IN     NUMBER,
        p_bank_name                IN     VARCHAR2,
        p_bank_number              IN     VARCHAR2 DEFAULT NULL,
        p_alternate_bank_name      IN     VARCHAR2 DEFAULT NULL,
        p_short_bank_name          IN     VARCHAR2 DEFAULT NULL,
        p_description              IN     VARCHAR2 DEFAULT NULL,
        p_tax_payer_id             IN     VARCHAR2 DEFAULT NULL,
        p_tax_registration_number  IN     VARCHAR2 DEFAULT NULL,
        p_attribute_category       IN     VARCHAR2 DEFAULT NULL,
        p_attribute1               IN     VARCHAR2 DEFAULT NULL,
        p_attribute2               IN     VARCHAR2 DEFAULT NULL,
        p_attribute3               IN     VARCHAR2 DEFAULT NULL,
        p_attribute4               IN     VARCHAR2 DEFAULT NULL,
        p_attribute5               IN     VARCHAR2 DEFAULT NULL,
        p_attribute6               IN     VARCHAR2 DEFAULT NULL,
        p_attribute7               IN     VARCHAR2 DEFAULT NULL,
        p_attribute8               IN     VARCHAR2 DEFAULT NULL,
        p_attribute9               IN     VARCHAR2 DEFAULT NULL,
        p_attribute10              IN     VARCHAR2 DEFAULT NULL,
        p_attribute11              IN     VARCHAR2 DEFAULT NULL,
        p_attribute12              IN     VARCHAR2 DEFAULT NULL,
        p_attribute13              IN     VARCHAR2 DEFAULT NULL,
        p_attribute14              IN     VARCHAR2 DEFAULT NULL,
        p_attribute15              IN     VARCHAR2 DEFAULT NULL,
        p_attribute16              IN     VARCHAR2 DEFAULT NULL,
        p_attribute17              IN     VARCHAR2 DEFAULT NULL,
        p_attribute18              IN     VARCHAR2 DEFAULT NULL,
        p_attribute19              IN     VARCHAR2 DEFAULT NULL,
        p_attribute20              IN     VARCHAR2 DEFAULT NULL,
        p_attribute21              IN     VARCHAR2 DEFAULT NULL,
        p_attribute22              IN     VARCHAR2 DEFAULT NULL,
        p_attribute23              IN     VARCHAR2 DEFAULT NULL,
        p_attribute24              IN     VARCHAR2 DEFAULT NULL,
	p_country_validate         IN     VARCHAR2 DEFAULT 'Y',
        p_object_version_number    IN OUT NOCOPY  NUMBER,
        x_return_status            OUT    NOCOPY  VARCHAR2,
        x_msg_count                OUT    NOCOPY  NUMBER,
        x_msg_data                 OUT    NOCOPY  VARCHAR2
  ) IS
    l_bank_rec           hz_bank_pub.bank_rec_type;
    l_org_rec            hz_party_v2pub.organization_rec_type;
    l_party_rec          hz_party_v2pub.party_rec_type;
    l_profile_id         NUMBER(15);
    l_ca_object_version_number	NUMBER(15);
    l_country_code	 VARCHAR2(60);
    l_bank_number        VARCHAR2(30);
  BEGIN
    SAVEPOINT update_bank;

    IF l_DEBUG in ('Y', 'C') THEN
      cep_standard.debug('>>CE_EXT_BANK_ACCT_PUB.update_bank.');
    END IF;

    -- initialize message list
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    -- first check all required params
    IF (p_bank_id IS NULL or
        p_bank_name IS NULL) THEN
      fnd_message.set_name('CE', 'CE_API_REQUIRED_PARAM');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
      RAISE fnd_api.g_exc_error;
    END IF;

    l_country_code := get_country(p_bank_id, x_return_status);

    -- raise an exception if bank is not found
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- country specific validation API call here
    ce_validate_bankinfo.ce_validate_bank(l_country_code,
                                          p_bank_number,
                                          p_bank_name,
                                          p_alternate_bank_name,
                                          p_tax_payer_id,
                                          p_bank_id,    -- bank_id
                                          FND_API.G_FALSE,  -- do not re-initialize msg stack
                                          x_msg_count,
                                          x_msg_data,
                                          l_bank_number,   -- reformated bank number
                                          x_return_status);

     -- Bug #8286747 The country specific validation errors are reported only if p_country_validate is set to 'Y'
   -- raise an exception if country specific validations fail
    IF x_return_status <> fnd_api.g_ret_sts_success and upper(p_country_validate) ='Y' THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    l_party_rec.party_id := p_bank_id;
    l_party_rec.attribute_category := p_attribute_category;
    l_party_rec.attribute1 := p_attribute1;
    l_party_rec.attribute2 := p_attribute2;
    l_party_rec.attribute3 := p_attribute3;
    l_party_rec.attribute4 := p_attribute4;
    l_party_rec.attribute5 := p_attribute5;
    l_party_rec.attribute6 := p_attribute6;
    l_party_rec.attribute7 := p_attribute7;
    l_party_rec.attribute8 := p_attribute8;
    l_party_rec.attribute9 := p_attribute9;
    l_party_rec.attribute10 := p_attribute10;
    l_party_rec.attribute11 := p_attribute11;
    l_party_rec.attribute12 := p_attribute12;
    l_party_rec.attribute13 := p_attribute13;
    l_party_rec.attribute14 := p_attribute14;
    l_party_rec.attribute15 := p_attribute15;
    l_party_rec.attribute16 := p_attribute16;
    l_party_rec.attribute17 := p_attribute17;
    l_party_rec.attribute18 := p_attribute18;
    l_party_rec.attribute19 := p_attribute19;
    l_party_rec.attribute20 := p_attribute20;
    l_party_rec.attribute21 := p_attribute21;
    l_party_rec.attribute22 := p_attribute22;
    l_party_rec.attribute23 := p_attribute23;
    l_party_rec.attribute24 := p_attribute24;

    l_org_rec.organization_name := p_bank_name;
    l_org_rec.organization_name_phonetic := p_alternate_bank_name;
    l_org_rec.known_as := p_short_bank_name;
    l_org_rec.mission_statement := p_description;
    l_org_rec.jgzz_fiscal_code := p_tax_payer_id;
    l_org_rec.tax_reference := p_tax_registration_number;
--    8400543: created_by_module should not be udpated.
--    l_org_rec.created_by_module := 'CE';
    l_org_rec.party_rec := l_party_rec;

    l_bank_rec.bank_or_branch_number := l_bank_number;
    l_bank_rec.organization_rec := l_org_rec;

    -- find the object_version_number of the code_assignment for the 'BANK' institution type
    SELECT object_version_number
    INTO   l_ca_object_version_number
    FROM   hz_code_assignments
    WHERE  class_category= 'BANK_INSTITUTION_TYPE'
    AND    owner_table_name = 'HZ_PARTIES'
    AND    owner_table_id = p_bank_id
    AND    status = 'A';

    hz_bank_pub.update_bank(fnd_api.g_false, l_bank_rec,
			    p_object_version_number, l_ca_object_version_number,
			    l_profile_id, x_return_status, x_msg_count, x_msg_data);

    -- raise an exception if error updating a bank
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);

    IF l_DEBUG in ('Y', 'C') THEN
      cep_standard.debug('<<CE_EXT_BANK_ACCT_PUB.update_bank.');
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO update_bank;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      IF l_DEBUG in ('Y', 'C') THEN
        cep_standard.debug_msg_stack(x_msg_count, x_msg_data);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO update_bank;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      IF l_DEBUG in ('Y', 'C') THEN
        cep_standard.debug_msg_stack(x_msg_count, x_msg_data);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO update_bank;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('CE', 'CE_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR',SQLERRM);
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      IF l_DEBUG in ('Y', 'C') THEN
        cep_standard.debug_msg_stack(x_msg_count, x_msg_data);
      END IF;

  END update_bank;


   /*=======================================================================+
   | PUBLIC PROCEDURE set_bank_end_date                                    |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Set the end date of a bank.                                         |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_bank_pub.update_bank                                             |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list          Initialize message stack if it is set to |
   |                              FND_API.G_TRUE. Default is fnd_api.g_false
   |     p_bank_id                Party ID of the bank to be updated.      |
   |     p_end_date               End date of the bank.                    |
   |   IN/OUT:                                                             |
   |     p_object_version_number Current object version number for the code|
   |                             assignment for the bank institution type. |
   |   OUT:                                                                |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   25-AUG-2004    Xin Wang           Created.                          |
   +=======================================================================*/
  PROCEDURE set_bank_end_date (
        p_init_msg_list            IN     VARCHAR2:= fnd_api.g_false,
        p_bank_id                  IN     NUMBER,
        p_end_date                 IN     DATE,
        p_object_version_number    IN OUT NOCOPY  NUMBER,
        x_return_status            OUT    NOCOPY  VARCHAR2,
        x_msg_count                OUT    NOCOPY  NUMBER,
        x_msg_data                 OUT    NOCOPY  VARCHAR2
  ) IS
    CURSOR c_bank IS
      SELECT end_date_active
      FROM   hz_code_assignments
      WHERE  owner_table_name = 'HZ_PARTIES'
      AND    owner_table_id = p_bank_id
      AND    class_category = 'BANK_INSTITUTION_TYPE'
      AND    class_code = 'BANK';
    CURSOR c_branch_id IS
      SELECT subject_id
      FROM   hz_relationships
      WHERE  relationship_type = 'BANK_AND_BRANCH'
      AND    relationship_code = 'BRANCH_OF'
      AND    subject_table_name = 'HZ_PARTIES'
      AND    subject_type = 'ORGANIZATION'
      AND    object_table_name = 'HZ_PARTIES'
      AND    object_type = 'ORGANIZATION'
      AND    object_id = p_bank_id;
    CURSOR c_branch (p_branch_id NUMBER) IS
      SELECT end_date_active, object_version_number
      FROM   hz_code_assignments
      WHERE  owner_table_name = 'HZ_PARTIES'
      AND    owner_table_id = p_branch_id
      AND    class_category = 'BANK_INSTITUTION_TYPE'
      AND    class_code = 'BANK_BRANCH';
    CURSOR c_bank_ovn IS
      SELECT object_version_number
      FROM   hz_parties
      WHERE  party_id = p_bank_id;

    l_bank_end		DATE;
    l_branch_end	DATE;
    l_bank_ovn		NUMBER(15);
    l_branch_ovn	NUMBER(15);
    l_bank_rec          hz_bank_pub.bank_rec_type;
    l_org_rec           hz_party_v2pub.organization_rec_type;
    l_party_rec         hz_party_v2pub.party_rec_type;
    l_profile_id        NUMBER(15);
  BEGIN
    SAVEPOINT set_bank_end_date;

    IF l_DEBUG in ('Y', 'C') THEN
      cep_standard.debug('>>CE_EXT_BANK_ACCT_PUB.set_bank_end_date.');
    END IF;

    -- initialize message list
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    -- first check all required params
    IF (p_bank_id is null or
        p_object_version_number is null) THEN -- Bug 7671686
      fnd_message.set_name('CE', 'CE_API_REQUIRED_PARAM');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- if new end date is earlier than its old end date,
    -- and is earlier than its children's end date
    -- set children's end dates.
    OPEN c_bank;
    FETCH c_bank INTO l_bank_end;
    IF c_bank%NOTFOUND THEN
      fnd_message.set_name('CE', 'CE_API_NO_BANK');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
      CLOSE c_bank;
      RAISE fnd_api.g_exc_error;
    END IF;
    CLOSE c_bank;

    IF p_end_date IS NOT NULL AND p_end_date < NVL(l_bank_end, p_end_date+1) THEN
      FOR branch_id_rec IN c_branch_id LOOP
        OPEN c_branch(branch_id_rec.subject_id);
        FETCH c_branch INTO l_branch_end, l_branch_ovn;
        IF c_branch%NOTFOUND THEN
          fnd_message.set_name('CE', 'CE_API_NO_BRANCH');
          fnd_msg_pub.add;
          x_return_status := fnd_api.g_ret_sts_error;
          CLOSE c_branch;
          RAISE fnd_api.g_exc_error;
        END IF;
        CLOSE c_branch;

        IF p_end_date < NVL(l_branch_end, p_end_date+1) THEN
          set_bank_branch_end_date (fnd_api.g_false,
                                    branch_id_rec.subject_id,
                                    p_end_date,
                                    l_branch_ovn,
                                    x_return_status,
                                    x_msg_count,
                                    x_msg_data);
          IF x_return_status <> fnd_api.g_ret_sts_success THEN
            RAISE fnd_api.g_exc_error;
          END IF;
        END IF;
      END LOOP;
    END IF;

    -- update bank's end date
    l_party_rec.party_id := p_bank_id;
    l_org_rec.party_rec := l_party_rec;
    l_bank_rec.organization_rec := l_org_rec;
    l_bank_rec.inactive_date := p_end_date;

    OPEN c_bank_ovn;
    FETCH c_bank_ovn INTO l_bank_ovn;
    IF c_bank_ovn%NOTFOUND THEN
      fnd_message.set_name('CE', 'CE_API_NO_BANK');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
      CLOSE c_bank_ovn;
      RAISE fnd_api.g_exc_error;
    END IF;
    CLOSE c_bank_ovn;

    hz_bank_pub.update_bank(fnd_api.g_false, l_bank_rec,
                            l_bank_ovn, p_object_version_number,
                            l_profile_id, x_return_status, x_msg_count, x_msg_data);

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);

    IF l_DEBUG in ('Y', 'C') THEN
      cep_standard.debug('<<CE_EXT_BANK_ACCT_PUB.set_bank_end_date.');
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO set_bank_end_date;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      IF l_DEBUG in ('Y', 'C') THEN
        cep_standard.debug_msg_stack(x_msg_count, x_msg_data);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO set_bank_end_date;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      IF l_DEBUG in ('Y', 'C') THEN
        cep_standard.debug_msg_stack(x_msg_count, x_msg_data);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO set_bank_end_date;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('CE', 'CE_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR',SQLERRM);
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      IF l_DEBUG in ('Y', 'C') THEN
        cep_standard.debug_msg_stack(x_msg_count, x_msg_data);
      END IF;

  END set_bank_end_date;

   /*=======================================================================+
   | PUBLIC PROCEDURE check_bank_exist                                     |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Check whether a bank already exists, if so, return the bank ID.     |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_country_code             Country code.                          |
   |     p_bank_name                Bank name.                             |
   |     p_bank_number              Bank number.                           |
   |   IN/OUT:                                                             |
   |   OUT:                                                                |
   |     x_bank_id                  Bank Party ID if bank exists,          |
   |                                null if bank does not exist.           |
   |     x_end_date                 End date of the bank.                  |
   |                                                                       |
   | MODIFICATION HISTORY                                                  |
   |   25-AUG-2004    Xin Wang           Created.                          |
   +=======================================================================*/
  PROCEDURE check_bank_exist(
        p_country_code             IN     VARCHAR2,
        p_bank_name                IN     VARCHAR2,
        p_bank_number              IN     VARCHAR2,
        x_bank_id                  OUT    NOCOPY NUMBER,
        x_end_date                 OUT    NOCOPY DATE
  ) IS
    CURSOR c_bank_name IS
      SELECT hz_hp.party_id,
             hz_ca.end_date_active
      FROM   hz_parties hz_hp,
	     hz_organization_profiles  hz_org,
             hz_code_assignments hz_ca
      WHERE  hz_ca.owner_table_id = hz_hp.party_id
       AND    hz_hp.party_type         = 'ORGANIZATION'  -- Bug 8333484
      AND    NVL(hz_hp.status, 'A') = 'A'   --  Bug 8333484
      AND    hz_ca.owner_table_name = 'HZ_PARTIES'
      AND    hz_ca.class_category = 'BANK_INSTITUTION_TYPE'
      AND    hz_ca.class_code = 'BANK'
      AND    hz_hp.PARTY_ID = hz_org.PARTY_ID
      AND    SYSDATE between TRUNC(hz_org.effective_start_date)
             and NVL(TRUNC(hz_org.effective_end_date), SYSDATE+1)
      AND    hz_org.home_country = p_country_code
      AND    upper(hz_hp.party_name) = upper(p_bank_name);

    CURSOR c_bank_num IS
      SELECT hz_hp.party_id,
             hz_ca.end_date_active
      FROM   hz_parties hz_hp,
             hz_organization_profiles hz_hop,
             hz_code_assignments hz_ca
      WHERE  hz_hp.party_id = hz_hop.party_id
       AND    hz_hp.party_type         = 'ORGANIZATION'  -- Bug 8333484
      AND    NVL(hz_hp.status, 'A') = 'A'  -- Bug 8333484
      AND    SYSDATE between TRUNC(hz_hop.effective_start_date)
             and NVL(TRUNC(hz_hop.effective_end_date), SYSDATE+1)
      AND    hz_ca.owner_table_id = hz_hp.party_id
      AND    hz_ca.owner_table_name = 'HZ_PARTIES'
      AND    hz_ca.class_category = 'BANK_INSTITUTION_TYPE'
      AND    hz_ca.class_code = 'BANK'
      AND    hz_hop.home_country = p_country_code   -- Bug 8992915
      AND    hz_hop.bank_or_branch_number = p_bank_number;

  BEGIN
    IF l_DEBUG in ('Y', 'C') THEN
      cep_standard.debug('>>CE_EXT_BANK_ACCT_PUB.check_bank_exist.');
    END IF;

    IF p_bank_name IS NOT NULL THEN
      OPEN c_bank_name;
      FETCH c_bank_name INTO x_bank_id, x_end_date;
      IF c_bank_name%NOTFOUND THEN
        x_bank_id := null;
        x_end_date := null;
      END IF;
      CLOSE c_bank_name;
    ELSIF p_bank_number IS NOT NULL THEN
      OPEN c_bank_num;
      FETCH c_bank_num INTO x_bank_id, x_end_date;
      IF c_bank_num%NOTFOUND THEN
        x_bank_id := null;
        x_end_date := null;
      END IF;
      CLOSE c_bank_num;
    ELSE
      x_bank_id := null;
      x_end_date := null;
    END IF;

    IF l_DEBUG in ('Y', 'C') THEN
      cep_standard.debug('<<CE_EXT_BANK_ACCT_PUB.check_bank_exist.');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      cep_standard.sql_error('CE_EXT_BANK_ACCT_PUB.check_bank_exist', sqlcode, sqlerrm);

  END check_bank_exist;


   /*=======================================================================+
   | PUBLIC PROCEDURE create_bank_branch                                   |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Create a bank branch as a TCA organization party.                   |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_bank_pub.create_bank_branch                                      |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list          Initialize message stack if it is set to |
   |                              FND_API.G_TRUE. Default is fnd_api.g_false
   |     p_bank_id            Party ID of the bank that the branch   |
   |                                belongs.                               |
   |     p_branch_name              Bank branch name.                      |
   |     p_branch_number            Bank branch number.                    |
   |     p_branch_type              Bank branch type.                      |
   |     p_alternate_branch_name    Alternate bank branch name.            |
   |     p_description              Description.                           |
   |     p_bic                      BIC (Bank Identification Code).        |
   |     p_eft_number               EFT number.                            |
   |     p_rfc_identifier           Regional Finance Center Identifier.    |
   |   IN/OUT:                                                             |
   |   OUT:                                                                |
   |     x_branch_id          Party ID for the bank branch.                |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   25-AUG-2004    Xin Wang           Created.                          |
   +=======================================================================*/
  PROCEDURE create_bank_branch (
        p_init_msg_list              IN     VARCHAR2:= fnd_api.g_false,
        p_bank_id              	     IN     NUMBER,
        p_branch_name                IN     VARCHAR2,
        p_branch_number              IN     VARCHAR2 DEFAULT NULL,
        p_branch_type                IN     VARCHAR2 DEFAULT NULL,
        p_alternate_branch_name      IN     VARCHAR2 DEFAULT NULL,
        p_description                IN     VARCHAR2 DEFAULT NULL,
        p_bic                        IN     VARCHAR2 DEFAULT NULL,
        p_eft_number                 IN     VARCHAR2 DEFAULT NULL,
        p_rfc_identifier             IN     VARCHAR2 DEFAULT NULL,
        p_attribute_category         IN     VARCHAR2 DEFAULT NULL,
        p_attribute1                 IN     VARCHAR2 DEFAULT NULL,
        p_attribute2                 IN     VARCHAR2 DEFAULT NULL,
        p_attribute3                 IN     VARCHAR2 DEFAULT NULL,
        p_attribute4                 IN     VARCHAR2 DEFAULT NULL,
        p_attribute5                 IN     VARCHAR2 DEFAULT NULL,
        p_attribute6                 IN     VARCHAR2 DEFAULT NULL,
        p_attribute7                 IN     VARCHAR2 DEFAULT NULL,
        p_attribute8                 IN     VARCHAR2 DEFAULT NULL,
        p_attribute9                 IN     VARCHAR2 DEFAULT NULL,
        p_attribute10                IN     VARCHAR2 DEFAULT NULL,
        p_attribute11                IN     VARCHAR2 DEFAULT NULL,
        p_attribute12                IN     VARCHAR2 DEFAULT NULL,
        p_attribute13                IN     VARCHAR2 DEFAULT NULL,
        p_attribute14                IN     VARCHAR2 DEFAULT NULL,
        p_attribute15                IN     VARCHAR2 DEFAULT NULL,
        p_attribute16                IN     VARCHAR2 DEFAULT NULL,
        p_attribute17                IN     VARCHAR2 DEFAULT NULL,
        p_attribute18                IN     VARCHAR2 DEFAULT NULL,
        p_attribute19                IN     VARCHAR2 DEFAULT NULL,
        p_attribute20                IN     VARCHAR2 DEFAULT NULL,
        p_attribute21                IN     VARCHAR2 DEFAULT NULL,
        p_attribute22                IN     VARCHAR2 DEFAULT NULL,
        p_attribute23                IN     VARCHAR2 DEFAULT NULL,
        p_attribute24                IN     VARCHAR2 DEFAULT NULL,
        x_branch_id                  OUT  NOCOPY  NUMBER,
        x_return_status              OUT  NOCOPY  VARCHAR2,
        x_msg_count                  OUT  NOCOPY  NUMBER,
        x_msg_data                   OUT  NOCOPY  VARCHAR2
  ) IS
    CURSOR c_bank IS
      SELECT hz_p.party_name, hz_org.bank_or_branch_number
      FROM   hz_parties                 hz_p,
             hz_organization_profiles   hz_org
      WHERE  hz_p.party_id = hz_org.party_id
      AND    SYSDATE between TRUNC(hz_org.effective_start_date)
             and NVL(TRUNC(hz_org.effective_end_date), SYSDATE+1)
      AND    hz_p.party_id = p_bank_id;

    l_branch_rec         	hz_bank_pub.bank_rec_type;
    l_org_rec            	hz_party_v2pub.organization_rec_type;
    l_party_rec          	hz_party_v2pub.party_rec_type;
    l_party_number       	VARCHAR2(30);
    l_profile_id         	NUMBER(15);
    l_rel_id			NUMBER(15);
    l_rel_party_id		NUMBER(15);
    l_rel_party_number		NUMBER(15);
    l_bch_code_assignment_id 	NUMBER(15);
    l_typ_code_assignment_id	NUMBER(15);
    l_rfc_code_assignment_id	NUMBER(15);
    l_contact_point_rec         hz_contact_point_v2pub.contact_point_rec_type;
    l_eft_rec                   hz_contact_point_v2pub.eft_rec_type;
    l_contact_point_id		NUMBER(15);
    l_country			VARCHAR2(60);
    l_branch_number		VARCHAR2(30);
    l_bank_name			VARCHAR2(360);
    l_bank_number		VARCHAR2(30);
    l_gen_party_num		VARCHAR2(1);
  BEGIN
    SAVEPOINT create_bank_branch;

    IF l_DEBUG in ('Y', 'C') THEN
      cep_standard.debug('>>CE_EXT_BANK_ACCT_PUB.create_bank_branch.');
    END IF;

    -- initialize message list
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    -- first check all required params
    IF (p_bank_id IS NULL or
        p_branch_name IS NULL) THEN
      fnd_message.set_name('CE', 'CE_API_REQUIRED_PARAM');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
      RAISE fnd_api.g_exc_error;
    END IF;

    l_country := get_country(p_bank_id, x_return_status);

    -- raise an exception if bank is not found
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    OPEN c_bank;
    FETCH c_bank INTO l_bank_name, l_bank_number;
    IF c_bank%NOTFOUND THEN
      fnd_message.set_name('CE', 'CE_API_NO_BANK');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
      RAISE fnd_api.g_exc_error;
    END IF;
    CLOSE c_bank;

    -- country specific validation API call here
    ce_validate_bankinfo.ce_validate_branch(
        X_COUNTRY_NAME            => l_country,
        X_BANK_NUMBER 	          => l_bank_number,
        X_BRANCH_NUMBER           => p_branch_number,
        X_BANK_NAME 	          => l_bank_name,
        X_BRANCH_NAME 	          => p_branch_name,
        X_BRANCH_NAME_ALT         => p_alternate_branch_name,
        X_BANK_ID 	              => p_bank_id,
        X_BRANCH_ID 	          => null,    -- branch_id
        P_INIT_MSG_LIST           => FND_API.G_FALSE,  -- do not re-initialize msg stack
        X_MSG_COUNT               => x_msg_count,
        X_MSG_DATA                => x_msg_data,
        X_VALUE_OUT               => l_branch_number,   -- reformatted branch number
        X_RETURN_STATUS	          => x_return_status,
        X_ACCOUNT_CLASSIFICATION  => null,               -- 9218190 added
        X_BRANCH_TYPE             => p_branch_type);     -- 9218190 added


    -- raise an exception if country specific validations fail
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    l_party_rec.attribute_category := p_attribute_category;
    l_party_rec.attribute1 := p_attribute1;
    l_party_rec.attribute2 := p_attribute2;
    l_party_rec.attribute3 := p_attribute3;
    l_party_rec.attribute4 := p_attribute4;
    l_party_rec.attribute5 := p_attribute5;
    l_party_rec.attribute6 := p_attribute6;
    l_party_rec.attribute7 := p_attribute7;
    l_party_rec.attribute8 := p_attribute8;
    l_party_rec.attribute9 := p_attribute9;
    l_party_rec.attribute10 := p_attribute10;
    l_party_rec.attribute11 := p_attribute11;
    l_party_rec.attribute12 := p_attribute12;
    l_party_rec.attribute13 := p_attribute13;
    l_party_rec.attribute14 := p_attribute14;
    l_party_rec.attribute15 := p_attribute15;
    l_party_rec.attribute16 := p_attribute16;
    l_party_rec.attribute17 := p_attribute17;
    l_party_rec.attribute18 := p_attribute18;
    l_party_rec.attribute19 := p_attribute19;
    l_party_rec.attribute20 := p_attribute20;
    l_party_rec.attribute21 := p_attribute21;
    l_party_rec.attribute22 := p_attribute22;
    l_party_rec.attribute23 := p_attribute23;
    l_party_rec.attribute24 := p_attribute24;

    l_org_rec.organization_name := p_branch_name;
    l_org_rec.organization_name_phonetic := p_alternate_branch_name;
    l_org_rec.mission_statement := p_description;
    l_org_rec.created_by_module := 'CE';
    l_org_rec.party_rec := l_party_rec;

    l_branch_rec.bank_or_branch_number := l_branch_number;
    l_branch_rec.branch_type := p_branch_type;
    l_branch_rec.rfc_code := p_rfc_identifier;
    l_branch_rec.institution_type := 'BANK_BRANCH';
    l_branch_rec.organization_rec := l_org_rec;
    l_branch_rec.country := l_country;

    l_gen_party_num := fnd_profile.value('HZ_GENERATE_PARTY_NUMBER');
    if (l_gen_party_num = 'N') then
      fnd_profile.put('HZ_GENERATE_PARTY_NUMBER', 'Y');
    end if;

    hz_bank_pub.create_bank_branch(fnd_api.g_false, l_branch_rec, p_bank_id,
			    	   x_branch_id, l_party_number,
                            	   l_profile_id, l_rel_id,
				   l_rel_party_id, l_rel_party_number,
				   l_bch_code_assignment_id, l_typ_code_assignment_id,
				   l_rfc_code_assignment_id,
                            	   x_return_status, x_msg_count, x_msg_data);

    if (l_gen_party_num = 'N') then
      fnd_profile.put('HZ_GENERATE_PARTY_NUMBER', 'N');
    end if;

    -- raise an exception if the branch creation is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    IF p_bic IS NOT NULL OR p_eft_number IS NOT NULL THEN
      l_contact_point_rec.contact_point_type := 'EFT';
      l_contact_point_rec.owner_table_name := 'HZ_PARTIES';
      l_contact_point_rec.owner_table_id := x_branch_id;
      l_contact_point_rec.created_by_module := 'CE';

      l_eft_rec.eft_swift_code := p_bic;
      l_eft_rec.eft_user_number := p_eft_number;

      hz_contact_point_v2pub.create_eft_contact_point
		(fnd_api.g_false, l_contact_point_rec, l_eft_rec,
                 l_contact_point_id,
                 x_return_status, x_msg_count, x_msg_data);

      -- raise an exception if the branch creation is unsuccessful
      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);

    IF l_DEBUG in ('Y', 'C') THEN
      cep_standard.debug('<<CE_EXT_BANK_ACCT_PUB.create_bank_branch.');
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_bank_branch;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      IF l_DEBUG in ('Y', 'C') THEN
        cep_standard.debug_msg_stack(x_msg_count, x_msg_data);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_bank_branch;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      IF l_DEBUG in ('Y', 'C') THEN
        cep_standard.debug_msg_stack(x_msg_count, x_msg_data);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO create_bank_branch;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('CE', 'CE_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR',SQLERRM);
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      IF l_DEBUG in ('Y', 'C') THEN
        cep_standard.debug_msg_stack(x_msg_count, x_msg_data);
      END IF;

  END create_bank_branch;


   /*=======================================================================+
   | PUBLIC PROCEDURE update_bank_branch                                   |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Update a bank branch organization party in TCA.                     |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_bank_pub.update_bank_branch                                      |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list          Initialize message stack if it is set to |
   |                              FND_API.G_TRUE. Default is fnd_api.g_false
   |     p_branch_id                Party ID of the branch to be updated.  |
   |     p_branch_name              Bank branch name.                      |
   |     p_branch_number            Bank branch number.                    |
   |     p_branch_type              Bank branch type.                      |
   |     p_alternate_branch_name    Alternate bank branch name.            |
   |     p_description              Description.                           |
   |     p_bic                      BIC (Bank Identification Code).        |
   |     p_eft_number               EFT number.                            |
   |     p_rfc_identifier           RFC Identifier.                        |
   |   IN/OUT:                                                             |
   |     p_bch_object_version_number    Current object version number for  |
   |                                    the bank branch.                   |
   |     p_typ_object_version_number    Current object version number for  |
   |                                    bank branch type code assignment.  |
   |     p_rfc_object_version_number    Current object version number for  |
   |                                    RFC code assignment.               |
   |   OUT:                                                                |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   25-AUG-2004    Xin Wang           Created.			   |
   |   05-MAR-2009    TALAPATI  Added a new parameter p_country_validate   |
   |                            to enable or disable the country specific  |
   |                            validation. (Bug # 	8286747)           |
   +=======================================================================*/
  PROCEDURE update_bank_branch (
        p_init_msg_list              IN     VARCHAR2:= fnd_api.g_false,
        p_branch_id                  IN     NUMBER,
        p_branch_name                IN     VARCHAR2,
        p_branch_number              IN     VARCHAR2 DEFAULT NULL,
        p_branch_type                IN     VARCHAR2,
        p_alternate_branch_name      IN     VARCHAR2 DEFAULT NULL,
        p_description                IN     VARCHAR2 DEFAULT NULL,
        p_bic                        IN     VARCHAR2 DEFAULT NULL,
        p_eft_number                 IN     VARCHAR2 DEFAULT NULL,
        p_rfc_identifier             IN     VARCHAR2 DEFAULT NULL,
        p_attribute_category         IN     VARCHAR2 DEFAULT NULL,
        p_attribute1                 IN     VARCHAR2 DEFAULT NULL,
        p_attribute2                 IN     VARCHAR2 DEFAULT NULL,
        p_attribute3                 IN     VARCHAR2 DEFAULT NULL,
        p_attribute4                 IN     VARCHAR2 DEFAULT NULL,
        p_attribute5                 IN     VARCHAR2 DEFAULT NULL,
        p_attribute6                 IN     VARCHAR2 DEFAULT NULL,
        p_attribute7                 IN     VARCHAR2 DEFAULT NULL,
        p_attribute8                 IN     VARCHAR2 DEFAULT NULL,
        p_attribute9                 IN     VARCHAR2 DEFAULT NULL,
        p_attribute10                IN     VARCHAR2 DEFAULT NULL,
        p_attribute11                IN     VARCHAR2 DEFAULT NULL,
        p_attribute12                IN     VARCHAR2 DEFAULT NULL,
        p_attribute13                IN     VARCHAR2 DEFAULT NULL,
        p_attribute14                IN     VARCHAR2 DEFAULT NULL,
        p_attribute15                IN     VARCHAR2 DEFAULT NULL,
        p_attribute16                IN     VARCHAR2 DEFAULT NULL,
        p_attribute17                IN     VARCHAR2 DEFAULT NULL,
        p_attribute18                IN     VARCHAR2 DEFAULT NULL,
        p_attribute19                IN     VARCHAR2 DEFAULT NULL,
        p_attribute20                IN     VARCHAR2 DEFAULT NULL,
        p_attribute21                IN     VARCHAR2 DEFAULT NULL,
        p_attribute22                IN     VARCHAR2 DEFAULT NULL,
        p_attribute23                IN     VARCHAR2 DEFAULT NULL,
        p_attribute24                IN     VARCHAR2 DEFAULT NULL,
	p_country_validate           IN     VARCHAR2 DEFAULT 'Y',
        p_bch_object_version_number  IN OUT NOCOPY  NUMBER,
        p_typ_object_version_number  IN OUT NOCOPY  NUMBER,
        p_rfc_object_version_number  IN OUT NOCOPY  NUMBER,
        p_eft_object_version_number  IN OUT NOCOPY  NUMBER,
        x_return_status              OUT    NOCOPY  VARCHAR2,
        x_msg_count                  OUT    NOCOPY  NUMBER,
        x_msg_data                   OUT    NOCOPY  VARCHAR2
  ) IS
    CURSOR c_eft IS
      SELECT contact_point_id
      FROM   hz_contact_points
      WHERE  contact_point_type = 'EFT'
      AND    owner_table_name = 'HZ_PARTIES'
      AND    owner_table_id = p_branch_id;

    l_branch_rec                hz_bank_pub.bank_rec_type;
    l_org_rec                   hz_party_v2pub.organization_rec_type;
    l_party_rec                 hz_party_v2pub.party_rec_type;
    l_party_number              VARCHAR2(30);
    l_profile_id                NUMBER(15);
    l_rel_id                    NUMBER(15);
    l_rel_party_id              NUMBER(15);
    l_rel_party_number          NUMBER(15);
    l_contact_point_rec         hz_contact_point_v2pub.contact_point_rec_type;
    l_eft_rec                   hz_contact_point_v2pub.eft_rec_type;
    l_contact_point_id          NUMBER(15);
    l_bank_id			NUMBER(15);
    l_bank_name			VARCHAR2(360);
    l_bank_number		VARCHAR2(30);
    l_country			VARCHAR2(60);
    l_branch_number		VARCHAR2(30);
  BEGIN
    SAVEPOINT update_bank_branch;

    IF l_DEBUG in ('Y', 'C') THEN
      cep_standard.debug('>>CE_EXT_BANK_ACCT_PUB.update_bank_branch.');
    END IF;

    -- initialize message list
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    -- first check all required params
    IF (p_branch_id IS NULL or
        p_branch_name IS NULL ) THEN
      fnd_message.set_name('CE', 'CE_API_REQUIRED_PARAM');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
      RAISE fnd_api.g_exc_error;
    END IF;

    find_bank_info(p_branch_id, x_return_status, l_bank_id, l_country, l_bank_name, l_bank_number);

    -- raise an exception if bank is not found
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- country specific validation API call here
    ce_validate_bankinfo.ce_validate_branch(
        X_COUNTRY_NAME      => l_country,
        X_BANK_NUMBER       => l_bank_number,
        X_BRANCH_NUMBER     => p_branch_number,
        X_BANK_NAME         => l_bank_name,
        X_BRANCH_NAME       => p_branch_name,
        X_BRANCH_NAME_ALT   => p_alternate_branch_name,
        X_BANK_ID           => l_bank_id,
        X_BRANCH_ID         => p_branch_id,
        P_INIT_MSG_LIST     => FND_API.G_FALSE,  -- do not re-initialize msg stack
        X_MSG_COUNT         => x_msg_count,
        X_MSG_DATA          => x_msg_data,
        X_VALUE_OUT         => l_branch_number,   -- reformatted branch number
        X_RETURN_STATUS     => x_return_status,
        X_ACCOUNT_CLASSIFICATION => NULL,         -- 9218190 added
        X_BRANCH_TYPE       => p_branch_type);    -- 9218190 added

    -- Bug #8286747 The country specific validation errors are reported only if p_country_validate is set to 'Y'
   -- raise an exception if country specific validations fail
    IF x_return_status <> fnd_api.g_ret_sts_success and upper(p_country_validate) ='Y' THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    l_party_rec.party_id := p_branch_id;
    l_party_rec.attribute_category := p_attribute_category;
    l_party_rec.attribute1 := p_attribute1;
    l_party_rec.attribute2 := p_attribute2;
    l_party_rec.attribute3 := p_attribute3;
    l_party_rec.attribute4 := p_attribute4;
    l_party_rec.attribute5 := p_attribute5;
    l_party_rec.attribute6 := p_attribute6;
    l_party_rec.attribute7 := p_attribute7;
    l_party_rec.attribute8 := p_attribute8;
    l_party_rec.attribute9 := p_attribute9;
    l_party_rec.attribute10 := p_attribute10;
    l_party_rec.attribute11 := p_attribute11;
    l_party_rec.attribute12 := p_attribute12;
    l_party_rec.attribute13 := p_attribute13;
    l_party_rec.attribute14 := p_attribute14;
    l_party_rec.attribute15 := p_attribute15;
    l_party_rec.attribute16 := p_attribute16;
    l_party_rec.attribute17 := p_attribute17;
    l_party_rec.attribute18 := p_attribute18;
    l_party_rec.attribute19 := p_attribute19;
    l_party_rec.attribute20 := p_attribute20;
    l_party_rec.attribute21 := p_attribute21;
    l_party_rec.attribute22 := p_attribute22;
    l_party_rec.attribute23 := p_attribute23;
    l_party_rec.attribute24 := p_attribute24;

    l_org_rec.organization_name := p_branch_name;
    l_org_rec.organization_name_phonetic := p_alternate_branch_name;
    l_org_rec.mission_statement := p_description;
    --8400543: created_by_module should not be updated
    --l_org_rec.created_by_module := 'CE';
    l_org_rec.party_rec := l_party_rec;

    l_branch_rec.bank_or_branch_number := p_branch_number;
    l_branch_rec.branch_type := p_branch_type;
    l_branch_rec.rfc_code := p_rfc_identifier;
    l_branch_rec.organization_rec := l_org_rec;

    hz_bank_pub.update_bank_branch(fnd_api.g_false, l_branch_rec, null,
                                   l_rel_id,
                                   p_bch_object_version_number, p_typ_object_version_number,
                                   p_rfc_object_version_number,
				   l_profile_id, l_rel_party_id, l_rel_party_number,
                                   x_return_status, x_msg_count, x_msg_data);

    -- raise an exception if the branch creation is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- see whether this branch already have eft contact points
    OPEN c_eft;
    FETCH c_eft INTO l_contact_point_id;

    IF c_eft%NOTFOUND THEN   -- does not already have eft contact points
      IF p_bic IS NOT NULL OR p_eft_number IS NOT NULL THEN
        l_contact_point_rec.contact_point_type := 'EFT';
        l_contact_point_rec.owner_table_name := 'HZ_PARTIES';
        l_contact_point_rec.owner_table_id := p_branch_id;
        l_contact_point_rec.created_by_module := 'CE';

        l_eft_rec.eft_swift_code := p_bic;
        l_eft_rec.eft_user_number := p_eft_number;

        hz_contact_point_v2pub.create_eft_contact_point
                (fnd_api.g_false, l_contact_point_rec, l_eft_rec,
                 l_contact_point_id,
                 x_return_status, x_msg_count, x_msg_data);
      END IF;
    ELSE   -- already have, update
      l_contact_point_rec.contact_point_id := l_contact_point_id;

      l_eft_rec.eft_swift_code := p_bic;
      l_eft_rec.eft_user_number := p_eft_number;

       hz_contact_point_v2pub.update_eft_contact_point
		(fnd_api.g_false, l_contact_point_rec, l_eft_rec,
		 p_eft_object_version_number,
                 x_return_status, x_msg_count, x_msg_data);
    END IF;

    -- raise an exception if the eft contact point creation/update is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);

    IF l_DEBUG in ('Y', 'C') THEN
      cep_standard.debug('<<CE_EXT_BANK_ACCT_PUB.update_bank_branch.');
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO update_bank_branch;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      IF l_DEBUG in ('Y', 'C') THEN
        cep_standard.debug_msg_stack(x_msg_count, x_msg_data);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO update_bank_branch;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      IF l_DEBUG in ('Y', 'C') THEN
        cep_standard.debug_msg_stack(x_msg_count, x_msg_data);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO update_bank_branch;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('CE', 'CE_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR',SQLERRM);
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      IF l_DEBUG in ('Y', 'C') THEN
        cep_standard.debug_msg_stack(x_msg_count, x_msg_data);
      END IF;

  END update_bank_branch;


   /*=======================================================================+
   | PUBLIC PROCEDURE set_bank_branch_end_date                             |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Set the end date of a bank branch.                                  |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |   hz_bank_pub.update_bank                                             |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list          Initialize message stack if it is set to |
   |                              FND_API.G_TRUE. Default is fnd_api.g_false
   |     p_branch_id              Party ID of the branch to be inactivated.|
   |     p_end_date               Inactive date of the bank branch.        |
   |   IN/OUT:                                                             |
   |     p_object_version_number    Current object version number for the  |
   |                                code assignment of the bank institution|
   |                                type for the bank branch.              |
   |   OUT:                                                                |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   25-AUG-2004    Xin Wang           Created.                          |
   +=======================================================================*/
  PROCEDURE set_bank_branch_end_date (
        p_init_msg_list            IN     VARCHAR2:= fnd_api.g_false,
        p_branch_id                IN     NUMBER,
        p_end_date                 IN     DATE,
        p_object_version_number    IN OUT NOCOPY  NUMBER,
        x_return_status            OUT    NOCOPY  VARCHAR2,
        x_msg_count                OUT    NOCOPY  NUMBER,
        x_msg_data                 OUT    NOCOPY  VARCHAR2
  ) IS
    CURSOR c_bank (p_bank_id NUMBER) IS
      SELECT end_date_active, object_version_number
      FROM   hz_code_assignments
      WHERE  owner_table_name = 'HZ_PARTIES'
      AND    owner_table_id = p_bank_id
      AND    class_category = 'BANK_INSTITUTION_TYPE'
      AND    class_code = 'BANK';
    CURSOR c_bank_id IS
      SELECT object_id
      FROM   hz_relationships
      WHERE  relationship_type = 'BANK_AND_BRANCH'
      AND    relationship_code = 'BRANCH_OF'
      AND    subject_table_name = 'HZ_PARTIES'
      AND    subject_type = 'ORGANIZATION'
      AND    object_table_name = 'HZ_PARTIES'
      AND    object_type = 'ORGANIZATION'
      AND    subject_id = p_branch_id;
    CURSOR c_branch_end IS
      SELECT end_date_active
      FROM   hz_code_assignments
      WHERE  owner_table_name = 'HZ_PARTIES'
      AND    owner_table_id = p_branch_id
      AND    class_category = 'BANK_INSTITUTION_TYPE'
      AND    class_code = 'BANK_BRANCH';
    CURSOR c_branch_party_ovn IS
      SELECT object_version_number
      FROM   hz_parties
      WHERE  party_id = p_branch_id;
    CURSOR c_account IS
      SELECT bank_account_id, start_date, end_date, object_version_number
      FROM   ce_bank_accounts
      WHERE  bank_branch_id = p_branch_id;
    CURSOR c_rfc_ovn IS
      SELECT object_version_number
      FROM   hz_code_assignments
      WHERE  owner_table_name = 'HZ_PARTIES'
      AND    owner_table_id = p_branch_id
      AND    class_category = 'RFC_IDENTIFIER';

    l_bank_id		NUMBER(15);
    l_bank_end          DATE;
    l_branch_end        DATE;
    l_bank_ovn          NUMBER(15);
    l_branch_party_ovn  NUMBER(15);
    l_account_ovn	NUMBER(15);
    l_rfc_ovn		NUMBER(15);
    l_branch_rec        hz_bank_pub.bank_rec_type;
    l_org_rec           hz_party_v2pub.organization_rec_type;
    l_party_rec         hz_party_v2pub.party_rec_type;
    l_profile_id        NUMBER(15);
    l_rel_id                    NUMBER(15);
    l_rel_party_id              NUMBER(15);
    l_rel_party_number          NUMBER(15);
    l_response			IBY_FNDCPT_COMMON_PUB.Result_rec_type;
  BEGIN
    SAVEPOINT set_bank_branch_end_date;

    IF l_DEBUG in ('Y', 'C') THEN
      cep_standard.debug('>>CE_EXT_BANK_ACCT_PUB.set_bank_branch_end_date.');
    END IF;

    -- initialize message list
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    -- first check all required params
    IF (p_branch_id is null or
        p_object_version_number is null) THEN -- bug 7671686
      fnd_message.set_name('CE', 'CE_API_REQUIRED_PARAM');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- if the new end date is later than the old branch end date
    -- and is later than its bank's end date,
    -- set its bank's end date to the same date as well.
    -- this is the re-activation case

    -- old branch end date
    OPEN c_branch_end;
    FETCH c_branch_end INTO l_branch_end;
    IF c_branch_end%NOTFOUND THEN
      fnd_message.set_name('CE', 'CE_API_NO_BRANCH');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
      RAISE fnd_api.g_exc_error;
    END IF;
    CLOSE c_branch_end;

    -- find bank_id of this branch's bank
    OPEN c_bank_id;
    FETCH c_bank_id INTO l_bank_id;
    IF c_bank_id%NOTFOUND THEN
      fnd_message.set_name('CE', 'CE_API_NO_BRANCH');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
      RAISE fnd_api.g_exc_error;
    END IF;
    CLOSE c_bank_id;

    -- bank's end date
    OPEN c_bank (l_bank_id);
    FETCH c_bank INTO l_bank_end, l_bank_ovn;
    IF c_bank%NOTFOUND THEN
      fnd_message.set_name('CE', 'CE_API_NO_BANK');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
      RAISE fnd_api.g_exc_error;
    END IF;
    CLOSE c_bank;

    IF (p_end_date IS NOT NULL
        AND p_end_date > NVL(l_bank_end, p_end_date))
       OR (p_end_date IS NULL
           AND l_bank_end IS NOT NULL) THEN
      set_bank_end_date (fnd_api.g_false,
                         l_bank_id,
                         p_end_date,
                         l_bank_ovn,
                         x_return_status,
                         x_msg_count,
                         x_msg_data);

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- if the new end date is earlier than the old branch end date
    -- and is earlier than its accounts' end date,
    -- set its accounts' end date to the same date as well.

    FOR acct_rec IN c_account LOOP
      IF p_end_date IS NOT NULL AND p_end_date < NVL(acct_rec.end_date, p_end_date + 1) THEN
        l_account_ovn := acct_rec.object_version_number;
        iby_ext_bankacct_pub.set_ext_bank_acct_dates (
				 1.0,
				 fnd_api.g_false,
                                 acct_rec.bank_account_id,
                                 acct_rec.start_date,
                                 p_end_date,
                                 l_account_ovn,
                                 x_return_status,
                                 x_msg_count,
                                 x_msg_data,
                		 l_response);
        IF x_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;
    END LOOP;

    -- update branch's end date
    l_party_rec.party_id := p_branch_id;
    l_org_rec.party_rec := l_party_rec;
    l_branch_rec.organization_rec := l_org_rec;
    l_branch_rec.inactive_date := p_end_date;

    OPEN c_branch_party_ovn;
    FETCH c_branch_party_ovn INTO l_branch_party_ovn;
    IF c_branch_party_ovn%NOTFOUND THEN
      fnd_message.set_name('CE', 'CE_API_NO_BRANCH');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
      CLOSE c_branch_party_ovn;
      RAISE fnd_api.g_exc_error;
    END IF;
    CLOSE c_branch_party_ovn;

    OPEN c_rfc_ovn;
    FETCH c_rfc_ovn INTO l_rfc_ovn;
    IF c_rfc_ovn%NOTFOUND THEN
      l_rfc_ovn := null;
    END IF;
    CLOSE c_rfc_ovn;

    hz_bank_pub.update_bank_branch(fnd_api.g_false, l_branch_rec, null,
                                   l_rel_id,
                                   l_branch_party_ovn, p_object_version_number,
                                   l_rfc_ovn,
                                   l_profile_id, l_rel_party_id, l_rel_party_number,
                                   x_return_status, x_msg_count, x_msg_data);

    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);

    IF l_DEBUG in ('Y', 'C') THEN
      cep_standard.debug('<<CE_EXT_BANK_ACCT_PUB.set_bank_branch_end_date.');
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO set_bank_branch_end_date;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      IF l_DEBUG in ('Y', 'C') THEN
        cep_standard.debug_msg_stack(x_msg_count, x_msg_data);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO set_bank_branch_end_date;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      IF l_DEBUG in ('Y', 'C') THEN
        cep_standard.debug_msg_stack(x_msg_count, x_msg_data);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO set_bank_branch_end_date;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('CE', 'CE_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR',SQLERRM);
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      IF l_DEBUG in ('Y', 'C') THEN
        cep_standard.debug_msg_stack(x_msg_count, x_msg_data);
      END IF;

  END set_bank_branch_end_date;


   /*=======================================================================+
   | PUBLIC PROCEDURE check_branch_exist                                   |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Check whether a bank branch already exists.                         |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_bank_id                  Bank Party ID.                         |
   |     p_branch_name              Bank branch name.                      |
   |   IN/OUT:                                                             |
   |   OUT:                                                                |
   |     x_branch_id                Bank branch Party ID if branch exists, |
   |                                null if branch does not already exist. |
   |                                                                       |
   | MODIFICATION HISTORY                                                  |
   |   25-AUG-2004    Xin Wang           Created.                          |
   +=======================================================================*/
  PROCEDURE check_branch_exist(
        p_bank_id                  IN     NUMBER,
        p_branch_name              IN     VARCHAR2,
        p_branch_number            IN     VARCHAR2,
        x_branch_id                OUT    NOCOPY NUMBER,
        x_end_date                 OUT    NOCOPY DATE
  ) IS
    CURSOR c_branch_name IS
      SELECT hz_branch.party_id,
             hz_branchCA.end_date_active
      FROM   hz_parties hz_branch,
             hz_relationships hz_rel,
             hz_code_assignments hz_branchCA
      WHERE  hz_branchCA.owner_table_name = 'HZ_PARTIES'
      AND    hz_branchCA.owner_table_id = hz_branch.party_id
      AND    hz_branchCA.class_category = 'BANK_INSTITUTION_TYPE'
      AND    hz_branchCA.class_code = 'BANK_BRANCH'
      AND    NVL(hz_branchCA.STATUS, 'A') = 'A'
      AND    hz_rel.OBJECT_ID = p_bank_id
      And    hz_branch.PARTY_ID = hz_rel.SUBJECT_ID
      And    hz_rel.RELATIONSHIP_TYPE = 'BANK_AND_BRANCH'
      And    hz_rel.RELATIONSHIP_CODE = 'BRANCH_OF'
      And    hz_rel.STATUS = 'A'
      And    hz_rel.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
      And    hz_rel.SUBJECT_TYPE =  'ORGANIZATION'
      And    hz_rel.OBJECT_TABLE_NAME = 'HZ_PARTIES'
      And    hz_rel.OBJECT_TYPE = 'ORGANIZATION'
      AND    upper(hz_branch.party_name) = upper(p_branch_name);

    CURSOR c_branch_num IS
      SELECT hz_branch.party_id,
             hz_branchCA.end_date_active
      FROM   hz_parties hz_branch,
             hz_organization_profiles hz_branchProf,
             hz_relationships hz_rel,
             hz_code_assignments hz_branchCA
      WHERE  hz_branchCA.owner_table_name = 'HZ_PARTIES'
      AND    hz_branchCA.owner_table_id = hz_branch.party_id
      AND    hz_branchCA.class_category = 'BANK_INSTITUTION_TYPE'
      AND    hz_branchCA.class_code = 'BANK_BRANCH'
      AND    NVL(hz_branchCA.STATUS, 'A') = 'A'
      AND    hz_rel.OBJECT_ID = p_bank_id
      And    hz_branch.PARTY_ID = hz_rel.SUBJECT_ID
      And    hz_rel.RELATIONSHIP_TYPE = 'BANK_AND_BRANCH'
      And    hz_rel.RELATIONSHIP_CODE = 'BRANCH_OF'
      And    hz_rel.STATUS = 'A'
      And    hz_rel.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
      And    hz_rel.SUBJECT_TYPE =  'ORGANIZATION'
      And    hz_rel.OBJECT_TABLE_NAME = 'HZ_PARTIES'
      And    hz_rel.OBJECT_TYPE = 'ORGANIZATION'
      AND    hz_branch.party_id = hz_branchProf.party_id
      AND    SYSDATE between TRUNC(hz_branchProf.effective_start_date)
             and NVL(TRUNC(hz_branchProf.effective_end_date), SYSDATE+1)
      AND    hz_branchProf.bank_or_branch_number = p_branch_number;
  BEGIN
    IF l_DEBUG in ('Y', 'C') THEN
      cep_standard.debug('>>CE_EXT_BANK_ACCT_PUB.check_branch_exist.');
    END IF;

    IF p_branch_name IS NOT NULL THEN
      OPEN c_branch_name;
      FETCH c_branch_name INTO x_branch_id, x_end_date;
      IF c_branch_name%NOTFOUND THEN
        x_branch_id := null;
        x_end_date := null;
      END IF;
      CLOSE c_branch_name;
    ELSIF p_branch_number IS NOT NULL THEN
      OPEN c_branch_num;
      FETCH c_branch_num INTO x_branch_id, x_end_date;
      IF c_branch_num%NOTFOUND THEN
        x_branch_id := null;
        x_end_date := null;
      END IF;
      CLOSE c_branch_num;
    ELSE
      x_branch_id := null;
      x_end_date := null;
    END IF;

    IF l_DEBUG in ('Y', 'C') THEN
      cep_standard.debug('<<CE_EXT_BANK_ACCT_PUB.check_branch_exist.');
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      cep_standard.sql_error('CE_EXT_BANK_ACCT_PUB.check_branch_exist', sqlcode, sqlerrm);

  END check_branch_exist;


   /*=======================================================================+
   | PUBLIC PROCEDURE create_bank_acct                                     |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Create an internal or subsidiary bank account.                      |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list      Initialize message stack if it is set to     |
   |                          FND_API.G_TRUE. Default is fnd_api.g_false   |
   |     p_acct_rec           Bank account record.                |
   |   IN/OUT:                                                             |
   |   OUT:                                                                |
   |     x_acct_id            Bank account ID.                             |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   25-AUG-2004    Xin Wang           Created.                          |
   +=======================================================================*/
  PROCEDURE create_bank_acct (
        p_init_msg_list                 IN     VARCHAR2:= fnd_api.g_false,
        p_acct_rec                      IN      BankAcct_rec_type,
        x_acct_id                       OUT     NOCOPY NUMBER,
        x_return_status                 OUT    NOCOPY  VARCHAR2,
        x_msg_count                     OUT    NOCOPY  NUMBER,
        x_msg_data                      OUT    NOCOPY  VARCHAR2
  ) IS
    CURSOR c_acct_id IS
      SELECT CE_BANK_ACCOUNTS_S.nextval
      FROM   sys.dual;
    CURSOR c_acct_rowid IS
      SELECT rowid
      FROM   CE_BANK_ACCOUNTS
      WHERE  bank_account_id = x_acct_id;
    CURSOR c_branch IS
      SELECT bank_or_branch_number
      FROM   hz_organization_profiles
      WHERE  SYSDATE between TRUNC(effective_start_date)
             and NVL(TRUNC(effective_end_date), SYSDATE+1)
      AND    party_id = p_acct_rec.branch_id;
/*
    CURSOR c_bank_id IS
      SELECT object_id
      FROM   hz_relationships
      WHERE  RELATIONSHIP_TYPE = 'BANK_AND_BRANCH'
      AND    RELATIONSHIP_CODE = 'BRANCH_OF'
      AND    subject_id = p_acct_rec.branch_id;
*/
    l_iban           VARCHAR2(50) := null;
    l_alc	     VARCHAR2(30) := null;
    l_country        VARCHAR2(60);
    l_bank_id        NUMBER(15) := null;
    l_acct_rowid     VARCHAR2(100);
    l_bank_name      VARCHAR2(360) := null;
    l_bank_number    VARCHAR2(30) := null;
    l_branch_number  VARCHAR2(30) := null;
    l_account_number VARCHAR2(100) := null;
     X_ELECTRONIC_ACCT_NUM	VARCHAR2(100) := null;

  BEGIN
    SAVEPOINT create_bank_acct;

    IF l_DEBUG in ('Y', 'C') THEN
      cep_standard.debug('>>CE_BANK_PUB.create_bank_acct.');
    END IF;

    -- initialize message list
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    -- first check all required params
    IF (p_acct_rec.branch_id is null or
        p_acct_rec.bank_account_name is null or
        p_acct_rec.bank_account_num is null or
        p_acct_rec.account_owner_org_id is null or
        p_acct_rec.account_classification is null ) THEN -- Bug 7671686
      fnd_message.set_name('CE', 'CE_API_REQUIRED_PARAM');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- validate currency
    IF p_acct_rec.currency IS NOT NULL THEN
      CE_BANK_AND_ACCOUNT_VALIDATION.validate_currency(p_acct_rec.currency, x_return_status);

      -- raise an exception if the validation is unsuccessful
      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- validate account name
    CE_BANK_AND_ACCOUNT_VALIDATION.validate_account_name(p_acct_rec.branch_id, p_acct_rec.bank_account_name,
                                                         null, x_return_status);

    -- raise an exception if the validation is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;


    -- validate iban
    IF p_acct_rec.iban IS NOT NULL THEN
      CE_BANK_AND_ACCOUNT_VALIDATION.validate_IBAN(p_acct_rec.iban, l_iban, x_return_status);

      -- raise an exception if the validation is unsuccessful
      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- validate agency_location_code
    IF p_acct_rec.agency_location_code IS NOT NULL THEN
      CE_BANK_AND_ACCOUNT_VALIDATION.validate_alc(p_acct_rec.agency_location_code,
						  FND_API.G_FALSE,
						  x_msg_count,
						  x_msg_data,
						  l_alc,
						  x_return_status);

      -- raise an exception if the validation is unsuccessful
      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- find bank info
    IF p_acct_rec.branch_id IS NOT NULL THEN
      find_bank_info(p_acct_rec.branch_id, x_return_status, l_bank_id, l_country, l_bank_name, l_bank_number);

      -- raise an exception if bank is not found
      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      -- find branch number
      OPEN c_branch;
      FETCH c_branch INTO l_branch_number;
      IF c_branch%NOTFOUND THEN
        fnd_message.set_name('CE', 'CE_API_NO_BRANCH');
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
        RAISE fnd_api.g_exc_error;
      END IF;
      CLOSE c_branch;
    END IF;

    -- country specific validation API call here.
    -- do not perform country specific validations for subsidiary accounts
    IF p_acct_rec.account_classification <> 'SUBSIDIARY' THEN
      ce_validate_bankinfo.ce_validate_cd (l_country,
                                         p_acct_rec.check_digits,
                                         l_bank_number,
                                         l_branch_number,
                                         p_acct_rec.bank_account_num,
                                         FND_API.G_FALSE,
                                         x_msg_count,
                                         x_msg_data,
                                         x_return_status,
                                         'INTERNAL');

      ce_validate_bankinfo.ce_validate_account (l_country,
                                              l_bank_number,
                                              l_branch_number,
                                              p_acct_rec.bank_account_num,
                                              l_bank_id,
                                              p_acct_rec.branch_id,
                                              null,    -- account_id
                                              p_acct_rec.currency,
                                              p_acct_rec.acct_type,
                                              p_acct_rec.acct_suffix,
                                              p_acct_rec.secondary_account_reference,
                                              p_acct_rec.bank_account_name,
                                              FND_API.G_FALSE,
                                              x_msg_count,
                                              x_msg_data,
                                              l_account_number,
                                              x_return_status,
                                              'INTERNAL',
						p_acct_rec.check_digits,
						X_ELECTRONIC_ACCT_NUM
				);

      -- raise an exception if the validation fails
      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    ELSE   -- set the account number for subsidiary accounts
      l_account_number := p_acct_rec.bank_account_num;
    END IF;   -- subsidiary accounts

    -- insert data into ce_bank_accounts table
    OPEN c_acct_id;
    FETCH c_acct_id INTO x_acct_id;
    CLOSE c_acct_id;

    INSERT INTO CE_BANK_ACCOUNTS (
        BANK_ACCOUNT_ID,
        BANK_BRANCH_ID,
        BANK_ID,
	ACCOUNT_OWNER_PARTY_ID,
	ACCOUNT_OWNER_ORG_ID,
	ACCOUNT_CLASSIFICATION,
        BANK_ACCOUNT_NAME,
        BANK_ACCOUNT_NUM,
        CURRENCY_CODE,
        IBAN_NUMBER,
	CHECK_DIGITS,
	EFT_REQUESTER_IDENTIFIER,
	SECONDARY_ACCOUNT_REFERENCE,
	MULTI_CURRENCY_ALLOWED_FLAG,
	BANK_ACCOUNT_NAME_ALT,
	SHORT_ACCOUNT_NAME,
	BANK_ACCOUNT_TYPE,
	ACCOUNT_SUFFIX,
	DESCRIPTION_CODE1,
	DESCRIPTION_CODE2,
	DESCRIPTION,
	AGENCY_LOCATION_CODE,
	AP_USE_ALLOWED_FLAG,
	AR_USE_ALLOWED_FLAG,
	XTR_USE_ALLOWED_FLAG,
	PAY_USE_ALLOWED_FLAG,
	PAYMENT_MULTI_CURRENCY_FLAG,
	RECEIPT_MULTI_CURRENCY_FLAG,
	ZERO_AMOUNT_ALLOWED,
	MAX_OUTLAY,
	MAX_CHECK_AMOUNT,
	MIN_CHECK_AMOUNT,
	AP_AMOUNT_TOLERANCE,
	AR_AMOUNT_TOLERANCE,
	XTR_AMOUNT_TOLERANCE,
	PAY_AMOUNT_TOLERANCE,
        CE_AMOUNT_TOLERANCE,
	AP_PERCENT_TOLERANCE,
	AR_PERCENT_TOLERANCE,
	XTR_PERCENT_TOLERANCE,
	PAY_PERCENT_TOLERANCE,
        CE_PERCENT_TOLERANCE,
	START_DATE,
	END_DATE,
	ACCOUNT_HOLDER_NAME_ALT,
	ACCOUNT_HOLDER_NAME,
	CASHFLOW_DISPLAY_ORDER,
	POOLED_FLAG,
	MIN_TARGET_BALANCE,
	MAX_TARGET_BALANCE,
	EFT_USER_NUM,
	MASKED_ACCOUNT_NUM,
	MASKED_IBAN,
	INTEREST_SCHEDULE_ID,
	ASSET_CODE_COMBINATION_ID,
	CASH_CLEARING_CCID,
	BANK_CHARGES_CCID,
	BANK_ERRORS_CCID,
	CASHPOOL_MIN_PAYMENT_AMT,
	CASHPOOL_MIN_RECEIPT_AMT,
	CASHPOOL_ROUND_FACTOR,
	CASHPOOL_ROUND_RULE,
	ATTRIBUTE_CATEGORY,
	ATTRIBUTE1,
	ATTRIBUTE2,
	ATTRIBUTE3,
	ATTRIBUTE4,
	ATTRIBUTE5,
	ATTRIBUTE6,
	ATTRIBUTE7,
	ATTRIBUTE8,
	ATTRIBUTE9,
	ATTRIBUTE10,
	ATTRIBUTE11,
	ATTRIBUTE12,
	ATTRIBUTE13,
	ATTRIBUTE14,
	ATTRIBUTE15,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	CREATION_DATE,
	CREATED_BY,
	OBJECT_VERSION_NUMBER,
	xtr_bank_account_reference)
    VALUES (
        x_acct_id,
	p_acct_rec.branch_id,
	l_bank_id,
	p_acct_rec.account_owner_party_id,
	p_acct_rec.account_owner_org_id,
	p_acct_rec.account_classification,
	p_acct_rec.bank_account_name,
	l_account_number,
	p_acct_rec.currency,
	l_iban,
	p_acct_rec.check_digits,
	p_acct_rec.eft_requester_id,
	p_acct_rec.secondary_account_reference,
	p_acct_rec.multi_currency_allowed_flag,
	p_acct_rec.alternate_acct_name,
	p_acct_rec.short_account_name,
	p_acct_rec.acct_type,
	p_acct_rec.acct_suffix,
	p_acct_rec.description_code1,
        p_acct_rec.description_code2,
	p_acct_rec.description,
	l_alc,
	p_acct_rec.ap_use_allowed_flag,
	p_acct_rec.ar_use_allowed_flag,
	p_acct_rec.xtr_use_allowed_flag,
	p_acct_rec.pay_use_allowed_flag,
	p_acct_rec.payment_multi_currency_flag,
	p_acct_rec.receipt_multi_currency_flag,
	p_acct_rec.zero_amount_allowed,
	p_acct_rec.max_outlay,
        p_acct_rec.max_check_amount,
        p_acct_rec.min_check_amount,
	p_acct_rec.ap_amount_tolerance,
	p_acct_rec.ar_amount_tolerance,
	p_acct_rec.xtr_amount_tolerance,
        p_acct_rec.pay_amount_tolerance,
        p_acct_rec.ce_amount_tolerance,
	p_acct_rec.ap_percent_tolerance,
        p_acct_rec.ar_percent_tolerance,
        p_acct_rec.xtr_percent_tolerance,
        p_acct_rec.pay_percent_tolerance,
        p_acct_rec.ce_percent_tolerance,
        p_acct_rec.start_date,
        p_acct_rec.end_date,
        p_acct_rec.account_holder_name_alt,
        p_acct_rec.account_holder_name,
        p_acct_rec.cashflow_display_order,
	p_acct_rec.pooled_flag,
	p_acct_rec.min_target_balance,
	p_acct_rec.max_target_balance,
	p_acct_rec.eft_user_num,
	p_acct_rec.masked_account_num,
	p_acct_rec.masked_iban,
	p_acct_rec.interest_schedule_id,
        p_acct_rec.asset_code_combination_id,
        p_acct_rec.cash_clearing_ccid,
        p_acct_rec.bank_charges_ccid,
        p_acct_rec.bank_errors_ccid,
        p_acct_rec.cashpool_min_payment_amt,
        p_acct_rec.cashpool_min_receipt_amt,
        p_acct_rec.cashpool_round_factor,
        p_acct_rec.cashpool_round_rule,
        p_acct_rec.attribute_category,
        p_acct_rec.attribute1,
        p_acct_rec.attribute2,
        p_acct_rec.attribute3,
        p_acct_rec.attribute4,
        p_acct_rec.attribute5,
        p_acct_rec.attribute6,
        p_acct_rec.attribute7,
        p_acct_rec.attribute8,
        p_acct_rec.attribute9,
        p_acct_rec.attribute10,
        p_acct_rec.attribute11,
        p_acct_rec.attribute12,
        p_acct_rec.attribute13,
        p_acct_rec.attribute14,
        p_acct_rec.attribute15,
        sysdate,
        NVL(FND_GLOBAL.user_id,-1),
        NVL(FND_GLOBAL.login_id, -1),
        sysdate,
        NVL(FND_GLOBAL.user_id,-1),
	1,
	p_acct_rec.xtr_bank_account_reference);
    OPEN c_acct_rowid;
    FETCH c_acct_rowid INTO l_acct_rowid;
    If (c_acct_rowid%NOTFOUND) then
       CLOSE c_acct_rowid;
       RAISE NO_DATA_FOUND;
    End If;
    CLOSE c_acct_rowid;

    -- get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);

    IF l_DEBUG in ('Y', 'C') THEN
      cep_standard.debug('<<CE_BANK_PUB.create_bank_acct.');
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_bank_acct;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      IF l_DEBUG in ('Y', 'C') THEN
        cep_standard.debug_msg_stack(x_msg_count, x_msg_data);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_bank_acct;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      IF l_DEBUG in ('Y', 'C') THEN
        cep_standard.debug_msg_stack(x_msg_count, x_msg_data);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO create_bank_acct;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('CE', 'CE_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR',SQLERRM);
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      IF l_DEBUG in ('Y', 'C') THEN
        cep_standard.debug_msg_stack(x_msg_count, x_msg_data);
      END IF;

  END create_bank_acct;

   /*=======================================================================+
   | PRIVATE FUNCTION get_masked_code                         		   |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Get the maked bank account number for the given bank account number |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | MODIFICATION HISTORY                                                  |
   |   10-APR-2009    TALAPATI      Created.  	                           |
   +=======================================================================*/

  FUNCTION get_masked_code (
    p_bank_account_num IN  VARCHAR2) RETURN VARCHAR2 IS
    l_maskChar VARCHAR2(100):= 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';
    l_maskOption VARCHAR2(30);
    l_acctNumLen NUMBER;
    l_replaceMaskChar VARCHAR2(100);
    l_newMaskedValues VARCHAR2(100);
  BEGIN

     l_maskoption:=fnd_profile.value('CE_MASK_INTERNAL_BANK_ACCT_NUM');
	  if l_maskOption is null then
            l_maskOption:= 'LAST FOUR VISIBLE';
	  end if;
   l_acctNumLen:= length(p_bank_account_num);
   if l_maskOption='LAST FOUR VISIBLE' and l_acctNumLen > 4 then
    l_replaceMaskChar:= substr(l_maskChar,1,l_acctNumLen-4);
    l_newMaskedValues:= l_replaceMaskChar||substr(p_bank_account_num,-4,4);

  elsif l_maskOption='FIRST FOUR VISIBLE' and l_acctNumLen > 4 then

    l_replaceMaskChar:= substr(l_maskChar,1,l_acctNumLen-4);
    l_newMaskedValues:= substr(p_bank_account_num,1,4)||l_replaceMaskChar;
  else
     l_newMaskedValues:= p_bank_account_num;
  end if;
    RETURN l_newMaskedValues;
  END get_masked_code;


   /*=======================================================================+
   | PUBLIC PROCEDURE update_bank_acct                                     |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Update an internal or subsidiary bank account.                      |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | ARGUMENTS                                                             |
   |   IN:                                                                 |
   |     p_init_msg_list          Initialize message stack if it is set to |
   |                              FND_API.G_TRUE. Default is fnd_api.g_false
   |     p_acct_rec               External bank account record.            |
   |   IN/OUT:                                                             |
   |     p_object_version_number  Current object version number for the    |
   |                              bank account.                            |
   |   OUT:                                                                |
   |     x_return_status      Return status after the call. The status can |
   |                          be FND_API.G_RET_STS_SUCCESS (success),      |
   |                          fnd_api.g_ret_sts_error (error),             |
   |                          fnd_api.g_ret_sts_unexp_error (unexpected    |
   |                          error).                                      |
   |     x_msg_count          Number of messages in message stack.         |
   |     x_msg_data           Message text if x_msg_count is 1.            |
   | MODIFICATION HISTORY                                                  |
   |   25-AUG-2004    Xin Wang           Created.                          |
   |   10-APR-2009    TALAPATI  Updated certain validation rules for bug   |
   |                             #8407297                                  |
   |									   |
   +=======================================================================*/
  PROCEDURE update_bank_acct (
        p_init_msg_list                 IN     VARCHAR2:= fnd_api.g_false,
        p_acct_rec                      IN      BankAcct_rec_type,
        p_object_version_number         IN OUT  NOCOPY NUMBER,
        x_return_status                 OUT    NOCOPY  VARCHAR2,
        x_msg_count                     OUT    NOCOPY  NUMBER,
        x_msg_data                      OUT    NOCOPY  VARCHAR2
  ) IS
    CURSOR c_branch_id IS
      SELECT bank_branch_id
      FROM   ce_bank_accounts
      WHERE  bank_account_id = p_acct_rec.bank_account_id;

    CURSOR c_branch_num(l_branch_id NUMBER) IS
      SELECT bank_or_branch_number
      FROM   hz_organization_profiles
      WHERE  SYSDATE between TRUNC(effective_start_date)
             and NVL(TRUNC(effective_end_date), SYSDATE+1)
      AND    party_id = l_branch_id;

    CURSOR c_ovn IS
      SELECT object_version_number
      FROM   ce_bank_accounts
      WHERE  bank_account_id = p_acct_rec.bank_account_id;

    CURSOR c_bank_account IS
      SELECT *
      FROM   ce_bank_accounts
      WHERE  bank_account_id = p_acct_rec.bank_account_id;

    l_iban           VARCHAR2(50) := null;
    l_alc	     VARCHAR2(30) := null;
    l_country        VARCHAR2(60);
    l_bank_name      VARCHAR2(360);
    l_bank_number    VARCHAR2(30);
    l_branch_number  VARCHAR2(30);
    l_account_number VARCHAR2(100) := null;
    l_bank_id           NUMBER(15);
    l_branch_id         NUMBER(15);
    l_old_ovn           NUMBER(15);
    X_ELECTRONIC_ACCT_NUM	VARCHAR2(100) := null;
    --Bug 8407297
    l_bank_acct_rec_master CE_BANK_ACCOUNTS%ROWTYPE;
    l_ap_use_allowed_flag  VARCHAR2(1);
    l_ar_use_allowed_flag  VARCHAR2(1);
    l_xtr_use_allowed_flag VARCHAR2(1);
    l_pay_use_allowed_flag VARCHAR2(1);
    l_currency_code VARCHAR2(15);
    l_masked_bank_acct_num VARCHAR2(100);


  BEGIN
    SAVEPOINT update_bank_acct;

    IF l_DEBUG in ('Y', 'C') THEN
      cep_standard.debug('>>CE_BANK_PUB.update_bank_acct.');
    END IF;

    -- initialize message list
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    -- first check all required params
    IF (p_acct_rec.bank_account_id is null or
        p_acct_rec.bank_account_name is null or
        p_acct_rec.bank_account_num is null or
        p_acct_rec.account_classification is null or
        p_object_version_number is null) THEN -- bug 7671686
      fnd_message.set_name('CE', 'CE_API_REQUIRED_PARAM');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
      RAISE fnd_api.g_exc_error;
    END IF;
    --Bug 8407297

    OPEN c_bank_account;
    FETCH c_bank_account INTO l_bank_acct_rec_master;
    IF c_bank_account%NOTFOUND THEN
      fnd_message.set_name('CE', 'CE_API_NO_ACCOUNT');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
      CLOSE c_bank_account;
      RAISE fnd_api.g_exc_error;
    END IF;
    CLOSE c_bank_account;


     if l_bank_acct_rec_master.ap_use_allowed_flag='N' then
      if p_acct_rec.ap_use_allowed_flag is not null and  p_acct_rec.ap_use_allowed_flag='Y' then
        l_ap_use_allowed_flag:= p_acct_rec.ap_use_allowed_flag;
      else
        l_ap_use_allowed_flag:= l_bank_acct_rec_master.ap_use_allowed_flag;
      end if;
    else
      l_ap_use_allowed_flag:= l_bank_acct_rec_master.ap_use_allowed_flag;
    end if;

    if l_bank_acct_rec_master.ar_use_allowed_flag='N' then
      if p_acct_rec.ar_use_allowed_flag is not null and p_acct_rec.ar_use_allowed_flag='Y' then
        l_ar_use_allowed_flag:= p_acct_rec.ar_use_allowed_flag;
      else
        l_ar_use_allowed_flag:= l_bank_acct_rec_master.ar_use_allowed_flag;
      end if;
    else
      l_ar_use_allowed_flag:= l_bank_acct_rec_master.ar_use_allowed_flag;
    end if;

    if l_bank_acct_rec_master.xtr_use_allowed_flag='N' then
      if p_acct_rec.xtr_use_allowed_flag is not null and p_acct_rec.xtr_use_allowed_flag='Y' then
        l_xtr_use_allowed_flag:= p_acct_rec.xtr_use_allowed_flag;
      else
        l_xtr_use_allowed_flag:= l_bank_acct_rec_master.xtr_use_allowed_flag;
      end if;
    else
      l_xtr_use_allowed_flag:= l_bank_acct_rec_master.xtr_use_allowed_flag;
    end if;

    if l_bank_acct_rec_master.pay_use_allowed_flag='N' then
      if p_acct_rec.pay_use_allowed_flag is not null and p_acct_rec.pay_use_allowed_flag='Y' then
        l_pay_use_allowed_flag:= p_acct_rec.pay_use_allowed_flag;
      else
        l_pay_use_allowed_flag:= l_bank_acct_rec_master.pay_use_allowed_flag;
      end if;
    else
      l_pay_use_allowed_flag:= l_bank_acct_rec_master.pay_use_allowed_flag;
    end if;

    if p_acct_rec.multi_currency_allowed_flag is not null and  p_acct_rec.multi_currency_allowed_flag='Y' then
      SELECT currency_code into l_currency_code
      FROM gl_ledger_le_v
      WHERE ledger_category_code = 'PRIMARY' and
      legal_entity_id =  l_bank_acct_rec_master.account_owner_org_id;

      -- Validate Multi-Currency Allowed or not bug 8407297
      if l_currency_code <> l_bank_acct_rec_master.currency_code then
        fnd_message.set_name('CE', 'CE_BANK_MULTICURRENCY');
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
        RAISE fnd_api.g_exc_error;
      end if;
   end if;


    -- validate currency
    --Bug 8407297 - Call to the Currency Validation not required as the Currency field is protected against update
  /*
    IF p_acct_rec.currency IS NOT NULL THEN
      CE_BANK_AND_ACCOUNT_VALIDATION.validate_currency(p_acct_rec.currency, x_return_status);

      -- raise an exception if the validation is unsuccessful
      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;
*/
    -- validate account name
    OPEN c_branch_id;
    FETCH c_branch_id INTO l_branch_id;
    IF c_branch_id%NOTFOUND THEN
      fnd_message.set_name('CE', 'CE_API_NO_ACCOUNT');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
      CLOSE c_branch_id;
      RAISE fnd_api.g_exc_error;
    END IF;
    CLOSE c_branch_id;

    CE_BANK_AND_ACCOUNT_VALIDATION.validate_account_name(l_branch_id, p_acct_rec.bank_account_name,
                                                         p_acct_rec.bank_account_id, x_return_status);

    -- raise an exception if the validation is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- validate iban
    IF p_acct_rec.iban IS NOT NULL THEN
      CE_BANK_AND_ACCOUNT_VALIDATION.validate_IBAN(p_acct_rec.iban, l_iban, x_return_status);

      -- raise an exception if the validation is unsuccessful
      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- validate agency_location_code
    IF p_acct_rec.agency_location_code IS NOT NULL THEN
      CE_BANK_AND_ACCOUNT_VALIDATION.validate_alc(p_acct_rec.agency_location_code,
                                                  FND_API.G_FALSE,
                                                  x_msg_count,
                                                  x_msg_data,
                                                  l_alc,
                                                  x_return_status);

      -- raise an exception if the validation is unsuccessful
      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- find bank info
    IF l_branch_id IS NOT NULL THEN
      find_bank_info(l_branch_id, x_return_status, l_bank_id, l_country, l_bank_name, l_bank_number);
      -- raise an exception if bank is not found
      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

      -- find branch number
      OPEN c_branch_num(l_branch_id);
      FETCH c_branch_num INTO l_branch_number;
      IF c_branch_num%NOTFOUND THEN
        fnd_message.set_name('CE', 'CE_API_NO_BRANCH');
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
        CLOSE c_branch_num;
        RAISE fnd_api.g_exc_error;
      END IF;
      CLOSE c_branch_num;
    END IF;

    -- country specific validation API call here.
    -- do not perform country specific validations for subsidiary accounts
    IF p_acct_rec.account_classification <> 'SUBSIDIARY' THEN
      ce_validate_bankinfo.ce_validate_cd (l_country,
                                         p_acct_rec.check_digits,
                                         l_bank_number,
                                         l_branch_number,
                                         p_acct_rec.bank_account_num,
                                         FND_API.G_FALSE,
                                         x_msg_count,
                                         x_msg_data,
                                         x_return_status,
                                         'INTERNAL');

      ce_validate_bankinfo.ce_validate_account (l_country,
                                              l_bank_number,
                                              l_branch_number,
                                              p_acct_rec.bank_account_num,
                                              l_bank_id,
                                              l_branch_id,
                                              p_acct_rec.bank_account_id,
                                              p_acct_rec.currency,
                                              p_acct_rec.acct_type,
                                              p_acct_rec.acct_suffix,
					      p_acct_rec.secondary_account_reference,
                                              p_acct_rec.bank_account_name,
                                              FND_API.G_FALSE,
                                              x_msg_count,
                                              x_msg_data,
                                              l_account_number,
                                              x_return_status,
                                              'INTERNAL',
						p_acct_rec.check_digits,
						X_ELECTRONIC_ACCT_NUM);

      -- raise an exception if the validation fails
      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    ELSE   -- set the account number for subsidiary accounts
      l_account_number := p_acct_rec.bank_account_num;
    END IF;  -- subsidiary account

    -- check object version number to make sure the record has not been updated
    OPEN c_ovn;
    FETCH c_ovn INTO l_old_ovn;
    IF c_ovn%NOTFOUND THEN
      fnd_message.set_name('CE', 'CE_API_NO_ACCOUNT');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
      CLOSE c_ovn;
      RAISE fnd_api.g_exc_error;
    END IF;
    CLOSE c_ovn;

    IF l_old_ovn > p_object_version_number THEN
      fnd_message.set_name('CE', 'CE_API_RECORD_CHANGED');
      fnd_message.set_token('TABLE', 'CE_BANK_ACCOUNTS');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Bug 8407297  Get the Masked value of the Bank Account Number
   if p_acct_rec.masked_account_num is null then
    l_masked_bank_acct_num:= get_masked_code(l_account_number);
   else
    l_masked_bank_acct_num:= p_acct_rec.masked_account_num;
   end if;

    -- update
    update ce_bank_accounts
    set    bank_account_name           = p_acct_rec.bank_account_name,
           bank_account_num            = l_account_number,
         --currency_code               = p_acct_rec.currency, --Bug 8407297
           iban_number                 = l_iban,
           check_digits                = p_acct_rec.check_digits,
           eft_requester_identifier    = p_acct_rec.eft_requester_id,
           secondary_account_reference = p_acct_rec.secondary_account_reference,
           multi_currency_allowed_flag = nvl(p_acct_rec.multi_currency_allowed_flag,l_bank_acct_rec_master.multi_currency_allowed_flag),
           bank_account_name_alt       = p_acct_rec.alternate_acct_name,
           short_account_name          = p_acct_rec.short_account_name,
           bank_account_type           = p_acct_rec.acct_type,
           account_suffix              = p_acct_rec.acct_suffix,
           description_code1           = p_acct_rec.description_code1,
           description_code2           = p_acct_rec.description_code2,
           description                 = p_acct_rec.description,
           agency_location_code        = l_alc,
           ap_use_allowed_flag         = l_ap_use_allowed_flag, --Bug 8407297
           ar_use_allowed_flag         = l_ar_use_allowed_flag, --Bug 8407297
           xtr_use_allowed_flag        = l_xtr_use_allowed_flag, --Bug 8407297
           pay_use_allowed_flag        = l_pay_use_allowed_flag, --Bug 8407297
           payment_multi_currency_flag = p_acct_rec.payment_multi_currency_flag,
           receipt_multi_currency_flag = p_acct_rec.receipt_multi_currency_flag,
           zero_amount_allowed         = nvl(p_acct_rec.zero_amount_allowed,l_bank_acct_rec_master.zero_amount_allowed),
           max_outlay                  = p_acct_rec.max_outlay,
           max_check_amount            = p_acct_rec.max_check_amount,
           min_check_amount            = p_acct_rec.min_check_amount,
           ap_amount_tolerance         = nvl(p_acct_rec.ap_amount_tolerance,l_bank_acct_rec_master.ap_amount_tolerance),
           ar_amount_tolerance         = nvl(p_acct_rec.ar_amount_tolerance,l_bank_acct_rec_master.ar_amount_tolerance),
           xtr_amount_tolerance        = nvl(p_acct_rec.xtr_amount_tolerance,l_bank_acct_rec_master.xtr_amount_tolerance),
           pay_amount_tolerance        = nvl(p_acct_rec.pay_amount_tolerance,l_bank_acct_rec_master.pay_amount_tolerance),
           ce_amount_tolerance	       = p_acct_rec.ce_amount_tolerance,
           ap_percent_tolerance        = nvl(p_acct_rec.ap_percent_tolerance,l_bank_acct_rec_master.ap_percent_tolerance),
           ar_percent_tolerance        = nvl(p_acct_rec.ar_percent_tolerance,l_bank_acct_rec_master.ar_percent_tolerance),
           xtr_percent_tolerance       = nvl(p_acct_rec.xtr_percent_tolerance,l_bank_acct_rec_master.xtr_percent_tolerance),
           pay_percent_tolerance       = p_acct_rec.pay_percent_tolerance,
           ce_percent_tolerance        = p_acct_rec.ce_percent_tolerance,
           start_date                  = p_acct_rec.start_date,
           end_date                    = p_acct_rec.end_date,
           account_holder_name_alt     = p_acct_rec.account_holder_name_alt,
           account_holder_name         = p_acct_rec.account_holder_name,
           cashflow_display_order      = p_acct_rec.cashflow_display_order,
           pooled_flag                 = nvl(p_acct_rec.pooled_flag,l_bank_acct_rec_master.pooled_flag),
           min_target_balance          = p_acct_rec.min_target_balance,
           max_target_balance          = p_acct_rec.max_target_balance,
           eft_user_num                = p_acct_rec.eft_user_num,
           masked_account_num          = l_masked_bank_acct_num,
           BANK_ACCOUNT_NUM_ELECTRONIC = l_account_number,
           masked_iban                 = p_acct_rec.masked_iban,
           interest_schedule_id        = p_acct_rec.interest_schedule_id,
           asset_code_combination_id   = nvl(p_acct_rec.asset_code_combination_id,l_bank_acct_rec_master.asset_code_combination_id),
           cash_clearing_ccid          = p_acct_rec.cash_clearing_ccid,
           bank_charges_ccid           = p_acct_rec.bank_charges_ccid,
           bank_errors_ccid            = p_acct_rec.bank_errors_ccid,
           cashpool_min_payment_amt    = p_acct_rec.cashpool_min_payment_amt,
           cashpool_min_receipt_amt    = p_acct_rec.cashpool_min_receipt_amt,
           cashpool_round_factor       = p_acct_rec.cashpool_round_factor,
           cashpool_round_rule         = p_acct_rec.cashpool_round_rule,
           attribute_category          = p_acct_rec.attribute_category,
           attribute1                  = p_acct_rec.attribute1,
           attribute2                  = p_acct_rec.attribute2,
           attribute3                  = p_acct_rec.attribute3,
           attribute4                  = p_acct_rec.attribute4,
           attribute5                  = p_acct_rec.attribute5,
           attribute6                  = p_acct_rec.attribute6,
           attribute7                  = p_acct_rec.attribute7,
           attribute8                  = p_acct_rec.attribute8,
           attribute9                  = p_acct_rec.attribute9,
           attribute10                 = p_acct_rec.attribute10,
           attribute11                 = p_acct_rec.attribute11,
           attribute12                 = p_acct_rec.attribute12,
           attribute13                 = p_acct_rec.attribute13,
           attribute14                 = p_acct_rec.attribute14,
           attribute15                 = p_acct_rec.attribute15,
           last_update_date            = sysdate,
           last_update_login           = NVL(FND_GLOBAL.login_id,-1),
           last_updated_by             = NVL(FND_GLOBAL.user_id,-1),
           object_version_number       = l_old_ovn + 1,
           xtr_bank_account_reference  = p_acct_rec.xtr_bank_account_reference
    WHERE  bank_account_id = p_acct_rec.bank_account_id;
    IF (SQL%NOTFOUND) THEN
      fnd_message.set_name('CE', 'CE_API_NO_ACCOUNT');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
      RAISE fnd_api.g_exc_error;
    END IF;
    p_object_version_number := l_old_ovn + 1;

    -- get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);

    IF l_DEBUG in ('Y', 'C') THEN
      cep_standard.debug('<<CE_BANK_PUB.update_bank_acct.');
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO update_bank_acct;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      IF l_DEBUG in ('Y', 'C') THEN
        cep_standard.debug_msg_stack(x_msg_count, x_msg_data);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO update_bank_acct;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      IF l_DEBUG in ('Y', 'C') THEN
        cep_standard.debug_msg_stack(x_msg_count, x_msg_data);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO udpate_bank_acct;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('CE', 'CE_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR',SQLERRM);
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      IF l_DEBUG in ('Y', 'C') THEN
        cep_standard.debug_msg_stack(x_msg_count, x_msg_data);
      END IF;

  END update_bank_acct;


  PROCEDURE create_bank_acct_use (
        p_init_msg_list                 IN     VARCHAR2:= fnd_api.g_false,
        p_acct_use_rec                  IN      BankAcct_use_rec_type,
        x_acct_use_id                   OUT     NOCOPY NUMBER,
        x_return_status                 OUT    NOCOPY  VARCHAR2,
        x_msg_count                     OUT    NOCOPY  NUMBER,
        x_msg_data                      OUT    NOCOPY  VARCHAR2
  ) IS
    CURSOR c_acct_use_id IS
      SELECT CE_BANK_ACCT_USES_S.nextval
      FROM   sys.dual;
    CURSOR c_acct_use_rowid IS
      SELECT rowid
      FROM   CE_BANK_ACCT_USES_ALL
      WHERE  bank_acct_use_id = x_acct_use_id;
    CURSOR c_gl_ccid_rowid IS
      SELECT rowid
      FROM   CE_GL_ACCOUNTS_CCID
      WHERE  bank_acct_use_id = x_acct_use_id;

    l_acct_use_rowid     VARCHAR2(100);
    l_gl_ccid_rowid	VARCHAR2(100);
    l_org_le_id         NUMBER;
  BEGIN
    SAVEPOINT create_bank_acct_use;

    IF l_DEBUG in ('Y', 'C') THEN
      cep_standard.debug('>>CE_BANK_PUB.create_bank_acct_use.');
    END IF;

    -- initialize message list
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    -- first check all required params
    IF (p_acct_use_rec.bank_account_id is null or
        P_acct_use_rec.org_type is null or
        (p_acct_use_rec.legal_entity_id is null and
         p_acct_use_rec.org_id is null) ) THEN  -- bug 7671686
      fnd_message.set_name('CE', 'CE_API_REQUIRED_PARAM');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- GL Cash Account is required if the account use is Payables or Receivables
    IF ((p_acct_use_rec.ap_use_enable_flag = 'Y' or
         p_acct_use_rec.ar_use_enable_flag = 'Y') and
        p_acct_use_rec.asset_code_combination_id is null) THEN -- bug 7671686
      fnd_message.set_name('CE', 'CE_API_CASH_CCID_REQUIRED');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- validate account use
    CE_BANK_AND_ACCOUNT_VALIDATION.validate_account_use
				(p_acct_use_rec.ap_use_enable_flag,
				 p_acct_use_rec.ar_use_enable_flag,
				 p_acct_use_rec.pay_use_enable_flag,
				 p_acct_use_rec.xtr_use_enable_flag,
				 x_return_status);

    -- raise an exception if the validation is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- validate the combination of bank_account_id and org_id/legal_entity_id is unique
    IF p_acct_use_rec.org_type = 'LE' THEN
      l_org_le_id := p_acct_use_rec.legal_entity_id;
    ELSE
      l_org_le_id := p_acct_use_rec.org_id;
    END IF;

    CE_BANK_AND_ACCOUNT_VALIDATION.validate_unique_org_access
				(l_org_le_id,
                                 p_acct_use_rec.bank_account_id,
                                 null,
                                 x_return_status);
    -- raise an exception if the validation is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- validate the org type matches with the account use
    CE_BANK_AND_ACCOUNT_VALIDATION.validate_account_access_org
				(p_acct_use_rec.ap_use_enable_flag,
				 p_acct_use_rec.ar_use_enable_flag,
				 p_acct_use_rec.pay_use_enable_flag,
				 p_acct_use_rec.xtr_use_enable_flag,
				 p_acct_use_rec.org_type,
                                 l_org_le_id,
				 x_return_status);
    -- raise an exception if the validation is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- validate default settlement
    CE_BANK_AND_ACCOUNT_VALIDATION.validate_def_settlement
				(p_acct_use_rec.bank_account_id,
				 null,
				 l_org_le_id,
				 p_acct_use_rec.xtr_default_settlement_flag,
				 p_acct_use_rec.ap_default_settlement_flag,
				 FND_API.G_FALSE,
				 x_msg_count,
				 x_msg_data,
				 x_return_status);
    -- raise an exception if the validation is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- insert data into ce_bank_accounts table
    OPEN c_acct_use_id;
    FETCH c_acct_use_id INTO x_acct_use_id;
    CLOSE c_acct_use_id;

    INSERT INTO CE_BANK_ACCT_USES_ALL (
	BANK_ACCT_USE_ID,
        BANK_ACCOUNT_ID,
	PRIMARY_FLAG,
	ORG_ID,
	ORG_PARTY_ID,
	AP_USE_ENABLE_FLAG,
	AR_USE_ENABLE_FLAG,
	XTR_USE_ENABLE_FLAG,
	PAY_USE_ENABLE_FLAG,
	EDISC_RECEIVABLES_TRX_ID,
	UNEDISC_RECEIVABLES_TRX_ID,
	END_DATE,
	BR_STD_RECEIVABLES_TRX_ID,
	LEGAL_ENTITY_ID,
	INVESTMENT_LIMIT_CODE,
	FUNDING_LIMIT_CODE,
	AP_DEFAULT_SETTLEMENT_FLAG,
	XTR_DEFAULT_SETTLEMENT_FLAG,
	PAYROLL_BANK_ACCOUNT_ID,
	PRICING_MODEL,
	AUTHORIZED_FLAG,
	EFT_SCRIPT_NAME,
	DEFAULT_ACCOUNT_FLAG,
	PORTFOLIO_CODE,
	ATTRIBUTE_CATEGORY,
	ATTRIBUTE1,
	ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        CREATION_DATE,
        CREATED_BY,
        OBJECT_VERSION_NUMBER)
    VALUES (
	x_acct_use_id,
	p_acct_use_rec.bank_account_id,
	p_acct_use_rec.primary_flag,
	p_acct_use_rec.org_id,
	p_acct_use_rec.org_party_id,
	p_acct_use_rec.ap_use_enable_flag,
	p_acct_use_rec.ar_use_enable_flag,
	p_acct_use_rec.xtr_use_enable_flag,
	p_acct_use_rec.pay_use_enable_flag,
	p_acct_use_rec.edisc_receivables_trx_id,
	p_acct_use_rec.unedisc_receivables_trx_id,
	p_acct_use_rec.end_date,
	p_acct_use_rec.br_std_receivables_trx_id,
	p_acct_use_rec.legal_entity_id,
	p_acct_use_rec.investment_limit_code,
	p_acct_use_rec.funding_limit_code,
	p_acct_use_rec.ap_default_settlement_flag,
	p_acct_use_rec.xtr_default_settlement_flag,
	p_acct_use_rec.payroll_bank_account_id,
	p_acct_use_rec.pricing_model,
	p_acct_use_rec.authorized_flag,
	p_acct_use_rec.eft_script_name,
	p_acct_use_rec.default_account_flag,
	p_acct_use_rec.portfolio_code,
	p_acct_use_rec.attribute_category,
	p_acct_use_rec.attribute1,
	p_acct_use_rec.attribute2,
	p_acct_use_rec.attribute3,
	p_acct_use_rec.attribute4,
	p_acct_use_rec.attribute5,
        p_acct_use_rec.attribute6,
        p_acct_use_rec.attribute7,
        p_acct_use_rec.attribute8,
        p_acct_use_rec.attribute9,
        p_acct_use_rec.attribute10,
        p_acct_use_rec.attribute11,
        p_acct_use_rec.attribute12,
        p_acct_use_rec.attribute13,
        p_acct_use_rec.attribute14,
        p_acct_use_rec.attribute15,
        sysdate,
        NVL(FND_GLOBAL.user_id,-1),
        NVL(FND_GLOBAL.login_id, -1),
        sysdate,
        NVL(FND_GLOBAL.user_id,-1),
        1);

    INSERT INTO CE_GL_ACCOUNTS_CCID (
        BANK_ACCT_USE_ID,
	ASSET_CODE_COMBINATION_ID,
	AP_ASSET_CCID,
	AR_ASSET_CCID,
	CASH_CLEARING_CCID,
	BANK_CHARGES_CCID,
	BANK_ERRORS_CCID,
	GAIN_CODE_COMBINATION_ID,
	LOSS_CODE_COMBINATION_ID,
	ON_ACCOUNT_CCID,
	UNAPPLIED_CCID,
	UNIDENTIFIED_CCID,
	FACTOR_CCID,
	RECEIPT_CLEARING_CCID,
	REMITTANCE_CCID,
	AR_SHORT_TERM_DEPOSIT_CCID,
	BR_SHORT_TERM_DEPOSIT_CCID,
	FUTURE_DATED_PAYMENT_CCID,
	BR_REMITTANCE_CCID,
	BR_FACTOR_CCID,
	BANK_INTEREST_EXPENSE_CCID,
	BANK_INTEREST_INCOME_CCID,
	XTR_ASSET_CCID,
	AR_BANK_CHARGES_CCID,  -- 7437641
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        CREATION_DATE,
        CREATED_BY,
        OBJECT_VERSION_NUMBER)
    VALUES (
        x_acct_use_id,
	p_acct_use_rec.asset_code_combination_id,
	p_acct_use_rec.ap_asset_ccid,
	p_acct_use_rec.ar_asset_ccid,
	p_acct_use_rec.cash_clearing_ccid,
	p_acct_use_rec.bank_charges_ccid,
	p_acct_use_rec.bank_errors_ccid,
	p_acct_use_rec.gain_code_combination_id,
	p_acct_use_rec.loss_code_combination_id,
	p_acct_use_rec.on_account_ccid,
	p_acct_use_rec.unapplied_ccid,
	p_acct_use_rec.unidentified_ccid,
	p_acct_use_rec.factor_ccid,
	p_acct_use_rec.receipt_clearing_ccid,
	p_acct_use_rec.remittance_ccid,
	p_acct_use_rec.ar_short_term_deposit_ccid,
	p_acct_use_rec.br_short_term_deposit_ccid,
	p_acct_use_rec.future_dated_payment_ccid,
	p_acct_use_rec.br_remittance_ccid,
	p_acct_use_rec.br_factor_ccid,
	p_acct_use_rec.bank_interest_expense_ccid,
	p_acct_use_rec.bank_interest_income_ccid,
	p_acct_use_rec.xtr_asset_ccid,
        p_acct_use_rec.ar_bank_charges_ccid,  -- 7437641
        sysdate,
        NVL(FND_GLOBAL.user_id,-1),
        NVL(FND_GLOBAL.login_id, -1),
        sysdate,
        NVL(FND_GLOBAL.user_id,-1),
        1);

    OPEN c_acct_use_rowid;
    FETCH c_acct_use_rowid INTO l_acct_use_rowid;
    If (c_acct_use_rowid%NOTFOUND) then
       CLOSE c_acct_use_rowid;
       RAISE NO_DATA_FOUND;
    End If;
    CLOSE c_acct_use_rowid;

    OPEN c_gl_ccid_rowid;
    FETCH c_gl_ccid_rowid INTO l_gl_ccid_rowid;
    If (c_gl_ccid_rowid%NOTFOUND) then
       CLOSE c_gl_ccid_rowid;
       RAISE NO_DATA_FOUND;
    End If;
    CLOSE c_gl_ccid_rowid;

    -- get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);

    IF l_DEBUG in ('Y', 'C') THEN
      cep_standard.debug('<<CE_BANK_PUB.create_bank_acct_use.');
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_bank_acct_use;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      IF l_DEBUG in ('Y', 'C') THEN
        cep_standard.debug_msg_stack(x_msg_count, x_msg_data);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_bank_acct_use;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      IF l_DEBUG in ('Y', 'C') THEN
        cep_standard.debug_msg_stack(x_msg_count, x_msg_data);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO create_bank_acct_use;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('CE', 'CE_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR',SQLERRM);
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      IF l_DEBUG in ('Y', 'C') THEN
        cep_standard.debug_msg_stack(x_msg_count, x_msg_data);
      END IF;


  END create_bank_acct_use;


  PROCEDURE update_bank_acct_use (
        p_init_msg_list                 IN     VARCHAR2:= fnd_api.g_false,
        p_acct_use_rec                  IN      BankAcct_use_rec_type,
        p_use_ovn	                IN OUT  NOCOPY NUMBER,
        p_ccid_ovn			IN OUT  NOCOPY NUMBER,
        x_return_status                 OUT    NOCOPY  VARCHAR2,
        x_msg_count                     OUT    NOCOPY  NUMBER,
        x_msg_data                      OUT    NOCOPY  VARCHAR2
  ) IS
    CURSOR c_acct_org IS
      SELECT bank_account_id,
             org_id,
             legal_entity_id
      FROM   ce_bank_acct_uses_all
      WHERE  bank_acct_use_id = p_acct_use_rec.bank_acct_use_id;

    CURSOR c_use_ovn IS
      SELECT object_version_number
      FROM   ce_bank_acct_uses_all
      WHERE  bank_acct_use_id = p_acct_use_rec.bank_acct_use_id;

    CURSOR c_ccid_ovn IS
      SELECT object_version_number
      FROM   ce_gl_accounts_ccid
      WHERE  bank_acct_use_id = p_acct_use_rec.bank_acct_use_id;

    l_acct_id           NUMBER(15);
    l_org_id		NUMBER(15);
    l_le_id		NUMBER(15);
    l_org_le_id		NUMBER(15);
    l_org_type		VARCHAR2(8);
    l_old_use_ovn       NUMBER(15);
    l_old_ccid_ovn	NUMBER(15);
  BEGIN
    SAVEPOINT update_bank_acct_use;

    IF l_DEBUG in ('Y', 'C') THEN
      cep_standard.debug('>>CE_BANK_PUB.update_bank_acct_use.');
    END IF;

    -- initialize message list
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    -- bank_account_id and org_id/legal_entity_id cannot be updated
    -- find them using the bank_acct_use_id
    OPEN c_acct_org;
    FETCH c_acct_org INTO l_acct_id, l_org_id, l_le_id;
    IF c_acct_org%NOTFOUND THEN
      fnd_message.set_name('CE', 'CE_API_NO_ACCOUNT_USE');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
      CLOSE c_acct_org;
      RAISE fnd_api.g_exc_error;
    END IF;
    CLOSE c_acct_org;

    IF l_org_id is not null AND l_org_id <> -1 THEN -- Bug 9150022
      l_org_le_id := l_org_id;
      l_org_type := 'BGOU';
    ELSE
      l_org_le_id := l_le_id;
      l_org_type := 'LE';
    END IF;

    -- first check all required params
    IF (p_acct_use_rec.bank_acct_use_id is null or
        p_use_ovn is null or
	p_ccid_ovn is null) THEN -- bug 7671686
      fnd_message.set_name('CE', 'CE_API_REQUIRED_PARAM');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- GL Cash Account is required if the account use is Payables or Receivables
    IF ((p_acct_use_rec.ap_use_enable_flag = 'Y' or
         p_acct_use_rec.ar_use_enable_flag = 'Y') and
        p_acct_use_rec.asset_code_combination_id is null) THEN -- bug 7671686
      fnd_message.set_name('CE', 'CE_API_CASH_CCID_REQUIRED');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- validate account use
    CE_BANK_AND_ACCOUNT_VALIDATION.validate_account_use
                                (p_acct_use_rec.ap_use_enable_flag,
                                 p_acct_use_rec.ar_use_enable_flag,
                                 p_acct_use_rec.pay_use_enable_flag,
                                 p_acct_use_rec.xtr_use_enable_flag,
                                 x_return_status);

    -- raise an exception if the validation is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- validate the org type matches with the account use
    CE_BANK_AND_ACCOUNT_VALIDATION.validate_account_access_org
                                (p_acct_use_rec.ap_use_enable_flag,
                                 p_acct_use_rec.ar_use_enable_flag,
                                 p_acct_use_rec.pay_use_enable_flag,
                                 p_acct_use_rec.xtr_use_enable_flag,
                                 l_org_type,
                                 l_org_le_id,
                                 x_return_status);
    -- raise an exception if the validation is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- validate default settlement
    CE_BANK_AND_ACCOUNT_VALIDATION.validate_def_settlement
                                (l_acct_id,
                                 p_acct_use_rec.bank_acct_use_id,
                                 l_org_le_id,
                                 p_acct_use_rec.xtr_default_settlement_flag,
                                 p_acct_use_rec.ap_default_settlement_flag,
                                 FND_API.G_FALSE,
                                 x_msg_count,
                                 x_msg_data,
                                 x_return_status);
    -- raise an exception if the validation is unsuccessful
    IF x_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- check object version number to make sure the record has not been updated
    OPEN c_use_ovn;
    FETCH c_use_ovn INTO l_old_use_ovn;
    IF c_use_ovn%NOTFOUND THEN
      fnd_message.set_name('CE', 'CE_API_NO_ACCOUNT_USE');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
      CLOSE c_use_ovn;
      RAISE fnd_api.g_exc_error;
    END IF;
    CLOSE c_use_ovn;

    IF l_old_use_ovn > p_use_ovn THEN
      fnd_message.set_name('CE', 'CE_API_RECORD_CHANGED');
      fnd_message.set_token('TABLE', 'CE_BANK_ACCT_USES_ALL');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- check object version number to make sure the record has not been updated
    OPEN c_ccid_ovn;
    FETCH c_ccid_ovn INTO l_old_ccid_ovn;
    CLOSE c_ccid_ovn;

    IF l_old_ccid_ovn is not null AND l_old_ccid_ovn > p_ccid_ovn THEN
      fnd_message.set_name('CE', 'CE_API_RECORD_CHANGED');
      fnd_message.set_token('TABLE', 'CE_GL_ACCOUNTS_CCID');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- update
    update ce_bank_acct_uses_all
    set    primary_flag		= p_acct_use_rec.primary_flag,
	   ap_use_enable_flag	= p_acct_use_rec.ap_use_enable_flag,
	   ar_use_enable_flag 	= p_acct_use_rec.ar_use_enable_flag,
	   xtr_use_enable_flag	= p_acct_use_rec.xtr_use_enable_flag,
	   pay_use_enable_flag	= p_acct_use_rec.pay_use_enable_flag,
	   edisc_receivables_trx_id	= p_acct_use_rec.edisc_receivables_trx_id,
           unedisc_receivables_trx_id	= p_acct_use_rec.unedisc_receivables_trx_id,
	   end_date 			= p_acct_use_rec.end_date,
	   br_std_receivables_trx_id	= p_acct_use_rec.br_std_receivables_trx_id,
	   investment_limit_code	= p_acct_use_rec.investment_limit_code,
	   funding_limit_code		= p_acct_use_rec.funding_limit_code,
	   ap_default_settlement_flag	= p_acct_use_rec.ap_default_settlement_flag,
	   xtr_default_settlement_flag	= p_acct_use_rec.xtr_default_settlement_flag,
	   payroll_bank_account_id	= p_acct_use_rec.payroll_bank_account_id,
	   pricing_model		= p_acct_use_rec.pricing_model,
	   authorized_flag		= p_acct_use_rec.authorized_flag,
	   eft_script_name		= p_acct_use_rec.eft_script_name,
	   default_account_flag		= p_acct_use_rec.default_account_flag,
	   portfolio_code		= p_acct_use_rec.portfolio_code,
	   attribute_category		= p_acct_use_rec.attribute_category,
	   attribute1			= p_acct_use_rec.attribute1,
           attribute2                   = p_acct_use_rec.attribute2,
           attribute3                   = p_acct_use_rec.attribute3,
           attribute4                   = p_acct_use_rec.attribute4,
           attribute5                   = p_acct_use_rec.attribute5,
           attribute6                   = p_acct_use_rec.attribute6,
           attribute7                   = p_acct_use_rec.attribute7,
           attribute8                   = p_acct_use_rec.attribute8,
           attribute9                   = p_acct_use_rec.attribute9,
           attribute10                  = p_acct_use_rec.attribute10,
           attribute11                  = p_acct_use_rec.attribute11,
           attribute12                  = p_acct_use_rec.attribute12,
           attribute13                  = p_acct_use_rec.attribute13,
           attribute14                  = p_acct_use_rec.attribute14,
           attribute15                  = p_acct_use_rec.attribute15,
           last_update_date            = sysdate,
           last_update_login           = NVL(FND_GLOBAL.login_id,-1),
           last_updated_by             = NVL(FND_GLOBAL.user_id,-1),
           object_version_number       = l_old_use_ovn + 1
    WHERE  bank_acct_use_id = p_acct_use_rec.bank_acct_use_id;
    IF (SQL%NOTFOUND) THEN
      fnd_message.set_name('CE', 'CE_API_NO_ACCOUNT_USE');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
      RAISE fnd_api.g_exc_error;
    END IF;
    p_use_ovn := l_old_use_ovn + 1;

    -- update ccid table
    IF l_old_ccid_ovn is not null THEN
      update ce_gl_accounts_ccid
      set    asset_code_combination_id	= p_acct_use_rec.asset_code_combination_id,
	   ap_asset_ccid		= p_acct_use_rec.ap_asset_ccid,
	   ar_asset_ccid		= p_acct_use_rec.ar_asset_ccid,
	   cash_clearing_ccid		= p_acct_use_rec.cash_clearing_ccid,
	   bank_charges_ccid		= p_acct_use_rec.bank_charges_ccid,
	   bank_errors_ccid		= p_acct_use_rec.bank_errors_ccid,
	   gain_code_combination_id	= p_acct_use_rec.gain_code_combination_id,
	   loss_code_combination_id	= p_acct_use_rec.loss_code_combination_id,
	   on_account_ccid		= p_acct_use_rec.on_account_ccid,
	   unapplied_ccid		= p_acct_use_rec.unapplied_ccid,
	   unidentified_ccid		= p_acct_use_rec.unidentified_ccid,
	   factor_ccid			= p_acct_use_rec.factor_ccid,
	   receipt_clearing_ccid	= p_acct_use_rec.receipt_clearing_ccid,
	   remittance_ccid		= p_acct_use_rec.remittance_ccid,
	   ar_short_term_deposit_ccid	= p_acct_use_rec.ar_short_term_deposit_ccid,
	   br_short_term_deposit_ccid	= p_acct_use_rec.br_short_term_deposit_ccid,
	   future_dated_payment_ccid	= p_acct_use_rec.future_dated_payment_ccid,
	   br_remittance_ccid		= p_acct_use_rec.br_remittance_ccid,
	   br_factor_ccid		= p_acct_use_rec.br_factor_ccid,
	   bank_interest_expense_ccid	= p_acct_use_rec.bank_interest_expense_ccid,
	   bank_interest_income_ccid	= p_acct_use_rec.bank_interest_income_ccid,
	   xtr_asset_ccid		= p_acct_use_rec.xtr_asset_ccid,
	   ar_bank_charges_ccid         = p_acct_use_rec.ar_bank_charges_ccid, -- 7437641
           last_update_date            = sysdate,
           last_update_login           = NVL(FND_GLOBAL.login_id,-1),
           last_updated_by             = NVL(FND_GLOBAL.user_id,-1),
           object_version_number       = l_old_ccid_ovn + 1
      WHERE  bank_acct_use_id = p_acct_use_rec.bank_acct_use_id;
      p_ccid_ovn := l_old_ccid_ovn + 1;
    END IF;

    -- get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);

    IF l_DEBUG in ('Y', 'C') THEN
      cep_standard.debug('<<CE_BANK_PUB.update_bank_acct_use.');
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO update_bank_acct_use;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      IF l_DEBUG in ('Y', 'C') THEN
        cep_standard.debug_msg_stack(x_msg_count, x_msg_data);
      END IF;

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO update_bank_acct_use;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      IF l_DEBUG in ('Y', 'C') THEN
        cep_standard.debug_msg_stack(x_msg_count, x_msg_data);
      END IF;

    WHEN OTHERS THEN
      ROLLBACK TO udpate_bank_acct_use;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_message.set_name('CE', 'CE_API_OTHERS_EXCEP');
      fnd_message.set_token('ERROR',SQLERRM);
      fnd_msg_pub.add;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

      IF l_DEBUG in ('Y', 'C') THEN
        cep_standard.debug_msg_stack(x_msg_count, x_msg_data);
      END IF;

  END update_bank_acct_use;


END ce_bank_pub;

/
