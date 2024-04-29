--------------------------------------------------------
--  DDL for Package Body OKS_RENEW_CONTRACT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_RENEW_CONTRACT_PUB" AS
/* $Header: OKSPRENKB.pls 120.1 2005/09/27 14:31 anjkumar noship $*/

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
     )
    IS
    l_api_name CONSTANT VARCHAR2(30) := 'RENEW_CONTRACT';
    l_api_version CONSTANT NUMBER := 1;
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PKG_NAME || '.' || l_api_name;
    l_error_text VARCHAR2(512);
    BEGIN

        --log key input parameters
        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.begin', 'p_chr_id=' || p_chr_id||' ,p_new_contract_number='||p_new_contract_number||' ,p_new_contract_modifier='||p_new_contract_modifier||
                ' ,p_new_start_date='||p_new_start_date||' ,p_new_end_date='||p_new_end_date||' ,p_new_duration='||p_new_duration||' ,p_new_uom_code='||p_new_uom_code||' ,p_renewal_called_from_ui='||p_renewal_called_from_ui);
        END IF;

        --standard api initilization and checks
        SAVEPOINT renew_contract_PUB;
        IF NOT FND_API.compatible_api_call (l_api_version, p_api_version, l_api_name, G_PKG_NAME)THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        IF FND_API.to_boolean(p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        OKS_RENEW_CONTRACT_PVT.renew_contract(
            p_api_version => 1,
            p_init_msg_list => FND_API.G_FALSE,
            p_commit => FND_API.G_FALSE,
            p_chr_id => p_chr_id,
            p_new_contract_number => p_new_contract_number,
            p_new_contract_modifier => p_new_contract_modifier,
            p_new_start_date => p_new_start_date,
            p_new_end_date => p_new_end_date,
            p_new_duration => p_new_duration,
            p_new_uom_code => p_new_uom_code,
            p_renewal_called_from_ui => p_renewal_called_from_ui,
            x_chr_id => x_chr_id,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data,
            x_return_status => x_return_status);

        IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
        ELSIF x_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
        END IF;

        --standard check of p_commit
	    IF FND_API.to_boolean( p_commit ) THEN
		    COMMIT;
	    END IF;

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.end', 'x_return_status='|| x_return_status);
        END IF;
        FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

    EXCEPTION
        WHEN FND_API.g_exc_error THEN
            ROLLBACK TO renew_contract_PUB;
            x_return_status := FND_API.g_ret_sts_error ;

            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_error, l_mod_name || '.end_error', 'x_return_status=' || x_return_status);
            END IF;
            FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

        WHEN FND_API.g_exc_unexpected_error THEN
            ROLLBACK TO renew_contract_PUB;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_unexpected_error', 'x_return_status=' || x_return_status);
            END IF;
            FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

        WHEN OTHERS THEN
            ROLLBACK TO renew_contract_PUB;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                --first log the sqlerrm
                l_error_text := substr (SQLERRM, 1, 240);
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_other_error', l_error_text);
                --then add it to the message api list
                FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_error_text);
            END IF;
            FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

    END RENEW_CONTRACT;


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
    )
    IS
    l_api_name CONSTANT VARCHAR2(30) := 'VALIDATE_RENEWAL';
    l_api_version CONSTANT NUMBER := 1;
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PKG_NAME || '.' || l_api_name;
    l_error_text VARCHAR2(512);
    BEGIN

        --log key input parameters
        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.begin', 'p_chr_id=' || p_chr_id||' ,p_date='||p_date||' ,p_validation_level='||p_validation_level);
        END IF;

        --standard api initilization and checks
        IF NOT FND_API.compatible_api_call (l_api_version, p_api_version, l_api_name, G_PKG_NAME)THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        IF FND_API.to_boolean(p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        OKS_RENEW_CONTRACT_PVT.validate_renewal(
            p_api_version =>  1,
            p_init_msg_list => FND_API.G_FALSE,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data,
            p_chr_id => p_chr_id,
            p_date => p_date,
            p_validation_level => p_validation_level,
            x_rnrl_rec => x_rnrl_rec,
            x_validation_status => x_validation_status,
            x_validation_tbl => x_validation_tbl);

        IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
        ELSIF x_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
        END IF;


        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.end', 'x_return_status='|| x_return_status);
        END IF;
        FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

    EXCEPTION
        WHEN FND_API.g_exc_error THEN
            x_return_status := FND_API.g_ret_sts_error ;

            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_error, l_mod_name || '.end_error', 'x_return_status=' || x_return_status);
            END IF;
            FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

        WHEN FND_API.g_exc_unexpected_error THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_unexpected_error', 'x_return_status=' || x_return_status);
            END IF;
            FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                --first log the sqlerrm
                l_error_text := substr (SQLERRM, 1, 240);
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_other_error', l_error_text);
                --then add it to the message api list
                FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_error_text);
            END IF;
            FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

    END VALIDATE_RENEWAL;

    /*
    Utility function that returns
        FND_API.G_TRUE = T,  if a contract is valid for renewal,
        FND_API.G_FALSE = F, if contract cannot be renewed because of warnings (for e.g., all the
        lines in the contract have terminated) or errors (for e.g., the contract is in ENTERED status)
    In case of other errors, logs the error message and returns F.

    This function should be used when setting up independent conditions (events) for contract
    renewal. It will filter out contracts that are not eligible for renewal. Internally calls the
    validate_renewal procedure and returns T only if x_validation_status = S, returns F otherwise.
    */
    FUNCTION VALID_FOR_RENEWAL
    (
     p_chr_id IN NUMBER
    ) RETURN VARCHAR2
    IS
    l_api_name CONSTANT VARCHAR2(30) := 'VALID_FOR_RENEWAL';
    l_api_version CONSTANT NUMBER := 1;
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PKG_NAME || '.' || l_api_name;
    l_error_text VARCHAR2(512);

    l_return_status VARCHAR2(1);
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(4000);
    l_rnrl_rec OKS_RENEW_UTIL_PVT.rnrl_rec_type;
    l_validation_status VARCHAR2(1);
    l_validation_tbl validation_tbl_type;

    l_return_value VARCHAR2(1);

    BEGIN

        --log key input parameters
        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.begin', 'p_chr_id=' || p_chr_id);
        END IF;

        l_return_status := FND_API.G_RET_STS_SUCCESS;
        OKS_RENEW_CONTRACT_PVT.validate_renewal(p_api_version => 1,
            p_init_msg_list => FND_API.G_FALSE,
            x_return_status => l_return_status,
            x_msg_count => l_msg_count,
            x_msg_data => l_msg_data,
            p_chr_id => p_chr_id,
            p_date => null,
            p_validation_level => null,
            x_rnrl_rec => l_rnrl_rec,
            x_validation_status => l_validation_status,
            x_validation_tbl => l_validation_tbl);

        IF( (l_return_status = FND_API.g_ret_sts_success) AND
            (l_validation_status = G_VALID_STS_SUCCESS) ) THEN
            l_return_value := FND_API.G_TRUE; --T
        ELSE
            --all other conditions return false
            l_return_value := FND_API.G_FALSE; --F
        END IF;

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.end', 'l_return_status='||l_return_status||' ,l_validation_status='||l_validation_status||' ,l_return_value='||l_return_value);
        END IF;

        RETURN l_return_value;

    EXCEPTION

        WHEN OTHERS THEN
            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                --first log the sqlerrm
                l_error_text := substr (SQLERRM, 1, 240);
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_other_error', l_error_text);
                --then add it to the message api list
                FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_error_text);
            END IF;

            l_return_value := FND_API.G_FALSE; --F
            RETURN l_return_value;

    END VALID_FOR_RENEWAL;


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
     )
    IS
    l_api_name CONSTANT VARCHAR2(30) := 'UPDATE_INVOICE_TEXT';
    l_api_version CONSTANT NUMBER := 1;
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PKG_NAME || '.' || l_api_name;
    l_error_text VARCHAR2(512);
    BEGIN

        --log key input parameters
        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.begin', 'p_chr_id=' || p_chr_id||' ,p_commit='||p_commit);
        END IF;

        --standard api initilization and checks
        SAVEPOINT update_invoice_text_PUB;
        IF NOT FND_API.compatible_api_call (l_api_version, p_api_version, l_api_name, G_PKG_NAME)THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        IF FND_API.to_boolean(p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        OKS_RENEW_CONTRACT_PVT.update_invoice_text(
            p_api_version => 1,
            p_init_msg_list => FND_API.G_FALSE,
            p_commit => FND_API.G_FALSE,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data,
            p_chr_id  => p_chr_id);

        IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
        ELSIF x_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
        END IF;

        --standard check of p_commit
	    IF FND_API.to_boolean( p_commit ) THEN
		    COMMIT;
	    END IF;

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.end', 'x_return_status='|| x_return_status);
        END IF;
        FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

    EXCEPTION
        WHEN FND_API.g_exc_error THEN
            ROLLBACK TO update_invoice_text_PUB;
            x_return_status := FND_API.g_ret_sts_error ;

            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_error, l_mod_name || '.end_error', 'x_return_status=' || x_return_status);
            END IF;
            FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

        WHEN FND_API.g_exc_unexpected_error THEN
            ROLLBACK TO update_invoice_text_PUB;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_unexpected_error', 'x_return_status=' || x_return_status);
            END IF;
            FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

        WHEN OTHERS THEN
            ROLLBACK TO update_invoice_text_PUB;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                --first log the sqlerrm
                l_error_text := substr (SQLERRM, 1, 240);
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_other_error', l_error_text);
                --then add it to the message api list
                FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_error_text);
            END IF;
            FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

    END UPDATE_INVOICE_TEXT;

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
    )
    IS
    l_api_name CONSTANT VARCHAR2(30) := 'GET_USER_NAME';
    l_api_version CONSTANT NUMBER := 1;
    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || G_PKG_NAME || '.' || l_api_name;
    l_error_text VARCHAR2(512);
    BEGIN

        --log key input parameters
        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.begin', 'p_chr_id=' || p_chr_id||' ,p_hdesk_user_id='||p_hdesk_user_id);
        END IF;

        --standard api initilization and checks
        IF NOT FND_API.compatible_api_call (l_api_version, p_api_version, l_api_name, G_PKG_NAME)THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        IF FND_API.to_boolean(p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        OKS_RENEW_CONTRACT_PVT.get_user_name(
            p_api_version =>  1,
            p_init_msg_list => FND_API.G_FALSE,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data,
            p_chr_id => p_chr_id,
            p_hdesk_user_id => p_hdesk_user_id,
            x_user_id => x_user_id,
            x_user_name => x_user_name);

        IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
        ELSIF x_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
        END IF;

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.end', 'x_return_status='|| x_return_status||' ,x_user_id='||x_user_id||' ,x_user_name='||x_user_name);
        END IF;
        FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

    EXCEPTION
        WHEN FND_API.g_exc_error THEN
            x_return_status := FND_API.g_ret_sts_error ;

            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_error, l_mod_name || '.end_error', 'x_return_status=' || x_return_status);
            END IF;
            FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

        WHEN FND_API.g_exc_unexpected_error THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_unexpected_error', 'x_return_status=' || x_return_status);
            END IF;
            FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

        WHEN OTHERS THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

            IF (FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level) THEN
                --first log the sqlerrm
                l_error_text := substr (SQLERRM, 1, 240);
                FND_LOG.string(FND_LOG.level_unexpected, l_mod_name || '.end_other_error', l_error_text);
                --then add it to the message api list
                FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name, l_error_text);
            END IF;
            FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

    END GET_USER_NAME;

END OKS_RENEW_CONTRACT_PUB;

/
