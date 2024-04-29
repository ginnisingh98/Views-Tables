--------------------------------------------------------
--  DDL for Package Body HZ_MERGE_PARTIES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_MERGE_PARTIES_PUB" AS
/*$Header: ARHMRGPB.pls 120.9 2005/12/06 06:25:41 ansingha noship $ */

----------------------------------
-- declaration of global variables
----------------------------------

G_PKG_NAME CONSTANT VARCHAR2(30) := 'HZ_MERGE_PARTIES_PUB';

------------------------------------
-- declaration of private procedures
------------------------------------

PROCEDURE do_create_merge_party(
    p_batch_id                        IN  NUMBER,
    p_merge_type                      IN VARCHAR2,
    p_from_party_id                   IN NUMBER,
    p_to_party_id                     IN NUMBER,
    p_merge_reason_code               IN VARCHAR2,
    x_batch_party_id                  OUT NOCOPY    NUMBER,
    x_return_status                   IN OUT NOCOPY VARCHAR2
);

---for validating lookup code merge_reason_code
PROCEDURE validate_merge_party (
    p_create_update_flag             IN     VARCHAR2,
    p_batch_id                        IN  NUMBER,
    p_merge_type                      IN VARCHAR2,
    p_from_party_id                   IN NUMBER,
    p_to_party_id                     IN NUMBER,
    p_merge_reason_code               IN VARCHAR2,
    x_return_status              IN OUT NOCOPY VARCHAR2);


 PROCEDURE check_party_hq(cp_batch_id      IN NUMBER,
                          cp_from_party_id IN NUMBER,
                          cp_to_party_id   IN NUMBER);

 PROCEDURE insert_party_details(cp_batch_party_id IN NUMBER,
                                cp_from_party_id IN NUMBER,
                                cp_to_party_id IN NUMBER);


  PROCEDURE insert_reln_parties(cp_batch_party_id IN NUMBER,
                                cp_batch_id       IN NUMBER);


-----------------------------
-- body of private procedures
-----------------------------

/**==========================================================================+
 | PROCEDURE
 |              do_create_party
 |
 | DESCRIPTION
 |              Creates party.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_batch_party_id
 |          IN/ OUT:
 |                    p_batch_id,
 |                    p_merge_type
 |                    p_from_party_id
 |                    p_to_party_id
 |                    p_merge_reason_code
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================**/
PROCEDURE do_create_merge_party(
          p_batch_id                        IN  NUMBER,
          p_merge_type                      IN VARCHAR2,
          p_from_party_id                   IN NUMBER,
          p_to_party_id                     IN NUMBER,
          p_merge_reason_code               IN VARCHAR2,
          x_batch_party_id                  OUT NOCOPY    NUMBER,
          x_return_status                   IN OUT NOCOPY VARCHAR2
          ) IS
BEGIN

    x_batch_party_id  := NULL;

    -- validate the merge_batch _rec record
    HZ_MERGE_PARTIES_PUB.validate_merge_party(
     'C'     ,
     p_batch_id,
     p_merge_type,
     p_from_party_id,
     p_to_party_id,
     p_merge_reason_code,
     x_return_status);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --Check the From Party and the HQ Branch
   check_party_hq(p_batch_id      ,
                  p_from_party_id ,
                  p_to_party_id  );



    -- call table-handler to insert the record
 HZ_MERGE_PARTIES_PKG.INSERT_ROW(
          px_BATCH_PARTY_ID   => x_batch_party_id,
          p_batch_id          => p_batch_id,
          p_merge_type        => p_merge_type,
          p_from_party_id     => p_from_party_id,
          p_to_party_id       => p_to_party_id,
          p_merge_reason_code => p_MERGE_REASON_CODE,
          p_merge_status      => 'PENDING',
          p_CREATED_BY        => HZ_UTILITY_PUB.CREATED_BY,
          p_CREATION_DATE     => HZ_UTILITY_PUB.CREATION_DATE,
          p_LAST_UPDATE_LOGIN => HZ_UTILITY_PUB.LAST_UPDATE_LOGIN,
          p_LAST_UPDATE_DATE  => HZ_UTILITY_PUB.LAST_UPDATE_DATE,
          p_LAST_UPDATED_BY   => HZ_UTILITY_PUB.LAST_UPDATED_BY);

END do_create_merge_party;


PROCEDURE insert_party_details( cp_batch_party_id IN NUMBER,
                                cp_from_party_id IN NUMBER,
                                cp_to_party_id   IN NUMBER) IS
BEGIN
    -----Insert Party Site details
   hz_merge_util.insert_party_site_details(
         cp_from_party_id,
         cp_to_party_id,
         cp_batch_party_id,
         HZ_UTILITY_PUB.CREATED_BY,
         HZ_UTILITY_PUB.CREATION_DATE,
         HZ_UTILITY_PUB.LAST_UPDATE_LOGIN,
         HZ_UTILITY_PUB.LAST_UPDATE_DATE,
         HZ_UTILITY_PUB.LAST_UPDATED_BY);

  -----Insert Party Relations details
     hz_merge_util.insert_party_reln_details(
         cp_from_party_id,
         cp_to_party_id,
         cp_batch_party_id,
         HZ_UTILITY_PUB.CREATED_BY,
         HZ_UTILITY_PUB.CREATION_DATE,
         HZ_UTILITY_PUB.LAST_UPDATE_LOGIN,
         HZ_UTILITY_PUB.LAST_UPDATE_DATE,
         HZ_UTILITY_PUB.LAST_UPDATED_BY);

  END insert_party_details;


PROCEDURE insert_reln_parties(  cp_batch_party_id       IN NUMBER,
                                cp_batch_id IN NUMBER)IS

  CURSOR merged_relns(cp_batch_party_id NUMBER) IS
    SELECT merge_from_entity_id, merge_to_entity_id,
    HZ_MERGE_UTIL.get_reln_party_id(merge_from_entity_id) from_reln_party_id,
    HZ_MERGE_UTIL.get_reln_party_id(merge_to_entity_id) to_reln_party_id
    FROM hz_merge_party_details
    WHERE batch_party_id = cp_batch_party_id
    AND entity_name = 'HZ_PARTY_RELATIONSHIPS'
    AND merge_to_entity_id IS NOT NULL
    AND merge_from_entity_id IS NOT NULL
    AND merge_from_entity_id <> merge_to_entity_id;

l_from_rel_id NUMBER := NULL;
l_to_rel_id NUMBER := NULL;
l_from_reln_party_id NUMBER := NULL;
l_to_reln_party_id NUMBER := NULL;

l_batch_party_id NUMBER := NULL;

num NUMBER := 0;
BEGIN


  OPEN merged_relns(cp_batch_party_id);
  LOOP
   FETCH merged_relns INTO l_from_rel_id, l_to_rel_id,
                       l_from_reln_party_id, l_to_reln_party_id;
    EXIT WHEN merged_relns%NOTFOUND;

  /*  IF :BATCH.BATCH_COMMIT = 'R' THEN
      CLOSE merged_relns;
      FND_MESSAGE.set_name('AR', 'HZ_RECORD_COMMIT_NOT_ALLOWED');
      FND_MESSAGE.error;
      RAISE FORM_TRIGGER_FAILURE;
    END IF;*/

    IF l_to_reln_party_id IS NOT NULL AND
         l_from_reln_party_id IS NOT NULL THEN

      l_batch_party_id := null;

         HZ_MERGE_PARTIES_PKG.Insert_Row(
                l_batch_party_id,
                 cp_BATCH_ID,
                'PARTY_MERGE',
                l_from_reln_party_id,
                l_to_reln_party_id,
                'DUPLICATE_RELN_PARTY',
                'PENDING',
                 HZ_UTILITY_PUB.CREATED_BY,
                 HZ_UTILITY_PUB.CREATION_DATE,
                 HZ_UTILITY_PUB.LAST_UPDATE_LOGIN,
                 HZ_UTILITY_PUB.LAST_UPDATE_DATE,
                 HZ_UTILITY_PUB.LAST_UPDATED_BY);

       num := num+1;
    END IF;
  END LOOP;
  CLOSE merged_relns;

 /* BugNo 3024162  Commented the code If num>0 ... END IF;*/
 /* IF num>0 THEN
    fnd_message.set_name('AR','HZ_NUM_RELN_PARTY_REQD');
    fnd_message.set_token('NUM_PARTIES',TO_CHAR(num));
   RAISE FND_API.G_EXC_ERROR;
  END IF;
 */

EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.SET_NAME('AR','HZ_FORM_DUP_PROC_ERROR');
    APP_EXCEPTION.RAISE_EXCEPTION;
END insert_reln_parties;

PROCEDURE check_party_hq( cp_batch_id      IN NUMBER,
                          cp_from_party_id IN NUMBER,
                          cp_to_party_id   IN NUMBER) IS

  l_batch_party_id   HZ_MERGE_PARTIES.BATCH_PARTY_ID%TYPE := NULL;
  l_dummy_count      NUMBER := 0;

 CURSOR c_check_from_party( cp_batch_id IN NUMBER  ,cp_from_party_id IN NUMBER, cp_to_party_id IN NUMBER ) IS
   SELECT batch_party_id
   FROM HZ_MERGE_PARTIES
    WHERE (from_party_id = cp_from_party_id OR
           to_party_id   = cp_to_party_id   OR
           from_party_id = cp_to_party_id   OR
           to_party_id   = cp_from_party_id)
    AND    batch_id = cp_batch_id;

 CURSOR c_check_hq_branch( cp_from_party_id IN NUMBER, cp_to_party_id IN NUMBER ) IS
   SELECT 1
   FROM HZ_RELATIONSHIPS  --4500011
    WHERE content_source_type = 'DNB'
    AND   subject_id = cp_from_party_id
    AND   object_id = cp_to_party_id
    AND   RELATIONSHIP_CODE = 'HEADQUARTERS_OF'
    AND   subject_table_name = 'HZ_PARTIES'
    AND   object_table_name = 'HZ_PARTIES'
    AND   directional_flag = 'F';

 BEGIN
    OPEN c_check_from_party(cp_batch_id ,cp_from_party_id , cp_to_party_id);
    FETCH c_check_from_party INTO l_batch_party_id;
    IF c_check_from_party%FOUND THEN
       CLOSE c_check_from_party;
       FND_MESSAGE.SET_NAME('AR','HZ_PARTY_ALREADY_IN_BATCH');
       -----------Srini y'r msg involves party number etc whose value we don't know here
       FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_check_from_party;

/*OPEN c_check_hq_branch(cp_from_party_id ,cp_to_party_id);
    FETCH c_check_hq_branch INTO l_dummy_count;
    IF c_check_hq_branch%FOUND THEN
       CLOSE c_check_hq_branch;
       FND_MESSAGE.SET_NAME('AR','HZ_DNB_BRANCH');
       -----------y'r msg involves party name etc whose value we don't have
       FND_MESSAGE.SET_TOKEN('ERROR', SQLERRM);
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_check_hq_branch;      */

END CHECK_PARTY_HQ;


PROCEDURE validate_merge_party (
    p_create_update_flag              IN     VARCHAR2,
    p_batch_id                        IN  NUMBER,
    p_merge_type                      IN VARCHAR2,
    p_from_party_id                   IN NUMBER,
    p_to_party_id                     IN NUMBER,
    p_merge_reason_code               IN VARCHAR2,
    x_return_status                   IN OUT  NOCOPY VARCHAR2
) IS

l_dummy                                 VARCHAR2(1);

BEGIN

---------- Validations for Lookup MERGE_REASON_CODE
    IF p_create_update_flag = 'C' AND p_merge_reason_code is NOT NULL
    THEN
        HZ_UTILITY_V2PUB.validate_lookup (
            p_column                                => 'merge_reason_code',
            p_lookup_type                           => 'MERGE_REASON_CODE',
            p_column_value                          => p_merge_reason_code,
            x_return_status                         => x_return_status );
    END IF;


END validate_merge_party;


-----------------------------
-- body of public procedures
-----------------------------



/**==========================================================================+
 | PROCEDURE
 |              create_merge_batch
 |
 | DESCRIPTION
 |              Creates merge_batch.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_api_version
 |                    p_init_msg_list
 |                    p_commit
 |                    p_merge_batch
 |                    p_validation_level
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |                    x_location_id
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================**/

procedure create_merge_party (
    p_api_version                IN    NUMBER,
    p_init_msg_list              IN    VARCHAR2:= FND_API.G_FALSE,
    p_commit                     IN    VARCHAR2:= FND_API.G_FALSE,
    p_batch_id                   IN  NUMBER,
    p_merge_type                 IN VARCHAR2,
    p_from_party_id              IN NUMBER,
    p_to_party_id                IN NUMBER,
    p_merge_reason_code          IN VARCHAR2,
    x_return_status              OUT NOCOPY VARCHAR2,
    x_msg_count                  OUT NOCOPY   NUMBER,
    x_msg_data                   OUT NOCOPY   VARCHAR2,
    x_batch_party_id             OUT NOCOPY   NUMBER,
    p_validation_level           IN    NUMBER:= FND_API.G_VALID_LEVEL_FULL
) IS

    l_api_name              CONSTANT    VARCHAR2(30) := 'create_merge_batch';
    l_api_version           CONSTANT    NUMBER       := 1.0;
    l_batch_id         NUMBER      := p_batch_id;
    l_merge_type       VARCHAR2(30) :=   p_merge_type;
    l_from_party_id    NUMBER  :=   p_from_party_id;
    l_to_party_id      NUMBER  :=   p_to_party_id;
    l_merge_reason_code VARCHAR2(30) :=  p_merge_reason_code;

BEGIN

    -- standard start of API savepoint
    SAVEPOINT create_merge_party;

    -- standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(
                                       l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- call to business logic.
    do_create_merge_party(
                      l_batch_id,
                      l_merge_type,
                      l_from_party_id,
                      l_to_party_id,
                      l_merge_reason_code,
                      x_batch_party_id,
                      x_return_status);



    --Call to insert details
    insert_party_details(x_batch_party_id,
                         l_from_party_id ,
                         l_to_party_id   );

    ---Call to insert relationships
    insert_reln_parties(x_batch_party_id ,
                        l_batch_id      );

    -- standard check of p_commit.
    IF FND_API.to_Boolean(p_commit) THEN
        COMMIT;
    END IF;

    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_merge_party;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_merge_party;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO create_merge_party;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);

END create_merge_party;
END HZ_MERGE_PARTIES_PUB;

/
