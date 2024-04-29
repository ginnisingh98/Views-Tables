--------------------------------------------------------
--  DDL for Package Body FUN_RULE_CRITERIA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_RULE_CRITERIA_PUB" AS
/*$Header: FUNXTMRULRCTPUB.pls 120.0 2005/06/20 04:29:59 ammishra noship $ */


------------------------------------
-- declaration of private procedures
------------------------------------


PROCEDURE do_create_rule_criteria(
    p_rule_criteria_rec        IN OUT    NOCOPY RULE_CRITERIA_REC_TYPE,
    x_criteria_id                        OUT NOCOPY    NUMBER,
    x_return_status        IN OUT NOCOPY    VARCHAR2
);

PROCEDURE do_update_rule_criteria(
    p_rule_criteria_rec         IN OUT   NOCOPY RULE_CRITERIA_REC_TYPE,
    p_object_version_number IN OUT NOCOPY   NUMBER,
    x_return_status         IN OUT NOCOPY   VARCHAR2
);


--------------------------------------
-- private procedures and functions
--------------------------------------

/*===========================================================================+
 | PROCEDURE
 |              do_create_rule_criteria
 |
 | DESCRIPTION
 |              Creates Rule criteria
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |                    p_rule_criteria_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |          10-Sep-2004    Amulya Mishra         Created.
 +===========================================================================*/

PROCEDURE do_create_rule_criteria(
    p_rule_criteria_rec        IN OUT    NOCOPY RULE_CRITERIA_REC_TYPE,
    x_criteria_id                        OUT NOCOPY    NUMBER,
    x_return_status        IN OUT NOCOPY    VARCHAR2
) IS

    l_rowid                      rowid;
BEGIN

   -- validate the input record
    FUN_RULE_VALIDATE_PKG.validate_rule_criteria(
      'C',
      p_rule_criteria_rec,
      l_rowid,
      x_return_status
    );

    IF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- call to table-handler
    FUN_RULE_CRITERIA_PKG.Insert_Row (
	X_ROWID                           =>l_rowid,
	X_CRITERIA_ID                     =>p_rule_criteria_rec.criteria_id,
	X_RULE_DETAIL_ID                  =>p_rule_criteria_rec.rule_detail_id,
	X_CRITERIA_PARAM_ID               =>p_rule_criteria_rec.criteria_param_id,
	X_CONDITION                       =>p_rule_criteria_rec.condition,
	X_PARAM_VALUE                     =>p_rule_criteria_rec.param_value,
	X_CASE_SENSITIVE_FLAG             =>p_rule_criteria_rec.case_sensitive_flag,
	X_CREATED_BY_MODULE               =>p_rule_criteria_rec.created_by_module
    );

    x_criteria_id := p_rule_criteria_rec.criteria_id;

END;

/*===========================================================================+
 | PROCEDURE
 |              do_update_rule_criteria
 |
 | DESCRIPTION
 |              Updates Rule Criteria
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |                    p_rule_criteria_rec
 |                    p_object_version_number
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 +===========================================================================*/

PROCEDURE do_update_rule_criteria(
    p_rule_criteria_rec         IN OUT    NOCOPY RULE_CRITERIA_REC_TYPE,
    p_object_version_number     IN OUT NOCOPY  NUMBER,
    x_return_status             IN OUT NOCOPY  VARCHAR2
) IS

    l_object_version_number             NUMBER;
    l_rowid                             ROWID;

BEGIN

    BEGIN
        SELECT OBJECT_VERSION_NUMBER,
               ROWID
        INTO   l_object_version_number,
               l_rowid
        FROM   FUN_RULE_CRITERIA
        WHERE  CRITERIA_ID = p_rule_criteria_rec.criteria_id
        FOR UPDATE NOWAIT;


        IF NOT ((p_object_version_number is null and l_object_version_number is null)
                OR (p_object_version_number = l_object_version_number))
        THEN

            FND_MESSAGE.SET_NAME('FUN', 'FUN_RULE_API_RECORD_CHANGED');
            FND_MESSAGE.SET_TOKEN('TABLE', 'FUN_RULE_OBJECTS');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        p_object_version_number := nvl(l_object_version_number, 1) + 1;

    EXCEPTION WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('FUN', 'FUN_RULE_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD', 'FUN_RULE_OBJECTS');
        FND_MESSAGE.SET_TOKEN('VALUE', 'rule_object_name');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;


    -- call for validations.
    FUN_RULE_VALIDATE_PKG.validate_rule_criteria(
      'U',
      p_rule_criteria_rec,
      l_rowid,
      x_return_status
    );

    IF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- call to table-handler
    FUN_RULE_CRITERIA_PKG.Update_Row (
	X_CRITERIA_ID                     =>p_rule_criteria_rec.criteria_id,
	X_RULE_DETAIL_ID                  =>p_rule_criteria_rec.rule_detail_id,
	X_CRITERIA_PARAM_ID               =>p_rule_criteria_rec.criteria_param_id,
	X_CONDITION                       =>p_rule_criteria_rec.condition,
	X_PARAM_VALUE                     =>p_rule_criteria_rec.param_value,
	X_CASE_SENSITIVE_FLAG             =>p_rule_criteria_rec.case_sensitive_flag,
	X_CREATED_BY_MODULE               =>p_rule_criteria_rec.created_by_module
    );

END;

/**
 * PROCEDURE create_rule_criteria
 *
 * DESCRIPTION
 *     Creates Rule criteria.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_rule_criteria_rec            Rule Criteria record.
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
 *   10-Sep-2004    Amulya Mishra       Created.
 *
 */

PROCEDURE create_rule_criteria(
    p_init_msg_list           IN        VARCHAR2 := FND_API.G_FALSE,
    p_rule_criteria_rec       IN        RULE_CRITERIA_REC_TYPE,
    x_criteria_id                        OUT NOCOPY    NUMBER,
    x_return_status           OUT NOCOPY       VARCHAR2,
    x_msg_count               OUT NOCOPY       NUMBER,
    x_msg_data                OUT NOCOPY       VARCHAR2
) IS

    l_rule_criteria_rec       RULE_CRITERIA_REC_TYPE:= p_rule_criteria_rec;

BEGIN
    -- standard start of API savepoint
    SAVEPOINT create_rule_criteria;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- call to business logic.
    do_create_rule_criteria(
                             l_rule_criteria_rec,
                             x_criteria_id,
                             x_return_status);

    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_rule_criteria;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_rule_criteria;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO create_rule_criteria;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('FUN', 'FUN_RULE_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
END create_rule_criteria;

/**
 * PROCEDURE update_rule_criteria
 *
 * DESCRIPTION
 *     Updates Rule Criteria
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_rule_criteria_rec            Rule Criteria record.
 *   IN/OUT:
 *     p_object_version_number        Used for locking the being updated record.
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
 *   10-Sep-2004    Amulya Mishra     Created.
 *
 */

PROCEDURE update_rule_criteria (
    p_init_msg_list             IN     VARCHAR2 := FND_API.G_FALSE,
    p_rule_criteria_rec         IN     RULE_CRITERIA_REC_TYPE,
    p_object_version_number     IN OUT NOCOPY NUMBER,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2
) IS

    l_rule_criteria_rec                    RULE_CRITERIA_REC_TYPE := p_rule_criteria_rec;
    l_old_rule_criteria_rec                RULE_CRITERIA_REC_TYPE;

BEGIN
    -- standard start of API savepoint
    SAVEPOINT update_rule_criteria;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;
    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- Get old records. Will be used by business event system.
    get_rule_criteria_rec (
        p_criteria_id                       => l_rule_criteria_rec.criteria_id,
        p_rule_detail_id                    => l_rule_criteria_rec.rule_detail_id,
        x_rule_criteria_rec                 => l_old_rule_criteria_rec,
        x_return_status                     => x_return_status,
        x_msg_count                         => x_msg_count,
        x_msg_data                          => x_msg_data );

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- call to business logic.
    do_update_rule_criteria(
                             l_rule_criteria_rec,
                             p_object_version_number,
                             x_return_status);

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

       -- standard call to get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);
   END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_rule_criteria;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_rule_criteria;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO update_rule_criteria;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('FUN', 'FUN_RULE_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
END update_rule_criteria;


/**
 * PROCEDURE get_rule_criteria_rec
 *
 * DESCRIPTION
 *     Gets Rule Criteria record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     FUN_RULES_PKG.Select_Row
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_criteria_id                  Criteria Id
 *     p_RULE_DETAIL_ID               Rule Id
 *   IN/OUT:
 *   OUT:
 *     x_rule_criteria_rec            Returned Rule Criteria record.
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
 *   10-Sep-2004    Amulya Mishra         Created.
 *
 */

PROCEDURE get_rule_criteria_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_criteria_id                           IN     NUMBER,
    p_rule_detail_id                        IN     NUMBER,
    x_rule_criteria_rec                     OUT    NOCOPY RULE_CRITERIA_REC_TYPE,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) IS

BEGIN
    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Check whether primary key has been passed in.
    IF p_criteria_id IS NULL OR
       p_criteria_id = FND_API.G_MISS_NUM THEN
        FND_MESSAGE.SET_NAME( 'FUN', 'FUN_RULE_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'criteria_id' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_rule_criteria_rec.criteria_id := p_criteria_id;
    x_rule_criteria_rec.rule_detail_id := p_rule_detail_id;



    FUN_RULE_CRITERIA_PKG.Select_Row (
	X_CRITERIA_ID                     =>x_rule_criteria_rec.criteria_id,
	X_RULE_DETAIL_ID                  =>x_rule_criteria_rec.rule_detail_id,
        X_CRITERIA_PARAM_ID               =>x_rule_criteria_rec.criteria_param_id,
	X_CONDITION                       =>x_rule_criteria_rec.condition,
	X_PARAM_VALUE                     =>x_rule_criteria_rec.param_value,
	X_CASE_SENSITIVE_FLAG             =>x_rule_criteria_rec.case_sensitive_flag,
	X_CREATED_BY_MODULE               =>x_rule_criteria_rec.created_by_module
    );


    --Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
        p_encoded => FND_API.G_FALSE,
        p_count => x_msg_count,
        p_data  => x_msg_data );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME( 'FUN', 'FUN_RULE_API_OTHERS_EXCEP' );
        FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
        FND_MSG_PUB.ADD;

        FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );

END get_rule_criteria_rec;


/**
 * PROCEDURE delete_rule_criteria
 *
 * DESCRIPTION
 *     Deletes Rule Criteria.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_criteria_param_name          Criteria Param Name.
 *     p_rule_detail_id               Rule Detail Id
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
 *   10-Sep-2004    Amulya Mishra       Created.
 *
 */

PROCEDURE delete_rule_criteria(
    p_init_msg_list           IN        VARCHAR2 := FND_API.G_FALSE,
    p_criteria_id             IN NUMBER,
    x_return_status           OUT NOCOPY       VARCHAR2,
    x_msg_count               OUT NOCOPY       NUMBER,
    x_msg_data                OUT NOCOPY       VARCHAR2
) IS


BEGIN

    -- standard start of API savepoint
    SAVEPOINT delete_rule_criteria;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- call to table-handler.
    FUN_RULE_CRITERIA_PKG.Delete_Row (
        X_CRITERIA_ID =>p_criteria_id
    );


    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO delete_rule_criteria;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO delete_rule_criteria;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO delete_rule_criteria;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('FUN', 'FUN_RULE_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
END delete_rule_criteria;

END FUN_RULE_CRITERIA_PUB;

/
