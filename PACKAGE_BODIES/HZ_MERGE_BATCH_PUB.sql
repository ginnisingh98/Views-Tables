--------------------------------------------------------
--  DDL for Package Body HZ_MERGE_BATCH_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_MERGE_BATCH_PUB" AS
/*$Header: ARHMGBTB.pls 115.2 2002/11/21 19:56:22 sponnamb noship $ */

----------------------------------
-- declaration of global variables
----------------------------------

G_PKG_NAME CONSTANT VARCHAR2(30) := 'HZ_MERGE_BATCH_PUB';

------------------------------------
-- declaration of private procedures
------------------------------------

PROCEDURE do_create_merge_batch(
    p_batch_name                        IN  VARCHAR2,
    p_batch_commit                      IN VARCHAR2,
    p_batch_delete                      IN VARCHAR2,
    p_merge_reason_code                 IN VARCHAR2,
    x_batch_id                   OUT NOCOPY     NUMBER,
    x_return_status              IN OUT NOCOPY  VARCHAR2
);

PROCEDURE validate_merge_batch (
    p_create_update_flag             IN     VARCHAR2,
    p_batch_name                 IN VARCHAR2,
    p_batch_commit               IN VARCHAR2,
    p_batch_delete               IN VARCHAR2,
    p_merge_reason_code         IN VARCHAR2,
    x_return_status              IN OUT NOCOPY VARCHAR2);



-----------------------------
-- body of private procedures
-----------------------------

/**==========================================================================+
 | PROCEDURE
 |              do_create_batch
 |
 | DESCRIPTION
 |              Creates batch.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_batch_id
 |          IN/ OUT:
 |                    p_batch_name,
 |                    p_batch_commit,
 |                    p_batch_delete,
 |                    p_merge_reason_code,
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================**/
PROCEDURE do_create_merge_batch(
    p_batch_name                        IN  VARCHAR2,
    p_batch_commit                      IN VARCHAR2,
    p_batch_delete                      IN VARCHAR2,
    p_merge_reason_code                 IN VARCHAR2,
    x_batch_id                   OUT NOCOPY     NUMBER,
    x_return_status              IN OUT NOCOPY  VARCHAR2
    ) IS


BEGIN

    x_batch_id  := NULL;

    -- validate the merge_batch _rec record
    HZ_MERGE_BATCH_PUB.validate_merge_batch(
     'C'     ,
     p_batch_name,
     p_batch_commit,
     p_batch_delete,
     p_merge_reason_code,
     x_return_status);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- call table-handler to insert the record
 HZ_MERGE_BATCH_PKG.INSERT_ROW(
          px_BATCH_ID   => x_batch_id,
          p_RULE_SET_NAME   => 'DEFAULT',
          p_BATCH_NAME   =>  p_BATCH_NAME,
          p_REQUEST_ID    => HZ_UTILITY_PUB.REQUEST_ID,
          p_BATCH_STATUS    => 'PENDING',
          p_BATCH_COMMIT    => p_BATCH_COMMIT,
          p_BATCH_DELETE    => p_BATCH_DELETE,
          p_MERGE_REASON_CODE    => p_MERGE_REASON_CODE,
          p_CREATED_BY    => HZ_UTILITY_PUB.CREATED_BY,
          p_CREATION_DATE  =>  HZ_UTILITY_PUB.CREATION_DATE,
          p_LAST_UPDATE_LOGIN  =>  HZ_UTILITY_PUB.LAST_UPDATE_LOGIN,
          p_LAST_UPDATE_DATE    =>HZ_UTILITY_PUB.LAST_UPDATE_DATE,
          p_LAST_UPDATED_BY  =>  HZ_UTILITY_PUB.LAST_UPDATED_BY);


END do_create_merge_batch;


PROCEDURE validate_merge_batch (
    p_create_update_flag             IN     VARCHAR2,
    p_batch_name                 IN VARCHAR2,
    p_batch_commit               IN VARCHAR2,
    p_batch_delete               IN VARCHAR2,
    p_merge_reason_code         IN VARCHAR2,
    x_return_status              IN OUT NOCOPY VARCHAR2

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


END validate_merge_batch;



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

procedure create_merge_batch (
    p_api_version                IN    NUMBER,
    p_init_msg_list              IN    VARCHAR2:= FND_API.G_FALSE,
    p_commit                     IN    VARCHAR2:= FND_API.G_FALSE,
    p_batch_name                 IN VARCHAR2,
    p_batch_commit               IN VARCHAR2,
    p_batch_delete               IN VARCHAR2,
    p_merge_reason_code          IN VARCHAR2,
    x_return_status              OUT NOCOPY    VARCHAR2,
    x_msg_count                  OUT NOCOPY    NUMBER,
    x_msg_data                   OUT NOCOPY    VARCHAR2,
    x_batch_id                   OUT NOCOPY    NUMBER,
    p_validation_level           IN    NUMBER:= FND_API.G_VALID_LEVEL_FULL
) IS

    l_api_name              CONSTANT    VARCHAR2(30) := 'create_merge_batch';
    l_api_version           CONSTANT    NUMBER       := 1.0;

    l_batch_name        VARCHAR2(30) :=   p_batch_name;
    l_batch_commit      VARCHAR2(1)  :=   p_batch_commit;
    l_batch_delete      VARCHAR2(1)  :=   p_batch_delete;
    l_merge_reason_code VARCHAR2(30) :=  p_merge_reason_code;

BEGIN

    -- standard start of API savepoint
    SAVEPOINT create_merge_batch;


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
    do_create_merge_batch(
                      l_batch_name,
                      l_batch_commit,
                      l_batch_delete,
                      l_merge_reason_code,
                      x_batch_id,
                      x_return_status);

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
        ROLLBACK TO create_merge_batch;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_merge_batch;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);

    WHEN OTHERS THEN

        ROLLBACK TO create_merge_batch;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
                        p_encoded => FND_API.G_FALSE,
                        p_count => x_msg_count,
                        p_data  => x_msg_data);

END create_merge_batch;
END HZ_MERGE_BATCH_PUB;

/
