--------------------------------------------------------
--  DDL for Package Body HZ_DSS_GROUPS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_DSS_GROUPS_PUB" AS
/* $Header: ARHPDSSB.pls 120.3 2005/10/18 19:34:06 jhuang noship $ */

----------------------------------
-- declaration of global variables
----------------------------------

-------------------------------------------------
-- private procedures and functions
-------------------------------------------------


--------------------------------------------
-- get_rank_of_dsg
--------------------------------------------

FUNCTION get_rank_of_dsg
-- Return rank if the passed in Data Sharing Group exists in hz_dss_group_b
--        -1 otherwise
(p_dss_group_code VARCHAR2 )
RETURN NUMBER
IS
CURSOR c0
IS
SELECT rank
  FROM hz_dss_groups_b
 WHERE dss_group_code= p_dss_group_code ;
result   NUMBER ;
BEGIN
 OPEN c0;
   FETCH c0 INTO result ;
   IF c0%NOTFOUND THEN
     result := -1 ;
   END IF;
 CLOSE c0;
 RETURN result;
END get_rank_of_dsg ;

--------------------------------------------
-- return_max_rank
--------------------------------------------

FUNCTION return_max_rank
-- Return the maximum rank in hz_dss_group_b , if number of rows is greater than 0.
-- 1 if no rows exist in hz_dss_groups_b
RETURN NUMBER
IS
CURSOR c0
IS
SELECT NVL(MAX(RANK),0)+ 1 FROM HZ_DSS_GROUPS_B;
result   NUMBER ;
BEGIN
 OPEN c0;
   FETCH c0 INTO result ;
   IF HZ_DSS_VALIDATE_PKG.return_no_of_dss_groups > 0
     THEN
        result := result -1 ;
   END IF;
 CLOSE c0;
 RETURN result;
END return_max_rank ;




--------------------------------------------
-- resequence_ranks_to_create
--------------------------------------------

PROCEDURE resequence_ranks_to_create ( p_insert_before_group_rank IN NUMBER )
-- Resequence ranks in hz_dss_groups_b in lieu of creating a new DSG
IS
BEGIN
    update hz_dss_groups_b set rank = rank + 1
    where rank >= p_insert_before_group_rank ;

END resequence_ranks_to_create;


--------------------------------------------
-- resequence_ranks_to_update
--------------------------------------------

PROCEDURE resequence_ranks_to_update ( p_group_to_be_updated_rank IN  NUMBER,
                                       p_insert_before_group_rank IN NUMBER,
                                       p_to_be_upd_group_code IN VARCHAR2,
                                       p_order_before_group_code IN VARCHAR2)
-- Resequence ranks in hz_dss_groups_b in lieu of updating the rank of a DSG
IS
BEGIN
    -- NOTE: IN THIS PROCEDURE WE DO NOT UPDATE THE RANK OF THE GROUP WHOSE RANK
    --       NEEDS TO BE UPDATED. WE RESEQUENCE EVERYTHING ELSE OTHER THAN THAT.

     -- INSERT BEFORE AN EXISTING GROUP CODE
    IF p_order_before_group_code IS NOT NULL AND
       p_order_before_group_code <> FND_API.G_MISS_CHAR
      THEN
    -----------------------------------------------------------------------------------
    -- RESEQUENCE 1: STARTS FROM (INCLUDING) LEVEL OF INSERT BEFORE GROUP AND GOES DOWN.
    --               THE GROUP TO BE UPDATED IS LEFT ALONE
    -----------------------------------------------------------------------------------
    -- FREEZE THE RANK OF GROUP TO BE UPDATED AND INCREMENT EVERY RANK THAT IS BIGGER
    -- THAN THE RANK THAT WE WOULD WANT OUR GROUP TO MOVE INTO, AFTER THE UPDATE.
    update hz_dss_groups_b set rank = rank + 1
    where rank >= p_insert_before_group_rank and dss_group_code <> p_to_be_upd_group_code ;

    ------------------------------------------------------------------------------------------
    -- RESEQUENCE 2: STARTS FROM (EXCLUDING) ONE LEVEL BELOW GROUP TO BE UPDATED AND GOES DOWN.
    -------------------------------------------------------------------------------------------

    -- TO FILL THE HOLE CREATED BY RESEQUENCING THE RANKS, WE NEED TO DECREMENT
    -- THE RANK OF ALL GROUP CODES THAT ARE HIGHER THAN THE RANK OF THE GROUP,
    -- WHOSE RANK HAS TO BE UPDATED.
    update hz_dss_groups_b set rank = rank - 1
    where rank > p_group_to_be_updated_rank ;

   -- INSERT LAST
   ELSIF   p_order_before_group_code = FND_API.G_MISS_CHAR
         THEN
            update hz_dss_groups_b set rank = rank - 1
            where rank > p_group_to_be_updated_rank ;
   END IF;


END resequence_ranks_to_update;



--------------------------------------
-- public procedures and functions
--------------------------------------

---------------------------------------------------------------------
-- NOTE: For create_group we follow this convention:
-- IF order_before_group_code is null or g_miss_char --- we insert last and resequence ranks
-- IF order_before_group_code is a valid group code  --- we insert before the order_before_group_code
                                                      --- and resequence ranks

-- NOTE: For update_group we follow this convention:
-- IF order_before_group_code is g_miss_char         --- we insert last and resequence ranks
-- IF order_before_group_code is null                --- we do not to anything to the ranks
-- IF order_before_group_code is a valid group code  --- we insert before the order_before_group_code
                                                      --- and resequence ranks

----------------------------------------------------------------------
/**
 * PROCEDURE create_group
 *
 * DESCRIPTION
 *     Creates a data sharing group.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 *
 * ARGUMENTS
 *
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   08-13-2002    Colathur Vijayan ("VJN")        o Created.
 *
 */

PROCEDURE create_group(
    p_init_msg_list           IN        VARCHAR2,
    p_dss_group               IN        DSS_GROUP_REC_TYPE,
    x_return_status           OUT NOCOPY       VARCHAR2,
    x_msg_count               OUT NOCOPY       NUMBER,
    x_msg_data                OUT NOCOPY       VARCHAR2
) IS
    row_id varchar2(64);
    rank number;
    temp number;
BEGIN

    -- standard start of API savepoint
    SAVEPOINT create_group;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --validation for mandatory column dss_group_code
    if (p_dss_group.dss_group_code is null or
        p_dss_group.dss_group_code = fnd_api.g_miss_char) then
       FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
       FND_MESSAGE.SET_TOKEN( 'COLUMN', 'dss_group_code' );
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    end if;

     --validation for mandatory column dss_group_name
    if (p_dss_group.dss_group_name is null or
        p_dss_group.dss_group_name = fnd_api.g_miss_char) then
       FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
       FND_MESSAGE.SET_TOKEN( 'COLUMN', 'dss_group_name' );
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    end if;



    -- VALIDATION
    -- PASSED IN GROUP CODE SHOULD BE UNIQUE
    IF HZ_DSS_VALIDATE_PKG.exist_in_dss_groups_b (p_dss_group.dss_group_code) = 'Y'
        THEN
             FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_GR_CODE_EXISTS_ALREADY');
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_ERROR;
     END IF;

   -- IF PASSED IN INSERT BEFORE GROUP IS NEITHER NULL NOR G_MISS_CHAR,
   -- IT SHOULD BE A VALID GROUP CODE

    IF p_dss_group.order_before_group_code IS NOT NULL AND
       p_dss_group.order_before_group_code <> FND_API.G_MISS_CHAR
       THEN
            IF HZ_DSS_VALIDATE_PKG.exist_in_dss_groups_b (p_dss_group.order_before_group_code) = 'N'
                THEN
                    FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_ORD_BEF_GR_CODE_INVALID');
                    FND_MSG_PUB.ADD;
                    RAISE FND_API.G_EXC_ERROR;
            END IF;
     END IF;


    -- PASSED IN GROUP NAME SHOULD BE UNIQUE IN AN MLS LANGUAGE
    IF HZ_DSS_VALIDATE_PKG.exist_in_dss_groups_vl (p_dss_group.dss_group_name) = 'Y'
        THEN
             FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_GR_NAME_EXISTS_ALREADY');
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_ERROR;
    END IF;


    -- STATUS VALIDATION

   IF p_dss_group.status is not null then
      IF HZ_DSS_VALIDATE_PKG.exist_in_ar_lookups(
         p_dss_group.status, 'REGISTRY_STATUS')= 'N' THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_GR_STATUS_VAL_INVALID');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

     -- BES ENABLE FLAG SHOULD BE Y OR N
     IF UPPER( NVL(p_dss_group.bes_enable_flag,'N') ) IN ('Y','N') THEN
       NULL;
     ELSE
       FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_GR_BES_FLAG_INVALID');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
     END IF;

    -- RANK RESEQUENCING
    -- CASE 1: WE WANT TO INSERT BEFORE AN EXISTING GROUP CODE
    IF p_dss_group.order_before_group_code IS NOT NULL AND
       p_dss_group.order_before_group_code <> FND_API.G_MISS_CHAR
          THEN
            rank :=  get_rank_of_dsg(p_dss_group.order_before_group_code);
            resequence_ranks_to_create(rank );
    -- CASE 2: WE WANT TO INSERT LAST -- NO NEED TO RESEQUENCE HERE !!!!!
    --         SINCE WE WANT TO INSERT LAST, WE NEED TO INCREMENT MAX RANK BY 1.
    --         THE ONLY EXCEPTION TO THIS RULE, IS WHEN WE HAVE NO ROWS AND
    --         WE WANT TO ADD A NEW ROW.
    ELSE
             IF HZ_DSS_VALIDATE_PKG.return_no_of_dss_groups > 0
                THEN
                    rank := return_max_rank + 1 ;
             ELSE
                    rank := return_max_rank ;
             END IF;
    END IF;


    -- Call the low level table handler
    HZ_DSS_GROUPS_PKG.Insert_Row (
            x_rowid                       => row_id ,
            x_dss_group_code              => p_dss_group.dss_group_code,
            x_rank                        => rank ,
            x_status                      => nvl(p_dss_group.status,'A'),
            x_dss_group_name              => p_dss_group.dss_group_name,
            x_description                 => p_dss_group.description,
            x_bes_enable_flag             => nvl(p_dss_group.bes_enable_flag,'Y'),
            x_object_version_number       => 1);


    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_group ;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_group ;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO create_group ;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
    END create_group ;


/**
 * PROCEDURE update_group
 *
 * DESCRIPTION
 *     Updates a data sharing group.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 *
 * ARGUMENTS
 *
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   08-13-2002    Colathur Vijayan ("VJN")        o Created.
 *
 */

PROCEDURE update_group (
    p_init_msg_list               IN     VARCHAR2,
    p_dss_group                   IN     dss_group_rec_type,
    x_object_version_number       IN OUT NOCOPY NUMBER,
    x_return_status               OUT    NOCOPY VARCHAR2,
    x_msg_count                   OUT    NOCOPY NUMBER,
    x_msg_data                    OUT    NOCOPY VARCHAR2
)
 IS

    rank                          NUMBER;
    l_rank                        NUMBER;
    temp1                         NUMBER;
    temp2                         NUMBER;
    l_object_version_number       NUMBER;
    l_rowid                       ROWID;
    l_status                      VARCHAR2(1);

BEGIN

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- standard start of API savepoint
    SAVEPOINT update_group;

    --Non updateable to null
    IF ( p_dss_group.dss_group_code IS NULL OR
         p_dss_group.dss_group_code= FND_API.G_MISS_CHAR )
    THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_NONUPDATEABLE_TO_NULL');
      FND_MESSAGE.SET_TOKEN( 'COLUMN', 'dss_group_code' );
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --Non updateable to null
    IF p_dss_group.dss_group_name = FND_API.G_MISS_CHAR THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_NONUPDATEABLE_TO_NULL');
      FND_MESSAGE.SET_TOKEN( 'COLUMN', 'dss_group_name' );
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF p_dss_group.bes_enable_flag = FND_API.G_MISS_CHAR THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_NONUPDATEABLE_TO_NULL');
      FND_MESSAGE.SET_TOKEN( 'COLUMN', 'bes_enable_flag' );
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- check whether record has been updated by another user. If not, lock it.
    BEGIN
      SELECT object_version_number, rowid, rank, status
      INTO   l_object_version_number, l_rowid, l_rank, l_status
      FROM   hz_dss_groups_b
      WHERE  dss_group_code = p_dss_group.dss_group_code
      FOR UPDATE NOWAIT;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_GR_CODE_INVALID');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;

    IF NOT ((x_object_version_number IS NULL AND
             l_object_version_number IS NULL) OR
            (x_object_version_number = l_object_version_number))
    THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
      FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_DSS_GROUPS');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_object_version_number := NVL(l_object_version_number, 1) + 1;

    -- VALIDATION
    -- PASSED IN GROUP CODE SHOULD BE VALID
    -- already validated when getting object_version_number.
    /*
     IF HZ_DSS_VALIDATE_PKG.exist_in_dss_groups_b (p_dss_group.dss_group_code) = 'N' THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_GR_CODE_INVALID');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    */

    -- IF PASSED IN INSERT BEFORE GROUP IS NEITHER NULL NOR G_MISS_CHAR,
    -- IT SHOULD BE A VALID GROUP CODE

    IF p_dss_group.order_before_group_code IS NOT NULL AND
       p_dss_group.order_before_group_code <> FND_API.G_MISS_CHAR
    THEN
      IF HZ_DSS_VALIDATE_PKG.exist_in_dss_groups_b (
           p_dss_group.order_before_group_code) = 'N'
      THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_ORD_BEF_GR_CODE_INVALID');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    -- PASSED IN GROUP NAME SHOULD BE UNIQUE IN AN MLS LANGUAGE
    IF p_dss_group.dss_group_name IS NOT NULL THEN
      IF HZ_DSS_VALIDATE_PKG.exist_in_dss_groups_vl (
           p_dss_group.dss_group_name, p_dss_group.dss_group_code) = 'Y'
      THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_GR_NAME_EXISTS_ALREADY');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    -- STATUS VALIDATION

    IF p_dss_group.status IS NOT NULL THEN
      IF HZ_DSS_VALIDATE_PKG.exist_in_ar_lookups(
           p_dss_group.status,
           'REGISTRY_STATUS')= 'N'
      THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_GR_STATUS_VAL_INVALID');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    -- BES ENABLE FLAG SHOULD BE Y OR N
    IF p_dss_group.bes_enable_flag IS NOT NULL THEN
      IF p_dss_group.bes_enable_flag <> 'Y' AND
         p_dss_group.bes_enable_flag <> 'N'
      THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_GR_BES_FLAG_INVALID');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    -- RANK RESEQUENCING
    -- BEFORE WE DO ANYTHING, WE LET THE RANK DEFAULT TO WHAT IS IN THE EXISTING ROW

    rank := l_rank;

    -- GROUP TO BE UPDATED
    temp1 :=  get_rank_of_dsg(p_dss_group.dss_group_code) ;

    -- GROUP BEFORE WHICH WE WANT TO INSERT
    temp2 :=  get_rank_of_dsg(p_dss_group.order_before_group_code) ;

    -- CASE 1 : WE WANT TO INSERT BEFORE AN EXISTING GROUP CODE
    IF p_dss_group.order_before_group_code IS NOT NULL AND
       p_dss_group.order_before_group_code <> FND_API.G_MISS_CHAR
    THEN
      resequence_ranks_to_update(
        temp1, temp2, p_dss_group.dss_group_code,
        p_dss_group.order_before_group_code);

      -- NOTE: THIS OFFSET IS IMPORTANT
      -- WHEN RANK NEEDS TO GO UP AFTER UPDATION
      IF temp1 > temp2 THEN
        rank := temp2 ;
      -- WHEN RANK NEEDS TO GO DOWN  AFTER UPDATION
      ELSIF temp1 < temp2 THEN
        rank := temp2 - 1;
      END IF;

    -- CASE 2 : WE WANT TO INSERT LAST
    ELSIF p_dss_group.order_before_group_code = FND_API.G_MISS_CHAR THEN
      rank := return_max_rank ;
      resequence_ranks_to_update(
        temp1, temp2, p_dss_group.dss_group_code,
        p_dss_group.order_before_group_code);

    END IF;

    -- Bug#3711820 - update grants when the status of a dss group has been
    -- changed.
    --
    -- reset grant end date if status has been switched from I to A.
    -- end-dated fnd grants if status has been switched from A to I.
    --
    -- status is null means no change
    -- status = G_MISS case has been caught by the lookup validation
    --
    IF p_dss_group.status IS NOT NULL AND
       ((p_dss_group.status = 'A' AND l_status = 'I') OR
        (p_dss_group.status = 'I' AND l_status = 'A'))
    THEN

      hz_dss_grants_pub.update_grant (
        p_dss_group_code          => p_dss_group.dss_group_code,
        p_dss_group_status        => p_dss_group.status,
        x_return_status           => x_return_status,
        x_msg_count               => x_msg_count,
        x_msg_data                => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    END IF;

    -- Call the low level table handler
    HZ_DSS_GROUPS_PKG.Update_Row (
      x_rowid                     => l_rowid ,
      x_rank                      => rank ,
      x_status                    => p_dss_group.status,
      x_dss_group_name            => p_dss_group.dss_group_name,
      x_description               => p_dss_group.description,
      x_bes_enable_flag           => p_dss_group.bes_enable_flag,
      x_object_version_number     => x_object_version_number
    );

    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_group ;
        x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_group ;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO update_group ;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
END update_group ;


/*------------------------------------------------------------------------
 * PROCEDURE create_secured_module
 *
 * DESCRIPTION
 *     Creates a created_by_module based criterion
 *     for a data sharing sharing group
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 *
 * ARGUMENTS
 *
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   10-15-2002    Jyoti Pandey        o Created.
 *
 ------------------------------------------------------------------------*/

PROCEDURE create_secured_module (
-- input parameters
    p_init_msg_list             IN  VARCHAR2,
    p_dss_secured_module        IN  dss_secured_module_type,
-- output parameters
    x_secured_item_id           OUT NOCOPY NUMBER,
    x_return_status             OUT NOCOPY VARCHAR2,
    x_msg_count                 OUT NOCOPY NUMBER,
    x_msg_data                  OUT NOCOPY VARCHAR2
) IS
    row_id varchar2(64);
    l_dup_count NUMBER := 0;
BEGIN

    -- standard start of API savepoint
    SAVEPOINT create_secured_module ;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --mandatory fields
    IF (p_dss_secured_module.dss_group_code is null OR
        p_dss_secured_module.dss_group_code = FND_API.G_MISS_CHAR) THEN
       FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
       FND_MESSAGE.SET_TOKEN( 'COLUMN', 'dss_group_code' );
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (p_dss_secured_module.created_by_module is null OR
        p_dss_secured_module.created_by_module = FND_API.G_MISS_CHAR) THEN
       FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
       FND_MESSAGE.SET_TOKEN( 'COLUMN', 'created_by_module' );
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF;


    -- DSG validation
    IF HZ_DSS_VALIDATE_PKG.exist_in_dss_groups_b (
                    p_dss_secured_module.dss_group_code) = 'N'
        THEN
             FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_GR_CODE_INVALID');
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- status validation
    IF p_dss_secured_module.status is not null then
       IF HZ_DSS_VALIDATE_PKG.exist_in_ar_lookups(
           p_dss_secured_module.status, 'REGISTRY_STATUS')= 'N' THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_GR_STATUS_VAL_INVALID');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;

     ---created_by_module validation
     IF HZ_DSS_VALIDATE_PKG.exist_in_ar_lookups_gl(
       p_dss_secured_module.created_by_module, 'HZ_CREATED_BY_MODULES') ='N'
       THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_CREATED_MODULE_INVALID');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
     END IF;

    --Bug 2645685 Duplicate criteria should not be created for a Data Sharing
    --group, class catefory and class code combination

    select count(*) into l_dup_count
    from  HZ_DSS_CRITERIA
    where dss_group_code = p_dss_secured_module.dss_group_code
    and owner_table_name  = 'AR_LOOKUPS'
    and owner_table_id1 =  'HZ_CREATED_BY_MODULES'
    and owner_table_id2 =  p_dss_secured_module.created_by_module;

    if l_dup_count >= 1 then
       FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_DUP_CRITERIA_MODULE');
       FND_MESSAGE.SET_TOKEN('MODULE', p_dss_secured_module.created_by_module);
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
     END IF;


    -- Call the low level table handler
    HZ_DSS_CRITERIA_PKG.Insert_Row (
        x_rowid                  => row_id,
        x_secured_item_id        => x_secured_item_id,
        x_status                 => nvl(p_dss_secured_module.status,'A'),
        x_dss_group_code         => p_dss_secured_module.dss_group_code,
        x_owner_table_name       => 'AR_LOOKUPS',
        x_owner_table_id1        => 'HZ_CREATED_BY_MODULES',
        x_owner_table_id2        => p_dss_secured_module.created_by_module ,
        x_object_version_number  => 1 );


    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_secured_module ;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_secured_module ;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO create_secured_module ;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
END create_secured_module;

/*------------------------------------------------------------------------
 * PROCEDURE update_secured_module
 *
 * DESCRIPTION
 *     Updates a created_by_module based criterion
 *     for a data sharing sharing group
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 *
 * ARGUMENTS
 *
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   10-15-2002    Jyoti Pandey        o Created.
 *
 ------------------------------------------------------------------------*/

PROCEDURE update_secured_module (
        p_init_msg_list                 IN  VARCHAR2,
        p_dss_secured_module            IN  dss_secured_module_type,
        x_object_version_number         IN OUT NOCOPY NUMBER,
        x_return_status                 OUT NOCOPY VARCHAR2,
        x_msg_count                     OUT NOCOPY NUMBER,
        x_msg_data                      OUT NOCOPY VARCHAR2
)
IS
    l_object_version_number           NUMBER;
    l_rowid                           ROWID;
    l_dss_group_code           HZ_DSS_CRITERIA.DSS_GROUP_CODE%TYPE;
    l_created_by_module        HZ_DSS_CRITERIA.owner_table_id2%TYPE;

BEGIN
    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- standard start of API savepoint
    SAVEPOINT update_secured_module ;

    -- check whether record has been updated by another user. If not, lock it.
    BEGIN
      SELECT object_version_number, rowid,dss_group_code,owner_table_id2
      INTO   l_object_version_number, l_rowid,l_dss_group_code,l_created_by_module
      FROM   HZ_DSS_CRITERIA
      WHERE  secured_item_id = p_dss_secured_module.secured_item_id
      FOR UPDATE NOWAIT;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_ITEM_ID_INVALID');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;


        IF NOT ((x_object_version_number is null and l_object_version_number is null)
                OR (x_object_version_number = l_object_version_number))
        THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
            FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_DSS_CRITERIA');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        x_object_version_number := nvl(l_object_version_number, 1) + 1;

    --Bug 2618664 Only status column can be updated
      IF  ( p_dss_secured_module.dss_group_code <> FND_API.G_MISS_CHAR OR
           l_dss_group_code IS NOT NULL )
       AND ( l_dss_group_code IS NULL OR
             p_dss_secured_module.dss_group_code <> l_dss_group_code ) THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_DSS_CRITERIA_IMMUTABLE' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
     END IF;


   IF  ( p_dss_secured_module.created_by_module <> FND_API.G_MISS_CHAR OR
           l_created_by_module IS NOT NULL )
       AND ( l_created_by_module IS NULL OR
             p_dss_secured_module.created_by_module <> l_created_by_module ) THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_DSS_CRITERIA_IMMUTABLE' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
     END IF;

    -- status validation
    IF  p_dss_secured_module.status is not null then
       IF HZ_DSS_VALIDATE_PKG.exist_in_ar_lookups(
           p_dss_secured_module.status, 'REGISTRY_STATUS')= 'N' THEN
           FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_GR_STATUS_VAL_INVALID');
           FND_MSG_PUB.ADD;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
   END IF;

/*
    ---created_by_module validation
     IF p_dss_secured_module.created_by_module is not null then
     IF HZ_DSS_VALIDATE_PKG.exist_in_ar_lookups(
       p_dss_secured_module.created_by_module, 'HZ_CREATED_BY_MODULES') ='N'
       THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_CREATED_MODULE_INVALID');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
     END IF;
     END IF;
*/


    -- Call the low level table handler
    HZ_DSS_CRITERIA_PKG.Update_Row (
    x_rowid                  => l_rowid,
    x_status                 => p_dss_secured_module.status,
    x_dss_group_code         => p_dss_secured_module.dss_group_code,
    x_owner_table_name       => 'AR_LOOKUPS',
    x_owner_table_id1        => 'HZ_CREATED_BY_MODULES',
    x_owner_table_id2        => p_dss_secured_module.created_by_module ,
    x_object_version_number  => x_object_version_number);

    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_secured_module ;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_secured_module ;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO update_secured_module ;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
END update_secured_module ;



/**
 * PROCEDURE create_secured_criterion
 *
 * DESCRIPTION
 *     Creates a criterion that determines how a data sharing sharing group
 *     should be assigned to an entity.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 *
 * ARGUMENTS
 *
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   08-27-2002    Colathur Vijayan ("VJN")        o Created.
 *
 */

PROCEDURE create_secured_criterion (
        p_init_msg_list                 IN  VARCHAR2,
        p_dss_secured_criterion IN  dss_secured_criterion_type,
    x_secured_item_id           OUT NOCOPY NUMBER,
        x_return_status                 OUT NOCOPY VARCHAR2,
    x_msg_count                         OUT NOCOPY NUMBER,
    x_msg_data                          OUT NOCOPY VARCHAR2
)
IS
    row_id varchar2(64);
    l_dup_count NUMBER := 0;
    l_dss_secured_module HZ_DSS_GROUPS_PUB.dss_secured_module_type;

BEGIN

    -- standard start of API savepoint
    SAVEPOINT create_secured_criterion ;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

     --Call the create_secured_module API
    IF (p_dss_secured_criterion.owner_table_name = 'AR_LOOKUPS' AND
        p_dss_secured_criterion.owner_table_id1 = 'HZ_CREATED_BY_MODULES') THEN

      l_dss_secured_module.secured_item_id :=
           p_dss_secured_criterion.secured_item_id;
      l_dss_secured_module.dss_group_code  :=
           p_dss_secured_criterion.dss_group_code;
      l_dss_secured_module.created_by_module:=
           p_dss_secured_criterion.owner_table_id2;
      l_dss_secured_module.status := p_dss_secured_criterion.status;

     --Call the create_secured_module API
     create_secured_module(p_init_msg_list,
                           l_dss_secured_module,
                           x_secured_item_id ,
                           x_return_status,
                           x_msg_count,
                           x_msg_data);

   ELSE

     --mandatory dss_group
     IF (p_dss_secured_criterion.dss_group_code is null OR
        p_dss_secured_criterion.dss_group_code = FND_API.G_MISS_CHAR) THEN
       FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
       FND_MESSAGE.SET_TOKEN( 'COLUMN', 'dss_group_code' );
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
     END IF;

    -- VALIDATION
    -- PASSED IN GROUP CODE SHOULD BE VALID
    IF HZ_DSS_VALIDATE_PKG.exist_in_dss_groups_b (
        p_dss_secured_criterion.dss_group_code) = 'N'
        THEN
             FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_GR_CODE_INVALID');
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- STATUS VALIDATION
    IF p_dss_secured_criterion.status is not null then
       IF HZ_DSS_VALIDATE_PKG.exist_in_ar_lookups(
          p_dss_secured_criterion.status, 'REGISTRY_STATUS')= 'N' THEN
          FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_GR_STATUS_VAL_INVALID');
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;


    -- Call the low level table handler
    HZ_DSS_CRITERIA_PKG.Insert_Row (
        x_rowid             => row_id,
        x_secured_item_id   => x_secured_item_id,
        x_status            => nvl(p_dss_secured_criterion.status,'A'),
        x_dss_group_code    => p_dss_secured_criterion.dss_group_code,
        x_owner_table_name  => p_dss_secured_criterion.owner_table_name,
        x_owner_table_id1   => p_dss_secured_criterion.owner_table_id1 ,
        x_owner_table_id2   => p_dss_secured_criterion.owner_table_id2 ,
        x_object_version_number => 1);

  END IF;


    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_secured_criterion ;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_secured_criterion ;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO create_secured_criterion ;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
    END create_secured_criterion ;


/**
 * PROCEDURE update_secured_criterion
 *
 * DESCRIPTION
 *     Updates a criterion that determines how a data sharing sharing group
 *     should be assigned to an entity.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 *
 * ARGUMENTS
 *
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   08-13-2002    Colathur Vijayan ("VJN")        o Created.
 *
 */

PROCEDURE update_secured_criterion (
        p_init_msg_list                     IN  VARCHAR2,
        p_dss_secured_criterion         IN  dss_secured_criterion_type,
    x_object_version_number             IN OUT NOCOPY NUMBER,
        x_return_status                     OUT NOCOPY VARCHAR2,
    x_msg_count                             OUT NOCOPY NUMBER,
    x_msg_data                              OUT NOCOPY VARCHAR2
)
IS
    l_object_version_number           NUMBER;
    l_rowid                           ROWID;
    l_dss_secured_module   HZ_DSS_GROUPS_PUB.dss_secured_module_type;

BEGIN
    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- standard start of API savepoint
    SAVEPOINT update_secured_criterion ;

    -- check whether record has been updated by another user. If not, lock it.
    BEGIN
      SELECT object_version_number, rowid
      INTO   l_object_version_number, l_rowid
      FROM   HZ_DSS_CRITERIA
      WHERE  secured_item_id = p_dss_secured_criterion.secured_item_id
      FOR UPDATE NOWAIT;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_ITEM_ID_INVALID');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;


        IF NOT ((x_object_version_number is null and l_object_version_number is null)
                OR (x_object_version_number = l_object_version_number))
        THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
            FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_DSS_CRITERIA');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;



      --Call the create_secured_module API
    IF (p_dss_secured_criterion.owner_table_name = 'AR_LOOKUPS' AND
        p_dss_secured_criterion.owner_table_id1 = 'HZ_CREATED_BY_MODULES') THEN

      l_dss_secured_module.secured_item_id :=
           p_dss_secured_criterion.secured_item_id;
      l_dss_secured_module.dss_group_code  :=
           p_dss_secured_criterion.dss_group_code;
      l_dss_secured_module.created_by_module:=
           p_dss_secured_criterion.owner_table_id2;
      l_dss_secured_module.status := p_dss_secured_criterion.status;

     --Call the create_secured_module API
     update_secured_module(p_init_msg_list,
                           l_dss_secured_module,
                           x_object_version_number,
                           x_return_status,
                           x_msg_count,
                           x_msg_data);


   ELSE

       -- VALIDATION

    -- STATUS VALIDATION

    IF p_dss_secured_criterion.status is not null then
    IF HZ_DSS_VALIDATE_PKG.exist_in_ar_lookups(
       p_dss_secured_criterion.status, 'REGISTRY_STATUS')= 'N'
        THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_GR_STATUS_VAL_INVALID');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
     END IF;
     END IF;

    x_object_version_number := nvl(l_object_version_number, 1) + 1;

    -- Call the low level table handler
    HZ_DSS_CRITERIA_PKG.Update_Row (
    x_rowid                       => l_rowid,
    x_status                      => p_dss_secured_criterion.status,
    x_dss_group_code              => p_dss_secured_criterion.dss_group_code,
    x_owner_table_name            => p_dss_secured_criterion.owner_table_name,
    x_owner_table_id1             => p_dss_secured_criterion.owner_table_id1 ,
    x_owner_table_id2             => p_dss_secured_criterion.owner_table_id2 ,
    x_object_version_number       => x_object_version_number);

    x_object_version_number := nvl(l_object_version_number, 1) + 1;

  END IF;
    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_secured_criterion ;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_secured_criterion ;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO update_secured_criterion ;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
END update_secured_criterion ;




/**
 * PROCEDURE create_secured_classification
 *
 * DESCRIPTION
 *     Creates a criterion that determines how a data sharing sharing group
 *     should be assigned to an entity.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 *
 * ARGUMENTS
 *
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   08-13-2002    Colathur Vijayan ("VJN")        o Created.
 *
 */

PROCEDURE create_secured_classification(
-- input parameters
        p_init_msg_list                 IN  VARCHAR2,
        p_dss_secured_class             IN  dss_secured_class_type,
-- output parameters
    x_secured_item_id           OUT NOCOPY NUMBER,
        x_return_status                 OUT NOCOPY VARCHAR2,
    x_msg_count                         OUT NOCOPY NUMBER,
    x_msg_data                          OUT NOCOPY VARCHAR2
)
IS
    row_id varchar2(64);
    l_dup_count NUMBER := 0;
BEGIN

    -- standard start of API savepoint
    SAVEPOINT create_secured_classification ;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --mandatory fields
    IF (p_dss_secured_class.dss_group_code is null OR
        p_dss_secured_class.dss_group_code = FND_API.G_MISS_CHAR) THEN
       FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
       FND_MESSAGE.SET_TOKEN( 'COLUMN', 'dss_group_code' );
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (p_dss_secured_class.class_category is null OR
        p_dss_secured_class.class_category = FND_API.G_MISS_CHAR) THEN
       FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
       FND_MESSAGE.SET_TOKEN( 'COLUMN', 'class_category' );
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (p_dss_secured_class.class_code is null OR
        p_dss_secured_class.class_code = FND_API.G_MISS_CHAR) THEN
       FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
       FND_MESSAGE.SET_TOKEN( 'COLUMN', 'class_code' );
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- VALIDATION

    -- PASSED IN GROUP CODE SHOULD BE VALID
    IF HZ_DSS_VALIDATE_PKG.exist_in_dss_groups_b (p_dss_secured_class.dss_group_code) = 'N'
        THEN
             FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_GR_CODE_INVALID');
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- PASSED IN CLASS CATEGORY SHOULD BE VALID
    IF HZ_DSS_VALIDATE_PKG.exist_in_hz_class_categories (p_dss_secured_class.class_category) = 'N'
        THEN
             FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_CL_CATEGORY_INVALID');
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_ERROR;
     END IF;

    -- PASSED IN CLASS CODE SHOULD BE VALID
    IF HZ_DSS_VALIDATE_PKG.exist_in_fnd_lookups(p_dss_secured_class.class_code,p_dss_secured_class.class_category ) = 'N'
        THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_CL_CODE_INVALID');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
     END IF;


     -- STATUS VALIDATION
    IF p_dss_secured_class.status is not null then
       IF HZ_DSS_VALIDATE_PKG.exist_in_ar_lookups(p_dss_secured_class.status,
          'REGISTRY_STATUS')= 'N' THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_GR_STATUS_VAL_INVALID');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;

    --Bug 2645685 Duplicate criteria should not be created for a Data Sharing
    --group, class catefory and class code combination

    select count(*) into l_dup_count
    from  HZ_DSS_CRITERIA
    where dss_group_code = p_dss_secured_class.dss_group_code
    and owner_table_name  = 'FND_LOOKUP_VALUES'
    and owner_table_id1 = p_dss_secured_class.class_category
    and owner_table_id2 = p_dss_secured_class.class_code;

    if l_dup_count >= 1 then
       FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_DUP_CRITERIA_CLASS');
       FND_MESSAGE.SET_TOKEN('CATEGORY', p_dss_secured_class.class_category);
       FND_MESSAGE.SET_TOKEN('CLASS', p_dss_secured_class.class_code);
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
     END IF;


    -- Call the low level table handler
    HZ_DSS_CRITERIA_PKG.Insert_Row (
        x_rowid                       => row_id,
        x_secured_item_id             => x_secured_item_id,
        x_status                      => nvl(p_dss_secured_class.status,'A'),
        x_dss_group_code              => p_dss_secured_class.dss_group_code,
        x_owner_table_name            => 'FND_LOOKUP_VALUES',
        x_owner_table_id1             => p_dss_secured_class.class_category,
        x_owner_table_id2             => p_dss_secured_class.class_code,
        x_object_version_number       => 1);


    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_secured_classification ;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_secured_classification ;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO create_secured_classification ;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
    END create_secured_classification ;

/**
 * PROCEDURE update_secured_classification
 *
 * DESCRIPTION
 *     Updates a criterion that determines how a data sharing sharing group
 *     should be assigned to an entity.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 *
 * ARGUMENTS
 *
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   08-13-2002    Colathur Vijayan ("VJN")        o Created.
 *
 */

PROCEDURE update_secured_classification (
-- input parameters
        p_init_msg_list                 IN  VARCHAR2,
        p_dss_secured_class             IN  dss_secured_class_type,
-- in/out parameters
    x_object_version_number     IN OUT NOCOPY NUMBER,
-- output parameters
        x_return_status                 OUT NOCOPY VARCHAR2,
    x_msg_count                         OUT NOCOPY NUMBER,
    x_msg_data                          OUT NOCOPY VARCHAR2
)
IS
    l_object_version_number           NUMBER;
    l_rowid                           ROWID;
    l_dss_group_code           HZ_DSS_CRITERIA.DSS_GROUP_CODE%TYPE;
    l_class_category           HZ_DSS_CRITERIA.owner_table_id1%TYPE;
    l_class_code               HZ_DSS_CRITERIA.owner_table_id2%TYPE;

BEGIN
    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- standard start of API savepoint
    SAVEPOINT update_secured_classification ;

    -- check whether record has been updated by another user. If not, lock it.

    BEGIN
      SELECT object_version_number, rowid , dss_group_code,
             owner_table_id1,owner_table_id2
      INTO   l_object_version_number, l_rowid ,l_dss_group_code ,
             l_class_category , l_class_code
      FROM   HZ_DSS_CRITERIA
      WHERE  secured_item_id = p_dss_secured_class.secured_item_id
      FOR UPDATE NOWAIT;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_ITEM_ID_INVALID');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;

        IF NOT ((x_object_version_number is null and l_object_version_number is null)
                OR (x_object_version_number = l_object_version_number))
        THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
            FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_DSS_CRITERIA');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        x_object_version_number := nvl(l_object_version_number, 1) + 1;

    -- VALIDATION
    --Bug 2618664 Only status column can be updated
      IF  ( p_dss_secured_class.dss_group_code <> FND_API.G_MISS_CHAR OR
           l_dss_group_code IS NOT NULL )
       AND ( l_dss_group_code IS NULL OR
             p_dss_secured_class.dss_group_code <> l_dss_group_code ) THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_DSS_CRITERIA_IMMUTABLE' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
     END IF;


   IF  ( p_dss_secured_class.class_category <> FND_API.G_MISS_CHAR OR
           l_class_category IS NOT NULL )
       AND ( l_class_category IS NULL OR
             p_dss_secured_class.class_category <> l_class_category ) THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_DSS_CRITERIA_IMMUTABLE' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
     END IF;

   IF  ( p_dss_secured_class.class_code <> FND_API.G_MISS_CHAR OR
           l_class_code IS NOT NULL )
       AND ( l_class_code IS NULL OR
             p_dss_secured_class.class_code <> l_class_code ) THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_DSS_CRITERIA_IMMUTABLE' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
     END IF;


    -- STATUS VALIDATION
    IF p_dss_secured_class.status is not null then
       IF HZ_DSS_VALIDATE_PKG.exist_in_ar_lookups(p_dss_secured_class.status,
          'REGISTRY_STATUS')= 'N' THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_GR_STATUS_VAL_INVALID');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;

    -- Call the low level table handler
    HZ_DSS_CRITERIA_PKG.Update_Row (
    x_rowid                                 => l_rowid,
    x_status                                => p_dss_secured_class.status,
    x_dss_group_code                        => p_dss_secured_class.dss_group_code,
    x_owner_table_name                      => 'AR_LOOKUPS',
    x_owner_table_id1                       => p_dss_secured_class.class_category,
    x_owner_table_id2                       => p_dss_secured_class.class_code,
    x_object_version_number                 => x_object_version_number
);

    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_secured_classification ;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_secured_classification ;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO update_secured_classification ;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
END update_secured_classification ;



/**
 * PROCEDURE create_secured_rel_type
 *
 * DESCRIPTION
 * The create_secured_rel_type procedure creates a record in HZ_DSS_CRITERIA that
 * identifies a Relationship Type to be used as a criterion to determine if data falls under
 * the Data Sharing Group.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 *
 * ARGUMENTS
 *
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   08-13-2002    Colathur Vijayan ("VJN")        o Created.
 *
 */

PROCEDURE create_secured_rel_type (
-- input parameters
        p_init_msg_list                 IN  VARCHAR2,
        p_dss_secured_rel_type  IN  dss_secured_rel_type,
-- output parameters
    x_secured_item_id           OUT NOCOPY NUMBER,
        x_return_status                 OUT NOCOPY VARCHAR2,
    x_msg_count                         OUT NOCOPY NUMBER,
    x_msg_data                          OUT NOCOPY VARCHAR2
)
IS
    row_id varchar2(64);
    l_dup_count NUMBER := 0;
    l_rel_type HZ_RELATIONSHIP_TYPES.RELATIONSHIP_TYPE%TYPE;

BEGIN

    -- standard start of API savepoint
    SAVEPOINT create_secured_rel_type ;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- VALIDATION of mandatory fields
    IF (p_dss_secured_rel_type.dss_group_code is null OR
        p_dss_secured_rel_type.dss_group_code = FND_API.G_MISS_CHAR) THEN
       FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
       FND_MESSAGE.SET_TOKEN( 'COLUMN', 'dss_group_code' );
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

     IF (p_dss_secured_rel_type.relationship_type_id is null OR
        p_dss_secured_rel_type.relationship_type_id = FND_API.G_MISS_NUM) THEN
       FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
       FND_MESSAGE.SET_TOKEN( 'COLUMN', 'relationship_type_id' );
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF;



    -- PASSED IN GROUP CODE SHOULD BE VALID
    IF HZ_DSS_VALIDATE_PKG.exist_in_dss_groups_b (p_dss_secured_rel_type.dss_group_code) = 'N'
        THEN
             FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_GR_CODE_INVALID');
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- PASSED IN RELATIONSHIP_TYPE_ID SHOULD BE VALID
    IF HZ_DSS_VALIDATE_PKG.exist_in_hz_relationship_types (p_dss_secured_rel_type.relationship_type_id) = 'N'
        THEN
             FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_REL_TYPE_ID_INVALID');
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_ERROR;
     END IF;


     -- STATUS VALIDATION
    IF p_dss_secured_rel_type.status is not null then
       IF HZ_DSS_VALIDATE_PKG.exist_in_ar_lookups(p_dss_secured_rel_type.status,
          'REGISTRY_STATUS')= 'N' THEN
          FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_GR_STATUS_VAL_INVALID');
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;

    --Bug 2645685 Duplicate criteria should not be created for a Data Sharing
    --group, class catefory and class code combination

    select count(*)  into l_dup_count
    from  HZ_DSS_CRITERIA
    where dss_group_code = p_dss_secured_rel_type.dss_group_code
    and owner_table_name  = 'HZ_RELATIONSHIP_TYPES'
    and owner_table_id1 = TO_CHAR(p_dss_secured_rel_type.relationship_type_id);

    if l_dup_count >= 1 then
      --get the rel type
       select relationship_type into l_rel_type
       from HZ_RELATIONSHIP_TYPES
       where relationship_type_id = p_dss_secured_rel_type.relationship_type_id;

       FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_DUP_CRITERIA_REL');
       FND_MESSAGE.SET_TOKEN('RELROLE', l_rel_type);
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
     END IF;


    -- Call the low level table handler
    HZ_DSS_CRITERIA_PKG.Insert_Row (
        x_rowid                       => row_id,
        x_secured_item_id             => x_secured_item_id,
        x_status                      => nvl(p_dss_secured_rel_type.status,'A'),
        x_dss_group_code              => p_dss_secured_rel_type.dss_group_code,
        x_owner_table_name            => 'HZ_RELATIONSHIP_TYPES',
        x_owner_table_id1             => p_dss_secured_rel_type.relationship_type_id,
        x_object_version_number       => 1);


    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_secured_rel_type ;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_secured_rel_type ;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO create_secured_rel_type ;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
    END create_secured_rel_type ;

/**
 * PROCEDURE update_secured_rel_type
 *
 * DESCRIPTION
 * The UPDATE_SECURED_REL_TYPE procedure updates a record in HZ_DSS_CRITERIA that identifies
 * a Relationship Type to be used as a criterion to determine if data falls under the Data Sharing
 * Group.  Currently, only the STATUS column can be updated at this time.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 *
 * ARGUMENTS
 *
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   08-13-2002    Colathur Vijayan ("VJN")        o Created.
 *
 */

PROCEDURE update_secured_rel_type (
        p_init_msg_list                 IN  VARCHAR2,
        p_dss_secured_rel_type  IN  dss_secured_rel_type,
    x_object_version_number     IN OUT NOCOPY NUMBER,
        x_return_status                 OUT NOCOPY VARCHAR2,
    x_msg_count                         OUT NOCOPY NUMBER,
    x_msg_data                          OUT NOCOPY VARCHAR2
)
IS
    l_object_version_number           NUMBER;
    l_rowid                           ROWID;
    l_dss_group_code           HZ_DSS_CRITERIA.DSS_GROUP_CODE%TYPE;
    l_relationship_type_id     HZ_DSS_CRITERIA.owner_table_id1%TYPE;

BEGIN
    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- standard start of API savepoint
    SAVEPOINT update_secured_rel_type ;

    -- check whether record has been updated by another user. If not, lock it.

    BEGIN
      SELECT object_version_number, rowid , dss_group_code, owner_table_id1
      INTO   l_object_version_number, l_rowid,l_dss_group_code,
             l_relationship_type_id
      FROM   HZ_DSS_CRITERIA
      WHERE  secured_item_id = p_dss_secured_rel_type.secured_item_id
      FOR UPDATE NOWAIT;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_ITEM_ID_INVALID');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;

        IF NOT ((x_object_version_number is null and l_object_version_number is null)
                OR (x_object_version_number = l_object_version_number))
        THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
            FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_DSS_CRITERIA');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        x_object_version_number := nvl(l_object_version_number, 1) + 1;

    -- VALIDATION
    IF  ( p_dss_secured_rel_type.dss_group_code <> FND_API.G_MISS_CHAR OR
           l_dss_group_code IS NOT NULL )
       AND ( l_dss_group_code IS NULL OR
             p_dss_secured_rel_type.dss_group_code <> l_dss_group_code ) THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_DSS_CRITERIA_IMMUTABLE' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
     END IF;


   IF  ( p_dss_secured_rel_type.relationship_type_id <> FND_API.G_MISS_NUM OR
           l_relationship_type_id IS NOT NULL )
       AND ( l_relationship_type_id IS NULL OR
            p_dss_secured_rel_type.relationship_type_id <> l_relationship_type_id )
   THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_DSS_CRITERIA_IMMUTABLE' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
     END IF;


    -- STATUS VALIDATION

    IF p_dss_secured_rel_type.status is not null then
       IF HZ_DSS_VALIDATE_PKG.exist_in_ar_lookups(p_dss_secured_rel_type.status,
          'REGISTRY_STATUS')= 'N' THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_GR_STATUS_VAL_INVALID');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;


    -- Call the low level table handler
    HZ_DSS_CRITERIA_PKG.Update_Row (
    x_rowid                       => l_rowid,
    x_status                      => p_dss_secured_rel_type.status,
    x_dss_group_code              => p_dss_secured_rel_type.dss_group_code,
    x_owner_table_name            => 'HZ_RELATIONSHIP_TYPES',
    x_owner_table_id1             => p_dss_secured_rel_type.relationship_type_id,
    x_object_version_number       => x_object_version_number);


    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_secured_rel_type ;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_secured_rel_type ;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO update_secured_rel_type ;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
END update_secured_rel_type ;



/**
 * PROCEDURE create_assignment
 *
 * DESCRIPTION
 * The create_assignment procedure creates a Data Sharing Group Assignment (HZ_DSS_ASSIGNMENTS)
 * to a given entity.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 *
 * ARGUMENTS
 *
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   08-15-2002    Colathur Vijayan ("VJN")        o Created.
 *
 */

PROCEDURE create_assignment (
        p_init_msg_list                 IN  VARCHAR2,
        p_dss_assignment                IN  dss_assignment_type,
    x_assignment_id                     OUT NOCOPY NUMBER,
        x_return_status                 OUT NOCOPY VARCHAR2,
    x_msg_count                         OUT NOCOPY NUMBER,
    x_msg_data                          OUT NOCOPY VARCHAR2
)

IS
    row_id varchar2(64);
BEGIN

    -- standard start of API savepoint
    SAVEPOINT create_assignment ;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- VALIDATION
    -- PASSED IN GROUP CODE SHOULD BE VALID
    IF HZ_DSS_VALIDATE_PKG.exist_in_dss_groups_b (p_dss_assignment.dss_group_code) = 'N'
        THEN
             FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_GR_CODE_INVALID');
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- OWNER TABLE NAME VALIDATION
    IF HZ_DSS_VALIDATE_PKG.exist_in_dss_entities(p_dss_assignment.owner_table_name) = 'N'
        THEN
             FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_OWN_TABLE_NAME_INVALID');
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- STATUS VALIDATION

    IF HZ_DSS_VALIDATE_PKG.exist_in_ar_lookups(p_dss_assignment.status, 'REGISTRY_STATUS')= 'N'
        THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_GR_STATUS_VAL_INVALID');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
     END IF;



    -- Call the low level table handler
    HZ_DSS_ASSIGNMENTS_PKG.Insert_Row (
            x_rowid                                 => row_id,
            x_assignment_id                         => x_assignment_id,
            x_status                                => p_dss_assignment.status,
            x_owner_table_name                      => p_dss_assignment.owner_table_name,
            x_owner_table_id1                       => p_dss_assignment.owner_table_id1,
            x_owner_table_id2                       => p_dss_assignment.owner_table_id2,
            x_owner_table_id3                       => p_dss_assignment.owner_table_id3,
            x_owner_table_id4                       => p_dss_assignment.owner_table_id4,
            x_owner_table_id5                       => p_dss_assignment.owner_table_id5,
            x_dss_group_code                        => p_dss_assignment.dss_group_code,
            x_object_version_number                 => 1
);


    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_assignment ;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_assignment ;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO create_assignment ;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
    END create_assignment ;

/**
 * PROCEDURE delete_assignment
 *
 * DESCRIPTION
 * The delete_assignment procedure deletes a Data Sharing Group assignment (HZ_DSS_ASSIGNMENTS).
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 *
 * ARGUMENTS
 *
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   08-15-2002    Colathur Vijayan ("VJN")        o Created.
 *
 */
PROCEDURE delete_assignment (
        p_init_msg_list                 IN  VARCHAR2,
        p_assignment_id                 IN  NUMBER,
        x_return_status                 OUT NOCOPY VARCHAR2,
    x_msg_count                         OUT NOCOPY NUMBER,
    x_msg_data                          OUT NOCOPY VARCHAR2
)
IS
    row_id varchar2(64);
BEGIN

    -- standard start of API savepoint
    SAVEPOINT delete_assignment ;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- VALIDATION
    -- PASSED IN ASSIGNMENT ID SHOULD BE VALID
    IF HZ_DSS_VALIDATE_PKG.exist_in_dss_assignments(p_assignment_id) = 'N'
        THEN
             FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_ASS_ID_INVALID');
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_ERROR;
     END IF;

    -- Call the low level table handler
    HZ_DSS_ASSIGNMENTS_PKG.Delete_Row (
                x_assignment_id  => p_assignment_id
    );


    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO delete_assignment ;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO delete_assignment ;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO delete_assignment ;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
    END delete_assignment ;

/**
 * PROCEDURE create_secured_entity
 *
 * DESCRIPTION
 * The create_secured_entity procedure creates a Secured Entity entry (HZ_DSS_SECURED_ENTITIES)
 * for a Data Sharing Group.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 *
 * ARGUMENTS
 *
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   08-15-2002    Colathur Vijayan ("VJN")        o Created.
 *
 */

PROCEDURE create_secured_entity (
        p_init_msg_list                 IN  VARCHAR2,
        p_dss_secured_entity    IN  dss_secured_entity_type,
    x_dss_instance_set_id       OUT NOCOPY NUMBER,
        x_return_status                 OUT NOCOPY VARCHAR2,
    x_msg_count                         OUT NOCOPY NUMBER,
    x_msg_data                          OUT NOCOPY VARCHAR2
)

IS
    row_id varchar2(64);
    l_predicate varchar2(2000);
    l_object_id number ;
    l_dss_instance_set_id number ;
    l_instance_set_id number ;

    l_dss_ois_name varchar2(30);
    l_dup_ois_cnt number;
BEGIN

    -- standard start of API savepoint
    SAVEPOINT create_secured_entity ;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --validation of mandatory fields
     IF (p_dss_secured_entity.dss_group_code is null OR
         p_dss_secured_entity.dss_group_code = FND_API.G_MISS_CHAR) THEN
       FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
       FND_MESSAGE.SET_TOKEN( 'COLUMN', 'dss_group_code' );
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF (p_dss_secured_entity.entity_id is null OR
         p_dss_secured_entity.entity_id = FND_API.G_MISS_NUM) THEN
       FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
       FND_MESSAGE.SET_TOKEN( 'COLUMN', 'entity_id' );
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
     END IF;


    -- VALIDATION
    -- PASSED IN GROUP CODE SHOULD BE VALID
    IF HZ_DSS_VALIDATE_PKG.exist_in_dss_groups_b (p_dss_secured_entity.dss_group_code) = 'N'
        THEN
             FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_GR_CODE_INVALID');
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- ENTITY ID VALIDATION
    IF HZ_DSS_VALIDATE_PKG.exist_in_dss_entities(p_dss_secured_entity.entity_id ) = 'N'
        THEN
             FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_ENT_ID_INVALID');
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- STATUS VALIDATION
    IF p_dss_secured_entity.status is not null then
       IF HZ_DSS_VALIDATE_PKG.exist_in_ar_lookups(p_dss_secured_entity.status,
          'REGISTRY_STATUS')= 'N' THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_GR_STATUS_VAL_INVALID');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;



    -- LOGIC FOR GENERATING OBJECT INSTANCE SETS CORRESPONDING TO THE SECURED ENTITY
    -- GOES HERE

    -- GET THE PREDICATE FIRST


    HZ_DSS_UTIL_PUB.generate_predicate (
        p_dss_group_code        => p_dss_secured_entity.dss_group_code,
        p_entity_id             => p_dss_secured_entity.entity_id,
        x_predicate             => l_predicate,
        x_return_status         => x_return_status,
        x_msg_count             => x_msg_count,
        x_msg_data              => x_msg_data
    );


    IF x_return_status NOT IN ( FND_API.G_RET_STS_SUCCESS, FND_API.G_TRUE) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- GET A SEQUENCE GENERATED DSS_INSTANCE_SET_ID TO BE INSERTED INTO FND_GRANTS
    select fnd_object_instance_sets_s.nextval
    into l_dss_instance_set_id
    from sys.dual;

    -- GET OBJECT ID TO BE INSERTED INTO FND_OBJECT_INSTANCE_SETS

    -- If there is an object id (non null) corresponding to the given entity id
    -- in HZ_DSS_ENTITIIES, grab it

    IF HZ_DSS_VALIDATE_PKG.is_an_obj_id_in_dss_entities(p_dss_secured_entity.entity_id) = 'Y'
        THEN
            l_object_id := HZ_DSS_VALIDATE_PKG.get_object_id_entities
                                        (p_dss_secured_entity.entity_id);
    -- Else get the object instance set id that corresponds to the entity id, go to fnd grants and get the
    -- object id
    ELSE
            l_instance_set_id := HZ_DSS_VALIDATE_PKG.get_instance_set_id_entities
                                        (p_dss_secured_entity.entity_id);
            l_object_id := HZ_DSS_VALIDATE_PKG.get_object_id_fnd_ins_sets
                                        (l_instance_set_id);
    END IF;


    -- CALL FND_OBJECT_INSTANCE_SETS_PKG INSERT ROW HANDLER TO INSERT
    -- ALL THE INFORMATION COLLECTED BEFORE

    -- Construct an Object Instance Set Name

    l_dss_ois_name := 'HZ_DSS_' || substrb(p_dss_secured_entity.dss_group_code,1,18) ||
          '_';
    select count(*) into l_dup_ois_cnt from fnd_object_instance_sets
      where instance_set_name like l_dss_ois_name || '%';
    l_dss_ois_name := l_dss_ois_name || to_char(l_dup_ois_cnt + 1);


    FND_OBJECT_INSTANCE_SETS_PKG.INSERT_ROW (
                    x_rowid => row_id,
                    x_instance_set_id => l_dss_instance_set_id,
                    x_instance_set_name => l_dss_ois_name,
                    x_object_id => l_object_id,
                    x_predicate => l_predicate,
                    x_display_name => l_dss_ois_name,
                    x_description => l_dss_ois_name,
                    x_creation_date => hz_utility_v2pub.creation_date ,
                    x_created_by => hz_utility_v2pub.created_by ,
                    x_last_update_date => hz_utility_v2pub.last_update_date,
                    x_last_updated_by => hz_utility_v2pub.last_updated_by ,
                    x_last_update_login => hz_utility_v2pub.last_update_login );

    -- Bug#3710516 - update grants when the status of a secured entity has been
    -- changed.
    --
    -- Create grants in case there are already grants created for the
    -- group.

    hz_dss_grants_pub.create_grant (
      p_dss_group_code          => p_dss_secured_entity.dss_group_code,
      p_dss_instance_set_id     => l_dss_instance_set_id,
      p_secured_entity_status   => NVL(p_dss_secured_entity.status,'A'),
      x_return_status           => x_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Call the low level table handler
    HZ_DSS_SECURED_ENTITIES_PKG.Insert_Row (
        x_rowid                  => row_id ,
        x_dss_group_code         => p_dss_secured_entity.dss_group_code,
        x_entity_id              => p_dss_secured_entity.entity_id,
        x_status                 => nvl(p_dss_secured_entity.status,'A'),
        x_dss_instance_set_id    => l_dss_instance_set_id,
        x_object_version_number  => 1
    );

    --Bug#2620405 Instance set ID is not getting returned
    x_dss_instance_set_id := l_dss_instance_set_id;

    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_secured_entity ;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_secured_entity ;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO create_secured_entity ;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
    END create_secured_entity ;


/**
 * PROCEDURE update_secured_entity
 *
 * DESCRIPTION
 * The update_secured_entity procedure updates a Secured Entity record.
 * Currently, the only data updateable is the STATUS column.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 *
 * ARGUMENTS
 *
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   08-13-2002    Colathur Vijayan ("VJN")        o Created.
 *
 */
PROCEDURE update_secured_entity (
    p_init_msg_list               IN     VARCHAR2,
    p_dss_secured_entity          IN     dss_secured_entity_type,
    x_object_version_number       IN OUT NOCOPY NUMBER,
    x_return_status               OUT    NOCOPY VARCHAR2,
    x_msg_count                   OUT    NOCOPY NUMBER,
    x_msg_data                    OUT    NOCOPY VARCHAR2
) IS

    l_object_version_number       NUMBER;
    l_rowid                       ROWID;
    l_dss_instance_set_id         NUMBER;
    l_status                      VARCHAR2(1);

BEGIN

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- standard start of API savepoint
    SAVEPOINT update_secured_entity ;

    -- check whether record has been updated by another user. If not, lock it.
    BEGIN
      SELECT object_version_number, dss_instance_set_id, rowid, status
      INTO   l_object_version_number, l_dss_instance_set_id , l_rowid, l_status
      FROM   hz_dss_secured_entities
      WHERE  dss_group_code = p_dss_secured_entity.dss_group_code
      AND    entity_id =  p_dss_secured_entity.entity_id
      FOR UPDATE NOWAIT;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_SEC_ENT_NOT_FOUND');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;

    IF NOT ((x_object_version_number IS NULL AND
             l_object_version_number IS NULL) OR
            (x_object_version_number = l_object_version_number))
    THEN
      FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
      FND_MESSAGE.SET_TOKEN('TABLE', 'HZ_DSS_SECURED_ENTITIES');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_object_version_number := nvl(l_object_version_number, 1) + 1;

    -- VALIDATION

    -- STATUS VALIDATION

    IF p_dss_secured_entity.status IS NOT NULL THEN
      IF HZ_DSS_VALIDATE_PKG.exist_in_ar_lookups (
           p_dss_secured_entity.status,
           'REGISTRY_STATUS')= 'N'
      THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_GR_STATUS_VAL_INVALID');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    -- Bug#3710516 - update grants when the status of a secured entity has been
    -- changed.
    --
    -- reset grant end date if status has been switched from I to A.
    -- end-dated fnd grants if status has been switched from A to I.
    --
    -- status is null means no change
    -- status = G_MISS case has been caught by the lookup validation
    --
    IF p_dss_secured_entity.status IS NOT NULL AND
       ((p_dss_secured_entity.status = 'A' AND l_status = 'D') OR
        (p_dss_secured_entity.status = 'D' AND l_status = 'A'))
    THEN

      hz_dss_grants_pub.update_grant (
        p_dss_group_code          => p_dss_secured_entity.dss_group_code,
        p_dss_instance_set_id     => l_dss_instance_set_id,
        p_secured_entity_status   => p_dss_secured_entity.status,
        x_return_status           => x_return_status,
        x_msg_count               => x_msg_count,
        x_msg_data                => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    END IF;

    -- Call the low level table handler
    HZ_DSS_SECURED_ENTITIES_PKG.Update_Row (
      x_rowid                     => l_rowid,
      x_status                    => p_dss_secured_entity.status,
      x_dss_instance_set_id       => l_dss_instance_set_id ,
      x_object_version_number     => x_object_version_number
    ) ;

    -- standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_secured_entity ;
        x_return_status := FND_API.G_RET_STS_ERROR;

        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_secured_entity ;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO update_secured_entity ;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MESSAGE.SET_NAME('AR', 'HZ_DSS_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
END update_secured_entity ;

END HZ_DSS_GROUPS_PUB ;

/
