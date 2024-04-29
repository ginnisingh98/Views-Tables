--------------------------------------------------------
--  DDL for Package Body HZ_PARTY_INFO_VAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_PARTY_INFO_VAL" AS
/*$Header: ARHPTIVB.pls 120.4 2006/05/26 10:03:38 vravicha ship $ */


--------------------------------------
-- declaration of private global varibles
--------------------------------------

--G_DEBUG             BOOLEAN := FALSE;
g_debug_count       NUMBER := 0;

--------------------------------------
-- declaration of private procedures and functions
--------------------------------------

/*PROCEDURE enable_debug;

PROCEDURE disable_debug;
*/

--------------------------------------
-- private procedures and functions
--------------------------------------

  /**
   * PRIVATE PROCEDURE enable_debug
   *
   * DESCRIPTION
   *     Turn on debug mode.
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *     HZ_UTILITY_V2PUB.enable_debug
   *
   * MODIFICATION HISTORY
   *
   *   07-23-2001    Jianying Huang      o Created.
   *
   */

  /*PROCEDURE enable_debug IS

  BEGIN

      g_debug_count := g_debug_count + 1;

      IF g_debug_count = 1 THEN
          IF fnd_profile.value('HZ_API_FILE_DEBUG_ON') = 'Y' OR
             fnd_profile.value('HZ_API_DBMS_DEBUG_ON') = 'Y'
          THEN
             hz_utility_v2pub.enable_debug;
             g_debug := TRUE;
          END IF;
      END IF;

  END enable_debug;
  */

  /**
   * PRIVATE PROCEDURE disable_debug
   *
   * DESCRIPTION
   *     Turn off debug mode.
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *     hz_utility_v2pub.disable_debug
   *
   * MODIFICATION HISTORY
   *
   *   07-23-2001    Jianying Huang      o Created.
   *
   */

  /*PROCEDURE disable_debug IS

  BEGIN

      IF g_debug THEN
          g_debug_count := g_debug_count - 1;

          IF g_debug_count = 0 THEN
              hz_utility_v2pub.disable_debug;
              g_debug := FALSE;
          END IF;
      END IF;

  END disable_debug;
  */

/*======================================================================
 | PROCEDURE  (public)
 |              validate_credit_ratings
 |
 | DESCRIPTION
 |              Validates on:
 |                      mandatory columns
 |                      non-updateable fields
 |                      foreign key
 |                      lookup types
 |
 | ARGUMENTS  : IN:
 |                      p_emp_history_rec
 |                      create_update_flag
 |              OUT:
 |
 | RETURNS    : NONE
 |
 | MODIFICATION HISTORY
 |       YKONG     26-OCT-1999    Created
 |      02-AUG-2000  Jianying Huang  Fixed Bug 1363124: Validation#2
 |                     hz_credit_ratings.content_source_type
 |
 |       19-Feb-2002  DNB V3 enhancement base bug 2188696
 |                    check obsoleted column suit_judge_ind
 |                    validate colums migrated from hz_organization_profiles
 |      01-03-2005  Rajib Ranjan Borah   o SSM SST Integration and Extension.
 |                                         Modified call to HZ_MIXNM_UTILITY.
 |                                         ValidateContentSource according to
 |                                         modified signature
 +======================================================================*/

procedure validate_credit_ratings(
    p_credit_ratings_rec       IN     HZ_PARTY_INFO_PUB.credit_ratings_rec_type,
    p_create_update_flag       IN     VARCHAR2,
    x_return_status            IN OUT NOCOPY VARCHAR2
) IS

    l_dummy                    VARCHAR2(1);
    l_count                    NUMBER;
    l_party_id                 NUMBER;
    l_credit_score_commentary  VARCHAR2(30);
    l_credit_score_commentary2 VARCHAR2(30);
    l_credit_score_commentary3 VARCHAR2(30);
    l_credit_score_commentary4 VARCHAR2(30);
    l_credit_score_commentary5 VARCHAR2(30);
    l_credit_score_commentary6 VARCHAR2(30);
    l_credit_score_commentary7 VARCHAR2(30);
    l_credit_score_commentary8 VARCHAR2(30);
    l_credit_score_commentary9 VARCHAR2(30);
    l_credit_score_commentary10 VARCHAR2(30);
    l_suit_ind                 VARCHAR2(1);
    l_lien_ind                 VARCHAR2(1);
    l_judgement_ind            VARCHAR2(1);
    l_bankruptcy_ind           VARCHAR2(1);
    l_no_trade_ind             VARCHAR2(1);
    l_prnt_hq_bkcy_ind         VARCHAR2(1);
    l_credit_score_override_code  hz_credit_ratings.credit_score_override_code%TYPE;
    l_debarment_ind            VARCHAR2(1);
    l_maximum_credit_currency_code hz_credit_ratings.maximum_credit_currency_code%TYPE;

    db_content_source_type      hz_credit_ratings.content_source_type%TYPE;

    -- Bug 2197181: added for mix-n-match
    db_actual_content_source    hz_credit_ratings.actual_content_source%TYPE;
    l_debug_prefix		VARCHAR2(30) := '';

BEGIN

      --enable_debug;

      -- Debug info.
      IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'validate_credit_ratings (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
      END IF;

      IF FND_PROFILE.VALUE( 'HZ_API_ERR_ON_OBSOLETE_COLUMN' ) = 'Y' THEN

          IF ( p_create_update_flag = 'C' AND
                   p_credit_ratings_rec.suit_judge_ind IS NOT NULL AND
                   p_credit_ratings_rec.suit_judge_ind <> FND_API.G_MISS_CHAR )
           OR
                 ( p_create_update_flag = 'U' AND
                   ( p_credit_ratings_rec.suit_judge_ind is null OR
                     p_credit_ratings_rec.suit_judge_ind <> FND_API.G_MISS_CHAR
                 ) )
          THEN
                FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OBSOLETE_COLUMN' );
                FND_MESSAGE.SET_TOKEN( 'COLUMN', 'suit_judge_ind' );
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;
    END IF;

    -- mandatory fields: party_id,  content_source_type
    IF (p_create_update_flag = 'C' AND
        (p_credit_ratings_rec.party_id IS NULL  OR
         p_credit_ratings_rec.party_id =  FND_API.G_MISS_NUM))
       OR
       (p_create_update_flag = 'U'  AND
        p_credit_ratings_rec.party_id IS NULL)  THEN

        FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
        FND_MESSAGE.SET_TOKEN('COLUMN', 'party_id');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;

    END IF;

    -- Bug 2197181: removed validation for mix-n-match
/*
   IF (p_create_update_flag = 'C' AND
        (p_credit_ratings_rec.content_source_type IS NULL  OR
         p_credit_ratings_rec.content_source_type =  FND_API.G_MISS_CHAR))
       OR
       (p_create_update_flag = 'U'  AND
        p_credit_ratings_rec.content_source_type IS NULL)  THEN

        FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
        FND_MESSAGE.SET_TOKEN('COLUMN', 'content_source_type');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;

    END IF;
*/
    -- non updateable field

    IF (p_create_update_flag = 'U') THEN


    -- Bug 2197181: selecting actual_content_source for mix-n-match

    BEGIN
        SELECT party_id,
               content_source_type,
               suit_ind,
               lien_ind,
               judgement_ind,
               bankruptcy_ind,
               no_trade_ind,
               prnt_hq_bkcy_ind,
               credit_score_override_code,
               debarment_ind,
               credit_score_commentary,
               credit_score_commentary2,
               credit_score_commentary3,
               credit_score_commentary4,
               credit_score_commentary5,
               credit_score_commentary6,
               credit_score_commentary7,
               credit_score_commentary8,
               credit_score_commentary9,
               credit_score_commentary10,
               maximum_credit_currency_code,
               actual_content_source
        INTO   l_party_id,
               db_content_source_type,
               l_suit_ind,
               l_lien_ind,
               l_judgement_ind,
               l_bankruptcy_ind,
               l_no_trade_ind,
               l_prnt_hq_bkcy_ind,
               l_credit_score_override_code,
               l_debarment_ind,
               l_credit_score_commentary,
               l_credit_score_commentary2,
               l_credit_score_commentary3,
               l_credit_score_commentary4,
               l_credit_score_commentary5,
               l_credit_score_commentary6,
               l_credit_score_commentary7,
               l_credit_score_commentary8,
               l_credit_score_commentary9,
               l_credit_score_commentary10,
               l_maximum_credit_currency_code,
               db_actual_content_source
        FROM hz_credit_ratings
        where credit_rating_id = p_credit_ratings_rec.credit_rating_id;

        IF (p_credit_ratings_rec.party_id <> FND_API.G_MISS_NUM) AND
           (p_credit_ratings_rec.party_id <> l_party_id) THEN
              FND_MESSAGE.SET_NAME('AR', 'HZ_API_NONUPDATEABLE_COLUMN');
              FND_MESSAGE.SET_TOKEN('COLUMN', 'party_id');
              FND_MSG_PUB.ADD;
              x_return_status := FND_API.G_RET_STS_ERROR;
        end if;

        -- Bug 2197181: removed validation for mix-n-match
/*
        IF p_credit_ratings_rec.content_source_type <> l_content_source_type THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_NONUPDATEABLE_COLUMN');
                FND_MESSAGE.SET_TOKEN('COLUMN', 'content_source_type');
                FND_MSG_PUB.ADD;
                x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
*/

        EXCEPTION WHEN NO_DATA_FOUND THEN
          FND_MESSAGE.SET_NAME('AR', 'HZ_API_NO_RECORD');
          FND_MESSAGE.SET_TOKEN('RECORD', 'credit rating');
          FND_MESSAGE.SET_TOKEN('VALUE', to_char(p_credit_ratings_rec.credit_rating_id));
          FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
     END;

     END IF;

    -- foreign key : party_id to hz_parties

    IF (p_credit_ratings_rec.party_id is NOT NULL  AND
        p_credit_ratings_rec.party_id <> FND_API.G_MISS_NUM) THEN

        SELECT count(*)
        INTO l_count
        FROM hz_parties
        WHERE party_id = p_credit_ratings_rec.party_id;

        IF l_count = 0 THEN
                        FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_FK');
                        FND_MESSAGE.SET_TOKEN('FK', 'party_id');
                        FND_MESSAGE.SET_TOKEN('COLUMN', 'party_id');
                        FND_MESSAGE.SET_TOKEN('TABLE', 'hz_parties');
                        FND_MSG_PUB.ADD;
                        x_return_status := FND_API.G_RET_STS_ERROR;
         END IF;

    END IF;

    -- Bug 2197181: removed validation for mix-n-match
/*
--content_source_type validations.
--Bug 1363124: validation#2 of content_source_type

    hz_common_pub.validate_lookup(
        p_lookup_type   => 'CONTENT_SOURCE_TYPE',
        p_column        => 'content_source_type',
        p_column_value  => p_credit_ratings_rec.content_source_type,
        x_return_status => x_return_status
    );
*/

--Status Validation
    hz_common_pub.validate_lookup('REGISTRY_STATUS','status',p_credit_ratings_rec.status,x_return_status);


      -------------------------
      -- validate SUIT_IND
      -------------------------

      -- suit_ind is lookup code in lookup type YES/NO
      IF p_credit_ratings_rec.suit_ind IS NOT NULL
         AND
         p_credit_ratings_rec.suit_ind <> fnd_api.g_miss_char
         AND
         (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_credit_ratings_rec.suit_ind <> NVL(l_suit_ind, fnd_api.g_miss_char)
         )
        )
      THEN

          HZ_UTILITY_V2PUB.validate_lookup (
              p_column                                => 'suit_ind',
              p_lookup_type                           => 'YES/NO',
              p_column_value                          => p_credit_ratings_rec.suit_ind,
              x_return_status                         => x_return_status);

	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	     hz_utility_v2pub.debug(p_message=>'suit_ind should be in lookup YES/NO. ' ||
						'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	  END IF;
      END IF;

      -------------------------
      -- validate LIEN_IND
      -------------------------

      -- lien_ind is lookup code in lookup type YES/NO
      IF p_credit_ratings_rec.lien_ind IS NOT NULL
         AND
         p_credit_ratings_rec.lien_ind <> fnd_api.g_miss_char
         AND
         (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_credit_ratings_rec.lien_ind <> NVL(l_lien_ind, fnd_api.g_miss_char)
         )
        )
      THEN

          HZ_UTILITY_V2PUB.validate_lookup (
              p_column                                => 'lien_ind',
              p_lookup_type                           => 'YES/NO',
              p_column_value                          => p_credit_ratings_rec.lien_ind,
              x_return_status                         => x_return_status);

	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	     hz_utility_v2pub.debug(p_message=>'lien_ind should be in lookup YES/NO. ' ||
						'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	  END IF;
      END IF;

      -------------------------
      -- validate JUDGEMENT_IND
      -------------------------

      -- judgement_ind is lookup code in lookup type YES/NO
      IF p_credit_ratings_rec.judgement_ind IS NOT NULL
         AND
         p_credit_ratings_rec.judgement_ind <> fnd_api.g_miss_char
         AND
         (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_credit_ratings_rec.judgement_ind <> NVL(l_judgement_ind, fnd_api.g_miss_char)
         )
        )
      THEN

          HZ_UTILITY_V2PUB.validate_lookup (
              p_column                                => 'judgement_ind',
              p_lookup_type                           => 'YES/NO',
              p_column_value                          => p_credit_ratings_rec.judgement_ind,
              x_return_status                         => x_return_status);

	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug(p_message=>'judgement_ind should be in lookup YES/NO. ' ||
						   'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	  END IF;
      END IF;

      -------------------------
      -- validate BANKRUPTCY_IND
      -------------------------

      -- bankruptcy_ind is lookup code in lookup type YES/NO
      IF p_credit_ratings_rec.bankruptcy_ind IS NOT NULL
         AND
         p_credit_ratings_rec.bankruptcy_ind <> fnd_api.g_miss_char
         AND
         (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_credit_ratings_rec.bankruptcy_ind <> NVL(l_bankruptcy_ind, fnd_api.g_miss_char)
         )
        )
      THEN

          HZ_UTILITY_V2PUB.validate_lookup (
              p_column                                => 'bankruptcy_ind',
              p_lookup_type                           => 'YES/NO',
              p_column_value                          => p_credit_ratings_rec.bankruptcy_ind,
              x_return_status                         => x_return_status);

	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		hz_utility_v2pub.debug(p_message=>'bankruptcy_ind should be in lookup YES/NO. ' ||
						  'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	  END IF;
      END IF;

      -------------------------
      -- validate NO_TRADE_IND
      -------------------------

      -- no_trade_ind is lookup code in lookup type YES/NO
      IF p_credit_ratings_rec.no_trade_ind IS NOT NULL
         AND
         p_credit_ratings_rec.no_trade_ind <> fnd_api.g_miss_char
         AND
         (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_credit_ratings_rec.no_trade_ind <> NVL(l_no_trade_ind, fnd_api.g_miss_char)
         )
        )
      THEN

          HZ_UTILITY_V2PUB.validate_lookup (
              p_column                                => 'no_trade_ind',
              p_lookup_type                           => 'YES/NO',
              p_column_value                          => p_credit_ratings_rec.no_trade_ind,
              x_return_status                         => x_return_status);

	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	      hz_utility_v2pub.debug(p_message=>'no_trade_ind should be in lookup YES/NO. ' ||
						 'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	  END IF;
      END IF;
      -------------------------
      -- validate PRNT_HQ_BKCY_IND
      -------------------------

      -- prnt_hq_bkcy_ind is lookup code in PRNT_HQ_IND
      IF p_credit_ratings_rec.prnt_hq_bkcy_ind IS NOT NULL
         AND
         p_credit_ratings_rec.prnt_hq_bkcy_ind <> fnd_api.g_miss_char
         AND
         (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_credit_ratings_rec.prnt_hq_bkcy_ind <> NVL(l_prnt_hq_bkcy_ind, fnd_api.g_miss_char)
         )
        )
      THEN

          HZ_UTILITY_V2PUB.validate_lookup (
                p_column                                => 'prnt_hq_bkcy_ind',
                p_lookup_type                           => 'PRNT_HQ_IND',
                p_column_value                          => p_credit_ratings_rec.prnt_hq_bkcy_ind,
                x_return_status                         => x_return_status );

	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		hz_utility_v2pub.debug(p_message=>'prnt_hq_bkcy_ind should be in lookup PRNT_HQ_IND. ' ||
						  'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	  END IF;
      END IF;

      -------------------------
      -- validate CREDIT_SCORE_OVERRIDE_CODE
      -------------------------

      -- credit_score_override_code is lookup code in FAILURE_SCORE_OVERRIDE_CODE
      IF p_credit_ratings_rec.credit_score_override_code IS NOT NULL
         AND
         p_credit_ratings_rec.credit_score_override_code <> fnd_api.g_miss_char
         AND
         (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_credit_ratings_rec.credit_score_override_code <> NVL(l_credit_score_override_code, fnd_api.g_miss_char)
         )
        )
      THEN

          HZ_UTILITY_V2PUB.validate_lookup (
                  p_column                                => 'credit_score_override_code',
                  p_lookup_type                           => 'FAILURE_SCORE_OVERRIDE_CODE',
                  p_column_value                          => p_credit_ratings_rec.credit_score_override_code,
                  x_return_status                         => x_return_status );

	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'credit_score_override_code should be in lookup FAILURE_SCORE_OVERRIDE_CODE. ' ||
					     'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	 END IF;
      END IF;
      -------------------------
      -- validate debarment_ind
      -------------------------

      -- debarment_ind is lookup code in lookup type YES/NO
      IF p_credit_ratings_rec.debarment_ind IS NOT NULL
         AND
         p_credit_ratings_rec.debarment_ind <> fnd_api.g_miss_char
         AND
         (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_credit_ratings_rec.debarment_ind <> NVL(l_debarment_ind, fnd_api.g_miss_char)
         )
        )
      THEN

          HZ_UTILITY_V2PUB.validate_lookup (
              p_column                                => 'debarment_ind',
              p_lookup_type                           => 'YES/NO',
              p_column_value                          => p_credit_ratings_rec.debarment_ind,
              x_return_status                         => x_return_status);

	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug(p_message=>'debarment_ind should be in lookup YES/NO. ' ||
                  'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	  END IF;
      END IF;

      -----------------------------------
      -- validate credit_score_commentary
      -----------------------------------

      -- credit_score_commentary is lookup code in lookup type CREDIT_SCORE_COMMENTARY
      IF p_credit_ratings_rec.credit_score_commentary IS NOT NULL
         AND
         p_credit_ratings_rec.credit_score_commentary <> fnd_api.g_miss_char
         AND
         (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_credit_ratings_rec.credit_score_commentary <> NVL(l_credit_score_commentary, fnd_api.g_miss_char)
         )
        )
      THEN

          HZ_UTILITY_V2PUB.validate_lookup (
              p_column                                => 'credit_score_commentary',
              p_lookup_type                           => 'CREDIT_SCORE_COMMENTARY',
              p_column_value                          => p_credit_ratings_rec.credit_score_commentary,
              x_return_status                         => x_return_status);

	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		hz_utility_v2pub.debug(p_message=>'credit_score_commentary is lookup code in lookup type CREDIT_SCORE_COMMENTARY. ' ||
						  'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	  END IF;

      END IF;

      ------------------------------------
      -- validate credit_score_commentary2
      ------------------------------------

      -- credit_score_commentary is lookup code in lookup type CREDIT_SCORE_COMMENTARY
      IF p_credit_ratings_rec.credit_score_commentary2 IS NOT NULL
         AND
         p_credit_ratings_rec.credit_score_commentary2 <> fnd_api.g_miss_char
         AND
         (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_credit_ratings_rec.credit_score_commentary2 <> NVL(l_credit_score_commentary2, fnd_api.g_miss_char)
         )
        )
      THEN

          HZ_UTILITY_V2PUB.validate_lookup (
              p_column                                => 'credit_score_commentary2',
              p_lookup_type                           => 'CREDIT_SCORE_COMMENTARY',
              p_column_value                          => p_credit_ratings_rec.credit_score_commentary2,
              x_return_status                         => x_return_status);

	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug(p_message=>'credit_score_commentary2 is lookup code in lookup type CREDIT_SCORE_COMMENTARY. ' ||
				'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	  END IF;
      END IF;

      ------------------------------------
      -- validate credit_score_commentary3
      ------------------------------------

      -- credit_score_commentary3 is lookup code in lookup type CREDIT_SCORE_COMMENTARY
      IF p_credit_ratings_rec.credit_score_commentary3 IS NOT NULL
         AND
         p_credit_ratings_rec.credit_score_commentary3 <> fnd_api.g_miss_char
         AND
         (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_credit_ratings_rec.credit_score_commentary3 <> NVL(l_credit_score_commentary3, fnd_api.g_miss_char)
         )
        )
      THEN

          HZ_UTILITY_V2PUB.validate_lookup (
              p_column                                => 'credit_score_commentary3',
              p_lookup_type                           => 'CREDIT_SCORE_COMMENTARY',
              p_column_value                          => p_credit_ratings_rec.credit_score_commentary3,
              x_return_status                         => x_return_status);

	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		hz_utility_v2pub.debug(p_message=>'credit_score_commentary3 is lookup code in lookup type CREDIT_SCORE_COMMENTARY. ' ||
                  'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	  END IF;
      END IF;

      ------------------------------------
      -- validate credit_score_commentary4
      ------------------------------------

      -- credit_score_commentary4 is lookup code in lookup type CREDIT_SCORE_COMMENTARY
      IF p_credit_ratings_rec.credit_score_commentary4 IS NOT NULL
         AND
         p_credit_ratings_rec.credit_score_commentary4 <> fnd_api.g_miss_char
         AND
         (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_credit_ratings_rec.credit_score_commentary4 <> NVL(l_credit_score_commentary4, fnd_api.g_miss_char)
         )
        )
      THEN

          HZ_UTILITY_V2PUB.validate_lookup (
              p_column                                => 'credit_score_commentary4',
              p_lookup_type                           => 'CREDIT_SCORE_COMMENTARY',
              p_column_value                          => p_credit_ratings_rec.credit_score_commentary4,
              x_return_status                         => x_return_status);

	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		hz_utility_v2pub.debug(p_message=>'credit_score_commentary4 is lookup code in lookup type CREDIT_SCORE_COMMENTARY. ' ||
						  'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	 END IF;
      END IF;

      ------------------------------------
      -- validate credit_score_commentary5
      ------------------------------------

      -- credit_score_commentary5 is lookup code in lookup type CREDIT_SCORE_COMMENTARY
      IF p_credit_ratings_rec.credit_score_commentary5 IS NOT NULL
         AND
         p_credit_ratings_rec.credit_score_commentary5 <> fnd_api.g_miss_char
         AND
         (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_credit_ratings_rec.credit_score_commentary5 <> NVL(l_credit_score_commentary5, fnd_api.g_miss_char)
         )
        )
      THEN

          HZ_UTILITY_V2PUB.validate_lookup (
              p_column                                => 'credit_score_commentary5',
              p_lookup_type                           => 'CREDIT_SCORE_COMMENTARY',
              p_column_value                          => p_credit_ratings_rec.credit_score_commentary5,
              x_return_status                         => x_return_status);

	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	     hz_utility_v2pub.debug(p_message=>'credit_score_commentary5 is lookup code in lookup type CREDIT_SCORE_COMMENTARY. ' ||
					       'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	  END IF;
      END IF;

      ------------------------------------
      -- validate credit_score_commentary6
      ------------------------------------

      -- credit_score_commentary6 is lookup code in lookup type CREDIT_SCORE_COMMENTARY
      IF p_credit_ratings_rec.credit_score_commentary6 IS NOT NULL
         AND
         p_credit_ratings_rec.credit_score_commentary6 <> fnd_api.g_miss_char
         AND
         (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_credit_ratings_rec.credit_score_commentary6 <> NVL(l_credit_score_commentary6, fnd_api.g_miss_char)
         )
        )
      THEN

          HZ_UTILITY_V2PUB.validate_lookup (
              p_column                                => 'credit_score_commentary6',
              p_lookup_type                           => 'CREDIT_SCORE_COMMENTARY',
              p_column_value                          => p_credit_ratings_rec.credit_score_commentary6,
              x_return_status                         => x_return_status);

	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		hz_utility_v2pub.debug(p_message=>'credit_score_commentary6 is lookup code in lookup type CREDIT_SCORE_COMMENTARY. ' ||
						  'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	  END IF;
      END IF;

      ------------------------------------
      -- validate credit_score_commentary7
      ------------------------------------

      -- credit_score_commentary7 is lookup code in lookup type CREDIT_SCORE_COMMENTARY
      IF p_credit_ratings_rec.credit_score_commentary7 IS NOT NULL
         AND
         p_credit_ratings_rec.credit_score_commentary7 <> fnd_api.g_miss_char
         AND
         (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_credit_ratings_rec.credit_score_commentary7 <> NVL(l_credit_score_commentary7, fnd_api.g_miss_char)
         )
        )
      THEN

          HZ_UTILITY_V2PUB.validate_lookup (
              p_column                                => 'credit_score_commentary7',
              p_lookup_type                           => 'CREDIT_SCORE_COMMENTARY',
              p_column_value                          => p_credit_ratings_rec.credit_score_commentary7,
              x_return_status                         => x_return_status);

	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		hz_utility_v2pub.debug(p_message=>'credit_score_commentary7 is lookup code in lookup type CREDIT_SCORE_COMMENTARY. ' ||
						  'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	  END IF;
      END IF;

      ------------------------------------
      -- validate credit_score_commentary8
      ------------------------------------

      -- credit_score_commentary8 is lookup code in lookup type CREDIT_SCORE_COMMENTARY
      IF p_credit_ratings_rec.credit_score_commentary8 IS NOT NULL
         AND
         p_credit_ratings_rec.credit_score_commentary8 <> fnd_api.g_miss_char
         AND
         (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_credit_ratings_rec.credit_score_commentary8 <> NVL(l_credit_score_commentary8, fnd_api.g_miss_char)
         )
        )
      THEN

          HZ_UTILITY_V2PUB.validate_lookup (
              p_column                                => 'credit_score_commentary8',
              p_lookup_type                           => 'CREDIT_SCORE_COMMENTARY',
              p_column_value                          => p_credit_ratings_rec.credit_score_commentary8,
              x_return_status                         => x_return_status);

	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		hz_utility_v2pub.debug(p_message=>'credit_score_commentary8 is lookup code in lookup type CREDIT_SCORE_COMMENTARY. ' ||
						  'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	  END IF;
      END IF;

      ------------------------------------
      -- validate credit_score_commentary9
      ------------------------------------

      -- credit_score_commentary9 is lookup code in lookup type CREDIT_SCORE_COMMENTARY
      IF p_credit_ratings_rec.credit_score_commentary9 IS NOT NULL
         AND
         p_credit_ratings_rec.credit_score_commentary9 <> fnd_api.g_miss_char
         AND
         (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_credit_ratings_rec.credit_score_commentary9 <> NVL(l_credit_score_commentary9, fnd_api.g_miss_char)
         )
        )
      THEN

          HZ_UTILITY_V2PUB.validate_lookup (
              p_column                                => 'credit_score_commentary9',
              p_lookup_type                           => 'CREDIT_SCORE_COMMENTARY',
              p_column_value                          => p_credit_ratings_rec.credit_score_commentary9,
              x_return_status                         => x_return_status);

	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug(p_message=>'credit_score_commentary9 is lookup code in lookup type CREDIT_SCORE_COMMENTARY. ' ||
						   'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	  END IF;
      END IF;

      -------------------------------------
      -- validate credit_score_commentary10
      -------------------------------------

      -- credit_score_commentary10 is lookup code in lookup type CREDIT_SCORE_COMMENTARY
      IF p_credit_ratings_rec.credit_score_commentary10 IS NOT NULL
         AND
         p_credit_ratings_rec.credit_score_commentary10 <> fnd_api.g_miss_char
         AND
         (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_credit_ratings_rec.credit_score_commentary10 <> NVL(l_credit_score_commentary10, fnd_api.g_miss_char)
         )
        )
      THEN

          HZ_UTILITY_V2PUB.validate_lookup (
              p_column                                => 'credit_score_commentary10',
              p_lookup_type                           => 'CREDIT_SCORE_COMMENTARY',
              p_column_value                          => p_credit_ratings_rec.credit_score_commentary10,
              x_return_status                         => x_return_status);

	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	      hz_utility_v2pub.debug(p_message=>'credit_score_commentary10 is lookup code in lookup type CREDIT_SCORE_COMMENTARY. ' ||
						'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
          END IF;
      END IF;

      ------------------------------------
      -- validate failure_score_commentary
      ------------------------------------

      -- failure_score_commentary is lookup code in lookup type FAILURE_SCORE_COMMENTARY
      IF p_credit_ratings_rec.failure_score_commentary IS NOT NULL
         AND
         p_credit_ratings_rec.failure_score_commentary <> fnd_api.g_miss_char
         AND
         (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_credit_ratings_rec.failure_score_commentary <> NVL(l_credit_score_commentary, fnd_api.g_miss_char)
         )
        )
      THEN
          HZ_UTILITY_V2PUB.validate_lookup (
              p_column                                => 'failure_score_commentary',
              p_lookup_type                           => 'FAILURE_SCORE_COMMENTARY',
              p_column_value                          => p_credit_ratings_rec.failure_score_commentary,
              x_return_status                         => x_return_status);

	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		 hz_utility_v2pub.debug(p_message=>'failure_score_commentary is lookup code in lookup type FAILURE_SCORE_COMMENTARY. ' ||
						   'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	  END IF;
      END IF;

      -------------------------------------
      -- validate failure_score_commentary2
      -------------------------------------

      -- failure_score_commentary2 is lookup code in lookup type FAILURE_SCORE_COMMENTARY
      IF p_credit_ratings_rec.failure_score_commentary2 IS NOT NULL
         AND
         p_credit_ratings_rec.failure_score_commentary2 <> fnd_api.g_miss_char
         AND
         (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_credit_ratings_rec.failure_score_commentary2 <> NVL(l_credit_score_commentary2, fnd_api.g_miss_char)
         )
        )
      THEN

          HZ_UTILITY_V2PUB.validate_lookup (
              p_column                                => 'failure_score_commentary2',
              p_lookup_type                           => 'FAILURE_SCORE_COMMENTARY',
              p_column_value                          => p_credit_ratings_rec.failure_score_commentary2,
              x_return_status                         => x_return_status);

	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		hz_utility_v2pub.debug(p_message=>'failure_score_commentary2 is lookup code in lookup type FAILURE_SCORE_COMMENTARY. ' ||
						  'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	  END IF;
      END IF;

      -------------------------------------
      -- validate failure_score_commentary3
      -------------------------------------

      -- failure_score_commentary3 is lookup code in lookup type FAILURE_SCORE_COMMENTARY
      IF p_credit_ratings_rec.failure_score_commentary3 IS NOT NULL
         AND
         p_credit_ratings_rec.failure_score_commentary3 <> fnd_api.g_miss_char
         AND
         (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_credit_ratings_rec.failure_score_commentary3 <> NVL(l_credit_score_commentary3, fnd_api.g_miss_char)
         )
        )
      THEN

          HZ_UTILITY_V2PUB.validate_lookup (
              p_column                                => 'failure_score_commentary3',
              p_lookup_type                           => 'FAILURE_SCORE_COMMENTARY',
              p_column_value                          => p_credit_ratings_rec.failure_score_commentary3,
              x_return_status                         => x_return_status);

	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	     hz_utility_v2pub.debug(p_message=>'failure_score_commentary3 is lookup code in lookup type FAILURE_SCORE_COMMENTARY. ' ||
						'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
          END IF;
      END IF;

      -------------------------------------
      -- validate failure_score_commentary4
      -------------------------------------

      -- failure_score_commentary4 is lookup code in lookup type FAILURE_SCORE_COMMENTARY
      IF p_credit_ratings_rec.failure_score_commentary4 IS NOT NULL
         AND
         p_credit_ratings_rec.failure_score_commentary4 <> fnd_api.g_miss_char
         AND
         (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_credit_ratings_rec.failure_score_commentary4 <> NVL(l_credit_score_commentary4, fnd_api.g_miss_char)
         )
        )
      THEN

          HZ_UTILITY_V2PUB.validate_lookup (
              p_column                                => 'failure_score_commentary4',
              p_lookup_type                           => 'FAILURE_SCORE_COMMENTARY',
              p_column_value                          => p_credit_ratings_rec.failure_score_commentary4,
              x_return_status                         => x_return_status);

	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		hz_utility_v2pub.debug(p_message=>'failure_score_commentary4 is lookup code in lookup type FAILURE_SCORE_COMMENTARY. ' ||
					          'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	  END IF;
      END IF;

      -------------------------------------
      -- validate failure_score_commentary5
      -------------------------------------

      -- failure_score_commentary5 is lookup code in lookup type FAILURE_SCORE_COMMENTARY
      IF p_credit_ratings_rec.failure_score_commentary5 IS NOT NULL
         AND
         p_credit_ratings_rec.failure_score_commentary5 <> fnd_api.g_miss_char
         AND
         (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_credit_ratings_rec.failure_score_commentary5 <> NVL(l_credit_score_commentary5, fnd_api.g_miss_char)
         )
        )
      THEN

          HZ_UTILITY_V2PUB.validate_lookup (
              p_column                                => 'failure_score_commentary5',
              p_lookup_type                           => 'FAILURE_SCORE_COMMENTARY',
              p_column_value                          => p_credit_ratings_rec.failure_score_commentary5,
              x_return_status                         => x_return_status);

	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
		hz_utility_v2pub.debug(p_message=>'failure_score_commentary5 is lookup code in lookup type FAILURE_SCORE_COMMENTARY. ' ||
						  'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	  END IF;
      END IF;

      -------------------------------------
      -- validate failure_score_commentary6
      -------------------------------------

      -- failure_score_commentary6 is lookup code in lookup type FAILURE_SCORE_COMMENTARY
      IF p_credit_ratings_rec.failure_score_commentary6 IS NOT NULL
         AND
         p_credit_ratings_rec.failure_score_commentary6 <> fnd_api.g_miss_char
         AND
         (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_credit_ratings_rec.failure_score_commentary6 <> NVL(l_credit_score_commentary6, fnd_api.g_miss_char)
         )
        )
      THEN

          HZ_UTILITY_V2PUB.validate_lookup (
              p_column                                => 'failure_score_commentary6',
              p_lookup_type                           => 'FAILURE_SCORE_COMMENTARY',
              p_column_value                          => p_credit_ratings_rec.failure_score_commentary6,
              x_return_status                         => x_return_status);

	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	      hz_utility_v2pub.debug(p_message=>'failure_score_commentary6 is lookup code in lookup type FAILURE_SCORE_COMMENTARY. ' ||
						 'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	  END IF;
      END IF;

      -------------------------------------
      -- validate failure_score_commentary7
      -------------------------------------

      -- failure_score_commentary7 is lookup code in lookup type FAILURE_SCORE_COMMENTARY
      IF p_credit_ratings_rec.failure_score_commentary7 IS NOT NULL
         AND
         p_credit_ratings_rec.failure_score_commentary7 <> fnd_api.g_miss_char
         AND
         (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_credit_ratings_rec.failure_score_commentary7 <> NVL(l_credit_score_commentary7, fnd_api.g_miss_char)
         )
        )
      THEN

          HZ_UTILITY_V2PUB.validate_lookup (
              p_column                                => 'failure_score_commentary7',
              p_lookup_type                           => 'FAILURE_SCORE_COMMENTARY',
              p_column_value                          => p_credit_ratings_rec.failure_score_commentary7,
              x_return_status                         => x_return_status);

	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	      hz_utility_v2pub.debug(p_message=>'failure_score_commentary7 is lookup code in lookup type FAILURE_SCORE_COMMENTARY. ' ||
						'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	  END IF;
      END IF;

      -------------------------------------
      -- validate failure_score_commentary8
      -------------------------------------

      -- failure_score_commentary8 is lookup code in lookup type FAILURE_SCORE_COMMENTARY
      IF p_credit_ratings_rec.failure_score_commentary8 IS NOT NULL
         AND
         p_credit_ratings_rec.failure_score_commentary8 <> fnd_api.g_miss_char
         AND
         (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_credit_ratings_rec.failure_score_commentary8 <> NVL(l_credit_score_commentary8, fnd_api.g_miss_char)
         )
        )
      THEN

          HZ_UTILITY_V2PUB.validate_lookup (
              p_column                                => 'failure_score_commentary8',
              p_lookup_type                           => 'FAILURE_SCORE_COMMENTARY',
              p_column_value                          => p_credit_ratings_rec.failure_score_commentary8,
              x_return_status                         => x_return_status);

	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	     hz_utility_v2pub.debug(p_message=>'failure_score_commentary8 is lookup code in lookup type FAILURE_SCORE_COMMENTARY. ' ||
						'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
          END IF;
      END IF;

      -------------------------------------
      -- validate failure_score_commentary9
      -------------------------------------

      -- failure_score_commentary9 is lookup code in lookup type FAILURE_SCORE_COMMENTARY
      IF p_credit_ratings_rec.failure_score_commentary9 IS NOT NULL
         AND
         p_credit_ratings_rec.failure_score_commentary9 <> fnd_api.g_miss_char
         AND
         (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_credit_ratings_rec.failure_score_commentary9 <> NVL(l_credit_score_commentary9, fnd_api.g_miss_char)
         )
        )
      THEN

          HZ_UTILITY_V2PUB.validate_lookup (
              p_column                                => 'failure_score_commentary9',
              p_lookup_type                           => 'FAILURE_SCORE_COMMENTARY',
              p_column_value                          => p_credit_ratings_rec.failure_score_commentary9,
              x_return_status                         => x_return_status);

	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	     hz_utility_v2pub.debug(p_message=>'failure_score_commentary9 is lookup code in lookup type FAILURE_SCORE_COMMENTARY. ' ||
						'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	  END IF;
      END IF;

      --------------------------------------
      -- validate failure_score_commentary10
      --------------------------------------

      -- failure_score_commentary10 is lookup code in lookup type FAILURE_SCORE_COMMENTARY
      IF p_credit_ratings_rec.failure_score_commentary10 IS NOT NULL
         AND
         p_credit_ratings_rec.failure_score_commentary10 <> fnd_api.g_miss_char
         AND
         (p_create_update_flag = 'C'
          OR
          (p_create_update_flag = 'U'
           AND
           p_credit_ratings_rec.failure_score_commentary10 <> NVL(l_credit_score_commentary10, fnd_api.g_miss_char)
         )
        )
      THEN

          HZ_UTILITY_V2PUB.validate_lookup (
              p_column                                => 'failure_score_commentary10',
              p_lookup_type                           => 'FAILURE_SCORE_COMMENTARY',
              p_column_value                          => p_credit_ratings_rec.failure_score_commentary10,
              x_return_status                         => x_return_status);

	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	      hz_utility_v2pub.debug(p_message=>'failure_score_commentary10 is lookup code in lookup type FAILURE_SCORE_COMMENTARY. ' ||
						'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	   END IF;
      END IF;


      ----------------------------------------
      -- validate maximum_credit_currency_code
      ----------------------------------------

      -- maximum_credit_currency_code is foreign key of fnd_currencies.currency_code

      IF p_credit_ratings_rec.maximum_credit_currency_code IS NOT NULL
         AND
         p_credit_ratings_rec.maximum_credit_currency_code <> fnd_api.g_miss_char
      THEN
          BEGIN
              SELECT 'Y'
              INTO   l_dummy
              FROM   FND_CURRENCIES
              WHERE  CURRENCY_CODE = p_credit_ratings_rec.maximum_credit_currency_code
              AND    CURRENCY_FLAG = 'Y'
              AND    ENABLED_FLAG in ('Y', 'N');
          EXCEPTION
              WHEN NO_DATA_FOUND THEN
                  fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
                  fnd_message.set_token('FK', 'maximum_credit_currency_code');
                  fnd_message.set_token('COLUMN', 'currency_code');
                  fnd_message.set_token('TABLE', 'fnd_currencies');
                  fnd_msg_pub.add;
                  x_return_status := fnd_api.g_ret_sts_error;
          END;

	  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	     hz_utility_v2pub.debug(p_message=>'maximum_credit_currency_code is foreign key of fnd_currencies.currency_code. ' ||
						'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
	  END IF;

      END IF;

      -- Bug 2197181: Added validation for mix-n-match

      ----------------------------------------
      -- validate content_source_type and actual_content_source_type
      ----------------------------------------
      -- SSM SST Integration and Extension
      -- Passed HZ_CREDIT_RATINGS for newly added paratemer p_entity_name

      HZ_MIXNM_UTILITY.ValidateContentSource (
        p_api_version                       => 'V1',
        p_create_update_flag                => p_create_update_flag,
        p_check_update_privilege            => 'Y',
        p_content_source_type               => p_credit_ratings_rec.content_source_type,
        p_old_content_source_type           => db_content_source_type,
        p_actual_content_source             => p_credit_ratings_rec.actual_content_source,
        p_old_actual_content_source         => db_actual_content_source,
	p_entity_name                       => 'HZ_CREDIT_RATINGS',
        x_return_status                     => x_return_status );

      --disable_debug;

END validate_credit_ratings;

/*======================================================================
 | PROCEDURE  (public)
 |              validate_financial_profile
 |
 | DESCRIPTION
 |              Validates on:
 |                      mandatory columns
 |                      non-updateable fields
 |                      foreign key
 |                      lookup types
 |
 | ARGUMENTS  : IN:
 |                      p_financial_profile_rec
 |                      create_update_flag
 |              OUT:
 |
 | RETURNS    : NONE
 |
 | MODIFICATION HISTORY
 |       YKONG     26-OCT-1999    Created
 |
 +======================================================================*/

procedure validate_financial_profile(
    p_financial_profile_rec    IN  HZ_PARTY_INFO_PUB.financial_profile_rec_type,
    p_create_update_flag       IN  VARCHAR2,
    x_return_status            IN OUT  NOCOPY VARCHAR2
) IS
    l_party_id                 NUMBER;
    l_party_type               HZ_PARTIES.PARTY_TYPE%TYPE;

BEGIN
    -- mandatory fields: party_id
    IF (p_create_update_flag = 'C' AND
        (p_financial_profile_rec.party_id IS NULL  OR
         p_financial_profile_rec.party_id =  FND_API.G_MISS_NUM))
       OR
       (p_create_update_flag = 'U'  AND
        p_financial_profile_rec.party_id IS NULL)  THEN

        FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
        FND_MESSAGE.SET_TOKEN('COLUMN', 'party_id');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;

    END IF;

    -- non updateable field

    IF (p_create_update_flag = 'U'  AND
        p_financial_profile_rec.party_id <> FND_API.G_MISS_NUM) THEN

        SELECT party_id
        INTO l_party_id
        FROM hz_financial_profile
        where financial_profile_id
             = p_financial_profile_rec.financial_profile_id ;

        if l_party_id <> p_financial_profile_rec.party_id  then
              FND_MESSAGE.SET_NAME('AR', 'HZ_API_NONUPDATEABLE_COLUMN');
              FND_MESSAGE.SET_TOKEN('COLUMN', 'party_id');
              FND_MSG_PUB.ADD;
              x_return_status := FND_API.G_RET_STS_ERROR;
        end if;

     END IF;

    -- foreign key : party_id to hz_parties

    IF (p_financial_profile_rec.party_id is NOT NULL  AND
        p_financial_profile_rec.party_id <> FND_API.G_MISS_NUM) THEN

        -- Bug 4461511.
        BEGIN
        SELECT party_type
        INTO l_party_type
        FROM hz_parties
        WHERE party_id = p_financial_profile_rec.party_id;

       IF p_create_update_flag = 'C'
          AND l_party_type <> 'PERSON'
          AND l_party_type <> 'ORGANIZATION'
       THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_PARTY_TYPE');
            FND_MESSAGE.SET_TOKEN('PARTY_ID', to_char(p_financial_profile_rec.party_id));
            FND_MESSAGE.SET_TOKEN('TYPE', 'ORGANIZATION or PERSON');
            FND_MSG_PUB.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

        EXCEPTION
        WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_INVALID_FK');
            FND_MESSAGE.SET_TOKEN('FK', 'party_id');
            FND_MESSAGE.SET_TOKEN('COLUMN', 'party_id');
            FND_MESSAGE.SET_TOKEN('TABLE', 'hz_parties');
            FND_MSG_PUB.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;
        END;
    END IF;


    -- lookup type validation : access_authority_granted

        hz_common_pub.validate_lookup('YES/NO', 'ACCESS_AUTHORITY_GRANTED',
                p_financial_profile_rec.access_authority_granted, x_return_status);
--Status Validation
hz_common_pub.validate_lookup('REGISTRY_STATUS','status',p_financial_profile_rec.status,x_return_status);
END validate_financial_profile;

END  HZ_PARTY_INFO_VAL;

/
