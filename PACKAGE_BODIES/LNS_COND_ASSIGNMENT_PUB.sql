--------------------------------------------------------
--  DDL for Package Body LNS_COND_ASSIGNMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_COND_ASSIGNMENT_PUB" AS
/* $Header: LNS_CASGM_PUBP_B.pls 120.7.12010000.5 2010/04/08 14:51:57 gparuchu ship $ */

 /*=======================================================================+
 |  Package Global Constants
 +=======================================================================*/
    G_PKG_NAME                      CONSTANT VARCHAR2(30):= 'LNS_COND_ASSIGNMENT_PUB';
    G_LOG_ENABLED                   varchar2(5);
    G_MSG_LEVEL                     NUMBER;


--------------------------------------------------
 -- declaration of private procedures and functions
--------------------------------------------------


/*========================================================================
 | PRIVATE PROCEDURE LogMessage
 |
 | DESCRIPTION
 |      This procedure logs debug messages to db and to CM log
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |      None
 |
 | PARAMETERS
 |      p_msg_level     IN      Debug msg level
 |      p_msg           IN      Debug msg itself
 |
 | KNOWN ISSUES
 |      None
 |
 | NOTES
 |      Any interesting aspect of the code in the package body which needs
 |      to be stated.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 04-02-2008            scherkas          Created
 |
 *=======================================================================*/
Procedure LogMessage(p_msg_level IN NUMBER, p_msg in varchar2)
IS
BEGIN
    if (p_msg_level >= G_MSG_LEVEL) then

        FND_LOG.STRING(p_msg_level, G_PKG_NAME, p_msg);
        if FND_GLOBAL.Conc_Request_Id is not null then
            fnd_file.put_line(FND_FILE.LOG, p_msg);
        end if;

    end if;

EXCEPTION
    WHEN OTHERS THEN
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'ERROR: ' || sqlerrm);
END;



PROCEDURE Set_Defaults (p_COND_ASSIGNMENT_rec IN OUT NOCOPY COND_ASSIGNMENT_REC_TYPE
)
IS
BEGIN

      IF (p_COND_ASSIGNMENT_rec.mandatory_flag IS NULL) THEN
        p_COND_ASSIGNMENT_rec.mandatory_flag := 'N';
      END IF;

      IF (p_COND_ASSIGNMENT_rec.condition_met_flag IS NULL) THEN
        p_COND_ASSIGNMENT_rec.condition_met_flag := 'N';
      END IF;

END Set_Defaults;


PROCEDURE do_create_COND_ASSIGNMENT (
    p_COND_ASSIGNMENT_rec      IN OUT NOCOPY COND_ASSIGNMENT_REC_TYPE,
    x_COND_ASSIGNMENT_id              OUT NOCOPY    NUMBER,
    x_return_status        IN OUT NOCOPY VARCHAR2
);

PROCEDURE do_update_COND_ASSIGNMENT (
    p_COND_ASSIGNMENT_rec        IN OUT NOCOPY COND_ASSIGNMENT_REC_TYPE,
    p_object_version_number  IN OUT NOCOPY NUMBER,
    x_return_status          IN OUT NOCOPY VARCHAR2
);

PROCEDURE do_delete_COND_ASSIGNMENT (
    p_COND_ASSIGNMENT_id        IN NUMBER,
    x_return_status          IN OUT NOCOPY VARCHAR2
);

/*===========================================================================+
 | PROCEDURE
 |              do_create_COND_ASSIGNMENT
 |
 | DESCRIPTION
 |              Creates condition assignment.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |                    x_COND_ASSIGNMENT_id
 |              IN/OUT:
 |                    p_COND_ASSIGNMENT_rec
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |   06-Jan-2004     Bernice Lam       Created.
 +===========================================================================*/

PROCEDURE do_create_COND_ASSIGNMENT(
    p_COND_ASSIGNMENT_rec      IN OUT NOCOPY COND_ASSIGNMENT_REC_TYPE,
    x_COND_ASSIGNMENT_id              OUT NOCOPY    NUMBER,
    x_return_status        IN OUT NOCOPY VARCHAR2
) IS

    l_COND_ASSIGNMENT_id         NUMBER;
--    l_rowid                 ROWID;
    l_dummy                 VARCHAR2(1);
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);

BEGIN

    l_COND_ASSIGNMENT_id         := p_COND_ASSIGNMENT_rec.cond_assignment_id;
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Begin do_create_COND_ASSIGNMENT procedure');
    END IF;

    -- if primary key value is passed, check for uniqueness.
    IF l_COND_ASSIGNMENT_id IS NOT NULL AND
        l_COND_ASSIGNMENT_id <> FND_API.G_MISS_NUM
    THEN
        BEGIN
            SELECT 'Y'
            INTO   l_dummy
            FROM   LNS_COND_ASSIGNMENTS
            WHERE  cond_assignment_id = l_COND_ASSIGNMENT_id;

            FND_MESSAGE.SET_NAME('LNS', 'LNS_API_DUPLICATE_COLUMN');
            FND_MESSAGE.SET_TOKEN('COLUMN', 'cond_assignment_id');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL;
        END;
    END IF;

    Set_Defaults(p_COND_ASSIGNMENT_rec);

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In do_create_COND_ASSIGNMENT procedure: Before call to LNS_COND_ASSIGNMENTS_PKG.Insert_Row');
    END IF;

    -- call table-handler.
    LNS_COND_ASSIGNMENTS_PKG.Insert_Row (
	  X_COND_ASSIGNMENT_ID		=> p_COND_ASSIGNMENT_rec.cond_assignment_id,
	  P_OBJECT_VERSION_NUMBER	=> 1,
	  P_LOAN_ID			=> p_COND_ASSIGNMENT_rec.loan_id,
	  P_CONDITION_ID		=> p_COND_ASSIGNMENT_rec.condition_id,
	  P_CONDITION_DESCRIPTION	=> p_COND_ASSIGNMENT_rec.condition_description,
	  P_CONDITION_MET_FLAG		=> p_COND_ASSIGNMENT_rec.condition_met_flag,
	  P_FULFILLMENT_DATE 	=> p_COND_ASSIGNMENT_rec.fulfillment_date,
	  P_FULFILLMENT_UPDATED_BY		=> p_COND_ASSIGNMENT_rec.fulfillment_updated_by,
	  P_MANDATORY_FLAG 		=> p_COND_ASSIGNMENT_rec.mandatory_flag,
	  P_CREATED_BY			=> p_COND_ASSIGNMENT_rec.created_by,
	  P_CREATION_DATE		=> p_COND_ASSIGNMENT_rec.creation_date,
	  P_LAST_UPDATED_BY		=> p_COND_ASSIGNMENT_rec.last_updated_by,
	  P_LAST_UPDATE_DATE		=> p_COND_ASSIGNMENT_rec.last_update_date,
	  P_LAST_UPDATE_LOGIN		=> p_COND_ASSIGNMENT_rec.last_update_login,
	  P_START_DATE_ACTIVE		=> sysdate,
	  P_END_DATE_ACTIVE		=> null,
	  P_DISB_HEADER_ID		=> p_COND_ASSIGNMENT_rec.DISB_HEADER_ID,
	  P_DELETE_DISABLED_FLAG	=> p_COND_ASSIGNMENT_rec.DELETE_DISABLED_FLAG,
	  P_OWNER_OBJECT_ID		=> p_COND_ASSIGNMENT_rec.OWNER_OBJECT_ID,
	  P_OWNER_TABLE	        => p_COND_ASSIGNMENT_rec.OWNER_TABLE

	);

	x_COND_ASSIGNMENT_id := p_COND_ASSIGNMENT_rec.cond_assignment_id;
    x_return_status := 'S';

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In do_create_COND_ASSIGNMENT procedure: After call to LNS_COND_ASSIGNMENT.Insert_Row');
    END IF;

END do_create_COND_ASSIGNMENT;


/*===========================================================================+
 | PROCEDURE
 |              do_update_COND_ASSIGNMENT
 |
 | DESCRIPTION
 |              Updates condition assignment.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |              IN/OUT:
 |                    p_COND_ASSIGNMENT_rec
 |		      p_object_version_number
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |   22-APR-2004     Bernice Lam       Created.
 +===========================================================================*/

PROCEDURE do_update_COND_ASSIGNMENT(
    p_COND_ASSIGNMENT_rec          IN OUT NOCOPY COND_ASSIGNMENT_REC_TYPE,
    p_object_version_number   IN OUT NOCOPY NUMBER,
    x_return_status           IN OUT NOCOPY VARCHAR2
) IS

    l_object_version_number         NUMBER;
--    l_rowid                         ROWID;
    ldup_rowid                      ROWID;

BEGIN

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Begin do_update_COND_ASSIGNMENT procedure');
    END IF;

    -- check whether record has been updated by another user. If not, lock it.
    BEGIN
        SELECT OBJECT_VERSION_NUMBER
        INTO   l_object_version_number
        FROM   LNS_COND_ASSIGNMENTS
        WHERE  COND_ASSIGNMENT_ID = p_COND_ASSIGNMENT_rec.cond_assignment_id
        FOR UPDATE OF COND_ASSIGNMENT_ID NOWAIT;

        IF NOT
            (
             (p_object_version_number IS NULL AND l_object_version_number IS NULL)
             OR
             (p_object_version_number IS NOT NULL AND
              l_object_version_number IS NOT NULL AND
              p_object_version_number = l_object_version_number
             )
            )
        THEN
            FND_MESSAGE.SET_NAME('LNS', 'LNS_API_RECORD_CHANGED');
            FND_MESSAGE.SET_TOKEN('TABLE', 'lns_COND_ASSIGNMENTs');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        p_object_version_number := nvl(l_object_version_number, 1) + 1;

    EXCEPTION WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('LNS', 'LNS_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD', 'cond_assignment_rec');
        FND_MESSAGE.SET_TOKEN('VALUE', NVL(TO_CHAR(p_COND_ASSIGNMENT_rec.cond_assignment_id), 'null'));
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;

    Set_Defaults(p_COND_ASSIGNMENT_rec);

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In do_update_COND_ASSIGNMENT procedure: Before call to LNS_COND_ASSIGNMENTS_PKG.Update_Row');
    END IF;

    -- log history
    LNS_LOAN_HISTORY_PUB.log_record_pre(p_COND_ASSIGNMENT_rec.cond_assignment_id,
					'COND_ASSIGNMENT_ID',
					'LNS_COND_ASSIGNMENTS');

    --Call to table-handler
    LNS_COND_ASSIGNMENTS_PKG.Update_Row (
	  P_COND_ASSIGNMENT_ID		=> p_COND_ASSIGNMENT_rec.cond_assignment_id,
	  P_OBJECT_VERSION_NUMBER	=> p_OBJECT_VERSION_NUMBER,
	  P_LOAN_ID			=> p_COND_ASSIGNMENT_rec.LOAN_ID,
	  P_CONDITION_ID		=> p_COND_ASSIGNMENT_rec.CONDITION_ID,
	  P_CONDITION_DESCRIPTION	=> p_COND_ASSIGNMENT_rec.CONDITION_DESCRIPTION,
	  P_CONDITION_MET_FLAG		=> p_COND_ASSIGNMENT_rec.CONDITION_MET_FLAG,
	  P_FULFILLMENT_DATE		=> p_COND_ASSIGNMENT_rec.FULFILLMENT_DATE,
	  P_FULFILLMENT_UPDATED_BY	=> p_COND_ASSIGNMENT_rec.FULFILLMENT_UPDATED_BY,
	  P_MANDATORY_FLAG 		=> p_COND_ASSIGNMENT_rec.MANDATORY_FLAG,
	  P_LAST_UPDATED_BY		=> NULL,
	  P_LAST_UPDATE_DATE		=> NULL,
	  P_LAST_UPDATE_LOGIN		=> NULL,
	  P_START_DATE_ACTIVE		=> NULL,
	  P_END_DATE_ACTIVE		=> NULL,
	  P_DISB_HEADER_ID		=> p_COND_ASSIGNMENT_rec.DISB_HEADER_ID,
	  P_DELETE_DISABLED_FLAG	=> p_COND_ASSIGNMENT_rec.DELETE_DISABLED_FLAG,
	  P_OWNER_OBJECT_ID		=> p_COND_ASSIGNMENT_rec.OWNER_OBJECT_ID,
	  P_OWNER_TABLE	        => p_COND_ASSIGNMENT_rec.OWNER_TABLE
);

    -- log record changes
    LNS_LOAN_HISTORY_PUB.log_record_post(p_COND_ASSIGNMENT_rec.cond_assignment_id,
					'COND_ASSIGNMENT_ID',
					'LNS_COND_ASSIGNMENTS',
					p_COND_ASSIGNMENT_rec.loan_id);

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In do_update_COND_ASSIGNMENT procedure: After call to LNS_COND_ASSIGNMENTS_PKG.Update_Row');
    END IF;

END do_update_COND_ASSIGNMENT;

/*===========================================================================+
 | PROCEDURE
 |              do_delete_COND_ASSIGNMENT
 |
 | DESCRIPTION
 |              Deletes cond assignment.
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |              OUT:
 |              IN/OUT:
 |                    p_COND_ASSIGNMENT_id
 |		      p_object_version_number
 |                    x_return_status
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |
 |   06-Jan-2004     Bernice Lam       Created.
 +===========================================================================*/

PROCEDURE do_delete_COND_ASSIGNMENT(
    p_COND_ASSIGNMENT_id           NUMBER,
    x_return_status           IN OUT NOCOPY VARCHAR2
) IS

    l_loan_id		    NUMBER;
    l_object_version_num    NUMBER;
    l_cond_assign_rec	    COND_ASSIGNMENT_REC_TYPE;

BEGIN

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Begin do_delete_COND_ASSIGNMENT procedure');
    END IF;

    IF p_COND_ASSIGNMENT_id IS NOT NULL AND
      p_COND_ASSIGNMENT_id <> FND_API.G_MISS_NUM
    THEN
    -- check whether record has been deleted by another user. If not, lock it.
      BEGIN
        SELECT loan_id, object_version_number
        INTO   l_loan_id, l_object_version_num
        FROM   LNS_COND_ASSIGNMENTS
        WHERE  COND_ASSIGNMENT_ID = p_COND_ASSIGNMENT_id
	FOR UPDATE NOWAIT;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          FND_MESSAGE.SET_NAME('LNS', 'LNS_API_NO_RECORD');
          FND_MESSAGE.SET_TOKEN('RECORD', 'cond_assignment_rec');
          FND_MESSAGE.SET_TOKEN('VALUE', NVL(TO_CHAR(p_COND_ASSIGNMENT_id), 'null'));
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
      END;
    END IF;


    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In do_delete_COND_ASSIGNMENT procedure: Before call to LNS_COND_ASSIGNMENTS_PKG.Delete_Row');
    END IF;

    -- log history
    LNS_LOAN_HISTORY_PUB.log_record_pre(p_cond_assignment_id,
					'COND_ASSIGNMENT_ID',
					'LNS_COND_ASSIGNMENTS');

    BEGIN

      UPDATE LNS_COND_ASSIGNMENTS
      SET END_DATE_ACTIVE = SYSDATE,
      OBJECT_VERSION_NUMBER = nvl(l_object_version_num, 1) + 1
      WHERE COND_ASSIGNMENT_ID = p_cond_assignment_id;

    EXCEPTION
      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('LNS', 'LNS_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

/*
    --Call to table-handler
    LNS_COND_ASSIGNMENTS_PKG.Update_Row (
	  P_COND_ASSIGNMENT_ID		=> p_COND_ASSIGNMENT_ID,
	  P_OBJECT_VERSION_NUMBER	=> null,
	  P_LOAN_ID			=> p_COND_ASSIGNMENT_rec.LOAN_ID,
	  P_CONDITION_ID		=> p_COND_ASSIGNMENT_rec.CONDITION_ID,
	  P_CONDITION_DESCRIPTION	=> p_COND_ASSIGNMENT_rec.CONDITION_DESCRIPTION,
	  P_CONDITION_MET_FLAG		=> p_COND_ASSIGNMENT_rec.CONDITION_MET_FLAG,
	  P_FULFILLMENT_DATE		=> p_COND_ASSIGNMENT_rec.FULFILLMENT_DATE,
	  P_FULFILLMENT_UPDATED_BY	=> p_COND_ASSIGNMENT_rec.FULFILLMENT_UPDATED_BY,
	  P_MANDATORY_FLAG 		=> p_COND_ASSIGNMENT_rec.MANDATORY_FLAG,
	  P_LAST_UPDATED_BY		=> NULL,
	  P_LAST_UPDATE_DATE		=> NULL,
	  P_LAST_UPDATE_LOGIN		=> NULL,
	  P_START_DATE_ACTIVE		=> NULL,
	  P_END_DATE_ACTIVE		=> sysdate
    );
*/
    -- log record changes
    LNS_LOAN_HISTORY_PUB.log_record_post(p_cond_assignment_id,
					'COND_ASSIGNMENT_ID',
					'LNS_COND_ASSIGNMENTS',
					l_loan_id);

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In do_delete_COND_ASSIGNMENT procedure: After call to LNS_COND_ASSIGNMENTS_PKG.Delete_Row');
    END IF;

END do_delete_COND_ASSIGNMENT;

----------------------------
-- body of public procedures
----------------------------

/*===========================================================================+
 | PROCEDURE
 |              create_COND_ASSIGNMENT
 |
 | DESCRIPTION
 |              Creates cond assignment.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_init_msg_list
 |                    p_COND_ASSIGNMENT_rec
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |                    x_COND_ASSIGNMENT_id
 |              IN/OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |   22-APR-2004     Bernice Lam       Created.
 +===========================================================================*/

PROCEDURE create_COND_ASSIGNMENT (
    p_init_msg_list   IN      VARCHAR2,
    p_COND_ASSIGNMENT_rec IN      COND_ASSIGNMENT_REC_TYPE,
    x_COND_ASSIGNMENT_id         OUT NOCOPY     NUMBER,
    x_return_status   OUT NOCOPY     VARCHAR2,
    x_msg_count       OUT NOCOPY     NUMBER,
    x_msg_data        OUT NOCOPY     VARCHAR2
) IS

    l_api_name        CONSTANT VARCHAR2(30) := 'create_COND_ASSIGNMENT';
    l_COND_ASSIGNMENT_rec  COND_ASSIGNMENT_REC_TYPE;

BEGIN

    l_COND_ASSIGNMENT_rec  := p_COND_ASSIGNMENT_rec;
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Begin Create_COND_ASSIGNMENT procedure');
    END IF;

    -- standard start of API savepoint
    SAVEPOINT create_COND_ASSIGNMENT;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In Create_COND_ASSIGNMENT procedure: Before call to do_create_COND_ASSIGNMENT proc');
    END IF;

    -- call to business logic.
    do_create_COND_ASSIGNMENT(
                   l_COND_ASSIGNMENT_rec,
                   x_COND_ASSIGNMENT_id,
                   x_return_status
                  );

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In Create_COND_ASSIGNMENT procedure: After call to do_create_COND_ASSIGNMENT proc');
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_COND_ASSIGNMENT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_COND_ASSIGNMENT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO create_COND_ASSIGNMENT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('LNS', 'LNS_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'End Create_COND_ASSIGNMENT procedure');
    END IF;

END create_COND_ASSIGNMENT;

/*===========================================================================+
 | PROCEDURE
 |              update_COND_ASSIGNMENT
 |
 | DESCRIPTION
 |              Updates condition assignment.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_init_msg_list
 |                    p_COND_ASSIGNMENT_rec
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |              IN/OUT:
 |		      p_object_version_number
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |   22-APR-2004     Bernice Lam		Created
 +===========================================================================*/

PROCEDURE update_COND_ASSIGNMENT (
    p_init_msg_list         IN      VARCHAR2,
    p_COND_ASSIGNMENT_rec        IN      COND_ASSIGNMENT_REC_TYPE,
    p_object_version_number IN OUT NOCOPY  NUMBER,
    x_return_status         OUT NOCOPY     VARCHAR2,
    x_msg_count             OUT NOCOPY     NUMBER,
    x_msg_data              OUT NOCOPY     VARCHAR2
) IS

    l_api_name            CONSTANT VARCHAR2(30) := 'update_COND_ASSIGNMENT';
    l_COND_ASSIGNMENT_rec     COND_ASSIGNMENT_REC_TYPE;
    l_old_COND_ASSIGNMENT_rec COND_ASSIGNMENT_REC_TYPE;

BEGIN

    l_COND_ASSIGNMENT_rec     := p_COND_ASSIGNMENT_rec;
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Begin Update_COND_ASSIGNMENT procedure');
    END IF;

    -- standard start of API savepoint
    SAVEPOINT update_COND_ASSIGNMENT;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;
/*
    -- Get old record. Will be used by history package.
    get_COND_ASSIGNMENT_rec (
        p_COND_ASSIGNMENT_id         => l_COND_ASSIGNMENT_rec.assignment_id,
        x_COND_ASSIGNMENT_rec => l_old_COND_ASSIGNMENT_rec,
        x_return_status   => x_return_status,
        x_msg_count       => x_msg_count,
        x_msg_data        => x_msg_data );
*/
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In Update_COND_ASSIGNMENT procedure: Before call to do_update_COND_ASSIGNMENT proc');
    END IF;

    -- call to business logic.
    do_update_COND_ASSIGNMENT(
                   l_COND_ASSIGNMENT_rec,
                   p_object_version_number,
                   x_return_status
                  );

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In Update_COND_ASSIGNMENT procedure: After call to do_update_COND_ASSIGNMENT proc');
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_COND_ASSIGNMENT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_COND_ASSIGNMENT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO update_COND_ASSIGNMENT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('LNS', 'LNS_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'End Update_COND_ASSIGNMENT procedure');
    END IF;

END update_COND_ASSIGNMENT;

/*===========================================================================+
 | PROCEDURE
 |              delete_COND_ASSIGNMENT
 |
 | DESCRIPTION
 |              Deletes assignment.
 |
 | SCOPE - PUBLIC
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_init_msg_list
 |                    p_COND_ASSIGNMENT_id
 |              OUT:
 |                    x_return_status
 |                    x_msg_count
 |                    x_msg_data
 |              IN/OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |   22-APR-2004     Bernice Lam       Created.
 +===========================================================================*/

PROCEDURE delete_COND_ASSIGNMENT (
    p_init_msg_list   IN      VARCHAR2,
    p_COND_ASSIGNMENT_id         IN     NUMBER,
    x_return_status   OUT NOCOPY     VARCHAR2,
    x_msg_count       OUT NOCOPY     NUMBER,
    x_msg_data        OUT NOCOPY     VARCHAR2
) IS

    l_api_name        CONSTANT VARCHAR2(30) := 'delete_COND_ASSIGNMENT';
    l_COND_ASSIGNMENT_id   NUMBER;

BEGIN

    l_COND_ASSIGNMENT_id   := p_COND_ASSIGNMENT_id;
    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Begin Delete_COND_ASSIGNMENT procedure');
    END IF;

    -- standard start of API savepoint
    SAVEPOINT delete_COND_ASSIGNMENT;

    -- initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In Delete_COND_ASSIGNMENT procedure: Before call to do_delete_COND_ASSIGNMENT proc');
    END IF;

    -- call to business logic.
    do_delete_COND_ASSIGNMENT(
                   l_COND_ASSIGNMENT_id,
                   x_return_status
                  );

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In Delete_COND_ASSIGNMENT procedure: After call to do_delete_COND_ASSIGNMENT proc');
    END IF;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO delete_COND_ASSIGNMENT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO delete_COND_ASSIGNMENT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO delete_COND_ASSIGNMENT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('LNS', 'LNS_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                  p_encoded => FND_API.G_FALSE,
                                  p_count => x_msg_count,
                                  p_data  => x_msg_data);

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'End Delete_COND_ASSIGNMENT procedure');
    END IF;

END delete_COND_ASSIGNMENT;


PROCEDURE create_LP_COND_ASSIGNMENT(
            P_LOAN_ID IN NUMBER ) IS

CURSOR loan_prod_cond ( c_loan_id NUMBER ) IS
    select LNS_COND_ASSIGNMENTS_S.NEXTVAL COND_ASSIGNMENT_ID,
    LnsLoanHeaders.LOAN_ID,
    LnsConditions.CONDITION_ID,
    LnsConditions.CONDITION_DESCRIPTION,
    LnsLoanProductLines.MANDATORY_FLAG

FROM LNS_CONDITIONS LnsConditions ,
LNS_LOAN_HEADERS LnsLoanHeaders ,
LNS_LOAN_PRODUCT_LINES LnsLoanProductLines

WHERE LnsLoanHeaders.LOAN_ID = c_loan_id
AND LnsLoanHeaders.PRODUCT_ID = LnsLoanProductLines.LOAN_PRODUCT_ID
AND LnsLoanProductLines.LOAN_PRODUCT_LINE_TYPE = 'CONDITION'
AND LnsLoanProductLines.LINE_REFERENCE_ID = LnsCOnditions.CONDITION_ID ;


CURSOR current_loan_status ( c_loan_id NUMBER ) IS
  SELECT LOAN_STATUS , CURRENT_PHASE
  FROM LNS_LOAN_HEADERS LnsLoanHeaders
  WHERE LnsLoanHeaders.LOAN_ID = c_loan_id ;


CURSOR loan_cond_count ( c_loan_id NUMBER ) IS
  SELECT count(COND_ASSIGNMENT_ID)
  FROM LNS_COND_ASSIGNMENTS_VL LnsCondAssignments
    WHERE LnsCondAssignments.LOAN_ID = c_loan_id ;


l_cond_assignment_id NUMBER ;
l_loan_id NUMBER ;
l_condition_id NUMBER ;
l_cond_desc LNS_CONDITIONS.CONDITION_DESCRIPTION%TYPE ;
l_mandatory_flag LNS_LOAN_PRODUCT_LINES.MANDATORY_FLAG%TYPE ;
l_cond_assignment_rec cond_assignment_rec_type ;
x_return_status VARCHAR2(1) ;
l_loan_status   LNS_LOAN_HEADERS.LOAN_STATUS%TYPE ;
l_loan_current_phase   LNS_LOAN_HEADERS.CURRENT_PHASE%TYPE ;
l_loan_cond_count    NUMBER ;
is_commit_needed BOOLEAN;

BEGIN
    --Initialize this variable to false. Change to true when a record is
    --inserted into the table in this procedure
    is_commit_needed := FALSE;

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Begin create_LP_COND_ASSIGNMENT procedure');
    END IF;

    -- standard start of API savepoint
    SAVEPOINT create_LP_COND_ASSIGNMENT;


    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In create_LP_COND_ASSIGNMENT procedure: Before opening cursor current_loan_status ');
    END IF;

    OPEN current_loan_status(P_LOAN_ID) ;

    FETCH current_loan_status INTO l_loan_status ,l_loan_Current_phase ;

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In create_LP_COND_ASSIGNMENT procedure: After opening cursor current_loan_status , loan status is '||l_loan_status ||' loan current phase is '||l_loan_Current_phase);
    END IF;

    /* If the loan current phase is not open or loan status is not Incomplete for Term loan , no conditions assignment required  */
    IF( NOT ( ( l_loan_status='INCOMPLETE' AND l_loan_current_phase = 'TERM' ) OR ( l_loan_current_phase = 'OPEN' ) ) ) THEN
	        RETURN  ;
    END IF ;




    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'create_LP_COND_ASSIGNMENT procedure: Before opening cursor loan_cond_count ');
    END IF;

    OPEN loan_cond_count(P_LOAN_ID) ;

    FETCH loan_cond_count INTO l_loan_cond_count ;

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In create_LP_COND_ASSIGNMENT procedure: After opening cursor loan_fee_count , loan condition count is '||l_loan_cond_count );
    END IF;

    /* If the loan condition count is not zero and there are already conditions assigned to loan, no conditions assignment required  */
    IF( l_loan_cond_count <> 0 ) THEN
	        RETURN  ;
    END IF ;



    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In create_LP_COND_ASSIGNMENT procedure: Before opening cursor loan_prod_cond ');
    END IF;

    OPEN loan_prod_cond(P_LOAN_ID) ;

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In create_LP_COND_ASSIGNMENT procedure: After opening cursor loan_prod_cond , no of conditions found is '||loan_prod_cond%ROWCOUNT);
    END IF;



LOOP

FETCH loan_prod_cond INTO l_cond_assignment_id ,l_loan_id,l_condition_id,l_cond_desc,l_mandatory_flag ;
EXIT WHEN loan_prod_cond%NOTFOUND ;

l_cond_assignment_rec.COND_ASSIGNMENT_ID := l_cond_assignment_id ;
l_cond_assignment_rec.LOAN_ID := l_loan_id ;
l_cond_assignment_rec.CONDITION_ID := l_condition_id ;
l_cond_assignment_rec.CONDITION_DESCRIPTION := l_cond_desc ;
l_cond_assignment_rec.CONDITION_MET_FLAG  := 'N' ;
l_cond_assignment_rec.FULFILLMENT_DATE := NULL ;
l_cond_assignment_rec.FULFILLMENT_UPDATED_BY  := NULL ;
l_cond_assignment_rec.MANDATORY_FLAG := l_mandatory_flag ;
l_cond_assignment_rec.CREATED_BY := NULL ;
l_cond_assignment_rec.CREATION_DATE  := NULL ;
l_cond_assignment_rec.LAST_UPDATED_BY := NULL ;
l_cond_assignment_rec.LAST_UPDATE_DATE := NULL ;
l_cond_assignment_rec.LAST_UPDATE_LOGIN := NULL ;
l_cond_assignment_rec.OBJECT_VERSION_NUMBER  := 1 ;
l_cond_assignment_rec.DISB_HEADER_ID := NULL ;
l_cond_assignment_rec.DELETE_DISABLED_FLAG := l_mandatory_flag ;
l_cond_assignment_rec.OWNER_OBJECT_ID := NULL ;
l_cond_assignment_rec.OWNER_TABLE := NULL ;


IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In create_LP_COND_ASSIGNMENT procedure: Before call to do_create_COND_ASSIGNMENT proc for condition'|| l_condition_id);
    END IF;

    -- call to business logic.
    do_create_COND_ASSIGNMENT( l_cond_assignment_rec ,
                           l_cond_assignment_id ,
                           x_return_status ) ;

    is_commit_needed := true;

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In create_LP_COND_ASSIGNMENT procedure: After call to do_create_COND_ASSIGNMENT proc for condition'|| l_condition_id ||' , return status is' || x_return_status);
    END IF;



END LOOP ;

--If records have been inserted into lns_cond_assignments table
--they need to be committed since the commit does not happen on the UI
--unless the user explicitly commits from the UI page
IF (is_commit_needed = TRUE) THEN
    COMMIT WORK;
END IF;

EXCEPTION

    WHEN OTHERS THEN
        ROLLBACK TO create_LP_COND_ASSIGNMENT;

END create_LP_COND_ASSIGNMENT ;


PROCEDURE create_LP_DISB_COND_ASSIGNMENT(
            P_LOAN_ID IN NUMBER,
            P_DISB_HEADER_ID IN NUMBER ,
            P_LOAN_PRODUCT_LINE_ID IN NUMBER)
IS

    CURSOR loan_prod_disb_cond ( c_loan_prod_line_id NUMBER ) IS
        select LnsConditions.CONDITION_ID,
            LnsConditions.CONDITION_DESCRIPTION,
            LnsLoanProductLines.MANDATORY_FLAG
        FROM LNS_CONDITIONS_VL LnsConditions ,
            LNS_LOAN_PRODUCT_LINES LnsLoanProductLines
        WHERE LnsLoanProductLines.PARENT_PRODUCT_LINES_ID = c_loan_prod_line_id
            AND LnsLoanProductLines.LOAN_PRODUCT_LINE_TYPE = 'DISB_CONDITION'
            AND LnsLoanProductLines.LINE_REFERENCE_ID = LnsCOnditions.CONDITION_ID
        UNION
        select LnsConditions.CONDITION_ID,
            LnsConditions.CONDITION_DESCRIPTION,
            LnsLoanProductLines.MANDATORY_FLAG
        FROM LNS_CONDITIONS_VL LnsConditions ,
            LNS_LOAN_PRODUCT_LINES LnsLoanProductLines
        WHERE LnsLoanProductLines.loan_product_id =
                (SELECT loan_product_id FROM LNS_LOAN_PRODUCT_LINES WHERE loan_product_lines_id = c_loan_prod_line_id)
            AND LnsLoanProductLines.LOAN_PRODUCT_LINE_TYPE = 'CONDITION'
            AND LnsLoanProductLines.LINE_REFERENCE_ID = LnsCOnditions.CONDITION_ID
            and LnsCOnditions.condition_type = 'DISBURSEMENT';

    l_cond_assignment_id NUMBER ;
    l_temp_cond_assignment_id NUMBER ;
    l_condition_id NUMBER ;
    l_cond_desc LNS_CONDITIONS.CONDITION_DESCRIPTION%TYPE ;
    l_mandatory_flag LNS_LOAN_PRODUCT_LINES.MANDATORY_FLAG%TYPE ;
    l_cond_assignment_rec cond_assignment_rec_type ;
    x_return_status VARCHAR2(1) ;

BEGIN

    logMessage(FND_LOG.LEVEL_STATEMENT, 'Begin create_LP_DISB_COND_ASSIGNMENT procedure');

    logMessage(FND_LOG.LEVEL_STATEMENT, 'P_LOAN_ID = ' || P_LOAN_ID);
    logMessage(FND_LOG.LEVEL_STATEMENT, 'P_DISB_HEADER_ID = ' || P_DISB_HEADER_ID);
    logMessage(FND_LOG.LEVEL_STATEMENT, 'P_LOAN_PRODUCT_LINE_ID = ' || P_LOAN_PRODUCT_LINE_ID);

    -- standard start of API savepoint
    SAVEPOINT create_LP_DISB_COND_ASSIGNMENT;

    logMessage(FND_LOG.LEVEL_STATEMENT, 'In create_LP_DISB_COND_ASSIGNMENT procedure: Before opening cursor loan_prod_disb_cond ');

    OPEN loan_prod_disb_cond(P_LOAN_PRODUCT_LINE_ID) ;

    logMessage(FND_LOG.LEVEL_STATEMENT, 'In create_LP_DISB_COND_ASSIGNMENT procedure: After opening cursor loan_prod_disb_cond , no of conditions found is '||loan_prod_disb_cond%ROWCOUNT);
    LOOP

        FETCH loan_prod_disb_cond INTO l_condition_id,l_cond_desc,l_mandatory_flag ;
        EXIT WHEN loan_prod_disb_cond%NOTFOUND ;

	select LNS_COND_ASSIGNMENTS_S.NEXTVAL into l_temp_cond_assignment_id from DUAL;
	l_cond_assignment_rec.COND_ASSIGNMENT_ID := l_temp_cond_assignment_id;

	--commented below line as it was throwing error PLS-00357 during the build by release team
	--l_cond_assignment_rec.COND_ASSIGNMENT_ID := LNS_COND_ASSIGNMENTS_S.NEXTVAL;

        l_cond_assignment_rec.LOAN_ID := P_LOAN_ID ;
        l_cond_assignment_rec.CONDITION_ID := l_condition_id ;
        l_cond_assignment_rec.CONDITION_DESCRIPTION := l_cond_desc ;
        l_cond_assignment_rec.CONDITION_MET_FLAG  := 'N' ;
        l_cond_assignment_rec.FULFILLMENT_DATE := NULL ;
        l_cond_assignment_rec.FULFILLMENT_UPDATED_BY  := NULL ;
        l_cond_assignment_rec.MANDATORY_FLAG := l_mandatory_flag ;
        l_cond_assignment_rec.CREATED_BY := NULL ;
        l_cond_assignment_rec.CREATION_DATE  := NULL ;
        l_cond_assignment_rec.LAST_UPDATED_BY := NULL ;
        l_cond_assignment_rec.LAST_UPDATE_DATE := NULL ;
        l_cond_assignment_rec.LAST_UPDATE_LOGIN := NULL ;
        l_cond_assignment_rec.OBJECT_VERSION_NUMBER  := 1 ;
        l_cond_assignment_rec.DISB_HEADER_ID := P_DISB_HEADER_ID ;
        l_cond_assignment_rec.DELETE_DISABLED_FLAG := l_mandatory_flag ;
        l_cond_assignment_rec.OWNER_OBJECT_ID := NULL ;
        l_cond_assignment_rec.OWNER_TABLE := 'LNS_DISB_HEADERS' ;

        logMessage(FND_LOG.LEVEL_STATEMENT, 'In create_LP_DISB_COND_ASSIGNMENT procedure: Before call to do_create_COND_ASSIGNMENT proc for condition '|| l_condition_id);

        -- call to business logic.
        do_create_COND_ASSIGNMENT( l_cond_assignment_rec ,
                            l_cond_assignment_id ,
                            x_return_status ) ;

        logMessage(FND_LOG.LEVEL_STATEMENT, 'In create_LP_DISB_COND_ASSIGNMENT procedure: After call to do_create_COND_ASSIGNMENT proc for condition '|| l_condition_id ||' , return status is ' || x_return_status);

    END LOOP ;

EXCEPTION

    WHEN OTHERS THEN
        ROLLBACK TO create_LP_DISB_COND_ASSIGNMENT;

END create_LP_DISB_COND_ASSIGNMENT ;




PROCEDURE delete_DISB_COND_ASSIGNMENT( P_DISB_HEADER_ID IN NUMBER ) IS

CURSOR loan_disb_cond ( c_disb_header_id NUMBER ) IS
    SELECT COND_ASSIGNMENT_ID
    FROM LNS_COND_ASSIGNMENTS LnsCondAssignments
    WHERE LnsCondAssignments.DISB_HEADER_ID = c_disb_header_id  ;

l_cond_assignment_id NUMBER ;
x_return_status VARCHAR2(1) ;

BEGIN


    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'Begin delete_DISB_COND_ASSIGNMENT procedure');
    END IF;

    -- standard start of API savepoint
    SAVEPOINT delete_DISB_COND_ASSIGNMENT;


IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In delete_DISB_COND_ASSIGNMENT procedure: Before opening cursor loan_disb_cond ');
    END IF;

    OPEN loan_disb_cond(P_DISB_HEADER_ID ) ;

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In delete_DISB_COND_ASSIGNMENT procedure: After opening cursor loan_disb_cond , no of conditions found is '||loan_disb_cond%ROWCOUNT);
    END IF;



LOOP

FETCH loan_disb_cond INTO l_cond_assignment_id ;
EXIT WHEN loan_disb_cond%NOTFOUND ;


IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In delete_DISB_COND_ASSIGNMENT procedure: Before call to do_delete_COND_ASSIGNMENT proc for cond_assignment_id'|| l_cond_assignment_id);
    END IF;

    -- call to business logic.
    do_delete_COND_ASSIGNMENT(l_cond_assignment_id ,
                           x_return_status ) ;

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    	FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, 'In delete_DISB_COND_ASSIGNMENT procedure: After call to do_delete_COND_ASSIGNMENT proc for cond_assignment_id'|| l_cond_assignment_id ||' , return status is' || x_return_status);
    END IF;



END LOOP ;



EXCEPTION

    WHEN OTHERS THEN
        ROLLBACK TO delete_DISB_COND_ASSIGNMENT;

END delete_DISB_COND_ASSIGNMENT ;



FUNCTION IS_EXIST_COND_ASSIGNMENT (
    p_condition_id			 NUMBER
) RETURN VARCHAR2 IS

  CURSOR C_Is_Exist_Assignment (X_COND_Id NUMBER) IS
  SELECT 'X' FROM DUAL
  WHERE EXISTS ( SELECT NULL FROM LNS_COND_ASSIGNMENTS
                  WHERE CONDITION_ID = X_COND_ID )
  OR EXISTS ( SELECT NULL FROM LNS_LOAN_PRODUCT_LINES
              WHERE LINE_REFERENCE_ID = X_COND_ID
              AND ( LOAN_PRODUCT_LINE_TYPE = 'CONDITION' OR LOAN_PRODUCT_LINE_TYPE='DISB_CONDITION' )
              );

  l_dummy VARCHAR2(1);

BEGIN

  OPEN C_Is_Exist_Assignment (p_condition_id);
  FETCH C_Is_Exist_Assignment INTO l_dummy;
  IF C_Is_Exist_Assignment%FOUND THEN
    CLOSE C_Is_Exist_Assignment;
    RETURN 'Y';
  END IF;
  CLOSE C_Is_Exist_Assignment;
  RETURN 'N';

END IS_EXIST_COND_ASSIGNMENT;



PROCEDURE VALIDATE_CUSTOM_CONDITIONS(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL		IN          NUMBER,
    P_OWNER_OBJECT_ID       IN          NUMBER,
    P_CONDITION_TYPE        IN          VARCHAR2,
    P_COMPLETE_FLAG         IN          VARCHAR2,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    		OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'VALIDATE_CUSTOM_CONDITIONS';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);

    l_COND_ASSIGNMENT_ID            NUMBER;
    l_CONDITION_ID                  NUMBER;
    l_CONDITION_NAME                VARCHAR2(50);
    l_CONDITION_DESCRIPTION         VARCHAR2(250);
    l_CONDITION_TYPE                VARCHAR2(30);
    l_MANDATORY_FLAG                VARCHAR2(1);
    l_CUSTOM_PROCEDURE              VARCHAR2(250);
    i                               number;
    l_success_count                 number;
    l_failed_count                  number;
    l_version_number                number;

    l_cond_assignment_tbl           LNS_COND_ASSIGNMENT_PUB.cond_assignment_tbl_type;
/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    /* querying all custom conditions for specified object */
    CURSOR custom_conditions_cur(P_OWNER_OBJECT_ID number, P_CONDITION_TYPE varchar2) IS
        select cond_ass.COND_ASSIGNMENT_ID,
            cond.CONDITION_ID,
            cond.CONDITION_NAME,
            cond.CONDITION_DESCRIPTION,
            cond.CONDITION_TYPE,
            cond_ass.MANDATORY_FLAG,
            cond.CUSTOM_PROCEDURE
        from LNS_CONDITIONS_VL cond,
            LNS_COND_ASSIGNMENTS cond_ass
        where decode(P_CONDITION_TYPE, 'APPROVAL', cond_ass.LOAN_ID,
                                       'CONVERSION', cond_ass.LOAN_ID,
                                       'DISBURSEMENT', cond_ass.DISB_HEADER_ID,
                                       cond_ass.OWNER_OBJECT_ID) = P_OWNER_OBJECT_ID
            and cond.custom_procedure is not null
            and cond.condition_type = P_CONDITION_TYPE
            and cond.condition_id = cond_ass.condition_id
            and cond_ass.END_DATE_ACTIVE is null;

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT VALIDATE_CUSTOM_CONDITIONS;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Savepoint is established');

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Input:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_OWNER_OBJECT_ID = ' || P_OWNER_OBJECT_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_CONDITION_TYPE = ' || P_CONDITION_TYPE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_COMPLETE_FLAG = ' || P_COMPLETE_FLAG);

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Querying for custom conditions...');
    l_success_count := 0;
    l_failed_count := 0;
    i := 0;
    open custom_conditions_cur(P_OWNER_OBJECT_ID, P_CONDITION_TYPE);
    LOOP

        fetch custom_conditions_cur into
            l_COND_ASSIGNMENT_ID,
            l_CONDITION_ID,
            l_CONDITION_NAME,
            l_CONDITION_DESCRIPTION,
            l_CONDITION_TYPE,
            l_MANDATORY_FLAG,
            l_CUSTOM_PROCEDURE;
        exit when custom_conditions_cur%NOTFOUND;

        i := i + 1;
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Custom condition ' || i);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_COND_ASSIGNMENT_ID = ' || l_COND_ASSIGNMENT_ID);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_CONDITION_ID = ' || l_CONDITION_ID);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_CONDITION_NAME = ' || l_CONDITION_NAME);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_CONDITION_DESCRIPTION = ' || l_CONDITION_DESCRIPTION);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_CONDITION_TYPE = ' || l_CONDITION_TYPE);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_MANDATORY_FLAG = ' || l_MANDATORY_FLAG);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_CUSTOM_PROCEDURE = ' || l_CUSTOM_PROCEDURE);

        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Validating custom condition ' || l_CONDITION_NAME || '...');
        VALIDATE_CUSTOM_CONDITION(
            P_API_VERSION		    => 1.0,
            P_INIT_MSG_LIST		    => FND_API.G_FALSE,
            P_COMMIT			    => FND_API.G_FALSE,
            P_VALIDATION_LEVEL		=> FND_API.G_VALID_LEVEL_FULL,
            P_COND_ASSIGNMENT_ID    => l_COND_ASSIGNMENT_ID,
            X_RETURN_STATUS		    => l_return_status,
            X_MSG_COUNT			    => l_msg_count,
            X_MSG_DATA	    		=> l_msg_data);

        IF l_return_status = 'S' THEN
            l_success_count := l_success_count + 1;
            if P_COMPLETE_FLAG = 'Y' then
                l_cond_assignment_tbl(i).COND_ASSIGNMENT_ID := l_COND_ASSIGNMENT_ID;
                l_cond_assignment_tbl(i).CONDITION_MET_FLAG := 'Y';
                l_cond_assignment_tbl(i).FULFILLMENT_DATE := sysdate;
                l_cond_assignment_tbl(i).FULFILLMENT_UPDATED_BY := lns_utility_pub.user_id;
		l_cond_assignment_tbl(i).MANDATORY_FLAG := l_MANDATORY_FLAG;
            end if;
        ELSE
            l_failed_count := l_failed_count + 1;
        END IF;

    END LOOP;
    close custom_conditions_cur;

    LogMessage(FND_LOG.LEVEL_STATEMENT, '-------------');
    if i = 0 then
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'No custom conditions found. Exiting.');
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        return;
    end if;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Successfully validated custom conditions: ' || l_success_count);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Failed custom conditions: ' || l_failed_count);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Total validated custom conditions: ' || i);

    if l_failed_count > 0 then
        RAISE FND_API.G_EXC_ERROR;
    end if;

    -- completing all custom conditions if P_COMPLETE_FLAG = 'Y'
    if P_COMPLETE_FLAG = 'Y' then
        FOR j IN 1..l_cond_assignment_tbl.COUNT LOOP

            select OBJECT_VERSION_NUMBER into l_version_number
            from LNS_COND_ASSIGNMENTS
            where COND_ASSIGNMENT_ID = l_cond_assignment_tbl(j).COND_ASSIGNMENT_ID;

            update_COND_ASSIGNMENT (
                p_init_msg_list         => FND_API.G_FALSE,
                p_COND_ASSIGNMENT_rec   => l_cond_assignment_tbl(j),
                p_object_version_number => l_version_number,
                X_RETURN_STATUS		    => l_return_status,
                X_MSG_COUNT			    => l_msg_count,
                X_MSG_DATA	    		=> l_msg_data);

            if l_return_status <> 'S' then
                RAISE FND_API.G_EXC_ERROR;
            end if;

        END LOOP;
    end if;

    if P_COMMIT = FND_API.G_TRUE then
        COMMIT WORK;
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Commited');
    end if;

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Successfully validated all custom conditions for object ' || P_OWNER_OBJECT_ID || '; type ' || P_CONDITION_TYPE);

    -- END OF BODY OF API
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data => x_msg_data);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO VALIDATE_CUSTOM_CONDITIONS;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO VALIDATE_CUSTOM_CONDITIONS;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
    WHEN OTHERS THEN
        ROLLBACK TO VALIDATE_CUSTOM_CONDITIONS;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Rollbacked');
END;




PROCEDURE VALIDATE_CUSTOM_CONDITION(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL		IN          NUMBER,
    P_COND_ASSIGNMENT_ID    IN          NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    		OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'VALIDATE_CUSTOM_CONDITION';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);

    l_CONDITION_ID                  NUMBER;
    l_CONDITION_NAME                VARCHAR2(50);
    l_CONDITION_DESCRIPTION         VARCHAR2(250);
    l_CONDITION_TYPE                VARCHAR2(30);
    l_MANDATORY_FLAG                VARCHAR2(1);
    l_CUSTOM_PROCEDURE              VARCHAR2(250);
    l_result                        varchar2(1);
    l_error                         varchar2(2000);
    l_plsql_block                   varchar2(2000);

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    /* querying condition info */
    CURSOR cond_info_cur(P_COND_ASSIGNMENT_ID number) IS
        select cond.CONDITION_ID,
            cond.CONDITION_NAME,
            cond.CONDITION_DESCRIPTION,
            cond.CONDITION_TYPE,
            cond_ass.MANDATORY_FLAG,
            cond.CUSTOM_PROCEDURE
        from LNS_CONDITIONS_VL cond,
            LNS_COND_ASSIGNMENTS cond_ass
        where cond_ass.cond_assignment_id = P_COND_ASSIGNMENT_ID
            and cond.condition_id = cond_ass.condition_id
            and cond_ass.END_DATE_ACTIVE is null;

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Input:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_COND_ASSIGNMENT_ID = ' || P_COND_ASSIGNMENT_ID);

    /* querying condition info */
    open cond_info_cur(P_COND_ASSIGNMENT_ID);
    fetch cond_info_cur into
        l_CONDITION_ID,
        l_CONDITION_NAME,
        l_CONDITION_DESCRIPTION,
        l_CONDITION_TYPE,
        l_MANDATORY_FLAG,
        l_CUSTOM_PROCEDURE;
    close cond_info_cur;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Condition info:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_CONDITION_ID = ' || l_CONDITION_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_CONDITION_NAME = ' || l_CONDITION_NAME);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_CONDITION_DESCRIPTION = ' || l_CONDITION_DESCRIPTION);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_CONDITION_TYPE = ' || l_CONDITION_TYPE);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_MANDATORY_FLAG = ' || l_MANDATORY_FLAG);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_CUSTOM_PROCEDURE = ' || l_CUSTOM_PROCEDURE);

    if l_CUSTOM_PROCEDURE is null then
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'This is not custom condition. Exiting.');
        return;
    end if;

    l_plsql_block := 'BEGIN ' || l_CUSTOM_PROCEDURE || '(:1, :2, :3); END;';

    BEGIN

        logMessage(FND_LOG.LEVEL_STATEMENT, 'l_plsql_block = ' || l_plsql_block);
        logMessage(FND_LOG.LEVEL_STATEMENT, 'Calling...');

        EXECUTE IMMEDIATE l_plsql_block
        USING
            IN P_COND_ASSIGNMENT_ID,
            OUT l_result,
            OUT l_error;

        logMessage(FND_LOG.LEVEL_STATEMENT, 'Done');

    EXCEPTION
        WHEN OTHERS THEN
            FND_MESSAGE.SET_NAME('LNS', 'LNS_CUSTOM_COND_FAILED');
            FND_MESSAGE.SET_TOKEN('COND_NAME' ,l_CONDITION_NAME);
            FND_MESSAGE.SET_TOKEN('ERROR_MESG' ,SQLERRM);
            FND_MSG_PUB.ADD;
            LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
            RAISE FND_API.G_EXC_ERROR;
    END;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_result = ' || l_result);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_error = ' || l_error);

    if l_result = 'N' then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_CUSTOM_COND_FAILED');
        FND_MESSAGE.SET_TOKEN('COND_NAME' ,l_CONDITION_NAME);
        FND_MESSAGE.SET_TOKEN('ERROR_MESG' ,l_error);
        FND_MSG_PUB.ADD;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    end if;

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Successfully validated custom condition ' || l_CONDITION_NAME);

    -- END OF BODY OF API
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data => x_msg_data);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
END;



PROCEDURE DEFAULT_COND_ASSIGNMENTS(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL		IN          NUMBER,
    P_LOAN_ID               IN          NUMBER,
    P_OWNER_OBJECT_ID       IN          NUMBER,
    P_CONDITION_TYPE        IN          VARCHAR2,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    		OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'DEFAULT_COND_ASSIGNMENTS';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_cond_name                     VARCHAR2(50);
    i                               number;
    l_cond_assignment_id            number;

    l_cond_assignment_rec           COND_ASSIGNMENT_REC_TYPE;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    /* querying condition info */
    CURSOR cond_info_cur(P_LOAN_ID number, P_CONDITION_TYPE varchar2) IS
        select cond_ass.CONDITION_ID,
            cond.CONDITION_NAME,
            cond.CONDITION_DESCRIPTION,
            cond_ass.MANDATORY_FLAG,
            cond_ass.DELETE_DISABLED_FLAG
        from LNS_CONDITIONS_VL cond,
            LNS_COND_ASSIGNMENTS cond_ass
        where cond_ass.LOAN_ID = P_LOAN_ID
            and cond.CONDITION_TYPE = P_CONDITION_TYPE
            and cond.condition_id = cond_ass.condition_id
            and decode(cond.CONDITION_TYPE, 'DISBURSEMENT', cond_ass.DISB_HEADER_ID, cond_ass.OWNER_OBJECT_ID) is null
            and cond_ass.END_DATE_ACTIVE is null;

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard start of API savepoint
    SAVEPOINT DEFAULT_COND_ASSIGNMENTS;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Savepoint is established');

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Input:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_LOAN_ID = ' || P_LOAN_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_OWNER_OBJECT_ID = ' || P_OWNER_OBJECT_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_CONDITION_TYPE = ' || P_CONDITION_TYPE);

    if P_LOAN_ID is null then
        FND_MESSAGE.SET_NAME( 'LNS', 'LNS_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'P_LOAN_ID' );
        FND_MSG_PUB.ADD;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    end if;

    if P_OWNER_OBJECT_ID is null then
        FND_MESSAGE.SET_NAME( 'LNS', 'LNS_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'P_OWNER_OBJECT_ID' );
        FND_MSG_PUB.ADD;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    end if;

    if P_CONDITION_TYPE is null then
        FND_MESSAGE.SET_NAME( 'LNS', 'LNS_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'P_CONDITION_TYPE' );
        FND_MSG_PUB.ADD;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    end if;

    if P_CONDITION_TYPE <> 'LOAN_AMOUNT_ADJUSTMENT' and
       P_CONDITION_TYPE <> 'ADDITIONAL_RECEIVABLE' and
       P_CONDITION_TYPE <> 'DISBURSEMENT'
    then
        FND_MESSAGE.SET_NAME( 'LNS', 'LNS_INVALID_VALUE' );
        FND_MESSAGE.SET_TOKEN( 'PARAMETER', 'P_CONDITION_TYPE' );
        FND_MESSAGE.SET_TOKEN( 'VALUE', P_CONDITION_TYPE );
        FND_MSG_PUB.ADD;
        LogMessage(FND_LOG.LEVEL_UNEXPECTED, FND_MSG_PUB.Get(p_encoded => 'F'));
        RAISE FND_API.G_EXC_ERROR;
    end if;

    i := 0;
    open cond_info_cur(P_LOAN_ID, P_CONDITION_TYPE);
    LOOP

        fetch cond_info_cur into
            l_cond_assignment_rec.CONDITION_ID,
            l_cond_name,
            l_cond_assignment_rec.CONDITION_DESCRIPTION,
            l_cond_assignment_rec.MANDATORY_FLAG,
            l_cond_assignment_rec.DELETE_DISABLED_FLAG;
        exit when cond_info_cur%NOTFOUND;

        l_cond_assignment_rec.cond_assignment_id := null;
        l_cond_assignment_rec.LOAN_ID := P_LOAN_ID;
        l_cond_assignment_rec.CONDITION_MET_FLAG  := 'N';
        l_cond_assignment_rec.FULFILLMENT_DATE := NULL ;
        l_cond_assignment_rec.FULFILLMENT_UPDATED_BY  := NULL;
        l_cond_assignment_rec.CREATED_BY := NULL;
        l_cond_assignment_rec.CREATION_DATE  := NULL;
        l_cond_assignment_rec.LAST_UPDATED_BY := NULL;
        l_cond_assignment_rec.LAST_UPDATE_DATE := NULL;
        l_cond_assignment_rec.LAST_UPDATE_LOGIN := NULL;
        l_cond_assignment_rec.OBJECT_VERSION_NUMBER  := 1;

        if P_CONDITION_TYPE = 'LOAN_AMOUNT_ADJUSTMENT' then
            l_cond_assignment_rec.OWNER_OBJECT_ID := P_OWNER_OBJECT_ID;
            l_cond_assignment_rec.OWNER_TABLE := 'LNS_LOAN_AMOUNT_ADJS';
            l_cond_assignment_rec.DISB_HEADER_ID := NULL;
        elsif P_CONDITION_TYPE = 'ADDITIONAL_RECEIVABLE' then
            l_cond_assignment_rec.OWNER_OBJECT_ID := P_OWNER_OBJECT_ID;
            l_cond_assignment_rec.OWNER_TABLE := 'LNS_LOAN_LINES';
            l_cond_assignment_rec.DISB_HEADER_ID := NULL;
        elsif P_CONDITION_TYPE = 'DISBURSEMENT' then
            l_cond_assignment_rec.OWNER_OBJECT_ID := null;
            l_cond_assignment_rec.OWNER_TABLE := 'LNS_DISB_HEADERS';
            l_cond_assignment_rec.DISB_HEADER_ID := P_OWNER_OBJECT_ID;
        end if;

        i := i + 1;
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Creating cond_ass ' || i);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'CONDITION_ID = ' || l_cond_assignment_rec.CONDITION_ID);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'CONDITION_NAME = ' || l_cond_name);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'CONDITION_DESCRIPTION = ' || l_cond_assignment_rec.CONDITION_DESCRIPTION);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'MANDATORY_FLAG = ' || l_cond_assignment_rec.MANDATORY_FLAG);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'DELETE_DISABLED_FLAG = ' || l_cond_assignment_rec.DELETE_DISABLED_FLAG);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'OWNER_OBJECT_ID = ' || l_cond_assignment_rec.OWNER_OBJECT_ID);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'OWNER_TABLE = ' || l_cond_assignment_rec.OWNER_TABLE);
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'DISB_HEADER_ID = ' || l_cond_assignment_rec.DISB_HEADER_ID);

        -- call to business logic.
        do_create_COND_ASSIGNMENT(l_cond_assignment_rec,
                            l_cond_assignment_id,
                            x_return_status) ;
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'COND_ASSIGNMENT_ID = ' || l_cond_assignment_id);

    END LOOP;
    close cond_info_cur;

    if P_COMMIT = FND_API.G_TRUE then
        COMMIT WORK;
        LogMessage(FND_LOG.LEVEL_STATEMENT, 'Commited');
    end if;

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Successfully created ' || i || ' condition assignments');

    -- END OF BODY OF API
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data => x_msg_data);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO DEFAULT_COND_ASSIGNMENTS;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO DEFAULT_COND_ASSIGNMENTS;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
        ROLLBACK TO DEFAULT_COND_ASSIGNMENTS;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
END;



PROCEDURE VALIDATE_NONCUSTOM_CONDITIONS(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL		IN          NUMBER,
    P_OWNER_OBJECT_ID       IN          NUMBER,
    P_CONDITION_TYPE        IN          VARCHAR2,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    		OUT NOCOPY  VARCHAR2)
IS

/*-----------------------------------------------------------------------+
 | Local Variable Declarations and initializations                       |
 +-----------------------------------------------------------------------*/

    l_api_name                      CONSTANT VARCHAR2(30) := 'VALIDATE_NONCUSTOM_CONDITIONS';
    l_api_version                   CONSTANT NUMBER := 1.0;
    l_return_status                 VARCHAR2(1);
    l_msg_count                     NUMBER;
    l_msg_data                      VARCHAR2(32767);
    l_cond_count                    NUMBER;

/*-----------------------------------------------------------------------+
 | Cursor Declarations                                                   |
 +-----------------------------------------------------------------------*/

    -- checking for number of not met non-custom conditions
    CURSOR conditions_cur(P_OWNER_OBJECT_ID number, P_CONDITION_TYPE varchar2) IS
        select count(1)
        from LNS_CONDITIONS_VL cond,
            LNS_COND_ASSIGNMENTS cond_ass
        where
            decode(P_CONDITION_TYPE, 'APPROVAL', cond_ass.LOAN_ID,
                                     'CONVERSION', cond_ass.LOAN_ID,
                                     'DISBURSEMENT', cond_ass.DISB_HEADER_ID,
                                     cond_ass.OWNER_OBJECT_ID) = P_OWNER_OBJECT_ID
            and cond.custom_procedure is null
            and cond.condition_type = P_CONDITION_TYPE
            and cond.condition_id = cond_ass.condition_id
            and cond_ass.END_DATE_ACTIVE is null
            and cond_ass.MANDATORY_FLAG = 'Y'
            and (cond_ass.CONDITION_MET_FLAG is null or cond_ass.CONDITION_MET_FLAG = 'N');

BEGIN

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' +');

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'Input:');
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_OWNER_OBJECT_ID = ' || P_OWNER_OBJECT_ID);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'P_CONDITION_TYPE = ' || P_CONDITION_TYPE);

    -- checking for number of not met non-custom conditions
    open conditions_cur(P_OWNER_OBJECT_ID, P_CONDITION_TYPE);
    fetch conditions_cur into l_cond_count;
    close conditions_cur;
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'l_cond_count = ' || l_cond_count);

    if l_cond_count > 0 then
        FND_MESSAGE.SET_NAME('LNS', 'LNS_NOT_ALL_COND_MET');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    end if;

    LogMessage(FND_LOG.LEVEL_UNEXPECTED, 'Successfully validated all non-custom conditions for object ' || P_OWNER_OBJECT_ID || '; type ' || P_CONDITION_TYPE);

    -- END OF BODY OF API
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Standard call to get message count and if count is 1, get message info
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data => x_msg_data);

    LogMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME || '.' || l_api_name || ' -');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
END;




BEGIN
    G_LOG_ENABLED := 'N';
    G_MSG_LEVEL := FND_LOG.LEVEL_UNEXPECTED;

    /* getting msg logging info */
    G_LOG_ENABLED := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'), 'N');
    if (G_LOG_ENABLED = 'N') then
       G_MSG_LEVEL := FND_LOG.LEVEL_UNEXPECTED;
    else
       G_MSG_LEVEL := NVL(to_number(FND_PROFILE.VALUE('AFLOG_LEVEL')), FND_LOG.LEVEL_UNEXPECTED);
    end if;

    LogMessage(FND_LOG.LEVEL_STATEMENT, 'G_LOG_ENABLED: ' || G_LOG_ENABLED);
    LogMessage(FND_LOG.LEVEL_STATEMENT, 'G_MSG_LEVEL: ' || G_MSG_LEVEL);

END LNS_COND_ASSIGNMENT_PUB;

/
