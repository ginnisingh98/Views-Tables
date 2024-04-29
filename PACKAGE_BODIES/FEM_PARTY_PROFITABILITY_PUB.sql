--------------------------------------------------------
--  DDL for Package Body FEM_PARTY_PROFITABILITY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_PARTY_PROFITABILITY_PUB" AS
/* $Header: femprfSB.pls 120.0 2005/06/06 20:46:56 appldev noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'FEM_PARTY_PROFITABILITY_PUB';

procedure do_create_profitability(
        p_profitability_rec             IN PROFITABILITY_REC_TYPE,
        x_party_id                      OUT NOCOPY     NUMBER,
        x_return_status                 IN OUT NOCOPY  VARCHAR2
);


procedure do_update_profitability(
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2:= FND_API.G_FALSE,
        p_commit                        IN      VARCHAR2:= FND_API.G_TRUE,
        p_profitability_rec             IN PROFITABILITY_REC_TYPE,
        p_last_update_date              IN OUT NOCOPY  DATE,
        x_return_status                 IN OUT NOCOPY  VARCHAR2,
        p_validation_level              IN      NUMBER:= FND_API.G_VALID_LEVEL_FULL
);

procedure validate_profitability(
        p_profitability_rec             IN      FEM_PARTY_profitability_pub.profitability_rec_type,
        create_update_flag              IN      VARCHAR2,
        x_return_status                 IN OUT NOCOPY  VARCHAR2
);

procedure get_current_profitability(
        p_party_id                      IN      NUMBER,
        x_profitability_rec             OUT NOCOPY     FEM_PARTY_profitability_pub.profitability_rec_type
);





/*===========================================================================+
 | PROCEDURE
 |              create_profitability.
 |
 | DESCRIPTION
 |              Creates profitability.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_api_version
 |                    p_init_msg_list
 |                    p_commit
 |                    p_profitability_rec
 |                    p_validation_level
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |                    x_party_id
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Steven Wasserman   27-DEC-00  Created
 |
 +===========================================================================*/


procedure create_profitability (
        p_api_version           IN      NUMBER :=1.0,
        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
        p_commit                IN      VARCHAR2:= FND_API.G_TRUE,
        p_validation_level      IN      NUMBER:= FND_API.G_VALID_LEVEL_FULL,
        p_profitability_rec     IN      PROFITABILITY_REC_TYPE,
        x_return_status         OUT NOCOPY     VARCHAR2,
        x_msg_count             OUT NOCOPY     NUMBER,
        x_msg_data              OUT NOCOPY     VARCHAR2,
        x_party_id              OUT NOCOPY     NUMBER
) IS
        l_api_name              CONSTANT VARCHAR2(30) := 'create_profitability';
        l_api_version           CONSTANT  NUMBER       := 1.0;


BEGIN
--Standard start of API savepoint
        SAVEPOINT create_profitability_pub;

--Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call(
                                        l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

--Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean(p_init_msg_list) THEN
                FND_MSG_PUB.initialize;
        END IF;

--Initialize API return status to success.
        x_return_status := FND_API.G_RET_STS_SUCCESS;

--Call to User-Hook pre Processing Procedure

/*      IF (fnd_profile.value('HZ_EXECUTE_API_CALLOUTS') = 'Y') THEN
        hz_profitability_crmhk.create_profitability_pre(
                        l_profitability_rec,
                        x_return_status,
                        x_msg_count,
                        x_msg_data);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_HOOK_ERROR');
                FND_MESSAGE.SET_TOKEN('PROCEDURE',
                                'HZ_PROFITABILITY_CRMHK.CREATE_PROFITABILITY_PRE');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

       END IF;
*/
--Call to business logic.
        do_create_profitability(
                        p_profitability_rec,
                        x_party_id,
                        x_return_status);

--Call to User-Hook post Processing Procedure
/*

      IF fnd_profile.value('HZ_EXECUTE_API_CALLOUTS') = 'Y' THEN
        hz_profitability_crmhk.create_profitability_post(
                        l_profitability_rec,
                        x_return_status,
                        x_msg_count,
                        x_msg_data);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_HOOK_ERROR');
                FND_MESSAGE.SET_TOKEN('PROCEDURE',
                                'HZ_PROFITABILITY_CRMHK.CREATE_PROFITABILITY_POST');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

       END IF;
*/

--Standard check of p_commit.
        IF FND_API.to_Boolean(p_commit) THEN
                commit;
        END IF;

--Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO create_location_pub;
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO create_profitability_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        WHEN OTHERS THEN
                ROLLBACK TO create_profitability_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;

                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

END create_profitability;

/*===========================================================================+
 | PROCEDURE
 |              update_profitability
 |
 | DESCRIPTION
 |              Updates profitability.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_api_version
 |                    p_init_msg_list
 |                    p_commit
 |                    p_profitability_rec
 |                    p_validation_level
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |          IN/ OUT:
 |                    p_last_update_date
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Steven Wasserman   27-DEC-00  Created
 |
 +===========================================================================*/

procedure update_profitability (
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2:=FND_API.G_FALSE,
        p_commit                IN      VARCHAR2:=FND_API.G_TRUE,
        p_validation_level      IN      NUMBER:= FND_API.G_VALID_LEVEL_FULL,
        p_profitability_rec     IN      PROFITABILITY_REC_TYPE,
        p_last_update_date      IN OUT NOCOPY  DATE,
        x_return_status         OUT NOCOPY     VARCHAR2,
        x_msg_count             OUT NOCOPY     NUMBER,
        x_msg_data              OUT NOCOPY     VARCHAR2
) IS
        l_api_name              CONSTANT VARCHAR2(30) := 'update_profitability';
        l_api_version           CONSTANT  NUMBER       := 1.0;


BEGIN
--Standard start of API savepoint
        SAVEPOINT update_profitability_pub;

--Standard call to check for call compatibility.
        IF NOT FND_API.Compatible_API_Call(
                                        l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
        THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

--Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean(p_init_msg_list) THEN
                FND_MSG_PUB.initialize;
        END IF;

--Initialize API return status to success.
        x_return_status := FND_API.G_RET_STS_SUCCESS;

--------------------------------------------------------------
--  Since we aren't doing any pre processing at this time,
--  there is no need to get the current record or perform
--  any of the other pre-processing steps
--------------------------------------------------------------
/*
--Get the old record.
        get_current_profitability(
                l_profitability_rec.party_id,
                l_old_profitability_rec);


--Call to User-Hook Pre Processing Procedure

      IF (fnd_profile.value('HZ_EXECUTE_API_CALLOUTS') = 'Y') THEN
        hz_profitability_crmhk.update_profitability_pre(l_profitability_rec,
                                              l_old_profitability_rec,
                                              x_return_status,
                                              x_msg_count,
                                              x_msg_data);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_HOOK_ERROR');
                FND_MESSAGE.SET_TOKEN('PROCEDURE',
                                'HZ_PROFITABILITY_CRMHK.UPDATE_PROFITABILITY_PRE');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

       END IF;
*/
-----------------------------------------------------------------
--  End of the pre-processing steps
-----------------------------------------------------------------
--Call to business logic.

        do_update_profitability(
                        p_api_version,
	                p_init_msg_list,
                        p_commit,
                        p_profitability_rec,
                        p_last_update_date,
                        x_return_status,
                        p_validation_level);

/*

--------------------------------------------------------------
--  Since we aren't doing any Post processing at this time,
--  there is no need to get the current record or perform
--  any of the other post-processing steps
--------------------------------------------------------------
--Call to User-Hook Pre Processing Procedure
      IF fnd_profile.value('HZ_EXECUTE_API_CALLOUTS') = 'Y' THEN
        hz_location_crmhk.update_profitability_post(l_profitability_rec,
                                              x_return_status,
                                              x_msg_count,
                                              x_msg_data);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                FND_MESSAGE.SET_NAME('AR', 'HZ_API_HOOK_ERROR');
                FND_MESSAGE.SET_TOKEN('PROCEDURE',
                                'HZ_PROFITABILITY_CRMHK.UPDATE_PROFITABILITY_POST');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

       END IF;

-----------------------------------------------------------------
--  End of the post-processing steps
-----------------------------------------------------------------
*/

--Standard check of p_commit.

        IF FND_API.to_Boolean(p_commit) THEN
                commit;
        END IF;

--Standard call to get message count and if count is 1, get message info.
        FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO update_profitability_pub;
                x_return_status := FND_API.G_RET_STS_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                ROLLBACK TO update_profitability_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

        WHEN OTHERS THEN
                ROLLBACK TO update_profitability_pub;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

                FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
                FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
                FND_MSG_PUB.ADD;

                FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

END update_profitability;

/*===========================================================================+
 | PROCEDURE
 |              get_current_profitability
 |
 | DESCRIPTION
 |              Gets current record.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_party_id
 |              OUT:
 |                    x_profitability_rec
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Steven Wasserman   28-DEC-00  Created
 |
 +===========================================================================*/

procedure get_current_profitability(
        p_party_id                      IN      NUMBER,
        x_profitability_rec             OUT NOCOPY     FEM_PARTY_profitability_pub.profitability_rec_type
) IS
                LAST_UPDATE_DATE        DATE;
                LAST_UPDATED_BY         NUMBER;
                CREATION_DATE           DATE;
                CREATED_BY              NUMBER;
                LAST_UPDATE_LOGIN       NUMBER;

BEGIN
null;
/*
    SELECT
        PARTY_ID,
        PROFIT,
        PROFIT_PCT,
        RELATIONSHIP_EXPENSE,
        TOTAL_EQUITY,
        TOTAL_GROSS_CONTRIB,
        TOTAL_ROE,
        TOTAL_TRANSACTIONS,
        CONTRIB_AFTER_CPTL_CHG,
        PARTNER_VALUE_INDEX,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN
      INTO
        x_profitability_rec.PARTY_ID,
        x_profitability_rec.PROFIT,
        x_profitability_rec.PROFIT_PCT,
        x_profitability_rec.RELATIONSHIP_EXPENSE,
        x_profitability_rec.TOTAL_EQUITY,
        x_profitability_rec.TOTAL_GROSS_CONTRIB,
        x_profitability_rec.TOTAL_ROE,
        x_profitability_rec.TOTAL_TRANSACTIONS,
        x_profitability_rec.CONTRIB_AFTER_CPTL_CHG,
        x_profitability_rec.PARTNER_VALUE_INDEX,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN
       FROM FEM_PARTY_profitability
       WHERE party_id = p_party_id;
*/
END get_current_profitability;

/*===========================================================================+
 | PROCEDURE
 |              do_create_profitability
 |
 | DESCRIPTION
 |              Creates profitability.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_party_id
 |          IN/ OUT:
 |                    p_profitability_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Kielley Fon-Ndikum 15-FEB-01  Add new columns and drop 2.
 |    Steven Wasserman   27-DEC-00  Created
 |                                                                           |
 +===========================================================================*/

procedure do_create_profitability(
        p_profitability_rec             IN PROFITABILITY_REC_TYPE,
        x_party_id                      OUT NOCOPY     NUMBER,
        x_return_status                 IN OUT NOCOPY  VARCHAR2
) IS
        l_party_id      NUMBER := p_profitability_rec.party_id;
        l_rowid         ROWID := NULL;
BEGIN

        validate_profitability(p_profitability_rec, 'C', x_return_status);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
        END IF;

--Call table-handler.

        FEM_PARTY_PROFITABILITY_PKG.INSERT_ROW(
        x_Rowid => l_Rowid,
        x_PARTY_ID => p_profitability_rec.PARTY_ID,
        X_LAST_UPDATE_DATE => p_profitability_rec.LAST_UPDATE_DATE,
	X_LAST_UPDATED_BY => p_profitability_rec.LAST_UPDATED_BY,
	X_CREATION_DATE => p_profitability_rec.CREATION_DATE,
	X_CREATED_BY => p_profitability_rec.CREATED_BY,
        X_LAST_UPDATE_LOGIN => p_profitability_rec.LAST_UPDATE_LOGIN,
        x_PROFIT => p_profitability_rec.PROFIT,
        x_PROFIT_PCT => p_profitability_rec.PROFIT_PCT,
        x_RELATIONSHIP_EXPENSE => p_profitability_rec.RELATIONSHIP_EXPENSE,
        x_TOTAL_EQUITY => p_profitability_rec.TOTAL_EQUITY,
        x_TOTAL_GROSS_CONTRIB => p_profitability_rec.TOTAL_GROSS_CONTRIB,
        x_TOTAL_ROE => p_profitability_rec.TOTAL_ROE,
        x_CONTRIB_AFTER_CPTL_CHG => p_profitability_rec.CONTRIB_AFTER_CPTL_CHG,
        x_PARTNER_VALUE_INDEX => p_profitability_rec.PARTNER_VALUE_INDEX,
        x_ISO_CURRENCY_CD => p_profitability_rec.ISO_CURRENCY_CD,
        x_REVENUE1 => p_profitability_rec.REVENUE1,
        x_REVENUE2 => p_profitability_rec.REVENUE2,
        x_REVENUE3 => p_profitability_rec.REVENUE3,
        x_REVENUE4 => p_profitability_rec.REVENUE4,
        x_REVENUE5 => p_profitability_rec.REVENUE5,
        x_REVENUE_TOTAL => p_profitability_rec.REVENUE_TOTAL,
        x_EXPENSE1 => p_profitability_rec.EXPENSE1,
        x_EXPENSE2 => p_profitability_rec.EXPENSE2,
        x_EXPENSE3 => p_profitability_rec.EXPENSE3,
        x_EXPENSE4 => p_profitability_rec.EXPENSE4,
        x_EXPENSE5 => p_profitability_rec.EXPENSE5,
        x_EXPENSE_TOTAL => p_profitability_rec.EXPENSE_TOTAL,
        x_PROFIT1 => p_profitability_rec.PROFIT1,
        x_PROFIT2 => p_profitability_rec.PROFIT2,
        x_PROFIT3 => p_profitability_rec.PROFIT3,
        x_PROFIT4 => p_profitability_rec.PROFIT4,
        x_PROFIT5 => p_profitability_rec.PROFIT5,
        x_PROFIT_TOTAL => p_profitability_rec.PROFIT_TOTAL,
        x_CACC1 => p_profitability_rec.CACC1,
        x_CACC2 => p_profitability_rec.CACC2,
        x_CACC3 => p_profitability_rec.CACC3,
        x_CACC4 => p_profitability_rec.CACC4,
        x_CACC5 => p_profitability_rec.CACC5,
        x_CACC_TOTAL => p_profitability_rec.CACC_TOTAL,
        x_BALANCE1 => p_profitability_rec.BALANCE1,
        x_BALANCE2 => p_profitability_rec.BALANCE2,
        x_BALANCE3 => p_profitability_rec.BALANCE3,
        x_BALANCE4 => p_profitability_rec.BALANCE4,
        x_BALANCE5 => p_profitability_rec.BALANCE5,
        x_ACCOUNTS1 => p_profitability_rec.ACCOUNTS1,
        x_ACCOUNTS2 => p_profitability_rec.ACCOUNTS2,
        x_ACCOUNTS3 => p_profitability_rec.ACCOUNTS3,
        x_ACCOUNTS4 => p_profitability_rec.ACCOUNTS4,
        x_ACCOUNTS5 => p_profitability_rec.ACCOUNTS5,
        x_TRANSACTION1 => p_profitability_rec.TRANSACTION1,
        x_TRANSACTION2 => p_profitability_rec.TRANSACTION2,
        x_TRANSACTION3 => p_profitability_rec.TRANSACTION3,
        x_TRANSACTION4 => p_profitability_rec.TRANSACTION4,
        x_TRANSACTION5 => p_profitability_rec.TRANSACTION5,
        x_RATIO1 => p_profitability_rec.RATIO1,
        x_RATIO2 => p_profitability_rec.RATIO2,
        x_RATIO3 => p_profitability_rec.RATIO3,
        x_RATIO4 => p_profitability_rec.RATIO4,
        x_RATIO5 => p_profitability_rec.RATIO5,
        x_VALUE1 => p_profitability_rec.VALUE1,
        x_VALUE2 => p_profitability_rec.VALUE2,
        x_VALUE3 => p_profitability_rec.VALUE3,
        x_VALUE4 => p_profitability_rec.VALUE4,
        x_VALUE5 => p_profitability_rec.VALUE5,
        x_YTD1 => p_profitability_rec.YTD1,
        x_YTD2 => p_profitability_rec.YTD2,
        x_YTD3 => p_profitability_rec.YTD3,
        x_YTD4 => p_profitability_rec.YTD4,
        x_YTD5 => p_profitability_rec.YTD5,
        x_LTD1 => p_profitability_rec.LTD1,
        x_LTD2 => p_profitability_rec.LTD2,
        x_LTD3 => p_profitability_rec.LTD3,
        x_LTD4 => p_profitability_rec.LTD4,
        x_LTD5 => p_profitability_rec.LTD5
        );

END do_create_profitability;

/*===========================================================================+
 | PROCEDURE
 |              do_update_profitability
 |
 | DESCRIPTION
 |              Updates profitability.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |          IN/ OUT:
 |                    p_profitability_rec
 |                    p_last_update_date
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Kielley Fon-Ndikum 15-FEB-01  Add new columns and drop 2.
 |    Steven Wasserman   27-DEC-00  Created
 |
 +===========================================================================*/

procedure do_update_profitability(
        p_api_version           IN      NUMBER,
        p_init_msg_list         IN      VARCHAR2:= FND_API.G_FALSE,
        p_commit                IN      VARCHAR2:= FND_API.G_TRUE,
        p_profitability_rec    IN PROFITABILITY_REC_TYPE,
        p_last_update_date     IN OUT NOCOPY  DATE,
        x_return_status        IN OUT NOCOPY  VARCHAR2,
        p_validation_level     NUMBER:= FND_API.G_VALID_LEVEL_FULL
) IS
        exist_last_update_date DATE;      -- last_update_date of existing
                                          -- record in FEM_PARTY_PROFITABILITY for
                                          -- same party_id
        l_rowid                ROWID;
        l_key                  VARCHAR2(2000);
        l_party_id             NUMBER;
        insert_flag            NUMBER:=0;  -- identifies that we have upserted
                                           -- and don't need to perform any update
        update_flag            NUMBER:=0;  -- identifies that we need to update
                                           -- because the last_update_date in apps
                                           -- is less than the source record from FDM


 ----------------------------------------------------------
 -- Return variables for calling create_profitability
 -- if record to update does not exist
 ----------------------------------------------------------
        x_msg_count                 NUMBER;
        x_msg_data                  VARCHAR2(2000);
        x_party_id                  NUMBER;
 -----------------------------------------------------------

BEGIN


--Check whether primary key has been passed in.
  IF p_profitability_rec.party_id IS NULL OR
        p_profitability_rec.party_id = FND_API.G_MISS_NUM THEN

        FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
        FND_MESSAGE.SET_TOKEN('COLUMN', 'party id');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
  END IF;

-------------------------------------------------------------
-- Don't need the check last_update_date logic because null
-- last_update_date means that we will insert since existing
-- record does not exist
--------------------------------------------------------------
/*--Check whether last_update_date has been passed in.
  IF p_last_update_date IS NULL OR
        p_last_update_date = FND_API.G_MISS_DATE THEN

        FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
        FND_MESSAGE.SET_TOKEN('COLUMN', 'profitability last update date');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
  END IF; */
---------------------------------------------------------------


--Check whether record exists matching primary key
--If not, then call create_profitability to insert
  IF p_last_update_date IS NULL THEN

     create_profitability(p_api_version,p_init_msg_list,p_commit,p_validation_level,
                          p_profitability_rec,
                          x_return_status,x_msg_count,x_msg_data,x_party_id);
     insert_flag := 1;
  END IF;

--------------------------------------------------------------
--  This section of code only performed if we are truly
--  updating a record.  If we have "upserted", then we can
--  skip this entire section
--------------------------------------------------------------

IF insert_flag <> 1 THEN
--Check whether last_update_date of record is < last_update_date from
--the FDM database
  BEGIN

     IF p_last_update_date < p_profitability_rec.last_update_date THEN

----------------------------------------------------------------------
  /*
        SELECT last_update_date INTO l_last_update_date
        FROM FEM_PARTY_profitability
        WHERE party_id = p_profitability_rec.party_id
        AND to_char(p_last_update_date, 'DD-MON-YYYY HH:MI:SS') =
                to_char(last_update_date, 'DD-MON-YYYY HH:MI:SS')
        FOR UPDATE OF party_id NOWAIT;

        EXCEPTION WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
        FND_MESSAGE.SET_TOKEN('TABLE', 'FEM_PARTY_PROFITABILITY');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR; */
-----------------------------------------------------------------------

        --Call for validations.
        validate_profitability(p_profitability_rec, 'U', x_return_status);

        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
        END IF;

        --Set value for geometry and rowid
        SELECT rowid INTO l_rowid
        FROM FEM_PARTY_profitability
        WHERE party_id = p_profitability_rec.party_id;

----------------------------------------------------------------------
/*
        --Pass back last_update_date.
        p_last_update_date := hz_utility_pub.LAST_UPDATE_DATE;  */
----------------------------------------------------------------------

        --Call to table-handler.

        FEM_PARTY_PROFITABILITY_PKG.UPDATE_ROW(
        x_Rowid => l_Rowid,
        x_PARTY_ID => p_profitability_rec.PARTY_ID,
      	X_LAST_UPDATE_DATE => p_profitability_rec.last_update_date,
	X_LAST_UPDATED_BY => p_profitability_rec.LAST_UPDATED_BY,
	X_CREATION_DATE => p_profitability_rec.CREATION_DATE,
	X_CREATED_BY => p_profitability_rec.CREATED_BY,
        X_LAST_UPDATE_LOGIN => p_profitability_rec.LAST_UPDATE_LOGIN,
        x_PROFIT => p_profitability_rec.PROFIT,
        x_PROFIT_PCT => p_profitability_rec.PROFIT_PCT,
        x_RELATIONSHIP_EXPENSE => p_profitability_rec.RELATIONSHIP_EXPENSE,
        x_TOTAL_EQUITY => p_profitability_rec.TOTAL_EQUITY,
        x_TOTAL_GROSS_CONTRIB => p_profitability_rec.TOTAL_GROSS_CONTRIB,
        x_TOTAL_ROE => p_profitability_rec.TOTAL_ROE,
        x_CONTRIB_AFTER_CPTL_CHG => p_profitability_rec.CONTRIB_AFTER_CPTL_CHG,
        x_PARTNER_VALUE_INDEX => p_profitability_rec.PARTNER_VALUE_INDEX,
        x_ISO_CURRENCY_CD => p_profitability_rec.ISO_CURRENCY_CD,
        x_REVENUE1 => p_profitability_rec.REVENUE1,
        x_REVENUE2 => p_profitability_rec.REVENUE2,
        x_REVENUE3 => p_profitability_rec.REVENUE3,
        x_REVENUE4 => p_profitability_rec.REVENUE4,
        x_REVENUE5 => p_profitability_rec.REVENUE5,
        x_REVENUE_TOTAL => p_profitability_rec.REVENUE_TOTAL,
        x_EXPENSE1 => p_profitability_rec.EXPENSE1,
        x_EXPENSE2 => p_profitability_rec.EXPENSE2,
        x_EXPENSE3 => p_profitability_rec.EXPENSE3,
        x_EXPENSE4 => p_profitability_rec.EXPENSE4,
        x_EXPENSE5 => p_profitability_rec.EXPENSE5,
        x_EXPENSE_TOTAL => p_profitability_rec.EXPENSE_TOTAL,
        x_PROFIT1 => p_profitability_rec.PROFIT1,
        x_PROFIT2 => p_profitability_rec.PROFIT2,
        x_PROFIT3 => p_profitability_rec.PROFIT3,
        x_PROFIT4 => p_profitability_rec.PROFIT4,
        x_PROFIT5 => p_profitability_rec.PROFIT5,
        x_PROFIT_TOTAL => p_profitability_rec.PROFIT_TOTAL,
        x_CACC1 => p_profitability_rec.CACC1,
        x_CACC2 => p_profitability_rec.CACC2,
        x_CACC3 => p_profitability_rec.CACC3,
        x_CACC4 => p_profitability_rec.CACC4,
        x_CACC5 => p_profitability_rec.CACC5,
        x_CACC_TOTAL => p_profitability_rec.CACC_TOTAL,
        x_BALANCE1 => p_profitability_rec.BALANCE1,
        x_BALANCE2 => p_profitability_rec.BALANCE2,
        x_BALANCE3 => p_profitability_rec.BALANCE3,
        x_BALANCE4 => p_profitability_rec.BALANCE4,
        x_BALANCE5 => p_profitability_rec.BALANCE5,
        x_ACCOUNTS1 => p_profitability_rec.ACCOUNTS1,
        x_ACCOUNTS2 => p_profitability_rec.ACCOUNTS2,
        x_ACCOUNTS3 => p_profitability_rec.ACCOUNTS3,
        x_ACCOUNTS4 => p_profitability_rec.ACCOUNTS4,
        x_ACCOUNTS5 => p_profitability_rec.ACCOUNTS5,
        x_TRANSACTION1 => p_profitability_rec.TRANSACTION1,
        x_TRANSACTION2 => p_profitability_rec.TRANSACTION2,
        x_TRANSACTION3 => p_profitability_rec.TRANSACTION3,
        x_TRANSACTION4 => p_profitability_rec.TRANSACTION4,
        x_TRANSACTION5 => p_profitability_rec.TRANSACTION5,
        x_RATIO1 => p_profitability_rec.RATIO1,
        x_RATIO2 => p_profitability_rec.RATIO2,
        x_RATIO3 => p_profitability_rec.RATIO3,
        x_RATIO4 => p_profitability_rec.RATIO4,
        x_RATIO5 => p_profitability_rec.RATIO5,
        x_VALUE1 => p_profitability_rec.VALUE1,
        x_VALUE2 => p_profitability_rec.VALUE2,
        x_VALUE3 => p_profitability_rec.VALUE3,
        x_VALUE4 => p_profitability_rec.VALUE4,
        x_VALUE5 => p_profitability_rec.VALUE5,
        x_YTD1 => p_profitability_rec.YTD1,
        x_YTD2 => p_profitability_rec.YTD2,
        x_YTD3 => p_profitability_rec.YTD3,
        x_YTD4 => p_profitability_rec.YTD4,
        x_YTD5 => p_profitability_rec.YTD5,
        x_LTD1 => p_profitability_rec.LTD1,
        x_LTD2 => p_profitability_rec.LTD2,
        x_LTD3 => p_profitability_rec.LTD3,
        x_LTD4 => p_profitability_rec.LTD4,
        x_LTD5 => p_profitability_rec.LTD5
        );

        END IF;
     END;
  END IF;  -- Insert flag

END do_update_profitability;

/*===========================================================================+
 | PROCEDURE
 |              validate_profitability
 |
 | DESCRIPTION
 |              Validates profitability. Checks for:
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                      p_profitability_rec
 |                      create_update_flag
 |              OUT:
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |    Rob Flippo         08-JAN-00  Modified validate_profitability to use
 |                                  G_MISS_NUM in party_id comparison
 |    Steven Wasserman   27-DEC-00  Created
 |
 |
 +===========================================================================*/

procedure validate_profitability(
        p_profitability_rec     IN      FEM_PARTY_profitability_pub.profitability_rec_type,
        create_update_flag      IN      VARCHAR2,
        x_return_status         IN OUT NOCOPY  VARCHAR2
) IS

BEGIN

--Check for mandatory, but updateable columns
  IF (create_update_flag = 'C' AND (p_profitability_rec.party_id = FND_API.G_MISS_NUM OR
  p_profitability_rec.party_id IS NULL)) OR (create_update_flag = 'U' AND
  p_profitability_rec.party_id IS NULL) THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_MISSING_COLUMN');
        FND_MESSAGE.SET_TOKEN('COLUMN', 'party_id');
        FND_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

END validate_profitability;



END FEM_PARTY_PROFITABILITY_PUB;

/
