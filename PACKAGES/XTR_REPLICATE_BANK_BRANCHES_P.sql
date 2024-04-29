--------------------------------------------------------
--  DDL for Package XTR_REPLICATE_BANK_BRANCHES_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_REPLICATE_BANK_BRANCHES_P" AUTHID CURRENT_USER AS
/* |  $Header: xtrrbkbs.pls 120.4 2005/07/29 08:01:04 badiredd noship $ | */

/* This package is used to replicate the Bank Branches created in CE into XTR tables.
*/
  /**
 * PROCEDURE update_bank_branchess
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
        );


/* This procedure is written so that CE can pass the individual parameters instead of ROW TYPE */
   PROCEDURE UPDATE_BANK_BRANCHES
      ( p_ce_bank_branch_id	IN	XTR_PARTY_INFO.ce_bank_branch_id%TYPE,
        p_short_name	IN	XTR_PARTY_INFO.short_name%TYPE,
        p_full_name	IN	XTR_PARTY_INFO.full_name%TYPE,
        p_swift_id	IN	XTR_PARTY_INFO.swift_id%TYPE,
        x_return_status    OUT NOCOPY VARCHAR2,
        x_msg_count     OUT NOCOPY NUMBER,
        x_msg_data     OUT NOCOPY VARCHAR2
        );


  /* This procedure is written so that CE can pass the individual parameters instead of ROW TYPE */
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
        );


/* This procedure is written so that CE can pass the individual parameters instead of ROW TYPE */
   PROCEDURE UPDATE_BANK_BRANCHES
      ( p_ce_bank_branch_id	IN	XTR_PARTY_INFO.ce_bank_branch_id%TYPE,
        p_contact_name	IN	XTR_PARTY_INFO.contact_name%TYPE,
        p_email_address	IN	XTR_PARTY_INFO.email_address%TYPE,
        p_fax_number	IN	XTR_PARTY_INFO.fax_number%TYPE,
        p_phone_number	IN	XTR_PARTY_INFO.phone_number%TYPE,
        x_return_status    OUT NOCOPY VARCHAR2,
        x_msg_count     OUT NOCOPY NUMBER,
        x_msg_data     OUT NOCOPY VARCHAR2
        );


/* This procedure is written so that CE can pass the individual parameters instead of ROW TYPE */
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
        );





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
        );

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
 *   05-19-2005    Bhargav Adireddy        	o Created.
 *
 */


    PROCEDURE MODIFY_BANK_BRANCH
      ( p_xtr_party_info_rec   IN XTR_PARTY_INFO%ROWTYPE,
        p_update_type          IN NUMBER,
        x_return_status  IN  OUT NOCOPY VARCHAR2
        );

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
     RETURN  BOOLEAN;

END XTR_REPLICATE_BANK_BRANCHES_P; -- Package spec


 

/
