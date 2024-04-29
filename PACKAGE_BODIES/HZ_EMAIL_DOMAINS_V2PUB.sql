--------------------------------------------------------
--  DDL for Package Body HZ_EMAIL_DOMAINS_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_EMAIL_DOMAINS_V2PUB" AS
/*$Header: ARH2EMDB.pls 120.14 2005/06/16 21:07:20 jhuang noship $ */

g_debug_count                        NUMBER := 0;
--g_debug                              BOOLEAN := FALSE;

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
 *     hz_utility_v2pub.enable_debug
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

/**
 * PRIVATE PROCEDURE validate_mandatory
 *
 * DESCRIPTION
 *     validate_mandatory if the column type is VARCHAR2.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 */

PROCEDURE validate_mandatory (
    p_create_update_flag                    IN     VARCHAR2,
    p_column                                IN     VARCHAR2,
    p_column_value                          IN     VARCHAR2,
    p_restricted                            IN     VARCHAR2 DEFAULT 'N',
    x_return_status                         IN OUT NOCOPY VARCHAR2
) IS

    l_error                                 BOOLEAN := FALSE;

BEGIN

    IF p_restricted = 'N' THEN
        IF (p_create_update_flag = 'C' AND
             (p_column_value IS NULL OR
               p_column_value = fnd_api.g_miss_char)) OR
           (p_create_update_flag = 'U' AND
             p_column_value = fnd_api.g_miss_char)
        THEN
            l_error := TRUE;
        END IF;
    ELSE
        IF (p_column_value IS NULL OR
             p_column_value = fnd_api.g_miss_char)
        THEN
            l_error := TRUE;
        END IF;
    END IF;

    IF l_error THEN
        fnd_message.set_name('AR', 'HZ_API_MISSING_COLUMN');
        fnd_message.set_token('COLUMN', p_column);
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
    END IF;

END validate_mandatory;

/**
 * PRIVATE PROCEDURE validate_mandatory
 *
 * DESCRIPTION
 *     validate_mandatory if the column type is NUMBER.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 */

PROCEDURE validate_mandatory (
    p_create_update_flag                    IN     VARCHAR2,
    p_column                                IN     VARCHAR2,
    p_column_value                          IN     NUMBER,
    p_restricted                            IN     VARCHAR2 DEFAULT 'N',
    x_return_status                         IN OUT NOCOPY VARCHAR2
 ) IS

    l_error                                 BOOLEAN := FALSE;

BEGIN

    IF p_restricted = 'N' THEN
        IF (p_create_update_flag = 'C' AND
             (p_column_value IS NULL OR
               p_column_value = fnd_api.g_miss_num)) OR
           (p_create_update_flag = 'U' AND
             p_column_value = fnd_api.g_miss_num)
        THEN
            l_error := TRUE;
        END IF;
    ELSE
        IF (p_column_value IS NULL OR
             p_column_value = fnd_api.g_miss_num)
        THEN
            l_error := TRUE;
        END IF;
    END IF;

    IF l_error THEN
        fnd_message.set_name('AR', 'HZ_API_MISSING_COLUMN');
        fnd_message.set_token('COLUMN', p_column);
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_error;
    END IF;

END validate_mandatory;

PROCEDURE do_email_domain_transfer(
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        x_to_id         IN OUT NOCOPY  NUMBER,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
	x_return_status IN OUT NOCOPY          VARCHAR2
) IS

BEGIN

  IF NOT (x_to_id <> FND_API.G_MISS_NUM AND
      x_to_id <> p_from_id) THEN

    --commented out because this part we are doing in email_domain_merge
    --procedure
    --UPDATE HZ_EMAIL_DOMAINS
    --SET
    --  STATUS = 'M',
    --  last_update_date = hz_utility_pub.last_update_date,
    --  last_updated_by = hz_utility_pub.user_id,
    --  last_update_login = hz_utility_pub.last_update_login
    --WHERE email_domain_id = p_from_id;
  --ELSE
    -- Update and set party_id = p_to_fk_id where pk = from_id
    UPDATE HZ_EMAIL_DOMAINS
    SET
      party_id = p_to_fk_id,
      last_update_date = hz_utility_pub.last_update_date,
      last_updated_by = hz_utility_pub.user_id,
      last_update_login = hz_utility_pub.last_update_login
    WHERE email_domain_id = p_from_id;

  END IF;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END do_email_domain_transfer;

/**
 * FUNCTION transpose_domain
 *
 * DESCRIPTION
 *     This API will accept an input domain, and return it with the segments
 *     transposed (reversed). The return value should be all-uppercase.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_domain_name                 Input domain
 *
 *   IN/OUT:
 *   OUT:
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   21-APR-2003  Sreedhar Mohan     o Created.
 *
 */

FUNCTION transpose_domain(
   p_domain_name IN VARCHAR2
) RETURN VARCHAR2
IS

  l_ret_domain       VARCHAR2(2000) := NULL;
  l_domain_name      VARCHAR2(2000) := p_domain_name;
  l_debug_prefix     VARCHAR2(30) := '';

BEGIN
  --enable_debug;

  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'transpose_domain (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
  END IF;
  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'l_domain_name: ' || l_domain_name,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
  END IF;

  WHILE instr(l_domain_name, '.') > 0 LOOP
    l_ret_domain := l_ret_domain || substrb(l_domain_name, instrb( l_domain_name, '.', -1, 1)+1, lengthb(l_domain_name)) || '.';
    l_domain_name := substrb( l_domain_name, 0, instrb( l_domain_name, '.', -1, 1) -1);
  END LOOP;
  l_ret_domain := l_ret_domain || l_domain_name;
  IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'l_ret_domain: ' || l_ret_domain,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
  END IF;
  IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'transpose_domain (-)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
  END IF;
  --disable_debug;

  RETURN upper(l_ret_domain);

END transpose_domain;

/**
 * PROCEDURE create_email_domain
 *
 * DESCRIPTION
 *     This API will insert a row into the HZ_EMAIL_DOMAINS table. It should
 *     internally call the function defined above (transpose_domain), and
 *     insert the transposed value as well.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_party_id                     Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_domain_name                  Financial report record.
 *   IN/OUT:
 *   OUT:
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   21-APR-2003  Sreedhar Mohan     o Created.
 *
 */

PROCEDURE create_email_domain(
     p_party_id IN NUMBER,
     p_domain_name IN VARCHAR2,
     x_return_status  OUT NOCOPY VARCHAR2,
     x_msg_count OUT NOCOPY NUMBER,
     x_msg_data  OUT NOCOPY VARCHAR2) IS

    l_debug_prefix                     VARCHAR2(30) := '';
    l_dummy                                VARCHAR2(32);

    CURSOR c_unique_email_domain ( p_party_id IN NUMBER,
                                   p_domain_name IN VARCHAR2) IS
      SELECT 'Y'
      FROM   hz_email_domains
      WHERE  party_id = p_party_id
      AND    domain_name = p_domain_name;

    BEGIN

    --enable_debug;
    IF fnd_log.level_procedure>=fnd_log.g_current_runtime_level THEN
	hz_utility_v2pub.debug(p_message=>'create_email_domain (+)',
	                       p_prefix=>l_debug_prefix,
			       p_msg_level=>fnd_log.level_procedure);
    END IF;

    SAVEPOINT create_email_domain;

    -------------------------------------
    -- validation for logical primary_key
    -------------------------------------

    OPEN c_unique_email_domain ( p_party_id, p_domain_name);

    FETCH c_unique_email_domain INTO l_dummy;

    -- combination key is not unique, push an error onto the stack.
    IF NVL(c_unique_email_domain%FOUND, FALSE) THEN
       fnd_message.set_name('AR', 'HZ_API_DUPLICATE_COLUMN');
       fnd_message.set_token('COLUMN', 'party_id and domain_name combination');
       fnd_msg_pub.add;
       x_return_status := fnd_api.g_ret_sts_error;
    END IF;
    CLOSE c_unique_email_domain;

    IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'The following column combination should be unique:' ||
					     ' PARTY_ID, DOMAIN_NAME. ' ||
					     ' x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
    END IF;

    -------------------------------------
    -- validation for party_id
    -------------------------------------

    --party_id is a mandatory field
    validate_mandatory (
        p_create_update_flag                    => 'C',
        p_column                                => 'party_id',
        p_column_value                          => p_party_id,
        x_return_status                         => x_return_status);

	IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	   hz_utility_v2pub.debug(p_message=>'party_id is mandatory field. ' ||
                'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
        END IF;

      -- party_id has foreign key HZ_PARTIES.PARTY_ID
      IF p_party_id IS NOT NULL
         AND
         p_party_id <> fnd_api.g_miss_num
      THEN
         BEGIN
              SELECT 'Y'
              INTO   l_dummy
              FROM   hz_parties p
              WHERE  p.party_id = p_party_id;

         EXCEPTION
              WHEN NO_DATA_FOUND THEN
                  fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
                  fnd_message.set_token('FK', 'party_id');
                  fnd_message.set_token('COLUMN', 'party_id');
                  fnd_message.set_token('TABLE', 'hz_parties');
                  fnd_msg_pub.add;
                  x_return_status := fnd_api.g_ret_sts_error;
         END;


	 IF fnd_log.level_statement>=fnd_log.g_current_runtime_level THEN
	    hz_utility_v2pub.debug(p_message=>'party_id has foreign key hz_parties.party_id. ' ||
                  'x_return_status = ' || x_return_status,
			          p_prefix =>l_debug_prefix,
			          p_msg_level=>fnd_log.level_statement);
         END IF;

      END IF;

      -----------------------------
      -- validation for domain_name
      -----------------------------
      validate_mandatory (
          p_create_update_flag                    => 'C',
          p_column                                => 'domain_name',
          p_column_value                          => p_domain_name,
          x_return_status                         => x_return_status);

      -------------------------------
      -- Insert into HZ_EMAIL_DOMAINS
      -------------------------------
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      INSERT INTO HZ_EMAIL_DOMAINS(
             EMAIL_DOMAIN_ID
           , PARTY_ID
           , TRANSPOSED_DOMAIN
           , DOMAIN_NAME
           , STATUS
           , CREATION_DATE
           , LAST_UPDATE_LOGIN
           , LAST_UPDATE_DATE
           , LAST_UPDATED_BY
           , CREATED_BY ) VALUES (
             hz_email_domains_s.nextval
           , p_party_id
           , transpose_domain( p_domain_name)
           , p_domain_name
           , 'A'
           , hz_utility_v2pub.creation_date
           , hz_utility_v2pub.last_update_login
           , hz_utility_v2pub.last_update_date
           , hz_utility_v2pub.last_updated_by
           , hz_utility_v2pub.created_by
     );

     -- VJN introduced changes for the domain name project for ensuring
     -- DQM sync happens, when ever an email domain is created, using this API.
     BEGIN
             select party_type into l_dummy
             from hz_parties
             where party_id = p_party_id;

             IF l_dummy = 'ORGANIZATION'
             THEN
                    HZ_DQM_SYNC.sync_org(p_party_id, 'U' );
             ELSIF l_dummy = 'PERSON'
             THEN
                    HZ_DQM_SYNC.sync_person(p_party_id, 'U' );
             END IF;

             EXCEPTION
              WHEN NO_DATA_FOUND THEN
                  fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
                  fnd_message.set_token('FK', 'party_id');
                  fnd_message.set_token('COLUMN', 'party_id');
                  fnd_message.set_token('TABLE', 'hz_parties');
                  fnd_msg_pub.add;
                  x_return_status := fnd_api.g_ret_sts_error;


      END;

     x_return_status := FND_API.G_RET_STS_SUCCESS;
    --disable_debug;

    EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_email_domain;
        x_return_status :=  fnd_api.g_ret_sts_error;
      WHEN OTHERS THEN
        ROLLBACK TO create_email_domain;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;

END create_email_domain;

PROCEDURE email_domains_merge(
        p_entity_name     IN     VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id         IN     NUMBER:=FND_API.G_MISS_NUM,
        x_to_id           IN OUT NOCOPY	NUMBER,
        p_from_fk_id      IN     NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id        IN     NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN     VARCHAR2:=FND_API.G_MISS_CHAR,
        p_batch_id	  IN	 NUMBER:=FND_API.G_MISS_NUM,
        p_batch_party_id  IN     NUMBER:=FND_API.G_MISS_NUM,
	x_return_status      OUT NOCOPY          VARCHAR2

) IS

l_to_id         NUMBER;
l_dup_exists    VARCHAR2(20);

BEGIN

   IF (x_to_id IS NULL) THEN
     l_to_id := FND_API.G_MISS_NUM;
   ELSE
     l_to_id := x_to_id;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   check_params(p_entity_name, p_from_id, l_to_id, NULL,
                p_from_id, p_par_entity_name,
                'HZ_EMAIL_DOMAINS_V2PUB.email_domains_merge',
                'HZ_EMAIL_DOMAINS','HZ_PARTIES',
                'EMAIL_DOMAIN_ID', 'PARTY_ID',x_return_status);

   IF (x_return_status = FND_API.G_RET_STS_SUCCESS AND l_to_id = FND_API.G_MISS_NUM) THEN
     l_dup_exists := HZ_EMAIL_DOMAINS_V2PUB.check_email_domain_dup(
                        p_from_id,l_to_id, p_from_fk_id, p_to_fk_id,
                        x_return_status);
   END IF;

   --since hz_email_domains does n't has its own id, p_from_id=p_from_fk_id
   --and p_to_fk_id = party_id
   IF (x_return_status =FND_API.G_RET_STS_SUCCESS AND l_dup_exists = FND_API.G_FALSE) THEN

       do_email_domain_transfer(p_from_id,l_to_id, p_from_fk_id, p_to_fk_id,
                         x_return_status);
   ELSIF (l_dup_exists = FND_API.G_TRUE) THEN
     UPDATE HZ_EMAIL_DOMAINS
     SET
       STATUS = 'M',
       last_update_date = hz_utility_pub.last_update_date,
       last_updated_by = hz_utility_pub.user_id,
       last_update_login = hz_utility_pub.last_update_login
     WHERE email_domain_id = p_from_id;
   END IF;

   x_to_id := l_to_id;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END email_domains_merge;

FUNCTION check_email_domain_dup(
  p_from_id          IN      NUMBER:=FND_API.G_MISS_NUM,
  x_to_id            IN OUT NOCOPY NUMBER,
  p_from_fk_id       IN      NUMBER:=FND_API.G_MISS_NUM,
  p_to_fk_id         IN      NUMBER:=FND_API.G_MISS_NUM,
  x_return_status    IN OUT NOCOPY VARCHAR2)
RETURN VARCHAR2 IS

CURSOR dupcheck IS
  SELECT PARTY_ID
  FROM   HZ_EMAIL_DOMAINS
  WHERE  party_id = p_to_fk_id
  AND    DOMAIN_NAME = ( SELECT DOMAIN_NAME
                         FROM   HZ_EMAIL_DOMAINS
                         WHERE  EMAIL_DOMAIN_ID= p_from_id);

l_record_id NUMBER;

BEGIN

  x_to_id := FND_API.G_MISS_NUM;

  OPEN dupcheck;
  FETCH dupcheck INTO l_record_id;
  IF dupcheck%NOTFOUND THEN
    CLOSE dupcheck;
    RETURN FND_API.G_FALSE;
  END IF;

  x_to_id := l_record_id;
  CLOSE dupcheck;
  RETURN FND_API.G_TRUE;

END check_email_domain_dup;

PROCEDURE check_params(
        p_entity_name   IN      VARCHAR2:=FND_API.G_MISS_CHAR,
        p_from_id       IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_id         IN	NUMBER:=FND_API.G_MISS_NUM,
        p_from_fk_id    IN      NUMBER:=FND_API.G_MISS_NUM,
        p_to_fk_id      IN      NUMBER:=FND_API.G_MISS_NUM,
        p_par_entity_name IN    VARCHAR2:=FND_API.G_MISS_CHAR,
	p_proc_name	  IN	VARCHAR2,
	p_exp_ent_name	IN	VARCHAR2:=FND_API.G_MISS_CHAR,
        p_exp_par_ent_name IN   VARCHAR2:=FND_API.G_MISS_CHAR,
        p_pk_column	IN	VARCHAR2:=FND_API.G_MISS_CHAR,
	p_par_pk_column	IN	VARCHAR2:=FND_API.G_MISS_CHAR,
	x_return_status IN OUT NOCOPY          VARCHAR2
) IS

BEGIN
   IF (p_entity_name <> p_exp_ent_name OR
       p_par_entity_name <> p_exp_par_ent_name) THEN
     FND_MESSAGE.SET_NAME('AR', 'HZ_INVALID_MERGE_ENTITIES');
     FND_MESSAGE.SET_TOKEN('ENTITY' ,p_entity_name);
     FND_MESSAGE.SET_TOKEN('PENTITY' ,p_par_entity_name);
     FND_MESSAGE.SET_TOKEN('MPROC' ,p_proc_name);
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;

   IF (p_from_id = FND_API.G_MISS_NUM) THEN
     FND_MESSAGE.SET_NAME('AR', 'HZ_INVALID_MERGE_FROM_REC');
     FND_MESSAGE.SET_TOKEN('MPROC' ,p_proc_name);
     FND_MESSAGE.SET_TOKEN('ENTITY',p_entity_name);
     FND_MESSAGE.SET_TOKEN('PKCOL',p_pk_column);
     FND_MESSAGE.SET_TOKEN('PKVALUE',p_to_id);
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;

   IF (p_exp_par_ent_name <> FND_API.G_MISS_CHAR AND
       p_to_fk_id = FND_API.G_MISS_NUM ) THEN
     FND_MESSAGE.SET_NAME('AR', 'HZ_INVALID_MERGE_FROM_PAR_REC');
     FND_MESSAGE.SET_TOKEN('MPROC' ,p_proc_name);
     FND_MESSAGE.SET_TOKEN('ENTITY',p_par_entity_name);
     FND_MESSAGE.SET_TOKEN('PKCOL',p_pk_column);
     FND_MESSAGE.SET_TOKEN('PKVALUE',p_to_id);
     FND_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;
EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END check_params;

---------------- VJN INTRODUCED -----------------------------------------------------

/*  -- will keep this for posterity


PROCEDURE extract_extension(
  p_input_str VARCHAR2,
  x_first_seg OUT NOCOPY VARCHAR2,
  x_extension OUT NOCOPY VARCHAR2) IS

tmp NUMBER;
l_prev_tok VARCHAR2(2000);
l_tok VARCHAR2(2000);
l_leftover VARCHAR2(2000);
BEGIN

  if (instrb(p_input_str,'.'))=0 THEN
    x_extension:=p_input_str;
    x_first_seg:=null;
    return;
  end if;

  l_leftover := p_input_str; -- = UK.ORACLE.TV
  l_prev_tok := null;
  l_tok := HZ_DQM_SEARCH_UTIL.strtok(p_input_str,1,'.');
  -- UK
  WHILE l_tok IS NOT NULL LOOP
    BEGIN
      SELECT 1 INTO tmp FROM AR_LOOKUPS WHERE
      lookup_type = 'HZ_DOMAIN_SUFFIX_LIST'
      and lookup_code = l_leftover;

      x_first_seg := l_prev_tok;
      x_extension:= l_leftover;
      RETURN;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_prev_tok:=l_tok;

        l_leftover := replace(l_leftover,l_tok||'.');
        l_tok := HZ_DQM_SEARCH_UTIL.strtok;

    END;
  END LOOP;

  x_extension:=l_prev_tok;

  l_leftover:= replace(p_input_str,'.'||x_extension);
  x_first_seg:=substrb(l_leftover,instrb(l_leftover,'.',-1)+1);
END;
*/
-----------------------------------------------------------------------------------------
-- EMAIL ADDRESS: colathur.vijayan@uk.oracle.com
-- FULL DOMAIN: uk.oracle.com
-- CORE DOMAIN: oracle.com

-- this will return the domain name with shortest length or the concatenation of
-- all domain names of a given party
FUNCTION get_email_domains(
	p_party_id	IN	NUMBER,
	p_entity	IN	VARCHAR2,
	p_attribute	IN	VARCHAR2,
    p_context       IN      VARCHAR2 )
RETURN VARCHAR2 IS
l_ret_str varchar2(32000);

BEGIN
  IF p_context = 'STAGE'
  THEN
    FOR email_domains_cur in
    (select domain_name
     from hz_email_domains
     where party_id = p_party_id)
    LOOP
       l_ret_str := l_ret_str || ' ' || ltrim(rtrim(email_domains_cur.domain_name)) ;
    END LOOP;
  ELSE
    FOR email_domain_cur in
    (
    select d_name
    from
        (select domain_name as d_name
        from hz_email_domains
        where party_id = p_party_id
        order by length(domain_name)
        )
     where rownum = 1
     )
     LOOP
       l_ret_str := ltrim(rtrim(email_domain_cur.d_name));
     END LOOP;
  END IF;
      -- final treatment to get rid of trailing/leading spaces, if any
      l_ret_str := ltrim(rtrim(l_ret_str));
  return l_ret_str ;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_EMAIL_DOMAINS_V2PUB');
    FND_MESSAGE.SET_TOKEN('PROC' ,'GET_EMAIL_DOMAINS');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END get_email_domains ;


-- this will return the concatenation of all full domain names
-- given a concatenation of email addresses
FUNCTION FULL_DOMAIN(
        p_input_str             IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2)
RETURN VARCHAR2
IS
treated_input_str VARCHAR2(4000);
tempstr VARCHAR2(4000);
retstr VARCHAR2(4000);
l_tok VARCHAR2(4000);
tmp NUMBER;
BEGIN


     -- remove leading/trailing spaces
     -- change all alphabetic characters to upper case
     -- all numeric characters as is
     -- all other characters to space
     -- "." and "@" will remain as is
     treated_input_str:= LTRIM(RTRIM(upper(p_input_str)));
     -- dbms_output.put_line('Input string is ' || treated_input_str);
     treated_input_str:= LTRIM(RTRIM(treated_input_str,'.'),'.');
     -- empty strings do not go far
     IF (treated_input_str IS NULL OR treated_input_str = '')
     THEN
            return '';
     END IF ;

     -- replace double spaces by single spaces
     WHILE instrb(treated_input_str,'  ')>0 LOOP
       treated_input_str := REPLACE(treated_input_str, '  ',' ');
     END LOOP;


     -- build the return string by tokenization
     -- tokenize the treated input string, with the delimiter
     -- being a space.
     l_tok := HZ_DQM_SEARCH_UTIL.strtok(treated_input_str,1,' ');

     -- cycle through the tokens and construct the return string
     -- by appending the right part of the @ of each token
     WHILE l_tok IS NOT NULL
     LOOP
           -- get the full domain ie., the string to the right of the @
           tempstr := substr(l_tok, instrb(l_tok,'@') + 1 );

           -- dbms_output.put_line('after stripping @ full domain is' || tempstr);

           -- do the ISP check on the tempstr
           BEGIN
               SELECT 1 INTO tmp FROM AR_LOOKUPS
               WHERE
               lookup_type = 'HZ_DOMAIN_ISP_LIST'
               and lookup_code = tempstr ;

               -- dbms_output.put_line('ISP validation fails');

               l_tok := HZ_DQM_SEARCH_UTIL.strtok;

               EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  retstr := retstr || ' '|| tempstr ;
                  l_tok := HZ_DQM_SEARCH_UTIL.strtok;
          END;
     END LOOP;

     -- final treatment to get rid of trailing/leading spaces, if any
     retstr := ltrim(rtrim(retstr));

     return retstr;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_EMAIL_DOMAINS_V2PUB');
    FND_MESSAGE.SET_TOKEN('PROC' ,'FULL_DOMAIN');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END FULL_DOMAIN;



-- Given a full domain, this would extract the extension
-- and the first segment, with the validation being driven either
-- by a lookup , if it exists or by the following default assumption
-- extension = anything to the right of the first dot from backwards
-- first segment = any string to the left of the first dot ( delimiter of
-- "." would apply if there are more dots than one)

PROCEDURE extract_ext_and_segment(
  p_input_str VARCHAR2,
  x_first_seg OUT NOCOPY VARCHAR2,
  x_extension OUT NOCOPY VARCHAR2)
IS
treated_input_str VARCHAR2(4000);
dot_occurence number;
tmp NUMBER;
pos number;
len number;

BEGIN
  -- extreme case 1: if input string has no dots, extension is input string
  -- and first segment is null
  IF (instrb(p_input_str,'.'))=0
  THEN
    x_extension:=p_input_str;
    x_first_seg:=null;
    return;
  ELSE
        -- remove leading dot from input string
        treated_input_str := ltrim(p_input_str,'.');

        -- count the number of dots, defaulting to 1 at first
        dot_occurence := 1 ;

        WHILE instrb(treated_input_str,'.',1,dot_occurence) > 0
        LOOP
           dot_occurence := dot_occurence + 1;
        END LOOP;

        -- this will be the number of dots in the final domain name
        dot_occurence := dot_occurence - 1;

        -- extreme case 2 : if the input string has no dots after removal of
        -- the leading dot, then we take extension to be what ever is left
        IF dot_occurence = 0
        THEN
          x_extension := treated_input_str;
          x_first_seg:=null;
          return;
        ELSE
              FOR I IN 0..dot_occurence
              LOOP
                     BEGIN
                         IF I = 0
                         THEN
                            x_extension := treated_input_str;
                         ELSE
                            x_extension := substr(treated_input_str,
                                             instrb(treated_input_str,'.',1,I) + 1 );
                         END IF;

                         SELECT 1 INTO tmp FROM AR_LOOKUPS
                         WHERE
                         lookup_type = 'HZ_DOMAIN_SUFFIX_LIST'
                         and lookup_code = x_extension;

                        -- extreme case 3 : if the input string matches an extension
                        --                  as is then first seg is null
                         IF I = 0
                         THEN
                           x_extension := treated_input_str;
                           x_first_seg := null;
                           return;
                         -- normal case
                         ELSIF I = 1
                         THEN
                           pos := 1;
                           len := instrb(treated_input_str,'.',1,1 ) - 1;

                         ELSE
                           pos := instrb(treated_input_str,'.',1, I-1) + 1 ;
                           len := instrb(treated_input_str,'.',1,I) - pos ;


                         END IF;

                         -- dbms_output.put_line('pos is ' || pos);
                         -- dbms_output.put_line('length is ' || len );

                         x_first_seg := substr(treated_input_str, pos , len );


                         return;

                         EXCEPTION
                         WHEN NO_DATA_FOUND THEN
                             null;
                     END;


              END LOOP;
        END IF;

         -- if we get this far we did not find an appropriate lookup
         -- in this case,
         -- extension := string to the right of the last dot
         -- first segment := string between penultimate dot/beginning and last dot.
         IF dot_occurence = 1
         THEN
            pos := 1;
         ELSE
            pos := instrb(treated_input_str,'.',-1,2) + 1 ;

         END IF;

         len := instrb(treated_input_str,'.',-1,1) - pos;
         x_extension := substr(treated_input_str,
                                             instrb(treated_input_str,'.',-1,1) + 1 );
         x_first_seg := substr(treated_input_str, pos, len );

END IF;


END;





-- this will return the concatenation of all core domain names
-- given a concatenation of email addresses
FUNCTION CORE_DOMAIN(
        p_input_str             IN      VARCHAR2,
        p_language              IN      VARCHAR2,
        p_attribute_name        IN      VARCHAR2,
        p_entity_name           IN      VARCHAR2)
RETURN VARCHAR2
IS
treated_input_str VARCHAR2(4000);
retstr VARCHAR2(4000);
l_tok VARCHAR2(4000);
x_first_seg VARCHAR2(4000);
x_extension VARCHAR2(4000);
BEGIN
     -- empty strings do not go far
     IF (p_input_str IS NULL OR p_input_str = '')
     THEN
            return '';
     END IF ;

     -- get all the domain names after stripping them from the input string
     treated_input_str := FULL_DOMAIN(p_input_str, p_language,
                           p_attribute_name,p_entity_name );

     -- replace double spaces by single spaces if any
     WHILE instrb(treated_input_str,'  ')>0 LOOP
            treated_input_str := REPLACE(treated_input_str, '  ',' ');
     END LOOP;

     -- build the return string by tokenization
     -- with the delimiter being a space.
     l_tok := HZ_DQM_SEARCH_UTIL.strtok(treated_input_str,1,' ');

     -- cycle through the tokens and construct the return string
     WHILE l_tok IS NOT NULL
     LOOP
          extract_ext_and_segment(l_tok, x_first_seg, x_extension);
          retstr := retstr ||ltrim(x_first_seg||'.'||x_extension||' ','.');
          l_tok := HZ_DQM_SEARCH_UTIL.strtok;
     END LOOP;

     -- final treatment to get rid of trailing/leading spaces, if any
     retstr := ltrim(rtrim(retstr));

     return retstr;

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR', 'HZ_EMAIL_DOMAINS_V2PUB');
    FND_MESSAGE.SET_TOKEN('PROC' ,'CORE_DOMAIN');
    FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END CORE_DOMAIN;





END HZ_EMAIL_DOMAINS_V2PUB;



/
