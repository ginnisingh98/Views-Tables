--------------------------------------------------------
--  DDL for Package OKS_RENEW_CONTRACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKS_RENEW_CONTRACT_PVT" AUTHID CURRENT_USER AS
/* $Header: OKSRRENKS.pls 120.4.12000000.1 2007/01/16 22:11:49 appldev ship $*/


    TYPE validation_rec_type IS RECORD(
                                       code VARCHAR2(50),
                                       message VARCHAR2(4000)
                                       );
    TYPE validation_tbl_type IS TABLE OF validation_rec_type INDEX BY BINARY_INTEGER;

    G_PKG_NAME CONSTANT VARCHAR2(30) := 'OKS_RENEW_CONTRACT_PVT';
    G_OKS_APP_NAME CONSTANT VARCHAR2(3) := 'OKS'; --all new nessages should use this

    G_BULK_FETCH_LIMIT  CONSTANT NUMBER := 1000;

    G_VALIDATE_ALL CONSTANT VARCHAR2(1) := 'A';
    G_VALIDATE_ERRORS CONSTANT VARCHAR2(1) := 'E';

    G_VALID_STS_SUCCESS CONSTANT VARCHAR2(1) := 'S';
    G_VALID_STS_WARNING CONSTANT VARCHAR2(1) := 'W';
    G_VALID_STS_ERROR CONSTANT VARCHAR2(1) := 'E';


    /*
	From R12 onwards, this procedure should be used to renew service contracts.
    It will be redesigned to do the following
        1.	Improve performance
        2.	Reduce dependence on OKC code
        3.	Incorporate functional design changes for R12
        4.	Comply with current Oracle Applications coding and logging standards
        5.	Ease of maintenance

    Parameters
        p_chr_id                :   id of the contract being renewed, mandatory
        p_new_contract_number   :   contract number for the renewed contract, optional
        p_new_contract_modifier :   contract modifier for the renewed contract, optional
        p_new_start_date        :   start date for the renewed contract, optional
        p_new_end_date          :   end date for the renewed contract, optional
        p_new_duration          :   duration for renewed contract, optional
        p_new_uom_code          :   period for the renewed contract, optional
        p_renewal_called_from_ui :  'Y' - called from UI, N - called from Events
        x_chr_id            :   id of the renewed contract

    Defaulting rules
        1. If p_new_contract_number is not passed, uses the source contract_number
        2. If p_new_contract_modifier is not passed, generated this as
            fnd_profile.VALUE('OKC_CONTRACT_IDENTIFIER') || to_char(SYSDATE, 'DD-MON-YYYY HH24:MI:SS')
        3. If p_new_start_date is not passed, defaults to source contract end_date +1
        4. If p_new_end_date is not passed, derived from p_new_duration/p_new_uom_code
            and p_new_start_date. If p_new_duration/p_new_uom_code are also not passed
            used the source contract duration/period
    */

    PROCEDURE RENEW_CONTRACT
    (
     p_api_version IN NUMBER,
     p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
     p_commit   IN VARCHAR2 DEFAULT FND_API.G_FALSE,
     p_chr_id IN NUMBER,
     p_new_contract_number IN okc_k_headers_b.contract_number%TYPE,
     p_new_contract_modifier IN okc_k_headers_b.contract_number_modifier%TYPE,
     p_new_start_date IN DATE,
     p_new_end_date IN DATE,
     p_new_duration IN NUMBER,
     p_new_uom_code IN MTL_UNITS_OF_MEASURE_TL.uom_code%TYPE,
     p_renewal_called_from_ui IN VARCHAR2 DEFAULT 'Y',
     x_chr_id OUT NOCOPY NUMBER,
     x_msg_count OUT NOCOPY NUMBER,
     x_msg_data OUT NOCOPY VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2
     );



    /* R12 procedure that validates if a contract can be renewed
        p_chr_id : contract id of the contract being renewed
        p_date : start date of the renewal, if not passed defaults to end date + 1 of the source contract
        p_validation_level : A - do all checks including warnings, E - do only error checks
        x_rnrl_rec : returns the effective renewal rules for the contract
        x_validation_status : S - Success (OK for renewal), W - Warnings (Ok for renewal)
                             E - Erros (Cannot be renewed)
        x_validation_tbl : Validation error and warning messages
    */
    PROCEDURE VALIDATE_RENEWAL
    (
     p_api_version IN NUMBER DEFAULT 1,
     p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
     x_return_status OUT NOCOPY VARCHAR2,
     x_msg_count OUT NOCOPY NUMBER,
     x_msg_data OUT NOCOPY VARCHAR2,
     p_chr_id IN NUMBER,
     p_date IN DATE,
     p_validation_level IN VARCHAR2 DEFAULT G_VALIDATE_ALL,
     x_rnrl_rec OUT NOCOPY OKS_RENEW_UTIL_PVT.rnrl_rec_type,
     x_validation_status OUT NOCOPY VARCHAR2,
     x_validation_tbl OUT NOCOPY validation_tbl_type
    );

    /*
    Procedure for updating  invoice_text col in table OKC_K_LINES_TL
    with the current line start date and end date. Called during renewal,
    after line dates are adjusted. Uses bulk calls to get and set the invoice text
    Parameters
        p_chr_id    : id of the contract whose lines need to be updated
    */
    PROCEDURE UPDATE_INVOICE_TEXT
    (
     p_api_version IN NUMBER DEFAULT 1,
     p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
     p_commit   IN VARCHAR2 DEFAULT FND_API.G_FALSE,
     x_return_status OUT NOCOPY VARCHAR2,
     x_msg_count OUT NOCOPY NUMBER,
     x_msg_data OUT NOCOPY VARCHAR2,
     p_chr_id IN NUMBER
     );

    /*
    Procedure for getting the user id and name of the contact on whose behalf the
    contract workflow is launched during renewal
    Parameters
        p_chr_id            : id of the contract for which the workflow is launched
        p_hdesk_user_id     : fnd user id of the help desk user id setup in GCD. Optional,
                              if not passed will be derived from GCD.

    If no vendor/merchant contact bases on jtf object 'OKX_SALEPERS' can be found for the contract
    header, the help desk user is used. This behaviour is from R12 onwards, prior to this if a
    salesrep was not found, contract admin and then contract approver would be used.
    */
    PROCEDURE GET_USER_NAME
    (
     p_api_version IN NUMBER DEFAULT 1,
     p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
     x_return_status OUT NOCOPY VARCHAR2,
     x_msg_count OUT NOCOPY NUMBER,
     x_msg_data OUT NOCOPY VARCHAR2,
     p_chr_id IN NUMBER,
     p_hdesk_user_id IN NUMBER,
     x_user_id OUT NOCOPY NUMBER,
     x_user_name OUT NOCOPY VARCHAR2
    );


END OKS_RENEW_CONTRACT_PVT;

 

/
