--------------------------------------------------------
--  DDL for Package Body OZF_CLAIM_DEF_RULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_CLAIM_DEF_RULE_PVT" as
/* $Header: ozfvcdrb.pls 120.3 2007/12/18 10:53:09 kpatro noship $ */
G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_CLAIM_DEF_RULE_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozfvcdrs.pls';

PROCEDURE get_clam_def_rule(
    p_claim_rec               IN OZF_Claim_PVT.claim_rec_type,
    x_clam_def_rec_type       OUT NOCOPY clam_def_rec_type,
    x_return_status           OUT NOCOPY  VARCHAR2,
    x_msg_count               OUT NOCOPY  NUMBER,
    x_msg_data                OUT NOCOPY  VARCHAR2
)

is
L_API_NAME                  CONSTANT VARCHAR2(30) := 'get_clam_def_rule';
   l_claim_type_id number;
   l_reason_code_id number;
   l_custom_setup_id number;
   l_count_custom_setup number;

--  CURSOR c_clam_rule ( cv_claim_class VARCHAR2, cv_source_object VARCHAR2, cv_custsetup_id NUMBER) is
  CURSOR c_clam_rule ( cv_claim_class VARCHAR2, cv_source_object VARCHAR2) is
     SELECT claim_type_id, reason_code_id , custom_setup_id
     FROM  OZF_CLAIM_DEF_RULES
     WHERE CLAIM_CLASS = cv_claim_class
     AND ( ( SOURCE_OBJECT_CLASS is null AND cv_source_object is null )
         OR (SOURCE_OBJECT_CLASS = cv_source_object ) )
     AND ENABLED_FLAG = 'Y';

   CURSOR ozf_def_claim_id is
     select claim_type_id
     from ozf_sys_parameters;

   CURSOR ozf_def_reason_id is
     select reason_code_id
     from ozf_sys_parameters;

   CURSOR csr_seed_custom_setup(cv_custom_setup_id IN NUMBER) IS
     SELECT custom_setup_id
     FROM ams_custom_setups_vl
     WHERE application_id = 682
     AND enabled_flag = 'Y'
     AND custom_setup_id = cv_custom_setup_id;

   CURSOR csr_count_custom_setup(cv_claim_class IN VARCHAR2) IS
     SELECT COUNT(custom_setup_id)
     FROM ams_custom_setups_vl
     WHERE application_id = 682
     AND enabled_flag = 'Y'
     AND object_type = 'CLAM'
     AND activity_type_code = cv_claim_class;

   CURSOR csr_user_custom_setup(cv_claim_class IN VARCHAR2) IS
     SELECT custom_setup_id
     FROM ams_custom_setups_vl
     WHERE application_id = 682
     AND enabled_flag = 'Y'
     AND object_type = 'CLAM'
     AND activity_type_code = cv_claim_class;



BEGIN

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      FOR l_claim_rule_rec IN c_clam_rule(p_claim_rec.claim_class,
			p_claim_rec.source_object_class)


      LOOP
	l_claim_type_id := l_claim_rule_rec.claim_type_id;
	l_reason_code_id := l_claim_rule_rec.reason_code_id;
	l_custom_setup_id := l_claim_rule_rec.custom_setup_id;
      END LOOP;

  IF ( l_claim_type_id is null ) THEN
        OPEN ozf_def_claim_id;
	FETCH ozf_def_claim_id INTO l_claim_type_id;
	CLOSE ozf_def_claim_id;
   END IF;

   IF ( l_reason_code_id is null ) THEN
        OPEN ozf_def_reason_id;
	FETCH ozf_def_reason_id INTO l_reason_code_id;
	CLOSE ozf_def_reason_id;
   END IF;

   x_clam_def_rec_type.claim_type_id := l_claim_type_id;
   x_clam_def_rec_type.reason_code_id := l_reason_code_id;
   x_clam_def_rec_type.claim_class := p_claim_rec.claim_class;
   x_clam_def_rec_type.source_object_class := p_claim_rec.source_object_class;
   x_clam_def_rec_type.custom_setup_id := l_custom_setup_id;
-- 12.1 SDR Enhancement: Added the custom setup for SDR claim
  IF  ( l_custom_setup_id is null ) THEN
      IF (  p_claim_rec.claim_class = 'CLAIM' AND p_claim_rec.source_object_class = 'SD_INTERNAL') THEN
        OPEN csr_seed_custom_setup(2002);
        FETCH csr_seed_custom_setup INTO l_custom_setup_id;
        CLOSE csr_seed_custom_setup;
      ELSIF (  p_claim_rec.claim_class = 'CLAIM' AND p_claim_rec.source_object_class = 'SD_SUPPLIER') THEN
      OPEN csr_seed_custom_setup(2003);
        FETCH csr_seed_custom_setup INTO l_custom_setup_id;
        CLOSE csr_seed_custom_setup;
      ELSIF(  p_claim_rec.claim_class = 'CLAIM' ) THEN
        OPEN csr_seed_custom_setup(2001);
        FETCH csr_seed_custom_setup INTO l_custom_setup_id;
        CLOSE csr_seed_custom_setup;
      ELSIF (  p_claim_rec.claim_class = 'OVERPAYMENT' ) THEN
        OPEN csr_seed_custom_setup(190);
        FETCH csr_seed_custom_setup INTO l_custom_setup_id;
        CLOSE csr_seed_custom_setup;
      ELSIF (  p_claim_rec.claim_class = 'DEDUCTION' ) THEN
        OPEN csr_seed_custom_setup(160);
        FETCH csr_seed_custom_setup INTO l_custom_setup_id;
        CLOSE csr_seed_custom_setup;
      ELSIF (  p_claim_rec.claim_class = 'CHARGE' ) THEN
        OPEN csr_seed_custom_setup(210);
        FETCH csr_seed_custom_setup INTO l_custom_setup_id;
        CLOSE csr_seed_custom_setup;
      ELSIF (  p_claim_rec.claim_class = 'GROUP' ) THEN
        OPEN csr_seed_custom_setup(150);
        FETCH csr_seed_custom_setup INTO l_custom_setup_id;
        CLOSE csr_seed_custom_setup;
      ELSE
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
           FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_CLASS_ERROR');
           FND_MSG_PUB.add;
        END IF;
        RAISE FND_API.g_exc_error;
      END IF;

      IF l_custom_setup_id IS NULL THEN
         OPEN csr_count_custom_setup(p_claim_rec.claim_class);
         FETCH csr_count_custom_setup INTO l_count_custom_setup;
         CLOSE csr_count_custom_setup;

         IF l_count_custom_setup = 1 THEN
            OPEN csr_user_custom_setup(p_claim_rec.claim_class);
            FETCH csr_user_custom_setup INTO l_custom_setup_id;
            CLOSE csr_user_custom_setup;
         ELSE
            IF l_count_custom_setup > 1 THEN
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                  FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_CUSTSET_UP_NO_EXT');
                  FND_MSG_PUB.add;
               END IF;
            ELSE
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
                  FND_MESSAGE.set_name('OZF', 'OZF_CLAIM_CUSTSET_UP_NO_UK');
                  FND_MSG_PUB.add;
               END IF;
            END IF;
            RAISE FND_API.g_exc_error;
         END IF;
      END IF;
      x_clam_def_rec_type.custom_setup_id := l_custom_setup_id;
   END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );


END get_clam_def_rule;
END ozf_claim_def_rule_pvt;

/
