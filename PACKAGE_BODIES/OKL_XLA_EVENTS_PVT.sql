--------------------------------------------------------
--  DDL for Package Body OKL_XLA_EVENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_XLA_EVENTS_PVT" AS
/* $Header: OKLRCSEB.pls 120.1.12010000.4 2009/10/08 09:30:27 nikshah ship $ */

-- Private API to write messages to log. If logging is enabled, then messages
-- are logged based on the level.
PROCEDURE WRITE_TO_LOG(p_message	IN	VARCHAR2)
IS
L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
BEGIN

  IF (L_DEBUG_ENABLED='Y' and fnd_log.level_statement >= fnd_log.g_current_runtime_level)
  THEN
    fnd_log.string(fnd_log.level_statement,
                   'okl_xla_events_pvt',
                   p_message );
  END IF;

  IF L_DEBUG_ENABLED = 'Y' then
     fnd_file.put_line (fnd_file.log,p_message);
     okl_debug_pub.logmessage(p_message);
  END IF;

END WRITE_TO_LOG;

-- Private procedure to return the entity code and event class
-- based on the transaction type
PROCEDURE get_entity_event_class(p_try_id            IN   NUMBER
								,p_action_type       IN   VARCHAR2 DEFAULT NULL
								,x_event_type_code   OUT  NOCOPY VARCHAR2
                                ,x_entity_type_code  OUT  NOCOPY VARCHAR2
                                ,x_event_class_code  OUT  NOCOPY VARCHAR2
                                ,x_return_status     OUT  NOCOPY VARCHAR2)
IS

l_entity_type_code   VARCHAR2(30);
l_event_class_code   VARCHAR2(30);

l_trx_type_name      VARCHAR2(150);
EVENT_CLASS_CODE_EXCP      EXCEPTION;

BEGIN
  SELECT DECODE(tryb.accounting_event_class_code
               ,'ACCRUAL',                 'TRANSACTIONS'
               ,'GENERAL_LOSS_PROVISION',  'TRANSACTIONS'
               ,'SPECIFIC_LOSS_PROVISION', 'TRANSACTIONS'
               ,'RECEIPT_APPLICATION',     'TRANSACTIONS'
               ,'PRINCIPAL_ADJUSTMENT',    'TRANSACTIONS'
               ,'EVERGREEN',               'CONTRACTS'
               ,'BOOKING',                 'CONTRACTS'
               ,'REBOOK',                  'CONTRACTS'
               ,'RE_LEASE',                'CONTRACTS'
               ,'TERMINATION',             'CONTRACTS'
               ,'UPFRONT_TAX',             'CONTRACTS'
               ,'ASSET_DISPOSITION',       'CONTRACTS'
               ,'SPLIT_ASSET',             'CONTRACTS'
               ,'INVESTOR',                'INVESTOR_AGREEMENTS'
               ,'UNKNOWN') entity_type_code,
         tryb.accounting_event_class_code
    INTO l_entity_type_code,
         l_event_class_code
    FROM okl_trx_types_b tryb
   WHERE tryb.id = p_try_id;

   x_entity_type_code := l_entity_type_code;
   x_event_class_code := l_event_class_code;

   IF p_action_type = 'CREATE' THEN
      x_event_type_code :=
	    CASE
		  WHEN l_event_class_code = 'ACCRUAL'                 THEN 'ACCRUAL_CREATE'
		  WHEN l_event_class_code = 'GENERAL_LOSS_PROVISION'  THEN 'GENERAL_LOSS_CREATE'
		  WHEN l_event_class_code = 'SPECIFIC_LOSS_PROVISION' THEN 'SPECIFIC_LOSS_CREATE'
		  WHEN l_event_class_code = 'RECEIPT_APPLICATION'     THEN 'RECEIPT_APPLICATION_CREATE'
		  WHEN l_event_class_code = 'PRINCIPAL_ADJUSTMENT'    THEN 'PRINCIPAL_ADJUSTMENT_CREATE'
		  WHEN l_event_class_code = 'EVERGREEN'               THEN 'EVERGREEN_CREATE'
		  WHEN l_event_class_code = 'BOOKING'                 THEN 'BOOKING_CREATE'
		  WHEN l_event_class_code = 'REBOOK'                  THEN 'REBOOK_CREATE'
		  WHEN l_event_class_code = 'RE_LEASE'                THEN 'RE_LEASE_CREATE'
		  WHEN l_event_class_code = 'TERMINATION'             THEN 'TERMINATION_CREATE'
		  WHEN l_event_class_code = 'UPFRONT_TAX'             THEN 'UPFRONT_TAX_CREATE'
		  WHEN l_event_class_code = 'ASSET_DISPOSITION'       THEN 'ASSET_DISPOSITION_CREATE'
		  WHEN l_event_class_code = 'SPLIT_ASSET'             THEN 'SPLIT_ASSET_CREATE'
		  WHEN l_event_class_code = 'INVESTOR'                THEN 'INVESTOR_CREATE'
		  ELSE 'UNKNOWN'
        END;
   ELSIF p_action_type = 'REVERSE' THEN
      x_event_type_code :=
	    CASE
		  WHEN l_event_class_code = 'ACCRUAL'                 THEN 'ACCRUAL_REVERSE'
		  WHEN l_event_class_code = 'BOOKING'                 THEN 'BOOKING_REVERSE'
		  WHEN l_event_class_code = 'GENERAL_LOSS_PROVISION'  THEN 'GENERAL_LOSS_REVERSE'
		  WHEN l_event_class_code = 'SPECIFIC_LOSS_PROVISION' THEN 'SPECIFIC_LOSS_REVERSE'
		  WHEN l_event_class_code = 'UPFRONT_TAX'             THEN 'UPFRONT_TAX_REVERSE'
		  ELSE 'UNKNOWN'
        END;
   ELSE
      x_event_type_code := NULL;
   END IF;

   IF l_entity_type_code = 'UNKNOWN' OR
      x_event_type_code  = 'UNKNOWN' THEN

	  SELECT name
	    INTO l_trx_type_name
		FROM okl_trx_types_tl
       WHERE id  = p_try_id
	     AND LANGUAGE = USERENV('LANG');

      RAISE EVENT_CLASS_CODE_EXCP;
   END IF;

   x_return_status := Okl_Api.G_RET_STS_SUCCESS;

EXCEPTION
WHEN NO_DATA_FOUND THEN
    Okl_Api.set_message(p_app_name     => g_app_name,
                        p_msg_name     => 'OKL_AM_NO_TRX_TYPE_FOUND',
                        p_token1       => 'TRY_NAME',
                        p_token1_value => p_try_id);

  x_return_status := Okl_Api.G_RET_STS_ERROR;

WHEN EVENT_CLASS_CODE_EXCP THEN
    Okl_Api.set_message(p_app_name     => g_app_name,
                        p_msg_name     => 'OKL_INVALID_EVENT_CLASS',
                        p_token1       => 'TRANSACTION_TYPE',
                        p_token1_value => l_trx_type_name);

  x_return_status := Okl_Api.G_RET_STS_ERROR;

END get_entity_event_class;

-------------------------------------------------------------------------------
-- Event creation routines
-------------------------------------------------------------------------------
-- Public function to raise an accounting event in SLA and return the event id.
-- If an error occurs, return status is set to error code and -1 is returned.
FUNCTION create_event(
    p_api_version           IN  NUMBER
   ,p_init_msg_list         IN  VARCHAR2
   ,x_return_status         OUT NOCOPY VARCHAR2
   ,x_msg_count             OUT NOCOPY NUMBER
   ,x_msg_data              OUT NOCOPY VARCHAR2
   ,p_tcn_id                IN  NUMBER
   ,p_gl_date               IN  DATE
   ,p_action_type           IN  VARCHAR2
   ,p_representation_code   IN  VARCHAR2
   ) RETURN INTEGER IS

 CURSOR get_tcn_csr is
 SELECT set_of_books_id,
        legal_entity_id,
        trunc(date_transaction_occurred) transaction_date,
        trunc(canceled_date) cancelled_date,
        trx_number,
        try_id
   FROM okl_trx_contracts
  WHERE id = p_tcn_id;

 get_tcn_rec               get_tcn_csr%ROWTYPE;

 l_event_source_info       xla_events_pub_pkg.t_event_source_info;
 l_security_context        xla_events_pub_pkg.t_security;

 l_transaction_date        DATE;
 l_event_id                NUMBER;
 l_entity_type_code        VARCHAR2(30);
 l_event_class_code        VARCHAR2(30);
 l_event_type_code         VARCHAR2(30);

 l_api_name                VARCHAR2(30) := 'CREATE_EVENT';
 l_api_version    CONSTANT NUMBER := 1.0;
 l_sla_api_name            VARCHAR2(30);
 l_return_status           VARCHAR2(1);

 l_existing_event_id       NUMBER;
 l_existing_event_date     DATE;

 l_msg_count               NUMBER;
 l_msg_data                VARCHAR2(2000);

 --Bug 8946667 by nikshah.
 l_org_id                  hr_operating_units.organization_id%type;
 l_access_mode             VARCHAR2(1);

BEGIN

   x_return_status := Okl_Api.START_ACTIVITY(l_api_name
                                             ,G_PKG_NAME
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);

    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

  WRITE_TO_LOG('');
  WRITE_TO_LOG('Inside the call to CREATE_EVENT');

  WRITE_TO_LOG('Input Parameters: ');
  WRITE_TO_LOG('===================================');
  WRITE_TO_LOG('p_tcn_id              : ' || p_tcn_id);
  WRITE_TO_LOG('p_gl_date             : ' || p_gl_date);
  WRITE_TO_LOG('p_action_type         : ' || p_action_type);
  WRITE_TO_LOG('p_representation_code : ' || p_representation_code);

  OPEN get_tcn_csr;
  FETCH get_tcn_csr into get_tcn_rec;
  CLOSE get_tcn_csr;

  WRITE_TO_LOG('Contents of GET_TCN_REC:');
  WRITE_TO_LOG('===================================');
  WRITE_TO_LOG('get_tcn_rec.try_id          : ' || get_tcn_rec.try_id);
  WRITE_TO_LOG('get_tcn_rec.legal_entity_id : ' || get_tcn_rec.legal_entity_id);
  WRITE_TO_LOG('get_tcn_rec.set_of_books_id : ' || get_tcn_rec.set_of_books_id);
  WRITE_TO_LOG('get_tcn_rec.trx_number      : ' || get_tcn_rec.trx_number);
  WRITE_TO_LOG('get_tcn_rec.transaction_date: ' || get_tcn_rec.transaction_date);
  WRITE_TO_LOG('get_tcn_rec.cancelled_date  : ' || get_tcn_rec.cancelled_date);

  get_entity_event_class(p_try_id              =>    get_tcn_rec.try_id
						,p_action_type         =>    p_action_type
						,x_event_type_code     =>    l_event_type_code
                        ,x_entity_type_code    =>    l_entity_type_code
                        ,x_event_class_code    =>    l_event_class_code
						,x_return_status       =>    l_return_status);

  IF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
     RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;

  l_event_source_info.source_application_id := g_application_id;
  l_event_source_info.application_id        := g_application_id;
  l_event_source_info.legal_entity_id       := get_tcn_rec.legal_entity_id;
  l_event_source_info.ledger_id             := get_tcn_rec.set_of_books_id;
  l_event_source_info.entity_type_code      := l_entity_type_code;
  l_event_source_info.transaction_number    := get_tcn_rec.trx_number;
  l_event_source_info.source_id_int_1       := p_tcn_id;

  l_security_context.security_id_int_1      := mo_global.get_current_org_id();

  WRITE_TO_LOG('Contents of l_event_source_info :');
  WRITE_TO_LOG('===================================');
  WRITE_TO_LOG('l_event_source_info.source_application_id : ' ||
  l_event_source_info.source_application_id);
  WRITE_TO_LOG('l_event_source_info.application_id        : ' ||
  l_event_source_info.application_id);
  WRITE_TO_LOG('l_event_source_info.legal_entity_id       : ' ||
  l_event_source_info.legal_entity_id);
  WRITE_TO_LOG('l_event_source_info.ledger_id             : ' ||
  l_event_source_info.ledger_id);
  WRITE_TO_LOG('l_event_source_info.entity_type_code      : ' ||
  l_event_source_info.entity_type_code);
  WRITE_TO_LOG('l_event_source_info.transaction_number    : ' ||
  l_event_source_info.transaction_number);
  WRITE_TO_LOG('l_event_source_info.source_id_int_1       : ' ||
  l_event_source_info.source_id_int_1);

  IF p_action_type       = 'CREATE' THEN
     l_transaction_date := get_tcn_rec.transaction_date;
  ELSIF p_action_type    = 'REVERSE' THEN
     l_transaction_date := get_tcn_rec.cancelled_date;
  END IF;

  BEGIN
    l_sla_api_name := 'CREATE_EVENT';
    --Bug 8946667 by nikshah.
    l_org_id := mo_global.get_current_org_id;
    l_access_mode := mo_global.get_access_mode;

    l_event_id :=
         xla_events_pub_pkg.create_event(p_event_source_info => l_event_source_info
                                        ,p_event_type_code   => l_event_type_code
                                        ,p_event_date        => p_gl_date
                                        ,p_event_status_code => 'U'
                                        ,p_event_number      => NULL
                                        ,p_transaction_date  => l_transaction_date
                                        ,p_reference_info    => NULL
                                        ,p_valuation_method  => p_representation_code
                                        ,p_security_context  => l_security_context
                                        );
    --Bug 8946667 by nikshah.
    --Org context was getting lost in xla_events_pub_pkg.create_event randomly
    --So below workaround was made to fix the issue.
    IF mo_global.get_current_org_id <> l_org_id OR
       mo_global.get_access_mode <> l_access_mode
    THEN
       mo_global.set_policy_context(l_access_mode,l_org_id);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

	  RAISE Okl_Api.G_EXCEPTION_ERROR;
  END;

  WRITE_TO_LOG('');
  WRITE_TO_LOG('Done with CREATE_EVENT');

  Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  x_return_status := Okl_Api.G_RET_STS_SUCCESS;

  return l_event_id;

EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
     IF get_tcn_csr%ISOPEN THEN
	    CLOSE get_tcn_csr;
     END IF;

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');
  RETURN -1;
  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
     IF get_tcn_csr%ISOPEN THEN
	    CLOSE get_tcn_csr;
     END IF;

      Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');
  RETURN -1;

  WHEN OTHERS THEN
     IF get_tcn_csr%ISOPEN THEN
	    CLOSE get_tcn_csr;
     END IF;

     x_return_status := Okl_Api.HANDLE_EXCEPTIONS
                                     (l_api_name,
                                      G_PKG_NAME,
                                      'OTHERS',
                                      x_msg_count,
                                      x_msg_data,
                                      '_PVT');

	 return -1;
END create_event;


-------------------------------------------------------------------------------
-- Event updation routines
-------------------------------------------------------------------------------
-- API to update event status of one or more matching events within an entity
PROCEDURE update_event_status(
    p_api_version           IN  NUMBER
   ,p_init_msg_list         IN  VARCHAR2
   ,x_return_status         OUT NOCOPY VARCHAR2
   ,x_msg_count             OUT NOCOPY NUMBER
   ,x_msg_data              OUT NOCOPY VARCHAR2
   ,p_tcn_id                IN  NUMBER
   ,p_gl_date               IN  DATE
   ,p_action_type           IN  VARCHAR2
   ,p_representation_code   IN  VARCHAR2
   ,p_event_status_code     IN  VARCHAR2) IS

 CURSOR get_tcn_csr is
 SELECT set_of_books_id,
        legal_entity_id,
        TRUNC(date_transaction_occurred) transaction_date,
        TRUNC(canceled_date) cancelled_date,
        trx_number,
        try_id
   FROM okl_trx_contracts
  WHERE id = p_tcn_id;

 get_tcn_rec               get_tcn_csr%ROWTYPE;

 l_event_source_info       xla_events_pub_pkg.t_event_source_info;
 l_security_context        xla_events_pub_pkg.t_security;

 l_transaction_date        DATE;
 l_event_id                NUMBER;
 l_entity_type_code        VARCHAR2(30);
 l_event_class_code        VARCHAR2(30);
 l_event_type_code         VARCHAR2(30);

 l_api_name                VARCHAR2(30) := 'UPDATE_EVENT_STATUS';
 l_api_version    CONSTANT NUMBER := 1.0;
 l_sla_api_name            VARCHAR2(30);
 l_return_status           VARCHAR2(1);
BEGIN

   x_return_status := Okl_Api.START_ACTIVITY(l_api_name
                                             ,G_PKG_NAME
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);

    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

  WRITE_TO_LOG('');
  WRITE_TO_LOG('Inside the call to ' || l_api_name);

  WRITE_TO_LOG('Input Parameters: ');
  WRITE_TO_LOG('===================================');
  WRITE_TO_LOG('p_tcn_id              : ' || p_tcn_id);
  WRITE_TO_LOG('p_gl_date             : ' || p_gl_date);
  WRITE_TO_LOG('p_action_type         : ' || p_action_type);
  WRITE_TO_LOG('p_representation_code : ' || p_representation_code);
  WRITE_TO_LOG('p_event_status_code   : ' || p_event_status_code);

  OPEN get_tcn_csr;
  FETCH get_tcn_csr into get_tcn_rec;
  CLOSE get_tcn_csr;

  WRITE_TO_LOG('Contents of GET_TCN_REC:');
  WRITE_TO_LOG('===================================');
  WRITE_TO_LOG('get_tcn_rec.try_id          : ' || get_tcn_rec.try_id);
  WRITE_TO_LOG('get_tcn_rec.legal_entity_id : ' || get_tcn_rec.legal_entity_id);
  WRITE_TO_LOG('get_tcn_rec.set_of_books_id : ' || get_tcn_rec.set_of_books_id);
  WRITE_TO_LOG('get_tcn_rec.trx_number      : ' || get_tcn_rec.trx_number);
  WRITE_TO_LOG('get_tcn_rec.transaction_date: ' || get_tcn_rec.transaction_date);
  WRITE_TO_LOG('get_tcn_rec.cancelled_date  : ' || get_tcn_rec.cancelled_date);

  get_entity_event_class(p_try_id              =>    get_tcn_rec.try_id
						,p_action_type         =>    p_action_type
						,x_event_type_code     =>    l_event_type_code
                        ,x_entity_type_code    =>    l_entity_type_code
                        ,x_event_class_code    =>    l_event_class_code
                        ,x_return_status       =>    l_return_status);

  IF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
     RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;

  l_event_source_info.source_application_id := g_application_id;
  l_event_source_info.application_id        := g_application_id;
  l_event_source_info.legal_entity_id       := get_tcn_rec.legal_entity_id;
  l_event_source_info.ledger_id             := get_tcn_rec.set_of_books_id;
  l_event_source_info.entity_type_code      := l_entity_type_code;
  l_event_source_info.transaction_number    := get_tcn_rec.trx_number;
  l_event_source_info.source_id_int_1       := p_tcn_id;

  l_security_context.security_id_int_1      := mo_global.get_current_org_id();

  WRITE_TO_LOG('Contents of l_event_source_info :');
  WRITE_TO_LOG('===================================');
  WRITE_TO_LOG('l_event_source_info.source_application_id : ' ||
  l_event_source_info.source_application_id);
  WRITE_TO_LOG('l_event_source_info.application_id        : ' ||
  l_event_source_info.application_id);
  WRITE_TO_LOG('l_event_source_info.legal_entity_id       : ' ||
  l_event_source_info.legal_entity_id);
  WRITE_TO_LOG('l_event_source_info.ledger_id             : ' ||
  l_event_source_info.ledger_id);
  WRITE_TO_LOG('l_event_source_info.entity_type_code      : ' ||
  l_event_source_info.entity_type_code);
  WRITE_TO_LOG('l_event_source_info.transaction_number    : ' ||
  l_event_source_info.transaction_number);
  WRITE_TO_LOG('l_event_source_info.source_id_int_1       : ' ||
  l_event_source_info.source_id_int_1);

  IF p_action_type       = 'CREATE' THEN
     l_transaction_date := get_tcn_rec.transaction_date;
  ELSIF p_action_type    = 'REVERSE' THEN
     l_transaction_date := get_tcn_rec.cancelled_date;
  END IF;

  BEGIN
  l_sla_api_name := 'UPDATE_EVENT_STATUS';
  xla_events_pub_pkg.update_event_status(p_event_source_info => l_event_source_info
                                        ,p_event_class_code  => l_event_class_code
                                        ,p_event_type_code   => l_event_type_code
                                        ,p_event_date        => p_gl_date
                                        ,p_event_status_code => p_event_status_code
                                        ,p_valuation_method  => p_representation_code
                                        ,p_security_context  => l_security_context);
  EXCEPTION
    WHEN OTHERS THEN
      Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

	  RAISE Okl_Api.G_EXCEPTION_ERROR;
  END;

  WRITE_TO_LOG('');
  WRITE_TO_LOG('Done with ' || l_api_name);

  Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  x_return_status := Okl_Api.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
     IF get_tcn_csr%ISOPEN THEN
	    CLOSE get_tcn_csr;
     END IF;

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');

  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
     IF get_tcn_csr%ISOPEN THEN
	    CLOSE get_tcn_csr;
     END IF;

      Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');

  WHEN OTHERS THEN
     IF get_tcn_csr%ISOPEN THEN
	    CLOSE get_tcn_csr;
     END IF;

     x_return_status := Okl_Api.HANDLE_EXCEPTIONS
                                     (l_api_name,
                                      G_PKG_NAME,
                                      'OTHERS',
                                      x_msg_count,
                                      x_msg_data,
                                      '_PVT');

END update_event_status;

-------------------------------------------------------------------------+
-- Public API to update the attributes of an event. Based on the parameters
-- passed, API calls an appropriate SLA's update event APIs.
PROCEDURE update_event(
    p_api_version           IN  NUMBER
   ,p_init_msg_list         IN  VARCHAR2
   ,x_return_status         OUT NOCOPY VARCHAR2
   ,x_msg_count             OUT NOCOPY NUMBER
   ,x_msg_data              OUT NOCOPY VARCHAR2
   ,p_tcn_id                IN  NUMBER
   ,p_gl_date               IN  DATE
   ,p_action_type           IN  VARCHAR2
   ,p_event_id              IN  NUMBER
   ,p_event_type_code       IN  VARCHAR2
   ,p_event_status_code     IN  VARCHAR2
   ,p_event_number          IN  NUMBER
   ,p_update_ref_info       IN  VARCHAR2
   ,p_reference_info        IN  xla_events_pub_pkg.t_event_reference_info
   ,p_representation_code   IN  VARCHAR2) IS

 CURSOR get_tcn_csr is
 SELECT set_of_books_id,
        legal_entity_id,
        trunc(date_transaction_occurred) transaction_date,
        trunc(canceled_date) cancelled_date,
        trx_number,
        try_id
   FROM okl_trx_contracts
  WHERE id = p_tcn_id;

 get_tcn_rec               get_tcn_csr%ROWTYPE;

 l_event_source_info       xla_events_pub_pkg.t_event_source_info;
 l_security_context        xla_events_pub_pkg.t_security;

 l_transaction_date        DATE;
 l_event_id                NUMBER;
 l_entity_type_code        VARCHAR2(30);
 l_event_class_code        VARCHAR2(30);
 l_event_type_code         VARCHAR2(30);

 l_api_name                VARCHAR2(20) := 'UPDATE_EVENT';
 l_api_version    CONSTANT NUMBER := 1.0;
 l_return_status           VARCHAR2(1);
 l_sla_api_name            VARCHAR2(60);

BEGIN
   x_return_status := Okl_Api.START_ACTIVITY(l_api_name
                                             ,G_PKG_NAME
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);

    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

  WRITE_TO_LOG('');
  WRITE_TO_LOG('Inside the call to ' || l_api_name);

  WRITE_TO_LOG('Input Parameters: ');
  WRITE_TO_LOG('===================================');
  WRITE_TO_LOG('p_tcn_id              : ' || p_tcn_id);
  WRITE_TO_LOG('p_gl_date             : ' || p_gl_date);
  WRITE_TO_LOG('p_action_type         : ' || p_action_type);
  WRITE_TO_LOG('p_event_id            : ' || p_event_id);
  WRITE_TO_LOG('p_event_type_code     : ' || p_event_type_code);
  WRITE_TO_LOG('p_event_status_code   : ' || p_event_status_code);
  WRITE_TO_LOG('p_event_number        : ' || p_event_number);
  WRITE_TO_LOG('p_update_ref_info     : ' || p_update_ref_info);
  WRITE_TO_LOG('p_representation_code : ' || p_representation_code);

  OPEN get_tcn_csr;
  FETCH get_tcn_csr into get_tcn_rec;
  CLOSE get_tcn_csr;

  WRITE_TO_LOG('Contents of GET_TCN_REC:');
  WRITE_TO_LOG('===================================');
  WRITE_TO_LOG('get_tcn_rec.try_id          : ' || get_tcn_rec.try_id);
  WRITE_TO_LOG('get_tcn_rec.legal_entity_id : ' || get_tcn_rec.legal_entity_id);
  WRITE_TO_LOG('get_tcn_rec.set_of_books_id : ' || get_tcn_rec.set_of_books_id);
  WRITE_TO_LOG('get_tcn_rec.trx_number      : ' || get_tcn_rec.trx_number);
  WRITE_TO_LOG('get_tcn_rec.transaction_date: ' || get_tcn_rec.transaction_date);
  WRITE_TO_LOG('get_tcn_rec.cancelled_date  : ' || get_tcn_rec.cancelled_date);

  get_entity_event_class(p_try_id              =>    get_tcn_rec.try_id
						,p_action_type         =>    p_action_type
						,x_event_type_code     =>    l_event_type_code
                        ,x_entity_type_code    =>    l_entity_type_code
                        ,x_event_class_code    =>    l_event_class_code
                        ,x_return_status       =>    l_return_status);

  IF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
     RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;

  l_event_source_info.source_application_id := g_application_id;
  l_event_source_info.application_id        := g_application_id;
  l_event_source_info.legal_entity_id       := get_tcn_rec.legal_entity_id;
  l_event_source_info.ledger_id             := get_tcn_rec.set_of_books_id;
  l_event_source_info.entity_type_code      := l_entity_type_code;
  l_event_source_info.transaction_number    := get_tcn_rec.trx_number;
  l_event_source_info.source_id_int_1       := p_tcn_id;

  l_security_context.security_id_int_1      := mo_global.get_current_org_id();

  WRITE_TO_LOG('Contents of l_event_source_info :');
  WRITE_TO_LOG('===================================');
  WRITE_TO_LOG('l_event_source_info.source_application_id : ' ||
  l_event_source_info.source_application_id);
  WRITE_TO_LOG('l_event_source_info.application_id        : ' ||
  l_event_source_info.application_id);
  WRITE_TO_LOG('l_event_source_info.legal_entity_id       : ' ||
  l_event_source_info.legal_entity_id);
  WRITE_TO_LOG('l_event_source_info.ledger_id             : ' ||
  l_event_source_info.ledger_id);
  WRITE_TO_LOG('l_event_source_info.entity_type_code      : ' ||
  l_event_source_info.entity_type_code);
  WRITE_TO_LOG('l_event_source_info.transaction_number    : ' ||
  l_event_source_info.transaction_number);
  WRITE_TO_LOG('l_event_source_info.source_id_int_1       : ' ||
  l_event_source_info.source_id_int_1);

  IF p_action_type       = 'CREATE' THEN
     l_transaction_date := get_tcn_rec.transaction_date;
  ELSIF p_action_type    = 'REVERSE' THEN
     l_transaction_date := get_tcn_rec.cancelled_date;
  END IF;

  BEGIN
    IF NVL(p_update_ref_info, 'N') = 'N' AND p_event_number IS NULL THEN
      l_sla_api_name := 'UPDATE_EVENT';
     -- update one of event type, event status, event date
     xla_events_pub_pkg.update_event(p_event_source_info => l_event_source_info
                                    ,p_event_id          => p_event_id
                                    ,p_event_type_code   => p_event_type_code
                                    ,p_event_date        => p_gl_date
                                    ,p_event_status_code => p_event_status_code
                                    ,p_valuation_method  => p_representation_code
                                    ,p_security_context  => l_security_context
                                    ,p_transaction_date  => l_transaction_date);

    ELSIF NVL(p_update_ref_info, 'N') = 'N' AND p_event_number IS NOT NULL THEN
      l_sla_api_name := 'UPDATE_EVENT FOR EVENT NUMBER';
     -- update one of event type, event status, event date and event number
     xla_events_pub_pkg.update_event(p_event_source_info => l_event_source_info
	                                ,p_event_id          => p_event_id
	                                ,p_event_type_code   => p_event_type_code
	                                ,p_event_date        => p_gl_date
	                                ,p_event_status_code => p_event_status_code
	                                ,p_event_number      => p_event_number
	                                ,p_valuation_method  => p_representation_code
	                                ,p_security_context  => l_security_context
	                                ,p_transaction_date  => l_transaction_date);

    ELSIF NVL(p_update_ref_info, 'N') = 'Y' AND p_event_number IS NULL THEN
      l_sla_api_name := 'UPDATE_EVENT FOR REF INFO';
     -- update one of event type, event status, event date and reference info
     xla_events_pub_pkg.update_event(p_event_source_info => l_event_source_info
                                    ,p_event_id          => p_event_id
                                    ,p_event_type_code   => p_event_type_code
                                    ,p_event_date        => p_gl_date
                                    ,p_event_status_code => p_event_status_code
                                    ,p_reference_info    => p_reference_info
                                    ,p_valuation_method  => p_representation_code
                                    ,p_security_context  => l_security_context
                                    ,p_transaction_date  => l_transaction_date);

    ELSIF NVL(p_update_ref_info, 'N') = 'Y' AND p_event_number IS NOT NULL THEN
      l_sla_api_name := 'UPDATE_EVENT FOR EVENT NUMBER AND REF INFO';
     -- update one of event type, event status, event date, reference info and event number
     xla_events_pub_pkg.update_event(p_event_source_info => l_event_source_info
                                    ,p_event_id          => p_event_id
                                    ,p_event_type_code   => p_event_type_code
                                    ,p_event_date        => p_gl_date
                                    ,p_event_status_code => p_event_status_code
                                    ,p_event_number      => p_event_number
                                    ,p_reference_info    => p_reference_info
                                    ,p_valuation_method  => p_representation_code
                                    ,p_security_context  => l_security_context
                                    ,p_transaction_date  => l_transaction_date);

    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

	  RAISE Okl_Api.G_EXCEPTION_ERROR;
  END;

  Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  x_return_status := Okl_Api.G_RET_STS_SUCCESS;

  WRITE_TO_LOG('');
  WRITE_TO_LOG('Done with ' || l_api_name);

EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
     IF get_tcn_csr%ISOPEN THEN
	    CLOSE get_tcn_csr;
     END IF;

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');

  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
     IF get_tcn_csr%ISOPEN THEN
	    CLOSE get_tcn_csr;
     END IF;

      Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');

  WHEN OTHERS THEN
     IF get_tcn_csr%ISOPEN THEN
	    CLOSE get_tcn_csr;
     END IF;

     x_return_status := Okl_Api.HANDLE_EXCEPTIONS
                                     (l_api_name,
                                      G_PKG_NAME,
                                      'OTHERS',
                                      x_msg_count,
                                      x_msg_data,
                                      '_PVT');
END update_event;

-------------------------------------------------------------------------+
-- API to update the event date. This is called by Period Sweep Program.
-- p_gl_date represents the new event date that is stamped on events.

PROCEDURE update_event(
    p_api_version           IN  NUMBER
   ,p_init_msg_list         IN  VARCHAR2
   ,x_return_status         OUT NOCOPY VARCHAR2
   ,x_msg_count             OUT NOCOPY NUMBER
   ,x_msg_data              OUT NOCOPY VARCHAR2
   ,p_tcn_id                IN  NUMBER
   ,p_event_id              IN  NUMBER
   ,p_gl_date               IN  DATE) IS

 CURSOR get_tcn_csr is
 SELECT set_of_books_id,
        legal_entity_id,
        trunc(date_transaction_occurred) transaction_date,
        trunc(canceled_date) cancelled_date,
        trx_number,
        try_id,
		representation_code
   FROM okl_trx_contracts_all
  WHERE id = p_tcn_id;

 get_tcn_rec               get_tcn_csr%ROWTYPE;

 l_event_source_info       xla_events_pub_pkg.t_event_source_info;
 l_security_context        xla_events_pub_pkg.t_security;

 l_transaction_date        DATE;
 l_event_id                NUMBER;
 l_entity_type_code        VARCHAR2(30);
 l_event_class_code        VARCHAR2(30);
 l_event_type_code         VARCHAR2(30);

 l_api_name                VARCHAR2(20) := 'UPDATE_EVENT';
 l_api_version    CONSTANT NUMBER := 1.0;
 l_return_status           VARCHAR2(1);
 l_sla_api_name            VARCHAR2(60);

BEGIN
   x_return_status := Okl_Api.START_ACTIVITY(l_api_name
                                             ,G_PKG_NAME
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);

    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

  WRITE_TO_LOG('');
  WRITE_TO_LOG('Inside the call to ' || l_api_name);

  WRITE_TO_LOG('Input Parameters: ');
  WRITE_TO_LOG('===================================');
  WRITE_TO_LOG('p_tcn_id              : ' || p_tcn_id);
  WRITE_TO_LOG('p_event_id            : ' || p_event_id);
  WRITE_TO_LOG('p_gl_date             : ' || p_gl_date);

  OPEN get_tcn_csr;
  FETCH get_tcn_csr into get_tcn_rec;
  CLOSE get_tcn_csr;

  WRITE_TO_LOG('Contents of GET_TCN_REC:');
  WRITE_TO_LOG('===================================');
  WRITE_TO_LOG('get_tcn_rec.try_id          : ' || get_tcn_rec.try_id);
  WRITE_TO_LOG('get_tcn_rec.legal_entity_id : ' || get_tcn_rec.legal_entity_id);
  WRITE_TO_LOG('get_tcn_rec.set_of_books_id : ' || get_tcn_rec.set_of_books_id);
  WRITE_TO_LOG('get_tcn_rec.trx_number      : ' || get_tcn_rec.trx_number);
  WRITE_TO_LOG('get_tcn_rec.transaction_date: ' || get_tcn_rec.transaction_date);
  WRITE_TO_LOG('get_tcn_rec.cancelled_date  : ' || get_tcn_rec.cancelled_date);
  WRITE_TO_LOG('get_tcn_rec.representation_code  : ' || get_tcn_rec.representation_code);

  get_entity_event_class(p_try_id              =>    get_tcn_rec.try_id
						,p_action_type         =>    NULL
						,x_event_type_code     =>    l_event_type_code
                        ,x_entity_type_code    =>    l_entity_type_code
                        ,x_event_class_code    =>    l_event_class_code
                        ,x_return_status       =>    l_return_status);

  IF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
     RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;

  l_event_source_info.source_application_id := g_application_id;
  l_event_source_info.application_id        := g_application_id;
  l_event_source_info.legal_entity_id       := get_tcn_rec.legal_entity_id;
  l_event_source_info.ledger_id             := get_tcn_rec.set_of_books_id;
  l_event_source_info.entity_type_code      := l_entity_type_code;
  l_event_source_info.transaction_number    := get_tcn_rec.trx_number;
  l_event_source_info.source_id_int_1       := p_tcn_id;

  l_security_context.security_id_int_1      := mo_global.get_current_org_id();

  WRITE_TO_LOG('Contents of l_event_source_info :');
  WRITE_TO_LOG('===================================');
  WRITE_TO_LOG('l_event_source_info.source_application_id : ' ||
  l_event_source_info.source_application_id);
  WRITE_TO_LOG('l_event_source_info.application_id        : ' ||
  l_event_source_info.application_id);
  WRITE_TO_LOG('l_event_source_info.legal_entity_id       : ' ||
  l_event_source_info.legal_entity_id);
  WRITE_TO_LOG('l_event_source_info.ledger_id             : ' ||
  l_event_source_info.ledger_id);
  WRITE_TO_LOG('l_event_source_info.entity_type_code      : ' ||
  l_event_source_info.entity_type_code);
  WRITE_TO_LOG('l_event_source_info.transaction_number    : ' ||
  l_event_source_info.transaction_number);
  WRITE_TO_LOG('l_event_source_info.source_id_int_1       : ' ||
  l_event_source_info.source_id_int_1);

  BEGIN

     xla_events_pub_pkg.update_event(p_event_source_info => l_event_source_info
                                    ,p_event_id          => p_event_id
                                    ,p_event_date        => p_gl_date
                                    ,p_valuation_method  => get_tcn_rec.representation_code
                                    ,p_security_context  => l_security_context);

  EXCEPTION
    WHEN OTHERS THEN
      Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

	  RAISE Okl_Api.G_EXCEPTION_ERROR;
  END;

  Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  x_return_status := Okl_Api.G_RET_STS_SUCCESS;

  WRITE_TO_LOG('');
  WRITE_TO_LOG('Done with ' || l_api_name);

EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
     IF get_tcn_csr%ISOPEN THEN
	    CLOSE get_tcn_csr;
     END IF;

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');

  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
     IF get_tcn_csr%ISOPEN THEN
	    CLOSE get_tcn_csr;
     END IF;

      Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');

  WHEN OTHERS THEN
     IF get_tcn_csr%ISOPEN THEN
	    CLOSE get_tcn_csr;
     END IF;

     x_return_status := Okl_Api.HANDLE_EXCEPTIONS
                                     (l_api_name,
                                      G_PKG_NAME,
                                      'OTHERS',
                                      x_msg_count,
                                      x_msg_data,
                                      '_PVT');
END update_event;

-------------------------------------------------------------------------+
-- API to update the event status in bulk. If p_action_type is null, then
-- events for both create and reverse event types are updated.

PROCEDURE update_bulk_event_statuses(
    p_api_version        IN  NUMBER
   ,p_init_msg_list      IN  VARCHAR2
   ,x_return_status      OUT NOCOPY VARCHAR2
   ,x_msg_count          OUT NOCOPY NUMBER
   ,x_msg_data           OUT NOCOPY VARCHAR2
   ,p_tcn_tbl            IN  tcn_tbl_type
   ,p_try_id             IN  NUMBER
   ,p_ledger_id          IN  NUMBER
   ,p_action_type        IN  VARCHAR2
   ,p_event_status_code  IN  VARCHAR2) IS

l_entity_type_code       VARCHAR2(30);
l_event_class_code       VARCHAR2(30);
l_event_type_code        VARCHAR2(100);

 l_api_name                VARCHAR2(30) := 'UPDATE_BULK_EVENT_STATUSES';
 l_api_version    CONSTANT NUMBER := 1.0;
 l_event_id                NUMBER;
 l_sla_api_name            VARCHAR2(30);
 l_return_status           VARCHAR2(1);
BEGIN

   x_return_status := Okl_Api.START_ACTIVITY(l_api_name
                                             ,G_PKG_NAME
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);

    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

  WRITE_TO_LOG('');
  WRITE_TO_LOG('Inside the call to ' || l_api_name);

  WRITE_TO_LOG('Input Parameters: ');
  WRITE_TO_LOG('===================================');
  WRITE_TO_LOG('p_try_id              : ' || p_try_id);
  WRITE_TO_LOG('p_ledger_id           : ' || p_ledger_id);
  WRITE_TO_LOG('p_action_type         : ' || p_action_type);
  WRITE_TO_LOG('p_event_status_code   : ' || p_event_status_code);

  IF p_tcn_tbl.count > 0 THEN
    FOR i IN 1..p_tcn_tbl.COUNT LOOP
      WRITE_TO_LOG('p_tcn_tbl(' || i || ')            : ' || p_tcn_tbl(i));
    END LOOP;
  END IF;

  IF p_tcn_tbl.count = 0 THEN
     RETURN;
  END IF;

  -- if p_action_type is null, then l_event_type_code returned will be null.
  get_entity_event_class(p_try_id              =>    p_try_id
						,p_action_type         =>    p_action_type
						,x_event_type_code     =>    l_event_type_code
                        ,x_entity_type_code    =>    l_entity_type_code
                        ,x_event_class_code    =>    l_event_class_code
                        ,x_return_status       =>    l_return_status);

  IF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
     RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;

  FORALL i IN 1..p_tcn_tbl.COUNT
  INSERT INTO xla_events_int_gt(
	     application_id,
	     entity_code,
	     ledger_id,
	     event_id,
	     event_status_code)
  SELECT g_application_id,
	     l_entity_type_code,
	     p_ledger_id,
	     xe.event_id,
	     p_event_status_code
    FROM xla_events xe,
         xla_transaction_entities xte
   WHERE xe.entity_id = xte.entity_id
     AND xte.application_id = g_application_id
     AND xte.ledger_id = p_ledger_id
     AND xte.source_id_int_1 = p_tcn_tbl(i)
     AND xe.application_id = g_application_id
     AND xe.event_type_code = NVL(l_event_type_code, xe.event_type_code);

  BEGIN
    l_sla_api_name := 'UPDATE_BULK_EVENT_STATUSES';
    XLA_EVENTS_PUB_PKG.update_bulk_event_statuses(p_application_id => g_application_id);
  EXCEPTION
    WHEN OTHERS THEN
      Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

	  RAISE Okl_Api.G_EXCEPTION_ERROR;
  END;

  Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  x_return_status := Okl_Api.G_RET_STS_SUCCESS;

  WRITE_TO_LOG('');
  WRITE_TO_LOG('Done with ' || l_api_name);

EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');

  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');

  WHEN OTHERS THEN
     x_return_status := Okl_Api.HANDLE_EXCEPTIONS
                                     (l_api_name,
                                      G_PKG_NAME,
                                      'OTHERS',
                                      x_msg_count,
                                      x_msg_data,
                                      '_PVT');
END update_bulk_event_statuses;

-------------------------------------------------------------------------------
-- Event deletion routines
-------------------------------------------------------------------------------
-- API to delete a single unaccounted event based on event id.
PROCEDURE delete_event(
    p_api_version           IN  NUMBER
   ,p_init_msg_list         IN  VARCHAR2
   ,x_return_status         OUT NOCOPY VARCHAR2
   ,x_msg_count             OUT NOCOPY NUMBER
   ,x_msg_data              OUT NOCOPY VARCHAR2
   ,p_tcn_id                IN  NUMBER
   ,p_event_id              IN  NUMBER
   ,p_representation_code   IN  VARCHAR2) IS

 CURSOR get_tcn_csr is
 SELECT set_of_books_id,
        legal_entity_id,
        trunc(date_transaction_occurred) transaction_date,
        trunc(canceled_date) cancelled_date,
        trx_number,
        try_id
   FROM okl_trx_contracts
  WHERE id = p_tcn_id;

 get_tcn_rec               get_tcn_csr%ROWTYPE;

 l_event_source_info       xla_events_pub_pkg.t_event_source_info;
 l_security_context        xla_events_pub_pkg.t_security;

 l_transaction_date        DATE;
 l_event_id                NUMBER;
 l_entity_type_code        VARCHAR2(30);
 l_event_class_code        VARCHAR2(30);
 l_event_type_code         VARCHAR2(30);

 l_api_name                VARCHAR2(30) := 'DELETE_EVENT';
 l_api_version    CONSTANT NUMBER := 1.0;
 l_return_status           VARCHAR2(1);

BEGIN

   x_return_status := Okl_Api.START_ACTIVITY(l_api_name
                                             ,G_PKG_NAME
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);

    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

  WRITE_TO_LOG('');
  WRITE_TO_LOG('Inside the call to ' || l_api_name);

  WRITE_TO_LOG('Input Parameters: ');
  WRITE_TO_LOG('===================================');
  WRITE_TO_LOG('p_tcn_id              : ' || p_tcn_id);
  WRITE_TO_LOG('p_event_id            : ' || p_event_id);
  WRITE_TO_LOG('p_representation_code : ' || p_representation_code);

  OPEN get_tcn_csr;
  FETCH get_tcn_csr into get_tcn_rec;
  CLOSE get_tcn_csr;

  WRITE_TO_LOG('Contents of GET_TCN_REC:');
  WRITE_TO_LOG('===================================');
  WRITE_TO_LOG('get_tcn_rec.try_id          : ' || get_tcn_rec.try_id);
  WRITE_TO_LOG('get_tcn_rec.legal_entity_id : ' || get_tcn_rec.legal_entity_id);
  WRITE_TO_LOG('get_tcn_rec.set_of_books_id : ' || get_tcn_rec.set_of_books_id);
  WRITE_TO_LOG('get_tcn_rec.trx_number      : ' || get_tcn_rec.trx_number);
  WRITE_TO_LOG('get_tcn_rec.transaction_date: ' || get_tcn_rec.transaction_date);
  WRITE_TO_LOG('get_tcn_rec.cancelled_date  : ' || get_tcn_rec.cancelled_date);

  get_entity_event_class(p_try_id              =>    get_tcn_rec.try_id
						,p_action_type         =>    NULL
						,x_event_type_code     =>    l_event_type_code
                        ,x_entity_type_code    =>    l_entity_type_code
                        ,x_event_class_code    =>    l_event_class_code
                        ,x_return_status       =>    l_return_status);

  IF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
     RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;

  l_event_source_info.source_application_id := g_application_id;
  l_event_source_info.application_id        := g_application_id;
  l_event_source_info.legal_entity_id       := get_tcn_rec.legal_entity_id;
  l_event_source_info.ledger_id             := get_tcn_rec.set_of_books_id;
  l_event_source_info.entity_type_code      := l_entity_type_code;
  l_event_source_info.transaction_number    := get_tcn_rec.trx_number;
  l_event_source_info.source_id_int_1       := p_tcn_id;

  l_security_context.security_id_int_1         := mo_global.get_current_org_id();

  WRITE_TO_LOG('Contents of l_event_source_info :');
  WRITE_TO_LOG('===================================');
  WRITE_TO_LOG('l_event_source_info.source_application_id : ' ||
  l_event_source_info.source_application_id);
  WRITE_TO_LOG('l_event_source_info.application_id        : ' ||
  l_event_source_info.application_id);
  WRITE_TO_LOG('l_event_source_info.legal_entity_id       : ' ||
  l_event_source_info.legal_entity_id);
  WRITE_TO_LOG('l_event_source_info.ledger_id             : ' ||
  l_event_source_info.ledger_id);
  WRITE_TO_LOG('l_event_source_info.entity_type_code      : ' ||
  l_event_source_info.entity_type_code);
  WRITE_TO_LOG('l_event_source_info.transaction_number    : ' ||
  l_event_source_info.transaction_number);
  WRITE_TO_LOG('l_event_source_info.source_id_int_1       : ' ||
  l_event_source_info.source_id_int_1);

  BEGIN

  xla_events_pub_pkg.delete_event(p_event_source_info => l_event_source_info
                                 ,p_event_id          => p_event_id
                                 ,p_valuation_method  => p_representation_code
                                 ,p_security_context  => l_security_context);
  EXCEPTION
     WHEN OTHERS THEN
      Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

	  RAISE Okl_Api.G_EXCEPTION_ERROR;
  END;

  Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  x_return_status := Okl_Api.G_RET_STS_SUCCESS;

  WRITE_TO_LOG('');
  WRITE_TO_LOG('Done with ' || l_api_name);

EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
     IF get_tcn_csr%ISOPEN THEN
	    CLOSE get_tcn_csr;
     END IF;

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');

  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
     IF get_tcn_csr%ISOPEN THEN
	    CLOSE get_tcn_csr;
     END IF;

      Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');

  WHEN OTHERS THEN
     IF get_tcn_csr%ISOPEN THEN
	    CLOSE get_tcn_csr;
     END IF;

     x_return_status := Okl_Api.HANDLE_EXCEPTIONS
                                     (l_api_name,
                                      G_PKG_NAME,
                                      'OTHERS',
                                      x_msg_count,
                                      x_msg_data,
                                      '_PVT');
END delete_event;

-- API to delete all events for a transaction that meet the criteria. This
-- API deletes events that belong to the given event class, event type, and
-- event date. Returns number of events deleted. Returns -1 if an error occurs.
FUNCTION delete_events(
    p_api_version           IN  NUMBER
   ,p_init_msg_list         IN  VARCHAR2
   ,x_return_status         OUT NOCOPY VARCHAR2
   ,x_msg_count             OUT NOCOPY NUMBER
   ,x_msg_data              OUT NOCOPY VARCHAR2
   ,p_tcn_id                IN  NUMBER
   ,p_action_type           IN  VARCHAR2
   ,p_gl_date               IN  DATE
   ,p_representation_code   IN  VARCHAR2)
RETURN INTEGER IS

 CURSOR get_tcn_csr is
 SELECT set_of_books_id,
        legal_entity_id,
        TRUNC(date_transaction_occurred) transaction_date,
        TRUNC(canceled_date) cancelled_date,
        trx_number,
        try_id
   FROM okl_trx_contracts
  WHERE id = p_tcn_id;

 get_tcn_rec               get_tcn_csr%ROWTYPE;

 l_event_source_info       xla_events_pub_pkg.t_event_source_info;
 l_security_context        xla_events_pub_pkg.t_security;

 l_transaction_date        DATE;
 l_event_id                NUMBER;
 l_entity_type_code        VARCHAR2(30);
 l_event_class_code        VARCHAR2(30);
 l_event_type_code         VARCHAR2(30);

 l_api_name                VARCHAR2(30) := 'DELETE_EVENTS';
 l_api_version    CONSTANT NUMBER := 1.0;

 l_return_status           VARCHAR2(1);
 l_events_deleted          NUMBER;

BEGIN
   x_return_status := Okl_Api.START_ACTIVITY(l_api_name
                                             ,G_PKG_NAME
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);

    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

  WRITE_TO_LOG('');
  WRITE_TO_LOG('Inside the call to ' || l_api_name);

  WRITE_TO_LOG('Input Parameters: ');
  WRITE_TO_LOG('===================================');
  WRITE_TO_LOG('p_tcn_id              : ' || p_tcn_id);
  WRITE_TO_LOG('p_gl_date             : ' || p_gl_date);
  WRITE_TO_LOG('p_action_type         : ' || p_action_type);
  WRITE_TO_LOG('p_representation_code : ' || p_representation_code);

  OPEN get_tcn_csr;
  FETCH get_tcn_csr into get_tcn_rec;
  CLOSE get_tcn_csr;

  WRITE_TO_LOG('Contents of GET_TCN_REC:');
  WRITE_TO_LOG('===================================');
  WRITE_TO_LOG('get_tcn_rec.try_id          : ' || get_tcn_rec.try_id);
  WRITE_TO_LOG('get_tcn_rec.legal_entity_id : ' || get_tcn_rec.legal_entity_id);
  WRITE_TO_LOG('get_tcn_rec.set_of_books_id : ' || get_tcn_rec.set_of_books_id);
  WRITE_TO_LOG('get_tcn_rec.trx_number      : ' || get_tcn_rec.trx_number);
  WRITE_TO_LOG('get_tcn_rec.transaction_date: ' || get_tcn_rec.transaction_date);
  WRITE_TO_LOG('get_tcn_rec.cancelled_date  : ' || get_tcn_rec.cancelled_date);

  get_entity_event_class(p_try_id              =>    get_tcn_rec.try_id
						,p_action_type         =>    p_action_type
						,x_event_type_code     =>    l_event_type_code
                        ,x_entity_type_code    =>    l_entity_type_code
                        ,x_event_class_code    =>    l_event_class_code
                        ,x_return_status       =>    l_return_status);

  IF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
     RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;

  l_event_source_info.source_application_id := g_application_id;
  l_event_source_info.application_id        := g_application_id;
  l_event_source_info.legal_entity_id       := get_tcn_rec.legal_entity_id;
  l_event_source_info.ledger_id             := get_tcn_rec.set_of_books_id;
  l_event_source_info.entity_type_code      := l_entity_type_code;
  l_event_source_info.transaction_number    := get_tcn_rec.trx_number;
  l_event_source_info.source_id_int_1       := p_tcn_id;

  l_security_context.security_id_int_1      := mo_global.get_current_org_id();

  WRITE_TO_LOG('Contents of l_event_source_info :');
  WRITE_TO_LOG('===================================');
  WRITE_TO_LOG('l_event_source_info.source_application_id : ' ||
  l_event_source_info.source_application_id);
  WRITE_TO_LOG('l_event_source_info.application_id        : ' ||
  l_event_source_info.application_id);
  WRITE_TO_LOG('l_event_source_info.legal_entity_id       : ' ||
  l_event_source_info.legal_entity_id);
  WRITE_TO_LOG('l_event_source_info.ledger_id             : ' ||
  l_event_source_info.ledger_id);
  WRITE_TO_LOG('l_event_source_info.entity_type_code      : ' ||
  l_event_source_info.entity_type_code);
  WRITE_TO_LOG('l_event_source_info.transaction_number    : ' ||
  l_event_source_info.transaction_number);
  WRITE_TO_LOG('l_event_source_info.source_id_int_1       : ' ||
  l_event_source_info.source_id_int_1);

  IF p_action_type       = 'CREATE' THEN
     l_transaction_date := get_tcn_rec.transaction_date;
  ELSIF p_action_type    = 'REVERSE' THEN
     l_transaction_date := get_tcn_rec.cancelled_date;
  END IF;

  BEGIN
     l_events_deleted :=
         xla_events_pub_pkg.delete_events(p_event_source_info => l_event_source_info
                                         ,p_event_class_code  => l_event_class_code
                                         ,p_event_type_code   => l_event_type_code
                                         ,p_event_date        => p_gl_date
                                         ,p_valuation_method  => p_representation_code
                                         ,p_security_context  => l_security_context);
  EXCEPTION
    WHEN OTHERS THEN
      Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

	  RAISE Okl_Api.G_EXCEPTION_ERROR;
  END;

  Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  x_return_status := Okl_Api.G_RET_STS_SUCCESS;

  WRITE_TO_LOG('');
  WRITE_TO_LOG('Done with ' || l_api_name);

  return l_events_deleted;

EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
     IF get_tcn_csr%ISOPEN THEN
	    CLOSE get_tcn_csr;
     END IF;

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');
  return -1;
  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
     IF get_tcn_csr%ISOPEN THEN
	    CLOSE get_tcn_csr;
     END IF;

      Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');
  return -1;
  WHEN OTHERS THEN
     IF get_tcn_csr%ISOPEN THEN
	    CLOSE get_tcn_csr;
     END IF;

     x_return_status := Okl_Api.HANDLE_EXCEPTIONS
                                     (l_api_name,
                                      G_PKG_NAME,
                                      'OTHERS',
                                      x_msg_count,
                                      x_msg_data,
                                      '_PVT');

	 return -1;
END delete_events;

-------------------------------------------------------------------------------
-- Event information routines
-------------------------------------------------------------------------------
-- API to return the information about an event in a record structure.
FUNCTION get_event_info(
    p_api_version           IN  NUMBER
   ,p_init_msg_list         IN  VARCHAR2
   ,x_return_status         OUT NOCOPY VARCHAR2
   ,x_msg_count             OUT NOCOPY NUMBER
   ,x_msg_data              OUT NOCOPY VARCHAR2
   ,p_tcn_id                IN  NUMBER
   ,p_event_id              IN  NUMBER
   ,p_representation_code   IN  VARCHAR2)
 RETURN xla_events_pub_pkg.t_event_info IS

 CURSOR get_tcn_csr IS
 SELECT set_of_books_id,
        legal_entity_id,
        TRUNC(date_transaction_occurred) transaction_date,
        TRUNC(canceled_date) cancelled_date,
        trx_number,
        try_id
   FROM okl_trx_contracts
  WHERE id = p_tcn_id;

 get_tcn_rec               get_tcn_csr%ROWTYPE;

 l_event_source_info       xla_events_pub_pkg.t_event_source_info;
 l_security_context        xla_events_pub_pkg.t_security;
 l_event_info              xla_events_pub_pkg.t_event_info;

 l_entity_type_code        VARCHAR2(30);
 l_event_class_code        VARCHAR2(30);
 l_event_type_code         VARCHAR2(30);

 l_api_name                VARCHAR2(30) := 'GET_EVENT_INFO';
 l_api_version    CONSTANT NUMBER := 1.0;

 l_init_msg_list           VARCHAR2(2000) := OKL_API.G_TRUE;
 l_return_status           VARCHAR2(1);
 l_msg_count               NUMBER;
 l_msg_data                VARCHAR2(2000);

BEGIN
   x_return_status := Okl_Api.START_ACTIVITY(l_api_name
                                             ,G_PKG_NAME
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);

    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

  WRITE_TO_LOG('');
  WRITE_TO_LOG('Inside the call to ' || l_api_name);

  WRITE_TO_LOG('Input Parameters: ');
  WRITE_TO_LOG('===================================');
  WRITE_TO_LOG('p_tcn_id              : ' || p_tcn_id);
  WRITE_TO_LOG('p_event_id            : ' || p_event_id);
  WRITE_TO_LOG('p_representation_code : ' || p_representation_code);

  OPEN get_tcn_csr;
  FETCH get_tcn_csr into get_tcn_rec;
  CLOSE get_tcn_csr;

  WRITE_TO_LOG('Contents of GET_TCN_REC:');
  WRITE_TO_LOG('===================================');
  WRITE_TO_LOG('get_tcn_rec.try_id          : ' || get_tcn_rec.try_id);
  WRITE_TO_LOG('get_tcn_rec.legal_entity_id : ' || get_tcn_rec.legal_entity_id);
  WRITE_TO_LOG('get_tcn_rec.set_of_books_id : ' || get_tcn_rec.set_of_books_id);
  WRITE_TO_LOG('get_tcn_rec.trx_number      : ' || get_tcn_rec.trx_number);
  WRITE_TO_LOG('get_tcn_rec.transaction_date: ' || get_tcn_rec.transaction_date);
  WRITE_TO_LOG('get_tcn_rec.cancelled_date  : ' || get_tcn_rec.cancelled_date);

  get_entity_event_class(p_try_id              =>    get_tcn_rec.try_id
						,p_action_type         =>    NULL
						,x_event_type_code     =>    l_event_type_code
                        ,x_entity_type_code    =>    l_entity_type_code
                        ,x_event_class_code    =>    l_event_class_code
                        ,x_return_status       =>    l_return_status);

  IF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
     RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;

  l_event_source_info.source_application_id := g_application_id;
  l_event_source_info.application_id        := g_application_id;
  l_event_source_info.legal_entity_id       := get_tcn_rec.legal_entity_id;
  l_event_source_info.ledger_id             := get_tcn_rec.set_of_books_id;
  l_event_source_info.entity_type_code      := l_entity_type_code;
  l_event_source_info.transaction_number    := get_tcn_rec.trx_number;
  l_event_source_info.source_id_int_1       := p_tcn_id;

  l_security_context.security_id_int_1      := mo_global.get_current_org_id();

  WRITE_TO_LOG('Contents of l_event_source_info :');
  WRITE_TO_LOG('===================================');
  WRITE_TO_LOG('l_event_source_info.source_application_id : ' ||
  l_event_source_info.source_application_id);
  WRITE_TO_LOG('l_event_source_info.application_id        : ' ||
  l_event_source_info.application_id);
  WRITE_TO_LOG('l_event_source_info.legal_entity_id       : ' ||
  l_event_source_info.legal_entity_id);
  WRITE_TO_LOG('l_event_source_info.ledger_id             : ' ||
  l_event_source_info.ledger_id);
  WRITE_TO_LOG('l_event_source_info.entity_type_code      : ' ||
  l_event_source_info.entity_type_code);
  WRITE_TO_LOG('l_event_source_info.transaction_number    : ' ||
  l_event_source_info.transaction_number);
  WRITE_TO_LOG('l_event_source_info.source_id_int_1       : ' ||
  l_event_source_info.source_id_int_1);

  BEGIN
    l_event_info :=
       xla_events_pub_pkg.get_event_info(p_event_source_info => l_event_source_info
                                        ,p_event_id          => p_event_id
                                        ,p_valuation_method  => p_representation_code
                                        ,p_security_context  => l_security_context);
  EXCEPTION
    WHEN OTHERS THEN
      Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

	  RAISE Okl_Api.G_EXCEPTION_ERROR;
  END;

  Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  x_return_status := Okl_Api.G_RET_STS_SUCCESS;

  WRITE_TO_LOG('');
  WRITE_TO_LOG('Done with ' || l_api_name);

  return l_event_info;

EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
     IF get_tcn_csr%ISOPEN THEN
	    CLOSE get_tcn_csr;
     END IF;

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');
  RETURN NULL;
  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
     IF get_tcn_csr%ISOPEN THEN
	    CLOSE get_tcn_csr;
     END IF;

      Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');
  RETURN NULL;
  WHEN OTHERS THEN
     IF get_tcn_csr%ISOPEN THEN
	    CLOSE get_tcn_csr;
     END IF;

     x_return_status := Okl_Api.HANDLE_EXCEPTIONS
                                     (l_api_name,
                                      G_PKG_NAME,
                                      'OTHERS',
                                      x_msg_count,
                                      x_msg_data,
                                      '_PVT');

	 return NULL;
END get_event_info;

-- API to return information for one or more events within a transaction for
-- a given criteria. An array of records is returned with the event info.
-- If action_type is passed, then the events corresponding to that event_type
-- will be returned.
-- If p_action_type is null, then all events for that event class will be
-- returned.
-- If gl_date is passed, all events for the transaction matching event date will be
-- returned.
FUNCTION get_array_event_info(
    p_api_version           IN  NUMBER
   ,p_init_msg_list         IN  VARCHAR2
   ,x_return_status         OUT NOCOPY VARCHAR2
   ,x_msg_count             OUT NOCOPY NUMBER
   ,x_msg_data              OUT NOCOPY VARCHAR2
   ,p_tcn_id                IN  NUMBER
   ,p_action_type           IN  VARCHAR2
   ,p_gl_date               IN  DATE
   ,p_event_status_code     IN  VARCHAR2
   ,p_representation_code   IN  VARCHAR2)
RETURN xla_events_pub_pkg.t_array_event_info IS

 CURSOR get_tcn_csr is
 SELECT set_of_books_id,
        legal_entity_id,
        TRUNC(date_transaction_occurred) transaction_date,
        TRUNC(canceled_date) cancelled_date,
        trx_number,
        try_id
   FROM okl_trx_contracts
  WHERE id = p_tcn_id;

 get_tcn_rec               get_tcn_csr%ROWTYPE;

 l_event_source_info       xla_events_pub_pkg.t_event_source_info;
 l_security_context        xla_events_pub_pkg.t_security;
 l_array_event_info        xla_events_pub_pkg.t_array_event_info;
 l_array_event_info_null   xla_events_pub_pkg.t_array_event_info;

 l_entity_type_code        VARCHAR2(30);
 l_event_class_code        VARCHAR2(30);
 l_event_type_code         VARCHAR2(30);

 l_api_name                VARCHAR2(30) := 'GET_ARRAY_EVENT_INFO';
 l_api_version    CONSTANT NUMBER := 1.0;

 l_init_msg_list           VARCHAR2(2000) := OKL_API.G_FALSE;
 l_return_status           VARCHAR2(1);
 l_msg_count               NUMBER;
 l_msg_data                VARCHAR2(2000);


BEGIN
   x_return_status := Okl_Api.START_ACTIVITY(l_api_name
                                             ,G_PKG_NAME
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);

    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

  l_array_event_info_null := l_array_event_info;

  WRITE_TO_LOG('');
  WRITE_TO_LOG('Inside the call to ' || l_api_name);

  WRITE_TO_LOG('Input Parameters: ');
  WRITE_TO_LOG('===================================');
  WRITE_TO_LOG('p_tcn_id              : ' || p_tcn_id);
  WRITE_TO_LOG('p_gl_date             : ' || p_gl_date);
  WRITE_TO_LOG('p_action_type         : ' || p_action_type);
  WRITE_TO_LOG('p_event_status_code   : ' || p_event_status_code);
  WRITE_TO_LOG('p_representation_code : ' || p_representation_code);

  OPEN get_tcn_csr;
  FETCH get_tcn_csr into get_tcn_rec;
  CLOSE get_tcn_csr;

  WRITE_TO_LOG('Contents of GET_TCN_REC:');
  WRITE_TO_LOG('===================================');
  WRITE_TO_LOG('get_tcn_rec.try_id          : ' || get_tcn_rec.try_id);
  WRITE_TO_LOG('get_tcn_rec.legal_entity_id : ' || get_tcn_rec.legal_entity_id);
  WRITE_TO_LOG('get_tcn_rec.set_of_books_id : ' || get_tcn_rec.set_of_books_id);
  WRITE_TO_LOG('get_tcn_rec.trx_number      : ' || get_tcn_rec.trx_number);
  WRITE_TO_LOG('get_tcn_rec.transaction_date: ' || get_tcn_rec.transaction_date);
  WRITE_TO_LOG('get_tcn_rec.cancelled_date  : ' || get_tcn_rec.cancelled_date);

  get_entity_event_class(p_try_id              =>    get_tcn_rec.try_id
						,p_action_type         =>    p_action_type
						,x_event_type_code     =>    l_event_type_code
                        ,x_entity_type_code    =>    l_entity_type_code
                        ,x_event_class_code    =>    l_event_class_code
                        ,x_return_status       =>    l_return_status);

  IF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
     RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;

  l_event_source_info.source_application_id := g_application_id;
  l_event_source_info.application_id        := g_application_id;
  l_event_source_info.legal_entity_id       := get_tcn_rec.legal_entity_id;
  l_event_source_info.ledger_id             := get_tcn_rec.set_of_books_id;
  l_event_source_info.entity_type_code      := l_entity_type_code;
  l_event_source_info.transaction_number    := get_tcn_rec.trx_number;
  l_event_source_info.source_id_int_1       := p_tcn_id;

  l_security_context.security_id_int_1      := mo_global.get_current_org_id();

  WRITE_TO_LOG('Contents of l_event_source_info :');
  WRITE_TO_LOG('===================================');
  WRITE_TO_LOG('l_event_source_info.source_application_id : ' ||
  l_event_source_info.source_application_id);
  WRITE_TO_LOG('l_event_source_info.application_id        : ' ||
  l_event_source_info.application_id);
  WRITE_TO_LOG('l_event_source_info.legal_entity_id       : ' ||
  l_event_source_info.legal_entity_id);
  WRITE_TO_LOG('l_event_source_info.ledger_id             : ' ||
  l_event_source_info.ledger_id);
  WRITE_TO_LOG('l_event_source_info.entity_type_code      : ' ||
  l_event_source_info.entity_type_code);
  WRITE_TO_LOG('l_event_source_info.transaction_number    : ' ||
  l_event_source_info.transaction_number);
  WRITE_TO_LOG('l_event_source_info.source_id_int_1       : ' ||
  l_event_source_info.source_id_int_1);

  BEGIN
    l_array_event_info :=
     xla_events_pub_pkg.get_array_event_info(p_event_source_info => l_event_source_info
                                            ,p_event_class_code  => l_event_class_code
                                            ,p_event_type_code   => l_event_type_code
                                            ,p_event_date        => p_gl_date
                                            ,p_event_status_code => p_event_status_code
                                            ,p_valuation_method  => p_representation_code
                                            ,p_security_context  => l_security_context);
  EXCEPTION
    WHEN OTHERS THEN
      Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

	  RAISE Okl_Api.G_EXCEPTION_ERROR;
  END;

  Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  x_return_status := Okl_Api.G_RET_STS_SUCCESS;

  WRITE_TO_LOG('');
  WRITE_TO_LOG('Done with ' || l_api_name);

  RETURN l_array_event_info;

EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
     IF get_tcn_csr%ISOPEN THEN
	    CLOSE get_tcn_csr;
     END IF;

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');
  RETURN l_array_event_info_null;
  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
     IF get_tcn_csr%ISOPEN THEN
	    CLOSE get_tcn_csr;
     END IF;

      Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');
  RETURN l_array_event_info_null;
  WHEN OTHERS THEN
     IF get_tcn_csr%ISOPEN THEN
	    CLOSE get_tcn_csr;
     END IF;

     x_return_status := Okl_Api.HANDLE_EXCEPTIONS
                                     (l_api_name,
                                      G_PKG_NAME,
                                      'OTHERS',
                                      x_msg_count,
                                      x_msg_data,
                                      '_PVT');
  RETURN l_array_event_info_null;
END get_array_event_info;

-- API to provide the status for a given event.
FUNCTION get_event_status(
    p_api_version           IN  NUMBER
   ,p_init_msg_list         IN  VARCHAR2
   ,x_return_status         OUT NOCOPY VARCHAR2
   ,x_msg_count             OUT NOCOPY NUMBER
   ,x_msg_data              OUT NOCOPY VARCHAR2
   ,p_tcn_id                IN  NUMBER
   ,p_event_id              IN  NUMBER
   ,p_representation_code   IN  VARCHAR2)
 RETURN VARCHAR2 IS

 CURSOR get_tcn_csr is
 SELECT set_of_books_id,
        legal_entity_id,
        TRUNC(date_transaction_occurred) transaction_date,
        TRUNC(canceled_date) cancelled_date,
        trx_number,
        try_id
   FROM okl_trx_contracts
  WHERE id = p_tcn_id;

 get_tcn_rec               get_tcn_csr%ROWTYPE;

 l_event_source_info       xla_events_pub_pkg.t_event_source_info;
 l_security_context        xla_events_pub_pkg.t_security;

 l_entity_type_code        VARCHAR2(30);
 l_event_class_code        VARCHAR2(30);
 l_event_type_code         VARCHAR2(30);
 l_event_status_code       VARCHAR2(10);

 l_api_name                VARCHAR2(30) := 'GET_EVENT_STATUS';
 l_api_version    CONSTANT NUMBER := 1.0;

 l_init_msg_list           VARCHAR2(2000) := OKL_API.G_FALSE;
 l_return_status           VARCHAR2(1);
 l_msg_count               NUMBER;
 l_msg_data                VARCHAR2(2000);


BEGIN
   x_return_status := Okl_Api.START_ACTIVITY(l_api_name
                                             ,G_PKG_NAME
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);

    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

  WRITE_TO_LOG('');
  WRITE_TO_LOG('Inside the call to ' || l_api_name);

  WRITE_TO_LOG('Input Parameters: ');
  WRITE_TO_LOG('===================================');
  WRITE_TO_LOG('p_tcn_id              : ' || p_tcn_id);
  WRITE_TO_LOG('p_event_id            : ' || p_event_id);
  WRITE_TO_LOG('p_representation_code : ' || p_representation_code);

  OPEN get_tcn_csr;
  FETCH get_tcn_csr into get_tcn_rec;
  CLOSE get_tcn_csr;

  WRITE_TO_LOG('Contents of GET_TCN_REC:');
  WRITE_TO_LOG('===================================');
  WRITE_TO_LOG('get_tcn_rec.try_id          : ' || get_tcn_rec.try_id);
  WRITE_TO_LOG('get_tcn_rec.legal_entity_id : ' || get_tcn_rec.legal_entity_id);
  WRITE_TO_LOG('get_tcn_rec.set_of_books_id : ' || get_tcn_rec.set_of_books_id);
  WRITE_TO_LOG('get_tcn_rec.trx_number      : ' || get_tcn_rec.trx_number);
  WRITE_TO_LOG('get_tcn_rec.transaction_date: ' || get_tcn_rec.transaction_date);
  WRITE_TO_LOG('get_tcn_rec.cancelled_date  : ' || get_tcn_rec.cancelled_date);

  get_entity_event_class(p_try_id              =>    get_tcn_rec.try_id
						,p_action_type         =>    NULL
						,x_event_type_code     =>    l_event_type_code
                        ,x_entity_type_code    =>    l_entity_type_code
                        ,x_event_class_code    =>    l_event_class_code
                        ,x_return_status       =>    l_return_status);

  IF l_return_status = Okl_Api.G_RET_STS_ERROR THEN
     RAISE Okl_Api.G_EXCEPTION_ERROR;
  END IF;

  l_event_source_info.source_application_id := g_application_id;
  l_event_source_info.application_id        := g_application_id;
  l_event_source_info.legal_entity_id       := get_tcn_rec.legal_entity_id;
  l_event_source_info.ledger_id             := get_tcn_rec.set_of_books_id;
  l_event_source_info.entity_type_code      := l_entity_type_code;
  l_event_source_info.transaction_number    := get_tcn_rec.trx_number;
  l_event_source_info.source_id_int_1       := p_tcn_id;

  l_security_context.security_id_int_1      := mo_global.get_current_org_id();

  WRITE_TO_LOG('Contents of l_event_source_info :');
  WRITE_TO_LOG('===================================');
  WRITE_TO_LOG('l_event_source_info.source_application_id : ' ||
  l_event_source_info.source_application_id);
  WRITE_TO_LOG('l_event_source_info.application_id        : ' ||
  l_event_source_info.application_id);
  WRITE_TO_LOG('l_event_source_info.legal_entity_id       : ' ||
  l_event_source_info.legal_entity_id);
  WRITE_TO_LOG('l_event_source_info.ledger_id             : ' ||
  l_event_source_info.ledger_id);
  WRITE_TO_LOG('l_event_source_info.entity_type_code      : ' ||
  l_event_source_info.entity_type_code);
  WRITE_TO_LOG('l_event_source_info.transaction_number    : ' ||
  l_event_source_info.transaction_number);
  WRITE_TO_LOG('l_event_source_info.source_id_int_1       : ' ||
  l_event_source_info.source_id_int_1);

  BEGIN
    l_event_status_code :=
       xla_events_pub_pkg.get_event_status(p_event_source_info => l_event_source_info
                                          ,p_event_id          => p_event_id
                                          ,p_valuation_method  => p_representation_code
                                          ,p_security_context  => l_security_context);
  EXCEPTION
    WHEN OTHERS THEN
      Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

	  RAISE Okl_Api.G_EXCEPTION_ERROR;
  END;

  Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  x_return_status := Okl_Api.G_RET_STS_SUCCESS;

  WRITE_TO_LOG('');
  WRITE_TO_LOG('Done with ' || l_api_name);

  RETURN l_event_status_code;

EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
     IF get_tcn_csr%ISOPEN THEN
	    CLOSE get_tcn_csr;
     END IF;

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');
  RETURN 'F';
  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
     IF get_tcn_csr%ISOPEN THEN
	    CLOSE get_tcn_csr;
     END IF;

      Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(l_api_name
                                 ,g_pkg_name
                                 ,'OKL_API.G_RET_STS_UNEXP_ERROR'
                                 ,x_msg_count
                                 ,x_msg_data
                                 ,'_PVT');
  RETURN 'F';
  WHEN OTHERS THEN
     IF get_tcn_csr%ISOPEN THEN
	    CLOSE get_tcn_csr;
     END IF;

     x_return_status := Okl_Api.HANDLE_EXCEPTIONS
                                     (l_api_name,
                                      G_PKG_NAME,
                                      'OTHERS',
                                      x_msg_count,
                                      x_msg_data,
                                      '_PVT');
  RETURN 'F';
END get_event_status;

-- API to check if an event has been raised for the transaction.
-- If p_action_type is passed, corresponding event for Create or Reverse
-- action will be identified, otherwise existence of event for the transaction
-- is checked and value returned.
PROCEDURE event_exists(p_api_version        IN  NUMBER
                      ,p_init_msg_list      IN  VARCHAR2
                      ,x_return_status      OUT NOCOPY VARCHAR2
                      ,x_msg_count          OUT NOCOPY NUMBER
                      ,x_msg_data           OUT NOCOPY VARCHAR2
                      ,p_tcn_id             IN  NUMBER
                      ,p_action_type        IN  VARCHAR2
                      ,x_event_id           OUT NOCOPY NUMBER
                      ,x_event_date         OUT NOCOPY DATE)
IS

TYPE event_ref_csr IS REF CURSOR;

get_event_csr     event_ref_csr;

l_api_name                VARCHAR2(30) := 'EVENT_EXISTS';
l_api_version    CONSTANT NUMBER := 1.0;

BEGIN
   x_return_status := Okl_Api.START_ACTIVITY(l_api_name
                                             ,G_PKG_NAME
                                             ,p_init_msg_list
                                             ,l_api_version
                                             ,p_api_version
                                             ,'_PVT'
                                             ,x_return_status);

    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_Status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

  WRITE_TO_LOG('');
  WRITE_TO_LOG('Inside the call to ' || l_api_name);

  WRITE_TO_LOG('Input Parameters: ');
  WRITE_TO_LOG('===================================');
  WRITE_TO_LOG('p_tcn_id              : ' || p_tcn_id);
  WRITE_TO_LOG('p_action_type         : ' || p_action_type);

  IF p_action_type = 'CREATE' THEN
    OPEN get_event_csr FOR
    SELECT accounting_event_id, gl_date
      FROM okl_trns_acc_dstrs
     WHERE original_dist_id IS NULL
       AND source_table = 'OKL_TXL_CNTRCT_LNS'
       AND source_id = (SELECT id
                          FROM okl_txl_cntrct_lns
                         WHERE tcn_id = p_tcn_id
                           AND rownum = 1)
       AND accounting_event_id is not null
       AND rownum = 1;
  ELSIF p_action_type = 'REVERSE' THEN
    OPEN get_event_csr FOR
    SELECT accounting_event_id, gl_date
      FROM okl_trns_acc_dstrs
     WHERE original_dist_id IS NOT NULL
       AND source_table = 'OKL_TXL_CNTRCT_LNS'
       AND source_id = (SELECT id
                          FROM okl_txl_cntrct_lns
                         WHERE tcn_id = p_tcn_id
                           AND rownum = 1)
       AND accounting_event_id IS NOT NULL
       AND rownum = 1;
   ELSE
    OPEN get_event_csr FOR
    SELECT accounting_event_id, gl_date
      FROM okl_trns_acc_dstrs
     WHERE source_table = 'OKL_TXL_CNTRCT_LNS'
       AND source_id = (SELECT id
                          FROM okl_txl_cntrct_lns
                         WHERE tcn_id = p_tcn_id
                           AND rownum = 1)
       AND accounting_event_id IS NOT NULL
       AND rownum = 1;
  END IF;

  IF get_event_csr%ISOPEN THEN
    FETCH get_event_csr into x_event_id, x_event_date;
    CLOSE get_event_csr;
  END IF;

  Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  x_return_status := Okl_Api.G_RET_STS_SUCCESS;

  WRITE_TO_LOG('');
  WRITE_TO_LOG('Done with ' || l_api_name);

EXCEPTION
  WHEN OTHERS THEN
    IF get_event_csr%ISOPEN THEN
       CLOSE get_event_csr;
    END IF;

     x_return_status := Okl_Api.HANDLE_EXCEPTIONS
                                     (l_api_name,
                                      G_PKG_NAME,
                                      'OTHERS',
                                      x_msg_count,
                                      x_msg_data,
                                      '_PVT');

END event_exists;

END OKL_XLA_EVENTS_PVT;

/
