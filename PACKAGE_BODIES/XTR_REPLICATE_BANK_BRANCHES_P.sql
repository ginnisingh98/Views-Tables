--------------------------------------------------------
--  DDL for Package Body XTR_REPLICATE_BANK_BRANCHES_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_REPLICATE_BANK_BRANCHES_P" AS
/* |  $Header: xtrrbkbb.pls 120.6 2005/07/29 08:01:36 badiredd noship $ | */
  /**
 * PROCEDURE update_bank_branches
 *
 * DESCRIPTION
 *     This procedure is called directly by CE to update
 *      the bank branch related data into XTR tables.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *
 *     p_xtr_party_info_rec    	Record type of XTR_PARTY_INFO.
 *					             This record type contains the Bank/Bank Branch
 *                              related information about the bank attached with
 *                              Bank Account.
 *    p_update_type             To determine what parameters CE has updated
 *   IN/OUT:
 *
 *   OUT:
 *      x_return_status                  Return status after the call. The
 *                                      status can be
 *                      FND_API.G_RET_STS_SUCCESS - for success
 *                      FND_API.G_RET_STS_ERR   - for expected error
 *                      FND_API.G_RET_STS_UNEXP_ERR - for unexpected error
 *      x_msg_count                     To return the number of error messages
 *                                      in stack
 *      x_msg_data                      To return the error message if
 *                                      x_msg_count = 1.
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   06-17-2005    Bhargav Adireddy        	o Created.
 *
 */

    PROCEDURE UPDATE_BANK_BRANCHES
      ( p_xtr_party_info_rec   IN XTR_PARTY_INFO%ROWTYPE,
        p_update_type          IN NUMBER,
        x_return_status    OUT NOCOPY VARCHAR2,
        x_msg_count     OUT NOCOPY NUMBER,
        x_msg_data     OUT NOCOPY VARCHAR2
        ) IS

l_check_branch VARCHAR2(10);

CURSOR c_check_branch IS
    SELECT 'Y'
    FROM XTR_PARTY_INFO
    WHERE ce_bank_branch_id = p_xtr_party_info_rec.ce_bank_branch_id;

BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_msg_count := NULL;
    FND_MSG_PUB.Initialize; -- Initializes the message list that stores the errors

  OPEN c_check_branch;
  FETCH c_check_branch INTO l_check_branch;

IF(c_check_branch%FOUND) THEN
    CLOSE c_check_branch;
    IF( CHK_BANK_BRANCH(p_xtr_party_info_rec.ce_bank_branch_id)) THEN
        VALIDATE_BANK_BRANCH(p_xtr_party_info_rec,p_update_type,x_return_status);
        IF(x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
            MODIFY_BANK_BRANCH(p_xtr_party_info_rec,p_update_type,x_return_status);
        END IF;
    ELSE
        x_return_status := FND_API.G_RET_STS_ERROR;
        XTR_REPLICATE_BANK_ACCOUNTS_P.LOG_ERR_MSG('XTR_INV_PARAM','XTR_PARTY_INFO.ce_bank_branch_id');
     END IF;
ELSE
    CLOSE c_check_branch;
END IF;

    FND_MSG_PUB.Count_And_Get -- Returns the error message if there is only 1 error
    (   p_count         =>      x_msg_count     ,
        p_data          =>      x_msg_data
    );
--
      EXCEPTION
        WHEN others THEN
         x_return_status    := FND_API.G_RET_STS_UNEXP_ERROR;
         XTR_REPLICATE_BANK_ACCOUNTS_P.LOG_ERR_MSG('XTR_UNEXP_ERROR',SQLERRM(SQLCODE));
         FND_MSG_PUB.Count_And_Get -- Returns the error message if there is only 1 error
         (  p_count         =>      x_msg_count     ,
            p_data          =>      x_msg_data
         );
END UPDATE_BANK_BRANCHES;


/* This procedure is to override the previos procedure so that CE can pass the individual parameters */

PROCEDURE UPDATE_BANK_BRANCHES
      ( p_ce_bank_branch_id	IN	XTR_PARTY_INFO.ce_bank_branch_id%TYPE,
        p_short_name	IN	XTR_PARTY_INFO.short_name%TYPE,
        p_full_name	IN	XTR_PARTY_INFO.full_name%TYPE,
        p_swift_id	IN	XTR_PARTY_INFO.swift_id%TYPE,
        x_return_status    OUT NOCOPY VARCHAR2,
        x_msg_count     OUT NOCOPY NUMBER,
        x_msg_data     OUT NOCOPY VARCHAR2
        ) IS

l_xtr_party_info_rec   XTR_PARTY_INFO%ROWTYPE;

BEGIN

	l_xtr_party_info_rec.ce_bank_branch_id	:=	p_ce_bank_branch_id;
	l_xtr_party_info_rec.short_name	:=	p_short_name;
	l_xtr_party_info_rec.full_name	:=	p_full_name;
    l_xtr_party_info_rec.swift_id	:=	p_swift_id;


	UPDATE_BANK_BRANCHES( l_xtr_party_info_rec,1, x_return_status,
        x_msg_count,
        x_msg_data);

   EXCEPTION
        WHEN others THEN
         x_return_status    := FND_API.G_RET_STS_UNEXP_ERROR;
         XTR_REPLICATE_BANK_ACCOUNTS_P.LOG_ERR_MSG('XTR_UNEXP_ERROR',SQLERRM(SQLCODE));
         FND_MSG_PUB.Count_And_Get -- Returns the error message if there is only 1 error
         (  p_count         =>      x_msg_count     ,
            p_data          =>      x_msg_data
         );
END UPDATE_BANK_BRANCHES;


PROCEDURE UPDATE_BANK_BRANCHES
      ( p_ce_bank_branch_id	IN	XTR_PARTY_INFO.ce_bank_branch_id%TYPE,
        p_address_2	IN	XTR_PARTY_INFO.address_2%TYPE,
        p_address_3	IN	XTR_PARTY_INFO.address_3%TYPE,
        p_address_4	IN	XTR_PARTY_INFO.address_4%TYPE,
        p_address_5	IN	XTR_PARTY_INFO.address_5%TYPE,
        p_country_code	IN	XTR_PARTY_INFO.country_code%TYPE,
        p_state_code	IN	XTR_PARTY_INFO.state_code%TYPE,
        x_return_status    OUT NOCOPY VARCHAR2,
        x_msg_count     OUT NOCOPY NUMBER,
        x_msg_data     OUT NOCOPY VARCHAR2
        ) IS

l_xtr_party_info_rec   XTR_PARTY_INFO%ROWTYPE;

BEGIN

	l_xtr_party_info_rec.ce_bank_branch_id	:=	p_ce_bank_branch_id;
	l_xtr_party_info_rec.address_2	:=	p_address_2;
	l_xtr_party_info_rec.address_3	:=	p_address_3;
	l_xtr_party_info_rec.address_4	:=	p_address_4;
	l_xtr_party_info_rec.address_5	:=	p_address_5;
    l_xtr_party_info_rec.country_code	:=	p_country_code;
	l_xtr_party_info_rec.state_code	:=	p_state_code;

	UPDATE_BANK_BRANCHES( l_xtr_party_info_rec,4, x_return_status,
        x_msg_count,
        x_msg_data);

   EXCEPTION
        WHEN others THEN
         x_return_status    := FND_API.G_RET_STS_UNEXP_ERROR;
         XTR_REPLICATE_BANK_ACCOUNTS_P.LOG_ERR_MSG('XTR_UNEXP_ERROR',SQLERRM(SQLCODE));
         FND_MSG_PUB.Count_And_Get -- Returns the error message if there is only 1 error
         (  p_count         =>      x_msg_count     ,
            p_data          =>      x_msg_data
         );
END UPDATE_BANK_BRANCHES;


PROCEDURE UPDATE_BANK_BRANCHES
      ( p_ce_bank_branch_id	IN	XTR_PARTY_INFO.ce_bank_branch_id%TYPE,
        p_contact_name	IN	XTR_PARTY_INFO.contact_name%TYPE,
        p_email_address	IN	XTR_PARTY_INFO.email_address%TYPE,
        p_fax_number	IN	XTR_PARTY_INFO.fax_number%TYPE,
        p_phone_number	IN	XTR_PARTY_INFO.phone_number%TYPE,
        x_return_status    OUT NOCOPY VARCHAR2,
        x_msg_count     OUT NOCOPY NUMBER,
        x_msg_data     OUT NOCOPY VARCHAR2
        ) IS

l_xtr_party_info_rec   XTR_PARTY_INFO%ROWTYPE;

BEGIN

	l_xtr_party_info_rec.ce_bank_branch_id	:=	p_ce_bank_branch_id;
	l_xtr_party_info_rec.contact_name	:=	p_contact_name;
	l_xtr_party_info_rec.email_address	:=	p_email_address;
	l_xtr_party_info_rec.fax_number	:=	p_fax_number;
	l_xtr_party_info_rec.phone_number	:=	p_phone_number;

	UPDATE_BANK_BRANCHES( l_xtr_party_info_rec,3, x_return_status,
        x_msg_count,
        x_msg_data);

   EXCEPTION
        WHEN others THEN
         x_return_status    := FND_API.G_RET_STS_UNEXP_ERROR;
         XTR_REPLICATE_BANK_ACCOUNTS_P.LOG_ERR_MSG('XTR_UNEXP_ERROR',SQLERRM(SQLCODE));
         FND_MSG_PUB.Count_And_Get -- Returns the error message if there is only 1 error
         (  p_count         =>      x_msg_count     ,
            p_data          =>      x_msg_data
         );
END UPDATE_BANK_BRANCHES;

PROCEDURE UPDATE_BANK_BRANCHES
      ( p_ce_bank_branch_id	IN	XTR_PARTY_INFO.ce_bank_branch_id%TYPE,
        p_address_2	IN	XTR_PARTY_INFO.address_2%TYPE,
        p_address_3	IN	XTR_PARTY_INFO.address_3%TYPE,
        p_address_4	IN	XTR_PARTY_INFO.address_4%TYPE,
        p_address_5	IN	XTR_PARTY_INFO.address_5%TYPE,
        p_p_address_1	IN	XTR_PARTY_INFO.p_address_1%TYPE,
        p_p_address_2	IN	XTR_PARTY_INFO.p_address_2%TYPE,
        p_p_address_3	IN	XTR_PARTY_INFO.p_address_3%TYPE,
        p_p_address_4	IN	XTR_PARTY_INFO.p_address_4%TYPE,
        p_state_code	IN	XTR_PARTY_INFO.state_code%TYPE,
        p_swift_id	IN	XTR_PARTY_INFO.swift_id%TYPE,
        x_return_status    OUT NOCOPY VARCHAR2,
        x_msg_count     OUT NOCOPY NUMBER,
        x_msg_data     OUT NOCOPY VARCHAR2
        ) IS

l_xtr_party_info_rec   XTR_PARTY_INFO%ROWTYPE;

BEGIN

	l_xtr_party_info_rec.ce_bank_branch_id	:=	p_ce_bank_branch_id;
	l_xtr_party_info_rec.address_2	:=	p_address_2;
	l_xtr_party_info_rec.address_3	:=	p_address_3;
	l_xtr_party_info_rec.address_4	:=	p_address_4;
	l_xtr_party_info_rec.address_5	:=	p_address_5;
	l_xtr_party_info_rec.p_address_1	:=	p_p_address_1;
	l_xtr_party_info_rec.p_address_2	:=	p_p_address_2;
	l_xtr_party_info_rec.p_address_3	:=	p_p_address_3;
	l_xtr_party_info_rec.p_address_4	:=	p_p_address_4;
	l_xtr_party_info_rec.state_code	:=	p_state_code;
	l_xtr_party_info_rec.swift_id	:=	p_swift_id;

	UPDATE_BANK_BRANCHES( l_xtr_party_info_rec,2, x_return_status,
        x_msg_count,
        x_msg_data);

   EXCEPTION
        WHEN others THEN
         x_return_status    := FND_API.G_RET_STS_UNEXP_ERROR;
         XTR_REPLICATE_BANK_ACCOUNTS_P.LOG_ERR_MSG('XTR_UNEXP_ERROR',SQLERRM(SQLCODE));
         FND_MSG_PUB.Count_And_Get -- Returns the error message if there is only 1 error
         (  p_count         =>      x_msg_count     ,
            p_data          =>      x_msg_data
         );
END UPDATE_BANK_BRANCHES;



/**
 * PROCEDURE validate_bank_branch
 *
 * DESCRIPTION
 *     This procedure is used to validate the Bank/Bank Branch related data
 *      before it is inserted into XTR_PARTY_INFO. This procedure will perform the
 *      required validations and puts the corresponding error messages into list
 *
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_xtr_party_info_rec    	Record type of XTR_PARTY_INFO.
 *					             This record type contains the Bank/Bank Branch
 *                              related information about the bank attached with
 *                              Bank Account.
 *    p_update_type             Parameter to determine what parmeters are updated by CE
 *   IN/OUT:
 *
 *   OUT:
 *      x_return_status                  Return status after the call. The
 *                                      status can be
 *                      FND_API.G_RET_STS_SUCCESS - for success
 *                      FND_API.G_RET_STS_ERR   - for expected error
 *                      FND_API.G_RET_STS_UNEXP_ERR - for unexpected error
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   06-17-2005    Bhargav Adireddy        	o Created.
 *
 */

    PROCEDURE VALIDATE_BANK_BRANCH
      ( p_xtr_party_info_rec   IN XTR_PARTY_INFO%ROWTYPE,
        p_update_type          IN NUMBER,
        x_return_status   IN OUT NOCOPY VARCHAR2
        ) IS

BEGIN
    -- Verifies if the ce_bank_branch_id in XTR_PARTY_INFO is passed as null
    IF(p_xtr_party_info_rec.ce_bank_branch_id is null) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        XTR_REPLICATE_BANK_ACCOUNTS_P.LOG_ERR_MSG('XTR_INV_PARAM','XTR_PARTY_INFO.ce_bank_branch_id');
    END IF;

-- Verifies if the short_name in XTR_PARTY_INFO is passed as null
    IF(p_xtr_party_info_rec.short_name is null and p_update_type = 1) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        XTR_REPLICATE_BANK_ACCOUNTS_P.LOG_ERR_MSG('XTR_INV_PARAM','XTR_PARTY_INFO.SHORT_NAME');
    END IF;
-- Verifies if full_name in XTR_PARTY_INFO is passed as null
    IF(p_xtr_party_info_rec.full_name is null and p_update_type = 1) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        XTR_REPLICATE_BANK_ACCOUNTS_P.LOG_ERR_MSG('XTR_INV_PARAM','XTR_PARTY_INFO.FULL_NAME');
    END IF;
-- Verifies if country_code in XTR_PARTY_INFO is passed as null
    IF(p_xtr_party_info_rec.country_code is null and p_update_type = 4) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        XTR_REPLICATE_BANK_ACCOUNTS_P.LOG_ERR_MSG('XTR_INV_PARAM','XTR_PARTY_INFO.COUNTRY');
    END IF;
    EXCEPTION
        WHEN others THEN
          x_return_status    := FND_API.G_RET_STS_UNEXP_ERROR;
          XTR_REPLICATE_BANK_ACCOUNTS_P.LOG_ERR_MSG('XTR_UNEXP_ERROR',SQLERRM(SQLCODE));
END VALIDATE_BANK_BRANCH;
/**
 * PROCEDURE modify_bank_branch
 *
 * DESCRIPTION
 *     This procedure will update XTR_PARTY_INFO table with the
 *      Bank Branch data passed form CE.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_xtr_party_info_rec    	Record type of XTR_PARTY_INFO.
 *					             This record type contains the Bank/Bank Branch
 *                              related information about the bank attached with
 *                              Bank Account.                        related information.
 *    p_update_type             Parameter to determine which parameters are updated by CE
 *   IN/OUT:
 *
 *   OUT:
 *      x_return_status                  Return status after the call. The
 *                                      status can be
 *                      FND_API.G_RET_STS_SUCCESS - for success
 *                      FND_API.G_RET_STS_ERR   - for expected error
 *                      FND_API.G_RET_STS_UNEXP_ERR - for unexpected error
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   06-17-2005    Bhargav Adireddy        	o Created.
 *
 */


    PROCEDURE MODIFY_BANK_BRANCH
      ( p_xtr_party_info_rec   IN XTR_PARTY_INFO%ROWTYPE,
        p_update_type          IN NUMBER,
        x_return_status  IN  OUT NOCOPY VARCHAR2
        ) IS
CURSOR c_chk_lock IS
    SELECT ce_bank_branch_id
    FROM XTR_PARTY_INFO
    WHERE ce_bank_branch_id = p_xtr_party_info_rec.ce_bank_branch_id
    FOR UPDATE NOWAIT;

l_ce_bank_branch_id XTR_PARTY_INFO.ce_bank_branch_id%TYPE;
BEGIN
     OPEN c_chk_lock;
    FETCH c_chk_lock INTO l_ce_bank_branch_id;
    IF c_chk_lock%FOUND THEN
    CLOSE c_chk_lock;

    IF(p_update_type = 1) then
        UPDATE XTR_PARTY_INFO
        SET short_name      =   nvl(p_xtr_party_info_rec.short_name,short_name)
        ,full_name          =   p_xtr_party_info_rec.full_name
        ,updated_by        =   fnd_global.user_id
        ,updated_on        =   sysdate
                        WHERE   ce_bank_branch_id = l_ce_bank_branch_id;
   ELSIF(p_update_type = 2) THEN
        UPDATE XTR_PARTY_INFO
        SET address_2       =   p_xtr_party_info_rec.address_2
        ,address_3    =   p_xtr_party_info_rec.address_3
        ,address_4 =  p_xtr_party_info_rec.address_4
        ,address_5 =   p_xtr_party_info_rec.address_5
        ,updated_by        =   fnd_global.user_id
        ,updated_on        =   sysdate
        ,p_address_1        =   p_xtr_party_info_rec.p_address_1
        ,p_address_2        =   p_xtr_party_info_rec.p_address_2
        ,p_address_3        =   p_xtr_party_info_rec.p_address_3
        ,p_address_4        =   p_xtr_party_info_rec.p_address_4
        ,state_code        =   p_xtr_party_info_rec.state_code
        ,swift_id           =   p_xtr_party_info_rec.swift_id
                WHERE   ce_bank_branch_id = l_ce_bank_branch_id;

   ELSIF(p_update_type = 3) THEN

        UPDATE XTR_PARTY_INFO
        SET contact_name          =   p_xtr_party_info_rec.contact_name
        ,country_code    =   p_xtr_party_info_rec.country_code
        ,email_address           =   p_xtr_party_info_rec.email_address
        ,updated_by        =   fnd_global.user_id
        ,updated_on        =   sysdate
        ,fax_number    =   p_xtr_party_info_rec.fax_number
        ,phone_number =  p_xtr_party_info_rec.phone_number
                WHERE   ce_bank_branch_id = l_ce_bank_branch_id;

  ELSIF(p_update_type = 4) THEN
        UPDATE XTR_PARTY_INFO
        SET address_2       =   p_xtr_party_info_rec.address_2
        ,address_3    =   p_xtr_party_info_rec.address_3
        ,address_4 =  p_xtr_party_info_rec.address_4
        ,address_5 =   p_xtr_party_info_rec.address_5
        ,updated_by        =   fnd_global.user_id
        ,updated_on        =   sysdate
        ,country_code    =   p_xtr_party_info_rec.country_code
        ,state_code        =   p_xtr_party_info_rec.state_code
                       WHERE   ce_bank_branch_id = l_ce_bank_branch_id;

   END IF;

    ELSE


    CLOSE c_chk_lock;
        x_return_status := FND_API.G_RET_STS_ERROR;
        XTR_REPLICATE_BANK_ACCOUNTS_P.LOG_ERR_MSG('XTR_INV_PARAM','XTR_PARTY_INFO.ce_bank_branch_id');

    END IF;

    EXCEPTION
        When app_exceptions.RECORD_LOCK_EXCEPTION then -- If the record is locked
            if C_CHK_LOCK%ISOPEN then
                close c_CHK_LOCK;
            end if;
            XTR_REPLICATE_BANK_ACCOUNTS_P.LOG_ERR_MSG('CHK_LOCK');
            x_return_status := FND_API.G_RET_STS_ERROR;
        WHEN others THEN
          x_return_status    := FND_API.G_RET_STS_UNEXP_ERROR;
          XTR_REPLICATE_BANK_ACCOUNTS_P.LOG_ERR_MSG('XTR_UNEXP_ERROR',SQLERRM(SQLCODE));

END MODIFY_BANK_BRANCH;
/**
 * FUNCTION chk_bank_branch
 *
 * DESCRIPTION
 *     This Function will verify if a particular bank_branch_id exists in
 *      XTR_PARTY_INFO table with the Bank Branch ID passed form CE. This returns
 *      a BOOLEAN
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 * XTR_REPLICATE_BANK_ACCOUNTS_P.LOG_ERR_MSG()
 * ARGUMENTS
 *   IN:
 *     p_ce_bank_branch_id    		This is type of CE_BANK_BRANCH_ID present in
 *                                  XTR_PARTY_INFO. CE will pass the Bank Branch
 *                                  id for which it is going to create an account.
 *   IN/OUT:
 *
 *   OUT:
 *      This Function returns a Boolean. TRUE if the Bank Branch exists in
 *      XTR_PARTY_INFO and FALSE if the Bank Branch does not exist in
 *      XTR_PARTY_INFO
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   06-17-2005    Bhargav Adireddy        	o Created.
 *
 */


    FUNCTION CHK_BANK_BRANCH
     ( p_ce_bank_branch_id IN XTR_PARTY_INFO.CE_BANK_BRANCH_ID%TYPE)
     RETURN  BOOLEAN IS

CURSOR c_check_bank IS
    SELECT authorised
    FROM XTR_PARTY_INFO
    WHERE ce_bank_branch_id = p_ce_bank_branch_id;

    l_bank_authorised VARCHAR2(10) := 'N';

BEGIN
IF(p_ce_bank_branch_id IS NOT NULL) THEN
    OPEN c_check_bank;
    FETCH c_check_bank into l_bank_authorised;
    CLOSE c_check_bank;

    IF(nvl(l_bank_authorised,'$$$') = '$$$') THEN
        RETURN(FALSE);
    ELSE
        IF(l_bank_authorised = 'Y') THEN
            RETURN(TRUE);
        ELSE
            RETURN(FALSE);
        END IF;
    END IF;
ELSE
    RETURN(FALSE);
END IF;

END CHK_BANK_BRANCH;
END XTR_REPLICATE_BANK_BRANCHES_P;


/
