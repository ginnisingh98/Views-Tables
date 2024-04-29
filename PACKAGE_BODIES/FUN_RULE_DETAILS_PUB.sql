--------------------------------------------------------
--  DDL for Package Body FUN_RULE_DETAILS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_RULE_DETAILS_PUB" AS
/*$Header: FUNXTMRULRDTPUB.pls 120.0 2005/06/20 04:30:02 ammishra noship $ */


------------------------------------
-- declaration of private procedures
------------------------------------


PROCEDURE do_create_rule_detail(
    p_rule_detail_rec        IN OUT    NOCOPY RULE_DETAILS_REC_TYPE,
    x_rule_detail_id                     OUT NOCOPY    NUMBER,
    x_return_status        IN OUT NOCOPY    VARCHAR2
);

PROCEDURE do_update_rule_detail(
    p_rule_detail_rec         IN OUT   NOCOPY RULE_DETAILS_REC_TYPE,
    p_object_version_number IN OUT NOCOPY   NUMBER,
    x_return_status         IN OUT NOCOPY   VARCHAR2
);


--------------------------------------
-- private procedures and functions
--------------------------------------

/*===========================================================================+
 | PROCEDURE
 |              do_create_rule_detail
 |
 | DESCRIPTION
 |              Creates rules record
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |                    p_rule_detail_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |          10-Sep-2004    Amulya Mishra         Created.
 +===========================================================================*/

PROCEDURE do_create_rule_detail(
    p_rule_detail_rec        IN OUT    NOCOPY RULE_DETAILS_REC_TYPE,
    x_rule_detail_id                     OUT NOCOPY    NUMBER,
    x_return_status        IN OUT NOCOPY    VARCHAR2
) IS

    l_rowid                      rowid;
BEGIN

   -- validate the input record


    FUN_RULE_VALIDATE_PKG.validate_rule_details(
      'C',
      p_rule_detail_rec,
      l_rowid,
      x_return_status
    );
    IF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    END IF;


    FUN_RULE_DETAILS_PKG.Insert_Row (
        X_ROWID                                =>l_rowid,
        X_RULE_DETAIL_ID	               =>p_rule_detail_rec.rule_detail_id,
        X_RULE_OBJECT_ID                       =>p_rule_detail_rec.rule_object_id,
        X_RULE_NAME		               =>p_rule_detail_rec.rule_name,
        X_SEQ			               =>p_rule_detail_rec.seq,
        X_OPERATOR                             =>p_rule_detail_rec.operator,
        X_ENABLED_FLAG                         =>p_rule_detail_rec.enabled_flag,
        X_RESULT_APPLICATION_ID                =>p_rule_detail_rec.result_application_id,
        X_RESULT_VALUE                         =>p_rule_detail_rec.result_value,
        X_CREATED_BY_MODULE                    =>p_rule_detail_rec.created_by_module
    );

    x_rule_detail_id := p_rule_detail_rec.rule_detail_id;


END;

/*===========================================================================+
 | PROCEDURE
 |              do_update_rule_detail
 |
 | DESCRIPTION
 |              Updates rules record
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |                    p_rule_detail_rec
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

PROCEDURE do_update_rule_detail(
    p_rule_detail_rec          IN OUT    NOCOPY RULE_DETAILS_REC_TYPE,
    p_object_version_number     IN OUT NOCOPY  NUMBER,
    x_return_status             IN OUT NOCOPY  VARCHAR2
) IS

    l_object_version_number             NUMBER;
    l_rowid                             ROWID;
BEGIN

    -- check whether record has been updated by another user. If not, lock it.
    BEGIN

        SELECT OBJECT_VERSION_NUMBER,
               ROWID
        INTO   l_object_version_number,
               l_rowid
        FROM   FUN_rule_details
        WHERE RULE_DETAIL_ID = p_rule_detail_rec.rule_detail_id
        AND    RULE_OBJECT_ID     = p_rule_detail_rec.rule_object_id
        FOR UPDATE OF RULE_NAME NOWAIT;


        IF NOT ((p_object_version_number is null and l_object_version_number is null)
                OR (p_object_version_number = l_object_version_number))
        THEN
            FND_MESSAGE.SET_NAME('FUN', 'FUN_RULE_API_RECORD_CHANGED');
            FND_MESSAGE.SET_TOKEN('TABLE', 'FUN_RULE_DETAILS');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        p_object_version_number := nvl(l_object_version_number, 1) + 1;

    EXCEPTION WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('FUN', 'FUN_RULE_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD', 'FUN_RULE_DETAILS');
        FND_MESSAGE.SET_TOKEN('VALUE', 'rule_name');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;

    -- call for validations.
    FUN_RULE_VALIDATE_PKG.validate_rule_details(
      'U',
      p_rule_detail_rec,
      l_rowid,
      x_return_status
    );


    IF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- call to table-handler.

    FUN_RULE_DETAILS_PKG.Update_Row (
        X_RULE_DETAIL_ID	               =>p_rule_detail_rec.rule_detail_id,
        X_RULE_OBJECT_ID                       =>p_rule_detail_rec.rule_object_id,
        X_RULE_NAME		               =>p_rule_detail_rec.rule_name,
        X_SEQ			               =>p_rule_detail_rec.seq,
        X_OPERATOR                             =>p_rule_detail_rec.operator,
        X_ENABLED_FLAG                         =>p_rule_detail_rec.enabled_flag,
        X_RESULT_APPLICATION_ID                =>p_rule_detail_rec.result_application_id,
        X_RESULT_VALUE                         =>p_rule_detail_rec.result_value,
        X_CREATED_BY_MODULE                    =>p_rule_detail_rec.created_by_module
    );

END;

/**
 * PROCEDURE create_rule_detail
 *
 * DESCRIPTION
 *     Creates User Defined Rules
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_rule_detail_rec              User defined Rules record.
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

PROCEDURE create_rule_detail(
    p_init_msg_list           IN        VARCHAR2 := FND_API.G_FALSE,
    p_rule_detail_rec         IN        RULE_DETAILS_REC_TYPE,
    x_rule_detail_id                     OUT NOCOPY    NUMBER,
    x_return_status           OUT NOCOPY       VARCHAR2,
    x_msg_count               OUT NOCOPY       NUMBER,
    x_msg_data                OUT NOCOPY       VARCHAR2
) IS

    l_rule_detail_rec       RULE_DETAILS_REC_TYPE:= p_rule_detail_rec;

BEGIN

    -- standard start of API savepoint
    SAVEPOINT create_rule_detail;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- call to business logic.
    do_create_rule_detail(
                             l_rule_detail_rec,
                             x_rule_detail_id,
                             x_return_status);

    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_rule_detail;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_rule_detail;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO create_rule_detail;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('FUN', 'FUN_RULE_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
END create_rule_detail;

/**
 * PROCEDURE update_rule_detail
 *
 * DESCRIPTION
 *     Updates A Rule
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_rule_detail_rec              User defined Rules record.
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

PROCEDURE update_rule_detail(
    p_init_msg_list             IN     VARCHAR2 := FND_API.G_FALSE,
    p_rule_detail_rec          IN     rule_details_REC_TYPE,
    p_object_version_number     IN OUT NOCOPY NUMBER,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2
) IS

    l_rule_detail_rec                      rule_details_REC_TYPE := p_rule_detail_rec;
    l_old_rule_detail_rec                  rule_details_REC_TYPE;

BEGIN
    -- standard start of API savepoint
    SAVEPOINT update_rule_detail;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Get old records. Will be used by business event system.
    get_rule_detail_rec (
        p_rule_detail_id                    => l_rule_detail_rec.rule_detail_id,
        p_rule_object_id                    => l_rule_detail_rec.rule_object_id,
        x_rule_detail_rec                   => l_old_rule_detail_rec,
        x_return_status                     => x_return_status,
        x_msg_count                         => x_msg_count,
        x_msg_data                          => x_msg_data );

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- call to business logic.
    do_update_rule_detail(
                             l_rule_detail_rec,
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
        ROLLBACK TO update_rule_detail;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_rule_detail;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO update_rule_detail;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

	IF( INSTR(SQLERRM, 'FUN_RULE_DETAILS_U2') > 0 ) THEN
          FND_MESSAGE.SET_NAME('FUN', 'FUN_RULE_DUPLICATE_RULE_NAME');
        ELSE
          FND_MESSAGE.SET_NAME('FUN', 'FUN_RULE_API_OTHERS_EXCEP');
          FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        END IF;

        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
END update_rule_detail;


/**
 * PROCEDURE get_rule_detail_rec
 *
 * DESCRIPTION
 *     Gets user defined Rules record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     FUN_rule_details_PKG.Select_Row
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_rule_detail_id               Rule Id.
 *   IN/OUT:
 *   OUT:
 *     x_rule_detail_rec              Returns Rules record.
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

PROCEDURE get_rule_detail_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_rule_detail_id                        IN     NUMBER,
    p_rule_object_id	                    IN     NUMBER,
    x_rule_detail_rec	                    OUT    NOCOPY RULE_DETAILS_REC_TYPE,
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

/*
    --We can update the Rule Name. So we should not check for

    --Check whether primary key has been passed in.
    IF p_rule_detail_id IS NULL OR
       p_rule_detail_id = FND_API.G_MISS_NUM THEN
        FND_MESSAGE.SET_NAME( 'FUN', 'FUN_RULE_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'rule_name' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
*/

    x_rule_detail_rec.rule_detail_id := p_rule_detail_id;
    x_rule_detail_rec.rule_object_id := p_rule_object_id;

    FUN_RULE_DETAILS_PKG.Select_Row (
        X_RULE_NAME                       =>x_rule_detail_rec.rule_name,
	X_RULE_DETAIL_ID                  =>x_rule_detail_rec.rule_detail_id,
	X_RULE_OBJECT_ID                  =>x_rule_detail_rec.rule_object_id,
	X_SEQ                             =>x_rule_detail_rec.seq,
	X_OPERATOR                        =>x_rule_detail_rec.operator,
	X_ENABLED_FLAG                    =>x_rule_detail_rec.enabled_flag,
	X_RESULT_APPLICATION_ID           =>x_rule_detail_rec.result_application_id,
	X_RESULT_VALUE                    =>x_rule_detail_rec.result_value,
	X_CREATED_BY_MODULE               =>x_rule_detail_rec.created_by_module
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

END get_rule_detail_rec;


/**
 * PROCEDURE delete_rule_detail
 *
 * DESCRIPTION
 *     Deletes A Rule.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_rule_name                    Rule Name.
 *     p_rule_object_id               Rule Object Id
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

PROCEDURE delete_rule_detail(
    p_init_msg_list           IN        VARCHAR2 := FND_API.G_FALSE,
    p_rule_name               IN        VARCHAR2,
    p_rule_object_id	      IN        NUMBER,
    x_return_status           OUT NOCOPY       VARCHAR2,
    x_msg_count               OUT NOCOPY       NUMBER,
    x_msg_data                OUT NOCOPY       VARCHAR2
) IS

  l_rule_detail_id NUMBER;

BEGIN

    -- standard start of API savepoint
    SAVEPOINT delete_rule_detail;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT rule_detail_id INTO l_rule_detail_id
    FROM fun_rule_details
    WHERE rule_object_id = p_rule_object_id
    AND rule_name = p_rule_name;

    -- call to table-handler.
    FUN_RULE_DETAILS_PKG.Delete_Row (
        X_RULE_DETAIL_ID => l_rule_detail_id
    );


    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO delete_rule_detail;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO delete_rule_detail;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO delete_rule_detail;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('FUN', 'FUN_RULE_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
END delete_rule_detail;

END FUN_RULE_DETAILS_PUB;

/
