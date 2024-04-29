--------------------------------------------------------
--  DDL for Package Body OKC_OC_INT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_OC_INT_PUB" AS
/* $Header: OKCPORDB.pls 120.1 2005/12/13 03:07:29 npalepu noship $ */
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

-------------------------------------------------------------------------------
--
-- global package structures
--
-------------------------------------------------------------------------------
--
-- global constants
--
G_EXCEPTION_HALT_VALIDATION     EXCEPTION;
G_UNEXPECTED_ERROR              CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
G_SQLCODE_TOKEN        	        CONSTANT VARCHAR2(200) := 'SQLCODE';
G_SQLERRM_TOKEN  		CONSTANT VARCHAR2(200) := 'SQLERRM';
G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKC_OC_INT_PUB';
G_APP_NAME			CONSTANT VARCHAR2(3)   := OKC_API.G_APP_NAME;
G_FND_APP			CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
G_API_TYPE                      VARCHAR2(30)           := '_PROCESS';

L_LOG_ENABLED			VARCHAR2(200);

-------------------------------------------------------------------------------
--
-- APIs: K->Q
--
-------------------------------------------------------------------------------
--
-- Procedure:       create_quote_for_renewal
-- Version:         1.0
-- Purpose:         Create a quote from a contract.
--                  This API is used in the outcome queue.
--                  This will be a wrapper for create_quote_from_k
--                  procedure described bellow

PROCEDURE create_quote_for_renewal(p_init_msg_list   IN VARCHAR2
                                  ,x_return_status   OUT NOCOPY VARCHAR2
                                  ,x_msg_count       OUT NOCOPY NUMBER
                                  ,x_msg_data        OUT NOCOPY VARCHAR2
                                  ,p_contract_id     IN  OKC_K_HEADERS_B.ID%TYPE
				  ,p_trace_mode      IN  VARCHAR2
                                  ) IS

l_api_version           CONSTANT NUMBER := 1;
l_rel_type              OKC_K_REL_OBJS.rty_code%TYPE:=OKC_OC_INT_KTQ_PVT.g_rlt_cod_qrk;
lx_quote_id             okx_quote_headers_v.id1%TYPE;

BEGIN
  --
  -- call full version of create_quote_from_k
  --
  OKC_OC_INT_PUB.create_quote_from_k(p_api_version   => l_api_version
                                    ,p_init_msg_list => OKC_API.G_TRUE
                                    ,p_commit        => OKC_API.G_TRUE
                                    ,x_return_status => x_return_status
                                    ,x_msg_count     => x_msg_count
                                    ,x_msg_data      => x_msg_data
				    --
                                    ,p_contract_id   => p_contract_id
				    ,p_rel_type      => l_rel_type
				     --
                                    ,p_trace_mode    => p_trace_mode
                                    ,x_quote_id      => lx_quote_id);

  -- no need to check for errors, message stack should be set,
  -- nothing to return to caller
END create_quote_for_renewal;

-------------------------------------------------------------------------------

-- Procedure:       create_quote_from_k
-- Version:         1.0
-- Purpose:         Create a quote from a contract.
--                  This API is used in a concurrent program definition
--                  This will be a wrapper for create_quote_from_k
--                  procedure described bellow

PROCEDURE create_quote_from_k(ERRBUF              OUT NOCOPY VARCHAR2
			     ,RETCODE             OUT NOCOPY NUMBER
			     --
                             ,p_contract_category IN  OKC_K_HEADERS_B.SCS_CODE%TYPE
                             ,p_contract_number   IN  OKC_K_HEADERS_B.ID%TYPE
			     -- Contains in fact the contract ID
			     ,p_rel_type          IN  FND_LOOKUPS.LOOKUP_CODE%TYPE
			     ,p_trace_mode        IN  VARCHAR2
                              ) IS

l_api_version           CONSTANT NUMBER := 1;
lx_quote_id             okx_quote_headers_v.id1%TYPE := NULL;
lx_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
lx_msg_count            NUMBER := 0;
lx_msg_data             VARCHAR2(2000);
l_trace_mode            VARCHAR2(1) := OKC_API.G_TRUE;

BEGIN
  --
  -- call full version of create_quote_from_k
  --
  IF p_trace_mode = OKC_API.G_MISS_CHAR OR p_trace_mode IS NULL THEN
	l_trace_mode:=OKC_API.G_TRUE;
  ELSE
	l_trace_mode:=p_trace_mode;
  END IF;
  OKC_OC_INT_PUB.create_quote_from_k(p_api_version   => l_api_version
                                    ,p_init_msg_list => OKC_API.G_TRUE
                                    ,p_commit        => OKC_API.G_TRUE
                                    ,x_return_status => lx_return_status
                                    ,x_msg_count     => lx_msg_count
                                    ,x_msg_data      => lx_msg_data
				    --
                                    ,p_contract_id   => p_contract_number
				    ,p_rel_type      => p_rel_type
				    --
                                    ,p_trace_mode    => l_trace_mode
                                    ,x_quote_id      => lx_quote_id);

  -- no need to check for errors, message stack should be set,
  -- nothing to return to caller
  IF lx_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	IF lx_quote_id IS NULL THEN
	   RETCODE := 2;
	ELSE
	   RETCODE := 1;
	END IF;
  ELSE
	RETCODE:=0;
  END IF;
  ERRBUF:=lx_msg_data;
END create_quote_from_k;

--
-- full version of the procedure to create a quote from a contract
--

PROCEDURE create_quote_from_k(p_api_version       IN  NUMBER
                             ,p_init_msg_list     IN  VARCHAR2
                             ,p_commit            IN  VARCHAR2
                             ,x_return_status     OUT NOCOPY VARCHAR2
                             ,x_msg_count         OUT NOCOPY NUMBER
                             ,x_msg_data          OUT NOCOPY VARCHAR2
			     --
                             ,p_contract_id       IN  OKC_K_HEADERS_B.ID%TYPE
			     ,p_rel_type          IN  OKC_K_REL_OBJS.rty_code%TYPE
			     --
			     ,p_trace_mode        IN  VARCHAR2
                             ,x_quote_id          OUT NOCOPY okx_quote_headers_v.id1%TYPE
                             ) IS

l_api_name	    CONSTANT VARCHAR2(30) := 'CREATE_Q_FROM_K';
l_api_version	    CONSTANT NUMBER	   := 1;
lx_return_status    VARCHAR2(1)	   := OKC_API.G_RET_STS_SUCCESS;
lx_msg_count        NUMBER := 0;
lx_msg_data         VARCHAR2(2000);
l_trace_mode        VARCHAR2(1);

BEGIN
  -- call START_ACTIVITY to create savepoint, check compatibility
  -- and initialize message list
  lx_return_status := OKC_API.START_ACTIVITY(
					p_api_name      => l_api_name,
					p_pkg_name      => g_pkg_name,
					p_init_msg_list => p_init_msg_list,
					l_api_version   => l_api_version,
					p_api_version   => p_api_version,
					p_api_type      => g_api_type,
					x_return_status => lx_return_status);

  -- check if activity started successfully
  IF (lx_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (lx_return_status = OKC_API.G_RET_STS_ERROR) THEN
     RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  -- call before user hooks
  null;

  -- trace mode initialization turned ON
  IF p_trace_mode = okc_api.g_true OR
	FND_PROFILE.VALUE('AFLOG_ENABLED') = 'Y' OR
	p_trace_mode = okc_oc_int_ktq_pvt.g_support THEN
	l_trace_mode := okc_api.g_true;
	okc_util.init_trace;
  ELSE
-- Bug 2234902
         okc_util.set_trace_context(FND_GLOBAL.conc_request_id, lx_return_status);
         okc_util.l_output_flag :=TRUE;
         lx_return_status    := OKC_API.G_RET_STS_SUCCESS;
--  End Bug 2234902
	l_trace_mode := okc_api.g_false;
  END IF;

  -- call the main routine
  OKC_OC_INT_KTQ_PVT.create_quote_from_k(p_api_version   => l_api_version
                                        ,p_init_msg_list => OKC_API.G_FALSE
                                        ,x_return_status => lx_return_status
                                        ,x_msg_count     => lx_msg_count
                                        ,x_msg_data      => lx_msg_data
								--
                                        ,p_contract_id   => p_contract_id
					,p_rel_type      => p_rel_type
								--
                                        ,p_trace_mode    => l_trace_mode
                                        ,x_quote_id      => x_quote_id
                                        );

  -- trace mode initialization turned OFF
  IF l_trace_mode = okc_api.g_true OR  FND_PROFILE.VALUE('AFLOG_ENABLED') = 'Y' THEN
	okc_util.stop_trace;
  END IF;

  -- check return status
  IF lx_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF lx_return_status = OKC_API.G_RET_STS_ERROR THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  -- call AFTER user hook
  null;

  -- if we got this far, then we are successful
  IF p_trace_mode <> okc_oc_int_ktq_pvt.g_support OR
	p_trace_mode IS NULL THEN
     IF p_commit = OKC_API.G_TRUE THEN
        COMMIT;
     END IF;
  END IF;


  -- end activity
  OKC_API.END_ACTIVITY(	x_msg_count		=> lx_msg_count,
  			x_msg_data		=> lx_msg_data);

  x_return_status := lx_return_status;
  x_msg_count     := lx_msg_count;
  x_msg_data      := lx_msg_data;

  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
						p_api_name  => l_api_name,
						p_pkg_name  => g_pkg_name,
						p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
						x_msg_count => x_msg_count,
						x_msg_data  => x_msg_data,
						p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
						p_api_name  => l_api_name,
						p_pkg_name  => g_pkg_name,
						p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
						x_msg_count => x_msg_count,
						x_msg_data  => x_msg_data,
						p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
						p_api_name  => l_api_name,
						p_pkg_name  => g_pkg_name,
						p_exc_name  => 'OTHERS',
						x_msg_count => x_msg_count,
						x_msg_data  => x_msg_data,
						p_api_type  => g_api_type);

END create_quote_from_k;

-------------------------------------------------------------------------------
-- Procedure:       update_quote_from_k
-- Version:         1.0
-- Purpose:         update a quote from a contract.
--                  This API is used in a concurrent program definition
--                  This will be a wrapper for update_quote_from_k
--                  procedure described below

PROCEDURE update_quote_from_k(ERRBUF              OUT NOCOPY VARCHAR2
			     ,RETCODE             OUT NOCOPY NUMBER
                	--
                             ,p_contract_number   IN  OKC_K_HEADERS_B.ID%TYPE
                             -- p_contract_number is in fact equal to contract ID
                	--
                             ,p_quote_number      IN  OKX_QUOTE_HEADERS_V.ID1%TYPE
                             -- p_quote_number is in fact equal to quote ID
                	--
                             ,p_trace_mode        IN  VARCHAR2

                              ) IS

l_api_version           CONSTANT NUMBER := 1;
l_trace_mode            VARCHAR2(1) := OKC_API.G_TRUE;
--
lx_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
lx_msg_count            NUMBER := 0;
lx_msg_data             VARCHAR2(2000);

BEGIN
  --
  -- call full version of update_quote_from_k
  --
  IF p_trace_mode = OKC_API.G_MISS_CHAR OR p_trace_mode IS NULL THEN
	l_trace_mode:=OKC_API.G_TRUE;
  ELSE
	l_trace_mode:=p_trace_mode;
  END IF;
  OKC_OC_INT_PUB.update_quote_from_k(p_api_version   => l_api_version
                                    ,p_init_msg_list => OKC_API.G_FALSE
                                    ,p_commit        => OKC_API.G_FALSE
				--
                                    ,p_quote_id      => p_quote_number
                                    ,p_contract_id   => p_contract_number
				--
                                    ,p_trace_mode    => l_trace_mode
				--
                                    ,x_return_status => lx_return_status
                                    ,x_msg_count     => lx_msg_count
                                    ,x_msg_data      => lx_msg_data );


  -- no need to check for errors, message stack should be set,
  -- nothing to return to caller
  IF lx_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
--	IF lx_quote_id IS NULL THEN
--	   RETCODE := 2;
--	ELSE
--	   RETCODE := 1;
--	END IF;
        RETCODE := 2;
  ELSE
	RETCODE:=0;
  END IF;
  ERRBUF:=lx_msg_data;
END update_quote_from_k;

--
-- full version of the procedure to update a quote from a contract
--

PROCEDURE update_quote_from_k(p_api_version     IN  NUMBER
                             ,p_init_msg_list   IN  VARCHAR2
                             ,p_commit          IN  VARCHAR2
			--
                             ,p_quote_id        IN  OKX_QUOTE_HEADERS_V.id1%TYPE
                             ,p_contract_id     IN  OKC_K_HEADERS_B.ID%TYPE
			--
                             ,p_trace_mode      IN  VARCHAR2
			--
                             ,x_return_status   OUT NOCOPY VARCHAR2
                             ,x_msg_count       OUT NOCOPY NUMBER
                             ,x_msg_data        OUT NOCOPY VARCHAR2
                             ) IS

l_api_name	    CONSTANT VARCHAR2(30) := 'UPDATE_Q_FROM_K';
l_api_version	    CONSTANT NUMBER	   := 1;
l_trace_mode        VARCHAR2(1);
--
lx_return_status    VARCHAR2(1)	   := OKC_API.G_RET_STS_SUCCESS;
lx_msg_count        NUMBER := 0;
lx_msg_data         VARCHAR2(2000);

BEGIN

   NULL;

/* ----------- COMMENTING THE FOLLWOING SECTION OF CODE --------------------
** This API is desupported following marcio's disccussion with Tony Goughan
** and Srini( Istore Director ).  This feature cannot be delivered because
** iStore team could not deliver the required functionality to support the
** Business Flows( Update Quote API's were not ready.., Quote Status model
** was not ready etc..)
** Also it was agreed that this peice of code would be owned by iStore team
** if at a later date we had to support business flow that requires updating
** quote from a contract..
** Date: 09/13/2001
**  -- call START_ACTIVITY to create savepoint, check compatibility
**  -- and initialize message list
**  lx_return_status := OKC_API.START_ACTIVITY(
**					p_api_name      => l_api_name,
**					p_pkg_name      => g_pkg_name,
**					p_init_msg_list => p_init_msg_list,
**					l_api_version   => l_api_version,
**					p_api_version   => p_api_version,
**					p_api_type      => g_api_type,
**					x_return_status => lx_return_status);
**
**  -- check if activity started successfully
**  IF (lx_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
**     RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
**  ELSIF (lx_return_status = OKC_API.G_RET_STS_ERROR) THEN
**     RAISE OKC_API.G_EXCEPTION_ERROR;
**  END IF;
**
**  -- call before user hooks
**  null;
**
**  -- trace mode initialization turned ON
**  IF p_trace_mode = okc_api.g_true OR
**	FND_PROFILE.VALUE('AFLOG_ENABLED') = 'Y' OR
**	p_trace_mode = okc_oc_int_ktq_pvt.g_support THEN
**	l_trace_mode := okc_api.g_true;
**	okc_util.init_trace;
**  ELSE
**	l_trace_mode := okc_api.g_false;
**  END IF;
**
**  -- call the main routine
**  OKC_OC_INT_KTQ_PVT.update_quote_from_k(
**					 p_api_version   => l_api_version
**                                        ,p_init_msg_list => OKC_API.G_FALSE
**				--
**                                        ,p_quote_id      => p_quote_id
**                                        ,p_contract_id   => p_contract_id
**				--
**                                        ,p_trace_mode    => l_trace_mode
**				--
**                                        ,x_return_status => lx_return_status
**                                        ,x_msg_count     => lx_msg_count
**                                        ,x_msg_data      => lx_msg_data  );
**
**  -- trace mode initialization turned OFF
**  IF l_trace_mode = okc_api.g_true OR  FND_PROFILE.VALUE('AFLOG_ENABLED') = 'Y' THEN
**	okc_util.stop_trace;
**  END IF;
**
**  -- check return status
**  IF lx_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
**    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
**  ELSIF lx_return_status = OKC_API.G_RET_STS_ERROR THEN
**    RAISE OKC_API.G_EXCEPTION_ERROR;
**  END IF;
**
**  -- call AFTER user hook
**  null;
**
**  -- if we got this far, then we are successful
**  IF p_trace_mode <> okc_oc_int_ktq_pvt.g_support OR
**	p_trace_mode IS NULL THEN
**     IF p_commit = OKC_API.G_TRUE THEN
**        COMMIT;
**     END IF;
**  END IF;
**
**
**  -- end activity
**  OKC_API.END_ACTIVITY(	x_msg_count		=> lx_msg_count,
**  			x_msg_data		=> lx_msg_data);
**
*/
  x_return_status := lx_return_status;
  x_msg_count     := lx_msg_count;
  x_msg_data      := lx_msg_data;

  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
						p_api_name  => l_api_name,
						p_pkg_name  => g_pkg_name,
						p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
						x_msg_count => x_msg_count,
						x_msg_data  => x_msg_data,
						p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
						p_api_name  => l_api_name,
						p_pkg_name  => g_pkg_name,
						p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
						x_msg_count => x_msg_count,
						x_msg_data  => x_msg_data,
						p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
						p_api_name  => l_api_name,
						p_pkg_name  => g_pkg_name,
						p_exc_name  => 'OTHERS',
						x_msg_count => x_msg_count,
						x_msg_data  => x_msg_data,
						p_api_type  => g_api_type);

END update_quote_from_k;

-------------------------------------------------------------------------------
--
-- APIs: K->O
--
-------------------------------------------------------------------------------

-- Procedure:       create_order_from_k
-- Version:         1.0
-- Purpose:         Create an order from a contract.
--                  This API is used in a concurrent program definition
--                  This will be a wrapper for create_order_from_k
--                  procedure described above


PROCEDURE create_order_from_k(ERRBUF              OUT NOCOPY VARCHAR2
			     ,RETCODE             OUT NOCOPY NUMBER
			     --
                             ,p_contract_category IN  OKC_K_HEADERS_B.SCS_CODE%TYPE
                             ,p_contract_number   IN  OKC_K_HEADERS_B.ID%TYPE
			     -- Contains in fact the contract ID
			     ,p_rel_type          IN  FND_LOOKUPS.LOOKUP_CODE%TYPE
			     ,p_trace_mode        IN  VARCHAR2
                              ) IS

l_api_version           CONSTANT NUMBER := 1;
lx_order_id             okx_order_headers_v.id1%TYPE := NULL;
lx_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
lx_msg_count            NUMBER := 0;
lx_msg_data             VARCHAR2(2000);
l_trace_mode            VARCHAR2(1) := OKC_API.G_TRUE;

BEGIN
  --
  -- call full version of create_order_from_k
  --
  IF p_trace_mode = OKC_API.G_MISS_CHAR OR p_trace_mode IS NULL THEN
	l_trace_mode:=OKC_API.G_TRUE;
  ELSE
	l_trace_mode:=p_trace_mode;
  END IF;
  OKC_OC_INT_PUB.create_order_from_k(p_api_version   => l_api_version
                                    ,p_init_msg_list => OKC_API.G_TRUE
                                    ,p_commit        => OKC_API.G_TRUE
                                    ,x_return_status => lx_return_status
                                    ,x_msg_count     => lx_msg_count
                                    ,x_msg_data      => lx_msg_data
							 --
                                    ,p_contract_id   => p_contract_number
				    ,p_rel_type      => p_rel_type
							 --
                                    ,p_trace_mode    => l_trace_mode
                                    ,x_order_id      => lx_order_id);

  -- no need to check for errors, message stack should be set,
  -- nothing to return to caller
  IF lx_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	IF lx_order_id IS NULL THEN
	   RETCODE := 2;
	ELSE
	   RETCODE := 1;
	END IF;
  ELSE
	RETCODE:=0;
  END IF;
  ERRBUF:=lx_msg_data;
END create_order_from_k;

--
-- full version of the procedure to create an order from a contract
--

PROCEDURE create_order_from_k(p_api_version       IN  NUMBER
                             ,p_init_msg_list     IN  VARCHAR2
                             ,p_commit            IN  VARCHAR2
                             ,x_return_status     OUT NOCOPY VARCHAR2
                             ,x_msg_count         OUT NOCOPY NUMBER
                             ,x_msg_data          OUT NOCOPY VARCHAR2
			     --
                             ,p_contract_id       IN  OKC_K_HEADERS_B.ID%TYPE
			     ,p_rel_type          IN  OKC_K_REL_OBJS.rty_code%TYPE
			     --
			     ,p_trace_mode        IN  VARCHAR2
                             ,x_order_id          OUT NOCOPY okx_order_headers_v.id1%TYPE
                             ) IS

l_api_name		    CONSTANT VARCHAR2(30) := 'CREATE_O_FROM_K';
l_api_version	            CONSTANT NUMBER	  := 1;
lx_return_status	    VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
lx_msg_count                NUMBER := 0;
lx_msg_data                 VARCHAR2(2000);
l_trace_mode                VARCHAR2(1);

BEGIN
  -- call START_ACTIVITY to create savepoint, check compatibility
  -- and initialize message list
  lx_return_status := OKC_API.START_ACTIVITY(
					p_api_name      => l_api_name,
					p_pkg_name      => g_pkg_name,
					p_init_msg_list => p_init_msg_list,
					l_api_version   => l_api_version,
					p_api_version   => p_api_version,
					p_api_type      => g_api_type,
					x_return_status => lx_return_status);

  -- check if activity started successfully
  IF (lx_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (lx_return_status = OKC_API.G_RET_STS_ERROR) THEN
     RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  -- call before user hooks
  null;

  -- trace mode initialization turned ON
  IF p_trace_mode = okc_api.g_true OR
	FND_PROFILE.VALUE('AFLOG_ENABLED') = 'Y' OR
	p_trace_mode = okc_oc_int_ktq_pvt.g_support THEN
	l_trace_mode := okc_api.g_true;
	okc_util.init_trace;
  ELSE
--  Bug 2234902
         okc_util.set_trace_context(FND_GLOBAL.conc_request_id, lx_return_status);
         okc_util.l_output_flag :=TRUE;
         lx_return_status    := OKC_API.G_RET_STS_SUCCESS;
-- End Bug 2234902
	l_trace_mode := okc_api.g_false;
  END IF;

  -- call the main routine
  OKC_OC_INT_KTO_PVT.create_order_from_k(p_api_version   => l_api_version
                                        ,p_init_msg_list => OKC_API.G_FALSE
                                        ,x_return_status => lx_return_status
                                        ,x_msg_count     => lx_msg_count
                                        ,x_msg_data      => lx_msg_data
					--
                                        ,p_contract_id   => p_contract_id
					,p_rel_type      => p_rel_type
					--
                                        ,p_trace_mode    => l_trace_mode
                                        ,x_order_id      => x_order_id
                                        );

  -- trace mode initialization turned OFF
  IF l_trace_mode = okc_api.g_true  OR  FND_PROFILE.VALUE('AFLOG_ENABLED') = 'Y' THEN
	okc_util.stop_trace;
  END IF;

  -- check return status
  IF lx_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF lx_return_status = OKC_API.G_RET_STS_ERROR THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  -- call AFTER user hook
  null;

  -- if we got this far, then we are successful
  IF p_trace_mode <> okc_oc_int_ktq_pvt.g_support OR
	p_trace_mode IS NULL THEN
     IF p_commit = OKC_API.G_TRUE THEN
        COMMIT;
     END IF;
  END IF;


  -- end activity
  OKC_API.END_ACTIVITY(	x_msg_count		=> lx_msg_count,
  			x_msg_data		=> lx_msg_data);

  x_return_status := lx_return_status;
  x_msg_count     := lx_msg_count;
  x_msg_data      := lx_msg_data;

  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
						p_api_name  => l_api_name,
						p_pkg_name  => g_pkg_name,
						p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
						x_msg_count => x_msg_count,
						x_msg_data  => x_msg_data,
						p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
						p_api_name  => l_api_name,
						p_pkg_name  => g_pkg_name,
						p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
						x_msg_count => x_msg_count,
						x_msg_data  => x_msg_data,
						p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
						p_api_name  => l_api_name,
						p_pkg_name  => g_pkg_name,
						p_exc_name  => 'OTHERS',
						x_msg_count => x_msg_count,
						x_msg_data  => x_msg_data,
						p_api_type  => g_api_type);
END create_order_from_k;


-------------------------------------------------------------------------------
--
-- APIs: Q->K
--
-------------------------------------------------------------------------------

-- Procedure:       create_k_from_quote
-- Version:         1.0
-- Purpose:         Create a contract from a quote.
--                  This will be a wrapper for create_k_from_quote
--                  procedure, created for running it as a conc prog.

-- Bug : 1686001 Changed references to ASO_QUOTE_HEADERS_ALL.QUOTE_HEADER_ID to OKX_QUOTE_HEADERS_V.ID1
PROCEDURE create_k_from_quote(ERRBUF            OUT NOCOPY VARCHAR2
                          ,RETCODE             OUT NOCOPY NUMBER
                          ,p_quote_id          IN  OKX_QUOTE_HEADERS_V.ID1%TYPE
                          ,p_contract_category IN  OKC_K_HEADERS_B.SCS_CODE%TYPE
                          ,p_template_id       IN  OKC_K_HEADERS_B.ID%TYPE
                          ,p_template_version  IN  NUMBER
                          ,p_rel_type          IN  FND_LOOKUPS.LOOKUP_CODE%TYPE
                          ,p_trace_mode        IN  VARCHAR2
                          ) IS

l_api_version           CONSTANT NUMBER := 1;
lx_contract_id          okc_k_headers_b.id%TYPE := NULL;
lx_contract_number      VARCHAR2(1000) := NULL;
lx_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
lx_msg_count            NUMBER := 0;
lx_msg_data             VARCHAR2(2000);
l_trace_mode            VARCHAR2(1) := OKC_API.G_TRUE;

BEGIN
  --
  -- call full version of create_quote_from_k
  --
  IF p_trace_mode = OKC_API.G_MISS_CHAR OR p_trace_mode IS NULL THEN
	l_trace_mode:=OKC_API.G_TRUE;
  ELSE
	l_trace_mode:=p_trace_mode;
  END IF;
  OKC_OC_INT_PUB.create_k_from_quote(p_api_version => l_api_version
                             ,p_init_msg_list => OKC_API.G_TRUE
                             ,p_commit        => OKC_API.G_TRUE
                             ,p_quote_id      => p_quote_id
                             ,p_template_id   => p_template_id
                             ,p_template_version   => p_template_version
			     ,p_rel_type      => p_rel_type
			     ,p_terms_agreed_flag => OKC_API.G_FALSE
                             ,p_trace_mode    => l_trace_mode
                             ,x_contract_id   => lx_contract_id
			     ,x_contract_number => lx_contract_number
                             ,x_return_status => lx_return_status
                             ,x_msg_count     => lx_msg_count
                             ,x_msg_data      => lx_msg_data);

  -- no need to check for errors, message stack should be set,
  -- nothing to return to caller
  IF lx_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	IF lx_contract_id IS NULL THEN
	   RETCODE := 2;
	ELSE
	   RETCODE := 1;
	END IF;
  ELSE
	RETCODE:=0;
  END IF;
  ERRBUF:=lx_msg_data;
END create_k_from_quote;

-- Procedure:       create_k_from_quote
-- Version:         1.0
-- Purpose:         Create a contract from a quote.
--                  Provides process 3.2.2 in data flow diagram in HLD.
--                  Create relationships from quote to contract
-- In Parameters:   p_quote_id     Quote for which to create contract
--                  p_template_id  Template contract to use in creating contract
-- Out Parameters:  x_contract_id   Id of created contract
--                  x_contract_number contract number of newly created contract
--

PROCEDURE create_k_from_quote(p_api_version IN  NUMBER
                         ,p_init_msg_list   IN  VARCHAR2
                         ,p_commit          IN  VARCHAR2
                         ,p_quote_id        IN  OKX_QUOTE_HEADERS_V.ID1%TYPE
                         ,p_template_id     IN  OKC_K_HEADERS_B.ID%TYPE
                         ,p_template_version  IN  NUMBER
			 ,p_rel_type        IN  OKC_K_REL_OBJS.RTY_CODE%TYPE
			 ,p_terms_agreed_flag IN  VARCHAR2
                         ,p_trace_mode      IN  VARCHAR2
                         ,x_contract_id     OUT NOCOPY OKC_K_HEADERS_B.ID%TYPE
			 ,x_contract_number OUT NOCOPY OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE
                         ,x_return_status   OUT NOCOPY VARCHAR2
                         ,x_msg_count       OUT NOCOPY NUMBER
                         ,x_msg_data        OUT NOCOPY VARCHAR2
                             ) IS

l_api_name	    CONSTANT VARCHAR2(30) := 'CREATE_K_FROM_Q';
l_api_version       CONSTANT NUMBER	  := 1;
lx_return_status    VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
lx_msg_count        NUMBER := 0;
lx_msg_data         VARCHAR2(2000);

BEGIN
  lx_return_status := OKC_API.START_ACTIVITY(
					p_api_name      => l_api_name,
					p_pkg_name      => g_pkg_name,
					p_init_msg_list => p_init_msg_list,
					l_api_version   => l_api_version,
					p_api_version   => p_api_version,
					p_api_type      => g_api_type,
					x_return_status => lx_return_status);

  IF (lx_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (lx_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  -- call before user hooks
  null;

  -- trace mode initialization turned ON
  IF p_trace_mode = okc_api.g_true OR
	FND_PROFILE.VALUE('AFLOG_ENABLED') = 'Y' THEN
	okc_util.init_trace;
  END IF;

  -- call the main routine
  OKC_OC_INT_QTK_PVT.create_k_from_quote(p_api_version     => l_api_version
                                        ,p_init_msg_list   => OKC_API.G_FALSE
                                        ,p_quote_id        => p_quote_id
                                        ,p_template_id     => p_template_id
                                        ,p_template_version  => p_template_version
                                        ,p_rel_type        => p_rel_type
                                        ,p_terms_agreed_flag  => p_terms_agreed_flag
                                        ,x_contract_id     => x_contract_id
				        ,x_contract_number => x_contract_number
                                        ,x_return_status   => lx_return_status
                                        ,x_msg_count       => lx_msg_count
                                        ,x_msg_data        => lx_msg_data
                                        );

  -- trace mode initialization turned OFF
  IF p_trace_mode = okc_api.g_true OR  FND_PROFILE.VALUE('AFLOG_ENABLED') = 'Y' THEN
	okc_util.stop_trace;
  END IF;

  -- check return status
  IF lx_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF lx_return_status = OKC_API.G_RET_STS_ERROR THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  -- call AFTER user hook
  null;

  -- if we got this far, then we are successful
  IF p_commit = OKC_API.G_TRUE THEN
    COMMIT;
  END IF;

  -- end activity
  OKC_API.END_ACTIVITY(	x_msg_count		=> lx_msg_count,
  			x_msg_data		=> lx_msg_data);

  x_return_status := lx_return_status;
  x_msg_count     := lx_msg_count;
  x_msg_data      := lx_msg_data;

  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
						p_api_name  => l_api_name,
						p_pkg_name  => g_pkg_name,
						p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
						x_msg_count => x_msg_count,
						x_msg_data  => x_msg_data,
						p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
						p_api_name  => l_api_name,
						p_pkg_name  => g_pkg_name,
						p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
						x_msg_count => x_msg_count,
						x_msg_data  => x_msg_data,
						p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
						p_api_name  => l_api_name,
						p_pkg_name  => g_pkg_name,
						p_exc_name  => 'OTHERS',
						x_msg_count => x_msg_count,
						x_msg_data  => x_msg_data,
						p_api_type  => g_api_type);
END create_k_from_quote;

-- Procedure:       create_k_from_quote
-- Version:         1.0
-- Purpose:         Create a contract from a quote.  Overloaded procedure
--                  Does not return contract number.
--                  Provides process 3.2.2 in data flow diagram in HLD.
--                  Create relationships from quote to contract
-- In Parameters:   p_quote_id     Quote for which to create contract
--                  p_template_id  Template contract to use in creating contract
-- Out Parameters:  x_contract_id  Id of created contract
--
PROCEDURE create_k_from_quote(p_api_version     IN  NUMBER
                             ,p_init_msg_list   IN  VARCHAR2
                             ,p_commit          IN  VARCHAR2
                             ,p_quote_id        IN  OKX_QUOTE_HEADERS_V.ID1%TYPE
                             ,p_template_id     IN  OKC_K_HEADERS_B.ID%TYPE
                             ,p_template_version IN  NUMBER
			     ,p_rel_type        IN  OKC_K_REL_OBJS.RTY_CODE%TYPE
                             ,p_trace_mode      IN  VARCHAR2
                             ,x_contract_id     OUT NOCOPY OKC_K_HEADERS_B.ID%TYPE
                             ,x_return_status   OUT NOCOPY VARCHAR2
                             ,x_msg_count       OUT NOCOPY NUMBER
                             ,x_msg_data        OUT NOCOPY VARCHAR2
                             ) IS

l_api_name	    CONSTANT VARCHAR2(30) := 'CREATE_K_FROM_Q';
l_api_version	    CONSTANT NUMBER	  := 1;

x_contract_number   OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE;

BEGIN

  -- call the main routine
  create_k_from_quote(p_api_version     => l_api_version
                     ,p_init_msg_list   => OKC_API.G_FALSE
                     ,p_commit          => p_commit
                     ,p_quote_id        => p_quote_id
                     ,p_template_id     => p_template_id
                     ,p_template_version => p_template_version
     		     ,p_rel_type        => p_rel_type
                     ,p_terms_agreed_flag => OKC_API.G_FALSE
                     ,x_contract_id     => x_contract_id
		     ,p_trace_mode      => p_trace_mode
		     ,x_contract_number => x_contract_number
                     ,x_return_status   => x_return_status
                     ,x_msg_count       => x_msg_count
                     ,x_msg_data        => x_msg_data
                     );

END create_k_from_quote;

-- Procedure:       create_k_relationships
-- Version:         1.0
-- ...

PROCEDURE create_k_relationships(p_api_version       IN  NUMBER
                               ,p_init_msg_list      IN  VARCHAR2
                               ,p_commit             IN  VARCHAR2
                               ,p_sales_contract_id  IN  OKC_K_HEADERS_B.ID%TYPE
                               ,p_service_contract_id IN OKC_K_HEADERS_B.ID%TYPE
                               ,p_quote_id           IN  OKX_QUOTE_HEADERS_V.ID1%TYPE
                               ,p_quote_line_tab     IN  OKC_OC_INT_PUB.OKC_QUOTE_LINE_TAB
                               ,p_order_id           IN  OKX_ORDER_HEADERS_V.ID1%TYPE
                               ,p_order_line_tab     IN  OKC_OC_INT_PUB.OKC_ORDER_LINE_TAB
                               ,p_trace_mode         IN  VARCHAR2
                               ,x_return_status  OUT NOCOPY VARCHAR2
                               ,x_msg_count      OUT NOCOPY NUMBER
                               ,x_msg_data       OUT NOCOPY VARCHAR2) IS

  l_api_name	    CONSTANT VARCHAR2(30) := 'CREATE_K_REL';
  l_api_version	    CONSTANT NUMBER	  := 1;
  lx_return_status  VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
  lx_msg_count      NUMBER := 0;
  lx_msg_data       VARCHAR2(2000);
  l_trace_mode      VARCHAR2(1);

BEGIN
  -- call START_ACTIVITY to create savepoint, check compatibility and initialize message list
  lx_return_status := OKC_API.START_ACTIVITY(
					p_api_name      => l_api_name,
					p_pkg_name      => g_pkg_name,
					p_init_msg_list => p_init_msg_list,
					l_api_version   => l_api_version,
					p_api_version   => p_api_version,
					p_api_type      => g_api_type,
					x_return_status => lx_return_status);

  -- check if activity started successfully
  IF (lx_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (lx_return_status = OKC_API.G_RET_STS_ERROR) THEN
     RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  -- call before user hooks
  null;

  -- trace mode initialization turned ON
  IF p_trace_mode = okc_api.g_true OR
	FND_PROFILE.VALUE('AFLOG_ENABLED') = 'Y'
  THEN
	l_trace_mode := okc_api.g_true;
	okc_util.init_trace;
  ELSE
	l_trace_mode := okc_api.g_false;
  END IF;

  -- call the main routine
  OKC_OC_INT_KTO_PVT.create_k_relationships(p_api_version           => l_api_version
                                           ,p_init_msg_list         => OKC_API.G_FALSE
                                           ,p_sales_contract_id     => p_sales_contract_id
                                           ,p_service_contract_id   => p_service_contract_id
                                           ,p_quote_id              => p_quote_id
                                           ,p_quote_line_tab        => p_quote_line_tab
                                           ,p_order_id              => p_order_id
                                           ,p_order_line_tab        => p_order_line_tab
                                           ,x_return_status         => lx_return_status
                                           ,x_msg_count             => lx_msg_count
                                           ,x_msg_data              => lx_msg_data
                                           );


  -- trace mode initialization turned OFF
  IF l_trace_mode = okc_api.g_true  OR  FND_PROFILE.VALUE('AFLOG_ENABLED') = 'Y' THEN
	okc_util.stop_trace;
  END IF;

  -- check return status
  IF lx_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF lx_return_status = OKC_API.G_RET_STS_ERROR THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  -- call AFTER user hook
  null;

  -- commit if necessary
  IF p_commit = OKC_API.G_TRUE THEN
     COMMIT;
  END IF;

  -- end activity
  OKC_API.END_ACTIVITY(	x_msg_count	=> lx_msg_count,
  			x_msg_data	=> lx_msg_data);

  x_return_status := lx_return_status;
  x_msg_count     := lx_msg_count;
  x_msg_data      := lx_msg_data;

  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
						p_api_name  => l_api_name,
						p_pkg_name  => g_pkg_name,
						p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
						x_msg_count => x_msg_count,
						x_msg_data  => x_msg_data,
						p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
						p_api_name  => l_api_name,
						p_pkg_name  => g_pkg_name,
						p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
						x_msg_count => x_msg_count,
						x_msg_data  => x_msg_data,
						p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
						p_api_name  => l_api_name,
						p_pkg_name  => g_pkg_name,
						p_exc_name  => 'OTHERS',
						x_msg_count => x_msg_count,
						x_msg_data  => x_msg_data,
						p_api_type  => g_api_type);

END create_k_relationships;


-- Procedure:       create_interaction_history
-- Version:         1.0
-- Purpose:         1. In the event of a new contract's terms and conditions
--                     not being approved by the customer, fresh negotiations
--                     of the terms and conditions is undertaken and the
--                     contract administrator notified.
--                     Following the fresh negotiations, the customer may
--                     or may not approve. If the customer still does not
--                     approve, the contract has to be set back to an
--                     ENTERED state.
--
--                     This procedure records the information used for
--                     the these negotiations.
--
-- In Parameters:   p_api_version         API version (to be initialized to 1)
--                  p_init_msg_list       Flag to reset the error message stack
--                  p_commit              Commit flag for the transaction
--                  p_contract_id         contract header id of the contract
--                                        whose TsandCs need to be negotiated
--                  p_party_id            Customer contract as party id of
--                                        the contact of relationship
--                                        between the customer and his contact
--                  p_interaction_subject Short message to introduce
--                                        the interaction, like
--                                        'Terms and conditions of contract'
--                  p_interaction_body    Message body to be used to
--                                        build the interaction
--                  p_trace_mode          Trace mode option to generate
--                                        a trace file
--
-- Out Parameters:  x_return_status       Final status of notification
--                                        sending API:
--                                        -OKC_API.G_RET_STS_SUCCESS
--                                        -OKC_API.G_RET_STS_ERROR
--                                        -OKC_API.G_RET_STS_UNEXP_ERROR
--                  x_msg_count           Number of messages set on the stack
--                  x_msg_data            Message info id x_msg_count = 1
--
-- THIS IS A WRAPPER FOR OKC_OC_INT_QTK_PVT.create_interaction_history

PROCEDURE create_interaction_history(p_api_version    IN  NUMBER
                               ,p_init_msg_list       IN  VARCHAR2
                               ,p_commit              IN  VARCHAR2
                               ,p_contract_id         IN  NUMBER
                               ,p_party_id            IN  NUMBER
                               ,p_interaction_subject IN  VARCHAR2
                               ,p_interaction_body    IN  VARCHAR2
                               ,p_trace_mode          IN  VARCHAR2
                               ,x_return_status       OUT NOCOPY VARCHAR2
                               ,x_msg_count           OUT NOCOPY NUMBER
                               ,x_msg_data            OUT NOCOPY VARCHAR2) IS



  l_api_name	    CONSTANT VARCHAR2(30) := 'CREATE_INTHIST';
  l_api_version	    CONSTANT NUMBER	  := 1;
  lx_return_status  VARCHAR2(1)		  := OKC_API.G_RET_STS_SUCCESS;
  lx_msg_count      NUMBER := 0;
  lx_msg_data       VARCHAR2(2000);
  l_trace_mode      VARCHAR2(1);

BEGIN
  -- call START_ACTIVITY to create savepoint, check compatibility and initialize message list
  lx_return_status := OKC_API.START_ACTIVITY(
					p_api_name      => l_api_name,
					p_pkg_name      => g_pkg_name,
					p_init_msg_list => p_init_msg_list,
					l_api_version   => l_api_version,
					p_api_version   => p_api_version,
					p_api_type      => g_api_type,
					x_return_status => lx_return_status);

  -- check if activity started successfully
  IF (lx_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (lx_return_status = OKC_API.G_RET_STS_ERROR) THEN
     RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  -- call before user hooks
  null;

  -- trace mode initialization turned ON
  IF p_trace_mode = okc_api.g_true OR
	FND_PROFILE.VALUE('AFLOG_ENABLED') = 'Y'
  THEN
	l_trace_mode := okc_api.g_true;
	okc_util.init_trace;
  ELSE
	l_trace_mode := okc_api.g_false;
  END IF;

  -- call the main routine
  OKC_OC_INT_QTK_PVT.create_interaction_history(
                                p_api_version           => l_api_version
                               ,p_init_msg_list         => OKC_API.G_FALSE
                               ,p_contract_id           => p_contract_id
                               ,p_party_id              => p_party_id
                               ,p_interaction_subject   => p_interaction_subject
                               ,p_interaction_body      => p_interaction_body
                               ,x_return_status         => lx_return_status
                               ,x_msg_count             => lx_msg_count
                               ,x_msg_data              => lx_msg_data
                                           );

  -- trace mode initialization turned OFF
  IF l_trace_mode = okc_api.g_true  OR  FND_PROFILE.VALUE('AFLOG_ENABLED') = 'Y' THEN
	okc_util.stop_trace;
  END IF;

  -- check return status
  IF lx_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF lx_return_status = OKC_API.G_RET_STS_ERROR THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  -- call AFTER user hook
  null;

  -- commit if necessary
  IF p_commit = OKC_API.G_TRUE THEN
     COMMIT;
  END IF;

  -- end activity
  OKC_API.END_ACTIVITY(	x_msg_count	=> lx_msg_count,
  			x_msg_data	=> lx_msg_data);

  x_return_status := lx_return_status;
  x_msg_count     := lx_msg_count;
  x_msg_data      := lx_msg_data;

  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
						p_api_name  => l_api_name,
						p_pkg_name  => g_pkg_name,
						p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
						x_msg_count => x_msg_count,
						x_msg_data  => x_msg_data,
						p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
						p_api_name  => l_api_name,
						p_pkg_name  => g_pkg_name,
						p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
						x_msg_count => x_msg_count,
						x_msg_data  => x_msg_data,
						p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
						p_api_name  => l_api_name,
						p_pkg_name  => g_pkg_name,
						p_exc_name  => 'OTHERS',
						x_msg_count => x_msg_count,
						x_msg_data  => x_msg_data,
						p_api_type  => g_api_type);

END create_interaction_history;


-- Procedure:       notify_k_adm
-- Version:         1.0
-- ...

--  Bug : 1905226  OKC, ISTORE TESTING: K ALERT RESULTS GRID SHOULD POPULATE K# FIELD
--  Problem : Notifications in Launchpad's Inbox don't show KNUMBER in subject
--            and 'Contract Number' column
--  Fix:  p_contract_id was added into parameter list of notify_k_adm procedure

PROCEDURE notify_k_adm(p_api_version                    IN NUMBER
                      ,p_init_msg_list                  IN VARCHAR2
                      ,p_commit                         IN VARCHAR2
		      ,p_application_name               IN VARCHAR2
		      ,p_message_subject                IN FND_NEW_MESSAGES.MESSAGE_NAME%TYPE
		      ,p_message_body 	                IN FND_NEW_MESSAGES.MESSAGE_NAME%TYPE
		      ,p_message_body_token1 		IN VARCHAR2
		      ,p_message_body_token1_value 	IN VARCHAR2
		      ,p_message_body_token2 		IN VARCHAR2
		      ,p_message_body_token2_value 	IN VARCHAR2
		      ,p_message_body_token3 		IN VARCHAR2
		      ,p_message_body_token3_value 	IN VARCHAR2
                      ,p_trace_mode      		IN VARCHAR2
                      ,p_contract_id       IN OKC_K_HEADERS_B.ID%TYPE
                      ,x_k_admin_user_name   	 OUT NOCOPY VARCHAR2
                      ,x_return_status   	 OUT NOCOPY VARCHAR2
                      ,x_msg_count                      OUT NOCOPY NUMBER
                      ,x_msg_data                       OUT NOCOPY VARCHAR2) IS

l_api_name	 CONSTANT VARCHAR2(30) 	:= 'NOTIFY_K_ADM';
l_api_version	 CONSTANT NUMBER	:=1;
lx_return_status VARCHAR2(1)	 	:= OKC_API.G_RET_STS_SUCCESS;
lx_msg_count	 NUMBER			;
lx_msg_data	 FND_NEW_MESSAGES.message_text%TYPE;

BEGIN
  lx_return_status := OKC_API.START_ACTIVITY(
					p_api_name      => l_api_name,
					p_pkg_name      => g_pkg_name,
					p_init_msg_list => p_init_msg_list,
					l_api_version   => l_api_version,
					p_api_version   => p_api_version,
					p_api_type      => g_api_type,
					x_return_status => lx_return_status);

  IF (lx_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (lx_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  -- call before user hooks
  null;

  -- trace mode initialization turned ON
  IF p_trace_mode = okc_api.g_true OR
	FND_PROFILE.VALUE('AFLOG_ENABLED') = 'Y'
  THEN
	okc_util.init_trace;
  END IF;

  -- call the main routine

 --  Bug : 1905226  OKC, ISTORE TESTING: K ALERT RESULTS GRID SHOULD POPULATE K# FIELD
 -- Problem : Notifications in Launchpad's Inbox don't show KNUMBER in subject
 --           and 'Contract Number' column
 -- Fix:  calls of notify_k_adm procedure were changed to pass 'contract ID'

  okc_oc_int_qtk_pvt.notify_k_adm(
                    p_api_version      	        => l_api_version
                   ,p_init_msg_list    	        => OKC_API.G_FALSE
                   ,p_application_name	        => p_application_name
		   ,p_message_subject  		=> p_message_subject
		   ,p_message_body    		=> p_message_body
		   ,p_message_body_token1	=> p_message_body_token1
		   ,p_message_body_token1_value	=> p_message_body_token1_value
		   ,p_message_body_token2	=> p_message_body_token2
		   ,p_message_body_token2_value	=> p_message_body_token2_value
		   ,p_message_body_token3	=> p_message_body_token3
		   ,p_message_body_token3_value	=> p_message_body_token3_value
                   ,p_contract_id               => p_contract_id
                   ,x_k_admin_user_name         => x_k_admin_user_name
                   ,x_return_status             => lx_return_status
                   ,x_msg_count                 => lx_msg_count
                   ,x_msg_data                  => lx_msg_data
                         );

  -- trace mode initialization turned OFF
  IF p_trace_mode = okc_api.g_true  OR  FND_PROFILE.VALUE('AFLOG_ENABLED') = 'Y' THEN
	okc_util.stop_trace;
  END IF;


  -- check return status
  IF lx_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF lx_return_status = OKC_API.G_RET_STS_ERROR THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  -- call AFTER user hook
  null;

  -- if we got this far, then we are successful
  IF p_commit = OKC_API.G_TRUE THEN
    COMMIT;
  END IF;

  -- end activity
  OKC_API.END_ACTIVITY(x_msg_count		=> lx_msg_count,
  		       x_msg_data		=> lx_msg_data);

  x_return_status := lx_return_status;
  x_msg_count     := lx_msg_count;
  x_msg_data      := lx_msg_data;

  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
						p_api_name  => l_api_name,
						p_pkg_name  => g_pkg_name,
						p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
						x_msg_count => lx_msg_count,
						x_msg_data  => lx_msg_data,
						p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
						p_api_name  => l_api_name,
						p_pkg_name  => g_pkg_name,
						p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
						x_msg_count => lx_msg_count,
						x_msg_data  => lx_msg_data,
						p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
						p_api_name  => l_api_name,
						p_pkg_name  => g_pkg_name,
						p_exc_name  => 'OTHERS',
						x_msg_count => lx_msg_count,
						x_msg_data  => lx_msg_data,
						p_api_type  => g_api_type);
END notify_k_adm;


-------------------------------------------------------------------------------
-- Procedure:       notify_sales_rep
-- Version:         1.0
-- Purpose:         API is used to retrive Quotation , contract status
--                  (If required) and generate notification to Order Capture
--                  and Istore
--                  THIS API IS CALLED FROM OKC_WF_K_APPROVE.NOTIFY_SALES_REP_W
-- IN Parameters   : p_contract_id, p_contract_status, p_trace_mode
--
-- OUT Parameters  : x_return_status
-------------------------------------------------------------------------------

PROCEDURE notify_sales_rep (p_api_version     IN NUMBER
                           ,p_init_msg_list   IN VARCHAR2
                           ,p_contract_id     IN NUMBER
                           ,p_contract_status IN VARCHAR2
                           ,p_trace_mode      IN VARCHAR2
                           ,p_commit          IN VARCHAR2
                           ,x_return_status   OUT NOCOPY VARCHAR2
                           ,x_msg_count       OUT NOCOPY NUMBER
                           ,x_msg_data        OUT NOCOPY VARCHAR2) IS
l_api_name	 CONSTANT VARCHAR2(30) 	:= 'NOTIFY_SALES_REP';
l_api_version	 CONSTANT NUMBER	:=1;
lx_return_status VARCHAR2(1)	 	:= OKC_API.G_RET_STS_SUCCESS;
lx_msg_count	 NUMBER			;
lx_msg_data	 FND_NEW_MESSAGES.message_text%TYPE;

BEGIN
  lx_return_status := OKC_API.START_ACTIVITY(
					p_api_name      => l_api_name,
					p_pkg_name      => g_pkg_name,
					p_init_msg_list => p_init_msg_list,
					l_api_version   => l_api_version,
                                        --npalepu modified on 22-11-2005 for bug # 4737495
                                        /* p_api_version   => p_api_version, */
                                        p_api_version   => 1.0,
                                        --end npalepu
					p_api_type      => g_api_type,
					x_return_status => lx_return_status);

  IF (lx_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (lx_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  -- call before user hooks
  null;

  -- trace mode initialization turned ON
  IF p_trace_mode = okc_api.g_true OR
	FND_PROFILE.VALUE('AFLOG_ENABLED') = 'Y'
  THEN
	okc_util.init_trace;
  END IF;

  -- call the main routine

  okc_oc_int_qtk_pvt.notify_sales_rep(
                    p_api_version      	        => l_api_version
                   ,p_init_msg_list    	        => OKC_API.G_FALSE
                   ,p_contract_id               => p_contract_id
                   ,p_contract_status           => p_contract_status
                   ,x_return_status             => lx_return_status
                   ,x_msg_count                 => lx_msg_count
                   ,x_msg_data                  => lx_msg_data
                         );

  -- trace mode initialization turned OFF
  IF p_trace_mode = okc_api.g_true  OR  FND_PROFILE.VALUE('AFLOG_ENABLED') = 'Y' THEN
	okc_util.stop_trace;
  END IF;


  -- check return status
  IF lx_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF lx_return_status = OKC_API.G_RET_STS_ERROR THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  -- call AFTER user hook
  null;

  -- if we got this far, then we are successful
  IF p_commit = OKC_API.G_TRUE THEN
    COMMIT;
  END IF;

  -- end activity
  OKC_API.END_ACTIVITY(x_msg_count		=> lx_msg_count,
  		       x_msg_data		=> lx_msg_data);

  x_return_status := lx_return_status;
  x_msg_count     := lx_msg_count;
  x_msg_data      := lx_msg_data;

 EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
						p_api_name  => l_api_name,
						p_pkg_name  => g_pkg_name,
						p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
						x_msg_count => lx_msg_count,
						x_msg_data  => lx_msg_data,
						p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
						p_api_name  => l_api_name,
						p_pkg_name  => g_pkg_name,
						p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
						x_msg_count => lx_msg_count,
						x_msg_data  => lx_msg_data,
						p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
						p_api_name  => l_api_name,
						p_pkg_name  => g_pkg_name,
						p_exc_name  => 'OTHERS',
						x_msg_count => lx_msg_count,
						x_msg_data  => lx_msg_data,
						p_api_type  => g_api_type);
END notify_sales_rep;

-- Procedure:       get_k_number
-- Version:         1.0
-- ...

PROCEDURE get_k_number(p_api_version IN NUMBER
                 ,p_init_msg_list    IN VARCHAR2
                 ,p_commit           IN VARCHAR2
                 ,p_contract_id      IN NUMBER
                 ,p_trace_mode       IN VARCHAR2
                 ,x_contract_number OUT NOCOPY OKC_K_HEADERS_B.contract_number%TYPE
                 ,x_contract_number_modifier OUT NOCOPY OKC_K_HEADERS_B.contract_number_modifier%TYPE
                 ,x_return_status   OUT NOCOPY VARCHAR2
                 ,x_msg_count       OUT NOCOPY NUMBER
                 ,x_msg_data        OUT NOCOPY VARCHAR2) IS

l_api_name	 CONSTANT VARCHAR2(30) 	:= 'GET_K_NUMBER';
l_api_version	 CONSTANT NUMBER	:= 1;
lx_return_status VARCHAR2(1)	 	:= OKC_API.G_RET_STS_SUCCESS;
lx_msg_count	 NUMBER			:= 0;
lx_msg_data	 VARCHAR2(50)		:= 'msg';

BEGIN
  lx_return_status := OKC_API.START_ACTIVITY(
					p_api_name      => l_api_name,
					p_pkg_name      => g_pkg_name,
					p_init_msg_list => p_init_msg_list,
					l_api_version   => l_api_version,
					p_api_version   => p_api_version,
					p_api_type      => g_api_type,
					x_return_status => lx_return_status);

  IF (lx_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (lx_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  -- call before user hooks
  null;

  -- trace mode initialization turned ON
  IF p_trace_mode = okc_api.g_true OR
	FND_PROFILE.VALUE('AFLOG_ENABLED') = 'Y'
  THEN
	okc_util.init_trace;
  END IF;

  -- call the main routine

  okc_oc_int_qtk_pvt.get_k_number(
                    p_api_version      	        => l_api_version
                   ,p_init_msg_list    	        => OKC_API.G_FALSE
                   ,p_contract_id               => p_contract_id
                   ,x_contract_number           => x_contract_number
                   ,x_contract_number_modifier  => x_contract_number_modifier
                   ,x_return_status             => lx_return_status
                   ,x_msg_count                 => lx_msg_count
                   ,x_msg_data                  => lx_msg_data
                         );

  -- trace mode initialization turned OFF
  IF p_trace_mode = okc_api.g_true  OR  FND_PROFILE.VALUE('AFLOG_ENABLED') = 'Y' THEN
	okc_util.stop_trace;
  END IF;


  -- check return status
  IF lx_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF lx_return_status = OKC_API.G_RET_STS_ERROR THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  -- call AFTER user hook
  null;

  -- if we got this far, then we are successful
  IF p_commit = OKC_API.G_TRUE THEN
    COMMIT;
  END IF;

  -- end activity
  OKC_API.END_ACTIVITY(x_msg_count		=> lx_msg_count,
  		       x_msg_data		=> lx_msg_data);

  x_return_status := lx_return_status;
  x_msg_count     := lx_msg_count;
  x_msg_data      := lx_msg_data;

  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
						p_api_name  => l_api_name,
						p_pkg_name  => g_pkg_name,
						p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
						x_msg_count => lx_msg_count,
						x_msg_data  => lx_msg_data,
						p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
						p_api_name  => l_api_name,
						p_pkg_name  => g_pkg_name,
						p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
						x_msg_count => lx_msg_count,
						x_msg_data  => lx_msg_data,
						p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
						p_api_name  => l_api_name,
						p_pkg_name  => g_pkg_name,
						p_exc_name  => 'OTHERS',
						x_msg_count => lx_msg_count,
						x_msg_data  => lx_msg_data,
						p_api_type  => g_api_type);
END get_k_number;


-- Procedure:       k_signed
-- Version:         1.0
-- Purpose:         While creating a contract from a quote, the contract
--                  is set within an ENTERED status. If the customer
--                  agrees with the standard TsandCs, this status has to be
--                  changed at its creation time from ENTERED to SIGNED.
--
--                  This procedure changes the status of the contract, e
--                  ither from an ENTERED status to a SIGNED status, or
--                  from an APPROVED status to a SIGNED status.
--
--                  This API will be called either directly from the creation
--                  contract API  (ENTERED to SIGNED), or later by Order
--                  Capture/iStore (APPROVED to SIGNED)
--
-- In Parameters:   p_party_id        Contract header id
--                  p_date_signed     Signing date of the contract
--
-- Out Parameters:  x_return_status   Final status of the contract status update
--                                        -OKC_API.G_RET_STS_SUCCESS
--                                        -OKC_API.G_RET_STS_ERROR
--                                        -OKC_API.G_RET_STS_UNEXP_ERROR
--
-- THIS IS A PLAIN BARE-BONES WRAPPER FOR OKC_CONTRACT_APPROVAL_PUB.k_signed

PROCEDURE k_signed(p_api_version    IN NUMBER
                  ,p_init_msg_list  IN VARCHAR2
                  ,p_commit         IN VARCHAR2
                  ,p_contract_id    IN  NUMBER
                  ,p_date_signed    IN  DATE
                  ,p_trace_mode     IN  VARCHAR2
		  ,x_return_status  OUT NOCOPY VARCHAR2
                  ,x_msg_count      OUT NOCOPY NUMBER
                  ,x_msg_data       OUT NOCOPY VARCHAR2) IS

l_api_name	 CONSTANT VARCHAR2(30) 	:= 'K_SIGNED';
l_api_version	 CONSTANT NUMBER	:= 1;
lx_return_status VARCHAR2(1)	 	:= OKC_API.G_RET_STS_SUCCESS;
lx_msg_count	 NUMBER			:= 0;
lx_msg_data	 VARCHAR2(50)		:= 'msg';

BEGIN

  -- call before user hooks
  null;

  -- trace mode initialization turned ON
  IF p_trace_mode = okc_api.g_true OR
	FND_PROFILE.VALUE('AFLOG_ENABLED') = 'Y'
  THEN
	okc_util.init_trace;
  END IF;

  -- call the main routine

   OKC_CONTRACT_APPROVAL_PUB.k_signed(p_contract_id   =>  p_contract_id
                                     ,p_date_signed   =>  p_date_signed
                                     ,x_return_status =>  lx_return_status);

  -- trace mode initialization turned OFF
  IF p_trace_mode = okc_api.g_true  OR  FND_PROFILE.VALUE('AFLOG_ENABLED') = 'Y' THEN
	okc_util.stop_trace;
  END IF;

  -- check return status
  IF lx_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF lx_return_status = OKC_API.G_RET_STS_ERROR THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  -- call AFTER user hook
  null;

  -- if we got this far, then we are successful
  IF p_commit = OKC_API.G_TRUE THEN
    COMMIT;
  END IF;

  -- end activity
  OKC_API.END_ACTIVITY(x_msg_count		=> lx_msg_count,
  		       x_msg_data		=> lx_msg_data);

  x_return_status := lx_return_status;
  x_msg_count     := lx_msg_count;
  x_msg_data      := lx_msg_data;

  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
						p_api_name  => l_api_name,
						p_pkg_name  => g_pkg_name,
						p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
						x_msg_count => lx_msg_count,
						x_msg_data  => lx_msg_data,
						p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
						p_api_name  => l_api_name,
						p_pkg_name  => g_pkg_name,
						p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
						x_msg_count => lx_msg_count,
						x_msg_data  => lx_msg_data,
						p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
						p_api_name  => l_api_name,
						p_pkg_name  => g_pkg_name,
						p_exc_name  => 'OTHERS',
						x_msg_count => lx_msg_count,
						x_msg_data  => lx_msg_data,
						p_api_type  => g_api_type);
END k_signed;


-- Procedure:       k_erase_approved
-- Version:         1.0
-- ...

PROCEDURE k_erase_approved(p_api_version    IN NUMBER
                  ,p_init_msg_list  IN VARCHAR2
                  ,p_commit         IN VARCHAR2
                  ,p_contract_id    IN  NUMBER
                  ,p_trace_mode     IN VARCHAR2
		  ,x_return_status  OUT NOCOPY VARCHAR2
                  ,x_msg_count      OUT NOCOPY NUMBER
                  ,x_msg_data       OUT NOCOPY VARCHAR2) IS

l_api_name	 CONSTANT VARCHAR2(30) 	:= 'K_ERASE_APPROV';
l_api_version	 CONSTANT NUMBER	:=1;
lx_return_status VARCHAR2(1)	 	:= OKC_API.G_RET_STS_SUCCESS;
lx_msg_count	 NUMBER			:= 0;
lx_msg_data	 VARCHAR2(50)		:= 'msg';

lx_contract_number       OKC_K_HEADERS_B.contract_number%TYPE; -- new contract number
lx_contract_number_modifier OKC_K_HEADERS_B.contract_number_modifier%TYPE; -- new contract number modifier
lx_k_admin_user_name    FND_USER.user_name%TYPE;

BEGIN

  -- call before user hooks
  null;

  -- trace mode initialization turned ON
  IF p_trace_mode = okc_api.g_true OR
	FND_PROFILE.VALUE('AFLOG_ENABLED') = 'Y'
  THEN
	okc_util.init_trace;
  END IF;

  -- call the main routine

   OKC_CONTRACT_APPROVAL_PUB.k_erase_approved(p_contract_id   =>  p_contract_id
                                     ,x_return_status =>  lx_return_status);

  -- check return status
  IF lx_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF lx_return_status = OKC_API.G_RET_STS_ERROR THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  -- call the another routine
  OKC_OC_INT_PUB.get_k_number (
                     p_api_version     => 1
                    ,p_init_msg_list   => OKC_API.g_false
                    ,p_commit          => OKC_API.g_false
                    ,p_contract_id     =>  p_contract_id
                    ,p_trace_mode      => OKC_API.g_false
                    ,x_contract_number => lx_contract_number
                    ,x_contract_number_modifier => lx_contract_number_modifier
                    ,x_return_status   => lx_return_status
                    ,x_msg_count       => lx_msg_count
                    ,x_msg_data        => lx_msg_data);

  -- check return status
  IF lx_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF lx_return_status = OKC_API.G_RET_STS_ERROR THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  -- call another main routine
  OKC_OC_INT_PUB.notify_k_adm(
                     p_api_version     =>1,
                     p_init_msg_list   => OKC_API.g_false,
                     p_commit          => OKC_API.g_false,
                     p_application_name=> OKC_API.g_app_name,
--                     p_message_subject => 'OKC_Q2K_KAENOTIF_SUBJ', Bug#2449811
                     p_message_subject => 'OKC_Q2K_KAENOTIF_SUBJECT',
                     p_message_body    => 'OKC_Q2K_KAENOTIF_BODY',
                     p_message_body_token1       => 'KNUMBER',
                     p_message_body_token1_value => lx_contract_number,
                     p_message_body_token2       => 'KNUMMODIFIER',
--                     p_message_body_token2_value => lx_contract_number_modifier, Bug#2454456
                     p_message_body_token2_value => Nvl(lx_contract_number_modifier,' '),
                     p_trace_mode      => OKC_API.g_false,
                     x_k_admin_user_name         => lx_k_admin_user_name,
                     x_return_status   => lx_return_status,
                     x_msg_count       => lx_msg_count,
                     x_msg_data        => lx_msg_data);

  IF (lx_return_status = OKC_API.G_RET_STS_UNEXP_ERROR OR
      lx_return_status = OKC_API.G_RET_STS_ERROR) THEN
      okc_api.set_message(p_app_name      => g_app_name,
                          p_msg_name      => 'OKC_Q2K_NOTIFFAILURE',
                          p_token1        => 'KNUMBER',
                          p_token1_value  => lx_contract_number,
                          p_token2        => 'KADMINUSERNAME',
                          p_token2_value  => lx_k_admin_user_name);
  END IF;

  -- check return status
  IF lx_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF lx_return_status = OKC_API.G_RET_STS_ERROR THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  -- trace mode initialization turned OFF
  IF p_trace_mode = okc_api.g_true  OR  FND_PROFILE.VALUE('AFLOG_ENABLED') = 'Y' THEN
	okc_util.stop_trace;
  END IF;

  -- call AFTER user hook
  null;

  -- if we got this far, then we are successful
  IF p_commit = OKC_API.G_TRUE THEN
    COMMIT;
  END IF;

  -- end activity
  OKC_API.END_ACTIVITY(x_msg_count		=> lx_msg_count,
  		       x_msg_data		=> lx_msg_data);

  x_return_status := lx_return_status;
  x_msg_count     := lx_msg_count;
  x_msg_data      := lx_msg_data;

  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
						p_api_name  => l_api_name,
						p_pkg_name  => g_pkg_name,
						p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
						x_msg_count => lx_msg_count,
						x_msg_data  => lx_msg_data,
						p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
						p_api_name  => l_api_name,
						p_pkg_name  => g_pkg_name,
						p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
						x_msg_count => lx_msg_count,
						x_msg_data  => lx_msg_data,
						p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
						p_api_name  => l_api_name,
						p_pkg_name  => g_pkg_name,
						p_exc_name  => 'OTHERS',
						x_msg_count => lx_msg_count,
						x_msg_data  => lx_msg_data,
						p_api_type  => g_api_type);
END k_erase_approved;


-- Procedure:       get_articles
-- Version:         1.0
-- Purpose:         This is the public API which intent to call private API
--                  to select all articles for the contract.
-- In Parameters :  P_contract_id Id of the contract
-- Out Parameters:  x_articles    contract articles (clob datatype)

PROCEDURE get_articles (p_api_version     IN NUMBER
                       ,p_init_msg_list   IN VARCHAR2
                       ,p_commit          IN VARCHAR2
                       ,p_contract_id     IN NUMBER
		       ,p_release_id      IN   NUMBER
                       ,p_trace_mode      IN VARCHAR2
                       ,x_articles        OUT NOCOPY OKC_K_ARTICLES_TL.TEXT%TYPE
                       ,x_return_status   OUT NOCOPY VARCHAR2
                       ,x_msg_count       OUT NOCOPY NUMBER
                       ,x_msg_data        OUT NOCOPY VARCHAR2) IS

l_api_name	 CONSTANT VARCHAR2(30) 	:= 'GET_ARTICLES';
l_api_version	 CONSTANT NUMBER	:=1;
lx_return_status VARCHAR2(1)	 	:= OKC_API.G_RET_STS_SUCCESS;
lx_msg_count	 NUMBER			:= 0;
lx_msg_data	 VARCHAR2(50)		:= 'msg';

BEGIN
  /* Removing Start and End activity because system could not read the LOB
  --   data from the calling program --Guna
  --lx_return_status := OKC_API.START_ACTIVITY(
  --					p_api_name      => l_api_name,
  --					p_pkg_name      => g_pkg_name,
  --					p_init_msg_list => p_init_msg_list,
  --					l_api_version   => l_api_version,
  --					p_api_version   => p_api_version,
  --					p_api_type      => g_api_type,
  --					x_return_status => lx_return_status);
  --
  -- IF (lx_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
  --    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  --  ELSIF (lx_return_status = OKC_API.G_RET_STS_ERROR) THEN
  --    RAISE OKC_API.G_EXCEPTION_ERROR;
  --  END IF;
  --
  */

  -- call before user hooks
  null;

  -- trace mode initialization turned ON
  IF p_trace_mode = okc_api.g_true OR
	FND_PROFILE.VALUE('AFLOG_ENABLED') = 'Y'
  THEN
	okc_util.init_trace;
  END IF;

  -- call the main routine

  okc_oc_int_qtk_pvt.get_articles(
                    p_api_version      	        => l_api_version
                   ,p_init_msg_list    	        => OKC_API.G_FALSE
                   ,p_contract_id               => p_contract_id
                   ,p_release_id                => p_release_id
                   ,x_articles                  => x_articles
                   ,x_return_status             => lx_return_status
                   ,x_msg_count                 => lx_msg_count
                   ,x_msg_data                  => lx_msg_data
                                 );

  -- trace mode initialization turned OFF
  IF p_trace_mode = okc_api.g_true  OR  FND_PROFILE.VALUE('AFLOG_ENABLED') = 'Y' THEN
	okc_util.stop_trace;
  END IF;


  -- check return status
  IF lx_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF lx_return_status = OKC_API.G_RET_STS_ERROR THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  -- call AFTER user hook
  null;

  -- if we got this far, then we are successful
  IF p_commit = OKC_API.G_TRUE THEN
    COMMIT;
  END IF;

  /*
  -- end activity
  -- OKC_API.END_ACTIVITY(x_msg_count		=> lx_msg_count,
  --		       x_msg_data		=> lx_msg_data);
  */

  x_return_status := lx_return_status;
  x_msg_count     := lx_msg_count;
  x_msg_data      := lx_msg_data;

  -- Bug 1835096
  -- Replaced okc_api.handle_exceptions with the following exception
  -- logic to avoid rolling back to a savepoint that was not set
  -- because usage of CLOB API's prevented us from using set_activity
  -- which was setting the savepoint.
  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      FND_MSG_PUB.Count_And_Get
      (
            p_count  => x_msg_count,
            p_data   => x_msg_data
      );
      x_return_status := OKC_API.G_RET_STS_ERROR;

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
       FND_MSG_PUB.Count_And_Get
      (
            p_count  => x_msg_count,
            p_data   => x_msg_data
      );
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    when OTHERS then
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
         FND_MSG_PUB.Add_Exc_Msg
         (
            g_pkg_name,
            l_api_name
         );
      END IF;
      FND_MSG_PUB.Count_And_Get
      (
            p_count  => x_msg_count,
            p_data   => x_msg_data
      );
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
END get_articles;


-- Procedure:       Submit_Request
-- Version:         1.0
-- Purpose:         Outcome PL/SQL API to submit concurrent requests
-- Arguments
--   application	- Short name of application under which the program
--			- is registered
--   program		- concurrent program name for which the request has
--			- to be submitted
--   description	- Optional. Will be displayed along with user
--			- concurrent program name
--   start_time	- Optional. Time at which the request has to start
--			- running
--   sub_request	- Optional. Set to TRUE if the request is submitted
--   			- from another running request and has to be treated
--			- as a sub request. Default is FALSE
--   argument1..100	- Optional. Arguments for the concurrent request

  PROCEDURE submit_request (
			  application IN varchar2 ,
			  program     IN varchar2 ,
			  description IN varchar2 ,
			  start_time  IN varchar2 ,
			  sub_request IN boolean  ,
			  argument1   IN varchar2 ,
			  argument2   IN varchar2 ,
  			  argument3   IN varchar2 ,
			  argument4   IN varchar2 ,
			  argument5   IN varchar2 ,
			  argument6   IN varchar2 ,
			  argument7   IN varchar2 ,
			  argument8   IN varchar2 ,
			  argument9   IN varchar2 ,
			  argument10  IN varchar2 ,
			  argument11  IN varchar2 ,
			  argument12  IN varchar2 ,
  			  argument13  IN varchar2 ,
			  argument14  IN varchar2 ,
			  argument15  IN varchar2 ,
			  argument16  IN varchar2 ,
			  argument17  IN varchar2 ,
			  argument18  IN varchar2 ,
			  argument19  IN varchar2 ,
			  argument20  IN varchar2 ,
			  argument21  IN varchar2 ,
			  argument22  IN varchar2 ,
  			  argument23  IN varchar2 ,
			  argument24  IN varchar2 ,
			  argument25  IN varchar2 ,
			  argument26  IN varchar2 ,
			  argument27  IN varchar2 ,
			  argument28  IN varchar2 ,
			  argument29  IN varchar2 ,
			  argument30  IN varchar2 ,
			  argument31  IN varchar2 ,
			  argument32  IN varchar2 ,
  			  argument33  IN varchar2 ,
			  argument34  IN varchar2 ,
			  argument35  IN varchar2 ,
			  argument36  IN varchar2 ,
			  argument37  IN varchar2 ,
  			  argument38  IN varchar2 ,
			  argument39  IN varchar2 ,
			  argument40  IN varchar2 ,
			  argument41  IN varchar2 ,
  			  argument42  IN varchar2 ,
			  argument43  IN varchar2 ,
			  argument44  IN varchar2 ,
			  argument45  IN varchar2 ,
			  argument46  IN varchar2 ,
			  argument47  IN varchar2 ,
  			  argument48  IN varchar2 ,
			  argument49  IN varchar2 ,
			  argument50  IN varchar2 ,
			  argument51  IN varchar2 ,
  			  argument52  IN varchar2 ,
			  argument53  IN varchar2 ,
			  argument54  IN varchar2 ,
			  argument55  IN varchar2 ,
			  argument56  IN varchar2 ,
			  argument57  IN varchar2 ,
			  argument58  IN varchar2 ,
			  argument59  IN varchar2 ,
			  argument60  IN varchar2 ,
			  argument61  IN varchar2 ,
			  argument62  IN varchar2 ,
  			  argument63  IN varchar2 ,
			  argument64  IN varchar2 ,
			  argument65  IN varchar2 ,
			  argument66  IN varchar2 ,
			  argument67  IN varchar2 ,
			  argument68  IN varchar2 ,
			  argument69  IN varchar2 ,
			  argument70  IN varchar2 ,
			  argument71  IN varchar2 ,
			  argument72  IN varchar2 ,
  			  argument73  IN varchar2 ,
			  argument74  IN varchar2 ,
			  argument75  IN varchar2 ,
			  argument76  IN varchar2 ,
			  argument77  IN varchar2 ,
			  argument78  IN varchar2 ,
			  argument79  IN varchar2 ,
			  argument80  IN varchar2 ,
			  argument81  IN varchar2 ,
			  argument82  IN varchar2 ,
  			  argument83  IN varchar2 ,
			  argument84  IN varchar2 ,
			  argument85  IN varchar2 ,
			  argument86  IN varchar2 ,
			  argument87  IN varchar2 ,
			  argument88  IN varchar2 ,
			  argument89  IN varchar2 ,
			  argument90  IN varchar2 ,
			  argument91  IN varchar2 ,
			  argument92  IN varchar2 ,
  			  argument93  IN varchar2 ,
			  argument94  IN varchar2 ,
			  argument95  IN varchar2 ,
			  argument96  IN varchar2 ,
			  argument97  IN varchar2 ,
			  argument98  IN varchar2 ,
			  argument99  IN varchar2 ,
			  argument100  IN varchar2 ,
                 p_init_msg_list   IN  VARCHAR2
                 ,x_return_status   OUT NOCOPY VARCHAR2
                 ,x_msg_count       OUT NOCOPY NUMBER
                 ,x_msg_data        OUT NOCOPY VARCHAR2) IS

l_request_id     NUMBER := 0;
l_proc varchar2(72) := '  OKC_OC_INT_PUB.'||'submit_request';

BEGIN

   --
   -- Call fnd_request.submit_request function, to submit concurrent
   -- request
   IF (l_debug = 'Y') THEN
      okc_debug.Set_Indentation(l_proc);
      okc_debug.Log('10: Entering ',2);
   END IF;

   IF (l_debug = 'Y') THEN
      okc_debug.Log('20: Before fnd_request.submit_request for outcome',2);
   END IF;
   l_request_id := fnd_request.submit_request(
		 application, program, description, start_time, sub_request,
		 Argument1,  Argument2,  Argument3,  Argument4,  Argument5,
		 Argument6,  Argument7,  Argument8,  Argument9,  Argument10,
		 Argument11, Argument12, Argument13, Argument14, Argument15,
		 Argument16, Argument17, Argument18, Argument19, Argument20,
		 Argument21, Argument22, Argument23, Argument24, Argument25,
		 Argument26, Argument27, Argument28, Argument29, Argument30,
		 Argument31, Argument32, Argument33, Argument34, Argument35,
		 Argument36, Argument37, Argument38, Argument39, Argument40,
		 Argument41, Argument42, Argument43, Argument44, Argument45,
		 Argument46, Argument47, Argument48, Argument49, Argument50,
		 Argument51, Argument52, Argument53, Argument54, Argument55,
		 Argument56, Argument57, Argument58, Argument59, Argument60,
		 Argument61, Argument62, Argument63, Argument64, Argument65,
		 Argument66, Argument67, Argument68, Argument69, Argument70,
		 Argument71, Argument72, Argument73, Argument74, Argument75,
		 Argument76, Argument77, Argument78, Argument79, Argument80,
		 Argument81, Argument82, Argument83, Argument84, Argument85,
		 Argument86, Argument87, Argument88, Argument89, Argument90,
		 Argument91, Argument92, Argument93, Argument94, Argument95,
		 Argument96, Argument97, Argument98, Argument99, Argument100);
   IF (l_debug = 'Y') THEN
      okc_debug.Log('20: After fnd_request.submit_request for outcome',2);
   END IF;

   IF ( l_request_id <> 0 ) THEN
	 -- Successfully submitted conc request
	 x_return_status := OKC_API.G_RET_STS_SUCCESS;
         IF (l_debug = 'Y') THEN
            okc_debug.Log('30: Conc Req ' || to_char(l_request_id) || ' successfully submitted',2);
         END IF;
         OKC_API.set_message(G_APP_NAME
                             ,'OKC_SUBMIT_REQUEST_SUCCESS'
                             ,'REQUEST_ID'
                             ,to_char(l_request_id));

   ELSE
        -- Error in submitting conc request
	x_return_status := OKC_API.G_RET_STS_ERROR;
        IF (l_debug = 'Y') THEN
           okc_debug.Log('30: Conc Req failed' || to_char(l_request_id),2);
        END IF;
        OKC_API.set_message(G_APP_NAME
                           ,G_UNEXPECTED_ERROR
                           ,G_SQLCODE_TOKEN
                           ,SQLCODE
                           ,G_SQLERRM_TOKEN
                           ,SQLERRM);
   END IF;
   IF (l_debug = 'Y') THEN
      okc_debug.Log('40: Leaving ',2);
      okc_debug.Reset_Indentation;
   END IF;

EXCEPTION WHEN others THEN
   x_msg_data := SQLERRM;
   x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
   OKC_API.set_message(G_APP_NAME
                      ,G_UNEXPECTED_ERROR
                      ,G_SQLCODE_TOKEN
                      ,SQLCODE
                      ,G_SQLERRM_TOKEN
                      ,SQLERRM);
END submit_request;

END OKC_OC_INT_PUB;

/
