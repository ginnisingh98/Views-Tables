--------------------------------------------------------
--  DDL for Package Body OKL_SUBSIDY_POOL_RPT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SUBSIDY_POOL_RPT_PVT" AS
  /* $Header: OKLRSIOB.pls 120.15 2007/01/09 12:37:08 udhenuko noship $ */

G_WF_EVT_POOL_NEAR_EXPIR CONSTANT wf_events.name%TYPE DEFAULT 'oracle.apps.okl.subsidy_pool.pool_nearing_expiration';
G_WF_EVT_POOL_NEAR_BUDGLMT CONSTANT wf_events.name%TYPE DEFAULT 'oracle.apps.okl.subsidy_pool.pool_nearing_bdgt_limit';
G_WF_ITM_SUB_POOL_ID  CONSTANT VARCHAR2(30)       := 'SUBSIDY_POOL_ID';

-------------------------------------------------------------------------------
-- PROCEDURE raise_business_event
-------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : raise_business_event
-- Description     : This procedure is a wrapper that raises a business event
--                 : when ever a subsidy pool record is submitted for approval, approved, rejected
-- Business Rules  : the event is raised based on the decision_status_code passed and
--                   successful updation of the pool record
-- Parameters      :
-- Version         : 1.0
-- History         :
-- End of comments
-----------------------------------------------------------------------------------------
PROCEDURE raise_business_event(p_api_version IN NUMBER,
                               p_init_msg_list IN VARCHAR2,
                               x_return_status OUT NOCOPY VARCHAR2,
                               x_msg_count OUT NOCOPY NUMBER,
                               x_msg_data OUT NOCOPY VARCHAR2,
                               p_event_name IN VARCHAR2,
                               p_event_param_list IN WF_PARAMETER_LIST_T
                               ) IS
  l_event_param_list WF_PARAMETER_LIST_T;
BEGIN
  x_return_status := OKL_API.G_RET_STS_SUCCESS;
  l_event_param_list := p_event_param_list;

  OKL_WF_PVT.raise_event(p_api_version    => p_api_version,
                         p_init_msg_list  => p_init_msg_list,
                         x_return_status  => x_return_status,
                         x_msg_count      => x_msg_count,
                         x_msg_data       => x_msg_data,
                         p_event_name     => p_event_name,
                         p_parameters     => l_event_param_list);
EXCEPTION
  WHEN OTHERS THEN
  x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
END raise_business_event;

  ---------------------------------------------------------------------------
  -- FUNCTION GET_PROPER_LENGTH
  ---------------------------------------------------------------------------
---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : GET_PROPER_LENGTH
  -- Description     : function to display the record with their proper lengths.
  --                   If they exceed the specified length then truncate it.
  -- Business Rules  :
  -- Parameters      : p_input_data, p_input_length, p_input_type
  -- Version         : 1.0
  -- History         : 08-Mar-2005 ABINDAL created.
  -- End of comments
  ---------------------------------------------------------------------------

FUNCTION  GET_PROPER_LENGTH(p_input_data          IN   VARCHAR2,
                            p_input_length        IN   NUMBER,
				    p_input_type          IN   VARCHAR2)
RETURN VARCHAR2

IS

x_return_data VARCHAR2(1000);

BEGIN

IF (p_input_type = 'TITLE') THEN
    IF (p_input_data IS NOT NULL) THEN
     x_return_data := RPAD(SUBSTR(ltrim(rtrim(p_input_data)),1,p_input_length),p_input_length,' ');
    ELSE
     x_return_data := RPAD(' ',p_input_length,' ');
    END IF;
ELSE
    IF (p_input_data IS NOT NULL) THEN
         IF (length(p_input_data) > p_input_length) THEN
             x_return_data := SUBSTR(p_input_data,1,p_input_length);
         ELSE
             x_return_data := RPAD(p_input_data,p_input_length,' ');
         END IF;
    ELSE
         x_return_data := RPAD(' ',p_input_length,' ');
    END IF;
END IF;

RETURN x_return_data;

END GET_PROPER_LENGTH;

---------------------------------------------------------------------------
  -- FUNCTION CURRENCY_CONVERSION
  ---------------------------------------------------------------------------
---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : CURRENCY_CONVERSION
  -- Description     : To convert the given amount in one currency to
  --                   the amount in other currency.
  -- Business Rules  :
  -- Parameters      : p_amount, p_from_currency_code,p_to_currency_code
  --                   p_conv_type, p_conv_date,x_conv_rate.
  -- Version         : 1.0
  -- History         : 08-Mar-2005 ABINDAL created.
  -- End of comments
  ---------------------------------------------------------------------------
FUNCTION currency_conversion (p_amount             IN NUMBER,
                              p_from_currency_code IN VARCHAR2,
                              p_to_currency_code   IN VARCHAR2,
                              p_conv_type          IN VARCHAR2,
                              p_conv_date          IN DATE,
                              x_conv_rate          OUT NOCOPY NUMBER)
RETURN NUMBER
IS

  l_api_version	     		 NUMBER ;
  l_init_msg_list       VARCHAR2(1) ;
  l_return_status     	 VARCHAR2(1);
  l_msg_count           NUMBER ;
  l_msg_data	         	 VARCHAR2(2000);
  l_conv_rate           NUMBER ;
  l_round_amount        NUMBER ;
  l_amount              NUMBER ;
  l_api_name            CONSTANT VARCHAR2(30) DEFAULT 'CURRENCY_CONVERSION';
  l_conv_date           DATE ;
  l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_SUBSIDY_POOL_RPT_PVT.CURRENCY_CONVERSION';
  l_debug_enabled       VARCHAR2(10);
  is_debug_procedure_on BOOLEAN;
  is_debug_statement_on BOOLEAN;

BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);

    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRSIOB.pls call currency_conversion');
    END IF;
    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);

   l_api_version := 1.0;
   l_init_msg_list := Okl_Api.g_false;
   l_msg_count := 0;
   l_conv_rate := 0;
   l_round_amount := 0;
   l_amount := 0;
   l_conv_date := TRUNC(SYSDATE);

   l_return_status := OKL_API.START_ACTIVITY( l_api_name,
                                              G_PKG_NAME,
                                              l_init_msg_list,
                                              l_api_version,
                                              l_api_version,
                                              '_PVT',
                                              l_return_status);

   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   IF(p_conv_date is null) THEN
      l_conv_date := TRUNC(SYSDATE);
   ELSE
      l_conv_date := TRUNC(p_conv_date);
   END IF;
   l_conv_rate := 0;
   l_round_amount := 0;
   l_amount := 0;
   -- If both the from currency code and to currency code are equal, there is no need
   -- for conversion. simply return back the amount.
   IF( p_from_currency_code <> p_to_currency_code) THEN
      -- get the currency conversion rate.
      okl_accounting_util.get_curr_con_rate(p_api_version     => l_api_version
                                            ,p_init_msg_list  => l_init_msg_list
                                            ,x_return_status  => l_return_status
                                            ,x_msg_count      => l_msg_count
                                            ,x_msg_data       => l_msg_data
                                            ,p_from_curr_code => p_from_currency_code
                                            ,p_to_curr_code   => p_to_currency_code
                                            ,p_con_date       => l_conv_date
                                            ,p_con_type       => p_conv_type
                                            ,x_conv_rate      => l_conv_rate
                                           );
    IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
       okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                               l_module,
                               'p_from_currency_code '||p_from_currency_code||' p_to_currency_code '
                               ||p_to_currency_code||' l_conv_date '||l_conv_date||'p_conv_type'||p_conv_type
                               ||'l_conv_rate'||l_conv_rate
                               );
    END IF; -- end of NVL(l_debug_enabled,'N')='Y'

      IF(l_conv_rate IS NULL OR l_conv_rate <= 0)THEN
        return -1;
      END IF;
      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- calculate the amount in terms of the required currency, by multiplying the rate with the given amount.
      x_conv_rate := l_conv_rate;
      l_amount := NVL(p_amount,0) *  l_conv_rate;
      -- Then round of this converted amount.
      okl_accounting_util.cross_currency_round_amount(p_api_version     => l_api_version
                                                      ,p_init_msg_list  => l_init_msg_list
                                                      ,x_return_status  => l_return_status
                                                      ,x_msg_count      => l_msg_count
                                                      ,x_msg_data       => l_msg_data
                                                      ,p_amount         => l_amount
                                                      ,p_currency_code  => p_to_currency_code
                                                      ,x_rounded_amount => l_round_amount
                                                     );
    IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
       okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                               l_module,
                               'l_amount '||l_amount||' l_round_amount '||l_round_amount
                               );
    END IF; -- end of NVL(l_debug_enabled,'N')='Y'

      IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
   ELSE
     l_round_amount := NVL(p_amount,0);
     x_conv_rate := 1;
   END IF;
   okl_api.END_ACTIVITY(l_msg_count, l_msg_data);
   RETURN l_round_amount;
   IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
     okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRSIOB.pls call currency_conversion');
   END IF;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      l_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => l_msg_count,
                           x_msg_data  => l_msg_data,
                           p_api_type  => g_api_type);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      l_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => l_msg_count,
                           x_msg_data  => l_msg_data,
                           p_api_type  => g_api_type);

    WHEN OTHERS THEN
      l_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => l_msg_count,
                           x_msg_data  => l_msg_data,
                           p_api_type  => g_api_type);
END currency_conversion;

  ---------------------------------------------------------------------------
  -- FUNCTION TOTAL_BUDGETS
  ---------------------------------------------------------------------------
---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : TOTAL_BUDGETS
  -- Description     : To calculate the total budgets of a subsidy pool
  --                   till the specified date.
  -- Business Rules  :
  -- Parameters      : p_pool_id, p_input_date, p_from_currency_code
  --                   p_to_currency_code, p_conversion_type
  -- Version         : 1.0
  -- History         : 08-Mar-2005 ABINDAL created.
  -- End of comments
  ---------------------------------------------------------------------------
FUNCTION   total_budgets  (p_pool_id            IN   VARCHAR2,
                           p_to_date            IN DATE,
                           p_from_currency_code IN   VARCHAR2,
                           p_to_currency_code   IN   VARCHAR2,
                           p_conversion_type    IN VARCHAR2,
                           x_return_status      OUT NOCOPY VARCHAR2,
                           x_msg_count          OUT NOCOPY NUMBER,
                           x_msg_data           OUT NOCOPY VARCHAR2 )
  RETURN NUMBER
IS

  CURSOR c_total_budget(cp_pool_id VARCHAR2, cp_to_date DATE)IS
  SELECT budget_type_code,
         budget_amount,
         decision_status_code,
         effective_from_date
  FROM   okl_subsidy_pool_budgets_b
  WHERE  subsidy_pool_id = cp_pool_id
  AND    TRUNC(effective_from_date) <= NVL(TRUNC(cp_to_date),TRUNC(effective_from_date));

  l_total_budget        NUMBER ;
  l_amount              NUMBER ;
  l_conv_rate           NUMBER ;
  l_api_name            CONSTANT VARCHAR2(30) := 'total_budgets';
  l_msg_count	          NUMBER ;
  l_msg_data	           VARCHAR2(2000);
  l_return_status     	 VARCHAR2(1);
  l_api_version			      NUMBER ;
  l_init_msg_list       VARCHAR2(1) ;
  l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_SUBSIDY_POOL_RPT_PVT.TOTAL_BUDGETS';
  l_debug_enabled       VARCHAR2(10);
  is_debug_procedure_on BOOLEAN;
  is_debug_statement_on BOOLEAN;
BEGIN
    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);

    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRSIOB.pls call total_budgets');
    END IF;
    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);

   l_api_version := 1.0;
   l_init_msg_list := Okl_Api.g_false;
   l_msg_count := 0;
   l_total_budget := 0;
   l_amount := 0;
   l_conv_rate := 0;

   l_return_status := OKL_API.START_ACTIVITY( l_api_name,
                                              G_PKG_NAME,
                                              l_init_msg_list,
                                              l_api_version,
                                              l_api_version,
                                              '_PVT',
                                              l_return_status);

   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

  l_total_budget := 0;
  -- Get the total budgets for the subsidy pool till the p_input_date specified.
  FOR each_row IN c_total_budget(p_pool_id,p_to_date)
    LOOP
       l_amount := 0;
       -- Convert the budget line amount, from its subsidy pool currency to the Parent pool currency
       -- entered by the user. The currency conversion rate will be derived based on the effective from
       -- date of the respective budget lines.
       l_amount := currency_conversion( each_row.budget_amount,
                                        p_from_currency_code,
                                        p_to_currency_code,
                                        p_conversion_type,
                                        each_row.effective_from_date,
                                        l_conv_rate
                                       );
       IF (l_amount < 0) THEN
         fnd_message.set_name(G_APP_NAME,
                              'OKL_POOL_CURR_CONV');
         fnd_message.set_token('FROM_CURR',
                               p_from_currency_code);
         fnd_message.set_token('TO_CURR',
                               p_to_currency_code);
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get);
       END IF;

       IF (each_row.budget_type_code = 'ADDITION' AND each_row.decision_status_code = 'ACTIVE') THEN
          l_total_budget := l_total_budget + l_amount;
       ELSIF(each_row.budget_type_code = 'REDUCTION' AND (each_row.decision_status_code IN ('ACTIVE', 'PENDING'))) THEN
          l_total_budget := l_total_budget - l_amount;
       END IF;

      IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                 l_module,
                                 'l_amount '||l_amount||' l_total_budget '||l_total_budget
                                 );
      END IF; -- end of NVL(l_debug_enabled,'N')='Y'

    END LOOP;
   okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
   x_return_status := l_return_status;
   x_msg_data      := l_msg_data;
   x_msg_count     := l_msg_count;
   RETURN l_total_budget;

   IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
     okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRSIOB.pls call total_budgets');
   END IF;

  EXCEPTION
     WHEN G_EXCEPTION_HALT_VALIDATION THEN
         x_return_status	:= OKL_API.HANDLE_EXCEPTIONS
       (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
       );

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);

END total_budgets;

  ---------------------------------------------------------------------------
  -- FUNCTION TRANSACTION_AMOUNT
  ---------------------------------------------------------------------------
---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : TRANSACTION_AMOUNT
  -- Description     : To get the total transaction amount for the subsidy
  --                   pool till the specified date.
  -- Business Rules  :
  -- Parameters      : p_pool_id, p_input_date, p_from_currency_code
  --                   p_to_currency_code, p_conversion_type
  -- Version         : 1.0
  -- History         : 08-Mar-2005 ABINDAL created.
  -- End of comments
  ---------------------------------------------------------------------------
  FUNCTION   transaction_amount  (p_pool_id            IN   VARCHAR2,
                                  p_to_date            IN DATE,
                                  p_from_currency_code IN   VARCHAR2,
                                  p_to_currency_code   IN   VARCHAR2,
                                  p_conversion_type    IN VARCHAR2,
                                  x_return_status      OUT NOCOPY VARCHAR2,
                                  x_msg_count          OUT NOCOPY NUMBER,
                                  x_msg_data           OUT NOCOPY VARCHAR2 )
  RETURN NUMBER
IS

  -- cursor for calcualting the remaining balance of pool till the date specified.
  CURSOR c_remaining_balance(cp_pool_id VARCHAR2, cp_to_date DATE)IS
  SELECT trx_type_code,
--STRAT: 02-NOV-05  cklee    - Fixed bug#4705629                          |
         trx_amount,
         trx_currency_code,
--         subsidy_pool_amount,
--END  : 02-NOV-05  cklee    - Fixed bug#4705629                          |
         source_trx_date,
         trx_date
  FROM  okl_trx_subsidy_pools
  WHERE subsidy_pool_id = cp_pool_id
  AND   TRUNC(source_trx_date) <= NVL(TRUNC(cp_to_date), TRUNC(source_trx_date));

  l_trx_amount          NUMBER ;
  l_amount              NUMBER ;
  l_conv_rate           NUMBER ;
  l_api_name            CONSTANT VARCHAR2(30) := 'transaction_amount';
  l_msg_count	          NUMBER ;
  l_msg_data	    	      VARCHAR2(2000);
  l_return_status	      VARCHAR2(1);
  l_api_version			      NUMBER ;
  l_init_msg_list       VARCHAR2(1);
  l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_SUBSIDY_POOL_RPT_PVT.TRANSACTION_AMOUNT';
  l_debug_enabled       VARCHAR2(10);
  is_debug_procedure_on BOOLEAN;
  is_debug_statement_on BOOLEAN;

BEGIN
   l_debug_enabled := okl_debug_pub.check_log_enabled;
   is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
   IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
     okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRSIOB.pls call transaction_amount');
   END IF;
   -- check for logging on STATEMENT level
   is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);

   l_api_version := 1.0;
   l_init_msg_list := Okl_Api.g_false;
   l_msg_count := 0;
   l_trx_amount := 0;
   l_amount := 0;
   l_conv_rate := 0;

   l_return_status := OKL_API.START_ACTIVITY( l_api_name,
                                              G_PKG_NAME,
                                              l_init_msg_list,
                                              l_api_version,
                                              l_api_version,
                                              '_PVT',
                                              l_return_status);

   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

  l_trx_amount := 0;
  -- Calculate the total transactions for the given subsidy pool uptill the p_input_date.
  FOR each_row IN c_remaining_balance(p_pool_id,p_to_date)
    LOOP
       l_amount := 0;
       -- Convert the transaction amount, from its subsidy pool currency to the Parent pool currency
       -- entered by the user. The currency conversion rate will be derived based on the transaction
       -- date of the respective transaction.
--STRAT: 02-NOV-05  cklee    - Fixed bug#4705629                          |
--       l_amount := currency_conversion( each_row.trx_amount,
       l_amount := currency_conversion( each_row.trx_amount,
--       this function will NOT use the passed in pool's curreny code to convert to
--       the destination curreny code, instead, will use trx curreny code to convert to destination pool
--       curreny directly to avoid inconsist between report header trx amount and the details' trx amount
--       if the passed in pool is reporting pool
--                                        p_from_currency_code,
                                        each_row.trx_currency_code,
--END: 02-NOV-05  cklee    - Fixed bug#4705629                          |
                                        p_to_currency_code,
                                        p_conversion_type,
                                        each_row.trx_date,
                                        l_conv_rate
                                      );
       IF (l_amount < 0) THEN
         fnd_message.set_name(G_APP_NAME,
                              'OKL_POOL_CURR_CONV');
         fnd_message.set_token('FROM_CURR',
                              p_from_currency_code);
         fnd_message.set_token('TO_CURR',
                               p_to_currency_code);
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get);
       END IF;
       IF (each_row.trx_type_code = 'ADDITION') THEN
          l_trx_amount := l_trx_amount - l_amount;
       ELSIF(each_row.trx_type_code = 'REDUCTION') THEN
          l_trx_amount := l_trx_amount + l_amount;
       END IF;
      IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                 l_module,
                                 'l_amount '||l_amount||' l_trx_amount '||l_trx_amount
                                 );
      END IF; -- end of NVL(l_debug_enabled,'N')='Y'

    END LOOP;
   okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
   x_return_status := l_return_status;
   x_msg_data      := l_msg_data;
   x_msg_count     := l_msg_count;
  RETURN l_trx_amount;
  IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
    okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRSIOB.pls call transaction_amount');
  END IF;
  EXCEPTION
     WHEN G_EXCEPTION_HALT_VALIDATION THEN
       x_return_status	:=  OKL_API.HANDLE_EXCEPTIONS
       (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
       );

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);

END transaction_amount;

  ---------------------------------------------------------------------------
  -- FUNCTION GET_PARENT_RECORD
  ---------------------------------------------------------------------------
---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : GET_PARENT_RECORD
  -- Description     : To get the parent subsidy pool record.
  -- Business Rules  :
  -- Parameters      : p_parent_id
  -- Version         : 1.0
  -- History         : 08-Mar-2005 ABINDAL created.
  -- End of comments
  ---------------------------------------------------------------------------
FUNCTION get_parent_record ( p_parent_id  IN okl_subsidy_pools_b.id%TYPE )

RETURN okl_sub_pool_rec

IS

CURSOR c_parent_summary(cp_pool_id okl_subsidy_pools_b.id%TYPE) IS
SELECT id,
       subsidy_pool_name,
       pool_type_code,
       currency_code,
       currency_conversion_type,
       reporting_pool_limit,
       effective_from_date
FROM   okl_subsidy_pools_b
WHERE  id = cp_pool_id
AND ( 1 = (case when nvl(fnd_profile.value('OKLSUBPOOLGLOBALACCESS'),'N') = 'Y' then 1
           else
           (case when exists (select 'x'
                              from okl_subsidies_v
                              where subsidy_pool_id = okl_subsidy_pools_b.id
                              and org_id <> mo_global.get_current_org_id()) then 0
             else 1  end)
             end));

l_pool_rec            okl_sub_pool_rec;

BEGIN
   -- Fetch the Parent subsidy pool record and return a record type.
   OPEN c_parent_summary(p_parent_id);
   FETCH  c_parent_summary INTO l_pool_rec;
   CLOSE c_parent_summary;

   RETURN l_pool_rec;

END get_parent_record;


  ---------------------------------------------------------------------------
  -- PROCEDURE PRINT_PARENT_RECORD
  ---------------------------------------------------------------------------
---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : PRINT_PARENT_RECORD
  -- Description     : To print the parent subsidy pool record.
  -- Business Rules  :
  -- Parameters      : p_pool_rec, p_input_date, p_to_currency_code
  -- Version         : 1.0
  -- History         : 08-Mar-2005 ABINDAL created.
  -- End of comments
  ---------------------------------------------------------------------------
PROCEDURE print_parent_record (p_pool_rec       IN okl_sub_pool_rec,
                             p_input_date       IN DATE,
                             p_to_currency_code IN VARCHAR2,
                             p_conv_type        IN VARCHAR2,
                             x_return_status    OUT NOCOPY VARCHAR2,
                             x_msg_count        OUT NOCOPY NUMBER,
                             x_msg_data         OUT NOCOPY VARCHAR2 )
IS

-- Cursor fetches all the records, which are children of a given pool till the pool,
-- does not have any more children.
CURSOR  get_amounts(cp_pool_id okl_subsidy_pools_b.id%TYPE) IS
  SELECT id ,
         currency_code,
         currency_conversion_type
  FROM okl_subsidy_pools_b pool
  WHERE pool_type_code = 'BUDGET'
  CONNECT BY PRIOR id = subsidy_pool_id
  START WITH id = cp_pool_id;

l_total_budget          okl_subsidy_pools_b.total_budgets%TYPE;
l_budget                okl_subsidy_pools_b.total_budgets%TYPE;
l_trx_amount            okl_trx_subsidy_pools.trx_amount%TYPE ;
l_trx_amt               okl_trx_subsidy_pools.trx_amount%TYPE ;
l_remaining_balance     okl_subsidy_pools_b.total_budgets%TYPE;
l_conv_rate             NUMBER;
l_Pool_Name_len		       CONSTANT NUMBER DEFAULT 30;
l_Pool_Type_len         CONSTANT NUMBER DEFAULT 30;
l_Currency_Code_len     CONSTANT NUMBER DEFAULT 15;
l_Pool_Limit_len        CONSTANT NUMBER DEFAULT 20;
l_Budget_len            CONSTANT NUMBER DEFAULT 20;
l_Remaining_Balance_len CONSTANT NUMBER DEFAULT 20;
l_total_length          CONSTANT NUMBER DEFAULT 152;
l_reporting_limit       okl_subsidy_pools_b.reporting_pool_limit%TYPE ;
l_api_name              CONSTANT VARCHAR2(30) := 'print_parent_record';
l_msg_count	            NUMBER ;
l_msg_data	    	        VARCHAR2(2000);
l_return_status  	      VARCHAR2(1);
l_api_version			        NUMBER ;
l_init_msg_list         VARCHAR2(1);
l_module                CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_SUBSIDY_POOL_RPT_PVT.PRINT_PARENT_RECORD';
l_debug_enabled         VARCHAR2(10);
is_debug_procedure_on   BOOLEAN;
is_debug_statement_on   BOOLEAN;

BEGIN
   l_debug_enabled := okl_debug_pub.check_log_enabled;
   is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
   IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
     okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRSIOB.pls call print_parent_record');
   END IF;
   -- check for logging on STATEMENT level
   is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);

   l_api_version := 1.0;
   l_init_msg_list := Okl_Api.g_false;
   l_msg_count := 0;
   l_total_budget := 0;
   l_budget := 0;
   l_trx_amount := 0;
   l_trx_amt := 0;
   l_remaining_balance := 0;
   l_conv_rate := 0;
   l_reporting_limit := p_pool_rec.reporting_pool_limit;

   l_return_status := OKL_API.START_ACTIVITY( l_api_name,
                                              G_PKG_NAME,
                                              l_init_msg_list,
                                              l_api_version,
                                              l_api_version,
                                              '_PVT',
                                              l_return_status);

   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

      -- Parent pool header with the parent pool name.
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', l_total_length, ' ' ));
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', l_total_length, ' ' ));
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_PARENT_POOL') || ' : '
          || fnd_message.get_string('OKL',p_pool_rec.subsidy_pool_name));
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('-', 30 , '-' ));
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('-', l_total_length+8 , '-' ));
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
          GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_SUBSIDY_POOL_NAME'),l_Pool_Name_len,'TITLE')||' '||
          GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_POOL_TYPE_TXT'),l_Pool_Type_len,'TITLE')||' '||
          GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_AGN_RPT_CURRENCY'),l_Currency_Code_len,'TITLE')||' '||
          GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_SUBSIDY_POOL_LIMIT'),l_Pool_Limit_len,'TITLE')||' '||
          GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_POOL_BUDGET'),l_Budget_len,'TITLE')||' '||
          GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_POOL_BALANCE'),l_Remaining_Balance_len,'TITLE'));
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('=', l_total_length+8 , '=' ));
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
      -- Convert the reporting pool limit amount from pool currency to the parent pool(user entered) currency.
      l_reporting_limit := currency_conversion(p_pool_rec.reporting_pool_limit,
                                               p_pool_rec.currency_code,
                                               p_to_currency_code,
                                               p_conv_type,
                                               p_pool_rec.effective_from_date,
                                               l_conv_rate
                                              );
       IF (l_reporting_limit < 0) THEN
         fnd_message.set_name( G_APP_NAME,
                               'OKL_POOL_CURR_CONV');
         fnd_message.set_token('FROM_CURR',
                               p_pool_rec.currency_code);
         fnd_message.set_token('TO_CURR',
                               p_to_currency_code);
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get);
       END IF;
      -- If subsidy pool is of type reporting then, calculate the total budgets and remaining balance for that pool,
      -- from all its children which are of type budget.
      IF(p_pool_rec.pool_type_code = 'REPORTING') THEN
          FOR each_row IN get_amounts(p_pool_rec.id) LOOP
                l_budget := total_budgets( each_row.id,
                                           p_input_date,
                                           each_row.currency_code,
                                           p_to_currency_code,
                                           p_conv_type,
                                           l_return_status,
                                           l_msg_count,
                                           l_msg_data
                                         );
                IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
                l_total_budget := l_total_budget + l_budget;
                l_trx_amt := transaction_amount( each_row.id,
                                                 p_input_date,
                                                 each_row.currency_code,
                                                 p_to_currency_code,
                                                 p_conv_type,
                                                 l_return_status,
                                                 l_msg_count,
                                                 l_msg_data
                                               );
                IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
                l_trx_amount := l_trx_amount + l_trx_amt;
          END LOOP;
      -- if subsidy pool type is budget, simply calculate the total budgets and remaining balance.
      ELSE
        l_budget := total_budgets( p_pool_rec.id,
                                   p_input_date,
                                   p_pool_rec.currency_code,
                                   p_to_currency_code,
                                   p_conv_type,
                                   l_return_status,
                                   l_msg_count,
                                   l_msg_data
                                 );
        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        l_total_budget := l_budget;
        l_trx_amt := transaction_amount( p_pool_rec.id,
                                         p_input_date,
                                         p_pool_rec.currency_code,
                                         p_to_currency_code,
                                         p_conv_type,
                                         l_return_status,
                                         l_msg_count,
                                         l_msg_data
                                       );
        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        l_trx_amount := l_trx_amt;
      END IF;
      l_remaining_balance :=  l_total_budget - l_trx_amount;

      IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                 l_module,
                                 'l_reporting_limit '||l_reporting_limit||' l_total_budget '
                                 ||l_total_budget||' l_trx_amount '||l_trx_amount
                                 ||'l_remaining_balance'||l_remaining_balance
                                 );
      END IF; -- end of NVL(l_debug_enabled,'N')='Y'

      -- Print the parent pool record
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
         GET_PROPER_LENGTH(p_pool_rec.subsidy_pool_name,l_Pool_Name_len,'DATA')||' '||
         GET_PROPER_LENGTH(p_pool_rec.pool_type_code,l_Pool_Type_len,'DATA')||' '||
         GET_PROPER_LENGTH(p_to_currency_code,l_Currency_Code_len,'DATA')||' '||
         GET_PROPER_LENGTH(okl_accounting_util.format_amount(l_reporting_limit,p_to_currency_code),l_Pool_Limit_len,'DATA')||' '||
         GET_PROPER_LENGTH(okl_accounting_util.format_amount(l_total_budget,p_to_currency_code),l_Budget_len,'DATA')||' '||
         GET_PROPER_LENGTH(okl_accounting_util.format_amount(l_remaining_balance,p_to_currency_code),l_Remaining_Balance_len,'DATA'));
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('-', l_total_length+8 , '-' ));

   okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
   x_return_status := l_return_status;
   x_msg_data      := l_msg_data;
   x_msg_count     := l_msg_count;

   IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
     okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRSIOB.pls call print_parent_record');
   END IF;

  EXCEPTION
     WHEN G_EXCEPTION_HALT_VALIDATION THEN
       x_return_status	:= OKL_API.HANDLE_EXCEPTIONS
       (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
       );

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);

END print_parent_record;

  ---------------------------------------------------------------------------
  -- FUNCTION GET_CHILD_RECORD
  ---------------------------------------------------------------------------
---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : GET_CHILD_RECORD
  -- Description     : To get the all the child subsidy pool records.
  -- Business Rules  :
  -- Parameters      : p_pool_id
  -- Version         : 1.0
  -- History         : 08-Mar-2005 ABINDAL created.
  -- End of comments
  ---------------------------------------------------------------------------
FUNCTION get_child_record ( p_pool_id  IN okl_subsidy_pools_b.id%TYPE )

RETURN subsidy_pool_tbl_type

IS

--Cursor for displaying the summary of all the children of a parent pool.
CURSOR c_child_summary(cp_pool_id VARCHAR2) IS
SELECT id,
       subsidy_pool_name,
       pool_type_code,
       currency_code,
       currency_conversion_type,
       reporting_pool_limit,
       effective_from_date
FROM   okl_subsidy_pools_b
WHERE  subsidy_pool_id = cp_pool_id
AND ( 1 = (case when nvl(fnd_profile.value('OKLSUBPOOLGLOBALACCESS'),'N') = 'Y' then 1
           else
           (case when exists (select 'x'
                              from okl_subsidies_v
                              where subsidy_pool_id = okl_subsidy_pools_b.id
                              and org_id <> mo_global.get_current_org_id()) then 0
             else 1  end)
             end))
ORDER BY subsidy_pool_name;

l_subsidy_pool_tbl    subsidy_pool_tbl_type;
i                     NUMBER ;
BEGIN
   i := 0;
   -- Fetch all the child pool records and store it in a table of records.
   -- return this table of records.
   i := 1;
   FOR each_row IN c_child_summary(p_pool_id)LOOP
     l_subsidy_pool_tbl(i) := each_row;
     i := i + 1;
   END LOOP;

   RETURN l_subsidy_pool_tbl;

END get_child_record;

  ---------------------------------------------------------------------------
  -- PROCEDURE PRINT_CHILD_RECORD
  ---------------------------------------------------------------------------
---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : PRINT_CHILD_RECORD
  -- Description     : To print all the child subsidy pool records.
  -- Business Rules  :
  -- Parameters      : p_pool_tbl, p_input_date, p_to_currency_code
  -- Version         : 1.0
  -- History         :  08-Mar-2005 ABINDAL created.
  -- End of comments
  ---------------------------------------------------------------------------
PROCEDURE print_child_record  (p_pool_tbl       IN subsidy_pool_tbl_type,
                             p_input_date       IN DATE,
                             p_to_currency_code IN VARCHAR2,
                             p_conv_type        IN VARCHAR2,
                             x_return_status    OUT NOCOPY VARCHAR2,
                             x_msg_count        OUT NOCOPY NUMBER ,
                             x_msg_data         OUT NOCOPY VARCHAR2 )
IS

CURSOR  get_amounts(cp_pool_id okl_subsidy_pools_b.id%TYPE) IS
  SELECT id ,
         currency_code,
         currency_conversion_type
  FROM okl_subsidy_pools_b pool
  WHERE pool_type_code = 'BUDGET'
  CONNECT BY PRIOR id = subsidy_pool_id
  START WITH id = cp_pool_id;

l_total_budget          okl_subsidy_pools_b.total_budgets%TYPE;
l_trx_amount            okl_trx_subsidy_pools.trx_amount%TYPE;
l_budget                okl_subsidy_pools_b.total_budgets%TYPE;
l_trx_amt               okl_trx_subsidy_pools.trx_amount%TYPE;
l_remaining_balance     okl_subsidy_pools_b.total_budgets%TYPE;
l_conv_rate             NUMBER;
l_Pool_Name_len		       CONSTANT NUMBER DEFAULT 30;
l_Pool_Type_len         CONSTANT NUMBER DEFAULT 30;
l_Currency_Code_len     CONSTANT NUMBER DEFAULT 15;
l_Pool_Limit_len        CONSTANT NUMBER DEFAULT 20;
l_Budget_len            CONSTANT NUMBER DEFAULT 20;
l_Remaining_Balance_len CONSTANT NUMBER DEFAULT 20;
l_total_length          CONSTANT NUMBER DEFAULT 152;
i                       NUMBER;
l_reporting_limit       okl_subsidy_pools_b.reporting_pool_limit%TYPE DEFAULT NULL;
l_api_name              CONSTANT VARCHAR2(30) := 'print_child_record';
l_msg_count	            NUMBER;
l_msg_data	    	        VARCHAR2(2000);
l_return_status	        VARCHAR2(1);
l_api_version			        NUMBER;
l_init_msg_list         VARCHAR2(1);
l_module                CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_SUBSIDY_POOL_RPT_PVT.PRINT_CHILD_RECORD';
l_debug_enabled         VARCHAR2(10);
is_debug_procedure_on   BOOLEAN;
is_debug_statement_on   BOOLEAN;

BEGIN
   l_debug_enabled := okl_debug_pub.check_log_enabled;
   is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
   IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
     okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRSIOB.pls call print_child_record');
   END IF;
   -- check for logging on STATEMENT level
   is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);

   l_api_version := 1.0;
   l_init_msg_list := Okl_Api.g_false;
   l_msg_count := 0;
   l_total_budget := 0;
   l_budget := 0;
   l_trx_amount := 0;
   l_trx_amt := 0;
   l_remaining_balance := 0;
   l_conv_rate := 0;
   i := 0;

   l_return_status := OKL_API.START_ACTIVITY( l_api_name,
                                              G_PKG_NAME,
                                              l_init_msg_list,
                                              l_api_version,
                                              l_api_version,
                                              '_PVT',
                                              l_return_status);

   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

      -- Print child header.
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', l_total_length, ' ' ));
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_CHILDREN_POOL'));
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('-', 30 , '-' ));
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('-', l_total_length+8 , '-' ));
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
          GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_SUBSIDY_POOL_NAME'),l_Pool_Name_len,'TITLE')||' '||
          GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_POOL_TYPE_TXT'),l_Pool_Type_len,'TITLE')||' '||
          GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_AGN_RPT_CURRENCY'),l_Currency_Code_len,'TITLE')||' '||
          GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_SUBSIDY_POOL_LIMIT'),l_Pool_Limit_len,'TITLE')||' '||
          GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_POOL_BUDGET'),l_Budget_len,'TITLE')||' '||
          GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_POOL_BALANCE'),l_Remaining_Balance_len,'TITLE'));
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('=', l_total_length+8 , '=' ));
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');

      -- For all the records in a table, print the records.
      FOR i IN  p_pool_tbl.first..p_pool_tbl.last LOOP
         l_total_budget := 0;
         l_trx_amount := 0;
         -- If subsidy pool is of type reporting then, calculate the total budgets and remaining balance for that pool,
         -- from all its children which are of type budget.
         IF(p_pool_tbl(i).pool_type_code = 'REPORTING') THEN
             FOR each_row IN get_amounts(p_pool_tbl(i).id) LOOP
                l_budget := total_budgets( each_row.id,
                                           p_input_date,
                                           each_row.currency_code,
                                           p_to_currency_code,
                                           p_conv_type,
                                           l_return_status,
                                           l_msg_count,
                                           l_msg_data
                                         );
                IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
                l_total_budget := l_total_budget + l_budget;
                l_trx_amt := transaction_amount( each_row.id,
                                                 p_input_date,
                                                 each_row.currency_code,
                                                 p_to_currency_code,
                                                 p_conv_type,
                                                 l_return_status,
                                                 l_msg_count,
                                                 l_msg_data
                                               );
                IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
                l_trx_amount := l_trx_amount + l_trx_amt;
             END LOOP;
         ELSE
         -- if pool type is budget then simply calculate the total budgets and remining balance of a pool.
         l_budget := total_budgets( p_pool_tbl(i).id,
                                    p_input_date,
                                    p_pool_tbl(i).currency_code,
                                    p_to_currency_code,
                                    p_conv_type,
                                    l_return_status,
                                    l_msg_count,
                                    l_msg_data
                                  );
         IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
         l_total_budget := l_budget;
         l_trx_amt := transaction_amount( p_pool_tbl(i).id,
                                          p_input_date,
                                          p_pool_tbl(i).currency_code,
                                          p_to_currency_code,
                                          p_conv_type,
                                          l_return_status,
                                          l_msg_count,
                                          l_msg_data
                                        );
         IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
         l_trx_amount := l_trx_amt;
         END IF;
         l_remaining_balance :=  l_total_budget - l_trx_amount;
         -- Convert the reporting pool limit amount from pool currency to the parent pool(user entered) currency.
         l_reporting_limit := currency_conversion(p_pool_tbl(i).reporting_pool_limit,
                                                  p_pool_tbl(i).currency_code,
                                                  p_to_currency_code,
                                                  p_conv_type,
                                                  p_pool_tbl(i).effective_from_date,
                                                  l_conv_rate
                                                 );
         IF (l_reporting_limit < 0) THEN
           fnd_message.set_name( G_APP_NAME,
                                 'OKL_POOL_CURR_CONV');
           fnd_message.set_token('FROM_CURR',
                                 p_pool_tbl(i).currency_code);
           fnd_message.set_token('TO_CURR',
                                 p_to_currency_code);
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get);
         END IF;

         IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
            okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                    l_module,
                                    'l_reporting_limit '||l_reporting_limit||' l_total_budget '
                                    ||l_total_budget||' l_trx_amount '||l_trx_amount
                                    ||'l_remaining_balance'||l_remaining_balance
                                    );
         END IF; -- end of NVL(l_debug_enabled,'N')='Y'

         -- Print the child records
         FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
            GET_PROPER_LENGTH(p_pool_tbl(i).subsidy_pool_name,l_Pool_Name_len,'DATA')||' '||
            GET_PROPER_LENGTH(p_pool_tbl(i).pool_type_code,l_Pool_Type_len,'DATA')||' '||
            GET_PROPER_LENGTH(p_to_currency_code,l_Currency_Code_len,'DATA')||' '||
            GET_PROPER_LENGTH(okl_accounting_util.format_amount(l_reporting_limit,p_to_currency_code)
                              ,l_Pool_Limit_len,'DATA')||' '||
            GET_PROPER_LENGTH(okl_accounting_util.format_amount(l_total_budget,p_to_currency_code),l_Budget_len,'DATA')||' '||
            GET_PROPER_LENGTH(okl_accounting_util.format_amount(l_remaining_balance,p_to_currency_code),l_Remaining_Balance_len,'DATA'));
      END LOOP;
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('-', l_total_length+8 , '-' ));

   okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
   x_return_status := l_return_status;
   x_msg_data      := l_msg_data;
   x_msg_count     := l_msg_count;

   IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
     okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRSIOB.pls call print_child_record');
   END IF;

  EXCEPTION
     WHEN G_EXCEPTION_HALT_VALIDATION THEN
        x_return_status	:= OKL_API.HANDLE_EXCEPTIONS
       (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
       );

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);

END print_child_record;

  -------------------------------------------------------------------------------
  -- PROCEDURE POOL_ASSOC_REPORT
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : POOL_ASSOC_REPORT
  -- Description     : Procedure for Subsidy pool association Report Generation
  -- Business Rules  :
  -- Parameters      : required parameters are p_pool_name
  -- Version         : 1.0
  -- History         : 08-Mar-2005 ABINDAL created
  -- End of comments
  -------------------------------------------------------------------------------
  PROCEDURE  POOL_ASSOC_REPORT(x_errbuf  OUT NOCOPY VARCHAR2,
                               x_retcode OUT NOCOPY NUMBER,
                               p_pool_id IN  okl_subsidy_pools_b.id%TYPE,
                               p_date    IN  VARCHAR2)

IS


l_subsidy_pool_tbl    subsidy_pool_tbl_type;
l_tbl                 subsidy_pool_tbl_type;
l_from_date           DATE;
i                     NUMBER ;
j                     NUMBER ;
k                     NUMBER ;
l_count               NUMBER ;
l_pool_rec            okl_sub_pool_rec;
l_total_budget        okl_subsidy_pools_b.total_budgets%TYPE ;
l_trx_amount          okl_trx_subsidy_pools.trx_amount%TYPE ;
l_remaining_balance   okl_subsidy_pools_b.total_budgets%TYPE;
l_api_name            CONSTANT VARCHAR2(30) := 'POOL_ASSOC_REPORT';
l_msg_count	          NUMBER;
l_msg_data	           VARCHAR2(2000);
l_return_status	      VARCHAR2(1);
l_api_version			      NUMBER;
l_init_msg_list       VARCHAR2(1);
--length
l_total_length        CONSTANT NUMBER DEFAULT 152;
l_sysdate             DATE ;
l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_SUBSIDY_POOL_RPT_PVT.POOL_ASSOC_REPORT';
l_debug_enabled       VARCHAR2(10);
is_debug_procedure_on BOOLEAN;
is_debug_statement_on BOOLEAN;

BEGIN
   l_debug_enabled := okl_debug_pub.check_log_enabled;
   is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
   IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
     okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRSIOB.pls call pool_assoc_report');
   END IF;
   -- check for logging on STATEMENT level
   is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);

   l_api_version := 1.0;
   l_init_msg_list := Okl_Api.g_false;
   l_msg_count := 0;
   i := 0;
   j := 0;
   k := 0;
   l_count := 0;
   l_total_budget := 0;
   l_trx_amount := 0;
   l_remaining_balance := 0;
   l_sysdate := TRUNC(SYSDATE);

   l_return_status := OKL_API.START_ACTIVITY( l_api_name,
                                              G_PKG_NAME,
                                              l_init_msg_list,
                                              l_api_version,
                                              l_api_version,
                                              '_PVT',
                                              l_return_status);
   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

  l_from_date:= FND_DATE.CANONICAL_TO_DATE(p_date);

  -- Printing Subsidy pools report header.
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', 52 , ' ' ) ||  fnd_message.get_string('OKL','OKLHOMENAVTITLE') ||
  RPAD(' ', 53 , ' ' ));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', l_total_length, ' ' ));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', l_total_length, ' ' ));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', 52 , ' ' ) ||  fnd_message.get_string('OKL','OKL_SUBSIDY_POOL_REPORT') ||
  RPAD(' ', 53 , ' ' ));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ',50, ' ' ) || '-------------------------------' || RPAD(' ', 51, ' ' ));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', l_total_length, ' ' ));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', l_total_length, ' ' ));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', l_total_length, ' ' ));

  -- Get the parent record, the record for the pool which user has entered.
  l_pool_rec := get_parent_record(p_pool_id);
  -- if that record is found then print the parent header and record.

  IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
     okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                             l_module,
                             'l_pool_rec.id '||l_pool_rec.id
                             );
  END IF; -- end of NVL(l_debug_enabled,'N')='Y'

  IF (l_pool_rec.id is not null) THEN
     print_parent_record(l_pool_rec,
                         l_from_date,
                         l_pool_rec.currency_code,
                         l_pool_rec.currency_conversion_type,
                         l_return_status,
                         l_msg_count,
                         l_msg_data
                        );
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
  END IF;
  -- Get all the child records of this parent subsidy pool.
  l_subsidy_pool_tbl := get_child_record(l_pool_rec.id);
  -- If the child record exists then print the child header and all the
  -- child records of the parent pool.

  IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
     okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                             l_module,
                             'l_subsidy_pool_tbl.count '||l_subsidy_pool_tbl.count
                             );
  END IF; -- end of NVL(l_debug_enabled,'N')='Y'

  IF l_subsidy_pool_tbl.count > 0 THEN
    print_child_record(l_subsidy_pool_tbl,
                       l_from_date,
                       l_pool_rec.currency_code,
                       l_pool_rec.currency_conversion_type,
                       l_return_status,
                       l_msg_count,
                       l_msg_data
                      );
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
  END IF;

   -- for all the child records, search if any further childs of these records
   -- exists, if yes print those records also.
   -- Take a table of records of the child subsidy pools.For each records in the table
   -- if further child pools are found then append these records in this array and the
   -- size of the array increases. Run the loop till this array ends.
   IF l_subsidy_pool_tbl.count > 0 THEN
      i := l_subsidy_pool_tbl.first;
      j := l_subsidy_pool_tbl.count;
      LOOP EXIT WHEN i > j;
          k := 0;
          l_tbl := get_child_record(l_subsidy_pool_tbl(i).id);
          -- If child record is found then print this record as a parent and then print all the
          -- child records of this pool.
          IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
             okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                     l_module,
                                     'l_tbl.count '||l_tbl.count
                                     );
          END IF; -- end of NVL(l_debug_enabled,'N')='Y'

          IF l_tbl.count > 0 THEN
             print_parent_record(l_subsidy_pool_tbl(i),
                                 l_from_date,
                                 l_pool_rec.currency_code,
                                 l_pool_rec.currency_conversion_type,
                                 l_return_status,
                                 l_msg_count,
                                 l_msg_data
                                );
             IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
             print_child_record(l_tbl,
                                l_from_date,
                                l_pool_rec.currency_code,
                                l_pool_rec.currency_conversion_type,
                                l_return_status,
                                l_msg_count,
                                l_msg_data
                               );
             IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
             l_count := l_subsidy_pool_tbl.count + 1;
             -- Appending in the array if the child records are found.
             FOR k IN  l_tbl.first..l_tbl.last LOOP
                l_subsidy_pool_tbl(l_count) := l_tbl(k);
                l_count := l_count + 1;
             END LOOP;
          END IF;
          j := l_subsidy_pool_tbl.count;
          i := i + 1;
      END LOOP;
   END IF;
   okl_api.END_ACTIVITY(l_msg_count, l_msg_data);

   IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
     okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRSIOB.pls call pool_assoc_report');
   END IF;

EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      l_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => l_msg_count,
                           x_msg_data  => l_msg_data,
                           p_api_type  => g_api_type);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      l_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => l_msg_count,
                           x_msg_data  => l_msg_data,
                           p_api_type  => g_api_type);

    WHEN OTHERS THEN
       x_errbuf := SQLERRM;
       x_retcode := 2;

       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: '||SQLERRM);

       IF (SQLCODE <> -20001) THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: '||SQLCODE||SQLERRM);
         --APP_EXCEPTION.RAISE_EXCEPTION;
          RAISE;
        ELSE
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: '||SQLCODE||SQLERRM);
          --g_error_message := Sqlerrm;
          APP_EXCEPTION.RAISE_EXCEPTION;
       END IF;

END pool_assoc_report;

---------------------------------------------------------------------------
  -- PROCEDURE PRINT_POOL_SUMMARY
---------------------------------------------------------------------------
---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : PRINT_POOL_SUMMARY
  -- Description     : To print the subsidy pool summary.
  -- Business Rules  :
  -- Parameters      : p_pool_rec, p_from_date,p_to_date, x_return_status,
  --                   x_msg_count,x_msg_data
  -- Version         : 1.0
  -- History         : 08-Mar-2005 ABINDAL created.
  -- End of comments
  ---------------------------------------------------------------------------
PROCEDURE print_pool_summary (p_pool_rec     IN okl_sub_pool_rec,
                             p_from_date     IN DATE,
                             p_to_date       IN DATE,
                             x_return_status OUT NOCOPY VARCHAR2,
                             x_msg_count     OUT NOCOPY NUMBER,
                             x_msg_data      OUT NOCOPY VARCHAR2 )
IS

-- Cursor to fetch all the children pools of a subsidy pool entered.
CURSOR  get_amounts(cp_pool_id okl_subsidy_pools_b.id%TYPE) IS
  SELECT id ,
         currency_code
  FROM okl_subsidy_pools_v pool
  WHERE pool_type_code = 'BUDGET'
  CONNECT BY PRIOR id = subsidy_pool_id
  START WITH id = cp_pool_id;

l_budget                okl_subsidy_pools_b.total_budgets%TYPE;
l_trx_amt               okl_trx_subsidy_pools.trx_amount%TYPE ;
l_amount                okl_trx_subsidy_pools.trx_amount%TYPE ;
l_remaining_balance     okl_subsidy_pools_b.total_budgets%TYPE;
l_Pool_Name_len		       CONSTANT NUMBER DEFAULT 30;
l_Pool_Type_len         CONSTANT NUMBER DEFAULT 30;
l_Currency_Code_len     CONSTANT NUMBER DEFAULT 15;
l_Pool_Limit_len        CONSTANT NUMBER DEFAULT 20;
l_Budget_len            CONSTANT NUMBER DEFAULT 20;
l_trx_amt_len           CONSTANT NUMBER DEFAULT 20;
l_Remaining_Balance_len CONSTANT NUMBER DEFAULT 20;
l_total_length          CONSTANT NUMBER DEFAULT 152;
l_api_name              CONSTANT VARCHAR2(30) := 'print_pool_summary';
l_msg_count	            NUMBER;
l_msg_data	    	        VARCHAR2(2000);
l_return_status	        VARCHAR2(1);
l_api_version			        NUMBER;
l_init_msg_list         VARCHAR2(1);
l_module                CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_SUBSIDY_POOL_RPT_PVT.PRINT_POOL_SUMMARY';
l_debug_enabled         VARCHAR2(10);
is_debug_procedure_on   BOOLEAN;
is_debug_statement_on   BOOLEAN;

BEGIN
   l_debug_enabled := okl_debug_pub.check_log_enabled;
   is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
   IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
     okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRSIOB.pls call print_pool_summary');
   END IF;
   -- check for logging on STATEMENT level
   is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);

   l_api_version := 1.0;
   l_init_msg_list := Okl_Api.g_false;
   l_msg_count := 0;
   l_budget := 0;
   l_trx_amt := 0;
   l_amount := 0;
   l_remaining_balance := 0;

   l_return_status := OKL_API.START_ACTIVITY( l_api_name,
                                              G_PKG_NAME,
                                              l_init_msg_list,
                                              l_api_version,
                                              l_api_version,
                                              '_PVT',
                                              l_return_status);

   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   -- If subsidy pool type is "Budget" then pick the values for total budgets
   -- from the okl_subsidy_pools_b table and calculate the total transaction amount
   -- from the okl_trx_subsidy_pools table.
   IF (p_pool_rec.pool_type_code = 'BUDGET') THEN
      -- Parent pool header with the parent pool name.
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', l_total_length, ' ' ));
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', l_total_length, ' ' ));
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('-', l_total_length+8 , '-' ));
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
          GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_SUBSIDY_POOL_NAME'),l_Pool_Name_len,'TITLE')||' '||
          GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_POOL_TYPE_TXT'),l_Pool_Type_len,'TITLE')||' '||
          GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_AGN_RPT_CURRENCY'),l_Currency_Code_len,'TITLE')||' '||
          GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_POOL_BUDGET'),l_Budget_len,'TITLE')||' '||
          GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_TRX_AMOUNT'),l_trx_amt_len,'TITLE')||' '||
          GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_POOL_BALANCE'),l_Remaining_Balance_len,'TITLE'));
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('=', l_total_length+8 , '=' ));
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
      -- Calculate the total budgets for subsidy pool till the date specified.
      l_budget := total_budgets( p_pool_rec.id,
                                 p_to_date,
                                 p_pool_rec.currency_code,
                                 p_pool_rec.currency_code,
                                 p_pool_rec.currency_conversion_type,
                                 l_return_status,
                                 l_msg_count,
                                 l_msg_data
                                );
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- calculate the total transaction amount for the subsidy pool.
      l_trx_amt := transaction_amount( p_pool_rec.id,
                                       p_to_date,
                                       p_pool_rec.currency_code,
                                       p_pool_rec.currency_code,
                                       p_pool_rec.currency_conversion_type,
                                       l_return_status,
                                       l_msg_count,
                                       l_msg_data
                                      );
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- remaining balance for subsidy pool is total budgets minus the total transaction amount.
      l_remaining_balance :=  l_budget - l_trx_amt;

      IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                 l_module,
                                 ' l_budget '||l_budget||' l_trx_amt '||l_trx_amt
                                 ||'l_remaining_balance'||l_remaining_balance
                                 );
      END IF; -- end of NVL(l_debug_enabled,'N')='Y'

      -- Print the parent pool record
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
         GET_PROPER_LENGTH(p_pool_rec.subsidy_pool_name,l_Pool_Name_len,'DATA')||' '||
         GET_PROPER_LENGTH(p_pool_rec.pool_type_code,l_Pool_Type_len,'DATA')||' '||
         GET_PROPER_LENGTH(p_pool_rec.currency_code,l_Currency_Code_len,'DATA')||' '||
         GET_PROPER_LENGTH(okl_accounting_util.format_amount(l_budget,p_pool_rec.currency_code),l_Budget_len,'DATA')||' '||
         GET_PROPER_LENGTH(okl_accounting_util.format_amount(l_trx_amt,p_pool_rec.currency_code),l_trx_amt_len,'DATA')||' '||
         GET_PROPER_LENGTH(okl_accounting_util.format_amount(l_remaining_balance,p_pool_rec.currency_code),l_Remaining_Balance_len,'DATA'));
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('-', l_total_length+8 , '-' ));

   -- if subsidy pool type is "Reporting" then the total budgets and total transaction amount
   -- is calculated from its children as there is no transaction and budgets for pool type "Reporting"
   ELSIF (p_pool_rec.pool_type_code = 'REPORTING') THEN
      -- Parent pool header with the parent pool name.
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', l_total_length, ' ' ));
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', l_total_length, ' ' ));
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('-', l_total_length+8 , '-' ));
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
          GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_SUBSIDY_POOL_NAME'),l_Pool_Name_len,'TITLE')||' '||
          GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_POOL_TYPE_TXT'),l_Pool_Type_len,'TITLE')||' '||
          GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_AGN_RPT_CURRENCY'),l_Currency_Code_len,'TITLE')||' '||
          GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_SUBSIDY_POOL_LIMIT'),l_Pool_Limit_len,'TITLE')||' '||
          GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_TRX_AMOUNT'),l_trx_amt_len,'TITLE'));
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('=', l_total_length+8 , '=' ));
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');

      -- For each of the children found for "Reporting" pool type
      FOR  each_row IN get_amounts(p_pool_rec.id) LOOP
         -- calculate the transaction amount and convert the children pool currency
         -- in to the "Reporting" pool currency.
         l_amount := transaction_amount ( each_row.id,
                                          p_to_date,
                                          each_row.currency_code,
                                          p_pool_rec.currency_code,
                                          p_pool_rec.currency_conversion_type,
                                          l_return_status,
                                          l_msg_count,
                                          l_msg_data
                                         );
         IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
         l_trx_amt := l_trx_amt + l_amount;
      END LOOP;
      -- Print the subsidy pool sumaary.
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
         GET_PROPER_LENGTH(p_pool_rec.subsidy_pool_name,l_Pool_Name_len,'DATA')||' '||
         GET_PROPER_LENGTH(p_pool_rec.pool_type_code,l_Pool_Type_len,'DATA')||' '||
         GET_PROPER_LENGTH(p_pool_rec.currency_code,l_Currency_Code_len,'DATA')||' '||
         GET_PROPER_LENGTH(okl_accounting_util.format_amount(p_pool_rec.reporting_pool_limit,p_pool_rec.currency_code),l_Pool_Limit_len,'DATA')||' '||
         GET_PROPER_LENGTH(okl_accounting_util.format_amount(l_trx_amt,p_pool_rec.currency_code),l_trx_amt_len,'DATA'));
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('-', l_total_length+8 , '-' ));
   END IF;

   okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
   x_return_status := l_return_status;
   x_msg_data      := l_msg_data;
   x_msg_count     := l_msg_count;

   IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
     okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRSIOB.pls call print_pool_summary');
   END IF;

  EXCEPTION
     WHEN G_EXCEPTION_HALT_VALIDATION THEN
       x_return_status	:= OKL_API.HANDLE_EXCEPTIONS
       (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
       );

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);

END print_pool_summary;

---------------------------------------------------------------------------
  -- PROCEDURE PRINT_TRANSACTION_SUMMARY
---------------------------------------------------------------------------
---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : PRINT_TRANSACTION_SUMMARY
  -- Description     : To print the subsidy pool summary.
  -- Business Rules  :
  -- Parameters      : p_pool_rec, p_from_date,p_to_date, x_return_status,
  --                   x_msg_count,x_msg_data
  -- Version         : 1.0
  -- History         : 08-Mar-2005 ABINDAL created.
  -- End of comments
  ---------------------------------------------------------------------------
PROCEDURE print_transaction_summary (p_pool_id       IN okl_subsidy_pools_b.id%TYPE,
                                     p_from_date     IN DATE,
                                     p_to_date       IN DATE,
                                     p_pool_type     IN okl_subsidy_pools_b.pool_type_code%TYPE,
                                     p_pool_currency IN okl_subsidy_pools_b.currency_code%TYPE,
                                     p_conv_type     IN okl_subsidy_pools_b.currency_conversion_type%TYPE,
                                     x_return_status OUT NOCOPY VARCHAR2,
                                     x_msg_count     OUT NOCOPY NUMBER ,
                                     x_msg_data      OUT NOCOPY VARCHAR2 )
IS

-- cursor to fetch all the transactions details for the subsidy pool between the dates entered by user.
CURSOR c_transaction_detail(cp_pool_id okl_subsidy_pools_b.id%TYPE, cp_from_date DATE, cp_to_date DATE) IS
   SELECT flk1.meaning trx_reason,
--START:14-DEC-05  cklee    - Fixed bug#4884558                          |
--          khr.contract_number,
        (case
           when pool.source_type_code = 'LEASE_CONTRACT' then
             (select khr.contract_number
              from okc_k_headers_b khr
              where khr.id = pool.source_object_id)
--START:|           26-JAN-05  cklee    - Fixed bug#5002229                          |
--           when pool.source_type_code in ('SALES_QUOTE', 'LEASE_APPLICATION') then
           when pool.source_type_code = 'SALES_QUOTE' then
--END|           26-JAN-05  cklee    - Fixed bug#5002229                          |
             (select sq.reference_number
              from okl_lease_quotes_b sq
              where sq.id = pool.source_object_id)
--START:|           26-JAN-05  cklee    - Fixed bug#5002229                          |
           when pool.source_type_code = 'LEASE_APPLICATION' then
--END|           26-JAN-05  cklee    - Fixed bug#5002229                          |
             (select lap.reference_number
              from okl_lease_applications_b lap,
                   okl_lease_quotes_b lsq
              where lsq.parent_object_id = lap.id
              and lsq.parent_object_code = 'LEASEAPP'
              and lsq.id = pool.source_object_id)
--END|           26-JAN-05  cklee    - Fixed bug#5002229                          |
         end) contract_number,
--END:14-DEC-05  cklee    - Fixed bug#4884558                          |
          dnz_asset_number,
          vend.vendor_name Vendor,
          sub.name subsidy_name,
          trx_type_code,
          source_trx_date,
          trx_currency_code,
          trx_amount,
          subsidy_pool_currency_code,
          pool.conversion_rate,
          subsidy_pool_amount,
          trx_date,
-- abindal start bug# 4873705 --
          hru.name operating_unit
-- abindal end bug# 4873705 --
   FROM okl_trx_subsidy_pools pool,
        fnd_lookups flk1,
        po_vendors vend,
        okl_subsidies_b sub,
-- abindal start bug# 4873705 --
        hr_organization_units hru
-- abindal end bug# 4873705 --
--START:14-DEC-05  cklee    - Fixed bug#4884558                          |
--,       okc_k_headers_b khr
--END:14-DEC-05  cklee    - Fixed bug#4884558                          |
   WHERE  flk1.lookup_type = 'OKL_SUB_POOL_TRX_REASON_TYPE'
   AND    flk1.lookup_code = pool.trx_reason_code
   AND vend.vendor_id = pool.vendor_id
   AND sub.id = pool.subsidy_id
--   AND TRUNC(source_trx_date) >= NVL(TRUNC(cp_from_date),TRUNC(source_trx_date))
--   AND TRUNC(source_trx_date) <= NVL(TRUNC(cp_to_date), TRUNC(source_trx_date))
   AND pool.subsidy_pool_id IN ( SELECT id
                                 FROM okl_subsidy_pools_b
                                 WHERE pool_type_code = 'BUDGET'
                                 CONNECT BY PRIOR id = subsidy_pool_id
                                 START WITH id = cp_pool_id
                                )
--START:14-DEC-05  cklee    - Fixed bug#4884558                          |
--   AND khr.id = pool.source_object_id
--END:14-DEC-05  cklee    - Fixed bug#4884558                          |
-- abindal start bug# 4873705 --
AND sub.org_id = hru.organization_id
-- abindal end bug# 4873705 --
--START:           09-Mar-05  cklee    - Fixed bug#4659748                          |
--ORDER BY source_trx_date;
ORDER BY trx_date asc;
--END:           09-Mar-05  cklee    - Fixed bug#4659748                          |

l_trx_reason_len		    CONSTANT NUMBER DEFAULT 27;
l_source_len          CONSTANT NUMBER DEFAULT 20;
l_asset_len           CONSTANT NUMBER DEFAULT 15;
l_vendor_len          CONSTANT NUMBER DEFAULT 25;
l_subsidy_len         CONSTANT NUMBER DEFAULT 20;
l_src_trx_date_len    CONSTANT NUMBER DEFAULT 13;
l_trx_amt_len         CONSTANT NUMBER DEFAULT 15;
l_conv_rate_len       CONSTANT NUMBER DEFAULT 10;
l_pool_amt_len        CONSTANT NUMBER DEFAULT 20;
-- abindal start bug# 4873705 --
l_oper_unit_len       CONSTANT NUMBER DEFAULT 30;
-- abindal end bug# 4873705 --
l_total_length        CONSTANT NUMBER DEFAULT 250;
l_total_amt_len       CONSTANT NUMBER DEFAULT 15;
l_tot_bdgt_len        CONSTANT NUMBER DEFAULT 137;
l_curr_len            CONSTANT NUMBER DEFAULT 3;
l_pool_amount         NUMBER;
l_amount              NUMBER;
l_conv_rate           NUMBER;
l_sub_pool_amount     NUMBER;
l_trx_amount          NUMBER;
l_api_name            CONSTANT VARCHAR2(30) := 'print_transaction_summary';
l_msg_count	          NUMBER;
l_msg_data	    	      VARCHAR2(2000);
l_return_status	      VARCHAR2(1);
l_api_version			      NUMBER;
l_init_msg_list       VARCHAR2(1);
l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_SUBSIDY_POOL_RPT_PVT.PRINT_TRANSACTION_SUMMARY';
l_debug_enabled       VARCHAR2(10);
is_debug_procedure_on BOOLEAN;
is_debug_statement_on BOOLEAN;

BEGIN

    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);

    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRSIOB.pls call print_transaction_summary');
    END IF;
    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);

    l_api_version := 1.0;
    l_init_msg_list := Okl_Api.g_false;
    l_msg_count := 0;
    l_pool_amount := 0;
    l_amount := 0;
    l_conv_rate := 0;
    l_sub_pool_amount := 0;
    l_trx_amount := 0;

    l_return_status := OKL_API.START_ACTIVITY( l_api_name,
                                               G_PKG_NAME,
                                               l_init_msg_list,
                                               l_api_version,
                                               l_api_version,
                                               '_PVT',
                                               l_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Print the transaction header.
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', l_total_length, ' ' ));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_TRANSACTION'));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('-', 30 , '-' ));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('-', l_total_length , '-' ));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
        GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_SOURCE'),l_trx_reason_len,'TITLE')||' '||
        GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_NUMBER'),l_source_len,'TITLE')||' '||
        GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_ASSET_NUMBER'),l_asset_len,'TITLE')||' '||
        GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_VENDOR'),l_vendor_len,'TITLE')||' '||
        GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_SUBSIDY'),l_subsidy_len,'TITLE')||' '||
        GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_EXPT_DATE'),l_src_trx_date_len,'TITLE')||' '||
        GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_TRX_AMOUNT'),l_trx_amt_len + l_curr_len,'TITLE')||' '||
        GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_CURR_CONV_FACT'),l_conv_rate_len,'TITLE')||' '||
        GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_RPT_AMOUNT'),l_pool_amt_len + l_curr_len,'TITLE')||' '||
-- abindal start bug# 4873705 --
        GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_OPERATING_UNIT'),l_oper_unit_len,'TITLE'));
-- abindal end bug# 4873705 --
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('=', l_total_length , '=' ));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');

    IF(p_pool_type = 'BUDGET') THEN
       FOR each_row IN c_transaction_detail(p_pool_id,p_from_date,p_to_date) LOOP
          -- If transaction line type is "Reduction" display the transaction amount as
          -- <transaction amount>.
          IF(each_row.trx_type_code = 'ADDITION') THEN
              l_trx_amount := each_row.trx_amount;
              l_sub_pool_amount :=  each_row.subsidy_pool_amount;
          ELSIF(each_row.trx_type_code = 'REDUCTION') THEN
              l_trx_amount := each_row.trx_amount * -1;
              l_sub_pool_amount :=  each_row.subsidy_pool_amount * -1;
          END IF;
          -- Display the transactions record for the subsidy pool type "Budget".
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
              GET_PROPER_LENGTH(each_row.trx_reason,l_trx_reason_len,'DATA')||' '||
              GET_PROPER_LENGTH(each_row.contract_number,l_source_len,'DATA')||' '||
              GET_PROPER_LENGTH(each_row.dnz_asset_number,l_asset_len,'DATA')||' '||
              GET_PROPER_LENGTH(each_row.Vendor,l_vendor_len,'DATA')||' '||
              GET_PROPER_LENGTH(each_row.subsidy_name,l_subsidy_len,'DATA')||' '||
              GET_PROPER_LENGTH(each_row.source_trx_date,l_src_trx_date_len,'DATA')||' '||
              LPAD(okl_accounting_util.format_amount(l_trx_amount,each_row.trx_currency_code)
                   ||' '||each_row.trx_currency_code,l_trx_amt_len + l_curr_len,' ')||' '||
              LPAD(each_row.conversion_rate,l_conv_rate_len,' ')||' '||
              LPAD(okl_accounting_util.format_amount(l_sub_pool_amount,each_row.subsidy_pool_currency_code)
                   ||' '|| each_row.subsidy_pool_currency_code,l_pool_amt_len + l_curr_len,' ')||' '||
-- abindal start bug# 4873705 --
              GET_PROPER_LENGTH(each_row.operating_unit,l_oper_unit_len,'DATA'));
-- abindal end bug# 4873705 --

          -- for all the transactions record  found add the transaction amount with type
          -- "Addition" and reduce the  amount with type "Reduction".
          IF(each_row.trx_type_code = 'ADDITION') THEN
             l_pool_amount := l_pool_amount + each_row.subsidy_pool_amount;
          ELSE
             l_pool_amount := l_pool_amount - each_row.subsidy_pool_amount;
          END IF;
       END LOOP;
       -- Print the total transaction amount, calculated above, after all transactions data
       -- is displayed.
       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('-', l_total_length , '-' ));
       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
           RPAD(' ', l_tot_bdgt_len , ' ' )||
           GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_TOTAL_AMOUNT'),l_total_amt_len,'TITLE')||' : '||
           LPAD(okl_accounting_util.format_amount(l_pool_amount,p_pool_currency),l_pool_amt_len,' ')||' '||
           GET_PROPER_LENGTH(p_pool_currency,l_curr_len,'DATA'));
       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('-', l_total_length , '-' ));

    ELSIF(p_pool_type = 'REPORTING') THEN
       FOR each_row IN c_transaction_detail(p_pool_id,p_from_date,p_to_date) LOOP
          -- If pool type is "Reporting", the transaction amount for all children "Budget"
          -- pool is converted in to the parent "Reporting" pool currency and this amount
          -- is displayed as a "Reporting amount".
          l_amount := currency_conversion(each_row.trx_amount,
                                          each_row.trx_currency_code,
                                          p_pool_currency,
                                          p_conv_type,
                                          each_row.trx_date,
                                          l_conv_rate
                                         );
          -- if negative value is returned display the error that the conversion between
          -- the two currencies is not found.
          IF (l_amount < 0) THEN
            fnd_message.set_name( G_APP_NAME,
                                  'OKL_POOL_CURR_CONV');
            fnd_message.set_token('FROM_CURR',
                                  each_row.subsidy_pool_currency_code);
            fnd_message.set_token('TO_CURR',
                                  p_pool_currency);
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get);
          END IF;
          -- If transaction line type is "Reduction" display the transaction amount as
          -- <transaction amount>.
          IF(each_row.trx_type_code = 'ADDITION') THEN
              l_trx_amount := each_row.trx_amount;
              l_sub_pool_amount :=  l_amount;
          ELSIF(each_row.trx_type_code = 'REDUCTION') THEN
              l_trx_amount := each_row.trx_amount * -1;
              l_sub_pool_amount :=  l_amount * -1;
          END IF;
          -- Print the transactions record for the subsidy pool.
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
              GET_PROPER_LENGTH(each_row.trx_reason,l_trx_reason_len,'DATA')||' '||
              GET_PROPER_LENGTH(each_row.contract_number,l_source_len,'DATA')||' '||
              GET_PROPER_LENGTH(each_row.dnz_asset_number,l_asset_len,'DATA')||' '||
              GET_PROPER_LENGTH(each_row.Vendor,l_vendor_len,'DATA')||' '||
              GET_PROPER_LENGTH(each_row.subsidy_name,l_subsidy_len,'DATA')||' '||
              GET_PROPER_LENGTH(each_row.source_trx_date,l_src_trx_date_len,'DATA')||' '||
              LPAD(okl_accounting_util.format_amount(l_trx_amount,each_row.trx_currency_code)
                   ||' '||each_row.trx_currency_code,l_trx_amt_len + l_curr_len,' ')||' '||
              LPAD(l_conv_rate,l_conv_rate_len,' ')||' '||
              LPAD(okl_accounting_util.format_amount(l_sub_pool_amount,p_pool_currency)
                   ||' '|| p_pool_currency,l_pool_amt_len + l_curr_len,' ')||' '||
-- abindal start bug# 4873705 --
              GET_PROPER_LENGTH(each_row.operating_unit,l_oper_unit_len,'DATA'));
-- abindal end bug# 4873705 --

          -- for all the transactions record  found add the transaction amount with type
          -- "Addition" and reduce the  amount with type "Reduction".
          IF(each_row.trx_type_code = 'ADDITION') THEN
             l_pool_amount := l_pool_amount + l_amount;
          ELSE
             l_pool_amount := l_pool_amount - l_amount;
          END IF;
       END LOOP;
       -- Print the total subsidy amount at the end of all the transactions record.
       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('-', l_total_length , '-' ));
       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
           RPAD(' ', l_tot_bdgt_len , ' ' )||
           GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_TOTAL_AMOUNT'),l_total_amt_len,'TITLE')||' : '||
           LPAD(okl_accounting_util.format_amount(l_pool_amount,p_pool_currency),l_pool_amt_len,' ')||' '||
           GET_PROPER_LENGTH(p_pool_currency,l_curr_len,'DATA'));
       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('-', l_total_length , '-' ));
    END IF;

   okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
   x_return_status := l_return_status;
   x_msg_data      := l_msg_data;
   x_msg_count     := l_msg_count;

   IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
     okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRSIOB.pls call print_transaction_summary');
   END IF;

  EXCEPTION
     WHEN G_EXCEPTION_HALT_VALIDATION THEN
       x_return_status	:= OKL_API.HANDLE_EXCEPTIONS
       (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
       );

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);

END print_transaction_summary;

  -------------------------------------------------------------------------------
  -- PROCEDURE POOL_RECONC_REPORT
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : POOL_RECONC_REPORT
  -- Description     : Procedure for Subsidy pool reconciliation Report Generation
  -- Business Rules  :
  -- Parameters      : required parameters are p_pool_name
  -- Version         : 1.0
  -- History         : 08-Mar-2005 ABINDAL created
  -- End of comments
  -------------------------------------------------------------------------------

  PROCEDURE  POOL_RECONC_REPORT(x_errbuf    OUT NOCOPY VARCHAR2,
                                x_retcode   OUT NOCOPY NUMBER,
                                p_pool_id   IN  okl_subsidy_pools_b.id%TYPE,
                                p_from_date IN  VARCHAR2,
                                p_to_date   IN  VARCHAR2)
IS

l_pool_rec            okl_sub_pool_rec;
l_bdgt_pool_rec       okl_sub_pool_rec;
l_from_date           DATE;
l_to_date             DATE;
l_api_name            CONSTANT VARCHAR2(30) := 'POOL_RECONC_REPORT';
l_msg_count     	     NUMBER;
l_msg_data	           VARCHAR2(2000);
l_return_status	      VARCHAR2(1);
l_api_version	     		 NUMBER;
l_init_msg_list       VARCHAR2(1);
l_count               NUMBER;
--length
l_total_length        CONSTANT NUMBER DEFAULT 152;
l_sysdate             DATE;
l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_SUBSIDY_POOL_RPT_PVT.POOL_RECONC_REPORT';
l_debug_enabled       VARCHAR2(10);
is_debug_procedure_on BOOLEAN;
is_debug_statement_on BOOLEAN;

BEGIN
   l_debug_enabled := okl_debug_pub.check_log_enabled;
   is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
   IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
     okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRSIOB.pls call pool_reconc_report');
   END IF;
   -- check for logging on STATEMENT level
   is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);

   l_api_version := 1.0;
   l_init_msg_list := Okl_Api.g_false;
   l_msg_count := 0;
   l_sysdate := TRUNC(SYSDATE);

   l_return_status := OKL_API.START_ACTIVITY( l_api_name,
                                              G_PKG_NAME,
                                              l_init_msg_list,
                                              l_api_version,
                                              l_api_version,
                                              '_PVT',
                                              l_return_status);
   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

  l_from_date:= FND_DATE.CANONICAL_TO_DATE(p_from_date);
  l_to_date:= FND_DATE.CANONICAL_TO_DATE(p_to_date);

  -- Printing Subsidy pools report header.
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', 52 , ' ' ) ||  fnd_message.get_string('OKL','OKLHOMENAVTITLE') ||
  RPAD(' ', 53 , ' ' ));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', l_total_length, ' ' ));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', l_total_length, ' ' ));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', 52 , ' ' ) ||  fnd_message.get_string('OKL','OKL_SUBSIDY_POOL_REPORT') ||
  RPAD(' ', 53 , ' ' ));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ',50, ' ' ) || '-------------------------------' || RPAD(' ', 51, ' ' ));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', l_total_length, ' ' ));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', l_total_length, ' ' ));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', l_total_length, ' ' ));

  -- Get the record for user entered pool name.
  l_pool_rec := get_parent_record(p_pool_id);
  -- Prints the user entered parameters.
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('-', 100 , '-' ));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_SUBSIDY_POOL_NAME') || ' : '
      || l_pool_rec.subsidy_pool_name);
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_FROM_DATE') || ' : ' || l_from_date);
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get_string('OKL','OKL_TO_DATE') || ' : '   || l_to_date);
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('-', 100 , '-' ));

  IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
     okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                             l_module,
                             'l_pool_rec.id '||l_pool_rec.id
                             );
  END IF; -- end of NVL(l_debug_enabled,'N')='Y'

  l_count := 0;

  -- If record is found in the table then print the pool details region
  -- and the transaction details region.
  IF (l_pool_rec.id is not null) THEN
     print_pool_summary(l_pool_rec,
                        l_from_date,
                        l_to_date,
                        l_return_status,
                        l_msg_count,
                        l_msg_data
                       );
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
     print_transaction_summary (p_pool_id,
                                l_from_date,
                                l_to_date,
                                l_pool_rec.pool_type_code,
                                l_pool_rec.currency_code,
                                l_pool_rec.currency_conversion_type,
                                l_return_status,
                                l_msg_count,
                                l_msg_data
                               );
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
  END IF;

   okl_api.END_ACTIVITY(l_msg_count, l_msg_data);

   IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
     okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRSIOB.pls call pool_reconc_report');
   END IF;

EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      l_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => l_msg_count,
                           x_msg_data  => l_msg_data,
                           p_api_type  => g_api_type);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      l_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => l_msg_count,
                           x_msg_data  => l_msg_data,
                           p_api_type  => g_api_type);

    WHEN OTHERS THEN
       x_errbuf := SQLERRM;
       x_retcode := 2;

       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: '||SQLERRM);

       IF (SQLCODE <> -20001) THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: '||SQLCODE||SQLERRM);
         --APP_EXCEPTION.RAISE_EXCEPTION;
          RAISE;
        ELSE
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: '||SQLCODE||SQLERRM);
          --g_error_message := Sqlerrm;
          APP_EXCEPTION.RAISE_EXCEPTION;
       END IF;

END pool_reconc_report;

---------------------------------------------------------------------------
  -- PROCEDURE PRINT_ATLIMIT_DETAIL
---------------------------------------------------------------------------
---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : PRINT_ATLIMIT_DETAIL
  -- Description     : To print the At-Limit subsidy pool detail.
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 08-Mar-2005 ABINDAL created.
  -- End of comments
  ---------------------------------------------------------------------------
PROCEDURE print_atlimit_detail (p_percent       IN NUMBER,
                                p_remaining     IN NUMBER,
                                p_currency      IN okl_subsidy_pools_b.currency_code%TYPE,
                                p_date          IN DATE,
                                p_days          IN NUMBER,
                                x_return_status OUT NOCOPY VARCHAR2,
                                x_msg_count     OUT NOCOPY NUMBER ,
                                x_msg_data      OUT NOCOPY VARCHAR2)
IS

-- Cursor to fetch all the subsidy pools whose % reamining balance is
-- less than or equal to the specified % balance.
CURSOR c_get_percent(cp_percent NUMBER) IS
   SELECT id,
          subsidy_pool_name,
          currency_code,
          total_budgets,
          NVL(total_budgets - NVL(total_subsidy_amount,0),0) remaining_balance,
          case when NVL(total_budgets,0) = 0 then 0
               else ((total_budgets - NVL(total_subsidy_amount,0)) * 100) /total_budgets end percent_remaining,
          effective_to_date,
          decision_status_code
   FROM okl_subsidy_pools_b
   WHERE pool_type_code = 'BUDGET'
   AND   decision_status_code = 'ACTIVE'
   AND   CASE WHEN NVL(total_budgets,0) = 0 THEN 0
              ELSE ((total_budgets - NVL(total_subsidy_amount,0)) * 100) /total_budgets END <= cp_percent
   AND ( 1 = (case when nvl(fnd_profile.value('OKLSUBPOOLGLOBALACCESS'),'N') = 'Y' then 1
           else
           (case when exists (select 'x'
                              from okl_subsidies_v
                              where subsidy_pool_id = okl_subsidy_pools_b.id
                              and org_id <> mo_global.get_current_org_id()) then 0
             else 1  end)
             end));

-- Cursor to fetch all the subsidy pools whose  reamining budget is
-- less than or equal to the specified remaining budget.
CURSOR c_get_budget(cp_remaining NUMBER, cp_currency okl_subsidy_pools_b.currency_code%TYPE) IS
   SELECT id,
          subsidy_pool_name,
          currency_code,
          total_budgets,
          NVL(total_budgets - NVL(total_subsidy_amount,0),0) remaining_balance,
          case when NVL(total_budgets,0) = 0 then 0
               else ((total_budgets - NVL(total_subsidy_amount,0)) * 100) /total_budgets end percent_remaining,
          effective_to_date,
          decision_status_code
   FROM okl_subsidy_pools_b
   WHERE pool_type_code = 'BUDGET'
   AND   decision_status_code = 'ACTIVE'
   AND   NVL(total_budgets - NVL(total_subsidy_amount,0),0) <= cp_remaining
   AND   currency_code = cp_currency
   AND ( 1 = (case when nvl(fnd_profile.value('OKLSUBPOOLGLOBALACCESS'),'N') = 'Y' then 1
           else
           (case when exists (select 'x'
                              from okl_subsidies_v
                              where subsidy_pool_id = okl_subsidy_pools_b.id
                              and org_id <> mo_global.get_current_org_id()) then 0
             else 1  end)
             end));

-- Cursor to fetch all the subsidy pools whose effective to date lies
-- between sysdate and user entered date.
CURSOR c_get_dates(cp_date DATE) IS
   SELECT id,
          subsidy_pool_name,
          currency_code,
          total_budgets,
          NVL(total_budgets - NVL(total_subsidy_amount,0),0) remaining_balance,
          case when NVL(total_budgets,0) = 0 then 0
               else ((total_budgets - NVL(total_subsidy_amount,0)) * 100) /total_budgets end percent_remaining,
          effective_to_date
   FROM okl_subsidy_pools_b
   WHERE pool_type_code = 'BUDGET'
   AND   decision_status_code = 'ACTIVE'
   AND   TRUNC(effective_to_date) >= TRUNC(SYSDATE)
   AND   TRUNC(effective_to_date) <= TRUNC(cp_date)
   AND ( 1 = (case when nvl(fnd_profile.value('OKLSUBPOOLGLOBALACCESS'),'N') = 'Y' then 1
           else
           (case when exists (select 'x'
                              from okl_subsidies_v
                              where subsidy_pool_id = okl_subsidy_pools_b.id
                              and org_id <> mo_global.get_current_org_id()) then 0
             else 1  end)
             end));

-- Cursor to fetch all the subsidy pools whose end of term days, calculated by pool's
-- effective to date - sysdate, is less than or equal to the entered value.
CURSOR c_get_days(cp_days NUMBER) IS
   SELECT id,
          subsidy_pool_name,
          currency_code,
          total_budgets,
          NVL(total_budgets - NVL(total_subsidy_amount,0),0) remaining_balance,
          case when NVL(total_budgets,0) = 0 then 0
               else ((total_budgets - NVL(total_subsidy_amount,0)) * 100) /total_budgets end percent_remaining,
          effective_to_date,
          trunc(effective_to_date) - trunc(sysdate) remaining_days
   FROM okl_subsidy_pools_b
   WHERE pool_type_code = 'BUDGET'
   AND   decision_status_code = 'ACTIVE'
   AND trunc(effective_to_date) - trunc(sysdate) between 0 and cp_days
   AND ( 1 = (case when nvl(fnd_profile.value('OKLSUBPOOLGLOBALACCESS'),'N') = 'Y' then 1
           else
           (case when exists (select 'x'
                              from okl_subsidies_v
                              where subsidy_pool_id = okl_subsidy_pools_b.id
                              and org_id <> mo_global.get_current_org_id()) then 0
             else 1  end)
             end));

l_Pool_Name_len		      CONSTANT NUMBER DEFAULT 30;
l_Currency_Code_len    CONSTANT NUMBER DEFAULT 15;
l_Budget_len           CONSTANT NUMBER DEFAULT 20;
l_Remaining_len        CONSTANT NUMBER DEFAULT 20;
l_percent_len          CONSTANT NUMBER DEFAULT 30;
l_effective_to_len     CONSTANT NUMBER DEFAULT 20;
l_remaining_days_len   CONSTANT NUMBER DEFAULT 20;
l_total_length         CONSTANT NUMBER DEFAULT 152;
l_module               CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_SUBSIDY_POOL_RPT_PVT.PRINT_ATLIMIT_DETAIL';
l_debug_enabled        VARCHAR2(10);
is_debug_procedure_on  BOOLEAN;
is_debug_statement_on  BOOLEAN;
l_parameter_list       WF_PARAMETER_LIST_T;
l_event_name           wf_events.name%TYPE;
l_api_version		        NUMBER;
l_init_msg_list        VARCHAR2(1);
l_return_status        VARCHAR2(1);
l_msg_count	           NUMBER;
l_msg_data	            VARCHAR2(2000);
l_api_name             CONSTANT VARCHAR2(30) := 'print_atlimit_detail';
l_decision_status_code okl_subsidy_pools_b.decision_status_code%TYPE;

BEGIN

   l_debug_enabled := okl_debug_pub.check_log_enabled;
   is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
   IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
     okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRSIOB.pls call print_atlimit_detail');
   END IF;
   -- check for logging on STATEMENT level
   is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);

   l_api_version := 1.0;
   l_init_msg_list := Okl_Api.g_false;
   l_msg_count := 0;

   l_return_status := OKL_API.START_ACTIVITY( l_api_name,
                                              G_PKG_NAME,
                                              l_init_msg_list,
                                              l_api_version,
                                              l_api_version,
                                              '_PVT',
                                              l_return_status);
   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;
    -- Print the subsidy pool summary header.
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', l_total_length, ' ' ));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', l_total_length, ' ' ));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('-', l_total_length+8 , '-' ));
    FND_FILE.PUT(FND_FILE.OUTPUT,
        GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_SUBSIDY_POOL_NAME'),l_Pool_Name_len,'TITLE')||' '||
        GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_AGN_RPT_CURRENCY'),l_Currency_Code_len,'TITLE')||' '||
        GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_POOL_BUDGET'),l_Budget_len,'TITLE')||' '||
        GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_POOL_BALANCE'),l_Remaining_len,'TITLE')||' '||
        GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_PERCENT_BUDGET'),l_percent_len,'TITLE')||' '||
        GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_END_TERM'),l_effective_to_len,'TITLE'));
    IF(p_days is not null) THEN
      FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
          GET_PROPER_LENGTH(fnd_message.get_string('OKL','OKL_REMAINING_DAYS'),l_remaining_days_len,'TITLE'));
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('=', l_total_length+8 , '=' ));
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');

    -- If p_percent parameter value is entered by user and other parameters value is nul.
    IF(p_percent is not null) THEN
       FOR each_row IN c_get_percent(p_percent) LOOP
          wf_event.AddParameterToList(G_WF_ITM_SUB_POOL_ID, each_row.id, l_parameter_list);
          l_event_name := G_WF_EVT_POOL_NEAR_BUDGLMT;
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
             GET_PROPER_LENGTH(each_row.subsidy_pool_name,l_Pool_Name_len,'DATA')||' '||
             GET_PROPER_LENGTH(each_row.currency_code,l_Currency_Code_len,'DATA')||' '||
             GET_PROPER_LENGTH(okl_accounting_util.format_amount(each_row.total_budgets,each_row.currency_code),l_Budget_len,'DATA')||' '||
             GET_PROPER_LENGTH(okl_accounting_util.format_amount(each_row.remaining_balance,each_row.currency_code),l_Remaining_len,'DATA')||' '||
             GET_PROPER_LENGTH(okl_accounting_util.format_amount(each_row.percent_remaining,each_row.currency_code),l_percent_len,'DATA')||' '||
             GET_PROPER_LENGTH(each_row.effective_to_date,l_effective_to_len,'DATA'));
          -- Raise the business event "Pool nearing budget limit" for all the subsidy pool records found.
          raise_business_event(p_api_version     => l_api_version,
                               p_init_msg_list   => l_init_msg_list,
                               x_return_status   => l_return_status,
                               x_msg_count       => l_msg_count,
                               x_msg_data        => l_msg_data,
                               p_event_name      => l_event_name,
                               p_event_param_list => l_parameter_list
                              );
          IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
          -- If subsidy pool effective to date is less than the current sysdate and the subsidy pool
          -- status is other than "EXPIRED' than set the stauts to "EXPIRED'.
          IF(each_row.effective_to_date < TRUNC(SYSDATE) AND each_row.decision_status_code <> 'EXPIRED')THEN
             l_decision_status_code := 'EXPIRED';
             okl_subsidy_pool_pvt.set_decision_status_code ( l_api_version,
                                                             l_init_msg_list,
                                                             l_return_status,
                                                             l_msg_count,
                                                             l_msg_data,
                                                             each_row.id,
                                                             l_decision_status_code);
             IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
          END IF;
       END LOOP;
       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('-', l_total_length+8 , '-' ));
    ELSIF(p_remaining is not null) THEN
       FOR each_row IN c_get_budget(p_remaining,p_currency) LOOP
          wf_event.AddParameterToList(G_WF_ITM_SUB_POOL_ID, each_row.id, l_parameter_list);
          l_event_name := G_WF_EVT_POOL_NEAR_BUDGLMT;
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
             GET_PROPER_LENGTH(each_row.subsidy_pool_name,l_Pool_Name_len,'DATA')||' '||
             GET_PROPER_LENGTH(each_row.currency_code,l_Currency_Code_len,'DATA')||' '||
             GET_PROPER_LENGTH(okl_accounting_util.format_amount(each_row.total_budgets,each_row.currency_code),l_Budget_len,'DATA')||' '||
             GET_PROPER_LENGTH(okl_accounting_util.format_amount(each_row.remaining_balance,each_row.currency_code),l_Remaining_len,'DATA')||' '||
             GET_PROPER_LENGTH(okl_accounting_util.format_amount(each_row.percent_remaining,each_row.currency_code),l_percent_len,'DATA')||' '||
             GET_PROPER_LENGTH(each_row.effective_to_date,l_effective_to_len,'DATA'));
          -- Raise the business event "Pool nearing budget limit" for all the subsidy pool records found.
          raise_business_event(p_api_version     => l_api_version,
                               p_init_msg_list   => l_init_msg_list,
                               x_return_status   => l_return_status,
                               x_msg_count       => l_msg_count,
                               x_msg_data        => l_msg_data,
                               p_event_name      => l_event_name,
                               p_event_param_list => l_parameter_list
                              );
          IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
          -- If subsidy pool effective to date is less than the current sysdate and the subsidy pool
          -- status is other than "EXPIRED' than set the stauts to "EXPIRED'.
          IF(each_row.effective_to_date < TRUNC(SYSDATE) AND each_row.decision_status_code <> 'EXPIRED')THEN
             l_decision_status_code := 'EXPIRED';
             okl_subsidy_pool_pvt.set_decision_status_code ( l_api_version,
                                                             l_init_msg_list,
                                                             l_return_status,
                                                             l_msg_count,
                                                             l_msg_data,
                                                             each_row.id,
                                                             l_decision_status_code);
             IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
          END IF;
       END LOOP;
       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('-', l_total_length+8 , '-' ));
    ELSIF(p_date is not null) THEN
       FOR each_row IN c_get_dates(p_date) LOOP
          wf_event.AddParameterToList(G_WF_ITM_SUB_POOL_ID, each_row.id, l_parameter_list);
          l_event_name := G_WF_EVT_POOL_NEAR_EXPIR;
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
             GET_PROPER_LENGTH(each_row.subsidy_pool_name,l_Pool_Name_len,'DATA')||' '||
             GET_PROPER_LENGTH(each_row.currency_code,l_Currency_Code_len,'DATA')||' '||
             GET_PROPER_LENGTH(okl_accounting_util.format_amount(each_row.total_budgets,each_row.currency_code),l_Budget_len,'DATA')||' '||
             GET_PROPER_LENGTH(okl_accounting_util.format_amount(each_row.remaining_balance,each_row.currency_code),l_Remaining_len,'DATA')||' '||
             GET_PROPER_LENGTH(okl_accounting_util.format_amount(each_row.percent_remaining,each_row.currency_code),l_percent_len,'DATA')||' '||
             GET_PROPER_LENGTH(each_row.effective_to_date,l_effective_to_len,'DATA'));
          -- Raise the business event "Pool nearing expiration" for all the subsidy pool records found.
          raise_business_event(p_api_version     => l_api_version,
                               p_init_msg_list   => l_init_msg_list,
                               x_return_status   => l_return_status,
                               x_msg_count       => l_msg_count,
                               x_msg_data        => l_msg_data,
                               p_event_name      => l_event_name,
                               p_event_param_list => l_parameter_list
                              );
          IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
       END LOOP;
       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('-', l_total_length+8 , '-' ));
    ELSIF(p_days is not null) THEN
       FOR each_row IN c_get_days(p_days) LOOP
          wf_event.AddParameterToList(G_WF_ITM_SUB_POOL_ID, each_row.id, l_parameter_list);
          l_event_name := G_WF_EVT_POOL_NEAR_EXPIR;
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,
             GET_PROPER_LENGTH(each_row.subsidy_pool_name,l_Pool_Name_len,'DATA')||' '||
             GET_PROPER_LENGTH(each_row.currency_code,l_Currency_Code_len,'DATA')||' '||
             GET_PROPER_LENGTH(okl_accounting_util.format_amount(each_row.total_budgets,each_row.currency_code),l_Budget_len,'DATA')||' '||
             GET_PROPER_LENGTH(okl_accounting_util.format_amount(each_row.remaining_balance,each_row.currency_code),l_Remaining_len,'DATA')||' '||
             GET_PROPER_LENGTH(okl_accounting_util.format_amount(each_row.percent_remaining,each_row.currency_code),l_percent_len,'DATA')||' '||
             GET_PROPER_LENGTH(each_row.effective_to_date,l_effective_to_len,'DATA')||' '||
             GET_PROPER_LENGTH(each_row.remaining_days,l_remaining_days_len,'DATA'));
          -- Raise the business event "Pool nearing expiration" for all the subsidy pool records found.
          raise_business_event(p_api_version     => l_api_version,
                               p_init_msg_list   => l_init_msg_list,
                               x_return_status   => l_return_status,
                               x_msg_count       => l_msg_count,
                               x_msg_data        => l_msg_data,
                               p_event_name      => l_event_name,
                               p_event_param_list => l_parameter_list
                              );
          IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
       END LOOP;
       FND_FILE.PUT_LINE(FND_FILE.OUTPUT,RPAD('-', l_total_length+8 , '-' ));
    END IF;
    COMMIT;

   okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
   x_return_status := l_return_status;
   x_msg_data      := l_msg_data;
   x_msg_count     := l_msg_count;

  IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
     okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRSIOB.pls call print_atlimit_detail');
   END IF;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);

    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => x_msg_count,
                           x_msg_data  => x_msg_data,
                           p_api_type  => g_api_type);

END print_atlimit_detail;

  -------------------------------------------------------------------------------
  -- PROCEDURE POOL_ATLIMIT_REPORT
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : POOL_ATLIMIT_REPORT
  -- Description     : Procedure for Subsidy pool association Report Generation
  -- Business Rules  :
  -- Parameters      : parameter p_currency is required if p_remaining is entered.
  -- Version         : 1.0
  -- History         : 08-Mar-2005 ABINDAL created
  -- End of comments
  -------------------------------------------------------------------------------

  PROCEDURE  POOL_ATLIMIT_REPORT(x_errbuf     OUT NOCOPY VARCHAR2,
                                 x_retcode    OUT NOCOPY NUMBER,
                                 p_percent    IN   NUMBER,
                                 p_remaining  IN   NUMBER,
                                 p_currency   IN   okl_subsidy_pools_b.currency_code%TYPE,
                                 p_end_date   IN   VARCHAR2,
                                 p_days       IN   NUMBER )
IS

l_date                DATE;
l_api_name            CONSTANT VARCHAR2(30) := 'POOL_ATLIMIT_REPORT';
l_msg_count     	     NUMBER;
l_msg_data	           VARCHAR2(2000);
l_return_status     	 VARCHAR2(1);
l_api_version			      NUMBER;
l_init_msg_list       VARCHAR2(1);
l_total_length        CONSTANT NUMBER DEFAULT 152;
l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_SUBSIDY_POOL_RPT_PVT.POOL_ATLIMIT_REPORT';
l_debug_enabled       VARCHAR2(10);
is_debug_procedure_on BOOLEAN;
is_debug_statement_on BOOLEAN;

BEGIN
   l_debug_enabled := okl_debug_pub.check_log_enabled;
   is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
   IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
     okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRSIOB.pls call pool_atlimit_report');
   END IF;
   -- check for logging on STATEMENT level
   is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);

   l_api_version := 1.0;
   l_init_msg_list := Okl_Api.g_false;
   l_msg_count := 0;

   l_return_status := OKL_API.START_ACTIVITY( l_api_name,
                                              G_PKG_NAME,
                                              l_init_msg_list,
                                              l_api_version,
                                              l_api_version,
                                              '_PVT',
                                              l_return_status);
   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

  l_date:= FND_DATE.CANONICAL_TO_DATE(p_end_date);

  -- Printing Subsidy pools report header.
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', 52 , ' ' ) ||  fnd_message.get_string('OKL','OKLHOMENAVTITLE') ||
  RPAD(' ', 53 , ' ' ));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', l_total_length, ' ' ));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', l_total_length, ' ' ));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', 52 , ' ' ) ||  fnd_message.get_string('OKL','OKL_SUBSIDY_POOL_REPORT') ||
  RPAD(' ', 53 , ' ' ));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ',50, ' ' ) || '-------------------------------' || RPAD(' ', 51, ' ' ));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', l_total_length, ' ' ));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', l_total_length, ' ' ));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, RPAD(' ', l_total_length, ' ' ));

  -- If p_remaining is entered and p_currency is not entered or vice versa
  -- then throw an error, if any one of these parameter is entered then other
  -- one is mandatory parameter.
  IF ( p_remaining is not null AND p_currency is null) THEN
     fnd_message.set_name( G_APP_NAME,
                           'OKL_SUBPOOL_CURR_REQ');
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get);
  ELSIF ( p_remaining is null AND p_currency is not null) THEN
     fnd_message.set_name( G_APP_NAME,
                           'OKL_SUBPOOL_REM_BDGT');
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get);
  ELSIF (p_percent is not null AND p_percent > 100)THEN
     fnd_message.set_name( G_APP_NAME,
                           'OKL_LLA_PERCENT');
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get);
 -- if more than one parameters is entered, considering p_remaining and p_currency
  -- as a single parameter, or no parameter is entered then throw an error.
  -- At least one of the parameter is mandatory.
  ELSIF( (p_percent is not null AND p_remaining is not null) OR
     (p_percent is not null AND l_date is not null) OR
     (l_date is not null AND p_remaining is not null) OR
     ( p_percent is not null AND p_days is not null) OR
     ( p_remaining is not null AND p_days is not null) OR
     ( l_date is not null AND p_days is not null)  OR
     (p_percent is null AND p_remaining is null AND l_date is null AND p_days is null AND p_currency is null)) THEN
     fnd_message.set_name( G_APP_NAME,
                           'OKL_SUBPOOL_ATLIMIT_PARAMS');
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get);
  -- if user has entered one of the parameters then print the report.
  ELSE
     print_atlimit_detail (p_percent,
                           p_remaining,
                           p_currency,
                           l_date,
                           p_days,
                           l_return_status,
                           l_msg_count,
                           l_msg_data);
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
  END IF;

  okl_api.END_ACTIVITY(l_msg_count, l_msg_data);

  IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
    okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRSIOB.pls call pool_atlimit_report');
  END IF;

EXCEPTION
     WHEN G_EXCEPTION_HALT_VALIDATION THEN
       l_return_status	:= OKL_API.HANDLE_EXCEPTIONS
       (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        l_msg_count,
        l_msg_data,
        '_PVT'
       );

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      l_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => l_msg_count,
                           x_msg_data  => l_msg_data,
                           p_api_type  => g_api_type);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      l_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => l_msg_count,
                           x_msg_data  => l_msg_data,
                           p_api_type  => g_api_type);

    WHEN OTHERS THEN
       x_errbuf := SQLERRM;
       x_retcode := 2;

       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: '||SQLERRM);

       IF (SQLCODE <> -20001) THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: '||SQLCODE||SQLERRM);
         --APP_EXCEPTION.RAISE_EXCEPTION;
          RAISE;
        ELSE
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: '||SQLCODE||SQLERRM);
          --g_error_message := Sqlerrm;
          APP_EXCEPTION.RAISE_EXCEPTION;
       END IF;

END pool_atlimit_report;

 ---------------------------------------------------------------------------
  -- FUNCTION GET_POOL_AMOUNTS
  ---------------------------------------------------------------------------
 ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : GET_POOL_AMOUNTS
  -- Description     : To determine the amounts for subsidy pool record.
  -- Business Rules  :
  -- Parameters      : p_pool_rec, p_input_date, p_to_currency_code, p_conv_type
  -- Version         : 1.0
  -- History         : 03-Jan-2007 UDHENUKO created.
  -- End of comments
  ---------------------------------------------------------------------------
 FUNCTION GET_POOL_AMOUNTS (p_pool_rec       IN okl_sub_pool_rec,
                             p_input_date       IN DATE,
                             p_to_currency_code IN VARCHAR2,
                             p_conv_type        IN VARCHAR2,
                             x_return_status    OUT NOCOPY VARCHAR2,
                             x_msg_count        OUT NOCOPY NUMBER,
                             x_msg_data         OUT NOCOPY VARCHAR2)
 RETURN pool_dtl_rec_type
 IS

 -- Cursor fetches all the records, which are children of a given pool till the pool,
 -- does not have any more children.
 CURSOR  get_amounts(cp_pool_id okl_subsidy_pools_b.id%TYPE) IS
  SELECT id ,
         currency_code,
         currency_conversion_type
  FROM okl_subsidy_pools_b pool
  WHERE pool_type_code = 'BUDGET'
  CONNECT BY PRIOR id = subsidy_pool_id
  START WITH id = cp_pool_id;

 x_errbuf                VARCHAR2(2000);
 x_retcode               NUMBER;
 x_pool_dtl_rec          pool_dtl_rec_type;
 l_total_budget          okl_subsidy_pools_b.total_budgets%TYPE;
 l_budget                okl_subsidy_pools_b.total_budgets%TYPE;
 l_trx_amount            okl_trx_subsidy_pools.trx_amount%TYPE ;
 l_trx_amt               okl_trx_subsidy_pools.trx_amount%TYPE ;
 l_remaining_balance     okl_subsidy_pools_b.total_budgets%TYPE;
 l_conv_rate             NUMBER;
 l_reporting_limit       okl_subsidy_pools_b.reporting_pool_limit%TYPE ;
 l_api_name              CONSTANT VARCHAR2(30) := 'GET_POOL_AMOUNTS';
 l_msg_count             NUMBER ;
 l_msg_data              VARCHAR2(2000);
 l_return_status         VARCHAR2(1);
 l_api_version           NUMBER ;
 l_init_msg_list         VARCHAR2(1);
 l_module                CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_SUBSIDY_POOL_RPT_PVT.GET_POOL_AMOUNTS';
 l_debug_enabled         VARCHAR2(10);
 is_debug_procedure_on   BOOLEAN;
 is_debug_statement_on   BOOLEAN;

 BEGIN
   l_debug_enabled := okl_debug_pub.check_log_enabled;
   is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
   IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
     okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRSIOB.pls call GET_POOL_AMOUNTS');
   END IF;
   -- check for logging on STATEMENT level
   is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);

   l_api_version := 1.0;
   l_init_msg_list := Okl_Api.g_false;
   l_msg_count := 0;
   l_total_budget := 0;
   l_budget := 0;
   l_trx_amount := 0;
   l_trx_amt := 0;
   l_remaining_balance := 0;
   l_conv_rate := 0;
   l_reporting_limit := p_pool_rec.reporting_pool_limit;

   x_pool_dtl_rec.reporting_limit := okl_accounting_util.format_amount(0,p_to_currency_code);
   x_pool_dtl_rec.total_budget := okl_accounting_util.format_amount(0,p_to_currency_code);
   x_pool_dtl_rec.remaining_balance := okl_accounting_util.format_amount(0,p_to_currency_code);

   l_return_status := OKL_API.START_ACTIVITY( l_api_name,
                                              G_PKG_NAME,
                                              l_init_msg_list,
                                              l_api_version,
                                              l_api_version,
                                              '_PVT',
                                              l_return_status);

   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

      -- Convert the reporting pool limit amount from pool currency to the pool currency.
      l_reporting_limit := currency_conversion(p_pool_rec.reporting_pool_limit,
                                               p_pool_rec.currency_code,
                                               p_to_currency_code,
                                               p_conv_type,
                                               p_pool_rec.effective_from_date,
                                               l_conv_rate
                                              );
       IF (l_reporting_limit < 0) THEN
         fnd_message.set_name( G_APP_NAME,
                               'OKL_POOL_CURR_CONV');
         fnd_message.set_token('FROM_CURR',
                               p_pool_rec.currency_code);
         fnd_message.set_token('TO_CURR',
                               p_to_currency_code);
         x_pool_dtl_rec.error_message := fnd_message.get;
       END IF;
      -- If subsidy pool is of type reporting then, calculate the total budgets and remaining balance for that pool,
      -- from all its children which are of type budget.
      IF(p_pool_rec.pool_type_code = 'REPORTING') THEN
          FOR each_row IN get_amounts(p_pool_rec.id) LOOP
                l_budget := total_budgets( each_row.id,
                                           p_input_date,
                                           each_row.currency_code,
                                           p_to_currency_code,
                                           p_conv_type,
                                           l_return_status,
                                           l_msg_count,
                                           l_msg_data
                                         );
                IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
                l_total_budget := l_total_budget + l_budget;
                l_trx_amt := transaction_amount( each_row.id,
                                                 p_input_date,
                                                 each_row.currency_code,
                                                 p_to_currency_code,
                                                 p_conv_type,
                                                 l_return_status,
                                                 l_msg_count,
                                                 l_msg_data
                                               );
                IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                   RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
                l_trx_amount := l_trx_amount + l_trx_amt;
          END LOOP;
      -- if subsidy pool type is budget, simply calculate the total budgets and remaining balance.
      ELSE
        l_budget := total_budgets( p_pool_rec.id,
                                   p_input_date,
                                   p_pool_rec.currency_code,
                                   p_to_currency_code,
                                   p_conv_type,
                                   l_return_status,
                                   l_msg_count,
                                   l_msg_data
                                 );
        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        l_total_budget := l_budget;
        l_trx_amt := transaction_amount( p_pool_rec.id,
                                         p_input_date,
                                         p_pool_rec.currency_code,
                                         p_to_currency_code,
                                         p_conv_type,
                                         l_return_status,
                                         l_msg_count,
                                         l_msg_data
                                       );
        IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        l_trx_amount := l_trx_amt;
      END IF;
      l_remaining_balance :=  l_total_budget - l_trx_amount;

      IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                 l_module,
                                 'l_reporting_limit '||l_reporting_limit||' l_total_budget '
                                 ||l_total_budget||' l_trx_amount '||l_trx_amount
                                 ||'l_remaining_balance'||l_remaining_balance
                                 );
      END IF; -- end of NVL(l_debug_enabled,'N')='Y'

      x_pool_dtl_rec.reporting_limit := okl_accounting_util.format_amount(l_reporting_limit,p_to_currency_code);
      x_pool_dtl_rec.total_budget := okl_accounting_util.format_amount(l_total_budget,p_to_currency_code);
      x_pool_dtl_rec.remaining_balance := okl_accounting_util.format_amount(l_remaining_balance,p_to_currency_code);

   okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
   x_return_status := l_return_status;
   x_msg_data      := l_msg_data;
   x_msg_count     := l_msg_count;

   RETURN x_pool_dtl_rec;

   IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
     okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRSIOB.pls call GET_POOL_AMOUNTS');
   END IF;

  EXCEPTION
     WHEN OTHERS THEN
       x_errbuf := SQLERRM;
       x_retcode := 2;

       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: '||SQLERRM);

       IF (SQLCODE <> -20001) THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: '||SQLCODE||SQLERRM);
        ELSE
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: '||SQLCODE||SQLERRM);
       END IF;

 END GET_POOL_AMOUNTS;
  -------------------------------------------------------------------------------
  -- FUNCTION XML_POOL_ASSOC_REPORT
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : XML_POOL_ASSOC_REPORT
  -- Description     : Function for Subsidy pool association Report Generation for
  --                   XML Publisher
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 03-Jan-2007 UDHENUKO created.
  -- End of comments
  -------------------------------------------------------------------------------
 FUNCTION  XML_POOL_ASSOC_REPORT RETURN BOOLEAN
 IS

 CURSOR  get_subsidy_pools(cp_pool_id okl_subsidy_pools_b.id%TYPE) IS
  SELECT nvl(parent.id,chld.id) parent_id,
  nvl(parent.subsidy_pool_name,chld.subsidy_pool_name) parent_subsidy_pool_name,
  LEVEL,
  decode(parent.id,NULL,parent.id,chld.id) chld_id,
  decode(parent.subsidy_pool_name,NULL,parent.subsidy_pool_name,chld.subsidy_pool_name) chld_subsidy_pool_name
  FROM okl_subsidy_pools_b parent,
  okl_subsidy_pools_b chld
  WHERE chld.pool_type_code IN('BUDGET', 'REPORTING')
   AND parent.id(+) = chld.subsidy_pool_id
  CONNECT BY PRIOR chld.id = chld.subsidy_pool_id START WITH chld.id = cp_pool_id
  AND ( 1 = (case when nvl(fnd_profile.value('OKLSUBPOOLGLOBALACCESS'),'N') = 'Y' then 1
           else
           (case when exists (select 'x'
                              from okl_subsidies_v
                              where subsidy_pool_id = chld.id
                              and org_id <> mo_global.get_current_org_id()) then 0
             else 1  end)
             end))
  ORDER BY LEVEL,
  parent.subsidy_pool_name;

 CURSOR get_pool_dtls(cp_pool_id okl_subsidy_pools_b.id%TYPE) IS
 SELECT id,
       subsidy_pool_name,
       pool_type_code,
       currency_code,
       currency_conversion_type,
       reporting_pool_limit,
       effective_from_date
  FROM   okl_subsidy_pools_b
 WHERE  id = cp_pool_id;

 x_errbuf              VARCHAR2(1000);
 x_retcode             NUMBER;
 x_pool_dtl_rec        pool_dtl_rec_type;
 x_chld_pool_dtl_rec   pool_dtl_rec_type;
 l_subsidy_pool_tbl    subsidy_pool_tbl_type;
 l_from_date           DATE;
 l_pool_rec            okl_sub_pool_rec;
 l_chld_pool_rec       okl_sub_pool_rec;
 l_input_pool_rec      okl_sub_pool_rec;
 l_total_budget        okl_subsidy_pools_b.total_budgets%TYPE ;
 l_trx_amount          okl_trx_subsidy_pools.trx_amount%TYPE ;
 l_remaining_balance   okl_subsidy_pools_b.total_budgets%TYPE;
 l_api_name            CONSTANT VARCHAR2(30) := 'XML_POOL_ASSOC_REPORT';
 l_msg_count	          NUMBER;
 l_msg_data	           VARCHAR2(2000);
 l_return_status	      VARCHAR2(1);
 l_api_version			      NUMBER;
 l_init_msg_list       VARCHAR2(1);
 l_sysdate             DATE ;
 l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_SUBSIDY_POOL_RPT_PVT.XML_POOL_ASSOC_REPORT';
 l_debug_enabled       VARCHAR2(10);
 is_debug_procedure_on BOOLEAN;
 is_debug_statement_on BOOLEAN;

 BEGIN
   l_debug_enabled := okl_debug_pub.check_log_enabled;
   is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
   IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
     okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRSIOB.pls call XML_POOL_ASSOC_REPORT');
   END IF;
   -- check for logging on STATEMENT level
   is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);

   l_api_version := 1.0;
   l_init_msg_list := Okl_Api.g_false;
   l_msg_count := 0;
   l_total_budget := 0;
   l_trx_amount := 0;
   l_remaining_balance := 0;
   l_sysdate := TRUNC(SYSDATE);

   l_return_status := OKL_API.START_ACTIVITY( l_api_name,
                                              G_PKG_NAME,
                                              l_init_msg_list,
                                              l_api_version,
                                              l_api_version,
                                              '_PVT',
                                              l_return_status);
   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

  l_from_date:= FND_DATE.CANONICAL_TO_DATE(P_DATE);

  -- Use this record to retain the currency of the input pool(user entered)
  OPEN get_pool_dtls(P_POOL_ID);
   FETCH  get_pool_dtls INTO l_input_pool_rec;
  CLOSE get_pool_dtls;

  FOR pool_row IN get_subsidy_pools(P_POOL_ID) LOOP

  -- Get all the details of this subsidy pool.
  OPEN get_pool_dtls(pool_row.parent_id);
   FETCH  get_pool_dtls INTO l_pool_rec;
  CLOSE get_pool_dtls;


  IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
     okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                             l_module,
                             'l_pool_rec.id '||l_pool_rec.id
                             );
  END IF; -- end of NVL(l_debug_enabled,'N')='Y'
  -- if that record is found then determine the pool amounts.
  IF (l_pool_rec.id is not null) THEN
     x_pool_dtl_rec := GET_POOL_AMOUNTS(l_pool_rec,
                         l_from_date,
                         l_input_pool_rec.currency_code,
                         l_input_pool_rec.currency_conversion_type,
                         l_return_status,
                         l_msg_count,
                         l_msg_data);
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
  ELSE
    l_pool_rec.subsidy_pool_name := NULL;
    l_pool_rec.pool_type_code := NULL;
    l_pool_rec.currency_code := NULL;
    x_pool_dtl_rec.reporting_limit := '0';
    x_pool_dtl_rec.total_budget := '0';
    x_pool_dtl_rec.remaining_balance := '0';
  END IF;
  -- Get all the details of this subsidy pool.
  OPEN get_pool_dtls(pool_row.chld_id);
   FETCH  get_pool_dtls INTO l_chld_pool_rec;
  CLOSE get_pool_dtls;

  IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
     okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                             l_module,
                             'l_chld_pool_rec.id '||l_chld_pool_rec.id
                             );
  END IF; -- end of NVL(l_debug_enabled,'N')='Y'

  -- if that record is found then determine the pool amounts.
  IF (l_chld_pool_rec.id is not null) THEN
     x_chld_pool_dtl_rec := GET_POOL_AMOUNTS(l_chld_pool_rec,
                         l_from_date,
                         l_input_pool_rec.currency_code,
                         l_input_pool_rec.currency_conversion_type,
                         l_return_status,
                         l_msg_count,
                         l_msg_data);
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
   ELSE
    l_chld_pool_rec.subsidy_pool_name := NULL;
    l_chld_pool_rec.pool_type_code := NULL;
    l_chld_pool_rec.currency_code := NULL;
    x_chld_pool_dtl_rec.reporting_limit := okl_accounting_util.format_amount(0,l_pool_rec.currency_code);
    x_chld_pool_dtl_rec.total_budget := okl_accounting_util.format_amount(0,l_pool_rec.currency_code);
    x_chld_pool_dtl_rec.remaining_balance := okl_accounting_util.format_amount(0,l_pool_rec.currency_code);
   END IF;
   INSERT INTO
          OKL_G_REPORTS_GT (VALUE1_TEXT,
		VALUE2_TEXT,
		VALUE3_TEXT,
		VALUE4_TEXT,
		VALUE5_TEXT,
		VALUE6_TEXT,
		VALUE7_TEXT,
		VALUE8_TEXT,
		VALUE9_TEXT,
		VALUE10_TEXT,
		VALUE11_TEXT,
		VALUE12_TEXT,
		VALUE13_TEXT,
		VALUE14_TEXT)
          VALUES
          (l_pool_rec.subsidy_pool_name,
          l_pool_rec.pool_type_code,
          l_pool_rec.currency_code,
          x_pool_dtl_rec.reporting_limit,
          x_pool_dtl_rec.total_budget,
          x_pool_dtl_rec.remaining_balance,
          x_pool_dtl_rec.error_message,
          l_chld_pool_rec.subsidy_pool_name,
          l_chld_pool_rec.pool_type_code,
          l_chld_pool_rec.currency_code,
          x_chld_pool_dtl_rec.reporting_limit,
          x_chld_pool_dtl_rec.total_budget,
          x_chld_pool_dtl_rec.remaining_balance,
	  x_chld_pool_dtl_rec.error_message
          );
   END LOOP;
   okl_api.END_ACTIVITY(l_msg_count, l_msg_data);

   IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
     okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRSIOB.pls call XML_POOL_ASSOC_REPORT');
   END IF;
   RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
       x_errbuf := SQLERRM;
       x_retcode := 2;

       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: '||SQLERRM);

       IF (SQLCODE <> -20001) THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: '||SQLCODE||SQLERRM);
        ELSE
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: '||SQLCODE||SQLERRM);
       END IF;

  END XML_POOL_ASSOC_REPORT;

  ---------------------------------------------------------------------------
  -- FUNCTION xml_print_atlimit_detail
  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : xml_print_atlimit_detail
  -- Description     : To insert the At-Limit subsidy pool detail into the
  --                   Global Temporary Table for XML Publisher.
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 03-Jan-2007 UDHENUKO created.
  -- End of comments
  ---------------------------------------------------------------------------
 FUNCTION xml_print_atlimit_detail
 RETURN BOOLEAN
 IS


 -- Cursor to fetch all the subsidy pools whose % reamining balance is
 -- less than or equal to the specified % balance.
 CURSOR c_get_percent(cp_percent NUMBER) IS
   SELECT id,
          subsidy_pool_name,
          currency_code,
          total_budgets,
          NVL(total_budgets - NVL(total_subsidy_amount,0),0) remaining_balance,
          case when NVL(total_budgets,0) = 0 then 0
               else ((total_budgets - NVL(total_subsidy_amount,0)) * 100) /total_budgets end percent_remaining,
          effective_to_date,
          decision_status_code
   FROM okl_subsidy_pools_b
   WHERE pool_type_code = 'BUDGET'
   AND   decision_status_code = 'ACTIVE'
   AND   CASE WHEN NVL(total_budgets,0) = 0 THEN 0
              ELSE ((total_budgets - NVL(total_subsidy_amount,0)) * 100) /total_budgets END <= cp_percent
   AND ( 1 = (case when nvl(fnd_profile.value('OKLSUBPOOLGLOBALACCESS'),'N') = 'Y' then 1
           else
           (case when exists (select 'x'
                              from okl_subsidies_v
                              where subsidy_pool_id = okl_subsidy_pools_b.id
                              and org_id <> mo_global.get_current_org_id()) then 0
             else 1  end)
             end));

 -- Cursor to fetch all the subsidy pools whose  reamining budget is
 -- less than or equal to the specified remaining budget.
 CURSOR c_get_budget(cp_remaining NUMBER, cp_currency okl_subsidy_pools_b.currency_code%TYPE) IS
   SELECT id,
          subsidy_pool_name,
          currency_code,
          total_budgets,
          NVL(total_budgets - NVL(total_subsidy_amount,0),0) remaining_balance,
          case when NVL(total_budgets,0) = 0 then 0
               else ((total_budgets - NVL(total_subsidy_amount,0)) * 100) /total_budgets end percent_remaining,
          effective_to_date,
          decision_status_code
   FROM okl_subsidy_pools_b
   WHERE pool_type_code = 'BUDGET'
   AND   decision_status_code = 'ACTIVE'
   AND   NVL(total_budgets - NVL(total_subsidy_amount,0),0) <= cp_remaining
   AND   currency_code = cp_currency
   AND ( 1 = (case when nvl(fnd_profile.value('OKLSUBPOOLGLOBALACCESS'),'N') = 'Y' then 1
           else
           (case when exists (select 'x'
                              from okl_subsidies_v
                              where subsidy_pool_id = okl_subsidy_pools_b.id
                              and org_id <> mo_global.get_current_org_id()) then 0
             else 1  end)
             end));

 -- Cursor to fetch all the subsidy pools whose effective to date lies
 -- between sysdate and user entered date.
 CURSOR c_get_dates(cp_date DATE) IS
   SELECT id,
          subsidy_pool_name,
          currency_code,
          total_budgets,
          NVL(total_budgets - NVL(total_subsidy_amount,0),0) remaining_balance,
          case when NVL(total_budgets,0) = 0 then 0
               else ((total_budgets - NVL(total_subsidy_amount,0)) * 100) /total_budgets end percent_remaining,
          effective_to_date
   FROM okl_subsidy_pools_b
   WHERE pool_type_code = 'BUDGET'
   AND   decision_status_code = 'ACTIVE'
   AND   TRUNC(effective_to_date) >= TRUNC(SYSDATE)
   AND   TRUNC(effective_to_date) <= TRUNC(cp_date)
   AND ( 1 = (case when nvl(fnd_profile.value('OKLSUBPOOLGLOBALACCESS'),'N') = 'Y' then 1
           else
           (case when exists (select 'x'
                              from okl_subsidies_v
                              where subsidy_pool_id = okl_subsidy_pools_b.id
                              and org_id <> mo_global.get_current_org_id()) then 0
             else 1  end)
             end));

 -- Cursor to fetch all the subsidy pools whose end of term days, calculated by pool's
 -- effective to date - sysdate, is less than or equal to the entered value.
 CURSOR c_get_days(cp_days NUMBER) IS
   SELECT id,
          subsidy_pool_name,
          currency_code,
          total_budgets,
          NVL(total_budgets - NVL(total_subsidy_amount,0),0) remaining_balance,
          case when NVL(total_budgets,0) = 0 then 0
               else ((total_budgets - NVL(total_subsidy_amount,0)) * 100) /total_budgets end percent_remaining,
          effective_to_date,
          trunc(effective_to_date) - trunc(sysdate) remaining_days
   FROM okl_subsidy_pools_b
   WHERE pool_type_code = 'BUDGET'
   AND   decision_status_code = 'ACTIVE'
   AND trunc(effective_to_date) - trunc(sysdate) between 0 and cp_days
   AND ( 1 = (case when nvl(fnd_profile.value('OKLSUBPOOLGLOBALACCESS'),'N') = 'Y' then 1
           else
           (case when exists (select 'x'
                              from okl_subsidies_v
                              where subsidy_pool_id = okl_subsidy_pools_b.id
                              and org_id <> mo_global.get_current_org_id()) then 0
             else 1  end)
             end));

 x_errbuf               VARCHAR2(1000);
 x_retcode              NUMBER;
 x_return_status		VARCHAR2(1);
 x_msg_count		    NUMBER;
 x_msg_data		        VARCHAR2(2000);
 l_date                 DATE;
 l_module               CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_SUBSIDY_POOL_RPT_PVT.XML_PRINT_ATLIMIT_DETAIL';
 l_debug_enabled        VARCHAR2(10);
 is_debug_procedure_on  BOOLEAN;
 is_debug_statement_on  BOOLEAN;
 l_parameter_list       WF_PARAMETER_LIST_T;
 l_event_name           wf_events.name%TYPE;
 l_api_version		        NUMBER;
 l_init_msg_list        VARCHAR2(1);
 l_return_status        VARCHAR2(1);
 l_msg_count	           NUMBER;
 l_msg_data	            VARCHAR2(2000);
 l_api_name             CONSTANT VARCHAR2(30) := 'xml_print_atlimit_detail';
 l_decision_status_code okl_subsidy_pools_b.decision_status_code%TYPE;

 BEGIN

   l_debug_enabled := okl_debug_pub.check_log_enabled;
   is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
   IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
     okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRSIOB.pls call xml_print_atlimit_detail');
   END IF;
   -- check for logging on STATEMENT level
   is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);

   l_api_version := 1.0;
   l_init_msg_list := Okl_Api.g_false;
   l_msg_count := 0;
   l_date:= FND_DATE.CANONICAL_TO_DATE(P_END_DATE);
   l_return_status := OKL_API.START_ACTIVITY( l_api_name,
                                              G_PKG_NAME,
                                              l_init_msg_list,
                                              l_api_version,
                                              l_api_version,
                                              '_PVT',
                                              l_return_status);
   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;


  -- If p_remaining is entered and p_currency is not entered or vice versa
  -- then throw an error, if any one of these parameter is entered then other
  -- one is mandatory parameter.
  IF ( P_REMAINING is not null AND P_CURRENCY is null) THEN
     fnd_message.set_name( G_APP_NAME,
                           'OKL_SUBPOOL_CURR_REQ');
     INSERT INTO
          OKL_G_REPORTS_GT(VALUE1_TEXT,
		VALUE2_TEXT)
          VALUES
          ('ERROR',
	  fnd_message.get
	  );

  ELSIF ( P_REMAINING is null AND P_CURRENCY is not null) THEN
     fnd_message.set_name( G_APP_NAME,
                           'OKL_SUBPOOL_REM_BDGT');
     INSERT INTO
          OKL_G_REPORTS_GT(VALUE1_TEXT,
		VALUE2_TEXT)
          VALUES
          ('ERROR',
	  fnd_message.get
	  );

  ELSIF (P_PERCENT is not null AND P_PERCENT > 100)THEN
     fnd_message.set_name( G_APP_NAME,
                           'OKL_LLA_PERCENT');
     INSERT INTO
          OKL_G_REPORTS_GT(VALUE1_TEXT,
		VALUE2_TEXT)
          VALUES
          ('ERROR',
	  fnd_message.get
	  );

  -- if more than one parameters is entered, considering p_remaining and p_currency
  -- as a single parameter, or no parameter is entered then throw an error.
  -- At least one of the parameter is mandatory.
  ELSIF( (P_PERCENT is not null AND P_REMAINING is not null) OR
     (P_PERCENT is not null AND l_date is not null) OR
     (l_date is not null AND P_REMAINING is not null) OR
     ( P_PERCENT is not null AND P_DAYS is not null) OR
     ( P_REMAINING is not null AND P_DAYS is not null) OR
     ( l_date is not null AND P_DAYS is not null)  OR
     (P_PERCENT is null AND P_REMAINING is null AND l_date is null AND P_DAYS is null AND P_CURRENCY is null)) THEN
     fnd_message.set_name( G_APP_NAME,
                           'OKL_SUBPOOL_ATLIMIT_PARAMS');
     INSERT INTO
          OKL_G_REPORTS_GT(VALUE1_TEXT,
		VALUE2_TEXT)
          VALUES
          ('ERROR',
	  fnd_message.get
	  );
  ELSE

    -- If p_percent parameter value is entered by user and other parameters value is null.
    IF(P_PERCENT is not null) THEN
       FOR each_row IN c_get_percent(P_PERCENT) LOOP
          wf_event.AddParameterToList(G_WF_ITM_SUB_POOL_ID, each_row.id, l_parameter_list);
          l_event_name := G_WF_EVT_POOL_NEAR_BUDGLMT;
          INSERT INTO
          OKL_G_REPORTS_GT(VALUE1_TEXT,
		VALUE2_TEXT,
		VALUE3_TEXT,
		VALUE4_TEXT,
		VALUE5_TEXT,
		VALUE6_TEXT,
		VALUE1_DATE)
          VALUES
          ('PERCENT',
          each_row.subsidy_pool_name,
          each_row.currency_code,
          okl_accounting_util.format_amount(each_row.total_budgets,each_row.currency_code),
          okl_accounting_util.format_amount(each_row.remaining_balance,each_row.currency_code),
          okl_accounting_util.format_amount(each_row.percent_remaining,each_row.currency_code),
          each_row.effective_to_date
          );

          -- Raise the business event "Pool nearing budget limit" for all the subsidy pool records found.
          raise_business_event(p_api_version     => l_api_version,
                               p_init_msg_list   => l_init_msg_list,
                               x_return_status   => l_return_status,
                               x_msg_count       => l_msg_count,
                               x_msg_data        => l_msg_data,
                               p_event_name      => l_event_name,
                               p_event_param_list => l_parameter_list
                              );
          IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
          -- If subsidy pool effective to date is less than the current sysdate and the subsidy pool
          -- status is other than "EXPIRED' than set the stauts to "EXPIRED'.
          IF(each_row.effective_to_date < TRUNC(SYSDATE) AND each_row.decision_status_code <> 'EXPIRED')THEN
             l_decision_status_code := 'EXPIRED';
             okl_subsidy_pool_pvt.set_decision_status_code ( l_api_version,
                                                             l_init_msg_list,
                                                             l_return_status,
                                                             l_msg_count,
                                                             l_msg_data,
                                                             each_row.id,
                                                             l_decision_status_code);
             IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
          END IF;
       END LOOP;
    ELSIF(P_REMAINING is not null) THEN
       FOR each_row IN c_get_budget(P_REMAINING,P_CURRENCY) LOOP
          wf_event.AddParameterToList(G_WF_ITM_SUB_POOL_ID, each_row.id, l_parameter_list);
          l_event_name := G_WF_EVT_POOL_NEAR_BUDGLMT;
          INSERT INTO
          OKL_G_REPORTS_GT(VALUE1_TEXT,
		VALUE2_TEXT,
		VALUE3_TEXT,
		VALUE4_TEXT,
		VALUE5_TEXT,
		VALUE6_TEXT,
		VALUE1_DATE)
          VALUES
          ('REMAINING',
          each_row.subsidy_pool_name,
          each_row.currency_code,
          okl_accounting_util.format_amount(each_row.total_budgets,each_row.currency_code),
          okl_accounting_util.format_amount(each_row.remaining_balance,each_row.currency_code),
          okl_accounting_util.format_amount(each_row.percent_remaining,each_row.currency_code),
          each_row.effective_to_date
          );

          -- Raise the business event "Pool nearing budget limit" for all the subsidy pool records found.
          raise_business_event(p_api_version     => l_api_version,
                               p_init_msg_list   => l_init_msg_list,
                               x_return_status   => l_return_status,
                               x_msg_count       => l_msg_count,
                               x_msg_data        => l_msg_data,
                               p_event_name      => l_event_name,
                               p_event_param_list => l_parameter_list
                              );
          IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
          -- If subsidy pool effective to date is less than the current sysdate and the subsidy pool
          -- status is other than "EXPIRED' than set the stauts to "EXPIRED'.
          IF(each_row.effective_to_date < TRUNC(SYSDATE) AND each_row.decision_status_code <> 'EXPIRED')THEN
             l_decision_status_code := 'EXPIRED';
             okl_subsidy_pool_pvt.set_decision_status_code ( l_api_version,
                                                             l_init_msg_list,
                                                             l_return_status,
                                                             l_msg_count,
                                                             l_msg_data,
                                                             each_row.id,
                                                             l_decision_status_code);
             IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
          END IF;
       END LOOP;
    ELSIF(l_date is not null) THEN
       l_date:= FND_DATE.CANONICAL_TO_DATE(l_date);
       FOR each_row IN c_get_dates(l_date) LOOP
          wf_event.AddParameterToList(G_WF_ITM_SUB_POOL_ID, each_row.id, l_parameter_list);
          l_event_name := G_WF_EVT_POOL_NEAR_EXPIR;
          INSERT INTO
          OKL_G_REPORTS_GT(VALUE1_TEXT,
		   VALUE2_TEXT,
		   VALUE3_TEXT,
		   VALUE4_TEXT,
		   VALUE5_TEXT,
		   VALUE6_TEXT,
		   VALUE1_DATE)
          VALUES
          ('DATE',
          each_row.subsidy_pool_name,
          each_row.currency_code,
          okl_accounting_util.format_amount(each_row.total_budgets,each_row.currency_code),
          okl_accounting_util.format_amount(each_row.remaining_balance,each_row.currency_code),
          okl_accounting_util.format_amount(each_row.percent_remaining,each_row.currency_code),
          each_row.effective_to_date
          );

          -- Raise the business event "Pool nearing expiration" for all the subsidy pool records found.
          raise_business_event(p_api_version     => l_api_version,
                               p_init_msg_list   => l_init_msg_list,
                               x_return_status   => l_return_status,
                               x_msg_count       => l_msg_count,
                               x_msg_data        => l_msg_data,
                               p_event_name      => l_event_name,
                               p_event_param_list => l_parameter_list
                              );
          IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
       END LOOP;
    ELSIF(P_DAYS is not null) THEN
       FOR each_row IN c_get_days(P_DAYS) LOOP
          wf_event.AddParameterToList(G_WF_ITM_SUB_POOL_ID, each_row.id, l_parameter_list);
          l_event_name := G_WF_EVT_POOL_NEAR_EXPIR;
          INSERT INTO
          OKL_G_REPORTS_GT(VALUE1_TEXT,
		  VALUE2_TEXT,
		  VALUE3_TEXT,
		  VALUE4_TEXT,
		  VALUE5_TEXT,
		  VALUE6_TEXT,
		  VALUE1_DATE,
		  VALUE1_NUM)
          VALUES
          ('DAYS',
          each_row.subsidy_pool_name,
          each_row.currency_code,
          okl_accounting_util.format_amount(each_row.total_budgets,each_row.currency_code),
          okl_accounting_util.format_amount(each_row.remaining_balance,each_row.currency_code),
          okl_accounting_util.format_amount(each_row.percent_remaining,each_row.currency_code),
          each_row.effective_to_date,
          each_row.remaining_days
          );

          -- Raise the business event "Pool nearing expiration" for all the subsidy pool records found.
          raise_business_event(p_api_version     => l_api_version,
                               p_init_msg_list   => l_init_msg_list,
                               x_return_status   => l_return_status,
                               x_msg_count       => l_msg_count,
                               x_msg_data        => l_msg_data,
                               p_event_name      => l_event_name,
                               p_event_param_list => l_parameter_list
                              );
          IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
       END LOOP;
    END IF;

   END IF;

   okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
   x_return_status := l_return_status;
   x_msg_data      := l_msg_data;
   x_msg_count     := l_msg_count;

  IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
     okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRSIOB.pls call xml_print_atlimit_detail');
   END IF;
   RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
       x_errbuf := SQLERRM;
       x_retcode := 2;

       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: '||SQLERRM);

       IF (SQLCODE <> -20001) THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: '||SQLCODE||SQLERRM);
        ELSE
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: '||SQLCODE||SQLERRM);
       END IF;

  END xml_print_atlimit_detail;

  ---------------------------------------------------------------------------
  -- PROCEDURE xml_print_pool_summary
  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : xml_print_pool_summary
  -- Description     : To insert the subsidy pool summary in
  --                   Global Temporary Table for XML Publisher.
  -- Business Rules  :
  -- Parameters      : p_pool_rec, p_from_date,p_to_date, x_return_status,
  --                   x_msg_count,x_msg_data
  -- Version         : 1.0
  -- History         : 03-Jan-2007 UDHENUKO created.
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE xml_print_pool_summary (p_pool_rec     IN okl_sub_pool_rec,
                             p_from_date     IN DATE,
                             p_to_date       IN DATE,
                             x_return_status OUT NOCOPY VARCHAR2,
                             x_msg_count     OUT NOCOPY NUMBER,
                             x_msg_data      OUT NOCOPY VARCHAR2 )
  IS

  -- Cursor to fetch all the children pools of a subsidy pool entered.
  CURSOR  get_amounts(cp_pool_id okl_subsidy_pools_b.id%TYPE) IS
  SELECT id ,
         currency_code
  FROM okl_subsidy_pools_v pool
  WHERE pool_type_code = 'BUDGET'
  CONNECT BY PRIOR id = subsidy_pool_id
  START WITH id = cp_pool_id;

  x_errbuf                VARCHAR2(1000);
  x_retcode               NUMBER;
  l_budget                okl_subsidy_pools_b.total_budgets%TYPE;
  l_trx_amt               okl_trx_subsidy_pools.trx_amount%TYPE ;
  l_amount                okl_trx_subsidy_pools.trx_amount%TYPE ;
  l_remaining_balance     okl_subsidy_pools_b.total_budgets%TYPE;
  l_api_name              CONSTANT VARCHAR2(30) := 'xml_print_pool_summary';
  l_msg_count	          NUMBER;
  l_msg_data	    	  VARCHAR2(2000);
  l_return_status	      VARCHAR2(1);
  l_api_version			  NUMBER;
  l_init_msg_list         VARCHAR2(1);
  l_module                CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_SUBSIDY_POOL_RPT_PVT.xml_print_pool_summary';
  l_debug_enabled         VARCHAR2(10);
  is_debug_procedure_on   BOOLEAN;
  is_debug_statement_on   BOOLEAN;

  BEGIN
   l_debug_enabled := okl_debug_pub.check_log_enabled;
   is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
   IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
     okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRSIOB.pls call xml_print_pool_summary');
   END IF;
   -- check for logging on STATEMENT level
   is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);

   l_api_version := 1.0;
   l_init_msg_list := Okl_Api.g_false;
   l_msg_count := 0;
   l_budget := 0;
   l_trx_amt := 0;
   l_amount := 0;
   l_remaining_balance := 0;

   l_return_status := OKL_API.START_ACTIVITY( l_api_name,
                                              G_PKG_NAME,
                                              l_init_msg_list,
                                              l_api_version,
                                              l_api_version,
                                              '_PVT',
                                              l_return_status);

   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   -- If subsidy pool type is "Budget" then pick the values for total budgets
   -- from the okl_subsidy_pools_b table and calculate the total transaction amount
   -- from the okl_trx_subsidy_pools table.
   IF (p_pool_rec.pool_type_code = 'BUDGET') THEN
      -- Parent pool header with the parent pool name.
      -- Calculate the total budgets for subsidy pool till the date specified.
      l_budget := total_budgets( p_pool_rec.id,
                                 p_to_date,
                                 p_pool_rec.currency_code,
                                 p_pool_rec.currency_code,
                                 p_pool_rec.currency_conversion_type,
                                 l_return_status,
                                 l_msg_count,
                                 l_msg_data
                                );
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- calculate the total transaction amount for the subsidy pool.
      l_trx_amt := transaction_amount( p_pool_rec.id,
                                       p_to_date,
                                       p_pool_rec.currency_code,
                                       p_pool_rec.currency_code,
                                       p_pool_rec.currency_conversion_type,
                                       l_return_status,
                                       l_msg_count,
                                       l_msg_data
                                      );
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- remaining balance for subsidy pool is total budgets minus the total transaction amount.
      l_remaining_balance :=  l_budget - l_trx_amt;

      IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
         okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                                 l_module,
                                 ' l_budget '||l_budget||' l_trx_amt '||l_trx_amt
                                 ||'l_remaining_balance'||l_remaining_balance
                                 );
      END IF; -- end of NVL(l_debug_enabled,'N')='Y'

      -- Insert the parent pool record into the Global Temporary Table
      INSERT INTO
        OKL_G_REPORTS_GT(VALUE1_TEXT,
		VALUE2_TEXT,
		VALUE3_TEXT,
		VALUE4_TEXT,
		VALUE5_TEXT,
		VALUE6_TEXT,
		VALUE7_TEXT,
		VALUE8_TEXT)
      VALUES
          ('POOL_SUMMRY',
          p_pool_rec.subsidy_pool_name,
          p_pool_rec.pool_type_code,
          p_pool_rec.currency_code,
          okl_accounting_util.format_amount(l_budget,p_pool_rec.currency_code),
          okl_accounting_util.format_amount(0,p_pool_rec.currency_code), -- Pool Limit
          okl_accounting_util.format_amount(l_trx_amt,p_pool_rec.currency_code),
          okl_accounting_util.format_amount(l_remaining_balance,p_pool_rec.currency_code)
          );

   -- if subsidy pool type is "Reporting" then the total budgets and total transaction amount
   -- is calculated from its children as there is no transaction and budgets for pool type "Reporting"
   ELSIF (p_pool_rec.pool_type_code = 'REPORTING') THEN

      -- For each of the children found for "Reporting" pool type
      FOR  each_row IN get_amounts(p_pool_rec.id) LOOP
         -- calculate the transaction amount and convert the children pool currency
         -- in to the "Reporting" pool currency.
         l_amount := transaction_amount ( each_row.id,
                                          p_to_date,
                                          each_row.currency_code,
                                          p_pool_rec.currency_code,
                                          p_pool_rec.currency_conversion_type,
                                          l_return_status,
                                          l_msg_count,
                                          l_msg_data
                                         );
         IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
         l_trx_amt := l_trx_amt + l_amount;
      END LOOP;
      -- Insert the parent pool record into the Global Temporary Table
      INSERT INTO
          OKL_G_REPORTS_GT(VALUE1_TEXT,
		    VALUE2_TEXT,
		    VALUE3_TEXT,
		    VALUE4_TEXT,
		    VALUE5_TEXT,
		    VALUE6_TEXT,
		    VALUE7_TEXT,
		    VALUE8_TEXT)
       VALUES
          ('POOL_SUMMRY',
          p_pool_rec.subsidy_pool_name,
          p_pool_rec.pool_type_code,
          p_pool_rec.currency_code,
          okl_accounting_util.format_amount(0,p_pool_rec.currency_code), -- Pool Budget
          okl_accounting_util.format_amount(p_pool_rec.reporting_pool_limit,p_pool_rec.currency_code),
          okl_accounting_util.format_amount(l_trx_amt,p_pool_rec.currency_code),
          okl_accounting_util.format_amount(0,p_pool_rec.currency_code) -- Pool Balance
	      );
   END IF;

   okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
   x_return_status := l_return_status;
   x_msg_data      := l_msg_data;
   x_msg_count     := l_msg_count;

   IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
     okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRSIOB.pls call xml_print_pool_summary');
   END IF;

  EXCEPTION
     WHEN OTHERS THEN
       x_errbuf := SQLERRM;
       x_retcode := 2;

       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: '||SQLERRM);

       IF (SQLCODE <> -20001) THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: '||SQLCODE||SQLERRM);
        ELSE
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: '||SQLCODE||SQLERRM);
       END IF;

  END xml_print_pool_summary;

  ---------------------------------------------------------------------------
  -- PROCEDURE xml_print_transaction_summary
  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : xml_print_transaction_summary
  -- Description     : To insert the subsidy pool transaction summary in
  --                   Global Temporary Table for XML Publisher.
  -- Business Rules  :
  -- Parameters      : p_pool_id, p_from_date, p_to_date, p_pool_type, p_pool_currency,
  --                   p_conv_type, x_return_status, x_msg_count, x_msg_data
  -- Version         : 1.0
  -- History         : 03-Jan-2007 UDHENUKO created.
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE xml_print_transaction_summary (p_pool_id       IN okl_subsidy_pools_b.id%TYPE,
                                     p_from_date     IN DATE,
                                     p_to_date       IN DATE,
                                     p_pool_type     IN okl_subsidy_pools_b.pool_type_code%TYPE,
                                     p_pool_currency IN okl_subsidy_pools_b.currency_code%TYPE,
                                     p_conv_type     IN okl_subsidy_pools_b.currency_conversion_type%TYPE,
                                     x_return_status OUT NOCOPY VARCHAR2,
                                     x_msg_count     OUT NOCOPY NUMBER ,
                                     x_msg_data      OUT NOCOPY VARCHAR2 )
  IS

  -- cursor to fetch all the transactions details for the subsidy pool between the dates entered by user.
  CURSOR c_transaction_detail(cp_pool_id okl_subsidy_pools_b.id%TYPE, cp_from_date DATE, cp_to_date DATE) IS
   SELECT flk1.meaning trx_reason,
        (case
           when pool.source_type_code = 'LEASE_CONTRACT' then
             (select khr.contract_number
              from okc_k_headers_b khr
              where khr.id = pool.source_object_id)
           when pool.source_type_code = 'SALES_QUOTE' then
             (select sq.reference_number
              from okl_lease_quotes_b sq
              where sq.id = pool.source_object_id)
           when pool.source_type_code = 'LEASE_APPLICATION' then
             (select lap.reference_number
              from okl_lease_applications_b lap,
                   okl_lease_quotes_b lsq
              where lsq.parent_object_id = lap.id
              and lsq.parent_object_code = 'LEASEAPP'
              and lsq.id = pool.source_object_id)
         end) contract_number,
         dnz_asset_number,
          vend.vendor_name Vendor,
          sub.name subsidy_name,
          trx_type_code,
          source_trx_date,
          trx_currency_code,
          trx_amount,
          subsidy_pool_currency_code,
          pool.conversion_rate,
          subsidy_pool_amount,
          trx_date,
          hru.name operating_unit
   FROM okl_trx_subsidy_pools pool,
        fnd_lookups flk1,
        po_vendors vend,
        okl_subsidies_b sub,
        hr_organization_units hru
  WHERE  flk1.lookup_type = 'OKL_SUB_POOL_TRX_REASON_TYPE'
   AND    flk1.lookup_code = pool.trx_reason_code
   AND vend.vendor_id = pool.vendor_id
   AND sub.id = pool.subsidy_id
   AND pool.subsidy_pool_id IN ( SELECT id
                                 FROM okl_subsidy_pools_b
                                 WHERE pool_type_code = 'BUDGET'
                                 CONNECT BY PRIOR id = subsidy_pool_id
                                 START WITH id = cp_pool_id
                                )
  AND sub.org_id = hru.organization_id
  ORDER BY trx_date asc;

  x_errbuf              VARCHAR2(1000);
  x_retcode             NUMBER;
  l_pool_amount         NUMBER;
  l_amount              NUMBER;
  l_conv_rate           NUMBER;
  l_sub_pool_amount     NUMBER;
  l_trx_amount          NUMBER;
  l_api_name            CONSTANT VARCHAR2(30) := 'xml_print_transaction_summary';
  l_msg_count	        NUMBER;
  l_msg_data	    	VARCHAR2(2000);
  l_return_status	    VARCHAR2(1);
  l_api_version			NUMBER;
  l_init_msg_list       VARCHAR2(1);
  l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_SUBSIDY_POOL_RPT_PVT.xml_print_transaction_summary';
  l_debug_enabled       VARCHAR2(10);
  is_debug_procedure_on BOOLEAN;
  is_debug_statement_on BOOLEAN;

  BEGIN

    l_debug_enabled := okl_debug_pub.check_log_enabled;
    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);

    IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
      okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRSIOB.pls call xml_print_transaction_summary');
    END IF;
    -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);

    l_api_version := 1.0;
    l_init_msg_list := Okl_Api.g_false;
    l_msg_count := 0;
    l_pool_amount := 0;
    l_amount := 0;
    l_conv_rate := 0;
    l_sub_pool_amount := 0;
    l_trx_amount := 0;

    l_return_status := OKL_API.START_ACTIVITY( l_api_name,
                                               G_PKG_NAME,
                                               l_init_msg_list,
                                               l_api_version,
                                               l_api_version,
                                               '_PVT',
                                               l_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF(p_pool_type = 'BUDGET') THEN
       FOR each_row IN c_transaction_detail(p_pool_id,p_from_date,p_to_date) LOOP
          -- If transaction line type is "Reduction" display the transaction amount as
          -- <transaction amount>.
          IF(each_row.trx_type_code = 'ADDITION') THEN
              l_trx_amount := each_row.trx_amount;
              l_sub_pool_amount :=  each_row.subsidy_pool_amount;
          ELSIF(each_row.trx_type_code = 'REDUCTION') THEN
              l_trx_amount := each_row.trx_amount * -1;
              l_sub_pool_amount :=  each_row.subsidy_pool_amount * -1;
          END IF;
          -- Insert the transactions record for the subsidy pool type "Budget" in
          -- Global Temporary Table.
          INSERT INTO
          OKL_G_REPORTS_GT(VALUE1_TEXT,
		VALUE2_TEXT,
		VALUE3_TEXT,
		VALUE4_TEXT,
		VALUE5_TEXT,
		VALUE6_TEXT,
		VALUE1_DATE,
		VALUE7_TEXT,
		VALUE1_NUM,
		VALUE8_TEXT,
		VALUE2_NUM,
		VALUE9_TEXT,
		VALUE10_TEXT)
          VALUES
          ('TRANS_SUMMRY',
          each_row.trx_reason,
          each_row.contract_number,
          each_row.dnz_asset_number,
          each_row.Vendor,
          each_row.subsidy_name,
          each_row.source_trx_date,
          okl_accounting_util.format_amount(l_trx_amount,each_row.trx_currency_code)
                   ||' '||each_row.trx_currency_code,
          each_row.conversion_rate,
          okl_accounting_util.format_amount(l_sub_pool_amount,each_row.subsidy_pool_currency_code)
                   ||' '|| each_row.subsidy_pool_currency_code,
          l_sub_pool_amount,
          each_row.operating_unit,
          each_row.subsidy_pool_currency_code
          );

          -- for all the transactions record  found add the transaction amount with type
          -- "Addition" and reduce the  amount with type "Reduction".
          IF(each_row.trx_type_code = 'ADDITION') THEN
             l_pool_amount := l_pool_amount + each_row.subsidy_pool_amount;
          ELSE
             l_pool_amount := l_pool_amount - each_row.subsidy_pool_amount;
          END IF;
       END LOOP;

    ELSIF(p_pool_type = 'REPORTING') THEN
       FOR each_row IN c_transaction_detail(p_pool_id,p_from_date,p_to_date) LOOP
          -- If pool type is "Reporting", the transaction amount for all children "Budget"
          -- pool is converted in to the parent "Reporting" pool currency and this amount
          -- is displayed as a "Reporting amount".
          l_amount := currency_conversion(each_row.trx_amount,
                                          each_row.trx_currency_code,
                                          p_pool_currency,
                                          p_conv_type,
                                          each_row.trx_date,
                                          l_conv_rate
                                         );
          -- if negative value is returned display the error that the conversion between
          -- the two currencies is not found.
          IF (l_amount < 0) THEN
            fnd_message.set_name( G_APP_NAME,
                                  'OKL_POOL_CURR_CONV');
            fnd_message.set_token('FROM_CURR',
                                  each_row.subsidy_pool_currency_code);
            fnd_message.set_token('TO_CURR',
                                  p_pool_currency);
            FND_FILE.PUT_LINE(FND_FILE.OUTPUT,fnd_message.get);
          END IF;
          -- If transaction line type is "Reduction" display the transaction amount as
          -- <transaction amount>.
          IF(each_row.trx_type_code = 'ADDITION') THEN
              l_trx_amount := each_row.trx_amount;
              l_sub_pool_amount :=  l_amount;
          ELSIF(each_row.trx_type_code = 'REDUCTION') THEN
              l_trx_amount := each_row.trx_amount * -1;
              l_sub_pool_amount :=  l_amount * -1;
          END IF;
          -- Insert the transactions record for the subsidy pool in
          -- Global Temporary Table.
          INSERT INTO
          OKL_G_REPORTS_GT(VALUE1_TEXT,
		  VALUE2_TEXT,
		  VALUE3_TEXT,
		  VALUE4_TEXT,
		  VALUE5_TEXT,
		  VALUE6_TEXT,
		  VALUE1_DATE,
		  VALUE7_TEXT,
		  VALUE1_NUM,
		  VALUE8_TEXT,
		  VALUE2_NUM,
		  VALUE9_TEXT,
		  VALUE10_TEXT)
          VALUES
          ('TRANS_SUMMRY',
          each_row.trx_reason,
          each_row.contract_number,
          each_row.dnz_asset_number,
          each_row.Vendor,
          each_row.subsidy_name,
          each_row.source_trx_date,
          okl_accounting_util.format_amount(l_trx_amount,each_row.trx_currency_code)
                   ||' '||each_row.trx_currency_code,
          l_conv_rate,
          okl_accounting_util.format_amount(l_sub_pool_amount,p_pool_currency)
                   ||' '|| p_pool_currency,
          l_sub_pool_amount,
          each_row.operating_unit,
          each_row.subsidy_pool_currency_code
          );

          -- for all the transactions record  found add the transaction amount with type
          -- "Addition" and reduce the  amount with type "Reduction".
          IF(each_row.trx_type_code = 'ADDITION') THEN
             l_pool_amount := l_pool_amount + l_amount;
          ELSE
             l_pool_amount := l_pool_amount - l_amount;
          END IF;
       END LOOP;
    END IF;

   okl_api.END_ACTIVITY(x_msg_count, x_msg_data);
   x_return_status := l_return_status;
   x_msg_data      := l_msg_data;
   x_msg_count     := l_msg_count;

   IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
     okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRSIOB.pls call xml_print_transaction_summary');
   END IF;

  EXCEPTION
     WHEN OTHERS THEN
       x_errbuf := SQLERRM;
       x_retcode := 2;

       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: '||SQLERRM);

       IF (SQLCODE <> -20001) THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: '||SQLCODE||SQLERRM);
        ELSE
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: '||SQLCODE||SQLERRM);
       END IF;

  END xml_print_transaction_summary;

  -------------------------------------------------------------------------------
  -- FUNCTION XML_POOL_RECONC_REPORT
  -------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : XML_POOL_RECONC_REPORT
  -- Description     : Function for Subsidy pool reconciliation Report Generation
  --                   in XML Publisher
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- History         : 03-Jan-2007 UDHENUKO created.
  -- End of comments
  -------------------------------------------------------------------------------

  FUNCTION  XML_POOL_RECONC_REPORT RETURN BOOLEAN
  IS

  x_errbuf		        VARCHAR2(2000);
  x_retcode		        NUMBER;
  l_pool_rec            okl_sub_pool_rec;
  l_bdgt_pool_rec       okl_sub_pool_rec;
  l_from_date           DATE;
  l_to_date             DATE;
  l_api_name            CONSTANT VARCHAR2(30) := 'XML_POOL_RECONC_REPORT';
  l_msg_count     	    NUMBER;
  l_msg_data	        VARCHAR2(2000);
  l_return_status	    VARCHAR2(1);
  l_api_version	     	NUMBER;
  l_init_msg_list       VARCHAR2(1);
  l_count               NUMBER;
  l_sysdate             DATE;
  l_module              CONSTANT fnd_log_messages.module%TYPE := 'okl.plsql.OKL_SUBSIDY_POOL_RPT_PVT.XML_POOL_RECONC_REPORT';
  l_debug_enabled       VARCHAR2(10);
  is_debug_procedure_on BOOLEAN;
  is_debug_statement_on BOOLEAN;

  BEGIN
   l_debug_enabled := okl_debug_pub.check_log_enabled;
   is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_PROCEDURE);
   IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
     okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'begin debug OKLRSIOB.pls call XML_POOL_RECONC_REPORT');
   END IF;
   -- check for logging on STATEMENT level
   is_debug_statement_on := okl_debug_pub.check_log_on(l_module,FND_LOG.LEVEL_STATEMENT);

   l_api_version := 1.0;
   l_init_msg_list := Okl_Api.g_false;
   l_msg_count := 0;
   l_sysdate := TRUNC(SYSDATE);

   l_return_status := OKL_API.START_ACTIVITY( l_api_name,
                                              G_PKG_NAME,
                                              l_init_msg_list,
                                              l_api_version,
                                              l_api_version,
                                              '_PVT',
                                              l_return_status);
   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
   ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

  l_from_date:= FND_DATE.CANONICAL_TO_DATE(P_FROM_DATE);
  l_to_date:= FND_DATE.CANONICAL_TO_DATE(P_TO_DATE);

  -- Get the record for user entered pool name.
  l_pool_rec := get_parent_record(P_POOL_ID);

  IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
     okl_debug_pub.log_debug(FND_LOG.LEVEL_STATEMENT,
                             l_module,
                             'l_pool_rec.id '||l_pool_rec.id
                             );
  END IF; -- end of NVL(l_debug_enabled,'N')='Y'

  l_count := 0;

  -- If record is found in the table then print the pool details region
  -- and the transaction details region.
  IF (l_pool_rec.id is not null) THEN
     xml_print_pool_summary(l_pool_rec,
                        l_from_date,
                        l_to_date,
                        l_return_status,
                        l_msg_count,
                        l_msg_data
                       );
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
     xml_print_transaction_summary (P_POOL_ID,
                                l_from_date,
                                l_to_date,
                                l_pool_rec.pool_type_code,
                                l_pool_rec.currency_code,
                                l_pool_rec.currency_conversion_type,
                                l_return_status,
                                l_msg_count,
                                l_msg_data
                               );
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
   END IF;

   okl_api.END_ACTIVITY(l_msg_count, l_msg_data);

   IF(l_debug_enabled='Y' AND is_debug_procedure_on) THEN
     okl_debug_pub.log_debug(FND_LOG.LEVEL_PROCEDURE,l_module,'end debug OKLRSIOB.pls call XML_POOL_RECONC_REPORT');
   END IF;
   RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
       x_errbuf := SQLERRM;
       x_retcode := 2;

       FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: '||SQLERRM);

       IF (SQLCODE <> -20001) THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: '||SQLCODE||SQLERRM);
       ELSE
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: '||SQLCODE||SQLERRM);
       END IF;

  END XML_POOL_RECONC_REPORT;

END okl_subsidy_pool_rpt_pvt;

/
