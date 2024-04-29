--------------------------------------------------------
--  DDL for Package Body FUN_RULE_OBJECTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_RULE_OBJECTS_PUB" AS
/*$Header: FUNXTMRULROBPUB.pls 120.8.12010000.2 2008/08/06 07:44:30 makansal ship $ */


------------------------------------
-- declaration of private procedures
------------------------------------


PROCEDURE do_create_rule_object(
    p_rule_object_rec     IN OUT NOCOPY RULE_OBJECTS_REC_TYPE,
    x_rule_object_id       OUT NOCOPY    NUMBER,
    x_return_status        IN OUT NOCOPY VARCHAR2
);

PROCEDURE do_create_rule_object_instance(
    p_application_id     IN      NUMBER,
    p_rule_object_name   IN      VARCHAR2,
    p_instance_label     IN      VARCHAR2,
    p_org_id             IN      NUMBER,
    x_rule_object_id     OUT NOCOPY    NUMBER,
    x_return_status      IN OUT NOCOPY VARCHAR2
);

PROCEDURE do_update_rule_object(
    p_update_instance     IN VARCHAR2 DEFAULT 'N',
    p_rule_object_rec      IN OUT NOCOPY RULE_OBJECTS_REC_TYPE,
    p_object_version_number IN OUT NOCOPY   NUMBER,
    x_return_status         IN OUT NOCOPY   VARCHAR2
);

--------------------------------------
-- private procedures and functions
--------------------------------------

/*===========================================================================+
 | PROCEDURE
 |              do_create_rule_object
 |
 | DESCRIPTION
 |              Creates user customizable objects
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |                    p_rule_object_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |          10-Sep-2004    Amulya Mishra         Created.
 +===========================================================================*/

PROCEDURE do_create_rule_object(
    p_rule_object_rec     IN OUT NOCOPY RULE_OBJECTS_REC_TYPE,
    x_rule_object_id       OUT NOCOPY    NUMBER,
    x_return_status        IN OUT NOCOPY VARCHAR2
) IS

    l_rowid                      rowid:= NULL;

BEGIN
   -- validate the input record
    FUN_RULE_VALIDATE_PKG.validate_rule_objects(
      'C',
      p_rule_object_rec,
      l_rowid,
      x_return_status
    );

    IF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    /********************************************************************************
      Dont pass X_INSTANCE_LABEL,X_PARENT_RULE_OBJECT_ID,X_ORG_ID
      on in this API the Rule Object Instance Information. Because, create_rule_object
      API will not be used to create the Rule Object Instance.
    *********************************************************************************/

    FUN_RULE_OBJECTS_PKG.Insert_Row (
        X_ROWID                                =>l_rowid,
        X_RULE_OBJECT_ID                       =>p_rule_object_rec.rule_object_id,
        X_APPLICATION_ID                       =>p_rule_object_rec.application_id,
        X_RULE_OBJECT_NAME                     =>p_rule_object_rec.rule_object_name,
        X_RESULT_TYPE                          =>p_rule_object_rec.result_type,
        X_REQUIRED_FLAG                        =>p_rule_object_rec.required_flag,
        X_USE_DEFAULT_VALUE_FLAG               =>p_rule_object_rec.use_default_value_flag,
        X_DEFAULT_APPLICATION_ID               =>p_rule_object_rec.default_application_id,
        X_DEFAULT_VALUE                        =>p_rule_object_rec.default_value,
        X_FLEX_VALUE_SET_ID                    =>p_rule_object_rec.flex_value_set_id,
        X_FLEXFIELD_NAME                       =>p_rule_object_rec.flexfield_name,
        X_FLEXFIELD_APP_SHORT_NAME             =>p_rule_object_rec.flexfield_app_short_name,
	X_MULTI_RULE_RESULT_FLAG               =>p_rule_object_rec.multi_rule_result_flag,
        X_CREATED_BY_MODULE                    =>p_rule_object_rec.created_by_module,
        X_USER_RULE_OBJECT_NAME                =>p_rule_object_rec.user_rule_object_name,
        X_DESCRIPTION                          =>p_rule_object_rec.description,
        X_USE_INSTANCE_FLAG                    =>p_rule_object_rec.use_instance_flag
    );

END;

/*===========================================================================+
 | PROCEDURE
 |              do_create_rule_object_instance
 |
 | DESCRIPTION
 |              Creates Rule object Instance
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |                    p_rule_object_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |          27-DEC-2005    Amulya Mishra         Created.
 +===========================================================================*/

PROCEDURE do_create_rule_object_instance(
    p_application_id     IN      NUMBER,
    p_rule_object_name   IN      VARCHAR2,
    p_instance_label     IN      VARCHAR2,
    p_org_id             IN      NUMBER,
    x_rule_object_id     OUT NOCOPY    NUMBER,
    x_return_status      IN OUT NOCOPY VARCHAR2
) IS

    l_rowid                      rowid:= NULL;
    l_orig_rule_object_rec       RULE_OBJECTS_REC_TYPE;
    l_rule_object_instance_rec   RULE_OBJECTS_REC_TYPE;
    l_rule_object_id             FUN_RULE_OBJECTS_B.RULE_OBJECT_ID%TYPE;

    x_msg_count                  number;
    x_msg_data                   varchar2(2000);

BEGIN

    -- Get old records. Will be used by logic to create Rule Object Instance.
    -- Before creating the Rule Object Instance for a Rule Object Name, we
    -- need to check if the original rule object instance exists or not.
    -- So explicitly pass p_instance_label as NULL.


    get_rule_object_rec (
        p_rule_object_name                  => p_rule_object_name,
        p_application_id                    => P_application_id,
	p_instance_label                    => NULL,
        p_org_id                            => NULL,
        x_rule_object_rec                   => l_orig_rule_object_rec,
        x_return_status                     => x_return_status,
        x_msg_count                         => x_msg_count,
        x_msg_data                          => x_msg_data );


    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Validate if the parent rule object has use_instance_flag as Y or not.
    --If not, then we will raise user defined exception and come out.

    IF  (NOT UPPER(l_orig_rule_object_rec.use_instance_flag) = 'Y') THEN
      fnd_message.set_name('FUN', 'FUN_RULE_NO_CREATE_ROB_INST');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
      RAISE FND_API.G_EXC_ERROR;
    END IF;


   --If we have reached here, that means we have got the Rule Object Name for which
   --we want to create Rule Object Instance.

   --Assign related values for the instance.
   l_rule_object_instance_rec := l_orig_rule_object_rec;

   l_rule_object_instance_rec.instance_label := p_instance_label;

   --Derive the Rule_Object_Id of original Rule Object and set it as
   --parent_rule_object_id of the instance.

   l_rule_object_instance_rec.parent_rule_object_id := l_orig_rule_object_rec.rule_object_id;
   l_rule_object_instance_rec.org_id := p_org_id;


   -- validate the input record
    FUN_RULE_VALIDATE_PKG.validate_rule_object_instance(
      'C',
      l_rule_object_instance_rec,
      l_rowid,
      x_return_status
    );

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    FUN_RULE_OBJECTS_PKG.Insert_Row (
		X_ROWID                                =>l_rowid,
		X_RULE_OBJECT_ID                       =>NULL,
		X_APPLICATION_ID                       =>l_rule_object_instance_rec.application_id,
		X_RULE_OBJECT_NAME                     =>l_rule_object_instance_rec.rule_object_name,
		X_RESULT_TYPE                          =>l_rule_object_instance_rec.result_type,
		X_REQUIRED_FLAG                        =>l_rule_object_instance_rec.required_flag,
		X_USE_DEFAULT_VALUE_FLAG               =>l_rule_object_instance_rec.use_default_value_flag,
		X_DEFAULT_APPLICATION_ID               =>l_rule_object_instance_rec.default_application_id,
		X_DEFAULT_VALUE                        =>l_rule_object_instance_rec.default_value,
		X_FLEX_VALUE_SET_ID                    =>l_rule_object_instance_rec.flex_value_set_id,
		X_FLEXFIELD_NAME                       =>l_rule_object_instance_rec.flexfield_name,
		X_FLEXFIELD_APP_SHORT_NAME             =>l_rule_object_instance_rec.flexfield_app_short_name,
		X_MULTI_RULE_RESULT_FLAG               =>l_rule_object_instance_rec.multi_rule_result_flag,
		X_CREATED_BY_MODULE                    =>l_rule_object_instance_rec.created_by_module,
		X_USER_RULE_OBJECT_NAME                =>l_rule_object_instance_rec.user_rule_object_name,
		X_DESCRIPTION                          =>l_rule_object_instance_rec.description,
		X_USE_INSTANCE_FLAG                    =>l_rule_object_instance_rec.use_instance_flag,
		X_INSTANCE_LABEL                       =>l_rule_object_instance_rec.instance_label,
		X_PARENT_RULE_OBJECT_ID                =>l_rule_object_instance_rec.parent_rule_object_id,
		X_ORG_ID                               =>l_rule_object_instance_rec.org_id
    );
    --Make sure the Rule Object Instance gets created and then select the Rule Object Id
    --of the new Rule Object Instance.

    BEGIN
	    SELECT RULE_OBJECT_ID INTO X_RULE_OBJECT_ID
	    FROM FUN_RULE_OBJECTS_B WHERE RULE_OBJECT_NAME = p_rule_object_name
	    AND  APPLICATION_ID = p_application_id
            AND ( (INSTANCE_LABEL IS NULL AND p_instance_label IS NULL) OR
 	          (INSTANCE_LABEL IS NOT NULL AND p_instance_label IS NOT NULL AND INSTANCE_LABEL = p_instance_label))
            AND ( (ORG_ID IS NULL AND p_org_id IS NULL) OR
   	          ( ORG_ID IS NOT NULL AND p_org_id IS NOT NULL AND ORG_ID = p_org_id))
            AND PARENT_RULE_OBJECT_ID IS NOT NULL;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
	  fnd_message.set_name('FUN', 'FUN_RULE_API_INVALID_ROB');
	  fnd_msg_pub.add;
	  x_return_status := fnd_api.g_ret_sts_error;
     END;

    /**************************************************************************************
      Since the newly created Rule Object Instance will have the same criteria parameters
      in FUN_RULE_CRIT_PARAMS_B/_TL table, we need to
      Create the Criteria Parameters for the Rule Object Instance with Rule_Object_id
      as X_RULE_OBJECT_ID.
    **************************************************************************************/
    FUN_RULE_CRIT_PARAMS_PUB.CREATE_DUP_RULE_CRIT_PARAMS(
	    p_init_msg_list           => FND_API.G_FALSE,
	    p_from_rule_object_id     => l_orig_rule_object_rec.rule_object_id,
	    p_to_rule_object_id       => X_RULE_OBJECT_ID,
	    x_return_status           => x_return_status,
	    x_msg_count               => x_msg_count,
	    x_msg_data                => x_msg_data);

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
	RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


END do_create_rule_object_instance;


/*===========================================================================+
 | PROCEDURE
 |              do_update_rule_object
 |
 | DESCRIPTION
 |              Updates user customizable objects
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |                    p_rule_object_rec
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

PROCEDURE do_update_rule_object(
    p_update_instance           IN VARCHAR2 DEFAULT 'N',
    p_rule_object_rec           IN OUT    NOCOPY RULE_OBJECTS_REC_TYPE,
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
        FROM   FUN_RULE_OBJECTS_B
        WHERE  RULE_OBJECT_ID = p_rule_object_rec.rule_object_id
        FOR UPDATE OF rule_object_id NOWAIT;


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
        FND_MESSAGE.SET_TOKEN('VALUE', 'rule_object_id'||to_char(p_rule_object_rec.rule_object_id));
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;

    -- call for validations.
    IF(    p_update_instance   = 'Y' ) THEN
      -- call for validations of Rule Object Instance.
      FUN_RULE_VALIDATE_PKG.validate_rule_object_instance(
           'U',
            p_rule_object_rec,
            l_rowid,
            x_return_status
       );
    ELSE
      -- call for validations of Rule Object Record
      FUN_RULE_VALIDATE_PKG.validate_rule_objects(
            'U',
             p_rule_object_rec,
             l_rowid,
             x_return_status
      );
    END IF;

    IF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    END IF;
    -- call to table-handler.
    FUN_RULE_OBJECTS_PKG.Update_Row (
        X_RULE_OBJECT_ID                       =>p_rule_object_rec.rule_object_id,
        X_APPLICATION_ID                       =>p_rule_object_rec.application_id,
        X_RULE_OBJECT_NAME                     =>p_rule_object_rec.rule_object_name,
        X_RESULT_TYPE                          =>p_rule_object_rec.result_type,
        X_REQUIRED_FLAG                        =>p_rule_object_rec.required_flag,
        X_USE_DEFAULT_VALUE_FLAG               =>p_rule_object_rec.use_default_value_flag,
        X_DEFAULT_APPLICATION_ID               =>p_rule_object_rec.default_application_id,
        X_DEFAULT_VALUE                        =>p_rule_object_rec.default_value,
        X_FLEX_VALUE_SET_ID                    =>p_rule_object_rec.flex_value_set_id,
        X_FLEXFIELD_NAME                       =>p_rule_object_rec.flexfield_name,
        X_FLEXFIELD_APP_SHORT_NAME             =>p_rule_object_rec.flexfield_app_short_name,
	X_MULTI_RULE_RESULT_FLAG               =>p_rule_object_rec.multi_rule_result_flag,
        X_OBJECT_VERSION_NUMBER                =>p_object_version_number,
        X_CREATED_BY_MODULE                    =>p_rule_object_rec.created_by_module,
        X_USER_RULE_OBJECT_NAME                =>p_rule_object_rec.user_rule_object_name,
        X_DESCRIPTION                          =>p_rule_object_rec.description,
	X_USE_INSTANCE_FLAG                    =>p_rule_object_rec.use_instance_flag,
	X_INSTANCE_LABEL                       =>p_rule_object_rec.instance_label,
	X_PARENT_RULE_OBJECT_ID                =>p_rule_object_rec.parent_rule_object_id,
        X_ORG_ID                               =>p_rule_object_rec.org_id
    );
END;


/**
 * PROCEDURE create_rule_object
 *
 * DESCRIPTION
 *     Creates User customizable objects.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_rule_object_rec             User customizable object record.
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

PROCEDURE create_rule_object(
    p_init_msg_list          IN        VARCHAR2 := FND_API.G_FALSE,
    p_rule_object_rec        IN        RULE_OBJECTS_REC_TYPE,
    x_rule_object_id          OUT NOCOPY       NUMBER,
    x_return_status           OUT NOCOPY       VARCHAR2,
    x_msg_count               OUT NOCOPY       NUMBER,
    x_msg_data                OUT NOCOPY       VARCHAR2
) IS

    l_rule_object_rec       RULE_OBJECTS_REC_TYPE:= p_rule_object_rec;

BEGIN

    -- standard start of API savepoint
    SAVEPOINT create_rule_objects;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- call to business logic.
    do_create_rule_object(
                             l_rule_object_rec,
                             l_rule_object_rec.rule_object_id,
                             x_return_status);

    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_rule_objects;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
        x_msg_data := FND_MSG_PUB.Get_Detail;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_rule_objects;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
        x_msg_data := FND_MSG_PUB.Get_Detail;
    WHEN OTHERS THEN
        ROLLBACK TO create_rule_objects;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('FUN', 'FUN_RULE_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
        x_msg_data := FND_MSG_PUB.Get_Detail;
END create_rule_object;

/**
 * Use this routine to create a rule object instance to be used for rule partitioning.
 * With this API you can create a record in the FUN_RULE_OBJECTS_B ,
 * table provided the flag USE_INSTANCE_FLAG is set to 'Y'. This API will return
 * the rule_object_id of the newly created rule object instance record.
 *
 *  p_init_msg_list    Initialize message stack if it is set to FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *  p_application_id   Application identifier
 *  p_rule_object_name Name of Rule Object
 *  p_instance_label   Name of the Instance.
 *  p_rule_object_id   Internal identifier for the Rule Object
 *  x_return_status    Return status after the call.
 *  x_msg_count        Number of messages in message stack.
 *  x_msg_data         Message text if x_msg_count is 1.
 *
 *  27-Dec-2005    Amulya Mishra     Created
 */

PROCEDURE create_rule_object_instance(
    p_init_msg_list           		 IN      VARCHAR2 := FND_API.G_FALSE,
    p_application_id                     IN      NUMBER,
    p_rule_object_name     		 IN      VARCHAR2,
    p_instance_label                     IN      VARCHAR2,
    p_org_id                             IN      NUMBER,
    x_rule_object_id                     OUT NOCOPY    NUMBER,
    x_return_status           		 OUT NOCOPY     VARCHAR2,
    x_msg_count               		 OUT NOCOPY     NUMBER,
    x_msg_data                		 OUT NOCOPY     VARCHAR2
)
IS

BEGIN
    -- standard start of API savepoint
    SAVEPOINT create_rule_object_instance;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Dont create the Rule Object Intance, if it already exists. Simply return to
    --calling procedure.

    IF (rule_object_instance_exists(p_application_id , p_rule_object_name , p_instance_label , p_org_id)) THEN
     BEGIN
      --This should infact never raise exception if the code flow has reached here.

      SELECT RULE_OBJECT_ID INTO X_RULE_OBJECT_ID
      FROM FUN_RULE_OBJECTS_B
      WHERE RULE_OBJECT_NAME = p_rule_object_name
      AND   APPLICATION_ID   = p_application_id
      AND ( (INSTANCE_LABEL IS NULL  AND p_instance_label IS NULL) OR
	  (INSTANCE_LABEL IS NOT NULL AND p_instance_label IS NOT NULL AND INSTANCE_LABEL = p_instance_label))
      AND ( (ORG_ID IS NULL AND p_org_id IS NULL) OR
	  ( ORG_ID IS NOT NULL AND p_org_id IS NOT NULL AND ORG_ID = p_org_id))
      AND PARENT_RULE_OBJECT_ID IS NOT NULL;

      RETURN;

     EXCEPTION
      WHEN NO_DATA_FOUND THEN
        RETURN;

     END;
    -- call to business logic.
    ELSE
       do_create_rule_object_instance(
                    p_application_id,
                    p_rule_object_name,
                    p_instance_label,
                    p_org_id,
                    x_rule_object_id,
                    x_return_status);
    END IF;
    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_rule_object_instance;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
        x_msg_data := FND_MSG_PUB.Get_Detail;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_rule_object_instance;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
        x_msg_data := FND_MSG_PUB.Get_Detail;
    WHEN OTHERS THEN
        ROLLBACK TO create_rule_object_instance;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('FUN', 'FUN_RULE_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
        x_msg_data := FND_MSG_PUB.Get_Detail;

END create_rule_object_instance;

/**
 * PROCEDURE update_rule_object
 *
 * DESCRIPTION
 *     Updates User customizable objects
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_rules_object_rec             User Customizable Object record.
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

PROCEDURE update_rule_object (
    p_init_msg_list             IN     VARCHAR2 := FND_API.G_FALSE,
    p_rule_object_rec           IN     RULE_OBJECTS_REC_TYPE,
    p_object_version_number     IN OUT NOCOPY NUMBER,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2
) IS

    l_rule_object_rec                    RULE_OBJECTS_REC_TYPE := p_rule_object_rec;
    l_old_rule_object_rec                RULE_OBJECTS_REC_TYPE;
    l_rule_object_id                     number;

    CURSOR FUN_RULE_OBJECTS_CUR(p_rule_object_id NUMBER) IS
    SELECT
      B.RULE_OBJECT_ID,
      B.APPLICATION_ID,
      B.RULE_OBJECT_NAME,
      B.RESULT_TYPE,
      B.REQUIRED_FLAG,
      B.USE_DEFAULT_VALUE_FLAG,
      ATTR.DEFAULT_APPLICATION_ID,
      ATTR.DEFAULT_VALUE,
      B.FLEX_VALUE_SET_ID,
      B.FLEXFIELD_NAME,
      B.FLEXFIELD_APP_SHORT_NAME,
      B.MULTI_RULE_RESULT_FLAG,
      B.CREATED_BY_MODULE,
      B.OBJECT_VERSION_NUMBER,
      TL.USER_RULE_OBJECT_NAME,
      TL.DESCRIPTION,
      B.USE_INSTANCE_FLAG,
      B.INSTANCE_LABEL,
      B.PARENT_RULE_OBJECT_ID,
      B.ORG_ID
    FROM FUN_RULE_OBJECTS_B B, FUN_RULE_OBJECTS_TL TL, FUN_RULE_OBJ_ATTRIBUTES ATTR
    WHERE B.PARENT_RULE_OBJECT_ID = p_rule_object_id
    AND   B.RULE_OBJECT_ID = ATTR.RULE_OBJECT_ID
    AND   B.RULE_OBJECT_ID = TL.RULE_OBJECT_ID
    AND   TL.LANGUAGE = 'US';

BEGIN
    -- standard start of API savepoint
    SAVEPOINT update_rule_objects;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Get old records. Will be used by business event system.
    get_rule_object_rec (
        p_rule_object_id                    => l_rule_object_rec.rule_object_id,
        x_rule_object_rec                   => l_old_rule_object_rec,
        x_return_status                     => x_return_status,
        x_msg_count                         => x_msg_count,
        x_msg_data                          => x_msg_data );

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    --Make sure to make the fields related to Rule Object Instance as NULL.
    l_rule_object_rec.instance_label := null;
    l_rule_object_rec.parent_rule_object_id := null;
    l_rule_object_rec.org_id := null;


    -- call to business logic.
    do_update_rule_object(
                             'N',  --Update for Rule Object Instance Parameter
                             l_rule_object_rec,
                             p_object_version_number,
                             x_return_status);

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

       -- standard call to get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);
   END IF;


   --If USE_INSTANCE_FLAG is Y, then make the update in all instances.
   --Loop through the cursor and update the Rule Object tables for each instances.

   IF( UPPER(l_rule_object_rec.use_instance_flag) = 'Y') THEN
      FOR C_REC IN FUN_RULE_OBJECTS_CUR(l_rule_object_rec.rule_object_id) LOOP


	    -- Get old records. Will be used by business event system.

	    get_rule_object_rec (
		p_rule_object_id                    => C_REC.rule_object_id,
		x_rule_object_rec                   => l_old_rule_object_rec,
		x_return_status                     => x_return_status,
		x_msg_count                         => x_msg_count,
		x_msg_data                          => x_msg_data );

	    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	    END IF;

	    -- initialize API return status to success.
	    x_return_status := FND_API.G_RET_STS_SUCCESS;

           --Only propagate the changes of parent rule object record to the instance records.

	   l_rule_object_rec.rule_object_id	        := c_rec.rule_object_id;
           l_rule_object_rec.use_instance_flag	        := c_rec.use_instance_flag;
           l_rule_object_rec.instance_label	        := c_rec.instance_label;

           --parent_rule_object_id should not be NULL for a Rule Object Instance.
	   --This validation is done in do_update_rule_object().

           l_rule_object_rec.parent_rule_object_id	:= C_REC.parent_rule_object_id;
           l_rule_object_rec.org_id 	                := C_REC.org_id;


	    -- call to business logic.
	    do_update_rule_object(
                                    'Y',  --Update for Rule Object Instance Parameter
				     l_rule_object_rec,
				     C_REC.OBJECT_VERSION_NUMBER,
				     x_return_status);

	   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

	       -- standard call to get message count and if count is 1, get message info.
	       FND_MSG_PUB.Count_And_Get(
			p_encoded => FND_API.G_FALSE,
			p_count => x_msg_count,
			p_data  => x_msg_data);
	   END IF;

   END LOOP;
 END IF;


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_rule_objects;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_rule_objects;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO update_rule_objects;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('FUN', 'FUN_RULE_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
END update_rule_object;


/**
 * PROCEDURE get_rule_object_rec
 *
 * DESCRIPTION
 *     Gets user customizable objects record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     FUN_RULES_PKG.Select_Row
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_rule_objects                 User customizable objects name.
 *   IN/OUT:
 *   OUT:
 *     x_rule_object_rec              Returned class category record.
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

PROCEDURE get_rule_object_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_rule_object_name                      IN     VARCHAR2,
    p_application_id                        IN     NUMBER,
    p_instance_label                        IN     VARCHAR2,
    p_org_id                                IN     NUMBER,
    x_rule_object_rec                       OUT    NOCOPY RULE_OBJECTS_REC_TYPE,
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
    IF p_rule_object_name IS NULL OR
       p_rule_object_name = FND_API.G_MISS_CHAR THEN
        FND_MESSAGE.SET_NAME( 'FUN', 'FUN_RULE_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'rule_object_name' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    x_rule_object_rec.rule_object_name := p_rule_object_name;
    x_rule_object_rec.application_id := p_application_id;
    x_rule_object_rec.instance_label := p_instance_label;
    x_rule_object_rec.org_id := p_org_id;

    FUN_RULE_OBJECTS_PKG.Select_Row (
        X_RULE_OBJECT_NAME                     =>x_rule_object_rec.rule_object_name,
	X_RULE_OBJECT_ID                       =>x_rule_object_rec.rule_object_id,
	X_APPLICATION_ID                       =>x_rule_object_rec.application_id,
	X_USER_RULE_OBJECT_NAME                =>x_rule_object_rec.user_rule_object_name,
	X_DESCRIPTION                          =>x_rule_object_rec.description,
	X_RESULT_TYPE                          =>x_rule_object_rec.result_type,
	X_REQUIRED_FLAG                        =>x_rule_object_rec.required_flag,
	X_USE_DEFAULT_VALUE_FLAG               =>x_rule_object_rec.use_default_value_flag,
	X_DEFAULT_APPLICATION_ID               =>x_rule_object_rec.default_application_id,
	X_DEFAULT_VALUE                        =>x_rule_object_rec.default_value,
        X_FLEX_VALUE_SET_ID                    =>x_rule_object_rec.flex_value_set_id,
        X_FLEXFIELD_NAME                       =>x_rule_object_rec.flexfield_name,
        X_FLEXFIELD_APP_SHORT_NAME             =>x_rule_object_rec.flexfield_app_short_name,
	X_MULTI_RULE_RESULT_FLAG               =>x_rule_object_rec.multi_rule_result_flag,
	X_CREATED_BY_MODULE                    =>x_rule_object_rec.created_by_module,
	X_USE_INSTANCE_FLAG                    =>x_rule_object_rec.use_instance_flag,
	X_INSTANCE_LABEL                       =>x_rule_object_rec.instance_label,
	X_PARENT_RULE_OBJECT_ID                =>x_rule_object_rec.parent_rule_object_id,
        X_ORG_ID                               =>x_rule_object_rec.org_id
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

END get_rule_object_rec;

/**
 * PROCEDURE get_rule_object_rec
 *
 * DESCRIPTION
 *     Gets Rule objects record for a passed Rule_Object_id
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     FUN_RULES_PKG.Select_Row
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_rule_objects                 User customizable objects name.
 *   IN/OUT:
 *   OUT:
 *     x_rule_object_rec              Returned class category record.
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

PROCEDURE get_rule_object_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_rule_object_id                        IN     NUMBER,
    x_rule_object_rec                       OUT    NOCOPY RULE_OBJECTS_REC_TYPE,
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
    IF p_rule_object_id IS NULL OR
       p_rule_object_id = FND_API.G_MISS_NUM THEN
        FND_MESSAGE.SET_NAME( 'FUN', 'FUN_RULE_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'rule_object_id' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    x_rule_object_rec.rule_object_id := p_rule_object_id;

    FUN_RULE_OBJECTS_PKG.Select_Row_Rob_Id (
        X_RULE_OBJECT_NAME                     =>x_rule_object_rec.rule_object_name,
	X_RULE_OBJECT_ID                       =>x_rule_object_rec.rule_object_id,
	X_APPLICATION_ID                       =>x_rule_object_rec.application_id,
	X_USER_RULE_OBJECT_NAME                =>x_rule_object_rec.user_rule_object_name,
	X_DESCRIPTION                          =>x_rule_object_rec.description,
	X_RESULT_TYPE                          =>x_rule_object_rec.result_type,
	X_REQUIRED_FLAG                        =>x_rule_object_rec.required_flag,
	X_USE_DEFAULT_VALUE_FLAG               =>x_rule_object_rec.use_default_value_flag,
	X_DEFAULT_APPLICATION_ID               =>x_rule_object_rec.default_application_id,
	X_DEFAULT_VALUE                        =>x_rule_object_rec.default_value,
        X_FLEX_VALUE_SET_ID                    =>x_rule_object_rec.flex_value_set_id,
        X_FLEXFIELD_NAME                       =>x_rule_object_rec.flexfield_name,
        X_FLEXFIELD_APP_SHORT_NAME             =>x_rule_object_rec.flexfield_app_short_name,
	X_MULTI_RULE_RESULT_FLAG               =>x_rule_object_rec.multi_rule_result_flag,
	X_CREATED_BY_MODULE                    =>x_rule_object_rec.created_by_module,
	X_USE_INSTANCE_FLAG                    =>x_rule_object_rec.use_instance_flag,
	X_INSTANCE_LABEL                       =>x_rule_object_rec.instance_label,
	X_PARENT_RULE_OBJECT_ID                =>x_rule_object_rec.parent_rule_object_id,
        X_ORG_ID                               =>x_rule_object_rec.org_id
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

END get_rule_object_rec;

/**
 * PROCEDURE delete_rule_object
 *
 * DESCRIPTION
 *     Deletes User customizable objects.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_rule_object_name             User customizable object Name.
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

PROCEDURE delete_rule_object(
    p_init_msg_list           IN        VARCHAR2 := FND_API.G_FALSE,
    p_rule_object_name        IN        VARCHAR2,
    p_application_id	      IN        NUMBER,
    x_return_status           OUT NOCOPY       VARCHAR2,
    x_msg_count               OUT NOCOPY       NUMBER,
    x_msg_data                OUT NOCOPY       VARCHAR2
) IS

    l_rule_object_id                     number;

    CURSOR FUN_RULE_OBJECTS_CUR(p_rule_object_id NUMBER) IS
    SELECT
      B.APPLICATION_ID,
      B.RULE_OBJECT_NAME,
      B.INSTANCE_LABEL,
      B.ORG_ID
    FROM FUN_RULE_OBJECTS_B B, FUN_RULE_OBJECTS_TL TL, FUN_RULE_OBJ_ATTRIBUTES ATTR
    WHERE B.PARENT_RULE_OBJECT_ID = p_rule_object_id
    AND   B.RULE_OBJECT_ID = ATTR.RULE_OBJECT_ID
    AND   B.RULE_OBJECT_ID = TL.RULE_OBJECT_ID
    AND   TL.LANGUAGE = 'US';

BEGIN

    -- standard start of API savepoint
    SAVEPOINT delete_rule_object;

    --Store the rule_object_id first so that it will be used
    --to delete the instances later.

    BEGIN
     SELECT RULE_OBJECT_ID INTO l_rule_object_id FROM FUN_RULE_OBJECTS_B
     WHERE RULE_OBJECT_NAME = p_rule_object_name
     AND   APPLICATION_ID   = p_application_id
     AND   INSTANCE_LABEL IS NULL
     AND   ORG_ID  IS NULL
     AND   PARENT_RULE_OBJECT_ID IS NULL;

    EXCEPTION
     WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('FUN', 'FUN_RULE_INVALID_ROB');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;

    --Instead of calling the delete apis of the tables for each record, from performance point of view
    --its better to issue direct delete statement.

    DELETE FROM FUN_RULE_PARAM_VALUES FRPV
    WHERE RULE_DETAIL_ID IN (SELECT RULE_DETAIL_ID
                             FROM FUN_RULE_DETAILS FRD , FUN_RULE_OBJECTS_B FROB
                             WHERE FROB.RULE_OBJECT_ID = FRD.RULE_OBJECT_ID
                             AND FROB.RULE_OBJECT_NAME = P_RULE_OBJECT_NAME);


    DELETE FROM FUN_RULE_CRIT_PARAMS_TL FRCP
    WHERE CRITERIA_PARAM_ID IN (SELECT CRITERIA_PARAM_ID
                                FROM FUN_RULE_OBJECTS_B FROB, FUN_RULE_CRIT_PARAMS_B FRCPB
				WHERE FROB.RULE_OBJECT_ID = FRCPB.RULE_OBJECT_ID
  			        AND RULE_OBJECT_NAME = P_RULE_OBJECT_NAME);

    DELETE FROM FUN_RULE_CRIT_PARAMS_B FRCP
    WHERE RULE_OBJECT_ID IN (SELECT RULE_OBJECT_ID
                             FROM FUN_RULE_OBJECTS_B WHERE
			     RULE_OBJECT_NAME = P_RULE_OBJECT_NAME);

    DELETE FROM FUN_RULE_DETAILS FRD
    WHERE RULE_OBJECT_ID IN (SELECT RULE_OBJECT_ID
                             FROM FUN_RULE_OBJECTS_B WHERE
			     RULE_OBJECT_NAME = P_RULE_OBJECT_NAME);
    DELETE FROM FUN_RULE_CRITERIA FRC
    WHERE RULE_DETAIL_ID IN (SELECT RULE_DETAIL_ID
                             FROM FUN_RULE_DETAILS FRD , FUN_RULE_OBJECTS_B FROB
			     WHERE FROB.RULE_OBJECT_ID = FRD.RULE_OBJECT_ID
			     AND FROB.RULE_OBJECT_NAME = P_RULE_OBJECT_NAME);

    --TEST Related tables deletion starts from here

    DELETE FROM FUN_RULE_TEST_MULTIRULE FRTP
    WHERE TEST_ID IN (SELECT TEST_ID
		      FROM FUN_RULE_TESTS FRT , FUN_RULE_OBJECTS_B FROB
		      WHERE FROB.RULE_OBJECT_ID = FRT.RULE_OBJECT_ID
		      AND FROB.RULE_OBJECT_NAME = P_RULE_OBJECT_NAME);

    DELETE FROM FUN_RULE_TEST_RESULTS FRTR
    WHERE TEST_ID IN (SELECT TEST_ID
                      FROM FUN_RULE_TESTS FRT , FUN_RULE_OBJECTS_B FROB
		      WHERE FROB.RULE_OBJECT_ID = FRT.RULE_OBJECT_ID
		      AND FROB.RULE_OBJECT_NAME = P_RULE_OBJECT_NAME);

    DELETE FROM FUN_RULE_TEST_MVAL_RES FRTMR
    WHERE TEST_ID IN (SELECT TEST_ID
                      FROM FUN_RULE_TESTS FRT , FUN_RULE_OBJECTS_B FROB
		      WHERE FROB.RULE_OBJECT_ID = FRT.RULE_OBJECT_ID
		      AND FROB.RULE_OBJECT_NAME = P_RULE_OBJECT_NAME);

    DELETE FROM FUN_RULE_TEST_PARAMS FRTP
    WHERE TEST_ID IN (SELECT TEST_ID
                      FROM FUN_RULE_TESTS FRT , FUN_RULE_OBJECTS_B FROB
		      WHERE FROB.RULE_OBJECT_ID = FRT.RULE_OBJECT_ID
		      AND FROB.RULE_OBJECT_NAME = P_RULE_OBJECT_NAME);

    DELETE FROM FUN_RULE_TESTS FRT
    WHERE RULE_OBJECT_ID IN (SELECT RULE_OBJECT_ID
                             FROM FUN_RULE_OBJECTS_B WHERE
			     RULE_OBJECT_NAME = P_RULE_OBJECT_NAME);

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- call to table-handler.
    FUN_RULE_OBJECTS_PKG.Delete_Row (
        X_RULE_OBJECT_NAME                     =>p_rule_object_name,
        X_APPLICATION_ID                       =>p_application_id
    );


   --If USE_INSTANCE_FLAG is Y, then DELETE all instances.
   --Loop through the cursor and update the Rule Object tables for each instances.


   FOR C_REC  IN FUN_RULE_OBJECTS_CUR(l_rule_object_id) LOOP

	    -- initialize API return status to success.
	    x_return_status := FND_API.G_RET_STS_SUCCESS;

            delete_rule_object_instance(
               p_application_id          => C_REC.application_id,
               p_rule_object_name        => C_REC.rule_object_name,
               p_instance_label          => C_REC.instance_label,
               p_org_id                  => C_REC.org_id,
               x_return_status           => x_return_status,
               x_msg_count               => x_msg_count,
               x_msg_data                => x_msg_data);


	   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

	       -- standard call to get message count and if count is 1, get message info.
	       FND_MSG_PUB.Count_And_Get(
			p_encoded => FND_API.G_FALSE,
			p_count => x_msg_count,
			p_data  => x_msg_data);
	   END IF;

   END LOOP;

    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO delete_rule_object;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO delete_rule_object;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO delete_rule_object;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('FUN', 'FUN_RULE_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
END delete_rule_object;



/**
 * Use this routine to delete a rule object instance. The API deletes a record in the
 * FUN_RULE_OBJECTS_B table after checking if the USE_INSTANCE_FLAG is Y or not.
 *
 *
 * p_init_msg_list    Initialize message stack if it is set to FND_API.G_TRUE. Default is FND_API.G_FALSE.
 * p_application_id   Application identifier
 * p_rule_object_name Name of Rule Object
 * p_instance_label   Name of the Instance.
 * x_return_status    Return status after the call.
 * x_msg_count        Number of messages in message stack.
 * x_msg_data         Message text if x_msg_count is 1.
 *
 * 27-Dec-2005    Amulya Mishra     Created
 */

PROCEDURE delete_rule_object_instance(
    p_init_msg_list           IN      VARCHAR2 := FND_API.G_FALSE,
    p_application_id          IN      NUMBER,
    p_rule_object_name        IN      VARCHAR2,
    p_instance_label          IN      VARCHAR2,
    p_org_id                  IN      NUMBER,
    x_return_status           OUT NOCOPY       VARCHAR2,
    x_msg_count               OUT NOCOPY       NUMBER,
    x_msg_data                OUT NOCOPY       VARCHAR2
) IS

l_rule_object_id              NUMBER;

BEGIN

    -- standard start of API savepoint
    SAVEPOINT delete_rule_object_instance;

    --Get the RULE_OBJECT_ID from FUN_RULE_OBJECTS_B for the Rule Instance.
    --Use the RULE_OBJECT_ID to delete the records.

    BEGIN
      SELECT RULE_OBJECT_ID INTO l_rule_object_id FROM FUN_RULE_OBJECTS_B
      WHERE RULE_OBJECT_NAME = p_rule_object_name
      AND   APPLICATION_ID   = p_application_id
      AND ( (INSTANCE_LABEL IS NULL  AND p_instance_label IS NULL) OR
	  (INSTANCE_LABEL IS NOT NULL AND p_instance_label IS NOT NULL AND INSTANCE_LABEL = p_instance_label))
      AND ( (ORG_ID IS NULL AND p_org_id IS NULL) OR
	  ( ORG_ID IS NOT NULL AND p_org_id IS NOT NULL AND ORG_ID = p_org_id))
      AND PARENT_RULE_OBJECT_ID IS NOT NULL;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('FUN', 'FUN_RULE_NO_INSTANCE');
        FND_MESSAGE.SET_TOKEN('INSTANCE_LABEL' ,p_instance_label);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;

    --Instead of calling the delete apis of the tables for each record, from performance point of view
    --its better to issue direct delete statement.

    DELETE FROM FUN_RULE_PARAM_VALUES FRPV
    WHERE RULE_DETAIL_ID IN (SELECT RULE_DETAIL_ID
                             FROM FUN_RULE_DETAILS FRD , FUN_RULE_OBJECTS_B FROB
                             WHERE FROB.RULE_OBJECT_ID = FRD.RULE_OBJECT_ID
                             AND FROB.RULE_OBJECT_NAME = P_RULE_OBJECT_NAME
			     AND FROB.APPLICATION_ID = P_APPLICATION_ID
			    AND ( (INSTANCE_LABEL IS NULL AND p_instance_label IS NULL) OR
				  (INSTANCE_LABEL IS NOT NULL AND p_instance_label IS NOT NULL AND INSTANCE_LABEL = p_instance_label))
			    AND ( (ORG_ID IS NULL AND p_org_id IS NULL) OR
				  ( ORG_ID IS NOT NULL AND p_org_id IS NOT NULL AND ORG_ID = p_org_id))
			    AND PARENT_RULE_OBJECT_ID IS NOT NULL);


    DELETE FROM FUN_RULE_CRIT_PARAMS_TL FRCP
    WHERE CRITERIA_PARAM_ID IN (SELECT CRITERIA_PARAM_ID
                                FROM FUN_RULE_OBJECTS_B FROB, FUN_RULE_CRIT_PARAMS_B FRCPB
				WHERE FROB.RULE_OBJECT_ID = FRCPB.RULE_OBJECT_ID
  			        AND RULE_OBJECT_NAME = P_RULE_OBJECT_NAME
				AND FROB.APPLICATION_ID = P_APPLICATION_ID
			    AND ( (INSTANCE_LABEL IS NULL AND p_instance_label IS NULL) OR
				  (INSTANCE_LABEL IS NOT NULL AND p_instance_label IS NOT NULL AND INSTANCE_LABEL = p_instance_label))
			    AND ( (ORG_ID IS NULL AND p_org_id IS NULL) OR
				  ( ORG_ID IS NOT NULL AND p_org_id IS NOT NULL AND ORG_ID = p_org_id))
			    AND PARENT_RULE_OBJECT_ID IS NOT NULL);



    DELETE FROM FUN_RULE_CRIT_PARAMS_B FRCP
    WHERE RULE_OBJECT_ID IN (SELECT RULE_OBJECT_ID
                             FROM FUN_RULE_OBJECTS_B WHERE
			     RULE_OBJECT_NAME = P_RULE_OBJECT_NAME
				AND APPLICATION_ID = P_APPLICATION_ID
			    AND ( (INSTANCE_LABEL IS NULL AND p_instance_label IS NULL) OR
				  (INSTANCE_LABEL IS NOT NULL AND p_instance_label IS NOT NULL AND INSTANCE_LABEL = p_instance_label))
			    AND ( (ORG_ID IS NULL AND p_org_id IS NULL) OR
				  ( ORG_ID IS NOT NULL AND p_org_id IS NOT NULL AND ORG_ID = p_org_id))
			    AND PARENT_RULE_OBJECT_ID IS NOT NULL);

    DELETE FROM FUN_RULE_DETAILS FRD
    WHERE RULE_OBJECT_ID IN (SELECT RULE_OBJECT_ID
                             FROM FUN_RULE_OBJECTS_B WHERE
			     RULE_OBJECT_NAME = P_RULE_OBJECT_NAME
			     AND APPLICATION_ID = P_APPLICATION_ID
			    AND ( (INSTANCE_LABEL IS NULL AND p_instance_label IS NULL) OR
				  (INSTANCE_LABEL IS NOT NULL AND p_instance_label IS NOT NULL AND INSTANCE_LABEL = p_instance_label))
			    AND ( (ORG_ID IS NULL AND p_org_id IS NULL) OR
				  ( ORG_ID IS NOT NULL AND p_org_id IS NOT NULL AND ORG_ID = p_org_id))
			    AND PARENT_RULE_OBJECT_ID IS NOT NULL);

    DELETE FROM FUN_RULE_CRITERIA FRC
    WHERE RULE_DETAIL_ID IN (SELECT RULE_DETAIL_ID
                             FROM FUN_RULE_DETAILS FRD , FUN_RULE_OBJECTS_B FROB
			     WHERE FROB.RULE_OBJECT_ID = FRD.RULE_OBJECT_ID
			     AND RULE_OBJECT_NAME = P_RULE_OBJECT_NAME
			     AND FROB.APPLICATION_ID = P_APPLICATION_ID
			    AND ( (INSTANCE_LABEL IS NULL AND p_instance_label IS NULL) OR
				  (INSTANCE_LABEL IS NOT NULL AND p_instance_label IS NOT NULL AND INSTANCE_LABEL = p_instance_label))
			    AND ( (ORG_ID IS NULL AND p_org_id IS NULL) OR
				  ( ORG_ID IS NOT NULL AND p_org_id IS NOT NULL AND ORG_ID = p_org_id))
			    AND PARENT_RULE_OBJECT_ID IS NOT NULL);


    --TEST Related tables deletion starts from here

    DELETE FROM FUN_RULE_TEST_MULTIRULE FRTP
    WHERE TEST_ID IN (SELECT TEST_ID
		      FROM FUN_RULE_TESTS FRT , FUN_RULE_OBJECTS_B FROB
		      WHERE FROB.RULE_OBJECT_ID = FRT.RULE_OBJECT_ID
		      AND RULE_OBJECT_NAME = P_RULE_OBJECT_NAME
 		      AND FROB.APPLICATION_ID = P_APPLICATION_ID
			    AND ( (INSTANCE_LABEL IS NULL AND p_instance_label IS NULL) OR
				  (INSTANCE_LABEL IS NOT NULL AND p_instance_label IS NOT NULL AND INSTANCE_LABEL = p_instance_label))
			    AND ( (ORG_ID IS NULL AND p_org_id IS NULL) OR
				  ( ORG_ID IS NOT NULL AND p_org_id IS NOT NULL AND ORG_ID = p_org_id))
			    AND PARENT_RULE_OBJECT_ID IS NOT NULL);


    DELETE FROM FUN_RULE_TEST_RESULTS FRTR
    WHERE TEST_ID IN (SELECT TEST_ID
                      FROM FUN_RULE_TESTS FRT , FUN_RULE_OBJECTS_B FROB
		      WHERE FROB.RULE_OBJECT_ID = FRT.RULE_OBJECT_ID
		      AND RULE_OBJECT_NAME = P_RULE_OBJECT_NAME
 		      AND FROB.APPLICATION_ID = P_APPLICATION_ID
			    AND ( (INSTANCE_LABEL IS NULL AND p_instance_label IS NULL) OR
				  (INSTANCE_LABEL IS NOT NULL AND p_instance_label IS NOT NULL AND INSTANCE_LABEL = p_instance_label))
			    AND ( (ORG_ID IS NULL AND p_org_id IS NULL) OR
				  ( ORG_ID IS NOT NULL AND p_org_id IS NOT NULL AND ORG_ID = p_org_id))
			    AND PARENT_RULE_OBJECT_ID IS NOT NULL);


    DELETE FROM FUN_RULE_TEST_MVAL_RES FRTMR
    WHERE TEST_ID IN (SELECT TEST_ID
                      FROM FUN_RULE_TESTS FRT , FUN_RULE_OBJECTS_B FROB
		      WHERE FROB.RULE_OBJECT_ID = FRT.RULE_OBJECT_ID
		      AND RULE_OBJECT_NAME = P_RULE_OBJECT_NAME
		      AND FROB.APPLICATION_ID = P_APPLICATION_ID
			    AND ( (INSTANCE_LABEL IS NULL AND p_instance_label IS NULL) OR
				  (INSTANCE_LABEL IS NOT NULL AND p_instance_label IS NOT NULL AND INSTANCE_LABEL = p_instance_label))
			    AND ( (ORG_ID IS NULL AND p_org_id IS NULL) OR
				  ( ORG_ID IS NOT NULL AND p_org_id IS NOT NULL AND ORG_ID = p_org_id))
			    AND PARENT_RULE_OBJECT_ID IS NOT NULL);


    DELETE FROM FUN_RULE_TEST_PARAMS FRTP
    WHERE TEST_ID IN (SELECT TEST_ID
                      FROM FUN_RULE_TESTS FRT , FUN_RULE_OBJECTS_B FROB
		      WHERE FROB.RULE_OBJECT_ID = FRT.RULE_OBJECT_ID
			     AND RULE_OBJECT_NAME = P_RULE_OBJECT_NAME
			     AND FROB.APPLICATION_ID = P_APPLICATION_ID
			    AND ( (INSTANCE_LABEL IS NULL AND p_instance_label IS NULL) OR
				  (INSTANCE_LABEL IS NOT NULL AND p_instance_label IS NOT NULL AND INSTANCE_LABEL = p_instance_label))
			    AND ( (ORG_ID IS NULL AND p_org_id IS NULL) OR
				  ( ORG_ID IS NOT NULL AND p_org_id IS NOT NULL AND ORG_ID = p_org_id))
			    AND PARENT_RULE_OBJECT_ID IS NOT NULL);


    DELETE FROM FUN_RULE_TESTS FRT
    WHERE RULE_OBJECT_ID IN (SELECT RULE_OBJECT_ID
                             FROM FUN_RULE_OBJECTS_B WHERE
			     RULE_OBJECT_NAME = P_RULE_OBJECT_NAME
			     AND APPLICATION_ID = P_APPLICATION_ID
			    AND ( (INSTANCE_LABEL IS NULL AND p_instance_label IS NULL) OR
				  (INSTANCE_LABEL IS NOT NULL AND p_instance_label IS NOT NULL AND INSTANCE_LABEL = p_instance_label))
			    AND ( (ORG_ID IS NULL AND p_org_id IS NULL) OR
				  ( ORG_ID IS NOT NULL AND p_org_id IS NOT NULL AND ORG_ID = p_org_id))
			    AND PARENT_RULE_OBJECT_ID IS NOT NULL);


    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- call to table-handler.
    FUN_RULE_OBJECTS_PKG.Delete_Row (
        X_RULE_OBJECT_ID                     =>l_rule_object_id
    );

    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO delete_rule_object_instance;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO delete_rule_object_instance;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO delete_rule_object_instance;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('FUN', 'FUN_RULE_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
END delete_rule_object_instance;


FUNCTION RULE_OBJECT_USES_PARAMETER(p_rule_object_name IN VARCHAR2,
                                    p_parameter_name IN VARCHAR2)
RETURN BOOLEAN
IS
    l_dummy     VARCHAR2(1);
BEGIN

    SELECT 'Y' INTO l_dummy
    FROM FUN_RULE_CRIT_PARAMS_B FRCP, FUN_RULE_OBJECTS_B FROB
    WHERE FROB.RULE_OBJECT_ID = FRCP.RULE_OBJECT_ID
    AND FROB.RULE_OBJECT_NAME = p_rule_object_name
    AND FRCP.PARAM_NAME = p_parameter_name;

   return TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
      return FALSE;
  WHEN OTHERS THEN
      return FALSE;
END;

/**
 * PROCEDURE rule_object_instance_exists
 *
 * DESCRIPTION
 *     Returns Boolean value based on a Rule Object Instance exists in the
 *     FUN_RULE_OBJECTS_B table or not.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 *
 * ARGUMENTS
 *   IN:
 *     p_application_id               Application Id
 *     p_rule_object_name             Rule object Name.
 *     p_instance_label               Rule Object Instance Label name
 *   IN/OUT:
 *   OUT:
 *     True , if the rule object instance exists in the table, else returns False.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   27-Dec-2005    Amulya Mishra       Created.
 *
 */

FUNCTION rule_object_instance_exists(
    p_application_id          IN      NUMBER,
    p_rule_object_name        IN      VARCHAR2,
    p_instance_label          IN      VARCHAR2,
    p_org_id                  IN      NUMBER
) RETURN BOOLEAN
IS

       l_param_value               VARCHAR2(1);


BEGIN
    if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start FUN_RULE_PUB.rule_object_instance_exists', FALSE);
    end if;

    /*
       Bug 7040957 - re_written the routine to avoid high parsing as dynamic code is not required under
       current case.
    */


      SELECT 'Y' INTO l_param_value
      FROM FUN_RULE_OBJECTS_B
      WHERE RULE_OBJECT_NAME = p_rule_object_name
      AND   APPLICATION_ID   = p_application_id
      AND ( (INSTANCE_LABEL IS NULL  AND p_instance_label IS NULL) OR
	  (INSTANCE_LABEL IS NOT NULL AND p_instance_label IS NOT NULL AND INSTANCE_LABEL = p_instance_label))
      AND ( (ORG_ID IS NULL AND p_org_id IS NULL) OR
	  ( ORG_ID IS NOT NULL AND p_org_id IS NOT NULL AND ORG_ID = p_org_id))
      AND PARENT_RULE_OBJECT_ID IS NOT NULL;

      if (l_param_value = 'Y') then
	   return TRUE;
       else
	   return FALSE;
       end if;

   EXCEPTION

    WHEN TOO_MANY_ROWS THEN
       IF (FND_LOG.LEVEL_EXCEPTION  >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION , 'FUN_RULE_PUB.rule_object_instance_exists:->TO_MANY_ROWS', FALSE);
       END IF;
       return TRUE;

     WHEN NO_DATA_FOUND THEN
       IF (FND_LOG.LEVEL_EXCEPTION  >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION , 'FUN_RULE_PUB.rule_object_instance_exists:->NO_DATA_FOUND', FALSE);
       END IF;
       return FALSE;

     WHEN OTHERS THEN

       IF (FND_LOG.LEVEL_EXCEPTION  >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION , 'FUN_RULE_PUB.rule_object_instance_exists:->'||SQLERRM, FALSE);
       END IF;
       RAISE;
END rule_object_instance_exists;

/**
 * FUNCTION rule_object_instance_exists
 *
 * DESCRIPTION
 *     Returns ('Y'/'N') value based on a Rule Object Instance exists in the
 *     FUN_RULE_OBJECTS_B table or not.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 *
 * ARGUMENTS
 *   IN:
 *     p_application_id               Application Id
 *     p_rule_object_name             Rule object Name.
 *     p_instance_label               Rule Object Instance Label name
 *     p_org_id			      Operating Unit
 *   IN/OUT:
 *   OUT:
 *     'Y' , if the rule object instance exists in the table, else returns 'N'.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   18-JUL-2006    A.Hari Krishna       Created.
 *
 */
FUNCTION rule_object_instance_exists_vc(
    p_application_id          IN      NUMBER,
    p_rule_object_name        IN      VARCHAR2,
    p_instance_label          IN      VARCHAR2,
    p_org_id                  IN      NUMBER

) RETURN VARCHAR2

IS

	return_value               VARCHAR2(1);

BEGIN

       if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
             fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'Start of FUN_RULE_PUB.rule_object_instance_exists', FALSE);
       end if;

       if(rule_object_instance_exists(p_application_id,p_rule_object_name,p_instance_label,p_org_id) = TRUE) then
            return_value:='Y';
       else
            return_value:='N';
       end if;

       if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
             fnd_log.message(FND_LOG.LEVEL_STATEMENT, 'End of FUN_RULE_PUB.rule_object_instance_exists', FALSE);
       end if;

       return return_value;

END rule_object_instance_exists_vc;

/**
 * PROCEDURE convert_use_instance
 *
 * DESCRIPTION
 *     convert the Rule Object to make it enabling Instance
 *     and vice versa.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_rule_object_id               Internal identifier for the Rule Object
 *     p_instance_flag                Use Instance Flag value for the Rule Object
 *     p_instance_label               Instance Label to be associated with the Rule Object Instances.
 *     p_org_id                       Internal identifier for the organization id to be
 *                                    associated with the Rule Object Instances
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
 *   14-Feb-2006    Amulya Mishra       Created.
 *
 */

/*Algorithm for converting the Rule Object Into Instance Anabled and vice-versa.

 If the RULE_OBJECT_ID is for an object instance, error out.
 Compare the USE_INSTANCE_FLAG on the rule object with P_INSTANCE_FLAG.
   If they are the same, do nothing and exit out.
 If P_INSTANCE_FLAG = 'Y' then
    Set USE_INSTANCE_FLAG to 'Y' for the rule object.
    IF P_INSTANCE_LABEL and/or P_ORG_ID is not null THEN
        Create a new instance.
        Move all of the original rules and test cases to this new instance.
     Else
        Delete all of the original rules and test cases.
    End if
 Else if P_INSTANCE_FLAG = 'N' then
    Set USE_INSTANCE_FLAG to 'N' for the rule object
    Delete all object instances
 Else
     Invalid P_INSTANCE_FLAG -- error
 End if

 */


PROCEDURE convert_use_instance(
    p_init_msg_list           		 IN      VARCHAR2 := FND_API.G_FALSE,
    p_rule_object_id                     IN      NUMBER,
    p_use_instance_flag                  IN      VARCHAR2,
    p_instance_label                     IN      VARCHAR2 DEFAULT NULL,
    P_ORG_ID                             IN      NUMBER DEFAULT NULL,
    x_return_status           		 OUT NOCOPY     VARCHAR2,
    x_msg_count               		 OUT NOCOPY     NUMBER,
    x_msg_data                		 OUT NOCOPY     VARCHAR2
)
IS
    CURSOR C_RULE_OBJECT_INSTANCES(p_rule_object_id NUMBER) IS
    SELECT APPLICATION_ID,RULE_OBJECT_NAME,
           RULE_OBJECT_ID, INSTANCE_LABEL, ORG_ID
    FROM FUN_RULE_OBJECTS_B
    WHERE PARENT_RULE_OBJECT_ID = p_rule_object_id;

    x_rule_object_id		FUN_RULE_OBJECTS_B.RULE_OBJECT_ID%TYPE;
    l_application_id		FUN_RULE_OBJECTS_B.APPLICATION_ID%TYPE;
    l_rule_object_name		FUN_RULE_OBJECTS_B.RULE_OBJECT_NAME%TYPE;
    l_parent_rule_object_id	FUN_RULE_OBJECTS_B.PARENT_RULE_OBJECT_ID%TYPE;
    l_use_instance_flag         FUN_RULE_OBJECTS_B.USE_INSTANCE_FLAG%TYPE;

BEGIN
    -- standard start of API savepoint
    SAVEPOINT convert_use_instance;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /*The Rule Object Id passed is for an Instance which cannt be processed.
     *Only parent Rule Objects should be processed through this method
     */

    IF (FUN_RULE_UTILITY_PKG.IS_USE_INSTANCE(p_rule_object_id)) THEN
      fnd_message.set_name('FUN', 'FUN_RULE_NO_CONV_ROB_INST');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    /*Compare the USE_INSTANCE_FLAG from Database for the Rule Object Id and compare
     *with the passed value i.e p_use_instance_flag. If same, then simply exit.
     */
    --Since we have come here, that means the Rule Object Id record exists in the database.
    --So No need to handling exception.

    BEGIN
       SELECT USE_INSTANCE_FLAG , APPLICATION_ID, RULE_OBJECT_NAME
       INTO l_use_instance_flag, l_application_id, l_rule_object_name
       FROM FUN_RULE_OBJECTS_B
       WHERE RULE_OBJECT_ID = p_rule_object_id;
    END;

    IF (NVL(l_use_instance_flag,'N') = NVL(p_use_instance_flag,'N')) THEN
      RETURN;
    END IF;


    IF (UPPER(p_use_instance_flag) = 'Y') THEN

       --Set USE_INSTANCE_FLAG to 'Y' for the rule object.
     BEGIN
       UPDATE FUN_RULE_OBJECTS_B
       SET USE_INSTANCE_FLAG ='Y'
       WHERE RULE_OBJECT_ID = p_rule_object_id;
     END;

       if ( p_instance_label IS NOT NULL OR
             p_org_id  IS NOT NULL) then

	   --Create a new instance.

	   create_rule_object_instance(
                 p_application_id    => l_application_id,
                 p_rule_object_name  => l_rule_object_name,
                 p_instance_label    => p_instance_label,
                 p_org_id            => p_org_id,
                 x_rule_object_id    => x_rule_object_id,
                 x_return_status     => x_return_status,
                 x_msg_count         => x_msg_count ,
                 x_msg_data          => x_msg_data
           );

          -- Move all of the original rules and test cases to this new instance.
          BEGIN
           UPDATE FUN_RULE_DETAILS
	   SET RULE_OBJECT_ID = x_rule_object_id
	   WHERE RULE_OBJECT_ID = p_rule_object_id;
          END;

	  BEGIN
	   UPDATE FUN_RULE_TESTS
	   SET RULE_OBJECT_ID = x_rule_object_id
	   WHERE RULE_OBJECT_ID = p_rule_object_id;
          END;
       else
           --Delete all of the original rules and test cases.

           delete_rule_object(
               p_rule_object_name  => l_rule_object_name,
               p_application_id	   => l_application_id,
               x_return_status     => x_return_status,
               x_msg_count         => x_msg_count ,
               x_msg_data          => x_msg_data
           );

       end if;

    ELSIF (UPPER(p_use_instance_flag) = 'N') THEN

      --Select the parent rule object id for this instance.
      BEGIN
        SELECT PARENT_RULE_OBJECT_ID
        INTO l_parent_rule_object_id
        FROM FUN_RULE_OBJECTS_B
        WHERE RULE_OBJECT_ID = p_rule_object_id;
      END;

      --Set USE_INSTANCE_FLAG to 'N' for the rule object
      BEGIN
       UPDATE FUN_RULE_OBJECTS_B
       SET USE_INSTANCE_FLAG ='N',
           INSTANCE_LABEL    = null,
	   ORG_ID            = null,
	   PARENT_RULE_OBJECT_ID = null
       WHERE RULE_OBJECT_ID = p_rule_object_id;
      END;

     --Delete all object instances

     FOR c_rec IN C_RULE_OBJECT_INSTANCES(p_rule_object_id)
     LOOP
        delete_rule_object_instance(
                p_application_id          => c_rec.application_id,
                p_rule_object_name        => c_rec.rule_object_name,
                p_instance_label          => c_rec.instance_label,
                p_org_id                  => c_rec.org_id,
                x_return_status           => x_return_status,
                x_msg_count               => x_msg_count,
                x_msg_data                => x_msg_data
         );
     END LOOP;

    ELSE
      --Invalid P_USE_INSTANCE_FLAG

      fnd_message.set_name('FUN', 'FUN_RULE_INVALID_INST_FLAG');
      fnd_msg_pub.add;
      x_return_status := fnd_api.g_ret_sts_error;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO convert_use_instance;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
        x_msg_data := FND_MSG_PUB.Get_Detail;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO convert_use_instance;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
        x_msg_data := FND_MSG_PUB.Get_Detail;
    WHEN OTHERS THEN
        ROLLBACK TO convert_use_instance;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('FUN', 'FUN_RULE_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
        x_msg_data := FND_MSG_PUB.Get_Detail;
END convert_use_instance;

END FUN_RULE_OBJECTS_PUB;

/
