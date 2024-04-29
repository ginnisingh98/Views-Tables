--------------------------------------------------------
--  DDL for Package Body OKS_RENEW_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_RENEW_UTIL_PUB" AS
/* $Header: OKSPRUTB.pls 120.5 2005/09/27 15:10:30 anjkumar noship $*/
    PROCEDURE GET_RENEW_RULES(p_api_version IN NUMBER,
                              p_init_msg_list IN VARCHAR2,
                              x_return_status OUT NOCOPY VARCHAR2,
                              x_msg_count OUT NOCOPY NUMBER,
                              x_msg_data OUT NOCOPY VARCHAR2,
                              p_chr_id IN NUMBER,
                              p_party_id IN NUMBER,
                              p_org_id IN NUMBER,
                              p_date IN DATE DEFAULT SYSDATE,
                              p_rnrl_rec IN rnrl_rec_type,
                              x_rnrl_rec OUT NOCOPY rnrl_rec_type)
    IS
    l_api_name CONSTANT VARCHAR2(30) := 'GET_RENEW_RULES';
    l_api_version CONSTANT NUMBER := 1.0;

    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || g_pkg_name || '.' || l_api_name;
    l_error_text VARCHAR2(512);

    BEGIN

        --log key input parameters
        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.begin', 'p_chr_id=' || p_chr_id||' ,p_party_id='||p_party_id||' ,p_org_id='||p_org_id||' ,p_date='||p_date);
        END IF;

        --standard api initilization and checks
        IF NOT FND_API.compatible_api_call (l_api_version, p_api_version, l_api_name, G_PKG_NAME)THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        IF FND_API.to_boolean(p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;
        x_return_status := FND_API.G_RET_STS_SUCCESS;


        OKS_RENEW_UTIL_PVT.GET_RENEW_RULES(
            p_api_version => 1,
            p_init_msg_list => FND_API.G_FALSE,
            p_chr_id => p_chr_id,
            p_party_id => p_party_id,
            p_org_id => p_org_id,
            p_date => p_date,
            p_rnrl_rec => p_rnrl_rec,
            x_rnrl_rec => x_rnrl_rec,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data );

        IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
        ELSIF x_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
        END IF;

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.end','x_return_status='|| x_return_status);
        END IF;
        FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

    EXCEPTION
         WHEN FND_API.g_exc_error THEN
            x_return_status := FND_API.g_ret_sts_error ;

            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_error, l_mod_name || '.end_error', 'x_return_status=' || x_return_status);
            END IF;
            FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
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

    END GET_RENEW_RULES;

  --===========================================================================

    PROCEDURE UPDATE_RENEWAL_STATUS (p_api_version IN NUMBER,
                                     p_init_msg_list IN VARCHAR2,
                                     x_return_status OUT NOCOPY VARCHAR2,
                                     x_msg_count OUT NOCOPY NUMBER,
                                     x_msg_data OUT NOCOPY VARCHAR2,
                                     P_CHR_ID IN NUMBER,
                                     P_RENEW_STATUS IN VARCHAR2,
                                     P_CHR_STATUS IN VARCHAR2)
    IS
    l_api_name CONSTANT VARCHAR2(30) := 'OKS_RENEW_UTIL';
    l_api_version CONSTANT NUMBER := 1.0;
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    BEGIN

        l_return_status := OKC_API.START_ACTIVITY
        (l_api_name
         , p_init_msg_list
         , '_PUB'
         , x_return_status
         );

        IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

        OKC_UTIL.call_user_hook
        (
         x_return_status => x_return_status,
         p_package_name => g_pkg_name,
         p_procedure_name => l_api_name,
         p_before_after => 'B'
         );

        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

        OKS_RENEW_UTIL_PVT.UPDATE_RENEWAL_STATUS(
                                                 x_return_status => x_Return_Status,
                                                 P_Chr_Id => P_Chr_Id,
                                                 P_renew_status => P_renew_status,
                                                 P_Chr_status => P_Chr_status
                                                 );

        IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

        OKC_UTIL.call_user_hook
        (
         x_return_status => x_return_status,
         p_package_name => g_pkg_name,
         p_procedure_name => l_api_name,
         p_before_after => 'A'
         );

        IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

        OKC_API.END_ACTIVITY
        (
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data
         );

    EXCEPTION
        WHEN OKC_API.G_EXCEPTION_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_ERROR',
             x_msg_count,
             x_msg_data,
             '_PUB'
             );

        WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PUB'
             );

        WHEN OTHERS THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PUB'
             );

    END;

    PROCEDURE Can_Update_Contract(p_api_version IN NUMBER,
                                  p_init_msg_list IN VARCHAR2,
                                  p_chr_id IN NUMBER,
                                  x_can_update_yn OUT NOCOPY VARCHAR2,
                                  x_can_submit_yn OUT NOCOPY VARCHAR2,
                                  x_msg_count OUT NOCOPY NUMBER,
                                  x_msg_data OUT NOCOPY VARCHAR2,
                                  x_return_status OUT NOCOPY VARCHAR2) IS

    l_api_name CONSTANT VARCHAR2(30) := 'OKS_RENEW_UTIL_PUB';
    l_api_version CONSTANT NUMBER := 1.0;
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    BEGIN

        l_return_status := OKC_API.START_ACTIVITY
        (
         l_api_name
         , p_init_msg_list
         , '_PUB'
         , x_return_status
         );

        IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;


        OKC_UTIL.call_user_hook
        (
         x_return_status => x_return_status,
         p_package_name => g_pkg_name,
         p_procedure_name => l_api_name,
         p_before_after => 'B'
         );

        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

        OKS_RENEW_UTIL_PVT.Can_Update_Contract(p_chr_id => p_chr_id,
                                               x_can_update_yn => x_can_update_yn,
                                               x_can_submit_yn => x_can_submit_yn,
                                               x_msg_count => x_msg_count,
                                               x_msg_data => x_msg_data,
                                               x_return_status => x_return_status);


        IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;


        OKC_UTIL.call_user_hook
        (
         x_return_status => x_return_status,
         p_package_name => g_pkg_name,
         p_procedure_name => l_api_name,
         p_before_after => 'A'
         );

        IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

        OKC_API.END_ACTIVITY
        (
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data
         );

    EXCEPTION
        WHEN OKC_API.G_EXCEPTION_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_ERROR',
             x_msg_count,
             x_msg_data,
             '_PUB'
             );

        WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PUB'
             );

        WHEN OTHERS THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PUB'
             );

    END Can_Update_Contract;


    PROCEDURE get_payment_terms (
                                 p_api_version IN NUMBER,
                                 p_init_msg_list IN VARCHAR2,
                                 p_chr_id IN NUMBER DEFAULT FND_API.G_MISS_NUM,
                                 p_party_id IN NUMBER DEFAULT FND_API.G_MISS_NUM,
                                 p_org_id IN NUMBER DEFAULT FND_API.G_MISS_NUM,
                                 p_effective_date IN DATE DEFAULT SYSDATE,
                                 x_pay_term_id1 OUT NOCOPY VARCHAR2,
                                 x_pay_term_id2 OUT NOCOPY VARCHAR2,
                                 x_msg_count OUT NOCOPY NUMBER,
                                 x_msg_data OUT NOCOPY VARCHAR2,
                                 x_return_status OUT NOCOPY VARCHAR2) IS

    l_api_name CONSTANT VARCHAR2(30) := 'OKS_RENEW_UTIL_PUB';
    l_api_version CONSTANT NUMBER := 1.0;
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    BEGIN

        l_return_status := OKC_API.START_ACTIVITY (l_api_name
                                                   , p_init_msg_list
                                                   , '_PUB'
                                                   , x_return_status
                                                   );

        IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;


        OKC_UTIL.call_user_hook (x_return_status => x_return_status,
                                 p_package_name => g_pkg_name,
                                 p_procedure_name => l_api_name,
                                 p_before_after => 'B'
                                 );

        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

        OKS_RENEW_UTIL_PVT.get_payment_terms(
                                             p_chr_id => p_chr_id,
                                             p_party_id => p_party_id,
                                             p_org_id => p_org_id,
                                             p_effective_date => p_effective_date,
                                             x_pay_term_id1 => x_pay_term_id1,
                                             x_pay_term_id2 => x_pay_term_id2,
                                             x_msg_count => x_msg_count,
                                             x_msg_data => x_msg_data,
                                             x_return_status => x_return_status
                                             );


        IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;


        OKC_UTIL.call_user_hook (
                                 x_return_status => x_return_status,
                                 p_package_name => g_pkg_name,
                                 p_procedure_name => l_api_name,
                                 p_before_after => 'A'
                                 );

        IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

        OKC_API.END_ACTIVITY (x_msg_count => x_msg_count,
                              x_msg_data => x_msg_data
                              );

    EXCEPTION
        WHEN OKC_API.G_EXCEPTION_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS (
                                                          l_api_name,
                                                          G_PKG_NAME,
                                                          'OKC_API.G_RET_STS_ERROR',
                                                          x_msg_count,
                                                          x_msg_data,
                                                          '_PUB'
                                                          );

        WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS (
                                                          l_api_name,
                                                          G_PKG_NAME,
                                                          'OKC_API.G_RET_STS_UNEXP_ERROR',
                                                          x_msg_count,
                                                          x_msg_data,
                                                          '_PUB'
                                                          );

        WHEN OTHERS THEN
            x_return_status := OKC_API.HANDLE_EXCEPTIONS (
                                                          l_api_name,
                                                          G_PKG_NAME,
                                                          'OTHERS',
                                                          x_msg_count,
                                                          x_msg_data,
                                                          '_PUB'
                                                          );

    END get_payment_terms;
-------------------------------------------------------------------------------------

    PROCEDURE get_period_defaults(p_hdr_id IN NUMBER DEFAULT NULL,
                                  p_org_id IN VARCHAR2 DEFAULT NULL,
                                  x_period_type OUT NOCOPY VARCHAR2,
                                  x_period_start OUT NOCOPY VARCHAR2,
                                  x_price_uom OUT NOCOPY VARCHAR2,
                                  x_return_status OUT NOCOPY VARCHAR2)
    IS

    l_api_name CONSTANT VARCHAR2(30) := 'OKS_RENEW_UTIL_PUB';
    l_api_version CONSTANT NUMBER := 1.0;

    BEGIN

        OKS_RENEW_UTIL_PVT.get_period_defaults(p_hdr_id => p_hdr_id,
                                               p_org_id => p_org_id,
                                               x_period_type => x_period_type,
                                               x_period_start => x_period_start,
                                               x_price_uom => x_price_uom,
                                               x_return_status => x_return_status);


    END get_period_defaults;

    /* stripped down version of get_renew_rules, only gets the template set id and template lang */
    PROCEDURE get_template_set(p_api_version IN NUMBER DEFAULT 1,
                               p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                               p_chr_id IN NUMBER,
                               x_template_set_id OUT NOCOPY NUMBER,
                               x_template_lang OUT NOCOPY VARCHAR2,
                               x_return_status OUT NOCOPY VARCHAR2,
                               x_msg_count OUT NOCOPY NUMBER,
                               x_msg_data OUT NOCOPY VARCHAR2)
    IS
    l_api_name CONSTANT VARCHAR2(30) := 'GET_TEMPLATE_SET';
    l_api_version CONSTANT NUMBER := 1.0;

    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || g_pkg_name || '.' || l_api_name;
    l_error_text VARCHAR2(512);

    BEGIN

        --log key input parameters
        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.begin', 'p_chr_id=' || p_chr_id);
        END IF;

        --standard api initilization and checks
        IF NOT FND_API.compatible_api_call (l_api_version, p_api_version, l_api_name, G_PKG_NAME)THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        IF FND_API.to_boolean(p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        OKS_RENEW_UTIL_PVT.get_template_set(
            p_api_version => 1,
            p_init_msg_list => FND_API.G_FALSE,
            p_chr_id => p_chr_id,
            x_template_set_id => x_template_set_id,
            x_template_lang => x_template_lang,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data);

        IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
        ELSIF x_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
        END IF;

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.end','x_return_status='|| x_return_status);
        END IF;
        FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

    EXCEPTION
         WHEN FND_API.g_exc_error THEN
            x_return_status := FND_API.g_ret_sts_error ;

            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_error, l_mod_name || '.end_error', 'x_return_status=' || x_return_status);
            END IF;
            FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
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

    END get_template_set;


    /* utility function to get template set id */
    FUNCTION get_template_set_id(p_chr_id IN NUMBER
                                 ) RETURN NUMBER
    IS
    BEGIN
        RETURN OKS_RENEW_UTIL_PVT.get_template_set_id(p_chr_id => p_chr_id);
    END get_template_set_id;

    /* utility function to get template set lang */
    FUNCTION get_template_lang(p_chr_id IN NUMBER
                               ) RETURN VARCHAR2
    IS
    BEGIN
        RETURN OKS_RENEW_UTIL_PVT.get_template_lang(p_chr_id => p_chr_id);
    END get_template_lang;

    /*
    Procedure evaluates the renewal rules setup in Contract or GCD to determine
    the effective renewal type for a contract.

    Parameters
        p_chr_id        :   id of the contract whose renewal type needs to be determined, mandatory
        p_amount        :   contract amount, optional, if not passed derived from p_chr_id
        p_currency_code :   contract currency, optional, if not passed derived from p_chr_id
        p_rnrl_rec      :   record containing the effective renewal rules for the contract,
                            optional, if not populated, derived from p_chr_id
        x_renewal_type  :   renewal type as determined
        x_approval_type :   approval type associated with the renewal type
        x_threshold_used :  Y|N indicating if GCD threshold where used to determine the renewal type
    */
    PROCEDURE GET_RENEWAL_TYPE
    (
     p_api_version IN NUMBER,
     p_init_msg_list IN VARCHAR2 DEFAULT FND_API.G_FALSE,
     x_return_status OUT NOCOPY VARCHAR2,
     x_msg_count OUT NOCOPY NUMBER,
     x_msg_data OUT NOCOPY VARCHAR2,
     p_chr_id IN NUMBER,
     p_amount IN NUMBER DEFAULT NULL,
     p_currency_code IN VARCHAR2 DEFAULT NULL,
     p_rnrl_rec IN rnrl_rec_type DEFAULT NULL,
     x_renewal_type OUT NOCOPY VARCHAR2,
     x_approval_type OUT NOCOPY VARCHAR2,
     x_threshold_used OUT NOCOPY VARCHAR2
    ) IS
    l_api_name CONSTANT VARCHAR2(30) := 'GET_RENEWAL_TYPE';
    l_api_version CONSTANT NUMBER := 1.0;

    l_mod_name VARCHAR2(256) := lower(G_OKS_APP_NAME) || '.plsql.' || g_pkg_name || '.' || l_api_name;
    l_error_text VARCHAR2(512);

    BEGIN

        --log key input parameters
        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.begin', 'p_chr_id=' || p_chr_id);
        END IF;

        --standard api initilization and checks
        IF NOT FND_API.compatible_api_call (l_api_version, p_api_version, l_api_name, G_PKG_NAME)THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        IF FND_API.to_boolean(p_init_msg_list ) THEN
            FND_MSG_PUB.initialize;
        END IF;
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        OKS_RENEW_UTIL_PVT.get_renewal_type(
            p_api_version => 1,
            p_init_msg_list => FND_API.G_FALSE,
            x_return_status => x_return_status,
            x_msg_count => x_msg_count,
            x_msg_data => x_msg_data,
            p_chr_id => p_chr_id,
            p_amount => p_amount,
            p_currency_code => p_currency_code,
            p_rnrl_rec => p_rnrl_rec,
            x_renewal_type => x_renewal_type,
            x_approval_type => x_approval_type,
            x_threshold_used => x_threshold_used);

        IF x_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
        ELSIF x_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
        END IF;

        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(FND_LOG.level_procedure, l_mod_name || '.end','x_return_status='|| x_return_status);
        END IF;
        FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

    EXCEPTION
         WHEN FND_API.g_exc_error THEN
            x_return_status := FND_API.g_ret_sts_error ;

            IF (FND_LOG.level_error >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string(FND_LOG.level_error, l_mod_name || '.end_error', 'x_return_status=' || x_return_status);
            END IF;
            FND_MSG_PUB.count_and_get(p_count => x_msg_count, p_data => x_msg_data );

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
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

    END GET_RENEWAL_TYPE;

END OKS_RENEW_UTIL_PUB;

/
