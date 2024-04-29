--------------------------------------------------------
--  DDL for Package Body IBY_EXT_BANKACCT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_EXT_BANKACCT_PUB" AS
/*$Header: ibyxbnkb.pls 120.33.12010000.31 2010/04/19 09:06:44 vkarlapu ship $*/

G_CURRENT_RUNTIME_LEVEL      CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_STATEMENT            CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
 --
 -- Forward Declarations
 --
 FUNCTION get_country (
    p_bank_id		   IN     NUMBER,
    x_return_status        IN OUT NOCOPY VARCHAR2
  ) RETURN VARCHAR2;

 PROCEDURE find_bank_info (
    p_branch_id            IN     NUMBER,
    x_return_status        IN     OUT NOCOPY VARCHAR2,
    x_bank_id		       OUT    NOCOPY NUMBER,
    x_country_code	       OUT    NOCOPY VARCHAR2,
    x_bank_name		       OUT    NOCOPY VARCHAR2,
    x_bank_number          OUT    NOCOPY VARCHAR2
  );

  PROCEDURE print_debuginfo(
    p_message              IN     VARCHAR2,
    p_prefix               IN     VARCHAR2 DEFAULT 'DEBUG',
    p_msg_level            IN     NUMBER   DEFAULT FND_LOG.LEVEL_STATEMENT,
    p_module               IN     VARCHAR2 DEFAULT G_DEBUG_MODULE
  );

  PROCEDURE check_mandatory(
      p_field           IN     VARCHAR2,
      p_value           IN     VARCHAR2
   );

  --
  -- USE: Gets credit card mask settings
  --
  PROCEDURE Get_Mask_Settings
  (x_mask_setting  OUT NOCOPY iby_sys_security_options.ext_ba_mask_setting%TYPE,
   x_unmask_len    OUT NOCOPY iby_sys_security_options.ext_ba_unmask_len%TYPE
  );


  /*======================================================================
   * APIs defined in this package
   *
   *   1. create_ext_bank
   *   2. update_ext_bank
   *   3. set_ext_bank_end_date
   *   4. check_ext_bank_exist
   *   5. create_bank_branch
   *   6. update_bank_branch
   *   7. set_bank_branch_end_date
   *   8. check_ext_bank_branch_exist
   *   9. create_ext_bank_acct
   *  10. update_ext_bank_acct
   *  11. set_ext_bank_acct_dates
   *  12. check_ext_acct_exist
   *  13. get_ext_bank_acct
   *  14. get_ext_bank_acct
   *  15. create_intermediary_acct
   *  16. update_intermediary_acct
   *  17. add_joint_acct_owner
   *  18. set_joint_acct_owner_end_date
   *  19. change_primary_acct_owner
   *  20. check_bank_acct_owner
   +====================================================================*/

   -- 1. create_ext_bank
   --
   --   API name        : create_ext_bank
   --   Type            : Public
   --   Pre-reqs        : None
   --   Function        : Creates an external bank
   --   Current version : 1.0
   --   Previous version: 1.0
   --   Initial version : 1.0
   --
  PROCEDURE create_ext_bank (
    p_api_version              IN  NUMBER,
	p_init_msg_list            IN  VARCHAR2,
	p_ext_bank_rec             IN  ExtBank_rec_type,
	x_bank_id                  OUT NOCOPY NUMBER,
	x_return_status            OUT NOCOPY VARCHAR2,
	x_msg_count                OUT NOCOPY NUMBER,
	x_msg_data                 OUT NOCOPY VARCHAR2,
	x_response                 OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
  ) IS

  l_api_name           CONSTANT VARCHAR2(30)   := 'create_ext_bank';
  l_api_version        CONSTANT NUMBER         := 1.0;
  l_module_name        CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.' || l_api_name;
  l_dup_bank_id number;
  l_dup_end_date date;
  BEGIN
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('Enter ' || l_module_name);

    END IF;
    SAVEPOINT create_bank_pub;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Start of API body

    -- Parameter validations
    check_mandatory('IBY_COUNTRY_CD_FIELD',p_ext_bank_rec.country_code);
    check_mandatory('IBY_BANK_NAME_FIELD',p_ext_bank_rec.bank_name);

    -- Other Needed Validations
    -- 1. Country Specific validations: Perfomed by CE
    -- 2. 3 generic Validations
    --    i. Country and Bank Name combination must be unique
    --   ii. Combination of Country and Short Bank Name must be unique
    --  iii. Country and Bank Number must be unique
    --
/*
  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	  print_debuginfo('Before Call to  ''ce_bank_pub.check_bank_exists''');
  END IF;
    -- Call CE API to check bank exists



   ce_bank_pub.check_bank_exist(p_ext_bank_rec.country_code,
			                p_ext_bank_rec.bank_name,
			                p_ext_bank_rec.bank_number,
                                        l_dup_bank_id,
                                        l_dup_end_date);

  IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	  print_debuginfo('Duplicate Bank Id : ' || l_dup_bank_id);
  END IF;
    -- End of API body
*/

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('Before Call to  ''ce_bank_pub.create_bank''');
    END IF;
    -- Call CE API to create bank
    ce_bank_pub.create_bank(p_init_msg_list,
			                p_ext_bank_rec.country_code,
			                p_ext_bank_rec.bank_name,
			                p_ext_bank_rec.bank_number,
			                p_ext_bank_rec.bank_alt_name,
			                p_ext_bank_rec.bank_short_name,  -- p_short_bank_name
			                p_ext_bank_rec.description,
			                p_ext_bank_rec.tax_payer_id,  -- p_tax_payer_id
			                p_ext_bank_rec.tax_registration_number,  -- p_tax_registration_number
			                p_ext_bank_rec.attribute_category,  -- p_attribute_category
                            p_ext_bank_rec.attribute1,  -- p_attribute1
                            p_ext_bank_rec.attribute2,  -- p_attribute2
                            p_ext_bank_rec.attribute3,  -- p_attribute3
                            p_ext_bank_rec.attribute4,  -- p_attribute4
                            p_ext_bank_rec.attribute5,  -- p_attribute5
                            p_ext_bank_rec.attribute6,  -- p_attribute6
                            p_ext_bank_rec.attribute7,  -- p_attribute7
                            p_ext_bank_rec.attribute8,  -- p_attribute8
                            p_ext_bank_rec.attribute9,  -- p_attribute9
                            p_ext_bank_rec.attribute10,  -- p_attribute10
                            p_ext_bank_rec.attribute11,  -- p_attribute11
                            p_ext_bank_rec.attribute12,  -- p_attribute12
                            p_ext_bank_rec.attribute13,  -- p_attribute13
                            p_ext_bank_rec.attribute14,  -- p_attribute14
                            p_ext_bank_rec.attribute15,  -- p_attribute15
                            p_ext_bank_rec.attribute16,  -- p_attribute16
                            p_ext_bank_rec.attribute17,  -- p_attribute17
                            p_ext_bank_rec.attribute18,  -- p_attribute18
                            p_ext_bank_rec.attribute19,  -- p_attribute19
                            p_ext_bank_rec.attribute20,  -- p_attribute20
                            p_ext_bank_rec.attribute21,  -- p_attribute21
                            p_ext_bank_rec.attribute22,  -- p_attribute22
                            p_ext_bank_rec.attribute23,  -- p_attribute23
                            p_ext_bank_rec.attribute24,  -- p_attribute24
			                x_bank_id, --x_bank_id
			                x_return_status, --x_return_status
			                x_msg_count, --x_msg_count
			                x_msg_data --x_msg_data
                           );
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('Ext Bank Id : ' || x_bank_id);
    END IF;
    -- End of API body

    -- get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('RETURN ' || l_module_name);

    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_bank_pub;
      x_return_status := fnd_api.g_ret_sts_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Exception : ' || SQLERRM);
      END IF;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_bank_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Exception : ' || SQLERRM);
      END IF;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


    WHEN OTHERS THEN
      ROLLBACK TO create_bank_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Exception : ' || SQLERRM);
      END IF;
     FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


  END create_ext_bank;


  -- 2. update_ext_bank
  --
  --   API name        : update_ext_bank
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Updates the external bank
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE update_ext_bank (
        p_api_version              IN   NUMBER,
	    p_init_msg_list            IN   VARCHAR2,
	    p_ext_bank_rec             IN   ExtBank_rec_type,
	    x_return_status            OUT  NOCOPY  VARCHAR2,
	    x_msg_count                OUT  NOCOPY  NUMBER,
	    x_msg_data                 OUT  NOCOPY  VARCHAR2,
	    x_response                 OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
    )IS

  l_api_name           CONSTANT VARCHAR2(30)   := 'update_bank';
  l_api_version        CONSTANT NUMBER         := 1.0;
  l_module_name        CONSTANT VARCHAR2(200)   := G_PKG_NAME || '.' || l_api_name;

  x_object_version_number NUMBER := p_ext_bank_rec.object_version_number;

  BEGIN
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('ENTER ' || l_module_name);

    END IF;
    SAVEPOINT update_bank_pub;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Start of API body

    -- Parameter validations
    check_mandatory('IBY_BANK_ID_FIELD',p_ext_bank_rec.bank_id);
    check_mandatory('IBY_BANK_NAME_FIELD',p_ext_bank_rec.bank_name);
    check_mandatory('IBY_OBJ_VER_NUM',p_ext_bank_rec.object_version_number);

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('Calling CE API to update bank');

    END IF;
    ce_bank_pub.update_bank(p_init_msg_list => p_init_msg_list,
                            p_bank_id => p_ext_bank_rec.bank_id,
			    p_bank_name => p_ext_bank_rec.bank_name,
                            p_bank_number => p_ext_bank_rec.bank_number,
                            p_alternate_bank_name => p_ext_bank_rec.bank_alt_name,
                            p_short_bank_name => p_ext_bank_rec.bank_short_name, -- p_short_bank_name
                            p_description => p_ext_bank_rec.description,
                            p_tax_payer_id => p_ext_bank_rec.tax_payer_id,   -- p_tax_payer_id
                            p_tax_registration_number => p_ext_bank_rec.tax_registration_number,   -- p_tax_registration_number
                            p_attribute_category => p_ext_bank_rec.attribute_category,   -- p_attribute_category
                            p_attribute1 => p_ext_bank_rec.attribute1,   -- p_attribute1
                            p_attribute2 => p_ext_bank_rec.attribute2,   -- p_attribute2
                            p_attribute3 => p_ext_bank_rec.attribute3,   -- p_attribute3
                            p_attribute4 => p_ext_bank_rec.attribute4,   -- p_attribute4
                            p_attribute5 => p_ext_bank_rec.attribute5,   -- p_attribute5
                            p_attribute6 => p_ext_bank_rec.attribute6,   -- p_attribute6
                            p_attribute7 => p_ext_bank_rec.attribute7,   -- p_attribute7
                            p_attribute8 => p_ext_bank_rec.attribute8,   -- p_attribute8
                            p_attribute9 => p_ext_bank_rec.attribute9,   -- p_attribute9
                            p_attribute10 => p_ext_bank_rec.attribute10,   -- p_attribute10
                            p_attribute11 => p_ext_bank_rec.attribute11,   -- p_attribute11
                            p_attribute12 => p_ext_bank_rec.attribute12,   -- p_attribute12
                            p_attribute13 => p_ext_bank_rec.attribute13,   -- p_attribute13
                            p_attribute14 => p_ext_bank_rec.attribute14,   -- p_attribute14
                            p_attribute15 => p_ext_bank_rec.attribute15,   -- p_attribute15
                            p_attribute16 => p_ext_bank_rec.attribute16,   -- p_attribute16
                            p_attribute17 => p_ext_bank_rec.attribute17,   -- p_attribute17
                            p_attribute18 => p_ext_bank_rec.attribute18,   -- p_attribute18
                            p_attribute19 => p_ext_bank_rec.attribute19,   -- p_attribute19
                            p_attribute20 => p_ext_bank_rec.attribute20,   -- p_attribute20
                            p_attribute21 => p_ext_bank_rec.attribute21,   -- p_attribute21
                            p_attribute22 => p_ext_bank_rec.attribute22,   -- p_attribute22
                            p_attribute23 => p_ext_bank_rec.attribute23,   -- p_attribute23
                            p_attribute24 => p_ext_bank_rec.attribute24,   -- p_attribute24
			    p_object_version_number => x_object_version_number,
                            x_return_status => x_return_status,
			    x_msg_count => x_msg_count,
                            x_msg_data => x_msg_data);

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('Returned from CE API');
    END IF;
    -- End of API body

    -- get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('RETURN ' || l_module_name);

    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO update_bank_pub;
      x_return_status := fnd_api.g_ret_sts_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Exception : ' || SQLERRM);
      END IF;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO update_bank_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Exception : ' || SQLERRM);
      END IF;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


    WHEN OTHERS THEN
      ROLLBACK TO update_bank_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Exception : ' || SQLERRM);

      END IF;
      FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


  END update_ext_bank;


  -- 3. set_bank_end_date
  --
  --   API name        : set_bank_end_date
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Sets the bank end date
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
   PROCEDURE set_bank_end_date (
    p_api_version               IN   NUMBER,
    p_init_msg_list             IN  VARCHAR2,
    p_bank_id                   IN   NUMBER,
    p_end_date                  IN   DATE,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2,
    x_response                  OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
    ) IS

   l_api_name           CONSTANT VARCHAR2(30)   := 'set_bank_end_date';
   l_api_version        CONSTANT NUMBER         := 1.0;
   l_module_name        CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.' || l_api_name;

   l_object_version_number  NUMBER;

    CURSOR c_bank_ovn IS
      SELECT object_version_number
      FROM   hz_parties
      WHERE  party_id = p_bank_id;

   BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo('ENTER ' || l_module_name);

     END IF;
     SAVEPOINT set_bank_end_date_pub;

     -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF FND_API.to_Boolean(p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
     END IF;

     --  Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- Start of API body

     -- Parameter validations
     check_mandatory('IBY_BANK_ID_FIELD',p_bank_id);
     check_mandatory('IBY_END_DATE' ,p_end_date);

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo('Before Call to CE_BANK_PUB.set_bank_end_date ');

     END IF;
     -- Fetch Object Version Number for Bank Party
     OPEN c_bank_ovn;
     FETCH c_bank_ovn INTO l_object_version_number;
     CLOSE c_bank_ovn;

     ce_bank_pub.set_bank_end_date (
        NULL,
        p_bank_id,
        p_end_date,
        l_object_version_number,
        x_return_status,
        x_msg_count,
        x_msg_data
        );

     -- End of API body

     -- get message count and if count is 1, get message info.
     fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo('RETURN ' || l_module_name);
     END IF;
     EXCEPTION
     WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO set_bank_end_date_pub;
      x_return_status := fnd_api.g_ret_sts_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Exception : ' || SQLERRM);
      END IF;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


     WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO set_bank_end_date_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Exception : ' || SQLERRM);
      END IF;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


     WHEN OTHERS THEN
      ROLLBACK TO set_bank_end_date_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Exception : ' || SQLERRM);
      END IF;
    FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

   END set_bank_end_date;


  -- 4. check_bank_exist
  --
  --   API name        : check_bank_exist
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Checks if the bank exists; bank name/number
  --                     and country code are used for identity
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE check_bank_exist (
   p_api_version                 IN   NUMBER,
   p_init_msg_list               IN  VARCHAR2,
   p_country_code                IN   VARCHAR2,
   p_bank_name                   IN   VARCHAR2,
   p_bank_number                 IN   VARCHAR2,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2,
   x_bank_id                     OUT NOCOPY NUMBER,
   x_end_date                    OUT NOCOPY DATE,
   x_response                    OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
    )IS

   l_api_name           CONSTANT VARCHAR2(30)   := 'check_bank_exist';
   l_api_version        CONSTANT NUMBER         := 1.0;
   l_module_name        CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.' || l_api_name;

   BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo('ENTER ' || l_module_name);

     END IF;
     -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF FND_API.to_Boolean(p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
     END IF;

     --  Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- Start of API body

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo('Before Call to CE_BANK_PUB.check_bank_exist ');

     END IF;
     ce_bank_pub.check_bank_exist(
        p_country_code,
        p_bank_name,
        p_bank_number,
        x_bank_id,
        x_end_date
        );

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo('Ext Bank Id : ' || x_bank_id);

     END IF;
     -- End of API body

     -- get message count and if count is 1, get message info.
     fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo('RETURN ' || l_module_name);
     END IF;
     EXCEPTION
     WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Exception : ' || SQLERRM);
      END IF;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


     WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Exception : ' || SQLERRM);
      END IF;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


     WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Exception : ' || SQLERRM);

      END IF;
   FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

   END check_bank_exist;


  -- 5. create_ext_bank_branch
  --
  --   API name        : create_ext_bank_branch
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Creates the external bank branch
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE create_ext_bank_branch (
   p_api_version                IN   NUMBER,
   p_init_msg_list              IN   VARCHAR2,
   p_ext_bank_branch_rec        IN   ExtBankBranch_rec_type,
   x_branch_id                  OUT  NOCOPY  NUMBER,
   x_return_status              OUT  NOCOPY  VARCHAR2,
   x_msg_count                  OUT  NOCOPY  NUMBER,
   x_msg_data                   OUT  NOCOPY  VARCHAR2,
   x_response                   OUT  NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
  ) IS

  l_api_name           CONSTANT VARCHAR2(30)   := 'create_ext_bank_branch';
  l_api_version        CONSTANT NUMBER         := 1.0;
  l_module_name        CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.' || l_api_name;


  BEGIN
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('ENTER ' || l_module_name);

    END IF;
    SAVEPOINT create_bank_branch_pub;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Start of API body

    -- Parameter validations
    check_mandatory('IBY_BANK_PARTY_ID_FIELD',p_ext_bank_branch_rec.bank_party_id);
    check_mandatory('IBY_BRANCH_NAME_FIELD',p_ext_bank_branch_rec.branch_name);
    check_mandatory('IBY_BRANCH_TYPE_FIELD',p_ext_bank_branch_rec.branch_type);

    -- Other Needed Validations
    -- 1. Country Specific validations: Perfomed by CE
    --    i. Bank Name, Branch Name and Country must be unique
    --       for non-US and Germany Bank branches
    --   ii. Bank Number, Branch Number and Country must be unique
    --       for non-US and Germany bank branches
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('Before Call to  ''ce_bank_pub.create_bank_branch''');
    END IF;
    -- Call CE API to create bank branch
    ce_bank_pub.create_bank_branch(p_init_msg_list,
				                   p_ext_bank_branch_rec.bank_party_id,
				                   p_ext_bank_branch_rec.branch_name,
				                   p_ext_bank_branch_rec.branch_number,
				                   p_ext_bank_branch_rec.branch_type,
				                   p_ext_bank_branch_rec.alternate_branch_name,
				                   p_ext_bank_branch_rec.description,
				                   p_ext_bank_branch_rec.bic,
				                   p_ext_bank_branch_rec.eft_number,   -- p_eft_number
				                   p_ext_bank_branch_rec.rfc_identifier,
				                   p_ext_bank_branch_rec.attribute_category,   -- p_attribute_category
				                   p_ext_bank_branch_rec.attribute1,    -- p_attribute1
                                   p_ext_bank_branch_rec.attribute2,    -- p_attribute2
                                   p_ext_bank_branch_rec.attribute3,    -- p_attribute3
                                   p_ext_bank_branch_rec.attribute4,    -- p_attribute4
                                   p_ext_bank_branch_rec.attribute5,    -- p_attribute5
                                   p_ext_bank_branch_rec.attribute6,    -- p_attribute6
                                   p_ext_bank_branch_rec.attribute7,    -- p_attribute7
                                   p_ext_bank_branch_rec.attribute8,    -- p_attribute8
                                   p_ext_bank_branch_rec.attribute9,    -- p_attribute9
                                   p_ext_bank_branch_rec.attribute10,   -- p_attribute10
                                   p_ext_bank_branch_rec.attribute11,   -- p_attribute11
                                   p_ext_bank_branch_rec.attribute12,   -- p_attribute12
                                   p_ext_bank_branch_rec.attribute13,   -- p_attribute13
                                   p_ext_bank_branch_rec.attribute14,   -- p_attribute14
                                   p_ext_bank_branch_rec.attribute15,   -- p_attribute15
                                   p_ext_bank_branch_rec.attribute16,   -- p_attribute16
                                   p_ext_bank_branch_rec.attribute17,   -- p_attribute17
                                   p_ext_bank_branch_rec.attribute18,   -- p_attribute18
                                   p_ext_bank_branch_rec.attribute19,   -- p_attribute19
                                   p_ext_bank_branch_rec.attribute20,   -- p_attribute20
                                   p_ext_bank_branch_rec.attribute21,   -- p_attribute21
                                   p_ext_bank_branch_rec.attribute22,   -- p_attribute22
                                   p_ext_bank_branch_rec.attribute23,   -- p_attribute23
                                   p_ext_bank_branch_rec.attribute24,   -- p_attribute24
			    	               x_branch_id,
                            	   x_return_status,
				                   x_msg_count,
				                   x_msg_data);

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('Ext Bank Branch Id : ' || x_branch_id);
    END IF;
	-- End of API body

    -- get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('RETURN ' || l_module_name);

    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_bank_branch_pub;
      x_return_status := fnd_api.g_ret_sts_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Exception : ' || SQLERRM);
      END IF;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_bank_branch_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Exception : ' || SQLERRM);
      END IF;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


    WHEN OTHERS THEN
      ROLLBACK TO create_bank_branch_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Exception : ' || SQLERRM);

      END IF;
    FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

  END create_ext_bank_branch;


  -- 6. update_ext_bank_branch
  --
  --   API name        : update_ext_bank_branch
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Updates the external bank branch
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE update_ext_bank_branch (
   p_api_version                IN     NUMBER,
   p_init_msg_list              IN     VARCHAR2,
   p_ext_bank_branch_rec        IN OUT NOCOPY ExtBankBranch_rec_type,
   x_return_status                 OUT NOCOPY  VARCHAR2,
   x_msg_count                     OUT NOCOPY  NUMBER,
   x_msg_data                      OUT NOCOPY  VARCHAR2,
   x_response                      OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
  ) IS

  l_api_name           CONSTANT VARCHAR2(30)   := 'update_ext_bank_branch';
  l_api_version        CONSTANT NUMBER         := 1.0;
  l_module_name        CONSTANT VARCHAR2(200)   := G_PKG_NAME || '.' || l_api_name;

  l_rfc_identifier_ovn NUMBER(15,0);
  l_eft_record_ovn     NUMBER(15,0);

  -- Picks up object version number of RFC identifier
  CURSOR c_rfc_identifier_ovn(p_branch_id NUMBER) IS
     SELECT object_version_number
       FROM HZ_CODE_ASSIGNMENTS
      WHERE class_category = 'RFC_IDENTIFIER'
        AND owner_table_name = 'HZ_PARTIES'
        AND owner_table_id = p_branch_id;

   -- Picks up object version number of EFT Record
  CURSOR c_eft_record_ovn(p_branch_id NUMBER) IS
     SELECT object_version_number
       FROM HZ_CODE_ASSIGNMENTS
      WHERE class_category = 'EFT'
        AND owner_table_name = 'HZ_PARTIES'
        AND owner_table_id = p_branch_id;

  BEGIN
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('ENTER ' || l_module_name);

    END IF;
    SAVEPOINT update_bank_branch_pub;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Start of API Body

     -- Parameter validations
    check_mandatory('IBY_BRANCH_ID_FIELD', p_ext_bank_branch_rec.branch_party_id);
    check_mandatory('IBY_BRANCH_NAME_FIELD', p_ext_bank_branch_rec.branch_name);
    check_mandatory('IBY_BRANCH_TYPE_FIELD', p_ext_bank_branch_rec.branch_type);
    check_mandatory('IBY_BNKBRN_REC_OBJ_VER', p_ext_bank_branch_rec.bch_object_version_number);
    check_mandatory('IBY_BNKBRN_TYPE_OBJ_VER', p_ext_bank_branch_rec.typ_object_version_number);

    -- Get the current RFC Identifier OVN
    OPEN c_rfc_identifier_ovn(p_ext_bank_branch_rec.branch_party_id);
    FETCH c_rfc_identifier_ovn INTO l_rfc_identifier_ovn;
    CLOSE c_rfc_identifier_ovn;

    -- Get the current EFT Identifier OVN
    OPEN c_eft_record_ovn(p_ext_bank_branch_rec.branch_party_id);
    FETCH c_eft_record_ovn INTO l_eft_record_ovn;
    CLOSE c_eft_record_ovn;

    -- Validate the input RFC Identifier OVN
    -- if the current RFC Identifier OVN is not null
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('Input RFC Identifier OVN ' || p_ext_bank_branch_rec.rfc_object_version_number);
    END IF;
    IF (l_rfc_identifier_ovn IS NOT NULL) THEN
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       print_debuginfo('Current RFC Identifier OVN ' || l_rfc_identifier_ovn);
       END IF;
       IF (l_rfc_identifier_ovn <> p_ext_bank_branch_rec.rfc_object_version_number) THEN

         fnd_message.set_name('IBY', 'IBY_DATA_VERSION_ERROR');

         fnd_msg_pub.add;
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo('Object Version Number mismatch');
         END IF;
       END IF;
    ELSE
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       print_debuginfo('Current RFC Identifier OVN is NULL');
       END IF;
    END IF;

    -- Validate the input EFT Identifier OVN
    -- if the current EFT Identifier OVN is not null
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('Input RFC Identifier OVN ' || p_ext_bank_branch_rec.eft_object_version_number);
    END IF;
    IF (l_eft_record_ovn IS NOT NULL) THEN
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       print_debuginfo('Current RFC Identifier OVN ' || l_eft_record_ovn);
       END IF;
       IF (l_eft_record_ovn <> p_ext_bank_branch_rec.eft_object_version_number) THEN
         fnd_message.set_name('IBY', 'IBY_DATA_VERSION_ERROR');
         fnd_msg_pub.add;
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	         print_debuginfo('Object Version Number mismatch');
         END IF;
       END IF;
    ELSE
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       print_debuginfo('Current RFC Identifier OVN is NULL');
       END IF;
    END IF;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('Calling CE API to update bank branch');

    END IF;
    ce_bank_pub.update_bank_branch(p_init_msg_list => p_init_msg_list,
				                   p_branch_id => p_ext_bank_branch_rec.branch_party_id,
						   p_branch_name => p_ext_bank_branch_rec.branch_name,
		                                   p_branch_number => p_ext_bank_branch_rec.branch_number,
						   p_branch_type => p_ext_bank_branch_rec.branch_type,
					           p_alternate_branch_name => p_ext_bank_branch_rec.alternate_branch_name,
					           p_description => p_ext_bank_branch_rec.description,
				                   p_bic => p_ext_bank_branch_rec.bic,
						   p_eft_number => p_ext_bank_branch_rec.eft_number,   -- p_eft_number
				                   p_rfc_identifier => p_ext_bank_branch_rec.rfc_identifier,
				                   p_attribute_category => p_ext_bank_branch_rec.attribute_category,   -- p_attribute_category
                            p_attribute1 => p_ext_bank_branch_rec.attribute1,   -- p_attribute1
                            p_attribute2 => p_ext_bank_branch_rec.attribute2,   -- p_attribute2
                            p_attribute3 => p_ext_bank_branch_rec.attribute3,   -- p_attribute3
                            p_attribute4 => p_ext_bank_branch_rec.attribute4,   -- p_attribute4
                            p_attribute5 => p_ext_bank_branch_rec.attribute5,   -- p_attribute5
                            p_attribute6 => p_ext_bank_branch_rec.attribute6,   -- p_attribute6
                            p_attribute7 => p_ext_bank_branch_rec.attribute7,   -- p_attribute7
                            p_attribute8 => p_ext_bank_branch_rec.attribute8,   -- p_attribute8
                            p_attribute9 => p_ext_bank_branch_rec.attribute9,   -- p_attribute9
                            p_attribute10 => p_ext_bank_branch_rec.attribute10,   -- p_attribute10
                            p_attribute11 => p_ext_bank_branch_rec.attribute11,   -- p_attribute11
                            p_attribute12 => p_ext_bank_branch_rec.attribute12,   -- p_attribute12
                            p_attribute13 => p_ext_bank_branch_rec.attribute13,   -- p_attribute13
                            p_attribute14 => p_ext_bank_branch_rec.attribute14,   -- p_attribute14
                            p_attribute15 => p_ext_bank_branch_rec.attribute15,   -- p_attribute15
                            p_attribute16 => p_ext_bank_branch_rec.attribute16,   -- p_attribute16
                            p_attribute17 => p_ext_bank_branch_rec.attribute17,   -- p_attribute17
                            p_attribute18 => p_ext_bank_branch_rec.attribute18,   -- p_attribute18
                            p_attribute19 => p_ext_bank_branch_rec.attribute19,   -- p_attribute19
                            p_attribute20 => p_ext_bank_branch_rec.attribute20,   -- p_attribute20
                            p_attribute21 => p_ext_bank_branch_rec.attribute21,   -- p_attribute21
                            p_attribute22 => p_ext_bank_branch_rec.attribute22,   -- p_attribute22
                            p_attribute23 => p_ext_bank_branch_rec.attribute23,   -- p_attribute23
                            p_attribute24 => p_ext_bank_branch_rec.attribute24,   -- p_attribute24
                            p_bch_object_version_number => p_ext_bank_branch_rec.bch_object_version_number,
			    p_typ_object_version_number => p_ext_bank_branch_rec.typ_object_version_number,
			    p_rfc_object_version_number => p_ext_bank_branch_rec.rfc_object_version_number,
			    p_eft_object_version_number => p_ext_bank_branch_rec.eft_object_version_number,
                            x_return_status => x_return_status,
                            x_msg_count => x_msg_count,
                            x_msg_data => x_msg_data);

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('Returned from CE API');
    END IF;
	-- End of API Body

    -- get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('RETURN ' || l_module_name);

    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO update_bank_branch_pub;
      x_return_status := fnd_api.g_ret_sts_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Exception : ' || SQLERRM);
      END IF;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO update_bank_branch_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Exception : ' || SQLERRM);
      END IF;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


    WHEN OTHERS THEN
      ROLLBACK TO update_bank_branch_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Exception : ' || SQLERRM);

      END IF;
    FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


  END update_ext_bank_branch;


  -- 7. set_ext_bank_branch_end_date
  --
  --   API name        : set_ext_bank_branch_end_date
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Sets the bank branch end date
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE set_ext_bank_branch_end_date (
   p_api_version                IN   NUMBER,
   p_init_msg_list              IN   VARCHAR2,
   p_branch_id                  IN   NUMBER,
   p_end_date                   IN   DATE,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,
   x_response                   OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
  ) IS

   l_api_name           CONSTANT VARCHAR2(30)   := 'set_ext_bank_branch_end_date';
   l_api_version        CONSTANT NUMBER         := 1.0;
   l_module_name        CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.' || l_api_name;

   l_object_version_number  NUMBER;

   CURSOR c_branch_party_ovn IS
      SELECT object_version_number
      FROM   hz_parties
      WHERE  party_id = p_branch_id;

  BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo('ENTER ' || l_module_name);

     END IF;
     SAVEPOINT set_ext_branch_end_date_pub;

     -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF FND_API.to_Boolean(p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
     END IF;

     --  Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- Start of API body

     -- Parameter validations
     check_mandatory('IBY_BNKBRN_ID_FIELD',p_branch_id);
     check_mandatory('IBY_END_DATE',p_end_date);

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo('Before Call to CE_BANK_PUB.set_bank_branch_end_date ');

     END IF;
     -- Fetch Object Verion Number for branch Party
     OPEN c_branch_party_ovn;
     FETCH c_branch_party_ovn INTO l_object_version_number;
     CLOSE c_branch_party_ovn;

     ce_bank_pub.set_bank_branch_end_date (
        NULL,
        p_branch_id,
        p_end_date,
        l_object_version_number,
        x_return_status,
        x_msg_count,
        x_msg_data
        );

     -- End of API body

     -- get message count and if count is 1, get message info.
     fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo('RETURN ' || l_module_name);
     END IF;
     EXCEPTION
     WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO set_ext_branch_end_date_pub;
      x_return_status := fnd_api.g_ret_sts_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Exception : ' || SQLERRM);
      END IF;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


     WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO set_ext_branch_end_date_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Exception : ' || SQLERRM);
      END IF;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


     WHEN OTHERS THEN
      ROLLBACK TO set_ext_branch_end_date_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Exception : ' || SQLERRM);

      END IF;
     FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);



  END set_ext_bank_branch_end_date;


  -- 8. check_ext_bank_branch_exist
  --
  --   API name        : check_ext_bank_branch_exist
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Checks if the bank branch exists; branch name/number
  --                     and bank id are used for identity
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE check_ext_bank_branch_exist (
   p_api_version                IN   NUMBER,
   p_init_msg_list              IN   VARCHAR2,
   p_bank_id                    IN   NUMBER,
   p_branch_name                IN   VARCHAR2,
   p_branch_number              IN   VARCHAR2,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,
   x_branch_id                  OUT NOCOPY NUMBER,
   x_end_date                   OUT NOCOPY DATE,
   x_response                   OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
  ) IS

   l_api_name           CONSTANT VARCHAR2(30)   := 'check_ext_bank_branch_exist';
   l_api_version        CONSTANT NUMBER         := 1.0;
   l_module_name        CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.' || l_api_name;

  BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo('ENTER ' || l_module_name);

     END IF;
     -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF FND_API.to_Boolean(p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
     END IF;

     --  Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- Start of API body

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo('Before Call to CE_BANK_PUB.check_branch_exist ');

     END IF;
     ce_bank_pub.check_branch_exist(
        p_bank_id,
        p_branch_name,
        p_branch_number,
        x_branch_id,
        x_end_date
        );

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo('Ext Bank Branch Id : ' || x_branch_id);

     END IF;
     -- End of API body

     -- get message count and if count is 1, get message info.
     fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo('RETURN ' || l_module_name);

     END IF;
     EXCEPTION
     WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Exception : ' || SQLERRM);
      END IF;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


     WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Exception : ' || SQLERRM);
      END IF;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


     WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Exception : ' || SQLERRM);
      END IF;
     FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


  END check_ext_bank_branch_exist;


  -- 9. create_ext_bank_acct
  --
  --   API name        : create_ext_bank_acct
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Creates an external bank account
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE create_ext_bank_acct (
   p_api_version                IN   NUMBER,
   p_init_msg_list            	IN   VARCHAR2,
   p_ext_bank_acct_rec          IN   ExtBankAcct_rec_type,
   x_acct_id			        OUT  NOCOPY NUMBER,
   x_return_status            	OUT  NOCOPY  VARCHAR2,
   x_msg_count                	OUT  NOCOPY  NUMBER,
   x_msg_data                 	OUT  NOCOPY  VARCHAR2,
   x_response                   OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
  ) IS

  l_api_name           CONSTANT VARCHAR2(30)   := 'create_ext_bank_acct';
  l_api_version        CONSTANT NUMBER         := 1.0;
  l_module_name        CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.' || l_api_name;

  l_iban	       VARCHAR2(50);
  l_country            VARCHAR2(60);
  l_bank_id            NUMBER(15)    := null;
  l_acct_rowid         VARCHAR2(100);
  l_bank_name          VARCHAR2(360) := null;
  l_bank_number        VARCHAR2(30)  := null;
  l_branch_number      VARCHAR2(30)  := null;
  l_account_number     VARCHAR2(100) := null;
  l_owner_id	       NUMBER(15);
  l_owner_rowid        VARCHAR2(100);
  l_count              NUMBER;
  l_joint_acct_owner_id NUMBER;

  lx_mask_option       iby_ext_bank_accounts.ba_mask_setting%TYPE;
  lx_unmask_len        iby_ext_bank_accounts.ba_unmask_length%TYPE;
  l_masked_ba_num      iby_ext_bank_accounts.masked_bank_account_num%TYPE;
  l_masked_iban        iby_ext_bank_accounts.masked_iban%TYPE;
  l_ba_num_hash1       iby_ext_bank_accounts.bank_account_num_hash1%TYPE;
  l_ba_num_hash2       iby_ext_bank_accounts.bank_account_num_hash1%TYPE;
  l_iban_hash1         iby_ext_bank_accounts.iban_hash1%TYPE;
  l_iban_hash2         iby_ext_bank_accounts.iban_hash2%TYPE;
  l_dup_acct_id        number;
  l_dup_start_date     date;
  l_dup_end_date       date;
  l_bank_account_num_electronic iby_ext_bank_accounts.bank_account_num_electronic%TYPE;
  l_party_id           ap_suppliers.party_id%TYPE;
  l_supplier_name      ap_suppliers.vendor_name%TYPE;
  l_supplier_number    ap_suppliers.segment1%TYPE;

  l_error_msg  VARCHAR2(500);
  l_ret_stat   VARCHAR2(1);
  l_org_id             iby_external_payees_all.org_id%TYPE;
  l_org_name           hr_operating_units.name%TYPE;
  -- picks up branch number
  CURSOR c_branch (p_branch_id NUMBER) IS
      SELECT bank_or_branch_number
      FROM   hz_organization_profiles
      WHERE  SYSDATE between TRUNC(effective_start_date)
             and NVL(TRUNC(effective_end_date), SYSDATE+1)
      AND    party_id = p_branch_id;

  CURSOR c_supplier(p_acct_id NUMBER) IS
     SELECT owners.account_owner_party_id
      FROM iby_pmt_instr_uses_all instrument,
           IBY_ACCOUNT_OWNERS owners,
           iby_external_payees_all payees
      WHERE
      owners.primary_flag = 'Y' AND
      owners.ext_bank_account_id = p_acct_id AND
      owners.ext_bank_account_id = instrument.instrument_id AND
      payees.ext_payee_id = instrument.ext_pmt_party_id AND
      payees.payee_party_id = owners.account_owner_party_id;



  BEGIN

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('ENTER ' || l_module_name);

    END IF;
    SAVEPOINT create_ext_bank_acct_pub;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Start of API

    -- Parameter validations
    --check_mandatory('Branch Id',p_ext_bank_acct_rec.branch_id);
    --check_mandatory('Bank Account Name',p_ext_bank_acct_rec.acct_name);
    check_mandatory('IBY_BANKACCT_NUM_FIELD',p_ext_bank_acct_rec.bank_account_num);

    -- Bug# 8470581
    -- Owner Party Id is no more mandatory as we allow
    -- the creation of orphan bank accounts
    --check_mandatory('Account Owner Party Id',p_ext_bank_acct_rec.acct_owner_party_id);

    --check_mandatory('Currency',p_ext_bank_acct_rec.currency);

    -- Other Validations
    -- 1. Country Specific Validations

    -- validate currency
    IF p_ext_bank_acct_rec.currency IS NOT NULL THEN
      CE_BANK_AND_ACCOUNT_VALIDATION.validate_currency(p_ext_bank_acct_rec.currency, x_return_status);
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Validated Currency');
      END IF;
    END IF;

    -- validate iban
    IF p_ext_bank_acct_rec.iban IS NOT NULL THEN
      CE_BANK_AND_ACCOUNT_VALIDATION.validate_IBAN(p_ext_bank_acct_rec.iban, l_iban, x_return_status);
         IF not x_return_status=fnd_api.g_ret_sts_success
	  THEN
              x_return_status := fnd_api.g_ret_sts_error;
              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	              print_debuginfo('IBAN Validation Failed ');
              END IF;
	      RAISE fnd_api.g_exc_error;
          ELSE
              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	              print_debuginfo('IBAN Validation Successful');
              END IF;
          END IF;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Validated IBAN Number');
      END IF;
    END IF;

    -- find bank info
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('The value for p_ext_bank_acct_rec.branch_id :' ||p_ext_bank_acct_rec.branch_id);
      END IF;
    IF p_ext_bank_acct_rec.branch_id IS NOT NULL THEN
      find_bank_info(p_ext_bank_acct_rec.branch_id, x_return_status, l_bank_id, l_country, l_bank_name, l_bank_number);
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Got Bank Info : '||l_bank_name);
	      print_debuginfo('Got Country   : '||l_country);

      END IF;
      -- find branch number
      OPEN c_branch(p_ext_bank_acct_rec.branch_id);
      FETCH c_branch INTO l_branch_number;
      IF c_branch%NOTFOUND THEN
        fnd_message.set_name('IBY', 'IBY_API_NO_BRANCH');
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
        RAISE fnd_api.g_exc_error;
      ELSE
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        print_debuginfo('Got Branch Number : '||l_branch_number);
        END IF;
      END IF;
      CLOSE c_branch;

    END IF;

    -- perform unique check for account

   -- calling our own check bank account exists


check_ext_acct_exist(
    p_api_version,
    p_init_msg_list,
    p_ext_bank_acct_rec,
    l_dup_acct_id,
    l_dup_start_date,
    l_dup_end_date,
    x_return_status,
    x_msg_count,
    x_msg_data,
    x_response
    );

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('Return status from check exist:'||x_return_status);
	 print_debuginfo('Duplicate account id:'||l_dup_acct_id);
 END IF;
    IF ((not x_return_status = fnd_api.g_ret_sts_success) OR
         (not l_dup_acct_id is null)) THEN
       fnd_message.set_name('IBY', 'IBY_UNIQ_ACCOUNT');
       fnd_msg_pub.add;
       /*OPEN c_supplier(l_dup_acct_id);
       FETCH c_supplier INTO l_party_id;
       IF l_party_id IS NOT NULL THEN
       SELECT vendor_name, segment1 INTO l_supplier_name, l_supplier_number FROM ap_suppliers WHERE party_id = l_party_id;
       fnd_message.set_name('IBY', 'IBY_UNIQ_ACCOUNT_SUPPLIER');
       fnd_message.set_Token('SUPPLIER',l_supplier_name);
       fnd_message.set_Token('SUPPLIERNUMBER',l_supplier_number);
       fnd_msg_pub.add;
       END IF;
       CLOSE c_supplier;*/
       l_org_id := find_assignment_OU(l_dup_acct_id);
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       print_debuginfo('l_org_id'||l_org_id);
       END IF;
       IF l_org_id <> -1 THEN
               select name into l_org_name from hr_operating_units where organization_id = l_org_id;
	       fnd_message.set_name('IBY', 'IBY_UNIQ_ACCOUNT_OU');
	       fnd_message.set_Token('OU', l_org_name);
               fnd_msg_pub.add;
       END IF;
       x_return_status := fnd_api.g_ret_sts_error;
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       print_debuginfo('Error : Duplicate Bank Account');
       END IF;
       RAISE fnd_api.g_exc_error;
    END IF;

    -- country specific validation API call here.
    -- delete the message as CE using message count for error
    fnd_msg_pub.delete_msg;
    x_msg_count:=0;

    /*
     * Fix for bug 5413958:
     *
     * The country code is necessary to correctly validate
     * the external bank account.
     *
     * If the user has provided us the branch id, the country code
     * of the branch can be used.
     *
     * If we do not have a country code (because the user has not
     * provided the branch id), then use the country code specified
     * on the account record. In the UI, it is mandatory to specify
     * the country of the account, so we will always have the
     * country code on the account record.
     */
    IF (l_country IS NULL) THEN

        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        print_debuginfo('Setting country code for bank account '
	            || 'from the account record since branch id was not '
	            || 'specified (country could not be derived from branch).'
	            );
        END IF;
        l_country := p_ext_bank_acct_rec.country_code;

    END IF;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('Country code used for bank account '
	        || 'validation: '
	        || l_country
	        );
    END IF;
-- removed call to CE_VALIDATE_CD which fails because bank_number, branch_number are not passed -bug 6660595
-- the call is deferred in update_ext_bank_acct() procedure
/*
    CE_VALIDATE_BANKINFO.CE_VALIDATE_CD (l_country,
					               p_ext_bank_acct_rec.check_digits,
					               l_bank_number,
					               l_branch_number,
					               p_ext_bank_acct_rec.bank_account_num,
					               FND_API.G_FALSE,
					               x_msg_count,
					               x_msg_data,
					               x_return_status,
					               'EXTERNAL');
*/


    CE_VALIDATE_BANKINFO.UPD_ACCOUNT_VALIDATE (l_country,
					                    l_bank_number,
					                    l_branch_number,
					                    p_ext_bank_acct_rec.bank_account_num,
				   	                    l_bank_id,
					                    p_ext_bank_acct_rec.branch_id,
                                                            null,    -- account_id
					                    p_ext_bank_acct_rec.currency,
					                    p_ext_bank_acct_rec.acct_type,
	 				                    p_ext_bank_acct_rec.acct_suffix,
					                    null,    -- p_secondary_acct_reference,
					                    p_ext_bank_acct_rec.bank_account_name,
					                    FND_API.G_FALSE,
					                    x_msg_count,
					                    x_msg_data,
					                    l_account_number,
					                    x_return_status,
					                    'EXTERNAL',
                                                            null, --xcd
                                                            l_bank_account_num_electronic);

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('Returned from Country Specific Account Validations');

    END IF;
  IF not x_return_status=fnd_api.g_ret_sts_success THEN
      x_return_status := fnd_api.g_ret_sts_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Account Validations Failed ');
      END IF;
      return;
   ELSE
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Account Validations Successful');
      END IF;
    END IF;

/* Bug - 9192335
 * Call Custom validations
 */
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Calling Custom Validations');
      END IF;
      IBY_ACCT_VAL_EXT_PUB.Validate_ext_bank_acct(p_ext_bank_acct_rec,l_ret_stat,l_error_msg);
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Return Status from Custom Validation::'||l_ret_stat);
	      print_debuginfo('Error Message from Custom Validation::'||l_error_msg);
      END IF;

  IF nvl(l_ret_stat,fnd_api.g_ret_sts_success) = fnd_api.g_ret_sts_error THEN
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Custom Validation Failed..');
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
       fnd_message.set_name('IBY', 'IBY_CUST_BANK_ACCT_VAL');
       fnd_message.set_Token('ERROR_MESSAGE',l_error_msg);
       fnd_msg_pub.add;
      RETURN;
  END IF;

    Get_Mask_Settings(lx_mask_option,lx_unmask_len);

    IF (NOT p_ext_bank_acct_rec.bank_account_num IS NULL) THEN
      l_masked_ba_num :=
        Mask_Bank_Number(p_ext_bank_acct_rec.bank_account_num,lx_mask_option,
                         lx_unmask_len);
      l_ba_num_hash1 := iby_security_pkg.Get_Hash
                       (p_ext_bank_acct_rec.bank_account_num,'F');
      l_ba_num_hash2 := iby_security_pkg.Get_Hash
                       (p_ext_bank_acct_rec.bank_account_num,'T');
    END IF;

    IF (NOT p_ext_bank_acct_rec.iban IS NULL) THEN
      l_masked_iban :=
        Mask_Bank_Number(p_ext_bank_acct_rec.iban,lx_mask_option,
                         lx_unmask_len);
      l_iban_hash1 := iby_security_pkg.Get_Hash(p_ext_bank_acct_rec.iban,'F');
      l_iban_hash2 := iby_security_pkg.Get_Hash(p_ext_bank_acct_rec.iban,'T');
    END IF;

    -- inserting the new account into IBY_EXT_BANK_ACCOUNTS
    INSERT INTO IBY_EXT_BANK_ACCOUNTS
    (
       EXT_BANK_ACCOUNT_ID,
       COUNTRY_CODE,
       BRANCH_ID,
       BANK_ID,
       BANK_ACCOUNT_NUM,
       BANK_ACCOUNT_NUM_HASH1,
       BANK_ACCOUNT_NUM_HASH2,
       MASKED_BANK_ACCOUNT_NUM,
       BA_MASK_SETTING,
       BA_UNMASK_LENGTH,
       CURRENCY_CODE,
       IBAN,
       IBAN_HASH1,
       IBAN_HASH2,
       MASKED_IBAN,
       CHECK_DIGITS,
       BANK_ACCOUNT_TYPE,
       ACCOUNT_CLASSIFICATION,
       ACCOUNT_SUFFIX,
       AGENCY_LOCATION_CODE,
--       MULTI_CURRENCY_ALLOWED_FLAG,
       PAYMENT_FACTOR_FLAG,
       FOREIGN_PAYMENT_USE_FLAG,
       EXCHANGE_RATE_AGREEMENT_NUM,
       EXCHANGE_RATE_AGREEMENT_TYPE,
       EXCHANGE_RATE,
       HEDGING_CONTRACT_REFERENCE,
--       STATUS,
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
       --REQUEST_ID,
       --PROGRAM_APPLICATION_ID,
       --PROGRAM_ID,
       --PROGRAM_UPDATE_DATE,
       START_DATE,
       END_DATE,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATE_LOGIN,
       OBJECT_VERSION_NUMBER,
       BANK_ACCOUNT_NAME,
       BANK_ACCOUNT_NAME_ALT,
       SHORT_ACCT_NAME,
       DESCRIPTION,
       ENCRYPTED,
       BANK_ACCOUNT_NUM_ELECTRONIC,
       SALT_VERSION,
       SECONDARY_ACCOUNT_REFERENCE,-- Bug 7408747
       CONTACT_NAME,
       CONTACT_PHONE,
       CONTACT_EMAIL,
       CONTACT_FAX
       )
       VALUES
       (
       IBY_EXT_BANK_ACCOUNTS_S.nextval, --EXT_BANK_ACCOUNT_ID,
       p_ext_bank_acct_rec.country_code, --COUNTRY_CODE,
       p_ext_bank_acct_rec.branch_id, --BRANCH_ID,
       p_ext_bank_acct_rec.bank_id, --BANK_ID,
       p_ext_bank_acct_rec.bank_account_num, --BANK_ACCOUNT_NUM,
       l_ba_num_hash1,
       l_ba_num_hash2,
       l_masked_ba_num,
       lx_mask_option,
       lx_unmask_len,
       p_ext_bank_acct_rec.currency, --CURRENCY_CODE,
       p_ext_bank_acct_rec.iban, --IBAN,
       l_iban_hash1,
       l_iban_hash2,
       l_masked_iban,
       p_ext_bank_acct_rec.check_digits, --CHECK_DIGITS,
       p_ext_bank_acct_rec.acct_type, --BANK_ACCOUNT_TYPE,
       'EXTERNAL', --ACCOUNT_CLASSIFICATION,
       p_ext_bank_acct_rec.acct_suffix, --ACCOUNT_SUFFIX,
       p_ext_bank_acct_rec.agency_location_code, --AGENCY_LOCATION_CODE,
--       p_ext_bank_acct_rec.multi_currency_allowed_flag, --MULTI_CURRENCY_ALLOWED_FLAG,
       p_ext_bank_acct_rec.payment_factor_flag, --PAYMENT_FACTOR_FLAG,
       p_ext_bank_acct_rec.foreign_payment_use_flag, --FOREIGN_PAYMENT_USE_FLAG,
       p_ext_bank_acct_rec.exchange_rate_agreement_num, --EXCHANGE_RATE_AGREEMENT_NUM,
       p_ext_bank_acct_rec.exchange_rate_agreement_type, --EXCHANGE_RATE_AGREEMENT_TYPE,
       p_ext_bank_acct_rec.exchange_rate, --EXCHANGE_RATE,
       p_ext_bank_acct_rec.hedging_contract_reference, --HEDGING_CONTRACT_REFERENCE,
  --     p_ext_bank_acct_rec.status, --STATUS,
       p_ext_bank_acct_rec.attribute_category, --ATTRIBUTE_CATEGORY,
       p_ext_bank_acct_rec.attribute1, --ATTRIBUTE1,
       p_ext_bank_acct_rec.attribute2, --ATTRIBUTE2,
       p_ext_bank_acct_rec.attribute3, --ATTRIBUTE3
       p_ext_bank_acct_rec.attribute4, --ATTRIBUTE4,
       p_ext_bank_acct_rec.attribute5, --ATTRIBUTE5,
       p_ext_bank_acct_rec.attribute6, --ATTRIBUTE6,
       p_ext_bank_acct_rec.attribute7, --ATTRIBUTE7,
       p_ext_bank_acct_rec.attribute8, --ATTRIBUTE8,
       p_ext_bank_acct_rec.attribute9, --ATTRIBUTE9,
       p_ext_bank_acct_rec.attribute10, --ATTRIBUTE10,
       p_ext_bank_acct_rec.attribute11, --ATTRIBUTE11,
       p_ext_bank_acct_rec.attribute12, --ATTRIBUTE12,
       p_ext_bank_acct_rec.attribute13, --ATTRIBUTE13,
       p_ext_bank_acct_rec.attribute14, --ATTRIBUTE14,
       p_ext_bank_acct_rec.attribute15, --ATTRIBUTE15,
       --REQUEST_ID,
       --PROGRAM_APPLICATION_ID,
       --PROGRAM_ID,
       --PROGRAM_UPDATE_DATE,
       trunc(NVL(p_ext_bank_acct_rec.start_date, sysdate)), --START_DATE,
       trunc(p_ext_bank_acct_rec.end_date), --END_DATE,
       fnd_global.user_id, --CREATED_BY,
       sysdate, --CREATION_DATE,
       fnd_global.user_id, --LAST_UPDATED_BY,
       sysdate, --LAST_UPDATE_DATE,
       fnd_global.login_id, --LAST_UPDATE_LOGIN,
       1.0, --OBJECT_VERSION_NUMBER,
    p_ext_bank_acct_rec.bank_account_name, --BANK_ACCOUNT_NAME
       p_ext_bank_acct_rec.alternate_acct_name, --BANK_ACCOUNT_NAME_ALT
       p_ext_bank_acct_rec.short_acct_name, --SHORT_ACCT_NAME
       p_ext_bank_acct_rec.description, --DESCRIPTION
      'N', -- encrypted
       l_bank_account_num_electronic,
       iby_security_pkg.get_salt_version,
       p_ext_bank_acct_rec.secondary_account_reference,     -- Bug 7408747
       p_ext_bank_acct_rec.contact_name,
       p_ext_bank_acct_rec.contact_phone,
       p_ext_bank_acct_rec.contact_email,
       p_ext_bank_acct_rec.contact_fax
       ) RETURNING EXT_BANK_ACCOUNT_ID INTO x_acct_id;

     IF (SQL%FOUND) THEN
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        print_debuginfo('New Row inserted in IBY_EXT_BANK_ACCOUNTS');
        END IF;
     ELSE
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        print_debuginfo('Failed to insert in IBY_EXT_BANK_ACCOUNTS');
        END IF;
        RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     -- End of API

     IF ((p_ext_bank_acct_rec.acct_owner_party_id IS NOT NULL) or
         (p_ext_bank_acct_rec.acct_owner_party_id <>-99)) THEN

        -- Populate the primary Account owner if the Account Owner
        -- Party id is populated
        add_joint_account_owner(1.0,
                                null,
                                x_acct_id,
                                p_ext_bank_acct_rec.acct_owner_party_id,
                                l_joint_acct_owner_id,
                                x_return_status,
                                x_msg_count,
                                x_msg_data,
                                x_response);

        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        print_debuginfo('Account Owner Id created : ' || l_joint_acct_owner_id);

        END IF;
       -- Set the newly created Account Owner as Primary
       IF (l_joint_acct_owner_id IS NOT NULL) THEN
          change_primary_acct_owner (1.0,
                                     null,
                                     x_acct_id,
                                     p_ext_bank_acct_rec.acct_owner_party_id,
                                     x_return_status,
                                     x_msg_count,
                                     x_msg_data,
                                     x_response);
       END IF;
    END IF;

    -- get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   print_debuginfo('RETURN ' || l_module_name);


   END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_ext_bank_acct_pub;
      x_return_status := fnd_api.g_ret_sts_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Exception : ' || SQLERRM);
      END IF;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_ext_bank_acct_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Exception : ' || SQLERRM);
      END IF;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


    WHEN OTHERS THEN
      ROLLBACK TO create_ext_bank_acct_pub;

      x_return_status := fnd_api.g_ret_sts_unexp_error;
     FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Exception : ' || SQLERRM);
      END IF;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

  END create_ext_bank_acct;


--- Updated for the bug 6461487
/* Over loaded procedure for using through API.
   This procedure is used to create the external bank account and
   assign the bank account at
            a. Supplier
	    b. Supplier Site
	    c. Address
	    d. Address Operating Unit  */
  PROCEDURE create_ext_bank_acct (
   p_api_version                IN   NUMBER,
   p_init_msg_list              IN   VARCHAR2,
   p_ext_bank_acct_rec          IN   ExtBankAcct_rec_type,
   p_association_level          IN   VARCHAR2,
   p_supplier_site_id           IN   NUMBER,
   p_party_site_id              IN   NUMBER,
   p_org_id                     IN   NUMBER,
   p_org_type			IN   VARCHAR2 default NULL,     --Bug7136876: new parameter
   x_acct_id                    OUT  NOCOPY NUMBER,
   x_return_status              OUT  NOCOPY  VARCHAR2,
   x_msg_count                  OUT  NOCOPY  NUMBER,
   x_msg_data                   OUT  NOCOPY  VARCHAR2,
   x_response                   OUT  NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
  ) IS
   l_module       CONSTANT  VARCHAR2(40) := 'overloaded create_ext_bank_acct';
   l_insert_status     BOOLEAN;
   l_assign_id         NUMBER;
   l_rec      IBY_DISBURSEMENT_SETUP_PUB.PayeeContext_rec_type;
   l_assign   IBY_FNDCPT_SETUP_PUB.PmtInstrAssignment_rec_type;
   l_payment_function  CONSTANT VARCHAR2(30)   :=  'PAYABLES_DISB';
   l_instrument_type   CONSTANT VARCHAR2(30)   :=  'BANKACCOUNT';
   l_party_site_id     NUMBER;
   l_supp_site_id      NUMBER;
   l_org_id            NUMBER;
   l_org_type          VARCHAR2(30);
   l_party_site_status VARCHAR2(1);
   L_INVALID_SUPPLIER_ID EXCEPTION;
   L_INVALID_PARTY_SITE  EXCEPTION;
   L_INVALID_AO          EXCEPTION;
   L_INVALID_ASSOCIATION_LEVEL          EXCEPTION;
   l_association_level  VARCHAR2(2) := Upper(p_association_level);

   /* ADDED for Bug - 8209536 */
  l_country            VARCHAR2(60);
  l_bank_id            NUMBER(15)    := null;
  l_bank_name          VARCHAR2(360) := null;
  l_bank_number        VARCHAR2(30)  := null;
  l_branch_number      VARCHAR2(30)  := null;

   -- picks up branch number
  CURSOR c_branch (p_branch_id NUMBER) IS
      SELECT bank_or_branch_number
      FROM   hz_organization_profiles
      WHERE  SYSDATE between TRUNC(effective_start_date)
             and NVL(TRUNC(effective_end_date), SYSDATE+1)
      AND    party_id = p_branch_id;

BEGIN
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('Enter '||l_module);
    END IF;
     SAVEPOINT  create_ext_bank_acct_thru_api;
     IF(l_association_level <> 'S' AND
        l_association_level <> 'SS' AND
        l_association_level <> 'A' AND
        l_association_level <> 'AO') THEN
          RAISE L_INVALID_ASSOCIATION_LEVEL;
      END IF;

      /* Bug 8209536
       * Country specific validation is inconsistent for UI and API
       *
       */

        -- find bank info
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('The value for p_ext_bank_acct_rec.branch_id :' ||p_ext_bank_acct_rec.branch_id);
      END IF;
    IF p_ext_bank_acct_rec.branch_id IS NOT NULL THEN
      find_bank_info(p_ext_bank_acct_rec.branch_id, x_return_status, l_bank_id, l_country, l_bank_name, l_bank_number);
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Got Bank Info : '||l_bank_name);
	      print_debuginfo('Got Country   : '||l_country);

      END IF;
      -- find branch number
      OPEN c_branch(p_ext_bank_acct_rec.branch_id);
      FETCH c_branch INTO l_branch_number;
      IF c_branch%NOTFOUND THEN
        fnd_message.set_name('IBY', 'IBY_API_NO_BRANCH');
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
        RAISE fnd_api.g_exc_error;
      ELSE
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        print_debuginfo('Got Branch Number : '||l_branch_number);
        END IF;
      END IF;
      CLOSE c_branch;

    END IF;


    CE_VALIDATE_BANKINFO.CE_VALIDATE_CD (l_country,
					          p_ext_bank_acct_rec.check_digits,
					          l_bank_number,
					          l_branch_number,
					          p_ext_bank_acct_rec.bank_account_num,
					          FND_API.G_FALSE,
					          x_msg_count,
					          x_msg_data,
					          x_return_status,
					          'EXTERNAL');
    IF(x_return_status<>fnd_api.g_ret_sts_success)
    THEN
              x_return_status := fnd_api.g_ret_sts_error;
             IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	             print_debuginfo('Account Validations Failed ');
             END IF;
             return;

    END IF;

/* Creating a new bank account*/

create_ext_bank_acct(p_api_version,
                     p_init_msg_list,
                     p_ext_bank_acct_rec,
                     x_acct_id,
                     x_return_status,
                     x_msg_count,
                     x_msg_data,
                     x_response);
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo('Return Status after creating the bank account'||x_return_status);
	     print_debuginfo('Account Id created'||x_acct_id);


     END IF;
IF(l_association_level='SS')THEN
      IF(p_supplier_site_id IS NOT NULL) THEN
        BEGIN
          --select party_site_id, org_id, org_type
         -- INTO l_party_site_id, l_org_id, l_org_type
         -- from iby_external_payees_all
          --where payee_party_id=p_ext_bank_acct_rec.acct_owner_party_id AND
          --      PAYMENT_FUNCTION='PAYABLES_DISB' AND
          --      SUPPLIER_SITE_ID =p_supplier_site_id;
	    select org_id, vendor_site_id
	    INTO   l_org_id, l_supp_site_id
	    from   ap_supplier_sites_all
	    where  vendor_site_id = p_supplier_site_id AND
	                  org_id  = p_org_id;
          EXCEPTION
            WHEN OTHERS THEN
             RAISE L_INVALID_SUPPLIER_ID;
         END;
          IF(p_party_site_id IS NOT NULL) THEN
                SELECT status
                INTO l_party_site_status
                FROM HZ_PARTY_SITES
                WHERE party_site_id = p_party_site_id;

                IF l_party_site_status = 'I' THEN
                  RAISE  L_INVALID_PARTY_SITE;
                END IF;
          END IF;
          l_rec.Party_Site_id :=p_party_site_id;
          l_rec.Supplier_Site_id:=p_supplier_site_id;
          l_rec.Org_Id:=l_org_id;
          l_rec.Org_Type:=p_org_type;
     ELSE
          RAISE L_INVALID_SUPPLIER_ID;
     END IF;
  ELSIF(l_association_level='A') THEN
      IF(p_party_site_id IS NOT NULL) THEN
          l_rec.Party_Site_id :=p_party_site_id;
          l_rec.Supplier_Site_id:=NULL;
          l_rec.Org_Id:=NULL;
          l_rec.Org_Type:=NULL;
          BEGIN
              SELECT status
              INTO l_party_site_status
              FROM HZ_PARTY_SITES
              WHERE party_site_id = p_party_site_id;
              EXCEPTION
              WHEN OTHERS THEN
                  RAISE  L_INVALID_PARTY_SITE;
          END;
          IF l_party_site_status = 'I' THEN
             RAISE  L_INVALID_PARTY_SITE;
          END IF;
      ELSE
         RAISE  L_INVALID_PARTY_SITE;
      END IF;
  ELSIF(l_association_level='AO') THEN
      IF(p_party_site_id IS NOT NULL AND p_org_id IS NOT NULL) THEN
        /*BEGIN
          select org_type
          INTO  l_org_type
          from iby_external_payees_all
          where payee_party_id=p_ext_bank_acct_rec.acct_owner_party_id AND
                PAYMENT_FUNCTION='PAYABLES_DISB' AND
                PARTY_SITE_ID =p_party_site_id AND
                ORG_ID = p_org_id AND
                SUPPLIER_SITE_ID IS NOT NULL;
          EXCEPTION
            WHEN OTHERS THEN
             RAISE L_INVALID_AO;
         END;
	 */
 	 print_debuginfo('Party site id, org id is not null ');
       ELSE
           RAISE L_INVALID_AO;
      END IF;
      l_rec.Party_Site_id :=p_party_site_id;
      l_rec.Org_Id:= p_org_id;
      l_rec.Org_Type:= p_org_type;
      l_rec.Supplier_Site_id:=NULL;
  ELSIF(l_association_level='S')  THEN
      l_rec.Party_Site_id :=NULL;
      l_rec.Org_Id:= NULL;
      l_rec.Org_Type:= NULL;
      l_rec.Supplier_Site_id:=NULL;
  END IF;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('orgid :'||l_rec.Org_Id);
	      print_debuginfo('org type :'||l_rec.Org_Type);
	      print_debuginfo('party_site_id :'||l_rec.Party_Site_id);
	      print_debuginfo('Supplier_site_id :'||l_rec.Supplier_Site_id);


      END IF;
      l_rec.Payment_Function :=l_payment_function;
      l_rec.Party_Id :=p_ext_bank_acct_rec.acct_owner_party_id;
      l_assign.Instrument.Instrument_Type := l_instrument_type;
      l_assign.Instrument.Instrument_Id := x_acct_id;
      IBY_DISBURSEMENT_SETUP_PUB.Set_Payee_Instr_Assignment(
                   p_api_version,
                   NULL,
                   NULL,
                   x_return_status,
                   x_msg_count,
                   x_msg_data,
                   l_rec,
                   l_assign,
                   l_assign_id,
                   x_response);

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   print_debuginfo('Exit '||l_module);
   END IF;
   EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO  create_ext_bank_acct_thru_api;
        x_return_status := fnd_api.g_ret_sts_error;
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        print_debuginfo('Exception : ' || SQLERRM);
        END IF;
        fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO  create_ext_bank_acct_thru_api;
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        print_debuginfo('Exception : ' || SQLERRM);
        END IF;
        fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                 p_count => x_msg_count,
                                 p_data  => x_msg_data);
      WHEN L_INVALID_SUPPLIER_ID THEN
        ROLLBACK TO  create_ext_bank_acct_thru_api;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        print_debuginfo('Exception : invalid supplier id');
        END IF;
        fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);
      WHEN L_INVALID_PARTY_SITE THEN
        ROLLBACK TO  create_ext_bank_acct_thru_api;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        print_debuginfo('Exception : invalid party site id');
        END IF;
        fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);
      WHEN L_INVALID_AO THEN
         ROLLBACK TO  create_ext_bank_acct_thru_api;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        print_debuginfo('Exception : invalid combination of party site id and org id');
        END IF;
        fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);
      WHEN L_INVALID_ASSOCIATION_LEVEL THEN
         ROLLBACK TO  create_ext_bank_acct_thru_api;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        print_debuginfo('Exception : invalid Association level');
        END IF;
        fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);
      WHEN OTHERS THEN
        ROLLBACK TO  create_ext_bank_acct_thru_api;
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module, null);
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        print_debuginfo('Exception : ' || SQLERRM);
        END IF;
        fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);

END create_ext_bank_acct;


  -- 10. update_ext_bank_acct
  --
  --   API name        : update_ext_bank_acct
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Updates an external bank account
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE update_ext_bank_acct (
   p_api_version               IN  NUMBER,
   p_init_msg_list             IN  VARCHAR2,
   p_ext_bank_acct_rec         IN  OUT NOCOPY ExtBankAcct_rec_type,
   x_return_status                 OUT  NOCOPY VARCHAR2,
   x_msg_count                     OUT  NOCOPY NUMBER,
   x_msg_data                      OUT  NOCOPY VARCHAR2,
   x_response                      OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
  ) IS

  l_api_name           CONSTANT VARCHAR2(30)   := 'update_ext_bank_acct';
  l_api_version        CONSTANT NUMBER         := 1.0;
  l_module_name        CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.' || l_api_name;

  l_country            VARCHAR2(60);
  l_old_ovn            NUMBER(15);
  l_count              NUMBER;
  l_bank_number        VARCHAR2(30);
  l_bank_id            NUMBER(15);
  l_branch_id          NUMBER(15);
  l_bank_name          VARCHAR2(360);
  l_branch_number      VARCHAR2(30);
  l_acct_number        iby_ext_bank_accounts.bank_account_num%TYPE;
  l_mask_option        iby_ext_bank_accounts.ba_mask_setting%TYPE;
  l_unmask_len         iby_ext_bank_accounts.ba_unmask_length%TYPE;
  l_masked_ba_num      iby_ext_bank_accounts.masked_bank_account_num%TYPE;
  l_masked_iban        iby_ext_bank_accounts.masked_iban%TYPE;
  l_ba_num_hash1       iby_ext_bank_accounts.bank_account_num_hash1%TYPE;
  l_ba_num_hash2       iby_ext_bank_accounts.bank_account_num_hash1%TYPE;
  l_iban_hash1         iby_ext_bank_accounts.iban_hash1%TYPE;
  l_iban_hash2         iby_ext_bank_accounts.iban_hash2%TYPE;
  l_iban               iby_ext_bank_accounts.iban%TYPE;
  l_encrypted          iby_ext_bank_accounts.encrypted%TYPE;
  l_ba_segment_id      iby_ext_bank_accounts.ba_num_sec_segment_id%TYPE;
  l_iban_segment_id    iby_ext_bank_accounts.iban_sec_segment_id%TYPE;
  l_bank_account_num_electronic iby_ext_bank_accounts.bank_account_num_electronic%TYPE;
  l_old_iban           iby_ext_bank_accounts.iban%TYPE;
  l_old_masked_iban    iby_ext_bank_accounts.masked_iban%TYPE;
  l_old_iban_hash1     iby_ext_bank_accounts.iban_hash1%TYPE;
  l_old_iban_hash2     iby_ext_bank_accounts.iban_hash2%TYPE;
  l_dup_acct_id        number;
  l_dup_start_date     date;
  l_dup_end_date       date;
  l_party_id           ap_suppliers.party_id%TYPE;
  l_supplier_name      ap_suppliers.vendor_name%TYPE;
  l_supplier_number    ap_suppliers.segment1%TYPE;

  l_error_msg  VARCHAR2(500);
  l_ret_stat   VARCHAR2(1);
  l_org_id             iby_external_payees_all.org_id%TYPE;
  l_org_name           hr_operating_units.name%TYPE;
  -- Get Object Version Number
   CURSOR c_ovn (p_acct_id NUMBER) IS
      SELECT object_version_number,
             bank_account_num_hash1,
             bank_account_num_hash2,
             iban_hash1,
             iban_hash2,
             ba_mask_setting,
             ba_unmask_length,
             ba_num_sec_segment_id,
             iban_sec_segment_id,
             encrypted,
             iban,
             masked_iban
      FROM   IBY_EXT_BANK_ACCOUNTS
      WHERE  EXT_BANK_ACCOUNT_ID = p_acct_id;

   -- checks if account already exists
   -- a duplicate bank account is one with the same account_number and
   -- and currency for the same bank and branch.
   -- checks if account already exists


  CURSOR uniq_check (p_account_num_hash1 VARCHAR2,
                     p_account_num_hash2 VARCHAR2,
                     p_currency VARCHAR2,
                     p_bank_id NUMBER,
                     p_branch_id NUMBER,
                     p_bank_acct_id NUMBER) IS
      SELECT count(*)
        FROM IBY_EXT_BANK_ACCOUNTS_V
       WHERE
         (bank_acct_num_hash1 = p_account_num_hash1)
         AND (bank_acct_num_hash2 = p_account_num_hash2)
   --      AND (p_currency IS NULL OR CURRENCY_CODE = p_currency)
         AND (p_bank_id IS NULL and BANK_PARTY_ID is NULL) OR (BANK_PARTY_ID = p_bank_id)
         AND (p_branch_id IS NULL and BRANCH_PARTY_ID is NULL)  OR (BRANCH_PARTY_ID = p_branch_id)
         AND EXT_BANK_ACCOUNT_ID<>p_bank_acct_id;

    -- get bank and branch numbers
    CURSOR c_bank_branch (p_bank_id NUMBER, p_branch_id NUMBER)IS
       SELECT BANK_NUMBER, BRANCH_NUMBER
         FROM CE_BANK_BRANCHES_V
        WHERE BANK_PARTY_ID   = p_bank_id
          AND BRANCH_PARTY_ID = p_branch_id;

      CURSOR c_supplier(p_acct_id NUMBER) IS
     SELECT owners.account_owner_party_id
      FROM iby_pmt_instr_uses_all instrument,
           IBY_ACCOUNT_OWNERS owners,
           iby_external_payees_all payees
      WHERE
      owners.primary_flag = 'Y' AND
      owners.ext_bank_account_id = p_acct_id AND
      owners.ext_bank_account_id = instrument.instrument_id AND
      payees.ext_payee_id = instrument.ext_pmt_party_id AND
      payees.payee_party_id = owners.account_owner_party_id;


  BEGIN

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('ENTER ' || l_module_name);
	    print_debuginfo('DEBUG- The value of account number :' || p_ext_bank_acct_rec.bank_account_num);

    END IF;
    SAVEPOINT update_ext_bank_acct_pub;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Start of API Body

    -- Parameter validations
    check_mandatory('IBY_BANKACCT_ID_FIELD', p_ext_bank_acct_rec.bank_account_id);
-- no need to check the bank account number for update case
--    check_mandatory('Bank Account Number', p_ext_bank_acct_rec.bank_account_num);
    --check_mandatory('Currency', p_ext_bank_acct_rec.currency);
    check_mandatory('IBY_OBJ_VER_NUM', p_ext_bank_acct_rec.object_version_number);

     -- check object version number to make sure the record has not been updated
    OPEN c_ovn(p_ext_bank_acct_rec.bank_account_id);
    FETCH c_ovn INTO l_old_ovn,
                     l_ba_num_hash1,
                     l_ba_num_hash2,
                     l_old_iban_hash1,
                     l_old_iban_hash2,
                     l_mask_option,
                     l_unmask_len,
                     l_ba_segment_id,
                     l_iban_segment_id,
                     l_encrypted,
                     l_old_iban,
                     l_old_masked_iban;
    IF c_ovn%NOTFOUND THEN
      fnd_message.set_name('IBY', 'IBY_API_NO_EXT_BANK_ACCT');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
      CLOSE c_ovn;
      RAISE fnd_api.g_exc_error;
    END IF;
    CLOSE c_ovn;
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('Current object_version_number Version Number ' || l_old_ovn);

    END IF;
    IF l_old_ovn <> p_ext_bank_acct_rec.object_version_number THEN
      fnd_message.set_name('IBY', 'IBY_DATA_VERSION_ERROR');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Error: Object Version Number Mismatch');
      END IF;
      RAISE fnd_api.g_exc_error;
    END IF;
    -- no need for unique check
    -- perform unique check for account
    -- passing in the ext bank account id to the query for unique check
/*

    OPEN uniq_check(p_ext_bank_acct_rec.bank_account_num,
                    p_ext_bank_acct_rec.currency,
                    p_ext_bank_acct_rec.bank_id,
                    p_ext_bank_acct_rec.branch_id,
                    p_ext_bank_acct_rec.bank_account_id);
    FETCH uniq_check into l_count;
    IF (l_count > 1) THEN
       fnd_message.set_name('IBY', 'IBY_UNIQ_ACCOUNT');
       fnd_msg_pub.add;
       x_return_status := fnd_api.g_ret_sts_error;
       RAISE fnd_api.g_exc_error;
    END IF;
    CLOSE uniq_check;



    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('Return status from check exist:'||x_return_status);
	 print_debuginfo('Duplicate account id:'||l_dup_acct_id);
 END IF;
    IF ((not x_return_status = fnd_api.g_ret_sts_success) OR
         (not l_dup_acct_id is null)) THEN
       fnd_message.set_name('IBY', 'IBY_UNIQ_ACCOUNT');
       fnd_msg_pub.add;
       x_return_status := fnd_api.g_ret_sts_error;
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       print_debuginfo('Error : Duplicate Bank Account');
       END IF;
       RAISE fnd_api.g_exc_error;
    END IF;

*/

   --  get branch id
   --  Bug 5739075 : l_bank_number and l_branch_number were not populated
   --                resulting into CE API failure

       OPEN c_bank_branch (p_ext_bank_acct_rec.bank_id,
                           p_ext_bank_acct_rec.branch_id);
       FETCH c_bank_branch INTO l_bank_number, l_branch_number;
       CLOSE c_bank_branch;


     -- country specific validation API call here.
    l_country:=p_ext_bank_acct_rec.country_code;

  -- handle the case user doesn't change bank account number

    l_acct_number :=  p_ext_bank_acct_rec.bank_account_num;

begin

    if (NOT l_acct_number IS NULL) then
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('The value of Get_Hash(l_acct_number,F): '||
	iby_security_pkg.Get_Hash(l_acct_number,'F'));
	      print_debuginfo('The value of Get_Hash(l_acct_number,T): '||
	iby_security_pkg.Get_Hash(l_acct_number,'T'));
	      print_debuginfo('The value of l_ba_num_hash1: ' ||l_ba_num_hash1);
	      print_debuginfo('The value of l_ba_num_hash1: '|| l_ba_num_hash2);

      END IF;
      if ( (iby_security_pkg.Get_Hash(l_acct_number,'F') = l_ba_num_hash1)
           AND (iby_security_pkg.Get_Hash(l_acct_number,'T') = l_ba_num_hash2)
         )
      then
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        print_debuginfo('User doesnt change the bank account number');
        END IF;
        l_acct_number:=null;
        l_ba_num_hash1:=null;
        l_ba_num_hash2:=null;
        l_masked_ba_num:=null;
      else
        l_ba_num_hash1 := iby_security_pkg.Get_Hash(l_acct_number,'F');

        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        print_debuginfo('User has changed the bank account number');
	        print_debuginfo('The value of l_masked_ba_num before masking:'||
	l_masked_ba_num);
        END IF;
        l_ba_num_hash2 := iby_security_pkg.Get_Hash(l_acct_number,'T');
        l_masked_ba_num :=
          Mask_Bank_Number(l_acct_number,l_mask_option,l_unmask_len);
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        print_debuginfo('The value of l_masked_ba_num after masking:'||
	l_masked_ba_num);
        END IF;
        l_encrypted := 'N';
        DELETE FROM iby_security_segments
        WHERE sec_segment_id = l_ba_segment_id;
      end if;
    end if;
exception
   when others then
 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	 print_debuginfo('Unknown exception in bank account number compare');
 END IF;
    -- the bank account number is not provided by the user
   l_acct_number :=null;

end;
/* Bug - 6935905
   The function validate_IBAN is returning the null value always for
   l_iban. Hence as we have that value, checking for return status
   and taking the existing value(p_ext_bank_acct_rec.iban).

   logic for updating the iban is not handled for the case of changing
   the existing iban to null value. Hence got iban values and changed
   the logic.
*/
/*
     l_iban :=p_ext_bank_acct_rec.iban;
begin
  if (NOT l_iban IS NULL) then
      if ( (iby_security_pkg.Get_Hash(l_iban,'F') = l_iban_hash1)
           AND (iby_security_pkg.Get_Hash(l_iban,'T') = l_iban_hash2)
         )
      then
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        print_debuginfo('User doesnt change the IBAN');
        END IF;
        l_iban:=null;
        l_iban_hash1:=null;
        l_iban_hash2:=null;
        l_masked_iban:=null;
      else
        CE_BANK_AND_ACCOUNT_VALIDATION.validate_IBAN
        (p_ext_bank_acct_rec.iban, l_iban, x_return_status);
        -- throw exception???
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        print_debuginfo('Validated IBAN Number');

        END IF;
        l_iban_hash1 := iby_security_pkg.Get_Hash(l_iban,'F');
        l_iban_hash2 := iby_security_pkg.Get_Hash(l_iban,'T');
        l_masked_iban := Mask_Bank_Number(l_iban,l_mask_option,l_unmask_len);

        l_encrypted := 'N';
        DELETE FROM iby_security_segments
        WHERE sec_segment_id = l_iban_segment_id;
      end if;
  end if;
exception
   when others then

    -- the bank account number is not provided by the user
IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	print_debuginfo('Unknown exception in iban compare');
END IF;
   l_iban :=null;

end;
*/

     l_iban :=p_ext_bank_acct_rec.iban;
begin
  if (Nvl(l_old_iban,'null')<> Nvl(l_iban,'null')) then
        IF(NOT l_iban IS NULL) THEN
            CE_BANK_AND_ACCOUNT_VALIDATION.validate_IBAN
            (p_ext_bank_acct_rec.iban, l_iban, x_return_status);
            -- throw exception???
            IF  x_return_status=fnd_api.g_ret_sts_success THEN
              l_iban :=p_ext_bank_acct_rec.iban;
	    ELSE
		      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			 print_debuginfo('IBAN Validation Failed ');
		      END IF;
		      RAISE fnd_api.g_exc_error;
            END IF;
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	            print_debuginfo('Validated IBAN Number');
	            print_debuginfo(x_return_status);
	            print_debuginfo(l_iban);
            END IF;
            l_iban_hash1 := iby_security_pkg.Get_Hash(l_iban,'F');
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	            print_debuginfo(l_iban_hash1);
            END IF;
            l_iban_hash2 := iby_security_pkg.Get_Hash(l_iban,'T');
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	            print_debuginfo(l_iban_hash2);
            END IF;
            l_masked_iban := Mask_Bank_Number(l_iban,l_mask_option,l_unmask_len);
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	            print_debuginfo(l_masked_iban);
            END IF;
        ELSE
             l_iban_hash1 :=NULL;
             l_iban_hash2 :=NULL;
             l_masked_iban :=NULL;
        END IF;

        l_encrypted := 'N';
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        print_debuginfo('before delete');
        END IF;
        DELETE FROM iby_security_segments
        WHERE sec_segment_id = l_iban_segment_id;
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        print_debuginfo('After delete');

        END IF;
  ELSE
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	            print_debuginfo('User doesnt change the IBAN');
            END IF;
            l_iban:=l_old_iban;
            l_iban_hash1:=l_old_iban_hash1;
            l_iban_hash2:=l_old_iban_hash2;
            l_masked_iban:=l_old_masked_iban;
  end if;
exception
   when fnd_api.g_exc_error then
	IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
		print_debuginfo('Exception in iban compare');
	END IF;
        Raise fnd_api.g_exc_error;
   when others then

    -- the bank account number is not provided by the user
IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	print_debuginfo('Unknown exception in iban compare');
END IF;
   l_iban :=l_old_iban;

end;



-- calling our own check bank account exists

check_ext_acct_exist(
    p_api_version,
    p_init_msg_list,
    p_ext_bank_acct_rec,
    l_dup_acct_id,
    l_dup_start_date,
    l_dup_end_date,
    x_return_status,
    x_msg_count,
    x_msg_data,
    x_response
    );

 IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	 print_debuginfo('Return status from check exist:'||x_return_status);
	 print_debuginfo('Duplicate account id:'||l_dup_acct_id);
 END IF;
    IF ((not x_return_status = fnd_api.g_ret_sts_success) OR
         (not l_dup_acct_id is null)) THEN
       fnd_message.set_name('IBY', 'IBY_UNIQ_ACCOUNT');
       fnd_msg_pub.add;
       /*OPEN c_supplier(l_dup_acct_id);
       FETCH c_supplier INTO l_party_id;
       IF l_party_id IS NOT NULL THEN
       SELECT vendor_name, segment1 INTO l_supplier_name, l_supplier_number FROM ap_suppliers WHERE party_id = l_party_id;
       fnd_message.set_name('IBY', 'IBY_UNIQ_ACCOUNT_SUPPLIER');
       fnd_message.set_Token('SUPPLIER',l_supplier_name);
       fnd_message.set_Token('SUPPLIERNUMBER',l_supplier_number);
       fnd_msg_pub.add;
       END IF;
       CLOSE c_supplier;*/
       l_org_id := find_assignment_OU(l_dup_acct_id);
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       print_debuginfo('l_org_id::'||l_org_id);
       END IF;
       IF l_org_id <> -1 THEN
               select name into l_org_name from hr_operating_units where organization_id = l_org_id;
	       fnd_message.set_name('IBY', 'IBY_UNIQ_ACCOUNT_OU');
	       fnd_message.set_Token('OU',l_org_name);
               fnd_msg_pub.add;
       END IF;
       x_return_status := fnd_api.g_ret_sts_error;
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       print_debuginfo('Error : Duplicate Bank Account');
       END IF;
       RAISE fnd_api.g_exc_error;
    END IF;

    -- country specific validation API call here.
    -- delete the message as CE using message count for error
    fnd_msg_pub.delete_msg;
    x_msg_count:=0;


--Get_Mask_Settings(lx_mask_option,lx_unmask_len);



    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('DEBUG-l_country : ' || l_country);
	    print_debuginfo('DEBUG-l_bank_number : ' || l_bank_number);
	    print_debuginfo('DEBUG-l_branch_number : ' || l_branch_number);

	    print_debuginfo('DEBUG-p_ext_bank_acct_rec.check_digits : ' || p_ext_bank_acct_rec.check_digits);
	    print_debuginfo('DEBUG- The value of l_masked_ba_num:'||l_masked_ba_num);
	    print_debuginfo('DEBUG- The value of account number passed to CE''s API:' || p_ext_bank_acct_rec.bank_account_num);

    END IF;
    -- removed check for bank_id and branch_id being not null - bug5486957 [taken back in bug 5739075 ]
    CE_VALIDATE_BANKINFO.CE_VALIDATE_CD (l_country,
					               p_ext_bank_acct_rec.check_digits,
					               l_bank_number,
					               l_branch_number,
					               p_ext_bank_acct_rec.bank_account_num,
					               FND_API.G_FALSE,
					               x_msg_count,
					               x_msg_data,
					               x_return_status,
					               'EXTERNAL');

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('Returned from Country Specific Check Digit Validations status:' || x_return_status);
	    print_debuginfo('After Country Specific validations, l_masked_ba_num:'||
	l_masked_ba_num);
    END IF;
   IF not x_return_status=fnd_api.g_ret_sts_success THEN

      x_return_status := fnd_api.g_ret_sts_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Account Validations Failed ');
      END IF;
      return;
   ELSE
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Account Validations Successful');
      END IF;
    END IF;


    CE_VALIDATE_BANKINFO.UPD_ACCOUNT_VALIDATE (              l_country,
					                    l_bank_number,
					                    l_branch_number,
					                    p_ext_bank_acct_rec.bank_account_num,
				   	                    l_bank_id,
					                    l_branch_id,
                                        null,    -- account_id
					                    p_ext_bank_acct_rec.currency,
					                    p_ext_bank_acct_rec.acct_type,
	 				                    p_ext_bank_acct_rec.acct_suffix,
					                    null,    -- p_secondary_acct_reference,
					                    p_ext_bank_acct_rec.bank_account_name,
					                    FND_API.G_FALSE,
					                    x_msg_count,
					                    x_msg_data,
					                    l_acct_number,
					                    x_return_status,
					                    'EXTERNAL',
                                                            null, --xcd
                                                            l_bank_account_num_electronic);

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('Returned from Account Validations' || x_return_status);
	    print_debuginfo('After CE s UPD_ACCOUNT_VALIDATE'||
	'l_masked_ba_num:'||l_masked_ba_num);
    END IF;
     IF not x_return_status=fnd_api.g_ret_sts_success THEN
      x_return_status := fnd_api.g_ret_sts_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Account Validations Failed ');
      END IF;
      return;
   ELSE
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Account Validations Successful');
      END IF;
    END IF;

  /* Bug :8244523
   *  Negative bank id and branch Id's are getting updated to the table
   *  iby_ext_bank_accounts.
   *  Nulling out the bank Id and branch Id if they are negative.
   */
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   print_debuginfo('BankID::'||p_ext_bank_acct_rec.bank_id);
	   print_debuginfo('BranchID::'||p_ext_bank_acct_rec.branch_id);
   END IF;
  if(p_ext_bank_acct_rec.bank_id <0) then
     p_ext_bank_acct_rec.bank_id := null;
  end if;
  if(p_ext_bank_acct_rec.branch_id <0) then
     p_ext_bank_acct_rec.branch_id := null;
  end if;


/* Bug - 9192335
 * Call Custom validations
 */
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Calling Custom Validations');
      END IF;
      IBY_ACCT_VAL_EXT_PUB.Validate_ext_bank_acct(p_ext_bank_acct_rec,l_ret_stat,l_error_msg);
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Return Status from Custom Validation::'||l_ret_stat);
	      print_debuginfo('Error Message from Custom Validation::'||l_error_msg);
      END IF;

  IF nvl(l_ret_stat,fnd_api.g_ret_sts_success) = fnd_api.g_ret_sts_error THEN
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Custom Validation Failed..');
      END IF;
      x_return_status := fnd_api.g_ret_sts_error;
       fnd_message.set_name('IBY', 'IBY_CUST_BANK_ACCT_VAL');
       fnd_message.set_Token('ERROR_MESSAGE',l_error_msg);
       fnd_msg_pub.add;
      RETURN;
  END IF;


   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   print_debuginfo('Before Update: using bank account');

   END IF;
        -- Update Table IBY_EXT_BANK_ACCOUNTS
    UPDATE IBY_EXT_BANK_ACCOUNTS
     SET BANK_ACCOUNT_NUM = nvl(l_acct_number, BANK_ACCOUNT_NUM),
         COUNTRY_CODE=p_ext_bank_acct_rec.country_code,
         CURRENCY_CODE =p_ext_bank_acct_rec.currency,
         IBAN = DECODE(l_iban, FND_API.G_MISS_CHAR,NULL,NULL,IBAN,l_iban),
         CHECK_DIGITS = p_ext_bank_acct_rec.check_digits,
--     MULTI_CURRENCY_ALLOWED_FLAG = p_ext_bank_acct_rec.multi_currency_allowed_flag,
         BANK_ACCOUNT_TYPE =p_ext_bank_acct_rec.acct_type,
         ACCOUNT_SUFFIX = p_ext_bank_acct_rec.acct_suffix,
	 AGENCY_LOCATION_CODE = p_ext_bank_acct_rec.agency_location_code,
	 BANK_ID = p_ext_bank_acct_rec.bank_id,
         BRANCH_ID =  p_ext_bank_acct_rec.branch_id,
         FOREIGN_PAYMENT_USE_FLAG=p_ext_bank_acct_rec.foreign_payment_use_flag ,
         PAYMENT_FACTOR_FLAG=p_ext_bank_acct_rec.payment_factor_flag,
	 EXCHANGE_RATE_AGREEMENT_TYPE=p_ext_bank_acct_rec.exchange_rate_agreement_type,
	 EXCHANGE_RATE_AGREEMENT_NUM=p_ext_bank_acct_rec.exchange_rate_agreement_num,
	 EXCHANGE_RATE=p_ext_bank_acct_rec.exchange_rate,
         START_DATE=trunc(p_ext_bank_acct_rec.start_date),
	 END_DATE=trunc(p_ext_bank_acct_rec.end_date),
	 HEDGING_CONTRACT_REFERENCE= p_ext_bank_acct_rec.hedging_contract_reference,
         MASKED_BANK_ACCOUNT_NUM=nvl(l_masked_ba_num,MASKED_BANK_ACCOUNT_NUM),
         MASKED_IBAN=l_masked_iban,
         IBAN_HASH1=l_iban_hash1,
         IBAN_HASH2=l_iban_hash2,
         BANK_ACCOUNT_NUM_HASH1=nvl(l_ba_num_hash1,BANK_ACCOUNT_NUM_HASH1),
	 -- bug 7635964
         BANK_ACCOUNT_NUM_HASH2=nvl(l_ba_num_hash2,BANK_ACCOUNT_NUM_HASH2),
         ENCRYPTED = l_encrypted,
         BANK_ACCOUNT_NUM_ELECTRONIC = nvl(l_bank_account_num_electronic,
                                           BANK_ACCOUNT_NUM_ELECTRONIC),
         ATTRIBUTE_CATEGORY = p_ext_bank_acct_rec.attribute_category,
         ATTRIBUTE1 = p_ext_bank_acct_rec.attribute1,
         ATTRIBUTE2 = p_ext_bank_acct_rec.attribute2,
	 ATTRIBUTE3 = p_ext_bank_acct_rec.attribute3,
	 ATTRIBUTE4 = p_ext_bank_acct_rec.attribute4,
	 ATTRIBUTE5 = p_ext_bank_acct_rec.attribute5,
	 ATTRIBUTE6 = p_ext_bank_acct_rec.attribute6,
	 ATTRIBUTE7 = p_ext_bank_acct_rec.attribute7,
	 ATTRIBUTE8 = p_ext_bank_acct_rec.attribute8,
	 ATTRIBUTE9 = p_ext_bank_acct_rec.attribute9,
	 ATTRIBUTE10 = p_ext_bank_acct_rec.attribute10,
	 ATTRIBUTE11 = p_ext_bank_acct_rec.attribute11,
	 ATTRIBUTE12 = p_ext_bank_acct_rec.attribute12,
	 ATTRIBUTE13 = p_ext_bank_acct_rec.attribute13,
	 ATTRIBUTE14 = p_ext_bank_acct_rec.attribute14,
	 ATTRIBUTE15 = p_ext_bank_acct_rec.attribute15,
         LAST_UPDATED_BY = fnd_global.user_id,
         LAST_UPDATE_DATE = sysdate,
         LAST_UPDATE_LOGIN = fnd_global.login_id,
         BANK_ACCOUNT_NAME = p_ext_bank_acct_rec.bank_account_name,
         BANK_ACCOUNT_NAME_ALT = p_ext_bank_acct_rec.alternate_acct_name,
         SHORT_ACCT_NAME = p_ext_bank_acct_rec.short_acct_name,
         DESCRIPTION =p_ext_bank_acct_rec.description,
	 OBJECT_VERSION_NUMBER = p_ext_bank_acct_rec.object_version_number+1 ,
	 SECONDARY_ACCOUNT_REFERENCE = p_ext_bank_acct_rec.secondary_account_reference, -- Bug 7408747
         CONTACT_NAME =p_ext_bank_acct_rec.contact_name,
	 CONTACT_PHONE =p_ext_bank_acct_rec.contact_phone,
	 CONTACT_EMAIL =p_ext_bank_acct_rec.contact_email,
	 CONTACT_FAX =p_ext_bank_acct_rec.contact_fax
     WHERE EXT_BANK_ACCOUNT_ID = p_ext_bank_acct_rec.bank_account_id
     RETURNING OBJECT_VERSION_NUMBER INTO p_ext_bank_acct_rec.object_version_number;

    -- End of API body

    -- get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('RETURN ' || l_module_name);

    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO update_ext_bank_acct_pub;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO update_ext_bank_acct_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


    WHEN OTHERS THEN
      ROLLBACK TO update_ext_bank_acct_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
     FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


  END update_ext_bank_acct;



  -- 11. get_ext_bank_acct
  --
  --   API name        : get_ext_bank_acct
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Queries an external bank account
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE get_ext_bank_acct (
   p_api_version               IN   NUMBER,
   p_init_msg_list             IN   VARCHAR2,
   p_bankacct_id               IN   NUMBER,
   x_return_status             OUT NOCOPY VARCHAR2,
   x_msg_count                 OUT NOCOPY NUMBER,
   x_msg_data                  OUT NOCOPY VARCHAR2,
   x_bankacct                  OUT NOCOPY ExtBankAcct_rec_type,
   x_response                  OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
  ) IS

   l_api_name           CONSTANT VARCHAR2(30)   := 'get_ext_bank_acct';
   l_api_version        CONSTANT NUMBER         := 1.0;
   l_module_name        CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.' || l_api_name;

   CURSOR c_bank_account IS
   SELECT b.EXT_BANK_ACCOUNT_ID,
          b.COUNTRY_CODE,
          b.BRANCH_ID,
          b.BANK_ID,
          b.BANK_ACCOUNT_NUM,
          b.CURRENCY_CODE,
          b.IBAN,
          b.CHECK_DIGITS,
          b.BANK_ACCOUNT_TYPE,
          b.ACCOUNT_CLASSIFICATION,
          b.ACCOUNT_SUFFIX,
          b.AGENCY_LOCATION_CODE,
--          b.MULTI_CURRENCY_ALLOWED_FLAG,
          b.PAYMENT_FACTOR_FLAG,
          b.FOREIGN_PAYMENT_USE_FLAG,
          b.EXCHANGE_RATE_AGREEMENT_NUM,
          b.EXCHANGE_RATE_AGREEMENT_TYPE,
          b.EXCHANGE_RATE,
          b.HEDGING_CONTRACT_REFERENCE,
  --        b.STATUS,
          b.ATTRIBUTE_CATEGORY,
          b.ATTRIBUTE1,
          b.ATTRIBUTE2,
          b.ATTRIBUTE3,
          b.ATTRIBUTE4,
          b.ATTRIBUTE5,
          b.ATTRIBUTE6,
          b.ATTRIBUTE7,
          b.ATTRIBUTE8,
          b.ATTRIBUTE9,
          b.ATTRIBUTE10,
          b.ATTRIBUTE11,
          b.ATTRIBUTE12,
          b.ATTRIBUTE13,
          b.ATTRIBUTE14,
          b.ATTRIBUTE15,
          b.REQUEST_ID,
          b.PROGRAM_APPLICATION_ID,
          b.PROGRAM_ID,
          b.PROGRAM_UPDATE_DATE,
          b.START_DATE,
          b.END_DATE,
          b.CREATED_BY,
          b.CREATION_DATE,
          b.LAST_UPDATED_BY,
          b.LAST_UPDATE_DATE,
          b.LAST_UPDATE_LOGIN,
          b.OBJECT_VERSION_NUMBER,
          null,
          b.BANK_ACCOUNT_NUM_HASH2,
          b.BANK_ACCOUNT_NUM_HASH1,
          b.MASKED_BANK_ACCOUNT_NUM,
          b.IBAN_HASH1,
          b.IBAN_HASH2,
          b.MASKED_IBAN,
          b.BA_MASK_SETTING,
          b.BA_UNMASK_LENGTH,
          b.ENCRYPTED,
          b.BANK_ACCOUNT_NAME,
          b.BANK_ACCOUNT_NAME_ALT,
          b.SHORT_ACCT_NAME,
          b.DESCRIPTION,
          b.SECONDARY_ACCOUNT_REFERENCE     -- Bug 7408747
     FROM IBY_EXT_BANK_ACCOUNTS b
    WHERE   b.EXT_BANK_ACCOUNT_ID = p_bankacct_id;

    CURSOR c_acct_owner IS
    SELECT ACCOUNT_OWNER_PARTY_ID
      FROM IBY_ACCOUNT_OWNERS
     WHERE EXT_BANK_ACCOUNT_ID = p_bankacct_id
      AND PRIMARY_FLAG = 'Y';

    l_bank_account_rec  c_bank_account%ROWTYPE;

  BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo('ENTER ' || l_module_name);

     END IF;
     -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF FND_API.to_Boolean(p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
     END IF;

     --  Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- Start of API body

     check_mandatory('IBY_BANKACCT_ID_FIELD', p_bankacct_id);

     -- Fext the Bank Account data
     OPEN c_bank_account;
     FETCH c_bank_account into l_bank_account_rec;
     CLOSE c_bank_account;

    x_bankacct.bank_account_id              := l_bank_account_rec.EXT_BANK_ACCOUNT_ID ;
    x_bankacct.country_code	                := l_bank_account_rec.COUNTRY_CODE;
    x_bankacct.branch_id	                := l_bank_account_rec.BRANCH_ID ;
    x_bankacct.bank_id		                := l_bank_account_rec.BANK_ID ;
    x_bankacct.bank_account_name            := l_bank_account_rec.BANK_ACCOUNT_NAME ;
    x_bankacct.bank_account_num  := l_bank_account_rec.MASKED_BANK_ACCOUNT_NUM;
    x_bankacct.currency	                    := l_bank_account_rec.CURRENCY_CODE;
    x_bankacct.iban               := l_bank_account_rec.MASKED_IBAN;
    x_bankacct.check_digits	                := l_bank_account_rec.CHECK_DIGITS ;
    x_bankacct.multi_currency_allowed_flag  := null;
--l_bank_account_rec.MULTI_CURRENCY_ALLOWED_FLAG ;
    x_bankacct.alternate_acct_name	        := l_bank_account_rec.BANK_ACCOUNT_NAME_ALT ;
    x_bankacct.short_acct_name              := l_bank_account_rec.SHORT_ACCT_NAME ;
    x_bankacct.acct_type                    := l_bank_account_rec.BANK_ACCOUNT_TYPE;
    x_bankacct.acct_suffix                  := l_bank_account_rec.ACCOUNT_SUFFIX ;
    x_bankacct.description                  := l_bank_account_rec.DESCRIPTION ;
    x_bankacct.agency_location_code	        := l_bank_account_rec.AGENCY_LOCATION_CODE ;
    x_bankacct.foreign_payment_use_flag	    := l_bank_account_rec.FOREIGN_PAYMENT_USE_FLAG ;
    x_bankacct.exchange_rate_agreement_num  := l_bank_account_rec.EXCHANGE_RATE_AGREEMENT_NUM ;
    x_bankacct.exchange_rate_agreement_type := l_bank_account_rec.EXCHANGE_RATE_AGREEMENT_TYPE ;
    x_bankacct.exchange_rate                := l_bank_account_rec.EXCHANGE_RATE ;
    x_bankacct.payment_factor_flag	        := l_bank_account_rec.PAYMENT_FACTOR_FLAG ;
    x_bankacct.status                       := null;
--l_bank_account_rec.STATUS ;
    x_bankacct.end_date                     := l_bank_account_rec.END_DATE ;
    x_bankacct.START_DATE                   := l_bank_account_rec.START_DATE ;
    x_bankacct.hedging_contract_reference   := l_bank_account_rec.HEDGING_CONTRACT_REFERENCE ;
    x_bankacct.attribute_category           := l_bank_account_rec.ATTRIBUTE_CATEGORY ;
    x_bankacct.attribute1                   := l_bank_account_rec.ATTRIBUTE1 ;
    x_bankacct.attribute2                   := l_bank_account_rec.ATTRIBUTE2 ;
    x_bankacct.attribute3                   := l_bank_account_rec.ATTRIBUTE3 ;
    x_bankacct.attribute4                   := l_bank_account_rec.ATTRIBUTE4 ;
    x_bankacct.attribute5                   := l_bank_account_rec.ATTRIBUTE5 ;
    x_bankacct.attribute6                   := l_bank_account_rec.ATTRIBUTE6 ;
    x_bankacct.attribute7                   := l_bank_account_rec.ATTRIBUTE7 ;
    x_bankacct.attribute8                   := l_bank_account_rec.ATTRIBUTE8 ;
    x_bankacct.attribute9                   := l_bank_account_rec.ATTRIBUTE9 ;
    x_bankacct.attribute10                  := l_bank_account_rec.ATTRIBUTE10 ;
    x_bankacct.attribute11                  := l_bank_account_rec.ATTRIBUTE11 ;
    x_bankacct.attribute12                  := l_bank_account_rec.ATTRIBUTE12 ;
    x_bankacct.attribute13                  := l_bank_account_rec.ATTRIBUTE13 ;
    x_bankacct.attribute14                  := l_bank_account_rec.ATTRIBUTE14 ;
    x_bankacct.attribute15                  := l_bank_account_rec.ATTRIBUTE15 ;
    x_bankacct.object_version_number        := l_bank_account_rec.OBJECT_VERSION_NUMBER ;
    x_bankacct.secondary_account_reference   := l_bank_account_rec.SECONDARY_ACCOUNT_REFERENCE ;  -- Bug 7408747

    -- Fetch the Bank Account Owner data
    OPEN c_acct_owner;
    FETCH c_acct_owner into x_bankacct.acct_owner_party_id;
    CLOSE c_acct_owner;

     -- End of API body

     -- get message count and if count is 1, get message info.
     fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo('RETURN ' || l_module_name);
     END IF;
     EXCEPTION
     WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Exception : ' || SQLERRM);
      END IF;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


     WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Exception : ' || SQLERRM);
      END IF;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


     WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Exception : ' || SQLERRM);
      END IF;
   FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


  END get_ext_bank_acct;


  -- 12. get_ext_bank_acct
  --
  --   API name        : get_ext_bank_acct
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Queries an external bank account, decrypting secure
  --                     fields
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE get_ext_bank_acct (
   p_api_version               IN   NUMBER,
   p_init_msg_list             IN   VARCHAR2,
   p_bankacct_id               IN   NUMBER,
   p_sec_key                   IN   VARCHAR2,
   x_return_status             OUT NOCOPY VARCHAR2,
   x_msg_count                 OUT NOCOPY NUMBER,
   x_msg_data                  OUT NOCOPY VARCHAR2,
   x_bankacct                  OUT NOCOPY ExtBankAcct_rec_type,
   x_response                  OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
  )IS

   l_api_name           CONSTANT VARCHAR2(30)   := 'get_ext_bank_acct';
   l_api_version        CONSTANT NUMBER         := 1.0;
   l_module_name        CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.' || l_api_name;

  BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo('ENTER ' || l_module_name);

     END IF;
     SAVEPOINT get_ext_bank_acct_pub;

     -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF FND_API.to_Boolean(p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
     END IF;

     --  Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- Start of API body

     --
     -- Call the other get_ext_bank_acct for now
     -- TO DO: Use the security key
     get_ext_bank_acct (
         1.0,
         NULL,
         p_bankacct_id,
         x_return_status,
         x_msg_count,
         x_msg_data,
         x_bankacct,
         x_response
      );

     -- End of API body

     -- get message count and if count is 1, get message info.
     fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo('RETURN ' || l_module_name);
     END IF;
     EXCEPTION
     WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO get_ext_bank_acct_pub;
      x_return_status := fnd_api.g_ret_sts_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Exception : ' || SQLERRM);
      END IF;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


     WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO get_ext_bank_acct_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Exception : ' || SQLERRM);
      END IF;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


     WHEN OTHERS THEN
      ROLLBACK TO get_ext_bank_acct_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Exception : ' || SQLERRM);
      END IF;
 FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


  END get_ext_bank_acct;


  -- 13. set_ext_bank_acct_dates
  --
  --   API name        : set_ext_bank_acct_dates
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Sets the bank account end dates
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE set_ext_bank_acct_dates (
   p_api_version              IN     NUMBER,
   p_init_msg_list            IN     VARCHAR2,
   p_acct_id                  IN     NUMBER,
   p_start_date		          IN	 DATE,
   p_end_date                 IN     DATE,
   p_object_version_number    IN OUT NOCOPY  NUMBER,
   x_return_status               OUT NOCOPY  VARCHAR2,
   x_msg_count                   OUT NOCOPY  NUMBER,
   x_msg_data                    OUT NOCOPY  VARCHAR2,
   x_response                    OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
  ) IS

  l_api_name           CONSTANT VARCHAR2(30)   := 'set_ext_bank_acct_dates';
  l_api_version        CONSTANT NUMBER         := 1.0;
  l_module_name        CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.' || l_api_name;

  BEGIN

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('ENTER ' || l_module_name);

    END IF;
    SAVEPOINT set_ext_bank_acct_dates_pub;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Start of API body

    -- Parameter validations
    check_mandatory('IBY_BANKACCT_ID_FIELD', p_acct_id);
    check_mandatory('IBY_START_DATE', p_start_date);
    -- End Date is optional
    --check_mandatory('End Date', p_end_date);
    check_mandatory('IBY_OBJ_VER_NUM', p_object_version_number);

    IF (p_end_date IS NOT NULL AND p_start_date > p_end_date) THEN
       -- throw exception if start date
       -- exceeds end_date
       fnd_message.set_name('IBY', 'IBY_START_END_DATE_BAD');
       fnd_msg_pub.add;
       RAISE fnd_api.g_exc_error;
    END IF;

    -- update bank account dates
    UPDATE IBY_EXT_BANK_ACCOUNTS
     SET START_DATE = p_start_date, END_DATE = NVL(p_end_date,END_DATE)
     WHERE EXT_BANK_ACCOUNT_ID = p_acct_id;

    IF (SQL%NOTFOUND) THEN
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       print_debuginfo('Warning: No matching Row found in IBY_EXT_BANK_ACCOUNTS');
       END IF;
    ELSE
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       print_debuginfo('Set Ext Bank Account End Date as ' || p_end_date);
       END IF;
    END IF;

    -- End of API body

    -- get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('RETURN ' || l_module_name);

    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO set_ext_bank_acct_dates_pub;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO set_ext_bank_acct_dates_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


    WHEN OTHERS THEN
      ROLLBACK TO set_ext_bank_acct_dates_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
     FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


  END set_ext_bank_acct_dates;


  -- 14. check_ext_acct_exist
  --
  --   API name        : check_ext_acct_exist
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Checks if the external account exists; identity
  --                     is determined by bank id, branch id, country and
  --                     currency codes, bank account number and
  --                     country specific attributes.
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  /* Modified to include country specific unique bank account
  validation. Bug:7501595*/
   PROCEDURE check_ext_acct_exist(
    p_api_version            IN  NUMBER,
    p_init_msg_list          IN  VARCHAR2,
    p_ext_bank_acct_rec      IN  ExtBankAcct_rec_type,
    x_acct_id                OUT NOCOPY NUMBER,
    x_start_date		     OUT NOCOPY DATE,
    x_end_date		         OUT NOCOPY DATE,
    x_return_status          OUT NOCOPY VARCHAR2,
    x_msg_count              OUT NOCOPY NUMBER,
    x_msg_data               OUT NOCOPY VARCHAR2,
    x_response               OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
  ) IS

  l_ba_num_hash1       iby_ext_bank_accounts.bank_account_num_hash1%TYPE;
  l_ba_num_hash2       iby_ext_bank_accounts.bank_account_num_hash1%TYPE;

  l_api_name           CONSTANT VARCHAR2(30)   := 'check_ext_acct_exist';
  l_api_version        CONSTANT NUMBER         := 1.0;
  l_module_name        CONSTANT VARCHAR2(200)   := G_PKG_NAME || '.' || l_api_name;

  -- Unique Check: the external bank already exists if
  -- the bank acount name matches or currency and bank
  -- account number matches.

  -- For Readability different cursors are maintained for each type of
  -- validation

  -- General Unique check

 CURSOR uniq_check_generic ( p_account_num_hash1 VARCHAR2,
                     p_account_num_hash2 VARCHAR2,
                     p_currency VARCHAR2,
                     p_bank_id NUMBER,
                     p_branch_id NUMBER,
                     p_country_code VARCHAR2,
                     p_acct_id NUMBER) IS

     SELECT EXT_BANK_ACCOUNT_ID,
            START_DATE,
            END_DATE
     FROM IBY_EXT_BANK_ACCOUNTS
     WHERE (BANK_ACCOUNT_NUM_HASH1= p_account_num_hash1)
         AND (BANK_ACCOUNT_NUM_HASH2= p_account_num_hash2)
       AND ((p_currency IS NULL and CURRENCY_CODE is NULL)  OR (CURRENCY_CODE = p_currency))
        AND ((p_bank_id IS NULL AND BANK_ID is NULL) OR (BANK_ID = p_bank_id))
        AND ((p_branch_id IS NULL AND BRANCH_ID is NULL) OR (BRANCH_ID = p_branch_id))
       AND p_country_code=COUNTRY_CODE
       AND ((p_acct_id IS NULL) OR (EXT_BANK_ACCOUNT_ID <> p_acct_id));

-- Country specific unique check cursor
-- where account type has to be considered
 CURSOR uniq_check_acctType ( p_account_num_hash1 VARCHAR2,
                     p_account_num_hash2 VARCHAR2,
                     p_currency VARCHAR2,
                     p_bank_id NUMBER,
                     p_branch_id NUMBER,
                     p_country_code VARCHAR2,
                     p_acct_type varchar2,
                     p_acct_id NUMBER) IS

     SELECT EXT_BANK_ACCOUNT_ID,
            START_DATE,
            END_DATE
     FROM IBY_EXT_BANK_ACCOUNTS
     WHERE (BANK_ACCOUNT_NUM_HASH1= p_account_num_hash1)
         AND (BANK_ACCOUNT_NUM_HASH2= p_account_num_hash2)
       AND ((p_currency IS NULL and CURRENCY_CODE is NULL)  OR (CURRENCY_CODE = p_currency))
        AND ((p_bank_id IS NULL AND BANK_ID is NULL) OR (BANK_ID = p_bank_id))
        AND ((p_branch_id IS NULL AND BRANCH_ID is NULL) OR (BRANCH_ID = p_branch_id))
       AND p_country_code=COUNTRY_CODE
       AND ((p_acct_id IS NULL) OR (EXT_BANK_ACCOUNT_ID <> p_acct_id))
       AND ((p_acct_type is NULL and BANK_ACCOUNT_TYPE is NULL)OR (p_acct_type=BANK_ACCOUNT_TYPE));

-- Country specific unique check cursor
-- where account suffix is to be considered
 CURSOR uniq_check_acctSuffix ( p_account_num_hash1 VARCHAR2,
                     p_account_num_hash2 VARCHAR2,
                     p_currency VARCHAR2,
                     p_bank_id NUMBER,
                     p_branch_id NUMBER,
                     p_country_code VARCHAR2,
                     p_acct_suffix varchar2,
                     p_acct_id NUMBER) IS

     SELECT EXT_BANK_ACCOUNT_ID,
            START_DATE,
            END_DATE
     FROM IBY_EXT_BANK_ACCOUNTS
     WHERE (BANK_ACCOUNT_NUM_HASH1= p_account_num_hash1)
         AND (BANK_ACCOUNT_NUM_HASH2= p_account_num_hash2)
       AND ((p_currency IS NULL and CURRENCY_CODE is NULL)  OR (CURRENCY_CODE = p_currency))
        AND ((p_bank_id IS NULL AND BANK_ID is NULL) OR (BANK_ID = p_bank_id))
        AND ((p_branch_id IS NULL AND BRANCH_ID is NULL) OR (BRANCH_ID = p_branch_id))
       AND p_country_code=COUNTRY_CODE
       AND ((p_acct_id IS NULL) OR (EXT_BANK_ACCOUNT_ID <> p_acct_id))
       AND ((p_acct_suffix is NULL and ACCOUNT_SUFFIX is NULL)OR (p_acct_suffix=ACCOUNT_SUFFIX));

  BEGIN

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('ENTER ' || l_module_name);
	    print_debuginfo('bank_id:' || p_ext_bank_acct_rec.bank_id);
	    print_debuginfo('branch_id:'|| p_ext_bank_acct_rec.branch_id);
	    print_debuginfo('country_code:'|| p_ext_bank_acct_rec.country_code);
	    print_debuginfo('currency:'|| p_ext_bank_acct_rec.currency);
	    print_debuginfo('account_type:'|| p_ext_bank_acct_rec.acct_type);
	    print_debuginfo('account_suffix:'|| p_ext_bank_acct_rec.acct_suffix);
	    print_debuginfo('account_number:'|| p_ext_bank_acct_rec.bank_account_num);
	    print_debuginfo('account_name:'|| p_ext_bank_acct_rec.bank_account_name);
	    print_debuginfo('external_bank_account_id:'|| p_ext_bank_acct_rec.bank_account_id);


    END IF;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Parameter validations

    IF (p_ext_bank_acct_rec.bank_id is not null) THEN
    check_mandatory('IBY_BNKBRN_ID_FIELD',p_ext_bank_acct_rec.branch_id);
    END IF;

    IF (p_ext_bank_acct_rec.bank_account_name IS NULL) THEN
       check_mandatory('IBY_BANKACCT_NUM_FIELD',p_ext_bank_acct_rec.bank_account_num);
    END IF;

    l_ba_num_hash1 := iby_security_pkg.get_hash(p_ext_bank_acct_rec.bank_account_num,'F');
    l_ba_num_hash2 := iby_security_pkg.get_hash(p_ext_bank_acct_rec.bank_account_num,'T');
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    print_debuginfo('l_ba_num_hash1:' || l_ba_num_hash1);
    print_debuginfo('l_ba_num_hash2:' || l_ba_num_hash2);
    END IF;

    -- Check if bank account exists
    -- For Japan, account type has to be considered for Unique check
    -- Bug No: 7501595
    IF (p_ext_bank_acct_rec.country_code = 'JP') THEN
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        print_debuginfo('Inside country_code - JP');
    END IF;
    OPEN uniq_check_acctType(l_ba_num_hash1, l_ba_num_hash2, p_ext_bank_acct_rec.currency, p_ext_bank_acct_rec.bank_id,
                    p_ext_bank_acct_rec.branch_id, p_ext_bank_acct_rec.country_code, p_ext_bank_acct_rec.acct_type,
                    p_ext_bank_acct_rec.bank_account_id);
    FETCH uniq_check_acctType INTO x_acct_id,x_start_date,x_end_date;
    CLOSE uniq_check_acctType;

    -- Check if bank account exists
    -- For Japan, account suffix has to be considered for Unique check
    -- Bug No: 7632304
    ELSIF (p_ext_bank_acct_rec.country_code = 'NZ') THEN
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        print_debuginfo('Inside country_code - NZ');
    END IF;
    OPEN uniq_check_acctSuffix(l_ba_num_hash1, l_ba_num_hash2, p_ext_bank_acct_rec.currency, p_ext_bank_acct_rec.bank_id,
                    p_ext_bank_acct_rec.branch_id, p_ext_bank_acct_rec.country_code, p_ext_bank_acct_rec.acct_suffix,
                    p_ext_bank_acct_rec.bank_account_id);
    FETCH uniq_check_acctSuffix INTO x_acct_id,x_start_date,x_end_date;
    CLOSE uniq_check_acctSuffix;
    ELSE
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        print_debuginfo('Inside generic check');
    END IF;
    OPEN uniq_check_generic(l_ba_num_hash1, l_ba_num_hash2, p_ext_bank_acct_rec.currency, p_ext_bank_acct_rec.bank_id,
                    p_ext_bank_acct_rec.branch_id, p_ext_bank_acct_rec.country_code,
                    p_ext_bank_acct_rec.bank_account_id);
    FETCH uniq_check_generic INTO x_acct_id,x_start_date,x_end_date;
    CLOSE uniq_check_generic;
    END IF;

    IF (SQL%NOTFOUND) THEN
--       fnd_message.set_name('IBY', 'IBY_EXT_ACCT_NOT_EXIST');
--       fnd_msg_pub.add;
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       print_debuginfo('External Account does not exist ');
       END IF;
    END IF;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    print_debuginfo('x_acct_id:' || x_acct_id);
    print_debuginfo('x_start_date:' || x_start_date);
    print_debuginfo('x_end_date:' || x_end_date);
    END IF;

    -- get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('RETURN ' || l_module_name);

    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Exception : ' || SQLERRM);
      END IF;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Exception : ' || SQLERRM);
      END IF;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


    WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Exception : ' || SQLERRM);
      END IF;
     FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


  END check_ext_acct_exist;


  -- 14. check_ext_acct_exist
  --
  --   API name        : check_ext_acct_exist
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Checks if the external account exists; identity
  --                     is determined by bank id, branch id, country and
  --                     currency codes
  --
  --
  --        Input parameters for the procedure is modified to facilitate
  -- country specific unique bank account validation. But this procedure
  -- is used by many external products. To ensure that no other code breaks
  -- due to this change, the original procedure is maintained as overloaded
  -- procedure. This procedure should be removed as soon as all the external
  -- products update their code to use the updated procedure.
  --
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
   PROCEDURE check_ext_acct_exist(
    p_api_version            IN  NUMBER,
    p_init_msg_list          IN  VARCHAR2,
    p_bank_id                IN varchar2,
    p_branch_id              IN  NUMBER,
    p_acct_number            IN  VARCHAR2,
    p_acct_name              IN  VARCHAR2,
    p_currency		     IN  VARCHAR2,
    p_country_code           IN  VARCHAR2,
    x_acct_id                OUT NOCOPY NUMBER,
    x_start_date		     OUT NOCOPY DATE,
    x_end_date		         OUT NOCOPY DATE,
    x_return_status          OUT NOCOPY VARCHAR2,
    x_msg_count              OUT NOCOPY NUMBER,
    x_msg_data               OUT NOCOPY VARCHAR2,
    x_response               OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
  ) IS
  l_api_name           CONSTANT VARCHAR2(50)   := 'check_ext_acct_exist (OVERLOADED)';
  l_api_version        CONSTANT NUMBER         := 1.0;
  l_module_name        CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.' || l_api_name;
  l_ext_bank_acct_rec  ExtBankAcct_rec_type;
  BEGIN
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo('ENTER ' || l_module_name);
     END IF;
     l_ext_bank_acct_rec.bank_id := p_bank_id;
     l_ext_bank_acct_rec.branch_id := p_branch_id;
     l_ext_bank_acct_rec.bank_account_num := p_acct_number;
     l_ext_bank_acct_rec.bank_account_name := p_acct_name;
     l_ext_bank_acct_rec.currency := p_currency;
     l_ext_bank_acct_rec.country_code := p_country_code;

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo('Before calling the base procedure ' || l_module_name);

     END IF;
    check_ext_acct_exist(
    p_api_version,
    p_init_msg_list,
    l_ext_bank_acct_rec,
    x_acct_id,
    x_start_date,
    x_end_date,
    x_return_status,
    x_msg_count,
    x_msg_data,
    x_response
    );

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo('EXIT ' || l_module_name);

     END IF;
  END;

  -- 15. create_intermediary_acct
  --
  --   API name        : create_intermediary_acct
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Creates an intermediary bank account
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE create_intermediary_acct (
    p_api_version              IN   NUMBER,
	p_init_msg_list            IN   VARCHAR2,
    p_intermed_acct_rec        IN   IntermediaryAcct_rec_type,
	x_intermediary_acct_id     OUT  NOCOPY NUMBER,
	x_return_status            OUT  NOCOPY  VARCHAR2,
	x_msg_count                OUT  NOCOPY  NUMBER,
	x_msg_data                 OUT  NOCOPY  VARCHAR2,
	x_response               OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
  )  IS

  l_api_name           CONSTANT VARCHAR2(30)   := 'create_intermediary_acct';
  l_api_version        CONSTANT NUMBER         := 1.0;
  l_module_name        CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.' || l_api_name;


  BEGIN
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('ENTER ' || l_module_name);

    END IF;
    SAVEPOINT create_intermediary_acct_pub;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Parameter validations
    check_mandatory('IBY_BANKACCT_ID_FIELD', p_intermed_acct_rec.bank_account_id);

    -- insert into IBY_INTERMEDIATE_ACCTS

    INSERT INTO IBY_INTERMEDIARY_ACCTS(
        INTERMEDIARY_ACCT_ID,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_LOGIN,
        CREATION_DATE,
        CREATED_BY,
        BANK_ACCT_ID,
        INTERNAL_BANK_ACCOUNT_ID,
        COUNTRY_CODE,
        BANK_NAME,
        CITY,
        BANK_CODE,
        BRANCH_NUMBER,
        BIC,
        ACCOUNT_NUMBER,
        CHECK_DIGITS,
        IBAN,
        COMMENTS,
        OBJECT_VERSION_NUMBER)
    VALUES (
        IBY_INTERMEDIARY_ACCTS_S.nextval,
        sysdate,
        NVL(FND_GLOBAL.user_id,-1),
        NVL(FND_GLOBAL.login_id, -1),
        sysdate,
        NVL(FND_GLOBAL.user_id,-1),
        p_intermed_acct_rec.bank_account_id,
        -99,
        p_intermed_acct_rec.country_code,
        p_intermed_acct_rec.bank_name,
        p_intermed_acct_rec.city,
        p_intermed_acct_rec.bank_code,
        p_intermed_acct_rec.branch_number,
        p_intermed_acct_rec.bic,
        p_intermed_acct_rec.account_number,
        p_intermed_acct_rec.check_digits,
        p_intermed_acct_rec.iban,
        p_intermed_acct_rec.comments,
        1)
    RETURNING INTERMEDIARY_ACCT_ID INTO x_intermediary_acct_id;


    -- get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('RETURN ' || l_module_name);


    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_intermediary_acct_pub;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_intermediary_acct_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


    WHEN OTHERS THEN
      ROLLBACK TO create_intermediary_acct_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Exception : ' || SQLERRM);
      END IF;
  FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


  END create_intermediary_acct;



  -- 16. Update_Intermediary_Acct
  --
  --   API name        : Update_Intermediary_Acct
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Updates an intermediary bank account
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE update_intermediary_acct (
   p_api_version              IN  NUMBER,
   p_init_msg_list            IN  VARCHAR2,
   p_intermed_acct_rec        IN  OUT NOCOPY  IntermediaryAcct_rec_type,
   x_return_status                OUT NOCOPY  VARCHAR2,
   x_msg_count                    OUT NOCOPY  NUMBER,
   x_msg_data                     OUT NOCOPY  VARCHAR2,
   x_response                     OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
  )  IS

  l_api_name           CONSTANT VARCHAR2(30)   := 'create_bank';
  l_api_version        CONSTANT NUMBER         := 1.0;
  l_module_name        CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.' || l_api_name;

   -- Get Object Version Number
   CURSOR c_ovn IS
      SELECT object_version_number
      FROM   IBY_INTERMEDIARY_ACCTS
      WHERE  intermediary_acct_id = p_intermed_acct_rec.intermediary_acct_id;

   l_old_ovn           NUMBER(15);

  BEGIN

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('ENTER ' || l_module_name);

    END IF;
    SAVEPOINT update_intermediary_acct;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --START of API

    -- Parameter validations
    check_mandatory('IBY_INTERMEDIARYACCT_ID_FIELD', p_intermed_acct_rec.intermediary_acct_id);
    check_mandatory('IBY_OBJ_VER_NUM', p_intermed_acct_rec.object_version_number);

     -- check object version number to make sure the record has not been updated
    OPEN c_ovn;
    FETCH c_ovn INTO l_old_ovn;
    IF c_ovn%NOTFOUND THEN
      fnd_message.set_name('IBY', 'IBY_API_NO_INTERMEDIARY_ACCT');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
      CLOSE c_ovn;
      RAISE fnd_api.g_exc_error;
    END IF;
    CLOSE c_ovn;

    IF l_old_ovn > p_intermed_acct_rec.object_version_number THEN
      fnd_message.set_name('IBY', 'IBY_DATA_VERSION_ERROR');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- update the table IBY_INTERMEDIARY_ACCOUNTS
    UPDATE IBY_INTERMEDIARY_ACCTS
    SET    country_code                = p_intermed_acct_rec.country_code,
           bank_name                   = p_intermed_acct_rec.bank_name,
           city                        = p_intermed_acct_rec.city,
           bank_code                   = p_intermed_acct_rec.bank_code,
           branch_number               = p_intermed_acct_rec.branch_number,
           bic                         = p_intermed_acct_rec.bic,
           account_number              = p_intermed_acct_rec.account_number,
           check_digits                = p_intermed_acct_rec.check_digits,
           iban                        = p_intermed_acct_rec.iban,
           comments                    = p_intermed_acct_rec.comments,
           last_update_date            = sysdate,
           last_update_login           = NVL(FND_GLOBAL.login_id,-1),
           last_updated_by             = NVL(FND_GLOBAL.user_id,-1),
           object_version_number       = l_old_ovn + 1
    WHERE  intermediary_acct_id = p_intermed_acct_rec.intermediary_acct_id
    RETURNING object_version_number INTO p_intermed_acct_rec.object_version_number;

    IF (SQL%NOTFOUND) THEN
      fnd_message.set_name('IBY', 'IBY_API_NO_INTERMEDIARY_ACCT');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- END of API

    -- get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo('RETURN ' || l_module_name);

     END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO update_intermediary_bank_acct;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO update_intermediary_bank_acct;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


    WHEN OTHERS THEN
      ROLLBACK TO update_intermediary_bank_acct;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
     FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

  END update_intermediary_acct;


  -- 17. add_joint_account_owner
  --
  --   API name        : add_joint_account_owner
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Associates another owner with a bank account
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE add_joint_account_owner (
   p_api_version               IN   NUMBER,
   p_init_msg_list             IN   VARCHAR2,
   p_bank_account_id           IN   NUMBER,
   p_acct_owner_party_id       IN   NUMBER,
   x_joint_acct_owner_id	   OUT  NOCOPY  NUMBER,
   x_return_status             OUT  NOCOPY  VARCHAR2,
   x_msg_count                 OUT  NOCOPY  NUMBER,
   x_msg_data                  OUT  NOCOPY  VARCHAR2,
   x_response                  OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
  )  IS

  l_api_name           CONSTANT VARCHAR2(30)   := 'add_joint_account_owner';
  l_api_version        CONSTANT NUMBER         := 1.0;
  l_module_name        CONSTANT VARCHAR2(200)   := G_PKG_NAME || '.' || l_api_name;

  l_count              NUMBER;
  l_primary_flag       VARCHAR2(1) := 'N';

  -- Unique Check: same party cannot be assigned the same bank account
  -- more than once.
  CURSOR uniq_check(p_party_id NUMBER, bank_account_id NUMBER)
  IS
  SELECT COUNT(*)
  FROM IBY_ACCOUNT_OWNERS
  WHERE ACCOUNT_OWNER_PARTY_ID = p_party_id
    AND EXT_BANK_ACCOUNT_ID = bank_account_id;

  -- No of Active account owners
  CURSOR active_owners(bank_account_id NUMBER)
  IS
  SELECT COUNT(*)
  FROM IBY_ACCOUNT_OWNERS
  WHERE EXT_BANK_ACCOUNT_ID = bank_account_id;
 -- AND (end_date IS NULL OR end_date > sysdate);

  BEGIN

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('ENTER ' || l_module_name);

    END IF;
    SAVEPOINT add_joint_account_owner;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Parameter validations
    check_mandatory('IBY_BANKACCT_ID_FIELD',p_bank_account_id);
    check_mandatory('IBY_ACCTOWNER_PARTYID_FIELD',p_acct_owner_party_id);

    -- Check for uniqueness
    OPEN uniq_check(p_acct_owner_party_id, p_bank_account_id);
    FETCH uniq_check INTO l_count;
    CLOSE uniq_check;

    IF (l_count > 0) THEN
       fnd_message.set_name('IBY', 'IBY_ACCT_OWNER_EXISTS');
       fnd_msg_pub.add;
       RETURN;
    END IF;

    -- Check the no. of active owners
    OPEN active_owners(p_bank_account_id);
    FETCH active_owners INTO l_count;
    CLOSE active_owners;

    -- Mark the owner as primary if it was
    -- an orphan account.
    IF (l_count <= 0) THEN
      l_primary_flag := 'Y';
    END IF;

    -- Insert Row in IBY_ACCOUNT_OWNERS
    INSERT INTO IBY_ACCOUNT_OWNERS
    (
     ACCOUNT_OWNER_ID,
     EXT_BANK_ACCOUNT_ID,
     ACCOUNT_OWNER_PARTY_ID,
     END_DATE,
     PRIMARY_FLAG,
     CREATED_BY,
     CREATION_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_DATE,
     LAST_UPDATE_LOGIN,
     OBJECT_VERSION_NUMBER
    )
    VALUES
    (
      IBY_ACCOUNT_OWNERS_S.NEXTVAL,
      p_bank_account_id,
      p_acct_owner_party_id,
      NULL,
      l_primary_flag,
      fnd_global.user_id,
      sysdate,
      fnd_global.user_id,
      sysdate,
      fnd_global.user_id,
      1.0
    ) RETURNING ACCOUNT_OWNER_ID INTO x_joint_acct_owner_id;

    -- get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('RETURN ' || l_module_name);

    END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO add_joint_account_owner;
      x_return_status := fnd_api.g_ret_sts_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Exception : ' || SQLERRM);
      END IF;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO add_joint_account_owner;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Exception : ' || SQLERRM);
      END IF;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


    WHEN OTHERS THEN
      ROLLBACK TO add_joint_account_owner;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Exception : ' || SQLERRM);
      END IF;
   FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

  END add_joint_account_owner;


  -- 18. set_joint_acct_owner_end_date
  --
  --   API name        : set_joint_acct_owner_end_date
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Sets the end data for a joint account owner
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE set_joint_acct_owner_end_date (
   p_api_version                IN   NUMBER,
   p_init_msg_list              IN     VARCHAR2,
   p_acct_owner_id              IN     NUMBER,
   p_end_date                   IN     DATE,
   p_object_version_number      IN OUT NOCOPY  NUMBER,
   x_return_status                 OUT NOCOPY  VARCHAR2,
   x_msg_count                     OUT NOCOPY  NUMBER,
   x_msg_data                      OUT NOCOPY  VARCHAR2,
   x_response                      OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
  )  IS

  l_api_name           CONSTANT VARCHAR2(30)   := 'set_joint_acct_owner_end_date';
  l_api_version        CONSTANT NUMBER         := 1.0;
  l_module_name        CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.' || l_api_name;


  BEGIN

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('ENTER ' || l_module_name);

    END IF;
    SAVEPOINT set_acct_owner_end_date_pub;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Start of API body
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('Object Version Number : ' || p_object_version_number);

    END IF;
    -- Parameter validations
    check_mandatory('IBY_ACCTOWNER_ID_FIELD',p_acct_owner_id);
    check_mandatory('IBY_END_DATE',p_end_date);
    check_mandatory('IBY_OBJ_VER_NUM',p_object_version_number);

    -- Set End Date to joint owners table
    UPDATE IBY_ACCOUNT_OWNERS
       SET END_DATE = p_end_date,
           OBJECT_VERSION_NUMBER = p_object_version_number + 1
       WHERE ACCOUNT_OWNER_ID = p_acct_owner_id
         AND OBJECT_VERSION_NUMBER = p_object_version_number
       RETURNING OBJECT_VERSION_NUMBER INTO p_object_version_number;

    IF (SQL%NOTFOUND) THEN
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       print_debuginfo('Warning : No Matching Rows found in IBY_ACCOUNT_OWNERS');
       END IF;
    END IF;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('Updated Object Version Number : ' || p_object_version_number);

    END IF;
    -- End of API body

    -- get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                              p_count => x_msg_count,
                              p_data  => x_msg_data);

   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   print_debuginfo('RETURN ' || l_module_name);

   END IF;
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO set_acct_owner_end_date_pub;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO set_acct_owner_end_date_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


    WHEN OTHERS THEN
      ROLLBACK TO set_acct_owner_end_date_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
 FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


  END set_joint_acct_owner_end_date;


  -- 19. change_primary_acct_owner
  --
  --   API name        : change_primary_acct_owner
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Changes the
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE change_primary_acct_owner (
   p_api_version                IN NUMBER,
   p_init_msg_list              IN VARCHAR2,
   p_bank_acct_id               IN NUMBER,
   p_acct_owner_party_id        IN NUMBER,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,
   x_response                   OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
  ) IS

   l_api_name           CONSTANT VARCHAR2(30)   := 'change_primary_acct_owner';
   l_api_version        CONSTANT NUMBER         := 1.0;
   l_module_name        CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.' || l_api_name;

   l_count              PLS_INTEGER;

   -- Pick up Current Primary Account for the Bank Account Id
   CURSOR c_account_owner(bank_account_id NUMBER)
   IS
   SELECT account_owner_id
   FROM IBY_ACCOUNT_OWNERS
   WHERE EXT_BANK_ACCOUNT_ID = bank_account_id
     AND primary_flag = 'Y';

  BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo('ENTER ' || l_module_name);

     END IF;
     SAVEPOINT change_primary_acct_owner_pub;

     -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF FND_API.to_Boolean(p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
     END IF;

     --  Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- Start of API body

     -- Parameter validations
     check_mandatory('IBY_BANKACCT_ID_FIELD',p_bank_acct_id);
     check_mandatory('IBY_ACCTOWNER_PARTYID_FIELD',p_acct_owner_party_id);

     FOR l_account_owner_id IN c_account_owner(p_bank_acct_id)
      LOOP
         UPDATE IBY_ACCOUNT_OWNERS
            SET PRIMARY_FLAG = 'N'
            WHERE EXT_BANK_ACCOUNT_ID = p_bank_acct_id;
      END LOOP;

     UPDATE IBY_ACCOUNT_OWNERS
        SET PRIMARY_FLAG = 'Y'
        WHERE ACCOUNT_OWNER_PARTY_ID = p_acct_owner_party_id
        AND EXT_BANK_ACCOUNT_ID = p_bank_acct_id;

     l_count := SQL%ROWCOUNT;
     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo('Rows affected : '||l_count);

     END IF;
     IF (l_count = 1) THEN
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        print_debuginfo('Primary Flag set for Account Owner '||p_acct_owner_party_id);
        END IF;
     ELSE
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	        print_debuginfo('Too many matching rows found');
        END IF;
        raise fnd_api.g_exc_unexpected_error;
     END IF;

     -- End of API body

     -- get message count and if count is 1, get message info.
     fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo('RETURN ' || l_module_name);
     END IF;
     EXCEPTION
     WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO change_primary_acct_owner_pub;
      x_return_status := fnd_api.g_ret_sts_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Exception : ' || SQLERRM);
      END IF;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


     WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO change_primary_acct_owner_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Exception : ' || SQLERRM);
      END IF;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


     WHEN OTHERS THEN
      ROLLBACK TO change_primary_acct_owner_pub;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Exception : ' || SQLERRM);
      END IF;
 FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

  END change_primary_acct_owner;




  -- 20. check_bank_acct_owner
  --
  --   API name        : check_bank_acct_owner
  --   Type            : Public
  --   Pre-reqs        : None
  --   Function        : Changes the
  --   Current version : 1.0
  --   Previous version: 1.0
  --   Initial version : 1.0
  --
  PROCEDURE check_bank_acct_owner (
   p_api_version                IN NUMBER,
   p_init_msg_list              IN VARCHAR2 default FND_API.G_FALSE,
   p_bank_acct_id               IN NUMBER,
   p_acct_owner_party_id        IN NUMBER,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,
   x_response                   OUT NOCOPY IBY_FNDCPT_COMMON_PUB.Result_rec_type
  ) IS
   l_api_name           CONSTANT VARCHAR2(30)   := 'check_bank_acct_owner';
   l_api_version        CONSTANT NUMBER         := 1.0;
   l_module_name        CONSTANT VARCHAR2(200)  := G_PKG_NAME || '.' || l_api_name;
   l_owner_id  NUMBER;

  BEGIN

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo('ENTER ' || l_module_name);

     END IF;

     -- Standard call to check for call compatibility.
     IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- Initialize message list if p_init_msg_list is set to TRUE.
     IF FND_API.to_Boolean(p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
     END IF;

     --  Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- Start of API body

     -- Parameter validations
     check_mandatory('Bank Account Id',p_bank_acct_id);
     check_mandatory('Account Owner Party Id',p_acct_owner_party_id);

	   BEGIN
		   SELECT account_owner_id
		   INTO l_owner_id
		   FROM IBY_ACCOUNT_OWNERS
		   WHERE EXT_BANK_ACCOUNT_ID = p_bank_acct_id
		     AND account_owner_party_id = p_acct_owner_party_id
		     AND nvl(end_date, sysdate+1) > sysdate;

		   EXCEPTION WHEN No_Data_Found THEN
		      x_return_status := fnd_api.g_ret_sts_error;
		       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
			       print_debuginfo('Given Party is not the owner of the account');
		       END IF;
	   END;

     -- End of API body

     -- get message count and if count is 1, get message info.
     fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

     IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	     print_debuginfo('RETURN ' || l_module_name);
     END IF;
     EXCEPTION
     WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Exception : ' || SQLERRM);
      END IF;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
      Raise;

     WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Exception : ' || SQLERRM);
      END IF;
      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
      Raise;

     WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	      print_debuginfo('Exception : ' || SQLERRM);
      END IF;
      FND_MSG_PUB.add_exc_msg(G_PKG_NAME, l_module_name, null);

      fnd_msg_pub.count_and_get(p_encoded => fnd_api.g_false,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
      Raise;
    END check_bank_acct_owner;


  /*=======================================================================+
   | PRIVATE FUNCTION get_country					                       |
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
    p_bank_id		       IN     NUMBER,
    x_return_status        IN OUT NOCOPY VARCHAR2
  ) RETURN VARCHAR2 IS
    CURSOR c_country IS
      SELECT hp.country
      FROM   hz_parties hp
      WHERE  hp.party_id = p_bank_id
      AND    hp.status = 'A';
    l_country	VARCHAR2(60);
  BEGIN
    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    OPEN c_country;
    FETCH c_country INTO l_country;
    IF c_country%NOTFOUND THEN
      fnd_message.set_name('IBY', 'IBY_API_NO_BANK');
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
    x_bank_id		       OUT    NOCOPY NUMBER,
    x_country_code	       OUT    NOCOPY VARCHAR2,
    x_bank_name		       OUT    NOCOPY VARCHAR2,
    x_bank_number          OUT    NOCOPY VARCHAR2
  ) IS

  l_api_name           CONSTANT VARCHAR2(30)   := 'find_bank_info';
  l_module_name        CONSTANT VARCHAR2(200)   := G_PKG_NAME || '.' || l_api_name;

    CURSOR c_bank IS
    select ce_bank.bank_party_id as bank_id,
           ce_bank.bank_home_country as country,
           ce_bank.bank_name,
           ce_bank.bank_number
   from    ce_bank_branches_v ce_bank
   where   ce_bank.branch_party_id=p_branch_id;

/*
      SELECT hz_bank.party_id AS bank_id,
             hz_bank.country,
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
*/
  BEGIN
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('ENTER ' || l_module_name);

    END IF;
    -- initialize API return status to success.
    x_return_status := fnd_api.g_ret_sts_success;

    OPEN c_bank;
    FETCH c_bank INTO x_bank_id, x_country_code, x_bank_name, x_bank_number;
    IF c_bank%NOTFOUND THEN
      fnd_message.set_name('IBY', 'IBY_API_NO_BANK');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
    END IF;
    CLOSE c_bank;

    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('RETURN ' || l_module_name);

    END IF;
  END find_bank_info;

  /*=======================================================================+
   | PRIVATE PROCEDURE check_mandatory                                     |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   check for mandatory parameters.                                     |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | MODIFICATION HISTORY                                                  |
   |   08-SEP-2004    nmukerje      Created.                               |
   +=======================================================================*/

   PROCEDURE check_mandatory(
      p_field           IN     VARCHAR2,
      p_value           IN     VARCHAR2
   ) IS

   l_temp         VARCHAR2(80);

   CURSOR c_validate_currency (p_currency_code  VARCHAR2) IS
      SELECT CURRENCY_CODE
        FROM FND_CURRENCIES
       WHERE CURRENCY_CODE = p_currency_code;

   BEGIN

   if (p_value is NULL) THEN
       fnd_message.set_name('IBY', 'IBY_MISSING_MANDATORY_PARAM');
       fnd_message.set_token('PARAM', fnd_message.get_string('IBY',p_field));
       fnd_msg_pub.add;
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	       print_debuginfo(fnd_message.get_string('IBY',p_field)|| ' is a required parameter.');
       END IF;
       RAISE fnd_api.g_exc_error;
   END IF;


   --Validate Currency
   IF (UPPER(p_field) = 'CURRENCY') THEN
      OPEN c_validate_currency(p_value);
      FETCH c_validate_currency INTO l_temp;
      CLOSE c_validate_currency;

      IF (l_temp IS NULL) THEN
         fnd_message.set_name('IBY', 'IBY_INVALID_CURRENCY');
         fnd_message.set_token('CURRENCY_CODE', p_field);
         fnd_msg_pub.add;
         RAISE fnd_api.g_exc_error;
      END IF;

   END IF;
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	   print_debuginfo('Checked mandatory field : ' || p_field || ' : ' || p_value);
   END IF;
   END check_mandatory;

  /*=======================================================================+
   | PRIVATE PROCEDURE print_debuginfo                                     |
   |                                                                       |
   | DESCRIPTION                                                           |
   |   Get the party_id and country of the bank given a bank_branch_id.    |
   |                                                                       |
   | EXTERNAL PROCEDURES/FUNCTIONS ACCESSED                                |
   |                                                                       |
   | MODIFICATION HISTORY                                                  |
   |   08-SEP-2004    Nilanshu Mukerje      Created.                       |
   +=======================================================================*/
  PROCEDURE print_debuginfo(
    p_message                               IN     VARCHAR2,
    p_prefix                                IN     VARCHAR2,
    p_msg_level                             IN     NUMBER,
    p_module                                IN     VARCHAR2
  ) IS

   l_message                               VARCHAR2(4000);
   l_module                                VARCHAR2(255);

  BEGIN

--    DBMS_OUTPUT.PUT_LINE(substr(RPAD(p_module,55)||' : '||p_message, 0, 150));
--     insert into ying_debug(log_time, text)  values(sysdate, p_message);

     -- Debug info.
       l_module  :=SUBSTRB(p_module,1,255);

       IF p_prefix IS NOT NULL THEN
          l_message :=SUBSTRB(p_prefix||'-'||p_message,1,4000);
       ELSE
          l_message :=SUBSTRB(p_message,1,4000);
       END IF;
    IF p_msg_level>=fnd_log.g_current_runtime_level THEN

     FND_LOG.STRING(p_msg_level,l_module,l_message);

    END IF;

  END print_debuginfo;

  --
  -- USE: Gets the bank account instrument encryption mode
  --
  FUNCTION Get_BA_Encrypt_Mode
  RETURN iby_sys_security_options.ext_ba_encryption_mode%TYPE
  IS

    l_mode iby_sys_security_options.ext_ba_encryption_mode%TYPE;

    CURSOR c_encrypt_mode
    IS
      SELECT ext_ba_encryption_mode
      FROM iby_sys_security_options;

  BEGIN
    IF (c_encrypt_mode%ISOPEN) THEN CLOSE c_encrypt_mode; END IF;

    OPEN c_encrypt_mode;
    FETCH c_encrypt_mode INTO l_mode;
    CLOSE c_encrypt_mode;

    RETURN l_mode;
  END Get_BA_Encrypt_Mode;

  FUNCTION Mask_Bank_Number( p_bank_number IN VARCHAR2 ) RETURN VARCHAR2
  IS
    lx_mask_option    iby_ext_bank_accounts.ba_mask_setting%TYPE;
    lx_unmask_len     iby_ext_bank_accounts.ba_unmask_length%TYPE;
  BEGIN
    Get_Mask_Settings(lx_mask_option,lx_unmask_len);
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('The value of lx_mask_option :' ||lx_mask_option);
	    print_debuginfo('The value of lx_unmask_len :'|| lx_unmask_len);
    END IF;
    RETURN Mask_Bank_Number(p_bank_number,lx_mask_option,lx_unmask_len);
  END Mask_Bank_Number;

  FUNCTION Mask_Bank_Number
  (p_bank_number     IN   VARCHAR2,
   p_mask_option     IN   iby_ext_bank_accounts.ba_mask_setting%TYPE,
   p_unmask_len      IN   iby_ext_bank_accounts.ba_unmask_length%TYPE
  )
  RETURN VARCHAR2
  IS
  BEGIN
    RETURN iby_security_pkg.Mask_Data
           (p_bank_number,p_mask_option,p_unmask_len,G_MASK_CHARACTER);
  END Mask_Bank_Number;

  PROCEDURE Compress_Bank_Number
  (p_bank_number  IN VARCHAR2,
   p_mask_setting IN iby_sys_security_options.ext_ba_mask_setting%TYPE,
   p_unmask_len   IN iby_sys_security_options.ext_ba_unmask_len%TYPE,
   x_compress_num OUT NOCOPY VARCHAR2,
   x_unmask_digits OUT NOCOPY VARCHAR2
  )
  IS
    l_prefix_index    NUMBER;
    l_unmask_len      NUMBER;
    l_substr_start    NUMBER;
    l_substr_stop     NUMBER;
  BEGIN
    x_unmask_digits :=
      iby_security_pkg.Get_Unmasked_Data
      (p_bank_number,p_mask_setting,p_unmask_len);
    l_unmask_len := NVL(LENGTH(x_unmask_digits),0);

    -- all digits exposed; compressed number is trivial
    IF (l_unmask_len >= LENGTH(p_bank_number)) THEN
      x_compress_num := NULL;
      RETURN;
    END IF;

    IF ( (p_mask_setting = iby_security_pkg.G_MASK_POSTFIX) )
    THEN
      l_substr_start := l_unmask_len + 1;
    ELSE
      l_substr_start := 1;
    END IF;

    IF (p_mask_setting = iby_security_pkg.G_MASK_PREFIX)
       AND (p_unmask_len>0)
    THEN
      l_substr_stop := GREATEST(LENGTH(p_bank_number)-p_unmask_len,0);
    ELSE
      l_substr_stop := LENGTH(p_bank_number);
    END IF;

    IF (l_substr_start < (l_substr_stop +1)) THEN
      x_compress_num := SUBSTR(p_bank_number,l_substr_start,
                               l_substr_stop - l_substr_start + 1);
    ELSE
      x_compress_num := NULL;
    END IF;
  END Compress_Bank_Number;

  FUNCTION Uncipher_Bank_Number
  (p_unmask_digits  IN   VARCHAR2,
   p_segment_id     IN   iby_security_segments.sec_segment_id%TYPE,
   p_sys_key        IN   iby_security_pkg.DES3_KEY_TYPE,
   p_sub_key_cipher IN   iby_sys_security_subkeys.subkey_cipher_text%TYPE,
   p_segment_cipher IN   iby_security_segments.segment_cipher_text%TYPE,
   p_encoding       IN   iby_security_segments.encoding_scheme%TYPE,
   p_mask_option    IN   iby_ext_bank_accounts.ba_mask_setting%TYPE,
   p_unmask_len     IN   iby_ext_bank_accounts.ba_unmask_length%TYPE
  )
  RETURN VARCHAR2
  IS
    l_sub_key         iby_sys_security_subkeys.subkey_cipher_text%TYPE;
    l_bank_segment    iby_security_segments.segment_cipher_text%TYPE;
    l_bank_num        VARCHAR2(200);
  BEGIN

    IF (p_segment_id IS NULL) THEN RETURN p_unmask_digits; END IF;

    -- uncipher the subkey
    l_sub_key := iby_security_pkg.get_sys_subkey(p_sys_key,p_sub_key_cipher);

    -- uncipher the segment
    l_bank_segment :=
        dbms_obfuscation_toolkit.des3decrypt
        ( input =>  p_segment_cipher, key => l_sub_key,
          which => dbms_obfuscation_toolkit.ThreeKeyMode
        );
    l_bank_segment := IBY_SECURITY_PKG.PKCS5_UNPAD(l_bank_segment);
    l_bank_num := UTL_I18N.RAW_TO_CHAR(l_bank_segment,p_encoding);

    IF (NOT p_unmask_digits IS NULL) THEN
      IF (p_mask_option = iby_security_pkg.G_MASK_POSTFIX) THEN
        l_bank_num := p_unmask_digits || l_bank_num;
      ELSIF (p_mask_option = iby_security_pkg.G_MASK_PREFIX) THEN
        l_bank_num := l_bank_num || p_unmask_digits;
      END IF;
    END IF;

    RETURN l_bank_num;
  END Uncipher_Bank_Number;

  PROCEDURE Remask_Accounts
  (p_commit      IN     VARCHAR2 := FND_API.G_TRUE,
   p_sys_key     IN     iby_security_pkg.DES3_KEY_TYPE
  )
  IS
    lx_mask_option    iby_ext_bank_accounts.ba_mask_setting%TYPE;
    lx_unmask_len     iby_ext_bank_accounts.ba_unmask_length%TYPE;
    l_mode            iby_sys_security_options.ext_ba_encryption_mode%TYPE;
    lx_key_error      VARCHAR2(300);

    l_ba_num          iby_ext_bank_accounts.bank_account_num%TYPE;
    l_iban            iby_ext_bank_accounts.iban%TYPE;
    lx_compress_num   iby_ext_bank_accounts.bank_account_num%TYPE;

    lx_ba_unmask_digits iby_ext_bank_accounts.bank_account_num%TYPE;
    l_ba_segment      iby_security_segments.segment_cipher_text%TYPE;
    lx_ba_segment_id  iby_ext_bank_accounts.ba_num_sec_segment_id%TYPE;

    lx_iban_unmask_digits iby_ext_bank_accounts.iban%TYPE;
    l_iban_segment    iby_security_segments.segment_cipher_text%TYPE;
    lx_iban_segment_id iby_ext_bank_accounts.ba_num_sec_segment_id%TYPE;

    l_dbg_mod      VARCHAR2(100) := G_DEBUG_MODULE || '.Remask_Accounts';

    CURSOR c_ext_ba
    (ci_mask_option   iby_ext_bank_accounts.ba_mask_setting%TYPE,
     ci_unmask_len    iby_ext_bank_accounts.ba_unmask_length%TYPE
    )
    IS
      SELECT b.ext_bank_account_id, b.bank_account_num, b.iban,
        b.ba_num_sec_segment_id, bak.subkey_cipher_text ba_subkey_cipher,
        bas.segment_cipher_text ba_segment_cipher,
        bas.encoding_scheme ba_encoding,
        b.iban_sec_segment_id, ibk.subkey_cipher_text iban_subkey_cipher,
        ibs.segment_cipher_text iban_segment_cipher,
        ibs.encoding_scheme iban_encoding,
        b.ba_mask_setting, b.ba_unmask_length
      FROM iby_ext_bank_accounts b, iby_sys_security_subkeys bak,
        iby_sys_security_subkeys ibk, iby_security_segments bas,
        iby_security_segments ibs
      WHERE
        ( (NVL(ba_unmask_length,-1) <> ci_unmask_len) OR
          (NVL(ba_mask_setting,' ') <> ci_mask_option) )
        AND (b.ba_num_sec_segment_id = bas.sec_segment_id(+))
        AND (bas.sec_subkey_id = bak.sec_subkey_id(+))
        AND (b.iban_sec_segment_id = ibs.sec_segment_id(+))
        AND (ibs.sec_subkey_id = ibk.sec_subkey_id(+));

  BEGIN
    iby_debug_pub.add('Enter',iby_debug_pub.G_LEVEL_PROCEDURE,l_dbg_mod);

    IF (c_ext_ba%ISOPEN) THEN CLOSE c_ext_ba; END IF;

    Get_Mask_Settings(lx_mask_option,lx_unmask_len);

    iby_debug_pub.add('masking option:=' || lx_mask_option,
      iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
    iby_debug_pub.add('unmask length:=' || lx_unmask_len,
      iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);

    iby_security_pkg.Validate_Sys_Key(p_sys_key,lx_key_error);
    l_mode := Get_BA_Encrypt_Mode();

    iby_debug_pub.add('sys key check:=' || lx_key_error,
      iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);

    FOR ext_ba_rec IN c_ext_ba(lx_mask_option,lx_unmask_len) LOOP
      l_ba_num := NULL;
      l_iban := NULL;
      lx_compress_num := NULL;
      lx_ba_unmask_digits := NULL;
      lx_iban_unmask_digits := NULL;
      l_ba_segment := NULL;
      l_iban_segment := NULL;
      lx_ba_segment_id := NULL;
      lx_iban_segment_id := NULL;

      iby_debug_pub.add('bank account:=' || ext_ba_rec.ext_bank_account_id,
        iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);

      IF ( ((NOT ext_ba_rec.ba_num_sec_segment_id IS NULL) OR
            (NOT ext_ba_rec.iban_sec_segment_id IS NULL)
           ) AND (NOT lx_key_error IS NULL) )
      THEN
        raise_application_error(-20000,lx_key_error, FALSE);
      END IF;

      l_ba_num := Uncipher_Bank_Number(ext_ba_rec.bank_account_num,
                                       ext_ba_rec.ba_num_sec_segment_id,
                                       p_sys_key,
                                       ext_ba_rec.ba_subkey_cipher,
                                       ext_ba_rec.ba_segment_cipher,
                                       ext_ba_rec.ba_encoding,
                                       ext_ba_rec.ba_mask_setting,
                                       ext_ba_rec.ba_unmask_length);
      l_iban := Uncipher_Bank_Number(ext_ba_rec.iban,
                                     ext_ba_rec.iban_sec_segment_id,
                                     p_sys_key,
                                     ext_ba_rec.iban_subkey_cipher,
                                     ext_ba_rec.iban_segment_cipher,
                                     ext_ba_rec.iban_encoding,
                                     ext_ba_rec.ba_mask_setting,
                                     ext_ba_rec.ba_unmask_length);

      IF (NOT ext_ba_rec.ba_num_sec_segment_id IS NULL)
        OR (NOT ext_ba_rec.iban_sec_segment_id IS NULL)
      THEN

        iby_debug_pub.add('encrypted bank account data',
          iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);
        Compress_Bank_Number
        (l_ba_num,lx_mask_option,lx_unmask_len,lx_compress_num,
         lx_ba_unmask_digits);

        IF (NOT lx_compress_num IS NULL) THEN
          l_ba_segment :=
            UTL_I18N.STRING_TO_RAW
            (lx_compress_num,iby_security_pkg.G_ENCODING_UTF8_AL32);
          l_ba_segment := IBY_SECURITY_PKG.PKCS5_PAD(l_ba_segment);

          IF (ext_ba_rec.ba_num_sec_segment_id IS NULL) THEN
            IBY_SECURITY_PKG.Create_Segment
            (FND_API.G_FALSE,l_ba_segment,
             iby_security_pkg.G_ENCODING_UTF8_AL32,
             p_sys_key,lx_ba_segment_id);
          ELSE
            lx_ba_segment_id := ext_ba_rec.ba_num_sec_segment_id;
            IBY_SECURITY_PKG.Update_Segment
            (FND_API.G_FALSE,lx_ba_segment_id,l_ba_segment,
             iby_security_pkg.G_ENCODING_UTF8_AL32,p_sys_key,
             ext_ba_rec.ba_subkey_cipher);
          END IF;
        ELSE
          DELETE FROM iby_security_segments
          WHERE sec_segment_id = ext_ba_rec.ba_num_sec_segment_id;
        END IF;

        Compress_Bank_Number
        (l_iban,lx_mask_option,lx_unmask_len,lx_compress_num,
         lx_iban_unmask_digits);

        IF (NOT lx_compress_num IS NULL) THEN
          l_iban_segment :=
            UTL_I18N.STRING_TO_RAW
            (lx_compress_num,iby_security_pkg.G_ENCODING_UTF8_AL32);
          l_iban_segment := IBY_SECURITY_PKG.PKCS5_PAD(l_iban_segment);

          IF (ext_ba_rec.iban_sec_segment_id IS NULL) THEN
            IBY_SECURITY_PKG.Create_Segment
            (FND_API.G_FALSE,l_iban_segment,
             iby_security_pkg.G_ENCODING_UTF8_AL32,p_sys_key,
             lx_iban_segment_id);
          ELSE
            lx_iban_segment_id := ext_ba_rec.iban_sec_segment_id;
            IBY_SECURITY_PKG.Update_Segment
            (FND_API.G_FALSE,lx_iban_segment_id,l_iban_segment,
             iby_security_pkg.G_ENCODING_UTF8_AL32,p_sys_key,
             ext_ba_rec.iban_subkey_cipher);
          END IF;
        ELSE
          DELETE FROM iby_security_segments
          WHERE sec_segment_id = ext_ba_rec.iban_sec_segment_id;
        END IF;

      ELSE
        iby_debug_pub.add('unencrypted bank account data',
          iby_debug_pub.G_LEVEL_INFO,l_dbg_mod);

        lx_ba_unmask_digits := l_ba_num;
        lx_iban_unmask_digits := l_iban;

        DELETE FROM iby_security_segments
        WHERE sec_segment_id = ext_ba_rec.ba_num_sec_segment_id;
        DELETE FROM iby_security_segments
        WHERE sec_segment_id = ext_ba_rec.iban_sec_segment_id;
      END IF;

      UPDATE iby_ext_bank_accounts
      SET
        bank_account_num = lx_ba_unmask_digits,
        ba_num_sec_segment_id = lx_ba_segment_id,
        iban = lx_iban_unmask_digits,
        iban_sec_segment_id = lx_iban_segment_id,
        masked_bank_account_num =
          Mask_Bank_Number(l_ba_num,lx_mask_option,lx_unmask_len),
        masked_iban = Mask_Bank_Number(l_iban,lx_mask_option,lx_unmask_len),
        ba_mask_setting = lx_mask_option,
        ba_unmask_length = lx_unmask_len,
        encrypted = DECODE(l_mode, iby_security_pkg.G_ENCRYPT_MODE_NONE,'N',
                                   'Y'
                          ),
        object_version_number = object_version_number + 1,
        last_update_date = sysdate,
        last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.login_id
      WHERE (ext_bank_account_id = ext_ba_rec.ext_bank_account_id);

    END LOOP;

    IF FND_API.to_Boolean( p_commit ) THEN
      COMMIT;
    END IF;

    iby_debug_pub.add('Exit',iby_debug_pub.G_LEVEL_PROCEDURE,l_dbg_mod);
  END Remask_Accounts;

  PROCEDURE Encrypt_Accounts
  (p_commit      IN     VARCHAR2,
   p_sys_key     IN     iby_security_pkg.DES3_KEY_TYPE
  )
  IS
    l_mode            iby_sys_security_options.ext_ba_encryption_mode%TYPE;
    lx_key_error      VARCHAR2(300);

    lx_compress_num   iby_ext_bank_accounts.bank_account_num%TYPE;

    lx_ba_unmask_digits iby_ext_bank_accounts.bank_account_num%TYPE;
    l_ba_segment      iby_security_segments.segment_cipher_text%TYPE;
    lx_ba_segment_id  iby_ext_bank_accounts.ba_num_sec_segment_id%TYPE;

    lx_iban_unmask_digits iby_ext_bank_accounts.iban%TYPE;
    l_iban_segment    iby_security_segments.segment_cipher_text%TYPE;
    lx_iban_segment_id iby_ext_bank_accounts.ba_num_sec_segment_id%TYPE;

    lx_e_ba_unmask_digits iby_ext_bank_accounts.bank_account_num_electronic%TYPE;
    l_e_ba_segment    iby_security_segments.segment_cipher_text%TYPE;
    lx_e_ba_segment_id iby_ext_bank_accounts.ba_num_elec_sec_segment_id%TYPE;

    CURSOR c_ext_ba
    IS
      SELECT b.ext_bank_account_id, b.bank_account_num, b.iban,
        b.ba_num_sec_segment_id, b.iban_sec_segment_id,
        b.bank_account_num_electronic, b.ba_num_elec_sec_segment_id,
        b.ba_mask_setting, b.ba_unmask_length
      FROM iby_ext_bank_accounts b
      WHERE (NVL(b.encrypted,'N') = 'N');

  BEGIN

    l_mode := Get_BA_Encrypt_Mode();
    IF (l_mode = iby_security_pkg.G_ENCRYPT_MODE_NONE) THEN
      RETURN;
    END IF;

    iby_security_pkg.Validate_Sys_Key(p_sys_key,lx_key_error);
    IF (NOT lx_key_error IS NULL) THEN
      raise_application_error(-20000,lx_key_error, FALSE);
    END IF;

    FOR ext_ba_rec IN c_ext_ba LOOP
      lx_ba_unmask_digits := NULL;
      lx_iban_unmask_digits := NULL;
      lx_ba_segment_id := NULL;
      lx_iban_segment_id := NULL;
      lx_e_ba_unmask_digits := NULL;
      lx_e_ba_segment_id := NULL;

      -- only one of bank acocunt number, IBAN number may be unencrypted
      -- thanks to update of only one of these values

      IF (ext_ba_rec.ba_num_sec_segment_id IS NULL)
        AND (NOT ext_ba_rec.bank_account_num IS NULL)
      THEN
        Compress_Bank_Number
        (ext_ba_rec.bank_account_num,ext_ba_rec.ba_mask_setting,
         ext_ba_rec.ba_unmask_length,lx_compress_num,lx_ba_unmask_digits);

        IF (NOT lx_compress_num IS NULL) THEN
          l_ba_segment :=
            UTL_I18N.STRING_TO_RAW
            (lx_compress_num,iby_security_pkg.G_ENCODING_UTF8_AL32);
          -- pad to unit 8 length
          l_ba_segment := IBY_SECURITY_PKG.PKCS5_PAD(l_ba_segment);

          IBY_SECURITY_PKG.Create_Segment
          (FND_API.G_FALSE,l_ba_segment,iby_security_pkg.G_ENCODING_UTF8_AL32,
           p_sys_key,lx_ba_segment_id);
        END IF;
      ELSE
        lx_ba_unmask_digits := ext_ba_rec.bank_account_num;
      END IF;

      IF (ext_ba_rec.iban_sec_segment_id IS NULL)
        AND (NOT ext_ba_rec.iban IS NULL)
      THEN
        Compress_Bank_Number
        (ext_ba_rec.iban,ext_ba_rec.ba_mask_setting,
         ext_ba_rec.ba_unmask_length,lx_compress_num,lx_iban_unmask_digits);

        IF (NOT lx_compress_num IS NULL) THEN
          l_iban_segment :=
            UTL_I18N.STRING_TO_RAW
            (lx_compress_num,iby_security_pkg.G_ENCODING_UTF8_AL32);
          -- pad to unit 8 length
          l_iban_segment := IBY_SECURITY_PKG.PKCS5_PAD(l_iban_segment);

          IBY_SECURITY_PKG.Create_Segment
          (FND_API.G_FALSE,l_iban_segment,
           iby_security_pkg.G_ENCODING_UTF8_AL32,p_sys_key,lx_iban_segment_id);
        END IF;
      ELSE
        lx_iban_unmask_digits := ext_ba_rec.iban;
      END IF;

      IF (ext_ba_rec.ba_num_elec_sec_segment_id IS NULL)
        AND (NOT ext_ba_rec.bank_account_num_electronic IS NULL)
      THEN
        lx_e_ba_unmask_digits := NULL;
        l_e_ba_segment :=
          UTL_I18N.STRING_TO_RAW
          (ext_ba_rec.bank_account_num_electronic,
           iby_security_pkg.G_ENCODING_UTF8_AL32);
        -- pad to unit 8 length
        l_e_ba_segment := IBY_SECURITY_PKG.PKCS5_PAD(l_e_ba_segment);

        IBY_SECURITY_PKG.Create_Segment
        (FND_API.G_FALSE,l_e_ba_segment,
         iby_security_pkg.G_ENCODING_UTF8_AL32,p_sys_key,lx_e_ba_segment_id);
      ELSE
        lx_e_ba_unmask_digits := ext_ba_rec.bank_account_num_electronic;
      END IF;

      UPDATE iby_ext_bank_accounts
      SET
        bank_account_num = lx_ba_unmask_digits,
        iban = lx_iban_unmask_digits,
        ba_num_sec_segment_id = NVL(lx_ba_segment_id,ba_num_sec_segment_id),
        iban_sec_segment_id = NVL(lx_iban_segment_id,iban_sec_segment_id),
        bank_account_num_electronic = lx_e_ba_unmask_digits,
        ba_num_elec_sec_segment_id =
          NVL(lx_e_ba_segment_id,ba_num_elec_sec_segment_id),
        encrypted = 'Y'
      WHERE (ext_bank_account_id = ext_ba_rec.ext_bank_account_id);
    END LOOP;

    IF FND_API.to_Boolean( p_commit ) THEN
      COMMIT;
    END IF;
  END Encrypt_Accounts;

  PROCEDURE Decrypt_Accounts
  (p_commit      IN     VARCHAR2,
   p_sys_key     IN     iby_security_pkg.DES3_KEY_TYPE
  )
  IS
    l_mode            iby_sys_security_options.ext_ba_encryption_mode%TYPE;
    l_subkey          iby_sys_security_subkeys.subkey_cipher_text%TYPE;
    l_ba_num          iby_ext_bank_accounts.bank_account_num%TYPE;
    l_iban            iby_ext_bank_accounts.iban%TYPE;
    l_e_ba            iby_ext_bank_accounts.bank_account_num_electronic%TYPE;

    lx_key_error      VARCHAR2(300);

    CURSOR c_ext_ba
    IS
      SELECT b.ext_bank_account_id, b.bank_account_num, b.iban,
        b.bank_account_num_electronic,
        b.ba_num_sec_segment_id, bak.subkey_cipher_text ba_subkey_cipher,
        bas.segment_cipher_text ba_segment_cipher,
        bas.encoding_scheme ba_encoding,
        b.iban_sec_segment_id, ibk.subkey_cipher_text iban_subkey_cipher,
        ibs.segment_cipher_text iban_segment_cipher,
        ibs.encoding_scheme iban_encoding,
        b.ba_num_elec_sec_segment_id,
        ebk.subkey_cipher_text e_ba_subkey_cipher,
        ebs.segment_cipher_text e_ba_segment_cipher,
        ebs.encoding_scheme e_ba_encoding,
        b.ba_mask_setting, b.ba_unmask_length
      FROM iby_ext_bank_accounts b, iby_sys_security_subkeys bak,
        iby_sys_security_subkeys ebk, iby_sys_security_subkeys ibk,
        iby_security_segments bas, iby_security_segments ibs,
        iby_security_segments ebs
      WHERE
        ((NOT ba_num_sec_segment_id IS NULL) OR (NOT iban_sec_segment_id IS NULL))
        AND (b.ba_num_sec_segment_id = bas.sec_segment_id(+))
        AND (bas.sec_subkey_id = bak.sec_subkey_id(+))
        AND (b.iban_sec_segment_id = ibs.sec_segment_id(+))
        AND (ibs.sec_subkey_id = ibk.sec_subkey_id(+))
        AND (b.ba_num_elec_sec_segment_id = ebs.sec_segment_id(+))
        AND (ebs.sec_subkey_id = ebk.sec_subkey_id(+));

  BEGIN

    l_mode := Get_BA_Encrypt_Mode();
    IF (NOT (l_mode = iby_security_pkg.G_ENCRYPT_MODE_NONE)) THEN
      RETURN;
    END IF;

    iby_security_pkg.Validate_Sys_Key(p_sys_key,lx_key_error);

    FOR ext_ba_rec IN c_ext_ba LOOP

      -- raise sys-key exception only if encrypted data exists
      IF (NOT lx_key_error IS NULL) THEN
        raise_application_error(-20000,lx_key_error, FALSE);
      END IF;

      l_ba_num := NULL;
      l_iban := NULL;
      l_e_ba := NULL;

      IF (NOT ext_ba_rec.ba_num_sec_segment_id IS NULL) THEN
        l_ba_num := Uncipher_Bank_Number(ext_ba_rec.bank_account_num,
                                         ext_ba_rec.ba_num_sec_segment_id,
                                         p_sys_key,
                                         ext_ba_rec.ba_subkey_cipher,
                                         ext_ba_rec.ba_segment_cipher,
                                         ext_ba_rec.ba_encoding,
                                         ext_ba_rec.ba_mask_setting,
                                         ext_ba_rec.ba_unmask_length);
      END IF;

      IF (NOT ext_ba_rec.iban_sec_segment_id IS NULL) THEN
        l_iban := Uncipher_Bank_Number(ext_ba_rec.iban,
                                       ext_ba_rec.iban_sec_segment_id,
                                       p_sys_key,
                                       ext_ba_rec.iban_subkey_cipher,
                                       ext_ba_rec.iban_segment_cipher,
                                       ext_ba_rec.iban_encoding,
                                       ext_ba_rec.ba_mask_setting,
                                       ext_ba_rec.ba_unmask_length);
      END IF;


      IF (NOT ext_ba_rec.ba_num_elec_sec_segment_id IS NULL) THEN
        l_e_ba := Uncipher_Bank_Number(ext_ba_rec.bank_account_num_electronic,
                                       ext_ba_rec.ba_num_elec_sec_segment_id,
                                       p_sys_key,
                                       ext_ba_rec.e_ba_subkey_cipher,
                                       ext_ba_rec.e_ba_segment_cipher,
                                       ext_ba_rec.e_ba_encoding,
                                       ext_ba_rec.ba_mask_setting,
                                       ext_ba_rec.ba_unmask_length);
      END IF;

      UPDATE iby_ext_bank_accounts
      SET
        bank_account_num = NVL(l_ba_num,bank_account_num),
        iban = NVL(l_iban,iban),
        bank_account_num_electronic = NVL(l_e_ba,bank_account_num_electronic),
        ba_num_sec_segment_id = NULL,
        iban_sec_segment_id = NULL,
        ba_num_elec_sec_segment_id = NULL,
        encrypted = 'N',
        object_version_number = object_version_number + 1,
        last_update_date = sysdate,
        last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.login_id
      WHERE (ext_bank_account_id = ext_ba_rec.ext_bank_account_id);

      DELETE FROM iby_security_segments
      WHERE sec_segment_id = ext_ba_rec.ba_num_sec_segment_id;
      DELETE FROM iby_security_segments
      WHERE sec_segment_id = ext_ba_rec.iban_sec_segment_id;
      DELETE FROM iby_security_segments
      WHERE sec_segment_id = ext_ba_rec.ba_num_elec_sec_segment_id;

    END LOOP;

    IF FND_API.to_Boolean( p_commit ) THEN
      COMMIT;
    END IF;
  END Decrypt_Accounts;

  --
  -- USE: Get bank account mask settings
  --
  PROCEDURE Get_Mask_Settings
  (x_mask_setting  OUT NOCOPY iby_sys_security_options.ext_ba_mask_setting%TYPE,
   x_unmask_len    OUT NOCOPY iby_sys_security_options.ext_ba_unmask_len%TYPE
  )
  IS

    CURSOR c_mask_setting
    IS
      SELECT ext_ba_mask_setting, ext_ba_unmask_len
      FROM iby_sys_security_options;

  BEGIN
    x_mask_setting := iby_security_pkg.G_MASK_PREFIX;

    IF (c_mask_setting%ISOPEN) THEN CLOSE c_mask_setting; END IF;

    OPEN c_mask_setting;
    FETCH c_mask_setting INTO x_mask_setting, x_unmask_len;
    CLOSE c_mask_setting;

    IF (x_mask_setting IS NULL) THEN
      x_mask_setting := iby_security_pkg.G_MASK_PREFIX;
    END IF;
    IF (x_unmask_len IS NULL) THEN
      x_unmask_len := G_DEF_UNMASK_LENGTH;
    END IF;
  END Get_Mask_Settings;

  --FSIO Code
  PROCEDURE vendor_id(p_party_id IN VARCHAR2,
                      x_vendor_id OUT NOCOPY NUMBER) IS
  BEGIN
    SELECT vendor_id
    INTO x_vendor_id
    FROM ap_suppliers
    WHERE party_id = p_party_id
    AND rownum = 1;

  EXCEPTION
    WHEN no_data_found THEN
      x_vendor_id := -999;
    WHEN others then
      x_vendor_id := -999;
  END vendor_id;
  --End of FSIO


  FUNCTION find_assignment_OU
  ( p_ext_bank_acct_id IN iby_ext_bank_accounts.ext_bank_account_id%TYPE
  )
  RETURN NUMBER IS
     l_org_id NUMBER :=-1;
     l_api_name           CONSTANT VARCHAR2(30)   := 'find_assignment_OU';
     l_module_name        CONSTANT VARCHAR2(200)   := G_PKG_NAME || '.' || l_api_name;
  BEGIN
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('ENTER ' || l_module_name);
      END IF;
	    BEGIN
		SELECT org_id INTO l_org_id FROM iby_external_payees_all
		WHERE org_id IS NOT NULL AND org_type IS NOT null
		AND
		ext_payee_id IN(
		SELECT ext_pmt_party_id FROM IBY_PMT_INSTR_USES_ALL WHERE
		 PAYMENT_FLOW = 'DISBURSEMENTS'
		AND INSTRUMENT_TYPE = 'BANKACCOUNT'
		AND payment_function = 'PAYABLES_DISB'
		AND INSTRUMENT_ID = p_ext_bank_acct_id )
		AND MO_GLOBAL.CHECK_ACCESS(org_id) = 'Y'
		AND ROWNUM=1;
		EXCEPTION
			   WHEN no_data_found THEN
				       BEGIN
					SELECT org_id INTO l_org_id FROM iby_external_payees_all
					WHERE org_id IS NOT NULL AND org_type IS NOT null
					AND
					ext_payee_id IN(
					SELECT ext_pmt_party_id FROM IBY_PMT_INSTR_USES_ALL WHERE
					 PAYMENT_FLOW = 'DISBURSEMENTS'
					AND INSTRUMENT_TYPE = 'BANKACCOUNT'
					AND payment_function = 'PAYABLES_DISB'
					AND INSTRUMENT_ID = p_ext_bank_acct_id )
					AND ROWNUM=1;
				      EXCEPTION
					WHEN no_data_found THEN
					   l_org_id := -1;
					WHEN others THEN
					 -- This is not fatal error. Hence swallowing..
					       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
						    print_debuginfo('Non Fatal Exceptionn ' || l_module_name);
					      END IF;
					  NULL;
				      END;
			   WHEN others THEN
			   -- This is not fatal error. Hence swallowing..
			       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
				    print_debuginfo('Non Fatal Exception ' || l_module_name);
			      END IF;
			   NULL;
	     END;
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
	    print_debuginfo('Exit ' || l_module_name);
      END IF;
   RETURN l_org_id;
  END find_assignment_OU;



END iby_ext_bankacct_pub;

/
