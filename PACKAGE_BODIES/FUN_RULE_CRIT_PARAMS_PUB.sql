--------------------------------------------------------
--  DDL for Package Body FUN_RULE_CRIT_PARAMS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_RULE_CRIT_PARAMS_PUB" AS
/*$Header: FUNXTMRULRCPPUB.pls 120.1 2006/01/10 12:17:36 ammishra noship $ */


------------------------------------
-- declaration of private procedures
------------------------------------


PROCEDURE do_create_rule_crit_param(
    p_rule_crit_param_rec         IN OUT    NOCOPY RULE_CRIT_PARAMS_REC_TYPE,
    x_criteria_param_id           OUT NOCOPY    NUMBER,
    x_return_status               IN OUT NOCOPY    VARCHAR2
);

PROCEDURE do_create_dup_rule_crit_param(
    p_from_rule_object_id                IN             NUMBER,
    p_to_rule_object_id                  IN             NUMBER,
    x_return_status               IN OUT NOCOPY    VARCHAR2
);

PROCEDURE do_update_rule_crit_param(
    p_rule_crit_param_rec         IN OUT   NOCOPY RULE_CRIT_PARAMS_REC_TYPE,
    p_object_version_number IN OUT NOCOPY   NUMBER,
    x_return_status         IN OUT NOCOPY   VARCHAR2
);


--------------------------------------
-- private procedures and functions
--------------------------------------

/*===========================================================================+
 | PROCEDURE
 |              do_create_rule_crit_param
 |
 | DESCRIPTION
 |              Creates rules criteria Parameter
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |                    p_rule_crit_param_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |          10-Sep-2004    Amulya Mishra         Created.
 +===========================================================================*/

PROCEDURE do_create_rule_crit_param(
    p_rule_crit_param_rec        IN OUT    NOCOPY RULE_CRIT_PARAMS_REC_TYPE,
    x_criteria_param_id           OUT NOCOPY    NUMBER,
    x_return_status               IN OUT NOCOPY    VARCHAR2
) IS

    l_rowid                      rowid;
BEGIN

    -- call for validations.
    FUN_RULE_VALIDATE_PKG.validate_rule_criteria_params(
      'C',
      p_rule_crit_param_rec,
      l_rowid,
      x_return_status
    );


    IF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    END IF;


    FUN_RULE_CRIT_PARAMS_PKG.Insert_Row (
        X_ROWID                                 =>l_rowid,
        X_CRITERIA_PARAM_ID                     =>p_rule_crit_param_rec.criteria_param_id,
        X_RULE_OBJECT_ID                        =>p_rule_crit_param_rec.rule_object_id,
        X_PARAM_NAME                     	=>p_rule_crit_param_rec.param_name,
        X_DATA_TYPE                             =>p_rule_crit_param_rec.data_type,
        X_FLEX_VALUE_SET_ID                     =>p_rule_crit_param_rec.flex_value_set_id,
        X_CREATED_BY_MODULE                     =>p_rule_crit_param_rec.created_by_module,
        X_USER_PARAM_NAME              	    	=>p_rule_crit_param_rec.user_param_name,
        X_DESCRIPTION                           =>p_rule_crit_param_rec.description,
        X_TIP_TEXT                              =>p_rule_crit_param_rec.tiptext
    );
    x_criteria_param_id := p_rule_crit_param_rec.criteria_param_id;

END;

/*===========================================================================+
 | PROCEDURE
 |              do_create_dup_rule_crit_param
 |
 | DESCRIPTION
 |              Duplicates rules criteria Parameter from one Rule Object to Another.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |                    p_rule_crit_param_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |          10-Sep-2004    Amulya Mishra         Created.
 +===========================================================================*/

PROCEDURE do_create_dup_rule_crit_param(
    p_from_rule_object_id                IN             NUMBER,
    p_to_rule_object_id                  IN             NUMBER,
    x_return_status              IN OUT NOCOPY    VARCHAR2
) IS

  l_rowid                      rowid;

  CURSOR RULE_CRIT_PARAMS_VL_CUR
  IS
  SELECT
    B.criteria_param_id,
    B.rule_object_id,
    B.param_name,
    TL.user_param_name,
    TL.description,
    tip_text,
    B.data_type,
    B.flex_value_set_id,
    B.created_by_module
  FROM FUN_RULE_CRIT_PARAMS_B B, FUN_RULE_CRIT_PARAMS_TL TL
  WHERE B.RULE_OBJECT_ID = p_from_rule_object_id
  AND   B.CRITERIA_PARAM_ID = TL.CRITERIA_PARAM_ID
  AND   TL.LANGUAGE='US';

  l_rule_crit_param_rec       RULE_CRIT_PARAMS_REC_TYPE;
  x_criteria_param_id         NUMBER;
  x_msg_count                 NUMBER;
  x_msg_data                  VARCHAR2(2000);
  l_count                     NUMBER := 0;
  l_rule_object_id            NUMBER;

BEGIN

      -- Validate if p_to_rule_object_id exists or not

      BEGIN
	    SELECT RULE_OBJECT_ID INTO l_rule_object_id
	    FROM FUN_RULE_OBJECTS_B WHERE RULE_OBJECT_ID = p_to_rule_object_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
	  fnd_message.set_name('FUN', 'FUN_RULE_INVALID_ROB');
	  fnd_msg_pub.add;
	  x_return_status := fnd_api.g_ret_sts_error;
      END;

  FOR C_REC IN RULE_CRIT_PARAMS_VL_CUR LOOP
     l_count := l_count + 1;
     l_rule_crit_param_rec.criteria_param_id	:= 	null;
     l_rule_crit_param_rec.rule_object_id	:= 	p_to_rule_object_id;
     l_rule_crit_param_rec.param_name	        := 	c_rec.param_name;
     l_rule_crit_param_rec.user_param_name	:= 	c_rec.user_param_name;
     l_rule_crit_param_rec.description	        := 	c_rec.description;
     l_rule_crit_param_rec.tiptext	        := 	c_rec.tip_text;
     l_rule_crit_param_rec.data_type	        := 	c_rec.data_type;
     l_rule_crit_param_rec.flex_value_set_id 	:= 	c_rec.flex_value_set_id;
     l_rule_crit_param_rec.created_by_module	:= 	c_rec.created_by_module;



     create_rule_crit_param(
	    p_init_msg_list           => FND_API.G_TRUE,
	    p_rule_crit_param_rec     => l_rule_crit_param_rec,
	    x_criteria_param_id       => x_criteria_param_id,
	    x_return_status           => x_return_status,
	    x_msg_count               => x_msg_count,
	    x_msg_data                => x_msg_data);



     IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
     ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;


     IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

       -- standard call to get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);
     END IF;

  END LOOP;

 IF l_count = 0 THEN
   RAISE  NO_DATA_FOUND;
 END IF;

 EXCEPTION
    WHEN NO_DATA_FOUND THEN

        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('FUN', 'FUN_RULE_INVALID_ROB');
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
        RAISE FND_API.G_EXC_ERROR;

END;

/*===========================================================================+
 | PROCEDURE
 |              do_update_rule_crit_param
 |
 | DESCRIPTION
 |              Updates rules criteria Parameter
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |                    p_rule_crit_param_rec
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

PROCEDURE do_update_rule_crit_param(
    p_rule_crit_param_rec      IN OUT    NOCOPY RULE_CRIT_PARAMS_REC_TYPE,
    p_object_version_number     IN OUT NOCOPY  NUMBER,
    x_return_status             IN OUT NOCOPY  VARCHAR2
) IS

    l_object_version_number             NUMBER;
    l_rowid                             ROWID;
    l_dummy                             VARCHAR2(1) := 'N';

BEGIN

    -- check whether record has been updated by another user. If not, lock it.
    BEGIN
        SELECT OBJECT_VERSION_NUMBER,
               ROWID
        INTO   l_object_version_number,
               l_rowid
        FROM   FUN_RULE_CRIT_PARAMS_B
        WHERE  PARAM_NAME = p_rule_crit_param_rec.param_name
        AND    RULE_OBJECT_ID     = p_rule_crit_param_rec.rule_object_id
        FOR UPDATE OF PARAM_NAME NOWAIT;

        IF NOT ((p_object_version_number is null and l_object_version_number is null)
                OR (p_object_version_number = l_object_version_number))
        THEN
            FND_MESSAGE.SET_NAME('FUN', 'FUN_RULE_API_RECORD_CHANGED');
            FND_MESSAGE.SET_TOKEN('TABLE', 'FUN_RULE_CRIT_PARAMS');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        p_object_version_number := nvl(l_object_version_number, 1) + 1;

    EXCEPTION WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('FUN', 'FUN_RULE_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD', 'FUN_RULE_CRIT_PARAMS');
        FND_MESSAGE.SET_TOKEN('VALUE', 'param_name');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;


    -- Validate for Rule Object Instance, never ever update the criteria parameters for a rule object instance.

    BEGIN
        SELECT 'Y' INTO l_dummy
        FROM   FUN_RULE_OBJECTS_B
        WHERE  RULE_OBJECT_ID  = p_rule_crit_param_rec.rule_object_id
	AND    INSTANCE_LABEL IS NULL AND ORG_ID IS NULL;

    EXCEPTION WHEN NO_DATA_FOUND THEN
        l_dummy := 'N';
    END;

    IF(l_dummy = 'N') THEN
	FND_MESSAGE.SET_NAME('FUN', 'FUN_RULE_NO_UPDATE_PARAM');
	FND_MSG_PUB.ADD;
	RAISE FND_API.G_EXC_ERROR;
    END IF;


    -- call for validations.
    FUN_RULE_VALIDATE_PKG.validate_rule_criteria_params(
      'U',
      p_rule_crit_param_rec,
      l_rowid,
      x_return_status
    );

    IF x_return_status = fnd_api.g_ret_sts_error THEN
      RAISE fnd_api.g_exc_error;
    END IF;


    -- call to table-handler.
    FUN_RULE_CRIT_PARAMS_PKG.UPDATE_ROW (
        X_CRITERIA_PARAM_ID                     =>p_rule_crit_param_rec.criteria_param_id,
        X_RULE_OBJECT_ID                        =>p_rule_crit_param_rec.rule_object_id,
        X_PARAM_NAME                            =>p_rule_crit_param_rec.param_name,
        X_DATA_TYPE                             =>p_rule_crit_param_rec.data_type,
        X_FLEX_VALUE_SET_ID                     =>p_rule_crit_param_rec.flex_value_set_id,
        X_CREATED_BY_MODULE                     =>p_rule_crit_param_rec.created_by_module,
        X_USER_PARAM_NAME              		=>p_rule_crit_param_rec.user_param_name,
        X_DESCRIPTION                           =>p_rule_crit_param_rec.description,
        X_TIP_TEXT                              =>p_rule_crit_param_rec.tiptext
    );

END;

/**
 * PROCEDURE create_rule_crit_param
 *
 * DESCRIPTION
 *     Creates rules criteria objects.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_rule_crit_param_rec          Rules Criteria parameter record
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

PROCEDURE create_rule_crit_param(
    p_init_msg_list           IN        VARCHAR2 := FND_API.G_FALSE,
    p_rule_crit_param_rec     IN        RULE_CRIT_PARAMS_REC_TYPE,
    x_criteria_param_id       OUT NOCOPY    NUMBER,
    x_return_status           OUT NOCOPY       VARCHAR2,
    x_msg_count               OUT NOCOPY       NUMBER,
    x_msg_data                OUT NOCOPY       VARCHAR2
) IS

    l_rule_crit_param_rec       RULE_CRIT_PARAMS_REC_TYPE:= p_rule_crit_param_rec;

BEGIN

    -- standard start of API savepoint
    SAVEPOINT create_rule_crit_param;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --Derive the Datatype for ValuSet Based Criteria Param and internally overwrite the same.
    IF(l_rule_crit_param_rec.flex_value_set_id IS NOT NULL) THEN
          --Validate if the flex_calue_set_id is Valid or not.
          IF (NOT FUN_RULE_VALIDATE_PKG.validate_flex_value_set_id (l_rule_crit_param_rec.flex_value_set_id)) THEN
           fnd_message.set_name('FUN', 'FUN_RULE_INVALID_VALUESET');
           fnd_msg_pub.add;
           x_return_status := fnd_api.g_ret_sts_error;
	  ELSE
           l_rule_crit_param_rec.data_type := FUN_RULE_UTILITY_PKG.getValueSetDataType(l_rule_crit_param_rec.flex_value_set_id);
          END IF;
    END IF;

    IF(l_rule_crit_param_rec.data_type IS NULL or
       l_rule_crit_param_rec.data_type = '') THEN
       l_rule_crit_param_rec.data_type := 'STRINGS';
    END IF;

    -- call to business logic.
    do_create_rule_crit_param(
                             l_rule_crit_param_rec,
                             x_criteria_param_id,
                             x_return_status);

    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);



EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_rule_crit_param;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_rule_crit_param;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO create_rule_crit_param;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('FUN', 'FUN_RULE_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
END create_rule_crit_param;

/**
 * Use this routine to create duplicate Criteria Parameters for a Rule Object and
 * its related information.With this API you can create a record in the
 * FUN_RULE_CRIT_PARAMS_* table.
 *
 * p_init_msg_list        Initialize message stack if it is set to FND_API.G_TRUE. Default is FND_API.G_FALSE.
 * p_from_rule_object_id  Rule Object Id from which you need to create parameters.
 * p_to_rule_object_id    Rule Object Id For/To which you need to create parameters from p_from_rule_object_id.
 * x_return_status        Return status after the call.
 * x_msg_count            Number of messages in message stack.
 * x_msg_data             Message text if x_msg_count is 1.
 *
 * 27-Dec-2005    Amulya Mishra     Created
 */

PROCEDURE create_dup_rule_crit_params(
    p_init_msg_list           		 IN      VARCHAR2 := FND_API.G_FALSE,
    p_from_rule_object_id                IN             NUMBER,
    p_to_rule_object_id                  IN             NUMBER,
    x_return_status           		 OUT NOCOPY     VARCHAR2,
    x_msg_count               		 OUT NOCOPY     NUMBER,
    x_msg_data                		 OUT NOCOPY     VARCHAR2
)IS

BEGIN
    -- standard start of API savepoint
    SAVEPOINT create_rule_dup_crit_param;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- call to business logic.
    do_create_dup_rule_crit_param(
                             p_from_rule_object_id,
                             p_to_rule_object_id,
                             x_return_status);

    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);



EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_rule_dup_crit_param;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_rule_dup_crit_param;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO create_rule_dup_crit_param;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('FUN', 'FUN_RULE_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);


END create_dup_rule_crit_params;

/**
 * PROCEDURE update_rule_crit_param
 *
 * DESCRIPTION
 *     Updates Rules Criteria parameter.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_rule_crit_param_rec          Rules Criteria parameter record.
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

PROCEDURE update_rule_crit_param (
    p_init_msg_list             IN     VARCHAR2 := FND_API.G_FALSE,
    p_rule_crit_param_rec       IN     RULE_CRIT_PARAMS_REC_TYPE,
    p_object_version_number     IN OUT NOCOPY NUMBER,
    x_return_status             OUT NOCOPY    VARCHAR2,
    x_msg_count                 OUT NOCOPY    NUMBER,
    x_msg_data                  OUT NOCOPY    VARCHAR2
) IS

    l_rule_crit_param_rec                    RULE_CRIT_PARAMS_REC_TYPE := p_rule_crit_param_rec;
    l_old_rule_crit_param_rec                RULE_CRIT_PARAMS_REC_TYPE;

BEGIN
    -- standard start of API savepoint
    SAVEPOINT update_rule_crit_param;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Get old records. Will be used by business event system.
    get_rule_crit_param_rec (
        p_rule_object_id                    => l_rule_crit_param_rec.rule_object_id,
        p_param_name                        => l_rule_crit_param_rec.param_name,
        x_rule_crit_param_rec               => l_old_rule_crit_param_rec,
        x_return_status                     => x_return_status,
        x_msg_count                         => x_msg_count,
        x_msg_data                          => x_msg_data );

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Derive the Datatype for ValuSet Based Criteria Param and internally overwrite the same.
    IF(l_rule_crit_param_rec.flex_value_set_id IS NOT NULL) THEN
      l_rule_crit_param_rec.data_type := FUN_RULE_UTILITY_PKG.getValueSetDataType(l_rule_crit_param_rec.flex_value_set_id);
    END IF;

    IF(l_rule_crit_param_rec.data_type IS NULL or
       l_rule_crit_param_rec.data_type = '') THEN
       l_rule_crit_param_rec.data_type := 'STRINGS';
    END IF;

    -- call to business logic.
    do_update_rule_crit_param(
                             l_rule_crit_param_rec,
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
        ROLLBACK TO update_rule_crit_param;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_rule_crit_param;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO update_rule_crit_param;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('FUN', 'FUN_RULE_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
END update_rule_crit_param;


/**
 * PROCEDURE get_rule_crit_param_rec
 *
 * DESCRIPTION
 *     Gets rules criteria Param record.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *     FUN_RULE_CRIT_PARAMS_PKG.Select_Row
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_param_name	              Rule criteria object name..
 *   IN/OUT:
 *   OUT:
 *     x_rule_crit_param_rec          Returned rule criteria param record.
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

PROCEDURE get_rule_crit_param_rec (
    p_init_msg_list                         IN     VARCHAR2 := FND_API.G_FALSE,
    p_rule_object_id                        IN NUMBER,
    p_param_name                            IN VARCHAR2,
    x_rule_crit_param_rec                   OUT    NOCOPY RULE_CRIT_PARAMS_REC_TYPE,
    x_return_status                         OUT NOCOPY    VARCHAR2,
    x_msg_count                             OUT NOCOPY    NUMBER,
    x_msg_data                              OUT NOCOPY    VARCHAR2
) IS
   cpid number;
BEGIN

    --Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    --Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT cp.criteria_param_id
    INTO cpid
    FROM fun_rule_crit_params_b cp
    where cp.rule_object_id = p_rule_object_id
    and cp.param_name = p_param_name;

    x_rule_crit_param_rec.criteria_param_id := cpid;

    FUN_RULE_CRIT_PARAMS_PKG.Select_Row (
	X_CRITERIA_PARAM_ID                     =>x_rule_crit_param_rec.criteria_param_id,
	X_RULE_OBJECT_ID                        =>x_rule_crit_param_rec.rule_object_id,
        X_PARAM_NAME                            =>x_rule_crit_param_rec.param_name,
	X_USER_PARAM_NAME                       =>x_rule_crit_param_rec.user_param_name,
	X_DESCRIPTION                           =>x_rule_crit_param_rec.description,
	X_TIP_TEXT                              =>x_rule_crit_param_rec.tiptext,
	X_DATA_TYPE                             =>x_rule_crit_param_rec.data_type,
        X_FLEX_VALUE_SET_ID                     =>x_rule_crit_param_rec.flex_value_set_id,
	X_CREATED_BY_MODULE                     =>x_rule_crit_param_rec.created_by_module
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

END get_rule_crit_param_rec;


/**
 * PROCEDURE delete_rule_crit_param
 *
 * DESCRIPTION
 *     Deletes Rule Criteria Params.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_param_name                   Object Param Name.
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

PROCEDURE delete_rule_crit_param(
    p_init_msg_list           IN        VARCHAR2 := FND_API.G_FALSE,
    p_criteria_param_id       IN        NUMBER,
    x_return_status           OUT NOCOPY       VARCHAR2,
    x_msg_count               OUT NOCOPY       NUMBER,
    x_msg_data                OUT NOCOPY       VARCHAR2
) IS


BEGIN

    -- standard start of API savepoint
    SAVEPOINT delete_rule_crit_param;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- call to table-handler.
    FUN_RULE_CRIT_PARAMS_PKG.Delete_Row (
        X_CRITERIA_PARAM_ID      =>p_criteria_param_id
    );


    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);


EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO delete_rule_crit_param;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO delete_rule_crit_param;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO delete_rule_crit_param;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('FUN', 'FUN_RULE_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
END delete_rule_crit_param;

END FUN_RULE_CRIT_PARAMS_PUB;

/
