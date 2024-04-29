--------------------------------------------------------
--  DDL for Package Body FUN_RICH_MESSAGES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_RICH_MESSAGES_PUB" AS
/*$Header: FUNXTMRULRTMPUB.pls 120.0 2005/06/20 04:30:08 ammishra noship $ */


------------------------------------
-- declaration of private procedures
------------------------------------


PROCEDURE do_create_rich_messages(
    p_rich_messages_rec     IN OUT NOCOPY RICH_MESSAGES_REC_TYPE,
    p_message_text          IN OUT NOCOPY CLOB,
    x_message_name          OUT NOCOPY    VARCHAR2,
    x_return_status        IN OUT NOCOPY VARCHAR2
);

PROCEDURE do_update_rich_messages(
    p_rich_messages_rec      IN OUT NOCOPY RICH_MESSAGES_REC_TYPE,
    p_message_text          IN OUT NOCOPY CLOB,
    p_object_version_number IN OUT NOCOPY   NUMBER,
    x_return_status         IN OUT NOCOPY   VARCHAR2
);


--------------------------------------
-- private procedures and functions
--------------------------------------

/*===========================================================================+
 | PROCEDURE
 |              do_create_rich_messages
 |
 | DESCRIPTION
 |              Creates Rich Text Messages
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |                    p_rich_messages_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |          10-Sep-2004    Amulya Mishra         Created.
 +===========================================================================*/

PROCEDURE do_create_rich_messages(
    p_rich_messages_rec     IN OUT NOCOPY RICH_MESSAGES_REC_TYPE,
    p_message_text          IN OUT NOCOPY CLOB,
    x_message_name          OUT NOCOPY    VARCHAR2,
    x_return_status        IN OUT NOCOPY VARCHAR2
) IS

    l_rowid                      rowid:= NULL;


BEGIN


   -- validate the input record
    FUN_RULE_VALIDATE_PKG.validate_rich_messages(
      'C',
      p_rich_messages_rec,
      l_rowid,
      x_return_status
    );



    IF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    END IF;



    FUN_RICH_MESSAGES_PKG.Insert_Row (
        X_ROWID                                =>l_rowid,
        X_APPLICATION_ID                       =>p_rich_messages_rec.application_id,
        X_MESSAGE_TEXT                         =>p_message_text,
        X_MESSAGE_NAME                         =>p_rich_messages_rec.MESSAGE_NAME,
        X_CREATED_BY_MODULE                    =>p_rich_messages_rec.created_by_module
    );



END;

/*===========================================================================+
 | PROCEDURE
 |              do_update_rich_messages
 |
 | DESCRIPTION
 |              Updates Rich Text Messages
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |                    p_rich_messages_rec
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

PROCEDURE do_update_rich_messages(
    p_rich_messages_rec         IN OUT    NOCOPY RICH_MESSAGES_REC_TYPE,
    p_message_text              IN OUT NOCOPY CLOB,
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
        FROM   FUN_RICH_MESSAGES_B
        WHERE  MESSAGE_NAME = p_rich_messages_rec.message_name
        AND    APPLICATION_ID     = p_rich_messages_rec.application_id
        FOR UPDATE OF MESSAGE_NAME NOWAIT;


        IF NOT ((p_object_version_number is null and l_object_version_number is null)
                OR (p_object_version_number = l_object_version_number))
        THEN

            FND_MESSAGE.SET_NAME('FUN', 'FUN_RULE_API_RECORD_CHANGED');
            FND_MESSAGE.SET_TOKEN('TABLE', 'FUN_RICH_MESSAGES');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        p_object_version_number := nvl(l_object_version_number, 1) + 1;

    EXCEPTION WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('FUN', 'FUN_RULE_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD', 'FUN_RICH_MESSAGES');
        FND_MESSAGE.SET_TOKEN('VALUE', 'MESSAGE_NAME');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;


    -- call for validations.
    FUN_RULE_VALIDATE_PKG.validate_rich_messages(
      'U',
      p_rich_messages_rec,
      l_rowid,
      x_return_status
    );


    IF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    -- call to table-handler.
    FUN_RICH_MESSAGES_PKG.Update_Row (
        X_APPLICATION_ID                       =>p_rich_messages_rec.application_id,
        X_MESSAGE_TEXT                         =>p_message_text,
        X_MESSAGE_NAME                         =>p_rich_messages_rec.message_name,
        X_CREATED_BY_MODULE                    =>p_rich_messages_rec.created_by_module
    );

END;

/**
 * PROCEDURE create_rich_messages
 *
 * DESCRIPTION
 *     Creates Riche Text Messages.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_rich_messages_rec            Rich text Messages record.
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

PROCEDURE create_rich_messages(
    p_init_msg_list           		 IN      VARCHAR2 := FND_API.G_FALSE,
    p_rich_messages_rec     		 IN      RICH_MESSAGES_REC_TYPE,
    p_message_text                       IN      CLOB,
    x_message_name                       OUT NOCOPY    VARCHAR2,
    x_return_status           		 OUT NOCOPY     VARCHAR2,
    x_msg_count               		 OUT NOCOPY     NUMBER,
    x_msg_data                		 OUT NOCOPY     VARCHAR2
) IS

    l_rich_messages_rec       RICH_MESSAGES_REC_TYPE:= p_rich_messages_rec;
    l_message_text                       CLOB := p_message_text;

BEGIN

    -- standard start of API savepoint
    SAVEPOINT create_rich_messages;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;



    -- call to business logic.
    do_create_rich_messages(
                             l_rich_messages_rec,
                             l_rich_messages_rec.message_name,
                             l_message_text,
                             x_return_status);


    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_rich_messages;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_rich_messages;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO create_rich_messages;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('FUN', 'FUN_RULE_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
END create_rich_messages;

/**
 * PROCEDURE update_rich_messages
 *
 * DESCRIPTION
 *     Updates Rich Text Messages
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_rich_messages_rec            Rich Text Message record.
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

PROCEDURE update_rich_messages (
    p_init_msg_list           		 IN      VARCHAR2 := FND_API.G_FALSE,
    p_rich_messages_rec    		 IN      RICH_MESSAGES_REC_TYPE,
    p_message_text                       IN      CLOB,
    p_object_version_number  		 IN OUT NOCOPY  NUMBER,
    x_return_status       		 OUT NOCOPY     VARCHAR2,
    x_msg_count           		 OUT NOCOPY     NUMBER,
    x_msg_data         			 OUT NOCOPY     VARCHAR2
) IS

    l_rich_messages_rec                  RICH_MESSAGES_REC_TYPE := p_rich_messages_rec;
    l_old_rich_messages_rec              RICH_MESSAGES_REC_TYPE;
    l_message_text                       CLOB := p_message_text;

BEGIN
    -- standard start of API savepoint
    SAVEPOINT update_rich_messages;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Get old records. Will be used by business event system.
    get_rich_messages_rec (
        p_message_name                      => l_rich_messages_rec.message_name,
        p_application_id                    => l_rich_messages_rec.application_id,
        x_message_text                      => l_message_text,
        x_rich_messages_rec                 => l_old_rich_messages_rec,
        x_return_status                     => x_return_status,
        x_msg_count                         => x_msg_count,
        x_msg_data                          => x_msg_data );

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- call to business logic.
    do_update_rich_messages(
                             l_rich_messages_rec,
                             l_message_text,
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
        ROLLBACK TO update_rich_messages;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_rich_messages;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO update_rich_messages;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('FUN', 'FUN_RULE_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
END update_rich_messages;


/**
 * PROCEDURE get_rich_messages_rec
 *
 * DESCRIPTION
 *     Gets Rich Text Message record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     FUN_RICH_MESSAGES_PKG.Select_Row
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_message_name                 Rich Text Message name.
 *     p_application_id               Application Id
 *     p_language_code                Language code.
 *   IN/OUT:
 *   OUT:
 *     x_rich_messages_rec            Returns Rich Text Message record.
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

PROCEDURE get_rich_messages_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_message_name                          IN     VARCHAR2,
    p_application_id                        IN     NUMBER,
    x_message_text                          OUT    NOCOPY CLOB,
    x_rich_messages_rec        	            OUT    NOCOPY RICH_MESSAGES_REC_TYPE,
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
    IF p_message_name IS NULL OR
       p_message_name = FND_API.G_MISS_CHAR THEN
        FND_MESSAGE.SET_NAME( 'FUN', 'FUN_RULE_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'p_message_name' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    x_rich_messages_rec.message_name := p_message_name;
    x_rich_messages_rec.application_id := p_application_id;

    FUN_RICH_MESSAGES_PKG.Select_Row (
	X_APPLICATION_ID                       =>x_rich_messages_rec.application_id,
	X_MESSAGE_NAME                         =>x_rich_messages_rec.message_name,
	X_MESSAGE_TEXT                         =>x_message_text,
	X_CREATED_BY_MODULE                    =>x_rich_messages_rec.created_by_module
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

END get_rich_messages_rec;

/**
 * PROCEDURE delete_RICH_MESSAGES
 *
 * DESCRIPTION
 *     Deletes Rich Text Message.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_message_name                 Message Name.
 *     p_application_id               Application Id
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

PROCEDURE delete_RICH_MESSAGES(
    p_init_msg_list           IN        VARCHAR2 := FND_API.G_FALSE,
    p_message_name            IN        VARCHAR2,
    p_language_code           IN        VARCHAR2,
    p_application_id	      IN        NUMBER,
    x_return_status           OUT NOCOPY       VARCHAR2,
    x_msg_count               OUT NOCOPY       NUMBER,
    x_msg_data                OUT NOCOPY       VARCHAR2
) IS


BEGIN

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- call to table-handler.
    FUN_RICH_MESSAGES_PKG.Delete_Row (
        X_MESSAGE_NAME                     =>p_message_name,
        X_APPLICATION_ID                   =>p_application_id
    );

    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);



EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO delete_rich_messages;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO delete_rich_messages;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO delete_rich_messages;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('FUN', 'FUN_RULE_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
END delete_rich_messages;


END FUN_RICH_MESSAGES_PUB;

/
